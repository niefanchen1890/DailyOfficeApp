import Foundation

class MemorialAntiphonsLoader {
    static let shared = MemorialAntiphonsLoader()
    private var container: MemorialAntiphonsContainer?
    
    private init() {
        loadJSON()
    }
    
    private func loadJSON() {
        guard let url = Bundle.main.url(forResource: "memorial_antiphons", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(MemorialAntiphonsContainer.self, from: data) else {
            AppLog.error("❌ 無法載入或解析 memorial_antiphons.json")
            return
        }
        self.container = decoded
    }
    
    func getContainer() -> MemorialAntiphonsContainer? {
        return container
    }
}
