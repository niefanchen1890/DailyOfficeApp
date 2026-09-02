import Foundation

// MARK: - 晚禱專屬 JSON 資料結構
struct EveningPrayerJSON: Codable {
    let openingRubric: String
    let preparatoryPrayers: PrayerSectionJSON
    let exhortation: PrayerSectionJSON
    let confession: ConfessionJSON
    let absolution: AbsolutionJSON
    let lordPrayer: PrayerSectionJSON
    let responses: [ResponsoryJSON]
    let phosHilaron: PrayerSectionJSON
    let prayers: PrayerSectionJSON
    let prayersResponsesBCP1932: [ResponsoryJSON]
    let prayersResponsesNew: [ResponsoryJSON]
    let collects: [PrayerSectionJSON]
    let generalPrayers: [PrayerSectionJSON]
    let endingResponses: [ResponsoryJSON]
    let ending: PrayerSectionJSON
    let stPatrickBreastplate: [String]
    let gloriaInExcelsis: GloriaInExcelsisJSON
    
    enum CodingKeys: String, CodingKey {
        case openingRubric = "opening_rubric"
        case preparatoryPrayers = "preparatory_prayers"
        case exhortation
        case confession
        case absolution
        case lordPrayer = "lord_prayer"
        case responses
        case phosHilaron = "phos_hilaron"
        case prayers
        case prayersResponsesBCP1932 = "prayers_responses_bcp1932"
        case prayersResponsesNew = "prayers_responses_new"
        case collects
        case generalPrayers = "general_prayers"
        case endingResponses = "ending_responses"
        case ending
        case stPatrickBreastplate = "st_patrick_breastplate"
        case gloriaInExcelsis = "gloria_in_excelsis"
    }
}

// 榮歸主頌 JSON 模型
struct GloriaInExcelsisJSON: Codable {
    let rubric: String
    let bcp1932: [String]
    let newTranslation: [String]
}

// MARK: - 晚禱資料載入器
class EveningPrayerDataLoader {
    static let shared = EveningPrayerDataLoader()
    private var cache: [AppLanguage: EveningPrayerJSON] = [:]
    
    func clearCache() {
        cache.removeAll()
    }
    
    /// 載入對應語言的 JSON
    func load(language: AppLanguage? = nil) -> EveningPrayerJSON {
        // 預設語言與早禱共用狀態
        let lang = language ?? MorningPrayerDataLoader.shared.currentLanguage
        
        if let cached = cache[lang] {
            return cached
        }
        
        let fileName = "evening_prayer_data_\(lang.rawValue)"
        print("🌙 正在載入晚禱: \(fileName).json")
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("無法找到 \(fileName).json")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("無法讀取 \(fileName).json")
        }
        
        guard let decoded = try? JSONDecoder().decode(EveningPrayerJSON.self, from: data) else {
            fatalError("無法解析 \(fileName).json，請檢查 JSON 格式與 Swift 結構是否對應")
        }
        
        cache[lang] = decoded
        return decoded
    }
}
