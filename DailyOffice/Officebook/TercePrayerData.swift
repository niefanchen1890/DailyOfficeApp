import Foundation

// MARK: - 三時禱資料模型
struct TercePrayerData {

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
            "一、懇求聖靈自天來至，\n聖靈與父與子為一。\n施恩據守我等靈魂，\n以全聖德充滿吾心。",
            "二、所思所想所言所行，\n願全盡力榮耀主名。\n願愛如火滿照我心，\n推廣其熱激發他人。",
            "三、至聖上帝三位一體，\n聖父聖靈與子合一。\n上帝至上永遠為君，\n我等所禱懇求應允。阿們。"
        ],
        responses: []
    )
    
    // MARK: - 聖靈降臨日專用聖詩（Veni, Creator Spiritus）
    static let pentecostHymn = PrayerSection(
        title: "聖詩",
        rubric: nil,
        paragraphs: [
            "一、懇求造主聖靈降臨，\n俯允安居我眾靈魂；\n沛降聖寵屬天扶佑，\n充滿祢所受造之心。",
            "二、吾等尊呼保惠聖靈，\n至高上帝特殊洪恩；\n祢乃活泉神火聖愛，\n亦為自天屬靈恩膏。",
            "三、奧妙七恩皆祢所賜，\n上帝之手威嚴指頭；\n祢乃聖父信實應許，\n賜我唇舌宣講之能。",
            "四、懇求真光點燃感官，\n更以聖愛激發我心；\n我等凡軀積弱不堪，\n求以不朽大能堅固。",
            "五、驅逐屬靈仇敵遠遁，\n惠賜常存安穩太平；\n賴祢前引作我嚮導，\n免受一切凶險災禍。",
            "六、藉祢使我認識聖父，\n藉祢使我深知聖子；\n祢乃父子共發之靈，\n世世代代咸同信認。",
            "七、讚美歸於上帝聖父，\n亦歸聖子以及聖靈；\n懇求基督我等之主，\n傾注聖靈無盡恩賜。阿們。"
        ],
        responses: []
    )

    // MARK: - 節期聖詩結尾（通用模組，與一時禱共用邏輯）
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

            // ✅ 先提取被替換的最後一段的段號，再移除
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
        static let text = "真福童貞女聖馬利亞：※你既獲母親的尊榮，又未損貞女的純潔。"
        
        /// 聖母慶節完整名稱列表（與一時禱共用標準）
        /// 當 liturgy.mainTitle 包含以下任一完整名稱時，即視為聖母慶節
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
        .init(season: "全年通用", text: "我呼求，＊"),
        .init(season: "降臨期", text: "看哪，主帶著能力和榮耀，＊"),
        .init(season: "聖誕期", text: "孕婦生了名叫「永恆」的君王，＊"),
        .init(season: "大齋期", text: "懺悔之日臨近我們，＊"),
        .init(season: "復活期", text: "哈利路亞，哈利路亞，＊")
    ]

    // MARK: - 詩篇鍵名（由 PsalmsLoader 動態載入）
    /// 禮拜日：三篇全唸；平日按星期輪替
    /// 注意：鍵名必須與 psalms.json 中的鍵名完全一致（簡體「詩篇 第XX篇」）
    static func psalmKeys(for date: Date) -> [String] {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: // 主日 → 全部三篇
            return ["詩篇 第120篇", "詩篇 第121篇", "詩篇 第122篇"]
        case 2, 5: // 禮拜一、禮拜四 → 120
            return ["詩篇 第120篇"]
        case 3, 6: // 禮拜二、禮拜五 → 121
            return ["詩篇 第121篇"]
        case 4, 7: // 禮拜三、禮拜六 → 122
            return ["詩篇 第122篇"]
        default:
            return ["詩篇 第120篇"]
        }
    }

    /// 顯示用標題（繁體，無「第」字，與禮儀書一致）
    static func psalmDisplayTitle(for key: String) -> String {
        return key
            .replacingOccurrences(of: "詩篇 第", with: "詩篇 ")
            .replacingOccurrences(of: "篇", with: "篇")
    }

    // MARK: - 讀經（由 terce_readings.json 載入）
    struct TerceReadingItem: Codable {
        let season: String
        let content: String
        let reference: String
    }

    struct TerceReadingsLoader {
        static let shared = TerceReadingsLoader()
        private let items: [TerceReadingItem]

        init() {
            if let url = Bundle.main.url(forResource: "terce_readings", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([TerceReadingItem].self, from: data) {
                items = decoded
            } else {
                items = [
                    .init(season: "全年平日", content: "主啊，求你醫治我，我就痊癒，拯救我，我便得救；因你是我所讚美的。", reference: "耶利米書 17:14"),
                    .init(season: "主日與瞻禮日", content: "深哉，上帝的豐富、智慧和知識！他的判斷何其難測！他的蹤跡何其難尋！", reference: "羅馬書 11:33"),
                    .init(season: "復活節期", content: "因為凡從上帝生的就勝過世界；使我們勝過世界的就是我們的信心。", reference: "約翰一書 5:4")
                ]
            }
        }

        func item(for season: String) -> TerceReadingItem? {
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
            Responsory(leader: "啟：我雖得罪祢，仍求祢醫救我命。", people: "應：我雖得罪祢，仍求祢醫救我命。"),
            Responsory(leader: "啟：我說，主阿，求祢憐憫我，", people: "應：我雖得罪祢。"),
            Responsory(leader: "啟：但願榮耀，歸於聖父、聖子、聖靈；", people: "應：我雖得罪祢，仍求祢醫救我命。"),
            Responsory(leader: "啟：祢從前幫助我，", people: "應：莫丟棄我，求救我的上帝莫撇開我。")
        ]
    )

    // 主日、瞻禮日、復活期 — 復活期內（含哈利路亞）
    static let shortResponsesFeastEaster = ShortResponsorySet(
        title: "主日、瞻禮日、復活期",
        responses: [
            Responsory(leader: "啟：上帝阿，叫我心向祢的法度。哈利路亞，哈利路亞。", people: "應：上帝阿，叫我心向祢的法度。哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：叫我的眼睛不看虛假，哈利路亞，哈利路亞。", people: "應：叫我心向祢的法度。哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：但願榮耀，歸於聖父、聖子、聖靈；", people: "應：上帝阿，叫我心向祢的法度。哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：祢從前幫助我，哈利路亞。", people: "應：莫丟棄我，求救我的上帝莫撇開我。哈利路亞。")
        ]
    )

    // 主日、瞻禮日、復活期 — 復活期外（隱藏哈利路亞）
    static let shortResponsesFeastOrdinary = ShortResponsorySet(
        title: "主日、瞻禮日、復活期",
        responses: [
            Responsory(leader: "啟：上帝阿，叫我心向祢的法度。", people: "應：上帝阿，叫我心向祢的法度。"),
            Responsory(leader: "啟：叫我的眼睛不看虛假。", people: "應：叫我心向祢的法度。"),
            Responsory(leader: "啟：但願榮耀，歸於聖父、聖子、聖靈；", people: "應：上帝阿，叫我心向祢的法度。"),
            Responsory(leader: "啟：祢從前幫助我。", people: "應：莫丟棄我，求救我的上帝莫撇開我。")
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
        Responsory(leader: "啟：求祢叫我存活，我必讚美主，", people: "應：求祢照祢的公義拯救我。"),
        Responsory(leader: "啟：我迷失道途，如同亡羊，", people: "應：求祢尋回僕人，因為我不忘記祢的命令。"),
        Responsory(leader: "啟：我要滿口讚美主。", people: "應：我要終日頌揚主的榮耀。"),
        Responsory(leader: "啟：求主掩面莫看我的罪孽。", people: "應：願主塗抹我的一切過犯。"),
        Responsory(leader: "啟：求主為我造清潔的心。", people: "應：願主為我作一正直的新誌。"),
        Responsory(leader: "啟：求主莫趕逐我離開主的面前。", people: "應：願主莫從我收回主的聖靈。"),
        Responsory(leader: "啟：求主還是拯救，叫我歡喜。", people: "應：願主以主樂意的靈扶持我。"),
        Responsory(leader: "啟：求主拯救我，脫離兇惡人，", people: "應：保護我，脫離強暴人。"),
        Responsory(leader: "啟：上帝啊，求主救我脫離仇敵，", people: "應：護庇我，叫我得脫離攻我的敵人。"),
        Responsory(leader: "啟：解救我脫離作惡的人，", people: "應：拯救我脫離殘忍的人。"),
        Responsory(leader: "啟：我必常常歌頌祢的名，", people: "應：日日還我的願。"),
        Responsory(leader: "啟：救我們的上帝啊，應允我們，", people: "應：地極海角極遠的人，都仰靠主。"),
        Responsory(leader: "啟：上帝阿，快來拯救我。", people: "應：主阿，趕緊幫助我。"),
        Responsory(leader: "啟：聖哉，上帝；聖哉，大能者；聖哉，永生者。", people: "應：上帝的羔羊，除掉世上罪的主，憐憫我們。"),
        Responsory(leader: "啟：我的心靈，當讚美主，", people: "應：我的臟腑，當讚美主的聖名。"),
        Responsory(leader: "啟：我的心靈，當頌美主，", people: "應：莫忘主的一切恩惠。"),
        Responsory(leader: "啟：祂赦免你一切罪愆，", people: "應：醫治你一切疾病。"),
        Responsory(leader: "啟：救贖你的性命，免掉在坑裏，", people: "應：用恩寵慈悲像冠冕，戴在你的頭上。"),
        Responsory(leader: "啟：使你的口吃飽美食，", people: "應：叫你像鷹返老還童。"),
        Responsory(leader: "啟：你們當稱頌主，因為祂至善，", people: "應：主的恩典，永遠長存。")
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

    // MARK: - 三時禱結束經文
    static let closingText = PrayerSection(
        title: nil,
        rubric: nil,
        paragraphs: [
            "他愛我們，用自己的血使我們從罪中得釋放，又使我們成為國度，作他父上帝的祭司。願榮耀、權能歸給他，直到永永遠遠。阿們！（啟示錄 1:4-6）"
        ],
        responses: []
    )
}

// MARK: - 讀經版本選擇
enum TerceReadingOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日與瞻禮日"
    case easter = "復活節期"
}

// MARK: - 簡短啟應版本選擇
enum TerceShortResponseOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日、瞻禮日、復活期"
}

// MARK: - 祈禱顯示選擇
enum TercePrayerOption: String, CaseIterable, Hashable {
    case show = "顯示"
    case omit = "省略"
}
