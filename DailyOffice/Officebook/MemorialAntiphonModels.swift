import Foundation

// MARK: - 對經選擇 Enum
enum MemorialAntiphonSelection: String, CaseIterable, Hashable {
    case seasonal = "季節對經"
    case marian = "聖母對經"
    case omit = "省略"
}

// MARK: - 資料模型
struct MemorialAntiphonsContainer: Codable {
    let seasonalAntiphons: [SeasonalAntiphonData]
    let marianAntiphons: [MarianAntiphonData]
    
    enum CodingKeys: String, CodingKey {
        case seasonalAntiphons = "seasonal_antiphons"
        case marianAntiphons = "marian_antiphons"
    }
}

struct SeasonalAntiphonData: Codable {
    let id: String
    let seasonKeys: [String]
    let tc: AntiphonContent
    let sc: AntiphonContent
    
    enum CodingKeys: String, CodingKey {
        case id, tc, sc
        case seasonKeys = "season_keys"
    }
}

struct MarianAntiphonData: Codable {
    let id: String
    let seasonKeys: [String]
    let tc: AntiphonContent
    let sc: AntiphonContent
    
    enum CodingKeys: String, CodingKey {
        case id, tc, sc
        case seasonKeys = "season_keys"
    }
}

struct AntiphonContent: Codable {
    let title: String?
    let rubric: String
    let antiphon: String
    let versicle: String
    let response: String
    let prayer: String
}
