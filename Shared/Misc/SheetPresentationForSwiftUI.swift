import SwiftUI

// 1 - Create a UISheetPresentationController that can be used in a SwiftUI interface
@available(iOS 15.0, *)
struct SheetPresentationForSwiftUI<Content>: UIViewRepresentable where Content: View {
    
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let detents: [UISheetPresentationController.Detent]
    let content: Content
    
    
    init(
        _ isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        detents: [UISheetPresentationController.Detent] = [.medium()],
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.detents = detents
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }
    
    class _VC<Content: View>: UIHostingController<Content> {
        let coordinator: Coordinator
        
        init(_ coordinator: Coordinator, rootView: Content) {
            self.coordinator = coordinator
            super.init(rootView: rootView)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("This class does not support NSCoder")
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            self.coordinator.dismissed()
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        /* NOTE: careful to not keep creating _VC() instances, as updateUIView can be invoked
         frequently by SwiftUI. */
        let viewController = (context.coordinator.vc as? _VC) ?? _VC(
            context.coordinator, rootView: content)
        context.coordinator.vc = viewController
        // --------
        
        // Set the presentationController as a UISheetPresentationController
        if let sheetController = viewController.presentationController as? UISheetPresentationController {
            sheetController.detents = detents
            sheetController.prefersGrabberVisible = true
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
            sheetController.largestUndimmedDetentIdentifier = .none
        }
        
        if !isPresented, let presentedVc = context.coordinator.presenterVc?.presentedViewController {
            presentedVc.dismiss(animated: true)
            return
        }
        
        /* Presenting here is a bit of a hack.
         
         Look for an already presented VC, and use that
         as the presentation base.
         
         When dismissing, look for the last VC that presents something, and assume it is us.
         */
        if isPresented {
            if context.coordinator.presenterVc == nil && !viewController.isBeingDismissed {
                if let alreadyPresentedByRoot = uiView.window?.rootViewController?.presentedViewController {
                    context.coordinator.presenterVc = alreadyPresentedByRoot
                } else {
                    // Present the viewController
                    context.coordinator.presenterVc = uiView.window?.rootViewController
                }
                
                context.coordinator.presenterVc?.present(viewController, animated: true)
            }
        } else {
            if let presentedVc = context.coordinator.presenterVc?.presentedViewController {
                presentedVc.dismiss(animated: true)
            }
        }
    }
    
    /* Creates the custom instance that you use to communicate changes
     from your view controller to other parts of your SwiftUI interface.
     */
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, onDismiss: onDismiss)
    }
    
    class Coordinator: NSObject, UIViewControllerTransitioningDelegate {
        @Binding var isPresented: Bool
        let onDismiss: (() -> Void)?
        
        /// Which VC is presenting the sheet
        var presenterVc: UIViewController? = nil
        
        weak var vc: AnyObject? = nil
        
        init(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) {
            self._isPresented = isPresented
            self.onDismiss = onDismiss
        }
        
        /// This is called by the ViewController when its view is unloaded.
        /// Alternatively, you might want to use `animationController(forDismissed dismissed: UIViewController)` but this appears to be less reliable (rarely not called on real devices)
        func dismissed() {
            isPresented = false
            presenterVc = nil
            onDismiss?()
        }
    }
}

// 2 - Create the SwiftUI modifier conforming to the ViewModifier protocol
@available(iOS 15.0, *)
struct sheetWithDetentsViewModifier<SwiftUIContent>: ViewModifier where SwiftUIContent: View {
    
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let detents: [UISheetPresentationController.Detent]
    let swiftUIContent: SwiftUIContent
    
    init(isPresented: Binding<Bool>, detents: [UISheetPresentationController.Detent] = [.medium()] , onDismiss: (() -> Void)? = nil, content: () -> SwiftUIContent) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.swiftUIContent = content()
        self.detents = detents
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            SheetPresentationForSwiftUI($isPresented, onDismiss: onDismiss, detents: detents) {
                swiftUIContent
            }.allowsHitTesting(false)
        }
    }
}

// 3 - Create extension on View that makes it easier to use the custom modifier
extension View {
    
    @available(iOS 15.0, *)
    func sheetWithDetents<Content>(
        isPresented: Binding<Bool>,
        detents: [UISheetPresentationController.Detent],
        onDismiss: (() -> Void)?,
        content: @escaping () -> Content) -> some View where Content : View {
            modifier(
                sheetWithDetentsViewModifier(
                    isPresented: isPresented,
                    detents: detents,
                    onDismiss: onDismiss,
                    content: content)
            )
        }
}

