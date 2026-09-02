import Foundation
import UIKit
import SwiftUI

// MARK: - PublishPress Authors 模型
struct PPAuthor: Codable {
    let term_id: Int?
    let user_id: Int?
    let is_guest: Int?
    let slug: String?
    let display_name: String?
    let avatar_url: AvatarURL?
    let first_name: String?
    let last_name: String?
    let description: String?
    
    // avatar_url 可能是字符串或對象
    struct AvatarURL: Codable {
        let url: String?
        let url2x: String?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let stringURL = try? container.decode(String.self) {
                self.url = stringURL
                self.url2x = nil
            } else {
                let obj = try decoder.container(keyedBy: CodingKeys.self)
                self.url = try obj.decodeIfPresent(String.self, forKey: .url)
                self.url2x = try obj.decodeIfPresent(String.self, forKey: .url2x)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case url, url2x
        }
    }
    
    /// 合併顯示名稱（優先 display_name，其次 first_name + last_name）
    var fullName: String {
        if let name = display_name, !name.isEmpty { return name }
        let first = first_name ?? ""
        let last = last_name ?? ""
        let combined = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        return combined.isEmpty ? "未知作者" : combined
    }
    
    var avatarImageURL: URL? {
        if let urlString = avatar_url?.url {
            return URL(string: urlString)
        }
        return nil
    }
}

// MARK: - WordPress API 模型
struct WPPost: Codable, Identifiable {
    let id: Int
    let date: String
    let title: RenderedContent
    let content: RenderedContent
    let excerpt: RenderedContent
    let link: String
    let jetpack_featured_media_url: String?
    
    // ✅ PublishPress Authors 字段
    let authors: [PPAuthor]?
    
    struct RenderedContent: Codable {
        let rendered: String
    }
    
    var cleanTitle: String { title.rendered.htmlDecoded.strippingHTML }
    var cleanExcerpt: String { excerpt.rendered.htmlDecoded.strippingHTML }
    
    // ✅ 修復：支持 WordPress 多種日期格式
    var parsedDate: Date? {
        let formatters: [DateFormatter] = [
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                f.locale = Locale(identifier: "en_US_POSIX")
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                f.locale = Locale(identifier: "en_US_POSIX")
                f.timeZone = TimeZone(secondsFromGMT: 0)
                return f
            }(),
            {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                f.locale = Locale(identifier: "en_US_POSIX")
                f.timeZone = TimeZone(secondsFromGMT: 0)
                return f
            }()
        ]
        
        for formatter in formatters {
            if let d = formatter.date(from: date) { return d }
        }
        return nil
    }
    
    // ✅ 中文格式化日期，如「2026年5月25日」
    var formattedDate: String {
        guard let d = parsedDate else { return "" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hant")
        f.dateStyle = .long
        return f.string(from: d)
    }
    
    var featuredImageURL: URL? {
        jetpack_featured_media_url.flatMap { URL(string: $0) }
    }
    
    // ✅ 作者名稱拼接（如「張三、李四」）
    var authorDisplayNames: String {
        guard let authors = authors, !authors.isEmpty else { return "" }
        return authors.map { $0.fullName }.joined(separator: "、")
    }
}

// MARK: - HTML 處理擴展（純 Swift，無 NSAttributedString，避免 SIGABRT）
extension String {
    var strippingHTML: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    var htmlDecoded: String {
        guard contains("&") else { return self }
        
        var result = self
        
        let namedEntities: [(String, String)] = [
            ("&amp;", "&"), ("&lt;", "<"), ("&gt;", ">"),
            ("&quot;", "\""), ("&apos;", "'"), ("&nbsp;", "\u{00A0}"),
            ("&ndash;", "\u{2013}"), ("&mdash;", "\u{2014}"),
            ("&lsquo;", "\u{2018}"), ("&rsquo;", "\u{2019}"),
            ("&ldquo;", "\u{201C}"), ("&rdquo;", "\u{201D}"),
            ("&hellip;", "\u{2026}"), ("&copy;", "\u{00A9}"),
        ]
        for (entity, char) in namedEntities {
            result = result.replacingOccurrences(of: entity, with: char)
        }
        
        if let regex = try? NSRegularExpression(pattern: "&#(\\d+);", options: []) {
            let matches = regex.matches(in: result, options: [], range: NSRange(result.startIndex..., in: result))
            for match in matches.reversed() {
                guard let numRange = Range(match.range(at: 1), in: result),
                      let num = Int(result[numRange]),
                      let scalar = UnicodeScalar(num) else { continue }
                let fullRange = Range(match.range, in: result)!
                result.replaceSubrange(fullRange, with: String(scalar))
            }
        }
        
        if let regex = try? NSRegularExpression(pattern: "&#x([0-9A-Fa-f]+);", options: []) {
            let matches = regex.matches(in: result, options: [], range: NSRange(result.startIndex..., in: result))
            for match in matches.reversed() {
                guard let numRange = Range(match.range(at: 1), in: result),
                      let num = Int(result[numRange], radix: 16),
                      let scalar = UnicodeScalar(num) else { continue }
                let fullRange = Range(match.range, in: result)!
                result.replaceSubrange(fullRange, with: String(scalar))
            }
        }
        
        return result
    }
}

// MARK: - 顏色輔助（供 WebView 使用）
extension UIColor {
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }
}

extension Color {
    func toHex() -> String {
        UIColor(self).hexString
    }
}
