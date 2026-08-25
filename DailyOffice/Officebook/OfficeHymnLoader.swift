import Foundation

enum OfficeHymnType: Equatable {
    case sundayEpiphany
    case sundayTrinity
    case weekday(Int)
    case feast(String)
}

struct OfficeHymnLoader {
    static let shared = OfficeHymnLoader()
    private var hymns: [String: OfficeHymnData] = [:]
    
    private init() {
        guard let url = Bundle.main.url(forResource: "morning_hymns", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ 無法載入 morning_hymns.json")
            return
        }
        do {
            let container = try JSONDecoder().decode(OfficeHymnContainer.self, from: data)
            hymns["sundayEpiphany"] = container.sundayEpiphany
            hymns["sundayTrinity"] = container.sundayTrinity
            if let wd = container.weekday {
                for (k, v) in wd { hymns["weekday_\(k)"] = v }
            }
        } catch {
            print("❌ 解析 morning_hymns.json 失敗: \(error)")
        }
    }
    
    func hymn(_ type: OfficeHymnType) -> OfficeHymnData {
        let key: String
        switch type {
        case .sundayEpiphany: key = "sundayEpiphany"
        case .sundayTrinity:  key = "sundayTrinity"
        case .weekday(let i): key = "weekday_\(i)"
        case .feast(let id):  key = "feast_\(id)"
        }
        return hymns[key] ?? OfficeHymnData(
            title: "聖詩暫缺", latinTitle: "", seasonNote: nil,
            verses: ["本日聖詩數據尚未載入"], versicle: nil
        )
    }
    
    func feastHymn(for feastName: String) -> OfficeHymnData? {
        hymns["feast_\(feastName)"]
    }
}

private struct OfficeHymnContainer: Codable {
    let sundayEpiphany: OfficeHymnData
    let sundayTrinity: OfficeHymnData
    let weekday: [String: OfficeHymnData]?
}
