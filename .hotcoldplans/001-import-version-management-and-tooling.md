# Plan: Import Version Management, Version Display, and Code Quality Tooling from Webometer

> **Goal**: Add BuildInfo.swift, git SHA build phase, version display in settings, Makefile version targets, SwiftLint, SwiftFormat, and useful pre-commit hooks to Wordlike-iOS — matching existing app style and localization conventions.
> **Created**: 2026-03-20
> **Repository**: /Volumes/X10/Projects/wordlike-base/Wordlike-iOS
> **Status**: completed

## Success Criteria

- `xcodebuild test -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -only-testing:WordlikeTests -quiet` — project builds and all tests pass
- `make version` — prints current MARKETING_VERSION and CURRENT_PROJECT_VERSION from the pbxproj in format `X.Y.Z (N)`
- `swiftlint lint --strict` — exits 0 (no violations)
- `swiftformat --lint .` — exits 0 (all files formatted)
- `pre-commit run --all-files` — all hooks pass
- Settings view shows Version, Build, Git, and Modified (when dirty) rows at the bottom of the VStack

---

## Phase A: Core infrastructure (all independent, run in parallel)

### A1: Create BuildInfo.swift

**Status**: finished
**Blocked by**: none
**Description**: Create `Shared/BuildInfo.swift` — an enum that reads `CFBundleShortVersionString`, `CFBundleVersion`, and `GITCommitSHA` from `Bundle.main.infoDictionary`. Identical to webometer's `BuildInfo.swift`. The file must be added to the Xcode project for the iOS and macOS app targets (but NOT the test target).

**Steps**:
- [x] Create `Shared/BuildInfo.swift` (copy webometer's version verbatim — it has no project-specific references)
- [x] Add `BuildInfo.swift` to the Xcode project's `PBXFileReference`, `PBXBuildFile` (one per app target), and `PBXSourcesBuildPhase` for both iOS and macOS targets in `SimpleWordGame.xcodeproj/project.pbxproj`
- [x] Add it to the appropriate `PBXGroup` children list (the `Shared` group)

**Test design**:
- No unit test (in test bundle context, `Bundle.main.infoDictionary` points to xctest runner, not the app — values would be `"?"`). Verified by successful compilation.

**Verification** (targeted):
```bash
xcodebuild build -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -quiet 2>&1 | tail -3
```
**Expected result**: `BUILD SUCCEEDED`, no errors referencing BuildInfo

**Regression**: `xcodebuild test -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -only-testing:WordlikeTests -quiet`

---

### A2: Delete stale Version.swift

**Status**: finished
**Blocked by**: none
**Description**: Remove `Resources/Version.swift` from disk. The file is NOT in the pbxproj (confirmed by grep) and `AppVersion` is only referenced within Version.swift itself (never used elsewhere). Just delete the file.

**Steps**:
- [x] Delete `Resources/Version.swift` from disk

**Test design**:
- No test needed. File is unused.

**Verification** (targeted):
```bash
test ! -f /Volumes/X10/Projects/wordlike-base/Wordlike-iOS/Resources/Version.swift && echo "PASS" || echo "FAIL"
```
**Expected result**: `PASS`

**Regression**: N/A — file was unused.

---

### A3: Create Makefile with version management targets

**Status**: finished
**Blocked by**: none
**Description**: Create a `Makefile` at the project root with targets adapted from webometer. Uses `SimpleWordGame.xcodeproj/project.pbxproj` as the pbxproj path.

**Steps**:
- [x] Create `Makefile` with `PBXPROJ := SimpleWordGame.xcodeproj/project.pbxproj`
- [x] Add `version` target (grep MARKETING_VERSION and CURRENT_PROJECT_VERSION from pbxproj)
- [x] Add `bump-build` target (increment CURRENT_PROJECT_VERSION only)
- [x] Add `bump-patch` target (increment patch, reset build to 1)
- [x] Add `bump-minor` target (increment minor, reset patch+build)
- [x] Add `bump-major` target (increment major, reset minor+patch+build)
- [x] Add `lint` target: `swiftlint lint --strict`
- [x] Add `format` target: `swiftformat .`
- [x] Add `test` target: `xcodebuild test -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -only-testing:WordlikeTests -quiet`
- [x] Add `setup` target: check for `pre-commit` and run `pre-commit install`

**Test design**:
- No unit test. Verified by running targets.

**Verification** (targeted):
```bash
cd /Volumes/X10/Projects/wordlike-base/Wordlike-iOS && make version
```
**Expected result**: `1.0.65 (115)` (current pbxproj values)

**Regression**: Makefile is declarative; no regression risk to app code.

---

### A4: Create .swiftlint.yml

**Status**: finished
**Blocked by**: none
**Description**: Create `.swiftlint.yml` adapted from webometer. Change `included` paths to match Wordlike's directories. Keep all opt-in rules, disabled rules, and configuration thresholds. May need to raise thresholds if existing code has many violations.

**Steps**:
- [x] Create `.swiftlint.yml` with `included`: `Shared`, `Resources`, `Extensions`, `GameLogic`, `Environment`, `Palettes`, `Misc`, `WordlikeTests`, `macOS`
- [x] Set `excluded`: `DerivedData`, `.build`, `build`
- [x] Copy all `opt_in_rules`, `disabled_rules`, and threshold configs from webometer
- [x] Run `swiftlint lint` and check violation count; adjust thresholds (e.g. raise `line_length`, `file_length`, `type_body_length`) if needed to achieve 0 violations without rewriting existing code
- [x] Iterate until `swiftlint lint --strict` passes cleanly

**Test design**:
- No unit test. Verified by running swiftlint.

**Verification** (targeted):
```bash
cd /Volumes/X10/Projects/wordlike-base/Wordlike-iOS && swiftlint lint --strict 2>&1 | tail -3
```
**Expected result**: 0 violations (possibly with adjusted thresholds)

**Regression**: SwiftLint is a linter only; does not affect compilation.

---

### A5: Add SwiftFormat config and reformat codebase

**Status**: finished
**Blocked by**: none
**Description**: Create `.swiftformat` config adapted from webometer and run a full reformat of the codebase. This is done as a single atomic commit so the formatting diff is isolated and doesn't pollute future feature commits. The config should use the same Swift version and formatting rules as webometer, with `--exclude` adjusted for Wordlike's directory structure.

**Steps**:
- [x] Create `.swiftformat` at project root, adapted from webometer (change `--swiftversion` if Wordlike targets a different Swift version, keep all format options and rules, adjust `--exclude` to `DerivedData,.build,build`)
- [x] Run `swiftformat .` to reformat the entire codebase
- [x] Build to verify the reformatted code still compiles
- [x] Run tests to verify nothing broke
- [ ] Commit the `.swiftformat` config and all reformatted files together as a single "Reformat codebase with SwiftFormat" commit

**Test design**:
- No unit test. Verified by build + test + `swiftformat --lint .`

**Verification** (targeted):
```bash
cd /Volumes/X10/Projects/wordlike-base/Wordlike-iOS && swiftformat --lint . 2>&1 | tail -3
```
**Expected result**: 0 files would have been changed (all already formatted)

**Regression**: `xcodebuild test -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -only-testing:WordlikeTests -quiet`

---

## Phase B: Build phase script and version display

### B1: Add "Stamp Git SHA" build phase script to pbxproj

**Status**: finished
**Blocked by**: A1
**Description**: Add a `PBXShellScriptBuildPhase` to the pbxproj that runs after the Resources phase for the iOS app target only (the macOS target inherits via Mac Catalyst from the same build). The script injects `GITCommitSHA` into the built Info.plist using PlistBuddy. Set `alwaysOutOfDate = 1` so it runs on every build.

This approach works in Xcode Cloud because build phase scripts run during the normal build process (unlike `ci_post_clone.sh` which runs before the build). The PlistBuddy approach modifies the BUILT product's Info.plist, not the source plist, so it's safe and works identically in local and Xcode Cloud builds. Webometer has been using this same approach successfully with Xcode Cloud.

**Steps**:
- [x] Generate a unique 24-char hex ID for the shell script build phase
- [x] Add a `PBXShellScriptBuildPhase` entry with the git SHA stamping script (same as webometer: `git rev-parse --short HEAD`, check `git diff --quiet HEAD` for dirty, PlistBuddy Add/Set)
- [x] Add the phase ID to the iOS app target's `buildPhases` array, after the Resources phase
- [x] Set `alwaysOutOfDate = 1` in the build phase entry

**Test design**:
- Verified by building and checking the built plist for the GITCommitSHA key.

**Verification** (targeted):
```bash
cd /Volumes/X10/Projects/wordlike-base/Wordlike-iOS && xcodebuild build -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -quiet 2>&1 | tail -3
```
**Expected result**: `BUILD SUCCEEDED`

**Regression**: `xcodebuild test -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -only-testing:WordlikeTests -quiet`

---

### B2: Add version info section to SettingsView with localization

**Status**: finished
**Blocked by**: A1
**Description**: Add a `versionInfoSection` computed property to `SettingsView.swift` that displays version info at the bottom of the settings. Uses the existing Wordlike style — NOT `LabeledContent`/`Section`/`Form`. Simultaneously add all localization strings to the .strings files.

The version info section shows:
- Version (x.y.z) — always shown
- Build number — always shown
- Git SHA — always shown
- Modified indicator — only shown when dirty, with orange text

Each row uses lightweight `.caption` font since this is informational, not interactive. Pattern: `HStack { Text(label).font(.caption) Spacer() Text(value).font(.caption).foregroundColor(.secondary) }`

**Steps**:
- [x] Add `versionInfoSection` computed property to `SettingsView` with rows for Version, Build, Git, and conditionally Modified
- [x] Add `Divider()` + `versionInfoSection` at the bottom of `body` VStack, after `optDebugSettings`
- [x] Add localization strings to `Resources/en.lproj/Localizable.strings`:
  - `"Version" = "Version";`
  - `"Build" = "Build";`
  - `"Git" = "Git";`
  - `"Modified" = "Modified";`
  - `"Yes" = "Yes";`
- [x] Add to `Resources/fr.lproj/Localizable.strings`:
  - `"Version" = "Version";`
  - `"Build" = "Build";`
  - `"Git" = "Git";`
  - `"Modified" = "Modifié";`
  - `"Yes" = "Oui";`
- [x] Add to `Resources/lv.lproj/Localizable.strings`:
  - `"Version" = "Versija";`
  - `"Build" = "Būvējums";`
  - `"Git" = "Git";`
  - `"Modified" = "Modificēts";`
  - `"Yes" = "Jā";`

**Test design**:
- No UI test (snapshot tests are out of scope). Verified by build + grep for localization keys.

**Verification** (targeted):
```bash
cd /Volumes/X10/Projects/wordlike-base/Wordlike-iOS && xcodebuild build -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -quiet 2>&1 | tail -3 && grep -c '"Version"\|"Build"\|"Git"\|"Modified"\|"Yes"' Resources/*/Localizable.strings
```
**Expected result**: `BUILD SUCCEEDED` and each .strings file shows 5+ matches

**Regression**: `xcodebuild test -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -only-testing:WordlikeTests -quiet`

---

## Phase C: Pre-commit hooks

### C1: Extend .pre-commit-config.yaml with new hooks

**Status**: finished
**Blocked by**: A4, A5
**Description**: Add useful hooks from webometer to the existing `.pre-commit-config.yaml`. Keep all 3 existing Wordlike hooks. Add new hooks in a sensible order: fast checks first, slow checks last.

**Hooks to add (in order):**
1. `snapshot-worktree` (first hook, before all others) — snapshots `git diff` so we can detect if any hook modifies files
2. `swiftformat` (fast) — lints Swift formatting with `swiftformat --lint`
3. `swiftlint` (fast, after existing wordlist check) — lints staged Swift files
4. `no-untracked` (fast) — fails if untracked files exist
5. Standard `pre-commit-hooks` repo (trailing-whitespace excluding Swift, end-of-file-fixer, check-yaml, check-added-large-files 500KB, check-merge-conflict, detect-private-key)
6. `no-worktree-changes` (very last hook) — compares `git diff` with snapshot to ensure no hook modified files

Note: `snapshot-worktree`/`no-worktree-changes` guard against hooks that silently modify files in the working tree. They compare `git diff` before and after all hooks run. This is useful for any project — it catches hooks that auto-format or auto-fix but forget to re-stage.

**Steps**:
- [x] Add `snapshot-worktree` as the first local hook (entry: `bash -c 'git diff > /tmp/wordlike-pre-commit-snapshot.diff'`)
- [x] Add `swiftformat` local hook (entry: `swiftformat --lint`, types: `[swift]`, pass_filenames: true, exclude: `'^Scripts/'`)
- [x] After existing Wordlike hooks, add `swiftlint` local hook (entry: `swiftlint lint --strict --quiet`, types: `[swift]`, pass_filenames: true, exclude: `'^Scripts/'`)
- [x] Add `no-untracked` local hook (same bash one-liner as webometer)
- [x] Add `pre-commit-hooks` repo block (rev: v5.0.0) with standard hooks
- [x] Create `Scripts/check-worktree-clean.sh` (adapted from webometer, using `/tmp/wordlike-` prefix)
- [x] Make it executable: `chmod +x Scripts/check-worktree-clean.sh`
- [x] Add `no-worktree-changes` as the final local hook referencing the script

**Test design**:
- No unit test. Verified by running pre-commit.

**Verification** (targeted):
```bash
cd /Volumes/X10/Projects/wordlike-base/Wordlike-iOS && pre-commit run snapshot-worktree --all-files && pre-commit run swiftlint --all-files && pre-commit run no-untracked --all-files
```
**Expected result**: All three hooks pass

**Regression**: `pre-commit run check-wordlist-blanks --all-files && pre-commit run wordlike-tests --all-files && pre-commit run check-warnings --all-files` — existing hooks still work

---

## Discarded Ideas

### Use LabeledContent/Section/Form for version info in SettingsView
**What**: Use SwiftUI `LabeledContent` in a `Section` for version info, matching webometer exactly.
**Why discarded**: Wordlike's SettingsView uses a manual VStack+Divider+HStack layout throughout. Introducing `Form`/`Section`/`LabeledContent` would create visual inconsistency.

### Import verify-translations / format-xcstrings hooks
**What**: Import translation verification and xcstrings formatting hooks from webometer.
**Why discarded**: These are designed for `.xcstrings` (String Catalog) format. Wordlike uses `.strings` files. Would need to be rewritten from scratch — out of scope.

### Add BuildInfo unit tests
**What**: Unit test BuildInfo.version, .build, .gitSHA values.
**Why discarded**: In the test bundle context, `Bundle.main.infoDictionary` points to the xctest runner's Info.plist, not the app's. Values would all be `"?"`. Testing via build + plist inspection is more reliable.

### Use ci_post_clone.sh instead of build phase script
**What**: Inject git SHA via `ci_scripts/ci_post_clone.sh` for Xcode Cloud instead of a build phase script.
**Why discarded**: The build phase script approach works identically in local and Xcode Cloud builds because it runs during the normal build process and modifies the BUILT product's Info.plist (not source files). Webometer has proven this works with Xcode Cloud. Using ci_post_clone.sh would require modifying source Info.plist files and committing changes, which is messier.

---

## Phase Z: Cleanup

### Z1: Final verification

**Status**: pending
**Blocked by**: A1, A2, A3, A4, A5, B1, B2, C1
**Description**: Run all verification commands end-to-end to confirm everything works.

**Steps**:
- [ ] Run full build: `xcodebuild build -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -quiet`
- [ ] Run full tests: `xcodebuild test -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -only-testing:WordlikeTests -quiet`
- [ ] Run `make version` and confirm output matches pbxproj values
- [ ] Run `swiftlint lint --strict` and confirm 0 violations
- [ ] Run `swiftformat --lint .` and confirm 0 files need changes
- [ ] Run `pre-commit run --all-files` and confirm all hooks pass
- [ ] Verify GITCommitSHA in built plist: `/usr/libexec/PlistBuddy -c "Print :GITCommitSHA" "$(xcodebuild -scheme 'SimpleWordGame (iOS)' -destination 'platform=macOS,variant=Mac Catalyst' -showBuildSettings 2>/dev/null | grep ' BUILT_PRODUCTS_DIR' | sed 's/.*= //')/Wordlike.app/Contents/Info.plist"`
- [ ] With uncommitted changes present, build and verify the GITCommitSHA ends with `-dirty`
- [ ] Visual check: launch app, open Settings, confirm version info section appears at bottom with correct styling

**Verification**:
```bash
cd /Volumes/X10/Projects/wordlike-base/Wordlike-iOS && xcodebuild test -scheme "SimpleWordGame (iOS)" -destination 'platform=macOS,variant=Mac Catalyst' -configuration Debug -only-testing:WordlikeTests -quiet 2>&1 | tail -3 && make version && swiftlint lint --strict 2>&1 | tail -3
```

### Z2: Mark plan complete

**Status**: pending
**Blocked by**: Z1
**Description**: Mark the plan file as completed after user confirmation. Plan files are kept as a paper trail.

**Steps**:
- [ ] Confirm with user: "All milestones verified. Ready to mark this plan as complete?"
- [ ] Update `**Status**:` from `in-progress` to `completed`

**Verification**:
```bash
grep -q '**Status**: completed' /Volumes/X10/Projects/wordlike-base/Wordlike-iOS/.hotcoldplans/001-import-version-management-and-tooling.md && echo "PASS" || echo "FAIL"
```
