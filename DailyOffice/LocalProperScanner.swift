import SwiftUI
import Foundation
import Combine


// MARK: - 資料結構
struct MonthGroup: Identifiable {
    let id: String          // 月份代碼，例如 "05"
    let name: String        // 顯示名稱，例如 "五月"
    let fileIDs: [String]   // 該月包含的檔案名稱，例如 ["0502", "0503"]
}

// MARK: - 本地檔案掃描器
class LocalProperScanner: ObservableObject {
    @Published var yearlyPropers: [MonthGroup] = []
    
    init() {
        scanLocalFiles()
    }
    
    func scanLocalFiles() {
        // 1. 尋找 App Bundle 中所有的 .json 檔案
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            return
        }
        
        var monthDict: [String: [String]] = [:]
        
        // 2. 遍歷檔案，過濾並分類
        for url in urls {
            let filename = url.deletingPathExtension().lastPathComponent
            
            // 確保檔名是 4 個字元，且都是數字 (例如 "0502")
            // 這樣可以避免抓到 manifest.json 或其他無關的設定檔
            guard filename.count == 4, Int(filename) != nil else { continue }
            
            // 取前兩個字元當作月份 (例如 "0502" 取出 "05")
            let monthPrefix = String(filename.prefix(2))
            
            // 將檔名加入對應的月份陣列中
            monthDict[monthPrefix, default: []].append(filename)
        }
        
        // 3. 準備月份名稱對照表
        let monthNames = [
            "01": "一月", "02": "二月", "03": "三月", "04": "四月",
            "05": "五月", "06": "六月", "07": "七月", "08": "八月",
            "09": "九月", "10": "十月", "11": "十一月", "12": "十二月"
        ]
        
        var groups: [MonthGroup] = []
        
        // 4. 將字典轉為陣列，並依照月份與日期進行排序
        for key in monthDict.keys.sorted() {
            let name = monthNames[key] ?? "\(key)月"
            // 將月份內的日期也由小到大排序 (例如 0502 優先於 0503)
            let sortedFiles = monthDict[key]!.sorted()
            
            groups.append(MonthGroup(id: key, name: name, fileIDs: sortedFiles))
        }
        
        // 5. 更新 UI 資料
        self.yearlyPropers = groups
    }
}
