import XCTest
@testable import DailyOffice

final class HolyDays1943Tests: XCTestCase {
    @MainActor
    func testSeparate1943SetsAndSpecialWithoutBorrowingOtherYears() throws {
        let data = Data(#"{"name":{"zh-hant":"聖日","zh-hans":"圣日"},"vigil":{"lessons":{"1962":{"ot":{"book":"不應顯示","chapter":"1"}}}},"morning":{"lectionary_sets":{"1943":[{"id":"a","label":"組一","psalms":{"items":[{"number":"1","verses":"1-6"}]}},{"id":"b","label":"組二","lessons":{"ot":{"book":"創世記","chapter":"2"}}}]},"lessons":{"special":{"nt":{"book":"約翰福音","chapter":"3"}}}}}"#.utf8)
        let rows = try HolyDay1943Row.rows(data: data, filename: "sanctorale_0921_test", language: .simplified)
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[0].name, "圣日")
        XCTAssertEqual(rows[0].dateKey, "0921")
        XCTAssertFalse(rows[0].isSpecial)
        XCTAssertEqual(rows[0].offices.count, 2)
        XCTAssertEqual(rows[0].offices.first?.psalms?.items.first?.verses, "1-6")
        XCTAssertTrue(rows[1].isSpecial)
        XCTAssertEqual(rows[1].offices.count, 1)
        XCTAssertEqual(rows[1].offices.first?.lessons?.nt?.chapter, "3")
    }

    @MainActor
    func testActualMatthewAndNativityResources() throws {
        func rows(_ name: String) throws -> [HolyDay1943Row] {
            let url = try XCTUnwrap(Bundle.main.url(forResource: name, withExtension: "json"))
            return try HolyDay1943Row.rows(data: Data(contentsOf: url), filename: name, language: .traditional)
        }
        let matthew = try XCTUnwrap(rows("sanctorale_0921_matthew").first)
        XCTAssertFalse(matthew.isSpecial)
        XCTAssertTrue(matthew.offices.contains { $0.id.hasPrefix("vigil") })
        XCTAssertTrue(matthew.offices.contains { $0.id.hasPrefix("morning") })
        XCTAssertTrue(matthew.offices.contains { $0.id.hasPrefix("evening") })
        let mary = try XCTUnwrap(rows("sanctorale_0908_nativity_of_mary").first)
        XCTAssertTrue(mary.isSpecial)
        XCTAssertEqual(mary.offices.count, 3)
        XCTAssertEqual(mary.offices.first?.psalms?.items.first?.number, "113")
    }
}
