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

struct LiturgyDashboardView: View {
    @StateObject private var viewModel = LiturgyViewModel()
    @ObservedObject private var languageStore = AppLanguageStore.shared
    private var isSimp: Bool { languageStore.isSimplified }
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
                    .navigationTitle(bio.title.adaptChinese(isSimplified: isSimp))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("完成".adaptChinese(isSimplified: isSimp)) { selectedBiography = nil }
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
                            Button("完成".adaptChinese(isSimplified: isSimp)) { selectedMassProper = nil }
                        }
                    }
            }
        }
        // 🌟 新增：如果找不到當日經文 JSON 檔案，顯示提示
        .alert("尚無經文".adaptChinese(isSimplified: isSimp), isPresented: $showNoMassProperAlert) {
            Button("確定".adaptChinese(isSimplified: isSimp), role: .cancel) { }
        } message: {
            Text("目前尚未建立此日期的彌撒經文資料。".adaptChinese(isSimplified: isSimp))
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
            Text("教會年曆".adaptChinese(isSimplified: isSimp))
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
                Button("完成".adaptChinese(isSimplified: isSimp)) { isCalendarPresented = false }.padding()
            }
            DatePicker("選擇日期".adaptChinese(isSimplified: isSimp), selection: $viewModel.selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: isSimp ? "zh_Hans" : "zh_Hant"))
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
    
    private func loadIntroductionText(for identifier: LiturgicalID) -> String? {
        guard let fileName = LiturgicalResourceResolver.shared.introductionFileName(for: identifier) else {
            return nil
        }
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
            Text(liturgy.rankName.adaptChinese(isSimplified: isSimp))
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
            Text("齋戒：\(calculateFasting(for: viewModel.selectedDate, season: liturgy.season))".adaptChinese(isSimplified: isSimp))
        }
        .font(.footnote).bold()
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Color.black.opacity(0.1))
        .cornerRadius(8)
    }

    @ViewBuilder
    private func biographyButtonSection(for liturgy: DailyLiturgy) -> some View {
        if isFixedFeast(liturgy.identifier, on: viewModel.selectedDate) {
            if let bio = martyrologyData?.biography, !bio.isEmpty {
                // let displayTitle = martyrologyData?.title ?? liturgy.mainTitle
                Button(action: {
                    selectedBiography = BiographySheetData(title: liturgy.mainTitle, content: bio)
                }) {
                    HStack {
                        Label("閱讀介紹".adaptChinese(isSimplified: isSimp), systemImage: "book.fill")
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
                        Label("閱讀介紹".adaptChinese(isSimplified: isSimp), systemImage: "book.fill")
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
        let sundayRanks: Set<LiturgicalRank> = [
            .sundayFirstClassGreat, .sundayFirstClass, .sundaySecondClass, .ordinarySunday
        ]
        let isAscension = liturgy.identifier == .ascension || liturgy.identifier == .ascensionVigil
        if isFixedFeast(liturgy.identifier, on: viewModel.selectedDate)
            || sundayRanks.contains(liturgy.rank)
            || liturgy.traits.fast == .rogation
            || isAscension {
            Button(action: {
                loadAndPresentMassProper(for: viewModel.selectedDate)
            }) {
                HStack {
                    Label("彌撒經文".adaptChinese(isSimplified: isSimp), systemImage: "doc.text.fill")
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
            Label("本日紀念聖人".adaptChinese(isSimplified: isSimp), systemImage: "person.2.fill").font(.footnote).bold()
            VStack(alignment: .leading, spacing: 10) {
                if let martyrs = martyrologyData?.martyrs, !martyrs.isEmpty {
                    ForEach(martyrs, id: \.self) { paragraph in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•").font(.subheadline)
                            Text(paragraph.adaptChinese(isSimplified: isSimp))
                                .font(.subheadline)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else {
                    Text("（此處將讀取殉道錄 JSON 數據...）".adaptChinese(isSimplified: isSimp))
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
                Label("紀念事項".adaptChinese(isSimplified: isSimp), systemImage: "quote.opening").font(.footnote).bold()
                
                ForEach(liturgy.commemorationItems) { commemoration in
                    Button(action: {
                        var content = "暫無此紀念項目的介紹資料。"
                        
                        if isFixedFeast(commemoration.identifier, on: viewModel.selectedDate) {
                            // A. 聖人：讀取本日殉道錄
                            if let bio = martyrologyData?.biography, !bio.isEmpty {
                                content = bio
                            }
                        } else {
                            // B. 節期/平日：獲取 ID 並讀取 intro_*.json
                            if let loadedContent = loadIntroductionText(for: commemoration.identifier) {
                                content = loadedContent
                            }
                        }
                        
                        selectedBiography = BiographySheetData(title: commemoration.title, content: content)
                        
                    }) {
                        HStack(alignment: .top, spacing: 6) {
                            Text("•").font(.subheadline)
                            Text(commemoration.title.adaptChinese(isSimplified: isSimp))
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
                Label("禮儀遷移".adaptChinese(isSimplified: isSimp), systemImage: "arrow.right.circle").font(.footnote).bold()
                ForEach(liturgy.transferred, id: \.self) {
                    Text("• \($0)".adaptChinese(isSimplified: isSimp)).font(.subheadline).italic()
                }
            }
        }
    }

    func isFixedFeast(_ identifier: LiturgicalID, on date: Date) -> Bool {
        Sanctorale.shared.getFeasts(for: date).contains { $0.identifier == identifier }
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
        var possibleNames: [String] = []
        
        // 🌟 A. 優先處理節期/主日 (Temporal)
        // 如果是特定的節期主日，根據需求匹配 mass-easter, mass-easter1 等
        if let key = LiturgicalResourceResolver.shared.massProperKey(for: liturgy.identifier) {
            possibleNames.append("mass-\(key)")
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
            AppLog.error("❌ 解析彌撒經文失敗：\(error)")
            showNoMassProperAlert = true
        }
    }
    
    func loadFeastIntroduction(for liturgy: DailyLiturgy) {
        guard let fileName = LiturgicalResourceResolver.shared.introductionFileName(for: liturgy.identifier),
              let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            let missingName = LiturgicalResourceResolver.shared.introductionFileName(for: liturgy.identifier)
                ?? liturgy.identifier.rawValue
            AppLog.warning("⚠️ 找不到節期介紹檔案：\(missingName)")
            self.feastIntroduction = nil
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            self.feastIntroduction = try JSONDecoder().decode(FeastIntroduction.self, from: data)
            AppLog.debug("✅ 成功讀取節期介紹：\(fileName).json")
        } catch {
            AppLog.error("❌ 解析節期介紹失敗：\(error)")
            self.feastIntroduction = nil
        }
    }

    @ViewBuilder
    func renderMainTitle(liturgy: DailyLiturgy) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(liturgy.mainTitle.adaptChinese(isSimplified: isSimp))
                .font(.system(size: 28, weight: .bold))
            
            if liturgy.identifier.temporalComponents.map({ $0.season == .easter && $0.week == 5 }) == true {
                Text("（俗稱特禱主日）".adaptChinese(isSimplified: isSimp))
                    .font(.subheadline)
                    .opacity(0.8)
            }
            
            // 🌟 新增：基督聖體節八日慶期內主日
            if liturgy.identifier == .corpusChristiOctaveSunday {
                Text("（三一主日後第一主日）".adaptChinese(isSimplified: isSimp))
                    .font(.subheadline)
                    .opacity(0.8)
            }
            if liturgy.identifier == .sacredHeartOctaveSunday {
                Text("（三一主日後第二主日）".adaptChinese(isSimplified: isSimp))
                    .font(.subheadline)
                    .opacity(0.8)
            }
        }
    }

    func formatYearMonth(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年 MMMM"
        f.locale = Locale(identifier: isSimp ? "zh_Hans" : "zh_Hant")
        return f.string(from: date)
    }
    
    func formatFullDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年MM月dd日 EEEE"
        f.locale = Locale(identifier: isSimp ? "zh_Hans" : "zh_Hant")
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
    @ObservedObject private var languageStore = AppLanguageStore.shared
    private var isSimp: Bool { languageStore.isSimplified }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title.adaptChinese(isSimplified: isSimp))
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255)) // 禮儀紅色
                    .padding(.horizontal)
                    .padding(.top, 16)
                if let content = content, !content.isEmpty {
                    Text(content.adaptChinese(isSimplified: isSimp))
                        .font(.body)
                        .lineSpacing(8)
                        .padding()
                } else {
                    Text("暫無聖人小傳或節期介紹資料。".adaptChinese(isSimplified: isSimp))
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
