import SwiftUI
import Combine

// MARK: - 視圖選項枚舉
enum MinorHourReadingOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日與慶節"
    case easter = "復活節期"
    
    func localizedTitle(isSimplified: Bool, hour: MinorHour) -> String {
        switch self {
        case .ordinary: return isSimplified ? "全年平日" : "全年平日"
        case .feast:
            if hour == .terce {
                return isSimplified ? "主日与瞻礼日" : "主日與瞻禮日"
            }
            return isSimplified ? "主日与庆节" : "主日與慶節"
        case .easter: return isSimplified ? "复活节期" : "復活節期"
        }
    }
}

enum MinorHourShortResponseOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日、瞻禮日、復活期"
    
    func localizedTitle(isSimplified: Bool) -> String {
        switch self {
        case .ordinary: return isSimplified ? "全年平日" : "全年平日"
        case .feast: return isSimplified ? "主日、瞻礼日、复活期" : "主日、瞻禮日、復活期"
        }
    }
}

enum MinorHourPrayerOption: String, CaseIterable, Hashable {
    case show = "顯示"
    case omit = "省略"
    
    func localizedTitle(isSimplified: Bool) -> String {
        switch self {
        case .show: return isSimplified ? "显示" : "顯示"
        case .omit: return isSimplified ? "省略" : "省略"
        }
    }
}

// MARK: - 視圖模型
class MinorHourPrayerViewModel: ObservableObject {
    let hour: MinorHour
    @Published var selectedDate: Date = Date()
    @Published var selectedReadingOption: MinorHourReadingOption = .ordinary
    @Published var selectedShortResponseOption: MinorHourShortResponseOption = .ordinary
    @Published var selectedPrayerOption: MinorHourPrayerOption = .show

    // 🌟 全局監聽語言設定
    @AppStorage("appLanguage") var appLanguageCode: String = AppLanguage.traditional.rawValue
    var isSimplified: Bool { appLanguageCode == AppLanguage.simplified.rawValue }

    init(hour: MinorHour, date: Date) {
        self.hour = hour
        self.selectedDate = date
    }

    var data: MinorHourPrayerJSON {
        MinorHourPrayerDataLoader.shared.load(hour: hour)
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

    var currentAntiphon: MinorHourPsalmAntiphonJSON? {
        let title = liturgy.mainTitle
        if MinorHourPrayerRules.isBVMFeast(title: title) {
            let text = data.bvmFeastAntiphon
            return MinorHourPsalmAntiphonJSON(season: isSimplified ? "圣母庆节" : "聖母慶節", text: text, fullText: text)
        }
        
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        let seasonMap: [LiturgicalSeason: String] = [
            .advent: "降臨期", .christmas: "聖誕期", .epiphany: "全年通用",
            .lent: "大齋期", .holyWeek: "大齋期", .easter: "復活期",
            .ascension: "復活期", .pentecost: "復活期", .trinity: "全年通用"
        ]

        let key = seasonMap[info.season] ?? "全年通用"
        let localizedKey = isSimplified ? key.replacingOccurrences(of: "期", with: "期").replacingOccurrences(of: "聖", with: "圣").replacingOccurrences(of: "復", with: "复").replacingOccurrences(of: "齋", with: "斋").replacingOccurrences(of: "臨", with: "临") : key
        
        return data.psalmAntiphons.first { $0.season == localizedKey }
            ?? data.psalmAntiphons.first { $0.season == "全年通用" }
    }

    var currentReading: MinorHourReadingItemJSON? {
        let readings = data.readings
        let matchingKey = selectedReadingOption.localizedTitle(isSimplified: isSimplified, hour: hour)
        return readings.first { $0.season == matchingKey }
    }

    var currentShortResponsorySet: MinorHourShortResponsorySetJSON? {
        switch selectedShortResponseOption {
        case .ordinary: return data.shortResponsesOrdinary
        case .feast:    return isEasterSeason ? data.shortResponsesFeastEaster : data.shortResponsesFeastOrdinary
        }
    }

    var collectOfTheDay: DailyOfficeFile.OfficePeriod.CollectJSON? {
        DailyOfficeLoader.shared.collect(for: selectedDate, liturgy: liturgy)
    }

    var hymnVerses: [String] {
        MinorHourPrayerRules.hymnVerses(data: data, date: selectedDate, liturgy: liturgy)
    }

    var hymnLatinTitle: String? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        return hour == .terce && (49...55).contains(info.daysFromEaster)
            ? "Veni, Creator Spiritus"
            : nil
    }

    func loadData() {
        let rank = liturgy.rank
        let isSundayOrFeast: [LiturgicalRank] = [
            .sundayFirstClassGreat, .sundayFirstClass, .sundaySecondClass, .ordinarySunday,
            .doubleFirstClass, .doubleSecondClass, .greaterDouble, .double,
            .privilegedOctaveFirstClass, .privilegedOctaveSecondClass, .privilegedOctaveSecondClassGreat,
            .privilegedOctaveThirdClass, .privilegedOctaveThirdClassGreat, .ordinaryOctavegreaterDouble, .ordinaryOctavesemiDouble
        ]
        
        if isEasterSeason {
            selectedReadingOption = .easter
            selectedShortResponseOption = .feast
        } else {
            selectedReadingOption = isSundayOrFeast.contains(rank) ? .feast : .ordinary
            selectedShortResponseOption = isSundayOrFeast.contains(rank) ? .feast : .ordinary
        }
        selectedPrayerOption = shouldShowPrayers ? .show : .omit
    }

    func jumpToYesterday() {
        if let d = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) { selectedDate = d; loadData() }
    }
    func jumpToToday() { selectedDate = Date(); loadData() }
    func jumpToTomorrow() {
        if let d = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) { selectedDate = d; loadData() }
    }
}

// MARK: - 視圖
struct MinorHourPrayerView: View {
    @StateObject private var viewModel: MinorHourPrayerViewModel
    @Environment(\.colorScheme) var colorScheme
    let hour: MinorHour
    let date: Date
    
    init(hour: MinorHour, date: Date = Date()) {
        self.hour = hour
        self.date = date
        let vm = MinorHourPrayerViewModel(hour: hour, date: date)
        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    if viewModel.data.openingNote != nil { openingNoteSection }
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
            .onAppear { viewModel.loadData() }
            .background(colorScheme == .dark ? Color.black : LiturgyColors.parchment)
            dateQuickNavButtons
        }
        .navigationTitle(hour.title(isSimplified: viewModel.isSimplified))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 日期導航
    private var dateQuickNavButtons: some View {
        let isSimp = viewModel.isSimplified
        return HStack(spacing: 0) {
            Button(action: { viewModel.jumpToYesterday() }) { Text(isSimp ? "昨日" : "昨日").font(.system(size: 15, weight: .medium)) }
                .padding(.horizontal, 12).padding(.vertical, 8)
            Divider().frame(height: 20).background(Color.white.opacity(0.3))
            Button(action: { viewModel.jumpToToday() }) { Text(isSimp ? "今日" : "今日").font(.system(size: 15, weight: .bold)) }
                .padding(.horizontal, 12).padding(.vertical, 8)
            Divider().frame(height: 20).background(Color.white.opacity(0.3))
            Button(action: { viewModel.jumpToTomorrow() }) { Text(isSimp ? "明日" : "明日").font(.system(size: 15, weight: .medium)) }
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
                .font(.system(size: 15, weight: .medium, design: .default)).foregroundColor(.secondary).padding(.top, 12)
            Text(liturgy.mainTitle)
                .font(.system(size: 34, weight: .bold)).foregroundColor(.primary).multilineTextAlignment(.center).padding(.top, 12)

            if let common = viewModel.commonName {
                Text(common).font(.system(size: 18, weight: .semibold)).foregroundColor(LiturgyColors.crimson).padding(.top, 6)
            }
            if !liturgy.rankName.isEmpty {
                Text("（\(liturgy.rankName)）").font(.system(size: 17, weight: .regular)).foregroundColor(LiturgyColors.crimson).padding(.top, 4)
            }

            Divider().background(Color.secondary.opacity(0.25)).padding(.horizontal, 60).padding(.vertical, 20)
            Text(hour.spacedTitle(isSimplified: isSimp))
                .font(.system(size: 26, weight: .medium)).foregroundColor(.primary).tracking(12).padding(.bottom, 4)

            if !liturgy.commemorations.isEmpty {
                Text((isSimp ? "纪念：" : "紀念：") + liturgy.commemorations.joined(separator: "、"))
                    .font(.system(size: 14, weight: .regular)).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.top, 8).padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center).padding(.horizontal, 16)
    }

    private func formattedFullDateWithWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日 EEEE"
        f.locale = Locale(identifier: viewModel.isSimplified ? "zh_Hans" : "zh_Hant")
        return f.string(from: date)
    }

    // MARK: - 禮規說明
    private var openingNoteSection: some View {
        LiturgyCard { RubricBlock(text: viewModel.data.openingNote ?? "") }
    }

    // MARK: - 開始啟應
    private var openingResponsesSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.data.openingResponsories, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }

    // MARK: - 聖詩
    private var hymnSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                if let title = viewModel.data.hymn.title { SectionTitle(text: title) }
                if let latinTitle = viewModel.hymnLatinTitle {
                    Text(latinTitle).font(.system(size: 15, weight: .medium)).italic().foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(.bottom, 4)
                }
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
            Text(prefix).font(.system(size: 17, weight: .medium)).foregroundColor(.red).frame(width: 40, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                ForEach(lines.indices, id: \.self) { i in
                    Text(lines[i]).font(.system(size: 17, weight: .regular)).foregroundColor(.primary).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.vertical, 2).frame(maxWidth: .infinity, alignment: .leading)
    }

    private func extractChineseNumberPrefix(_ text: String) -> String {
        let chineseDigits = "一二三四五六七八九十"
        var prefix = ""
        for char in text {
            if chineseDigits.contains(char) { prefix.append(char) }
            else if char == "、" && !prefix.isEmpty { prefix.append(char); return prefix }
            else { break }
        }
        return prefix
    }

    // MARK: - 詩篇
    private var psalmsSection: some View {
        let isSimp = viewModel.isSimplified
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimp ? "诗篇" : "詩篇")
                RubricBlock(text: isSimp ? "¶ 然后当按日课诵念诗篇，以及适当的季节或瞻礼对经。" : "¶ 然後當按日課誦唸詩篇，以及適當的季節或瞻禮對經。")

                if let antiphon = viewModel.currentAntiphon {
                    let seasonStr = antiphon.season
                    RubricBlock(text: "¶ \(seasonStr)\(isSimp ? "对经" : "對經")：")
                }

                let psalmKeys = MinorHourPrayerRules.psalmKeys(hour: hour, date: viewModel.selectedDate)
                ForEach(psalmKeys.indices, id: \.self) { index in
                    let key = psalmKeys[index]
                    if let psalm = PsalmsLoader.shared.psalmContent(for: key) {
                        let displayTitle = MinorHourPrayerRules.psalmDisplayTitle(for: key, isSimplified: isSimp)
                        psalmContentView(
                            title: displayTitle,
                            content: psalm,
                            openingAntiphon: index == 0 ? viewModel.currentAntiphon?.text : nil
                        )
                        if index < psalmKeys.count - 1 { Divider().padding(.vertical, 8) }
                    }
                }

                if let antiphon = viewModel.currentAntiphon {
                    Divider().padding(.vertical, 4)
                    MorningPrayerView.AntiphonRow(text: antiphon.fullText)
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
                if !content.latinTitle.isEmpty { Text(content.latinTitle).italic().foregroundColor(.primary) }
            }
            .font(.system(size: 17, weight: .semibold)).padding(.bottom, 4)

            if let openingAntiphon, !openingAntiphon.isEmpty {
                MorningPrayerView.AntiphonRow(text: openingAntiphon)
            }

            ForEach(content.verses, id: \.self) { verse in psalmVerseRow(verse) }

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

        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            if !number.isEmpty { Text(number).font(.system(size: 17, weight: .regular)).foregroundColor(.red) }
            Text(text).font(.system(size: 17, weight: .regular)).foregroundColor(.primary).lineSpacing(6).fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - 讀經
    private var readingSection: some View {
        let isSimp = viewModel.isSimplified
        let reading = viewModel.currentReading

        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimp ? "读经" : "讀經")
                RubricBlock(text: isSimp ? "¶ 然后，按季节或日期念以下圣经章节。" : "¶ 然後，按季節或日期唸以下聖經章節。")

                Picker(isSimp ? "读经选择" : "讀經選擇", selection: $viewModel.selectedReadingOption) {
                    ForEach(MinorHourReadingOption.allCases, id: \.self) { option in
                        Text(option.localizedTitle(isSimplified: isSimp, hour: hour)).tag(option)
                    }
                }
                .pickerStyle(.segmented).padding(.vertical, 6)

                if let r = reading {
                    RubricBlock(text: "¶ \(r.season)：")
                    BodyText(r.content)
                    if !r.reference.isEmpty {
                        Text("（\(r.reference)）").font(.system(size: 13, weight: .medium)).foregroundColor(.red).padding(.top, 2).padding(.leading, 4)
                    }
                } else {
                    PlaceholderBlock(text: isSimp ? "按当日节期诵念" : "按當日節期誦唸")
                }

                Divider().padding(.vertical, 4)
                RubricBlock(text: isSimp ? "¶ 圣经读毕，会众念：" : "¶ 聖經讀畢，會眾唸：")
                ResponsoryRow(response: Responsory(leader: "", people: isSimp ? "应：感谢上帝。" : "應：感謝上帝。"))
            }
        }
    }

    // MARK: - 簡短啟應
    private var shortResponsesSection: some View {
        let isSimp = viewModel.isSimplified
        let set = viewModel.currentShortResponsorySet

        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimp ? "简短启应" : "簡短啟應")
                RubricBlock(text: isSimp ? "¶ 按着季节选择以下的简单启应。" : "¶ 按著季節選擇以下的簡單啟應。")

                Picker(isSimp ? "启应选择" : "啟應選擇", selection: $viewModel.selectedShortResponseOption) {
                    ForEach(MinorHourShortResponseOption.allCases, id: \.self) { option in
                        Text(option.localizedTitle(isSimplified: isSimp)).tag(option)
                    }
                }
                .pickerStyle(.segmented).padding(.vertical, 6)

                if let s = set {
                    RubricBlock(text: "¶ \(s.title)")
                    ForEach(s.uiResponses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                }
            }
        }
    }

    // MARK: - 祈禱
    private var prayersSection: some View {
        let isSimp = viewModel.isSimplified
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                if let title = viewModel.data.prayersSection.title { SectionTitle(text: title) }

                Picker(isSimp ? "祈祷选择" : "祈禱選擇", selection: $viewModel.selectedPrayerOption) {
                    ForEach(MinorHourPrayerOption.allCases, id: \.self) { option in
                        Text(option.localizedTitle(isSimplified: isSimp)).tag(option)
                    }
                }
                .pickerStyle(.segmented).padding(.vertical, 6)

                if viewModel.selectedPrayerOption == .show {
                    if let rubric = viewModel.data.prayersSection.rubric { RubricBlock(text: rubric) }

                    Text(viewModel.data.prayersSection.paragraphs[0])
                        .font(.system(size: 17, weight: .regular)).foregroundColor(.primary).multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 4)

                    RubricBlock(text: isSimp ? "¶ 默念主祷文，然后出声启应：" : "¶ 默念主禱文，然後出聲啟應：")
                    BodyText(viewModel.data.prayersSection.paragraphs[1])

                    Divider().padding(.vertical, 6)
                    ForEach(viewModel.data.prayerResponsories, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                } else {
                    Text(isSimp ? "（本日为主日、庆节或八日庆期，省略此「祈祷」，直接诵念祝文。）" : "（本日為主日、慶節或八日慶期，省略此「祈禱」，直接誦唸祝文。）")
                        .font(.system(size: 15, weight: .regular)).italic().foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                }
            }
        }
    }

    // MARK: - 祝文
    private var memorialCollectRubric: String? {
        if hour == .terce {
            return viewModel.isSimplified
                ? "¶ 诵念本日祝文，然后诵念以下纪念祝文。"
                : "¶ 誦唸本日祝文，然後誦唸以下紀念祝文。"
        }
        return viewModel.data.memorialCollect?.rubric
    }

    private var memorialCollectText: String? {
        if hour == .terce { return viewModel.data.dailyCollectText }
        return viewModel.data.memorialCollect?.paragraphs.first
    }

    private var collectsSection: some View {
        let isSimp = viewModel.isSimplified
        return VStack(alignment: .leading, spacing: 12) {
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(text: isSimp ? "祝文" : "祝文")
                    RubricBlock(text: isSimp ? "¶ 祈祷后，或省略祈祷，则简短启应后，直接念下文。" : "¶ 祈禱後，或省略祈禱，則簡短啟應後，直接唸下文。")

                    ForEach(viewModel.data.collectOpeningResponsories, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }

                    Text(isSimp ? "我们要祷告。" : "我們要禱告。").font(.system(size: 17, weight: .medium)).foregroundColor(.primary).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 4)

                    if let mainCollect = viewModel.collectOfTheDay {
                        Text(mainCollect.title).font(.system(size: 17, weight: .semibold)).foregroundColor(LiturgyColors.crimson).padding(.top, 2)
                        BodyText(mainCollect.text)
                    } else {
                        PlaceholderBlock(text: isSimp ? "按当日节期诵念" : "按當日節期誦唸")
                    }

                    Divider().padding(.vertical, 4)
                    
                    if let rubric = memorialCollectRubric { RubricBlock(text: rubric) }
                    if let text = memorialCollectText {
                        Text(text)
                            .font(.system(size: 17, weight: .regular)).foregroundColor(.primary).lineSpacing(6).fixedSize(horizontal: false, vertical: true).padding(.top, 4)
                    }
                }
            }

            LiturgyCard {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.data.collectEndingResponsories, id: \.self) { r in
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
                if !viewModel.data.closingText.paragraphs.isEmpty {
                    let text = viewModel.data.closingText.paragraphs[0]

                    if let openRange = text.range(of: "（", options: .backwards),
                       let closeRange = text.range(of: "）", options: .backwards),
                       openRange.lowerBound < closeRange.lowerBound {

                        let content = String(text[..<openRange.lowerBound])
                        let reference = String(text[openRange.lowerBound...])

                        VStack(alignment: .leading, spacing: 4) {
                            Text(content).font(.system(size: 17, weight: .regular)).foregroundColor(.primary).lineSpacing(6).fixedSize(horizontal: false, vertical: true)
                            Text(reference).font(.system(size: 13, weight: .medium)).foregroundColor(.red).padding(.top, 2).padding(.leading, 4)
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
            Text(hour.endingText(isSimplified: viewModel.isSimplified))
                .font(.system(size: 15, weight: .medium)).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 20)
            Spacer().frame(height: 32)
        }
    }
}
