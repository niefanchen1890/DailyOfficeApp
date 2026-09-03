import Foundation

// 經文畫面共用的顯示模型；正文由 BibleJSONService 提供。
struct BibleVerse: Identifiable {
    var id: String { "\(verse)-\(content.hashValue)" }
    let verse: Int
    let content: String
}

/// 從 lectionary_1928、lectionary_1962 資料夾讀取每日經課。
/// 此服務只讀 JSON，不會開啟或查詢 SQLite 資料庫。
final class LectionaryJSONService {
    static let shared = LectionaryJSONService()

    private struct ResourceFile: Decodable {
        let id: String
        let office: String
        let lessons: Lessons
    }

    private struct Lessons: Decodable {
        let ot: Lesson?
        let nt: Lesson?
    }

    private struct Lesson: Decodable {
        let book: String
        let chapter: String
    }

    private let decoder = JSONDecoder()
    private var cache: [String: [LectionaryDay]] = [:]
    private let lock = NSLock()

    private init() {}

    /// 讀取一個節期中指定週次的全部經課，例如 ad1、lent3。
    func fetchLectionary(year: String, season: String, week: Int) -> [LectionaryDay] {
        guard week >= 0 else {
            AppLog.warning("⚠️ [經課 JSON] 無效的 week: \(week)")
            return []
        }
        return readings(year: year, keyPrefix: "\(season)\(week)-")
    }

    /// 讀取固定日期或特殊節期代碼，例如 1225、tr、christmas1。
    func fetchLectionaryBySpecificKey(year: String, keyPrefix: String) -> [LectionaryDay] {
        readings(year: year, keyPrefix: "\(keyPrefix)-")
    }

    func clearCache() {
        lock.lock()
        cache.removeAll()
        lock.unlock()
    }

    private func readings(year: String, keyPrefix: String) -> [LectionaryDay] {
        guard year == "1928" || year == "1962" else {
            AppLog.warning("⚠️ [經課 JSON] 不支援的經課版本: \(year)")
            return []
        }

        let cacheKey = "\(year)|\(keyPrefix)"
        lock.lock()
        if let cached = cache[cacheKey] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        // 每次只解析目前節期或日期需要的少量檔案，避免首次開啟畫面時
        // 一次解析近兩千個 JSON，造成畫面短暫停頓。
        let filenamePrefix = "\(year)_"
        let urls = resourceURLs(year: year).filter {
            let filename = $0.deletingPathExtension().lastPathComponent
            let resourceID = filename.hasPrefix(filenamePrefix)
                ? String(filename.dropFirst(filenamePrefix.count))
                : filename
            return resourceID.hasPrefix(keyPrefix)
        }
        var result: [LectionaryDay] = []

        for url in urls {
            do {
                let data = try Data(contentsOf: url)
                let file = try decoder.decode(ResourceFile.self, from: data)
                result.append(contentsOf: makeDays(from: file))
            } catch {
                AppLog.error("❌ [經課 JSON] 解析失敗 \(url.lastPathComponent): \(error)")
            }
        }

        result.sort {
            if $0.dayKey == $1.dayKey { return $0.book < $1.book }
            return $0.dayKey < $1.dayKey
        }

        lock.lock()
        cache[cacheKey] = result
        lock.unlock()

        if result.isEmpty {
            AppLog.error("❌ [經課 JSON] lectionary_\(year) 找不到 \(keyPrefix)*")
        } else {
            AppLog.debug("📖 [經課 JSON] lectionary_\(year)/\(keyPrefix)* 載入 \(urls.count) 個檔案、\(result.count) 段經題")
        }
        return result
    }

    private func makeDays(from file: ResourceFile) -> [LectionaryDay] {
        var result: [LectionaryDay] = []
        let officeCode = file.office.lowercased() == "evening" ? "E" : "M"
        let baseKey = file.id.hasSuffix("-M") || file.id.hasSuffix("-E")
            ? file.id
            : "\(file.id)-\(officeCode)"

        if let lesson = file.lessons.ot {
            result.append(makeDay(baseKey: baseKey, testament: "OT", lesson: lesson))
        }
        if let lesson = file.lessons.nt {
            result.append(makeDay(baseKey: baseKey, testament: "NT", lesson: lesson))
        }
        return result
    }

    private func makeDay(baseKey: String, testament: String, lesson: Lesson) -> LectionaryDay {
        LectionaryDay(
            season: "json",
            weekIndex: 0,
            dayKey: "\(baseKey)-\(testament)",
            book: lesson.book,
            chapter: lesson.chapter
        )
    }

    private func resourceURLs(year: String) -> [URL] {
        let folder = "lectionary_\(year)"
        let filenamePrefix = "\(year)_"

        // Xcode 會把一般資源資料夾的內容放到 App 資源根目錄。
        // 實際檔名帶年份後，即使 1928、1962 的經課代碼相同也不會碰撞。
        let bundledURLs = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        let prefixedURLs = bundledURLs.filter {
            $0.deletingPathExtension().lastPathComponent.hasPrefix(filenamePrefix)
        }
        if !prefixedURLs.isEmpty {
            return prefixedURLs.sorted { $0.lastPathComponent < $1.lastPathComponent }
        }

        // 保留資料夾形式的相容處理，方便 Preview、測試或日後改為 folder reference。
        let candidates = [
            "Resources/Officebook/\(folder)",
            "Officebook/\(folder)",
            folder
        ]

        for subdirectory in candidates {
            if let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: subdirectory),
               !urls.isEmpty {
                return urls.sorted { $0.lastPathComponent < $1.lastPathComponent }
            }
        }

        let marker = "/\(folder)/"
        return bundledURLs
            .filter { $0.path.contains(marker) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
