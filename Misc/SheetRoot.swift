import SwiftUI

fileprivate struct _OptNavTitleModifier: ViewModifier {
    let title: String? 
    
    func body(content: Content) -> some View {
        if let title = title {
            content
                .navigationTitle(title)
        } else {
            content
        }
    }
}

struct SheetRoot<SheetContent: View>: View {
    let title: String?
    @Binding var isPresented: Bool
    @ViewBuilder let content: ()->SheetContent
    
    var body: some View {
        NavigationView {
            GeometryReader { gr in 
                ScrollView {
                    content()
                        .padding()
                        .frame(width: gr.size.width)      
                        .frame(minHeight: gr.size.height)
                }
                
                /* Sometimes we don't know the 
                 title initially (e.g. when
                 a single sheet can house different
                 content based on the item */
                .modifier(_OptNavTitleModifier(
                    title: title))
                
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        UIButtonClose {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}

extension View {
    func safeSheet<Content: View, Item: Identifiable>(item: Binding<Item?>, 
onDismiss: (()->())? = nil,
    @ViewBuilder _ content: @escaping (Item)->Content
    ) -> some View {
        return self.sheet(item: item, onDismiss: onDismiss) {  current in
            SheetRoot(title: nil, isPresented: Binding(get: {
                current.id == item.wrappedValue?.id
            }, set: { t in 
                item.wrappedValue = (t ? current : nil) 
            })) {
                content(current)
            }
        }
    }
    
    func safeSheet<Content: View>(
    _ title: String, isPresented: Binding<Bool>,
    @ViewBuilder _ content: @escaping ()->Content
    ) -> some View {
        return self.sheet(isPresented: isPresented) {  
            SheetRoot(title: title, isPresented: isPresented) {
                content()
            }
        }
    }
}

struct SheetRoot_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(AppView_Previews.configurations, id: \.self.id) {
            MockDevice(config: $0) {
                SheetRoot(title: "Vertical test", isPresented: .constant(true)) {
                    Text("Am I centered vertically?")
                        .frame(maxWidth: .infinity)
                        .debugBorder(.red)
                }
            }
            
            MockDevice(config: $0) {
                SheetRoot(title: "Horizontal test", isPresented: .constant(true)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Hello")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .debugBorder(.red)
                        
                        Spacer()
                        
                        Text("Bim")
                    }
                }
            }
        }
    }
}
