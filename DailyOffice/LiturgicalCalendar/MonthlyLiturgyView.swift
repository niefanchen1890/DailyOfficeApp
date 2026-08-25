import SwiftUI

struct MonthlyLiturgyView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // 預設為當前月份
    @State private var currentMonth: Date = {
        let cal = Calendar.current
        let now = Date()
        var comp = cal.dateComponents([.year, .month], from: now)
        comp.day = 1
        return cal.date(from: comp) ?? Date()
    }()
    
    @State private var daysInMonth: [DailyLiturgy] = []
    private let calendar = Calendar.current
    private let coreService = LiturgyCoreService.shared
    
    private var minimumDate: Date {
        calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
    }
    
    // 🌟 修正：移除 NavigationStack，直接返回 VStack
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 自定義頂部標題區
            VStack(spacing: 6) {
                Text("禮儀月表")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(monthYearString(from: currentMonth))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            Divider()
            weekdayHeader
            Divider()
            
            // MARK: - 日期列表（佔滿剩餘空間）
            dayGrid
            
            // MARK: - 底部工具欄
            bottomToolbar
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear(perform: loadMonthData)
        .onChange(of: currentMonth) { _, _ in loadMonthData() }
    }
    
    // MARK: - 星期標題
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(["主日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(day == "主日" ? .red : .secondary)
                    .padding(.vertical, 6)
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    // MARK: - 每日網格
    private var dayGrid: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 0) {
                ForEach(0..<daysInMonth.count, id: \.self) { index in
                    DayRow(
                        day: index + 1,
                        date: dateForDay(index + 1),
                        liturgy: daysInMonth[index]
                    )
                    if index < daysInMonth.count - 1 {
                        Divider()
                            .padding(.leading, 70)
                    }
                }
            }
        }
        .scrollIndicators(.visible)
    }
    
    // MARK: - 底部工具欄（返回 + 月份切換）
    private var bottomToolbar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .center, spacing: 0) {
                // 左側：返回上級按鈕
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("返回")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                }
                .frame(width: 80, alignment: .leading)
                
                Spacer()
                
                // 中間：月份切換膠囊（方便拇指點擊）
                HStack(spacing: 0) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(canGoPrevious ? .primary : .gray)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .disabled(!canGoPrevious)
                    
                    Text(monthYearString(from: currentMonth))
                        .font(.system(size: 16, weight: .semibold))
                        .frame(minWidth: 120)
                        .multilineTextAlignment(.center)
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(Capsule())
                
                Spacer()
                
                // 右側：佔位保持視覺平衡（與左側同寬）
                HStack {
                    EmptyView()
                }
                .frame(width: 80, height: 40, alignment: .trailing)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .padding(.bottom, 8) // 為 Home Indicator 留空間
            .background(Color(UIColor.systemBackground).opacity(0.95))
        }
    }
    
    // MARK: - 月份切換
    private func previousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth),
              newDate >= minimumDate else { return }
        currentMonth = newDate
    }
    
    private func nextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        currentMonth = newDate
    }
    
    private var canGoPrevious: Bool {
        guard let prev = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return false }
        return prev >= minimumDate
    }
    
    // MARK: - 數據載入
    private func loadMonthData() {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return }
        let numDays = range.count
        
        var data: [DailyLiturgy] = []
        for day in 1...numDays {
            var comp = calendar.dateComponents([.year, .month], from: currentMonth)
            comp.day = day
            if let date = calendar.date(from: comp) {
                data.append(coreService.resolve(for: date))
            }
        }
        daysInMonth = data
    }
    
    private func dateForDay(_ day: Int) -> Date {
        var comp = calendar.dateComponents([.year, .month], from: currentMonth)
        comp.day = day
        return calendar.date(from: comp) ?? Date()
    }
    
    private func monthYearString(from date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy年 MMMM"; f.locale = Locale(identifier: "zh_Hant_TW")
        return f.string(from: date)
    }
    
    private var liturgicalSeasonHint: String {
        let info = coreService.getSeasonInfo(for: currentMonth)
        switch info.season {
        case .advent:    return "降臨期"
        case .christmas: return "聖誕期"
        case .epiphany:  return "顯現期"
        case .prelenten: return "大齋前夕"
        case .lent:      return "大齋期"
        case .holyWeek:  return "聖週"
        case .easter:    return "復活期"
        case .ascension: return "升天期"
        case .pentecost: return "聖神降臨期"
        case .trinity:   return "三一期"
        default: return ""
        }
    }
}

// MARK: - 單日列表行（緊湊版）
struct DayRow: View {
    let day: Int
    let date: Date
    let liturgy: DailyLiturgy
    private let calendar = Calendar.current
    
    private var isSunday: Bool {
        calendar.component(.weekday, from: date) == 1
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            
            // 左側日期區
            VStack(alignment: .center, spacing: 1) {
                Text("\(day)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isSunday ? Color(red: 181/255, green: 8/255, blue: 56/255) : .primary)
                
                Text(weekdayShortName)
                    .font(.caption2)
                    .foregroundColor(isSunday ? .red.opacity(0.8) : .secondary)
            }
            .frame(width: 38, alignment: .center)
            
            // 禮儀顏色豎條
            RoundedRectangle(cornerRadius: 2)
                .fill(liturgyColor(liturgy.color))
                .frame(width: 4)
                .padding(.vertical, 8)
            
            // 內容區
            VStack(alignment: .leading, spacing: 4) {
                Text(liturgy.mainTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 6) {
                    if !liturgy.rankName.isEmpty {
                        Text(liturgy.rankName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(rankBadgeColor.opacity(0.12))
                            .foregroundColor(rankBadgeColor)
                            .cornerRadius(4)
                    }
                    
                    HStack(spacing: 3) {
                        Circle()
                            .fill(liturgyColor(liturgy.color))
                            .frame(width: 8, height: 8)
                        Text(colorLocalName(liturgy.color))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !liturgy.commemorations.isEmpty {
                    Text("紀念：" + liturgy.commemorations.joined(separator: "、"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if !liturgy.transferred.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("遷移：\(liturgy.transferred.joined(separator: "、"))")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
    }
    
    private var weekdayShortName: String {
        let weekday = calendar.component(.weekday, from: date)
        let names = ["", "日", "一", "二", "三", "四", "五", "六"]
        return (weekday >= 0 && weekday < names.count) ? names[weekday] : ""
    }
    
    private var rankBadgeColor: Color {
        switch liturgy.rank {
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
        case .simple, .commemoration:
            return .gray
        default:
            return .primary
        }
    }
}

#Preview {
    MonthlyLiturgyView()
}
