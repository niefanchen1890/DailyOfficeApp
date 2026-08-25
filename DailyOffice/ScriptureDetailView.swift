import SwiftUI

struct ScriptureDetailView: View {
    let day: LectionaryDay
    
    @State private var selectedVersionCode: String = ""
    @State private var verses: [BibleVerse] = []
    @State private var isLoading = true
    
    // 預先緩存處理好的屬性字串
    @State private var formattedVerses: [String: AttributedString] = [:]
    
    private var versionOptions: [(name: String, code: String)] {
        let isApocrypha = LectionaryDatabaseManager.shared.isApocrypha(bookName: day.book)
        if isApocrypha {
            // 🌟 已刪除 APO2014，僅保留 APO1933
            return [("1933版", "APO1933")]
        } else {
            // 🌟 將 RCUV 替換為 SSEB
            return [("和合本", "CUV"), ("施約瑟譯本", "SSEB")]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // ⬛️ 頂部控制區
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .lastTextBaseline) {
                    Text(day.book)
                        .font(.system(.title, )).bold()
                    Text(day.chapter)
                        .font(.system(.title3, ))
                    Spacer()
                }
                
                Picker("版本", selection: $selectedVersionCode) {
                    ForEach(versionOptions, id: \.code) { option in
                        Text(option.name).tag(option.code)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 12)
            .background(Color(UIColor.systemBackground))
            
            Divider()

            // ⬜️ 經文內容區
            if isLoading {
                Spacer()
                ProgressView("正在開啟聖道...").frame(maxWidth: .infinity)
                Spacer()
            } else {
                List {
                    ForEach(verses) { verse in
                        if let attributedText = formattedVerses[verse.id] {
                            Text(attributedText)
                                .lineSpacing(8)
                                .padding(.vertical, 4)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                        }
                    }
                }
                .listStyle(.plain)
                .environment(\.defaultMinListRowHeight, 1)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedVersionCode.isEmpty {
                // 🌟 預設版本改為 SSEB
                selectedVersionCode = versionOptions.last?.code ?? "SSEB"
            }
            loadScripture()
        }
        .onChange(of: selectedVersionCode) { _, _ in
            loadScripture()
        }
    }

    private func loadScripture() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let fetched = LectionaryDatabaseManager.shared.fetchVerses(
                version: selectedVersionCode,
                book: day.book,
                reference: day.chapter
            )
            
            var tempCache: [String: AttributedString] = [:]
            for verse in fetched {
                tempCache[verse.id] = createAttributedString(from: verse.content)
            }
            
            DispatchQueue.main.async {
                self.verses = fetched
                self.formattedVerses = tempCache
                self.isLoading = false
            }
        }
    }
    
    private func createAttributedString(from rawText: String) -> AttributedString {
        var attrStr = AttributedString(rawText)
        attrStr.font = .system(size: 18, )
        
        if let regex = try? NSRegularExpression(pattern: "\\d+", options: []) {
            let range = NSRange(location: 0, length: rawText.utf16.count)
            let matches = regex.matches(in: rawText, options: [], range: range)
            
            for match in matches {
                if let rangeInAttr = Range(match.range, in: attrStr) {
                    attrStr[rangeInAttr].font = .system(size: 11, weight: .bold, )
                    attrStr[rangeInAttr].foregroundColor = Color(red: 181/255, green: 8/255, blue: 56/255)
                    attrStr[rangeInAttr].baselineOffset = 8
                }
            }
        }
        return attrStr
    }
}


func chineseNumber(_ number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    formatter.locale = Locale(identifier: "zh_Hant")
    let result = formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    
    // 針對公禱書習慣進行特殊替換
    return result
        .replacingOccurrences(of: "百", with: "百")
        .replacingOccurrences(of: "零", with: "〇")
}

extension Int {
    /// 方便直接在 Int 上呼叫 .chineseString
    var chineseString: String {
        return chineseNumber(self)
    }
}
