# 5 月 14 日至 9 月底聖日通用遷移與保留差異報告

日期：2026-09-11。此報告依本次修改前的工作目錄內容比對，並非拿 Git HEAD 代替原檔。

## 結果

- 掃描 128 份聖日 JSON；轉換 69 份，其餘 59 份保留原狀。
- 已轉換檔案：945,088 → 654,815 bytes，減少 290,273 bytes。
- 19 份通用逐時辰檢查：9 份補入 27 個 `lectionary_1943` 三語空物件；原有對經及季節分支不變。
- 原檔 identifier、name、rank、traits、祝文與其他非時辰資料原樣保留；未順便修正既有複製錯誤或重新分類聖日。

## 比對及保留規則

- 依現有 CommonOfficeResolver 的實際合併行為處理，不修改解析器。物件按欄位繼承；陣列、聖詩與祝文為整組覆蓋。
- 使用者已允許：原本單一繁體字串若與通用繁體完全一致，可改為繼承通用的翻譯。原檔已有翻譯只要不同，仍保留，不把標點差異當成相同。
- 祝文始終保留；required_proper_fields 指定的專用欄位始終保留。
- 1943 詩篇對經沒有本日專用時，省略 `lectionary_1943` 並繼承通用，不得加入 null 阻擋。原本明確停用的整個時辰仍保留停用規則。
- 原檔缺省前夕但可以回退晚禱的情況不強制轉為 null；不能保證回退等效者列為待確認。
- 若聖詩／陣列內只有一部分相同，整組仍須保留。下方只列真正不同的子欄位；未列出的相同子欄位可能因整組覆蓋仍存在。
- 不把「最相似」自動當成正確通用：類別、季節或聖母通用用途有疑問者列入未轉換清單。

## 驗證

- 69 份候選以實際 Swift CommonOfficeResolver 合併，結果逐欄比對預期；使用目前 DailyOfficeFile 模型完成繁體、簡體、英文解碼及重新編碼比對。
- 初次遷移檢查了繁體與原檔一致；其後依使用者更正，原來沒有本日專用的 1943 對經改為繼承通用，因此可能新增通用對經顯示。已有專用對經不變。
- 核對 firstVespersPeriod，確保缺省／停用及回退行為相同；未宣稱全 App 建置、全資源測試或模擬器驗證完成。
- 修改前原檔與候選暫存於 `/private/tmp/common-migration-20260911/`；此為本機臨時備份，非永久版本紀錄。

## 2026-09-11 更正：沒有專用 1943 對經時繼承通用

- 已移除 59 份聖日 JSON 共 170 個本輪遷移加入的 `lectionary_1943: null`；刪除後若 `psalm_antiphons` 為空，連同空容器移除。
- 通用有正文時載入通用；通用目前是三語空欄位時不顯示，日後補上內容即可自動使用。
- 本次只更正 1943 對經的繼承，不改動原有專用對經、祝文、其他覆蓋欄位及整個時辰的停用設定。
- 上方初次檔案大小統計及「原顯示一致」的紀錄描述初次遷移；本節為最新行為，以此節及下方更新後逐檔說明為準。

## 通用新增 1943 空欄位

| 檔案 | 時辰 |
|---|---|
| 一位精修者通用（復活期內）非主教、非主教聖師.json | vigil, morning, evening |
| 一位精修者通用（復活期內）主教、主教聖師.json | vigil, morning, evening |
| 多位精修者通用（復活期外）.json | vigil, morning, evening |
| 一位殉道童貞女用（復活期外）.json | vigil, morning, evening |
| 一位童貞女通用（復活期內）.json | vigil, morning, evening |
| 使徒用（復活期內） .json | vigil, morning, evening |
| 多位殉道者通用（復活期內）.json | vigil, morning, evening |
| 禮拜六特敬聖母.json | vigil, morning, evening |
| 一位殉道童貞女用（復活期內）.json | vigil, morning, evening |

空欄位格式：`{"zh-hant":"","zh-hans":"","en":""}`。後續可直接填入對經，空文字目前不顯示。

## 已轉換檔案及逐項保留差異

### sanctorale_0514_pachomius_easter.json

- 通用：`common_confessor_non_bishop_easter`（一位精修者通用（復活期內）非主教、非主教聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.benedictus_antiphon`, `evening.bible_sentences`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.office_hymn.versicle.leader.zh-hans` | "你们忧愁，" | "启：你们忧愁，哈利路亚." |
| `vigil.office_hymn.versicle.leader.zh-hant` | "你們憂愁，" | "啟：你們憂愁，哈利路亞。" |
| `vigil.office_hymn.versicle.people.zh-hans` | "将变为喜乐，哈利路亚." | "应：将变为喜乐，哈利路亚." |
| `vigil.office_hymn.versicle.people.zh-hant` | "將變為喜樂，哈利路亞。" | "應：將變為喜樂，哈利路亞。" |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "主啊，你交给我五千。请看，我又赚了五千。哈利路亚." | "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚." |
| `vigil.psalm_antiphons.antiphons.0.zh-hant` | "主啊，你交給我五千。請看，我又賺了五千。哈利路亞。" | "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。" |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "好，你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚." | "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚." |
| `vigil.psalm_antiphons.antiphons.1.zh-hant` | "好，你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "他是那忠心又精明的仆人，主人派他管理自己的家。哈利路亚." | "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚." |
| `vigil.psalm_antiphons.antiphons.2.zh-hant` | "他是那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" | "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主人来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚." | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚." |
| `vigil.psalm_antiphons.antiphons.3.zh-hant` | "主人來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "你这又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚." | "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚." |
| `vigil.psalm_antiphons.antiphons.4.zh-hant` | "你這又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.ascension_office_hymn.verses.1.zh-hans` | "二、主名谦逊精修圣者，\n今日得享荣耀声名；\n主之信民欢欣庆祝，\n年度庆节隆重庄严." | "二、主名谦逊精修圣者，\n今日得享荣耀声名；\n主之信民欢欣庆祝，\n年度庆节日隆重庄严." |
| `morning.ascension_office_hymn.versicle.leader.zh-hans` | "你们善人应该因主欢乐，" | "你们善人应该因主欢乐，哈利路亚." |
| `morning.ascension_office_hymn.versicle.leader.zh-hant` | "你們善人應該因主歡樂，" | "你們善人應該因主歡樂，哈利路亞。" |
| `morning.invitatory_hymn.verses.4.zh-hant` | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主.阿們。" | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。" |
| `morning.office_hymn.verses.1.zh-hans` | "二、主名谦逊精修圣者，\n今日得享荣耀声名；\n主之信民欢欣庆祝，\n年度庆节隆重庄严." | "二、主名谦逊精修圣者，\n今日得享荣耀声名；\n主之信民欢欣庆祝，\n年度庆节日隆重庄严." |
| `morning.office_hymn.versicle.leader.zh-hans` | "你们善人应该因主欢乐，" | "你们善人应该因主欢乐，哈利路亚." |
| `morning.office_hymn.versicle.leader.zh-hant` | "你們善人應該因主歡樂，" | "你們善人應該因主歡樂，哈利路亞。" |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "主啊，你交给我五千。请看，我又赚了五千。哈利路亚." | "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚." |
| `morning.psalm_antiphons.antiphons.0.zh-hant` | "主啊，你交給我五千。請看，我又賺了五千。哈利路亞。" | "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。" |
| `morning.psalm_antiphons.antiphons.1.zh-hans` | "好，你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚." | "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚." |
| `morning.psalm_antiphons.antiphons.1.zh-hant` | "好，你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "他是那忠心又精明的仆人，主人派他管理自己的家。哈利路亚." | "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚." |
| `morning.psalm_antiphons.antiphons.2.zh-hant` | "他是那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" | "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "主人来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚." | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚." |
| `morning.psalm_antiphons.antiphons.3.zh-hant` | "主人來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" |
| `morning.psalm_antiphons.antiphons.4.zh-hans` | "你这又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚." | "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚." |
| `morning.psalm_antiphons.antiphons.4.zh-hant` | "你這又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening.benedictus_antiphon.normal.zh-hans` | "你们义人，应该因主欢喜：※蒙上帝选为子民的，就有福了，哈利路亚，哈利路亚，哈利路亚." | "你们义人，应该因主欢喜：蒙上帝选为子民的，就有福了，哈利路亚，哈利路亚，哈利路亚." |
| `evening.benedictus_antiphon.normal.zh-hant` | "你們義人，應該因主歡喜：※蒙上帝選為子民的，就有福了，哈利路亞，哈利路亞，哈利路亞。" | "你們義人，應該因主歡喜：蒙上帝選為子民的，就有福了，哈利路亞，哈利路亞，哈利路亞。" |
| `evening.office_hymn.verses.4.zh-hant` | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主.阿們。" | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。" |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "主啊，你交给我五千。请看，我又赚了五千。哈利路亚." | "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚." |
| `evening.psalm_antiphons.antiphons.0.zh-hant` | "主啊，你交給我五千。請看，我又賺了五千。哈利路亞。" | "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。" |
| `evening.psalm_antiphons.antiphons.1.zh-hans` | "好，你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚." | "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚." |
| `evening.psalm_antiphons.antiphons.1.zh-hant` | "好，你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "他是那忠心又精明的仆人，主人派他管理自己的家。哈利路亚." | "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚." |
| `evening.psalm_antiphons.antiphons.2.zh-hant` | "他是那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" | "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "主人来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚." | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚." |
| `evening.psalm_antiphons.antiphons.3.zh-hant` | "主人來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" |
| `evening.psalm_antiphons.antiphons.4.zh-hans` | "你这又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚." | "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚." |
| `evening.psalm_antiphons.antiphons.4.zh-hant` | "你這又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |

### sanctorale_0516_simon_stock_easter.json

- 通用：`common_confessor_non_bishop_easter`（一位精修者通用（復活期內）非主教、非主教聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 保留原先缺失／停用狀態：`evening`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.office_hymn.versicle.leader.zh-hans` | "你们忧愁，" | "启：你们忧愁，哈利路亚." |
| `vigil.office_hymn.versicle.leader.zh-hant` | "你們憂愁，" | "啟：你們憂愁，哈利路亞。" |
| `vigil.office_hymn.versicle.people.zh-hans` | "将变为喜乐，哈利路亚." | "应：将变为喜乐，哈利路亚." |
| `vigil.office_hymn.versicle.people.zh-hant` | "將變為喜樂，哈利路亞。" | "應：將變為喜樂，哈利路亞。" |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "主啊，你交给我五千。请看，我又赚了五千。哈利路亚." | "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚." |
| `vigil.psalm_antiphons.antiphons.0.zh-hant` | "主啊，你交給我五千。請看，我又賺了五千。哈利路亞。" | "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。" |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "好，你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚." | "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚." |
| `vigil.psalm_antiphons.antiphons.1.zh-hant` | "好，你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "他是那忠心又精明的仆人，主人派他管理自己的家。哈利路亚." | "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚." |
| `vigil.psalm_antiphons.antiphons.2.zh-hant` | "他是那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" | "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主人来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚." | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚." |
| `vigil.psalm_antiphons.antiphons.3.zh-hant` | "主人來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "你这又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚." | "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚." |
| `vigil.psalm_antiphons.antiphons.4.zh-hant` | "你這又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.ascension_office_hymn.verses.1.zh-hans` | "二、主名谦逊精修圣者，\n今日得享荣耀声名；\n主之信民欢欣庆祝，\n年度庆节隆重庄严." | "二、主名谦逊精修圣者，\n今日得享荣耀声名；\n主之信民欢欣庆祝，\n年度庆节日隆重庄严." |
| `morning.ascension_office_hymn.versicle.leader.zh-hans` | "你们善人应该因主欢乐，" | "你们善人应该因主欢乐，哈利路亚." |
| `morning.ascension_office_hymn.versicle.leader.zh-hant` | "你們善人應該因主歡樂，" | "你們善人應該因主歡樂，哈利路亞。" |
| `morning.invitatory_hymn.verses.4.zh-hant` | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主.阿們。" | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。" |
| `morning.office_hymn.verses.1.zh-hans` | "二、主名谦逊精修圣者，\n今日得享荣耀声名；\n主之信民欢欣庆祝，\n年度庆节隆重庄严." | "二、主名谦逊精修圣者，\n今日得享荣耀声名；\n主之信民欢欣庆祝，\n年度庆节日隆重庄严." |
| `morning.office_hymn.versicle.leader.zh-hans` | "你们善人应该因主欢乐，" | "你们善人应该因主欢乐，哈利路亚." |
| `morning.office_hymn.versicle.leader.zh-hant` | "你們善人應該因主歡樂，" | "你們善人應該因主歡樂，哈利路亞。" |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "主啊，你交给我五千。请看，我又赚了五千。哈利路亚." | "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚." |
| `morning.psalm_antiphons.antiphons.0.zh-hant` | "主啊，你交給我五千。請看，我又賺了五千。哈利路亞。" | "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。" |
| `morning.psalm_antiphons.antiphons.1.zh-hans` | "好，你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚." | "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚." |
| `morning.psalm_antiphons.antiphons.1.zh-hant` | "好，你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "他是那忠心又精明的仆人，主人派他管理自己的家。哈利路亚." | "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚." |
| `morning.psalm_antiphons.antiphons.2.zh-hant` | "他是那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" | "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "主人来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚." | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚." |
| `morning.psalm_antiphons.antiphons.3.zh-hant` | "主人來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" |
| `morning.psalm_antiphons.antiphons.4.zh-hans` | "你这又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚." | "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚." |
| `morning.psalm_antiphons.antiphons.4.zh-hant` | "你這又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening` | （原檔沒有此欄位） | {"bible_sentences": [{"text": {"zh-hant": "這些人是從大患難中出來的，他們曾用羔羊的血把衣裳洗得潔白。", "zh-hans": "这些人是从大患难中出来的，他们曾用羔羊的血把衣裳洗得洁白."}, "reference": {"zh-hant": "（啟示錄 7:14）", "zh-hans": "（启示录 7:14）"}}], "psalm_antiphons": {"antiphons": [{"zh-hant": "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。", "zh-hans": "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚."}, {"zh-hant": "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚."}, {"zh-hant": "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。", "zh-hans": "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚."}, {"zh-hant": "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。", "zh-hans": "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚."}, {"zh-hant": "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚."}], "lectionary_1943": {"zh-hant": "", "zh-hans": "", "en": ""}}, "office_hymn": {"title": "Iste Confessor", "verses": [{"zh-hant": "一、昔有宣信士，曾蒙上帝嘉納，\n四方眾士民，虔敬肅然稱頌；\n今朝受封賞，榮登天府高衙，\n永享主榮華。", "zh-hans": "一、昔有宣信士，曾蒙上帝嘉纳，\n四方众士民，虔敬肃然称颂；\n今朝受封赏，荣登天府高衙，\n永享主荣华."}, {"zh-hant": "二、敬畏而警醒，忠貞清正端莊，\n聖潔且謙卑，世人共稱其德；\n雖歿其塵軀，靈召永恆之生，\n蒙入主天庭。", "zh-hans": "二、敬畏而警醒，忠贞清正端庄，\n圣洁且谦卑，世人共称其德；\n虽殁其尘躯，灵召永恒之生，\n蒙入主天庭."}, {"zh-hant": "三、聖澤長流溢，溥濟疲憊乏困，\n賢能有慈懷，仁德沛然昭顯；\n凡負軛抱疾，無論何等重擔，\n悉獲主康安。", "zh-hans": "三、圣泽长流溢，溥济疲惫乏困，\n贤能有慈怀，仁德沛然昭显；\n凡负轭抱疾，无论何等重担，\n悉获主康安."}, {"zh-hant": "四、我眾合讚頌，歸與上帝尊榮，\n欣然高舉歌，敬獻聖名欽崇；\n願今生來世，同作天上良朋，\n共沐主宏恩。", "zh-hans": "四、我众合赞颂，归与上帝尊荣，\n欣然高举歌，敬献圣名钦崇；\n愿今生来世，同作天上良朋，\n共沐主宏恩."}, {"zh-hant": "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。", "zh-hans": "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。"}], "versicle": {"leader": {"zh-hant": "你們憂愁，哈利路亞。", "zh-hans": "你们忧愁，哈利路亚."}, "people": {"zh-hant": "將變為喜樂，哈利路亞。", "zh-hans": "将变为喜乐，哈利路亚."}}}, "benedictus_antiphon": {"normal": {"zh-hant": "你們義人，應該因主歡喜：蒙上帝選為子民的，就有福了，哈利路亞，哈利路亞，哈利路亞。", "zh-hans": "你们义人，应该因主欢喜：蒙上帝选为子民的，就有福了，哈利路亚，哈利路亚，哈利路亚."}}} |

### sanctorale_0517_paschal_baylon_easter.json

- 通用：`common_confessor_non_bishop_easter`（一位精修者通用（復活期內）非主教、非主教聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.office_hymn.versicle.leader` | "你們憂愁，" | {"zh-hant": "啟：你們憂愁，哈利路亞。", "zh-hans": "启：你们忧愁，哈利路亚."} |
| `vigil.office_hymn.versicle.people` | "將變為喜樂，哈利路亞。" | {"zh-hant": "應：將變為喜樂，哈利路亞。", "zh-hans": "应：将变为喜乐，哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.0` | "主啊，你交給我五千。請看，我又賺了五千。哈利路亞。" | {"zh-hant": "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。", "zh-hans": "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.1` | "好，你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" | {"zh-hant": "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.2` | "他是那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" | {"zh-hant": "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。", "zh-hans": "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.3` | "主人來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" | {"zh-hant": "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。", "zh-hans": "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.4` | "你這又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" | {"zh-hant": "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.ascension_office_hymn.versicle.leader` | "你們善人應該因主歡樂，" | {"zh-hant": "你們善人應該因主歡樂，哈利路亞。", "zh-hans": "你们善人应该因主欢乐，哈利路亚."} |
| `morning.office_hymn.versicle.leader` | "你們善人應該因主歡樂，" | {"zh-hant": "你們善人應該因主歡樂，哈利路亞。", "zh-hans": "你们善人应该因主欢乐，哈利路亚."} |
| `morning.psalm_antiphons.antiphons.0` | "主啊，你交給我五千。請看，我又賺了五千。哈利路亞。" | {"zh-hant": "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。", "zh-hans": "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.1` | "好，你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" | {"zh-hant": "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚."} |
| `morning.psalm_antiphons.antiphons.2` | "他是那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" | {"zh-hant": "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。", "zh-hans": "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.3` | "主人來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" | {"zh-hant": "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。", "zh-hans": "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.4` | "你這又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" | {"zh-hant": "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening.office_hymn.versicle.leader` | "你們憂愁，" | {"zh-hant": "你們憂愁，哈利路亞。", "zh-hans": "你们忧愁，哈利路亚."} |
| `evening.psalm_antiphons.antiphons.0` | "主啊，你交給我五千。請看，我又賺了五千。哈利路亞。" | {"zh-hant": "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。", "zh-hans": "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.1` | "好，你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。" | {"zh-hant": "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚."} |
| `evening.psalm_antiphons.antiphons.2` | "他是那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。" | {"zh-hant": "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。", "zh-hans": "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.3` | "主人來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。" | {"zh-hant": "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。", "zh-hans": "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.4` | "你這又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。" | {"zh-hant": "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |

### sanctorale_0524_vincent_of_lerins_easter.json

- 通用：`common_confessor_non_bishop_easter`（一位精修者通用（復活期內）非主教、非主教聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.benedictus_antiphon`。
- 保留原先缺失／停用狀態：`evening`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.office_hymn.versicle.leader` | "你們憂愁，" | {"zh-hant": "啟：你們憂愁，哈利路亞。", "zh-hans": "启：你们忧愁，哈利路亚."} |
| `vigil.office_hymn.versicle.people` | "將變為喜樂，哈利路亞。" | {"zh-hant": "應：將變為喜樂，哈利路亞。", "zh-hans": "应：将变为喜乐，哈利路亚."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.ascension_office_hymn.versicle.leader` | "你們善人應該因主歡樂，" | {"zh-hant": "你們善人應該因主歡樂，哈利路亞。", "zh-hans": "你们善人应该因主欢乐，哈利路亚."} |
| `morning.office_hymn.versicle.leader` | "你們善人應該因主歡樂，" | {"zh-hant": "你們善人應該因主歡樂，哈利路亞。", "zh-hans": "你们善人应该因主欢乐，哈利路亚."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening` | （原檔沒有此欄位） | {"bible_sentences": [{"text": {"zh-hant": "這些人是從大患難中出來的，他們曾用羔羊的血把衣裳洗得潔白。", "zh-hans": "这些人是从大患难中出来的，他们曾用羔羊的血把衣裳洗得洁白."}, "reference": {"zh-hant": "（啟示錄 7:14）", "zh-hans": "（启示录 7:14）"}}], "psalm_antiphons": {"antiphons": [{"zh-hant": "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。", "zh-hans": "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚."}, {"zh-hant": "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚."}, {"zh-hant": "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。", "zh-hans": "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚."}, {"zh-hant": "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。", "zh-hans": "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚."}, {"zh-hant": "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚."}], "lectionary_1943": {"zh-hant": "", "zh-hans": "", "en": ""}}, "office_hymn": {"title": "Iste Confessor", "verses": [{"zh-hant": "一、昔有宣信士，曾蒙上帝嘉納，\n四方眾士民，虔敬肅然稱頌；\n今朝受封賞，榮登天府高衙，\n永享主榮華。", "zh-hans": "一、昔有宣信士，曾蒙上帝嘉纳，\n四方众士民，虔敬肃然称颂；\n今朝受封赏，荣登天府高衙，\n永享主荣华."}, {"zh-hant": "二、敬畏而警醒，忠貞清正端莊，\n聖潔且謙卑，世人共稱其德；\n雖歿其塵軀，靈召永恆之生，\n蒙入主天庭。", "zh-hans": "二、敬畏而警醒，忠贞清正端庄，\n圣洁且谦卑，世人共称其德；\n虽殁其尘躯，灵召永恒之生，\n蒙入主天庭."}, {"zh-hant": "三、聖澤長流溢，溥濟疲憊乏困，\n賢能有慈懷，仁德沛然昭顯；\n凡負軛抱疾，無論何等重擔，\n悉獲主康安。", "zh-hans": "三、圣泽长流溢，溥济疲惫乏困，\n贤能有慈怀，仁德沛然昭显；\n凡负轭抱疾，无论何等重担，\n悉获主康安."}, {"zh-hant": "四、我眾合讚頌，歸與上帝尊榮，\n欣然高舉歌，敬獻聖名欽崇；\n願今生來世，同作天上良朋，\n共沐主宏恩。", "zh-hans": "四、我众合赞颂，归与上帝尊荣，\n欣然高举歌，敬献圣名钦崇；\n愿今生来世，同作天上良朋，\n共沐主宏恩."}, {"zh-hant": "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。", "zh-hans": "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。"}], "versicle": {"leader": {"zh-hant": "你們憂愁，哈利路亞。", "zh-hans": "你们忧愁，哈利路亚."}, "people": {"zh-hant": "將變為喜樂，哈利路亞。", "zh-hans": "将变为喜乐，哈利路亚."}}}, "benedictus_antiphon": {"normal": {"zh-hant": "你們義人，應該因主歡喜：蒙上帝選為子民的，就有福了，哈利路亞，哈利路亞，哈利路亞。", "zh-hans": "你们义人，应该因主欢喜：蒙上帝选为子民的，就有福了，哈利路亚，哈利路亚，哈利路亚."}}} |

### sanctorale_0526_augustine_of_canterbury.json

- 通用：`common_confessor_bishop_outside_easter`（一位精修者通用（復活期外）主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `morning.bible_sentences`, `morning.invitatory`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `morning.bible_sentences`, `morning.invitatory`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "主的精修者聖奧古斯丁，※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。" | {"zh-hant": "主的精修者聖（某某），※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。", "zh-hans": "主的精修者圣（某某），※藉着你神圣的代祷坚固我们众人，使我们这些人被罪恶重担压垮之人，因你已得享真福荣耀而昂首挺身，并追随你的芳踪，至终赢得永恒的赏赐."} |
| `vigil.office_hymn.verses.3` | "四、 伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。" | {"zh-hant": "四、伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。", "zh-hans": "四、伏祈祷声恒，助忠僕越沧浪；\n赐登天国境，颂圣三于云阙；\n父子与圣灵，赞上帝永不歇；\n圣三永称扬！阿们。"} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人走入正路，將上帝的國指示給他，賜予他神聖事物的知識，使他在辛勞之中得榮耀，並增加他辛苦勞成果。", "zh-hans": "主引导义人走入正路，将上帝的国指示给他，赐予他神圣事物的知识，使他在辛劳之中得荣耀，并增加他辛苦劳成果。", "en": "The Lord guided the righteous man in right paths, and showed him the Kingdom of God; bestowed on him the knowledge of holy things, made him honourable in his travails, and increased the fruit of his labours."}, {"zh-hant": "你這又良善又忠心的僕人，※可以進來享受你主人的快樂。", "zh-hans": "你这又良善又忠心的仆人，※可以进来享受你主人的快乐。", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `morning.invitatory_hymn.title` | "Olim Sanctorum Insula" | "Christe, pastorum Caput atque Princeps" |
| `morning.invitatory_hymn.verses.0` | "一、古昔素稱眾聖之島，\n今當高唱雄壯頌歌；\n齊聲稱揚使徒聖德，\n致敬格列高利之子。" | {"zh-hant": "一、基督彰威嚴，眾牧元首治者；\n主教當稱頌，德澤流芳永世；\n攜誓趨聖殿，虔獻心香主前；\n仁愛永長存！", "zh-hans": "一、基督彰威严，众牧元首治者；\n主教当称颂，德泽流芳永世；\n携誓趋圣殿，虔献心香主前；\n仁爱永长存！"} |
| `morning.invitatory_hymn.verses.1` | "二、辛勞汗水滋潤沃土，\n慷慨大地終得豐收；\n遍地綻放璀璨繁花，\n田間禾稼結實百倍。" | {"zh-hant": "二、秉謙登牧座，不恃名唯承光；\n主賜威權重，戰兢持守聖德；\n克己潔身行，恩雨沛臨群羊；\n憐憫澤萬方！", "zh-hans": "二、秉谦登牧座，不恃名唯承光；\n主赐威权重，战兢持守圣德；\n克己洁身行，恩雨沛临群羊；\n怜悯泽万方！"} |
| `morning.invitatory_hymn.verses.2` | "三、四十修士結伴同行，\n遵命抵達英倫海岸；\n基督旌旗高展穹蒼，\n彰顯神聖生命平安。" | {"zh-hant": "三、為父與牧者，傾身家惠澤長；\n萬民立聖範，德輝照耀八荒；\n甘作眾人僕，仁風雨潤塵疆；\n信德作津梁！", "zh-hans": "三、为父与牧者，倾身家惠泽长；\n万民立圣范，德辉照耀八荒；\n甘作众人仆，仁风雨润尘疆；\n信德作津梁！"} |
| `morning.invitatory_hymn.verses.3` | "四、十架閃耀奧妙光輝，\n醫治聖言自此廣傳；\n君王雖長化外之邦，\n欣然領受真道信仰。" | {"zh-hant": "四、 伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。", "zh-hans": "四、 伏祈祷声恒，助忠僕越沧浪；\n赐登天国境，颂圣三于云阙；\n父子与圣灵，赞上帝永不歇；\n圣三永称扬！阿们。"} |
| `morning.invitatory_hymn.verses.4` | "五、三一上帝恩澤不息，\n聖寵甘露恆灌聖蔓；\n懇求吾土再次復興，\n昔日賜命神聖信仰。阿們。" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "願那愛你名的人都靠你歡欣。※因為你必賜福與義人；主啊，你必用恩惠如同盾牌四面護衛他。", "zh-hans": "愿那爱你名的人都靠你欢欣。※因为你必赐福与义人；主啊，你必用恩惠如同盾牌四面护卫他。", "en": "Let all rejoice ※ who hope in thee, O Lord; since thou hast blessed the righteous man, and with the shield of thy good will hast crowned him."}, {"zh-hant": "在遵守至高者的法律上，※沒有人可與他對立。", "zh-hans": "在遵守至高者的法律上，※没有人可与他对立。", "en": "There was none found ※ like unto him, who kept the law of the Most High."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪！這是大祭司，※他在世之時取悅了上帝，被看為完全，是個義人。", "zh-hans": "看哪！这是大祭司，※他在世之时取悦了上帝，被看为完全，是个义人。", "en": "Behold a great Priest, ※ who in his days pleased God, and was found righteous."}, {"zh-hant": "這是那忠心有見識的管家，主人派他管理家裡的人。", "zh-hans": "这是那忠心有见识的管家，主人派他管理家里的人。", "en": "A wise and faithful steward, whom the Lord made ruler over his household."}] |

### sanctorale_0526_augustine_of_canterbury_easter.json

- 通用：`common_confessor_bishop_easter`（一位精修者通用（復活期內）主教、主教聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.office_hymn`, `morning.ascension_office_hymn`, `evening.bible_sentences`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.office_hymn`, `morning.ascension_office_hymn`, `evening.bible_sentences`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.office_hymn.verses.4` | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。" | {"zh-hant": "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主.阿們。", "zh-hans": "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。"} |
| `vigil.office_hymn.versicle.leader` | "你們憂愁，哈利路亞。" | {"zh-hant": "啟：你們憂愁，哈利路亚。", "zh-hans": "启：你们忧愁，哈利路亚."} |
| `vigil.office_hymn.versicle.people` | "將變為喜樂，哈利路亞。" | {"zh-hant": "應：將變為喜樂，哈利路亚。", "zh-hans": "应：将变为喜乐，哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.0` | "看，大祭司，※他在世之時蒙上帝喜悅，又被認為是齊全正義之人。哈利路亞。" | {"zh-hant": "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。", "zh-hans": "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.1` | "他遵守至高者的法律，※沒有人比得上他。哈利路亞。" | {"zh-hant": "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.2` | "因此，※上帝起誓許使他的苗裔在萬民之中興旺。哈利路亞。" | {"zh-hant": "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。", "zh-hans": "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.3` | "上帝的眾祭司阿，※你們要讚頌主；主的僕人阿，請謳歌頌讚我們的上帝。哈利路亞。" | {"zh-hant": "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。", "zh-hans": "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.4` | "善良忠信的僕人，※進入你主人的福樂吧！哈利路亞。" | {"zh-hant": "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.benedictus_antiphon.normal` | "看哪，※他們如今站立在上帝的羔羊面前，身穿白袍，哈利路亞。" | {"zh-hant": "看哪，他們如今站立在上帝的羔羊面前，身穿白袍，哈利路亞。", "zh-hans": "看哪，他们如今站立在上帝的羔羊面前，身穿白袍，哈利路亚."} |
| `morning.invitatory_hymn.title` | "Olim Sanctorum Insula" | "Iste Confessor" |
| `morning.invitatory_hymn.verses.0` | "一、古昔素稱眾聖之島，\n今當高唱雄壯頌歌；\n齊聲稱揚使徒聖德，\n致敬格列高利之子。" | {"zh-hant": "一、昔有宣信士，曾蒙上帝嘉納，\n四方眾士民，虔敬肅然稱頌；\n今朝受封賞，榮登天府高衙，\n永享主榮華。", "zh-hans": "一、昔有宣信士，曾蒙上帝嘉纳，\n四方众士民，虔敬肃然称颂；\n今朝受封赏，荣登天府高衙，\n永享主荣华."} |
| `morning.invitatory_hymn.verses.1` | "二、辛勞汗水滋潤沃土，\n慷慨大地終得豐收；\n遍地綻放璀璨繁花，\n田間禾稼結實百倍。" | {"zh-hant": "二、敬畏而警醒，忠貞清正端莊，\n聖潔且謙卑，世人共稱其德；\n雖歿其塵軀，靈召永恆之生，\n蒙入主天庭。", "zh-hans": "二、敬畏而警醒，忠贞清正端庄，\n圣洁且谦卑，世人共称其德；\n虽殁其尘躯，灵召永恒之生，\n蒙入主天庭."} |
| `morning.invitatory_hymn.verses.2` | "三、四十修士結伴同行，\n遵命抵達英倫海岸；\n基督旌旗高展穹蒼，\n彰顯神聖生命平安。" | {"zh-hant": "三、聖澤長流溢，溥濟疲憊乏困，\n賢能有慈懷，仁德沛然昭顯；\n凡負軛抱疾，無論何等重擔，\n悉獲主康安。", "zh-hans": "三、圣泽长流溢，溥济疲惫乏困，\n贤能有慈怀，仁德沛然昭显；\n凡负轭抱疾，无论何等重担，\n悉获主康安."} |
| `morning.invitatory_hymn.verses.3` | "四、十架閃耀奧妙光輝，\n醫治聖言自此廣傳；\n君王雖長化外之邦，\n欣然領受真道信仰。" | {"zh-hant": "四、我眾合讚頌，歸與上帝尊榮，\n欣然高舉歌，敬獻聖名欽崇；\n願今生來世，同作天上良朋，\n共沐主宏恩。", "zh-hans": "四、我众合赞颂，归与上帝尊荣，\n欣然高举歌，敬献圣名钦崇；\n愿今生来世，同作天上良朋，\n共沐主宏恩."} |
| `morning.invitatory_hymn.verses.4` | "五、三一上帝恩澤不息，\n聖寵甘露恆灌聖蔓；\n懇求吾土再次復興，\n昔日賜命神聖信仰。阿們。" | {"zh-hant": "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主.阿們。", "zh-hans": "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。"} |
| `morning.psalm_antiphons.antiphons.0` | "看，大祭司，※他在世之時蒙上帝喜悅，又被認為是齊全正義之人。哈利路亞。" | {"zh-hant": "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。", "zh-hans": "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.1` | "他遵守至高者的法律，※沒有人比得上他。哈利路亞。" | {"zh-hant": "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚."} |
| `morning.psalm_antiphons.antiphons.2` | "因此，※上帝起誓許使他的苗裔在萬民之中興旺。哈利路亞。" | {"zh-hant": "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。", "zh-hans": "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.3` | "上帝的眾祭司阿，※你們要讚頌主；主的僕人阿，請謳歌頌讚我們的上帝。哈利路亞。" | {"zh-hant": "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。", "zh-hans": "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.4` | "善良忠信的僕人，※進入你主人的福樂吧！哈利路亞。" | {"zh-hant": "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening.office_hymn.verses.4` | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。" | {"zh-hant": "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主.阿們。", "zh-hans": "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。"} |
| `evening.psalm_antiphons.antiphons.0` | "看，大祭司，※他在世之時蒙上帝喜悅，又被認為是齊全正義之人。哈利路亞。" | {"zh-hant": "主啊，※你交給我五千。請看，我又賺了五千。哈利路亞。", "zh-hans": "主啊，※你交给我五千。请看，我又赚了五千。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.1` | "他遵守至高者的法律，※沒有人比得上他。哈利路亞。" | {"zh-hant": "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！哈利路亚."} |
| `evening.psalm_antiphons.antiphons.2` | "因此，※上帝起誓許使他的苗裔在萬民之中興旺。哈利路亞。" | {"zh-hant": "他是※那忠心又精明的僕人，主人派他管理自己的家。哈利路亞。", "zh-hans": "他是※那忠心又精明的仆人，主人派他管理自己的家。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.3` | "上帝的眾祭司阿，※你們要讚頌主；主的僕人阿，請謳歌頌讚我們的上帝。哈利路亞。" | {"zh-hant": "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。哈利路亞。", "zh-hans": "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.4` | "善良忠信的僕人，※進入你主人的福樂吧！哈利路亞。" | {"zh-hant": "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！哈利路亞。", "zh-hans": "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！哈利路亚."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |

### sanctorale_0527_bede.json

- 通用：`common_confessor_doctor_outside_easter`（一位精修者通用（復活期外）教會聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon` | {"normal": "主的精修者聖比德，※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。"} | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人走入正路，將上帝的國指示給他，賜予他神聖事物的知識，使他在辛勞之中得榮耀，並增加他辛苦勞成果。", "zh-hans": "主引导义人走入正路，将上帝的国指示给他，赐予他神圣事物的知识，使他在辛劳之中得荣耀，并增加他辛苦劳成果。", "en": "The Lord guided the righteous man in right paths, and showed him the Kingdom of God; bestowed on him the knowledge of holy things, made him honourable in his travails, and increased the fruit of his labours."}, {"zh-hant": "你這又良善又忠心的僕人，※可以進來享受你主人的快樂。", "zh-hans": "你这又良善又忠心的仆人，※可以进来享受你主人的快乐。", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `morning.invitatory` | {"text": "主的聖師聖比德，懷著對上帝的信德而生活，※讓我們懷著同樣信德來俯伏敬拜至聖三一，惟一上帝。"} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "願那愛你名的人都靠你歡欣。※因為你必賜福與義人；主啊，你必用恩惠如同盾牌四面護衛他。", "zh-hans": "愿那爱你名的人都靠你欢欣。※因为你必赐福与义人；主啊，你必用恩惠如同盾牌四面护卫他。", "en": "Let all rejoice ※ who hope in thee, O Lord; since thou hast blessed the righteous man, and with the shield of thy good will hast crowned him."}, {"zh-hant": "在遵守至高者的法律上，※沒有人可與他對立。", "zh-hans": "在遵守至高者的法律上，※没有人可与他对立。", "en": "There was none found ※ like unto him, who kept the law of the Most High."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪！這是大祭司，※他在世之時取悅了上帝，被看為完全，是個義人。", "zh-hans": "看哪！这是大祭司，※他在世之时取悦了上帝，被看为完全，是个义人。", "en": "Behold a great Priest, ※ who in his days pleased God, and was found righteous."}, {"zh-hant": "這是那忠心有見識的管家，主人派他管理家裡的人。", "zh-hans": "这是那忠心有见识的管家，主人派他管理家里的人。", "en": "A wise and faithful steward, whom the Lord made ruler over his household."}] |

### sanctorale_0527_bede_easter.json

- 通用：`common_confessor_non_bishop_easter`（一位精修者通用（復活期內）非主教、非主教聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.office_hymn.versicle.leader` | "你們憂愁，" | {"zh-hant": "啟：你們憂愁，哈利路亞。", "zh-hans": "启：你们忧愁，哈利路亚."} |
| `vigil.office_hymn.versicle.people` | "將變為喜樂，哈利路亞。" | {"zh-hant": "應：將變為喜樂，哈利路亞。", "zh-hans": "应：将变为喜乐，哈利路亚."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.ascension_office_hymn.versicle.leader` | "你們善人應該因主歡樂，" | {"zh-hant": "你們善人應該因主歡樂，哈利路亞。", "zh-hans": "你们善人应该因主欢乐，哈利路亚."} |
| `morning.office_hymn.versicle.leader` | "你們善人應該因主歡樂，" | {"zh-hant": "你們善人應該因主歡樂，哈利路亞。", "zh-hans": "你们善人应该因主欢乐，哈利路亚."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening.office_hymn.versicle.leader` | "你們憂愁，" | {"zh-hant": "你們憂愁，哈利路亞。", "zh-hans": "你们忧愁，哈利路亚."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |

### sanctorale_0530_joan_of_arc.json

- 通用：`common_virgin_martyr_outside_easter`（一位殉道童貞女用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |

### sanctorale_0530_joan_of_arc_easter.json

- 通用：`common_virgin_martyr_easter`（一位殉道童貞女用（復活期內）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |

### sanctorale_0602_martyrs_of_china.json

- 通用：`common_martyrs_outside_easter`（多位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "諸聖藉著信，※制伏了敵國，行了公義，得了應許。", "zh-hans": "诸圣藉着信，※制伏了敌国，行了公义，得了应许。", "en": "The Saints through faith ※subdued kingdoms, they wrought righteousness, they obtained the promises."} |
| `morning.psalm_antiphons.antiphons.0` | "這些聖人歷盡艱苦，※使他們在平安之中得到了殉道的棕櫚枝。" | {"zh-hant": "主的聖徒必如百合花开放，※哈利路亞；他們必如香膏的馨香立於主面前，哈利路亞。", "zh-hans": "主的圣徒必如百合花开放，※哈利路亚；他们必如香膏的馨香立于主面前，哈利路亚."} |
| `morning.psalm_antiphons.antiphons.1` | "這些聖者手持棕樹枝※來到了天國，他們堪當由上帝手中接受榮耀的冠冕。" | {"zh-hant": "天國是諸聖的居所，※哈利路亞，他們要永遠安息，哈利路亞。", "zh-hans": "天国是诸圣的居所，※哈利路亚，他们要永远安息，哈利路亚."} |
| `morning.psalm_antiphons.antiphons.2` | "聖者們的身體※雖被安葬於平安之中，他們的名永存不朽。" | {"zh-hant": "主的諸聖在帷幕內高呼：※哈利路亞，哈利路亞，哈利路亞。", "zh-hans": "主的诸圣在帷幕内高呼：※哈利路亚，哈利路亚，哈利路亚."} |
| `morning.psalm_antiphons.antiphons.3` | "主的殉道者阿，※請讚頌上主直到永遠。" | {"zh-hant": "義人的靈魂，※請歌唱讚美我們的上帝，哈利路亞，哈利路亞。", "zh-hans": "义人的灵魂，※请歌唱赞美我们的上帝，哈利路亚，哈利路亚."} |
| `morning.psalm_antiphons.antiphons.4` | "殉道者的歌詠團，※請在至高的天上讚美主。" | {"zh-hant": "義人要在上帝台前發出光來，※像太陽一樣。哈利路亞。", "zh-hans": "义人要在上帝台前发出光来，※像太阳一样。哈利路亚."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪，諸聖在上帝那裡有無與倫比的賞賜；※他們為基督而死，而在光榮之中永遠生活。", "zh-hans": "看哪，诸圣在上帝那里有无与伦比的赏赐；※他们为基督而死，而在光荣之中永远生活。", "en": "Behold, the reward of the Saints ※ is plentiful with God; in truth, they died for Christ; in glory, they shall live for ever."}, {"zh-hant": "如金子在爐中被鍛煉，※主也如此試驗祂所揀選的人；祂永遠悅納他們，如同悅納燔祭。", "zh-hans": "如金子在炉中被锻炼，※主也如此试验祂所拣选的人；祂永远悦纳他们，如同悦纳燔祭。", "en": "As gold in the furnace, ※ so doth the Lord try his Elect; and as a burnt-offering, he hath accepted them for ever."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "義人的靈魂※在上帝手中，而痛苦斷不能侵害他們。", "zh-hans": "义人的灵魂※在上帝手中，而痛苦断不能侵害他们。", "en": "The souls of the righteous ※ are in the hand of God, and there shall no torment touch them."} |

### sanctorale_0602_martyrs_of_china_easter.json

- 通用：`common_martyrs_easter`（多位殉道者通用（復活期內）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.ascension_office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.ascension_office_hymn`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.ascension_office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.ascension_office_hymn`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "來吧，※耶路撒冷的女兒，請看，殉道者，以及主在這隆重喜悅的日子上，給他們戴上的冠冕，哈利路亞。" | {"zh-hant": "來吧，※耶路撒冷的女兒，請看，殉道者，以及主在這隆重喜悅的日子上，給他們戴上的冠冕，哈利路亚。", "zh-hans": "来吧，※耶路撒冷的女儿，请看，殉道者，以及主在这隆重喜悦的日子上，给他们戴上的冠冕，哈利路亚."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening.benedictus_antiphon.normal` | "主啊，※永恆之光必照耀主的眾聖徒，哈利路亞；直到永永遠遠，哈利路亞，哈利路亞，哈利路亞。" | {"zh-hant": "主阿，※永恆之光必照耀主的眾聖徒，哈利路亞；直到永永遠遠，哈利路亞，哈利路亞，哈利路亞。", "zh-hans": "主阿，※永恒之光必照耀主的众圣徒，哈利路亚；直到永永远远，哈利路亚，哈利路亚，哈利路亚."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |

### sanctorale_0609_columba_easter.json

- 通用：`common_confessor_non_bishop_easter`（一位精修者通用（復活期內）非主教、非主教聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.ascension_office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.ascension_office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.office_hymn.versicle.leader` | "你們憂愁，哈利路亞。" | {"zh-hant": "啟：你們憂愁，哈利路亞。", "zh-hans": "启：你们忧愁，哈利路亚."} |
| `vigil.office_hymn.versicle.people` | "將變為喜樂，哈利路亞。" | {"zh-hant": "應：將變為喜樂，哈利路亞。", "zh-hans": "应：将变为喜乐，哈利路亚."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |

### sanctorale_0610_margaret_of_scotland.json

- 通用：`common_holy_woman_outside_easter`（一位聖婦用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |
| `morning.invitatory.text` | "在聖瑪格麗特的隆重慶節中，※我們當來俯伏敬拜上帝。" | {"zh-hant": "在聖（某某）的隆重慶節中，※我們當來俯伏敬拜上帝。", "zh-hans": "在圣（某某）的隆重庆节中，※我们当来俯伏敬拜上帝."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |

### sanctorale_0610_margaret_of_scotland_easter.json

- 通用：`common_holy_woman_easter`（一位聖婦用（復活期內）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。哈利路亞。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。哈利路亞。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。哈利路亚。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |
| `morning.invitatory.text` | "在聖瑪格麗特的隆重慶節中，※我們當來俯伏敬拜上帝。哈利路亞。" | {"zh-hant": "在聖（某某）的隆重慶節中，※我們當來俯伏敬拜上帝。哈利路亞。", "zh-hans": "在圣（某某）的隆重庆节中，※我们当来俯伏敬拜上帝。哈利路亚."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。哈利路亞。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。哈利路亞。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。哈利路亚。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。哈利路亞。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。哈利路亞。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。哈利路亚。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |

### sanctorale_0613_anthony_of_padua.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0614_basil_the_great.json

- 通用：`common_confessor_doctor_outside_easter`（一位精修者通用（復活期外）教會聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.psalm_antiphons.antiphons`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.psalm_antiphons.antiphons`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon` | {"normal": "主的精修者聖巴西流，※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。"} | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人走入正路，將上帝的國指示給他，賜予他神聖事物的知識，使他在辛勞之中得榮耀，並增加他辛苦勞成果。", "zh-hans": "主引导义人走入正路，将上帝的国指示给他，赐予他神圣事物的知识，使他在辛劳之中得荣耀，并增加他辛苦劳成果。", "en": "The Lord guided the righteous man in right paths, and showed him the Kingdom of God; bestowed on him the knowledge of holy things, made him honourable in his travails, and increased the fruit of his labours."}, {"zh-hant": "你這又良善又忠心的僕人，※可以進來享受你主人的快樂。", "zh-hans": "你这又良善又忠心的仆人，※可以进来享受你主人的快乐。", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `morning.invitatory` | {"text": "主是精修者的君王，※我們當來俯伏敬拜。"} | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3` | "四、 伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。" | {"zh-hant": "四、伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。", "zh-hans": "四、伏祈祷声恒，助忠僕越沧浪；\n赐登天国境，颂圣三于云阙；\n父子与圣灵，赞上帝永不歇；\n圣三永称扬！阿们。"} |
| `morning.office_hymn.title` | "Jesu, sacerdotum decus" | "O luce qui mortalibus" |
| `morning.office_hymn.verses.0` | "一、耶穌主僕榮冕喜樂，\n慈目垂顧主的子民，\n今值聖者榮升天鄉，\n光耀冠冕永沐聖恩。" | {"zh-hant": "一、上帝燃明燈，何其輝耀光明！\n你為地上鹽，聖味至潔純清；\n護人免腐朽，靈魂永葆潔貞，\n使人得永生。", "zh-hans": "一、上帝燃明灯，何其辉耀光明！\n你为地上盐，圣味至洁纯清；\n护人免腐朽，灵魂永葆洁贞，\n使人得永生."} |
| `morning.office_hymn.verses.1` | "二、愛主為證主恩為憑，\n自禰聖殿領受使命；\n守護照顧主贖羊群，\n父托於主彼竭其誠。" | {"zh-hant": "二、因你真理存，謬誤永不侵凌；\n因你信德貞，童貞無玷堅凝；\n因主啓寶藏，智慧豐盈傾注，\n智慧顯於今。", "zh-hans": "二、因你真理存，谬误永不侵凌；\n因你信德贞，童贞无玷坚凝；\n因主启宝藏，智慧丰盈倾注，\n智慧显于今."} |
| `morning.office_hymn.verses.2` | "三、驅散凶獸斥退豺狼，\n詭計雖狡盡皆洞穿；\n護衛群羊願承危險，\n捨命爭戰忠勇無雙。" | {"zh-hant": "三、聖泉湧活水，清澈潤澤無垠，\n潤基督田地，結實累累豐登；\n為乳汁育嬰，為壯者備真糧，\n萬民得飽饗。", "zh-hans": "三、圣泉涌活水，清澈润泽无垠，\n润基督田地，结实累累丰登；\n为乳汁育婴，为壮者备真粮，\n万民得饱飨."} |
| `morning.office_hymn.verses.3` | "四、每逢獻上無血聖祭，\n救恩聖筵價值無極；\n羊群置於祭壇之上，\n自己也為活獻祭上。" | {"zh-hant": "四、永恆真理主，我眾因主歡欣！\n肉身耳雖聞，未解聖言深恩，\n聖師言教中，啓迪靈性明心，\n聖靈耀吾靈。阿們。", "zh-hans": "四、永恒真理主，我众因主欢欣！\n肉身耳虽闻，未解圣言深恩，\n圣师言教中，启迪灵性明心，\n圣灵耀吾灵。阿们。"} |
| `morning.office_hymn.verses.4` | "五、唯願榮耀讚頌尊威，\n歸於至高祭司耶穌，\n歸於聖父保惠聖靈，\n三一上帝永受讚頌。阿們。" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader` | "義人必如百合花開放，" | {"zh-hant": "我已陳明主的信實和救恩；", "zh-hans": "我已陈明主的信实和救恩；"} |
| `morning.office_hymn.versicle.people` | "永遠繁榮在主面前。" | {"zh-hant": "我未曾隱瞞主的慈愛和信實。", "zh-hans": "我未曾隐瞒主的慈爱和信实."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "願那愛你名的人都靠你歡欣。※因為你必賜福與義人；主啊，你必用恩惠如同盾牌四面護衛他。", "zh-hans": "愿那爱你名的人都靠你欢欣。※因为你必赐福与义人；主啊，你必用恩惠如同盾牌四面护卫他。", "en": "Let all rejoice ※ who hope in thee, O Lord; since thou hast blessed the righteous man, and with the shield of thy good will hast crowned him."}, {"zh-hant": "在遵守至高者的法律上，※沒有人可與他對立。", "zh-hans": "在遵守至高者的法律上，※没有人可与他对立。", "en": "There was none found ※ like unto him, who kept the law of the Most High."}] |
| `evening.office_hymn.title` | "Jesu, sacerdotum decus" | "O luce qui mortalibus" |
| `evening.office_hymn.verses.0` | "一、耶穌主僕榮冕喜樂，\n慈目垂顧主的子民，\n今值聖者榮升天鄉，\n光耀冠冕永沐聖恩。" | {"zh-hant": "一、上帝燃明燈，何其輝耀光明！\n你為地上鹽，聖味至潔純清；\n護人免腐朽，靈魂永葆潔貞，\n使人得永生。", "zh-hans": "一、上帝燃明灯，何其辉耀光明！\n你为地上盐，圣味至洁纯清；\n护人免腐朽，灵魂永葆洁贞，\n使人得永生."} |
| `evening.office_hymn.verses.1` | "二、愛主為證主恩為憑，\n自禰聖殿領受使命；\n守護照顧主贖羊群，\n父托於主彼竭其誠。" | {"zh-hant": "二、因你真理存，謬誤永不侵凌；\n因你信德貞，童貞無玷堅凝；\n因主啓寶藏，智慧豐盈傾注，\n智慧顯於今。", "zh-hans": "二、因你真理存，谬误永不侵凌；\n因你信德贞，童贞无玷坚凝；\n因主启宝藏，智慧丰盈倾注，\n智慧显于今."} |
| `evening.office_hymn.verses.2` | "三、驅散凶獸斥退豺狼，\n詭計雖狡盡皆洞穿；\n護衛群羊願承危險，\n捨命爭戰忠勇無雙。" | {"zh-hant": "三、聖泉湧活水，清澈潤澤無垠，\n潤基督田地，結實累累豐登；\n為乳汁育嬰，為壯者備真糧，\n萬民得飽饗。", "zh-hans": "三、圣泉涌活水，清澈润泽无垠，\n润基督田地，结实累累丰登；\n为乳汁育婴，为壮者备真粮，\n万民得饱飨."} |
| `evening.office_hymn.verses.3` | "四、每逢獻上無血聖祭，\n救恩聖筵價值無極；\n羊群置於祭壇之上，\n自己也為活獻祭上。" | {"zh-hant": "四、永恆真理主，我眾因主歡欣！\n肉身耳雖聞，未解聖言深恩，\n聖師言教中，啓迪靈性明心，\n聖靈耀吾靈。阿們。", "zh-hans": "四、永恒真理主，我众因主欢欣！\n肉身耳虽闻，未解圣言深恩，\n圣师言教中，启迪灵性明心，\n圣灵耀吾灵。阿们。"} |
| `evening.office_hymn.verses.4` | "五、唯願榮耀讚頌尊威，\n歸於至高祭司耶穌，\n歸於聖父保惠聖靈，\n三一上帝永受讚頌。阿們。" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪！這是大祭司，※他在世之時取悅了上帝，被看為完全，是個義人。", "zh-hans": "看哪！这是大祭司，※他在世之时取悦了上帝，被看为完全，是个义人。", "en": "Behold a great Priest, ※ who in his days pleased God, and was found righteous."}, {"zh-hant": "這是那忠心有見識的管家，主人派他管理家裡的人。", "zh-hans": "这是那忠心有见识的管家，主人派他管理家里的人。", "en": "A wise and faithful steward, whom the Lord made ruler over his household."}] |

### sanctorale_0618_ephrem.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.office_hymn.title` | "Iste Confessor" | "Christe, pastorum Caput atque Princeps" |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.office_hymn.title` | "Jesu, sacerdotum decus" | "Iesu, corona celsior" |
| `morning.office_hymn.verses.7` | "八、榮耀全歸上帝聖父，\n並其獨生至聖聖言；\n偕同至聖唯一聖靈，\n掌管萬有永世無窮。" | {"zh-hant": "八、榮耀全歸上帝聖父，\n並其獨生至聖聖言；\n偕同至聖唯一聖靈，\n掌管萬有永世無窮。阿們。", "zh-hans": "八、荣耀全归上帝圣父，\n并其独生至圣圣言；\n偕同至圣唯一圣灵，\n掌管万有永世无穷。阿们。"} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0620_translation_of_edward.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這位聖者為維護上帝的律法奮鬥至死，※對惡人的恐嚇毫不畏懼；因為他好像建在穩固的磐石上。", "zh-hans": "这位圣者为维护上帝的律法奋斗至死，※对恶人的恐吓毫不畏惧；因为他好像建在稳固的磐石上。", "en": "This is a holy man ※ who strove for the law of his God, even unto death; and feared not the words of evil men, forasmuch as he was established on the sure and firm Rock."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "公義的主※喜愛公義；他的眼目必看顧正直的人。", "zh-hans": "公义的主※喜爱公义；他的眼目必看顾正直的人。", "en": "The righteous Lord ※ loveth righteousness; his countenance will behold the thing that is just."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他。", "en": "Whosoever shall confess ※ me before men, him will I confess also before my Father."}, {"zh-hant": "那在智慧中恆心不渝，※默想神聖之事，並在心中思想上帝無所不見之大能的人有福了。", "zh-hans": "那在智慧中恒心不渝，※默想神圣之事，并在心中思想上帝无所不见之大能的人有福了。", "en": "Blessed is the man ※ that continueth in wisdom, and doth meditate on holy things, and that reasoneth in his mind on the all-seeing power of God."}] |

### sanctorale_0622_alban.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`。
- 保留原先缺失／停用狀態：`morning.benedictus_antiphon.normals`, `evening.benedictus_antiphon.normals`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "萬福，阿爾班，※英格蘭首位殉道者、天使君王之精兵！殉道者之花，猶如玫瑰花蕾與百合花；願你在上帝面前的祈求，能為信徒的福祉生發功效。" | {"zh-hant": "這真是一位殉道者，※他為基督的名傾流了鮮血；他不畏懼審判者的威嚇，不追求世俗的尊貴榮耀，喜樂地進入天國。", "zh-hans": "这真是一位殉道者，※他为基督的名倾流了鲜血；他不畏惧审判者的威吓，不追求世俗的尊贵荣耀，喜乐地进入天国."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這位聖者為維護上帝的律法奮鬥至死，※對惡人的恐嚇毫不畏懼；因為他好像建在穩固的磐石上。", "zh-hans": "这位圣者为维护上帝的律法奋斗至死，※对恶人的恐吓毫不畏惧；因为他好像建在稳固的磐石上。", "en": "This is a holy man ※ who strove for the law of his God, even unto death; and feared not the words of evil men, forasmuch as he was established on the sure and firm Rock."} |
| `morning.benedictus_antiphon.normal` | "萬福，阿爾班，※英格蘭首位殉道者、天使君王之精兵！殉道者之花，猶如玫瑰花蕾與百合花；願你在上帝面前的祈求，能為信徒的福祉生發功效。" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normals` | （原檔沒有此欄位） | [{"zh-hant": "一粒麥子不落在地裏死了，※仍舊是一粒。", "zh-hans": "一粒麦子不落在地里死了，※仍旧是一粒."}, {"zh-hant": "主說：若有人要跟從我，※就當捨己，背起自己的十字架來跟從我。", "zh-hans": "主说：若有人要跟从我，※就当舍己，背起自己的十字架来跟从我."}] |
| `morning.invitatory.text` | "主是精修者的君王，※我們當來俯伏敬拜。" | {"zh-hant": "主是殉道者的君王，※我們當來俯伏敬拜。", "zh-hans": "主是殉道者的君王，※我们当来俯伏敬拜."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "公義的主※喜愛公義；他的眼目必看顧正直的人。", "zh-hans": "公义的主※喜爱公义；他的眼目必看顾正直的人。", "en": "The righteous Lord ※ loveth righteousness; his countenance will behold the thing that is just."} |
| `evening.benedictus_antiphon.normal` | "萬福，阿爾班，※英格蘭首位殉道者、天使君王之精兵！殉道者之花，猶如玫瑰花蕾與百合花；願你在上帝面前的祈求，能為信徒的福祉生發功效。" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals` | （原檔沒有此欄位） | [{"zh-hant": "他將世上的一切都視為無物，※以言以行，為自己在天上積蓄財寶。", "zh-hans": "他将世上的一切都视为无物，※以言以行，为自己在天上积蓄财宝."}, {"zh-hant": "此人徹悟公義，洞悉奇偉奧秘；※他祈求至高者，終列諸聖之中。", "zh-hans": "此人彻悟公义，洞悉奇伟奥秘；※他祈求至高者，终列诸圣之中."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他。", "en": "Whosoever shall confess ※ me before men, him will I confess also before my Father."}, {"zh-hant": "那在智慧中恆心不渝，※默想神聖之事，並在心中思想上帝無所不見之大能的人有福了。", "zh-hans": "那在智慧中恒心不渝，※默想神圣之事，并在心中思想上帝无所不见之大能的人有福了。", "en": "Blessed is the man ※ that continueth in wisdom, and doth meditate on holy things, and that reasoneth in his mind on the all-seeing power of God."}] |

### sanctorale_0628_irenaeus.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這位聖者為維護上帝的律法奮鬥至死，※對惡人的恐嚇毫不畏懼；因為他好像建在穩固的磐石上。", "zh-hans": "这位圣者为维护上帝的律法奋斗至死，※对恶人的恐吓毫不畏惧；因为他好像建在稳固的磐石上。", "en": "This is a holy man ※ who strove for the law of his God, even unto death; and feared not the words of evil men, forasmuch as he was established on the sure and firm Rock."} |
| `morning.invitatory.text` | "主是精修者的君王，※我們當來俯伏敬拜。" | {"zh-hant": "主是殉道者的君王，※我們當來俯伏敬拜。", "zh-hans": "主是殉道者的君王，※我们当来俯伏敬拜."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "公義的主※喜愛公義；他的眼目必看顧正直的人。", "zh-hans": "公义的主※喜爱公义；他的眼目必看顾正直的人。", "en": "The righteous Lord ※ loveth righteousness; his countenance will behold the thing that is just."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他。", "en": "Whosoever shall confess ※ me before men, him will I confess also before my Father."}, {"zh-hant": "那在智慧中恆心不渝，※默想神聖之事，並在心中思想上帝無所不見之大能的人有福了。", "zh-hans": "那在智慧中恒心不渝，※默想神圣之事，并在心中思想上帝无所不见之大能的人有福了。", "en": "Blessed is the man ※ that continueth in wisdom, and doth meditate on holy things, and that reasoneth in his mind on the all-seeing power of God."}] |

### sanctorale_0630_commemoration_of_paul.json

- 通用：`common_apostle_outside_easter`（使徒用（復活期外）.json）。
- 移除並繼承：`morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`。
- 保留原先缺失／停用狀態：`vigil`, `evening`。
- 無本日專用，改為繼承通用：`morning.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil` | （原檔沒有此欄位） | {"bible_sentences": [{"text": {"zh-hant": "在鑒察的時候，他們顯為光明，來往飛騰，如麥稭被焚的星火。他們要審判邦國，治理眾民；他們的主將作王直到永遠。", "zh-hans": "在鉴察的时候，他们显为光明，来往飞腾，如麦秸被焚的星火。他们要审判邦国，治理众民；他们的主将作王直到永远."}, "reference": {"zh-hant": "（所羅門智訓 3:8）", "zh-hans": "（所罗门智训 3:8）"}}], "psalm_antiphons": {"antiphons": [{"zh-hant": "你們要彼此相愛，※像我愛你們一樣，這是我的命令。", "zh-hans": "你们要彼此相爱，※像我爱你们一样，这是我的命令."}, {"zh-hant": "人為朋友捨命，※人的愛心沒有比這個更大的了。", "zh-hans": "人为朋友舍命，※人的爱心没有比这个更大的了."}, {"zh-hant": "主說：※你們若遵行我所命令的，就是我的朋友。", "zh-hans": "主说：※你们若遵行我所命令的，就是我的朋友."}, {"zh-hant": "締造和平的人有福了，※清心的人有福了，因為他們必得見上帝。", "zh-hans": "缔造和平的人有福了，※清心的人有福了，因为他们必得见上帝."}, {"zh-hant": "你們憑着堅忍，※就必保全性命。", "zh-hans": "你们凭着坚忍，※就必保全性命."}], "lectionary_1943": {"zh-hant": "在戰爭中你們要勇敢， ※ 與古蛇爭戰；你們必得永恆的國度，哈利路亞。", "zh-hans": "在战争中你们要勇敢， ※ 与古蛇争战；你们必得永恒的国度，哈利路亚。", "en": "Be ye valiant in warfare, ※ and contend with the old serpent; and ye shall receive an eternal kingdom, alleluia."}}, "office_hymn": {"title": "Annue, Christe, sæculorum Domine", "verses": [{"zh-hant": "一、萬古君王我主耶穌，求因聖者功德施恩；\n我眾在主前犯重罪，賴他代求得蒙赦免。", "zh-hans": "一、万古君王我主耶稣，求因圣者功德施恩；\n我众在主前犯重罪，赖他代求得蒙赦免。"}, {"zh-hant": "二、", "zh-hans": "二、"}, {"zh-hant": "三、救主求保所造之人，聖容光輝印在其身；\n莫容邪靈詭計傷害，主曾捨命救贖之民。", "zh-hans": "三、救主求保所造之人，圣容光辉印在其身；\n莫容邪灵诡计伤害，主曾舍命救赎之民。"}, {"zh-hant": "四、慈悲君王憐我囚僕，赦免罪人釋放拘囚；\n寶血所贖主之子民，賜在樂園與主同歡。", "zh-hans": "四、慈悲君王怜我囚仆，赦免罪人释放拘囚；\n宝血所赎主之子民，赐在乐园与主同欢。"}, {"zh-hant": "五、耶穌我主永享榮耀，能力尊貴至高權柄；\n與父聖靈同為上帝，掌權萬古永世無盡。阿們。", "zh-hans": "五、耶稣我主永享荣耀，能力尊贵至高权柄；\n与父圣灵同为上帝，掌权万古永世无尽。阿们。"}], "versicle": {"leader": {"zh-hant": "他們的聲音傳遍天下。", "zh-hans": "他们的声音传遍天下."}, "people": {"zh-hant": "他們的言語傳到地極。", "zh-hans": "他们的语言传到地极."}}}, "benedictus_antiphon": {"normal": {"zh-hant": "人若因我辱罵你們，※迫害你們，捏造各樣壞話毀謗你們，你們就有福了！要歡喜快樂，因為你們在天上的賞賜是很多的。", "zh-hans": "人若因我辱骂你们，※迫害你们，捏造各样坏话毁谤你们，你们就有福了！要欢喜快乐，因为你们在天上的赏赐是很多的."}}} |
| `morning.benedictus_antiphon.normal` | "我已經被澆獻，※離世的時候到了。那美好的仗我已經打過了，當跑的路我已經跑盡了，該信的道我已經守住了。從此以後，有公義的冠冕為我存留，就是按着公義審判的主到了那日要賜給我的。" | {"zh-hant": "他們要把你們交給議會，※也要在會堂裏鞭打你們。你們要為我的緣故被送到統治者和君王面前，對他們和外邦人作見證。", "zh-hans": "他们要把你们交给议会，※也要在会堂里鞭打你们。你们要为我的缘故被送到统治者和君王面前，对他们和外邦人作见证."} |
| `morning.biography` | {"title": "《論恩典與自由意志》", "source": "節選自聖奧古斯丁主教的《論恩典與自由意志》", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["使徒保羅這個人，當我們最初聽見他的事蹟時，他不但沒有任何功德，反而有許多過失。然而，他從上帝領受了恩典；上帝正是那位以善報惡者。現在讓我們看看，當他最後受苦的時刻臨近時，他是用怎樣的話寫信給提摩太的。他說：「我現在被澆奠，我離世的時候到了。那美好的仗我已經打過了，當跑的路我已經跑盡了，所信的道我已經守住了。」在這裡，他列舉自己的功德；隨之而來的，便是一頂冠冕，正如恩典曾緊接著臨到他的過失之後一樣。請聽接下來的話：「從此以後，有公義的冠冕為我存留，就是按著公義審判的主到了那日要賜給我的。」若主沒有先以慈悲父親的身分賜下恩典，祂又會以公義審判者的身分把冠冕賜給誰呢？若不是先有那使不敬虔之人稱義的恩典臨到，這冠冕又怎能稱為公義的冠冕呢？若不是先白白賜下那能夠贏得賞賜的能力，又怎能說賞賜是被贏得的呢？", "現在讓我們思想，使徒保羅究竟有什麼功德，使他有資格從主——那按著公義審判的主——那裡期待公義的冠冕；並且讓我們看看，這些功德究竟是出於他自己，還是上帝賜給他的禮物。他說：「那美好的仗我已經打過了，當跑的路我已經跑盡了，所信的道我已經守住了。」首先，若這些善工不是出於善念，它們本身就毫無價值。因此，請聽同一位保羅論到善念時所說的話。他寫信給哥林多人說：「並不是我們憑自己能承擔甚麼事，我們所能承擔的，乃是出於上帝。」", "現在讓我們逐點來考察這件事。他說：「那美好的仗我已經打過了。」我想知道，他是靠誰的力量爭戰的？是靠自己的力量嗎？還是靠從上頭所賜的力量？絕不可認為這位偉大的教師竟不認識他上帝的律法；上帝在《申命記》中說：「恐怕你心裏說：『這財富是我的力量、我手的能力得來的。』你要記念主——你的上帝，因為得財富的能力是他給你的。」再者，若一場爭戰沒有以勝利告終，又有什麼益處呢？而賜下勝利的，除了那一位還有誰呢？正是這同一位保羅所說的：「感謝上帝，使我們藉著我們的主耶穌基督得勝。」"]} | （原檔沒有此欄位） |
| `morning.commemorations` | [{"display_name": "使徒聖彼得", "antiphon": "彼得，你愛我比這些更深嗎？主阿，是的，你知道我愛你。", "versicle": {"leader": "你是彼得。", "people": "我要把我的教會建造在這磐石上。"}, "collect": {"title": "使徒聖彼得", "text": "上帝阿，主將天國的鑰匙交給了主的使徒聖彼得，即授給他捆綁和釋放的權柄；求主恩准，使我們能藉着他轉達的幫助，脫免一切罪惡的覊絆。主和聖父、聖靈，惟一上帝，一同永生，一同掌權，永世無盡。阿們。"}}] | （原檔沒有此欄位） |
| `morning.office_hymn.verses.5` | "六、讚美皆歸上帝聖父，\n永恆聖子同受頌揚；\n榮耀尊貴理當歸於，\n至聖聖靈保惠聖師。阿們。" | {"zh-hant": "六、讚美皆歸上帝聖父，\n永恆聖子同受頌揚；\n榮耀尊貴理當歸於，\n至聖聖靈保惠聖師。阿們", "zh-hans": "六、赞美皆归上帝圣父，\n永恒圣子同受颂扬；\n荣耀尊贵理当归于，\n至圣圣灵保惠圣师.阿们"} |
| `morning.psalm_antiphons.antiphons.0` | "我栽種了，※亞波羅澆灌了，惟有上帝叫他生長。哈利路亞。" | {"zh-hant": "你們要彼此相愛，※像我愛你們一樣，這是我的命令。", "zh-hans": "你们要彼此相爱，※像我爱你们一样，这是我的命令."} |
| `morning.psalm_antiphons.antiphons.1` | "所以，※我更喜歡誇自己的軟弱，好叫基督的能力覆庇我。" | {"zh-hant": "人為朋友捨命，※人的愛心沒有比這個更大的了。", "zh-hans": "人为朋友舍命，※人的爱心没有比这个更大的了."} |
| `morning.psalm_antiphons.antiphons.2` | "上帝所賜我的恩※不是徒然的，他的恩與我同在。。" | {"zh-hant": "主說：※你們若遵行我所命令的，就是我的朋友。", "zh-hans": "主说：※你们若遵行我所命令的，就是我的朋友."} |
| `morning.psalm_antiphons.antiphons.3` | "在大馬士革，※總督要捉拿我，夜裡，弟兄們用筐子將我從城牆上縋下去，依靠主的名，我脫離了他的手。" | {"zh-hant": "締造和平的人有福了，※清心的人有福了，因為他們必得見上帝。", "zh-hans": "缔造和平的人有福了，※清心的人有福了，因为他们必得见上帝."} |
| `morning.psalm_antiphons.antiphons.4` | "為了基督的名，※我被棍打了三次；被石頭打了一次；遇著船壞三次。" | {"zh-hant": "你們憑着堅忍，※就必保全性命。", "zh-hans": "你们凭着坚忍，※就必保全性命."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "他們遵守他的法度和他所賜給他們的律例。哈利路亞。", "zh-hans": "他们遵守他的法度和他所赐给他们的律例。哈利路亚。", "en": "They kept his testimonies, ※ and observed his statutes, alleluia."} |
| `evening` | （原檔沒有此欄位） | {"bible_sentences": [{"text": {"zh-hant": "在那些日子，耶穌出去，上山祈禱，整夜向上帝禱告。到了天亮，他叫門徒來，就從他們中間挑選十二個人，稱他們為使徒。", "zh-hans": "在那些日子，耶稣出去，上山祈祷，整夜向上帝祷告。到了天亮，他叫门徒来，就从他们中间挑选十二个人，称他们为使徒."}, "reference": {"zh-hant": "（路加福音 6:12-13）", "zh-hans": "（路加福音 6:12-13）"}}], "psalm_antiphons": {"antiphons": [{"zh-hant": "主起了誓，※絕不改變。你是永遠為祭司。", "zh-hans": "主起了誓，※绝不改变。你是永远为祭司."}, {"zh-hant": "主※叫他們與王子同坐。", "zh-hans": "主※叫他们与王子同坐."}, {"zh-hant": "主已解开※捆我的绳索，我要献感谢祭与主。", "zh-hans": "主已解开※捆我的绳索，我要献感谢祭与主."}, {"zh-hant": "他們※哭泣去撒谷种。", "zh-hans": "他们※哭泣去撒谷种."}, {"zh-hant": "主阿，※我極其尊敬主的朋友，他們的王權極為堅固。", "zh-hans": "主阿，※我极其尊敬主的朋友，他们的王权极为坚固."}], "lectionary_1943": {"zh-hant": "他們的王權堅固立定；※上帝啊，你的朋友大得尊榮。", "zh-hans": "他们的王权坚固立定；※上帝啊，你的朋友大得尊荣。", "en": "Firmly established ※ is their princedom; and highly honoured are thy friends, O God."}}, "office_hymn": {"title": "Jesu, Corona Virginum", "verses": [{"zh-hant": "一、諸天高唱歡欣讚歌，\n大地喜樂同聲應和；\n使徒功德崇高聖位，\n佳節良期我眾頌揚。", "zh-hans": "一、诸天高唱欢欣赞歌，\n大地喜乐同声应和；\n使徒功德崇高圣位，\n佳节良期我众颂扬."}, {"zh-hant": "二、威嚴榮耀寶座之上，\n將要審判生者死者；\n普世明燈照耀萬方，\n俯聽我等虔誠祈禱。", "zh-hans": "二、威严荣耀宝座之上，\n将要审判生者死者；\n普世明灯照耀万方，\n俯听我等虔诚祈祷."}, {"zh-hant": "三、天國門戶聽憑爾命，\n為眾敞開或作關閉；\n願藉爾等神聖權柄，\n解脫我眾諸般罪愆。", "zh-hans": "三、天国门户听凭尔命，\n为众敞开或作关闭；\n愿藉尔等神圣权柄，\n解脱我众诸般罪愆."}, {"zh-hant": "四、昔日所授神聖權能，\n疾病康健皆聽差遣；\n懇求再次醫治我靈，\n恢復聖潔剛強健壯。", "zh-hans": "四、昔日所授神圣权能，\n疾病康健皆听差遣；\n恳求再次医治我灵，\n恢复圣洁刚强健壮."}, {"zh-hant": "五、基督威嚴審判之主，\n末日時辰降臨之際；\n因其慈悲恩典眷顧，\n賜我永享天國福樂。", "zh-hans": "五、基督威严审判之主，\n末日時辰降临之际；\n因其慈悲恩典眷顾，\n赐我永享天国福乐."}, {"zh-hant": "六、讚美皆歸上帝聖父，\n永恆聖子同受頌揚；\n榮耀尊貴理當歸於，\n至聖聖靈保惠聖師。阿們。", "zh-hans": "六、赞美皆归上帝圣父，\n永恒圣子同受颂扬；\n荣耀尊贵理当归于，\n至圣圣灵保惠圣师。阿们。"}], "versicle": {"leader": {"zh-hant": "他們傳揚上帝所做的事，", "zh-hans": "他们传扬上帝所做的事，"}, "people": {"zh-hant": "並曉得祂的作為。", "zh-hans": "并晓得祂的作为."}}}, "benedictus_antiphon": {"normal": {"zh-hant": "主說：我實在告訴你們，※你們這些跟從我的人，到了萬物更新、人子坐在他榮耀寶座上的時候，你們也要坐在十二個寶座上，審判以色列十二個支派。", "zh-hans": "主说：我实在告诉你们，※你们这些跟从我的人，到了万物更新、人子坐在他荣耀宝座上的时候，你们也要坐在十二个宝座上，审判以色列十二个支派."}}} |

### sanctorale_0705_peter_and_paul_octave_7.json

- 通用：`common_apostle_outside_easter`（使徒用（復活期外）.json）。
- 移除並繼承：`morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`。
- 保留原先缺失／停用狀態：`vigil`, `evening`。
- 無本日專用，改為繼承通用：`morning.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil` | （原檔沒有此欄位） | {"bible_sentences": [{"text": {"zh-hant": "在鑒察的時候，他們顯為光明，來往飛騰，如麥稭被焚的星火。他們要審判邦國，治理眾民；他們的主將作王直到永遠。", "zh-hans": "在鉴察的时候，他们显为光明，来往飞腾，如麦秸被焚的星火。他们要审判邦国，治理众民；他们的主将作王直到永远."}, "reference": {"zh-hant": "（所羅門智訓 3:8）", "zh-hans": "（所罗门智训 3:8）"}}], "psalm_antiphons": {"antiphons": [{"zh-hant": "你們要彼此相愛，※像我愛你們一樣，這是我的命令。", "zh-hans": "你们要彼此相爱，※像我爱你们一样，这是我的命令."}, {"zh-hant": "人為朋友捨命，※人的愛心沒有比這個更大的了。", "zh-hans": "人为朋友舍命，※人的爱心没有比这个更大的了."}, {"zh-hant": "主說：※你們若遵行我所命令的，就是我的朋友。", "zh-hans": "主说：※你们若遵行我所命令的，就是我的朋友."}, {"zh-hant": "締造和平的人有福了，※清心的人有福了，因為他們必得見上帝。", "zh-hans": "缔造和平的人有福了，※清心的人有福了，因为他们必得见上帝."}, {"zh-hant": "你們憑着堅忍，※就必保全性命。", "zh-hans": "你们凭着坚忍，※就必保全性命."}], "lectionary_1943": {"zh-hant": "在戰爭中你們要勇敢， ※ 與古蛇爭戰；你們必得永恆的國度，哈利路亞。", "zh-hans": "在战争中你们要勇敢， ※ 与古蛇争战；你们必得永恒的国度，哈利路亚。", "en": "Be ye valiant in warfare, ※ and contend with the old serpent; and ye shall receive an eternal kingdom, alleluia."}}, "office_hymn": {"title": "Annue, Christe, sæculorum Domine", "verses": [{"zh-hant": "一、萬古君王我主耶穌，求因聖者功德施恩；\n我眾在主前犯重罪，賴他代求得蒙赦免。", "zh-hans": "一、万古君王我主耶稣，求因圣者功德施恩；\n我众在主前犯重罪，赖他代求得蒙赦免。"}, {"zh-hant": "二、", "zh-hans": "二、"}, {"zh-hant": "三、救主求保所造之人，聖容光輝印在其身；\n莫容邪靈詭計傷害，主曾捨命救贖之民。", "zh-hans": "三、救主求保所造之人，圣容光辉印在其身；\n莫容邪灵诡计伤害，主曾舍命救赎之民。"}, {"zh-hant": "四、慈悲君王憐我囚僕，赦免罪人釋放拘囚；\n寶血所贖主之子民，賜在樂園與主同歡。", "zh-hans": "四、慈悲君王怜我囚仆，赦免罪人释放拘囚；\n宝血所赎主之子民，赐在乐园与主同欢。"}, {"zh-hant": "五、耶穌我主永享榮耀，能力尊貴至高權柄；\n與父聖靈同為上帝，掌權萬古永世無盡。阿們。", "zh-hans": "五、耶稣我主永享荣耀，能力尊贵至高权柄；\n与父圣灵同为上帝，掌权万古永世无尽。阿们。"}], "versicle": {"leader": {"zh-hant": "他們的聲音傳遍天下。", "zh-hans": "他们的声音传遍天下."}, "people": {"zh-hant": "他們的言語傳到地極。", "zh-hans": "他们的语言传到地极."}}}, "benedictus_antiphon": {"normal": {"zh-hant": "人若因我辱罵你們，※迫害你們，捏造各樣壞話毀謗你們，你們就有福了！要歡喜快樂，因為你們在天上的賞賜是很多的。", "zh-hans": "人若因我辱骂你们，※迫害你们，捏造各样坏话毁谤你们，你们就有福了！要欢喜快乐，因为你们在天上的赏赐是很多的."}}} |
| `morning.benedictus_antiphon.normal` | "基督的兩位榮耀使徒※生時相悅相愛，死時也不分離。" | {"zh-hant": "他們要把你們交給議會，※也要在會堂裏鞭打你們。你們要為我的緣故被送到統治者和君王面前，對他們和外邦人作見證。", "zh-hans": "他们要把你们交给议会，※也要在会堂里鞭打你们。你们要为我的缘故被送到统治者和君王面前，对他们和外邦人作见证."} |
| `morning.office_hymn.verses.5` | "六、讚美皆歸上帝聖父，\n永恆聖子同受頌揚；\n榮耀尊貴理當歸於，\n至聖聖靈保惠聖師。阿們。" | {"zh-hant": "六、讚美皆歸上帝聖父，\n永恆聖子同受頌揚；\n榮耀尊貴理當歸於，\n至聖聖靈保惠聖師。阿們", "zh-hans": "六、赞美皆归上帝圣父，\n永恒圣子同受颂扬；\n荣耀尊贵理当归于，\n至圣圣灵保惠圣师.阿们"} |
| `morning.office_hymn.versicle.leader` | "他們的聲音傳遍天下。" | {"zh-hant": "他們傳揚上帝所做的事，", "zh-hans": "他们传扬上帝所做的事，"} |
| `morning.office_hymn.versicle.people` | "他們的言語傳到地極。" | {"zh-hant": "並曉得祂的作為。", "zh-hans": "并晓得祂的作为."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "他們遵守他的法度和他所賜給他們的律例。哈利路亞。", "zh-hans": "他们遵守他的法度和他所赐给他们的律例。哈利路亚。", "en": "They kept his testimonies, ※ and observed his statutes, alleluia."} |
| `evening` | （原檔沒有此欄位） | {"bible_sentences": [{"text": {"zh-hant": "在那些日子，耶穌出去，上山祈禱，整夜向上帝禱告。到了天亮，他叫門徒來，就從他們中間挑選十二個人，稱他們為使徒。", "zh-hans": "在那些日子，耶稣出去，上山祈祷，整夜向上帝祷告。到了天亮，他叫门徒来，就从他们中间挑选十二个人，称他们为使徒."}, "reference": {"zh-hant": "（路加福音 6:12-13）", "zh-hans": "（路加福音 6:12-13）"}}], "psalm_antiphons": {"antiphons": [{"zh-hant": "主起了誓，※絕不改變。你是永遠為祭司。", "zh-hans": "主起了誓，※绝不改变。你是永远为祭司."}, {"zh-hant": "主※叫他們與王子同坐。", "zh-hans": "主※叫他们与王子同坐."}, {"zh-hant": "主已解开※捆我的绳索，我要献感谢祭与主。", "zh-hans": "主已解开※捆我的绳索，我要献感谢祭与主."}, {"zh-hant": "他們※哭泣去撒谷种。", "zh-hans": "他们※哭泣去撒谷种."}, {"zh-hant": "主阿，※我極其尊敬主的朋友，他們的王權極為堅固。", "zh-hans": "主阿，※我极其尊敬主的朋友，他们的王权极为坚固."}], "lectionary_1943": {"zh-hant": "他們的王權堅固立定；※上帝啊，你的朋友大得尊榮。", "zh-hans": "他们的王权坚固立定；※上帝啊，你的朋友大得尊荣。", "en": "Firmly established ※ is their princedom; and highly honoured are thy friends, O God."}}, "office_hymn": {"title": "Jesu, Corona Virginum", "verses": [{"zh-hant": "一、諸天高唱歡欣讚歌，\n大地喜樂同聲應和；\n使徒功德崇高聖位，\n佳節良期我眾頌揚。", "zh-hans": "一、诸天高唱欢欣赞歌，\n大地喜乐同声应和；\n使徒功德崇高圣位，\n佳节良期我众颂扬."}, {"zh-hant": "二、威嚴榮耀寶座之上，\n將要審判生者死者；\n普世明燈照耀萬方，\n俯聽我等虔誠祈禱。", "zh-hans": "二、威严荣耀宝座之上，\n将要审判生者死者；\n普世明灯照耀万方，\n俯听我等虔诚祈祷."}, {"zh-hant": "三、天國門戶聽憑爾命，\n為眾敞開或作關閉；\n願藉爾等神聖權柄，\n解脫我眾諸般罪愆。", "zh-hans": "三、天国门户听凭尔命，\n为众敞开或作关闭；\n愿藉尔等神圣权柄，\n解脱我众诸般罪愆."}, {"zh-hant": "四、昔日所授神聖權能，\n疾病康健皆聽差遣；\n懇求再次醫治我靈，\n恢復聖潔剛強健壯。", "zh-hans": "四、昔日所授神圣权能，\n疾病康健皆听差遣；\n恳求再次医治我灵，\n恢复圣洁刚强健壮."}, {"zh-hant": "五、基督威嚴審判之主，\n末日時辰降臨之際；\n因其慈悲恩典眷顧，\n賜我永享天國福樂。", "zh-hans": "五、基督威严审判之主，\n末日時辰降临之际；\n因其慈悲恩典眷顾，\n赐我永享天国福乐."}, {"zh-hant": "六、讚美皆歸上帝聖父，\n永恆聖子同受頌揚；\n榮耀尊貴理當歸於，\n至聖聖靈保惠聖師。阿們。", "zh-hans": "六、赞美皆归上帝圣父，\n永恒圣子同受颂扬；\n荣耀尊贵理当归于，\n至圣圣灵保惠圣师。阿们。"}], "versicle": {"leader": {"zh-hant": "他們傳揚上帝所做的事，", "zh-hans": "他们传扬上帝所做的事，"}, "people": {"zh-hant": "並曉得祂的作為。", "zh-hans": "并晓得祂的作为."}}}, "benedictus_antiphon": {"normal": {"zh-hant": "主說：我實在告訴你們，※你們這些跟從我的人，到了萬物更新、人子坐在他榮耀寶座上的時候，你們也要坐在十二個寶座上，審判以色列十二個支派。", "zh-hans": "主说：我实在告诉你们，※你们这些跟从我的人，到了万物更新、人子坐在他荣耀宝座上的时候，你们也要坐在十二个宝座上，审判以色列十二个支派."}}} |

### sanctorale_0706_peter_and_paul_octave_8.json

- 通用：`common_apostle_outside_easter`（使徒用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `morning.bible_sentences`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `morning.bible_sentences`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "至尊榮耀的使徒們，※是教會的柱石，真理的喉舌，點燃閃耀的明燈；藉著聖靈之火，你們驅散了謬誤的黑暗，光照了寰宇：請為我們向揀選了你們的上帝台前代求。" | {"zh-hant": "人若因我辱罵你們，※迫害你們，捏造各樣壞話毀謗你們，你們就有福了！要歡喜快樂，因為你們在天上的賞賜是很多的。", "zh-hans": "人若因我辱骂你们，※迫害你们，捏造各样坏话毁谤你们，你们就有福了！要欢喜快乐，因为你们在天上的赏赐是很多的."} |
| `vigil.office_hymn.title` | "Aurea luce et decore roseo" | "Annue, Christe, sæculorum Domine" |
| `vigil.office_hymn.verses.0` | "一、金色光輝燦爛玫瑰美麗非凡，\n光中之光親自照耀普世寰宇；\n殉道神聖榮冠裝飾今日良辰，\n為眾懺悔之人帶來赦罪恩典。" | {"zh-hant": "一、萬古君王我主耶穌，求因聖者功德施恩；\n我眾在主前犯重罪，賴他代求得蒙赦免。", "zh-hans": "一、万古君王我主耶稣，求因圣者功德施恩；\n我众在主前犯重罪，赖他代求得蒙赦免。"} |
| `vigil.office_hymn.verses.1` | "二、天國神聖守衛普世雄辯導師，\n審判世界威嚴明燈啟迪人類；\n因著十架凱旋因著聖劍得勝，\n榮冠今加爾身永生不朽元勳。" | {"zh-hant": "二、", "zh-hans": "二、"} |
| `vigil.office_hymn.verses.2` | "三、善牧彼得懇求爾之祈禱不息，\n為我等代求以斬斷罪惡鎖鏈；\n因爾自古得授天上神聖權柄，\n得以開啟或者關閉樂園之門。" | {"zh-hant": "三、救主求保所造之人，聖容光輝印在其身；\n莫容邪靈詭計傷害，主曾捨命救贖之民。", "zh-hans": "三、救主求保所造之人，圣容光辉印在其身；\n莫容邪灵诡计伤害，主曾舍命救赎之民。"} |
| `vigil.office_hymn.verses.3` | "四、智者保羅願藉爾之昭彰真道，\n引導我等德行提升心靈向天；\n直到完美真知豐沛傾注我身，\n那有限與殘缺盡皆消逝無蹤。" | {"zh-hant": "四、慈悲君王憐我囚僕，赦免罪人釋放拘囚；\n寶血所贖主之子民，賜在樂園與主同歡。", "zh-hans": "四、慈悲君王怜我囚仆，赦免罪人释放拘囚；\n宝血所赎主之子民，赐在乐园与主同欢。"} |
| `vigil.office_hymn.verses.4` | "五、雙枝橄欖同融神聖團契合一，\n合意獻上祈禱使我克己修身；\n堅定信仰之中我等日日成長，\n勇敢盼望倍加充滿仁愛之德。" | {"zh-hant": "五、耶穌我主永享榮耀，能力尊貴至高權柄；\n與父聖靈同為上帝，掌權萬古永世無盡。阿們。", "zh-hans": "五、耶稣我主永享荣耀，能力尊贵至高权柄；\n与父圣灵同为上帝，掌权万古永世无尽。阿们。"} |
| `vigil.office_hymn.verses.5` | "六、永恆榮耀歸於至福三一上帝，\n讚頌尊崇大能至高皆歸於主；\n三一亦是唯一威嚴掌權統御，\n從今時直到萬世代永無窮盡。阿們。" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0` | "申初禱告的時候，※彼得和約翰上聖殿去。" | {"zh-hant": "你們要彼此相愛，※像我愛你們一樣，這是我的命令。", "zh-hans": "你们要彼此相爱，※像我爱你们一样，这是我的命令."} |
| `vigil.psalm_antiphons.antiphons.1` | "彼得對那乞丐說：※金銀我都沒有，※但我把我有的給你。" | {"zh-hant": "人為朋友捨命，※人的愛心沒有比這個更大的了。", "zh-hans": "人为朋友舍命，※人的爱心没有比这个更大的了."} |
| `vigil.psalm_antiphons.antiphons.2` | "天使對彼得說：※披上外衣，跟我來。" | {"zh-hant": "主說：※你們若遵行我所命令的，就是我的朋友。", "zh-hans": "主说：※你们若遵行我所命令的，就是我的朋友."} |
| `vigil.psalm_antiphons.antiphons.3` | "彼得說：※主差遣他的使者，救我脫離希律的手。哈利路亞。" | {"zh-hant": "締造和平的人有福了，※清心的人有福了，因為他們必得見上帝。", "zh-hans": "缔造和平的人有福了，※清心的人有福了，因为他们必得见上帝."} |
| `vigil.psalm_antiphons.antiphons.4` | "主說：你是彼得，※我要把我的教會建造在這磐石上。" | {"zh-hant": "你們憑着堅忍，※就必保全性命。", "zh-hans": "你们凭着坚忍，※就必保全性命."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "在戰爭中你們要勇敢， ※ 與古蛇爭戰；你們必得永恆的國度，哈利路亞。", "zh-hans": "在战争中你们要勇敢， ※ 与古蛇争战；你们必得永恒的国度，哈利路亚。", "en": "Be ye valiant in warfare, ※ and contend with the old serpent; and ye shall receive an eternal kingdom, alleluia."} |
| `morning.benedictus_antiphon.normal` | "他們是兩棵橄欖樹，※是在主面前兩個点燃的燈臺。他们有權柄關閉天雲，並打開天之門，因為他們的口舌成為天國的鑰匙。哈利路亞。" | {"zh-hant": "他們要把你們交給議會，※也要在會堂裏鞭打你們。你們要為我的緣故被送到統治者和君王面前，對他們和外邦人作見證。", "zh-hans": "他们要把你们交给议会，※也要在会堂里鞭打你们。你们要为我的缘故被送到统治者和君王面前，对他们和外邦人作见证."} |
| `morning.biography` | {"title": "摘自梅塔弗拉斯提斯編撰的文獻", "source": "節選自聖金口約翰的講道。", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["蒙福的使徒啊，你們為我們勞苦如此之多，我們該獻上什麼感謝來報答你們呢？當我想起你，彼得啊，我便驚歎不已！當我想到你，保羅啊，我的心便百感交集，不禁潸然淚下！當我瞻仰你們所受的苦難時，我竟不知當說什麼，或該如何言語！你們使多少監牢化為聖潔？使多少鎖鏈成為尊貴？你們忍受了多少酷刑？承擔了多少凌辱？你們如何背負了基督？你們又如何藉著自己的傳道，使眾教會歡喜快樂？誠然，你們的舌頭是蒙福的器皿；你們的肢體流血，全是為了教會的緣故。你們在萬事上都成了基督的追隨者。「你們的聲音傳遍全地，你們的言語傳到地極。」", "歡喜吧，彼得啊！你蒙賜恩典，得以在基督十字架的木頭上歡欣。為了顯出與你主某種相似之處，你甘願被釘十字架；只是你未如祂那般直立受釘，而是頭朝向地，宛如一個要從地上步入天上的人。那刺透你聖潔肢體的釘子是有福的。你懷著確實而堅定的盼望，將自己的靈魂交託在主手中；你是祂忠信的僕人，也是祂新婦——教會的忠僕；你以火熱的心，比眾使徒更熱切地愛了主。", "你也當歡喜，蒙福的保羅啊！你的頭顱雖被刀劍斬下，但你無畏的熱忱，絕非言語所能表達。那將你神聖身軀斬斷的，是怎樣的一把劍啊！你這身軀原是主作工的器皿，配得諸天驚歎，全地敬仰。那暢飲你鮮血的，是怎樣的一處地方啊！你的血濺落在那擊殺你之人的衣裳上，宛若乳滴，竟使那殘暴之徒與他的同伴，奇妙地變得溫和而忠信。但願我能以那把劍為冠冕，並將彼得的釘子鑲嵌其上，作為王冠上的寶石。"]} | （原檔沒有此欄位） |
| `morning.invitatory.text` | "我主基督，萬王之王，祂因真福使徒聖彼得與聖保羅的雙雙蒙難殉道，顯揚祂的榮耀，※我們當來俯伏敬拜。" | {"zh-hant": "主是使徒們的君王，※我們當來俯伏敬拜。", "zh-hans": "主是使徒们的君王，※我们当来俯伏敬拜."} |
| `morning.invitatory_hymn.title` | "Aurea luce et decore roseo" | "使徒心中充滿悲傷" |
| `morning.invitatory_hymn.verses.0` | "一、金色光輝燦爛玫瑰美麗非凡，\n光中之光親自照耀普世寰宇；\n殉道神聖榮冠裝飾今日良辰，\n為眾懺悔之人帶來赦罪恩典。" | {"zh-hant": "一、基督君王永恆恩賜，\n我們頌唱使徒榮耀；\n獻上讚美詩歌時刻，\n感恩之心驅散憂愁。", "zh-hans": "一、基督君王永恒恩赐，\n我们颂唱使徒荣耀；\n献上赞美诗歌时刻，\n感恩之心驱散忧愁."} |
| `morning.invitatory_hymn.verses.1` | "二、天國神聖守衛普世雄辯導師，\n審判世界威嚴明燈啟迪人類；\n因著十架凱旋因著聖劍得勝，\n榮冠今加爾身永生不朽元勳。" | {"zh-hant": "二、教會以此君王為榮，\n得勝元帥戰士統領；\n天庭勇士光耀四方，\n普世明燈照亮萬邦。", "zh-hans": "二、教会以此君王为荣，\n得胜元帅战士统领；\n天庭勇士光耀四方，\n普世明灯照亮万邦."} |
| `morning.invitatory_hymn.verses.2` | "三、善牧彼得懇求爾之祈禱不息，\n為我等代求以斬斷罪惡鎖鏈；\n因爾自古得授天上神聖權柄，\n得以開啟或者關閉樂園之門。" | {"zh-hant": "三、聖徒信心如此渴慕，\n堅毅盼望永不衰退，\n基督之愛無懼無羞，\n戰勝世間諸般權勢。", "zh-hans": "三、圣徒信心如此渴慕，\n坚毅盼望永不衰退，\n基督之爱无惧无羞，\n战胜世间诸般权势."} |
| `morning.invitatory_hymn.verses.3` | "四、智者保羅願藉爾之昭彰真道，\n引導我等德行提升心靈向天；\n直到完美真知豐沛傾注我身，\n那有限與殘缺盡皆消逝無蹤。" | {"zh-hant": "四、聖父榮光藉此彰顯，\n聖子旨意於此成全；\n聖靈喜悅充滿其中，\n天軍天使同聲歡欣。", "zh-hans": "四、圣父荣光藉此彰显，\n圣子旨意于此成全；\n圣灵喜悦充满其中，\n天军天使同声欢欣."} |
| `morning.invitatory_hymn.verses.4` | "五、雙枝橄欖同融神聖團契合一，\n合意獻上祈禱使我克己修身；\n堅定信仰之中我等日日成長，\n勇敢盼望倍加充滿仁愛之德。" | {"zh-hant": "五、救主垂聽愛的祈求，\n使我與此榮耀天軍，\n藉主無盡恩典眷顧，\n同享天國永恆福樂。阿們。", "zh-hans": "五、救主垂听爱的祈求，\n使我与此荣耀天军，\n藉主无尽恩典眷顾，\n同享天国永恒福乐。阿们。"} |
| `morning.invitatory_hymn.verses.5` | "六、永恆榮耀歸於至福三一上帝，\n讚頌尊崇大能至高皆歸於主；\n三一亦是唯一威嚴掌權統御，\n從今時直到萬世代永無窮盡。阿們。" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.5` | "六、讚美皆歸上帝聖父，\n永恆聖子同受頌揚；\n榮耀尊貴理當歸於，\n至聖聖靈保惠聖師。阿們。" | {"zh-hant": "六、讚美皆歸上帝聖父，\n永恆聖子同受頌揚；\n榮耀尊貴理當歸於，\n至聖聖靈保惠聖師。阿們", "zh-hans": "六、赞美皆归上帝圣父，\n永恒圣子同受颂扬；\n荣耀尊贵理当归于，\n至圣圣灵保惠圣师.阿们"} |
| `morning.psalm_antiphons.antiphons.0` | "申初禱告的時候，※彼得和約翰上聖殿去。" | {"zh-hant": "你們要彼此相愛，※像我愛你們一樣，這是我的命令。", "zh-hans": "你们要彼此相爱，※像我爱你们一样，这是我的命令."} |
| `morning.psalm_antiphons.antiphons.1` | "彼得對那乞丐說：※金銀我都沒有，※但我把我有的給你。" | {"zh-hant": "人為朋友捨命，※人的愛心沒有比這個更大的了。", "zh-hans": "人为朋友舍命，※人的爱心没有比这个更大的了."} |
| `morning.psalm_antiphons.antiphons.2` | "天使對彼得說：※披上外衣，跟我來。" | {"zh-hant": "主說：※你們若遵行我所命令的，就是我的朋友。", "zh-hans": "主说：※你们若遵行我所命令的，就是我的朋友."} |
| `morning.psalm_antiphons.antiphons.3` | "彼得說：※主差遣他的使者，救我脫離希律的手。哈利路亞。" | {"zh-hant": "締造和平的人有福了，※清心的人有福了，因為他們必得見上帝。", "zh-hans": "缔造和平的人有福了，※清心的人有福了，因为他们必得见上帝."} |
| `morning.psalm_antiphons.antiphons.4` | "主說：你是彼得，※我要把我的教會建造在這磐石上。" | {"zh-hant": "你們憑着堅忍，※就必保全性命。", "zh-hans": "你们凭着坚忍，※就必保全性命."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "他們遵守他的法度和他所賜給他們的律例。哈利路亞。", "zh-hans": "他们遵守他的法度和他所赐给他们的律例。哈利路亚。", "en": "They kept his testimonies, ※ and observed his statutes, alleluia."} |
| `evening.benedictus_antiphon.normal` | "主說：※到了萬物更新、人子坐在他榮耀寶座上的時候，你們也要坐在十二個寶座上，審判以色列十二個支派。" | {"zh-hant": "主說：我實在告訴你們，※你們這些跟從我的人，到了萬物更新、人子坐在他榮耀寶座上的時候，你們也要坐在十二個寶座上，審判以色列十二個支派。", "zh-hans": "主说：我实在告诉你们，※你们这些跟从我的人，到了万物更新、人子坐在他荣耀宝座上的时候，你们也要坐在十二个宝座上，审判以色列十二个支派."} |
| `evening.office_hymn.title` | "Aurea luce et decore roseo" | "Jesu, Corona Virginum" |
| `evening.office_hymn.verses.0` | "一、金色光輝燦爛玫瑰美麗非凡，\n光中之光親自照耀普世寰宇；\n殉道神聖榮冠裝飾今日良辰，\n為眾懺悔之人帶來赦罪恩典。" | {"zh-hant": "一、諸天高唱歡欣讚歌，\n大地喜樂同聲應和；\n使徒功德崇高聖位，\n佳節良期我眾頌揚。", "zh-hans": "一、诸天高唱欢欣赞歌，\n大地喜乐同声应和；\n使徒功德崇高圣位，\n佳节良期我众颂扬."} |
| `evening.office_hymn.verses.1` | "二、天國神聖守衛普世雄辯導師，\n審判世界威嚴明燈啟迪人類；\n因著十架凱旋因著聖劍得勝，\n榮冠今加爾身永生不朽元勳。" | {"zh-hant": "二、威嚴榮耀寶座之上，\n將要審判生者死者；\n普世明燈照耀萬方，\n俯聽我等虔誠祈禱。", "zh-hans": "二、威严荣耀宝座之上，\n将要审判生者死者；\n普世明灯照耀万方，\n俯听我等虔诚祈祷."} |
| `evening.office_hymn.verses.2` | "三、善牧彼得懇求爾之祈禱不息，\n為我等代求以斬斷罪惡鎖鏈；\n因爾自古得授天上神聖權柄，\n得以開啟或者關閉樂園之門。" | {"zh-hant": "三、天國門戶聽憑爾命，\n為眾敞開或作關閉；\n願藉爾等神聖權柄，\n解脫我眾諸般罪愆。", "zh-hans": "三、天国门户听凭尔命，\n为众敞开或作关闭；\n愿藉尔等神圣权柄，\n解脱我众诸般罪愆."} |
| `evening.office_hymn.verses.3` | "四、智者保羅願藉爾之昭彰真道，\n引導我等德行提升心靈向天；\n直到完美真知豐沛傾注我身，\n那有限與殘缺盡皆消逝無蹤。" | {"zh-hant": "四、昔日所授神聖權能，\n疾病康健皆聽差遣；\n懇求再次醫治我靈，\n恢復聖潔剛強健壯。", "zh-hans": "四、昔日所授神圣权能，\n疾病康健皆听差遣；\n恳求再次医治我灵，\n恢复圣洁刚强健壮."} |
| `evening.office_hymn.verses.4` | "五、雙枝橄欖同融神聖團契合一，\n合意獻上祈禱使我克己修身；\n堅定信仰之中我等日日成長，\n勇敢盼望倍加充滿仁愛之德。" | {"zh-hant": "五、基督威嚴審判之主，\n末日時辰降臨之際；\n因其慈悲恩典眷顧，\n賜我永享天國福樂。", "zh-hans": "五、基督威严审判之主，\n末日時辰降临之际；\n因其慈悲恩典眷顾，\n赐我永享天国福乐."} |
| `evening.office_hymn.verses.5` | "六、永恆榮耀歸於至福三一上帝，\n讚頌尊崇大能至高皆歸於主；\n三一亦是唯一威嚴掌權統御，\n從今時直到萬世代永無窮盡。阿們。" | {"zh-hant": "六、讚美皆歸上帝聖父，\n永恆聖子同受頌揚；\n榮耀尊貴理當歸於，\n至聖聖靈保惠聖師。阿們。", "zh-hans": "六、赞美皆归上帝圣父，\n永恒圣子同受颂扬；\n荣耀尊贵理当归于，\n至圣圣灵保惠圣师。阿们。"} |
| `evening.office_hymn.versicle.leader` | "眾人傳揚上帝所做的事，" | {"zh-hant": "他們傳揚上帝所做的事，", "zh-hans": "他们传扬上帝所做的事，"} |
| `evening.office_hymn.versicle.people` | "並曉得上帝的作為。" | {"zh-hant": "並曉得祂的作為。", "zh-hans": "并晓得祂的作为."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "他們的王權堅固立定；※上帝啊，你的朋友大得尊榮。", "zh-hans": "他们的王权坚固立定；※上帝啊，你的朋友大得尊荣。", "en": "Firmly established ※ is their princedom; and highly honoured are thy friends, O God."} |

### sanctorale_0707_cyril_and_methodius.json

- 通用：`common_confessors_outside_easter`（多位精修者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["區利羅與美多德兄弟二人，生於帖撒羅尼迦的一個元老家族；後來他們棄絕了世俗的尊榮，成為了司祭與修士。他們曾在君士坦丁堡求學。區利羅留在那裡擔任司祭，並成為聖智大教堂的圖書館長，同時也在大學中任教。在這東方世界的首都裡，他的聲望變得極高，以至於因其卓越的學識被尊稱為「哲學家」。但兄長美多德起初在東部帝國的一個行省中擔任總督，後來退隱至一座修道院。856年，區利羅前往巴格達宣教；後來又在居住於克里米亞以外地區的可薩人中間勞苦做工，許多人因而歸信耶穌基督。在這後期的宣教使命中，美多德也予以協助；之後他返回君士坦丁堡，成為波利克倫修道院的院長。到了862年，當摩拉維亞親王拉斯提斯拉夫請求派遣福音工人時，區利羅與美多德被派往他那裡。他們以極大的能力與勤勉，投入使靈魂歸化基督的聖工；不久之後，摩拉維亞也歡喜地順服於基督。為此，他們的學識發揮了極大作用，因為有必要將斯拉夫語整理成文字，好用這種語言來翻譯聖經與禮儀。因此，區利羅創製了一套字母——後來由他的跟隨者加以改良，被稱為「區利羅字母」——藉此能夠恰當地表達斯拉夫人的語言。由於區利羅與美多德的著作，他們便成為了斯拉夫文學之父。", "然而，日耳曼的主教們——他們並不隸屬君士坦丁堡宗主教區，而是隸屬羅馬——因區利羅與美多德在禮儀中使用通俗語言而反對他們。為此，兄弟二人上訴於羅馬並親自前往；他們還帶上了據稱是聖教宗革利免一世（Saint Pope Clement I）的聖髑，這是區利羅在赫爾松所尋獲的。教宗亞德里安二世（Adrian II）隨後作出裁決：兄弟二人應被祝聖為主教，使他們能夠按立自己的司祭；此外，他們應當繼續在禮儀中使用本地語言。區利羅在恩寵上而非年歲上顯得更為老練；不久之後，他於羅馬逝世，即869年2月14日，最終被安奉於聖革利免大殿內，緊鄰著那位殉道者的聖髑。美多德則返回摩拉維亞，在基督信仰中堅固潘諾尼亞人、保加利亞人和達爾馬提亞人，並大力勞苦，使科林多人歸向敬拜獨一真上帝。", "然而，美多德又再次在亞德里安的繼任者——教宗約翰八世面前，被控在信仰上不純正；因此他被召往羅馬，在那裡輕易地駁倒了這些指控。當他指明自己在公共崇拜中使用斯拉夫語，是出於正當理由、得到教宗亞德里安的允准，且絲毫不違背聖經時，約翰八世便以書面形式確認了他的大主教權柄，以及他在斯拉夫人中間的宣教使命。於是美多德回到了摩拉維亞，在那裡他因先前反對他的人而遭受許多苦難；那些人依然持續企圖破壞他所完成的一切。他因使徒般的勞苦與這持續不斷的迫害而耗盡心力，於885年4月6日安息主懷。這兩位聖徒的慶日，長久以來已在斯拉夫民族中被慶祝，並於1880年被列入西方教會曆之中。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |

### sanctorale_0708_elizabeth_of_portugal.json

- 通用：`common_holy_woman_outside_easter`（一位聖婦用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["伊麗莎白生於1271年，是亞拉岡的彼得三世之女。當時彼得三世僅為王位繼承人。她以其伯祖母——匈牙利的聖伊麗莎白之名而受洗，但人們常以其名字的西班牙語形式稱呼她為伊莎貝爾。她終生致力於締造和平；事實上，她的促和之舉始於她出生之時。她的降生促成了其父與祖父（即當時的國王）之間的和解，此前二人水火不容，以致整個王國分裂為相互仇視的派系。蒙上帝恩典，她在成長的過程中對財富與世俗的榮耀淡然處之，在屬天之道上虔敬度日，在世俗之事上亦充滿智慧。這令她的父親十分欣慰，並預言她將成為所有親族與臣民的祝福。他的預言的確應驗了。十二歲時，她被許配給葡萄牙國王迪尼什。（這位國王在治理國政上確是一位英勇公正的君主，但在私生活中卻自私且充滿罪愆。）她敬重並愛護他，始終努力幫助他在上帝與人面前和睦度日，藉此成就了許多善工。", "她像撫育自己的親生兒女一般，撫養國王的私生子女，並竭力教導他們如上帝的兒女般生活。她傾注心血，救濟全國各地貧苦無依的百姓。與此同時，她始終持守每日恆切祈禱與研讀神聖典籍的定例。她的丈夫對她的美貌與財富十分喜悅，卻遠勝於對她美德與才華的欣賞，因為他常對她冷酷無情。在他繼承父位登基後，她身為王后贏得了臣民的敬重。最終，就連國王也無法抗拒她的良善；在他臨終前不久，因著她的引導，他全心轉向了上帝，對自己的罪行生出真實的悔改，並盡其所能為此作出補贖。然而，他們的兒子阿方索在成長過程中，因認為父親偏愛那些私生子，變得陰鬱且叛逆。他曾兩度舉兵反叛父親，而伊麗莎白亦兩度促成了這對父子的和解；當她的懇求無濟於事時，她便親自騎馬來到兩軍對陣的戰場中間，成功要求雙方停戰並接受仲裁。她也曾化解了卡斯提爾國王斐迪南四世與一位覬覦王位的宗親之間的戰爭；之後又再次弭平了這位斐迪南與她自己的兄弟、亞拉岡國王詹姆斯二世之間的干戈。還有一次，當她的兒子（即當時的葡萄牙國王阿方索四世）向其女婿（即她的孫女婿，卡斯提爾國王阿方索九世）開戰時，她再次為他們締造了長久的和平。她甚至為此冒了生命危險，因為當時她已年邁體弱，難以承受前往交戰邊境的旅途勞頓。", "她生平最主要的善工之一，是在科英布拉為貧窮克萊爾修女會建造了一座修道院。在丈夫離世後，她退居於此，並穿上了該會的會衣。由於她手頭上仍有許多重大善工（例如她為孤兒和棄嬰建立的機構，以及為悔罪婦女設立的庇護所），她選擇以第三會會士的身份宣發聖願，而非成為一名受隱修限制的克萊爾會修女，以便能自由地監管這些機構。1336年7月4日，她在六十五歲時安息主懷。她最後一次締造和平的任務所帶來的艱辛使她染病，並最終致命。她被安葬在科英布拉的修女會教堂中；並於1625年列入聖品。關於她，人們傳頌著如同匈牙利的聖伊麗莎白那般的「玫瑰奇蹟」。"]} | （原檔沒有此欄位） |
| `morning.invitatory.text` | "在聖伊麗莎白的隆重慶節中，※我們當來俯伏敬拜上帝。" | {"zh-hant": "在聖（某某）的隆重慶節中，※我們當來俯伏敬拜上帝。", "zh-hans": "在圣（某某）的隆重庆节中，※我们当来俯伏敬拜上帝."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |

### sanctorale_0709_john_fisher_and_thomas_more.json

- 通用：`common_martyrs_outside_easter`（多位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "諸聖藉著信，※制伏了敵國，行了公義，得了應許。", "zh-hans": "诸圣藉着信，※制伏了敌国，行了公义，得了应许。", "en": "The Saints through faith ※subdued kingdoms, they wrought righteousness, they obtained the promises."} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["這位約翰·費雪是一位司祭，在英王亨利七世時期，他被任命為羅徹斯特主教，治理該教區達三十三年之久，並藉著他的勞苦、禁食與其他許多善工，熱切地建立該教會。起初，他特別受到英王亨利八世的敬愛；但後來，當國王意圖撤銷自己的婚姻時，這位聖人因極力勸阻國王此舉，而招致國王的忌恨。", "約翰主教與王國大法官托馬斯·莫爾一同拒絕了針對國王婚姻所制定的考驗誓言，他因此被投入倫敦塔，並被國會法案剝奪了主教職位。當教皇聽聞此事後，認為羅馬樞機的尊貴身分或許能成為阻擋國王處死約翰的障礙，因此任命他為樞機主教；然而，國王為此勃然大怒，下令將這位學識淵博、無比神聖且年事已高的主教押上審判席，並在那裡對他宣判死刑；1535年6月22日，蒙福的約翰被押往塔丘行刑。", "此後，他的遺體被赤身露體地棄置了一天，之後才被兩名士兵秘密掩埋；但最終，他的遺體與神聖的托馬斯·莫爾的遺體一同被移入倫敦塔內。他的頭顱被掛在倫敦橋的木桿上示眾，但隨後被拋入河中，以免信徒將其視為尊崇的對象。1935年，約翰·費雪與他的同道殉道者托馬斯·莫爾被正式宣聖列入聖品。", "托馬斯·莫爾成為了英格蘭最卓越的法官之一。他與加爾都西會的修士們交情甚篤，年輕時他曾在那裡以客人的身分居住了四年，旨在更嚴謹地事奉上帝。在那裡，他學會了以苦衣和鞭笞來苦待己身、叫身子服從，並且終其一生，他未曾停止身上常帶著耶穌的死。他為國家效力了近四十年，期間他光榮地履行了多項出使任務，並以極高的信譽擔任了全英格蘭大法官的崇高職位。", "當英格蘭國王亨利八世休棄了亞拉岡的凱瑟琳，並迎娶安妮·博林時，他要求所有人宣誓承認後者的婚姻是合法的。但托馬斯與羅徹斯特主教一同拒絕了這項誓言，他也因此被投入監獄。在那裡，他未曾顯露任何悲傷的跡象，反倒因為他生性極其喜樂且無比堅定，他在獄中以奇妙的仁慈款待所有來到他面前的人，並常說這整個世界不過是一座監獄，我們當中每天都有人被召喚出去接受審判。十四個月後，他被判為叛國者，因為他拒絕宣告國王為教會的元首。", "在他殉道的前一天，由於被剝奪了平常的書寫工具，他用一塊炭筆寫了一封信給他的女兒，信中充滿了慈父對她的愛，並向她表明自己渴望離世見上帝的熱切期盼。次日，即1535年7月6日，在祈禱並呼籲眾人為他作證他是為大公信仰而死之後，他被斬首。整個基督宗教世界發出了哀嘆，並高呼他確實是為基督的殉道烈士。1935年，隆重的宣聖法令證實了這項判斷。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪，諸聖在上帝那裡有無與倫比的賞賜；※他們為基督而死，而在光榮之中永遠生活。", "zh-hans": "看哪，诸圣在上帝那里有无与伦比的赏赐；※他们为基督而死，而在光荣之中永远生活。", "en": "Behold, the reward of the Saints ※ is plentiful with God; in truth, they died for Christ; in glory, they shall live for ever."}, {"zh-hant": "如金子在爐中被鍛煉，※主也如此試驗祂所揀選的人；祂永遠悅納他們，如同悅納燔祭。", "zh-hans": "如金子在炉中被锻炼，※主也如此试验祂所拣选的人；祂永远悦纳他们，如同悦纳燔祭。", "en": "As gold in the furnace, ※ so doth the Lord try his Elect; and as a burnt-offering, he hath accepted them for ever."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "義人的靈魂※在上帝手中，而痛苦斷不能侵害他們。", "zh-hans": "义人的灵魂※在上帝手中，而痛苦断不能侵害他们。", "en": "The souls of the righteous ※ are in the hand of God, and there shall no torment touch them."} |

### sanctorale_0711_benedict.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.biography` | {"title": "教父講道", "source": "節選自大聖格里高利教宗的《對話錄》第二卷三十七章。", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["在他離世前的最後一年，這位屬上帝的人向幾位門徒預言了自己安息主懷的日子。他向隱修院中與他同處的一些人提及此事時，囑咐他們務必嚴守秘密。然而，對於在別處居住的門徒，他僅告知他們在他離世之時將要看見的特殊預兆。", "離世前六日，他吩咐人掘開他的墳墓。旋即他便發起高燒，這熱病迅速耗盡了他殘存的氣力。他的病情日漸加重；終於到了第六日，他命門徒將他抬入聖堂。在那裡，他領受了我們主的聖體與寶血，好為即將到來的大限增添力量。隨後，他在眾弟兄的臂膀攙扶下，撐起虛弱的身體，舉手向天站立，便在祈禱中呼出了最後一口氣。", "那一日，有兩名修士——一名身在隱修院中，另一名則在遠方——見到了完全相同的異象。他們二人都看見一條宏偉的大道，鋪滿華美的織錦，閃爍著千萬點光芒。這條大道從他的隱修院筆直向東延伸，直到升入高天。在那光輝之中，站立著一位容貌威嚴的人，問他們說：“你們可知是誰從這條路走過的？”他們答道：“不知。”那人對他們說：“這正是主所愛的蒙福者本篤，升入高天時所走的大道。”如此，與本篤同處的弟兄們親眼見證了他的安息；而那些不在場的人，也藉著他曾應許的預兆得知了此事。他的遺體被安放於施洗約翰聖堂中安息；這聖堂正是他為取代亞波羅祭壇而親手建造的。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0712_john_gualbert.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["約翰·瓜爾貝特出生於十世紀末佛羅倫斯的一個貴族家庭，他成為了十一世紀對教會改革貢獻卓著、並使教宗聖格列高利七世得以改變歐洲面貌的多位聖人之一。依照父親的意願，約翰成為了一名士兵。當時，他唯一的兄弟休（Hugh）被一位表親殺害。在某個救主受難日，全副武裝並有士兵隨行的約翰，在一條狹窄、雙方都無法避開的路上，遇見了那名孤身一人且毫無防備的兇手。正當約翰準備拔劍殺他時，那可憐的人跪了下來，雙臂伸展成十字架的形狀，因著那神聖記號的緣故懇求約翰饒恕他；出於對十字架的敬畏，約翰饒過了他的性命。隨後，他走進附近的一座修道院聖堂祈禱。在那裡，他覺得自己看到那天剛被信徒敬奉的被釘十字架基督的聖像，向他點頭。為此他深受感動，甚至違背父親的意願放下了軍職，進入該修道院成為一名修士。", "當該院的院長離世時，眾修士推選約翰繼任。但這位上帝的僕人更渴望順服而非掌權，於是便前往卡馬爾多利（Camaldoli）向聖羅慕鐸尋求建議。在那裡他得知，上帝的旨意是要他創立一個屬於自己的修會，在被稱為瓦隆布羅薩的山谷中，以最純粹的方式遵行《聖本篤會規》。因他聖潔生活的名聲所吸引，許多人聚集到他那裡。他將他們視為同伴，並開始努力作工，以潔淨該地區教會中異端與買賣聖職的污染。然而，這種對抗時代邪惡的見證樹立了敵人，使他們遭受了許多苦難。有一次，他們的一些敵人在夜間來到其中一座修道院，企圖消滅約翰和他的修士們。這些人放火燒了聖堂，拆毀了他們的茅舍，並擊傷了許多修士。", "但最終，約翰和他的門徒們得到了他們所渴望的和平，清除了托斯卡納買賣聖職的污染，並廣泛恢復了信仰。在他七十八歲那年，因徹夜守望、齋戒、祈禱和刻苦己身而耗盡了體力，他的身體衰敗了。當他臨近離世時，他要求將以下的話寫下來並與他一同埋葬：「我，約翰，確信並宣認聖使徒所傳揚、及聖教父於四次大公會議中所確立之信仰」；隨後他於1073年7月12日安息主懷；並於1193年被封聖。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0713_silas.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這位聖者為維護上帝的律法奮鬥至死，※對惡人的恐嚇毫不畏懼；因為他好像建在穩固的磐石上。", "zh-hans": "这位圣者为维护上帝的律法奋斗至死，※对恶人的恐吓毫不畏惧；因为他好像建在稳固的磐石上。", "en": "This is a holy man ※ who strove for the law of his God, even unto death; and feared not the words of evil men, forasmuch as he was established on the sure and firm Rock."} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["這位西拉首次被提及是在《使徒行傳》中，據記載，他與稱呼巴撒巴的猶大一同被揀選，隨保羅和巴拿巴前往安提阿，為了將耶路撒冷會議致敘利亞外邦信徒的信件帶去。這些信件就基督徒生活與大公教會的紀律給予了指示，並清楚表明西拉是耶路撒冷弟兄中的領袖之一，且他能夠親口向敘利亞的基督徒講述他們所需了解的、關於會議所發之書面勸誡的內容。", "猶大和西拉自己也是先知，就用許多話勸勉安提阿的弟兄，堅固他們的信仰。西拉與保羅和巴拿巴留在安提阿，直到那兩人之間發生了分歧；那時他被聖保羅選中，陪同他去探訪敘利亞和基利家的其他教會，最後到達馬其頓。在腓立比，他與這位偉大的使徒一同遭到毆打和監禁，並與他一同經歷了脫離敵人手的奇妙拯救。", "在庇哩亞，他與聖提摩太留了下來，直到當時在雅典的使徒派人去接他們，之後兩人便在哥林多與保羅會合。據推測，《帖撒羅尼迦前後書》就是在那裡寫成的，在兩封書信中，使徒都提到了他的同伴西拉（Sylvanus），人們相信這就是聖西拉最初的全名。若是如此，聖《彼得前書》中提到、當時擔任使徒之長代筆的西拉，可能也就是這位蒙福的西拉。根據傳統，他在歐洲度過了餘生，並因著為信仰而承受的榮耀苦難，從馬其頓安息主懷。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "公義的主※喜愛公義；他的眼目必看顧正直的人。", "zh-hans": "公义的主※喜爱公义；他的眼目必看顾正直的人。", "en": "The righteous Lord ※ loveth righteousness; his countenance will behold the thing that is just."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他。", "en": "Whosoever shall confess ※ me before men, him will I confess also before my Father."}, {"zh-hant": "那在智慧中恆心不渝，※默想神聖之事，並在心中思想上帝無所不見之大能的人有福了。", "zh-hans": "那在智慧中恒心不渝，※默想神圣之事，并在心中思想上帝无所不见之大能的人有福了。", "en": "Blessed is the man ※ that continueth in wisdom, and doth meditate on holy things, and that reasoneth in his mind on the all-seeing power of God."}] |

### sanctorale_0714_bonaventure.json

- 通用：`common_confessor_doctor_outside_easter`（一位精修者通用（復活期外）教會聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon` | {"normal": "主的精修者聖波拿文都拉，※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。"} | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人走入正路，將上帝的國指示給他，賜予他神聖事物的知識，使他在辛勞之中得榮耀，並增加他辛苦勞成果。", "zh-hans": "主引导义人走入正路，将上帝的国指示给他，赐予他神圣事物的知识，使他在辛劳之中得荣耀，并增加他辛苦劳成果。", "en": "The Lord guided the righteous man in right paths, and showed him the Kingdom of God; bestowed on him the knowledge of holy things, made him honourable in his travails, and increased the fruit of his labours."}, {"zh-hant": "你這又良善又忠心的僕人，※可以進來享受你主人的快樂。", "zh-hans": "你这又良善又忠心的仆人，※可以进来享受你主人的快乐。", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["人們普遍相信，波拿文都拉，意即「好運」，其名字，是他在襁褓時由阿西西的聖法蘭西斯親自為他起的。當時，應這孩童父母的請求，這位聖人為他祝禱，以醫治他的疾病；因為他於1221年出生在托斯卡納的巴尼奧雷焦時，受洗的名字是約翰。到了適當的年齡，他加入了聖法蘭西斯的修會（根據同一個廣為流傳的故事，他的父母已將他奉獻給該修會），並被派往巴黎，在偉大的學者海爾斯的亞歷山大門下學習。亞歷山大是法蘭西斯學派的創始人，在同時代被譽為「無可辯駁的博士」。亞歷山大十分賞識波拿文都拉，常說他似乎沒有遺傳到任何原罪。因為他是一個俊美的青年，深受眾人喜愛，以心思敏銳、判斷謹慎而聞名，並且對我們的上帝和主耶穌基督懷有無比熱切的虔敬。", "在巴黎，他與道明會的阿奎那結為好友，宛如大衛與約拿單一般。兩人似乎互為補充，共同築起了經院神學的偉大殿堂，並受到同時代人的共同敬仰，托馬斯被尊為「天使博士」，而波拿文都拉則被尊為「撒拉弗博士」。波拿文都拉尤其擅長教授祈禱與默觀，並將苦像作為他首要的研究之書；正如有人發現他在凝視苦像時，他曾說道：「我只研究耶穌基督，並他釘十字架。」 他在修會中擔任過多項要職，並在未滿三十六歲時就成為了修會的總會長；當時修會正因教會當局所批准的某些放寬會規的規定，而陷入分裂的爭端之中。由於他成功地藉由他為修會制定的《會規》帶來了統一的遵行規範，他理所當然地被譽為修會的第二位創始人。出於他的仁愛與謙卑，他總是勤於照料病人，並樂於從事粗重的勞役。據說，當教宗的使節將樞機主教的紅帽帶來給他時，他正在洗碗，因此請他們將帽子掛在廚房門外的樹叢上。他先前曾拒絕了幾次高階聖職的提名，包括約克大主教之職；但這一次教宗不容他拒絕，親手祝聖他為阿爾巴諾的樞機主教。", "他是促成1274年里昂大公會議上東西方教會短暫彌合分裂的主要推手之一；但他在此後不久、會議仍在進行期間便離世了，即在7月15日，正如同聖托馬斯·阿奎那在前往該會議途中離世一樣。後者在波拿文都拉在世時便稱他為聖人；因為當托馬斯發現他正致力於撰寫聖法蘭西斯的傳記時，便拒絕打擾他，說道：「讓我們留一位聖人為另一位聖人作工吧。」 他的著述豐富且精妙；他是一位極具感染力的講道者；他以智慧治理他的修會；教宗依諾增爵四世在聽過他講話後說道：沒有人看見他不愛他的；即使是陌生人，單單聽他說話便渴望遵從他的勸告：他溫文有禮、謙卑、充滿憐憫、謹慎且貞潔。他於1482年被封聖，並於1588年被宣告為教會聖師。"]} | （原檔沒有此欄位） |
| `morning.invitatory` | {"text": "主的聖師聖波拿文都拉，懷著對上帝的信德而生活，※讓我們懷著同樣信德來俯伏敬拜至聖三一，惟一上帝。"} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "願那愛你名的人都靠你歡欣。※因為你必賜福與義人；主啊，你必用恩惠如同盾牌四面護衛他。", "zh-hans": "愿那爱你名的人都靠你欢欣。※因为你必赐福与义人；主啊，你必用恩惠如同盾牌四面护卫他。", "en": "Let all rejoice ※ who hope in thee, O Lord; since thou hast blessed the righteous man, and with the shield of thy good will hast crowned him."}, {"zh-hant": "在遵守至高者的法律上，※沒有人可與他對立。", "zh-hans": "在遵守至高者的法律上，※没有人可与他对立。", "en": "There was none found ※ like unto him, who kept the law of the Most High."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪！這是大祭司，※他在世之時取悅了上帝，被看為完全，是個義人。", "zh-hans": "看哪！这是大祭司，※他在世之时取悦了上帝，被看为完全，是个义人。", "en": "Behold a great Priest, ※ who in his days pleased God, and was found righteous."}, {"zh-hant": "這是那忠心有見識的管家，主人派他管理家裡的人。", "zh-hans": "这是那忠心有见识的管家，主人派他管理家里的人。", "en": "A wise and faithful steward, whom the Lord made ruler over his household."}] |

### sanctorale_0715_translation_of_swithun.json

- 通用：`common_confessor_bishop_outside_easter`（一位精修者通用（復活期外）主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "主的精修者聖斯威頓主教，※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。" | {"zh-hant": "主的精修者聖（某某），※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。", "zh-hans": "主的精修者圣（某某），※藉着你神圣的代祷坚固我们众人，使我们这些人被罪恶重担压垮之人，因你已得享真福荣耀而昂首挺身，并追随你的芳踪，至终赢得永恒的赏赐."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人走入正路，將上帝的國指示給他，賜予他神聖事物的知識，使他在辛勞之中得榮耀，並增加他辛苦勞成果。", "zh-hans": "主引导义人走入正路，将上帝的国指示给他，赐予他神圣事物的知识，使他在辛劳之中得荣耀，并增加他辛苦劳成果。", "en": "The Lord guided the righteous man in right paths, and showed him the Kingdom of God; bestowed on him the knowledge of holy things, made him honourable in his travails, and increased the fruit of his labours."}, {"zh-hant": "你這又良善又忠心的僕人，※可以進來享受你主人的快樂。", "zh-hans": "你这又良善又忠心的仆人，※可以进来享受你主人的快乐。", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["斯威頓進入了溫徹斯特的修道院，並在那裡成為了一名司祭。西撒克遜國王埃格伯特聽聞了他的名聲，便將自己的兒子埃塞爾伍爾夫交由他照管；多年後，當這位王子繼承王位時，在坎特伯雷大主教及其聖品人的同意下，他提名斯威頓為溫徹斯特主教。此後，在履行對其教區的職責時，斯威頓克盡了一位忠信牧者應盡的一切本分。", "他退避一切在人前的張揚與沽名釣譽，只求自己所行的一切善事，除了上帝與他自己的良心之外，無人知曉。當他臨終時（即862年7月2日），他表達了一個心願，希望自己的遺體能埋葬在教堂外的泥土中，置於廣闊的穹蒼之下，好讓來到那裡的人的腳步能從他身上踏過，並讓雨水與露水能降在他身上；他這卑微的心願最終得到了實現。", "由此便產生了一種說法：因為他熱愛陽光與雨水，上帝總會應允他的祈求，無論他在自己的慶日那天偏愛哪一種天氣，上帝都會賜下，並且在此後的連續四十天裡都會維持這般天氣。後來，當新的溫徹斯特座堂建成時，聖斯威頓的聖髑被遷移至該處，即在1093年。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "願那愛你名的人都靠你歡欣。※因為你必賜福與義人；主啊，你必用恩惠如同盾牌四面護衛他。", "zh-hans": "愿那爱你名的人都靠你欢欣。※因为你必赐福与义人；主啊，你必用恩惠如同盾牌四面护卫他。", "en": "Let all rejoice ※ who hope in thee, O Lord; since thou hast blessed the righteous man, and with the shield of thy good will hast crowned him."}, {"zh-hant": "在遵守至高者的法律上，※沒有人可與他對立。", "zh-hans": "在遵守至高者的法律上，※没有人可与他对立。", "en": "There was none found ※ like unto him, who kept the law of the Most High."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪！這是大祭司，※他在世之時取悅了上帝，被看為完全，是個義人。", "zh-hans": "看哪！这是大祭司，※他在世之时取悦了上帝，被看为完全，是个义人。", "en": "Behold a great Priest, ※ who in his days pleased God, and was found righteous."}, {"zh-hant": "這是那忠心有見識的管家，主人派他管理家裡的人。", "zh-hans": "这是那忠心有见识的管家，主人派他管理家里的人。", "en": "A wise and faithful steward, whom the Lord made ruler over his household."}] |

### sanctorale_0716_translation_of_osmund.json

- 通用：`common_confessor_bishop_outside_easter`（一位精修者通用（復活期外）主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "主的精修者聖奥斯蒙德，※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。" | {"zh-hant": "主的精修者聖（某某），※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。", "zh-hans": "主的精修者圣（某某），※藉着你神圣的代祷坚固我们众人，使我们这些人被罪恶重担压垮之人，因你已得享真福荣耀而昂首挺身，并追随你的芳踪，至终赢得永恒的赏赐."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人走入正路，將上帝的國指示給他，賜予他神聖事物的知識，使他在辛勞之中得榮耀，並增加他辛苦勞成果。", "zh-hans": "主引导义人走入正路，将上帝的国指示给他，赐予他神圣事物的知识，使他在辛劳之中得荣耀，并增加他辛苦劳成果。", "en": "The Lord guided the righteous man in right paths, and showed him the Kingdom of God; bestowed on him the knowledge of holy things, made him honourable in his travails, and increased the fruit of his labours."}, {"zh-hant": "你這又良善又忠心的僕人，※可以進來享受你主人的快樂。", "zh-hans": "你这又良善又忠心的仆人，※可以进来享受你主人的快乐。", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "願那愛你名的人都靠你歡欣。※因為你必賜福與義人；主啊，你必用恩惠如同盾牌四面護衛他。", "zh-hans": "愿那爱你名的人都靠你欢欣。※因为你必赐福与义人；主啊，你必用恩惠如同盾牌四面护卫他。", "en": "Let all rejoice ※ who hope in thee, O Lord; since thou hast blessed the righteous man, and with the shield of thy good will hast crowned him."}, {"zh-hant": "在遵守至高者的法律上，※沒有人可與他對立。", "zh-hans": "在遵守至高者的法律上，※没有人可与他对立。", "en": "There was none found ※ like unto him, who kept the law of the Most High."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪！這是大祭司，※他在世之時取悅了上帝，被看為完全，是個義人。", "zh-hans": "看哪！这是大祭司，※他在世之时取悦了上帝，被看为完全，是个义人。", "en": "Behold a great Priest, ※ who in his days pleased God, and was found righteous."}, {"zh-hant": "這是那忠心有見識的管家，主人派他管理家裡的人。", "zh-hans": "这是那忠心有见识的管家，主人派他管理家里的人。", "en": "A wise and faithful steward, whom the Lord made ruler over his household."}] |

### sanctorale_0717_alexius.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["在第五世紀初，敘利亞的埃德薩住著一位乞丐。他極其聖潔，被人尊為聖人，人們只以「屬上帝的人」來稱呼他，不知其真名。在他離世後某時，大約在主後450至475年之間，一位不知名的作者寫下了一篇關於他的事蹟。其中告訴我們，他靠在教堂門口乞討為生，並將得來的施捨與其他窮苦人分享，而在他們的需要得到滿足後，他自己僅靠所剩無幾的物品度日。他死後，被安葬在埃德薩的窰匠之田裡。但在臨終前，他向照料他的人吐露，自己出身於羅馬最顯赫的貴族家庭之一。這本書後來的修訂本記載（如今已無人知曉其權威根據為何），他的名字是阿歷克修斯。並且，出於對耶穌基督痛悔的愛，他領受了上帝的特別命令：不要親近他即將迎娶的新娘，而是要前往世界各地最著名的教堂進行朝聖。因此，許多年來他一直投身於這些旅程，且完全不為人所知。在此期間，他回到了羅馬，來到了自己父親的家中。他的父親並未認出他來，但讓他在通往屋內的樓梯底下的一處空間棲身；他在那裡住了許多年，始終無人認出。他藉著如此艱苦且隱蔽的痛悔生活，向世俗之人顯明，上帝的僕人中有愛基督耶穌勝過婦女之愛情的人，為著這份愛，他們甘願將失去整個世界視為美事。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0718_bernard_mizeki.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這位聖者為維護上帝的律法奮鬥至死，※對惡人的恐嚇毫不畏懼；因為他好像建在穩固的磐石上。", "zh-hans": "这位圣者为维护上帝的律法奋斗至死，※对恶人的恐吓毫不畏惧；因为他好像建在稳固的磐石上。", "en": "This is a holy man ※ who strove for the law of his God, even unto death; and feared not the words of evil men, forasmuch as he was established on the sure and firm Rock."} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["伯納德·米澤基大約於1861年出生在葡屬東非（即今莫桑比克）的伊尼揚巴內附近。他的父母是尚加安人，給他取名為馬米耶利·米澤基·格萬貝。由於當地沒有學校，他早年並未接受過任何正規教育。他在青春期離開了故鄉，作為僕役陪同一位歐洲獵人前往開普敦隨後在開普敦郊區找到了一份家僕的工作。米澤基在條件允許時，參加了由安立甘差會開辦的夜校，並展現出極高的學習天賦。在安立甘宣教士的結交與帶領下，他於1886年3月9日領受洗禮，並獲取教名伯納德。後來，他進入尊內布洛姆學院接受培訓，準備成為一名傳道員。1891年，伯納德自願前往馬紹納蘭的先鋒傳教站擔任傳道員，並駐紮在位於今津巴布韋的諾韋。", "五年後，即1896年6月，在由姆瓦里教祭司領導的旨在反抗英國人及其非洲盟友的馬紹納起義中，伯納德成了特別針對的目標，部分原因是他曾冒犯當地的巫醫。在那年6月的一個主日，巫醫命令諾韋的居民不得參加伯納德早上的禮拜，儘管當天的晚禱依然有許多人出席。巫醫聽聞此事後，威脅要殺死伯納德，並懲罰那些違抗命令去參加基督徒崇拜的人。儘管有人警告他逃跑，但伯納德不願拋棄他在傳教站的信徒。6月17日，伯納德被村裡的叛軍戰士從他的茅屋中拖出，並受了致命重傷。他掙扎著爬到附近的山坡上，他的妻子在那裡為他清洗傷口。妻子短暫離開去取毛毯，隨後與另一位婦女一同返回。她們回憶說，當時被一陣「如同許多大鳥翅膀拍擊」的超自然聲音，以及一道向伯納德躺臥之處移動的耀眼光芒所驚嚇。當這兩位婦女鼓起勇氣走向伯納德躺臥的地方時，他的遺體已經消失了。他的遺體始終未被尋獲，其確切的安葬地點至今無人知曉。", "在他殉道地附近建立的一座聖地，至今仍吸引著朝聖者前來。每年，在最接近6月18日的星期六，人們都會舉行特別的聖餐禮儀，以紀念這位中南非的安立甘首位殉道者。"]} | （原檔沒有此欄位） |
| `morning.invitatory.text` | "主是精修者的君王，※我們當來俯伏敬拜。" | {"zh-hant": "主是殉道者的君王，※我們當來俯伏敬拜。", "zh-hans": "主是殉道者的君王，※我们当来俯伏敬拜."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "公義的主※喜愛公義；他的眼目必看顧正直的人。", "zh-hans": "公义的主※喜爱公义；他的眼目必看顾正直的人。", "en": "The righteous Lord ※ loveth righteousness; his countenance will behold the thing that is just."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他。", "en": "Whosoever shall confess ※ me before men, him will I confess also before my Father."}, {"zh-hant": "那在智慧中恆心不渝，※默想神聖之事，並在心中思想上帝無所不見之大能的人有福了。", "zh-hans": "那在智慧中恒心不渝，※默想神圣之事，并在心中思想上帝无所不见之大能的人有福了。", "en": "Blessed is the man ※ that continueth in wisdom, and doth meditate on holy things, and that reasoneth in his mind on the all-seeing power of God."}] |

### sanctorale_0719_vincent_de_paul.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["文森特·德·保羅是法國人，1576年出生於加斯科涅·達克斯附近一個農民家庭的小農場裡。當他還是個小男孩時，便展現出對書籍的天賦，於是他的父親不再讓他放牛，轉而讓他接受書本教育。他在達克斯學習世俗學問，並在圖盧茲與薩拉戈薩學習神學，隨後被按立為司祭。1605年，他有機會進行了一次海上旅行，途中被穆斯林海盜所俘虜，並被賣到非洲為奴。在那裡，他使他的主人（一名背教者）歸信，並與他一同逃離了巴巴里，返回法國。此後，文森特擔任堂區司祭，直到國王任命他為法國槳帆船隊的總隨軍司祭（Chaplain-General），在這個職位上，他為划船的囚犯以及那些粗暴冷酷的看守做了許多善事。應「聖母訪親女修會」創辦人聖法蘭西斯·德·沙雷士的請求，他還被任命為該封閉式默觀修會的院長，並履行此職責約四十年；他的智慧如此之高，以至於法蘭西斯常說，他所認識的司祭中，沒有比文森特更配得這份榮譽的了。", "在向窮人，特別是向農民宣講福音方面，他不知疲倦地辛勤工作，直到因年邁而喪失勞動力。為了這項特殊的工作，他創立了一個由在俗司祭組成的修會，名為「遣使會」，有時被稱為「拉撒路會」，或以其創始人之名被稱為「文森特會」。他為改善聖品人員的紀律付出了極大的努力，這從他各項事工中可見一斑，例如：為初級聖品人員的最終教育建立神學院；舉辦司祭會議以探討神聖事務；以及提供為按立作準備的宗教退修。為此，也為了平信徒的退修，他希望屬於其機構的房屋能始終免費開放。他能夠將他的福音工人派往世界各地。他在國王路易十三臨終時陪伴並協助了他。路易十四的母親，奧地利的安妮王后，在攝政期間任命他為年輕國王的「良知委員會」成員，在這個位置上，他在任命訓練有素的司祭擔任空缺聖俸方面，以及在鎮壓決鬥和其他罪惡方面，做了許多善事。", "對於任何形式的苦難，他無不盡力去救濟。在穆斯林奴役中呻吟的基督徒、棄嬰與殘疾兒童、面臨危險的少女、無家可歸的修女與墮落的婦女、被送往槳帆船的囚犯、患病的外國人與殘疾的工人、精神病患者以及無數的乞丐；所有這些人，他都予以救濟，並虔誠地將他們安置在至今依然存在的各種慈善機構中。他創立了許多慈善協會以及數個宗教社團，如仁愛修女會、天命修女會等；因為在他那個時代之前，女性修道機構是不被允許在修道院之外進行積極的憐憫善工的。在這些繁多且最令人操心的事務中，他始終單單仰望上帝。帶著因艱辛、勞作和年邁而耗盡的身體，在他八十五歲那年，即1660年9月27日，他在巴黎的聖拉撒路會院安然離世，該會院是他所創立的遣使會的總會院。1737年，他的名字被列入聖人名錄，他的慶節被定於7月19日。他被尊為所有慈善協會的主保聖人。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0720_margaret_of_antioch.json

- 通用：`common_virgin_martyr_outside_easter`（一位殉道童貞女用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `morning.benedictus_antiphon.normal` | "當新郎來到時，※明智的童貞女已經預備好，就與他一同進入婚宴。" | {"zh-hant": "當新郎來到時，明智的童貞女已經預備好，就與他一同進入婚宴。", "zh-hans": "当新郎来到时，明智的童贞女已经预备好，就与他一同进入婚宴."} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["這位瑪格麗特，是東西方教會最廣受崇敬的聖人之一；然而，除了她是在安提阿為基督殉道的一位童貞女之外，人們對她實無確切可知之事。在東方，她被稱為「大殉道者瑪利納」；此名與「瑪格麗特」一樣，意為珍珠。她的瞻禮定於七月十二日。她的名聲由東方傳至西方；至第七世紀，她的名字改作「瑪格麗特」，已見於一篇英格蘭的連禱文中。中世紀時，她在歐洲各地深受敬愛，並被尊為「十四位護佑聖人」之一；人們祈求她護佑免於邪魔附身，也求她扶助臨產的婦女及心懷恐懼的人。她也是鼓勵聖女貞德與邪惡和不義爭戰的聲音之一。主後九〇八年，據稱她的遺骸由安提阿被盜運至歐洲，最後安奉於蒙泰菲亞斯科內主教座堂。", "在較晚的年代，有人寫成她所謂的《行傳》；但這些文字乃以基督徒的純樸與純潔戰勝邪惡為主題的象徵性敘事，故不應視作純然的史實記錄。依照此《行傳》，她生於彼西底的安提阿，父親是異教祭司亞德修斯。父親將她交給一位基督徒婦人乳養；她從那婦人認識基督，此後父親便棄絕了她。於是，她不得不以牧羊維生。省長奧利布里烏斯見她容貌出眾，若她是自由身，便想娶她為妻；若她是婢女，便想誘她犯罪。但她全不理會他。在審判席前，省長問她說：「你的姓名、出身和宗教是甚麼？」她回答說：「我的名字是瑪格麗特；我出身高貴；我的信仰乃是基督徒。」", "省長便說：「你前兩個回答倒與你相稱；但第三個卻是愚妄：誰能把一位被釘十字架的人當作神呢？」這位童貞女答道：「你從哪裏得知主耶穌曾被釘十字架？」省長說：「從基督徒的書中。」瑪格麗特回答說：「這就是你的智慧嗎？同樣的書既見證基督的受難，也見證祂的榮耀；你卻信其一而拒其一！」於是，她受盡各樣酷刑。在幽暗的監牢中，她彷彿看見魔鬼化作巨龍，將她吞下；但巨龍不能容納她所攜帶的十字架，便把她吐了出來。她在肉身受苦之時，又經歷其他屬靈的試煉與劇痛；但她以忍耐在基督裏保守自己的靈魂，以致許多人因她而信了基督。最後，她在戴克里先在位、迫害教會的第四世紀初期，藉著斬首，凱旋歸向她的新郎基督。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |
| `evening.benedictus_antiphon.normal` | "天國又好比商人尋找好的珍珠，※發現一顆貴重的珍珠，就去變賣他一切所有的，買下這顆珍珠。" | {"zh-hant": "天國又好比商人尋找好的珍珠，發現一顆貴重的珍珠，就去變賣他一切所有的，買下這顆珍珠。", "zh-hans": "天国又好比商人寻找好的珍珠，发现一颗贵重的珍珠，就去变卖他一切所有的，买下这颗珍珠."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "", "zh-hans": "", "en": ""} |

### sanctorale_0723_apollinaris.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這位聖者為維護上帝的律法奮鬥至死，※對惡人的恐嚇毫不畏懼；因為他好像建在穩固的磐石上。", "zh-hans": "这位圣者为维护上帝的律法奋斗至死，※对恶人的恐吓毫不畏惧；因为他好像建在稳固的磐石上。", "en": "This is a holy man ※ who strove for the law of his God, even unto death; and feared not the words of evil men, forasmuch as he was established on the sure and firm Rock."} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["聖亞波里拿留是拉溫那的首任主教。他最傑出的繼任者金言聖彼得在一篇流傳至今的講道中，稱他為殉道者，但補充道，儘管他屢次為基督流血，逼迫他的人卻未曾奪去他的性命。然而，他在早期教會被尊為最偉大的殉道者之一，故可推斷他為基督受了許多且頻繁的苦難。", "記載其事蹟的《行傳》（雖未被視為完全符合史實）記載，他與真福彼得一同來到羅馬，使徒親自祝聖他為主教，並差遣他前往拉溫那傳揚福音；他在那裏使許多人歸信基督。拜偶像的祭司因此拿住他，狠狠地鞭打了。此後，因他醫好長久作啞巴的貴族波尼法爵，並從他女兒身上趕出污鬼，反對他的第二次暴動又起。在此次事件中，亞波里拿留再次受鞭打，被迫赤足走過滾燙的火炭，隨後被逐出城外。", "於是，他與部分基督徒隱匿了些時日，隨後前往艾米利亞，在那裏領了許多人歸向基督。該城之官長亦因此將他到處驅逐，從一地趕至另一地，直到他被趕回拉溫那；在那裏，他再次遭到同一批拜偶像祭司的控告。這些事以後，亞波理拿留再次逃亡，卻被追上、拿住且遭毆打，被丟棄在路旁奄奄一息。幾位基督徒尋見了他，將他帶回照料，使他存活了七日；期間他勸勉眾人要在真道上站立得穩。他就這樣帶著殉道的光榮輝煌離世，其遺體被葬於緊靠城牆之處。"]} | （原檔沒有此欄位） |
| `morning.invitatory.text` | "主是精修者的君王，※我們當來俯伏敬拜。" | {"zh-hant": "主是殉道者的君王，※我們當來俯伏敬拜。", "zh-hans": "主是殉道者的君王，※我们当来俯伏敬拜."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "公義的主※喜愛公義；他的眼目必看顧正直的人。", "zh-hans": "公义的主※喜爱公义；他的眼目必看顾正直的人。", "en": "The righteous Lord ※ loveth righteousness; his countenance will behold the thing that is just."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他。", "en": "Whosoever shall confess ※ me before men, him will I confess also before my Father."}, {"zh-hant": "那在智慧中恆心不渝，※默想神聖之事，並在心中思想上帝無所不見之大能的人有福了。", "zh-hans": "那在智慧中恒心不渝，※默想神圣之事，并在心中思想上帝无所不见之大能的人有福了。", "en": "Blessed is the man ※ that continueth in wisdom, and doth meditate on holy things, and that reasoneth in his mind on the all-seeing power of God."}] |

### sanctorale_0729_martha.json

- 通用：`common_virgin_outside_easter`（一位童貞女通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.antiphons.0` | "這是那位明智的貞女，她是那聰明貞女當中的一位。" | {"zh-hant": "這是那位明智的貞女，※她是那聰明貞女當中的一位。", "zh-hans": "这是那位明智的贞女，※她是那聪明贞女当中的一位."} |
| `vigil.psalm_antiphons.antiphons.1` | "這是那位明智的貞女，是主來到時發現醒悟著的貞女。" | {"zh-hant": "這是那位明智的貞女，※是主來到時發現醒悟著的貞女。", "zh-hans": "这是那位明智的贞女，※是主来到时发现醒悟着的贞女."} |
| `vigil.psalm_antiphons.antiphons.2` | "這就是那不知床第罪惡的女子，在靈魂受眷顧的時候，她必富有果實。" | {"zh-hant": "這就是那不知床第罪惡的女子，※在靈魂受眷顧的時候，她必富有果實。", "zh-hans": "这就是那不知床第罪恶的女子，※在灵魂受眷顾的时候，她必富有果实."} |
| `vigil.psalm_antiphons.antiphons.3` | "來吧，我所揀選的，我要讓她坐在我的寶座上。" | {"zh-hant": "來吧，※我所揀選的，我要讓她坐在我的寶座上。", "zh-hans": "来吧，※我所拣选的，我要让她坐在我的宝座上."} |
| `vigil.psalm_antiphons.antiphons.4` | "這就是那在耶路撒冷的女兒中美貌秀麗的那一位。" | {"zh-hant": "這就是※那在耶路撒冷的女兒中美貌秀麗的那一位。", "zh-hans": "这就是※那在耶路撒冷的女儿中美貌秀丽的那一位."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這是一位神聖榮耀的童貞女，※萬主之主已經揀選了她。", "zh-hans": "这是一位神圣荣耀的童贞女，※万主之主已经拣选了她。", "en": "This is a virgin, ※ glorious and holy, for the Lord of all hath chosen her. "} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["聖馬大與其妹馬利亞及弟拉撒路同住於伯大尼的家中。該處充滿了高尚的款待之情，因此人們相信他們出身名門且家境優渥。但馬大主要因作為我們主充滿愛心的女主人而被銘記；主為了她及馬利亞的緣故，將他已死三日的朋友拉撒路從死裡復活，在拉撒路的墳前，正如福音書作者所言：「耶穌哭了。」因為福音書對他們作出了極高的讚譽：「耶穌素來愛馬大和她妹妹，並拉撒路。」按照古代教父的觀點，馬利亞被視為默觀呼召的典範，而馬大則是行動呼召的典範：也就是說，將生命奉獻給上帝，為鄰舍行善。", "在中世紀的法國，關於這三位聖徒流傳著一個奇特的故事，如下所述。主升天後，他們及其家屬由馬克西明（主基督七十二門徒之一）施洗。他們與許多其他基督徒一起被猶太人抓獲，被流放到大海上的一艘既無帆也無槳的船上，注定要遇難；但在上帝的掌管下，這艘船安全抵達了馬賽。藉由這個神蹟和聖徒們的講道，周圍的民眾開始信奉基督，拉撒路成為了馬賽的主教，馬克西明成為了艾克斯的主教。", "馬利亞彷彿繼續坐在耶穌的腳前，因為她始終完全專注於祈禱和對屬天福分的默觀；為了使她所選擇的那上好的福分不致被奪去，她退隱到一座極高山上的一個山洞中，在那裡生活了三十年，完全與世隔絕，只有聖天使與她為伴。而馬大以她奇妙的聖潔與慈善的生活，贏得了馬賽所有居民的愛戴，直到她與其他幾位尊貴的婦女一同退隱到一個偏僻的地方，預備自己去迎見那位愛她的主，於此安息，與主永遠同在。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0` | "這是那位明智的貞女，她是那聰明貞女當中的一位。" | {"zh-hant": "這是那位明智的貞女，※她是那聰明貞女當中的一位。", "zh-hans": "这是那位明智的贞女，※她是那聪明贞女当中的一位."} |
| `morning.psalm_antiphons.antiphons.1` | "這是那位明智的貞女，是主來到時發現醒悟著的貞女。" | {"zh-hant": "這是那位明智的貞女，※是主來到時發現醒悟著的貞女。", "zh-hans": "这是那位明智的贞女，※是主来到时发现醒悟着的贞女."} |
| `morning.psalm_antiphons.antiphons.2` | "這就是那不知床第罪惡的女子，在靈魂受眷顧的時候，她必富有果實。" | {"zh-hant": "這就是那不知床第罪惡的女子，※在靈魂受眷顧的時候，她必富有果實。", "zh-hans": "这就是那不知床第罪恶的女子，※在灵魂受眷顾的时候，她必富有果实."} |
| `morning.psalm_antiphons.antiphons.3` | "來吧，我所揀選的，我要讓她坐在我的寶座上。" | {"zh-hant": "來吧，※我所揀選的，我要讓她坐在我的寶座上。", "zh-hans": "来吧，※我所拣选的，我要让她坐在我的宝座上."} |
| `morning.psalm_antiphons.antiphons.4` | "這就是那在耶路撒冷的女兒中美貌秀麗的那一位。" | {"zh-hant": "這就是※那在耶路撒冷的女兒中美貌秀麗的那一位。", "zh-hans": "这就是※那在耶路撒冷的女儿中美貌秀丽的那一位."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "基督的淨配，※請來接受主從永遠就為你準備好的華冠。", "zh-hans": "基督的净配，※请来接受主从永远就为你准备好的华冠。", "en": "Come, thou bride of Christ,※ receive the crown, which the Lord hath provided for thee for ever."} |
| `evening.psalm_antiphons.antiphons.0` | "這是那位明智的貞女，她是那聰明貞女當中的一位。" | {"zh-hant": "這是那位明智的貞女，※她是那聰明貞女當中的一位。", "zh-hans": "这是那位明智的贞女，※她是那聪明贞女当中的一位。", "en": "This is a wise virgin, ※ and one of the number of the prudent."} |
| `evening.psalm_antiphons.antiphons.1` | "這是那位明智的貞女，是主來到時發現醒悟著的貞女。" | {"zh-hant": "這是那位明智的貞女，※是主來到時發現醒悟著的貞女。", "zh-hans": "这是那位明智的贞女，※是主来到时发现醒悟着的贞女."} |
| `evening.psalm_antiphons.antiphons.2` | "這就是那不知床第罪惡的女子，在靈魂受眷顧的時候，她必富有果實。" | {"zh-hant": "這就是那不知床第罪惡的女子，※在靈魂受眷顧的時候，她必富有果實。", "zh-hans": "这就是那不知床第罪恶的女子，※在灵魂受眷顾的时候，她必富有果实."} |
| `evening.psalm_antiphons.antiphons.3` | "來吧，我所揀選的，我要讓她坐在我的寶座上。" | {"zh-hant": "來吧，※我所揀選的，我要讓她坐在我的寶座上。", "zh-hans": "来吧，※我所拣选的，我要让她坐在我的宝座上."} |
| `evening.psalm_antiphons.antiphons.4` | "這就是那在耶路撒冷的女兒中美貌秀麗的那一位。" | {"zh-hant": "這就是※那在耶路撒冷的女兒中美貌秀麗的那一位。", "zh-hans": "这就是※那在耶路撒冷的女儿中美貌秀丽的那一位."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這是那位明智的貞女，※她是那聰明貞女當中的一位。", "zh-hans": "这是那位明智的贞女，※她是那聪明贞女当中的一位.", "en": "This is a wise virgin, ※ and one of the number of the prudent."} |

### sanctorale_0731_ignatius_of_loyola.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["這位依納爵在血統上是西班牙巴斯克人，於1491年出生於羅耀拉的尊貴比斯開家族；他首先進入宮廷，隨後加入了西班牙國王的軍隊。在1521年的潘普洛納圍城戰中，他身受重傷，這使他臥床不起，患了一場漫長而危險的疾病。在此期間，他偶然讀到了一些敬虔的書籍，並從中萌生了跟隨基督及其聖徒腳蹤的強烈渴望。此後，他前往蒙塞拉特，在那裡將自己奉獻於屬天的爭戰中——他將自己的武器懸掛起來，在榮福童貞馬利亞的祭壇前為其守夜看顧。隨後，他退隱到附近一個名為曼雷薩的山洞中，在那裡居住了一年，齋戒、祈禱並進行嚴厲的苦修，以便能克制自己。但與此同時，上帝以如此清晰的光照恩待他，使他（儘管當時他並未受過多少教育）編寫了那本名為《神操》的奇妙著作，其普世的實用性已證明了它的價值。", "1523年，他前往聖地朝聖，在那裡他的心靈更加親近我們的主。回到西班牙後，他決定為了靈魂的益處而透過教育來提升自己，於是在三十三歲那年開始與小男孩們一起學習基礎知識。與此同時，他嘗試了一切有助於拯救他人的方法。令人驚嘆的是，為了上帝更大的榮耀，他滿懷熱情，甚至從那些被他激怒的人那裡，欣然接受了痛苦與嘲笑，忍受了監禁甚至鞭打。在巴黎，他從該大學的成員中招募了七位同伴，他們來自不同的國家，但都已獲得文學碩士和神學碩士學位。1534年8月15日，他與這七人在蒙馬特的一個小教堂裡，奠定了耶穌會的最初基礎。後來他在羅馬組織了同一個修會時，將其與宗座建立了最緊密的聯繫，在通常的三個誓願之外，增加了關於宣教的第四個誓願。為了傳播信仰，他派遣聖法蘭西斯·沙勿略前往印度宣講福音，並派遣其他人前往世界各地。他由此發起的反對不信與異端的戰爭取得了如此大的成功，以至於人們普遍認為，上帝興起他及他的修會，正是為了對抗那個時代的異端。", "但依納爵首要關注的是在大公信仰者之中推動敬虔。他是要理問答教學、退修會和堂區會議的偉大推動者，為此，他所著的《神操》已被那些主辦此類活動的人廣泛使用。他在各地開設學校，以敬虔和優良的學識來培養男孩。他還建立了許多其他慈善機構。他為上帝贏得靈魂的工作從未疲倦，直到1556年7月31日，他在六十五歲那年安息主懷；那位主的更大榮耀，一直是他言語中不變的主題，也是他所有工作的目標。1662年，他被列入聖人年曆，如今被尊為主保聖人，供那些為靈魂迴轉而參加退修會的人祈求。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0801_peter_in_chains.json

- 通用：`common_apostle_outside_easter`（使徒用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `morning.bible_sentences`, `morning.invitatory`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `morning.bible_sentences`, `morning.invitatory`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "你是群羊的牧人，※眾使徒之長；天國的鑰匙已經交給了你。" | {"zh-hant": "人若因我辱罵你們，※迫害你們，捏造各樣壞話毀謗你們，你們就有福了！要歡喜快樂，因為你們在天上的賞賜是很多的。", "zh-hans": "人若因我辱骂你们，※迫害你们，捏造各样坏话毁谤你们，你们就有福了！要欢喜快乐，因为你们在天上的赏赐是很多的."} |
| `vigil.commemorations` | [{"display_name": "聖保羅", "antiphon": "神聖的使徒保羅，真理的宣講者，萬民的導師，請為我們轉求揀選你的上帝。", "versicle": {"leader": "使徒聖保羅，你是特選之器。", "people": "向普世宣講真理者。"}, "collect": {"title": "使徒聖保羅", "text": "上帝啊，主藉著蒙福的使徒聖保羅教導真道，叫外邦人也能領受福音的真光，我們今天紀念他，懇求主因他的代求，叫我們獲得幫助。這都是靠著我主耶穌基督。主耶穌和聖父、聖靈，惟一上帝，一同永生，一同掌權，世世無盡。阿們。"}}] | （原檔沒有此欄位） |
| `vigil.lessons` | {"special": {"ot": {"book": "耶利米書", "chapter": "1:11-19"}, "nt": {"book": "使徒行傳", "chapter": "12:5-11"}}} | （原檔沒有此欄位） |
| `vigil.office_hymn.title` | "萬世之君我主耶穌" | "Annue, Christe, sæculorum Domine" |
| `vigil.office_hymn.verses.0` | "一、萬世之君慈悲耶穌，\n因主摯愛聖者功勳；\n我等重罪俯伏主前，\n藉其榮福代求蒙赦。" | {"zh-hant": "一、萬古君王我主耶穌，求因聖者功德施恩；\n我眾在主前犯重罪，賴他代求得蒙赦免。", "zh-hans": "一、万古君王我主耶稣，求因圣者功德施恩；\n我众在主前犯重罪，赖他代求得蒙赦免。"} |
| `vigil.office_hymn.verses.1` | "二、善牧彼得禱告不息，\n為我代求斷除罪環；\n因你昔日曾受權柄，\n樂園之門任憑開關。" | {"zh-hant": "二、", "zh-hans": "二、"} |
| `vigil.office_hymn.verses.2` | "三、慈悲救主保守善工，\n聖容光輝作為印記。\n莫讓邪靈詭計撕裂，\n主的聖死所贖之人。" | {"zh-hant": "三、救主求保所造之人，聖容光輝印在其身；\n莫容邪靈詭計傷害，主曾捨命救贖之民。", "zh-hans": "三、救主求保所造之人，圣容光辉印在其身；\n莫容邪灵诡计伤害，主曾舍命救赎之民。"} |
| `vigil.office_hymn.verses.3` | "四、求主憐憫被囚之僕，\n赦免罪人釋放囚徒，\n以主寶血重價贖回，\n在天與主同享喜樂。" | {"zh-hant": "四、慈悲君王憐我囚僕，赦免罪人釋放拘囚；\n寶血所贖主之子民，賜在樂園與主同歡。", "zh-hans": "四、慈悲君王怜我囚仆，赦免罪人释放拘囚；\n宝血所赎主之子民，赐在乐园与主同欢。"} |
| `vigil.office_hymn.verses.4` | "五、永享榮耀尊貴權柄，\n耶穌基督萬世之主，\n聖父聖靈為一上帝，\n治理萬世永世無盡。阿們。" | {"zh-hant": "五、耶穌我主永享榮耀，能力尊貴至高權柄；\n與父聖靈同為上帝，掌權萬古永世無盡。阿們。", "zh-hans": "五、耶稣我主永享荣耀，能力尊贵至高权柄；\n与父圣灵同为上帝，掌权万古永世无尽。阿们。"} |
| `vigil.psalm_antiphons.antiphons.0` | "希律用刀殺了雅各，※又去捉拿彼得，拿住他後，押在監裏，企圖要在逾越節後把他提出來，當着百姓辦他。" | {"zh-hant": "你們要彼此相愛，※像我愛你們一樣，這是我的命令。", "zh-hans": "你们要彼此相爱，※像我爱你们一样，这是我的命令."} |
| `vigil.psalm_antiphons.antiphons.1` | "於是彼得被囚在監裏，※教會卻為他切切禱告上帝。" | {"zh-hant": "人為朋友捨命，※人的愛心沒有比這個更大的了。", "zh-hans": "人为朋友舍命，※人的爱心没有比这个更大的了."} |
| `vigil.psalm_antiphons.antiphons.2` | "天使對彼得說：※披上外衣，跟我來。" | {"zh-hant": "主說：※你們若遵行我所命令的，就是我的朋友。", "zh-hans": "主说：※你们若遵行我所命令的，就是我的朋友."} |
| `vigil.psalm_antiphons.antiphons.3` | "彼得說，主差遣他的使者，※救我脫離希律的手，哈利路亞。" | {"zh-hant": "締造和平的人有福了，※清心的人有福了，因為他們必得見上帝。", "zh-hans": "缔造和平的人有福了，※清心的人有福了，因为他们必得见上帝."} |
| `vigil.psalm_antiphons.antiphons.4` | "基督對彼得說：你是彼得，※我要把我的教會建造在這磐石上。" | {"zh-hant": "你們憑着堅忍，※就必保全性命。", "zh-hans": "你们凭着坚忍，※就必保全性命."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "在戰爭中你們要勇敢， ※ 與古蛇爭戰；你們必得永恆的國度，哈利路亞。", "zh-hans": "在战争中你们要勇敢， ※ 与古蛇争战；你们必得永恒的国度，哈利路亚。", "en": "Be ye valiant in warfare, ※ and contend with the old serpent; and ye shall receive an eternal kingdom, alleluia."} |
| `vigil.psalms` | {"special": {"items": [{"number": "113"}, {"number": "117"}, {"number": "146"}]}} | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal` | "主對西門彼得說：※凡你在地上所捆綁的，在天上也要捆綁；凡你在地上所釋放的，在天上也要釋放。" | {"zh-hant": "他們要把你們交給議會，※也要在會堂裏鞭打你們。你們要為我的緣故被送到統治者和君王面前，對他們和外邦人作見證。", "zh-hans": "他们要把你们交给议会，※也要在会堂里鞭打你们。你们要为我的缘故被送到统治者和君王面前，对他们和外邦人作见证."} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["使徒彼得曾因主耶穌的名被收在監裏，且被鎖鏈捆綁；這不只一次，也不只在一處，而是多次在不同地方如此。使徒行傳記載：五旬節後不久，他和使徒約翰一同上聖殿去；在那裏，彼得於聖殿門口醫好了那瘸腿的人。後來，他正在向百姓講道時，他和約翰因祭司的嫉妒被捉拿，押在監裏（也就是被鎖鏈捆綁），直到第二天。到了第二天，他們被帶出來受審；彼得與約翰一同為基督作見證時，表現出如此堅定不移的心志，以致那些原本把這兩位使徒看作沒有學問的平民的官長，也不得不驚訝他們無畏的膽量。所有聽見此事之人的信心，都因使徒的見證和彼得的鎖鏈大得堅固；信徒的數目約到了五千。", "此後不久，彼得只從人旁邊經過，他的影兒就能醫治各樣疾病；然而，他再一次被捉拿，與其他使徒一同被收在外監，這是因大祭司和撒都該人的命令。於是，他第二次被鎖鏈捆綁。但主的使者在夜間開了監門，差遣使徒出去傳揚基督，不顧人的禁止。因此，彼得和其他使徒又被捕，帶到公會面前，並被判受鞭打；這是要迫使他們順從人，而不順從上帝。關於彼得鎖鏈的第三次記載，發生在雅各死後。希律察覺殺害這位使徒的事正合猶太人的心意，便也想捉拿彼得。他叫人用兩條鐵鍊銬住彼得，將他收在監裏，交給四班兵丁看守。彼得又一次奇妙地被一位天使救出來。", "最後，彼得在羅馬殉道時，曾被囚在瑪麥爾定監獄中；據說他奉尼祿之命被鎖鏈捆綁。自初期教會以來，這些鎖鏈一直備受特別尊崇。此外，第六世紀羅馬教會的副會吏（Arator，阿拉托爾）曾寫道：彼得在耶路撒冷所受的鎖鏈，或至少其中的一部分，在他所處的時代仍保存於羅馬。因此，對彼得鎖鏈的敬禮大為增長；尤其是根據羅馬教會其他記錄所載，瓦倫提尼安三世的妻子小歐多西亞，在埃斯奎利諾山興建了一座聖殿，名為「聖彼得受鎖鏈堂」。這座聖殿，或其後重建的聖殿，在八月一日舉行祝聖禮；因此，這一天便列入教會年曆，作為「聖彼得受鎖鏈日」。後來在英格蘭，這日稱為「拉瑪斯日」（Lammas Day）；因人們有習俗以當年初收的穀物所製成的麵包奉獻，為收穫季節的開始感謝上帝。又因彼得曾受鎖鏈捆綁，這位神聖的使徒常被信徒呼求，為一切受囚禁、受奴役或受束縛的人代禱。"]} | （原檔沒有此欄位） |
| `morning.commemorations` | [{"display_name": "使徒聖保羅", "antiphon": "神聖的使徒保羅，真理的宣講者，萬民的導師，請為我們轉求揀選你的上帝。", "versicle": {"leader": "使徒聖保羅，你是特選之器。", "people": "向普世宣講真理者。"}, "collect": {"title": "紀念聖保羅", "text": "上帝啊，主藉著蒙福的使徒聖保羅教導真道，叫外邦人也能領受福音的真光，我們今天紀念他，懇求主因他的代求，叫我們獲得幫助。這都是靠著我主耶穌基督。主耶穌和聖父、聖靈，惟一上帝，一同永生，一同掌權，世世無盡。阿們。"}}] | （原檔沒有此欄位） |
| `morning.invitatory_hymn.title` | "Miris modis repente liber" | "使徒心中充滿悲傷" |
| `morning.invitatory_hymn.verses.0` | "一、彼得奇妙獲釋，看哪重獲自由，\n遵照恩主命令，鐵鍊解脫無留；\n身為牧人嚮導，羊群皆歸他守，\n指引生命之野，前往神聖水流，\n並為恩主羊群，驅趕狡猾野獸。" | {"zh-hant": "一、基督君王永恆恩賜，\n我們頌唱使徒榮耀；\n獻上讚美詩歌時刻，\n感恩之心驅散憂愁。", "zh-hans": "一、基督君王永恒恩赐，\n我们颂唱使徒荣耀；\n献上赞美诗歌时刻，\n感恩之心驱散忧愁."} |
| `morning.invitatory_hymn.verses.1` | "二、善牧使徒彼得，我們發聲頌讚，\n你言滿有大能，罪惡鎖鍊折斷；\n藉著神聖大能，奧祕鑰匙掌權，\n為人開啟穹蒼，或將天國門關；\n我們永遠頌揚，求你為我代禱。" | {"zh-hant": "二、教會以此君王為榮，\n得勝元帥戰士統領；\n天庭勇士光耀四方，\n普世明燈照亮萬邦。", "zh-hans": "二、教会以此君王为荣，\n得胜元帅战士统领；\n天庭勇士光耀四方，\n普世明灯照亮万邦."} |
| `morning.invitatory_hymn.verses.2` | "三、如今願將榮耀，永遠歸於聖父，\n永生上帝聖子，歌聲向祢傾注，\n至高之處聖靈，寶座前齊俯伏；\n願將尊貴讚美，榮耀永遠歸屬，\n永恆神聖三一，我們永遠敬慕。阿們。" | {"zh-hant": "三、聖徒信心如此渴慕，\n堅毅盼望永不衰退，\n基督之愛無懼無羞，\n戰勝世間諸般權勢。", "zh-hans": "三、圣徒信心如此渴慕，\n坚毅盼望永不衰退，\n基督之爱无惧无羞，\n战胜世间诸般权势."} |
| `morning.invitatory_hymn.verses.3` | （原檔沒有此欄位） | {"zh-hant": "四、聖父榮光藉此彰顯，\n聖子旨意於此成全；\n聖靈喜悅充滿其中，\n天軍天使同聲歡欣。", "zh-hans": "四、圣父荣光藉此彰显，\n圣子旨意于此成全；\n圣灵喜悦充满其中，\n天军天使同声欢欣."} |
| `morning.invitatory_hymn.verses.4` | （原檔沒有此欄位） | {"zh-hant": "五、救主垂聽愛的祈求，\n使我與此榮耀天軍，\n藉主無盡恩典眷顧，\n同享天國永恆福樂。阿們。", "zh-hans": "五、救主垂听爱的祈求，\n使我与此荣耀天军，\n藉主无尽恩典眷顾，\n同享天国永恒福乐。阿们。"} |
| `morning.lessons` | {"special": {"ot": {"book": "但以理書", "chapter": "3:19-28"}, "nt": {"book": "哥林多後書", "chapter": "1:3-11"}}} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "他們遵守他的法度和他所賜給他們的律例。哈利路亞。", "zh-hans": "他们遵守他的法度和他所赐给他们的律例。哈利路亚。", "en": "They kept his testimonies, ※ and observed his statutes, alleluia."} |
| `morning.psalms` | {"special": {"items": [{"number": "75"}, {"number": "97"}, {"number": "99"}]}} | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal` | "彼得清醒過來，※說：現在我真知道主差遣他的使者，救我脫離希律的手，和猶太人所期待的一切。" | {"zh-hant": "主說：我實在告訴你們，※你們這些跟從我的人，到了萬物更新、人子坐在他榮耀寶座上的時候，你們也要坐在十二個寶座上，審判以色列十二個支派。", "zh-hans": "主说：我实在告诉你们，※你们这些跟从我的人，到了万物更新、人子坐在他荣耀宝座上的时候，你们也要坐在十二个宝座上，审判以色列十二个支派."} |
| `evening.commemorations` | [{"display_name": "使徒聖保羅", "antiphon": "神聖的使徒保羅，真理的宣講者，萬民的導師，請為我們轉求揀選你的上帝。", "versicle": {"leader": "使徒聖保羅，你是特選之器。", "people": "向普世宣講真理者。"}, "collect": {"title": "紀念聖保羅", "text": "上帝啊，主藉著蒙福的使徒聖保羅教導真道，叫外邦人也能領受福音的真光，我們今天紀念他，懇求主因他的代求，叫我們獲得幫助。這都是靠著我主耶穌基督。主耶穌和聖父、聖靈，惟一上帝，一同永生，一同掌權，世世無盡。阿們。"}}] | （原檔沒有此欄位） |
| `evening.lessons` | {"special": {"ot": {"book": "創世記", "chapter": "22:1-19"}, "nt": {"book": "彼得前書", "chapter": "1:13-21"}}} | （原檔沒有此欄位） |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "他們的王權堅固立定；※上帝啊，你的朋友大得尊榮。", "zh-hans": "他们的王权坚固立定；※上帝啊，你的朋友大得尊荣。", "en": "Firmly established ※ is their princedom; and highly honoured are thy friends, O God."} |
| `evening.psalms` | {"special": {"items": [{"number": "116"}, {"number": "126"}, {"number": "139"}]}} | （原檔沒有此欄位） |

### sanctorale_0802_alphonsus_liguori.json

- 通用：`common_confessor_doctor_outside_easter`（一位精修者通用（復活期外）教會聖師.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.psalm_antiphons.antiphons`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `morning.bible_sentences`, `morning.psalm_antiphons.antiphons`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon` | {"normal": "主的精修者聖聖亞豐索·利古力，※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。"} | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人走入正路，將上帝的國指示給他，賜予他神聖事物的知識，使他在辛勞之中得榮耀，並增加他辛苦勞成果。", "zh-hans": "主引导义人走入正路，将上帝的国指示给他，赐予他神圣事物的知识，使他在辛劳之中得荣耀，并增加他辛苦劳成果。", "en": "The Lord guided the righteous man in right paths, and showed him the Kingdom of God; bestowed on him the knowledge of holy things, made him honourable in his travails, and increased the fruit of his labours."}, {"zh-hant": "你這又良善又忠心的僕人，※可以進來享受你主人的快樂。", "zh-hans": "你这又良善又忠心的仆人，※可以进来享受你主人的快乐。", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["聖亞豐索・馬利亞出生於一六九六年，出身於那不勒斯附近利古力家族的貴族家庭。他受洗時得了許多教名，日後他只選用頭兩個名字——亞豐索・馬利亞——作為自己的專稱。年幼時，他在許多學科上都受過悉心教導；十三歲時已在人文學科上受過良好訓練，並成為出色的音樂家。十六歲時，他通過那不勒斯大學民法與教會法的考試，取得「兩法博士」學位。此後兩年，他跟隨那不勒斯兩位著名律師受訓，繼而開始執業，成績極為出眾。據說，他在八年的律師生涯中從未輸過一宗案件，直到最後一次出庭辯護。那次事件促使他最終認定，上帝並沒有呼召他從事世俗的事業。", "年少時，他曾加入若干虔誠的善會，藉着祈禱及實踐身體力行的慈惠善工，獲得許多屬靈益處；其中最主要的善工，是探訪窮人與照料病人。然而，他對音樂的愛好也使他常流連劇院和其他世俗娛樂場所。雖然那時他的靈修生活稍有鬆懈，他卻總能藉着一種方式來安撫良心：每當眼前出現有礙靈性建樹的表演時，他便小心翼翼地摘下眼鏡；因為他患有近視，沒有眼鏡便甚麼也看不清楚。一七二二年，他參加了一次退修並領受堅振禮，隨即私下立志不婚，預備自己隨時接受上帝特別的呼召。他兩次拒絕了父親為他安排的有利婚事，最後認定上帝呼召他進入司祭職。他的父親起初為此對他大發雷霆；直到亞豐索答應暫住家中，在導師指導下預備司祭職，父親才與他和好。被按立為司祭後，他開始到處講道，很快便以能勸服罪人與世俗之人、窮人與無知者的恩賜而聞名。", "一七三二年，在屬靈導師的建議下，他奠定了一個修會的基礎，將其命名為「贖世主會」，旨在培養傳教士到鄉村貧困地區服務。亞豐索從各方面遭遇了許多艱難和苦楚，尤其是來自一些主教的阻力。最終，教宗任命他為聖阿加莎教區主教；這項職務雖非他所願，但他卻證明了自己是一位深受愛戴且忠心牧養群羊的牧者。一七八七年，他以九十一歲高齡安息主懷；其一生都奉獻於祈禱、講道、寫作與牧靈關懷之中。"]} | （原檔沒有此欄位） |
| `morning.invitatory` | {"text": "主是精修者的君王，※我們當來俯伏敬拜。"} | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3` | "四、 伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。" | {"zh-hant": "四、伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。", "zh-hans": "四、伏祈祷声恒，助忠僕越沧浪；\n赐登天国境，颂圣三于云阙；\n父子与圣灵，赞上帝永不歇；\n圣三永称扬！阿们。"} |
| `morning.office_hymn.title` | "Jesu, sacerdotum decus" | "O luce qui mortalibus" |
| `morning.office_hymn.verses.0` | "一、耶穌主僕榮冕喜樂，\n慈目垂顧主的子民，\n今值聖者榮升天鄉，\n光耀冠冕永沐聖恩。" | {"zh-hant": "一、上帝燃明燈，何其輝耀光明！\n你為地上鹽，聖味至潔純清；\n護人免腐朽，靈魂永葆潔貞，\n使人得永生。", "zh-hans": "一、上帝燃明灯，何其辉耀光明！\n你为地上盐，圣味至洁纯清；\n护人免腐朽，灵魂永葆洁贞，\n使人得永生."} |
| `morning.office_hymn.verses.1` | "二、愛主為證主恩為憑，\n自禰聖殿領受使命；\n守護照顧主贖羊群，\n父托於主彼竭其誠。" | {"zh-hant": "二、因你真理存，謬誤永不侵凌；\n因你信德貞，童貞無玷堅凝；\n因主啓寶藏，智慧豐盈傾注，\n智慧顯於今。", "zh-hans": "二、因你真理存，谬误永不侵凌；\n因你信德贞，童贞无玷坚凝；\n因主启宝藏，智慧丰盈倾注，\n智慧显于今."} |
| `morning.office_hymn.verses.2` | "三、驅散凶獸斥退豺狼，\n詭計雖狡盡皆洞穿；\n護衛群羊願承危險，\n捨命爭戰忠勇無雙。" | {"zh-hant": "三、聖泉湧活水，清澈潤澤無垠，\n潤基督田地，結實累累豐登；\n為乳汁育嬰，為壯者備真糧，\n萬民得飽饗。", "zh-hans": "三、圣泉涌活水，清澈润泽无垠，\n润基督田地，结实累累丰登；\n为乳汁育婴，为壮者备真粮，\n万民得饱飨."} |
| `morning.office_hymn.verses.3` | "四、每逢獻上無血聖祭，\n救恩聖筵價值無極；\n羊群置於祭壇之上，\n自己也為活獻祭上。" | {"zh-hant": "四、永恆真理主，我眾因主歡欣！\n肉身耳雖聞，未解聖言深恩，\n聖師言教中，啓迪靈性明心，\n聖靈耀吾靈。阿們。", "zh-hans": "四、永恒真理主，我众因主欢欣！\n肉身耳虽闻，未解圣言深恩，\n圣师言教中，启迪灵性明心，\n圣灵耀吾灵。阿们。"} |
| `morning.office_hymn.verses.4` | "五、唯願榮耀讚頌尊威，\n歸於至高祭司耶穌，\n歸於聖父保惠聖靈，\n三一上帝永受讚頌。阿們。" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader` | "義人必如百合花開放，" | {"zh-hant": "我已陳明主的信實和救恩；", "zh-hans": "我已陈明主的信实和救恩；"} |
| `morning.office_hymn.versicle.people` | "永遠繁榮在主面前。" | {"zh-hant": "我未曾隱瞞主的慈愛和信實。", "zh-hans": "我未曾隐瞒主的慈爱和信实."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "願那愛你名的人都靠你歡欣。※因為你必賜福與義人；主啊，你必用恩惠如同盾牌四面護衛他。", "zh-hans": "愿那爱你名的人都靠你欢欣。※因为你必赐福与义人；主啊，你必用恩惠如同盾牌四面护卫他。", "en": "Let all rejoice ※ who hope in thee, O Lord; since thou hast blessed the righteous man, and with the shield of thy good will hast crowned him."}, {"zh-hant": "在遵守至高者的法律上，※沒有人可與他對立。", "zh-hans": "在遵守至高者的法律上，※没有人可与他对立。", "en": "There was none found ※ like unto him, who kept the law of the Most High."}] |
| `evening.office_hymn.title` | "Jesu, sacerdotum decus" | "O luce qui mortalibus" |
| `evening.office_hymn.verses.0` | "一、耶穌主僕榮冕喜樂，\n慈目垂顧主的子民，\n今值聖者榮升天鄉，\n光耀冠冕永沐聖恩。" | {"zh-hant": "一、上帝燃明燈，何其輝耀光明！\n你為地上鹽，聖味至潔純清；\n護人免腐朽，靈魂永葆潔貞，\n使人得永生。", "zh-hans": "一、上帝燃明灯，何其辉耀光明！\n你为地上盐，圣味至洁纯清；\n护人免腐朽，灵魂永葆洁贞，\n使人得永生."} |
| `evening.office_hymn.verses.1` | "二、愛主為證主恩為憑，\n自禰聖殿領受使命；\n守護照顧主贖羊群，\n父托於主彼竭其誠。" | {"zh-hant": "二、因你真理存，謬誤永不侵凌；\n因你信德貞，童貞無玷堅凝；\n因主啓寶藏，智慧豐盈傾注，\n智慧顯於今。", "zh-hans": "二、因你真理存，谬误永不侵凌；\n因你信德贞，童贞无玷坚凝；\n因主启宝藏，智慧丰盈倾注，\n智慧显于今."} |
| `evening.office_hymn.verses.2` | "三、驅散凶獸斥退豺狼，\n詭計雖狡盡皆洞穿；\n護衛群羊願承危險，\n捨命爭戰忠勇無雙。" | {"zh-hant": "三、聖泉湧活水，清澈潤澤無垠，\n潤基督田地，結實累累豐登；\n為乳汁育嬰，為壯者備真糧，\n萬民得飽饗。", "zh-hans": "三、圣泉涌活水，清澈润泽无垠，\n润基督田地，结实累累丰登；\n为乳汁育婴，为壮者备真粮，\n万民得饱飨."} |
| `evening.office_hymn.verses.3` | "四、每逢獻上無血聖祭，\n救恩聖筵價值無極；\n羊群置於祭壇之上，\n自己也為活獻祭上。" | {"zh-hant": "四、永恆真理主，我眾因主歡欣！\n肉身耳雖聞，未解聖言深恩，\n聖師言教中，啓迪靈性明心，\n聖靈耀吾靈。阿們。", "zh-hans": "四、永恒真理主，我众因主欢欣！\n肉身耳虽闻，未解圣言深恩，\n圣师言教中，启迪灵性明心，\n圣灵耀吾灵。阿们。"} |
| `evening.office_hymn.verses.4` | "五、唯願榮耀讚頌尊威，\n歸於至高祭司耶穌，\n歸於聖父保惠聖靈，\n三一上帝永受讚頌。阿們。" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪！這是大祭司，※他在世之時取悅了上帝，被看為完全，是個義人。", "zh-hans": "看哪！这是大祭司，※他在世之时取悦了上帝，被看为完全，是个义人。", "en": "Behold a great Priest, ※ who in his days pleased God, and was found righteous."}, {"zh-hant": "這是那忠心有見識的管家，主人派他管理家裡的人。", "zh-hans": "这是那忠心有见识的管家，主人派他管理家里的人。", "en": "A wise and faithful steward, whom the Lord made ruler over his household."}] |

### sanctorale_0803_nicodemus.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0804_dominic.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["聖道明於一一七○年生於西班牙卡拉羅加，出身於古斯曼貴族家庭。他在帕倫西亞大學完成學業後，加入奧斯馬法政司祭團，成為會規法政司祭。一二○三年，他奉命出使，途中經過法國；在那裏，他察覺到阿爾比派異端對人類社會造成的危害，並明白唯有正確宣講「道成肉身」的教義，才能醫治這種屬靈的疾病。", "因此，他開始在阿爾比派人士中講道和施教，藉着祈禱、勸導、學識與聖潔生活的榜樣，努力引領他們回歸大公信仰。他拒絕以暴力使人歸正，深信信仰的真理應當藉着宣講與聖潔來見證，而不是以武力強迫。", "他聚集同伴，創立了「宣道兄弟會」，即道明會。這個修會的職分，是藉着富有學識的宣講來捍衛信仰、拯救靈魂。他一生熱愛貧窮、祈禱、研讀，並對罪人充滿憐憫。一二二一年，他安息主懷，為教會留下了以他名字命名、並持續履行宣講職事的修會。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0805_oswald.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這位聖者為維護上帝的律法奮鬥至死，※對惡人的恐嚇毫不畏懼；因為他好像建在穩固的磐石上。", "zh-hans": "这位圣者为维护上帝的律法奋斗至死，※对恶人的恐吓毫不畏惧；因为他好像建在稳固的磐石上。", "en": "This is a holy man ※ who strove for the law of his God, even unto death; and feared not the words of evil men, forasmuch as he was established on the sure and firm Rock."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "公義的主※喜愛公義；他的眼目必看顧正直的人。", "zh-hans": "公义的主※喜爱公义；他的眼目必看顾正直的人。", "en": "The righteous Lord ※ loveth righteousness; his countenance will behold the thing that is just."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他。", "en": "Whosoever shall confess ※ me before men, him will I confess also before my Father."}, {"zh-hant": "那在智慧中恆心不渝，※默想神聖之事，並在心中思想上帝無所不見之大能的人有福了。", "zh-hans": "那在智慧中恒心不渝，※默想神圣之事，并在心中思想上帝无所不见之大能的人有福了。", "en": "Blessed is the man ※ that continueth in wisdom, and doth meditate on holy things, and that reasoneth in his mind on the all-seeing power of God."}] |

### sanctorale_0808_john_mason_neale.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`。
- 保留原先缺失／停用狀態：`evening`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "當用各樣的智慧，※把基督的道豐豐富富的存在心裏，用詩篇、讚美詩、靈歌，彼此教導，互相勸戒，以感恩的心歌頌上帝。" | {"zh-hant": "我要把他好比一個聰明人，※把房子蓋在磐石上。", "zh-hans": "我要把他好比一个聪明人，※把房子盖在磐石上."} |
| `vigil.office_hymn.versicle.leader` | "你們當向主唱新歌。" | {"zh-hant": "主愛了他，並裝扮了他。", "zh-hans": "主爱了他，并装扮了他."} |
| `vigil.office_hymn.versicle.people` | "因主做了奇事。" | {"zh-hant": "給他穿上榮耀的外衣。", "zh-hans": "给他穿上荣耀的外衣."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.benedictus_antiphon.normal` | "當用各樣的智慧，※把基督的道豐豐富富的存在心裏，用詩篇、讚美詩、靈歌，彼此教導，互相勸戒，以感恩的心歌頌上帝。" | {"zh-hant": "好，你這又善良又忠心的僕人，※你在少許的事上忠心，我要派你管理許多的事，進來享受你主人的快樂吧！", "zh-hans": "好，你这又善良又忠心的仆人，※你在少许的事上忠心，我要派你管理许多的事，进来享受你主人的快乐吧！"} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["尼爾於1818年出生在倫敦，自幼展現出極高的古典文學與語言天賦。他在劍橋大學就讀期間，深受致力於恢復大公教會傳統的「牛津運動」影響。1839年，他協助創立了劍橋坎登學會，提倡哥德式建築復興，並推動在安立甘教堂中恢復更具儀式感的禮儀，為日後捍衛安立甘宗的大公身分奠定基礎。尼爾堅信安立甘宗是自使徒時代以來神聖大公教會的延續。面對當時對「高派」理念的敵視，他毫不退縮。透過對東方教會歷史與禮儀的深入研究，他向信徒展示了超越羅馬傳統的廣闊大公信仰。", "在捍衛安立甘信仰的過程中，尼爾付出了巨大的代價。他因堅持高派禮儀而遭教會內部強烈反對，甚至被所屬主教停止在堂區職權長達十數年，並曾面臨暴徒襲擊。然而他從未妥協，於1854年創立了聖瑪格麗特修會，專注護理病患與窮人。儘管當時恢復修道生活備受新教徒猜忌，修女們在霍亂期間的無私奉獻最終贏得了社會尊重，為安立甘宗重新確立修道生活的合法性打下了堅實基礎。尼爾精通多種語言，將大量早期與中世紀的拉丁文、希臘文聖詩翻譯成英文，如著名的《以馬內利來臨歌曲》與《無量榮光歌》。他深信這些來自古代教會的聖詩是歷代聖徒的心血，更是安立甘宗作為大公教會不可或缺的屬靈遺產。", "1866年8月6日，基督易容顯光日，尼爾安息主懷，享年僅48歲。為紀念他，安立甘公教會在8月8日慶祝他的慶節。他以學者的嚴謹與殉道者的勇氣，在重重阻力中捍衛了安立甘傳統，使安立甘宗能在神學上確信自身的大公身分，並在壯麗禮儀與不朽聖詩中活出這份神聖信仰。"]} | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader` | "你們當向主唱新歌。" | {"zh-hant": "主引導義人走入正路，", "zh-hans": "主引导义人走入正路."} |
| `morning.office_hymn.versicle.people` | "因主做了奇事。" | {"zh-hant": "將上帝的國指示給他。", "zh-hans": "将上帝的国指示给他."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening` | （原檔沒有此欄位） | {"bible_sentences": [{"text": {"zh-hant": "寶座中的羔羊必牧養他們，領他們到生命水的泉源；上帝必擦去他們一切的眼淚。", "zh-hans": "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪."}, "reference": {"zh-hant": "（啟示錄 7:17）", "zh-hans": "（启示录 7:17）"}}], "psalm_antiphons": {"lectionary_1943": [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}], "antiphons": [{"zh-hant": "主啊，※你交給我五千。請看，我又賺了五千。", "zh-hans": "主啊，※你交给我五千。请看，我又赚了五千."}, {"zh-hant": "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！", "zh-hans": "好，※你这又善良又忠心的仆人，你在少许的事上忠心，进来享受你主人的快乐吧！"}, {"zh-hant": "他是※那忠心又精明的僕人，主人派他管理自己的家。", "zh-hans": "他是※那忠心又精明的仆人，主人派他管理自己的家."}, {"zh-hant": "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。", "zh-hans": "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了."}, {"zh-hant": "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！", "zh-hans": "你这※又善良又忠心的仆人，进来享受你主人的快乐吧！"}]}, "office_hymn": {"title": "Jesu, sacerdotum decus", "verses": [{"zh-hant": "一、求救世主耶穌垂聽，\n聖人榮冕即將臨近。\n現以溫柔愛心接納，\n我們獻上祈禱讚美。", "zh-hans": "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美."}, {"zh-hant": "二、這位謙卑精修聖人，\n今日獲得榮耀美名。\n忠信子民每年歡欣，\n莊嚴慶賀聖人節日。", "zh-hans": "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日."}, {"zh-hant": "三、他已拋棄世界虛榮，\n視為虛空轉瞬即逝。\n現已列入天使歌團，\n進入無窮喜樂之中。", "zh-hans": "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中."}, {"zh-hant": "四、懇求仁慈上帝賜恩，\n求使我們隨他芳蹤。\n藉著聖人祈禱之能，\n脫離一切罪惡污穢。", "zh-hans": "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽."}, {"zh-hant": "五、仁君基督永享尊荣，\n偕同天父同享榮耀；\n也歸於保惠師聖靈，\n三一上帝永世無盡。阿們。", "zh-hans": "五、仁君基督永享尊荣，\n偕同天父同享荣耀；\n也归于保惠师圣灵，\n三一上帝永世无尽。阿们。"}], "versicle": {"leader": {"zh-hant": "義人的口談論智慧；", "zh-hans": "义人的口谈论智慧."}, "people": {"zh-hant": "他的舌頭講說公平。", "zh-hans": "他的舌头讲说公平."}}}, "benedictus_antiphon": {"normal": {"zh-hant": "這是一位在上帝之前行大事之人，※他的教導充滿全地；願他為眾人的罪過代求。", "zh-hans": "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求."}}} |

### sanctorale_0809_john_vianney.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["1786 年，在法國達爾迪利，一個名為維雅納的虔敬農家誕下一子，名為約翰・巴普蒂斯特・馬利亞（John Baptist Mary）。他自幼便顯出非凡的聖德徵兆。當時法國教會因革命而大受阻礙，宗教教育十分缺乏。約翰八歲時，常被差遣去放羊；他有時會召集其他小孩，以言語和行動教導他們誦念玫瑰經，並讓他們跪下與他一同祈禱。有時他也會把羊群交託給身邊的人照看，自己退避到較僻靜之處，尋求更好的祈禱機會。法國教會恢復後，約翰立志成為司祭。然而，他先前只學過最基本的知識，於是由其本堂司祭負責教導他進修。後來他被徵召入伍，不久後卻因一次離奇的意外而被列為逃兵。為免遭處決，他被迫躲藏數月，直到其身分問題獲得解決。此期間以及退役之後，他都專心致志地學習。但他悟性遲緩，幾乎無法掌握功課。為此，他藉著禁食與祈禱懇求上帝幫助，迫切懇求賜下他所需要的恩賜。就這樣，憑藉著辛勤的努力，他終於完成了神學課程，最終被認定具備足夠的知識以領受聖秩。", "他擔任本堂司祭的助理將近三年，之後被指派照管阿爾斯堂區。那是一個在屬靈上如荒漠般貧瘠的小村莊，但他卻使它如玫瑰般綻放。因為他鼓勵信徒頻繁領受聖餐，又成立了敬虔的善會，並成功地教導信仰，以致大公教會的敬虔生活漸漸興盛。同時，他深信牧者有不可推卸的責任為其會眾的罪作補贖，因此從不吝惜為他們獻上祈禱、守夜和不斷的禁食。他尤其勸勉他的懺悔者常作簡短的短誦禱文，說：「這樣的祈禱，好比零散撒在各處的稻草，一旦被點燃，便會燃起許多極其熾熱的小火焰。」", "既然撒但不能再容忍這位上帝僕人的基督徒氣概，起初便以許多肉身的軟弱、特別是胃疾來折磨他；其次，在十五年間，他遭受了魔鬼的侵擾。透過邪靈極大而頻繁的迫害，他的德行日益長進，自身也成為了最聖善的司祭之一。於是，在他事奉的最初幾年裡，他帶領了近十萬人歸正，這些人不但在阿爾斯牧區及其鄰近地區，更是來自法國各地乃至世界各處，他們紛紛轉向他，尋求靈魂的醫治。除了舉行聖餐獻祭外，他不是在祭臺前、講道臺上，就是在聽取告解。據說在他生命的晚年、七十三歲高齡時，他每日聽取的告解竟多達兩千人。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0810_lawrence.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.office_hymn`, `evening.bible_sentences`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.office_hymn`, `evening.bible_sentences`。
- 保留原先缺失／停用狀態：`morning.benedictus_antiphon.normals`, `evening.benedictus_antiphon.normals`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "當聖勞倫斯在鐵架上受烙刑時，※對不虔誠的暴君說：「盛宴已備好，翻過來吃吧；但你所尋找的教會財富，早已被窮人與由需要之人的雙手帶到天上的寶庫里了。」" | {"zh-hant": "這真是一位殉道者，※他為基督的名傾流了鮮血；他不畏懼審判者的威嚇，不追求世俗的尊貴榮耀，喜樂地進入天國。", "zh-hans": "这真是一位殉道者，※他为基督的名倾流了鲜血；他不畏惧审判者的威吓，不追求世俗的尊贵荣耀，喜乐地进入天国."} |
| `vigil.office_hymn.versicle.leader` | "他施捨錢財，周濟貧窮；" | {"zh-hant": "主加增他尊贵荣耀。", "zh-hans": "主加增他尊贵荣耀."} |
| `vigil.office_hymn.versicle.people` | "他的仁義存到永遠。" | {"zh-hant": "把主所创造的归他管理，", "zh-hans": "把主所创造的归他管理，"} |
| `vigil.psalm_antiphons.antiphons.0` | "勞倫斯※作為基督的勇士挺身應戰；因他公開宣信了耶穌基督。" | {"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他."} |
| `vigil.psalm_antiphons.antiphons.1` | "勞倫斯作了一件美事；※他藉著十架聖號，使瞎眼的人得看見。" | {"zh-hant": "我就是世界的光。※跟從我的，必不在黑暗裏走，卻要得着生命的光。", "zh-hans": "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光."} |
| `vigil.psalm_antiphons.antiphons.2` | "我的心依戀主，我的上帝；※我必不與主分離，因为我的身体为了祢已被焚烧，我的心依然切慕主。" | {"zh-hant": "若有人服事我，※就當跟從我；我在哪裏，服事我的人也要在哪裏。", "zh-hans": "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里."} |
| `vigil.psalm_antiphons.antiphons.3` | "我的上帝差遣了他的使者，正如他待那三位聖童一樣；※他將我從烈火之中救拔出來，使我不致被勝過。" | {"zh-hant": "主說：※若有人服事我，我父必尊重他。", "zh-hans": "主说：※若有人服事我，我父必尊重他."} |
| `vigil.psalm_antiphons.antiphons.4` | "最後，聖勞倫說：主阿，我感謝祢；※因主算我配得進入主的門。。" | {"zh-hant": "聖父阿，※我在哪裏，服事我的人也要在哪裏。", "zh-hans": "圣父阿，※我在哪里，服事我的人也要在哪里."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這位聖者為維護上帝的律法奮鬥至死，※對惡人的恐嚇毫不畏懼；因為他好像建在穩固的磐石上。", "zh-hans": "这位圣者为维护上帝的律法奋斗至死，※对恶人的恐吓毫不畏惧；因为他好像建在稳固的磐石上。", "en": "This is a holy man ※ who strove for the law of his God, even unto death; and feared not the words of evil men, forasmuch as he was established on the sure and firm Rock."} |
| `morning.benedictus_antiphon.normal` | "上帝，在鐵架上，※我沒有否認你；基督，當我被放在烈火之上時，我仍宣認你：你證明瞭我的內心，在夜裡來訪；你藉烈火試煉我，但在我內卻卻找不到任何邪惡。" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normals` | （原檔沒有此欄位） | [{"zh-hant": "一粒麥子不落在地裏死了，※仍舊是一粒。", "zh-hans": "一粒麦子不落在地里死了，※仍旧是一粒."}, {"zh-hant": "主說：若有人要跟從我，※就當捨己，背起自己的十字架來跟從我。", "zh-hans": "主说：若有人要跟从我，※就当舍己，背起自己的十字架来跟从我."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["在教會中，沒有一個名字比勞倫斯更為著名；拉丁教父曾著書讚揚他，古代教會也一向樂於一同尊崇他。西班牙曾宣稱他為該國人；但確知的是，他乃羅馬教會由西斯篤二世任命的七位會吏之一。這些利未人掌管錢囊和教會財物，負責照料眾多貧困與有需要的基督徒，並協助施行聖禮與奉獻聖餐獻祭。當時羅馬教會正遭逢一道敕令，規定所有主教、牧師及會吏均須處死。八月六日，聖西斯篤殉道；四日後，聖勞倫斯作了以下祈禱：「求主憐憫主的僕人，因我是主的僕人，是住婢女的兒子。求主將力量賜給這青年，使他配得為主施洗。」在他受苦之初，聖勞倫斯說：「黑暗漸漸過去，黑夜發亮如白晝，這光越照越明，直到日午。」", {"type": "source", "text": "節選自教宗聖利奧的聖勞倫斯日講道"}, "當異教勢力向教會的一些護衛者，尤其是向主教發難時，那邪惡的迫害者便轉而對付德行崇高的西斯篤。勞倫斯負責將賙濟分發給窮人。因此，迫害者一逮捕西斯篤，便以為可以得到雙重戰利品：蒙福的勞倫斯所掌管的財寶，以及西斯篤的性命。勞倫斯身為會吏長，既因職責受託，又因愛護貧者，便以雙重熱忱為大公真理奮戰。迫害者的貪婪日益加深，他竭盡一切異教暴行，要從信徒手中奪取資財，甚至不斷向那被迫交出財物的主管催逼索討。他說：「我所渴望的，正是那些財寶所在之處。看哪，教會最窮乏的一部分，就是這些虔敬的窮人；他們構成了教會的財富。因此，他們絕不會因強權而變得貧乏，反倒能藉著所賜予他們的聖潔之道得著供養。」", "這強盜般的迫害者既受挫折，便憤怒地攻擊這個把窮人視為財寶的宗教。他又企圖施行更大的掠奪：既聽說教會的財寶在窮人手中，便索取教會最寶貴的財產。勞倫斯曾藉著洗禮使一位青年成為上帝的兒女，使他在聖潔與善德上富足。異教徒見這位利未人的心志堅定不移，便把怒氣發洩在徒然且駭人的酷刑上；然而，這位美善受苦者的堅忍，讓這記載更令人敬畏。他下令將勞倫斯慢慢炙烤至瀕死，然後置於火上烘烤。為此，他們添上燃燒的炭火，把這位英雄放在其上；施刑者又用鐵叉翻動他的肢體，要使他的痛苦延長。他以極大的忍耐承受殘酷折磨，神色毫不改變，反而越發顯出超凡的剛毅。那終有一死的肉身，逐漸超越了痛苦所能及之處；他的苦楚終於不再延長。"]} | （原檔沒有此欄位） |
| `morning.invitatory.text` | "主基督賜予殉道者聖勞倫斯上天得勝的冠冕，※我們當來俯伏敬拜永恆的君王。" | {"zh-hant": "主是殉道者的君王，※我們當來俯伏敬拜。", "zh-hans": "主是殉道者的君王，※我们当来俯伏敬拜."} |
| `morning.psalm_antiphons.antiphons.0` | "勞倫斯※作為基督的勇士挺身應戰；因他公開宣信了耶穌基督。" | {"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他."} |
| `morning.psalm_antiphons.antiphons.1` | "勞倫斯作了一件美事；※他藉著十架聖號，使瞎眼的人得看見。" | {"zh-hant": "我就是世界的光。※跟從我的，必不在黑暗裏走，卻要得着生命的光。", "zh-hans": "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光."} |
| `morning.psalm_antiphons.antiphons.2` | "我的心依戀主，我的上帝；※我必不與主分離，因为我的身体为了祢已被焚烧，我的心依然切慕主。" | {"zh-hant": "若有人服事我，※就當跟從我；我在哪裏，服事我的人也要在哪裏。", "zh-hans": "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里."} |
| `morning.psalm_antiphons.antiphons.3` | "我的上帝差遣了他的使者，正如他待那三位聖童一樣；※他將我從烈火之中救拔出來，使我不致被勝過。" | {"zh-hant": "主說：※若有人服事我，我父必尊重他。", "zh-hans": "主说：※若有人服事我，我父必尊重他."} |
| `morning.psalm_antiphons.antiphons.4` | "最後，聖勞倫說：主阿，我感謝祢；※因主算我配得進入主的門。。" | {"zh-hant": "聖父阿，※我在哪裏，服事我的人也要在哪裏。", "zh-hans": "圣父阿，※我在哪里，服事我的人也要在哪里."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "公義的主※喜愛公義；他的眼目必看顧正直的人。", "zh-hans": "公义的主※喜爱公义；他的眼目必看顾正直的人。", "en": "The righteous Lord ※ loveth righteousness; his countenance will behold the thing that is just."} |
| `evening.benedictus_antiphon.normal` | "來吧，我良善熱誠之僕人；※來吧，我的天使將接納你；因你受烙刑時，沒有否認我；當你受考驗時，明認了我。" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals` | （原檔沒有此欄位） | [{"zh-hant": "他將世上的一切都視為無物，※以言以行，為自己在天上積蓄財寶。", "zh-hans": "他将世上的一切都视为无物，※以言以行，为自己在天上积蓄财宝."}, {"zh-hant": "此人徹悟公義，洞悉奇偉奧秘；※他祈求至高者，終列諸聖之中。", "zh-hans": "此人彻悟公义，洞悉奇伟奥秘；※他祈求至高者，终列诸圣之中."}] |
| `evening.office_hymn.versicle.leader` | "他施捨錢財，周濟貧窮；" | {"zh-hant": "主迎接他，赐他厚福，", "zh-hans": "主迎接他，赐他厚福，"} |
| `evening.office_hymn.versicle.people` | "他的仁義存到永遠。" | {"zh-hant": "将精金的冠冕，戴在他的头上。", "zh-hans": "将精金的冠冕，戴在他的头上。"} |
| `evening.psalm_antiphons.antiphons.0` | "勞倫斯※作為基督的勇士挺身應戰；因他公開宣信了耶穌基督。" | {"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他."} |
| `evening.psalm_antiphons.antiphons.1` | "勞倫斯作了一件美事；※他藉著十架聖號，使瞎眼的人得看見。" | {"zh-hant": "我就是世界的光。※跟從我的，必不在黑暗裏走，卻要得着生命的光。", "zh-hans": "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光."} |
| `evening.psalm_antiphons.antiphons.2` | "我的心依戀主，我的上帝；※我必不與主分離，因为我的身体为了祢已被焚烧，我的心依然切慕主。" | {"zh-hant": "若有人服事我，※就當跟從我；我在哪裏，服事我的人也要在哪裏。", "zh-hans": "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里."} |
| `evening.psalm_antiphons.antiphons.3` | "我的上帝差遣了他的使者，正如他待那三位聖童一樣；※他將我從烈火之中救拔出來，使我不致被勝過。" | {"zh-hant": "主說：※若有人服事我，我父必尊重他。", "zh-hans": "主说：※若有人服事我，我父必尊重他."} |
| `evening.psalm_antiphons.antiphons.4` | "最後，聖勞倫說：主阿，我感謝祢；※因主算我配得進入主的門。。" | {"zh-hant": "聖父阿，※我在哪裏，服事我的人也要在哪裏。", "zh-hans": "圣父阿，※我在哪里，服事我的人也要在哪里."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他。", "en": "Whosoever shall confess ※ me before men, him will I confess also before my Father."}, {"zh-hant": "那在智慧中恆心不渝，※默想神聖之事，並在心中思想上帝無所不見之大能的人有福了。", "zh-hans": "那在智慧中恒心不渝，※默想神圣之事，并在心中思想上帝无所不见之大能的人有福了。", "en": "Blessed is the man ※ that continueth in wisdom, and doth meditate on holy things, and that reasoneth in his mind on the all-seeing power of God."}] |

### sanctorale_0812_clare.json

- 通用：`common_virgin_outside_easter`（一位童貞女通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.antiphons.0` | "這是那位明智的貞女，她是那聰明貞女當中的一位。" | {"zh-hant": "這是那位明智的貞女，※她是那聰明貞女當中的一位。", "zh-hans": "这是那位明智的贞女，※她是那聪明贞女当中的一位."} |
| `vigil.psalm_antiphons.antiphons.1` | "這是那位明智的貞女，是主來到時發現醒悟著的貞女。" | {"zh-hant": "這是那位明智的貞女，※是主來到時發現醒悟著的貞女。", "zh-hans": "这是那位明智的贞女，※是主来到时发现醒悟着的贞女."} |
| `vigil.psalm_antiphons.antiphons.2` | "這就是那不知床第罪惡的女子，在靈魂受眷顧的時候，她必富有果實。" | {"zh-hant": "這就是那不知床第罪惡的女子，※在靈魂受眷顧的時候，她必富有果實。", "zh-hans": "这就是那不知床第罪恶的女子，※在灵魂受眷顾的时候，她必富有果实."} |
| `vigil.psalm_antiphons.antiphons.3` | "來吧，我所揀選的，我要讓她坐在我的寶座上。" | {"zh-hant": "來吧，※我所揀選的，我要讓她坐在我的寶座上。", "zh-hans": "来吧，※我所拣选的，我要让她坐在我的宝座上."} |
| `vigil.psalm_antiphons.antiphons.4` | "這就是那在耶路撒冷的女兒中美貌秀麗的那一位。" | {"zh-hant": "這就是※那在耶路撒冷的女兒中美貌秀麗的那一位。", "zh-hans": "这就是※那在耶路撒冷的女儿中美貌秀丽的那一位."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這是一位神聖榮耀的童貞女，※萬主之主已經揀選了她。", "zh-hans": "这是一位神圣荣耀的童贞女，※万主之主已经拣选了她。", "en": "This is a virgin, ※ glorious and holy, for the Lord of all hath chosen her. "} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["她於 1194 年出生在阿西西的家族宅邸，是薩索-羅索伯爵（Count of Sasso-Rosso）的長女。在那裡她一直生活到十八歲。當時，家人正為她安排一門富貴的婚事，但她卻決心跟隨同鄉阿西西的法蘭西斯，走貧窮的道路。她展現出與其父親如出一轍的勇氣與堅毅；由於深知在家人正為她籌劃婚事之際，絕不可能獲得父母同意成為修女，她便暗中將自己所有的一切施捨給窮人。某個夜晚，她挖通了一扇被封死的門洞逃離家門——那扇門通常只有在抬出家族死者去安葬時才會開啟。當父親發現她以此舉表明放棄財富與特權、決心向世俗而死時，便決意要迫使她屈服。在此同時，她已前往阿西西的法蘭西斯會修士所使用的「博俊古辣小堂」（Church of the Little Portion）。就在那個深夜，法蘭西斯為她穿上修會的會衣並剪去她的頭髮，隨後將她安置在附近的一所本篤會女修院，為她崇高的召命接受訓練。", "她的父親一得知她的去向，便立刻趕來，企圖強行將她帶回家。但克萊爾在小聖堂中避難，緊緊抱住祭壇，挑戰他，因為其父將她從那裡拉開。父親看見她的堅定，便轉而訴諸她的孝心；此時她露出被剪短的頭髮，以此表明自己已不可撤回地成為了基督的新婦。父親對女兒的勇氣唯有欽佩，最終允許她留下。後來，她的另一位姊妹（阿格尼絲）也加入了她；在父親過世後，她的母親奧爾托拉娜同樣也加入了這個行列。法蘭西斯儘快將克萊爾以及那些尋求同樣召命的修女們，安置在聖達米昂堂——這是他親手修復的教堂之一。克萊爾在那裡擔任女修院院長近四十年，直到去世。許多由克萊爾訓練的修女從聖達米昂堂出發，到世界各地建立如今被稱為「貧窮克萊爾會」（Poor Clares）的生活。她們的修會致力於祈禱與補贖，代表這世界向上帝獻上祈禱，並特別敬奉至聖聖體——這是上帝對我們之愛在地上的首要記號。在建立修會的過程中，克萊爾經歷了幾乎令人難以置信的艱難；她在其中始終展現出的智慧與堅毅，證明了她確實是上帝最英勇的女子之一。", "關於她有許多奇妙的傳聞，但最引人注目的，是發生在一群撒拉森士兵入侵該地區之時。他們意圖洗劫女修院並侵犯修女。克萊爾除了信仰之外，對他們毫無防禦之力。因此，她從祭壇上取下至聖聖禮，說道：「我的女兒們，不要害怕；要信靠耶穌。」她帶領著修女們走出院門，以聖禮作為武器，彷彿要以此攻擊撒拉森人。這些士兵對婦女們所展現出的明顯而奇異的勇氣感到驚愕不已，竟轉身逃跑。在她生命最後的二十七年中，她飽受極度虛弱之苦，但她的虔誠與喜樂卻從未有絲毫減退。人們紛紛從遠處趕來，為要從她那裡認識上帝；當她臨終之際，反而是她給予周圍的人鼓勵。就這樣，她於 1253 年，即聖勞倫斯日的次日，充滿喜樂地離世，永遠與她真正的新郎同在。當時她享年六十歲，也是她宣發修道誓願的第四十二年。在她於 1255 年被封聖之後，她的慶日被定於 8 月 12 日，即她安葬之日。如今，在阿西西她的聖所裡，仍能見到她身穿灰衣的童貞女遺體；許多朝聖者來到這裡，敬仰這位藉著真福聖事而得勝的聖女。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0` | "這是那位明智的貞女，她是那聰明貞女當中的一位。" | {"zh-hant": "這是那位明智的貞女，※她是那聰明貞女當中的一位。", "zh-hans": "这是那位明智的贞女，※她是那聪明贞女当中的一位."} |
| `morning.psalm_antiphons.antiphons.1` | "這是那位明智的貞女，是主來到時發現醒悟著的貞女。" | {"zh-hant": "這是那位明智的貞女，※是主來到時發現醒悟著的貞女。", "zh-hans": "这是那位明智的贞女，※是主来到时发现醒悟着的贞女."} |
| `morning.psalm_antiphons.antiphons.2` | "這就是那不知床第罪惡的女子，在靈魂受眷顧的時候，她必富有果實。" | {"zh-hant": "這就是那不知床第罪惡的女子，※在靈魂受眷顧的時候，她必富有果實。", "zh-hans": "这就是那不知床第罪恶的女子，※在灵魂受眷顾的时候，她必富有果实."} |
| `morning.psalm_antiphons.antiphons.3` | "來吧，我所揀選的，我要讓她坐在我的寶座上。" | {"zh-hant": "來吧，※我所揀選的，我要讓她坐在我的寶座上。", "zh-hans": "来吧，※我所拣选的，我要让她坐在我的宝座上."} |
| `morning.psalm_antiphons.antiphons.4` | "這就是那在耶路撒冷的女兒中美貌秀麗的那一位。" | {"zh-hant": "這就是※那在耶路撒冷的女兒中美貌秀麗的那一位。", "zh-hans": "这就是※那在耶路撒冷的女儿中美貌秀丽的那一位."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "基督的淨配，※請來接受主從永遠就為你準備好的華冠。", "zh-hans": "基督的净配，※请来接受主从永远就为你准备好的华冠。", "en": "Come, thou bride of Christ,※ receive the crown, which the Lord hath provided for thee for ever."} |
| `evening.psalm_antiphons.antiphons.0` | "這是那位明智的貞女，她是那聰明貞女當中的一位。" | {"zh-hant": "這是那位明智的貞女，※她是那聰明貞女當中的一位。", "zh-hans": "这是那位明智的贞女，※她是那聪明贞女当中的一位。", "en": "This is a wise virgin, ※ and one of the number of the prudent."} |
| `evening.psalm_antiphons.antiphons.1` | "這是那位明智的貞女，是主來到時發現醒悟著的貞女。" | {"zh-hant": "這是那位明智的貞女，※是主來到時發現醒悟著的貞女。", "zh-hans": "这是那位明智的贞女，※是主来到时发现醒悟着的贞女."} |
| `evening.psalm_antiphons.antiphons.2` | "這就是那不知床第罪惡的女子，在靈魂受眷顧的時候，她必富有果實。" | {"zh-hant": "這就是那不知床第罪惡的女子，※在靈魂受眷顧的時候，她必富有果實。", "zh-hans": "这就是那不知床第罪恶的女子，※在灵魂受眷顾的时候，她必富有果实."} |
| `evening.psalm_antiphons.antiphons.3` | "來吧，我所揀選的，我要讓她坐在我的寶座上。" | {"zh-hant": "來吧，※我所揀選的，我要讓她坐在我的寶座上。", "zh-hans": "来吧，※我所拣选的，我要让她坐在我的宝座上."} |
| `evening.psalm_antiphons.antiphons.4` | "這就是那在耶路撒冷的女兒中美貌秀麗的那一位。" | {"zh-hant": "這就是※那在耶路撒冷的女兒中美貌秀麗的那一位。", "zh-hans": "这就是※那在耶路撒冷的女儿中美貌秀丽的那一位."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這是那位明智的貞女，※她是那聰明貞女當中的一位。", "zh-hans": "这是那位明智的贞女，※她是那聪明贞女当中的一位.", "en": "This is a wise virgin, ※ and one of the number of the prudent."} |

### sanctorale_0813_hippolytus_and_cassian.json

- 通用：`common_martyrs_outside_easter`（多位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "諸聖藉著信，※制伏了敵國，行了公義，得了應許。", "zh-hans": "诸圣藉着信，※制伏了敌国，行了公义，得了应许。", "en": "The Saints through faith ※subdued kingdoms, they wrought righteousness, they obtained the promises."} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["根據所謂的《殉道者勞倫斯行傳》記載，士兵希坡律陀是在該殉道者被囚期間負責看守的軍官；他在獄中由勞倫斯為其施洗，並在聖勞倫斯死後兩日被處死。據該行傳所載，當眾人得知希坡律陀曾協助以合宜的尊榮安葬這位殉道者時，他便被控行為有失帝國軍官的身分。於是，他遭到傳喚，並在領聖餐時被逮捕。此後，照前述行傳所言，他被一根長繩拴在一對野馬身上；人們以鞭子、刺棒和喧鬧聲驚嚇馬匹，驅使牠們狂奔。馬匹就這樣將他猛烈地拖進樹林，穿過灌木與荊棘，越過坑洞與岩石，直到他的身體被撕成碎片，他英勇的靈魂遂歸向上帝。忠信者流著淚跟隨在後，收集他被撕裂的血肉與肢體，甚至用亞麻布片吸取他的鮮血，為要以敬虔之禮安葬他的遺骸。", "《聖勞倫斯行傳》中的某些故事，並未被學界接納為真實的歷史；然而，當中所述關於希坡律陀的遭遇，不過是早期殉道者所面臨的眾多酷刑之一。這正是不信的世界在當時加諸基督追隨者身上的苦難；每當不信的勢力占了上風，這便是忠信者可預期的命運。並且，在相同的情境下，忠信者也必同樣對那些為基督光榮赴死之人的遺骸心懷敬畏與尊崇。", "今日也紀念意大利伊莫拉的卡西安，他是四世紀初的一位殉道者。據傳他曾是一名教師；因著基督徒的身分，他被剝去衣服、雙手反綁在背後，交給他那些信奉異教的學生處置。這些學生用他們的鐵筆將他刺傷、撕裂，直至死亡。由於男孩們及其武器的力量微弱，他所受的折磨極為殘酷且漫長，而他那得勝的棕櫚枝也因此越發榮耀。"]} | （原檔沒有此欄位） |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪，諸聖在上帝那裡有無與倫比的賞賜；※他們為基督而死，而在光榮之中永遠生活。", "zh-hans": "看哪，诸圣在上帝那里有无与伦比的赏赐；※他们为基督而死，而在光荣之中永远生活。", "en": "Behold, the reward of the Saints ※ is plentiful with God; in truth, they died for Christ; in glory, they shall live for ever."}, {"zh-hant": "如金子在爐中被鍛煉，※主也如此試驗祂所揀選的人；祂永遠悅納他們，如同悅納燔祭。", "zh-hans": "如金子在炉中被锻炼，※主也如此试验祂所拣选的人；祂永远悦纳他们，如同悦纳燔祭。", "en": "As gold in the furnace, ※ so doth the Lord try his Elect; and as a burnt-offering, he hath accepted them for ever."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "義人的靈魂※在上帝手中，而痛苦斷不能侵害他們。", "zh-hans": "义人的灵魂※在上帝手中，而痛苦断不能侵害他们。", "en": "The souls of the righteous ※ are in the hand of God, and there shall no torment touch them."} |

### sanctorale_0814_jeremy_taylor.json

- 通用：`common_confessor_bishop_outside_easter`（一位精修者通用（復活期外）主教.json）。
- 移除並繼承：`evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`evening.benedictus_antiphon`。
- 保留原先缺失／停用狀態：`morning.invitatory.text`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "我要把他好比一個聰明人，※把房子蓋在磐石上。" | {"zh-hant": "主的精修者聖（某某），※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。", "zh-hans": "主的精修者圣（某某），※藉着你神圣的代祷坚固我们众人，使我们这些人被罪恶重担压垮之人，因你已得享真福荣耀而昂首挺身，并追随你的芳踪，至终赢得永恒的赏赐."} |
| `vigil.bible_sentences.0.reference` | "（便西拉智訓 39:5）" | {"zh-hant": "（便西拉智訓 44:16）", "zh-hans": "（便西拉智训 44:16）"} |
| `vigil.bible_sentences.0.text` | "有福之人清早起來專心致志，歸向那位創造他的主；他在至高者之前祈求，並張開他的嘴巴禱告，為自己的罪過而祈求。" | {"zh-hant": "看，大司祭，他在世之時蒙上帝悅納，又被認為是齊全正義之人。當烈怒的時候，他成為得救的人。", "zh-hans": "看，大司祭，他在世之时蒙上帝悦纳，又被认为是齐全正义之人。当烈怒的时候，他成为得救的人."} |
| `vigil.office_hymn.verses.0` | "一、昔有宣信士，曾蒙上帝嘉納，\n四方眾士民，虔敬肅然稱頌；\n今朝受封賞，榮登天府高衙，\n永享主榮華。" | {"zh-hant": "一、基督彰威嚴，眾牧元首治者；\n主教當稱頌，德澤流芳永世；\n攜誓趨聖殿，虔獻心香主前；\n仁愛永長存！", "zh-hans": "一、基督彰威严，众牧元首治者；\n主教当称颂，德泽流芳永世；\n携誓趋圣殿，虔献心香主前；\n仁爱永长存！"} |
| `vigil.office_hymn.verses.1` | "二、敬畏而警醒，忠貞清正端莊，\n聖潔且謙卑，世人共稱其德；\n雖歿其塵軀，靈召永恆之生，\n蒙入主天庭。" | {"zh-hant": "二、秉謙登牧座，不恃名唯承光；\n主賜威權重，戰兢持守聖德；\n克己潔身行，恩雨沛臨群羊；\n憐憫澤萬方！", "zh-hans": "二、秉谦登牧座，不恃名唯承光；\n主赐威权重，战兢持守圣德；\n克己洁身行，恩雨沛临群羊；\n怜悯泽万方！"} |
| `vigil.office_hymn.verses.2` | "三、聖澤長流溢，溥濟疲憊乏困，\n賢能有慈懷，仁德沛然昭顯；\n凡負軛抱疾，無論何等重擔，\n悉獲主康安。" | {"zh-hant": "三、為父與牧者，傾身家惠澤長；\n萬民立聖範，德輝照耀八荒；\n甘作眾人僕，仁風雨潤塵疆；\n信德作津梁！", "zh-hans": "三、为父与牧者，倾身家惠泽长；\n万民立圣范，德辉照耀八荒；\n甘作众人仆，仁风雨润尘疆；\n信德作津梁！"} |
| `vigil.office_hymn.verses.3` | "四、我眾合讚頌，歸與上帝尊榮，\n欣然高舉歌，敬獻聖名欽崇；\n願今生來世，同作天上良朋，\n共沐主宏恩。" | {"zh-hant": "四、伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。", "zh-hans": "四、伏祈祷声恒，助忠僕越沧浪；\n赐登天国境，颂圣三于云阙；\n父子与圣灵，赞上帝永不歇；\n圣三永称扬！阿们。"} |
| `vigil.office_hymn.verses.4` | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0` | "主啊，※你交給我五千。請看，我又賺了五千。" | {"zh-hant": "看，大祭司，※他在世之時蒙上帝喜悅，又被認為是齊全正義之人。哈利路亞。", "zh-hans": "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.1` | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！" | {"zh-hant": "他遵守至高者的法律，※沒有人比得上他。哈利路亞。", "zh-hans": "他遵守至高者的法律，※没有人比得上他。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.2` | "他是※那忠心又精明的僕人，主人派他管理自己的家。" | {"zh-hant": "因此，※上帝起誓許使他的苗裔在萬民之中興旺。哈利路亞。", "zh-hans": "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.3` | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。" | {"zh-hant": "上帝的眾祭司阿，※你們要讚頌主；主的僕人阿，請謳歌頌讚我們的上帝。哈利路亞。", "zh-hans": "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.4` | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！" | {"zh-hant": "善良忠信的僕人，※進入你主人的福樂吧！哈利路亞。", "zh-hans": "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人走入正路，將上帝的國指示給他，賜予他神聖事物的知識，使他在辛勞之中得榮耀，並增加他辛苦勞成果。", "zh-hans": "主引导义人走入正路，将上帝的国指示给他，赐予他神圣事物的知识，使他在辛劳之中得荣耀，并增加他辛苦劳成果。", "en": "The Lord guided the righteous man in right paths, and showed him the Kingdom of God; bestowed on him the knowledge of holy things, made him honourable in his travails, and increased the fruit of his labours."}, {"zh-hant": "你這又良善又忠心的僕人，※可以進來享受你主人的快樂。", "zh-hans": "你这又良善又忠心的仆人，※可以进来享受你主人的快乐。", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `morning.benedictus_antiphon.normal` | "好，你這又善良又忠心的僕人，※你在少許的事上忠心，我要派你管理許多的事，進來享受你主人的快樂吧！" | {"zh-hant": "主揀選了他，※祝聖了他，為他施於憐憫，使他在主眼中得蒙恩寵。", "zh-hans": "主拣选了他，※祝圣了他，为他施于怜悯，使他在主眼中得蒙恩宠."} |
| `morning.bible_sentences.0.reference` | "（啟示錄 7:15）" | {"zh-hant": "（以斯拉補編下卷 2:45）", "zh-hans": "（以斯拉补编下卷 2:45）"} |
| `morning.bible_sentences.0.text` | "他們在上帝寶座前，晝夜在他殿中事奉他；那坐在寶座上的要用帳幕覆庇他們。" | {"zh-hant": "我在上帝面前，並在將來審判活人死人的基督耶穌面前，憑着他的顯現和他的國度鄭重地勸戒你：務要傳道；無論得時不得時總要專心，並以百般的忍耐和各樣的教導責備人，警戒人，勸勉人。", "zh-hans": "我在上帝面前，并在将来审判活人死人的基督耶耶稣面前，凭着他的显现和他的国度郑重地劝戒你：务要传道；无论得时不得时总要专心，并以百般的忍耐和各样的教导责备人，警戒人，劝勉人."} |
| `morning.invitatory.text` | （原檔沒有此欄位） | {"zh-hant": "主是精修者的君王，※我們當來俯伏敬拜。", "zh-hans": "主是精修者的君王，※我们当来俯伏敬拜."} |
| `morning.invitatory.texts` | ["義人栽種在主的殿前，發旺在我們上帝院裏，※讓我們在他的聖日歡欣慶賀。", "主是精修者的君王，※我們當來俯伏敬拜。"] | （原檔沒有此欄位） |
| `morning.invitatory_hymn.title` | "Iste Confessor" | "Christe, pastorum Caput atque Princeps" |
| `morning.invitatory_hymn.verses.0` | "一、昔有宣信士，曾蒙上帝嘉納，\n四方眾士民，虔敬肅然稱頌；\n今朝受封賞，榮登天府高衙，\n永享主榮華。" | {"zh-hant": "一、基督彰威嚴，眾牧元首治者；\n主教當稱頌，德澤流芳永世；\n攜誓趨聖殿，虔獻心香主前；\n仁愛永長存！", "zh-hans": "一、基督彰威严，众牧元首治者；\n主教当称颂，德泽流芳永世；\n携誓趋圣殿，虔献心香主前；\n仁爱永长存！"} |
| `morning.invitatory_hymn.verses.1` | "二、敬畏而警醒，忠貞清正端莊，\n聖潔且謙卑，世人共稱其德；\n雖歿其塵軀，靈召永恆之生，\n蒙入主天庭。" | {"zh-hant": "二、秉謙登牧座，不恃名唯承光；\n主賜威權重，戰兢持守聖德；\n克己潔身行，恩雨沛臨群羊；\n憐憫澤萬方！", "zh-hans": "二、秉谦登牧座，不恃名唯承光；\n主赐威权重，战兢持守圣德；\n克己洁身行，恩雨沛临群羊；\n怜悯泽万方！"} |
| `morning.invitatory_hymn.verses.2` | "三、聖澤長流溢，溥濟疲憊乏困，\n賢能有慈懷，仁德沛然昭顯；\n凡負軛抱疾，無論何等重擔，\n悉獲主康安。" | {"zh-hant": "三、為父與牧者，傾身家惠澤長；\n萬民立聖範，德輝照耀八荒；\n甘作眾人僕，仁風雨潤塵疆；\n信德作津梁！", "zh-hans": "三、为父与牧者，倾身家惠泽长；\n万民立圣范，德辉照耀八荒；\n甘作众人仆，仁风雨润尘疆；\n信德作津梁！"} |
| `morning.invitatory_hymn.verses.3` | "四、我眾合讚頌，歸與上帝尊榮，\n欣然高舉歌，敬獻聖名欽崇；\n願今生來世，同作天上良朋，\n共沐主宏恩。" | {"zh-hant": "四、 伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。", "zh-hans": "四、 伏祈祷声恒，助忠僕越沧浪；\n赐登天国境，颂圣三于云阙；\n父子与圣灵，赞上帝永不歇；\n圣三永称扬！阿们。"} |
| `morning.invitatory_hymn.verses.4` | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。" | （原檔沒有此欄位） |
| `morning.office_hymn.title` | "Iesu, corona celsior" | "Jesu, sacerdotum decus" |
| `morning.office_hymn.verses.0` | "一、耶穌基督天府冠冕，\n永恆至高真理上主；\n嘉納主之精修聖者，\n偕同諸聖永享榮華。" | {"zh-hant": "一、耶穌主僕榮冕喜樂，\n慈目垂顧主的子民，\n今值聖者榮升天鄉，\n光耀冠冕永沐聖恩。", "zh-hans": "一、耶稣主僕荣冕喜乐，\n慈目垂顾主的子民，\n今值圣者荣升天乡，\n光耀冠冕永沐圣恩."} |
| `morning.office_hymn.verses.1` | "二、俯聽我眾卑微懇求，\n藉其代禱蒙主庇護；\n滌除我等諸般罪愆，\n悉數斬斷罪惡桎梏。" | {"zh-hant": "二、愛主為證主恩為憑，\n自禰聖殿領受使命；\n守護照顧主贖羊群，\n父托於主彼竭其誠。", "zh-hans": "二、爱主为证主恩为凭，\n自祢圣殿领受使命；\n守护照顾主赎羊群，\n父托于主彼竭其诚."} |
| `morning.office_hymn.verses.2` | "三、歲月周環時光流轉，\n榮耀佳節今朝重臨；\n主之忠僕脫離塵軀，\n榮登高天覲見主面。" | {"zh-hant": "三、驅散凶獸斥退豺狼，\n詭計雖狡盡皆洞穿；\n護衛群羊願承危險，\n捨命爭戰忠勇無雙。", "zh-hans": "三、驱散凶兽斥退豺狼，\n诡计虽狡尽皆洞穿；\n护卫群羊愿承危险，\n舍命争战忠勇无双."} |
| `morning.office_hymn.verses.3` | "四、視此塵世虛妄歡樂，\n浮華名利皆如塵土；\n鄙棄諸般世俗污穢，\n終獲天府凱旋奇樂。" | {"zh-hant": "四、每逢獻上無血聖祭，\n救恩聖筵價值無極；\n羊群置於祭壇之上，\n自己也為活獻祭上。", "zh-hans": "四、每逢献上无血圣祭，\n救恩圣筵价值无极；\n羊群置于祭坛之上，\n自己也为活献祭上."} |
| `morning.office_hymn.verses.4` | "五、恆常宣認主為君王，\n仰賴基督宏恩大德；\n狂傲仇敵踐踏足下，\n奮勇擊退眾魔魑魅。" | {"zh-hant": "五、唯願榮耀讚頌尊威，\n歸於至高祭司耶穌，\n歸於聖父保惠聖靈，\n三一上帝永受讚頌。阿們。", "zh-hans": "五、唯愿荣耀赞颂尊威，\n归于至高祭司耶稣，\n归于圣父保惠圣灵，\n三一上帝永受赞颂。阿们。"} |
| `morning.office_hymn.verses.5` | "六、信德昭彰美名遠播，\n堅定恆常宣信其主；\n嚴守齋戒克己修身，\n終獲高天靈糧滋養。" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.6` | "七、洪恩廣被慈悲上主，\n俯首叩拜至尊天顏；\n念此忠僕宣信之功，\n懇求塗抹我眾罪債。" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.7` | "八、榮耀全歸上帝聖父，\n並其獨生至聖聖言；\n偕同至聖唯一聖靈，\n掌管萬有永世無窮。阿們。" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader` | "主引導義人走入正路，" | {"zh-hant": "義人必如百合花開放，", "zh-hans": "义人必如百合花开放."} |
| `morning.office_hymn.versicle.people` | "將上帝的國指示給他。" | {"zh-hant": "永遠繁榮在主面前。", "zh-hans": "永远繁荣在主面前."} |
| `morning.psalm_antiphons.antiphons.0` | "主啊，※你交給我五千。請看，我又賺了五千。" | {"zh-hant": "看，大祭司，※他在世之時蒙上帝喜悅，又被認為是齊全正義之人。哈利路亞。", "zh-hans": "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.1` | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！" | {"zh-hant": "他遵守至高者的法律，※沒有人比得上他。哈利路亞。", "zh-hans": "他遵守至高者的法律，※没有人比得上他。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.2` | "他是※那忠心又精明的僕人，主人派他管理自己的家。" | {"zh-hant": "因此，※上帝起誓許使他的苗裔在萬民之中興旺。哈利路亞。", "zh-hans": "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.3` | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。" | {"zh-hant": "上帝的眾祭司阿，※你們要讚頌主；主的僕人阿，請謳歌頌讚我們的上帝。哈利路亞。", "zh-hans": "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.4` | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！" | {"zh-hant": "善良忠信的僕人，※進入你主人的福樂吧！哈利路亞。", "zh-hans": "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "願那愛你名的人都靠你歡欣。※因為你必賜福與義人；主啊，你必用恩惠如同盾牌四面護衛他。", "zh-hans": "愿那爱你名的人都靠你欢欣。※因为你必赐福与义人；主啊，你必用恩惠如同盾牌四面护卫他。", "en": "Let all rejoice ※ who hope in thee, O Lord; since thou hast blessed the righteous man, and with the shield of thy good will hast crowned him."}, {"zh-hant": "在遵守至高者的法律上，※沒有人可與他對立。", "zh-hans": "在遵守至高者的法律上，※没有人可与他对立。", "en": "There was none found ※ like unto him, who kept the law of the Most High."}] |
| `evening.bible_sentences.0.reference` | "（啟示錄 7:17）" | {"zh-hant": "（便西拉智訓 45:15）", "zh-hans": "（便西拉智训 45:15）"} |
| `evening.bible_sentences.0.text` | "寶座中的羔羊必牧養他們，領他們到生命水的泉源；上帝必擦去他們一切的眼淚。" | {"zh-hant": "主與他立永遠的盟約，賜予他大祭司的職分，以榮耀祝聖他，使他盡祭司職分，使他名得榮耀，並向他供獻火祭、燒香和馨香祭。", "zh-hans": "主与他立永远的盟约，赐予他大祭司的职分，以荣耀祝圣他，使他尽祭司职分，使他名得荣耀，并向他供献火祭、烧香和馨香祭."} |
| `evening.office_hymn.verses.0` | "一、求救世主耶穌垂聽，\n聖人榮冕即將臨近。\n現以溫柔愛心接納，\n我們獻上祈禱讚美。" | {"zh-hant": "一、耶穌主僕榮冕喜樂，\n慈目垂顧主的子民，\n今值聖者榮升天鄉，\n光耀冠冕永沐聖恩。", "zh-hans": "一、耶稣主僕荣冕喜乐，\n慈目垂顾主的子民，\n今值圣者荣升天乡，\n光耀冠冕永沐圣恩."} |
| `evening.office_hymn.verses.1` | "二、這位謙卑精修聖人，\n今日獲得榮耀美名。\n忠信子民每年歡欣，\n莊嚴慶賀聖人節日。" | {"zh-hant": "二、愛主為證主恩為憑，\n自禰聖殿領受使命；\n守護照顧主贖羊群，\n父托於主彼竭其誠。", "zh-hans": "二、爱主为证主恩为凭，\n自祢圣殿领受使命；\n守护照顾主赎羊群，\n父托于主彼竭其诚."} |
| `evening.office_hymn.verses.2` | "三、他已拋棄世界虛榮，\n視為虛空轉瞬即逝。\n現已列入天使歌團，\n進入無窮喜樂之中。" | {"zh-hant": "三、驅散凶獸斥退豺狼，\n詭計雖狡盡皆洞穿；\n護衛群羊願承危險，\n捨命爭戰忠勇無雙。", "zh-hans": "三、驱散凶兽斥退豺狼，\n诡计虽狡尽皆洞穿；\n护卫群羊愿承危险，\n舍命争战忠勇无双."} |
| `evening.office_hymn.verses.3` | "四、懇求仁慈上帝賜恩，\n求使我們隨他芳蹤。\n藉著聖人祈禱之能，\n脫離一切罪惡污穢。" | {"zh-hant": "四、每逢獻上無血聖祭，\n救恩聖筵價值無極；\n羊群置於祭壇之上，\n自己也為活獻祭上。", "zh-hans": "四、每逢献上无血圣祭，\n救恩圣筵价值无极；\n羊群置于祭坛之上，\n自己也为活献祭上."} |
| `evening.office_hymn.verses.4` | "五、仁君基督永享尊荣，\n偕同天父同享榮耀；\n也歸於保惠師聖靈，\n三一上帝永世無盡。阿們。" | {"zh-hant": "五、唯願榮耀讚頌尊威，\n歸於至高祭司耶穌，\n歸於聖父保惠聖靈，\n三一上帝永受讚頌。阿們。", "zh-hans": "五、唯愿荣耀赞颂尊威，\n归于至高祭司耶稣，\n归于圣父保惠圣灵，\n三一上帝永受赞颂。阿们。"} |
| `evening.office_hymn.versicle.leader` | "義人的口談論智慧；" | {"zh-hant": "主愛了他，並裝扮了他。", "zh-hans": "主爱了他，并装扮了他."} |
| `evening.office_hymn.versicle.people` | "他的舌頭講說公平。" | {"zh-hant": "給他穿上榮耀的外衣。", "zh-hans": "给他穿上荣耀的外衣."} |
| `evening.psalm_antiphons.antiphons.0` | "主啊，※你交給我五千。請看，我又賺了五千。" | {"zh-hant": "看，大祭司，※他在世之時蒙上帝喜悅，又被認為是齊全正義之人。哈利路亞。", "zh-hans": "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.1` | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！" | {"zh-hant": "他遵守至高者的法律，※沒有人比得上他。哈利路亞。", "zh-hans": "他遵守至高者的法律，※没有人比得上他。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.2` | "他是※那忠心又精明的僕人，主人派他管理自己的家。" | {"zh-hant": "因此，※上帝起誓許使他的苗裔在萬民之中興旺。哈利路亞。", "zh-hans": "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.3` | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。" | {"zh-hant": "上帝的眾祭司阿，※你們要讚頌主；主的僕人阿，請謳歌頌讚我們的上帝。哈利路亞。", "zh-hans": "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.4` | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！" | {"zh-hant": "善良忠信的僕人，※進入你主人的福樂吧！哈利路亞。", "zh-hans": "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪！這是大祭司，※他在世之時取悅了上帝，被看為完全，是個義人。", "zh-hans": "看哪！这是大祭司，※他在世之时取悦了上帝，被看为完全，是个义人。", "en": "Behold a great Priest, ※ who in his days pleased God, and was found righteous."}, {"zh-hant": "這是那忠心有見識的管家，主人派他管理家裡的人。", "zh-hans": "这是那忠心有见识的管家，主人派他管理家里的人。", "en": "A wise and faithful steward, whom the Lord made ruler over his household."}] |

### sanctorale_0816_joachim.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `morning.bible_sentences`, `morning.invitatory`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | "我們要讚美這世代之中的偉人，※主與他建立了賜福萬國的盟約，使之落在他的頭上。" | {"zh-hant": "我要把他好比一個聰明人，※把房子蓋在磐石上。", "zh-hans": "我要把他好比一个聪明人，※把房子盖在磐石上."} |
| `vigil.lessons` | {"special": {"ot": {"book": "便西拉智訓", "chapter": "31:8-11"}, "nt": {"book": "路加福音", "chapter": "12:42-44"}}} | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.leader` | "他們的子孫在世上必強盛。" | {"zh-hant": "主愛了他，並裝扮了他。", "zh-hans": "主爱了他，并装扮了他."} |
| `vigil.office_hymn.versicle.people` | "正直人的後裔，必定蒙福。" | {"zh-hant": "給他穿上榮耀的外衣。", "zh-hans": "给他穿上荣耀的外衣."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `vigil.psalms` | {"special": {"items": [{"number": "1"}, {"number": "2"}, {"number": "3"}]}} | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal` | "我們要讚美這世代之中的偉人，※主與他建立了賜福萬國的盟約，使之落在他的頭上。" | {"zh-hant": "好，你這又善良又忠心的僕人，※你在少許的事上忠心，我要派你管理許多的事，進來享受你主人的快樂吧！", "zh-hans": "好，你这又善良又忠心的仆人，※你在少许的事上忠心，我要派你管理许多的事，进来享受你主人的快乐吧！"} |
| `morning.biography` | {"title": "《讚美童貞女講道》", "source": "節選自聖伊皮法紐斯主教的一篇講道", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["耶西的根生出了大衛王，神聖的童貞女便屬於他的支派。我稱她為神聖，因她實在是神聖的，也是聖民的女兒。她的父親和母親是約雅敬與安娜；他們以蒙上帝喜悅的方式度過一生，也同樣生下了一位後裔，就是這位神聖的童貞女馬利亞；她成為了上帝之母，也成了祂的聖殿。約雅敬、安娜與馬利亞這三個名字的真正含義，似乎表明了他們將自己獻上，為要歸於三一上帝的榮耀。「約雅敬」一名，按其釋義，是「主的建立」；主的聖殿，即童貞女，便由他而建立。「安娜」一名意為「恩典」；她和約雅敬確實得了恩典，因為上帝應允了他們的祈禱，使他們生下如此的一位後裔，生出了神聖的童貞女。按傳統所說，為此約雅敬曾在山上禱告，安娜則在她的園中禱告。而「馬利亞」一名在希伯來文中通常被理解為「夫人」；這便指向她作為我們的主和夫子之母的身分。", {"type": "source", "text": "節選自大馬士革的聖約翰的講道《論童貞馬利亞》第一篇"}, "既然有一天，上帝的童貞母親注定要由安娜而生，自然界便不敢搶在這位恩典之子以先，而是等候那時刻來到，使恩典本身生出自己的孩子。因此，她理當以首生者的身分來到世上，因為她將要生下那在一切被造的以先的首生者，就是萬物藉以受造的那一位。約雅敬與安娜啊，你們是有福的夫婦！一切受造之物都虧欠你們。因為藉著你們，受造界把最崇高的禮物獻給了造物主：就是那位貞潔的母親；唯有她被算為配得承載造物主。", "約雅敬啊，歡喜吧！因為由你的女兒，有一嬰孩為我們而生；祂的名要稱為「大謀略的使者」，也就是全世界救恩的使者。讓聶斯脫利羞愧，並用手掩口吧。她的孩子是上帝；那麼，祂的母親怎能不是上帝之母呢？凡不承認神聖上帝之母的，便是遠離上帝。這話雖在其他意義上可說是我的，卻不是憑我自己的權威而說；因為我從神學家教父聖格里高利那裏，承受了這最敬虔的遺產。約雅敬與安娜啊，你們是有福的夫婦！基督曾在一處說：「憑着他們的果子就可以認出他們來。」而你們正是藉著你們貞潔腰間所出的果實為人所認識。為使由你們所生的那一位在上帝眼中配得稱許、蒙祂喜悅，你們管束了自己的天然情感，使之不致失序。因此，你們在貞潔與神聖地履行父母職分之時，便生出了那一位——她正是童貞的寶庫。"]} | （原檔沒有此欄位） |
| `morning.lessons` | {"special": {"ot": {"book": "便西拉智訓", "chapter": "32:14-16"}, "nt": {"book": "馬太福音", "chapter": "25:31-36"}}} | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader` | "他們的子孫在世上必強盛。" | {"zh-hant": "主引導義人走入正路，", "zh-hans": "主引导义人走入正路."} |
| `morning.office_hymn.versicle.people` | "正直人的後裔，必定蒙福。" | {"zh-hant": "將上帝的國指示給他。", "zh-hans": "将上帝的国指示给他."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `morning.psalms` | {"special": {"items": [{"number": "4"}, {"number": "5"}, {"number": "8"}]}} | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal` | "我們要讚美這世代之中的偉人，※主與他建立了賜福萬國的盟約，使之落在他的頭上。" | {"zh-hant": "這是一位在上帝之前行大事之人，※他的教導充滿全地；願他為眾人的罪過代求。", "zh-hans": "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求."} |
| `evening.lessons` | {"special": {"ot": {"book": "便西拉智訓", "chapter": "34:13-17"}, "nt": {"book": "約翰福音", "chapter": "13:12-17"}}} | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader` | "他們的子孫在世上必強盛。" | {"zh-hant": "義人的口談論智慧；", "zh-hans": "义人的口谈论智慧."} |
| `evening.office_hymn.versicle.people` | "正直人的後裔，必定蒙福。" | {"zh-hant": "他的舌頭講說公平。", "zh-hans": "他的舌头讲说公平."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `evening.psalms` | {"special": {"items": [{"number": "15"}, {"number": "21"}, {"number": "24"}]}} | （原檔沒有此欄位） |

### sanctorale_0818_helena.json

- 通用：`common_holy_woman_outside_easter`（一位聖婦用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |
| `morning.biography` | {"title": "《論狄奧多西之逝世》", "source": "取自聖安波羅修主教的講道。", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["聖海倫納前往聖地朝聖。因為聖靈感動她，去尋找十字真木。因此她來到各各他，心裏如此自言自語：「看哪，這是戰場！勝利的記號在哪裏？我尋找救恩的旌旗，卻找不着。她說：難道我坐在寶座上，而主的十字架卻埋在塵土中嗎？難道我身處君王的宮殿，而基督的凱旋卻埋沒在廢墟中嗎？它必定隱藏在那裏；因此，在這地方必有永生的棕櫚枝隱藏着。若救贖本身的憑據尚不可見，我怎能自認已得救贖呢？撒但啊，我看見你所作的事了：你把那把殺死你的劍藏了起來。然而，以撒重新挖掘他父親亞伯拉罕在世時所挖的水井，因為非利士人在亞伯拉罕死後把它們塞住了；以撒照着他父親所叫的名字，叫這些井的名字。以撒的僕人在谷中挖掘，在那裏挖得一口活水井。 因此，應當把廢墟清除，使生命的杖得以顯現。當把那砍下真正歌利亞頭顱的劍從鞘中拔出；當把大地打開，使救恩閃耀出來。撒但啊，你豈不是把那樹藏起來，只是為了再次被征服嗎？」", "「是馬利亞征服了你！就是那位生下得勝者的馬利亞！她永遠保持童貞，卻生下了那位將藉着被釘十字架征服你、藉着死亡粉碎你的主！而你今日也將被征服，好讓一位婦人識破你的詭計。馬利亞在聖潔中承載了主；我也要尋找祂的十字架！她在祂降生時懷抱祂；如今祂既已從死人中復活，我也要承載祂！她使上帝顯現在人中間；我則要從這些廢墟中舉起祂的旌旗，為醫治罪人。」於是海倫納掘開地面，除去塵土；她發現三個十字架堆放一處，是仇敵所隱藏、廢墟所掩埋的。然而，基督的凱旋不能被遮蔽。她雖只是一介婦女，一時不知所措；但聖靈啟發她，使她能作出一場毫無疑問的搜尋。", "然後，她尋找那將主釘在十字架上的釘子，並且找到了。她吩咐人用一根釘子製成馬的嚼環，又將另一根釘子打造成冠冕；她用其中一件作為裝飾，將另一件作為敬虔的聖物。馬利亞蒙眷顧，是為使夏娃得釋放；海倫納蒙眷顧，是為救贖眾君王。她把鑲嵌著寶石的冠冕送給她的兒子君士坦丁；她（在上帝眼中如寶石般珍貴）將更寶貴的聖釘之鐵與之結合，並在上面立着十字架的記號——上帝藉此救贖了人類。她也把馬的嚼環送給了他。君士坦丁使用了這兩件物品，並把自己的信仰傳給了後繼的君王。正如撒迦利亞書十四章二十節的希臘文譯本所說：「到那日，馬的嚼環上必有『歸主為聖』的字樣」；事情就這樣成就了。因此，在海倫納的那個時代，信主君王的開端，正藉着這歸主為聖的馬嚼環而顯明；自他開始了信仰的時代，迫害止息，敬虔取而代之。海倫納把十字架置於君王的頭頂之上，實在作得明智，好使人能在君王身上敬拜基督的十字架。向救贖的神聖記號屈身，並非新奇之事，而是敬虔的舉動。因此，上帝就是這統御普世的羅馬帝國之釘，並裝飾着君王的額頭；使那些曾經的迫害者，如今能成為傳道者。"]} | （原檔沒有此欄位） |
| `morning.invitatory.text` | "在聖海倫娜的隆重慶節中，※我們當來俯伏敬拜上帝。" | {"zh-hant": "在聖（某某）的隆重慶節中，※我們當來俯伏敬拜上帝。", "zh-hans": "在圣（某某）的隆重庆节中，※我们当来俯伏敬拜上帝."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |

### sanctorale_0820_bernard.json

- 通用：`common_confessor_doctor_outside_easter`（一位精修者通用（復活期外）教會聖師.json）。
- 移除並繼承：`evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon` | {"normal": "我要把他好比一個聰明人，※把房子蓋在磐石上。"} | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.reference` | "（便西拉智訓 39:5）" | {"zh-hant": "（便西拉智訓 44:16）", "zh-hans": "（便西拉智训 44:16）"} |
| `vigil.bible_sentences.0.text` | "有福之人清早起來專心致志，歸向那位創造他的主；他在至高者之前祈求，並張開他的嘴巴禱告，為自己的罪過而祈求。" | {"zh-hant": "看，大司祭，他在世之時蒙上帝悅納，又被認為是齊全正義之人。當烈怒的時候，他成為得救的人。", "zh-hans": "看，大司祭，他在世之时蒙上帝悦纳，又被认为是齐全正义之人。当烈怒的时候，他成为得救的人."} |
| `vigil.office_hymn.verses.0` | "一、昔有宣信士，曾蒙上帝嘉納，\n四方眾士民，虔敬肅然稱頌；\n今朝受封賞，榮登天府高衙，\n永享主榮華。" | {"zh-hant": "一、基督彰威嚴，眾牧元首治者；\n主教當稱頌，德澤流芳永世；\n攜誓趨聖殿，虔獻心香主前；\n仁愛永長存！", "zh-hans": "一、基督彰威严，众牧元首治者；\n主教当称颂，德泽流芳永世；\n携誓趋圣殿，虔献心香主前；\n仁爱永长存！"} |
| `vigil.office_hymn.verses.1` | "二、敬畏而警醒，忠貞清正端莊，\n聖潔且謙卑，世人共稱其德；\n雖歿其塵軀，靈召永恆之生，\n蒙入主天庭。" | {"zh-hant": "二、秉謙登牧座，不恃名唯承光；\n主賜威權重，戰兢持守聖德；\n克己潔身行，恩雨沛臨群羊；\n憐憫澤萬方！", "zh-hans": "二、秉谦登牧座，不恃名唯承光；\n主赐威权重，战兢持守圣德；\n克己洁身行，恩雨沛临群羊；\n怜悯泽万方！"} |
| `vigil.office_hymn.verses.2` | "三、聖澤長流溢，溥濟疲憊乏困，\n賢能有慈懷，仁德沛然昭顯；\n凡負軛抱疾，無論何等重擔，\n悉獲主康安。" | {"zh-hant": "三、為父與牧者，傾身家惠澤長；\n萬民立聖範，德輝照耀八荒；\n甘作眾人僕，仁風雨潤塵疆；\n信德作津梁！", "zh-hans": "三、为父与牧者，倾身家惠泽长；\n万民立圣范，德辉照耀八荒；\n甘作众人仆，仁风雨润尘疆；\n信德作津梁！"} |
| `vigil.office_hymn.verses.3` | "四、我眾合讚頌，歸與上帝尊榮，\n欣然高舉歌，敬獻聖名欽崇；\n願今生來世，同作天上良朋，\n共沐主宏恩。" | {"zh-hant": "四、伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。", "zh-hans": "四、伏祈祷声恒，助忠僕越沧浪；\n赐登天国境，颂圣三于云阙；\n父子与圣灵，赞上帝永不歇；\n圣三永称扬！阿们。"} |
| `vigil.office_hymn.verses.4` | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0` | "主啊，※你交給我五千。請看，我又賺了五千。" | {"zh-hant": "看，大祭司，※他在世之時蒙上帝喜悅，又被認為是齊全正義之人。哈利路亞。", "zh-hans": "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.1` | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！" | {"zh-hant": "他遵守至高者的法律，※沒有人比得上他。哈利路亞。", "zh-hans": "他遵守至高者的法律，※没有人比得上他。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.2` | "他是※那忠心又精明的僕人，主人派他管理自己的家。" | {"zh-hant": "因此，※上帝起誓許使他的苗裔在萬民之中興旺。哈利路亞。", "zh-hans": "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.3` | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。" | {"zh-hant": "上帝的眾祭司阿，※你們要讚頌主；主的僕人阿，請謳歌頌讚我們的上帝。哈利路亞。", "zh-hans": "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚."} |
| `vigil.psalm_antiphons.antiphons.4` | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！" | {"zh-hant": "善良忠信的僕人，※進入你主人的福樂吧！哈利路亞。", "zh-hans": "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚."} |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人走入正路，將上帝的國指示給他，賜予他神聖事物的知識，使他在辛勞之中得榮耀，並增加他辛苦勞成果。", "zh-hans": "主引导义人走入正路，将上帝的国指示给他，赐予他神圣事物的知识，使他在辛劳之中得荣耀，并增加他辛苦劳成果。", "en": "The Lord guided the righteous man in right paths, and showed him the Kingdom of God; bestowed on him the knowledge of holy things, made him honourable in his travails, and increased the fruit of his labours."}, {"zh-hant": "你這又良善又忠心的僕人，※可以進來享受你主人的快樂。", "zh-hans": "你这又良善又忠心的仆人，※可以进来享受你主人的快乐。", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `morning.benedictus_antiphon.normal` | "好，你這又善良又忠心的僕人，※你在少許的事上忠心，我要派你管理許多的事，進來享受你主人的快樂吧！" | {"zh-hant": "主揀選了他，※祝聖了他，為他施於憐憫，使他在主眼中得蒙恩寵。", "zh-hans": "主拣选了他，※祝圣了他，为他施于怜悯，使他在主眼中得蒙恩宠."} |
| `morning.bible_sentences.0.reference` | "（啟示錄 7:15）" | {"zh-hant": "（以斯拉補編下卷 2:45）", "zh-hans": "（以斯拉补编下卷 2:45）"} |
| `morning.bible_sentences.0.text` | "他們在上帝寶座前，晝夜在他殿中事奉他；那坐在寶座上的要用帳幕覆庇他們。" | {"zh-hant": "我在上帝面前，並在將來審判活人死人的基督耶穌面前，憑着他的顯現和他的國度鄭重地勸戒你：務要傳道；無論得時不得時總要專心，並以百般的忍耐和各樣的教導責備人，警戒人，勸勉人。", "zh-hans": "我在上帝面前，并在将来审判活人死人的基督耶耶稣面前，凭着他的显现和他的国度郑重地劝戒你：务要传道；无论得时不得时总要专心，并以百般的忍耐和各样的教导责备人，警戒人，劝勉人."} |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["伯納德約於1091年出生於勃艮第第戎附近的楓丹城堡。出生時，母親便將他奉獻給上帝，正如她對其他六名子女所作的一樣。由於她給予兒女的神聖培育，她有時被稱為「聖徒之母」：因為她的六個兒子以及丈夫不僅都成為了修士，女兒也成為了修女；並且他們所有人都與她自己一樣，在聖潔的馨香中離世。她眾子中最有恩賜的便是伯納德，他長大後儀表迷人，言辭極具說服力，無人能抗拒。由於他容貌異常俊美，許多女子對他趨之若鶩；然而，沒有甚麼能使他偏離守貞的決心。母親去世後，他於二十二歲時決意逃避像他這般年輕貴族所面臨的種種誘惑，進入熙篤修道院；熙篤會便是由此發源。當他的這個決定傳開後，他的兄弟們竭力想要改變他的心意；但他反倒發揮了更出色的口才，成功地說服了他們。於是一件史無前例的事發生了：他使四位已達適齡的兄弟，以及許多親族，共三十人，都與自己抱持了同一心志；他們全都與他一同加入了熙篤會。後來，甚至連他的父親和最年幼的弟弟也加入了。據說，無論他走到哪裏，母親們便把兒子藏起來，妻子們便把丈夫藏起來，唯恐他感動他們作出像他一般的犧牲；因為當時的貴族與士兵為了騎士精神，將自己的生命看得很輕，並且不認為像如今的人那樣，為了獻身於上帝而作出類似的犧牲是件怪事。", "在伯納德及其同伴到來前約十五年，英國人聖司提反·哈定已經建立了熙篤修道院；但該修道院已有多年未曾接收初學生。他對本篤會生活的改革極其嚴厲，包括永久禁食肉類，以及幾乎不間斷的靜默。今日人們最熟知的，便是由此衍生出的特拉普會修士團體。因此，伯納德於1112年的到來，標誌着該修會大幅成長、並傳播至世界各地的開端。伯納德被派往建立克萊沃修道院，他又從該修道院建立了其他幾所修道院，包括英格蘭的噴泉修道院。他常說：「我們的先輩將修道院建在不宜居住之處，為的是讓修士們能將生命的無常擺在眼前。」然而，如同噴泉修道院所建的沼澤地一般，修士們的勤勉很快便將這些地方轉變為健康而豐饒的園地；他們親手勞作，藉此維生。伯納德從未做過粗重勞動，起初對此毫不擅長；直到他懇求上帝賜下恩典，使他能勝任這類工作，不久他便學會了與最出色的匠人媲美。但在這類勞作中，他的心靈始終專注於上帝；後來他常將自己在神聖學問上的進步，歸功於他在戶外時對聖經的不斷默想。他是如此全神貫注於上帝，以致從未留意過自己所住房間的模樣。他禁食極深，甚至失去了所有味覺。就這樣，藉着祈禱與肉身的克苦，他成為了約束自己的主人，並完全被上帝的愛所點燃。", "他拒絕了熱那亞、米蘭及其他幾個地方的主教職。然而，他的才幹如此出眾，以致各國王侯與教宗們——尤其是教宗因諾森二世——經常借重他的服事來執行許多重要任務，例如調解交戰雙方，以及推行教會改革。特別是在1147年，教宗命令他為十字軍東征講道；他在招募志願者方面取得了巨大的成功，但這次十字軍最終以災難告終。伯納德悲痛地將此失敗歸咎於那些未能遵行十字架道路的十字軍士兵的罪惡。他的偉大工作如此卓越，以致有人如此評價他：「他將整個十二世紀扛在了自己的肩上，但這並非沒有伴隨着苦難。」他於 1153 年 8 月 20 日在主裏安睡，享壽六十三歲；並於1174年獲封聖。他創作了許多聖詩、禱文及其他著作；正如人們論及他的講道時所說，這些文字如此令人喜悅並溫暖心靈，彷彿乳與蜜從他的舌頭流入了他的言語之中。為此，他被稱為「流蜜博士」（The Mellifluous Doctor）。在1830年，他被正式宣告為教會聖師。"]} | （原檔沒有此欄位） |
| `morning.invitatory` | {"texts": ["義人栽種在主的殿前，發旺在我們上帝院裏，※讓我們在他的聖日歡欣慶賀。", "主是精修者的君王，※我們當來俯伏敬拜。"]} | （原檔沒有此欄位） |
| `morning.invitatory_hymn.title` | "Iste Confessor" | "Christe, pastorum Caput atque Princeps" |
| `morning.invitatory_hymn.verses.0` | "一、昔有宣信士，曾蒙上帝嘉納，\n四方眾士民，虔敬肅然稱頌；\n今朝受封賞，榮登天府高衙，\n永享主榮華。" | {"zh-hant": "一、基督彰威嚴，眾牧元首治者；\n主教當稱頌，德澤流芳永世；\n攜誓趨聖殿，虔獻心香主前；\n仁愛永長存！", "zh-hans": "一、基督彰威严，众牧元首治者；\n主教当称颂，德泽流芳永世；\n携誓趋圣殿，虔献心香主前；\n仁爱永长存！"} |
| `morning.invitatory_hymn.verses.1` | "二、敬畏而警醒，忠貞清正端莊，\n聖潔且謙卑，世人共稱其德；\n雖歿其塵軀，靈召永恆之生，\n蒙入主天庭。" | {"zh-hant": "二、秉謙登牧座，不恃名唯承光；\n主賜威權重，戰兢持守聖德；\n克己潔身行，恩雨沛臨群羊；\n憐憫澤萬方！", "zh-hans": "二、秉谦登牧座，不恃名唯承光；\n主赐威权重，战兢持守圣德；\n克己洁身行，恩雨沛临群羊；\n怜悯泽万方！"} |
| `morning.invitatory_hymn.verses.2` | "三、聖澤長流溢，溥濟疲憊乏困，\n賢能有慈懷，仁德沛然昭顯；\n凡負軛抱疾，無論何等重擔，\n悉獲主康安。" | {"zh-hant": "三、為父與牧者，傾身家惠澤長；\n萬民立聖範，德輝照耀八荒；\n甘作眾人僕，仁風雨潤塵疆；\n信德作津梁！", "zh-hans": "三、为父与牧者，倾身家惠泽长；\n万民立圣范，德辉照耀八荒；\n甘作众人仆，仁风雨润尘疆；\n信德作津梁！"} |
| `morning.invitatory_hymn.verses.3` | "四、我眾合讚頌，歸與上帝尊榮，\n欣然高舉歌，敬獻聖名欽崇；\n願今生來世，同作天上良朋，\n共沐主宏恩。" | {"zh-hant": "四、伏祈禱聲恆，助忠僕越滄浪；\n賜登天國境，頌聖三於雲闕；\n父子與聖靈，讚上帝永不歇；\n聖三永稱揚！阿們。", "zh-hans": "四、伏祈祷声恒，助忠僕越沧浪；\n赐登天国境，颂圣三于云阙；\n父子与圣灵，赞上帝永不歇；\n圣三永称扬！阿们。"} |
| `morning.invitatory_hymn.verses.4` | "五、尊榮並權能，救恩榮耀齊弘，\n全歸至高君，永在至尊天宮；\n恆常且無限，掌管萬有無窮，\n三一真上主。阿們。" | （原檔沒有此欄位） |
| `morning.office_hymn.title` | "Iesu, corona celsior" | "O luce qui mortalibus" |
| `morning.office_hymn.verses.0` | "一、耶穌基督天府冠冕，\n永恆至高真理上主；\n嘉納主之精修聖者，\n偕同諸聖永享榮華。" | {"zh-hant": "一、上帝燃明燈，何其輝耀光明！\n你為地上鹽，聖味至潔純清；\n護人免腐朽，靈魂永葆潔貞，\n使人得永生。", "zh-hans": "一、上帝燃明灯，何其辉耀光明！\n你为地上盐，圣味至洁纯清；\n护人免腐朽，灵魂永葆洁贞，\n使人得永生."} |
| `morning.office_hymn.verses.1` | "二、俯聽我眾卑微懇求，\n藉其代禱蒙主庇護；\n滌除我等諸般罪愆，\n悉數斬斷罪惡桎梏。" | {"zh-hant": "二、因你真理存，謬誤永不侵凌；\n因你信德貞，童貞無玷堅凝；\n因主啓寶藏，智慧豐盈傾注，\n智慧顯於今。", "zh-hans": "二、因你真理存，谬误永不侵凌；\n因你信德贞，童贞无玷坚凝；\n因主启宝藏，智慧丰盈倾注，\n智慧显于今."} |
| `morning.office_hymn.verses.2` | "三、歲月周環時光流轉，\n榮耀佳節今朝重臨；\n主之忠僕脫離塵軀，\n榮登高天覲見主面。" | {"zh-hant": "三、聖泉湧活水，清澈潤澤無垠，\n潤基督田地，結實累累豐登；\n為乳汁育嬰，為壯者備真糧，\n萬民得飽饗。", "zh-hans": "三、圣泉涌活水，清澈润泽无垠，\n润基督田地，结实累累丰登；\n为乳汁育婴，为壮者备真粮，\n万民得饱飨."} |
| `morning.office_hymn.verses.3` | "四、視此塵世虛妄歡樂，\n浮華名利皆如塵土；\n鄙棄諸般世俗污穢，\n終獲天府凱旋奇樂。" | {"zh-hant": "四、永恆真理主，我眾因主歡欣！\n肉身耳雖聞，未解聖言深恩，\n聖師言教中，啓迪靈性明心，\n聖靈耀吾靈。阿們。", "zh-hans": "四、永恒真理主，我众因主欢欣！\n肉身耳虽闻，未解圣言深恩，\n圣师言教中，启迪灵性明心，\n圣灵耀吾灵。阿们。"} |
| `morning.office_hymn.verses.4` | "五、恆常宣認主為君王，\n仰賴基督宏恩大德；\n狂傲仇敵踐踏足下，\n奮勇擊退眾魔魑魅。" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.5` | "六、信德昭彰美名遠播，\n堅定恆常宣信其主；\n嚴守齋戒克己修身，\n終獲高天靈糧滋養。" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.6` | "七、洪恩廣被慈悲上主，\n俯首叩拜至尊天顏；\n念此忠僕宣信之功，\n懇求塗抹我眾罪債。" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.7` | "八、榮耀全歸上帝聖父，\n並其獨生至聖聖言；\n偕同至聖唯一聖靈，\n掌管萬有永世無窮。阿們。" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader` | "主引導義人走入正路，" | {"zh-hant": "我已陳明主的信實和救恩；", "zh-hans": "我已陈明主的信实和救恩；"} |
| `morning.office_hymn.versicle.people` | "將上帝的國指示給他。" | {"zh-hant": "我未曾隱瞞主的慈愛和信實。", "zh-hans": "我未曾隐瞒主的慈爱和信实."} |
| `morning.psalm_antiphons.antiphons.0` | "主啊，※你交給我五千。請看，我又賺了五千。" | {"zh-hant": "看，大祭司，※他在世之時蒙上帝喜悅，又被認為是齊全正義之人。哈利路亞。", "zh-hans": "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.1` | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！" | {"zh-hant": "他遵守至高者的法律，※沒有人比得上他。哈利路亞。", "zh-hans": "他遵守至高者的法律，※没有人比得上他。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.2` | "他是※那忠心又精明的僕人，主人派他管理自己的家。" | {"zh-hant": "因此，※上帝起誓許使他的苗裔在萬民之中興旺。哈利路亞。", "zh-hans": "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.3` | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。" | {"zh-hant": "上帝的眾祭司阿，※你們要讚頌主；主的僕人阿，請謳歌頌讚我們的上帝。哈利路亞。", "zh-hans": "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚."} |
| `morning.psalm_antiphons.antiphons.4` | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！" | {"zh-hant": "善良忠信的僕人，※進入你主人的福樂吧！哈利路亞。", "zh-hans": "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "願那愛你名的人都靠你歡欣。※因為你必賜福與義人；主啊，你必用恩惠如同盾牌四面護衛他。", "zh-hans": "愿那爱你名的人都靠你欢欣。※因为你必赐福与义人；主啊，你必用恩惠如同盾牌四面护卫他。", "en": "Let all rejoice ※ who hope in thee, O Lord; since thou hast blessed the righteous man, and with the shield of thy good will hast crowned him."}, {"zh-hant": "在遵守至高者的法律上，※沒有人可與他對立。", "zh-hans": "在遵守至高者的法律上，※没有人可与他对立。", "en": "There was none found ※ like unto him, who kept the law of the Most High."}] |
| `evening.bible_sentences.0.reference` | "（啟示錄 7:17）" | {"zh-hant": "（便西拉智訓 45:15）", "zh-hans": "（便西拉智训 45:15）"} |
| `evening.bible_sentences.0.text` | "寶座中的羔羊必牧養他們，領他們到生命水的泉源；上帝必擦去他們一切的眼淚。" | {"zh-hant": "主與他立永遠的盟約，賜予他大祭司的職分，以榮耀祝聖他，使他盡祭司職分，使他名得榮耀，並向他供獻火祭、燒香和馨香祭。", "zh-hans": "主与他立永远的盟约，赐予他大祭司的职分，以荣耀祝圣他，使他尽祭司职分，使他名得荣耀，并向他供献火祭、烧香和馨香祭."} |
| `evening.office_hymn.title` | "Jesu, sacerdotum decus" | "O luce qui mortalibus" |
| `evening.office_hymn.verses.0` | "一、求救世主耶穌垂聽，\n聖人榮冕即將臨近。\n現以溫柔愛心接納，\n我們獻上祈禱讚美。" | {"zh-hant": "一、上帝燃明燈，何其輝耀光明！\n你為地上鹽，聖味至潔純清；\n護人免腐朽，靈魂永葆潔貞，\n使人得永生。", "zh-hans": "一、上帝燃明灯，何其辉耀光明！\n你为地上盐，圣味至洁纯清；\n护人免腐朽，灵魂永葆洁贞，\n使人得永生."} |
| `evening.office_hymn.verses.1` | "二、這位謙卑精修聖人，\n今日獲得榮耀美名。\n忠信子民每年歡欣，\n莊嚴慶賀聖人節日。" | {"zh-hant": "二、因你真理存，謬誤永不侵凌；\n因你信德貞，童貞無玷堅凝；\n因主啓寶藏，智慧豐盈傾注，\n智慧顯於今。", "zh-hans": "二、因你真理存，谬误永不侵凌；\n因你信德贞，童贞无玷坚凝；\n因主启宝藏，智慧丰盈倾注，\n智慧显于今."} |
| `evening.office_hymn.verses.2` | "三、他已拋棄世界虛榮，\n視為虛空轉瞬即逝。\n現已列入天使歌團，\n進入無窮喜樂之中。" | {"zh-hant": "三、聖泉湧活水，清澈潤澤無垠，\n潤基督田地，結實累累豐登；\n為乳汁育嬰，為壯者備真糧，\n萬民得飽饗。", "zh-hans": "三、圣泉涌活水，清澈润泽无垠，\n润基督田地，结实累累丰登；\n为乳汁育婴，为壮者备真粮，\n万民得饱飨."} |
| `evening.office_hymn.verses.3` | "四、懇求仁慈上帝賜恩，\n求使我們隨他芳蹤。\n藉著聖人祈禱之能，\n脫離一切罪惡污穢。" | {"zh-hant": "四、永恆真理主，我眾因主歡欣！\n肉身耳雖聞，未解聖言深恩，\n聖師言教中，啓迪靈性明心，\n聖靈耀吾靈。阿們。", "zh-hans": "四、永恒真理主，我众因主欢欣！\n肉身耳虽闻，未解圣言深恩，\n圣师言教中，启迪灵性明心，\n圣灵耀吾灵。阿们。"} |
| `evening.office_hymn.verses.4` | "五、仁君基督永享尊荣，\n偕同天父同享榮耀；\n也歸於保惠師聖靈，\n三一上帝永世無盡。阿們。" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader` | "義人的口談論智慧；" | {"zh-hant": "主愛了他，並裝扮了他。", "zh-hans": "主爱了他，并装扮了他."} |
| `evening.office_hymn.versicle.people` | "他的舌頭講說公平。" | {"zh-hant": "給他穿上榮耀的外衣。", "zh-hans": "给他穿上荣耀的外衣."} |
| `evening.psalm_antiphons.antiphons.0` | "主啊，※你交給我五千。請看，我又賺了五千。" | {"zh-hant": "看，大祭司，※他在世之時蒙上帝喜悅，又被認為是齊全正義之人。哈利路亞。", "zh-hans": "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.1` | "好，※你這又善良又忠心的僕人，你在少許的事上忠心，進來享受你主人的快樂吧！" | {"zh-hant": "他遵守至高者的法律，※沒有人比得上他。哈利路亞。", "zh-hans": "他遵守至高者的法律，※没有人比得上他。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.2` | "他是※那忠心又精明的僕人，主人派他管理自己的家。" | {"zh-hant": "因此，※上帝起誓許使他的苗裔在萬民之中興旺。哈利路亞。", "zh-hans": "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.3` | "主人※來了，他來叩門，看見僕人警醒，那些僕人就有福了。" | {"zh-hant": "上帝的眾祭司阿，※你們要讚頌主；主的僕人阿，請謳歌頌讚我們的上帝。哈利路亞。", "zh-hans": "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚."} |
| `evening.psalm_antiphons.antiphons.4` | "你這※又善良又忠心的僕人，進來享受你主人的快樂吧！" | {"zh-hant": "善良忠信的僕人，※進入你主人的福樂吧！哈利路亞。", "zh-hans": "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚."} |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪！這是大祭司，※他在世之時取悅了上帝，被看為完全，是個義人。", "zh-hans": "看哪！这是大祭司，※他在世之时取悦了上帝，被看为完全，是个义人。", "en": "Behold a great Priest, ※ who in his days pleased God, and was found righteous."}, {"zh-hant": "這是那忠心有見識的管家，主人派他管理家裡的人。", "zh-hans": "这是那忠心有见识的管家，主人派他管理家里的人。", "en": "A wise and faithful steward, whom the Lord made ruler over his household."}] |

### sanctorale_0821_jane_frances_de_chantal.json

- 通用：`common_holy_woman_outside_easter`（一位聖婦用（復活期外）.json）。
- 移除並繼承：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 繁體相同，改為繼承通用翻譯：`vigil.bible_sentences`, `vigil.psalm_antiphons.antiphons`, `vigil.office_hymn`, `vigil.benedictus_antiphon`, `morning.bible_sentences`, `morning.invitatory_hymn`, `morning.psalm_antiphons.antiphons`, `morning.office_hymn`, `morning.benedictus_antiphon`, `evening.bible_sentences`, `evening.psalm_antiphons.antiphons`, `evening.office_hymn`, `evening.benedictus_antiphon`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |
| `morning.biography` | {"title": "聖人小傳", "source": "", "rubric": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "paragraphs": ["簡·法蘭西斯於1572年出生於勃艮第第戎的弗雷米奧貴族家庭，二十歲時嫁給了尚塔爾男爵。由於加爾文派異端已嚴重侵染勃艮第，簡的父親確保子女們接受了徹底的大公教會培育；她由此獲得了忠於上帝的心志，這成為她一生的印記。父親將她許配給尚塔爾男爵之後，她努力在妻子的一切職責與美德上追求卓越，並學會了妥善管理他的家庭。她對丈夫極其忠貞，以致丈夫不在時，她從不穿著與其世俗身分相稱的華服，說：「我所願取悅的眼睛，並不在此。」她確保自己的兒女、僕人，以及一切在她權柄之下的人，都接受純正信仰的教導。她藉著豐厚的賙濟減輕窮人的苦難；凡奉基督之名向她求食的，從未被拒絕。1601年，她的丈夫在狩獵時意外身亡；她在悲痛中，渴慕走上一條更卓越的道路，便立誓不再結婚。她以順服的心承受了喪夫之痛，並徹底克服了對那位誤開致命一槍之紳士的恐懼與反感；為了表明自己不歸咎於他，她甚至擔任了他幼子的代母。", "為保障兒女的家族產業，她如今不得不住進公公家中。她的公公生活放蕩，又深受一名邪惡傲慢的女管家所控制。簡和她的子女都不受他們歡迎，反而受盡殘酷的侮辱。她忍受了七年，直到她的善良勝過了老人的暴躁脾氣與女僕的惡意。她曾收到一些既符合利益又體面的再婚提議，但她從未被勸動去接受其中任何一項。為堅定自己持守寡居的心意，她重申了此一誓言，並用燒紅的烙鐵在胸前烙下耶穌的名字。她的愛心日益寬廣；飢餓者、被遺棄者，甚至患有令人作嘔之疾病的人，都被帶到她跟前。她不僅收留、安慰並護理他們，還親自清洗並縫補他們污穢破爛的衣物。除了操持家務之外，她將所有的時間都用於祈禱、閱讀有助於增進敬虔的書籍，以及服侍不幸的人。然而，在她守寡的初期，她的屬靈導師未能理解她的靈魂及其召命；但在聖法蘭西斯·德·沙雷士接手指導她之後，一名僕人說道：「從前夫人每天被要求祈禱三次時，她是每個人的麻煩；如今她被要求不住地祈禱，反而不再是任何人的麻煩了。」", "當她的四個子女長大，不再需要她時刻照料時，她從上帝那裏得知自己蒙召進入修道生活。為此，她說服了年邁的父親和公公，以及身為布爾日大主教的兄弟；他們最終都同意了法蘭西斯·德·沙雷士的看法：若她再婚並因此離開家庭，沒有人會覺得奇怪。於是，在1610年，她懷著堅定的決心，身無分文地離開了家，在安錫創立了聖馬利亞訪親修女會——當然，這期間經歷了許多反對與苦難。這項創立為修道史標誌了一個新的開端：該修女會的宗旨，是向那些既沒有足夠體力、也不受當時修會普遍採行的肉身苦行所吸引，卻能勇敢接受屬靈與內在克己的婦女，提供修道生活。她終其一生，都極其完美地遵守了法蘭西斯·德·沙雷士為這修會制定的會規。透過她，訪親會修女遍布各地；她不斷以言語、榜樣，以及充滿神聖烈火的著作，激勵她們追求更大的完全。1641年12月13日，在她七十歲那年，她離開此世，永遠與主同在。她逝於穆蘭，但其遺體後來被遷至安錫，安葬於訪親修女會教堂內、聖法蘭西斯·德·沙雷士的墓旁。1767年，她被封聖，其慶日被定於 8月21日。"]} | （原檔沒有此欄位） |
| `morning.invitatory.text` | "在聖簡·法蘭西斯的隆重慶節中，※我們當來俯伏敬拜上帝。" | {"zh-hant": "在聖（某某）的隆重慶節中，※我們當來俯伏敬拜上帝。", "zh-hans": "在圣（某某）的隆重庆节中，※我们当来俯伏敬拜上帝."} |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "zh-hans": "你的名如同倒出來的香膏，※所以童女們甚愛你。", "en": "Thy name is as ointment ※ poured forth; therefore do the virgins love thee exceedingly."}, {"zh-hant": "來，※我所揀選的，我要在你內設立我的寶座。因為王已羨慕你的美貌。", "zh-hans": "来，※我所拣选的，我要在你内设立我的宝座。因為王已羨慕你的美貌。", "en": "Come, ※ my chosen One, and I will place my throne in thee, for the King hath desired thy beauty."}] |

### sanctorale_0825_louis.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`morning.benedictus_antiphon`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal.zh-hans` | "我要把他好比一个聪明人，※把房子盖在磐石上。" | "我要把他好比一个聪明人，※把房子盖在磐石上." |
| `vigil.bible_sentences.0.text.zh-hans` | "有福之人清早起來专心致志，归向那位创造他的主；他在至高者之前祈求，并张开他的嘴巴祷告，为自己的罪过而祈求。" | "有福之人清早起来专心致志，归向那位创造他的主；他在至高者之前祈求，并张开他的嘴巴祷告，为自己的罪过而祈求." |
| `vigil.office_hymn.verses.0.zh-hans` | "一、昔有宣信士，曾蒙上帝嘉纳，\n四方众士民，虔敬肃然称颂；\n今朝受封赏，荣登天府高衙，\n永享主荣华。" | "一、昔有宣信士，曾蒙上帝嘉纳，\n四方众士民，虔敬肃然称颂；\n今朝受封赏，荣登天府高衙，\n永享主荣华." |
| `vigil.office_hymn.verses.1.zh-hans` | "二、敬畏而警醒，忠贞清正端庄，\n圣洁且谦卑，世人共称其德；\n虽殁其尘躯，灵召永恒之生，\n蒙入主天庭。" | "二、敬畏而警醒，忠贞清正端庄，\n圣洁且谦卑，世人共称其德；\n虽殁其尘躯，灵召永恒之生，\n蒙入主天庭." |
| `vigil.office_hymn.verses.2.zh-hans` | "三、圣泽长流溢，溥济疲惫乏困，\n贤能有慈怀，仁德沛然昭显；\n凡负轭抱疾，无论何等重担，\n悉获主康安。" | "三、圣泽长流溢，溥济疲惫乏困，\n贤能有慈怀，仁德沛然昭显；\n凡负轭抱疾，无论何等重担，\n悉获主康安." |
| `vigil.office_hymn.verses.3.zh-hans` | "四、我众合赞颂，归与上帝尊荣，\n欣然高举歌，敬献圣名钦崇；\n愿今生来世，同作天上良朋，\n共沐主宏恩。" | "四、我众合赞颂，归与上帝尊荣，\n欣然高举歌，敬献圣名钦崇；\n愿今生来世，同作天上良朋，\n共沐主宏恩." |
| `vigil.office_hymn.versicle.leader.zh-hans` | "主爱了他，并装扮了他。" | "主爱了他，并装扮了他." |
| `vigil.office_hymn.versicle.people.zh-hans` | "给他穿上荣耀的外衣。" | "给他穿上荣耀的外衣." |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主愛了他，※並裝扮了他，給他穿上華麗的外衣，在樂園的門口給他戴上冠冕。", "zh-hans": "主爱了他，※并装扮了他，给他穿上华丽的外衣，在乐园的门口给他戴上冠冕。", "en": "The Lord loved him and adorned him, ※ he clothed him with a robe of glory, and at the gates of Paradise he crowned him."}, {"zh-hant": "一位忠心又精明的管家，※主派他管理他的家。", "zh-hans": "一位忠心又精明的管家，※主派他管理他的家。", "en": "A wise and faithful steward, ※ whom the Lord made ruler over his household."}] |
| `morning.bible_sentences.0.text.zh-hans` | "他们在上帝宝座前，昼夜在他殿中事奉他；那坐在宝座上的要用帐幕覆庇他们。" | "他们在上帝宝座前，昼夜在他殿中事奉他；那坐在宝座上的要用帐幕覆庇他们." |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传"}, "source": "", "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。"}, "paragraphs": [{"zh-hant": "法國的路易九世，是世上曾經在位的君王中最尊貴的一位。因為他兼具卓越的心志與高尚的勇氣，以及嚴謹的生活紀律、對上帝的熱忱，與對人類需要的慷慨關懷。他於 1215 年出生，在母親白蘭琪的敬虔照料下長大。父親去世時，他年僅十一歲，遂加冕為王；十九歲時，他迎娶了普羅旺斯的瑪格麗特，她為他生下了五個兒子和六個女兒。他在位第二十年的時候，決意嘗試從穆罕默德教徒手中解救耶路撒冷。起初，他擊潰了撒拉森人；但後來，當大批士兵死於疾病後，他自己也被擊敗並淪為俘虜，因而被迫與他們簽訂停戰協議。", "zh-hans": "法国的路易九世，是世上曾经在位的君王中最尊贵的一位。因为他兼具卓越的心志与高尚的勇气，以及严谨的生活纪律、对上帝的热忱，与对人类需要的慷慨关怀。他于 1215 年出生，在母亲白兰琪的敬虔照料下长大。父亲去世时，他年仅十一岁，遂加冕为王；十九岁时，他迎娶了普罗旺斯的玛格丽特，她为他生下了五个儿子和六个女儿。他在位第二十年的时候，决意尝试从穆罕默德教徒手中解救耶路撒冷。起初，他击溃了撒拉森人；但后来，当大批士兵死于疾病后，他自己也被击败并沦为俘虏，因而被迫与他们签订停战协议。"}, {"zh-hant": "他獲釋後，在東方停留了五年；在此期間，他朝訪了聖地，並贖回大批淪為奴隸的基督徒。他帶走了三百名被穆罕默德教徒弄瞎的基督徒，並在法國為他們設立了終身照護之所；這是史上有紀錄以來的首個盲人機構。他又建立了許多其他慈善機構和修道院。他協助自己的聽告解神父羅貝爾·德·索邦，在巴黎創立神學學院；為紀念這位創始人，該院便被稱為「索邦學院」。他向來熱愛公義，並致力於整頓王室法庭，使法律得以妥善施行，以保障平民大眾的利益。他因著智慧和公平而聲名遠播；因此，在1258年，當英格蘭國王亨利三世與其諸男爵發生重大爭端時，他受邀擔任仲裁人。", "zh-hans": "他获释後，在东方停留了五年；在此期间，他朝访了圣地，并赎回大批沦为奴隶的基督徒。他带走了三百名被穆罕默德教徒弄瞎的基督徒，并在法国为他们设立了终身照护之所；这是史上有纪录以来的首个盲人机构。他又建立了许多其他慈善机构和修道院。他协助自己的听告解神父罗贝尔·德·索邦，在巴黎创立神学院；为纪念这位创始人，该院便被称为「索邦学院」。他向来热爱公义，并致力于整顿王室法庭，使法律得以妥善施行，以保障平民大众的利益。他因着智慧和公平而声名远播；因此，在1258年，当英格兰国王亨利三世与其诸男爵发生重大争端时，他受邀担任仲裁人。"}, {"zh-hant": "1270年，他再次渡海，與撒拉森人交戰。但抵達東方不久，他便染上瘟疫而逝世，臨終時說著：「我必進入你的居所；我必向你的聖殿下拜。」在那粗暴殘酷的時代，他以公義和憐憫施政；在他身上，偉大君王與聖徒的特質完美地結合為一。雖然他的兩次十字軍東征皆告失敗，他仍躋身於最英勇的君王與戰士之列。儘管他一直渴望看見基督的信仰在普世，尤其是在聖地本身掌權；但當他明白上帝的旨意是讓他在這個目標上失敗時，他便在順服神聖旨意中得著了安慰。他的遺骸被恭敬地送回法國，安奉於聖但尼修道院；1297年，他獲封聖。", "zh-hans": "1270年，他再次渡海，与撒拉森人交战。但抵达东方不久，他便染上瘟疫而逝世，临终时说着：「我必进入你的居所；我必向你的圣殿下拜。」在那粗暴残酷的时代，他以公义和怜悯施政；在他身上，伟大君王与圣徒的特质完美地结合为一。虽然他的两次十字军东征皆告失败，他仍跻身于最英勇的君王与战士之列。尽管他一直渴望看见基督的信仰在普世，尤其是在圣地本身掌权；但当他明白上帝的旨意是让他在这个目标上失败时，他便在顺服神圣旨意中得着了安慰。他的遗骸被恭敬地送回法国，安奉于圣但尼修道院；1297年，他获封圣。"}]} | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.zh-hans` | "义人栽种在主的殿前，发旺在我们上帝院里，※让我们在他的圣日欢欣庆贺。" | "义人栽种在主的殿前，发旺在我们上帝院里，※让我们在他的圣日欢欣庆贺." |
| `morning.invitatory.texts.1.zh-hans` | "主是精修者的君王，※我们当来俯伏敬拜。" | "主是精修者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory_hymn.verses.0.zh-hans` | "一、昔有宣信士，曾蒙上帝嘉纳，\n四方众士民，虔敬肃然称颂；\n今朝受封赏，荣登天府高衙，\n永享主荣华。" | "一、昔有宣信士，曾蒙上帝嘉纳，\n四方众士民，虔敬肃然称颂；\n今朝受封赏，荣登天府高衙，\n永享主荣华." |
| `morning.invitatory_hymn.verses.1.zh-hans` | "二、敬畏而警醒，忠贞清正端庄，\n圣洁且谦卑，世人共称其德；\n虽殁其尘躯，灵召永恒之生，\n蒙入主天庭。" | "二、敬畏而警醒，忠贞清正端庄，\n圣洁且谦卑，世人共称其德；\n虽殁其尘躯，灵召永恒之生，\n蒙入主天庭." |
| `morning.invitatory_hymn.verses.2.zh-hans` | "三、圣泽长流溢，溥济疲惫乏困，\n贤能有慈怀，仁德沛然昭显；\n凡负轭抱疾，无论何等重担，\n悉获主康安。" | "三、圣泽长流溢，溥济疲惫乏困，\n贤能有慈怀，仁德沛然昭显；\n凡负轭抱疾，无论何等重担，\n悉获主康安." |
| `morning.invitatory_hymn.verses.3.zh-hans` | "四、我众合赞颂，归与上帝尊荣，\n欣然高举歌，敬献圣名钦崇；\n愿今生来世，同作天上良朋，\n共沐主宏恩。" | "四、我众合赞颂，归与上帝尊荣，\n欣然高举歌，敬献圣名钦崇；\n愿今生来世，同作天上良朋，\n共沐主宏恩." |
| `morning.office_hymn.verses.0.zh-hans` | "一、耶稣基督天府冠冕，\n永恒至高真理上主；\n嘉纳主之精修圣者，\n偕同诸圣永享荣华。" | "一、耶稣基督天府冠冕，\n永恒至高真理上主；\n嘉纳主之精修圣者，\n偕同诸圣永享荣华." |
| `morning.office_hymn.verses.1.zh-hans` | "二、俯听我众卑微恳求，\n藉其代祷蒙主庇护；\n涤除我等诸般罪愆，\n悉数斩断罪恶桎梏。" | "二、俯听我众卑微恳求，\n藉其代祷蒙主庇护；\n涤除我等诸般罪愆，\n悉数斩断罪恶桎梏." |
| `morning.office_hymn.verses.2.zh-hans` | "三、岁月周环时光流转，\n荣耀佳节今朝重临；\n主之忠仆脱离尘躯，\n荣登高天觐见主面。" | "三、岁月周环时光流转，\n荣耀佳节今朝重临；\n主之忠仆脱离尘躯，\n荣登高天觐见主面." |
| `morning.office_hymn.verses.3.zh-hans` | "四、视此尘世虚妄欢乐，\n浮华名利皆如尘土；\n鄙弃诸般世俗污秽，\n终获天府凯旋奇乐。" | "四、视此尘世虚妄欢乐，\n浮华名利皆如尘土；\n鄙弃诸般世俗污秽，\n终获天府凯旋奇乐." |
| `morning.office_hymn.verses.4.zh-hans` | "五、恒常宣认主为君王，\n仰赖基督宏恩大德；\n狂傲仇敌践踏足下，\n奋勇击退众魔魑魅。" | "五、恒常宣认主为君王，\n仰赖基督宏恩大德；\n狂傲仇敌践踏足下，\n奋勇击退众魔魑魅." |
| `morning.office_hymn.verses.5.zh-hans` | "六、信德昭彰美名远播，\n坚定恒常宣信其主；\n严守斋戒克己修身，\n终获高天灵粮滋养。" | "六、信德昭彰美名远播，\n坚定恒常宣信其主；\n严守斋戒克己修身，\n终获高天灵粮滋养." |
| `morning.office_hymn.verses.6.zh-hans` | "七、洪恩广被慈悲上主，\n俯首叩拜至尊天颜；\n念此忠仆宣信之功，\n恳求涂抹我众罪债。" | "七、洪恩广被慈悲上主，\n俯首叩拜至尊天颜；\n念此忠仆宣信之功，\n恳求涂抹我众罪债." |
| `morning.office_hymn.versicle.leader.zh-hans` | "主引导义人走入正路，" | "主引导义人走入正路." |
| `morning.office_hymn.versicle.people.zh-hans` | "将上帝的国指示给他。" | "将上帝的国指示给他." |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "這樣的人必蒙主賜福，※救他的上帝也必叫他為義，這是尋求主的族類。", "zh-hans": "这样的人必蒙主赐福，※救他的上帝也必叫他为义，这是寻求主的族类。", "en": "He shall receive the blessing ※ from the Lord, and loving-kindness from the God of his salvation; this is the generation of them that seek the Lord."}, {"zh-hant": "主人來了，敲門的時候，看見僕人警醒，※那些僕人就有福了。", "zh-hans": "主人来了，敲门的时候，看见仆人警醒，※那些仆人就有福了。", "en": "Blessed is that servant, ※ whom the Lord when he cometh, and knocketh at the door, shall find watching."}] |
| `evening.benedictus_antiphon.normal.zh-hans` | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求。" | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求." |
| `evening.bible_sentences.0.text.zh-hans` | "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪。" | "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪." |
| `evening.office_hymn.verses.0.zh-hans` | "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美。" | "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美." |
| `evening.office_hymn.verses.1.zh-hans` | "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日。" | "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日." |
| `evening.office_hymn.verses.2.zh-hans` | "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中。" | "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中." |
| `evening.office_hymn.verses.3.zh-hans` | "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽。" | "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽." |
| `evening.office_hymn.versicle.leader.zh-hans` | "义人的口谈论智慧；" | "义人的口谈论智慧." |
| `evening.office_hymn.versicle.people.zh-hans` | "他的舌头讲说公平。" | "他的舌头讲说公平." |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人，※走入正路，將上帝的國指示給他。", "zh-hans": "主引导义人，※走入正路，将上帝的国指示给他。", "en": "The Lord guided the righteous, ※ in right paths, and showed him the Kingdom of God."}, {"zh-hant": "你這又善良又忠心的僕人，※進來享受你主人的快樂吧！", "zh-hans": "你这又善良又忠心的仆人，※进来享受你主人的快乐吧！", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |

### sanctorale_0828_augustine_of_hippo.json

- 通用：`common_confessor_doctor_outside_easter`（一位精修者通用（復活期外）教會聖師.json）。
- 移除並繼承：`morning.invitatory_hymn`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon` | {"normal": {"zh-hant": "主的精修者聖奧古斯丁，※藉著你神聖的代禱堅固我們眾人，使我們這些被罪惡重擔壓垮之人，因你已得享真福榮耀而昂首挺身，並追隨你的芳蹤，至終贏得永恆的賞賜。", "zh-hans": "主的精修者圣奥古斯丁，※藉着你神圣的代祷坚固我们众人，使我们这些人被罪恶重担压垮之人，因你已得享真福荣耀而昂首挺身，并追随你的芳踪，至终赢得永恒的赏赐。"}} | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.zh-hans` | "看，大司祭，他在世之时蒙上帝悦纳，又被认为是齐全正义之人。当烈怒的时候，他成为得救的人。" | "看，大司祭，他在世之时蒙上帝悦纳，又被认为是齐全正义之人。当烈怒的时候，他成为得救的人." |
| `vigil.office_hymn.versicle.leader.zh-hans` | "主爱了他，并装扮了他。" | "主爱了他，并装扮了他." |
| `vigil.office_hymn.versicle.people.zh-hans` | "给他穿上荣耀的外衣。" | "给他穿上荣耀的外衣." |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚。" | "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚." |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "他遵守至高者的法律，※没有人比得上他。哈利路亚。" | "他遵守至高者的法律，※没有人比得上他。哈利路亚." |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚。" | "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚." |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚。" | "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚." |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚。" | "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚." |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "主引導義人走入正路，將上帝的國指示給他，賜予他神聖事物的知識，使他在辛勞之中得榮耀，並增加他辛苦勞成果。", "zh-hans": "主引导义人走入正路，将上帝的国指示给他，赐予他神圣事物的知识，使他在辛劳之中得荣耀，并增加他辛苦劳成果。", "en": "The Lord guided the righteous man in right paths, and showed him the Kingdom of God; bestowed on him the knowledge of holy things, made him honourable in his travails, and increased the fruit of his labours."}, {"zh-hant": "你這又良善又忠心的僕人，※可以進來享受你主人的快樂。", "zh-hans": "你这又良善又忠心的仆人，※可以进来享受你主人的快乐。", "en": "Good and faithful servant, ※ enter thou into the joy of thy Lord."}] |
| `morning.benedictus_antiphon.normal.zh-hans` | "主拣选了他，※祝圣了他，为他施于怜悯，使他在主眼中得蒙恩宠。" | "主拣选了他，※祝圣了他，为他施于怜悯，使他在主眼中得蒙恩宠." |
| `morning.bible_sentences.0.text.zh-hans` | "我在上帝面前，并在将来审判活人死人的基督耶耶稣面前，凭着他的显现和他的国度郑重地劝戒你：务要传道；无论得时不得时总要专心，并以百般的忍耐和各样的教导责备人，警戒人，劝勉人。" | "我在上帝面前，并在将来审判活人死人的基督耶耶稣面前，凭着他的显现和他的国度郑重地劝戒你：务要传道；无论得时不得时总要专心，并以百般的忍耐和各样的教导责备人，警戒人，劝勉人." |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传"}, "source": "", "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。"}, "paragraphs": [{"zh-hant": "奧古斯丁出生於北非塔加斯特的一個體面家庭，於354年11月13日誕生。他的父親是異教徒，母親卻是基督徒，並使他在教會名冊上登記為慕道友。他年少時才智極其敏銳，在學問上遠勝所有同伴。然而，當他青年時期住在迦太基時，他開始以重大的罪惡玷污自己的靈魂，又受摩尼教異端迷惑心思。最後他離開非洲，前往羅馬，隨後被派往米蘭教授修辭學。多年來，他的母親聖莫妮卡一直為他的歸正祈禱；正是在米蘭，他成為了基督徒。因為他常去聽聖安波羅修主教的講道，藉著安波羅修的勞苦，他被吸引歸向大公教會；並在 387 年的聖週禮拜六，於三十三歲時由安波羅修為他施洗。在 388 年回到非洲後，希坡卓越的聖瓦勒流主教，見他兼備聖潔的生活與大公信仰的見證，便約於390年底按立他為司祭。當時，他建立了一個敬虔男子的團體；他們與他共同生活、共同祈禱，他並熱切地按著使徒生活與教導的模式來培育他們。由這些人的榜樣，以及他關於共同生活的教導，便產生了所謂的《聖奧古斯丁會規》，以及律修會士的生活。其後，摩尼教異端猛烈爆發；他便開始強力抨擊它，並駁倒了異端首領福圖納圖斯。", "zh-hans": "奥古斯丁出生于北非塔加斯特的一个体面家庭，于354年11月13日诞生。他的父亲是异教徒，母亲却是基督徒，并使他在教会名册上登记为慕道友。他年少时才智极其敏锐，在学问上远胜所有同伴。然而，当他青年时期住在迦太基时，他开始以重大的罪恶玷污自己的灵魂，又受摩尼教异端迷惑心思。最后他离开非洲，前往罗马，随后被派往米兰教授修辞学。多年来，他的母亲圣莫妮卡一直为他的归正祈祷；正是在米兰，他成为了基督徒。因为他常去听圣安波罗修主教的讲道，藉着安波罗修的劳苦，他被吸引归向大公教会；并在 387 年的圣周礼拜六，于三十三岁时由安波罗修为他施洗。在 388 年回到非洲后，希坡卓越的圣瓦勒流主教，见他兼备圣洁的生活与大公信仰的见证，便约于390年底按立他为司祭。当时，他建立了一个敬虔男子的团体；他们与他共同生活、共同祈祷，他并热切地按着使徒生活与教导的模式来培育他们。由这些人的榜样，以及他关于共同生活的教导，便产生了所谓的《圣奥古斯丁会规》，以及律修会士的生活。其后，摩尼教异端猛烈爆发；他便开始强力抨击它，并驳倒了异端首领福图纳图斯。"}, {"zh-hant": "瓦勒流深受奧古斯丁敬虔的熱忱所感動，於395年12月任命他為自己主教職務的助理；瓦勒流在翌年逝世後，奧古斯丁便繼任其位。他極其謙卑與貞潔。他的家具和衣著都很樸素，飲食也極為普通；他在餐桌上總是藉由閱讀某本宗教書籍，或談論宗教話題來調味。他對窮人極其慈憫，以致在缺乏所有其他資源時，他甚至打碎聖器來救濟他們的需要。他的規矩是不住在任何婦女附近，也不與她們建立過於親密的友誼；即使是他的姊妹與姪女，他也不放寬這條規矩。他常說，雖然與這等近親相處不會引發醜聞，但她們身邊前來尋求陪伴的女友卻可能引來非議。他從不停止宣講上帝的道，直到重病使他無能為力為止。他總是對異端窮追猛打，藉著他的言語與著作，從不容許他們在任何地方有安歇之處。在很大程度上，他清除了非洲的摩尼教徒、多納徒派、伯拉糾派，以及其他異端。", "zh-hans": "瓦勒流深受奥古斯丁敬虔的热忱所感动，于395年12月任命他为自己主教职务的助理；瓦勒流在翌年逝世后，奥古斯丁便继任其位。他极其谦卑与贞洁。他的家具和衣着都很朴素，饮食也极为普通；他在餐桌上总是藉由阅读某本宗教书籍，或谈论宗教话题来调味。他对穷人极其慈悯，以致在缺乏所有其他资源时，他甚至打碎圣器来救济他们的需要。他的规矩是不住在任何妇女附近，也不与她们建立过于亲密的友谊；即使是他的姊妹与姪女，他也不放宽这条规矩。他常说，虽然与这等近亲相处不会引发丑闻，但她们身边前来寻求陪伴的女友却可能引来非议。他从不停止宣讲上帝的道，直到重病使他无能为力为止。他总是对异端穷追猛打，藉着他的言语与著作，从不容许他们在任何地方有安歇之处。在很大程度上，他清除了非洲的摩尼教徒、多纳徒派、伯拉纠派，以及其他异端。"}, {"zh-hant": "他的著作極其豐富，並且充滿敬虔與悟性；在那些闡明基督信仰教義的人中，他當被列為最卓越的首領之一。他是後世神學家在方法與論證上所效法的先驅之一。汪達爾人蹂躪非洲、圍攻希坡大約第三個月時，他染上熱病。當他明白自己即將離開這今生的生命時，便命人把大衛的詩篇中最能表達悔罪之語的篇章放在他面前，流淚閱讀；因他常說，即使一個人的良心沒有指控他犯下任何罪，他也不該大膽地離開這個世界，除非是以悔罪者的身分。他的心智直到最後仍保持清醒有力；在那些他曾勸勉要愛慕敬虔及一切美善的弟兄面前，他沉浸於祈禱中，於430年8月28日離世升天。他享壽七十六歲，其中擔任主教將近三十六年。他的遺體起初被運往薩丁尼亞島，後來倫巴底國王柳特普蘭以重價購得，將其遷至提契諾，在那裏獲得了尊榮的安葬。他是最早被公認為教會聖師的人之一，因此與大格里高利、安波羅修和耶柔米並列為西方四大聖師。", "zh-hans": "他的著作极其丰富，并且充满敬虔与悟性；在那些阐明基督信仰教义的人中，他当被列为最卓越的首领之一。他是后世神学家在方法与论证上所效法的先驱之一。汪达尔人蹂躏非洲、围攻希坡大约第三个月时，他染上热病。当他明白自己即将离开这今生的生命时，便命人把大卫的诗篇中最能表达悔罪之语的篇章放在他面前，流泪阅读；因他常说，即使一个人的良心没有指控他犯下任何罪，他也不该大胆地离开这个世界，除非是以悔罪者的身分。他的心智直到最后仍保持清醒有力；在那些他曾劝勉要爱慕敬虔及一切美善的弟兄面前，他沉浸于祈祷中，于430年8月28日离世升天。他享寿七十六岁，其中担任主教将近三十六年。他的遗体起初被运往萨丁尼亚岛，后来伦巴底国王柳特普兰以重价购得，将其迁至提契诺，在那里获得了尊荣的安葬。他是最早被公认为教会圣师的人之一，因此与大格里高利、安波罗修和耶柔米并列为西方四大圣师。"}]} | （原檔沒有此欄位） |
| `morning.invitatory` | {"texts": [{"zh-hant": "主是精修者的君王，※我們當來俯伏敬拜。", "zh-hans": "主是精修者的君王，※我们当来俯伏敬拜。"}]} | （原檔沒有此欄位） |
| `morning.office_hymn.title` | "Jesu, sacerdotum decus" | "O luce qui mortalibus" |
| `morning.office_hymn.verses.0.zh-hans` | "一、耶稣主僕荣冕喜乐，\n慈目垂顾主的子民，\n今值圣者荣升天乡，\n光耀冠冕永沐圣恩。" | "一、上帝燃明灯，何其辉耀光明！\n你为地上盐，圣味至洁纯清；\n护人免腐朽，灵魂永葆洁贞，\n使人得永生." |
| `morning.office_hymn.verses.0.zh-hant` | "一、耶穌主僕榮冕喜樂，\n慈目垂顧主的子民，\n今值聖者榮升天鄉，\n光耀冠冕永沐聖恩。" | "一、上帝燃明燈，何其輝耀光明！\n你為地上鹽，聖味至潔純清；\n護人免腐朽，靈魂永葆潔貞，\n使人得永生。" |
| `morning.office_hymn.verses.1.zh-hans` | "二、爱主为证主恩为凭，\n自祢圣殿领受使命；\n守护照顾主赎羊群，\n父托于主彼竭其诚。" | "二、因你真理存，谬误永不侵凌；\n因你信德贞，童贞无玷坚凝；\n因主启宝藏，智慧丰盈倾注，\n智慧显于今." |
| `morning.office_hymn.verses.1.zh-hant` | "二、愛主為證主恩為憑，\n自禰聖殿領受使命；\n守護照顧主贖羊群，\n父托於主彼竭其誠。" | "二、因你真理存，謬誤永不侵凌；\n因你信德貞，童貞無玷堅凝；\n因主啓寶藏，智慧豐盈傾注，\n智慧顯於今。" |
| `morning.office_hymn.verses.2.zh-hans` | "三、驱散凶兽斥退豺狼，\n诡计虽狡尽皆洞穿；\n护卫群羊愿承危险，\n舍命争战忠勇无双。" | "三、圣泉涌活水，清澈润泽无垠，\n润基督田地，结实累累丰登；\n为乳汁育婴，为壮者备真粮，\n万民得饱飨." |
| `morning.office_hymn.verses.2.zh-hant` | "三、驅散凶獸斥退豺狼，\n詭計雖狡盡皆洞穿；\n護衛群羊願承危險，\n捨命爭戰忠勇無雙。" | "三、聖泉湧活水，清澈潤澤無垠，\n潤基督田地，結實累累豐登；\n為乳汁育嬰，為壯者備真糧，\n萬民得飽饗。" |
| `morning.office_hymn.verses.3.zh-hans` | "四、每逢献上无血圣祭，\n救恩圣筵价值无极；\n羊群置于祭坛之上，\n自己也为活献祭上。" | "四、永恒真理主，我众因主欢欣！\n肉身耳虽闻，未解圣言深恩，\n圣师言教中，启迪灵性明心，\n圣灵耀吾灵。阿们。" |
| `morning.office_hymn.verses.3.zh-hant` | "四、每逢獻上無血聖祭，\n救恩聖筵價值無極；\n羊群置於祭壇之上，\n自己也為活獻祭上。" | "四、永恆真理主，我眾因主歡欣！\n肉身耳雖聞，未解聖言深恩，\n聖師言教中，啓迪靈性明心，\n聖靈耀吾靈。阿們。" |
| `morning.office_hymn.verses.4` | {"zh-hant": "五、唯願榮耀讚頌尊威，\n歸於至高祭司耶穌，\n歸於聖父保惠聖靈，\n三一上帝永受讚頌。阿們。", "zh-hans": "五、唯愿荣耀赞颂尊威，\n归于至高祭司耶稣，\n归于圣父保惠圣灵，\n三一上帝永受赞颂。阿们。"} | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.zh-hans` | "义人必如百合花开放，" | "我已陈明主的信实和救恩；" |
| `morning.office_hymn.versicle.leader.zh-hant` | "義人必如百合花開放，" | "我已陳明主的信實和救恩；" |
| `morning.office_hymn.versicle.people.zh-hans` | "永远繁荣在主面前。" | "我未曾隐瞒主的慈爱和信实." |
| `morning.office_hymn.versicle.people.zh-hant` | "永遠繁榮在主面前。" | "我未曾隱瞞主的慈愛和信實。" |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚。" | "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚." |
| `morning.psalm_antiphons.antiphons.1.zh-hans` | "他遵守至高者的法律，※没有人比得上他。哈利路亚。" | "他遵守至高者的法律，※没有人比得上他。哈利路亚." |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚。" | "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚." |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚。" | "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚." |
| `morning.psalm_antiphons.antiphons.4.zh-hans` | "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚。" | "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚." |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "願那愛你名的人都靠你歡欣。※因為你必賜福與義人；主啊，你必用恩惠如同盾牌四面護衛他。", "zh-hans": "愿那爱你名的人都靠你欢欣。※因为你必赐福与义人；主啊，你必用恩惠如同盾牌四面护卫他。", "en": "Let all rejoice ※ who hope in thee, O Lord; since thou hast blessed the righteous man, and with the shield of thy good will hast crowned him."}, {"zh-hant": "在遵守至高者的法律上，※沒有人可與他對立。", "zh-hans": "在遵守至高者的法律上，※没有人可与他对立。", "en": "There was none found ※ like unto him, who kept the law of the Most High."}] |
| `evening.benedictus_antiphon.normal.zh-hans` | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求。" | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求." |
| `evening.bible_sentences.0.text.zh-hans` | "主与他立永远的盟约，赐予他大祭司的职分，以荣耀祝圣他，使他尽祭司职分，使他名得荣耀，并向他供献火祭、烧香和馨香祭。" | "主与他立永远的盟约，赐予他大祭司的职分，以荣耀祝圣他，使他尽祭司职分，使他名得荣耀，并向他供献火祭、烧香和馨香祭." |
| `evening.office_hymn.title` | "Jesu, sacerdotum decus" | "O luce qui mortalibus" |
| `evening.office_hymn.verses.0.zh-hans` | "一、耶稣主僕荣冕喜乐，\n慈目垂顾主的子民，\n今值圣者荣升天乡，\n光耀冠冕永沐圣恩。" | "一、上帝燃明灯，何其辉耀光明！\n你为地上盐，圣味至洁纯清；\n护人免腐朽，灵魂永葆洁贞，\n使人得永生." |
| `evening.office_hymn.verses.0.zh-hant` | "一、耶穌主僕榮冕喜樂，\n慈目垂顧主的子民，\n今值聖者榮升天鄉，\n光耀冠冕永沐聖恩。" | "一、上帝燃明燈，何其輝耀光明！\n你為地上鹽，聖味至潔純清；\n護人免腐朽，靈魂永葆潔貞，\n使人得永生。" |
| `evening.office_hymn.verses.1.zh-hans` | "二、爱主为证主恩为凭，\n自祢圣殿领受使命；\n守护照顾主赎羊群，\n父托于主彼竭其诚。" | "二、因你真理存，谬误永不侵凌；\n因你信德贞，童贞无玷坚凝；\n因主启宝藏，智慧丰盈倾注，\n智慧显于今." |
| `evening.office_hymn.verses.1.zh-hant` | "二、愛主為證主恩為憑，\n自禰聖殿領受使命；\n守護照顧主贖羊群，\n父托於主彼竭其誠。" | "二、因你真理存，謬誤永不侵凌；\n因你信德貞，童貞無玷堅凝；\n因主啓寶藏，智慧豐盈傾注，\n智慧顯於今。" |
| `evening.office_hymn.verses.2.zh-hans` | "三、驱散凶兽斥退豺狼，\n诡计虽狡尽皆洞穿；\n护卫群羊愿承危险，\n舍命争战忠勇无双。" | "三、圣泉涌活水，清澈润泽无垠，\n润基督田地，结实累累丰登；\n为乳汁育婴，为壮者备真粮，\n万民得饱飨." |
| `evening.office_hymn.verses.2.zh-hant` | "三、驅散凶獸斥退豺狼，\n詭計雖狡盡皆洞穿；\n護衛群羊願承危險，\n捨命爭戰忠勇無雙。" | "三、聖泉湧活水，清澈潤澤無垠，\n潤基督田地，結實累累豐登；\n為乳汁育嬰，為壯者備真糧，\n萬民得飽饗。" |
| `evening.office_hymn.verses.3.zh-hans` | "四、每逢献上无血圣祭，\n救恩圣筵价值无极；\n羊群置于祭坛之上，\n自己也为活献祭上。" | "四、永恒真理主，我众因主欢欣！\n肉身耳虽闻，未解圣言深恩，\n圣师言教中，启迪灵性明心，\n圣灵耀吾灵。阿们。" |
| `evening.office_hymn.verses.3.zh-hant` | "四、每逢獻上無血聖祭，\n救恩聖筵價值無極；\n羊群置於祭壇之上，\n自己也為活獻祭上。" | "四、永恆真理主，我眾因主歡欣！\n肉身耳雖聞，未解聖言深恩，\n聖師言教中，啓迪靈性明心，\n聖靈耀吾靈。阿們。" |
| `evening.office_hymn.verses.4` | {"zh-hant": "五、唯願榮耀讚頌尊威，\n歸於至高祭司耶穌，\n歸於聖父保惠聖靈，\n三一上帝永受讚頌。阿們。", "zh-hans": "五、唯愿荣耀赞颂尊威，\n归于至高祭司耶稣，\n归于圣父保惠圣灵，\n三一上帝永受赞颂。阿们。"} | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.zh-hans` | "主爱了他，并装扮了他。" | "主爱了他，并装扮了他." |
| `evening.office_hymn.versicle.people.zh-hans` | "给他穿上荣耀的外衣。" | "给他穿上荣耀的外衣." |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚。" | "看，大祭司，※他在世之时蒙上帝喜悦，又被认为是齐全正义之人。哈利路亚." |
| `evening.psalm_antiphons.antiphons.1.zh-hans` | "他遵守至高者的法律，※没有人比得上他。哈利路亚。" | "他遵守至高者的法律，※没有人比得上他。哈利路亚." |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚。" | "因此，※上帝起誓许使他的苗裔在万民之中兴旺。哈利路亚." |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚。" | "上帝的众祭司阿，※你们要赞颂主；主的仆人阿，请讴歌颂赞我们的上帝。哈利路亚." |
| `evening.psalm_antiphons.antiphons.4.zh-hans` | "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚。" | "善良忠信的仆人，※进入你主人的福乐吧！哈利路亚." |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "看哪！這是大祭司，※他在世之時取悅了上帝，被看為完全，是個義人。", "zh-hans": "看哪！这是大祭司，※他在世之时取悦了上帝，被看为完全，是个义人。", "en": "Behold a great Priest, ※ who in his days pleased God, and was found righteous."}, {"zh-hant": "這是那忠心有見識的管家，主人派他管理家裡的人。", "zh-hans": "这是那忠心有见识的管家，主人派他管理家里的人。", "en": "A wise and faithful steward, whom the Lord made ruler over his household."}] |

### sanctorale_0829_beheading_of_john_the_baptist.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`morning.bible_sentences`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 保留原先缺失／停用狀態：`morning.benedictus_antiphon.normals`, `evening.benedictus_antiphon.normals`。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal.zh-hans` | "希律※把约翰抓住绑了，关进监狱，因为约翰曾对他说：「你占有这妇人是不合法的。」" | "这真是一位殉道者，※他为基督的名倾流了鲜血；他不畏惧审判者的威吓，不追求世俗的尊贵荣耀，喜乐地进入天国." |
| `vigil.benedictus_antiphon.normal.zh-hant` | "希律※把約翰抓住綁了，關進監獄，因為約翰曾對他說：「你佔有這婦人是不合法的。」" | "這真是一位殉道者，※他為基督的名傾流了鮮血；他不畏懼審判者的威嚇，不追求世俗的尊貴榮耀，喜樂地進入天國。" |
| `vigil.bible_sentences.0.text.zh-hans` | "你们要为我的名被众人憎恨。但坚忍到底的终必得救。" | "你们要为我的名被众人憎恨。但坚忍到底的终必得救." |
| `vigil.lessons` | {"special": {"ot": {"book": "以賽亞書", "chapter": "1:4-9"}, "nt": {"book": "約翰福音", "chapter": "3:22-30"}}} | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.0.zh-hans` | "一、上帝义子勇毅无双，\n基督引尔得胜疆场；\n仇敌溃败如烟消散，\n凯旋荣光永耀天乡。" | "一、上帝义子勇毅无双，\n基督引尔得胜疆场；\n仇敌溃败如烟消散，\n凯旋荣光永耀天乡." |
| `vigil.office_hymn.verses.1.zh-hans` | "二、伏求圣徒代祷恳切，\n涤我众罪污痕尽灭；\n护避诸恶蛊惑沾染，\n卸却尘劳疲困重轭。" | "二、伏求圣徒代祷恳切，\n涤我众罪污痕尽灭；\n护避诸恶蛊惑沾染，\n卸却尘劳疲困重轭." |
| `vigil.office_hymn.verses.2.zh-hans` | "三、昔日枷锁尽化埃尘，\n圣躯终脱桎梏苦困；\n求以圣子救赎宏恩，\n解我尘世万般束缚。" | "三、昔日枷锁尽化埃尘，\n圣躯终脱桎梏苦困；\n求以圣子救赎宏恩，\n解我尘世万般束缚." |
| `vigil.office_hymn.verses.3.zh-hans` | "四、赞美圣父创造之恩，\n赞美圣子救世之恩；\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽。阿们。" | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽。阿们。" |
| `vigil.office_hymn.versicle.leader.zh-hans` | "主加增他尊贵荣耀。" | "主加增他尊贵荣耀." |
| `vigil.office_hymn.versicle.leader.zh-hant` | "主加增他尊貴榮耀。" | "主加增他尊贵荣耀。" |
| `vigil.office_hymn.versicle.people.zh-hant` | "把主所創造的歸他管理，" | "把主所创造的归他管理，" |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "希律为希罗底的缘故，派人去抓了约翰，※把他绑了在监狱里。" | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `vigil.psalm_antiphons.antiphons.0.zh-hant` | "希律為希羅底的緣故，派人去抓了約翰，※把他綁了在監獄裏。" | "凡在人面前認我的，※我在我天上的父面前也必認他。" |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "那跳舞的女孩说：※愿我主我王立刻把施洗约翰的头放在盘子里给我。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `vigil.psalm_antiphons.antiphons.1.zh-hant` | "那跳舞的女孩說：※願我主我王立刻把施洗約翰的頭放在盤子里給我。" | "我就是世界的光。※跟從我的，必不在黑暗裏走，卻要得着生命的光。" |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "女孩跳完舞，她母亲对她说：※除了施洗约翰的头，你什么也不要求。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `vigil.psalm_antiphons.antiphons.2.zh-hant` | "女孩跳完舞，她母親對她說：※除了施洗約翰的頭，你什麼也不要求。" | "若有人服事我，※就當跟從我；我在哪裏，服事我的人也要在哪裏。" |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "约翰为了希罗底的缘故，※指责希律，因为希律娶了他兄弟腓力的妻子。" | "主说：※若有人服事我，我父必尊重他." |
| `vigil.psalm_antiphons.antiphons.3.zh-hant` | "約翰為了希羅底的緣故，※指責希律，因為希律娶了他兄弟腓力的妻子。" | "主說：※若有人服事我，我父必尊重他。" |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "女孩说：请把施洗约翰的头放在盘子里给我。※王因他所发的誓就很忧愁。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |
| `vigil.psalm_antiphons.antiphons.4.zh-hant` | "女孩說：請把施洗約翰的頭放在盤子裏給我。※王因他所發的誓就很憂愁。" | "聖父阿，※我在哪裏，服事我的人也要在哪裏。" |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這位聖者為維護上帝的律法奮鬥至死，※對惡人的恐嚇毫不畏懼；因為他好像建在穩固的磐石上。", "zh-hans": "这位圣者为维护上帝的律法奋斗至死，※对恶人的恐吓毫不畏惧；因为他好像建在稳固的磐石上。", "en": "This is a holy man ※ who strove for the law of his God, even unto death; and feared not the words of evil men, forasmuch as he was established on the sure and firm Rock."} |
| `vigil.psalms` | {"special": {"items": [{"number": "113"}, {"number": "117"}, {"number": "146"}]}} | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal` | {"zh-hant": "希律就立刻派※一個衛兵，吩咐在監獄中砍下約翰的頭。約翰的門徒聽到了，就立刻來把他的屍體領去，放在墳墓裏。", "zh-hans": "希律就立刻派※一个卫兵，吩咐在监狱中砍下约翰的头。约翰的门徒听到了，就立刻来把他的尸体领去，放在坟墓里。"} | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normals` | （原檔沒有此欄位） | [{"zh-hant": "一粒麥子不落在地裏死了，※仍舊是一粒。", "zh-hans": "一粒麦子不落在地里死了，※仍旧是一粒."}, {"zh-hant": "主說：若有人要跟從我，※就當捨己，背起自己的十字架來跟從我。", "zh-hans": "主说：若有人要跟从我，※就当舍己，背起自己的十字架来跟从我."}] |
| `morning.biography` | {"title": {"zh-hant": "《論童貞女》", "zh-hans": "《论童贞女》"}, "source": {"zh-hant": "取自聖安波羅修主教的《論童貞女》。", "zh-hans": "取自圣安波罗修主教的《论童贞女》。"}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。"}, "paragraphs": [{"zh-hant": "我們不可匆匆略過真福施洗聖約翰之紀錄。我們必須問：他被誰殺害？為何被殺？又如何被殺？他是一位義人，卻因自己的義而被行淫的人謀殺；他是一位審判官，因他公正地判斷了有罪之人的罪，反被罪人判處死刑；他是一位先知，他的死亡竟成了為一場淫蕩舞蹈付給跳舞少女的報酬。最後，竟發生了一件連野蠻人也會退避的事：他的頭顱被當作筵席上的一道菜端了上來。因為下達這殘暴命令之時，正值宴飲歡樂之際；而兇手的僕人們在各道菜餚之間引進了這場謀殺，從宴席跑到監獄，又從監獄跑回宴席！看哪，這單單一項罪行中，就包含了多少可恥之舉。", "zh-hans": "我们不可匆匆略过真福施洗圣约翰之纪录。我们必须问：他被谁杀害？为何被杀？又如何被杀？他是一位义人，却因自己的义而被行淫的人谋杀；他是一位审判官，因他公正地判断了有罪之人的罪，反被罪人判处死刑；他是一位先知，他的死亡竟成了为一场淫荡舞蹈付给跳舞少女的报酬。最后，竟发生了一件连野蛮人也会退避的事：他的头颅被当作筵席上的一道菜端了上来。因为下达这残暴命令之时，正值宴饮欢乐之际；而凶手的仆人们在各道菜肴之间引进了这场谋杀，从宴席跑到监狱，又从监狱跑回宴席！看哪，这单单一项罪行中，就包含了多少可耻之举。"}, {"zh-hant": "若有人看見使者急忙從宴席前往監獄，誰不會立刻斷定他是帶著釋放先知的命令呢？若有人聽說那天是希律的生日，他正大擺筵席；又聽說他已應允一位少女，可以隨意求她所要的；隨後便有使者被派往約翰的牢房——我說，若有人聽見這一切，他會怎麼想呢？他必會以為，那少女求得了約翰的自由。尋歡作樂與殘酷有何相干？貪圖享樂與殺人害命又有何相干？筵席還在進行時，這位先知便因一個醉心宴樂之人的命令，被匆匆送去受死；而他甚至未曾以求釋放的祈求去打擾過那人。他被刀劍所殺，他的頭被放在盤子裏端了上來。這是殘酷所要求的一道新菜，是整場宴席也無力滿足的殘酷。", "zh-hans": "若有人看见使者急忙从宴席前往监狱，谁不会立刻断定他是带着释放先知的命令呢？若有人听说那天是希律的生日，他正大摆筵席；又听说他已应允一位少女，可以随意求她所要的；随后便有使者被派往约翰的牢房——我说，若有人听见这一切，他会怎么想呢？他必会以为，那少女求得了约翰的自由。寻欢作乐与残酷有何相干？贪图享乐与杀人害命又有何相干？筵席还在进行时，这位先知便因一个醉心宴乐之人的命令，被匆匆送去受死；而他甚至未曾以求释放的祈求去打扰过那人。他被刀剑所杀，他的头被放在盘子里端了上来。这是残酷所要求的一道新菜，是整场筵席也无力满足的残酷。"}, {"zh-hant": "殘酷的王啊，看看這多麼配得上你宴席的裝飾吧！伸出你的手，在筵席中觸摸這死亡的頭顱。為不失去任何一點殘酷的享樂，讓那神聖的血從你的指間淌過。宴席未能滿足你的飢餓，酒杯也未能止息你不近人情的乾渴；那麼，你就喝這顆神聖頭顱仍從悸動的血管中流出的血吧。看看那雙眼睛！即使在死亡中，它們仍是你污穢的見證；儘管它們急忙閉上，好不再看見你放縱的歡樂。那雙眼睛正在閉合；然而，與其說是因著死亡，不如說是出於對你享樂的駭然。那張金口如今毫無血色，寂然無聲；它再不能重複你不堪聽聞的譴責！然而，即使它不再說話，你仍害怕它無言的審判！", "zh-hans": "残酷的王啊，看看这多么配得上你宴席的装饰吧！伸出你的手，在筵席中触摸这死亡的头颅。为不失去任何一点残酷的享乐，让那神圣的血从你的指间淌过。宴席未能满足你的饥饿，酒杯也未能止息你不近人情的干渴；那么，你就喝这颗神圣头颅仍从悸动的血管中流出的血吧。看看那双眼睛！即使在死亡中，它们仍是你污秽的见证；尽管它们急忙闭上，好不再看见你放纵的欢乐。那双眼睛正在闭合；然而，与其说是因着死亡，不如说是出于对你享乐的骇然。那张金口如今毫无血色，寂然无声；它再不能重复你不堪听闻的谴责！然而，即使它不再说话，你仍害怕它无言的审判！"}]} | （原檔沒有此欄位） |
| `morning.invitatory.text.zh-hans` | "主是先锋的君王，※我们当来俯伏敬拜。" | "主是殉道者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory.text.zh-hant` | "主是先鋒的君王，※我們當來俯伏敬拜。" | "主是殉道者的君王，※我們當來俯伏敬拜。" |
| `morning.invitatory_hymn.verses.0.zh-hans` | "一、上帝义子勇毅无双，\n基督引尔得胜疆场；\n仇敌溃败如烟消散，\n凯旋荣光永耀天乡。" | "一、上帝义子勇毅无双，\n基督引尔得胜疆场；\n仇敌溃败如烟消散，\n凯旋荣光永耀天乡." |
| `morning.invitatory_hymn.verses.1.zh-hans` | "二、伏求圣徒代祷恳切，\n涤我众罪污痕尽灭；\n护避诸恶蛊惑沾染，\n卸却尘劳疲困重轭。" | "二、伏求圣徒代祷恳切，\n涤我众罪污痕尽灭；\n护避诸恶蛊惑沾染，\n卸却尘劳疲困重轭." |
| `morning.invitatory_hymn.verses.2.zh-hans` | "三、昔日枷锁尽化埃尘，\n圣躯终脱桎梏苦困；\n求以圣子救赎宏恩，\n解我尘世万般束缚。" | "三、昔日枷锁尽化埃尘，\n圣躯终脱桎梏苦困；\n求以圣子救赎宏恩，\n解我尘世万般束缚." |
| `morning.invitatory_hymn.verses.3.zh-hans` | "四、赞美圣父创造之恩，\n赞美圣子救世之恩；\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽。阿们。" | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽。阿们。" |
| `morning.lessons` | {"special": {"ot": {"book": "以西結書", "chapter": "3:4-11"}, "nt": {"book": "馬太福音", "chapter": "11:2-19"}}} | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生。" | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生." |
| `morning.office_hymn.verses.1.zh-hans` | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年。" | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年." |
| `morning.office_hymn.verses.2.zh-hans` | "三、为尔穿越万般艰难，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆。" | "三、为尔穿越万般艰难，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆." |
| `morning.office_hymn.verses.3.zh-hans` | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污。" | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污." |
| `morning.office_hymn.versicle.leader.zh-hans` | "义人必如百合花开放，" | "义人必如百合花开放." |
| `morning.office_hymn.versicle.people.zh-hans` | "永远繁荣在主面前。" | "永远繁荣在主面前." |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "希律为希罗底的缘故，派人去抓了约翰，※把他绑了在监狱里." | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `morning.psalm_antiphons.antiphons.0.zh-hant` | "希律為希羅底的緣故，派人去抓了約翰，※把他綁了在監獄裏。" | "凡在人面前認我的，※我在我天上的父面前也必認他。" |
| `morning.psalm_antiphons.antiphons.1.zh-hans` | "那跳舞的女孩说：※愿我主我王立刻把施洗约翰的头放在盘子里给我。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `morning.psalm_antiphons.antiphons.1.zh-hant` | "那跳舞的女孩說：※願我主我王立刻把施洗約翰的頭放在盤子里給我。" | "我就是世界的光。※跟從我的，必不在黑暗裏走，卻要得着生命的光。" |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "女孩跳完舞，她母亲对她说：※除了施洗约翰的头，你什么也不要求。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `morning.psalm_antiphons.antiphons.2.zh-hant` | "女孩跳完舞，她母親對她說：※除了施洗約翰的頭，你什麼也不要求。" | "若有人服事我，※就當跟從我；我在哪裏，服事我的人也要在哪裏。" |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "约翰为了希罗底的缘故，※指责希律，因为希律娶了他兄弟腓力的妻子。" | "主说：※若有人服事我，我父必尊重他." |
| `morning.psalm_antiphons.antiphons.3.zh-hant` | "約翰為了希羅底的緣故，※指責希律，因為希律娶了他兄弟腓力的妻子。" | "主說：※若有人服事我，我父必尊重他。" |
| `morning.psalm_antiphons.antiphons.4.zh-hans` | "女孩说：请把施洗约翰的头放在盘子里给我。※王因他所发的誓就很忧愁。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |
| `morning.psalm_antiphons.antiphons.4.zh-hant` | "女孩說：請把施洗約翰的頭放在盤子裏給我。※王因他所發的誓就很憂愁。" | "聖父阿，※我在哪裏，服事我的人也要在哪裏。" |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "公義的主※喜愛公義；他的眼目必看顧正直的人。", "zh-hans": "公义的主※喜爱公义；他的眼目必看顾正直的人。", "en": "The righteous Lord ※ loveth righteousness; his countenance will behold the thing that is just."} |
| `morning.psalms` | {"special": {"items": [{"number": "63"}, {"number": "93"}, {"number": "100"}]}} | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal` | {"zh-hant": "約翰的門徒來，※把屍體領去埋葬了，把他放在墳墓裏。", "zh-hans": "约翰的门徒来，※把尸体领去埋葬了，把他放在坟墓里。"} | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals` | （原檔沒有此欄位） | [{"zh-hant": "他將世上的一切都視為無物，※以言以行，為自己在天上積蓄財寶。", "zh-hans": "他将世上的一切都视为无物，※以言以行，为自己在天上积蓄财宝."}, {"zh-hant": "此人徹悟公義，洞悉奇偉奧秘；※他祈求至高者，終列諸聖之中。", "zh-hans": "此人彻悟公义，洞悉奇伟奥秘；※他祈求至高者，终列诸圣之中."}] |
| `evening.bible_sentences.0.text.zh-hans` | "忍受试炼的人有福了，因为他经过考验以后必得生命的冠冕，这是主应许给爱他之人的。" | "忍受试炼的人有福了，因为他经过考验以后必得生命的冠冕，这是主应许给爱他之人的." |
| `evening.lessons` | {"special": {"ot": {"book": "所羅門智訓", "chapter": "5:15-20"}, "nt": {"book": "路加福音", "chapter": "12:1-12"}}} | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生。" | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生." |
| `evening.office_hymn.verses.1.zh-hans` | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年。" | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年." |
| `evening.office_hymn.verses.2.zh-hans` | "三、为尔穿越万般艰难，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆。" | "三、为尔穿越万般艰难，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆." |
| `evening.office_hymn.verses.3.zh-hans` | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污。" | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污." |
| `evening.office_hymn.versicle.leader.zh-hant` | "主迎接他，賜他厚福，" | "主迎接他，赐他厚福，" |
| `evening.office_hymn.versicle.people.zh-hant` | "將精金的冠冕，戴在他的頭上。" | "将精金的冠冕，戴在他的头上。" |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "希律为希罗底的缘故，派人去抓了约翰，※把他绑了在监狱里." | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `evening.psalm_antiphons.antiphons.0.zh-hant` | "希律為希羅底的緣故，派人去抓了約翰，※把他綁了在監獄裏。" | "凡在人面前認我的，※我在我天上的父面前也必認他。" |
| `evening.psalm_antiphons.antiphons.1.zh-hans` | "那跳舞的女孩说：※愿我主我王立刻把施洗约翰的头放在盘子里给我。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `evening.psalm_antiphons.antiphons.1.zh-hant` | "那跳舞的女孩說：※願我主我王立刻把施洗約翰的頭放在盤子里給我。" | "我就是世界的光。※跟從我的，必不在黑暗裏走，卻要得着生命的光。" |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "女孩跳完舞，她母亲对她说：※除了施洗约翰的头，你什么也不要求。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `evening.psalm_antiphons.antiphons.2.zh-hant` | "女孩跳完舞，她母親對她說：※除了施洗約翰的頭，你什麼也不要求。" | "若有人服事我，※就當跟從我；我在哪裏，服事我的人也要在哪裏。" |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "约翰为了希罗底的缘故，※指责希律，因为希律娶了他兄弟腓力的妻子。" | "主说：※若有人服事我，我父必尊重他." |
| `evening.psalm_antiphons.antiphons.3.zh-hant` | "約翰為了希羅底的緣故，※指責希律，因為希律娶了他兄弟腓力的妻子。" | "主說：※若有人服事我，我父必尊重他。" |
| `evening.psalm_antiphons.antiphons.4.zh-hans` | "女孩说：请把施洗约翰的头放在盘子里给我。※王因他所发的誓就很忧愁。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |
| `evening.psalm_antiphons.antiphons.4.zh-hant` | "女孩說：請把施洗約翰的頭放在盤子裏給我。※王因他所發的誓就很憂愁。" | "聖父阿，※我在哪裏，服事我的人也要在哪裏。" |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | [{"zh-hant": "凡在人面前認我的，※我在我天上的父面前也必認他。", "zh-hans": "凡在人面前认我的，※我在我天上的父面前也必认他。", "en": "Whosoever shall confess ※ me before men, him will I confess also before my Father."}, {"zh-hant": "那在智慧中恆心不渝，※默想神聖之事，並在心中思想上帝無所不見之大能的人有福了。", "zh-hans": "那在智慧中恒心不渝，※默想神圣之事，并在心中思想上帝无所不见之大能的人有福了。", "en": "Blessed is the man ※ that continueth in wisdom, and doth meditate on holy things, and that reasoneth in his mind on the all-seeing power of God."}] |
| `evening.psalms` | {"special": {"items": [{"number": "110"}, {"number": "116"}, {"number": "126"}]}} | （原檔沒有此欄位） |

### sanctorale_0830_rose_of_lima.json

- 通用：`common_virgin_outside_easter`（一位童貞女通用（復活期外）.json）。
- 移除並繼承：`evening.bible_sentences`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 無本日專用，改為繼承通用：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal.zh-hans` | "这是一位明智的童贞女，※主发现她警醒守候；她整理好灯，带着油，当主来临时，就与祂一同进入婚宴。" | "这是一位明智的童贞女，主发现她警醒守候；她整理好灯，带着油，当主来临时，就与祂一同进入婚宴." |
| `vigil.benedictus_antiphon.normal.zh-hant` | "這是一位明智的童貞女，※主發現她警醒守候；她整理好燈，帶著油，當主來臨時，就與祂一同進入婚宴。" | "這是一位明智的童貞女，主發現她警醒守候；她整理好燈，帶著油，當主來臨時，就與祂一同進入婚宴。" |
| `vigil.bible_sentences.0.text.zh-hans` | "才德的妇人谁能得着呢？她的价值远胜过宝石。她开口就发智慧，她舌上有仁慈的教诲。" | "才德的妇人谁能得着呢？她的价值远胜过宝石。她开口就发智慧，她舌上有仁慈的教诲." |
| `vigil.office_hymn.title` | "Virginis Proles Opifexque Matris" | "童貞產聖子" |
| `vigil.office_hymn.verses.0.zh-hans` | "一、童贞产圣子，造尔圣母之主；\n童贞身受孕，复由童贞所生；\n当我等传述，童贞凯旋事迹，\n听我等祈求。" | "一、童贞产圣子，造尔圣母之主；\n童贞身受孕，复由童贞所生；\n当我等传述，童贞凯旋事迹，\n听我等祈求." |
| `vigil.office_hymn.verses.1.zh-hans` | "二、尔之圣侍女，赢得双重福份；\n竭力以克胜，本性软弱之躯；\n即以此弱身，胜过血腥俗世，\n凯歌永传扬。" | "二、尔之圣侍女，赢得双重福份；\n竭力以克胜，本性软弱之躯；\n即以此弱身，胜过血腥俗世，\n凯歌永传扬." |
| `vigil.office_hymn.verses.2.zh-hans` | "三、无惧地注视，死亡及其惊怖；\n蔑视死侍婢，即那残忍酷刑；\n倾流生命血，以此堪当进入，\n至圣之天乡。" | "三、无惧地注视，死亡及其惊怖；\n蔑视死侍婢，即那残忍酷刑；\n倾流生命血，以此堪当进入，\n至圣之天乡." |
| `vigil.office_hymn.verses.3.zh-hans` | "四、永爱之上帝，当伊为我代求；\n怜我等过犯，赦免一切罪愆；\n愿纯洁赞美，回响以此敬献，\n归于尔荣耀。" | "四、永爱之上帝，当伊为我代求；\n怜我等过犯，赦免一切罪愆；\n愿纯洁赞美，回响以此敬献，\n归于尔荣耀." |
| `vigil.office_hymn.versicle.leader.zh-hans` | "你的嘴里满有恩惠。" | "你的嘴唇满有恩惠." |
| `vigil.office_hymn.versicle.leader.zh-hant` | "你的嘴里满有恩惠。" | "你的嘴唇滿有恩惠。" |
| `vigil.office_hymn.versicle.people.zh-hans` | "因为上帝永远赐福与你。" | "因为上帝永远赐福与你." |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "这是那位明智的贞女，※她是那聪明贞女当中的一位。" | "这是那位明智的贞女，※她是那聪明贞女当中的一位." |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "这是那位明智的贞女，※是主来到时发现醒悟着的贞女。" | "这是那位明智的贞女，※是主来到时发现醒悟着的贞女." |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "这就是那不知床第罪恶的女子，※在灵魂受眷顾的时候，她必富有果实。" | "这就是那不知床第罪恶的女子，※在灵魂受眷顾的时候，她必富有果实." |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "来吧，我所拣选的，※我要让她坐在我的宝座上。" | "来吧，※我所拣选的，我要让她坐在我的宝座上." |
| `vigil.psalm_antiphons.antiphons.3.zh-hant` | "來吧，我所揀選的，※我要讓她坐在我的寶座上。" | "來吧，※我所揀選的，我要讓她坐在我的寶座上。" |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "这就是那在耶路撒冷的女儿※中美貌秀丽的那一位。" | "这就是※那在耶路撒冷的女儿中美貌秀丽的那一位." |
| `vigil.psalm_antiphons.antiphons.4.zh-hant` | "這就是那在耶路撒冷的女兒※中美貌秀麗的那一位。" | "這就是※那在耶路撒冷的女兒中美貌秀麗的那一位。" |
| `vigil.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這是一位神聖榮耀的童貞女，※萬主之主已經揀選了她。", "zh-hans": "这是一位神圣荣耀的童贞女，※万主之主已经拣选了她。", "en": "This is a virgin, ※ glorious and holy, for the Lord of all hath chosen her. "} |
| `morning.benedictus_antiphon.normal.zh-hans` | "当新郎来到时，明智的童贞女已经预备好，就与他一同进入婚宴。" | "当新郎来到时，明智的童贞女已经预备好，就与他一同进入婚宴." |
| `morning.bible_sentences.0.text.zh-hans` | "才德的女子很多，惟独你超过一切。魅力是虚假的，美貌是虚浮的；惟敬畏耶和华的妇女必得称赞。" | "才德的女子很多，惟独你超过一切。魅力是虚假的，美貌是虚浮的；惟敬畏耶和华的妇女必得称赞." |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传"}, "source": {"zh-hant": "", "zh-hans": ""}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。"}, "paragraphs": [{"zh-hant": "在南美洲完全綻放的第一朵聖潔之花，是一位名叫羅撒的少女。她於 1586 年 4 月 20 日出生在利馬，父母皆為西班牙裔。她名字的由來，是因為家人覺得她在嬰孩時的面容奇異地像一朵玫瑰。後來，她又在自己的名字加上了童貞上帝之母的名字，渴望被稱為「聖馬利亞的玫瑰」。她很早便察覺到，家人因她的美貌而產生的驕傲，會對她的靈魂造成危險；因此在十五歲時，她許下了終身守貞的誓願。隨著年歲漸長，為免父母強迫她結婚，她剪去了頭上所有的頭髮。她用十年的時間，抵抗父母為她安排的世俗抱負。她也抵抗自己強烈的天然情感，即藉著肉身的苦行——對於一個如此年輕、又如此受這個充滿巧言諂媚的世界所愛慕的人而言，這是極其非凡的。", "zh-hans": "在南美洲完全绽放的第一朵圣洁之花，是一位名叫罗撒的少女。她于 1586 年 4 月 20 日出生在利马，父母皆为西班牙裔。她名字的由来，是因为家人觉得她在婴儿时的面容奇异地像一朵玫瑰。后来，她又在自己的名字加上了童贞上帝之母的名字，渴望被称为「圣马利亚的玫瑰」。她很早便察觉到，家人因她的美貌而产生的骄傲，会对她的灵魂造成危险；因此在十五岁时，她许下了终身守贞的誓愿。随着年岁渐长，为免父母强迫她结婚，她剪去了头上所有的头发。她用十年的时间，抵抗父母为她安排的世俗抱负。她也抵抗自己强烈的天然情感，即藉着肉身的苦行——对于一个如此年轻、又如此受这个充满巧言谄媚的世界所爱慕的人而言，这是极其非凡的。"}, {"zh-hant": "其後，在取得父母同意領受道明会的第三會的會衣後，她效法錫耶納的聖凱瑟琳的榜樣，將從前的苦行加倍。她穿著粗糙的毛布苦衣，以及其他為克己肉身而設計的物品。為了仿效聖凱瑟琳，她以三重的鐵鏈束腰。她睡在極其堅硬且不舒服的床上。她在花園最偏遠的角落為自己建了一間小屋，在那裏她專心思念天上的事，並藉著頻繁的鞭打、禁食和徹夜祈禱來操練自己的身體。然而，她的靈魂越發剛強；雖然她常在心靈中經歷劇烈的爭戰，卻藉著對基督的愛而得勝。當她的父母變得非常貧窮時，她欣然迎接貧窮，並甘心樂意地以自己的手工勞作供養他們度過餘生。", "zh-hans": "其后，在取得父母同意领受道明会的第三会的会衣后，她效法锡耶纳的圣凯瑟琳的榜样，将从前的苦行加倍。她穿着粗糙的毛布苦衣，以及其他为克己肉身而设计的物品。为了仿效圣凯瑟琳，她以重重的铁链束腰。她睡在极其坚硬且不舒服的床上。她在花园最偏远的角落为自己建了一间小屋，在那里她专心思念天上的事，并藉着频繁的鞭打、禁食和彻夜祈祷来操练自己的身体。然而，她的灵魂越发刚强；虽然她常在心灵中经历剧烈的争战，却藉着对基督的爱而得胜。当她的父母变得非常贫穷时，她欣然迎接贫穷，并甘心乐意地以自己的手工劳作供养他们度过余生。"}, {"zh-hant": "在晚年，她因痛苦的疾病、僕人的虐待，甚至毀謗性的指控而受了極大的苦。但她藉著默觀被釘十字架的基督，學習到若要為罪作補贖，就有受苦的必要；因此，她反而抱怨自己所受的苦，不如她所配受的那樣多。十五年之久，她經歷了許多投身於更高深祈禱生活者都會面臨的巨大試煉，即靈性的荒涼與枯乾；在其中，她勇敢地忍受了一種比任何形式的死亡更為可怕的荒涼。經過這段時期後，她開始滿溢著安慰，並蒙上帝恩典的照耀，以致如撒拉弗一般被愛火點燃。據說，她與自己的守護天使達到了一種奇特而親密的個人關係；她與自己努力效法的童貞聖徒——即錫耶納的聖凱瑟琳——甚至與童貞上帝之母，也有著同樣的親密。有一次在異象中，她聽見基督說：「我心中的玫瑰，作我的新婦吧。」她在秘魯為上帝作了偉大的見證；無論在她離世之前或之後，都因許多奇事而聞名。1617 年 8 月 24 日，她被移植到新郎的花園中，當時年僅三十一歲。1671 年，她獲封聖，如今被尊為南美洲與菲律賓的主保；因為她是新世界中第一位獲封聖的人。在那之前，那片土地一直是一片荒蕪，直到這位童貞女出現，如同玫瑰般在異教的荊棘中生長、綻放。", "zh-hans": "在晚年，她因痛苦的疾病、仆人的虐待，甚至毁谤性的指控而受了极大的苦。但她藉着默观被钉十字架的基督，学习到若要为罪作补赎，就有受苦的必要；因此，她反而抱怨自己所受的苦，不如她所配受的那样多。十五年之久，她经历了许多投身于更高深祈祷生活者都会面临的巨大试炼，即灵性的荒凉与枯干；在其中，她勇敢地忍受了一种比任何形式的死亡更为可怕的荒凉。经过这段时期后，她开始满溢着安慰，并蒙上帝恩典的照耀，以致如撒拉弗一般被爱火点燃。据说，她与自己的守护天使达到了一种奇特而亲密的个人关系；她与自己努力效法的童贞圣徒——即锡耶纳的圣凯瑟琳——甚至与童贞上帝之母，也有着同样的亲密。有一次在异象中，她听见基督说：「我心中的玫瑰，作我的新妇吧。」她在秘鲁为上帝作了伟大的见证；无论在她离世之前或之后，都因许多奇事而闻名。1617 年 8 月 24 日，她被移植到新郎的花园中，当时年仅三十一岁。1671 年，她获封圣，如今被尊为南美洲与菲律宾的主保；因为她是新世界中第一位获封圣的人。在那之前，那片土地一直是一片荒芜，直到这位童贞女出现，如同玫瑰般在异教的荆棘中生长、绽放。"}]} | （原檔沒有此欄位） |
| `morning.invitatory.text.zh-hans` | "主是童贞女的君王，※我们当来俯伏敬拜。" | "童贞女所许配之羔羊，我主耶稣基督。※我们当来俯伏敬拜." |
| `morning.invitatory.text.zh-hant` | "主是童貞女的君王，※我們當來俯伏敬拜。" | "童貞女所許配之羔羊，我主耶穌基督。※我們當來俯伏敬拜。" |
| `morning.invitatory_hymn.title` | "Virginis Proles Opifexque Matris" | "童貞產聖子" |
| `morning.invitatory_hymn.verses.0.zh-hans` | "一、童贞产圣子，造尔圣母之主；\n童贞身受孕，复由童贞所生；\n当我等传述，童贞凯旋事迹，\n听我等祈求。" | "一、童贞产圣子，造尔圣母之主；\n童贞身受孕，复由童贞所生；\n当我等传述，童贞凯旋事迹，\n听我等祈求." |
| `morning.invitatory_hymn.verses.1.zh-hans` | "二、尔之圣侍女，赢得双重福份；\n竭力以克胜，本性软弱之躯；\n即以此弱身，胜过血腥俗世，\n凯歌永传扬。" | "二、尔之圣侍女，赢得双重福份；\n竭力以克胜，本性软弱之躯；\n即以此弱身，胜过血腥俗世，\n凯歌永传扬." |
| `morning.invitatory_hymn.verses.2.zh-hans` | "三、无惧地注视，死亡及其惊怖；\n蔑视死侍婢，即那残忍酷刑；\n倾流生命血，以此堪当进入，\n至圣之天乡。" | "三、无惧地注视，死亡及其惊怖；\n蔑视死侍婢，即那残忍酷刑；\n倾流生命血，以此堪当进入，\n至圣之天乡." |
| `morning.invitatory_hymn.verses.3.zh-hans` | "四、永爱之上帝，当伊为我代求；\n怜我等过犯，赦免一切罪愆；\n愿纯洁赞美，回响以此敬献，\n归于尔荣耀。" | "四、永爱之上帝，当伊为我代求；\n怜我等过犯，赦免一切罪愆；\n愿纯洁赞美，回响以此敬献，\n归于尔荣耀." |
| `morning.office_hymn.title` | "Jesu, Corona Virginum" | "耶穌童貞女的冠冕" |
| `morning.office_hymn.verses.0.zh-hans` | "一、耶稣童贞荣耀冠冕，\n俯听我等屈膝祈祷，\n生于童贞圣母膝下，\n惟伊童贞亦得母荣。" | "一、耶稣童贞女的冠冕，\n求主俯听我们祈祷，\n主由童贞圣母所生，\n我们尊崇圣母圣女." |
| `morning.office_hymn.verses.0.zh-hant` | "一、耶穌童貞榮耀冠冕，\n俯聽我等屈膝祈禱，\n生於童貞聖母膝下，\n惟伊童貞亦得母榮。" | "一、耶穌童貞女的冠冕，\n求主俯聽我們祈禱，\n主由童貞聖母所生，\n我們尊崇聖母聖女。" |
| `morning.office_hymn.verses.1.zh-hans` | "二、牧养徜徉百合花间，\n率领童贞圣洁歌团，\n慈爱赐下荣耀恩物，\n妆饰蒙选圣洁净配。" | "二、百合丛中牧养我们，\n引领童贞女的诗班，\n主以慈爱赐下恩典，\n装饰蒙拣选的新娘." |
| `morning.office_hymn.verses.1.zh-hant` | "二、牧養徜徉百合花間，\n率領童貞聖潔歌團，\n慈愛賜下榮耀恩物，\n妝飾蒙選聖潔淨配。" | "二、百合叢中牧養我們，\n引領童貞女的詩班，\n主以慈愛賜下恩典，\n裝飾蒙揀選的新娘。" |
| `morning.office_hymn.verses.2.zh-hans` | "三、无论恩主圣足何往，\n童贞队列赞美相随；\n为祢献上甜美颂歌，\n欢欣踊跃紧随尊前。" | "三、无论上主前往何方，\n贞女歌团赞美相随；\n为主献上甜美赞歌，\n欢欣踊跃跟随着主." |
| `morning.office_hymn.verses.2.zh-hant` | "三、無論恩主聖足何往，\n童貞隊列讚美相隨；\n為祢獻上甜美頌歌，\n歡欣踴躍緊隨尊前。" | "三、無論上主前往何方，\n貞女歌團讚美相隨；\n為主獻上甜美贊歌，\n歡欣踴躍跟隨著主。" |
| `morning.office_hymn.verses.3.zh-hans` | "四、恳求至慈至悲恩主，\n倾注恩典洁净感官；\n免受罪恶污秽沾染，\n为祢保持心地纯全。" | "四、我们恳求慈悲恩主，\n以主恩典充满感官；\n保守我们远离罪污，\n心灵洁净归属于主." |
| `morning.office_hymn.verses.3.zh-hant` | "四、懇求至慈至悲恩主，\n傾注恩典潔淨感官；\n免受罪惡污穢沾染，\n為祢保持心地純全。" | "四、我們懇求慈悲恩主，\n以主恩典充滿感官；\n保守我們遠離罪污，\n心靈潔淨歸屬於主。" |
| `morning.office_hymn.versicle.leader.zh-hans` | "众童贞女必伴随她。" | "众童贞女必伴随她." |
| `morning.office_hymn.versicle.people.zh-hans` | "她们必被带到祢面前。" | "她们必被带到祢面前." |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "来吧，我所拣选的，※我要让她坐在我的宝座上." | "来吧，※我所拣选的，我要让她坐在我的宝座上." |
| `morning.psalm_antiphons.antiphons.3.zh-hant` | "來吧，我所揀選的，※我要讓她坐在我的寶座上。" | "來吧，※我所揀選的，我要讓她坐在我的寶座上。" |
| `morning.psalm_antiphons.antiphons.4.zh-hans` | "这就是那在耶路撒冷的女儿※中美貌秀丽的那一位." | "这就是※那在耶路撒冷的女儿中美貌秀丽的那一位." |
| `morning.psalm_antiphons.antiphons.4.zh-hant` | "這就是那在耶路撒冷的女兒※中美貌秀麗的那一位。" | "這就是※那在耶路撒冷的女兒中美貌秀麗的那一位。" |
| `morning.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "基督的淨配，※請來接受主從永遠就為你準備好的華冠。", "zh-hans": "基督的净配，※请来接受主从永远就为你准备好的华冠。", "en": "Come, thou bride of Christ,※ receive the crown, which the Lord hath provided for thee for ever."} |
| `evening.benedictus_antiphon.normal.zh-hans` | "天国又好比商人寻找好的珍珠，发现一颗贵重的珍珠，就去变卖他一切所有的，买下这颗珍珠。" | "天国又好比商人寻找好的珍珠，发现一颗贵重的珍珠，就去变卖他一切所有的，买下这颗珍珠." |
| `evening.office_hymn.title` | "Jesu, Corona Virginum" | "耶穌童貞女的冠冕" |
| `evening.office_hymn.verses.0.zh-hans` | "一、耶稣童贞荣耀冠冕，\n俯听我等屈膝祈祷，\n生于童贞圣母膝下，\n惟伊童贞亦得母荣." | "一、耶稣童贞女的冠冕，\n求主俯听我们祈祷，\n主由童贞圣母所生，\n我们尊崇圣母圣女." |
| `evening.office_hymn.verses.0.zh-hant` | "一、耶穌童貞榮耀冠冕，\n俯聽我等屈膝祈禱，\n生於童貞聖母膝下，\n惟伊童貞亦得母榮。" | "一、耶穌童貞女的冠冕，\n求主俯聽我們祈禱，\n主由童貞聖母所生，\n我們尊崇聖母聖女。" |
| `evening.office_hymn.verses.1.zh-hans` | "二、牧养徜徉百合花间，\n率领童贞圣洁歌团，\n慈爱赐下荣耀恩物，\n妆饰蒙选圣洁净配." | "二、百合丛中牧养我们，\n引领童贞女的诗班，\n主以慈爱赐下恩典，\n装饰蒙拣选的新娘." |
| `evening.office_hymn.verses.1.zh-hant` | "二、牧養徜徉百合花間，\n率領童貞聖潔歌團，\n慈愛賜下榮耀恩物，\n妝飾蒙選聖潔淨配。" | "二、百合叢中牧養我們，\n引領童貞女的詩班，\n主以慈愛賜下恩典，\n裝飾蒙揀選的新娘。" |
| `evening.office_hymn.verses.2.zh-hans` | "三、无论恩主圣足何往，\n童贞队列赞美相随；\n为祢献上甜美颂歌，\n欢欣踊跃紧随尊前." | "三、无论上主前往何方，\n贞女歌团赞美相随；\n为主献上甜美赞歌，\n欢欣踊跃跟随着主." |
| `evening.office_hymn.verses.2.zh-hant` | "三、無論恩主聖足何往，\n童貞隊列讚美相隨；\n為祢獻上甜美頌歌，\n歡欣踴躍緊隨尊前。" | "三、無論上主前往何方，\n貞女歌團讚美相隨；\n為主獻上甜美贊歌，\n歡欣踴躍跟隨著主。" |
| `evening.office_hymn.verses.3.zh-hans` | "四、恳求至慈至悲恩主，\n倾注恩典洁净感官；\n免受罪恶污秽沾染，\n为祢保持心地纯全." | "四、我们恳求慈悲恩主，\n以主恩典充满感官；\n保守我们远离罪污，\n心灵洁净归属于主." |
| `evening.office_hymn.verses.3.zh-hant` | "四、懇求至慈至悲恩主，\n傾注恩典潔淨感官；\n免受罪惡污穢沾染，\n為祢保持心地純全。" | "四、我們懇求慈悲恩主，\n以主恩典充滿感官；\n保守我們遠離罪污，\n心靈潔淨歸屬於主。" |
| `evening.office_hymn.versicle.leader.zh-hans` | "上帝必用脸上的光辉帮助她。" | "上帝必用面上的光辉帮助她." |
| `evening.office_hymn.versicle.leader.zh-hant` | "上帝必用臉上的光輝幫助她。" | "上帝必用面上的光輝幫助她。" |
| `evening.office_hymn.versicle.people.zh-hans` | "主在她里面，她不至动摇。" | "主在她里面，所以她必不动摇." |
| `evening.office_hymn.versicle.people.zh-hant` | "主在她裏面，她不至動搖。" | "主在她裏面，所以她必不動搖。" |
| `evening.psalm_antiphons.antiphons.0.en` | （原檔沒有此欄位） | "This is a wise virgin, ※ and one of the number of the prudent." |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "这是那位明智的贞女，※她是那聪明贞女当中的一位." | "这是那位明智的贞女，※她是那聪明贞女当中的一位。" |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "来吧，我所拣选的，※我要让她坐在我的宝座上." | "来吧，※我所拣选的，我要让她坐在我的宝座上." |
| `evening.psalm_antiphons.antiphons.3.zh-hant` | "來吧，我所揀選的，※我要讓她坐在我的寶座上。" | "來吧，※我所揀選的，我要讓她坐在我的寶座上。" |
| `evening.psalm_antiphons.antiphons.4.zh-hans` | "这就是那在耶路撒冷的女儿※中美貌秀丽的那一位." | "这就是※那在耶路撒冷的女儿中美貌秀丽的那一位." |
| `evening.psalm_antiphons.antiphons.4.zh-hant` | "這就是那在耶路撒冷的女兒※中美貌秀麗的那一位。" | "這就是※那在耶路撒冷的女兒中美貌秀麗的那一位。" |
| `evening.psalm_antiphons.lectionary_1943` | （無本日專用，現繼承右欄通用內容） | {"zh-hant": "這是那位明智的貞女，※她是那聰明貞女當中的一位。", "zh-hans": "这是那位明智的贞女，※她是那聪明贞女当中的一位.", "en": "This is a wise virgin, ※ and one of the number of the prudent."} |

### sanctorale_0901_giles.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。
- 所有祝文、選項標籤及頂層身分資料保留。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normal.zh-hans` | "我要把他好比一个聪明人，※把房子盖在磐石上。" | "我要把他好比一个聪明人，※把房子盖在磐石上." |
| `vigil.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.zh-hans` | "有福之人清早起来专心致志，归向那位创造他的主；他在至高者之前祈求，并张开他的嘴巴祷告，为自己的罪过而祈求。" | "有福之人清早起来专心致志，归向那位创造他的主；他在至高者之前祈求，并张开他的嘴巴祷告，为自己的罪过而祈求." |
| `vigil.office_hymn.title` | {"zh-hant": "Christe, pastorum Caput atque Princeps", "zh-hans": "Christe, pastorum Caput atque Princeps", "en": ""} | "Christe, pastorum Caput atque Princeps" |
| `vigil.office_hymn.verses.0.en` | "THIS the Confessor of the Lord, whose triumph\nNow all the faithful celebrate, with gladness\nErst on this feast-day merited to enter\nInto his glory." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.1.en` | "Saintly and prudent, modest in behavior,\nPeaceful and sober, chaste was he, and lowly,\nWhile that life's vigour, coursing through his members,\nQuickened his being." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.2.en` | "Sick ones of old time, to his tomb resorting,\nSorely by ailments manifold afflicted,\nOft-times have welcomed health and strength returning,\nAt his petition." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.en` | "Whence we in chorus gladly do him honor,\nChanting his praises with devout affection,\nThat in his merits we may have a portion,\nNow and forever." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.en` | "His be the glory, power, and salvation:\nWho over all things reigneth in the highest,\nEarth's mighty fabric ruling and directing,\nOnely and Trinal. Amen." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.zh-hans` | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主.阿们." | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。" |
| `vigil.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.leader.zh-hans` | "主爱了他，并装扮了他。" | "主爱了他，并装扮了他." |
| `vigil.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.people.zh-hans` | "给他穿上荣耀的外衣。" | "给他穿上荣耀的外衣." |
| `vigil.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `vigil.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `vigil.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `vigil.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.zh-hans` | "他们在上帝宝座前，昼夜在他殿中事奉他；那坐在宝座上的要用帐幕覆庇他们。" | "他们在上帝宝座前，昼夜在他殿中事奉他；那坐在宝座上的要用帐幕覆庇他们." |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传", "en": ""}, "source": {"zh-hant": "", "zh-hans": "", "en": ""}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。", "en": ""}, "paragraphs": [{"zh-hant": "神聖的賈爾斯院長是第八世紀最受愛戴的聖人之一，他是中世紀的人物，常被人呼求為殘疾者、乞丐和鐵匠的主保，因此被列入所謂的「十四救難聖人」之中。不過，到了第十世紀，人們彙編了一份關於當時流傳的，關於賈爾斯事蹟的文獻。據這份記載說，他出生於富裕之家，享盡奢華；年少時身強力壯，儀表出眾。後來，他因把自己的衣服送給一名乞丐而得到美名；但他愈來愈害怕奢華與聲望所帶來的誘惑。因此，他處置了自己的產業，逃到羅訥河口附近幽僻的森林中，在一座洞穴裡棲身，為了遠離眾人的稱譽，好與自己爭戰，尋求屬靈的剛強和上帝的恩眷。在孤居之中，他馴養了一隻小雌鹿，並主要靠牠的乳汁維持生活。有一天，幾名獵人帶著獵犬看見這怯生生的小獸，便追趕牠，直到牠消失在濃密的灌木叢中，獵犬便不肯再追。同樣的事在第二天、第三天又發生了。但這最後一次，獵人親自搜查灌木叢，發現後面有一個洞穴入口，便盲目地（或隨意地）向洞內射了一箭。當他們走近時，看見賈爾斯坐在那裡，身上被箭射中；但小雌鹿安然無恙，正依偎在他的膝間。獵人十分驚訝，想帶他離開接受照料；可是他懇求他們讓他獨自與上帝及小雌鹿同住。獵人離開後，他祈求上帝不要使自己完全恢復肉身的強健，反倒讓他常帶著身體的疾患，好從中得著屬靈的力量。他的名聲漸漸傳開，許多人前來向他學習敬虔之道。在他的指導下，人們在那裡建造住處，凡事親手勞作。於是，一所修道院和一座城鎮便在那裡建立起來；那城後來稱為「聖賈爾斯」。這位聖人在那裡作院長，直到安息歸天。", "zh-hans": "神圣的贾尔斯院长是第八世纪最受爱戴的圣人之一，他是中世纪的人物，常被人呼求为残疾者、乞丐和铁匠的主保，因此被列入所谓的「十四救难圣人」之中。不过，到了第十世纪，人们汇编了一份关于当时流传的，关于贾尔斯事迹的文献。据这份记载说，他出生于富裕之家，享尽奢华；年少时身强力壮，仪表出众。后来，他因把自己的衣服送给一名乞丐而得到美名；但他愈来愈害怕奢华与声望所带来的诱惑。因此，他处置了自己的产业，逃到罗讷河口附近幽僻的森林中，在一座洞穴里栖身，为了远离众人的称誉，好与自己争战，寻求属灵的刚强和上帝的恩眷。在孤居之中，他驯养了一只小雌鹿，并主要靠它的乳汁维持生活。有一天，几名猎人带着猎犬看见这怯生生的小兽，便追赶它，直到它消失在浓密的灌木丛中，猎犬便不肯再追。同样的事在第二天、第三天又发生了。但这最后一次，猎人亲自搜查灌木丛，发现后面有一个洞穴入口，便盲目地（或随意地）向洞内射了一箭。当他们走近时，看见贾尔斯坐在那里，身上被箭射中；但小雌鹿安然无恙，正依偎在他的膝间。猎人十分惊讶，想带他离开接受照料；可是他恳求他们让他独自与上帝及小雌鹿同住。猎人离开后，他祈求上帝不要使自己完全恢复肉身的强健，反倒让他常带着身体的疾患，好从中得着属灵的力量。他的名声渐渐传开，许多人前来向他学习敬虔之道。在他的指导下，人们在那里建造住处，凡事亲手劳作。于是，一所修道院和一座城镇便在那里建立起来；那城后来称为「圣贾尔斯」。这位圣人在那里作院长，直到安息归天。", "en": "The holy Abbot Giles, who was one of the best beloved Saints of the eighth century, was a man of middle ages, and was much invoked as the Patron of cripples, beggars, and blacksmiths; and therefore he came to be numbered among the so-called Fourteen Holy Helpers. But in the tenth century was compiled an account of what was then believed of him, wherein we are told that he was born to wealth and its luxuries, and was a vigorous youth, and well-favoured. And that, when he had gained fame for giving his clothes to a beggar, he began more and more to fear the temptations of luxury and popularity. For which reason he disposed of his estate, and fled to a cave, in the solitude of the woods near the mouth of the Rhone River, so that separated from the admiration of men, he might wrestle with himself, and gain spiritual vigour, and the favour of God. And there in his loneliness he made a pet of a little hind, on whose milk he largely depended for sustenance. Now it happened one day that certain huntsmen, with their dogs, saw the timid little beast, and pursued her till she disappeared in some thick bushes, whereupon the dogs refused to give further chase. Which same happened also on the second day, and again on the third. But this last time the huntsmen themselves searched the bushes, and saw behind them an entrance to a cave, wherein at a venture they shot an arrow. And when they drew near thereto, they saw Giles sitting, pierced with the shaft, but the hind safe, nestling between his knees. Whereupon they were amazed, and desired to carry Giles away, to be nursed. But he entreated them to leave him alone with God, and with his little hind. And after they had gone, he prayed God not to give him back his full physical vigour, but to leave him always an infirmity of the flesh, wherefrom to gain strength of spirit. And his fame grew, and many came to him to be taught the lore of godliness. And under his tutelage they built there an habitation, and they did all things with their own hands. Thus was founded both a monastery and a town, later called Saint-Gilles. And this holy man ruled as Abbot thereof till he went home to heaven."}]} | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.zh-hans` | "义人栽种在主的殿前，发旺在我们上帝院里，※让我们在他的圣日欢欣庆贺。" | "义人栽种在主的殿前，发旺在我们上帝院里，※让我们在他的圣日欢欣庆贺." |
| `morning.invitatory.texts.1.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.1.zh-hans` | "主是精修者的君王，※我们当来俯伏敬拜。" | "主是精修者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory_hymn.title` | {"zh-hant": "Iste Confessor", "zh-hans": "Iste Confessor", "en": ""} | "Iste Confessor" |
| `morning.invitatory_hymn.verses.0.en` | "THIS the Confessor of the Lord, whose triumph\nNow all the faithful celebrate, with gladness\nErst on this feast-day merited to enter\nInto his glory." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.1.en` | "Saintly and prudent, modest in behavior,\nPeaceful and sober, chaste was he, and lowly,\nWhile that life's vigour, coursing through his members,\nQuickened his being." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.2.en` | "Sick ones of old time, to his tomb resorting,\nSorely by ailments manifold afflicted,\nOft-times have welcomed health and strength returning,\nAt his petition." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.en` | "Whence we in chorus gladly do him honor,\nChanting his praises with devout affection,\nThat in his merits we may have a portion,\nNow and forever." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.4.en` | "His be the glory, power, and salvation:\nWho over all things reigneth in the highest,\nEarth's mighty fabric ruling and directing,\nOnely and Trinal. Amen." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.4.zh-hans` | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主.阿们." | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。" |
| `morning.office_hymn.title` | {"zh-hant": "Iesu, corona celsior", "zh-hans": "Iesu, corona celsior", "en": ""} | "Iesu, corona celsior" |
| `morning.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、耶稣基督天府冠冕，\n永恒至高真理上主；\n嘉纳主之精修圣者，\n偕同诸圣永享荣华。" | "一、耶稣基督天府冠冕，\n永恒至高真理上主；\n嘉纳主之精修圣者，\n偕同诸圣永享荣华." |
| `morning.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.1.zh-hans` | "二、俯听我众卑微恳求，\n借其代祷蒙主庇护；\n涤除我等诸般罪愆，\n悉数斩断罪恶桎梏。" | "二、俯听我众卑微恳求，\n藉其代祷蒙主庇护；\n涤除我等诸般罪愆，\n悉数斩断罪恶桎梏." |
| `morning.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.2.zh-hans` | "三、岁月周环时光流转，\n荣耀佳节今朝重临；\n主之忠仆脱离尘躯，\n荣登高天觐见主面。" | "三、岁月周环时光流转，\n荣耀佳节今朝重临；\n主之忠仆脱离尘躯，\n荣登高天觐见主面." |
| `morning.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.3.zh-hans` | "四、视此尘世虚妄欢乐，\n浮华名利皆如尘土；\n鄙弃诸般世俗污秽，\n终获天府凯旋奇乐。" | "四、视此尘世虚妄欢乐，\n浮华名利皆如尘土；\n鄙弃诸般世俗污秽，\n终获天府凯旋奇乐." |
| `morning.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.4.zh-hans` | "五、恒常宣认主为君王，\n仰赖基督宏恩大德；\n狂傲仇敌践踏足下，\n奋勇击退众魔魑魅。" | "五、恒常宣认主为君王，\n仰赖基督宏恩大德；\n狂傲仇敌践踏足下，\n奋勇击退众魔魑魅." |
| `morning.office_hymn.verses.5.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.5.zh-hans` | "六、信德昭彰美名远播，\n坚定恒常宣信其主；\n严守斋戒克己修身，\n终获高天灵粮滋养。" | "六、信德昭彰美名远播，\n坚定恒常宣信其主；\n严守斋戒克己修身，\n终获高天灵粮滋养." |
| `morning.office_hymn.verses.6.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.6.zh-hans` | "七、洪恩广被慈悲上主，\n俯首叩拜至尊天颜；\n念此忠仆宣信之功，\n恳求涂抹我众罪债。" | "七、洪恩广被慈悲上主，\n俯首叩拜至尊天颜；\n念此忠仆宣信之功，\n恳求涂抹我众罪债." |
| `morning.office_hymn.verses.7.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.zh-hans` | "主引导义人走入正路，" | "主引导义人走入正路." |
| `morning.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.people.zh-hans` | "将上帝的国指示给他。" | "将上帝的国指示给他." |
| `morning.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `morning.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `morning.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `morning.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal.zh-hans` | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求。" | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求." |
| `evening.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.zh-hans` | "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪。" | "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪." |
| `evening.office_hymn.title` | {"zh-hant": "Jesu, sacerdotum decus", "zh-hans": "Jesu, sacerdotum decus", "en": ""} | "Jesu, sacerdotum decus" |
| `evening.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美。" | "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美." |
| `evening.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.1.zh-hans` | "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日。" | "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日." |
| `evening.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.2.zh-hans` | "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中。" | "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中." |
| `evening.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.3.zh-hans` | "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽。" | "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽." |
| `evening.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.zh-hans` | "义人的口谈论智慧；" | "义人的口谈论智慧." |
| `evening.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.zh-hans` | "他的舌头讲说公平。" | "他的舌头讲说公平." |
| `evening.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `evening.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `evening.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `evening.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |

### sanctorale_0902_stephen_of_hungary.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。
- 所有祝文、選項標籤及頂層身分資料保留。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normal.zh-hans` | "我要把他好比一个聪明人，※把房子盖在磐石上。" | "我要把他好比一个聪明人，※把房子盖在磐石上." |
| `vigil.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.zh-hans` | "有福之人清早起来专心致志，归向那位创造他的主；他在至高者之前祈求，并张开他的嘴巴祷告，为自己的罪过而祈求。" | "有福之人清早起来专心致志，归向那位创造他的主；他在至高者之前祈求，并张开他的嘴巴祷告，为自己的罪过而祈求." |
| `vigil.office_hymn.title` | {"zh-hant": "Christe, pastorum Caput atque Princeps", "zh-hans": "Christe, pastorum Caput atque Princeps", "en": ""} | "Christe, pastorum Caput atque Princeps" |
| `vigil.office_hymn.verses.0.en` | "THIS the Confessor of the Lord, whose triumph\nNow all the faithful celebrate, with gladness\nErst on this feast-day merited to enter\nInto his glory." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.1.en` | "Saintly and prudent, modest in behavior,\nPeaceful and sober, chaste was he, and lowly,\nWhile that life's vigour, coursing through his members,\nQuickened his being." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.2.en` | "Sick ones of old time, to his tomb resorting,\nSorely by ailments manifold afflicted,\nOft-times have welcomed health and strength returning,\nAt his petition." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.en` | "Whence we in chorus gladly do him honor,\nChanting his praises with devout affection,\nThat in his merits we may have a portion,\nNow and forever." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.en` | "His be the glory, power, and salvation:\nWho over all things reigneth in the highest,\nEarth's mighty fabric ruling and directing,\nOnely and Trinal. Amen." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.zh-hans` | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主.阿们." | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。" |
| `vigil.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.leader.zh-hans` | "主爱了他，并装扮了他。" | "主爱了他，并装扮了他." |
| `vigil.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.people.zh-hans` | "给他穿上荣耀的外衣。" | "给他穿上荣耀的外衣." |
| `vigil.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `vigil.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `vigil.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `vigil.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.zh-hans` | "他们在上帝宝座前，昼夜在他殿中事奉他；那坐在宝座上的要用帐幕覆庇他们。" | "他们在上帝宝座前，昼夜在他殿中事奉他；那坐在宝座上的要用帐幕覆庇他们." |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传", "en": ""}, "source": {"zh-hant": "", "zh-hans": "", "en": ""}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。", "en": ""}, "paragraphs": [{"zh-hant": "司提反，匈牙利人的國王，生於九七五年；那時，這個剽悍的民族才開始稍微認識基督信仰。他的父親蓋薩公爵原是異教徒；但他的母親、波蘭的阿德萊德，生長於基督信仰之中。在她的影響下，蓋薩終於領受洗禮；司提反約十歲時，也與父親一同受洗。這少年尚未深陷於異教的習俗，遂成為一位虔誠而深明教理的基督徒。二十歲時，他迎娶了吉塞拉——聖亨利皇帝的姊妹；兩年後，他繼承父親，作了匈牙利人的公爵。當時他的人民與鄰邦和平相處；司提反便把握這機會，使他們脫離野蠻的風俗。因此，他延請教師和領袖前來，引導人民歸向上帝。", "zh-hans": "司提反，匈牙利人的国王，生于九七五年；那时，这个剽悍的民族才开始稍微认识基督信仰。他的父亲盖萨公爵原是异教徒；但他的母亲、波兰的阿德莱德，生长于基督信仰之中。在她的影响下，盖萨终于领受洗礼；司提反约十岁时，也与父亲一同受洗。这少年尚未深陷于异教的习俗，遂成为一位虔诚而深明教理的基督徒。二十岁时，他迎娶了吉塞拉——圣亨利皇帝的姊妹；两年后，他继承父亲，作了匈牙利人的公爵。当时他的人民与邻邦和平相处；司提反便把握这机会，使他们脱离野蛮的风俗。因此，他延请教师和领袖前来，引导人民归向上帝。", "en": "STEPHEN, King of the Hungarians, was born in 975, at a time when those fierce folk were beginning to learn somewhat of Christianity. His father, the Duke Geza, was a pagan, but his mother, Adelaide of Poland, was born and brought up in the Faith. Through her influence Geza was finally baptized, along with his son Stephen, when the latter was about ten years old. The lad was therefore not yet fixed in pagan ways, and became a devout and knowledgeable Christian. At the age of twenty he married Gisela, sister to Saint Henry the Emperor, and two years later succeeded his father as Duke of the Hungarians. At that time his people were at peace with their neighbours, and Stephen seized upon the opportunity to raise them out of their barbarous ways. Wherefore he brought in teachers and leaders to bring them to God."}, {"zh-hant": "他隨即堅決致力於根除民間的一切偶像崇拜，並抑制各樣惡習。他又建立了一套完整的政府與司法行政制度，制定成文法典。因此，他既是匈牙利教會的創建者，也是匈牙利國家的奠基者；故此，人常稱他為「匈牙利人的使徒」。他從教宗領受「匈牙利國王」的稱號，也獲賜那頂著名的王冠；後世的繼承者向來都用這王冠加冕。他興建許多教堂、修道院和學校。為鼓勵人民前往基督教虔敬與文化的重要中心朝聖，據說他甚至在遙遠的羅馬、耶路撒冷和君士坦丁堡設立旅舍，以供他們使用。他設立了格蘭總主教區及另外十個教區。他愛護貧窮卑微的人；為確知他們得到應有的公義，他常常化裝混在民眾中間。有一次，他竟被自己原本要去救濟的人毆打並搶劫；當時他對榮福聖母說：「看哪，這些屬於你聖子的人，竟如此報答我！」", "zh-hans": "他随即坚决致力于根除民间的一切偶像崇拜，并抑制各样恶习。他又建立了一套完整的政府与司法行政制度，制定成文法典。因此，他既是匈牙利教会的创建者，也是匈牙利国家的奠基者；故此，人常称他为「匈牙利人的使徒」。他从教宗领受「匈牙利国王」的称号，也获赐那顶著名的王冠；后世的继承者向来都用这王冠加冕。他兴建许多教堂、修道院和学校。为鼓励人民前往基督教虔敬与文化的重要中心朝圣，据说他甚至在遥远的罗马、耶路撒冷和君士坦丁堡设立旅舍，以供他们使用。他设立了格兰总主教区及另外十个教区。他爱护贫穷卑微的人；为确知他们得到应有的公义，他常常化装混在民众中间。有一次，他竟被自己原本要去救济的人殴打并抢劫；当时他对荣福圣母说：「看哪，这些属于你圣子的人，竟如此报答我！」", "en": "He then set himself sternly to extirpate all idolatry amongst them, and to repress various vices. He organized also a complete system for the administration of government and justice, and set up a code of written laws. Thus was he founder alike of the Church and the State of Hungary; wherefore he is often called the Apostle of the Hungarians. He received from the Pope the title of King of Hungary, and also the famous crown wherewith his successors were wont to be crowned. He built many churches, monasteries, and schools. And to encourage his people in making pilgrimages to the great centres of Christian devotion and culture, it is believed that he established hospices for their benefit, as far away as Rome, Jerusalem, and Constantinople. It was he that set up the Archbishoprick of Gran and ten other Sees. He loved the poor and lowly, and to assure himself that they were receiving due justice, he often went amongst them in disguise. And thus once he was beaten and robbed by the very ones to whose succour he had come: at which time he said to our blessed Mother: “See how I am rewarded by these folk who belong to thy Son!”"}, {"zh-hant": "然而，和平只能偶爾維持；民間常有叛亂，也多有戰事。他晚年的哀傷，既因愛子埃默里克去世，也因家族中有人為繼承王位而陰謀紛爭。這些朝臣曾企圖謀殺他，他卻赦免他們；因為他不但有王者的胸襟，也有基督般的心腸。他愛上帝，也敬愛童貞聖母；他為尊崇聖母建造了一座極宏偉的教堂，並立她為匈牙利的主保。作為報答，這位聖母在一○三八年、他六十三歲時、聖母升天節那日，接他進入天鄉。匈牙利人效法這位聖王，稱該節日為「大聖母日」。不過，自一六八六年以來，他的慶日一直定在九月二日；因為據信，就在這一天，藉著他的代求，匈牙利國王兼神聖羅馬帝國皇帝利奧波德一世的軍隊大勝土耳其人，收復了布達城；聖司提反的聖髑先前已長久安奉於上述的聖母堂之中。", "zh-hans": "然而，和平只能偶尔维持；民间常有叛乱，也多有战事。他晚年的哀伤，既因爱子埃默里克去世，也因家族中有人为继承王位而阴谋纷争。这些朝臣曾企图谋杀他，他却赦免他们；因为他不但有王者的胸襟，也有基督般的心肠。他爱上帝，也敬爱童贞圣母；他为尊崇圣母建造了一座极宏伟的教堂，并立她为匈牙利的主保。作为报答，这位圣母在一○三八年、他六十三岁时、圣母升天节那日，接他进入天乡。匈牙利人效法这位圣王，称该节日为「大圣母日」。不过，自一六八六年以来，他的庆日一直定在九月二日；因为据信，就在这一天，藉着他的代求，匈牙利国王兼神圣罗马帝国皇帝利奥波德一世的军队大胜土耳其人，收复了布达城；圣司提反的圣髑先前已长久安奉于上述的圣母堂之中。", "en": "But peace could be general only at intervals: there were rebellions against him, and much fighting. And his last years were saddened by the death of his good son Emeric, and by the intrigues of some of his family as to succession to his throne. These courtiers attempted to murder him, and he pardoned them, for he was not only kingly but Christly. He loved God, and the Virgin Mother, and built in her honour a very great church, and made her the Patroness of Hungary. In return, the same Virgin received him into heaven, in 1038, at the age of sixty-three, on the Feast of her Assumption, which the Hungarians, after the holy King’s example, call the Great Lady’s Day. But ever since 1686, his feast hath been kept on September the second. For on this day, through his intercession, as it is believed, a great victory was gained over the Turks by the army of Leopold I, King of Hungary and Emperor of the Holy Roman Empire, and the City of Buda was then regained, where holy Stephen’s relics had long been enshrined in the aforesaid Church of Our Lady."}]} | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.zh-hans` | "义人栽种在主的殿前，发旺在我们上帝院里，※让我们在他的圣日欢欣庆贺。" | "义人栽种在主的殿前，发旺在我们上帝院里，※让我们在他的圣日欢欣庆贺." |
| `morning.invitatory.texts.1.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.1.zh-hans` | "主是精修者的君王，※我们当来俯伏敬拜。" | "主是精修者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory_hymn.title` | {"zh-hant": "Iste Confessor", "zh-hans": "Iste Confessor", "en": ""} | "Iste Confessor" |
| `morning.invitatory_hymn.verses.0.en` | "THIS the Confessor of the Lord, whose triumph\nNow all the faithful celebrate, with gladness\nErst on this feast-day merited to enter\nInto his glory." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.1.en` | "Saintly and prudent, modest in behavior,\nPeaceful and sober, chaste was he, and lowly,\nWhile that life's vigour, coursing through his members,\nQuickened his being." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.2.en` | "Sick ones of old time, to his tomb resorting,\nSorely by ailments manifold afflicted,\nOft-times have welcomed health and strength returning,\nAt his petition." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.en` | "Whence we in chorus gladly do him honor,\nChanting his praises with devout affection,\nThat in his merits we may have a portion,\nNow and forever." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.4.en` | "His be the glory, power, and salvation:\nWho over all things reigneth in the highest,\nEarth's mighty fabric ruling and directing,\nOnely and Trinal. Amen." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.4.zh-hans` | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主.阿们." | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。" |
| `morning.office_hymn.title` | {"zh-hant": "Iesu, corona celsior", "zh-hans": "Iesu, corona celsior", "en": ""} | "Iesu, corona celsior" |
| `morning.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、耶稣基督天府冠冕，\n永恒至高真理上主；\n嘉纳主之精修圣者，\n偕同诸圣永享荣华。" | "一、耶稣基督天府冠冕，\n永恒至高真理上主；\n嘉纳主之精修圣者，\n偕同诸圣永享荣华." |
| `morning.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.1.zh-hans` | "二、俯听我众卑微恳求，\n借其代祷蒙主庇护；\n涤除我等诸般罪愆，\n悉数斩断罪恶桎梏。" | "二、俯听我众卑微恳求，\n藉其代祷蒙主庇护；\n涤除我等诸般罪愆，\n悉数斩断罪恶桎梏." |
| `morning.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.2.zh-hans` | "三、岁月周环时光流转，\n荣耀佳节今朝重临；\n主之忠仆脱离尘躯，\n荣登高天觐见主面。" | "三、岁月周环时光流转，\n荣耀佳节今朝重临；\n主之忠仆脱离尘躯，\n荣登高天觐见主面." |
| `morning.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.3.zh-hans` | "四、视此尘世虚妄欢乐，\n浮华名利皆如尘土；\n鄙弃诸般世俗污秽，\n终获天府凯旋奇乐。" | "四、视此尘世虚妄欢乐，\n浮华名利皆如尘土；\n鄙弃诸般世俗污秽，\n终获天府凯旋奇乐." |
| `morning.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.4.zh-hans` | "五、恒常宣认主为君王，\n仰赖基督宏恩大德；\n狂傲仇敌践踏足下，\n奋勇击退众魔魑魅。" | "五、恒常宣认主为君王，\n仰赖基督宏恩大德；\n狂傲仇敌践踏足下，\n奋勇击退众魔魑魅." |
| `morning.office_hymn.verses.5.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.5.zh-hans` | "六、信德昭彰美名远播，\n坚定恒常宣信其主；\n严守斋戒克己修身，\n终获高天灵粮滋养。" | "六、信德昭彰美名远播，\n坚定恒常宣信其主；\n严守斋戒克己修身，\n终获高天灵粮滋养." |
| `morning.office_hymn.verses.6.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.6.zh-hans` | "七、洪恩广被慈悲上主，\n俯首叩拜至尊天颜；\n念此忠仆宣信之功，\n恳求涂抹我众罪债。" | "七、洪恩广被慈悲上主，\n俯首叩拜至尊天颜；\n念此忠仆宣信之功，\n恳求涂抹我众罪债." |
| `morning.office_hymn.verses.7.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.zh-hans` | "主引导义人走入正路，" | "主引导义人走入正路." |
| `morning.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.people.zh-hans` | "将上帝的国指示给他。" | "将上帝的国指示给他." |
| `morning.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `morning.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `morning.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `morning.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal.zh-hans` | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求。" | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求." |
| `evening.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.zh-hans` | "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪。" | "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪." |
| `evening.office_hymn.title` | {"zh-hant": "Jesu, sacerdotum decus", "zh-hans": "Jesu, sacerdotum decus", "en": ""} | "Jesu, sacerdotum decus" |
| `evening.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美。" | "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美." |
| `evening.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.1.zh-hans` | "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日。" | "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日." |
| `evening.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.2.zh-hans` | "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中。" | "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中." |
| `evening.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.3.zh-hans` | "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽。" | "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽." |
| `evening.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.zh-hans` | "义人的口谈论智慧；" | "义人的口谈论智慧." |
| `evening.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.zh-hans` | "他的舌头讲说公平。" | "他的舌头讲说公平." |
| `evening.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `evening.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `evening.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `evening.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |

### sanctorale_0911_protus_and_hyacinth.json

- 通用：`common_martyrs_outside_easter`（多位殉道者通用（復活期外）.json）。
- 移除並繼承：`morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。
- 所有祝文、選項標籤及頂層身分資料保留。
- 保留原先缺失／停用狀態：`vigil.benedictus_antiphon.normals`, `morning.invitatory.texts`, `evening.benedictus_antiphon.normals`。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal` | {"zh-hant": "來吧，※耶路撒冷的女兒，請看，殉道者，以及主在這隆重喜悅的日子上，給他們戴上的冠冕，哈利路亞。", "zh-hans": "来吧，※耶路撒冷的女儿，请看，殉道者，以及主在这隆重喜悦的日子上，给他们戴上的冠冕，哈利路亚。", "en": ""} | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normals` | （原檔沒有此欄位） | [{"zh-hant": "追隨基督的眾聖徒在天國歡慶，※他們追隨基督的腳蹤，為愛祂而傾流了鮮血，因此永遠與基督為王。", "zh-hans": "追随基督的众圣徒在天国欢庆，※他们追随基督的脚踪，为爱祂而倾流了鲜血，因此永远与基督为王."}, {"zh-hant": "這些聖者，※因愛上帝而輕視了世人的威脅；神聖的殉道者們，與天使在永恆的國中歡欣喜樂；聖民之死何等寶貴，他們永遠侍立在主面前，與主永不分離。", "zh-hans": "这些圣者，※因爱上帝而轻视了世人的威胁；神圣的殉道者们，与天使在永恒的国中欢欣喜乐；圣民之死何等宝贵，他们永远侍立在主面前，与主永不分离."}] |
| `vigil.bible_sentences.0.reference.en` | "(2 Esdras.ii.45.)" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.reference.zh-hans` | "（以斯拉补编下卷 2:45）" | "（启示录 7:14）" |
| `vigil.bible_sentences.0.reference.zh-hant` | "（以斯拉補編下卷 2:45）" | "（啟示錄 7:14）" |
| `vigil.bible_sentences.0.text.en` | "THESE be they that have put off the mortal clothing, and put on the immortal, and have confessed the name of God: now are they crowned, and receive palms." | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.zh-hans` | "这些人是脱了那必死的衣裳，穿上那不死的。他们宣认了上帝的名，现在他们戴上冠冕，又得棕树枝。" | "这些人是从大患难中出来的，他们曾用羔羊的血把衣裳洗得洁白." |
| `vigil.bible_sentences.0.text.zh-hant` | "這些人是脫了那必死的衣裳，穿上那不死的。他們宣認了上帝的名，現在他們戴上冠冕，又得棕樹枝。" | "這些人是從大患難中出來的，他們曾用羔羊的血把衣裳洗得潔白。" |
| `vigil.office_hymn.title` | {"zh-hant": "Sanctorum meritis inclyta gaudia", "zh-hans": "Sanctorum meritis inclyta gaudia", "en": ""} | "諸聖功德永受讚頌" |
| `vigil.office_hymn.verses.0.en` | "THE merits of the Saints, Blessèd for evermore, \nTheir love that never faints, The toils they bravely bore: \nFor these the Church today Pours forth her joyous lay, \nThese victors win the noblest bay." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.0.zh-hans` | "一、诸圣功勋可颂，永蒙福乐无穷；\n爱心永不衰歇，勇忍艰劳不辞。\n教会今朝为此，欢然歌咏颂扬；\n得胜圣徒荣冠高戴。" | "一、诸圣功德永受赞颂，\n爱心不灭永坚强勇，\n勇敢忍受诸般艰辛，\n教会今献喜乐颂歌，\n得胜者赢最高冠冕，\n荣耀桂冠永辉煌光." |
| `vigil.office_hymn.verses.0.zh-hant` | "一、諸聖功勳可頌，永蒙福樂無窮；\n愛心永不衰歇，勇忍艱勞不辭。\n教會今朝為此，歡然歌詠頌揚；\n得勝聖徒榮冠高戴。" | "一、諸聖功德永受讚頌，\n愛心不滅永堅強勇，\n勇敢忍受諸般艱辛，\n教會今獻喜樂頌歌，\n得勝者贏最高冠冕，\n榮耀桂冠永輝煌光。" |
| `vigil.office_hymn.verses.1.en` | "They whom this world of ill, While it yet held, abhorred; \nIts withering flow'rs that still They spurned withione faccord:\nThey knew them short-lived all, And followed at thy call, \nKing Jesu, to thine heav'nly hall. " | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.1.zh-hans` | "二、邪世尚据人间，曾憎恶诸圣徒；\n凋零花朵仍开，齐心轻蔑弃绝。\n深知万有短暂，遂应主慈声召；\n君王耶稣召入天庭。" | "二、邪世曾憎恶诸圣徒，\n凋零花朵不屑顾看，\n万物短暂心深知晓，\n回应耶稣召唤声音，\n天国殿堂永享安居，\n至圣君王恩典无穷." |
| `vigil.office_hymn.verses.1.zh-hant` | "二、邪世尚據人間，曾憎惡諸聖徒；\n凋零花朵仍開，齊心輕蔑棄絕。\n深知萬有短暫，遂應主慈聲召；\n君王耶穌召入天庭。" | "二、邪世曾憎惡諸聖徒，\n凋零花朵不屑顧看，\n萬物短暫心深知曉，\n回應耶穌召喚聲音，\n天國殿堂永享安居，\n至聖君王恩典無窮。" |
| `vigil.office_hymn.verses.2.en` | "For thee all pangs they bare, Fury and mortal hate;\nThe cruèl scourge to tear, The hook to lacerate:\nBut vain their foes' intent For, every torment spent,\nTheir valiant spirits stood unbent." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.2.zh-hans` | "三、为主忍受诸苦，狂怒死亡仇恨；\n酷鞭撕裂其身，铁钩割伤其肉。\n仇敌徒劳无功，诸般酷刑既尽；\n英魂坚立终不屈挠。" | "三、为主忍受诸多苦难，\n狂怒仇恨齐临身上，\n残鞭撕裂铁钩伤害，\n敌意徒然苦尽时刻，\n勇敢精神永不屈服，\n坚毅心志立如山岳." |
| `vigil.office_hymn.verses.2.zh-hant` | "三、為主忍受諸苦，狂怒死亡仇恨；\n酷鞭撕裂其身，鐵鉤割傷其肉。\n仇敵徒勞無功，諸般酷刑既盡；\n英魂堅立終不屈撓。" | "三、為主忍受諸多苦難，\n狂怒仇恨齊臨身上，\n殘鞭撕裂鐵鉤傷害，\n敵意徒然苦盡時刻，\n勇敢精神永不屈服，\n堅毅心志立如山岳。" |
| `vigil.office_hymn.verses.3.en` | "Like sheep their blood they poured, And without groan or tear;\nThey bent before the sword, For that their King most dear;\nTheir souls, serenely blest, In patience they possessed,\nAnd looked in hope towards their rest." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.zh-hans` | "四、如羊倾流鲜血，无呻吟亦无泪；\n俯首在剑刃前，皆为至爱君王。\n灵魂安然蒙福，忍耐持守其灵；\n盼望安息欣然仰望。" | "四、如羊流血无声息叹，\n无痛无泪跪剑前方，\n皆为至爱君王缘故，\n灵魂安详得享福乐，\n忍耐等候持守盼望，\n仰望安息到达永恒." |
| `vigil.office_hymn.verses.3.zh-hant` | "四、如羊傾流鮮血，無呻吟亦無淚；\n俯首在劍刃前，皆為至愛君王。\n靈魂安然蒙福，忍耐持守其靈；\n盼望安息欣然仰望。" | "四、如羊流血無聲息嘆，\n無痛無淚跪劍前方，\n皆為至愛君王緣故，\n靈魂安詳得享福樂，\n忍耐等候持守盼望，\n仰望安息到達永恆。" |
| `vigil.office_hymn.verses.4.en` | "What tongue may here declare, Fancy or thought descry,\nThe joys thou dost prepare For these thy Saints on high?\nEmpurpled in the flood Of their victorious blood,\nThey won the laurel from their God." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.zh-hans` | "五、何舌能宣说尽，何思能够窥知？\n主为诸圣预备，高天喜乐何深！\n浸染凯旋鲜血，披上紫红荣光；\n从上帝手赢得桂冠。" | "五、何言能述天堂喜乐，\n何思能知主爱恩情，\n为圣徒备高深福乐，\n浸染得胜血流中间，\n上主亲赐桂冠戴头，\n荣耀冠冕永远辉煌." |
| `vigil.office_hymn.verses.4.zh-hant` | "五、何舌能宣說盡，何思能夠窺知？\n主為諸聖預備，高天喜樂何深！\n浸染凱旋鮮血，披上紫紅榮光；\n從上帝手贏得桂冠。" | "五、何言能述天堂喜樂，\n何思能知主愛恩情，\n為聖徒備高深福樂，\n浸染得勝血流中間，\n上主親賜桂冠戴頭，\n榮耀冠冕永遠輝煌。" |
| `vigil.office_hymn.verses.5.en` | "To thee, O Lord most high, One in Three Persons still, \nTo pardon us we cry, And to preserve from ill:\nHere give thy servants peace, Hereafter glad release,\nAnd pleasures that shall never cease. Amen." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.5.zh-hans` | "六、至高上主三一，求赦我众罪愆，\n又保守免诸恶；今赐仆人平安，\n来世欢然解脱，永享无尽喜乐，\n永享无穷不息福乐。阿们。" | "六、至高上主三一上帝，\n求赐赦罪保守平安，\n今赐仆人享受和平，\n来世欢欣得到释放，\n永恒喜乐永无穷尽，\n颂赞荣耀永不息止。阿们。" |
| `vigil.office_hymn.verses.5.zh-hant` | "六、至高上主三一，求赦我眾罪愆，\n又保守免諸惡；今賜僕人平安，\n來世歡然解脫，永享無盡喜樂，\n永享無窮不息福樂。阿們。" | "六、至高上主三一上帝，\n求賜赦罪保守平安，\n今賜僕人享受和平，\n來世歡欣得到釋放，\n永恆喜樂永無窮盡，\n頌讚榮耀永不息止。阿們。" |
| `vigil.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.leader.zh-hans` | "你们忧愁，哈利路亚。" | "你们善人应该因主欢乐，" |
| `vigil.office_hymn.versicle.leader.zh-hant` | "你們憂愁，哈利路亞。" | "你們善人應該因主歡樂，" |
| `vigil.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.people.zh-hans` | "将变为喜乐，哈利路亚。" | "正直人赞美祂是理所应该的." |
| `vigil.office_hymn.versicle.people.zh-hant` | "將變為喜樂，哈利路亞。" | "正直人讚美祂是理所應該的。" |
| `vigil.psalm_antiphons.antiphons.0.en` | "Thy Saints, O Lord, shall flourish like the lily, alleluia; ※and shall be even as the odour of balsam before thee, alleluia." | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "主的圣徒必如百合花开放，※哈利路亚；他们必如香膏的馨香立于主面前，哈利路亚。" | "这些圣人历尽艰苦，※使他们在平安之中得到了殉道的棕榈枝." |
| `vigil.psalm_antiphons.antiphons.0.zh-hant` | "主的聖徒必如百合花开放，※哈利路亞；他們必如香膏的馨香立於主面前，哈利路亞。" | "這些聖人歷盡艱苦，※使他們在平安之中得到了殉道的棕櫚枝。" |
| `vigil.psalm_antiphons.antiphons.1.en` | "In the heavenly kingdom † the Blessed have their dwelling-place, alleluia; ※and their rest for ever and ever, alleluia." | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "天国是诸圣的居所，※哈利路亚，他们要永远安息，哈利路亚。" | "这些圣者手持棕树枝※来到了天国，他们堪当由上帝手中接受荣耀的冠冕." |
| `vigil.psalm_antiphons.antiphons.1.zh-hant` | "天國是諸聖的居所，※哈利路亞，他們要永遠安息，哈利路亞。" | "這些聖者手持棕樹枝※來到了天國，他們堪當由上帝手中接受榮耀的冠冕。" |
| `vigil.psalm_antiphons.antiphons.2.en` | "Within the veil + thy blessed Saints, O Lord, ※continually do cry, alleluia, alleluia, alleluia." | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "主的诸圣在帷幕内高呼：※哈利路亚，哈利路亚，哈利路亚。" | "圣者们的身体※虽被安葬于平安之中，他们的名永存不朽." |
| `vigil.psalm_antiphons.antiphons.2.zh-hant` | "主的諸聖在帷幕內高呼：※哈利路亞，哈利路亞，哈利路亞。" | "聖者們的身體※雖被安葬於平安之中，他們的名永存不朽。" |
| `vigil.psalm_antiphons.antiphons.3.en` | "O ye spirits + and souls of the righteous, ※sing ye praise to the Lord our God, alleluia, alleluia." | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "义人的灵魂，※请歌唱赞美我们的上帝，哈利路亚，哈利路亚。" | "主的殉道者阿，※请赞颂上主直到永远." |
| `vigil.psalm_antiphons.antiphons.3.zh-hant` | "義人的靈魂，※請歌唱讚美我們的上帝，哈利路亞，哈利路亞。" | "主的殉道者阿，※請讚頌上主直到永遠。" |
| `vigil.psalm_antiphons.antiphons.4.en` | "Then shall the righteous † shine forth as the sun ※in the presence of God, alleluia." | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "义人要在上帝台前发出光来，※像太阳一样。哈利路亚." | "殉道者的歌咏团，※请在至高的天上赞美主." |
| `vigil.psalm_antiphons.antiphons.4.zh-hant` | "義人要在上帝台前發出光來，※像太陽一樣。哈利路亞。" | "殉道者的歌詠團，※請在至高的天上讚美主。" |
| `vigil.psalm_antiphons.lectionary_1943.en` | "The Saints through faith subdued kingdoms, they wrought righteousness, they obtained the promises." | "The Saints through faith ※subdued kingdoms, they wrought righteousness, they obtained the promises." |
| `vigil.psalm_antiphons.lectionary_1943.zh-hans` | "诸圣藉着信，制伏了敌国，行了公义，得了应许。" | "诸圣藉着信，※制伏了敌国，行了公义，得了应许。" |
| `vigil.psalm_antiphons.lectionary_1943.zh-hant` | "諸聖藉著信，制伏了敵國，行了公義，得了應許。" | "諸聖藉著信，※制伏了敵國，行了公義，得了應許。" |
| `morning.ascension_office_hymn` | {"title": {"zh-hant": "榮耀殉道圣者之君", "zh-hans": "荣耀殉道圣者之君", "en": ""}, "verses": [{"zh-hant": "一、榮耀殉道圣者之君，\n精修圣人以主為冠；\n引領捨棄世俗歡樂，\n邁向天國光輝之日。", "zh-hans": "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日。", "en": ""}, {"zh-hant": "二、救主垂憐傾聽我們，\n我眾祈禱上達於天；\n數算他們得勝之時，\n赦免我們所犯之罪。", "zh-hans": "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪。", "en": ""}, {"zh-hant": "三、殉道者因你而得勝，\n精修者從你得恩典；\n助我克服罪恶慾望，\n好使我們获得寬恕。", "zh-hans": "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕。", "en": ""}, {"zh-hant": "四、願主作我喜樂護衛，\n主是我們至大賞賜；\n願主永遠作我榮耀，\n為我永恆不朽誇耀。", "zh-hans": "四、愿主作我喜乐护卫，\n主是我们至大赏赐；\n愿主永远作我荣耀，\n为我永恒不朽夸耀。", "en": ""}, {"zh-hant": "五、今日升上群星之主，\n我們獻上一切榮耀；\n永恆榮耀歸於聖父，\n聖靈與你同享尊崇。阿們。", "zh-hans": "五、今日升上群星之主，\n我们献上一切荣耀；\n永恒荣耀归于圣父，\n圣灵与你同享尊崇。阿们。", "en": ""}], "versicle": {"leader": {"zh-hant": "你們善人應該因主歡樂，哈利路亞。", "zh-hans": "你们善人应该因主欢乐，哈利路亚。", "en": "Rejoice in the Lord, ye righteous, alleluia."}, "people": {"zh-hant": "正直人讚美祂是理所應該的。哈利路亞。", "zh-hans": "正直人赞美祂是理所应该是的。哈利路亚。", "en": "For it becometh well the just to be thankful, alleluia."}}} | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal.zh-hans` | "主阿，※永恒之光必照耀主的众圣徒，哈利路亚；直到永永远远，哈利路亚，哈利路亚，哈利路亚。" | "这些人轻视了世俗的生活，※获得了天国的赏报，并在羔羊的血中洗净了他们的衣服；天国是他们的." |
| `morning.benedictus_antiphon.normal.zh-hant` | "主阿，※永恆之光必照耀主的眾聖徒，哈利路亞；直到永永遠遠，哈利路亞，哈利路亞，哈利路亞。" | "這些人輕視了世俗的生活，※獲得了天國的賞報，並在羔羊的血中洗淨了他們的衣服；天國是他們的。" |
| `morning.bible_sentences.0.reference.en` | "(Rev.vii.14.)" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.reference.zh-hans` | "（启示录 7:14）" | "（启示录 6:9-10）" |
| `morning.bible_sentences.0.reference.zh-hant` | "（啟示錄 7:14）" | "（啟示錄 6:9-10）" |
| `morning.bible_sentences.0.text.en` | "THESE are they which came out of great tribulation, and have washed their robes, and made them white in the blood of the Lamb." | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.zh-hans` | "这些人是从大患难中出来的，他们曾用羔羊的血把衣裳洗得洁白。" | "我看见在祭坛底下有曾为上帝的道，并为作见证而被杀的人的灵魂，大声喊着说：神圣真实的主宰啊，你不审判住在地上的人，为我们所流的血伸冤，要到几时呢？" |
| `morning.bible_sentences.0.text.zh-hant` | "這些人是從大患難中出來的，他們曾用羔羊的血把衣裳洗得潔白。" | "我看見在祭壇底下有曾為上帝的道，並為作見證而被殺的人的靈魂，大聲喊着說：神聖真實的主宰啊，你不審判住在地上的人，為我們所流的血伸冤，要到幾時呢？" |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传", "en": ""}, "source": {"zh-hant": "", "zh-hans": "", "en": ""}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。", "en": ""}, "paragraphs": [{"zh-hant": "自早期以來，教會就在這一天紀念殉道者聖普羅托與聖海厄森斯；人們相信他們是兄弟。一八四五年，海厄森斯的葬處在羅馬舊薩拉里亞大道的聖巴西拉墓園中被發現，且未受擾動。在那裡，一塊古老碑文的下方——碑文寫著：「殉道者海厄森斯，安葬於九月十一日」——發現了骨灰和被焚燒過的人骨，裹在昂貴織物的殘片中。附近還有一座空墓，上刻著：「殉道者普羅托之墓。」後世所流傳關於這兩位殉道者的故事如下：他們原是埃及童貞女聖尤金妮亞的宦官奴僕，並與她一同受洗；此後，他們勤奮研讀上帝的聖言，曾在一所修道院中居住一段時間。後來，他們跟隨尤金妮亞前往羅馬，在那裡引導聖巴西拉歸信基督；約於二五七年，他們又為基督的緣故，與她一同慘遭殺害。", "zh-hans": "自早期以来，教会就在这一天纪念殉道者圣普罗托与圣海厄森斯；人们相信他们是兄弟。一八四五年，海厄森斯的葬处在罗马旧萨拉里亚大道的圣巴西拉墓园中被发现，且未受扰动。在那里，一块古老碑文的下方——碑文写着：「殉道者海厄森斯，安葬于九月十一日」——发现了骨灰和被焚烧过的人骨，裹在昂贵织物的残片中。附近还有一座空墓，上刻着：「殉道者普罗托之墓。」后世所流传关于这两位殉道者的故事如下：他们原是埃及童贞女圣尤金妮亚的宦官奴仆，并与她一同受洗；此后，他们勤奋研读上帝的圣言，曾在一所修道院中居住一段时间。后来，他们跟随尤金妮亚前往罗马，在那里引导圣巴西拉归信基督；约于二五七年，他们又为基督的缘故，与她一同惨遭杀害。", "en": "ON this day since early times, have been commemorated the Martyrs Protus and Hyacinth, who are believed to have been brothers. In 1845 the burial-place of Hyacinth was found undisturbed in the Cemetery of Saint Basilla, on the Old Salarian Way at Rome. There, under an ancient inscription which was found to read: Hyacinth the Martyr, buried September IIth: were discovered ashes and charred human bones, wrapped in the remains of a costly fabric. Nearby was an empty tomb, bearing the inscription: The tomb of Protus the Martyr. The story which in later days came to be told of these Martyrs is this: They were slave-eunuchs in Egypt of Saint Eugenia the Virgin, and were baptized with her; whereafter they studied God's Word diligently, and dwelt for a while in a monastery; and then they followed Eugenia to Rome, where they brought Saint Basilla to the Faith; and were for Christ's sake cruelly put to death with her, about the year 257."}]} | （原檔沒有此欄位） |
| `morning.invitatory.text` | {"zh-hant": "願眾聖徒在主裏歡欣，※哈利路亞。", "zh-hans": "愿众圣徒在主里欢欣，※哈利路亚。", "en": ""} | （原檔沒有此欄位） |
| `morning.invitatory.texts` | （原檔沒有此欄位） | [{"zh-hant": "上帝在祂的聖徒中顯為奇妙可畏，※我們當來俯伏敬拜。", "zh-hans": "上帝在祂的圣徒中显为奇妙可畏，※我们当来俯伏敬拜."}, {"zh-hant": "主是殉道者的君王，※我們當來俯伏敬拜。", "zh-hans": "主是殉道者的君王，※我们当来俯伏敬拜."}] |
| `morning.invitatory_hymn.title` | {"zh-hant": "Aeterna Christi munera", "zh-hans": "Aeterna Christi munera", "en": "Aeterna Christi munera"} | "基督君王永恆恩賜" |
| `morning.invitatory_hymn.verses.0.en` | "THE eternal gifts of Christ the King, \nThe Martyrs' victories we sing:\nAnd while due hymns of praise we pay, \nOur thankful hearts cast grief away." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.0.zh-hans` | "一、基督君王永恒恩赐，\n献上歌声不断赞颂，\n殉道圣者光荣事迹，\n感恩之心驱散忧伤。" | "一、基督君王永恒恩赐，\n献上歌声不断赞颂，\n殉道圣者光荣事迹，\n感恩之心驱散忧伤." |
| `morning.invitatory_hymn.verses.1.en` | "They braved the terrors of the time, \nNo torment shook their faith sublime;\nSoon, holy death brought peace and rest, \nAnd light eternal with the blest." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.1.zh-hans` | "二、勇敢面对时代恐惧，\n苦难不移崇高信仰，\n圣洁死亡带来安息，\n真福同享永恒荣光。" | "二、勇敢面对时代恐惧，\n苦难不移崇高信仰，\n圣洁死亡带来安息，\n真福同享永恒荣光." |
| `morning.invitatory_hymn.verses.2.en` | "To flames the Martyr Saints are haled: \nBy teeth of savage beasts assailed;\nAgainst them, armed with ruthless brand \nAnd hooks of steel, their torturers stand. " | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.2.zh-hans` | "三、猛兽张齿裂骨噬肌，\n烈焰焚躯圣徒不移，\n刑鈎贯体铁刃凌欺，\n诸般酷虐圣者无遗。" | "三、猛兽张齿裂骨噬肌，\n烈焰焚躯圣徒不移，\n刑鈎贯体铁刃凌欺，\n诸般酷虐圣者无遗." |
| `morning.invitatory_hymn.verses.3.en` | "The mangled frame is tortured sore; \nThe holy life-drops freshly pour:\nThey stand unmoved amidst the strife, \nBy grace of everlasting life." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.zh-hans` | "四、圣血滂沱体骸残损，\n痛楚虽极心志愈韧，\n靠主恩典立场坚定，\n苦难中间毫不动摇。" | "四、圣血滂沱体骸残损，\n痛楚虽极心志愈韧，\n靠主恩典立场坚定，\n苦难中间毫不动摇." |
| `morning.invitatory_hymn.verses.4.en` | "Redeemer, hear us of thy love, \nThat with the Martyr host above,\nThy servants too may find a place,\nAnd reign for ever through thy grace. Amen." | （原檔沒有此欄位） |
| `morning.office_hymn.title` | {"zh-hant": "榮耀殉道圣者之君", "zh-hans": "荣耀殉道圣者之君", "en": ""} | "榮耀殉道圣者之君" |
| `morning.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日。" | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日." |
| `morning.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.1.zh-hans` | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪。" | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪." |
| `morning.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.2.zh-hans` | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕。" | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕." |
| `morning.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.3.zh-hans` | "四、恳求荣耀加冕之君，\n复活喜悦护佑群羊，\n因你挑选重价赎回，\n免受死亡扰乱侵害。" | "四、仁君基督永享尊荣，\n偕同天父同享荣耀；\n也归于保惠师圣灵，\n三一上帝永世无尽。阿们。" |
| `morning.office_hymn.verses.3.zh-hant` | "四、懇求榮耀加冕之君，\n復活喜悅護佑群羊，\n因你揀選重價贖回，\n免受死亡擾亂侵害。" | "四、仁君基督永享尊榮，\n偕同天父同享榮耀；\n也歸於保惠師聖靈，\n三一上帝永世無盡。阿們。" |
| `morning.office_hymn.verses.4` | {"zh-hant": "五、但願死而復活之主，\n接受子民所獻榮耀，\n也願歸於聖父聖靈，\n從今直到永永遠遠。阿們。", "zh-hans": "五、但愿死而复活之主，\n接受子民所献荣耀，\n也愿归于圣父圣灵，\n从今直到永永远远。阿们。", "en": ""} | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.en` | "Rejoice in the Lord, ye righteous, alleluia." | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.zh-hans` | "你们善人应该因主欢乐，哈利路亚。" | "上帝在祂的圣徒中显为奇妙可畏." |
| `morning.office_hymn.versicle.leader.zh-hant` | "你們善人應該因主歡樂，哈利路亞。" | "上帝在祂的聖徒中顯為奇妙可畏。" |
| `morning.office_hymn.versicle.people.en` | "For it becometh well the just to be thankful, alleluia." | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.people.zh-hans` | "正直人赞美祂是理所应该是的。哈利路亚。" | "祂的威严满有荣耀." |
| `morning.office_hymn.versicle.people.zh-hant` | "正直人讚美祂是理所應該的。哈利路亞。" | "祂的威嚴滿有榮耀。" |
| `morning.psalm_antiphons.antiphons.0.en` | "Thy Saints, O Lord, shall flourish like the lily, alleluia; ※and shall be even as the odour of balsam before thee, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "主的圣徒必如百合花开放，※哈利路亚；他们必如香膏的馨香立于主面前，哈利路亚。" | "主的圣徒必如百合花开放，※哈利路亚；他们必如香膏的馨香立于主面前，哈利路亚." |
| `morning.psalm_antiphons.antiphons.1.en` | "In the heavenly kingdom † the Blessed have their dwelling-place, alleluia; ※and their rest for ever and ever, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.1.zh-hans` | "天国是诸圣的居所，※哈利路亚，他们要永远安息，哈利路亚。" | "天国是诸圣的居所，※哈利路亚，他们要永远安息，哈利路亚." |
| `morning.psalm_antiphons.antiphons.2.en` | "Within the veil + thy blessed Saints, O Lord, ※continually do cry, alleluia, alleluia, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "主的诸圣在帷幕内高呼：※哈利路亚，哈利路亚，哈利路亚。" | "主的诸圣在帷幕内高呼：※哈利路亚，哈利路亚，哈利路亚." |
| `morning.psalm_antiphons.antiphons.3.en` | "O ye spirits + and souls of the righteous, ※sing ye praise to the Lord our God, alleluia, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "义人的灵魂，※请歌唱赞美我们的上帝，哈利路亚，哈利路亚。" | "义人的灵魂，※请歌唱赞美我们的上帝，哈利路亚，哈利路亚." |
| `morning.psalm_antiphons.antiphons.4.en` | "Then shall the righteous † shine forth as the sun ※in the presence of God, alleluia." | （原檔沒有此欄位） |
| `evening.ascension_office_hymn` | {"title": {"zh-hant": "榮耀殉道圣者之君", "zh-hans": "荣耀殉道圣者之君", "en": ""}, "verses": [{"zh-hant": "一、榮耀殉道圣者之君，\n精修圣人以主為冠；\n引領捨棄世俗歡樂，\n邁向天國光輝之日。", "zh-hans": "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日。", "en": ""}, {"zh-hant": "二、救主垂憐傾聽我們，\n我眾祈禱上達於天；\n數算他們得勝之時，\n赦免我們所犯之罪。", "zh-hans": "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪。", "en": ""}, {"zh-hant": "三、殉道者因你而得勝，\n精修者從你得恩典；\n助我克服罪恶慾望，\n好使我們获得寬恕。", "zh-hans": "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕。", "en": ""}, {"zh-hant": "四、願主作我喜樂護衛，\n主是我們至大賞賜；\n願主永遠作我榮耀，\n為我永恆不朽誇耀。", "zh-hans": "四、愿主作我喜乐护卫，\n主是我们至大赏赐；\n愿主永远作我荣耀，\n为我永恒不朽夸耀。", "en": ""}, {"zh-hant": "五、今日升上群星之主，\n我們獻上一切榮耀；\n永恆榮耀歸於聖父，\n聖靈與你同享尊崇。阿們。", "zh-hans": "五、今日升上群星之主，\n我们献上一切荣耀；\n永恒荣耀归于圣父，\n圣灵与你同享尊崇。阿们。", "en": ""}], "versicle": {"leader": {"zh-hant": "永恆的喜樂必在他們頭上。哈利路亞。", "zh-hans": "永恒的喜乐必在他们头上。哈利路亚。", "en": ""}, "people": {"zh-hant": "他們必得著歡喜快樂，哈利路亞。", "zh-hans": "他们必得着欢喜快乐，哈利路亚。", "en": ""}}} | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal` | {"zh-hant": "主阿，※永恆之光必照耀主的眾聖徒，哈利路亞；直到永永遠遠，哈利路亞，哈利路亞，哈利路亞。", "zh-hans": "主阿，※永恒之光必照耀主的众圣徒，哈利路亚；直到永永远远，哈利路亚，哈利路亚，哈利路亚。", "en": ""} | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals` | （原檔沒有此欄位） | [{"zh-hant": "上帝要擦去聖徒一切的眼淚；※不再有死亡，也不再有悲哀、哭號、痛苦，因為先前的事都過去了。", "zh-hans": "上帝要擦去圣徒一切的眼泪；※不再有死亡，也不再有悲哀、哭号、痛苦，因为先前的事都过去了."}, {"zh-hant": "諸聖手執棕枝直抵天國，※他們從主手中領受了華冠。", "zh-hans": "诸圣手执棕枝直抵天国，※他们从主手中领受了华冠."}] |
| `evening.bible_sentences.0.reference.en` | "(Matt.x.22.)" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.reference.zh-hans` | "（马太福音 10:22）" | "（以斯拉补编下卷 2:45）" |
| `evening.bible_sentences.0.reference.zh-hant` | "（馬太福音 10:22）" | "（以斯拉補編下卷 2:45）" |
| `evening.bible_sentences.0.text.en` | "AND ye shall be hated of all men for my name's sake: but he that endureth to the end shall be saved." | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.zh-hans` | "你们要为我的名被众人憎恨。但坚忍到底的终必得救." | "这些人是脱了那必死的衣裳，穿上那不死的。他们宣认了上帝的名，现在他们戴上冠冕，又得棕树枝." |
| `evening.bible_sentences.0.text.zh-hant` | "你們要為我的名被眾人憎恨。但堅忍到底的終必得救。" | "這些人是脫了那必死的衣裳，穿上那不死的。他們宣認了上帝的名，現在他們戴上冠冕，又得棕樹枝。" |
| `evening.office_hymn.title` | {"zh-hant": "榮耀殉道圣者之君", "zh-hans": "荣耀殉道圣者之君", "en": ""} | "榮耀殉道圣者之君" |
| `evening.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日。" | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日." |
| `evening.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.1.zh-hans` | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪。" | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪." |
| `evening.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.2.zh-hans` | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕。" | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕." |
| `evening.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.3.zh-hans` | "四、恳求荣耀加冕之君，\n复活喜悦护佑群羊，\n因你挑选重价赎回，\n免受死亡扰乱侵害。" | "四、仁君基督永享尊荣，\n偕同天父同享荣耀；\n也归于保惠师圣灵，\n三一上帝永世无尽。阿们。" |
| `evening.office_hymn.verses.3.zh-hant` | "四、懇求榮耀加冕之君，\n復活喜悅護佑群羊，\n因你揀選重價贖回，\n免受死亡擾亂侵害。" | "四、仁君基督永享尊榮，\n偕同天父同享榮耀；\n也歸於保惠師聖靈，\n三一上帝永世無盡。阿們。" |
| `evening.office_hymn.verses.4` | {"zh-hant": "五、但願死而復活之主，\n接受子民所獻榮耀，\n也願歸於聖父聖靈，\n從今直到永永遠遠。阿們。", "zh-hans": "五、但愿死而复活之主，\n接受子民所献荣耀，\n也愿归于圣父圣灵，\n从今直到永永远远。阿们。", "en": ""} | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.en` | "Rejoice in the Lord, ye righteous, alleluia." | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.zh-hans` | "你们善人应该因主欢乐，哈利路亚。" | "只有善人必要快乐，" |
| `evening.office_hymn.versicle.leader.zh-hant` | "你們善人應該因主歡樂，哈利路亞。" | "只有善人必要快樂，" |
| `evening.office_hymn.versicle.people.en` | "For it becometh well the just to be thankful, alleluia." | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.zh-hans` | "正直人赞美祂是理所应该是的。哈利路亚。" | "在上帝面前勇跃欢喜." |
| `evening.office_hymn.versicle.people.zh-hant` | "正直人讚美祂是理所應該的。哈利路亞。" | "在上帝面前勇躍歡喜。" |
| `evening.psalm_antiphons.antiphons.0.en` | "Thy Saints, O Lord, shall flourish like the lily, alleluia; ※and shall be even as the odour of balsam before thee, alleluia." | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "主的圣徒必如百合花开放，※哈利路亚；他们必如香膏的馨香立于主面前，哈利路亚。" | "这些圣徒为上帝舍身，※并用羔羊的血把衣裳洗得洁白." |
| `evening.psalm_antiphons.antiphons.0.zh-hant` | "主的聖徒必如百合花开放，※哈利路亞；他們必如香膏的馨香立於主面前，哈利路亞。" | "這些聖徒為上帝捨身，※並用羔羊的血把衣裳洗得潔白。" |
| `evening.psalm_antiphons.antiphons.1.en` | "In the heavenly kingdom † the Blessed have their dwelling-place, alleluia; ※and their rest for ever and ever, alleluia." | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.1.zh-hans` | "天国是诸圣的居所，※哈利路亚，他们要永远安息，哈利路亚。" | "圣徒藉着信，※制伏了列国，行了公义，得了应许." |
| `evening.psalm_antiphons.antiphons.1.zh-hant` | "天國是諸聖的居所，※哈利路亞，他們要永遠安息，哈利路亞。" | "聖徒藉著信，※制伏了列國，行了公義，得了應許。" |
| `evening.psalm_antiphons.antiphons.2.en` | "Within the veil + thy blessed Saints, O Lord, ※continually do cry, alleluia, alleluia, alleluia." | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "主的诸圣在帷幕内高呼：※哈利路亚，哈利路亚，哈利路亚。" | "圣徒如鹰返老返童，※他们如百合花盛开在主的城里." |
| `evening.psalm_antiphons.antiphons.2.zh-hant` | "主的諸聖在帷幕內高呼：※哈利路亞，哈利路亞，哈利路亞。" | "聖徒如鷹返老返童，※他們如百合花盛開在主的城裏。" |
| `evening.psalm_antiphons.antiphons.3.en` | "O ye spirits + and souls of the righteous, ※sing ye praise to the Lord our God, alleluia, alleluia." | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "义人的灵魂，※请歌唱赞美我们的上帝，哈利路亚，哈利路亚。" | "上帝要擦去圣徒一切的眼泪；※不再有死亡，也不再有悲哀、哭号、痛苦，因为先前的事都过去了." |
| `evening.psalm_antiphons.antiphons.3.zh-hant` | "義人的靈魂，※請歌唱讚美我們的上帝，哈利路亞，哈利路亞。" | "上帝要擦去聖徒一切的眼淚；※不再有死亡，也不再有悲哀、哭號、痛苦，因為先前的事都過去了。" |
| `evening.psalm_antiphons.antiphons.4.en` | "Then shall the righteous † shine forth as the sun ※in the presence of God, alleluia." | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.4.zh-hans` | "义人要在上帝台前发出光来，※像太阳一样。哈利路亚." | "天国是诸圣的居所，※他们要永远安息." |
| `evening.psalm_antiphons.antiphons.4.zh-hant` | "義人要在上帝台前發出光來，※像太陽一樣。哈利路亞。" | "天國是諸聖的居所，※他們要永遠安息。" |

### sanctorale_0916_cyprian.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。
- 所有祝文、選項標籤及頂層身分資料保留。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normal.zh-hans` | "这真是一位殉道者，※他为基督的名倾流了鲜血；他不畏惧审判者的威吓，不追求世俗的尊贵荣耀，喜乐地进入天国。" | "这真是一位殉道者，※他为基督的名倾流了鲜血；他不畏惧审判者的威吓，不追求世俗的尊贵荣耀，喜乐地进入天国." |
| `vigil.bible_sentences.0.reference.en` | "(Matt.x.22.)" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.en` | "AND ye shall be hated of all men for my name's sake: but he that endureth to the end shall be saved." | （原檔沒有此欄位） |
| `vigil.office_hymn.title` | {"zh-hant": "Deus tuorum militum", "zh-hans": "Deus tuorum militum", "en": "Deus tuorum militum"} | "上帝義子勇毅無雙" |
| `vigil.office_hymn.verses.0.en` | "MARTYR of God! the only Son \nTo victory hath led thee on;\nThine every foe now prostrate lies, \nAnd heaven accords the victor's prize." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.1.en` | "O may thy prayer. for us obtain \nThe cleansing of each guilty stain;\nShield us from sin's contagious blight: \nPut life's long weariness to flight." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.2.en` | "Now riven are the bonds in twain, \nWhich did thy saintly limbs enchain;\nFrom us the bonds of earth remove, \nThrough God the Son's redeeming love." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.en` | "All laud to God the Father be; \nAll praise, eternal Son, to thee;\nAll glory, as is ever meet, \nTo God the Holy Paraclete. Amen." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.zh-hans` | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽.阿们." | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽。阿们。" |
| `vigil.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.leader.zh-hans` | "主加增他尊贵荣耀。" | "主加增他尊贵荣耀." |
| `vigil.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "凡在人面前认我的，※我在我天上的父面前也必认他。" | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `vigil.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `vigil.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `vigil.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主说：※若有人服事我，我父必尊重他。" | "主说：※若有人服事我，我父必尊重他." |
| `vigil.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "圣父阿，※我在哪里，服事我的人也要在哪里。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |
| `morning.benedictus_antiphon.normals.0.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normals.0.zh-hans` | "一粒麦子不落在地里死了，※仍旧是一粒。" | "一粒麦子不落在地里死了，※仍旧是一粒." |
| `morning.benedictus_antiphon.normals.1.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normals.1.zh-hans` | "主说：若有人要跟从我，※就当舍己，背起自己的十字架来跟从我。" | "主说：若有人要跟从我，※就当舍己，背起自己的十字架来跟从我." |
| `morning.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传", "en": ""}, "source": {"zh-hant": "", "zh-hans": "", "en": ""}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。", "en": ""}, "paragraphs": [{"zh-hant": "居普良於二五八年被斬首。聖耶柔米在《教會作家錄》中，留下了關於他的以下記述：居普良是非洲人。他最初以修辭學教師聞名。後來，他在司鐸凱西利烏斯的勸導下成為基督徒，並冠上了對方的姓氏，又將自己所有的財物分給窮人。不久之後，他被按立為司鐸，繼而成為迦太基主教。若要詳述他的才智，實屬多餘，因為他的著作如太陽般為人所共知。他在瓦勒良與加里恩努斯兩位皇帝治下，即第八次教難中受害；他與哥尼流在同一日（即九月十四日）為信仰作見證，只是不在同一年，哥尼流在羅馬，而他則在迦太基。", "zh-hans": "居普良于二五八年被斩首。圣耶柔米在《教会作家录》中，留下了关于他的以下记述：居普良是非洲人。他最初以修辞学教师闻名。后来，他在司铎凯西利乌斯的劝导下成为基督徒，并冠上了对方的姓氏，又将自己所有的财物分给穷人。不久之后，他被按立为司铎，继而成为迦太基主教。若要详述他的才智，实属多余，因为他的著作如太阳般为人所共知。他在瓦勒良与加里恩努斯两位皇帝治下，即第八次教难中受害；他与哥尼流在同一日（即九月十四日）为信仰作见证，只是不在同一年，哥尼流在罗马，而他则在迦太基。", "en": "Cyprian was beheaded in 258. St. Jerome, in his Book on Ecclesiastical Writers, hath left the following account of him. Cyprian was an African. He was first distinguished as a teacher of rhetoric. He afterwards became a Christian at the persuasion of the priest Caecilius, whose surname he took, and parted all his goods among the poor. It was not long afterwards that he was ordained priest, and then made Bishop of Carthage. It would be idle to enlarge upon his wit, seeing that his works are as well known as the sun. He suffered under the Emperors Valerian and Gallienus, in the eighth persecution, and upon the same day, though not in the same year, that Cornelius testified at Rome."}]} | （原檔沒有此欄位） |
| `morning.invitatory.text.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.text.zh-hans` | "主是殉道者的君王，※我们当来俯伏敬拜。" | "主是殉道者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory_hymn.title` | {"zh-hant": "Deus tuorum militum", "zh-hans": "Deus tuorum militum", "en": "Deus tuorum militum"} | "上帝義子勇毅無雙" |
| `morning.invitatory_hymn.verses.0.en` | "MARTYR of God! the only Son \nTo victory hath led thee on;\nThine every foe now prostrate lies, \nAnd heaven accords the victor's prize." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.1.en` | "O may thy prayer. for us obtain \nThe cleansing of each guilty stain;\nShield us from sin's contagious blight: \nPut life's long weariness to flight." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.2.en` | "Now riven are the bonds in twain, \nWhich did thy saintly limbs enchain;\nFrom us the bonds of earth remove, \nThrough God the Son's redeeming love." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.en` | "All laud to God the Father be; \nAll praise, eternal Son, to thee;\nAll glory, as is ever meet, \nTo God the Holy Paraclete. Amen." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.zh-hans` | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽.阿们." | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽。阿们。" |
| `morning.office_hymn.title` | {"zh-hant": "主之諸聖共沐主恩", "zh-hans": "主之诸圣共沐主恩", "en": ""} | "主之諸聖共沐主恩" |
| `morning.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生。" | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生." |
| `morning.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.1.zh-hans` | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年。" | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年." |
| `morning.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.2.zh-hans` | "三、为尔穿越万般艰险，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆。" | "三、为尔穿越万般艰难，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆." |
| `morning.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.3.zh-hans` | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污。" | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污." |
| `morning.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.en` | "The righteous shall blossom as the lily. " | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.people.en` | "He shall flourish for ever before the Lord." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "凡在人面前认我的，※我在我天上的父面前也必认他。" | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `morning.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.1.zh-hans` | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `morning.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `morning.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "主说：※若有人服事我，我父必尊重他。" | "主说：※若有人服事我，我父必尊重他." |
| `morning.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.4.zh-hans` | "圣父阿，※我在哪里，服事我的人也要在哪里。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |
| `evening.benedictus_antiphon.normals.0.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.0.zh-hans` | "他将世上的一切都视为无物，※以言以行，为自己在天上积蓄财宝。" | "他将世上的一切都视为无物，※以言以行，为自己在天上积蓄财宝." |
| `evening.benedictus_antiphon.normals.1.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.1.zh-hans` | "此人彻悟公义，洞悉奇伟奥秘；※他祈求至高者，终列诸圣之中。" | "此人彻悟公义，洞悉奇伟奥秘；※他祈求至高者，终列诸圣之中." |
| `evening.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.zh-hans` | "忍受试炼的人有福了，因为他经过考验以后必得生命的冠冕，这是主应许给爱他之人的。" | "忍受试炼的人有福了，因为他经过考验以后必得生命的冠冕，这是主应许给爱他之人的." |
| `evening.office_hymn.title` | {"zh-hant": "主之諸聖共沐主恩", "zh-hans": "主之诸圣共沐主恩", "en": ""} | "主之諸聖共沐主恩" |
| `evening.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生。" | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生." |
| `evening.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.1.zh-hans` | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年。" | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年." |
| `evening.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.2.zh-hans` | "三、为尔穿越万般艰险，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆。" | "三、为尔穿越万般艰难，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆." |
| `evening.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.3.zh-hans` | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污。" | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污." |
| `evening.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "凡在人面前认我的，※我在我天上的父面前也必认他。" | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `evening.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.1.zh-hans` | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `evening.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `evening.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "主说：※若有人服事我，我父必尊重他。" | "主说：※若有人服事我，我父必尊重他." |
| `evening.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.4.zh-hans` | "圣父阿，※我在哪里，服事我的人也要在哪里。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |

### sanctorale_0917_stigmata_of_francis.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。
- 所有祝文、選項標籤及頂層身分資料保留。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normal.zh-hans` | "我要把他好比一个聪明人，※把房子盖在磐石上。" | "我要把他好比一个聪明人，※把房子盖在磐石上." |
| `vigil.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.zh-hans` | "有福之人清早起来专心致志，归向那位创造他的主；他在至高者之前祈求，并张开他的嘴巴祷告，为自己的罪过而祈求。" | "有福之人清早起来专心致志，归向那位创造他的主；他在至高者之前祈求，并张开他的嘴巴祷告，为自己的罪过而祈求." |
| `vigil.office_hymn.title` | {"zh-hant": "Christe, pastorum Caput atque Princeps", "zh-hans": "Christe, pastorum Caput atque Princeps", "en": ""} | "Christe, pastorum Caput atque Princeps" |
| `vigil.office_hymn.verses.0.en` | "THIS the Confessor of the Lord, whose triumph\nNow all the faithful celebrate, with gladness\nErst on this feast-day merited to enter\nInto his glory." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.1.en` | "Saintly and prudent, modest in behavior,\nPeaceful and sober, chaste was he, and lowly,\nWhile that life's vigour, coursing through his members,\nQuickened his being." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.2.en` | "Sick ones of old time, to his tomb resorting,\nSorely by ailments manifold afflicted,\nOft-times have welcomed health and strength returning,\nAt his petition." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.en` | "Whence we in chorus gladly do him honor,\nChanting his praises with devout affection,\nThat in his merits we may have a portion,\nNow and forever." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.en` | "His be the glory, power, and salvation:\nWho over all things reigneth in the highest,\nEarth's mighty fabric ruling and directing,\nOnely and Trinal. Amen." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.zh-hans` | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主.阿们." | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。" |
| `vigil.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.leader.zh-hans` | "主以救赎的记号印了主仆法兰西斯。" | "主爱了他，并装扮了他." |
| `vigil.office_hymn.versicle.leader.zh-hant` | "主以救贖的記號印了主僕法蘭西斯。" | "主愛了他，並裝扮了他。" |
| `vigil.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.people.zh-hans` | "就是我们得赎的圣号。" | "给他穿上荣耀的外衣." |
| `vigil.office_hymn.versicle.people.zh-hant` | "就是我們得贖的聖號。" | "給他穿上榮耀的外衣。" |
| `vigil.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `vigil.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `vigil.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `vigil.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.zh-hans` | "他们在上帝宝座前，昼夜在他殿中事奉他；那坐在宝座上的要用帐幕覆庇他们。" | "他们在上帝宝座前，昼夜在他殿中事奉他；那坐在宝座上的要用帐幕覆庇他们." |
| `morning.biography` | {"title": {"zh-hant": "《聖法蘭西斯傳》第十三章", "zh-hans": "《圣法兰西斯传》第十三章", "en": "Legenda S. Francisci, cap. 13"}, "source": {"zh-hant": "節選自聖波那文都拉主教的註釋", "zh-hans": "节选自圣波那文都拉主教的注释", "en": "From the Life of St. Francis by St. Bonaventure the Bishop"}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。", "en": ""}, "paragraphs": [{"zh-hant": "基督忠信的僕人和使者法蘭西斯，在他將靈魂交託天鄉前兩年，上到一處高遠、僻靜之地，就是阿爾韋爾納山。他在那裡開始守他每年秋季為敬禮聖總領天使彌額爾而慣常守的四旬期齋戒。不久，他便被天上默觀的甘飴充滿，遠勝於以往；又燃起更熾熱、超乎塵世的渴慕之火，彷彿感到許多神聖恩賜傾注在他身上。因此，他以撒拉弗般的渴慕被提升向上帝，又被對上帝受苦的甜蜜憐憫所感動。於是，他被轉化為那位因極大之愛而忍受釘十字架者的樣式；這奇事發生的情形如下：在聖十字架高舉日附近的一個早晨，法蘭西斯正在山邊祈禱，看見有一個發焰、光輝燦爛的形象，從天上高處降到他面前；那是一位有六翼的撒拉弗。當這位撒拉弗以極迅疾的飛行接近這位屬上帝的人時，他的雙翼之間顯現一個被釘十字架之人的形象，雙手雙腳伸開作十字架的形狀，並被釘在十字架上。這六翼的用法是：兩翼遮臉，兩翼遮腳，兩翼飛翔。法蘭西斯見到這一切，便極其驚異；喜樂與憂傷交織，充滿了他的心。因為基督以撒拉弗的形狀慈顏注視他，使他非常喜樂；然而，當他看見他的主和師傅被釘十字架的可怖景象時，又好像有一把憐憫悲傷的劍刺透他的靈魂，使他極其憂傷。", "zh-hans": "基督忠信的仆人和使者法兰西斯，在他将灵魂交托天乡前两年，上到一处高远、僻静之地，就是阿尔韦尔纳山。他在那里开始守他每年秋季为敬礼圣总领天使弥额尔而惯常守的四旬期斋戒。不久，他便被天上默观的甘饴充满，远胜于以往；又燃起更炽热、超乎尘世的渴慕之火，仿佛感到许多神圣恩赐倾注在他身上。因此，他以撒拉弗般的渴慕被提升向上帝，又被对上帝受苦的甜蜜怜悯所感动。于是，他被转化为那位因极大之爱而忍受钉十字架者的样式；这奇事发生的情形如下：在圣十字架高举日附近的一个早晨，法兰西斯正在山边祈祷，看见有一个发焰、光辉灿烂的形象，从天上高处降到他面前；那是一位有六翼的撒拉弗。当这位撒拉弗以极迅疾的飞行接近这位属上帝的人时，他的双翼之间显现一个被钉十字架之人的形象，双手双脚伸开作十字架的形状，并被钉在十字架上。这六翼的用法是：两翼遮脸，两翼遮脚，两翼飞翔。法兰西斯见到这一切，便极其惊异；喜乐与忧伤交织，充满了他的心。因为基督以撒拉弗的形状慈颜注视他，使他非常喜乐；然而，当他看见他的主和师傅被钉十字架的可怖景象时，又好像有一把怜悯悲伤的剑刺透他的灵魂，使他极其忧伤。", "en": "CHRIST’S faithful servant and minister Francis, two years before he rendered his spirit unto heaven, went up to a high place apart, namely, Mount Alverna. There he began the Lenten fast which he was wont to make each autumn in honour of holy Michael the Archangel. Soon was he filled unto overflowing, and as never before, with the sweetness of heavenly contemplation, and was kindled with a yet more burning flame of unearthly longing, and began to feel, as it were, heaped upon him, many gifts of divine bestowal. Wherefore he was uplifted toward God by a certain seraphic ardour of longing, and a sweet compassion for God’s suffering took hold on him. Then it came to pass that he was transformed into the very likeness of him who of his exceeding love endured to be crucified, and this wonder happened as followeth. On a certain morning about the Feast of the Exaltation of the Holy Cross, whilst he was praying on the mountainside, he beheld something flaming and resplendent, coming down from the heights of heaven unto him, which same was a Seraph with six wings. Now when this Seraph, in his most swift flight, drew near unto the man of God, there betwixt the wings was the Figure of a Man Crucified, having his hands and feet stretched forth in the shape of a cross, and fastened unto a cross. The six wings were used on this fashion: with twain he covered his face; with twain he covered his feet; and with twain he did fly. When Francis beheld all this, he was sore amazed, and joy, mingled with sorrow, filled his heart. For he rejoiced exceedingly at the gracious countenance wherewith Christ, in this guise of a Seraph, did look upon him, and he sorrowed, as though a sword of pitying grief did pierce his soul, at the direful sight of the crucifixion of his Lord and Master."}, {"zh-hant": "過了一會兒，他內心開始明白這外在異象所表示的意義。他由此受教知道：受難的軟弱，決不能與撒拉弗之靈的不死性相合；這異象呈現在他眼前，乃是要使他預先知道將要發生的事。也就是說，他既為基督的朋友，便蒙召全然轉化為被釘十字架的基督的樣式；這並非藉著肉身的殉道，而是藉著心靈被愛火燃起。因此，在一段隱密而親密的交談之後，異象消失了，卻在他心中留下撒拉弗般的愛火。然而，在外面、在他的肉身上，異象也留下同樣奇妙的被釘者形象；正如蠟受火加熱後，在原模的壓印之下形成封印的印記。隨即，他的手和腳開始顯出釘痕；釘子的頭顯在他的手掌和腳背上，釘尖則顯在其下。並且，他的右脅留下赤紅的傷痕，如同被槍刺透一般；聖血時常從那裡流出，染紅了他的會衣和褲子。", "zh-hans": "过了一会儿，他内心开始明白这外在异象所表示的意义。他由此受教知道：受难的软弱，决不能与撒拉弗之灵的不死性相合；这异象呈现在他眼前，乃是要使他预先知道将要发生的事。也就是说，他既为基督的朋友，便蒙召全然转化为被钉十字架的基督的样式；这并非借着肉身的殉道，而是借着心灵被爱火燃起。因此，在一段隐密而亲密的交谈之后，异象消失了，却在他心中留下撒拉弗般的爱火。然而，在外面、在他的肉身上，异象也留下同样奇妙的被钉者形象；正如蜡受火加热后，在原模的压印之下形成封印的印记。随即，他的手和脚开始显出钉痕；钉子的头显在他的手掌和脚背上，钉尖则显在其下。并且，他的右胁留下赤红的伤痕，如同被枪刺透一般；圣血时常从那里流出，染红了他的会衣和裤子。", "en": "AFTER a time he began to understand inwardly what this outward appearance signified. For therewithal he was taught that the infirmity of the Passion doth in no wise accord with the immortality of a seraphic spirit, and that this vision was thus presented unto his gaze to give him foreknowledge of what was come to pass, to wit, that he, as a friend of Christ, was called to be wholly transformed unto the likeness of Christ Crucified, not by martyrdom of body, but by enkindling of heart. Accordingly, after a secret and familiar converse, the vision disappeared, but left a seraphic glow of love within his heart. But without, upon his flesh, it imprinted a no less wondrous likeness of the Crucified; like as wax, heated by fire, is formed into a sealed imprint under the pressure of the original mould. For forthwith there began to appear in his hands and feet the wounds of the nails. Moreover, the heads of the nails did shew in the palms of his hands, and in the upper side of his feet, and their points did shew underneath the same. Furthermore his right side was seamed with a ruddy scar, like as it had been pierced with a lance, wherefrom his hallowed blood, staining his habit and breeches, did oftentimes flow."}, {"zh-hant": "此後，法蘭西斯成了一個新人，身上帶著一項新奇的神蹟；他的更新藉著一項從未賜給世上任何人的特殊恩典顯明出來，就是印在他肉身上的神聖五傷。當他從山上下降時，他帶著被釘十字架者的形象；這形象不是某位工匠用手刻在木板或石板上，乃是永生上帝的手指寫在他的肉身肢體上。由於「君王的祕密宜於隱藏」，這位承載真正君王祕密的蒙福之人，便竭力將這些神聖記號隱藏在人眼之外。然而，上帝為了自己的榮耀，常願意顯明祂所成就的大事。因此，這位曾暗中印下這些記號的主，也藉著其能力公開顯出許多神蹟，使五傷隱密而奇妙的效能，能從隨後發生的徵兆中清楚彰顯。這奇事發生於一二二四年；數百年來，人們一直為紀念此事而守這慶日，起初只在法蘭西斯會中舉行，後來擴展到普世教會，為使信徒的心被對被釘十字架之基督的愛火所燃燒。", "zh-hans": "此后，法兰西斯成了一个新人，身上带着一项新奇的神迹；他的更新借着一项从未赐给世上任何人的特殊恩典显明出来，就是印在他肉身上的神圣五伤。当他从山上下降时，他带着被钉十字架者的形象；这形象不是某位工匠用手刻在木板或石板上，乃是永生上帝的手指写在他的肉身肢体上。由于「君王的秘密宜于隐藏」，这位承载真正君王秘密的蒙福之人，便竭力将这些神圣记号隐藏在人眼之外。然而，上帝为了自己的荣耀，常愿意显明祂所成就的大事。因此，这位曾暗中印下这些记号的主，也借着其能力公开显出许多神迹，使五伤隐密而奇妙的效能，能从随后发生的征兆中清楚彰显。这奇事发生于一二二四年；数百年来，人们一直为纪念此事而守这庆日，起初只在法兰西斯会中举行，后来扩展到普世教会，为使信徒的心被对被钉十字架之基督的爱火所燃烧。", "en": "THEREAFTER Francis was a new man, marked by a new and strange miracle, wherein his renewal was made manifest in a singular privilege never before granted to anyone in this world; to wit, the sacred Stigmata impressed upon his flesh. When he descended from the mountain, he bore the image of the Crucified, which same was not engraven by the hands of some artificer on tables of wood or stone, but was written on the members of his flesh by the finger of the living God. And because it is good to conceal the secret of the king, this blessed bearer of a right kingly secret endeavoured to conceal its sacred signs from the eyes of men. Howbeit, God is wont, for his own glory, to reveal the great things which he hath done. Wherefore this same Lord who had secretly imprinted these tokens, openly manifested many miracles by their power; that the hidden and wondrous virtue of these Stigmata might be clearly made known by signs following. This wondrous thing took place in 1224, and for many centuries this feast hath been kept in honour of the same, first by Franciscans only, and afterwards throughout the Church, to the end that the hearts of the faithful might be inflamed with the love of Christ Crucified."}]} | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.zh-hans` | "义人栽种在主的殿前，发旺在我们上帝院里，※让我们在他的圣日欢欣庆贺。" | "义人栽种在主的殿前，发旺在我们上帝院里，※让我们在他的圣日欢欣庆贺." |
| `morning.invitatory.texts.1.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.1.zh-hans` | "主是精修者的君王，※我们当来俯伏敬拜。" | "主是精修者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory_hymn.title` | {"zh-hant": "Iste Confessor", "zh-hans": "Iste Confessor", "en": ""} | "Iste Confessor" |
| `morning.invitatory_hymn.verses.0.en` | "THIS the Confessor of the Lord, whose triumph\nNow all the faithful celebrate, with gladness\nErst on this feast-day merited to enter\nInto his glory." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.1.en` | "Saintly and prudent, modest in behavior,\nPeaceful and sober, chaste was he, and lowly,\nWhile that life's vigour, coursing through his members,\nQuickened his being." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.2.en` | "Sick ones of old time, to his tomb resorting,\nSorely by ailments manifold afflicted,\nOft-times have welcomed health and strength returning,\nAt his petition." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.en` | "Whence we in chorus gladly do him honor,\nChanting his praises with devout affection,\nThat in his merits we may have a portion,\nNow and forever." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.4.en` | "His be the glory, power, and salvation:\nWho over all things reigneth in the highest,\nEarth's mighty fabric ruling and directing,\nOnely and Trinal. Amen." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.4.zh-hans` | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主.阿们." | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。" |
| `morning.office_hymn.title` | {"zh-hant": "Iesu, corona celsior", "zh-hans": "Iesu, corona celsior", "en": ""} | "Iesu, corona celsior" |
| `morning.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、耶稣基督天府冠冕，\n永恒至高真理上主；\n嘉纳主之精修圣者，\n偕同诸圣永享荣华。" | "一、耶稣基督天府冠冕，\n永恒至高真理上主；\n嘉纳主之精修圣者，\n偕同诸圣永享荣华." |
| `morning.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.1.zh-hans` | "二、俯听我众卑微恳求，\n借其代祷蒙主庇护；\n涤除我等诸般罪愆，\n悉数斩断罪恶桎梏。" | "二、俯听我众卑微恳求，\n藉其代祷蒙主庇护；\n涤除我等诸般罪愆，\n悉数斩断罪恶桎梏." |
| `morning.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.2.zh-hans` | "三、岁月周环时光流转，\n荣耀佳节今朝重临；\n主之忠仆脱离尘躯，\n荣登高天觐见主面。" | "三、岁月周环时光流转，\n荣耀佳节今朝重临；\n主之忠仆脱离尘躯，\n荣登高天觐见主面." |
| `morning.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.3.zh-hans` | "四、视此尘世虚妄欢乐，\n浮华名利皆如尘土；\n鄙弃诸般世俗污秽，\n终获天府凯旋奇乐。" | "四、视此尘世虚妄欢乐，\n浮华名利皆如尘土；\n鄙弃诸般世俗污秽，\n终获天府凯旋奇乐." |
| `morning.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.4.zh-hans` | "五、恒常宣认主为君王，\n仰赖基督宏恩大德；\n狂傲仇敌践踏足下，\n奋勇击退众魔魑魅。" | "五、恒常宣认主为君王，\n仰赖基督宏恩大德；\n狂傲仇敌践踏足下，\n奋勇击退众魔魑魅." |
| `morning.office_hymn.verses.5.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.5.zh-hans` | "六、信德昭彰美名远播，\n坚定恒常宣信其主；\n严守斋戒克己修身，\n终获高天灵粮滋养。" | "六、信德昭彰美名远播，\n坚定恒常宣信其主；\n严守斋戒克己修身，\n终获高天灵粮滋养." |
| `morning.office_hymn.verses.6.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.6.zh-hans` | "七、洪恩广被慈悲上主，\n俯首叩拜至尊天颜；\n念此忠仆宣信之功，\n恳求涂抹我众罪债。" | "七、洪恩广被慈悲上主，\n俯首叩拜至尊天颜；\n念此忠仆宣信之功，\n恳求涂抹我众罪债." |
| `morning.office_hymn.verses.7.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.zh-hans` | "主以救赎的记号印了主仆法兰西斯。" | "主引导义人走入正路." |
| `morning.office_hymn.versicle.leader.zh-hant` | "主以救贖的記號印了主僕法蘭西斯。" | "主引導義人走入正路，" |
| `morning.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.people.zh-hans` | "就是我们得赎的圣号。" | "将上帝的国指示给他." |
| `morning.office_hymn.versicle.people.zh-hant` | "就是我們得贖的聖號。" | "將上帝的國指示給他。" |
| `morning.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `morning.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `morning.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `morning.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal.zh-hans` | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求。" | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求." |
| `evening.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.zh-hans` | "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪。" | "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪." |
| `evening.office_hymn.title` | {"zh-hant": "Jesu, sacerdotum decus", "zh-hans": "Jesu, sacerdotum decus", "en": ""} | "Jesu, sacerdotum decus" |
| `evening.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美。" | "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美." |
| `evening.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.1.zh-hans` | "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日。" | "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日." |
| `evening.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.2.zh-hans` | "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中。" | "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中." |
| `evening.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.3.zh-hans` | "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽。" | "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽." |
| `evening.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.zh-hans` | "主以救赎的记号印了主仆法兰西斯。" | "义人的口谈论智慧." |
| `evening.office_hymn.versicle.leader.zh-hant` | "主以救贖的記號印了主僕法蘭西斯。" | "義人的口談論智慧；" |
| `evening.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.zh-hans` | "就是我们得赎的圣号。" | "他的舌头讲说公平." |
| `evening.office_hymn.versicle.people.zh-hant` | "就是我們得贖的聖號。" | "他的舌頭講說公平。" |
| `evening.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `evening.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `evening.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `evening.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |

### sanctorale_0918_edward_bouverie_pusey.json

- 通用：`common_confessor_non_bishop_outside_easter`（一位精修者通用（復活期外）非主教.json）。
- 移除並繼承：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。
- 所有祝文、選項標籤及頂層身分資料保留。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normal.zh-hans` | "我要把他好比一个聪明人，※把房子盖在磐石上。" | "我要把他好比一个聪明人，※把房子盖在磐石上." |
| `vigil.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.zh-hans` | "有福之人清早起来专心致志，归向那位创造他的主；他在至高者之前祈求，并张开他的嘴巴祷告，为自己的罪过而祈求。" | "有福之人清早起来专心致志，归向那位创造他的主；他在至高者之前祈求，并张开他的嘴巴祷告，为自己的罪过而祈求." |
| `vigil.office_hymn.title` | {"zh-hant": "Christe, pastorum Caput atque Princeps", "zh-hans": "Christe, pastorum Caput atque Princeps", "en": ""} | "Christe, pastorum Caput atque Princeps" |
| `vigil.office_hymn.verses.0.en` | "THIS the Confessor of the Lord, whose triumph\nNow all the faithful celebrate, with gladness\nErst on this feast-day merited to enter\nInto his glory." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.1.en` | "Saintly and prudent, modest in behavior,\nPeaceful and sober, chaste was he, and lowly,\nWhile that life's vigour, coursing through his members,\nQuickened his being." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.2.en` | "Sick ones of old time, to his tomb resorting,\nSorely by ailments manifold afflicted,\nOft-times have welcomed health and strength returning,\nAt his petition." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.en` | "Whence we in chorus gladly do him honor,\nChanting his praises with devout affection,\nThat in his merits we may have a portion,\nNow and forever." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.en` | "His be the glory, power, and salvation:\nWho over all things reigneth in the highest,\nEarth's mighty fabric ruling and directing,\nOnely and Trinal. Amen." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.zh-hans` | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主.阿们." | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。" |
| `vigil.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.leader.zh-hans` | "主爱了他，并装扮了他。" | "主爱了他，并装扮了他." |
| `vigil.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.people.zh-hans` | "给他穿上荣耀的外衣。" | "给他穿上荣耀的外衣." |
| `vigil.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `vigil.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `vigil.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `vigil.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.zh-hans` | "他们在上帝宝座前，昼夜在他殿中事奉他；那坐在宝座上的要用帐幕覆庇他们。" | "他们在上帝宝座前，昼夜在他殿中事奉他；那坐在宝座上的要用帐幕覆庇他们." |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传", "en": "Legend"}, "source": {"zh-hant": "", "zh-hans": "", "en": ""}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。", "en": ""}, "paragraphs": [{"zh-hant": "愛德華·布維萊·普西生於一八〇〇年，早年就讀伊頓公學與牛津大學，青年時即受任為牛津大學希伯來文欽定教授及基督堂座堂法政牧師，任職五十三年之久。他精通希伯來文與德文，曾親赴德國研究新興的聖經批判學，以深厚的學術維護聖經啟示與教會信仰。愛妻早逝後，他度著嚴謹克己的生活，將自己的財富、地位與才學，奉獻於基督及其教會。", "zh-hans": "爱德华·布维莱·普西生于一八〇〇年，早年就读伊顿公学与牛津大学，青年时即受任为牛津大学希伯来文钦定教授及基督堂座堂法政牧师，任职五十三年之久。他精通希伯来文与德文，曾亲赴德国研究新兴的圣经批判学，以深厚的学术维护圣经启示与教会信仰。爱妻早逝后，他度着严谨克己的生活，将自己的财富、地位与才学，奉献于基督及其教会。", "en": "Edward Bouverie Pusey was born in 1800 and educated at Eton and Oxford. While still a young man, he became Regius Professor of Hebrew and a canon of Christ Church, serving for fifty-three years. Fluent in Hebrew and German, he studied the new biblical criticism in Germany and answered it with profound scholarship and steadfast faith. After the early death of his beloved wife, he embraced a life of austerity, devoting his learning, wealth, and influence to Christ and his Church."}, {"zh-hant": "普西是牛津運動的主要領袖之一。他為《時代論叢》撰寫論禁食的第十八號小冊，又倡導研讀教父著作，闡明英格蘭教會承繼大公與使徒信仰。他扶助修會生活的復興，指導並支持許多在貧民中服務的牧者，也致力恢復告解與和好的聖事職分，成為眾人的靈性導師。紐曼歸入羅馬、基布爾退居堂區之後，普西仍忠守英格蘭教會，堅信本教會確為至一、至聖、大公、使徒教會的一員。", "zh-hans": "普西是牛津运动的主要领袖之一。他为《时代论丛》撰写论禁食的第十八号小册，又倡导研读教父著作，阐明英格兰教会承继大公与使徒信仰。他扶助修会生活的复兴，指导并支持许多在贫民中服务的牧者，也致力恢复告解与和好的圣事职分，成为众人的灵性导师。纽曼归入罗马、基布尔退居堂区之后，普西仍忠守英格兰教会，坚信本教会确为至一、至圣、大公、使徒教会的一员。", "en": "Pusey became one of the principal leaders of the Oxford Movement. He contributed the eighteenth Tract for the Times, renewed the study of the Fathers, and defended the catholic and apostolic inheritance of the Church of England. He encouraged the revival of religious communities, supported priests serving among the poor, and helped restore the ministry of confession and reconciliation. After Newman entered the Roman Church and Keble withdrew to parish life, Pusey remained steadfast, upholding the Church of England as a true part of the One, Holy, Catholic, and Apostolic Church."}, {"zh-hant": "一八四三年，普西宣講〈至聖聖體：悔罪者的安慰〉，教導基督在聖體聖事中的真實臨在，並宣認教會藉此紀念主在十字架上一次而永遠的犧牲。他因此被牛津大學禁止講道兩年；然而這篇「被定罪的講章」反而廣為流傳，使聖體信仰更深入人心。他的教導促進了對聖體的敬禮、莊嚴的崇拜與主日常行聖餐。普西於一八八二年安息；他以謙卑、忍耐與忠貞，終身持守所領受的大公信仰，為教會的更新留下深遠恩澤。", "zh-hans": "一八四三年，普西宣讲〈至圣圣体：悔罪者的安慰〉，教导基督在圣体圣事中的真实临在，并宣认教会借此纪念主在十字架上一次而永远的牺牲。他因此被牛津大学禁止讲道两年；然而这篇「被定罪的讲章」反而广为流传，使圣体信仰更深入人心。他的教导促进了对圣体的敬礼、庄严的崇拜与主日常行圣餐。普西于一八八二年安息；他以谦卑、忍耐与忠贞，终身持守所领受的大公信仰，为教会的更新留下深远恩泽。", "en": "In 1843 Pusey preached The Holy Eucharist, a Comfort to the Penitent, teaching Christ’s Real Presence in the Sacrament and the Church’s pleading of his once-for-all sacrifice upon the Cross. For this he was forbidden to preach at Oxford for two years; yet the “condemned sermon” was widely read and strengthened Eucharistic faith throughout the Church. His teaching encouraged deeper devotion, more reverent worship, and more frequent Communion. Pusey died in 1882, having borne faithful witness through humility, patience, and perseverance, and leaving an enduring legacy of renewal within the Church."}]} | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.zh-hans` | "义人栽种在主的殿前，发旺在我们上帝院里，※让我们在他的圣日欢欣庆贺。" | "义人栽种在主的殿前，发旺在我们上帝院里，※让我们在他的圣日欢欣庆贺." |
| `morning.invitatory.texts.1.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.1.zh-hans` | "主是精修者的君王，※我们当来俯伏敬拜。" | "主是精修者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory_hymn.title` | {"zh-hant": "Iste Confessor", "zh-hans": "Iste Confessor", "en": ""} | "Iste Confessor" |
| `morning.invitatory_hymn.verses.0.en` | "THIS the Confessor of the Lord, whose triumph\nNow all the faithful celebrate, with gladness\nErst on this feast-day merited to enter\nInto his glory." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.1.en` | "Saintly and prudent, modest in behavior,\nPeaceful and sober, chaste was he, and lowly,\nWhile that life's vigour, coursing through his members,\nQuickened his being." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.2.en` | "Sick ones of old time, to his tomb resorting,\nSorely by ailments manifold afflicted,\nOft-times have welcomed health and strength returning,\nAt his petition." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.en` | "Whence we in chorus gladly do him honor,\nChanting his praises with devout affection,\nThat in his merits we may have a portion,\nNow and forever." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.4.en` | "His be the glory, power, and salvation:\nWho over all things reigneth in the highest,\nEarth's mighty fabric ruling and directing,\nOnely and Trinal. Amen." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.4.zh-hans` | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主.阿们." | "五、尊荣并权能，救恩荣耀齐弘，\n全归至高君，永在至尊天宫；\n恒常且无限，掌管万有无穷，\n三一真上主。阿们。" |
| `morning.office_hymn.title` | {"zh-hant": "Iesu, corona celsior", "zh-hans": "Iesu, corona celsior", "en": ""} | "Iesu, corona celsior" |
| `morning.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、耶稣基督天府冠冕，\n永恒至高真理上主；\n嘉纳主之精修圣者，\n偕同诸圣永享荣华。" | "一、耶稣基督天府冠冕，\n永恒至高真理上主；\n嘉纳主之精修圣者，\n偕同诸圣永享荣华." |
| `morning.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.1.zh-hans` | "二、俯听我众卑微恳求，\n借其代祷蒙主庇护；\n涤除我等诸般罪愆，\n悉数斩断罪恶桎梏。" | "二、俯听我众卑微恳求，\n藉其代祷蒙主庇护；\n涤除我等诸般罪愆，\n悉数斩断罪恶桎梏." |
| `morning.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.2.zh-hans` | "三、岁月周环时光流转，\n荣耀佳节今朝重临；\n主之忠仆脱离尘躯，\n荣登高天觐见主面。" | "三、岁月周环时光流转，\n荣耀佳节今朝重临；\n主之忠仆脱离尘躯，\n荣登高天觐见主面." |
| `morning.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.3.zh-hans` | "四、视此尘世虚妄欢乐，\n浮华名利皆如尘土；\n鄙弃诸般世俗污秽，\n终获天府凯旋奇乐。" | "四、视此尘世虚妄欢乐，\n浮华名利皆如尘土；\n鄙弃诸般世俗污秽，\n终获天府凯旋奇乐." |
| `morning.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.4.zh-hans` | "五、恒常宣认主为君王，\n仰赖基督宏恩大德；\n狂傲仇敌践踏足下，\n奋勇击退众魔魑魅。" | "五、恒常宣认主为君王，\n仰赖基督宏恩大德；\n狂傲仇敌践踏足下，\n奋勇击退众魔魑魅." |
| `morning.office_hymn.verses.5.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.5.zh-hans` | "六、信德昭彰美名远播，\n坚定恒常宣信其主；\n严守斋戒克己修身，\n终获高天灵粮滋养。" | "六、信德昭彰美名远播，\n坚定恒常宣信其主；\n严守斋戒克己修身，\n终获高天灵粮滋养." |
| `morning.office_hymn.verses.6.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.6.zh-hans` | "七、洪恩广被慈悲上主，\n俯首叩拜至尊天颜；\n念此忠仆宣信之功，\n恳求涂抹我众罪债。" | "七、洪恩广被慈悲上主，\n俯首叩拜至尊天颜；\n念此忠仆宣信之功，\n恳求涂抹我众罪债." |
| `morning.office_hymn.verses.7.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.zh-hans` | "主引导义人走入正路，" | "主引导义人走入正路." |
| `morning.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.people.zh-hans` | "将上帝的国指示给他。" | "将上帝的国指示给他." |
| `morning.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `morning.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `morning.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `morning.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normal.zh-hans` | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求。" | "这是一位在上帝之前行大事之人，※他的教导充满全地；愿他为众人的罪过代求." |
| `evening.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.zh-hans` | "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪。" | "宝座中的羔羊必牧养他们，领他们到生命水的泉源；上帝必擦去他们一切的眼泪." |
| `evening.office_hymn.title` | {"zh-hant": "Jesu, sacerdotum decus", "zh-hans": "Jesu, sacerdotum decus", "en": ""} | "Jesu, sacerdotum decus" |
| `evening.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美。" | "一、求救世主耶稣垂听，\n圣人荣冕即将临近。\n现以温柔爱心接纳，\n我们献上祈祷赞美." |
| `evening.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.1.zh-hans` | "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日。" | "二、这位谦卑精修圣人，\n今日获得荣耀美名。\n忠信子民每年欢欣，\n庄严庆贺圣人节日." |
| `evening.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.2.zh-hans` | "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中。" | "三、他已抛弃世界虚荣，\n视为虚空转瞬即逝。\n现已列入天使歌团，\n进入无穷喜乐之中." |
| `evening.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.3.zh-hans` | "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽。" | "四、恳求仁慈上帝赐恩，\n求使我们随他芳踪。\n藉着圣人祈祷之能，\n脱离一切罪恶污秽." |
| `evening.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.zh-hans` | "义人的口谈论智慧；" | "义人的口谈论智慧." |
| `evening.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.zh-hans` | "他的舌头讲说公平。" | "他的舌头讲说公平." |
| `evening.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "主啊，※你交给我五千。请看，我又赚了五千。" | "主啊，※你交给我五千。请看，我又赚了五千." |
| `evening.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "他是※那忠心又精明的仆人，主人派他管理自己的家。" | "他是※那忠心又精明的仆人，主人派他管理自己的家." |
| `evening.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了。" | "主人※来了，他来叩门，看见仆人警醒，那些仆人就有福了." |
| `evening.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |

### sanctorale_0922_maurice_and_companions.json

- 通用：`common_martyrs_outside_easter`（多位殉道者通用（復活期外）.json）。
- 移除並繼承：`morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。
- 所有祝文、選項標籤及頂層身分資料保留。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normals.0.en` | "" | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normals.0.zh-hans` | "追随基督的众圣徒在天国欢庆，※他们追随基督的脚踪，为爱祂而倾流了鲜血，因此永远与基督为王。" | "追随基督的众圣徒在天国欢庆，※他们追随基督的脚踪，为爱祂而倾流了鲜血，因此永远与基督为王." |
| `vigil.benedictus_antiphon.normals.1.en` | "" | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normals.1.zh-hans` | "这些圣者，※因爱上帝而轻视了世人的威胁；神圣的殉道者们，与天使在永恒的国中欢欣喜乐；圣民之死何等宝贵，他们永远侍立在主面前，与主永不分离。" | "这些圣者，※因爱上帝而轻视了世人的威胁；神圣的殉道者们，与天使在永恒的国中欢欣喜乐；圣民之死何等宝贵，他们永远侍立在主面前，与主永不分离." |
| `vigil.bible_sentences.0.reference.en` | "(Rev.vii.14.)" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.en` | "THESE are they which came out of great tribulation, and have washed their robes, and made them white in the blood of the Lamb." | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.zh-hans` | "这些人是从大患难中出来的，他们曾用羔羊的血把衣裳洗得洁白。" | "这些人是从大患难中出来的，他们曾用羔羊的血把衣裳洗得洁白." |
| `vigil.office_hymn.title` | {"zh-hant": "Sanctorum meritis inclyta gaudia", "zh-hans": "Sanctorum meritis inclyta gaudia", "en": ""} | "諸聖功德永受讚頌" |
| `vigil.office_hymn.verses.0.en` | "THE merits of the Saints, Blessèd for evermore, \nTheir love that never faints, The toils they bravely bore: \nFor these the Church today Pours forth her joyous lay, \nThese victors win the noblest bay." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.0.zh-hans` | "一、诸圣功勋可颂，永蒙福乐无穷；\n爱心永不衰歇，勇忍艰劳不辞。\n教会今朝为此，欢然歌咏颂扬；\n得胜圣徒荣冠高戴。" | "一、诸圣功德永受赞颂，\n爱心不灭永坚强勇，\n勇敢忍受诸般艰辛，\n教会今献喜乐颂歌，\n得胜者赢最高冠冕，\n荣耀桂冠永辉煌光." |
| `vigil.office_hymn.verses.0.zh-hant` | "一、諸聖功勳可頌，永蒙福樂無窮；\n愛心永不衰歇，勇忍艱勞不辭。\n教會今朝為此，歡然歌詠頌揚；\n得勝聖徒榮冠高戴。" | "一、諸聖功德永受讚頌，\n愛心不滅永堅強勇，\n勇敢忍受諸般艱辛，\n教會今獻喜樂頌歌，\n得勝者贏最高冠冕，\n榮耀桂冠永輝煌光。" |
| `vigil.office_hymn.verses.1.en` | "They whom this world of ill, While it yet held, abhorred; \nIts withering flow'rs that still They spurned withione faccord:\nThey knew them short-lived all, And followed at thy call, \nKing Jesu, to thine heav'nly hall. " | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.1.zh-hans` | "二、邪世尚据人间，曾憎恶诸圣徒；\n凋零花朵仍开，齐心轻蔑弃绝。\n深知万有短暂，遂应主慈声召；\n君王耶稣召入天庭。" | "二、邪世曾憎恶诸圣徒，\n凋零花朵不屑顾看，\n万物短暂心深知晓，\n回应耶稣召唤声音，\n天国殿堂永享安居，\n至圣君王恩典无穷." |
| `vigil.office_hymn.verses.1.zh-hant` | "二、邪世尚據人間，曾憎惡諸聖徒；\n凋零花朵仍開，齊心輕蔑棄絕。\n深知萬有短暫，遂應主慈聲召；\n君王耶穌召入天庭。" | "二、邪世曾憎惡諸聖徒，\n凋零花朵不屑顧看，\n萬物短暫心深知曉，\n回應耶穌召喚聲音，\n天國殿堂永享安居，\n至聖君王恩典無窮。" |
| `vigil.office_hymn.verses.2.en` | "For thee all pangs they bare, Fury and mortal hate;\nThe cruèl scourge to tear, The hook to lacerate:\nBut vain their foes' intent For, every torment spent,\nTheir valiant spirits stood unbent." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.2.zh-hans` | "三、为主忍受诸苦，狂怒死亡仇恨；\n酷鞭撕裂其身，铁钩割伤其肉。\n仇敌徒劳无功，诸般酷刑既尽；\n英魂坚立终不屈挠。" | "三、为主忍受诸多苦难，\n狂怒仇恨齐临身上，\n残鞭撕裂铁钩伤害，\n敌意徒然苦尽时刻，\n勇敢精神永不屈服，\n坚毅心志立如山岳." |
| `vigil.office_hymn.verses.2.zh-hant` | "三、為主忍受諸苦，狂怒死亡仇恨；\n酷鞭撕裂其身，鐵鉤割傷其肉。\n仇敵徒勞無功，諸般酷刑既盡；\n英魂堅立終不屈撓。" | "三、為主忍受諸多苦難，\n狂怒仇恨齊臨身上，\n殘鞭撕裂鐵鉤傷害，\n敵意徒然苦盡時刻，\n勇敢精神永不屈服，\n堅毅心志立如山岳。" |
| `vigil.office_hymn.verses.3.en` | "Like sheep their blood they poured, And without groan or tear;\nThey bent before the sword, For that their King most dear;\nTheir souls, serenely blest, In patience they possessed,\nAnd looked in hope towards their rest." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.zh-hans` | "四、如羊倾流鲜血，无呻吟亦无泪；\n俯首在剑刃前，皆为至爱君王。\n灵魂安然蒙福，忍耐持守其灵；\n盼望安息欣然仰望。" | "四、如羊流血无声息叹，\n无痛无泪跪剑前方，\n皆为至爱君王缘故，\n灵魂安详得享福乐，\n忍耐等候持守盼望，\n仰望安息到达永恒." |
| `vigil.office_hymn.verses.3.zh-hant` | "四、如羊傾流鮮血，無呻吟亦無淚；\n俯首在劍刃前，皆為至愛君王。\n靈魂安然蒙福，忍耐持守其靈；\n盼望安息欣然仰望。" | "四、如羊流血無聲息嘆，\n無痛無淚跪劍前方，\n皆為至愛君王緣故，\n靈魂安詳得享福樂，\n忍耐等候持守盼望，\n仰望安息到達永恆。" |
| `vigil.office_hymn.verses.4.en` | "What tongue may here declare, Fancy or thought descry,\nThe joys thou dost prepare For these thy Saints on high?\nEmpurpled in the flood Of their victorious blood,\nThey won the laurel from their God." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.zh-hans` | "五、何舌能宣说尽，何思能够窥知？\n主为诸圣预备，高天喜乐何深！\n浸染凯旋鲜血，披上紫红荣光；\n从上帝手赢得桂冠。" | "五、何言能述天堂喜乐，\n何思能知主爱恩情，\n为圣徒备高深福乐，\n浸染得胜血流中间，\n上主亲赐桂冠戴头，\n荣耀冠冕永远辉煌." |
| `vigil.office_hymn.verses.4.zh-hant` | "五、何舌能宣說盡，何思能夠窺知？\n主為諸聖預備，高天喜樂何深！\n浸染凱旋鮮血，披上紫紅榮光；\n從上帝手贏得桂冠。" | "五、何言能述天堂喜樂，\n何思能知主愛恩情，\n為聖徒備高深福樂，\n浸染得勝血流中間，\n上主親賜桂冠戴頭，\n榮耀冠冕永遠輝煌。" |
| `vigil.office_hymn.verses.5.en` | "To thee, O Lord most high, One in Three Persons still, \nTo pardon us we cry, And to preserve from ill:\nHere give thy servants peace, Hereafter glad release,\nAnd pleasures that shall never cease. Amen." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.5.zh-hans` | "六、至高上主三一，求赦我众罪愆，\n又保守免诸恶；今赐仆人平安，\n来世欢然解脱，永享无尽喜乐，\n永享无穷不息福乐。阿们。" | "六、至高上主三一上帝，\n求赐赦罪保守平安，\n今赐仆人享受和平，\n来世欢欣得到释放，\n永恒喜乐永无穷尽，\n颂赞荣耀永不息止。阿们。" |
| `vigil.office_hymn.verses.5.zh-hant` | "六、至高上主三一，求赦我眾罪愆，\n又保守免諸惡；今賜僕人平安，\n來世歡然解脫，永享無盡喜樂，\n永享無窮不息福樂。阿們。" | "六、至高上主三一上帝，\n求賜赦罪保守平安，\n今賜僕人享受和平，\n來世歡欣得到釋放，\n永恆喜樂永無窮盡，\n頌讚榮耀永不息止。阿們。" |
| `vigil.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.people.zh-hans` | "正直人赞美祂是理所应当的。" | "正直人赞美祂是理所应该的." |
| `vigil.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "这些圣人历尽艰苦，※使他们在平安之中得到了殉道的棕榈枝。" | "这些圣人历尽艰苦，※使他们在平安之中得到了殉道的棕榈枝." |
| `vigil.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "这些圣者手持棕树枝※来到了天国，他们堪当由上帝手中接受荣耀的冠冕。" | "这些圣者手持棕树枝※来到了天国，他们堪当由上帝手中接受荣耀的冠冕." |
| `vigil.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "圣者们的身体※虽被安葬于平安之中，他们的名永存不朽。" | "圣者们的身体※虽被安葬于平安之中，他们的名永存不朽." |
| `vigil.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主的殉道者阿，※请赞颂上主直到永远。" | "主的殉道者阿，※请赞颂上主直到永远." |
| `vigil.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "殉道者的歌咏团，※请在至高的天上赞美主。" | "殉道者的歌咏团，※请在至高的天上赞美主." |
| `vigil.psalm_antiphons.lectionary_1943.en` | "The Saints through faith subdued kingdoms, they wrought righteousness, they obtained the promises." | "The Saints through faith ※subdued kingdoms, they wrought righteousness, they obtained the promises." |
| `vigil.psalm_antiphons.lectionary_1943.zh-hans` | "诸圣藉着信，制伏了敌国，行了公义，得了应许。" | "诸圣藉着信，※制伏了敌国，行了公义，得了应许。" |
| `vigil.psalm_antiphons.lectionary_1943.zh-hant` | "諸聖藉著信，制伏了敵國，行了公義，得了應許。" | "諸聖藉著信，※制伏了敵國，行了公義，得了應許。" |
| `morning.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal.zh-hans` | "这些人轻视了世俗的生活，※获得了天国的赏报，并在羔羊的血中洗净了他们的衣服；天国是他们的。" | "这些人轻视了世俗的生活，※获得了天国的赏报，并在羔羊的血中洗净了他们的衣服；天国是他们的." |
| `morning.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传", "en": "For the Legend"}, "source": {"zh-hant": "", "zh-hans": "", "en": ""}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。", "en": ""}, "paragraphs": [{"zh-hant": "聖莫里斯於二八七年在高盧的阿高努姆附近殉道。有些權威文獻認為，這些聖人即是底比斯軍團；這是一支從上埃及招募而來的基督徒士兵部隊。軍隊行至高盧邊境時停下，要向眾神獻祭；底比斯軍團為免參與這不聖潔的祭典而受玷污，便退出隊伍。因此，皇帝派遣士兵到他們那裡，命令他們若珍惜自己的性命，就要回去參與祭祀。他們回答說，基督信仰不容許他們如此行。於是，皇帝派出部分軍隊攻擊底比斯人，下令每十人中先殺一人。出於自願，並在莫里斯的懇切勸勉下，他們寧願選擇忍受殉道之苦，也不願遵從不義皇帝的命令。最後，皇帝在九月二十二日下令全軍攻擊他們，將他們全部殺害。而他們勇敢地宣認基督，直到最後。", "zh-hans": "圣莫里斯于二八七年在高卢的阿高努姆附近殉道。有些权威文献认为，这些圣人即是底比斯军团；这是一支从上埃及招募而来的基督徒士兵部队。军队行至高卢边境时停下，要向众神献祭；底比斯军团为免参与这不圣洁的祭典而受玷污，便退出队伍。因此，皇帝派遣士兵到他们那里，命令他们若珍惜自己的性命，就要回去参与祭祀。他们回答说，基督信仰不容许他们如此行。于是，皇帝派出部分军队攻击底比斯人，下令每十人中先杀一人。出于自愿，并在莫里斯的恳切劝勉下，他们宁愿选择忍受殉道之苦，也不愿遵从不义皇帝的命令。最后，皇帝在九月二十二日下令全军攻击他们，将他们全部杀害。而他们勇敢地宣认基督，直到最后。", "en": "St. Maurice died in 287, near Agaunum, in Gaul. These holy men are by some authorities identified with the Theban Legion, that is, a band of Christian soldiers recruited from Upper Egypt. At the frontiers of Gaul, the army paused to sacrifice to the gods; and the Theban Legion, that they might not be defiled by any share in the unhallowed rites, withdrew themselves. Therefore the Emperor sent soldiers unto them to bid them, if they valued their lives, to come back to the sacrifice. They answered that the Christian religion did not allow them so to do. He therefore despatched a part of his army to the Thebans, with orders to begin by killing one man in every ten of them. By their own will, and at the urgent exhortation of Maurice, they chose rather to endure this martyrdom than to obey the commandment of the unrighteous Emperor. At the last, the Emperor, upon the 22nd day of September, bade his whole army fall upon them and slay them all. And they confessed Christ bravely even to the end."}]} | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.zh-hans` | "上帝在祂的圣徒中显为奇妙可畏，※我们当来俯伏敬拜。" | "上帝在祂的圣徒中显为奇妙可畏，※我们当来俯伏敬拜." |
| `morning.invitatory.texts.1.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.1.zh-hans` | "主是殉道者的君王，※我们当来俯伏敬拜。" | "主是殉道者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory_hymn.title` | {"zh-hant": "基督君王永恆恩賜", "zh-hans": "基督君王永恒恩赐", "en": ""} | "基督君王永恆恩賜" |
| `morning.invitatory_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.0.zh-hans` | "一、基督君王永恒恩赐，\n献上歌声不断赞颂，\n殉道圣者光荣事迹，\n感恩之心驱散忧伤。" | "一、基督君王永恒恩赐，\n献上歌声不断赞颂，\n殉道圣者光荣事迹，\n感恩之心驱散忧伤." |
| `morning.invitatory_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.1.zh-hans` | "二、勇敢面对时代恐惧，\n苦难不移崇高信仰，\n圣洁死亡带来安息，\n真福同享永恒荣光。" | "二、勇敢面对时代恐惧，\n苦难不移崇高信仰，\n圣洁死亡带来安息，\n真福同享永恒荣光." |
| `morning.invitatory_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.2.zh-hans` | "三、猛兽张齿裂骨噬肌，\n烈焰焚躯圣徒不移，\n刑钩贯体铁刃凌欺，\n诸般酷虐圣者无遗。" | "三、猛兽张齿裂骨噬肌，\n烈焰焚躯圣徒不移，\n刑鈎贯体铁刃凌欺，\n诸般酷虐圣者无遗." |
| `morning.invitatory_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.zh-hans` | "四、圣血滂沱体骸残损，\n痛楚虽极心志愈韧，\n靠主恩典立场坚定，\n苦难中间毫不动摇。" | "四、圣血滂沱体骸残损，\n痛楚虽极心志愈韧，\n靠主恩典立场坚定，\n苦难中间毫不动摇." |
| `morning.invitatory_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.title` | {"zh-hant": "榮耀殉道圣者之君", "zh-hans": "荣耀殉道圣者之君", "en": ""} | "榮耀殉道圣者之君" |
| `morning.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日。" | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日." |
| `morning.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.1.zh-hans` | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪。" | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪." |
| `morning.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.2.zh-hans` | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕。" | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕." |
| `morning.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.zh-hans` | "上帝在祂的圣徒中显为奇妙可畏。" | "上帝在祂的圣徒中显为奇妙可畏." |
| `morning.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.people.zh-hans` | "祂的威严满有荣耀。" | "祂的威严满有荣耀." |
| `morning.psalm_antiphons.antiphons.0.en` | "Thy Saints, O Lord, shall flourish like the lily, alleluia; ※and shall be even as the odour of balsam before thee, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "主的圣徒必如百合花开放，※哈利路亚；他们必如香膏的馨香立于主面前，哈利路亚。" | "主的圣徒必如百合花开放，※哈利路亚；他们必如香膏的馨香立于主面前，哈利路亚." |
| `morning.psalm_antiphons.antiphons.1.en` | "In the heavenly kingdom † the Blessed have their dwelling-place, alleluia; ※and their rest for ever and ever, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.1.zh-hans` | "天国是诸圣的居所，※哈利路亚，他们要永远安息，哈利路亚。" | "天国是诸圣的居所，※哈利路亚，他们要永远安息，哈利路亚." |
| `morning.psalm_antiphons.antiphons.2.en` | "Within the veil + thy blessed Saints, O Lord, ※continually do cry, alleluia, alleluia, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "主的诸圣在帷幕内高呼：※哈利路亚，哈利路亚，哈利路亚。" | "主的诸圣在帷幕内高呼：※哈利路亚，哈利路亚，哈利路亚." |
| `morning.psalm_antiphons.antiphons.3.en` | "O ye spirits + and souls of the righteous, ※sing ye praise to the Lord our God, alleluia, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "义人的灵魂，※请歌唱赞美我们的上帝，哈利路亚，哈利路亚。" | "义人的灵魂，※请歌唱赞美我们的上帝，哈利路亚，哈利路亚." |
| `morning.psalm_antiphons.antiphons.4.en` | "Then shall the righteous † shine forth as the sun ※in the presence of God, alleluia." | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.0.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.0.zh-hans` | "上帝要擦去圣徒一切的眼泪；※不再有死亡，也不再有悲哀、哭号、痛苦，因为先前的事都过去了。" | "上帝要擦去圣徒一切的眼泪；※不再有死亡，也不再有悲哀、哭号、痛苦，因为先前的事都过去了." |
| `evening.benedictus_antiphon.normals.1.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.1.zh-hans` | "诸圣手执棕枝直抵天国，※他们从主手中领受了华冠。" | "诸圣手执棕枝直抵天国，※他们从主手中领受了华冠." |
| `evening.bible_sentences.0.reference.en` | "(2 Esdras.ii.45.)" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.en` | "THESE be they that have put off the mortal clothing, and put on the immortal, and have confessed the name of God: now are they crowned, and receive palms." | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.zh-hans` | "这些人是脱了那必死的衣裳，穿上那不死的。他们宣认了上帝的名，现在他们戴上冠冕，又得棕树枝。" | "这些人是脱了那必死的衣裳，穿上那不死的。他们宣认了上帝的名，现在他们戴上冠冕，又得棕树枝." |
| `evening.office_hymn.title` | {"zh-hant": "榮耀殉道圣者之君", "zh-hans": "荣耀殉道圣者之君", "en": ""} | "榮耀殉道圣者之君" |
| `evening.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日。" | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日." |
| `evening.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.1.zh-hans` | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪。" | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪." |
| `evening.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.2.zh-hans` | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕。" | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕." |
| `evening.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.3.zh-hans` | "四、仁君基督永享尊荣，\n偕同天父同享荣耀；\n+也归于保惠师圣灵，\n三一上帝永世无尽。阿们。" | "四、仁君基督永享尊荣，\n偕同天父同享荣耀；\n也归于保惠师圣灵，\n三一上帝永世无尽。阿们。" |
| `evening.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.zh-hans` | "在上帝面前踊跃欢喜。" | "在上帝面前勇跃欢喜." |
| `evening.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "这些圣徒为上帝舍身，※并用羔羊的血把衣裳洗得洁白。" | "这些圣徒为上帝舍身，※并用羔羊的血把衣裳洗得洁白." |
| `evening.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.1.zh-hans` | "圣徒藉着信，※制伏了列国，行了公义，得了应许。" | "圣徒藉着信，※制伏了列国，行了公义，得了应许." |
| `evening.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "圣徒如鹰返老返童，※他们如百合花盛开在主的城里。" | "圣徒如鹰返老返童，※他们如百合花盛开在主的城里." |
| `evening.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "上帝要擦去圣徒一切的眼泪；※不再有死亡，也不再有悲哀、哭号、痛苦，因为先前的事都过去了。" | "上帝要擦去圣徒一切的眼泪；※不再有死亡，也不再有悲哀、哭号、痛苦，因为先前的事都过去了." |
| `evening.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.4.zh-hans` | "天国是诸圣的居所，※他们要永远安息。" | "天国是诸圣的居所，※他们要永远安息." |

### sanctorale_0923_linus.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。
- 所有祝文、選項標籤及頂層身分資料保留。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normal.zh-hans` | "这真是一位殉道者，※他为基督的名倾流了鲜血；他不畏惧审判者的威吓，不追求世俗的尊贵荣耀，喜乐地进入天国。" | "这真是一位殉道者，※他为基督的名倾流了鲜血；他不畏惧审判者的威吓，不追求世俗的尊贵荣耀，喜乐地进入天国." |
| `vigil.bible_sentences.0.reference.en` | "(Matt.x.22.)" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.en` | "AND ye shall be hated of all men for my name's sake: but he that endureth to the end shall be saved." | （原檔沒有此欄位） |
| `vigil.office_hymn.title` | {"zh-hant": "Deus tuorum militum", "zh-hans": "Deus tuorum militum", "en": "Deus tuorum militum"} | "上帝義子勇毅無雙" |
| `vigil.office_hymn.verses.0.en` | "MARTYR of God! the only Son \nTo victory hath led thee on;\nThine every foe now prostrate lies, \nAnd heaven accords the victor's prize." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.1.en` | "O may thy prayer. for us obtain \nThe cleansing of each guilty stain;\nShield us from sin's contagious blight: \nPut life's long weariness to flight." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.2.en` | "Now riven are the bonds in twain, \nWhich did thy saintly limbs enchain;\nFrom us the bonds of earth remove, \nThrough God the Son's redeeming love." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.en` | "All laud to God the Father be; \nAll praise, eternal Son, to thee;\nAll glory, as is ever meet, \nTo God the Holy Paraclete. Amen." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.zh-hans` | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽.阿们." | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽。阿们。" |
| `vigil.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.leader.zh-hans` | "主加增他尊贵荣耀。" | "主加增他尊贵荣耀." |
| `vigil.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "凡在人面前认我的，※我在我天上的父面前也必认他。" | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `vigil.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `vigil.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `vigil.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主说：※若有人服事我，我父必尊重他。" | "主说：※若有人服事我，我父必尊重他." |
| `vigil.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "圣父阿，※我在哪里，服事我的人也要在哪里。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |
| `morning.benedictus_antiphon.normals.0.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normals.0.zh-hans` | "一粒麦子不落在地里死了，※仍旧是一粒。" | "一粒麦子不落在地里死了，※仍旧是一粒." |
| `morning.benedictus_antiphon.normals.1.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normals.1.zh-hans` | "主说：若有人要跟从我，※就当舍己，背起自己的十字架来跟从我。" | "主说：若有人要跟从我，※就当舍己，背起自己的十字架来跟从我." |
| `morning.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传", "en": "For the Legend"}, "source": {"zh-hant": "", "zh-hans": "", "en": ""}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。", "en": ""}, "paragraphs": [{"zh-hant": "據聖愛任紐、聖希坡呂托及其他人的見證，利奴是聖使徒彼得在羅馬主教座的直接繼任者。依照愛任紐的說法，真福保羅在《提摩太後書》中提到他，說：「友布羅、布田、利奴和眾弟兄，都問你安。」成於第六世紀的《教宗名錄》記載，利奴是義大利人，出身於托斯卡尼地區；他在主教座上任職十一年三個月又十二日；他生活於尼祿皇帝在位期間；他曾舉行兩次按立，按立了十五位主教和十八位司祭；他於十二月二十三日安葬在梵蒂岡、真福彼得的遺體旁。該書又稱他以殉道獲得冠冕；在《格里高利感恩經》中，他也列於殉道者之中。然而，就現有的認識而言，他在羅馬任職期間似乎沒有發生迫害基督徒的事，因此人們認為，「殉道者」這稱號是為表明他作為精修聖人服事基督時所忍受的巨大勞苦與苦難。據信他約於七十八年歸向上帝。", "zh-hans": "据圣爱任纽、圣希坡吕托及其他人的见证，利奴是圣使徒彼得在罗马主教座的直接继任者。依照爱任纽的说法，真福保罗在《提摩太后书》中提到他，说：「友布罗、布田、利奴和众弟兄，都问你安。」成于第六世纪的《教宗名录》记载，利奴是意大利人，出身于托斯卡尼地区；他在主教座上任职十一年三个月又十二日；他生活于尼禄皇帝在位期间；他曾举行两次按立，按立了十五位主教和十八位司祭；他于十二月二十三日安葬在梵蒂冈、真福彼得的遗体旁。该书又称他以殉道获得冠冕；在《格里高利感恩经》中，他也列于殉道者之中。然而，就现有的认识而言，他在罗马任职期间似乎没有发生迫害基督徒的事，因此人们认为，「殉道者」这称号是为表明他作为精修圣人服事基督时所忍受的巨大劳苦与苦难。据信他约于七十八年归向上帝。", "en": "LINUS was the immediate successor of the Apostle Peter in the Roman See, according to the testimony of Saints Irenæus and Hippolytus, and others. And according to Irenæus, blessed Paul maketh mention of him in his second Epistle to Timothy, where he saith: Eubulus greeteth thee, and Pudens, and Linus. The Pontifical Book, dating from the sixth century, saith that he was an Italian by nation, of the Tuscan region; that he sat in the episcopal chair eleven years, three months, and twelve days; that he lived in the time of Nero; that he held two ordinations, wherein he made fifteen bishops and eighteen presbyters; and that he was buried beside the body of blessed Peter at the Vatican on December 23rd. This same book saith that he was crowned by martyrdom. And in the Gregorian Canon he is mentioned amongst the Martyrs. But because, so far as is known, no persecution of Christians took place in Rome during his period, it is supposed that he was given the title of Martyr to describe the great sufferings and labours wherewith he served Christ as a Confessor. He is believed to have gone to God about the year 78."}, {"zh-hant": "德克拉自教會最早期起便備受稱頌；在東方禮儀中，她被尊稱為「女性首位殉道者」與「與使徒同等者」。然而，關於她並沒有可靠的歷史記錄，只有民間流傳的傳統。拉丁禮儀中的《臨終者交託禮》提到她所忍受的三樣極其殘酷的苦難；這些話也指向很早便流傳的一位名叫德克拉的童貞女的故事。首先，她在自己的家中因信仰而遭受嚴酷迫害。她從聖使徒保羅領受信仰後，拒絕了一門為她安排的婚事；因此，她受到父母和朋友嚴重的虐待，只得為保全性命而秘密逃離。其次，她被投入火中。她的求婚者因她是基督徒而將她逮捕，並判她焚燒之刑；但旋風挾著雲雨而起，撲滅了火，使她逃脫。第三次，當她再度被判死刑時，她被投入競技場的野獸中；野獸卻沒有傷害她，因此她得到釋放。之後，她前往聖使徒保羅那裡，有一段時間協助他的使徒工作。其後，她退居洞穴，作隱修女，並在九十歲時平安離世。這段關於德克拉的記述，無疑是為表明早期基督徒當如何為基督甘心忍受苦難。因此，德克拉之名歷世歷代已成為弱者藉著上帝能力而得勝的象徵。", "zh-hans": "德克拉自教会最早期起便备受称颂；在东方礼仪中，她被尊称为「女性首位殉道者」与「与使徒同等者」。然而，关于她并没有可靠的历史记录，只有民间流传的传统。拉丁礼仪中的《临终者交托礼》提到她所忍受的三样极其残酷的苦难；这些话也指向很早便流传的一位名叫德克拉的童贞女的故事。首先，她在自己的家中因信仰而遭受严酷迫害。她从圣使徒保罗领受信仰后，拒绝了一门为她安排的婚事；因此，她受到父母和朋友严重的虐待，只得为保全性命而秘密逃离。其次，她被投入火中。她的求婚者因她是基督徒而将她逮捕，并判她焚烧之刑；但旋风挟着云雨而起，扑灭了火，使她逃脱。第三次，当她再度被判死刑时，她被投入竞技场的野兽中；野兽却没有伤害她，因此她得到释放。之后，她前往圣使徒保罗那里，有一段时间协助他的使徒工作。其后，她退居洞穴，作隐修女，并在九十岁时平安离世。这段关于德克拉的记述，无疑是为表明早期基督徒当如何为基督甘心忍受苦难。因此，德克拉之名历世历代已成为弱者借着上帝能力而得胜的象征。", "en": "THECLA hath been acclaimed since the earliest days of the Church, and in the Eastern Liturgy is entitled: Protomartyr of Women and Equal of the Apostles. However, no trustworthy historical records are to be found of her, but only a popular tradition. The Order for the Commendation of a Dying Person, to be found in the Latin Ritual, speaketh of three most cruel torments which she endured, and in these words pointeth to the stories which were very early written concerning a maiden named Thecla. First, she was grievously tormented by persecutions in her own home. For, after she had accepted the Faith from the holy Apostle Paul, she refused the proposal of marriage which she had received, and thereupon was so mistreated by her parents and friends that she was obliged for safety to flee away secretly. Secondly, she was cast into a fire. For her suitor had her arrested as a Christian, and condemned to be burnt. But a whirlwind of clouds and rain arose, and put out the fire, and enabled her to escape. Thirdly, when she was for the second time condemned to death, she was thrown to the wild beasts in the arena. But the beasts did not harm her, and so she was set free. Whereupon she went to the Apostle Paul, and for a while assisted him in his apostolic labours. Thereafter she retired to a cave, and lived as an anchoress, and died in peace at the age of ninety. This account of Thecla was doubtless written to show what things Christians of the early days were expected to endure cheerfully for Christ. And therefore the name of Thecla hath been for many ages a symbol of the triumph of the weak through divine strength."}]} | （原檔沒有此欄位） |
| `morning.invitatory.text.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.text.zh-hans` | "主是殉道者的君王，※我们当来俯伏敬拜。" | "主是殉道者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory_hymn.title` | {"zh-hant": "Deus tuorum militum", "zh-hans": "Deus tuorum militum", "en": "Deus tuorum militum"} | "上帝義子勇毅無雙" |
| `morning.invitatory_hymn.verses.0.en` | "MARTYR of God! the only Son \nTo victory hath led thee on;\nThine every foe now prostrate lies, \nAnd heaven accords the victor's prize." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.1.en` | "O may thy prayer. for us obtain \nThe cleansing of each guilty stain;\nShield us from sin's contagious blight: \nPut life's long weariness to flight." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.2.en` | "Now riven are the bonds in twain, \nWhich did thy saintly limbs enchain;\nFrom us the bonds of earth remove, \nThrough God the Son's redeeming love." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.en` | "All laud to God the Father be; \nAll praise, eternal Son, to thee;\nAll glory, as is ever meet, \nTo God the Holy Paraclete. Amen." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.zh-hans` | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽.阿们." | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽。阿们。" |
| `morning.office_hymn.title` | {"zh-hant": "主之諸聖共沐主恩", "zh-hans": "主之诸圣共沐主恩", "en": ""} | "主之諸聖共沐主恩" |
| `morning.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生。" | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生." |
| `morning.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.1.zh-hans` | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年。" | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年." |
| `morning.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.2.zh-hans` | "三、为尔穿越万般艰险，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆。" | "三、为尔穿越万般艰难，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆." |
| `morning.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.3.zh-hans` | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污。" | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污." |
| `morning.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.en` | "The righteous shall blossom as the lily. " | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.people.en` | "He shall flourish for ever before the Lord." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "凡在人面前认我的，※我在我天上的父面前也必认他。" | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `morning.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.1.zh-hans` | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `morning.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `morning.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "主说：※若有人服事我，我父必尊重他。" | "主说：※若有人服事我，我父必尊重他." |
| `morning.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.4.zh-hans` | "圣父阿，※我在哪里，服事我的人也要在哪里。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |
| `evening.benedictus_antiphon.normals.0.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.0.zh-hans` | "他将世上的一切都视为无物，※以言以行，为自己在天上积蓄财宝。" | "他将世上的一切都视为无物，※以言以行，为自己在天上积蓄财宝." |
| `evening.benedictus_antiphon.normals.1.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.1.zh-hans` | "此人彻悟公义，洞悉奇伟奥秘；※他祈求至高者，终列诸圣之中。" | "此人彻悟公义，洞悉奇伟奥秘；※他祈求至高者，终列诸圣之中." |
| `evening.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.zh-hans` | "忍受试炼的人有福了，因为他经过考验以后必得生命的冠冕，这是主应许给爱他之人的。" | "忍受试炼的人有福了，因为他经过考验以后必得生命的冠冕，这是主应许给爱他之人的." |
| `evening.office_hymn.title` | {"zh-hant": "主之諸聖共沐主恩", "zh-hans": "主之诸圣共沐主恩", "en": ""} | "主之諸聖共沐主恩" |
| `evening.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生。" | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生." |
| `evening.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.1.zh-hans` | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年。" | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年." |
| `evening.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.2.zh-hans` | "三、为尔穿越万般艰险，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆。" | "三、为尔穿越万般艰难，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆." |
| `evening.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.3.zh-hans` | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污。" | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污." |
| `evening.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "凡在人面前认我的，※我在我天上的父面前也必认他。" | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `evening.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.1.zh-hans` | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `evening.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `evening.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "主说：※若有人服事我，我父必尊重他。" | "主说：※若有人服事我，我父必尊重他." |
| `evening.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.4.zh-hans` | "圣父阿，※我在哪里，服事我的人也要在哪里。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |

### sanctorale_0927_cosmas_and_damian.json

- 通用：`common_martyrs_outside_easter`（多位殉道者通用（復活期外）.json）。
- 移除並繼承：`morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。
- 所有祝文、選項標籤及頂層身分資料保留。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normals.0.en` | "" | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normals.0.zh-hans` | "全能的上帝，我们恳求主：使我们庆祝着主殉道者圣科斯马斯和圣达米盎的在天诞辰，能藉着他们的转达，从一切围困我们的凶恶中获得解救。这都是靠我主耶稣基督。主耶稣和圣父、圣灵，惟一上帝，一同永生，一同掌权，世世无尽。阿们。" | "追随基督的众圣徒在天国欢庆，※他们追随基督的脚踪，为爱祂而倾流了鲜血，因此永远与基督为王." |
| `vigil.benedictus_antiphon.normals.0.zh-hant` | "全能的上帝，我們懇求主：使我們慶祝著主殉道者圣科斯马斯和圣达米盎的在天誕辰，能藉著他們的轉達，從一切圍困我們的兇惡中獲得解救。這都是靠我主耶穌基督。主耶穌和聖父、聖靈，惟一上帝，一同永生，一同掌權，世世無盡。阿們。" | "追隨基督的眾聖徒在天國歡慶，※他們追隨基督的腳蹤，為愛祂而傾流了鮮血，因此永遠與基督為王。" |
| `vigil.benedictus_antiphon.normals.1` | （原檔沒有此欄位） | {"zh-hant": "這些聖者，※因愛上帝而輕視了世人的威脅；神聖的殉道者們，與天使在永恆的國中歡欣喜樂；聖民之死何等寶貴，他們永遠侍立在主面前，與主永不分離。", "zh-hans": "这些圣者，※因爱上帝而轻视了世人的威胁；神圣的殉道者们，与天使在永恒的国中欢欣喜乐；圣民之死何等宝贵，他们永远侍立在主面前，与主永不分离."} |
| `vigil.bible_sentences.0.reference.en` | "(Rev.vii.14.)" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.en` | "THESE are they which came out of great tribulation, and have washed their robes, and made them white in the blood of the Lamb." | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.zh-hans` | "这些人是从大患难中出来的，他们曾用羔羊的血把衣裳洗得洁白。" | "这些人是从大患难中出来的，他们曾用羔羊的血把衣裳洗得洁白." |
| `vigil.office_hymn.title` | {"zh-hant": "Sanctorum meritis inclyta gaudia", "zh-hans": "Sanctorum meritis inclyta gaudia", "en": ""} | "諸聖功德永受讚頌" |
| `vigil.office_hymn.verses.0.en` | "THE merits of the Saints, Blessèd for evermore, \nTheir love that never faints, The toils they bravely bore: \nFor these the Church today Pours forth her joyous lay, \nThese victors win the noblest bay." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.0.zh-hans` | "一、诸圣功勋可颂，永蒙福乐无穷；\n爱心永不衰歇，勇忍艰劳不辞。\n教会今朝为此，欢然歌咏颂扬；\n得胜圣徒荣冠高戴。" | "一、诸圣功德永受赞颂，\n爱心不灭永坚强勇，\n勇敢忍受诸般艰辛，\n教会今献喜乐颂歌，\n得胜者赢最高冠冕，\n荣耀桂冠永辉煌光." |
| `vigil.office_hymn.verses.0.zh-hant` | "一、諸聖功勳可頌，永蒙福樂無窮；\n愛心永不衰歇，勇忍艱勞不辭。\n教會今朝為此，歡然歌詠頌揚；\n得勝聖徒榮冠高戴。" | "一、諸聖功德永受讚頌，\n愛心不滅永堅強勇，\n勇敢忍受諸般艱辛，\n教會今獻喜樂頌歌，\n得勝者贏最高冠冕，\n榮耀桂冠永輝煌光。" |
| `vigil.office_hymn.verses.1.en` | "They whom this world of ill, While it yet held, abhorred; \nIts withering flow'rs that still They spurned withione faccord:\nThey knew them short-lived all, And followed at thy call, \nKing Jesu, to thine heav'nly hall. " | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.1.zh-hans` | "二、邪世尚据人间，曾憎恶诸圣徒；\n凋零花朵仍开，齐心轻蔑弃绝。\n深知万有短暂，遂应主慈声召；\n君王耶稣召入天庭。" | "二、邪世曾憎恶诸圣徒，\n凋零花朵不屑顾看，\n万物短暂心深知晓，\n回应耶稣召唤声音，\n天国殿堂永享安居，\n至圣君王恩典无穷." |
| `vigil.office_hymn.verses.1.zh-hant` | "二、邪世尚據人間，曾憎惡諸聖徒；\n凋零花朵仍開，齊心輕蔑棄絕。\n深知萬有短暫，遂應主慈聲召；\n君王耶穌召入天庭。" | "二、邪世曾憎惡諸聖徒，\n凋零花朵不屑顧看，\n萬物短暫心深知曉，\n回應耶穌召喚聲音，\n天國殿堂永享安居，\n至聖君王恩典無窮。" |
| `vigil.office_hymn.verses.2.en` | "For thee all pangs they bare, Fury and mortal hate;\nThe cruèl scourge to tear, The hook to lacerate:\nBut vain their foes' intent For, every torment spent,\nTheir valiant spirits stood unbent." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.2.zh-hans` | "三、为主忍受诸苦，狂怒死亡仇恨；\n酷鞭撕裂其身，铁钩割伤其肉。\n仇敌徒劳无功，诸般酷刑既尽；\n英魂坚立终不屈挠。" | "三、为主忍受诸多苦难，\n狂怒仇恨齐临身上，\n残鞭撕裂铁钩伤害，\n敌意徒然苦尽时刻，\n勇敢精神永不屈服，\n坚毅心志立如山岳." |
| `vigil.office_hymn.verses.2.zh-hant` | "三、為主忍受諸苦，狂怒死亡仇恨；\n酷鞭撕裂其身，鐵鉤割傷其肉。\n仇敵徒勞無功，諸般酷刑既盡；\n英魂堅立終不屈撓。" | "三、為主忍受諸多苦難，\n狂怒仇恨齊臨身上，\n殘鞭撕裂鐵鉤傷害，\n敵意徒然苦盡時刻，\n勇敢精神永不屈服，\n堅毅心志立如山岳。" |
| `vigil.office_hymn.verses.3.en` | "Like sheep their blood they poured, And without groan or tear;\nThey bent before the sword, For that their King most dear;\nTheir souls, serenely blest, In patience they possessed,\nAnd looked in hope towards their rest." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.zh-hans` | "四、如羊倾流鲜血，无呻吟亦无泪；\n俯首在剑刃前，皆为至爱君王。\n灵魂安然蒙福，忍耐持守其灵；\n盼望安息欣然仰望。" | "四、如羊流血无声息叹，\n无痛无泪跪剑前方，\n皆为至爱君王缘故，\n灵魂安详得享福乐，\n忍耐等候持守盼望，\n仰望安息到达永恒." |
| `vigil.office_hymn.verses.3.zh-hant` | "四、如羊傾流鮮血，無呻吟亦無淚；\n俯首在劍刃前，皆為至愛君王。\n靈魂安然蒙福，忍耐持守其靈；\n盼望安息欣然仰望。" | "四、如羊流血無聲息嘆，\n無痛無淚跪劍前方，\n皆為至愛君王緣故，\n靈魂安詳得享福樂，\n忍耐等候持守盼望，\n仰望安息到達永恆。" |
| `vigil.office_hymn.verses.4.en` | "What tongue may here declare, Fancy or thought descry,\nThe joys thou dost prepare For these thy Saints on high?\nEmpurpled in the flood Of their victorious blood,\nThey won the laurel from their God." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.4.zh-hans` | "五、何舌能宣说尽，何思能够窥知？\n主为诸圣预备，高天喜乐何深！\n浸染凯旋鲜血，披上紫红荣光；\n从上帝手赢得桂冠。" | "五、何言能述天堂喜乐，\n何思能知主爱恩情，\n为圣徒备高深福乐，\n浸染得胜血流中间，\n上主亲赐桂冠戴头，\n荣耀冠冕永远辉煌." |
| `vigil.office_hymn.verses.4.zh-hant` | "五、何舌能宣說盡，何思能夠窺知？\n主為諸聖預備，高天喜樂何深！\n浸染凱旋鮮血，披上紫紅榮光；\n從上帝手贏得桂冠。" | "五、何言能述天堂喜樂，\n何思能知主愛恩情，\n為聖徒備高深福樂，\n浸染得勝血流中間，\n上主親賜桂冠戴頭，\n榮耀冠冕永遠輝煌。" |
| `vigil.office_hymn.verses.5.en` | "To thee, O Lord most high, One in Three Persons still, \nTo pardon us we cry, And to preserve from ill:\nHere give thy servants peace, Hereafter glad release,\nAnd pleasures that shall never cease. Amen." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.5.zh-hans` | "六、至高上主三一，求赦我众罪愆，\n又保守免诸恶；今赐仆人平安，\n来世欢然解脱，永享无尽喜乐，\n永享无穷不息福乐。阿们。" | "六、至高上主三一上帝，\n求赐赦罪保守平安，\n今赐仆人享受和平，\n来世欢欣得到释放，\n永恒喜乐永无穷尽，\n颂赞荣耀永不息止。阿们。" |
| `vigil.office_hymn.verses.5.zh-hant` | "六、至高上主三一，求赦我眾罪愆，\n又保守免諸惡；今賜僕人平安，\n來世歡然解脫，永享無盡喜樂，\n永享無窮不息福樂。阿們。" | "六、至高上主三一上帝，\n求賜赦罪保守平安，\n今賜僕人享受和平，\n來世歡欣得到釋放，\n永恆喜樂永無窮盡，\n頌讚榮耀永不息止。阿們。" |
| `vigil.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.leader.zh-hans` | "你们善人应该因主欢乐" | "你们善人应该因主欢乐，" |
| `vigil.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.people.zh-hans` | "正直人赞美祂是理所应当的。" | "正直人赞美祂是理所应该的." |
| `vigil.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "这些圣人历尽艰苦，※使他们在平安之中得到了殉道的棕榈枝。" | "这些圣人历尽艰苦，※使他们在平安之中得到了殉道的棕榈枝." |
| `vigil.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "这些圣者手持棕树枝※来到了天国，他们堪当由上帝手中接受荣耀的冠冕。" | "这些圣者手持棕树枝※来到了天国，他们堪当由上帝手中接受荣耀的冠冕." |
| `vigil.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "圣者们的身体※虽被安葬于平安之中，他们的名永存不朽。" | "圣者们的身体※虽被安葬于平安之中，他们的名永存不朽." |
| `vigil.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主的殉道者阿，※请赞颂上主直到永远。" | "主的殉道者阿，※请赞颂上主直到永远." |
| `vigil.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "殉道者的歌咏团，※请在至高的天上赞美主。" | "殉道者的歌咏团，※请在至高的天上赞美主." |
| `vigil.psalm_antiphons.lectionary_1943.en` | "The Saints through faith subdued kingdoms, they wrought righteousness, they obtained the promises." | "The Saints through faith ※subdued kingdoms, they wrought righteousness, they obtained the promises." |
| `vigil.psalm_antiphons.lectionary_1943.zh-hans` | "诸圣藉着信，制伏了敌国，行了公义，得了应许。" | "诸圣藉着信，※制伏了敌国，行了公义，得了应许。" |
| `vigil.psalm_antiphons.lectionary_1943.zh-hant` | "諸聖藉著信，制伏了敵國，行了公義，得了應許。" | "諸聖藉著信，※制伏了敵國，行了公義，得了應許。" |
| `morning.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normal.zh-hans` | "这些人轻视了世俗的生活，※获得了天国的赏报，并在羔羊的血中洗净了他们的衣服；天国是他们的。" | "这些人轻视了世俗的生活，※获得了天国的赏报，并在羔羊的血中洗净了他们的衣服；天国是他们的." |
| `morning.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `morning.biography` | {"title": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传", "en": "For the Legend"}, "source": {"zh-hant": "", "zh-hans": "", "en": ""}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。", "en": ""}, "paragraphs": [{"zh-hant": "如同許多早期聖人一樣，著名殉道者聖科斯馬斯與聖達彌盎的可靠歷史記錄已不復存留。據說他們約於三〇三年為基督而死；依照一些古老記述，他們的事蹟如下：二人是弟兄，在戴克里先與馬克西彌安皇帝在位時為著名醫師；他們是阿拉伯裔，卻出生於西里西亞。他們慣常免費為窮人診治，因此在東方被稱為「無酬者」。總督呂西亞得知他們是基督徒後，便以酷刑和死亡威脅，命令他們敬拜眾神。", "zh-hans": "如同许多早期圣人一样，著名殉道者圣科斯马斯与圣达弥盎的可靠历史记录已不复存留。据说他们约于三〇三年为基督而死；依照一些古老记述，他们的事迹如下：二人是弟兄，在戴克里先与马克西弥安皇帝在位时为著名医师；他们是阿拉伯裔，却出生于西里西亚。他们惯常免费为穷人诊治，因此在东方被称为「无酬者」。总督吕西亚得知他们是基督徒后，便以酷刑和死亡威胁，命令他们敬拜众神。", "en": "AS with so many of the early Saints, no historical records remain of the famous Martyrs, Cosmas and Damian. They are said to have died for Christ about the year 303, and their story, according to some ancient accounts, is as followeth. They were eminent physicians in the time of the Emperors Diocletian and Maximin, brothers, and by race Arabs, but born in Cilicia. And they were wont to give their services to the poor, for which reason in the East they have the title: The Moneyless Ones. When the Prefect Lysias learnt that they were Christians, he commanded them to worship the gods, under threats of torments and death."}, {"zh-hant": "但他發現威脅不能動搖他們，便用水、火及其他殘酷手段折磨他們，最後下令斬首。他們如此為基督耶穌作見證，直到領受勝利的棕櫚枝。", "zh-hans": "但他发现威胁不能动摇他们，便用水、火及其他残酷手段折磨他们，最后下令斩首。他们如此为基督耶稣作见证，直到领受胜利的棕榈枝。", "en": "But when he found that threats could not shake them, he practised upon them torments by water, by fire, and by other cruelties, and lastly had them beheaded. Thus did they bear witness for Christ Jesus even until they grasped the palm of victory."}]} | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.0.zh-hans` | "上帝在祂的圣徒中显为奇妙可畏，※我们当来俯伏敬拜。" | "上帝在祂的圣徒中显为奇妙可畏，※我们当来俯伏敬拜." |
| `morning.invitatory.texts.1.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.texts.1.zh-hans` | "主是殉道者的君王，※我们当来俯伏敬拜。" | "主是殉道者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory_hymn.title` | {"zh-hant": "基督君王永恆恩賜", "zh-hans": "基督君王永恒恩赐", "en": ""} | "基督君王永恆恩賜" |
| `morning.invitatory_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.0.zh-hans` | "一、基督君王永恒恩赐，\n献上歌声不断赞颂，\n殉道圣者光荣事迹，\n感恩之心驱散忧伤。" | "一、基督君王永恒恩赐，\n献上歌声不断赞颂，\n殉道圣者光荣事迹，\n感恩之心驱散忧伤." |
| `morning.invitatory_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.1.zh-hans` | "二、勇敢面对时代恐惧，\n苦难不移崇高信仰，\n圣洁死亡带来安息，\n真福同享永恒荣光。" | "二、勇敢面对时代恐惧，\n苦难不移崇高信仰，\n圣洁死亡带来安息，\n真福同享永恒荣光." |
| `morning.invitatory_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.2.zh-hans` | "三、猛兽张齿裂骨噬肌，\n烈焰焚躯圣徒不移，\n刑钩贯体铁刃凌欺，\n诸般酷虐圣者无遗。" | "三、猛兽张齿裂骨噬肌，\n烈焰焚躯圣徒不移，\n刑鈎贯体铁刃凌欺，\n诸般酷虐圣者无遗." |
| `morning.invitatory_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.zh-hans` | "四、圣血滂沱体骸残损，\n痛楚虽极心志愈韧，\n靠主恩典立场坚定，\n苦难中间毫不动摇。" | "四、圣血滂沱体骸残损，\n痛楚虽极心志愈韧，\n靠主恩典立场坚定，\n苦难中间毫不动摇." |
| `morning.invitatory_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.title` | {"zh-hant": "榮耀殉道圣者之君", "zh-hans": "荣耀殉道圣者之君", "en": ""} | "榮耀殉道圣者之君" |
| `morning.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日。" | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日." |
| `morning.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.1.zh-hans` | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪。" | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪." |
| `morning.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.2.zh-hans` | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕。" | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕." |
| `morning.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.zh-hans` | "上帝在祂的圣徒中显为奇妙可畏。" | "上帝在祂的圣徒中显为奇妙可畏." |
| `morning.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.people.zh-hans` | "祂的威严满有荣耀。" | "祂的威严满有荣耀." |
| `morning.psalm_antiphons.antiphons.0.en` | "Thy Saints, O Lord, shall flourish like the lily, alleluia; ※and shall be even as the odour of balsam before thee, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "主的圣徒必如百合花开放，※哈利路亚；他们必如香膏的馨香立于主面前，哈利路亚。" | "主的圣徒必如百合花开放，※哈利路亚；他们必如香膏的馨香立于主面前，哈利路亚." |
| `morning.psalm_antiphons.antiphons.1.en` | "In the heavenly kingdom † the Blessed have their dwelling-place, alleluia; ※and their rest for ever and ever, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.1.zh-hans` | "天国是诸圣的居所，※哈利路亚，他们要永远安息，哈利路亚。" | "天国是诸圣的居所，※哈利路亚，他们要永远安息，哈利路亚." |
| `morning.psalm_antiphons.antiphons.2.en` | "Within the veil + thy blessed Saints, O Lord, ※continually do cry, alleluia, alleluia, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "主的诸圣在帷幕内高呼：※哈利路亚，哈利路亚，哈利路亚。" | "主的诸圣在帷幕内高呼：※哈利路亚，哈利路亚，哈利路亚." |
| `morning.psalm_antiphons.antiphons.3.en` | "O ye spirits + and souls of the righteous, ※sing ye praise to the Lord our God, alleluia, alleluia." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "义人的灵魂，※请歌唱赞美我们的上帝，哈利路亚，哈利路亚。" | "义人的灵魂，※请歌唱赞美我们的上帝，哈利路亚，哈利路亚." |
| `morning.psalm_antiphons.antiphons.4.en` | "Then shall the righteous † shine forth as the sun ※in the presence of God, alleluia." | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.0.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.0.zh-hans` | "上帝要擦去圣徒一切的眼泪；※不再有死亡，也不再有悲哀、哭号、痛苦，因为先前的事都过去了。" | "上帝要擦去圣徒一切的眼泪；※不再有死亡，也不再有悲哀、哭号、痛苦，因为先前的事都过去了." |
| `evening.benedictus_antiphon.normals.1.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.1.zh-hans` | "诸圣手执棕枝直抵天国，※他们从主手中领受了华冠。" | "诸圣手执棕枝直抵天国，※他们从主手中领受了华冠." |
| `evening.bible_sentences.0.reference.en` | "(2 Esdras.ii.45.)" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.en` | "THESE be they that have put off the mortal clothing, and put on the immortal, and have confessed the name of God: now are they crowned, and receive palms." | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.zh-hans` | "这些人是脱了那必死的衣裳，穿上那不死的。他们宣认了上帝的名，现在他们戴上冠冕，又得棕树枝。" | "这些人是脱了那必死的衣裳，穿上那不死的。他们宣认了上帝的名，现在他们戴上冠冕，又得棕树枝." |
| `evening.office_hymn.title` | {"zh-hant": "榮耀殉道圣者之君", "zh-hans": "荣耀殉道圣者之君", "en": ""} | "榮耀殉道圣者之君" |
| `evening.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日。" | "一、荣耀殉道圣者之君，\n精修圣人以主为冠；\n引领舍弃世俗欢乐，\n迈向天国光辉之日." |
| `evening.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.1.zh-hans` | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪。" | "二、救主垂怜倾听我们，\n我众祈祷上达于天；\n数算他们得胜之时，\n赦免我们所犯之罪." |
| `evening.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.2.zh-hans` | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕。" | "三、殉道者因你而得胜，\n精修者从你得恩典；\n助我克服罪恶欲望，\n好使我们获得宽恕." |
| `evening.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.zh-hans` | "在上帝面前踊跃欢喜。" | "在上帝面前勇跃欢喜." |
| `evening.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "这些圣徒为上帝舍身，※并用羔羊的血把衣裳洗得洁白。" | "这些圣徒为上帝舍身，※并用羔羊的血把衣裳洗得洁白." |
| `evening.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.1.zh-hans` | "圣徒藉着信，※制伏了列国，行了公义，得了应许。" | "圣徒藉着信，※制伏了列国，行了公义，得了应许." |
| `evening.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "圣徒如鹰返老返童，※他们如百合花盛开在主的城里。" | "圣徒如鹰返老返童，※他们如百合花盛开在主的城里." |
| `evening.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "上帝要擦去圣徒一切的眼泪；※不再有死亡，也不再有悲哀、哭号、痛苦，因为先前的事都过去了。" | "上帝要擦去圣徒一切的眼泪；※不再有死亡，也不再有悲哀、哭号、痛苦，因为先前的事都过去了." |
| `evening.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.4.zh-hans` | "天国是诸圣的居所，※他们要永远安息。" | "天国是诸圣的居所，※他们要永远安息." |

### sanctorale_0928_wenceslaus.json

- 通用：`common_martyr_outside_easter`（一位殉道者通用（復活期外）.json）。
- 移除並繼承：`vigil.psalm_antiphons.lectionary_1943`, `morning.psalm_antiphons.lectionary_1943`, `evening.psalm_antiphons.lectionary_1943`。
- 所有祝文、選項標籤及頂層身分資料保留。

| 欄位（陣列索引從 0 起） | 聖日保留內容 | 現行通用內容 |
|---|---|---|
| `vigil.benedictus_antiphon.normal.en` | "" | （原檔沒有此欄位） |
| `vigil.benedictus_antiphon.normal.zh-hans` | "这真是一位殉道者，※他为基督的名倾流了鲜血；他不畏惧审判者的威吓，不追求世俗的尊贵荣耀，喜乐地进入天国。" | "这真是一位殉道者，※他为基督的名倾流了鲜血；他不畏惧审判者的威吓，不追求世俗的尊贵荣耀，喜乐地进入天国." |
| `vigil.bible_sentences.0.reference.en` | "(Matt.x.22.)" | （原檔沒有此欄位） |
| `vigil.bible_sentences.0.text.en` | "AND ye shall be hated of all men for my name's sake: but he that endureth to the end shall be saved." | （原檔沒有此欄位） |
| `vigil.office_hymn.title` | {"zh-hant": "Deus tuorum militum", "zh-hans": "Deus tuorum militum", "en": "Deus tuorum militum"} | "上帝義子勇毅無雙" |
| `vigil.office_hymn.verses.0.en` | "MARTYR of God! the only Son \nTo victory hath led thee on;\nThine every foe now prostrate lies, \nAnd heaven accords the victor's prize." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.1.en` | "O may thy prayer. for us obtain \nThe cleansing of each guilty stain;\nShield us from sin's contagious blight: \nPut life's long weariness to flight." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.2.en` | "Now riven are the bonds in twain, \nWhich did thy saintly limbs enchain;\nFrom us the bonds of earth remove, \nThrough God the Son's redeeming love." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.en` | "All laud to God the Father be; \nAll praise, eternal Son, to thee;\nAll glory, as is ever meet, \nTo God the Holy Paraclete. Amen." | （原檔沒有此欄位） |
| `vigil.office_hymn.verses.3.zh-hans` | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽.阿们." | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽。阿们。" |
| `vigil.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `vigil.office_hymn.versicle.leader.zh-hans` | "主加增他尊贵荣耀。" | "主加增他尊贵荣耀." |
| `vigil.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.0.zh-hans` | "凡在人面前认我的，※我在我天上的父面前也必认他。" | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `vigil.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.1.zh-hans` | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `vigil.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.2.zh-hans` | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `vigil.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.3.zh-hans` | "主说：※若有人服事我，我父必尊重他。" | "主说：※若有人服事我，我父必尊重他." |
| `vigil.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `vigil.psalm_antiphons.antiphons.4.zh-hans` | "圣父阿，※我在哪里，服事我的人也要在哪里。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |
| `morning.benedictus_antiphon.normals.0.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normals.0.zh-hans` | "一粒麦子不落在地里死了，※仍旧是一粒。" | "一粒麦子不落在地里死了，※仍旧是一粒." |
| `morning.benedictus_antiphon.normals.1.en` | "" | （原檔沒有此欄位） |
| `morning.benedictus_antiphon.normals.1.zh-hans` | "主说：若有人要跟从我，※就当舍己，背起自己的十字架来跟从我。" | "主说：若有人要跟从我，※就当舍己，背起自己的十字架来跟从我." |
| `morning.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `morning.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `morning.biography` | {"title": {"zh-hant": "聖瓦茨拉夫殉道者", "zh-hans": "圣瓦茨拉夫殉道者", "en": "St. Wenceslas, Martyr"}, "source": {"zh-hant": "聖人小傳", "zh-hans": "圣人小传", "en": "For the Legend"}, "rubric": {"zh-hant": "¶ 在信經之前，可選讀以下聖人小傳/教父講道。", "zh-hans": "¶ 在信经之前，可选读以下圣人小传/教父讲道。", "en": ""}, "paragraphs": [{"zh-hant": "波希米亞公爵瓦茨拉夫，蒙上帝召叫，承擔護衛基督信仰的艱鉅使命；當時他的臣民才剛開始學習信仰，魔鬼對信仰的仇恨也剛顯露出來。他的父親是基督徒——弗拉季斯拉斯一世公爵；母親名為德拉霍米拉，卻只是名義上的基督徒。然而，他的祖母聖盧德米拉是一位極其聖潔的養育者，在敬虔中培育他。因此，他在各樣美德上都十分出眾；即使身處極大的邪惡之中，仍一生謹守貞潔，毫無玷污。父親去世後，他的母親藉著殘殺盧德米拉，奪取最高權力，並竭盡所能消滅基督信仰。但一些貴族厭倦了她的暴政與惡劣統治，便擺脫她的軛，在布拉格城擁立瓦茨拉夫為統治者。", "zh-hans": "波希米亚公爵瓦茨拉夫，蒙上帝召叫，承担护卫基督信仰的艰巨使命；当时他的臣民才刚开始学习信仰，魔鬼对信仰的仇恨也刚显露出来。他的父亲是基督徒——弗拉季斯拉斯一世公爵；母亲名为德拉霍米拉，却只是名义上的基督徒。然而，他的祖母圣卢德米拉是一位极其圣洁的养育者，在敬虔中培育他。因此，他在各样美德上都十分出众；即使身处极大的邪恶之中，仍一生谨守贞洁，毫无玷污。父亲去世后，他的母亲藉着残杀卢德米拉，夺取最高权力，并竭尽所能消灭基督信仰。但一些贵族厌倦了她的暴政与恶劣统治，便摆脱她的轭，在布拉格城拥立瓦茨拉夫为统治者。", "en": "WENCESLAS, Duke of Bohemia, was called of God to the hard task of defending Christianity when his subjects were just beginning to learn the Faith, and the devil’s hatred thereof was first being manifested. He was the son of a Christian father, Duke Wratislas I, and a mother, named Drahomira, who was Christian only in name. But he had in his paternal grandmother a most holy foster-mother, namely Saint Ludmilla, who trained him up in godliness. Therefore, he became a man eminent in all graces, and one who carefully kept chastity unsullied throughout the whole course of his life, and in the midst of great wickedness. After his father’s death, his mother seized the supreme power through the foul murder of Ludmilla, and did all that she could to extirpate Christianity. But some of the nobles, wearied with her tyranny and wicked government, cast off her yoke, and hailed Wenceslas, in the city of Prague, as their ruler."}, {"zh-hant": "他立刻宣告：自己要以公義、卻也以憐憫施政；而他確實如此行。對孤兒、寡婦和貧困者，他極其仁慈，甚至有時在冬天親自肩負柴薪，送給有需要的人。他常常協助安葬窮人，釋放俘虜；又屢次在深夜前往監獄，以金錢和勸慰安慰被囚的人。對這樣一位心腸柔和的君主來說，即使罪犯確有罪過，必須判處其死刑也是極大的悲痛。他對教會及其聖職人員懷有極深敬意；他喜歡親手播種、收割穀物、壓榨葡萄，好供應舉行神聖祭獻所需之物。", "zh-hans": "他立刻宣告：自己要以公义、却也以怜悯施政；而他确实如此行。对孤儿、寡妇和贫困者，他极其仁慈，甚至有时在冬天亲自肩负柴薪，送给有需要的人。他常常协助安葬穷人，释放俘虏；又屡次在深夜前往监狱，以金钱和劝慰安慰被囚的人。对这样一位心肠柔和的君主来说，即使罪犯确有罪过，必须判处其死刑也是极大的悲痛。他对教会及其圣职人员怀有极深敬意；他喜欢亲手播种、收割谷物、压榨葡萄，好供应举行神圣祭献所需之物。", "en": "At once he issued a proclamation that he would rule justly, but with mercy, and he did. To the orphaned, the widowed, and the destitute he was very charitable, so that sometimes in the winter he carried firewood to the needy on his own shoulders. He helped oftentimes to bury the poor; he set captives free; and at the dead of night he went many times to the prisons to comfort with money and advice them that were detained therein. To a prince of so tender an heart it was a great grief to be behoven to condemn any to death, however guilty. For the Church and her clergy he had a most earnest respect, and it was his pleasure to sow and reap the corn, and press the grapes, with his own hands, wherewith to provide for the holy sacrifice."}, {"zh-hant": "當古林納的塔迪斯拉斯親王入侵波希米亞時，瓦茨拉夫為避免眾多人流血，便親自出去與他單獨決鬥。敵人面對他的勇氣與良善，肅然起敬，便與他締結友好盟約。瓦茨拉夫前往德意志時，皇帝因見他顯然的聖德，便從寶座起來，擁抱他，賜予他王室的徽飾，並贈送聖殉道者維特的聖髑給他。然而，他那不敬虔的弟弟博萊斯拉斯，在母親的唆使下，到一所教堂尋找正在祈禱的他，意圖殺害他。這不近人情的兄弟博萊斯拉斯，聯同幾名同謀，以劍刺傷了他；隨後，博萊斯拉斯親手用長矛刺透他的身體，將他殺死。他於九三五年九月二十八日、午夜過後不久受難。人民立刻尊他為殉道者，因他為護衛信仰、抵抗異教徒的反對而獻出了生命；約自九八五年起，人們已在波希米亞慶祝他的瞻禮。他被視為捷克民族的主保聖人。", "zh-hans": "当古林纳的塔迪斯拉斯亲王入侵波希米亚时，瓦茨拉夫为避免众人流血，便亲自出去与他单独决斗。敌人面对他的勇气与良善，肃然起敬，便与他缔结友好盟约. 瓦茨拉夫前往德意志时，皇帝因见他显然的圣德，便从宝座起来，拥抱他，赐予他王室的徽饰，并赠送圣殉道者维特的圣髑给他。然而，他那不敬虔的弟弟博莱斯拉斯，在母亲的唆使下，到一所教堂寻找正在祈祷的他，意图杀害他。这不近人情的兄弟博莱斯拉斯，联同几名同谋，以剑刺伤了他；随后，博莱斯拉斯亲手用长矛刺透他的身体，将他杀死。他于九三五年九月二十八日、午夜过后不久受难。人民立刻尊他为殉道者，因他为护卫信仰、抵抗异教徒的反对而献出了生命；约自九八五年起，人们已在波希米亚庆祝他的瞻礼。他被视为捷克民族的主保圣人。", "en": "When Tadislass, Prince of Gurinna, invaded Bohemia, Wenceslas, to save the bloodshed of many, went out to meet him in single combat. Faced with such courage and goodness, his enemy bowed in reverence before him, and made with him a league of friendship. When he went to Germany, the Emperor was so impressed with his evident holiness that he arose from his throne, embraced him in his arms, decorated him with the insignia of royalty, and gifted him with relics of the holy Martyr Vitus. Nevertheless, his godless brother, at the exhortation of their mother, sought him out in a church, where he was praying, thinking to kill him. There this unnatural brother, Boleslas, together with some accomplices in crime, wounded him with their swords. And then Boleslas despatched him with his own hand, running him through the body with a lance. He suffered a little after midnight on September 28th, 935. At once he was acclaimed by the people as a Martyr who had given his life to uphold the Faith against pagan opposition; and since about the year 985 his feast hath been observed in Bohemia. He is considered the national patron of the Czechs."}]} | （原檔沒有此欄位） |
| `morning.invitatory.text.en` | "" | （原檔沒有此欄位） |
| `morning.invitatory.text.zh-hans` | "主是殉道者的君王，※我们当来俯伏敬拜。" | "主是殉道者的君王，※我们当来俯伏敬拜." |
| `morning.invitatory_hymn.title` | {"zh-hant": "Deus tuorum militum", "zh-hans": "Deus tuorum militum", "en": "Deus tuorum militum"} | "上帝義子勇毅無雙" |
| `morning.invitatory_hymn.verses.0.en` | "MARTYR of God! the only Son \nTo victory hath led thee on;\nThine every foe now prostrate lies, \nAnd heaven accords the victor's prize." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.1.en` | "O may thy prayer. for us obtain \nThe cleansing of each guilty stain;\nShield us from sin's contagious blight: \nPut life's long weariness to flight." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.2.en` | "Now riven are the bonds in twain, \nWhich did thy saintly limbs enchain;\nFrom us the bonds of earth remove, \nThrough God the Son's redeeming love." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.en` | "All laud to God the Father be; \nAll praise, eternal Son, to thee;\nAll glory, as is ever meet, \nTo God the Holy Paraclete. Amen." | （原檔沒有此欄位） |
| `morning.invitatory_hymn.verses.3.zh-hans` | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽.阿们." | "四、赞美圣父创造之恩，\n赞美圣子救世之恩;\n赞美圣灵保惠之恩，\n虔诚拜祷永世无尽。阿们。" |
| `morning.office_hymn.title` | {"zh-hant": "主之諸聖共沐主恩", "zh-hans": "主之诸圣共沐主恩", "en": ""} | "主之諸聖共沐主恩" |
| `morning.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.0.zh-hans` | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生。" | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生." |
| `morning.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.1.zh-hans` | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年。" | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年." |
| `morning.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.2.zh-hans` | "三、为尔穿越万般艰险，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆。" | "三、为尔穿越万般艰难，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆." |
| `morning.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.verses.3.zh-hans` | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污。" | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污." |
| `morning.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.leader.en` | "The righteous shall blossom as the lily. " | （原檔沒有此欄位） |
| `morning.office_hymn.versicle.people.en` | "He shall flourish for ever before the Lord." | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.0.zh-hans` | "凡在人面前认我的，※我在我天上的父面前也必认他。" | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `morning.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.1.zh-hans` | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `morning.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.2.zh-hans` | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `morning.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.3.zh-hans` | "主说：※若有人服事我，我父必尊重他。" | "主说：※若有人服事我，我父必尊重他." |
| `morning.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `morning.psalm_antiphons.antiphons.4.zh-hans` | "圣父阿，※我在哪里，服事我的人也要在哪里。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |
| `evening.benedictus_antiphon.normals.0.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.0.zh-hans` | "他将世上的一切都视为无物，※以言以行，为自己在天上积蓄财宝。" | "他将世上的一切都视为无物，※以言以行，为自己在天上积蓄财宝." |
| `evening.benedictus_antiphon.normals.1.en` | "" | （原檔沒有此欄位） |
| `evening.benedictus_antiphon.normals.1.zh-hans` | "此人彻悟公义，洞悉奇伟奥秘；※他祈求至高者，终列诸圣之中。" | "此人彻悟公义，洞悉奇伟奥秘；※他祈求至高者，终列诸圣之中." |
| `evening.bible_sentences.0.reference.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.en` | "" | （原檔沒有此欄位） |
| `evening.bible_sentences.0.text.zh-hans` | "忍受试炼的人有福了，因为他经过考验以后必得生命的冠冕，这是主应许给爱他之人的。" | "忍受试炼的人有福了，因为他经过考验以后必得生命的冠冕，这是主应许给爱他之人的." |
| `evening.office_hymn.title` | {"zh-hant": "主之諸聖共沐主恩", "zh-hans": "主之诸圣共沐主恩", "en": ""} | "主之諸聖共沐主恩" |
| `evening.office_hymn.verses.0.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.0.zh-hans` | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生。" | "一、主之诸圣共沐主恩，\n冠冕永赏凯旋功勋；\n我众讴歌圣徒得胜，\n求赦罪愆赐予新生." |
| `evening.office_hymn.verses.1.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.1.zh-hans` | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年。" | "二、弃绝俗世虚华宴乐，\n挣脱罪恶诱惑网罗；\n瞬逝浮华皆作云烟，\n终抵天乡圣殿永年." |
| `evening.office_hymn.verses.2.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.2.zh-hans` | "三、为尔穿越万般艰险，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆。" | "三、为尔穿越万般艰难，\n百战之中勇毅无双；\n甘为圣名倾流热血，\n永享欢庆万世无疆." |
| `evening.office_hymn.verses.3.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.verses.3.zh-hans` | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污。" | "四、仁爱救主伏求垂怜，\n自主宝座施恩广远；\n在此圣者凯旋之日，\n洗净我众一切罪污." |
| `evening.office_hymn.verses.4.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.leader.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.en` | "" | （原檔沒有此欄位） |
| `evening.office_hymn.versicle.people.zh-hant` | "將精金的冠冕，戴在他的头上。" | "将精金的冠冕，戴在他的头上。" |
| `evening.psalm_antiphons.antiphons.0.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.0.zh-hans` | "凡在人面前认我的，※我在我天上的父面前也必认他。" | "凡在人面前认我的，※我在我天上的父面前也必认他." |
| `evening.psalm_antiphons.antiphons.1.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.1.zh-hans` | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光。" | "我就是世界的光。※跟从我的，必不在黑暗里走，却要得着生命的光." |
| `evening.psalm_antiphons.antiphons.2.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.2.zh-hans` | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里。" | "若有人服事我，※就当跟从我；我在哪里，服事我的人也要在哪里." |
| `evening.psalm_antiphons.antiphons.3.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.3.zh-hans` | "主说：※若有人服事我，我父必尊重他。" | "主说：※若有人服事我，我父必尊重他." |
| `evening.psalm_antiphons.antiphons.4.en` | "" | （原檔沒有此欄位） |
| `evening.psalm_antiphons.antiphons.4.zh-hans` | "圣父阿，※我在哪里，服事我的人也要在哪里。" | "圣父阿，※我在哪里，服事我的人也要在哪里." |

## 未轉換檔案與原因

以下檔案完全未寫入。JSON 格式錯誤需先修正才能可靠比對；類別待確認的建議不是已套用的通用選擇。

| 檔案 | 原因 | 比對候選（僅供校對） |
|---|---|---|
| sanctorale_0519_dunstan_easter.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_confessor_non_bishop_easter, common_confessor_bishop_easter |
| sanctorale_0520_bernardino_of_siena_easter.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_confessor_non_bishop_easter, common_confessor_bishop_easter |
| sanctorale_0609_columba.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_confessor_bishop_outside_easter, common_confessor_doctor_outside_easter |
| sanctorale_0611_barnabas.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of object: line 46 column 8 (char 1147) |  |
| sanctorale_0611_barnabas_easter.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of object: line 46 column 8 (char 1194) |  |
| sanctorale_0617_botolph.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_confessor_non_bishop_easter, common_confessor_bishop_easter |
| sanctorale_0623_nativity_of_john_the_baptist_vigil.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0624_nativity_of_john_the_baptist.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of object: line 62 column 8 (char 1760) |  |
| sanctorale_0625_john_baptist_octave_2.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0626_john_baptist_octave_3.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0627_john_baptist_octave_4.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0628_john_baptist_octave_5.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0628_peter_and_paul_vigil.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0629_john_baptist_octave_6.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0629_peter_and_paul.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of object: line 46 column 8 (char 1164) |  |
| sanctorale_0630_john_baptist_octave_7.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0701_john_baptist_octave_8.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0701_precious_blood.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0702_visitation.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0703_peter_and_paul_octave_5.json | 時辰回退／必填結構待確認：缺省前夕原可回退晚禱，需另行處理時辰相容性 | common_evangelist_outside_easter, common_apostle_outside_easter |
| sanctorale_0704_peter_and_paul_octave_6.json | 時辰回退／必填結構待確認：缺省前夕原可回退晚禱，需另行處理時辰相容性 | common_evangelist_outside_easter, common_apostle_outside_easter |
| sanctorale_0705_vladimir.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_martyr_outside_easter, common_confessor_bishop_outside_easter |
| sanctorale_0716_our_lady_of_mount_carmel.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_saturday_office_of_our_lady, common_virgin_outside_easter |
| sanctorale_0722_mary_magdalene.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_martyr_outside_easter, common_virgin_martyr_easter |
| sanctorale_0724_james_vigil.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0725_james.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of object: line 45 column 8 (char 1111) |  |
| sanctorale_0726_anne.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of array: line 62 column 60 (char 1909) |  |
| sanctorale_0801_maccabees.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_confessors_outside_easter, common_martyrs_outside_easter |
| sanctorale_0805_our_lady_of_the_snows.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_saturday_office_of_our_lady, common_virgin_outside_easter |
| sanctorale_0806_transfiguration.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of object: line 45 column 8 (char 1147) |  |
| sanctorale_0807_holy_name_of_jesus.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0809_lawrence_vigil.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0814_assumption_vigil.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0815_assumption.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of array: line 173 column 80 (char 5887) |  |
| sanctorale_0817_assumption_octave_3.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of array: line 82 column 80 (char 2827) |  |
| sanctorale_0818_assumption_octave_4.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of array: line 82 column 80 (char 2827) |  |
| sanctorale_0819_assumption_octave_5.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of array: line 82 column 80 (char 2827) |  |
| sanctorale_0820_assumption_octave_6.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of array: line 82 column 80 (char 2827) |  |
| sanctorale_0821_assumption_octave_7.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0822_assumption_octave_8.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0823_bartholomew_vigil.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0824_bartholomew.json | 原有 JSON 格式錯誤：Illegal trailing comma before end of object: line 46 column 8 (char 1160) |  |
| sanctorale_0831_aidan.json | 差異位於整組覆蓋欄位，無可移除的完整重複區塊：相同部分位於不可拆分區塊，整組需保留 | common_confessor_bishop_outside_easter, common_confessor_doctor_outside_easter |
| sanctorale_0907_evurtius.json | 差異位於整組覆蓋欄位，無可移除的完整重複區塊：相同部分位於不可拆分區塊，整組需保留 | common_confessor_bishop_outside_easter, common_confessor_doctor_outside_easter |
| sanctorale_0908_nativity_of_mary.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0909_peter_claver.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_confessor_bishop_outside_easter, common_confessor_doctor_outside_easter |
| sanctorale_0912_holy_name_of_mary.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_saturday_office_of_our_lady, common_virgin_outside_easter |
| sanctorale_0914_holy_cross.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_martyrs_outside_easter, common_martyrs_easter |
| sanctorale_0915_our_lady_of_sorrows.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0916_ninian.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_confessor_bishop_outside_easter, common_confessor_doctor_outside_easter |
| sanctorale_0919_theodore_of_canterbury.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_confessor_bishop_outside_easter, common_confessor_doctor_outside_easter |
| sanctorale_0920_john_coleridge_patteson.json | 差異位於整組覆蓋欄位，無可移除的完整重複區塊：相同部分位於不可拆分區塊，整組需保留 | common_confessor_bishop_outside_easter, common_confessor_doctor_outside_easter |
| sanctorale_0920_matthew_vigil.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0921_matthew.json | 差異位於整組覆蓋欄位，無可移除的完整重複區塊：相同部分位於不可拆分區塊，整組需保留 | common_evangelist_outside_easter, common_apostle_outside_easter |
| sanctorale_0923_thecla.json | 差異位於整組覆蓋欄位，無可移除的完整重複區塊：相同部分位於不可拆分區塊，整組需保留 | common_virgin_martyr_outside_easter, common_virgin_martyr_easter |
| sanctorale_0924_our_lady_of_ransom.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_saturday_office_of_our_lady, common_virgin_outside_easter |
| sanctorale_0925_lancelot_andrewes.json | 類別／季節或通用用途待確認：通用相似度與名稱／季節不一致，或聖母專用通用未確認 | common_confessor_bishop_outside_easter, common_confessor_doctor_outside_easter |
| sanctorale_0929_michael_and_all_angels.json | 望日、專用資料或無足夠相同內容：望日、專用節日或沒有足夠相同內容 | common_virgin_outside_easter, common_virgin_martyr_outside_easter |
| sanctorale_0930_jerome.json | 差異位於整組覆蓋欄位，無可移除的完整重複區塊：相同部分位於不可拆分區塊，整組需保留 | common_confessor_non_bishop_outside_easter, common_confessor_non_bishop_easter |
