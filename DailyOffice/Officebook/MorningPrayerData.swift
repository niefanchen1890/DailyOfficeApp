import Foundation

// MARK: - 輔助結構
struct SeasonalBlock: Hashable {
    let title: String
    let rubric: String
    let content: String?
}

struct PrayerSection: Hashable {
    let title: String?
    let rubric: String?
    let paragraphs: [String]
    let responses: [Responsory]
}

struct Responsory: Hashable {
    let leader: String
    let people: String
}

struct ConfessionBlock: Hashable {
    let rubricBefore: String
    let version1: PrayerSection
}

// MARK: - 赦罪文資料結構
struct AbsolutionBlock: Hashable {
    let title: String
    let clergyRubric: String
    let clergyParagraphs: [String]
    let clergyAltRubric: String
    let clergyAltParagraphs: [String]
    let laypersonRubric: String
    let laypersonParagraphs: [String]
}

struct LessonBlock: Hashable {
    let title: String
    let rubric: String
    let responses: [Responsory]
}

// MARK: - JSON 資料結構
struct BibleSentenceJSON: Codable, Hashable {
    let text: String
    let reference: String
}

struct BibleSentencesContainer: Codable {
    let ordinary: [BibleSentenceJSON]
    let advent: [BibleSentenceJSON]
    let christmas: [BibleSentenceJSON]
    let epiphany: [BibleSentenceJSON]
    let lent: [BibleSentenceJSON]
    let holy_week: [BibleSentenceJSON]
    let easter: [BibleSentenceJSON]
    let ascension: [BibleSentenceJSON]
    let pentecost: [BibleSentenceJSON]
    let trinity: [BibleSentenceJSON]
    let thanksgiving: [BibleSentenceJSON]
}

// MARK: - 聖經選句載入器
struct BibleSentencesLoader {
    static let shared = BibleSentencesLoader(fileName: "bible_sentences")
    static let eveningShared = BibleSentencesLoader(fileName: "evening_bible_sentences")
    
    private let container: BibleSentencesContainer
    
    init(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(BibleSentencesContainer.self, from: data) else {
            fatalError("無法載入 \(fileName).json")
        }
        self.container = decoded
    }
    
    /// 根據節期與主日標題取得選句
    func sentences(for season: LiturgicalSeason, title: String) -> [BibleSentenceJSON] {
        // 優先判斷：五旬、六旬、七旬主日，以及三一主日後第一主日至降臨前主日 → 平日
        
        if title.contains("三一主日後禮拜一") || title.contains("三一主日後禮拜二") || title.contains("三一主日後禮拜三") {
            return container.trinity
        }
        
        if isOrdinarySunday(title: title) {
            return container.ordinary
        }
        
        // 苦難主日與棕樹主日兩週，使用聖周選句
        if title.contains("苦難主日") || title.contains("棕樹主日") {
            return container.holy_week
        }
        
        // 特定節期對應
        switch season {
        case .advent:    return container.advent
        case .christmas: return container.christmas
        case .epiphany:  return container.epiphany
        case .lent:      return container.lent
        case .holyWeek:  return container.holy_week
        case .easter:    return container.easter
        case .ascension: return container.ascension
        case .pentecost: return container.pentecost
        case .trinity:
            // 三一主日本身使用三一專用選句；三一主日後第一主日至降臨前主日（含主日、平日）使用平日選句
            if title.contains("三一主日") && !title.contains("三一主日後") {
                return container.trinity
            }
            return container.ordinary
        default:         return container.ordinary
        }
    }
    
    /// 判斷是否為應顯示平日選句的主日
    private func isOrdinarySunday(title: String) -> Bool {
        if title.contains("五旬主日") || title.contains("六旬主日") || title.contains("七旬主日") {
            return true
        }
        if title.contains("復活後第五主日") || title.contains("復活後第六主日") || title.contains("復活後第七主日") {
            return true
        }
        if title.contains("三一主日後") && !title.contains("三一主日") {
            return true
        }
        if title.contains("降臨前主日") {
            return true
        }
        return false
    }
}


// MARK: - 邀請選句與皆來頌輔助結構
struct InvitatorySundayText: Hashable {
    let range: String
    let text: String
}

struct InvitatoryData: Hashable {
    let generalRubric: String
    let weekdayTexts: [String]      // 禮拜一至六（0=禮拜一）
}

// MARK: - 邀請選句顯示模式
enum InvitatoryDisplayMode: Hashable {
    case fullTwice       // 完整兩遍
    case fullOnce        // 完整一遍
    case secondHalf      // 後半部分（從 ※ 開始）
    case secondHalfThenFull  // 後半部分，然後完整一遍
}

// MARK: - 皆來頌段落
struct VeniteStanza: Hashable {
    let antiphonMode: InvitatoryDisplayMode?   // ← 加問號，允許 nil
    let verses: [String]
}

struct VeniteEnding: Hashable {
    let title: String
    let note: String?
    let stanzas: [VeniteStanza]
}

struct VeniteData: Hashable {
    let title: String
    let stanzas: [VeniteStanza]      // 主體：開頭對經 + 三段詩節 + 結束式提示
    let ending1: VeniteEnding
    let ending2: VeniteEnding
}

enum StPatrickOption: String, CaseIterable, Hashable {
    case omit = "省略"
    case recite = "誦唸"
}


// MARK: - 其他禱文選項（求恩祝文後）
enum GeneralPrayerOption: String, CaseIterable, Hashable {
    case prayers = "祈禱"
    case litany = "總禱文"
    case omit = "省略"
}


// MARK: - 資料模型
struct MorningPrayerData {
    
    // MARK: 禮規與開始
    static let openingRubric = """
    ¶ 主禮開始每日早禱，需要誦唸以下一段或數段聖經選句。
    
    ¶ 除了齋戒日或齋期外，無論什麼日課，如果要續唸總禱文或施聖餐文之日，主禮可以由聖經選句開始，後直接讀主禱文。但，在之前要先唸：「願主與你們同在」。應：「願主與你的心靈同在」。主禮：「我們要禱告」。
    
    ¶ 又要注意，若省略了認罪文與解罪文時，主禮可在聖經選句後，直接由「求主幫助我們開口」啟應開始。省略了的主禱文，需要在「願主與你們同在」等啟應之後，而在其他啟應之前誦讀，或在總禱文之中按其指定的方式誦讀。
    """
    
    // MARK: 日課前祈禱（可選）
    static let preparatoryPrayers = PrayerSection(
        title: "日課前祈禱",
        rubric: "¶ 此經文並非必須誦唸，但在日課之前誦唸之，是值得嘉許的。",
        paragraphs: [
            "求主開啟我的口，以讚美主聖名；求主潔淨我的心靈，驅除一切無益的、邪惡的和不相宜的思想；求主光照我的理智，灼熱我的情感，好能適當地、專心地、虔誠地向主祈禱，並能在主的台前幸蒙垂聽。這都是靠著我主耶穌基督。阿們。",
            "全能的上帝阿，凡願意的，主就將恩惠和祈禱的精神澆灌他們；當我們親近主的時候，求主拯救我們脫離冷淡的心情，和游移的意念，使我們能專心熱情的以心靈和誠實敬拜主；這都是靠著我主耶穌基督。阿們。",
            "萬福馬利亞，你充滿聖寵，主與你同在，你在婦女中受讚頌，你的親子耶穌同受讚頌。上帝聖母馬利亞，求你現在和我們臨終時，為我們罪人祈求上帝。阿們。",
            "主阿，現在我要結合主在世時向上帝所獻讚頌的神聖意向，向主誦念這一日課。"
        ],
        responses: []
    )
    
    // MARK: 節期選句（占位）
    static let seasonalSentences = SeasonalBlock(
        title: "聖經選句",
        rubric: "¶ 主禮開始早禱，要讀一節或數節的「聖經選句」。",
        content: nil
    )
    
    // MARK: 勸眾文
    static let exhortation = PrayerSection(
        title: "勸眾文",
        rubric: "¶ 然後，主禮唸：",
        paragraphs: [
            "親愛的弟兄們，聖經上屢次勸我們承認一切罪惡，不可在全能主天父的面前隱瞞，應當存謙恭痛悔順從的心，承認罪惡，這樣，才可以靠主無窮的恩惠慈悲，得著赦免。我們本來應當常常在主面前虛心認罪，現在大家聚會，要感謝主的大恩典，頌揚主的榮耀，敬聽主的聖經，並求主賜我們身體靈魂不可少的恩典，這時候更應當認罪。所以我勸你們要存潔淨的心，用謙恭的聲音，到施天恩的寶座前，跟隨我說——",
            "我們應當在全能上帝的面前謙恭認罪。"
        ],
        responses: []
    )
    
    // MARK: 認罪文（兩式）
    static let confession = ConfessionBlock(
        rubricBefore: "¶ 眾人同跪，跟隨主禮同唸：",
        version1: PrayerSection(
            title: nil,
            rubric: nil,
            paragraphs: [
                "無所不能最慈悲的父，我們離開了聖道，走錯了道路，如同失群的羊一樣。我們常隨自己的意思，放縱自己的情慾，違犯了天父的聖法。當做的不做，不當做的反去做，性情軟弱，沒有力量行善。求主憐憫我們重罪的人，認罪的，求主憐憫，悔罪的，求主赦免，就應驗主托付我主耶穌基督應許世人的話。又求最慈悲的父，看在主耶穌的面上，叫我們從今以後，尊奉天父，公道待人，安分守己，就將榮耀歸於天父的聖名。阿們。"
            ],
            responses: []
        ),
    )
    
    // MARK: 赦罪文
    static let absolution = AbsolutionBlock(
        title: "赦罪文",
        clergyRubric: "¶ 會長站立誦唸赦罪文，會眾仍跪。",
        clergyParagraphs: [
            "無所不能的上帝，我主耶穌基督的父，不願罪人死，但願他離開罪惡，可以生活。又把權柄賜與所設立的聖品人員，並且吩咐他們曉諭主的百姓，如果悔罪改過，必蒙寬恕赦免。上帝必寬恕赦免一切真心悔罪，誠心信服聖福音的人。",
            "所以，我們須求上帝，賜真實悔改的心，又賜聖靈，叫我們現在所做的事，都合主的聖意，又叫我們終身清潔聖善，到了臨終的時候，就可以享永遠的安樂。這都是靠著我主耶穌基督。阿們。"
        ],
        clergyAltRubric: "¶ 會長若不誦唸上文，誦唸下文亦可。",
        clergyAltParagraphs: [
            "無所不能的上帝，我們的天父，發大慈悲，應許把赦罪的恩典賜與一切真心悔罪，誠信主，歸向主的人。願上帝憐憫你們，赦免你們，拯救你們脫離一切所犯的罪，賜你們行善的力量，叫你們得永生。這都是靠著我主耶穌基督。阿們。"
        ],
        laypersonRubric: "¶ 注意，若主禮人並非會長，應誦唸三一主日後第二十一主日之祝文來代替赦罪文：",
        laypersonParagraphs: [
            "求慈悲的主，將赦罪和平安的恩典，賜予信主的百姓。叫我們一切的罪惡，都得洗淨，心裏安然事奉主。這都是靠著我主耶穌基督。阿們。"
        ]
    )
    
    // MARK: 主禱文（認罪後）
    static let lordPrayer = PrayerSection(
        title: "主禱文",
        rubric: "¶ 然後應唸主禱文，眾跪。",
        paragraphs: [
            "我們在天上的父，願人都尊父的名為聖。願父的國降臨。願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人。保佑我們不遇試探，拯救我們脫離凶惡。因為國度、權柄、榮耀，全是父的，永世無盡。阿們。"
        ],
        responses: []
    )
    
    // MARK: 啟應
    static let responses: [Responsory] = [
        Responsory(leader: "啟：求主幫助我們開口。", people: "應：我們就讚美主。"),
        Responsory(leader: "啟：上帝阿，快來拯救我們。", people: "應：主阿，趕緊幫助我們。"),
        Responsory(leader: "啟：但願榮耀歸於聖父、聖子、聖靈；", people: "應：起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。"),
        Responsory(leader: "啟：你們應當讚美主。", people: "應：主的名應當讚美。")
    ]
    
    // MARK: - 邀請選句資料
    static let invitatory = InvitatoryData(
        generalRubric: "¶ 在「皆來頌」之前，應先將選句完整唸兩遍，然後按著標記，交替唸出詩節與選句。在季節與慶禮，邀請選句可從對應的專用與通用部分找到。",
        weekdayTexts: [
            "來啊，※我們要向主歌唱。",
            "我們要向上帝大聲歡呼，※祂是拯救我們的磐石。",
            "主是至大的君王，※我們當來俯伏敬拜。",
            "主是創造我們的，※我們當來俯伏敬拜。",
            "主是我們的創造者，※我們當來俯伏敬拜。",
            "主是我們的上帝，※我們當來俯伏敬拜。"
        ]
    )

    static let invitatoryMondayNote = "¶ 此句在頌歌之中不重複，直接接著唸「向拯救我們的磐石⋯⋯」。"
    
    // MARK: - 皆來頌（對經+詩節交替）
    static let venite = VeniteData(
        title: "皆來頌",
        stanzas: [
            // 開頭：對經完整兩遍（無詩節）
            VeniteStanza(antiphonMode: .fullTwice, verses: []),
            // 第一段詩節
            VeniteStanza(
                antiphonMode: nil,
                verses: [
                    "你們都來和我歌頌主，",
                    "※向我們全能的救主，大聲歡呼。",
                    "到主面前感謝，",
                    "※向主快活唱詩。"
                ]
            ),
            // 第二段詩節
            VeniteStanza(
                antiphonMode: .fullOnce,
                verses: [
                    "主是至大的神，",
                    "※至大的君，超在諸神以上。",
                    "地底幽深的處所，是主所掌，",
                    "※山的高峰，也屬主有。"
                ]
            ),
            // 第三段詩節
            VeniteStanza(
                antiphonMode: .secondHalf,
                verses: [
                    "海是主的，是主創造，",
                    "※旱地也是主手造成。",
                    "你們皆來同我屈膝，",
                    "※俯伏叩拜造我們的主。",
                    "惟主是我們的上帝，",
                    "※我們是主所撫養的民，是主手下的羊。"
                ]
            ),
            // 結束式選擇提示
            VeniteStanza(antiphonMode: .fullOnce, verses: [])
        ],
        ending1: VeniteEnding(
            title: "第一式",
            note: "¶ 全年平日與慶節：",
            stanzas: [
                VeniteStanza(
                    antiphonMode: nil,
                    verses: ["應該在榮華聖所崇拜主，",
                             "※普天下的人，都應該敬畏主。"]
                ),
                VeniteStanza(
                    antiphonMode: .fullOnce,
                    verses: [
                        "因為主必要來審判普天下人，",
                        "※按正直審判世界，依誠實判斷萬民。"
                    ]
                ),
                VeniteStanza(
                    antiphonMode: .secondHalf,
                    verses: ["但願榮耀歸於聖父、聖子、聖靈；",
                             "※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。"]
                ),
                // 最後：後半部分 → 完整一遍
                VeniteStanza(antiphonMode: .secondHalfThenFull, verses: [])
            ]
        ),
        ending2: VeniteEnding(
            title: "第二式",
            note: "¶ 禮拜三、禮拜五和懺悔日",
            stanzas: [
                VeniteStanza(
                    antiphonMode: nil,
                    verses: [
                        "惟願你們今日聽從主的話。",
                        "※不可心裏剛硬，像從前在米利巴，在曠野的瑪撒。",
                        "那時候你們列祖，雖然看見我的作為，",
                        "※還是試探我。"
                    ]
                ),
                VeniteStanza(
                    antiphonMode: .secondHalf,
                    verses: [
                        "那世代四十年惹我厭煩，我說，",
                        "※他們是心裏偏邪的百姓，不明白我的道理。",
                        "我就向他們發怒立誓，說，",
                        "※必不容他們到我安息的地方。"
                    ]
                ),
                VeniteStanza(
                    antiphonMode: .fullOnce,
                    verses: ["但願榮耀歸於聖父、聖子、聖靈；",
                             "起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。"]
                ),
                VeniteStanza(antiphonMode: .secondHalf, verses: []),
                VeniteStanza(antiphonMode: .fullOnce, verses: [])
            ]
        )
    )
    
    

    
    // MARK: 經課（已不含頌歌）
    static let lessons = [
        LessonBlock(
            title: "第一經課",
            rubric: "¶ 此後要按著週年讀經表，讀第一經課。注意，主禮在讀經課之前，先說：「某某書某某章（或某某章某某節）起」；而經課讀畢之後，要說：「第一經課（或第二經課）讀畢」。\n\n¶ 每次經課讀畢之後，以如下啟應作為結束是值得讚許的：",
            responses: [
                Responsory(leader: "啟：求主憐憫。", people: "應：感謝上帝。")
            ]
        ),
        LessonBlock(
            title: "第二經課",
            rubric: "¶ 此後，也應當按著週年讀經表，以同樣的方式誦讀由《聖經·新約》之中所選的第二經課。",
            responses: [
                Responsory(leader: "啟：求主憐憫。", people: "應：感謝上帝。")
            ]
        )
    ]
    
    // MARK: 頌歌（獨立區塊）
    static let firstCanticle = SeasonalBlock(
        title: "第一頌歌",
        rubric: "¶ 全年的主日與瞻禮日以及其八日慶期內，唸：",
        content: nil
    )
    
    static let secondCanticle = SeasonalBlock(
        title: "第二頌歌",
        rubric: "¶ 在啟應後，應唸專用對經，然後唸此頌歌。季節與慶節中，對經可以在相應的專用或通用部分找到。",
        content: nil
    )
    
    // MARK: 信經禮規
    static let creedRubric = "¶ 此後，主禮和會眾站立同唸使徒信經。注意，在特定的日子，則應用「亞他那修信經」代替「使徒信經」。"
    
    // MARK: 使徒信經
    static let apostlesCreed = PrayerSection(
        title: "使徒信經",
        rubric: nil,
        paragraphs: [
            "我信上帝，全能的父，是創造天地的。",
            "我信我主耶穌基督，是上帝的獨生子。因聖靈感孕，為童貞女馬利亞所生。在本丟彼拉多手下受難，釘在十字架上，受死，埋葬。降在陰間，第三天從死裏復活。升天，坐在無所不能的上帝聖父的右邊。將來必從那裏降臨審判活人死人。",
            "我信聖靈，我信聖而公之教會，我信聖徒相通，我信罪得赦免，我信身體復活，我信永生。阿們。"
        ],
        responses: []
    )
    
    // MARK: 尼西亞信經
    static let niceneCreed = PrayerSection(
        title: "尼西亞信經",
        rubric: nil,
        paragraphs: [
            "我信獨一上帝，全能的父，是創造天地的，並造有形無形的萬物。",
            "我信獨一主，耶穌基督，上帝的獨生子，在萬世以前為父所生，是從上帝的上帝，從光的光，從真上帝的真上帝，且生，不受造，與父一性，萬物都藉著他受造。又為我們世人，為救我們，從天降臨，因聖靈降孕，從童貞女馬利亞取肉身，成為世人。在本丟彼拉多手下為我們釘在十字架上；受害、埋葬。照聖經的話，第三天復活；升天，坐在父的右邊。將來必駕威榮再臨審判活人死人，祂的國就沒有窮盡。",
            "我信聖靈，是主，是賜生命的，從父【子】出來。同父、子一樣受尊貴，一樣受頌美。往日藉著眾先知傳話。我信使徒所傳的惟一聖而公之教會。我承認為赦罪設立的獨一洗禮。我望死人的復活。又指望來世的永生。阿們。"
        ],
        responses: []
    )
    
    // MARK: 祈禱
    static let prayers = PrayerSection(
        title: "祈禱",
        rubric: "¶ 此後，會眾虔誠跪下，誦唸以下禱文，主禮先唸：",
        paragraphs: [
            "啟：願主與你們同在。\n應：願主與你的心靈同在。\n\n我們要禱告。",
            "求主憐憫；\n求基督憐憫；\n求主憐憫。",
            "我們在天上的父，願人都尊父的名為聖。願父的國降臨。願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人。保佑我們不遇試探，拯救我們脫離凶惡。阿們。"
        ],
        responses: [] // ← 啟應改為獨立管理
    )
    
    // MARK: 祈禱啟應 - BCP1932（預設）
    static let prayersResponsesBCP1932: [Responsory] = [
        Responsory(leader: "啟：求主向我們發慈悲。", people: "應：求主施恩拯救我們。"),
        Responsory(leader: "啟：求主保佑國家。", people: "應：求主發慈悲允准我們的禱告。"),
        Responsory(leader: "啟：求主叫主所設立的聖品人、將善德當作衣服穿上。", people: "應：求主叫主的選民常常快樂。"),
        Responsory(leader: "啟：求主拯救主的百姓。", people: "應：賜福與主的選民。"),
        Responsory(leader: "啟：求主在這時候賜天下太平。", people: "應：只有主能叫我們平安度日。"),
        Responsory(leader: "啟：求主洗淨我們的心。", people: "應：求主使聖靈不離開我們。")
    ]
    // MARK: 祈禱啟應 - 新譯
    static let prayersResponsesNew: [Responsory] = [
        Responsory(leader: "啟：求主叫我們看見主的憐憫；", people: "應：求主施恩拯救我們。"),
        Responsory(leader: "啟：求主眷顧我們的國家（王國）；", people: "應：求主發慈悲允准我們的禱告。"),
        Responsory(leader: "啟：求主叫主的僕人都披上公義。", people: "應：叫主的子民都歡樂歌唱。"),
        Responsory(leader: "啟：求主拯救主的百姓。", people: "應：賜福給主的選民。"),
        Responsory(leader: "啟：主阿，求祢賜平安給全世界。", people: "應：因為我們只有在祢裡面，才能平安度日。"),
        Responsory(leader: "啟：上帝阿，求祢為我們造潔淨的心。", people: "應：求祢的聖靈扶持我們。")
    ]
    
    // MARK: 祝文
    static let collects: [PrayerSection] = [
        PrayerSection(
            title: "本日祝文",
            rubric: "¶ 此後，誦唸本日祝文，然後接著誦唸合時的紀念祝文；最後以下面兩篇祝文作為結束。",
            paragraphs: ["（按當日節期誦唸對應之祝文）"],
            responses: []
        ),
        PrayerSection(
            title: "求安祝文",
            rubric: nil,
            paragraphs: [
                "上帝是平安的根本，並且喜悅人和睦，人認識主就是永生，事奉主就是自由。伏求主保護卑微的僕人，不受仇人的一切攻擊，叫我們一心倚靠主的保護，不怕敵人的勢力。這都是靠著我主耶穌基督的大能。阿們。"
            ],
            responses: []
        ),
        PrayerSection(
            title: "求恩祝文",
            rubric: nil,
            paragraphs: [
                "無所不能、無始無終的天父上主，已經叫我們平安到今日早晨。求主還顯大能，保佑我們終日不犯罪，不遇危險，引導我們常做主所喜歡的事。這都是靠著我主耶穌基督。阿們。"
            ],
            responses: []
        )
    ]
    
    // MARK: 其他禱文
    static let generalPrayers: [PrayerSection] = [
        PrayerSection(
            title: "為國家及政府",
            rubric:  nil,
            paragraphs: [
                "萬王之王，萬主之主，至上全能的主天父，列王君王都屬主統轄，主在寶座上眷顧普天下的人。我們懇求主用慈愛恩惠看顧我們的國家和所有執政掌權的，賜給他們聖靈感化的恩，使他們能遵主的命令，行主的聖道。又求主多賜天恩保佑他們，終生平安、健康、長壽，死後享受永遠的安樂。這都是靠著我主耶穌基督。阿們。",
                "¶ 或唸此文：\n治理我們的主，主的榮耀充滿世界：我們將這國家，交託在主慈悲的眷顧之下，這樣，我們蒙主的恩佑引導，就能在主的平安裏常享太平。求主賜智慧與力量給我們的國家和所有執政掌權的人，使他們認識和遵行主的旨意，心中充滿對真理和正義的熱愛。又使他們知道使命，以敬畏主的心為民服務；這都是靠著我們的主耶穌基督，聖子和聖父、聖靈，一同永生，一同掌權，惟一上帝，永無窮盡。阿們。"
            ],
            responses: []
        ),
        PrayerSection(
            title: "為聖品人暨會眾禱文",
            rubric: nil,
            paragraphs: [
                "無所不能無始無終的上帝，各樣的大德大恩，都是主賜的。求主賜施救恩的聖靈，給一切主教和各等聖品人員，並他們所牧的教會。又常常施恩澤，叫他們所做的事，都合主的聖意。伏求主應允我們的禱告，將尊貴榮耀，歸於我們的中保，就是代我們求的主耶穌基督。阿們。"
            ],
            responses: []
        ),
        PrayerSection(
            title: "為普天下人禱文",
            rubric: nil,
            paragraphs: [
                "上帝是創造世人，保護世人的。現在我們為各樣各類的人，恭敬禱告，懇求主叫他們都明白主的聖道，叫萬國也都感謝主救世的恩典。又特為天下的聖公教會禱告，求主使教會蒙聖靈的引導管理，叫凡說自己是基督門徒的，都得著指引，來到真理的路上，同心堅守聖教，彼此和睦，做事合理。又替身心和事業遇難受苦的人禱告。【且特為請我們禱告的某某。若無人請禱，則不讀此句。】伏求天父大發慈悲，照各人的苦處，安慰他們，拯救他們，叫他們在受苦的時候，有忍耐的心，也救他們脫離一切困苦。這都是靠著我主耶穌基督。阿們。"
            ],
            responses: []
        ),
        PrayerSection(
            title: "總謝文",
            rubric: "¶ 注意、此總謝文會眾可隨主禮同讀",
            paragraphs: [
                "無所不能的上帝，賜萬恩的父。我們這些無用的僕人，都謙卑誠心感謝主，因為主賜恩惠仁慈與我們，也賜與萬人。【且賜與受過主恩，要讚美主感謝主的某某。若無人請謝，則不讀此句。】又感謝主，因為主創造我們，保護我們，並將今世各樣的福，賜與我們。更感謝主，因為主將頂大的仁愛，藉著我主耶穌基督，救贖世人，又將受恩的法，賜與我們，也叫我們指望後來的榮耀。伏求主叫我們紀念主的一切仁慈，都真心感謝主，讚美主。又叫我們顯揚主的聖德，不但口裡說，也要用所做的事，就是一心事奉主，一生做清潔善良的事。這都是靠著我主耶穌基督。但願尊貴榮耀，歸於聖父、聖子、聖靈，永世無盡。阿們。"
            ],
            responses: []
        ),
        PrayerSection(
            title: "金口聖約翰禱文",
            rubric: nil,
            paragraphs: [
                "無所不能的上帝，賜恩典與我們，叫我們在這時候同心禱告。主從前說，若有兩三個人奉主的名聚集禱告，主必應許。現在我們所願所求的，若是與我們有益，伏求主允准，使我們今世明白主的真道，來世得享永生。阿們。"
            ],
            responses: []
        )
    ]
    // MARK: 結尾專屬啟應
    static let endingResponses: [Responsory] = [
        Responsory(leader: "啟：願主與你們同在。", people: "應：願主與你的心靈同在。"),
        Responsory(leader: "啟：我們要讚美主。", people: "應：感謝上帝。"),
        Responsory(leader: "啟：願所有已經去世信友的靈魂，因上帝的恩慈，得享安息。", people: "應：阿們。")
    ]
    
    // MARK: 結束
    static let ending = PrayerSection(
        title: "使徒禱文",
        rubric: "",
        paragraphs: [
            "願主耶穌基督的恩惠，上帝的慈愛，聖靈的感動，常與我們眾人同在。阿們。\n（哥林多後書13:14）",
        ],
        responses: []
    )
    // MARK: 聖帕特里克鎧甲歌
    static let stPatrickBreastplate: [String] = [
        "今我緊緊向我周身，繫主三一剛強之名，\n繫主幫助引領權能，繫主扶持保護之恩，\n垂聽之耳看守之睛，指導之手蔭庇之盾，\n教訓之言感動之聲，永生之道永在之靈。",
        "今我緊緊向我周身，繫主基督道成人身，\n繫主領洗約旦河濱，繫主十架受死救人，\n繫主脫離芳香之墓，繫主復活乘雲上升，\n繫主為日再臨塵世，凡此神力緊緊於身。",
        "今我緊緊向我周身，繫基路伯愛心之殷，\n繫撒拉弗事主之誠，繫主末日宣告完成，\n繫眾烈士聖人之訓，先知之言傳世之經，\n一切歸主善良言行，一切歸主清潔靈魂。",
        "今我緊緊向我周身，繫彼群星光明德性，\n繫彼紅日輝煌生命，繫彼夜月皎潔晶明，\n繫彼雷電光照聲名，繫彼風雨時作時停，\n繫彼大地博厚久恆，繫彼洋海既廣且深。",
        "今我身繫種種權能，以破罪惡奸邪之阱，\n以破試探引誘之因，以破心中情慾戰爭，\n以破仇敵阻我行程，無論眾寡無論遠近，\n處處時時向前猛進，攻破一切兇狂敵人。",
        "求主陪我居我心間，求主在後求主在前，\n求主在旁勝我罪愆，求主慰我導我歸旋，\n求主在下求主在上，引我穩渡危險安康，\n求進一切愛我心鄉，求臨親疏友朋舌上。",
        "今我緊緊向我周身，繫主三一剛強之名，\n願能依賴禱告之誠，不離三一偉大權能，\n讚美永生聖父聖靈，萬物受造有生重生，\n讚美聖子救贖我靈，萬民中保天國之君。\n阿們。"
    ]
    
    // MARK: - 聖靈降臨八日慶期每日附加祝文
    struct PentecostOctaveAppendix {
        static let collect = DailyOfficeFile.OfficePeriod.CollectJSON(
            title: "聖靈降臨八日慶期每日祝文",
            text: "全能最慈悲的上帝，我們懇求主，使我們靠著住在我們裡面的聖靈，得蒙啓發，加增力量服事主。這都是靠著我主耶穌基督。主和聖父、聖靈，惟一上帝，一同永生，一同掌權，世世無盡。阿們。"
        )
        
        /// 需要附加此祝文的日子（主標題）
        static let applicableTitles: Set<String> = [
            "聖靈降臨後一日",
            "聖靈降臨後二日",
            "聖靈降臨八日慶期內夏季齋期禮拜三",
            "聖靈降臨八日慶期內禮拜四",
            "聖靈降臨八日慶期內夏季齋期禮拜五",
            "聖靈降臨八日慶期內夏季齋期禮拜六"
        ]
    }
}
