import SwiftUI
import Combine

struct PrimePrayerView: View {
    @StateObject private var viewModel: PrimePrayerViewModel
    let date: Date
    
    init(date: Date = Date()) {
        self.date = date
        let vm = PrimePrayerViewModel()
        vm.selectedDate = date
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    openingNoteSection
                    openingResponsesSection
                    hymnSection
                    psalmsSection
                    athanasianCreedSection
                    readingSection
                    shortResponsesSection
                    prayersSection
                    collectsSection
                    closingNoteSection
                    martyrologySection
                    commemorationSection
                    endingSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .padding(.bottom, 60)
            }
            .onAppear {
                viewModel.loadData()
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            dateQuickNavButtons
        }
        .navigationTitle("一時禱")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 結束說明（殉道錄前）
    private var closingNoteSection: some View {
        LiturgyCard {
            RubricBlock(text: "¶ 一時禱可由此結束，或加唸以下祈禱。")
        }
    }

    // MARK: - 日期導航
    private var dateQuickNavButtons: some View {
        HStack(spacing: 0) {
            Button(action: { viewModel.jumpToYesterday() }) {
                Text("昨日").font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            
            Divider().frame(height: 20).background(Color.white.opacity(0.3))
            
            Button(action: { viewModel.jumpToToday() }) {
                Text("今日").font(.system(size: 15, weight: .bold))
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            
            Divider().frame(height: 20).background(Color.white.opacity(0.3))
            
            Button(action: { viewModel.jumpToTomorrow() }) {
                Text("明日").font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
        }
        .background(Capsule().fill(LiturgyColors.crimson).shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2))
        .foregroundColor(.white)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - 標頭
    private var header: some View {
        let liturgy = viewModel.liturgy
        
        return VStack(spacing: 0) {
            Text(formattedFullDateWithWeekday(viewModel.selectedDate))
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(.secondary)
                .padding(.top, 12)
            
            Text(liturgy.mainTitle)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
            
            if let common = viewModel.commonName {
                Text(common)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(LiturgyColors.crimson)
                    .padding(.top, 6)
            }
            
            if !liturgy.rankName.isEmpty {
                Text("（\(liturgy.rankName)）")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(LiturgyColors.crimson)
                    .padding(.top, 4)
            }
            
            Divider()
                .background(Color.secondary.opacity(0.25))
                .padding(.horizontal, 60)
                .padding(.vertical, 20)
            
            Text("一  時  禱")
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(.primary)
                .tracking(12)
                .padding(.bottom, 4)
            
            if !liturgy.commemorations.isEmpty {
                Text("紀念：\(liturgy.commemorations.joined(separator: "、"))")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
    }
    
    private func formattedFullDateWithWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日 EEEE"
        f.locale = Locale(identifier: "zh_Hant_TW")
        return f.string(from: date)
    }
    
    // MARK: - 禮規說明
    private var openingNoteSection: some View {
        LiturgyCard {
            RubricBlock(text: PrimePrayerData.openingNote)
        }
    }
    
    // MARK: - 開始啟應
    private var openingResponsesSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(PrimePrayerData.openingResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }
    
    // MARK: - 聖詩（動態組裝節期結尾）
    private var hymnSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "聖詩")
                ForEach(viewModel.hymnVerses, id: \.self) { verse in
                    hymnVerseRow(verse)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)  // ← 加上這行
        }
    }
    
    // MARK: - 聖詩單節（紅色中文序號 + 懸掛縮進）
    private func hymnVerseRow(_ verse: String) -> some View {
        let prefix = extractChineseNumberPrefix(verse)
        let bodyText = String(verse.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
        let lines = bodyText.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        return HStack(alignment: .top, spacing: 0) {
            Text(prefix)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.red)
                .frame(width: 40, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                ForEach(lines.indices, id: \.self) { i in
                    Text(lines[i])
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: .leading)  // ← 加上這行
    }
    
    // MARK: - 提取中文數字序號（與早禱共用邏輯）
    private func extractChineseNumberPrefix(_ text: String) -> String {
        let chineseDigits = "一二三四五六七八九十"
        var prefix = ""
        for char in text {
            if chineseDigits.contains(char) {
                prefix.append(char)
            } else if char == "、" && !prefix.isEmpty {
                prefix.append(char)
                return prefix
            } else {
                break
            }
        }
        return prefix
    }
    
    private var psalmsSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "詩篇")
                RubricBlock(text: "¶ 然後當唸詩篇，以及適當的季節或瞻禮對經。詩篇119篇，可以週劃分，見標題下所標記。")
                
                // 季節對經（前）
                if let antiphon = viewModel.currentAntiphon {
                    RubricBlock(text: "¶ \(antiphon.season)對經：")
                    MorningPrayerView.AntiphonRow(text: antiphon.text)
                        .padding(.bottom, 4)
                }
                
                let weekday = Calendar.current.component(.weekday, from: viewModel.selectedDate)
                
                // 平日（禮拜一至六）顯示詩篇54篇
                if weekday != 1 {
                    if let psalm54 = PsalmsLoader.shared.psalmContent(for: PrimePrayerData.psalm54Key) {
                        psalmContentView(title: PrimePrayerData.psalm54Key, content: psalm54)
                    }
                    Divider().padding(.vertical, 8)
                }
                
                // 詩篇 119篇（當日分段組，主日顯示全部六段）
                let psalm119Keys = PrimePrayerData.psalm119Keys(for: viewModel.selectedDate)
                ForEach(psalm119Keys.indices, id: \.self) { index in
                    let key = psalm119Keys[index]
                    if let psalm119 = PsalmsLoader.shared.psalmContent(for: key) {
                        psalmContentView(title: key, content: psalm119)
                        if index < psalm119Keys.count - 1 {
                            Divider().padding(.vertical, 8)
                        }
                    }
                }
                if let antiphon = viewModel.currentAntiphon {
                    Divider().padding(.vertical, 4)
                    MorningPrayerView.AntiphonRow(text: viewModel.fullAntiphonText(for: antiphon))
                }
            }
        }
    }
    
    // MARK: - 單篇詩篇渲染（與早禱風格一致）
    private func psalmContentView(title: String, content: PsalmContent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 標題 + 拉丁文
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title)
                    .foregroundColor(LiturgyColors.crimson)
                if !content.latinTitle.isEmpty {
                    Text(content.latinTitle)
                        .italic()
                        .foregroundColor(.primary)
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .padding(.bottom, 4)
            
            // 詩節
            ForEach(content.verses, id: \.self) { verse in
                psalmVerseRow(verse)
            }
            
            // 榮耀頌
            VStack(alignment: .leading, spacing: 4) {
                BodyText("但願榮耀歸於聖父、聖子、聖靈；")
                BodyText("※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。")
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - 詩節行（紅色節號，※ 與正文同黑色）
    private func psalmVerseRow(_ verse: String) -> some View {
        let trimmed = verse.trimmingCharacters(in: .whitespaces)
        var number = ""
        for char in trimmed {
            if char.isNumber { number.append(char) } else { break }
        }
        let text = number.isEmpty
            ? trimmed
            : String(trimmed.dropFirst(number.count)).trimmingCharacters(in: .whitespaces)
        
        // ✅ 刪除 ※ 標紅，全文統一黑色
        var attrStr = AttributedString(text)
        attrStr.font = .system(size: 17, weight: .regular)
        attrStr.foregroundColor = .primary
        
        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            if !number.isEmpty {
                Text(number)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.red)
            }
            Text(attrStr)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - 亞他拿修信經（特定主日與聖日，可選顯示/省略）
    private var athanasianCreedSection: some View {
        Group {
            if viewModel.shouldShowAthanasianCreed {
                LiturgyCard {
                    VStack(alignment: .leading, spacing: 14) {
                        
                        // ═════ 標題列 + 顯示/省略切換 ═════
                        HStack(alignment: .center, spacing: 8) {
                            SectionTitle(text: PrimePrayerData.athanasianCreed.title!)
                            Spacer()
                            Toggle("顯示", isOn: $viewModel.showAthanasianCreed)
                                .toggleStyle(.switch)
                                .labelsHidden()
                                .tint(LiturgyColors.crimson)
                        }
                        
                        // ═════ 內容區域 ═════
                        if viewModel.showAthanasianCreed {
                            if let rubric = PrimePrayerData.athanasianCreed.rubric {
                                RubricBlock(text: rubric)
                            }
                            
                            // 正文 42 段（帶中文序號，懸掛縮進）
                            ForEach(0..<42, id: \.self) { index in
                                let prefix = numberToChinese(index + 1) + "、"
                                let text = PrimePrayerData.athanasianCreed.paragraphs[index]
                                
                                HStack(alignment: .top, spacing: 0) {
                                    Text(prefix)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.red)
                                        .frame(width: 52, alignment: .leading)
                                    Text(text)
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.vertical, 2)
                            }
                            
                            // 榮耀頌（第 43–44 段，無序號，居中）
                            VStack(alignment: .leading, spacing: 4) {
                                Text(PrimePrayerData.athanasianCreed.paragraphs[42])
                                Text(PrimePrayerData.athanasianCreed.paragraphs[43])
                            }
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                            
                        } else {
                            // 省略狀態
                            Text("（已省略亞他拿修信經）")
                                .font(.system(size: 15, weight: .regular))
                                .italic()
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 12)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 讀經（含節期選擇器）
    private var readingSection: some View {
        let reading = viewModel.currentReading
        
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "讀經")
                RubricBlock(text: "¶ 然後，按季節或日期唸以下聖經章節。")
                
                // ═════ 節期選擇器 ═════
                Picker("讀經選擇", selection: $viewModel.selectedReadingOption) {
                    ForEach(PrimeReadingOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
                
                if let r = reading {
                    RubricBlock(text: "¶ \(r.season)：")
                    BodyText(r.content)
                    
                    // 出處標紅
                    if !r.reference.isEmpty {
                        Text("（\(r.reference)）")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.top, 2)
                            .padding(.leading, 4)
                    }
                } else {
                    PlaceholderBlock(text: "按當日節期誦唸")
                }
                
                Divider().padding(.vertical, 4)
                
                RubricBlock(text: "¶ 聖經讀畢，會眾唸：")
                ResponsoryRow(response: Responsory(
                    leader: "",
                    people: "應：感謝上帝。"
                ))
            }
        }
    }
    
    // MARK: - 簡短啟應
    private var shortResponsesSection: some View {
        let set = viewModel.currentShortResponsorySet
        
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "簡短啟應")
                RubricBlock(text: viewModel.isEasterSeason ? "¶ 復活節期內" : "¶ 復活節期外")
                
                if let s = set {
                    RubricBlock(text: "¶ \(s.title)")
                    
                    ResponsoryRow(response: s.opening)
                        .padding(.top, 4)
                    
                    Divider().padding(.vertical, 4)
                    
                    ResponsoryRow(response: s.seasonal)
                    
                    Divider().padding(.vertical, 4)
                    
                    ForEach(s.common, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                }
            }
        }
    }
    
    // MARK: - 祈禱（含顯示/省略選擇器）
    private var prayersSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "祈禱")
                
                // ═════ 顯示/省略選擇器 ═════
                Picker("祈禱選擇", selection: $viewModel.selectedPrayerOption) {
                    ForEach(PrimePrayerOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
                
                // ═════ 內容或省略提示 ═════
                if viewModel.selectedPrayerOption == .show {
                    if let rubric = PrimePrayerData.prayersOpening.rubric {
                        RubricBlock(text: rubric)
                    }
                    
                    // 求主憐憫
                    Text("求主憐憫；\n求基督憐憫；\n求主憐憫。")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                    
                    // 主禱文（默念提示）
                    RubricBlock(text: "¶ 默念主禱文，然後出聲啟應：")
                    BodyText(PrimePrayerData.prayersOpening.paragraphs[1])
                    
                    Divider().padding(.vertical, 6)
                    
                    // ═════ 第一組啟應（前 3 組）═════
                    let responses1 = PrimePrayerData.prayersResponses1
                    ForEach(0..<min(3, responses1.count), id: \.self) { i in
                        ResponsoryRow(response: responses1[i])
                    }
                    
                    // ═════ 插入：使徒信經默念 + 啟應 ═════
                    RubricBlock(text: "¶ 默念「使徒信經」，然後出聲啟應：")
                    ResponsoryRow(response: Responsory(
                        leader: "啟：我信身體復活，",
                        people: "應：我信永生。阿們。"
                    ))
                    
                    // ═════ 第一組啟應（續：第 4 組起）═════
                    if responses1.count > 3 {
                        ForEach(3..<responses1.count, id: \.self) { i in
                            ResponsoryRow(response: responses1[i])
                        }
                    }
                    
                    Divider().padding(.vertical, 6)
                    
                    // 認罪文
                    if let rubric = PrimePrayerData.confession.rubric {
                        RubricBlock(text: rubric)
                    }
                    ForEach(PrimePrayerData.confession.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                    RubricBlock(text: PrimePrayerData.confessionNote)
                    
                    Divider().padding(.vertical, 6)
                    
                    // 赦罪文
                    if let rubric = PrimePrayerData.absolution.rubric {
                        RubricBlock(text: rubric)
                    }
                    ForEach(PrimePrayerData.absolution.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                    
                    Divider().padding(.vertical, 6)
                    
                    // 第二組啟應
                    ForEach(PrimePrayerData.prayersResponses2, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                } else {
                    // 省略狀態
                    Text("（本日為主日、慶節或八日慶期，省略此「祈禱」，直接誦唸祝文。）")
                        .font(.system(size: 15, weight: .regular))
                        .italic()
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
            }
        }
    }
    
    // MARK: - 祝文
    private var collectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(text: "祝文")
                    RubricBlock(text: "¶ 祈禱後，或省略祈禱，則簡短啟應後，直接唸下文。")
                    
                    // 祝文前啟應
                    ForEach(PrimePrayerData.collectOpening, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                    
                    Text("我們要禱告。")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                    
                    // 祝文選擇
                    Picker("祝文選擇", selection: $viewModel.selectedCollect) {
                        Text("第一式").tag(0)
                        Text("第二式").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 6)
                    
                    if viewModel.selectedCollect == 0 {
                        BodyText(PrimePrayerData.collect1.paragraphs[0])
                    } else {
                        if let rubric = PrimePrayerData.collect2.rubric {
                            RubricBlock(text: rubric)
                        }
                        BodyText(PrimePrayerData.collect2.paragraphs[0])
                    }
                }
            }
            
            // 結束啟應
            LiturgyCard {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(PrimePrayerData.collectEndingResponses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                }
            }
            
            // 結束經文
            // 結束經文
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    // 第一段：正常渲染
                    BodyText(PrimePrayerData.closingText.paragraphs[0])
                    
                    // 第二段：拆分正文與經文出處，出處標紅
                    if PrimePrayerData.closingText.paragraphs.count > 1 {
                        let text = PrimePrayerData.closingText.paragraphs[1]
                        
                        // 穩健查找末尾全角括號
                        if let openRange = text.range(of: "（", options: .backwards),
                           let closeRange = text.range(of: "）", options: .backwards),
                           openRange.lowerBound < closeRange.lowerBound {
                            
                            let content = String(text[..<openRange.lowerBound])
                            let reference = String(text[openRange.lowerBound...])
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(content)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text(reference)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.red)
                                    .padding(.top, 2)
                                    .padding(.leading, 4)
                            }
                        } else {
                            BodyText(text)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 殉道錄（預設顯示，紅色標題居中，內容由 JSON 載入）
    private var martyrologySection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // ═════ 紅色居中標題 ═════
                Text("殉道錄")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 2)
                
                if let rubric = PrimePrayerData.martyrology.rubric {
                    RubricBlock(text: rubric)
                }
                
                // ═════ 殉道錄條目：由 JSON 載入 ═════
                let entries = viewModel.martyrologyEntries
                if !entries.isEmpty {
                    ForEach(entries.indices, id: \.self) { i in
                        Text(entries[i])
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 2)
                    }
                }
                
                ForEach(PrimePrayerData.martyrology.responses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
                
                // ═════ 「願我們上帝之母聖馬利亞…」禱文：置於「敬主的虔誠人死亡」啟應之後 ═════
                ForEach(PrimePrayerData.martyrology.paragraphs, id: \.self) { p in
                    BodyText(p)
                }
                
                Divider().padding(.vertical, 6)
                
                // ═════ 殉道錄結束啟應（重複三遍）═════
                RubricBlock(text: "¶ 以下啓應重複三遍。")
                ForEach(PrimePrayerData.martyrologyClosing, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
                
                Divider().padding(.vertical, 6)
                
                // ═════ 求主憐憫（居中，非啟應格式）═════
                Text(PrimePrayerData.martyrologyKyrie)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                
                // 主禱文提示 + 全文
                RubricBlock(text: PrimePrayerData.martyrologyLordPrayerNote)
                
                Text(PrimePrayerData.martyrologyLordPrayerText)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.primary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 4)
                
                // ═════ 結束啟應 ═════
                ForEach(PrimePrayerData.martyrologyEndingResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
                
                Divider().padding(.vertical, 6)
                
                // 祝文
                Text("我們要禱告。")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                
                BodyText(PrimePrayerData.martyrologyCollect)
                
                Divider().padding(.vertical, 6)
                
                ResponsoryRow(response: PrimePrayerData.martyrologyFinalResponse)
            }
        }
    }
    
    // MARK: - 紀念亡者（可選）
    private var commemorationSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("紀念亡者")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 2)
                
                RubricBlock(text: "¶ 此紀念亡者，通常與「殉道錄」一起誦讀；也可以在一天之內的任何時辰祈禱中一起誦讀。")
                
                ResponsoryRow(response: PrimePrayerData.commemorationOpening)
                
                Divider().padding(.vertical, 6)
                
                // 詩篇130 — 從 psalms.json 動態載入
                if let psalm130 = PsalmsLoader.shared.psalmContent(for: "詩篇 第130篇") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("詩篇 130篇")
                                .foregroundColor(LiturgyColors.crimson)
                            if !psalm130.latinTitle.isEmpty {
                                Text(psalm130.latinTitle)
                                    .italic()
                                    .foregroundColor(.primary)
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.bottom, 4)

                        ForEach(psalm130.verses, id: \.self) { verse in
                            psalmVerseRow(verse)
                        }
                    }
                } else {
                    Text("（詩篇 130篇 載入失敗）")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                }
                
                Divider().padding(.vertical, 6)
                
                ForEach(PrimePrayerData.commemorationResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
                
                Divider().padding(.vertical, 6)
                
                BodyText(PrimePrayerData.commemorationPrayer.paragraphs[0])
                
                Divider().padding(.vertical, 6)
                
                ForEach(PrimePrayerData.commemorationClosing, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }
    
    // MARK: - 結尾
    private var endingSection: some View {
        VStack(spacing: 0) {
            Text("❦ 一時禱至此結束。")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)

            Spacer().frame(height: 32)
        }
    }
}

// MARK: - 視圖模型
class PrimePrayerViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedCollect: Int = 0
    @Published var showAthanasianCreed: Bool = true
    @Published var selectedReadingOption: PrimeReadingOption = .ordinary
    @Published var selectedPrayerOption: PrimePrayerOption = .show
    /// 當日殉道錄條目（由 JSON 載入，空陣列則後退到內建資料）
    var martyrologyEntries: [String] {
        MartyrologyLoader.shared.entries(for: selectedDate)
    }

    /// 是否應顯示亞他拿修信經
    /// 對應中文標題：顯現期第一主日…第六主日、三一主日後第一主日…第二十六主日、降臨前主日
    var shouldShowAthanasianCreed: Bool {
        // 1. 原有固定聖日與移動節日（救主聖誕、復活、升天、聖靈降臨、三一主日等）
        if PrimePrayerData.shouldShowAthanasianCreed(for: selectedDate) {
            return true
        }
        
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        let title = liturgy.mainTitle
        
        // 2. 顯現期第 1–6 主日（對應：顯現期第一主日 … 顯現期第六主日）
        if info.season == .epiphany && info.weekday == 1 && (1...6).contains(info.weekNumber) {
            return true
        }
        
        // 3. 三一節期第 1–26 主日（對應：三一主日後第一主日 … 三一主日後第二十六主日）
        if info.season == .trinity && info.weekday == 1 && (1...26).contains(info.weekNumber) {
            return true
        }
        
        // 4. 降臨前主日
        if title == "降臨前主日" {
            return true
        }
        
        return false
    }
    
    var liturgy: DailyLiturgy {
        LiturgyCoreService.shared.resolve(for: selectedDate)
    }
    
    var commonName: String? {
        let map: [String: String] = [
            "復活後第五主日": "特禱主日",
            "復活後第一主日": "卸白衣主日"
        ]
        return map[liturgy.mainTitle]
    }
    
    /// 是否為復活期（含升天期、聖靈降臨期）
    var isEasterSeason: Bool {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        return [.easter, .ascension, .pentecost].contains(info.season)
    }
    
    /// 是否應顯示祈禱部分（平日顯示，主日/慶節/特等一等二等八日慶期省略）
    var shouldShowPrayers: Bool {
        let rank = liturgy.rank
        // 主日類型
        let sundayRanks: [LiturgicalRank] = [.sundayFirstClassGreat, .sundayFirstClass, .sundaySecondClass, .ordinarySunday]
        if sundayRanks.contains(rank) { return false }
        
        // 高級慶節
        let feastRanks: [LiturgicalRank] = [.doubleFirstClass, .doubleSecondClass, .greaterDouble, .double, .semiDouble]
        if feastRanks.contains(rank) { return false }
        
        // 特等/一等/二等八日慶期
        let octaveRanks: [LiturgicalRank] = [
            .privilegedOctaveFirstClass, .privilegedOctaveSecondClass,
            .privilegedOctaveSecondClassGreat, .privilegedOctaveThirdClass,
            .privilegedOctaveThirdClassGreat, .ordinaryOctavegreaterDouble,
            .ordinaryOctavesemiDouble
        ]
        if octaveRanks.contains(rank) { return false }
        
        return true
    }
    
    /// 當季節對經（聖母慶節優先）
    var currentAntiphon: PrimePrayerData.PsalmAntiphon? {
        let title = liturgy.mainTitle
        
        // 1️⃣ 聖母慶節優先（完整名稱列表匹配）
        if PrimePrayerData.BVMFeastAntiphon.isBVMFeast(title: title) {
            return PrimePrayerData.PsalmAntiphon(
                season: "聖母慶節",
                text: PrimePrayerData.BVMFeastAntiphon.text
            )
        }
        
        // 2️⃣ 原有季節對經邏輯（保持不變）
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        let season = info.season
        
        let seasonMap: [LiturgicalSeason: String] = [
            .advent: "降臨期",
            .christmas: "聖誕期",
            .epiphany: "全年通用",
            .lent: "大齋期",
            .holyWeek: "大齋期",
            .easter: "復活期",
            .ascension: "復活期",
            .pentecost: "復活期",
            .trinity: "全年通用"
        ]
        
        let key = seasonMap[season] ?? "全年通用"
        return PrimePrayerData.psalmAntiphons.first { $0.season == key }
            ?? PrimePrayerData.psalmAntiphons.first { $0.season == "全年通用" }
    }

    func fullAntiphonText(for antiphon: PrimePrayerData.PsalmAntiphon) -> String {
        // 聖母慶節專用
        if antiphon.season == "聖母慶節" {
            return antiphon.text
        }
        
        switch antiphon.season {
        case "全年通用":
            return "哈利路亞。你們當稱謝主，因為祂至善，祂的恩慈，永遠長存。哈利路亞。"
        case "降臨期":
            return "看哪，時候已經滿足，上帝就差遣他的兒子來到世界上。"
        case "聖誕期":
            return "牧人！你們看見了誰？請你們說；請告訴我們：誰在地上出現了？我們看見了新生的嬰兒和一大群讚美主的天使，哈利路亞，哈利路亞。"
        case "大齋期":
            return "敬畏主的當說，主的恩典，永遠長存。"
        case "復活期":
            return "哈利路亞，哈利路亞，哈利路亞，哈利路亞。"
        default:
            return antiphon.text
        }
    }
    
    /// 當日讀經（由選擇器決定）
    var currentReading: PrimePrayerData.PrimeReadingItem? {
        PrimePrayerData.PrimeReadingsLoader.shared.item(for: selectedReadingOption.rawValue)
    }
    
    /// 當日簡短啟應組
    var currentShortResponsorySet: PrimePrayerData.ShortResponsorySet? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        let season = info.season
        
        if isEasterSeason {
            let map: [LiturgicalSeason: String] = [
                .easter: "復活期",
                .ascension: "升天期",
                .pentecost: "聖靈降臨期"
            ]
            let key = map[season] ?? "復活期"
            return PrimePrayerData.shortResponsesInsideEaster.first { $0.title == key }
        } else {
            let map: [LiturgicalSeason: String] = [
                .trinity: "三一節期、大齋預備期、大齋期",
                .advent: "降臨節",
                .christmas: "聖誕期",
                .epiphany: "顯現期",
                .lent: "三一節期、大齋預備期、大齋期",
                .holyWeek: "三一節期、大齋預備期、大齋期"
            ]
            let key = map[season] ?? "三一節期、大齋預備期、大齋期"
            return PrimePrayerData.shortResponsesOutsideEaster.first { $0.title == key }
        }
    }
    
    func loadData() {
        let rank = liturgy.rank
        
        // 讀經自動預設
        if isEasterSeason {
            selectedReadingOption = .easter
        } else {
            let isSundayOrFeast: [LiturgicalRank] = [
                // 主日
                .sundayFirstClassGreat, .sundayFirstClass, .sundaySecondClass, .ordinarySunday,
                // 慶節（複式各級）
                .doubleFirstClass, .doubleSecondClass, .greaterDouble, .double,
                // 八日慶期（所有等級均視為慶節）
                .privilegedOctaveFirstClass,
                .privilegedOctaveSecondClass,
                .privilegedOctaveSecondClassGreat,
                .privilegedOctaveThirdClass,
                .privilegedOctaveThirdClassGreat,
                .ordinaryOctavegreaterDouble,
                .ordinaryOctavesemiDouble
            ]
            selectedReadingOption = isSundayOrFeast.contains(rank) ? .feast : .ordinary
        }
        selectedPrayerOption = shouldShowPrayers ? .show : .omit
    }
    
    func jumpToYesterday() {
        if let d = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = d
            loadData()
        }
    }
    func jumpToToday() {
        selectedDate = Date()
        loadData()
    }
    func jumpToTomorrow() {
        if let d = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = d
            loadData()
        }
    }
    /// 當日完整聖詩（基礎詩節 + 節期專用結尾，平日保留通用第五段）
    var hymnVerses: [String] {
        PrimePrayerData.SeasonalHymnEnding.assemble(
            baseVerses: PrimePrayerData.hymn.paragraphs,
            for: selectedDate,
            liturgy: liturgy
        )
    }
}

// MARK: - 預覽
struct PrimePrayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PrimePrayerView()
        }
    }
}
