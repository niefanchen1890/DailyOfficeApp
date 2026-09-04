import Combine
import Foundation

// MARK: - JSON 資料模型

struct PenitentialSentence: Codable, Hashable {
    let text: String
    let reference: String
}

struct PenitentialStandaloneBlock: Codable, Hashable {
    let rubric: String
    let sentences: [PenitentialSentence]
}

struct PenitentialResponsoryItem: Codable, Hashable {
    let leader: String
    let people: String?
}

struct PenitentialPrayerSection: Codable, Hashable {
    let rubric: String?
    let paragraphs: [String]
}

struct PenitentialHymn: Codable, Hashable {
    let title: String
    let verses: [String]
}

struct PenitentialPsalmSettings: Codable, Hashable {
    let number: String
    let fallbackTitle: String
    let loadingText: String
    let gloriaPatri: [String]
}

struct PenitentialServiceFile: Codable, Hashable {
    let title: String
    let standalone: PenitentialStandaloneBlock
    let embeddedRubric: String
    let beforePsalmRubric: String
    let afterPsalmRubric: String
    let kyrieResponses: [PenitentialResponsoryItem]
    let lordPrayerTitle: String
    let lordPrayerText: String
    let salvationResponses: [PenitentialResponsoryItem]
    let letUsPray: String
    let confessionPrayers: [PenitentialPrayerSection]
    let congregationRecitation: PenitentialPrayerSection
    let optionalOmitRubric: String
    let priestPrayer: PenitentialPrayerSection
    let ashResponses: [PenitentialResponsoryItem]
    let finalPrayers: [PenitentialPrayerSection]
    let hymn: PenitentialHymn
    let finalCollect: PenitentialPrayerSection
    let blessing: String
    let psalm: PenitentialPsalmSettings
    let leaderLabel: String
    let peopleLabel: String
}

// MARK: - JSON 載入與繁簡轉換

final class PenitentialServiceDataLoader {
    static let shared = PenitentialServiceDataLoader()
    private var cache: [AppLanguage: PenitentialServiceFile] = [:]

    private init() {}

    func clearCache() {
        cache.removeAll()
    }

    func load(language: AppLanguage = AppLanguageStore.shared.language) -> PenitentialServiceFile {
        if let cached = cache[language] { return cached }

        guard let url = Bundle.main.url(forResource: "penitential_service", withExtension: "json") else {
            fatalError("無法找到 penitential_service.json")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(PenitentialServiceFile.self, from: data)
            let localized = language == .simplified ? decoded.convertedToSimplified() : decoded
            cache[language] = localized
            return localized
        } catch {
            fatalError("無法解析 penitential_service.json：\(error)")
        }
    }
}

// MARK: - 畫面資料與詩篇載入邏輯

@MainActor
final class PenitentialServiceViewModel: ObservableObject {
    @Published private(set) var service: PenitentialServiceFile
    @Published private(set) var psalm51: PsalmContent?
    @Published private(set) var psalmTitle: String

    init() {
        let service = PenitentialServiceDataLoader.shared.load()
        self.service = service
        self.psalmTitle = service.psalm.fallbackTitle
    }

    func load(language: AppLanguage) {
        service = PenitentialServiceDataLoader.shared.load(language: language)
        loadPsalm()
    }

    func loadPsalm() {
        if let result = PsalmsLoader.shared.psalm(number: service.psalm.number) {
            psalm51 = result.content
            psalmTitle = result.title
        } else {
            psalm51 = nil
            psalmTitle = service.psalm.fallbackTitle
            AppLog.warning("⚠️ [懺悔文] 無法載入詩篇第\(service.psalm.number)篇")
        }
    }
}

// JSON 保存繁體原文；簡體模式在資料層統一轉換。
private extension PenitentialServiceFile {
    func convertedToSimplified() -> PenitentialServiceFile {
        PenitentialServiceFile(
            title: title.toSimplifiedChinese(),
            standalone: standalone.convertedToSimplified(),
            embeddedRubric: embeddedRubric.toSimplifiedChinese(),
            beforePsalmRubric: beforePsalmRubric.toSimplifiedChinese(),
            afterPsalmRubric: afterPsalmRubric.toSimplifiedChinese(),
            kyrieResponses: kyrieResponses.map { $0.convertedToSimplified() },
            lordPrayerTitle: lordPrayerTitle.toSimplifiedChinese(),
            lordPrayerText: lordPrayerText.toSimplifiedChinese(),
            salvationResponses: salvationResponses.map { $0.convertedToSimplified() },
            letUsPray: letUsPray.toSimplifiedChinese(),
            confessionPrayers: confessionPrayers.map { $0.convertedToSimplified() },
            congregationRecitation: congregationRecitation.convertedToSimplified(),
            optionalOmitRubric: optionalOmitRubric.toSimplifiedChinese(),
            priestPrayer: priestPrayer.convertedToSimplified(),
            ashResponses: ashResponses.map { $0.convertedToSimplified() },
            finalPrayers: finalPrayers.map { $0.convertedToSimplified() },
            hymn: hymn.convertedToSimplified(),
            finalCollect: finalCollect.convertedToSimplified(),
            blessing: blessing.toSimplifiedChinese(),
            psalm: psalm.convertedToSimplified(),
            leaderLabel: leaderLabel.toSimplifiedChinese(),
            peopleLabel: peopleLabel.toSimplifiedChinese()
        )
    }
}

private extension PenitentialStandaloneBlock {
    func convertedToSimplified() -> PenitentialStandaloneBlock {
        PenitentialStandaloneBlock(
            rubric: rubric.toSimplifiedChinese(),
            sentences: sentences.map {
                PenitentialSentence(text: $0.text.toSimplifiedChinese(), reference: $0.reference.toSimplifiedChinese())
            }
        )
    }
}

private extension PenitentialResponsoryItem {
    func convertedToSimplified() -> PenitentialResponsoryItem {
        PenitentialResponsoryItem(leader: leader.toSimplifiedChinese(), people: people?.toSimplifiedChinese())
    }
}

private extension PenitentialPrayerSection {
    func convertedToSimplified() -> PenitentialPrayerSection {
        PenitentialPrayerSection(
            rubric: rubric?.toSimplifiedChinese(),
            paragraphs: paragraphs.map { $0.toSimplifiedChinese() }
        )
    }
}

private extension PenitentialHymn {
    func convertedToSimplified() -> PenitentialHymn {
        PenitentialHymn(title: title.toSimplifiedChinese(), verses: verses.map { $0.toSimplifiedChinese() })
    }
}

private extension PenitentialPsalmSettings {
    func convertedToSimplified() -> PenitentialPsalmSettings {
        PenitentialPsalmSettings(
            number: number,
            fallbackTitle: fallbackTitle.toSimplifiedChinese(),
            loadingText: loadingText.toSimplifiedChinese(),
            gloriaPatri: gloriaPatri.map { $0.toSimplifiedChinese() }
        )
    }
}

private extension String {
    func toSimplifiedChinese() -> String {
        applyingTransform(StringTransform("Hant-Hans"), reverse: false) ?? self
    }
}
