import Foundation
import Combine

// MARK: - JSON 解析專用結構（純字串）
struct ComplineResponsoryJSON: Codable {
    let leader: String
    let people: String
}

struct ComplinePrayerSectionJSON: Codable {
    let title: String?
    let rubric: String?
    let paragraphs: [String]
    let responses: [ComplineResponsoryJSON]?
}

struct ComplinePsalmAntiphonJSON: Codable {
    let season: String
    let before: String
    let after: String
}

struct ComplineShortResponsorySetJSON: Codable {
    let title: String
    let responses: [ComplineResponsoryJSON]
}

struct ComplineCollectOptionJSON: Codable {
    let id: String
    let title: String
    let text: String
}

// MARK: - 寢前禱 JSON 根節點
struct ComplinePrayerJSON: Codable {
    let openingResponses: [ComplineResponsoryJSON]
    let shortReading: ComplinePrayerSectionJSON
    let readingResponses: [ComplineResponsoryJSON]
    let lordPrayerResponses: [ComplineResponsoryJSON]
    let psalmAntiphons: [ComplinePsalmAntiphonJSON]
    let lesson: ComplinePrayerSectionJSON
    let shortResponsesOrdinary: ComplineShortResponsorySetJSON
    let shortResponsesEaster: ComplineShortResponsorySetJSON
    let weekdayHymn: ComplinePrayerSectionJSON
    let feastHymn: ComplinePrayerSectionJSON
    let lentHymn: ComplinePrayerSectionJSON
    let easterHymn: ComplinePrayerSectionJSON
    let ascensionHymn: ComplinePrayerSectionJSON
    let pentecostHymn: ComplinePrayerSectionJSON
    let almaChorusHymn: ComplinePrayerSectionJSON
    let seasonalHymnEndings: [String: String]
    let postHymnResponsesOrdinary: [ComplineResponsoryJSON]
    let postHymnResponsesEaster: [ComplineResponsoryJSON]
    let defaultNuncDimittisAntiphon: String
    let prayersSection: ComplinePrayerSectionJSON
    let prayersResponses: [ComplineResponsoryJSON]
    let confession: ComplinePrayerSectionJSON
    let confessionNote: String
    let absolutionClergy: ComplinePrayerSectionJSON
    let postAbsolutionResponses: [ComplineResponsoryJSON]
    let collectOptions: [ComplineCollectOptionJSON]
    let commemorationSection: ComplinePrayerSectionJSON
    let commemorationResponsesBefore: [ComplineResponsoryJSON]
    let commemorationResponsesAfter: [ComplineResponsoryJSON]
    let preCollectResponses: [ComplineResponsoryJSON]
    let postCollectResponses: [ComplineResponsoryJSON]
}

// MARK: - 寢前禱資料加載器
class ComplinePrayerDataLoader {
    static let shared = ComplinePrayerDataLoader()
    private var cache: [AppLanguage: ComplinePrayerJSON] = [:]
    
    var currentLanguage: AppLanguage {
        AppLanguageStore.shared.language
    }
    
    func clearCache() { cache.removeAll() }
    
    func load(language: AppLanguage? = nil) -> ComplinePrayerJSON {
        let lang = language ?? currentLanguage
        if let cached = cache[lang] { return cached }
        
        guard let url = Bundle.main.url(forResource: "compline_prayer", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let localizedData = LocalizedJSONResolver.resolve(data: data, language: lang),
              let decoded = try? JSONDecoder().decode(ComplinePrayerJSON.self, from: localizedData) else {
            fatalError("❌ 無法載入 compline_prayer.json")
        }
        cache[lang] = decoded
        return decoded
    }
}

// MARK: - 視圖專用 UI 模型轉換器
struct ComplinePrayerData {
    private static var json: ComplinePrayerJSON { ComplinePrayerDataLoader.shared.load() }
    static var isSimplified: Bool { MorningPrayerDataLoader.shared.currentLanguage == .simplified }
    
    // 輔助轉換
    private static func map(_ r: ComplineResponsoryJSON) -> Responsory { Responsory(leader: r.leader, people: r.people) }
    private static func map(_ s: ComplinePrayerSectionJSON) -> PrayerSection {
        PrayerSection(title: s.title, rubric: s.rubric, paragraphs: s.paragraphs, responses: s.responses?.map { map($0) } ?? [])
    }
    
    // 匯出屬性
    static var openingResponses: [Responsory] { json.openingResponses.map { map($0) } }
    static var shortReading: PrayerSection { map(json.shortReading) }
    static var readingResponses: [Responsory] { json.readingResponses.map { map($0) } }
    static var lordPrayerResponses: [Responsory] { json.lordPrayerResponses.map { map($0) } }
    
    struct PsalmAntiphonUI { let season: String; let before: String; let after: String }
    static var psalmAntiphons: [PsalmAntiphonUI] {
        json.psalmAntiphons.map { PsalmAntiphonUI(season: $0.season, before: $0.before, after: $0.after) }
    }
    
    static let psalmKeys = ["詩篇 第4篇", "詩篇 第31篇", "詩篇 第91篇", "詩篇 第134篇"]
    static func psalmDisplayTitle(for key: String) -> String {
        let title = key.replacingOccurrences(of: "詩篇 第", with: "詩篇 ")
        return isSimplified ? title.replacingOccurrences(of: "詩", with: "诗") : title
    }
    static func psalmLatinSubtitle(for key: String) -> String {
        switch key {
        case "詩篇 第4篇":   return isSimplified ? "Cum invocarem（求助的晚祷）" : "Cum invocarem（求助的晚禱）"
        case "詩篇 第31篇":  return isSimplified ? "In te, Domine, speravi（信靠上帝的祈祷）" : "In te, Domine, speravi（信靠上帝的祈禱）"
        case "詩篇 第91篇":  return isSimplified ? "Qui habitat（上帝是我们的保护者）" : "Qui habitat（上帝是我們的保護者）"
        case "詩篇 第134篇": return isSimplified ? "Ecce nunc（宣召称颂）" : "Ecce nunc（宣召稱頌）"
        default: return ""
        }
    }
    
    static var lesson: PrayerSection { map(json.lesson) }
    
    struct ShortResponsorySetUI { let title: String; let responses: [Responsory]; let showGloria: Bool }
    static var shortResponsesOrdinary: ShortResponsorySetUI {
        ShortResponsorySetUI(title: json.shortResponsesOrdinary.title, responses: json.shortResponsesOrdinary.responses.map { map($0) }, showGloria: true)
    }
    static var shortResponsesEaster: ShortResponsorySetUI {
        ShortResponsorySetUI(title: json.shortResponsesEaster.title, responses: json.shortResponsesEaster.responses.map { map($0) }, showGloria: true)
    }
    
    static var weekdayHymn: PrayerSection { map(json.weekdayHymn) }
    static var feastHymn: PrayerSection { map(json.feastHymn) }
    static var lentHymn: PrayerSection { map(json.lentHymn) }
    static var easterHymn: PrayerSection { map(json.easterHymn) }
    static var ascensionHymn: PrayerSection { map(json.ascensionHymn) }
    static var pentecostHymn: PrayerSection { map(json.pentecostHymn) }
    static var almaChorusHymn: PrayerSection { map(json.almaChorusHymn) }
    
    static var postHymnResponsesOrdinary: [Responsory] { json.postHymnResponsesOrdinary.map { map($0) } }
    static var postHymnResponsesEaster: [Responsory] { json.postHymnResponsesEaster.map { map($0) } }
    static var defaultNuncDimittisAntiphon: String { json.defaultNuncDimittisAntiphon }
    
    static var prayersSection: PrayerSection { map(json.prayersSection) }
    static var prayersResponses: [Responsory] { json.prayersResponses.map { map($0) } }
    
    static var confession: PrayerSection { map(json.confession) }
    static var confessionNote: String { json.confessionNote }
    static var absolutionClergy: PrayerSection { map(json.absolutionClergy) }
    static var postAbsolutionResponses: [Responsory] { json.postAbsolutionResponses.map { map($0) } }
    
    struct CollectOption { let id: String; let title: String; let text: String }
    static var collectOptions: [CollectOption] {
        json.collectOptions.map { CollectOption(id: $0.id, title: $0.title, text: $0.text) }
    }
    
    static var commemorationSection: PrayerSection { map(json.commemorationSection) }
    static var commemorationResponsesBefore: [Responsory] { json.commemorationResponsesBefore.map { map($0) } }
    static var commemorationResponsesAfter: [Responsory] { json.commemorationResponsesAfter.map { map($0) } }
    
    static var preCollectResponses: [Responsory] { json.preCollectResponses.map { map($0) } }
    static var postCollectResponses: [Responsory] { json.postCollectResponses.map { map($0) } }
}
