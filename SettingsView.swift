import SwiftUI

struct SettingsView: View {
    
    static let HIGH_CONTRAST_KEY = "cfg.isHighContrast"
    
    @AppStorage(SettingsView.HIGH_CONTRAST_KEY) 
    var isHighContrast: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
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
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Reset state").font(.body)
                    Text("Clear all historical stats and today's progress").font(.caption)
                }
                Spacer()
                Button("Reset") {
                    if let bundleID = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: bundleID)
                    }
                }
            }
            
            Divider()
        }.padding(24)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
