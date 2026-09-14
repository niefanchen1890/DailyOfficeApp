import Foundation

// MARK: - 輔助結構
struct SeasonalBlock: Hashable {
    let title: String
    let rubric: String
    let content: String?
}

struct PrayerSection: Hashable {
    let title: String?
    let rubric: String?
    let paragraphs: [String]
    let responses: [Responsory]
}

struct Responsory: Hashable {
    let leader: String
    let people: String
}

struct ConfessionBlock: Hashable {
    let rubricBefore: String
    let version1: PrayerSection
}



// MARK: - 赦罪文資料結構
struct AbsolutionBlock: Hashable {
    let title: String
    let clergyRubric: String
    let clergyParagraphs: [String]
    let clergyAltRubric: String
    let clergyAltParagraphs: [String]
    let laypersonRubric: String
    let laypersonParagraphs: [String]
}

struct LessonBlock: Hashable {
    let title: String
    let rubric: String
    let responses: [Responsory]
}

// MARK: - JSON 資料結構
struct BibleSentenceJSON: Codable, Hashable {
    let text: String
    let reference: String
}

struct BibleSentencesContainer: Codable {
    let ordinary: [BibleSentenceJSON]
    let advent: [BibleSentenceJSON]
    let christmas: [BibleSentenceJSON]
    let epiphany: [BibleSentenceJSON]
    let lent: [BibleSentenceJSON]
    let holy_week: [BibleSentenceJSON]
    let easter: [BibleSentenceJSON]
    let ascension: [BibleSentenceJSON]
    let pentecost: [BibleSentenceJSON]
    let trinity: [BibleSentenceJSON]
    let thanksgiving: [BibleSentenceJSON]
}

// MARK: - 聖經選句載入器
class BibleSentencesLoader {
    static let shared = BibleSentencesLoader(baseFileName: "bible_sentences")
    static let eveningShared = BibleSentencesLoader(baseFileName: "evening_bible_sentences")
    
    private let baseFileName: String
    private var cache: [AppLanguage: BibleSentencesContainer] = [:]
    
    init(baseFileName: String) {
        self.baseFileName = baseFileName
    }
    
    /// 清除快取（切換語言時呼叫）
    func clearCache() {
        cache.removeAll()
    }
    
    /// 載入對應語言的容器
    private func container(for language: AppLanguage) -> BibleSentencesContainer {
        if let cached = cache[language] {
            return cached
        }
        
        // 🌟 優先嘗試雙語合併檔案（新格式）
        let bilingualFileName = baseFileName // e.g. "bible_sentences"
        if let url = Bundle.main.url(forResource: bilingualFileName, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let localizedData = LocalizedJSONResolver.resolve(data: data, language: language),
           let decoded = try? JSONDecoder().decode(BibleSentencesContainer.self, from: localizedData) {
            cache[language] = decoded
            return decoded
        }
        
        // 🌟 回退：舊格式分語言檔案（向後兼容）
        let legacyFileName = "\(baseFileName)_\(language.rawValue)"
        guard let url = Bundle.main.url(forResource: legacyFileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(BibleSentencesContainer.self, from: data) else {
            fatalError("無法載入 \(bilingualFileName).json 或 \(legacyFileName).json")
        }
        
        cache[language] = decoded
        return decoded
    }
    
    /// 根據節期與穩定 identifier 取得選句。
    func sentences(for season: LiturgicalSeason, identifier: LiturgicalID, language: AppLanguage? = nil) -> [BibleSentenceJSON] {
        let lang = language ?? MorningPrayerDataLoader.shared.currentLanguage
        let container = self.container(for: lang)
        
        // 優先判斷：五旬、六旬、七旬主日，以及三一主日後第一主日至降臨前主日 → 平日
        if LiturgicalRuleTable.trinityOctaveWeekdays.contains(identifier) {
            return container.trinity
        }
        
        if isOrdinarySunday(identifier: identifier) {
            return container.ordinary
        }
        
        // 苦難主日與棕樹主日兩週，使用聖周選句
        if identifier == .passionSunday || identifier == .palmSunday {
            return container.holy_week
        }
        
        // 特定節期對應
        switch season {
        case .advent:    return container.advent
        case .christmas: return container.christmas
        case .epiphany:  return container.epiphany
        case .lent:      return container.lent
        case .holyWeek:  return container.holy_week
        case .easter:    return container.easter
        case .ascension: return container.ascension
        case .pentecost: return container.pentecost
        case .trinity:
            // 三一主日本身使用三一專用選句；三一主日後第一主日至降臨前主日（含主日、平日）使用平日選句
            if identifier == .trinitySunday {
                return container.trinity
            }
            return container.ordinary
        default:         return container.ordinary
        }
    }
    
    /// 判斷是否為應顯示平日選句的主日
    private func isOrdinarySunday(identifier: LiturgicalID) -> Bool {
        if [.septuagesimaSunday, .sexagesimaSunday, .quinquagesimaSunday, .sundayBeforeAdvent]
            .contains(identifier) { return true }
        guard let temporal = identifier.temporalComponents else { return false }
        return temporal.weekday == 1
            && ((temporal.season == .easter && temporal.week >= 5)
                || temporal.season == .trinity)
    }
}



// MARK: - 邀請選句與皆來頌輔助結構
struct InvitatorySundayText: Hashable {
    let range: String
    let text: String
}

struct InvitatoryData: Hashable {
    let generalRubric: String
    let weekdayTexts: [String]      // 禮拜一至六（0=禮拜一）
}

// MARK: - 邀請選句顯示模式
enum InvitatoryDisplayMode: Hashable {
    case fullTwice       // 完整兩遍
    case fullOnce        // 完整一遍
    case secondHalf      // 後半部分（從 ※ 開始）
    case secondHalfThenFull  // 後半部分，然後完整一遍
}

// MARK: - 皆來頌段落
struct VeniteStanza: Hashable {
    let antiphonMode: InvitatoryDisplayMode?   // ← 加問號，允許 nil
    let verses: [String]
}

struct VeniteEnding: Hashable {
    let title: String
    let note: String?
    let stanzas: [VeniteStanza]
}

struct VeniteData: Hashable {
    let title: String
    let stanzas: [VeniteStanza]      // 主體：開頭對經 + 三段詩節 + 結束式提示
    let ending1: VeniteEnding
    let ending2: VeniteEnding
}

enum StPatrickOption: String, CaseIterable, Hashable {
    case omit = "省略"
    case recite = "誦唸"
}


// MARK: - 其他禱文選項（求恩祝文後）
enum GeneralPrayerOption: String, CaseIterable, Hashable {
    case prayers = "祈禱"
    case litany = "總禱文"
    case omit = "省略"
}


// MARK: - 資料模型
struct MorningPrayerData {
    
    // MARK: - JSON 資料存取（私有，只供內部使用）
    private static var json: MorningPrayerJSON {
        MorningPrayerDataLoader.shared.load()
    }
    
    // MARK: 禮規與開始
    static var openingRubric: String {
        json.openingRubric
    }
    static var seasonalSentences: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.seasonalSentences)
    }
    // MARK: 日課前祈禱（可選）
    static var preparatoryPrayers: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.preparatoryPrayers)
    }
    
    // MARK: 勸眾文
    static var exhortation: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.exhortation)
    }
    
    // MARK: 認罪文
    static var confession: ConfessionBlock {
        MorningPrayerDataLoader.shared.confessionBlock(from: json.confession)
    }
    
    // MARK: 赦罪文
    static var absolution: AbsolutionBlock {
        MorningPrayerDataLoader.shared.absolutionBlock(from: json.absolution)
    }
    
    // MARK: 主禱文
    static var lordPrayer: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.lordPrayer)
    }
    
    // MARK: 啟應
    static var responses: [Responsory] {
        MorningPrayerDataLoader.shared.responsories(from: json.responses)
    }
    
    // MARK: - 邀請選句資料
    static var invitatory: InvitatoryData {
        MorningPrayerDataLoader.shared.invitatoryData(from: json.invitatory)
    }
    
    // 禮拜一提示
    static var invitatoryMondayNote: String {
        json.invitatoryMondayNote
    }
    
    // MARK: - 皆來頌
    static var venite: VeniteData {
        MorningPrayerDataLoader.shared.veniteData(from: json.venite)
    }
    
    // MARK: 經課 (🌟 從 JSON 動態讀取)
    static var lessons: [LessonBlock] {
        json.lessons.map {
            LessonBlock(
                title: $0.title,
                rubric: $0.rubric,
                responses: MorningPrayerDataLoader.shared.responsories(from: $0.responses)
            )
        }
    }
    
    // MARK: 頌歌
    static var firstCanticle: SeasonalBlock {
        let isTrad = MorningPrayerDataLoader.shared.currentLanguage == .traditional
        return SeasonalBlock(
            title: isTrad ? "第一頌歌" : "第一颂歌",
            rubric: json.firstCanticleRubric,
            content: nil
        )
    }
    
    static var secondCanticle: SeasonalBlock {
        let isTrad = MorningPrayerDataLoader.shared.currentLanguage == .traditional
        return SeasonalBlock(
            title: isTrad ? "第二頌歌" : "第二颂歌",
            rubric: json.secondCanticleRubric,
            content: nil
        )
    }
    
    // MARK: 信經禮規
    static var creedRubric: String {
        json.creedRubric
    }
    
    // MARK: 使徒信經
    static var apostlesCreed: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.apostlesCreed)
    }
    
    // MARK: 尼西亞信經
    static var niceneCreed: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.niceneCreed)
    }
    
    // MARK: 祈禱
    static var prayers: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.prayers)
    }
    
    // MARK: 祈禱啟應
    static var prayersResponsesBCP1932: [Responsory] {
        MorningPrayerDataLoader.shared.responsories(from: json.prayersResponsesBCP1932)
    }
    
    static var prayersResponsesNew: [Responsory] {
        MorningPrayerDataLoader.shared.responsories(from: json.prayersResponsesNew)
    }
    
    // MARK: 祝文
    static var collects: [PrayerSection] {
        json.collects.map { MorningPrayerDataLoader.shared.prayerSection(from: $0) }
    }
    
    // MARK: 其他禱文
    static var generalPrayers: [PrayerSection] {
        json.generalPrayers.map { MorningPrayerDataLoader.shared.prayerSection(from: $0) }
    }
    
    // MARK: 結尾專屬啟應
    static var endingResponses: [Responsory] {
        MorningPrayerDataLoader.shared.responsories(from: json.endingResponses)
    }
    
    // MARK: 結束
    static var ending: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.ending)
    }
    
    // MARK: 聖帕特里克鎧甲歌
    static var stPatrickBreastplate: [String] {
        json.stPatrickBreastplate
    }
    
    // MARK: - 聖靈降臨八日慶期每日附加祝文 (動態雙語化)
    struct PentecostOctaveAppendix {
        static var collect: DailyOfficeFile.OfficePeriod.CollectJSON {
            let isTrad = MorningPrayerDataLoader.shared.currentLanguage == .traditional
            return DailyOfficeFile.OfficePeriod.CollectJSON(
                title: isTrad ? "聖靈降臨八日慶期每日祝文" : "圣灵降临八日庆期每日祝文",
                text: isTrad ? "全能最慈悲的上帝，我們懇求主，使我們靠著住在我們裡面的聖靈，得蒙啓發，加增力量服事主。這都是靠著我主耶穌基督。主和聖父、聖靈，惟一上帝，一同永生，一同掌權，世世無盡。阿們。" : "全能最慈悲的上帝，我们恳求主，使我们靠着住在我们里面的圣灵，得蒙启发，加增力量服事主。这都是靠着我主耶稣基督。主和圣父、圣灵，惟一上帝，一同永生，一同掌权，世世无尽。阿们。"
            )
        }
        
        static let applicableTitles: Set<String> = [
            "聖靈降臨後一日", "圣灵降临后一日",
            "聖靈降臨後二日", "圣灵降临后二日",
            "聖靈降臨八日慶期內夏季齋期禮拜三", "圣灵降临八日庆期内夏季斋期礼拜三",
            "聖靈降臨八日慶期內禮拜四", "圣灵降临八日庆期内礼拜四",
            "聖靈降臨八日慶期內夏季齋期禮拜五", "圣灵降临八日庆期内夏季斋期礼拜五",
            "聖靈降臨八日慶期內夏季齋期禮拜六", "圣灵降临八日庆期内夏季斋期礼拜六"
        ]
    }
}
