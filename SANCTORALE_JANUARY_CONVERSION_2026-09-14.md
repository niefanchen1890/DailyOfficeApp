# 一月聖日轉換記錄 — 2026-09-14

## 範圍與規則

- 29 份 PHP 來源全部轉為 Sanctorale JSON，其中 15 份明確使用 common_office。原始 PHP 不修改、不執行。
- 來源 30 組單一詩篇對經放入 lectionary_1943，各預留五個普通對經空物件，共 150 個空位。來源標 common 者省略欄位以繼承，沒有加入 null 阻斷通用。
- 保留 72 個祝文區塊、44 個聖詩區塊及 44 個教父選讀區塊；祝文 title 使用本檔 name。聖詩加中文段號、保留換行，移除 HTML 及啟應前綴。
- 繁簡文字齊備，來源未提供的英文留空。identifier 與核心穩定識別碼對齊並補資源映射；現有九月至十二月檔案不修改。

## 差異及待確認事項

- 1/22 已按使用者確認改為「殉道者聖文森與聖阿納斯塔修」、半複式；核心、JSON、祝文標題及映射同步，保留原穩定 ID st_vincent。
- 1/28「授予安立甘公教會主教聖品」、二等複式已加入固定日曆，使用 anglican_episcopate 與既有 JSON。
- 1/14、27、29 舊來源引用「主教或聖師」合併通用，本次沿用前批方法映射現行主教精修者通用；現行聖師通用另要求前夕尊主頌對經和早禱邀請句，來源只標 common，尚無專用文字可填，未臆造。
- 1/5 依使用者指定為特殊二等特權望日：平日有前夕內容（1/4 晚上，畫面稱「晚禱」），早禱及前夕以 1/1 資源複製為底，再覆蓋來源專用內容；未引入一般聖日間自動繼承。1/5 當晚進入顯現日前夕晚禱。逢主日改守聖誕後第二主日，前夕與早禱不紀念望日。
- 1/2、3、4、16、18 來源缺少晚禱，維持缺少／停用，不補造時辰。1/3、4、16、18 來源有前夕內容，保留供資料存檔；是否舉行仍由核心等級及第一晚禱規則決定。
- 1/7–12 八日慶期內沒有前夕，禁用晚禱回退成前夕；1/12 來源只有早禱。八日慶期使用核心特權八日等級，rank_display 保留來源半複式／大複式文字。
- 1/25 插入使徒聖詩專用第二段；使用者另提供 data/memorials/saints0125.php 後，已將聖彼得紀念的對經、啟應、祝文加入本日 vigil/morning/evening.commemorations。
- 多日 sentence: common 沒有 common_file，省略該欄位使用既有節期載入；1/30 邀請句亦為此情況。
- 名稱以核心顯示名為準，來源另譯保留在正文；未作神學文字校訂，來源疑似筆誤留待校對。

## 每檔保留項目

| 日期 | JSON 檔案 | 通用 | 專用區塊 |
|---|---|---|---|
|0101|sanctorale_0101_circumcision.json|獨立專用|vigil: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons；morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons, psalms；evening: benedictus_antiphon, collect, office_hymn, psalm_antiphons, psalms|
|0102|sanctorale_0102_stephen_octave_8.json|獨立專用|morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn|
|0103|sanctorale_0103_john_octave_8.json|獨立專用|vigil: benedictus_antiphon, collect, office_hymn；morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn|
|0104|sanctorale_0104_holy_innocents_octave_8.json|獨立專用|vigil: benedictus_antiphon, collect, office_hymn；morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn|
|0105|sanctorale_0105_epiphany_vigil.json|獨立專用|morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons|
|0106|sanctorale_0106_epiphany.json|獨立專用|vigil: benedictus_antiphon, biography, collect, nunc_dimittis_antiphon, office_hymn, psalm_antiphons, psalms；morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons, psalms；evening: benedictus_antiphon, collect, nunc_dimittis_antiphon, office_hymn, psalm_antiphons, psalms|
|0107|sanctorale_0107_epiphany_octave_2.json|獨立專用|morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons|
|0108|sanctorale_0108_epiphany_octave_3.json|獨立專用|morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons|
|0109|sanctorale_0109_epiphany_octave_4.json|獨立專用|morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons|
|0110|sanctorale_0110_epiphany_octave_5.json|獨立專用|morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons|
|0111|sanctorale_0111_epiphany_octave_6.json|獨立專用|morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons|
|0112|sanctorale_0112_epiphany_octave_7.json|獨立專用|morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons|
|0113|sanctorale_0113_epiphany_octave_8.json|獨立專用|vigil: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons；morning: benedictus_antiphon, biography, collect, invitatory, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, collect, office_hymn, psalm_antiphons|
|0114|sanctorale_0114_hilary.json|common_confessor_bishop_outside_easter|vigil: collect；morning: biography, collect；evening: collect|
|0115|sanctorale_0115_paul_the_hermit.json|common_confessor_non_bishop_outside_easter|vigil: collect；morning: biography, collect；evening: collect|
|0116|sanctorale_0116_william_laud.json|common_martyr_outside_easter|vigil: collect；morning: biography, collect；evening: 停用|
|0117|sanctorale_0117_antony.json|common_confessor_non_bishop_outside_easter|vigil: collect；morning: biography, collect；evening: collect|
|0118|sanctorale_0118_prisca.json|common_virgin_martyr_outside_easter|vigil: collect；morning: biography, collect；evening: 停用|
|0120|sanctorale_0120_fabian_and_sebastian.json|common_martyrs_outside_easter|vigil: collect；morning: biography, collect；evening: collect|
|0121|sanctorale_0121_agnes.json|common_virgin_martyr_outside_easter|vigil: benedictus_antiphon, collect, psalm_antiphons；morning: benedictus_antiphon, biography, collect, psalm_antiphons；evening: benedictus_antiphon, collect, psalm_antiphons|
|0122|sanctorale_0122_vincent.json|common_martyrs_outside_easter|vigil: collect；morning: biography, collect；evening: collect|
|0124|sanctorale_0124_timothy.json|common_martyr_outside_easter|vigil: collect；morning: biography, collect；evening: collect|
|0125|sanctorale_0125_conversion_of_paul.json|common_apostle_outside_easter|vigil: benedictus_antiphon, biography, collect, office_hymn, psalm_antiphons, psalms；morning: benedictus_antiphon, biography, collect, psalm_antiphons, psalms；evening: benedictus_antiphon, collect, psalm_antiphons, psalms|
|0126|sanctorale_0126_polycarp.json|common_martyr_outside_easter|vigil: collect；morning: biography, collect；evening: biography, collect|
|0127|sanctorale_0127_john_chrysostom.json|common_confessor_bishop_outside_easter|vigil: biography, collect；morning: biography, collect；evening: collect|
|0128|sanctorale_0128_anglican_episcopate.json|common_confessors_outside_easter|vigil: biography, collect；morning: biography, collect；evening: collect|
|0129|sanctorale_0129_francis_de_sales.json|common_confessor_bishop_outside_easter|vigil: biography, collect；morning: biography, collect；evening: collect|
|0130|sanctorale_0130_charles_martyr.json|獨立專用|vigil: benedictus_antiphon, bible_sentences, biography, collect, office_hymn, psalm_antiphons；morning: benedictus_antiphon, bible_sentences, biography, collect, invitatory_hymn, office_hymn, psalm_antiphons；evening: benedictus_antiphon, bible_sentences, collect, office_hymn, psalm_antiphons|
|0131|sanctorale_0131_john_bosco.json|common_confessor_non_bishop_outside_easter|vigil: collect；morning: biography, collect；evening: biography, collect|

## 驗證

- 29 份 × 三語透過現有 Swift 模型與 CommonOfficeResolver 解碼成功；每個識別碼及資源映射皆通過。
- 單組 1943、普通五組空位、通用欄位省略、祝文標題、聖詩中文段號與顯現望日時辰限制通過結構檢查。
- 最後不簽名 iOS 建置 BUILD SUCCEEDED；29 份 JSON 均逐位元組核對收入 App bundle。現有 28 個一月日曆聖日的核心 ID 與新資源逐一吻合。
- 未執行全專案 JSON 驗證、XCTest runner 或人工畫面檢查。

## 使用者確認後的核心修訂

- 1/2、3、4 依 octave.day=8 與 simple 顯示「簡式八日慶期，簡式」，數值仍為 50，與普通簡式同級，不建立不同優先級；新增等級文字解析。
- 1/2、3、4、16、18 維持沒有本日晚禱的資料。1/5 是明確的前夕例外，不推廣至其他望日。
- 2025–2035 年 1/5 逢主日及平日、前夕身分、望日紀念省略、當晚進入顯現日等核心檢查通過。
- 9 份相關 JSON 的三語解碼、聖彼得三時辰紀念、顯現望日承接受割禮日詩篇及時辰限制通過。
- 不簽名 iOS 建置 BUILD SUCCEEDED；6 份本次修改的 JSON 已逐位元組核對打包。新增 XCTest 回歸案例；本輪執行的是實際 Swift 來源驗證程式，未啟動 XCTest runner 或人工畫面驗證。
