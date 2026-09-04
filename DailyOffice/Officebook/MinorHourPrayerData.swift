import Foundation

enum MinorHour: String, CaseIterable {
    case terce
    case sext
    case nona

    var resourceName: String { "\(rawValue)_prayer" }

    var traditionalTitle: String {
        switch self {
        case .terce: return "三時禱"
        case .sext: return "六時禱"
        case .nona: return "九時禱"
        }
    }

    var simplifiedTitle: String {
        switch self {
        case .terce: return "三时祷"
        case .sext: return "六时祷"
        case .nona: return "九时祷"
        }
    }

    func title(isSimplified: Bool) -> String {
        isSimplified ? simplifiedTitle : traditionalTitle
    }

    func spacedTitle(isSimplified: Bool) -> String {
        let numeral: String
        switch self {
        case .terce: numeral = "三"
        case .sext: numeral = "六"
        case .nona: numeral = "九"
        }
        return isSimplified ? "\(numeral)  时  祷" : "\(numeral)  時  禱"
    }

    func endingText(isSimplified: Bool) -> String {
        "❦ \(title(isSimplified: isSimplified))至此\(isSimplified ? "结束" : "結束")。"
    }

    var psalmNumbers: [Int] {
        switch self {
        case .terce: return [120, 121, 122]
        case .sext: return [123, 124, 125]
        case .nona: return [126, 127, 128]
        }
    }
}

struct MinorHourResponsoryJSON: Codable {
    let leader: String
    let people: String
}

struct MinorHourPrayerSectionJSON: Codable {
    let title: String?
    let rubric: String?
    let paragraphs: [String]
    let responses: [MinorHourResponsoryJSON]?
}

struct MinorHourPsalmAntiphonJSON: Codable {
    let season: String
    let text: String
    let fullText: String
}

struct MinorHourShortResponsorySetJSON: Codable {
    let title: String
    let responses: [MinorHourResponsoryJSON]
}

struct MinorHourReadingItemJSON: Codable {
    let season: String
    let content: String
    let reference: String
}

struct MinorHourPrayerJSON: Codable {
    let openingNote: String?
    let openingResponses: [MinorHourResponsoryJSON]
    let hymn: MinorHourPrayerSectionJSON
    let pentecostHymn: MinorHourPrayerSectionJSON?
    let seasonalHymnEndings: [String: String]
    let bvmFeastAntiphon: String
    let psalmAntiphons: [MinorHourPsalmAntiphonJSON]
    let readings: [MinorHourReadingItemJSON]
    let shortResponsesOrdinary: MinorHourShortResponsorySetJSON
    let shortResponsesFeastEaster: MinorHourShortResponsorySetJSON
    let shortResponsesFeastOrdinary: MinorHourShortResponsorySetJSON
    let prayersSection: MinorHourPrayerSectionJSON
    let prayersResponses: [MinorHourResponsoryJSON]
    let collectOpening: [MinorHourResponsoryJSON]
    let dailyCollectText: String?
    let sextMemorialCollect: MinorHourPrayerSectionJSON?
    let nonaMemorialCollect: MinorHourPrayerSectionJSON?
    let collectEndingResponses: [MinorHourResponsoryJSON]
    let closingText: MinorHourPrayerSectionJSON
}

final class MinorHourPrayerDataLoader {
    static let shared = MinorHourPrayerDataLoader()

    private var cache: [String: MinorHourPrayerJSON] = [:]
    private init() {}

    func clearCache() {
        cache.removeAll()
    }

    func load(hour: MinorHour, language: AppLanguage? = nil) -> MinorHourPrayerJSON {
        let lang = language ?? AppLanguageStore.shared.language
        let cacheKey = "\(hour.rawValue)|\(lang.rawValue)"
        if let cached = cache[cacheKey] { return cached }

        guard let url = Bundle.main.url(forResource: hour.resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let localizedData = LocalizedJSONResolver.resolve(data: data, language: lang),
              let decoded = try? JSONDecoder().decode(MinorHourPrayerJSON.self, from: localizedData) else {
            fatalError("❌ 無法載入 \(hour.resourceName).json")
        }
        cache[cacheKey] = decoded
        return decoded
    }
}

@MainActor
extension MinorHourPrayerJSON {
    var openingResponsories: [Responsory] { openingResponses.map(Responsory.init) }
    var prayerResponsories: [Responsory] { prayersResponses.map(Responsory.init) }
    var collectOpeningResponsories: [Responsory] { collectOpening.map(Responsory.init) }
    var collectEndingResponsories: [Responsory] { collectEndingResponses.map(Responsory.init) }

    var hymnSection: PrayerSection { hymn.asPrayerSection }
    var pentecostHymnSection: PrayerSection? { pentecostHymn?.asPrayerSection }
    var prayers: PrayerSection { prayersSection.asPrayerSection }
    var closing: PrayerSection { closingText.asPrayerSection }
    var memorialCollect: PrayerSection? {
        (sextMemorialCollect ?? nonaMemorialCollect)?.asPrayerSection
    }
}

@MainActor
extension MinorHourPrayerSectionJSON {
    var asPrayerSection: PrayerSection {
        PrayerSection(
            title: title,
            rubric: rubric,
            paragraphs: paragraphs,
            responses: responses?.map(Responsory.init) ?? []
        )
    }
}

extension Responsory {
    init(_ json: MinorHourResponsoryJSON) {
        self.init(leader: json.leader, people: json.people)
    }
}

@MainActor
extension MinorHourShortResponsorySetJSON {
    var uiResponses: [Responsory] { responses.map(Responsory.init) }
}

enum MinorHourPrayerRules {
    static func isBVMFeast(liturgy: DailyLiturgy) -> Bool {
        liturgy.traits.themes.contains(.blessedVirginMary)
    }

    static func psalmKeys(hour: MinorHour, date: Date) -> [String] {
        let numbers = hour.psalmNumbers
        let weekday = Calendar.current.component(.weekday, from: date)
        let selected: [Int]
        switch weekday {
        case 1: selected = numbers
        case 2, 5: selected = [numbers[0]]
        case 3, 6: selected = [numbers[1]]
        case 4, 7: selected = [numbers[2]]
        default: selected = [numbers[0]]
        }
        return selected.map { "詩篇 第\($0)篇" }
    }

    static func psalmDisplayTitle(for key: String, isSimplified: Bool) -> String {
        let title = key.replacingOccurrences(of: "詩篇 第", with: "詩篇 ")
        return isSimplified ? title.replacingOccurrences(of: "詩", with: "诗") : title
    }

    static func hymnEndingKey(for date: Date, liturgy: DailyLiturgy) -> String? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        let themes = liturgy.traits.themes
        if themes.contains(.sacredHeart) { return "sacred_heart" }
        if themes.contains(.transfiguration) { return "transfiguration" }
        if liturgy.identifier == .christTheKing || themes.contains(.christTheKing) { return "christ_the_king" }
        if themes.contains(.blessedVirginMary) { return "bvm" }
        if info.season == .ascension { return "ascensiontide" }
        if [.easter, .pentecost].contains(info.season) { return "eastertide" }
        if info.season == .epiphany && info.weekNumber == 1 { return "epiphany_octave" }
        if info.season == .christmas { return "christmas_to_purification" }
        return nil
    }

    static func hymnVerses(data: MinorHourPrayerJSON, date: Date, liturgy: DailyLiturgy) -> [String] {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        if (49...55).contains(info.daysFromEaster), let pentecost = data.pentecostHymn {
            return pentecost.paragraphs
        }
        guard let key = hymnEndingKey(for: date, liturgy: liturgy),
              let ending = data.seasonalHymnEndings[key],
              !data.hymn.paragraphs.isEmpty else { return data.hymn.paragraphs }
        var verses = data.hymn.paragraphs
        let prefix = chineseNumberPrefix(verses.removeLast())
        verses.append(prefix.isEmpty ? ending : prefix + ending)
        return verses
    }

    static func chineseNumberPrefix(_ text: String) -> String {
        let digits = "一二三四五六七八九十"
        var prefix = ""
        for character in text {
            if digits.contains(character) { prefix.append(character) }
            else if character == "、" && !prefix.isEmpty { prefix.append(character); return prefix }
            else { break }
        }
        return prefix
    }
}
