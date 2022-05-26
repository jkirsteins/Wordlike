import SwiftUI
import UniformTypeIdentifiers

fileprivate enum ActiveSheet {
    case mail
}

extension ActiveSheet: Identifiable {
    var id: Self { self }
}


struct SettingsView: View {
    
    // iCloud "Hide my e-mail" address
    static let feedbackEmail = "adorables.ambassade_0z@icloud.com"
    
    // Min width for right-hand widgets
    static let minRightWidth = CGFloat(0)
    
#if os(iOS)
    @State var mailData = ComposeMailData(
        subject: NSLocalizedString("Feedback about Wordlike", comment: ""),
        recipients: [
            Self.feedbackEmail
        ],
        message: "",
        attachments: [])
#endif
    
    static let HIGH_CONTRAST_KEY = "cfg.isHighContrast"
    static let SIMPLIFIED_LATVIAN_KEYBOARD_KEY = "cfg.isSimplifiedLatvianKeyboard"
    static let HARD_MODE_KEY = "cfg.isHardMode"
    
    @Environment(\.debug) var debug: Bool
    
    @State fileprivate var activeSheet: ActiveSheet? = nil
    
    @AppStateStorage(SettingsView.HIGH_CONTRAST_KEY)
    var isHighContrast: Bool = false
    
    @AppStateStorage(SettingsView.SIMPLIFIED_LATVIAN_KEYBOARD_KEY)
    var isSimplifiedLatvianKeyboard: Bool = false
    
    @AppStateStorage(SettingsView.HARD_MODE_KEY)
    var isHardMode: Bool = false
    
    @AppStateStorage("turnState.en")
    var dailyStateEn: DailyState? = nil
    
    @AppStateStorage("turnState.fr")
    var dailyStateFr: DailyState? = nil
    
    @AppStateStorage("turnState.lv")
    var dailyStateLv: DailyState? = nil
    
    @State var emailCopied = false
    
    var contrastSettings: some View {
        HStack {
            Toggle(isOn: $isHighContrast) {
                VStack(alignment: .leading) {
                    Text("High contrast mode")
                    Text("For improved color vision.")
                        .font(.caption)
                }
            }
        }
    }
    
    var hardModeSettings: some View {
        Group {
            Toggle(isOn: $isHardMode) {
                VStack(alignment: .leading) {
                    Text("Hard mode")
                    Text("Any revealed hints must be used in subsequent guesses.")
                        .font(.caption)
                }
            }
            
            Toggle(isOn: $isSimplifiedLatvianKeyboard) {
                VStack(alignment: .leading) {
                    Text("Simplified Latvian keyboard")
                    Text("Do not require precise use of diacritics.")
                        .font(.caption)
                }
            }
        }
    }
    
    var feedbackSettings: some View {
        Group {
#if os(iOS)
            if MailView.canSendMail {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Feedback")
                        Text("You can send feedback via e-mail.").font(.caption)
                    }
                    Spacer()
                    Button("Send") {
                        activeSheet = .mail
                    }.frame(minWidth: Self.minRightWidth)
                }
            }
#endif
            
            HStack {
                VStack(alignment: .leading) {
#if os(iOS)
                    if MailView.canSendMail {
                        Text("Feedback (manual)")
                    } else {
                        Text("Feedback")
                    }
#else
                    Text("Feedback")
#endif
                    Text("Click to copy feedback e-mail address.").font(.caption)
                }
                Spacer()
                HStack {
                    if emailCopied {
                        
                        Text("Copied")
                            .font(.caption)
                            .foregroundColor(Color(NativeColor.secondaryLabel))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    emailCopied = false
                                }
                            }
                        
                    } else {
                        Button(action: {
#if os(iOS)
                            NativePasteboard.general.setValue(
                                Self.feedbackEmail,
                                forPasteboardType: UTType.plainText.identifier)
#else
                            NativePasteboard.general.setString(
                                Self.feedbackEmail, forType: .string)
#endif
                            
                            emailCopied = true
                        }, label: {
                            Image(systemName: "doc.on.clipboard")
                        })
                    }
                }.frame(minWidth: Self.minRightWidth)
                
            }
        }
    }
    
    var socialSettings: some View {
        Group {
            HStack {
                VStack(alignment: .leading) {
                    Text("Source code")
                    Text("This game was created using Swift Playgrounds 4 on an iPad.\n\nThe source code is freely available.")
                        .font(.caption)
                }
                
                Spacer()
                
                Link(destination: URL(string: "https://github.com/jkirsteins/SimpleWordGame")!, label: {
                    Text("GitHub")
                })
                .frame(minWidth: Self.minRightWidth)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Author")
                    Text("Made by Jānis Kiršteins.")
                        .font(.caption)
                }
                
                Spacer()
                
                Link(destination: URL(string: "https://twitter.com/jkirsteins")!, label: {
                    Text("Twitter")
                })
                .frame(minWidth: Self.minRightWidth)
            }
        }
    }
    
    @ViewBuilder
    var optDebugSettings: some View {
        if debug {
            Group {
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Reset all state").font(.body)
                        Text("Clear all historical stats and today's progress").font(.caption)
                    }
                    Spacer()
                    Button("Full reset") {
                        if let bundleID = Bundle.main.bundleIdentifier {
                            UserDefaults.standard.removePersistentDomain(forName: bundleID)
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Reset turn (EN)").font(.body)
                        Text("Reset today's state only (EN)").font(.caption)
                    }
                    Spacer()
                    Button("Reset") {
                        dailyStateEn = nil
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Reset turn (FR)").font(.body)
                        Text("Reset today's state only (FR)").font(.caption)
                    }
                    Spacer()
                    Button("Reset") {
                        dailyStateFr = nil
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Reset turn (LV)").font(.body)
                        Text("Reset today's state only (LV)").font(.caption)
                    }
                    Spacer()
                    Button("Reset") {
                        dailyStateLv = nil
                    }
                }
                
                Divider()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            contrastSettings
            
            Divider()
            
            hardModeSettings
            
            Divider()
            
            feedbackSettings
            
            Divider()
            
            // Social
            socialSettings
            
            // Since optional, the divider is included inside
            optDebugSettings
        }
        .navigationTitle("Settings")
        
        // Feedback e-mail sheet is only available in iOS
#if os(iOS)
        .sheet(item: $activeSheet, onDismiss: {
            
        }, content: { item in
            switch(item) {
            case .mail:
                MailView(data: $mailData) { _ in
                    
                }
            }
        })
#endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
