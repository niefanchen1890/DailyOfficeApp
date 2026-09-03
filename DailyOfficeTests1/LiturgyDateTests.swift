import XCTest
@testable import DailyOffice

final class LiturgyDateTests: XCTestCase {
    private let service = LiturgyCoreService()

    func testFixedFeasts() {
        assertLiturgy(
            on: date(2025, 1, 1),
            title: "救主受割禮日",
            season: .christmas,
            color: "white"
        )
        assertLiturgy(
            on: date(2025, 1, 6),
            title: "顯現日",
            season: .epiphany,
            color: "white"
        )
        assertLiturgy(
            on: date(2025, 12, 25),
            title: "聖誕日",
            season: .christmas,
            color: "white"
        )
    }

    func testEasterDatesAcrossMultipleYears() {
        let cases = [
            (2024, 3, 31),
            (2025, 4, 20),
            (2026, 4, 5)
        ]

        for (year, month, day) in cases {
            assertLiturgy(
                on: date(year, month, day),
                title: "復活日",
                season: .easter,
                color: "white"
            )
        }
    }

    func testAshWednesdayDatesAcrossMultipleYears() {
        let cases = [
            (2024, 2, 14),
            (2025, 3, 5),
            (2026, 2, 18)
        ]

        for (year, month, day) in cases {
            assertLiturgy(
                on: date(year, month, day),
                title: "大齋首日 (聖灰禮拜三)",
                season: .lent,
                color: "purple"
            )
        }
    }

    func testAscensionDatesAcrossMultipleYears() {
        let cases = [
            (2024, 5, 9),
            (2025, 5, 29),
            (2026, 5, 14)
        ]

        for (year, month, day) in cases {
            assertLiturgy(
                on: date(year, month, day),
                title: "救主升天日",
                season: .ascension,
                color: "white"
            )
        }
    }

    func testPentecostDatesAcrossMultipleYears() {
        let cases = [
            (2024, 5, 19),
            (2025, 6, 8),
            (2026, 5, 24)
        ]

        for (year, month, day) in cases {
            assertLiturgy(
                on: date(year, month, day),
                title: "聖靈降臨日",
                season: .pentecost,
                color: "red"
            )
        }
    }

    func testTrinitySundayDatesAcrossMultipleYears() {
        let cases = [
            (2024, 5, 26),
            (2025, 6, 15),
            (2026, 5, 31)
        ]

        for (year, month, day) in cases {
            assertLiturgy(
                on: date(year, month, day),
                title: "三一主日",
                season: .trinity,
                color: "white"
            )
        }
    }

    func testFirstSundayOfAdventDatesAcrossMultipleYears() {
        let cases = [
            (2024, 12, 1),
            (2025, 11, 30),
            (2026, 11, 29)
        ]

        for (year, month, day) in cases {
            assertLiturgy(
                on: date(year, month, day),
                title: "降臨第一主日",
                season: .advent,
                color: "purple"
            )
        }
    }

    private func assertLiturgy(
        on date: Date,
        title: String,
        season: LiturgicalSeason,
        color: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let result = service.resolve(for: date)
        let readableDate = Self.dateFormatter.string(from: date)

        XCTAssertEqual(
            result.mainTitle,
            title,
            "\(readableDate) 的禮儀名稱不正確",
            file: file,
            line: line
        )
        XCTAssertEqual(
            result.season,
            season,
            "\(readableDate) 的禮儀季節不正確",
            file: file,
            line: line
        )
        XCTAssertEqual(
            result.color,
            color,
            "\(readableDate) 的禮儀顏色不正確",
            file: file,
            line: line
        )
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar.date(
            from: DateComponents(year: year, month: month, day: day, hour: 12)
        )!
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_Hant")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
