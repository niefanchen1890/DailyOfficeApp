import Foundation

// MARK: - 基礎模型定義
struct DailyLiturgy {
    let mainTitle: String
    let color: String
    let rank: LiturgicalRank
    let rankName: String
    let season: LiturgicalSeason
    let commemorations: [String]
    let transferred: [String]
    var isFirstVespers: Bool = false
    /// 括號內的普通紀念（非八日慶期），僅在早禱和前夕晚禱紀念，當天晚禱不紀念
    let parentheticalCommemorations: [String]
    
    init(mainTitle: String, color: String, rank: LiturgicalRank, rankName: String, season: LiturgicalSeason, commemorations: [String], transferred: [String], isFirstVespers: Bool = false, parentheticalCommemorations: [String] = []) {
        self.mainTitle = mainTitle
        self.color = color
        self.rank = rank
        self.rankName = rankName
        self.season = season
        self.commemorations = commemorations
        self.transferred = transferred
        self.isFirstVespers = isFirstVespers
        self.parentheticalCommemorations = parentheticalCommemorations
    }
}

// 內部使用的節期本位模型
private struct TemporalDay {
    var title: String
    var rank: LiturgicalRank
    var rankName: String
    var color: String
    var season: LiturgicalSeason
    var isGreaterFeria: Bool
    var implicitCommemoration: String? = nil
}

// MARK: - 核心禮儀服務引擎 (LiturgyCoreService)
class LiturgyCoreService {
    
    static let shared = LiturgyCoreService()
    
    private let sanctorale = Sanctorale.shared
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        return cal
    }
    
    init() {}

    // ═══════════════════════════════════════════════════════
    // MARK: - 輔助函數（新增與修改）
    // ═══════════════════════════════════════════════════════
    
    /// 判斷主節期是否為「八日慶期內非第八日」（這類日子沒有前夕晚禱）
    private func isWithinOctaveWithoutVespers(_ liturgy: DailyLiturgy) -> Bool {
        return liturgy.mainTitle.contains("八日慶期") && !liturgy.mainTitle.contains("第八日")
    }
    
    /// 判斷某個禮儀日是否有「第一晚禱」資格
    /// 🌟 關鍵修正：望日只有早禱，沒有晚禱
    private func hasFirstVespers(_ liturgy: DailyLiturgy) -> Bool {
        if isWithinOctaveWithoutVespers(liturgy) { return false }
        let trinityOctaveDays = ["三一主日後禮拜一", "三一主日後禮拜二", "三一主日後禮拜三"]
        if trinityOctaveDays.contains(liturgy.mainTitle) { return false }
        
        // 🌟 硬編碼：6月30日「紀念使徒聖保羅」沒有第一晚禱
        if liturgy.mainTitle == "紀念使徒聖保羅" { return false }
        
        let noVespersRanks: [LiturgicalRank] = [
            .feria, .commemoration, .greaterFeria, .privilegedFeria,
            .vigil, .privilegedVigilSecondClass, .privilegedVigilFirstClass
        ]
        return !noVespersRanks.contains(liturgy.rank)
    }
    
    /// 🌟 望日只有早禱，晚禱紀念列表中應屏蔽望日
    private func filterVigilFromCommemorations(_ names: [String]) -> [String] {
        return names.filter { !$0.contains("望日") }
    }
    
    /// 判斷名稱是否為「八日慶期內的具體日期描述」（如「八日慶期第二日」、「八日慶期內禮拜五」）
    /// 這類描述不應在前一天晚禱中被紀念，因為八日慶期內非第八日的日子沒有前夕晚禱。
    /// 但保留「八日慶期第八日」以及純「八日慶期」紀念（如主日的 implicit 紀念）。
    private func isOctaveDayDescription(_ name: String) -> Bool {
        if !name.contains("八日慶期") { return false }
        if name.contains("第八日") { return false }
        let dayPatterns = ["第二日", "第三日", "第四日", "第五日", "第六日", "第七日", "內"]
        return dayPatterns.contains { name.contains($0) }
    }
    
    /// 判斷明天是否是今天已慶祝聖人的後續紀念日
    /// 例如：今天是「使徒聖彼得與聖保羅日」，明天是「紀念使徒聖保羅」
    private func isCommemorationOfSameSaint(todayTitle: String, tomorrowTitle: String) -> Bool {
        guard tomorrowTitle.hasPrefix("紀念") else { return false }
        let commemoration = String(tomorrowTitle.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        return todayTitle.contains(commemoration)
    }
    
    /// 判斷今天 → 明天是否為「基督的慶節 → 基督的慶節」相接
    private func isChristToChristTransition(
        todayTemporalTitle: String,
        tomorrowTemporalTitle: String
    ) -> Bool {
        let pairs: [(String, String)] = [
            ("基督聖體節八日慶期第八日", "耶穌聖心節")
        ]
        return pairs.contains {
            $0.0 == todayTemporalTitle && $0.1 == tomorrowTemporalTitle
        }
    }
    
    /// 計算指定聖誕年度「聖誕後第一主日」實際慶祝日期 (month, day)
    /// 八日慶期（12/25–12/31）內必有且僅有一個主日，依聖誕日落點決定其位置：
    ///   - 12/25–28（聖誕、司提反、約翰、嬰孩）適逢主日 → 大慶節勝出，主日遷移至12/30
    ///   - 12/29（聖托馬斯）適逢主日 → 當日誦唸主日日課
    ///   - 12/30 適逢主日 → 當日為主日
    ///   - 12/31（聖西爾維斯特）適逢主日 → 當日誦唸主日日課
    private func christmasFirstSundayMD(xmasYear: Int) -> (month: Int, day: Int) {
        let christmasDate = calendar.date(from: DateComponents(year: xmasYear, month: 12, day: 25, hour: 12))!
        let cwd = calendar.component(.weekday, from: christmasDate) // 1=主日 … 7=禮拜六
        switch cwd {
        case 4:  return (12, 29) // 聖誕日為禮拜三：主日落於12/29（聖托馬斯）
        case 2:  return (12, 31) // 聖誕日為禮拜一：主日落於12/31（聖西爾維斯特）
        default: return (12, 30) // 其餘情形（含聖誕日落主日）：主日落於或遷移至12/30
        }
    }
    
    /// 計算指定年份的秋季齋期日期（9月14日聖十架日後的禮拜三、禮拜五、禮拜六）
    /// 規則：若9月14日為主日/禮拜一/禮拜二，則本週的禮拜三、五、六為齋期；
    ///       若9月14日為禮拜三/禮拜四/禮拜五/禮拜六，則下週的禮拜三、五、六為齋期。
    private func autumnEmberDays(for year: Int) -> [Date] {
        let crossDate = calendar.date(from: DateComponents(year: year, month: 9, day: 14, hour: 12))!
        let weekday = calendar.component(.weekday, from: crossDate)
        
        var wedOffset = (4 - weekday + 7) % 7
        if weekday == 4 { // 9月14日剛好是禮拜三，跳過當天（聖十架日）
            wedOffset += 7
        }
        
        let wed = calendar.date(byAdding: .day, value: wedOffset, to: crossDate)!
        let fri = calendar.date(byAdding: .day, value: 2, to: wed)!
        let sat = calendar.date(byAdding: .day, value: 3, to: wed)!
        
        return [wed, fri, sat]
    }
    
    // MARK: - 同級慶節晚禱優先級裁決
    /// 當今天與明天 rank 相等時，判斷是否應使用明天（前夕晚禱）。
    private func resolveEqualRankVespers(
        today: DailyLiturgy,
        tomorrow: DailyLiturgy,
        todayTemporal: TemporalDay,
        tomorrowTemporal: TemporalDay,
        todayDate: Date,
        tomorrowDate: Date
    ) -> Bool {
        
        // 1. 硬編碼特定組合（最高優先）
        let priorityPairs: [(winner: String, loser: String)] = [
            ("耶穌聖心節", "基督聖體節八日慶期第八日"),
        ]
        
        for pair in priorityPairs {
            if tomorrow.mainTitle.contains(pair.winner) && today.mainTitle.contains(pair.loser) {
                return true
            }
            if today.mainTitle.contains(pair.winner) && tomorrow.mainTitle.contains(pair.loser) {
                return false
            }
        }
        
        // 2. 固定慶節 vs 移動慶節
        let todayFeast = sanctorale.getFeast(for: todayDate)
        let tomorrowFeast = sanctorale.getFeast(for: tomorrowDate)
        
        let todayIsFixed = (todayFeast != nil && today.mainTitle != todayTemporal.title)
        let tomorrowIsFixed = (tomorrowFeast != nil && tomorrow.mainTitle != tomorrowTemporal.title)
        
        if tomorrowIsFixed && !todayIsFixed { return true }
        if todayIsFixed && !tomorrowIsFixed { return false }
        
        // ═══════════════════════════════════════════════════════
        // 3️⃣ 同為固定慶節（或同為移動）且同 rank 時，比較 priority
        // ═══════════════════════════════════════════════════════
        if tomorrow.rank == today.rank {
            let todayPriority = todayFeast?.priority ?? 0
            let tomorrowPriority = tomorrowFeast?.priority ?? 0
            
            if tomorrowPriority > todayPriority { return true }
            if todayPriority > tomorrowPriority { return false }
        }
        
        // 3. 預設：今天優先
        return false
    }
    
    // MARK: - 望日提前規則（普通望日落主日提前至禮拜六）
    /// 此函數在 resolveDay 最終返回前調用
    private func applyVigilTransferRule(
        for date: Date,
        temporal: TemporalDay,
        allFeasts: [Feast],
        currentTitle: inout String,
        currentRank: inout LiturgicalRank,
        currentRankName: inout String,
        currentColor: inout String,
        commemorations: inout [String],
        transferred: inout [String]
    ) {
        let weekday = calendar.component(.weekday, from: date)
        
        // 分支 A：今天是禮拜六，明天是主日+普通望日 → 今天承接該望日紀念
        if weekday == 7 {
            let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: date)!
            let tomorrowFeasts = sanctorale.getFeasts(for: tomorrowDate)
            
            for tf in tomorrowFeasts where tf.rank == .vigil {
                // 🌟 修正：只前移望日主體，分離括號內的普通紀念，讓其留在原來的禮拜日
                var cleanName = tf.name
                let bracketPairs = [(" (", ")"), ("（", "）")]
                for (open, close) in bracketPairs {
                    if let openRange = cleanName.range(of: open) {
                        cleanName = String(cleanName[..<openRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                        break
                    }
                }
                
                if !commemorations.contains(cleanName) {
                    commemorations.append(cleanName)
                }
            }
            
            // 🌟 處理明天 Feast 名稱括號內的望日紀念
            // 望日只有早禱，遇到主日提前至禮拜六早禱紀念
            for tf in tomorrowFeasts {
                let bracketPairs = [(" (", ")"), ("（", "）")]
                for (open, close) in bracketPairs {
                    if let openRange = tf.name.range(of: open) {
                        let suffix = String(tf.name[openRange.upperBound...])
                        if let closeRange = suffix.range(of: close) {
                            let rawCommemoration = String(suffix[..<closeRange.lowerBound])
                            let commemoration = rawCommemoration.hasPrefix("紀念")
                                ? String(rawCommemoration.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                                : rawCommemoration
                            if commemoration.contains("望日") && !commemorations.contains(commemoration) {
                                commemorations.append(commemoration)
                            }
                            break
                        }
                    }
                }
            }
        }
        
        // 分支 B：今天是主日，且本身是普通望日 → 望日已被提前到禮拜六，今天不顯示
        if weekday == 1 {
            for f in allFeasts where f.rank == .vigil {
                // 若今天主標題就是這個望日，回退到 temporal
                // （此處的 allFeasts 已經是在 resolveDay 中去除了括號的 cleanFeasts）
                if currentTitle == f.name {
                    currentTitle = temporal.title
                    currentRank = temporal.rank
                    currentRankName = temporal.rankName
                    currentColor = temporal.color
                }
                // 從今天紀念中移除該望日
                commemorations.removeAll { $0 == f.name }
                
                if !transferred.contains(f.name) {
                    transferred.append(f.name)
                }
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════
    // MARK: - 1. 最終衝突裁決 (支援晚禱相遇計算)
    // ═══════════════════════════════════════════════════════
    func resolve(for date: Date, isEvening: Bool = false) -> DailyLiturgy {
        let today = resolveDay(for: date)
        
        if !isEvening {
            // 早禱：合併普通括號紀念
            var mergedCommemorations = today.commemorations
            let weekday = calendar.component(.weekday, from: date)
            for name in today.parentheticalCommemorations {
                if !mergedCommemorations.contains(name) {
                    // 🌟 主日的括號內望日紀念已按望日規則提前至禮拜六，當天早禱不紀念
                    if weekday == 1 && name.contains("望日") { continue }
                    mergedCommemorations.append(name)
                }
            }
            return DailyLiturgy(
                mainTitle: today.mainTitle,
                color: today.color,
                rank: today.rank,
                rankName: today.rankName,
                season: today.season,
                commemorations: mergedCommemorations,
                transferred: today.transferred,
                isFirstVespers: false,
                parentheticalCommemorations: today.parentheticalCommemorations
            )
        }
        
        // 聖靈降臨三日（49–51）晚禱絕對規則
        let year = calendar.component(.year, from: date)
        let easter = calculateEaster(for: year)
        let daysToEaster = daysBetween(easter, and: date)
        
        if (49...51).contains(daysToEaster) {
            return DailyLiturgy(
                mainTitle: today.mainTitle,
                color: today.color,
                rank: today.rank,
                rankName: today.rankName,
                season: today.season,
                commemorations: [],
                transferred: [],
                isFirstVespers: false,
                parentheticalCommemorations: today.parentheticalCommemorations
            )
        }
        
        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: date)!
        let tomorrow = resolveDay(for: tomorrowDate)
        
        let todayTemporal = getTemporalDay(for: date)
        let tomorrowTemporal = getTemporalDay(for: tomorrowDate)
        
        var useTomorrow = false
        let isTodayVigil = today.rank == .vigil
            || today.rank == .privilegedVigilFirstClass
            || today.rank == .privilegedVigilSecondClass
            || today.mainTitle.contains("望日")
        
        // 規則1：望日沒有晚禱，直接進入明天
        if isTodayVigil {
            useTomorrow = true
        }
        // 規則2：明天有資格舉行前夕晚禱，且（rank更高 或 同級但明天優先）
        else if hasFirstVespers(tomorrow)
            && tomorrow.mainTitle != "聖靈降臨望日" {
            
            if tomorrow.rank > today.rank {
                useTomorrow = true
            } else if tomorrow.rank == today.rank {
                useTomorrow = resolveEqualRankVespers(
                    today: today,
                    tomorrow: tomorrow,
                    todayTemporal: todayTemporal,
                    tomorrowTemporal: tomorrowTemporal,
                    todayDate: date,
                    tomorrowDate: tomorrowDate
                )
            }
        }
        
        // 通用規則：八日慶期第八日的前一天的晚禱，改為八日慶期第八日的前夕晚禱
        if tomorrowTemporal.title.contains("八日慶期第八日") {
            useTomorrow = true
        }
        
        // 🌟 硬編碼：使徒聖彼得與聖保羅日八日慶期第七日只有早禱，省略晚禱
        // （今天晚禱直接改為八日慶期第八日的前夕晚禱）
        if today.mainTitle.contains("使徒聖彼得與聖保羅") && today.mainTitle.contains("第七日") {
            useTomorrow = true
        }
        
        // 🌟 硬編碼：榮福童貞馬利亞升天日八日慶期第七日只有早禱，省略晚禱
        if today.mainTitle.contains("榮福童貞馬利亞升天") && today.mainTitle.contains("第七日") {
            useTomorrow = true
        }
        
        // 基督聖體節八日慶期第八日沒有晚禱，晚禱已是基督聖心節前夕
        if todayTemporal.title == "基督聖體節八日慶期第八日" {
            useTomorrow = true
        }
        
        
        // ═══════════════════════════════════════════════════
        // 分支：使用明天（First Vespers / 前夕晚禱）
        // ═══════════════════════════════════════════════════
        if useTomorrow {
            let tomorrowTemporalResolved = getTemporalDay(for: tomorrowDate)
            let isTomorrowFeastWinning = tomorrow.mainTitle != tomorrowTemporalResolved.title
            // 🌟 基礎紀念：明天節期，並預先過濾望日
            var combinedCommemorations = filterVigilFromCommemorations(
                tomorrow.commemorations.filter {
                    // 若明天無聖日勝出，temporal title 已是 mainTitle，此處跳過
                    // 若明天有聖日勝出，temporal title（如主日）是明天的紀念，應保留
                    if !isTomorrowFeastWinning && $0 == tomorrowTemporalResolved.title {
                        return false
                    }
                    return !isOctaveDayDescription($0)
                }
            )

            let isSaturday       = calendar.component(.weekday, from: date) == 7
            let isTomorrowSunday = calendar.component(.weekday, from: tomorrowDate) == 1
            let isTodayTrinityOctave =
                ["三一主日後禮拜一", "三一主日後禮拜二", "三一主日後禮拜三"].contains(today.mainTitle)
            let isTomorrowHighRank = tomorrow.rank >= .doubleSecondClass
            let isSatToSun = isSaturday && isTomorrowSunday
            
            // let isTomorrowFirstClass = tomorrow.rank >= .doubleFirstClass

            let isChristChain = isChristToChristTransition(
                todayTemporalTitle: todayTemporal.title,
                tomorrowTemporalTitle: tomorrowTemporal.title
            )
            let christChainForbidden: Set<String> = isChristChain
                ? ["基督聖體節八日慶期", "基督聖體節八日慶期第八日"]
                : []
            if isChristChain {
                combinedCommemorations.removeAll { christChainForbidden.contains($0) }
            }

            // 🌟 硬編碼：6月30日「紀念使徒聖保羅」不帶入7月1日前夕晚禱
            let isTodayPaulCommemoration = today.mainTitle == "紀念使徒聖保羅"
            
            if today.rank > .simple
                && !isTodayVigil
                && !isTodayPaulCommemoration
                && !(isTodayTrinityOctave && isTomorrowHighRank) {

                // ───── 分支 ①：禮拜六 → 主日 ─────
                if isSatToSun {
                    if today.mainTitle != todayTemporal.title,
                       today.mainTitle != tomorrow.mainTitle,
                       !combinedCommemorations.contains(today.mainTitle),
                       !christChainForbidden.contains(today.mainTitle),
                       !today.mainTitle.contains("望日") {
                        combinedCommemorations.append(today.mainTitle)
                    }

                    for name in filterVigilFromCommemorations(today.commemorations) {
                        if name != tomorrow.mainTitle
                            && name != todayTemporal.title
                            && !combinedCommemorations.contains(name)
                            && !christChainForbidden.contains(name) {
                            combinedCommemorations.append(name)
                        }
                    }

                // ───── 分支 ②：今天是八日慶期第八日 ─────
                } else if todayTemporal.title.contains("八日慶期第八日") {
                    if today.mainTitle != tomorrow.mainTitle,
                       !combinedCommemorations.contains(today.mainTitle),
                       !christChainForbidden.contains(today.mainTitle),
                       !today.mainTitle.contains("望日") {
                        combinedCommemorations.append(today.mainTitle)
                    }
                    for name in filterVigilFromCommemorations(today.commemorations) {
                        if name != tomorrow.mainTitle
                            && !combinedCommemorations.contains(name)
                            && !christChainForbidden.contains(name) {
                            combinedCommemorations.append(name)
                        }
                    }

                // ───── 分支 ③：明天是八日慶期第八日 ─────
                } else if tomorrowTemporal.title.contains("八日慶期第八日") {
                    let octaveTheme = tomorrowTemporal.title
                        .replacingOccurrences(of: "八日慶期第八日", with: "")

                    let isSameOctaveWithinDay = !octaveTheme.isEmpty
                        && todayTemporal.title.hasPrefix(octaveTheme)
                        && todayTemporal.title.contains("八日慶期內")

                    let shouldSkipTodayMainTitle = isSameOctaveWithinDay
                        && today.mainTitle == todayTemporal.title

                    if !shouldSkipTodayMainTitle,
                       today.mainTitle != tomorrow.mainTitle,
                       !combinedCommemorations.contains(today.mainTitle),
                       !christChainForbidden.contains(today.mainTitle),
                       !today.mainTitle.contains("望日") {
                        combinedCommemorations.append(today.mainTitle)
                    }

                    for name in filterVigilFromCommemorations(today.commemorations) {
                        let isSameOctaveImplicit = !octaveTheme.isEmpty
                            && name.hasPrefix(octaveTheme)
                            && (name.contains("八日慶期內") || name.hasSuffix("八日慶期"))
                        if name != tomorrow.mainTitle
                            && !combinedCommemorations.contains(name)
                            && !christChainForbidden.contains(name)
                            && !isSameOctaveImplicit {
                            combinedCommemorations.append(name)
                        }
                    }

                    if tomorrow.mainTitle != tomorrowTemporal.title,
                       !combinedCommemorations.contains(tomorrowTemporal.title),
                       !christChainForbidden.contains(tomorrowTemporal.title) {
                        combinedCommemorations.append(tomorrowTemporal.title)
                    }

                // ───── 分支 ④：普通前夕晚禱 ─────
                } else {
                    if today.mainTitle != tomorrow.mainTitle,
                       !combinedCommemorations.contains(today.mainTitle),
                       !christChainForbidden.contains(today.mainTitle),
                       !today.mainTitle.contains("望日") {
                        combinedCommemorations.append(today.mainTitle)
                    }
                }
            }
            
            // ───── 合併明天括號內的普通紀念（前夕晚禱應紀念）─────
            // 🌟 望日只有早禱，括號內的望日紀念不帶入前夕晚禱
            for name in tomorrow.parentheticalCommemorations {
                if name.contains("望日") { continue }
                if !combinedCommemorations.contains(name) {
                    combinedCommemorations.append(name)
                }
            }
            
            // 🌟 強制規則：三一主日絕對不紀念任何慶節
            if tomorrow.mainTitle == "三一主日" {
                combinedCommemorations.removeAll()
            }
            
            // 🌟 強制規則：我主基督至聖寶血節前夕晚禱不紀念任何慶節
            if tomorrow.mainTitle.contains("基督寶血") || tomorrow.mainTitle.contains("至聖寶血") {
                combinedCommemorations.removeAll()
            }
            
            // 🌟 強制規則：顯現日前夕晚禱不紀念聖誕後主日
            // （1/5 邊界：聖誕後第二主日適逢 1/5 時，當晚晚禱直接為顯現日前夕晚禱，不紀念主日）
            if tomorrow.mainTitle == "顯現日" {
                combinedCommemorations.removeAll { $0.contains("聖誕後") && $0.contains("主日") }
            }

            // 🌟 硬編碼：使徒聖彼得與聖保羅日八日慶期第八日的前夕晚禱，不紀念第七日（第七日只有早禱）
            combinedCommemorations.removeAll { $0.contains("使徒聖彼得與聖保羅") && $0.contains("第七日") }
            
            // 🌟 硬編碼：榮福童貞馬利亞升天日八日慶期第八日的前夕晚禱，不紀念第七日（第七日只有早禱）
            combinedCommemorations.removeAll { $0.contains("榮福童貞馬利亞升天") && $0.contains("第七日") }
            
            return DailyLiturgy(
                mainTitle: tomorrow.mainTitle,
                color: tomorrow.color,
                rank: tomorrow.rank,
                rankName: tomorrow.rankName,
                season: tomorrow.season,
                commemorations: combinedCommemorations,
                transferred: tomorrow.transferred,
                isFirstVespers: true,
                parentheticalCommemorations: tomorrow.parentheticalCommemorations
            )
            
        // 分支：使用今天（Second Vespers / 今天晚禱）
        } else {
            // 🌟 今天紀念，預先過濾望日
            var combinedCommemorations = filterVigilFromCommemorations(today.commemorations)
            
            // 🌟 特殊規則：若明天是望日，今天晚禱仍紀念明天括號內的普通紀念
            // （望日本身沒有晚禱，但其括號紀念應在前一天晚禱中紀念）
            let isTomorrowVigil = tomorrow.rank == .vigil
                || tomorrow.rank == .privilegedVigilFirstClass
                || tomorrow.rank == .privilegedVigilSecondClass
                || tomorrow.mainTitle.contains("望日")
            
            if isTomorrowVigil {
                for name in tomorrow.parentheticalCommemorations {
                    if !combinedCommemorations.contains(name) {
                        combinedCommemorations.append(name)
                    }
                }
            }
            
            // 🌟 強制規則：我主基督至聖寶血節晚禱不紀念施洗約翰誕辰八日慶期第八日
            if today.mainTitle.contains("基督寶血") || today.mainTitle.contains("至聖寶血") {
                combinedCommemorations.removeAll {
                    $0.contains("施洗聖約翰誕辰日") && $0.contains("八日慶期第八日")
                }
            }
            
            // let isSameSaintCommemoration = isCommemorationOfSameSaint(
            //     todayTitle: today.mainTitle,
            //     tomorrowTitle: tomorrow.mainTitle
            // )
            
            // 🌟 硬編碼：6月30日「紀念使徒聖保羅」不帶入今天晚禱
            let isTomorrowPaulCommemoration = tomorrow.mainTitle == "紀念使徒聖保羅"
            
            // 紀念明天主節期（僅當明天有第一晚禱資格）
            if !isTomorrowPaulCommemoration && hasFirstVespers(tomorrow) {
                if !tomorrow.mainTitle.contains("望日"),
                   !combinedCommemorations.contains(tomorrow.mainTitle) {
                    combinedCommemorations.append(tomorrow.mainTitle)
                }
            }
            
            // 帶入明天 commemorations 中的聖人（過濾隱含紀念與望日）
            if !isTomorrowPaulCommemoration {
                let tomorrowTemporalResolved = getTemporalDay(for: tomorrowDate)
                // ✅ 新增：判斷明天是否有聖日勝出
                let isTomorrowFeastWinning = tomorrow.mainTitle != tomorrowTemporalResolved.title
                for name in filterVigilFromCommemorations(tomorrow.commemorations) {
                    // 若明天無聖日勝出，temporal title 已作為 mainTitle 被加入，此處跳過
                    // 若明天有聖日勝出，temporal title（如主日）是明天的紀念，應被帶入
                    if !isTomorrowFeastWinning && name == tomorrowTemporalResolved.title {
                        continue
                    }
                    if !combinedCommemorations.contains(name)
                        && !isOctaveDayDescription(name) {
                        combinedCommemorations.append(name)
                    }
                }
            }
            
            // 🌟 強制規則：三一主日絕對不紀念任何慶節
            if today.mainTitle == "三一主日" {
                combinedCommemorations.removeAll()
            }
            
            // 🌟 硬編碼：今天晚禱也不紀念使徒聖彼得與聖保羅日八日慶期第七日（第七日只有早禱）
            // 例：7月5日為主日時，第七日降為紀念，仍需在晚禱中移除
            combinedCommemorations.removeAll { $0.contains("使徒聖彼得與聖保羅") && $0.contains("第七日") }
            
            // 🌟 硬編碼：今天晚禱也不紀念榮福童貞馬利亞升天日八日慶期第七日（第七日只有早禱）
            combinedCommemorations.removeAll { $0.contains("榮福童貞馬利亞升天") && $0.contains("第七日") }
            
            // 核心規則：簡式慶節沒有當晚晚禱，回退為平日 temporal
            if today.rank == .simple {
                let temporal = getTemporalDay(for: date)
                return DailyLiturgy(
                    mainTitle: temporal.title,
                    color: temporal.color,
                    rank: temporal.rank,
                    rankName: temporal.rankName,
                    season: temporal.season,
                    commemorations: combinedCommemorations,
                    transferred: today.transferred,
                    isFirstVespers: false,
                    parentheticalCommemorations: today.parentheticalCommemorations
                )
            }
            
            return DailyLiturgy(
                mainTitle: today.mainTitle,
                color: today.color,
                rank: today.rank,
                rankName: today.rankName,
                season: today.season,
                commemorations: combinedCommemorations,
                transferred: today.transferred,
                isFirstVespers: false,
                parentheticalCommemorations: today.parentheticalCommemorations
            )
        }
    }
    
    // ═══════════════════════════════════════════════════════
    // MARK: - 1.1 單日禮儀計算 (resolveDay)
    // ═══════════════════════════════════════════════════════
    private func resolveDay(for date: Date) -> DailyLiturgy {
        let targetDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
        
        let temporal = getTemporalDay(for: targetDate)
        let allFeasts = sanctorale.getFeasts(for: targetDate)   // 🌟 改為數組
        //  let feast = allFeasts.sorted { $0.rank > $1.rank }.first
        
        let year = calendar.component(.year, from: targetDate)
        let easter = calculateEaster(for: year)
        let daysToEaster = daysBetween(easter, and: targetDate)
        
        var currentTitle = temporal.title
        var currentRank = temporal.rank
        var currentRankName = temporal.rankName
        var currentColor = temporal.color
        let currentSeason = temporal.season
        var commemorations: [String] = []
        if let implicit = temporal.implicitCommemoration, !implicit.isEmpty {
            commemorations.append(implicit)
        }
        var transferred: [String] = []
        
        // 提取所有聖日名稱中括號內的紀念事項
        // 🌟 統一去掉「紀念」前綴：commemorations 陣列只存乾淨名稱（如「施洗聖約翰誕辰日八日慶期第五日」），
        //    渲染層自行加「紀念」前綴顯示，避免出現「紀念紀念…」。
        var cleanFeasts: [Feast] = []
        var parentheticalCommemorations: [String] = []
        for var f in allFeasts {
            let bracketPairs = [(" (", ")"), ("（", "）")]
            for (open, close) in bracketPairs {
                if let openRange = f.name.range(of: open) {
                    let suffix = String(f.name[openRange.upperBound...])
                    if let closeRange = suffix.range(of: close) {
                        let rawCommemoration = String(suffix[..<closeRange.lowerBound])
                        // 🌟 去掉「紀念」前綴
                        let commemoration = rawCommemoration.hasPrefix("紀念")
                            ? String(rawCommemoration.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                            : rawCommemoration
                        if !commemoration.isEmpty {
                            // 🌟 區分八日慶期紀念與普通括號紀念：
                            //    - 八日慶期紀念：當天晚禱也紀念，放入 commemorations
                            //    - 普通括號紀念：僅早禱和前夕晚禱紀念，放入 parentheticalCommemorations
                            if commemoration.contains("八日慶期") {
                                if !commemorations.contains(commemoration) {
                                    commemorations.append(commemoration)
                                }
                            } else {
                                if !parentheticalCommemorations.contains(commemoration) {
                                    parentheticalCommemorations.append(commemoration)
                                }
                            }
                        }
                        let cleanName = String(f.name[..<openRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                        // ✅ 修正：加入 priority: f.priority
                        f = Feast(month: f.month, day: f.day, name: cleanName, rank: f.rank, priority: f.priority)
                        break
                    }
                }
            }
            cleanFeasts.append(f)
        }
        
        let cleanFeast = cleanFeasts.sorted { $0.rank > $1.rank }.first
        
        // ═══════════════════════════════════════════════════════
        // MARK: - 特殊規則攔截：聖誕期（聖誕後主日 + 八日慶期）
        // ═══════════════════════════════════════════════════════
        if currentSeason == .christmas {
            let m = calendar.component(.month, from: targetDate)
            let d = calendar.component(.day, from: targetDate)
            let weekday = calendar.component(.weekday, from: targetDate)
            let xmasYear = (m == 1) ? year - 1 : year
            let firstSundayMD = christmasFirstSundayMD(xmasYear: xmasYear)
            
            // 聖誕八日慶期當日編號（12/25=第一日 … 12/31=第七日）
            func octaveCommemoration() -> String? {
                if m == 12 && (25...31).contains(d) {
                    return "聖誕日八日慶期第\(numberToChinese(d - 24))日"
                }
                return nil
            }
            
            // 規則：1月1日僅誦唸「救主受割禮日」，不紀念任何慶節
            if m == 1 && d == 1 {
                let circRank = cleanFeast?.rank ?? .doubleSecondClass
                return DailyLiturgy(
                    mainTitle: "救主受割禮日",
                    color: "white",
                    rank: circRank,
                    rankName: circRank.displayName,
                    season: currentSeason,
                    commemorations: [],
                    transferred: [],
                    parentheticalCommemorations: parentheticalCommemorations
                )
            }
            
            let isObservedFirstSunday = (m == firstSundayMD.month && d == firstSundayMD.day)
            // 規則D：聖誕後第二主日＝救主受割禮日與顯現日之間（1/2–1/5）的主日
            let isSecondSunday = (weekday == 1 && m == 1 && (2...5).contains(d))
            
            if isObservedFirstSunday || isSecondSunday {
                let sundayTitle = isSecondSunday ? "聖誕後第二主日" : "聖誕後第一主日"
                let sundayRank: LiturgicalRank = .ordinarySunday
                var comms: [String] = []
                // 規則：1/5 邊界——聖誕後第二主日不紀念「救主顯現望日」
                let skipCommemorations: Set<String> = ["救主顯現望日"]
                // 紀念當日慶節（聖托馬斯 / 聖西爾維斯特 / 八日慶期第六日 等）
                if let feast = cleanFeast, feast.name != sundayTitle, !skipCommemorations.contains(feast.name) {
                    comms.append(feast.name)
                }
                // 規則B：第一主日落於八日慶期內 → 紀念聖誕八日慶期當日
                if let oct = octaveCommemoration(), !comms.contains(oct) {
                    comms.append(oct)
                }
                // 併入括號析出之紀念與同日其他聖日
                for name in commemorations where !comms.contains(name) && !skipCommemorations.contains(name) {
                    comms.append(name)
                }
                for f in cleanFeasts where f.name != (cleanFeast?.name ?? "") && !comms.contains(f.name) && !skipCommemorations.contains(f.name) {
                    comms.append(f.name)
                }
                return DailyLiturgy(
                    mainTitle: sundayTitle,
                    color: "white",
                    rank: sundayRank,
                    rankName: sundayRank.displayName,
                    season: currentSeason,
                    commemorations: comms,
                    transferred: [],
                    parentheticalCommemorations: parentheticalCommemorations
                )
            }
            
            // 非主日：由 sanctorale 聖日勝出
            // 規則A：12/25–28大慶節適逢主日 → 主日已遷移至12/30，今日照常慶祝慶節、不紀念主日
            // 規則C：12/30（未承接遷移主日時）誦唸「聖誕日八日慶期第六日」
            if let feast = cleanFeast {
                var comms: [String] = []
                for name in commemorations where !comms.contains(name) { comms.append(name) }
                for f in cleanFeasts where f.name != feast.name && !comms.contains(f.name) {
                    comms.append(f.name)
                }
                return DailyLiturgy(
                    mainTitle: feast.name,
                    color: getFeastColor(feastName: feast.name) ?? "white",
                    rank: feast.rank,
                    rankName: feast.rank.displayName,
                    season: currentSeason,
                    commemorations: comms,
                    transferred: [],
                    parentheticalCommemorations: parentheticalCommemorations
                )
            }
            
            // 保險：無聖日的聖誕期平日
            return DailyLiturgy(
                mainTitle: temporal.title,
                color: temporal.color,
                rank: temporal.rank,
                rankName: temporal.rankName,
                season: currentSeason,
                commemorations: commemorations,
                transferred: [],
                parentheticalCommemorations: parentheticalCommemorations
            )
        }
        
        // 🌟 前置攔截：三一主日絕對不紀念任何慶節，所有聖日直接遷移（不勝出）
        if temporal.title == "三一主日" {
            if let feast = cleanFeast, feast.name != temporal.title {
                if feast.rank >= .doubleSecondClass {
                    if !transferred.contains(feast.name) { transferred.append(feast.name) }
                } else {
                    if !commemorations.contains(feast.name) { commemorations.append(feast.name) }
                }
            }
            // 處理同日其他聖日
            if let winner = cleanFeast {
                for f in cleanFeasts where f.name != winner.name {
                    if f.rank >= .doubleSecondClass {
                        if !transferred.contains(f.name) { transferred.append(f.name) }
                    } else if !commemorations.contains(f.name) {
                        commemorations.append(f.name)
                    }
                }
            }
            return DailyLiturgy(
                mainTitle: temporal.title,
                color: temporal.color,
                rank: temporal.rank,
                rankName: temporal.rankName,
                season: currentSeason,
                commemorations: [],          // 三一主日絕對不紀念
                transferred: transferred,
                parentheticalCommemorations: parentheticalCommemorations
            )
        }

        // 🌟 特殊規則攔截：升天望日與特禱禮拜三
        if temporal.title == "升天望日" {
            let rogationTitle = "特禱禮拜三"
            if let feast = cleanFeast, feast.name != temporal.title {
                if feast.rank != .simple {
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(feastName: feast.name) ?? temporal.color
                    commemorations.append(temporal.title)
                    commemorations.append(rogationTitle)
                } else {
                    commemorations.append(rogationTitle)
                    commemorations.append(feast.name) // 遵從平日勝出紀念聖人規則
                }
            } else {
                commemorations.append(rogationTitle)
            }
            
            return DailyLiturgy(mainTitle: currentTitle, color: currentColor, rank: currentRank, rankName: currentRankName, season: currentSeason, commemorations: commemorations, transferred: transferred, parentheticalCommemorations: parentheticalCommemorations)
        }
        
        // MARK: - 特殊規則攔截：聖靈降臨日、後一日、二日（49–51）—— 完全隔離
        if (49...51).contains(daysToEaster) {
            // 這三日無論聖日等級高低、無論括號內隱含紀念，一律不紀念、不遷移
            return DailyLiturgy(
                mainTitle: currentTitle,
                color: currentColor,
                rank: currentRank,
                rankName: currentRankName,
                season: currentSeason,
                commemorations: [],
                transferred: [],
                parentheticalCommemorations: parentheticalCommemorations
            )
        }

        // MARK: - 特殊規則攔截：聖靈降臨八日慶期禮拜三至六（52–55）
        if (52...55).contains(daysToEaster) {
            if let feast = cleanFeast, feast.name != temporal.title {
                if feast.rank >= .doubleSecondClass {
                    transferred.append(feast.name)
                } else {
                    commemorations.append(feast.name)
                }
            }
            return DailyLiturgy(
                mainTitle: currentTitle,
                color: currentColor,
                rank: currentRank,
                rankName: currentRankName,
                season: currentSeason,
                commemorations: commemorations,
                transferred: transferred,
                parentheticalCommemorations: parentheticalCommemorations
            )
        }
        
        // 救主升天日獨占，省略其他所有慶節不紀念
        if temporal.title == "救主升天日" {
            return DailyLiturgy(
                mainTitle: currentTitle,
                color: currentColor,
                rank: currentRank,
                rankName: currentRankName,
                season: currentSeason,
                commemorations: [],
                transferred: [],
                parentheticalCommemorations: parentheticalCommemorations
            )
        }
        
        // 🌟 特殊規則攔截：升天八日慶期後禮拜五
        if temporal.title == "升天八日慶期後禮拜五" {
            if let feast = cleanFeast, feast.name != temporal.title {
                if feast.rank >= .semiDouble {
                    // 半複式及以上：慶祝慶節
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(feastName: feast.name) ?? temporal.color
                    
                    // 一等、二等複式：省略紀念平日
                    if feast.rank < .doubleSecondClass {
                        commemorations.append(temporal.title)
                    }
                } else {
                    // 簡式及以下：平日勝出，紀念聖日
                    commemorations.append(feast.name)
                }
            }
            return DailyLiturgy(
                mainTitle: currentTitle,
                color: currentColor,
                rank: currentRank,
                rankName: currentRankName,
                season: currentSeason,
                commemorations: commemorations,
                transferred: transferred,
                parentheticalCommemorations: parentheticalCommemorations
            )
        }
        
        // 🌟 特殊規則攔截：三一主日後禮拜一至三（daysToEaster 57–59）
        if (57...59).contains(daysToEaster) {
            if let feast = cleanFeast, feast.name != temporal.title {
                if feast.rank >= .doubleSecondClass {
                    // 一等複式(100)、二等複式(90)：慶祝慶節，不紀念三一主日後禮拜X
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(feastName: feast.name) ?? temporal.color
                } else if feast.rank >= .semiDouble {
                    // 半複式(66)、複式(75)、大複式(81)：慶祝慶節，紀念三一主日後禮拜X
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(feastName: feast.name) ?? temporal.color
                    commemorations.append(temporal.title)
                } else {
                    // 簡式(50)及以下：慶祝三一主日後禮拜X，紀念聖日
                    commemorations.append(feast.name)
                }
            }
            
            // 🌟 新增：6月12日檢查遷移的聖巴拿巴日（當6月11日為三一主日時）
            let m = calendar.component(.month, from: targetDate)
            let d = calendar.component(.day, from: targetDate)
            if m == 6 && d == 12 {
                let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: targetDate)!
                let yesterdayTemporal = getTemporalDay(for: yesterdayDate)
                if yesterdayTemporal.title == "三一主日" {
                    let yesterdayFeasts = sanctorale.getFeasts(for: yesterdayDate)
                    for f in yesterdayFeasts where f.name.contains("聖巴拿巴") {
                        // 清理括號內的紀念事項
                        var cleanName = f.name
                        let bracketPairs = [(" (", ")"), ("（", "）")]
                        for (open, close) in bracketPairs {
                            if let openRange = cleanName.range(of: open) {
                                let suffix = String(cleanName[openRange.upperBound...])
                                if suffix.range(of: close) != nil {
                                    cleanName = String(cleanName[..<openRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                                    break
                                }
                            }
                        }
                        
                        // 按三一主日後禮拜一二三規則：一等、二等複式勝出，三一主日後禮拜X被省略
                        if f.rank >= .doubleSecondClass {
                            currentTitle = cleanName
                            currentRank = f.rank
                            currentRankName = f.rank.displayName
                            currentColor = getFeastColor(feastName: cleanName) ?? "white"
                        } else if f.rank >= .semiDouble {
                            // 半複式及以上但低於二等複式：慶祝聖巴拿巴日，原temporal降為紀念
                            if !commemorations.contains(temporal.title) {
                                commemorations.append(temporal.title)
                            }
                            currentTitle = cleanName
                            currentRank = f.rank
                            currentRankName = f.rank.displayName
                            currentColor = getFeastColor(feastName: cleanName) ?? "white"
                        } else {
                            // 簡式及以下：慶祝三一主日後禮拜一，紀念聖巴拿巴日
                            if !commemorations.contains(cleanName) {
                                commemorations.append(cleanName)
                            }
                        }
                        break
                    }
                }
            }
            
            return DailyLiturgy(
                mainTitle: currentTitle,
                color: currentColor,
                rank: currentRank,
                rankName: currentRankName,
                season: currentSeason,
                commemorations: commemorations,
                transferred: transferred,
                parentheticalCommemorations: parentheticalCommemorations
            )
        }
        
        // 特殊規則攔截：基督聖體節八日慶期內的固定聖日（6月11日、24日、29日）
        if (61...67).contains(daysToEaster) {
            let month = calendar.component(.month, from: targetDate)
            let day = calendar.component(.day, from: targetDate)
            let specialDates = [(6, 11), (6, 24), (6, 29)]
            
            if specialDates.contains(where: { $0.0 == month && $0.1 == day }),
               let feast = cleanFeast, feast.name != temporal.title, feast.rank > temporal.rank {
                // 聖日勝出，慶祝聖日
                currentTitle = feast.name
                currentRank = feast.rank
                currentRankName = feast.rank.displayName
                currentColor = getFeastColor(feastName: feast.name) ?? temporal.color
                commemorations.append(temporal.title)
                
                return DailyLiturgy(
                    mainTitle: currentTitle,
                    color: currentColor,
                    rank: currentRank,
                    rankName: currentRankName,
                    season: currentSeason,
                    commemorations: commemorations,
                    transferred: transferred,
                    parentheticalCommemorations: parentheticalCommemorations
                )
            }
        }
        
        // 特殊規則攔截：耶穌聖心節八日慶期內的固定聖日（6月13日聖安東尼等）
        if (69...74).contains(daysToEaster) {
            if let feast = cleanFeast, feast.name != temporal.title, feast.rank > temporal.rank {
                // 聖日勝出，慶祝聖日
                currentTitle = feast.name
                currentRank = feast.rank
                currentRankName = feast.rank.displayName
                currentColor = getFeastColor(feastName: feast.name) ?? temporal.color
                // 紀念：耶穌聖心節八日慶期內禮拜X
                commemorations.append(temporal.title)
                
                return DailyLiturgy(
                    mainTitle: currentTitle,
                    color: currentColor,
                    rank: currentRank,
                    rankName: currentRankName,
                    season: currentSeason,
                    commemorations: commemorations,
                    transferred: transferred,
                    parentheticalCommemorations: parentheticalCommemorations
                )
            }
        }
        
        // 🌟 特殊規則攔截：秋季齋期（非特權大平日）
        if temporal.title.contains("秋季齋期") {
            if let feast = cleanFeast, feast.name != temporal.title {
                if feast.rank >= .semiDouble {
                    // 半複式及以上：慶祝慶節，紀念秋季齋期
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(feastName: feast.name) ?? temporal.color
                    if !commemorations.contains(temporal.title) {
                        commemorations.append(temporal.title)
                    }
                } else {
                    // 簡式及以下：慶祝秋季齋期，紀念慶節
                    if !commemorations.contains(feast.name) {
                        commemorations.append(feast.name)
                    }
                }
            }
            
            // 處理同日其他聖日
            if let winner = cleanFeast {
                for f in cleanFeasts where f.name != winner.name {
                    if f.name == temporal.title { continue }
                    if f.rank >= .doubleSecondClass {
                        if !transferred.contains(f.name) { transferred.append(f.name) }
                    } else if !commemorations.contains(f.name) {
                        commemorations.append(f.name)
                    }
                }
            }
            
            // 應用望日提前規則
            applyVigilTransferRule(
                for: targetDate,
                temporal: temporal,
                allFeasts: cleanFeasts,
                currentTitle: &currentTitle,
                currentRank: &currentRank,
                currentRankName: &currentRankName,
                currentColor: &currentColor,
                commemorations: &commemorations,
                transferred: &transferred
            )
            
            return DailyLiturgy(
                mainTitle: currentTitle,
                color: currentColor,
                rank: currentRank,
                rankName: currentRankName,
                season: currentSeason,
                commemorations: commemorations,
                transferred: transferred,
                parentheticalCommemorations: parentheticalCommemorations
            )
        }

        // 常規規則
        if let feast = cleanFeast, feast.name != temporal.title {
            let isSunday = calendar.component(.weekday, from: targetDate) == 1
            
            if temporal.rank == .sundayFirstClass || temporal.rank == .doubleFirstClass || temporal.rank == .privilegedFeria {
                if feast.rank >= .doubleSecondClass {
                    transferred.append(feast.name)
                } else {
                    if temporal.rank == .doubleFirstClass && feast.rank == .simple {
                        // 省略簡式不紀念
                    } else {
                        commemorations.append(feast.name)
                    }
                }
            }
            else if isSunday {
                if feast.rank >= .doubleSecondClass {
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(feastName: feast.name) ?? temporal.color
                    commemorations.append(temporal.title)
                } else {
                    commemorations.append(feast.name)
                }
            }
            else if feast.rank > temporal.rank {
                currentTitle = feast.name
                currentRank = feast.rank
                currentRankName = feast.rank.displayName
                currentColor = getFeastColor(feastName: feast.name) ?? temporal.color
                // 🌟 三一期、聖誕期、顯現期內不紀念平日
                if currentSeason != .trinity && currentSeason != .christmas && currentSeason != .epiphany {
                    commemorations.append(temporal.title)
                }
            }
            else if feast.rank >= .simple {
                commemorations.append(feast.name)
            }
        }
        
        // 🌟 拆出格式補充：處理同日其他聖日（排除已處理的勝出者）
        if let winner = cleanFeast {
            for f in cleanFeasts where f.name != winner.name {
                if f.name == temporal.title { continue }
                if f.rank >= .doubleSecondClass {
                    if !transferred.contains(f.name) {
                        transferred.append(f.name)
                    }
                } else if !commemorations.contains(f.name) {
                    commemorations.append(f.name)
                }
            }
        }

        // 🌟 應用望日提前規則（普通望日落主日提前至禮拜六）
        applyVigilTransferRule(
            for: targetDate,
            temporal: temporal,
            allFeasts: cleanFeasts,
            currentTitle: &currentTitle,
            currentRank: &currentRank,
            currentRankName: &currentRankName,
            currentColor: &currentColor,
            commemorations: &commemorations,
            transferred: &transferred
        )
        
        // 🌟 強制規則：三一主日絕對不紀念任何慶節
        if currentTitle == "三一主日" {
            commemorations.removeAll()
            transferred.removeAll()
        }

        return DailyLiturgy(
            mainTitle: currentTitle,
            color: currentColor,
            rank: currentRank,
            rankName: currentRankName,
            season: currentSeason,
            commemorations: commemorations,
            transferred: transferred,
            parentheticalCommemorations: parentheticalCommemorations
        )
    }
    
    // ═══════════════════════════════════════════════════════
    // MARK: - 2. 構建節期本位 (Temporale)
    // ═══════════════════════════════════════════════════════
    private func getTemporalDay(for date: Date) -> TemporalDay {
        let year = calendar.component(.year, from: date)
        let weekday = calendar.component(.weekday, from: date)
        let easter = calculateEaster(for: year)
        let adventStart = calculateAdventSunday(for: year)
        let daysToEaster = daysBetween(easter, and: date)
        
        let season = determineSeason(date: date, easter: easter, adventStart: adventStart, daysToEaster: daysToEaster)
        let weekNumber = determineWeekNumber(season: season, date: date, adventStart: adventStart, daysToEaster: daysToEaster)
        
        var title = ""
        var rank: LiturgicalRank = .feria
        var color = "green"
        var isGreaterFeria = false
        var implicitCommemoration: String? = nil
        
        let wdSuffix = getWeekdaySuffix(weekday)
        let wdName = (weekday == 1) ? "主日" : "禮拜\(wdSuffix)"

        if season == .easter || season == .ascension || season == .pentecost || season == .lent {
            switch daysToEaster {
            case -46: title = "大齋首日 (聖灰禮拜三)"; rank = .privilegedFeria; color = "purple"; isGreaterFeria = true
            case -6...(-4): title = "聖週禮拜\(wdSuffix)"; rank = .privilegedFeria; color = "purple"; isGreaterFeria = true
            case -3: title = "聖週禮拜四：設立聖餐日"; rank = .doubleFirstClass; color = "white"; isGreaterFeria = true
            case -2: title = "聖週禮拜五：主受難日"; rank = .doubleFirstClass; color = "red"; isGreaterFeria = true
            case -1: title = "聖週禮拜六"; rank = .doubleFirstClass; color = "purple"; isGreaterFeria = true
            case 0: title = "復活日"; rank = .sundayFirstClassGreat; color = "white"
            case 1, 2: title = "復活後\(numberToChinese(daysToEaster))日"; rank = .doubleFirstClass; color = "white"; isGreaterFeria = true
            case 3...6: title = "復活後禮拜\(wdSuffix)"; rank = .privilegedFeria; color = "white"; isGreaterFeria = true
            
            case 7:
                title = "復活後第一主日（卸白衣主日）"
                rank = .sundayFirstClassGreat
                color = "white"
            case 14, 21, 28, 35:
                title = "復活後第\(numberToChinese(daysToEaster / 7))主日"
                rank = .semiDouble
                color = "white"
                
            case 36...37: title = "特禱禮拜\(wdSuffix)"; rank = .greaterFeria; color = "white"; isGreaterFeria = true
            case 38: title = "升天望日"; rank = .greaterFeria; color = "purple"; isGreaterFeria = true
            case 39: title = "救主升天日"; rank = .doubleFirstClass; color = "white"
            
            case 40, 41:
                title = "升天八日慶期內\(wdName)"
                rank = .privilegedOctaveThirdClass
                color = "white"
                isGreaterFeria = false
            
            case 42:
                title = "升天後主日"
                rank = .ordinarySunday
                color = "white"
                implicitCommemoration = "升天八日慶期"
                
            case 43...45:
                title = "升天八日慶期內\(wdName)"
                rank = .privilegedOctaveThirdClass
                color = "white"
                isGreaterFeria = false
            
            case 46:
                title = "升天八日慶期第八日"
                rank = .privilegedOctaveThirdClassGreat
                color = "white"
                
            case 47:
                title = "升天八日慶期後禮拜五"
                rank = .semiDouble
                color = "white"
                
            case 48:
                title = "聖靈降臨望日"
                rank = .privilegedVigilFirstClass
                color = "purple"
                
            case 49:
                title = "聖靈降臨日"
                rank = .sundayFirstClassGreat
                color = "red"
            
            case 50:
                title = "聖靈降臨後一日"
                rank = .doubleFirstClass
                color = "red"
            case 51:
                title = "聖靈降臨後二日"
                rank = .doubleFirstClass
                color = "red"
            case 52:
                title = "聖靈降臨八日慶期內夏季齋期禮拜三"
                rank = .privilegedOctaveFirstClass
                color = "red"
            case 53:
                title = "聖靈降臨八日慶期內禮拜四"
                rank = .privilegedOctaveFirstClass
                color = "red"
            case 54:
                title = "聖靈降臨八日慶期內夏季齋期禮拜五"
                rank = .privilegedOctaveFirstClass
                color = "red"
            case 55:
                title = "聖靈降臨八日慶期內夏季齋期禮拜六"
                rank = .privilegedOctaveFirstClass
                color = "red"
            
            default: break
            }
        }
        
        // 常規處理 (若上面 switch 沒有賦值)
        if title.isEmpty {
            // 🌟 秋季齋期（三一期內，9月14日聖十架日後的禮拜三、五、六）
            var isAutumnEmber = false
            if season == .trinity {
                let emberDays = autumnEmberDays(for: year)
                if emberDays.contains(where: { calendar.isDate($0, inSameDayAs: date) }) {
                    title = "秋季齋期禮拜\(wdSuffix)"
                    rank = .greaterFeria
                    color = "purple"
                    isGreaterFeria = true
                    isAutumnEmber = true
                }
            }
            
            if !isAutumnEmber {
                if season == .easter {
                    if weekday == 1 { title = "復活後第\(numberToChinese(daysToEaster / 7))主日" }
                    else { title = "復活後第\(numberToChinese(daysToEaster / 7))主日\(wdName)" }
                    color = "white"
                }
                else if season == .trinity {
                    // 🌟 新增：三一主日後禮拜一至三，八日慶期內，半複式
                    if (57...59).contains(daysToEaster) {
                        title = "三一主日後\(wdName)"
                        rank = .semiDouble
                        color = "white"
                    } else if daysToEaster == 56 && weekday == 1 {
                        // 原有：三一主日
                        title = "三一主日"
                        rank = .sundayFirstClassGreat
                        color = "white"
                    } else if daysToEaster == 60 {
                        title = "基督聖體節"
                        rank = .doubleFirstClass
                        color = "white"
                        
                    // 🌟 基督聖體節八日慶期內主日（daysToEaster 63 必為主日）
                    } else if daysToEaster == 63 && weekday == 1 {
                        title = "三一主日後第一主日"
                        rank = .ordinarySunday
                        color = "white"
                        implicitCommemoration = "基督聖體節八日慶期"
                        
                    } else if (61...66).contains(daysToEaster) {
                        title = "基督聖體節八日慶期內\(wdName)"
                        rank = .privilegedOctaveSecondClass
                        color = "white"
                        
                    } else if daysToEaster == 67 {
                        title = "基督聖體節八日慶期第八日"
                        rank = .privilegedOctaveSecondClassGreat
                        color = "white"
                        
                    } else if daysToEaster == 68 {
                        title = "耶穌聖心節"
                        rank = .doubleFirstClass
                        color = "white"
                        
                    // 🌟 耶穌聖心節八日慶期內主日（daysToEaster 70 必為主日）
                    } else if daysToEaster == 70 && weekday == 1 {
                        title = "三一主日後第二主日"
                        rank = .ordinarySunday
                        color = "white"
                        implicitCommemoration = "耶穌聖心節八日慶期"
                        
                    } else if (69...74).contains(daysToEaster) {
                        title = "耶穌聖心節八日慶期內\(wdName)"
                        rank = .privilegedOctaveThirdClass
                        color = "white"
                        
                    } else if daysToEaster == 75 {
                        title = "耶穌聖心節八日慶期第八日"
                        rank = .privilegedOctaveThirdClassGreat
                        color = "white"
                    // 🌟 基督君王節：10月最後一個主日（下一個主日已不在10月）
                    } else if calendar.component(.month, from: date) == 10 && weekday == 1,
                              let nextSunday = calendar.date(byAdding: .day, value: 7, to: date),
                              calendar.component(.month, from: nextSunday) != 10 {
                        title = "基督君王節"
                        rank = .doubleFirstClass
                        color = "white"
                        // 🌟 計算並保存原來的三一後第X主日名稱，供 resolve 加入紀念
                        let originalWeekNumber = (daysToEaster - 56) / 7
                        if originalWeekNumber > 0 {
                            implicitCommemoration = "三一主日後第\(numberToChinese(originalWeekNumber))主日"
                        }
                    // 🌟 降臨前主日：降臨第一主日前一個主日
                    } else if daysBetween(date, and: adventStart) == 7 && weekday == 1 {
                        title = "降臨前主日"
                        rank = .ordinarySunday
                        color = "green"
                    // 🌟 降臨前主日週間：降臨第一主日前一週的禮拜一至六，
                    // 不再按「三一主日後第X主日禮拜X」，而是「降臨前主日禮拜X」
                    } else if (1...6).contains(daysBetween(date, and: adventStart)) && weekday != 1 {
                        title = "降臨前主日\(wdName)"
                    } else if weekday == 1 {
                        title = "三一主日後第\(numberToChinese(weekNumber))主日"
                    } else {
                        if weekNumber == 0 {
                            title = "三一主日後\(wdName)"
                        } else {
                            title = "三一主日後第\(numberToChinese(weekNumber))主日\(wdName)"
                        }
                    }
                    
                    if color != "white" {
                        color = "green"
                    }
                }
                else {
                    let prefix = getSeasonPrefix(season)
                    if season == .advent {
                        // 🌟 降臨期命名：主日為「降臨第X主日」，週間為「降臨第X主日禮拜X」
                        if weekday == 1 {
                            title = "降臨第\(numberToChinese(weekNumber))主日"
                        } else {
                            title = "降臨第\(numberToChinese(weekNumber))主日\(wdName)"
                        }
                    } else if weekday == 1 {
                        title = "\(prefix)第\(numberToChinese(weekNumber))主日"
                    } else {
                        title = "\(prefix)第\(numberToChinese(weekNumber))週\(wdName)"
                    }
                    
                    if season == .advent || season == .lent {
                        color = "purple"
                        isGreaterFeria = true
                        if (season == .advent && weekNumber == 3 && weekday == 1) ||
                           (season == .lent && weekNumber == 4 && weekday == 1) { color = "pink" }
                    } else if season == .christmas { color = "white" }
                    else { color = "green" }
                }
                
                // 只有 rank 仍是預設值 .feria 時，才賦予預設 rank
                if rank == .feria {
                    if weekday == 1 {
                        if season == .advent && weekNumber == 1 { rank = .sundayFirstClass }
                        else if season == .lent { rank = .sundayFirstClass }
                        else { rank = .ordinarySunday }
                    } else {
                        rank = isGreaterFeria ? .greaterFeria : .feria
                    }
                }
            }
        }
        
        return TemporalDay(
            title: title,
            rank: rank,
            rankName: rank.displayName,
            color: color,
            season: season,
            isGreaterFeria: isGreaterFeria,
            implicitCommemoration: implicitCommemoration
        )
    }
    
    // MARK: - 3. 輔助判定邏輯
    private func getFeastColor(feastName: String) -> String? {
        if feastName.contains("施洗聖約翰誕辰日八日慶期") { return "white" }
        if feastName.contains("望日") { return "purple" }
        if feastName.contains("殉道") || feastName.contains("使徒") || feastName.contains("十架") || feastName.contains("約翰誕辰") {
            if feastName.contains("聖約翰") && !feastName.contains("誕辰") && !feastName.contains("殉道") { return "white" }
            return "red"
        }
        return "white"
    }

    private func getSeasonPrefix(_ season: LiturgicalSeason) -> String {
        switch season {
        case .advent: return "降臨期"
        case .christmas: return "聖誕期"
        case .epiphany: return "顯現期"
        case .prelenten: return "大齋前夕"
        case .lent: return "大齋期"
        case .trinity: return "三一期"
        default: return ""
        }
    }

    // MARK: - 4. 基礎數學計算
    private func determineSeason(date: Date, easter: Date, adventStart: Date, daysToEaster: Int) -> LiturgicalSeason {
        let christmas = calendar.date(from: DateComponents(year: calendar.component(.year, from: date), month: 12, day: 25))!
        let epiphany = calendar.date(from: DateComponents(year: calendar.component(.year, from: date), month: 1, day: 6))!

        if date >= christmas { return .christmas }
        if date >= adventStart { return .advent }
        if date < epiphany { return .christmas }
        if daysToEaster >= 56 { return .trinity }
        if daysToEaster >= 49 { return .pentecost }
        if daysToEaster >= 39 { return .ascension }
        if daysToEaster >= 0 { return .easter }
        if daysToEaster >= -46 { return .lent }
        return .epiphany
    }
    
    private func determineWeekNumber(season: LiturgicalSeason, date: Date, adventStart: Date, daysToEaster: Int) -> Int {
        switch season {
        case .advent:    return daysBetween(adventStart, and: date) / 7 + 1
        case .trinity:   return (daysToEaster - 56) / 7
        case .easter:    return daysToEaster / 7
        case .ascension: return daysToEaster / 7   // ← 新增
        case .pentecost: return daysToEaster / 7   // ← 新增
        case .lent:      return (daysToEaster + 46) / 7 + 1
        default:         return 1
        }
    }

    private func calculateEaster(for year: Int) -> Date {
        let a = year % 19, b = year / 100, c = year % 100
        let d = b / 4, e = b % 4, f = (b + 8) / 25, g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30, i = c / 4, k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7, m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31, day = ((h + l - 7 * m + 114) % 31) + 1
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func calculateAdventSunday(for year: Int) -> Date {
        var d = calendar.date(from: DateComponents(year: year, month: 11, day: 27, hour: 12))!
        while calendar.component(.weekday, from: d) != 1 {
            d = calendar.date(byAdding: .day, value: 1, to: d)!
        }
        return d
    }
    
    private func daysBetween(_ start: Date, and end: Date) -> Int {
        let d1 = calendar.startOfDay(for: start), d2 = calendar.startOfDay(for: end)
        return calendar.dateComponents([.day], from: d1, to: d2).day ?? 0
    }
    
    // MARK: - 5. 公共相容接口
    func getSeasonInfo(for date: Date) -> SeasonInfo {
        let targetDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
        
        let year = calendar.component(.year, from: targetDate)
        let weekday = calendar.component(.weekday, from: targetDate)
        let easter = calculateEaster(for: year)
        let adventStart = calculateAdventSunday(for: year)
        let daysToEaster = daysBetween(easter, and: targetDate)
        
        let season = determineSeason(date: targetDate, easter: easter, adventStart: adventStart, daysToEaster: daysToEaster)
        let weekNumber = determineWeekNumber(season: season, date: targetDate, adventStart: adventStart, daysToEaster: daysToEaster)
        let temporal = getTemporalDay(for: targetDate)
        
        return SeasonInfo(
            season: season,
            weekNumber: weekNumber,
            weekday: weekday,
            daysFromEaster: daysToEaster,
            name: temporal.title
        )
    }
    
    // MARK: - 邀請聖詩查詢（hymns.json）
    // MARK: - 邀請聖詩查詢（已併入 MorningPrayerDataLoader）
    func invitatoryHymn(for date: Date) -> InvitatoryHymnData {
        let weekday = calendar.component(.weekday, from: date)
        let year = calendar.component(.year, from: date)
        let easter = calculateEaster(for: year)
        let ashWednesday = calendar.date(byAdding: .day, value: -46, to: easter)!
        let adventStart = calculateAdventSunday(for: year)
        let trinitySunday = calendar.date(byAdding: .day, value: 56, to: easter)!
        
        let jan13 = calendar.date(from: DateComponents(year: year, month: 1, day: 13))!
        let sep28 = calendar.date(from: DateComponents(year: year, month: 9, day: 28))!
        
        let type: InvitatoryHymnType
        if weekday == 1 {
            if (date >= jan13 && date < ashWednesday) || (date >= sep28 && date < adventStart) {
                type = .sundayWinter
            } else if date >= trinitySunday && date < sep28 {
                type = .sundaySummer
            } else {
                type = .sundayWinter
            }
        } else {
            type = .weekday(weekday - 1)
        }
        
        // ✅ 統一由 MorningPrayerDataLoader 載入（支援繁簡雙語）
        return MorningPrayerDataLoader.shared.invitatoryHymn(for: type)
    }

    func firstCanticleType(for date: Date) -> CanticleType {
        let info = getSeasonInfo(for: date)
        let weekday = calendar.component(.weekday, from: date)
        let temporal = getTemporalDay(for: date)
        let feast = sanctorale.getFeast(for: date)
        
        let liturgy = resolve(for: date)
        // 🌟 修正：只有當「主節期」是秋季齋期時才強制三童歌；若是「紀念」則不強制
        if liturgy.mainTitle.contains("秋季齋期") {
            return .benedicite
        }
        
        // 1. 慶節（聖日勝出）→ 讚美頌
        if let f = feast, f.name != temporal.title, f.rank > temporal.rank {
            return .teDeum
        }
        
        // 1b. 三一期內的「節期慶節」→ 讚美頌
        if info.season == .trinity && weekday != 1 {
            let feriaRanks: [LiturgicalRank] = [.feria, .greaterFeria, .privilegedFeria]
            if !feriaRanks.contains(temporal.rank) {
                return .teDeum
            }
        }
        
        // 2. 主日
        if weekday == 1 {
            switch info.season {
            case .advent, .prelenten, .lent:
                return .benedicite
            default:
                return .teDeum
            }
        }
        // 3. 三一主日後禮拜一至三（daysToEaster 57–59）使用讚美頌
        if (57...59).contains(info.daysFromEaster) {
            return .teDeum
        }
        // 4. 平日：復活期（含升天期、聖靈降臨期）至三一主日前，使用讚美頌
        if [.easter, .ascension, .pentecost].contains(info.season) {
            return .teDeum
        }
        
        return .benedictusEs
    }
    
    
    // MARK: - 日課聖詩查詢（morning_hymns.json）
    func morningOfficeHymn(for date: Date) -> OfficeHymnData {
        let weekday = calendar.component(.weekday, from: date)
        let year = calendar.component(.year, from: date)
        let easter = calculateEaster(for: year)
        let ashWednesday = calendar.date(byAdding: .day, value: -46, to: easter)!
        let adventStart = calculateAdventSunday(for: year)
        let trinitySunday = calendar.date(byAdding: .day, value: 56, to: easter)!
        
        let jan13 = calendar.date(from: DateComponents(year: year, month: 1, day: 13))!
        let sep28 = calendar.date(from: DateComponents(year: year, month: 9, day: 28))!
        
        // 1. 聖日覆蓋（最高優先級）
        let temporal = getTemporalDay(for: date)
        if let feast = sanctorale.getFeast(for: date),
           feast.name != temporal.title,
           let feastHymn = OfficeHymnLoader.shared.feastHymn(for: feast.name) {
            return feastHymn
        }
        
        // 2. 主日
        if weekday == 1 {
            if (date >= jan13 && date < ashWednesday) || (date >= sep28 && date < adventStart) {
                return OfficeHymnLoader.shared.hymn(.sundayEpiphany)
            }
            if date >= trinitySunday && date < sep28 {
                return OfficeHymnLoader.shared.hymn(.sundayTrinity)
            }
            return OfficeHymnLoader.shared.hymn(.sundayEpiphany)
        }
        
        // 3. 平日（禮拜一至六）
        let index = weekday - 1
        return OfficeHymnLoader.shared.hymn(.weekday(index))
    }
}


extension LiturgyCoreService {
    
    /// 判斷指定固定聖日（以原始 mmdd 標識）在指定日期是否仍被慶祝
    /// 例：6月11日若為三一主日，聖巴拿巴日被遷移，則返回 false
    func isHolyDayObserved(on date: Date, mmdd: String) -> Bool {
        let liturgy = resolve(for: date)
        
        // 遍歷內部聖日註冊表，找出 mmdd 對應的 canonical 聖日名稱
        guard let canonicalName = canonicalNameFor(mmdd: mmdd) else { return false }
        
        // 檢查當天禮儀是否慶祝該聖日（主標題或紀念）
        if liturgy.mainTitle.contains(canonicalName) { return true }
        if liturgy.commemorations.contains(where: { $0.contains(canonicalName) }) { return true }
        
        return false
    }
    
    /// 根據聖日標題返回其原始固定日期 mmdd
    /// 例：傳入 "使徒聖巴拿巴日" 返回 "0611"；傳入無法識別的標題返回 nil
    func originalFixedDate(for title: String) -> String? {
        // 遍歷內部聖日註冊表（您現有的 add(month, day, title, rank) 資料）
        // 匹配 title，返回 String(format: "%02d%02d", month, day)
        //
        // 實現範例（請根據您實際的聖日註冊結構調整）：
        for entry in holyDayRegistry {
            if title.contains(entry.name) || entry.name.contains(title) {
                return String(format: "%02d%02d", entry.month, entry.day)
            }
        }
        return nil
    }
    // 以下為輔助實現範例，請根據您的實際資料結構替換
    private struct HolyDayRegistryEntry {
        let month: Int
        let day: Int
        let name: String
    }
    
    /// 您現有的聖日註冊表（請確保與 add() 方法使用的資料一致）
    private var holyDayRegistry: [HolyDayRegistryEntry] {
        return [
            HolyDayRegistryEntry(month: 6, day: 11, name: "使徒聖巴拿巴日"),
            HolyDayRegistryEntry(month: 6, day: 24, name: "施洗聖約翰誕辰日"),
            HolyDayRegistryEntry(month: 6, day: 29, name: "使徒聖彼得與聖保羅日"),
            HolyDayRegistryEntry(month: 6, day: 30, name: "紀念使徒聖保羅"),
            HolyDayRegistryEntry(month: 7, day: 1, name: "我主基督至聖寶血"),
            HolyDayRegistryEntry(month: 7, day: 25, name: "使徒聖雅各日"),
            HolyDayRegistryEntry(month: 8, day: 6, name: "基督易容顯光日"),
            HolyDayRegistryEntry(month: 8, day: 24, name: "使徒聖巴多羅買日"),
            HolyDayRegistryEntry(month: 9, day: 21, name: "聖馬太日"),
            HolyDayRegistryEntry(month: 9, day: 29, name: "聖米迦勒與諸天使日"),
            HolyDayRegistryEntry(month: 10, day: 18, name: "使徒聖路加日"),
            HolyDayRegistryEntry(month: 10, day: 28, name: "聖西門與聖猶大日"),
            HolyDayRegistryEntry(month: 11, day: 1, name: "諸聖日"),
            HolyDayRegistryEntry(month: 11, day: 30, name: "使徒聖安德烈日"),
            HolyDayRegistryEntry(month: 12, day: 21, name: "使徒聖多馬日"),
            HolyDayRegistryEntry(month: 1, day: 25, name: "使徒聖保羅受感化日"),
            HolyDayRegistryEntry(month: 2, day: 2, name: "獻聖嬰日"),
            HolyDayRegistryEntry(month: 2, day: 24, name: "使徒聖馬提亞日"),
            HolyDayRegistryEntry(month: 3, day: 25, name: "童女聞報日"),
            HolyDayRegistryEntry(month: 4, day: 25, name: "使徒聖馬可日"),
            HolyDayRegistryEntry(month: 5, day: 1, name: "使徒聖腓力與聖雅各日"),
            // ⚠️ 請根據實際 fixedHolyDays 與聖日表補充完整
        ]
    }
    
    private func canonicalNameFor(mmdd: String) -> String? {
        guard mmdd.count == 4,
              let m = Int(mmdd.prefix(2)),
              let d = Int(mmdd.suffix(2)) else { return nil }
        return holyDayRegistry.first { $0.month == m && $0.day == d }?.name
    }
}
