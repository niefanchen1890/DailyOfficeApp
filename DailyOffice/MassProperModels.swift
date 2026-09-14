import Foundation
import SwiftUI

// MARK: - 1. 彌撒經文資料結構
struct MassProper: Codable, Identifiable {
    var id: String { dateKey }
    let dateKey: String         // 例如："0505"
    let dateDisplay: String     // 例如："5月5日"
    let title: String           // 例如："聖奧古斯丁受感化日"
    let rank: String            // 例如："聖婦，複式"
    var commonMass: String?     // 例如："通用彌撒十三：教會聖師"
    
    // 🌟 新增：禮儀指示與說明性文字（例如：「此彌撒經文同8月28日...」）
    let rubricNote: String?
    
    // 🌟 原有簡介：保留為可選，專門用於聖人行傳或節日歷史簡介
    let intro: String?
    
    // 按禮儀順序排列的經文
    let introit: LiturgicalText?
    let collect: LiturgicalText?
    let collects: [LiturgicalText]?
    let epistle: LiturgicalText?
    let alleluia: LiturgicalText?
    let tract: LiturgicalText?
    let gospel: LiturgicalText?
    let creed: LiturgicalText?
    let offertory: LiturgicalText?
    let secret: LiturgicalText?
    let secrets: [LiturgicalText]?
    let communion: LiturgicalText?
    let postcommunion: LiturgicalText?
    let postcommunions: [LiturgicalText]?
}

struct LiturgicalText: Codable {
    let sectionTitle: String? // 標題名稱，如「入祭頌」
    let instruction: String?  // 指示語，如「書信載在...」
    let reference: String?    // 出處，如「太 5:13-19」
    let content: String       // 正文
}

// MARK: - 2. 禮儀排版專用樣式與常數

extension Color {
    // 將禮儀紅字定義在 Color 擴展中，更符合標準 SwiftUI 開發習慣
    static let rubricRed = Color(red: 181/255, green: 8/255, blue: 56/255) // #B50838
}

extension View {
    // 替代 HTML 中的 <p style="color: #B50838; text-align:center;">
    func rubricCenteredStyle() -> some View {
        self
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.rubricRed) // 直接使用擴展常數
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

extension String {
    // 替代 HTML 中的 text-indent: 2em (中文字首行縮排)
    var indented: String {
        return "\u{3000}\u{3000}" + self
    }
}

// MARK: - 3. 聖經與譯本定義
enum BibleVersion: String, CaseIterable, Codable {
    case cuv = "CUV"
    case sseb = "SSEB"
    
    var displayName: String {
        switch self {
        case .cuv: return "和合本"
        case .sseb: return "施約瑟譯本"
        }
    }
}
