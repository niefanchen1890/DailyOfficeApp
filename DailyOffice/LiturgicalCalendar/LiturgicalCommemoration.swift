import Foundation

/// 一個可供程式可靠辨認的紀念項目。
/// `title` 只負責顯示；規則判斷應使用 `identifier` 或 `traits`。
struct LiturgicalCommemoration: Identifiable, Codable, Hashable, Sendable {
    let identifier: LiturgicalID
    let title: String
    let traits: LiturgicalTraits

    var id: LiturgicalID { identifier }

    init(
        identifier: LiturgicalID,
        title: String,
        traits: LiturgicalTraits = .none
    ) {
        self.identifier = identifier
        self.title = title
        self.traits = traits
    }

    init(feast: Feast, title: String? = nil) {
        self.init(
            identifier: feast.identifier,
            title: title ?? feast.name,
            traits: feast.traits
        )
    }

    /// 舊的純文字紀念在進入新模型時，只在此處進行一次相容轉換。
    static func fromLegacyTitle(_ title: String) -> LiturgicalCommemoration {
        let identifier = LiturgicalID.fromLegacyTitle(title)
        var traits = LiturgicalTraits.fromLegacyData(
            identifier: identifier,
            title: title,
            rank: .commemoration,
            season: .trinity
        )

        // 舊紀念文字沒有 rank；望日資料改在這個單一入口補上，
        // 不再讓各個畫面自行搜尋中文字。
        if traits.vigil == nil && title.contains("望日") {
            traits.vigil = .ordinary
        }

        return LiturgicalCommemoration(
            identifier: identifier,
            title: title,
            traits: traits
        )
    }
}

extension Array where Element == LiturgicalCommemoration {
    mutating func append(_ legacyTitle: String) {
        append(.fromLegacyTitle(legacyTitle))
    }

    func contains(_ legacyTitle: String) -> Bool {
        contains { $0.title == legacyTitle }
    }

    mutating func append(feast: Feast) {
        append(LiturgicalCommemoration(feast: feast))
    }

    mutating func append(temporal: TemporalDay) {
        append(
            LiturgicalCommemoration(
                identifier: temporal.identifier,
                title: temporal.title,
                traits: temporal.traits
            )
        )
    }

    mutating func append(liturgy: DailyLiturgy) {
        append(
            LiturgicalCommemoration(
                identifier: liturgy.identifier,
                title: liturgy.mainTitle,
                traits: liturgy.traits
            )
        )
    }
}

func == (lhs: LiturgicalCommemoration, rhs: String) -> Bool {
    lhs.title == rhs
}

func != (lhs: LiturgicalCommemoration, rhs: String) -> Bool {
    !(lhs == rhs)
}
