import Foundation

// MARK: - 詩篇循環索引
struct PsalmCycle: Codable {
    let morning: [String: [String]]
    let evening: [String: [String]]
}

// MARK: - 單篇詩篇內容
struct PsalmContent: Codable {
    let antiphon: String
    let verses: [String]
    var latinTitle: String
    
    // ⬇️ 手動實現解碼，允許 latinTitle 缺失
    enum CodingKeys: String, CodingKey {
        case antiphon
        case verses
        case latinTitle
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.antiphon = try container.decode(String.self, forKey: .antiphon)
        self.verses = try container.decode([String].self, forKey: .verses)
        self.latinTitle = try container.decodeIfPresent(String.self, forKey: .latinTitle) ?? ""
    }
    
    init(antiphon: String, verses: [String], latinTitle: String = "") {
        self.antiphon = antiphon
        self.verses = verses
        self.latinTitle = latinTitle
    }
}

// MARK: - 詩篇載入器
struct PsalmsLoader {
    static let shared = PsalmsLoader()
    private let cycle: PsalmCycle
    private let contents: [String: PsalmContent]
    
    init() {
        // 載入循環索引
        if let cycleURL = Bundle.main.url(forResource: "psalm_cycle", withExtension: "json"),
           let cycleData = try? Data(contentsOf: cycleURL),
           let cycleDecoded = try? JSONDecoder().decode(PsalmCycle.self, from: cycleData) {
            self.cycle = cycleDecoded
        } else {
            print("⚠️ 警告：無法載入 psalm_cycle.json")
            self.cycle = PsalmCycle(morning: [:], evening: [:])
        }
        
        // 載入詩篇內容
        var contentDecoded: [String: PsalmContent] = [:]
        if let contentURL = Bundle.main.url(forResource: "psalms", withExtension: "json"),
           let contentData = try? Data(contentsOf: contentURL),
           let decoded = try? JSONDecoder().decode([String: PsalmContent].self, from: contentData) {
            contentDecoded = decoded
        } else {
            print("⚠️ 警告：無法載入 psalms.json")
        }
        
        // ⬇️ 載入拉丁文標題並注入
        if let latinURL = Bundle.main.url(forResource: "psalm_latin_titles", withExtension: "json"),
           let latinData = try? Data(contentsOf: latinURL),
           let latinDict = try? JSONDecoder().decode([String: String].self, from: latinData) {
            for (key, latin) in latinDict {
                if var content = contentDecoded[key] {
                    content.latinTitle = latin
                    contentDecoded[key] = content
                }
            }
        } else {
            print("⚠️ 警告：無法載入 psalm_latin_titles.json")
        }
        
        self.contents = contentDecoded
    }
    
    func morningPsalms(for date: Date) -> [(title: String, content: PsalmContent)] {
        let day = Calendar.current.component(.day, from: date)
        let key = day == 31 ? "30" : String(day)
        guard let titles = cycle.morning[key] else { return [] }
        return titles.compactMap { title in
            guard let content = contents[title] else { return nil }
            return (title, content)
        }
    }
    // 獲取晚禱詩篇
    func eveningPsalms(for date: Date) -> [(title: String, content: PsalmContent)] {
        let day = Calendar.current.component(.day, from: date)
        // 日期為31日時，使用第30日的詩篇
        let key = day == 31 ? "30" : String(day)
        guard let titles = cycle.evening[key] else { return [] }
        return titles.compactMap { title in
            guard let content = contents[title] else { return nil }
            return (title, content)
        }
    }
    /// 按詩篇篇號讀取整篇或指定節段。
    ///
    /// 用於 JSON 專用詩篇，例如：
    /// - { "number": "46" }              → 詩篇46整篇
    /// - { "number": "119", "verses": "1-16" } → 詩篇119篇1-16節
    func psalm(
        number: String,
        verses: String? = nil
    ) -> (title: String, content: PsalmContent)? {
        let normalizedNumber = normalizePsalmNumber(number)
        
        // ═══════════════════════════════════════════════════════
        // 特殊處理：詩篇119篇在 psalms.json 中分段存儲
        // ═══════════════════════════════════════════════════════
        if normalizedNumber == "119",
           let verseRange = verses?.trimmingCharacters(in: .whitespacesAndNewlines),
           !verseRange.isEmpty {
            return psalm119(rangeText: verseRange)
        }
        
        guard let fullPsalm = psalmEntry(for: normalizedNumber) else {
            print("⚠️ [詩篇] 找不到詩篇 \(number)")
            return nil
        }
        
        guard let verseRange = verses?.trimmingCharacters(in: .whitespacesAndNewlines),
              !verseRange.isEmpty else {
            return fullPsalm
        }
        
        let selectedVerses = filterPsalmVerses(
            fullPsalm.content.verses,
            rangeText: verseRange
        )
        
        guard !selectedVerses.isEmpty else {
            print("⚠️ [詩篇] 詩篇 \(normalizedNumber):\(verseRange) 無可用節段")
            return nil
        }
        
        let title = "\(fullPsalm.title) \(verseRange)節"
        let content = PsalmContent(
            antiphon: fullPsalm.content.antiphon,
            verses: selectedVerses,
            latinTitle: fullPsalm.content.latinTitle
        )
        
        return (title, content)
    }
    
    /// 直接讀取單篇詩篇內容（供一時禱等獨立模組使用）
    func psalmContent(for key: String) -> PsalmContent? {
        contents[key]
    }
    
    // MARK: - 專用詩篇節段輔助
    
    private func psalmEntry(for normalizedNumber: String) -> (title: String, content: PsalmContent)? {
        let candidates = [
            normalizedNumber,
            "詩篇\(normalizedNumber)",
            "詩篇第\(normalizedNumber)篇",
            "第\(normalizedNumber)篇",
            "Psalm \(normalizedNumber)",
            "Psalm\(normalizedNumber)"
        ]
        
        for key in candidates {
            if let content = contents[key] {
                return (key, content)
            }
        }
        
        // 若 psalms.json 的 key 使用其他顯示格式，則以 key 中的第一組數字比對。
        for (key, content) in contents {
            if normalizePsalmNumber(key) == normalizedNumber {
                return (key, content)
            }
        }
        
        return nil
    }
    
    private func normalizePsalmNumber(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var digits = ""
        var hasStarted = false
        
        for char in trimmed {
            if char.isNumber {
                digits.append(char)
                hasStarted = true
            } else if hasStarted {
                break
            }
        }
        
        return digits.isEmpty ? trimmed : digits
    }
    
    private func filterPsalmVerses(
        _ allVerses: [String],
        rangeText: String
    ) -> [String] {
        let wantedNumbers = parseVerseRange(rangeText)
        
        guard !wantedNumbers.isEmpty else {
            return allVerses
        }
        
        return allVerses.filter { verse in
            guard let verseNumber = extractVerseNumber(from: verse) else {
                return false
            }
            return wantedNumbers.contains(verseNumber)
        }
    }
    
    private func parseVerseRange(_ text: String) -> Set<Int> {
        var result = Set<Int>()
        
        let normalized = text
            .replacingOccurrences(of: "，", with: ",")
            .replacingOccurrences(of: "、", with: ",")
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
        
        let parts = normalized
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        for part in parts {
            if part.contains("-") {
                let bounds = part.split(separator: "-")
                guard bounds.count == 2,
                      let start = Int(bounds[0].trimmingCharacters(in: .whitespacesAndNewlines)),
                      let end = Int(bounds[1].trimmingCharacters(in: .whitespacesAndNewlines)) else {
                    continue
                }
                
                if start <= end {
                    for n in start...end {
                        result.insert(n)
                    }
                }
            } else if let n = Int(part) {
                result.insert(n)
            }
        }
        
        return result
    }
    
    private func extractVerseNumber(from verse: String) -> Int? {
        let trimmed = verse.trimmingCharacters(in: .whitespacesAndNewlines)
        var digits = ""
        
        for char in trimmed {
            if char.isNumber {
                digits.append(char)
            } else {
                break
            }
        }
        
        return Int(digits)
    }
    
    // MARK: - 月度循環詩篇查詢（供 PsalmCycleView 使用）
    func cyclePsalms(for day: Int, isMorning: Bool) -> [(title: String, content: PsalmContent)] {
        let key = String(day)
        let titles = isMorning ? (cycle.morning[key] ?? []) : (cycle.evening[key] ?? [])
        return titles.compactMap { title in
            contents[title].map { (title, $0) }
        }
    }
    
    // MARK: - 詩篇119篇分段處理
    
    /// 詩篇119篇在 psalms.json 中按每8節分段存儲：
    /// 詩篇 第119篇（1-8）、（9-16）...（169-176）
    /// 此方法將請求的範圍（如 "33-48"）映射到對應分段，合併後返回。
    private func psalm119(rangeText: String) -> (title: String, content: PsalmContent)? {
        let wantedNumbers = parseVerseRange(rangeText)
        guard !wantedNumbers.isEmpty else { return nil }
        
        // 119篇共22段，每段8節：(1-8), (9-16), ..., (169-176)
        let segments = stride(from: 1, to: 177, by: 8).map { start -> (key: String, start: Int, end: Int) in
            let end = min(start + 7, 176)
            let key = "詩篇 第119篇（\(start)-\(end)）"
            return (key, start, end)
        }
        
        var mergedVerses: [String] = []
        var firstAntiphon: String = ""
        var firstLatinTitle: String = ""
        var foundAny = false
        
        for segment in segments {
            // 檢查此分段是否與請求範圍有重疊
            let segmentRange = Set(segment.start...segment.end)
            guard !segmentRange.isDisjoint(with: wantedNumbers) else { continue }
            
            guard let content = contents[segment.key] else {
                print("⚠️ [詩篇] 找不到 \(segment.key)")
                continue
            }
            
            if !foundAny {
                firstAntiphon = content.antiphon
                firstLatinTitle = content.latinTitle
                foundAny = true
            }
            
            // 只取此分段中符合請求範圍的節
            let filtered = content.verses.filter { verse in
                guard let num = extractVerseNumber(from: verse) else { return false }
                return wantedNumbers.contains(num)
            }
            mergedVerses.append(contentsOf: filtered)
        }
        
        guard !mergedVerses.isEmpty else {
            print("⚠️ [詩篇] 詩篇119:\(rangeText) 無可用節段")
            return nil
        }
        
        let title = "詩篇 第119篇 \(rangeText)節"
        let content = PsalmContent(
            antiphon: firstAntiphon,
            verses: mergedVerses,
            latinTitle: firstLatinTitle
        )
        
        return (title, content)
    }
}
