import SwiftUI
import Combine

// MARK: - 視圖選項枚舉
enum SextReadingOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日與慶節"
    case easter = "復活節期"
    
    func localizedTitle(isSimplified: Bool) -> String {
        switch self {
        case .ordinary: return isSimplified ? "全年平日" : "全年平日"
        case .feast: return isSimplified ? "主日与庆节" : "主日與慶節"
        case .easter: return isSimplified ? "复活节期" : "復活節期"
        }
    }
}

enum SextShortResponseOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日、瞻禮日、復活期"
    
    func localizedTitle(isSimplified: Bool) -> String {
        switch self {
        case .ordinary: return isSimplified ? "全年平日" : "全年平日"
        case .feast: return isSimplified ? "主日、瞻礼日、复活期" : "主日、瞻禮日、復活期"
        }
    }
}

enum SextPrayerOption: String, CaseIterable, Hashable {
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
class SextPrayerViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedReadingOption: SextReadingOption = .ordinary
    @Published var selectedShortResponseOption: SextShortResponseOption = .ordinary
    @Published var selectedPrayerOption: SextPrayerOption = .show

    // 🌟 全局監聽語言設定
    @AppStorage("appLanguage") var appLanguageCode: String = AppLanguage.traditional.rawValue
    var isSimplified: Bool { appLanguageCode == AppLanguage.simplified.rawValue }

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

    var currentAntiphon: SextPrayerData.PsalmAntiphonUI? {
        let title = liturgy.mainTitle
        if SextPrayerData.BVMFeastAntiphon.isBVMFeast(title: title) {
            let text = SextPrayerData.BVMFeastAntiphon.text
            return SextPrayerData.PsalmAntiphonUI(season: isSimplified ? "圣母庆节" : "聖母慶節", text: text, fullText: text)
        }
        
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        let seasonMap: [LiturgicalSeason: String] = [
            .advent: "降臨期", .christmas: "聖誕期", .epiphany: "全年通用",
            .lent: "大齋期", .holyWeek: "大齋期", .easter: "復活期",
            .ascension: "復活期", .pentecost: "復活期", .trinity: "全年通用"
        ]

        let key = seasonMap[info.season] ?? "全年通用"
        let localizedKey = isSimplified ? key.replacingOccurrences(of: "期", with: "期").replacingOccurrences(of: "聖", with: "圣").replacingOccurrences(of: "復", with: "复").replacingOccurrences(of: "齋", with: "斋").replacingOccurrences(of: "臨", with: "临") : key
        
        return SextPrayerData.psalmAntiphons.first { $0.season == localizedKey }
            ?? SextPrayerData.psalmAntiphons.first { $0.season == (isSimplified ? "全年通用" : "全年通用") }
    }

    var currentReading: SextReadingItemJSON? {
        let readings = SextPrayerData.readings
        let matchingKey = selectedReadingOption.localizedTitle(isSimplified: isSimplified)
        return readings.first { $0.season == matchingKey }
    }

    var currentShortResponsorySet: SextPrayerData.ShortResponsorySetUI? {
        switch selectedShortResponseOption {
        case .ordinary: return SextPrayerData.shortResponsesOrdinary
        case .feast:    return isEasterSeason ? SextPrayerData.shortResponsesFeastEaster : SextPrayerData.shortResponsesFeastOrdinary
        }
    }

    var collectOfTheDay: DailyOfficeFile.OfficePeriod.CollectJSON? {
        DailyOfficeLoader.shared.collect(for: selectedDate, liturgy: liturgy)
    }

    var hymnVerses: [String] {
        return SextPrayerData.SeasonalHymnEnding.assemble(
            baseVerses: SextPrayerData.hymn.paragraphs,
            for: selectedDate,
            liturgy: liturgy
        )
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
struct SextPrayerView: View {
    @StateObject private var viewModel: SextPrayerViewModel
    @Environment(\.colorScheme) var colorScheme
    let date: Date
    
    init(date: Date = Date()) {
        self.date = date
        let vm = SextPrayerViewModel()
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
            .onAppear { viewModel.loadData() }
            .background(colorScheme == .dark ? Color.black : LiturgyColors.parchment) 

            dateQuickNavButtons
        }
        .navigationTitle(viewModel.isSimplified ? "六时祷" : "六時禱")
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
            Text(isSimp ? "六  时  祷" : "六  時  禱")
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

    // MARK: - 開始啟應
    private var openingResponsesSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(SextPrayerData.openingResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }

    // MARK: - 聖詩
    private var hymnSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                if let title = SextPrayerData.hymn.title { SectionTitle(text: title) }
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
                    MorningPrayerView.AntiphonRow(text: antiphon.text).padding(.bottom, 4)
                }

                let psalmKeys = SextPrayerData.psalmKeys(for: viewModel.selectedDate)
                ForEach(psalmKeys.indices, id: \.self) { index in
                    let key = psalmKeys[index]
                    if let psalm = PsalmsLoader.shared.psalmContent(for: key) {
                        let displayTitle = SextPrayerData.psalmDisplayTitle(for: key, isSimplified: isSimp)
                        psalmContentView(title: displayTitle, content: psalm)
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

    private func psalmContentView(title: String, content: PsalmContent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title).foregroundColor(LiturgyColors.crimson)
                if !content.latinTitle.isEmpty { Text(content.latinTitle).italic().foregroundColor(.primary) }
            }
            .font(.system(size: 17, weight: .semibold)).padding(.bottom, 4)

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
                    ForEach(SextReadingOption.allCases, id: \.self) { option in
                        Text(option.localizedTitle(isSimplified: isSimp)).tag(option)
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
                    ForEach(SextShortResponseOption.allCases, id: \.self) { option in
                        Text(option.localizedTitle(isSimplified: isSimp)).tag(option)
                    }
                }
                .pickerStyle(.segmented).padding(.vertical, 6)

                if let s = set {
                    RubricBlock(text: "¶ \(s.title)")
                    ForEach(s.responses, id: \.self) { r in
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
                if let title = SextPrayerData.prayersSection.title { SectionTitle(text: title) }

                Picker(isSimp ? "祈祷选择" : "祈禱選擇", selection: $viewModel.selectedPrayerOption) {
                    ForEach(SextPrayerOption.allCases, id: \.self) { option in
                        Text(option.localizedTitle(isSimplified: isSimp)).tag(option)
                    }
                }
                .pickerStyle(.segmented).padding(.vertical, 6)

                if viewModel.selectedPrayerOption == .show {
                    if let rubric = SextPrayerData.prayersSection.rubric { RubricBlock(text: rubric) }

                    Text(SextPrayerData.prayersSection.paragraphs[0])
                        .font(.system(size: 17, weight: .regular)).foregroundColor(.primary).multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 4)

                    RubricBlock(text: isSimp ? "¶ 默念主祷文，然后出声启应：" : "¶ 默念主禱文，然後出聲啟應：")
                    BodyText(SextPrayerData.prayersSection.paragraphs[1])

                    Divider().padding(.vertical, 6)
                    ForEach(SextPrayerData.prayersResponses, id: \.self) { r in
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
    private var collectsSection: some View {
        let isSimp = viewModel.isSimplified
        return VStack(alignment: .leading, spacing: 12) {
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    SectionTitle(text: isSimp ? "祝文" : "祝文")
                    RubricBlock(text: isSimp ? "¶ 祈祷后，或省略祈祷，则简短启应后，直接念下文。" : "¶ 祈禱後，或省略祈禱，則簡短啟應後，直接唸下文。")

                    ForEach(SextPrayerData.collectOpening, id: \.self) { r in
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
                    
                    if let rubric = SextPrayerData.sextMemorialCollect.rubric { RubricBlock(text: rubric) }
                    if !SextPrayerData.sextMemorialCollect.paragraphs.isEmpty {
                        Text(SextPrayerData.sextMemorialCollect.paragraphs[0])
                            .font(.system(size: 17, weight: .regular)).foregroundColor(.primary).lineSpacing(6).fixedSize(horizontal: false, vertical: true).padding(.top, 4)
                    }
                }
            }

            LiturgyCard {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(SextPrayerData.collectEndingResponses, id: \.self) { r in
                        ResponsoryRow(response: r)
                    }
                }
            }
        }
    }

    // MARK: - 結束經文
    private var closingSection: some View {
        let isSimp = viewModel.isSimplified
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                if SextPrayerData.closingText.paragraphs.count > 0 {
                    let text = SextPrayerData.closingText.paragraphs[0]

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
            Text(viewModel.isSimplified ? "❦ 六时祷至此结束。" : "❦ 六時禱至此結束。")
                .font(.system(size: 15, weight: .medium)).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 20)
            Spacer().frame(height: 32)
        }
    }
}
