import Foundation

/// Resolves explicit common IDs before localization. No inheritance is inferred from titles.
struct CommonOfficeResolver {
    struct Failure: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    static func resolve(data: Data, commonData: (String) throws -> Data) throws -> Data {
        guard let proper = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw Failure(message: "聖日 JSON 必須是物件")
        }
        guard let reference = proper["common_office"] else { return data }
        guard let id = reference as? String, !id.isEmpty else {
            throw Failure(message: "common_office 必須是非空的通用 ID")
        }
        guard let base = try JSONSerialization.jsonObject(with: commonData(id)) as? [String: Any],
              base["identifier"] as? String == id,
              base["type"] as? String == "common_office",
              let metadata = base["common_metadata"] as? [String: Any],
              metadata["schema_version"] as? Int == 1,
              base["common_office"] == nil else {
            throw Failure(message: "\(id)：通用身分／版本錯誤或存在巢狀繼承")
        }
        var result = proper
        for hour in ["vigil", "morning", "evening"] {
            if proper[hour] is NSNull {
                if hour == "vigil" { result["disabledVigil"] = true }
                continue
            }
            if let value = proper[hour], !(value is [String: Any]) {
                throw Failure(message: "\(id).\(hour)：時辰必須是物件或 null")
            }
            if let inherited = base[hour] {
                result[hour] = proper[hour].map { merge(inherited, $0) } ?? inherited
            }
            guard result[hour] != nil else { continue }
            let period = proper[hour] as? [String: Any] ?? [:]
            if metadata["requires_proper_collect"] as? Bool == true {
                let collects = (period["collect"] as? [[String: Any]])
                    ?? (period["collect"] as? [String: Any]).map { [$0] } ?? []
                guard !collects.isEmpty, collects.allSatisfy({ validText($0["text"]) }) else {
                    throw Failure(message: "\(id).\(hour).collect：需要聖日專用祝文")
                }
            }
        }
        for path in metadata["required_proper_fields"] as? [String] ?? [] {
            let keys = path.split(separator: ".").map(String.init)
            guard let hour = keys.first, !(proper[hour] is NSNull) else { continue }
            var value: Any? = proper
            for key in keys { value = (value as? [String: Any])?[key] }
            guard let value, !(value is NSNull) else {
                throw Failure(message: "\(id).\(path)：缺少聖日專用內容")
            }
        }
        return try JSONSerialization.data(withJSONObject: result)
    }

    private static func validText(_ value: Any?) -> Bool {
        if let text = value as? String { return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if let translations = value as? [String: Any] { return validText(translations["zh-hant"]) }
        return false
    }

    private static func merge(_ base: Any, _ proper: Any, key: String = "") -> Any {
        let atomic = ["collect", "office_hymn", "invitatory_hymn", "ascension_office_hymn", "easter_office_hymn", "ascension_invitatory_hymn"]
        guard !atomic.contains(key), let left = base as? [String: Any],
              let right = proper as? [String: Any],
              !right.keys.contains(where: { ["zh-hant", "zh-hans", "en"].contains($0) }) else { return proper }
        var output = left
        for (key, value) in right {
            output[key] = left[key].map { merge($0, value, key: key) } ?? value
        }
        return output
    }

    static func loadCommon(id: String, bundle: Bundle = .main) throws -> Data {
        guard let url = bundle.url(forResource: "common_office_index", withExtension: "json") else {
            throw Failure(message: "缺少 common_office_index.json")
        }
        let index = try JSONDecoder().decode([String: String].self, from: Data(contentsOf: url))
        guard let filename = index[id], let resource = bundle.url(forResource: filename, withExtension: "json") else {
            throw Failure(message: "\(id)：通用索引或資源不存在")
        }
        return try Data(contentsOf: resource)
    }
}
