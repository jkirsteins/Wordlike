---
name: rum-report
description: Generate an executive summary of Wordlike's RUM (Real User Monitoring) data from Datadog using the pup CLI. Use this skill whenever the user asks about app analytics, user metrics, engagement data, funnel analysis, user growth, RUM reports, or wants to understand how users interact with Wordlike. Also trigger when the user mentions "rum report", "analytics summary", "user stats", "engagement metrics", "funnel", or asks questions like "how many users do we have" or "what's our win rate".
---

# Wordlike RUM Executive Report

Generate an executive summary of Wordlike iOS app analytics by querying Datadog RUM data via the `pup` CLI.

## Arguments

The user may specify a time range. Default to `7d` if not provided. Examples:
- `/rum-report` - last 7 days
- `/rum-report 30d` - last 30 days
- `/rum-report 1d` - last 24 hours

Parse the argument as the `PERIOD` variable used throughout.

## Tool: pup CLI

All Datadog queries use `pup rum sessions search` (which queries ALL RUM event types, not just sessions) with the `--query` flag for server-side filtering. Every invocation must set the EU site:

```bash
DD_SITE=datadoghq.eu pup rum sessions search --from=<PERIOD> --limit=<N> --query='<Datadog search query>'
```

The response is JSON with structure `{ "data": [ { "attributes": { "attributes": { ... } } } ] }`. The inner `attributes` contains the event fields. Use `jq` to extract data from `.data[].attributes.attributes`.

Do NOT use `pup rum events` - it lacks query filtering. Always use `pup rum sessions search`.

## App Context

Wordlike is an iOS Wordle clone supporting 4 game locales with `fileBaseName` values: `en`, `en-GB`, `fr`, `lv`.

**Custom Actions tracked:**
| Action | Key Attributes |
|---|---|
| `language.switched` | `context.game_locale`, `context.time_to_first_interaction_ms` |
| `game.started` | `context.game_locale` |
| `game.row_submitted` | `context.game_locale`, `context.attempt_number` |
| `game.invalid_word` | `context.game_locale` |
| `game.won` | `context.game_locale`, `context.attempts`, `context.game.duration_seconds` |
| `game.lost` | `context.game_locale`, `context.game.duration_seconds` |
| `game.shared` | `context.game_locale` |
| `settings.high_contrast_toggled` | `context.enabled` (string: `"true"` or `"false"`) |
| `settings.hard_mode_toggled` | `context.enabled` (string: `"true"` or `"false"`) |

## Queries

All queries filter on `service:wordlike env:production` and use `--from=<PERIOD>`. Run as many in parallel as possible (multiple Bash calls in one message).

**Funnel counts** (one query per step):
```bash
# language.switched count
DD_SITE=datadoghq.eu pup rum sessions search --from=7d --limit=500 \
  --query='service:wordlike @type:action @action.name:language.switched env:production' \
  | jq '.data | length'

# game.started (with locale breakdown)
DD_SITE=datadoghq.eu pup rum sessions search --from=7d --limit=500 \
  --query='service:wordlike @type:action @action.name:game.started env:production' \
  | jq '{count: (.data | length), locales: ([.data[].attributes.attributes.context.game_locale // "unknown"] | group_by(.) | map({locale: .[0], count: length}) | sort_by(-.count))}'

# game.won (with details for win rate, duration, attempts, locale)
DD_SITE=datadoghq.eu pup rum sessions search --from=7d --limit=500 \
  --query='service:wordlike @type:action @action.name:game.won env:production' \
  | jq '{count: (.data | length), events: [.data[].attributes.attributes | {attempts: .context.attempts, duration: .context.game.duration_seconds, locale: (.context.game_locale // "unknown")}]}'

# game.lost (with details)
DD_SITE=datadoghq.eu pup rum sessions search --from=7d --limit=500 \
  --query='service:wordlike @type:action @action.name:game.lost env:production' \
  | jq '{count: (.data | length), events: [.data[].attributes.attributes | {duration: .context.game.duration_seconds, locale: (.context.game_locale // "unknown")}]}'

# game.shared count
DD_SITE=datadoghq.eu pup rum sessions search --from=7d --limit=500 \
  --query='service:wordlike @type:action @action.name:game.shared env:production' \
  | jq '.data | length'

# game.invalid_word count
DD_SITE=datadoghq.eu pup rum sessions search --from=7d --limit=500 \
  --query='service:wordlike @type:action @action.name:game.invalid_word env:production' \
  | jq '.data | length'

# game.row_submitted count
DD_SITE=datadoghq.eu pup rum sessions search --from=7d --limit=500 \
  --query='service:wordlike @type:action @action.name:game.row_submitted env:production' \
  | jq '.data | length'
```

**Sessions + users + device/geo:**
```bash
DD_SITE=datadoghq.eu pup rum sessions search --from=7d --limit=500 \
  --query='service:wordlike @type:session env:production' \
  | jq '{
    total_sessions: (.data | length),
    unique_users: ([.data[].attributes.attributes.usr.anonymous_id] | unique | length),
    devices: ([.data[].attributes.attributes.device.model // "unknown"] | group_by(.) | map({model: .[0], count: length}) | sort_by(-.count)),
    countries: ([.data[].attributes.attributes.geo.country // "unknown"] | group_by(.) | map({country: .[0], count: length}) | sort_by(-.count)),
    os_versions: ([.data[].attributes.attributes.os.version // "unknown"] | group_by(.) | map({version: .[0], count: length}) | sort_by(-.count))
  }'
```

**Errors:**
```bash
DD_SITE=datadoghq.eu pup rum sessions search --from=7d --limit=500 \
  --query='service:wordlike @type:error env:production' \
  | jq '{count: (.data | length), errors: [.data[].attributes.attributes | {message: .error.message, source: .error.source}]}'
```

**Settings toggles:**
```bash
DD_SITE=datadoghq.eu pup rum sessions search --from=7d --limit=500 \
  --query='service:wordlike @type:action @action.name:(settings.hard_mode_toggled OR settings.high_contrast_toggled) env:production' \
  | jq '[.data[].attributes.attributes.action.name] | group_by(.) | map({action: .[0], count: length})'
```

## Execution

1. Parse the time range from arguments (default: `7d`)
2. Run pup queries in parallel (multiple Bash calls in one message) - at minimum 4 parallel calls:
   - Funnel actions (language.switched, game.started, game.won, game.lost, game.shared, game.invalid_word, game.row_submitted)
   - Sessions + users + devices + geo
   - Errors
   - Settings toggles
3. Compute derived metrics:
   - Win rate = won / (won + lost)
   - Avg duration from `game.duration_seconds` (use `tonumber`; filter out null values before averaging)
   - Avg attempts from `attempts` on won events (string - parse to int)
   - Locale distribution from `game_locale` on game.started events
   - Funnel conversion rates (step-to-step)
   - Sessions per user
   - Error rate per 1000 sessions
4. Format and output the report

## Report Template

```
# Wordlike RUM Executive Summary
**Period:** last [N]d
**Generated:** [today's date]

## User Activity
- **Total Sessions:** N
- **Unique Users (anonymous):** N
- **Sessions per User:** N.N

## Game Funnel
| Step | Count | Conversion |
|---|---|---|
| Language Selected | N | 100% |
| Game Started | N | N% of selected |
| Game Completed | N | N% of started |
| Game Won | N | N% win rate |
| Game Shared | N | N% of completed |

## Engagement
- **Win Rate:** N%
- **Avg Attempts (wins):** N.N / 6
- **Avg Game Duration:** Nm Ns
- **Total Submissions:** N
- **Invalid Word Rate:** N% of submissions

## Locale Breakdown
| Locale | Games Started | Share |
|---|---|---|
| en | N | N% |
| en-GB | N | N% |
| fr | N | N% |
| lv | N | N% |

## Device & Geography
- **Top Devices:** model (N%), ...
- **Top Countries:** country (N%), ...
- **iOS Versions:** ver (N%), ...

## Errors
- **Total Errors:** N
- **Error Rate:** N per 1000 sessions

## Settings Usage
- **Hard Mode Toggled:** N times
- **High Contrast Toggled:** N times
```

## Notes

- If a query returns exactly `--limit` results, the true count may be higher. Note "N+" in the report.
- If pup returns an auth error, tell the user to run `! DD_SITE=datadoghq.eu pup auth login`.
- If a metric has no data, still include it with "0" or "N/A".
- `game.duration_seconds` is sent as `Int` from Swift, but Datadog may return it as a JSON string. Always parse with `tonumber` to handle either form. This field is absent (null) when no guesses were submitted before the game ended - filter nulls before computing averages.
- `attempts` on game.won is always a string like "3" - parse to int with `tonumber`.
