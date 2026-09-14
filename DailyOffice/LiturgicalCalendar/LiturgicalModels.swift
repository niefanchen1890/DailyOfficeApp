import Foundation
import Combine
import SwiftUI


// MARK: - 2. 季候與經課表資料結構
struct SeasonInfo {
    var season: LiturgicalSeason // 這裡改用 LiturgicalSeason
    var weekNumber: Int
    var weekday: Int      // 1 (日) 到 7 (六)
    var daysFromEaster: Int
    var name: String   
}

// MARK: - 全域工具函數
/// 將數字轉換為中文大寫，用於主日、週數、復活後日數顯示
func numberToChinese(_ number: Int) -> String {
    let numStrings = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十",
                      "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                      "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七",
                      "廿八", "廿九", "三十", "卅一", "卅二", "卅三", "卅四", "卅五",
                      "卅六", "卅七", "卅八", "卅九", "四十", "卌一", "卌二"]
    guard number >= 0 && number < numStrings.count else { return "\(number)" }
    return numStrings[number]
}


func getWeekdaySuffix(_ weekday: Int) -> String {
    // weekday: 1(日), 2(一), 3(二), 4(三), 5(四), 6(五), 7(六)
    let suffixes = ["", "日", "一", "二", "三", "四", "五", "六"]
    guard weekday >= 1 && weekday < suffixes.count else { return "" }
    return suffixes[weekday]
}

/// 全域統一的星期稱呼函數
func getWeekdayName(_ weekday: Int) -> String {
    if weekday == 1 { return "主日" }
    return "禮拜\(getWeekdaySuffix(weekday))"
}



