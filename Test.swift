import SwiftUI

struct TestView: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.green)
            Text("Hello")
                .font(.system(size: 100))
                .scaledToFit()
                .minimumScaleFactor(0.01)
                .lineLimit(1)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 250)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
