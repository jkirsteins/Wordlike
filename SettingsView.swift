import SwiftUI

struct SettingsView: View {
    
    static let HIGH_CONTRAST_KEY = "cfg.isHighContrast"
    
    @AppStorage(SettingsView.HIGH_CONTRAST_KEY) 
    var isHighContrast: Bool = false
    
    @AppStorage("turnState.en")
    var dailyStateEn: DailyState?
    
    @AppStorage("turnState.fr")
    var dailyStateFr: DailyState?
    
    @AppStorage("turnState.lv")
    var dailyStateLv: DailyState?
    
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
        }.padding(24)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
