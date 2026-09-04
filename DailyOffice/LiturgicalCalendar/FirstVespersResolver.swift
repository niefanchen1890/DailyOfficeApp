import Foundation

/// 專門判斷某禮儀日是否具有第一晚禱資格。
/// 判斷只使用穩定 identifier 與禮儀等級，不讀取中文顯示名稱。
struct FirstVespersResolver {
    func isVigil(_ liturgy: DailyLiturgy) -> Bool {
        liturgy.traits.isVigil
    }

    func hasFirstVespers(_ liturgy: DailyLiturgy) -> Bool {
        if liturgy.traits.isWithinOctave && !liturgy.traits.octave!.isDayEight {
            return false
        }

        if LiturgicalRuleTable.daysWithoutFirstVespers.contains(liturgy.identifier) {
            return false
        }

        switch liturgy.rank {
        case .feria,
             .commemoration,
             .greaterFeria,
             .privilegedFeria,
             .vigil,
             .privilegedVigilSecondClass,
             .privilegedVigilFirstClass:
            return false
        default:
            return true
        }
    }

}
