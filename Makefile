PBXPROJ := SimpleWordGame.xcodeproj/project.pbxproj

.PHONY: lint format setup test version bump-patch bump-minor bump-major

# Run SwiftLint
lint:
	swiftlint lint --strict

# Run SwiftFormat
format:
	swiftformat .

# Install pre-commit hooks and copy config templates
setup:
	@if [ ! -f Config/Datadog.xcconfig ]; then \
		mkdir -p Config; \
		cp Config/Datadog.xcconfig.template Config/Datadog.xcconfig; \
		echo "Created Config/Datadog.xcconfig from template — fill in your Datadog credentials."; \
	fi
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		pre-commit install --hook-type pre-push; \
		echo "Pre-commit and pre-push hooks installed."; \
	else \
		echo "warning: pre-commit not found. Install with: brew install pre-commit"; \
	fi

# Run unit tests
test:
	xcodebuild test \
		-scheme "SimpleWordGame (iOS)" \
		-destination 'platform=iOS Simulator,name=iPhone 16e Test' \
		-configuration Debug \
		-only-testing:WordlikeTests \
		-quiet

# Show current version
version:
	@v=$$(grep 'MARKETING_VERSION' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/ *;//'); \
	b=$$(grep 'CURRENT_PROJECT_VERSION' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/ *;//'); \
	echo "$$v ($$b)"

# Bump patch version (e.g. 1.0.2 -> 1.0.3) and reset build to 1
bump-patch:
	@v=$$(grep 'MARKETING_VERSION' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/ *;//'); \
	major=$$(echo $$v | cut -d. -f1); \
	minor=$$(echo $$v | cut -d. -f2); \
	patch=$$(echo $$v | cut -d. -f3); \
	new="$$major.$$minor.$$((patch + 1))"; \
	sed -i '' "s/MARKETING_VERSION = $$v;/MARKETING_VERSION = $$new;/g" $(PBXPROJ); \
	sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = 1;/g' $(PBXPROJ); \
	echo "Version: $$v -> $$new (build reset to 1)"

# Bump minor version (e.g. 1.0.2 -> 1.1.0) and reset build to 1
bump-minor:
	@v=$$(grep 'MARKETING_VERSION' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/ *;//'); \
	major=$$(echo $$v | cut -d. -f1); \
	minor=$$(echo $$v | cut -d. -f2); \
	new="$$major.$$((minor + 1)).0"; \
	sed -i '' "s/MARKETING_VERSION = $$v;/MARKETING_VERSION = $$new;/g" $(PBXPROJ); \
	sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = 1;/g' $(PBXPROJ); \
	echo "Version: $$v -> $$new (build reset to 1)"

# Bump major version (e.g. 1.0.2 -> 2.0.0) and reset build to 1
bump-major:
	@v=$$(grep 'MARKETING_VERSION' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/ *;//'); \
	major=$$(echo $$v | cut -d. -f1); \
	new="$$((major + 1)).0.0"; \
	sed -i '' "s/MARKETING_VERSION = $$v;/MARKETING_VERSION = $$new;/g" $(PBXPROJ); \
	sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = 1;/g' $(PBXPROJ); \
	echo "Version: $$v -> $$new (build reset to 1)"
