import Foundation

// 1. 經課表的統一資料結構 (全專案唯一宣告)
struct LectionaryDay: Hashable, Identifiable {
    var id: String { "\(season)-\(weekIndex)-\(dayKey)-\(book)-\(chapter)" }
    let season: String
    let weekIndex: Int
    let dayKey: String
    let book: String
    let chapter: String
}

// 2. 節期大分類定義
enum LiturgicalSeason: String, CaseIterable {
    case advent = "ad"
    case christmas = "ch"
    case epiphany = "ep"
    case prelenten = "prele"
    case lent = "le"
    case holyWeek = "ho"
    case easter = "ea"
    case ascension = "as"
    case pentecost = "pe"
    case trinity = "tr"
    case holyDays = "holy"
    
    var title: String {
        switch self {
        case .advent: return "降臨期 (Advent)"
        case .christmas: return "聖誕期 (Christmas)"
        case .epiphany: return "顯現期 (Epiphany)"
        case .prelenten: return "大齋期預備期 (Pre Lenten)"
        case .lent: return "大齋期 (Lent)"
        case .easter: return "復活期 (Easter)"
        case .holyWeek: return "聖週 (HolyWeek)"
        case .ascension: return "升天期（Ascension）"
        case .pentecost: return "聖靈降臨期（Pentecost）"
        case .trinity: return "三一期 (Trinity)"
        case .holyDays: return "聖日 (Holy Days)"
        }
    }
}



