import Foundation

struct PenitentialServiceData {
    static let title = "大齋首日懺悔文"
    
    struct StandaloneBlock {
        let rubric: String
        let sentences: [(text: String, reference: String)]
    }
    
    static let standalone = StandaloneBlock(
        rubric: "¶ 此禮文應於早禱或晚禱第三篇祝文後使用；或於總禱文後；或於施聖餐前；或單獨使用。若在早禱或晚禱用時，應從詩篇第51篇開始。此禮文特別適用於大齋期及其他懺悔時期，四季齋期，以及復活期以外的禮拜五。若單獨使用時，禮文由以下聖經選句開始：",
        sentences: [
            (text: "耶穌來到加利利，宣講上帝的福音，說：日期滿了，上帝的國近了。你們要悔改，信福音！", reference: "馬可福音 1:14-15"),
            (text: "凡父所賜給我的人，必到我這裏來；到我這裏來的，我總不丟棄他。", reference: "約翰福音 6:37"),
            (text: "凡勞苦擔重擔的人都到我這裏來，我要使你們得安息。我心裏柔和謙卑，你們當負我的軛，向我學習；這樣，你們的心靈就必得安息。因為我的軛是容易的，我的擔子是輕省的。", reference: "馬太福音 11:28-30")
        ]
    )
    
    static let embeddedRubric = "¶ 此禮文應於早禱或晚禱第三篇祝文後使用；或於總禱文後；或於施聖餐前；或單獨使用。此禮文特別適用於大齋期及其他懺悔時期，四季齋期，以及復活期以外的禮拜五。"
    static let beforePsalmRubric = "¶ 主禮與會眾同跪，誦唸詩篇。"
    static let afterPsalmRubric = "¶ 若曾誦讀總禱文，主禮可直接誦唸「求主拯救主的僕人⋯⋯」禱文。"
    
    static let kyrieResponses: [PenitentialResponsoryItem] = [
        PenitentialResponsoryItem(leader: "求主憐憫我們。", people: "求基督憐憫我們。"),
        PenitentialResponsoryItem(leader: "求主憐憫我們。", people: nil)
    ]
    
    static let lordPrayerText = "我們在天上的父，願人都尊父的名為聖，願父的國降臨，願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人，保佑我們不遇試探，拯救我們脫離凶惡。阿們。"
    
    static let salvationResponses: [PenitentialResponsoryItem] = [
        PenitentialResponsoryItem(leader: "求主拯救主的僕人。", people: "因為我們只仰仗主。"),
        PenitentialResponsoryItem(leader: "求主賜恩輔助我們。", people: "求主常施大能，保護我們。"),
        PenitentialResponsoryItem(leader: "求我救主上帝扶助我們。", people: "求主為主名的榮耀救贖我們，為主的聖名，憐憫我們有罪的人。"),
        PenitentialResponsoryItem(leader: "求主聽我禱告。", people: "願我懇求的聲音，達到主的面前。")
    ]
    
    static let confessionPrayers: [PrayerSection] = [
        PrayerSection(
            title: nil,
            rubric: nil,
            paragraphs: [
                "懇求主發慈悲，聽我們禱告，憐憫一切在主面前認罪的人，叫那因為犯罪心裡不安的人，都蒙主的恩典，赦免他們的罪。這都是靠著我主耶穌基督。阿們。"
            ],
            responses: []
        ),
        PrayerSection(
            title: nil,
            rubric: nil,
            paragraphs: [
                "全能上帝，慈悲的父，常常憐憫萬人，不願罪人死，只願他悔改得救。現在我們背負重罪，心裡憂愁難過，求主發慈悲，眷顧我們，安慰我們，赦免我們一切的過惡。只有主常施憐憫，只有主能夠赦人的罪，求仁慈的主，憐憫我們，憐憫主所贖回的子民。求主莫追問主的僕人，我們真誠痛悔認罪，求主息怒，今世快來救我們，來世叫我們同主得享永生。這都是靠著我主耶穌基督。 阿們。"
            ],
            responses: []
        )
    ]
    
    static let congregationRecitation = PrayerSection(
        title: nil,
        rubric: "¶ 會眾隨主禮誦讀以下經文。",
        paragraphs: [
            "求慈悲的主，叫我們歸向主，我們就歸向主。我們現在哀哭禁食禱告，要歸向主，求主悅納。主最慈悲，常常忍耐，多行仁愛，大施憐憫，我們受罰的時候，主還是寬恕，主發怒的時候，還是存憐憫的心。又求慈悲的主，憐憫我們，叫我們總不羞愧。主的慈悲，沒有窮盡，懇求主應允我們的禱告，大發憐憫，看顧我們。這都是靠著當贊美的聖子，我中保我主耶穌基督的功勞。阿們。"
        ],
        responses: []
    )
    
    static let optionalOmitRubric = "¶ 以下的禱文可以省略，直接以最後的祝文「上帝的本性就是憐憫⋯⋯」和祝福文作結束。"
    
    static let priestPrayer = PrayerSection(
        title: nil,
        rubric: "¶ 主禮誦讀：",
        paragraphs: [
            "主啊，因祢溫柔的慈悲，求祢不要追究我們的罪；但求祢赦免我們過去的過犯，並賜恩典使我們改正罪惡的生活；使我們遠離罪惡，傾向美德，好叫我們現在和永遠在祢面前以完全的心行走。"
        ],
        responses: []
    )
    
    static let ashResponses: [PenitentialResponsoryItem] = [
        PenitentialResponsoryItem(leader: "記住你是塵土，將來仍要歸回塵土。", people: "主啊，求祢憐憫我們。"),
        PenitentialResponsoryItem(leader: "求主垂聽我們的禱告。", people: "願我們的呼聲達到主前。")
    ]
    
    static let finalPrayers: [PrayerSection] = [
        PrayerSection(
            title: nil,
            rubric: nil,
            paragraphs: [
                "無所不能永生的上帝，當日尼尼微人披麻蒙灰悔改時，主就赦免了他們：懇求主施恩憐憫，使我們真誠悔改己罪，得蒙主完全的赦免與釋放；這都是靠著我主耶穌基督。阿們。"
            ],
            responses: []
        ),
        PrayerSection(
            title: nil,
            rubric: nil,
            paragraphs: [
                "上帝我們的天父使日頭照好人，也照歹人，降雨給義人，也給不義的人：求主幫助我們愛仇敵，饒恕得罪我們的人，使我們也可以從主那裡得到罪的赦免，並在聖靈裏和真理中成為主的兒女；這都是靠著我們的主耶穌基督。主和聖父，聖靈，惟一上帝，一同永生，一同掌權，永世無盡。阿們。"
            ],
            responses: []
        ),
        PrayerSection(
            title: nil,
            rubric: nil,
            paragraphs: [
                "全能的大主宰，萬物之源，一切美善之施予者：求主將愛慕主聖名的心栽植在我們心裡，使我們對主的信仰日益增長，以主的美善培育我們，並以主的大慈悲保守我們常在其中；這都是靠著我主耶穌基督。阿們。"
            ],
            responses: []
        )
    ]
    
    static let hymn = (
        title: "聖詩",
        verses: [
            "榮耀君王諸聖簇擁，永遠受讚無盡無窮。",
            "主既親臨我眾之中，我眾稱為主之聖名。",
            "懇求上帝莫棄我等，潔心以守逾越聖節。",
            "審判之日列位聖選，至福君王懇求垂憐。"
        ]
    )
    
    static let finalCollect = PrayerSection(
        title: nil,
        rubric: "¶ 主禮誦唸：",
        paragraphs: [
            "上帝的本性就是憐憫，歡喜赦免。現在求主聽我們的懇求，我們犯罪就像被鐵鍊捆住。懇求主施憐憫，發大慈悲，解開我們，將榮耀歸於我們的中保，就是為我們代求的耶穌基督。阿們。"
        ],
        responses: []
    )
    
    static let blessing = "願主賜福與我們，保全我們；願主面上的光榮普照我們，賜恩典與我們；願主眷顧我們，賜平安與我們，從現在直到永遠。阿們。"
}

struct PenitentialResponsoryItem: Hashable {
    let leader: String
    let people: String?
}
