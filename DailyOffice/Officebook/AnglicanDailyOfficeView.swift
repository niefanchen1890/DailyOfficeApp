import SwiftUI

struct AnglicanDailyOfficeView: View {
    @ObservedObject private var languageStore = AppLanguageStore.shared

    private var isSimp: Bool { languageStore.isSimplified }

    var body: some View {
        List {
            Section("禱文".adaptChinese(isSimplified: isSimp)) {
                NavigationLink("總禱文".adaptChinese(isSimplified: isSimp)) {
                    LitanyView()
                }
                NavigationLink("大齋首日懺悔文".adaptChinese(isSimplified: isSimp)) {
                    PenitentialServiceView()
                }
                NavigationLink("家用禱文（早禱）".adaptChinese(isSimplified: isSimp)) {
                    HomePrayerMorningView()
                }
                NavigationLink("家用禱文（晚禱）".adaptChinese(isSimplified: isSimp)) {
                    HomePrayerEveningView()
                }
            }
            
            Section("大衛詩篇".adaptChinese(isSimplified: isSimp)) {
                NavigationLink("詩篇".adaptChinese(isSimplified: isSimp)) {
                    PsalmCycleView()
                }
            }
            
            Section("時辰祈禱".adaptChinese(isSimplified: isSimp)) {
                NavigationLink("早禱".adaptChinese(isSimplified: isSimp)) {
                    MorningPrayerView()
                }
                NavigationLink("一時禱".adaptChinese(isSimplified: isSimp)) {
                    PrimePrayerView()
                }
                NavigationLink("三時禱".adaptChinese(isSimplified: isSimp)) {
                    TercePrayerView()
                }
                NavigationLink("六時禱".adaptChinese(isSimplified: isSimp)) {
                    SextPrayerView()
                }
                NavigationLink("九時禱".adaptChinese(isSimplified: isSimp)) {
                    NonaPrayerView()
                }
                NavigationLink("晚禱".adaptChinese(isSimplified: isSimp)) {
                    EveningPrayerView()
                }
                NavigationLink("寢前禱".adaptChinese(isSimplified: isSimp)) {
                    ComplinePrayerView()
                }
            }
        }
        .navigationTitle("安立甘日課經".adaptChinese(isSimplified: isSimp))
        .navigationBarTitleDisplayMode(.inline)
    }
}
