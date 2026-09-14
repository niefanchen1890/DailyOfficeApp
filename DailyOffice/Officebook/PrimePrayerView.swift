import SwiftUI
import Combine

struct PrimePrayerView: View {
    @State private var usesFortnightlyB = false
    @StateObject private var viewModel: PrimePrayerViewModel
    @Environment(\.colorScheme) var colorScheme
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
            .background(colorScheme == .dark ? Color.black : LiturgyColors.parchment)
            
            dateQuickNavButtons
        }
        .overlay(alignment: .bottomTrailing) {
            languageToggleButton
        }
        .navigationTitle(viewModel.isSimplified ? "一时祷" : "一時禱")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 繁簡切換按鈕 (完全綁定早禱引擎)
    private var languageToggleButton: some View {
        Button(action: toggleLanguage) {
            Text(viewModel.appLanguageCode == AppLanguage.traditional.rawValue ? "繁" : "简")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(LiturgyColors.crimson)
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
                )
        }
        .padding(.trailing, 16)
        .padding(.bottom, 80)
    }

    private func toggleLanguage() {
        withAnimation(.spring()) {
            AppLanguageStore.shared.toggleLanguage()
        }
    }
    
    // MARK: - 結束說明
    private var closingNoteSection: some View {
        LiturgyCard {
            RubricBlock(text: viewModel.isSimplified ? "¶ 一时祷可由此结束，或加念以下祈祷。" : "¶ 一時禱可由此結束，或加唸以下祈禱。")
        }
    }

    // MARK: - 日期導航
    private var dateQuickNavButtons: some View {
        let isSimp = viewModel.isSimplified
        return HStack(spacing: 0) {
            Button(action: { viewModel.jumpToYesterday() }) {
                Text(isSimp ? "昨日" : "昨日").font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            
            Divider().frame(height: 20).background(Color.white.opacity(0.3))
            
            Button(action: { viewModel.jumpToToday() }) {
                Text(isSimp ? "今日" : "今日").font(.system(size: 15, weight: .bold))
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            
            Divider().frame(height: 20).background(Color.white.opacity(0.3))
            
            Button(action: { viewModel.jumpToTomorrow() }) {
                Text(isSimp ? "明日" : "明日").font(.system(size: 15, weight: .medium))
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
        let isSimp = viewModel.isSimplified
        
        return VStack(spacing: 0) {
            Text(formattedFullDateWithWeekday(viewModel.selectedDate))
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(.secondary)
                .padding(.top, 12)
            
            Text(liturgy.mainTitle.adaptChinese(isSimplified: isSimp))
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
                Text("（\(liturgy.rankName.adaptChinese(isSimplified: isSimp))）")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(LiturgyColors.crimson)
                    .padding(.top, 4)
            }
            
            Divider()
                .background(Color.secondary.opacity(0.25))
                .padding(.horizontal, 60)
                .padding(.vertical, 20)
            
            Text(isSimp ? "一  时  祷" : "一  時  禱")
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(.primary)
                .tracking(12)
                .padding(.bottom, 4)
            
            if !liturgy.commemorations.isEmpty {
                Text((isSimp ? "纪念：" : "紀念：") + liturgy.commemorations.joined(separator: "、").adaptChinese(isSimplified: isSimp))
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
        f.locale = Locale(identifier: viewModel.isSimplified ? "zh_Hans" : "zh_Hant")
        return f.string(from: date)
    }
    
    private var openingNoteSection: some View {
        LiturgyCard { RubricBlock(text: PrimePrayerData.openingNote) }
    }
    
    private var openingResponsesSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(PrimePrayerData.openingResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }
    
    private var hymnSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: PrimePrayerData.hymn.title ?? (viewModel.isSimplified ? "圣诗" : "聖詩"))
                ForEach(viewModel.hymnVerses, id: \.self) { verse in
                    hymnVerseRow(verse)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
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
        let isSimp = viewModel.isSimplified
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimp ? "诗篇" : "詩篇")
                SmallHourPsalmPicker(usesFortnightlyB: $usesFortnightlyB, isSimplified: isSimp)
                RubricBlock(text: isSimp ? "¶ 然后当念诗篇，以及适当的季节或瞻礼对经。诗篇119篇，可以周划分，见标题下所标记。" : "¶ 然後當唸詩篇，以及適當的季節或瞻禮對經。詩篇119篇，可以週劃分，見標題下所標記。")
                
                if let antiphon = viewModel.currentAntiphon {
                    RubricBlock(text: "¶ \(antiphon.season)\(isSimp ? "对经" : "對經")：")
                }
                
                let weekday = Calendar.current.component(.weekday, from: viewModel.selectedDate)
                
                if !usesFortnightlyB && weekday != 1 {
                    if let psalm54 = PsalmsLoader.shared.psalmContent(for: PrimePrayerData.psalm54Key) {
                        psalmContentView(
                            title: PrimePrayerData.psalm54Key,
                            content: psalm54,
                            openingAntiphon: viewModel.currentAntiphon?.text
                        )
                    }
                    Divider().padding(.vertical, 8)
                }
                
                let psalm119Keys = usesFortnightlyB
                    ? PsalmsLoader.shared.fortnightlyBKeys(for: viewModel.selectedDate, hour: "prime")
                    : PrimePrayerData.psalm119Keys(for: viewModel.selectedDate)
                ForEach(psalm119Keys.indices, id: \.self) { index in
                    let key = psalm119Keys[index]
                    if let psalm119 = PsalmsLoader.shared.psalmContent(for: key) {
                        psalmContentView(
                            title: usesFortnightlyB ? psalm119.title : key,
                            content: psalm119,
                            openingAntiphon: (usesFortnightlyB || weekday == 1) && index == 0
                                ? viewModel.currentAntiphon?.text
                                : nil
                        )
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
    
    private func psalmContentView(
        title: String,
        content: PsalmContent,
        openingAntiphon: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title).foregroundColor(LiturgyColors.crimson)
                if !content.latinTitle.isEmpty {
                    Text(content.latinTitle).italic().foregroundColor(.primary)
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .padding(.bottom, 4)

            if let openingAntiphon, !openingAntiphon.isEmpty {
                MorningPrayerView.AntiphonRow(text: openingAntiphon)
            }
            
            ForEach(content.verses, id: \.self) { verse in
                psalmVerseRow(verse)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                BodyText(viewModel.isSimplified ? "但愿荣耀归于圣父、圣子、圣灵；" : "但願榮耀歸於聖父、聖子、聖靈；")
                BodyText(viewModel.isSimplified ? "※起初怎样，现在以及永远，也是怎样，世世无尽。阿们。" : "※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。")
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 6)
    }
    
    private func psalmVerseRow(_ verse: String) -> some View {
        let trimmed = verse.trimmingCharacters(in: .whitespaces)
        var number = ""
        for char in trimmed {
            if char.isNumber { number.append(char) } else { break }
        }
        let text = number.isEmpty ? trimmed : String(trimmed.dropFirst(number.count)).trimmingCharacters(in: .whitespaces)
        
        var attrStr = AttributedString(text)
        attrStr.font = .system(size: 17, weight: .regular)
        attrStr.foregroundColor = .primary
        
        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            if !number.isEmpty {
                Text(number).font(.system(size: 17, weight: .regular)).foregroundColor(.red)
            }
            Text(attrStr).lineSpacing(6).fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var athanasianCreedSection: some View {
        let isSimp = viewModel.isSimplified
        return Group {
            if viewModel.shouldShowAthanasianCreed {
                LiturgyCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .center, spacing: 8) {
                            SectionTitle(text: PrimePrayerData.athanasianCreed.title ?? "")
                            Spacer()
                            Toggle(isSimp ? "显示" : "顯示", isOn: $viewModel.showAthanasianCreed)
                                .toggleStyle(.switch)
                                .labelsHidden()
                                .tint(LiturgyColors.crimson)
                        }
                        
                        if viewModel.showAthanasianCreed {
                            if let rubric = PrimePrayerData.athanasianCreed.rubric, !rubric.isEmpty {
                                RubricBlock(text: rubric)
                            }
                            
                            ForEach(0..<min(42, PrimePrayerData.athanasianCreed.paragraphs.count), id: \.self) { index in
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
                            
                            if PrimePrayerData.athanasianCreed.paragraphs.count >= 44 {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(PrimePrayerData.athanasianCreed.paragraphs[42])
                                    Text(PrimePrayerData.athanasianCreed.paragraphs[43])
                                }
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 8)
                            }
                            
                        } else {
                            Text(isSimp ? "（已省略亚他拿修信经）" : "（已省略亞他拿修信經）")
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
    
    private var readingSection: some View {
        let reading = viewModel.currentReading
        let isSimp = viewModel.isSimplified
        
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimp ? "读经" : "讀經")
                RubricBlock(text: isSimp ? "¶ 然后，按季节或日期念以下圣经章节。" : "¶ 然後，按季節或日期唸以下聖經章節。")
                
                Picker(isSimp ? "读经选择" : "讀經選擇", selection: $viewModel.selectedReadingOption) {
                    ForEach(PrimeReadingOption.allCases, id: \.self) { option in
                        Text(option.localizedTitle(isSimplified: isSimp)).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
                
                if let r = reading {
                    RubricBlock(text: "¶ \(r.season)：")
                    BodyText(r.content)
                    
                    if !r.reference.isEmpty {
                        Text("（\(r.reference)）")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.top, 2)
                            .padding(.leading, 4)
                    }
                } else {
                    PlaceholderBlock(text: isSimp ? "按当日节期诵念" : "按當日節期誦唸")
                }
                
                Divider().padding(.vertical, 4)
                
                RubricBlock(text: isSimp ? "¶ 圣经读毕，会众念：" : "¶ 聖經讀畢，會眾唸：")
                ResponsoryRow(response: Responsory(
                    leader: "",
                    people: isSimp ? "应：感谢上帝。" : "應：感謝上帝。"
                ))
            }
        }
    }
    
    private var shortResponsesSection: some View {
        let set = viewModel.currentShortResponsorySet
        let isSimp = viewModel.isSimplified
        
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimp ? "简短启应" : "簡短啟應")
                RubricBlock(text: viewModel.isEasterSeason ? (isSimp ? "¶ 复活节期内" : "¶ 復活節期內") : (isSimp ? "¶ 复活节期外" : "¶ 復活節期外"))
                
                if let s = set {
                    RubricBlock(text: "¶ \(s.title)")
                    ResponsoryRow(response: s.opening).padding(.top, 4)
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
    
    private var prayersSection: some View {
        let isSimp = viewModel.isSimplified
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimp ? "祈祷" : "祈禱")
                
                Picker(isSimp ? "祈祷选择" : "祈禱選擇", selection: $viewModel.selectedPrayerOption) {
                    ForEach(PrimePrayerOption.allCases, id: \.self) { option in
                        Text(option.localizedTitle(isSimplified: isSimp)).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
                
                if viewModel.selectedPrayerOption == .show {
                    if let rubric = PrimePrayerData.prayersOpening.rubric {
                        RubricBlock(text: rubric)
                    }
                    
                    Text(PrimePrayerData.prayersOpening.paragraphs.first ?? "")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                    
                    RubricBlock(text: isSimp ? "¶ 默念主祷文，然后出声启应：" : "¶ 默念主禱文，然後出聲啟應：")
                    if PrimePrayerData.prayersOpening.paragraphs.count > 1 {
                        BodyText(PrimePrayerData.prayersOpening.paragraphs[1])
                    }
                    
                    Divider().padding(.vertical, 6)
                    
                    let responses1 = PrimePrayerData.prayersResponses1
                    ForEach(0..<min(3, responses1.count), id: \.self) { i in
                        ResponsoryRow(response: responses1[i])
                    }
                    
                    RubricBlock(text: isSimp ? "¶ 默念「使徒信经」，然后出声启应：" : "¶ 默念「使徒信經」，然後出聲啟應：")
                    ResponsoryRow(response: Responsory(
                        leader: isSimp ? "启：我信身体复活，" : "啟：我信身體復活，",
                        people: isSimp ? "应：我信永生。阿们。" : "應：我信永生。阿們。"
                    ))
                    
                    if responses1.count > 3 {
                        ForEach(3..<responses1.count, id: \.self) { i in
                            ResponsoryRow(response: responses1[i])
                        }
                    }
                    
                    Divider().padding(.vertical, 6)
                    
                    if let rubric = PrimePrayerData.confession.rubric { RubricBlock(text: rubric) }
                    ForEach(PrimePrayerData.confession.paragraphs, id: \.self) { p in BodyText(p) }
                    RubricBlock(text: PrimePrayerData.confessionNote)
                    
                    Divider().padding(.vertical, 6)
                    
                    if let rubric = PrimePrayerData.absolution.rubric { RubricBlock(text: rubric) }
                    ForEach(PrimePrayerData.absolution.paragraphs, id: \.self) { p in BodyText(p) }
                    
                    Divider().padding(.vertical, 6)
                    
                    ForEach(PrimePrayerData.prayersResponses2, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                } else {
                    Text(isSimp ? "（本日为主日、庆节或八日庆期，省略此「祈祷」，直接诵念祝文。）" : "（本日為主日、慶節或八日慶期，省略此「祈禱」，直接誦唸祝文。）")
                        .font(.system(size: 15, weight: .regular))
                        .italic()
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
            }
        }
    }
    
    private var collectsSection: some View {
        let isSimp = viewModel.isSimplified
        return VStack(alignment: .leading, spacing: 12) {
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(text: isSimp ? "祝文" : "祝文")
                    RubricBlock(text: isSimp ? "¶ 祈祷后，或省略祈祷，则简短启应后，直接念下文。" : "¶ 祈禱後，或省略祈禱，則簡短啟應後，直接唸下文。")
                    
                    ForEach(PrimePrayerData.collectOpening, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                    
                    Text(isSimp ? "我们要祷告。" : "我們要禱告。")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                    
                    Picker(isSimp ? "祝文选择" : "祝文選擇", selection: $viewModel.selectedCollect) {
                        Text(isSimp ? "第一式" : "第一式").tag(0)
                        Text(isSimp ? "第二式" : "第二式").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 6)
                    
                    if viewModel.selectedCollect == 0 {
                        BodyText(PrimePrayerData.collect1.paragraphs.first ?? "")
                    } else {
                        if let rubric = PrimePrayerData.collect2.rubric { RubricBlock(text: rubric) }
                        BodyText(PrimePrayerData.collect2.paragraphs.first ?? "")
                    }
                }
            }
            
            LiturgyCard {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(PrimePrayerData.collectEndingResponses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                }
            }
            
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    BodyText(PrimePrayerData.closingText.paragraphs.first ?? "")
                    
                    if PrimePrayerData.closingText.paragraphs.count > 1 {
                        let text = PrimePrayerData.closingText.paragraphs[1]
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
    
    private var martyrologySection: some View {
        let isSimp = viewModel.isSimplified
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(PrimePrayerData.martyrology.title ?? "")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 2)
                
                if let rubric = PrimePrayerData.martyrology.rubric {
                    RubricBlock(text: rubric)
                }
                
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
                
                ForEach(PrimePrayerData.martyrology.paragraphs, id: \.self) { p in
                    BodyText(p)
                }
                
                Divider().padding(.vertical, 6)
                
                RubricBlock(text: isSimp ? "¶ 以下启应重复三遍。" : "¶ 以下啓應重複三遍。")
                ForEach(PrimePrayerData.martyrologyClosing, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
                
                Divider().padding(.vertical, 6)
                
                Text(PrimePrayerData.martyrologyKyrie)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                
                RubricBlock(text: PrimePrayerData.martyrologyLordPrayerNote)
                
                Text(PrimePrayerData.martyrologyLordPrayerText)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.primary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 4)
                
                ForEach(PrimePrayerData.martyrologyEndingResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
                
                Divider().padding(.vertical, 6)
                
                Text(isSimp ? "我们要祷告。" : "我們要禱告。")
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
    
    private var commemorationSection: some View {
        let isSimp = viewModel.isSimplified
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(isSimp ? "纪念亡者" : "紀念亡者")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 2)
                
                RubricBlock(text: isSimp ? "¶ 此纪念亡者，通常与「殉道录」一起诵读；也可以在一天之内的任何时辰祈祷中一起诵读。" : "¶ 此紀念亡者，通常與「殉道錄」一起誦讀；也可以在一天之內的任何時辰祈禱中一起誦讀。")
                
                ResponsoryRow(response: PrimePrayerData.commemorationOpening)
                
                Divider().padding(.vertical, 6)
                
                if let psalm130 = PsalmsLoader.shared.psalmContent(for: "詩篇 第130篇") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(isSimp ? "诗篇 130篇" : "詩篇 130篇")
                                .foregroundColor(LiturgyColors.crimson)
                            if !psalm130.latinTitle.isEmpty {
                                Text(psalm130.latinTitle).italic().foregroundColor(.primary)
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.bottom, 4)

                        ForEach(psalm130.verses, id: \.self) { verse in
                            psalmVerseRow(verse)
                        }
                    }
                }
                
                Divider().padding(.vertical, 6)
                
                ForEach(PrimePrayerData.commemorationResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
                
                Divider().padding(.vertical, 6)
                
                BodyText(PrimePrayerData.commemorationPrayer.paragraphs.first ?? "")
                
                Divider().padding(.vertical, 6)
                
                ForEach(PrimePrayerData.commemorationClosing, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }
    
    private var endingSection: some View {
        let isSimp = viewModel.isSimplified
        return VStack(spacing: 0) {
            Text(isSimp ? "❦ 一时祷至此结束。" : "❦ 一時禱至此結束。")
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
    
    // 🌟 全局監聽語言，與早禱同步
    @AppStorage("appLanguage") var appLanguageCode: String = AppLanguage.traditional.rawValue
    
    var isSimplified: Bool {
        appLanguageCode == AppLanguage.simplified.rawValue
    }

    var martyrologyEntries: [String] {
        MartyrologyLoader.shared.entries(for: selectedDate)
    }

    var shouldShowAthanasianCreed: Bool {
        if PrimePrayerData.shouldShowAthanasianCreed(for: selectedDate) { return true }
        
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        if info.season == .epiphany && info.weekday == 1 && (1...6).contains(info.weekNumber) { return true }
        if info.season == .trinity && info.weekday == 1 && (1...26).contains(info.weekNumber) { return true }
        if liturgy.identifier == .sundayBeforeAdvent { return true }
        
        return false
    }
    
    var liturgy: DailyLiturgy {
        LiturgyCoreService.shared.resolve(for: selectedDate)
    }
    
    var commonName: String? {
        let map: [String: String] = [
            "復活後第五主日": isSimplified ? "特祷主日" : "特禱主日",
            "復活後第一主日": isSimplified ? "卸白衣主日" : "卸白衣主日"
        ]
        return map[liturgy.mainTitle]
    }
    
    var isEasterSeason: Bool {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        return [.easter, .ascension, .pentecost].contains(info.season)
    }
    
    var shouldShowPrayers: Bool {
        let rank = liturgy.rank
        let sundayRanks: [LiturgicalRank] = [.sundayFirstClassGreat, .sundayFirstClass, .sundaySecondClass, .ordinarySunday]
        if sundayRanks.contains(rank) { return false }
        
        let feastRanks: [LiturgicalRank] = [.doubleFirstClass, .doubleSecondClass, .greaterDouble, .double, .semiDouble]
        if feastRanks.contains(rank) { return false }
        
        let octaveRanks: [LiturgicalRank] = [
            .privilegedOctaveFirstClass, .privilegedOctaveSecondClass,
            .privilegedOctaveSecondClassGreat, .privilegedOctaveThirdClass,
            .privilegedOctaveThirdClassGreat, .ordinaryOctavegreaterDouble,
            .ordinaryOctavesemiDouble
        ]
        if octaveRanks.contains(rank) { return false }
        
        return true
    }
    
    var currentAntiphon: PrimePrayerData.PsalmAntiphonUI? {
        if PrimePrayerData.BVMFeastAntiphon.isBVMFeast(liturgy: liturgy) {
            return PrimePrayerData.PsalmAntiphonUI(
                season: isSimplified ? "圣母庆节" : "聖母慶節",
                text: PrimePrayerData.BVMFeastAntiphon.text
            )
        }
        
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
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
        
        let key = seasonMap[info.season] ?? "全年通用"
        let simplifiedKey = key.replacingOccurrences(of: "降臨", with: "降临")
                               .replacingOccurrences(of: "聖誕", with: "圣诞")
                               .replacingOccurrences(of: "大齋", with: "大斋")
                               .replacingOccurrences(of: "復活", with: "复活")
        
        return PrimePrayerData.psalmAntiphons.first { $0.season == (isSimplified ? simplifiedKey : key) }
            ?? PrimePrayerData.psalmAntiphons.first { $0.season == "全年通用" }
    }

    func fullAntiphonText(for antiphon: PrimePrayerData.PsalmAntiphonUI) -> String {
        let seasonStr = antiphon.season
        if seasonStr == "聖母慶節" || seasonStr == "圣母庆节" { return antiphon.text }
        
        switch seasonStr {
        case "全年通用": return isSimplified ? "哈利路亚。你们当称谢主，因为祂至善，祂的恩慈，永远长存。哈利路亚。" : "哈利路亞。你們當稱謝主，因為祂至善，祂的恩慈，永遠長存。哈利路亞。"
        case "降臨期", "降临期": return isSimplified ? "看哪，时候已经满足，上帝就差遣他的儿子来到世界上。" : "看哪，時候已經滿足，上帝就差遣他的兒子來到世界上。"
        case "聖誕期", "圣诞期": return isSimplified ? "牧人！你们看见了谁？请你们说；请告诉我们：谁在地上出现了？我们看见了新生的婴儿和一大群赞美主的天使，哈利路亚，哈利路亚。" : "牧人！你們看見了誰？請你們說；請告訴我們：誰在地上出現了？我們看見了新生的嬰兒和一大群讚美主的天使，哈利路亞，哈利路亞。"
        case "大齋期", "大斋期": return isSimplified ? "敬畏主的当说，主的恩典，永远长存。" : "敬畏主的當說，主的恩典，永遠長存。"
        case "復活期", "复活期": return isSimplified ? "哈利路亚，哈利路亚，哈利路亚，哈利路亚。" : "哈利路亞，哈利路亞，哈利路亞，哈利路亞。"
        default: return antiphon.text
        }
    }
    
    var currentReading: PrimePrayerData.PrimeReadingItemUI? {
        PrimePrayerData.PrimeReadingsLoader.shared.item(for: selectedReadingOption.rawValue)
    }
    
    var currentShortResponsorySet: PrimePrayerData.ShortResponsorySetUI? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        
        if isEasterSeason {
            let map: [LiturgicalSeason: String] = [
                .easter: isSimplified ? "复活期" : "復活期",
                .ascension: isSimplified ? "升天期" : "升天期",
                .pentecost: isSimplified ? "圣灵降临期" : "聖靈降臨期"
            ]
            let key = map[info.season] ?? (isSimplified ? "复活期" : "復活期")
            return PrimePrayerData.shortResponsesInsideEaster.first { $0.title == key }
        } else {
            let map: [LiturgicalSeason: String] = [
                .trinity: isSimplified ? "三一节期、大斋预备期、大斋期" : "三一節期、大齋預備期、大齋期",
                .advent: isSimplified ? "降临节" : "降臨節",
                .christmas: isSimplified ? "圣诞期" : "聖誕期",
                .epiphany: isSimplified ? "显现期" : "顯現期",
                .lent: isSimplified ? "三一节期、大斋预备期、大斋期" : "三一節期、大齋預備期、大齋期",
                .holyWeek: isSimplified ? "三一节期、大斋预备期、大斋期" : "三一節期、大齋預備期、大齋期"
            ]
            let key = map[info.season] ?? (isSimplified ? "三一节期、大斋预备期、大斋期" : "三一節期、大齋預備期、大齋期")
            return PrimePrayerData.shortResponsesOutsideEaster.first { $0.title == key }
        }
    }
    
    func loadData() {
        let rank = liturgy.rank
        if isEasterSeason {
            selectedReadingOption = .easter
        } else {
            let isSundayOrFeast: [LiturgicalRank] = [
                .sundayFirstClassGreat, .sundayFirstClass, .sundaySecondClass, .ordinarySunday,
                .doubleFirstClass, .doubleSecondClass, .greaterDouble, .double,
                .privilegedOctaveFirstClass, .privilegedOctaveSecondClass, .privilegedOctaveSecondClassGreat,
                .privilegedOctaveThirdClass, .privilegedOctaveThirdClassGreat, .ordinaryOctavegreaterDouble, .ordinaryOctavesemiDouble
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
    
    var hymnVerses: [String] {
        PrimePrayerData.SeasonalHymnEnding.assemble(
            baseVerses: PrimePrayerData.hymn.paragraphs,
            for: selectedDate,
            liturgy: liturgy,
            isSimplified: isSimplified
        )
    }
}
