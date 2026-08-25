import Foundation

// MARK: - 禮儀名稱映射器
/// 將 LiturgyCoreService 輸出的中文名稱，映射為 JSON 檔案的英文鍵名（snake_case）。
/// 主日、聖日、紀念都走同一套映射，DailyOfficeLoader 按優先級順序查找。
struct LiturgicalNameMapper {
    static let shared = LiturgicalNameMapper()
    
    // MARK: - 主映射表
    /// Key: 中文名稱（與 DailyLiturgy.mainTitle / commemorations 完全一致）
    /// Value: JSON 檔案使用的英文鍵（不含模組前綴）
    private let map: [String: String] = [
        // ═════ 移動節期（Temporale）═════
        "大齋首日 (聖灰禮拜三)":      "ash_wednesday",
        "聖週禮拜四：設立聖餐日":      "maundy_thursday",
        "聖週禮拜五：主受難日":        "good_friday",
        "聖週禮拜六":                 "holy_saturday",
        "復活日":                     "easter_day",
        "復活後第一主日（卸白衣主日）":  "easter_1_st_quasimodo",
        "升天望日":                   "ascension_vigil",
        "救主升天日":                 "ascension_day",
        "升天八日慶期第八日":          "ascension_octave_8",
        "聖靈降臨望日":               "pentecost_vigil",
        "聖靈降臨日":                 "pentecost",
        "聖靈降臨後一日":             "pentecost_1",
        "聖靈降臨後二日":             "pentecost_2",
        "三一主日":                   "trinity_sunday",
        "基督聖體節":                 "corpus_christi",
        "基督聖體節八日慶期第八日":     "corpus_christi_octave_8",
        "耶穌聖心節":                 "sacred_heart",
        "基督君王節":                 "christ_the_king",
        "降臨前主日":                 "sunday_next_before_advent",
        "降臨期第一主日":             "advent_1",
        "降臨期第四主日":             "advent_4",
        
        // ═════ 聖誕期 ═════
        "聖誕望日":                   "christmas_vigil",
        "聖誕日":                     "christmas",
        "聖司提反日":                 "st_stephen",
        "傳福音使徒聖約翰日":          "st_john_evangelist",
        "嬰孩被殺日":                 "holy_innocents",
        "救主受割禮日":               "circumcision",
        "顯現日":                     "epiphany",
        "顯現日八日慶期第八日":       "epiphany_octave_8",
        
        // ═════ 聖母與主耶穌 ═════
        "獻聖嬰日 (童女聖馬利亞告潔日)": "presentation",
        "聖母淨配聖約瑟":             "st_joseph",
        "童女聖馬利亞聞報日":         "annunciation",
        "榮福童貞馬利亞訪親日":       "visitation",
        "榮福童貞馬利亞升天日":                 "assumption",
        "榮福童貞馬利亞升天八日慶期第八日":     "assumption_octave_8",
        "榮福童貞女馬利亞誕辰日":     "nativity_bvm",
        "聖母聖名日":                   "holy_name_mary",
        "七苦聖母":                   "our_lady_sorrows",
        "加羅默爾聖母":               "our_lady_mount_carmel",
        "建立聖母雪地大殿":           "our_lady_snows",
        "贖虜聖母":                   "our_lady_ransom",
        "聖母玫瑰":                   "our_lady_rosary",
        "沃爾辛厄姆聖母":             "our_lady_walsingham",
        "上帝之母榮福童貞馬利亞":     "mother_of_god",
        "榮福童貞馬利亞奉獻日":       "presentation_bvm",
        "榮福童貞馬利亞始胎日":       "immaculate_conception",
        "露德聖母":                   "our_lady_lourdes",
        
        // ═════ 使徒與聖約翰 ═════
        "使徒聖保羅受感化日":         "conversion_st_paul",
        "傳福音使徒聖馬可日":         "st_mark",
        "使徒聖腓力和聖雅各日":       "sts_philip_james",
        "使徒聖巴拿巴日":             "st_barnabas",
        "施洗聖約翰誕辰日":          "st_john_baptist_nativity",
        "施洗聖約翰殉道日":          "beheading_st_john_baptist",
        "使徒聖彼得與聖保羅日":       "sts_peter_paul",
        "使徒聖雅各日":               "st_james",
        "使徒聖巴多羅買日":           "st_bartholomew",
        "傳福音使徒聖馬太日":         "st_matthew",
        "傳福音的使徒聖路加":         "st_luke",
        "使徒聖西門與聖猶大日":       "sts_simon_jude",
        "使徒聖安得烈日":             "st_andrew",
        "使徒聖多馬日":               "st_thomas",
        
        // ═════ 教會聖師與主教 ═════
        "教會聖師聖希拉里主教":       "st_hilary",
        "教會聖師聖金口約翰":         "st_chrysostom",
        "教會聖師托馬斯·阿奎納":      "st_thomas_aquinas",
        "教宗大聖格里高利":           "st_gregory_great",
        "耶路撒冷聖區利羅主教":       "st_cyril_jerusalem",
        "教會聖師大馬士革聖約翰":     "st_john_damascene",
        "教宗大聖利奧一世":           "st_leo_great",
        "教會聖師聖安瑟倫主教":       "st_anselm",
        "教會聖師聖彼得·卡尼修":      "st_peter_canisius",
        "教會聖師、童貞女錫耶納的聖凱瑟琳": "st_catherine_siena",
        "聖帕特里克主教":             "st_patrick",
        "聖卡斯伯特主教":             "st_cuthbert",
        "坎特伯雷的聖奧古斯丁":       "st_augustine_canterbury",
        "聖鄧斯坦主教":               "st_dunstan",
        "坎特伯雷的聖西奧多主教":     "st_theodore_canterbury",
        "聖馬丁主教":                 "st_martin",
        "教會聖師大聖阿爾伯特主教":   "st_albert_great",
        "殉道者聖居普良主教":         "st_cyprian",
        "教會聖師聖波拿文都拉主教":   "st_bonaventure",
        "教會聖師希坡的聖奧古斯丁主教": "st_augustine_hippo",
        "圖爾的聖布萊斯主教":         "st_blaise_tours",
        "聖卡洛·博羅梅奧主教":       "st_charles_borromeo",
        "倫斯特的聖胡格主教":         "st_hugh_lincoln",
        "羅馬的聖克萊門特主教":       "st_clement",
        "金言聖彼得主教":             "st_peter_chrysologus",
        "聖安波羅修主教":             "st_ambrose",
        "聖雷米吉烏斯主教":           "st_remi",
        "約克的聖保利努斯主教":       "st_paulinus_york",
        "聖威爾弗里德主教":           "st_wilfrid",
        "真福蘭斯洛特·安德魯斯主教":  "blessed_lancelot_andrewes",
        "真福約翰·科爾里奇·帕特森主教": "blessed_john_paterson",
        "真福耶利米·泰勒主教":        "blessed_jeremy_taylor",
        "真福愛德華·布維萊·普西":    "blessed_edward_pusey",
        
        // ═════ 殉道者 ═════
        "殉道者聖法比盎和聖巴斯弟盎":   "sts_fabian_sebastian",
        "殉道童貞女聖雅妮":           "st_agnes",
        "殉道者聖文生":               "st_vincent",
        "殉道者聖伊格納丟主教":       "st_ignatius_antioch",
        "殉道童貞女聖阿加莎":         "st_agatha",
        "殉道者聖提多主教":           "st_titus",
        "殉道者聖普伯度和聖費莉希蒂":  "sts_perpetua_felicity",
        "四十聖殉道者":               "forty_martyrs",
        "殉道者聖游斯丁":             "st_justin",
        "殉道者聖喬治":               "st_george",
        "殉道者維羅納的聖彼得":       "st_peter_verona",
        "殉道者聖涅柔斯、聖亞奇力、聖多彌諦拉、聖邦康": "sts_nerius_achilleus",
        "殉道者聖愛任紐主教":         "st_irenaeus",
        "殉道者聖西拉":               "st_silas",
        "殉道者聖亞波里拿留主教":     "st_apollinaris",
        "殉道者聖勞倫斯會吏":         "st_lawrence",
        "殉道者聖希坡律陀和聖卡西安":  "sts_hippolytus_cassian",
        "殉道者聖普拉西":             "st_placid",
        "殉道者聖莫里斯及其同伴":     "st_maurice",
        "殉道者聖利奴主教":           "st_linus",
        "殉道者聖科斯馬斯和聖達米盎":  "sts_cosmas_damian",
        "殉道者聖瓦茨拉夫":           "st_wenceslaus",
        "殉道者聖塞西莉亞":           "st_cecilia",
        "殉道童貞女亞歷山大的聖凱瑟琳": "st_catherine_alexandria",
        "殉道聖王埃德蒙":             "st_edmund_king_martyr",
        "殉道者聖卡利斯托主教":       "st_callistus",
        "殉道童貞女聖露西":           "st_lucy",
        "殉道童貞女安提阿的聖瑪格麗特": "st_margaret_antioch",
        "殉道者聖伯納多·米澤基":     "blessed_barnabas_mikki",
        "日本殉道者":                 "japanese_martyrs",
        "新幾內亞殉道諸聖":           "new_guinea_martyrs",
        "烏干達殉道諸聖":             "uganda_martyrs",
        "中華殉道諸聖":               "chinese_martyrs",
        "殉道者聖亞斐奇主教":         "st_aphrodisius",
        "殉道者聖西緬主教":           "st_simeon",
        
        // ═════ 聖人與貞女 ═════
        "首位隱修士聖保羅":           "st_paul_hermit",
        "聖安東尼院長":               "st_anthony_egypt",
        "殉道童貞女聖百基拉":         "st_priscilla",
        "聖方濟各·沙雷氏主教":       "st_francis_de_sales",
        "殉道王查理":                 "king_charles_martyr",
        "聖若望·鮑思高":             "st_john_bosco",
        "聖布萊斯主教":               "st_blaise",
        "施普林格的聖吉爾伯特院長":   "st_gilbert_sempringham",
        "聖羅慕鐸院長":               "st_romuald",
        "聖約翰·瑪達":               "st_john_matha",
        "教會聖師亞歷山大的聖區利羅": "st_cyril_alexandria",
        "童貞女聖思嘉":               "st_scholastica",
        "聖本篤·比斯克普院長":       "st_benedict_biscop",
        "聖肯蒂格恩主教":             "st_chad",
        "聖大衛主教":                 "st_david",
        "聖查德主教":                 "st_chad",
        "聖波利卡主教":               "st_polycarp",
        "聖梯摩太主教":               "st_timothy",
        "聖約翰·瓜爾貝特院長":       "st_john_gualbert",
        "聖文森·德·保羅":           "st_vincent_de_paul",
        "抹大拉的聖馬利亞":           "st_mary_magdalene",
        "童貞女聖馬大":               "st_martha",
        "聖安娜，榮福童貞馬利亞之母":  "st_anne",
        "聖彼得受鎖鏈":               "st_peter_chains",
        "教會聖師聖亞豐索·利古力主教": "st_alphonsus_liguori",
        "精修者聖尼哥德慕":           "st_nicodemus",
        "聖道明":                     "st_dominic",
        "真福約翰·梅森·尼爾":       "blessed_john_mason_neale",
        "聖約翰·維雅納":             "st_john_vianney",
        "童貞女聖克萊爾":             "st_clare",
        "聖約雅敬——聖母之父":         "st_joachim",
        "聖路易九世國王":             "st_louis_ix",
        "童貞女利馬的聖羅撒":         "st_rose_lima",
        "精修者聖艾登主教":           "st_aidan",
        "聖賈爾斯院長":               "st_giles",
        "匈牙利的聖王聖司提反":       "st_stephen_hungary",
        "聖彼得·克拉維爾":           "st_peter_claver",
        "殉道者聖普羅托與聖海厄森斯":  "sts_proto_hyacinth",
        "聖法蘭西斯受五傷":           "st_francis_stigmata",
        "聖布魯諾":                   "st_bruno",
        "聖婦彼濟達":                 "st_bridget",
        "聖丹尼斯、聖魯斯蒂克斯和聖愛德雷": "sts_denis",
        "聖佛萊茲維德":               "st_frideswide",
        "聖希拉里昂院長":             "st_hilarion",
        "聖克里斯賓與聖克里斯毗尼安":  "sts_crispin_crispinian",
        "聖尼古拉斯主教":             "st_nicholas",
        "聖薩巴斯院長":               "st_sabas",
        "聖法蘭西斯·沙勿略":         "st_francis_xavier",
        "亞歷山大的聖革利免":         "st_clement_alexandria",
        "聖西爾維斯特主教":           "st_sylvester",
        "聖格特魯德":                 "st_gertrude",
        "聖婦海德薇":                 "st_hedwig",
        "童貞女聖埃塞爾麗達":         "st_etheldreda",
        "十架聖約翰":                   "st_john_cross",
        "真福尼古拉·費拉爾執事":      "blessed_nicholas_ferrar",
        
        // ═════ 其他主要慶節 ═════
        "發現聖十架日":               "finding_holy_cross",
        "聖莫尼卡":                   "st_monica",
        "聖奧古斯丁受感化日":         "st_augustine_conversion",
        "聖科倫巴院長":               "st_columba",
        "蘇格蘭的聖瑪格麗特":         "st_margaret_scotland",
        "帕多瓦的聖安東尼":           "st_anthony_padua",
        "教會聖師大聖巴西流主教":     "st_basil_great",
        "聖博托爾夫院長":             "st_botolph",
        "聖以法蓮會吏":               "st_ephraem",
        "敬遷殉道聖王愛德華之聖髑":       "translation_st_edward",
        "英格蘭首位殉道者聖阿爾班":   "st_alban",
        "聖區利羅主教與聖美多德主教":     "sts_cyril_methodius",
        "葡萄牙的聖伊麗莎白女王":     "st_elizabeth_portugal",
        "殉道者聖約翰·費捨爾主教和聖托馬斯·莫爾": "sts_fisher_more",
        "聖本篤院長":                 "st_benedict_nursia",
        "聖阿歷克修斯":               "st_alexis",
        "聖依納爵·羅耀拉":           "st_ignatius_loyola",
        "聖彼得設立宗座於安提阿":     "chair_st_peter",
        "天使長聖加百列":             "st_gabriel",
        "守護聖天使":                 "guardian_angels",
        "阿西西的聖法蘭西斯":         "st_francis_assisi",
        "天使長聖拉法勒":             "st_raphael",
        "安立甘諸聖":                 "anglican_saints",
        "諸靈日":                     "all_souls",
        "聖誕日八日慶期第六日":       "christmas_octave_6",
        "聖誕日八日慶期第七日":       "christmas_octave_7",
        "聖誕日八日慶期第八日":       "christmas_octave_8",
        "顯現日八日慶期第二日":       "epiphany_octave_2",
        "顯現日八日慶期第三日":       "epiphany_octave_3",
        "施洗聖約翰誕辰日八日慶期第二日": "st_john_baptist_octave_2",
        "使徒聖彼得與聖保羅日八日慶期第八日": "sts_peter_paul_octave_8",
        "榮福童貞馬利亞升天八日慶期第三日":     "assumption_octave_3",
        "榮福童貞馬利亞升天八日慶期第四日":     "assumption_octave_4",
        "榮福童貞馬利亞升天八日慶期第五日":     "assumption_octave_5",
        "榮福童貞馬利亞升天八日慶期第六日":     "assumption_octave_6",
        "榮福童貞馬利亞升天八日慶期第七日":     "assumption_octave_7",
        "諸聖八日慶期第三日":         "all_saints_octave_3",
        "諸聖八日慶期第四日":         "all_saints_octave_4",
        "諸聖八日慶期第五日":         "all_saints_octave_5",
        "諸聖八日慶期第六日":         "all_saints_octave_6",
        "諸聖八日慶期第七日":         "all_saints_octave_7",
        "諸聖八日慶期第八日":         "all_saints_octave_8",
        "榮福童貞馬利亞始胎八日慶期第二日": "immaculate_conception_octave_2",
        "榮福童貞馬利亞始胎八日慶期第八日": "immaculate_conception_octave_8",
        
        // ═════ 望日 ═════
        "救主顯現望日":               "epiphany_vigil",
        "使徒聖馬提亞望日":           "st_matthias_vigil",
        "使徒聖雅各望日":             "st_james_vigil",
        "榮福童貞馬利亞升天望日":               "assumption_vigil",
        "使徒聖巴多羅買望日":         "st_bartholomew_vigil",
        "傳福音使徒聖馬太望日":       "st_matthew_vigil",
        "使徒聖西門與聖猶大望日":     "sts_simon_jude_vigil",
        "諸聖望日":                   "all_saints_vigil",
        "使徒聖安得烈望日":           "st_andrew_vigil",
        "使徒聖多馬望日":             "st_thomas_vigil",
    ]
    
    // MARK: - 公共方法
    
    /// 取得單一名稱對應的檔案鍵。若無對應，先去除括號內的紀念文字再試一次。
    func fileKey(for chineseName: String) -> String? {
        if let key = map[chineseName] { return key }
        
        // 處理如「殉道者聖愛任紐主教 (紀念施洗聖約翰八日慶期第五日)」的情況
        let clean = chineseName
            .components(separatedBy: " (")[0]
            .components(separatedBy: "（")[0]
            .trimmingCharacters(in: .whitespaces)
        return map[clean]
    }
    
    /// 從 DailyLiturgy 提取所有應嘗試讀取的檔案鍵，按禮儀優先級排序：
    /// 1. 主標題（慶祝）→ 2. 紀念（commemorations）→ 3. 遷移（transferred，可選）
    func allFileKeys(for liturgy: DailyLiturgy) -> [String] {
        var keys: [String] = []
        
        // 1. 主標題（慶祝）
        if let mainKey = fileKey(for: liturgy.mainTitle), !mainKey.isEmpty {
            keys.append(mainKey)
        }
        
        // 2. 紀念（commemorations）
        for name in liturgy.commemorations {
            if let key = fileKey(for: name), !key.isEmpty, !keys.contains(key) {
                keys.append(key)
            }
        }
        
        // 3. 遷移節日（通常當日不慶祝，但如果有專用內容想保留可啟用）
        // for name in liturgy.transferred {
        //     if let key = fileKey(for: name), !key.isEmpty, !keys.contains(key) {
        //         keys.append(key)
        //     }
        // }
        
        return keys
    }
    
    /// 僅提取紀念對應的鍵（供「紀念專用 Collect」等場景使用）
    func commemorationKeys(for liturgy: DailyLiturgy) -> [String] {
        liturgy.commemorations.compactMap { fileKey(for: $0) }
    }
}
