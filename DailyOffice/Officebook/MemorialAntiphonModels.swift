import Foundation

// MARK: - 對經選擇 Enum
enum MemorialAntiphonSelection: String, CaseIterable, Hashable {
    case seasonal = "季節對經"
    case marian = "聖母對經"
    case omit = "省略"

    static func available(hasSeasonal: Bool, hasMarian: Bool) -> [MemorialAntiphonSelection] {
        var selections: [MemorialAntiphonSelection] = []
        if hasSeasonal { selections.append(.seasonal) }
        if hasMarian { selections.append(.marian) }
        if !selections.isEmpty { selections.append(.omit) }
        return selections
    }
}

// MARK: - 資料模型
struct MemorialAntiphonsContainer: Codable {
    let identifier: String
    let name: String
    let type: String
    let seasonalAntiphons: [SeasonalAntiphonData]
    let marianAntiphons: [MarianAntiphonData]
    
    enum CodingKeys: String, CodingKey {
        case identifier, name, type
        case seasonalAntiphons = "seasonal_antiphons"
        case marianAntiphons = "marian_antiphons"
    }
}

struct SeasonalAntiphonData: Codable {
    let identifier: String
    let seasonKeys: [String]
    let title: String?
    let rubric: String
    let antiphon: String
    let versicle: MemorialVersicleData
    let collect: MemorialCollectData
    
    enum CodingKeys: String, CodingKey {
        case identifier, title, rubric, antiphon, versicle, collect
        case seasonKeys = "season_keys"
    }

    var content: AntiphonContent {
        AntiphonContent(
            title: title.flatMap { $0.isEmpty ? nil : $0 },
            rubric: rubric,
            antiphon: antiphon,
            versicle: versicle.leader,
            response: versicle.people,
            prayer: collect.text
        )
    }
}

typealias MarianAntiphonData = SeasonalAntiphonData

struct MemorialVersicleData: Codable {
    let leader: String
    let people: String
}

struct MemorialCollectData: Codable {
    let text: String
}

struct AntiphonContent {
    let title: String?
    let rubric: String
    let antiphon: String
    let versicle: String
    let response: String
    let prayer: String
}
