@testable import Wordlike
import XCTest

final class AppLanguageTests: XCTestCase {
    /// The raw value is stored on disk and names the per-language saved state,
    /// so it must stay equal to the locale's file name.
    func testRawValueMatchesLocaleFileName() {
        for language in AppLanguage.allCases {
            XCTAssertEqual(language.rawValue, language.locale.fileBaseName)
        }
    }

    func testSavedStateKeyMatchesGameLocale() {
        for language in AppLanguage.allCases {
            XCTAssertEqual(
                language.turnStateKey,
                language.gameLocale(simplifiedLatvianKeyboard: false).turnStateKey
            )
        }
    }

    func testNothingChosenMeansAsk() {
        XCTAssertNil(AppLanguage.resolve(stored: "", session: nil))
    }

    func testUnknownStoredValueMeansAsk() {
        XCTAssertNil(AppLanguage.resolve(stored: "xx", session: nil))
    }

    func testStoredDefaultIsUsed() {
        XCTAssertEqual(AppLanguage.resolve(stored: "fr", session: nil), .french)
        XCTAssertEqual(AppLanguage.resolve(stored: "lv", session: nil), .latvian)
    }

    func testSessionLanguageOverridesDefault() {
        XCTAssertEqual(AppLanguage.resolve(stored: "lv", session: .french), .french)
        XCTAssertEqual(AppLanguage.resolve(stored: "", session: .american), .american)
    }

    func testStoredDefaultReadsUserDefaults() throws {
        let suite = try XCTUnwrap(UserDefaults(suiteName: "AppLanguageTests"))
        suite.removePersistentDomain(forName: "AppLanguageTests")
        XCTAssertNil(AppLanguage.storedDefault(in: suite))

        suite.set("fr", forKey: AppLanguage.defaultKey)
        XCTAssertEqual(AppLanguage.storedDefault(in: suite), .french)

        suite.set("garbage", forKey: AppLanguage.defaultKey)
        XCTAssertNil(AppLanguage.storedDefault(in: suite))
    }

    func testLatvianKeyboardSettingIsPassedThrough() {
        guard case let .lv_LV(simplified: on) = AppLanguage.latvian.gameLocale(simplifiedLatvianKeyboard: true),
              case let .lv_LV(simplified: off) = AppLanguage.latvian.gameLocale(simplifiedLatvianKeyboard: false)
        else {
            return XCTFail("Latvian must map to the Latvian game locale")
        }
        XCTAssertTrue(on)
        XCTAssertFalse(off)
    }

    /// British and American answers must differ on the same day.
    func testEnglishVariantsUseDifferentSeeds() {
        XCTAssertNotNil(AppLanguage.american.seed)
        XCTAssertNotNil(AppLanguage.british.seed)
        XCTAssertNotEqual(AppLanguage.american.seed, AppLanguage.british.seed)
        XCTAssertNil(AppLanguage.latvian.seed)
        XCTAssertNil(AppLanguage.french.seed)
    }
}
