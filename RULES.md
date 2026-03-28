# Rules

## Code Quality

- **Zero warnings policy**: The project must compile with 0 warnings at all times. No exceptions.
- **Never relax linter rules**: SwiftLint and SwiftFormat rules must never be weakened, disabled, or bypassed. If code doesn't pass, fix the code — not the rules.
- **No inline rule suppressions**: Do not use `// swiftlint:disable` or equivalent annotations to silence warnings or errors.
- **Never skip hooks**: Do not use `--no-verify`, `--no-gpg-sign`, or any other flag to bypass pre-commit hooks. If hooks fail, fix the underlying issue.

## Localization

- **Supported languages**: English (`en`) as base language, French (`fr`) and Latvian (`lv`) as full translations.
- **Complete coverage**: All user-facing strings must be translated in all supported languages. No string may be left unlocalized.

## General

- **No TODO/FIXME debt**: Do not introduce TODO or FIXME comments that defer work indefinitely. If something needs doing, do it or create a tracked issue.
- **Follow existing conventions**: Match the style, patterns, and architecture already established in the codebase.
