import Foundation


// MARK: - 聖人小傳
struct BiographyJSON: Codable {
    let title: String?
    let source: String?
    let rubric: String?
    let paragraphs: [Paragraph]

    // 段落類型：正文 或 來源標注（紅色居中，非誦念正文）
    enum Paragraph {
        case text(String)
        case source(String)
    }
}

extension BiographyJSON.Paragraph: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, text
    }

    init(from decoder: Decoder) throws {
        // 1. 先嘗試純字串（舊格式 → 一律視為正文）
        if let container = try? decoder.singleValueContainer(),
           let str = try? container.decode(String.self) {
            self = .text(str)
            return
        }
        // 2. 物件格式：{ "type": "...", "text": "..." }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type) ?? "text"
        let text = try container.decode(String.self, forKey: .text)
        self = (type == "source") ? .source(text) : .text(text)
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let str):
            // 正文仍編碼回純字串，保持 JSON 簡潔
            var container = encoder.singleValueContainer()
            try container.encode(str)
        case .source(let str):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("source", forKey: .type)
            try container.encode(str, forKey: .text)
        }
    }
}


// MARK: - 每日專日禮儀文件模型
struct DailyOfficeFile: Codable {
    let identifier: String
    let name: String
    let rank: String?
    let morning: OfficePeriod?
    let evening: OfficePeriod?
    let vigil: OfficePeriod?
    
    struct OfficePeriod: Codable {
        let bibleSentences: [BibleSentenceJSON]?
        let invitatory: InvitatoryJSON?
        let invitatoryHymn: HymnJSON?
        let ascensionInvitatoryHymn: HymnJSON?
        let psalmAntiphons: PsalmAntiphonsJSON?
        let officeHymn: HymnJSON?
        let easterOfficeHymn: HymnJSON?
        let ascensionOfficeHymn: HymnJSON?
        let benedictusAntiphon: AntiphonJSON?
        let nuncDimittisAntiphon: AntiphonJSON?
        let collect: CollectJSON?
        let commemorations: [CommemorationJSON]?
        let lessons: LessonsContainer?      // ✅ 已存在
        let psalms: PsalmLectionaryContainer? // ✅ 專用詩篇：1943 / 1928 / 1962
        let lectionarySets: LectionarySetContainer? // ✅ 經課與詩篇配套組：1943 主日 / 平日
        let biography: BiographyJSON?
        
        // MARK: - 原有嵌套類型（保持不變）
        struct InvitatoryJSON: Codable {
            let text: String?
            let texts: [String]?
        }
        
        struct HymnJSON: Codable {
            let title: String?
            let verses: [String]?
            let versicle: VersicleJSON?
        }
        
        struct VersicleJSON: Codable {
            let leader: String
            let people: String
        }
        
        struct PsalmAntiphonsJSON: Codable {
            let common: String?
            let antiphons: [String]?
        }
        
        struct AntiphonJSON: Codable {
            let normal: String?
            let normals: [String]?
            let note: String?
        }
        
        struct CommemorationJSON: Codable {
            let displayName: String?
            let antiphon: String?
            let versicle: VersicleJSON?
            let collect: CollectJSON?
            
            enum CodingKeys: String, CodingKey {
                case displayName = "display_name"
                case antiphon
                case versicle
                case collect
            }
        }
        
        struct CollectJSON: Codable {
            let title: String
            let text: String
        }
        
        // MARK: - 🌟 新增：內嵌經課模型（放在 CodingKeys 之前）
        struct LessonsContainer: Codable {
            let year1943: LessonsGroup?
            let year1928: LessonsGroup?
            let year1962: LessonsGroup?
            let special: LessonsGroup?
            
            enum CodingKeys: String, CodingKey {
                case year1943 = "1943"
                case year1928 = "1928"
                case year1962 = "1962"
                case special
            }
        }

        struct LessonsGroup: Codable {
            let ot: LessonReference?
            let nt: LessonReference?
        }

        struct LessonReference: Codable {
            let book: String
            let chapter: String
        }
        
        // MARK: - 🌟 新增：專用詩篇模型
        struct PsalmLectionaryContainer: Codable {
            let year1943: PsalmLectionaryGroup?
            let year1928: PsalmLectionaryGroup?
            let year1962: PsalmLectionaryGroup?
            let special: PsalmLectionaryGroup?
            
            enum CodingKeys: String, CodingKey {
                case year1943 = "1943"
                case year1928 = "1928"
                case year1962 = "1962"
                case special
            }
        }
        
        struct PsalmLectionaryGroup: Codable {
            // 1943 / 1928 / 1962 均共用當日詩篇對經邏輯；1943 只取當日第一個對經，並按1943方式首尾使用
            let antiphon: String?
            let antiphons: [String]?
            let items: [PsalmReference]
        }
        
        struct PsalmReference: Codable, Hashable {
            let number: String
            let verses: String?
        }
        
        // MARK: - 🌟 新增：經課與詩篇配套組模型
        struct LectionarySetContainer: Codable {
            let year1943: [LectionarySet]?
            
            enum CodingKeys: String, CodingKey {
                case year1943 = "1943"
            }
        }
        
        struct LectionarySet: Codable, Identifiable {
            let id: String
            let label: String?
            let lessons: LessonsGroup?
            let psalms: PsalmLectionaryGroup?
        }
        
        // MARK: - CodingKeys（🌟 必須加入 lessons / psalms / lectionary_sets）
        enum CodingKeys: String, CodingKey {
            case bibleSentences = "bible_sentences"
            case invitatory
            case invitatoryHymn = "invitatory_hymn"
            case ascensionInvitatoryHymn = "ascension_invitatory_hymn"
            case psalmAntiphons = "psalm_antiphons"
            case officeHymn = "office_hymn"
            case easterOfficeHymn = "easter_office_hymn"
            case ascensionOfficeHymn = "ascension_office_hymn"
            case benedictusAntiphon = "benedictus_antiphon"
            case nuncDimittisAntiphon = "nunc_dimittis_antiphon"
            case collect
            case commemorations
            case lessons
            case psalms
            case lectionarySets = "lectionary_sets"
            case biography
        }
    }
}

// MARK: - 每日禮儀加載器
struct DailyOfficeLoader {
    static let shared = DailyOfficeLoader()
    
    // 🌟 從 commemoration_map.json 加載的中文聖日映射表
    private let commemorationMap: [String: String]
    
    init() {
        var map: [String: String] = [:]
        if let url = Bundle.main.url(forResource: "commemoration_map", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
            map = json
        } else {
            print("⚠️ 無法加載 commemoration_map.json")
        }
        self.commemorationMap = map
    }
    
    // MARK: - 檢查紀念是否為 liturgicalFileMap 映射借用
    func isMappedCommemoration(_ name: String) -> Bool {
        return liturgicalFileMap[name] != nil
    }
    
    // MARK: - 對外接口：聖經選句
    func bibleSentences(for date: Date, liturgy: DailyLiturgy) -> [BibleSentenceJSON]? {
        if let office = loadOfficeFile(for: date, liturgy: liturgy),
           let sentences = office.morning?.bibleSentences,
           !sentences.isEmpty {
            return sentences
        }
        return nil
    }
    
    // MARK: - 對外接口：聖經選句（支援早晚禱）
    func bibleSentences(for date: Date, liturgy: DailyLiturgy, isEvening: Bool = false) -> [BibleSentenceJSON]? {
        if let office = loadOfficeFile(for: date, liturgy: liturgy) {
            let period: DailyOfficeFile.OfficePeriod?
            if isEvening {
                period = liturgy.isFirstVespers ? (office.vigil ?? office.evening) : office.evening
            } else {
                period = office.morning
            }
            if let sentences = period?.bibleSentences, !sentences.isEmpty {
                return sentences
            }
        }
        return nil
    }
    
    // MARK: - 對外接口：邀請選句
    func invitatoryText(for date: Date, liturgy: DailyLiturgy) -> String? {
        if let office = loadOfficeFile(for: date, liturgy: liturgy),
           let invitatory = office.morning?.invitatory {
            
            // 🌟 多組輪換：按年份取模
            if let texts = invitatory.texts, !texts.isEmpty {
                let year = Calendar.current.component(.year, from: date)
                return texts[year % texts.count]
            }
            // 向後兼容：單一版本
            if let text = invitatory.text, !text.isEmpty {
                return text
            }
        }
        return nil
    }
    
    // MARK: - 對外接口：邀請聖詩
    func invitatoryHymn(for date: Date, liturgy: DailyLiturgy) -> DailyOfficeFile.OfficePeriod.HymnJSON? {
        guard let office = loadOfficeFile(for: date, liturgy: liturgy),
              let basePeriod = office.morning else { return nil }
        
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        let daysToEaster = info.daysFromEaster
        
        // 🌟 升天期（升天日至聖靈降臨日前一天）
        if daysToEaster >= 39 && daysToEaster < 49 {
            return basePeriod.ascensionInvitatoryHymn ?? basePeriod.invitatoryHymn
        }
        
        // 其餘時間（含復活期）使用 invitatory_hymn
        return basePeriod.invitatoryHymn
    }
    
    // MARK: - 對外接口：詩篇對經陣列（支援早晚禱）
    func psalmAntiphons(for date: Date, liturgy: DailyLiturgy, isEvening: Bool = false) -> [String]? {
        if let office = loadOfficeFile(for: date, liturgy: liturgy) {
            let period: DailyOfficeFile.OfficePeriod?
            if isEvening {
                period = liturgy.isFirstVespers ? (office.vigil ?? office.evening) : office.evening
            } else {
                period = office.morning
            }
            // 🌟 優先讀取新格式 antiphons 陣列
            if let antiphons = period?.psalmAntiphons?.antiphons, !antiphons.isEmpty {
                return antiphons
            }
            // 🌟 向後兼容：舊格式 common 視為單一陣列
            if let common = period?.psalmAntiphons?.common, !common.isEmpty {
                return [common]
            }
        }
        return nil
    }

    // 保留舊方法名作為別名（避免其他程式碼報錯）
    func psalmAntiphon(for date: Date, liturgy: DailyLiturgy, isEvening: Bool = false) -> String? {
        return psalmAntiphons(for: date, liturgy: liturgy, isEvening: isEvening)?.first
    }
    
    // MARK: - 對外接口：日課聖詩
    func officeHymn(for date: Date, liturgy: DailyLiturgy, isEvening: Bool = false) -> DailyOfficeFile.OfficePeriod.HymnJSON? {
        guard let office = loadOfficeFile(for: date, liturgy: liturgy) else { return nil }
        
        let period = isEvening
            ? (liturgy.isFirstVespers ? (office.vigil ?? office.evening) : office.evening)
            : office.morning
        
        guard let basePeriod = period else { return nil }
        
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        let daysToEaster = info.daysFromEaster
        
        // 🌟 復活期（復活主日至升天日前一天）
        if daysToEaster >= 0 && daysToEaster < 39 {
            return basePeriod.easterOfficeHymn ?? basePeriod.officeHymn
        }
        // 🌟 升天期（升天日至聖靈降臨日前一天）
        if daysToEaster >= 39 && daysToEaster < 49 {
            return basePeriod.ascensionOfficeHymn ?? basePeriod.officeHymn
        }
        
        return basePeriod.officeHymn
    }
    
    // MARK: - 對外接口：尊主頌對經
    func benedictusAntiphon(for date: Date, liturgy: DailyLiturgy, isEvening: Bool = false) -> String? {
        if let office = loadOfficeFile(for: date, liturgy: liturgy) {
            let period: DailyOfficeFile.OfficePeriod?
            if isEvening {
                period = liturgy.isFirstVespers ? (office.vigil ?? office.evening) : office.evening
            } else {
                period = office.morning
            }
            if let antiphon = period?.benedictusAntiphon {
                // 🌟 多組輪換
                if let normals = antiphon.normals, !normals.isEmpty {
                    let year = Calendar.current.component(.year, from: date)
                    return normals[year % normals.count]
                }
                // 向後兼容
                if let normal = antiphon.normal, !normal.isEmpty {
                    return normal
                }
            }
        }
        return nil
    }
    
    // MARK: - 對外接口：祝文
    func collect(for date: Date, liturgy: DailyLiturgy) -> DailyOfficeFile.OfficePeriod.CollectJSON? {
        if let office = loadOfficeFile(for: date, liturgy: liturgy),
           let collect = office.morning?.collect {
            return collect
        }
        return nil
    }
    
    // MARK: - 對外接口：聖人小傳
    func biography(for date: Date, liturgy: DailyLiturgy, isEvening: Bool = false) -> BiographyJSON? {
        guard let file = loadOfficeFile(for: date, liturgy: liturgy) else { return nil }
        
        let period: DailyOfficeFile.OfficePeriod?
        if isEvening {
            period = liturgy.isFirstVespers ? (file.vigil ?? file.evening) : file.evening
        } else {
            period = file.morning
        }
        
        return period?.biography
    }
    
    // MARK: - 對外接口：尊主頌對經後註解
    func benedictusAntiphonNote(for date: Date, liturgy: DailyLiturgy, isEvening: Bool = false) -> String? {
        if let office = loadOfficeFile(for: date, liturgy: liturgy) {
            let period: DailyOfficeFile.OfficePeriod?
            if isEvening {
                period = liturgy.isFirstVespers ? (office.vigil ?? office.evening) : office.evening
            } else {
                period = office.morning
            }
            if let note = period?.benedictusAntiphon?.note, !note.isEmpty {
                return note
            }
        }
        return nil
    }
    
    // MARK: - 主入口：加載完整專日文件
    func loadOfficeFile(for date: Date, liturgy: DailyLiturgy) -> DailyOfficeFile? {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        let daysToEaster = info.daysFromEaster
        
        // 如果 liturgy.mainTitle 是聖日名稱，優先查 Sanctorale
        if let feastFile = loadSanctorale(date: date, daysToEaster: daysToEaster, expectedName: liturgy.mainTitle) {
            return feastFile
        }
        
        // 遷移聖日回退查找（當聖日被遷移到其他日期時，去原始日期查找 JSON）
        if let transferredFile = loadTransferredSanctorale(for: date, expectedName: liturgy.mainTitle) {
            return transferredFile
        }
        
        // 2. 再查節期特定日（Temporal Fixed）
        if let fixedFile = loadTemporalFixed(daysToEaster: daysToEaster, weekday: info.weekday, title: liturgy.mainTitle) {
            return fixedFile
        }
        
        // 3. 最後查常規週間日
        return loadTemporalWeekly(season: info.season, weekNumber: info.weekNumber, weekday: info.weekday)
    }
    
    // MARK: - 遷移聖日回退查找（硬編碼已知遷移規則）
    private func loadTransferredSanctorale(for date: Date, expectedName: String) -> DailyOfficeFile? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        
        // 規則：6月11日的使徒聖巴拿巴日遷移到6月12日（當三一主日為6月11日時）
        if month == 6 && day == 12 && expectedName.contains("聖巴拿巴") {
            let originalDate = calendar.date(from: DateComponents(year: year, month: 6, day: 11))!
            print("🔄 [遷移回退] 6月12日查找 '\(expectedName)' 失敗，回退到原始日期 6月11日查找")
            return loadSanctorale(date: originalDate, expectedName: expectedName)
        }
        
        return nil
    }
    
    // MARK: - 聖日加載（月日精確匹配 + 復活期雙版本匹配 + 名稱精確匹配）
    private func loadSanctorale(date: Date, daysToEaster: Int? = nil, expectedName: String? = nil) -> DailyOfficeFile? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let mmdd = String(format: "%02d%02d", month, day)
        print("      [loadSanctorale] 日期=\(mmdd), expectedName=\(expectedName ?? "nil")")
        
        // 1. 精確匹配 sanctorale_MMDD.json
        if let file = loadJSON(name: "sanctorale_\(mmdd)") {
            if let expected = expectedName {
                print("      → 找到 sanctorale_\(mmdd).json, name='\(file.name)'")
                if file.name == expected {
                    print("      → ✅ 名稱吻合")
                    return file
                } else {
                    print("      → ❌ 名稱不匹配: '\(file.name)' vs '\(expected)'")
                }
            } else {
                print("      → ✅ 無 expectedName，直接返回")
                return file
            }
        }
        
        // 2. 掃描所有 sanctorale_MMDD_*.json
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            print("      → ❌ Bundle 中無任何 json")
            return nil
        }
        
        let prefix = "sanctorale_\(mmdd)_"
        let candidates = urls.filter {
            $0.deletingPathExtension().lastPathComponent.hasPrefix(prefix)
        }
        print("      → 掃描到 \(candidates.count) 個候選: \(candidates.map { $0.lastPathComponent })")
        
        // 3. 若指定了預期名稱，在所有候選中精確匹配 name
        if let expected = expectedName {
            for url in candidates {
                print("      → 嘗試解析: \(url.lastPathComponent)")
                if let data = try? Data(contentsOf: url),
                   let file = try? JSONDecoder().decode(DailyOfficeFile.self, from: data) {
                    print("      → 解析成功: name='\(file.name)'")
                    if file.name == expected {
                        print("      → ✅ 名稱吻合，返回")
                        return file
                    } else {
                        print("      → ❌ 名稱不匹配: '\(file.name)' vs '\(expected)'")
                    }
                } else {
                    print("      → ❌ 解析失敗")
                }
            }
            print("      → ❌ 所有候選均不匹配 expectedName")
            return nil
        }
        
        // 4. 無預期名稱時：按原邏輯
        let isEasterSeason = (daysToEaster != nil) && (daysToEaster! >= 0) && (daysToEaster! < 49)
        print("      → 無 expectedName, isEasterSeason=\(isEasterSeason)")
        
        if isEasterSeason {
            if let easterURL = candidates.first(where: {
                $0.deletingPathExtension().lastPathComponent.hasSuffix("_easter")
            }) {
                print("      → 嘗試復活期版本: \(easterURL.lastPathComponent)")
                if let data = try? Data(contentsOf: easterURL) {
                    return try? JSONDecoder().decode(DailyOfficeFile.self, from: data)
                }
            }
        }
        
        if let normalURL = candidates.first(where: {
            !$0.deletingPathExtension().lastPathComponent.hasSuffix("_easter")
        }) {
            print("      → 嘗試普通版本: \(normalURL.lastPathComponent)")
            if let data = try? Data(contentsOf: normalURL) {
                return try? JSONDecoder().decode(DailyOfficeFile.self, from: data)
            }
        }
        
        if isEasterSeason, let anyURL = candidates.first {
            print("      → 復活期兜底: \(anyURL.lastPathComponent)")
            if let data = try? Data(contentsOf: anyURL) {
                return try? JSONDecoder().decode(DailyOfficeFile.self, from: data)
            }
        }
        
        print("      → ❌ loadSanctorale 全部失敗")
        return nil
    }
    
    
    // MARK: - 望日全局名稱匹配（按 file.name 在所有 sanctorale 中搜索）
    // 用途：望日遷移後，按名稱找到原始日期的 sanctorale 文件以獲取 collect
    private func loadSanctoraleByName(expectedName: String) -> DailyOfficeFile? {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            return nil
        }
        
        let prefix = "sanctorale_"
        let candidates = urls.filter {
            $0.deletingPathExtension().lastPathComponent.hasPrefix(prefix)
        }
        
        print("      [loadSanctoraleByName] 掃描 \(candidates.count) 個 sanctorale 檔案，查找 name='\(expectedName)'")
        
        for url in candidates {
            if let data = try? Data(contentsOf: url),
               let file = try? JSONDecoder().decode(DailyOfficeFile.self, from: data) {
                if file.name == expectedName {
                    print("      → ✅ 匹配成功: \(url.lastPathComponent), name='\(file.name)'")
                    return file
                }
            }
        }
        
        print("      → ❌ 無匹配")
        return nil
    }
    
    // MARK: - 節期特定日（硬編碼映射 + 中文標題回退映射）
    private func loadTemporalFixed(daysToEaster: Int, weekday: Int, title: String) -> DailyOfficeFile? {
        let key: String?
        
        switch daysToEaster {
        case -46: key = "temporal_ash_wednesday"
        case -3:  key = "temporal_maundy_thursday"
        case -2:  key = "temporal_good_friday"
        case -1:  key = "temporal_holy_saturday"
        case 0:   key = "temporal_easter_sunday"
        case 7:   key = "temporal_easter_1_sunday"
        case 14:  key = "temporal_easter_2_sunday"
        case 21:  key = "temporal_easter_3_sunday"
        case 28:  key = "temporal_easter_4_sunday"
        case 35:  key = "temporal_easter_5_sunday"
        case 36 where weekday == 4: key = "temporal_rogation_wednesday"
        case 37 where weekday == 5: key = "temporal_rogation_thursday"
        case 38:  key = "temporal_ascension_vigil"
        case 39:  key = "temporal_ascension_day"
        case 42 where weekday == 1: key = "temporal_ascension_1_sunday"
        case 46:  key = "temporal_ascension_octave_8"
        case 47:  key = "temporal_ascension_friday_after"
        case 48:  key = "temporal_pentecost_vigil"
        case 49:  key = "temporal_pentecost_sunday"
        // 🌟 修正：聖靈降臨八日慶期統一加上 _1
        case 50:  key = "temporal_pentecost_monday"
        case 51:  key = "temporal_pentecost_tuesday"
        case 52 where weekday == 4: key = "temporal_pentecost_1_wednesday"
        case 53 where weekday == 5: key = "temporal_pentecost_1_thursday"
        case 54 where weekday == 6: key = "temporal_pentecost_1_friday"
        case 55 where weekday == 7: key = "temporal_pentecost_1_saturday"
        case 56 where weekday == 1: key = "temporal_trinity_sunday"
        case 60:  key = "temporal_corpus_christi"
        case 67:  key = "temporal_corpus_christi_octave_8"
        case 68:  key = "temporal_sacred_heart"
        case 75:  key = "temporal_sacred_heart_octave_8"
        default:
            key = liturgicalFileMap[title]
        }
        
        guard let name = key else { return nil }
        return loadJSON(name: name)
    }
    
    // 🌟 合併後的統一映射表（補齊升天八日慶期 + 聖靈降臨八日慶期）
    private let liturgicalFileMap: [String: String] = [
        "升天望日": "temporal_ascension_vigil",
        "救主升天日": "temporal_ascension_day",
        "聖靈降臨日": "temporal_pentecost_sunday",
        "聖靈降臨望日": "temporal_pentecost_vigil",
        "三一主日": "temporal_trinity_sunday",
        "升天八日慶期": "temporal_ascension_oct",
        "復活日": "temporal_easter_sunday",
        "聖週禮拜五：主受難日": "temporal_good_friday",
        "聖週禮拜四：設立聖餐日": "temporal_maundy_thursday",
        "大齋首日 (聖灰禮拜三)": "temporal_ash_wednesday",
        "復活後第一主日（卸白衣主日）": "temporal_easter_1_sunday",
        "基督君王節": "temporal_christ_the_king",
        "降臨前主日": "temporal_before_advent_sunday",
        "特禱禮拜三": "temporal_easter6-3",
        
        // 升天八日慶期內各日
        "升天八日慶期內禮拜五": "temporal_ascension_1_friday",
        "升天八日慶期內禮拜六": "temporal_ascension_1_saturday",
        "升天八日慶期內禮拜一": "temporal_ascension_1_monday",
        "升天八日慶期內禮拜二": "temporal_ascension_1_tuesday",
        "升天八日慶期內禮拜三": "temporal_ascension_1_wednesday",
        "升天八日慶期內禮拜四": "temporal_ascension_1_thursday",
        "聖靈降臨後一日": "temporal_pentecost_monday",
        "聖靈降臨後二日": "temporal_pentecost_tuesday",
        "聖靈降臨八日慶期內夏季齋期禮拜三": "temporal_pentecost_1_wednesday",
        "聖靈降臨八日慶期內禮拜四": "temporal_pentecost_1_thursday",
        "聖靈降臨八日慶期內夏季齋期禮拜五": "temporal_pentecost_1_friday",
        "聖靈降臨八日慶期內夏季齋期禮拜六": "temporal_pentecost_1_saturday",
        "基督聖體節八日慶期": "temporal_corpus_christi",
        "基督聖體節八日慶期第八日": "temporal_corpus_christi_octave_8",
        "耶穌聖心節八日慶期": "temporal_sacred_heart",
        "使徒聖彼得與聖保羅望日": "sanctorale_0628_peter_and_paul_vigil",
        "施洗聖約翰誕辰日八日慶期第五日": "sanctorale_0628_john_baptist_octave_5",
        
    ]
    
    // MARK: - 常規週間日
    private func loadTemporalWeekly(season: LiturgicalSeason, weekNumber: Int, weekday: Int) -> DailyOfficeFile? {
        let seasonCode: String
        switch season {
        case .advent:    seasonCode = "advent"
        case .christmas: seasonCode = "christmas"
        case .epiphany:  seasonCode = "epiphany"
        case .lent:      seasonCode = "lent"
        case .easter:    seasonCode = "easter"
        case .ascension: seasonCode = "ascension"
        case .pentecost: seasonCode = "pentecost"
        case .trinity:   seasonCode = "trinity"
        default:         seasonCode = "ordinary"
        }
        
        let wd: String
        switch weekday {
        case 1: wd = "sunday"
        case 2: wd = "monday"
        case 3: wd = "tuesday"
        case 4: wd = "wednesday"
        case 5: wd = "thursday"
        case 6: wd = "friday"
        case 7: wd = "saturday"
        default: wd = "monday"
        }
        
        let name = "temporal_\(seasonCode)_\(weekNumber)_\(wd)"
        return loadJSON(name: name)
    }
    
    // MARK: - 紀念加載 (透過中文名稱映射 + 復活期雙版本 + temporal 回退)
    func loadCommemoration(name: String, date: Date) -> DailyOfficeFile? {
        print("🎯 loadCommemoration 被調用: name='\(name)'")
        
        // 🌟 名稱歸一化：去掉「紀念」前綴，因為 JSON 和映射表都不帶此前綴
        let normalizedName = name.hasPrefix("紀念")
            ? String(name.dropFirst(2)).trimmingCharacters(in: .whitespaces)
            : name
        print("   → 歸一化名稱: '\(normalizedName)'")
        
        // 1. 優先檢查統一映射表
        if let fileName = liturgicalFileMap[normalizedName] {
            print("   → 命中 liturgicalFileMap: key='\(normalizedName)' → fileName='\(fileName)'")
            if let file = loadJSON(name: fileName) {
                print("   → ✅ [步驟1] 透過 liturgicalFileMap 加載成功: '\(file.name)'")
                return file
            } else {
                print("   → ❌ [步驟1] liturgicalFileMap 有映射但 loadJSON 失敗")
            }
        } else {
            print("   → [步驟1] liturgicalFileMap 無此鍵: '\(normalizedName)'")
        }
        
        // 2. 查詢 commemoration_map.json
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let mmdd = String(format: "%02d%02d", month, day)
        let key = "\(mmdd)\(normalizedName)"
        print("   → [步驟2] 查詢 commemoration_map.json: key='\(key)'")
        
        if let baseName = commemorationMap[key] {
            print("   → 命中 commemoration_map: baseName='\(baseName)'")
            let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
            // let daysToEaster = info.daysFromEaster
            let season = info.season
            let isEasterSeason = (season == .easter || season == .ascension || season == .pentecost)
            
            if isEasterSeason {
                print("   → 復活期內，優先嘗試 \(baseName)_easter")
                if let file = loadJSON(name: "\(baseName)_easter") {
                    print("   → ✅ [步驟2] 加載 \(baseName)_easter 成功")
                    return file
                }
            }
            if let file = loadJSON(name: baseName) {
                print("   → ✅ [步驟2] 加載 \(baseName) 成功")
                return file
            }
            if isEasterSeason, let file = loadJSON(name: baseName) {
                print("   → ✅ [步驟2] 復活期回退加載 \(baseName) 成功")
                return file
            }
            print("   → ❌ [步驟2] commemoration_map 有映射但 loadJSON 全部失敗")
        } else {
            print("   → [步驟2] commemoration_map 無此鍵")
        }
        
        // 3. 回退：按日期模糊匹配 sanctorale
        print("   → [步驟3] 按日期匹配 sanctorale: date=\(month)/\(day), expectedName='\(normalizedName)'")
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        if let sanctorale = loadSanctorale(date: date, daysToEaster: info.daysFromEaster, expectedName: normalizedName) {
            print("   → ✅ [步驟3] sanctorale 匹配成功: '\(sanctorale.name)'")
            return sanctorale
        } else {
            print("   → ❌ [步驟3] sanctorale 無匹配")
        }
        
        // ═══════════════════════════════════════════════════════
        // 🌟 步驟3.5：望日全局名稱回退（處理遷移後的望日）
        // 目的：找到原始日期的 sanctorale 文件，僅用於獲取 collect
        // 注意：對經與啟應由 MorningPrayerViewModel 的 isVigilCommemoration 覆蓋為 temporal
        // ═══════════════════════════════════════════════════════
        if normalizedName.contains("望日") {
            print("   → [步驟3.5] 望日全局掃描: name='\(normalizedName)'")
            if let vigilFile = loadSanctoraleByName(expectedName: normalizedName) {
                print("   → ✅ [步驟3.5] 望日全局掃描成功: '\(vigilFile.name)'（僅用於獲取 collect）")
                return vigilFile
            } else {
                print("   → ❌ [步驟3.5] 望日全局掃描無匹配")
            }
        }
        
        // 4. 最後回退：回退到 temporal 週間日
        print("   → [步驟4] 回退到 temporal: season=\(info.season), week=\(info.weekNumber), wd=\(info.weekday)")
        if let temporal = loadTemporalWeekly(season: info.season, weekNumber: info.weekNumber, weekday: info.weekday) {
            print("   → ⚠️ [步驟4] 回退到 temporal: '\(temporal.name)'")
            if temporal.name == normalizedName {
                print("   → ✅ [步驟4] temporal 名稱吻合，視為有效回退")
                return temporal
            } else {
                print("   → ❌ [步驟4] temporal 名稱不匹配: file.name='\(temporal.name)' vs expected='\(normalizedName)'，已剔除")
                return nil
            }
        }
        
        print("   → ❌❌❌ loadCommemoration 全部失敗，返回 nil")
        return nil
    }
    
    // MARK: - 底層 JSON 讀取（藍組扁平 Bundle）
    private func loadJSON(name: String) -> DailyOfficeFile? {
        let testURL = Bundle.main.url(forResource: name, withExtension: "json")
        print("🔍 查找: \(name).json → \(testURL == nil ? "❌ nil" : "✅ \(testURL!.lastPathComponent)")")
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("   → ❌ 檔案不存在或讀取失敗")
            return nil
        }
        do {
            let decoded = try JSONDecoder().decode(DailyOfficeFile.self, from: data)
            print("   → ✅ 解析成功: name='\(decoded.name)'")
            return decoded
        } catch {
            print("❌ 解析 \(name).json 失敗: \(error)")
            return nil
        }
    }
}

// MARK: - 內嵌經課讀取擴展
extension DailyOfficeLoader {
    
    // 🌟 新增：查詢當前 JSON 有哪些可用經課版本
    func availableLectionaryOptions(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool
    ) -> [String] {
        guard let file = loadOfficeFile(for: date, liturgy: liturgy) else { return [] }
        
        let period: DailyOfficeFile.OfficePeriod?
        if isEvening {
            period = liturgy.isFirstVespers ? (file.vigil ?? file.evening) : file.evening
        } else {
            period = file.morning
        }
        
        let lessons = period?.lessons
        let sets = period?.lectionarySets
        
        var options: [String] = []
        if lessons?.year1943 != nil || !(sets?.year1943?.isEmpty ?? true) { options.append("1943") }
        if lessons?.year1928 != nil { options.append("1928") }
        if lessons?.year1962 != nil { options.append("1962") }
        if lessons?.special != nil   { options.append("special") }
        
        // 🌟 關鍵規則：若 JSON 僅有 special，則同時提供 1928 與 1962（回退到經課表資料庫）
        if options.count == 1 && options.first == "special" {
            options = ["1928", "1962", "special"]
        }
        
        return options
    }
    
    func lectionarySets(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool,
        year: String
    ) -> [DailyOfficeFile.OfficePeriod.LectionarySet] {
        guard let file = loadOfficeFile(for: date, liturgy: liturgy) else { return [] }
        
        let period: DailyOfficeFile.OfficePeriod?
        if isEvening {
            period = liturgy.isFirstVespers ? (file.vigil ?? file.evening) : file.evening
        } else {
            period = file.morning
        }
        
        guard let sets = period?.lectionarySets else { return [] }
        
        switch year {
        case "1943":
            return sets.year1943 ?? []
        default:
            return []
        }
    }
    
    func lectionarySet(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool,
        year: String,
        setId: String?
    ) -> DailyOfficeFile.OfficePeriod.LectionarySet? {
        let sets = lectionarySets(
            for: date,
            liturgy: liturgy,
            isEvening: isEvening,
            year: year
        )
        
        if let setId = setId,
           let selected = sets.first(where: { $0.id == setId }) {
            return selected
        }
        
        return sets.first
    }
    
    func jsonPsalms(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool,
        year: String
    ) -> DailyOfficeFile.OfficePeriod.PsalmLectionaryGroup? {
        guard let file = loadOfficeFile(for: date, liturgy: liturgy) else { return nil }
        
        let period: DailyOfficeFile.OfficePeriod?
        if isEvening {
            period = liturgy.isFirstVespers ? (file.vigil ?? file.evening) : file.evening
        } else {
            period = file.morning
        }
        
        guard let psalms = period?.psalms else { return nil }
        
        switch year {
        case "1943": return psalms.year1943
        case "1928": return psalms.year1928
        case "1962": return psalms.year1962
        case "special": return psalms.special
        default: return nil
        }
    }
    
    func availablePsalmLectionaryOptions(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool
    ) -> [String] {
        guard let file = loadOfficeFile(for: date, liturgy: liturgy) else { return [] }
        
        let period: DailyOfficeFile.OfficePeriod?
        if isEvening {
            period = liturgy.isFirstVespers ? (file.vigil ?? file.evening) : file.evening
        } else {
            period = file.morning
        }
        
        let psalms = period?.psalms
        let sets = period?.lectionarySets
        
        var options: [String] = []
        if psalms?.year1928 != nil { options.append("1928") }
        if !(sets?.year1943?.isEmpty ?? true) || psalms?.year1943 != nil { options.append("1943") }
        if psalms?.year1962 != nil { options.append("1962") }
        if psalms?.special != nil { options.append("special") }
        return options
    }
    
    func jsonLessons(
        for date: Date,
        liturgy: DailyLiturgy,
        isEvening: Bool,
        year: String
    ) -> DailyOfficeFile.OfficePeriod.LessonsGroup? {
        
        print("🔍 [jsonLessons] 開始 year=\(year), isEvening=\(isEvening), liturgy.mainTitle=\(liturgy.mainTitle)")
        
        guard let file = loadOfficeFile(for: date, liturgy: liturgy) else {
            print("❌ [jsonLessons] loadOfficeFile 返回 nil")
            return nil
        }
        print("✅ [jsonLessons] 文件加載成功: name='\(file.name)', identifier='\(file.identifier)'")
        
        let period: DailyOfficeFile.OfficePeriod?
        if isEvening {
            period = liturgy.isFirstVespers ? (file.vigil ?? file.evening) : file.evening
            print("📖 [jsonLessons] 晚禱選擇: isFirstVespers=\(liturgy.isFirstVespers), period=\(period == nil ? "nil" : "有值")")
            if liturgy.isFirstVespers {
                print("   → 使用 vigil=\(file.vigil == nil ? "nil" : "有值"), evening=\(file.evening == nil ? "nil" : "有值")")
            }
        } else {
            period = file.morning
            print("📖 [jsonLessons] 早禱選擇: morning=\(file.morning == nil ? "nil" : "有值")")
        }
        
        if year == "1943", let set = lectionarySet(
            for: date,
            liturgy: liturgy,
            isEvening: isEvening,
            year: "1943",
            setId: nil
        ), let setLessons = set.lessons {
            print("✅ [jsonLessons] 1943 使用 lectionarySet")
            return setLessons
        }
        
        guard let lessons = period?.lessons else {
            print("❌ [jsonLessons] period?.lessons 為 nil (period=\(period == nil ? "nil" : "有值"))")
            return nil
        }
        print("✅ [jsonLessons] lessons 容器有值")
        
        let base: DailyOfficeFile.OfficePeriod.LessonsGroup?
        switch year {
        case "1943": base = lessons.year1943
        case "1928": base = lessons.year1928
        case "1962": base = lessons.year1962
        case "special": base = lessons.special
        default:
            base = lessons.special ?? lessons.year1928 ?? lessons.year1962 ?? lessons.year1943
        }
        
        print("📖 [jsonLessons] year=\(year), base=\(base == nil ? "nil" : "有值")")
        if let b = base {
            print("   → ot=\(b.ot == nil ? "nil" : "\(b.ot!.book) \(b.ot!.chapter)")")
            print("   → nt=\(b.nt == nil ? "nil" : "\(b.nt!.book) \(b.nt!.chapter)")")
        } else {
            print("   → lessons.year1928=\(lessons.year1928 == nil ? "nil" : "有值")")
            print("   → lessons.year1962=\(lessons.year1962 == nil ? "nil" : "有值")")
            print("   → lessons.year1943=\(lessons.year1943 == nil ? "nil" : "有值")")
            print("   → lessons.special=\(lessons.special == nil ? "nil" : "有值")")
        }
        
        return base
    }
}


// 放在 DailyOfficeLoader.swift 或獨立的 Helpers.swift 中
func displayNameForLectionaryOption(_ option: String) -> String {
    switch option {
    case "1943":    return "1943年經課"
    case "1928":    return "1928年經課"
    case "1962":    return "1962年經課"
    case "special": return "專用經課"
    default:        return option
    }
}



// MARK: - 🌟 前夕（vigil）經課讀取擴展
//
// 用途：當今日聖日在晚禱被降級為紀念、晚禱轉為明日聖日的前夕晚禱時，
// 1928 / 1962 經課需改讀「被慶祝聖日」（明日）JSON 的
// vigil（前夕）經課；無 vigil 則回退 evening。
//
// 此擴展可直接附加在 DailyOfficeLoader.swift 末尾，
// 或作為獨立檔案加入專案（需加入 App target）。
extension DailyOfficeLoader {
    
    /// 讀取指定日期 JSON 的前夕晚禱經課（vigil ?? evening）。
    /// - Parameters:
    ///   - date: 被慶祝聖日的日期（即明日）
    ///   - liturgy: 被慶祝聖日的禮儀資訊（resolve(for: 明日) 的結果）
    ///   - year: 經課版本（"1928" / "1962" / "1943" / "special"）
    func vigilLessons(
        for date: Date,
        liturgy: DailyLiturgy,
        year: String
    ) -> DailyOfficeFile.OfficePeriod.LessonsGroup? {
        guard let file = loadOfficeFile(for: date, liturgy: liturgy) else {
            print("❌ [vigilLessons] loadOfficeFile 返回 nil")
            return nil
        }
        
        let period = file.vigil ?? file.evening
        guard let lessons = period?.lessons else {
            print("❌ [vigilLessons] '\(file.name)' vigil/evening 無 lessons 容器")
            return nil
        }
        
        let group: DailyOfficeFile.OfficePeriod.LessonsGroup?
        switch year {
        case "1943": group = lessons.year1943
        case "1928": group = lessons.year1928
        case "1962": group = lessons.year1962
        case "special": group = lessons.special
        default:
            group = lessons.special ?? lessons.year1928 ?? lessons.year1962 ?? lessons.year1943
        }
        
        if let g = group {
            print("✅ [vigilLessons] '\(file.name)' year=\(year) 命中: ot=\(g.ot.map { "\($0.book) \($0.chapter)" } ?? "nil"), nt=\(g.nt.map { "\($0.book) \($0.chapter)" } ?? "nil")")
        } else {
            print("❌ [vigilLessons] '\(file.name)' vigil/evening 無 year=\(year) 經課")
        }
        return group
    }
}
