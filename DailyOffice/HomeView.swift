import SwiftUI
import Combine
import CryptoKit
import Foundation // 確保引入 Foundation 以使用 StringTransform

// MARK: - 🌟 1. 字串繁簡轉換擴充 (Extension)
extension String {
    /// 根據傳入的布林值，將字串自動轉換為簡體中文（預設本身為繁體）
    func adaptChinese(isSimplified: Bool) -> String {
        guard isSimplified else { return self }
        // 呼叫 iOS 原生的繁轉簡 API
        return self.applyingTransform(StringTransform("Hant-Hans"), reverse: false) ?? self
    }
}

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

// 🌟 改寫：只寫繁體，透過擴充自動轉換
func colorLocalName(_ name: String, isSimplified: Bool) -> String {
    let traditionalName: String
    switch name {
    case "red":    traditionalName = "紅"
    case "white":  traditionalName = "白"
    case "green":  traditionalName = "綠"
    case "purple": traditionalName = "紫"
    case "pink":   traditionalName = "粉紅"
    default:       traditionalName = name
    }
    return traditionalName.adaptChinese(isSimplified: isSimplified)
}

// MARK: - 3. 首頁主視圖
struct HomeView: View {
    @Binding var selectedTab: Int
    
    // 🌟 全域監聽語言狀態
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    
    private var isSimp: Bool {
        appLanguageCode == AppLanguage.simplified.rawValue
    }
    
    @State private var upcomingDays: [(date: Date, liturgy: DailyLiturgy)] = []
    @State private var todayLiturgy: DailyLiturgy?
    private let coreService = LiturgyCoreService.shared
    private let calendar = Calendar.current
    
    let anglicanRed = Color(red: 181/255, green: 8/255, blue: 56/255)
    
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
                        
                        Text("安立甘日課".adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 26, weight: .bold))
                        
                        Text("St. Aidan Traditional Ministry")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 30)

                    // --- 2. 今日日課與時辰網格 ---
                    let liturgy = todayLiturgy
                    
                    VStack(spacing: 0) {
                        // 頂部禮儀信息橫幅
                        HStack(spacing: 12) {
                            VStack(alignment: .center, spacing: 2) {
                                Text(todayMonthString)
                                    .font(.system(size: 14, weight: .medium))
                                Text(todayDayString)
                                    .font(.system(size: 36, weight: .bold))
                            }
                            .foregroundColor(.white)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 1)
                                .padding(.vertical, 8)
                            
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
                                
                                Text((liturgy?.mainTitle ?? "載入中…").adaptChinese(isSimplified: isSimp))
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(liturgyColor(liturgy?.color ?? "green"))
                        
                        // 七個時辰按鈕網格
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                officeButton(title: "早禱".adaptChinese(isSimplified: isSimp), icon: "sunrise.fill", dest: "早禱")
                                officeButton(title: "一時禱".adaptChinese(isSimplified: isSimp), icon: "1.circle.fill", dest: "一時禱")
                                officeButton(title: "三時禱".adaptChinese(isSimplified: isSimp), icon: "3.circle.fill", dest: "三時禱")
                                officeButton(title: "六時禱".adaptChinese(isSimplified: isSimp), icon: "6.circle.fill", dest: "六時禱")
                            }
                            
                            HStack(spacing: 12) {
                                officeButton(title: "九時禱".adaptChinese(isSimplified: isSimp), icon: "9.circle.fill", dest: "九時禱")
                                officeButton(title: "晚禱".adaptChinese(isSimplified: isSimp), icon: "sunset.fill", dest: "晚禱")
                                officeButton(title: "寢前禱".adaptChinese(isSimplified: isSimp), icon: "moon.zzz.fill", dest: "寢前禱")
                                
                                // 聆聽（外部連結）
                                Button(action: {
                                    if let url = URL(string: "https://blog.theanglicancatholic.org/episodes/") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "headphones")
                                            .font(.system(size: 24))
                                            .foregroundColor(todayColor)
                                        Text("聆聽".adaptChinese(isSimplified: isSimp))
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
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                    .padding(.horizontal)
                    
                    // --- 3. 四個主要區塊按鈕 ---
                    VStack(spacing: 12) {
                        NavigationLink(value: "faithAndPractice") {
                            HomeCardButtonView(title: "安立甘公教會之信仰與實踐".adaptChinese(isSimplified: isSimp), icon: "book.closed.fill", color: liturgyColor("red"))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        HStack(spacing: 15) {
                            NavigationLink(value: "lectionary") {
                                HomeCardButtonView(title: "經課表".adaptChinese(isSimplified: isSimp), icon: "square.grid.3x3.topleft.filled", color: liturgyColor("green"))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(value: "monthlyLiturgy") {
                                HomeCardButtonView(title: "教會年曆".adaptChinese(isSimplified: isSimp), icon: "calendar", color: liturgyColor("purple"))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        HStack(spacing: 15) {
                            NavigationLink(value: "anglicanDailyOffice") {
                                HomeCardButtonView(title: "日課經".adaptChinese(isSimplified: isSimp), icon: "book.fill", color: liturgyColor("red"))
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(value: "martyrology") {
                                HomeCardButtonView(title: "殉道錄".adaptChinese(isSimplified: isSimp), icon: "cross.fill", color: liturgyColor("red"))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)

                    // --- 4. 此後七日聖日卡片 ---
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("此後七日聖日".adaptChinese(isSimplified: isSimp)).bold()
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
                        Text("聯繫我們".adaptChinese(isSimplified: isSimp))
                            .font(.headline)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Button(action: { openURL("https://theanglicancatholic.org") }) {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("網址：".adaptChinese(isSimplified: isSimp)).foregroundColor(.secondary)
                                    Text("theanglicancatholic.org").foregroundColor(anglicanRed).underline()
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: { openURL("https://thedailyoffice.org") }) {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("網址：".adaptChinese(isSimplified: isSimp)).foregroundColor(.secondary)
                                    Text("thedailyoffice.org").foregroundColor(anglicanRed).underline()
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: { openURL("mailto:admin@theanglicancatholic.org") }) {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("郵箱：".adaptChinese(isSimplified: isSimp)).foregroundColor(.secondary)
                                    Text("admin@theanglicancatholic.org").foregroundColor(anglicanRed).underline()
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
                    
                    // --- 6. 設定與說明欄位 ---
                    NavigationLink(value: "about") {
                        HStack {
                            Image(systemName: "gearshape.and.text.badge")
                                .foregroundColor(.secondary)
                            Text("設定與說明".adaptChinese(isSimplified: isSimp))
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
            .onAppear { loadUpcomingDays() }
            .task { loadUpcomingDays() }
            .onChange(of: appLanguageCode) {
                loadUpcomingDays()
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "lectionary": LectionaryView()
                case "monthlyLiturgy": MonthlyLiturgyView()
                case "anglicanDailyOffice": AnglicanDailyOfficeView()
                case "martyrology": MartyrologyArchiveView()
                case "faithAndPractice": FaithAndPracticeView()
                case "about": AboutView()
                default: EmptyView()
                }
            }
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) { UIApplication.shared.open(url) }
    }
    
    // MARK: - 時辰網格按鈕
    @ViewBuilder
    private func officeButton(title: String, icon: String, dest: String) -> some View {
        NavigationLink(destination: officeDestination(for: dest)) {
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
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(todayColor.opacity(0.25), lineWidth: 0.5))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func officeDestination(for office: String) -> some View {
        switch office {
        case "早禱": MorningPrayerView()
        case "一時禱": PrimePrayerView()
        case "三時禱": TercePrayerView()
        case "六時禱": SextPrayerView()
        case "九時禱": NonaPrayerView()
        case "晚禱": EveningPrayerView()
        case "寢前禱": ComplinePrayerView()
        default: Text(office).navigationTitle(office)
        }
    }
    
    // MARK: - 動態日期格式 (保持原樣，讓 DateFormatter 自己處理語系)
    private var todayMonthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: isSimp ? "zh_Hans" : "zh_Hant")
        formatter.dateFormat = "MM月"
        return formatter.string(from: Date())
    }
    
    private var todayDayString: String { String(calendar.component(.day, from: Date())) }
    
    private var todayWeekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: isSimp ? "zh_Hans" : "zh_Hant")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
    private func loadUpcomingDays() {
        let today = calendar.startOfDay(for: Date())
        todayLiturgy = coreService.resolve(for: today)
        
        var results: [(date: Date, liturgy: DailyLiturgy)] = []
        for offset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                results.append((date: date, liturgy: coreService.resolve(for: date)))
            }
        }
        upcomingDays = results
    }
}

// MARK: - 🌟 此後七日單行
struct UpcomingHolyDayRow: View {
    let date: Date
    let liturgy: DailyLiturgy
    private let calendar = Calendar.current
    
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    private var isSimp: Bool { appLanguageCode == AppLanguage.simplified.rawValue }
    
    private var isSunday: Bool { calendar.component(.weekday, from: date) == 1 }
    private var dayNumber: Int { calendar.component(.day, from: date) }
    
    private var weekdayShortName: String {
        let weekday = calendar.component(.weekday, from: date)
        let names = ["", "日", "一", "二", "三", "四", "五", "六"]
        return (weekday >= 0 && weekday < names.count) ? names[weekday].adaptChinese(isSimplified: isSimp) : ""
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // 左側日期區
            VStack(alignment: .center, spacing: 1) {
                Text("\(dayNumber)")
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
                // 🔥 動態資料也能轉！
                Text(liturgy.mainTitle.adaptChinese(isSimplified: isSimp))
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 6) {
                    if !liturgy.rankName.isEmpty {
                        Text(liturgy.rankName.adaptChinese(isSimplified: isSimp))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(rankBadgeColor.opacity(0.12))
                            .foregroundColor(rankBadgeColor)
                            .cornerRadius(4)
                    }
                    
                    HStack(spacing: 3) {
                        Circle().fill(liturgyColor(liturgy.color)).frame(width: 8, height: 8)
                        Text(colorLocalName(liturgy.color, isSimplified: isSimp))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !liturgy.commemorations.isEmpty {
                    Text(("紀念" + liturgy.commemorations.joined(separator: "、")).adaptChinese(isSimplified: isSimp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if !liturgy.transferred.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle.fill").font(.caption2).foregroundColor(.orange)
                        Text(("遷移至：" + "\(liturgy.transferred.joined(separator: "、"))").adaptChinese(isSimplified: isSimp))
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
    
    private var rankBadgeColor: Color {
        switch liturgy.rank {
        case .doubleFirstClass, .sundayFirstClass, .privilegedVigilFirstClass: return .red
        case .doubleSecondClass, .sundaySecondClass, .privilegedVigilSecondClass: return .purple
        case .greaterDouble, .double, .privilegedOctaveFirstClass, .privilegedOctaveSecondClassGreat, .privilegedOctaveThirdClassGreat, .ordinaryOctavegreaterDouble: return .blue
        case .semiDouble, .ordinarySunday, .privilegedOctaveSecondClass, .privilegedOctaveThirdClass, .ordinaryOctavesemiDouble: return .green
        case .simple, .commemoration: return .gray
        default: return .primary
        }
    }
}

// MARK: - 6. 設定與說明視圖
struct AboutView: View {
    @AppStorage("bibleVersion") private var bibleVersion = "CUV"
    @ObservedObject private var languageStore = AppLanguageStore.shared
    
    private var isSimp: Bool {
        languageStore.isSimplified
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // --- 1. 偏好設定 ---
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("偏好設定".adaptChinese(isSimplified: isSimp))
                            .font(.headline).bold()
                    }
                    .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("經文版本".adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
                        
                        Picker("聖經版本", selection: $bibleVersion) {
                            Text("和合本 (CUV)".adaptChinese(isSimplified: isSimp)).tag("CUV")
                            Text("施約瑟譯本 (SSEB)".adaptChinese(isSimplified: isSimp)).tag("SSEB")
                        }
                        .pickerStyle(.segmented)
                        
                        Text("切換後重新進入早禱或晚禱即可生效。".adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 12)).foregroundColor(.secondary)
                    }
                    
                    Divider().padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("介面字體".adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
                        
                        Picker("介面字體", selection: languageBinding) {
                            Text("繁體中文".adaptChinese(isSimplified: isSimp)).tag(AppLanguage.traditional)
                            Text("簡體中文".adaptChinese(isSimplified: isSimp)).tag(AppLanguage.simplified)
                        }
                        .pickerStyle(.segmented)
                        
                        Text("切換介面繁簡體中文顯示。".adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 12)).foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // --- 2. 日課說明 ---
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "book.circle")
                        Text("日課說明".adaptChinese(isSimplified: isSimp)).font(.headline).bold()
                    }
                    .foregroundColor(.secondary)
                    
                    Text("本安立甘日課是以1928年美國《公禱書》為基礎，增加了聖日、聖詩、頌歌、啟應經文，以及來自莎霖日課、其他地區《公禱書》與更廣泛的西方教會傳統禱文。除了早晚禱之外，還有一套來自《莎霖日課經》、本篤會禮儀的《小時課》。日課讀經表則是採用1928年美國版《公禱書》與1962年加拿大版《公禱書》經課表。".adaptChinese(isSimplified: isSimp))
                        .font(.system(size: 15)).lineSpacing(6).foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
                
                // --- 3. 中文說明 ---
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "book.circle")
                        Text("中文說明".adaptChinese(isSimplified: isSimp)).font(.headline).bold()
                    }
                    .foregroundColor(.secondary)
                    
                    Text("日課中文主體來自1932年中華聖公會三教區聯合出版之《公禱文》。此為1928年美國《公禱書》之最全中譯本。其餘補充的「聖日、聖詩、頌歌、啟應經文以及小時課」等內容，若有通行，或權威中譯則是直接引用。若無，則為自行翻譯。".adaptChinese(isSimplified: isSimp))
                        .font(.system(size: 15)).lineSpacing(6).foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
                
                // --- 4. 版權說明 ---
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "c.circle")
                        Text("版權說明".adaptChinese(isSimplified: isSimp)).font(.headline).bold()
                    }
                    .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("《聖經·和合本》 ©️ 公共版權".adaptChinese(isSimplified: isSimp))
                        Text("《聖經·施約瑟譯本》 ©️ 公共版權".adaptChinese(isSimplified: isSimp))
                        Text("《次經·1933版》 ©️ 公共版權".adaptChinese(isSimplified: isSimp)).foregroundColor(.secondary)
                    }
                    .font(.system(size: 14))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("設定與說明".adaptChinese(isSimplified: isSimp))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { languageStore.language },
            set: { languageStore.setLanguage($0) }
        )
    }
}

// MARK: - 首頁大卡片
struct HomeCardButtonView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).frame(width: 34, height: 34)
                Image(systemName: icon).font(.system(size: 17, weight: .semibold)).foregroundColor(color)
            }
            Text(title) // 傳入時已經是轉換過的字串，所以這裡不需要再轉
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 2)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.trailing, 2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.35), lineWidth: 1.0))
    }
}
