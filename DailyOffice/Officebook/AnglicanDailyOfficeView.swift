import SwiftUI

struct AnglicanDailyOfficeView: View {
    var body: some View {
        List {
            Section("禱文") {
                NavigationLink("總禱文") {
                    LitanyView()
                }
                NavigationLink("大齋首日懺悔文") {
                    PenitentialServiceView()
                }
                NavigationLink("家用禱文（早禱）") {
                    HomePrayerMorningView()
                }
                NavigationLink("家用禱文（晚禱）") {
                    HomePrayerEveningView()
                }
            }
            
            Section("大衛詩篇") {
                NavigationLink("詩篇") {
                    PsalmCycleView()
                }
            }
            
            Section("時辰祈禱") {
                NavigationLink("早禱") {
                    MorningPrayerView()
                }
                NavigationLink("一時禱") {
                    PrimePrayerView()
                }
                NavigationLink("三時禱") {
                    TercePrayerView()
                }
                NavigationLink("六時禱") {
                    SextPrayerView()
                }
                NavigationLink("九時禱") {
                    NonaPrayerView()
                }
                NavigationLink("晚禱") {
                    EveningPrayerView()
                }
                NavigationLink("寢前禱") {
                    ComplinePrayerView()
                }
            }
        }
        .navigationTitle("安立甘日課經")
        .navigationBarTitleDisplayMode(.inline)
    }
}
