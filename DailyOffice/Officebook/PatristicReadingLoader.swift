import Foundation

class PatristicReadingLoader {
    static let shared = PatristicReadingLoader()
    private var cache: [String: PatristicReadingJSON] = [:]
    
    func reading(for date: Date, liturgy: DailyLiturgy) -> PatristicReadingEntry? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        let (seasonKey, week) = adjustedSeasonAndWeek(
            season: info.season,
            week: info.weekNumber,
            title: liturgy.mainTitle,
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
        title: String,
        daysFromEaster: Int
    ) -> (seasonKey: String, week: Int) {
        
        switch season {
        case .christmas:
            if title.contains("聖誕日") { return ("christmas", 0) }
            if title.contains("聖誕後第一") { return ("christmas", 1) }
            if title.contains("聖誕後第二") { return ("christmas", 2) }
            if title.contains("救主受割禮") { return ("christmas", 3) }
            return ("christmas", 0)
            
        case .epiphany:
            if title == "顯現日" { return ("epiphany", 0) }
            return ("epiphany", week)
            
        case .prelenten:
            if title.contains("七旬") { return ("prelenten", 1) }
            if title.contains("六旬") { return ("prelenten", 2) }
            if title.contains("五旬") { return ("prelenten", 3) }
            return ("prelenten", week)
            
        case .lent:
            if title.contains("大齋首日") { return ("lent", 0) }
            if title.contains("苦難主日") { return ("lent", 5) }
            if title.contains("棕樹主日") { return ("lent", 6) }
            return ("lent", week)
            
        case .easter:
            if title.contains("救主復活") { return ("easter", 0) }
            if title.contains("升天") && !title.contains("後") { return ("easter", 5) }
            if title.contains("聖靈降臨") { return ("easter", 7) }
            return ("easter", week)
            
        case .trinity:
            if title == "三一主日" { return ("trinity", 0) }
            if title.contains("降臨前主日") { return ("trinity", 27) }
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
