import Foundation

// MARK: - 寢前禱資料模型
struct ComplinePrayerData {

    // MARK: 開始啟應
    static let openingResponses: [Responsory] = [
        Responsory(leader: "啟：主，請降福。", people: "應：求全能的主，使我們平安渡過黑夜不遇危險。阿們。")
    ]

    // MARK: 簡短讀經
    static let shortReading = PrayerSection(
        title: "簡短讀經",
        rubric: nil,
        paragraphs: [
            "弟兄們：務要謹守，警醒。因為你們的仇敵魔鬼，如同吼叫的獅子，遍地遊行，尋找可吞吃的人。你們要用堅固的信心抵擋他。"
        ],
        responses: []
    )

    // MARK: 讀經後啟應
    static let readingResponses: [Responsory] = [
        Responsory(leader: "啟：創造天地的主，", people: "應：我們倚靠主的聖名，必蒙拯救。")
    ]

    // MARK: 主禱文前啟應
    static let lordPrayerResponses: [Responsory] = [
        Responsory(leader: "啟：保佑我們不遇試探，", people: "應：拯救我們脫離兇惡。"),
        Responsory(leader: "啟：上帝我們的救主阿，求主復興我們，", people: "應：不再向我們發怒。"),
        Responsory(leader: "啟：上帝阿，快來拯救我們。", people: "應：主阿，趕緊幫助我們。"),
        Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：起初怎樣，現在以及永遠也是怎樣，世世無盡。阿們。"),
        Responsory(leader: "啟：你們應當讚美主。", people: "應：主的名應當讚美。")
    ]

    // MARK: - 詩篇對經（前／後）
    struct PsalmAntiphon {
        let season: String
        let before: String
        let after: String
    }

    static let psalmAntiphons: [PsalmAntiphon] = [
        .init(season: "全年通用",
              before: "求主憐憫我＊",
              after: "求主憐憫我，俯聽我的禱告。"),
        .init(season: "降臨期",
              before: "我們應正直敬虔的生活＊",
              after: "我們應正直敬虔的生活，盼望福樂的應許，等候主的降臨。"),
        .init(season: "聖誕期",
              before: "哦，基督，祢已經顯現＊",
              after: "哦，基督，祢已經顯現，從光的光。哈利路亞，哈利路亞，哈利路亞。"),
        .init(season: "大齋期",
              before: "哦，永恆的救主，求祢垂顧我們＊",
              after: "哦，永恆的救主，求祢垂顧我們，懇求祢成為我們永遠的幫助者，助我們脫免狡詐者的試探引誘。"),
        .init(season: "復活期",
              before: "哈利路亞，哈利路亞＊",
              after: "哈利路亞，哈利路亞，哈利路亞，哈利路亞。")
    ]

    // MARK: - 詩篇鍵名（固定四篇）
    static let psalmKeys = ["詩篇 第4篇", "詩篇 第31篇", "詩篇 第91篇", "詩篇 第134篇"]

    /// 顯示用標題（繁體）
    static func psalmDisplayTitle(for key: String) -> String {
        return key.replacingOccurrences(of: "詩篇 第", with: "詩篇 ")
    }

    /// 拉丁文與副標題（對照禮儀書）
    static func psalmLatinSubtitle(for key: String) -> String {
        switch key {
        case "詩篇 第4篇":   return "Cum invocarem（求助的晚禱）"
        case "詩篇 第31篇":  return "In te, Domine, speravi（信靠上帝的祈禱）"
        case "詩篇 第91篇":  return "Qui habitat（上帝是我們的保護者）"
        case "詩篇 第134篇": return "Ecce nunc（宣召稱頌）"
        default:            return ""
        }
    }

    // MARK: - 經課
    static let lesson = PrayerSection(
        title: "經課",
        rubric: "¶ 聖經讀畢，會眾誦唸：",
        paragraphs: [
            "主啊，你在我們中間，我們是稱為你名下的人，求你不要離開我們。（耶利米書 14:9）"
        ],
        responses: [
            Responsory(leader: "", people: "應：感謝上帝。")
        ]
    )

    // MARK: - 簡短啟應
    struct ShortResponsorySet {
        let title: String
        let responses: [Responsory]
        let showGloria: Bool   // 苦難期隱藏榮耀頌
    }

    // 復活節期外
    static let shortResponsesOrdinary = ShortResponsorySet(
        title: "復活節期外",
        responses: [
            Responsory(leader: "啟：主阿，我將我的靈魂交在你手裡。", people: "應：主阿，我將我的靈魂交在你手裡。"),
            Responsory(leader: "啟：主阿，誠實的上帝阿，祢必救贖我。", people: "應：我將我的靈魂交在你手裡。"),
            Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：起初怎樣，現在以及永遠也是怎樣，世世無盡。阿們。"),
            Responsory(leader: "啟：祢從前幫助我。", people: "應：莫丟棄我，求救我的上帝莫撇開我。")
        ],
        showGloria: true
    )

    // 復活期
    static let shortResponsesEaster = ShortResponsorySet(
        title: "復活期",
        responses: [
            Responsory(leader: "啟：主阿，我將我的靈魂交在你手裡。哈利路亞，哈利路亞。", people: "應：主阿，我將我的靈魂交在你手裡。哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：主阿，誠實的上帝阿，祢必救贖我。", people: "應：哈利路亞，哈利路亞。"),
            Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：主阿，我將我的靈魂交在你手裡。哈利路亞，哈利路亞。")
        ],
        showGloria: true
    )

    // MARK: 聖詩    
    // 平日
    static let weekdayHymn = PrayerSection(
        title: "聖詩",
        rubric: "¶ 此聖詩用於大齋期與復活期外的所有平日。",
        paragraphs: [
            "一、又是一天轉瞬過去，\n我衆敬求創造大主，\n仍舊賜給我衆恩賜，\n夜間陪伴我衆同居。",
            "二、懇求驅除任何惡夢，\n消滅夜間諸般驚恐，\n逐去損害靈魂之敵，\n且使罪惡不染心中。",
            "三、懇求天父允我所求，\n靠主耶穌獨生愛子，\n他同天父和保惠師，\n萬古永存萬年永治。阿們。"
        ],
        responses: []
    )

    // 慶節（大齋期與復活期外的禮拜六、禮拜日、慶節、八日慶期）
    static let feastHymn = PrayerSection(
        title: "聖詩",
        rubric: "¶ 此聖詩用於大齋期和復活期外的禮拜六、禮拜日和慶節，包含八日慶期。",
        paragraphs: [
            "一、救世之主我們祈求，\n謝主護我安度白晝，\n夜幕降臨求主庇護，\n全能之主永遠拯救。",
            "二、慈悲之主懇求同在，\n求祢寬恕僕人哀求，\n洗滌罪過悅納祈禱，\n照亮黑暗脫離憂愁。",
            "三、莫讓靈魂沈睡受傷，\n莫讓撒但惡意傷害，\n護衛身心常保貞潔，\n成為聖殿獻於主前。",
            "四、更新我們靈魂的主，\n吾等謙卑真摯祈求，\n惟願靈魂純潔無垢，\n睡醒之後安然起身。",
            "五、讚美聖父創造之恩，\n讚美聖子救世之恩，\n讚美聖靈保惠之恩，\n虔誠拜禱永世無盡。阿們。"
        ],
        responses: []
    )

    // 大齋期（含苦難期）
    static let lentHymn = PrayerSection(
        title: "聖詩",
        rubric: "¶ 此聖詩用於大齋期與苦難期，包括主日、平日、慶節。",
        paragraphs: [
            "一、基督祢是光明白晝，\n驅散夜晚深沈幽暗，\n光中之光我們明認，\n基督榮光已經顯明。",
            "二、至聖主前我們叩首，\n護佑僕人安度此夜，\n恩賜我們安然休息，\n平安無虞穩度良宵。",
            "三、莫讓昏睡壓制靈魂，\n莫容仇敵佔據內心，\n莫從撒但詭計誘惑，\n免使我們主前不潔。",
            "四、求讓雙眸適度安睡，\n求醒心靈向主警醒，\n願主右手施恩保護，\n愛主信主忠信子民。",
            "五、求主為我堅固保障，\n願主制服仇敵狂妄，\n引導保守主的子民，\n主血所贖引導向善。",
            "六、親愛之主求你記念，\n我眾生靈困於塵世，\n只有主能護我靈魂，\n求主同在直到終末。",
            "七、讚美聖父創造之恩，\n讚美聖子救世之恩，\n讚美聖靈保惠之恩，\n虔誠拜禱永世無盡。阿們。"
        ],
        responses: []
    )

    // 復活節期（完整六段）
    static let easterHymn = PrayerSection(
        title: "聖詩",
        rubric: "¶ 復活節期唸：",
        paragraphs: [
            "一、耶穌神聖救贖源泉，\n我心愛慕全然盼望，\n上帝創造開天闢地，\n時候滿足道成肉身。",
            "二、祢的大愛何等奇妙，\n甘願擔負我們憂患，\n忍受十架痛苦死亡，\n絕望之中我們被贖。",
            "三、地獄之門被祢打開，\n被囚奴僕為祢釋放，\n祢已高坐天父右邊，\n彰顯勝利威嚴尊榮。",
            "四、願祢憐憫饒恕我們，\n征服一切疾病痛苦，\n應允我們所有祈求，\n以祢榮面滿足我們。",
            "五、萬物造主我們祈求，\n在此復活喜樂慶節，\n護庇祢的選民羊群，\n脫離死亡陰霾威脅。",
            "六、死而復活的創造主，\n我們獻上一切尊榮，\n永歸聖父聖子聖靈，\n直到永遠永無窮盡。阿們。"
        ],
        responses: []
    )

    // 升天節期（完整六段）
    static let ascensionHymn = PrayerSection(
        title: "聖詩",
        rubric: "¶ 升天節期唸：",
        paragraphs: [
            "一、耶穌神聖救贖源泉，\n我心愛慕全然盼望，\n上帝創造開天闢地，\n時候滿足道成肉身。",
            "二、祢的大愛何等奇妙，\n甘願擔負我們憂患，\n忍受十架痛苦死亡，\n絕望之中我們被贖。",
            "三、地獄之門被祢打開，\n被囚奴僕為祢釋放，\n祢已高坐天父右邊，\n彰顯勝利威嚴尊榮。",
            "四、願祢憐憫饒恕我們，\n征服一切疾病痛苦，\n應允我們所有祈求，\n以祢榮面滿足我們。",
            "五、願主為我今生喜樂，\n成為我等偉大賞賜，\n我心我靈唯一誇耀，\n永遠得蒙恩主接納。",
            "六、升到群星之上的主，\n我們獻上榮耀讚揚，\n永歸聖父聖子聖靈，\n永永遠遠永無窮盡。阿們。"
        ],
        responses: []
    )

    // 聖靈降臨節期（完整六段）
    static let pentecostHymn = PrayerSection(
        title: "聖詩",
        rubric: "¶ 聖靈降臨節期唸：",
        paragraphs: [
            "一、耶穌神聖救贖源泉，\n我心愛慕全然盼望，\n上帝創造開天闢地，\n時候滿足道成肉身。",
            "二、祢的大愛何等奇妙，\n甘願擔負我們憂患，\n忍受十架痛苦死亡，\n絕望之中我們被贖。",
            "三、地獄之門被祢打開，\n被囚奴僕為祢釋放，\n祢已高坐天父右邊，\n彰顯勝利威嚴尊榮。",
            "四、願祢憐憫饒恕我們，\n征服一切疾病痛苦，\n應允我們所有祈求，\n以祢榮面滿足我們。",
            "五、祢在每個聖潔心靈，\n常駐恩典永不離開，\n今日我眾祈求赦免，\n求主賜與我們平安。",
            "六、讚美歸於聖父聖子，\n同樣歸於保惠之師，\n聖子澆灌聖靈恩賜，\n直到永遠永無窮盡。阿們。"
        ],
        responses: []
    )
    
    // MARK: - 聖靈降臨日、後一日、後二日專用繼抒詠
    static let almaChorusHymn = PrayerSection(
        title: "聖詩",
        rubric: "¶ 聖靈降臨日、聖靈降臨後一日、聖靈降臨後二日的寢前禱，用以下繼抒詠代替原本聖詩：",
        paragraphs: [
            "今我眾人，齊聲頌唱，\n循序稱揚，主之尊名：\n君王救主，是彌賽亞，\n以馬內利，萬軍之主。",
            "與父同體，道路生命，\n上帝之手，獨生聖子；\n智慧大能，太初元始，\n一切受造，首生之子。",
            "稱阿拉法，與俄梅戛，\n既為元首，亦為終結；\n萬善之泉，萬福之源，\n代求之主，我等中保。",
            "牛犢羔羊，綿羊公羊，\n微蟲銅蛇，威武雄獅；\n上帝之口，主之聖言，\n真光旭日，榮輝真像。",
            "聖花靈糧，真葡萄樹，\n羊門磐石，聖山角石；\n教會使者，教會新郎，\n善牧先知，大祭司長。",
            "大能不朽，至高無上，\n全能上帝，救主耶穌；\n懇求主恩，拯救我等，\n榮耀歸主，萬世無盡。阿們。"
        ],
        responses: []
    )
    
    // MARK: - 聖詩後啟應（復活節期外）
    static let postHymnResponsesOrdinary: [Responsory] = [
        Responsory(leader: "啟：求主保護我如同眼中的瞳人。", people: "應：將我隱藏在你翅膀的蔭下。")
    ]

    // MARK: - 聖詩後啟應（復活期）
    static let postHymnResponsesEaster: [Responsory] = [
        Responsory(leader: "啟：求主保護我如同眼中的瞳人。哈利路亞。", people: "應：將我隱藏在你翅膀的蔭下。哈利路亞。")
    ]

    // MARK: - 西面頌默認對經
    static let defaultNuncDimittisAntiphon = "主啊，醒時求你引導，睡時求你保護；這樣，我們醒時可以與基督一同守候，睡時可以在平安里歇息。"

    // MARK: - 祈禱
    static let prayersSection = PrayerSection(
        title: "祈禱",
        rubric: "¶ 眾跪，在復活節期外所有的平日唸以下祈禱。在主日、慶節以及八日慶期中省略。若省略，則直接唸祝文。",
        paragraphs: [
            "求主憐憫；\n求基督憐憫；\n求主憐憫。",
            "我們在天上的父，願人都尊父的名為聖。願父的國降臨。願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人。"
        ],
        responses: []
    )

    static let prayersResponses: [Responsory] = [
        Responsory(leader: "啟：保佑我們不遇試探，", people: "應：拯救我們脫離兇惡。"),
        Responsory(leader: "啟：我得安逸去睡，", people: "應：安然居住。"),
        Responsory(leader: "啟：我信身體復活，", people: "應：我信永生。阿們。"),
        Responsory(leader: "啟：主，我祖的上主，是當讚美的；", people: "應：稱頌主，尊主在萬有之上，永世無盡。"),
        Responsory(leader: "啟：我們都當讚美聖父、聖子、聖靈；", people: "應：頌揚主，尊主為大，永世無盡。"),
        Responsory(leader: "啟：主在穹蒼之上，是當讚美的；", people: "應：稱頌主，尊主在萬有之上，永世無盡。"),
        Responsory(leader: "啟：願全能慈悲的主，聖父、聖子、聖靈，賜福我們，保護我們。", people: "應：阿們。")
    ]

    // MARK: - 認罪文（寢前禱專用簡式）
    static let confession = PrayerSection(
        title: "認罪文",
        rubric: "¶ 低聲誦唸認罪文：",
        paragraphs: [
            "我向上帝，榮福馬利亞、所有聖人，（和你或弟兄們）承認我在思想、言語和行為上重重犯了罪；因我的過犯，我懇求榮福馬利亞、所有聖人，為我們祈禱。",
            "求全能的上帝憐憫我們，寬恕我們一切所犯的罪，拯救我們脫離一切兇惡，賜我們行善的力量，叫我們得永生。阿們。"
        ],
        responses: []
    )
    
    static let confessionNote = "¶ 認罪可由主禮與會眾交替進行。"

    static let absolutionClergy = PrayerSection(
        title: "赦罪文",
        rubric: "¶ 若主禮人是會長，則加唸以下內容：",
        paragraphs: [
            "願全能仁慈的主寬恕、赦免、除去我們所有的罪，並賜予我們真正悔改的時間，生活的改善，及聖靈的恩惠與安慰。阿們。"
        ],
        responses: []
    )
    
    // MARK: - 赦罪文後啟應
    static let postAbsolutionResponses: [Responsory] = [
        Responsory(leader: "啟：求主回來，叫我們再活，", people: "應：願主的百姓因主喜悅。"),
        Responsory(leader: "啟：求主向我們發慈悲，", people: "應：願主施恩拯救我們。"),
        Responsory(leader: "啟：求主保佑我們，", people: "應：今夜不犯罪。"),
        Responsory(leader: "啟：願主憐憫我們，", people: "應：憐憫我們。"),
        Responsory(leader: "啟：求主施憐憫於我們，", people: "應：因為我們倚靠主。"),
        Responsory(leader: "啟：主阿，我呼籲，求祢聽我聲音，", people: "應：求祢憐恤我，應允我。")
    ]

    // MARK: - 祝文選項
    struct CollectOption {
        let id: String
        let title: String
        let text: String
    }

    static let collectOptions: [CollectOption] = [
        .init(id: "protection",
              title: "求護祝文",
              text: "主阿，我們懇求祢，臨格此間，驅散仇敵所設的一切陷阱，遣派祢的聖天使居在此處，保護我們，使我們獲得平安；更求主的祝福永遠降臨我們身上；這都是靠著你的聖子，我們的主耶穌基督，聖子和聖父、聖靈，一同永生，一同掌權，惟一上帝，永無窮盡。阿們。"),
        .init(id: "ambrose",
              title: "聖安波羅修祝文",
              text: "無所不能的聖父，我們懇求祢，以祢永恆的光輝照亮今夜的黑暗；求祢使我們無罪安眠，在天使的能力之中甦醒，好讓我們藉著祢的幫助，健康平安地迎接白晝的光明。這都是靠著我主耶穌基督。阿們。"),
        .init(id: "hope",
              title: "希望祝文",
              text: "主耶穌基督，永生上帝之子，昔日夜中，主在墓中安息，而使墓為聖，為主百姓盼望的床鋪。主曾為贖我們的罪受苦，也求主使我們懊悔自己這罪，叫我們的肉體安息在塵土里的時候，靈魂能與主同住。主耶穌與聖父、聖靈，一同掌權，惟一上帝，世世無盡。阿們。")
    ]

    // MARK: - 紀念聖母與諸聖
    static let commemorationSection = PrayerSection(
        title: "紀念聖母與諸聖",
        rubric: "¶ 此時誦唸「紀念聖母與諸聖」。在主日、慶節以及復活期外要跪唸。",
        paragraphs: [
            "上帝，永恆的主阿，我們讚美尊崇祢的聖名，感謝祢賜予我們上帝之母，終身童貞榮福馬利亞、諸聖使徒、殉道者、精修者、童貞女，以及所有祢的聖徒和選民。我們懇求祢，使我們因與他們相交而歡欣的人，藉著他們的代禱，得以在祢天國里與他們同享永恆的福樂。這都是靠著我們的主基督。阿們。"
        ],
        responses: []
    )

    // 祝文前的啟應（義人的靈魂）
    static let commemorationResponsesBefore: [Responsory] = [
        Responsory(leader: "啟：義人的靈魂阿，請為我們祈求主。", people: "應：使我們堪受基督的恩許。")
    ]

    // 祝文後的啟應（助佑 + 安息）
    static let commemorationResponsesAfter: [Responsory] = [
        Responsory(leader: "啟：願上帝的助佑常與我們同在。", people: "應：阿們。"),
        Responsory(leader: "啟：願所有已經去世信友的靈魂，因上帝的恩慈，得享安息。", people: "應：阿們。")
    ]
    
    // MARK: - 祝文前啟應
    static let preCollectResponses: [Responsory] = [
        Responsory(leader: "啟：主阿，求祢起來幫助我們；", people: "應：為祢的聖名拯救我們。"),
        Responsory(leader: "啟：萬軍的上帝啊，求祢復興我們，", people: "應：叫祢面上的光輝普照，我們就可得救。"),
        Responsory(leader: "啟：願主與你們同在。", people: "應：願主與你的心靈同在。")
    ]
    
    // MARK: - 祝文後啟應
    static let postCollectResponses: [Responsory] = [
        Responsory(leader: "啟：願主與你們同在。", people: "應：願主與你的心靈同在。"),
        Responsory(leader: "啟：我們要讚美主。", people: "應：感謝上帝。")
    ]
}

// MARK: - 祝文選擇
enum ComplineCollectOption: String, CaseIterable, Hashable {
    case protection = "求護祝文"
    case ambrose = "聖安波羅修祝文"
    case hope = "希望祝文"
}

// MARK: - 聖詩類型（供選擇器使用）
enum ComplineHymnType: String, CaseIterable, Hashable {
    case weekday = "平日"
    case feast = "慶節"
    case lent = "大齋期"
    case easter = "復活期"
}

// MARK: - 簡短啟應選擇
enum ComplineShortResponseOption: String, CaseIterable, Hashable {
    case ordinary = "復活節期外"
    case easter = "復活期"
}


// MARK: - 祈禱顯示選擇
enum ComplinePrayerOption: String, CaseIterable, Hashable {
    case show = "顯示"
    case omit = "省略"
}
