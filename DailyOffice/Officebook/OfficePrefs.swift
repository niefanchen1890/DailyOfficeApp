import Foundation

// MARK: - 早晚禱選項記憶工具
// 用法：在 ViewModel 的 @Published 屬性上
//   宣告時用 OfficePrefs.restore 讀取上次選擇，
//   didSet 裡用 OfficePrefs.save 存檔。
// 早晚禱共用同一個 key 的選項（信經、經課版本等），換頁時也會保持一致。
enum OfficePrefs {
    
    // MARK: - Key 定義（早晚禱共用者用同一個 key）
    enum Key {
        static let creed              = "officePref.creed"
        static let absolutionVersion  = "officePref.absolutionVersion"
        static let preparatoryOption  = "officePref.preparatoryOption"
        static let prayerResponse     = "officePref.prayerResponse"
        static let stPatrickOption    = "officePref.stPatrickOption"
        static let generalPrayerOption = "officePref.generalPrayerOption"
        static let lectionaryYear     = "officePref.lectionaryYear"
        static let psalmLectionary    = "officePref.psalmLectionary"
        // 早禱專屬
        static let veniteEnding       = "officePref.veniteEnding"
        // 晚禱專屬
        static let gloriaOption       = "officePref.gloriaOption"
        static let secondCanticle     = "officePref.secondCanticle.evening"
    }
    
    // MARK: - String raw value enum 的存取
    static func restore<T: RawRepresentable>(_ key: String, default defaultValue: T) -> T where T.RawValue == String {
        guard let raw = UserDefaults.standard.string(forKey: key),
              let value = T(rawValue: raw) else { return defaultValue }
        return value
    }
    
    static func save<T: RawRepresentable>(_ value: T, key: String) where T.RawValue == String {
        UserDefaults.standard.set(value.rawValue, forKey: key)
    }
    
    // MARK: - 純 String（經課版本、詩篇選擇）的存取
    static func restoreString(_ key: String, default defaultValue: String) -> String {
        UserDefaults.standard.string(forKey: key) ?? defaultValue
    }
    
    static func saveString(_ value: String, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
