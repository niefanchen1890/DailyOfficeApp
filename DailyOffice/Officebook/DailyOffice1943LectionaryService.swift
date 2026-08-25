import Foundation

// MARK: - 1943 年日課經課服務
//
// 最新資料方式：
// 一個早禱 / 晚禱單元 = 一個 JSON 文件。
//
// 檔名格式：
// office1943_{seasonWeek}-yr{1/2/3}-{dayIndex}-{office}.json
//
// 例：
// office1943_tr1-yr1-0-M.json
// office1943_tr1-yr2-0-M.json
// office1943_tr1-yr1-1-M.json
// office1943_tr1-yr1-0-E.json
//
// 注意：節期經課文件不使用 V。
// 前夕晚禱若需要專用經課，直接寫在聖日 JSON 的 vigil.lectionary_sets.1943 裡。
//
// 每個文件內包含：
// - psalms
// - lessons.ot
// - lessons.nt
//
// 主日多組：建立 yr1 / yr2 / yr3 多個文件。
// 平日單組：通常只建立 yr1 文件。

final class DailyOffice1943LectionaryService {
    static let shared = DailyOffice1943LectionaryService()
    
    typealias OfficeSet = DailyOfficeFile.OfficePeriod.LectionarySet
    
    private let calendar = Calendar.current
    
    private init() {}
    
    // MARK: - 對外主入口
    
    /// 取得指定日期、早禱/晚禱的 1943 年日課組。
    ///
    /// 查找順序：
    /// 1. 當日禮儀 JSON 內的 lectionary_sets.1943
    /// 2. 按最新「一個日課單元一個 JSON」方式查找：
    ///    office1943_{seasonWeek}-yr1-{dayIndex}-{office}.json
    ///    office1943_{seasonWeek}-yr2-{dayIndex}-{office}.json
    ///    office1943_{seasonWeek}-yr3-{dayIndex}-{office}.json
    ///
    /// 找到幾個 yr 文件，就返回幾組。
    func officeSets(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool
    ) -> [OfficeSet] {
        // 1. 聖日 / 專日 JSON override 維持原本前夕邏輯：
        //    若畫面是「某聖日前夕晚禱」，就用明日日期去讀明日 JSON 的 vigil / evening。
        //    這個優先級最高，可以直接覆蓋節期經課。
        let overrideDate = effectiveDate(
            for: date,
            liturgy: liturgy,
            isEvening: isEvening
        )
        
        let overrideSets = DailyOfficeLoader.shared.lectionarySets(
            for: overrideDate,
            liturgy: liturgy,
            isEvening: isEvening,
            year: "1943"
        )
        if !overrideSets.isEmpty {
            return applyConditionalLectionaryRules(
                to: overrideSets,
                for: overrideDate,
                isEvening: isEvening
            )
        }
        
        // 2. 節期 1943 文件不使用前夕邏輯：
        //    即使畫面標題顯示「某主日前夕晚禱」，節期經課仍讀取當天自己的晚禱。
        //    例如：聖靈降臨節禮拜六晚禱，仍讀 pentecost / saturday / E，
        //    不跳到三一主日的前夕文件。
        let temporalDate = date
        let prefixes = candidateSeasonWeekPrefixes(for: temporalDate)
        let dayIndex = weekdayToDayIndex(calendar.component(.weekday, from: temporalDate))
        let offices = officeCodes(isEvening: isEvening)
        
        for prefix in prefixes {
            for office in offices {
                let sets = loadGroupedSets(
                    prefix: prefix,
                    dayIndex: dayIndex,
                    office: office
                )
                
                if !sets.isEmpty {
                    return applyConditionalLectionaryRules(
                        to: sets,
                        for: temporalDate,
                        isEvening: isEvening
                    )
                }
            }
        }
        
        return []
    }
    
    func officeSet(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool,
        setId: String?
    ) -> OfficeSet? {
        let sets = officeSets(
            for: date,
            liturgy: liturgy,
            isEvening: isEvening
        )
        
        if let setId = setId,
           let selected = sets.first(where: { $0.id == setId }) {
            return selected
        }
        
        return sets.first
    }
    
    func hasOfficeSets(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool
    ) -> Bool {
        !officeSets(
            for: date,
            liturgy: liturgy,
            isEvening: isEvening
        ).isEmpty
    }
    
    // MARK: - 文件查找
    
    private func loadGroupedSets(
        prefix: String,
        dayIndex: Int,
        office: String
    ) -> [OfficeSet] {
        var sets: [OfficeSet] = []
        
        // 1943 主日最多三組；平日通常只有 yr1。
        // 若只存在 yr1，會返回單組；若存在 yr1 + yr2，會返回兩組。
        for groupIndex in 1...3 {
            let group = "yr\(groupIndex)"
            let resourceName = "office1943_\(prefix)-\(group)-\(dayIndex)-\(office)"
            
            if let set = loadOfficeSet(resourceName: resourceName, groupIndex: groupIndex) {
                sets.append(set)
            }
        }
        
        return sets
    }
    
    // MARK: - 1943 專用條件經課規則
    
    private func applyConditionalLectionaryRules(
        to sets: [OfficeSet],
        for date: Date,
        isEvening: Bool
    ) -> [OfficeSet] {
        sets.map { set in
            guard let lessons = set.lessons else {
                return set
            }
            
            let updatedLessons = applyConditionalLectionaryRules(
                for: date,
                isEvening: isEvening,
                base: lessons
            )
            
            return OfficeSet(
                id: set.id,
                label: set.label,
                lessons: updatedLessons,
                psalms: set.psalms
            )
        }
    }
    
    /// 1943 年經課特殊規則集中放在這裡。
    /// DailyOfficeLoader 只負責讀取普通 JSON，不再處理 1943 特殊判斷。
    private func applyConditionalLectionaryRules(
        for date: Date,
        isEvening: Bool,
        base: DailyOfficeFile.OfficePeriod.LessonsGroup
    ) -> DailyOfficeFile.OfficePeriod.LessonsGroup {
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        let isTrinity = (info.season == .trinity)
        
        // ═══════════════════════════════════════════════════════
        // 1. 聖巴拿巴日（6月11日，或遷移至6月12日）
        // ═══════════════════════════════════════════════════════
        let isBarnabasDay = (month == 6 && day == 11) || (month == 6 && day == 12)
        if isBarnabasDay && isTrinity {
            let trinityWeek = info.weekNumber
            
            // 早禱：三一主日後第一主日 → 路加福音14:25-35
            if !isEvening && trinityWeek == 1 {
                return DailyOfficeFile.OfficePeriod.LessonsGroup(
                    ot: base.ot,
                    nt: DailyOfficeFile.OfficePeriod.LessonReference(
                        book: "路加福音",
                        chapter: "14:25-35"
                    )
                )
            }
            
            // 晚禱：三一主日後第三主日之後（含）→ 羅馬書10:1-15
            if isEvening && trinityWeek >= 3 {
                return DailyOfficeFile.OfficePeriod.LessonsGroup(
                    ot: base.ot,
                    nt: DailyOfficeFile.OfficePeriod.LessonReference(
                        book: "羅馬書",
                        chapter: "10:1-15"
                    )
                )
            }
        }
        
        // 2. 施洗聖約翰誕辰日（6月24日）
        if month == 6 && day == 24 && isTrinity && isEvening {
            // 前夕晚禱（effectiveDate=6月24日，isEvening=true）
            // 第二經課固定為馬太福音21:23-27
            return DailyOfficeFile.OfficePeriod.LessonsGroup(
                ot: base.ot,
                nt: DailyOfficeFile.OfficePeriod.LessonReference(
                    book: "馬太福音",
                    chapter: "21:23-27"
                )
            )
        }
        
        return base
    }
    
    private func loadOfficeSet(
        resourceName: String,
        groupIndex: Int
    ) -> OfficeSet? {
        guard let url = Bundle.main.url(
            forResource: resourceName,
            withExtension: "json"
        ),
        let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        do {
            let decoded = try JSONDecoder().decode(OfficeSet.self, from: data)
            
            // 如果 JSON 沒有 label，給一個穩定顯示名稱。
            let fallbackLabel: String
            switch groupIndex {
            case 1:
                fallbackLabel = "第一組"
            case 2:
                fallbackLabel = "第二組"
            case 3:
                fallbackLabel = "第三組"
            default:
                fallbackLabel = "第\(groupIndex)組"
            }
            
            return OfficeSet(
                id: decoded.id,
                label: decoded.label ?? fallbackLabel,
                lessons: decoded.lessons,
                psalms: decoded.psalms
            )
        } catch {
            print("❌ 解析 \(resourceName).json 失敗: \(error)")
            return nil
        }
    }
    
    // MARK: - 日期與日課代碼
    
    private func effectiveDate(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool
    ) -> Date {
        if isEvening && liturgy.isFirstVespers {
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return date
    }
    
    private func officeCodes(isEvening: Bool) -> [String] {
        // 節期經課文件不設前夕 V。
        // 前夕晚禱若需要專用經課，應寫在聖日 JSON 的 vigil.lectionary_sets.1943 裡，
        // 並由上面的 override 邏輯優先讀取。
        return [isEvening ? "E" : "M"]
    }
    
    private func weekdayToDayIndex(_ weekday: Int) -> Int {
        // Calendar: Sunday = 1, Monday = 2 ...
        // 1943 file key: Sunday = 0, Monday = 1 ...
        return weekday == 1 ? 0 : weekday - 1
    }
    
    // MARK: - 節期週次 prefix
    
    /// 產生可能的 seasonWeek 前綴。
    ///
    /// 主要支援：
    /// - tr1-yr1-0-M
    /// - tr2-yr1-1-M
    ///
    /// 同時兼容：
    /// - tr-yr1-0-M
    ///
    /// 也就是你原先提出的 `tr-yr1-0-M` 仍可被讀到；
    /// 但若同一節期有多週，建議使用 `tr1`, `tr2`, `tr3` 以免混淆。
    private func candidateSeasonWeekPrefixes(for date: Date) -> [String] {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        
        var prefixes: [String] = []
        
        // 1. 先加入特殊大節日 key。
        if let fixed = fixedTemporalPrefix(daysFromEaster: info.daysFromEaster) {
            prefixes.append(fixed)
        }
        
        // 2. 加入按節期週次生成的 key。
        let season = seasonPrefix(info.season, info: info)
        let week = max(info.weekNumber, 0)
        
        // 常用格式：tr1 / tr2 / ad1 / lent3
        appendUnique("\(season)\(week)", to: &prefixes)
        
        // 有些演算法三一主日可能是 week 0，有些資料習慣以 1 起算。
        appendUnique("\(season)\(week + 1)", to: &prefixes)
        
        if week > 0 {
            appendUnique("\(season)\(week - 1)", to: &prefixes)
        }
        
        // 兼容你提出的簡短格式：tr-yr1-0-M。
        // 注意：簡短格式適合單一大日或臨時測試；完整週次建議用 tr1/tr2。
        appendUnique(season, to: &prefixes)
        
        return prefixes
    }
    
    private func appendUnique(_ value: String, to array: inout [String]) {
        guard !array.contains(value) else { return }
        array.append(value)
    }
    
    private func seasonPrefix(
        _ season: LiturgicalSeason,
        info: SeasonInfo
    ) -> String {
        switch season {
        case .advent:
            return "ad"
        case .christmas:
            return "ch"
        case .epiphany:
            return "ep"
        case .prelenten:
            if info.name.contains("七旬") {
                return "septuagesima"
            }
            if info.name.contains("六旬") {
                return "sexagesima"
            }
            if info.name.contains("五旬") {
                return "quinquagesima"
            }
            return "prelent"
        case .lent:
            return "lent"
        case .easter:
            return "easter"
        case .ascension:
            return "ascension"
        case .pentecost:
            return "pentecost"
        case .trinity:
            return "tr"
        case .holyDays:
            return "holyday"
        default:
            return "ordinary"
        }
    }
    
    private func fixedTemporalPrefix(daysFromEaster: Int) -> String? {
        switch daysFromEaster {
        case -46:
            return "ash_wednesday"
        case -3:
            return "maundy_thursday"
        case -2:
            return "good_friday"
        case -1:
            return "holy_saturday"
        case 0:
            return "easter_sunday"
        case 39:
            return "ascension_day"
        case 48:
            return "pentecost_vigil"
        case 49:
            return "pentecost_sunday"
        case 56:
            return "trinity_sunday"
        default:
            return nil
        }
    }
}
