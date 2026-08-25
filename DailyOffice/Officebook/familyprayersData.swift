import Foundation

// MARK: - 家用禱文段落模型
struct HomePrayerSection: Hashable {
    let title: String?           // 段落標題，如「主禱文」「祝文」
    let rubric: String?          // 禮規（¶ 開頭的說明文字）
    let preRubric: String?       // 前置禮規（如誦經提示）
    let paragraphs: [String]     // 正文段落
    let postRubric: String?      // 段後提示（如「¶ 此處可頌唸本日祝文」）
}

// MARK: - 早晚禱結構
struct HomePrayerPart: Hashable {
    let title: String            // 「早禱」或「晚禱」
    let mainRubric: String       // 主要禮規
    let sections: [HomePrayerSection]
}

// MARK: - 家用禱文資料
struct HomePrayerData {
    static let title = "家用禱文"
    
    // MARK: - 早禱
    static let morningPrayer = HomePrayerPart(
        title: "早祷",
        mainRubric: "¶ 家主命家中凡可聚集祷告者，皆来聚集；同跪，家主或家中一人，用以下之祷文。",
        sections: [
            // 誦經後短禱
            HomePrayerSection(
                title: nil,
                rubric: nil,
                preRubric: "¶ 诵读一段圣经后，念：",
                paragraphs: [
                    "上帝阿，你是我的上帝，求主早晨听我的声音，我早晨向主出声祷告，随后就盼望。"
                ],
                postRubric: nil
            ),
            
            // 主禱文
            HomePrayerSection(
                title: "主祷文",
                rubric: "¶ 众随领祷者诵念主祷文。",
                preRubric: nil,
                paragraphs: [
                    "我们在天上的父，愿人都尊父的名为圣。愿父的国降临。愿父的旨意行在地上，如同行在天上。日用的粮食，求父今天赐给我们。又求饶恕我们的罪，如同我们饶恕得罪我们的人。保佑我们不遇试探，拯救我们脱离凶恶。因为国度权柄荣耀，都是父的，永世无尽。阿们。"
                ],
                postRubric: "¶ 此处可诵念本日祝文。"
            ),
            
            // 讚美上帝之慈悲
            HomePrayerSection(
                title: "赞美上帝之慈悲感谢上帝保护我等过夜之文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "无所不能永生的上帝，我们生活动静都是倚靠主。我们从生下来直到现在，都是蒙主的保佑，昨天夜里又蒙拯救，脱离危险。所以我们恭敬感谢主，称颂主的圣名，这就是我们所献的祭物。伏求主看在我救主耶稣基督的面上，就是为我们死而复活的圣子，欢然收纳我们的祷告。阿们。"
                ],
                postRubric: nil
            ),
            
            // 敬獻靈魂身體
            HomePrayerSection(
                title: "敬献灵魂身体于主立志日新之文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "天父大发慈悲，又赐我们一天的生命。我们就献身体灵魂与主，立志自守，以公义虔敬度日。求慈悲的主，坚固我们的志向，叫我们的岁数越发加增，就越发得主的恩典，也就越发认识我救主耶稣基督。阿们。"
                ],
                postRubric: nil
            ),
            
            // 求主施恩
            HomePrayerSection(
                title: "求主施恩使我等依所立之志而行之文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "主知道我们的性情软弱顽钝，而且常常遭试探。求主怜悯我们，赐圣灵帮助我们，叫我们勉力做自己的本分，也不犯罪。又求主叫我们想主的刑罚，就怕得罪与主，又想主的恩典，就以得罪主为羞愧。更求主叫我们思想到了末日，我们的意念言语行为，都必定受审判。那时，上帝所设立审判生人死人的主，就是圣子我主耶稣基督。阿们。"
                ],
                postRubric: nil
            ),
            
            // 求主今日引導
            HomePrayerSection(
                title: "求主今日引导保护辅助我等行事之文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "特求主施恩，今日引导保护我们，教我们今天节制饮食，勤快做分内的事。若是遇见苦难，求主叫我们忍耐。求主施恩，叫我们做事，都要公道，为人也要安静和平，常怀着怜爱的心，量自己的力量，去做善事。又求主凡事开导我们，更保护我们和一切所有的不遇危险，不遇灾害。大发慈悲，顾恤我们，就像父亲待儿女一样。凡我们所求的，和主知道我们所需用的，惟愿主为圣子耶稣基督的大功劳，赐与我们。阿们。"
                ],
                postRubric: nil
            ),
            
            // 祝文
            HomePrayerSection(
                title: "祝福文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "至高至圣，三一上帝，圣父、圣子、圣灵；我们今将自己的身体与灵魂献给主，作个圣洁的活祭，是理所当然的；愿一切颂赞荣耀都归于主。阿们。",
                    "愿我们众人，常蒙我主耶稣基督的恩惠，上帝的慈爱，圣灵的感动。阿们。"
                ],
                postRubric: nil
            )
        ]
    )
    
    // MARK: - 晚禱
    static let eveningPrayer = HomePrayerPart(
        title: "晚祷",
        mainRubric: "¶ 将寝之先，家人聚集，同跪，家主或家中一人，用以下之祷文。",
        sections: [
            // 誦經後短禱
            HomePrayerSection(
                title: nil,
                rubric: nil,
                preRubric: "¶ 诵念一段圣经之后，诵念：",
                paragraphs: [
                    "惟愿我的祷告像香烟达到主前，我举手祈求，愿主当作晚祭。"
                ],
                postRubric: nil
            ),
            
            // 主禱文
            HomePrayerSection(
                title: "主祷文",
                rubric: "¶ 众随领祷者同跪，诵念主祷文。",
                preRubric: nil,
                paragraphs: [
                    "我们在天上的父，愿人都尊父的名为圣。愿父的国降临。愿父的旨意行在地上，如同行在天上。日用的粮食，求父今天赐给我们。又求饶恕我们的罪，如同我们饶恕得罪我们的人。保佑我们不遇试探，拯救我们脱离凶恶。因为国度权柄荣耀，都是父的，永世无尽。 阿们。"
                ],
                postRubric: "¶ 此处可诵念本日祝文。"
            ),
            
            // 認罪求赦
            HomePrayerSection(
                title: "认罪求赦之文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "大慈悲的上帝，主的眼睛，喜看清洁，不看罪恶，人若是认罪，也弃绝了罪，主必定赦免。我们现在谦卑到主面前，承认我们屡次犯罪，违背主的圣法。{{RED:此时略停片刻，等各人默认一天的罪过。}}但是天父是最慈悲，不愿罪人死亡，所以我们求天父，大施怜悯，眷顾我们，赦免我们的一切过犯。也求主叫我们晓得，罪是最恶的事，并感动我们，叫我们痛切悔改所犯的罪，才可以蒙主赦免，因为主常悦纳那虔诚悔改的人。这都是靠着圣子，我独一救主，基督的大功劳。阿们。"
                ],
                postRubric: nil
            ),
            
            // 求恩改過
            HomePrayerSection(
                title: "求恩改过之文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "我们软弱，也常遇见试探，深怕再犯罪恶，恳求主赐圣灵开导我们，帮助我们，改正我们心里的不善。叫我们心里不存邪情恶念私欲，除去我们妒忌恶毒的意念，叫我们不可含怒到日落。在将睡的时候，心里就要亲爱和睦，对主对人都存无亏的良心。这样，主必使我们清洁无疵，也保守我们，直到我主耶稣再降临的日子。阿们。"
                ],
                postRubric: nil
            ),
            
            // 代眾禱告
            HomePrayerSection(
                title: "代众祷告之文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "我们又为普天之下的人祈祷，求主允准。惟愿主用福音的光普照万民，叫他们信服顺从。又施恩典与主的教会，叫会中的人都安分守己，诚心事奉主。又求主赐福与一切执政掌权的人员，感化他们的心，叫他们信奉真道，公道管理百姓，赏善罚恶。又求主赐福气与我家里，和亲友邻里，叫他们的身体都平安，心里得圣灵的感化。至于一切善待我们的，求主赐福气与他们。虐待我们和喜欢我们有灾祸的，求主赦免他们，感化他们。又求主大发慈悲，看顾一切受灾难的人，照各人的苦处，施恩拯救他们，这都是靠着往日周流行善的圣子，我救主耶稣基督。阿们。"
                ],
                postRubric: nil
            ),
            
            // 感謝主
            HomePrayerSection(
                title: "感谢主之文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "我们感谢主，因为主赐各样的恩典与我们，教我们生活在世，知识通达，灵性百体都是全备，身体也无病无灾，又有亲友，也有衣食，和一切所用的东西。我们又特为感谢主，因为主差遣圣子，降生在世，救赎我们脱离罪恶永死，叫我们认识上帝，也知道向主当做的事。我们虽然常常干犯主怒，主却常常忍耐，赐圣灵开导帮助安慰我们。我们因为这些大慈悲，更称谢主，颂美主。又感谢主，因为我们从生下以来，常蒙主看顾我们，保护我们，也因主今天赐恩典与我们，特别感谢主。恳求主常将这些恩典赐与我们，使我们做事，能照救主的圣道，显出感谢的心。我们得这些恩典，都是靠着代求的圣子，我主耶稣基督的功劳。阿们。"
                ],
                postRubric: nil
            ),
            
            // 求主保佑過夜
            HomePrayerSection(
                title: "求主保佑过夜之文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "求主今夜施恩保佑我们，脱离危险惊扰。叫我们歇息的时候，身体畅快，明天早晨起来，精力强壮，做应当做的事。又叫我们在世日日行善，到了死的时候，就不惧怕，这样不论生死，都是属主。现在我们献这不周备的祷告，都是靠着我主耶稣基督。阿们。"
                ],
                postRubric: nil
            ),
            
            // 祝福文前可選誦念
            HomePrayerSection(
                title: nil,
                rubric: nil,
                preRubric: "¶ 在祝福文之前，可诵念：",
                paragraphs: [
                    "我得安逸去睡，因为主叫我安然居住。",
                    "主阿，祢在我们中间，我们是称为祢名下的人，求主我们的上帝不要离开我们。",
                    "主阿，醒时求祢引导，睡时求祢保护，这样，我们醒时可以与基督一同守候，睡时可以在平安里歇息。阿们。"
                ],
                postRubric: nil
            ),
            
            // 祝福文
            HomePrayerSection(
                title: "祝福文",
                rubric: nil,
                preRubric: nil,
                paragraphs: [
                    "求全能的主赐给我们一个平安的夜晚和完美的结束。愿全能的上帝，圣父、圣子、圣灵的赐福，与我们同在，从今夜直到永远。阿们。",
                    "愿我们众人，常蒙我主耶稣基督的恩惠，上帝的慈爱，圣灵的感动。阿们。"
                ],
                postRubric: nil
            )
        ]
    )
}
