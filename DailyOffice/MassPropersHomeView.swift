import SwiftUI

struct MassPropersHomeView: View {
    // 引入我們剛剛寫好的掃描器
    @StateObject private var scanner = LocalProperScanner()
    
    var body: some View {
        List {
            // MARK: - 節期專用
            Section(header: Text("節期專用").font(.headline)) {
                // 復活期入口
                NavigationLink(destination: MassEasterSeasonView()) {
                    Label("復活期", systemImage: "laurel.leading")
                        .font(.system(.body))
                }
                
                // 未來可在此增加：大齋期、降臨期等
                /*
                NavigationLink(destination: LentSeasonView()) {
                    Label("大齋期", systemImage: "cross.fill")
                }
                */
            }
            
            // MARK: - 聖日專用 (自動生成月份與日期)
            Section(header: Text("聖日專用").font(.headline)) {
                if scanner.yearlyPropers.isEmpty {
                    Text("尚未在專案內偵測到任何 MMDD.json 檔案")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                } else {
                    // 第一層：月份列表
                    ForEach(scanner.yearlyPropers) { month in
                        NavigationLink(destination: MonthDetailView(month: month)) {
                            Label("\(month.name)", systemImage: "calendar")
                                .font(.system(.body, ))
                        }
                    }
                }
            }
        }
        .navigationTitle("每日彌撒")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - 第二層：該月每日列表
struct MonthDetailView: View {
    let month: MonthGroup
    
    var body: some View {
        List {
            ForEach(month.fileIDs, id: \.self) { filename in
                if let proper = MassProperManager.shared.loadProper(filename: filename) {
                    NavigationLink(destination: MassProperDetailView(proper: proper)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(proper.dateDisplay)
                                .font(.caption)
                                .foregroundColor(.red)
                            Text(proper.title)
                                .font(.system(.body, ))
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("尚未匯入 \(filename) 資料")
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle(month.name)
    }
}


struct MassEasterSeasonView: View {
    // 定義該節期內的檔案清單（硬編碼順序）
    let easterFiles = [
        "mass-easter4","mass-easter5", "mass-rogation", "mass-vigilofascension", "mass-ascension" // 復活後第五主日
        // 未來可繼續增加 "mass-easter6", "mass-ascension" 等
    ]
    
    var body: some View {
        List {
            ForEach(easterFiles, id: \.self) { filename in
                if let proper = MassProperManager.shared.loadProper(filename: filename) {
                    NavigationLink(destination: MassProperDetailView(proper: proper)) {
                        VStack(alignment: .leading, spacing: 4) {
                            // 顯示「復活後第五主日」
                            Text(proper.dateDisplay)
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            // 顯示標題
                            Text(proper.title)
                                .font(.system(.body, ))
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    // 防呆顯示
                    HStack {
                        Text("檔案缺失: \(filename)")
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                    }
                    .foregroundColor(.secondary)
                    .font(.caption)
                }
            }
        }
        .navigationTitle("復活期")
    }
}

#Preview {
    NavigationStack {
        MassPropersHomeView()
    }
}
