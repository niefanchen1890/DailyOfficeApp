# 降臨期主日轉換記錄 — 2026-09-13

已完成四個主日及使用者隨後要求的 24 份周間來源，共 28 份降臨期 JSON。原始 PHP 不修改、不執行。

輸出至 DailyOffice/Resources/Officebook/Temporal：

- temporal_advent_1_sunday.json
- temporal_advent_2_sunday.json
- temporal_advent_3_sunday.json
- temporal_advent_4_sunday.json

## 內容與相容處理

- 每日保留前夕晚禱、早禱與晚禱；共 12 個單一詩篇對經轉為 lectionary_1943，普通 antiphons 各預留五個繁／簡／英文空物件。
- 繁體來源及簡體版本齊備；英文欄位保留空值，尚未完成英文翻譯。
- 聖詩保留原段落與換行，加上中文段號；移除 HTML 和啟應顯示前綴。祝文標題對應本日 name。
- 尊主頌與以色列頌對經使用既有 benedictus_antiphon 結構；西面頌使用 nunc_dimittis_antiphon。第四主日教父選讀轉為 biography。
- 第二主日 1962 詩篇有兩個選項：第一組保存於 psalms.1962，第二組保存於系統現有 psalms.special，由早晚禱「專用詩篇」選項選用。未將兩組拼成同一組，也未加入年份輪替規則。
- 詩篇 119k、l、m、n 依每段八節，分別轉為 81–88、89–96、97–104、105–112。
- 第一主日沿用核心固定 ID advent_1_sunday，補上資源映射；其餘使用 temporal.advent.week.N.weekday.1 和既有通用檔名規則。

## 保留的來源差異

- 第二至第四主日來源標為二等主日，JSON 保留 sundaySecondClass；現有核心對這三日仍賦 ordinarySunday。本輪未改動核心優先等級規則。
- 第四主日前夕及晚禱來源沒有尊主頌對經，未編造補入。
- 來源有疑似筆誤，例如第一主日晚禱「大光名」，第四主日教父選讀「女人的摸不著後裔」「除非發」」等；本輪保留原文，留待使用者校對，未擅改翻譯。

## 驗證

- 4 份 JSON 格式、三語鍵、12 組 1943 對經、60 個普通對經空位、祝文標題及聖詩段號檢查通過。
- 使用目前實際 Swift 核心與 DailyOfficeFile 模型驗證：四個主日 × 三語解碼、三時辰選擇、識別碼及映射、第二主日替代詩篇範圍均通過。
- 不簽名 iOS 建置 BUILD SUCCEEDED；四份 JSON 已逐位元組核對收入 App bundle。
- 尚未人工驗證模擬器排版及導航；沒有執行全專案 JSON 驗證或 XCTest runner。


## 周間補充轉換

- ad1-1.php 至 ad4-6.php 共 24 份周間來源，輸出為 Temporal/temporal_advent_N_monday.json 至 temporal_advent_N_saturday.json。
- 保留來源的 45 個早晚禱時辰、45 組 1943 對經、225 個普通五組空位、69 個聖詩區塊、9 篇教父選讀。所有祝文標題對應本檔 name。
- 繁體、簡體內容與英文空欄位齊備；未提供的英文不另行臆譯。
- 第一至第三週星期六來源僅有早禱，未新增晚禱；第四週星期六保留來源晚禱。全部周間設定 disabledVigil，避免把晚禱誤作本日前夕晚禱。
- 第三週星期三、五、六的 canticle1: benedicite.php 轉為 first_canticle: benedicite。新增可選解碼欄位與早禱選擇支援；依核心決定當日主禮儀後，讀取該份資源的指定頌歌。沒有指定或代碼無效時維持原選擇。
- 專用 1928／1962 詩篇及節數保留；來源沒提供的經文／對經未編造填入。來源的疑似文字錯誤仍留待校對。
- 24 份檔案 × 三語均以現有 Swift 模型解碼成功；時辰限制、映射、三童歌欄位、聖詩段數與語言結構檢查通過。
- 不簽名 iOS 建置 BUILD SUCCEEDED，24 份新增 JSON 已逐位元組核對收入 App。未人工驗證畫面或執行 XCTest runner。
