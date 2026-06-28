extends Control

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

# ---- 資產路徑（沿用Story Dialogue UI跟存讀檔零件已經做好的正式美術）----
const STORY_DIALOGUE_UI_DIR := "res://assets/ui/story_dialogue/"
const EXCEL_SOLVER_UI_DIR := "res://assets/ui/excel_solver/"
const TAB_CATEGORY_TEXTURE := EXCEL_SOLVER_UI_DIR + "tab_category.png"
const TOP_BAR_BUTTON_KEYS := ["save", "load", "settings"]
const TOP_BAR_BUTTON_LABELS := {"save": "保存", "load": "讀取", "settings": "設定"}

# ---- 版面數字（統一管理，之後調整大小/間距只改這裡）----
const CELL_SIZE = Vector2(150, 48)
const HEADER_CELL_SIZE = Vector2(150, 40)
const SPACER_CELL_SIZE = Vector2(30, 36)  # 對齊COLUMN_WIDTHS["I"]，間隔欄寬度統一管理
const FILL_HANDLE_SIZE = Vector2(10, 10)
const PAGE_MARGIN = 20
const SECTION_SPACING = 12
const TITLE_FONT_SIZE = 20
const HINT_FONT_SIZE = 16
const RESULT_FONT_SIZE = 18
const PLACEHOLDER_FONT_SIZE = 16
const HEADER_FONT_SIZE = 18
const CELL_FONT_SIZE = 18
const SELECTION_INFO_FONT_SIZE = 15
const SIDEBAR_TITLE_FONT_SIZE = 17
const SIDEBAR_TAB_FONT_SIZE = 16
const OBJECTIVE_FONT_SIZE = 16
const FORMULA_HINT_NAME_FONT_SIZE = 17
const FORMULA_HINT_DESC_FONT_SIZE = 13
const LOCKED_BORDER_WIDTH = 1
const EDITABLE_BORDER_WIDTH = 2
const TOP_BAR_HEIGHT = 88
const BOTTOM_BAR_HEIGHT = 56
const LEFT_SIDEBAR_WIDTH = 230
const RIGHT_SIDEBAR_WIDTH = 270
const TOP_BAR_BUTTON_SIZE := Vector2(72, 64)
const SIDEBAR_TAB_SIZE := Vector2(190, 56)

# 左側分類牌高度：素材_source_5_save_load_tab.png原圖是1080x573（寬高比
# 約1.885:1）。v5剛做出來時把按鈕硬壓成50px高，跟原圖比例完全對不上，
# 角落雕花被壓扁變形。這裡不去猜測九宮格邊角雕花在原圖裡精確占多少
# 像素（沒有實際量過容易猜錯，margin設太大反而在矮按鈕裡會溢出），
# 改成更穩妥的做法：texture_margin設為0（整張圖直接等比例縮放，不切
# 九宮格），按鈕高度依照面板寬度跟原圖寬高比反推，確保整張圖縮放時
# 完全沒有變形。等之後素材有「拉長版」九宮格專用裁切（邊框窄、中間
# 大片留白）才適合切九宮格。
const SIDEBAR_PANEL_WIDTH := 250.0
const SIDEBAR_TAB_TEXTURE_ASPECT := 1080.0 / 573.0
const SIDEBAR_TAB_HEIGHT := SIDEBAR_PANEL_WIDTH / SIDEBAR_TAB_TEXTURE_ASPECT
const SIDEBAR_TAB_TEXTURE_MARGIN := 0.0

# 表格每一欄的固定寬度（像素），取代「依文字內容自動決定欄寬」——
# GridContainer若用SIZE_EXPAND_FILL+min_size.x=0，欄寬會依該欄最長的
# 文字內容跑來跑去（例如「輸入公式」比「T1」寬），造成參差不齊。明確
# 寫死每欄寬度後，表格寬度=各欄總和，不隨內容變動，也不會無限被撐開。
const ROW_HEADER_WIDTH := 40
const COLUMN_WIDTHS := {
	"A": 70, "B": 90, "C": 110, "D": 80, "E": 110,
	"F": 110, "G": 170, "H": 110, "I": 30, "J": 70,
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

var tex_left_tab: ImageTexture

func _load_texture_without_import(path: String, remove_black_threshold: float = 0.0) -> ImageTexture:
	var absolute_path = ProjectSettings.globalize_path("res://") + path
	if not FileAccess.file_exists(absolute_path):
		absolute_path = path # fallback
	var img := Image.load_from_file(absolute_path)
	if img == null or img.is_empty():
		return null
	if remove_black_threshold > 0.0:
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var color := img.get_pixel(x, y)
				var max_val: float = maxf(color.r, maxf(color.g, color.b))
				if max_val < remove_black_threshold:
					var alpha: float = max_val / remove_black_threshold
					img.set_pixel(x, y, Color(color.r, color.g, color.b, alpha * color.a))
	return ImageTexture.create_from_image(img)

func _apply_label_style(lbl: Label, size: int, color_hex: String) -> void:
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", Color(color_hex))
	var font = load("res://assets/fonts/NotoSerifTC[wght].ttf")
	if font: lbl.add_theme_font_override("font", font)

func _make_texture_style(tex: Texture2D, margin: float = 0.0) -> StyleBoxTexture:
	var sb = StyleBoxTexture.new()
	sb.texture = tex
	if margin > 0.0:
		sb.texture_margin_left = margin
		sb.texture_margin_top = margin
		sb.texture_margin_right = margin
		sb.texture_margin_bottom = margin
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

	tex_left_tab = _load_texture_without_import("../1UI/save_load/_source_5_save_load_tab.png", 0.08)

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
	bottom_panel.custom_minimum_size = Vector2(0, 50)
	bottom_panel.add_theme_stylebox_override("panel", _make_border_stylebox(Color(COLOR_PANEL_HEADER), Color(COLOR_LINE_SILVER), 1))
	
	var bottom_hbox = HBoxContainer.new()
	bottom_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	result_label = Label.new()
	result_label.name = "ResultLabel"
	result_label.text = "目前請使用 COUNTIF 檢查證言狀態。"
	_apply_label_style(result_label, 16, COLOR_TEXT_MAIN)
	bottom_hbox.add_child(result_label)
	
	selection_info_label = Label.new()
	selection_info_label.name = "SelectionInfoLabel"
	selection_info_label.text = "  |  目前選取：（無）"
	_apply_label_style(selection_info_label, 14, COLOR_TEXT_MUTED)
	bottom_hbox.add_child(selection_info_label)

	var bottom_margin = MarginContainer.new()
	bottom_margin.add_theme_constant_override("margin_left", 30)
	bottom_margin.add_child(bottom_hbox)
	bottom_panel.add_child(bottom_margin)
	root_vbox.add_child(bottom_panel)

func _build_top_bar() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 60)
	panel.add_theme_stylebox_override("panel", _make_border_stylebox(Color(COLOR_PANEL_HEADER), Color(COLOR_LINE_SILVER), 1))
	
	var hbox = HBoxContainer.new()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_child(hbox)
	panel.add_child(margin)

	var title = Label.new()
	title.text = "數據計算儀"
	_apply_label_style(title, 24, COLOR_TEXT_BRIGHT)
	hbox.add_child(title)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)
	
	var subtitle = Label.new()
	subtitle.text = "第1章：第一份委託"
	_apply_label_style(subtitle, 18, COLOR_TEXT_MUTED)
	hbox.add_child(subtitle)
	
	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer2)
	
	var btn_save = TextureButton.new()
	btn_save.texture_normal = load("res://assets/ui/story_dialogue/button_top_save_normal.png")
	btn_save.texture_hover = load("res://assets/ui/story_dialogue/button_top_save_hover.png")
	btn_save.texture_pressed = load("res://assets/ui/story_dialogue/button_top_save_pressed.png")
	btn_save.ignore_texture_size = true
	btn_save.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn_save.custom_minimum_size = Vector2(100, 36)
	btn_save.pressed.connect(func(): if self.has_method("_on_top_bar_button_pressed"): _on_top_bar_button_pressed("save"))
	hbox.add_child(btn_save)
	
	var btn_load = TextureButton.new()
	btn_load.texture_normal = load("res://assets/ui/story_dialogue/button_top_load_normal.png")
	btn_load.texture_hover = load("res://assets/ui/story_dialogue/button_top_load_hover.png")
	btn_load.texture_pressed = load("res://assets/ui/story_dialogue/button_top_load_pressed.png")
	btn_load.ignore_texture_size = true
	btn_load.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn_load.custom_minimum_size = Vector2(100, 36)
	btn_load.pressed.connect(func(): if self.has_method("_on_top_bar_button_pressed"): _on_top_bar_button_pressed("load"))
	hbox.add_child(btn_load)
	
	var btn_settings = TextureButton.new()
	btn_settings.texture_normal = load("res://assets/ui/story_dialogue/button_top_settings_normal.png")
	btn_settings.texture_hover = load("res://assets/ui/story_dialogue/button_top_settings_hover.png")
	btn_settings.texture_pressed = load("res://assets/ui/story_dialogue/button_top_settings_pressed.png")
	btn_settings.ignore_texture_size = true
	btn_settings.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn_settings.custom_minimum_size = Vector2(100, 36)
	btn_settings.pressed.connect(func(): if self.has_method("_on_top_bar_button_pressed"): _on_top_bar_button_pressed("settings"))
	hbox.add_child(btn_settings)

	return panel

func _build_left_sidebar() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(250, 0)
	panel.add_theme_stylebox_override("panel", _make_border_stylebox(Color(COLOR_PANEL_HEADER), Color(COLOR_LINE_SILVER), 1))
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "案件資料"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(0, 50)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_apply_label_style(title, 20, COLOR_TEXT_BRIGHT)
	vbox.add_child(title)
	
	var line = ColorRect.new()
	line.custom_minimum_size = Vector2(0, 1)
	line.color = Color(COLOR_LINE_SILVER)
	vbox.add_child(line)
	
	var categories = ["證言", "物證", "名冊", "交易紀錄"]
	for i in range(categories.size()):
		var cat = categories[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, SIDEBAR_TAB_HEIGHT)
		btn.text = cat
		btn.focus_mode = Control.FOCUS_NONE

		var clr = COLOR_ACCENT_GREEN if i == 0 else COLOR_TEXT_MAIN
		var font = load("res://assets/fonts/NotoSerifTC[wght].ttf")
		if font: btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 18)
		btn.add_theme_color_override("font_color", Color(clr))
		btn.add_theme_color_override("font_hover_color", Color(COLOR_TEXT_BRIGHT))
		btn.add_theme_color_override("font_pressed_color", Color(COLOR_ACCENT_GREEN))

		if tex_left_tab and i == 0:
			var sb = _make_texture_style(tex_left_tab, SIDEBAR_TAB_TEXTURE_MARGIN)
			btn.add_theme_stylebox_override("normal", sb)
			btn.add_theme_stylebox_override("hover", sb)
			btn.add_theme_stylebox_override("pressed", sb)
			btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		else:
			btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
			var hover_sb = _make_border_stylebox(Color(0.2, 0.2, 0.2, 0.5), Color(0), 0)
			btn.add_theme_stylebox_override("hover", hover_sb)
			btn.add_theme_stylebox_override("pressed", hover_sb)
			btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
		btn.pressed.connect(func(): if self.has_method("_on_sidebar_tab_pressed"): _on_sidebar_tab_pressed(i))
		vbox.add_child(btn)
		sidebar_tab_buttons.append(btn)
		
	return panel

func _build_center_area() -> Control:
	var center_vbox = VBoxContainer.new()
	center_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_vbox.add_theme_constant_override("separation", 20)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(center_vbox)

	var outer = MarginContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(margin)

	var formula_box = HBoxContainer.new()
	center_vbox.add_child(formula_box)

	var fx_label = Label.new()
	fx_label.text = "公式"
	_apply_label_style(fx_label, 18, COLOR_TEXT_MAIN)
	fx_label.custom_minimum_size = Vector2(48, 0)
	fx_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	formula_box.add_child(fx_label)

	var formula_input = LineEdit.new()
	formula_input.placeholder_text = "=COUNTIF(...)"
	formula_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	formula_input.name = "FormulaInput"
	formula_input.add_theme_font_size_override("font_size", 18)
	formula_input.add_theme_color_override("font_color", Color(COLOR_TEXT_BRIGHT))
	formula_input.add_theme_color_override("caret_color", Color(COLOR_TEXT_BRIGHT))
	var sb = _make_border_stylebox(Color(COLOR_LOCKED_BG), Color(COLOR_LINE_SILVER), 1)
	var sb_focus = _make_border_stylebox(Color(COLOR_LOCKED_BG), Color(COLOR_ACCENT_GREEN), 1)
	formula_input.add_theme_stylebox_override("normal", sb)
	formula_input.add_theme_stylebox_override("focus", sb_focus)
	formula_input.text_submitted.connect(_on_formula_bar_submitted)
	formula_box.add_child(formula_input)

	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_vbox.add_child(scroll)

	# 表格現在每欄都是固定寬度，總寬不再跟著內容變動，所以這裡改用
	# CenterContainer水平置中——畫面更寬時表格不會被無限拉伸撐開，
	# 而是維持原始大小、卷宗感的緊湊版面，置中顯示在可用空間裡。
	var grid_center = CenterContainer.new()
	grid_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_center.add_child(_build_grid())
	scroll.add_child(grid_center)

	return outer

func _on_top_bar_button_pressed(key: String) -> void:
	if self.has_method("_show_message"):
		_show_message("尚未實裝功能: " + key)

func _on_sidebar_tab_pressed(tab_index: int) -> void:
	_select_sidebar_tab(tab_index)

func _select_sidebar_tab(tab_index: int) -> void:
	for i in range(sidebar_tab_buttons.size()):
		var btn: Button = sidebar_tab_buttons[i]
		if i == tab_index:
			btn.add_theme_color_override("font_color", Color(COLOR_ACCENT_GREEN))
			if tex_left_tab:
				var sb = _make_texture_style(tex_left_tab, SIDEBAR_TAB_TEXTURE_MARGIN)
				btn.add_theme_stylebox_override("normal", sb)
		else:
			btn.add_theme_color_override("font_color", Color(COLOR_TEXT_MAIN))
			btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())

func _build_right_sidebar() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(250, 0)
	panel.add_theme_stylebox_override("panel", _make_border_stylebox(Color(COLOR_PANEL_HEADER), Color(COLOR_LINE_SILVER), 1))
	
	var vbox = VBoxContainer.new()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_child(vbox)
	panel.add_child(margin)
	
	var title_obj = Label.new()
	title_obj.text = "案件目標"
	_apply_label_style(title_obj, 20, COLOR_TEXT_BRIGHT)
	vbox.add_child(title_obj)
	
	var obj1 = Label.new()
	obj1.text = "◇ 找出證言矛盾"
	_apply_label_style(obj1, 16, COLOR_TEXT_MAIN)
	vbox.add_child(obj1)
	
	var obj2 = Label.new()
	obj2.text = "◆ 統計不在場人數"
	_apply_label_style(obj2, 16, COLOR_ACCENT_GREEN)
	vbox.add_child(obj2)
	
	var obj3 = Label.new()
	obj3.text = "◇ 比對交易紀錄"
	_apply_label_style(obj3, 16, COLOR_TEXT_MAIN)
	vbox.add_child(obj3)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer)
	
	var title_hint = Label.new()
	title_hint.text = "公式提示"
	_apply_label_style(title_hint, 20, COLOR_TEXT_BRIGHT)
	vbox.add_child(title_hint)
	
	var hints = [
		{"f": "COUNTIF", "d": "計算符合條件的儲存格數量"},
		{"f": "SUMIFS", "d": "依多重條件加總數值"},
		{"f": "XLOOKUP", "d": "在範圍或陣列中查找對應值"}
	]
	
	for h in hints:
		var hb = VBoxContainer.new()
		var l1 = Label.new()
		l1.text = h["f"]
		_apply_label_style(l1, 16, COLOR_TEXT_BRIGHT)
		var l2 = Label.new()
		l2.text = h["d"]
		_apply_label_style(l2, 14, COLOR_TEXT_MUTED)
		hb.add_child(l1)
		hb.add_child(l2)
		vbox.add_child(hb)
		var s = Control.new()
		s.custom_minimum_size = Vector2(0, 10)
		vbox.add_child(s)

	return panel


func _build_grid() -> GridContainer:
	var max_rows = max(TABLE_ONE_DATA.size(), TABLE_TWO_NAMES.size())
	var grid = GridContainer.new()
	grid.columns = COLUMN_ORDER.size() + 1
	grid.add_theme_constant_override("h_separation", 0)
	grid.add_theme_constant_override("v_separation", 0)

	grid.add_child(_make_header_cell("", -1, true, ROW_HEADER_WIDTH))
	var col_index = 0
	for col in COLUMN_ORDER:
		var header = _make_header_cell(col, -1, false, COLUMN_WIDTHS[col])
		if col != COL_SPACER:
			header.gui_input.connect(_on_column_header_gui_input.bind(col_index))
			col_header_nodes[col] = header
		grid.add_child(header)
		col_index += 1

	for r in range(DATA_START_ROW, DATA_START_ROW + max_rows):
		var row_header = _make_header_cell(str(r), r, false, ROW_HEADER_WIDTH)
		row_header.gui_input.connect(_on_row_header_gui_input.bind(r))
		row_header_nodes[r] = row_header
		grid.add_child(row_header)

		var data_index = r - DATA_START_ROW

		for col in COLUMN_ORDER:
			var cell_id = col + str(r)
			if col == COL_STATUS and data_index < TABLE_ONE_DATA.size():
				grid.add_child(_make_editable_cell_with_handle(cell_id, r, COLUMN_WIDTHS[col]))
			elif col == COL_SPACER:
				grid.add_child(_make_spacer_cell())
			else:
				var value := _value_for_locked_cell(col, data_index)
				if value != "":
					cell_value_lookup[cell_id] = value
				grid.add_child(_make_locked_cell(cell_id, value, COLUMN_WIDTHS[col]))

	return grid


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
	btn.custom_minimum_size = Vector2(width_px, 36)
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
	input.custom_minimum_size = Vector2(width_px, 36)
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
	wrapper.custom_minimum_size = Vector2(width_px, 36)

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


func _make_spacer_cell() -> Label:
	var lbl = Label.new()
	lbl.custom_minimum_size = SPACER_CELL_SIZE
	lbl.add_theme_stylebox_override("normal", _make_border_stylebox(COLOR_SPACER_BG, COLOR_SPACER_BG, 0))
	return lbl


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
		var col = COLUMN_ORDER[col_index]
		var ids: Array = []
		for r in row_header_nodes:
			var cid = col + str(r)
			if all_cell_nodes.has(cid):
				ids.append(cid)
		_apply_selection(ids, "整欄 %s" % col)


func _on_row_header_gui_input(event: InputEvent, row: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var ids: Array = []
		for col in COLUMN_ORDER:
			var cid = col + str(row)
			if all_cell_nodes.has(cid):
				ids.append(cid)
		_apply_selection(ids, "整列 %d" % row)


# 直接接在每個儲存格(LineEdit)自己的gui_input訊號上：按下時記錄起點，
# 開始一段可能的拖曳多格選取；實際拖曳中的移動/放開交給_input()統一
# 處理（理由跟拖拉填滿手把一樣：滑鼠移動到別的格子上時，不能被那一格
# 自己的點擊/焦點邏輯打斷）。這裡不呼叫accept_event()，所以LineEdit
# 自己原生的「點擊→取得焦點→可以打字」流程不會被擋掉，兩者並存。
func _on_cell_gui_input(event: InputEvent, cell_id: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var col = cell_id.substr(0, 1)
		var row = int(cell_id.substr(1))
		var col_index = COLUMN_ORDER.find(col)
		if col_index == -1:
			return
		is_selecting = true
		selection_anchor_col_index = col_index
		selection_anchor_row = row
		selection_current_col_index = col_index
		selection_current_row = row
		_refresh_rect_selection()


func _refresh_rect_selection() -> void:
	var col_lo = min(selection_anchor_col_index, selection_current_col_index)
	var col_hi = max(selection_anchor_col_index, selection_current_col_index)
	var row_lo = min(selection_anchor_row, selection_current_row)
	var row_hi = max(selection_anchor_row, selection_current_row)

	var ids: Array = []
	for ci in range(col_lo, col_hi + 1):
		var col = COLUMN_ORDER[ci]
		for r in range(row_lo, row_hi + 1):
			var cid = col + str(r)
			if all_cell_nodes.has(cid):
				ids.append(cid)

	var label_text = "%s%d:%s%d" % [COLUMN_ORDER[col_lo], row_lo, COLUMN_ORDER[col_hi], row_hi]
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
	for col in COLUMN_ORDER:
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
