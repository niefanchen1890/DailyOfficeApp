import Foundation

/// 禮儀日的穩定識別碼。
///
/// `rawValue` 只供程式和資料檔使用，不應顯示在畫面上，也不隨繁簡名稱改變。
struct LiturgicalID: RawRepresentable, Codable, Hashable, Sendable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    // MARK: - 核心直接引用的固定節期

    static let circumcision = LiturgicalID(rawValue: "circumcision")
    static let epiphany = LiturgicalID(rawValue: "epiphany")
    static let epiphanyVigil = LiturgicalID(rawValue: "epiphany_vigil")
    static let ashWednesday = LiturgicalID(rawValue: "ash_wednesday")
    static let easterDay = LiturgicalID(rawValue: "easter_day")
    static let ascension = LiturgicalID(rawValue: "ascension")
    static let ascensionVigil = LiturgicalID(rawValue: "ascension_vigil")
    static let fridayAfterAscensionOctave = LiturgicalID(rawValue: "friday_after_ascension_octave")
    static let pentecost = LiturgicalID(rawValue: "pentecost")
    static let pentecostVigil = LiturgicalID(rawValue: "pentecost_vigil")
    static let trinitySunday = LiturgicalID(rawValue: "trinity_sunday")
    static let trinityOctaveMonday = LiturgicalID(rawValue: "trinity_octave_monday")
    static let trinityOctaveTuesday = LiturgicalID(rawValue: "trinity_octave_tuesday")
    static let trinityOctaveWednesday = LiturgicalID(rawValue: "trinity_octave_wednesday")
    static let corpusChristiOctaveDayEight = LiturgicalID(rawValue: "corpus_christi_octave_day_8")
    static let sacredHeart = LiturgicalID(rawValue: "sacred_heart")
    static let peterAndPaul = LiturgicalID(rawValue: "peter_and_paul")
    static let peterAndPaulOctaveDaySeven = LiturgicalID(rawValue: "peter_and_paul_octave_day_7")
    static let paulCommemoration = LiturgicalID(rawValue: "paul_commemoration")
    static let preciousBlood = LiturgicalID(rawValue: "precious_blood")
    static let nativityOfJohnBaptistOctaveDayEight = LiturgicalID(rawValue: "nativity_of_john_baptist_octave_day_8")
    static let assumption = LiturgicalID(rawValue: "assumption")
    static let assumptionOctaveDaySeven = LiturgicalID(rawValue: "assumption_octave_day_7")
    static let firstSundayOfAdvent = LiturgicalID(rawValue: "advent_1_sunday")
    static let christmasDay = LiturgicalID(rawValue: "christmas_day")
    static let sundayAfterChristmas = LiturgicalID(rawValue: "sunday_after_christmas")
    static let septuagesimaSunday = LiturgicalID(rawValue: "septuagesima_sunday")
    static let sexagesimaSunday = LiturgicalID(rawValue: "sexagesima_sunday")
    static let quinquagesimaSunday = LiturgicalID(rawValue: "quinquagesima_sunday")
    static let passionSunday = LiturgicalID(rawValue: "passion_sunday")
    static let palmSunday = LiturgicalID(rawValue: "palm_sunday")
    static let sundayAfterAscension = LiturgicalID(rawValue: "sunday_after_ascension")
    static let corpusChristi = LiturgicalID(rawValue: "corpus_christi")
    static let corpusChristiOctave = LiturgicalID(rawValue: "corpus_christi_octave")
    static let corpusChristiOctaveSunday = LiturgicalID(rawValue: "corpus_christi_octave_sunday")
    static let sacredHeartOctaveSunday = LiturgicalID(rawValue: "sacred_heart_octave_sunday")
    static let sacredHeartOctaveDayEight = LiturgicalID(rawValue: "sacred_heart_octave_day_8")
    static let christTheKing = LiturgicalID(rawValue: "christ_the_king")
    static let sundayBeforeAdvent = LiturgicalID(rawValue: "sunday_before_advent")
    static let barnabas = LiturgicalID(rawValue: "st_barnabas")
    static let stephenOfHungary = LiturgicalID(rawValue: "st_stephen_hungary")
    static let evurtius = LiturgicalID(rawValue: "st_evurtius")
    static let nativityOfMary = LiturgicalID(rawValue: "nativity_of_mary")
    static let peterClaver = LiturgicalID(rawValue: "st_peter_claver")
    static let protusAndHyacinth = LiturgicalID(rawValue: "sts_proto_hyacinth")
    static let holyNameOfMary = LiturgicalID(rawValue: "holy_name_mary")
    static let holyCross = LiturgicalID(rawValue: "holy_cross")
    static let ourLadyOfSorrows = LiturgicalID(rawValue: "our_lady_sorrows")
    static let cyprian = LiturgicalID(rawValue: "st_cyprian")
    static let ninian = LiturgicalID(rawValue: "st_ninian")
    static let stigmataOfFrancis = LiturgicalID(rawValue: "st_francis_stigmata")
    static let edwardBouveriePusey = LiturgicalID(rawValue: "blessed_edward_pusey")
    static let theodoreOfCanterbury = LiturgicalID(rawValue: "st_theodore_canterbury")
    static let johnColeridgePatteson = LiturgicalID(rawValue: "blessed_john_patteson")
    static let matthewVigil = LiturgicalID(rawValue: "st_matthew_vigil")
    static let matthew = LiturgicalID(rawValue: "st_matthew")
    static let mauriceAndCompanions = LiturgicalID(rawValue: "st_maurice")
    static let linus = LiturgicalID(rawValue: "st_linus")
    static let thecla = LiturgicalID(rawValue: "st_thecla")
    static let ourLadyOfRansom = LiturgicalID(rawValue: "our_lady_ransom")
    static let lancelotAndrewes = LiturgicalID(rawValue: "blessed_lancelot_andrewes")
    static let cosmasAndDamian = LiturgicalID(rawValue: "sts_cosmas_damian")
    static let wenceslaus = LiturgicalID(rawValue: "st_wenceslaus")
    static let michaelAndAllAngels = LiturgicalID(rawValue: "st_michael_all_angels")
    static let jerome = LiturgicalID(rawValue: "st_jerome")

    /// 尚未完成正式編碼的舊資料使用此命名空間過渡。
    /// 這只是相容層；業務規則不可新增對 `legacy.*` 的依賴。
    static func legacy(title: String) -> LiturgicalID {
        LiturgicalID(rawValue: "legacy.\(title)")
    }

    /// 一般節期週日的結構化識別碼，例如 `temporal.easter.week.5.weekday.1`。
    static func temporal(season: LiturgicalSeason, week: Int, weekday: Int) -> LiturgicalID {
        LiturgicalID(rawValue: "temporal.\(season.identifierKey).week.\(week).weekday.\(weekday)")
    }

    var temporalComponents: (season: LiturgicalSeason, week: Int, weekday: Int)? {
        let parts = rawValue.split(separator: ".")
        guard parts.count == 6,
              parts[0] == "temporal",
              parts[2] == "week",
              parts[4] == "weekday",
              let season = LiturgicalSeason(identifierKey: String(parts[1])),
              let week = Int(parts[3]),
              let weekday = Int(parts[5]) else { return nil }
        return (season, week, weekday)
    }

    /// 把現有繁體標題轉成穩定 ID。後續資料 JSON 加入 identifier 後，將逐步不再需要此表。
    static func fromLegacyTitle(_ title: String) -> LiturgicalID {
        let baseTitle: String = {
            for marker in [" (", "（"] {
                if let range = title.range(of: marker) {
                    return String(title[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                }
            }
            return title
        }()

        let exact: [String: LiturgicalID] = [
            "救主受割禮日": .circumcision,
            "顯現日": .epiphany,
            "救主顯現望日": .epiphanyVigil,
            "大齋首日": .ashWednesday,
            "復活日": .easterDay,
            "救主升天日": .ascension,
            "升天望日": .ascensionVigil,
            "升天八日慶期後禮拜五": .fridayAfterAscensionOctave,
            "聖靈降臨日": .pentecost,
            "聖靈降臨望日": .pentecostVigil,
            "三一主日": .trinitySunday,
            "三一主日後禮拜一": .trinityOctaveMonday,
            "三一主日後禮拜二": .trinityOctaveTuesday,
            "三一主日後禮拜三": .trinityOctaveWednesday,
            "基督聖體節八日慶期第八日": .corpusChristiOctaveDayEight,
            "耶穌聖心節": .sacredHeart,
            "使徒聖彼得與聖保羅日": .peterAndPaul,
            "紀念使徒聖保羅": .paulCommemoration,
            "我主基督至聖寶血": .preciousBlood,
            "施洗聖約翰誕辰日八日慶期第八日": .nativityOfJohnBaptistOctaveDayEight,
            "榮福童貞馬利亞升天日": .assumption,
            "降臨第一主日": .firstSundayOfAdvent,
            "聖誕日": .christmasDay,
            "七旬主日": .septuagesimaSunday,
            "六旬主日": .sexagesimaSunday,
            "五旬主日": .quinquagesimaSunday,
            "苦難主日": .passionSunday,
            "棕樹主日": .palmSunday,
            "升天後主日": .sundayAfterAscension,
            "基督聖體節": .corpusChristi,
            "基督聖體節八日慶期": .corpusChristiOctave,
            "三一主日後第一主日": .corpusChristiOctaveSunday,
            "三一主日後第二主日": .sacredHeartOctaveSunday,
            "耶穌聖心節八日慶期第八日": .sacredHeartOctaveDayEight,
            "基督君王節": .christTheKing,
            "降臨前主日": .sundayBeforeAdvent,
            "使徒聖巴拿巴日": .barnabas,
            "匈牙利的聖王聖司提反": .stephenOfHungary,
            "聖艾烏爾提烏斯主教": .evurtius,
            "榮福童貞女馬利亞誕辰日": .nativityOfMary,
            "聖彼得·克拉維爾": .peterClaver,
            "殉道者聖普羅托與聖海厄森斯": .protusAndHyacinth,
            "聖母聖名日": .holyNameOfMary,
            "聖十字架日": .holyCross,
            "七苦聖母": .ourLadyOfSorrows,
            "殉道者聖居普良主教": .cyprian,
            "聖尼安主教": .ninian,
            "聖法蘭西斯受五傷": .stigmataOfFrancis,
            "真福愛德華·布維萊·普西": .edwardBouveriePusey,
            "坎特伯雷的聖西奧多主教": .theodoreOfCanterbury,
            "真福約翰·科爾里奇·帕特森主教": .johnColeridgePatteson,
            "傳福音使徒聖馬太望日": .matthewVigil,
            "傳福音使徒聖馬太日": .matthew,
            "殉道者聖莫里斯及其同伴": .mauriceAndCompanions,
            "殉道者聖利奴主教": .linus,
            "童貞女聖德克拉": .thecla,
            "贖虜聖母": .ourLadyOfRansom,
            "真福蘭斯洛特·安德魯斯主教": .lancelotAndrewes,
            "殉道者聖科斯馬斯和聖達米盎": .cosmasAndDamian,
            "殉道者聖瓦茨拉夫": .wenceslaus,
            "聖米迦勒和諸天使日": .michaelAndAllAngels,
            "教會聖師、精修者聖耶柔米": .jerome
        ]

        if let identifier = exact[baseTitle] {
            return identifier
        }
        if baseTitle.contains("使徒聖彼得與聖保羅"), baseTitle.contains("第七日") {
            return .peterAndPaulOctaveDaySeven
        }
        if baseTitle.contains("榮福童貞馬利亞升天"), baseTitle.contains("第七日") {
            return .assumptionOctaveDaySeven
        }
        if baseTitle.contains("基督寶血") || baseTitle.contains("至聖寶血") {
            return .preciousBlood
        }
        if baseTitle.hasPrefix("降臨前主日") {
            return .sundayBeforeAdvent
        }
        if baseTitle.hasPrefix("聖誕後"), baseTitle.contains("主日") {
            return .sundayAfterChristmas
        }

        return .legacy(title: baseTitle)
    }
}

private extension LiturgicalSeason {
    var identifierKey: String {
        switch self {
        case .advent: return "advent"
        case .christmas: return "christmas"
        case .epiphany: return "epiphany"
        case .prelenten: return "prelenten"
        case .lent: return "lent"
        case .holyWeek: return "holy_week"
        case .easter: return "easter"
        case .ascension: return "ascension"
        case .pentecost: return "pentecost"
        case .trinity: return "trinity"
        case .holyDays: return "holy_days"
        }
    }

    init?(identifierKey: String) {
        switch identifierKey {
        case "advent": self = .advent
        case "christmas": self = .christmas
        case "epiphany": self = .epiphany
        case "prelenten": self = .prelenten
        case "lent": self = .lent
        case "holy_week": self = .holyWeek
        case "easter": self = .easter
        case "ascension": self = .ascension
        case "pentecost": self = .pentecost
        case "trinity": self = .trinity
        case "holy_days": self = .holyDays
        default: return nil
        }
    }
}
