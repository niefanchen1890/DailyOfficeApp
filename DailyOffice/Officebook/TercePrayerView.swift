import SwiftUI

struct TercePrayerView: View {
    let date: Date

    init(date: Date = Date()) {
        self.date = date
    }

    var body: some View {
        MinorHourPrayerView(hour: .terce, date: date)
    }
}
