import Foundation

final class BibleJSONService {
    static let shared = BibleJSONService()
    
    private let cache = NSCache<NSString, ChapterJSON>()
    
    // MARK: - 書卷名稱映射（與 BibleView.swift 保持一致）
    private let bookMapping: [String: String] = [
        // 正典
        "創世記": "GEN", "出埃及記": "EXO", "利未記": "LEV", "民數記": "NUM", "申命記": "DEU",
        "約書亞記": "JOS", "士師記": "JDG", "路得記": "RUT", "撒母耳記上": "1SA", "撒母耳記下": "2SA",
        "列王紀上": "1KI", "列王紀下": "2KI", "歷代志上": "1CH", "歷代志下": "2CH", "以斯拉記": "EZR",
        "尼希米記": "NEH", "以斯帖記": "EST", "約伯記": "JOB", "詩篇": "PSA", "箴言": "PRO",
        "傳道書": "ECC", "雅歌": "SNG", "以賽亞書": "ISA", "耶利米書": "JER", "耶利米哀歌": "LAM",
        "以西結書": "EZK", "但以理書": "DAN", "何西阿書": "HOS", "約珥書": "JOL", "阿摩司書": "AMO",
        "俄巴底亞書": "OBA", "約拿書": "JON", "彌迦書": "MIC", "那鴻書": "NAM", "哈巴谷書": "HAB",
        "西番雅書": "ZEP", "哈該書": "HAG", "撒迦利亞書": "ZEC", "瑪拉基書": "MAL",
        "馬太福音": "MAT", "馬可福音": "MRK", "路加福音": "LUK", "約翰福音": "JHN", "使徒行傳": "ACT",
        "羅馬書": "ROM", "哥林多前書": "1CO", "哥林多後書": "2CO", "加拉太書": "GAL", "以弗所書": "EPH",
        "腓立比書": "PHP", "歌羅西書": "COL", "帖撒羅尼迦前書": "1TH", "帖撒羅尼迦後書": "2TH",
        "提摩太前書": "1TI", "提摩太後書": "2TI", "提多書": "TIT", "腓利門書": "PHM", "希伯來書": "HEB",
        "雅各書": "JAS", "彼得前書": "1PE", "彼得後書": "2PE", "約翰一書": "1JN", "約翰二書": "2JN",
        "約翰三書": "3JN", "猶大書": "JUD", "啟示錄": "REV",
        // 次經
        "瑪喀比傳上": "1_Maccabees", "瑪喀比傳下": "2_Maccabees", "多比傳": "Tobit",
        "猶滴傳": "Judith", "便西拉智訓": "Sirach", "所羅門智訓": "Wisdom",
        "以斯拉續篇上": "1_Esdras", "以斯拉續篇下": "2_Esdras", "巴錄書": "Baruch",
        "耶利米書信": "Letter_Jeremiah", "瑪拿西禱言": "Pr_Manasseh", "三童歌": "Song_Three",
        "蘇撒拿傳": "Susanna", "比勒與大龍": "Bel_Dragon", "以斯帖補編": "Esther_Add"
    ]
    
    // MARK: - 對外接口
    
    /// 讀取指定經課引用的經文，整合為一段純文本（含節號）
    func fetchScripture(book: String, chapter: String) -> String? {
        // 🌟 統一連字符：防止中文輸入法自動替換的全角破折號導致解析失敗
        let normalizedChapter = chapter
            .replacingOccurrences(of: "\u{2013}", with: "-")  // EN DASH (–)
            .replacingOccurrences(of: "\u{2014}", with: "-")  // EM DASH (—)
            .replacingOccurrences(of: "\u{2010}", with: "-")  // HYPHEN (‐)
            .replacingOccurrences(of: "\u{2212}", with: "-")  // MINUS SIGN (−)
        
        guard let bookCode = bookMapping[book] else {
            print("❌ [BibleJSON] 未找到書卷映射: '\(book)'")
            return nil
        }
        
        let segments = parseSegments(normalizedChapter)   // ← 改為 normalizedChapter
        guard !segments.isEmpty else {
            print("❌ [BibleJSON] 無法解析章節範圍: '\(chapter)'")  // 日誌仍顯示原始值
            return nil
        }
        
        var allTexts: [String] = []
        
        for segment in segments {
            guard let chapterData = loadChapterJSON(bookCode: bookCode, chapter: segment.chapter) else {
                print("❌ [BibleJSON] \(book) \(chapter)：第\(segment.chapter)章檔案缺失或解析失敗，經文不完整")
                continue
            }
            let verses = extractVerses(from: chapterData, range: segment.verseRange)
            if !verses.isEmpty {
                allTexts.append(verses.joined(separator: " "))
            }
        }
        
        guard !allTexts.isEmpty else {
            print("❌ [BibleJSON] 所有章節均無法讀取: \(book) \(chapter)")
            return nil
        }
        let result = allTexts.joined(separator: " ")
        print("✅ [BibleJSON] 成功讀取 \(book) \(chapter) (\(result.count) 字)")
        return result
    }
    
    // MARK: - 私有：JSON 加載
    
    private func loadChapterJSON(bookCode: String, chapter: Int) -> ChapterJSON? {
        let cacheKey = "\(bookCode)_\(chapter)" as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }
        
        let resourceName = "\(bookCode)_\(chapter)"
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ [BibleJSON] 找不到檔案: \(resourceName).json")
            return nil
        }
        
        do {
            let decoded = try JSONDecoder().decode(ChapterJSON.self, from: data)
            cache.setObject(decoded, forKey: cacheKey)
            return decoded
        } catch {
            print("❌ [BibleJSON] 解析失敗 \(resourceName).json: \(error)")
            return nil
        }
    }
    
    // MARK: - 私有：經文提取（節號加回每節開頭）
    
    private func extractVerses(from chapterData: ChapterJSON, range: VerseRange?) -> [String] {
        let allKeys = chapterData.verses.keys.compactMap { Int($0) }.sorted()
        guard !allKeys.isEmpty else { return [] }
        
        let maxVerse = allKeys.max() ?? 0
        
        let filtered: [Int]
        if let range = range {
            let effectiveEnd = min(range.end, maxVerse)
            filtered = allKeys.filter { $0 >= range.start && $0 <= effectiveEnd }
        } else {
            filtered = allKeys
        }
        
        return filtered.compactMap { key -> String? in
            let text = chapterData.verses[String(key)]
            guard let t = text, !t.isEmpty, !t.contains("【併於上節】") else { return nil }
            return "\(key) \(t)"
        }
    }
    
    // MARK: - 私有：章節範圍解析
    
    /// 支援格式：
    /// - "14"           → 第14章全部
    /// - "14:25-35"     → 第14章 25-35節
    /// - "14:25"        → 第14章 25節至章末（經課慣例：單節無連字符表示讀到章末）
    /// - "1:1-6, 9-13"  → 第1章 1-6節、9-13節
    /// - "10:28-11:2"   → 第10章28節至第11章2節（跨章節）
    /// - "5:20-7:1"     → 第5章20節至第7章1節，中間第6章整章包含在內
    /// - "38:1-11、38:16-18、42:1-6" → 多段跨章
    private func parseSegments(_ chapterString: String) -> [ChapterSegment] {
        // 把括號轉為「、」分段，例如 "7:1-17 (18-end)" → "7:1-17 、18-end"
        let normalizedInput = chapterString
            .replacingOccurrences(of: "，", with: "、")  // 統一全形逗號為頓號
            .replacingOccurrences(of: "(", with: "、")
            .replacingOccurrences(of: ")", with: "")
        let majorParts = normalizedInput.components(separatedBy: "、")
        
        // 只有整個引用本身是單一範圍時，才沿用「單節讀到章末」的經課慣例。
        // 多段引用（如 "4:1、5、7-12"）中的單節必須只代表該節，避免重複輸出。
        let referencePartCount = majorParts.reduce(0) { count, part in
            let normalized = part
                .trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "：", with: ":")
            guard !normalized.isEmpty else { return count }
            
            if normalized.contains(":") {
                let subParts = normalized.split(separator: ":", maxSplits: 1)
                guard subParts.count == 2 else { return count + 1 }
                return count + String(subParts[1])
                    .components(separatedBy: ",")
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                    .count
            }
            
            return count + 1
        }
        let expandSingleVerseToChapterEnd = (referencePartCount == 1)
        
        var segments: [ChapterSegment] = []
        var currentChapter: Int? = nil
        
        for part in majorParts {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            
            let normalized = trimmed.replacingOccurrences(of: "：", with: ":")
            
            if normalized.contains(":") {
                let subParts = normalized.split(separator: ":", maxSplits: 1)
                guard subParts.count == 2,
                      let ch = Int(subParts[0].trimmingCharacters(in: .whitespaces)) else { continue }
                currentChapter = ch
                
                let verseRanges = String(subParts[1]).components(separatedBy: ",")
                for vRange in verseRanges {
                    let vTrimmed = vRange.trimmingCharacters(in: .whitespaces)
                    guard !vTrimmed.isEmpty else { continue }
                    
                    // 優先嘗試跨章節解析（如 28-11:2）
                    if let cross = parseCrossChapterRange(vTrimmed, startChapter: ch) {
                        segments.append(contentsOf: cross)
                    } else if let vr = parseVerseRange(
                        vTrimmed,
                        expandSingleVerseToChapterEnd: expandSingleVerseToChapterEnd
                    ) {
                        segments.append(ChapterSegment(chapter: ch, verseRange: vr))
                    } else {
                        print("⚠️ [BibleJSON] 無法解析節範圍: '\(vTrimmed)'")
                    }
                }
            } else if let ch = currentChapter,
                      let vr = parseVerseRange(
                          normalized,
                          expandSingleVerseToChapterEnd: expandSingleVerseToChapterEnd
                      ) {
                // 無冒號，繼承上一段的章號（如 "16-18"）
                segments.append(ChapterSegment(chapter: ch, verseRange: vr))
            } else if let ch = Int(normalized) {
                // 純數字，視為整章
                currentChapter = ch
                segments.append(ChapterSegment(chapter: ch, verseRange: nil))
            }
        }
        
        return segments
    }
    
    /// 解析跨章節範圍，如 "28-11:2" 或 "28—11:2"
    /// 返回 ChapterSegment 陣列：前半（到章末）+ 中間所有完整章 + 後半（從頭開始）
    /// 例如 5:20-7:1 → [5章20節-章末, 第6章整章, 7章1節]
    private func parseCrossChapterRange(_ text: String, startChapter: Int) -> [ChapterSegment]? {
        let separators = ["-", "—", "–"]
        for sep in separators {
            let parts = text.components(separatedBy: sep)
            guard parts.count == 2 else { continue }
            
            let startPart = parts[0].trimmingCharacters(in: .whitespaces)
            let endPart = parts[1].trimmingCharacters(in: .whitespaces)
            
            guard let startVerse = Int(startPart),
                  endPart.contains(":") else { continue }
            
            let endSubParts = endPart.split(separator: ":", maxSplits: 1)
            guard endSubParts.count == 2,
                  let endChapter = Int(endSubParts[0].trimmingCharacters(in: .whitespaces)) else { continue }
            
            // 新增：支援 "end" 作為結束節
            let endVerseStr = endSubParts[1].trimmingCharacters(in: .whitespaces)
            let endVerse: Int
            if endVerseStr.lowercased() == "end" {
                endVerse = 999
            } else {
                guard let ev = Int(endVerseStr) else { continue }
                endVerse = ev
            }
            
            // 防禦：結束章必須大於起始章，否則不是有效的跨章範圍
            guard endChapter > startChapter else { continue }

            var crossSegments: [ChapterSegment] = [
                ChapterSegment(chapter: startChapter, verseRange: VerseRange(start: startVerse, end: 999))
            ]
            // 補上中間所有完整章節（例如 5:20-7:1 中的第6章）
            if endChapter - startChapter > 1 {
                for midChapter in (startChapter + 1)...(endChapter - 1) {
                    crossSegments.append(ChapterSegment(chapter: midChapter, verseRange: nil))
                }
            }
            crossSegments.append(ChapterSegment(chapter: endChapter, verseRange: VerseRange(start: 1, end: endVerse)))
            return crossSegments
        }
        return nil
    }
    
    private func parseVerseRange(
        _ text: String,
        expandSingleVerseToChapterEnd: Bool
    ) -> VerseRange? {
        if text.contains(":") { return nil }
        
        let parts = text.components(separatedBy: "-")
        guard let start = Int(parts[0].trimmingCharacters(in: .whitespaces)) else { return nil }
        
        let end: Int
        if parts.count > 1 {
            let endStr = parts[1].trimmingCharacters(in: .whitespaces)
            if endStr.isEmpty || endStr.lowercased() == "end" {
                end = 999   // 由 extractVerses 自動截斷到實際最大節數
            } else {
                guard let e = Int(endStr) else { return nil }
                end = e
            }
        } else {
            // 單一引用（如 "1:10"）沿用經課慣例讀到章末；
            // 多段引用（如 "4:1、5、7-12"）中的單節只讀該節。
            end = expandSingleVerseToChapterEnd ? 999 : start
        }
        
        return VerseRange(start: start, end: end)
    }
}

// MARK: - 內部模型（class 以滿足 NSCache 要求）

private final class ChapterJSON: Codable {
    let verses: [String: String]
    let headings: [String: String]?
    let paragraph_starts: [Int]?

    private enum CodingKeys: String, CodingKey {
        case verses, headings, paragraph_starts
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        verses = try c.decode([String: String].self, forKey: .verses)
        // 型別不符時靜默視為 nil，不讓它拖垮整個 decode
        headings = try? c.decodeIfPresent([String: String].self, forKey: .headings) ?? nil
        paragraph_starts = try? c.decodeIfPresent([Int].self, forKey: .paragraph_starts) ?? nil
    }
}

private struct VerseRange {
    let start: Int
    let end: Int
}

private struct ChapterSegment {
    let chapter: Int
    let verseRange: VerseRange?  // nil 表示整章
}
