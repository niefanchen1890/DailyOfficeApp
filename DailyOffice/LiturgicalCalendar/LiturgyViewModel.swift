import SwiftUI
import Combine

class LiturgyViewModel: ObservableObject {
    @Published var currentLiturgy: DailyLiturgy?
    @Published var selectedDate = Date()
    
    // 🌟 修正 1：改用單例模式調用合併後的服務
    private let coreService = LiturgyCoreService.shared
    
    // 初始化的時候先更新一次
    init() {
        updateLiturgy()
    }
    
    func updateLiturgy() {
        // 🌟 修正 2：直接調用核心服務的 resolve 方法。
        // 這個方法內部已經處理了：復活節計算、節期判定、聖日衝突比對、
        // 優先級（一等複式、普通主日）、簡式省略、以及顏色判定。
        
        // 不需要再這裡寫 if let feast = feast，因為 resolve 內部已經寫好了。
        self.currentLiturgy = coreService.resolve(for: selectedDate)
    }
    
    // 🌟 修正 3：原本在 ViewModel 裡的 getSeasonColor 和 getFeastColor 都可以刪除。
    // 因為這些邏輯已經全部整合在 LiturgyCoreService 的 determineColor 私有方法中了。
    // 這樣可以確保 UI 顯示的顏色與禮儀規章完全一致。
}
