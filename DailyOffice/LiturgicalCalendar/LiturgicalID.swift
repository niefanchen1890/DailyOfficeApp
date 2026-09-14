import Foundation

/// 禮儀日的穩定識別碼。
///
/// `rawValue` 只供程式和資料檔使用，不應顯示在畫面上，也不隨繁簡名稱改變。
struct LiturgicalID: RawRepresentable, Codable, Hashable, Sendable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    // MARK: - 十一月至十二月聖日與八日慶期

    static let allSaints = LiturgicalID(rawValue: "all_saints")
    static let allSaintsOctave3 = LiturgicalID(rawValue: "all_saints_octave_3")
    static let stCharlesBorromeo = LiturgicalID(rawValue: "st_charles_borromeo")
    static let stElizabeth = LiturgicalID(rawValue: "st_elizabeth")
    static let allSaintsOctave6 = LiturgicalID(rawValue: "all_saints_octave_6")
    static let stWillibrord = LiturgicalID(rawValue: "st_willibrord")
    static let anglicanSaints = LiturgicalID(rawValue: "anglican_saints")
    static let stTheodoreMartyr = LiturgicalID(rawValue: "st_theodore_martyr")
    static let stMartin = LiturgicalID(rawValue: "st_martin")
    static let stBlaiseTours = LiturgicalID(rawValue: "st_blaise_tours")
    static let stAlbertGreat = LiturgicalID(rawValue: "st_albert_great")
    static let stGertrude = LiturgicalID(rawValue: "st_gertrude")
    static let stHughLincoln = LiturgicalID(rawValue: "st_hugh_lincoln")
    static let stHildaWhitby = LiturgicalID(rawValue: "st_hilda_whitby")
    static let stElizabethHungary = LiturgicalID(rawValue: "st_elizabeth_hungary")
    static let stEdmundKingMartyr = LiturgicalID(rawValue: "st_edmund_king_martyr")
    static let presentationBvm = LiturgicalID(rawValue: "presentation_bvm")
    static let stCecilia = LiturgicalID(rawValue: "st_cecilia")
    static let stClement = LiturgicalID(rawValue: "st_clement")
    static let stJohnCross = LiturgicalID(rawValue: "st_john_cross")
    static let stCatherineAlexandria = LiturgicalID(rawValue: "st_catherine_alexandria")
    static let stSylvesterAbbot = LiturgicalID(rawValue: "st_sylvester_abbot")
    static let stAndrewVigil = LiturgicalID(rawValue: "st_andrew_vigil")
    static let stAndrew = LiturgicalID(rawValue: "st_andrew")
    static let blessedNicholasFerrar = LiturgicalID(rawValue: "blessed_nicholas_ferrar")
    static let stPeterChrysologus = LiturgicalID(rawValue: "st_peter_chrysologus")
    static let stFrancisXavier = LiturgicalID(rawValue: "st_francis_xavier")
    static let stClementAlexandria = LiturgicalID(rawValue: "st_clement_alexandria")
    static let stSabas = LiturgicalID(rawValue: "st_sabas")
    static let stNicholas = LiturgicalID(rawValue: "st_nicholas")
    static let stAmbrose = LiturgicalID(rawValue: "st_ambrose")
    static let immaculateConception = LiturgicalID(rawValue: "immaculate_conception")
    static let immaculateConceptionOctave2 = LiturgicalID(rawValue: "immaculate_conception_octave_2")
    static let immaculateConceptionOctave3 = LiturgicalID(rawValue: "immaculate_conception_octave_3")
    static let immaculateConceptionOctave4 = LiturgicalID(rawValue: "immaculate_conception_octave_4")
    static let immaculateConceptionOctave5 = LiturgicalID(rawValue: "immaculate_conception_octave_5")
    static let stLucy = LiturgicalID(rawValue: "st_lucy")
    static let immaculateConceptionOctave7 = LiturgicalID(rawValue: "immaculate_conception_octave_7")
    static let immaculateConceptionOctave8 = LiturgicalID(rawValue: "immaculate_conception_octave_8")
    static let stThomas = LiturgicalID(rawValue: "st_thomas")
    static let christmasVigil = LiturgicalID(rawValue: "christmas_vigil")
    static let stStephen = LiturgicalID(rawValue: "st_stephen")
    static let stJohnEvangelist = LiturgicalID(rawValue: "st_john_evangelist")
    static let holyInnocents = LiturgicalID(rawValue: "holy_innocents")
    static let stThomasBecket = LiturgicalID(rawValue: "st_thomas_becket")
    static let christmasOctave6 = LiturgicalID(rawValue: "christmas_octave_6")
    static let stSylvester = LiturgicalID(rawValue: "st_sylvester")
    static let allSaintsOctave4 = LiturgicalID(rawValue: "all_saints_octave_4")
    static let allSaintsOctave5 = LiturgicalID(rawValue: "all_saints_octave_5")
    static let allSaintsOctave7 = LiturgicalID(rawValue: "all_saints_octave_7")
    static let immaculateConceptionOctave6 = LiturgicalID(rawValue: "immaculate_conception_octave_6")
    static let christmasOctave2 = LiturgicalID(rawValue: "christmas_octave_2")
    static let christmasOctave3 = LiturgicalID(rawValue: "christmas_octave_3")
    static let christmasOctave4 = LiturgicalID(rawValue: "christmas_octave_4")
    static let christmasOctave5 = LiturgicalID(rawValue: "christmas_octave_5")
    static let christmasOctave7 = LiturgicalID(rawValue: "christmas_octave_7")

    // MARK: - 一月聖日

    static let stephenOctave8 = LiturgicalID(rawValue: "stephen_octave_8")
    static let johnOctave8 = LiturgicalID(rawValue: "john_octave_8")
    static let holyInnocentsOctave8 = LiturgicalID(rawValue: "holy_innocents_octave_8")
    static let epiphanyOctave2 = LiturgicalID(rawValue: "epiphany_octave_2")
    static let epiphanyOctave3 = LiturgicalID(rawValue: "epiphany_octave_3")
    static let epiphanyOctave4 = LiturgicalID(rawValue: "epiphany_octave_4")
    static let epiphanyOctave5 = LiturgicalID(rawValue: "epiphany_octave_5")
    static let epiphanyOctave6 = LiturgicalID(rawValue: "epiphany_octave_6")
    static let epiphanyOctave7 = LiturgicalID(rawValue: "epiphany_octave_7")
    static let epiphanyOctave8 = LiturgicalID(rawValue: "epiphany_octave_8")
    static let stHilary = LiturgicalID(rawValue: "st_hilary")
    static let stPaulHermit = LiturgicalID(rawValue: "st_paul_hermit")
    static let williamLaud = LiturgicalID(rawValue: "william_laud")
    static let stAnthonyEgypt = LiturgicalID(rawValue: "st_anthony_egypt")
    static let stPriscilla = LiturgicalID(rawValue: "st_priscilla")
    static let stsFabianSebastian = LiturgicalID(rawValue: "sts_fabian_sebastian")
    static let stAgnes = LiturgicalID(rawValue: "st_agnes")
    static let stVincent = LiturgicalID(rawValue: "st_vincent")
    static let stTimothy = LiturgicalID(rawValue: "st_timothy")
    static let conversionStPaul = LiturgicalID(rawValue: "conversion_st_paul")
    static let stPolycarp = LiturgicalID(rawValue: "st_polycarp")
    static let stChrysostom = LiturgicalID(rawValue: "st_chrysostom")
    static let anglicanEpiscopate = LiturgicalID(rawValue: "anglican_episcopate")
    static let stFrancisDeSales = LiturgicalID(rawValue: "st_francis_de_sales")
    static let kingCharlesMartyr = LiturgicalID(rawValue: "king_charles_martyr")
    static let stJohnBosco = LiturgicalID(rawValue: "st_john_bosco")

    // MARK: - 核心直接引用的固定節期

    static let circumcision = LiturgicalID(rawValue: "circumcision")
    static let epiphany = LiturgicalID(rawValue: "epiphany")
    static let epiphanyVigil = LiturgicalID(rawValue: "epiphany_vigil")
    static let ashWednesday = LiturgicalID(rawValue: "ash_wednesday")
    static let easterDay = LiturgicalID(rawValue: "easter_day")
    static let ascension = LiturgicalID(rawValue: "ascension")
    static let ascensionVigil = LiturgicalID(rawValue: "ascension_vigil")
    static let fridayAfterAscensionOctave = LiturgicalID(rawValue: "friday_after_ascension_octave")
    static let pentecost = LiturgicalID(rawValue: "pentecost")
    static let pentecostVigil = LiturgicalID(rawValue: "pentecost_vigil")
    static let trinitySunday = LiturgicalID(rawValue: "trinity_sunday")
    static let trinityOctaveMonday = LiturgicalID(rawValue: "trinity_octave_monday")
    static let trinityOctaveTuesday = LiturgicalID(rawValue: "trinity_octave_tuesday")
    static let trinityOctaveWednesday = LiturgicalID(rawValue: "trinity_octave_wednesday")
    static let corpusChristiOctaveDayEight = LiturgicalID(rawValue: "corpus_christi_octave_day_8")
    static let sacredHeart = LiturgicalID(rawValue: "sacred_heart")
    static let peterAndPaul = LiturgicalID(rawValue: "peter_and_paul")
    static let peterAndPaulOctaveDaySeven = LiturgicalID(rawValue: "peter_and_paul_octave_day_7")
    static let paulCommemoration = LiturgicalID(rawValue: "paul_commemoration")
    static let preciousBlood = LiturgicalID(rawValue: "precious_blood")
    static let nativityOfJohnBaptistOctaveDayEight = LiturgicalID(rawValue: "nativity_of_john_baptist_octave_day_8")
    static let assumption = LiturgicalID(rawValue: "assumption")
    static let assumptionOctaveDaySeven = LiturgicalID(rawValue: "assumption_octave_day_7")
    static let firstSundayOfAdvent = LiturgicalID(rawValue: "advent_1_sunday")
    static let christmasDay = LiturgicalID(rawValue: "christmas_day")
    static let sundayAfterChristmas = LiturgicalID(rawValue: "sunday_after_christmas")
    static let septuagesimaSunday = LiturgicalID(rawValue: "septuagesima_sunday")
    static let sexagesimaSunday = LiturgicalID(rawValue: "sexagesima_sunday")
    static let quinquagesimaSunday = LiturgicalID(rawValue: "quinquagesima_sunday")
    static let passionSunday = LiturgicalID(rawValue: "passion_sunday")
    static let palmSunday = LiturgicalID(rawValue: "palm_sunday")
    static let sundayAfterAscension = LiturgicalID(rawValue: "sunday_after_ascension")
    static let corpusChristi = LiturgicalID(rawValue: "corpus_christi")
    static let corpusChristiOctave = LiturgicalID(rawValue: "corpus_christi_octave")
    static let corpusChristiOctaveSunday = LiturgicalID(rawValue: "corpus_christi_octave_sunday")
    static let sacredHeartOctaveSunday = LiturgicalID(rawValue: "sacred_heart_octave_sunday")
    static let sacredHeartOctaveDayEight = LiturgicalID(rawValue: "sacred_heart_octave_day_8")
    static let christTheKing = LiturgicalID(rawValue: "christ_the_king")
    static let beforeAdventMonday = LiturgicalID(rawValue: "before_advent_monday")
    static let beforeAdventTuesday = LiturgicalID(rawValue: "before_advent_tuesday")
    static let beforeAdventWednesday = LiturgicalID(rawValue: "before_advent_wednesday")
    static let beforeAdventThursday = LiturgicalID(rawValue: "before_advent_thursday")
    static let beforeAdventFriday = LiturgicalID(rawValue: "before_advent_friday")
    static let beforeAdventSaturday = LiturgicalID(rawValue: "before_advent_saturday")
    static let sundayBeforeAdvent = LiturgicalID(rawValue: "sunday_before_advent")
    static let barnabas = LiturgicalID(rawValue: "st_barnabas")
    static let stephenOfHungary = LiturgicalID(rawValue: "st_stephen_hungary")
    static let evurtius = LiturgicalID(rawValue: "st_evurtius")
    static let nativityOfMary = LiturgicalID(rawValue: "nativity_of_mary")
    static let peterClaver = LiturgicalID(rawValue: "st_peter_claver")
    static let protusAndHyacinth = LiturgicalID(rawValue: "sts_proto_hyacinth")
    static let holyNameOfMary = LiturgicalID(rawValue: "holy_name_mary")
    static let holyCross = LiturgicalID(rawValue: "holy_cross")
    static let ourLadyOfSorrows = LiturgicalID(rawValue: "our_lady_sorrows")
    static let cyprian = LiturgicalID(rawValue: "st_cyprian")
    static let ninian = LiturgicalID(rawValue: "st_ninian")
    static let stigmataOfFrancis = LiturgicalID(rawValue: "st_francis_stigmata")
    static let edwardBouveriePusey = LiturgicalID(rawValue: "blessed_edward_pusey")
    static let theodoreOfCanterbury = LiturgicalID(rawValue: "st_theodore_canterbury")
    static let johnColeridgePatteson = LiturgicalID(rawValue: "blessed_john_patteson")
    static let matthewVigil = LiturgicalID(rawValue: "st_matthew_vigil")
    static let matthew = LiturgicalID(rawValue: "st_matthew")
    static let mauriceAndCompanions = LiturgicalID(rawValue: "st_maurice")
    static let linus = LiturgicalID(rawValue: "st_linus")
    static let thecla = LiturgicalID(rawValue: "st_thecla")
    static let ourLadyOfRansom = LiturgicalID(rawValue: "our_lady_ransom")
    static let lancelotAndrewes = LiturgicalID(rawValue: "blessed_lancelot_andrewes")
    static let cosmasAndDamian = LiturgicalID(rawValue: "sts_cosmas_damian")
    static let wenceslaus = LiturgicalID(rawValue: "st_wenceslaus")
    static let michaelAndAllAngels = LiturgicalID(rawValue: "st_michael_all_angels")
    static let ourLadyOfTheRosary = LiturgicalID(rawValue: "our_lady_rosary")
    static let simeonAndAnna = LiturgicalID(rawValue: "sts_simeon_anna")
    static let bridgetOfSweden = LiturgicalID(rawValue: "st_bridget")
    static let denisAndCompanions = LiturgicalID(rawValue: "sts_denis")
    static let motherhoodOfMary = LiturgicalID(rawValue: "mother_of_god")
    static let wilfrid = LiturgicalID(rawValue: "st_wilfrid")
    static let translationOfEdwardConfessor = LiturgicalID(rawValue: "translation_st_edward_confessor")
    static let callistus = LiturgicalID(rawValue: "st_callistus")
    static let ourLadyOfWalsingham = LiturgicalID(rawValue: "our_lady_walsingham")
    static let teresaOfAvila = LiturgicalID(rawValue: "st_teresa_avila")
    static let hedwig = LiturgicalID(rawValue: "st_hedwig")
    static let etheldreda = LiturgicalID(rawValue: "st_etheldreda")
    static let luke = LiturgicalID(rawValue: "st_luke")
    static let crispinAndCrispinian = LiturgicalID(rawValue: "sts_crispin_crispinian")
    static let simonAndJude = LiturgicalID(rawValue: "sts_simon_jude")
    static let allSaintsVigil = LiturgicalID(rawValue: "all_saints_vigil")
    static let simonAndJudeVigil = LiturgicalID(rawValue: "sts_simon_jude_vigil")
    static let hilarion = LiturgicalID(rawValue: "st_hilarion")
    static let ursulaAndCompanions = LiturgicalID(rawValue: "sts_ursula_and_companions")
    static let newGuineaMartyrs = LiturgicalID(rawValue: "new_guinea_martyrs")
    static let raphael = LiturgicalID(rawValue: "st_raphael")
    static let frideswide = LiturgicalID(rawValue: "st_frideswide")
    static let bruno = LiturgicalID(rawValue: "st_bruno")
    static let placidus = LiturgicalID(rawValue: "st_placid")
    static let francisOfAssisi = LiturgicalID(rawValue: "st_francis_assisi")
    static let thereseOfLisieux = LiturgicalID(rawValue: "st_therese_of_lisieux")
    static let jerome = LiturgicalID(rawValue: "st_jerome")
    static let allSouls = LiturgicalID(rawValue: "all_souls")
    static let saturdayOfficeOfOurLady = LiturgicalID(rawValue: "saturday_office_of_our_lady")

    /// 尚未完成正式編碼的舊資料使用此命名空間過渡。
    /// 這只是相容層；業務規則不可新增對 `legacy.*` 的依賴。
    static func legacy(title: String) -> LiturgicalID {
        LiturgicalID(rawValue: "legacy.\(title)")
    }

    /// 一般節期週日的結構化識別碼，例如 `temporal.easter.week.5.weekday.1`。
    static func temporal(season: LiturgicalSeason, week: Int, weekday: Int) -> LiturgicalID {
        LiturgicalID(rawValue: "temporal.\(season.identifierKey).week.\(week).weekday.\(weekday)")
    }

    var temporalComponents: (season: LiturgicalSeason, week: Int, weekday: Int)? {
        let parts = rawValue.split(separator: ".")
        guard parts.count == 6,
              parts[0] == "temporal",
              parts[2] == "week",
              parts[4] == "weekday",
              let season = LiturgicalSeason(identifierKey: String(parts[1])),
              let week = Int(parts[3]),
              let weekday = Int(parts[5]) else { return nil }
        return (season, week, weekday)
    }

    /// 把現有繁體標題轉成穩定 ID。後續資料 JSON 加入 identifier 後，將逐步不再需要此表。
    static func fromLegacyTitle(_ title: String) -> LiturgicalID {
        let baseTitle: String = {
            for marker in [" (", "（"] {
                if let range = title.range(of: marker) {
                    return String(title[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                }
            }
            return title
        }()

        if baseTitle == "禮拜六特敬聖母" {
            return .saturdayOfficeOfOurLady
        }

        let exact: [String: LiturgicalID] = [
            "聖司提反日八日慶期第八日": .stephenOctave8,
            "聖司提反八日慶期第八日": .stephenOctave8,
            "聖約翰日八日慶期第八日": .johnOctave8,
            "傳福音使徒聖約翰八日慶期第八日": .johnOctave8,
            "嬰孩被殺日八日慶期第八日": .holyInnocentsOctave8,
            "嬰孩被殺八日慶期第八日": .holyInnocentsOctave8,
            "顯現望日": .epiphanyVigil,
            "救主顯現日": .epiphany,
            "顯現日八日慶期第二日": .epiphanyOctave2,
            "顯現八日慶期第二日": .epiphanyOctave2,
            "顯現八日慶期第三日": .epiphanyOctave3,
            "顯現日八日慶期第三日": .epiphanyOctave3,
            "顯現八日慶期第四日": .epiphanyOctave4,
            "顯現日八日慶期第四日": .epiphanyOctave4,
            "顯現八日慶期第五日": .epiphanyOctave5,
            "顯現日八日慶期第五日": .epiphanyOctave5,
            "顯現八日慶期第六日": .epiphanyOctave6,
            "顯現日八日慶期第六日": .epiphanyOctave6,
            "顯現八日慶期第七日": .epiphanyOctave7,
            "顯現日八日慶期第七日": .epiphanyOctave7,
            "顯現日八日慶期第八日": .epiphanyOctave8,
            "教會聖師、精修者聖希拉里主教": .stHilary,
            "教會聖師聖希拉里主教": .stHilary,
            "首位隱修士聖保羅": .stPaulHermit,
            "殉道者真福威廉·勞德主教": .williamLaud,
            "真福威廉·勞德主教": .williamLaud,
            "聖安東尼院長": .stAnthonyEgypt,
            "殉道童貞女聖百基拉": .stPriscilla,
            "殉道者聖法比盎和聖塞巴斯蒂安": .stsFabianSebastian,
            "殉道者聖法比盎和聖巴斯弟盎": .stsFabianSebastian,
            "殉道童貞女聖雅妮": .stAgnes,
            "殉道童貞女聖阿格妮絲": .stAgnes,
            "真福殉道者聖文森與聖阿納斯塔修": .stVincent,
            "殉道者聖文生": .stVincent,
            "殉道者聖文森與聖阿納斯塔修": .stVincent,
            "聖梯摩太主教": .stTimothy,
            "殉道者聖提摩太主教": .stTimothy,
            "使徒聖保羅受感化日": .conversionStPaul,
            "殉道者聖坡旅甲主教": .stPolycarp,
            "聖波利卡主教": .stPolycarp,
            "教會聖師聖金口約翰": .stChrysostom,
            "教會聖師、精修者金口聖約翰主教": .stChrysostom,
            "授予安立甘公教會主教聖品": .anglicanEpiscopate,
            "聖方濟各·沙雷氏主教": .stFrancisDeSales,
            "教會聖師、精修者聖法蘭西斯·沙雷士主教": .stFrancisDeSales,
            "真福殉道聖王查理·斯圖亞特": .kingCharlesMartyr,
            "殉道王查理": .kingCharlesMartyr,
            "聖約翰·鮑思高": .stJohnBosco,
            "聖若望·鮑思高": .stJohnBosco,
            "諸聖日": .allSaints,
            "諸靈日": .allSouls,
            "諸聖八日慶期第三日": .allSaintsOctave3,
            "聖卡洛·博羅梅奧主教": .stCharlesBorromeo,
            "聖伊麗莎白": .stElizabeth,
            "諸聖八日慶期第六日": .allSaintsOctave6,
            "聖威利布羅德主教": .stWillibrord,
            "聖威利布羅德": .stWillibrord,
            "安立甘諸聖": .anglicanSaints,
            "聖西奧多": .stTheodoreMartyr,
            "聖馬丁": .stMartin,
            "聖馬丁主教": .stMartin,
            "圖爾的聖布萊斯": .stBlaiseTours,
            "圖爾的聖布萊斯主教": .stBlaiseTours,
            "教會聖師大聖阿爾伯特主教": .stAlbertGreat,
            "童貞女聖格特魯德": .stGertrude,
            "倫斯特的聖胡格主教": .stHughLincoln,
            "惠特比的聖希爾達院長": .stHildaWhitby,
            "匈牙利的聖伊麗莎白": .stElizabethHungary,
            "匈牙利的聖婦伊麗莎白女王": .stElizabethHungary,
            "殉道聖王埃德蒙": .stEdmundKingMartyr,
            "榮福童貞馬利亞奉獻日": .presentationBvm,
            "殉道童貞女聖塞西莉亞": .stCecilia,
            "羅馬的聖革利免": .stClement,
            "羅馬的聖克萊門特主教": .stClement,
            "十架聖約翰": .stJohnCross,
            "殉道童貞女亞歷山大的聖凱瑟琳": .stCatherineAlexandria,
            "亞歷山大的聖凱瑟琳": .stCatherineAlexandria,
            "聖西爾維斯特院長": .stSylvesterAbbot,
            "聖西爾維斯特": .stSylvesterAbbot,
            "使徒聖安得烈望日": .stAndrewVigil,
            "使徒聖安德烈望日": .stAndrewVigil,
            "使徒聖安得烈日": .stAndrew,
            "使徒聖安德烈日": .stAndrew,
            "真福尼古拉·費拉爾執事": .blessedNicholasFerrar,
            "真福尼古拉·費拉爾": .blessedNicholasFerrar,
            "教會聖師、金言聖彼得主教": .stPeterChrysologus,
            "金言聖彼得主教": .stPeterChrysologus,
            "聖法蘭西斯·沙勿略": .stFrancisXavier,
            "亞歷山大的聖革利免": .stClementAlexandria,
            "聖薩巴斯": .stSabas,
            "聖薩巴斯院長": .stSabas,
            "聖尼古拉斯主教": .stNicholas,
            "精修者聖尼古拉斯主教": .stNicholas,
            "聖安波羅修": .stAmbrose,
            "聖安波羅修主教": .stAmbrose,
            "榮福童貞馬利亞始胎日": .immaculateConception,
            "榮福童貞馬利亞始胎八日慶期第二日": .immaculateConceptionOctave2,
            "榮福童貞馬利亞始胎八日慶期第三日": .immaculateConceptionOctave3,
            "榮福童貞馬利亞始胎八日慶期第四日": .immaculateConceptionOctave4,
            "榮福童貞馬利亞始胎八日慶期第五日": .immaculateConceptionOctave5,
            "殉道童貞女聖露西": .stLucy,
            "榮福童貞馬利亞始胎八日慶期第七日": .immaculateConceptionOctave7,
            "榮福童貞馬利亞始胎八日慶期第八日": .immaculateConceptionOctave8,
            "使徒聖多馬日": .stThomas,
            "聖誕望日": .christmasVigil,
            "救主聖誕日": .christmasDay,
            "聖司提反日": .stStephen,
            "殉道會吏聖司提反日": .stStephen,
            "傳福音使徒聖約翰日": .stJohnEvangelist,
            "嬰孩被殺日": .holyInnocents,
            "坎特伯雷的聖托馬斯大主教": .stThomasBecket,
            "坎特伯雷的聖托馬斯主教": .stThomasBecket,
            "聖誕日八日慶期第六日": .christmasOctave6,
            "聖誕八日慶期第六日": .christmasOctave6,
            "聖誕日八日慶期第6日": .christmasOctave6,
            "聖西爾維斯特主教": .stSylvester,
            "諸聖日八日慶期第四日": .allSaintsOctave4,
            "諸聖八日慶期第五日": .allSaintsOctave5,
            "諸聖八日慶期第七日": .allSaintsOctave7,
            "榮福童貞馬利亞始胎八日慶期第六日": .immaculateConceptionOctave6,
            "聖誕日八日慶期第二日": .christmasOctave2,
            "聖誕日八日慶期第2日": .christmasOctave2,
            "聖誕日八日慶期第三日": .christmasOctave3,
            "聖誕日八日慶期第3日": .christmasOctave3,
            "聖誕日八日慶期第四日": .christmasOctave4,
            "聖誕日八日慶期第4日": .christmasOctave4,
            "聖誕日八日慶期第五日": .christmasOctave5,
            "聖誕日八日慶期第5日": .christmasOctave5,
            "聖誕日八日慶期第七日": .christmasOctave7,
            "聖誕日八日慶期第7日": .christmasOctave7,
            "諸聖八日慶期第四日": .allSaintsOctave4,
            "救主受割禮日": .circumcision,
            "顯現日": .epiphany,
            "救主顯現望日": .epiphanyVigil,
            "大齋首日": .ashWednesday,
            "復活日": .easterDay,
            "救主升天日": .ascension,
            "升天望日": .ascensionVigil,
            "升天八日慶期後禮拜五": .fridayAfterAscensionOctave,
            "聖靈降臨日": .pentecost,
            "聖靈降臨望日": .pentecostVigil,
            "三一主日": .trinitySunday,
            "三一主日後禮拜一": .trinityOctaveMonday,
            "三一主日後禮拜二": .trinityOctaveTuesday,
            "三一主日後禮拜三": .trinityOctaveWednesday,
            "基督聖體節八日慶期第八日": .corpusChristiOctaveDayEight,
            "耶穌聖心節": .sacredHeart,
            "使徒聖彼得與聖保羅日": .peterAndPaul,
            "紀念使徒聖保羅": .paulCommemoration,
            "我主基督至聖寶血": .preciousBlood,
            "施洗聖約翰誕辰日八日慶期第八日": .nativityOfJohnBaptistOctaveDayEight,
            "榮福童貞馬利亞升天日": .assumption,
            "降臨第一主日": .firstSundayOfAdvent,
            "聖誕日": .christmasDay,
            "七旬主日": .septuagesimaSunday,
            "六旬主日": .sexagesimaSunday,
            "五旬主日": .quinquagesimaSunday,
            "苦難主日": .passionSunday,
            "棕樹主日": .palmSunday,
            "升天後主日": .sundayAfterAscension,
            "基督聖體節": .corpusChristi,
            "基督聖體節八日慶期": .corpusChristiOctave,
            "三一主日後第一主日": .corpusChristiOctaveSunday,
            "三一主日後第二主日": .sacredHeartOctaveSunday,
            "耶穌聖心節八日慶期第八日": .sacredHeartOctaveDayEight,
            "基督君王節": .christTheKing,
            "降臨前主日禮拜一": .beforeAdventMonday,
            "降臨前主日禮拜二": .beforeAdventTuesday,
            "降臨前主日禮拜三": .beforeAdventWednesday,
            "降臨前主日禮拜四": .beforeAdventThursday,
            "降臨前主日禮拜五": .beforeAdventFriday,
            "降臨前主日禮拜六": .beforeAdventSaturday,
            "降臨前主日": .sundayBeforeAdvent,
            "使徒聖巴拿巴日": .barnabas,
            "匈牙利的聖王聖司提反": .stephenOfHungary,
            "聖艾烏爾提烏斯主教": .evurtius,
            "榮福童貞女馬利亞誕辰日": .nativityOfMary,
            "聖彼得·克拉維爾": .peterClaver,
            "殉道者聖普羅托與聖海厄森斯": .protusAndHyacinth,
            "聖母聖名日": .holyNameOfMary,
            "聖十字架日": .holyCross,
            "七苦聖母": .ourLadyOfSorrows,
            "殉道者聖居普良主教": .cyprian,
            "聖尼安主教": .ninian,
            "聖法蘭西斯受五傷": .stigmataOfFrancis,
            "真福愛德華·布維萊·普西": .edwardBouveriePusey,
            "坎特伯雷的聖西奧多主教": .theodoreOfCanterbury,
            "真福約翰·科爾里奇·帕特森主教": .johnColeridgePatteson,
            "傳福音使徒聖馬太望日": .matthewVigil,
            "傳福音使徒聖馬太日": .matthew,
            "殉道者聖莫里斯及其同伴": .mauriceAndCompanions,
            "殉道者聖利奴主教": .linus,
            "童貞女聖德克拉": .thecla,
            "贖虜聖母": .ourLadyOfRansom,
            "真福蘭斯洛特·安德魯斯主教": .lancelotAndrewes,
            "殉道者聖科斯馬斯和聖達米盎": .cosmasAndDamian,
            "殉道者聖瓦茨拉夫": .wenceslaus,
            "聖米迦勒和諸天使日": .michaelAndAllAngels,
            "聖母玫瑰": .ourLadyOfTheRosary,
            "聖西面與聖亞拿": .simeonAndAnna,
            "聖婦彼濟達": .bridgetOfSweden,
            "聖彼濟達": .bridgetOfSweden,
            "聖丹尼斯、聖魯斯蒂克斯和聖愛德雷": .denisAndCompanions,
            "上帝之母榮福童貞馬利亞": .motherhoodOfMary,
            "聖威爾弗里德主教": .wilfrid,
            "敬遷聖王愛德華之聖髑": .translationOfEdwardConfessor,
            "殉道者聖卡利斯托主教": .callistus,
            "聖卡利斯圖斯一世": .callistus,
            "沃爾辛厄姆聖母": .ourLadyOfWalsingham,
            "阿維拉的聖德蘭": .teresaOfAvila,
            "聖婦海德薇": .hedwig,
            "童貞女聖埃塞爾麗達": .etheldreda,
            "傳福音的使徒聖路加": .luke,
            "聖克里斯賓與聖克里斯毗尼安": .crispinAndCrispinian,
            "使徒聖西門與聖猶大日": .simonAndJude,
            "諸聖望日": .allSaintsVigil,
            "使徒聖西門與聖猶大望日": .simonAndJudeVigil,
            "聖希拉里昂院長": .hilarion,
            "聖厄休拉及其同伴": .ursulaAndCompanions,
            "新幾內亞殉道諸聖": .newGuineaMartyrs,
            "天使長聖拉法勒": .raphael,
            "聖佛萊茲維德": .frideswide,
            "聖布魯諾": .bruno,
            "殉道者聖普拉西": .placidus,
            "聖普拉西及同伴": .placidus,
            "阿西西的聖法蘭西斯": .francisOfAssisi,
            "童貞女嬰孩耶穌聖德蘭": .thereseOfLisieux,
            "教會聖師、精修者聖耶柔米": .jerome
        ]

        if let identifier = exact[baseTitle] {
            return identifier
        }
        if baseTitle.contains("使徒聖彼得與聖保羅"), baseTitle.contains("第七日") {
            return .peterAndPaulOctaveDaySeven
        }
        if baseTitle.contains("榮福童貞馬利亞升天"), baseTitle.contains("第七日") {
            return .assumptionOctaveDaySeven
        }
        if baseTitle.contains("基督寶血") || baseTitle.contains("至聖寶血") {
            return .preciousBlood
        }
        if baseTitle.hasPrefix("降臨前主日") {
            return .sundayBeforeAdvent
        }
        if baseTitle.hasPrefix("聖誕後"), baseTitle.contains("主日") {
            return .sundayAfterChristmas
        }

        return .legacy(title: baseTitle)
    }
}

private extension LiturgicalSeason {
    var identifierKey: String {
        switch self {
        case .advent: return "advent"
        case .christmas: return "christmas"
        case .epiphany: return "epiphany"
        case .prelenten: return "prelenten"
        case .lent: return "lent"
        case .holyWeek: return "holy_week"
        case .easter: return "easter"
        case .ascension: return "ascension"
        case .pentecost: return "pentecost"
        case .trinity: return "trinity"
        case .holyDays: return "holy_days"
        }
    }

    init?(identifierKey: String) {
        switch identifierKey {
        case "advent": self = .advent
        case "christmas": self = .christmas
        case "epiphany": self = .epiphany
        case "prelenten": self = .prelenten
        case "lent": self = .lent
        case "holy_week": self = .holyWeek
        case "easter": self = .easter
        case "ascension": self = .ascension
        case "pentecost": self = .pentecost
        case "trinity": self = .trinity
        case "holy_days": self = .holyDays
        default: return nil
        }
    }
}
