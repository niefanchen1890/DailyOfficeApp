import Foundation

enum VigilKind: String, Codable, Hashable, Sendable {
    case ordinary
    case privilegedFirstClass
    case privilegedSecondClass
}

struct OctaveInfo: Codable, Hashable, Sendable {
    /// 八日慶期中的日數；舊資料無法確定時為 nil。
    let day: Int?

    var isDayEight: Bool { day == 8 }
}

enum FastKind: String, Codable, Hashable, Sendable {
    case advent
    case lent
    case rogation
    case summerEmber
    case autumnEmber
}

enum LiturgicalTheme: String, Codable, Hashable, Sendable {
    case blessedVirginMary
    case martyr
    case apostle
    case holyCross
    case johnBaptistNativity
    case sacredHeart
    case transfiguration
    case christTheKing
    case allSaints
    case confessor
    case sovereign
    case bishop
    case virgin
    case evangelist
    case churchDoctor
    case angel
}

/// 不依賴畫面顯示語言的禮儀特徵。
struct LiturgicalTraits: Codable, Hashable, Sendable {
    var vigil: VigilKind?
    var octave: OctaveInfo?
    var fast: FastKind?
    var themes: Set<LiturgicalTheme>

    static let none = LiturgicalTraits()

    var isVigil: Bool { vigil != nil }
    var isWithinOctave: Bool { octave != nil }
    var octaveDay: Int? { octave?.day }

    init(vigil: VigilKind? = nil, octave: OctaveInfo? = nil, fast: FastKind? = nil, themes: Set<LiturgicalTheme> = []) {
        self.vigil = vigil
        self.octave = octave
        self.fast = fast
        self.themes = themes
    }

    /// 主節日本身的特徵優先，同時保留所在禮儀日的齋期背景。
    func preservingContext(from context: LiturgicalTraits) -> LiturgicalTraits {
        LiturgicalTraits(
            vigil: vigil ?? context.vigil,
            octave: octave ?? context.octave,
            fast: fast ?? context.fast,
            themes: themes.union(context.themes)
        )
    }

    /// 舊資料尚未提供特徵欄位時的集中相容轉換。
    /// 新資料應直接傳入 traits，避免新增中文名稱依賴。
    static func fromLegacyData(
        identifier: LiturgicalID,
        title: String,
        rank: LiturgicalRank,
        season: LiturgicalSeason
    ) -> LiturgicalTraits {
        var traits = LiturgicalTraits()

        switch rank {
        case .vigil:
            traits.vigil = .ordinary
        case .privilegedVigilFirstClass:
            traits.vigil = .privilegedFirstClass
        case .privilegedVigilSecondClass:
            traits.vigil = .privilegedSecondClass
        default:
            // 升天望日目前沿用 greaterFeria 等級，因此由 identifier 補足。
            if identifier == .ascensionVigil {
                traits.vigil = .ordinary
            }
        }

        if title.contains("八日慶期") || isOctaveRank(rank) {
            let inferredDay = octaveDay(from: title) ?? (isOctaveDayEightRank(rank) ? 8 : nil)
            traits.octave = OctaveInfo(day: inferredDay)
        }

        if title.contains("夏季齋期") {
            traits.fast = .summerEmber
        } else if title.contains("秋季齋期") {
            traits.fast = .autumnEmber
        } else if title.contains("特禱禮拜") {
            traits.fast = .rogation
        } else if season == .lent {
            traits.fast = .lent
        } else if season == .advent {
            traits.fast = .advent
        }

        if title.contains("童貞") || title.contains("聖母") || title.contains("馬利亞") { traits.themes.insert(.blessedVirginMary) }
        if title.contains("殉道") { traits.themes.insert(.martyr) }
        if title.contains("使徒") { traits.themes.insert(.apostle) }
        if title.contains("十架") { traits.themes.insert(.holyCross) }
        if title.contains("約翰誕辰") || title.contains("施洗聖約翰誕辰") { traits.themes.insert(.johnBaptistNativity) }
        if title.contains("聖心") { traits.themes.insert(.sacredHeart) }
        if title.contains("易容") { traits.themes.insert(.transfiguration) }
        if title.contains("君王節") { traits.themes.insert(.christTheKing) }
        if title.contains("諸聖日") { traits.themes.insert(.allSaints) }
        if title.contains("精修") { traits.themes.insert(.confessor) }
        if title.contains("聖王") || title.contains("國王") || title.contains("女王") { traits.themes.insert(.sovereign) }
        if title.contains("主教") { traits.themes.insert(.bishop) }

        return traits
    }

    private static func isOctaveRank(_ rank: LiturgicalRank) -> Bool {
        switch rank {
        case .privilegedOctaveFirstClass,
             .privilegedOctaveSecondClass,
             .privilegedOctaveSecondClassGreat,
             .privilegedOctaveThirdClass,
             .privilegedOctaveThirdClassGreat,
             .ordinaryOctavesemiDouble,
             .ordinaryOctavegreaterDouble:
            return true
        default:
            return false
        }
    }

    private static func octaveDay(from title: String) -> Int? {
        let numbers: [(String, Int)] = [
            ("第一日", 1), ("第二日", 2), ("第三日", 3), ("第四日", 4),
            ("第五日", 5), ("第六日", 6), ("第七日", 7), ("第八日", 8)
        ]
        return numbers.first { title.contains($0.0) }?.1
    }

    private static func isOctaveDayEightRank(_ rank: LiturgicalRank) -> Bool {
        switch rank {
        case .privilegedOctaveSecondClassGreat,
             .privilegedOctaveThirdClassGreat,
             .ordinaryOctavegreaterDouble:
            return true
        default:
            return false
        }
    }
}
