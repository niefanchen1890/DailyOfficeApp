import SwiftUI
import Combine
import CryptoKit

// MARK: - 共享輔助函數
func liturgyColor(_ name: String) -> Color {
    switch name {
    case "red":    return Color(red: 181/255, green: 8/255,  blue: 56/255)
    case "white":  return Color(red: 212/255, green: 175/255, blue: 55/255) // 金色：代替白色禮儀色，避免白底白字
    case "green":  return Color(red: 43/255,  green: 138/255, blue: 62/255)
    case "purple": return .purple
    case "pink":   return Color(red: 209/255, green: 117/255, blue: 143/255)
    default:       return .gray
    }
}

func colorLocalName(_ name: String) -> String {
    switch name {
    case "red":    return "紅"
    case "white":  return "白"
    case "green":  return "綠"
    case "purple": return "紫"
    case "pink":   return "粉紅"
    default:       return name
    }
}

// MARK: - 3. 首頁主視圖
struct HomeView: View {
    @Binding var selectedTab: Int
    
    // 🌟 本地核心服務計算此後七日
    @State private var upcomingDays: [(date: Date, liturgy: DailyLiturgy)] = []
    @State private var todayLiturgy: DailyLiturgy?
    private let coreService = LiturgyCoreService.shared
    private let calendar = Calendar.current
    
    let anglicanRed = Color(red: 181/255, green: 8/255, blue: 56/255)
    
    // 今日禮儀色（用於時辰按鈕的淡漸變）
    private var todayColor: Color {
        liturgyColor(todayLiturgy?.color ?? "green")
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // --- 1. 頂部 Logo 品牌區 ---
                    VStack(spacing: 12) {
                        Image("app_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: .black.opacity(0.1), radius: 8)
                        
                        Text("安立甘日課")
                            .font(.system(size: 26, weight: .bold))
                        
                        Text("St. Aidan Traditional Ministry")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 30)

                    // --- 2. 今日日課與時辰網格 ---
                    let liturgy = todayLiturgy
                    
                    VStack(spacing: 0) {
                        // 頂部禮儀信息橫幅（綠色/禮儀色背景）
                        HStack(spacing: 12) {
                            // 左側日期
                            VStack(alignment: .center, spacing: 2) {
                                Text(todayMonthString)
                                    .font(.system(size: 14, weight: .medium))
                                Text(todayDayString)
                                    .font(.system(size: 36, weight: .bold))
                            }
                            .foregroundColor(.white)
                            
                            // 分隔線
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 1)
                                .padding(.vertical, 8)
                            
                            // 右側禮儀信息
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.caption)
                                    Text(todayWeekdayString)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(6)
                                
                                Text(liturgy?.mainTitle ?? "載入中…")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(liturgyColor(liturgy?.color ?? "green"))
                        
                        // 七個時辰按鈕網格（上四下三）
                        VStack(spacing: 12) {
                            // 上排：四個
                            HStack(spacing: 12) {
                                officeButton(title: "早禱", icon: "sunrise.fill")
                                officeButton(title: "一時禱", icon: "1.circle.fill")
                                officeButton(title: "三時禱", icon: "3.circle.fill")
                                officeButton(title: "六時禱", icon: "6.circle.fill")
                            }
                            
                            // 下排：四個
                            HStack(spacing: 12) {
                                officeButton(title: "九時禱", icon: "9.circle.fill")
                                officeButton(title: "晚禱", icon: "sunset.fill")
                                officeButton(title: "寢前禱", icon: "moon.zzz.fill")
                                
                                // ✅ 第四個：聆聽（外部連結）
                                Button(action: {
                                    if let url = URL(string: "https://blog.theanglicancatholic.org/episodes/") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "headphones")
                                            .font(.system(size: 24))
                                            .foregroundColor(todayColor)
                                        Text("聆聽")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 85)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                todayColor.opacity(0.18),
                                                Color(UIColor.secondarySystemBackground)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(todayColor.opacity(0.25), lineWidth: 0.5)
                                    )
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(UIColor.systemBackground))
                    }
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // --- 3. 安立甘公教會之信仰與實踐 + 經課表與教會年曆 + 安立甘日課經與殉道錄 ---
                    VStack(spacing: 12) {
                        // 全寬按鈕
                        NavigationLink(value: "faithAndPractice") {
                            HomeCardButtonView(title: "安立甘公教會之信仰與實踐", icon: "book.closed.fill", color: liturgyColor("red"))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 第一排：經課表 + 教會年曆
                        HStack(spacing: 15) {
                            NavigationLink(value: "lectionary") {
                                HomeCardButtonView(title: "經課表", icon: "square.grid.3x3.topleft.filled", color: liturgyColor("green"))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(value: "monthlyLiturgy") {
                                HomeCardButtonView(title: "教會年曆", icon: "calendar", color: liturgyColor("purple"))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // 第二排：安立甘日課經 + 殉道錄
                        HStack(spacing: 15) {
                            NavigationLink(value: "anglicanDailyOffice") {
                                HomeCardButtonView(title: "日課經", icon: "book.fill", color: liturgyColor("red"))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(value: "martyrology") {
                                HomeCardButtonView(title: "殉道錄", icon: "cross.fill", color: liturgyColor("red"))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)

                    // --- 4. 此後七日聖日卡片 ---
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("此後七日聖日").bold()
                        }
                        .font(.headline)
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            if upcomingDays.isEmpty {
                                ProgressView().padding(30)
                            } else {
                                ForEach(Array(upcomingDays.enumerated()), id: \.offset) { index, item in
                                    UpcomingHolyDayRow(date: item.date, liturgy: item.liturgy)
                                    if index < upcomingDays.count - 1 {
                                        Divider().padding(.leading, 70)
                                    }
                                }
                            }
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // --- 5. 聯繫我們欄位 ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("聯繫我們")
                            .font(.headline)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            // 網址 1
                            Button(action: {
                                if let url = URL(string: "https://theanglicancatholic.org") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("網址：")
                                        .foregroundColor(.secondary)
                                    Text("theanglicancatholic.org")
                                        .foregroundColor(anglicanRed)
                                        .underline()
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // 網址 2
                            Button(action: {
                                if let url = URL(string: "https://thedailyoffice.org") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("網址：")
                                        .foregroundColor(.secondary)
                                    Text("thedailyoffice.org")
                                        .foregroundColor(anglicanRed)
                                        .underline()
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // 郵箱
                            Button(action: {
                                if let url = URL(string: "mailto:admin@theanglicancatholic.org") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("郵箱：")
                                        .foregroundColor(.secondary)
                                    Text("admin@theanglicancatholic.org")
                                        .foregroundColor(anglicanRed)
                                        .underline()
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .font(.system(size: 15))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // --- 6. 說明與版權欄位 ---
                    NavigationLink(value: "about") {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                            Text("日課與版權說明")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadUpcomingDays()
            }
            .task {
                loadUpcomingDays()
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "lectionary":
                    LectionaryView()
                case "monthlyLiturgy":
                    MonthlyLiturgyView()
                case "anglicanDailyOffice":
                    AnglicanDailyOfficeView()
                case "martyrology":
                    MartyrologyArchiveView()
                case "faithAndPractice":
                    FaithAndPracticeView()
                case "about":
                    AboutView()
                default:
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - 時辰網格按鈕（帶導航）
    @ViewBuilder
    private func officeButton(title: String, icon: String) -> some View {
        NavigationLink(destination: officeDestination(for: title)) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(todayColor)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, minHeight: 85)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        todayColor.opacity(0.18),
                        Color(UIColor.secondarySystemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(todayColor.opacity(0.25), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 時辰導航目的地（請替換為實際視圖）
    @ViewBuilder
    private func officeDestination(for office: String) -> some View {
        // ⚠️ 請將以下 Text 佔位符替換為你實際的時辰視圖
        // 例如：case "早禱": MorningPrayerView()
        switch office {
        case "早禱":
            MorningPrayerView().navigationTitle("早禱")
        case "一時禱":
            PrimePrayerView().navigationTitle("一時禱")
        case "三時禱":
            TercePrayerView().navigationTitle("三時禱")
        case "六時禱":
            SextPrayerView().navigationTitle("六時禱")
        case "九時禱":
            NonaPrayerView().navigationTitle("九時禱")
        case "晚禱":
            EveningPrayerView().navigationTitle("晚禱")
        case "寢前禱":
            ComplinePrayerView().navigationTitle("寢前禱")
        default:
            Text(office).navigationTitle(office)
        }
    }
    
    // MARK: - 今日日期格式化輔助
    private var todayMonthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant")
        formatter.dateFormat = "MM月"
        return formatter.string(from: Date())
    }
    
    private var todayDayString: String {
        let day = calendar.component(.day, from: Date())
        return String(day)
    }
    
    private var todayWeekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
    // MARK: - 計算此後七日（本地算法）
    private func loadUpcomingDays() {
        let today = calendar.startOfDay(for: Date())
        let liturgy = coreService.resolve(for: today)
        
        // 🌟 除錯輸出：確認核心服務是否正確返回今日禮儀
        print("🏠 HomeView 載入今日禮儀：title=\(liturgy.mainTitle), color=\(liturgy.color), rank=\(liturgy.rankName)")
        
        todayLiturgy = liturgy
        
        var results: [(date: Date, liturgy: DailyLiturgy)] = []
        for offset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                let liturgy = coreService.resolve(for: date)
                results.append((date: date, liturgy: liturgy))
            }
        }
        upcomingDays = results
    }
}




// MARK: - 🌟 此後七日單行（風格同 MonthlyLiturgyView 的 DayRow）
struct UpcomingHolyDayRow: View {
    let date: Date
    let liturgy: DailyLiturgy
    private let calendar = Calendar.current
    
    private var isSunday: Bool {
        calendar.component(.weekday, from: date) == 1
    }
    
    private var dayNumber: Int {
        calendar.component(.day, from: date)
    }
    
    private var weekdayShortName: String {
        let weekday = calendar.component(.weekday, from: date)
        let names = ["", "日", "一", "二", "三", "四", "五", "六"]
        return (weekday >= 0 && weekday < names.count) ? names[weekday] : ""
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            
            // 左側日期區（同 DayRow）
            VStack(alignment: .center, spacing: 1) {
                Text("\(dayNumber)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isSunday ? Color(red: 181/255, green: 8/255, blue: 56/255) : .primary)
                
                Text(weekdayShortName)
                    .font(.caption2)
                    .foregroundColor(isSunday ? .red.opacity(0.8) : .secondary)
            }
            .frame(width: 38, alignment: .center)
            
            // 禮儀顏色豎條（同 DayRow）
            RoundedRectangle(cornerRadius: 2)
                .fill(liturgyColor(liturgy.color))
                .frame(width: 4)
                .padding(.vertical, 8)
            
            // 內容區（同 DayRow）
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
                    Text("紀念" + liturgy.commemorations.joined(separator: "、"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if !liturgy.transferred.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("遷移至：\(liturgy.transferred.joined(separator: "、"))")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - 視覺輔助函數（與 MonthlyLiturgyView 保持一致）
    
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


// MARK: - 5. 輔助元件：列表行（已移除舊的 HolyDayListRow，改為 UpcomingHolyDayRow）


// MARK: - 6. 日課與版權說明視圖 (二級頁面)
struct AboutView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // --- 日課說明 ---
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "book.circle")
                        Text("日課說明")
                            .font(.headline)
                            .bold()
                    }
                    .foregroundColor(.secondary)
                    
                    Text("本安立甘日課是以1928年美國《公禱書》為基礎，增加了聖日、聖詩、頌歌、啟應經文，以及來自莎霖日課、其他地區《公禱書》與更廣泛的西方教會傳統禱文。除了早晚禱之外，還有一套來自《莎霖日課經》、本篤會禮儀的《小時課》。日課讀經表則是採用1928年美國版《公禱書》與1962年加拿大版《公禱書》經課表。")
                        .font(.system(size: 15))
                        .lineSpacing(6)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                // --- 中文說明 ---
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "book.circle")
                        Text("中文說明")
                            .font(.headline)
                            .bold()
                    }
                    .foregroundColor(.secondary)
                    
                    Text("日課中文主體來自1932年中華聖公會三教區聯合出版之《公禱文》。此為1928年美國《公禱書》之最全中譯本。其餘補充的「聖日、聖詩、頌歌、啟應經文以及小時課」等內容，若有通行，或權威中譯則是直接引用。若無，則為自行翻譯。")
                        .font(.system(size: 15))
                        .lineSpacing(6)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                // --- 版權說明 ---
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "c.circle")
                        Text("版權說明")
                            .font(.headline)
                            .bold()
                    }
                    .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("《聖經·和合本》 ©️ 公共版權")
                        Text("《聖經·施約瑟譯本》 ©️ 公共版權")
                        Text("《次經·1933版》 ©️ 公共版權")
                            .foregroundColor(.secondary)
                    }
                    .font(.system(size: 14))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
            }
            .padding()
        }
        .navigationTitle("說明")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - 首頁大卡片（雙列優化：緊湊左圖右文，確保單行不換行）
struct HomeCardButtonView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            // ═════ 左側：緊湊彩色圖標塊（34×34）═════
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.12))
                    .frame(width: 34, height: 34)
                
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // ═════ 中間：標題（單行、不縮放、不換行）═════
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)                       // ← 強制單行
                .truncationMode(.tail)              // ← 萬一超長尾部省略
            
            Spacer(minLength: 2)                    // ← 最小間距，盡量留給文字
            
            // ═════ 右側：箭頭（更緊湊）═════
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.trailing, 2)
        }
        .padding(.horizontal, 12)                   // ← 左右內邊距從 16 減為 12
        .padding(.vertical, 14)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.35), lineWidth: 1.0)
        )
    }
}



#Preview("白天模式") {
    ContentView().preferredColorScheme(.light)
}

#Preview("黑夜模式") {
    ContentView().preferredColorScheme(.dark)
}
