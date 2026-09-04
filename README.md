# DailyOffice

DailyOffice 是一個以 SwiftUI 製作的 iOS 安立甘宗日課應用程式。它把每日禱告、禮儀日期、經課表、詩篇與聖經內容整合在同一個 App，並支援繁體中文與簡體中文。

這份文件同時是：

- 專案使用說明
- 程式架構地圖
- 資料維護注意事項
- 開發日記

## 目前狀態

- 開發分支：`feature/i18n-json-refactor`
- 開始本輪整理前的穩定備份點：`829185a`
- App 最低支援版本：iOS 17.6
- 介面技術：SwiftUI
- 主要資料來源：JSON

> `829185a` 是本輪修改開始前的安全參考點，不代表其後所有尚未提交的修改都已經包含在該版本內。進行較大的修改前，仍建議先建立新的 Git 備份點。

## 主要功能

### 日課與禱文

- 早禱 Morning Prayer
- 一時禱 Prime
- 三時禱 Terce
- 六時禱 Sext
- 九時禱 None
- 晚禱 Evening Prayer
- 寢前禱 Compline
- 家庭禱文 Family Prayers
- 連禱 Litany
- 懺悔禮文 Penitential Office

### 禮儀與經課

- 禮儀日曆與節期判定
- 1928 年經課表
- 1943 年經課表
- 1962 年經課表
- 日期、早晚禱、詩篇與讀經內容之間的連結

### 語言與經文

- 繁體中文／簡體中文切換
- 聖經正文由 JSON 載入
- 次經正文由 JSON 載入
- 語言切換時更新禮儀名稱、日課選單、家庭禱文與相關內容

## 用淺白方式理解程式架構

程式大致分為四層。可以把它想成一間餐廳：

| 程式部分 | 白話解釋 | 專案中的例子 |
| --- | --- | --- |
| View（顯示層） | 使用者真正看見及點擊的畫面 | `HomeView`、`MorningPrayerView`、`LectionaryView` |
| Model（資料格式） | 規定一筆資料應該有哪些內容 | 禮儀日、經課、禱文、詩篇等資料結構 |
| Service／Loader（邏輯與載入層） | 找檔案、讀資料、依日期與規則選出正確內容 | `LiturgyCoreService`、`BibleJSONService`、`DailyLectionaryService` |
| JSON（文字資源） | 存放實際禱文、經文、經課與節期資料 | `Data`、`Resources` 內的 `.json` 檔案 |

這樣拆分的目的，是讓「文字資料」、「日期判斷」和「畫面外觀」不必全部擠在同一個 Swift 檔案裡。

## 主要目錄

```text
DailyOffice/
├── DailyOfficeApp.swift          App 啟動入口
├── HomeView.swift                首頁與主要功能入口
├── ContentView.swift             禮儀日曆及日課選擇
├── AppLanguageStore.swift        繁體／簡體語言狀態
├── LectionaryView.swift          經課表畫面
├── LectionaryJSONService.swift   1928／1962 經課 JSON 載入
├── LiturgicalCalendar/           禮儀日期、節期、顏色與名稱
├── Officebook/                   各時辰日課、經文與讀取邏輯
├── Data/                         共用 JSON 資料
└── Resources/                    聖經、經課、聖人日及其他文字資源

DailyOfficeTests1/
├── JSONResourceValidationTests.swift  所有 JSON 格式檢查
└── LiturgyDateTests.swift              重要禮儀日期檢查
```

## 主要資料流程

### 語言切換

1. 使用者在設定中選擇繁體或簡體。
2. `AppLanguageStore` 保存目前語言。
3. 依賴語言的暫存資料會被清除。
4. 畫面重新取得對應語言的內容。
5. 雙語 JSON 優先選擇 `zh-hant` 或 `zh-hans`；只有單一中文版本的資料，才在載入層進行必要的文字轉換。

### 禮儀日期

1. 畫面把使用者選擇的日期交給 `LiturgyCoreService`。
2. 服務判斷固定節日、復活節相關移動節日、將臨期及節期優先次序。
3. 計算結果交回禮儀月曆、早晚禱及其他需要節期資料的畫面。

### 經課與經文

1. 使用者選擇日期、經課版本及早禱或晚禱。
2. 經課服務從相應的 1928、1943 或 1962 JSON 找出讀經範圍。
3. 詩篇連結交給詩篇閱讀畫面。
4. 聖經及次經範圍交給 `BibleJSONService`，再從 JSON 取得正文。

## JSON 資料規則

JSON 是一種讓程式容易閱讀的文字格式。它對標點非常嚴格，一個多餘的逗號、缺少的引號或括號，都可能使整份檔案無法載入。

維護資料時請遵守以下原則：

- JSON 最後一項後面不要加逗號。
- 成對使用 `{ }`、`[ ]` 和英文雙引號 `" "`。
- 同一個 App 資源內避免出現完全相同的檔名；即使位於不同資料夾，Xcode 打包時仍可能發生衝突。
- 經課檔名必須遵守載入服務所預期的命名方式。
- 繁體／簡體雙語欄位使用 `zh-hant` 與 `zh-hans`。
- 程式用來辨識資料的代號不要翻譯，只翻譯顯示給使用者看的文字。
- 範本與尚未完成的資料，也必須保持合法 JSON；否則全資源測試會失敗。

## 如何開啟及執行

1. 用 Xcode 開啟 `DailyOffice.xcodeproj`。
2. 在 Xcode 上方選擇一部實際 iPhone，或一個具體的 iPhone Simulator。
3. 不要選擇 `Any iOS Device` 執行測試，因為測試需要一部具體裝置。
4. 按 `Command + R` 執行 App。
5. 按 `Command + U` 執行全部測試。

若只想執行一組測試，可在 Xcode 左側 Test Navigator 點擊測試名稱旁的小菱形按鈕。

## 自動測試

### 禮儀日期測試

`LiturgyDateTests` 會檢查：

- 固定節日
- 復活節
- 聖灰日
- 升天日
- 五旬節
- 三一主日
- 將臨期第一主日

目前已用 2024 至 2026 年的重要日期作交叉檢查。2026 年 9 月 3 日執行結果為 7 項測試全部通過。

### 所有 JSON 格式測試

`JSONResourceValidationTests` 會逐一打開 App 內的 JSON，確認每一份檔案在語法上能被程式閱讀。

這項測試目前仍可能顯示紅色失敗，原因是部分原始資料或範本尚未完成，並不代表禮儀日期測試失敗。修復 JSON 已按開發安排暫緩；完成資料後，目標是讓此測試變成全數通過。

這項測試只回答「檔案格式是否完整」，不會判斷禱文內容是否正確、經文章節是否引用正確，或繁簡用詞是否合適。這些內容仍需要另一層資料測試及人工校對。

## 開發日記

### 穩定基準

- 分支：`feature/i18n-json-refactor`
- Commit：`829185a`
- 用途：本輪 JSON、繁簡語言及架構整理之前的穩定備份點。

### 2026-09-02：專案盤點與資料安全檢查

- 重新整理主要 View、Model、Service 與 JSON 資料流。
- 建立「所有 JSON 格式是否合法」的自動測試。
- 修正測試最初找不到 JSON 的掃描路徑問題。
- 測試成功掃描數千份 JSON，並找出尚未完成或格式錯誤的資料。
- 因原始 JSON 尚未齊全，決定先保留報告，延後修復內容。

### 2026-09-02：統一繁簡語言管理

- 以 `AppLanguageStore` 集中管理繁體／簡體選擇。
- 語言切換時清除依賴語言的暫存資料，減少畫面仍顯示舊語言的情況。
- 逐步讓日課、禮儀名稱、選單與資料載入使用同一個語言來源。

### 2026-09-02：聖經、次經與每日經課改用 JSON

- 聖經正文改為從 JSON 讀取。
- 次經正文改為從 JSON 讀取。
- 1928 與 1962 每日經課由資料庫改為 JSON。
- 因不同資料夾內曾有相同檔名，Xcode 打包時出現數百個 `Multiple commands produce`；資料檔重命名後，載入程式亦配合新的唯一檔名。
- 舊資料庫檔案及相關殘留物仍應在確認完全沒有使用後再清理。

### 2026-09-02 至 2026-09-03：程式結構與除錯訊息整理

- 將三時、六時、九時禱的重複畫面與邏輯整理為共用的小時禱結構。
- 集中正式執行時的程式紀錄，避免大量零散的除錯輸出。
- 修正 `AppLog` 的 autoclosure 編譯問題。
- 整理未使用變數、Swift 並行規則及 iOS 17 `onChange` 舊寫法等黃色警告。
- 分析 `cannot add handler to 0 from 0 - dropping` 等系統主控台訊息；這類訊息未證實是日課內容錯誤，仍應以 App 是否閃退、卡住或功能異常作主要判斷。

### 2026-09-03：補齊繁簡切換

- 禮儀月曆跟隨 App 語言設定切換繁簡。
- 安立甘日課經頁面跟隨語言設定切換繁簡。
- 家庭禱文拆分為 JSON 文字、資料邏輯層與顯示層。
- 家庭禱文加入繁體／簡體切換。

### 2026-09-03：禮儀日期測試

- 建立固定節日與復活節週期的自動測試。
- 覆蓋 2024、2025、2026 三個年份的重要日期。
- 7 項測試全部通過；完整測試套件仍會受未修復 JSON 測試影響而顯示失敗。

### 2026-09-03：經課表及詩篇導覽

- 修復 1943 經課表點擊詩篇沒有反應的問題。
- 找出同一列放置多個導覽連結會造成畫面堆疊、返回時逐頁倒退的原因。
- 改為由經課表統一管理目前選中的詩篇，每次只開啟一個詩篇頁面。
- 檢查 1943 經課資料中的詩篇連結，包含單篇與跨範圍情況。
- 修正一筆把「詩篇 21」與「詩篇 24」誤連在一起的資料。
- 將 1928、1962 經課表畫面整理為接近 1943 經課表的卡片樣式。
- 為 1943 經課表加入如 1928 經課表般的節期大標題。

### 2026-09-03：詩篇對經位置

- 統一各時辰日課的詩篇顯示順序。
- 每篇詩篇第一個對經放在詩篇標題之下、第 1 節之前。
- 詩篇結束後的對經仍保留在榮歸頌之後。

### 2026-09-03：大齋首日懺悔文三層拆分

- 將原本寫在 `PenitentialServiceData.swift` 裡的標題、禮規、經句、啟應、禱文及聖詩移到 `penitential_service.json`。
- `PenitentialServiceData.swift` 負責定義資料格式、讀取 JSON、繁簡轉換及載入詩篇第 51 篇。
- `PenitentialServiceView.swift` 只保留畫面排列及顯示方式。
- 懺悔文現在會跟隨全 App 的繁體／簡體設定即時更新。

### 2026-09-03：禮儀核心穩定識別碼第一階段

- 建立 `LiturgicalID`，作為不隨繁簡名稱改變的禮儀日「身分證號碼」。
- `DailyLiturgy`、固定聖日 `Feast` 與核心內部節期日開始提供 identifier。
- 先涵蓋三一主日、顯現日、升天日、五旬節、聖心節、寶血節、聖保羅紀念及核心直接引用的特殊八日慶日。
- 將第一批特殊規則由中文 title 比較改為 identifier 比較，同時保留舊 title 作相容及畫面顯示。
- 新增 identifier 對照、括號紀念及實際日期輸出測試。

### 2026-09-03：禮儀核心穩定識別碼第二階段

- `DailyLiturgy`、`TemporalDay`、`Feast` 都在建立時固定保存 identifier，不再於每次使用時重新由中文名稱計算。
- 保留 `mainTitle`、`title`、`name` 等舊文字欄位，既有畫面及資料建立方式不需要立即重寫。
- 舊程式若尚未傳入 identifier，會暫時由舊標題自動補上，讓改造可以分階段進行。
- 清理固定聖日括號紀念文字時會保留原 identifier，避免改過顯示名稱後改變節期身分。
- 完整測試版本編譯成功。

### 2026-09-03：禮儀核心穩定識別碼第三階段

- 為復活日、大齋首日、降臨第一主日與聖誕日補上穩定 identifier。
- 新增跨 2024、2025、2026 年的 identifier 測試，覆蓋復活日、升天日、聖靈降臨日及三一主日。
- 新增「顯示名稱可以改變，但 identifier 不變」測試，分別檢查 `DailyLiturgy`、`TemporalDay` 與 `Feast`。
- 測試程式及 App 均成功編譯；重新建立可用模擬器後，identifier 測試亦已實際執行通過。

### 2026-09-03：禮儀日期計算器第四階段

- 建立獨立的 `LiturgicalDateCalculator`，只處理日期數學，不載入 JSON、不處理顯示文字，也不判斷節期優先次序。
- 集中計算復活日、大齋首日、升天日、聖靈降臨日、三一主日與降臨第一主日。
- `LiturgyCoreService` 改為使用日期計算器，移除核心內重複的復活日、降臨日及日期間隔公式。
- 原有多年份禮儀日期測試改為直接檢查日期計算器，使日期公式可獨立驗證。
- App 與測試程式完整編譯成功；`LiturgyDateTests` 共 12 項測試全部通過。

### 2026-09-03：第一晚禱判斷器第五階段

- 建立獨立的 `FirstVespersResolver`，集中判斷第一晚禱資格與望日性質。
- 第一晚禱資格改用穩定 identifier 和 `LiturgicalRank`，不再搜尋中文名稱中的「望日」「八日慶期」或「第八日」。
- 核心中的今日望日、明日第一晚禱資格及明日望日判斷，統一交給新判斷器。
- 保留三一主日八日慶期禮拜一至三及聖保羅紀念等 identifier 特例。
- 新增顯示名稱無關、特殊 identifier 例外及望日等級測試；`LiturgyDateTests` 共 15 項全部通過。

### 2026-09-03：優先次序與遷移判斷器第六階段

- 建立獨立的 `LiturgicalPrecedenceResolver`，集中處理兩個同等級禮儀日相遇時，應採用今日還是明日禮儀的判斷。
- 優先次序先比較穩定 identifier、固定節日或移動節日的性質，以及原有數字優先值，不再由中文顯示名稱決定核心結果。
- 建立獨立的 `LiturgicalTransferResolver`，集中處理普通望日由主日移至禮拜六、以及主日移除已遷移望日的規則。
- `LiturgyCoreService` 保留資料整合工作，實際規則改交給兩個可獨立測試的判斷器。
- 新增同等級優先次序與普通望日遷移測試；`LiturgyDateTests` 共 19 項全部通過。
- 括號內舊紀念資料仍暫時保留「望日」文字辨認作相容處理，待日後把例外資料正式結構化後即可移除。

### 2026-09-03：集中禮儀例外規則第七階段

- 建立 `LiturgicalRuleTable`，作為核心特殊規則的單一登記處。
- 集中沒有第一晚禱、當日晚禱改用明日、晚禱禁止帶入紀念、同級節期特殊優先關係及特殊固定日期。
- `FirstVespersResolver`、`LiturgicalPrecedenceResolver` 與 `LiturgyCoreService` 改為共用規則表，不再各自保存重複的例外清單。
- 規則表使用穩定 identifier；繁簡顯示名稱改變時，不會改變這些核心判斷。
- 加入規則表完整性測試；`LiturgyDateTests` 共 21 項全部通過。
- 尚未結構化的括號文字和少數舊節期名稱仍保留相容解析，後續可隨 JSON identifier 補齊逐步移除。

### 2026-09-03：望日、八日慶期與齋期結構化第八階段

- 建立 `LiturgicalTraits`，用明確欄位保存禮儀特徵，不再要求使用者從中文標題猜測規則。
- 望日分為普通望日、一等特權望日及二等特權望日。
- 八日慶期保存是否屬於八日慶期及第幾日；可直接判斷是否為第八日。
- 齋期分為降臨期、大齋期、特禱日、夏季齋期及秋季齋期。
- `DailyLiturgy`、`TemporalDay`、`Feast` 都加入 traits，舊資料則暫由單一相容轉換器補足。
- 第一晚禱、望日遷移、八日慶期第八日及秋季齋期的第一批核心判斷已改用 traits。
- 測試曾成功找出中文「望日」造成的誤判，修正後望日改由 identifier 或 rank 判斷。
- 實際日期及不依賴中文標題的特徵測試均已加入；`LiturgyDateTests` 共 24 項全部通過。

### 2026-09-03：紀念項目資料模型第九階段

- 建立 `LiturgicalCommemoration`，每個紀念項目正式保存 identifier、顯示文字及禮儀 traits。
- `DailyLiturgy` 內部改為保存 `commemorationItems` 與 `parentheticalCommemorationItems`，不再只保存純文字。
- 現有 SwiftUI 畫面暫時保留舊文字介面，因此不需要一次重寫所有早禱、晚禱和月曆畫面。
- 舊純文字紀念統一在資料模型入口轉換，不再要求各畫面自行猜測 identifier。
- 核心晚禱的望日及八日慶期紀念過濾開始使用 traits；已知來源的紀念在合併時會保留原 identifier。
- 新增結構化紀念與舊資料相容測試；`LiturgyDateTests` 共 26 項全部通過。

### 2026-09-03：紀念項目資料模型第十階段

- 為核心仍會辨認的主日、望日、八日慶期及特殊聖日補上穩定 identifier，包括七旬至五旬主日、苦難主日、棕樹主日、升天後主日、基督聖體節、基督君王節及聖巴拿巴日等。
- `LiturgyCoreService` 用來合併今日、明日及括號紀念的暫存陣列，已統一改為 `[LiturgicalCommemoration]`。
- 晚禱過濾改用 identifier 與 traits；紀念在合併和刪除期間不再退回純文字判斷，也不會遺失原有 identifier。
- 舊的 `commemorations: [String]` 僅保留為畫面相容的唯讀輸出，已不再作為核心內部的累積資料。
- 新增主日與特殊節期 identifier 測試；`LiturgyDateTests` 共 28 項全部通過。

### 2026-09-03：禱文、經課與介紹資源選擇第十一階段

- 建立集中式 `LiturgicalResourceResolver`，用穩定 identifier 對應實際 JSON 檔名。
- `DailyOfficeLoader` 會先按 identifier 選擇專日檔；該檔中的禱文、詩篇、經課和對經因此不再依賴繁體中文標題。
- 專日快取鍵也改用 identifier，切換繁簡顯示名稱不會建立兩份不同快取。
- 聖巴拿巴遷移日的專日選擇改用 `.barnabas`，不再搜尋名稱中的中文字。
- 月曆主項及紀念項目的介紹檔案，優先使用各自的 identifier；紀念按鈕直接使用 `LiturgicalCommemoration`，不再先把資料降成純文字。
- 尚未取得正式 identifier 的舊資料仍保留集中式相容回退，避免現有內容突然無法載入。
- 新增資源選擇測試；`LiturgyDateTests` 共 29 項全部通過。

### 2026-09-03：移除中文標題業務判斷第十二階段

- 一般節期日加入結構化 identifier，直接保存 season、week 與 weekday，不再需要從「第幾主日／禮拜幾」中文字樣反推。
- 加入 `LiturgicalTheme`，結構化保存聖母、殉道者、使徒、十架、施洗約翰誕辰、聖心、易容顯光、基督君王及諸聖等主題。
- 晨禱與晚禱選句、教父讀經、小時禱與一時課聖詩結尾、晚禱專用對經及禮儀顏色，改用 identifier、traits、theme、season 或日期差判斷。
- 月曆的介紹、彌撒經文按鈕與固定聖日辨認不再解析中文標題；舊的重複 `feastIdentifier`／`getIdentifier` 函式已刪除。
- 刪除一組未被使用、仍靠中文名稱模糊比對的舊固定聖日示例程式。
- 中文文字解析只保留在舊資料進入結構化模型的相容邊界，不再散落於業務流程。
- 新增一般週次 identifier 與 theme 測試；`LiturgyDateTests` 共 30 項全部通過。

### 2026-09-03：9月2日聖日 JSON 結構化試轉

- 以 `sanctorale_0902_stephen_of_hungary.json` 作為第一份固定聖日試轉範本。
- JSON identifier 從檔名式名稱改為穩定的 `st_stephen_hungary`。
- JSON 新增 traits，明確標記為精修者（confessor）及君王（sovereign）。
- Swift 的 `LiturgicalID`、`Sanctorale` 聖日表及 `LiturgicalResourceResolver` 使用同一個 identifier。
- `DailyOfficeFile` 現在可以直接解碼 JSON 中的結構化 traits。
- 新增實際 Bundle JSON 解碼測試，確認日期、資源檔、identifier 及 themes 能互相對應。

### 2026-09-03：9月7日聖日 JSON 結構化試轉

- 將 `sanctorale_0907_evurtius.json` 的 identifier 改為穩定的 `st_evurtius`。
- JSON traits 標記為主教（bishop）與精修者（confessor）。
- `LiturgicalID`、`Sanctorale` 及 `LiturgicalResourceResolver` 使用相同 identifier。
- 新增實際 Bundle 解碼測試，確認9月7日日期、檔案、identifier 與 themes 一致。

### 2026-09-03：9月8日聖母誕辰日 JSON 結構化

- 將 `sanctorale_0908_nativity_of_mary.json` 的 identifier 改為穩定的 `nativity_of_mary`。
- JSON traits 明確標記為聖母主題（blessedVirginMary）。
- `LiturgicalID`、`Sanctorale` 及 `LiturgicalResourceResolver` 使用相同 identifier。
- 新增實際 Bundle 解碼測試，確認9月8日日期、檔案、identifier 與 themes 一致。

### 2026-09-03：9月9日聖彼得・克拉維爾 JSON 結構化

- 將 `sanctorale_0909_peter_claver.json` 的 identifier 改為穩定的 `st_peter_claver`。
- JSON traits 明確標記為精修者（confessor）。
- `LiturgicalID`、`Sanctorale` 及 `LiturgicalResourceResolver` 使用相同 identifier。
- 新增實際 Bundle 解碼測試，確認9月9日日期、檔案、identifier 與 themes 一致。

### 2026-09-03：9月11日聖普羅托與聖海厄森斯 JSON 結構化

- 將 `sanctorale_0911_protus_and_hyacinth.json` 的 identifier 改為穩定的 `sts_proto_hyacinth`。
- JSON traits 明確標記為殉道者（martyr）。
- `LiturgicalID`、`Sanctorale` 及 `LiturgicalResourceResolver` 使用相同 identifier。
- 新增實際 Bundle 解碼測試，確認9月11日日期、檔案、identifier 與 themes 一致。

### 2026-09-03：完成9月15日至30日聖日 JSON 結構化

- 一次完成9月15日至30日共18份專用聖日 JSON，加入穩定 identifier 與結構化 traits。
- 完成主聖日及同日紀念的 identifier、`Sanctorale` 日期登記和 `LiturgicalResourceResolver` 檔名對照。
- 新增童貞女、傳福音者、教會聖師及天使四種結構化主題。
- 修正9月22日聖莫里斯檔案誤用聖帕科繆 identifier，以及 Patteson 英文代號拼寫錯誤。
- 新增表格式 Bundle 測試，一次驗證18份檔案的 identifier、themes、日期及資源對照。

### 2026-09-03：三一後第13週禮拜四 JSON 結構化試轉

- 確認節期本位（Temporal）JSON 也需要逐步轉換，才能完全停止從中文標題反推週次與星期。
- 將 `temporal_trinity_13_thursday.json` 的 identifier 改為 `temporal.trinity.week.13.weekday.5`。
- 新增 temporal 結構，明確保存 season、week 和 weekday，並加入空的 traits 結構。
- `LiturgicalResourceResolver` 現在可由一般節期 identifier 自動產生對應 JSON 檔名。
- `DailyOfficeFile` 新增可選的 temporal metadata，舊 JSON 沒有此欄位時仍可正常解碼。
- 新增 Bundle 解碼測試，確認 identifier、結構化日期資料和實際檔名一致。

### 2026-09-03：完成三一後第13週 JSON 結構化

- 按同一格式轉換第13週剩餘六份 JSON：主日、禮拜一、二、三、五及六。
- 七份文件的 identifier 現在統一為 `temporal.trinity.week.13.weekday.N`。
- 每份文件都明確保存 temporal season、week、weekday 及 traits。
- 修正禮拜六主標題誤寫成「三一主日後第七主日禮拜六」的舊資料錯誤。
- 新增整週七份 Bundle JSON 逐一解碼測試，避免漏改、星期編號錯置或 identifier 與檔名不一致。

### 2026-09-03：完成三一後第14週 JSON 結構化

- 將 `temporal_trinity_14` 全週七份 JSON 改用穩定 identifier：`temporal.trinity.week.14.weekday.1...7`。
- 每份文件都加入 temporal season、week、weekday 及 traits 結構化資料。
- 修正禮拜六主標題誤寫成「三一主日後第七主日禮拜六」的舊資料錯誤。
- 新增整週七份 Bundle JSON 逐一解碼測試。

### 2026-09-03：完成三一後第15週 JSON 結構化

- 將 `temporal_trinity_15` 全週七份 JSON 改用穩定 identifier：`temporal.trinity.week.15.weekday.1...7`。
- 每份文件都加入 temporal season、week、weekday 及 traits 結構化資料。
- 修正禮拜六主標題誤寫成「三一主日後第七主日禮拜六」的舊資料錯誤。
- 新增整週七份 Bundle JSON 逐一解碼測試。

### 2026-09-03：完成三一後第16週 JSON 結構化

- 將 `temporal_trinity_16` 全週七份 JSON 改用穩定 identifier：`temporal.trinity.week.16.weekday.1...7`。
- 每份文件都加入 temporal season、week、weekday 及 traits 結構化資料。
- 修正禮拜六主標題誤寫成「三一主日後第七主日禮拜六」的舊資料錯誤。
- 新增整週七份 Bundle JSON 逐一解碼測試。

### 2026-09-03：完成三一後第17週 JSON 結構化

- 將 `temporal_trinity_17` 全週七份 JSON 改用穩定 identifier：`temporal.trinity.week.17.weekday.1...7`。
- 每份文件都加入 temporal season、week、weekday 及 traits 結構化資料。
- 修正禮拜六主標題誤寫成「三一主日後第七主日禮拜六」的舊資料錯誤。
- 新增整週七份 Bundle JSON 逐一解碼測試。

### 2026-09-03：完成三一後第18週 JSON 結構化

- 將 `temporal_trinity_18` 全週七份 JSON 改用穩定 identifier：`temporal.trinity.week.18.weekday.1...7`。
- 每份文件都加入 temporal season、week、weekday 及 traits 結構化資料。
- 修正禮拜六主標題誤寫成「三一主日後第七主日禮拜六」的舊資料錯誤。
- 新增整週七份 Bundle JSON 逐一解碼測試。

## 已知問題與待辦事項

依目前風險與影響，建議按以下次序處理：

1. 補齊並修復不合法 JSON，讓全資源格式測試通過。
2. 建立「資料內容是否合理」測試，例如必填欄位、經文章節、詩篇編號及經課引用是否存在。
3. 增加語言切換測試，確認所有畫面在切換後立即更新，而且不混用繁簡。
4. 增加經課表導覽測試，特別是詩篇跳轉及返回路徑。
5. 擴充禮儀規則測試，包括節日相撞、優先次序、第一晚禱及更多年份。
6. 人工校對自動繁簡轉換後的教會專有名詞。
7. 確認舊資料庫及舊載入程式已無使用，再安全移除，避免 App 體積與維護負擔增加。
8. 發布前補上資料來源、授權方式、隱私說明及版本紀錄。

## 每次修改後的簡單檢查清單

- App 能否成功編譯及開啟？
- 繁體與簡體能否正常切換？
- 早禱、晚禱及各小時禱能否顯示？
- 經課能否開啟正確的詩篇及聖經內容？
- 返回按鈕能否直接回到原來的經課表？
- `LiturgyDateTests` 是否全部通過？
- 新增或修改的 JSON 是否通過格式測試？
- 是否先建立了可返回的 Git 備份點？

## 文件維護方式

每完成一項較大的功能或修復，請在「開發日記」加入：

- 日期
- 修改了什麼
- 為什麼要修改
- 如何確認結果
- 是否仍有未完成部分

這能讓不熟悉程式碼的人，也可以從 README 看懂專案目前做到哪裡，以及下一步應先處理什麼。
