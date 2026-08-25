import Foundation

struct EveningHymnLoader {
    static let shared = EveningHymnLoader()
    private var hymns: [String: OfficeHymnData] = [:]

    init() {
        if let url = Bundle.main.url(forResource: "evening_hymns", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            // 注意：這裡解碼為 [String: OfficeHymnData] 以對應 JSON 的 Key
            self.hymns = (try? JSONDecoder().decode([String: OfficeHymnData].self, from: data)) ?? [:]
        }
    }

    func getHymn(for key: String) -> OfficeHymnData? {
        return hymns[key]
    }
}
