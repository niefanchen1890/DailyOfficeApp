import Foundation

// MARK: - 基礎模型定義
struct DailyLiturgy {
    let identifier: LiturgicalID
    let traits: LiturgicalTraits
    let mainTitle: String
    let color: String
    let rank: LiturgicalRank
    let rankName: String
    let season: LiturgicalSeason
    let commemorationItems: [LiturgicalCommemoration]
    let transferred: [String]
    var isFirstVespers: Bool = false
    /// 括號內的普通紀念（非八日慶期），僅在早禱和前夕晚禱紀念，當天晚禱不紀念
    let parentheticalCommemorationItems: [LiturgicalCommemoration]

    /// 舊畫面暫時使用的文字介面；實際保存內容已是結構化模型。
    var commemorations: [String] { commemorationItems.map(\.title) }
    var parentheticalCommemorations: [String] { parentheticalCommemorationItems.map(\.title) }
    
    init(identifier: LiturgicalID? = nil, traits: LiturgicalTraits? = nil, mainTitle: String, color: String, rank: LiturgicalRank, rankName: String, season: LiturgicalSeason, commemorations: [String] = [], commemorationItems: [LiturgicalCommemoration]? = nil, transferred: [String], isFirstVespers: Bool = false, parentheticalCommemorations: [String] = [], parentheticalCommemorationItems: [LiturgicalCommemoration]? = nil) {
        let resolvedIdentifier = identifier ?? LiturgicalID.fromLegacyTitle(mainTitle)
        self.identifier = resolvedIdentifier
        self.traits = traits ?? LiturgicalTraits.fromLegacyData(
            identifier: resolvedIdentifier,
            title: mainTitle,
            rank: rank,
            season: season
        )
        self.mainTitle = mainTitle
        self.color = color
        self.rank = rank
        self.rankName = rankName
        self.season = season
        self.commemorationItems = commemorationItems
            ?? commemorations.map(LiturgicalCommemoration.fromLegacyTitle)
        self.transferred = transferred
        self.isFirstVespers = isFirstVespers
        self.parentheticalCommemorationItems = parentheticalCommemorationItems
            ?? parentheticalCommemorations.map(LiturgicalCommemoration.fromLegacyTitle)
    }

    init(
        identifier: LiturgicalID? = nil,
        traits: LiturgicalTraits? = nil,
        mainTitle: String,
        color: String,
        rank: LiturgicalRank,
        rankName: String,
        season: LiturgicalSeason,
        commemorations: [LiturgicalCommemoration],
        transferred: [String],
        isFirstVespers: Bool = false,
        parentheticalCommemorations: [LiturgicalCommemoration]
    ) {
        self.init(
            identifier: identifier,
            traits: traits,
            mainTitle: mainTitle,
            color: color,
            rank: rank,
            rankName: rankName,
            season: season,
            commemorationItems: commemorations,
            transferred: transferred,
            isFirstVespers: isFirstVespers,
            parentheticalCommemorationItems: parentheticalCommemorations
        )
    }
}

// 內部使用的節期本位模型
struct TemporalDay {
    let identifier: LiturgicalID
    let traits: LiturgicalTraits
    var title: String
    var rank: LiturgicalRank
    var rankName: String
    var color: String
    var season: LiturgicalSeason
    var isGreaterFeria: Bool
    var implicitCommemoration: String? = nil

    init(
        identifier: LiturgicalID? = nil,
        title: String,
        rank: LiturgicalRank,
        rankName: String,
        color: String,
        season: LiturgicalSeason,
        isGreaterFeria: Bool,
        implicitCommemoration: String? = nil,
        traits: LiturgicalTraits? = nil
    ) {
        let resolvedIdentifier = identifier ?? LiturgicalID.fromLegacyTitle(title)
        self.identifier = resolvedIdentifier
        self.traits = traits ?? LiturgicalTraits.fromLegacyData(
            identifier: resolvedIdentifier,
            title: title,
            rank: rank,
            season: season
        )
        self.title = title
        self.rank = rank
        self.rankName = rankName
        self.color = color
        self.season = season
        self.isGreaterFeria = isGreaterFeria
        self.implicitCommemoration = implicitCommemoration
    }
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
    private var dateCalculator: LiturgicalDateCalculator {
        LiturgicalDateCalculator(calendar: calendar)
    }
    private let firstVespersResolver = FirstVespersResolver()
    private let precedenceResolver = LiturgicalPrecedenceResolver()
    private let transferResolver = LiturgicalTransferResolver()
    
    init() {}

    // ═══════════════════════════════════════════════════════
    // MARK: - 輔助函數（新增與修改）
    // ═══════════════════════════════════════════════════════
    
    /// 🌟 望日只有早禱，晚禱紀念列表中應屏蔽望日
    private func filterVigilFromCommemorations(
        _ items: [LiturgicalCommemoration]
    ) -> [LiturgicalCommemoration] {
        items.filter { !$0.traits.isVigil }
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
        today: LiturgicalID,
        tomorrow: LiturgicalID
    ) -> Bool {
        LiturgicalRuleTable.exclusiveTransitions.contains(
            .init(today: today, tomorrow: tomorrow)
        )
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
        
        let todayFeast = sanctorale.getFeast(for: todayDate)
        let tomorrowFeast = sanctorale.getFeast(for: tomorrowDate)
        let todayIsFixed = (todayFeast != nil && today.mainTitle != todayTemporal.title)
        let tomorrowIsFixed = (tomorrowFeast != nil && tomorrow.mainTitle != tomorrowTemporal.title)

        return precedenceResolver.tomorrowWins(
            EqualRankPrecedenceContext(
                todayIdentifier: today.identifier,
                tomorrowIdentifier: tomorrow.identifier,
                todayIsFixedFeast: todayIsFixed,
                tomorrowIsFixedFeast: tomorrowIsFixed,
                todayPriority: todayFeast?.priority ?? 0,
                tomorrowPriority: tomorrowFeast?.priority ?? 0
            )
        )
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
        commemorations: inout [LiturgicalCommemoration],
        transferred: inout [String]
    ) {
        let weekday = calendar.component(.weekday, from: date)
        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: date)!
        let tomorrowFeasts = weekday == 7 ? sanctorale.getFeasts(for: tomorrowDate) : []
        let resolution = transferResolver.resolveOrdinaryVigilTransfer(
            weekday: weekday,
            temporal: temporal,
            todayFeasts: allFeasts,
            tomorrowFeasts: tomorrowFeasts,
            current: VigilTransferResolution(
                title: currentTitle,
                rank: currentRank,
                rankName: currentRankName,
                color: currentColor,
                commemorations: commemorations,
                transferred: transferred
            )
        )

        currentTitle = resolution.title
        currentRank = resolution.rank
        currentRankName = resolution.rankName
        currentColor = resolution.color
        commemorations = resolution.commemorations
        transferred = resolution.transferred
    }
    
    // ═══════════════════════════════════════════════════════
    // MARK: - 1. 最終衝突裁決 (支援晚禱相遇計算)
    // ═══════════════════════════════════════════════════════
    func resolve(for date: Date, isEvening: Bool = false) -> DailyLiturgy {
        let today = resolveDay(for: date)
        
        if !isEvening {
            // 早禱：合併普通括號紀念
            var mergedItems = today.commemorationItems
            let weekday = calendar.component(.weekday, from: date)
            for item in today.parentheticalCommemorationItems {
                let name = item.title
                if !mergedItems.contains(where: { $0.title == name }) {
                    // 🌟 主日的括號內望日紀念已按望日規則提前至禮拜六，當天早禱不紀念
                    if weekday == 1 && item.traits.isVigil { continue }
                    mergedItems.append(item)
                }
            }
            return DailyLiturgy(
                identifier: today.identifier,
                traits: today.traits,
                mainTitle: today.mainTitle,
                color: today.color,
                rank: today.rank,
                rankName: today.rankName,
                season: today.season,
                commemorationItems: mergedItems,
                transferred: today.transferred,
                isFirstVespers: false,
                parentheticalCommemorations: today.parentheticalCommemorations
            )
        }
        
        // 聖靈降臨三日（49–51）晚禱絕對規則
        let year = calendar.component(.year, from: date)
        let easter = dateCalculator.easterSunday(in: year)
        let daysToEaster = dateCalculator.daysBetween(easter, and: date)
        
        if (49...51).contains(daysToEaster) {
            return DailyLiturgy(
                identifier: today.identifier,
                traits: today.traits,
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
        let isTodayVigil = firstVespersResolver.isVigil(today)
        
        // 規則1：望日沒有晚禱，直接進入明天
        if isTodayVigil {
            useTomorrow = true
        }
        // 規則2：明天有資格舉行前夕晚禱，且（rank更高 或 同級但明天優先）
        else if firstVespersResolver.hasFirstVespers(tomorrow) {
            
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
        if tomorrowTemporal.traits.octave?.isDayEight == true {
            useTomorrow = true
        }
        
        // 🌟 硬編碼：使徒聖彼得與聖保羅日八日慶期第七日只有早禱，省略晚禱
        // （今天晚禱直接改為八日慶期第八日的前夕晚禱）
        if LiturgicalRuleTable.daysWhoseEveningUsesTomorrow.contains(today.identifier)
            || LiturgicalRuleTable.daysWhoseEveningUsesTomorrow.contains(todayTemporal.identifier) {
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
                tomorrow.commemorationItems.filter {
                    // 若明天無聖日勝出，temporal title 已是 mainTitle，此處跳過
                    // 若明天有聖日勝出，temporal title（如主日）是明天的紀念，應保留
                    if !isTomorrowFeastWinning && $0.title == tomorrowTemporalResolved.title {
                        return false
                    }
                    return !$0.traits.isWithinOctave || $0.traits.octave?.isDayEight == true
                }
            )

            let isSaturday       = calendar.component(.weekday, from: date) == 7
            let isTomorrowSunday = calendar.component(.weekday, from: tomorrowDate) == 1
            let isTodayTrinityOctave = LiturgicalRuleTable.trinityOctaveWeekdays.contains(today.identifier)
            let isTomorrowHighRank = tomorrow.rank >= .doubleSecondClass
            let isSatToSun = isSaturday && isTomorrowSunday
            
            // let isTomorrowFirstClass = tomorrow.rank >= .doubleFirstClass

            let isChristChain = isChristToChristTransition(
                today: todayTemporal.identifier,
                tomorrow: tomorrowTemporal.identifier
            )
            let christChainForbidden: Set<LiturgicalID> = isChristChain
                ? [.corpusChristiOctave, .corpusChristiOctaveDayEight]
                : []
            if isChristChain {
                combinedCommemorations.removeAll { christChainForbidden.contains($0.identifier) }
            }

            // 🌟 硬編碼：6月30日「紀念使徒聖保羅」不帶入7月1日前夕晚禱
            let shouldExcludeTodayFromEvening = LiturgicalRuleTable.daysNotCarriedIntoAdjacentEvening.contains(
                today.identifier
            )
            
            if today.rank > .simple
                && !isTodayVigil
                && !shouldExcludeTodayFromEvening
                && !(isTodayTrinityOctave && isTomorrowHighRank) {

                // ───── 分支 ①：禮拜六 → 主日 ─────
                if isSatToSun {
                    if today.mainTitle != todayTemporal.title,
                       today.mainTitle != tomorrow.mainTitle,
                       !combinedCommemorations.contains(today.mainTitle),
                       !christChainForbidden.contains(today.identifier),
                       !today.traits.isVigil {
                        combinedCommemorations.append(liturgy: today)
                    }

                    for item in filterVigilFromCommemorations(today.commemorationItems) {
                        if item.title != tomorrow.mainTitle
                            && item.title != todayTemporal.title
                            && !combinedCommemorations.contains(item.title)
                            && !christChainForbidden.contains(item.identifier) {
                            combinedCommemorations.append(item)
                        }
                    }

                // ───── 分支 ②：今天是八日慶期第八日 ─────
                } else if todayTemporal.traits.octave?.isDayEight == true {
                    if today.mainTitle != tomorrow.mainTitle,
                       !combinedCommemorations.contains(today.mainTitle),
                       !christChainForbidden.contains(today.identifier),
                       !today.traits.isVigil {
                        combinedCommemorations.append(liturgy: today)
                    }
                    for item in filterVigilFromCommemorations(today.commemorationItems) {
                        if item.title != tomorrow.mainTitle
                            && !combinedCommemorations.contains(item.title)
                            && !christChainForbidden.contains(item.identifier) {
                            combinedCommemorations.append(item)
                        }
                    }

                // ───── 分支 ③：明天是八日慶期第八日 ─────
                } else if tomorrowTemporal.traits.octave?.isDayEight == true {
                    let isSameOctaveWithinDay = todayTemporal.traits.isWithinOctave

                    let shouldSkipTodayMainTitle = isSameOctaveWithinDay
                        && today.mainTitle == todayTemporal.title

                    if !shouldSkipTodayMainTitle,
                       today.mainTitle != tomorrow.mainTitle,
                       !combinedCommemorations.contains(today.mainTitle),
                       !christChainForbidden.contains(today.identifier),
                       !today.traits.isVigil {
                        combinedCommemorations.append(liturgy: today)
                    }

                    for item in filterVigilFromCommemorations(today.commemorationItems) {
                        let name = item.title
                        let isSameOctaveImplicit = item.traits.isWithinOctave
                        if name != tomorrow.mainTitle
                            && !combinedCommemorations.contains(name)
                            && !christChainForbidden.contains(item.identifier)
                            && !isSameOctaveImplicit {
                            combinedCommemorations.append(item)
                        }
                    }

                    if tomorrow.mainTitle != tomorrowTemporal.title,
                       !combinedCommemorations.contains(tomorrowTemporal.title),
                       !christChainForbidden.contains(tomorrowTemporal.identifier) {
                        combinedCommemorations.append(temporal: tomorrowTemporal)
                    }

                // ───── 分支 ④：普通前夕晚禱 ─────
                } else {
                    if today.mainTitle != tomorrow.mainTitle,
                       !combinedCommemorations.contains(today.mainTitle),
                       !christChainForbidden.contains(today.identifier),
                       !today.traits.isVigil {
                        combinedCommemorations.append(liturgy: today)
                    }
                }
            }
            
            // ───── 合併明天括號內的普通紀念（前夕晚禱應紀念）─────
            // 🌟 望日只有早禱，括號內的望日紀念不帶入前夕晚禱
            for item in tomorrow.parentheticalCommemorationItems {
                let name = item.title
                if item.traits.isVigil { continue }
                if !combinedCommemorations.contains(name) {
                    combinedCommemorations.append(item)
                }
            }
            
            // 🌟 強制規則：三一主日絕對不紀念任何慶節
            if LiturgicalRuleTable.firstVespersWithoutCommemorations.contains(tomorrow.identifier) {
                combinedCommemorations.removeAll()
            }
            
            // 🌟 強制規則：顯現日前夕晚禱不紀念聖誕後主日
            // （1/5 邊界：聖誕後第二主日適逢 1/5 時，當晚晚禱直接為顯現日前夕晚禱，不紀念主日）
            if tomorrow.identifier == .epiphany {
                combinedCommemorations.removeAll { $0.identifier == .sundayAfterChristmas }
            }

            // 🌟 硬編碼：使徒聖彼得與聖保羅日八日慶期第八日的前夕晚禱，不紀念第七日（第七日只有早禱）
            combinedCommemorations.removeAll {
                LiturgicalRuleTable.commemorationsExcludedFromEvening.contains(
                    $0.identifier
                )
            }
            
            return DailyLiturgy(
                identifier: tomorrow.identifier,
                traits: tomorrow.traits,
                mainTitle: tomorrow.mainTitle,
                color: tomorrow.color,
                rank: tomorrow.rank,
                rankName: tomorrow.rankName,
                season: tomorrow.season,
                commemorationItems: combinedCommemorations,
                transferred: tomorrow.transferred,
                isFirstVespers: true,
                parentheticalCommemorations: tomorrow.parentheticalCommemorations
            )
            
        // 分支：使用今天（Second Vespers / 今天晚禱）
        } else {
            // 🌟 今天紀念，預先過濾望日
            var combinedCommemorations = filterVigilFromCommemorations(today.commemorationItems)
            
            // 🌟 特殊規則：若明天是望日，今天晚禱仍紀念明天括號內的普通紀念
            // （望日本身沒有晚禱，但其括號紀念應在前一天晚禱中紀念）
            let isTomorrowVigil = firstVespersResolver.isVigil(tomorrow)
            
            if isTomorrowVigil {
                for item in tomorrow.parentheticalCommemorationItems {
                    if !combinedCommemorations.contains(item.title) {
                        combinedCommemorations.append(item)
                    }
                }
            }
            
            // 🌟 強制規則：我主基督至聖寶血節晚禱不紀念施洗約翰誕辰八日慶期第八日
            if let suppressedIdentifiers = LiturgicalRuleTable.secondVespersSuppressedCommemorations[today.identifier] {
                combinedCommemorations.removeAll {
                    suppressedIdentifiers.contains($0.identifier)
                }
            }
            
            // let isSameSaintCommemoration = isCommemorationOfSameSaint(
            //     todayTitle: today.mainTitle,
            //     tomorrowTitle: tomorrow.mainTitle
            // )
            
            // 🌟 硬編碼：6月30日「紀念使徒聖保羅」不帶入今天晚禱
            let isTomorrowPaulCommemoration = LiturgicalRuleTable.daysNotCarriedIntoAdjacentEvening.contains(
                tomorrow.identifier
            )
            
            // 紀念明天主節期（僅當明天有第一晚禱資格）
            if !isTomorrowPaulCommemoration && firstVespersResolver.hasFirstVespers(tomorrow) {
                if !tomorrow.traits.isVigil,
                   !combinedCommemorations.contains(tomorrow.mainTitle) {
                    combinedCommemorations.append(liturgy: tomorrow)
                }
            }
            
            // 帶入明天 commemorations 中的聖人（過濾隱含紀念與望日）
            if !isTomorrowPaulCommemoration {
                let tomorrowTemporalResolved = getTemporalDay(for: tomorrowDate)
                // ✅ 新增：判斷明天是否有聖日勝出
                let isTomorrowFeastWinning = tomorrow.mainTitle != tomorrowTemporalResolved.title
                for item in tomorrow.commemorationItems where !item.traits.isVigil {
                    let name = item.title
                    // 若明天無聖日勝出，temporal title 已作為 mainTitle 被加入，此處跳過
                    // 若明天有聖日勝出，temporal title（如主日）是明天的紀念，應被帶入
                    if !isTomorrowFeastWinning && name == tomorrowTemporalResolved.title {
                        continue
                    }
                    if !combinedCommemorations.contains(name)
                        && (!item.traits.isWithinOctave || item.traits.octave?.isDayEight == true) {
                    combinedCommemorations.append(item)
                    }
                }
            }
            
            // 🌟 強制規則：三一主日絕對不紀念任何慶節
            if LiturgicalRuleTable.secondVespersWithoutCommemorations.contains(today.identifier) {
                combinedCommemorations.removeAll()
            }
            
            // 🌟 硬編碼：今天晚禱也不紀念使徒聖彼得與聖保羅日八日慶期第七日（第七日只有早禱）
            // 例：7月5日為主日時，第七日降為紀念，仍需在晚禱中移除
            combinedCommemorations.removeAll {
                LiturgicalRuleTable.commemorationsExcludedFromEvening.contains(
                    $0.identifier
                )
            }
            
            // 核心規則：簡式慶節沒有當晚晚禱，回退為平日 temporal
            if today.rank == .simple {
                let temporal = getTemporalDay(for: date)
                return DailyLiturgy(
                    identifier: temporal.identifier,
                    traits: temporal.traits,
                    mainTitle: temporal.title,
                    color: temporal.color,
                    rank: temporal.rank,
                    rankName: temporal.rankName,
                    season: temporal.season,
                    commemorationItems: combinedCommemorations,
                    transferred: today.transferred,
                    isFirstVespers: false,
                    parentheticalCommemorations: today.parentheticalCommemorations
                )
            }
            
            return DailyLiturgy(
                identifier: today.identifier,
                traits: today.traits,
                mainTitle: today.mainTitle,
                color: today.color,
                rank: today.rank,
                rankName: today.rankName,
                season: today.season,
                commemorationItems: combinedCommemorations,
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
        let easter = dateCalculator.easterSunday(in: year)
        let daysToEaster = dateCalculator.daysBetween(easter, and: targetDate)
        
        var currentTitle = temporal.title
        var currentRank = temporal.rank
        var currentRankName = temporal.rankName
        var currentColor = temporal.color
        let currentSeason = temporal.season
        var commemorations: [LiturgicalCommemoration] = []
        if let implicit = temporal.implicitCommemoration, !implicit.isEmpty {
            commemorations.append(implicit)
        }
        var transferred: [String] = []
        
        // 提取所有聖日名稱中括號內的紀念事項
        // 🌟 統一去掉「紀念」前綴：commemorations 陣列只存乾淨名稱（如「施洗聖約翰誕辰日八日慶期第五日」），
        //    渲染層自行加「紀念」前綴顯示，避免出現「紀念紀念…」。
        var cleanFeasts: [Feast] = []
        var parentheticalCommemorations: [LiturgicalCommemoration] = []
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
                            if LiturgicalCommemoration.fromLegacyTitle(commemoration).traits.isWithinOctave {
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
                        f = Feast(
                            identifier: f.identifier,
                            month: f.month,
                            day: f.day,
                            name: cleanName,
                            rank: f.rank,
                            priority: f.priority,
                            traits: f.traits
                        )
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
                var comms: [LiturgicalCommemoration] = []
                // 規則：1/5 邊界——聖誕後第二主日不紀念「救主顯現望日」
                let skipCommemorations: Set<LiturgicalID> = [.epiphanyVigil]
                // 紀念當日慶節（聖托馬斯 / 聖西爾維斯特 / 八日慶期第六日 等）
                if let feast = cleanFeast,
                   feast.name != sundayTitle,
                   !skipCommemorations.contains(feast.identifier) {
                    comms.append(LiturgicalCommemoration(feast: feast))
                }
                // 規則B：第一主日落於八日慶期內 → 紀念聖誕八日慶期當日
                if let oct = octaveCommemoration(), !comms.contains(oct) {
                    comms.append(oct)
                }
                // 併入括號析出之紀念與同日其他聖日
                for item in commemorations
                    where !comms.contains(item.title)
                        && !skipCommemorations.contains(item.identifier) {
                    comms.append(item)
                }
                for f in cleanFeasts
                    where f.name != (cleanFeast?.name ?? "")
                        && !comms.contains(f.name)
                        && !skipCommemorations.contains(f.identifier) {
                    comms.append(LiturgicalCommemoration(feast: f))
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
                var comms: [LiturgicalCommemoration] = []
                for item in commemorations where !comms.contains(item.title) { comms.append(item) }
                for f in cleanFeasts where f.name != feast.name && !comms.contains(f.name) {
                    comms.append(LiturgicalCommemoration(feast: f))
                }
                return DailyLiturgy(
                    mainTitle: feast.name,
                    color: getFeastColor(traits: feast.traits) ?? "white",
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
        if temporal.identifier == .trinitySunday {
            if let feast = cleanFeast, feast.name != temporal.title {
                if feast.rank >= .doubleSecondClass {
                    if !transferred.contains(feast.name) { transferred.append(feast.name) }
                } else {
                    if !commemorations.contains(feast.name) { commemorations.append(feast: feast) }
                }
            }
            // 處理同日其他聖日
            if let winner = cleanFeast {
                for f in cleanFeasts where f.name != winner.name {
                    if f.rank >= .doubleSecondClass {
                        if !transferred.contains(f.name) { transferred.append(f.name) }
                    } else if !commemorations.contains(f.name) {
                        commemorations.append(feast: f)
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
        if temporal.identifier == .ascensionVigil {
            let rogationTitle = "特禱禮拜三"
            if let feast = cleanFeast, feast.name != temporal.title {
                if feast.rank != .simple {
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(traits: feast.traits) ?? temporal.color
                    commemorations.append(temporal: temporal)
                    commemorations.append(rogationTitle)
                } else {
                    commemorations.append(rogationTitle)
                    commemorations.append(feast: feast) // 遵從平日勝出紀念聖人規則
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
                    commemorations.append(feast: feast)
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
        if temporal.identifier == .ascension {
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
        if temporal.identifier == .fridayAfterAscensionOctave {
            if let feast = cleanFeast, feast.name != temporal.title {
                if feast.rank >= .semiDouble {
                    // 半複式及以上：慶祝慶節
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(traits: feast.traits) ?? temporal.color
                    
                    // 一等、二等複式：省略紀念平日
                    if feast.rank < .doubleSecondClass {
                        commemorations.append(temporal: temporal)
                    }
                } else {
                    // 簡式及以下：平日勝出，紀念聖日
                    commemorations.append(feast: feast)
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
                    currentColor = getFeastColor(traits: feast.traits) ?? temporal.color
                } else if feast.rank >= .semiDouble {
                    // 半複式(66)、複式(75)、大複式(81)：慶祝慶節，紀念三一主日後禮拜X
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(traits: feast.traits) ?? temporal.color
                    commemorations.append(temporal: temporal)
                } else {
                    // 簡式(50)及以下：慶祝三一主日後禮拜X，紀念聖日
                    commemorations.append(feast: feast)
                }
            }
            
            // 🌟 新增：6月12日檢查遷移的聖巴拿巴日（當6月11日為三一主日時）
            let m = calendar.component(.month, from: targetDate)
            let d = calendar.component(.day, from: targetDate)
            if m == 6 && d == 12 {
                let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: targetDate)!
                let yesterdayTemporal = getTemporalDay(for: yesterdayDate)
                if yesterdayTemporal.identifier == .trinitySunday {
                    let yesterdayFeasts = sanctorale.getFeasts(for: yesterdayDate)
                    for f in yesterdayFeasts where f.identifier == .barnabas {
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
                            currentColor = getFeastColor(traits: f.traits) ?? "white"
                        } else if f.rank >= .semiDouble {
                            // 半複式及以上但低於二等複式：慶祝聖巴拿巴日，原temporal降為紀念
                            if !commemorations.contains(temporal.title) {
                                commemorations.append(temporal: temporal)
                            }
                            currentTitle = cleanName
                            currentRank = f.rank
                            currentRankName = f.rank.displayName
                            currentColor = getFeastColor(traits: f.traits) ?? "white"
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
            let specialDate = LiturgicalRuleTable.MonthDay(month: month, day: day)
            
            if LiturgicalRuleTable.corpusChristiOctaveFixedFeastDates.contains(specialDate),
               let feast = cleanFeast, feast.name != temporal.title, feast.rank > temporal.rank {
                // 聖日勝出，慶祝聖日
                currentTitle = feast.name
                currentRank = feast.rank
                currentRankName = feast.rank.displayName
                currentColor = getFeastColor(traits: feast.traits) ?? temporal.color
                commemorations.append(temporal: temporal)
                
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
                currentColor = getFeastColor(traits: feast.traits) ?? temporal.color
                // 紀念：耶穌聖心節八日慶期內禮拜X
                commemorations.append(temporal: temporal)
                
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
        if temporal.traits.fast == .autumnEmber {
            var currentTraits = temporal.traits
            if let feast = cleanFeast, feast.name != temporal.title {
                if feast.rank >= .semiDouble {
                    // 半複式及以上：慶祝慶節，紀念秋季齋期
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(traits: feast.traits) ?? temporal.color
                    currentTraits = feast.traits.preservingContext(from: temporal.traits)
                    if !commemorations.contains(temporal.title) {
                        commemorations.append(temporal: temporal)
                    }
                } else {
                    // 簡式及以下：慶祝秋季齋期，紀念慶節
                    if !commemorations.contains(feast.name) {
                        commemorations.append(feast: feast)
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
                        commemorations.append(feast: f)
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
                traits: currentTraits,
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
                        commemorations.append(feast: feast)
                    }
                }
            }
            else if isSunday {
                if feast.rank >= .doubleSecondClass {
                    currentTitle = feast.name
                    currentRank = feast.rank
                    currentRankName = feast.rank.displayName
                    currentColor = getFeastColor(traits: feast.traits) ?? temporal.color
                    commemorations.append(temporal: temporal)
                } else {
                    commemorations.append(feast: feast)
                }
            }
            else if feast.rank > temporal.rank {
                currentTitle = feast.name
                currentRank = feast.rank
                currentRankName = feast.rank.displayName
                currentColor = getFeastColor(traits: feast.traits) ?? temporal.color
                // 🌟 三一期、聖誕期、顯現期內不紀念平日
                if currentSeason != .trinity && currentSeason != .christmas && currentSeason != .epiphany {
                    commemorations.append(temporal: temporal)
                }
            }
            else if feast.rank >= .simple {
                commemorations.append(feast: feast)
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
                    commemorations.append(feast: f)
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
        if LiturgicalID.fromLegacyTitle(currentTitle) == .trinitySunday {
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
        let easter = dateCalculator.easterSunday(in: year)
        let adventStart = dateCalculator.firstSundayOfAdvent(in: year)
        let daysToEaster = dateCalculator.daysBetween(easter, and: date)
        
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
                    } else if dateCalculator.daysBetween(date, and: adventStart) == 7 && weekday == 1 {
                        title = "降臨前主日"
                        rank = .ordinarySunday
                        color = "green"
                    // 🌟 降臨前主日週間：降臨第一主日前一週的禮拜一至六，
                    // 不再按「三一主日後第X主日禮拜X」，而是「降臨前主日禮拜X」
                    } else if (1...6).contains(dateCalculator.daysBetween(date, and: adventStart)) && weekday != 1 {
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
        
        let legacyIdentifier = LiturgicalID.fromLegacyTitle(title)
        let identifier = legacyIdentifier.rawValue.hasPrefix("legacy.")
            ? LiturgicalID.temporal(season: season, week: weekNumber, weekday: weekday)
            : legacyIdentifier

        return TemporalDay(
            identifier: identifier,
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
    private func getFeastColor(traits: LiturgicalTraits) -> String? {
        if traits.themes.contains(.johnBaptistNativity) && traits.isWithinOctave { return "white" }
        if traits.isVigil { return "purple" }
        if !traits.themes.isDisjoint(with: [.martyr, .apostle, .holyCross, .johnBaptistNativity]) { return "red" }
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
        case .advent:    return dateCalculator.daysBetween(adventStart, and: date) / 7 + 1
        case .trinity:   return (daysToEaster - 56) / 7
        case .easter:    return daysToEaster / 7
        case .ascension: return daysToEaster / 7   // ← 新增
        case .pentecost: return daysToEaster / 7   // ← 新增
        case .lent:      return (daysToEaster + 46) / 7 + 1
        default:         return 1
        }
    }

    // MARK: - 5. 公共相容接口
    func getSeasonInfo(for date: Date) -> SeasonInfo {
        let targetDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
        
        let year = calendar.component(.year, from: targetDate)
        let weekday = calendar.component(.weekday, from: targetDate)
        let easter = dateCalculator.easterSunday(in: year)
        let adventStart = dateCalculator.firstSundayOfAdvent(in: year)
        let daysToEaster = dateCalculator.daysBetween(easter, and: targetDate)
        
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
        let easter = dateCalculator.easterSunday(in: year)
        let ashWednesday = calendar.date(byAdding: .day, value: -46, to: easter)!
        let adventStart = dateCalculator.firstSundayOfAdvent(in: year)
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
        if liturgy.traits.fast == .autumnEmber {
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
        let easter = dateCalculator.easterSunday(in: year)
        let ashWednesday = calendar.date(byAdding: .day, value: -46, to: easter)!
        let adventStart = dateCalculator.firstSundayOfAdvent(in: year)
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
