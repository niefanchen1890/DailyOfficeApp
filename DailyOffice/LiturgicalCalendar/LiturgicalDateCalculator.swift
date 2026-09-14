import Foundation

/// 只負責禮儀日期的數學計算，不讀取畫面、JSON 或節期優先規則。
struct LiturgicalDateCalculator {
    private let calendar: Calendar

    init(calendar: Calendar = .liturgicalGregorian) {
        self.calendar = calendar
    }

    func easterSunday(in year: Int) -> Date {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1

        return date(year: year, month: month, day: day)
    }

    func ashWednesday(in year: Int) -> Date {
        days(-46, from: easterSunday(in: year))
    }

    func ascensionDay(in year: Int) -> Date {
        days(39, from: easterSunday(in: year))
    }

    func pentecostSunday(in year: Int) -> Date {
        days(49, from: easterSunday(in: year))
    }

    func trinitySunday(in year: Int) -> Date {
        days(56, from: easterSunday(in: year))
    }

    func firstSundayOfAdvent(in year: Int) -> Date {
        var result = date(year: year, month: 11, day: 27)
        while calendar.component(.weekday, from: result) != 1 {
            result = days(1, from: result)
        }
        return result
    }

    func daysBetween(_ start: Date, and end: Date) -> Int {
        let startOfFirstDay = calendar.startOfDay(for: start)
        let startOfLastDay = calendar.startOfDay(for: end)
        return calendar.dateComponents([.day], from: startOfFirstDay, to: startOfLastDay).day ?? 0
    }

    private func days(_ value: Int, from date: Date) -> Date {
        calendar.date(byAdding: .day, value: value, to: date)!
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }
}

private extension Calendar {
    static var liturgicalGregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }
}
