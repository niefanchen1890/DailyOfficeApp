import SwiftUI
import Foundation
import Combine


// MARK: - 日課選擇（禮儀日曆）
struct DailyOfficeView: View {
    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    private let coreService = LiturgyCoreService.shared
    private let calendar = Calendar.current
    private let anglicanRed = Color(red: 181/255, green: 8/255, blue: 56/255)
    
    private let offices: [OfficeItem] = [
        OfficeItem(name: "早禱", subtitle: "Morning Prayer", icon: "sunrise.fill", color: Color(red: 181/255, green: 8/255, blue: 56/255), destination: { date in AnyView(MorningPrayerView(date: date)) }),
        OfficeItem(name: "一時禱", subtitle: "Prime", icon: "1.circle.fill", color: Color(red: 0.55, green: 0.35, blue: 0.25), destination: { date in AnyView(PrimePrayerView(date: date)) }),
        OfficeItem(name: "三時禱", subtitle: "Terce", icon: "3.circle.fill", color: Color(red: 0.50, green: 0.40, blue: 0.30), destination: { date in AnyView(TercePrayerView(date: date)) }),
        OfficeItem(name: "六時禱", subtitle: "Sext", icon: "6.circle.fill", color: Color(red: 0.45, green: 0.45, blue: 0.30), destination: { date in AnyView(SextPrayerView(date: date)) }),
        OfficeItem(name: "九時禱", subtitle: "None", icon: "9.circle.fill", color: Color(red: 0.40, green: 0.50, blue: 0.35), destination: { date in AnyView(NonaPrayerView(date: date)) }),
        OfficeItem(name: "晚禱", subtitle: "Evening Prayer", icon: "sunset.fill", color: Color(red: 0.35, green: 0.25, blue: 0.55), destination: { date in AnyView(EveningPrayerView(date: date)) }),
        OfficeItem(name: "寢前禱", subtitle: "Compline", icon: "moon.fill", color: Color(red: 0.20, green: 0.15, blue: 0.45), destination: { date in AnyView(ComplinePrayerView(date: date)) })
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if geometry.size.width > 700 {
                    ipadLayout
                } else {
                    iphoneLayout
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { selectedDate = Date(); displayedMonth = Date() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    // MARK: - iPhone 布局
    private var iphoneLayout: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                headerTitle
                calendarSection
                dayInfoCard
                officeButtonsGrid
                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - iPad 布局
    private var ipadLayout: some View {
        HStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    calendarSection
                    recentDaysList
                }
                .padding(.vertical, 16)
            }
            .frame(maxWidth: 360)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    dayInfoHeader
                    officeButtonsRow
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(Color(UIColor.systemBackground))
        }
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - 頂部標題（僅 iPhone）
    private var headerTitle: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 32))
                .foregroundColor(anglicanRed)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("禮儀日曆".adaptChinese(isSimplified: isSimp))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                Text("我因你公義的典章一天七次讚美你。——詩篇 119:164".adaptChinese(isSimplified: isSimp))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - 日曆區塊
    private var calendarSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(monthYearString(displayedMonth))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 0) {
                ForEach(["日","一","二","三","四","五","六"], id: \.self) { wd in
                    Text(wd)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth) { day in
                    DayCell(
                        day: day,
                        isSelected: isSameDay(day.date, selectedDate),
                        markerColor: liturgyColor(day.liturgy.color),
                        onTap: { selectedDate = day.date }
                    )
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - 今日信息卡（iPhone）
    private var dayInfoCard: some View {
        let liturgy = coreService.resolve(for: selectedDate)
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(formattedFullDate(selectedDate))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(liturgyColor(liturgy.color))
                        .frame(width: 8, height: 8)
                    Text(colorLocalName(liturgy.color, isSimplified: isSimp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Text(liturgy.mainTitle.adaptChinese(isSimplified: isSimp))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            if !liturgy.rankName.isEmpty {
                Text(liturgy.rankName.adaptChinese(isSimplified: isSimp))
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(rankBadgeColor(liturgy.rank).opacity(0.12))
                    .foregroundColor(rankBadgeColor(liturgy.rank))
                    .cornerRadius(6)
            }
            
            if !liturgy.commemorations.isEmpty {
                Text(("紀念：" + liturgy.commemorations.joined(separator: "、")).adaptChinese(isSimplified: isSimp))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - 詳情標題（iPad）
    private var dayInfoHeader: some View {
        let liturgy = coreService.resolve(for: selectedDate)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formattedFullDate(selectedDate))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(liturgyColor(liturgy.color))
                        .frame(width: 8, height: 8)
                    Text(colorLocalName(liturgy.color, isSimplified: isSimp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Text(liturgy.mainTitle.adaptChinese(isSimplified: isSimp))
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.primary)
            
            if !liturgy.rankName.isEmpty {
                Text(liturgy.rankName.adaptChinese(isSimplified: isSimp))
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(rankBadgeColor(liturgy.rank).opacity(0.12))
                    .foregroundColor(rankBadgeColor(liturgy.rank))
                    .cornerRadius(6)
            }
            
            if !liturgy.commemorations.isEmpty {
                Text(("紀念：" + liturgy.commemorations.joined(separator: "、")).adaptChinese(isSimplified: isSimp))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - 按鈕網格（iPhone）
    private var officeButtonsGrid: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 4)
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(offices) { office in
                NavigationLink(destination: office.destination(selectedDate)) {
                    VStack(spacing: 6) {
                        Image(systemName: office.icon)
                            .font(.system(size: 22))
                            .foregroundColor(office.color)
                            .frame(width: 44, height: 44)
                            .background(office.color.opacity(0.12))
                            .cornerRadius(10)
                        
                        Text(office.name.adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 72)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 按鈕行（iPad）
    private var officeButtonsRow: some View {
        HStack(spacing: 12) {
            ForEach(offices) { office in
                NavigationLink(destination: office.destination(selectedDate)) {
                    VStack(spacing: 6) {
                        Image(systemName: office.icon)
                            .font(.system(size: 22))
                            .foregroundColor(office.color)
                            .frame(width: 44, height: 44)
                            .background(office.color.opacity(0.12))
                            .cornerRadius(10)
                        
                        Text(office.name.adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - 近日列表
    private var recentDaysList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("近日".adaptChinese(isSimplified: isSimp))
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            ForEach(Array(recentDays.enumerated()), id: \.offset) { index, item in
                let isSelected = isSameDay(item.date, selectedDate)
                Button(action: { selectedDate = item.date }) {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(liturgyColor(item.liturgy.color))
                            .frame(width: 6, height: 6)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formattedShortDate(item.date))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(item.liturgy.mainTitle.adaptChinese(isSimplified: isSimp))
                                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(isSelected ? Color.green.opacity(0.08) : Color.clear)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: isSelected ? 1.5 : 0)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 8)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - 數據計算
    private var daysInMonth: [CalendarDay] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else { return [] }
        
        let weekdayOfFirst = calendar.component(.weekday, from: monthStart)
        let daysInThisMonth = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30
        
        var days: [CalendarDay] = []
        
        if let start = calendar.date(byAdding: .day, value: -(weekdayOfFirst - 1), to: monthStart) {
            var d = start
            for _ in 1..<weekdayOfFirst {
                days.append(CalendarDay(date: d, isCurrentMonth: false, liturgy: coreService.resolve(for: d)))
                d = calendar.date(byAdding: .day, value: 1, to: d)!
            }
        }
        
        var d = monthStart
        for _ in 1...daysInThisMonth {
            days.append(CalendarDay(date: d, isCurrentMonth: true, liturgy: coreService.resolve(for: d)))
            d = calendar.date(byAdding: .day, value: 1, to: d)!
        }
        
        let remaining = max(0, 42 - days.count)
        for _ in 0..<remaining {
            days.append(CalendarDay(date: d, isCurrentMonth: false, liturgy: coreService.resolve(for: d)))
            d = calendar.date(byAdding: .day, value: 1, to: d)!
        }
        
        return days
    }
    
    private var recentDays: [(date: Date, liturgy: DailyLiturgy)] {
        let offsets = -3...7
        return offsets.compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: selectedDate) else { return nil }
            return (date, coreService.resolve(for: date))
        }
    }
    
    // MARK: - 輔助函數
    private func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        calendar.isDate(d1, inSameDayAs: d2)
    }
    
    private func changeMonth(_ delta: Int) {
        displayedMonth = calendar.date(byAdding: .month, value: delta, to: displayedMonth) ?? displayedMonth
    }
    
    private func formattedFullDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年M月d日 EEEE"
        f.locale = Locale(identifier: isSimp ? "zh_Hans" : "zh_Hant")
        return f.string(from: date)
    }
    
    private func formattedShortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd EEEE"
        f.locale = Locale(identifier: isSimp ? "zh_Hans" : "zh_Hant")
        return f.string(from: date)
    }
    
    private func monthYearString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年MM月"
        f.locale = Locale(identifier: isSimp ? "zh_Hans" : "zh_Hant")
        return f.string(from: date)
    }
    
    private func rankBadgeColor(_ rank: LiturgicalRank) -> Color {
        switch rank {
        case .doubleFirstClass, .sundayFirstClass, .privilegedVigilFirstClass:
            return .red
        case .doubleSecondClass, .sundaySecondClass, .privilegedVigilSecondClass:
            return .purple
        case .greaterDouble, .double, .privilegedOctaveFirstClass,
             .privilegedOctaveSecondClassGreat, .privilegedOctaveThirdClassGreat,
             .ordinaryOctavegreaterDouble:
            return .blue
        case .semiDouble, .ordinarySunday, .privilegedOctaveSecondClass,
             .privilegedOctaveThirdClass, .ordinaryOctavesemiDouble:
            return .green
        case .saturdayOfficeBVM, .simple, .commemoration:
            return .gray
        default:
            return .primary
        }
    }
}

// MARK: - 輔助結構（僅此一份，全局唯一）
struct OfficeItem: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let icon: String
    let color: Color
    let destination: (Date) -> AnyView
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
    let liturgy: DailyLiturgy
    
    var dayString: String {
        String(Calendar.current.component(.day, from: date))
    }
}

struct DayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let markerColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(day.dayString)
                    .font(.system(size: 15, weight: isSelected ? .bold : .regular))
                    .foregroundColor(day.isCurrentMonth ? .primary : .secondary.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(isSelected ? Color.green.opacity(0.12) : Color.clear)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: isSelected ? 2 : 0)
                    )
                
                let hasMarker = day.liturgy.rank != .feria || !day.liturgy.commemorations.isEmpty
                Circle()
                    .fill(hasMarker ? markerColor : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 3. 主導航列
struct ContentView: View {
    @State private var selectedTab = 0
    
    // 🌟 監聽全域語言
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    var body: some View {
        Group {
            if #available(iOS 18.0, macOS 15.0, *) {
                mainTabView
                    .tabViewStyle(.tabBarOnly)
            } else {
                mainTabView
            }
        }
        .accentColor(Color(red: 181/255, green: 8/255, blue: 56/255))
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem { Image(systemName: "house.fill"); Text(isSimp ? "首页" : "首頁") }
                .tag(0)
            
            DailyOfficeView()
                .tabItem { Image(systemName: "book.closed.fill"); Text(isSimp ? "日课经" : "日課經") }
                .tag(1)
            
            NavigationStack { BibleView() }
                .tabItem { Image(systemName: "scroll.fill"); Text(isSimp ? "圣经" : "聖經") }
                .tag(2)
            
            NavigationStack { ChurchInfoView() }
                .tabItem { Image(systemName: "building.columns.fill"); Text(isSimp ? "教会" : "教會") }
                .tag(4)
        }
    }
}

// MARK: - 占位日課行（保留原樣）
struct PlaceholderOfficeRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let liturgy: DailyLiturgy
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.10))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(liturgy.mainTitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .opacity(0.7)
    }
}

#Preview("白天模式") {
    ContentView().preferredColorScheme(.light)
}

#Preview("黑夜模式") {
    ContentView().preferredColorScheme(.dark)
}
