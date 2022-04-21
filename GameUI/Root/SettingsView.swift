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
    
    @State var mailData = ComposeMailData(
        subject: "Feedback about \(Bundle.main.displayName)",
        recipients: [
            Self.feedbackEmail
        ],
        message: "",
        attachments: [])
    
    static let HIGH_CONTRAST_KEY = "cfg.isHighContrast"
    
    @Environment(\.debug) var debug: Bool
    
    @State fileprivate var activeSheet: ActiveSheet? = nil
    
    @AppStorage(SettingsView.HIGH_CONTRAST_KEY) 
    var isHighContrast: Bool = false
    
    @AppStorage("turnState.en")
    var dailyStateEn: DailyState?
    
    @AppStorage("turnState.fr")
    var dailyStateFr: DailyState?
    
    @AppStorage("turnState.lv")
    var dailyStateLv: DailyState?
    
    @State var emailCopied = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(Font.system(.title).smallCaps())
                .fontWeight(.bold)
            
            HStack {
                
                Toggle(isOn: $isHighContrast) {
                    VStack(alignment: .leading) {
                        Text("High contrast mode")
                        Text("For improved color vision")
                            .font(.caption)
                    }
                }
            }
            
            // Feedback group
            Group { 
                
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
                
                HStack {
                    VStack(alignment: .leading) {
                        if MailView.canSendMail {
                            Text("Feedback (manual)")
                        } else {
                            Text("Feedback")
                        }
                        Text("Click to copy feedback e-mail address.").font(.caption)
                    }
                    Spacer()
                    HStack {
                        if emailCopied {
                            Text("Copied")
                                .font(.caption)
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .task {
                                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                                    emailCopied = false
                                }
                        } else {
                            Button(action: {
                                UIPasteboard.general.setValue(
                                    Self.feedbackEmail,
                                    forPasteboardType: UTType.plainText.identifier)
                                
                                emailCopied = true
                            }, label: {
                                Image(systemName: "doc.on.clipboard")
                            }) 
                        }
                    }.frame(minWidth: Self.minRightWidth)
                    
                }
            }
            
            // GitHub 
            Group {
                Divider()
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
                Divider()
            }
            
            // Debug group
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
        .padding(24)
        .sheet(item: $activeSheet, onDismiss: {
            
        }, content: { item in
            switch(item) {
            case .mail: 
                MailView(data: $mailData) { _ in
                    
                }
            }
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
