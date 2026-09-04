import Foundation

// MARK: - 當日經課包裝
struct DailyReadings {
    let date: Date
    let liturgy: DailyLiturgy
    let seasonInfo: SeasonInfo
    let isHolyDay: Bool
    let morningOT: LectionaryDay?   // 早禱第一經課
    let morningNT: LectionaryDay?   // 早禱第二經課
    let eveningOT: LectionaryDay?   // 晚禱第一經課
    let eveningNT: LectionaryDay?   // 晚禱第二經課
}

// MARK: - 當日經課服務
class DailyLectionaryService {
    static let shared = DailyLectionaryService()
    
    private let calendar = Calendar.current
    private let fixedHolyDays = [
        "1130", "1221", "0125", "0202", "0224", "0325",
        "0425", "0501", "0611", "0624", "0629", "0725",
        "0806", "0824", "0921", "0929", "1018", "1028", "1101"
    ]
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - 公開接口
    // ═══════════════════════════════════════════════════════════════
    
    /// 主入口：從 lectionary_1928／lectionary_1962 JSON 獲取指定日期的完整經課。
    func readings(for date: Date, year: String = "1928") -> DailyReadings {
        let liturgy = LiturgyCoreService.shared.resolve(for: date)
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        
        // 🌟 1962 主日雙年規則：
        // 單數年使用 yr2，雙數年使用 yr1
        let lectionarySubYear: String?
        
        if year == "1962" {
            let calendarYear = calendar.component(.year, from: date)
            lectionarySubYear = calendarYear % 2 == 0 ? "yr1" : "yr2"
        } else {
            lectionarySubYear = nil
        }
        
        // ═══════════════════════════════════════════════════════
        // 🌟 前夕遮蔽規則（1928 / 1962 適用，1943 由專用服務處理）：
        // 若今日聖日在晚禱被降級為紀念（晚禱轉為明日聖日的前夕晚禱），
        // 則晚禱經課改用明日聖日的經課；明日聖日無專用經課時改用平日經課。
        // 早禱經課不受影響，仍使用今日聖日經課。
        // ═══════════════════════════════════════════════════════
        let supersession = firstVespersSupersession(for: date)
        
        return loadLectionaryJSONReadings(
            for: date,
            year: year,
            liturgy: liturgy,
            info: info,
            lectionarySubYear: lectionarySubYear,
            supersession: supersession
        )
    }
    
    /// 供 ViewModel Picker 使用：查詢 JSON 中存在的經課版本選項
    func availableLectionaryOptions(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool
    ) -> [String] {
        guard let file = DailyOfficeLoader.shared.loadOfficeFile(for: date, liturgy: liturgy) else { return [] }
        
        let period: DailyOfficeFile.OfficePeriod?
        if isEvening {
            period = liturgy.isFirstVespers ? (file.vigil ?? file.evening) : file.evening
        } else {
            period = file.morning
        }
        
        guard let lessons = period?.lessons else { return [] }
        
        var options: [String] = []
        if lessons.year1943 != nil { options.append("1943") }
        if lessons.year1928 != nil { options.append("1928") }
        if lessons.year1962 != nil { options.append("1962") }
        if lessons.special != nil   { options.append("special") }
        return options
    }
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - 🌟 前夕遮蔽判斷（聖日降級為紀念）
    // ═══════════════════════════════════════════════════════════════
    
    /// 判斷今日晚禱是否被明日聖日的前夕晚禱遮蔽（今日聖日降級為紀念）。
    ///
    /// 直接複用 LiturgyCoreService.resolve(for:isEvening:) 的晚禱裁決：
    /// 回傳 isFirstVespers == true 即表示今晚已轉為明日聖日的前夕晚禱，
    /// 等級比較、同級裁決、望日/八日慶期特殊規則等全部由核心引擎處理，
    /// 保證經課切換與 UI 降級判斷使用同一套規則。
    ///
    /// 回傳被慶祝聖日（明日）的日期與禮儀資訊；未被遮蔽則回傳 nil。
    private func firstVespersSupersession(
        for date: Date
    ) -> (date: Date, liturgy: DailyLiturgy)? {
        // 只有今天本身是「有專用經課的聖日」才需要處理遮蔽
        guard fixedHolyDays.contains(mmddFor(date)) else { return nil }
        
        // 核心引擎的晚禱裁決：isFirstVespers=true 表示今晚是明日聖日前夕晚禱
        let eveningLiturgy = LiturgyCoreService.shared.resolve(for: date, isEvening: true)
        guard eveningLiturgy.isFirstVespers else { return nil }
        
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) else { return nil }
        
        AppLog.debug("🌟 [經課] 前夕遮蔽：\(mmddFor(date)) 晚禱轉為 \(mmddFor(tomorrow))『\(eveningLiturgy.mainTitle)』前夕晚禱，今日聖日降級為紀念")
        return (tomorrow, eveningLiturgy)
    }
    
    // ═══════════════════════════════════════════════════════════════
    // MARK: - 1928／1962 經課 JSON
    // ═══════════════════════════════════════════════════════════════
    
    private func loadLectionaryJSONReadings(
        for date: Date,
        year: String,
        liturgy: DailyLiturgy,
        info: SeasonInfo,
        lectionarySubYear: String? = nil,
        supersession: (date: Date, liturgy: DailyLiturgy)? = nil
    ) -> DailyReadings {
        var rawDays: [LectionaryDay] = []
        var isHolyDay = false
        var allowNoDayIndex = false
        
        // 聖日經課查詢
        let mmdd = mmddFor(date)
        if fixedHolyDays.contains(mmdd) {
            rawDays = LectionaryJSONService.shared.fetchLectionaryBySpecificKey(
                year: year,
                keyPrefix: mmdd
            )
            isHolyDay = !rawDays.isEmpty
            allowNoDayIndex = isHolyDay
        }
        
        // 非聖日：按節期查詢
        if rawDays.isEmpty {
            let query = buildQuery(info: info, date: date)
            
            if query.useSpecificKey {
                rawDays = LectionaryJSONService.shared.fetchLectionaryBySpecificKey(
                    year: year,
                    keyPrefix: query.key
                )
                
                // 🌟 specific-key 格式可能沒有 dayIndex：
                // tr-M-NT / tr-yr1-M-NT / tr-yr2-M-NT
                allowNoDayIndex = true
            } else {
                rawDays = LectionaryJSONService.shared.fetchLectionary(
                    year: year,
                    season: query.season,
                    week: query.week
                )
                
                allowNoDayIndex = false
            }
        }
        
        // 過濾出當日
        let dayIndex = weekdayToDayIndex(calendar.component(.weekday, from: date))
        let filtered = filterDays(
            rawDays,
            dayIndex: dayIndex,
            allowNoDayIndex: allowNoDayIndex
        )
        
        AppLog.debug("📖 [經課 JSON] year=\(year), subYear=\(lectionarySubYear ?? "nil"), raw=\(rawDays.count), filtered=\(filtered.count)")
        for d in filtered {
            AppLog.debug("   \(d.dayKey) \(d.book) \(d.chapter)")
        }
        
        let base = parseToDailyReadings(
            filtered,
            date: date,
            liturgy: liturgy,
            info: info,
            isHolyDay: isHolyDay,
            lectionarySubYear: lectionarySubYear
        )
        
        // ═══════════════════════════════════════════════════════
        // 🌟 前夕遮蔽：今日聖日降級為紀念時，晚禱槽改換經課來源
        //    1. 明日聖日有專用經課 → 用明日聖日經課（有 eve 專用前夕經課則只用 eve）
        //    2. 明日聖日無專用經課 → 用今日平日經課
        //    早禱槽不受影響。
        // ═══════════════════════════════════════════════════════
        if let sup = supersession, isHolyDay {
            let tomorrowKey = mmddFor(sup.date)
            var eveningRaw = LectionaryJSONService.shared.fetchLectionaryBySpecificKey(
                year: year,
                keyPrefix: tomorrowKey
            )
            var eveningAllowNoDayIndex = !eveningRaw.isEmpty
            
            if !eveningRaw.isEmpty {
                // 有 eve（前夕專用）條目時只用 eve，避免與當日 E 條目混用
                let eveOnly = eveningRaw.filter { $0.dayKey.contains("-eve-") }
                if !eveOnly.isEmpty {
                    eveningRaw = eveOnly
                }
                AppLog.debug("📖 [經課 JSON] 前夕遮蔽：晚禱改用明日聖日 \(tomorrowKey)『\(sup.liturgy.mainTitle)』經課（\(eveningRaw.count) 筆）")
            } else {
                // 明日聖日無專用經課 → 平日經課（按今日節期週次查詢）
                let query = buildQuery(info: info, date: date)
                if query.useSpecificKey {
                    eveningRaw = LectionaryJSONService.shared.fetchLectionaryBySpecificKey(
                        year: year,
                        keyPrefix: query.key
                    )
                    eveningAllowNoDayIndex = true
                } else {
                    eveningRaw = LectionaryJSONService.shared.fetchLectionary(
                        year: year,
                        season: query.season,
                        week: query.week
                    )
                    eveningAllowNoDayIndex = false
                }
                AppLog.debug("📖 [經課 JSON] 前夕遮蔽：明日聖日 \(tomorrowKey) 無專用經課，晚禱改用平日經課（\(eveningRaw.count) 筆）")
            }
            
            let eveningFiltered = filterDays(
                eveningRaw,
                dayIndex: dayIndex,
                allowNoDayIndex: eveningAllowNoDayIndex
            )
            let eveningReadings = parseToDailyReadings(
                eveningFiltered,
                date: date,
                liturgy: liturgy,
                info: info,
                isHolyDay: isHolyDay,
                lectionarySubYear: lectionarySubYear
            )
            
            AppLog.debug("📖 [經課 JSON] 前夕遮蔽結果：晚禱 OT=\(eveningReadings.eveningOT.map { "\($0.book) \($0.chapter)" } ?? "nil"), NT=\(eveningReadings.eveningNT.map { "\($0.book) \($0.chapter)" } ?? "nil")")
            
            return DailyReadings(
                date: date,
                liturgy: liturgy,
                seasonInfo: info,
                isHolyDay: isHolyDay,
                morningOT: base.morningOT,       // 早禱維持今日聖日經課
                morningNT: base.morningNT,
                eveningOT: eveningReadings.eveningOT,
                eveningNT: eveningReadings.eveningNT
            )
        }
        
        return base
    }
    
    // MARK: - 節期 → JSON 檔名查詢參數
    private func buildQuery(info: SeasonInfo, date: Date) -> (useSpecificKey: Bool, key: String, season: String, week: Int) {
        switch info.season {
        case .advent:
            return (false, "", "ad", info.weekNumber)
        case .christmas:
            let m = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            if m == 12 && day == 25 { return (true, "1225", "", 0) }
            if m == 12 && (29...31).contains(day) { return (true, "christmas1", "", 0) }
            if m == 1 && (1...5).contains(day) { return (true, "christmas2", "", 0) }
            return (false, "", "ch", info.weekNumber)
        case .epiphany:
            if info.weekNumber == 0 { return (true, "0106", "", 0) }
            return (false, "", "epiphany", info.weekNumber)
        case .prelenten:
            switch info.weekNumber {
            case 1: return (false, "", "septuagesima", 0)
            case 2: return (false, "", "sexagesima", 0)
            case 3: return (false, "", "quinquagesima", 0)
            default: return (false, "", "prele", 0)
            }
        case .lent:
            if info.daysFromEaster == -46 { return (false, "", "quinquagesima", 0) }
            return (false, "", "lent", info.weekNumber)
        case .easter:
            return (false, "", "easter", info.weekNumber + 1)
        case .ascension:
            let dbWeek = info.daysFromEaster <= 41 ? 6 : 7
            return (false, "", "easter", dbWeek)
        case .pentecost:
            return (false, "", "easter", 8)
        case .trinity:
            let key = info.weekNumber == 0 ? "tr" : "tr\(info.weekNumber)"
            return (true, key, "", 0)
        case .holyDays:
            return (true, mmddFor(date), "", 0)
        default:
            return (false, "", "", 0)
        }
    }
    
    // MARK: - 過濾當日經課
    private func filterDays(
        _ days: [LectionaryDay],
        dayIndex: Int,
        allowNoDayIndex: Bool
    ) -> [LectionaryDay] {
        return days.filter { day in
            let parts = day.dayKey.components(separatedBy: "-")
            guard parts.count >= 3 else { return false }
            
            // 前夕格式：0611-eve-E-NT
            if parts.count >= 2 && parts[1] == "eve" {
                return allowNoDayIndex
            }
            
            // 標準週內格式：ad1-0-M-OT / ad1-0-yr2-M-NT
            if let idx = Int(parts[1]) {
                return idx == dayIndex
            }
            
            // 1962 主日格式：tr-yr1-M-NT / tr-yr2-M-NT
            if parts[1] == "yr1" || parts[1] == "yr2" {
                return allowNoDayIndex
            }
            
            // 其他 specific-key 格式：tr-M-OT / 0106-M-NT
            if allowNoDayIndex {
                return true
            }
            
            return false
        }
    }
    
    // MARK: - 解析為 DailyReadings
    private func parseToDailyReadings(
        _ filtered: [LectionaryDay],
        date: Date,
        liturgy: DailyLiturgy,
        info: SeasonInfo,
        isHolyDay: Bool,
        lectionarySubYear: String? = nil
    ) -> DailyReadings {
        var mOT: LectionaryDay?
        var mNT: LectionaryDay?
        var eOT: LectionaryDay?
        var eNT: LectionaryDay?
        
        // 🌟 記錄各經課槽是否已由「帶星期索引的當日專屬經課」填入。
        // 帶索引者（如 tr4-6-E-OT 的 "6"）代表該星期幾的專屬經課，
        // 必須優先於無索引的該週主日通用經課（如 tr4-E-OT）。
        // 否則主日的前夕晚禱（禮拜六）會被該週主日的晚禱經課覆蓋，
        // 應繼續使用禮拜六本身的晚禱經課。
        var mOTFromDayIndex = false
        var mNTFromDayIndex = false
        var eOTFromDayIndex = false
        var eNTFromDayIndex = false
        
        // 空槽直接填入；當日專屬經課（帶星期索引）可覆蓋通用經課；
        // 已填入當日專屬經課後，通用經課不得再覆蓋。
        func assignReading(
            _ slot: inout LectionaryDay?,
            _ filledByDayIndex: inout Bool,
            with day: LectionaryDay,
            hasDayIndex: Bool
        ) {
            if slot == nil || hasDayIndex || !filledByDayIndex {
                slot = day
                filledByDayIndex = filledByDayIndex || hasDayIndex
            }
        }
        
        for day in filtered {
            let parts = day.dayKey.components(separatedBy: "-")
            guard parts.count >= 2 else { continue }
            
            // 🌟 1962 主日雙年格式：
            // tr-yr1-M-NT / tr-yr2-M-NT
            if parts.contains("yr1") || parts.contains("yr2") {
                if let subYear = lectionarySubYear {
                    // 指定了 yr1/yr2，就只取對應年份
                    guard parts.contains(subYear) else { continue }
                } else {
                    // 未指定時，避免 yr2 覆蓋 yr1，預設取 yr1
                    if parts.contains("yr2") {
                        continue
                    }
                }
            }
            
            // 🌟 是否帶星期索引（parts[1] 為數字，如 ad1-0-M-OT / tr4-6-E-OT）
            let hasDayIndex = Int(parts[1]) != nil
            
            let isEve = parts.contains("eve")
            let time = parts[parts.count - 2]
            let testament = parts[parts.count - 1]
            
            if isEve && time == "E" {
                if testament == "OT" { assignReading(&eOT, &eOTFromDayIndex, with: day, hasDayIndex: hasDayIndex) }
                if testament == "NT" { assignReading(&eNT, &eNTFromDayIndex, with: day, hasDayIndex: hasDayIndex) }
                continue
            }
            
            if time == "M" && testament == "OT" { assignReading(&mOT, &mOTFromDayIndex, with: day, hasDayIndex: hasDayIndex) }
            if time == "M" && testament == "NT" { assignReading(&mNT, &mNTFromDayIndex, with: day, hasDayIndex: hasDayIndex) }
            if time == "E" && testament == "OT" { assignReading(&eOT, &eOTFromDayIndex, with: day, hasDayIndex: hasDayIndex) }
            if time == "E" && testament == "NT" { assignReading(&eNT, &eNTFromDayIndex, with: day, hasDayIndex: hasDayIndex) }
        }
        
        return DailyReadings(
            date: date,
            liturgy: liturgy,
            seasonInfo: info,
            isHolyDay: isHolyDay,
            morningOT: mOT,
            morningNT: mNT,
            eveningOT: eOT,
            eveningNT: eNT
        )
    }
    
    private func weekdayToDayIndex(_ weekday: Int) -> Int {
        return weekday == 1 ? 0 : weekday - 1 // 主日=0, 禮拜一=1...
    }
    
    private func mmddFor(_ date: Date) -> String {
        String(format: "%02d%02d",
               calendar.component(.month, from: date),
               calendar.component(.day, from: date))
    }
}
