import SwiftUI

/// 獨立閱讀頁沿用早晚禱的禱文資料，不依賴日課內的顯示選項。
struct BeforeAndAfterOfficePrayerView: View {
    @ObservedObject private var languageStore = AppLanguageStore.shared
    private var isSimp: Bool { languageStore.isSimplified }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LiturgyCard {
                    PrayerSectionContent(section: MorningPrayerData.preparatoryPrayers)
                }

                Divider()

                LiturgyCard {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle(text: AfterOfficePrayerData.title.adaptChinese(isSimplified: isSimp))
                        ForEach(Array(AfterOfficePrayerData.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                            BodyText(paragraph.adaptChinese(isSimplified: isSimp))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("日課前後的祈禱".adaptChinese(isSimplified: isSimp))
        .navigationBarTitleDisplayMode(.inline)
    }
}
