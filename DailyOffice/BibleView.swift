import SwiftUI

// MARK: - 預計算後的展示結構
private struct PrecomputedParagraph: Identifiable {
    let id = UUID()
    let heading: String?
    let content: AttributedString
}

struct BibleView: View {
    // 💡 記憶位置：預設版本改為 CUV，避免找不到已刪除的 RCUV
    @AppStorage("lastReadBibleVersion") private var selectedVersion = "CUV"
    @AppStorage("lastReadBibleBook") private var selectedBook = "GEN"
    @AppStorage("lastReadBibleChapter") private var selectedChapter = 1
    
    // 🌟 狀態變數
    @State private var precomputedTexts: [PrecomputedParagraph] = []
    @State private var isHeaderHidden: Bool = false
    @State private var lastScrollOffset: CGFloat = 0
    @State private var currentTaskID = UUID()
    
    // 🌟 靜態正則，避免每次滾動重建
    private static let verseRegex = try! NSRegularExpression(pattern: #"\d+\s"#)

    // --- 📚 目錄定義 ---

    // 1. 正典 (66 卷) - 用於 CUV 與 SSEB
    let canonicalBooks = [
        ("創世記", "GEN", 50), ("出埃及記", "EXO", 40), ("利未記", "LEV", 27), ("民數記", "NUM", 36), ("申命記", "DEU", 34),
        ("約書亞記", "JOS", 24), ("士師記", "JDG", 21), ("路得記", "RUT", 4), ("撒母耳記上", "1SA", 31), ("撒母耳記下", "2SA", 24),
        ("列王紀上", "1KI", 22), ("列王紀下", "2KI", 25), ("歷代志上", "1CH", 29), ("歷代志下", "2CH", 36), ("以斯拉記", "EZR", 10),
        ("尼希米記", "NEH", 13), ("以斯帖記", "EST", 10), ("約伯記", "JOB", 42), ("詩篇", "PSA", 150), ("箴言", "PRO", 31),
        ("傳道書", "ECC", 12), ("雅歌", "SNG", 8), ("以賽亞書", "ISA", 66), ("耶利米書", "JER", 52), ("耶利米哀歌", "LAM", 5),
        ("以西結書", "EZK", 48), ("但以理書", "DAN", 12), ("何西阿書", "HOS", 14), ("約珥書", "JOL", 3), ("阿摩司書", "AMO", 9),
        ("俄巴底亞書", "OBA", 1), ("約拿書", "JON", 4), ("彌迦書", "MIC", 7), ("那鴻書", "NAM", 3), ("哈巴谷書", "HAB", 3),
        ("西番雅書", "ZEP", 3), ("哈該書", "HAG", 2), ("撒迦利亞書", "ZEC", 14), ("瑪拉基書", "MAL", 4),
        ("馬太福音", "MAT", 28), ("馬可福音", "MRK", 16), ("路加福音", "LUK", 24), ("約翰福音", "JHN", 21), ("使徒行傳", "ACT", 28),
        ("羅馬書", "ROM", 16), ("哥林多前書", "1CO", 16), ("哥林多後書", "2CO", 13), ("加拉太書", "GAL", 6), ("以弗所書", "EPH", 6),
        ("腓立比書", "PHP", 4), ("歌羅西書", "COL", 4), ("帖撒羅尼迦前書", "1TH", 5), ("帖撒羅尼迦後書", "2TH", 3),
        ("提摩太前書", "1TI", 6), ("提摩太後書", "2TI", 4), ("提多書", "TIT", 3), ("腓利門書", "PHM", 1), ("希伯來書", "HEB", 13),
        ("雅各書", "JAS", 5), ("彼得前書", "1PE", 5), ("彼得後書", "2PE", 3), ("約翰一書", "1JN", 5), ("約翰二書", "2JN", 1),
        ("約翰三書", "3JN", 1), ("猶大書", "JUD", 1), ("啟示錄", "REV", 22)
    ]

    // 2. 次經 (15 卷) - 增加總章數
    let apocryphaBooks = [
        ("瑪喀比傳上", "1_Maccabees", 16), ("瑪喀比傳下", "2_Maccabees", 15), ("多比傳", "Tobit", 14),
        ("猶滴傳", "Judith", 16), ("便西拉智訓", "Sirach", 51), ("所羅門智訓", "Wisdom", 19),
        ("以斯拉續篇上", "1_Esdras", 9), ("以斯拉續篇下", "2_Esdras", 16), ("巴錄書", "Baruch", 6),
        ("耶利米書信", "Letter_Jeremiah", 1), ("瑪拿西禱言", "Pr_Manasseh", 1), ("三童歌", "Song_Three", 1),
        ("蘇撒拿傳", "Susanna", 1), ("比勒與大龍", "Bel_Dragon", 1), ("以斯帖記補編", "Esther_Add", 6)
    ]
    
    // 💡 動態過濾目錄：SSEB 屬於正典目錄
    var filteredBooks: [(String, String, Int)] {
        if selectedVersion == "CUV" || selectedVersion == "SSEB" {
            return canonicalBooks
        } else {
            return apocryphaBooks
        }
    }
    
    // 獲取當前書卷的最大章數
    var currentMaxChapters: Int {
        filteredBooks.first(where: { $0.1 == selectedBook })?.2 ?? 1
    }
    
    var selectedBookName: String {
        filteredBooks.first(where: { $0.1 == selectedBook })?.0 ?? ""
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).minY
                    )
                }
                .frame(height: 0)
                
                LazyVStack(alignment: .leading, spacing: 18) {
                    if precomputedTexts.isEmpty {
                        Text("載入中或無資料...")
                            .foregroundColor(.gray)
                            .padding(.top, 100)
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(precomputedTexts) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                if let heading = item.heading, !heading.isEmpty {
                                    Text(heading)
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255))
                                        .padding(.top, 15)
                                }
                                
                                Text(item.content)
                                    .font(.system(size: 20))
                                    .lineSpacing(10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 55)
                .padding(.bottom, 20)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { handleScroll(currentOffset: $0) }
            
            headerView
                .offset(y: isHeaderHidden ? -120 : 0)
                .opacity(isHeaderHidden ? 0 : 1)
                .animation(.easeInOut(duration: 0.25), value: isHeaderHidden)
        }
        .navigationTitle("\(selectedBookName) 第 \(selectedChapter) 章")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedBook) { loadBibleData() }
        .onChange(of: selectedChapter) { loadBibleData() }
        .onAppear { loadBibleData() }
    }
    
    // MARK: - Header 視圖
    private var headerView: some View {
        HStack(spacing: 5) {
            // 版本選擇選單：移除了 RCUV 與 APO2014，加入了 SSEB
            Menu {
                Button("和合本 (CUV)") { handleVersionChange(to: "CUV") }
                Button("施約瑟譯本 (SSEB)") { handleVersionChange(to: "SSEB") }
                Divider()
                Button("次經1933 (APO1933)") { handleVersionChange(to: "APO1933") }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedVersion)
                    Image(systemName: "chevron.down").font(.caption2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // 書卷選擇
            Picker("書卷", selection: $selectedBook) {
                ForEach(filteredBooks, id: \.1) { name, code, _ in
                    Text(name).tag(code)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedBook) { _, _ in
                // 🌟 當切換書卷時，如果原本的章數超過了新書卷的上限，自動重置為最後一章或第一章
                if selectedChapter > currentMaxChapters {
                    selectedChapter = currentMaxChapters
                }
                // (註：如果想要切換書卷時永遠回到第1章，可以改成 selectedChapter = 1)
            }
            
            // 章節選擇 (🌟 使用動態的 currentMaxChapters，並刪除重複的 Picker)
            Picker("章節", selection: $selectedChapter) {
                ForEach(1...currentMaxChapters, id: \.self) { num in
                    Text("第\(num)章").tag(num)
                }
            }
            .pickerStyle(.menu)
        }
        .tint(Color(red: 181/255, green: 8/255, blue: 56/255))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.systemBackground).opacity(0.95))
        .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
    }
    
    // MARK: - 邏輯處理
    
    private func handleVersionChange(to newVer: String) {
        let wasApocrypha = selectedVersion.contains("APO")
        let isApocrypha = newVer.contains("APO")
        
        selectedVersion = newVer
        
        // 如果在正典與次經之間切換，自動重置書卷位置
        if wasApocrypha != isApocrypha {
            if isApocrypha {
                selectedBook = "Tobit"
            } else {
                selectedBook = "GEN"
            }
            selectedChapter = 1
        }
        loadBibleData()
    }

    private static func parseBibleContent(_ content: String) -> AttributedString {
        var attributedString = AttributedString()
        let nsString = content as NSString
        let matches = verseRegex.matches(in: content, range: NSRange(location: 0, length: nsString.length))
        
        var lastIdx = 0
        for match in matches {
            let textRange = NSRange(location: lastIdx, length: match.range.location - lastIdx)
            if textRange.length > 0 {
                attributedString += AttributedString(nsString.substring(with: textRange))
            }
            
            let verseNumWithSpace = nsString.substring(with: match.range)
            let verseNum = verseNumWithSpace.trimmingCharacters(in: .whitespaces)
            
            var verseAttr = AttributedString(verseNum)
            verseAttr.foregroundColor = .red
            verseAttr.font = .system(size: 13, weight: .bold)
            verseAttr.baselineOffset = 8
            
            attributedString += verseAttr
            attributedString += AttributedString(" ")
            lastIdx = match.range.location + match.range.length
        }
        
        if lastIdx < nsString.length {
            attributedString += AttributedString(nsString.substring(from: lastIdx))
        }
        return attributedString
    }

    private func handleScroll(currentOffset: CGFloat) {
        if currentOffset >= 0 {
            if isHeaderHidden { withAnimation(.easeInOut(duration: 0.2)) { isHeaderHidden = false } }
            return
        }
        let diff = currentOffset - lastScrollOffset
        if diff < -15 && !isHeaderHidden {
            withAnimation(.easeInOut(duration: 0.3)) { isHeaderHidden = true }
        } else if diff > 15 && isHeaderHidden {
            withAnimation(.easeInOut(duration: 0.3)) { isHeaderHidden = false }
        }
        lastScrollOffset = currentOffset
    }
    
    private func loadBibleData() {
        let taskID = UUID()
        currentTaskID = taskID
        
        precomputedTexts = []
        
        let rawParagraphs = BibleDatabaseManager.shared.fetchChapter(
            version: selectedVersion,
            book: selectedBook,
            chapter: selectedChapter
        )
        
        DispatchQueue.global(qos: .userInitiated).async { [taskID] in
            var computed: [PrecomputedParagraph] = []
            computed.reserveCapacity(rawParagraphs.count)
            
            for para in rawParagraphs {
                guard taskID == self.currentTaskID else { return }
                let parsed = Self.parseBibleContent(para.content)
                computed.append(PrecomputedParagraph(heading: para.heading, content: parsed))
            }
            
            DispatchQueue.main.async {
                guard taskID == self.currentTaskID else { return }
                self.precomputedTexts = computed
            }
        }
    }
}
