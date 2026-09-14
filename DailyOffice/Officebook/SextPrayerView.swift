import SwiftUI

struct SextPrayerView: View {
    let date: Date

    init(date: Date = Date()) {
        self.date = date
    }

    var body: some View {
        MinorHourPrayerView(hour: .sext, date: date)
    }
}
