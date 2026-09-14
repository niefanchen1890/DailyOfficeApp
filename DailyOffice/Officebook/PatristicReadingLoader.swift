import Foundation

class PatristicReadingLoader {
    static let shared = PatristicReadingLoader()
    private var cache: [String: PatristicReadingJSON] = [:]
    
    func reading(for date: Date, liturgy: DailyLiturgy) -> PatristicReadingEntry? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        let (seasonKey, week) = adjustedSeasonAndWeek(
            season: info.season,
            week: info.weekNumber,
            identifier: liturgy.identifier,
            daysFromEaster: info.daysFromEaster
        )
        
        let filename = "patristic_\(seasonKey)_\(week)"
        
        guard let json = loadJSON(filename: filename) else { return nil }
        
        let weekday = Calendar.current.component(.weekday, from: date)
        let dayIndex = (weekday == 1) ? 0 : (weekday - 1)
        
        return json.readings.first { $0.day == dayIndex }
    }
    
    private func adjustedSeasonAndWeek(
        season: LiturgicalSeason,
        week: Int,
        identifier: LiturgicalID,
        daysFromEaster: Int
    ) -> (seasonKey: String, week: Int) {
        
        switch season {
        case .christmas:
            if identifier == .christmasDay { return ("christmas", 0) }
            if identifier == .circumcision { return ("christmas", 3) }
            if let temporal = identifier.temporalComponents { return ("christmas", temporal.week) }
            return ("christmas", 0)
            
        case .epiphany:
            if identifier == .epiphany { return ("epiphany", 0) }
            return ("epiphany", week)
            
        case .prelenten:
            if identifier == .septuagesimaSunday { return ("prelenten", 1) }
            if identifier == .sexagesimaSunday { return ("prelenten", 2) }
            if identifier == .quinquagesimaSunday { return ("prelenten", 3) }
            return ("prelenten", week)
            
        case .lent:
            if identifier == .ashWednesday { return ("lent", 0) }
            if identifier == .passionSunday { return ("lent", 5) }
            if identifier == .palmSunday { return ("lent", 6) }
            return ("lent", week)
            
        case .easter:
            if identifier == .easterDay { return ("easter", 0) }
            if identifier == .ascension { return ("easter", 5) }
            if identifier == .pentecost { return ("easter", 7) }
            return ("easter", week)
            
        case .trinity:
            if identifier == .trinitySunday { return ("trinity", 0) }
            if [.sundayBeforeAdvent, .beforeAdventMonday, .beforeAdventTuesday, .beforeAdventWednesday, .beforeAdventThursday, .beforeAdventFriday, .beforeAdventSaturday].contains(identifier) { return ("trinity", 27) }
            return ("trinity", week)
            
        case .advent:
            return ("advent", week)
            
        case .holyWeek:
            return ("holyweek", 1)
            
        default:
            return (seasonFileKey(season), week)
        }
    }
    
    private func seasonFileKey(_ season: LiturgicalSeason) -> String {
        switch season {
        case .advent: return "advent"
        case .christmas: return "christmas"
        case .epiphany: return "epiphany"
        case .prelenten: return "prelenten"
        case .lent: return "lent"
        case .easter: return "easter"
        case .ascension: return "easter"
        case .pentecost: return "easter"
        case .trinity: return "trinity"
        case .holyWeek: return "holyweek"
        case .holyDays: return "holydays"
        }
    }
    
    private func loadJSON(filename: String) -> PatristicReadingJSON? {
        if let cached = cache[filename] { return cached }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        let json = try? JSONDecoder().decode(PatristicReadingJSON.self, from: data)
        if let json = json { cache[filename] = json }
        return json
    }
}
