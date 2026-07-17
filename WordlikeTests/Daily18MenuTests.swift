@testable import Wordlike
import XCTest

final class Daily18MenuTests: XCTestCase {
    func testOnlyLatvianModeIsListed() {
        XCTAssertEqual(Locale.supportedLocales, [.lv_LV])
    }
}
