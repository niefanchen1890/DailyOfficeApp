import SwiftUI

// MARK: - 數據模型
struct MartyrologyDaily: Codable {
    let date: String
    let title: String?
    let biography: String?
    let martyrs: [String]?
}

struct FeastIntroduction: Codable {
    let title: String
    let content: String
}

struct BiographySheetData: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

private let temporalKeywords: [String] = [
    "主日", "平日", "禮拜", "週", "特禱",
    "大齋首日", "聖週", "復活日", "復活後","升天望日",
    "救主升天日", "升天日", "升天後主日",
    "聖靈降臨", "三一", "基督君王"
]

struct LiturgyDashboardView: View {
    @StateObject private var viewModel = LiturgyViewModel()
    @State private var isCalendarPresented = false
    
    @State private var martyrologyData: MartyrologyDaily?
    @State private var feastIntroduction: FeastIntroduction?
    @State private var selectedBiography: BiographySheetData?
    
    // 🌟 新增：控制彌撒經文彈出視窗與錯誤提示的狀態
    @State private var selectedMassProper: MassProper?
    @State private var showNoMassProperAlert = false
    
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            topNavigationBar
            Divider()
            
            ScrollView(.vertical, showsIndicators: true) {
                if let liturgy = viewModel.currentLiturgy {
                    mainCard(for: liturgy)
                        .offset(x: dragOffset)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .simultaneousGesture(
                DragGesture(minimumDistance: 25, coordinateSpace: .local)
                    .onChanged { value in
                        let horizontal = value.translation.width
                        let vertical = value.translation.height
                        
                        if abs(horizontal) > abs(vertical) * 1.2 {
                            dragOffset = horizontal
                        }
                    }
                    .onEnded { value in
                        let horizontal = value.translation.width
                        let vertical = value.translation.height
                        let threshold: CGFloat = 80
                        
                        guard abs(horizontal) > abs(vertical) * 1.2 else {
                            withAnimation(.spring()) { dragOffset = 0 }
                            return
                        }
                        
                        withAnimation(.spring()) {
                            dragOffset = 0
                        }
                        
                        if horizontal < -threshold {
                            changeDate(by: 1)
                        } else if horizontal > threshold {
                            changeDate(by: -1)
                        }
                    }
            )
        }
        .sheet(isPresented: $isCalendarPresented) {
            calendarSheet
        }
        .sheet(item: $selectedBiography) { bio in
            NavigationStack {
                BiographyView(title: bio.title, content: bio.content)
                    .navigationTitle("\(bio.title)")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("完成") { selectedBiography = nil }
                        }
                    }
            }
        }
        // 🌟 新增：彌撒經文的 Sheet 視窗
        .sheet(item: $selectedMassProper) { proper in
            NavigationStack {
                MassProperDetailView(proper: proper)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("完成") { selectedMassProper = nil }
                        }
                    }
            }
        }
        // 🌟 新增：如果找不到當日經文 JSON 檔案，顯示提示
        .alert("尚無經文", isPresented: $showNoMassProperAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("目前尚未建立此日期的彌撒經文資料。")
        }
        .onAppear {
            loadMartyrology(for: viewModel.selectedDate)
            if let liturgy = viewModel.currentLiturgy {
                loadFeastIntroduction(for: liturgy)
            }
        }
    }
    
    private func changeDate(by days: Int) {
        let calendar = Calendar.current
        guard let newDate = calendar.date(byAdding: .day, value: days, to: viewModel.selectedDate) else {
            return
        }
        
        let today = Date()
        let minDate = calendar.date(byAdding: .year, value: -5, to: today)!
        let maxDate = calendar.date(byAdding: .year, value: 5, to: today)!
        
        guard newDate >= minDate && newDate <= maxDate else { return }
        
        viewModel.selectedDate = newDate
        viewModel.updateLiturgy()
        loadMartyrology(for: newDate)
        if let liturgy = viewModel.currentLiturgy {
            loadFeastIntroduction(for: liturgy)
        }
    }
    
    private var topNavigationBar: some View {
        VStack(spacing: 8) {
            Text("教會年曆")
                .font(.system(size: 24, weight: .bold))
            
            Button(action: { isCalendarPresented = true }) {
                HStack {
                    Text(formatYearMonth(viewModel.selectedDate))
                    Image(systemName: "calendar")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    private var calendarSheet: some View {
        VStack {
            HStack {
                Spacer()
                Button("完成") { isCalendarPresented = false }.padding()
            }
            DatePicker("選擇日期", selection: $viewModel.selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "zh_Hant"))
                .onChange(of: viewModel.selectedDate) { oldDate, newDate in
                    viewModel.updateLiturgy()
                    loadMartyrology(for: newDate)
                    if let liturgy = viewModel.currentLiturgy {
                        loadFeastIntroduction(for: liturgy)
                    }
                    isCalendarPresented = false
                }
            Spacer()
        }
        .presentationDetents([.medium])
    }
    
    private func loadIntroductionText(for identifier: String) -> String? {
        let fileName = "intro_\(identifier)"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let intro = try? JSONDecoder().decode(FeastIntroduction.self, from: data) else {
            return nil
        }
        return intro.content
    }
    
    @ViewBuilder
    private func mainCard(for liturgy: DailyLiturgy) -> some View {
        mainCardContent(for: liturgy)
            .padding(24)
            .foregroundColor(cardTextColor(for: liturgy))
            .background(themeColor(for: liturgy.color))
            .cornerRadius(24)
            .shadow(radius: 10)
    }
    
    @ViewBuilder
    private func mainCardContent(for liturgy: DailyLiturgy) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            headerSection(for: liturgy)
            renderMainTitle(liturgy: liturgy)
            fastingSection(for: liturgy)
            
            Divider().background(Color.white.opacity(0.5))
            
            // 🌟 修改：將閱讀簡介和彌撒經文按鈕群組在一起
            VStack(spacing: 12) {
                biographyButtonSection(for: liturgy)
                massProperButtonSection(for: liturgy)
            }
            
            commemorationsSection(for: liturgy)
            transferredSection(for: liturgy)
            martyrsSection()
        }
    }
    
    private func cardTextColor(for liturgy: DailyLiturgy) -> Color {
        if liturgy.color == "white" {
            return Color.black
        } else {
            return Color.white
        }
    }

    @ViewBuilder
    private func headerSection(for liturgy: DailyLiturgy) -> some View {
        HStack {
            Text(liturgy.rankName)  // ← 改為 rankName
                .font(.caption2).bold()
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.white.opacity(0.3))
                .cornerRadius(4)
            Spacer()
            Text(formatFullDate(viewModel.selectedDate))
                .font(.system(.caption, design: .monospaced))
        }
    }

    @ViewBuilder
    private func fastingSection(for liturgy: DailyLiturgy) -> some View {
        HStack {
            Image(systemName: "drop.fill")
            Text("齋戒：\(calculateFasting(for: viewModel.selectedDate, season: liturgy.season))")
        }
        .font(.footnote).bold()
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Color.black.opacity(0.1))
        .cornerRadius(8)
    }

    @ViewBuilder
    private func biographyButtonSection(for liturgy: DailyLiturgy) -> some View {
        if isFixedFeast(liturgy.mainTitle) {
            if let bio = martyrologyData?.biography, !bio.isEmpty {
                // let displayTitle = martyrologyData?.title ?? liturgy.mainTitle
                Button(action: {
                    selectedBiography = BiographySheetData(title: liturgy.mainTitle, content: bio)
                }) {
                    HStack {
                        Label("閱讀介紹", systemImage: "book.fill")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        } else {
            if let intro = feastIntroduction, !intro.content.isEmpty {
                Button(action: {
                    selectedBiography = BiographySheetData(title: intro.title, content: intro.content)
                }) {
                    HStack {
                        Label("閱讀介紹", systemImage: "book.fill")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // 🌟 新增：聖日、主日與特禱日的「彌撒經文」按鈕
    @ViewBuilder
    private func massProperButtonSection(for liturgy: DailyLiturgy) -> some View {
        let title = liturgy.mainTitle
        
        // 1. 判定是否為平日 (只要包含「禮拜」加數字，就是平日)
        let weekdaySymbols = ["一", "二", "三", "四", "五", "六"]
        let isWeekday = title.contains("禮拜") && weekdaySymbols.contains { title.contains($0) }
        // 2. 嚴格判定是否為真正的主日 (包含「主日」或「復活日」，且絕對不能是平日)
        let isSunday = (title.contains("主日") || title.contains("復活日")) && !isWeekday
        // 🌟 新增 3. 判定是否為特禱日 (Rogation Days)
        let isRogation = title.contains("特禱禮拜") && (title.contains("一") || title.contains("二") || title.contains("三"))
        // 🌟 新增 3.1：判定是否為升天望日
        let isVigilOfAscension = title.contains("升天望日")
        let Ascension = title.contains("升天日") || title.contains("救主升天日") || title.contains("耶穌升天日")
        // 4. 條件中加入 isVigilOfAscension，使其顯示按鈕
        if isFixedFeast(title) || isSunday || isRogation || isVigilOfAscension  || Ascension {
            Button(action: {
                loadAndPresentMassProper(for: viewModel.selectedDate)
            }) {
                HStack {
                    Label("彌撒經文", systemImage: "doc.text.fill")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    
    @ViewBuilder
    private func martyrsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("本日紀念聖人", systemImage: "person.2.fill").font(.footnote).bold()
            VStack(alignment: .leading, spacing: 10) {
                if let martyrs = martyrologyData?.martyrs, !martyrs.isEmpty {
                    ForEach(martyrs, id: \.self) { paragraph in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•").font(.subheadline)
                            Text(paragraph)
                                .font(.subheadline)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else {
                    Text("（此處將讀取殉道錄 JSON 數據...）")
                        .font(.subheadline)
                        .opacity(0.6)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.1))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    private func commemorationsSection(for liturgy: DailyLiturgy) -> some View {
        if !liturgy.commemorations.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("紀念事項", systemImage: "quote.opening").font(.footnote).bold()
                
                ForEach(liturgy.commemorations, id: \.self) { commemoration in
                    Button(action: {
                        var content = "暫無此紀念項目的介紹資料。"
                        
                        if isFixedFeast(commemoration) {
                            // A. 聖人：讀取本日殉道錄
                            if let bio = martyrologyData?.biography, !bio.isEmpty {
                                content = bio
                            }
                        } else {
                            // B. 節期/平日：獲取 ID 並讀取 intro_*.json
                            let id = getIdentifier(from: commemoration, season: liturgy.season)
                            if let loadedContent = loadIntroductionText(for: id) {
                                content = loadedContent
                            }
                        }
                        
                        selectedBiography = BiographySheetData(title: commemoration, content: content)
                        
                    }) {
                        HStack(alignment: .top, spacing: 6) {
                            Text("•").font(.subheadline)
                            Text(commemoration)
                                .font(.subheadline)
                                .underline()
                            Image(systemName: "info.circle")
                                .font(.caption).opacity(0.7).padding(.top, 2)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    @ViewBuilder
    private func transferredSection(for liturgy: DailyLiturgy) -> some View {
        if !liturgy.transferred.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("禮儀遷移", systemImage: "arrow.right.circle").font(.footnote).bold()
                ForEach(liturgy.transferred, id: \.self) { Text("• \($0)").font(.subheadline).italic() }
            }
        }
    }

    func isFixedFeast(_ title: String) -> Bool {
        for keyword in temporalKeywords {
            if title.contains(keyword) {
                return false
            }
        }
        return true
    }
    
    func calculateFasting(for date: Date, season: LiturgicalSeason) -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 1 { return "無齋" }
        switch season {
        case .lent, .holyWeek:
            if weekday == 4 || weekday == 6 { return "大小齋" }
            return "大齋"
        case .christmas: return "無齋"
        default:
            if weekday == 6 { return "小齋" }
            return "無齋"
        }
    }

    func loadMartyrology(for date: Date) {
        let calendar = Calendar.current
        let month = String(format: "%02d", calendar.component(.month, from: date))
        let day = String(format: "%02d", calendar.component(.day, from: date))
        let fileName = "martyr_\(month)\(day)"
        
        let possiblePaths = [
            "Resources/martyrology/\(month)",
            "martyrology/\(month)",
            nil
        ]
        
        var fileURL: URL? = nil
        for path in possiblePaths {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: path) {
                fileURL = url
                break
            }
        }
        
        guard let url = fileURL else {
            self.martyrologyData = nil
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(MartyrologyDaily.self, from: data)
            self.martyrologyData = decoded
        } catch {
            self.martyrologyData = nil
        }
    }
    
    // 🌟 新增：讀取彌撒經文資料並觸發 Sheet
    func loadAndPresentMassProper(for date: Date) {
        guard let liturgy = viewModel.currentLiturgy else { return }
        
        // 獲取當天的節期標識符 (如 "easter", "easter5", "rogation" 等)
        let identifier = feastIdentifier(for: liturgy)
        
        var possibleNames: [String] = []
        
        // 🌟 A. 優先處理節期/主日 (Temporal)
        // 如果是特定的節期主日，根據需求匹配 mass-easter, mass-easter1 等
        if identifier != "generic" && identifier != "eastertide" {
            possibleNames.append("mass-\(identifier)")
        }
        
        // 🌟 B. 處理固定日期 (Fixed Feast)
        let calendar = Calendar.current
        let month = String(format: "%02d", calendar.component(.month, from: date))
        let day = String(format: "%02d", calendar.component(.day, from: date))
        
        possibleNames.append(contentsOf: [
            "\(month)\(day)",
            "mass_\(month)\(day)",
            "proper_\(month)\(day)"
        ])
        
        var foundURL: URL? = nil
        for name in possibleNames {
            if let url = Bundle.main.url(forResource: name, withExtension: "json") {
                foundURL = url
                break
            }
        }
        
        guard let url = foundURL else {
            showNoMassProperAlert = true // 找不到檔案，彈出提示
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(MassProper.self, from: data)
            self.selectedMassProper = decoded // 解析成功，這會自動彈出 Sheet 顯示 MassProperDetailView
        } catch {
            print("❌ 解析彌撒經文失敗：\(error)")
            showNoMassProperAlert = true
        }
    }
    
    func loadFeastIntroduction(for liturgy: DailyLiturgy) {
        let identifier = feastIdentifier(for: liturgy)
        let fileName = "intro_\(identifier)"
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("⚠️ 找不到節期介紹檔案：\(fileName).json")
            self.feastIntroduction = nil
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            self.feastIntroduction = try JSONDecoder().decode(FeastIntroduction.self, from: data)
            print("✅ 成功讀取節期介紹：\(fileName).json")
        } catch {
            print("❌ 解析節期介紹失敗：\(error)")
            self.feastIntroduction = nil
        }
    }

    // MARK: - 更新後的 feastIdentifier (用於主畫面)
    func feastIdentifier(for liturgy: DailyLiturgy) -> String {
        let title = liturgy.mainTitle
        
        // 🌟 新增：節期八日慶期統一讀取節期介紹
        if title.contains("八日慶期") {
            if title.contains("升天") { return "ascension" }
            if title.contains("基督聖體") { return "corpuschristi" }
            if title.contains("耶穌聖心") { return "sacredheart" }
            if title.contains("聖靈降臨") { return "pentecost" }
            if title.contains("復活") { return "easter" }
            if title.contains("聖誕") { return "christmas" }
        }
        
        // 1. 特大節日優先處理 (攔截順序不變)
        if title.contains("升天望日") { return "vigilofascension" }
        if title.contains("復活主日") || title.contains("復活節") { return "easter" }
        if title.contains("聖誕") { return "christmas" }
        if title.contains("大齋首日") { return "lent" }
        if title.contains("特禱禮拜") {
            if title.contains("一") || title.contains("二") || title.contains("三") {
                return "rogation"
            }
        }
        if title.contains("救主升天日") || title.contains("升天日") { return "ascension" }
        if title.contains("升天後主日") { return "sundayafterascension" }
        // 🌟 核心調整：針對「主日」關鍵字進行編號抓取
        // 復活期平日標題為「復活後第X主日禮拜X」，移除 !isWeekday 限制後，
        // 平日也會正確對應到 "easter1", "easter2" 等主日介紹檔案。
        if title.contains("主日") {
            let prefix: String
            switch liturgy.season {
            case .advent:   prefix = "advent"
            case .lent:     prefix = "lent"
            case .easter:   prefix = "easter"
            case .pentecost: prefix = "pentecost"
            case .trinity:  prefix = "trinity"
            default:        prefix = ""
            }
            
            if !prefix.isEmpty {
                for i in 1...7 {
                    let chineseNum = numberToChinese(i)
                    if title.contains("第\(chineseNum)") {
                        return "\(prefix)\(i)"
                    }
                }
            }
        }

        // 3. 其餘平日則顯示該節期的通用介紹
        // 降臨期、三一期等的平日標題通常不含「主日」二字，會安全地落入此處回傳通用 ID
        switch liturgy.season {
        case .advent:    return "advent"
        case .christmas: return "christmas"
        case .epiphany:  return "epiphany"
        case .lent:      return "lent"
        case .holyWeek:  return "holy_week"
        case .easter:    return "eastertide"
        case .pentecost: return "pentecost"
        case .trinity:   return "trinity"
        default:         return "generic"
        }
    }

    // MARK: - 更新後的 getIdentifier (用於紀念事項按鈕)
    private func getIdentifier(from title: String, season: LiturgicalSeason) -> String {
        // 🌟 新增：節期八日慶期統一讀取節期介紹
        if title.contains("八日慶期") {
            if title.contains("升天") { return "ascension" }
            if title.contains("基督聖體") { return "corpuschristi" }
            if title.contains("耶穌聖心") { return "sacredheart" }
            if title.contains("聖靈降臨") { return "pentecost" }
            if title.contains("復活") { return "easter" }
            if title.contains("聖誕") { return "christmas" }
        }
        
        // 1. 特大節日處理 (與上方 logic 保持一致)
        if title.contains("升天望日") { return "vigilofascension" }
        if title.contains("復活主日") || title.contains("復活節") { return "easter" }
        if title.contains("聖誕") { return "christmas" }
        if title.contains("大齋首日") { return "lent" }
        if title.contains("救主升天日") || title.contains("升天日") { return "ascension" }
        
        if title.contains("特禱禮拜") {
            if title.contains("一") || title.contains("二") || title.contains("三") {
                return "rogation"
            }
        }
        if title.contains("升天後主日") { return "sundayafterascension" }
        // 🌟 核心調整：同步移除 !isWeekday 判定，使復活期平日紀念也能讀取主日介紹
        if title.contains("主日") {
            let prefix: String
            switch season {
            case .advent:   prefix = "advent"
            case .lent:     prefix = "lent"
            case .easter:   prefix = "easter"
            case .pentecost: prefix = "pentecost"
            case .trinity:  prefix = "trinity"
            default:        prefix = ""
            }
            
            if !prefix.isEmpty {
                for i in 1...7 {
                    let chineseNum = numberToChinese(i)
                    if title.contains("第\(chineseNum)") {
                        return "\(prefix)\(i)"
                    }
                }
            }
        }

        // 3. 預設回傳該節期的通用標識符
        switch season {
        case .advent:    return "advent"
        case .christmas: return "christmas"
        case .epiphany:  return "epiphany"
        case .lent:      return "lent"
        case .holyWeek:  return "holy_week"
        case .easter:    return "eastertide"
        case .pentecost: return "pentecost"
        case .trinity:   return "trinity"
        default:         return "generic"
        }
    }
    
    @ViewBuilder
    func renderMainTitle(liturgy: DailyLiturgy) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(liturgy.mainTitle)
                .font(.system(size: 28, weight: .bold))
            
            if liturgy.mainTitle.contains("復活後第五主日") {
                Text("（俗稱特禱主日）")
                    .font(.subheadline)
                    .opacity(0.8)
            }
            
            // 🌟 新增：基督聖體節八日慶期內主日
            if liturgy.mainTitle.contains("基督聖體節八日慶期內主日") {
                Text("（三一主日後第一主日）")
                    .font(.subheadline)
                    .opacity(0.8)
            }
            if liturgy.mainTitle.contains("耶穌聖心節八日慶期內主日") {
                Text("（三一主日後第二主日）")
                    .font(.subheadline)
                    .opacity(0.8)
            }
        }
    }

    func formatYearMonth(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy年 MMMM"; f.locale = Locale(identifier: "zh_Hant")
        return f.string(from: date)
    }
    
    func formatFullDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy年MM月dd日 EEEE"; f.locale = Locale(identifier: "zh_Hant")
        return f.string(from: date)
    }

    func themeColor(for colorName: String) -> Color {
        switch colorName {
        case "red": return Color(red: 181/255, green: 8/255, blue: 56/255)
        case "white": return Color.white
        case "green": return Color(red: 43/255, green: 138/255, blue: 62/255)
        case "purple": return .purple
        case "pink": return Color(red: 209/255, green: 117/255, blue: 143/255)
        default: return .gray
        }
    }
}

struct BiographyView: View {
    let title: String
    let content: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255)) // 禮儀紅色
                    .padding(.horizontal)
                    .padding(.top, 16)
                if let content = content, !content.isEmpty {
                    Text(content)
                        .font(.body)
                        .lineSpacing(8)
                        .padding()
                } else {
                    Text("暫無聖人小傳或節期介紹資料。")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
    }
}



#Preview {
    LiturgyDashboardView()
}
