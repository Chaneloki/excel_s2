# excel_game_s2 Godot 專案

這個資料夾是 `excel_game_s2` 的 Godot 專案。

採用「零件式」開發：每一個主要玩法或 UI 都先獨立做成清楚命名的 scene，
穩定後再組成完整遊戲。每個零件的檔名前面都有**編號**（`01_`、`02_`...），
方便在檔案越來越多時快速辨認與排序，編號代表零件建立的先後順序，
不代表遊戲內實際執行順序。

---

## 目前主場景

```text
res://09_chapter1_dialogue.tscn
```

這是案件一《缺席者的名字》的**純 Story Dialogue Demo**：全劇本
（s01~s10b）可從頭播放到尾，目前只顯示`dialogue`／`narration`／`system`
內容；案件資料內的`hotspot`與`excel_stage_trigger`會自動略過，不建立
Map Walker或Excel Solver。各零件獨立demo仍保留、沒有刪除或修改，日後
需要時才重新整合。

---

## 檔案說明

| 檔案 | 用途 |
|---|---|
| `project.godot` | Godot 專案設定。主場景指向 `09_chapter1_dialogue.tscn`。 |
| `10_investigation_state.gd` | Detective Mode第10個零件：純邏輯調查狀態核心。以穩定ID管理證據、推論、flags、地點、話題、NPC信任值、hotspot狀態及案件進度，並提供JSON可往返的序列化；不依賴UI、案件一場景或Excel解謎器。 |
| `10_investigation_state_test.gd`／`10_investigation_state_test.tscn` | Investigation State獨立測試場景；以虛構ID驗證去重、解鎖、訊號、狀態讀寫及完整JSON往返，共23項。 |
| `01_excel_simulator_step1_countif.tscn` | Excel解謎器（數據計算儀）第1個零件：COUNTIF原型 scene。 |
| `01_excel_simulator_step1_countif.gd` | COUNTIF原型的程式邏輯，內部依「設定→建構→輸入處理→運算核心→公式解析」分區，詳見檔案內註解。**v4架構重做**：表格撐滿空間、整欄/整列/矩形選取拖曳、可編輯格文字/游標顏色、填滿手把`CURSOR_CROSS`滑鼠提示。**已知bug修正（共兩輪）**：每個格子原本蓋了一層`mouse_filter=PASS`的透明選取偵測層，但PASS在Godot裡只會把事件往上傳給父節點、不會往下傳給視覺上被蓋住的同層兄弟節點，導致LineEdit永遠收不到滑鼠事件、點不進去打字——已改成直接訂閱每個LineEdit自己的`gui_input`訊號，不蓋額外覆蓋層。**v5視覺redesign**：把預設亮色系（白底/淺黃底/金邊）換成0mockup/ui_style_guide_v0.1.md的深炭黑/銀框/淡綠/象牙白風格，色票數值沿用`02_story_dialogue_ui_demo.gd`已定案的常數值，避免兩個零件出現不一致的深綠。頂部「保存/讀取/設定」沿用`assets/ui/story_dialogue/`已有的按鈕素材（只做外觀+占位行為，真正存讀檔/設定邏輯留給各自獨立零件）；左側「證言/物證/名冊/交易紀錄」用`assets/ui/excel_solver/tab_category.png`當分類牌底圖+Godot Label疊文字（目前只有一張資料表，分類按鈕只做視覺選取狀態，不做真的切換）；右側案件目標維持占位文字，公式提示列出ui_style_guide公開的函數範例，COUNTIF標示可用、其餘標示尚未開放。已用自動化測試腳本驗證公式邏輯、選取機制、分類按鈕視覺狀態均正常。**v8表格版面改成動態補滿**：拿掉先前手動猜倍率撐大欄寬、用CenterContainer置中的做法（會在視窗變動或資料量改變時立刻跟可用空間對不上），改成`_build_grid()`在畫面排版完成、量到`grid_scroll_container`實際可用寬高後，自動計算右邊/下面還缺多少空間，動態補上延續字母（K、L……）的空白欄、延續列號的空白列，對齊真實Excel「資料範圍以外仍顯示空白格線」的行為；A~J真實欄寬维持原始「依內容自然大小」的數值，不再被硬改。**v9選取系統統一化**（參考舊作v2專案`render.js`：整個可視格線統一可選取、欄寬一致，沒有特別瘦的間隔欄）：補滿欄/補滿列改用跟真實資料格完全相同的`_make_locked_cell()`建構＋註冊進`all_cell_nodes`，不再被選取系統特殊排除；新增`current_column_order`（真實欄位+補滿欄的完整順序）取代選取相關函式裡原本固定10欄的`COLUMN_ORDER`，修正拖曳多選在補滿欄會直接失效、選取範圍延伸進補滿欄會索引超出範圍的問題；I欄（COL_SPACER）改成跟其他欄一樣的正常寬度，不再是視覺上特別瘦的30px間隔欄。**v10接上Mockup精準重建計畫第一批正式素材**（頂部與左側，見`assets/ui/excel_solver/readme.md`）：頂部列改用`panel_top_bar_main.png`九宮格背景＋`badge_title_calculator.png`標題徽章＋`plate_chapter_label.png`章節牌（取代純色`_make_border_stylebox`占位框）；左側面板改用`panel_left_sidebar_main.png`九宮格背景；分類按鈕改用`button_category_base_normal/hover/selected.png`三態九宮格共用底圖＋4張對應icon（`icon_category_*.png`），取代借用存讀檔素材`tab_category.png`的暫時做法；移除已淘汰的`tex_left_tab`/`_load_texture_without_import()`相關程式碼跟`SIDEBAR_TAB_HEIGHT`等舊版專屬常數。**v10.1修正章節牌/分類按鈕變形**：發現章節牌/分類按鈕的素材外框是斜切角造型，沒有乾淨直線可以九宮格延展，套`texture_margin`會把雕花切歪——改成不做九宮格，整張圖依素材原始寬高比（`CHAPTER_PLATE_TEXTURE_ASPECT`／`CATEGORY_BUTTON_TEXTURE_ASPECT`）等比例縮放；分類按鈕的icon也改成自己用置中的`HBoxContainer`疊icon+Label，不用Godot Button內建的icon屬性（Button.icon預設永遠貼在最左邊、不受alignment影響，會卡在按鈕邊框雕花上）。**v11接上Mockup精準重建計畫第二批正式素材**（中央與右側，見`assets/ui/excel_solver/readme.md`）：公式列改用`panel_formula_bar_frame.png`九宮格外框（取代`formula_input`自己畫的淺色細框）；右側面板改用`panel_right_sidebar_main.png`九宮格背景，「案件目標」「公式提示」各自包進`panel_case_objective_box.png`／`panel_formula_hint_box.png`卡片框；案件目標的◇／◆文字符號狀態標記換成`icon_objective_pending/active/done.png`三態圖示。這批素材生成前就先要求是「乾淨直角矩形、裝飾收在角落」，避開第一批章節牌/分類按鈕的變形問題，margin數值都先用Python量測+九宮格試算圖確認無變形才寫進`_make_texture_style()`呼叫（該函式也擴充成支援上下邊距分別指定，因為公式提示框上方有紋章裝飾占用更高範圍）。**v12公式引擎通用化**：先前COUNTIF只認得一種寫死的正規表示式（單欄範圍+條件只能完全相等），改成跟真實Excel一樣的通用邏輯——`_parse_function_call()`/`_split_arguments()`把公式拆成函數名稱跟引數陣列，`_flatten_range()`展開任意矩形範圍（含整欄"E:E"寫法），`_matches_criteria()`支援比較運算子／萬用字元／儲存格參照／純數字純文字條件，對應`excel_teaching.pdf`第九講COUNTIF/COUNTIFS教學內容；新增COUNTIFS支援（多組範圍/條件成對出現，範圍大小須一致）。COUNTIF/COUNTIFS現在不管表格資料怎麼變動都能算出正確答案，不再綁定特定問題的特定答案。**同一輪修正了兩個「點格子應該看到公式、拖曳填滿要有相對參照」相關的bug**：①送出公式後`release_focus()`會同步觸發`focus_exited`又commit一次、把格子文字（計算結果）誤存進`row_formulas`蓋掉原始公式，改成只呼叫`release_focus()`讓`focus_exited`統一commit一次；②拖曳填滿的相對參照改成對齊真實Excel「看`$`不看參數位置」的規則——`_shift_relative_reference()`逐字元掃描整段公式（跳過引號內容），沒加`$`的列號（不管是範圍邊界還是條件參照）都跟著往下遞增，加了`$`（例如`$G$2:$G$9`）才鎖定不動，`_flatten_range()`／`_matches_criteria()`也同步支援解析時先去掉`$`。**新增編輯中內容溢出顯示**：正在編輯的格子如果輸入內容超出欄寬，會像真實Excel一樣往右溢出蓋住右邊格子（離開編輯狀態才收回），做法是只放大LineEdit本身的顯示尺寸＋抬高z_index，wrapper（GridContainer看到的格子大小／欄寬）完全不受影響，表格版面不會被打字內容打亂。**修正溢出文字點不到的問題**：z_index只影響畫面畫在誰上面、不影響滑鼠點擊判定，導致點擊溢出文字時被視覺上蓋住、但節點樹判定順序在前的右邊鎖住格子搶走點擊、誤判成換格結束編輯；新增`_update_overflow_mouse_passthrough()`依目前溢出的實際像素寬度，把被蓋住的右邊格子暫時設成`mouse_filter=IGNORE`讓點擊正確落到編輯中的LineEdit，離開編輯時還原，溢出範圍以外的格子點擊行為不受影響。**新增F4切換參照鎖定**：編輯公式時把游標移到某個儲存格參照上按F4，依真實Excel順序（相對→絕對→鎖列→鎖欄→相對）循環切換`$`鎖定狀態，格子內編輯跟fx公式列都支援，共用`_cycle_reference_lock_at_caret()`。**補上"&"字串連接與IF()巢狀公式**：新增`_evaluate_scalar()`/`_evaluate_term()`通用運算式求值（支援`&`字串連接、巢狀函數呼叫），COUNTIF/COUNTIFS的條件參數現在可以是`A2&"*"`這種運算式；新增`_evaluate_if()`/`_evaluate_condition()`/`_split_condition()`支援`=IF(COUNTIF(...)=0,"未體檢","已體檢")`巢狀寫法，`_evaluate_formula()`的dispatch新增`IF`分支。**修正公式提示清單重複維護**：右側「公式提示」框原本跟`FORMULA_HINTS`常數是兩份各自手寫的清單，容易在新增函數時漏改其中一份；改成直接迴圈`FORMULA_HINTS`、只列出`available=true`的項目，單一資料來源。（案件目標／公式提示要隨章節變動，屬於readme規劃裡還沒開始的「案件資料結構」零件範圍，先不在這個COUNTIF原型裡提前處理。）**新增公式編輯「指向模式」**：對齊真實Excel，編輯中的格子如果內容是以`=`開頭還沒打完的公式，點別的格子會把該格參照插進公式游標位置、焦點留在原本編輯中的格子，不會結束編輯；新增`_try_insert_reference_in_active_formula()`，不依賴猜測Godot內部「點擊搶焦點」跟`gui_input`訊號的執行順序，改成從`row_formulas`讀目前公式內容、插入後明確`grab_focus()`搶回焦點。**修正插入位置跑到"="之前的bug**：原本直接讀`caret_column`會在格子失焦後被重置成0、讀到錯誤位置；嘗試訂閱`caret_changed`訊號記錄位置，但LineEdit在Godot 4沒有這個訊號（執行期報錯），改成新增`_process()`每個畫面更新輪詢一次目前編輯格的`caret_column`記錄下來，插入參照時改讀這份紀錄。**新增SUMIF/SUMIFS支援**：沿用COUNTIF/COUNTIFS同一套`_flatten_range()`/`_matches_criteria()`，差別只在符合條件時不是+1而是把「加總範圍」對應位置的數值累加（`_evaluate_sumif()`/`_evaluate_sumifs()`），新增`_cell_numeric_value()`（非數字內容視為0，對齊真實Excel SUM系列忽略文字的行為）跟`_format_number()`（整數不顯示多餘的.0、小數只留兩位）；SUMIF的加總範圍放最後且可省略（省略時加總條件範圍本身），SUMIFS的加總範圍放最前且必填，對齊真實Excel兩個函數引數順序不同的習慣。跟COUNTIF/COUNTIFS一樣不綁定特定問題的特定答案，表格資料怎麼變動都能算出正確總和。`FORMULA_HINTS`同步標示SUMIF/SUMIFS為可用。**指向模式擴充支援拖曳範圍**：原本`_try_insert_reference_in_active_formula()`只認得單點點擊，插入單一儲存格參照，拖曳過多格時只會插入第一格、不會變成範圍；改成`_try_begin_formula_pointing()`在按下滑鼠時記錄拖曳起點(`pointing_anchor_cell_id`)跟要插入的游標位置範圍(`pointing_insert_start`/`pointing_insert_end`)，`_input()`新增`is_pointing_range`分支處理拖曳中的滑鼠移動/放開（跟既有的拖拉填滿/矩形選取共用同一套「用`_input()`攔截、避免被途中經過的格子搶走焦點」做法），`_apply_pointing_reference()`依目前框住的矩形範圍（正規化成左上:右下，不管實際拖曳方向）算出"A2:B5"這種範圍參照，每次拖曳移動都用新範圍取代掉上一次插入的那一段（不是疊加插入），對齊真實Excel拖曳選取多格時公式列即時更新成範圍參照的行為；只點一下沒有拖曳則沿用原本插入單一儲存格參照的結果。 |
| `02_story_dialogue_ui_demo.tscn` | Story Dialogue UI 第2個零件：劇情對話畫面 demo scene。 |
| `02_story_dialogue_ui_demo.gd` | Story Dialogue UI 的程式邏輯，內部依「設定→建構→輸入處理→彈窗互動→自動播放→對白播放→共用輔助函式」分區，詳見檔案內註解。之後可再拆成 DialogueBox、NamePlate、CharacterSpriteLayer 等更小的子零件。存讀檔彈窗（`SaveLoadPopup_CaseFiles`）已用`1UI/save_load`正式美術零件做出6格案件檔案格，由右上角「保存」「讀取」按鈕共用，依模式決定空白格是否可點擊。**立繪顯示改成依說話者切換**：原本host(莉希雅)跟其他角色(Sophia)兩個立繪節點永遠同時顯示，跟對白內容無關；改成每句`DIALOGUE_LINES`新增`speaker_id`欄位，`_show_line()`呼叫新增的`_update_speaker_sprite()`依`speaker_id`決定同一時間只顯示一位——host固定左下角蓋在對話框上面，其他角色固定置中，沒有`speaker_id`（系統訊息）則兩者都隱藏；新增`CHARACTER_SPRITE_TEXTURES`對照表，之後其餘角色加入只要新增對照即可。同時修正`SOPHIA_TEMP`原本誤指向host圖檔的問題，改指向正確的`sophia_story_transparent_v0_1.png`。**設定彈窗補上真正可動的分頁與文字/自動播放速度設定**：原本「顯示與輔助」分頁的切換按鈕只有函式定義、從沒被呼叫過（`tex_tab_bg`貼圖也從沒被指定，是個沒接上的半成品），畫面上只看得到「音訊設定」分頁的BGM/音效音量兩條滑桿；改成分頁按鈕沿用`button_icon_frame_*.png`通用小按鈕素材（`_make_framed_button()`），`_build_settings_tabs()`真正加進版面並接上`_select_settings_tab()`切換顯示。「顯示與輔助」分頁新增「文字速度」「自動播放速度」兩條滑桿（沿用音量滑桿同一套0~1比例值元件），`_get_typing_speed_char()`/`_get_auto_advance_seconds()`依比例值內插出實際的「每字顯示秒數」/「自動播放等待秒數」，取代原本寫死的`TYPING_SPEED_CHAR`/`AUTO_ADVANCE_SECONDS`常數，調整滑桿會立刻改變打字機速度跟自動播放間隔。對白框透明度/全螢幕/解析度/動畫特效（ui_style_guide第10節其餘項目）留給之後獨立的Settings UI零件。**修正分頁按鈕位置與外觀**：分頁按鈕原本借用`button_icon_frame_*.png`（設計給單一圖示用的素材）拉伸成長條文字按鈕，邊框比例跑掉、看起來像兩層疊框，且整排貼著卡片左上角、跟銀色雕花轉角裝飾疊在一起；改成`_make_settings_tab_button()`直接用`_make_flat_panel_style()`畫低調矩形+銀框（對齊ui_style_guide第5節按鈕風格規則），選中時邊框/底色換成淡綠強調（新增`COLOR_SETTINGS_TAB_BG_NORMAL/SELECTED`、`COLOR_SETTINGS_TAB_BORDER_SELECTED`），不需要額外素材；`_build_settings_tabs()`容器最前面加一個固定寬度的空白`Control`（`SETTINGS_TAB_ROW_LEFT_INDENT`）把整排往右推開，外面再包一層只加top margin的`MarginContainer`（`SETTINGS_TAB_ROW_TOP_OFFSET`）往下移，避開角落裝飾。**新增host立繪人形輪廓陰影**：去背PNG邊緣是人形不是方形，一般方形陰影會露出矩形邊界，改成複製同一張貼圖、`modulate`染黑調低透明度、整體偏移疊在底下，陰影輪廓自然跟立繪本身完全一致；新增的`host_sprite_shadow`跟著`host_sprite`一起顯示/隱藏。**新增CG場景專用版面**：CG（全螢幕過場插畫）出現時不用平常的雕花對話框，改成全螢幕插畫（目前是佔位色平面，尚無正式CG素材）疊一條矮、貼齊螢幕左右邊緣的簡單矩形文字條，不顯示姓名、角色立繪全部隱藏；`DIALOGUE_LINES`新增`"scene":"cg"`標記，新增`_build_cg_layer()`/`_build_cg_text_bar()`/`_set_cg_mode()`，`_show_line()`/`_next_line()`改用新增的`active_dialogue_label`追蹤目前實際在播放打字機效果的Label（CG場景是`cg_text_label`、平常是`dialogue_label`）。**依參考圖修正文字條位置/配色**：位置從貼底部改成畫面中下段、更矮的比例；配色改成深炭黑半透明（新增`COLOR_CG_TEXT_BAR_BG`，alpha約0.55），不再暫時沿用偏深綠的`COLOR_PANEL_HEADER`；確認後移除銀色外框與淡綠細節線，CG畫面維持單純乾淨，只留半透明底色+象牙白文字，跟平常雕花對話框刻意做出區別。**CG文字整句直接顯示**：CG場景不用逐字打字機效果，`_show_line()`偵測到`is_cg_scene`時直接把文字Label的`visible_ratio`設成1.0顯示完整文字，不建立Tween；一般場景的打字機邏輯不受影響。 |
| `03_map_walker_hotspot_demo.tscn` | Map Walker 第3個零件：純2D環境插畫+熱點彈出特寫卡 demo scene。 |
| `03_map_walker_hotspot_demo.gd` | Map Walker 的程式邏輯，驗證「同一張大地圖上，不同類型熱點分別觸發不同效果」機制：clue（關鍵線索）/flavor（純風味）兩種點擊後彈出占位文字特寫卡，collectible（收藏品，呼應莉莉M編號收藏癖）點擊只彈簡短「已收藏」提示並淡化icon。背景用D1主展場插畫，5個熱點對應case1劇本場景③⑤的洽談室門/側門/塔克/席默+1個收藏品占位。放大鏡icon已換成`assets/ui/map_walker/icon_magnifier_normal\|hover.png`正式素材。內容全為無意義占位文字，不含案件1真實線索（依嚴格規則4）。 |
| `04_map_walker_pov_tree_demo.tscn` | Map Walker 第4個零件：v0.2「兩層熱點」demo scene。 |
| `04_map_walker_pov_tree_demo.gd` | 驗證Map Walker v0.2規劃（見下方章節）：大地圖上的熱點只負責換視角（切到D1九宮格第2/3/4/5/8格正式背景），子背景上才有「真正調查」熱點，依type分door（真的轉場到D2/D3正式背景）/npc（彈出多句占位對話，模擬之後接Story Dialogue UI）/collectible（彈收藏提示）三種行為。內容全為占位文字，不含案件1真實NPC/地點名稱（依嚴格規則4，已修正先前版本誤用真名的問題）。 |
| `assets/ui/story_dialogue/` | Story Dialogue UI 使用的 PNG skin，包括對白框、姓名框、案件目標面板，以及右上角保存/讀取/設定/紀錄/自動五個功能鈕的`button_top_<功能>_<狀態>.png`（每個狀態都是圖示+外框合成好的完整美術圖，來源是`1UI/main_menus/top_menu_ui_normal\|hover\|click`）。 |
| `assets/ui/save_load/` | 存讀檔彈窗使用的 PNG skin（主面板、空白格、已存檔格、選取高亮框），來源是`1UI/save_load/`，細節見資料夾內README。 |
| `assets/ui/map_walker/` | Map Walker 使用的環境插畫（目前只有D1主展場背景，複製自`3case/case1_bg/`），細節見資料夾內README。 |
| `assets/ui/excel_solver/` | Excel解謎器左側分類牌底圖（`tab_category.png`，複製自`1UI/save_load/_source_5_save_load_tab.png`），細節見資料夾內README。頂部按鈕沿用`assets/ui/story_dialogue/`既有素材，沒有另外複製。 |
| `assets/characters/` | Story Dialogue UI用的角色去背立繪，含host/sophia/案件一NPC的預設立繪跟表情差分，複製自`1char/`，細節見資料夾內README。 |
| `assets/backgrounds/` | Story Dialogue UI用的場景背景（偵探所/商會辦事處/走廊/旅館茶室/旅館外街道，共5張），複製自`3case/case1_bg/`，細節見資料夾內README。 |
| `assets/cg/` | Story Dialogue UI用的CG（全螢幕過場插畫）正式素材，共5張，複製自`3case/case1_cg/`，細節見資料夾內README。 |
| `assets/se/` | Chapter 1逐句音效素材，共82個MP3，複製自根目錄`1se/`並把檔名空白正規化成小寫底線。整合Demo的對白資料加入`"se":"<檔名，不含.mp3>"`即可在進入該句時播放一次；使用獨立播放器，不中斷BGM，音量接設定畫面的「音效音量」。細節與範例見資料夾內README。 |
| `05_ui_tweaker_tool.tscn` | UI 運行時調校工具：解決Vibe Coding寫死座標/大小數值，沒辦法用滑鼠拖拉所見即所得調整的痛點。可實例化成任何畫面的子節點。 |
| `05_ui_tweaker_tool.gd` | 調校工具程式邏輯：掃描目前場景下所有Control節點列入下拉選單，用SpinBox即時調整選中節點的Position/Size/Scale，支援「拖拽模式」直接用滑鼠拖動節點，「複製參數」可把目前數值格式化成GDScript常數寫法複製到剪貼簿，方便貼回對應零件的程式碼設定區。只負責調校與輸出參數，不會自動寫回任何.gd檔案。 |
| `05_ui_tweaker_tool_demo.tscn` / `.gd` | 調校工具的獨立測試場景：放1個假按鈕+2個假面板讓調校工具掃描測試，驗證下拉選單/即時調整/拖拽模式/複製參數四項功能皆正常，跟正式UI零件（02/03/04）無關。 |
| `06_save_system.gd` | 存讀檔零件：真正把遊戲進度寫進磁碟/讀回來，跟UI完全分離。`SaveSystem`（`class_name`，無對應`.tscn`，純邏輯不需要場景節點）以靜態函式提供`has_save(slot_index)`／`save_slot(slot_index, data)`／`load_slot(slot_index)`，存檔寫成JSON純文字檔到`user://saves/slot_<編號>.json`（6格對齊存讀檔彈窗版面，編號0~5）。`02_story_dialogue_ui_demo.gd`的存讀檔彈窗已接上：原本6格存讀檔資料`SAVE_LOAD_SLOT_DATA`是寫死的占位陣列（前2格已存檔、其餘空白），改成`_refresh_save_load_grid()`每次開彈窗都直接問`SaveSystem.has_save()`/`load_slot()`決定格子要顯示「已存檔」還是「空白檔案」貼圖/文字，不再寫死；點擊保存模式的格子會呼叫`_gather_save_data()`整理目前對白index跟目前案件目標id存進去，點擊讀取模式的已存檔格子會呼叫`_apply_save_data()`還原對白播放位置跟案件目標進度。章節名稱/地點/狀態文字改讀`CaseData`（見下方07零件），不再是寫死的結構性常數。 |
| `07_case_data.gd` | 「案件資料結構」零件：`CaseData`（`class_name`，無對應`.tscn`，純邏輯）以靜態函式讀`data/cases/<case_id>.json`，提供`load_case()`/`get_dialogue_lines()`/`get_objective_text()`/`get_active_objectives()`/`get_excel_stage()`/`get_character()`，把章節名稱/對白腳本/案件目標/Excel解謎器各關設定/角色立繪對照，從02/01兩個demo內部寫死的占位常數，搬到跟UI完全解耦的JSON資料檔。`02_story_dialogue_ui_demo.gd`已改讀真實`case_01.json`：`DIALOGUE_LINES`/`CASE_OBJECTIVES`兩個占位常數整個移除，對白播放、案件目標小面板（依`objective_update`欄位動態算出done/active清單並重建面板）、存讀檔資料、角色立繪資料（`character_data`，含host，取代原本寫死的`CHARACTER_SPRITE_TEXTURES`/`HOST_TEMP`/`SOPHIA_TEMP`）全部改讀`case_data`。新增**場景背景／CG插畫／角色表情差分**支援：`case_01.json`新增`backgrounds`/`cg_images`字典跟角色`expressions`子欄位，對白資料新增可省略的`"background"`/`"cg"`/`"expression"`欄位，`_switch_background()`依背景id換貼圖（非開場第一次切換會包`08_dialogue_effects.gd`的黑屏轉場）、`_resolve_sprite_path()`依`speaker_id`+`expression`算出實際立繪路徑（對不到表情就退回預設`sprite`，不報錯）、`cg_image_rect`疊在CG佔位層之上顯示真正的CG插畫。**修正一個欄位命名撞名的bug**：案件資料原本的場景分組標籤跟既有CG模式判斷都叫`"scene"`，導致CG模式永遠判斷不到、從沒被觸發過，已把分組標籤改名成`"scene_id"`，`"scene":"cg"`留給真正的CG旗標。`01_excel_simulator_step1_countif.gd`的頂部章節牌文字跟右側「案件目標」三列，也改讀同一份`case_01.json`（`PLACEHOLDER_CASE_TITLE`/`PLACEHOLDER_CASE_OBJECTIVES`兩個占位常數已移除），這個COUNTIF原型對應劇本場景④第一關，固定把`stage_countif`標記成「進行中」、其餘關卡標記「尚未開始」。獨立測試見`07_case_data_test.gd`/`.tscn`，資料檔規格見[data/cases/readme.md](data/cases/readme.md)。 |
| `08_dialogue_effects.gd` / `.tscn` | 「劇情特效」零件：提供`shake()`（震動）/`flash()`（全螢幕白閃）/`punch_zoom()`（瞬間放大彈回）/`fade_to_black()`+`fade_from_black()`（黑屏轉場）/`fade_sprite_visibility()`（角色立繪淡入淡出）/`ken_burns()`（背景緩慢縮放+位移）六個public函式，跟`05_ui_tweaker_tool`一樣是可以直接`add_child()`掛載的工具節點，本身不認識任何劇本內容。**`ken_burns()`歷經三輪修正**：v1參考使用者舊作v2專案`code/ui_v2_story.js`的「sticky camera」CSS transition概念，用Control的`scale`+`pivot_offset`做縮放；v2發現每次呼叫都強制重設`scale=(1,1)`/`position=(0,0)`會造成「像lag、會抖動」（連續設定相近目標時畫面先跳回原點再重新動）。改成「目前值當起點」後使用者實測仍會抖動，懷疑是`scale`/`pivot_offset`這套Control transform本身在Godot裡跟錨點佈局系統有微妙的互相影響——**v3改成完全不用scale/pivot_offset，直接動畫`offset_left/top/right/bottom`四個錨點偏移值**，讓滿版背景矩形本身往外長大（=zoom）再整體偏移（=pan），靠`STRETCH_KEEP_ASPECT_COVERED`自然蓋住多出來的範圍。v3仍有緩慢上下移動像卡頓的階梯感；查核Godot官方文件與社群案例後確認，原因是`Control`預設把位置吸附到整數像素，慢速Tween會形成「停幾幀、跳一像素」。**v4在Ken Burns播放期間暫時關閉所屬Viewport的`gui_snap_controls_to_pixels`，動畫結束或零件離開場景時還原原設定**；若動畫中途被下一段取代，使用動畫編號避免舊Tween提早恢復吸附。簽名維持`ken_burns(target, base_size, zoom_to, pan_factor, duration)`，`base_size`是target在offset全部=0時的原始尺寸（呼叫端要在背景剛建立、還沒被放大過的時候量一次存起來），`pan_factor`是x/y各自-1~1的方向係數（不是像素，實際像素由函式依`base_size`/`zoom_to`算出）。獨立測試見`08_dialogue_effects_test.gd`/`.tscn`（6顆按鈕分別觸發，Ken Burns測試用獨立的`BgTestRect`滿版節點+來回切換兩個目標驗證「接續不跳回原點」，不能跟其他5個測試共用`TargetBox`）。 |
| `09_chapter1_dialogue.gd` / `.tscn` | **整合Demo母控制場景**：複製自`02_story_dialogue_ui_demo.gd`/`.tscn`（02本體完全沒被改動，繼續當獨立demo），新增`excel_solver_container`/`current_excel_solver`/`_enter_excel_stage()`/`_on_excel_stage_solved()`——劇本播到`type:"excel_stage_trigger"`的那句時，不再像02demo合成一句系統訊息文字，是真的實例化`09_chapter1_excel_solver.tscn`、指定對應`stage_id`、蓋滿全螢幕讓玩家互動，答對（`puzzle_solved`訊號）才移除實例、繼續播下一句對白。`_unhandled_input()`的點擊防穿透guard也加上`excel_solver_container.visible`，數據計算儀開著時點擊/Space不會穿透推進劇情。**新增BGM播放**：`_build_bgm_player()`掛一個`AudioStreamPlayer`，`_switch_bgm()`依`case_01.json`對白資料的`"bgm"`欄位換曲（換到不同曲目才會觸發，先把目前音量淡出到`BGM_FADE_OUT_VOLUME_DB`、換`stream`、再淡入），設定彈窗的BGM音量滑桿（`_set_bgm_volume()`）原本只存一個沒人讀的數字，現在真的會改變播放器音量。素材跟對照表見[assets/bgm/readme.md](assets/bgm/readme.md)，這份BGM-場景對照是依檔名語意排的草案，需要使用者實際聽過確認。**新增背景縮放/位移（鏡頭運鏡）**：參考使用者舊作v2專案`code/ui_v2_story.js`的「sticky camera」設計（`currentBgZoom`/`currentBgFx`/`currentBgFy`持久狀態），`case_01.json`對白資料新增可省略的`"bg_zoom"`（縮放倍率）/`"bg_pos"`（方向關鍵字，對照v2的`posFactors`表：`center`/`left`/`right`/`top`/`bottom`及四個角落+`center bottom`）/`"bg_zoom_duration"`欄位——只有這句話真的帶了`bg_zoom`或`bg_pos`才會更新鏡頭目標並啟動新動畫，沒帶的句子完全不會碰，前一句還在跑、還沒跑完的動畫會繼續跑完。`current_bg_zoom`/`current_bg_fx`/`current_bg_fy`三個sticky狀態變數記著「目前設定到哪裡」，實際換算成`offset_left/top/right/bottom`目標值的計算交給`08_dialogue_effects.gd`的`ken_burns()`處理（見該零件的readme說明，v3已改成offset-based，不用scale/pivot_offset）；`background_base_size`是`_build_background()`建好背景、offset還是0時量一次存起來的原始尺寸，每次呼叫`ken_burns()`都要傳這個值，不能用`background_rect.size`現場量（動畫進行中該值已經反映放大後的尺寸）。 |
| `09_chapter1_excel_solver.gd` / `.tscn` | **整合Demo用的數據計算儀**：複製自`01_excel_simulator_step1_countif.gd`/`.tscn`（01本體完全沒被改動，繼續當COUNTIF原型獨立demo），新增`stage_id`（由09_chapter1_dialogue.gd在`instantiate()`後、`add_child()`前指定）、`puzzle_solved`訊號、`STAGE_TABLE_DATA`（案件一三關真實資料，取代原本8人測試資料T1~T8：第一關簽到名冊vs離場記錄14/15人、第二關區域進出記錄含洽談室17:20-17:40時段判定、第三關貝洛特費用明細雜項加總1275）、`_check_stage_solved()`（玩家答對後自動偵測並emit signal，COUNTIF/COUNTIFS檢查貝洛特那一列狀態欄、SUMIF檢查任一格狀態欄）。右側「公式提示」改依`case_data.excel_stages[stage_id].available_functions`（累積式）篩選，不再三關都顯示COUNTIF~SUMIFS全部可用，避免在第一關就先暴雷後面的函數。 |
| `app_icon.svg` | Godot 專案 icon。 |
| `.godot/` | Godot 自動產生的專案快取資料夾，不需要手動修改。 |

---

## Story Dialogue UI v0.1 範圍

目前 demo 已有：

- 偵探所背景 placeholder
- Host 立繪 placeholder
- 姓名框
- 對白框
- 點擊滑鼠左鍵下一句
- Space / Enter 下一句
- 右上角按鈕：保存、讀取、設定、紀錄、自動
- 小型案件目標面板，可展開/收合
- 設定 prototype：BGM / SFX 音量 slider，暫時只保存畫面數值
- 保存/讀取 prototype：案件簿彈窗與6個存檔格 UI（套用正式save_load美術，2排x3欄），讀取模式空白格不可點擊，暫時不寫入實際檔案
- 紀錄 prototype：可滾動調查紀錄彈窗，暫時從 demo 對白生成
- 自動播放 prototype：按鈕切換自動播放狀態，手動點擊時會關閉
- Host 透明立繪 prototype（固定左下角，蓋在對話框上面）
- 依說話者切換立繪：每句對白依`speaker_id`只顯示一位角色（host置左下角，其他角色置中），不會同時顯示多位
- CG場景專用版面：依`scene:"cg"`標記切換成全螢幕插畫（佔位）+矮文字條，取代平常的雕花對話框
- 測試對白資料（含一句Sophia占位對白驗證立繪切換機制、一句CG佔位對白驗證CG版面切換機制）

目前 demo 暫時不做：

- 真正保存 / 讀取檔案
- 真正設定資料持久化與 AudioBus 連接
- 真正隨玩家閱讀進度追加的對白紀錄
- 角色最終正式立繪
- 背景正式美術
- Excel Solver 連接
- Map Walker 連接
- 獨立 Save/Load、Settings、Dialogue Log 場景；目前這些只是在 Story Dialogue UI 內做可互動 prototype

---

## 整合Demo（案件一，09_chapter1_*）範圍與限制

`09_chapter1_dialogue.tscn`是目前的主場景，案件一s01~s10b全劇本可以從頭
玩到尾，劇情走到Excel三關時真的會切換成可互動、答對才能繼續的數據計算儀
（細節見上方檔案說明）。**這次整合範圍故意縮小，明確不包含**：

- **Map Walker未接上**：劇本場景③⑤（展示廳地圖走查，洽談室/側門/塔克/
  席默/瑞娜）這次維持「劇情文字播放」，不會切換成03/04的可點擊地圖畫面。
  原因：要把這些對話內容改造成真正的地圖熱點互動，需要重新設計熱點版面/
  特寫卡內容，工程量跟Excel解謎器整合相當，這次先讓「文字劇本＋Excel
  解謎」這條主線可以完整玩通，Map Walker視覺化留作下一個獨立整合任務。
- 01~08八個零件**完全沒有被修改**，09只是複製02（對話UI）跟01（COUNTIF
  引擎）出來、在複製出來的檔案上加整合邏輯，原本的獨立demo繼續可以單獨
  打開測試，不受09開發影響。

---

## Map Walker 技術路線（已定案，第一個零件已完成）

曾經試做過「3D box-out場景 + 第一人稱固定觀察點」（`03_map_walker_3d_lite_demo`）
驗證NPC比例問題，但實測發現門/旗幟/展示桌這類2D插畫貼上3D幾何後，視覺上仍有明顯
「貼紙感」，品質天花板不夠高，**該demo已移除**。

Map Walker正式定案改用**純2D環境插畫＋熱點彈出特寫卡**：畫面是一張完整的AI生成
場景插畫（不放玩家自己的avatar，因此不需要處理avatar比例問題），玩家點擊熱點
（放大鏡icon）後彈出對應的特寫卡片。場景插畫見`3case/case1_bg/`，多機位9宮格
（鏡位備選）見`3case/case1_bg_grid9/`，生成prompt見`3case/case1_bg_prompts_flat_v1.md`。

機制本身已用`03_map_walker_hotspot_demo.gd`/`.tscn`獨立驗證完成（**v0.1，已完成**）：
D1主展場背景疊5個占位熱點，依type（clue/flavor/collectible）觸發不同反應
（特寫卡彈窗 或 收藏提示），可正常開關。下一步是擴充SUMIF/VLOOKUP等Excel函數零件，
Map Walker要再回頭做下面規劃的v0.2範圍。

### Map Walker v0.2（兩層熱點結構，機制已完成驗證）

v0.1只驗證了「點熱點→彈卡片」這個最小機制，互動感太單薄（玩家只是看一張靜止圖+
點幾個點），跟實際想要的地圖走查體感差距大。討論後定調的下一版方向是**兩層熱點**：

- **大地圖層**（主背景，例如D1場景設定圖/第6格）上的放大鏡熱點 = 只負責「換視角」，
  點下去畫面**切換成對應的特寫/其他鏡位背景**（例如D1的第2、3、4、5、8格），
  不直接顯示調查結果。
- **特寫/子背景層**上的放大鏡熱點 = 才是真正的「調查」互動：
  - 對應**門**的子背景（例如洽談室門、側門）→ 熱點點下去是「確認要不要走進去」
    →真的切換到對應場景的完整背景（例如D2、D3）。
  - 對應**NPC**的子背景（例如門衛、工匠）→ 熱點點下去要接到Story Dialogue UI
    播放多句對話（莉莉/蘇菲亞/NPC互動），不是塞進一張卡片的單段文字。
  - 對應**物件/收藏品**的子背景 → 維持v0.1那種輕量彈窗或收藏提示即可。

整體結構等於一棵樹：主背景 → 點熱點換到子背景（對應已選定的9宮格鏡位） →
子背景上的熱點才觸發真正的互動（轉場/對話/彈窗/收藏）。這個設計剛好跟已經選定的
D1九宮格素材（第2/3/4/5/8格）對應，每一格會變成樹裡的一個子背景節點，不用額外多生圖。

**目前狀態：機制已用`04_map_walker_pov_tree_demo.gd`/`.tscn`獨立驗證完成。**
用D1主背景+九宮格第2/3/4/5/8格正式素材（`assets/ui/map_walker/bg_exhibition_hall_d1_pov_*.png`）
搭建兩層熱點：大地圖換視角→子背景投資調查→依type真的轉場（door，沿用D2/D3正式背景）
／彈占位多句對話（npc）／彈收藏提示（collectible）。畫面左上角有麵包屑顯示目前位置、
返回大地圖按鈕可隨時跳回主視角。內容全為占位文字，不含案件1真實NPC/地點名稱。

待補：NPC類熱點目前只彈占位文字多句對話，真正接上Story Dialogue UI播放（含立繪、
打字機效果）要等案件資料結構/劇本對白拆分零件完成後，在整合Demo階段才處理；
門類熱點轉場後的下一個場景（D2/D3）目前是死圖，沒有自己的熱點，之後若要繼續往
下深入（例如D2內部也要能調查物件），需要再擴充這個零件或另開新零件。

---

## 怎麼打開

1. 打開 Godot。
2. Import / Open project。
3. 選擇這個資料夾裡的 `project.godot`。
4. 按 Play / F5。

如果 Godot 問要不要載入目前主場景，選擇 `09_chapter1_dialogue.tscn`。

---

## 命名規則

1. **全部小寫 + 底線**：不使用空白或大寫字母（例如 `story_dialogue_ui_mockup.png`，
   不要 `UI_style_guide v0.1.md`）。
2. **編號前綴**：每個零件的`.gd`/`.tscn`檔名前面加兩位數編號（`01_`、`02_`...），
   同一個零件的`.gd`跟`.tscn`要用同一個編號，方便配對辨識。
3. **檔名要清楚反映用途**：禁止 `test`、`scene1`、`new_script`、`main` 這種
   無意義命名。
4. 例外：Godot 規定的固定檔名（`project.godot`）跟自動生成的快取/匯入檔
   （`.godot/`、`*.uid`、`*.import`）不受此規則限制，不要手動改它們的名字。

目前已用到的編號：01（Excel解謎器COUNTIF）、02（Story Dialogue UI）、
03（Map Walker熱點demo）、04（Map Walker兩層熱點demo）、05（UI調校工具
+其獨立測試場景）、06（存讀檔零件`SaveSystem`，純邏輯無對應`.tscn`）、
07（案件資料結構零件`CaseData`+其獨立測試場景）、08（劇情特效零件
`DialogueEffects`+其獨立測試場景）、09（案件一純劇情Demo）、
10（Detective Mode調查狀態核心`InvestigationState`+其獨立測試場景）。
下一個Detective Mode零件按規劃使用 `11_`：

- `11_detective_pov_camera.gd` / `.tscn`

---

## 程式碼規範

1. **所有註解使用繁體中文**，並依邏輯執行順序分區說明（設定 → 建構 →
   輸入處理 → 核心邏輯），參考`01_excel_simulator_step1_countif.gd`跟
   `02_story_dialogue_ui_demo.gd`檔案開頭的區塊註解寫法。
2. **禁止不必要的硬編碼**：重複出現的顏色、字體大小、間距、版面數字，
   一律在檔案最上面的「設定區」集中定義成具名常數，函式裡只能引用
   常數，不能直接寫魔法數字/顏色字串。
3. 結構性常數（畫面版面設計本身的參數，例如表格大小、案件目標清單
   內容）可以保留具名常數的形式，不算違規硬編碼。
