import Foundation

/// 禮儀核心的集中例外規則表。
///
/// 這裡只保存規則資料；日期查詢、優先次序和畫面顯示仍由各自元件處理。
/// 新增特殊節期規則時，應先在這裡登記，避免再次散落於核心服務中。
enum LiturgicalRuleTable {
    struct PrecedencePair: Equatable {
        let winner: LiturgicalID
        let loser: LiturgicalID
    }

    struct Transition: Hashable {
        let today: LiturgicalID
        let tomorrow: LiturgicalID
    }

    struct MonthDay: Hashable {
        let month: Int
        let day: Int
    }

    /// 即使等級通常容許，也沒有第一晚禱的特殊日子。
    static let daysWithoutFirstVespers: Set<LiturgicalID> = [
        .trinityOctaveMonday,
        .trinityOctaveTuesday,
        .trinityOctaveWednesday,
        .paulCommemoration
    ]

    /// 同等級相遇時，不能只靠一般 priority 判斷的組合。
    static let equalRankPrecedence: [PrecedencePair] = [
        PrecedencePair(winner: .sacredHeart, loser: .corpusChristiOctaveDayEight)
    ]

    /// 當日晚禱必須改用明日第一晚禱的特殊日子。
    static let daysWhoseEveningUsesTomorrow: Set<LiturgicalID> = [
        .peterAndPaulOctaveDaySeven,
        .assumptionOctaveDaySeven,
        .corpusChristiOctaveDayEight
    ]

    /// 在晚禱合併紀念時，完全不應被帶入的日子。
    static let commemorationsExcludedFromEvening: Set<LiturgicalID> = [
        .peterAndPaulOctaveDaySeven,
        .assumptionOctaveDaySeven
    ]

    /// 不帶入相鄰晚禱的特殊紀念日。
    static let daysNotCarriedIntoAdjacentEvening: Set<LiturgicalID> = [
        .paulCommemoration
    ]

    /// 三一主日八日慶期中，遇高等級明日禮儀時不帶入晚禱的平日。
    static let trinityOctaveWeekdays: Set<LiturgicalID> = [
        .trinityOctaveMonday,
        .trinityOctaveTuesday,
        .trinityOctaveWednesday
    ]

    /// 第一晚禱不保留任何其他紀念的節期。
    static let firstVespersWithoutCommemorations: Set<LiturgicalID> = [
        .trinitySunday,
        .preciousBlood
    ]

    /// 第二晚禱不保留任何其他紀念的節期。
    static let secondVespersWithoutCommemorations: Set<LiturgicalID> = [
        .trinitySunday
    ]

    /// 指定主節日晚禱需要排除的特定紀念。
    static let secondVespersSuppressedCommemorations: [LiturgicalID: Set<LiturgicalID>] = [
        .preciousBlood: [.nativityOfJohnBaptistOctaveDayEight]
    ]

    /// 相接時需要排除前一節期紀念的特殊組合。
    static let exclusiveTransitions: Set<Transition> = [
        Transition(today: .corpusChristiOctaveDayEight, tomorrow: .sacredHeart)
    ]

    /// 聖體節八日慶期內，容許固定聖日依等級勝出的日期。
    static let corpusChristiOctaveFixedFeastDates: Set<MonthDay> = [
        MonthDay(month: 6, day: 11),
        MonthDay(month: 6, day: 24),
        MonthDay(month: 6, day: 29)
    ]
}
