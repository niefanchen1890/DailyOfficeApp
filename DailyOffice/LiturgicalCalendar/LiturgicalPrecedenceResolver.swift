import Foundation

/// 同級禮儀日相遇時所需的資料。
struct EqualRankPrecedenceContext {
    let todayIdentifier: LiturgicalID
    let tomorrowIdentifier: LiturgicalID
    let todayIsFixedFeast: Bool
    let tomorrowIsFixedFeast: Bool
    let todayPriority: Int
    let tomorrowPriority: Int
}

/// 只負責比較禮儀優先次序，不查日期、不讀中文名稱。
struct LiturgicalPrecedenceResolver {
    func tomorrowWins(_ context: EqualRankPrecedenceContext) -> Bool {
        for pair in LiturgicalRuleTable.equalRankPrecedence {
            if context.tomorrowIdentifier == pair.winner,
               context.todayIdentifier == pair.loser {
                return true
            }
            if context.todayIdentifier == pair.winner,
               context.tomorrowIdentifier == pair.loser {
                return false
            }
        }

        if context.tomorrowIsFixedFeast != context.todayIsFixedFeast {
            return context.tomorrowIsFixedFeast
        }

        if context.tomorrowPriority != context.todayPriority {
            return context.tomorrowPriority > context.todayPriority
        }

        return false
    }
}
