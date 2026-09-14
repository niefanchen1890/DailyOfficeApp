import SwiftUI

struct AfterOfficePrayerSection: View {
    @Binding var option: AfterOfficePrayerOption
    let language: AppLanguage
    private var isSimp: Bool { language == .simplified }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(text: AfterOfficePrayerData.title.adaptChinese(isSimplified: isSimp))
            Picker(AfterOfficePrayerData.title.adaptChinese(isSimplified: isSimp), selection: $option) {
                ForEach(AfterOfficePrayerOption.allCases, id: \.self) { choice in
                    Text(choice.localizedTitle(for: language)).tag(choice)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 2)

            if option.isVisible {
                ForEach(Array(AfterOfficePrayerData.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                    BodyText(paragraph.adaptChinese(isSimplified: isSimp))
                }
            }
        }
    }
}
