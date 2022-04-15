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
        }.padding(24)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
