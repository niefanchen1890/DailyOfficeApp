import SwiftUI
import Combine

struct ProperPsalmDisplay {
    let year: String
    let psalms: [(title: String, content: PsalmContent)]
    let jsonAntiphon: String?
}

struct MorningPrayerView: View {
    @StateObject private var viewModel: MorningPrayerViewModel
    @StateObject private var litanyLoader = LitanyDataLoader.shared
    @StateObject private var creedsLoader = CreedsDataLoader.shared
    @Environment(\.colorScheme) var colorScheme
    
    let date: Date
    
    init(date: Date = Date()) {
        self.date = date
        let vm = MorningPrayerViewModel()
        vm.selectedDate = date
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    openingRubric
                    preparatorySection
                    seasonalSentencesSection
                    exhortationSection
                    confessionSection
                    absolutionSection
                    lordPrayerSection
                    responsesSection
                    veniteSection
                    invitatoryHymnSection
                    psalmsSection
                    lessonsSection
                    biographySection
                    creedSection
                    prayersSection
                    collectsSection
                    memorialAntiphonsSection
                    generalPrayerSelectorSection
                    generalPrayersOrLitanySection
                    endingSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .padding(.bottom, 60)
            }
            .onAppear {
                viewModel.loadReadings()
            }
            .background(colorScheme == .dark ? Color.black : LiturgyColors.parchment)
            
            dateQuickNavButtons
        }
        .overlay(alignment: .bottomTrailing) {
            languageToggleButton
        }
        .navigationTitle("早禱")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 聖人小傳/教父講道（信經前）
    private var biographySection: some View {
        Group {
            if viewModel.hasBiography, let bio = viewModel.biography {
                let lang = viewModel.appLanguage
                
                LiturgyCard {
                    VStack(alignment: .leading, spacing: 14) {
                        
                        // ═════ 1. 紅色大標題 ═════
                        if let titleText = bio.title, !titleText.isEmpty {
                            SectionTitle(text: titleText)
                        } else {
                            SectionTitle(text: lang == .traditional ? "聖人小傳" : "圣人小传")
                        }
                        
                        // ═════ 2. 禮規（紅色斜體）═════
                        if let rubricText = bio.rubric, !rubricText.isEmpty {
                            RubricBlock(text: rubricText)
                        } else {
                            RubricBlock(text: lang == .traditional ? "¶ 在信經之前，誦讀以下聖人小傳。" : "¶ 在信经之前，诵读以下圣人小传。")
                        }
                        
                        // ═════ 3. 來源說明（若有填寫，則在第一段前顯示）═════
                        if let sourceText = bio.source, !sourceText.isEmpty {
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text(lang == .traditional ? "讀經員：" : "读经员：")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.red)
                                Text(sourceText)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        // ═════ 4. 正文與特例段落 ═════
                        ForEach(bio.paragraphs.indices, id: \.self) { index in
                            switch bio.paragraphs[index] {
                            case .text(let bodyText):
                                BodyText(bodyText)

                            case .source(let sourceText):
                                Text(sourceText)
                                    .font(.system(size: 14, weight: .medium))
                                    .italic()
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 2)
                                    
                            case .subtitle(let subtitleText):
                                Text(subtitleText)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(LiturgyColors.crimson)
                                    .padding(.top, 6)
                                    
                            case .centered(let centeredText):
                                Text(centeredText)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom, 4)
                            }
                        }
                        
                        // ═════ 5. 結束啟應 ═════
                        ResponsoryRow(response: Responsory(
                            leader: lang == .traditional ? "求主憐憫。" : "求主怜悯。",
                            people: lang == .traditional ? "感謝上帝。" : "感谢上帝。"
                        ))
                        .padding(.top, 4)
                    }
                }
            }
        }
    }
    
    // MARK: - 日期導航按鈕組件
    private var dateQuickNavButtons: some View {
        HStack(spacing: 0) {
            Button(action: { viewModel.jumpToYesterday() }) {
                Text("昨日")
                    .font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
                .frame(height: 20)
                .background(Color.white.opacity(0.3))
            
            Button(action: { viewModel.jumpToToday() }) {
                Text("今日")
                    .font(.system(size: 15, weight: .bold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
                .frame(height: 20)
                .background(Color.white.opacity(0.3))
            
            Button(action: { viewModel.jumpToTomorrow() }) {
                Text("明日")
                    .font(.system(size: 15, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(
            Capsule()
                .fill(LiturgyColors.crimson)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .foregroundColor(.white)
        .padding(.bottom, 20) // 保持底部距離
        .frame(maxWidth: .infinity, alignment: .center) // 🌟 新增：撐滿外層寬度並居中
    }
    
    // MARK: - 繁簡切換按鈕（右下角圓形）
    private var languageToggleButton: some View {
        Button(action: toggleLanguage) {
            Text(viewModel.appLanguage == .traditional ? "繁" : "简")
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
        .padding(.bottom, 80)   // 往上抬高，避免與底部「昨日/今日/明日」按鈕重疊
    }

    private func toggleLanguage() {
        withAnimation(.spring()) {
            viewModel.appLanguage = (viewModel.appLanguage == .traditional) ? .simplified : .traditional
        }
    }
    
    private var header: some View {
        let liturgy = viewModel.liturgy
        
        return VStack(spacing: 0) {
            // 日期：2026年5月24日 禮拜日
            Text(formattedFullDateWithWeekday(viewModel.selectedDate))
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(.secondary)
                .padding(.top, 12)
            
            // 大標題：聖靈降臨日
            Text(liturgy.mainTitle)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
            
            // 通稱（若有）：特禱主日
            if let common = viewModel.commonName {
                Text(common)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(LiturgyColors.crimson)
                    .padding(.top, 6)
            }
            
            // 禮儀等級：（一等複式）
            if !liturgy.rankName.isEmpty {
                Text("（\(liturgy.rankName)）")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(LiturgyColors.crimson)
                    .padding(.top, 4)
            }
            
            // 分隔線
            Divider()
                .background(Color.secondary.opacity(0.25))
                .padding(.horizontal, 60)
                .padding(.vertical, 20)
            
            // 早 禱（大字置中，字間加寬）
            Text("早  禱")
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(.primary)
                .tracking(12) // 字間距
                .padding(.bottom, 4)
            
            // 紀念事項
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
    
    // MARK: - 輔助函數
    private func formattedFullDateWithWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日 EEEE"
        f.locale = Locale(identifier: "zh_Hant")
        return f.string(from: date)
    }
    
    private var openingRubric: some View {
        LiturgyCard {
            RubricBlock(text: MorningPrayerData.openingRubric)
        }
    }
    
    // MARK: - 對經行（紅色前綴，第二行對齊冒號後）
    struct AntiphonRow: View {
        let text: String
        
        // 🌟 透過 AppStorage 即時獲取當前語言
        @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
        
        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                Text(appLanguageCode == AppLanguage.traditional.rawValue ? "對經：" : "对经：")
                    .foregroundColor(.red)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 52, alignment: .leading)
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    struct VeniteStanzaView: View {
        let stanza: VeniteStanza
        let invitatoryText: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Group {
                // 對經區塊
                    if let mode = stanza.antiphonMode {
                        let lines = antiphonLines(for: mode)
                        ForEach(lines.indices, id: \.self) { index in
                            AntiphonRow(text: lines[index])
                        }
                    }
                }
                // ⬇️ 新增：對經與詩節之間的段後間距
                .padding(.bottom, 6)
                
                // 皆來頌詩節
                ForEach(stanza.verses, id: \.self) { verse in
                    BodyText(verse)
                }
            }
        }
        
        private func antiphonLines(for mode: InvitatoryDisplayMode) -> [String] {
            switch mode {
            case .fullTwice:
                return [invitatoryText, invitatoryText]
            case .fullOnce:
                return [invitatoryText]
            case .secondHalf:
                if let range = invitatoryText.range(of: "※") {
                    return [String(invitatoryText[range.lowerBound...])]
                }
                return [invitatoryText]
            case .secondHalfThenFull:
                if let range = invitatoryText.range(of: "※") {
                    let secondHalf = String(invitatoryText[range.lowerBound...])
                    return [secondHalf, invitatoryText]
                }
                return [invitatoryText, invitatoryText]
            }
        }
    }
    
    private var preparatorySection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // 1. 標題
                if let title = MorningPrayerData.preparatoryPrayers.title {
                    SectionTitle(text: title)
                }
                
                // 2. 切換按鈕（標題下、禮規上）
                Picker("預備禱文", selection: $viewModel.preparatoryOption) {
                    ForEach(PreparatoryPrayerOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 2)
                
                // 3. 禮規
                if let rubric = MorningPrayerData.preparatoryPrayers.rubric {
                    RubricBlock(text: rubric)
                }
                
                // 4. 內容（僅在選擇「日課前祈禱」時顯示）
                if viewModel.preparatoryOption == .include {
                    ForEach(MorningPrayerData.preparatoryPrayers.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                } else {
                    // 省略時顯示淡色提示
                    Text("（已省略日課前祈禱）")
                        .font(.system(size: 15, weight: .regular))
                        .italic()
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
            }
        }
    }
    
    private var seasonalSentencesSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // 🌟 從 JSON 動態讀取標題（會自動跟隨 appLanguage 讀取繁簡體 JSON）
                if let title = MorningPrayerData.seasonalSentences.title {
                    SectionTitle(text: title)
                }
                
                // 🌟 從 JSON 動態讀取禮儀說明
                if let rubric = MorningPrayerData.seasonalSentences.rubric {
                    RubricBlock(text: rubric)
                }
                
                let sentences = viewModel.bibleSentences
                
                if sentences.isEmpty {
                    // 佔位文字（保留雙語判斷，確保沒選句時顯示正確語言）
                    PlaceholderBlock(text: viewModel.appLanguage == .traditional ? "按當日節期誦唸" : "按当日节期诵念")
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(sentences, id: \.self) { sentence in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sentence.text)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text(sentence.reference)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.red)
                                    .padding(.leading, 4)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
        }
    }
    
    private func seasonalBlock(_ block: SeasonalBlock) -> some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 10) {
                if !block.title.isEmpty {
                    SectionTitle(text: block.title)
                }
                RubricBlock(text: block.rubric)
                if let content = block.content {
                    BodyText(content)
                } else {
                    PlaceholderBlock(text: "按當日節期誦唸")
                }
            }
        }
    }
    
    private var exhortationSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // 🌟 修復：支援簡體切換
                SectionTitle(text: viewModel.appLanguage == .traditional ? "勸眾文" : "劝众文")
                RubricBlock(text: MorningPrayerData.exhortation.rubric!)
                
                BodyText(MorningPrayerData.exhortation.paragraphs[0])
                
                Text(viewModel.appLanguage == .traditional ? "或唸：" : "或念：")
                    .font(.system(size: 15, weight: .regular))
                    .italic()
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                
                BodyText(MorningPrayerData.exhortation.paragraphs[1])
            }
        }
    }
    
    private var confessionSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // 🌟 修復：支援簡體切換
                SectionTitle(text: viewModel.appLanguage == .traditional ? "認罪文" : "认罪文")
                RubricBlock(text: MorningPrayerData.confession.rubricBefore)
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(MorningPrayerData.confession.version1.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                }
            }
        }
    }
    
    private var absolutionSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: MorningPrayerData.absolution.title)
                
                // ⬇️ iOS 原生分段選擇器
                Picker("赦罪文版本", selection: $viewModel.absolutionVersion) {
                    ForEach(AbsolutionVersion.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 2)
                
                if viewModel.absolutionVersion == .clergy {
                    // 聖品人員用
                    RubricBlock(text: MorningPrayerData.absolution.clergyRubric)
                    
                    ForEach(MorningPrayerData.absolution.clergyParagraphs, id: \.self) { p in
                        BodyText(p)
                    }
                    
                    RubricBlock(text: MorningPrayerData.absolution.clergyAltRubric)
                    
                    ForEach(MorningPrayerData.absolution.clergyAltParagraphs, id: \.self) { p in
                        BodyText(p)
                    }
                } else {
                    // 平信徒用
                    RubricBlock(text: MorningPrayerData.absolution.laypersonRubric)
                    
                    ForEach(MorningPrayerData.absolution.laypersonParagraphs, id: \.self) { p in
                        BodyText(p)
                    }
                }
            }
        }
    }
    
    private var responsesSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // 🌟 修復：支援簡體切換
                SectionTitle(text: viewModel.appLanguage == .traditional ? "啟應" : "启应")
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(MorningPrayerData.responses, id: \.self) { response in
                        ResponsoryRow(response: response)
                    }
                }
            }
        }
    }
    
    private var lordPrayerSection: some View {
        LiturgyCard {
            PrayerSectionContent(section: MorningPrayerData.lordPrayer)
        }
    }
    
    private var veniteSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 0) {
                SectionTitle(text: MorningPrayerData.venite.title)
                    .padding(.bottom, 4)
                
                // 皆來頌主體：對經+詩節交替
                ForEach(MorningPrayerData.venite.stanzas.indices, id: \.self) { i in
                    VeniteStanzaView(
                        stanza: MorningPrayerData.venite.stanzas[i],
                        invitatoryText: viewModel.invitatoryText
                    )
                    .padding(.bottom, 12)
                    
                    if i == 0 && viewModel.shouldShowInvitatoryMondayNote {
                        RubricBlock(text: MorningPrayerData.invitatoryMondayNote)
                            .padding(.top, 2)
                    }
                }
                
                // 結束式選擇器
                Picker("結束方式", selection: $viewModel.veniteEnding) {
                    ForEach(VeniteEndingOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
                
                // 根據選擇顯示對應結束式
                let ending = viewModel.veniteEnding == .ending1
                ? MorningPrayerData.venite.ending1
                : MorningPrayerData.venite.ending2
                
                // 🌟 修改點：拉開禮規說明的上下距離
                if let note = ending.note {
                    RubricBlock(text: note)
                        .padding(.top, 8)     // 增加與上方 Picker 的距離
                        .padding(.bottom, 14) // 增加與下方正文的距離
                }
                
                // 結束式：對經+詩節交替
                ForEach(ending.stanzas.indices, id: \.self) { i in
                    VeniteStanzaView(
                        stanza: ending.stanzas[i],
                        invitatoryText: viewModel.invitatoryText
                    )
                    .padding(.bottom, 12)
                }
            }
        }
    }
    
    // MARK: - 邀請聖詩（皆來頌之後、詩篇之前）
    private var invitatoryHymnSection: some View {
        let hymn = viewModel.invitatoryHymn
        
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // 🌟 修復：支援簡體切換
                SectionTitle(text: viewModel.appLanguage == .traditional ? "邀請聖詩" : "邀请圣诗")
                
                // 🌟 修復：拉丁文標題改為靠左對齊（alignment: .leading）
                Text(hymn.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 2)
                
                // 使用時期說明（禮規 → 紅色斜體）
                if let note = hymn.seasonNote, !note.isEmpty {
                    Text("¶ " + note)
                        .font(.system(size: 13, weight: .medium))
                        .italic()
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading) // 也將禮規說明靠左以統一視覺
                        .padding(.bottom, 4)
                }
                
                Divider().padding(.vertical, 4)
                
                // 詩句逐節渲染（紅色序號 + 懸掛縮進對齊）
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(hymn.verses.enumerated()), id: \.offset) { _, verse in
                        invitatoryHymnVerseRow(verse)
                    }
                }
            }
        }
    }
    
    // MARK: - 邀請聖詩單節（紅色中文序號 + 懸掛縮進）
    private func invitatoryHymnVerseRow(_ verse: String) -> some View {
        let prefix = extractChineseNumberPrefix(verse)   // 例如 "一、"
        let bodyText = String(verse.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
        let lines = bodyText.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        return HStack(alignment: .top, spacing: 0) {
            // 紅色中文序號（固定寬度，對齊頓號後文字）
            Text(prefix)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.red)
                .frame(width: 40, alignment: .leading)
            
            // 正文（分句斷行，自動與頓號後對齊）
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
    }
    
    // MARK: - 日課聖詩（第二經課後、第二頌歌前）
    private var officeHymnSection: some View {
        let hymn = viewModel.officeHymn
        
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "日課聖詩")
                
                // 拉丁文標題：紅色、居中（取代中文標題）
                if !hymn.latinTitle.isEmpty {
                    Text(hymn.latinTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                }
                
                // 季節註釋（禮規說明 → 紅色斜體）
                if let note = hymn.seasonNote, !note.isEmpty {
                    Text(note)
                        .font(.system(size: 13, weight: .medium))
                        .italic()
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 4)
                }
                
                Divider().padding(.vertical, 4)
                
                // 詩句逐節渲染（紅色中文序號 + 懸掛縮進對齊）
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(hymn.verses.enumerated()), id: \.offset) { _, verse in
                        officeHymnVerseRow(verse)
                    }
                }
                
                // 啟應
                if let versicle = hymn.versicle {
                    Divider().padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 4) {
                            Text("啟：")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                                .frame(width: 32, alignment: .leading)
                            Text(versicle.leader)
                                .font(.system(size: 16))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        HStack(alignment: .top, spacing: 4) {
                            Text("應：")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                                .frame(width: 32, alignment: .leading)
                            Text(versicle.people)
                                .font(.system(size: 16))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 日課聖詩單節（紅色中文序號 + 懸掛縮進）
    private func officeHymnVerseRow(_ verse: String) -> some View {
        let prefix = extractChineseNumberPrefix(verse)   // 例如 "一、"
        let bodyText = String(verse.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
        let lines = bodyText.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        return HStack(alignment: .top, spacing: 0) {
            // 紅色中文序號（固定寬度，對齊頓號後文字）
            Text(prefix)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.red)
                .frame(width: 40, alignment: .leading)
            
            // 正文（分句斷行，自動與頓號後對齊）
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
    }
    
    // MARK: - 聖詩單節（紅色序號 + 懸掛縮進 + 分句斷行）
    private func hymnVerseRow(_ verse: String) -> some View {
        let prefix = extractChineseNumberPrefix(verse)
        let body = String(verse.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
        let lines = body.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        return HStack(alignment: .top, spacing: 0) {
            // 紅色中文序號（固定寬度，對齊頓號後文字）
            Text(prefix)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.red)
                .frame(width: 40, alignment: .leading)
            
            // 正文分句（每句獨立一行）
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
    }
    
    // MARK: - 提取中文數字序號（如「一、」「十二、」）
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
    
    private func displayNameForPsalmLectionaryOption(_ option: String) -> String {
        let isTrad = viewModel.appLanguage == .traditional
        switch option {
        case "monthly": return isTrad ? "月度循環" : "月度循环"
        case "1943":    return isTrad ? "1943年詩篇" : "1943年诗篇"
        case "1928":    return isTrad ? "1928年詩篇" : "1928年诗篇"
        case "1962":    return isTrad ? "1962年詩篇" : "1962年诗篇"
        case "special": return isTrad ? "專用詩篇" : "专用诗篇"
        default:        return option
        }
    }
    
    // MARK: - 詩篇
    private var psalmsSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.appLanguage == .traditional ? "詩篇" : "诗篇")
                RubricBlock(text: viewModel.appLanguage == .traditional ? "¶ 然後按本會的慣例讀詩篇，並相應的對經。" : "¶ 然后按本会的惯例读诗篇，并相应的对经。")
                
                let psalmOptions = ["monthly"] + viewModel.availablePsalmLectionaryOptions
                
                if psalmOptions.count > 1 {
                    Picker("詩篇選擇", selection: $viewModel.selectedPsalmLectionary) {
                        ForEach(psalmOptions, id: \.self) { option in
                            Text(displayNameForPsalmLectionaryOption(option)).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 2)
                }
                
                if viewModel.selectedPsalmLectionary == "1943",
                   viewModel.available1943Sets.count > 1 {
                    Picker("1943詩篇組", selection: $viewModel.selected1943SetId) {
                        ForEach(viewModel.available1943Sets) { set in
                            Text(set.label ?? set.id).tag(Optional(set.id))
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 2)
                    .onChange(of: viewModel.selected1943SetId) {
                        viewModel.loadReadings()
                    }
                }
                
                switch viewModel.selectedPsalmLectionary {
                case "1943":
                    if let proper = viewModel.selected1943SetPsalms {
                        properPsalm1943Section(proper)
                    } else {
                        psalmsWithCurrentAntiphonLogic(psalms: viewModel.morningPsalms)
                    }
                    
                case "1928", "1962", "special":
                    if let proper = viewModel.selectedProperPsalms {
                        psalmsWithCurrentAntiphonLogic(psalms: proper.psalms)
                    } else {
                        psalmsWithCurrentAntiphonLogic(psalms: viewModel.morningPsalms)
                    }
                    
                default:
                    psalmsWithCurrentAntiphonLogic(psalms: viewModel.morningPsalms)
                }
            }
        }
    }
    
    @ViewBuilder
    private func psalmsWithCurrentAntiphonLogic(
        psalms: [(title: String, content: PsalmContent)]
    ) -> some View {
        let antiphonList = viewModel.psalmAntiphons
        
        if psalms.isEmpty {
            PlaceholderBlock(text: viewModel.appLanguage == .traditional ? "按當日節期誦唸" : "按当日节期诵念")
        } else if let list = antiphonList, !list.isEmpty {
            let groups = antiphonGroups(
                psalms: psalms,
                antiphons: list
            )
            psalmsGroupedView(groups: groups)
        } else {
            psalmsIndividualView(psalms: psalms)
        }
    }
    
    private func psalms1943AntiphonView(
            psalms: [(title: String, content: PsalmContent)],
            antiphon: String?
        ) -> some View {
            // 🌟 檢查是否有傳入有效的專用對經
            let hasProperAntiphon = (antiphon != nil && !antiphon!.isEmpty)
            
            return VStack(alignment: .leading, spacing: 0) {
                // 1. 群組開頭：如果有專用對經，統一顯示在最前面
                if hasProperAntiphon {
                    AntiphonRow(text: antiphon!)
                        .padding(.bottom, 8)
                }
                
                ForEach(psalms.indices, id: \.self) { i in
                    let psalm = psalms[i]
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(psalm.title)
                                .foregroundColor(LiturgyColors.crimson)
                            
                            if !psalm.content.latinTitle.isEmpty {
                                Text(psalm.content.latinTitle)
                                    .italic()
                                    .foregroundColor(.primary)
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.bottom, 4)
                        
                        // 🌟 2. 詩篇開頭：如果沒有專用對經，退回顯示詩篇自帶的對經
                        if !hasProperAntiphon && !psalm.content.antiphon.isEmpty {
                            AntiphonRow(text: psalm.content.antiphon)
                        }
                        
                        ForEach(psalm.content.verses, id: \.self) { verse in
                            verseWithNumber(verse)
                        }
                        
                        // 1943：每一篇詩篇後都加榮耀頌
                        VStack(alignment: .leading, spacing: 4) {
                            BodyText(MorningPrayerData.responses[2].leader)
                            BodyText("※" + MorningPrayerData.responses[2].people)
                        }
                        .padding(.top, 8)
                        
                        // 🌟 3. 詩篇結尾：如果沒有專用對經，退回顯示詩篇自帶的對經
                        if !hasProperAntiphon && !psalm.content.antiphon.isEmpty {
                            AntiphonRow(text: psalm.content.antiphon)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 6)
                    
                    if i < psalms.count - 1 {
                        Divider()
                            .padding(.vertical, 4)
                    }
                }
                
                // 4. 群組結尾：如果有專用對經，統一顯示在最後面
                if hasProperAntiphon {
                    AntiphonRow(text: antiphon!)
                        .padding(.top, 8)
                }
            }
        }
    
    private func properPsalm1943Section(_ proper: ProperPsalmDisplay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            psalms1943AntiphonView(
                psalms: proper.psalms,
                antiphon: proper.jsonAntiphon
            )
        }
    }

    // MARK: - 對經分組演算法
    private func antiphonGroups(
        psalms: [(title: String, content: PsalmContent)],
        antiphons: [String]
    ) -> [(antiphon: String, psalms: [(title: String, content: PsalmContent)])] {
        var groups: [(String, [(title: String, content: PsalmContent)])] = []
        var psalmIndex = 0
        let psalmCount = psalms.count
        let antiphonCount = antiphons.count
        
        for i in 0..<antiphonCount {
            if psalmIndex >= psalmCount { break }
            
            let isLastAntiphon = (i == antiphonCount - 1)
            let antiphon = antiphons[i]
            
            // 前幾個對經各配一篇；最後一個對經吞掉所有剩餘詩篇
            let count = isLastAntiphon ? (psalmCount - psalmIndex) : 1
            
            let endIndex = min(psalmIndex + count, psalmCount)
            let slice = Array(psalms[psalmIndex..<endIndex])
            groups.append((antiphon, slice))
            psalmIndex = endIndex
        }
        
        return groups
    }

    // MARK: - 分組對經詩篇渲染（新邏輯）
    private func psalmsGroupedView(
        groups: [(antiphon: String, psalms: [(title: String, content: PsalmContent)])]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(groups.indices, id: \.self) { gIndex in
                let group = groups[gIndex]
                
                // ═════ 對經（組前）═════
                AntiphonRow(text: group.antiphon)
                    .padding(.bottom, 8)
                
                // ═════ 組內詩篇 ═════
                ForEach(group.psalms.indices, id: \.self) { pIndex in
                    let psalm = group.psalms[pIndex]
                    let isLastInGroup = pIndex == group.psalms.count - 1
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // 篇名
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(psalm.title).foregroundColor(LiturgyColors.crimson)
                            if !psalm.content.latinTitle.isEmpty {
                                Text(psalm.content.latinTitle).italic().foregroundColor(.primary)
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.bottom, 4)
                        
                        // 詩節
                        ForEach(psalm.content.verses, id: \.self) { verse in
                            verseWithNumber(verse)
                        }
                        
                        // ═════ 榮耀頌：僅組最後一篇才加 ═════
                        if isLastInGroup {
                            VStack(alignment: .leading, spacing: 4) {
                                // 🌟 直接從載入的 JSON 中提取對應語言的榮耀頌
                                BodyText(MorningPrayerData.responses[2].leader)
                                BodyText("※" + MorningPrayerData.responses[2].people)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.vertical, 6)
                    
                    // 組內分隔線（非最後一篇不加榮耀頌，故加分隔線區隔）
                    if !isLastInGroup {
                        Divider().padding(.vertical, 4)
                    }
                }
                
                // ═════ 對經（組後，榮耀頌後）═════
                AntiphonRow(text: group.antiphon)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                
                // 組間分隔線
                if gIndex < groups.count - 1 {
                    Divider().padding(.vertical, 8)
                }
            }
        }
    }

    // MARK: - 舊邏輯：每篇自帶對經（無專用對經時）
    private func psalmsIndividualView(
        psalms: [(title: String, content: PsalmContent)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(psalms.indices, id: \.self) { i in
                let psalm = psalms[i]
                // let isLast = i == psalms.count - 1
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(psalm.title).foregroundColor(LiturgyColors.crimson)
                        if !psalm.content.latinTitle.isEmpty {
                            Text(psalm.content.latinTitle).italic().foregroundColor(.primary)
                        }
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.bottom, 4)
                    
                    if !psalm.content.antiphon.isEmpty {
                        AntiphonRow(text: psalm.content.antiphon)
                    }
                    
                    ForEach(psalm.content.verses, id: \.self) { verse in
                        verseWithNumber(verse)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // 🌟 直接從載入的 JSON 中提取對應語言的榮耀頌
                        BodyText(MorningPrayerData.responses[2].leader)
                        BodyText("※" + MorningPrayerData.responses[2].people)
                    }
                    .padding(.top, 8)
                    
                    if !psalm.content.antiphon.isEmpty {
                        AntiphonRow(text: psalm.content.antiphon)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 6)
                
                if i < psalms.count - 1 {
                    Divider().padding(.vertical, 4)
                }
            }
        }
    }
    
    // MARK: - 帶紅色節序號的詩節
    private func verseWithNumber(_ verse: String) -> some View {
        let trimmed = verse.trimmingCharacters(in: .whitespaces)
        var number = ""
        for char in trimmed {
            if char.isNumber {
                number.append(char)
            } else {
                break
            }
        }
        
        let text = number.isEmpty
        ? trimmed
        : String(trimmed.dropFirst(number.count)).trimmingCharacters(in: .whitespaces)
        
        return HStack(alignment: .firstTextBaseline, spacing: 6) {
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
    }
    
    // MARK: - 經課區塊
    private var lessonsSection: some View {
        let readings = viewModel.dailyReadings
        // 安全獲取標題，防範 JSON 解析延遲
        let firstLessonTitle = MorningPrayerData.lessons.count > 0 ? MorningPrayerData.lessons[0].title : (viewModel.appLanguage == .traditional ? "第一經課" : "第一经课")
        let secondLessonTitle = MorningPrayerData.lessons.count > 1 ? MorningPrayerData.lessons[1].title : (viewModel.appLanguage == .traditional ? "第二經課" : "第二经课")
        
        return VStack(alignment: .leading, spacing: 12) {
            
            // 🌟 1. 第一經課卡片：將大標題放在選擇器上方
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    
                    // 大標題「第一經課」
                    SectionTitle(text: firstLessonTitle)
                    
                    // 經課版本選擇器
                    if viewModel.availableLectionaryOptions.count > 1 {
                        Picker("經課版本", selection: $viewModel.lectionaryYear) {
                            ForEach(viewModel.availableLectionaryOptions, id: \.self) { option in
                                Text(displayNameForLectionaryOption(option)).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 2)
                    } else if let onlyOption = viewModel.availableLectionaryOptions.first {
                        Text(displayNameForLectionaryOption(onlyOption))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                    }
                    
                    // 1943 特屬經課組選擇器
                    if viewModel.lectionaryYear == "1943",
                       viewModel.available1943Sets.count > 1 {
                        Picker("1943經課組", selection: $viewModel.selected1943SetId) {
                            ForEach(viewModel.available1943Sets) { set in
                                Text(set.label ?? set.id).tag(Optional(set.id))
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 2)
                        .onChange(of: viewModel.selected1943SetId) {
                            viewModel.loadReadings()
                        }
                    }
                    
                    // 第一經課內容
                    if let day = readings?.morningOT {
                        scriptureContent(day: day, verses: viewModel.morningOTVerses, readingLabel: firstLessonTitle)
                    } else {
                        scripturePlaceholder()
                    }
                }
            }
            
            // 🌟 2. 聖日第一頌歌選擇器
            SectionTitle(text: viewModel.appLanguage == .traditional ? "第一頌歌" : "第一颂歌")
            
            if LiturgyCoreService.shared.firstCanticleType(for: viewModel.selectedDate) == .teDeum {
                Picker("第一頌歌選擇", selection: $viewModel.selectedHolyDayCanticle) {
                    Text(viewModel.appLanguage == .traditional ? "讚美頌" : "赞美颂").tag(CanticleType.teDeum)
                    Text(viewModel.appLanguage == .traditional ? "摩西頌" : "摩西颂").tag(CanticleType.cantemusDomino)
                    Text(viewModel.appLanguage == .traditional ? "安波羅修頌" : "安波罗修颂").tag(CanticleType.teLaudamus)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 2)
            }
            
            let isHolyDayCanticle = [CanticleType.teDeum, CanticleType.cantemusDomino, CanticleType.teLaudamus].contains(viewModel.firstCanticleType)
            canticleBlock(canticle: viewModel.firstCanticle, showTitle: !isHolyDayCanticle)
            
            // 🌟 3. 第二經課數據
            lessonBlock(
                title: secondLessonTitle,
                rubric: "", // 禮規已經由 scriptureContent 動態渲染，這裡留空
                day: readings?.morningNT,
                verses: viewModel.morningNTVerses,
                readingLabel: secondLessonTitle
            )
            
            officeHymnSection
            
            // 🌟 4. 第二頌歌選擇器
            SectionTitle(text: viewModel.appLanguage == .traditional ? "第二頌歌" : "第二颂歌")
            
            Picker("第二頌歌選擇", selection: $viewModel.selectedSecondCanticle) {
                ForEach(SecondCanticleSelection.allCases, id: \.self) { option in
                    Text(viewModel.appLanguage == .traditional ? option.rawValue : (option == .benedictus ? "以色列颂" : "欢呼颂")).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 2)
            
            canticleBlock(
                canticle: viewModel.secondCanticleData,
                antiphon: viewModel.secondCanticleAntiphon,
                antiphonNote: viewModel.secondCanticleAntiphonNote,
                showTitle: false
            )
        }
    }

    // MARK: - 頌歌顯示區塊（支援顯示副標題與禮規）
    private func canticleBlock(canticle: CanticleData, antiphon: String? = nil, antiphonNote: String? = nil, showTitle: Bool = true) -> some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                
                // ═════ 標題區（依 showTitle 決定是否顯示大標題）═════
                if showTitle {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(canticle.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(LiturgyColors.crimson)
                        
                        if let subtitle = canticle.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                } else {
                    // 🌟 即使隱藏了大標題，若有副標題（經文出處，如「詩篇 100篇」或「路加福音 1:68-79」），依然獨立顯示
                    if let subtitle = canticle.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 2)
                    }
                }
                
                // ═════ 禮規說明（如「¶ 在平日，唸歡呼頌。」）═════
                if let rubric = canticle.rubric, !rubric.isEmpty {
                    RubricBlock(text: rubric)
                }
                
                // ═════ 對經（第一遍，詩節前）═════
                if let antiphon = antiphon {
                    AntiphonRow(text: antiphon)
                        .padding(.bottom, 4)
                }
                
                // ═════ 對經後註解 ═════
                if let note = antiphonNote {
                    RubricBlock(text: note)
                        .padding(.bottom, 4)
                }
                
                // ═════ 頌歌內容 ═════
                if canticle.style == "prose", let paragraphs = canticle.paragraphs {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(paragraphs.indices, id: \.self) { i in
                            BodyText(paragraphs[i])
                        }
                    }
                } else if canticle.style == "responsive" {
                    if let sections = canticle.sections {
                        ForEach(sections.indices, id: \.self) { sIndex in
                            let section = sections[sIndex]
                            ForEach(section) { verse in
                                canticleVerseRow(verse)
                            }
                            if sIndex < sections.count - 1 {
                                Spacer().frame(height: 12)
                            }
                        }
                    } else if let verses = canticle.verses {
                        ForEach(verses) { verse in
                            canticleVerseRow(verse)
                        }
                    }
                }
                
                // ═════ 榮耀頌 ═════
                if let doxology = canticle.doxology {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(doxology)
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 8)
                }
                
                // ═════ 對經（第二遍，榮耀頌後）═════
                if let antiphon = antiphon {
                    AntiphonRow(text: antiphon)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    // MARK: - 頌歌啟應行（全部黑色，※ 不標紅）
    private func canticleVerseRow(_ verse: CanticleVerse) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verse.call)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.primary)
            
            Text(verse.response)
                .font(.system(size: 17))
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .padding(.vertical, 2)
    }
    
    // MARK: - 處理 ※ 標記（純黑色，不再標紅）
    private func markedText(_ text: String) -> Text {
        Text(text)
            .font(.system(size: 17))
            .foregroundColor(.primary)
    }
    
    // MARK: - 經課區塊（含版本切換 + 經文）
    private func lessonBlock(title: String, rubric: String, day: LectionaryDay?, verses: [BibleVerse], readingLabel: String) -> some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: title)
                
                // 刪除這一行：RubricBlock(text: rubric)
                // 禮規改由 scriptureContent 統一分段渲染
                
                if let day = day {
                    scriptureContent(day: day, verses: verses, readingLabel: readingLabel)
                } else {
                    scripturePlaceholder()
                }
            }
        }
    }
    
    func displayNameForLectionaryOption(_ option: String) -> String {
        // 🌟 同樣直接讀取全域語言狀態
        let isTrad = MorningPrayerDataLoader.shared.currentLanguage == .traditional
        switch option {
        case "1943":    return isTrad ? "1943年經課" : "1943年经课"
        case "1928":    return isTrad ? "1928年經課" : "1928年经课"
        case "1962":    return isTrad ? "1962年經課" : "1962年经课"
        case "special": return isTrad ? "專用經課" : "专用经课"
        default:        return option
        }
    }

    
    // MARK: - 經文內容（直接從對應的 JSON 檔讀取禮儀說明與啟應）
    private func scriptureContent(day: LectionaryDay, verses: [BibleVerse], readingLabel: String) -> some View {
        // 🌟 判斷當前是第一經課（索引 0）還是第二經課（索引 1）
        let lessonIndex = readingLabel.contains("第二") || readingLabel.contains("第二经课") ? 1 : 0
        let jsonLesson = MorningPrayerData.lessons.indices.contains(lessonIndex) ? MorningPrayerData.lessons[lessonIndex] : nil
        
        // 取得該經課的原始禮儀說明文字
        let rubricText = jsonLesson?.rubric ?? ""
        
        return VStack(alignment: .leading, spacing: 16) {
            
            // 🌟 1. 經課前的禮規說明（若內容含有雙換行，取上半部顯示於經課前）
            if !rubricText.isEmpty {
                let components = rubricText.components(separatedBy: "\n\n")
                RubricBlock(text: components.first ?? rubricText)
            }
            
            // 經課標題
            let atText = viewModel.appLanguage == .traditional ? "載在" : "载在"
            Text("\(readingLabel)\(atText)\(day.book)\(day.chapter)")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
            
            // 經文（加載中或內容）
            if verses.isEmpty {
                HStack {
                    Spacer()
                    ProgressView(viewModel.appLanguage == .traditional ? "載入經文..." : "载入经文...")
                        .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                scriptureVerses(verses)
            }
            
            // 讀畢提示
            let readCompletedText = viewModel.appLanguage == .traditional ? "讀畢。" : "读毕。"
            Text("\(readingLabel)\(readCompletedText)")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.primary)
                .padding(.top, 8)
            
            // 🌟 2. 經課讀畢後的啟應前禮規（若內容含有雙換行，取下半部）
            if !rubricText.isEmpty {
                let components = rubricText.components(separatedBy: "\n\n")
                if components.count > 1 {
                    RubricBlock(text: components.last ?? "")
                }
            }
            
            // 🌟 3. 啟應（完全從 JSON 陣列中讀取，不設任何硬編碼預設）
            if let responses = jsonLesson?.responses {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(responses, id: \.self) { response in
                        ResponsoryRow(response: response)
                    }
                }
            }
        }
    }
    
    // MARK: - 經文段落（數據庫已帶節號，直接標紅上標）
    private func scriptureVerses(_ verses: [BibleVerse]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(verses) { verse in
                Text(attributedScripture(verse.content))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - 將經文字串中的節號數字標為紅色上標
    private func attributedScripture(_ text: String) -> AttributedString {
        var attrStr = AttributedString(text)
        attrStr.font = .system(size: 17)
        attrStr.foregroundColor = .primary
        
        // 匹配作為節號的數字：開頭或空格後，且後面跟空格
        guard let regex = try? NSRegularExpression(pattern: "(?:^|\\s)(\\d+)(?=\\s)", options: []) else {
            return attrStr
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            let numRange = match.range(at: 1) // 只取數字部分
            if let range = Range(numRange, in: attrStr) {
                attrStr[range].font = .system(size: 11, weight: .medium)
                attrStr[range].foregroundColor = .red
                attrStr[range].baselineOffset = 6
            }
        }
        
        return attrStr
    }
    
    // MARK: - 無經課佔位
    private func scripturePlaceholder() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                Image(systemName: "book.closed")
                    .font(.system(size: 22))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                Text("按當日節期誦唸")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    private var creedSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.appLanguage == .traditional ? "信經" : "信经")
                RubricBlock(text: MorningPrayerData.creedRubric)
                
                // 三段選擇器
                Picker("信經選擇", selection: $viewModel.selectedCreed) {
                    ForEach(CreedSelection.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
                
                // 🌟 補充禮規提示：當選擇的不是亞他那修信經時才顯示，並支援雙語
                if viewModel.selectedCreed != .athanasian {
                    Text(viewModel.appLanguage == .traditional
                         ? "¶ 不唸使徒信經，唸尼西亞信經亦可。"
                         : "¶ 不念使徒信经，念尼西亚信经亦可。")
                        .font(.system(size: 13, weight: .regular))
                        .italic()
                        .foregroundColor(.red)
                        .padding(.bottom, 4)
                }
                
                // 根據選擇顯示對應信經
                switch viewModel.selectedCreed {
                case .apostles:
                    creedContent(MorningPrayerData.apostlesCreed)
                case .nicene:
                    creedContent(MorningPrayerData.niceneCreed)
                case .athanasian:
                    athanasianCreedContent
                }
            }
        }
    }

    // MARK: - 使徒 / 尼西亞信經通用渲染
    private func creedContent(_ section: PrayerSection) -> some View {
        Group {
            // 🌟 配合頂部已有的分段選擇器，隱略個別的紅色標題
            ForEach(section.paragraphs, id: \.self) { p in
                BodyText(p)
            }
        }
    }

    // MARK: - 亞他拿修信經專用渲染（42 段正文 + 2 段榮耀頌）
    @ViewBuilder
    private var athanasianCreedContent: some View {
        if let creedData = creedsLoader.athanasianCreed {
            let lang = viewModel.appLanguage
            
            Group {
                // 🌟 配合頂部已有的分段選擇器，隱略個別的紅色標題
                RubricBlock(text: creedData.rubric.text(for: lang))
                
                // 🌟 1. 將正文與榮耀頌包進獨立的 VStack (spacing: 8)，避免受到外層 14pt 影響而太鬆散
                VStack(alignment: .leading, spacing: 8) {
                    // ═════ 正文 42 段：一、至四十二、（懸掛縮進）═════
                    ForEach(0..<42, id: \.self) { index in
                        // 確保陣列不越界
                        if index < creedData.paragraphs.count {
                            let body = creedData.paragraphs[index].text(for: lang)
                            let prefix = numberToChinese(index + 1) + "、"
                            
                            HStack(alignment: .top, spacing: 0) {
                                Text(prefix)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.red)
                                    .frame(width: 52, alignment: .leading)
                                Text(body)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    
                    // ═════ 榮耀頌（第 43–44 段）═════
                    if creedData.paragraphs.count >= 44 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(creedData.paragraphs[42].text(for: lang))
                                .lineSpacing(6)
                            Text(creedData.paragraphs[43].text(for: lang))
                                .lineSpacing(6)
                        }
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        // 🌟 2. 移除置中對齊，讓榮耀頌直接與上方信經的「序號（如一、二）」切齊
                        .padding(.top, 8)
                    }
                }
            }
        } else {
            // 資料加載中
            ProgressView(viewModel.appLanguage == .traditional ? "載入亞他那修信經..." : "载入亚他那修信经...")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
    }
    
    private var prayersSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // 🌟 改為從 JSON 動態讀取標題與禮規
                if let title = MorningPrayerData.prayers.title {
                    SectionTitle(text: title)
                }
                if let rubric = MorningPrayerData.prayers.rubric {
                    RubricBlock(text: rubric)
                }
                
                // ⬇️ 啟應格式，不居中（加入雙語判斷）
                ResponsoryRow(response: Responsory(
                    leader: viewModel.appLanguage == .traditional ? "願主與你們同在。" : "愿主与你们同在。",
                    people: viewModel.appLanguage == .traditional ? "願主與你的心靈同在。" : "愿主与你的心灵同在。"
                ))
                
                // ⬇️ 居中：我們要禱告（加入雙語判斷）
                Text(viewModel.appLanguage == .traditional ? "我們要禱告。" : "我们要祷告。")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                
                // ⬇️ 居中：求主憐憫三句（加入雙語判斷）
                Text(viewModel.appLanguage == .traditional ? "求主憐憫；\n求基督憐憫；\n求主憐憫。" : "求主怜悯；\n求基督怜悯；\n求主怜悯。")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 4)
                
                // ⬇️ 主禱文：正常左對齊 (這個原本就有抓 JSON 的 paragraphs[2]，會自動雙語)
                if MorningPrayerData.prayers.paragraphs.count > 2 {
                    BodyText(MorningPrayerData.prayers.paragraphs[2])
                }
                
                // 啟應版本選擇器
                Picker("啟應版本", selection: $viewModel.selectedPrayerResponse) {
                    ForEach(PrayerResponseVersion.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
                
                // 動態啟應 (這個是抓 JSON，會自動雙語)
                let responses = viewModel.selectedPrayerResponse == .bcp1932
                ? MorningPrayerData.prayersResponsesBCP1932
                : MorningPrayerData.prayersResponsesNew
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(responses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                }
            }
        }
    }
    
    private var collectsSection: some View {
        let isTrad = viewModel.appLanguage == .traditional
        
        return VStack(alignment: .leading, spacing: 12) {
            
            // 1. 本日祝文與紀念祝文（合併於同一個卡片中）
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    // 🌟 整個區塊的唯一大標題與禮規（從 JSON 讀取）
                    if let title = MorningPrayerData.collects[0].title {
                        SectionTitle(text: title)
                    }
                    if let rubric = MorningPrayerData.collects[0].rubric {
                        RubricBlock(text: rubric)
                    }
                    
                    // 🌟 祝文前啟應（支援雙語）
                    VStack(alignment: .leading, spacing: 10) {
                        ResponsoryRow(response: Responsory(
                            leader: isTrad ? "願主與你們同在。" : "愿主与你们同在。",
                            people: isTrad ? "願主與你的心靈同在。" : "愿主与你的心灵同在。"
                        ))
                        
                        // 🌟 居中：我們要禱告
                        Text(isTrad ? "我們要禱告。" : "我们要祷告。")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 6)
                        
                    
                    // 🌟 載入主祝文
                    if let mainCollect = viewModel.collectOfTheDay {
                        Text(mainCollect.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(LiturgyColors.crimson)
                            .padding(.top, 2)
                        
                        BodyText(mainCollect.text)
                    } else {
                        PlaceholderBlock(text: viewModel.appLanguage == .traditional ? "按當日節期誦唸" : "按当日节期诵念")
                    }
                    
                    // ═════ 1. JSON 文件內建紀念（緊接主祝文之後）═════
                    ForEach(viewModel.fileCommemorations.indices, id: \.self) { index in
                        commemorationBlock(viewModel.fileCommemorations[index])
                    }

                    // ═════ 2. 其他紀念（來自禮儀引擎 liturgy.commemorations）═════
                    ForEach(viewModel.commemorationCollects.indices, id: \.self) { index in
                        commemorationBlock(viewModel.commemorationCollects[index])
                    }
                    
                    // 🌟 新增：聖靈降臨八日慶期每日附加祝文
                    if viewModel.shouldShowPentecostOctaveAppendix {
                        Divider().padding(.vertical, 4)
                        
                        Text(viewModel.pentecostOctaveAppendixCollect.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(LiturgyColors.crimson)
                            .padding(.top, 2)
                        
                        BodyText(viewModel.pentecostOctaveAppendixCollect.text)
                    }
                }
            }
            
            // 2. 求安祝文 & 求恩祝文（固定的平日祝文，維持獨立卡片）
            if MorningPrayerData.collects.count >= 3 {
                LiturgyCard {
                    PrayerSectionContent(section: MorningPrayerData.collects[1])
                }
                LiturgyCard {
                    PrayerSectionContent(section: MorningPrayerData.collects[2])
                }
            }
        }
    }
    private var generalPrayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 🌟 修正：直接迭代 PrayerSection 元素本身，而不是 .indices
            ForEach(MorningPrayerData.generalPrayers, id: \.self) { prayerSection in
                LiturgyCard {
                    PrayerSectionContent(section: prayerSection)
                }
            }
        }
    }
    
    
    // MARK: - 季節對經與聖母對經區塊
    private var memorialAntiphonsSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                let sectionTitleText = viewModel.appLanguage == .traditional ? "紀念對經" : "纪念对经"
                let introRubricText = viewModel.appLanguage == .traditional ? "¶ 季節對經或聖母對經在規定的祝文之後誦讀。" : "¶ 季节对经或圣母对经在规定的祝文之后诵读。"
                
                SectionTitle(text: sectionTitleText)
                RubricBlock(text: introRubricText)
                
                // 🌟 選擇按鈕：季節對經、聖母對經、省略
                Picker("選擇對經", selection: $viewModel.memorialAntiphonSelection) {
                    ForEach(MemorialAntiphonSelection.allCases, id: \.self) { option in
                        let localizedText = viewModel.appLanguage == .traditional ? option.rawValue : option.rawValue.replacingOccurrences(of: "節", with: "节").replacingOccurrences(of: "經", with: "经").replacingOccurrences(of: "聖", with: "圣")
                        Text(localizedText).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
                
                // 🌟 顯示邏輯
                if viewModel.memorialAntiphonSelection == .seasonal {
                    if let content = viewModel.currentSeasonalContent {
                        RubricBlock(text: content.rubric)
                        
                        Text("對經：\(content.antiphon)")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                            .padding(.vertical, 2)
                        
                        ResponsoryRow(response: Responsory(leader: content.versicle, people: content.response))
                        
                        Text(viewModel.appLanguage == .traditional ? "我們要禱告。" : "我们要祷告。")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                        
                        BodyText(content.prayer)
                    } else {
                        PlaceholderBlock(text: viewModel.appLanguage == .traditional ? "本日無指定的季節對經。" : "本日无指定的季节对经。")
                    }
                } else if viewModel.memorialAntiphonSelection == .marian {
                    if let content = viewModel.currentMarianContent {
                        if let title = content.title {
                            Text(title)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(LiturgyColors.crimson)
                        }
                        RubricBlock(text: content.rubric)
                        
                        BodyText(content.antiphon)
                        
                        ResponsoryRow(response: Responsory(leader: content.versicle, people: content.response))
                        
                        Text(viewModel.appLanguage == .traditional ? "我們要禱告。" : "我们要祷告。")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                        
                        BodyText(content.prayer)
                    } else {
                        PlaceholderBlock(text: viewModel.appLanguage == .traditional ? "本日無指定的聖母對經。" : "本日无指定的圣母对经。")
                    }
                }
            }
        }
    }
        
    // MARK: - 其他禱文選擇器（求恩祝文後）
    private var generalPrayerSelectorSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.appLanguage == .traditional ? "其他禱文" : "其他祷文")
                RubricBlock(text: viewModel.appLanguage == .traditional ? "¶ 此處可選擇誦唸以下禱文，或總禱文，或完全省略。" : "¶ 此处可选择诵念以下祷文，或总祷文，或完全省略。")
                
                Picker("禱文選擇", selection: $viewModel.generalPrayerOption) {
                    ForEach(GeneralPrayerOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 2)
            }
        }
    }
    
    
        
    // MARK: - 根據選擇顯示原禱文、總禱文或省略
    private var generalPrayersOrLitanySection: some View {
        Group {
            switch viewModel.generalPrayerOption {
            case .prayers:
                generalPrayersSection
            case .litany:
                litanySection
            case .omit:
                EmptyView()
            }
        }
    }
        
        // MARK: - 總禱文（內嵌於早禱，不另開頁面）
    // MARK: - 總禱文（內嵌於早禱，不另開頁面）
        @ViewBuilder
        private var litanySection: some View {
            if let data = litanyLoader.uiData {
                // 讀取當前的繁簡狀態
                let lang = viewModel.appLanguage
                
                VStack(alignment: .leading, spacing: 12) {
                    // 1. 總禱文主體
                    LiturgyCard {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionTitle(text: data.title.text(for: lang))
                            RubricBlock(text: data.mainRubric.text(for: lang))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(data.mainResponses) { response in
                                    litanyResponseRow(response: response, lang: lang)
                                }
                            }
                        }
                    }
                    
                    // 2. 主禱文
                    LiturgyCard {
                        VStack(alignment: .leading, spacing: 14) {
                            if let title = data.lordPrayer.title?.text(for: lang) {
                                SectionTitle(text: title)
                            }
                            if let rubric = data.lordPrayer.rubric?.text(for: lang) {
                                RubricBlock(text: rubric)
                            }
                            ForEach(data.lordPrayer.paragraphs, id: \.self) { p in
                                BodyText(p.text(for: lang))
                            }
                            RubricBlock(text: data.lordPrayerNote.text(for: lang))
                        }
                    }
                    
                    // 3. 中間啟應
                    LiturgyCard {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(data.intermediateResponses) { response in
                                litanyResponseRow(response: response, lang: lang)
                            }
                        }
                    }
                    
                    // 4. 中間禱文
                    LiturgyCard {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(data.intermediatePrayer.paragraphs, id: \.self) { p in
                                BodyText(p.text(for: lang))
                            }
                        }
                    }
                    
                    // 5. 誦唸段落
                    ForEach(data.middleRecitations) { recitation in
                        LiturgyCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recitation.rubric.text(for: lang))
                                    .font(.system(size: 15, weight: .regular))
                                    .italic()
                                    .foregroundColor(.red)
                                BodyText(recitation.text.text(for: lang))
                            }
                        }
                    }
                    
                    // 6. 結尾啟應
                    LiturgyCard {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(data.closingResponses) { response in
                                litanyResponseRow(response: response, lang: lang)
                            }
                        }
                    }
                    
                    // 7. 結尾禱文
                    LiturgyCard {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(data.closingPrayer.paragraphs, id: \.self) { p in
                                BodyText(p.text(for: lang))
                            }
                        }
                    }
                    
                    // 8. 最後禮規
                    LiturgyCard {
                        RubricBlock(text: data.finalRubric.text(for: lang))
                    }
                }
            } else {
                // 資料尚未準備好時顯示載入中
                HStack {
                    Spacer()
                    ProgressView("載入總禱文...")
                        .padding(.vertical, 20)
                    Spacer()
                }
                .onAppear {
                    litanyLoader.loadData()
                }
            }
        }
        
    // MARK: - 總禱文啟應行（採用早禱統一設計：圓圈啟應）
        private func litanyResponseRow(response: UILitanyResponsory, lang: AppLanguage) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                
                // 🌟 獲取文字並清理多餘的空白與前綴（避免正文前帶有空格）
                let leaderText = response.leader.text(for: lang)
                    .replacingOccurrences(of: "啟：", with: "")
                    .replacingOccurrences(of: "启：", with: "")
                    .trimmingCharacters(in: .whitespaces)
                
                if !leaderText.isEmpty {
                    // 🌟 spacing: 8 讓圓圈與文字保持緊湊，沒有多餘空格
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(lang == .traditional ? "啟" : "启")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(LiturgyColors.crimson)
                            .frame(width: 22, height: 22)
                            .overlay(Circle().stroke(LiturgyColors.crimson, lineWidth: 1.5))
                        
                        Text(leaderText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
                
                let peopleText = response.people.text(for: lang)
                    .replacingOccurrences(of: "應：", with: "")
                    .replacingOccurrences(of: "应：", with: "")
                    .trimmingCharacters(in: .whitespaces)
                
                if !peopleText.isEmpty {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(lang == .traditional ? "應" : "应")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(LiturgyColors.crimson)
                            .frame(width: 22, height: 22)
                            .overlay(Circle().stroke(LiturgyColors.crimson, lineWidth: 1.5))
                        
                        Text(peopleText)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 2)
        }
        
        // MARK: - 紀念祝文統一渲染
        @ViewBuilder
        private func commemorationBlock(_ block: MorningPrayerViewModel.CommemorationCollectBlock) -> some View {
            VStack(alignment: .leading, spacing: 14) {
                Divider().padding(.vertical, 4)
                
                Text((viewModel.appLanguage == .traditional ? "紀念" : "纪念") + block.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(LiturgyColors.crimson)
                
                if block.antiphon != nil || block.versicle != nil {
                    if let antiphon = block.antiphon {
                        AntiphonRow(text: antiphon)
                            .padding(.top, 4)
                    }
                    
                    if let versicle = block.versicle {
                        ResponsoryRow(response: Responsory(
                            leader: (viewModel.appLanguage == .traditional ? "啟：" : "启：") + versicle.leader,
                            people: (viewModel.appLanguage == .traditional ? "應：" : "应：") + versicle.people
                        ))
                        .padding(.bottom, 4)
                    }
                    
                    Text(viewModel.appLanguage == .traditional ? "我們要禱告。" : "我们要祷告。")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                }
                
                BodyText(block.collect.text)
            }
        }
        
    private var endingSection: some View {
        VStack(spacing: 0) {
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    RubricBlock(text: viewModel.appLanguage == .traditional ? "¶ 以下文結束日課：" : "¶ 以下文结束日课：")
                    
                    VStack(alignment: .leading, spacing: 10) {
                        // 🌟 修正：直接迭代 Responsory 元素本身，而不是 .indices
                        ForEach(MorningPrayerData.endingResponses, id: \.self) { response in
                            ResponsoryRow(response: response)
                        }
                    }
                    Divider().padding(.vertical, 8)
                    
                    if let title = MorningPrayerData.ending.title {
                        SectionTitle(text: title)
                    }
                    ForEach(MorningPrayerData.ending.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                    
                    SectionTitle(text: viewModel.appLanguage == .traditional ? "聖帕特里克鎧甲歌" : "圣帕特里克铠甲歌")
                    Picker("聖帕特里克鎧甲歌", selection: $viewModel.stPatrickOption) {
                        ForEach(StPatrickOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)
                    
                    if viewModel.stPatrickOption == .recite {
                        ForEach(MorningPrayerData.stPatrickBreastplate, id: \.self) { paragraph in
                            BodyText(paragraph)
                        }
                    }
                    
                    if let rubric = MorningPrayerData.ending.rubric {
                        Text(rubric)
                            .font(.system(size: 15, weight: .regular))
                            .italic()
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                    }
                }
            }
            Text(viewModel.appLanguage == .traditional ? "❦ 早禱至此結束。" : "❦ 早祷至此结束。")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)

            Spacer().frame(height: 32)
        }
    }
}

// MARK: - iOS 原生風格卡片容器
struct LiturgyCard<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(.vertical, 12) // 🌟 只保留上下的呼吸空間，刪除背景與圓角
    }
}

// MARK: - 內容渲染組件
struct PrayerSectionContent: View {
    let section: PrayerSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let title = section.title {
                SectionTitle(text: title)
            }
            if let rubric = section.rubric {
                RubricBlock(text: rubric)
            }
            ForEach(section.paragraphs, id: \.self) { p in
                BodyText(p)
            }
            // 💡 改為直接迭代 responses 元素
            ForEach(section.responses, id: \.self) { response in
                ResponsoryRow(response: response)
            }
        }
    }
}

struct SectionTitle: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(LiturgyColors.crimson)
            .padding(.bottom, 2)
    }
}

struct RubricBlock: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .regular))
            .italic()
            .foregroundColor(.red)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BodyText: View {
    let text: String
    init(_ text: String) { self.text = text }
    
    var body: some View {
        Text(styledText(text))
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    // MARK: - 動態文字排版與上色
    private func styledText(_ string: String) -> AttributedString {
        var attrStr = AttributedString(string)
        
        // 基礎樣式：17pt 黑色 襯線體
        attrStr.font = .system(size: 17, weight: .regular)
        attrStr.foregroundColor = .primary
        
        // 1. 單一詞彙上色（同時支援繁簡）
        let redKeywords = [
            "【美國總統】", "【美国总统】",
            "¶ 或唸此文：", "¶ 或念此文："
        ]
        
        for keyword in redKeywords {
            if let range = attrStr.range(of: keyword) {
                attrStr[range].foregroundColor = .red
            }
        }
        
        // 2. 為普天下人禱文中的代禱句（同時支援繁簡）
        let prayerTargets = [
            ("【且特為請我們禱告的某某。若無人請禱，則不讀此句。】", "且特為請我們禱告的某某。"),
            ("【且特为请我们祷告的某某。若无人请祷，则不读此句。】", "且特为请我们祷告的某某。")
        ]
        
        for (full, black) in prayerTargets {
            if let fullRange = attrStr.range(of: full) {
                // 先將整句變為紅色
                attrStr[fullRange].foregroundColor = .red
                
                // 再把實際要唸出來的正文覆蓋回黑色
                if let blackRange = attrStr.range(of: black) {
                    attrStr[blackRange].foregroundColor = .primary
                }
            }
        }
        
        // 3. 總謝文中的感恩句（同時支援繁簡）
        let thanksTargets = [
            ("【且賜與受過主恩，要讚美主感謝主的某某。若無人請謝，則不讀此句。】", "且賜與受過主恩，要讚美主感謝主的某某。"),
            ("【且赐与受过主恩，要赞美主感谢主的某某。若无人请谢，则不读此句。】", "且赐与受过主恩，要赞美主感谢主的某某。")
        ]
        
        for (full, black) in thanksTargets {
            if let fullRange = attrStr.range(of: full) {
                // 先將整句變為紅色
                attrStr[fullRange].foregroundColor = .red
                
                // 再把實際要唸出來的正文覆蓋回黑色
                if let blackRange = attrStr.range(of: black) {
                    attrStr[blackRange].foregroundColor = .primary
                }
            }
        }
        
        // 4. 經文出處縮小並上紅（同時支援繁簡）
        let bibleRefs = ["（哥林多後書13:14）", "（哥林多后书13:14）"]
        for ref in bibleRefs {
            if let range = attrStr.range(of: ref) {
                attrStr[range].foregroundColor = .red
                attrStr[range].font = .system(size: 14, weight: .regular)
            }
        }
        
        return attrStr
    }
}

struct ResponsoryRow: View {
    let response: Responsory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let leaderText = response.leader.replacingOccurrences(of: "啟：", with: "")
            
            // 🌟 只在 leader 非空時顯示啟行
            if !leaderText.isEmpty {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("啟")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(LiturgyColors.crimson)
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(LiturgyColors.crimson, lineWidth: 1.5))
                    Text(leaderText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("應")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(LiturgyColors.crimson)
                    .frame(width: 22, height: 22)
                    .overlay(Circle().stroke(LiturgyColors.crimson, lineWidth: 1.5))
                Text(response.people.replacingOccurrences(of: "應：", with: ""))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .padding(.vertical, 2)
    }
}

struct PlaceholderBlock: View {
    let text: String
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.system(size: 24))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
                Text(text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 28)
            Spacer()
        }
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

// MARK: - 配色
struct LiturgyColors {
    static let parchment = Color(red: 0.97, green: 0.95, blue: 0.91)
    static let ink = Color(red: 0.15, green: 0.12, blue: 0.10)
    static let crimson = Color(red: 0.71, green: 0.03, blue: 0.22)
    static let rubricGray = Color(red: 0.45, green: 0.40, blue: 0.38)
    static let placeholder = Color(red: 0.55, green: 0.50, blue: 0.45)
}


// MARK: - 視圖模型枚舉（移出類外）
enum CreedSelection: String, CaseIterable, Hashable {
    case apostles = "使徒信經"
    case nicene = "尼西亞信經"
    case athanasian = "亞他拿修信經"
}

enum SecondCanticleSelection: String, CaseIterable, Hashable {
    case benedictus = "以色列頌"
    case jubilate = "歡呼頌"
}

enum PrayerResponseVersion: String, CaseIterable, Hashable {
    case bcp1932 = "BCP1932"
    case newTranslation = "新譯"
}

enum PreparatoryPrayerOption: String, CaseIterable, Hashable {
    case include = "日課前祈禱"
    case omit = "省略"
}

enum AbsolutionVersion: String, CaseIterable, Hashable {
    case clergy = "聖品人員"
    case layperson = "平信徒"
}

enum VeniteEndingOption: String, CaseIterable, Hashable {
    case ending1 = "第一式"
    case ending2 = "第二式"
}


// MARK: - 視圖模型
class MorningPrayerViewModel: ObservableObject {
    @Published var currentSeason: LiturgicalSeason = .trinity
    @Published var selectedDate: Date = Date()
    @Published var selectedCreed: CreedSelection =
        OfficePrefs.restore(OfficePrefs.Key.creed, default: .apostles) {
        didSet { OfficePrefs.save(selectedCreed, key: OfficePrefs.Key.creed) }
    }
    @Published var selectedPrayerResponse: PrayerResponseVersion =
        OfficePrefs.restore(OfficePrefs.Key.prayerResponse, default: .bcp1932) {
        didSet { OfficePrefs.save(selectedPrayerResponse, key: OfficePrefs.Key.prayerResponse) }
    }
    @Published var preparatoryOption: PreparatoryPrayerOption =
        OfficePrefs.restore(OfficePrefs.Key.preparatoryOption, default: .include) {
        didSet { OfficePrefs.save(preparatoryOption, key: OfficePrefs.Key.preparatoryOption) }
    }
    @Published var absolutionVersion: AbsolutionVersion =
        OfficePrefs.restore(OfficePrefs.Key.absolutionVersion, default: .clergy) {
        didSet { OfficePrefs.save(absolutionVersion, key: OfficePrefs.Key.absolutionVersion) }
    }
    @Published var veniteEnding: VeniteEndingOption =
        OfficePrefs.restore(OfficePrefs.Key.veniteEnding, default: .ending1) {
        didSet { OfficePrefs.save(veniteEnding, key: OfficePrefs.Key.veniteEnding) }
    }
    @Published var lectionaryYear: String =
        OfficePrefs.restoreString(OfficePrefs.Key.lectionaryYear, default: "1928") {
        didSet {
            OfficePrefs.saveString(lectionaryYear, key: OfficePrefs.Key.lectionaryYear)
            loadReadings()   // ← 保留原有這行
        }
    }
    // 🌟 新增：聖日第一頌歌選擇
    @Published var selectedHolyDayCanticle: CanticleType = {
        let saved = UserDefaults.standard.string(forKey: "holyDayCanticle") ?? CanticleType.teDeum.rawValue
        return CanticleType(rawValue: saved) ?? .teDeum
    }() {
        didSet {
            UserDefaults.standard.set(selectedHolyDayCanticle.rawValue, forKey: "holyDayCanticle")
        }
    }
    @Published var selectedSecondCanticle: SecondCanticleSelection = {
        let saved = UserDefaults.standard.string(forKey: "selectedSecondCanticle") ?? SecondCanticleSelection.benedictus.rawValue
        return SecondCanticleSelection(rawValue: saved) ?? .benedictus
    }() {
        didSet {
            UserDefaults.standard.set(selectedSecondCanticle.rawValue, forKey: "selectedSecondCanticle")
        }
    }
    @Published var appLanguage: AppLanguage = MorningPrayerDataLoader.shared.currentLanguage {
        didSet {
            // ✅ 統一由 MorningPrayerDataLoader 處理語言切換與級聯快取清理
            MorningPrayerDataLoader.shared.setLanguage(appLanguage)
            loadReadings()
        }
    }
    @Published var availableLectionaryOptions: [String] = ["1928", "1962"]
    @Published var dailyReadings: DailyReadings?
    @Published var morningOTVerses: [BibleVerse] = []
    @Published var morningNTVerses: [BibleVerse] = []
    @Published var scriptureVersion: String = {
        UserDefaults.standard.string(forKey: "bibleVersion") ?? "CUV"
    }()
    @Published var stPatrickOption: StPatrickOption =
        OfficePrefs.restore(OfficePrefs.Key.stPatrickOption, default: .recite) {
        didSet { OfficePrefs.save(stPatrickOption, key: OfficePrefs.Key.stPatrickOption) }
    }
    @Published var generalPrayerOption: GeneralPrayerOption =
        OfficePrefs.restore(OfficePrefs.Key.generalPrayerOption, default: .prayers) {
        didSet { OfficePrefs.save(generalPrayerOption, key: OfficePrefs.Key.generalPrayerOption) }
    }
    @Published var selectedPsalmLectionary: String =
        OfficePrefs.restoreString(OfficePrefs.Key.psalmLectionary, default: "monthly") {
        didSet { OfficePrefs.saveString(selectedPsalmLectionary, key: OfficePrefs.Key.psalmLectionary) }
    }
    @Published var availablePsalmLectionaryOptions: [String] = []
    @Published var selected1943SetId: String?
    @Published var available1943Sets: [DailyOfficeFile.OfficePeriod.LectionarySet] = []
    
    // MARK: - 季節與聖母對經狀態
    @Published var memorialAntiphonSelection: MemorialAntiphonSelection = .omit
    @Published var currentSeasonalContent: AntiphonContent?
    @Published var currentMarianContent: AntiphonContent?
    
    init() {
        syncCreedSelection()
    }
    
    /// 當日聖人小傳（早禱）
    var biography: BiographyJSON? {
        DailyOfficeLoader.shared.biography(for: selectedDate, liturgy: liturgy, isEvening: false)
    }

    /// 是否有聖人小傳可顯示
    var hasBiography: Bool {
        guard let bio = biography else { return false }
        return !bio.paragraphs.isEmpty
    }
    
    /// 是否使用平日通用對經（無專用對經時才回退到平日）
    var isUsingGenericInvitatory: Bool {
        DailyOfficeLoader.shared.invitatoryText(for: selectedDate, liturgy: liturgy) == nil
    }

    /// 是否應顯示「禮拜一對經不重复」提示
    var shouldShowInvitatoryMondayNote: Bool {
        isInvitatoryMonday && isUsingGenericInvitatory
    }
    
    
    /// 是否應顯示聖靈降臨八日慶期每日附加祝文
    var shouldShowPentecostOctaveAppendix: Bool {
        let titles: Set<String> = [
            "聖靈降臨後一日",
            "聖靈降臨後二日",
            "聖靈降臨八日慶期內夏季齋期禮拜三",
            "聖靈降臨八日慶期內禮拜四",
            "聖靈降臨八日慶期內夏季齋期禮拜五",
            "聖靈降臨八日慶期內夏季齋期禮拜六"
        ]
        return titles.contains(liturgy.mainTitle)
    }

    /// 聖靈降臨八日慶期附加祝文
    var pentecostOctaveAppendixCollect: DailyOfficeFile.OfficePeriod.CollectJSON {
        .init(
            title: "聖靈降臨八日慶期每日祝文",
            text: "全能最慈悲的上帝，我們懇求主，使我們靠著住在我們裡面的聖靈，得蒙啓發，加增力量服事主。這都是靠著我主耶穌基督。主和聖父、聖靈，惟一上帝，一同永生，一同掌權，世世無盡。阿們。"
        )
    }
    
    var psalmAntiphons: [String]? {
        DailyOfficeLoader.shared.psalmAntiphons(for: selectedDate, liturgy: liturgy)
    }
    
    var liturgy: DailyLiturgy {
        LiturgyCoreService.shared.resolve(for: selectedDate)
    }
    
    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        f.locale = Locale(identifier: "zh_Hant")
        return f.string(from: selectedDate)
    }
    
    var commonName: String? {
        let map: [String: String] = [
            "復活後第五主日": "特禱主日",
            "復活後第一主日": "卸白衣主日"
        ]
        return map[liturgy.mainTitle]
    }
    var bibleSentences: [BibleSentenceJSON] {
        // 🌟 強制：三一主日後第一、第二主日使用平日選句，不受基督聖體節／聖心節專日 JSON 覆蓋
        let isCorpusChristiSunday = liturgy.mainTitle.contains("三一主日後第一主日")
        let isSacredHeartSunday   = liturgy.mainTitle.contains("三一主日後第二主日")
        let forceOrdinary = isCorpusChristiSunday || isSacredHeartSunday
        
        // 1. 優先：本日專用 JSON（強制平日時跳過）
        if !forceOrdinary, let special = DailyOfficeLoader.shared.bibleSentences(for: selectedDate, liturgy: liturgy, isEvening: false) {
            return special
        }
        
        // 2. 回退：節期 / 平日通用
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        
        // 🌟 升天後主日：強制使用升天期選句，絕不回退到平日
        if liturgy.mainTitle == "升天後主日" {
            let ascension = BibleSentencesLoader.shared.sentences(for: .ascension, title: liturgy.mainTitle)
            if !ascension.isEmpty { return ascension }
            
            let easter = BibleSentencesLoader.shared.sentences(for: .easter, title: "復活後第七主日")
            if !easter.isEmpty { return easter }
            
            return BibleSentencesLoader.shared.sentences(for: .easter, title: "主日")
        }
        
        return BibleSentencesLoader.shared.sentences(for: info.season, title: liturgy.mainTitle, language: appLanguage)
    }
    
    
    var invitatoryText: String {
        // 1. 優先：讀取專日文件（聖日 / 節期特定日 / 常規週間日 / 主日）
        if let special = DailyOfficeLoader.shared.invitatoryText(for: selectedDate, liturgy: liturgy) {
            return special
        }
        
        // 2. 回退：平日通用選句（禮拜一至六）
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        let index = (weekday + 5) % 7 // 0=禮拜一 ... 5=禮拜六
        
        if index < 6 {
            return MorningPrayerData.invitatory.weekdayTexts[index]
        }
        
        // 3. 主日若無專用 JSON（理論上不應發生），回退第一組平日選句
        return MorningPrayerData.invitatory.weekdayTexts[0]
    }
    
    var isInvitatoryMonday: Bool {
        Calendar.current.component(.weekday, from: selectedDate) == 2
    }

    // 🌟 定義視圖專用的聖詩顯示結構
    struct OfficeHymnDisplay {
        let title: String
        let latinTitle: String
        let seasonNote: String?
        let verses: [String]
        let versicle: DailyOfficeFile.OfficePeriod.VersicleJSON?
    }

    /// 當日應誦邀請聖詩（皆來頌後、詩篇前）
    var invitatoryHymn: InvitatoryHymnData {
        // 1. 優先讀取專日/節期文件 (DailyOfficeLoader - 已經支援雙語)
        if let special = DailyOfficeLoader.shared.invitatoryHymn(for: selectedDate, liturgy: liturgy) {
            return InvitatoryHymnData(
                title: special.title ?? "",
                seasonNote: nil,
                verses: special.verses ?? []
            )
        }
        
        // 2. 回退常規邀請聖詩 (MorningPrayerDataLoader 雙語)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        let type: InvitatoryHymnType
        
        if weekday == 1 {
            let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
            if info.season == .trinity || info.season == .pentecost {
                type = .sundaySummer
            } else {
                type = .sundayWinter
            }
        } else {
            // 平日：Calendar.weekday (1=日, 2=一 ... 7=六)
            type = .weekday(weekday - 1)
        }
        return MorningPrayerDataLoader.shared.invitatoryHymn(for: type, language: appLanguage)
    }

    /// 日課聖詩（第二經課後、第二頌歌前）
    var officeHymn: OfficeHymnDisplay {
        // 1. 優先讀取專日/節期文件 (DailyOfficeLoader - 已經支援雙語)
        if let special = DailyOfficeLoader.shared.officeHymn(for: selectedDate, liturgy: liturgy) {
            return OfficeHymnDisplay(
                title: "", // 專日文件通常沒有雙標題，主標題留空
                latinTitle: special.title ?? "", // 借用 latinTitle 欄位渲染成紅色居中標題
                seasonNote: nil,
                verses: special.verses ?? [],
                versicle: special.versicle
            )
        }
        
        // 2. 回退常規日課聖詩 (MorningPrayerDataLoader 雙語)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        let fallbackType: MorningOfficeHymnType
        
        if weekday == 1 { // 主日
            let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
            if info.season == .trinity || info.season == .pentecost {
                fallbackType = .sundayTrinity
            } else {
                fallbackType = .sundayEpiphany
            }
        } else {
            // 平日：Calendar.weekday (1=日, 2=一 ... 7=六)
            fallbackType = .weekday(weekday - 1)
        }
        
        if let baseHymn = MorningPrayerDataLoader.shared.officeHymn(for: fallbackType, language: appLanguage) {
            let v = baseHymn.versicle.map { DailyOfficeFile.OfficePeriod.VersicleJSON(leader: $0.leader, people: $0.people) }
            return OfficeHymnDisplay(
                title: baseHymn.title,
                latinTitle: baseHymn.latinTitle,
                seasonNote: baseHymn.seasonNote,
                verses: baseHymn.verses,
                versicle: v
            )
        }
        
        // 兜底防護
        return OfficeHymnDisplay(title: "", latinTitle: "", seasonNote: nil, verses: [], versicle: nil)
    }
    
    // 👇 這兩個保留不變
    var morningPsalms: [(title: String, content: PsalmContent)] {
        PsalmsLoader.shared.morningPsalms(for: selectedDate)
    }
    
    /// 當日應誦的第一頌歌類型
    var firstCanticleType: CanticleType {
        let baseType = LiturgyCoreService.shared.firstCanticleType(for: selectedDate)
        // 🌟 若原定為讚美頌 (Te Deum，即聖日)，允許用戶自選摩西頌或安波羅修頌
        if baseType == .teDeum {
            return selectedHolyDayCanticle
        }
        return baseType
    }
    
    /// 當日第一頌歌數據（供視圖直接使用）
    var firstCanticle: CanticleData {
        // 🌟 透過 Loader 動態獲取當前選擇與語言版本的頌歌
        CanticleLoader.shared.canticle(for: firstCanticleType)
    }
    

    // ═══════════════════════════════════════════════════════
    // 🌟 2. 將這段動態計算邏輯貼在 ViewModel 內部的這個位置
    // ═══════════════════════════════════════════════════════
    
    /// 當日第二頌歌數據（支援以色列頌與歡呼頌切換）
    var secondCanticleData: CanticleData {
        switch selectedSecondCanticle {
        case .benedictus:
            return CanticleLoader.shared.canticle(for: CanticleType.benedictus)
        case .jubilate:
            return CanticleLoader.shared.canticle(for: CanticleType(rawValue: "jubilateDeo") ?? CanticleType.benedictus)
        }
    }
    
    /// 第二頌歌對經與註解（僅以色列頌適用，歡呼頌則為 nil）
    var secondCanticleAntiphon: String? {
        guard selectedSecondCanticle == .benedictus else { return nil }
        if let special = DailyOfficeLoader.shared.benedictusAntiphon(for: selectedDate, liturgy: liturgy),
           !special.isEmpty {
            return special
        }
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        return CanticleLoader.shared.benedictusWeekdayAntiphon(for: weekday)
    }
    
    var secondCanticleAntiphonNote: String? {
        guard selectedSecondCanticle == .benedictus else { return nil }
        return DailyOfficeLoader.shared.benedictusAntiphonNote(for: selectedDate, liturgy: liturgy)
    }
    
    func loadReadings() {
        scriptureVersion = UserDefaults.standard.string(forKey: "bibleVersion") ?? "CUV"
        
        // 🌟 1943 年經課改由獨立服務處理：
        // 先看本日 JSON 是否有真正專用 override，沒有則回退到 1943 節期經課表。
        available1943Sets = DailyOffice1943LectionaryService.shared.officeSets(
            for: selectedDate,
            liturgy: liturgy,
            isEvening: false
        )
        
        if selected1943SetId == nil ||
           !available1943Sets.contains(where: { $0.id == selected1943SetId }) {
            selected1943SetId = available1943Sets.first?.id
        }
        
        // 🌟 查詢 JSON 有哪些版本（僅用於 Picker 顯示）
        let jsonOptions = DailyOfficeLoader.shared.availableLectionaryOptions(
            for: selectedDate,
            liturgy: liturgy,
            isEvening: false
        )
        
        // 只要 JSON 未提供經課，或僅提供單一選項，
        // 一律補上資料庫預設的 1928 與 1962，確保按鈕不會消失。
        var options = Set(jsonOptions)
        
        if !available1943Sets.isEmpty {
            options.insert("1943")
        }
        
        let jsonHasLectionary = options.contains("1928") || options.contains("1962")
                             || options.contains("special") || options.contains("1943")
        
        if !jsonHasLectionary || options.count < 2 {
            options.insert("1928")
            options.insert("1962")
        }
        
        availableLectionaryOptions = Array(options).sorted()
        
        if !availableLectionaryOptions.contains(lectionaryYear) {
            let nextYear = availableLectionaryOptions.first ?? "1928"
            if lectionaryYear != nextYear {
                lectionaryYear = nextYear
                return
            }
        }
        
        var psalmOptions = DailyOfficeLoader.shared.availablePsalmLectionaryOptions(
            for: selectedDate,
            liturgy: liturgy,
            isEvening: false
        )
        
        // 🌟 詩篇選擇按鈕堅持全部同時出現：
        // 只要 1943 獨立經課服務找到資料，就把 1943年詩篇 加入詩篇選擇器。
        if !available1943Sets.isEmpty && !psalmOptions.contains("1943") {
            if let index = psalmOptions.firstIndex(of: "1962") {
                psalmOptions.insert("1943", at: index)
            } else {
                psalmOptions.append("1943")
            }
        }

        availablePsalmLectionaryOptions = psalmOptions

        if selectedPsalmLectionary != "monthly",
           !availablePsalmLectionaryOptions.contains(selectedPsalmLectionary) {
            selectedPsalmLectionary = "monthly"
        }
        
        if lectionaryYear == "1943",
           let set = selected1943Set,
           let lessons = set.lessons {
            let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
            
            let morningOT = lessons.ot.map {
                LectionaryDay(
                    season: "json",
                    weekIndex: 0,
                    dayKey: "json-1943-\(set.id)-M-OT",
                    book: $0.book,
                    chapter: $0.chapter
                )
            }
            
            let morningNT = lessons.nt.map {
                LectionaryDay(
                    season: "json",
                    weekIndex: 0,
                    dayKey: "json-1943-\(set.id)-M-NT",
                    book: $0.book,
                    chapter: $0.chapter
                )
            }
            
            dailyReadings = DailyReadings(
                date: selectedDate,
                liturgy: liturgy,
                seasonInfo: info,
                isHolyDay: true,
                morningOT: morningOT,
                morningNT: morningNT,
                eveningOT: nil,
                eveningNT: nil
            )
            loadVerses()
            return
        }
        
        // 🌟 統一由 DailyLectionaryService 處理（JSON 優先 → 資料庫回退）
        dailyReadings = DailyLectionaryService.shared.readings(
            for: selectedDate,
            year: lectionaryYear
        )
        loadVerses()
        loadMemorialAntiphons()
    }
    
    private func loadVerses() {
        morningOTVerses = []
        morningNTVerses = []
        guard let readings = dailyReadings else { return }
        
        scriptureVersion = UserDefaults.standard.string(forKey: "bibleVersion") ?? "CUV"
        
        DispatchQueue.global(qos: .userInitiated).async {
            var ot: [BibleVerse] = []
            var nt: [BibleVerse] = []
            
            if let otDay = readings.morningOT {
                let isApo = LectionaryDatabaseManager.shared.isApocrypha(bookName: otDay.book)
                let version = isApo ? "APO1933" : self.scriptureVersion
                
                let stringVerses = BibleJSONService.shared.fetchVersesList(version: version, book: otDay.book, reference: otDay.chapter)
                ot = stringVerses.map { text in
                    let vStr = text.components(separatedBy: " ").first ?? "0"
                    // 💡 如果你的 BibleVerse 中 verse 是 String 型別，請改為 verse: vStr
                    return BibleVerse(verse: Int(vStr) ?? 0, content: text)
                }
            }
            
            if let ntDay = readings.morningNT {
                let isApo = LectionaryDatabaseManager.shared.isApocrypha(bookName: ntDay.book)
                let version = isApo ? "APO1933" : self.scriptureVersion
                
                let stringVerses = BibleJSONService.shared.fetchVersesList(version: version, book: ntDay.book, reference: ntDay.chapter)
                nt = stringVerses.map { text in
                    let vStr = text.components(separatedBy: " ").first ?? "0"
                    // 💡 如果你的 BibleVerse 中 verse 是 String 型別，請改為 verse: vStr
                    return BibleVerse(verse: Int(vStr) ?? 0, content: text)
                }
            }
            
            DispatchQueue.main.async {
                self.morningOTVerses = ot
                self.morningNTVerses = nt
            }
        }
    }

    var selected1943Set: DailyOfficeFile.OfficePeriod.LectionarySet? {
        if let id = selected1943SetId,
           let selected = available1943Sets.first(where: { $0.id == id }) {
            return selected
        }
        return available1943Sets.first
    }
    
    var selected1943SetPsalms: ProperPsalmDisplay? {
        guard let group = selected1943Set?.psalms else {
            return nil
        }
        
        let psalms = group.items.compactMap { ref in
            PsalmsLoader.shared.psalm(
                number: ref.number,
                verses: ref.verses
            )
        }
        
        guard !psalms.isEmpty else {
            return nil
        }
        
        // 1943 詩篇不再使用 JSON 內的專用對經。
        // 改為與 1928 / 1962 共用當日詩篇對經，但只取第一個，
        // 並按 1943 原本方式：所有詩篇前一次，最後一篇榮耀頌後一次。
        let antiphon = psalmAntiphons?.first
        
        return ProperPsalmDisplay(
            year: "1943",
            psalms: psalms,
            jsonAntiphon: antiphon
        )
    }
    
    var selectedProperPsalms: ProperPsalmDisplay? {
        guard selectedPsalmLectionary != "monthly" else {
            return nil
        }
        
        guard let group = DailyOfficeLoader.shared.jsonPsalms(
            for: selectedDate,
            liturgy: liturgy,
            isEvening: false,
            year: selectedPsalmLectionary
        ) else {
            return nil
        }
        
        let psalms = group.items.compactMap { ref in
            PsalmsLoader.shared.psalm(
                number: ref.number,
                verses: ref.verses
            )
        }
        
        guard !psalms.isEmpty else {
            return nil
        }
        
        let antiphon = group.antiphon ?? group.antiphons?.first
        
        return ProperPsalmDisplay(
            year: selectedPsalmLectionary,
            psalms: psalms,
            jsonAntiphon: antiphon
        )
    }
    
    /// ⬇️ 第二頌歌：固定以色列頌
    var benedictus: CanticleData {
        CanticleLoader.shared.canticle(for: CanticleType.benedictus)
    }
    
    /// 以色列頌對經後的禮規註解（如施洗約翰誕辰日）
    var benedictusAntiphonNote: String? {
        DailyOfficeLoader.shared.benedictusAntiphonNote(for: selectedDate, liturgy: liturgy)
    }
    /// 以色列頌當日對經（平日按星期，主日 nil）
    var benedictusAntiphon: String? {
        // 🌟 1. 優先：讀取專日 JSON
        if let special = DailyOfficeLoader.shared.benedictusAntiphon(for: selectedDate, liturgy: liturgy),
           !special.isEmpty {
            return special
        }
        
        // 2. 回退：通用 canticles.json 的平日對經
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        return CanticleLoader.shared.benedictusWeekdayAntiphon(for: weekday)
    }
    /// 單一通用對經（向後兼容）
    var psalmAntiphon: String? {
        psalmAntiphons?.first
    }

    // MARK: - 祝文區塊資料
        
    /// 獲取本日專用祝文
    var collectOfTheDay: DailyOfficeFile.OfficePeriod.CollectJSON? {
        DailyOfficeLoader.shared.collect(for: selectedDate, liturgy: liturgy)
    }
    
    /// 檔案內建附加紀念（如6月30日之聖彼得）
    var fileCommemorations: [CommemorationCollectBlock] {
        guard let file = DailyOfficeLoader.shared.loadOfficeFile(for: selectedDate, liturgy: liturgy),
              let morning = file.morning,
              let comms = morning.commemorations else { return [] }
        
        return comms.compactMap { comm in
            guard let collect = comm.collect else { return nil }
            let displayName = comm.displayName ?? "紀念"
            let commemorationFile = DailyOfficeLoader.shared.loadCommemoration(name: displayName, date: selectedDate)
            let rank = commemorationFile.map { parseJSONRank($0.rank) } ?? .commemoration
            
            return CommemorationCollectBlock(
                name: displayName,
                displayName: displayName,
                antiphon: comm.antiphon,
                versicle: comm.versicle,
                collect: collect,
                rank: rank
            )
        }
    }
    
    /// 本日祝文區塊內全部紀念，統一按被紀念者等級由高至低排列。
    var allCommemorationCollects: [CommemorationCollectBlock] {
        (fileCommemorations + commemorationCollects).sorted { lhs, rhs in
            if lhs.rank == rhs.rank {
                return lhs.displayName < rhs.displayName
            }
            return lhs.rank > rhs.rank
        }
    }
    
    // MARK: - 祝文區塊資料
    struct CommemorationCollectBlock {
        let name: String
        let displayName: String
        let antiphon: String?
        let versicle: DailyOfficeFile.OfficePeriod.VersicleJSON?
        let collect: DailyOfficeFile.OfficePeriod.CollectJSON
        let rank: LiturgicalRank
    }
    
    /// 獲取並排序當日所有的紀念祝文
        var commemorationCollects: [CommemorationCollectBlock] {
        var blocks: [CommemorationCollectBlock] = []
        
        print("🎯 當日紀念列表：\(liturgy.commemorations)")
        
        for name in liturgy.commemorations {
            print("🔍 查找紀念：\(name)")
            
            var file = DailyOfficeLoader.shared.loadCommemoration(name: name, date: selectedDate)
            print("   loadCommemoration 返回：\(file?.name ?? "nil")")
            
            // 🌟 1. 歸一化：去掉「紀念」前綴
            let normalizedName = name.hasPrefix("紀念")
                ? String(name.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                : name
            
            if let f = file, !DailyOfficeLoader.shared.isMappedCommemoration(normalizedName) {
                // 🌟 2. 繁簡轉換：利用 iOS 原生 API 產生繁體與簡體版本，包容語言切換導致的差異
                let nameHans = name.applyingTransform(StringTransform("Hant-Hans"), reverse: false) ?? name
                let nameHant = name.applyingTransform(StringTransform("Hans-Hant"), reverse: false) ?? name
                let normHans = normalizedName.applyingTransform(StringTransform("Hant-Hans"), reverse: false) ?? normalizedName
                let normHant = normalizedName.applyingTransform(StringTransform("Hans-Hant"), reverse: false) ?? normalizedName
                
                // 只要檔案名稱符合其中一種（繁體原名、簡體原名、繁體去前綴、簡體去前綴），就視為匹配
                let validNames = [name, normalizedName, nameHans, nameHant, normHans, normHant]
                
                if !validNames.contains(f.name) {
                    print("   ⚠️ 名稱不匹配：file.name='\(f.name)' vs 預期名稱集='\(validNames)'，已剔除")
                    file = nil
                }
            }
            
            guard let foundFile = file else {
                print("   ❌ 無有效檔案，跳過")
                continue
            }
            
            // ... (下方的 morning 節點解析、rank 解析、append 邏輯保持完全不變)
            guard let morning = foundFile.morning else {
                print("   ❌ 檔案無 morning 節點")
                continue
            }
            
            guard let collect = morning.collect else {
                print("   ❌ morning 節點無 collect")
                continue
            }
            
            print("   ✅ 找到祝文：\(collect.title)")
            
            // 🌟 判斷是否為望日紀念
            let isVigilCommemoration = name.contains("望日")
            
            // 🌟 對經：與 DailyOfficeLoader 一致，支援 normal / normals 兩種格式
            let antiphon: String? = {
                if isVigilCommemoration {
                    let weekday = Calendar.current.component(.weekday, from: selectedDate)
                    return CanticleLoader.shared.benedictusWeekdayAntiphon(for: weekday)
                }
                if let normals = morning.benedictusAntiphon?.normals, !normals.isEmpty {
                    let year = Calendar.current.component(.year, from: selectedDate)
                    return normals[year % normals.count]
                }
                if let n = morning.benedictusAntiphon?.normal, !n.isEmpty {
                    return n
                }
                return nil
            }()
            
            // ✅ 修改：JSON 無 versicle 時，針對望日與平日進行回退
            let versicle: DailyOfficeFile.OfficePeriod.VersicleJSON? = {
                // 1. 若望日作為紀念，使用當日日課聖詩的啟應
                if isVigilCommemoration {
                    let hymn = LiturgyCoreService.shared.morningOfficeHymn(for: selectedDate)
                    if let v = hymn.versicle {
                        return DailyOfficeFile.OfficePeriod.VersicleJSON(leader: v.leader, people: v.people)
                    }
                    return nil
                }
                
                // 2. 若 JSON 內建有專屬 versicle (如聖日)，優先使用
                if let v = morning.officeHymn?.versicle { return v }
                
                // 3. 缺乏專屬啟應的紀念（如秋季齋期），強制回退使用「當天實際星期幾」的「平日」啟應
                let calendar = Calendar.current
                let weekday = calendar.component(.weekday, from: selectedDate)
                
                // 讀取當天實際日期的「平日」日課聖詩啟應 (平日索引為 weekday - 1)
                if let baseHymn = MorningPrayerDataLoader.shared.officeHymn(for: .weekday(weekday - 1), language: appLanguage),
                   let v = baseHymn.versicle {
                    return DailyOfficeFile.OfficePeriod.VersicleJSON(leader: v.leader, people: v.people)
                }
                
                return nil
            }()
            
            print("   📜 antiphon=\(antiphon ?? "nil"), versicle=\(versicle.map { "\($0.leader)/\($0.people)" } ?? "nil")")
            let rank = parseJSONRank(foundFile.rank)
            
            blocks.append(CommemorationCollectBlock(
                name: foundFile.name,
                displayName: name,
                antiphon: antiphon,
                versicle: versicle,
                collect: collect,
                rank: rank
            ))
        }
        
        return blocks.sorted { $0.rank > $1.rank }
    }
    
    private func displayNameForPsalmLectionaryOption(_ option: String) -> String {
        // 🌟 直接讀取全域語言狀態，避免作用域報錯
        let isTrad = MorningPrayerDataLoader.shared.currentLanguage == .traditional
        switch option {
        case "monthly": return isTrad ? "月度循環" : "月度循环"
        case "1943":    return isTrad ? "1943年詩篇" : "1943年诗篇"
        case "1928":    return isTrad ? "1928年詩篇" : "1928年诗篇"
        case "1962":    return isTrad ? "1962年詩篇" : "1962年诗篇"
        case "special": return isTrad ? "專用詩篇" : "专用诗篇"
        default:        return option
        }
    }
    
    /// 輔助函數：將 JSON 中的 rank 轉換為完整的 LiturgicalRank
    private func parseJSONRank(_ rankString: String?) -> LiturgicalRank {
        // 抓取原始字串（保留大小寫與括號，供兜底使用）
        guard let rawStr = rankString, !rawStr.isEmpty else { return .none }
        
        // 轉為小寫，去除可能的多餘空格，方便比對英文標籤
        let cleanStr = rawStr.lowercased().trimmingCharacters(in: .whitespaces)
        
        // 完整對照 LiturgicalRank.swift 中的所有等級
        switch cleanStr {
        
        // 100 級以上
        case "privilegedferia", "特權大平日": return .privilegedFeria
            
        // 10 級以上：一等
        case "privilegedvigilfirstclass", "一等特權望日，半複式", "一等特權望日": return .privilegedVigilFirstClass
        case "sundayfirstclassgreat", "一等主日，大複式": return .sundayFirstClassGreat
        case "sundayfirstclass", "一等主日，半複式", "一等主日": return .sundayFirstClass
        case "doublefirstclass", "一等複式": return .doubleFirstClass
            
        // 8 - 9 級：二等
        case "sundaysecondclass", "二等主日，半複式", "二等主日": return .sundaySecondClass
        case "doublesecondclass", "二等複式": return .doubleSecondClass
            
        // 7 級：普通主日與特殊特權
        case "privilegedoctavefirstclass", "一等特權八日慶期，半複式", "一等特權八日慶期": return .privilegedOctaveFirstClass
        case "privilegedoctavesecondclassgreat", "二等特權八日慶期，大複式": return .privilegedOctaveSecondClassGreat
        case "privilegedoctavesecondclass", "二等特權八日慶期，半複式": return .privilegedOctaveSecondClass
        case "privilegedvigilsecondclass", "二等特權望日，半複式", "二等特權望日": return .privilegedVigilSecondClass
        case "privilegedoctavethirdclass", "三等特權八日慶期，半複式", "三等特權八日慶期": return .privilegedOctaveThirdClass
        case "privilegedoctavethirdclassgreat", "三等特權八日慶期，大複式": return .privilegedOctaveThirdClassGreat
        case "ordinaryoctavegreaterdouble", "普通八日慶期，大複式": return .ordinaryOctavegreaterDouble
        case "ordinaryoctavesemidouble", "普通八日慶期，半複式", "普通八日慶期": return .ordinaryOctavesemiDouble
        case "ordinarysunday", "普通主日，半複式", "普通主日": return .ordinarySunday
        case "greaterdouble", "大複式": return .greaterDouble
        case "double", "複式": return .double
        case "semidouble", "半複式": return .semiDouble
        
        // 5 - 6 級：平日與紀念
        case "greaterferia", "非特權大平日": return .greaterFeria
        case "simple", "簡式": return .simple
        case "commemoration", "紀念": return .commemoration
        case "vigil", "望日": return .vigil
        case "feria", "普通平日": return .feria
            
        default:
            // 🌟 雙重保險兜底：
            // 如果 JSON 裡面的寫法剛好是舊資料帶有全形括號，例如 "（大複式）"
            // 就直接呼叫你寫在 LiturgicalRank.swift 裡的舊版相容解析器
            let fallbackRank = LiturgicalRank.parse(from: rawStr)
            return fallbackRank != .none ? fallbackRank : .none
        }
    }
    
    private func syncCreedSelection() {
        if CreedsDataLoader.shouldShowAthanasianCreed(for: selectedDate) {
            selectedCreed = .athanasian
        } else {
            selectedCreed = .apostles
        }
    }

    // MARK: - 日期跳轉邏輯
    func jumpToYesterday() {
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = yesterday
            syncCreedSelection()   // ← 加入
            loadReadings()
        }
    }

    func jumpToToday() {
        selectedDate = Date()
        syncCreedSelection()
        loadReadings()
    }

    func jumpToTomorrow() {
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = tomorrow
            syncCreedSelection()
            loadReadings()
        }
    }
    private func loadVersesFromJSON(bookOT: String, chapterOT: String, bookNT: String, chapterNT: String) {
        morningOTVerses = []
        morningNTVerses = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            let isApoOT = LectionaryDatabaseManager.shared.isApocrypha(bookName: bookOT)
            let versionOT = isApoOT ? "APO1933" : self.scriptureVersion
            let otVerses = LectionaryDatabaseManager.shared.fetchVerses(
                version: versionOT,
                book: bookOT,
                reference: chapterOT
            )
            
            let isApoNT = LectionaryDatabaseManager.shared.isApocrypha(bookName: bookNT)
            let versionNT = isApoNT ? "APO1933" : self.scriptureVersion
            let ntVerses = LectionaryDatabaseManager.shared.fetchVerses(
                version: versionNT,
                book: bookNT,
                reference: chapterNT
            )
            
            DispatchQueue.main.async {
                self.morningOTVerses = otVerses
                self.morningNTVerses = ntVerses
            }
        }
    }
    func loadMemorialAntiphons() {
        guard let container = MemorialAntiphonsLoader.shared.getContainer() else { return }
        
        // 1. 取得當前節期與日期資訊
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        let isSunday = (weekday == 1)
        
        // 判斷是否為繁體
        let isTC = (self.appLanguage == .traditional)
        
        // 2. 判斷季節對經的 Key
        var seasonalKey = "pre_lent" // 預設或七旬期
        var marianKey = "trinity"    // 預設
        
        switch info.season {
        case .advent:
            seasonalKey = isSunday ? "advent_sunday" : "advent_weekday"
            marianKey = "advent"
            
        case .christmas:
            seasonalKey = "epiphany" // 根據您的禮規，聖誕期不念季節對經，或併入顯現期邏輯，此處您可依據JSON內的設定調整
            marianKey = "christmas"
            
        case .epiphany:
            seasonalKey = "epiphany"
            marianKey = "christmas" // 萬福天上母后是從2月2日開始，視您的具體禮規細分
            
        case .lent, .holyWeek:
            seasonalKey = "lent"
            marianKey = "lent"
            
        case .easter, .ascension, .pentecost:
            seasonalKey = "easter"
            marianKey = "easter"
            
        case .trinity:
            seasonalKey = isSunday ? "trinity_sunday" : "trinity_weekday"
            marianKey = "trinity"
            
        default:
            seasonalKey = "pre_lent"
            marianKey = "pre_lent"
        }
        
        // 針對2月2日至設立聖餐日的特例 (萬福天上母后) 可以透過日期進行微調
        // 這裡做一個簡單的月份判斷，您可以依據確切的 LiturgyCoreService 節期進行替換
        let month = Calendar.current.component(.month, from: selectedDate)
        if (month >= 2 && info.season != .easter && info.season != .lent) {
             // 若有需要，可以在此強制將 marianKey 設為 "pre_lent" 對應 ave_regina_caelorum
        }
        
        // 3. 配對季節對經內容
        if let match = container.seasonalAntiphons.first(where: { $0.seasonKeys.contains(seasonalKey) }) {
            currentSeasonalContent = isTC ? match.tc : match.sc
        } else {
            currentSeasonalContent = nil
        }
        
        // 4. 配對聖母對經內容
        if let match = container.marianAntiphons.first(where: { $0.seasonKeys.contains(marianKey) }) {
            currentMarianContent = isTC ? match.tc : match.sc
        } else {
            currentMarianContent = nil
        }
        
        // 5. 預設選項設定 (依您的需求，可預設為省略或季節對經)
        // 此處不強制覆蓋使用者的選擇，除非需要重置
        // self.memorialAntiphonSelection = .omit
    }
}


// MARK: - 預覽
struct MorningPrayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MorningPrayerView()
        }
    }
}
