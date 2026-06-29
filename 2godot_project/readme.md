# excel_game_s2 Godot 專案

這個資料夾是 `excel_game_s2` 的 Godot 專案。

採用「零件式」開發：每一個主要玩法或 UI 都先獨立做成清楚命名的 scene，
穩定後再組成完整遊戲。每個零件的檔名前面都有**編號**（`01_`、`02_`...），
方便在檔案越來越多時快速辨認與排序，編號代表零件建立的先後順序，
不代表遊戲內實際執行順序。

---

## 目前主場景

```text
res://02_story_dialogue_ui_demo.tscn
```

這是目前最新的UI零件：Story Dialogue UI Component v0.1 prototype。

---

## 檔案說明

| 檔案 | 用途 |
|---|---|
| `project.godot` | Godot 專案設定。主場景指向 `02_story_dialogue_ui_demo.tscn`。 |
| `01_excel_simulator_step1_countif.tscn` | Excel解謎器（數據計算儀）第1個零件：COUNTIF原型 scene。 |
| `01_excel_simulator_step1_countif.gd` | COUNTIF原型的程式邏輯，內部依「設定→建構→輸入處理→運算核心→公式解析」分區，詳見檔案內註解。**v4架構重做**：表格撐滿空間、整欄/整列/矩形選取拖曳、可編輯格文字/游標顏色、填滿手把`CURSOR_CROSS`滑鼠提示。**已知bug修正（共兩輪）**：每個格子原本蓋了一層`mouse_filter=PASS`的透明選取偵測層，但PASS在Godot裡只會把事件往上傳給父節點、不會往下傳給視覺上被蓋住的同層兄弟節點，導致LineEdit永遠收不到滑鼠事件、點不進去打字——已改成直接訂閱每個LineEdit自己的`gui_input`訊號，不蓋額外覆蓋層。**v5視覺redesign**：把預設亮色系（白底/淺黃底/金邊）換成0mockup/ui_style_guide_v0.1.md的深炭黑/銀框/淡綠/象牙白風格，色票數值沿用`02_story_dialogue_ui_demo.gd`已定案的常數值，避免兩個零件出現不一致的深綠。頂部「保存/讀取/設定」沿用`assets/ui/story_dialogue/`已有的按鈕素材（只做外觀+占位行為，真正存讀檔/設定邏輯留給各自獨立零件）；左側「證言/物證/名冊/交易紀錄」用`assets/ui/excel_solver/tab_category.png`當分類牌底圖+Godot Label疊文字（目前只有一張資料表，分類按鈕只做視覺選取狀態，不做真的切換）；右側案件目標維持占位文字，公式提示列出ui_style_guide公開的函數範例，COUNTIF標示可用、其餘標示尚未開放。已用自動化測試腳本驗證公式邏輯、選取機制、分類按鈕視覺狀態均正常。**v8表格版面改成動態補滿**：拿掉先前手動猜倍率撐大欄寬、用CenterContainer置中的做法（會在視窗變動或資料量改變時立刻跟可用空間對不上），改成`_build_grid()`在畫面排版完成、量到`grid_scroll_container`實際可用寬高後，自動計算右邊/下面還缺多少空間，動態補上延續字母（K、L……）的空白欄、延續列號的空白列，對齊真實Excel「資料範圍以外仍顯示空白格線」的行為；A~J真實欄寬维持原始「依內容自然大小」的數值，不再被硬改。**v9選取系統統一化**（參考舊作v2專案`render.js`：整個可視格線統一可選取、欄寬一致，沒有特別瘦的間隔欄）：補滿欄/補滿列改用跟真實資料格完全相同的`_make_locked_cell()`建構＋註冊進`all_cell_nodes`，不再被選取系統特殊排除；新增`current_column_order`（真實欄位+補滿欄的完整順序）取代選取相關函式裡原本固定10欄的`COLUMN_ORDER`，修正拖曳多選在補滿欄會直接失效、選取範圍延伸進補滿欄會索引超出範圍的問題；I欄（COL_SPACER）改成跟其他欄一樣的正常寬度，不再是視覺上特別瘦的30px間隔欄。**v10接上Mockup精準重建計畫第一批正式素材**（頂部與左側，見`assets/ui/excel_solver/readme.md`）：頂部列改用`panel_top_bar_main.png`九宮格背景＋`badge_title_calculator.png`標題徽章＋`plate_chapter_label.png`章節牌（取代純色`_make_border_stylebox`占位框）；左側面板改用`panel_left_sidebar_main.png`九宮格背景；分類按鈕改用`button_category_base_normal/hover/selected.png`三態九宮格共用底圖＋4張對應icon（`icon_category_*.png`），取代借用存讀檔素材`tab_category.png`的暫時做法；移除已淘汰的`tex_left_tab`/`_load_texture_without_import()`相關程式碼跟`SIDEBAR_TAB_HEIGHT`等舊版專屬常數。**v10.1修正章節牌/分類按鈕變形**：發現章節牌/分類按鈕的素材外框是斜切角造型，沒有乾淨直線可以九宮格延展，套`texture_margin`會把雕花切歪——改成不做九宮格，整張圖依素材原始寬高比（`CHAPTER_PLATE_TEXTURE_ASPECT`／`CATEGORY_BUTTON_TEXTURE_ASPECT`）等比例縮放；分類按鈕的icon也改成自己用置中的`HBoxContainer`疊icon+Label，不用Godot Button內建的icon屬性（Button.icon預設永遠貼在最左邊、不受alignment影響，會卡在按鈕邊框雕花上）。**v11接上Mockup精準重建計畫第二批正式素材**（中央與右側，見`assets/ui/excel_solver/readme.md`）：公式列改用`panel_formula_bar_frame.png`九宮格外框（取代`formula_input`自己畫的淺色細框）；右側面板改用`panel_right_sidebar_main.png`九宮格背景，「案件目標」「公式提示」各自包進`panel_case_objective_box.png`／`panel_formula_hint_box.png`卡片框；案件目標的◇／◆文字符號狀態標記換成`icon_objective_pending/active/done.png`三態圖示。這批素材生成前就先要求是「乾淨直角矩形、裝飾收在角落」，避開第一批章節牌/分類按鈕的變形問題，margin數值都先用Python量測+九宮格試算圖確認無變形才寫進`_make_texture_style()`呼叫（該函式也擴充成支援上下邊距分別指定，因為公式提示框上方有紋章裝飾占用更高範圍）。**v12公式引擎通用化**：先前COUNTIF只認得一種寫死的正規表示式（單欄範圍+條件只能完全相等），改成跟真實Excel一樣的通用邏輯——`_parse_function_call()`/`_split_arguments()`把公式拆成函數名稱跟引數陣列，`_flatten_range()`展開任意矩形範圍（含整欄"E:E"寫法），`_matches_criteria()`支援比較運算子／萬用字元／儲存格參照／純數字純文字條件，對應`excel_teaching.pdf`第九講COUNTIF/COUNTIFS教學內容；新增COUNTIFS支援（多組範圍/條件成對出現，範圍大小須一致）。COUNTIF/COUNTIFS現在不管表格資料怎麼變動都能算出正確答案，不再綁定特定問題的特定答案。**同一輪修正了兩個「點格子應該看到公式、拖曳填滿要有相對參照」相關的bug**：①送出公式後`release_focus()`會同步觸發`focus_exited`又commit一次、把格子文字（計算結果）誤存進`row_formulas`蓋掉原始公式，改成只呼叫`release_focus()`讓`focus_exited`統一commit一次；②拖曳填滿的相對參照改成對齊真實Excel「看`$`不看參數位置」的規則——`_shift_relative_reference()`逐字元掃描整段公式（跳過引號內容），沒加`$`的列號（不管是範圍邊界還是條件參照）都跟著往下遞增，加了`$`（例如`$G$2:$G$9`）才鎖定不動，`_flatten_range()`／`_matches_criteria()`也同步支援解析時先去掉`$`。**新增編輯中內容溢出顯示**：正在編輯的格子如果輸入內容超出欄寬，會像真實Excel一樣往右溢出蓋住右邊格子（離開編輯狀態才收回），做法是只放大LineEdit本身的顯示尺寸＋抬高z_index，wrapper（GridContainer看到的格子大小／欄寬）完全不受影響，表格版面不會被打字內容打亂。**修正溢出文字點不到的問題**：z_index只影響畫面畫在誰上面、不影響滑鼠點擊判定，導致點擊溢出文字時被視覺上蓋住、但節點樹判定順序在前的右邊鎖住格子搶走點擊、誤判成換格結束編輯；新增`_update_overflow_mouse_passthrough()`依目前溢出的實際像素寬度，把被蓋住的右邊格子暫時設成`mouse_filter=IGNORE`讓點擊正確落到編輯中的LineEdit，離開編輯時還原，溢出範圍以外的格子點擊行為不受影響。**新增F4切換參照鎖定**：編輯公式時把游標移到某個儲存格參照上按F4，依真實Excel順序（相對→絕對→鎖列→鎖欄→相對）循環切換`$`鎖定狀態，格子內編輯跟fx公式列都支援，共用`_cycle_reference_lock_at_caret()`。**補上"&"字串連接與IF()巢狀公式**：新增`_evaluate_scalar()`/`_evaluate_term()`通用運算式求值（支援`&`字串連接、巢狀函數呼叫），COUNTIF/COUNTIFS的條件參數現在可以是`A2&"*"`這種運算式；新增`_evaluate_if()`/`_evaluate_condition()`/`_split_condition()`支援`=IF(COUNTIF(...)=0,"未體檢","已體檢")`巢狀寫法，`_evaluate_formula()`的dispatch新增`IF`分支。**修正公式提示清單重複維護**：右側「公式提示」框原本跟`FORMULA_HINTS`常數是兩份各自手寫的清單，容易在新增函數時漏改其中一份；改成直接迴圈`FORMULA_HINTS`、只列出`available=true`的項目，單一資料來源。（案件目標／公式提示要隨章節變動，屬於readme規劃裡還沒開始的「案件資料結構」零件範圍，先不在這個COUNTIF原型裡提前處理。）**新增公式編輯「指向模式」**：對齊真實Excel，編輯中的格子如果內容是以`=`開頭還沒打完的公式，點別的格子會把該格參照插進公式游標位置、焦點留在原本編輯中的格子，不會結束編輯；新增`_try_insert_reference_in_active_formula()`，不依賴猜測Godot內部「點擊搶焦點」跟`gui_input`訊號的執行順序，改成從`row_formulas`讀目前公式內容、插入後明確`grab_focus()`搶回焦點。**修正插入位置跑到"="之前的bug**：原本直接讀`caret_column`會在格子失焦後被重置成0、讀到錯誤位置；嘗試訂閱`caret_changed`訊號記錄位置，但LineEdit在Godot 4沒有這個訊號（執行期報錯），改成新增`_process()`每個畫面更新輪詢一次目前編輯格的`caret_column`記錄下來，插入參照時改讀這份紀錄。 |
| `02_story_dialogue_ui_demo.tscn` | Story Dialogue UI 第2個零件：劇情對話畫面 demo scene。 |
| `02_story_dialogue_ui_demo.gd` | Story Dialogue UI 的程式邏輯，內部依「設定→建構→輸入處理→彈窗互動→自動播放→對白播放→共用輔助函式」分區，詳見檔案內註解。之後可再拆成 DialogueBox、NamePlate、CharacterSpriteLayer 等更小的子零件。存讀檔彈窗（`SaveLoadPopup_CaseFiles`）已用`1UI/save_load`正式美術零件做出6格案件檔案格，由右上角「保存」「讀取」按鈕共用，依模式決定空白格是否可點擊。 |
| `03_map_walker_hotspot_demo.tscn` | Map Walker 第3個零件：純2D環境插畫+熱點彈出特寫卡 demo scene。 |
| `03_map_walker_hotspot_demo.gd` | Map Walker 的程式邏輯，驗證「同一張大地圖上，不同類型熱點分別觸發不同效果」機制：clue（關鍵線索）/flavor（純風味）兩種點擊後彈出占位文字特寫卡，collectible（收藏品，呼應莉莉M編號收藏癖）點擊只彈簡短「已收藏」提示並淡化icon。背景用D1主展場插畫，5個熱點對應case1劇本場景③⑤的洽談室門/側門/塔克/席默+1個收藏品占位。放大鏡icon已換成`assets/ui/map_walker/icon_magnifier_normal\|hover.png`正式素材。內容全為無意義占位文字，不含案件1真實線索（依嚴格規則4）。 |
| `04_map_walker_pov_tree_demo.tscn` | Map Walker 第4個零件：v0.2「兩層熱點」demo scene。 |
| `04_map_walker_pov_tree_demo.gd` | 驗證Map Walker v0.2規劃（見下方章節）：大地圖上的熱點只負責換視角（切到D1九宮格第2/3/4/5/8格正式背景），子背景上才有「真正調查」熱點，依type分door（真的轉場到D2/D3正式背景）/npc（彈出多句占位對話，模擬之後接Story Dialogue UI）/collectible（彈收藏提示）三種行為。內容全為占位文字，不含案件1真實NPC/地點名稱（依嚴格規則4，已修正先前版本誤用真名的問題）。 |
| `assets/ui/story_dialogue/` | Story Dialogue UI 使用的 PNG skin，包括對白框、姓名框、案件目標面板，以及右上角保存/讀取/設定/紀錄/自動五個功能鈕的`button_top_<功能>_<狀態>.png`（每個狀態都是圖示+外框合成好的完整美術圖，來源是`1UI/main_menus/top_menu_ui_normal\|hover\|click`）。 |
| `assets/ui/save_load/` | 存讀檔彈窗使用的 PNG skin（主面板、空白格、已存檔格、選取高亮框），來源是`1UI/save_load/`，細節見資料夾內README。 |
| `assets/ui/map_walker/` | Map Walker 使用的環境插畫（目前只有D1主展場背景，複製自`3case/case1_bg/`），細節見資料夾內README。 |
| `assets/ui/excel_solver/` | Excel解謎器左側分類牌底圖（`tab_category.png`，複製自`1UI/save_load/_source_5_save_load_tab.png`），細節見資料夾內README。頂部按鈕沿用`assets/ui/story_dialogue/`既有素材，沒有另外複製。 |
| `05_ui_tweaker_tool.tscn` | UI 運行時調校工具：解決Vibe Coding寫死座標/大小數值，沒辦法用滑鼠拖拉所見即所得調整的痛點。可實例化成任何畫面的子節點。 |
| `05_ui_tweaker_tool.gd` | 調校工具程式邏輯：掃描目前場景下所有Control節點列入下拉選單，用SpinBox即時調整選中節點的Position/Size/Scale，支援「拖拽模式」直接用滑鼠拖動節點，「複製參數」可把目前數值格式化成GDScript常數寫法複製到剪貼簿，方便貼回對應零件的程式碼設定區。只負責調校與輸出參數，不會自動寫回任何.gd檔案。 |
| `05_ui_tweaker_tool_demo.tscn` / `.gd` | 調校工具的獨立測試場景：放1個假按鈕+2個假面板讓調校工具掃描測試，驗證下拉選單/即時調整/拖拽模式/複製參數四項功能皆正常，跟正式UI零件（02/03/04）無關。 |
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
- Host 透明立繪 prototype
- 測試對白資料

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

如果 Godot 問要不要載入目前主場景，選擇 `02_story_dialogue_ui_demo.tscn`。

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
+其獨立測試場景）。下一個新零件請從 `06_` 開始命名，例如：

- `06_excel_simulator_step2_sumif.gd` / `.tscn`
- `07_save_load_ui_demo.gd` / `.tscn`
- `08_settings_ui_demo.gd` / `.tscn`

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
