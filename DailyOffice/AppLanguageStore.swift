import Combine
import Foundation

enum AppLanguage: String, CaseIterable, Hashable {
    case traditional = "zh-Hant"
    case simplified = "zh-Hans"
}

/// 全 App 唯一的繁簡語言狀態與切換入口。
final class AppLanguageStore: ObservableObject {
    static let shared = AppLanguageStore()
    static let userDefaultsKey = "appLanguage"

    @Published private(set) var language: AppLanguage

    var languageCode: String { language.rawValue }
    var isSimplified: Bool { language == .simplified }

    private init() {
        let savedCode = UserDefaults.standard.string(forKey: Self.userDefaultsKey)
        language = AppLanguage(rawValue: savedCode ?? "") ?? .traditional
    }

    func setLanguage(_ newLanguage: AppLanguage) {
        let didChange = language != newLanguage

        language = newLanguage
        UserDefaults.standard.set(newLanguage.rawValue, forKey: Self.userDefaultsKey)

        guard didChange else { return }
        clearLanguageDependentCaches()
    }

    func setLanguage(code: String) {
        guard let newLanguage = AppLanguage(rawValue: code) else { return }
        setLanguage(newLanguage)
    }

    func toggleLanguage() {
        setLanguage(language == .traditional ? .simplified : .traditional)
    }

    private func clearLanguageDependentCaches() {
        MorningPrayerDataLoader.shared.clearCache()
        EveningPrayerDataLoader.shared.clearCache()
        DailyOfficeLoader.shared.clearCache()

        BibleSentencesLoader.shared.clearCache()
        BibleSentencesLoader.eveningShared.clearCache()
        BibleJSONService.shared.clearCache()
        CanticleLoader.shared.clearCache()

        MinorHourPrayerDataLoader.shared.clearCache()
        ComplinePrayerDataLoader.shared.clearCache()
        HomePrayerDataLoader.shared.clearCache()
        PenitentialServiceDataLoader.shared.clearCache()
    }
}
