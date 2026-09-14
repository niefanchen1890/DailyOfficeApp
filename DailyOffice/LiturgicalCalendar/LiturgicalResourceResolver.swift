import Foundation

/// 將穩定禮儀 identifier 轉成實際 JSON 資源名稱。
/// 顯示文字不參與選檔，因此繁簡切換不會改變載入結果。
struct LiturgicalResourceResolver {
    static let shared = LiturgicalResourceResolver()

    /// 三一後主日總數包含最後的降臨前主日，不包含三一主日本身。
    /// 只選專用內容，並不改變當日的節期、等級或經課週次。
    func trinitySundayReplacementFile(for date: Date) -> String? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        guard calendar.component(.weekday, from: date) == 1 else { return nil }
        let calculator = LiturgicalDateCalculator(calendar: calendar)
        let year = calendar.component(.year, from: date)
        let trinity = calculator.trinitySunday(in: year)
        let advent = calculator.firstSundayOfAdvent(in: year)
        let offset = calculator.daysBetween(trinity, and: date)
        let total = calculator.daysBetween(trinity, and: advent) / 7 - 1
        let week = offset / 7
        guard offset > 0, week <= total else { return nil }
        if week == total { return "sunday_next_before_advent" }
        switch (total, week) {
        case (26, 25), (27, 26): return "temporal_epiphany_6_sunday"
        case (27, 25): return "temporal_epiphany_5_sunday"
        default: return nil
        }
    }

    private let officeFiles: [LiturgicalID: String] = [
        .circumcision: "sanctorale_0101_circumcision",
        .stephenOctave8: "sanctorale_0102_stephen_octave_8",
        .johnOctave8: "sanctorale_0103_john_octave_8",
        .holyInnocentsOctave8: "sanctorale_0104_holy_innocents_octave_8",
        .epiphanyVigil: "sanctorale_0105_epiphany_vigil",
        .epiphany: "sanctorale_0106_epiphany",
        .epiphanyOctave2: "sanctorale_0107_epiphany_octave_2",
        .epiphanyOctave3: "sanctorale_0108_epiphany_octave_3",
        .epiphanyOctave4: "sanctorale_0109_epiphany_octave_4",
        .epiphanyOctave5: "sanctorale_0110_epiphany_octave_5",
        .epiphanyOctave6: "sanctorale_0111_epiphany_octave_6",
        .epiphanyOctave7: "sanctorale_0112_epiphany_octave_7",
        .epiphanyOctave8: "sanctorale_0113_epiphany_octave_8",
        .stHilary: "sanctorale_0114_hilary",
        .stPaulHermit: "sanctorale_0115_paul_the_hermit",
        .williamLaud: "sanctorale_0116_william_laud",
        .stAnthonyEgypt: "sanctorale_0117_antony",
        .stPriscilla: "sanctorale_0118_prisca",
        .stsFabianSebastian: "sanctorale_0120_fabian_and_sebastian",
        .stAgnes: "sanctorale_0121_agnes",
        .stVincent: "sanctorale_0122_vincent",
        .stTimothy: "sanctorale_0124_timothy",
        .conversionStPaul: "sanctorale_0125_conversion_of_paul",
        .stPolycarp: "sanctorale_0126_polycarp",
        .stChrysostom: "sanctorale_0127_john_chrysostom",
        .anglicanEpiscopate: "sanctorale_0128_anglican_episcopate",
        .stFrancisDeSales: "sanctorale_0129_francis_de_sales",
        .kingCharlesMartyr: "sanctorale_0130_charles_martyr",
        .stJohnBosco: "sanctorale_0131_john_bosco",
        .firstSundayOfAdvent: "temporal_advent_1_sunday",
        .allSaints: "sanctorale_1101_all_saints",
        .allSouls: "sanctorale_1102_all_souls",
        .allSaintsOctave3: "sanctorale_1103_all_saints_octave_3",
        .stCharlesBorromeo: "sanctorale_1104_charles_borromeo",
        .stElizabeth: "sanctorale_1105_elizabeth",
        .allSaintsOctave6: "sanctorale_1106_all_saints_octave_6",
        .stWillibrord: "sanctorale_1107_willibrord",
        .anglicanSaints: "sanctorale_1108_saints_of_anglican_communion",
        .stTheodoreMartyr: "sanctorale_1109_theodore",
        .stMartin: "sanctorale_1111_martin_of_tours",
        .stBlaiseTours: "sanctorale_1113_brice",
        .stAlbertGreat: "sanctorale_1115_albert_the_great",
        .stGertrude: "sanctorale_1116_gertrude",
        .stHughLincoln: "sanctorale_1117_hugh_of_lincoln",
        .stHildaWhitby: "sanctorale_1118_hilda_of_whitby",
        .stElizabethHungary: "sanctorale_1119_elizabeth_of_hungary",
        .stEdmundKingMartyr: "sanctorale_1120_edmund_martyr",
        .presentationBvm: "sanctorale_1121_presentation_of_mary",
        .stCecilia: "sanctorale_1122_cecilia",
        .stClement: "sanctorale_1123_clement_of_rome",
        .stJohnCross: "sanctorale_1124_john_of_the_cross",
        .stCatherineAlexandria: "sanctorale_1125_catherine_of_alexandria",
        .stSylvesterAbbot: "sanctorale_1126_sylvester_abbot",
        .stAndrewVigil: "sanctorale_1129_andrew_vigil",
        .stAndrew: "sanctorale_1130_andrew",
        .blessedNicholasFerrar: "sanctorale_1201_nicholas_ferrar",
        .stPeterChrysologus: "sanctorale_1202_peter_chrysologus",
        .stFrancisXavier: "sanctorale_1203_francis_xavier",
        .stClementAlexandria: "sanctorale_1204_clement_of_alexandria",
        .stSabas: "sanctorale_1205_sabbas",
        .stNicholas: "sanctorale_1206_nicholas",
        .stAmbrose: "sanctorale_1207_ambrose",
        .immaculateConception: "sanctorale_1208_immaculate_conception",
        .immaculateConceptionOctave2: "sanctorale_1209_immaculate_conception_octave_2",
        .immaculateConceptionOctave3: "sanctorale_1210_immaculate_conception_octave_3",
        .immaculateConceptionOctave4: "sanctorale_1211_immaculate_conception_octave_4",
        .immaculateConceptionOctave5: "sanctorale_1212_immaculate_conception_octave_5",
        .stLucy: "sanctorale_1213_lucy",
        .immaculateConceptionOctave7: "sanctorale_1214_immaculate_conception_octave_7",
        .immaculateConceptionOctave8: "sanctorale_1215_immaculate_conception_octave_8",
        .stThomas: "sanctorale_1221_thomas",
        .christmasVigil: "sanctorale_1224_christmas_vigil",
        .christmasDay: "sanctorale_1225_christmas",
        .stStephen: "sanctorale_1226_stephen",
        .stJohnEvangelist: "sanctorale_1227_john",
        .holyInnocents: "sanctorale_1228_holy_innocents",
        .stThomasBecket: "sanctorale_1229_thomas_becket",
        .christmasOctave6: "sanctorale_1230_christmas_octave_6",
        .stSylvester: "sanctorale_1231_sylvester",
        .allSaintsOctave4: "sanctorale_1104_all_saints_octave_4",
        .allSaintsOctave5: "sanctorale_1105_all_saints_octave_5",
        .allSaintsOctave7: "sanctorale_1107_all_saints_octave_7",
        .immaculateConceptionOctave6: "sanctorale_1213_immaculate_conception_octave_6",
        .christmasOctave2: "sanctorale_1226_christmas_octave_2",
        .christmasOctave3: "sanctorale_1227_christmas_octave_3",
        .christmasOctave4: "sanctorale_1228_christmas_octave_4",
        .christmasOctave5: "sanctorale_1229_christmas_octave_5",
        .christmasOctave7: "sanctorale_1231_christmas_octave_7",
        .crispinAndCrispinian: "sanctorale_1025_crispin_and_crispinian",
        .sundayBeforeAdvent: "sunday_next_before_advent",
        .beforeAdventMonday: "temporal_before_advent_monday",
        .beforeAdventTuesday: "temporal_before_advent_tuesday",
        .beforeAdventWednesday: "temporal_before_advent_wednesday",
        .beforeAdventThursday: "temporal_before_advent_thursday",
        .beforeAdventFriday: "temporal_before_advent_friday",
        .beforeAdventSaturday: "temporal_before_advent_saturday",
        .christTheKing: "temporal_christ_the_king",
        .simonAndJude: "sanctorale_1028_simon_and_jude",
        .allSaintsVigil: "sanctorale_1031_all_saints_vigil",
        .simonAndJudeVigil: "sanctorale_1027_simon_and_jude_vigil",
        .hilarion: "sanctorale_1021_hilarion",
        .ursulaAndCompanions: "sanctorale_1021_ursula_and_companions",
        .newGuineaMartyrs: "sanctorale_1022_martyrs_of_new_guinea",
        .raphael: "sanctorale_1024_raphael",
        .frideswide: "sanctorale_1019_frideswide",
        .luke: "sanctorale_1018_luke",
        .etheldreda: "sanctorale_1017_etheldreda",
        .hedwig: "sanctorale_1016_hedwig",
        .ourLadyOfWalsingham: "sanctorale_1015_our_lady_of_walsingham",
        .teresaOfAvila: "sanctorale_1015_teresa_of_avila",
        .callistus: "sanctorale_1014_callistus",
        .translationOfEdwardConfessor: "sanctorale_1013_translation_of_edward",
        .wilfrid: "sanctorale_1012_wilfrid",
        .motherhoodOfMary: "sanctorale_1011_motherhood_of_mary",
        .denisAndCompanions: "sanctorale_1009_denis_and_companions",
        .bridgetOfSweden: "sanctorale_1008_bridget_of_sweden",
        .ourLadyOfTheRosary: "sanctorale_1007_our_lady_of_the_rosary",
        .simeonAndAnna: "sanctorale_1007_simeon_and_anna",
        .bruno: "sanctorale_1006_bruno",
        .placidus: "sanctorale_1005_placidus",
        .francisOfAssisi: "sanctorale_1004_francis_of_assisi",
        .thereseOfLisieux: "sanctorale_1003_therese_of_lisieux",
        .ascensionVigil: "temporal_ascension_vigil",
        .ascension: "temporal_ascension_day",
        .sundayAfterAscension: "temporal_ascension_1_sunday",
        .fridayAfterAscensionOctave: "temporal_ascension_friday_after",
        .pentecostVigil: "temporal_pentecost_vigil",
        .pentecost: "temporal_pentecost_sunday",
        .trinitySunday: "temporal_trinity_sunday",
        .corpusChristi: "temporal_corpus_christi",
        .corpusChristiOctave: "temporal_corpus_christi",
        .corpusChristiOctaveDayEight: "temporal_corpus_christi_octave_8",
        .sacredHeart: "temporal_sacred_heart",
        .sacredHeartOctaveDayEight: "temporal_sacred_heart_octave_8",
        .barnabas: "sanctorale_0611_barnabas",
        .stephenOfHungary: "sanctorale_0902_stephen_of_hungary",
        .evurtius: "sanctorale_0907_evurtius",
        .nativityOfMary: "sanctorale_0908_nativity_of_mary",
        .peterClaver: "sanctorale_0909_peter_claver",
        .protusAndHyacinth: "sanctorale_0911_protus_and_hyacinth",
        .holyNameOfMary: "sanctorale_0912_holy_name_of_mary",
        .holyCross: "sanctorale_0914_holy_cross",
        .ourLadyOfSorrows: "sanctorale_0915_our_lady_of_sorrows",
        .cyprian: "sanctorale_0916_cyprian",
        .ninian: "sanctorale_0916_ninian",
        .stigmataOfFrancis: "sanctorale_0917_stigmata_of_francis",
        .edwardBouveriePusey: "sanctorale_0918_edward_bouverie_pusey",
        .theodoreOfCanterbury: "sanctorale_0919_theodore_of_canterbury",
        .johnColeridgePatteson: "sanctorale_0920_john_coleridge_patteson",
        .matthewVigil: "sanctorale_0920_matthew_vigil",
        .matthew: "sanctorale_0921_matthew",
        .mauriceAndCompanions: "sanctorale_0922_maurice_and_companions",
        .linus: "sanctorale_0923_linus",
        .thecla: "sanctorale_0923_thecla",
        .ourLadyOfRansom: "sanctorale_0924_our_lady_of_ransom",
        .lancelotAndrewes: "sanctorale_0925_lancelot_andrewes",
        .cosmasAndDamian: "sanctorale_0927_cosmas_and_damian",
        .wenceslaus: "sanctorale_0928_wenceslaus",
        .michaelAndAllAngels: "sanctorale_0929_michael_and_all_angels",
        .jerome: "sanctorale_0930_jerome",
        .saturdayOfficeOfOurLady: "saturday_office_of_our_lady",
        .peterAndPaul: "sanctorale_0629_peter_and_paul",
        .paulCommemoration: "sanctorale_0630_commemoration_of_paul",
        .preciousBlood: "sanctorale_0701_precious_blood",
        .assumption: "sanctorale_0815_assumption"
    ]

    private let introductionFiles: [LiturgicalID: String] = [
        .epiphany: "intro_epiphany",
        .ashWednesday: "intro_lent",
        .easterDay: "intro_easter",
        .ascensionVigil: "intro_vigilofascension",
        .ascension: "intro_ascension",
        .sundayAfterAscension: "intro_sundayafterascension",
        .pentecostVigil: "intro_pentecost",
        .pentecost: "intro_pentecost",
        .trinitySunday: "intro_trinity"
    ]

    func officeFileName(for identifier: LiturgicalID) -> String? {
        if let name = officeFiles[identifier] {
            return name
        }
        guard let temporal = identifier.temporalComponents else { return nil }
        let weekdayNames = [
            1: "sunday", 2: "monday", 3: "tuesday", 4: "wednesday",
            5: "thursday", 6: "friday", 7: "saturday"
        ]
        guard let weekday = weekdayNames[temporal.weekday] else { return nil }
        let seasonNames: [LiturgicalSeason: String] = [
            .advent: "advent", .christmas: "christmas", .epiphany: "epiphany",
            .prelenten: "prelenten", .lent: "lent", .holyWeek: "holy_week",
            .easter: "easter", .ascension: "ascension", .pentecost: "pentecost",
            .trinity: "trinity", .holyDays: "holy_days"
        ]
        guard let season = seasonNames[temporal.season] else { return nil }
        return "temporal_\(season)_\(temporal.week)_\(weekday)"
    }

    func introductionFileName(for identifier: LiturgicalID) -> String? {
        if let name = introductionFiles[identifier] {
            return name
        }
        guard let temporal = identifier.temporalComponents else { return nil }
        switch temporal.season {
        case .advent: return "intro_advent"
        case .christmas: return "intro_christmas"
        case .epiphany: return "intro_epiphany"
        case .lent: return "intro_lent"
        case .holyWeek: return "intro_holy_week"
        case .easter:
            return temporal.week == 5 ? "intro_easter5" : "intro_eastertide"
        case .ascension: return "intro_ascension"
        case .pentecost: return "intro_pentecost"
        case .trinity: return "intro_trinity"
        default: return nil
        }
    }

    func massProperKey(for identifier: LiturgicalID) -> String? {
        let special: [LiturgicalID: String] = [
            .easterDay: "easter",
            .ascensionVigil: "vigilofascension",
            .ascension: "ascension",
            .sundayAfterAscension: "sundayafterascension",
            .pentecost: "pentecost",
            .trinitySunday: "trinity"
        ]
        if let key = special[identifier] { return key }
        guard let temporal = identifier.temporalComponents, temporal.weekday == 1 else { return nil }
        switch temporal.season {
        case .advent: return "advent\(temporal.week)"
        case .lent: return "lent\(temporal.week)"
        case .easter: return "easter\(temporal.week)"
        case .trinity: return "trinity\(temporal.week)"
        default: return nil
        }
    }
}
