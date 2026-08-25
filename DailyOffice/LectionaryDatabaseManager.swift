import Foundation
import SQLite3

// 專供經課表顯示經文用的資料結構
struct BibleVerse: Identifiable {
    var id: String { "\(verse)-\(content.hashValue)" }
    let verse: Int // 儲存該段落的起始節數
    let content: String
}

class LectionaryDatabaseManager {
    static let shared = LectionaryDatabaseManager()
    var db: OpaquePointer?
    private let dbQueue = DispatchQueue(
        label: "com.dailyoffice.lectionarydb",
        qos: .userInitiated
    )
    // 書卷名稱與代碼的映射字典 (例如：創世記 -> GEN)
    private let bookToCode: [String: String]
    // 快速判斷是否為次經的集合
    private let apocryphaCodes: Set<String>
    
    init() {
        // 1. 正典書卷 (39 + 27)
        let canonical = [
            ("創世記", "GEN"), ("出埃及記", "EXO"), ("利未記", "LEV"), ("民數記", "NUM"), ("申命記", "DEU"),
            ("約書亞記", "JOS"), ("士師記", "JDG"), ("路得記", "RUT"), ("撒母耳記上", "1SA"), ("撒母耳記下", "2SA"),
            ("列王紀上", "1KI"), ("列王紀下", "2KI"), ("歷代志上", "1CH"), ("歷代志下", "2CH"), ("以斯拉記", "EZR"),
            ("尼希米記", "NEH"), ("以斯帖記", "EST"), ("約伯記", "JOB"), ("詩篇", "PSA"), ("箴言", "PRO"),
            ("傳道書", "ECC"), ("雅歌", "SNG"), ("以賽亞書", "ISA"), ("耶利米書", "JER"), ("耶利米哀歌", "LAM"),
            ("以西結書", "EZK"), ("但以理書", "DAN"), ("何西阿書", "HOS"), ("約珥書", "JOL"), ("阿摩司書", "AMO"),
            ("俄巴底亞書", "OBA"), ("約拿書", "JON"), ("彌迦書", "MIC"), ("那鴻書", "NAM"), ("哈巴谷書", "HAB"),
            ("西番雅書", "ZEP"), ("哈該書", "HAG"), ("撒迦利亞書", "ZEC"), ("瑪拉基書", "MAL"),
            ("馬太福音", "MAT"), ("馬可福音", "MRK"), ("路加福音", "LUK"), ("約翰福音", "JHN"), ("使徒行傳", "ACT"),
            ("羅馬書", "ROM"), ("哥林多前書", "1CO"), ("哥林多後書", "2CO"), ("加拉太書", "GAL"), ("以弗所書", "EPH"),
            ("腓立比書", "PHP"), ("歌羅西書", "COL"), ("帖撒羅尼迦前書", "1TH"), ("帖撒羅尼迦後書", "2TH"),
            ("提摩太前書", "1TI"), ("提摩太後書", "2TI"), ("提多書", "TIT"), ("腓利門書", "PHM"), ("希伯來書", "HEB"),
            ("雅各書", "JAS"), ("彼得前書", "1PE"), ("彼得後書", "2PE"), ("約翰一書", "1JN"), ("約翰二書", "2JN"),
            ("約翰三書", "3JN"), ("猶大書", "JUD"), ("啟示錄", "REV")
        ]
        
        // 2. 次經 (15 卷) - 🌟 這裡保持「沒有卷字」的格式，因為這是資料庫裡的名稱
        let apocrypha = [
            ("瑪喀比傳上", "1_Maccabees"),
            ("瑪喀比傳下", "2_Maccabees"),
            ("多比傳", "Tobit"),
            ("猶滴傳", "Judith"),
            ("便西拉智訓", "Sirach"),
            ("所羅門智訓", "Wisdom"),
            ("以斯拉續篇上", "1_Esdras"),
            ("以斯拉續篇下", "2_Esdras"),
            ("巴錄書", "Baruch"),
            ("耶利米書信", "Letter_Jeremiah"),
            ("瑪拿西禱言", "Pr_Manasseh"),
            ("三童歌", "Song_Three"),
            ("蘇撒拿傳", "Susanna"),
            ("比勒與大龍", "Bel_Dragon"),
            ("以斯帖記補編", "Esther_Add")
        ]
        
        var map = [String: String]()
        for item in canonical { map[item.0] = item.1 }
        for item in apocrypha { map[item.0] = item.1 }
        self.bookToCode = map
        self.apocryphaCodes = Set(apocrypha.map { $0.1 })
        
        openDatabase()
    }
    
    func openDatabase() {
        guard let dbPath = Bundle.main.path(forResource: "bible_all_versions", ofType: "db") else { return }
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("❌ 無法開啟資料庫")
        }
    }
    
    // 🌟 核心：正規化書卷名稱 (把經課表的怪名字，轉成我們資料庫認得的名字)
    private func normalizeBookName(_ name: String) -> String {
        var cleanName = name.trimmingCharacters(in: .whitespaces)
        
        // 解決「以斯拉續篇上/下」後面多了個「卷」字的問題
        if cleanName == "以斯拉續篇上卷" || cleanName == "以斯拉續編上卷" {
            cleanName = "以斯拉續篇上"
        }
        if cleanName == "以斯拉續篇下卷" || cleanName == "以斯拉續編下卷" {
            cleanName = "以斯拉續篇下"
        }
        
        // 這裡可以繼續添加其他的名稱修正，例如「哥林多前書」變成「哥聯多前書」之類的
        
        return cleanName
    }
    
    // MARK: - 輔助方法
    func isApocrypha(bookName: String) -> Bool {
        let normalizedName = normalizeBookName(bookName) // 先正規化
        guard let code = bookToCode[normalizedName] else { return false }
        return apocryphaCodes.contains(code)
    }
    
    // MARK: - 獲取經課表目錄（線程安全版）
    func fetchLectionary(year: String, season: String, week: Int) -> [LectionaryDay] {
        return dbQueue.sync {
            var results: [LectionaryDay] = []
            
            guard let db = self.db else {
                print("❌ 數據庫未開啟")
                return []
            }
            
            guard week >= 0 else {
                print("⚠️ 無效的 week: \(week)")
                return []
            }
            
            let tableName = "lectionary_\(year)"
            let query = "SELECT file_key, book_name, reference FROM \(tableName) WHERE file_key LIKE ? ORDER BY id ASC"
            var statement: OpaquePointer?
            
            guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
                let errMsg = String(cString: sqlite3_errmsg(db))
                print("❌ SQL 準備失敗: \(errMsg)")
                return []
            }
            
            // 🌟 修正：使用 withCString，無需 SQLITE_TRANSIENT
            let pattern = "\(season)\(week)-%"
            pattern.withCString { cPattern in
                sqlite3_bind_text(statement, 1, cPattern, -1, nil)
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let fileKey = String(cString: sqlite3_column_text(statement, 0))
                    let bookName = String(cString: sqlite3_column_text(statement, 1))
                    let reference = String(cString: sqlite3_column_text(statement, 2))
                    results.append(LectionaryDay(
                        season: season,
                        weekIndex: week,
                        dayKey: fileKey,
                        book: bookName,
                        chapter: reference
                    ))
                }
            }
            
            sqlite3_finalize(statement)
            return results
        }
    }
    
    // MARK: - 精確截斷版經文獲取引擎
    func fetchVerses(version: String, book: String, reference: String) -> [BibleVerse] {
        return dbQueue.sync {
            let normalizedName = normalizeBookName(book)
            guard let bookCode = bookToCode[normalizedName] else {
                print("❌ 找不到書卷映射：\(book) (正規化後為: \(normalizedName))")
                return []
            }
            
            let actualVersion = version
            
            // 解析 reference 為多個查詢區間
            let ranges = parseReference(reference)
            
            var results: [BibleVerse] = []
            let verseRegex = try? NSRegularExpression(pattern: "\\d+", options: [])
            
            for req in ranges {
                let query = "SELECT verse_range, content FROM paragraphs WHERE version = ? AND book_name = ? AND chapter = ? ORDER BY id ASC"
                var statement: OpaquePointer?
                
                if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_text(statement, 1, (actualVersion as NSString).utf8String, -1, nil)
                    sqlite3_bind_text(statement, 2, (bookCode as NSString).utf8String, -1, nil)
                    sqlite3_bind_text(statement, 3, (req.chapter as NSString).utf8String, -1, nil)
                    
                    while sqlite3_step(statement) == SQLITE_ROW {
                        let vRangeStr = String(cString: sqlite3_column_text(statement, 0))
                        let contentStr = String(cString: sqlite3_column_text(statement, 1))
                        
                        var dbStart = 0
                        var dbEnd = 0
                        if vRangeStr.contains("-") {
                            let parts = vRangeStr.components(separatedBy: "-")
                            dbStart = Int(parts[0]) ?? 0
                            dbEnd = Int(parts[1]) ?? 0
                        } else {
                            dbStart = Int(vRangeStr) ?? 0
                            dbEnd = dbStart
                        }
                        
                        if dbStart <= req.endVerse && dbEnd >= req.startVerse {
                            var finalContent = contentStr
                                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                                .replacingOccurrences(of: "[（\\(].*?[）\\)]", with: "", options: .regularExpression)
                            
                            let needTrimEnd = req.endVerse < dbEnd && req.endVerse != 999
                            let needTrimStart = req.startVerse > dbStart
                            
                            if needTrimEnd {
                                let nsString = finalContent as NSString
                                let matches = verseRegex?.matches(in: finalContent, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
                                for match in matches {
                                    let matchStr = nsString.substring(with: match.range)
                                    if let verseNum = Int(matchStr), verseNum > req.endVerse {
                                        finalContent = nsString.substring(to: match.range.location)
                                        break
                                    }
                                }
                            }
                            
                            if needTrimStart {
                                let nsString = finalContent as NSString
                                let matches = verseRegex?.matches(in: finalContent, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
                                for match in matches {
                                    let matchStr = nsString.substring(with: match.range)
                                    if let verseNum = Int(matchStr), verseNum >= req.startVerse {
                                        finalContent = nsString.substring(from: match.range.location)
                                        break
                                    }
                                }
                            }
                            
                            let trimmed = finalContent.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                results.append(BibleVerse(verse: dbStart, content: trimmed))
                            }
                        }
                    }
                }
                sqlite3_finalize(statement)
            }
            return results
        }
    }
    
    // MARK: - 經題解析引擎
    
    /// 將經題字串解析為多個 (chapter, startVerse, endVerse) 區間
    private func parseReference(_ reference: String) -> [(chapter: String, startVerse: Int, endVerse: Int)] {
        let cleanRef = reference.trimmingCharacters(in: .whitespaces)
        
        // 空引用視為整章/整卷（第1章全部）
        if cleanRef.isEmpty {
            return [(chapter: "1", startVerse: 1, endVerse: 999)]
        }
        
        // 1. 清理括號：提取括號內容作為額外段落
        var extraParts: [String] = []
        var temp = cleanRef
            .replacingOccurrences(of: "（", with: "(")
            .replacingOccurrences(of: "）", with: ")")
            .replacingOccurrences(of: "節", with: "")
        
        while let openIdx = temp.firstIndex(of: "(") {
            if let closeIdx = temp.firstIndex(of: ")"), closeIdx > openIdx {
                let start = temp.index(after: openIdx)
                let extra = String(temp[start..<closeIdx]).trimmingCharacters(in: .whitespaces)
                if !extra.isEmpty {
                    extraParts.append(extra)
                }
                temp.removeSubrange(openIdx...closeIdx)
            } else {
                break
            }
        }
        let mainRef = temp.trimmingCharacters(in: .whitespaces)
        
        // 2. 解析主內容
        var result = parseReferencePart(mainRef)
        
        // 3. 從主內容提取預設章號（供無冒號的括號內容使用）
        let defaultChapter = result.last?.chapter
        
        // 4. 解析額外內容
        for extra in extraParts {
            result.append(contentsOf: parseReferencePart(extra, defaultChapter: defaultChapter))
        }
        
        // 5. 去重
        var unique: [(chapter: String, startVerse: Int, endVerse: Int)] = []
        for item in result {
            if !unique.contains(where: { $0.chapter == item.chapter && $0.startVerse == item.startVerse && $0.endVerse == item.endVerse }) {
                unique.append(item)
            }
        }
        
        return unique
    }
    
    /// 解析單個經題段落
    private func parseReferencePart(_ part: String, defaultChapter: String? = nil) -> [(chapter: String, startVerse: Int, endVerse: Int)] {
        var result: [(chapter: String, startVerse: Int, endVerse: Int)] = []
        
        // 統一分隔符與冒號
        let clean = part
            .replacingOccurrences(of: "、", with: ",")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "：", with: ":")
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
        
        let segments = clean.components(separatedBy: ",")
        let partHasColon = clean.contains(":")
        var currentChapter: String? = defaultChapter
        
        for segment in segments {
            let trimmed = segment.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            
            // 去掉字母後綴（如 9a, 9b）
            let alphaRemoved = trimmed.replacingOccurrences(of: "[a-zA-Z]", with: "", options: .regularExpression)
            
            if alphaRemoved.contains(":") {
                // 包含冒號，提取章號
                let parts = alphaRemoved.split(separator: ":", maxSplits: 1).map { String($0) }
                guard parts.count >= 2 else { continue }
                
                let ch = parts[0].trimmingCharacters(in: .whitespaces)
                currentChapter = ch
                
                let versePart = parts[1].trimmingCharacters(in: .whitespaces)
                
                if versePart.contains("-") {
                    let vParts = versePart.components(separatedBy: "-")
                    let startVStr = vParts[0].trimmingCharacters(in: .whitespaces)
                    
                    if vParts.count >= 2 {
                        let endVStr = vParts[1].trimmingCharacters(in: .whitespaces)
                        
                        // 檢查結束部分是否包含冒號（跨章節）
                        if endVStr.contains(":") {
                            let endParts = endVStr.split(separator: ":", maxSplits: 1).map { String($0) }
                            if endParts.count == 2 {
                                let endCh = endParts[0].trimmingCharacters(in: .whitespaces)
                                let endV = parseVerseNumber(endParts[1]) ?? 999
                                let startV = parseVerseNumber(startVStr) ?? 1
                                
                                // 第一段：從 startVerse 到章末
                                result.append((chapter: ch, startVerse: startV, endVerse: 999))
                                
                                // 中間章節：全部（如有）
                                if let startChInt = Int(ch), let endChInt = Int(endCh), endChInt > startChInt + 1 {
                                    for middleCh in (startChInt + 1)..<endChInt {
                                        result.append((chapter: String(middleCh), startVerse: 1, endVerse: 999))
                                    }
                                }
                                
                                // 最後一段：從 1 到 endVerse
                                result.append((chapter: endCh, startVerse: 1, endVerse: endV))
                            }
                        } else {
                            let startV = parseVerseNumber(startVStr) ?? 1
                            let endV = parseVerseNumber(endVStr) ?? 999
                            result.append((chapter: ch, startVerse: startV, endVerse: endV))
                        }
                    }
                } else {
                    let v = parseVerseNumber(versePart) ?? 1
                    result.append((chapter: ch, startVerse: v, endVerse: v))
                }
            } else if alphaRemoved.contains("-") {
                let vParts = alphaRemoved.components(separatedBy: "-")
                let startV = parseVerseNumber(vParts[0]) ?? 1
                let endV = parseVerseNumber(vParts[1]) ?? 999
                
                if partHasColon && currentChapter != nil {
                    result.append((chapter: currentChapter!, startVerse: startV, endVerse: endV))
                } else {
                    result.append((chapter: currentChapter ?? "1", startVerse: startV, endVerse: endV))
                }
            } else if let v = parseVerseNumber(alphaRemoved) {
                if partHasColon && currentChapter != nil {
                    result.append((chapter: currentChapter!, startVerse: v, endVerse: v))
                } else {
                    currentChapter = String(v)
                    result.append((chapter: String(v), startVerse: 1, endVerse: 999))
                }
            }
        }
        
        return result
    }
    
    /// 解析單個節號，支援 "end" 與字母後綴
    private func parseVerseNumber(_ str: String) -> Int? {
        let clean = str.trimmingCharacters(in: .whitespaces).lowercased()
        if clean == "end" {
            return 999
        }
        let numeric = clean.filter { $0.isNumber }
        guard !numeric.isEmpty else { return nil }
        return Int(numeric)
    }
}

extension LectionaryDatabaseManager {
    func fetchLectionaryBySpecificKey(year: String, keyPrefix: String) -> [LectionaryDay] {
        return dbQueue.sync {
            var results: [LectionaryDay] = []
            
            guard let db = self.db else {
                print("❌ 數據庫未開啟")
                return []
            }
            
            let tableName = "lectionary_\(year)"
            let query = "SELECT file_key, book_name, reference FROM \(tableName) WHERE file_key LIKE ? ORDER BY id ASC"
            var statement: OpaquePointer?
            
            guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
                let errMsg = String(cString: sqlite3_errmsg(db))
                print("❌ SQL 準備失敗: \(errMsg)")
                return []
            }
            
            let pattern = "\(keyPrefix)-%"
            pattern.withCString { cPattern in
                sqlite3_bind_text(statement, 1, cPattern, -1, nil)
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let fileKey = String(cString: sqlite3_column_text(statement, 0))
                    let bookName = String(cString: sqlite3_column_text(statement, 1))
                    let reference = String(cString: sqlite3_column_text(statement, 2))
                    results.append(LectionaryDay(
                        season: "fixed",
                        weekIndex: 0,
                        dayKey: fileKey,
                        book: bookName,
                        chapter: reference
                    ))
                }
            }
            
            sqlite3_finalize(statement)
            return results
        }
    }
}
