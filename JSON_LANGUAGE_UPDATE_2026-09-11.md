# 聖日 JSON 英文空位與通用啟應標記整理

日期：2026-09-11

## 範圍更正

- 僅處理 `DailyOffice/Resources/Officebook/Sanctorale/` 內的 JSON。
- 已撤回上一輪在此資料夾以外 103 份檔案新增的英文空位，恢復至該輪修改前的內容；不撤回其他既有開發工作。
- 聖日資料夾內保留 28 份修改，新增 1465 個 `en: ""`，移除通用文字內 8 處重複啟應標記。
- 既有英文正文、其他欄位及啟應結構不變。英文空位不代表翻譯完成。

## 保留修改清單

| 檔案 | 新增英文空位 | 移除啟應標記 |
|---|---:|---:|
| sanctorale_0514_pachomius_easter.json | 59 | 0 |
| sanctorale_0516_simon_stock_easter.json | 44 | 0 |
| sanctorale_0825_louis.json | 67 | 0 |
| sanctorale_0828_augustine_of_hippo.json | 58 | 0 |
| sanctorale_0829_beheading_of_john_the_baptist.json | 61 | 0 |
| sanctorale_0830_rose_of_lima.json | 63 | 0 |
| sanctorale_1018_luke.json | 6 | 0 |
| sanctorale_1028_simon_and_jude.json | 6 | 0 |
| saturday_office_of_our_lady.json | 68 | 0 |
| 一位殉道童貞女用（復活期內）.json | 52 | 0 |
| 一位殉道童貞女用（復活期外）.json | 52 | 0 |
| 一位殉道者通用（復活期外）.json | 52 | 0 |
| 一位童貞女通用（復活期內）.json | 52 | 0 |
| 一位童貞女通用（復活期外）.json | 51 | 0 |
| 一位精修者通用（復活期內）主教、主教聖師.json | 61 | 4 |
| 一位精修者通用（復活期內）非主教、非主教聖師.json | 61 | 4 |
| 一位精修者通用（復活期外）主教.json | 50 | 0 |
| 一位精修者通用（復活期外）教會聖師.json | 46 | 0 |
| 一位精修者通用（復活期外）非主教.json | 56 | 0 |
| 一位聖婦用（復活期內）.json | 48 | 0 |
| 一位聖婦用（復活期外）.json | 48 | 0 |
| 使徒用（復活期內） .json | 71 | 0 |
| 使徒用（復活期外）.json | 54 | 0 |
| 傳福音者用（復活期外）.json | 54 | 0 |
| 多位殉道者通用（復活期內）.json | 67 | 0 |
| 多位殉道者通用（復活期外）.json | 54 | 0 |
| 多位精修者通用（復活期外）.json | 47 | 0 |
| 禮拜六特敬聖母.json | 57 | 0 |

## 聖日資料夾原有格式問題，未修改

| 檔案 | 解析錯誤 |
|---|---|
| sanctorale_0611_barnabas.json | Illegal trailing comma before end of object: line 46 column 8 (char 1147) |
| sanctorale_0611_barnabas_easter.json | Illegal trailing comma before end of object: line 46 column 8 (char 1194) |
| sanctorale_0624_nativity_of_john_the_baptist.json | Illegal trailing comma before end of object: line 62 column 8 (char 1760) |
| sanctorale_0629_peter_and_paul.json | Illegal trailing comma before end of object: line 46 column 8 (char 1164) |
| sanctorale_0725_james.json | Illegal trailing comma before end of object: line 45 column 8 (char 1111) |
| sanctorale_0726_anne.json | Illegal trailing comma before end of array: line 62 column 60 (char 1909) |
| sanctorale_0806_transfiguration.json | Illegal trailing comma before end of object: line 45 column 8 (char 1147) |
| sanctorale_0815_assumption.json | Illegal trailing comma before end of array: line 173 column 80 (char 5887) |
| sanctorale_0817_assumption_octave_3.json | Illegal trailing comma before end of array: line 82 column 80 (char 2827) |
| sanctorale_0818_assumption_octave_4.json | Illegal trailing comma before end of array: line 82 column 80 (char 2827) |
| sanctorale_0819_assumption_octave_5.json | Illegal trailing comma before end of array: line 82 column 80 (char 2827) |
| sanctorale_0820_assumption_octave_6.json | Illegal trailing comma before end of array: line 82 column 80 (char 2827) |
| sanctorale_0824_bartholomew.json | Illegal trailing comma before end of object: line 46 column 8 (char 1160) |
