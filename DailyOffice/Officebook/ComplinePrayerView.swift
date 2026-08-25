import SwiftUI
import Combine

struct ComplinePrayerView: View {
    @StateObject private var viewModel: ComplinePrayerViewModel
    let date: Date
    
    init(date: Date = Date()) {
        self.date = date
        let vm = ComplinePrayerViewModel()
        vm.selectedDate = date
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    openingSection
                    shortReadingSection
                    lordPrayerResponsesSection
                    psalmsSection
                    lessonSection
                    shortResponsesSection
                    hymnSection
                    postHymnResponsesSection
                    nuncDimittisSection
                    prayersSection
                    collectsSection
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
        .navigationTitle("寢前禱")
        .navigationBarTitleDisplayMode(.inline)
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

            Text("寢  前  禱")
                .font(.system(size: 20, weight: .bold))
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

    // MARK: - 開始啟應
    private var openingSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(ComplinePrayerData.openingResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }

    // MARK: - 簡短讀經
    private var shortReadingSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: ComplinePrayerData.shortReading.title ?? "簡短讀經")
                BodyText(ComplinePrayerData.shortReading.paragraphs[0])

                // ⬇️ 新增：經題（紅色）
                Text("（彼得前書 5:8）")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.top, 2)
                    .padding(.leading, 4)

                Divider().padding(.vertical, 4)

                ResponsoryRow(response: Responsory(
                    leader: "",
                    people: "應：感謝上帝。"
                ))

                ForEach(ComplinePrayerData.readingResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }

                Divider().padding(.vertical, 4)

                // 主禱文前啟應
                RubricBlock(text: "¶ 我們在天上的父，默念主禱文，然後出聲啟應：")
                BodyText("我們在天上的父，願人都尊父的名為聖。願父的國降臨。願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人。")
                ForEach(ComplinePrayerData.lordPrayerResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }

    // 主禱文前啟應（已併入簡短讀經區塊）
    private var lordPrayerResponsesSection: some View { EmptyView() }

    // MARK: - 詩篇
    private var psalmsSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "詩篇")
                RubricBlock(text: "¶ 然後，唸以下詩篇，並按著節期唸對應的對經。")

                // 季節對經（前）
                if let antiphon = viewModel.currentPsalmAntiphon {
                    RubricBlock(text: "¶ \(antiphon.season)：")
                    MorningPrayerView.AntiphonRow(text: antiphon.before)
                        .padding(.bottom, 4)
                }

                let keys = ComplinePrayerData.psalmKeys
                ForEach(keys.indices, id: \.self) { index in
                    let key = keys[index]
                    if let psalm = PsalmsLoader.shared.psalmContent(for: key) {
                        let displayTitle = ComplinePrayerData.psalmDisplayTitle(for: key)
                        let latinSubtitle = ComplinePrayerData.psalmLatinSubtitle(for: key)
                        complinePsalmView(title: displayTitle, latin: latinSubtitle, content: psalm)
                        if index < keys.count - 1 {
                            Divider().padding(.vertical, 8)
                        }
                    }
                }

                // 季節對經（後）
                if let antiphon = viewModel.currentPsalmAntiphon {
                    Divider().padding(.vertical, 4)
                    MorningPrayerView.AntiphonRow(text: antiphon.after)
                }
            }
        }
    }

    // MARK: - 單篇詩篇渲染（寢前禱風格）
    private func complinePsalmView(title: String, latin: String, content: PsalmContent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title)
                    .foregroundColor(LiturgyColors.crimson)
                if !latin.isEmpty {
                    Text(latin)
                        .italic()
                        .foregroundColor(.primary)
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .padding(.bottom, 4)

            ForEach(content.verses, id: \.self) { verse in
                psalmVerseRow(verse)
            }

            // ⬇️ 新增：每篇詩篇後加榮耀頌
            VStack(alignment: .leading, spacing: 4) {
                BodyText("但願榮耀歸於聖父、聖子、聖靈；")
                BodyText("※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。")
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 6)
    }

    private func psalmVerseRow(_ verse: String) -> some View {
        let trimmed = verse.trimmingCharacters(in: .whitespaces)
        var number = ""
        for char in trimmed { if char.isNumber { number.append(char) } else { break } }
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

    // MARK: - 經課
    private var lessonSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "經課")
                
                // 拆分經文與經題（經題標紅）
                let fullText = ComplinePrayerData.lesson.paragraphs[0]
                if let openRange = fullText.range(of: "（", options: .backwards),
                   let closeRange = fullText.range(of: "）", options: .backwards),
                   openRange.lowerBound < closeRange.lowerBound {
                    
                    let scripture = String(fullText[..<openRange.lowerBound])
                    let reference = String(fullText[openRange.lowerBound...])
                    
                    BodyText(scripture)
                    
                    Text(reference)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.top, 2)
                        .padding(.leading, 4)
                } else {
                    BodyText(fullText)
                }

                // 🌟 禮規說明（非啟，紅色斜體）
                if let rubric = ComplinePrayerData.lesson.rubric {
                    RubricBlock(text: rubric)
                }

                // 只保留應：感謝上帝（啟行為空，自動隱藏）
                ResponsoryRow(response: Responsory(
                    leader: "",
                    people: "感謝上帝。"
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
                RubricBlock(text: "¶ 按著季節選擇以下的簡短啟應。")

                // 節期選擇器（與六時禱一致）
                Picker("啟應選擇", selection: $viewModel.selectedShortResponseOption) {
                    ForEach(ComplineShortResponseOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)

                // 苦難期提示
                if viewModel.isHolyWeek {
                    RubricBlock(text: "¶ 苦難期不誦唸榮耀頌。")
                }

                // 顯示當前組別標題與啟應
                RubricBlock(text: "¶ \(set.title)")
                ForEach(set.responses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }

    // MARK: - 聖詩（帶節期選擇器，與簡短啟應同風格）
    private var hymnSection: some View {
        let hymnData = viewModel.currentHymn

        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "聖詩")

                // 節期選擇器（與簡短啟應一致）
                Picker("聖詩選擇", selection: $viewModel.selectedHymnType) {
                    ForEach(ComplineHymnType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)

                if let rubric = hymnData.rubric {
                    RubricBlock(text: rubric)
                }

                ForEach(hymnData.paragraphs, id: \.self) { verse in
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

    // MARK: - 聖詩後啟應
    private var postHymnResponsesSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.currentPostHymnResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }

    // MARK: - 頌歌（西面頌）—— 直接引用晚禱數據
    private var nuncDimittisSection: some View {
        let canticle = viewModel.nuncDimittisCanticle
        let antiphon = viewModel.nuncDimittisAntiphon

        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
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

                RubricBlock(text: "¶ 然後唸此頌歌，並相應的對經。")

                // 對經（前）
                MorningPrayerView.AntiphonRow(text: antiphon)
                    .padding(.bottom, 4)

                // 頌歌內容
                if canticle.style == "responsive", let verses = canticle.verses {
                    ForEach(verses) { verse in
                        canticleVerseRow(verse)
                    }
                } else if let paragraphs = canticle.paragraphs {
                    ForEach(paragraphs.indices, id: \.self) { i in
                        BodyText(paragraphs[i])
                    }
                }

                // 榮耀頌
                if let doxology = canticle.doxology {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(doxology)
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 8)
                }

                // 對經（後）
                MorningPrayerView.AntiphonRow(text: antiphon)
                    .padding(.top, 8)
            }
        }
    }

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

    // MARK: - 祈禱
    private var prayersSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "祈禱")

                // 顯示／省略選擇器
                Picker("祈禱選擇", selection: $viewModel.selectedPrayerOption) {
                    ForEach(ComplinePrayerOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)

                // 內容或省略提示
                if viewModel.selectedPrayerOption == .show {
                    if let rubric = ComplinePrayerData.prayersSection.rubric {
                        RubricBlock(text: rubric)
                    }

                    // 求主憐憫
                    Text("求主憐憫；\n求基督憐憫；\n求主憐憫。")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)

                    // 主禱文默念提示
                    RubricBlock(text: "¶ 默念主禱文，然後出聲啟應：")
                    BodyText(ComplinePrayerData.prayersSection.paragraphs[1])

                    Divider().padding(.vertical, 6)

                    // 啟應（前兩組）
                    ForEach(0..<2, id: \.self) { i in
                        ResponsoryRow(response: ComplinePrayerData.prayersResponses[i])
                    }

                    // 使徒信經提示
                    RubricBlock(text: "¶ 默唸「使徒信經」，然後出聲啟應：")

                    // 啟應（續：自「我信身體復活」起）
                    let remainingResponses = Array(ComplinePrayerData.prayersResponses.dropFirst(2))
                    ForEach(remainingResponses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }

                    // 認罪文
                    if let rubric = ComplinePrayerData.confession.rubric {
                        RubricBlock(text: rubric)
                    }
                    ForEach(ComplinePrayerData.confession.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                    RubricBlock(text: ComplinePrayerData.confessionNote)

                    // 赦罪文（會長）
                    if let rubric = ComplinePrayerData.absolutionClergy.rubric {
                        RubricBlock(text: rubric)
                    }
                    ForEach(ComplinePrayerData.absolutionClergy.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                    ForEach(ComplinePrayerData.postAbsolutionResponses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }

                } else {
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

                    // ✅ 祝文前啟應（3句）
                    ForEach(ComplinePrayerData.preCollectResponses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }

                    Text("我們要禱告。")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)

                    // 祝文選擇器
                    Picker("祝文選擇", selection: $viewModel.selectedCollect) {
                        ForEach(ComplineCollectOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 6)

                    // 當前祝文
                    let collect = viewModel.currentCollect
                    Text(collect.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(LiturgyColors.crimson)
                        .padding(.top, 2)

                    BodyText(collect.text)

                    // ✅ 祝文後啟應（2句）
                    ForEach(ComplinePrayerData.postCollectResponses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                }
            }
        }
    }

    // MARK: - 紀念聖母與諸聖
    private var commemorationSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: ComplinePrayerData.commemorationSection.title ?? "紀念聖母與諸聖")

                if let rubric = ComplinePrayerData.commemorationSection.rubric {
                    RubricBlock(text: rubric)
                }

                // 對經
                if let antiphon = viewModel.commemorationAntiphon {
                    MorningPrayerView.AntiphonRow(text: antiphon)
                        .padding(.bottom, 4)
                }

                // 祝文前啟應
                ForEach(ComplinePrayerData.commemorationResponsesBefore, id: \.self) { r in
                    ResponsoryRow(response: r)
                }

                Divider().padding(.vertical, 4)

                // 祝文正文
                BodyText(ComplinePrayerData.commemorationSection.paragraphs[0])

                // 祝文後啟應
                ForEach(ComplinePrayerData.commemorationResponsesAfter, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }
    // MARK: - 結尾
    private var endingSection: some View {
        VStack(spacing: 0) {
            Text("❦ 寢前禱至此結束。")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)

            Spacer().frame(height: 32)
        }
    }
}

// MARK: - 視圖模型
class ComplinePrayerViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedCollect: ComplineCollectOption = .protection
    @Published var selectedShortResponseOption: ComplineShortResponseOption = .ordinary
    @Published var selectedHymnType: ComplineHymnType = .weekday   // ⬅️ 新增：聖詩手動選項
    @Published var selectedPrayerOption: ComplinePrayerOption = .show

    private let eveningVM = EveningPrayerViewModel()
    /// 西面頌數據（直接引用晚禱 VM，固定為 Nunc Dimittis）
    var nuncDimittisCanticle: CanticleData {
        eveningVM.secondCanticle
    }
    
    /// 西面頌對經（直接引用晚禱 VM 的 JSON → 節期回退 → 默認對經 邏輯）
    var nuncDimittisAntiphon: String {
        eveningVM.secondCanticleAntiphon ?? ComplinePrayerData.defaultNuncDimittisAntiphon
    }

    init() {
        eveningVM.selectedSecondCanticle = .nuncDimittis
        eveningVM.selectedDate = selectedDate
        loadData()
        
    }
    
    var liturgy: DailyLiturgy {
        LiturgyCoreService.shared.resolve(for: selectedDate, isEvening: true)
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

    /// 是否為苦難期
    var isHolyWeek: Bool {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        return info.season == .holyWeek
    }

    /// 是否應顯示祈禱（平日顯示，主日/慶節/八日慶期省略）
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

    /// 當季節對經（詩篇）
    var currentPsalmAntiphon: ComplinePrayerData.PsalmAntiphon? {
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
        return ComplinePrayerData.psalmAntiphons.first { $0.season == key }
            ?? ComplinePrayerData.psalmAntiphons.first { $0.season == "全年通用" }
    }

    /// 當日簡短啟應
    var currentShortResponsorySet: ComplinePrayerData.ShortResponsorySet {
        switch selectedShortResponseOption {
        case .ordinary:
            return ComplinePrayerData.shortResponsesOrdinary
        case .easter:
            return ComplinePrayerData.shortResponsesEaster
        }
    }
    
    /// 當日聖詩後啟應
    var currentPostHymnResponses: [Responsory] {
        isEasterSeason ? ComplinePrayerData.postHymnResponsesEaster : ComplinePrayerData.postHymnResponsesOrdinary
    }
    
    /// 當日聖詩（根據選擇器或節期預設）
    var currentHymn: PrayerSection {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        
        // 🌟 聖靈降臨日（49）至聖靈降臨後二日（51）強制使用 Alma Chorus
        if (49...51).contains(info.daysFromEaster) {
            return ComplinePrayerData.almaChorusHymn
        }
        
        switch selectedHymnType {
        case .easter:
            let season = info.season
            if season == .ascension {
                return ComplinePrayerData.ascensionHymn
            } else if season == .pentecost {
                return ComplinePrayerData.pentecostHymn
            } else {
                return ComplinePrayerData.easterHymn
            }

        case .lent:
            return applySeasonalEnding(ComplinePrayerData.lentHymn)
        case .feast:
            return applySeasonalEnding(ComplinePrayerData.feastHymn)
        case .weekday:
            return applySeasonalEnding(ComplinePrayerData.weekdayHymn)
        }
    }

    /// 套用節期結尾替換（與一時禱共用 PrimePrayerData.SeasonalHymnEnding）
    private func applySeasonalEnding(_ base: PrayerSection) -> PrayerSection {
        let verses = PrimePrayerData.SeasonalHymnEnding.assemble(
            baseVerses: base.paragraphs,
            for: selectedDate,
            liturgy: liturgy
        )
        return PrayerSection(
            title: base.title,
            rubric: base.rubric,
            paragraphs: verses,
            responses: base.responses
        )
    }

    /// 紀念聖母對經
    var commemorationAntiphon: String? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        if info.season == .easter || info.season == .ascension || info.season == .pentecost {
            return "這是如何充滿榮耀的王國！所有聖者在那裡與基督一起歡樂。哈利路亞。"
        }
        return "這是如何充滿榮耀的王國！所有聖者在那裡與基督一起歡樂。"
    }

    /// 當前祝文
    var currentCollect: ComplinePrayerData.CollectOption {
        switch selectedCollect {
        case .protection: return ComplinePrayerData.collectOptions[0]
        case .ambrose:    return ComplinePrayerData.collectOptions[1]
        case .hope:       return ComplinePrayerData.collectOptions[2]
        }
    }

    func loadData() {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        let season = info.season
        let rank = liturgy.rank

        // ⬇️ 預設聖詩選項（按當前節期）
        if [.easter, .ascension, .pentecost].contains(season) {
            selectedHymnType = .easter
        } else if [.lent, .holyWeek].contains(season) {
            selectedHymnType = .lent
        } else {
            let isFeast: [LiturgicalRank] = [.sundayFirstClassGreat, .sundayFirstClass, .sundaySecondClass, .ordinarySunday, .doubleFirstClass, .doubleSecondClass, .greaterDouble, .double, .semiDouble]
            let isOctave: [LiturgicalRank] = [
                .privilegedOctaveFirstClass, .privilegedOctaveSecondClass,
                .privilegedOctaveSecondClassGreat, .privilegedOctaveThirdClass,
                .privilegedOctaveThirdClassGreat, .ordinaryOctavegreaterDouble,
                .ordinaryOctavesemiDouble
            ]
            if isFeast.contains(rank) || isOctave.contains(rank) {
                selectedHymnType = .feast
            } else {
                selectedHymnType = .weekday
            }
        }

        // 原有祝文與簡短啟應預設
        if season == .easter || season == .ascension {
            selectedCollect = .hope
        } else {
            selectedCollect = .protection
        }
        selectedShortResponseOption = isEasterSeason ? .easter : .ordinary
        // 祈禱預設：平日顯示，主日／慶節／八日慶期省略
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
}

// MARK: - 預覽
struct ComplinePrayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ComplinePrayerView()
        }
    }
}
