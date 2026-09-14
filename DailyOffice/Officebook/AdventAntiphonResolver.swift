import Foundation

/// 按實際民用日期選對經；前夕晚禱不能改用翌日日期。
struct AdventAntiphonResolver: Decodable {
    let evening: [String: String]
    let thomasMorningCommemoration: [String: String]

    enum CodingKeys: String, CodingKey {
        case evening
        case thomasMorningCommemoration = "thomas_morning_commemoration"
    }

    func override(for date: Date, isEvening: Bool, celebration: LiturgicalID,
                  commemorated: LiturgicalID? = nil, calendar: Calendar = Calendar(identifier: .gregorian)) -> String? {
        let parts = calendar.dateComponents([.month, .day], from: date)
        guard parts.month == 12, let day = parts.day, (16...23).contains(day) else { return nil }
        let key = String(format: "12%02d", day)
        let value: String?
        if let commemorated {
            guard commemorated.temporalComponents?.season == .advent || commemorated == .firstSundayOfAdvent else { return nil }
            value = isEvening ? evening[key]
                : (celebration == .stThomas ? thomasMorningCommemoration[key] : nil)
        } else {
            guard isEvening, celebration != .stThomas else { return nil }
            value = evening[key]
        }
        return value.flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
    }
}

/// 使用既有語言解析，資源缺失時保留原有對經。
final class AdventAntiphonLoader {
    static let shared = AdventAntiphonLoader()
    private var cache: [String: AdventAntiphonResolver] = [:]

    func override(for date: Date, isEvening: Bool, celebration: LiturgicalID,
                  commemorated: LiturgicalID? = nil, language: AppLanguage) -> String? {
        let key = language.rawValue
        if cache[key] == nil {
            guard let url = Bundle.main.url(forResource: "o_antiphons", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let localized = LocalizedJSONResolver.resolve(data: data, language: language),
                  let rules = try? JSONDecoder().decode(AdventAntiphonResolver.self, from: localized) else { return nil }
            cache[key] = rules
        }
        return cache[key]?.override(for: date, isEvening: isEvening, celebration: celebration, commemorated: commemorated)
    }
}
