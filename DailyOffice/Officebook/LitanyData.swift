import Foundation

// MARK: - 總禱文啟應結構
struct LitanyResponsory: Hashable {
    let leader: String
    let people: String
}

// MARK: - 總禱文資料
struct LitanyData {
    
    // MARK: 標題與禮規
    static let title = "總禱文"
    static let mainRubric = "¶ 此文在早禱或晚禱第三祝文後誦唸，或在施聖餐文前誦唸，或單獨誦唸。"
    
    // MARK: 總禱文啟應（41組）
    static let mainResponses: [LitanyResponsory] = [
        LitanyResponsory(leader: "創造天地的上帝聖父。", people: "憐憫我們。"),
        LitanyResponsory(leader: "救世的上帝聖子。", people: "憐憫我們。"),
        LitanyResponsory(leader: "使信徒成聖的上帝聖靈。", people: "憐憫我們。"),
        LitanyResponsory(leader: "至聖當稱頌有榮耀三一的惟一上帝。", people: "憐憫我們。"),
        LitanyResponsory(leader: "上帝聖母，我主耶穌基督之母，聖馬利亞，", people: "請為我們祈禱。"),
        LitanyResponsory(leader: "諸聖天使、天使長、永安群靈；", people: "請為我們祈禱。"),
        LitanyResponsory(leader: "諸聖祖、先知、使徒、殉道者、宣信者、童貞女及天上眾聖徒；", people: "請為我們祈禱。"),
        LitanyResponsory(leader: "求主莫記念我們的過犯、和我們列祖的過犯、莫照我們的罪報應我們。求慈悲的主、憐憫我們、就是主用寶貝的血所救贖的百姓、且莫向我們常常發怒。", people: "求慈悲的主憐憫我們。"),
        LitanyResponsory(leader: "求主救我們不遇兇惡災害、不犯罪、不遭撒但的謀害攻擊、不干犯主的震怒、免定永遠的罪。", people: "求慈悲的主拯救我們。"),
        LitanyResponsory(leader: "求主救我們不蒙昧、不驕傲、不自誇、不假善、不存妒忌怨恨謀害、和一切不仁愛的心。", people: "求慈悲的主拯救我們。"),
        LitanyResponsory(leader: "求主救我們不生無度的貪愛、不法的情慾、也不受世俗私慾、和撒但的迷惑。", people: "求慈悲的主拯救我們。"),
        LitanyResponsory(leader: "求主救我們不遭大雷大風、地震、水火的災難、不遇瘟疫飢荒的災難、和爭戰兇殺暴死的禍患。", people: "求慈悲的主拯救我們。"),
        LitanyResponsory(leader: "求主救我們、不遇結黨謀反作亂的事、不從假道異端、和叛離教會的事、不存剛硬的心、不藐視主的聖道、和主的命令。", people: "求慈悲的主拯救我們。"),
        LitanyResponsory(leader: "為主降生成人的奧妙、為主聖誕受割禮、為主受洗禁食、為主受試探。", people: "求慈悲的主拯救我們。"),
        LitanyResponsory(leader: "為主心裡的慘傷、為主身上的血汗、為主釘十字架受痛苦、為主至寶的死安葬、為主榮耀的復活升天、為聖靈降臨。", people: "求慈悲的主拯救我們。"),
        LitanyResponsory(leader: "在受苦享福的時候、在臨死受審的日子。", people: "求慈悲的主拯救我們。"),
        LitanyResponsory(leader: "我們罪人、伏求主上帝俯聽、求主管理引導主的聖公教會、使行正道。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主眷顧我國的中央政府、使他們能夠在萬事以上、尋求主的尊貴和榮耀。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主眷顧保護一切信服主的執政和掌權的、賜恩惠與他們、叫他們用義理治百姓、做事公道。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主叫一切主教、會長、會吏、都通曉聖道、可講真理、也可照所講的去做、為眾人的榜樣。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主差遣主的工人、去收主的莊稼。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主賜恩典、保護主的百姓。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主賜天下萬國、都同心和睦、都享太平。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主賜我們敬畏主愛慕主的心、叫我們照主的命令殷勤去做。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主多賜恩典、保佑主的百姓、叫他們恭敬聽主的聖道、誠心領受、又蒙聖靈的感化、結成好果子。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主引導凡被迷惑、和走錯了路的人、都歸正道。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主堅固那站住的人、安慰幫助那軟弱的人、扶起那跌倒的人、又叫撒但伏在我們的腳下。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主保護那遇危險的人、拯救那受窮苦的人、安慰那遇艱難的人。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主保護在陸、海、空、旅行的人、保佑一切生產的婦人、保佑生病的人、和小孩子們、憐憫坐監牢的人、和被擄的人。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主保護撫養孤兒寡婦、和各樣無依靠與負屈含冤的人。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主憐憫普天下的人。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主饒恕怨恨我們、逼迫我們、毀謗我們的人、並且感動他們、回心轉意。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主賜地上的出產、叫我們隨時夠吃夠用。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求主叫我們真心悔改、赦免我們所犯的罪、饒恕我們疏忽愚蠢的過錯、又賜聖靈的恩佑、叫我們行動、都能遵主的聖道。", people: "求慈悲的主俯聽。"),
        LitanyResponsory(leader: "求上帝的聖子俯聽。", people: "求上帝的聖子俯聽。"),
        LitanyResponsory(leader: "除掉世上罪的、上帝的羔羊。", people: "賜我們平安。"),
        LitanyResponsory(leader: "除掉世上罪的、上帝的羔羊。", people: "憐憫我們。"),
        LitanyResponsory(leader: "求基督俯聽。", people: "求基督俯聽。"),
        LitanyResponsory(leader: "求主憐憫我們。", people: "求主憐憫我們。"),
        LitanyResponsory(leader: "求基督憐憫我們。", people: "求基督憐憫我們。"),
        LitanyResponsory(leader: "求主憐憫我們。", people: "求主憐憫我們。"),
    ]
    
    // MARK: 主禱文
    static let lordPrayer = PrayerSection(
        title: "主禱文",
        rubric: "¶ 主領與會眾跪下，同讀。",
        paragraphs: [
            "我們在天上的父，願人都尊父的名為聖。願父的國降臨。願父的旨意行在地上，如同行在天上。日用的糧食，求父今天賜給我們。又求饒恕我們的罪，如同我們饒恕得罪我們的人。保佑我們不遇試探，拯救我們脫離兇惡。因為國度、權柄、榮耀，全是父的，永世無盡。阿們。"
        ],
        responses: []
    )
    
    static let lordPrayerNote = "¶ 主禮者可斟酌刪除省略以下禱文、直接從「我們恭敬懇求天父⋯⋯」讀起。"
    
    // MARK: 中間啟應
    static let intermediateResponses: [LitanyResponsory] = [
        LitanyResponsory(leader: "求主莫照我們的罪責罰我們。", people: "求主莫照我們的過惡報應我們。"),
        LitanyResponsory(leader: "我們要禱告。", people: "")
    ]
    
    // MARK: 中間禱文
    static let intermediatePrayer = PrayerSection(
        title: nil,
        rubric: nil,
        paragraphs: [
            "上帝慈悲的父、痛悔的人心裡的嘆息、憂傷的人心裡的羨慕、主都不輕看。我們受苦受難的時候禱告主、求主施恩幫助。又求主攻敗撒但和惡人謀害我們的奸計、叫我們不受他們的害、能夠在聖會中時常感謝主。這都是靠著我主耶穌基督。 阿們。"
        ],
        responses: []
    )
    
    // MARK: 中間誦唸段落
    struct Recitation: Hashable {
        let rubric: String
        let text: String
    }
    
    static let middleRecitations: [Recitation] = [
        Recitation(
            rubric: "¶ 主禮者與眾同唸：",
            text: "求主為主的聖名起來、幫助我們、拯救我們。"
        ),
        Recitation(
            rubric: "¶ 主禮者唸：",
            text: "上帝在古時我們列祖的時候、行的奇事、我們已經親耳聽見、列祖也對我們傳說。"
        ),
        Recitation(
            rubric: "¶ 主禮者與會眾同唸：",
            text: "求主為主的榮耀起來、幫助我們、拯救我們。"
        )
    ]
    
    // MARK: 結尾啟應
    static let closingResponses: [LitanyResponsory] = [
        LitanyResponsory(leader: "但願榮耀歸於聖父、聖子、聖靈。", people: "起初怎樣、現在以及永遠、也是怎樣、世世無盡。"),
        LitanyResponsory(leader: "求基督保護我們脫離仇敵。", people: "求主賜恩典、眷顧我們的苦難。"),
        LitanyResponsory(leader: "求主施憐憫、眷顧我心裡的憂愁。", people: "求主發慈悲、饒恕百姓的罪。"),
        LitanyResponsory(leader: "求主施恩典、俯聽我們的禱告。", people: "求大衛的後裔、憐憫我們。"),
        LitanyResponsory(leader: "求基督從現在直到後來、常聽我們的禱告。", people: "求基督施恩俯聽、求主基督施恩俯聽。"),
        LitanyResponsory(leader: "求主憐憫我們。", people: "因為我們只仰仗主。"),
        LitanyResponsory(leader: "我們要禱告。", people: "")
    ]
    
    // MARK: 結尾禱文
    static let closingPrayer = PrayerSection(
        title: nil,
        rubric: nil,
        paragraphs: [
            "我們恭敬懇求天父、哀憐我們、眷顧我們的軟弱、為主聖名的榮耀、免我們當受的災難。又求主叫我們遇難的時候、專心仰仗主的慈悲、一生清潔善良事奉主、將尊貴榮耀歸於主的聖名。這都是靠著我們獨一無二的中保、就是代我們求的主耶穌基督。 阿們。"
        ],
        responses: []
    )
    
    // MARK: 最後禮規
    static let finalRubric = "¶ 總禱文應在主日、禮拜三和禮拜五誦讀，尤其是在大齋期間；以及特禱日。在重大公共災難、災禍或戰爭時期，禮文中可省略的部分也應當誦讀。"
}
