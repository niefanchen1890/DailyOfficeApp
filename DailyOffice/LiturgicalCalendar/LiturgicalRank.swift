import Foundation

// MARK: - 禮儀等級 (Liturgical Rank)
/// 負責定義安立甘傳統中各個日子的優先級。數字越大，優先級越高。
/// 實作 `Comparable` 協議後，我們可以直接使用 `>` 或 `<` 來比較兩個日子誰勝出。
public enum LiturgicalRank: Double, Comparable {
    
    // 100 級以上
    case privilegedFeria = 1000             // 特權大平日 (如大齋首日、聖週一至三)
    
    // 10 級以上：一等
    case privilegedVigilFirstClass = 120    // 一等特權望日，半複式
    case sundayFirstClassGreat = 111
    case sundayFirstClass = 110             // 一等主日 （半複式)

    
    case doubleFirstClass = 100             // 一等複式 (含遷移)
    
    // 8 - 9 級：二等
    case sundaySecondClass = 95             // 二等主日，半複式
    case doubleSecondClass = 90             // 二等複式 (含遷移)
    
    // 7 級：普通主日與特殊特權
    case privilegedOctaveFirstClass = 79   // 一等特權八日慶期，半複式
    case privilegedOctaveSecondClassGreat = 81 // 二等特權八日慶期，大複式
    case privilegedOctaveSecondClass = 78      // 二等特權八日慶期，半複式
    case privilegedOctaveThirdClassGreat = 76  // 三等特權八日慶期，大複式
    case privilegedVigilSecondClass = 74    // 二等特權望日，半複式
    case ordinarySunday = 85                // 普通主日，半複式
    case privilegedOctaveThirdClass = 65    // 三等特權八日慶期，半複式
    case ordinaryOctavegreaterDouble = 64   // 普通八日慶期，大複式
    case greaterDouble = 63                 // 大複式
    case double = 62                        // 複式
    case semiDouble = 61                    // 半複式 (含遷移)
    case ordinaryOctavesemiDouble = 60    // 普通八日慶期，半複式
    case greaterFeria = 55                // 非特權大平日 (如降臨期平日)
    case saturdayOfficeBVM = 51           // 禮拜六特敬聖母：只高於簡式慶日
    case simple = 50                        // 簡式
    case commemoration = 45                 // 紀念
    case vigil = 40                         // 望日
    case feria = 10                         // 普通平日
    case none = 0.0                          // 無等級 / 未定義

    // MARK: - 大小比較
    // Swift 自帶 Comparable，這行代碼讓系統知道「用 rawValue (小數) 來比大小」
    public static func < (lhs: LiturgicalRank, rhs: LiturgicalRank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - 相容舊版資料解析
extension LiturgicalRank {
    /// 如果你未來打算將 PHP 的 data 直接轉成 JSON 讀入，
    /// 這個方法能把以前的字串（如 "（一等主日，一等複式）"）自動轉換為安全的 Swift Enum。
    public static func parse(from string: String) -> LiturgicalRank {
        switch string {
        case "（特權大平日）": return .privilegedFeria
        case "（一等特權望日，半複式）": return .privilegedVigilFirstClass
        case "（一等主日，大複式）": return .sundayFirstClassGreat
        case "（一等主日，半複式）": return .sundayFirstClass
        case "（一等複式）",
             "（一等複式，遷移至今日）": return .doubleFirstClass
        case "（二等主日，半複式）": return .sundaySecondClass
        case "（二等複式）",
             "（二等複式，遷移至今日）": return .doubleSecondClass
        case "（一等特權八日慶期，半複式）": return .privilegedOctaveFirstClass
        case "（二等特權望日，半複式）": return .privilegedVigilSecondClass
        case "（二等特權八日慶期，半複式）": return .privilegedOctaveSecondClass
        case "（二等特權八日慶期，大複式）": return .privilegedOctaveSecondClassGreat
        case "（三等特權八日慶期，半複式）": return .privilegedOctaveThirdClass
        case "（三等特權八日慶期，大複式）": return .privilegedOctaveThirdClassGreat
        case "（普通八日慶期，大複式）": return .ordinaryOctavegreaterDouble
        case "（普通八日慶期，半複式）": return .ordinaryOctavesemiDouble
        case "（普通主日，半複式）": return .ordinarySunday
        case "（大複式）": return .greaterDouble
        case "（複式）": return .double
        case "（半複式）",
             "（半複式，遷移至今日）": return .semiDouble
        case "（非特權大平日）": return .greaterFeria
        case "（禮拜六特敬聖母）": return .saturdayOfficeBVM
        case "（簡式）", "（簡式八日慶期，簡式）", "簡式八日慶期，簡式": return .simple
        case "（紀念）": return .commemoration
        case "（望日）": return .vigil
        case "（普通平日）": return .feria
        default: return .none
        }
    }
}



extension LiturgicalRank {
    var displayName: String {
        switch self {
        case .privilegedFeria:              return "特權大平日"
        case .privilegedVigilFirstClass:   return "一等特權望日，半複式"
        case .sundayFirstClassGreat:        return "一等主日，大複式"
        case .sundayFirstClass:             return "一等主日，半複式"
        case .doubleFirstClass:             return "一等複式"
        case .sundaySecondClass:            return "二等主日，半複式"
        case .doubleSecondClass:            return "二等複式"
        case .privilegedOctaveFirstClass:   return "一等特權八日慶期，半複式"
        case .privilegedOctaveSecondClassGreat: return "二等特權八日慶期，大複式"
        case .privilegedOctaveSecondClass:  return "二等特權八日慶期，半複式"
        case .privilegedVigilSecondClass:   return "二等特權望日，半複式"
        case .privilegedOctaveThirdClass:   return "三等特權八日慶期，半複式"
        case .privilegedOctaveThirdClassGreat: return "三等特權八日慶期，大複式"
        case .ordinaryOctavegreaterDouble:  return "普通八日慶期，大複式"
        case .ordinaryOctavesemiDouble:     return "普通八日慶期，半複式"
        case .ordinarySunday:               return "普通主日，半複式"
        case .greaterDouble:                return "大複式"
        case .double:                       return "複式"
        case .semiDouble:                   return "半複式"
        case .greaterFeria:                 return "非特權大平日"
        case .saturdayOfficeBVM:            return "禮拜六特敬聖母"
        case .simple:                       return "簡式"
        case .commemoration:                return "紀念"
        case .vigil:                        return "望日"
        case .feria:                        return "普通平日"
        case .none:                         return ""
        }
    }
}


extension LiturgicalRank {
    /// 簡式八日慶期保持簡式的數值與優先級，只按結構化特徵細分顯示。
    func displayName(for traits: LiturgicalTraits) -> String {
        self == .simple && traits.octave?.isDayEight == true
            ? "簡式八日慶期，簡式" : displayName
    }
}
