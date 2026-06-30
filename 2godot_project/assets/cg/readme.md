# CG插畫（Story Dialogue UI用）

這個資料夾放 `02_story_dialogue_ui_demo` 的CG（全螢幕過場插畫）正式素材，
原始檔在`3case/case1_cg/`，複製進來方便Godot專案內引用。

| 檔案 | 對應劇本位置 | 內容 |
|---|---|---|
| `cg_01_sophia_arrival.png` | 場景①蘇菲亞登場（`ch1_0040`） | 蘇菲亞提著點心盒站在門口、逆光 |
| `cg_02_chess_decision.png` | 場景⑧結尾「四線齊備→進入對質」（`ch1_7170`） | 莉希雅推動棋子、硬幣紙張飄浮，象徵她決定怎麼出招 |
| `cg_03_street_wide.png` | 場景⑨b開場（`ch1_9010`） | 兩人走在日落石板路，遠景 |
| `cg_03_street_closeup.png` | 場景⑨b結尾互相微笑（`ch1_9120`） | 同一條街，兩人對視微笑特寫 |
| `cg_04_counting_money.png` | 場景⑩收尾數錢（`ch1_10070`） | 莉希雅數錢大笑，蘇菲亞在後面整理資料 |

哪一句對白觸發哪張CG，見[data/cases/case_01.json](../../data/cases/case_01.json)
的`cg_images`字典跟各句的`"scene":"cg"`+`"cg"`欄位；觸發/顯示邏輯見
`02_story_dialogue_ui_demo.gd`的`_build_cg_layer()`（建立`cg_image_rect`）
跟`_show_line()`（依`cg`欄位設定texture）。找不到對應素材時會退回顯示
`cg_layer`原本的佔位色+「CG（佔位）」文字，不會讓畫面開窗。
