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

// MARK: - 月度誦讀詩篇主視圖
struct PsalmCycleView: View {
    @State private var cycleData: PsalmCycleData?
    @State private var selectedPeriod: PsalmReadingPeriod = .morning
    
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
        .navigationTitle("詩篇")
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
                Text("本日無分配")
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
                            
                            Text(psalmKey)
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
            Text("第 \(chineseNumber(day)) 日")
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

// MARK: - 單篇詩篇閱讀視圖
struct PsalmReadingView: View {
    let psalmKey: String
    
    /// 從 psalms.json 解碼完整內容（含對經）
    private struct FullPsalmEntry: Codable {
        let antiphon: String?
        let verses: [String]
    }
    
    @State private var latinTitle: String = ""
    @State private var antiphon: String?
    @State private var verses: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // ═════ 標題列（紅色中文標題 + 拉丁文）═════
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(psalmKey)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(LiturgyColors.crimson)
                    
                    if !latinTitle.isEmpty {
                        Text(latinTitle)
                            .font(.system(size: 16, weight: .regular))
                            .italic()
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom, 4)
                
                // ═════ 對經（若有）═════
                if let antiphon = antiphon, !antiphon.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("對經")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red)
                        
                        Text(antiphon)
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
                ForEach(verses.indices, id: \.self) { index in
                    PsalmVerseRow(verse: verses[index])
                }
                
                // ═════ 榮耀頌 ═════
                VStack(alignment: .leading, spacing: 4) {
                    Text("但願榮耀歸於聖父、聖子、聖靈；")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                    Text("※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                }
                .padding(.top, 12)
            }
            .padding()
        }
        .navigationTitle(psalmKey)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear(perform: loadPsalm)
    }
    
    // MARK: - 載入詩篇內容
    private func loadPsalm() {
        // 1. 從 PsalmsLoader 取得基本內容（verses & latinTitle）
        if let content = PsalmsLoader.shared.psalmContent(for: psalmKey) {
            self.latinTitle = content.latinTitle
            self.verses = content.verses
        }
        
        // 2. 從 psalms.json 補充解碼對經（若 PsalmsLoader 未提供 antiphon）
        if let url = Bundle.main.url(forResource: "psalms", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let dict = try? JSONDecoder().decode([String: FullPsalmEntry].self, from: data),
           let entry = dict[psalmKey] {
            self.antiphon = entry.antiphon
            // 後備：若 PsalmsLoader 未能提供 verses，則使用此處
            if verses.isEmpty {
                self.verses = entry.verses
            }
        }
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
