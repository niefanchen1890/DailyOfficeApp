# 聖日通用 JSON 格式與繼承方案

## 本輪範圍

已整理 19 份通用文件，加入 common_office_index.json 精確 ID 索引、CommonOfficeResolver 合併器並接入 DailyOfficeLoader。雷米吉烏斯為第一個引用聖日；九月未引用通用的文件仍原樣載入。第一版採精確 ID，不自動切換季節，不批量遷移其他聖日。

## 資料格式

保留 identifier、name、vigil、morning、evening；type 改為 common_office。common_metadata.schema_version 為 1；categories 表示可引用的穩定類別；season 為 easter、outside_easter 或 unspecified。禮拜六特敬聖母的原始文件沒有季節標記，因此使用 unspecified，不能推定全年適用。requires_proper_collect 為 true：個別聖日須提供祝文。本輪刪除三個時辰中空白或錯置的帕科繆祝文，不編造替代正文。原始備份只用於本輪語義比對，最終資料不保留錯誤祝文。

通用的 name 僅描述資源，繁體為來源；簡體名稱缺失時使用現有繁體回退／顯示轉換。既有禮文的所有語言內容原樣保留。rank、rank_display 移除，通用不決定節日等級。

## 載入契約

聖日以 common_office 指定下表的精確 identifier，可先避免季節自動推斷。例如 common_office: common_confessor_bishop_outside_easter。日後增加類別索引時，由禮儀核心提供季節及實際慶祝日期；缺少季節資源應報錯，不能猜用其他類別。

讀取原始通用及專用 JSON → 合併三個時辰 → 語言解析 → DailyOfficeFile 解碼。元資料不繼承，聖日 identifier、name、rank、traits 一律來自專用／核心。紀念聖日亦走相同流程。中文檔名保留，資源索引須保存精確檔名，包括使徒復活期檔名的尾端空格。

- 專用缺少欄位：繼承通用。
- 結構物件：按欄位合併；陣列：整組取代。
- 多語言文字、祝文、聖詩：完整單位取代，避免通用與專用文字混搭。
- 專用 null：明確停用；空陣列：清空；空字串：保留空值，不表示繼承。
- 停用時辰的標記須保留到時辰選擇階段，不能被 vigil ?? evening 恢復。
- 通用有 vigil 不授予第一晚禱資格，資格仍由核心判定。
- lectionary_1943 獨立於普通對經，合併後才按公曆年份輪替。
- 祝文必須由引用聖日提供；驗證其實際使用時辰有有效祝文，不能忽略 requires_proper_collect。
- 未引用通用的舊聖日行為不變；已複製的共用文字須逐批核對並刪除，才能接收通用更新。
- 資源缺失、重複 ID、解碼失敗須回報檔名及路徑，不使用 fatalError，不靜默轉用另一份日課。
- 只允許聖日引用一份通用，通用不再引用通用，第一版避免循環和多重繼承。

## 後續驗證

驗證缺省繼承、專用覆蓋、null 停用、陣列替換、多語言整體覆蓋、季節邊界、第一晚禱與移節、1943 輪替、必填祝文及錯誤診斷。遷移代表聖日前後比對有效資料；修改通用後，繼承聖日同步更新，專用內容保持不變。快取需包含資源／季節／語言，切換語言後失效。

## 資源清單

| 精確檔名 | identifier | 季節 | 類別 |
|---|---|---|---|
| `一位殉道童貞女用（復活期內）.json` | `common_virgin_martyr_easter` | `easter` | `virgin_martyr` |
| `一位殉道童貞女用（復活期外）.json` | `common_virgin_martyr_outside_easter` | `outside_easter` | `virgin_martyr` |
| `一位殉道者通用（復活期外）.json` | `common_martyr_outside_easter` | `outside_easter` | `martyr` |
| `一位童貞女通用（復活期內）.json` | `common_virgin_easter` | `easter` | `virgin` |
| `一位童貞女通用（復活期外）.json` | `common_virgin_outside_easter` | `outside_easter` | `virgin` |
| `一位精修者通用（復活期內）主教、主教聖師.json` | `common_confessor_bishop_easter` | `easter` | `confessor_bishop,confessor_doctor_bishop` |
| `一位精修者通用（復活期內）非主教、非主教聖師.json` | `common_confessor_non_bishop_easter` | `easter` | `confessor_non_bishop,confessor_doctor_non_bishop` |
| `一位精修者通用（復活期外）主教.json` | `common_confessor_bishop_outside_easter` | `outside_easter` | `confessor_bishop` |
| `一位精修者通用（復活期外）教會聖師.json` | `common_confessor_doctor_outside_easter` | `outside_easter` | `confessor_doctor_bishop,confessor_doctor_non_bishop` |
| `一位精修者通用（復活期外）非主教.json` | `common_confessor_non_bishop_outside_easter` | `outside_easter` | `confessor_non_bishop` |
| `一位聖婦用（復活期內）.json` | `common_holy_woman_easter` | `easter` | `holy_woman` |
| `一位聖婦用（復活期外）.json` | `common_holy_woman_outside_easter` | `outside_easter` | `holy_woman` |
| `使徒用（復活期內） .json` | `common_apostle_easter` | `easter` | `apostle` |
| `使徒用（復活期外）.json` | `common_apostle_outside_easter` | `outside_easter` | `apostle` |
| `傳福音者用（復活期外）.json` | `common_evangelist_outside_easter` | `outside_easter` | `evangelist` |
| `多位殉道者通用（復活期內）.json` | `common_martyrs_easter` | `easter` | `martyrs` |
| `多位殉道者通用（復活期外）.json` | `common_martyrs_outside_easter` | `outside_easter` | `martyrs` |
| `多位精修者通用（復活期外）.json` | `common_confessors_outside_easter` | `outside_easter` | `confessors` |
| `禮拜六特敬聖母.json` | `common_saturday_office_of_our_lady` | `unspecified` | `saturday_office_of_our_lady` |

## 教會聖師通用的專用殘留

前夕 benedictus_antiphon 及早禱 invitatory 含帕科繆姓名，亦已移除。common_metadata.required_proper_fields 列出這兩項；載入器須檢查實際使用時辰的專用內容有提供相應欄位。未查證禮文前不自行替換姓名或編寫通用正文。

## 實作細節與限制

採用精確 ID 引用，季節欄位是資源說明；季節自動選擇尚未啟用。載入時要求每個非 null 且存在的時辰均有專用祝文，比只檢查當前時辰更嚴格，確保整份資源可解碼。null 前夕透過 disabledVigil 保留到時辰選擇，舊文件的缺省前夕仍可回退晚禱。索引由 19 份通用唯一 ID 建立，測試核對所有索引與 bundle 資源；通用不可巢狀引用。合併器沒有額外快取，沿用聖日載入器既有日期、身分、語言快取。診斷以 AppLog 輸出來源檔名及失敗路徑；尚未新增使用者介面的錯誤頁。

## 本輪驗證紀錄

通用合併／錯誤處理、雷米吉烏斯 bundle 載入與繁簡解碼、既有 1943 輪替共四項模擬器測試通過。獨立執行同一 Swift 合併器，核對 19 份通用及 26 份九月文件原始資料不變。未執行人工介面驗證或全資源 JSON 測試，不能宣稱全專案測試通過。

最後補齊晚禱直接讀取路徑及全九月 XCTest 後已重新編譯成功，但該次模擬器重跑啟動卡住，已中止；這部分不列為最終版本測試通過。前一輪四項 XCTest 通過，全部九月資料另以同一 Swift 合併器直接驗證通過。

## 1943 詩篇對經的季節版本

lectionary_1943 仍支援單一多語言文字或按年輪替的文字陣列。新增結構物件格式：normal 保存通常版本，septuagesima_to_lent 保存七旬主日至大齋期版本；兩者均可使用多語言文字或輪替陣列。先按實際禮儀日期選版本，再依公曆年份選取陣列項目。日期範圍由 LiturgicalDateCalculator 計算：復活節前 63 天至前一天（含聖週六）。復活節當日恢復 normal。第一晚禱使用呼叫端傳入的有效禮儀日期，不另加一天。

傳福音者通用的前夕、早禱使用此格式；晚禱維持固定對經。普通詩篇對經不受影響。中文特別版依使用者提供的語序，以「主如是說」起首；英文按禮規在末尾以 saith the Lord 取代 alleluia。
