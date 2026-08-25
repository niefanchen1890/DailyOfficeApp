import Foundation

// MARK: - 一時禱資料模型
struct PrimePrayerData {
    
    // MARK: 禮規說明
    static let openingNote = "¶ 可於早禱前後適當時間舉行，但不可替代早禱。"
    
    // MARK: 開始啟應
    static let openingResponses: [Responsory] = [
        Responsory(leader: "啟：上帝阿，快來拯救我們。", people: "應：主阿，趕緊幫助我們。"),
        Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：起初這樣，現在這樣，將來也這樣，永無窮盡。阿們。"),
        Responsory(leader: "啟：你們應當讚美主。", people: "應：主的名應當讚美。")
    ]
    
    // MARK: 聖詩
    static let hymn = PrayerSection(
        title: "聖詩",
        rubric: nil,
        paragraphs: [
            "一、紅日東升滿天光明，\n我眾向主奉獻虔心，\n求主使我所言所行，\n能夠脫離罪惡憂驚。",
            "二、求使我口脫離爭競，\n求使我心常守和平；\n懇求使我耳清目明，\n不被世間利慾迷昏。",
            "三、使我內心清潔真誠，\n使我思想能免愚蠢，\n使我日常節衣縮食，\n藉能克服肉體驕淫。",
            "四、待我既完一天工作，\n重新遇到黑暗黃昏；\n求使穩渡試探路程，\n能將榮耀歸我真神。",
            "五、讚美聖父創造之恩；\n讚美聖子救世之恩；\n讚美聖靈保惠之恩；\n虔誠拜禱永世無盡。阿們。"
        ],
        responses: []
    )
    
    // MARK: - 聖母慶節專用對經
    struct BVMFeastAntiphon {
        static let text = "我們理當以至誠敬禮※此至聖童貞女，實屬應當且合理；因她無與倫比的貞潔，為我們孕育了生命之果。"
        
        /// 聖母慶節完整名稱列表
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
        .init(season: "全年通用", text: "哈利路亞。＊"),
        .init(season: "降臨期", text: "看哪，時候已經滿足，＊"),
        .init(season: "聖誕期", text: "牧人！你們看見了誰？＊"),
        .init(season: "大齋期", text: "敬畏主的當說，＊"),
        .init(season: "復活期", text: "哈利路亞，哈利路亞，＊")
    ]
    
    // MARK: - 詩篇鍵名（由 PsalmsLoader 動態載入）
    static let psalm54Key = "詩篇 第54篇"
    
    // MARK: - 詩篇119篇分段鍵名（按8節一組）
    static let psalm119Group1 = ["詩篇 第119篇（1-8）", "詩篇 第119篇（9-16）"]     // 第一部分 1-16節
    static let psalm119Group2 = ["詩篇 第119篇（17-24）", "詩篇 第119篇（25-32）"]   // 第二部分 17-32節
    static let psalm119Group3 = ["詩篇 第119篇（33-40）", "詩篇 第119篇（41-48）"]   // 第三部分 33-48節

    /// 根據日期取得當日詩篇119篇分段鍵名組
    static func psalm119Keys(for date: Date) -> [String] {
        let weekday = Calendar.current.component(.weekday, from: date)
        switch weekday {
        case 1: // 主日 → 全部六段（1-48節）
            return psalm119Group1 + psalm119Group2 + psalm119Group3
        case 2, 5: // 禮拜一、禮拜四 → 第一部分（1-16節）
            return psalm119Group1
        case 3, 6: // 禮拜二、禮拜五 → 第二部分（17-32節）
            return psalm119Group2
        case 4, 7: // 禮拜三、禮拜六 → 第三部分（33-48節）
            return psalm119Group3
        default:
            return psalm119Group1
        }
    }
    
    
    // MARK: - 讀經（由 prime_readings.json 載入）
    struct PrimeReadingItem: Codable {
        let season: String
        let content: String
        let reference: String
    }

    struct PrimeReadingsLoader {
        static let shared = PrimeReadingsLoader()
        private let items: [PrimeReadingItem]
        
        init() {
            if let url = Bundle.main.url(forResource: "prime_readings", withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([PrimeReadingItem].self, from: data) {
                items = decoded
            } else {
                // 後備：JSON 遺失時不崩潰，使用內建資料
                items = [
                    .init(season: "全年平日", content: "萬軍之主如此說：你們要喜愛誠實與和平。", reference: "撒迦利亞書 8:19"),
                    .init(season: "主日與瞻禮日", content: "願尊貴、榮耀歸給永世的君王，那不朽壞、看不見、獨一的上帝，直到永永遠遠。阿們！", reference: "提摩太前書 1:17"),
                    .init(season: "復活節期", content: "主啊，求你施恩給我們，我們等候你。求你每早晨作我們的膀臂，遭難時作我們的拯救。", reference: "以賽亞書 33:2")
                ]
            }
        }
        
        func item(for season: String) -> PrimeReadingItem? {
            items.first { $0.season == season }
        }
    }
    
    // MARK: - 簡短啟應
    struct ShortResponsorySet {
        let title: String
        let opening: Responsory
        let seasonal: Responsory
        let common: [Responsory]
    }
    
    // 復活節期外
    static let shortResponsesOutsideEaster: [ShortResponsorySet] = [
        .init(
            title: "三一節期、大齋預備期、大齋期",
            opening: Responsory(leader: "啟：耶穌基督，永生上帝之子，求祢憐憫我們。", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。"),
            seasonal: Responsory(leader: "啟：坐在上帝聖父右邊的主，", people: "應：求憐憫我們。"),
            common: [
                Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。"),
                Responsory(leader: "啟：基督阿，求祢起來幫助我們。", people: "應：為祢的聖名拯救我們。")
            ]
        ),
        .init(
            title: "降臨節",
            opening: Responsory(leader: "啟：耶穌基督，永生上帝之子，求祢憐憫我們。", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。"),
            seasonal: Responsory(leader: "啟：必再降臨世界的主，", people: "應：求憐憫我們。"),
            common: [
                Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。"),
                Responsory(leader: "啟：基督阿，求祢起來幫助我們。", people: "應：為祢的聖名拯救我們。")
            ]
        ),
        .init(
            title: "聖誕期",
            opening: Responsory(leader: "啟：耶穌基督，永生上帝之子，求祢憐憫我們。", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。"),
            seasonal: Responsory(leader: "啟：甘願由童貞女所生的主，", people: "應：求憐憫我們。"),
            common: [
                Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。"),
                Responsory(leader: "啟：基督阿，求祢起來幫助我們。", people: "應：為祢的聖名拯救我們。")
            ]
        ),
        .init(
            title: "顯現期",
            opening: Responsory(leader: "啟：耶穌基督，永生上帝之子，求祢憐憫我們。", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。"),
            seasonal: Responsory(leader: "啟：就在此刻顯現塵寰的主，", people: "應：求憐憫我們。"),
            common: [
                Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。"),
                Responsory(leader: "啟：基督阿，求祢起來幫助我們。", people: "應：為祢的聖名拯救我們。")
            ]
        )
    ]
    
    // 復活節期內
    static let shortResponsesInsideEaster: [ShortResponsorySet] = [
        .init(
            title: "復活期",
            opening: Responsory(leader: "啟：耶穌基督，永生上帝之子，求祢憐憫我們。哈利路亞，哈利路亞。", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。哈利路亞，哈利路亞。"),
            seasonal: Responsory(leader: "啟：主已從死裏復活。", people: "應：哈利路亞，哈利路亞。"),
            common: [
                Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。哈利路亞，哈利路亞。"),
                Responsory(leader: "啟：基督阿，求祢起來幫助我們。哈利路亞。", people: "應：為祢的聖名拯救我們。哈利路亞。")
            ]
        ),
        .init(
            title: "升天期",
            opening: Responsory(leader: "啟：耶穌基督，永生上帝之子，求祢憐憫我們。哈利路亞，哈利路亞。", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。哈利路亞，哈利路亞。"),
            seasonal: Responsory(leader: "啟：主已上升到群星之上。", people: "應：哈利路亞，哈利路亞。"),
            common: [
                Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。哈利路亞，哈利路亞。"),
                Responsory(leader: "啟：基督阿，求祢起來幫助我們。哈利路亞。", people: "應：為祢的聖名拯救我們。哈利路亞。")
            ]
        ),
        .init(
            title: "聖靈降臨期",
            opening: Responsory(leader: "啟：耶穌基督，永生上帝之子，求祢憐憫我們。哈利路亞，哈利路亞。", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。哈利路亞，哈利路亞。"),
            seasonal: Responsory(leader: "啟：主已差遣聖靈降臨在門徒的身上，", people: "應：哈利路亞，哈利路亞。"),
            common: [
                Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：耶穌基督，永生上帝之子，求祢憐憫我們。哈利路亞，哈利路亞。"),
                Responsory(leader: "啟：基督阿，求祢起來幫助我們。哈利路亞。", people: "應：為祢的聖名拯救我們。哈利路亞。")
            ]
        )
    ]
    
    // MARK: - 祈禱（平日用）
    static let prayersOpening = PrayerSection(
        title: "祈禱",
        rubric: "¶ 眾跪，在復活節期外所有的平日唸以下祈禱。在主日、慶節以及八日慶期中省略。若省略，則直接唸祝文。",
        paragraphs: [
            "求主憐憫；\n求基督憐憫；\n求主憐憫。",
            "我們在天上的父，願人都尊父的名為聖。願父的國降臨。願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人。"
        ],
        responses: []
    )
    
    static let prayersResponses1: [Responsory] = [
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
    
    // MARK: 認罪文
    static let confession = PrayerSection(
        title: nil,
        rubric: "¶ 低聲唸認罪文",
        paragraphs: [
            "我向上帝，榮福馬利亞、所有聖人，（和你或弟兄們）承認我在思想、言語和行為上重重犯了罪；因我的過犯，我懇求榮福馬利亞、所有聖人，為我們祈禱。",
            "求全能的上帝憐憫我們，寬恕我們一切所犯的罪，拯救我們脫離一切兇惡，賜我們行善的力量，叫我們得永生。阿們。"
        ],
        responses: []
    )
    
    static let confessionNote = "¶ 認罪可由主禮與會眾交替進行。"
    
    // MARK: 赦罪文（會長）
    static let absolution = PrayerSection(
        title: nil,
        rubric: "¶ 若主禮人是會長，則加唸以下內容：",
        paragraphs: [
            "願全能仁慈的主寬恕、赦免、除去我們所有的罪，並賜予我們真正悔改的時間，生活的改善，及聖靈的恩惠與安慰。阿們。"
        ],
        responses: []
    )
    
    static let prayersResponses2: [Responsory] = [
        Responsory(leader: "啟：求主回來，叫我們再活。", people: "應：願主的百姓因主喜悅。"),
        Responsory(leader: "啟：求主向我們發慈悲。", people: "應：願主施恩拯救我們。"),
        Responsory(leader: "啟：求主保佑我們，", people: "應：今天不犯罪。"),
        Responsory(leader: "啟：願主憐憫我們，", people: "應：憐憫我們。"),
        Responsory(leader: "啟：求主施憐憫於我們，", people: "應：因為我們倚靠主。"),
        Responsory(leader: "啟：萬軍的上帝啊，求主復興我們，", people: "應：叫主面上的光輝普照，我們就可得救。")
    ]
    
    // MARK: - 祝文
    static let collectOpening: [Responsory] = [
        Responsory(leader: "啟：願主與你們同在。", people: "應：願主與你的心靈同在。")
    ]
    
    static let collect1 = PrayerSection(
        title: nil,
        rubric: "我們要禱告。",
        paragraphs: [
            "求主在此日此時，以主的憐憫充滿我們；使我們整日歡欣踴躍，因讚美主而喜悅。這都是靠著我們的主耶穌基督；聖子和聖父、聖靈，惟一上帝，一同永生，一同掌權，永世無盡。阿們。"
        ],
        responses: []
    )
    
    static let collect2 = PrayerSection(
        title: nil,
        rubric: "¶ 或",
        paragraphs: [
            "主耶穌基督，永生上帝之子，在一天的第一時被帶到本丟·彼拉多面前；主原是審判萬人的主，卻遭受了最嚴厲的刑罰；我們懇求主，在終末時刻，在主的審判台前，求主憐憫我們罪人。主耶穌和聖父、聖靈，惟一上帝，一同永生，一同掌權，永世無盡。阿們。"
        ],
        responses: []
    )
    
    static let collectEndingResponses: [Responsory] = [
        Responsory(leader: "啟：願主與你們同在。", people: "應：願主與你的心靈同在。"),
        Responsory(leader: "啟：我們要讚美主。", people: "應：感謝上帝。")
    ]
    
    static let closingText = PrayerSection(
        title: nil,
        rubric: nil,
        paragraphs: [
            "願主賜福給我們，保護我們脫離一切兇惡，使我們得永生。又願衆信徒的靈魂，在上帝的憐憫裏面安息。阿們。",
            "上帝能照着運行在我們心裏的大能充充足足地成就一切，超過我們所求所想的。願他在教會中，並在基督耶穌裏，得着榮耀，直到世世代代，永永遠遠。阿們！（以弗所書 3:20-21）"
        ],
        responses: []
    )
    
    // MARK: - 殉道錄（可選）
    static let martyrology = PrayerSection(
        title: "殉道錄",
        rubric: "¶ 以下「紀念殉道者和聖人們」的內容並非一時禱的一部分。但，可在一時禱結束後誦唸。若在誦唸之前誦讀「殉道錄」更是合宜的。",
        paragraphs: [
            "願我們上帝之母聖馬利亞，我主耶穌基督的母親，以及所有聖潔、公義、蒙揀選的上帝子民，為我們罪人向上帝、我們的主祈求，使我們獲得上帝的幫助和拯救；聖子和聖父、聖靈，三位一體的主，一同永生，一同掌權，惟一上帝，永世無盡。阿們。"
        ],
        responses: [
            Responsory(leader: "啟：在其他地方，還有許多其他神聖的殉道者、精修者及童貞女。", people: "應：感謝上帝。"),
            Responsory(leader: "啟：敬主的虔誠人死亡。", people: "應：在主的眼睛中最為珍貴。")
        ]
    )
    
    static let martyrologyClosing: [Responsory] = [
        Responsory(leader: "啟：上帝阿，快來拯救我們。", people: "應：主阿，趕緊幫助我們。"),
        Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：起初這樣，現在這樣，將來也這樣，永無窮盡。阿們。")
    ]
    
    // MARK: - 殉道錄結束
    static let martyrologyKyrie = "求主憐憫；\n求基督憐憫；\n求主憐憫。"
    
    static let martyrologyLordPrayerNote = "¶ 唸「我們在天上的父」，後默唸主禱文："
    
    static let martyrologyLordPrayerText = "我們在天上的父，願人都尊父的名為聖。願父的國降臨。願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人。"
    
    static let martyrologyEndingResponses: [Responsory] = [
        Responsory(leader: "啟：保佑我們不遇試探，", people: "應：拯救我們脫離兇惡。"),
        Responsory(leader: "啟：主阿，惟願主的恩惠，臨到我的身上，", people: "應：求主照主的言語，拯救我。"),
        Responsory(leader: "啟：惟願主的僕人，得見祢的作為，", people: "應：他們的子孫，得見主的榮耀。"),
        Responsory(leader: "啟：惟願主我們上帝的恩典臨到我們，", people: "應：我們手裏所做的，願主為我們堅固，我們的手所做的，願主堅固。")
    ]
    
    static let martyrologyCollect = "伏求無所不能的主，無始無終的上帝，引導我們，使我們成聖，又治理我們，使我們的身心都能謹守主的律法，遵行主的誡命，得蒙主全能的護衛，從今以後，身體靈魂，都得保全。聖子和聖父、聖靈，三位一體的主，一同永生，一同掌權，惟一上帝，永世無盡。阿們。"
    
    static let martyrologyFinalResponse = Responsory(
        leader: "啟：願上帝的助佑常與我們同在。",
        people: "應：阿們。"
    )
    
    // MARK: - 紀念亡者（可選）
    static let commemorationOpening = Responsory(
        leader: "啟：讓我們紀念已逝的親屬、鄰舍、友人和恩人們。",
        people: "應：願他們息止安所。阿們。"
    )
    
    static let commemorationResponses: [Responsory] = [
        Responsory(leader: "啟：求主賜他們永恆的安息。", people: "應：並以永遠的光照耀他們。"),
        Responsory(leader: "啟：自地獄之門，", people: "應：求主拯救他們的靈魂。"),
        Responsory(leader: "啟：我確信在生命的地方，", people: "應：得見主恩。"),
        Responsory(leader: "啟：求主俯聽我們的禱告。", people: "應：願我們的呼聲達到主前。"),
        Responsory(leader: "啟：願主與你們同在。", people: "應：願主與你的心靈同在。")
    ]
    
    static let commemorationPrayer = PrayerSection(
        title: nil,
        rubric: "我們要禱告。",
        paragraphs: [
            "上帝的本性就是憐憫，喜歡赦免：求主眷顧我們已逝的親屬、鄰舍、友人和恩人們；求主賜他們在榮耀之中復活，加入光明眾聖徒榮耀的團契。這都是靠著我們的主耶穌基督。阿們。"
        ],
        responses: []
    )
    
    static let commemorationClosing: [Responsory] = [
        Responsory(leader: "啟：願他們的靈魂和一切離世信徒的靈魂，都靠著上帝的慈悲，得享安息。", people: "應：阿們。"),
        Responsory(leader: "啟：求主賜與他們安息，", people: "應：求主賜與我們永生。阿們。")
    ]
    // MARK: - 節期聖詩結尾（通用模組）
    struct SeasonalHymnEnding {
        static let endings: [String: String] = [
            "christmas_to_purification": "童女所生救主耶穌，\n常受一切讚美榮光。\n榮耀亦歸聖父聖靈，同受尊崇萬世無疆。阿們。",
            "epiphany_octave": "一切榮耀歸於恩主，\n為祢今日榮耀顯現；\n歸於聖父及與聖靈，稱頌讚美永世無盡。阿們。",
            "eastertide": "吾等獻上一切榮耀，\n歸於死而復生之主；\n及父與保惠師聖靈，\n稱頌讚美永世無盡。阿們。",
            "ascensiontide": "我眾今獻所有榮耀，\n歸於超越眾星之主，\n及父與保惠師聖靈，\n稱頌讚美永世無盡。阿們。",
            "sacred_heart": "榮耀皆歸我主基督，\n自主聖心傾注恩寵；\n偕同聖父永恆同在，\n以及聖靈永世無盡。阿們。",
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
            if title.contains("基督易容") || title.contains("易容顯光")  || title.contains("基督易容顯光日") {
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
        
        /// 組裝完整聖詩：無節期結尾時保留通用第五段；有節期結尾時替換最後一段
        static func assemble(baseVerses: [String], for date: Date, liturgy: DailyLiturgy) -> [String] {
            guard let key = endingKey(for: date, liturgy: liturgy),
                  let ending = endings[key],
                  !baseVerses.isEmpty else {
                // 無特殊節期：完整保留原詩（含通用結尾段）
                return baseVerses
            }
            
            var verses = baseVerses
            
            // ✅ 提取最後一段的中文段號（如「五、」「三、」「七、」）
            let lastVerse = verses.last!
            let prefix = extractChineseNumberPrefix(lastVerse)
            
            verses.removeLast()
            
            // ✅ 將段號加到新結尾前；若無段號則直接 append
            let newEnding = prefix.isEmpty ? ending : prefix + ending
            verses.append(newEnding)
            
            return verses
        }
        
        // MARK: - 輔助：提取中文數字段號
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
}


// MARK: - 亞他拿修信經（供一時禱、早禱共用）
extension PrimePrayerData {
    static let athanasianCreed = PrayerSection(
        title: "聖亞他那修信經",
        rubric: "¶ 救主聖誕日、顯現日、聖馬提亞日、復活日、升天日、聖靈降臨日、施洗聖約翰日、聖雅各日、聖巴多羅買日、聖馬太日、聖西門與聖猶大日、聖安德烈日以及聖三一主日，主禮與會眾站立，或誦唸或吟唱我們基督信仰告白，即通稱「聖亞他那修信經」，取代「使徒信經」。注意，在瞻禮的八日慶期均不誦唸此信經。",
        paragraphs: [
            "凡欲得救者，首先須當持守屬公會之道。",
            "此道，凡守之不全，守之不純者，必致永遠沈淪。",
            "屬公會之道，載下，我等敬拜獨一上帝為三位，又敬拜三位為一上帝。",
            "其位不紊，其體不分。",
            "蓋聖父一位，聖子一位，聖靈亦一位。",
            "然聖父之為上帝，聖子之為上帝，聖靈之為上帝，其性為一，榮光同等，威嚴同是永遠。",
            "聖父如是，聖子如是，聖靈亦如是。",
            "聖父非受造，聖子非受造，聖靈亦非受造。",
            "聖父無限量，聖子無限量，聖靈亦無限量。",
            "聖父無始終，聖子無始終，聖靈亦無始終。",
            "非三無始終，乃一無始終。",
            "亦非三不受造，非三無限量，乃一非受造，一無限量。",
            "聖父全能，聖子全能，聖靈亦全能。",
            "非三全能，乃一全能。",
            "聖父是上帝，聖子是上帝，聖靈亦是上帝。",
            "非三上帝，乃一上帝。",
            "聖父是主，聖子是主，聖靈亦是主。",
            "非三主，乃一主。",
            "依屬主基督教之實情，我等不得不認三位各自為上帝，各自為主。",
            "如是，依屬公會之道，我等不得謂上帝有三，亦不得謂主有三。",
            "聖父無所由成，非受造，亦非生。",
            "聖子獨由聖父，非受成，非受造，乃由聖父而生。",
            "聖靈由聖父與聖子，非受成，非受造，亦非生，乃由出。",
            "如是，有一聖父，非三聖父，有一聖子，非三聖子，有一聖靈，非三聖靈。",
            "此三位一體之中，無先後，無尊卑之別。",
            "乃三位皆互相永遠同在，並同等。",
            "如是，由上所論，一上帝為三位，三位為一上帝，乃當敬拜。",
            "凡欲得救者，當如是，顧三位一體之上帝。",
            "再者，凡欲得永救，又必須依正道，信吾主耶穌基督成為人身。",
            "依此正道，我等信認吾主耶穌基督，上帝之子是上帝亦是人。",
            "其為上帝，以其由聖父之體生於萬物之先，其為人，以其由母之體生於世間。",
            "其真為上帝，亦真為人，靈心與肉軀全備。",
            "論其上帝之性，與聖父同等，論其人之性，則次於聖父。",
            "其為上帝亦為人，然不可稱為二，惟一基督。",
            "其為一，非上帝之性變為肉身，乃上帝取人性而成一位。",
            "其真為一，非在體之相紊，乃在位之為一。",
            "蓋靈心與肉身相合為一人，上帝與人相合為一基督，亦若是。",
            "其為救我等而受難，降於陰間，第三日從死復活。",
            "升天，坐於上帝全能聖父之右，後必自彼處降臨，審判活人死人。",
            "降臨之時，萬人必以身體復活，並且陳明本身所行之事。",
            "行善者必入永生，行惡者必入永火。",
            "此乃屬公會之道，凡不依正道篤信者，必不能得救。",
            "但願榮耀歸於聖父、聖子、聖靈，",
            "起初怎樣，現在以及永遠也是怎樣，世世無盡。阿們。"
        ],
        responses: []
    )
    
    static func shouldShowAthanasianCreed(for date: Date) -> Bool {
        let info = LiturgyCoreService.shared.getSeasonInfo(for: date)
        // let season = info.season
        let daysToEaster = info.daysFromEaster
        let weekday = info.weekday
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        // 固定聖日（月日匹配）
        let fixedFeasts: [(Int, Int)] = [
            (12, 25), // 救主聖誕日
            (1, 6),   // 顯現日
            (2, 24),  // 聖馬提亞日
            (6, 24),  // 施洗聖約翰日
            (7, 25),  // 聖雅各日
            (8, 24),  // 聖巴多羅買日
            (9, 21),  // 聖馬太日
            (10, 28), // 聖西門與聖猶大日
            (11, 30), // 聖安德烈日
        ]
        if fixedFeasts.contains(where: { $0 == (month, day) }) {
            return true
        }
        
        // 移動節日
        if daysToEaster == 0 { return true }                   // 復活日
        if daysToEaster == 39 { return true }                  // 升天日
        if daysToEaster == 49 { return true }                  // 聖靈降臨日
        if daysToEaster == 56 && weekday == 1 { return true } // 聖三一主日
        
        return false
    }
}


// MARK: - 殉道錄載入器（martyrologyMMdd.json）
struct MartyrologyLoader {
    static let shared = MartyrologyLoader()
    
    /// 「使徒聖彼得與聖保羅望日」殉道錄宣告語句
    private let peterPaulVigilEntry = "圣彼得与圣保罗两位使徒望日。"
    
    /// 根據月日載入對應 JSON，如 martyrology0531.json
    func entries(for date: Date) -> [String] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let filename = String(format: "martyrology%02d%02d", month, day)
        
        var result: [String] = []
        if let url = Bundle.main.url(forResource: filename, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            result = decoded
        }
        
        // 🌟 「使徒聖彼得與聖保羅望日」宣告隨望日遷移而動態插入
        result = insertPeterPaulVigilIfNeeded(into: result, for: date)
        
        return result
    }
    
    /// 依核心望日遷移規則，將「使徒聖彼得與聖保羅望日」宣告插入正確日期的殉道錄。
    /// 望日原為 6 月 28 日；若 6 月 28 日適逢主日，依核心規則（普通望日落主日提前至禮拜六）
    /// 提前至 6 月 27 日，否則保留在 6 月 28 日。
    private func insertPeterPaulVigilIfNeeded(into entries: [String], for date: Date) -> [String] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        // 僅處理 6 月 27、28 日
        guard month == 6, (day == 27 || day == 28) else { return entries }
        
        let year = calendar.component(.year, from: date)
        guard let june28 = calendar.date(from: DateComponents(year: year, month: 6, day: 28, hour: 12)) else {
            return entries
        }
        
        // 6 月 28 日是否為主日（weekday == 1）
        let june28IsSunday = calendar.component(.weekday, from: june28) == 1
        
        // 望日宣告應出現的日子：遷移時為 27 日，否則為 28 日
        let vigilDay = june28IsSunday ? 27 : 28
        
        // 先移除任何既有宣告（避免重複），再於正確日子插入
        var result = entries.filter { $0 != peterPaulVigilEntry }
        
        if day == vigilDay {
            // 插入於日期標題（首行「今天是…」）之後
            let insertIndex = result.isEmpty ? 0 : 1
            result.insert(peterPaulVigilEntry, at: insertIndex)
        }
        
        return result
    }
    // MARK: - 年度歸檔輔助
    
    /// 取得指定年度所有有殉道錄資料的月份與日期（JSON 文件名為 martyrologyMMdd.json，不隨年份變化）
    func availableDatesByMonth(forYear year: Int) -> [(month: Int, monthName: String, days: [Int])] {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            return []
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        
        var monthDays: [Int: [Int]] = [:]
        
        for url in urls {
            let filename = url.lastPathComponent
            guard filename.hasPrefix("martyrology"), filename.hasSuffix(".json") else { continue }
            
            let digits = filename.dropFirst("martyrology".count).dropLast(".json".count)
            guard digits.count == 4,
                  let month = Int(digits.prefix(2)),
                  let day = Int(digits.suffix(2)) else {
                continue
            }
            monthDays[month, default: []].append(day)
        }
        
        return (1...12).compactMap { month in
            guard let days = monthDays[month], !days.isEmpty else { return nil }
            return (
                month: month,
                monthName: formatter.monthSymbols[month - 1],
                days: days.sorted()
            )
        }
    }
}


// MARK: - 讀經版本選擇
enum PrimeReadingOption: String, CaseIterable, Hashable {
    case ordinary = "全年平日"
    case feast = "主日與瞻禮日"
    case easter = "復活節期"
}


// MARK: - 祈禱顯示選擇
enum PrimePrayerOption: String, CaseIterable, Hashable {
    case show = "顯示"
    case omit = "省略"
}
