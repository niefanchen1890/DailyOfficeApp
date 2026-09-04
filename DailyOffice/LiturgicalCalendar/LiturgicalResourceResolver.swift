import Foundation

/// 將穩定禮儀 identifier 轉成實際 JSON 資源名稱。
/// 顯示文字不參與選檔，因此繁簡切換不會改變載入結果。
struct LiturgicalResourceResolver {
    static let shared = LiturgicalResourceResolver()

    private let officeFiles: [LiturgicalID: String] = [
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
