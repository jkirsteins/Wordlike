# Wordlike (iOS)

**Before starting any work, always read these files:**
- `RULES.md` — Mandatory code quality rules. Follow them strictly.

## Project Structure
- **iOS app**: `Wordlike.swift` — SwiftUI app entry point
- **Shared code**: `Shared/` — Game logic, UI, environment keys, extensions
- **Resources**: `Resources/` — Localization files and word lists
- **Tests**: `WordlikeTests/` — Unit tests (XCTest)
- **Xcode project**: `SimpleWordGame.xcodeproj` (raw .xcodeproj, not generated)

## Build & Run
- `make setup` — Install pre-commit hooks and create config files from templates
- `make lint` — Run SwiftLint (strict mode)
- `make format` — Run SwiftFormat
- `make test` — Run unit tests

## Versioning
- Use `make bump-patch`, `make bump-minor`, or `make bump-major` to modify version numbers. Never edit `MARKETING_VERSION` or `CURRENT_PROJECT_VERSION` in `project.pbxproj` by hand.
- Build numbers (`CURRENT_PROJECT_VERSION`) are set automatically by Xcode Cloud. Do not bump them manually.

## Conventions
- SwiftUI for all UI
- Follow SwiftLint and SwiftFormat rules (`.swiftlint.yml`, `.swiftformat`)
- Zero warnings allowed — fix all warnings immediately
- Full English, French, and Latvian localization coverage required
