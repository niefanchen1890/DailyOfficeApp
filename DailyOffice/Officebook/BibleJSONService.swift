import Foundation

final class BibleJSONService {
    static let shared = BibleJSONService()
    
    // 🌟 快取加入了語言區分
    private let cache = NSCache<NSString, ChapterJSON>()
    
    // MARK: - 書卷名稱映射（支援繁簡體輸入，並自動過濾重複鍵值）
    private let bookMapping: [String: String] = {
        var map: [String: String] = [:]
        
        // 繁體映射
        let traditional: [String: String] = [
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
            "瑪喀比傳上": "1_Maccabees", "瑪喀比傳下": "2_Maccabees", "多比傳": "Tobit",
            "猶滴傳": "Judith", "便西拉智訓": "Sirach", "所羅門智訓": "Wisdom",
            "以斯拉續篇上": "1_Esdras", "以斯拉續篇下": "2_Esdras", "巴錄書": "Baruch",
            "耶利米書信": "Letter_Jeremiah", "瑪拿西禱言": "Pr_Manasseh", "三童歌": "Song_Three",
            "蘇撒拿傳": "Susanna", "比勒與大龍": "Bel_Dragon", "以斯帖補編": "Esther_Add"
        ]
        
        // 簡體映射
        let simplified: [String: String] = [
            "创世记": "GEN", "出埃及记": "EXO", "利未记": "LEV", "民数记": "NUM", "申命记": "DEU",
            "约书亚记": "JOS", "士师记": "JDG", "路得记": "RUT", "撒母耳记上": "1SA", "撒母耳记下": "2SA",
            "列王纪上": "1KI", "列王纪下": "2KI", "历代志上": "1CH", "历代志下": "2CH", "以斯拉记": "EZR",
            "尼希米记": "NEH", "以斯帖记": "EST", "约伯记": "JOB", "诗篇": "PSA", "箴言": "PRO",
            "传道书": "ECC", "雅歌": "SNG", "以赛亚书": "ISA", "耶利米书": "JER", "耶利米哀歌": "LAM",
            "以西结书": "EZK", "但以理书": "DAN", "何西阿书": "HOS", "约珥书": "JOL", "阿摩司书": "AMO",
            "俄巴底亚书": "OBA", "约拿书": "JON", "弥迦书": "MIC", "那鸿书": "NAM", "哈巴谷书": "HAB",
            "西番雅书": "ZEP", "哈该书": "HAG", "撒迦利亚书": "ZEC", "玛拉基书": "MAL",
            "马太福音": "MAT", "马可福音": "MRK", "路加福音": "LUK", "约翰福音": "JHN", "使徒行传": "ACT",
            "罗马书": "ROM", "哥林多前书": "1CO", "哥林多后书": "2CO", "加拉太书": "GAL", "以弗所书": "EPH",
            "腓立比书": "PHP", "歌罗西书": "COL", "帖撒罗尼迦前书": "1TH", "帖撒罗尼迦后书": "2TH",
            "提摩太前书": "1TI", "提摩太后书": "2TI", "提多书": "TIT", "腓利门书": "PHM", "希伯来书": "HEB",
            "雅各书": "JAS", "彼得前书": "1PE", "彼得后书": "2PE", "约翰一书": "1JN", "约翰二书": "2JN",
            "约翰三书": "3JN", "犹大书": "JUD", "启示录": "REV",
            "玛喀比传上": "1_Maccabees", "玛喀比传下": "2_Maccabees", "多比传": "Tobit",
            "犹滴传": "Judith", "便西拉智训": "Sirach", "所罗门智训": "Wisdom",
            "以斯拉续篇上": "1_Esdras", "以斯拉续篇下": "2_Esdras", "巴录书": "Baruch",
            "耶利米书信": "Letter_Jeremiah", "玛拿西祷言": "Pr_Manasseh", "三童歌": "Song_Three",
            "苏撒拿传": "Susanna", "比勒与大龙": "Bel_Dragon", "以斯帖补编": "Esther_Add"
        ]
        
        // 依序寫入字典，如果簡體有與繁體重複的書名（如箴言），將會自動覆蓋而不會報錯
        for (key, value) in traditional { map[key] = value }
        for (key, value) in simplified { map[key] = value }
        
        return map
    }()
    
    // MARK: - 對外接口
    
    func fetchFullChapter(version: String, book: String, chapter: Int) -> [(heading: String?, content: String)] {
        // 先將中文書卷名轉換為代碼 (如 "GEN")
        guard let bookCode = bookMapping[book] ?? bookMapping.first(where: { $0.value == book })?.value else {
            print("❌ [BibleJSON] BibleView 未找到書卷映射: '\(book)'")
            return []
        }
        
        let prefix = version == "SSEB" ? "sseb_" : ""
        // 🌟 永遠讀取繁體原檔，不加 _zh-Hans
        let resourceName = "\(prefix)\(bookCode)_\(chapter)"
        
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let chapterData = try? JSONDecoder().decode(ChapterJSON.self, from: data) else {
            print("❌ [BibleJSON] BibleView 找不到檔案: \(resourceName).json")
            return []
        }
        
        let allVerseKeys = chapterData.verses.keys.compactMap { Int($0) }.sorted()
        guard !allVerseKeys.isEmpty else { return [] }
        
        var paragraphs: [(heading: String?, content: String)] = []
        var currentHeading: String? = nil
        var currentContent = ""
        
        let starts = chapterData.paragraph_starts ?? []
        
        for verseNum in allVerseKeys {
            let verseStr = String(verseNum)
            let isParagraphStart = starts.contains(verseNum) || verseNum == allVerseKeys.first
            let hasHeading = chapterData.headings?[verseStr] != nil
            
            // 如果遇到新段落或新標題，就將前面的內容打包存入
            if isParagraphStart || hasHeading {
                if !currentContent.isEmpty {
                    paragraphs.append((heading: currentHeading, content: currentContent))
                    currentContent = ""
                    currentHeading = nil
                }
            }
            
            if let heading = chapterData.headings?[verseStr] {
                currentHeading = heading
            }
            
            if let text = chapterData.verses[verseStr] {
                if !currentContent.isEmpty { currentContent += " " }
                currentContent += "\(verseNum) \(text)"
            }
        }
        
        if !currentContent.isEmpty {
            paragraphs.append((heading: currentHeading, content: currentContent))
        }
        
        return paragraphs
    }
    
    
    // MARK: - 清理快取 (語言切換時必須呼叫)
        func clearCache() {
            cache.removeAllObjects()
        }
        
        // MARK: - 給早晚禱經課使用的陣列讀取 (支援繁簡與版本)
        func fetchVersesList(version: String, book: String, reference: String) -> [String] {
            let normalizedChapter = reference
                .replacingOccurrences(of: "\u{2013}", with: "-")
                .replacingOccurrences(of: "\u{2014}", with: "-")
                .replacingOccurrences(of: "\u{2010}", with: "-")
                .replacingOccurrences(of: "\u{2212}", with: "-")
            
            guard let bookCode = bookMapping[book] ?? bookMapping.first(where: { $0.value == book })?.value else {
                return []
            }
            
            let segments = parseSegments(normalizedChapter)
            var allTexts: [String] = []
            
            for segment in segments {
                guard let chapterData = loadChapterJSON(version: version, bookCode: bookCode, chapter: segment.chapter) else {
                    continue
                }
                let verses = extractVerses(from: chapterData, range: segment.verseRange)
                allTexts.append(contentsOf: verses)
            }
            return allTexts
        }
        
        /// 讀取指定經課引用的經文，整合為一段純文本（含節號）
        func fetchScripture(book: String, chapter: String) -> String? {
            let version = UserDefaults.standard.string(forKey: "bibleVersion") ?? "CUV"
            let verses = fetchVersesList(version: version, book: book, reference: chapter)
            return verses.isEmpty ? nil : verses.joined(separator: " ")
        }

        // MARK: - 私有：JSON 加載 (🌟 必須接收 version 參數，以正確載入 APO1933 或 SSEB)
        private func loadChapterJSON(version: String, bookCode: String, chapter: Int) -> ChapterJSON? {
            let lang = MorningPrayerDataLoader.shared.currentLanguage
            
            let cacheKey = "\(version)_\(bookCode)_\(chapter)_\(lang.rawValue)" as NSString
            if let cached = cache.object(forKey: cacheKey) { return cached }
            
            let prefix = version == "SSEB" ? "sseb_" : ""
            var resourceName = "\(prefix)\(bookCode)_\(chapter)"
            
            // 🌟 簡體中文後綴
            if lang == .simplified {
                resourceName += "_zh-Hans"
            }
            
            var url = Bundle.main.url(forResource: resourceName, withExtension: "json")
            if url == nil {
                let fallbackName = "\(prefix)\(bookCode)_\(chapter)"
                url = Bundle.main.url(forResource: fallbackName, withExtension: "json")
            }
            
            guard let finalURL = url, let data = try? Data(contentsOf: finalURL) else {
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
    
    private func parseSegments(_ chapterString: String) -> [ChapterSegment] {
        let normalizedInput = chapterString
            .replacingOccurrences(of: "，", with: "、")
            .replacingOccurrences(of: "(", with: "、")
            .replacingOccurrences(of: ")", with: "")
        let majorParts = normalizedInput.components(separatedBy: "、")
        
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
                segments.append(ChapterSegment(chapter: ch, verseRange: vr))
            } else if let ch = Int(normalized) {
                currentChapter = ch
                segments.append(ChapterSegment(chapter: ch, verseRange: nil))
            }
        }
        
        return segments
    }
    
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
            
            let endVerseStr = endSubParts[1].trimmingCharacters(in: .whitespaces)
            let endVerse: Int
            if endVerseStr.lowercased() == "end" {
                endVerse = 999
            } else {
                guard let ev = Int(endVerseStr) else { continue }
                endVerse = ev
            }
            
            guard endChapter > startChapter else { continue }

            var crossSegments: [ChapterSegment] = [
                ChapterSegment(chapter: startChapter, verseRange: VerseRange(start: startVerse, end: 999))
            ]
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
                end = 999
            } else {
                guard let e = Int(endStr) else { return nil }
                end = e
            }
        } else {
            end = expandSingleVerseToChapterEnd ? 999 : start
        }
        
        return VerseRange(start: start, end: end)
    }
}

// MARK: - 內部模型

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
    let verseRange: VerseRange?
}
