# 十一至十二月聖日轉換記錄（2026-09-12）

## 範圍與已確認決定

- 來源為 Sanctorale/需要转化的文件 內的 50 份 PHP。只解析資料，不執行 PHP。
- 49 份轉為聖日 JSON，29 份明確引用 common_office。另建立 9 份八日慶期紀念選段資源。
- christtheking.php 不採用；依使用者要求，現有 Temporal/temporal_christ_the_king.json 完全不修改，已核對 SHA-256。
- 11 月 8 日維持禮儀核心的大複式，JSON 由來源二等複式調整為大複式。
- 12 月 29 日核心由半複式改為複式，與來源及 JSON 一致。
- 補入 11 月 26 日聖西爾維斯特院長（複式，st_sylvester_abbot）；與 12 月 31 日主教 st_sylvester 分開。

## 轉換規則

- identifier 對應核心穩定識別碼；檔名保持 sanctorale_MMDD_ 格式，補齊核心與紀念資源映射。
- common 字段省略以繼承。專用內容覆蓋通用；不產生 lectionary_1943:null。
- 來源 53 組單一詩篇對經均置入 lectionary_1943，每組另預留五個普通對經空物件（繁／簡／英）。
- 祝文 title 與本檔 name 一致。移除 HTML 排版，聖詩保留分段並加中文段號，啟應不存顯示前綴。
- 來源繁簡混用文字統一為繁體原文並生成簡體；未提供英文的文字留 en 空位，繼承的現有通用翻譯保留。
- 前夕晚禱聖詩為原子覆蓋：11 月 30 日、12 月 21 日複製現行使徒通用完整聖詩，再插入來源第二段，其他段落及啟應保留。
- 11 月 29 日與 12 月 24 日望日僅保留 morning。12 月 14 日按來源條件僅保留早禱。
- 明確沒有某時辰的通用繼承檔使用時辰 null 停用；無前夕、但有晚禱的獨立檔使用 disabledVigil 避免晚禱回退成前夕。
- 西面頌對經使用既有 nunc_dimittis_antiphon；教父選讀轉 biography；1928／1962 詩篇範圍保留。

## 來源差異與待補內容

- 英文未提供的部分仍為空，不能視為英文版完成；預留的普通五組對經仍待提供。
- 11 月 2 日 PHP 含多處諸聖用禮文，這次按來源保留，尚待禮文校對；沒有替換既有亡者日課功能。
- 11 月 15、24 日及 12 月 2、7 日來源引用舊「主教或聖師」合併通用。此次明確映射現行主教精修者通用，保留專用祝文。現行「教會聖師」通用要求另給前夕尊主頌對經與早禱邀請句，來源沒有提供，故未臆造。11 月 24 日此引用不代表把十架聖約翰改成主教；若改採聖師專用通用，仍須補上述兩項。
- 11 月 25 日雖名為殉道童貞女，來源明確指定 one_virgin.php，故保留一位童貞女通用的引用，未自行改為殉道童貞女通用。
- 12 月 8 日晚禱 use_seasonal_doxology=false 是 PHP 顯示層指令；JSON 保留來源專用聖詩及結束式，未新增未受 Swift 模型支援的欄位。
- 12 月 25–28 日及 12 月 30 日部分聖經選句標 common，卻未指定 common_file；省略該字段，交既有平日／節期載入機制處理，不編造選句。
- fixed_memorials 中若為同一來源檔的自我引用，不複製為遞迴引用。紀念仍由現有核心決定，另補八日慶期選段與映射。
- 12 月 31 日來源重複 type（christmas、bishop_confessor），依 PHP 最後值語義處理。JSON 統一 type 為 sanctorale。
- 來源 has_eve、precedence、type 的舊顯示／排序值不取代現有核心禮規；明確沒有時辰的限制已轉成受支援的資料結構。
- 本批未提供 12 月 20 日聖多馬望日來源，沒有生成或臆造該日禮文。

## 每檔引用與專用保留

下表欄位列出各時辰實際保留的專用區塊；未列出的通用字段由 common_office 繼承。一般五組空位在 psalm_antiphons 之內。

| 日期 | 檔案 | 通用引用 | 專用保留 |
|---|---|---|---|
|1101|sanctorale_1101_all_saints.json|獨立專用|vigil: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons；morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1102|sanctorale_1102_all_souls.json|獨立專用|morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1103|sanctorale_1103_all_saints_octave_3.json|獨立專用|morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1104|sanctorale_1104_charles_borromeo.json|common_confessor_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1105|sanctorale_1105_elizabeth.json|common_holy_woman_outside_easter|vigil: collect；morning: collect；evening: collect|
|1106|sanctorale_1106_all_saints_octave_6.json|獨立專用|morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1107|sanctorale_1107_willibrord.json|common_confessor_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1108|sanctorale_1108_saints_of_anglican_communion.json|獨立專用|vigil: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons；morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1109|sanctorale_1109_theodore.json|common_martyr_outside_easter|vigil: collect；morning: collect；evening: 停用|
|1111|sanctorale_1111_martin_of_tours.json|common_confessor_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1113|sanctorale_1113_brice.json|common_confessor_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1115|sanctorale_1115_albert_the_great.json|common_confessor_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1116|sanctorale_1116_gertrude.json|common_virgin_outside_easter|vigil: collect；morning: collect；evening: collect|
|1117|sanctorale_1117_hugh_of_lincoln.json|common_confessor_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1118|sanctorale_1118_hilda_of_whitby.json|common_virgin_outside_easter|vigil: collect；morning: collect；evening: collect|
|1119|sanctorale_1119_elizabeth_of_hungary.json|common_holy_woman_outside_easter|vigil: collect；morning: collect；evening: collect|
|1120|sanctorale_1120_edmund_martyr.json|common_martyr_outside_easter|vigil: benedictus_antiphon, collect, office_hymn；morning: benedictus_antiphon, collect, office_hymn；evening: benedictus_antiphon, collect, office_hymn|
|1121|sanctorale_1121_presentation_of_mary.json|獨立專用|vigil: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons；morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1122|sanctorale_1122_cecilia.json|common_virgin_martyr_outside_easter|vigil: benedictus_antiphon, collect, office_hymn；morning: benedictus_antiphon, collect, office_hymn；evening: benedictus_antiphon, collect, office_hymn|
|1123|sanctorale_1123_clement_of_rome.json|common_martyr_outside_easter|vigil: benedictus_antiphon, collect；morning: benedictus_antiphon, collect, psalm_antiphons；evening: benedictus_antiphon, collect, psalm_antiphons|
|1124|sanctorale_1124_john_of_the_cross.json|common_confessor_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1125|sanctorale_1125_catherine_of_alexandria.json|common_virgin_outside_easter|vigil: collect；morning: collect；evening: collect|
|1126|sanctorale_1126_sylvester_abbot.json|common_confessor_non_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1129|sanctorale_1129_andrew_vigil.json|獨立專用|morning: collect|
|1130|sanctorale_1130_andrew.json|common_apostle_outside_easter|vigil: benedictus_antiphon, collect, nunc_dimittis_antiphon, office_hymn, psalm_antiphons；morning: benedictus_antiphon, collect, psalm_antiphons；evening: benedictus_antiphon, collect, nunc_dimittis_antiphon, psalm_antiphons|
|1201|sanctorale_1201_nicholas_ferrar.json|common_confessor_non_bishop_outside_easter|vigil: collect；morning: collect；evening: 停用|
|1202|sanctorale_1202_peter_chrysologus.json|common_confessor_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1203|sanctorale_1203_francis_xavier.json|common_confessor_non_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1204|sanctorale_1204_clement_of_alexandria.json|common_confessor_non_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1205|sanctorale_1205_sabbas.json|common_confessor_non_bishop_outside_easter|vigil: 停用；morning: collect；evening: collect|
|1206|sanctorale_1206_nicholas.json|common_confessor_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1207|sanctorale_1207_ambrose.json|common_confessor_bishop_outside_easter|vigil: collect；morning: collect；evening: collect|
|1208|sanctorale_1208_immaculate_conception.json|獨立專用|vigil: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons；morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1209|sanctorale_1209_immaculate_conception_octave_2.json|獨立專用|morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1210|sanctorale_1210_immaculate_conception_octave_3.json|獨立專用|morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1211|sanctorale_1211_immaculate_conception_octave_4.json|獨立專用|morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1212|sanctorale_1212_immaculate_conception_octave_5.json|獨立專用|morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1213|sanctorale_1213_lucy.json|common_virgin_martyr_outside_easter|vigil: benedictus_antiphon, collect, psalm_antiphons；morning: benedictus_antiphon, collect, psalm_antiphons；evening: benedictus_antiphon, collect, psalm_antiphons|
|1214|sanctorale_1214_immaculate_conception_octave_7.json|獨立專用|morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons|
|1215|sanctorale_1215_immaculate_conception_octave_8.json|獨立專用|vigil: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons；morning: benedictus_antiphon, bible_sentences, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|1221|sanctorale_1221_thomas.json|common_apostle_outside_easter|vigil: benedictus_antiphon, collect, office_hymn, psalms；morning: benedictus_antiphon, collect, psalms；evening: benedictus_antiphon, collect, psalms|
|1224|sanctorale_1224_christmas_vigil.json|獨立專用|morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons|
|1225|sanctorale_1225_christmas.json|獨立專用|vigil: benedictus_antiphon, collect, nunc_dimittis_antiphon, office_hymn, psalm_antiphons, psalms；morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons, psalms；evening: benedictus_antiphon, collect, nunc_dimittis_antiphon, office_hymn, psalm_antiphons, psalms|
|1226|sanctorale_1226_stephen.json|獨立專用|vigil: benedictus_antiphon, collect, office_hymn；morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons, psalms；evening: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons, psalms|
|1227|sanctorale_1227_john.json|獨立專用|vigil: benedictus_antiphon, collect, office_hymn；morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons, psalms；evening: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons, psalms|
|1228|sanctorale_1228_holy_innocents.json|獨立專用|vigil: benedictus_antiphon, collect, office_hymn；morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons, psalms；evening: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons, psalms|
|1229|sanctorale_1229_thomas_becket.json|common_martyr_outside_easter|vigil: benedictus_antiphon, collect, office_hymn；morning: benedictus_antiphon, biography, collect, psalm_antiphons；evening: benedictus_antiphon, biography, collect, psalm_antiphons|
|1230|sanctorale_1230_christmas_octave_6.json|獨立專用|morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, biography, collect, office_hymn|
|1231|sanctorale_1231_sylvester.json|common_confessor_bishop_outside_easter|vigil: benedictus_antiphon, collect, psalm_antiphons；morning: benedictus_antiphon, biography, collect, psalm_antiphons；evening: 停用|

## 八日慶期紀念選段

只保存紀念所需的頌歌對經、啟應和祝文；取自所列現有來源的相同八日慶期，不新增獨立聖詩或假造每日專用經文。

| 資源 | 取自 |
|---|---|
|sanctorale_1104_all_saints_octave_4.json|saints1103.php（八日慶期紀念選段）|
|sanctorale_1105_all_saints_octave_5.json|saints1103.php（八日慶期紀念選段）|
|sanctorale_1107_all_saints_octave_7.json|saints1106.php（八日慶期紀念選段）|
|sanctorale_1213_immaculate_conception_octave_6.json|saints1212.php（八日慶期紀念選段）|
|sanctorale_1226_christmas_octave_2.json|saints1230.php（八日慶期紀念選段）|
|sanctorale_1227_christmas_octave_3.json|saints1230.php（八日慶期紀念選段）|
|sanctorale_1228_christmas_octave_4.json|saints1230.php（八日慶期紀念選段）|
|sanctorale_1229_christmas_octave_5.json|saints1230.php（八日慶期紀念選段）|
|sanctorale_1231_christmas_octave_7.json|saints1230.php（八日慶期紀念選段）|

## 驗證

- 58 份 JSON 格式與結構檢查通過；147 個祝文標題與本檔 name 一致。
- 53 個專用 1943 對經均有五組普通空位；69 個聖詩區塊段號檢查通過；1,571 個語言物件含繁、簡、英鍵。
- 使用目前實際 CommonOfficeResolver、DailyOfficeFile 和核心來源組成 Swift 驗證程式：58 份資源 × 3 種語言均解碼成功，所有識別碼與資源映射通過。
- 核心定日資料查詢：11/8 大複式、12/29 複式，11/26 院長與 12/31 主教識別碼獨立，四項均通過。
- 已新增相同四項核心規則的 XCTest 回歸案例；本輪以等效的實際核心 Swift 驗證程式通過，未啟動 XCTest runner。
- 沙盒內模擬器建置因 SwiftUIMacros.StateMacro 執行失敗；改用沙盒外不簽名 iOS 建置，結果 **BUILD SUCCEEDED**。已逐檔核對 58 份新增資源均收入 App bundle，內容與原檔一致。
- 本輪相關檔案的空白格式檢查通過；全 working tree 檢查另報既有 EveningPrayerView.swift:1054 尾隨空白，未修改該無關檔案。
- 未進行模擬器人工排版、導航驗證；未宣稱全專案 JSON 驗證通過。
