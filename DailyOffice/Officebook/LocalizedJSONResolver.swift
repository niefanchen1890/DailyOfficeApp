import Foundation

/// 共用工具：在 JSONDecoder 之前，遞迴把 {"zh-hant": "...", "zh-hans": "..."} 替換為當前語言的純字串
struct LocalizedJSONResolver {
    static func resolve(data: Data, language: AppLanguage) -> Data? {
        guard var json = try? JSONSerialization.jsonObject(with: data) else { return nil }
        resolve(in: &json, language: language)
        return try? JSONSerialization.data(withJSONObject: json)
    }
    
    private static func resolve(in object: inout Any, language: AppLanguage) {
        if var dict = object as? [String: Any] {
            let hasHant = dict.keys.contains("zh-hant")
            let hasHans = dict.keys.contains("zh-hans")
            
            // 這個字典同時含 zh-hant / zh-hans → 是多語言欄位
            if hasHant || hasHans {
                let targetKey = (language == .traditional) ? "zh-hant" : "zh-hans"
                let fallbackKey = "zh-hant" // 簡體缺失時回退繁體
                
                if let localizedValue = dict[targetKey] ?? dict[fallbackKey] {
                    object = localizedValue
                    return
                }
            }
            
            // 不是多語言字典，繼續遞迴
            for (key, var value) in dict {
                resolve(in: &value, language: language)
                dict[key] = value
            }
            object = dict
            
        } else if var array = object as? [Any] {
            for i in array.indices {
                var item = array[i]
                resolve(in: &item, language: language)
                array[i] = item
            }
            object = array
        }
        // String / Number / Bool / null 不處理
    }
}
