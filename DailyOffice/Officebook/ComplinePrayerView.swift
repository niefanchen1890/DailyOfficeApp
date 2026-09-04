import SwiftUI
import Combine

// MARK: - 祝文選擇
enum ComplineCollectOption: String, CaseIterable, Hashable {
    case protection = "求護祝文"
    case ambrose = "聖安波羅修祝文"
    case hope = "希望祝文"
    
    func localizedTitle(isSimplified: Bool) -> String {
        switch self {
        case .protection: return isSimplified ? "求护祝文" : "求護祝文"
        case .ambrose: return isSimplified ? "圣安波罗修祝文" : "聖安波羅修祝文"
        case .hope: return isSimplified ? "希望祝文" : "希望祝文"
        }
    }
}

// MARK: - 聖詩類型
enum ComplineHymnType: String, CaseIterable, Hashable {
    case weekday = "平日"
    case feast = "慶節"
    case lent = "大齋期"
    case easter = "復活期"
    
    func localizedTitle(isSimplified: Bool) -> String {
        switch self {
        case .weekday: return isSimplified ? "平日" : "平日"
        case .feast: return isSimplified ? "庆节" : "慶節"
        case .lent: return isSimplified ? "大斋期" : "大齋期"
        case .easter: return isSimplified ? "复活期" : "復活期"
        }
    }
}

// MARK: - 簡短啟應選擇
enum ComplineShortResponseOption: String, CaseIterable, Hashable {
    case ordinary = "復活節期外"
    case easter = "復活期"
    
    func localizedTitle(isSimplified: Bool) -> String {
        switch self {
        case .ordinary: return isSimplified ? "复活节期外" : "復活節期外"
        case .easter: return isSimplified ? "复活期" : "復活期"
        }
    }
}

// MARK: - 祈禱顯示選擇
enum ComplinePrayerOption: String, CaseIterable, Hashable {
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
class ComplinePrayerViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedCollect: ComplineCollectOption = .protection
    @Published var selectedShortResponseOption: ComplineShortResponseOption = .ordinary
    @Published var selectedHymnType: ComplineHymnType = .weekday
    @Published var selectedPrayerOption: ComplinePrayerOption = .show

    @AppStorage("appLanguage") var appLanguageCode: String = AppLanguage.traditional.rawValue
    var isSimplified: Bool { appLanguageCode == AppLanguage.simplified.rawValue }

    private let eveningVM = EveningPrayerViewModel()
    
    var nuncDimittisCanticle: CanticleData {
        eveningVM.secondCanticle
    }
    
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
            "復活後第五主日": isSimplified ? "特祷主日" : "特禱主日",
            "復活後第一主日": isSimplified ? "卸白衣主日" : "卸白衣主日"
        ]
        return map[liturgy.mainTitle]
    }

    var isEasterSeason: Bool {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        return [.easter, .ascension, .pentecost].contains(info.season)
    }

    var isHolyWeek: Bool {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        return info.season == .holyWeek
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

    var currentPsalmAntiphon: ComplinePrayerData.PsalmAntiphonUI? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        let seasonMap: [LiturgicalSeason: String] = [
            .advent: "降臨期", .christmas: "聖誕期", .epiphany: "全年通用",
            .lent: "大齋期", .holyWeek: "大齋期", .easter: "復活期",
            .ascension: "復活期", .pentecost: "復活期", .trinity: "全年通用"
        ]

        let key = seasonMap[info.season] ?? "全年通用"
        let localizedKey = isSimplified ? key.replacingOccurrences(of: "期", with: "期").replacingOccurrences(of: "聖", with: "圣").replacingOccurrences(of: "復", with: "复").replacingOccurrences(of: "齋", with: "斋").replacingOccurrences(of: "臨", with: "临") : key
        
        return ComplinePrayerData.psalmAntiphons.first { $0.season == localizedKey }
            ?? ComplinePrayerData.psalmAntiphons.first { $0.season == (isSimplified ? "全年通用" : "全年通用") }
    }

    var currentShortResponsorySet: ComplinePrayerData.ShortResponsorySetUI {
        switch selectedShortResponseOption {
        case .ordinary: return ComplinePrayerData.shortResponsesOrdinary
        case .easter: return ComplinePrayerData.shortResponsesEaster
        }
    }
    
    var currentPostHymnResponses: [Responsory] {
        isEasterSeason ? ComplinePrayerData.postHymnResponsesEaster : ComplinePrayerData.postHymnResponsesOrdinary
    }
    
    var currentHymn: PrayerSection {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        
        if (49...51).contains(info.daysFromEaster) {
            return ComplinePrayerData.almaChorusHymn
        }
        
        switch selectedHymnType {
        case .easter:
            let season = info.season
            if season == .ascension { return applySeasonalEnding(ComplinePrayerData.ascensionHymn) }
            else if season == .pentecost { return applySeasonalEnding(ComplinePrayerData.pentecostHymn) }
            else { return applySeasonalEnding(ComplinePrayerData.easterHymn) }
        case .lent: return applySeasonalEnding(ComplinePrayerData.lentHymn)
        case .feast: return applySeasonalEnding(ComplinePrayerData.feastHymn)
        case .weekday: return applySeasonalEnding(ComplinePrayerData.weekdayHymn)
        }
    }

    private func applySeasonalEnding(_ base: PrayerSection) -> PrayerSection {
        let verses = PrimePrayerData.SeasonalHymnEnding.assemble(
            baseVerses: base.paragraphs,
            for: selectedDate,
            liturgy: liturgy,
            isSimplified: isSimplified
        )
        return PrayerSection(
            title: base.title,
            rubric: base.rubric,
            paragraphs: verses,
            responses: base.responses
        )
    }

    var commemorationAntiphon: String? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        if info.season == .easter || info.season == .ascension || info.season == .pentecost {
            return isSimplified ? "这是如何充满荣耀的王国！所有圣者在那里与基督一起欢乐。哈利路亚。" : "這是如何充滿榮耀的王國！所有聖者在那裡與基督一起歡樂。哈利路亞。"
        }
        return isSimplified ? "这是如何充满荣耀的王国！所有圣者在那里与基督一起欢乐。" : "這是如何充滿榮耀的王國！所有聖者在那裡與基督一起歡樂。"
    }

    var currentCollect: ComplinePrayerData.CollectOption {
        switch selectedCollect {
        case .protection: return ComplinePrayerData.collectOptions[0]
        case .ambrose:    return ComplinePrayerData.collectOptions[1]
        case .hope:       return ComplinePrayerData.collectOptions[2]
        }
    }

    func loadData() {
        eveningVM.selectedDate = selectedDate // Sync eveningVM
        let info = LiturgyCoreService.shared.getSeasonInfo(for: selectedDate)
        let season = info.season
        let rank = liturgy.rank

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

        if season == .easter || season == .ascension {
            selectedCollect = .hope
        } else {
            selectedCollect = .protection
        }
        selectedShortResponseOption = isEasterSeason ? .easter : .ordinary
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
struct ComplinePrayerView: View {
    @StateObject private var viewModel: ComplinePrayerViewModel
    @Environment(\.colorScheme) var colorScheme
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
            .onAppear { viewModel.loadData() }
            .background(colorScheme == .dark ? Color.black : LiturgyColors.parchment)
            dateQuickNavButtons
        }
        .navigationTitle(viewModel.isSimplified ? "寝前祷" : "寢前禱")
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
            Text(liturgy.mainTitle.adaptChinese(isSimplified: isSimp))
                .font(.system(size: 34, weight: .bold)).foregroundColor(.primary).multilineTextAlignment(.center).padding(.top, 12)

            if let common = viewModel.commonName {
                Text(common).font(.system(size: 18, weight: .semibold)).foregroundColor(LiturgyColors.crimson).padding(.top, 6)
            }
            if !liturgy.rankName.isEmpty {
                Text("（\(liturgy.rankName.adaptChinese(isSimplified: isSimp))）").font(.system(size: 17, weight: .regular)).foregroundColor(LiturgyColors.crimson).padding(.top, 4)
            }

            Divider().background(Color.secondary.opacity(0.25)).padding(.horizontal, 60).padding(.vertical, 20)
            Text(isSimp ? "寝  前  祷" : "寢  前  禱")
                .font(.system(size: 20, weight: .bold)).foregroundColor(.primary).tracking(12).padding(.bottom, 4)

            if !liturgy.commemorations.isEmpty {
                Text((isSimp ? "纪念：" : "紀念：") + liturgy.commemorations.joined(separator: "、").adaptChinese(isSimplified: isSimp))
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
        let isSimp = viewModel.isSimplified
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: ComplinePrayerData.shortReading.title ?? (isSimp ? "简短读经" : "簡短讀經"))
                BodyText(ComplinePrayerData.shortReading.paragraphs[0])

                Text(isSimp ? "（彼得前书 5:8）" : "（彼得前書 5:8）")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.red).padding(.top, 2).padding(.leading, 4)

                Divider().padding(.vertical, 4)
                ResponsoryRow(response: Responsory(leader: "", people: isSimp ? "应：感谢上帝。" : "應：感謝上帝。"))

                ForEach(ComplinePrayerData.readingResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }

                Divider().padding(.vertical, 4)
                RubricBlock(text: isSimp ? "¶ 我们在天上的父，默念主祷文，然后出声启应：" : "¶ 我們在天上的父，默念主禱文，然後出聲啟應：")
                BodyText(isSimp ? "我们在天上的父，愿人都尊父的名为圣。愿父的国降临。愿父的旨意行在地上，如同行在天上。日用的粮食，求父今天赐给我们。又求饶恕我们的罪，如同我们饶恕得罪我们的人。" : "我們在天上的父，願人都尊父的名為聖。願父的國降臨。願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人。")
                
                ForEach(ComplinePrayerData.lordPrayerResponses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }

    private var lordPrayerResponsesSection: some View { EmptyView() }

    // MARK: - 詩篇
    private var psalmsSection: some View {
        let isSimp = viewModel.isSimplified
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimp ? "诗篇" : "詩篇")
                RubricBlock(text: isSimp ? "¶ 然后，念以下诗篇，并按着节期念对应的对经。" : "¶ 然後，唸以下詩篇，並按著節期唸對應的對經。")

                if let antiphon = viewModel.currentPsalmAntiphon {
                    RubricBlock(text: "¶ \(antiphon.season)：")
                }

                let keys = ComplinePrayerData.psalmKeys
                ForEach(keys.indices, id: \.self) { index in
                    let key = keys[index]
                    if let psalm = PsalmsLoader.shared.psalmContent(for: key) {
                        let displayTitle = ComplinePrayerData.psalmDisplayTitle(for: key)
                        let latinSubtitle = ComplinePrayerData.psalmLatinSubtitle(for: key)
                        complinePsalmView(
                            title: displayTitle,
                            latin: latinSubtitle,
                            content: psalm,
                            openingAntiphon: index == 0
                                ? viewModel.currentPsalmAntiphon?.before
                                : nil
                        )
                        if index < keys.count - 1 { Divider().padding(.vertical, 8) }
                    }
                }

                if let antiphon = viewModel.currentPsalmAntiphon {
                    Divider().padding(.vertical, 4)
                    MorningPrayerView.AntiphonRow(text: antiphon.after)
                }
            }
        }
    }

    private func complinePsalmView(
        title: String,
        latin: String,
        content: PsalmContent,
        openingAntiphon: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title).foregroundColor(LiturgyColors.crimson)
                if !latin.isEmpty { Text(latin).italic().foregroundColor(.primary) }
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
        for char in trimmed { if char.isNumber { number.append(char) } else { break } }
        let text = number.isEmpty ? trimmed : String(trimmed.dropFirst(number.count)).trimmingCharacters(in: .whitespaces)

        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            if !number.isEmpty { Text(number).font(.system(size: 17, weight: .regular)).foregroundColor(.red) }
            Text(text).font(.system(size: 17, weight: .regular)).foregroundColor(.primary).lineSpacing(6).fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - 經課
    private var lessonSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: ComplinePrayerData.lesson.title ?? (viewModel.isSimplified ? "经课" : "經課"))
                
                let fullText = ComplinePrayerData.lesson.paragraphs.first ?? ""
                if let openRange = fullText.range(of: "（", options: .backwards),
                   let closeRange = fullText.range(of: "）", options: .backwards),
                   openRange.lowerBound < closeRange.lowerBound {
                    
                    let scripture = String(fullText[..<openRange.lowerBound])
                    let reference = String(fullText[openRange.lowerBound...])
                    
                    BodyText(scripture)
                    Text(reference).font(.system(size: 13, weight: .medium)).foregroundColor(.red).padding(.top, 2).padding(.leading, 4)
                } else {
                    BodyText(fullText)
                }

                if let rubric = ComplinePrayerData.lesson.rubric { RubricBlock(text: rubric) }

                ResponsoryRow(response: Responsory(leader: "", people: viewModel.isSimplified ? "应：感谢上帝。" : "應：感謝上帝。"))
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
                RubricBlock(text: isSimp ? "¶ 按着季节选择以下的简短启应。" : "¶ 按著季節選擇以下的簡短啟應。")

                Picker(isSimp ? "启应选择" : "啟應選擇", selection: $viewModel.selectedShortResponseOption) {
                    ForEach(ComplineShortResponseOption.allCases, id: \.self) { option in
                        Text(option.localizedTitle(isSimplified: isSimp)).tag(option)
                    }
                }
                .pickerStyle(.segmented).padding(.vertical, 6)

                if viewModel.isHolyWeek { RubricBlock(text: isSimp ? "¶ 苦难期不诵念荣耀颂。" : "¶ 苦難期不誦唸榮耀頌。") }

                RubricBlock(text: "¶ \(set.title)")
                ForEach(set.responses, id: \.self) { r in
                    ResponsoryRow(response: r)
                }
            }
        }
    }

    // MARK: - 聖詩
    private var hymnSection: some View {
        let isSimp = viewModel.isSimplified
        let hymnData = viewModel.currentHymn

        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimp ? "圣诗" : "聖詩")

                Picker(isSimp ? "圣诗选择" : "聖詩選擇", selection: $viewModel.selectedHymnType) {
                    ForEach(ComplineHymnType.allCases, id: \.self) { type in
                        Text(type.localizedTitle(isSimplified: isSimp)).tag(type)
                    }
                }
                .pickerStyle(.segmented).padding(.vertical, 6)

                if let rubric = hymnData.rubric { RubricBlock(text: rubric) }

                ForEach(hymnData.paragraphs, id: \.self) { verse in hymnVerseRow(verse) }
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
        for char in text { if chineseDigits.contains(char) { prefix.append(char) } else if char == "、" && !prefix.isEmpty { prefix.append(char); return prefix } else { break } }
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

    // MARK: - 頌歌（西面頌）
    private var nuncDimittisSection: some View {
        let canticle = viewModel.nuncDimittisCanticle
        let antiphon = viewModel.nuncDimittisAntiphon
        let isSimp = viewModel.isSimplified

        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(canticle.title).font(.system(size: 20, weight: .bold)).foregroundColor(LiturgyColors.crimson)
                    if let subtitle = canticle.subtitle { Text(subtitle).font(.system(size: 14, weight: .medium)).foregroundColor(.primary) }
                }

                RubricBlock(text: isSimp ? "¶ 然后念此颂歌，并相应的对经。" : "¶ 然後唸此頌歌，並相應的對經。")

                MorningPrayerView.AntiphonRow(text: antiphon).padding(.bottom, 4)

                if canticle.style == "responsive", let verses = canticle.verses {
                    ForEach(verses) { verse in canticleVerseRow(verse) }
                } else if let paragraphs = canticle.paragraphs {
                    ForEach(paragraphs.indices, id: \.self) { i in BodyText(paragraphs[i]) }
                }

                if let doxology = canticle.doxology {
                    VStack(alignment: .leading, spacing: 2) { Text(doxology).font(.system(size: 17)).foregroundColor(.primary) }.padding(.top, 8)
                }

                MorningPrayerView.AntiphonRow(text: antiphon).padding(.top, 8)
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

    // MARK: - 祈禱
    private var prayersSection: some View {
        let isSimp = viewModel.isSimplified
        return LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimp ? "祈祷" : "祈禱")

                Picker(isSimp ? "祈祷选择" : "祈禱選擇", selection: $viewModel.selectedPrayerOption) {
                    ForEach(ComplinePrayerOption.allCases, id: \.self) { option in
                        Text(option.localizedTitle(isSimplified: isSimp)).tag(option)
                    }
                }
                .pickerStyle(.segmented).padding(.vertical, 6)

                if viewModel.selectedPrayerOption == .show {
                    if let rubric = ComplinePrayerData.prayersSection.rubric { RubricBlock(text: rubric) }

                    Text(ComplinePrayerData.prayersSection.paragraphs[0])
                        .font(.system(size: 17, weight: .regular)).foregroundColor(.primary).multilineTextAlignment(.center).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 4)

                    RubricBlock(text: isSimp ? "¶ 默念主祷文，然后出声启应：" : "¶ 默念主禱文，然後出聲啟應：")
                    BodyText(ComplinePrayerData.prayersSection.paragraphs[1])

                    Divider().padding(.vertical, 6)

                    ForEach(0..<2, id: \.self) { i in ResponsoryRow(response: ComplinePrayerData.prayersResponses[i]) }

                    RubricBlock(text: isSimp ? "¶ 默念「使徒信经」，然后出声启应：" : "¶ 默唸「使徒信經」，然後出聲啟應：")
                    let remainingResponses = Array(ComplinePrayerData.prayersResponses.dropFirst(2))
                    ForEach(remainingResponses, id: \.self) { r in ResponsoryRow(response: r) }

                    if let rubric = ComplinePrayerData.confession.rubric { RubricBlock(text: rubric) }
                    ForEach(ComplinePrayerData.confession.paragraphs, id: \.self) { p in BodyText(p) }
                    RubricBlock(text: ComplinePrayerData.confessionNote)

                    if let rubric = ComplinePrayerData.absolutionClergy.rubric { RubricBlock(text: rubric) }
                    ForEach(ComplinePrayerData.absolutionClergy.paragraphs, id: \.self) { p in BodyText(p) }
                    ForEach(ComplinePrayerData.postAbsolutionResponses, id: \.self) { r in ResponsoryRow(response: r) }

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

                    ForEach(ComplinePrayerData.preCollectResponses, id: \.self) { r in ResponsoryRow(response: r) }

                    Text(isSimp ? "我们要祷告。" : "我們要禱告。").font(.system(size: 17, weight: .medium)).foregroundColor(.primary).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 4)

                    Picker(isSimp ? "祝文选择" : "祝文選擇", selection: $viewModel.selectedCollect) {
                        ForEach(ComplineCollectOption.allCases, id: \.self) { option in
                            Text(option.localizedTitle(isSimplified: isSimp)).tag(option)
                        }
                    }
                    .pickerStyle(.segmented).padding(.vertical, 6)

                    let collect = viewModel.currentCollect
                    Text(collect.title).font(.system(size: 17, weight: .semibold)).foregroundColor(LiturgyColors.crimson).padding(.top, 2)
                    BodyText(collect.text)

                    ForEach(ComplinePrayerData.postCollectResponses, id: \.self) { r in ResponsoryRow(response: r) }
                }
            }
        }
    }

    // MARK: - 紀念聖母與諸聖
    private var commemorationSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: ComplinePrayerData.commemorationSection.title ?? (viewModel.isSimplified ? "纪念圣母与诸圣" : "紀念聖母與諸聖"))

                if let rubric = ComplinePrayerData.commemorationSection.rubric { RubricBlock(text: rubric) }

                if let antiphon = viewModel.commemorationAntiphon {
                    MorningPrayerView.AntiphonRow(text: antiphon).padding(.bottom, 4)
                }

                ForEach(ComplinePrayerData.commemorationResponsesBefore, id: \.self) { r in ResponsoryRow(response: r) }

                Divider().padding(.vertical, 4)
                BodyText(ComplinePrayerData.commemorationSection.paragraphs[0])
                ForEach(ComplinePrayerData.commemorationResponsesAfter, id: \.self) { r in ResponsoryRow(response: r) }
            }
        }
    }

    // MARK: - 結尾
    private var endingSection: some View {
        VStack(spacing: 0) {
            Text(viewModel.isSimplified ? "❦ 寝前祷至此结束。" : "❦ 寢前禱至此結束。")
                .font(.system(size: 15, weight: .medium)).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 20)
            Spacer().frame(height: 32)
        }
    }
}
