import Foundation
import Combine

class LitanyDataLoader: ObservableObject {
    static let shared = LitanyDataLoader()
    
    @Published var uiData: UILitanyData?
    
    init() {
        loadData()
    }
    
    func loadData() {
        // 因為 JSON 已包含雙語，只需載入一次即可
        guard let url = Bundle.main.url(forResource: "litany_data", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            AppLog.error("❌ 無法找到 litany_data.json")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(LitanyDataJSON.self, from: data)
            
            // 轉換為帶有 UUID 的 UI 專用模型
            let model = UILitanyData(
                title: decoded.title,
                mainRubric: decoded.mainRubric,
                mainResponses: decoded.mainResponses.map { UILitanyResponsory(leader: $0.leader, people: $0.people) },
                lordPrayer: decoded.lordPrayer,
                lordPrayerNote: decoded.lordPrayerNote,
                intermediateResponses: decoded.intermediateResponses.map { UILitanyResponsory(leader: $0.leader, people: $0.people) },
                intermediatePrayer: decoded.intermediatePrayer,
                middleRecitations: decoded.middleRecitations.map { UILitanyRecitation(rubric: $0.rubric, text: $0.text) },
                closingResponses: decoded.closingResponses.map { UILitanyResponsory(leader: $0.leader, people: $0.people) },
                closingPrayer: decoded.closingPrayer,
                finalRubric: decoded.finalRubric
            )
            
            DispatchQueue.main.async {
                self.uiData = model
            }
        } catch {
            AppLog.error("❌ 解析 litany_data.json 失敗: \(error)")
        }
    }
}
