import SwiftUI

struct NonaPrayerView: View {
    let date: Date

    init(date: Date = Date()) {
        self.date = date
    }

    var body: some View {
        MinorHourPrayerView(hour: .nona, date: date)
    }
}
