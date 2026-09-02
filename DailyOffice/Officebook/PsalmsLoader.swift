import Foundation

// MARK: - 詩篇循環索引
struct PsalmCycle: Codable {
    let morning: [String: [String]]
    let evening: [String: [String]]
}

// MARK: - 🌟 詩篇多語言資料模型 (增強容錯版)
struct PsalmDBEntry: Codable {
    // 全面改為可選型別 (Optional)，防止單一欄位缺失導致整個 JSON 解析失敗
    let titleNum: LocalizedText?
    let latin: String?
    let antiphon: LocalizedText?
    let verses: [LocalizedText]
    
    enum CodingKeys: String, CodingKey {
        case titleNum = "title_num"
        case latin
        case antiphon
        case verses
    }
}

// 支援多語言字串解析 (增強容錯版)
struct LocalizedText: Codable {
    let zhHant: String?
    let zhHans: String?
    let en: String?
    
    enum CodingKeys: String, CodingKey {
        case zhHant = "zh-hant"
        case zhHans = "zh-hans"
        case en
    }
    
    // 根據當前設定的語言回傳對應的字串，若缺失則回傳空字串防崩潰
    func text(for language: AppLanguage) -> String {
        switch language {
        case .traditional: return zhHant ?? ""
        case .simplified:  return zhHans ?? ""
        }
    }
}

// MARK: - 單篇詩篇內容 (供 UI 與外部呼叫使用的解析結果)
struct PsalmContent: Codable {
    let title: String
    let antiphon: String
    let verses: [String]
    let latinTitle: String
}

// MARK: - 詩篇載入器
struct PsalmsLoader {
    static let shared = PsalmsLoader()
    
    private let cycle: PsalmCycle
    private let db: [String: PsalmDBEntry]
    
    init() {
        // 1. 載入循環索引 (psalm_cycle.json)
        if let cycleURL = Bundle.main.url(forResource: "psalm_cycle", withExtension: "json"),
           let cycleData = try? Data(contentsOf: cycleURL),
           let cycleDecoded = try? JSONDecoder().decode(PsalmCycle.self, from: cycleData) {
            self.cycle = cycleDecoded
        } else {
            print("⚠️ 警告：無法載入 psalm_cycle.json")
            self.cycle = PsalmCycle(morning: [:], evening: [:])
        }
        
        // 2. 🌟 載入三語詩篇資料庫 (psalms_db.json)，加入除錯捕捉
        if let dbURL = Bundle.main.url(forResource: "psalms_db", withExtension: "json"),
           let dbData = try? Data(contentsOf: dbURL) {
            do {
                let decoded = try JSONDecoder().decode([String: PsalmDBEntry].self, from: dbData)
                self.db = decoded
            } catch {
                // 💡 如果未來還有錯，這裡會印出具體是哪個 Key 解析失敗
                print("❌ [詩篇] psalms_db.json 解析崩潰：\(error)")
                self.db = [:]
            }
        } else {
            print("⚠️ 警告：找不到 psalms_db.json 檔案")
            self.db = [:]
        }
    }
    
    // MARK: - 🌟 輔助：將 "詩篇 第1篇" 轉換為 JSON Key "1"
        private func extractPsalmKey(from formattedTitle: String) -> String {
            var key = formattedTitle.replacingOccurrences(of: "詩篇 第", with: "")
            key = key.replacingOccurrences(of: "篇", with: "")
            
            // 🌟 新增：專門處理詩篇 119 篇的格式，將 "119（41-48）" 轉換為 "119_41_48"
            key = key.replacingOccurrences(of: "（", with: "_") // 替換左全形括號
            key = key.replacingOccurrences(of: "）", with: "")  // 刪除右全形括號
            key = key.replacingOccurrences(of: "(", with: "_")  // 替換左半形括號 (防呆)
            key = key.replacingOccurrences(of: ")", with: "")   // 刪除右半形括號 (防呆)
            key = key.replacingOccurrences(of: "-", with: "_")  // 將橫槓替換為底線
            
            return key.trimmingCharacters(in: .whitespaces)
        }
    
    // MARK: - 核心：依據當前語言解析出單一語言的 PsalmContent
    private func resolveEntry(key: String) -> PsalmContent? {
        guard let entry = db[key] else {
            print("⚠️ [詩篇] 找不到資料庫 Key: \(key)")
            return nil
        }
        
        let lang = MorningPrayerDataLoader.shared.currentLanguage
        return PsalmContent(
            title: entry.titleNum?.text(for: lang) ?? key,
            antiphon: entry.antiphon?.text(for: lang) ?? "",
            verses: entry.verses.map { $0.text(for: lang) },
            latinTitle: entry.latin ?? ""
        )
    }
    
    // MARK: - 獲取早禱詩篇
    func morningPsalms(for date: Date) -> [(title: String, content: PsalmContent)] {
        let day = Calendar.current.component(.day, from: date)
        let key = day == 31 ? "30" : String(day)
        guard let titles = cycle.morning[key] else { return [] }
        
        return titles.compactMap { rawTitle in
            let dbKey = extractPsalmKey(from: rawTitle)
            guard let content = resolveEntry(key: dbKey) else { return nil }
            return (content.title, content)
        }
    }
    
    // MARK: - 獲取晚禱詩篇
    func eveningPsalms(for date: Date) -> [(title: String, content: PsalmContent)] {
        let day = Calendar.current.component(.day, from: date)
        let key = day == 31 ? "30" : String(day)
        guard let titles = cycle.evening[key] else { return [] }
        
        return titles.compactMap { rawTitle in
            let dbKey = extractPsalmKey(from: rawTitle)
            guard let content = resolveEntry(key: dbKey) else { return nil }
            return (content.title, content)
        }
    }
    
    // MARK: - 專用詩篇讀取
    func psalm(
        number: String,
        verses: String? = nil
    ) -> (title: String, content: PsalmContent)? {
        let normalizedNumber = normalizePsalmNumber(number)
        
        // 特殊處理：詩篇119篇分段存儲
        if normalizedNumber == "119",
           let verseRange = verses?.trimmingCharacters(in: .whitespacesAndNewlines),
           !verseRange.isEmpty {
            return psalm119(rangeText: verseRange)
        }
        
        guard let fullPsalm = psalmEntry(for: normalizedNumber) else {
            print("⚠️ [詩篇] 找不到專用詩篇 \(number)")
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
        
        let lang = MorningPrayerDataLoader.shared.currentLanguage
        let verseLabel = lang == .traditional ? "節" : "节"
        let title = "\(fullPsalm.title) \(verseRange)\(verseLabel)"
        
        let content = PsalmContent(
            title: title,
            antiphon: fullPsalm.content.antiphon,
            verses: selectedVerses,
            latinTitle: fullPsalm.content.latinTitle
        )
        
        return (title, content)
    }
    
    /// 直接讀取單篇詩篇內容（供一時禱等獨立模組使用）
    func psalmContent(for key: String) -> PsalmContent? {
        let dbKey = extractPsalmKey(from: key)
        return resolveEntry(key: dbKey)
    }
    
    // MARK: - 月度循環詩篇查詢（供 PsalmCycleView 使用）
    func cyclePsalms(for day: Int, isMorning: Bool) -> [(title: String, content: PsalmContent)] {
        let key = String(day)
        let titles = isMorning ? (cycle.morning[key] ?? []) : (cycle.evening[key] ?? [])
        
        return titles.compactMap { rawTitle in
            let dbKey = extractPsalmKey(from: rawTitle)
            guard let content = resolveEntry(key: dbKey) else { return nil }
            return (content.title, content)
        }
    }
    
    // MARK: - 內部輔助與分段處理
    private func psalmEntry(for normalizedNumber: String) -> (title: String, content: PsalmContent)? {
        if let content = resolveEntry(key: normalizedNumber) {
            return (content.title, content)
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
    
    // MARK: - 詩篇119篇分段處理
    private func psalm119(rangeText: String) -> (title: String, content: PsalmContent)? {
        let wantedNumbers = parseVerseRange(rangeText)
        guard !wantedNumbers.isEmpty else { return nil }
        
        let segments = stride(from: 1, to: 177, by: 8).map { start -> (key: String, start: Int, end: Int) in
            let end = min(start + 7, 176)
            // 🌟 配合資料庫，將 Key 格式改為 119_1_8
            let key = "119_\(start)_\(end)"
            return (key, start, end)
        }
        
        var mergedVerses: [String] = []
        var firstAntiphon: String = ""
        var firstLatinTitle: String = ""
        var foundAny = false
        
        for segment in segments {
            let segmentRange = Set(segment.start...segment.end)
            guard !segmentRange.isDisjoint(with: wantedNumbers) else { continue }
            
            guard let content = resolveEntry(key: segment.key) else {
                print("⚠️ [詩篇] 找不到 119篇分段: \(segment.key)")
                continue
            }
            
            if !foundAny {
                firstAntiphon = content.antiphon
                firstLatinTitle = content.latinTitle
                foundAny = true
            }
            
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
        
        let lang = MorningPrayerDataLoader.shared.currentLanguage
        let titleFormat = lang == .traditional ? "詩篇 第119篇 %@節" : "诗篇 第119篇 %@节"
        let title = String(format: titleFormat, rangeText)
        
        let content = PsalmContent(
            title: title,
            antiphon: firstAntiphon,
            verses: mergedVerses,
            latinTitle: firstLatinTitle
        )
        
        return (title, content)
    }
}
