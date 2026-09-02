import Foundation

struct EveningPrayerData {
    
    // MARK: - JSON 資料存取（私有，只供內部使用）
    private static var json: EveningPrayerJSON {
        EveningPrayerDataLoader.shared.load()
    }
    
    // MARK: 禮規與開始
    static var openingRubric: String {
        json.openingRubric
    }
    
    // MARK: 日課前祈禱（可選）
    static var preparatoryPrayers: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.preparatoryPrayers)
    }
    
    // MARK: 勸眾文
    static var exhortation: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.exhortation)
    }
    
    // MARK: 認罪文
    static var confession: ConfessionBlock {
        MorningPrayerDataLoader.shared.confessionBlock(from: json.confession)
    }
    
    // MARK: 赦罪文
    static var absolution: AbsolutionBlock {
        MorningPrayerDataLoader.shared.absolutionBlock(from: json.absolution)
    }
    
    // MARK: 主禱文
    static var lordPrayer: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.lordPrayer)
    }
    
    // MARK: 啟應
    static var responses: [Responsory] {
        MorningPrayerDataLoader.shared.responsories(from: json.responses)
    }
    
    // MARK: 恩光頌 (Phos Hilaron)
    static var phosHilaron: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.phosHilaron)
    }
    
    // MARK: 祈禱 (Prayers)
    static var prayers: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.prayers)
    }
    
    // MARK: 祈禱啟應
    static var prayersResponsesBCP1932: [Responsory] {
        MorningPrayerDataLoader.shared.responsories(from: json.prayersResponsesBCP1932)
    }
    
    static var prayersResponsesNew: [Responsory] {
        MorningPrayerDataLoader.shared.responsories(from: json.prayersResponsesNew)
    }
    
    // MARK: 祝文
    static var collects: [PrayerSection] {
        json.collects.map { MorningPrayerDataLoader.shared.prayerSection(from: $0) }
    }
    
    // MARK: 其他禱文
    static var generalPrayers: [PrayerSection] {
        json.generalPrayers.map { MorningPrayerDataLoader.shared.prayerSection(from: $0) }
    }
    
    // MARK: 晚禱結尾專屬啟應
    static var endingResponses: [Responsory] {
        MorningPrayerDataLoader.shared.responsories(from: json.endingResponses)
    }
    
    // MARK: 結束 (使徒禱文)
    static var ending: PrayerSection {
        MorningPrayerDataLoader.shared.prayerSection(from: json.ending)
    }
    
    // MARK: 聖帕特里克鎧甲歌
    static var stPatrickBreastplate: [String] {
        json.stPatrickBreastplate
    }
    
    // MARK: - 榮歸主頌數據模型
    struct GloriaBlock {
        let rubric: String
        let bcp1932: [String]
        let newTranslation: [String]
    }
    
    static var gloriaInExcelsis: GloriaBlock {
        GloriaBlock(
            rubric: json.gloriaInExcelsis.rubric,
            bcp1932: json.gloriaInExcelsis.bcp1932,
            newTranslation: json.gloriaInExcelsis.newTranslation
        )
    }
}
