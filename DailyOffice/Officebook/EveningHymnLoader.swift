import Foundation

struct EveningHymnLoader {
    static let shared = EveningHymnLoader()
    private var hymns: [String: OfficeHymnData] = [:]

    init() {
        if let url = Bundle.main.url(forResource: "evening_hymns", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            // 注意：這裡解碼為 [String: OfficeHymnData] 以對應 JSON 的 Key
            self.hymns = (try? JSONDecoder().decode([String: OfficeHymnData].self, from: data)) ?? [:]
        }
    }

    func getHymn(for key: String, language: AppLanguage? = nil) -> OfficeHymnData? {
        guard let hymn = hymns[key] else { return nil }
        let resolvedLanguage = language ?? AppLanguageStore.shared.language
        guard resolvedLanguage == .simplified else { return hymn }

        return OfficeHymnData(
            title: hymn.title.adaptChinese(isSimplified: true),
            latinTitle: hymn.latinTitle,
            seasonNote: hymn.seasonNote?.adaptChinese(isSimplified: true),
            verses: hymn.verses.map { $0.adaptChinese(isSimplified: true) },
            versicle: hymn.versicle.map {
                OfficeHymnData.OfficeVersicle(
                    leader: $0.leader.adaptChinese(isSimplified: true),
                    people: $0.people.adaptChinese(isSimplified: true)
                )
            }
        )
    }
}
