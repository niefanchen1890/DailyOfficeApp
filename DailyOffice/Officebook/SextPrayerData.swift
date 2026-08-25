import Foundation

// MARK: - 六時禱資料模型
struct SextPrayerData {

    // MARK: 開始啟應
    static let openingResponses: [Responsory] = [
        Responsory(leader: "啟：上帝阿，快來拯救我們。", people: "應：主阿，趕緊幫助我們。"),
        Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：起初怎樣，現在以及永遠也是怎樣，世世無盡。阿們。"),
        Responsory(leader: "啟：你們應當讚美主。", people: "應：主的名應當讚美。")
    ]

    // MARK: 聖詩（基礎三節，第三節由節期結尾替換）
    static let hymn = PrayerSection(
        title: "聖詩",
        rubric: nil,
        paragraphs: [
            "一、真理上帝權柄主宰，\n管理光陰循序更改。\n以主榮光清晨得光，\n以主火炎午日發晃。",
            "二、求將我中爭火打滅，\n分散情慾內心洗潔。\n保護身體無險無病，\n又賜靈魂確實安寧。",
            "三、至聖上帝三位一體，\n聖父聖靈與子合一。\n上帝至上永遠為君，\n我等所禱懇求應允。阿們。"
        ],
        responses: []
    )

    // MARK: - 節期聖詩結尾（通用模組，與一時禱/三時禱共用邏輯）
    struct SeasonalHymnEnding {
        static let endings: [String: String] = [
            "christmas_to_purification": "童女所生救主耶穌，常受一切讚美榮光。\n榮耀亦歸聖父聖靈，同受尊崇萬世無疆。阿們。",
            "epiphany_octave": "一切榮耀歸於恩主，\n為祢今日榮耀顯現；\n歸於聖父及與聖靈，稱頌讚美永世無盡。阿們。",
            "eastertide": "吾等獻上一切榮耀，\n歸於死而復生之主；\n及父與保惠師聖靈，\n稱頌讚美永世無盡。阿們。",
            "ascensiontide": "我眾今獻所有榮耀，\n歸於超越眾星之主，\n及父與保惠師聖靈，\n稱頌讚美永世無盡。阿們。",
            "sacred_heart": "我將榮耀全歸與主，\n主從聖心傾流恩典；\n如今與父永遠同在，\n偕同聖靈永世無盡。阿們。",
            "transfiguration": "榮耀全歸我主基督，\n今日山上顯現光輝；\n及父與保惠師聖靈，\n稱頌讚美永世無盡。阿們。",
            "christ_the_king": "我獻榮耀歸於耶穌，\n掌管普世國度之主；\n及父與保惠師聖靈，\n稱頌讚美永世無盡。阿們。",
            "bvm": "童女所生救主耶穌，\n常受一切讚美榮光。\n榮耀亦歸聖父聖靈，\n同受尊崇萬世無疆。阿們。"
        ]

        static func endingKey(for date: Date, liturgy: DailyLiturgy) -> String? {
            let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
            let season = info.season
            let weekNumber = info.weekNumber
            let title = liturgy.mainTitle

            if title.contains("耶穌聖心節") || title.contains("聖心節") {
                return "sacred_heart"
            }
            if title.contains("基督易容") || title.contains("易容顯光") {
                return "transfiguration"
            }
            if title.contains("基督普世君王") || title.contains("普世君王節") {
                return "christ_the_king"
            }
            if title.contains("童貞") || title.contains("聖母") || title.contains("馬利亞") {
                return "bvm"
            }
            if season == .ascension || title.contains("升天") {
                return "ascensiontide"
            }
            if [.easter, .pentecost].contains(season) || title.contains("復活") || title.contains("聖靈降臨") {
                return "eastertide"
            }
            if season == .epiphany && weekNumber == 1 {
                return "epiphany_octave"
            }
            if season == .christmas || title.contains("聖誕") || title.contains("主顯") {
                return "christmas_to_purification"
            }
            return nil
        }

        /// 組裝完整聖詩：無節期結尾時保留通用第三段；有節期結尾時替換最後一段
        static func assemble(baseVerses: [String], for date: Date, liturgy: DailyLiturgy) -> [String] {
            guard let key = endingKey(for: date, liturgy: liturgy),
                  let ending = endings[key],
                  !baseVerses.isEmpty else {
                return baseVerses
            }

            var verses = baseVerses

            // 先提取被替換的最後一段的段號，再移除
            let lastVerse = verses.last!
            let prefix = extractChineseNumberPrefix(lastVerse)
            verses.removeLast()

            let newEnding = prefix.isEmpty ? ending : prefix + ending
            verses.append(newEnding)

            return verses
        }

        private static func extractChineseNumberPrefix(_ text: String) -> String {
            let chineseDigits = "一二三四五六七八九十"
            var prefix = ""
            for char in text {
                if chineseDigits.contains(char) {
                    prefix.append(char)
                } else if char == "、" && !prefix.isEmpty {
                    prefix.append(char)
                    return prefix
                } else {
                    break
                }
            }
            return prefix
        }
    }
    
    // MARK: - 聖母慶節專用對經
    struct BVMFeastAntiphon {
        static let text = "馬利亞，※你光輝顯赫，是王室的苗裔；我們應當以全靈全魂的虔誠，請求她的代禱。"
        
        /// 聖母慶節完整名稱列表（與一時禱、三時禱共用標準）
        static let feastNames: [String] = [
            "加羅默爾聖母",
            "聖母聖名日",
            "七苦聖母",
            "贖虜聖母",
            "聖母玫瑰",
            "沃爾辛厄姆聖母",
            "建立聖母雪地大殿",
            "露德聖母"
        ]
        
        /// 判斷是否為聖母慶節
        static func isBVMFeast(title: String) -> Bool {
            feastNames.contains { title.contains($0) }
        }
    }

    // MARK: - 詩篇對經（按季節）
    struct PsalmAntiphon {
        let season: String
        let text: String
    }

    static let psalmAntiphons: [PsalmAntiphon] = [
        .init(season: "全年通用", text: "住在天上的主阿＊"),
        .init(season: "降臨期", text: "看哪，萬國所羨慕的必來到＊"),
        .init(season: "聖誕期", text: "看哪，馬利亞為我們誕生了救主＊"),
        .init(season: "大齋期", text: "當以恆久的忍耐＊"),
        .init(season: "復活期", text: "哈利路亞，哈利路亞＊")
    ]

    // MARK: - 詩篇鍵名（由 PsalmsLoader 動態載入）
    /// 禮拜日：三篇全唸；平日按星期輪替
    static func psalmKeys(for date: Date) -> [String] {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: // 主日 → 全部三篇
            return ["詩篇 第123篇", "詩篇 第124篇", "詩篇 第125篇"]
        case 2, 5: // 禮拜一、禮拜四 → 123
            return ["詩篇 第123篇"]
        case 3, 6: // 禮拜二、禮拜五 → 124
            return ["詩篇 第124篇"]
        case 4, 7: // 禮拜三、禮拜六 → 125
            return ["詩篇 第125篇"]
        default:
            return ["詩篇 第123篇"]
        }
    }

    /// 顯示用標題（繁體，無「第」字，與禮儀書一致）
    static func psalmDisplayTitle(for key: String) -> String {
        return key
            .replacingOccurrences(of: "詩篇 第", with: "詩篇 ")
            .replacingOccurrences(of: "篇", with: "篇")
    }

    // MARK: - 讀經（由 sext_readings.json 載入）
    struct SextReadingItem: Codable {
        let season: String
        let content: String
        let reference: String
    }

    struct SextReadingsLoader {
        static let shared = SextReadingsLoader()
        private let items: [SextReadingItem]

        init() {
            if let url = Bundle.main.url(forResource: "sexta_readings", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([SextReadingItem].self, from: data) {
                items = decoded
            } else {
                items = [
                    .init(season: "全年平日", content: "但凡事要察驗：美善的事要持守，各樣惡事要禁戒。", reference: "帖撒羅尼迦前書 5:21-22"),
                    .init(season: "主日與慶節", content: "在天上作見證的有三：就是父，與道，與聖靈。這三乃是一。", reference: "約翰一書 5:7"),
                    .init(season: "復活節期", content: "勝過世界的是誰呢？不就是那信耶穌是上帝兒子的嗎？這藉着水和血而來的，就是耶穌基督。", reference: "約翰一書 5:5-6")
                ]
            }
        }

        func item(for season: String) -> SextReadingItem? {
            items.first { $0.season == season }
        }
    }

    // MARK: - 簡短啟應
    struct ShortResponsorySet {
        let title: String
        let responses: [Responsory]
    }

    // 全年平日
    static let shortResponsesOrdinary = ShortResponsorySet(
        title: "全年平日",
        responses: [
            Responsory(leader: "啟：我要時常讚美主。", people: "應：我要時常讚美主。"),
            Responsory(leader: "啟：頌美祂的話，", people: "應：常在我口裏。"),
            Responsory(leader: "啟：但願榮耀，歸於聖父、聖子、聖靈；", people: "應：我要時常讚美主。"),
            Responsory(leader: "啟：看哪，上帝是幫助我的，", people: "應：主保護我的性命。")
        ]
    )

    // 主日、瞻禮日、復活期 — 復活期內（含哈利路亞）
    static let shortResponsesFeastEaster = ShortResponsorySet(
        title: "主日、瞻禮日、復活期",
        responses: [
            Responsory(leader: "啟：主阿，祢的言語，堅立在天。哈利路亞，哈利路亞。", people: "應：主阿，祢的言語，堅立在天。哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：祢的信實，永世無窮。哈利路亞，哈利路亞。", people: "應：堅立在天上。哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：但願榮耀，歸於聖父、聖子、聖靈；", people: "應：主阿，祢的言語，堅立在天。哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：主是我的牧人，叫我不至貧窮。哈利路亞。", people: "應：祂叫我睡在青草地上。哈利路亞。")
        ]
    )

    // 主日、瞻禮日、復活期 — 復活期外（隱藏哈利路亞）
    static let shortResponsesFeastOrdinary = ShortResponsorySet(
        title: "主日、瞻禮日、復活期",
        responses: [
            Responsory(leader: "啟：主阿，祢的言語，堅立在天。", people: "應：主阿，祢的言語，堅立在天。"),
            Responsory(leader: "啟：祢的信實，永世無窮。", people: "應：堅立在天上。"),
            Responsory(leader: "啟：但願榮耀，歸於聖父、聖子、聖靈；", people: "應：主阿，祢的言語，堅立在天。"),
            Responsory(leader: "啟：主是我的牧人，叫我不至貧窮。", people: "應：祂叫我睡在青草地上。")
        ]
    )

    // MARK: - 祈禱（平日用）
    static let prayersSection = PrayerSection(
        title: "祈禱",
        rubric: "¶ 眾跪，在復活節期外所有的平日誦唸以下祈禱。在主日、瞻禮日以及八日慶期中省略。若省略，則直接唸祝文。",
        paragraphs: [
            "求主憐憫；\n求基督憐憫；\n求主憐憫。",
            "我們在天上的父，願人都尊父的名為聖。願父的國降臨。願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人。"
        ],
        responses: []
    )

    static let prayersResponses: [Responsory] = [
        Responsory(leader: "啟：保佑我們不遇試探，", people: "應：拯救我們脫離兇惡。"),
        Responsory(leader: "啟：莫掩面不看僕人，因為我遭了急難，", people: "應：求祢快快應允我的祈求。"),
        Responsory(leader: "啟：求祢快來救贖我的性命，", people: "應：上帝阿，求祢救我脫離仇敵。"),
        Responsory(leader: "啟：基督阿，求祢起來幫助我們。", people: "應：為祢的聖名拯救我們。")
    ]

    // MARK: - 祝文前啟應
    static let collectOpening: [Responsory] = [
        Responsory(leader: "啟：願主與你們同在。", people: "應：願主與你的心靈同在。")
    ]

    // MARK: - 結束啟應
    static let collectEndingResponses: [Responsory] = [
        Responsory(leader: "啟：願主與你們同在。", people: "應：願主與你的心靈同在。"),
        Responsory(leader: "啟：我們要讚美主。", people: "應：感謝上帝。"),
        Responsory(leader: "啟：願一切離世信徒的靈魂，都靠著上帝的慈悲，得享安息。", people: "應：阿們。")
    ]

    // MARK: - 六時禱固定紀念祝文
    static let sextMemorialCollect = PrayerSection(
        title: nil,
        rubric: "¶ 誦唸本日祝文，然後誦唸以下紀念祝文。",
        paragraphs: [
            "主耶穌，祢當年被掛在十字木架上，伸出祢慈愛的膀臂：求祢因祢慈悲的心懷，叫世上萬民都能仰望祢而得蒙拯救。求祢以聖靈充滿我們，使我們也能伸出雙手，以愛為他人工作，領那些不認識祢的人進入祢的愛與真理之中。主和聖父、聖靈，惟一上帝，一同永生，一同掌權，永世無盡。阿們。"
        ],
        responses: []
    )

    // MARK: - 結束經文
    static let closingText = PrayerSection(
        title: nil,
        rubric: nil,
        paragraphs: [
            "願尊貴、榮耀歸給永世的君王，那不朽壞、看不見、獨一的上帝，直到永永遠遠。阿們！（提摩太前書 1:17）"
        ],
        responses: []
    )
}

// MARK: - 讀經版本選擇
enum SextReadingOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日與慶節"
    case easter = "復活節期"
}

// MARK: - 簡短啟應版本選擇
enum SextShortResponseOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日、瞻禮日、復活期"
}

// MARK: - 祈禱顯示選擇
enum SextPrayerOption: String, CaseIterable, Hashable {
    case show = "顯示"
    case omit = "省略"
}
