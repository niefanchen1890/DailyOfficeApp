import Foundation
import Combine

// MARK: - 專屬雙語 JSON 解析模型 (隔離命名空間，避免與早禱衝突)
struct PrimeBilingualText: Codable, Hashable {
    let zhHant: String
    let zhHans: String
    
    enum CodingKeys: String, CodingKey {
        case zhHant = "zh-hant"
        case zhHans = "zh-hans"
    }
    
    func text(isSimplified: Bool) -> String {
        return isSimplified ? zhHans : zhHant
    }
}

struct PrimeResponsoryJSON: Codable {
    let leader: PrimeBilingualText
    let people: PrimeBilingualText
}

struct PrimePrayerSectionJSON: Codable {
    let title: PrimeBilingualText?
    let rubric: PrimeBilingualText?
    let paragraphs: [PrimeBilingualText]
    let responses: [PrimeResponsoryJSON]
}

struct PrimeReadingItemJSON: Codable {
    let season: PrimeBilingualText
    let content: PrimeBilingualText
    let reference: PrimeBilingualText
}

struct PrimePsalmAntiphonJSON: Codable {
    let season: PrimeBilingualText
    let text: PrimeBilingualText
}

struct PrimeShortResponsorySetJSON: Codable {
    let title: PrimeBilingualText
    let opening: PrimeResponsoryJSON
    let seasonal: PrimeResponsoryJSON
    let common: [PrimeResponsoryJSON]
}

// MARK: - 一時禱 JSON 根節點
struct PrimePrayerJSON: Codable {
    let openingNote: PrimeBilingualText
    let openingResponses: [PrimeResponsoryJSON]
    let hymn: PrimePrayerSectionJSON
    let bvmFeastAntiphon: PrimeBilingualText
    let psalmAntiphons: [PrimePsalmAntiphonJSON]
    let readings: [PrimeReadingItemJSON]
    let shortResponsesOutsideEaster: [PrimeShortResponsorySetJSON]
    let shortResponsesInsideEaster: [PrimeShortResponsorySetJSON]
    let prayersOpening: PrimePrayerSectionJSON
    let prayersResponses1: [PrimeResponsoryJSON]
    let confession: PrimePrayerSectionJSON
    let confessionNote: PrimeBilingualText
    let absolution: PrimePrayerSectionJSON
    let prayersResponses2: [PrimeResponsoryJSON]
    let collectOpening: [PrimeResponsoryJSON]
    let collect1: PrimePrayerSectionJSON
    let collect2: PrimePrayerSectionJSON
    let collectEndingResponses: [PrimeResponsoryJSON]
    let closingText: PrimePrayerSectionJSON
    let martyrology: PrimePrayerSectionJSON
    let martyrologyClosing: [PrimeResponsoryJSON]
    let martyrologyKyrie: PrimeBilingualText
    let martyrologyLordPrayerNote: PrimeBilingualText
    let martyrologyLordPrayerText: PrimeBilingualText
    let martyrologyEndingResponses: [PrimeResponsoryJSON]
    let martyrologyCollect: PrimeBilingualText
    let martyrologyFinalResponse: PrimeResponsoryJSON
    let commemorationOpening: PrimeResponsoryJSON
    let commemorationResponses: [PrimeResponsoryJSON]
    let commemorationPrayer: PrimePrayerSectionJSON
    let commemorationClosing: [PrimeResponsoryJSON]
    let seasonalHymnEndings: [String: PrimeBilingualText]
}

// MARK: - 一時禱資料加載器
class PrimePrayerDataLoader: ObservableObject {
    static let shared = PrimePrayerDataLoader()
    
    @Published var data: PrimePrayerJSON
    
    init() {
        guard let url = Bundle.main.url(forResource: "prime_prayer", withExtension: "json"),
              let fileData = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(PrimePrayerJSON.self, from: fileData) else {
            fatalError("❌ 無法載入 prime_prayer.json，請檢查文件是否存在且格式正確")
        }
        self.data = decoded
    }
}

// MARK: - 視圖專用 UI 模型轉換器
struct PrimePrayerData {
    
    // 🌟 直接讀取全局語系，與早禱同步
    static var isSimplified: Bool {
        return AppLanguageStore.shared.isSimplified
    }
    
    static var data: PrimePrayerJSON {
        PrimePrayerDataLoader.shared.data
    }
    
    // 輔助函式：將 JSON 的 Responsory 轉為 UI Responsory (使用 MorningPrayerData 的 Responsory)
    private static func mapResponsory(_ json: PrimeResponsoryJSON) -> Responsory {
        return Responsory(
            leader: json.leader.text(isSimplified: isSimplified),
            people: json.people.text(isSimplified: isSimplified)
        )
    }
    
    // 輔助函式：將 JSON 的 PrayerSection 轉為 UI PrayerSection
    private static func mapPrayerSection(_ json: PrimePrayerSectionJSON) -> PrayerSection {
        return PrayerSection(
            title: json.title?.text(isSimplified: isSimplified),
            rubric: json.rubric?.text(isSimplified: isSimplified),
            paragraphs: json.paragraphs.map { $0.text(isSimplified: isSimplified) },
            responses: json.responses.map { mapResponsory($0) }
        )
    }
    
    // MARK: - 對外暴露的 UI 資料
    static var openingNote: String { data.openingNote.text(isSimplified: isSimplified) }
    static var openingResponses: [Responsory] { data.openingResponses.map { mapResponsory($0) } }
    static var hymn: PrayerSection { mapPrayerSection(data.hymn) }
    
    struct BVMFeastAntiphon {
        static var text: String { PrimePrayerData.data.bvmFeastAntiphon.text(isSimplified: isSimplified) }
        static let feastNames: [String] = [
            "加羅默爾聖母", "聖母聖名日", "七苦聖母", "贖虜聖母",
            "聖母玫瑰", "沃爾辛厄姆聖母", "建立聖母雪地大殿", "露德聖母"
        ]
        static func isBVMFeast(title: String) -> Bool {
            feastNames.contains { title.contains($0) }
        }
    }
    
    struct PsalmAntiphonUI: Hashable {
        let season: String
        let text: String
    }
    
    static var psalmAntiphons: [PsalmAntiphonUI] {
        data.psalmAntiphons.map {
            PsalmAntiphonUI(
                season: $0.season.text(isSimplified: isSimplified),
                text: $0.text.text(isSimplified: isSimplified)
            )
        }
    }
    
    static let psalm54Key = "詩篇 第54篇"
    static let psalm119Group1 = ["詩篇 第119篇（1-8）", "詩篇 第119篇（9-16）"]
    static let psalm119Group2 = ["詩篇 第119篇（17-24）", "詩篇 第119篇（25-32）"]
    static let psalm119Group3 = ["詩篇 第119篇（33-40）", "詩篇 第119篇（41-48）"]

    static func psalm119Keys(for date: Date) -> [String] {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: return psalm119Group1 + psalm119Group2 + psalm119Group3
        case 2, 5: return psalm119Group1
        case 3, 6: return psalm119Group2
        case 4, 7: return psalm119Group3
        default: return psalm119Group1
        }
    }
    
    struct PrimeReadingItemUI: Hashable {
        let season: String
        let content: String
        let reference: String
    }
    
    struct PrimeReadingsLoader {
        static let shared = PrimeReadingsLoader()
        func item(for season: String) -> PrimeReadingItemUI? {
            // 比對繁體字串確保邏輯匹配
            if let jsonItem = PrimePrayerData.data.readings.first(where: { $0.season.zhHant == season }) {
                return PrimeReadingItemUI(
                    season: jsonItem.season.text(isSimplified: isSimplified),
                    content: jsonItem.content.text(isSimplified: isSimplified),
                    reference: jsonItem.reference.text(isSimplified: isSimplified)
                )
            }
            return nil
        }
    }
    
    struct ShortResponsorySetUI: Hashable {
        let title: String
        let opening: Responsory
        let seasonal: Responsory
        let common: [Responsory]
    }
    
    private static func mapShortResponsorySet(_ json: PrimeShortResponsorySetJSON) -> ShortResponsorySetUI {
        return ShortResponsorySetUI(
            title: json.title.text(isSimplified: isSimplified),
            opening: mapResponsory(json.opening),
            seasonal: mapResponsory(json.seasonal),
            common: json.common.map { mapResponsory($0) }
        )
    }
    
    static var shortResponsesOutsideEaster: [ShortResponsorySetUI] { data.shortResponsesOutsideEaster.map { mapShortResponsorySet($0) } }
    static var shortResponsesInsideEaster: [ShortResponsorySetUI] { data.shortResponsesInsideEaster.map { mapShortResponsorySet($0) } }
    
    static var prayersOpening: PrayerSection { mapPrayerSection(data.prayersOpening) }
    static var prayersResponses1: [Responsory] { data.prayersResponses1.map { mapResponsory($0) } }
    static var confession: PrayerSection { mapPrayerSection(data.confession) }
    static var confessionNote: String { data.confessionNote.text(isSimplified: isSimplified) }
    static var absolution: PrayerSection { mapPrayerSection(data.absolution) }
    static var prayersResponses2: [Responsory] { data.prayersResponses2.map { mapResponsory($0) } }
    
    static var collectOpening: [Responsory] { data.collectOpening.map { mapResponsory($0) } }
    static var collect1: PrayerSection { mapPrayerSection(data.collect1) }
    static var collect2: PrayerSection { mapPrayerSection(data.collect2) }
    static var collectEndingResponses: [Responsory] { data.collectEndingResponses.map { mapResponsory($0) } }
    static var closingText: PrayerSection { mapPrayerSection(data.closingText) }
    
    static var martyrology: PrayerSection { mapPrayerSection(data.martyrology) }
    static var martyrologyClosing: [Responsory] { data.martyrologyClosing.map { mapResponsory($0) } }
    static var martyrologyKyrie: String { data.martyrologyKyrie.text(isSimplified: isSimplified) }
    static var martyrologyLordPrayerNote: String { data.martyrologyLordPrayerNote.text(isSimplified: isSimplified) }
    static var martyrologyLordPrayerText: String { data.martyrologyLordPrayerText.text(isSimplified: isSimplified) }
    static var martyrologyEndingResponses: [Responsory] { data.martyrologyEndingResponses.map { mapResponsory($0) } }
    static var martyrologyCollect: String { data.martyrologyCollect.text(isSimplified: isSimplified) }
    static var martyrologyFinalResponse: Responsory { mapResponsory(data.martyrologyFinalResponse) }
    
    static var commemorationOpening: Responsory { mapResponsory(data.commemorationOpening) }
    static var commemorationResponses: [Responsory] { data.commemorationResponses.map { mapResponsory($0) } }
    static var commemorationPrayer: PrayerSection { mapPrayerSection(data.commemorationPrayer) }
    static var commemorationClosing: [Responsory] { data.commemorationClosing.map { mapResponsory($0) } }
    
    struct SeasonalHymnEnding {
        static func endingKey(for date: Date, liturgy: DailyLiturgy) -> String? {
            let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
            let season = info.season
            let weekNumber = info.weekNumber
            let title = liturgy.mainTitle
            
            if title.contains("耶穌聖心節") || title.contains("聖心節") { return "sacred_heart" }
            if title.contains("基督易容") || title.contains("易容顯光") || title.contains("基督易容顯光日") { return "transfiguration" }
            if title.contains("基督普世君王") || title.contains("普世君王節") { return "christ_the_king" }
            if title.contains("童貞") || title.contains("聖母") || title.contains("馬利亞") { return "bvm" }
            if season == .ascension || title.contains("升天") { return "ascensiontide" }
            if [.easter, .pentecost].contains(season) || title.contains("復活") || title.contains("聖靈降臨") { return "eastertide" }
            if season == .epiphany && weekNumber == 1 { return "epiphany_octave" }
            if season == .christmas || title.contains("聖誕") || title.contains("主顯") { return "christmas_to_purification" }
            return nil
        }
        
        static func assemble(baseVerses: [String], for date: Date, liturgy: DailyLiturgy, isSimplified: Bool) -> [String] {
            guard let key = endingKey(for: date, liturgy: liturgy),
                  let endingBilingual = PrimePrayerData.data.seasonalHymnEndings[key],
                  !baseVerses.isEmpty else {
                return baseVerses
            }
            
            let ending = endingBilingual.text(isSimplified: isSimplified)
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
                if chineseDigits.contains(char) {
                    prefix.append(char)
                } else if char == "、" && !prefix.isEmpty {
                    prefix.append(char)
                    return prefix
                } else {
                    break
                }
            }
            return prefix
        }
    }
}

// MARK: - 亞他拿修信經 (橋接從外部加載器載入)
extension PrimePrayerData {
    static var athanasianCreed: PrayerSection {
        let lang = isSimplified ? AppLanguage.simplified : AppLanguage.traditional
        
        // 🌟 修正編譯錯誤：使用明確的 if let 解包，取代可選鏈與 compactMap
        if let creedData = CreedsDataLoader.shared.athanasianCreed {
            return PrayerSection(
                title: creedData.title.text(for: lang),
                rubric: creedData.rubric.text(for: lang),
                paragraphs: creedData.paragraphs.map { $0.text(for: lang) },
                responses: []
            )
        }
        
        // 兜底預設值
        return PrayerSection(
            title: isSimplified ? "圣亚他那修信经" : "聖亞他那修信經",
            rubric: "",
            paragraphs: [],
            responses: []
        )
    }
    
    static func shouldShowAthanasianCreed(for date: Date) -> Bool {
        return CreedsDataLoader.shouldShowAthanasianCreed(for: date)
    }
}

// MARK: - 殉道錄 JSON 雙語解析模型
struct MartyrologyItemJSON: Codable {
    let zhHant: String
    let zhHans: String
    let en: String? // 預留英文欄位
    
    enum CodingKeys: String, CodingKey {
        case zhHant = "zh-hant"
        case zhHans = "zh-hans"
        case en
    }
    
    // 根據設定返回對應語言
    func text(isSimplified: Bool) -> String {
        return isSimplified ? zhHans : zhHant
    }
}

// MARK: - 殉道錄載入器 (martyrologyMMdd.json)
struct MartyrologyLoader {
    static let shared = MartyrologyLoader()
    
    // 🌟 1. 定義通用望日規則模型
    private struct VigilRule {
        let month: Int
        let normalDay: Int // 原本標準的望日日期
        let textHant: String
        let textHans: String
    }
    
    // 🌟 2. 集中管理所有需要「遇主日提前至週六」的望日
    // 只要在這裡新增一行，程式就會自動處理它的提前與省略邏輯
    private let vigilRules: [VigilRule] = [
        VigilRule(month: 2, normalDay: 23, textHant: "使徒聖馬提亞望日。", textHans: "使徒圣马提亚望日。"),
        VigilRule(month: 6, normalDay: 23, textHant: "施洗聖約翰誕辰望日。", textHans: "施洗圣约翰诞辰望日。"),
        VigilRule(month: 6, normalDay: 28, textHant: "使徒聖彼得與聖保羅望日。", textHans: "使徒圣彼得与圣保罗望日。"),
        VigilRule(month: 7, normalDay: 24, textHant: "使徒聖雅各望日。", textHans: "使徒圣雅各望日。"),
        VigilRule(month: 8, normalDay: 9, textHant: "聖勞倫斯望日。", textHans: "圣劳伦斯望日。"),
        VigilRule(month: 8, normalDay: 14, textHant: "榮福童貞馬利亞升天望日。", textHans: "荣福童贞马利亚升天望日。"),
        VigilRule(month: 8, normalDay: 23, textHant: "使徒聖巴多羅買望日。", textHans: "使徒圣巴多罗买望日。"),
        VigilRule(month: 9, normalDay: 20, textHant: "傳福音使徒聖馬太望日。", textHans: "传福音使徒圣马太望日。"),
        VigilRule(month: 10, normalDay: 27, textHant: "使徒聖西門與聖猶大望日。", textHans: "使徒圣西门与圣犹大望日。"),
        VigilRule(month: 10, normalDay: 31, textHant: "諸聖日望日。", textHans: "诸圣日望日。"),
        VigilRule(month: 11, normalDay: 29, textHant: "使徒聖安得烈望日。", textHans: "使徒圣安得烈望日。"),
        VigilRule(month: 12, normalDay: 20, textHant: "使徒聖多馬望日。", textHans: "使徒圣多马望日。")
    ]
    
    func entries(for date: Date) -> [String] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let filename = String(format: "martyrology%02d%02d", month, day)
        
        let isSimplified = AppLanguageStore.shared.isSimplified
        
        var result: [String] = []
        if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([MartyrologyItemJSON].self, from: data) {
            
            // 將雙語 JSON 陣列直接 map 為當前語系的字串陣列
            result = decoded.map { $0.text(isSimplified: isSimplified) }
        }
        
        // 🌟 交給通用函數處理
        result = processAllVigils(entries: result, for: date, isSimplified: isSimplified)
        return result
    }
    
    // 🌟 3. 處理所有望日的動態判定
    private func processAllVigils(entries: [String], for date: Date, isSimplified: Bool) -> [String] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: date)
        let currentDay = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        
        var processedEntries = entries
        
        // 步驟 A：先將 JSON 中可能寫死的望日宣告全部清除，確保畫面乾淨，完全交由程式動態判定
        for rule in vigilRules {
            processedEntries.removeAll { $0 == rule.textHant || $0 == rule.textHans }
        }
        
        // 步驟 B：檢查今天的日期是否符合任何一個計算後的望日
        for rule in vigilRules {
            // 如果月份不對，直接跳過，節省效能
            guard currentMonth == rule.month else { continue }
            
            // 計算該望日在今年是否為主日
            guard let normalVigilDate = calendar.date(from: DateComponents(year: year, month: rule.month, day: rule.normalDay, hour: 12)) else { continue }
            let isSunday = calendar.component(.weekday, from: normalVigilDate) == 1
            
            // 決定今年實際的望日日期（遇主日則提前一天）
            let actualVigilDay = isSunday ? (rule.normalDay - 1) : rule.normalDay
            
            // 如果今天就是這個實際的望日，則插入宣告
            if currentDay == actualVigilDay {
                let targetEntry = isSimplified ? rule.textHans : rule.textHant
                let insertIndex = processedEntries.isEmpty ? 0 : 1
                processedEntries.insert(targetEntry, at: insertIndex)
            }
        }
        
        return processedEntries
    }
    
    // 🌟 用於年度歸檔/日曆顯示
    func availableDatesByMonth(forYear year: Int) -> [(month: Int, monthName: String, days: [Int])] {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            return []
        }
        
        let formatter = DateFormatter()
        let isSimplified = AppLanguageStore.shared.isSimplified
        formatter.locale = Locale(identifier: isSimplified ? "zh_Hans" : "zh_Hant")
        
        var monthDays: [Int: [Int]] = [:]
        
        for url in urls {
            let filename = url.lastPathComponent
            guard filename.hasPrefix("martyrology"), filename.hasSuffix(".json") else { continue }
            
            let digits = filename.dropFirst("martyrology".count).dropLast(".json".count)
            guard digits.count == 4,
                  let month = Int(digits.prefix(2)),
                  let day = Int(digits.suffix(2)) else {
                continue
            }
            monthDays[month, default: []].append(day)
        }
        
        return (1...12).compactMap { month in
            guard let days = monthDays[month], !days.isEmpty else { return nil }
            return (
                month: month,
                monthName: formatter.monthSymbols[month - 1],
                days: days.sorted()
            )
        }
    }
}



// MARK: - 讀經版本選擇
enum PrimeReadingOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日與瞻禮日"
    case easter = "復活節期"
    
    func localizedTitle(isSimplified: Bool) -> String {
        switch self {
        case .ordinary: return isSimplified ? "全年平日" : "全年平日"
        case .feast: return isSimplified ? "主日与瞻礼日" : "主日與瞻禮日"
        case .easter: return isSimplified ? "复活节期" : "復活節期"
        }
    }
}

// MARK: - 祈禱顯示選擇
enum PrimePrayerOption: String, CaseIterable, Hashable {
    case show = "顯示"
    case omit = "省略"
    
    func localizedTitle(isSimplified: Bool) -> String {
        switch self {
        case .show: return isSimplified ? "显示" : "顯示"
        case .omit: return isSimplified ? "省略" : "省略"
        }
    }
}
