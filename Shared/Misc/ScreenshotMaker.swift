import SwiftUI

#if os(iOS)
typealias ScreenshotMakerClosure = (ScreenshotMaker) -> Void

class ScreenshotMaker: UIView {
    /// Takes the screenshot of the superview of this superview
    /// - Returns: The UIImage with the screenshot of the view
    func screenshot(scale: Double) -> UIImage? {
        guard let containerView = superview?.superview,
              let containerSuperview = containerView.superview
        else { return nil }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale

        let renderer = UIGraphicsImageRenderer(
            bounds: containerView.frame,
            format: format
        )

        return renderer.image { context in
            containerSuperview.layer.render(in: context.cgContext)
        }
    }
}

struct ScreenshotMakerView: UIViewRepresentable {
    let closure: ScreenshotMakerClosure

    init(_ closure: @escaping ScreenshotMakerClosure) {
        self.closure = closure
    }

    func makeUIView(context: Context) -> ScreenshotMaker {
        return ScreenshotMaker(frame: CGRect.zero)
    }

    func updateUIView(_ uiView: ScreenshotMaker, context: Context) {
        DispatchQueue.main.async {
            closure(uiView)
        }
    }
}
#endif
