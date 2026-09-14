import SwiftUI
import Combine

// MARK: - 1. 資料模型 (對應 JSON 結構)
nonisolated struct FaithBookData: Codable, Sendable {
    let intro: String
    let chapters: [FaithChapterData]
}

nonisolated struct FaithChapterData: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let content: String
}

// MARK: - 2. JSON 載入管理器
class FaithDataManager: ObservableObject {
    @Published var bookData: FaithBookData?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    init() {
        loadData()
    }

    func loadData() {
        // 在背景執行緒載入，避免阻塞主執行緒
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = Bundle.main.url(forResource: "FaithAndPractice", withExtension: "json") else {
                DispatchQueue.main.async {
                    self.errorMessage = "找不到 FaithAndPractice.json 檔案"
                    self.isLoading = false
                }
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let decodedData = try JSONDecoder().decode(FaithBookData.self, from: data)
                
                DispatchQueue.main.async {
                    self.bookData = decodedData
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "解析 JSON 失敗：\(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - 3. 書籍主視圖（封面 + 目錄）
struct FaithAndPracticeView: View {
    @StateObject private var dataManager = FaithDataManager()
    
    private let anglicanRed = Color(red: 181/255, green: 8/255, blue: 56/255)

    // 全域監聽語言狀態
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    
    private var isSimp: Bool {
        appLanguageCode == AppLanguage.simplified.rawValue
    }

    var body: some View {
        Group {
            if dataManager.isLoading {
                ProgressView("載入中...")
            } else if let error = dataManager.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    Button("重試") {
                        dataManager.isLoading = true
                        dataManager.errorMessage = nil
                        dataManager.loadData()
                    }
                }
            } else if let book = dataManager.bookData {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // --- 標題 ---
                        VStack(alignment: .leading, spacing: 6) {
                            Text("安立甘公教會之信仰與實踐".adaptChinese(isSimplified: isSimp))
                                .font(.system(size: 24, weight: .bold))
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Anglican Catholic Faith and Practice")
                                .font(.system(size: 13, design: .serif))
                                .foregroundColor(.secondary)
                        }

                        // --- 版權 / 介紹 ---
                        Text(book.intro.adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 14))
                            .lineSpacing(5)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)

                        // --- 目錄 ---
                        Text("目錄".adaptChinese(isSimplified: isSimp))
                            .font(.headline)
                            .bold()

                        VStack(spacing: 0) {
                            ForEach(Array(book.chapters.enumerated()), id: \.element.id) { index, chapter in
                                NavigationLink(destination: FaithChapterDetailView(chapter: chapter)) {
                                    HStack(spacing: 12) {
                                        Text("\(index + 1)")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(anglicanRed)
                                            .frame(width: 26)
                                        Text(chapter.title.adaptChinese(isSimplified: isSimp))
                                            .font(.system(size: 16))
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(PlainButtonStyle())

                                if index < book.chapters.count - 1 {
                                    Divider().padding(.leading, 52)
                                }
                            }
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)

                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("信仰與實踐".adaptChinese(isSimplified: isSimp))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 4. 章節閱讀視圖
struct FaithChapterDetailView: View {
    let chapter: FaithChapterData
    private let anglicanRed = Color(red: 181/255, green: 8/255, blue: 56/255)

    // 全域監聽語言狀態
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    
    private var isSimp: Bool {
        appLanguageCode == AppLanguage.simplified.rawValue
    }

    // 腳註資料模型
    private struct Footnote: Identifiable {
        let id = UUID()
        let number: String
        let text: String
    }

    // 內容區塊（行或表格）
    private enum ContentBlock {
        case line(String)
        case table(rows: [[String]], hasHeader: Bool)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text(chapter.title.adaptChinese(isSimplified: isSimp))
                    .font(.system(size: 22, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 4)

                ForEach(Array(contentBlocks.enumerated()), id: \.offset) { _, block in
                    switch block {
                    case .line(let line):
                        lineView(line)
                    case .table(let rows, let hasHeader):
                        tableView(rows, hasHeader: hasHeader)
                    }
                }

                // 腳註區
                if !footnotes.isEmpty {
                    Divider().padding(.top, 14)
                    Text("註釋".adaptChinese(isSimplified: isSimp))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(anglicanRed)
                        .padding(.top, 6)
                    ForEach(footnotes) { fn in
                        HStack(alignment: .top, spacing: 8) {
                            Text(superscript(fn.number))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(anglicanRed)
                                .frame(minWidth: 18, alignment: .leading)
                            Text(md(fn.text.adaptChinese(isSimplified: isSimp)))
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(chapter.title.adaptChinese(isSimplified: isSimp))
        .navigationBarTitleDisplayMode(.inline)
    }

    // 文本解析邏輯保持不變
    private var allLines: [String] {
        chapter.content.components(separatedBy: "\n")
    }

    private var bodyLines: [String] {
        allLines.filter { raw in
            let line = raw.trimmingCharacters(in: .whitespaces)
            return !(line.hasPrefix("[^") && line.contains("]:"))
        }
    }

    private var contentBlocks: [ContentBlock] {
        var blocks: [ContentBlock] = []
        var tableBuffer: [String] = []

        func flushTable() {
            guard !tableBuffer.isEmpty else { return }
            let parsed = parseTable(tableBuffer)
            blocks.append(.table(rows: parsed.rows, hasHeader: parsed.hasHeader))
            tableBuffer.removeAll()
        }

        for raw in bodyLines {
            if raw.trimmingCharacters(in: .whitespaces).hasPrefix("|") {
                tableBuffer.append(raw)
            } else {
                flushTable()
                blocks.append(.line(raw))
            }
        }
        flushTable()
        return blocks
    }

    private func parseTable(_ lines: [String]) -> (rows: [[String]], hasHeader: Bool) {
        func cells(_ line: String) -> [String] {
            var t = line.trimmingCharacters(in: .whitespaces)
            if t.hasPrefix("|") { t.removeFirst() }
            if t.hasSuffix("|") { t.removeLast() }
            return t.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        func isSeparator(_ line: String) -> Bool {
            let c = cells(line)
            return !c.isEmpty && c.allSatisfy { cell in
                !cell.isEmpty && cell.allSatisfy { $0 == "-" || $0 == ":" }
            }
        }
        var rows: [[String]] = []
        var hasHeader = false
        for (i, line) in lines.enumerated() {
            if isSeparator(line) {
                if i == 1 { hasHeader = true }
                continue
            }
            rows.append(cells(line))
        }
        return (rows, hasHeader)
    }

    private var footnotes: [Footnote] {
        allLines.compactMap { raw -> Footnote? in
            let line = raw.trimmingCharacters(in: .whitespaces)
            guard line.hasPrefix("[^"), let close = line.range(of: "]:") else { return nil }
            let numStart = line.index(line.startIndex, offsetBy: 2)
            let number = String(line[numStart..<close.lowerBound])
            let text = String(line[close.upperBound...]).trimmingCharacters(in: .whitespaces)
            guard !number.isEmpty else { return nil }
            return Footnote(number: number, text: text)
        }
    }

    @ViewBuilder
    private func lineView(_ raw: String) -> some View {
        let line = raw.trimmingCharacters(in: .whitespaces)
        if line.isEmpty {
            Color.clear.frame(height: 2)
        } else if line.hasPrefix("### ") {
            Text(md(convertMarkers(String(line.dropFirst(4))).adaptChinese(isSimplified: isSimp)))
                .font(.system(size: 17, weight: .semibold))
                .padding(.top, 6)
        } else if line.hasPrefix("## ") {
            Text(md(convertMarkers(String(line.dropFirst(3))).adaptChinese(isSimplified: isSimp)))
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(anglicanRed)
                .padding(.top, 10)
        } else if line.hasPrefix("> ") {
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(anglicanRed.opacity(0.5))
                    .frame(width: 3)
                Text(md(convertMarkers(String(line.dropFirst(2))).adaptChinese(isSimplified: isSimp)))
                    .font(.system(size: 15))
                    .italic()
                    .foregroundColor(.secondary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)
        } else if line.hasPrefix("- ") {
            HStack(alignment: .top, spacing: 8) {
                Text("•").font(.system(size: 16))
                Text(md(convertMarkers(String(line.dropFirst(2))).adaptChinese(isSimplified: isSimp)))
                    .font(.system(size: 16))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else if line.hasPrefix("[註]") {
            Text("註釋".adaptChinese(isSimplified: isSimp))
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(anglicanRed)
                .padding(.top, 10)
        } else {
            Text(md(convertMarkers(line).adaptChinese(isSimplified: isSimp)))
                .font(.system(size: 16))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func tableView(_ rows: [[String]], hasHeader: Bool) -> some View {
        let columnCount = rows.map { $0.count }.max() ?? 0
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                    let isHeader = hasHeader && rowIndex == 0
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(0..<columnCount, id: \.self) { col in
                            let cell = col < row.count ? row[col] : ""
                            VStack(alignment: .leading, spacing: 3) {
                                ForEach(Array(splitBreaks(cell).enumerated()), id: \.offset) { _, ln in
                                    Text(md(convertMarkers(ln).adaptChinese(isSimplified: isSimp)))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .font(.system(size: 14, weight: isHeader ? .bold : .regular))
                            .foregroundColor(isHeader ? anglicanRed : .primary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(width: columnWidth(col, columnCount), alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(isHeader ? anglicanRed.opacity(0.08) : Color.clear)
                        }
                    }
                    if rowIndex < rows.count - 1 {
                        Divider()
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
            )
        }
        .padding(.vertical, 6)
    }

    private func columnWidth(_ col: Int, _ count: Int) -> CGFloat {
        if count <= 2 { return col == 0 ? 280 : 240 }
        if count == 3 { return col == 0 ? 160 : 110 }
        return col == 0 ? 150 : 92
    }

    private func splitBreaks(_ s: String) -> [String] {
        var result = s
        for token in ["<br/>", "<br />", "<br>"] {
            result = result.replacingOccurrences(of: token, with: "\n")
        }
        let parts = result.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
        return parts.isEmpty ? [s] : parts
    }

    private func convertMarkers(_ s: String) -> String {
        guard s.contains("[^") else { return s }
        var result = ""
        let chars = Array(s)
        var i = 0
        while i < chars.count {
            if chars[i] == "[", i + 1 < chars.count, chars[i + 1] == "^" {
                var j = i + 2
                var digits = ""
                while j < chars.count, chars[j].isNumber {
                    digits.append(chars[j])
                    j += 1
                }
                if !digits.isEmpty, j < chars.count, chars[j] == "]" {
                    result += superscript(digits)
                    i = j + 1
                    continue
                }
            }
            result.append(chars[i])
            i += 1
        }
        return result
    }

    private func superscript(_ s: String) -> String {
        let map: [Character: Character] = [
            "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴",
            "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹"
        ]
        return String(s.map { map[$0] ?? $0 })
    }

    private func md(_ s: String) -> AttributedString {
        (try? AttributedString(markdown: s)) ?? AttributedString(s)
    }
}
