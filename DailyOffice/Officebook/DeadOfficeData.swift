import Foundation

// MARK: - 亡者日課 JSON 資料模型

struct DeadOfficeReading: Codable, Hashable {
    let book: String
    let reference: String
    let version: String
}

struct DeadOfficeResponse: Codable, Hashable {
    let leader: String
    let people: String
}

struct DeadOfficeResponsory: Codable, Hashable {
    let title: String
    let text: String
    let responses: [DeadOfficeResponse]
}

struct DeadOfficeCanticle: Codable, Hashable {
    let title: String
    let antiphonOpening: String?
    let antiphonFull: String?
    let rubric: String?
    let verses: [String]

    enum CodingKeys: String, CodingKey {
        case title, rubric, verses
        case antiphonOpening = "antiphon_opening"
        case antiphonFull = "antiphon_full"
    }
}

struct DeadOfficeCollect: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let text: String
}

struct DeadOfficeForm: Codable, Hashable {
    let title: String
    let psalms: [String]
    let weekdayPsalmGroups: [String: [String]]?
    let psalmSelectionRubric: String?
    let psalmGroupRubrics: [String: String]?
    let allSoulsPsalms: [String]?
    let firstLesson: DeadOfficeReading
    let firstResponsory: DeadOfficeResponsory?
    let firstLessonResponse: DeadOfficeResponse?
    let firstCanticle: DeadOfficeCanticle?
    let secondLesson: DeadOfficeReading
    let secondResponsory: DeadOfficeResponsory?
    let secondCanticle: DeadOfficeCanticle
    let collectsRubric: String
    let allSaintsCollectsRubric: String?
    let allSoulsCollectsRubric: String
    let collects: [DeadOfficeCollect]
    let optionalPsalm: String
    let optionalPsalmRubric: String
    let endingText: String

    enum CodingKeys: String, CodingKey {
        case title, psalms, collects
        case weekdayPsalmGroups = "weekday_psalm_groups"
        case psalmSelectionRubric = "psalm_selection_rubric"
        case psalmGroupRubrics = "psalm_group_rubrics"
        case allSoulsPsalms = "all_souls_psalms"
        case firstLesson = "first_lesson"
        case firstResponsory = "first_responsory"
        case firstLessonResponse = "first_lesson_response"
        case firstCanticle = "first_canticle"
        case secondLesson = "second_lesson"
        case secondResponsory = "second_responsory"
        case secondCanticle = "second_canticle"
        case collectsRubric = "collects_rubric"
        case allSaintsCollectsRubric = "all_saints_collects_rubric"
        case allSoulsCollectsRubric = "all_souls_collects_rubric"
        case optionalPsalm = "optional_psalm"
        case optionalPsalmRubric = "optional_psalm_rubric"
        case endingText = "ending_text"
    }
}

struct DeadOfficeFile: Codable, Hashable {
    let identifier: String
    let title: String
    let introductoryRubric: String
    let psalmTitle: String
    let psalmAntiphonOpening: String
    let psalmAntiphonFull: String
    let firstLessonTitle: String
    let secondLessonTitle: String
    let lessonRubric: String
    let prayerTitle: String
    let kyrie: [String]
    let lordPrayer: String
    let prayerResponses: [DeadOfficeResponse]
    let collectOpening: DeadOfficeResponse
    let collectEnding: DeadOfficeResponse
    let morning: DeadOfficeForm
    let evening: DeadOfficeForm

    enum CodingKeys: String, CodingKey {
        case identifier, title, kyrie, morning, evening
        case introductoryRubric = "introductory_rubric"
        case psalmTitle = "psalm_title"
        case psalmAntiphonOpening = "psalm_antiphon_opening"
        case psalmAntiphonFull = "psalm_antiphon_full"
        case firstLessonTitle = "first_lesson_title"
        case secondLessonTitle = "second_lesson_title"
        case lessonRubric = "lesson_rubric"
        case prayerTitle = "prayer_title"
        case lordPrayer = "lord_prayer"
        case prayerResponses = "prayer_responses"
        case collectOpening = "collect_opening"
        case collectEnding = "collect_ending"
    }
}

final class DeadOfficeDataLoader {
    static let shared = DeadOfficeDataLoader()
    private var cache: [AppLanguage: DeadOfficeFile] = [:]

    private init() {}

    func clearCache() {
        cache.removeAll()
    }

    func load(language: AppLanguage = AppLanguageStore.shared.language) -> DeadOfficeFile {
        if let cached = cache[language] { return cached }

        guard let url = Bundle.main.url(forResource: "office_for_the_dead", withExtension: "json") else {
            fatalError("無法找到 office_for_the_dead.json")
        }

        do {
            let rawData = try Data(contentsOf: url)
            guard let localizedData = LocalizedJSONResolver.resolve(data: rawData, language: language) else {
                fatalError("無法解析亡者日課的多語言資料")
            }
            let result = try JSONDecoder().decode(DeadOfficeFile.self, from: localizedData)
            cache[language] = result
            return result
        } catch {
            fatalError("無法解析 office_for_the_dead.json：\(error)")
        }
    }
}
