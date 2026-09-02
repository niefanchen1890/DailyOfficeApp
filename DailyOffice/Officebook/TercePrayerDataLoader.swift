import Foundation
import Combine

// MARK: - JSON 解析專用結構（純字串，因 LocalizedJSONResolver 已經壓平）
struct TerceResponsoryJSON: Codable {
    let leader: String
    let people: String
}

struct TercePrayerSectionJSON: Codable {
    let title: String?
    let rubric: String?
    let paragraphs: [String]
    let responses: [TerceResponsoryJSON]?
}

struct TercePsalmAntiphonJSON: Codable {
    let season: String
    let text: String
    let fullText: String
}

struct TerceShortResponsorySetJSON: Codable {
    let title: String
    let responses: [TerceResponsoryJSON]
}

struct TerceReadingItemJSON: Codable {
    let season: String
    let content: String
    let reference: String
}

// MARK: - 三時禱 JSON 根節點
struct TercePrayerJSON: Codable {
    let openingResponses: [TerceResponsoryJSON]
    let hymn: TercePrayerSectionJSON
    let pentecostHymn: TercePrayerSectionJSON
    let seasonalHymnEndings: [String: String]
    let bvmFeastAntiphon: String
    let psalmAntiphons: [TercePsalmAntiphonJSON]
    let readings: [TerceReadingItemJSON]
    let shortResponsesOrdinary: TerceShortResponsorySetJSON
    let shortResponsesFeastEaster: TerceShortResponsorySetJSON
    let shortResponsesFeastOrdinary: TerceShortResponsorySetJSON
    let prayersSection: TercePrayerSectionJSON
    let prayersResponses: [TerceResponsoryJSON]
    let collectOpening: [TerceResponsoryJSON]
    let dailyCollectText: String
    let collectEndingResponses: [TerceResponsoryJSON]
    let closingText: TercePrayerSectionJSON
}

// MARK: - 三時禱資料加載器
class TercePrayerDataLoader {
    static let shared = TercePrayerDataLoader()
    
    private var cache: [AppLanguage: TercePrayerJSON] = [:]
    
    var currentLanguage: AppLanguage {
        let code = UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.traditional.rawValue
        return AppLanguage(rawValue: code) ?? .traditional
    }
    
    func clearCache() {
        cache.removeAll()
    }
    
    func load(language: AppLanguage? = nil) -> TercePrayerJSON {
        let lang = language ?? currentLanguage
        if let cached = cache[lang] { return cached }
        
        guard let url = Bundle.main.url(forResource: "terce_prayer", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let localizedData = LocalizedJSONResolver.resolve(data: data, language: lang),
              let decoded = try? JSONDecoder().decode(TercePrayerJSON.self, from: localizedData) else {
            fatalError("❌ 無法載入 terce_prayer.json")
        }
        cache[lang] = decoded
        return decoded
    }
}

// MARK: - 視圖專用 UI 模型轉換器
struct TercePrayerData {
    private static var json: TercePrayerJSON { TercePrayerDataLoader.shared.load() }
    
    // 輔助轉換
    private static func map(_ r: TerceResponsoryJSON) -> Responsory {
        Responsory(leader: r.leader, people: r.people)
    }
    
    private static func map(_ s: TercePrayerSectionJSON) -> PrayerSection {
        PrayerSection(title: s.title, rubric: s.rubric, paragraphs: s.paragraphs, responses: s.responses?.map { map($0) } ?? [])
    }
    
    // 對外暴露的 UI 資料
    static var openingResponses: [Responsory] { json.openingResponses.map { map($0) } }
    static var hymn: PrayerSection { map(json.hymn) }
    static var pentecostHymn: PrayerSection { map(json.pentecostHymn) }
    static var readings: [TerceReadingItemJSON] { json.readings }
    
    static var prayersSection: PrayerSection { map(json.prayersSection) }
    static var prayersResponses: [Responsory] { json.prayersResponses.map { map($0) } }
    static var collectOpening: [Responsory] { json.collectOpening.map { map($0) } }
    static var dailyCollectText: String { json.dailyCollectText }
    static var collectEndingResponses: [Responsory] { json.collectEndingResponses.map { map($0) } }
    static var closingText: PrayerSection { map(json.closingText) }

    struct PsalmAntiphonUI {
        let season: String
        let text: String
        let fullText: String
    }
    
    static var psalmAntiphons: [PsalmAntiphonUI] {
        json.psalmAntiphons.map { PsalmAntiphonUI(season: $0.season, text: $0.text, fullText: $0.fullText) }
    }
    
    struct ShortResponsorySetUI {
        let title: String
        let responses: [Responsory]
    }
    
    static var shortResponsesOrdinary: ShortResponsorySetUI {
        ShortResponsorySetUI(title: json.shortResponsesOrdinary.title, responses: json.shortResponsesOrdinary.responses.map { map($0) })
    }
    static var shortResponsesFeastEaster: ShortResponsorySetUI {
        ShortResponsorySetUI(title: json.shortResponsesFeastEaster.title, responses: json.shortResponsesFeastEaster.responses.map { map($0) })
    }
    static var shortResponsesFeastOrdinary: ShortResponsorySetUI {
        ShortResponsorySetUI(title: json.shortResponsesFeastOrdinary.title, responses: json.shortResponsesFeastOrdinary.responses.map { map($0) })
    }

    struct BVMFeastAntiphon {
        static var text: String { TercePrayerData.json.bvmFeastAntiphon }
        static let feastNames: [String] = [
            "加羅默爾聖母", "聖母聖名日", "七苦聖母", "贖虜聖母",
            "聖母玫瑰", "沃爾辛厄姆聖母", "建立聖母雪地大殿", "露德聖母"
        ]
        static func isBVMFeast(title: String) -> Bool {
            feastNames.contains { title.contains($0) }
        }
    }

    static func psalmKeys(for date: Date) -> [String] {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: return ["詩篇 第120篇", "詩篇 第121篇", "詩篇 第122篇"]
        case 2, 5: return ["詩篇 第120篇"]
        case 3, 6: return ["詩篇 第121篇"]
        case 4, 7: return ["詩篇 第122篇"]
        default: return ["詩篇 第120篇"]
        }
    }

    static func psalmDisplayTitle(for key: String, isSimplified: Bool) -> String {
        let title = key.replacingOccurrences(of: "詩篇 第", with: "詩篇 ")
        return isSimplified ? title.replacingOccurrences(of: "詩", with: "诗") : title
    }

    struct SeasonalHymnEnding {
        static func endingKey(for date: Date, liturgy: DailyLiturgy) -> String? {
            let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
            let season = info.season
            let weekNumber = info.weekNumber
            let title = liturgy.mainTitle

            if title.contains("耶穌聖心節") || title.contains("聖心節") { return "sacred_heart" }
            if title.contains("基督易容") || title.contains("易容顯光") { return "transfiguration" }
            if title.contains("基督普世君王") || title.contains("普世君王節") { return "christ_the_king" }
            if title.contains("童貞") || title.contains("聖母") || title.contains("馬利亞") { return "bvm" }
            if season == .ascension || title.contains("升天") { return "ascensiontide" }
            if [.easter, .pentecost].contains(season) || title.contains("復活") || title.contains("聖靈降臨") { return "eastertide" }
            if season == .epiphany && weekNumber == 1 { return "epiphany_octave" }
            if season == .christmas || title.contains("聖誕") || title.contains("主顯") { return "christmas_to_purification" }
            return nil
        }

        static func assemble(baseVerses: [String], for date: Date, liturgy: DailyLiturgy) -> [String] {
            guard let key = endingKey(for: date, liturgy: liturgy),
                  let ending = TercePrayerData.json.seasonalHymnEndings[key],
                  !baseVerses.isEmpty else {
                return baseVerses
            }

            var verses = baseVerses
            let lastVerse = verses.last!
            let prefix = extractChineseNumberPrefix(lastVerse)
            verses.removeLast()

            let newEnding = prefix.isEmpty ? ending : prefix + ending
            verses.append(newEnding)

            return verses
        }

        private static func extractChineseNumberPrefix(_ text: String) -> String {
            let chineseDigits = "一二三四五六七八九十"
            var prefix = ""
            for char in text {
                if chineseDigits.contains(char) { prefix.append(char) }
                else if char == "、" && !prefix.isEmpty { prefix.append(char); return prefix }
                else { break }
            }
            return prefix
        }
    }
}
