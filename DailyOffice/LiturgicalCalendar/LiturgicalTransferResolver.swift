import Foundation

struct VigilTransferResolution {
    var title: String
    var rank: LiturgicalRank
    var rankName: String
    var color: String
    var commemorations: [LiturgicalCommemoration]
    var transferred: [String]
}

/// 只負責普通望日遇到主日後的提前規則。
struct LiturgicalTransferResolver {
    func resolveOrdinaryVigilTransfer(
        weekday: Int,
        temporal: TemporalDay,
        todayFeasts: [Feast],
        tomorrowFeasts: [Feast],
        current: VigilTransferResolution
    ) -> VigilTransferResolution {
        var result = current

        // 禮拜六承接翌日落在主日的普通望日。
        if weekday == 7 {
            for feast in tomorrowFeasts where feast.traits.isVigil {
                appendIfNeeded(
                    LiturgicalCommemoration(feast: feast, title: cleanMainName(feast.name)),
                    to: &result.commemorations
                )
            }

            for feast in tomorrowFeasts {
                guard let commemoration = parentheticalCommemoration(in: feast.name),
                      LiturgicalID.fromLegacyTitle(commemoration).rawValue.contains("vigil")
                        || commemoration.contains("望日") else {
                    continue
                }
                appendIfNeeded(.fromLegacyTitle(commemoration), to: &result.commemorations)
            }
        }

        // 主日不再顯示已提前至禮拜六的普通望日。
        if weekday == 1 {
            for feast in todayFeasts where feast.traits.isVigil {
                if result.title == feast.name {
                    result.title = temporal.title
                    result.rank = temporal.rank
                    result.rankName = temporal.rankName
                    result.color = temporal.color
                }
                result.commemorations.removeAll { $0 == feast.name }
                if !result.transferred.contains(feast.name) {
                    result.transferred.append(feast.name)
                }
            }
        }

        return result
    }

    private func cleanMainName(_ name: String) -> String {
        for marker in [" (", "（"] {
            if let range = name.range(of: marker) {
                return String(name[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
        }
        return name
    }

    private func parentheticalCommemoration(in name: String) -> String? {
        for (open, close) in [(" (", ")"), ("（", "）")] {
            guard let openRange = name.range(of: open) else { continue }
            let suffix = String(name[openRange.upperBound...])
            guard let closeRange = suffix.range(of: close) else { continue }
            let rawValue = String(suffix[..<closeRange.lowerBound])
            let value = rawValue.hasPrefix("紀念")
                ? String(rawValue.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                : rawValue
            return value.isEmpty ? nil : value
        }
        return nil
    }

    private func appendIfNeeded(
        _ value: LiturgicalCommemoration,
        to values: inout [LiturgicalCommemoration]
    ) {
        if !values.contains(where: { $0.identifier == value.identifier && $0.title == value.title }) {
            values.append(value)
        }
    }
}
