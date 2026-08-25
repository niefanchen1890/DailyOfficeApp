import Foundation

// MARK: - 頌歌類型
enum CanticleType: String, Codable {
    // 早禱
    case teDeum = "teDeum"
    case benedicite = "benedicite"
    case benedictusEs = "benedictusEs"
    case benedictus = "benedictus" // 早禱第二頌歌（以色列頌）
    
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
    let benedictusEs: CanticleData
    let benedictus: CanticleData
    
    // 晚禱
    let magnificat: CanticleData
    let nuncDimittis: CanticleData
    let deusMisereatur: CanticleData
    let benedicAnimaMea: CanticleData
}

// MARK: - 頌歌載入器
struct CanticleLoader {
    static let shared = CanticleLoader()
    private let container: CanticleContainer
    
    init() {
        guard let url = Bundle.main.url(forResource: "canticles", withExtension: "json") else {
            fatalError("❌ 找不到 canticles.json，请检查 Target Membership / Copy Bundle Resources")
        }
        do {
            let data = try Data(contentsOf: url)
            self.container = try JSONDecoder().decode(CanticleContainer.self, from: data)
        } catch {
            fatalError("❌ canticles.json 解码失败：\(error)")
        }
    }
    
    // MARK: - 獲取頌歌內容
    func canticle(for type: CanticleType) -> CanticleData {
        switch type {
        case .teDeum: return container.teDeum
        case .benedicite: return container.benedicite
        case .benedictusEs: return container.benedictusEs
        case .benedictus: return container.benedictus
            
        case .magnificat: return container.magnificat
        case .nuncDimittis: return container.nuncDimittis
        case .deusMisereatur: return container.deusMisereatur
        case .benedicAnimaMea: return container.benedicAnimaMea
        }
    }
    
    // MARK: - 對經獲取方法
    
    /// 獲取以色列頌平日對經（禮拜一=1 ... 禮拜六=6）
    func benedictusWeekdayAntiphon(for weekday: Int) -> String? {
        let index = weekday - 1 // Calendar.weekday: 2=禮拜一, 7=禮拜六
        guard (1...6).contains(index) else { return nil }
        return container.benedictus.weekdayAntiphons?[String(index)]
    }
    
    /// 獲取尊主頌平日對經（禮拜一=1 ... 禮拜五=5）
    func magnificatWeekdayAntiphon(for weekday: Int) -> String? {
        let index = weekday - 1 // Calendar.weekday: 2=禮拜一, 6=禮拜五 (禮拜六為第一晚禱，通常用主日對經)
        guard (1...5).contains(index) else { return nil }
        return container.magnificat.weekdayAntiphons?[String(index)]
    }
    
    /// ⬇️ 預留：聖日對經覆蓋（以後實現）
    func benedictusFeastAntiphon(for feastName: String) -> String? {
        nil
    }
}
