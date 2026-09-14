import XCTest
@testable import DailyOffice

final class LiturgyDateTests: XCTestCase {
    @MainActor
    func testEpiphanyVigilSundayAndWeekdayEvenings() {
        for year in 2025...2035 {
            let morning = service.resolve(for: date(year, 1, 5))
            let eve = service.resolve(for: date(year, 1, 4), isEvening: true)
            if Calendar(identifier: .gregorian).component(.weekday, from: date(year, 1, 5)) == 1 {
                XCTAssertEqual(morning.identifier, .sundayAfterChristmas)
                XCTAssertEqual(eve.identifier, .sundayAfterChristmas)
                XCTAssertFalse(morning.commemorationItems.contains { $0.identifier == .epiphanyVigil })
                XCTAssertFalse(eve.commemorationItems.contains { $0.identifier == .epiphanyVigil })
            } else {
                XCTAssertEqual(morning.identifier, .epiphanyVigil)
                XCTAssertEqual(eve.identifier, .epiphanyVigil)
                XCTAssertTrue(eve.isFirstVespers)
            }
            XCTAssertEqual(service.resolve(for: date(year, 1, 5), isEvening: true).identifier, .epiphany)
        }
    }

    @MainActor
    func testJanuarySimpleOctavesKeepSimplePriority() throws {
        for day in [2, 3, 4] {
            let feast = try XCTUnwrap(Sanctorale.shared.getFeast(for: date(2026, 1, day)))
            XCTAssertEqual(feast.rank, .simple)
            XCTAssertEqual(feast.rank.rawValue, 50)
            XCTAssertEqual(feast.rankName, "簡式八日慶期，簡式")
        }
        XCTAssertEqual(Sanctorale.shared.getFeast(for: date(2026, 1, 22))?.rank, .semiDouble)
        XCTAssertEqual(Sanctorale.shared.getFeast(for: date(2026, 1, 28))?.identifier, .anglicanEpiscopate)
    }

    @MainActor
    func testThomasTransfersFromSundayToMondayWithFirstVespers() throws {
        let calendar = Calendar(identifier: .gregorian)
        for year in 2025...2045 {
            let originalDate = try XCTUnwrap(calendar.date(from: DateComponents(year: year, month: 12, day: 21, hour: 12)))
            let nextDate = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: originalDate))
            let original = service.resolve(for: originalDate)
            if calendar.component(.weekday, from: originalDate) == 1 {
                XCTAssertNotEqual(original.identifier, .stThomas, "\(year)")
                XCTAssertFalse(original.commemorationItems.contains { $0.identifier == .stThomas })
                XCTAssertTrue(original.transferred.contains("使徒聖多馬日"))
                let transferred = service.resolve(for: nextDate)
                XCTAssertEqual(transferred.identifier, .stThomas)
                XCTAssertEqual(transferred.rank, .doubleSecondClass)
                XCTAssertTrue(transferred.commemorationItems.contains { $0.identifier.temporalComponents?.season == .advent })
                XCTAssertEqual(LiturgicalResourceResolver.shared.officeFileName(for: transferred.identifier), "sanctorale_1221_thomas")
                let evening = service.resolve(for: originalDate, isEvening: true)
                XCTAssertEqual(evening.identifier, .stThomas)
                XCTAssertTrue(evening.isFirstVespers)
                let previousDate = try XCTUnwrap(calendar.date(byAdding: .day, value: -1, to: originalDate))
                XCTAssertNotEqual(service.resolve(for: previousDate, isEvening: true).identifier, .stThomas)
            } else {
                XCTAssertEqual(original.identifier, .stThomas, "\(year)")
                XCTAssertFalse(Sanctorale.shared.getFeasts(for: nextDate).contains { $0.identifier == .stThomas })
            }
        }
    }

    @MainActor
    func testAdventAntiphonDateBoundariesAndThomasException() throws {
        let rules = AdventAntiphonResolver(
            evening: Dictionary(uniqueKeysWithValues: (16...23).map { ("12\($0)", "O-\($0)") }),
            thomasMorningCommemoration: ["1221": "正日", "1222": "遷移日"]
        )
        let calendar = Calendar(identifier: .gregorian)
        let advent = LiturgicalID.temporal(season: .advent, week: 4, weekday: 2)
        for day in 15...24 {
            let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 12, day: day, hour: 12)))
            let expected = (16...23).contains(day) ? "O-\(day)" : nil
            XCTAssertEqual(rules.override(for: date, isEvening: true, celebration: advent), expected)
            XCTAssertNil(rules.override(for: date, isEvening: true, celebration: .stThomas))
            XCTAssertNil(rules.override(for: date, isEvening: false, celebration: advent))
            XCTAssertEqual(rules.override(for: date, isEvening: true, celebration: .stThomas, commemorated: advent), expected)
            XCTAssertNil(rules.override(for: date, isEvening: true, celebration: advent, commemorated: .stThomas))
            XCTAssertEqual(rules.override(for: date, isEvening: false, celebration: .stThomas, commemorated: advent),
                           day == 21 ? "正日" : (day == 22 ? "遷移日" : nil))
        }
        // 前夕仍使用民用當日的 12/20，而不是慶節的 12/21。
        let eve = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 12, day: 20, hour: 18)))
        XCTAssertEqual(rules.override(for: eve, isEvening: true, celebration: .stThomas, commemorated: advent), "O-20")
    }

    @MainActor
    func testNovemberDecemberFeastRanksAndDistinctSylvesters() throws {
        let calendar = Calendar(identifier: .gregorian)
        let cases: [(Int, Int, LiturgicalID, LiturgicalRank, String)] = [
            (11, 8, .anglicanSaints, .greaterDouble, "sanctorale_1108_saints_of_anglican_communion"),
            (12, 29, .stThomasBecket, .double, "sanctorale_1229_thomas_becket"),
            (11, 26, .stSylvesterAbbot, .double, "sanctorale_1126_sylvester_abbot"),
            (12, 31, .stSylvester, .double, "sanctorale_1231_sylvester")
        ]
        for (month, day, identifier, rank, filename) in cases {
            let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: 12)))
            let feast = try XCTUnwrap(Sanctorale.shared.getFeasts(for: date).first { $0.identifier == identifier })
            XCTAssertEqual(feast.rank, rank)
            XCTAssertEqual(LiturgicalResourceResolver.shared.officeFileName(for: identifier), filename)
        }
        XCTAssertNotEqual(LiturgicalID.stSylvesterAbbot, .stSylvester)
    }

    @MainActor
    func testTrinitySundayProperSupplementAndOmission() throws {
        let resolver = LiturgicalResourceResolver.shared
        let calculator = LiturgicalDateCalculator()
        let calendar = Calendar(identifier: .gregorian)
        // 包含降臨前主日的主日總數：22、23、24、25、26、27。
        for (year, total) in [(2038, 22), (2025, 23), (2020, 24), (2026, 25), (2024, 26), (2035, 27)] {
            let trinity = calculator.trinitySunday(in: year)
            for week in 1...total {
                let sunday = try XCTUnwrap(calendar.date(byAdding: .day, value: week * 7, to: trinity))
                let expected: String?
                if week == total { expected = "sunday_next_before_advent" }
                else if total == 26 && week == 25 { expected = "temporal_epiphany_6_sunday" }
                else if total == 27 && week == 25 { expected = "temporal_epiphany_5_sunday" }
                else if total == 27 && week == 26 { expected = "temporal_epiphany_6_sunday" }
                else { expected = nil }
                XCTAssertEqual(resolver.trinitySundayReplacementFile(for: sunday), expected, "\(year) week \(week)")
                let monday = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: sunday))
                XCTAssertNil(resolver.trinitySundayReplacementFile(for: monday))
            }
            XCTAssertNil(resolver.trinitySundayReplacementFile(for: trinity))
            XCTAssertNil(resolver.trinitySundayReplacementFile(for: calculator.firstSundayOfAdvent(in: year)))
            let lastSunday = try XCTUnwrap(calendar.date(byAdding: .day, value: total * 7, to: trinity))
            let liturgy = LiturgyCoreService.shared.resolve(for: lastSunday)
            XCTAssertEqual(liturgy.identifier, .sundayBeforeAdvent)
            XCTAssertEqual(liturgy.season, .trinity)
            let file = try XCTUnwrap(DailyOfficeLoader.shared.loadOfficeFile(for: lastSunday, liturgy: liturgy))
            XCTAssertEqual(file.identifier, LiturgicalID.sundayBeforeAdvent.rawValue)
            XCTAssertNotNil(file.morning?.collect)
        }
        // 第一晚禱以翌日的有效日期選取，最後主日的專用內容不可回落到週次檔。
        let saturday = date(2026, 11, 21)
        let evening = LiturgyCoreService.shared.resolve(for: saturday, isEvening: true)
        XCTAssertTrue(evening.isFirstVespers)
        XCTAssertEqual(evening.identifier, .sundayBeforeAdvent)
        let sunday = date(2026, 11, 22)
        let file = try XCTUnwrap(DailyOfficeLoader.shared.loadOfficeFile(for: sunday, liturgy: evening))
        XCTAssertEqual(file.identifier, LiturgicalID.sundayBeforeAdvent.rawValue)
        let memorial = try XCTUnwrap(DailyOfficeLoader.shared.loadCommemoration(name: "降臨前主日", date: sunday))
        XCTAssertEqual(memorial.identifier, LiturgicalID.sundayBeforeAdvent.rawValue)
    }

    @MainActor
    func testFortnightlyBAllHoursAndPrimeSegments() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "psalm_cycle_fortnightly_b", withExtension: "json"))
        let table = try JSONDecoder().decode([String: [String: [String: [String]]]].self, from: Data(contentsOf: url))
        let hours = ["morning", "prime", "terce", "sext", "nona", "evening", "compline"]
        XCTAssertEqual(Set(table.keys), Set(hours))
        XCTAssertEqual(table["prime"]?["week_1"]?["0"], ["119_1_8", "119_9_16"])
        XCTAssertEqual(table["prime"]?["week_2"]?["6"], ["119_161_168", "119_169_176"])
        XCTAssertEqual(table["sext"]?["week_2"]?["5"], ["122", "123"])
        XCTAssertEqual(table["compline"]?["week_1"]?["3"], ["11", "12"])
        let original = AppLanguageStore.shared.language
        let prefKey = OfficePrefs.Key.psalmLectionary
        let saved = UserDefaults.standard.object(forKey: prefKey)
        defer {
            AppLanguageStore.shared.setLanguage(original)
            if let saved { UserDefaults.standard.set(saved, forKey: prefKey) }
            else { UserDefaults.standard.removeObject(forKey: prefKey) }
        }
        let calendar = Calendar(identifier: .gregorian)
        // 1 月 11 日為第三週主日：week_1；1 月 18 日為第四週：week_2。
        for language in [AppLanguage.traditional, .simplified] {
            AppLanguageStore.shared.setLanguage(language)
            for week in 1...2 {
                for weekday in 0...6 {
                    let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 11 + (week - 1) * 7 + weekday, hour: 12)))
                    for hour in hours {
                        let expected = try XCTUnwrap(table[hour]?["week_\(week)"]?[String(weekday)])
                        XCTAssertFalse(expected.isEmpty)
                        XCTAssertEqual(PsalmsLoader.shared.fortnightlyBKeys(for: date, hour: hour), expected)
                        let psalms = PsalmsLoader.shared.fortnightlyBPsalms(for: date, hour: hour)
                        XCTAssertEqual(psalms.count, expected.count)
                        XCTAssertEqual(psalms.map { $0.content.verses }, expected.compactMap { PsalmsLoader.shared.psalmContent(for: $0)?.verses })
                        for psalm in psalms {
                            XCTAssertFalse(psalm.content.verses.isEmpty)
                            XCTAssertTrue(psalm.content.verses.allSatisfy { !$0.isEmpty })
                            if hour == "prime" { XCTAssertEqual(psalm.content.verses.count, 8) }
                        }
                    }
                }
            }
        }
        let morning = MorningPrayerViewModel()
        let evening = EveningPrayerViewModel()
        let saturday = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 1, day: 17, hour: 12)))
        morning.selectedDate = saturday
        evening.selectedDate = saturday
        morning.selectedPsalmLectionary = FortnightlyPsalmCycle.optionB
        evening.selectedPsalmLectionary = FortnightlyPsalmCycle.optionB
        morning.loadReadings()
        evening.loadReadings()
        XCTAssertEqual(morning.selectedPsalmLectionary, FortnightlyPsalmCycle.optionB)
        XCTAssertEqual(evening.selectedPsalmLectionary, FortnightlyPsalmCycle.optionB)
        XCTAssertEqual(morning.morningPsalms.map { $0.content.verses }, ["37", "38"].compactMap { PsalmsLoader.shared.psalmContent(for: $0)?.verses })
        XCTAssertEqual(evening.eveningPsalms.map { $0.content.verses }, ["88", "89"].compactMap { PsalmsLoader.shared.psalmContent(for: $0)?.verses })
    }

    @MainActor
    func testFortnightlyPsalmCycleAnnualWeeksAndOfficeSelection() throws {
        let zone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        for (year, month, day, week, weekday) in [
            (2026, 1, 1, 1, 4), (2026, 1, 3, 1, 6),
            (2026, 1, 4, 2, 0), (2026, 1, 10, 2, 6),
            (2026, 1, 11, 1, 0), (2026, 12, 31, 1, 4),
            (2027, 1, 1, 1, 5), (2027, 1, 3, 2, 0),
            (2024, 2, 29, 1, 4)
        ] {
            let date = try XCTUnwrap(calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12)))
            let position = FortnightlyPsalmCycle.position(for: date, timeZone: zone)
            XCTAssertEqual(position.week, week, "\(year)-\(month)-\(day)")
            XCTAssertEqual(position.weekday, weekday)
        }

        let key = OfficePrefs.Key.psalmLectionary
        let savedOption = UserDefaults.standard.object(forKey: key)
        defer {
            if let savedOption { UserDefaults.standard.set(savedOption, forKey: key) }
            else { UserDefaults.standard.removeObject(forKey: key) }
        }
        let morning = MorningPrayerViewModel()
        let evening = EveningPrayerViewModel()
        morning.selectedPsalmLectionary = FortnightlyPsalmCycle.option
        evening.selectedPsalmLectionary = FortnightlyPsalmCycle.option
        // 使用本地日期，驗證換日載入不會將循環選項重設為月度循環。
        let localCalendar = Calendar(identifier: .gregorian)
        for (day, morningKeys, eveningKeys) in [
            (3, ["30", "32", "31", "33", "34"], ["101", "103", "102", "105"]),
            (4, ["98", "148", "99", "149", "100", "150"], ["110", "113", "111", "114", "112", "115"]),
            (11, ["63", "93", "66", "96", "67", "97"], ["84", "104", "85", "119_49_56", "119_57_64", "119_65_72", "119_73_80"])
        ] {
            let date = try XCTUnwrap(localCalendar.date(from: DateComponents(year: 2026, month: 1, day: day, hour: 12)))
            morning.selectedDate = date
            evening.selectedDate = date
            morning.loadReadings()
            evening.loadReadings()
            XCTAssertEqual(morning.selectedPsalmLectionary, FortnightlyPsalmCycle.option)
            XCTAssertEqual(evening.selectedPsalmLectionary, FortnightlyPsalmCycle.option)
            XCTAssertEqual(morning.morningPsalms.map { $0.content.verses }, morningKeys.compactMap { PsalmsLoader.shared.psalmContent(for: $0)?.verses })
            XCTAssertEqual(evening.eveningPsalms.map { $0.content.verses }, eveningKeys.compactMap { PsalmsLoader.shared.psalmContent(for: $0)?.verses })
        }
        XCTAssertEqual(OfficePrefs.restoreString(key, default: "monthly"), FortnightlyPsalmCycle.option)
    }

    @MainActor
    func testFortnightlyPsalmCycleOneResourceAndSegments() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "psalm_cycle_fortnightly_1", withExtension: "json"))
        let cycle = try JSONDecoder().decode(FortnightlyPsalmCycle.self, from: Data(contentsOf: url))
        XCTAssertEqual(cycle.keys(week: 1, weekday: 0, isMorning: true), ["63", "93", "66", "96", "67", "97"])
        XCTAssertEqual(cycle.keys(week: 2, weekday: 6, isMorning: false), ["144", "146", "145", "147"])
        XCTAssertTrue(cycle.keys(week: 3, weekday: 0, isMorning: true).isEmpty)
        XCTAssertTrue(cycle.keys(week: 1, weekday: 7, isMorning: true).isEmpty)
        let originalLanguage = AppLanguageStore.shared.language
        defer { AppLanguageStore.shared.setLanguage(originalLanguage) }
        for language in [AppLanguage.traditional, .simplified] {
            AppLanguageStore.shared.setLanguage(language)
            for week in 1...2 {
                for weekday in 0...6 {
                    for isMorning in [true, false] {
                        let keys = cycle.keys(week: week, weekday: weekday, isMorning: isMorning)
                        XCTAssertFalse(keys.isEmpty)
                        let psalms = PsalmsLoader.shared.fortnightlyPsalms(week: week, weekday: weekday, isMorning: isMorning)
                        XCTAssertEqual(psalms.count, keys.count)
                        for (key, psalm) in zip(keys, psalms) {
                            XCTAssertFalse(psalm.content.verses.isEmpty, key)
                            XCTAssertTrue(psalm.content.verses.allSatisfy { !$0.isEmpty }, key)
                            let parts = key.split(separator: "_")
                            if parts.count == 3 {
                                XCTAssertEqual(psalm.content.verses.count, 8, key)
                                XCTAssertTrue(psalm.content.verses.first?.hasPrefix("\(parts[1]) ") == true, key)
                                XCTAssertTrue(psalm.content.verses.last?.hasPrefix("\(parts[2]) ") == true, key)
                            }
                        }
                    }
                }
            }
        }
    }

    @MainActor
    func test1943PsalmAntiphonSelection() throws {
        let json = #"{"identifier":"test","name":"test","morning":{"psalm_antiphons":{"antiphons":["ordinary"],"lectionary_1943":["even year","odd year"]}},"vigil":{"psalm_antiphons":{"lectionary_1943":"vigil"}},"evening":{"psalm_antiphons":{"lectionary_1943":"evening"}}}"#
        let office = try JSONDecoder().decode(DailyOfficeFile.self, from: Data(json.utf8))
        let calendar = Calendar(identifier: .gregorian)
        for year in [2026, 2027, 2028] {
            let date = try XCTUnwrap(calendar.date(from: DateComponents(year: year, month: 9, day: 8, hour: 12)))
            XCTAssertEqual(DailyOfficeLoader.lectionary1943PsalmAntiphon(in: office, for: date), year == 2027 ? "odd year" : "even year")
            XCTAssertEqual(DailyOfficeLoader.lectionary1943PsalmAntiphon(in: office, for: date, isEvening: true), "evening")
            XCTAssertEqual(DailyOfficeLoader.lectionary1943PsalmAntiphon(in: office, for: date, isEvening: true, isFirstVespers: true), "vigil")
            XCTAssertEqual(DailyOfficeLoader.lectionary1943PsalmAntiphon(in: office, for: date, isFirstVespers: true), year == 2027 ? "odd year" : "even year")
        }
    }

    @MainActor
    func test1943PsalmAntiphonMissingAndEmptyNeverUseOrdinaryAntiphons() throws {
        for extra in ["", #", "lectionary_1943": []"#, #", "lectionary_1943": "  ""#] {
            let json = """
            {"identifier":"test","name":"test","morning":{"psalm_antiphons":{"antiphons":["ordinary"],"common":"common"\(extra)}},"evening":{"psalm_antiphons":{"lectionary_1943":"evening"}}}
            """
            let office = try JSONDecoder().decode(DailyOfficeFile.self, from: Data(json.utf8))
            XCTAssertNil(DailyOfficeLoader.lectionary1943PsalmAntiphon(in: office, for: Date()))
            XCTAssertEqual(DailyOfficeLoader.lectionary1943PsalmAntiphon(in: office, for: Date(), isEvening: true, isFirstVespers: true), "evening")
        }
    }

    @MainActor
    func testCommonOfficeRemigiusAndSeptemberCompatibility() throws {
        func resource(_ name: String) throws -> Data {
            try Data(contentsOf: XCTUnwrap(Bundle.main.url(forResource: name, withExtension: "json")))
        }
        let index = try JSONDecoder().decode([String: String].self, from: resource("common_office_index"))
        XCTAssertEqual(index.count, 19)
        for (id, name) in index {
            let object = try XCTUnwrap(JSONSerialization.jsonObject(with: resource(name)) as? [String: Any])
            XCTAssertEqual(object["identifier"] as? String, id)
        }
        let raw = try resource("sanctorale_1001_remigius")
        let merged = try CommonOfficeResolver.resolve(data: raw) { try CommonOfficeResolver.loadCommon(id: $0) }
        for language in [AppLanguage.traditional, .simplified] {
            let data = try XCTUnwrap(LocalizedJSONResolver.resolve(data: merged, language: language))
            let file = try JSONDecoder().decode(DailyOfficeFile.self, from: data)
            XCTAssertEqual(file.identifier, "sanctorale_1001_remigius")
            for period in [file.vigil, file.morning, file.evening] {
                XCTAssertEqual(period?.collect?.options.count, 2)
                XCTAssertFalse(try XCTUnwrap(period?.psalmAntiphons?.lectionary1943?.values).isEmpty)
            }
        }
        let september = try XCTUnwrap(Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil))
            .filter { $0.lastPathComponent.hasPrefix("sanctorale_09") }
        XCTAssertGreaterThan(september.count, 20)
        for url in september {
            let original = try Data(contentsOf: url)
            let result = try CommonOfficeResolver.resolve(data: original) { _ in
                XCTFail("舊模式不應讀取通用")
                return Data()
            }
            XCTAssertEqual(result, original)
        }
        let date = try XCTUnwrap(Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 12)))
        let loaded = DailyOfficeLoader.shared.loadCommemoration(name: "聖雷米吉烏斯主教", date: date)
        XCTAssertEqual(loaded?.morning?.collect?.options.count, 2)
        XCTAssertNotNil(loaded?.morning?.psalmAntiphons)
    }

    @MainActor
    func testCommonOfficeMergeAndFailures() throws {
        let base = Data(#"{"identifier":"c","type":"common_office","common_metadata":{"schema_version":1},"morning":{"psalm_antiphons":{"antiphons":["A","B"],"lectionary_1943":"C"},"office_hymn":{"title":"old","verses":["old"]},"invitatory":{"text":{"zh-hant":"通用","zh-hans":"通用简体"}}},"vigil":{},"evening":{}}"#.utf8)
        let proper = Data(#"{"identifier":"p","name":"p","common_office":"c","vigil":null,"morning":{"psalm_antiphons":{"antiphons":[],"lectionary_1943":null},"office_hymn":{"verses":["new"]},"invitatory":{"text":{"zh-hant":"專用"}}}}"#.utf8)
        let merged = try CommonOfficeResolver.resolve(data: proper) { _ in base }
        let localized = try XCTUnwrap(LocalizedJSONResolver.resolve(data: merged, language: .simplified))
        let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
        XCTAssertNil(file.firstVespersPeriod)
        XCTAssertNotNil(file.evening)
        XCTAssertEqual(file.morning?.psalmAntiphons?.antiphons, [])
        XCTAssertNil(file.morning?.psalmAntiphons?.lectionary1943)
        XCTAssertNil(file.morning?.officeHymn?.title)
        XCTAssertEqual(file.morning?.invitatory?.text, "專用")
        XCTAssertThrowsError(try CommonOfficeResolver.resolve(data: proper) { _ in Data("{}".utf8) })
        XCTAssertThrowsError(try CommonOfficeResolver.loadCommon(id: "missing"))
        let required = Data(#"{"identifier":"c","type":"common_office","common_metadata":{"schema_version":1,"requires_proper_collect":true},"morning":{}}"#.utf8)
        XCTAssertThrowsError(try CommonOfficeResolver.resolve(data: proper) { _ in required })
    }

    @MainActor
    func testRosaryAndSimeonAnnaMemorial() throws {
        let calendar = Calendar(identifier: .gregorian)
        let eve = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 10, day: 6, hour: 12)))
        let day = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 10, day: 7, hour: 12)))
        let core = LiturgyCoreService()
        let first = core.resolve(for: eve, isEvening: true)
        XCTAssertEqual(first.identifier, .ourLadyOfTheRosary)
        XCTAssertTrue(first.isFirstVespers)
        let ids = first.commemorationItems.map(\.identifier)
        let bruno = try XCTUnwrap(ids.firstIndex(of: .bruno))
        let simeon = try XCTUnwrap(ids.firstIndex(of: .simeonAndAnna))
        XCTAssertLessThan(bruno, simeon)
        XCTAssertEqual(ids.filter { $0 == .simeonAndAnna }.count, 1)
        let morning = core.resolve(for: day, isEvening: false)
        XCTAssertEqual(morning.identifier, .ourLadyOfTheRosary)
        XCTAssertTrue(morning.commemorationItems.contains { $0.identifier == .simeonAndAnna })
        XCTAssertFalse(core.resolve(for: day, isEvening: true).commemorationItems.contains { $0.identifier == .simeonAndAnna })
        XCTAssertFalse(core.resolve(for: eve, isEvening: false).commemorationItems.contains { $0.identifier == .simeonAndAnna })
        for language in [AppLanguage.traditional, .simplified] {
            for name in ["sanctorale_1007_our_lady_of_the_rosary", "sanctorale_1007_simeon_and_anna"] {
                let url = try XCTUnwrap(Bundle.main.url(forResource: name, withExtension: "json"))
                let raw = try Data(contentsOf: url)
                let data = try XCTUnwrap(LocalizedJSONResolver.resolve(data: raw, language: language))
                let file = try JSONDecoder().decode(DailyOfficeFile.self, from: data)
                XCTAssertNotNil(file.vigil?.collect)
                XCTAssertNotNil(file.morning?.collect)
                if name.contains("rosary") {
                    for h in [file.vigil, file.morning, file.evening] {
                        XCTAssertEqual(h?.officeHymn?.verses?.count, 6)
                        XCTAssertTrue(h?.officeHymn?.verses?.first?.hasPrefix("一、") == true)
                        XCTAssertEqual(h?.psalmAntiphons?.antiphons?.count, 5)
                        XCTAssertNotNil(h?.psalmAntiphons?.lectionary1943)
                        XCTAssertNotNil(h?.nuncDimittisAntiphon)
                    }
                    XCTAssertEqual(file.morning?.invitatoryHymn?.verses?.count, 6)
                } else {
                    XCTAssertEqual(file.identifier, "sts_simeon_anna")
                    XCTAssertNotNil(file.morning?.officeHymn?.versicle)
                    XCTAssertNil(file.evening)
                }
            }
        }
        let memorial = DailyOfficeLoader.shared.loadCommemoration(name: "聖西面與聖亞拿", date: day)
        XCTAssertEqual(memorial?.identifier, "sts_simeon_anna")
    }

    @MainActor
    func testEvangelist1943SeasonalAntiphons() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "傳福音者用（復活期外）", withExtension: "json"))
        let raw = try Data(contentsOf: url)
        let calendar = Calendar(identifier: .gregorian)
        let easter = LiturgicalDateCalculator().easterSunday(in: 2026)
        for language in [AppLanguage.traditional, .simplified] {
            let data = try XCTUnwrap(LocalizedJSONResolver.resolve(data: raw, language: language))
            let office = try JSONDecoder().decode(DailyOfficeFile.self, from: data)
            let redecoded = try JSONDecoder().decode(DailyOfficeFile.self, from: JSONEncoder().encode(office))
            XCTAssertEqual(redecoded.morning?.psalmAntiphons?.lectionary1943?.septuagesimaToLent,
                           office.morning?.psalmAntiphons?.lectionary1943?.septuagesimaToLent)
            for offset in [-64, -63, -47, -46, -7, -1, 0, 1] {
                let date = try XCTUnwrap(calendar.date(byAdding: .day, value: offset, to: easter))
                let special = offset >= -63 && offset < 0
                for evening in [false, true] {
                    let result = try XCTUnwrap(DailyOfficeLoader.lectionary1943PsalmAntiphon(
                        in: office, for: date, isEvening: evening, isFirstVespers: evening))
                    XCTAssertEqual(result.hasPrefix("主如是"), special, "offset=\(offset)")
                    XCTAssertEqual(result.contains(language == .traditional ? "哈利路亞" : "哈利路亚"), !special)
                }
                let evening = DailyOfficeLoader.lectionary1943PsalmAntiphon(in: office, for: date, isEvening: true)
                XCTAssertEqual(evening, office.evening?.psalmAntiphons?.lectionary1943?.values.first)
            }
        }
    }

    private let service = LiturgyCoreService()
    private let dateCalculator = LiturgicalDateCalculator()

    @MainActor
    func testOfficeForTheDeadLoadsInTraditionalAndSimplifiedChinese() {
        for language in [AppLanguage.traditional, .simplified] {
            DeadOfficeDataLoader.shared.clearCache()
            let data = DeadOfficeDataLoader.shared.load(language: language)

            XCTAssertEqual(data.identifier, "office_for_the_dead")
            XCTAssertFalse(data.title.isEmpty)
            XCTAssertEqual(data.morning.allSoulsPsalms?.count, 9)
            XCTAssertEqual(data.evening.psalms, ["116", "120", "121", "130", "138"])
            XCTAssertEqual(data.morning.collects.count, 7)
            XCTAssertEqual(data.evening.collects.count, 6)
            XCTAssertEqual(data.morning.firstLesson.reference, "14:1-16")
            XCTAssertEqual(data.evening.firstLesson.version, "APO1933")
        }
    }

    @MainActor
    func testCollectSupportsLegacySingleObjectAndMultipleOptions() throws {
        let singleData = Data(#"{"title":"祝文","text":"第一篇"}"#.utf8)
        let single = try JSONDecoder().decode(
            DailyOfficeFile.OfficePeriod.CollectJSON.self,
            from: singleData
        )
        XCTAssertEqual(single.options.count, 1)
        XCTAssertEqual(single.options.first?.text, "第一篇")

        let multipleData = Data(#"[{"option_label":"默認祝文","title":"祝文","text":"第一篇"},{"option_label":"另一祝文","title":"另一祝文","text":"第二篇"}]"#.utf8)
        let multiple = try JSONDecoder().decode(
            DailyOfficeFile.OfficePeriod.CollectJSON.self,
            from: multipleData
        )
        XCTAssertEqual(multiple.options.count, 2)
        XCTAssertEqual(multiple.options.map(\.optionLabel), ["默認祝文", "另一祝文"])
        XCTAssertEqual(multiple.options.map(\.text), ["第一篇", "第二篇"])
    }

    @MainActor
    func testAutumnEmberSaturdayProvidesTwoLocalizedCollects() throws {
        for language in [AppLanguage.traditional, .simplified] {
            let url = try XCTUnwrap(Bundle.main.url(
                forResource: "temporal_autumn_ember_saturday",
                withExtension: "json"
            ))
            let rawData = try Data(contentsOf: url)
            let localizedData = try XCTUnwrap(
                LocalizedJSONResolver.resolve(data: rawData, language: language)
            )
            let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localizedData)
            let options = try XCTUnwrap(file.morning?.collect?.options)

            XCTAssertEqual(options.count, 2)
            XCTAssertFalse(options[0].text.isEmpty)
            XCTAssertFalse(options[1].text.isEmpty)
        }
    }

    @MainActor
    func testHolyCrossProvidesThreeLocalizedCollects() throws {
        for language in [AppLanguage.traditional, .simplified] {
            let url = try XCTUnwrap(Bundle.main.url(
                forResource: "sanctorale_0914_holy_cross",
                withExtension: "json"
            ))
            let rawData = try Data(contentsOf: url)
            let localizedData = try XCTUnwrap(
                LocalizedJSONResolver.resolve(data: rawData, language: language)
            )
            let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localizedData)

            for options in [
                file.vigil?.collect?.options,
                file.morning?.collect?.options,
                file.evening?.collect?.options
            ] {
                let unwrapped = try XCTUnwrap(options)
                XCTAssertEqual(unwrapped.count, 3)
                XCTAssertEqual(
                    unwrapped.map(\.optionLabel),
                    language == .traditional
                        ? ["默認祝文", "又祝文", "另一祝文"]
                        : ["默认祝文", "又祝文", "另一祝文"]
                )
                XCTAssertTrue(unwrapped.allSatisfy { !$0.text.isEmpty })
            }
        }
    }

    @MainActor
    func testNativityOfMaryMorningSpecialLessonsLoadFromSanctoraleJSON() throws {
        let selectedDate = date(2025, 9, 8)
        let liturgy = service.resolve(for: selectedDate)
        let lessons = try XCTUnwrap(
            DailyOfficeLoader.shared.jsonLessons(
                for: selectedDate,
                liturgy: liturgy,
                isEvening: false,
                year: "special"
            )
        )

        XCTAssertEqual(lessons.ot?.book, "雅歌")
        XCTAssertEqual(lessons.ot?.chapter, "1:9-17")
        XCTAssertEqual(lessons.nt?.book, "羅馬書")
        XCTAssertEqual(lessons.nt?.chapter, "1:1-4")
    }

    func testMemorialAntiphonButtonsOnlyShowAvailableContentAndOmit() {
        XCTAssertEqual(
            MemorialAntiphonSelection.available(hasSeasonal: true, hasMarian: true),
            [.seasonal, .marian, .omit]
        )
        XCTAssertEqual(
            MemorialAntiphonSelection.available(hasSeasonal: true, hasMarian: false),
            [.seasonal, .omit]
        )
        XCTAssertEqual(
            MemorialAntiphonSelection.available(hasSeasonal: false, hasMarian: true),
            [.marian, .omit]
        )
        XCTAssertEqual(
            MemorialAntiphonSelection.available(hasSeasonal: false, hasMarian: false),
            []
        )
    }

    func testMemorialAntiphonResourcesFollowLocalizedOfficeSchema() throws {
        for language in [AppLanguage.traditional, .simplified] {
            let morning = try XCTUnwrap(
                MemorialAntiphonsLoader.shared.getContainer(language: language)
            )
            XCTAssertEqual(morning.identifier, "morning_memorial_antiphons")
            XCTAssertEqual(morning.type, "office_supplement")
            XCTAssertEqual(morning.seasonalAntiphons.count, 8)
            XCTAssertEqual(morning.marianAntiphons.count, 5)

            let eveningKeys = [
                "advent_feria",
                "advent_saturday",
                "advent_sunday",
                "epiphany_default",
                "epiphany_saturday_before_purification",
                "septuagesima",
                "lent",
                "easter_feria",
                "easter_saturday",
                "trinity_feria",
                "trinity_weekend"
            ]
            for key in eveningKeys {
                let entry = try XCTUnwrap(
                    MemorialAntiphonsLoader.shared.eveningSeasonalAntiphon(
                        for: key,
                        language: language
                    )
                )
                XCTAssertFalse(entry.antiphon.isEmpty, key)
                XCTAssertFalse(entry.versicle.leader.isEmpty, key)
                XCTAssertFalse(entry.versicle.people.isEmpty, key)
                XCTAssertFalse(entry.collect.text.isEmpty, key)
            }
        }
    }

    func testSaturdayOfficeOfOurLadyOnEligibleSaturday() {
        let result = service.resolve(for: date(2025, 5, 10))

        XCTAssertEqual(result.identifier, .saturdayOfficeOfOurLady)
        XCTAssertEqual(result.mainTitle, "禮拜六特敬聖母")
        XCTAssertEqual(result.rank, .saturdayOfficeBVM)
        XCTAssertEqual(result.color, "white")
        XCTAssertTrue(result.traits.themes.contains(.blessedVirginMary))
    }

    func testSaturdayOfficeOfOurLadyCommemoratesSimpleFeast() {
        let result = service.resolve(for: date(2025, 5, 24))

        XCTAssertEqual(result.identifier, .saturdayOfficeOfOurLady)
        XCTAssertTrue(result.commemorations.contains("勒蘭的聖文森特"))
    }

    func testSaturdayOfficeOfOurLadyIsOmittedForHigherFeastAndForbiddenTimes() {
        let highFeastSaturday = service.resolve(for: date(2025, 1, 25))
        XCTAssertNotEqual(highFeastSaturday.identifier, .saturdayOfficeOfOurLady)
        XCTAssertEqual(highFeastSaturday.mainTitle, "使徒聖保羅受感化日")
        XCTAssertNotEqual(service.resolve(for: date(2025, 1, 11)).identifier, .saturdayOfficeOfOurLady)
        XCTAssertNotEqual(service.resolve(for: date(2025, 3, 15)).identifier, .saturdayOfficeOfOurLady)
        XCTAssertNotEqual(service.resolve(for: date(2025, 9, 20)).identifier, .saturdayOfficeOfOurLady)
    }

    func testSaturdayOfficeOfOurLadyRunsFromFirstVespersThroughNona() {
        let fridayEvening = service.resolve(for: date(2025, 5, 23), isEvening: true)
        XCTAssertEqual(fridayEvening.identifier, .saturdayOfficeOfOurLady)
        XCTAssertTrue(fridayEvening.isFirstVespers)

        let saturdayDaytime = service.resolve(for: date(2025, 5, 24))
        XCTAssertEqual(saturdayDaytime.identifier, .saturdayOfficeOfOurLady)

        let saturdayEvening = service.resolve(for: date(2025, 5, 24), isEvening: true)
        XCTAssertNotEqual(saturdayEvening.identifier, .saturdayOfficeOfOurLady)
        XCTAssertFalse(saturdayEvening.commemorations.contains("禮拜六特敬聖母"))
    }

    func testSaturdayOfficeOfOurLadyJSONIsFormallyConnectedAndBilingual() throws {
        let resourceName = try XCTUnwrap(
            LiturgicalResourceResolver.shared.officeFileName(for: .saturdayOfficeOfOurLady)
        )
        XCTAssertEqual(resourceName, "saturday_office_of_our_lady")

        let url = try XCTUnwrap(
            Bundle.main.url(forResource: resourceName, withExtension: "json")
        )
        let source = try Data(contentsOf: url)

        let traditionalData = try XCTUnwrap(
            LocalizedJSONResolver.resolve(data: source, language: .traditional)
        )
        let traditionalFile = try JSONDecoder().decode(DailyOfficeFile.self, from: traditionalData)
        XCTAssertEqual(traditionalFile.identifier, LiturgicalID.saturdayOfficeOfOurLady.rawValue)
        XCTAssertEqual(traditionalFile.name, "禮拜六特敬聖母")
        XCTAssertEqual(traditionalFile.traits?.themes, [.blessedVirginMary])

        let simplifiedData = try XCTUnwrap(
            LocalizedJSONResolver.resolve(data: source, language: .simplified)
        )
        let simplifiedFile = try JSONDecoder().decode(DailyOfficeFile.self, from: simplifiedData)
        XCTAssertEqual(simplifiedFile.identifier, LiturgicalID.saturdayOfficeOfOurLady.rawValue)
        XCTAssertEqual(simplifiedFile.name, "礼拜六特敬圣母")
        XCTAssertEqual(simplifiedFile.traits?.themes, [.blessedVirginMary])
    }

    func testSaturdayOfficeOfOurLadyUsesBVMHymnEndingAtAllMinorHours() throws {
        let saturday = date(2025, 5, 10)
        let liturgy = service.resolve(for: saturday)
        XCTAssertEqual(liturgy.identifier, .saturdayOfficeOfOurLady)
        XCTAssertEqual(MinorHourPrayerRules.hymnEndingKey(for: saturday, liturgy: liturgy), "bvm")

        for language in [AppLanguage.traditional, .simplified] {
            for hour in MinorHour.allCases {
                let data = MinorHourPrayerDataLoader.shared.load(hour: hour, language: language)
                let bvmEnding = try XCTUnwrap(data.seasonalHymnEndings["bvm"])
                let verses = MinorHourPrayerRules.hymnVerses(
                    data: data,
                    date: saturday,
                    liturgy: liturgy
                )

                XCTAssertTrue(
                    try XCTUnwrap(verses.last).hasSuffix(bvmEnding),
                    "\(hour.rawValue) should use the BVM hymn ending for \(language.rawValue)"
                )
            }
        }
    }

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
            assertCalculatedDate(dateCalculator.easterSunday(in: year), year, month, day)
        }
    }

    func testAshWednesdayDatesAcrossMultipleYears() {
        let cases = [
            (2024, 2, 14),
            (2025, 3, 5),
            (2026, 2, 18)
        ]

        for (year, month, day) in cases {
            assertCalculatedDate(dateCalculator.ashWednesday(in: year), year, month, day)
        }
    }

    func testAscensionDatesAcrossMultipleYears() {
        let cases = [
            (2024, 5, 9),
            (2025, 5, 29),
            (2026, 5, 14)
        ]

        for (year, month, day) in cases {
            assertCalculatedDate(dateCalculator.ascensionDay(in: year), year, month, day)
        }
    }

    func testPentecostDatesAcrossMultipleYears() {
        let cases = [
            (2024, 5, 19),
            (2025, 6, 8),
            (2026, 5, 24)
        ]

        for (year, month, day) in cases {
            assertCalculatedDate(dateCalculator.pentecostSunday(in: year), year, month, day)
        }
    }

    func testTrinitySundayDatesAcrossMultipleYears() {
        let cases = [
            (2024, 5, 26),
            (2025, 6, 15),
            (2026, 5, 31)
        ]

        for (year, month, day) in cases {
            assertCalculatedDate(dateCalculator.trinitySunday(in: year), year, month, day)
        }
    }

    func testFirstSundayOfAdventDatesAcrossMultipleYears() {
        let cases = [
            (2024, 12, 1),
            (2025, 11, 30),
            (2026, 11, 29)
        ]

        for (year, month, day) in cases {
            assertCalculatedDate(dateCalculator.firstSundayOfAdvent(in: year), year, month, day)
        }
    }

    func testStableIdentifiersForCoreSpecialDays() {
        let cases: [(String, LiturgicalID)] = [
            ("救主受割禮日", .circumcision),
            ("顯現日", .epiphany),
            ("升天望日", .ascensionVigil),
            ("救主升天日", .ascension),
            ("聖靈降臨望日", .pentecostVigil),
            ("聖靈降臨日", .pentecost),
            ("三一主日", .trinitySunday),
            ("基督聖體節八日慶期第八日", .corpusChristiOctaveDayEight),
            ("耶穌聖心節", .sacredHeart),
            ("紀念使徒聖保羅", .paulCommemoration),
            ("我主基督至聖寶血", .preciousBlood)
        ]

        for (title, expected) in cases {
            XCTAssertEqual(LiturgicalID.fromLegacyTitle(title), expected, "\(title) 的 identifier 不正確")
        }
    }

    func testIdentifierIgnoresParentheticalCommemoration() {
        XCTAssertEqual(
            LiturgicalID.fromLegacyTitle("紀念使徒聖保羅 (紀念施洗聖約翰誕辰日八日慶期第七日)"),
            .paulCommemoration
        )
        XCTAssertEqual(
            LiturgicalID.fromLegacyTitle("我主基督至聖寶血（紀念施洗聖約翰誕辰日八日慶期第八日）"),
            .preciousBlood
        )
    }

    func testResolvedLiturgyIncludesStableIdentifier() {
        XCTAssertEqual(service.resolve(for: date(2025, 1, 6)).identifier, .epiphany)
        XCTAssertEqual(service.resolve(for: date(2025, 4, 20)).identifier, .easterDay)
        XCTAssertEqual(service.resolve(for: date(2025, 5, 29)).identifier, .ascension)
        XCTAssertEqual(service.resolve(for: date(2025, 6, 8)).identifier, .pentecost)
        XCTAssertEqual(service.resolve(for: date(2025, 6, 15)).identifier, .trinitySunday)
    }

    func testResolvedIdentifiersAcrossMultipleYears() {
        let cases: [(LiturgicalID, [(Int, Int, Int)])] = [
            (.easterDay, [(2024, 3, 31), (2025, 4, 20), (2026, 4, 5)]),
            (.ascension, [(2024, 5, 9), (2025, 5, 29), (2026, 5, 14)]),
            (.pentecost, [(2024, 5, 19), (2025, 6, 8), (2026, 5, 24)]),
            (.trinitySunday, [(2024, 5, 26), (2025, 6, 15), (2026, 5, 31)])
        ]

        for (expectedIdentifier, dates) in cases {
            for (year, month, day) in dates {
                let result = service.resolve(for: date(year, month, day))
                XCTAssertEqual(
                    result.identifier,
                    expectedIdentifier,
                    "\(Self.dateFormatter.string(from: date(year, month, day))) 的 identifier 不正確"
                )
            }
        }
    }

    func testIdentifiersDoNotDependOnDisplayTitles() {
        let changedTitle = "這段顯示文字可以改成其他語言"

        let dailyLiturgy = DailyLiturgy(
            identifier: .easterDay,
            mainTitle: changedTitle,
            color: "white",
            rank: .sundayFirstClassGreat,
            rankName: "",
            season: .easter,
            commemorations: [],
            transferred: []
        )
        XCTAssertEqual(dailyLiturgy.identifier, .easterDay)
        XCTAssertEqual(dailyLiturgy.mainTitle, changedTitle)

        let temporalDay = TemporalDay(
            identifier: .trinitySunday,
            title: changedTitle,
            rank: .sundayFirstClassGreat,
            rankName: "",
            color: "white",
            season: .trinity,
            isGreaterFeria: false
        )
        XCTAssertEqual(temporalDay.identifier, .trinitySunday)
        XCTAssertEqual(temporalDay.title, changedTitle)

        let feast = Feast(
            identifier: .epiphany,
            month: 1,
            day: 6,
            name: changedTitle,
            rank: .doubleFirstClass,
            priority: 0
        )
        XCTAssertEqual(feast.identifier, .epiphany)
        XCTAssertEqual(feast.name, changedTitle)
    }

    func testFirstVespersEligibilityDoesNotDependOnChineseTitle() {
        let resolver = FirstVespersResolver()
        let unrelatedDisplayTitle = "Display name in any language"

        XCTAssertTrue(
            resolver.hasFirstVespers(
                liturgy(identifier: .easterDay, title: unrelatedDisplayTitle, rank: .sundayFirstClassGreat)
            )
        )
        XCTAssertFalse(
            resolver.hasFirstVespers(
                liturgy(identifier: .legacy(title: "vigil"), title: unrelatedDisplayTitle, rank: .vigil)
            )
        )
        XCTAssertFalse(
            resolver.hasFirstVespers(
                liturgy(identifier: .legacy(title: "octave_day"), title: unrelatedDisplayTitle, rank: .privilegedOctaveSecondClass)
            )
        )
        XCTAssertTrue(
            resolver.hasFirstVespers(
                liturgy(identifier: .legacy(title: "octave_day_8"), title: unrelatedDisplayTitle, rank: .privilegedOctaveSecondClassGreat)
            )
        )
    }

    func testFirstVespersIdentifierExceptions() {
        let resolver = FirstVespersResolver()
        let unrelatedDisplayTitle = "名稱不參與判斷"

        for identifier in [
            LiturgicalID.trinityOctaveMonday,
            .trinityOctaveTuesday,
            .trinityOctaveWednesday,
            .paulCommemoration
        ] {
            XCTAssertFalse(
                resolver.hasFirstVespers(
                    liturgy(identifier: identifier, title: unrelatedDisplayTitle, rank: .semiDouble)
                ),
                "\(identifier.rawValue) 不應具有第一晚禱"
            )
        }
    }

    func testVigilDetectionUsesRankInsteadOfTitle() {
        let resolver = FirstVespersResolver()

        XCTAssertTrue(
            resolver.isVigil(
                liturgy(identifier: .pentecostVigil, title: "No Chinese keyword", rank: .privilegedVigilFirstClass)
            )
        )
        XCTAssertFalse(
            resolver.isVigil(
                liturgy(identifier: .easterDay, title: "文字中即使寫有望日也不採用", rank: .sundayFirstClassGreat)
            )
        )
    }

    func testEqualRankPrecedenceUsesIdentifiersAndPriority() {
        let resolver = LiturgicalPrecedenceResolver()

        XCTAssertTrue(
            resolver.tomorrowWins(
                EqualRankPrecedenceContext(
                    todayIdentifier: .corpusChristiOctaveDayEight,
                    tomorrowIdentifier: .sacredHeart,
                    todayIsFixedFeast: false,
                    tomorrowIsFixedFeast: false,
                    todayPriority: 0,
                    tomorrowPriority: 0
                )
            )
        )
        XCTAssertTrue(
            resolver.tomorrowWins(
                EqualRankPrecedenceContext(
                    todayIdentifier: .easterDay,
                    tomorrowIdentifier: .epiphany,
                    todayIsFixedFeast: false,
                    tomorrowIsFixedFeast: true,
                    todayPriority: 99,
                    tomorrowPriority: 0
                )
            )
        )
        XCTAssertTrue(
            resolver.tomorrowWins(
                EqualRankPrecedenceContext(
                    todayIdentifier: .easterDay,
                    tomorrowIdentifier: .epiphany,
                    todayIsFixedFeast: true,
                    tomorrowIsFixedFeast: true,
                    todayPriority: 1,
                    tomorrowPriority: 2
                )
            )
        )
    }

    func testEqualRankPrecedenceDefaultsToToday() {
        let context = EqualRankPrecedenceContext(
            todayIdentifier: .easterDay,
            tomorrowIdentifier: .trinitySunday,
            todayIsFixedFeast: false,
            tomorrowIsFixedFeast: false,
            todayPriority: 0,
            tomorrowPriority: 0
        )

        XCTAssertFalse(LiturgicalPrecedenceResolver().tomorrowWins(context))
    }

    func testCentralRuleTableContainsEveningExceptions() {
        XCTAssertTrue(
            LiturgicalRuleTable.daysWhoseEveningUsesTomorrow.contains(.peterAndPaulOctaveDaySeven)
        )
        XCTAssertTrue(
            LiturgicalRuleTable.daysWhoseEveningUsesTomorrow.contains(.assumptionOctaveDaySeven)
        )
        XCTAssertEqual(
            LiturgicalRuleTable.secondVespersSuppressedCommemorations[.preciousBlood],
            [.nativityOfJohnBaptistOctaveDayEight]
        )
    }

    func testCentralRuleTableContainsFixedDateExceptions() {
        XCTAssertEqual(
            LiturgicalRuleTable.corpusChristiOctaveFixedFeastDates,
            [
                .init(month: 6, day: 11),
                .init(month: 6, day: 24),
                .init(month: 6, day: 29)
            ]
        )
    }

    func testStructuredVigilTraitDoesNotDependOnChineseTitle() {
        let result = DailyLiturgy(
            identifier: .ascensionVigil,
            traits: LiturgicalTraits(vigil: .ordinary),
            mainTitle: "Display name in any language",
            color: "purple",
            rank: .greaterFeria,
            rankName: "",
            season: .ascension,
            commemorations: [],
            transferred: []
        )

        XCTAssertTrue(result.traits.isVigil)
        XCTAssertTrue(FirstVespersResolver().isVigil(result))
    }

    func testStructuredOctaveAndFastTraitsDoNotDependOnChineseTitle() {
        let traits = LiturgicalTraits(
            octave: OctaveInfo(day: 8),
            fast: .summerEmber
        )
        let result = TemporalDay(
            identifier: .legacy(title: "structured_test"),
            title: "Display name in any language",
            rank: .privilegedOctaveFirstClass,
            rankName: "",
            color: "red",
            season: .pentecost,
            isGreaterFeria: true,
            traits: traits
        )

        XCTAssertTrue(result.traits.isWithinOctave)
        XCTAssertEqual(result.traits.octaveDay, 8)
        XCTAssertEqual(result.traits.fast, .summerEmber)
    }

    func testResolvedDaysProvideStructuredTraits() {
        let ascensionVigil = service.resolve(for: date(2025, 5, 28))
        XCTAssertTrue(ascensionVigil.traits.isVigil)

        let ascensionOctaveDayEight = service.resolve(for: date(2025, 6, 5))
        XCTAssertTrue(ascensionOctaveDayEight.traits.isWithinOctave)
        XCTAssertEqual(ascensionOctaveDayEight.traits.octaveDay, 8)

        let summerEmberDay = service.resolve(for: date(2025, 6, 11))
        XCTAssertEqual(summerEmberDay.traits.fast, .summerEmber)

        let autumnEmberDay = service.resolve(for: date(2025, 9, 17))
        XCTAssertEqual(autumnEmberDay.traits.fast, .autumnEmber)
    }

    func testStructuredCommemorationDoesNotDependOnDisplayTitle() {
        let item = LiturgicalCommemoration(
            identifier: .paulCommemoration,
            title: "Display name in any language"
        )
        let liturgy = DailyLiturgy(
            identifier: .preciousBlood,
            mainTitle: "Another display name",
            color: "white",
            rank: .doubleFirstClass,
            rankName: "",
            season: .trinity,
            commemorationItems: [item],
            transferred: []
        )

        XCTAssertEqual(liturgy.commemorationItems.first?.identifier, .paulCommemoration)
        XCTAssertEqual(liturgy.commemorations, ["Display name in any language"])
    }

    func testLegacyCommemorationIsConvertedAtModelBoundary() {
        let liturgy = DailyLiturgy(
            mainTitle: "測試日",
            color: "green",
            rank: .feria,
            rankName: "",
            season: .trinity,
            commemorations: ["紀念使徒聖保羅", "測試望日"],
            transferred: []
        )

        XCTAssertEqual(liturgy.commemorationItems[0].identifier, .paulCommemoration)
        XCTAssertTrue(liturgy.commemorationItems[1].traits.isVigil)
    }

    func testAdditionalComparedDaysHaveStableIdentifiers() {
        let cases: [(String, LiturgicalID)] = [
            ("七旬主日", .septuagesimaSunday),
            ("六旬主日", .sexagesimaSunday),
            ("五旬主日", .quinquagesimaSunday),
            ("苦難主日", .passionSunday),
            ("棕樹主日", .palmSunday),
            ("升天後主日", .sundayAfterAscension),
            ("基督聖體節", .corpusChristi),
            ("三一主日後第一主日", .corpusChristiOctaveSunday),
            ("三一主日後第二主日", .sacredHeartOctaveSunday),
            ("基督君王節", .christTheKing),
            ("降臨前主日", .sundayBeforeAdvent),
            ("聖誕後第二主日", .sundayAfterChristmas),
            ("使徒聖巴拿巴日", .barnabas)
        ]

        for (title, identifier) in cases {
            XCTAssertEqual(LiturgicalID.fromLegacyTitle(title), identifier)
        }
    }

    func testResourceSelectionDoesNotDependOnDisplayTitle() {
        let resolver = LiturgicalResourceResolver.shared

        XCTAssertEqual(resolver.officeFileName(for: .ascension), "temporal_ascension_day")
        XCTAssertEqual(resolver.officeFileName(for: .barnabas), "sanctorale_0611_barnabas")
        XCTAssertEqual(resolver.introductionFileName(for: .ascension), "intro_ascension")
        XCTAssertEqual(resolver.introductionFileName(for: .trinitySunday), "intro_trinity")
    }

    func testTemporalIdentifiersAndThemesReplaceTitleMatching() {
        let temporalID = LiturgicalID.temporal(season: .easter, week: 5, weekday: 1)
        XCTAssertEqual(temporalID.temporalComponents?.season, .easter)
        XCTAssertEqual(temporalID.temporalComponents?.week, 5)
        XCTAssertEqual(
            LiturgicalResourceResolver.shared.introductionFileName(for: temporalID),
            "intro_easter5"
        )

        let marian = LiturgicalTraits.fromLegacyData(
            identifier: .legacy(title: "display-name-independent"),
            title: "榮福童貞馬利亞升天日",
            rank: .doubleFirstClass,
            season: .trinity
        )
        XCTAssertTrue(marian.themes.contains(.blessedVirginMary))
    }

    func testSeptemberSecondJSONUsesStructuredIdentifier() throws {
        XCTAssertEqual(
            LiturgicalResourceResolver.shared.officeFileName(for: .stephenOfHungary),
            "sanctorale_0902_stephen_of_hungary"
        )

        let feast = Sanctorale.shared.getFeasts(for: date(2025, 9, 2))
            .first { $0.identifier == .stephenOfHungary }
        XCTAssertNotNil(feast)

        let url = try XCTUnwrap(
            Bundle.main.url(
                forResource: "sanctorale_0902_stephen_of_hungary",
                withExtension: "json"
            )
        )
        let source = try Data(contentsOf: url)
        let localized = try XCTUnwrap(
            LocalizedJSONResolver.resolve(data: source, language: .traditional)
        )
        let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
        XCTAssertEqual(file.identifier, LiturgicalID.stephenOfHungary.rawValue)
        XCTAssertEqual(file.traits?.themes, [.confessor, .sovereign])
    }

    func testSeptemberSeventhJSONUsesStructuredIdentifier() throws {
        XCTAssertEqual(
            LiturgicalResourceResolver.shared.officeFileName(for: .evurtius),
            "sanctorale_0907_evurtius"
        )

        let feast = Sanctorale.shared.getFeasts(for: date(2025, 9, 7))
            .first { $0.identifier == .evurtius }
        XCTAssertNotNil(feast)

        let url = try XCTUnwrap(
            Bundle.main.url(
                forResource: "sanctorale_0907_evurtius",
                withExtension: "json"
            )
        )
        let source = try Data(contentsOf: url)
        let localized = try XCTUnwrap(
            LocalizedJSONResolver.resolve(data: source, language: .traditional)
        )
        let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
        XCTAssertEqual(file.identifier, LiturgicalID.evurtius.rawValue)
        XCTAssertEqual(file.traits?.themes, [.bishop, .confessor])
    }

    func testSeptemberEighthJSONUsesStructuredIdentifier() throws {
        XCTAssertEqual(
            LiturgicalResourceResolver.shared.officeFileName(for: .nativityOfMary),
            "sanctorale_0908_nativity_of_mary"
        )

        let feast = Sanctorale.shared.getFeasts(for: date(2025, 9, 8))
            .first { $0.identifier == .nativityOfMary }
        XCTAssertNotNil(feast)

        let url = try XCTUnwrap(
            Bundle.main.url(
                forResource: "sanctorale_0908_nativity_of_mary",
                withExtension: "json"
            )
        )
        let source = try Data(contentsOf: url)
        let localized = try XCTUnwrap(
            LocalizedJSONResolver.resolve(data: source, language: .traditional)
        )
        let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
        XCTAssertEqual(file.identifier, LiturgicalID.nativityOfMary.rawValue)
        XCTAssertEqual(file.traits?.themes, [.blessedVirginMary])
    }

    func testSeptemberNinthJSONUsesStructuredIdentifier() throws {
        XCTAssertEqual(
            LiturgicalResourceResolver.shared.officeFileName(for: .peterClaver),
            "sanctorale_0909_peter_claver"
        )

        let feast = Sanctorale.shared.getFeasts(for: date(2025, 9, 9))
            .first { $0.identifier == .peterClaver }
        XCTAssertNotNil(feast)

        let url = try XCTUnwrap(
            Bundle.main.url(
                forResource: "sanctorale_0909_peter_claver",
                withExtension: "json"
            )
        )
        let source = try Data(contentsOf: url)
        let localized = try XCTUnwrap(
            LocalizedJSONResolver.resolve(data: source, language: .traditional)
        )
        let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
        XCTAssertEqual(file.identifier, LiturgicalID.peterClaver.rawValue)
        XCTAssertEqual(file.traits?.themes, [.confessor])
    }

    func testSeptemberEleventhJSONUsesStructuredIdentifier() throws {
        XCTAssertEqual(
            LiturgicalResourceResolver.shared.officeFileName(for: .protusAndHyacinth),
            "sanctorale_0911_protus_and_hyacinth"
        )

        let feast = Sanctorale.shared.getFeasts(for: date(2025, 9, 11))
            .first { $0.identifier == .protusAndHyacinth }
        XCTAssertNotNil(feast)

        let url = try XCTUnwrap(
            Bundle.main.url(
                forResource: "sanctorale_0911_protus_and_hyacinth",
                withExtension: "json"
            )
        )
        let source = try Data(contentsOf: url)
        let localized = try XCTUnwrap(
            LocalizedJSONResolver.resolve(data: source, language: .traditional)
        )
        let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
        XCTAssertEqual(file.identifier, LiturgicalID.protusAndHyacinth.rawValue)
        XCTAssertEqual(file.traits?.themes, [.martyr])
    }

    func testSeptemberTwelfthJSONUsesStructuredIdentifier() throws {
        XCTAssertEqual(
            LiturgicalResourceResolver.shared.officeFileName(for: .holyNameOfMary),
            "sanctorale_0912_holy_name_of_mary"
        )

        let feast = Sanctorale.shared.getFeasts(for: date(2025, 9, 12))
            .first { $0.identifier == .holyNameOfMary }
        XCTAssertNotNil(feast)

        let url = try XCTUnwrap(
            Bundle.main.url(
                forResource: "sanctorale_0912_holy_name_of_mary",
                withExtension: "json"
            )
        )
        let source = try Data(contentsOf: url)
        let localized = try XCTUnwrap(
            LocalizedJSONResolver.resolve(data: source, language: .traditional)
        )
        let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
        XCTAssertEqual(file.identifier, LiturgicalID.holyNameOfMary.rawValue)
        XCTAssertEqual(file.traits?.themes, [.blessedVirginMary])
    }

    func testSeptemberFourteenthJSONUsesStructuredIdentifier() throws {
        XCTAssertEqual(
            LiturgicalResourceResolver.shared.officeFileName(for: .holyCross),
            "sanctorale_0914_holy_cross"
        )

        let feast = Sanctorale.shared.getFeasts(for: date(2025, 9, 14))
            .first { $0.identifier == .holyCross }
        XCTAssertNotNil(feast)

        let url = try XCTUnwrap(
            Bundle.main.url(
                forResource: "sanctorale_0914_holy_cross",
                withExtension: "json"
            )
        )
        let source = try Data(contentsOf: url)
        let localized = try XCTUnwrap(
            LocalizedJSONResolver.resolve(data: source, language: .traditional)
        )
        let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
        XCTAssertEqual(file.identifier, LiturgicalID.holyCross.rawValue)
        XCTAssertEqual(file.traits?.themes, [.holyCross])
    }

    func testSeptemberFifteenthThroughThirtiethJSONFilesUseStructuredIdentifiers() throws {
        let resources: [(LiturgicalID, String, Set<LiturgicalTheme>)] = [
            (.ourLadyOfSorrows, "sanctorale_0915_our_lady_of_sorrows", [.blessedVirginMary]),
            (.cyprian, "sanctorale_0916_cyprian", [.martyr, .bishop]),
            (.ninian, "sanctorale_0916_ninian", [.bishop, .confessor]),
            (.stigmataOfFrancis, "sanctorale_0917_stigmata_of_francis", [.confessor]),
            (.edwardBouveriePusey, "sanctorale_0918_edward_bouverie_pusey", [.confessor]),
            (.theodoreOfCanterbury, "sanctorale_0919_theodore_of_canterbury", [.bishop, .confessor]),
            (.johnColeridgePatteson, "sanctorale_0920_john_coleridge_patteson", [.bishop, .martyr]),
            (.matthewVigil, "sanctorale_0920_matthew_vigil", [.apostle, .evangelist]),
            (.matthew, "sanctorale_0921_matthew", [.apostle, .evangelist]),
            (.mauriceAndCompanions, "sanctorale_0922_maurice_and_companions", [.martyr]),
            (.linus, "sanctorale_0923_linus", [.martyr, .bishop]),
            (.thecla, "sanctorale_0923_thecla", [.virgin, .martyr]),
            (.ourLadyOfRansom, "sanctorale_0924_our_lady_of_ransom", [.blessedVirginMary]),
            (.lancelotAndrewes, "sanctorale_0925_lancelot_andrewes", [.bishop, .confessor]),
            (.cosmasAndDamian, "sanctorale_0927_cosmas_and_damian", [.martyr]),
            (.wenceslaus, "sanctorale_0928_wenceslaus", [.martyr, .sovereign]),
            (.michaelAndAllAngels, "sanctorale_0929_michael_and_all_angels", [.angel]),
            (.jerome, "sanctorale_0930_jerome", [.confessor, .churchDoctor])
        ]

        for (identifier, resourceName, expectedThemes) in resources {
            XCTAssertEqual(
                LiturgicalResourceResolver.shared.officeFileName(for: identifier),
                resourceName
            )
            let url = try XCTUnwrap(
                Bundle.main.url(forResource: resourceName, withExtension: "json")
            )
            let source = try Data(contentsOf: url)
            let localized = try XCTUnwrap(
                LocalizedJSONResolver.resolve(data: source, language: .traditional)
            )
            let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
            XCTAssertEqual(file.identifier, identifier.rawValue, resourceName)
            XCTAssertEqual(file.traits?.themes, expectedThemes, resourceName)
        }

        let mainFeasts: [(Int, LiturgicalID)] = [
            (15, .ourLadyOfSorrows), (16, .cyprian), (17, .stigmataOfFrancis),
            (18, .edwardBouveriePusey), (19, .theodoreOfCanterbury),
            (20, .matthewVigil), (21, .matthew), (22, .mauriceAndCompanions),
            (23, .linus), (24, .ourLadyOfRansom), (25, .lancelotAndrewes),
            (27, .cosmasAndDamian), (28, .wenceslaus),
            (29, .michaelAndAllAngels), (30, .jerome)
        ]
        for (day, identifier) in mainFeasts {
            XCTAssertTrue(
                Sanctorale.shared.getFeasts(for: date(2025, 9, day))
                    .contains { $0.identifier == identifier }
            )
        }

        XCTAssertEqual(LiturgicalID.fromLegacyTitle("聖尼安主教"), .ninian)
        XCTAssertEqual(
            LiturgicalID.fromLegacyTitle("真福約翰·科爾里奇·帕特森主教"),
            .johnColeridgePatteson
        )
        XCTAssertEqual(LiturgicalID.fromLegacyTitle("童貞女聖德克拉"), .thecla)
    }

    func testTrinityWeekThirteenThursdayJSONUsesStructuredIdentifier() throws {
        let identifier = LiturgicalID.temporal(season: .trinity, week: 13, weekday: 5)
        XCTAssertEqual(
            LiturgicalResourceResolver.shared.officeFileName(for: identifier),
            "temporal_trinity_13_thursday"
        )

        let url = try XCTUnwrap(
            Bundle.main.url(
                forResource: "temporal_trinity_13_thursday",
                withExtension: "json"
            )
        )
        let source = try Data(contentsOf: url)
        let localized = try XCTUnwrap(
            LocalizedJSONResolver.resolve(data: source, language: .traditional)
        )
        let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
        XCTAssertEqual(file.identifier, identifier.rawValue)
        XCTAssertEqual(
            file.temporal,
            DailyOfficeFile.TemporalMetadata(season: "trinity", week: 13, weekday: 5)
        )
        XCTAssertEqual(file.traits, LiturgicalTraits.none)
    }

    func testAllTrinityWeekThirteenJSONFilesUseStructuredIdentifiers() throws {
        let weekdayNames = [
            1: "sunday", 2: "monday", 3: "tuesday", 4: "wednesday",
            5: "thursday", 6: "friday", 7: "saturday"
        ]

        for weekday in 1...7 {
            let identifier = LiturgicalID.temporal(
                season: .trinity,
                week: 13,
                weekday: weekday
            )
            let resourceName = "temporal_trinity_13_\(weekdayNames[weekday]!)"
            XCTAssertEqual(
                LiturgicalResourceResolver.shared.officeFileName(for: identifier),
                resourceName
            )

            let url = try XCTUnwrap(
                Bundle.main.url(forResource: resourceName, withExtension: "json")
            )
            let source = try Data(contentsOf: url)
            let localized = try XCTUnwrap(
                LocalizedJSONResolver.resolve(data: source, language: .traditional)
            )
            let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
            XCTAssertEqual(file.identifier, identifier.rawValue)
            XCTAssertEqual(file.temporal?.season, "trinity")
            XCTAssertEqual(file.temporal?.week, 13)
            XCTAssertEqual(file.temporal?.weekday, weekday)
            XCTAssertEqual(file.traits, LiturgicalTraits.none)
        }
    }

    func testAllTrinityWeekFourteenJSONFilesUseStructuredIdentifiers() throws {
        let weekdayNames = [
            1: "sunday", 2: "monday", 3: "tuesday", 4: "wednesday",
            5: "thursday", 6: "friday", 7: "saturday"
        ]

        for weekday in 1...7 {
            let identifier = LiturgicalID.temporal(
                season: .trinity,
                week: 14,
                weekday: weekday
            )
            let resourceName = "temporal_trinity_14_\(weekdayNames[weekday]!)"
            XCTAssertEqual(
                LiturgicalResourceResolver.shared.officeFileName(for: identifier),
                resourceName
            )

            let url = try XCTUnwrap(
                Bundle.main.url(forResource: resourceName, withExtension: "json")
            )
            let source = try Data(contentsOf: url)
            let localized = try XCTUnwrap(
                LocalizedJSONResolver.resolve(data: source, language: .traditional)
            )
            let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
            XCTAssertEqual(file.identifier, identifier.rawValue)
            XCTAssertEqual(file.temporal?.season, "trinity")
            XCTAssertEqual(file.temporal?.week, 14)
            XCTAssertEqual(file.temporal?.weekday, weekday)
            XCTAssertEqual(file.traits, LiturgicalTraits.none)
        }
    }

    func testAllTrinityWeekFifteenJSONFilesUseStructuredIdentifiers() throws {
        let weekdayNames = [
            1: "sunday", 2: "monday", 3: "tuesday", 4: "wednesday",
            5: "thursday", 6: "friday", 7: "saturday"
        ]

        for weekday in 1...7 {
            let identifier = LiturgicalID.temporal(
                season: .trinity,
                week: 15,
                weekday: weekday
            )
            let resourceName = "temporal_trinity_15_\(weekdayNames[weekday]!)"
            XCTAssertEqual(
                LiturgicalResourceResolver.shared.officeFileName(for: identifier),
                resourceName
            )

            let url = try XCTUnwrap(
                Bundle.main.url(forResource: resourceName, withExtension: "json")
            )
            let source = try Data(contentsOf: url)
            let localized = try XCTUnwrap(
                LocalizedJSONResolver.resolve(data: source, language: .traditional)
            )
            let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
            XCTAssertEqual(file.identifier, identifier.rawValue)
            XCTAssertEqual(file.temporal?.season, "trinity")
            XCTAssertEqual(file.temporal?.week, 15)
            XCTAssertEqual(file.temporal?.weekday, weekday)
            XCTAssertEqual(file.traits, LiturgicalTraits.none)
        }
    }

    func testAllTrinityWeekSixteenJSONFilesUseStructuredIdentifiers() throws {
        let weekdayNames = [
            1: "sunday", 2: "monday", 3: "tuesday", 4: "wednesday",
            5: "thursday", 6: "friday", 7: "saturday"
        ]

        for weekday in 1...7 {
            let identifier = LiturgicalID.temporal(
                season: .trinity,
                week: 16,
                weekday: weekday
            )
            let resourceName = "temporal_trinity_16_\(weekdayNames[weekday]!)"
            XCTAssertEqual(
                LiturgicalResourceResolver.shared.officeFileName(for: identifier),
                resourceName
            )

            let url = try XCTUnwrap(
                Bundle.main.url(forResource: resourceName, withExtension: "json")
            )
            let source = try Data(contentsOf: url)
            let localized = try XCTUnwrap(
                LocalizedJSONResolver.resolve(data: source, language: .traditional)
            )
            let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
            XCTAssertEqual(file.identifier, identifier.rawValue)
            XCTAssertEqual(file.temporal?.season, "trinity")
            XCTAssertEqual(file.temporal?.week, 16)
            XCTAssertEqual(file.temporal?.weekday, weekday)
            XCTAssertEqual(file.traits, LiturgicalTraits.none)
        }
    }

    func testAllTrinityWeekSeventeenJSONFilesUseStructuredIdentifiers() throws {
        let weekdayNames = [
            1: "sunday", 2: "monday", 3: "tuesday", 4: "wednesday",
            5: "thursday", 6: "friday", 7: "saturday"
        ]

        for weekday in 1...7 {
            let identifier = LiturgicalID.temporal(
                season: .trinity,
                week: 17,
                weekday: weekday
            )
            let resourceName = "temporal_trinity_17_\(weekdayNames[weekday]!)"
            XCTAssertEqual(
                LiturgicalResourceResolver.shared.officeFileName(for: identifier),
                resourceName
            )

            let url = try XCTUnwrap(
                Bundle.main.url(forResource: resourceName, withExtension: "json")
            )
            let source = try Data(contentsOf: url)
            let localized = try XCTUnwrap(
                LocalizedJSONResolver.resolve(data: source, language: .traditional)
            )
            let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
            XCTAssertEqual(file.identifier, identifier.rawValue)
            XCTAssertEqual(file.temporal?.season, "trinity")
            XCTAssertEqual(file.temporal?.week, 17)
            XCTAssertEqual(file.temporal?.weekday, weekday)
            XCTAssertEqual(file.traits, LiturgicalTraits.none)
        }
    }

    func testAllTrinityWeekEighteenJSONFilesUseStructuredIdentifiers() throws {
        let weekdayNames = [
            1: "sunday", 2: "monday", 3: "tuesday", 4: "wednesday",
            5: "thursday", 6: "friday", 7: "saturday"
        ]

        for weekday in 1...7 {
            let identifier = LiturgicalID.temporal(
                season: .trinity,
                week: 18,
                weekday: weekday
            )
            let resourceName = "temporal_trinity_18_\(weekdayNames[weekday]!)"
            XCTAssertEqual(
                LiturgicalResourceResolver.shared.officeFileName(for: identifier),
                resourceName
            )

            let url = try XCTUnwrap(
                Bundle.main.url(forResource: resourceName, withExtension: "json")
            )
            let source = try Data(contentsOf: url)
            let localized = try XCTUnwrap(
                LocalizedJSONResolver.resolve(data: source, language: .traditional)
            )
            let file = try JSONDecoder().decode(DailyOfficeFile.self, from: localized)
            XCTAssertEqual(file.identifier, identifier.rawValue)
            XCTAssertEqual(file.temporal?.season, "trinity")
            XCTAssertEqual(file.temporal?.week, 18)
            XCTAssertEqual(file.temporal?.weekday, weekday)
            XCTAssertEqual(file.traits, LiturgicalTraits.none)
        }
    }

    func testResolvedComparedSundaysHaveStableIdentifiers() {
        XCTAssertEqual(service.resolve(for: date(2025, 6, 1)).identifier, .sundayAfterAscension)
        XCTAssertEqual(service.resolve(for: date(2025, 6, 22)).identifier, .corpusChristiOctaveSunday)
        XCTAssertEqual(service.resolve(for: date(2024, 6, 9)).identifier, .sacredHeartOctaveSunday)
        XCTAssertEqual(service.resolve(for: date(2025, 10, 26)).identifier, .christTheKing)
        XCTAssertEqual(service.resolve(for: date(2025, 11, 23)).identifier, .sundayBeforeAdvent)
    }

    func testOrdinaryVigilTransfersFromSundayToSaturday() {
        let resolver = LiturgicalTransferResolver()
        let vigil = Feast(
            identifier: .legacy(title: "ordinary_vigil"),
            month: 9,
            day: 14,
            name: "測試望日 (紀念測試聖人)",
            rank: .vigil,
            priority: 0
        )
        let initial = VigilTransferResolution(
            title: "禮拜六",
            rank: .feria,
            rankName: "普通平日",
            color: "green",
            commemorations: [],
            transferred: []
        )

        let result = resolver.resolveOrdinaryVigilTransfer(
            weekday: 7,
            temporal: temporalDay(title: "禮拜六"),
            todayFeasts: [],
            tomorrowFeasts: [vigil],
            current: initial
        )

        XCTAssertEqual(result.commemorations.map(\.title), ["測試望日"])
        XCTAssertTrue(result.transferred.isEmpty)
    }

    func testSundayRemovesTransferredOrdinaryVigil() {
        let resolver = LiturgicalTransferResolver()
        let vigil = Feast(
            identifier: .legacy(title: "ordinary_vigil"),
            month: 9,
            day: 14,
            name: "測試望日",
            rank: .vigil,
            priority: 0
        )
        let sunday = temporalDay(title: "測試主日", rank: .ordinarySunday)
        let initial = VigilTransferResolution(
            title: vigil.name,
            rank: vigil.rank,
            rankName: vigil.rank.displayName,
            color: "purple",
            commemorations: [LiturgicalCommemoration(feast: vigil)],
            transferred: []
        )

        let result = resolver.resolveOrdinaryVigilTransfer(
            weekday: 1,
            temporal: sunday,
            todayFeasts: [vigil],
            tomorrowFeasts: [],
            current: initial
        )

        XCTAssertEqual(result.title, sunday.title)
        XCTAssertEqual(result.rank, sunday.rank)
        XCTAssertFalse(result.commemorations.contains(vigil.name))
        XCTAssertEqual(result.transferred, [vigil.name])
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

    private func liturgy(
        identifier: LiturgicalID,
        title: String,
        rank: LiturgicalRank
    ) -> DailyLiturgy {
        DailyLiturgy(
            identifier: identifier,
            mainTitle: title,
            color: "white",
            rank: rank,
            rankName: "",
            season: .easter,
            commemorations: [],
            transferred: []
        )
    }

    private func temporalDay(
        title: String,
        rank: LiturgicalRank = .feria
    ) -> TemporalDay {
        TemporalDay(
            title: title,
            rank: rank,
            rankName: rank.displayName,
            color: "green",
            season: .trinity,
            isGreaterFeria: false
        )
    }

    private func assertCalculatedDate(
        _ actual: Date,
        _ year: Int,
        _ month: Int,
        _ day: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            Self.dateFormatter.string(from: actual),
            Self.dateFormatter.string(from: date(year, month, day)),
            "\(year) 年的禮儀日期計算不正確",
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
