import Foundation

class MassProperManager {
    static let shared = MassProperManager()
    
    private init() {}
    
    /// 讀取指定的 JSON 檔案並轉換為 MassProper 模型
    /// - Parameter filename: 檔案名稱 (不含副檔名，例如 "mass_0502")
    func loadProper(filename: String) -> MassProper? {
        // 尋找 Main Bundle 中的 JSON 檔案
        // 註：如果 Xcode 中加入資料夾時選擇 "Create groups"，檔案會自動扁平化，直接用檔名即可找到。
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("⚠️ 找不到檔案: \(filename).json")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let proper = try decoder.decode(MassProper.self, from: data)
            return proper
        } catch {
            print("❌ 解析 JSON 失敗 (\(filename)): \(error)")
            return nil
        }
    }
}




