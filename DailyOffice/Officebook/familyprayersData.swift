import Foundation

// MARK: - 家庭禱文資料模型

struct HomePrayerSection: Codable, Hashable {
    let id: String
    let title: String?
    let rubric: String?
    let preRubric: String?
    let paragraphs: [String]
    let postRubric: String?
}

struct HomePrayerPart: Codable, Hashable {
    let title: String
    let mainRubric: String
    let sections: [HomePrayerSection]
}

struct HomePrayerFile: Codable, Hashable {
    let title: String
    let morning: HomePrayerPart
    let evening: HomePrayerPart
}

// MARK: - JSON 載入與語言轉換

final class HomePrayerDataLoader {
    static let shared = HomePrayerDataLoader()
    private var cache: [AppLanguage: HomePrayerFile] = [:]

    private init() {}

    func clearCache() { cache.removeAll() }

    func load(language: AppLanguage = AppLanguageStore.shared.language) -> HomePrayerFile {
        if let cached = cache[language] { return cached }

        guard let url = Bundle.main.url(forResource: "family_prayers", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("無法找到 family_prayers.json")
        }

        do {
            let decoded = try JSONDecoder().decode(HomePrayerFile.self, from: data)
            let localized = language == .simplified ? decoded : decoded.convertedToTraditional()
            cache[language] = localized
            return localized
        } catch {
            fatalError("無法解析 family_prayers.json：\(error)")
        }
    }
}

// MARK: - 畫面使用的資料入口

struct HomePrayerData {
    private static var file: HomePrayerFile { HomePrayerDataLoader.shared.load() }
    static var title: String { file.title }
    static var morningPrayer: HomePrayerPart { file.morning }
    static var eveningPrayer: HomePrayerPart { file.evening }
}

// JSON 保留現有簡體原文；繁體模式在資料層統一轉換。
private extension HomePrayerFile {
    func convertedToTraditional() -> HomePrayerFile {
        HomePrayerFile(
            title: title.toTraditionalChinese(),
            morning: morning.convertedToTraditional(),
            evening: evening.convertedToTraditional()
        )
    }
}

private extension HomePrayerPart {
    func convertedToTraditional() -> HomePrayerPart {
        HomePrayerPart(
            title: title.toTraditionalChinese(),
            mainRubric: mainRubric.toTraditionalChinese(),
            sections: sections.map { $0.convertedToTraditional() }
        )
    }
}

private extension HomePrayerSection {
    func convertedToTraditional() -> HomePrayerSection {
        HomePrayerSection(
            id: id,
            title: title?.toTraditionalChinese(),
            rubric: rubric?.toTraditionalChinese(),
            preRubric: preRubric?.toTraditionalChinese(),
            paragraphs: paragraphs.map { $0.toTraditionalChinese() },
            postRubric: postRubric?.toTraditionalChinese()
        )
    }
}

private extension String {
    func toTraditionalChinese() -> String {
        applyingTransform(StringTransform("Hans-Hant"), reverse: false) ?? self
    }
}
