import Foundation

struct PatristicReadingJSON: Codable {
    let weekTitle: String
    let season: String
    let week: Int
    let readings: [PatristicReadingEntry]
}

struct PatristicReadingEntry: Codable, Identifiable {
    var id: Int { day }
    let day: Int      // 0=主日, 1=禮拜一 … 6=禮拜六
    let title: String
    let reader: String   // 读经员来源
    let subtitle: String // 标题
    let text: String
}


