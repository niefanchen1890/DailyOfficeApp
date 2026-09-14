import Foundation

/// 使用者提供的兩週循環參考表；不參與日課的詩篇選用規則。
enum FortnightPsalmData {
    struct Office {
        let hour: String
        let psalms: String
    }
    struct Day {
        let day: String
        let offices: [Office]
    }
    struct Cycle {
        let title: String
        let weeks: [[Day]]
        let notes: [String]
    }
    static let introduction = "《公禱書》的主要優點之一，在於它將詩篇固定的編排為三十天誦讀一遍。這使人能以古代禮儀的精神，規律地誦念《詩篇》，而不致負擔過重。然而，有些人認為每月才誦讀一次《詩篇》，相隔太久，未能使人對《詩篇》有深切而熟悉的認識。因此，現提供這兩種可供選用的詩篇編排，作為補充使用。"
    static let cycles: [Cycle] = [
        .init(title: "兩週循環A", weeks: [
            [
                .init(day: "主日", offices: [.init(hour: "早禱", psalms: "63、93、66、96、67、97"), .init(hour: "晚禱", psalms: "84、104、85、119篇第VII–X段")]),
                .init(day: "禮拜一", offices: [.init(hour: "早禱", psalms: "1、6、2–3、7、5、8"), .init(hour: "晚禱", psalms: "69、71、70、72、119篇第XI–XIV段")]),
                .init(day: "禮拜二", offices: [.init(hour: "早禱", psalms: "9、12、10、13、11、14"), .init(hour: "晚禱", psalms: "73、75、74、76、77")]),
                .init(day: "禮拜三", offices: [.init(hour: "早禱", psalms: "15、17、16、18"), .init(hour: "晚禱", psalms: "78、80、79、81")]),
                .init(day: "禮拜四", offices: [.init(hour: "早禱", psalms: "19、21、20、22、23"), .init(hour: "晚禱", psalms: "82、86、83、87、88")]),
                .init(day: "禮拜五", offices: [.init(hour: "早禱", psalms: "24、27、25、28、26、29"), .init(hour: "晚禱", psalms: "89、92、90、94")]),
                .init(day: "禮拜六", offices: [.init(hour: "早禱", psalms: "30、32、31、33、34"), .init(hour: "晚禱", psalms: "101、103、102、105")])
            ], [
                .init(day: "主日", offices: [.init(hour: "早禱", psalms: "98、148、99、149、100、150"), .init(hour: "晚禱", psalms: "110、113、111、114、112、115")]),
                .init(day: "禮拜一", offices: [.init(hour: "早禱", psalms: "35、37、36、38"), .init(hour: "晚禱", psalms: "106、108、107、109")]),
                .init(day: "禮拜二", offices: [.init(hour: "早禱", psalms: "39、41、40、42、43"), .init(hour: "晚禱", psalms: "116、118、117、119篇第XV–XVIII段")]),
                .init(day: "禮拜三", offices: [.init(hour: "早禱", psalms: "44、47、45、48、46、49"), .init(hour: "晚禱", psalms: "119篇第XIX–XXII段、129、130、131")]),
                .init(day: "禮拜四", offices: [.init(hour: "早禱", psalms: "50、52、51、53、55"), .init(hour: "晚禱", psalms: "132、136、133、137、135、138")]),
                .init(day: "禮拜五", offices: [.init(hour: "早禱", psalms: "56、59、57、60、58、61"), .init(hour: "晚禱", psalms: "139、141、140、142、143")]),
                .init(day: "禮拜六", offices: [.init(hour: "早禱", psalms: "62、65、64、68"), .init(hour: "晚禱", psalms: "144、146、145、147")])
            ]
        ], notes: ["在上述編排中，詩篇盡可能依照古代西方日課經的模式安排。所涵蓋的範圍包括一切詩篇，惟日課規程之中已固定專用詩篇除外：一時禱的詩篇54篇及119篇第I–VI段，小時禱的詩篇120–128篇，以及寢前禱的詩篇4、91及134篇。"]),
        .init(title: "兩週循環B", weeks: [
            [
                .init(day: "主日", offices: [.init(hour: "早禱", psalms: "66、67、96、97"), .init(hour: "一時禱", psalms: "119篇第I–II段"), .init(hour: "三時禱", psalms: "19"), .init(hour: "六時禱", psalms: "20"), .init(hour: "九時禱", psalms: "21"), .init(hour: "晚禱", psalms: "110、111、112、113、114、115"), .init(hour: "寢前禱", psalms: "4、6")]),
                .init(day: "禮拜一", offices: [.init(hour: "早禱", psalms: "1、2、3、5、8"), .init(hour: "一時禱", psalms: "119篇第III段"), .init(hour: "三時禱", psalms: "23"), .init(hour: "六時禱", psalms: "24"), .init(hour: "九時禱", psalms: "25"), .init(hour: "晚禱", psalms: "69、71"), .init(hour: "寢前禱", psalms: "7")]),
                .init(day: "禮拜二", offices: [.init(hour: "早禱", psalms: "18"), .init(hour: "一時禱", psalms: "119篇第IV–V段"), .init(hour: "三時禱", psalms: "26"), .init(hour: "六時禱", psalms: "27"), .init(hour: "九時禱", psalms: "28"), .init(hour: "晚禱", psalms: "72、73、74"), .init(hour: "寢前禱", psalms: "10")]),
                .init(day: "禮拜三", offices: [.init(hour: "早禱", psalms: "30、31"), .init(hour: "一時禱", psalms: "119篇第VI段"), .init(hour: "三時禱", psalms: "29"), .init(hour: "六時禱", psalms: "33"), .init(hour: "九時禱", psalms: "40"), .init(hour: "晚禱", psalms: "77、79、80"), .init(hour: "寢前禱", psalms: "11、12")]),
                .init(day: "禮拜四", offices: [.init(hour: "早禱", psalms: "32、35、36"), .init(hour: "一時禱", psalms: "119篇第VII–VIII段"), .init(hour: "三時禱", psalms: "41"), .init(hour: "六時禱", psalms: "42"), .init(hour: "九時禱", psalms: "52"), .init(hour: "晚禱", psalms: "78"), .init(hour: "寢前禱", psalms: "13、14")]),
                .init(day: "禮拜五", offices: [.init(hour: "早禱", psalms: "9、22"), .init(hour: "一時禱", psalms: "119篇第IX段"), .init(hour: "三時禱", psalms: "53"), .init(hour: "六時禱", psalms: "54"), .init(hour: "九時禱", psalms: "56"), .init(hour: "晚禱", psalms: "81、83、86"), .init(hour: "寢前禱", psalms: "15、16")]),
                .init(day: "禮拜六", offices: [.init(hour: "早禱", psalms: "37、38"), .init(hour: "一時禱", psalms: "119篇第X–XI段"), .init(hour: "三時禱", psalms: "57"), .init(hour: "六時禱", psalms: "58"), .init(hour: "九時禱", psalms: "59"), .init(hour: "晚禱", psalms: "88、89"), .init(hour: "寢前禱", psalms: "17")])
            ], [
                .init(day: "主日", offices: [.init(hour: "早禱", psalms: "98、147、148、149、150"), .init(hour: "一時禱", psalms: "119篇第XII–XIII段"), .init(hour: "三時禱", psalms: "60"), .init(hour: "六時禱", psalms: "61"), .init(hour: "九時禱", psalms: "62"), .init(hour: "晚禱", psalms: "103、116、117、118"), .init(hour: "寢前禱", psalms: "34")]),
                .init(day: "禮拜一", offices: [.init(hour: "早禱", psalms: "39、43、44"), .init(hour: "一時禱", psalms: "119篇第XIV段"), .init(hour: "三時禱", psalms: "63"), .init(hour: "六時禱", psalms: "64"), .init(hour: "九時禱", psalms: "70"), .init(hour: "晚禱", psalms: "90、92、94、102"), .init(hour: "寢前禱", psalms: "91")]),
                .init(day: "禮拜二", offices: [.init(hour: "早禱", psalms: "45、46、47"), .init(hour: "一時禱", psalms: "119篇第XV–XVI段"), .init(hour: "三時禱", psalms: "75"), .init(hour: "六時禱", psalms: "76"), .init(hour: "九時禱", psalms: "82"), .init(hour: "晚禱", psalms: "105、106"), .init(hour: "寢前禱", psalms: "133、134")]),
                .init(day: "禮拜三", offices: [.init(hour: "早禱", psalms: "48、49、50"), .init(hour: "一時禱", psalms: "119篇第XVII段"), .init(hour: "三時禱", psalms: "84"), .init(hour: "六時禱", psalms: "87"), .init(hour: "九時禱", psalms: "93"), .init(hour: "晚禱", psalms: "107、108、109"), .init(hour: "寢前禱", psalms: "137、138")]),
                .init(day: "禮拜四", offices: [.init(hour: "早禱", psalms: "65、68"), .init(hour: "一時禱", psalms: "119篇第XVIII–XIX段"), .init(hour: "三時禱", psalms: "99"), .init(hour: "六時禱", psalms: "100"), .init(hour: "九時禱", psalms: "101"), .init(hour: "晚禱", psalms: "132、135、136"), .init(hour: "寢前禱", psalms: "140")]),
                .init(day: "禮拜五", offices: [.init(hour: "早禱", psalms: "51、55"), .init(hour: "一時禱", psalms: "119篇第XX段"), .init(hour: "三時禱", psalms: "120、121"), .init(hour: "六時禱", psalms: "122、123"), .init(hour: "九時禱", psalms: "124、125"), .init(hour: "晚禱", psalms: "139、143、144"), .init(hour: "寢前禱", psalms: "141")]),
                .init(day: "禮拜六", offices: [.init(hour: "早禱", psalms: "85、104"), .init(hour: "一時禱", psalms: "119篇第XXI–XXII段"), .init(hour: "三時禱", psalms: "126、127"), .init(hour: "六時禱", psalms: "128、129"), .init(hour: "九時禱", psalms: "130、131"), .init(hour: "晚禱", psalms: "145、146"), .init(hour: "寢前禱", psalms: "142")])
            ]
        ], notes: ["在這一編排中，早禱及晚禱的詩篇同樣遵循一般西方傳統的安排；小時禱則按照高盧日課經及庇護日課經的方式，採用可變動的詩篇週期。", "若在早禱及晚禱中慶祝有專用詩篇的節日，小時禱的詩篇仍應按照該禮拜幾的次序繼續誦讀。", "小時禱中詩篇所用的對經，一律按照日課規程所規定的通用或專用對經。", "在聖誕日、復活日及聖靈降臨日及其八日慶期內，並在逾越三日慶典之中，小時禱應誦念依照日課規程所規定的詩篇。"])
    ]
}
