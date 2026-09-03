import SwiftUI
import Combine

struct EveningPrayerView: View {
    @StateObject private var viewModel: EveningPrayerViewModel
    @StateObject private var litanyLoader = LitanyDataLoader.shared
    @ObservedObject private var languageStore = AppLanguageStore.shared
    @Environment(\.colorScheme) var colorScheme
    let date: Date
    
    init(date: Date = Date()) {
        self.date = date
        let vm = EveningPrayerViewModel()
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
                    phosHilaronSection
                    psalmsSection
                    gloriaInExcelsisSection
                    lessonsSection
                    patristicReadingSection
                    creedSection
                    prayersSection
                    collectsSection
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
        .navigationTitle("晚禱")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: languageStore.language) { _, newLanguage in
            if viewModel.appLanguage != newLanguage {
                viewModel.appLanguage = newLanguage
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
            
            // 🌟 改為晚禱
            // 🌟 改為晚禱（簡式慶節的前夕晚禱顯示為「晚禱」）
            Text(liturgy.isFirstVespers && liturgy.rank != .simple ? "前夕晚禱" : "晚  禱")
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(.primary)
                .tracking(12) // 字間距
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
        f.locale = Locale(identifier: "zh_Hant")
        return f.string(from: date)
    }
    
    // MARK: - 基礎禮儀區塊 (替換為 EveningPrayerData)
    private var openingRubric: some View {
        LiturgyCard { RubricBlock(text: EveningPrayerData.openingRubric) }
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
                SectionTitle(text: viewModel.appLanguage == .traditional ? "聖經選句" : "圣经选句")
                RubricBlock(text: viewModel.appLanguage == .traditional ? "¶ 主禮開始晚禱，要讀一節或數節的「聖經選句」。" : "¶ 主礼开始晚祷，要读一节或数节的「圣经选句」。")
                
                let sentences = viewModel.bibleSentences
                if sentences.isEmpty {
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
    
    private var exhortationSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.appLanguage == .traditional ? "勸眾文" : "劝众文")
                if let rubric = EveningPrayerData.exhortation.rubric { RubricBlock(text: rubric) }
                BodyText(EveningPrayerData.exhortation.paragraphs[0])
                Text(viewModel.appLanguage == .traditional ? "或唸：" : "或念：")
                    .font(.system(size: 15, weight: .regular))
                    .italic()
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                BodyText(EveningPrayerData.exhortation.paragraphs[1])
            }
        }
    }
    
    private var confessionSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.appLanguage == .traditional ? "認罪文" : "认罪文")
                RubricBlock(text: EveningPrayerData.confession.rubricBefore)
                ForEach(EveningPrayerData.confession.version1.paragraphs, id: \.self) { p in
                    BodyText(p)
                }
            }
        }
    }
    
    private var absolutionSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: EveningPrayerData.absolution.title)
                Picker("赦罪文版本", selection: $viewModel.absolutionVersion) {
                    ForEach(AbsolutionVersion.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 2)
                
                if viewModel.absolutionVersion == .clergy {
                    RubricBlock(text: EveningPrayerData.absolution.clergyRubric)
                    ForEach(EveningPrayerData.absolution.clergyParagraphs, id: \.self) { BodyText($0) }
                    RubricBlock(text: EveningPrayerData.absolution.clergyAltRubric)
                    ForEach(EveningPrayerData.absolution.clergyAltParagraphs, id: \.self) { BodyText($0) }
                } else {
                    RubricBlock(text: EveningPrayerData.absolution.laypersonRubric)
                    ForEach(EveningPrayerData.absolution.laypersonParagraphs, id: \.self) { BodyText($0) }
                }
            }
        }
    }
    
    private var lordPrayerSection: some View {
        LiturgyCard { PrayerSectionContent(section: EveningPrayerData.lordPrayer) }
    }
    
    private var responsesSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.appLanguage == .traditional ? "啟應" : "启应")
                ForEach(EveningPrayerData.responses, id: \.self) { response in
                    ResponsoryRow(response: response)
                }
            }
        }
    }
    
    // 🌟 恩光頌區塊
    private var phosHilaronSection: some View {
        LiturgyCard { PrayerSectionContent(section: EveningPrayerData.phosHilaron) }
    }
    
    private func displayNameForPsalmLectionaryOption(_ option: String) -> String {
        switch option {
        case "monthly":
            return "月度循環"
        case "1943":
            return "1943年詩篇"
        case "1928":
            return "1928年詩篇"
        case "1962":
            return "1962年詩篇"
        case "special":
            return "專用詩篇"
        default:
            return option
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
                        psalmsWithCurrentAntiphonLogic(psalms: viewModel.eveningPsalms)
                    }
                case "1928", "1962", "special":
                    if let proper = viewModel.selectedProperPsalms {
                        psalmsWithCurrentAntiphonLogic(psalms: proper.psalms)
                    } else {
                        psalmsWithCurrentAntiphonLogic(psalms: viewModel.eveningPsalms)
                    }
                default:
                    psalmsWithCurrentAntiphonLogic(psalms: viewModel.eveningPsalms)
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
            PlaceholderBlock(text: "按當日節期誦唸")
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
    
    private func properPsalm1943Section(_ proper: ProperPsalmDisplay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            psalms1943AntiphonView(
                psalms: proper.psalms,
                antiphon: proper.jsonAntiphon
            )
        }
    }
    
    private func psalms1943AntiphonView(
        psalms: [(title: String, content: PsalmContent)],
        antiphon: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
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

                    // 第一遍對經：標題之下、第1節之前
                    if let antiphon = antiphon,
                       !antiphon.isEmpty,
                       i == psalms.startIndex {
                        MorningPrayerView.AntiphonRow(text: antiphon)
                    }
                    
                    ForEach(psalm.content.verses, id: \.self) { verse in
                        verseWithNumber(verse)
                    }
                    
                    // 1943：每一篇詩篇後都加榮耀頌
                    VStack(alignment: .leading, spacing: 4) {
                        BodyText("但願榮耀歸於聖父、聖子、聖靈；")
                        BodyText("※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。")
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 6)
                
                if i < psalms.count - 1 {
                    Divider()
                        .padding(.vertical, 4)
                }
            }
            
            if let antiphon = antiphon, !antiphon.isEmpty {
                MorningPrayerView.AntiphonRow(text: antiphon)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - 對經分組演算法（與早禱相同）
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
            let count = isLastAntiphon ? (psalmCount - psalmIndex) : 1
            let endIndex = min(psalmIndex + count, psalmCount)
            let slice = Array(psalms[psalmIndex..<endIndex])
            groups.append((antiphon, slice))
            psalmIndex = endIndex
        }
        
        return groups
    }

    // MARK: - 分組對經詩篇渲染
    private func psalmsGroupedView(
        groups: [(antiphon: String, psalms: [(title: String, content: PsalmContent)])]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(groups.indices, id: \.self) { gIndex in
                let group = groups[gIndex]
                
                ForEach(group.psalms.indices, id: \.self) { pIndex in
                    let psalm = group.psalms[pIndex]
                    let isLastInGroup = pIndex == group.psalms.count - 1
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(psalm.title).foregroundColor(LiturgyColors.crimson)
                            if !psalm.content.latinTitle.isEmpty {
                                Text(psalm.content.latinTitle).italic().foregroundColor(.primary)
                            }
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.bottom, 4)

                        // 第一遍對經：標題之下、第1節之前
                        if pIndex == group.psalms.startIndex {
                            MorningPrayerView.AntiphonRow(text: group.antiphon)
                        }
                        
                        ForEach(psalm.content.verses, id: \.self) { verse in
                            verseWithNumber(verse)
                        }
                        
                        if isLastInGroup {
                            VStack(alignment: .leading, spacing: 4) {
                                BodyText("但願榮耀歸於聖父、聖子、聖靈；")
                                BodyText("※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。")
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.vertical, 6)
                    
                    if !isLastInGroup {
                        Divider().padding(.vertical, 4)
                    }
                }
                
                MorningPrayerView.AntiphonRow(text: group.antiphon)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                
                if gIndex < groups.count - 1 {
                    Divider().padding(.vertical, 8)
                }
            }
        }
    }

    // MARK: - 舊邏輯：每篇自帶對經
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
                        MorningPrayerView.AntiphonRow(text: psalm.content.antiphon)
                    }
                    
                    ForEach(psalm.content.verses, id: \.self) { verse in
                        verseWithNumber(verse)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        BodyText("但願榮耀歸於聖父、聖子、聖靈；")
                        BodyText("※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。")
                    }
                    .padding(.top, 8)
                    
                    if !psalm.content.antiphon.isEmpty {
                        MorningPrayerView.AntiphonRow(text: psalm.content.antiphon)
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
    
    private func verseWithNumber(_ verse: String) -> some View {
        let trimmed = verse.trimmingCharacters(in: .whitespaces)
        var number = ""
        for char in trimmed { if char.isNumber { number.append(char) } else { break } }
        let text = number.isEmpty ? trimmed : String(trimmed.dropFirst(number.count)).trimmingCharacters(in: .whitespaces)
        
        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            if !number.isEmpty {
                Text(number).font(.system(size: 17, weight: .regular)).foregroundColor(.red)
            }
            Text(text).font(.system(size: 17, weight: .regular)).foregroundColor(.primary).lineSpacing(6).fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - 榮歸主頌 (詩篇後)
    private var gloriaInExcelsisSection: some View {
        let data = EveningPrayerData.gloriaInExcelsis
        
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.appLanguage == .traditional ? "榮歸主頌" : "荣归主颂")
                RubricBlock(text: data.rubric)
                
                Picker("榮歸主頌版本", selection: $viewModel.gloriaOption) {
                    ForEach(GloriaInExcelsisOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 2)
                
                if viewModel.gloriaOption == .bcp1932 {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(data.bcp1932, id: \.self) { BodyText($0) }
                    }
                } else if viewModel.gloriaOption == .newTranslation {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(data.newTranslation, id: \.self) { BodyText($0) }
                    }
                } else {
                    Text(viewModel.appLanguage == .traditional ? "（已省略榮歸主頌）" : "（已省略荣归主颂）")
                        .font(.system(size: 15, weight: .regular))
                        .italic()
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
            }
        }
    }
    
    // MARK: - 經課與頌歌區塊
    private var lessonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let firstLessonTitle = viewModel.appLanguage == .traditional ? "第一經課" : "第一经课"
            let secondLessonTitle = viewModel.appLanguage == .traditional ? "第二經課" : "第二经课"
            let firstRubric = viewModel.appLanguage == .traditional ? "¶ 此後要按著週年讀經表，讀第一經課。" : "¶ 此后要按着周年读经表，读第一经课。"
            let secondRubric = viewModel.appLanguage == .traditional ? "¶ 此後，誦讀由《聖經·新約》之中所選的第二經課。" : "¶ 此后，诵读由《圣经·新约》之中所选的第二经课。"
            
            // 🌟 第一經課：展開以加入經課版本與1943經課組的選擇器
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(text: firstLessonTitle)
                    
                    // 🌟 經課提示（Rubric）移至選擇器之上
                    RubricBlock(text: firstRubric)
                    
                    // 🌟 經課版本選擇器
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
                    
                    // 🌟 1943 特屬經課組選擇器
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
                    
                    if let reading = viewModel.eveningOTReading {
                        scriptureContent(reading: reading, verses: viewModel.eveningOTVerses, readingLabel: firstLessonTitle)
                    } else {
                        scripturePlaceholder()
                    }
                }
            }
            
            officeHymnSection
            
            // 🌟 第一頌歌
            canticleBlock(canticle: viewModel.magnificat, antiphon: viewModel.magnificatAntiphon)
            
            // 🌟 第二經課
            lessonBlock(
                title: secondLessonTitle,
                rubric: secondRubric,
                reading: viewModel.eveningNTReading,
                verses: viewModel.eveningNTVerses,
                readingLabel: secondLessonTitle
            )
            
            eveningSecondCanticleBlock
        }
    }
    
    private func displayNameForLectionaryOption(_ option: String) -> String {
        let isTrad = viewModel.appLanguage == .traditional
        switch option {
        case "1943":    return isTrad ? "1943年經課" : "1943年经课"
        case "1928":    return isTrad ? "1928年經課" : "1928年经课"
        case "1962":    return isTrad ? "1962年經課" : "1962年经课"
        case "special": return isTrad ? "專用經課" : "专用经课"
        default:        return option
        }
    }
    
    // MARK: - 晚禱專用：第二頌歌區塊 (含切換器)
    private var eveningSecondCanticleBlock: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                
                // 🌟 新增：西面頌、憐憫頌、心靈頌 選擇器
                Picker("第二頌歌", selection: $viewModel.selectedSecondCanticle) {
                    ForEach(EveningSecondCanticleSelection.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 4)
                
                let canticle = viewModel.secondCanticle
                let antiphon = viewModel.secondCanticleAntiphon
                
                // 標題區
                VStack(alignment: .leading, spacing: 4) {
                    Text(canticle.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(LiturgyColors.crimson)
                    
                    if let subtitle = canticle.subtitle {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                // ═════ 對經（第一遍，頌歌前）═════
                if let antiphon = antiphon {
                    MorningPrayerView.AntiphonRow(text: antiphon)
                        .padding(.bottom, 4)
                }
                
                // ═════ 頌歌內容 ═════
                if canticle.style == "prose", let paragraphs = canticle.paragraphs {
                    ForEach(paragraphs.indices, id: \.self) { i in
                        BodyText(paragraphs[i])
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
                    MorningPrayerView.AntiphonRow(text: antiphon)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    
    private func canticleBlock(canticle: CanticleData, antiphon: String? = nil) -> some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(canticle.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(LiturgyColors.crimson)
                    if let subtitle = canticle.subtitle {
                        Text(subtitle).font(.system(size: 14, weight: .medium)).foregroundColor(.primary)
                    }
                }
                
                if let antiphon = antiphon { MorningPrayerView.AntiphonRow(text: antiphon).padding(.bottom, 4) }
                
                if canticle.style == "prose", let paragraphs = canticle.paragraphs {
                    ForEach(paragraphs.indices, id: \.self) { i in BodyText(paragraphs[i]) }
                } else if canticle.style == "responsive" {
                    if let sections = canticle.sections {
                        ForEach(sections.indices, id: \.self) { sIndex in
                            ForEach(sections[sIndex]) { canticleVerseRow($0) }
                            if sIndex < sections.count - 1 { Spacer().frame(height: 12) }
                        }
                    } else if let verses = canticle.verses {
                        ForEach(verses) { canticleVerseRow($0) }
                    }
                }
                
                if let doxology = canticle.doxology {
                    VStack(alignment: .leading, spacing: 2) { Text(doxology).font(.system(size: 17)).foregroundColor(.primary) }.padding(.top, 8)
                }
                
                if let antiphon = antiphon { MorningPrayerView.AntiphonRow(text: antiphon).padding(.top, 8) }
            }
        }
    }
    
    private func canticleVerseRow(_ verse: CanticleVerse) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verse.call).font(.system(size: 17, weight: .regular)).foregroundColor(.primary)
            Text(verse.response).font(.system(size: 17)).foregroundColor(.primary).lineSpacing(4)
        }
        .padding(.vertical, 2)
    }
    
    private func lessonBlock(title: String, rubric: String, reading: (book: String, chapter: String)?, verses: [BibleVerse], readingLabel: String) -> some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: title)
                RubricBlock(text: rubric)
                if let reading = reading {
                    scriptureContent(reading: reading, verses: verses, readingLabel: readingLabel)
                } else {
                    scripturePlaceholder()
                }
            }
        }
    }
    
    private func scriptureContent(reading: (book: String, chapter: String), verses: [BibleVerse], readingLabel: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(readingLabel)載在\(reading.book)\(reading.chapter)")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
            
            if verses.isEmpty {
                HStack { Spacer(); ProgressView("載入經文...").padding(.vertical, 20); Spacer() }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(verses) { verse in
                        Text(attributedScripture(verse.content)).lineSpacing(6).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            Text("\(readingLabel)讀畢。").font(.system(size: 17, weight: .regular)).foregroundColor(.primary).padding(.top, 8)
            ResponsoryRow(response: Responsory(leader: "啟：求主憐憫。", people: "應：感謝上帝。")).padding(.top, 4)
        }
    }
    
    private func attributedScripture(_ text: String) -> AttributedString {
        var attrStr = AttributedString(text)
        attrStr.font = .system(size: 17)
        attrStr.foregroundColor = .primary
        guard let regex = try? NSRegularExpression(pattern: "(?:^|\\s)(\\d+)(?=\\s)", options: []) else { return attrStr }
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: (text as NSString).length))
        for match in matches {
            if let range = Range(match.range(at: 1), in: attrStr) {
                attrStr[range].font = .system(size: 11, weight: .medium)
                attrStr[range].foregroundColor = .red
                attrStr[range].baselineOffset = 6
            }
        }
        return attrStr
    }
    
    private func scripturePlaceholder() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                Image(systemName: "book.closed").font(.system(size: 22)).foregroundColor(Color(UIColor.tertiaryLabel))
                Text("按當日節期誦唸").font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            Spacer()
        }
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    private var officeHymnSection: some View {
        let hymn = viewModel.officeHymn
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // 🌟 修正：簡體切換
                SectionTitle(text: viewModel.appLanguage == .traditional ? "日課聖詩" : "日课圣诗")
                
                // 🌟 修正：拉丁文靠左對齊
                if !hymn.latinTitle.isEmpty {
                    Text(hymn.latinTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                }
                
                if let note = hymn.seasonNote, !note.isEmpty {
                    Text(note)
                        .font(.system(size: 13, weight: .medium))
                        .italic()
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                }
                
                Divider().padding(.vertical, 4)
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(hymn.verses.enumerated()), id: \.offset) { _, verse in officeHymnVerseRow(verse) }
                }
                if let versicle = hymn.versicle {
                    Divider().padding(.vertical, 4)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 4) {
                            Text(viewModel.appLanguage == .traditional ? "啟：" : "启：").font(.system(size: 16, weight: .medium)).foregroundColor(.red).frame(width: 32, alignment: .leading)
                            Text(versicle.leader).font(.system(size: 16)).fixedSize(horizontal: false, vertical: true)
                        }
                        HStack(alignment: .top, spacing: 4) {
                            Text(viewModel.appLanguage == .traditional ? "應：" : "应：").font(.system(size: 16, weight: .medium)).foregroundColor(.red).frame(width: 32, alignment: .leading)
                            Text(versicle.people).font(.system(size: 16)).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }
    
    private func officeHymnVerseRow(_ verse: String) -> some View {
        let prefix = extractChineseNumberPrefix(verse)
        let lines = String(verse.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces).components(separatedBy: "\n").filter { !$0.isEmpty }
        return HStack(alignment: .top, spacing: 0) {
            Text(prefix).font(.system(size: 17, weight: .medium)).foregroundColor(.red).frame(width: 40, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                ForEach(lines.indices, id: \.self) { i in Text(lines[i]).font(.system(size: 17, weight: .regular)).foregroundColor(.primary).fixedSize(horizontal: false, vertical: true) }
            }
        }.padding(.vertical, 2)
    }
    
    private func extractChineseNumberPrefix(_ text: String) -> String {
        let chineseDigits = "一二三四五六七八九十"
        var prefix = ""
        for char in text { if chineseDigits.contains(char) { prefix.append(char) } else if char == "、" && !prefix.isEmpty { prefix.append(char); return prefix } else { break } }
        return prefix
    }
    
    // MARK: - 教父誦讀（信經之前）
    private var patristicReadingSection: some View {
        Group {
            if let reading = viewModel.patristicReading {
                LiturgyCard {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionTitle(text: viewModel.appLanguage == .traditional ? "教父誦讀" : "教父诵读")
                        RubricBlock(text: viewModel.appLanguage == .traditional ? "¶ 此後，誦讀教父著作選段。" : "¶ 此后，诵读教父著作选段。")
                        
                        // 讀經員行
                        HStack(spacing: 0) {
                            Text(viewModel.appLanguage == .traditional ? "讀經員：" : "读经员：")
                                .foregroundColor(.red)
                            Text(reading.reader)
                                .foregroundColor(.primary)
                        }
                        .font(.system(size: 15))
                        
                        Text(reading.subtitle)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Divider()
                        BodyText(reading.text)
                        Divider().padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 0) {
                                Text(viewModel.appLanguage == .traditional ? "啓：" : "启：")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                                    .frame(width: 32, alignment: .leading)
                                Text(viewModel.appLanguage == .traditional ? "求主憐憫。" : "求主怜悯。")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            HStack(spacing: 0) {
                                Text(viewModel.appLanguage == .traditional ? "應：" : "应：")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                                    .frame(width: 32, alignment: .leading)
                                Text(viewModel.appLanguage == .traditional ? "感謝上帝。" : "感谢上帝。")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
    }
    
    private var creedSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.appLanguage == .traditional ? "信經" : "信经")
                RubricBlock(text: viewModel.appLanguage == .traditional ? "¶ 此後，主禮和會眾站立同唸「使徒信經」。注意，在特定的日子，則應用「亞他那修信經」代替「使徒信經」。" : "¶ 此后，主礼和会众站立同念「使徒信经」。注意，在特定的日子，则应用「亚他那修信经」代替「使徒信经」。")
                
                Picker("信經選擇", selection: $viewModel.selectedCreed) {
                    ForEach(CreedSelection.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
                
                Text(viewModel.appLanguage == .traditional ? "¶ 不唸使徒信經，唸尼西亞信經亦可。" : "¶ 不念使徒信经，念尼西亚信经亦可。")
                    .font(.system(size: 13, weight: .regular))
                    .italic()
                    .foregroundColor(.red)
                    .padding(.bottom, 4)
                
                switch viewModel.selectedCreed {
                case .apostles:
                    creedContent(MorningPrayerData.apostlesCreed) // 🌟 改回從 MorningPrayerData 讀取
                case .nicene:
                    creedContent(MorningPrayerData.niceneCreed)   // 🌟 改回從 MorningPrayerData 讀取
                case .athanasian:
                    athanasianCreedContent
                }
            }
        }
    }

    // MARK: - 使徒 / 尼西亞信經通用渲染
    private func creedContent(_ section: PrayerSection) -> some View {
        Group {
            if let title = section.title {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(LiturgyColors.crimson)
                    .padding(.top, 2)
            }
            ForEach(section.paragraphs, id: \.self) { p in
                BodyText(p)
            }
        }
    }

    // MARK: - 亞他拿修信經專用渲染（42 段正文 + 2 段榮耀頌）
    private var athanasianCreedContent: some View {
        Group {
            Text(PrimePrayerData.athanasianCreed.title!)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(LiturgyColors.crimson)
                .padding(.top, 2)
            
            if let rubric = PrimePrayerData.athanasianCreed.rubric {
                RubricBlock(text: rubric)
            }
            
            // ═════ 正文 42 段：一、至四十二、（懸掛縮進）═════
            ForEach(0..<42, id: \.self) { index in
                let body = PrimePrayerData.athanasianCreed.paragraphs[index]
                let prefix = numberToChinese(index + 1) + "、"
                
                HStack(alignment: .top, spacing: 0) {
                    Text(prefix)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 52, alignment: .leading)
                    Text(body)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // ═════ 榮耀頌（第 43–44 段，無序號，居中）═════
            VStack(alignment: .leading, spacing: 4) {
                Text(PrimePrayerData.athanasianCreed.paragraphs[42])
                Text(PrimePrayerData.athanasianCreed.paragraphs[43])
            }
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        }
    }
    
    // MARK: - 祈禱區塊
    private var prayersSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.appLanguage == .traditional ? "祈禱" : "祈祷")
                RubricBlock(text: EveningPrayerData.prayers.rubric ?? "")
                ResponsoryRow(response: Responsory(
                    leader: viewModel.appLanguage == .traditional ? "願主與你們同在。" : "愿主与你们同在。",
                    people: viewModel.appLanguage == .traditional ? "願主與你的心靈同在。" : "愿主与你的心灵同在。"
                ))
                Text(viewModel.appLanguage == .traditional ? "我們要禱告。" : "我们要祷告。")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                Text(viewModel.appLanguage == .traditional ? "求主憐憫；\n求基督憐憫；\n求主憐憫。" : "求主怜悯；\n求基督怜悯；\n求主怜悯。")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 4)
                
                if EveningPrayerData.prayers.paragraphs.count > 2 {
                    BodyText(EveningPrayerData.prayers.paragraphs[2])
                }
                
                Picker("啟應版本", selection: $viewModel.selectedPrayerResponse) {
                    ForEach(PrayerResponseVersion.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
                
                let responses = viewModel.selectedPrayerResponse == .bcp1932 ? EveningPrayerData.prayersResponsesBCP1932 : EveningPrayerData.prayersResponsesNew
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(responses, id: \.self) { r in ResponsoryRow(response: r) }
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
                    
                    // 🌟 從 JSON 讀取標題與禮規（會自動跟隨 appLanguage 切換雙語）
                    if let title = EveningPrayerData.collects.first?.title {
                        SectionTitle(text: title)
                    }
                    if let rubric = EveningPrayerData.collects.first?.rubric {
                        RubricBlock(text: rubric)
                    }
                    
                    // 🌟 祝文前啟應（支援雙語）
                    VStack(alignment: .leading, spacing: 10) {
                        ResponsoryRow(response: Responsory(
                            leader: isTrad ? "啟：願主與你們同在。" : "启：愿主与你们同在。",
                            people: isTrad ? "應：願主與你的心靈同在。" : "应：愿主与你的心灵同在。"
                        ))
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text(isTrad ? "啟" : "启")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(LiturgyColors.crimson)
                                .frame(width: 22, height: 22)
                                .overlay(Circle().stroke(LiturgyColors.crimson, lineWidth: 1.5))
                            Text(isTrad ? "我們要禱告。" : "我们要祷告。")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                        }
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
                        PlaceholderBlock(text: isTrad ? "按當日節期誦唸" : "按当日节期诵念")
                    }
                    
                    // 🌟 紀念祝文
                    // 改用 id: \.displayName 直接迭代元素，強制 SwiftUI 在語言切換時重繪畫面
                    ForEach(viewModel.fileCommemorations, id: \.displayName) { block in
                        commemorationBlock(block)
                    }

                    ForEach(viewModel.commemorationCollects, id: \.displayName) { block in
                        commemorationBlock(block)
                    }
                    
                    // 🌟 聖靈降臨八日慶期每日附加祝文（支援雙語）
                    if viewModel.shouldShowPentecostOctaveAppendix {
                        Divider().padding(.vertical, 4)
                        
                        Text(isTrad ? "聖靈降臨八日慶期每日祝文" : "圣灵降临八日庆期每日祝文")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(LiturgyColors.crimson)
                            .padding(.top, 2)
                        
                        BodyText(isTrad ? "全能最慈悲的上帝，我們懇求主，使我們靠著住在我們裡面的聖靈，得蒙啓發，加增力量服事主。這都是靠著我主耶穌基督。主和聖父、聖靈，惟一上帝，一同永生，一同掌權，世世無盡。阿們。" : "全能最慈悲的上帝，我们恳求主，使我们靠着住在我们里面的圣灵，得蒙启发，加增力量服事主。这都是靠着我主耶稣基督。主和圣父、圣灵，唯一上帝，一同永生，一同掌权，世世无尽。阿们。")
                    }
                }
            }
            
            // 2. 求安祝文 & 求恩祝文（固定的平日祝文，維持獨立卡片）
            if EveningPrayerData.collects.count >= 3 {
                LiturgyCard { PrayerSectionContent(section: EveningPrayerData.collects[1]) }
                LiturgyCard { PrayerSectionContent(section: EveningPrayerData.collects[2]) }
            }
        }
    }
    
    private var generalPrayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 晚禱使用自己的一般禱文 (EveningPrayerData.generalPrayers)
            ForEach(EveningPrayerData.generalPrayers.indices, id: \.self) { i in
                LiturgyCard { PrayerSectionContent(section: EveningPrayerData.generalPrayers[i]) }
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
    
    // MARK: - 總禱文（內嵌於晚禱，使用 LitanyDataLoader 雙語支援）
    @ViewBuilder
    private var litanySection: some View {
        if let data = litanyLoader.uiData {
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
            HStack {
                Spacer()
                ProgressView(viewModel.appLanguage == .traditional ? "載入總禱文..." : "载入总祷文...")
                    .padding(.vertical, 20)
                Spacer()
            }
            .onAppear {
                litanyLoader.loadData()
            }
        }
    }
    
    // MARK: - 總禱文啟應行（採用統一設計：圓圈啟應）
    private func litanyResponseRow(response: UILitanyResponsory, lang: AppLanguage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            
            let leaderText = response.leader.text(for: lang)
                .replacingOccurrences(of: "啟：", with: "")
                .replacingOccurrences(of: "启：", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            if !leaderText.isEmpty {
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
            
            Text("紀念" + block.displayName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(LiturgyColors.crimson)
            
            if block.antiphon != nil || block.versicle != nil {
                if let antiphon = block.antiphon {
                    MorningPrayerView.AntiphonRow(text: antiphon)
                        .padding(.top, 4)
                }
                
                if let versicle = block.versicle {
                    ResponsoryRow(response: Responsory(
                        leader: "啟：" + versicle.leader,
                        people: "應：" + versicle.people
                    ))
                    .padding(.bottom, 4)
                }
                
                Text("我們要禱告。")
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
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(EveningPrayerData.endingResponses, id: \.self) { response in
                            ResponsoryRow(response: response)
                        }
                    }
                    Divider().padding(.vertical, 8)
                    
                    if let title = EveningPrayerData.ending.title { SectionTitle(text: title) }
                    ForEach(EveningPrayerData.ending.paragraphs, id: \.self) { p in BodyText(p) }
                    
                    // 🌟 聖帕特里克鎧甲歌
                    SectionTitle(text: viewModel.appLanguage == .traditional ? "聖帕特里克鎧甲歌" : "圣帕特里克铠甲歌")
                    Picker("聖帕特里克鎧甲歌", selection: $viewModel.stPatrickOption) {
                        ForEach(StPatrickOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)
                    
                    if viewModel.stPatrickOption == .recite {
                        ForEach(EveningPrayerData.stPatrickBreastplate, id: \.self) { paragraph in
                            BodyText(paragraph)
                        }
                    }
                    
                    if let rubric = EveningPrayerData.ending.rubric {
                        Text(rubric).font(.system(size: 15, weight: .regular)).italic().foregroundColor(.red).frame(maxWidth: .infinity, alignment: .center).padding(.top, 8)
                    }
                }
            }
            Text(viewModel.appLanguage == .traditional ? "❦ 晚禱至此結束。" : "❦ 晚祷至此结束。")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)

            Spacer().frame(height: 32)
        }
    }
}

enum EveningSecondCanticleSelection: String, CaseIterable, Hashable {
    case nuncDimittis = "西面頌"
    case deusMisereatur = "憐憫頌"
    case benedicAnimaMea = "心靈頌"
    
    var canticleType: CanticleType {
        switch self {
        case .nuncDimittis: return .nuncDimittis
        case .deusMisereatur: return .deusMisereatur
        case .benedicAnimaMea: return .benedicAnimaMea
        }
    }
}

enum GloriaInExcelsisOption: String, CaseIterable, Hashable {
    case bcp1932 = "BCP1932"
    case newTranslation = "新譯"
    case omit = "省略"
}

// MARK: - 晚禱專屬 ViewModel
class EveningPrayerViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var absolutionVersion: AbsolutionVersion =
        OfficePrefs.restore(OfficePrefs.Key.absolutionVersion, default: .clergy) {
        didSet { OfficePrefs.save(absolutionVersion, key: OfficePrefs.Key.absolutionVersion) }
    }
    @Published var selectedCreed: CreedSelection =
        OfficePrefs.restore(OfficePrefs.Key.creed, default: .apostles) {
        didSet { OfficePrefs.save(selectedCreed, key: OfficePrefs.Key.creed) }
    }
    @Published var lectionaryYear: String =
        OfficePrefs.restoreString(OfficePrefs.Key.lectionaryYear, default: "1928") {
        didSet {
            OfficePrefs.saveString(lectionaryYear, key: OfficePrefs.Key.lectionaryYear)
            loadReadings()   // ← 保留原有這行
        }
    }
    @Published var preparatoryOption: PreparatoryPrayerOption =
        OfficePrefs.restore(OfficePrefs.Key.preparatoryOption, default: .include) {
        didSet { OfficePrefs.save(preparatoryOption, key: OfficePrefs.Key.preparatoryOption) }
    }
    @Published var dailyReadings: DailyReadings?
    @Published var eveningOTVerses: [BibleVerse] = []
    @Published var eveningNTVerses: [BibleVerse] = []
    @Published var selectedSecondCanticle: EveningSecondCanticleSelection =
        OfficePrefs.restore(OfficePrefs.Key.secondCanticle, default: .nuncDimittis) {
        didSet { OfficePrefs.save(selectedSecondCanticle, key: OfficePrefs.Key.secondCanticle) }
    }
    @Published var scriptureVersion: String = {
        UserDefaults.standard.string(forKey: "bibleVersion") ?? "CUV"
    }()
    @Published var gloriaOption: GloriaInExcelsisOption =
        OfficePrefs.restore(OfficePrefs.Key.gloriaOption, default: .bcp1932) {
        didSet { OfficePrefs.save(gloriaOption, key: OfficePrefs.Key.gloriaOption) }
    }
    @Published var selectedPrayerResponse: PrayerResponseVersion =
        OfficePrefs.restore(OfficePrefs.Key.prayerResponse, default: .bcp1932) {
        didSet { OfficePrefs.save(selectedPrayerResponse, key: OfficePrefs.Key.prayerResponse) }
    }
    @Published var stPatrickOption: StPatrickOption =
        OfficePrefs.restore(OfficePrefs.Key.stPatrickOption, default: .recite) {
        didSet { OfficePrefs.save(stPatrickOption, key: OfficePrefs.Key.stPatrickOption) }
    }
    @Published var generalPrayerOption: GeneralPrayerOption =
        OfficePrefs.restore(OfficePrefs.Key.generalPrayerOption, default: .prayers) {
        didSet { OfficePrefs.save(generalPrayerOption, key: OfficePrefs.Key.generalPrayerOption) }
    }
    @Published var jsonEveningOT: DailyOfficeFile.OfficePeriod.LessonReference?
    @Published var jsonEveningNT: DailyOfficeFile.OfficePeriod.LessonReference?
    @Published var selectedPsalmLectionary: String =
        OfficePrefs.restoreString(OfficePrefs.Key.psalmLectionary, default: "monthly") {
        didSet { OfficePrefs.saveString(selectedPsalmLectionary, key: OfficePrefs.Key.psalmLectionary) }
    }
    @Published var availablePsalmLectionaryOptions: [String] = []
    @Published var selected1943SetId: String?
    @Published var available1943Sets: [DailyOfficeFile.OfficePeriod.LectionarySet] = []
    @Published var patristicReading: PatristicReadingEntry?

    // 🌟 新增：應用語言狀態（與早禱共用全域設定）
    @Published var appLanguage: AppLanguage = MorningPrayerDataLoader.shared.currentLanguage {
        didSet {
            AppLanguageStore.shared.setLanguage(appLanguage)
            loadReadings()
        }
    }
    // 🌟 新增：當天日間禮儀（isEvening: false），用於 temporal 節期紀念祝文回退
    var todayDayLiturgy: DailyLiturgy {
        LiturgyCoreService.shared.resolve(for: selectedDate, isEvening: false)
    }
    
    // MARK: - 聖靈降臨八日慶期每日附加祝文
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

    var pentecostOctaveAppendixCollect: DailyOfficeFile.OfficePeriod.CollectJSON {
        .init(
            title: "聖靈降臨八日慶期每日祝文",
            text: "全能最慈悲的上帝，我們懇求主，使我們靠著住在我們裡面的聖靈，得蒙啓發，加增力量服事主。這都是靠著我主耶穌基督。主和聖父、聖靈，惟一上帝，一同永生，一同掌權，世世無盡。阿們。"
        )
    }
    
    var secondCanticle: CanticleData {
        CanticleLoader.shared.canticle(for: selectedSecondCanticle.canticleType)
    }
    
    /// 處理西面頌的對經（僅在選擇西面頌時顯示）
    var secondCanticleAntiphon: String? {
        // 如果選的不是西面頌，直接返回 nil
        guard selectedSecondCanticle == .nuncDimittis else { return nil }
        
        // 0. 基督聖體節至其八日慶期前夕晚禱：一律使用聖體節西面頌對經。
        // 排除基督聖心節前夕晚禱，因該晚禱已屬基督聖心節。
        let daysFromEaster = LiturgyCoreService.shared.getSeasonInfo(for: effectiveDate).daysFromEaster
        let isSacredHeartVespers = liturgy.mainTitle.contains("聖心")
        if (60...67).contains(daysFromEaster) && !isSacredHeartVespers {
            return "哈利路亞，※我所要賜的糧，哈利路亞，就是我的肉，哈利路亞，為世人之生命所賜的。哈利路亞，哈利路亞。"
        }
        
        // 1. 優先：從 JSON 文件讀取專用對經（前夕晚禱用 effectiveDate）
        if let file = DailyOfficeLoader.shared.loadOfficeFile(for: effectiveDate, liturgy: liturgy) {
            let period = liturgy.isFirstVespers ? (file.vigil ?? file.evening) : file.evening
            if let antiphon = period?.nuncDimittisAntiphon?.normal, !antiphon.isEmpty {
                return antiphon
            }
        }
        
        // 2. 🌟 按節期回退（對照 PHP 映射表）
        let info = LiturgyCoreService.shared.getSeasonInfo(for: effectiveDate)
        let season = info.season
        let weekNumber = info.weekNumber
        
        // 諸聖日專用（前夕到第八日）
        if liturgy.mainTitle.contains("諸聖日") {
            return "聖者、義者，※你們要在主內歡欣；※上帝揀選了你們作為祂自己的人。"
        }
        
        switch season {
        case .advent:
            return "求主來臨，在平安中眷顧我們，※使我們能以純全的心在主面前歡欣。"
            
        case .christmas:
            return "哈利路亞，※道成了肉身，哈利路亞；住在我們中間，哈利路亞，哈利路亞。"
            
        case .epiphany:
            // 顯現日及八日慶期內專用，之後顯現期回退通用
            if weekNumber == 1 {
                return "基督，※祢是從光的光，祢已顯現；東方博士給你獻上禮物，哈利路亞。"
            }
            break
            
        case .lent:
            // 大齋期第1-2周
            if weekNumber <= 2 {
                return "你見赤身的給他衣服遮體，※不可隱藏自己避開你的骨肉，這樣，必有光如晨光破曉照耀你，主的榮光必作你的後盾。"
            }
            // 大齋期第3-4周
            else if weekNumber <= 4 {
                return "我們存活的時候，※也離死不遠。我們犯罪，主向我們發怒，也是應該的。但是，除了主以外，我們向誰求赦呢？還是求至聖全能的主上帝，至聖最慈悲的救主，莫叫我們受永死的苦。"
            }
            // 苦難期（第5周起，含聖周）
            else {
                return "榮耀的君王，※在諸聖中極其榮耀，永受讚頌，卻非言語所能盡述；主在我們中間，我們亦稱為主聖名下之人；我們的上帝，求主勿撇棄我們：永受讚頌的君王，求主在審判之日，恩准我們列於主諸聖與選民之中。"
            }
            
        case .easter:
            return "哈利路亞，※主已經復活了，哈利路亞。正如主對你們所說的話，哈利路亞。"
            
        case .ascension:
            return "哈利路亞，※基督已升上高天，哈利路亞，祂擄掠了仇敵，哈利路亞，哈利路亞。"
            
        case .pentecost:
            return "哈利路亞，※聖靈保惠師，哈利路亞，必將一切事指教你們，哈利路亞，哈利路亞。"
            
        case .trinity:
            return "求主※將真光賜給我們，好驅散我們心中的幽暗，使我們能來就那光，就是基督。"
            
        default:
            break
        }
        return "主啊，醒時求你引導，睡時求你保護；這樣，我們醒時可以與基督一同守候，睡時可以在平安里歇息。"
    }
    
    // 解析時加入 isEvening: true
    var liturgy: DailyLiturgy {
        LiturgyCoreService.shared.resolve(for: selectedDate, isEvening: true)
    }
    
    // 實際用來讀取 JSON 的日期
    // 如果今天是前夕晚禱，我們必須拿「明天」的日期去抓明天的檔案
    var effectiveDate: Date {
        if liturgy.isFirstVespers {
            return Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
        }
        return selectedDate
    }
    
    // 🌟 更新：獲取本日祝文（支援 vigil 節點）
    var collectOfTheDay: DailyOfficeFile.OfficePeriod.CollectJSON? {
        guard let file = DailyOfficeLoader.shared.loadOfficeFile(for: effectiveDate, liturgy: liturgy) else { return nil }
        
        if liturgy.isFirstVespers {
            // 前夕晚禱：優先讀取 vigil，沒有就降級用 evening 或 morning
            return file.vigil?.collect ?? file.evening?.collect ?? file.morning?.collect
        } else {
            // 一般晚禱：優先讀取 evening，沒有就降級用 morning
            return file.evening?.collect ?? file.morning?.collect
        }
    }
    
    /// 檔案內建附加紀念（晚禱：evening / vigil）
    var fileCommemorations: [MorningPrayerViewModel.CommemorationCollectBlock] {
        guard let file = DailyOfficeLoader.shared.loadOfficeFile(for: effectiveDate, liturgy: liturgy) else { return [] }
        
        let period: DailyOfficeFile.OfficePeriod?
        if liturgy.isFirstVespers {
            period = file.vigil ?? file.evening
        } else {
            period = file.evening
        }
        
        guard let comms = period?.commemorations else { return [] }
        
        return comms.compactMap { comm in
            guard let collect = comm.collect else { return nil }
            let displayName = comm.displayName ?? "紀念"
            let commemorationFile = DailyOfficeLoader.shared.loadCommemoration(name: displayName, date: effectiveDate)
            let rank = commemorationFile.map { LiturgicalRank.parse(from: $0.rank ?? "") } ?? .commemoration
            
            return MorningPrayerViewModel.CommemorationCollectBlock(
                name: displayName,
                displayName: displayName,
                antiphon: comm.antiphon,
                versicle: comm.versicle,
                collect: collect,
                rank: rank
            )
        }
    }
    
    var allCommemorationCollects: [MorningPrayerViewModel.CommemorationCollectBlock] {
        (fileCommemorations + commemorationCollects).sorted { lhs, rhs in
            // ═════ 特殊條件：聖彼得與聖保羅配對 ═════
            // commemorations 機制目前只用於這一對節日，
            // 聖彼得的祝文之後必須緊接聖保羅的紀念祝文。
            let lhsIsPeter = lhs.displayName.contains("聖彼得") || lhs.name.contains("聖彼得")
            let rhsIsPaul  = rhs.displayName.contains("聖保羅") || rhs.name.contains("聖保羅")
            let lhsIsPaul  = lhs.displayName.contains("聖保羅") || lhs.name.contains("聖保羅")
            let rhsIsPeter = rhs.displayName.contains("聖彼得") || rhs.name.contains("聖彼得")
            
            // 聖彼得始終排在聖保羅之前
            if lhsIsPeter && rhsIsPaul { return true }
            // 聖保羅不可排在聖彼得之前
            if lhsIsPaul && rhsIsPeter { return false }
            
            // 聖保羅紀念始終排在其他所有紀念的最後
            if lhsIsPaul && !rhsIsPaul { return false }
            if rhsIsPaul && !lhsIsPaul { return true }
            // ═══════════════════════════════════════
            
            if lhs.rank == rhs.rank {
                return lhs.displayName < rhs.displayName
            }
            return lhs.rank > rhs.rank
        }
    }
    
    // 🌟 更新：日課聖詩（支援 vigil 節點）
    var officeHymn: OfficeHymnData {
        // 🌟 關鍵修正：前夕晚禱要用明天的日期(effectiveDate)去載入節日檔案
        // 例如：升天節前夕 → 載入 temporal_ascension_day.json 的 vigil 節點
        if let file = DailyOfficeLoader.shared.loadOfficeFile(for: effectiveDate, liturgy: liturgy) {
            let period = liturgy.isFirstVespers ? (file.vigil ?? file.evening) : file.evening
            if let special = period?.officeHymn {
                return OfficeHymnData(
                    title: "",
                    latinTitle: special.title ?? "",
                    seasonNote: nil,
                    verses: special.verses ?? [],
                    versicle: special.versicle.map { .init(leader: $0.leader, people: $0.people) }
                )
            }
        }
        
        // 2. 退回到平日晚禱 (evening_hymns.json)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        
        // 處理禮拜六特殊邏輯
        if weekday == 7 {
            return EveningHymnLoader.shared.getHymn(for: "saturdayTrinity")
                   ?? EveningHymnLoader.shared.getHymn(for: "saturdayEpiphany")
                   ?? OfficeHymnData(title: "", latinTitle: "", seasonNote: nil, verses: [], versicle: nil)
        }
        
        let keys = ["", "sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        let key = keys[weekday]
        
        return EveningHymnLoader.shared.getHymn(for: key)
               ?? OfficeHymnData(title: "", latinTitle: "", seasonNote: nil, verses: [], versicle: nil)
    }
    
    
    
    var commonName: String? {
        let map: [String: String] = ["復活後第五主日": "特禱主日", "復活後第一主日": "卸白衣主日"]
        return map[liturgy.mainTitle]
    }
    
    var bibleSentences: [BibleSentenceJSON] {
        // 1. 優先：本日專用 JSON（前夕晚禱用 effectiveDate）
        if let special = DailyOfficeLoader.shared.bibleSentences(for: effectiveDate, liturgy: liturgy, isEvening: true) {
            return special
        }
        
        // 2. 回退：節期 / 平日通用
        let info = LiturgyCoreService.shared.getSeasonInfo(for: effectiveDate)
        
        // 🌟 升天後主日：強制使用升天期選句，絕不回退到平日
        if liturgy.mainTitle == "升天後主日" {
            let ascension = BibleSentencesLoader.eveningShared.sentences(for: .ascension, title: liturgy.mainTitle)
            if !ascension.isEmpty { return ascension }
            
            let easter = BibleSentencesLoader.eveningShared.sentences(for: .easter, title: "復活後第七主日")
            if !easter.isEmpty { return easter }
            
            return BibleSentencesLoader.eveningShared.sentences(for: .easter, title: "主日")
        }
        
        return BibleSentencesLoader.eveningShared.sentences(for: info.season, title: liturgy.mainTitle)
    }
    
    // 🌟 詩篇改為 Evening
    var eveningPsalms: [(title: String, content: PsalmContent)] {
        PsalmsLoader.shared.eveningPsalms(for: selectedDate)
    }
    
    var psalmAntiphons: [String]? {
        DailyOfficeLoader.shared.psalmAntiphons(for: effectiveDate, liturgy: liturgy, isEvening: true)
    }

    var psalmAntiphon: String? {
        psalmAntiphons?.first
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
            for: effectiveDate,
            liturgy: liturgy,
            isEvening: true,
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
    
    /// ⬇️ 晚禱第一頌歌：固定尊主頌 (Magnificat)
    var magnificat: CanticleData {
        CanticleLoader.shared.canticle(for: .magnificat)
    }
    
    /// 尊主頌當日對經（平日按星期，主日 nil）
    var magnificatAntiphon: String? {
        // 🌟 修正：傳入 isEvening: true，並用 effectiveDate（前夕晚禱時讀明天檔案）
        if let special = DailyOfficeLoader.shared.benedictusAntiphon(for: effectiveDate, liturgy: liturgy, isEvening: true),
           !special.isEmpty {
            return special
        }
        // 2. 回退：通用 canticles.json 的平日對經
        let weekday = Calendar.current.component(.weekday, from: selectedDate)
        return CanticleLoader.shared.magnificatWeekdayAntiphon(for: weekday)
    }
    
    /// ⬇️ 晚禱第二頌歌：固定西面頌 (Nunc Dimittis)
    var nuncDimittis: CanticleData {
        CanticleLoader.shared.canticle(for: .nuncDimittis)
    }
    
    /// 西面頌對經（通常為 nil，預留擴展空間）
    var nuncDimittisAntiphon: String? {
        // 晚禱西面頌對經在某些特殊節期（如大齋期）可能會有，目前預設為 nil
        return nil
    }
    
    // MARK: - 經課讀取輔助
    
    /// 當前可用的內嵌經課版本選項
    var availableLectionaryOptions: [String] {
        var options = Set(
            DailyOfficeLoader.shared.availableLectionaryOptions(
                for: effectiveDate,
                liturgy: liturgy,
                isEvening: true
            )
        )
        
        let sets1943 = DailyOffice1943LectionaryService.shared.officeSets(
            for: selectedDate,
            liturgy: liturgy,
            isEvening: true
        )
        
        if !sets1943.isEmpty {
            options.insert("1943")
        }
        
        // 晚禱經課版本選擇必須保留 JSON 經課表提供的 1928 / 1962。
        // 否則當 JSON 或 1943 獨立文件只提供 1943 時，Picker 會只剩 1943。
        options.insert("1928")
        options.insert("1962")
        
        return Array(options).sorted()
    }
    
    /// 統一接口：第一經課書卷與章節
    var eveningOTReading: (book: String, chapter: String)? {
        if let ref = jsonEveningOT { return (ref.book, ref.chapter) }
        guard let day = dailyReadings?.eveningOT else { return nil }
        return (day.book, day.chapter)
    }
    
    /// 統一接口：第二經課書卷與章節
    var eveningNTReading: (book: String, chapter: String)? {
        if let ref = jsonEveningNT { return (ref.book, ref.chapter) }
        guard let day = dailyReadings?.eveningNT else { return nil }
        return (day.book, day.chapter)
    }
    
    var commemorationCollects: [MorningPrayerViewModel.CommemorationCollectBlock] {
            var blocks: [MorningPrayerViewModel.CommemorationCollectBlock] = []
            
            AppLog.debug("🌙 當日晚禱紀念列表：\(liturgy.commemorations)")
            
            for name in liturgy.commemorations {
                AppLog.debug("🔍 查找紀念：\(name)")
                
                // 🌟 1. 歸一化：去掉「紀念」前綴
                let normalizedName = name.hasPrefix("紀念")
                    ? String(name.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                    : name
                
                // 🌟 2. 繁簡轉換：利用 iOS 原生 API 產生繁體與簡體版本，包容語言切換導致的差異
                let nameHans = name.applyingTransform(StringTransform("Hant-Hans"), reverse: false) ?? name
                let nameHant = name.applyingTransform(StringTransform("Hans-Hant"), reverse: false) ?? name
                let normHans = normalizedName.applyingTransform(StringTransform("Hant-Hans"), reverse: false) ?? normalizedName
                let normHant = normalizedName.applyingTransform(StringTransform("Hans-Hant"), reverse: false) ?? normalizedName
                
                let validNames = [name, normalizedName, nameHans, nameHant, normHans, normHant]
                
                // 1. 嘗試今天
                var foundDate = selectedDate
                var file = DailyOfficeLoader.shared.loadCommemoration(name: name, date: selectedDate)
                AppLog.debug("   今天(\(formattedMMDD(selectedDate)))查找結果：\(file?.name ?? "nil")")
                
                if let f = file, !DailyOfficeLoader.shared.isMappedCommemoration(normalizedName) {
                    if !validNames.contains(f.name) {
                        AppLog.debug("   ⚠️ 名稱不匹配：file.name='\(f.name)' vs 預期名稱集='\(validNames)'，已剔除")
                        file = nil
                    }
                }
                
                // 2. 嘗試明天
                if file == nil {
                    let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
                    file = DailyOfficeLoader.shared.loadCommemoration(name: name, date: tomorrowDate)
                    if file != nil {
                        foundDate = tomorrowDate
                        AppLog.debug("   明天(\(formattedMMDD(tomorrowDate)))查找結果：\(file!.name)")
                    }
                    
                    if let f = file, !DailyOfficeLoader.shared.isMappedCommemoration(normalizedName) {
                        if !validNames.contains(f.name) {
                            AppLog.debug("   ⚠️ 名稱不匹配：file.name='\(f.name)' vs 預期名稱集='\(validNames)'，已剔除")
                            file = nil
                        }
                    }
                }
                
                // 3. Temporal 節期紀念（保持不變）
                if file == nil {
                    let nextDayLiturgy = LiturgyCoreService.shared.resolve(for: effectiveDate, isEvening: false)
                    let temporalMatch: (date: Date, liturgy: DailyLiturgy, useVigil: Bool)? = {
                        if liturgy.isFirstVespers && nextDayLiturgy.mainTitle == name {
                            return (effectiveDate, nextDayLiturgy, true)
                        }
                        if todayDayLiturgy.mainTitle == name {
                            return (selectedDate, todayDayLiturgy, false)
                        }
                        return nil
                    }()
                    
                    if let temporal = temporalMatch {
                        if let officeFile = DailyOfficeLoader.shared.loadOfficeFile(for: temporal.date, liturgy: temporal.liturgy) {
                            let period = temporal.useVigil
                                ? (officeFile.vigil ?? officeFile.evening ?? officeFile.morning)
                                : (officeFile.evening ?? officeFile.morning)
                            if let collect = period?.collect {
                                let antiphon: String? = {
                                    if let normals = period?.benedictusAntiphon?.normals, !normals.isEmpty {
                                        let year = Calendar.current.component(.year, from: selectedDate)
                                        return normals[year % normals.count]
                                    }
                                    if let n = period?.benedictusAntiphon?.normal, !n.isEmpty {
                                        return n
                                    }
                                    return nil
                                }()
                                // ✅ 修改：JSON 無 versicle 時，從晚禱聖詩回退
                                // ✅ 修改：JSON 無 versicle 時，針對前夕晚禱與平日進行回退
                                let versicle: DailyOfficeFile.OfficePeriod.VersicleJSON? = {
                                    // 1. 若 JSON 內建有專屬 versicle (如聖日)，優先使用
                                    if let v = period?.officeHymn?.versicle { return v }
                                    
                                    // 2. 缺乏專屬啟應的紀念（如秋季齋期），強制回退使用「當天實際星期幾」的「平日」晚禱啟應
                                    let calendar = Calendar.current
                                    let todayWeekday = calendar.component(.weekday, from: selectedDate)
                                    
                                    // 處理禮拜六特殊邏輯（主日的前夕晚禱實際在禮拜六舉行）
                                    if todayWeekday == 7 {
                                        if let hymn = EveningHymnLoader.shared.getHymn(for: "saturdayTrinity")
                                           ?? EveningHymnLoader.shared.getHymn(for: "saturdayEpiphany"),
                                           let v = hymn.versicle {
                                            return DailyOfficeFile.OfficePeriod.VersicleJSON(leader: v.leader, people: v.people)
                                        }
                                        return nil
                                    }
                                    
                                    // 處理禮拜日到禮拜五的平日回退
                                    // weekday 索引：1=sunday, 2=monday, 3=tuesday, 4=wednesday, 5=thursday, 6=friday
                                    let keys = ["", "sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
                                    let key = keys[todayWeekday]
                                    
                                    if let hymn = EveningHymnLoader.shared.getHymn(for: key),
                                       let v = hymn.versicle {
                                        return DailyOfficeFile.OfficePeriod.VersicleJSON(leader: v.leader, people: v.people)
                                    }
                                    
                                    return nil
                                }()
                                blocks.append(MorningPrayerViewModel.CommemorationCollectBlock(
                                    name: name,
                                    displayName: name,
                                    antiphon: antiphon,
                                    versicle: versicle,
                                    collect: collect,
                                    rank: temporal.liturgy.rank
                                ))
                                // 🌟 新增：載入 temporal 檔案中的內建 commemorations
                                if let comms = period?.commemorations {
                                    for comm in comms {
                                        guard let c = comm.collect else { continue }
                                        blocks.append(MorningPrayerViewModel.CommemorationCollectBlock(
                                            name: comm.displayName ?? "紀念",
                                            displayName: comm.displayName ?? "紀念",
                                            antiphon: comm.antiphon,
                                            versicle: comm.versicle,
                                            collect: c,
                                            rank: .commemoration
                                        ))
                                    }
                                }
                                continue
                            }
                        }
                    }
                }
                
                // 4. Sanctorale 聖人紀念：根據 foundDate 選擇節點
                guard let foundFile = file else {
                    AppLog.debug("   ❌ 無有效檔案")
                    continue
                }

                let period: DailyOfficeFile.OfficePeriod?
                if foundDate != selectedDate {
                    // 明天聖日 → 使用 vigil（前夕晚禱）
                    period = foundFile.vigil ?? foundFile.evening ?? foundFile.morning
                } else {
                    // 今天聖日 → 使用 evening（晚禱）
                    period = foundFile.evening ?? foundFile.morning
                }

                guard let period = period, let collect = period.collect else {
                    AppLog.debug("   ❌ 無有效檔案或無 collect")
                    continue
                }

                AppLog.debug("   ✅ 找到祝文：\(collect.title)")

                let antiphon: String? = {
                    if let normals = period.benedictusAntiphon?.normals, !normals.isEmpty {
                        let year = Calendar.current.component(.year, from: selectedDate)
                        return normals[year % normals.count]
                    }
                    if let n = period.benedictusAntiphon?.normal, !n.isEmpty {
                        return n
                    }
                    return nil
                }()
                // ✅ 修改：JSON 無 versicle 時，從當天實際日期的晚禱聖詩回退
                let versicle: DailyOfficeFile.OfficePeriod.VersicleJSON? = {
                    if let v = period.officeHymn?.versicle { return v }
                    let calendar = Calendar.current
                    let weekday = calendar.component(.weekday, from: selectedDate)
                    if weekday == 7 { // 禮拜六
                        if let hymn = EveningHymnLoader.shared.getHymn(for: "saturdayTrinity")
                           ?? EveningHymnLoader.shared.getHymn(for: "saturdayEpiphany"),
                           let v = hymn.versicle {
                            return DailyOfficeFile.OfficePeriod.VersicleJSON(leader: v.leader, people: v.people)
                        }
                    }
                    return nil
                }()
                let rank = LiturgicalRank.parse(from: foundFile.rank ?? "")

                blocks.append(MorningPrayerViewModel.CommemorationCollectBlock(
                    name: foundFile.name,
                    displayName: name,
                    antiphon: antiphon,
                    versicle: versicle,
                    collect: collect,
                    rank: rank
                ))
                // 🌟 新增：載入該聖日檔案中的內建 commemorations（如聖保羅）
                if let comms = period.commemorations {
                    for comm in comms {
                        guard let c = comm.collect else { continue }
                        blocks.append(MorningPrayerViewModel.CommemorationCollectBlock(
                            name: comm.displayName ?? "紀念",
                            displayName: comm.displayName ?? "紀念",
                            antiphon: comm.antiphon,
                            versicle: comm.versicle,
                            collect: c,
                            rank: .commemoration
                        ))
                    }
                }
            }
            return blocks
        }
    
    // 輔助：格式化日期為 MMDD
    private func formattedMMDD(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMdd"
        return f.string(from: date)
    }
    
    
    func loadReadings() {
        // 🌟 同步最新版本設定
        scriptureVersion = UserDefaults.standard.string(forKey: "bibleVersion") ?? "CUV"
        
        let options = availableLectionaryOptions
        
        // 同步合法年份（避免 JSON 有 special 但 Picker 卡在 1928）
        let validYear: String
        if options.isEmpty {
            validYear = self.lectionaryYear
        } else if options.contains(self.lectionaryYear) {
            validYear = self.lectionaryYear
        } else {
            validYear = options.first!
            if self.lectionaryYear != validYear {
                self.lectionaryYear = validYear
                return
            }
        }
        
        available1943Sets = DailyOffice1943LectionaryService.shared.officeSets(
            for: selectedDate,
            liturgy: liturgy,
            isEvening: true
        )
        
        if selected1943SetId == nil ||
           !available1943Sets.contains(where: { $0.id == selected1943SetId }) {
            selected1943SetId = available1943Sets.first?.id
        }
        
        var psalmOptions = DailyOfficeLoader.shared.availablePsalmLectionaryOptions(
            for: effectiveDate,
            liturgy: liturgy,
            isEvening: true
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
        
        if validYear == "1943",
           let set = selected1943Set,
           let lessons = set.lessons {
            jsonEveningOT = lessons.ot
            jsonEveningNT = lessons.nt
            dailyReadings = nil
            loadVerses()
            return
        }
        
        // 🌟 優先嘗試 JSON 內嵌經課
        let _fvFmt = DateFormatter(); _fvFmt.dateFormat = "MMdd"
        AppLog.debug("🌸🌸🌸 [前夕晚禱診斷] selectedDate=\(_fvFmt.string(from: selectedDate)), effectiveDate=\(_fvFmt.string(from: effectiveDate)), isFirstVespers=\(liturgy.isFirstVespers), mainTitle=\(liturgy.mainTitle)")
        if !options.isEmpty,
           let jsonLessons = DailyOfficeLoader.shared.jsonLessons(for: effectiveDate, liturgy: liturgy, isEvening: true, year: validYear),
           let ot = jsonLessons.ot, let nt = jsonLessons.nt {
            jsonEveningOT = ot
            jsonEveningNT = nt
            dailyReadings = nil   // 有 JSON 就不走經課表
            AppLog.debug("🌸🌸🌸 [前夕晚禱診斷] 經課來源=JSON(effectiveDate=\(_fvFmt.string(from: effectiveDate)))，OT=\(ot.book)\(ot.chapter)，NT=\(nt.book)\(nt.chapter)")
        } else {
            jsonEveningOT = nil
            jsonEveningNT = nil
            // 🌟 前夕晚禱經課映射：
            // 主日／節日的前夕晚禱若沒有自己的內嵌(JSON)經課，
            // 經課固定取「前一天（禮拜六）」自身的晚禱經課，
            // 絕不可改用次日（主日）的晚禱經課。
            // 前一天 = effectiveDate 回退一日；前夕晚禱時 effectiveDate=selectedDate+1，
            // 故結果即 selectedDate，但以 effectiveDate 推導可確保「鎖定前夕日」的語意明確且不依賴 selectedDate 是否被正確設定。
            let lectionaryQueryDate: Date = {
                guard liturgy.isFirstVespers else { return selectedDate }
                return Calendar.current.date(byAdding: .day, value: -1, to: effectiveDate) ?? selectedDate
            }()
            AppLog.debug("[前夕晚禱] 經課來源=經課表 JSON，isFirstVespers=\(liturgy.isFirstVespers)，查詢日期=\(_fvFmt.string(from: lectionaryQueryDate))（selectedDate=\(_fvFmt.string(from: selectedDate))）")
            dailyReadings = DailyLectionaryService.shared.readings(for: lectionaryQueryDate, year: validYear)
        }
        
        patristicReading = PatristicReadingLoader.shared.reading(
            for: selectedDate,
            liturgy: liturgy
        )
        
        loadVerses()
    }
    
    private func loadVerses() {
            eveningOTVerses = []
            eveningNTVerses = []
            
            scriptureVersion = UserDefaults.standard.string(forKey: "bibleVersion") ?? "CUV"
            
            DispatchQueue.global(qos: .userInitiated).async {
                var ot: [BibleVerse] = []
                var nt: [BibleVerse] = []
                
                let otBook = self.jsonEveningOT?.book ?? self.dailyReadings?.eveningOT?.book
                let otChapter = self.jsonEveningOT?.chapter ?? self.dailyReadings?.eveningOT?.chapter
                
                if let book = otBook, let chapter = otChapter {
                    let isApo = BibleJSONService.shared.isApocrypha(book: book)
                    let version = isApo ? "APO1933" : self.scriptureVersion
                    
                    let stringVerses = BibleJSONService.shared.fetchVersesList(version: version, book: book, reference: chapter)
                    ot = stringVerses.map { text in
                        let vStr = text.components(separatedBy: " ").first ?? "0"
                        // 💡 如果你的 BibleVerse 中 verse 是 String 型別，請改為 verse: vStr
                        return BibleVerse(verse: Int(vStr) ?? 0, content: text)
                    }
                }
                
                let ntBook = self.jsonEveningNT?.book ?? self.dailyReadings?.eveningNT?.book
                let ntChapter = self.jsonEveningNT?.chapter ?? self.dailyReadings?.eveningNT?.chapter
                
                if let book = ntBook, let chapter = ntChapter {
                    let isApo = BibleJSONService.shared.isApocrypha(book: book)
                    let version = isApo ? "APO1933" : self.scriptureVersion
                    
                    let stringVerses = BibleJSONService.shared.fetchVersesList(version: version, book: book, reference: chapter)
                    nt = stringVerses.map { text in
                        let vStr = text.components(separatedBy: " ").first ?? "0"
                        // 💡 如果你的 BibleVerse 中 verse 是 String 型別，請改為 verse: vStr
                        return BibleVerse(verse: Int(vStr) ?? 0, content: text)
                    }
                }
                
                DispatchQueue.main.async {
                    self.eveningOTVerses = ot
                    self.eveningNTVerses = nt
                }
            }
        }
    
    func jumpToYesterday() {
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) { selectedDate = yesterday; loadReadings() }
    }
    func jumpToToday() { selectedDate = Date(); loadReadings() }
    func jumpToTomorrow() {
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) { selectedDate = tomorrow; loadReadings() }
    }
}


// MARK: - 預覽
struct EveningPrayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EveningPrayerView()
        }
    }
}
