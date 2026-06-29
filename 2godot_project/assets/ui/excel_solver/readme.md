# Excel 解謎器（數據計算儀）美術資產

舊版（v1原型）只有一張`tab_category.png`借用存讀檔素材當左側分類按鈕底圖。
「Mockup精準重建計畫」第一、二批（頂部、左側、中央公式列、右側案件目標/
公式提示）素材已生成、處理、接上完成，見下表。

**第三批（六個公式圖示＋底部提示框/徽章）已決定不做，到此收尾**——底部
系統提示列維持原本純色細邊框占位樣式，公式提示清單維持純文字呈現，
不影響COUNTIF原型的功能，純粹是視覺精修範圍的取捨。

頂部「保存／讀取／設定」按鈕直接沿用 `assets/ui/story_dialogue/button_top_save/load/settings_normal|hover|pressed.png`，
沒有複製到這個資料夾，避免同一份素材出現兩份副本。

## 舊版素材（v1原型，待第一批新素材接上後淘汰）

| 檔案 | 用途 |
|---|---|
| `tab_category.png` | 左側案件資料分類按鈕（證言／物證／名冊／交易紀錄）的底圖，來源是 `1UI/save_load/_source_5_save_load_tab.png`，文字由Godot Label疊上去，不烤進圖片裡。 |

## 第一批：頂部與左側（Mockup精準重建計畫）

來源：`1UI/excel/`（imagegen生成），裁切/處理腳本：Python+Pillow，裁到alpha邊界+8px留白；
分類按鈕三態額外做了「60%最大透明度門檻找核心圖案bbox、置中貼到統一970×225畫布」的處理，
理由跟`assets/ui/story_dialogue/README.md`記錄的按鈕三態對齊邏輯一樣——原始生成圖三態的
透明留白大小不同，直接用會造成hover/selected/normal切換時視覺上「跳動」，置中對齊後三態
核心圖案位置一致，只有發光/裝飾細節在變化。

| 檔案 | 用途 | 處理後尺寸 |
|---|---|---|
| `panel_top_bar_main.png` | 頂部列（標題「數據計算儀」、章節牌、保存/讀取/設定鈕）背景框，九宮格延展。 | 1064×157 |
| `badge_title_calculator.png` | 「數據計算儀」標題左側的小型紋章徽章。 | 908×920（正方形構圖，含留白） |
| `plate_chapter_label.png` | 「第1章：第一份委託」章節文字的背景牌，九宮格延展。 | 1015×149 |
| `panel_left_sidebar_main.png` | 左側「案件資料」整面背景框，取代`tab_category.png`借位當整面背景的暫時做法。 | 390×1066 |
| `button_category_base_normal.png` / `_hover.png` / `_selected.png` | 左側分類按鈕（證言／物證／名冊／交易紀錄）共用底圖三態，四個分類疊不同icon+Godot Label文字，不用4×3張獨立素材。三態已核心對齊，統一970×225畫布。 | 各970×225 |
| `icon_category_testimony.png` | 「證言」分類icon（羽毛筆+卷軸）。 | 429×456 |
| `icon_category_evidence.png` | 「物證」分類icon（放大鏡+標籤）。 | 400×463 |
| `icon_category_roster.png` | 「名冊」分類icon（人名簿）。 | 427×521 |
| `icon_category_transaction.png` | 「交易紀錄」分類icon（天秤+帳本）。 | 522×510 |

**已知風格落差（記錄，暫不重做）**：上面4個分類icon走的是偏寫實光澤、高飽和的單體卡片式
畫風，跟其他框類素材（磨砂深炭黑底+克制發光）的調性不完全一致，比較接近
`0mockup/ui_style_guide_v0.1.md`第1節明確列為「避免方向」的手遊抽卡式裝飾。先用這版
組裝整體畫面驗證版面，icon風格之後如果決定要重做再單獨處理，不影響其他素材的接入進度。

**已知bug記錄（已修正）**：分類按鈕/章節牌一開始套用九宮格`texture_margin`時整個變形——
原因是這兩種素材的外框是斜切角/圓角造型，沒有一段乾淨筆直的邊可以當「不拉伸的邊角」，
硬切margin只會把雕花線條切歪、重複。後來改成不做九宮格，整張圖依素材原始寬高比等比例
縮放（章節牌、分類按鈕都是這樣處理，見`01_excel_simulator_step1_countif.gd`裡
`CHAPTER_PLATE_TEXTURE_ASPECT`／`CATEGORY_BUTTON_TEXTURE_ASPECT`的註解）。第二批素材
（下表）生成時已經事先要求素材是「乾淨直角矩形、裝飾收在角落範圍內」，避開同一個問題，
九宮格margin都先用Python量測+試算九宮格圖確認無變形才寫進程式碼。

## 第二批：中央與右側（Mockup精準重建計畫）

來源同樣是`1UI/excel/`（imagegen生成），裁切流程跟第一批一樣（裁到alpha邊界+8px留白）。
這批4張面板全部是乾淨直角矩形外框、裝飾收在角落（公式提示框例外，紋章在上方居中），
跟第一批斜切角造型的章節牌/分類按鈕不同，可以安全套用九宮格`texture_margin`延展。

| 檔案 | 用途 | 處理後尺寸 |
|---|---|---|
| `panel_formula_bar_frame.png` | 公式列（=COUNTIF(...)輸入列）外框，九宮格延展配合公式長度。 | 1021×155 |
| `panel_right_sidebar_main.png` | 右側「案件目標」「公式提示」整面背景框，呼應左側面板。 | 477×1046 |
| `panel_case_objective_box.png` | 「案件目標」清單外的卡片框，九宮格延展配合目標數量。 | 648×1011 |
| `panel_formula_hint_box_frame_only.png` | 「公式提示」卡片框的純背景版（見下方bug記錄），九宮格延展用，margin跟案件目標框共用同一組數值。 | 591×976 |
| `badge_formula_hint_calculator.png` | 從`panel_formula_hint_box.png`原圖裁出來的計算機紋章，獨立固定大小貼圖，疊在公式提示框標題上方，不隨框寬度縮放。 | 295×130 |
| `icon_objective_pending.png` | 目標狀態圖示：未完成（空心菱形）。 | 218×218 |
| `icon_objective_active.png` | 目標狀態圖示：進行中（淡綠發光菱形），取代原本的「◆」文字符號。 | 302×320 |
| `icon_objective_done.png` | 目標狀態圖示：已完成（古銅金菱形+勾選），目前demo資料還沒有已完成的目標，先備著。 | 334×337 |

**已知色調小落差（記錄，暫不修正）**：`icon_objective_pending.png`的線條顏色偏粉白，
跟其他素材的銀色(`#c9d3c6`)不完全一致，但只是色調偏差、形狀正常，先用著，之後素材
統一校色時再一併處理。

**已知bug記錄（已修正）**：原始`panel_formula_hint_box.png`把計算機紋章畫在「頂部
置中」，這個位置落在九宮格會被水平拉伸的中段區域裡（不像角落雕花是固定不拉伸的），
框被撐寬之後紋章跟著被拉扁變形。修法：用Python從原圖裁出乾淨的邊框樣本，貼掉紋章
所在區域，另存成`panel_formula_hint_box_frame_only.png`當作可以放心九宮格延展的純
背景框；紋章本身從**原始未修改**的`panel_formula_hint_box.png`另外裁成
`badge_formula_hint_calculator.png`，獨立用固定大小的TextureRect疊在框內標題上方，
不會再跟著框的寬度被拉伸。原始`panel_formula_hint_box.png`保留不刪，沒有被覆寫。
