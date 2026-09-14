import Foundation

// MARK: - 讀經項目（由 prime_readings.json 載入）
struct PrimeReadingItem: Codable {
    let season: String
    let content: String
    let reference: String
}

// MARK: - 讀經載入器
struct PrimeReadingsLoader {
    static let shared = PrimeReadingsLoader()
    private let items: [PrimeReadingItem]
    
    init() {
        if let url = Bundle.main.url(forResource: "prime_readings", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([PrimeReadingItem].self, from: data) {
            items = decoded
        } else {
            // 後備：JSON 遺失時不崩潰
            items = [
                .init(season: "全年平日", content: "萬軍之主如此說：你們要喜愛誠實與和平。", reference: "撒迦利亞書 8:19"),
                .init(season: "主日與瞻禮日", content: "願尊貴、榮耀歸給永世的君王，那不朽壞、看不見、獨一的上帝，直到永永遠遠。阿們！", reference: "提摩太前書 1:17"),
                .init(season: "復活節期", content: "主啊，求你施恩給我們，我們等候你。求你每早晨作我們的膀臂，遭難時作我們的拯救。", reference: "以賽亞書 33:2")
            ]
        }
    }
    
    func item(for season: String) -> PrimeReadingItem? {
        items.first { $0.season == season }
    }
}
