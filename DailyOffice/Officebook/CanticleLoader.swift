import Foundation

// MARK: - 頌歌類型
enum CanticleType: String, Codable, CaseIterable {
    // 早禱
    case teDeum = "teDeum"
    case benedicite = "benedicite"
    case cantemusDomino = "cantemusDomino" // 🌟 新增：摩西頌
    case teLaudamus = "teLaudamus"         // 🌟 新增：安波羅修頌
    case benedictusEs = "benedictusEs"
    case benedictus = "benedictus" // 早禱第二頌歌（以色列頌）
    case jubilateDeo = "jubilateDeo"
    
    // 晚禱
    case magnificat = "magnificat"         // 晚禱第一頌歌（尊主頌）
    case nuncDimittis = "nuncDimittis"     // 晚禱第二頌歌（西面頌）
    case deusMisereatur = "deusMisereatur" // 晚禱替代頌歌（憐憫頌）
    case benedicAnimaMea = "benedicAnimaMea" // 晚禱替代頌歌（心靈頌）
}

// MARK: - 頌歌數據模型
struct CanticleData: Codable {
    let title: String
    let subtitle: String?
    let rubric: String?
    let style: String // "prose" | "responsive"
    let paragraphs: [String]?
    let sections: [[CanticleVerse]]?
    let verses: [CanticleVerse]?
    let doxology: String?
    let weekdayAntiphons: [String: String]? // 供以色列頌、尊主頌使用
}

struct CanticleVerse: Codable, Identifiable, Hashable {
    var id: String { call + "|" + response }
    let call: String
    let response: String
}

// MARK: - 頌歌容器
struct CanticleContainer: Codable {
    // 早禱
    let teDeum: CanticleData
    let benedicite: CanticleData
    let cantemusDomino: CanticleData? // 🌟 可選，以兼容舊版
    let teLaudamus: CanticleData?     // 🌟 可選，以兼容舊版
    let benedictusEs: CanticleData
    let benedictus: CanticleData
    let jubilateDeo: CanticleData?
    
    // 晚禱
    let magnificat: CanticleData
    let nuncDimittis: CanticleData
    let deusMisereatur: CanticleData
    let benedicAnimaMea: CanticleData
}

// MARK: - 🌟 頌歌載入器 (雙語化重構)
class CanticleLoader {
    static let shared = CanticleLoader()
    private var cache: [AppLanguage: CanticleContainer] = [:]
    
    func clearCache() {
        cache.removeAll()
    }
    
    private func loadContainer(language: AppLanguage) -> CanticleContainer {
        if let cached = cache[language] { return cached }
        
        guard let url = Bundle.main.url(forResource: "canticles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              // 🌟 透過 Resolver 將 { "zh-hant": "...", "zh-hans": "..." } 扁平化為 String
              let localizedData = LocalizedJSONResolver.resolve(data: data, language: language),
              let decoded = try? JSONDecoder().decode(CanticleContainer.self, from: localizedData) else {
            fatalError("❌ canticles.json 解碼或多語言解析失敗")
        }
        cache[language] = decoded
        return decoded
    }
    
    // MARK: - 獲取頌歌內容
    func canticle(for type: CanticleType, language: AppLanguage? = nil) -> CanticleData {
        let lang = language ?? MorningPrayerDataLoader.shared.currentLanguage
        let container = loadContainer(language: lang)
        
        switch type {
        case .teDeum: return container.teDeum
        case .benedicite: return container.benedicite
        case .cantemusDomino: return container.cantemusDomino ?? container.teDeum
        case .teLaudamus: return container.teLaudamus ?? container.teDeum
        case .benedictusEs: return container.benedictusEs
        case .benedictus: return container.benedictus
        case .jubilateDeo: return container.jubilateDeo ?? container.benedictus
        case .magnificat: return container.magnificat
        case .nuncDimittis: return container.nuncDimittis
        case .deusMisereatur: return container.deusMisereatur
        case .benedicAnimaMea: return container.benedicAnimaMea
        }
    }
    
    // MARK: - 對經獲取方法
    func benedictusWeekdayAntiphon(for weekday: Int, language: AppLanguage? = nil) -> String? {
        let lang = language ?? MorningPrayerDataLoader.shared.currentLanguage
        let container = loadContainer(language: lang)
        let index = weekday - 1 // Calendar.weekday: 2=禮拜一, 7=禮拜六
        guard (1...6).contains(index) else { return nil }
        return container.benedictus.weekdayAntiphons?[String(index)]
    }
    
    func magnificatWeekdayAntiphon(for weekday: Int, language: AppLanguage? = nil) -> String? {
        let lang = language ?? MorningPrayerDataLoader.shared.currentLanguage
        let container = loadContainer(language: lang)
        let index = weekday - 1 // Calendar.weekday: 2=禮拜一, 6=禮拜五
        guard (1...5).contains(index) else { return nil }
        return container.magnificat.weekdayAntiphons?[String(index)]
    }
    
    func benedictusFeastAntiphon(for feastName: String) -> String? {
        nil
    }
}
