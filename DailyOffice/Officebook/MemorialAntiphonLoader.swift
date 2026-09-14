import Foundation

class MemorialAntiphonsLoader {
    static let shared = MemorialAntiphonsLoader()
    private var cache: [String: MemorialAntiphonsContainer] = [:]
    
    private init() {}
    
    private func load(resourceName: String, language: AppLanguage) -> MemorialAntiphonsContainer? {
        let cacheKey = "\(resourceName)|\(language.rawValue)"
        if let cached = cache[cacheKey] { return cached }

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let localizedData = LocalizedJSONResolver.resolve(data: data, language: language),
              let decoded = try? JSONDecoder().decode(MemorialAntiphonsContainer.self, from: localizedData) else {
            AppLog.error("❌ 無法載入或解析 \(resourceName).json")
            return nil
        }
        cache[cacheKey] = decoded
        return decoded
    }
    
    func getContainer(language: AppLanguage) -> MemorialAntiphonsContainer? {
        load(resourceName: "memorial_antiphons", language: language)
    }

    func eveningSeasonalAntiphon(for key: String, language: AppLanguage) -> SeasonalAntiphonData? {
        load(resourceName: "evening_seasonal_antiphons", language: language)?
            .seasonalAntiphons
            .first { $0.seasonKeys.contains(key) }
    }
}
