import Foundation

// MARK: - 1. 雙語字串共用模型
struct BilingualText: Codable, Hashable {
    let zhHant: String?
    let zhHans: String?

    enum CodingKeys: String, CodingKey {
        case zhHant = "zh-hant"
        case zhHans = "zh-hans"
    }

    // 根據當前語系自動回傳對應的字串
    func text(for language: AppLanguage) -> String {
        return language == .traditional ? (zhHant ?? "") : (zhHans ?? "")
    }
}

// MARK: - 2. JSON 映射結構
struct LitanyDataJSON: Codable {
    let identifier: String
    let title: BilingualText
    let mainRubric: BilingualText
    let mainResponses: [LitanyResponsoryJSON]
    let lordPrayer: LitanyPrayerSectionJSON
    let lordPrayerNote: BilingualText
    let intermediateResponses: [LitanyResponsoryJSON]
    let intermediatePrayer: LitanyPrayerSectionJSON
    let middleRecitations: [LitanyRecitationJSON]
    let closingResponses: [LitanyResponsoryJSON]
    let closingPrayer: LitanyPrayerSectionJSON
    let finalRubric: BilingualText

    enum CodingKeys: String, CodingKey {
        case identifier, title
        case mainRubric = "main_rubric"
        case mainResponses = "main_responses"
        case lordPrayer = "lord_prayer"
        case lordPrayerNote = "lord_prayer_note"
        case intermediateResponses = "intermediate_responses"
        case intermediatePrayer = "intermediate_prayer"
        case middleRecitations = "middle_recitations"
        case closingResponses = "closing_responses"
        case closingPrayer = "closing_prayer"
        case finalRubric = "final_rubric"
    }
}

struct LitanyResponsoryJSON: Codable {
    let leader: BilingualText
    let people: BilingualText
}

struct LitanyPrayerSectionJSON: Codable {
    let title: BilingualText?
    let rubric: BilingualText?
    let paragraphs: [BilingualText]
}

struct LitanyRecitationJSON: Codable {
    let rubric: BilingualText
    let text: BilingualText
}

// MARK: - 3. UI 顯示模型 (實作 Identifiable 解決 ForEach 重複崩潰問題)
struct UILitanyResponsory: Identifiable {
    let id = UUID()
    let leader: BilingualText
    let people: BilingualText
}

struct UILitanyRecitation: Identifiable {
    let id = UUID()
    let rubric: BilingualText
    let text: BilingualText
}

struct UILitanyData {
    let title: BilingualText
    let mainRubric: BilingualText
    let mainResponses: [UILitanyResponsory]
    let lordPrayer: LitanyPrayerSectionJSON
    let lordPrayerNote: BilingualText
    let intermediateResponses: [UILitanyResponsory]
    let intermediatePrayer: LitanyPrayerSectionJSON
    let middleRecitations: [UILitanyRecitation]
    let closingResponses: [UILitanyResponsory]
    let closingPrayer: LitanyPrayerSectionJSON
    let finalRubric: BilingualText
}
