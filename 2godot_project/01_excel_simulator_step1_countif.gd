extends Control

# ------------------------------
# 異動紀錄 (Change Log):
# 2026-06-28:
#   1. 架構重做（v2~v4）：v1只驗證COUNTIF字串解析，跟案件1實際玩法骨架
#      對不上。v2補上「整欄填滿＋跨表查找＋相對參照」三個邏輯骨架。v3
#      把表格從3欄擴成8+1欄、撐滿畫面、填滿方式改成拖曳儲存格右下角
#      手把。v4修正表格沒撐滿可用空間、無法選整欄整列/拖曳多格、可編輯
#      格文字游標看不清楚、填滿手把無滑鼠提示、以及點格子永遠拿不到
#      焦點（蓋了一層mouse_filter=PASS的選取偵測層擋住下面的LineEdit，
#      改成直接訂閱LineEdit自己的gui_input訊號解決）。
#   2. 視覺redesign（v5）：把預設亮色系換成0mockup/ui_style_guide_v0.1.md
#      的深炭黑/銀框/淡綠/象牙白風格，色票常數沿用02_story_dialogue_ui_
#      demo.gd已定案的值；頂部功能列、左側案件資料分類、右側案件目標/
#      公式提示從純文字占位換成有實際版面結構的容器，並接上Story
#      Dialogue UI與存讀檔零件已有的正式美術素材。
#   3. 版面細修（v6~v7）：左側分類牌按鈕高度改成依素材實際寬高比
#      （1080:573）反推計算，不再硬壓造成雕花變形；表格欄寬改成
#      COLUMN_WIDTHS固定像素字典，取代「依文字內容自動決定欄寬」造成
#      的參差不齊；中央表格區改用CenterContainer水平置中，避免欄寬
#      固定後表格被無限拉伸撐開。
# ------------------------------

# ============================================================
# Excel 模擬器 - Step 1 原型（只支援 COUNTIF）— v5 視覺redesign
#
# v4把表格骨架（全螢幕、整欄/整列/矩形選取、拖拉填滿）跟互動bug都修好了，
# 這個v5只換皮，不動任何公式邏輯／選取邏輯：把預設亮色系換成
# 0mockup/ui_style_guide_v0.1.md定義的「貴族偵探×魔法資料學」風格
# （深炭黑底、銀色細框、淡綠互動提示、象牙白文字），並把原本「占位：xxx」
# 純文字的頂部功能列/左側分類/右側案件目標公式提示，換成有實際版面結構
# 的容器＋已有的正式美術素材（沿用Story Dialogue UI跟存讀檔零件已經做好
# 的按鈕/分類牌素材，顏色常數沿用02_story_dialogue_ui_demo.gd已定案的
# 色票，避免兩個零件出現「同一個遊戲兩種深綠」的不一致）。
#
# 範圍邊界（避免跟其他已排隊零件的工作重複）：
#   - 頂部「保存／讀取／設定」只做外觀＋占位行為，不接真實存讀檔/設定，
#     那是Save/Load UI、Settings UI各自獨立零件的範圍。
#   - 左側「證言／物證／名冊／交易紀錄」目前只有一張資料表，分類按鈕
#     只做外觀＋視覺選取狀態，不做真的切換資料表（之後有多張表時再接）。
#   - 右側案件目標清單內容維持無意義占位文字，不放案件1真實目標
#     （依嚴格規則4）；公式提示清單則列出ui_style_guide本來就公開的
#     函數名稱範例，COUNTIF標示為目前可用、其餘標示為尚未開放。
#
# 程式碼的邏輯順序（從上到下對應實際執行順序）：
#   1. 設定區：表格大小、假資料、版面數字、占位文字、資產路徑、配色。
#   2. _ready()：畫面建構，依「整體深色背景 → 頂部功能列 → 主體
#      （左側分類＋中央表格區＋右側案件目標/公式提示） → 底部提示列」
#      的順序疊畫面。
#   3. 格子建構函式：統一的儲存格元件，包含選取拖曳訊號、可編輯格額外
#      帶拖拉填滿手把。（這部分跟v4完全相同，只是顏色常數的值換了。）
#   4. 使用者輸入處理：單格編輯、整欄/整列選取、矩形範圍選取拖曳、
#      拖拉填滿手把。（v4邏輯不變。）
#   5. 公式運算核心。（v3起邏輯不變。）
#   6. 公式解析。（v3起邏輯不變。）
# ============================================================


# ------------------------------------------------------------
# 1. 設定區
# ------------------------------------------------------------

const COL_PERSON := "A"
const COL_TIME := "B"
const COL_LOCATION := "C"
const COL_AMOUNT := "D"
const COL_ITEM := "E"
const COL_WITNESS := "F"
const COL_STATUS := "G"  # 唯一可編輯欄
const COL_NOTE := "H"
const COL_SPACER := "I"
const COL_REFERENCE_LIST := "J"  # 跨查用的第二份清單

const COLUMN_ORDER := [COL_PERSON, COL_TIME, COL_LOCATION, COL_AMOUNT, COL_ITEM, COL_WITNESS, COL_STATUS, COL_NOTE, COL_SPACER, COL_REFERENCE_LIST]

const DATA_START_ROW := 2

const TABLE_ONE_DATA := [
	{"person": "T1", "time": "09:00", "location": "地點1", "amount": "100", "item": "物品1", "witness": "證人1", "note": "備註1"},
	{"person": "T2", "time": "09:05", "location": "地點2", "amount": "200", "item": "物品2", "witness": "證人2", "note": "備註2"},
	{"person": "T3", "time": "09:10", "location": "地點3", "amount": "300", "item": "物品3", "witness": "證人3", "note": "備註3"},
	{"person": "T4", "time": "09:15", "location": "地點4", "amount": "400", "item": "物品4", "witness": "證人4", "note": "備註4"},
	{"person": "T5", "time": "09:20", "location": "地點5", "amount": "500", "item": "物品5", "witness": "證人5", "note": "備註5"},
	{"person": "T6", "time": "09:25", "location": "地點6", "amount": "600", "item": "物品6", "witness": "證人6", "note": "備註6"},
	{"person": "T7", "time": "09:30", "location": "地點7", "amount": "700", "item": "物品7", "witness": "證人7", "note": "備註7"},
	{"person": "T8", "time": "09:35", "location": "地點8", "amount": "800", "item": "物品8", "witness": "證人8", "note": "備註8"},
]

# 故意缺少T4，用來驗證COUNTIF能不能正確抓出「表一出現、表二沒有」的那一列。
const TABLE_TWO_NAMES := ["T1", "T2", "T3", "T5", "T6", "T7", "T8"]

const EXAMPLE_FORMULA = '=COUNTIF(J2:J9,A2)'

# ---- 占位文字（依嚴格規則4不放真實案件內容）----
const PLACEHOLDER_CASE_TITLE := "占位：第1章 · 第一份委託"
const PLACEHOLDER_CASE_OBJECTIVES := ["占位案件目標 1", "占位案件目標 2"]
const PLACEHOLDER_BOTTOM_BAR_DEFAULT := "占位：系統提示語（目前請使用COUNTIF檢查狀態欄）"
const SIDEBAR_TAB_LABELS := ["證言", "物證", "名冊", "交易紀錄"]

# 公式提示清單：函數名稱跟簡述沿用0mockup/ui_style_guide_v0.1.md第7節
# 公開列出的範例，不是案件1的專屬內容；COUNTIF是這個v1原型唯一支援的
# 函數，其餘標示為尚未開放，呼應嚴格規則11「未支援公式要用偵探語氣
# 拉回主線」的精神——這裡先用視覺上的「未開放」呈現，公式列本身的提示
# 訊息見_evaluate_countif()。
const FORMULA_HINTS := [
	{"name": "COUNTIF", "desc": "計算符合條件的儲存格數量", "available": true},
	{"name": "SUMIFS", "desc": "依多重條件加總數值", "available": false},
	{"name": "XLOOKUP", "desc": "在範圍或陣列中查找對應值", "available": false},
	{"name": "LEFT", "desc": "擷取字串左側指定字元數", "available": false},
	{"name": "MID", "desc": "擷取字串中間指定字元數", "available": false},
	{"name": "DATE", "desc": "建立日期值", "available": false},
]

# 九宮格素材的texture_margin是「畫邊框留多少不拉伸角落」，但實際雕花
# 通常只占這個範圍的一部分，其餘是純背景。content_margin（決定子節點
# 內縮多少）用texture_margin的這個比例計算，讓內容區不用整段margin
# 都讓開，見_make_texture_style()。
const CONTENT_MARGIN_RATIO := 0.65  # 原本0.4太激進，文字會貼到邊框雕花上

# ---- 資產路徑（沿用Story Dialogue UI跟存讀檔零件已經做好的正式美術）----
const STORY_DIALOGUE_UI_DIR := "res://assets/ui/story_dialogue/"
const EXCEL_SOLVER_UI_DIR := "res://assets/ui/excel_solver/"
const TOP_BAR_BUTTON_KEYS := ["save", "load", "settings"]
const TOP_BAR_BUTTON_LABELS := {"save": "保存", "load": "讀取", "settings": "設定"}

# Mockup精準重建計畫第一批素材（頂部與左側），見assets/ui/excel_solver/readme.md。
const PANEL_TOP_BAR_MAIN := EXCEL_SOLVER_UI_DIR + "panel_top_bar_main.png"
const BADGE_TITLE_CALCULATOR := EXCEL_SOLVER_UI_DIR + "badge_title_calculator.png"
const PLATE_CHAPTER_LABEL := EXCEL_SOLVER_UI_DIR + "plate_chapter_label.png"
const PANEL_LEFT_SIDEBAR_MAIN := EXCEL_SOLVER_UI_DIR + "panel_left_sidebar_main.png"
const BUTTON_CATEGORY_BASE_NORMAL := EXCEL_SOLVER_UI_DIR + "button_category_base_normal.png"
const BUTTON_CATEGORY_BASE_HOVER := EXCEL_SOLVER_UI_DIR + "button_category_base_hover.png"
const BUTTON_CATEGORY_BASE_SELECTED := EXCEL_SOLVER_UI_DIR + "button_category_base_selected.png"
# 分類順序跟對應icon——四個分類目前只有一張資料表，icon純粹做視覺辨識，
# 不代表四個分類已經分別有獨立資料（見_build_left_sidebar()的範圍說明）。
const SIDEBAR_CATEGORY_ICONS := {
	"證言": EXCEL_SOLVER_UI_DIR + "icon_category_testimony.png",
	"物證": EXCEL_SOLVER_UI_DIR + "icon_category_evidence.png",
	"名冊": EXCEL_SOLVER_UI_DIR + "icon_category_roster.png",
	"交易紀錄": EXCEL_SOLVER_UI_DIR + "icon_category_transaction.png",
}

# Mockup精準重建計畫第二批素材（中央與右側）。跟第一批章節牌/分類按鈕
# 不同，這批四張面板的外框都是乾淨直角矩形、裝飾收在角落，已用Python
# 量測+九宮格試算圖確認可以安全延展，margin數值見下面版面數字區塊。
const PANEL_FORMULA_BAR_FRAME := EXCEL_SOLVER_UI_DIR + "panel_formula_bar_frame.png"
const PANEL_RIGHT_SIDEBAR_MAIN := EXCEL_SOLVER_UI_DIR + "panel_right_sidebar_main.png"
const PANEL_CASE_OBJECTIVE_BOX := EXCEL_SOLVER_UI_DIR + "panel_case_objective_box.png"
# panel_formula_hint_box.png原圖把計算機紋章畫在「頂部置中」，落在
# 九宮格會被水平拉伸的中段區域裡（不像角落雕花是固定不拉伸的），框一
# 變寬紋章就被拉扁。改成兩張圖：_frame_only是把紋章區域用同一張圖裡
# 乾淨的邊框樣本貼掉之後的純背景框（可以放心九宮格延展），紋章另外
# 裁成固定大小的badge，用獨立TextureRect疊在頂部，不會跟著框被拉伸。
const PANEL_FORMULA_HINT_BOX := EXCEL_SOLVER_UI_DIR + "panel_formula_hint_box_frame_only.png"
const BADGE_FORMULA_HINT_CALCULATOR := EXCEL_SOLVER_UI_DIR + "badge_formula_hint_calculator.png"
const OBJECTIVE_STATUS_ICONS := {
	"pending": EXCEL_SOLVER_UI_DIR + "icon_objective_pending.png",
	"active": EXCEL_SOLVER_UI_DIR + "icon_objective_active.png",
	"done": EXCEL_SOLVER_UI_DIR + "icon_objective_done.png",
}

# ---- 版面數字（統一管理，之後調整大小/間距只改這裡）----
# 所有格子（表頭/鎖住格/可編輯格/填補格）統一用這個高度，取代原本
# 散落在各個_make_xxx_cell()函式裡的「36」魔法數字。整體格子加大約
# 1.2倍（36->44），文字跟著放大才不會在變大的格子裡顯得鬆散。
const GRID_ROW_HEIGHT := 44
const FILL_HANDLE_SIZE = Vector2(10, 10)
# 補滿欄/補滿列：表格右邊、下面如果還有可視空間沒被A~J真實資料欄/列
# 填滿，就用這個預設寬度自動算出要再補幾欄純空白格子，對齊真實Excel
# 「資料範圍以外還是會繼續顯示空白格線」的行為，不是手動猜一個倍率
# 把欄寬硬撐大（後者在視窗大小改變或之後欄位調整時會立刻跟可用空間
# 對不上，每次都要重新手動量）。實際補幾欄/幾列在_build_grid()裡依
# 執行時量到的ScrollContainer實際大小計算，不是寫死的數字。
const DEFAULT_FILLER_COLUMN_WIDTH := 110
const PAGE_MARGIN = 20
const SECTION_SPACING = 12
const TITLE_FONT_SIZE = 24  # 原本20，頂部「數據計算儀」標題字級
const HINT_FONT_SIZE = 16
const RESULT_FONT_SIZE = 16  # 原本18，底部系統提示字級
const PLACEHOLDER_FONT_SIZE = 16
const HEADER_FONT_SIZE = 20
const CELL_FONT_SIZE = 20
const SELECTION_INFO_FONT_SIZE = 14  # 原本15，底部「目前選取」字級
const SIDEBAR_TITLE_FONT_SIZE = 23  # 原本17，加大「案件資料」標題字級
const SIDEBAR_TAB_FONT_SIZE = 18
const OBJECTIVE_FONT_SIZE = 18  # 原本16，案件目標項目文字字級
const FORMULA_HINT_NAME_FONT_SIZE = 18  # 原本17，公式提示函數名稱字級
const FORMULA_HINT_DESC_FONT_SIZE = 16  # 原本13，公式提示說明文字字級
const LOCKED_BORDER_WIDTH = 1
const EDITABLE_BORDER_WIDTH = 2
const TOP_BAR_HEIGHT = 88
const BOTTOM_BAR_HEIGHT = 56
# 以下是今天Mockup精準重建時新增、原本直接寫死在各_build_xxx()函式裡
# 的版面數字，統一搬到這裡集中管理（嚴格規則7：版面數字禁止散落）。
const TOP_BAR_FRAME_MARGIN_H := 110.0
const TOP_BAR_FRAME_MARGIN_V := 36.0
const CHAPTER_LABEL_FONT_SIZE := 18
const TITLE_BADGE_SIZE := Vector2(44, 44)
const TOP_BAR_TITLE_GAP := 10.0
const TOP_BAR_INNER_MARGIN := PAGE_MARGIN
const BOTTOM_BAR_CONTENT_MARGIN := 30.0
const SIDEBAR_TITLE_HEIGHT := 50.0
const DIVIDER_LINE_HEIGHT := 1.0
const FORMULA_BOX_INNER_MARGIN := 16.0
const FORMULA_BOX_FONT_SIZE := 18
const FX_LABEL_WIDTH := 48.0
const RIGHT_SIDEBAR_OUTER_MARGIN_H := 10.0
const RIGHT_SIDEBAR_OUTER_MARGIN_V := 16.0
const SIDEBAR_CARD_INNER_MARGIN := 16.0
const SIDEBAR_CARD_TITLE_FONT_SIZE := 22
const HINT_ITEM_SPACING := 10.0
const LEFT_SIDEBAR_WIDTH = 300  # 原本230，加大讓分類按鈕（寬高依此反推）更舒展、不會看起來太瘦小
# 原本270->320都還是太窄：右側主框邊框自己吃掉RIGHT_SIDEBAR_TEXTURE_
# MARGIN_H*2=110px，案件目標/公式提示卡片框邊框又各吃掉CASE_OBJECTIVE_
# BOX_MARGIN_H*2=80px，兩層邊框疊加後，320寬的面板真正能放文字的空間
# 不到50px。加大到440，扣掉兩層邊框後內部還能留出合理的文字寬度。
const RIGHT_SIDEBAR_WIDTH = 440
const TOP_BAR_BUTTON_SIZE := Vector2(230, 85)  # 原本190×70，再加大
const SIDEBAR_TAB_SIZE := Vector2(190, 56)

# 章節牌（plate_chapter_label.png）跟分類按鈕一樣是斜切角造型，沒有乾淨
# 直線可以九宮格延展，用texture_margin硬切會變形（見CATEGORY_BUTTON_
# TEXTURE_ASPECT註解的同一個教訓）。改成整張等比例縮放：寬度先選一個
# 能放下「第X章：標題文字」的舒適值，高度依素材量到的寬高比（1015/149
# ≈6.81）反推，不拉伸不裁切。
const CHAPTER_PLATE_TEXTURE_ASPECT := 1015.0 / 149.0
const CHAPTER_PLATE_WIDTH := 380.0
const CHAPTER_PLATE_HEIGHT := CHAPTER_PLATE_WIDTH / CHAPTER_PLATE_TEXTURE_ASPECT

# 左側分類按鈕（Mockup精準重建計畫第一批素材：button_category_base_*.png）：
# 這張素材的外框是斜切角/圓角造型，沒有一段乾淨筆直的邊可以當九宮格
# 「不拉伸的邊角」，用texture_margin硬切只會把雕花線條切歪、重複——
# 已實測過90/130/160等margin組合，三態都會變形。改成不做九宮格，整張
# 圖依素材原始寬高比等比例縮放，不拉伸不裁切，三態切換只是換一張完整
# 的圖，本來就不會跳動或變形。
# CATEGORY_BUTTON_TEXTURE_ASPECT：量測三態素材核心圖案bbox（943×189、
# 903×191、925×197）取平均算出的寬高比，width由左側面板實際可用寬度
# 反推，height再依寬高比算出，避免再次憑感覺硬寫死高度數字。
const SIDEBAR_PANEL_TEXTURE_MARGIN_H := 24.0
const SIDEBAR_PANEL_TEXTURE_MARGIN_V := 60.0
const CATEGORY_BUTTON_TEXTURE_ASPECT := 4.8
# 子節點實際可用寬度現在是看content_margin（texture_margin*CONTENT_
# MARGIN_RATIO），不是整段texture_margin——這裡要用同一個算法，不然
# 按鈕底圖會比容器寬度算少，蓋到面板右邊框。CATEGORY_BUTTON_RIGHT_GAP
# 是額外留的緩衝，確保按鈕跟邊框之間留一點呼吸空間。
const CATEGORY_BUTTON_RIGHT_GAP := 16.0
const CATEGORY_BUTTON_WIDTH := LEFT_SIDEBAR_WIDTH - (SIDEBAR_PANEL_TEXTURE_MARGIN_H * CONTENT_MARGIN_RATIO) * 2 - CATEGORY_BUTTON_RIGHT_GAP
# 底圖本身的「不變形」高度（寬度/寬高比算出來的），STRETCH_KEEP_ASPECT_CENTERED
# 會照這個高度畫底圖、不會因為按鈕容器更高而被拉伸；CATEGORY_BUTTON_HEIGHT
# 才是按鈕容器實際的高度，多出來的CATEGORY_BUTTON_EXTRA_HEIGHT只是讓
# 底圖在按鈕裡置中時上下多留一點空間，按鈕變高但寬度跟底圖大小都不變。
const CATEGORY_BUTTON_BG_NATURAL_HEIGHT := CATEGORY_BUTTON_WIDTH / CATEGORY_BUTTON_TEXTURE_ASPECT
const CATEGORY_BUTTON_EXTRA_HEIGHT := 26.0
const CATEGORY_BUTTON_HEIGHT := CATEGORY_BUTTON_BG_NATURAL_HEIGHT + CATEGORY_BUTTON_EXTRA_HEIGHT
const CATEGORY_BUTTON_ICON_SIZE := Vector2(26, 26)  # 原本20×20，稍微加大
const SIDEBAR_VBOX_SPACING := 14.0  # 標題/分隔線/4個分類按鈕之間的垂直間距，避免按鈕黏在一起

# Mockup精準重建計畫第二批素材（公式列外框/右側主框/案件目標框/公式
# 提示框）：跟第一批不同，這4張都是乾淨的直角矩形、裝飾收在角落，已用
# Python量測「哪個範圍是裝飾、哪個範圍是純色可拉伸」並產生九宮格試算圖
# 確認無變形，才把下面的margin數字寫進來——不是憑感覺猜的。
const FORMULA_BAR_FRAME_MARGIN_H := 55.0
const FORMULA_BAR_FRAME_MARGIN_V := 35.0
const RIGHT_SIDEBAR_TEXTURE_MARGIN_H := 55.0
const RIGHT_SIDEBAR_TEXTURE_MARGIN_V := 70.0
const CASE_OBJECTIVE_BOX_MARGIN_H := 40.0
const CASE_OBJECTIVE_BOX_MARGIN_V := 50.0
# 紋章已經挖出來變成獨立badge（見BADGE_FORMULA_HINT_CALCULATOR），
# 框本身（panel_formula_hint_box_frame_only.png）現在跟案件目標框一樣
# 是乾淨邊框，margin直接沿用同一組數值即可。
const FORMULA_HINT_BOX_MARGIN_H := CASE_OBJECTIVE_BOX_MARGIN_H
const FORMULA_HINT_BOX_MARGIN_V := CASE_OBJECTIVE_BOX_MARGIN_V
const OBJECTIVE_STATUS_ICON_SIZE := Vector2(18, 18)
const FORMULA_HINT_BADGE_SIZE := Vector2(160, 70)  # 計算機紋章badge的固定顯示大小，不隨框寬度縮放

# 表格每一欄的固定寬度（像素），取代「依文字內容自動決定欄寬」——
# GridContainer若用SIZE_EXPAND_FILL+min_size.x=0，欄寬會依該欄最長的
# 文字內容跑來跑去（例如「輸入公式」比「T1」寬），造成參差不齊。明確
# 寫死每欄寬度後，表格寬度=各欄總和，不隨內容變動，也不會無限被撐開。
# 這是每欄「內容需要多寬」的自然寬度，跟畫面可用空間多大無關——可用
# 空間沒被佔滿的部分，由_build_grid()自動補空白欄/空白列填滿（見上面
# DEFAULT_FILLER_COLUMN_WIDTH的說明），不是把這裡的數字硬改大去湊滿。
#
# I欄（COL_SPACER）是A~H表一跟J表二之間刻意留的空白欄，但寬度跟其他
# 欄一致、一樣可被選取/拖曳——不像舊版做成特別瘦的30px間隔欄，那樣
# 在統一可選取的格線網格裡看起來像是漏畫了一格，跟真實Excel「中間空
# 一欄但格子大小不變」的視覺習慣不符。
# 整體加大約1.2倍（配合GRID_ROW_HEIGHT/CELL_FONT_SIZE一起放大），讓
# 格子比v1原型寬鬆一些，閱讀文字/打公式更舒服。
const ROW_HEADER_WIDTH := 48
const COLUMN_WIDTHS := {
	"A": 85, "B": 110, "C": 130, "D": 95, "E": 130,
	"F": 130, "G": 200, "H": 130, "I": 110, "J": 85,
}

# ---- 配色（沿用02_story_dialogue_ui_demo.gd已定案的色票常數值，
# 避免兩個零件各自猜一套「差不多」的深綠/銀色，造成視覺不一致）----
const COLOR_DEEP_CHARCOAL_DIM = Color(0.04, 0.09, 0.08)     # 整體背景，比面板底色再深一階
const COLOR_TEXT_MAIN := "#f0eadb"
const COLOR_TEXT_BRIGHT := "#f7f1e4"
const COLOR_TEXT_MUTED := "#c9c2ae"
const COLOR_TEXT_WHITE := "#ffffff"
const COLOR_ACCENT_GREEN := "#bde8cc"
const COLOR_LINE_SILVER := "#c9d3c6aa"
const COLOR_LINE_GOLD := "#b8a06d9a"
const COLOR_PANEL_HEADER := "#10231fcc"
const COLOR_SHADOW_SOFT := "#000000a8"

const COLOR_HEADER_BG = Color(0.92, 0.90, 0.86)
const COLOR_HEADER_TEXT = Color(0.1, 0.15, 0.13)
const COLOR_HEADER_SELECTED_BG = Color(0.8, 0.85, 0.8)
const COLOR_LOCKED_BG = Color(0.08, 0.12, 0.10)
const COLOR_LOCKED_BORDER = Color(COLOR_LINE_SILVER)
const COLOR_LOCKED_TEXT = Color(COLOR_TEXT_MAIN)
const COLOR_SPACER_BG = Color(0.08, 0.12, 0.10)
const COLOR_EDITABLE_BG = Color(0.10, 0.16, 0.13)
const COLOR_EDITABLE_BORDER = Color(COLOR_ACCENT_GREEN)
const COLOR_EDITABLE_TEXT = Color(COLOR_TEXT_BRIGHT)
const COLOR_EDITABLE_CARET = Color(COLOR_TEXT_BRIGHT)
const COLOR_EDITABLE_HIGHLIGHT_BG = Color(0.15, 0.30, 0.22)
const COLOR_SELECTION_HIGHLIGHT_BG = Color(0.12, 0.25, 0.18)
const COLOR_FILL_HANDLE = Color(COLOR_ACCENT_GREEN)

func _apply_label_style(lbl: Label, size: int, color_hex: String) -> void:
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", Color(color_hex))
	var font = load("res://assets/fonts/NotoSerifTC[wght].ttf")
	if font: lbl.add_theme_font_override("font", font)

# margin為單一數字時四邊一致；要做長條形九宮格延展（頂部列/章節牌這種
# 兩側裝飾窄、中段要拉很長的素材）時，margin_horizontal/margin_vertical
# 可以分開指定，不然四邊等寬會把兩側雕花一起拉變形。margin_top/
# margin_bottom再進一步覆寫上下邊（例如公式提示框上方有紋章裝飾，
# 比下邊框占用更高的範圍，上下邊距需要不一樣）。
func _make_texture_style(tex: Texture2D, margin: float = 0.0, margin_horizontal: float = -1.0, margin_vertical: float = -1.0, margin_top: float = -1.0, margin_bottom: float = -1.0) -> StyleBoxTexture:
	var sb = StyleBoxTexture.new()
	sb.texture = tex
	var h_margin = margin_horizontal if margin_horizontal >= 0.0 else margin
	var v_margin = margin_vertical if margin_vertical >= 0.0 else margin
	if h_margin > 0.0:
		sb.texture_margin_left = h_margin
		sb.texture_margin_right = h_margin
	if v_margin > 0.0:
		sb.texture_margin_top = v_margin
		sb.texture_margin_bottom = v_margin
	if margin_top >= 0.0:
		sb.texture_margin_top = margin_top
	if margin_bottom >= 0.0:
		sb.texture_margin_bottom = margin_bottom

	# texture_margin同時決定了「九宮格畫邊框留多少不拉伸的角落」跟
	# 「PanelContainer要讓開多少空間給子節點」這兩件事，但其實邊框的
	# 雕花通常只佔texture_margin範圍的一部分，剩下是純背景。把
	# content_margin明確設成比texture_margin小一點，讓子節點（文字/
	# icon）可以往外多用一些空間，不用整段margin都讓開，視覺上邊框
	# 還是照原樣畫，只是裡面內容區變寬了。
	sb.content_margin_left = sb.texture_margin_left * CONTENT_MARGIN_RATIO
	sb.content_margin_right = sb.texture_margin_right * CONTENT_MARGIN_RATIO
	sb.content_margin_top = sb.texture_margin_top * CONTENT_MARGIN_RATIO
	sb.content_margin_bottom = sb.texture_margin_bottom * CONTENT_MARGIN_RATIO
	return sb


# 執行期狀態（會在_ready()建構畫面時被指定，不是寫死的資料）
var cell_value_lookup: Dictionary = {}          # "A2" -> "T1"，鎖住格子的實際值
var editable_cells: Dictionary = {}             # "G2" -> LineEdit節點
var fill_handle_nodes: Dictionary = {}          # "G2" -> 拖拉填滿手把節點
var status_cell_by_row: Dictionary = {}         # row(int) -> COL_STATUS那一格的LineEdit節點
var row_formulas: Dictionary = {}               # "G2" -> 玩家打的公式原文
var all_cell_nodes: Dictionary = {}             # 所有格子（鎖住+可編輯）："A2" -> LineEdit節點
var cell_base_bg: Dictionary = {}               # 每個格子未被選取時的底色，用於還原
var col_header_nodes: Dictionary = {}           # 欄名 -> 表頭節點（點擊可選整欄）
var row_header_nodes: Dictionary = {}           # 列號(int) -> 表頭節點（點擊可選整列）
var active_cell_id: String = ""
var result_label: Label
var selection_info_label: Label
var sidebar_tab_buttons: Array = []
var sidebar_tab_backgrounds: Array = []         # 跟sidebar_tab_buttons一一對應的背景TextureRect，整張圖換貼圖、不做九宮格
var sidebar_tab_labels: Array = []              # 跟sidebar_tab_buttons一一對應的文字Label，選取狀態改這裡的顏色
var sidebar_selected_tab_index: int = 0
var category_button_texture_normal: Texture2D
var category_button_texture_hover: Texture2D
var category_button_texture_selected: Texture2D
var grid_scroll_container: ScrollContainer  # 表格外層的捲動容器，量它實際大小來算要補幾欄/幾列空白格

# 拖拉填滿狀態
var is_filling: bool = false
var fill_source_row: int = -1
var fill_current_target_row: int = -1

# 矩形範圍選取狀態（點欄名/列號全選，或拖曳選取多格）
var is_selecting: bool = false
var selection_anchor_col_index: int = -1
var selection_anchor_row: int = -1
var selection_current_col_index: int = -1
var selection_current_row: int = -1
var selected_cell_ids: Array = []


# ------------------------------------------------------------
# 2. 畫面建構
# ------------------------------------------------------------
func _ready() -> void:
	cell_value_lookup.clear()
	editable_cells.clear()
	fill_handle_nodes.clear()
	status_cell_by_row.clear()
	row_formulas.clear()
	all_cell_nodes.clear()
	cell_base_bg.clear()
	col_header_nodes.clear()
	row_header_nodes.clear()
	add_child(load("res://05_ui_tweaker_tool.tscn").instantiate())

	var bg = ColorRect.new()
	bg.color = Color(COLOR_LOCKED_BG)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root_vbox = VBoxContainer.new()
	root_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_vbox.add_theme_constant_override("separation", 0)
	add_child(root_vbox)

	root_vbox.add_child(_build_top_bar())

	var body_hbox = HBoxContainer.new()
	body_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_hbox.add_theme_constant_override("separation", 0)
	root_vbox.add_child(body_hbox)

	body_hbox.add_child(_build_left_sidebar())
	body_hbox.add_child(_build_center_area())
	body_hbox.add_child(_build_right_sidebar())

	var bottom_panel = PanelContainer.new()
	bottom_panel.custom_minimum_size = Vector2(0, BOTTOM_BAR_HEIGHT)
	bottom_panel.add_theme_stylebox_override("panel", _make_border_stylebox(Color(COLOR_PANEL_HEADER), Color(COLOR_LINE_SILVER), 1))

	var bottom_hbox = HBoxContainer.new()
	bottom_hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	result_label = Label.new()
	result_label.name = "ResultLabel"
	result_label.text = "目前請使用 COUNTIF 檢查證言狀態。"
	_apply_label_style(result_label, RESULT_FONT_SIZE, COLOR_TEXT_MAIN)
	bottom_hbox.add_child(result_label)

	selection_info_label = Label.new()
	selection_info_label.name = "SelectionInfoLabel"
	selection_info_label.text = "  |  目前選取：（無）"
	_apply_label_style(selection_info_label, SELECTION_INFO_FONT_SIZE, COLOR_TEXT_MUTED)
	bottom_hbox.add_child(selection_info_label)

	var bottom_margin = MarginContainer.new()
	bottom_margin.add_theme_constant_override("margin_left", BOTTOM_BAR_CONTENT_MARGIN)
	bottom_margin.add_child(bottom_hbox)
	bottom_panel.add_child(bottom_margin)
	root_vbox.add_child(bottom_panel)

	# 表格要等整個畫面排版完成、grid_scroll_container量得到真實大小後才能建，
	# 否則算不出右邊/下面還有多少可視空間需要補空白欄/空白列。
	await get_tree().process_frame
	await get_tree().process_frame
	grid_scroll_container.add_child(_build_grid())

func _build_top_bar() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, TOP_BAR_HEIGHT)
	var top_bar_texture = load(PANEL_TOP_BAR_MAIN)
	panel.add_theme_stylebox_override("panel", _make_texture_style(top_bar_texture, 0.0, TOP_BAR_FRAME_MARGIN_H, TOP_BAR_FRAME_MARGIN_V))

	var hbox = HBoxContainer.new()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", TOP_BAR_INNER_MARGIN)
	margin.add_theme_constant_override("margin_right", TOP_BAR_INNER_MARGIN)
	margin.add_child(hbox)
	panel.add_child(margin)

	var badge = TextureRect.new()
	badge.texture = load(BADGE_TITLE_CALCULATOR)
	badge.custom_minimum_size = TITLE_BADGE_SIZE
	badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	badge.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	hbox.add_child(badge)

	var title_gap = Control.new()
	title_gap.custom_minimum_size = Vector2(TOP_BAR_TITLE_GAP, 0)
	hbox.add_child(title_gap)

	var title = Label.new()
	title.text = "數據計算儀"
	_apply_label_style(title, TITLE_FONT_SIZE, COLOR_TEXT_BRIGHT)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(title)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# 章節牌跟分類按鈕一樣是斜切角造型，沒有乾淨直線可以九宮格延展，
	# 改成跟分類按鈕同一套做法：TextureRect整張等比例縮放當背景，
	# Label疊在上面，不靠StyleBoxTexture margin切割（會變形）。
	var chapter_root = Control.new()
	chapter_root.custom_minimum_size = Vector2(CHAPTER_PLATE_WIDTH, CHAPTER_PLATE_HEIGHT)

	var chapter_bg = TextureRect.new()
	chapter_bg.texture = load(PLATE_CHAPTER_LABEL)
	chapter_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chapter_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chapter_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chapter_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	chapter_root.add_child(chapter_bg)

	var subtitle = Label.new()
	subtitle.text = "第1章：第一份委託"
	_apply_label_style(subtitle, CHAPTER_LABEL_FONT_SIZE, COLOR_TEXT_MUTED)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.set_anchors_preset(Control.PRESET_FULL_RECT)
	chapter_root.add_child(subtitle)
	hbox.add_child(chapter_root)

	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer2)
	
	var btn_save = TextureButton.new()
	btn_save.texture_normal = load("res://assets/ui/story_dialogue/button_top_save_normal.png")
	btn_save.texture_hover = load("res://assets/ui/story_dialogue/button_top_save_hover.png")
	btn_save.texture_pressed = load("res://assets/ui/story_dialogue/button_top_save_pressed.png")
	btn_save.ignore_texture_size = true
	btn_save.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn_save.custom_minimum_size = TOP_BAR_BUTTON_SIZE
	btn_save.pressed.connect(func(): if self.has_method("_on_top_bar_button_pressed"): _on_top_bar_button_pressed("save"))
	hbox.add_child(btn_save)
	
	var btn_load = TextureButton.new()
	btn_load.texture_normal = load("res://assets/ui/story_dialogue/button_top_load_normal.png")
	btn_load.texture_hover = load("res://assets/ui/story_dialogue/button_top_load_hover.png")
	btn_load.texture_pressed = load("res://assets/ui/story_dialogue/button_top_load_pressed.png")
	btn_load.ignore_texture_size = true
	btn_load.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn_load.custom_minimum_size = TOP_BAR_BUTTON_SIZE
	btn_load.pressed.connect(func(): if self.has_method("_on_top_bar_button_pressed"): _on_top_bar_button_pressed("load"))
	hbox.add_child(btn_load)
	
	var btn_settings = TextureButton.new()
	btn_settings.texture_normal = load("res://assets/ui/story_dialogue/button_top_settings_normal.png")
	btn_settings.texture_hover = load("res://assets/ui/story_dialogue/button_top_settings_hover.png")
	btn_settings.texture_pressed = load("res://assets/ui/story_dialogue/button_top_settings_pressed.png")
	btn_settings.ignore_texture_size = true
	btn_settings.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn_settings.custom_minimum_size = TOP_BAR_BUTTON_SIZE
	btn_settings.pressed.connect(func(): if self.has_method("_on_top_bar_button_pressed"): _on_top_bar_button_pressed("settings"))
	hbox.add_child(btn_settings)

	return panel

# 範圍說明：目前只有一張資料表（COUNTIF測試資料），四個分類按鈕只做
# 外觀＋視覺選取狀態，不切換真的資料——之後有多張表時再接上真實切換。
func _build_left_sidebar() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(LEFT_SIDEBAR_WIDTH, 0)
	var sidebar_texture = load(PANEL_LEFT_SIDEBAR_MAIN)
	panel.add_theme_stylebox_override("panel", _make_texture_style(sidebar_texture, 0.0, SIDEBAR_PANEL_TEXTURE_MARGIN_H, SIDEBAR_PANEL_TEXTURE_MARGIN_V))

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", SIDEBAR_VBOX_SPACING)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "案件資料"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(0, SIDEBAR_TITLE_HEIGHT)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_apply_label_style(title, SIDEBAR_TITLE_FONT_SIZE, COLOR_TEXT_BRIGHT)
	vbox.add_child(title)

	var line = ColorRect.new()
	line.custom_minimum_size = Vector2(0, DIVIDER_LINE_HEIGHT)
	line.color = Color(COLOR_LINE_SILVER)
	vbox.add_child(line)

	# 分類按鈕共用三態底圖（Mockup精準重建計畫第一批素材），不再用4×3張
	# 獨立圖；只換底圖+疊icon+Godot Label文字，呼應「能用共用底板表達的
	# 狀態不做獨立圖片」的素材製作原則。素材外框是斜切角造型，不適合九宮格
	# （見CATEGORY_BUTTON_TEXTURE_ASPECT上方註解），改成TextureRect整張
	# 等比例縮放、三態之間直接換貼圖，不靠StyleBoxTexture margin切割。
	category_button_texture_normal = load(BUTTON_CATEGORY_BASE_NORMAL)
	category_button_texture_hover = load(BUTTON_CATEGORY_BASE_HOVER)
	category_button_texture_selected = load(BUTTON_CATEGORY_BASE_SELECTED)
	sidebar_tab_buttons.clear()
	sidebar_tab_backgrounds.clear()
	sidebar_tab_labels.clear()

	var categories = ["證言", "物證", "名冊", "交易紀錄"]
	for i in range(categories.size()):
		var cat = categories[i]

		var tab_root = Control.new()
		tab_root.custom_minimum_size = Vector2(0, CATEGORY_BUTTON_HEIGHT)

		# 之前直接把bg_rect設成FULL_RECT塞滿tab_root，但tab_root的實際寬度
		# 是跟著vbox走的（vbox多寬，tab_root就多寬），跟CATEGORY_BUTTON_
		# WIDTH這個「設計上想要的底圖寬度」是兩件不相關的事——
		# STRETCH_KEEP_ASPECT_CENTERED只負責「保持比例」，不負責「不要
		# 超過某個寬度」，所以底圖還是會被撐到塞滿容器、貼到面板邊框。
		# 改成用CenterContainer包住，底圖用custom_minimum_size指定固定
		# 大小，不管tab_root本身多寬，底圖都維持CATEGORY_BUTTON_WIDTH，
		# 置中顯示，自然跟邊框保持距離。
		var bg_center = CenterContainer.new()
		bg_center.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tab_root.add_child(bg_center)

		var bg_rect = TextureRect.new()
		bg_rect.texture = category_button_texture_selected if i == 0 else category_button_texture_normal
		bg_rect.custom_minimum_size = Vector2(CATEGORY_BUTTON_WIDTH, CATEGORY_BUTTON_BG_NATURAL_HEIGHT)
		bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg_center.add_child(bg_rect)
		sidebar_tab_backgrounds.append(bg_rect)

		# icon+文字不用Button內建的icon屬性——Godot的Button.icon預設永遠
		# 貼在按鈕最左邊，不受alignment影響，跟按鈕邊框雕花疊在一起、
		# 很難看清楚。改成自己用一個置中的HBoxContainer疊icon+Label，
		# Button只負責透明的點擊/hover偵測層，不顯示任何文字/圖示。
		var content_hbox = HBoxContainer.new()
		content_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		content_hbox.add_theme_constant_override("separation", 10)
		content_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		tab_root.add_child(content_hbox)

		var icon_rect = TextureRect.new()
		icon_rect.texture = load(SIDEBAR_CATEGORY_ICONS[cat])
		icon_rect.custom_minimum_size = CATEGORY_BUTTON_ICON_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		content_hbox.add_child(icon_rect)

		var label = Label.new()
		label.text = cat
		var clr = COLOR_ACCENT_GREEN if i == 0 else COLOR_TEXT_MAIN
		_apply_label_style(label, SIDEBAR_TAB_FONT_SIZE, clr)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		content_hbox.add_child(label)
		sidebar_tab_labels.append(label)

		var btn = Button.new()
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		btn.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		btn.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

		btn.mouse_entered.connect(_on_sidebar_tab_mouse_entered.bind(i))
		btn.mouse_exited.connect(_on_sidebar_tab_mouse_exited.bind(i))
		btn.pressed.connect(func(): if self.has_method("_on_sidebar_tab_pressed"): _on_sidebar_tab_pressed(i))
		tab_root.add_child(btn)

		vbox.add_child(tab_root)
		sidebar_tab_buttons.append(btn)

	return panel

func _build_center_area() -> Control:
	var center_vbox = VBoxContainer.new()
	center_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_vbox.add_theme_constant_override("separation", PAGE_MARGIN)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", PAGE_MARGIN)
	margin.add_theme_constant_override("margin_top", PAGE_MARGIN)
	margin.add_theme_constant_override("margin_right", PAGE_MARGIN)
	margin.add_theme_constant_override("margin_bottom", PAGE_MARGIN)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(center_vbox)

	var outer = MarginContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(margin)

	# 公式列外框（Mockup精準重建計畫第二批素材）：整條fx輸入列包進這個
	# 框裡，取代原本formula_input自己畫一層淺色細框的暫時做法。
	var formula_panel = PanelContainer.new()
	var formula_frame_texture = load(PANEL_FORMULA_BAR_FRAME)
	formula_panel.add_theme_stylebox_override("panel", _make_texture_style(formula_frame_texture, 0.0, FORMULA_BAR_FRAME_MARGIN_H, FORMULA_BAR_FRAME_MARGIN_V))
	center_vbox.add_child(formula_panel)

	var formula_margin = MarginContainer.new()
	formula_margin.add_theme_constant_override("margin_left", FORMULA_BOX_INNER_MARGIN)
	formula_margin.add_theme_constant_override("margin_right", FORMULA_BOX_INNER_MARGIN)
	formula_panel.add_child(formula_margin)

	var formula_box = HBoxContainer.new()
	formula_margin.add_child(formula_box)

	var fx_label = Label.new()
	fx_label.text = "公式"
	_apply_label_style(fx_label, FORMULA_BOX_FONT_SIZE, COLOR_TEXT_MAIN)
	fx_label.custom_minimum_size = Vector2(FX_LABEL_WIDTH, 0)
	fx_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	formula_box.add_child(fx_label)

	var formula_input = LineEdit.new()
	formula_input.placeholder_text = "=COUNTIF(...)"
	formula_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	formula_input.name = "FormulaInput"
	formula_input.add_theme_font_size_override("font_size", FORMULA_BOX_FONT_SIZE)
	formula_input.add_theme_color_override("font_color", Color(COLOR_TEXT_BRIGHT))
	formula_input.add_theme_color_override("caret_color", Color(COLOR_TEXT_BRIGHT))
	# 外面已經有公式列外框畫邊線了，這裡不再疊一層淺色細框，只用透明
	# 背景讓文字直接顯示在外框的深綠內裡上。
	formula_input.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	formula_input.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	formula_input.text_submitted.connect(_on_formula_bar_submitted)
	formula_box.add_child(formula_input)

	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_vbox.add_child(scroll)

	# 依0mockup/excel_solver_ui_mockup.png：表格從fx公式列正下方開始，
	# 左上對齊、貼著左右可用空間撐滿，不是置中放在一大塊空白正中間。
	# 舊版用CenterContainer水平+垂直置中，固定尺寸的表格遠小於可用
	# 空間，造成上下左右都出現大片留白（跟mockup不符）。
	#
	# 這裡先不馬上塞表格進去：_build_grid()需要量到scroll實際的可用
	# 寬高才能算出要補幾欄/幾列空白格，但scroll剛建出來時還沒有經過
	# 排版，size量到的會是錯的。改成只記住這個ScrollContainer，等
	# _ready()最後等畫面排版完成後再建表格、塞進來（見_ready()結尾）。
	grid_scroll_container = scroll

	return outer

func _on_top_bar_button_pressed(key: String) -> void:
	if self.has_method("_show_message"):
		_show_message("尚未實裝功能: " + key)

func _on_sidebar_tab_pressed(tab_index: int) -> void:
	_select_sidebar_tab(tab_index)

func _select_sidebar_tab(tab_index: int) -> void:
	sidebar_selected_tab_index = tab_index
	for i in range(sidebar_tab_buttons.size()):
		var label: Label = sidebar_tab_labels[i]
		var bg_rect: TextureRect = sidebar_tab_backgrounds[i]
		if i == tab_index:
			label.add_theme_color_override("font_color", Color(COLOR_ACCENT_GREEN))
			bg_rect.texture = category_button_texture_selected
		else:
			label.add_theme_color_override("font_color", Color(COLOR_TEXT_MAIN))
			bg_rect.texture = category_button_texture_normal


# 滑鼠移到非選取中的分類按鈕時換成hover貼圖；目前選取的分類維持selected
# 貼圖不被hover蓋掉，讓玩家清楚知道「現在在哪一頁」跟「滑鼠移到哪一個」
# 是兩件事，不會搞混。
func _on_sidebar_tab_mouse_entered(tab_index: int) -> void:
	if tab_index == sidebar_selected_tab_index:
		return
	sidebar_tab_backgrounds[tab_index].texture = category_button_texture_hover


func _on_sidebar_tab_mouse_exited(tab_index: int) -> void:
	if tab_index == sidebar_selected_tab_index:
		return
	sidebar_tab_backgrounds[tab_index].texture = category_button_texture_normal

# 建一個小icon+文字的橫排，取代原本拿◇／◆文字符號當案件目標狀態
# 標記的暫時做法。status對應OBJECTIVE_STATUS_ICONS的key（pending/
# active/done）。
func _build_objective_row(text: String, status: String, text_color: String) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var icon = TextureRect.new()
	icon.texture = load(OBJECTIVE_STATUS_ICONS[status])
	icon.custom_minimum_size = OBJECTIVE_STATUS_ICON_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	row.add_child(icon)

	var label = Label.new()
	label.text = text
	_apply_label_style(label, OBJECTIVE_FONT_SIZE, text_color)
	row.add_child(label)

	return row


func _build_right_sidebar() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(RIGHT_SIDEBAR_WIDTH, 0)
	var sidebar_texture = load(PANEL_RIGHT_SIDEBAR_MAIN)
	panel.add_theme_stylebox_override("panel", _make_texture_style(sidebar_texture, 0.0, RIGHT_SIDEBAR_TEXTURE_MARGIN_H, RIGHT_SIDEBAR_TEXTURE_MARGIN_V))

	# 內距縮小一點（原本20px），案件目標/公式提示卡片框才能更貼近外層
	# 主框的寬度，不會看起來小一圈。
	var outer_margin = MarginContainer.new()
	outer_margin.add_theme_constant_override("margin_left", RIGHT_SIDEBAR_OUTER_MARGIN_H)
	outer_margin.add_theme_constant_override("margin_top", RIGHT_SIDEBAR_OUTER_MARGIN_V)
	outer_margin.add_theme_constant_override("margin_right", RIGHT_SIDEBAR_OUTER_MARGIN_H)
	outer_margin.add_theme_constant_override("margin_bottom", RIGHT_SIDEBAR_OUTER_MARGIN_V)
	panel.add_child(outer_margin)

	var outer_vbox = VBoxContainer.new()
	outer_vbox.add_theme_constant_override("separation", PAGE_MARGIN)
	outer_margin.add_child(outer_vbox)

	# ---- 案件目標框 ----
	var objective_panel = PanelContainer.new()
	objective_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var objective_texture = load(PANEL_CASE_OBJECTIVE_BOX)
	objective_panel.add_theme_stylebox_override("panel", _make_texture_style(objective_texture, 0.0, CASE_OBJECTIVE_BOX_MARGIN_H, CASE_OBJECTIVE_BOX_MARGIN_V))
	outer_vbox.add_child(objective_panel)

	var objective_margin = MarginContainer.new()
	objective_margin.add_theme_constant_override("margin_left", SIDEBAR_CARD_INNER_MARGIN)
	objective_margin.add_theme_constant_override("margin_top", SIDEBAR_CARD_INNER_MARGIN)
	objective_margin.add_theme_constant_override("margin_right", SIDEBAR_CARD_INNER_MARGIN)
	objective_margin.add_theme_constant_override("margin_bottom", SIDEBAR_CARD_INNER_MARGIN)
	objective_panel.add_child(objective_margin)

	var objective_vbox = VBoxContainer.new()
	objective_vbox.add_theme_constant_override("separation", HINT_ITEM_SPACING)
	objective_margin.add_child(objective_vbox)

	var title_obj = Label.new()
	title_obj.text = "案件目標"
	_apply_label_style(title_obj, SIDEBAR_CARD_TITLE_FONT_SIZE, COLOR_TEXT_BRIGHT)
	objective_vbox.add_child(title_obj)

	objective_vbox.add_child(_build_objective_row("找出證言矛盾", "pending", COLOR_TEXT_MAIN))
	objective_vbox.add_child(_build_objective_row("統計不在場人數", "active", COLOR_ACCENT_GREEN))
	objective_vbox.add_child(_build_objective_row("比對交易紀錄", "pending", COLOR_TEXT_MAIN))

	# ---- 公式提示框 ----
	var hint_panel = PanelContainer.new()
	hint_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var hint_texture = load(PANEL_FORMULA_HINT_BOX)
	hint_panel.add_theme_stylebox_override("panel", _make_texture_style(hint_texture, 0.0, FORMULA_HINT_BOX_MARGIN_H, FORMULA_HINT_BOX_MARGIN_V))
	outer_vbox.add_child(hint_panel)

	var hint_margin = MarginContainer.new()
	hint_margin.add_theme_constant_override("margin_left", SIDEBAR_CARD_INNER_MARGIN)
	hint_margin.add_theme_constant_override("margin_top", SIDEBAR_CARD_INNER_MARGIN)
	hint_margin.add_theme_constant_override("margin_right", SIDEBAR_CARD_INNER_MARGIN)
	hint_margin.add_theme_constant_override("margin_bottom", SIDEBAR_CARD_INNER_MARGIN)
	hint_panel.add_child(hint_margin)

	var hint_vbox = VBoxContainer.new()
	hint_margin.add_child(hint_vbox)

	# 計算機紋章是獨立badge（固定大小，不隨框寬度縮放），置中疊在標題
	# 上方——這個寬度不管框被撐多寬都不會跟著拉伸變形。
	var badge_center = CenterContainer.new()
	var badge_rect = TextureRect.new()
	badge_rect.texture = load(BADGE_FORMULA_HINT_CALCULATOR)
	badge_rect.custom_minimum_size = FORMULA_HINT_BADGE_SIZE
	badge_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	badge_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	badge_center.add_child(badge_rect)
	hint_vbox.add_child(badge_center)

	var title_hint = Label.new()
	title_hint.text = "公式提示"
	_apply_label_style(title_hint, SIDEBAR_CARD_TITLE_FONT_SIZE, COLOR_TEXT_BRIGHT)
	hint_vbox.add_child(title_hint)

	var hints = [
		{"f": "COUNTIF", "d": "計算符合條件的儲存格數量"},
		{"f": "SUMIFS", "d": "依多重條件加總數值"},
		{"f": "XLOOKUP", "d": "在範圍或陣列中查找對應值"}
	]

	for h in hints:
		var hb = VBoxContainer.new()
		var l1 = Label.new()
		l1.text = h["f"]
		_apply_label_style(l1, FORMULA_HINT_NAME_FONT_SIZE, COLOR_TEXT_BRIGHT)
		var l2 = Label.new()
		l2.text = h["d"]
		_apply_label_style(l2, FORMULA_HINT_DESC_FONT_SIZE, COLOR_TEXT_MUTED)
		hb.add_child(l1)
		hb.add_child(l2)
		hint_vbox.add_child(hb)
		var s = Control.new()
		s.custom_minimum_size = Vector2(0, HINT_ITEM_SPACING)
		hint_vbox.add_child(s)

	return panel


# 依0mockup/excel_solver_ui_mockup.png跟參考專案v2(render.js)的行為：
# 真實Excel整個可視範圍是一張「統一可選取」的格線網格，沒有資料的格子
# 一樣是正常大小、正常格線、可以被點選/拖曳選取，不是特別瘦或被排除
# 在選取系統外的死格子。current_column_order是這次建表時「真實欄位
# (A~J) + 補滿欄(K、L……)」的完整順序，後面所有跟選取相關的函式都依
# 這份清單運作，不再只看COLUMN_ORDER這個固定10欄的常數。
var current_column_order: Array = []
var current_column_widths: Dictionary = {}


func _build_grid() -> GridContainer:
	var max_rows = max(TABLE_ONE_DATA.size(), TABLE_TWO_NAMES.size())

	# 真實資料需要的總寬/總高（A~J欄 + 表頭列 + 資料列），算出畫面剩多少
	# 可視空間還沒被填滿，剩下的部分用同樣大小、一樣可選取的空白格補滿，
	# 對齊真實Excel「資料範圍以外仍會繼續顯示完整格線」的行為。
	var base_width: float = ROW_HEADER_WIDTH
	for col in COLUMN_ORDER:
		base_width += COLUMN_WIDTHS[col]
	var base_height: float = GRID_ROW_HEIGHT * (1 + max_rows)

	var available_width: float = grid_scroll_container.size.x
	var available_height: float = grid_scroll_container.size.y

	var filler_col_count := 0
	if available_width > base_width:
		filler_col_count = int(floor((available_width - base_width) / DEFAULT_FILLER_COLUMN_WIDTH))

	var filler_row_count := 0
	if available_height > base_height:
		filler_row_count = int(floor((available_height - base_height) / GRID_ROW_HEIGHT))

	current_column_order = COLUMN_ORDER.duplicate()
	current_column_widths = COLUMN_WIDTHS.duplicate()
	for i in range(filler_col_count):
		var filler_letter := _spreadsheet_column_letter(COLUMN_ORDER.size() + 1 + i)
		current_column_order.append(filler_letter)
		current_column_widths[filler_letter] = DEFAULT_FILLER_COLUMN_WIDTH

	var grid = GridContainer.new()
	grid.columns = current_column_order.size() + 1
	grid.add_theme_constant_override("h_separation", 0)
	grid.add_theme_constant_override("v_separation", 0)

	# ---- 表頭列：左上角空白角 + 所有欄位(A~J + 補滿欄)，全部統一可點選整欄 ----
	grid.add_child(_make_header_cell("", -1, true, ROW_HEADER_WIDTH))
	var col_index = 0
	for col in current_column_order:
		var header = _make_header_cell(col, -1, false, current_column_widths[col])
		header.gui_input.connect(_on_column_header_gui_input.bind(col_index))
		col_header_nodes[col] = header
		grid.add_child(header)
		col_index += 1

	# ---- 真實資料列：A~J原本內容 + 補滿欄空白格，全部用同一套鎖住格元件 ----
	for r in range(DATA_START_ROW, DATA_START_ROW + max_rows):
		_build_grid_row(grid, r, max_rows)

	# ---- 補滿列：資料範圍以下的空白格子，跟真實資料列同一套元件、
	# 同樣能被選取，只是沒有值（對齊真實Excel資料範圍以外仍可選取的
	# 空白格行為）----
	for i in range(filler_row_count):
		var r = DATA_START_ROW + max_rows + i
		_build_grid_row(grid, r, max_rows)

	return grid


# 建一整列（不管是真實資料列還是補滿列都走這個函式）：先放列號表頭，
# 再依current_column_order逐欄放格子。真實欄位裡有資料的格子才會寫進
# cell_value_lookup，其餘（補滿欄、或超出TABLE_ONE_DATA筆數的真實欄）
# 一律是空字串的鎖住格——跟其他格子用同一個_make_locked_cell()，所以
# 格線、邊框、選取行為完全一致。
func _build_grid_row(grid: GridContainer, r: int, max_rows: int) -> void:
	var row_header = _make_header_cell(str(r), r, false, ROW_HEADER_WIDTH)
	row_header.gui_input.connect(_on_row_header_gui_input.bind(r))
	row_header_nodes[r] = row_header
	grid.add_child(row_header)

	var data_index = r - DATA_START_ROW
	var is_real_data_row = data_index >= 0 and data_index < max_rows

	for col in current_column_order:
		var cell_id = col + str(r)
		var is_real_column = COLUMN_ORDER.has(col)

		if is_real_data_row and is_real_column and col == COL_STATUS and data_index < TABLE_ONE_DATA.size():
			grid.add_child(_make_editable_cell_with_handle(cell_id, r, current_column_widths[col]))
			continue

		var value := ""
		if is_real_data_row and is_real_column:
			value = _value_for_locked_cell(col, data_index)
			if value != "":
				cell_value_lookup[cell_id] = value
		grid.add_child(_make_locked_cell(cell_id, value, current_column_widths[col]))


# 把1-based欄位編號換成Excel式欄名（11->K、27->AA……），用來幫補滿欄
# 取一個延續A~J字母順序的名字，視覺上跟真實Excel一致。
func _spreadsheet_column_letter(index_from_1: int) -> String:
	var n := index_from_1
	var letters := ""
	while n > 0:
		var remainder := (n - 1) % 26
		letters = char(65 + remainder) + letters
		n = (n - 1) / 26
	return letters


func _value_for_locked_cell(col: String, data_index: int) -> String:
	if data_index >= TABLE_ONE_DATA.size() and col != COL_REFERENCE_LIST:
		return ""
	match col:
		COL_PERSON:
			return TABLE_ONE_DATA[data_index]["person"]
		COL_TIME:
			return TABLE_ONE_DATA[data_index]["time"]
		COL_LOCATION:
			return TABLE_ONE_DATA[data_index]["location"]
		COL_AMOUNT:
			return TABLE_ONE_DATA[data_index]["amount"]
		COL_ITEM:
			return TABLE_ONE_DATA[data_index]["item"]
		COL_WITNESS:
			return TABLE_ONE_DATA[data_index]["witness"]
		COL_NOTE:
			return TABLE_ONE_DATA[data_index]["note"]
		COL_REFERENCE_LIST:
			if data_index < TABLE_TWO_NAMES.size():
				return TABLE_TWO_NAMES[data_index]
			return ""
	return ""


# ------------------------------------------------------------
# 3. 格子建構函式
# ------------------------------------------------------------

func _make_border_stylebox(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var bg = StyleBoxFlat.new()
	bg.bg_color = bg_color
	bg.border_color = border_color
	bg.border_width_left = border_width
	bg.border_width_right = border_width
	bg.border_width_top = border_width
	bg.border_width_bottom = border_width
	return bg


# 表頭格（欄名或列號）。is_corner為true時是左上角空白格，不參與選取。
# row >= 0 代表這是列號表頭（用於存進row_header_nodes時對齊列號）。
# width_px：這一欄的固定寬度（像素），不再用SIZE_EXPAND_FILL讓Godot
# 依文字內容自動決定欄寬——那樣會因為「輸入公式」比「T1」寬而欄寬參差
# 不齊。改成明確寫死每欄寬度，表格總寬=各欄寬度總和，不隨內容變動。
func _make_header_cell(text: String, _row: int, is_corner: bool, width_px: float) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(width_px, GRID_ROW_HEIGHT)
	btn.add_theme_font_size_override("font_size", HEADER_FONT_SIZE)
	var font = load("res://assets/fonts/NotoSerifTC[wght].ttf")
	if font: btn.add_theme_font_override("font", font)
	btn.add_theme_color_override("font_color", COLOR_HEADER_TEXT)
	btn.add_theme_color_override("font_hover_color", COLOR_HEADER_TEXT)
	btn.add_theme_color_override("font_pressed_color", COLOR_HEADER_TEXT)
	btn.add_theme_stylebox_override("normal", _make_border_stylebox(COLOR_HEADER_BG, COLOR_LINE_SILVER, LOCKED_BORDER_WIDTH))
	btn.add_theme_stylebox_override("hover", _make_border_stylebox(COLOR_HEADER_BG, COLOR_ACCENT_GREEN, LOCKED_BORDER_WIDTH))
	btn.add_theme_stylebox_override("pressed", _make_border_stylebox(COLOR_HEADER_SELECTED_BG, COLOR_ACCENT_GREEN, LOCKED_BORDER_WIDTH))
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.focus_mode = Control.FOCUS_NONE
	if is_corner:
		btn.disabled = true
	return btn


# 鎖住的資料格：跟可編輯格用同一種LineEdit元件，只是editable=false，
# 鎖住只是因為這格已經有值，不代表它本來就是不同種類的東西。
# 選取拖曳直接接在LineEdit自己的gui_input訊號上（不用額外蓋一層覆蓋
# Control）——蓋一層mouse_filter=PASS的覆蓋層在它之下的LineEdit上，
# 會讓整個格子點不進去：PASS只會把事件往上傳給父節點，不會往下傳給
# 視覺上被蓋住的同層兄弟節點，所以下面的LineEdit根本收不到滑鼠事件、
# 永遠拿不到焦點。直接訂閱LineEdit自己的gui_input不會擋掉它原生的
# 點擊/取得焦點/打字行為，兩者可以並存。
func _make_locked_cell(cell_id: String, text: String, width_px: float) -> LineEdit:
	var input = LineEdit.new()
	input.text = text
	input.editable = false
	input.custom_minimum_size = Vector2(width_px, GRID_ROW_HEIGHT)
	input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	input.add_theme_font_size_override("font_size", CELL_FONT_SIZE)
	var font = load("res://assets/fonts/NotoSerifTC[wght].ttf")
	if font: input.add_theme_font_override("font", font)
	input.add_theme_stylebox_override("normal", _make_border_stylebox(COLOR_LOCKED_BG, COLOR_LOCKED_BORDER, LOCKED_BORDER_WIDTH))
	input.add_theme_stylebox_override("read_only", _make_border_stylebox(COLOR_LOCKED_BG, COLOR_LOCKED_BORDER, LOCKED_BORDER_WIDTH))
	input.add_theme_color_override("font_color", COLOR_LOCKED_TEXT)
	input.add_theme_color_override("font_uneditable_color", COLOR_LOCKED_TEXT)
	input.gui_input.connect(_on_cell_gui_input.bind(cell_id))

	all_cell_nodes[cell_id] = input
	cell_base_bg[cell_id] = COLOR_LOCKED_BG
	return input


# 可編輯格子＋右下角拖拉填滿手把：手把預設隱藏，只有這一格被選取（focus）
# 時才顯示，對齊真實Excel「只在目前選取格顯示填滿手把」的行為。
func _make_editable_cell_with_handle(cell_id: String, row: int, width_px: float) -> Control:
	var wrapper = Control.new()
	wrapper.custom_minimum_size = Vector2(width_px, GRID_ROW_HEIGHT)

	var input = LineEdit.new()
	input.name = "EditableCell_%s" % cell_id
	input.set_anchors_preset(Control.PRESET_FULL_RECT)
	# 可編輯格用靠左對齊，不是置中——置中對齊在打字時，文字/游標會以
	# 置中為基準跳動，跟一般輸入框「從左邊開始打字」的習慣不一致，
	# 會讓人覺得游標亂跳。鎖住的展示格(_make_locked_cell)維持置中沒
	# 關係，因為那些只是顯示結果，不會被打字。
	input.alignment = HORIZONTAL_ALIGNMENT_LEFT
	input.placeholder_text = "輸入公式"
	input.add_theme_font_size_override("font_size", CELL_FONT_SIZE)
	var font = load("res://assets/fonts/NotoSerifTC[wght].ttf")
	if font: input.add_theme_font_override("font", font)

	var bg = _make_border_stylebox(COLOR_EDITABLE_BG, COLOR_EDITABLE_BORDER, EDITABLE_BORDER_WIDTH)
	input.add_theme_stylebox_override("normal", bg)
	input.add_theme_stylebox_override("focus", bg)
	input.add_theme_color_override("font_color", COLOR_EDITABLE_TEXT)
	input.add_theme_color_override("caret_color", COLOR_EDITABLE_CARET)

	input.focus_entered.connect(_on_editable_cell_focus_entered.bind(cell_id))
	input.focus_exited.connect(_on_editable_cell_focus_exited.bind(cell_id))
	input.text_submitted.connect(_on_editable_cell_text_submitted.bind(cell_id))
	input.gui_input.connect(_on_cell_gui_input.bind(cell_id))
	wrapper.add_child(input)

	var handle = ColorRect.new()
	handle.name = "FillHandle_%s" % cell_id
	handle.color = COLOR_FILL_HANDLE
	handle.visible = false
	handle.mouse_filter = Control.MOUSE_FILTER_STOP
	# 滑鼠移到手把上方時指標改為十字準心，對齊真實Excel的提示行為。
	handle.mouse_default_cursor_shape = Control.CURSOR_CROSS
	handle.anchor_left = 1.0
	handle.anchor_top = 1.0
	handle.anchor_right = 1.0
	handle.anchor_bottom = 1.0
	handle.offset_left = -FILL_HANDLE_SIZE.x
	handle.offset_top = -FILL_HANDLE_SIZE.y
	handle.offset_right = 0
	handle.offset_bottom = 0
	handle.gui_input.connect(_on_fill_handle_gui_input.bind(row))
	wrapper.add_child(handle)

	editable_cells[cell_id] = input
	fill_handle_nodes[cell_id] = handle
	status_cell_by_row[row] = input
	row_formulas[cell_id] = ""
	all_cell_nodes[cell_id] = input
	cell_base_bg[cell_id] = COLOR_EDITABLE_BG

	return wrapper


# ------------------------------------------------------------
# 4. 使用者輸入處理
# ------------------------------------------------------------

# ---- 4a. 公式輸入（fx欄／格子本身）----

func _on_formula_bar_submitted(text: String) -> void:
	if active_cell_id == "" or not editable_cells.has(active_cell_id):
		_show_message("請先點選%s欄其中一格，再用fx欄輸入公式。" % COL_STATUS)
		return
	_commit_cell(active_cell_id, text)


func _on_editable_cell_focus_entered(cell_id: String) -> void:
	active_cell_id = cell_id
	editable_cells[cell_id].text = row_formulas.get(cell_id, "")
	for id in fill_handle_nodes:
		fill_handle_nodes[id].visible = (id == cell_id)


func _on_editable_cell_focus_exited(cell_id: String) -> void:
	_commit_cell(cell_id, editable_cells[cell_id].text)


func _on_editable_cell_text_submitted(text: String, cell_id: String) -> void:
	_commit_cell(cell_id, text)
	editable_cells[cell_id].release_focus()


func _commit_cell(cell_id: String, text: String) -> void:
	var trimmed = text.strip_edges()
	row_formulas[cell_id] = trimmed
	if trimmed == "":
		editable_cells[cell_id].text = ""
		return
	var row = int(cell_id.substr(1))
	var evaluation = _evaluate_countif(trimmed, row)
	_show_message(evaluation["message"])
	if evaluation["ok"]:
		editable_cells[cell_id].text = str(evaluation["value"])
		cell_value_lookup[cell_id] = str(evaluation["value"])
	else:
		editable_cells[cell_id].text = trimmed


func _show_message(text: String) -> void:
	if result_label != null:
		result_label.text = text


# ---- 4b. 整欄／整列／矩形範圍選取 ----

func _on_column_header_gui_input(event: InputEvent, col_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var col = current_column_order[col_index]
		var ids: Array = []
		for r in row_header_nodes:
			var cid = col + str(r)
			if all_cell_nodes.has(cid):
				ids.append(cid)
		_apply_selection(ids, "整欄 %s" % col)


func _on_row_header_gui_input(event: InputEvent, row: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var ids: Array = []
		for col in current_column_order:
			var cid = col + str(row)
			if all_cell_nodes.has(cid):
				ids.append(cid)
		_apply_selection(ids, "整列 %d" % row)


# 直接接在每個儲存格(LineEdit)自己的gui_input訊號上：按下時記錄起點，
# 開始一段可能的拖曳多格選取；實際拖曳中的移動/放開交給_input()統一
# 處理（理由跟拖拉填滿手把一樣：滑鼠移動到別的格子上時，不能被那一格
# 自己的點擊/焦點邏輯打斷）。這裡不呼叫accept_event()，所以LineEdit
# 自己原生的「點擊→取得焦點→可以打字」流程不會被擋掉，兩者並存。
#
# 用current_column_order（而不是固定10欄的COLUMN_ORDER）找col_index，
# 補滿欄（K、L……）才能跟A~J一樣正常開始拖曳選取，不會因為找不到欄位
# 索引而直接return、整個選取失效。
func _on_cell_gui_input(event: InputEvent, cell_id: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var col := _extract_column_letter(cell_id)
		var row := int(cell_id.substr(col.length()))
		var col_index = current_column_order.find(col)
		if col_index == -1:
			return
		is_selecting = true
		selection_anchor_col_index = col_index
		selection_anchor_row = row
		selection_current_col_index = col_index
		selection_current_row = row
		_refresh_rect_selection()


# cell_id格式是「欄字母+列號」（例如"G9"、"K10"，補滿欄超過Z後可能是
# "AA12"這種雙字母），欄字母長度不固定，不能再用substr(0,1)硬切第一個
# 字元——這裡改成往前掃描所有開頭的英文字母字元。
func _extract_column_letter(cell_id: String) -> String:
	var i := 0
	while i < cell_id.length() and cell_id[i].to_upper() >= "A" and cell_id[i].to_upper() <= "Z":
		i += 1
	return cell_id.substr(0, i)


func _refresh_rect_selection() -> void:
	var col_lo = min(selection_anchor_col_index, selection_current_col_index)
	var col_hi = max(selection_anchor_col_index, selection_current_col_index)
	var row_lo = min(selection_anchor_row, selection_current_row)
	var row_hi = max(selection_anchor_row, selection_current_row)

	var ids: Array = []
	for ci in range(col_lo, col_hi + 1):
		var col = current_column_order[ci]
		for r in range(row_lo, row_hi + 1):
			var cid = col + str(r)
			if all_cell_nodes.has(cid):
				ids.append(cid)

	var label_text = "%s%d:%s%d" % [current_column_order[col_lo], row_lo, current_column_order[col_hi], row_hi]
	_apply_selection(ids, label_text)


func _apply_selection(ids: Array, description: String) -> void:
	for cid in selected_cell_ids:
		if all_cell_nodes.has(cid):
			_set_cell_bg(all_cell_nodes[cid], cell_base_bg.get(cid, COLOR_LOCKED_BG))

	selected_cell_ids = ids
	for cid in selected_cell_ids:
		_set_cell_bg(all_cell_nodes[cid], COLOR_SELECTION_HIGHLIGHT_BG)

	selection_info_label.text = "目前選取：%s（%d 格）" % [description, ids.size()]


func _set_cell_bg(node: LineEdit, bg_color: Color) -> void:
	var border = COLOR_EDITABLE_BORDER if node.editable else COLOR_LOCKED_BORDER
	var border_width = EDITABLE_BORDER_WIDTH if node.editable else LOCKED_BORDER_WIDTH
	var style = _make_border_stylebox(bg_color, border, border_width)
	node.add_theme_stylebox_override("normal", style)
	if node.editable:
		node.add_theme_stylebox_override("focus", style)
	else:
		node.add_theme_stylebox_override("read_only", style)


# ---- 4c. 拖拉填滿手把 ----

func _on_fill_handle_gui_input(event: InputEvent, source_row: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_filling = true
		fill_source_row = source_row
		fill_current_target_row = source_row
		accept_event()


# 統一處理「拖拉填滿」跟「矩形範圍選取」兩種拖曳中的滑鼠移動/放開，用
# _input()（在GUI事件分派之前就會收到），避免拖曳途中滑鼠經過其他格子時
# 被那些格子自己的焦點/點擊邏輯打斷。兩種拖曳互斥，依is_filling優先判斷。
func _input(event: InputEvent) -> void:
	if is_filling:
		if event is InputEventMouseMotion:
			_update_fill_drag_target(event.global_position)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_finish_fill_drag()
			get_viewport().set_input_as_handled()
	elif is_selecting:
		if event is InputEventMouseMotion:
			_update_selection_drag_target(event.global_position)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			# 注意：這裡刻意不呼叫set_input_as_handled()。放開滑鼠這個事件
			# 還要繼續往下傳給GUI正常分派，讓被點到的LineEdit能完成它自己
			# 的「點擊→取得焦點→可以打字」流程。
			is_selecting = false


func _update_selection_drag_target(global_pos: Vector2) -> void:
	var closest_row = selection_current_row
	var closest_row_distance = INF
	for r in row_header_nodes:
		var node: Button = row_header_nodes[r]
		var center_y = node.get_global_rect().get_center().y
		var distance = abs(global_pos.y - center_y)
		if distance < closest_row_distance:
			closest_row_distance = distance
			closest_row = r

	var closest_col_index = selection_current_col_index
	var closest_col_distance = INF
	var ci = 0
	for col in current_column_order:
		if col_header_nodes.has(col):
			var node: Button = col_header_nodes[col]
			var center_x = node.get_global_rect().get_center().x
			var distance = abs(global_pos.x - center_x)
			if distance < closest_col_distance:
				closest_col_distance = distance
				closest_col_index = ci
		ci += 1

	if closest_row == selection_current_row and closest_col_index == selection_current_col_index:
		return
	selection_current_row = closest_row
	selection_current_col_index = closest_col_index
	_refresh_rect_selection()


func _update_fill_drag_target(global_pos: Vector2) -> void:
	var closest_row = fill_source_row
	var closest_distance = INF
	for row in status_cell_by_row:
		var node: LineEdit = status_cell_by_row[row]
		var center_y = node.get_global_rect().get_center().y
		var distance = abs(global_pos.y - center_y)
		if distance < closest_distance:
			closest_distance = distance
			closest_row = row

	if closest_row == fill_current_target_row:
		return
	fill_current_target_row = closest_row
	_refresh_fill_drag_highlight()


func _refresh_fill_drag_highlight() -> void:
	for row in status_cell_by_row:
		var node: LineEdit = status_cell_by_row[row]
		var in_range = row > fill_source_row and row <= fill_current_target_row
		var bg_color = COLOR_EDITABLE_HIGHLIGHT_BG if in_range else COLOR_EDITABLE_BG
		_set_cell_bg(node, bg_color)


func _finish_fill_drag() -> void:
	if fill_current_target_row > fill_source_row:
		_apply_fill_range(fill_source_row, fill_current_target_row)
	else:
		_show_message("拖曳填滿已取消（沒有往下拖到其他列）。")

	is_filling = false
	fill_source_row = -1
	fill_current_target_row = -1
	for row in status_cell_by_row:
		var node: LineEdit = status_cell_by_row[row]
		_set_cell_bg(node, COLOR_EDITABLE_BG)


# 把來源列已輸入的公式，依相對參照規則套用到 source_row+1 ~ target_row：
# 範圍部分（COL_REFERENCE_LIST的範圍）保持不變，但條件部分參照的列號要
# 跟著目前列數一起遞增，對應真實Excel往下拖曳填滿時的相對參照行為。
func _apply_fill_range(source_row: int, target_row: int) -> void:
	var source_cell_id = COL_STATUS + str(source_row)
	var source_formula: String = row_formulas.get(source_cell_id, "").strip_edges()
	if source_formula == "":
		_show_message("請先在 %s 輸入公式，再拖曳填滿。" % source_cell_id)
		return

	for row in range(source_row + 1, target_row + 1):
		var target_cell_id = COL_STATUS + str(row)
		if not editable_cells.has(target_cell_id):
			continue
		var shifted_formula = _shift_relative_reference(source_formula, COL_PERSON, source_row, row)
		_commit_cell(target_cell_id, shifted_formula)

	_show_message("已將 %s 的公式拖曳填滿到第%d~%d列（範圍不變，姓名參照列號自動遞增）。" % [source_cell_id, source_row + 1, target_row])


func _shift_relative_reference(formula: String, col: String, from_row: int, to_row: int) -> String:
	var regex = RegEx.new()
	regex.compile("\\b%s%d\\b" % [col, from_row])
	return regex.sub(formula, "%s%d" % [col, to_row], true)


# ------------------------------------------------------------
# 5. 公式運算核心
# ------------------------------------------------------------
func _evaluate_countif(raw_text: String, current_row: int) -> Dictionary:
	var text = _normalize_formula(raw_text)

	var parsed = _parse_countif(text)
	if parsed == null:
		return {"ok": false, "value": null, "message": "目前案件用不到這個指令，先專心查 COUNTIF 試試看。"}

	var range_col = parsed["range_col_start"]
	var range_row_start = parsed["range_row_start"]
	var range_row_end = parsed["range_row_end"]
	var criteria_raw = parsed["criteria_raw"]

	var range_values: Array = []
	for r in range(range_row_start, range_row_end + 1):
		var cell_id = range_col + str(r)
		if cell_value_lookup.has(cell_id):
			range_values.append(cell_value_lookup[cell_id])

	if range_values.is_empty():
		return {"ok": false, "value": null, "message": "找不到範圍 %s%d:%s%d 的資料。" % [range_col, range_row_start, range_col, range_row_end]}

	var criteria_value: String
	if criteria_raw.begins_with("\"") and criteria_raw.ends_with("\""):
		criteria_value = criteria_raw.substr(1, criteria_raw.length() - 2)
	else:
		if not cell_value_lookup.has(criteria_raw):
			return {"ok": false, "value": null, "message": "找不到參照格 %s 的值，請確認儲存格座標。" % criteria_raw}
		criteria_value = cell_value_lookup[criteria_raw]

	var count = 0
	for value in range_values:
		if value == criteria_value:
			count += 1

	var message = "=COUNTIF(%s%d:%s%d,%s) 結果 = %d（條件值：%s）" % [range_col, range_row_start, range_col, range_row_end, criteria_raw, count, criteria_value]
	return {"ok": true, "value": count, "message": message}


# ------------------------------------------------------------
# 6. 公式解析
# ------------------------------------------------------------
func _normalize_formula(text: String) -> String:
	var stripped = text.strip_edges()
	var result := ""
	var in_quotes := false
	for ch in stripped:
		if ch == "\"":
			in_quotes = not in_quotes
			result += ch
		elif in_quotes:
			result += ch
		else:
			result += ch.to_upper()
	return result


func _parse_countif(text: String):
	var regex = RegEx.new()
	regex.compile("^=COUNTIF\\(([A-Za-z]+)(\\d+):[A-Za-z]+(\\d+),\\s*(\"[^\"]*\"|[A-Za-z]+\\d+)\\)$")
	var m = regex.search(text.strip_edges())
	if m == null:
		return null
	return {
		"range_col_start": m.get_string(1).to_upper(),
		"range_row_start": int(m.get_string(2)),
		"range_row_end": int(m.get_string(3)),
		"criteria_raw": m.get_string(4)
	}
