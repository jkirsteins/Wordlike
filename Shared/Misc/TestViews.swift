import SwiftUI

struct Test<Content: View, TestData>  : View {
    let title: String
    let prepare: TestData
    let content: (TestData)->Content
    
    init(
    _ title: String,
    _ prepare: ()->TestData,
    @ViewBuilder _ content: @escaping ((TestData)->Content)) {
        self.content = content
        self.prepare = prepare()
        self.title = title
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).fontWeight(.bold)
            content(prepare)
        }.border(.gray)
    }
}

struct TestList<Content: View>  : View {
    let title: String
    let content: Content
    
    init(_ title: String, @ViewBuilder _ content: (()->Content)) {
        self.content = content()
        self.title = title
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.largeTitle)
                
                content
            }
        }
    }
}

extension Text {
    func testColor(good: Bool) -> some View {
        self.foregroundColor(good ? .green : .red)
    }
}
