import SwiftUI

// MARK: - 殉道錄年度歸檔主視圖（月份列表）
struct MartyrologyArchiveView: View {
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var monthGroups: [(month: Int, monthName: String, days: [Int])] = []
    
    var body: some View {
        List {
            ForEach(monthGroups, id: \.month) { group in
                NavigationLink(
                    destination: MartyrologyMonthDaysView(
                        year: selectedYear,
                        month: group.month,
                        monthName: group.monthName,
                        days: group.days
                    )
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "cross.fill")
                            .foregroundColor(LiturgyColors.crimson)
                            .frame(width: 24)
                        
                        Text(group.monthName)
                            .font(.system(size: 17, weight: .medium))
                        
                        Spacer()
                        
                        Text("\(group.days.count)日")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("\(String(selectedYear))年殉道錄")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            monthGroups = MartyrologyLoader.shared.availableDatesByMonth(forYear: selectedYear)
        }
    }
}

// MARK: - 月份內日期列表（二級頁面：點擊月份後進入）
struct MartyrologyMonthDaysView: View {
    let year: Int
    let month: Int
    let monthName: String
    let days: [Int]
    
    var body: some View {
        List {
            ForEach(days, id: \.self) { day in
                if let date = Calendar.current.date(
                    from: DateComponents(year: year, month: month, day: day)
                ) {
                    NavigationLink(destination: MartyrologyDayDetailView(date: date)) {
                        HStack(spacing: 12) {
                            // 日期數字圓圈
                            ZStack {
                                Circle()
                                    .fill(LiturgyColors.crimson.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Text("\(day)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(LiturgyColors.crimson)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(formattedWeekday(date))
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                                Text(formattedDateDetail(date))
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // 右側預覽首條摘要（若有）
                            let entries = MartyrologyLoader.shared.entries(for: date)
                            if let first = entries.first {
                                Text(first.prefix(10) + (first.count > 10 ? "…" : ""))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(monthName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formattedWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        f.locale = Locale(identifier: "zh_Hant_TW")
        return f.string(from: date)
    }
    
    private func formattedDateDetail(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        f.locale = Locale(identifier: "zh_Hant_TW")
        return f.string(from: date)
    }
}

// MARK: - 單日殉道錄詳情（三級頁面：點擊日期後進入）
struct MartyrologyDayDetailView: View {
    let date: Date
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                let entries = MartyrologyLoader.shared.entries(for: date)
                
                if entries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cross")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("本日無殉道錄資料")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .padding(.top, 60)
                } else {
                    LiturgyCard {
                        VStack(alignment: .leading, spacing: 10) {
                            // 日期標題（如「6月10日 禮拜三」）
                            Text(formattedFullDate(date))
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(LiturgyColors.crimson)
                            
                            Divider()
                                .padding(.vertical, 2)
                            
                            // 條目內容（與一時禱共用同一 Loader）
                            ForEach(entries.indices, id: \.self) { i in
                                Text(entries[i])
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.vertical, 2)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(formattedNavigationTitle(date))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func formattedFullDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M月d日 EEEE"
        f.locale = Locale(identifier: "zh_Hant_TW")
        return f.string(from: date)
    }
    
    private func formattedNavigationTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        f.locale = Locale(identifier: "zh_Hant_TW")
        return f.string(from: date)
    }
}
