import Foundation

// MARK: - 1. 聖日模型
struct Feast {
    let month: Int
    let day: Int
    let name: String
    let rank: LiturgicalRank
    let priority: Int 
}

// MARK: - 2. 固定聖日資料庫 (Sanctorale)
class Sanctorale {
    
    // 改為存儲數組，支持同日多聖日
    private var feasts: [String: [Feast]] = [:]
    
    static let shared = Sanctorale()
    
    private init() {
        loadFeasts()
    }
    
    // MARK: - 查詢所有聖日（新增）
    func getFeasts(for date: Date) -> [Feast] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let key = String(format: "%02d-%02d", month, day)
        return feasts[key] ?? []
    }
    
    // MARK: - 向後兼容：返回最高等級的單個聖日
    func getFeast(for date: Date) -> Feast? {
        return getFeasts(for: date).sorted { $0.rank > $1.rank }.first
    }
    
    // MARK: - 載入聖日（改為追加模式）
    private func loadFeasts() {
        func add(_ month: Int, _ day: Int, _ name: String, _ rank: LiturgicalRank, _ priority: Int = 0) {
            let key = String(format: "%02d-%02d", month, day)
            let feast = Feast(month: month, day: day, name: name, rank: rank, priority: priority)
            if feasts[key] == nil {
                feasts[key] = []
            }
            feasts[key]!.append(feast)
        }
        
        add(1, 1, "救主受割禮日", .doubleSecondClass)
        add(1, 2, "聖司提反日八日慶期第八日", .simple)
        add(1, 3, "聖約翰日八日慶期第八日", .simple)
        add(1, 4, "嬰孩被殺日八日慶期第八日", .simple)
        add(1, 5, "救主顯現望日", .privilegedVigilSecondClass)
        add(1, 6, "顯現日", .doubleFirstClass)
        add(1, 7, "顯現日八日慶期第二日", .privilegedOctaveSecondClass)
        add(1, 8, "顯現日八日慶期第三日", .privilegedOctaveSecondClass)
        add(1, 9, "顯現日八日慶期第四日", .privilegedOctaveSecondClass)
        add(1, 10, "顯現日八日慶期第五日", .privilegedOctaveSecondClass)
        add(1, 11, "顯現日八日慶期第六日", .privilegedOctaveSecondClass)
        add(1, 12, "顯現日八日慶期第七日", .privilegedOctaveSecondClass)
        add(1, 13, "顯現日八日慶期第八日", .privilegedOctaveSecondClassGreat)
        add(1, 14, "教會聖師聖希拉里主教", .double)
        add(1, 15, "首位隱修士聖保羅", .double)
        add(1, 16, "真福威廉·勞德主教", .simple)
        add(1, 17, "聖安東尼院長", .double)
        add(1, 18, "殉道童貞女聖百基拉", .simple)
        add(1, 20, "殉道者聖法比盎和聖巴斯弟盎", .double)
        add(1, 21, "殉道童貞女聖雅妮", .double)
        add(1, 22, "殉道者聖文生", .double)
        add(1, 24, "聖梯摩太主教", .double)
        add(1, 25, "使徒聖保羅受感化日", .doubleSecondClass)
        add(1, 26, "聖波利卡主教", .double)
        add(1, 27, "教會聖師聖金口約翰", .double)
        add(1, 29, "聖方濟各·沙雷氏主教", .double)
        add(1, 30, "殉道王查理", .doubleSecondClass)
        add(1, 31, "聖若望·鮑思高", .double)

        // ------------------ 2月 ------------------
        add(2, 1, "殉道者聖伊格納丟主教", .double)
        add(2, 2, "獻聖嬰日 (童女聖馬利亞告潔日)", .doubleSecondClass)
        add(2, 3, "聖布萊斯主教", .simple)
        add(2, 4, "施普林格的聖吉爾伯特院長", .simple)
        add(2, 5, "殉道童貞女聖阿加莎", .double)
        add(2, 6, "殉道者聖提多主教", .double)
        add(2, 7, "聖羅慕鐸院長", .double)
        add(2, 8, "聖約翰·瑪達", .double)
        add(2, 9, "教會聖師亞歷山大的聖區利羅", .double)
        add(2, 10, "童貞女聖思嘉", .double)
        add(2, 11, "露德聖母", .greaterDouble)
        add(2, 12, "聖本篤·比斯克普院長", .double)
        add(2, 13, "聖肯蒂格恩主教", .semiDouble)
        add(2, 14, "殉道者聖瓦倫丁司鐸", .simple)
        add(2, 15, "日本殉道者", .simple)
        add(2, 18, "殉道者聖西緬主教", .simple)
        add(2, 22, "聖彼得設立宗座於安提阿", .greaterDouble)
        add(2, 23, "使徒聖馬提亞望日", .vigil)
        add(2, 24, "使徒聖馬提亞日", .doubleSecondClass)

        // ------------------ 3月 ------------------
        add(3, 1, "聖大衛主教", .double)
        add(3, 2, "聖查德主教", .semiDouble)
        add(3, 6, "殉道者聖普伯度和聖費莉希蒂", .double)
        add(3, 7, "教會聖師托馬斯·阿奎納", .double) //
        add(3, 8, "天賜聖約翰", .double)
        add(3, 9, "羅馬的聖法蘭西絲", .double)
        add(3, 10, "四十聖殉道者", .semiDouble)
        add(3, 12, "教宗大聖格里高利", .double)
        add(3, 17, "聖帕特里克主教", .double)
        add(3, 18, "耶路撒冷聖區利羅主教", .double)
        add(3, 19, "聖母淨配聖約瑟", .doubleFirstClass)
        add(3, 20, "聖卡斯伯特主教", .double)
        add(3, 21, "努西亞的聖本篤院長", .greaterDouble)
        add(3, 22, "真福詹姆斯·德·科文", .simple)
        add(3, 24, "天使長聖加百列", .greaterDouble)
        add(3, 25, "童女聖馬利亞聞報日", .doubleFirstClass)
        add(3, 27, "教會聖師大馬士革聖約翰", .double)
        add(3, 29, "真福約翰·基布爾", .simple)

        // ------------------ 4月 ------------------
        add(4, 5, "教會聖師聖伊西多主教", .double)
        add(4, 11, "教宗大聖利奧一世", .double)
        add(4, 14, "殉道者聖游斯丁", .double)
        add(4, 17, "聖司提反·哈丁院長", .semiDouble)
        add(4, 19, "殉道者聖亞斐奇主教", .simple)
        add(4, 21, "教會聖師聖安瑟倫主教", .double)
        add(4, 23, "殉道者聖喬治", .semiDouble)
        add(4, 25, "傳福音使徒聖馬可日", .doubleSecondClass)
        add(4, 27, "教會聖師聖彼得·卡尼修", .double)
        add(4, 28, "十字聖保羅", .double)
        add(4, 29, "殉道者維羅納的聖彼得", .double)
        add(4, 30, "教會聖師、童貞女錫耶納的聖凱瑟琳", .double)
        
        // ------------------ 5月 ------------------
        add(5, 1, "使徒聖腓力和聖雅各日", .doubleSecondClass)
        add(5, 2, "聖亞他那修主教", .double)
        add(5, 3, "發現聖十架日", .doubleSecondClass)
        add(5, 4, "聖莫尼卡", .double)
        add(5, 5, "聖奧古斯丁受感化日", .double)
        add(5, 7, "殉道者聖斯丹尼斯勞斯主教", .double)
        add(5, 9, "教會聖師拿先斯的聖格里高利主教", .double)
        add(5, 12, "殉道者聖涅柔斯、聖亞奇力、聖多彌諦拉、聖邦康", .semiDouble)
        add(5, 14, "聖巴科繆院長 (紀念聖波尼法爵)", .simple)
        add(5, 16, "聖西面·斯托克", .simple) 
        add(5, 17, "聖巴斯加", .double)
        add(5, 19, "聖鄧斯坦主教", .double)
        add(5, 20, "錫耶納的聖伯納定主教", .semiDouble)
        add(5, 24, "勒蘭的聖文森特", .simple)
        add(5, 26, "坎特伯雷的聖奧古斯丁", .greaterDouble)
        add(5, 27, "教會聖師可敬者聖比德", .double)
        add(5, 30, "殉道童貞女聖貞德", .semiDouble)

        // ------------------ 6月 ------------------
        add(6, 2, "中華殉道諸聖", .doubleSecondClass)
        add(6, 9, "聖科倫巴院長", .double)
        add(6, 10, "蘇格蘭的聖瑪格麗特", .semiDouble)
        add(6, 11, "使徒聖巴拿巴日", .doubleSecondClass)
        add(6, 13, "帕多瓦的聖安東尼", .double)
        add(6, 14, "教會聖師大聖巴西流主教", .double)
        add(6, 17, "聖博托爾夫院長", .simple)
        add(6, 18, "聖以法蓮會吏", .double)
        add(6, 20, "敬遷殉道聖王愛德華之聖髑", .semiDouble)
        add(6, 22, "英格蘭首位殉道者聖阿爾班", .double)
        add(6, 23, "施洗聖約翰誕辰望日", .vigil)
        add(6, 24, "施洗聖約翰誕辰日", .doubleFirstClass)
        add(6, 25, "施洗聖約翰誕辰日八日慶期第二日", .ordinaryOctavesemiDouble)
        add(6, 26, "施洗聖約翰誕辰日八日慶期第三日", .ordinaryOctavesemiDouble)
        add(6, 27, "施洗聖約翰誕辰日八日慶期第四日", .ordinaryOctavesemiDouble)
        add(6, 28, "殉道者聖愛任紐主教 (紀念施洗聖約翰誕辰日八日慶期第五日)", .double)
        add(6, 28, "使徒聖彼得與聖保羅望日", .vigil)
        add(6, 29, "使徒聖彼得與聖保羅日（紀念施洗聖約翰誕辰日八日慶期第六日）", .doubleFirstClass)
        add(6, 30, "紀念使徒聖保羅 (紀念施洗聖約翰誕辰日八日慶期第七日)", .greaterDouble)
        
        // ------------------ 7月 ------------------
        add(7, 1, "我主基督至聖寶血（紀念施洗聖約翰誕辰日八日慶期第八日）", .doubleFirstClass)
        add(7, 2, "榮福童貞馬利亞訪親日", .doubleSecondClass)
        add(7, 3, "使徒聖彼得與聖保羅日八日慶期第五日", .ordinaryOctavesemiDouble)
        add(7, 4, "使徒聖彼得與聖保羅日八日慶期第六日", .ordinaryOctavesemiDouble)
        add(7, 5, "使徒聖彼得與聖保羅日八日慶期第七日 (紀念聖弗拉基米爾大公)", .ordinaryOctavesemiDouble)
        add(7, 6, "使徒聖彼得與聖保羅日八日慶期第八日", .ordinaryOctavegreaterDouble)
        add(7, 7, "聖區利羅主教與聖美多德主教", .double)
        add(7, 8, "葡萄牙的聖伊麗莎白女王", .semiDouble)
        add(7, 9, "殉道者聖約翰·費捨爾主教和聖托馬斯·莫爾", .simple)
        add(7, 11, "敬遷努西亞聖本篤之聖髑", .double)
        add(7, 12, "聖約翰·瓜爾貝特院長", .double)
        add(7, 13, "殉道者聖西拉", .semiDouble)
        add(7, 14, "教會聖師聖波拿文都拉主教", .double)
        add(7, 15, "敬遷聖斯威頓主教之聖髑", .simple)
        add(7, 16, "加羅默爾聖母 (紀念敬遷聖奥斯蒙德之聖髑)", .greaterDouble)
        add(7, 17, "聖阿歷克修斯", .semiDouble, 5)
        add(7, 18, "殉道者聖伯納多·米澤基", .semiDouble, 10)
        add(7, 19, "聖文森·德·保羅", .double)
        add(7, 20, "殉道童貞女安提阿的聖瑪格麗特", .double)
        add(7, 22, "抹大拉的聖馬利亞", .double)
        add(7, 23, "殉道者聖亞波里拿留主教", .double)
        add(7, 24, "使徒聖雅各望日", .vigil)
        add(7, 25, "使徒聖雅各日", .doubleSecondClass, 10)
        add(7, 26, "聖安娜，榮福童貞馬利亞之母", .doubleSecondClass, 5)
        add(7, 29, "童貞女聖馬大", .semiDouble)
        add(7, 31, "聖依納爵·羅耀拉", .double)

        // ------------------ 8月 ------------------
        add(8, 1, "聖彼得受鎖鏈 (紀念瑪喀比聖殉道者)", .greaterDouble)
        add(8, 2, "教會聖師聖亞豐索·利古力主教", .double)
        add(8, 3, "精修者聖尼哥德慕", .semiDouble)
        add(8, 4, "聖道明", .greaterDouble, 5)
        add(8, 5, "建立聖母雪地大殿 (紀念殉道者聖奧斯瓦爾德國王)", .greaterDouble, 10)
        add(8, 6, "基督易容顯光日", .doubleSecondClass, 5)
        add(8, 7, "耶穌至聖聖名日", .doubleSecondClass, 10)
        add(8, 8, "真福約翰·梅森·尼爾", .simple)
        add(8, 9, "聖約翰·維雅納 (紀念聖勞倫斯望日)", .semiDouble)
        add(8, 10, "殉道者聖勞倫斯會吏", .doubleSecondClass)
        add(8, 12, "童貞女聖克萊爾", .double)
        add(8, 13, "殉道者聖希坡律陀和聖卡西安", .simple)
        add(8, 14, "榮福童貞馬利亞升天望日 (紀念真福耶利米·泰勒主教)", .vigil)
        add(8, 15, "榮福童貞馬利亞升天日", .doubleFirstClass)
        add(8, 16, "聖約雅敬——聖母之父", .doubleSecondClass)
        add(8, 17, "榮福童貞馬利亞升天八日慶期第三日", .ordinaryOctavesemiDouble)
        add(8, 18, "聖海倫娜太后 (紀念榮福童貞馬利亞升天八日慶期第四日)", .double, 5)
        add(8, 19, "榮福童貞馬利亞升天八日慶期第五日", .ordinaryOctavesemiDouble)
        add(8, 20, "教會聖師聖伯納德院長 (紀念榮福童貞馬利亞升天八日慶期第六日)", .double, 10)
        add(8, 21, "聖簡·法蘭西斯·尚塔爾 (紀念榮福童貞馬利亞升天八日慶期第七日)", .double, 5)
        add(8, 22, "榮福童貞馬利亞升天八日慶期第八日", .ordinaryOctavegreaterDouble)
        add(8, 23, "使徒聖巴多羅買望日", .vigil)
        add(8, 24, "使徒聖巴多羅買日", .doubleSecondClass)
        add(8, 25, "聖路易九世國王", .semiDouble)
        add(8, 28, "教會聖師希坡的聖奧古斯丁主教", .double)
        add(8, 29, "施洗聖約翰殉道日", .greaterDouble)
        add(8, 30, "童貞女利馬的聖羅撒", .double)
        add(8, 31, "精修者聖艾登主教", .double)
        
        // ------------------ 9月 ------------------
        add(9, 1, "聖賈爾斯院長", .simple)
        add(9, 2, "匈牙利的聖王聖司提反", .semiDouble)
        add(9, 7, "聖艾烏爾提烏斯主教", .simple)
        add(9, 8, "榮福童貞女馬利亞誕辰日", .doubleSecondClass) // 已修正錯字
        add(9, 9, "聖彼得·克拉維爾", .double)
        add(9, 11, "殉道者聖普羅托與聖海厄森斯", .simple)
        add(9, 12, "聖母聖名日", .greaterDouble)
        add(9, 14, "聖十字架日", .greaterDouble)
        add(9, 15, "七苦聖母", .doubleSecondClass)
        add(9, 16, "殉道者聖居普良主教 (紀念聖尼安主教)", .semiDouble)
        add(9, 17, "聖法蘭西斯受五傷", .double)
        add(9, 18, "真福愛德華·布維萊·普西", .simple)
        add(9, 19, "坎特伯雷的聖西奧多主教", .double)
        add(9, 20, "傳福音使徒聖馬太望日 (紀念真福約翰·科爾里奇·帕特森主教)", .vigil)
        add(9, 21, "傳福音使徒聖馬太日", .doubleSecondClass)
        add(9, 22, "殉道者聖莫里斯及其同伴", .simple)
        add(9, 23, "殉道者聖利奴主教 (紀念童貞女聖德克拉)", .semiDouble)
        add(9, 24, "贖虜聖母", .greaterDouble)
        add(9, 25, "真福蘭斯洛特·安德魯斯主教", .simple)
        add(9, 27, "殉道者聖科斯馬斯和聖達米盎", .semiDouble)
        add(9, 28, "殉道者聖瓦茨拉夫", .semiDouble)
        add(9, 29, "聖米迦勒和諸天使日", .doubleFirstClass)
        add(9, 30, "教會聖師、精修者聖耶柔米", .double)

        // ------------------ 10月 ------------------
        add(10, 1, "聖雷米吉烏斯主教", .simple)
        add(10, 2, "守護聖天使", .greaterDouble)
        add(10, 3, "童貞女嬰孩耶穌聖德蘭", .double)
        add(10, 4, "阿西西的聖法蘭西斯", .greaterDouble)
        add(10, 5, "殉道者聖普拉西", .simple)
        add(10, 6, "聖布魯諾", .double)
        add(10, 7, "聖母玫瑰", .doubleSecondClass)
        add(10, 8, "聖婦彼濟達", .double)
        add(10, 9, "聖丹尼斯、聖魯斯蒂克斯和聖愛德雷", .semiDouble)
        add(10, 10, "約克的聖保利努斯主教", .semiDouble)
        add(10, 11, "上帝之母榮福童貞馬利亞", .doubleSecondClass)
        add(10, 12, "聖威爾弗里德主教", .semiDouble)
        add(10, 13, "敬遷殉道聖王愛德華之聖髑", .semiDouble)
        add(10, 14, "殉道者聖卡利斯托主教", .double)
        add(10, 15, "沃爾辛厄姆聖母", .doubleSecondClass)
        add(10, 16, "聖婦海德薇", .semiDouble)
        add(10, 17, "童貞女聖埃塞爾麗達", .semiDouble)
        add(10, 18, "傳福音的使徒聖路加", .doubleSecondClass)
        add(10, 19, "聖佛萊茲維德", .semiDouble)
        add(10, 21, "聖希拉里昂院長 (紀念聖厄休拉及其同伴)", .simple)
        add(10, 22, "新幾內亞殉道諸聖", .simple)
        add(10, 24, "天使長聖拉法勒", .greaterDouble)
        add(10, 25, "聖克里斯賓與聖克里斯毗尼安", .simple)
        add(10, 27, "使徒聖西門與聖猶大望日", .vigil)
        add(10, 28, "使徒聖西門與聖猶大日", .doubleSecondClass)
        add(10, 29, "烏干達殉道諸聖", .simple) // 原稿未標註等級，預設為簡式
        add(10, 31, "諸聖望日", .vigil)
        
        // ------------------ 11月 ------------------
        add(11, 1, "諸聖日", .doubleFirstClass)
        add(11, 2, "諸靈日", .double)
        add(11, 3, "諸聖八日慶期第三日", .ordinaryOctavesemiDouble)
        add(11, 4, "聖卡洛·博羅梅奧主教 (紀念諸聖日八日慶期第四日)", .double)
        add(11, 5, "聖伊麗莎白 (紀念諸聖八日慶期第五日)", .semiDouble)
        add(11, 6, "諸聖八日慶期第六日", .ordinaryOctavesemiDouble)
        add(11, 7, "聖威利布羅德主教 (紀念諸聖八日慶期第七日)", .double)
        add(11, 8, "安立甘諸聖", .greaterDouble)
        add(11, 9, "聖西奧多", .simple)
        add(11, 11, "聖馬丁主教", .double)
        add(11, 13, "圖爾的聖布萊斯主教", .semiDouble)
        add(11, 15, "教會聖師大聖阿爾伯特主教", .double)
        add(11, 16, "童貞女聖格特魯德", .double)
        add(11, 17, "倫斯特的聖胡格主教", .double)
        add(11, 18, "惠特比的聖希爾達院長", .semiDouble)
        add(11, 19, "匈牙利的聖婦伊麗莎白女王", .double)
        add(11, 20, "殉道聖王埃德蒙", .semiDouble)
        add(11, 21, "榮福童貞馬利亞奉獻日", .greaterDouble)
        add(11, 22, "殉道童貞女聖塞西莉亞", .double)
        add(11, 23, "羅馬的聖克萊門特主教", .double)
        add(11, 24, "十架聖約翰", .double)
        add(11, 25, "殉道童貞女亞歷山大的聖凱瑟琳", .double)
        add(11, 29, "使徒聖安得烈望日", .vigil)
        add(11, 30, "使徒聖安得烈日", .doubleSecondClass)
        
        // ------------------ 12月 (修正版：移除大對經) ------------------
        add(12, 1, "真福尼古拉·費拉爾執事", .simple)
        add(12, 2, "金言聖彼得主教", .double)
        add(12, 3, "聖法蘭西斯·沙勿略", .greaterDouble)
        add(12, 4, "亞歷山大的聖革利免", .double)
        add(12, 5, "聖薩巴斯院長", .simple)
        add(12, 6, "聖尼古拉斯主教", .double)
        add(12, 7, "聖安波羅修主教", .double)
        add(12, 8, "榮福童貞馬利亞始胎日", .doubleFirstClass)
        add(12, 9, "榮福童貞馬利亞始胎八日慶期第二日", .ordinaryOctavesemiDouble)
        add(12, 10, "榮福童貞馬利亞始胎八日慶期第三日", .ordinaryOctavesemiDouble)
        add(12, 11, "榮福童貞馬利亞始胎八日慶期第四日", .ordinaryOctavesemiDouble)
        add(12, 12, "榮福童貞馬利亞始胎八日慶期第五日", .ordinaryOctavesemiDouble)
        add(12, 13, "殉道童貞女聖露西 (紀念榮福童貞馬利亞始胎八日慶期第六日)", .double)
        add(12, 14, "榮福童貞馬利亞始胎八日慶期第七日", .ordinaryOctavesemiDouble)
        add(12, 15, "榮福童貞馬利亞始胎八日慶期第八日", .ordinaryOctavegreaterDouble)
    
        add(12, 20, "使徒聖多馬望日", .vigil)
        add(12, 21, "使徒聖多馬日", .doubleSecondClass)
        
        add(12, 24, "聖誕望日", .privilegedVigilFirstClass)
        add(12, 25, "聖誕日", .doubleFirstClass)
        add(12, 26, "聖司提反日", .doubleSecondClass)
        add(12, 27, "傳福音使徒聖約翰日", .doubleSecondClass)
        add(12, 28, "嬰孩被殺日", .doubleSecondClass)
        add(12, 29, "坎特伯雷的聖托馬斯大主教", .semiDouble)
        add(12, 30, "聖誕日八日慶期第六日", .privilegedOctaveThirdClass)
        add(12, 31, "聖西爾維斯特主教 (紀念聖誕日八日慶期第七日)", .double)
    }
}
