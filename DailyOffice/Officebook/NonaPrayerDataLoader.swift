import Foundation

// MARK: - 九時禱資料模型
struct NonaPrayerData {

    // MARK: 禮規說明
    static let openingNote = "¶ 九時禱於午後三時左右舉行，為六時禱之後、晚禱之前的小時祈禱。"

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
            "一、上帝全能全力之王，\n雖雲至逸無勞無苦。\n仍管眾時循序而行，\n從早發光直至日終。",
            "二、求以光照我生殘軀，\n一生不被黑暗捆拘。\n直到我等平安身亡，\n直到我得永遠榮耀。",
            "三、至聖上帝三位一體，\n聖父聖靈與子合一。\n上帝至上永遠為君，\n我等所禱懇求應允。阿們。"
        ],
        responses: []
    )

    // MARK: - 節期聖詩結尾（通用模組，與一時禱/三時禱/六時禱共用邏輯）
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
        static let text = "上帝聖母，※榮福童貞女馬利亞，當享尊榮。"
        
        /// 聖母慶節完整名稱列表（與各時辰共用標準）
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
        .init(season: "全年通用", text: "敬畏主的人＊"),
        .init(season: "降臨期", text: "你全能的道＊"),
        .init(season: "聖誕期", text: "摩西看見的焚而不毀的荊棘叢＊"),
        .init(season: "大齋期", text: "當以上帝公義的能力為盔甲＊"),
        .init(season: "復活期", text: "哈利路亞，哈利路亞＊")
    ]

    // MARK: - 詩篇鍵名（由 PsalmsLoader 動態載入）
    /// 禮拜日：三篇全唸；平日按星期輪替
    static func psalmKeys(for date: Date) -> [String] {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: // 主日 → 全部三篇
            return ["詩篇 第126篇", "詩篇 第127篇", "詩篇 第128篇"]
        case 2, 5: // 禮拜一、禮拜四 → 126
            return ["詩篇 第126篇"]
        case 3, 6: // 禮拜二、禮拜五 → 127
            return ["詩篇 第127篇"]
        case 4, 7: // 禮拜三、禮拜六 → 128
            return ["詩篇 第128篇"]
        default:
            return ["詩篇 第126篇"]
        }
    }

    /// 顯示用標題（繁體，無「第」字，與禮儀書一致）
    static func psalmDisplayTitle(for key: String) -> String {
        return key
            .replacingOccurrences(of: "詩篇 第", with: "詩篇 ")
            .replacingOccurrences(of: "篇", with: "篇")
    }

    // MARK: - 讀經（由 nona_readings.json 載入）
    struct NonaReadingItem: Codable {
        let season: String
        let content: String
        let reference: String
    }

    struct NonaReadingsLoader {
        static let shared = NonaReadingsLoader()
        private let items: [NonaReadingItem]

        init() {
            if let url = Bundle.main.url(forResource: "nona_readings", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([NonaReadingItem].self, from: data) {
                items = decoded
            } else {
                items = [
                    .init(season: "全年平日", content: "你們各人的重擔要互相擔當，這樣就會成全基督的律法。", reference: "加拉太書 6:2"),
                    .init(season: "主日與慶節", content: "一主，一信，一洗，一上帝－就是萬人之父，超越萬有之上，貫通萬有，在萬有之中。", reference: "以弗所書 4:5-6"),
                    .init(season: "復活節期", content: "在地上作見證的有三：就是聖靈、水與血。這三乃是一。", reference: "約翰一書 5:8")
                ]
            }
        }

        func item(for season: String) -> NonaReadingItem? {
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
            Responsory(leader: "啟：主阿，求祢拯救我，求祢憐恤我。", people: "應：主阿，求祢拯救我，求祢憐恤我。"),
            Responsory(leader: "啟：我的腳登平坦地，在會眾中，我要讚美主。", people: "應：求你憐恤我。"),
            Responsory(leader: "啟：但願榮耀，歸於聖父、聖子、聖靈；", people: "應：主阿，求祢拯救我，求祢憐恤我。"),
            Responsory(leader: "啟：主阿，我要讚揚祢的名，", people: "應：祢從一切患難中拯救我。")
        ]
    )

    // 主日、瞻禮日、復活期 — 復活期內（含哈利路亞）
    static let shortResponsesFeastEaster = ShortResponsorySet(
        title: "主日、瞻禮日、復活期",
        responses: [
            Responsory(leader: "啟：我一心呼籲，求主應允。哈利路亞，哈利路亞。", people: "應：我一心呼籲，求主應允。哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：我遵守祢的典章，哈利路亞，哈利路亞。", people: "應：求主應允。哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：但願榮耀，歸於聖父、聖子、聖靈；", people: "應：我一心呼籲，求主應允。哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：主阿，願祢赦免我暗中的過失。哈利路亞。", people: "應：我不容祢的僕人故意犯罪。哈利路亞。")
        ]
    )

    // 主日、瞻禮日、復活期 — 復活期外（隱藏哈利路亞）
    static let shortResponsesFeastOrdinary = ShortResponsorySet(
        title: "主日、瞻禮日、復活期",
        responses: [
            Responsory(leader: "啟：我一心呼籲，求主應允。", people: "應：我一心呼籲，求主應允。"),
            Responsory(leader: "啟：我遵守祢的典章，", people: "應：求主應允。"),
            Responsory(leader: "啟：但願榮耀，歸於聖父、聖子、聖靈；", people: "應：我一心呼籲，求主應允。"),
            Responsory(leader: "啟：主阿，願祢赦免我暗中的過失。", people: "應：我不容祢的僕人故意犯罪。")
        ]
    )

    // MARK: - 祈禱（平日用）
    static let prayersSection = PrayerSection(
        title: "祈禱",
        rubric: "¶ 眾跪，在復活節期外所有的平日誦唸以下祈禱。在主日、慶節以及特等、一等、二等八日慶期中省略。若省略，則直接唸祝文。",
        paragraphs: [
            "求主憐憫；\n求基督憐憫；\n求主憐憫。",
            "我們在天上的父，願人都尊父的名為聖。願父的國降臨。願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人。"
        ],
        responses: []
    )

    static let prayersResponses: [Responsory] = [
        Responsory(leader: "啟：保佑我們不遇試探，", people: "應：拯救我們脫離兇惡。"),
        Responsory(leader: "啟：我年紀老邁的時候，求祢莫丟棄我，", people: "應：我的氣力衰弱，求祢莫離開我。"),
        Responsory(leader: "啟：求主莫掩面不顧我，", people: "應：恐怕我像已經進了墳墓的人。"),
        Responsory(leader: "啟：主阿，求祢為祢的名，叫我甦醒，", people: "應：照祢的公義，叫我脫離苦難。")
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

    // MARK: - 九時禱固定紀念祝文
    static let nonaMemorialCollect = PrayerSection(
        title: nil,
        rubric: "¶ 誦唸本日祝文，然後誦唸以下紀念祝文。",
        paragraphs: [
            "主耶穌基督啊，祢為我們的緣故走過死亡之路；求祢向我們指明生命之道；正如你在死亡時被列在罪犯之中，在埋葬時與財主同葬，願我們這些死在罪惡過犯中的人，因祢得以復活，並被帶入真福之地。主和聖父、聖靈，惟一上帝，一同永生，一同掌權，永世無盡。阿們。"
        ],
        responses: []
    )

    // MARK: - 結束經文
    static let closingText = PrayerSection(
        title: nil,
        rubric: nil,
        paragraphs: [
            "願那能保守你們不失腳，使你們無瑕無疵、歡歡喜喜站在他榮耀之前的、我們的救主獨一的上帝，藉着我們的主耶穌基督，得享榮耀、威嚴、能力、權柄，從萬古以前，到現今，直到永永遠遠。阿們！（猶大書 24-25）"
        ],
        responses: []
    )
}

// MARK: - 讀經版本選擇
enum NonaReadingOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日與慶節"
    case easter = "復活節期"
}

// MARK: - 簡短啟應版本選擇
enum NonaShortResponseOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日、瞻禮日、復活期"
}

// MARK: - 祈禱顯示選擇
enum NonaPrayerOption: String, CaseIterable, Hashable {
    case show = "顯示"
    case omit = "省略"
}
