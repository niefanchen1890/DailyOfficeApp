import SwiftUI
import Combine

struct TercePrayerView: View {
    @StateObject private var viewModel: TercePrayerViewModel
    let date: Date
    
    init(date: Date = Date()) {
        self.date = date
        let vm = TercePrayerViewModel()
        vm.selectedDate = date
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    openingResponsesSection
                    hymnSection
                    psalmsSection
                    readingSection
                    shortResponsesSection

                    prayersSection

                    collectsSection
                    closingSection
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
        .navigationTitle("三時禱")
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

            Text("三  時  禱")
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

    // MARK: - 開始啟應
    private var openingResponsesSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(TercePrayerData.openingResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }

    // MARK: - 聖詩（動態組裝節期結尾，聖靈降臨日使用 Veni, Creator Spiritus）
    private var hymnSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "聖詩")
                
                // 拉丁文標題（聖靈降臨日專用）
                if let latinTitle = viewModel.hymnLatinTitle, !latinTitle.isEmpty {
                    Text(latinTitle)
                        .font(.system(size: 15, weight: .medium))
                        .italic()
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 4)
                }
                
                ForEach(viewModel.hymnVerses, id: \.self) { verse in
                    hymnVerseRow(verse)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 提取中文數字序號
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

    // MARK: - 詩篇
    private var psalmsSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "詩篇")
                RubricBlock(text: "¶ 然後當按日課誦唸詩篇，以及適當的季節或瞻禮對經。")

                // 季節對經（前）
                if let antiphon = viewModel.currentAntiphon {
                    RubricBlock(text: "¶ \(antiphon.season)對經：")
                    MorningPrayerView.AntiphonRow(text: antiphon.text)
                        .padding(.bottom, 4)
                }

                let psalmKeys = TercePrayerData.psalmKeys(for: viewModel.selectedDate)
                ForEach(psalmKeys.indices, id: \.self) { index in
                    let key = psalmKeys[index]
                    if let psalm = PsalmsLoader.shared.psalmContent(for: key) {
                        let displayTitle = TercePrayerData.psalmDisplayTitle(for: key)
                        psalmContentView(title: displayTitle, content: psalm)
                        if index < psalmKeys.count - 1 {
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

    // MARK: - 單篇詩篇渲染
    private func psalmContentView(title: String, content: PsalmContent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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

            ForEach(content.verses, id: \.self) { verse in
                psalmVerseRow(verse)
            }

            VStack(alignment: .leading, spacing: 4) {
                BodyText("但願榮耀歸於聖父、聖子、聖靈；")
                BodyText("※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。")
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 6)
    }

    // MARK: - 詩節行（紅色節號）
    private func psalmVerseRow(_ verse: String) -> some View {
        let trimmed = verse.trimmingCharacters(in: .whitespaces)
        var number = ""
        for char in trimmed {
            if char.isNumber { number.append(char) } else { break }
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

    // MARK: - 讀經
    private var readingSection: some View {
        let reading = viewModel.currentReading

        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "讀經")
                RubricBlock(text: "¶ 然後，按季節或日期唸以下聖經章節。")

                // 節期選擇器（大標題下）
                Picker("讀經選擇", selection: $viewModel.selectedReadingOption) {
                    ForEach(TerceReadingOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
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
                RubricBlock(text: "¶ 按著季節選擇以下的簡單啟應。")

                // 節期選擇器（大標題下）
                Picker("啟應選擇", selection: $viewModel.selectedShortResponseOption) {
                    ForEach(TerceShortResponseOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)

                if let s = set {
                    RubricBlock(text: "¶ \(s.title)")
                    ForEach(s.responses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                }
            }
        }
    }

    // MARK: - 祈禱（平日）
    private var prayersSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "祈禱")

                // 顯示/省略選擇器（大標題下）
                Picker("祈禱選擇", selection: $viewModel.selectedPrayerOption) {
                    ForEach(TercePrayerOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)

                // 根據選擇顯示內容或省略提示
                if viewModel.selectedPrayerOption == .show {
                    if let rubric = TercePrayerData.prayersSection.rubric {
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
                    BodyText(TercePrayerData.prayersSection.paragraphs[1])

                    Divider().padding(.vertical, 6)

                    let responses = TercePrayerData.prayersResponses
                    ForEach(responses.indices, id: \.self) { i in
                        ResponsoryRow(response: responses[i])
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
                    ForEach(TercePrayerData.collectOpening, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }

                    Text("我們要禱告。")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)

                    // 本日祝文（只載入早禱主祝文，不含紀念）
                    if let mainCollect = viewModel.collectOfTheDay {
                        Text(mainCollect.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(LiturgyColors.crimson)
                            .padding(.top, 2)

                        BodyText(mainCollect.text)
                    } else {
                        PlaceholderBlock(text: "按當日節期誦唸")
                    }

                    // 三時禱固定補充祝文
                    Divider().padding(.vertical, 4)

                    RubricBlock(text: "¶ 誦唸本日祝文，然後誦唸以下紀念祝文。")

                    Text("上帝阿，求祢助我今日虔誠的事奉祢，扶持我們在世界的勞碌；使我們明智去工作，暗中行施捨；使我們飲食有胃口，就坐有謹慎，睡眠有節制，合宜的讓朋友歡欣，愉快的睡覺，安穩的入眠；以我們的主耶穌基督為樂。阿們。")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }
            }

            // 結束啟應
            LiturgyCard {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(TercePrayerData.collectEndingResponses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                }
            }
        }
    }

    // MARK: - 結束經文
    private var closingSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // 拆分正文與經文出處，出處標紅
                if TercePrayerData.closingText.paragraphs.count > 0 {
                    let text = TercePrayerData.closingText.paragraphs[0]

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

    // MARK: - 結尾
    private var endingSection: some View {
        VStack(spacing: 0) {
            Text("❦ 三時禱至此結束。")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)

            Spacer().frame(height: 32)
        }
    }
}

// MARK: - 視圖模型
class TercePrayerViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedReadingOption: TerceReadingOption = .ordinary
    @Published var selectedShortResponseOption: TerceShortResponseOption = .ordinary
    @Published var selectedPrayerOption: TercePrayerOption = .show

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

    /// 當季節對經（聖母慶節優先）
    var currentAntiphon: TercePrayerData.PsalmAntiphon? {
        let title = liturgy.mainTitle
        
        // 1️⃣ 聖母慶節優先（完整名稱列表匹配）
        if TercePrayerData.BVMFeastAntiphon.isBVMFeast(title: title) {
            return TercePrayerData.PsalmAntiphon(
                season: "聖母慶節",
                text: TercePrayerData.BVMFeastAntiphon.text
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
        return TercePrayerData.psalmAntiphons.first { $0.season == key }
            ?? TercePrayerData.psalmAntiphons.first { $0.season == "全年通用" }
    }

    func fullAntiphonText(for antiphon: TercePrayerData.PsalmAntiphon) -> String {
        // 聖母慶節專用
        if antiphon.season == "聖母慶節" {
            return antiphon.text
        }
        
        switch antiphon.season {
        case "全年通用":
            return "我呼求，主垂聽我。"
        case "降臨期":
            return "看哪，主帶著能力和榮耀，駕著天上的雲來臨。哈利路亚。"
        case "聖誕期":
            return "孕婦生了名叫「永恆」的君王，她兼有童貞女的榮譽，又獲得做母親的喜樂；前不見古人，後不見來者，哈利路亞。"
        case "大齋期":
            return "懺悔之日臨近我們，為補贖我們的罪，拯救我們的靈魂。"
        case "復活期":
            return "哈利路亞，哈利路亞，哈利路亞，哈利路亞。"
        default:
            return antiphon.text
        }
    }

    /// 當日讀經
    var currentReading: TercePrayerData.TerceReadingItem? {
        TercePrayerData.TerceReadingsLoader.shared.item(for: selectedReadingOption.rawValue)
    }

    /// 當日簡短啟應組
    var currentShortResponsorySet: TercePrayerData.ShortResponsorySet? {
        switch selectedShortResponseOption {
        case .ordinary:
            return TercePrayerData.shortResponsesOrdinary
        case .feast:
            // 復活期內顯示哈利路亞，復活期外隱藏
            return isEasterSeason
                ? TercePrayerData.shortResponsesFeastEaster
                : TercePrayerData.shortResponsesFeastOrdinary
        }
    }

    /// 本日祝文（只取早禱主祝文，不含紀念）
    var collectOfTheDay: DailyOfficeFile.OfficePeriod.CollectJSON? {
        DailyOfficeLoader.shared.collect(for: selectedDate, liturgy: liturgy)
    }

    /// 當日完整聖詩（基礎詩節 + 節期專用結尾）
    var hymnVerses: [String] {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        
        // 🌟 聖靈降臨日（49）至聖靈降臨八日慶期內夏季齋期禮拜六（55）均使用 Veni, Creator Spiritus
        if (49...55).contains(info.daysFromEaster) {
            return TercePrayerData.pentecostHymn.paragraphs
        }
        
        return TercePrayerData.SeasonalHymnEnding.assemble(
            baseVerses: TercePrayerData.hymn.paragraphs,
            for: selectedDate,
            liturgy: liturgy
        )
    }

    /// 聖詩拉丁文標題（聖靈降臨八日慶期內專用）
    var hymnLatinTitle: String? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        if (49...55).contains(info.daysFromEaster) {
            return "Veni, Creator Spiritus"
        }
        return nil
    }

    func loadData() {
        // let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        let rank = liturgy.rank

        // 讀經自動預設
        if isEasterSeason {
            selectedReadingOption = .easter
        } else {
            let isSundayOrFeast: [LiturgicalRank] = [
                .sundayFirstClassGreat, .sundayFirstClass, .sundaySecondClass, .ordinarySunday,
                .doubleFirstClass, .doubleSecondClass, .greaterDouble, .double,
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

        // 簡短啟應自動預設
        if isEasterSeason {
            selectedShortResponseOption = .feast
        } else {
            let isSundayOrFeast: [LiturgicalRank] = [
                .sundayFirstClassGreat, .sundayFirstClass, .sundaySecondClass, .ordinarySunday,
                .doubleFirstClass, .doubleSecondClass, .greaterDouble, .double,
                .privilegedOctaveFirstClass,
                .privilegedOctaveSecondClass,
                .privilegedOctaveSecondClassGreat,
                .privilegedOctaveThirdClass,
                .privilegedOctaveThirdClassGreat,
                .ordinaryOctavegreaterDouble,
                .ordinaryOctavesemiDouble
            ]
            selectedShortResponseOption = isSundayOrFeast.contains(rank) ? .feast : .ordinary
        }

        // 祈禱自動預設
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
struct TercePrayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TercePrayerView()
        }
    }
}
