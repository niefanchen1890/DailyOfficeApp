import Foundation
import Combine

// MARK: - 亞他那修信經 JSON 結構
struct AthanasianCreedJSON: Codable {
    let title: BilingualText
    let rubric: BilingualText
    let paragraphs: [BilingualText]
}

// MARK: - 信經與信仰宣告加載器
class CreedsDataLoader: ObservableObject {
    static let shared = CreedsDataLoader()
    
    @Published var athanasianCreed: AthanasianCreedJSON?
    
    init() {
        loadAthanasianCreed()
    }
    
    private func loadAthanasianCreed() {
        guard let url = Bundle.main.url(forResource: "athanasian_creed", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ 無法載入 athanasian_creed.json")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(AthanasianCreedJSON.self, from: data)
            DispatchQueue.main.async {
                self.athanasianCreed = decoded
            }
        } catch {
            print("❌ 解析 athanasian_creed.json 失敗: \(error)")
        }
    }
    
    // MARK: - 判斷當日是否誦唸亞他那修信經
    static func shouldShowAthanasianCreed(for date: Date) -> Bool {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        let daysToEaster = info.daysFromEaster
        let weekday = info.weekday
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        // 固定聖日（月日匹配）
        let fixedFeasts: [(Int, Int)] = [
            (12, 25), // 救主聖誕日
            (1, 6),   // 顯現日
            (2, 24),  // 聖馬提亞日
            (6, 24),  // 施洗聖約翰日
            (7, 25),  // 聖雅各日
            (8, 24),  // 聖巴多羅買日
            (9, 21),  // 聖馬太日
            (10, 28), // 聖西門與聖猶大日
            (11, 30), // 聖安德烈日
        ]
        if fixedFeasts.contains(where: { $0 == (month, day) }) {
            return true
        }
        
        // 移動節日
        if daysToEaster == 0 { return true }                   // 復活日
        if daysToEaster == 39 { return true }                  // 升天日
        if daysToEaster == 49 { return true }                  // 聖靈降臨日
        if daysToEaster == 56 && weekday == 1 { return true }  // 聖三一主日
        
        return false
    }
}
