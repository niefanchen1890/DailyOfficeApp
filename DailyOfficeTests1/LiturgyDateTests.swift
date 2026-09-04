import XCTest
@testable import DailyOffice

final class LiturgyDateTests: XCTestCase {
    private let service = LiturgyCoreService()
    private let dateCalculator = LiturgicalDateCalculator()

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
