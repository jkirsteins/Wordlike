import SwiftUI

/// Lets the user choose a language. Used full screen on first launch (to pick
/// the default) and as a sheet for switching language from the game.
struct LanguagePicker: View {
    let prompt: LocalizedStringKey
    var selected: AppLanguage?
    let onSelect: (AppLanguage) -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 40) {
                    Logo()
                        .frame(maxWidth: .infinity, minHeight: 130)

                    VStack(spacing: 16) {
                        Text(prompt)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(spacing: 8) {
                            ForEach(AppLanguage.allCases) { language in
                                row(for: language)
                            }
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: MockDeviceConfig.inch65_iPhone12ProMax.portrait.width)
                .frame(maxWidth: .infinity)
                // At least a full screen tall, so the content sits in the middle
                // instead of hugging the top (it scrolls if it ever gets taller).
                .frame(minHeight: geometry.size.height)
            }
        }
        .onAppear { FlagImageLoader.shared.loadIfNeeded() }
    }

    private func row(for language: AppLanguage) -> some View {
        Button {
            onSelect(language)
        } label: {
            HStack {
                LanguageRow()
                    .environment(
                        \.gameLocale,
                        language.gameLocale(simplifiedLatvianKeyboard: false)
                    )
                if language == selected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .buttonStyle(LanguageRowButtonStyle())
    }
}

/// Settings row for the language the app opens into.
struct DefaultLanguageSetting: View {
    @AppStorage(AppLanguage.defaultKey) var defaultLanguageID: String = ""

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Default language")
                Text("The game opens in this language.")
                    .font(.caption)
            }
            Spacer()
            Picker("Default language", selection: $defaultLanguageID) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.locale.displayName).tag(language.rawValue)
                }
            }
            .labelsHidden()
            .onChange(of: defaultLanguageID) { newValue in
                Analytics.shared.trackAction(
                    name: "settings.default_language_changed",
                    attributes: ["game_locale": newValue]
                )
            }
        }
    }
}
