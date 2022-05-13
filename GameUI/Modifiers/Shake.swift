import SwiftUI

/// See: https://www.objc.io/blog/2019/10/01/swiftui-shake-animation/
struct Shake: GeometryEffect {
    var amount: CGFloat = 4
    var shakesPerUnit = 6
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX:
                                                        amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                                                     y: 0))
    }
}
