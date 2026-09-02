import SwiftUI

// MARK: - 月度誦讀詩篇資料模型（匹配 psalm_cycle.json）
struct PsalmCycleData: Codable {
    let morning: [String: [String]]
    let evening: [String: [String]]
    let note: String
}

// MARK: - 誦讀時段
enum PsalmReadingPeriod: String, CaseIterable {
    case morning = "早禱"
    case evening = "晚禱"
}

// MARK: - 🌟 第三步：月度誦讀詩篇主視圖 (目錄頁)
struct PsalmCycleView: View {
    @State private var cycleData: PsalmCycleData?
    @State private var selectedPeriod: PsalmReadingPeriod = .morning
    
    // 🌟 新增：監聽語言切換，讓目錄列表也能即時變更語言
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    
    var body: some View {
        List {
            // 頂端說明（含 31 日規則）
            if let note = cycleData?.note, !note.isEmpty {
                Section {
                    Text(note)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }
            
            // 1–30 日列表
            ForEach(1...30, id: \.self) { day in
                daySection(day: day)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(appLanguageCode == AppLanguage.traditional.rawValue ? "詩篇" : "诗篇")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("誦讀時段", selection: $selectedPeriod) {
                    ForEach(PsalmReadingPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
        }
        .onAppear(perform: loadData)
    }
    
    // MARK: - 單日區塊
    @ViewBuilder
    private func daySection(day: Int) -> some View {
        let key = String(day)
        let psalms: [String] = {
            guard let data = cycleData else { return [] }
            switch selectedPeriod {
            case .morning: return data.morning[key] ?? []
            case .evening: return data.evening[key] ?? []
            }
        }()
        
        Section {
            if psalms.isEmpty {
                Text(appLanguageCode == AppLanguage.traditional.rawValue ? "本日無分配" : "本日无分配")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
            } else {
                ForEach(psalms, id: \.self) { psalmKey in
                    NavigationLink(destination: PsalmReadingView(psalmKey: psalmKey)) {
                        HStack(spacing: 12) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 14))
                                .foregroundColor(LiturgyColors.crimson)
                                .frame(width: 24)
                            
                            // 🌟 關鍵修改：透過 Loader 獲取當前語言的標題，若無則降級顯示原始 Key
                            Text(PsalmsLoader.shared.psalmContent(for: psalmKey)?.title ?? psalmKey)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        } header: {
            Text(appLanguageCode == AppLanguage.traditional.rawValue ? "第 \(chineseNumber(day)) 日" : "第 \(chineseNumber(day)) 日")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(LiturgyColors.crimson)
        }
    }
    
    // MARK: - 載入 psalm_cycle.json
    private func loadData() {
        guard let url = Bundle.main.url(forResource: "psalm_cycle", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(PsalmCycleData.self, from: data) else {
            return
        }
        cycleData = decoded
    }
    
    // MARK: - 中文數字（1–30）
    private func chineseNumber(_ num: Int) -> String {
        let digits = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
        if num <= 10 { return digits[num] }
        if num < 20 { return "十" + digits[num % 10] }
        if num == 20 { return "二十" }
        if num < 30 { return "二十" + digits[num % 20] }
        return "三十"
    }
}

// MARK: - 🌟 第二步：單篇詩篇閱讀視圖 (內文頁)
struct PsalmReadingView: View {
    let psalmKey: String
    
    // 🌟 改為直接持有一個 PsalmContent 模型，刪除原本手動解碼 psalms.json 的代碼
    @State private var content: PsalmContent?
    
    // 🌟 新增：監聽語言切換，當用戶切換繁/簡時即時刷新內容
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let content = content {
                    // ═════ 標題列（雙語標題 + 拉丁文）═════
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(content.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(LiturgyColors.crimson)
                        
                        if !content.latinTitle.isEmpty {
                            Text(content.latinTitle)
                                .font(.system(size: 16, weight: .regular))
                                .italic()
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.bottom, 4)
                    
                    // ═════ 對經（若有）═════
                    if !content.antiphon.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appLanguageCode == AppLanguage.traditional.rawValue ? "對經" : "对经")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                            
                            Text(content.antiphon)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.primary)
                                .lineSpacing(6)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.red.opacity(0.06))
                        .cornerRadius(8)
                    }
                    
                    Divider()
                        .background(Color.secondary.opacity(0.2))
                    
                    // ═════ 詩節（紅色節號 + 正文）═════
                    ForEach(content.verses.indices, id: \.self) { index in
                        PsalmVerseRow(verse: content.verses[index])
                    }
                    
                    // ═════ 榮耀頌 ═════
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appLanguageCode == AppLanguage.traditional.rawValue ? "但願榮耀歸於聖父、聖子、聖靈；" : "但愿荣耀归于圣父、圣子、圣灵；")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                        Text(appLanguageCode == AppLanguage.traditional.rawValue ? "※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。" : "※起初怎样，现在以及永远，也是怎样，世世无尽。阿们。")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 12)
                } else {
                    // 載入中的佔位符
                    Text("載入中...")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
        }
        // 🌟 導航列標題也支援雙語
        .navigationTitle(content?.title ?? psalmKey)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear(perform: loadPsalm)
        // 🌟 關鍵：當語言設定改變時，重新讀取對應語言的內容
        .onChange(of: appLanguageCode) { _ in
            loadPsalm()
        }
    }
    
    // MARK: - 🌟 載入詩篇內容（大幅精簡）
    private func loadPsalm() {
        // 完全交給重構後的 PsalmsLoader 處理多語言轉換
        self.content = PsalmsLoader.shared.psalmContent(for: psalmKey)
    }
}

// MARK: - 詩節行（復用一時禱風格：紅色節號 + 正文）
struct PsalmVerseRow: View {
    let verse: String
    
    var body: some View {
        let trimmed = verse.trimmingCharacters(in: .whitespaces)
        let number = extractNumber()
        let text = number.isEmpty
            ? trimmed
            : String(trimmed.dropFirst(number.count)).trimmingCharacters(in: .whitespaces)
        
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if !number.isEmpty {
                Text(number)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.red)
            }
            Text(text)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.primary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 1)
    }
    
    private func extractNumber() -> String {
        var number = ""
        for char in verse.trimmingCharacters(in: .whitespaces) {
            if char.isNumber { number.append(char) } else { break }
        }
        return number
    }
}
