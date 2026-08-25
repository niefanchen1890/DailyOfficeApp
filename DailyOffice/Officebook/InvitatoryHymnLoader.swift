import Foundation

// MARK: - 邀請聖詩類型
enum InvitatoryHymnType {
    case sundayWinter   // Primo Dierum Omnium
    case sundaySummer   // Nocte surgentes
    case weekday(Int)   // 1=禮拜一 ... 6=禮拜六
}

// MARK: - 邀請聖詩數據模型
struct InvitatoryHymnData: Codable {
    let title: String
    let seasonNote: String?
    let verses: [String]
}

private struct InvitatoryHymnContainer: Codable {
    let sundayWinter: InvitatoryHymnData
    let sundaySummer: InvitatoryHymnData
    let weekday: [String: InvitatoryHymnData]
}

// MARK: - 邀請聖詩載入器
struct InvitatoryHymnLoader {
    static let shared = InvitatoryHymnLoader()
    private let container: InvitatoryHymnContainer
    
    init() {
        guard let url = Bundle.main.url(forResource: "hymns", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(InvitatoryHymnContainer.self, from: data) else {
            fatalError("無法載入 hymns.json")
        }
        self.container = decoded
    }
    
    func hymn(_ type: InvitatoryHymnType) -> InvitatoryHymnData {
        switch type {
        case .sundayWinter:
            return container.sundayWinter
        case .sundaySummer:
            return container.sundaySummer
        case .weekday(let index):
            let key = String(index)
            return container.weekday[key] ?? container.weekday["1"]!
        }
    }
}
