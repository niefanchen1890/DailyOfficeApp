import Foundation

enum AfterOfficePrayerOption: String, CaseIterable, Hashable {
    case include
    case omit

    var isVisible: Bool { self == .include }

    func localizedTitle(for language: AppLanguage) -> String {
        let title = self == .include ? AfterOfficePrayerData.title : "省略"
        return title.adaptChinese(isSimplified: language == .simplified)
    }
}
