import SwiftUI

// MARK: - 主視圖
struct LectionaryView: View {
    @AppStorage("lectionaryYear") private var selectedYear = "1928"
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        VStack(spacing: 0) {
            // 頂部切換按鈕
            Picker("經課表版本".adaptChinese(isSimplified: isSimp), selection: $selectedYear) {
                Text("美國1928年版".adaptChinese(isSimplified: isSimp)).tag("1928")
                Text("加拿大1962年版".adaptChinese(isSimplified: isSimp)).tag("1962")
                Text("美國1943年版".adaptChinese(isSimplified: isSimp)).tag("1943")
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(.systemBackground))
            
            Divider()
            
            // 依年份切換視圖
            if selectedYear == "1943" {
                Lectionary1943View()
            } else {
                List {
                    ForEach(LiturgicalSeason.allCases.filter {
                        $0 != .holyWeek && $0 != .ascension && $0 != .pentecost
                    }, id: \.self) { season in
                        DisclosureGroup {
                            switch season {
                            case .advent:      AdventSeasonView(year: selectedYear)
                            case .christmas:   ChristmasSeasonView(year: selectedYear)
                            case .epiphany:    EpiphanySeasonView(year: selectedYear)
                            case .prelenten:   PreLentenSeasonView(year: selectedYear)
                            case .lent:        LentenSeasonView(year: selectedYear)
                            case .easter:      EasterSeasonView(year: selectedYear)
                            case .trinity:     TrinitySeasonView(year: selectedYear)
                            case .holyDays:    HolyDaysView(year: selectedYear)
                            default:           RegularSeasonView(season: season, year: selectedYear)
                            }
                        } label: {
                            Text(season.title.adaptChinese(isSimplified: isSimp))
                                .font(.headline)
                                .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255))
                                .padding(.vertical, 6)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("經課表".adaptChinese(isSimplified: isSimp))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 3. 降臨期專屬視圖
struct AdventSeasonView: View {
    let year: String
    @State private var weeksData: [Int: [DayLectionaryGroup]] = [:]
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        ForEach(1...4, id: \.self) { week in
            DisclosureGroup("降臨期第\(week.chineseString)主日".adaptChinese(isSimplified: isSimp)) {
                if let daysGrouped = weeksData[week], !daysGrouped.isEmpty {
                    LectionaryTableView(weeklyData: daysGrouped)
                        .padding(.vertical, 8)
                } else {
                    ProgressView("載入中...".adaptChinese(isSimplified: isSimp))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .onAppear { loadData(for: week) }
                }
            }
        }
        .onChange(of: year) { weeksData.removeAll() }
    }
    
    private func loadData(for week: Int) {
        guard weeksData[week] == nil else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            let rawData = LectionaryJSONService.shared.fetchLectionary(year: year, season: "ad", week: week)
            let groupedData = groupDataForTable(rawData)
            DispatchQueue.main.async {
                self.weeksData[week] = groupedData
            }
        }
    }
    
    private func groupDataForTable(_ rawDays: [LectionaryDay]) -> [DayLectionaryGroup] {
        var dict: [Int: DayLectionaryGroup] = [:]
        for i in 0...6 {
            let name = i == 0 ? "日" : i.chineseString
            dict[i] = DayLectionaryGroup(dayIndex: i, dayName: name)
        }
        
        for day in rawDays {
            let parts = day.dayKey.components(separatedBy: "-")
            guard parts.count >= 4, let dayIndex = Int(parts[1]) else { continue }
            
            let isYear2 = day.dayKey.contains("-yr2-")
            let time = parts[parts.count - 2]
            let testament = parts[parts.count - 1]
            
            if isYear2 {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1_yr2 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2_yr2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1_yr2 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2_yr2 = day }
            } else {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2 = day }
            }
        }
        return dict.values.sorted(by: { $0.dayIndex < $1.dayIndex })
    }
}

struct DayLectionaryGroup: Identifiable {
    var id: Int { dayIndex }
    let dayIndex: Int
    let dayName: String
    var customName: String? = nil
    var specialNote: String? = nil
    
    var displayName: String {
        customName ?? dayName
    }
    
    var morning1: LectionaryDay?
    var morning2: LectionaryDay?
    var evening1: LectionaryDay?
    var evening2: LectionaryDay?
    
    var morning1_yr2: LectionaryDay?
    var morning2_yr2: LectionaryDay?
    var evening1_yr2: LectionaryDay?
    var evening2_yr2: LectionaryDay?
    
    var hasYear2: Bool {
        morning1_yr2 != nil || morning2_yr2 != nil || evening1_yr2 != nil || evening2_yr2 != nil
    }
}

// MARK: - 經課表格
struct LectionaryTableView: View {
    let weeklyData: [DayLectionaryGroup]
    var isHolyDayMode: Bool = false
    @State private var selectedLesson: LectionaryDay?
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(weeklyData) { dayGroup in
                VStack(alignment: .leading, spacing: 8) {
                    Text(dayTitle(for: dayGroup).adaptChinese(isSimplified: isSimp))
                        .font(.subheadline.bold())
                        .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255))

                    if let note = dayGroup.specialNote {
                        Text(note.adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else if isHolyDayMode && dayGroup.displayName == "前夕" {
                        officeCard(
                            title: "前晚",
                            systemImage: "moon.fill",
                            accentColor: .indigo,
                            firstLesson: dayGroup.evening1,
                            secondLesson: dayGroup.evening2
                        )
                    } else if dayGroup.hasYear2 {
                        yearCards(
                            title: "第一年",
                            morning1: dayGroup.morning1,
                            morning2: dayGroup.morning2,
                            evening1: dayGroup.evening1,
                            evening2: dayGroup.evening2
                        )
                        yearCards(
                            title: "第二年",
                            morning1: dayGroup.morning1_yr2,
                            morning2: dayGroup.morning2_yr2,
                            evening1: dayGroup.evening1_yr2,
                            evening2: dayGroup.evening2_yr2
                        )
                    } else {
                        officeCard(
                            title: "早禱",
                            systemImage: "sunrise.fill",
                            accentColor: .orange,
                            firstLesson: dayGroup.morning1,
                            secondLesson: dayGroup.morning2
                        )
                        officeCard(
                            title: "晚禱",
                            systemImage: "moon.fill",
                            accentColor: .indigo,
                            firstLesson: dayGroup.evening1,
                            secondLesson: dayGroup.evening2
                        )
                    }
                }
            }
        }
        .navigationDestination(item: $selectedLesson) { day in
            ScriptureDetailView(day: day)
        }
    }

    private func dayTitle(for group: DayLectionaryGroup) -> String {
        switch group.displayName {
        case "日": return "主日"
        case "一", "二", "三", "四", "五", "六": return "禮拜\(group.displayName)"
        default: return group.displayName
        }
    }

    @ViewBuilder
    private func yearCards(
        title: String,
        morning1: LectionaryDay?,
        morning2: LectionaryDay?,
        evening1: LectionaryDay?,
        evening2: LectionaryDay?
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.adaptChinese(isSimplified: isSimp))
                .font(.caption.bold())
                .foregroundColor(.secondary)

            officeCard(
                title: "早禱",
                systemImage: "sunrise.fill",
                accentColor: .orange,
                firstLesson: morning1,
                secondLesson: morning2
            )
            officeCard(
                title: "晚禱",
                systemImage: "moon.fill",
                accentColor: .indigo,
                firstLesson: evening1,
                secondLesson: evening2
            )
        }
    }

    private func officeCard(
        title: String,
        systemImage: String,
        accentColor: Color,
        firstLesson: LectionaryDay?,
        secondLesson: LectionaryDay?
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title.adaptChinese(isSimplified: isSimp), systemImage: systemImage)
                .font(.caption.bold())
                .foregroundColor(accentColor)

            Divider()

            HStack(alignment: .top, spacing: 0) {
                lessonColumn(
                    title: "第一經課",
                    lesson: firstLesson
                )

                Divider()
                    .frame(height: 54)
                    .padding(.horizontal, 12)

                lessonColumn(
                    title: "第二經課",
                    lesson: secondLesson
                )
            }
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func lessonColumn(title: String, lesson: LectionaryDay?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.adaptChinese(isSimplified: isSimp))
                .font(.caption2.bold())
                .foregroundColor(.secondary)

            if let lesson {
                Button {
                    selectedLesson = lesson
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(lesson.book.adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)

                        Text(lesson.chapter.adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 11))
                            .lineLimit(2)
                    }
                    .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                Text("—")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 其他節期視圖
struct ChristmasSeasonView: View {
    let year: String
    private let sectionTitles = ["聖誕日", "聖誕後第一主日", "聖誕後第二主日"]
    @State private var christmasDataGroups: [String: [DayLectionaryGroup]] = [:]
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }

    var body: some View {
        ForEach(sectionTitles, id: \.self) { title in
            DisclosureGroup(title.adaptChinese(isSimplified: isSimp)) {
                if let data = christmasDataGroups[title], !data.isEmpty {
                    LectionaryTableView(weeklyData: data)
                        .padding(.vertical, 8)
                } else {
                    ProgressView("載入中...".adaptChinese(isSimplified: isSimp))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .onAppear {
                            loadDataForSection(title)
                        }
                }
            }
        }
        .onChange(of: year) {
            christmasDataGroups.removeAll()
        }
    }

    private func loadDataForSection(_ title: String) {
        guard christmasDataGroups[title] == nil else { return }
        // 內容載入邏輯不變 ...
        let keys: [(label: String, key: String)]
        switch title {
        case "聖誕日":
            keys = [
                ("聖誕前夕", "1225-eve"), ("聖誕日", "1225"), ("聖司提反日", "1226"),
                ("聖約翰日", "1227"), ("嬰孩被殺日", "1228")
            ]
        case "聖誕後第一主日":
            keys = [
                ("聖誕後一主日", "christmas1"), ("十二月廿九日", "1229"),
                ("十二月三十日", "1230"), ("十二月卅一日", "1231")
            ]
        case "聖誕後第二主日":
            keys = [
                ("救主受割禮日", "0101"), ("聖誕後二主日", "christmas2"),
                ("一月二日", "0102"), ("一月三日", "0103"),
                ("一月四日", "0104"), ("一月五日", "0105")
            ]
        default:
            keys = []
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var tempGroups: [DayLectionaryGroup] = []
            
            for (index, def) in keys.enumerated() {
                if year == "1928" && def.key == "1225-eve" { continue }
                
                let rawData = LectionaryJSONService.shared.fetchLectionaryBySpecificKey(year: year, keyPrefix: def.key)
                var group = DayLectionaryGroup(dayIndex: index, dayName: def.label)
                
                for day in rawData {
                    if def.key == "1225" && day.dayKey.contains("-eve-") { continue }
                    
                    let parts = day.dayKey.components(separatedBy: "-")
                    guard parts.count >= 3 else { continue }
                    
                    let isYear2 = day.dayKey.contains("-yr2-")
                    let time = day.dayKey.contains("-eve-") ? "E" : parts[parts.count - 2]
                    let testament = parts[parts.count - 1]
                    
                    if isYear2 {
                        if time == "M" && testament == "OT" { group.morning1_yr2 = day }
                        if time == "M" && testament == "NT" { group.morning2_yr2 = day }
                        if time == "E" && testament == "OT" { group.evening1_yr2 = day }
                        if time == "E" && testament == "NT" { group.evening2_yr2 = day }
                    } else {
                        if time == "M" && testament == "OT" { group.morning1 = day }
                        if time == "M" && testament == "NT" { group.morning2 = day }
                        if time == "E" && testament == "OT" { group.evening1 = day }
                        if time == "E" && testament == "NT" { group.evening2 = day }
                    }
                }
                tempGroups.append(group)
            }

            DispatchQueue.main.async {
                self.christmasDataGroups[title] = tempGroups
            }
        }
    }
}

struct EpiphanySeasonView: View {
    let year: String
    @State private var weeksData: [Int: [DayLectionaryGroup]] = [:]
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        ForEach(0...6, id: \.self) { week in
            DisclosureGroup(getWeekTitle(week).adaptChinese(isSimplified: isSimp)) {
                if let data = weeksData[week], !data.isEmpty {
                    LectionaryTableView(weeklyData: data)
                        .padding(.vertical, 8)
                } else {
                    ProgressView("載入中...".adaptChinese(isSimplified: isSimp))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .onAppear { loadData(for: week) }
                }
            }
        }
        .onChange(of: year) { weeksData.removeAll() }
    }
    
    private func getWeekTitle(_ week: Int) -> String {
        if week == 0 {
            return "顯現日"
        } else {
            return "顯現後第\(week.chineseString)主日"
        }
    }
    
    private func loadData(for week: Int) {
        guard weeksData[week] == nil else { return }
        
        if week == 0 {
            loadEpiphanyDay()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let rawData = LectionaryJSONService.shared.fetchLectionary(
                year: year,
                season: "epiphany",
                week: week
            )
            
            let groupedData = self.groupDataForTable(rawData)
            
            DispatchQueue.main.async {
                self.weeksData[week] = groupedData
            }
        }
    }
    
    private func loadEpiphanyDay() {
        DispatchQueue.global(qos: .userInitiated).async {
            var tempGroups: [DayLectionaryGroup] = []
            
            let epiphanyDayData = LectionaryJSONService.shared.fetchLectionaryBySpecificKey(year: self.year, keyPrefix: "0106")
            var dayGroup = DayLectionaryGroup(dayIndex: 0, dayName: "顯現日")
            
            for day in epiphanyDayData {
                let parts = day.dayKey.components(separatedBy: "-")
                guard parts.count >= 3 else { continue }
                
                let isYear2 = day.dayKey.contains("-yr2-")
                let time = parts[parts.count - 2]
                let testament = parts[parts.count - 1]
                
                if isYear2 {
                    if time == "M" && testament == "OT" { dayGroup.morning1_yr2 = day }
                    if time == "M" && testament == "NT" { dayGroup.morning2_yr2 = day }
                    if time == "E" && testament == "OT" { dayGroup.evening1_yr2 = day }
                    if time == "E" && testament == "NT" { dayGroup.evening2_yr2 = day }
                } else {
                    if time == "M" && testament == "OT" { dayGroup.morning1 = day }
                    if time == "M" && testament == "NT" { dayGroup.morning2 = day }
                    if time == "E" && testament == "OT" { dayGroup.evening1 = day }
                    if time == "E" && testament == "NT" { dayGroup.evening2 = day }
                }
            }
            tempGroups.append(dayGroup)
            
            let weekDaysData = LectionaryJSONService.shared.fetchLectionary(
                year: self.year,
                season: "epiphany",
                week: 0
            )
            
            let groupedWeekDays = self.groupDataForTable(weekDaysData)
            
            for i in 1...6 {
                if let weekdayGroup = groupedWeekDays.first(where: { $0.dayIndex == i }) {
                    tempGroups.append(weekdayGroup)
                }
            }
            
            DispatchQueue.main.async {
                self.weeksData[0] = tempGroups
            }
        }
    }
    
    private func groupDataForTable(_ rawDays: [LectionaryDay]) -> [DayLectionaryGroup] {
        var dict: [Int: DayLectionaryGroup] = [:]
        for i in 0...6 {
            let name = i == 0 ? "日" : i.chineseString
            dict[i] = DayLectionaryGroup(dayIndex: i, dayName: name)
        }
        
        for day in rawDays {
            let parts = day.dayKey.components(separatedBy: "-")
            guard parts.count >= 4, let dayIndex = Int(parts[1]) else { continue }
            
            let isYear2 = day.dayKey.contains("-yr2-")
            let time = parts[parts.count - 2]
            let testament = parts[parts.count - 1]
            
            if isYear2 {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1_yr2 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2_yr2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1_yr2 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2_yr2 = day }
            } else {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2 = day }
            }
        }
        return dict.values.sorted(by: { $0.dayIndex < $1.dayIndex })
    }
}

struct PreLentenSeasonView: View {
    let year: String
    private let seasons = [
        (title: "七旬主日", key: "septuagesima"),
        (title: "六旬主日", key: "sexagesima"),
        (title: "五旬主日", key: "quinquagesima")
    ]
    
    @State private var seasonData: [String: [DayLectionaryGroup]] = [:]
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        ForEach(seasons, id: \.key) { item in
            DisclosureGroup(item.title.adaptChinese(isSimplified: isSimp)) {
                if let days = seasonData[item.key], !days.isEmpty {
                    LectionaryTableView(weeklyData: days)
                        .padding(.vertical, 8)
                } else {
                    ProgressView("載入中...".adaptChinese(isSimplified: isSimp))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .onAppear { loadData(for: item.key) }
                }
            }
        }
        .onChange(of: year) { seasonData.removeAll() }
    }
    
    private func loadData(for seasonKey: String) {
        guard seasonData[seasonKey] == nil else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let rawData = LectionaryJSONService.shared.fetchLectionary(
                year: year,
                season: seasonKey,
                week: 0
            )
            
            var groupedData = self.groupDataForTable(rawData)
            
            if seasonKey == "quinquagesima" {
                groupedData = groupedData.filter { $0.dayIndex <= 2 }
            }
            
            DispatchQueue.main.async {
                self.seasonData[seasonKey] = groupedData
            }
        }
    }
    
    private func groupDataForTable(_ rawDays: [LectionaryDay]) -> [DayLectionaryGroup] {
        var dict: [Int: DayLectionaryGroup] = [:]
        for i in 0...6 {
            let name = i == 0 ? "日" : i.chineseString
            dict[i] = DayLectionaryGroup(dayIndex: i, dayName: name)
        }
        
        for day in rawDays {
            let parts = day.dayKey.components(separatedBy: "-")
            guard parts.count >= 4, let dayIndex = Int(parts[1]) else { continue }
            
            let isYear2 = day.dayKey.contains("-yr2-")
            let time = parts[parts.count - 2]
            let testament = parts[parts.count - 1]
            
            if isYear2 {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1_yr2 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2_yr2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1_yr2 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2_yr2 = day }
            } else {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2 = day }
            }
        }
        return dict.values.sorted(by: { $0.dayIndex < $1.dayIndex })
    }
}

struct LentenSeasonView: View {
    let year: String
    @State private var weeksData: [Int: [DayLectionaryGroup]] = [:]
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        ForEach(0...6, id: \.self) { week in
            DisclosureGroup(getWeekTitle(week).adaptChinese(isSimplified: isSimp)) {
                if let data = weeksData[week], !data.isEmpty {
                    LectionaryTableView(weeklyData: data)
                        .padding(.vertical, 8)
                } else {
                    ProgressView("載入中...".adaptChinese(isSimplified: isSimp))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .onAppear { loadData(for: week) }
                }
            }
        }
        .onChange(of: year) { weeksData.removeAll() }
    }
    
    private func getWeekTitle(_ week: Int) -> String {
        switch week {
        case 0: return "大齋首日"
        case 1: return "大齋第一主日"
        case 2: return "大齋第二主日"
        case 3: return "大齋第三主日"
        case 4: return "大齋第四主日"
        case 5: return "苦難主日"
        case 6: return "棕樹主日"
        default: return ""
        }
    }
    
    private func loadData(for week: Int) {
        guard weeksData[week] == nil else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let rawData: [LectionaryDay]
            var isAshWeek = false
            
            if week == 0 {
                rawData = LectionaryJSONService.shared.fetchLectionary(year: year, season: "quinquagesima", week: 0)
                isAshWeek = true
            } else {
                rawData = LectionaryJSONService.shared.fetchLectionary(year: year, season: "lent", week: week)
            }
            
            var groupedData = self.groupDataForTable(rawData, isAshWeek: isAshWeek)
            
            if week == 0 {
                groupedData = groupedData.filter { $0.dayIndex >= 3 }
            }
            
            DispatchQueue.main.async {
                self.weeksData[week] = groupedData
            }
        }
    }
    
    private func groupDataForTable(_ rawDays: [LectionaryDay], isAshWeek: Bool = false) -> [DayLectionaryGroup] {
        var dict: [Int: DayLectionaryGroup] = [:]
        
        for i in 0...6 {
            var name = i == 0 ? "日" : i.chineseString
            if isAshWeek && i == 3 {
                name = "大齋首日"
            }
            dict[i] = DayLectionaryGroup(dayIndex: i, dayName: name)
        }
        
        for day in rawDays {
            let parts = day.dayKey.components(separatedBy: "-")
            guard parts.count >= 4, let dayIndex = Int(parts[1]) else { continue }
            
            let isYear2 = day.dayKey.contains("-yr2-")
            let time = parts[parts.count - 2]
            let testament = parts[parts.count - 1]
            
            if isYear2 {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1_yr2 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2_yr2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1_yr2 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2_yr2 = day }
            } else {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2 = day }
            }
        }
        return dict.values.sorted(by: { $0.dayIndex < $1.dayIndex })
    }
}

struct EasterSeasonView: View {
    let year: String
    @State private var weeksData: [Int: [DayLectionaryGroup]] = [:]
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        ForEach(0...7, id: \.self) { week in
            DisclosureGroup(getWeekTitle(week).adaptChinese(isSimplified: isSimp)) {
                if let data = weeksData[week], !data.isEmpty {
                    LectionaryTableView(weeklyData: data)
                        .padding(.vertical, 8)
                } else if weeksData[week] != nil {
                    Text("此周經課數據尚未收錄".adaptChinese(isSimplified: isSimp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ProgressView("載入中...".adaptChinese(isSimplified: isSimp))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .onAppear { loadData(for: week) }
                }
            }
        }
        .onChange(of: year) { weeksData.removeAll() }
    }
    
    private func getWeekTitle(_ week: Int) -> String {
        switch week {
        case 0: return "救主復活日"
        case 1: return "復活後第一主日"
        case 2: return "復活後第二主日"
        case 3: return "復活後第三主日"
        case 4: return "復活後第四主日"
        case 5: return "復活後第五主日（特禱主日）"
        case 6: return "升天後主日"
        case 7: return "聖靈降臨主日"
        default: return ""
        }
    }
    
    private func loadData(for week: Int) {
        guard weeksData[week] == nil else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let dbWeek = week + 1
            
            let rawData = LectionaryJSONService.shared.fetchLectionary(
                year: year,
                season: "easter",
                week: dbWeek
            )
            
            let groupedData = self.groupDataForTable(rawData, week: week)
    
            DispatchQueue.main.async {
                self.weeksData[week] = groupedData
            }
        }
    }
    
    private func groupDataForTable(_ rawDays: [LectionaryDay], week: Int) -> [DayLectionaryGroup] {
        var dict: [Int: DayLectionaryGroup] = [:]
        
        for i in 0...6 {
            var name = i == 0 ? "日" : i.chineseString
            if week == 5 {
                switch i {
                case 1: name = "特禱一"
                case 2: name = "特禱二"
                case 3: name = "特禱三"
                case 4: name = "升天日"
                default: break
                }
            }
            dict[i] = DayLectionaryGroup(dayIndex: i, dayName: name)
        }
        
        for day in rawDays {
            let parts = day.dayKey.components(separatedBy: "-")
            guard parts.count >= 4, let dayIndex = Int(parts[1]) else { continue }
            
            let isYear2 = day.dayKey.contains("-yr2-")
            let time = parts[parts.count - 2]
            let testament = parts[parts.count - 1]
            
            if isYear2 {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1_yr2 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2_yr2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1_yr2 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2_yr2 = day }
            } else {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2 = day }
            }
        }
        return dict.values.sorted(by: { $0.dayIndex < $1.dayIndex })
    }
}

struct AscensionSeasonView: View {
    let year: String
    @State private var ascensionDayData: [DayLectionaryGroup] = []
    @State private var ascensionSundayData: [DayLectionaryGroup] = []
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        Group {
            DisclosureGroup("救主升天日".adaptChinese(isSimplified: isSimp)) {
                if !ascensionDayData.isEmpty {
                    LectionaryTableView(weeklyData: ascensionDayData)
                        .padding(.vertical, 8)
                } else {
                    ProgressView("載入中...".adaptChinese(isSimplified: isSimp)).onAppear { loadAscensionDayData() }
                }
            }
            
            DisclosureGroup("升天後主日".adaptChinese(isSimplified: isSimp)) {
                if !ascensionSundayData.isEmpty {
                    LectionaryTableView(weeklyData: ascensionSundayData)
                        .padding(.vertical, 8)
                } else {
                    ProgressView("載入中...".adaptChinese(isSimplified: isSimp)).onAppear { loadAscensionSundayData() }
                }
            }
        }
        .onChange(of: year) {
            ascensionDayData.removeAll()
            ascensionSundayData.removeAll()
        }
    }
    
    private func loadAscensionDayData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let rawData = LectionaryJSONService.shared.fetchLectionary(year: year, season: "easter", week: 5)
            let dictionary = self.buildGroupDictionary(from: rawData, prefix: "ascDay")
            
            var groups: [DayLectionaryGroup] = []
            for i in 4...6 {
                if var group = dictionary[i] {
                    if i == 4 { group.customName = "升天日" }
                    groups.append(group)
                }
            }
            DispatchQueue.main.async { self.ascensionDayData = groups }
        }
    }
    
    private func loadAscensionSundayData() {
        DispatchQueue.global(qos: .userInitiated).async {
            let rawData = LectionaryJSONService.shared.fetchLectionary(year: year, season: "easter", week: 6)
            let dictionary = self.buildGroupDictionary(from: rawData, prefix: "ascSun")
            
            let groups = (0...6).compactMap { dictionary[$0] }
            DispatchQueue.main.async { self.ascensionSundayData = groups }
        }
    }
    
    private func buildGroupDictionary(from rawDays: [LectionaryDay], prefix: String) -> [Int: DayLectionaryGroup] {
        var dict: [Int: DayLectionaryGroup] = [:]
        for i in 0...6 {
            let name = i == 0 ? "日" : i.chineseString
            dict[i] = DayLectionaryGroup(dayIndex: i, dayName: name)
        }
        
        for day in rawDays {
            let parts = day.dayKey.components(separatedBy: "-")
            guard parts.count >= 4, let dayIndex = Int(parts[1]) else { continue }
            
            let isYear2 = day.dayKey.contains("-yr2-")
            let time = parts[parts.count - 2]
            let testament = parts[parts.count - 1]
            
            if isYear2 {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1_yr2 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2_yr2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1_yr2 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2_yr2 = day }
            } else {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2 = day }
            }
        }
        return dict
    }
}

struct PentecostSeasonView: View {
    let year: String
    @State private var pentecostData: [DayLectionaryGroup] = []
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        DisclosureGroup("聖靈降臨主日 (Whitsunday)".adaptChinese(isSimplified: isSimp)) {
            if !pentecostData.isEmpty {
                LectionaryTableView(weeklyData: pentecostData)
                    .padding(.vertical, 8)
            } else {
                ProgressView("載入中...".adaptChinese(isSimplified: isSimp))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .onAppear { loadData() }
            }
        }
        .onChange(of: year) { pentecostData.removeAll() }
    }
    
    private func loadData() {
        guard pentecostData.isEmpty else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // 兩套 JSON 都以 Easter 第 8 週保存聖靈降臨週經課。
            let rawData = LectionaryJSONService.shared.fetchLectionary(year: year, season: "easter", week: 8)
            let groupedData = self.groupDataForTable(rawData)
            
            DispatchQueue.main.async {
                self.pentecostData = groupedData
            }
        }
    }
    
    private func groupDataForTable(_ rawDays: [LectionaryDay]) -> [DayLectionaryGroup] {
        var dict: [Int: DayLectionaryGroup] = [:]
        for i in 0...6 {
            let name = i == 0 ? "日" : i.chineseString
            dict[i] = DayLectionaryGroup(dayIndex: i, dayName: name)
        }
        
        for day in rawDays {
            let parts = day.dayKey.components(separatedBy: "-")
            guard parts.count >= 4, let dayIndex = Int(parts[1]) else { continue }
            
            let isYear2 = day.dayKey.contains("-yr2-")
            let time = parts[parts.count - 2]
            let testament = parts[parts.count - 1]
            
            if isYear2 {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1_yr2 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2_yr2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1_yr2 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2_yr2 = day }
            } else {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2 = day }
            }
        }
        return dict.values.sorted(by: { $0.dayIndex < $1.dayIndex })
    }
}

struct TrinitySeasonView: View {
    let year: String
    @State private var weeksData: [Int: [DayLectionaryGroup]] = [:]
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        ForEach(0...27, id: \.self) { week in
            DisclosureGroup(getTrinityWeekTitle(week).adaptChinese(isSimplified: isSimp)) {
                if let data = weeksData[week] {
                    LectionaryTableView(weeklyData: data)
                        .padding(.vertical, 8)
                } else {
                    ProgressView("載入中...".adaptChinese(isSimplified: isSimp))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .onAppear { loadData(for: week) }
                }
            }
        }
        .onChange(of: year) { _, _ in
            weeksData.removeAll()
        }
    }
    
    private func getTrinityWeekTitle(_ week: Int) -> String {
        switch week {
        case 0: return "三一主日"
        case 27: return "降臨前主日"
        default: return "三一後第\(week.chineseString)主日"
        }
    }
    
    private func loadData(for week: Int) {
        guard weeksData[week] == nil else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let dbPrefix = week == 0 ? "tr" : "tr\(week)"
            
            let rawData = LectionaryJSONService.shared.fetchLectionaryBySpecificKey(
                year: year,
                keyPrefix: dbPrefix
            )
            
            var groupedData = self.groupDataForTable(rawData)
            
            if year == "1928" && (week == 25 || week == 26) {
                if let sundayIndex = groupedData.firstIndex(where: { $0.dayIndex == 0 }) {
                    groupedData[sundayIndex].specialNote = "讀顯現節後本年未曾用之主日讀經課。"
                }
            }
            
            DispatchQueue.main.async {
                self.weeksData[week] = groupedData
            }
        }
    }
    
    private func groupDataForTable(_ rawDays: [LectionaryDay]) -> [DayLectionaryGroup] {
        var dict: [Int: DayLectionaryGroup] = [:]
        
        for i in 0...6 {
            let name = i == 0 ? "日" : i.chineseString
            dict[i] = DayLectionaryGroup(dayIndex: i, dayName: name)
        }
        
        for day in rawDays {
            let parts = day.dayKey.components(separatedBy: "-")
            guard parts.count >= 4, let dayIndex = Int(parts[1]) else { continue }
            guard dayIndex >= 0 && dayIndex <= 6 else { continue }
            
            let isYear2 = day.dayKey.contains("-yr2-")
            let time = parts[parts.count - 2]
            let testament = parts[parts.count - 1]
            
            if isYear2 {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1_yr2 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2_yr2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1_yr2 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2_yr2 = day }
            } else {
                if time == "M" && testament == "OT" { dict[dayIndex]?.morning1 = day }
                if time == "M" && testament == "NT" { dict[dayIndex]?.morning2 = day }
                if time == "E" && testament == "OT" { dict[dayIndex]?.evening1 = day }
                if time == "E" && testament == "NT" { dict[dayIndex]?.evening2 = day }
            }
        }
        return dict.values.sorted(by: { $0.dayIndex < $1.dayIndex })
    }
}

struct HolyDaysView: View {
    let year: String
    private let holyDayList = [
        ("1130", "聖安得烈日"), ("1221", "聖多馬日"),
        ("0125", "聖保羅受感化日"), ("0202", "獻聖嬰日"), ("0224", "聖馬提亞日"),
        ("0325", "童女馬利亞聞報日"), ("0425", "聖馬可日"), ("0501", "聖腓力聖雅各日"),
        ("0611", "聖巴拿巴日"), ("0624", "施洗聖約翰日"), ("0629", "聖彼得日"),
        ("0725", "聖雅各日"), ("0806", "易容顯光日"),
        ("0824", "聖巴多羅買日"), ("0921", "聖馬太日"), ("0929", "聖米迦勒日"),
        ("1018", "聖路加日"), ("1028", "聖西門聖猶大日"), ("1101", "諸聖日")
    ]
    
    @State private var holyDayData: [String: [DayLectionaryGroup]] = [:]
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        ForEach(holyDayList, id: \.0) { dateKey, title in
            DisclosureGroup(title.adaptChinese(isSimplified: isSimp)) {
                if let groups = holyDayData[dateKey] {
                    LectionaryTableView(weeklyData: groups, isHolyDayMode: true)
                        .padding(.vertical, 8)
                } else {
                    ProgressView("載入聖日經課...".adaptChinese(isSimplified: isSimp))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .onAppear { loadHolyDay(dateKey: dateKey, title: title) }
                }
            }
        }
        .onChange(of: year) { holyDayData.removeAll() }
    }
    
    private func loadHolyDay(dateKey: String, title: String) {
        guard holyDayData[dateKey] == nil else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let rawData = LectionaryJSONService.shared.fetchLectionaryBySpecificKey(year: year, keyPrefix: dateKey)
            
            var eveGroup = DayLectionaryGroup(dayIndex: 0, dayName: "前夕", customName: "前夕")
            var dayGroup = DayLectionaryGroup(dayIndex: 1, dayName: "當日", customName: title)
            
            for day in rawData {
                let isEve = day.dayKey.contains("-eve-")
                let parts = day.dayKey.components(separatedBy: "-")
                guard parts.count >= 2 else { continue }
                
                let time = parts[parts.count - 2]
                let testament = parts[parts.count - 1]
                
                if isEve {
                    if time == "E" && testament == "OT" { eveGroup.evening1 = day }
                    if time == "E" && testament == "NT" { eveGroup.evening2 = day }
                } else {
                    if time == "M" && testament == "OT" { dayGroup.morning1 = day }
                    if time == "M" && testament == "NT" { dayGroup.morning2 = day }
                    if time == "E" && testament == "OT" { dayGroup.evening1 = day }
                    if time == "E" && testament == "NT" { dayGroup.evening2 = day }
                }
            }
            
            DispatchQueue.main.async {
                self.holyDayData[dateKey] = [eveGroup, dayGroup]
            }
        }
    }
}

struct RegularSeasonView: View {
    let season: LiturgicalSeason
    let year: String
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        Text("\(season.title) 經課準備中...".adaptChinese(isSimplified: isSimp))
            .foregroundColor(.gray)
            .font(.footnote)
    }
}

// MARK: - 1943 年資料模型
struct Office1943Entry: Codable, Identifiable {
    var id: String { rawId }
    let rawId: String
    let label: String
    let office: String
    let psalms: Office1943Psalms
    let lessons: Office1943Lessons
    
    enum CodingKeys: String, CodingKey {
        case rawId = "id"
        case label, office, psalms, lessons
    }
}

struct Office1943Psalms: Codable {
    let antiphon: String
    let items: [Office1943PsalmItem]
}

struct Office1943PsalmItem: Codable, Hashable, Identifiable {
    let number: String
    let verses: String?

    var id: String { "\(number)-\(verses ?? "all")" }
}

struct Office1943Lessons: Codable {
    let ot: Office1943Lesson
    let nt: Office1943Lesson
}

struct Office1943Lesson: Codable {
    let book: String
    let chapter: String
}

// MARK: - 1943 年經課表總覽
struct Lectionary1943View: View {
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    @State private var selectedLesson: LectionaryDay?
    @State private var selectedPsalm: Office1943PsalmItem?
    
    private let seasons: [(key: String, title: String)] = {
        var result: [(String, String)] = []
        result.append(("tr", "三一主日"))
        for i in 1...26 {
            result.append(("tr\(i)", "三一後第\(i.chineseString)主日"))
        }
        result.append(("tr27", "降臨前主日"))
        return result
    }()
    
    var body: some View {
        List {
            DisclosureGroup {
                ForEach(seasons, id: \.key) { season in
                    DisclosureGroup(season.title.adaptChinese(isSimplified: isSimp)) {
                        Trinity1943WeekView(
                            seasonKey: season.key,
                            onPsalmTapped: { psalm in
                                selectedPsalm = psalm
                            }
                        ) { lesson in
                            selectedLesson = LectionaryDay(
                                season: season.key,
                                weekIndex: 0,
                                dayKey: "1943-\(season.key)",
                                book: lesson.book,
                                chapter: lesson.chapter
                            )
                        }
                        .padding(.vertical, 4)
                    }
                }
            } label: {
                Text(LiturgicalSeason.trinity.title.adaptChinese(isSimplified: isSimp))
                    .font(.headline)
                    .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255))
                    .padding(.vertical, 6)
            }
            HolyDays1943View(
                onPsalmTapped: { selectedPsalm = $0 },
                onLessonTapped: { lesson in
                    selectedLesson = LectionaryDay(season: "holyDays", weekIndex: 0, dayKey: "1943-holyDays", book: lesson.book, chapter: lesson.chapter)
                }
            )
        }
        .listStyle(.insetGrouped)
        .navigationDestination(item: $selectedLesson) { day in
            ScriptureDetailView(day: day)
        }
        .navigationDestination(item: $selectedPsalm) { psalm in
            PsalmReadingView(
                psalmNumber: psalm.number,
                verses: psalm.verses
            )
        }
    }
}




// MARK: - 1943 單週視圖
struct Trinity1943WeekView: View {
    let seasonKey: String
    var onPsalmTapped: (Office1943PsalmItem) -> Void
    var onLessonTapped: (Office1943Lesson) -> Void
    
    @State private var sundayEntries: [(yr: Int, m: Office1943Entry, e: Office1943Entry)] = []
    @State private var weekdayEntries: [(idx: Int, m: Office1943Entry, e: Office1943Entry)] = []
    @State private var hasLoaded = false
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    private let weekdays = ["禮拜一","禮拜二","禮拜三","禮拜四","禮拜五","禮拜六"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 主日：動態組數
            ForEach(sundayEntries, id: \.yr) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text("第\(group.yr.chineseString)組".adaptChinese(isSimplified: isSimp))
                        .font(.subheadline.bold())
                        .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255))
                    
                    VStack(spacing: 8) {
                        Office1943Card(
                            entry: group.m,
                            onPsalmTapped: onPsalmTapped,
                            onLessonTapped: onLessonTapped
                        )
                        Office1943Card(
                            entry: group.e,
                            onPsalmTapped: onPsalmTapped,
                            onLessonTapped: onLessonTapped
                        )
                    }
                }
            }
            
            if !sundayEntries.isEmpty && !weekdayEntries.isEmpty {
                Divider().padding(.vertical, 4)
            }
            
            // 禮拜一 ~ 禮拜六
            ForEach(weekdayEntries, id: \.idx) { day in
                VStack(alignment: .leading, spacing: 8) {
                    Text(weekdays[day.idx - 1].adaptChinese(isSimplified: isSimp))
                        .font(.subheadline.bold())
                        .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255))
                    
                    VStack(spacing: 8) {
                        Office1943Card(
                            entry: day.m,
                            onPsalmTapped: onPsalmTapped,
                            onLessonTapped: onLessonTapped
                        )
                        Office1943Card(
                            entry: day.e,
                            onPsalmTapped: onPsalmTapped,
                            onLessonTapped: onLessonTapped
                        )
                    }
                }
            }
        }
        .onAppear {
            if !hasLoaded {
                loadWeekData()
                hasLoaded = true
            }
        }
    }
    
    // (loadWeekData 與 loadEntry 的函數內容保持不變，照舊即可)
    private func loadWeekData() {
        var sundays: [(Int, Office1943Entry, Office1943Entry)] = []
        for yr in 1...3 {
            if let m = loadEntry(week: 0, office: "M", yr: yr),
               let e = loadEntry(week: 0, office: "E", yr: yr) {
                sundays.append((yr, m, e))
            }
        }
        sundayEntries = sundays
        
        var weekdays: [(Int, Office1943Entry, Office1943Entry)] = []
        for idx in 1...6 {
            if let m = loadEntry(week: idx, office: "M", yr: 1),
               let e = loadEntry(week: idx, office: "E", yr: 1) {
                weekdays.append((idx, m, e))
            }
        }
        weekdayEntries = weekdays
    }
    
    private func loadEntry(week: Int, office: String, yr: Int) -> Office1943Entry? {
        let yearGroup = (week == 0) ? "yr\(yr)" : "yr1"
        let filename = "office1943_\(seasonKey)-\(yearGroup)-\(week)-\(office.uppercased())"
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Office1943Entry.self, from: data)
    }
}

// MARK: - 1943 單日卡片
struct Office1943Card: View {
    let entry: Office1943Entry
    let onPsalmTapped: (Office1943PsalmItem) -> Void
    let onLessonTapped: (Office1943Lesson) -> Void
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Label(
                    (entry.office == "morning" ? "早禱" : "晚禱").adaptChinese(isSimplified: isSimp),
                    systemImage: entry.office == "morning" ? "sunrise.fill" : "moon.fill"
                )
                .font(.caption.bold())
                .foregroundColor(entry.office == "morning" ? .orange : .indigo)
                
                Spacer()
            }
            
            Divider()
            
            HStack(alignment: .top, spacing: 0) {
                psalmColumn
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 70)
                    .padding(.horizontal, 8)
                
                lessonColumn(title: "第一經課".adaptChinese(isSimplified: isSimp), lesson: entry.lessons.ot)
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 70)
                    .padding(.horizontal, 8)
                
                lessonColumn(title: "第二經課".adaptChinese(isSimplified: isSimp), lesson: entry.lessons.nt)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var psalmColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("詩篇".adaptChinese(isSimplified: isSimp))
                .font(.caption2.bold())
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(entry.psalms.items.enumerated()), id: \.offset) { _, item in
                    let chapterText = item.verses.map { "\(item.number)(\($0))" } ?? item.number
                    Button {
                        onPsalmTapped(item)
                    } label: {
                        Text(chapterText.adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // 修改：加上按鈕與點擊事件
    private func lessonColumn(title: String, lesson: Office1943Lesson) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.bold())
                .foregroundColor(.secondary)
            
            // 加入按鈕
            Button {
                onLessonTapped(lesson)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.book.adaptChinese(isSimplified: isSimp))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255))
                        .lineLimit(1)
                    
                    Text(lesson.chapter.adaptChinese(isSimplified: isSimp))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                // 使用 Rectangle 放大點擊範圍
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("白天模式") {
    NavigationStack {
        LectionaryView()
    }
    .preferredColorScheme(.light)
}

#Preview("黑夜模式") {
    NavigationStack {
        LectionaryView()
    }
    .preferredColorScheme(.dark)
}
