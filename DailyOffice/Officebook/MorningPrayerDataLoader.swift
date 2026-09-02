import Foundation

// MARK: - 語言設定
enum AppLanguage: String, CaseIterable {
    case traditional = "zh-Hant"
    case simplified = "zh-Hans"
}

// MARK: - ✅ 邀請聖詩數據模型（原 InvitatoryHymnLoader 遷入）
struct InvitatoryHymnData: Hashable {
    let title: String
    let seasonNote: String?
    let verses: [String]
}

enum InvitatoryHymnType {
    case sundayWinter
    case sundaySummer
    case weekday(Int)
}

struct InvitatoryHymnsContainerJSON: Codable {
    let ui: InvitatoryHymnUIJSON?
    let sundayWinter: InvitatoryHymnEntryJSON
    let sundaySummer: InvitatoryHymnEntryJSON
    let weekday: [String: InvitatoryHymnEntryJSON]
    
    enum CodingKeys: String, CodingKey {
        case ui, sundayWinter, sundaySummer, weekday
    }
}

struct InvitatoryHymnUIJSON: Codable {
    let title: String
    let rubric: String
}

struct InvitatoryHymnEntryJSON: Codable {
    let title: String
    let seasonNote: String?
    let verses: [String]
}

// MARK: - ✅ 日課聖詩數據模型（對應 morning_hymns.json）
struct OfficeHymnsContainerJSON: Codable {
    let sundayEpiphany: OfficeHymnEntryJSON
    let sundayTrinity: OfficeHymnEntryJSON
    let weekday: [String: OfficeHymnEntryJSON]
}

struct OfficeHymnEntryJSON: Codable {
    let title: String
    let latinTitle: String
    let seasonNote: String?
    let verses: [String]
    let versicle: OfficeVersicleJSON?
}

struct OfficeVersicleJSON: Codable {
    let leader: String
    let people: String
}

// 用來指定要查詢哪一種日課聖詩
enum MorningOfficeHymnType {
    case sundayEpiphany      // 顯現期主日
    case sundayTrinity       // 三一期主日
    case weekday(Int)        // 平日 (1=禮拜一 ... 6=禮拜六)
}

// MARK: - JSON 資料結構
struct MorningPrayerJSON: Codable {
    let openingRubric: String
    let preparatoryPrayers: PrayerSectionJSON
    let seasonalSentences: PrayerSectionJSON
    let exhortation: PrayerSectionJSON
    let confession: ConfessionJSON
    let absolution: AbsolutionJSON
    let lordPrayer: PrayerSectionJSON
    let responses: [ResponsoryJSON]
    let invitatory: InvitatoryJSON
    let invitatoryMondayNote: String
    let venite: VeniteJSON
    let lessons: [LessonJSON]
    let firstCanticleRubric: String
    let secondCanticleRubric: String
    let creedRubric: String
    let apostlesCreed: PrayerSectionJSON
    let niceneCreed: PrayerSectionJSON
    let prayers: PrayerSectionJSON
    let prayersResponsesBCP1932: [ResponsoryJSON]
    let prayersResponsesNew: [ResponsoryJSON]
    let collects: [PrayerSectionJSON]
    let generalPrayers: [PrayerSectionJSON]
    let endingResponses: [ResponsoryJSON]
    let ending: PrayerSectionJSON
    let stPatrickBreastplate: [String]
    
    enum CodingKeys: String, CodingKey {
        case openingRubric = "opening_rubric"
        case preparatoryPrayers = "preparatory_prayers"
        case seasonalSentences = "seasonalSentences"
        case exhortation
        case confession
        case absolution
        case lordPrayer = "lord_prayer"
        case responses
        case invitatory
        case invitatoryMondayNote = "invitatory_monday_note"
        case venite
        case lessons
        case firstCanticleRubric = "first_canticle_rubric"
        case secondCanticleRubric = "second_canticle_rubric"
        case creedRubric = "creed_rubric"
        case apostlesCreed = "apostles_creed"
        case niceneCreed = "nicene_creed"
        case prayers
        case prayersResponsesBCP1932 = "prayers_responses_bcp1932"
        case prayersResponsesNew = "prayers_responses_new"
        case collects
        case generalPrayers = "general_prayers"
        case endingResponses = "ending_responses"
        case ending
        case stPatrickBreastplate = "st_patrick_breastplate"
    }
}

struct PrayerSectionJSON: Codable {
    let title: String?
    let rubric: String?
    let paragraphs: [String]
    let responses: [ResponsoryJSON]
}

struct ResponsoryJSON: Codable {
    let leader: String
    let people: String
}

struct ConfessionJSON: Codable {
    let rubricBefore: String
    let version1: PrayerSectionJSON
    
    enum CodingKeys: String, CodingKey {
        case rubricBefore = "rubric_before"
        case version1
    }
}

struct AbsolutionJSON: Codable {
    let title: String
    let clergyRubric: String
    let clergyParagraphs: [String]
    let clergyAltRubric: String
    let clergyAltParagraphs: [String]
    let laypersonRubric: String
    let laypersonParagraphs: [String]
    
    enum CodingKeys: String, CodingKey {
        case title
        case clergyRubric = "clergy_rubric"
        case clergyParagraphs = "clergy_paragraphs"
        case clergyAltRubric = "clergy_alt_rubric"
        case clergyAltParagraphs = "clergy_alt_paragraphs"
        case laypersonRubric = "layperson_rubric"
        case laypersonParagraphs = "layperson_paragraphs"
    }
}

struct InvitatoryJSON: Codable {
    let generalRubric: String
    let weekdayTexts: [String]
    
    enum CodingKeys: String, CodingKey {
        case generalRubric = "general_rubric"
        case weekdayTexts = "weekday_texts"
    }
}

struct VeniteJSON: Codable {
    let title: String
    let stanzas: [VeniteStanzaJSON]
    let ending1: VeniteEndingJSON
    let ending2: VeniteEndingJSON
}

struct VeniteStanzaJSON: Codable {
    let antiphonMode: String?
    let verses: [String]
    
    enum CodingKeys: String, CodingKey {
        case antiphonMode = "antiphon_mode"
        case verses
    }
}

struct VeniteEndingJSON: Codable {
    let title: String
    let note: String?
    let stanzas: [VeniteStanzaJSON]
}

struct LessonJSON: Codable {
    let title: String
    let rubric: String
    let responses: [ResponsoryJSON]
}

// MARK: - 資料載入器
class MorningPrayerDataLoader {
    static let shared = MorningPrayerDataLoader()
    
    private var cache: [AppLanguage: MorningPrayerJSON] = [:]
    
    private var invitatoryHymnsCache: [AppLanguage: InvitatoryHymnsContainerJSON] = [:]
    
    private var officeHymnsCache: [AppLanguage: OfficeHymnsContainerJSON] = [:]
    
    /// 從 UserDefaults 讀取目前語言，預設繁體
    var currentLanguage: AppLanguage {
        let code = UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.traditional.rawValue
        return AppLanguage(rawValue: code) ?? .traditional
    }
    
    func clearCache() {
        cache.removeAll()
    }
    
    /// ✅ 統一語言切換入口：清理自身與所有子加載器的快取
    func setLanguage(_ language: AppLanguage) {
        // 移除 guard language != currentLanguage else { return }
        // 因為 @AppStorage 已經提前修改了 UserDefaults，這裡的 currentLanguage 已經是新值
        
        UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
        
        // 1. 清理自身所有快取
        clearCache()
        invitatoryHymnsCache.removeAll()
        officeHymnsCache.removeAll() // 🌟 新增：清理日課聖詩快取
        // 🌟 新增：清理晚禱快取
        EveningPrayerDataLoader.shared.clearCache()
        
        // 2. 級聯清理 DailyOfficeLoader（聖日/節期檔案）
        DailyOfficeLoader.shared.clearCache()
        
        // 3. 級聯清理聖經選句與頌歌
        BibleSentencesLoader.shared.clearCache()
        BibleSentencesLoader.eveningShared.clearCache()
        CanticleLoader.shared.clearCache()
        
        print("🌐 語言已切換至 \(language.rawValue)，所有快取已清理")
    }
    
    // MARK: - ✅ 邀請聖詩載入（併入 DataLoader，支援三語 JSON）
    
    func loadInvitatoryHymns(language: AppLanguage? = nil) -> InvitatoryHymnsContainerJSON {
        let lang = language ?? currentLanguage
        
        if let cached = invitatoryHymnsCache[lang] {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "invitatory_hymns", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let localizedData = LocalizedJSONResolver.resolve(data: data, language: lang),
              let decoded = try? JSONDecoder().decode(InvitatoryHymnsContainerJSON.self, from: localizedData) else {
            fatalError("無法載入 invitatory_hymns.json（請確認檔案存在且 LocalizedJSONResolver 正常運作）")
        }
        
        invitatoryHymnsCache[lang] = decoded
        return decoded
    }
    
    // MARK: - ✅ 日課聖詩載入（支援三語 JSON 與專用聖詩）
        
    func loadOfficeHymns(language: AppLanguage? = nil) -> OfficeHymnsContainerJSON {
        let lang = language ?? currentLanguage
        
        if let cached = officeHymnsCache[lang] {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "morning_hymns", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              // 🌟 透過 Resolver 自動將 { "zh-hant": "...", "zh-hans": "..." } 轉為純字串
              let localizedData = LocalizedJSONResolver.resolve(data: data, language: lang),
              let decoded = try? JSONDecoder().decode(OfficeHymnsContainerJSON.self, from: localizedData) else {
            fatalError("無法載入 morning_hymns.json（請確認檔案存在且 LocalizedJSONResolver 正常運作）")
        }
        
        officeHymnsCache[lang] = decoded
        return decoded
    }
    
    /// 根據類型與語言，獲取對應的日課聖詩資料
    func officeHymn(for type: MorningOfficeHymnType, language: AppLanguage? = nil) -> OfficeHymnEntryJSON? {
        let container = loadOfficeHymns(language: language ?? currentLanguage)
        
        switch type {
        case .sundayEpiphany: return container.sundayEpiphany
        case .sundayTrinity:  return container.sundayTrinity
        case .weekday(let index): return container.weekday[String(index)]
        }
    }
    
    func invitatoryHymn(for type: InvitatoryHymnType, language: AppLanguage? = nil) -> InvitatoryHymnData {
        let container = loadInvitatoryHymns(language: language ?? currentLanguage)
        
        let entry: InvitatoryHymnEntryJSON
        switch type {
        case .sundayWinter:
            entry = container.sundayWinter
        case .sundaySummer:
            entry = container.sundaySummer
        case .weekday(let index):
            let key = String(index)
            entry = container.weekday[key] ?? container.weekday["1"]!
        }
        
        return InvitatoryHymnData(
            title: entry.title,
            seasonNote: entry.seasonNote,
            verses: entry.verses
        )
    }
    
    func invitatoryHymnUI(language: AppLanguage? = nil) -> (title: String, rubric: String?) {
        let container = loadInvitatoryHymns(language: language ?? currentLanguage)
        return (
            title: container.ui?.title ?? "邀請聖詩",
            rubric: container.ui?.rubric
        )
    }
    
    /// 載入對應語言的 JSON
    func load(language: AppLanguage? = nil) -> MorningPrayerJSON {
        let lang = language ?? currentLanguage
        
        if let cached = cache[lang] {
            return cached
        }
        
        // ✅ 關鍵修改：文件名加上語言後綴，避免同名衝突
        let fileName = "morning_prayer_data_\(lang.rawValue)"
        
        // ✅ 加這行除錯
        print("📖 正在載入: \(fileName).json | currentLanguage=\(currentLanguage.rawValue)")
        
        guard let url = Bundle.main.url(
            forResource: fileName,     // e.g. "morning_prayer_data_zh-Hant"
            withExtension: "json",
            subdirectory: nil           // ← 改成 nil，因為檔案在 Bundle 根目錄
        ) else {
            // 臨時除錯：列出 Bundle 裡所有 JSON 檔案
            if let resourcePath = Bundle.main.resourcePath {
                let fileManager = FileManager.default
                if let files = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                    let jsonFiles = files.filter { $0.hasSuffix(".json") }
                    print("📁 Bundle 根目錄 JSON 檔案：\(jsonFiles)")
                }
            }
            fatalError("無法找到 \(fileName).json")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("無法讀取 \(fileName).json")
        }
        
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(MorningPrayerJSON.self, from: data) else {
            fatalError("無法解析 \(fileName).json，請檢查 JSON 格式與 Swift 結構是否對應")
        }
        
        cache[lang] = decoded
        return decoded
    }
    
    // MARK: - 轉換輔助方法
    
    func prayerSection(from json: PrayerSectionJSON) -> PrayerSection {
        PrayerSection(
            title: json.title,
            rubric: json.rubric,
            paragraphs: json.paragraphs,
            responses: json.responses.map { Responsory(leader: $0.leader, people: $0.people) }
        )
    }
    
    func responsories(from jsons: [ResponsoryJSON]) -> [Responsory] {
        jsons.map { Responsory(leader: $0.leader, people: $0.people) }
    }
    // MARK: - 新增：認罪文、赦罪文、邀請選句轉換
    
    func confessionBlock(from json: ConfessionJSON) -> ConfessionBlock {
        ConfessionBlock(
            rubricBefore: json.rubricBefore,
            version1: prayerSection(from: json.version1)
        )
    }
    
    func absolutionBlock(from json: AbsolutionJSON) -> AbsolutionBlock {
        AbsolutionBlock(
            title: json.title,
            clergyRubric: json.clergyRubric,
            clergyParagraphs: json.clergyParagraphs,
            clergyAltRubric: json.clergyAltRubric,
            clergyAltParagraphs: json.clergyAltParagraphs,
            laypersonRubric: json.laypersonRubric,
            laypersonParagraphs: json.laypersonParagraphs
        )
    }
    
    func invitatoryData(from json: InvitatoryJSON) -> InvitatoryData {
        InvitatoryData(
            generalRubric: json.generalRubric,
            weekdayTexts: json.weekdayTexts
        )
    }
    // MARK: - 皆來頌轉換
    func veniteData(from json: VeniteJSON) -> VeniteData {
        VeniteData(
            title: json.title,
            stanzas: json.stanzas.map { stanzaJSON in
                VeniteStanza(
                    antiphonMode: stanzaJSON.antiphonMode.flatMap { modeString in
                        switch modeString {
                        case "fullTwice": return .fullTwice
                        case "fullOnce": return .fullOnce
                        case "secondHalf": return .secondHalf
                        case "secondHalfThenFull": return .secondHalfThenFull
                        default: return nil
                        }
                    },
                    verses: stanzaJSON.verses
                )
            },
            ending1: veniteEnding(from: json.ending1),
            ending2: veniteEnding(from: json.ending2)
        )
    }
    
    private func veniteEnding(from json: VeniteEndingJSON) -> VeniteEnding {
        VeniteEnding(
            title: json.title,
            note: json.note,
            stanzas: json.stanzas.map { stanzaJSON in
                VeniteStanza(
                    antiphonMode: stanzaJSON.antiphonMode.flatMap { modeString in
                        switch modeString {
                        case "fullTwice": return .fullTwice
                        case "fullOnce": return .fullOnce
                        case "secondHalf": return .secondHalf
                        case "secondHalfThenFull": return .secondHalfThenFull
                        default: return nil
                        }
                    },
                    verses: stanzaJSON.verses
                )
            }
        )
    }
}
