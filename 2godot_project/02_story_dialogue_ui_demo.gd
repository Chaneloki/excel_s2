extends Control

# ------------------------------
# 異動紀錄 (Change Log):
# 2026-06-26:
#   1. 案件目標 UI 微調與重構：合併 builder 函數至單一 VBoxContainer (CaseObjectiveWidget) 管理，設定 separation=-6 消除垂直間隙，並配合外層 MarginContainer (CaseObjectiveContentMargin) 設定 margin_left=10, margin_right=5 來對齊金屬邊框實體邊緣。
#   2. 字體視覺提升：下載開源思源宋體 (Noto Serif TC Variable Font) 置於 assets/fonts/，並動態套用到所有 Label 與 Button 控制項，對齊 Mockup 中的雅緻明體/宋體古典風格。
#   3. 存讀檔彈窗改用 1UI/save_load 正式美術零件（main_panel + 6格存檔卡 + 選取高亮框），
#      取代原本沿用案件目標面板貼圖的純文字暫時版本，並依保存/讀取模式分別控制格子是否可點擊。
#   4. 調查紀錄對齊與佈局優化：重構對白紀錄彈窗結構，列表左右 Margin 設為 156 以完美貼齊金屬面板左右邊緣；獨立關閉按鈕絕對定位於 card 右上方並稍微超出金屬外框；加寬列表上方 margin 讓對白紀錄稍向下移，更具呼吸感。
# ------------------------------

# ------------------------------
# 設定區：資產路徑
# ------------------------------
const UI_SKIN_DIR := "res://assets/ui/story_dialogue/"
const CHARACTER_DIR := "res://assets/characters/"
const BG_STORY_OFFICE := UI_SKIN_DIR + "bg_detective_office_rainy_night.png"
const HOST_TEMP := CHARACTER_DIR + "host_lisia_story_transparent_v0_1.png"
const BUTTON_NORMAL := UI_SKIN_DIR + "button_icon_frame_normal.png"
const BUTTON_HOVER := UI_SKIN_DIR + "button_icon_frame_hover.png"
const BUTTON_PRESSED := UI_SKIN_DIR + "button_icon_frame_pressed.png"
# 右上角五個功能鈕：每個狀態都是完整美術圖（圖示+外框已畫在一起），
# 不再像舊版用「通用外框+另外疊icon」的做法。
const TOP_MENU_BUTTON_SUFFIX_NORMAL := "_normal.png"
const TOP_MENU_BUTTON_SUFFIX_HOVER := "_hover.png"
const TOP_MENU_BUTTON_SUFFIX_PRESSED := "_pressed.png"
const PANEL_DIALOGUE_BOX := UI_SKIN_DIR + "panel_dialogue_box_ornate.png"
const PANEL_NAME_PLATE := UI_SKIN_DIR + "panel_name_plate_ornate.png"
const PANEL_CASE_OBJECTIVE := UI_SKIN_DIR + "panel_case_objective_ornate.png"
# 案件目標標題列：「案件目標」文字跟展開/收合箭頭已經畫在圖裡，
# 下方的詳細目標內容框不在這張圖內，由Godot另外畫。
const PANEL_OBJECTIVE_HEADER_EXPANDED := UI_SKIN_DIR + "panel_case_objective_header_open.png"
const PANEL_OBJECTIVE_HEADER_COLLAPSED := UI_SKIN_DIR + "panel_case_objective_header_closed.png"

# 存讀檔彈窗素材（來源1UI/save_load，見assets/ui/save_load/README.md）。
const UI_SKIN_SAVE_LOAD_DIR := "res://assets/ui/save_load/"
const BG_SAVE_LOAD_OFFICE := UI_SKIN_SAVE_LOAD_DIR + "bg_save_load_office.png"
const PANEL_SAVE_LOAD_MAIN := UI_SKIN_SAVE_LOAD_DIR + "panel_main_save_load.png"
const SAVE_LOAD_SLOT_EMPTY := UI_SKIN_SAVE_LOAD_DIR + "slot_empty_normal.png"
const SAVE_LOAD_SLOT_SAVED := UI_SKIN_SAVE_LOAD_DIR + "slot_saved_normal.png"
const SAVE_LOAD_SLOT_SELECTED_FRAME := UI_SKIN_SAVE_LOAD_DIR + "frame_slot_selected.png"

# ------------------------------
# 設定區：色彩、字級與共用尺寸
# ------------------------------
const COLOR_TEXT_MAIN := "#f0eadb"
const COLOR_TEXT_BRIGHT := "#f7f1e4"
const COLOR_TEXT_MUTED := "#c9c2ae"
const COLOR_TEXT_WHITE := "#ffffff"
const COLOR_ACCENT_GREEN := "#bde8cc"
const COLOR_LINE_SILVER := "#c9d3c6aa"
const COLOR_LINE_GOLD := "#b8a06d9a"
const COLOR_PANEL_HEADER := "#10231fcc"
const COLOR_SHADOW_SOFT := "#000000a8"
const COLOR_SHADOW_DIALOGUE := "#000000c0"
const COLOR_SHADOW_NAME := "#000000b0"
const COLOR_VIGNETTE := Color(0.0, 0.0, 0.0, 0.18)
const COLOR_DIALOGUE_INNER_SHADOW := Color(0.0, 0.0, 0.0, 0.24)

const FONT_MENU_LABEL := 13
const FONT_POPUP_TITLE := 28
const FONT_POPUP_CLOSE := 36
const FONT_POPUP_BUTTON := 18
const FONT_VOLUME_LABEL := 20
const FONT_SAVE_LOAD_SLOT_TITLE := 26
const FONT_SAVE_LOAD_SLOT_CHAPTER := 20
const FONT_SAVE_LOAD_SLOT_LOCATION := 17
const FONT_SAVE_LOAD_SLOT_EMPTY_LABEL := 17
const FONT_LOG_SPEAKER := 17
const FONT_LOG_TEXT := 20
const FONT_OBJECTIVE_ITEM := 20
const FONT_DIALOGUE_TEXT := 32
const FONT_NAME_TEXT := 27

const MENU_STACK_SIZE := Vector2(96, 56)

# 五個按鈕直接用各自裁切後的原始貼圖（見assets/ui/story_dialogue/README.md）。
# 三態貼圖已經用「核心圖案中心對齊」處理過，核心大小完全一致，
# 所以這裡單純放大MENU_BUTTON_SIZE，hover不會因為放大而出現縮放感。
const MENU_BUTTON_SIZE := Vector2(96, 84)
const POPUP_CLOSE_BUTTON_SIZE := Vector2(64, 56)
const SAVE_LOAD_SLOT_SIZE := Vector2(480, 360)
const VOLUME_LABEL_SIZE := Vector2(58, 0)
const DECORATIVE_LINE_HEIGHT := 2

const STYLE_BUTTON_TEXTURE_MARGIN := 24
const STYLE_BUTTON_CONTENT_MARGIN := 6
const STYLE_SMALL_BUTTON_TEXTURE_MARGIN := 14
const STYLE_SMALL_BUTTON_CONTENT_MARGIN := 4
# 新版對話框美術（panel_dialogue_box_ornate.png，來源1UI/story_dialogue/dialogue_box.png）
# 左右兩側的金色立柱裝飾較粗，邊距要加大才不會被拉伸變形。
const STYLE_DIALOGUE_TEXTURE_MARGIN := 50
const STYLE_DIALOGUE_CONTENT_MARGIN := 26
const STYLE_POPUP_TEXTURE_MARGIN := 38
const STYLE_POPUP_CONTENT_MARGIN := 18
# 案件目標的詳細內容框是純Godot繪製（沒有對應圖片資產），用深綠玻璃感
# 底色+銀色細邊呼應整體UI風格指南，跟標題列圖片的造型呼應但不重複。
const OBJECTIVE_CONTENT_BORDER_WIDTH := 1
const OBJECTIVE_CONTENT_CORNER_RADIUS := 4
const STYLE_LOG_TEXTURE_MARGIN := 22
const STYLE_LOG_CONTENT_MARGIN := 10
# 存讀檔主面板（panel_main_save_load.png）邊框較粗，需要較大的texture_margin
# 才不會把四角裝飾拉伸變形。
const STYLE_SAVE_LOAD_TEXTURE_MARGIN := 34
const STYLE_SAVE_LOAD_CONTENT_MARGIN := 18

const SHADOW_OFFSET_SMALL := Vector2(1, 1)
const SHADOW_OFFSET_DIALOGUE := Vector2(2, 2)
const AUTO_ADVANCE_SECONDS := 2.2
const BGM_VOLUME_INITIAL := 0.75
const SFX_VOLUME_INITIAL := 0.80
const SLIDER_MIN_VALUE := 0.0
const SLIDER_MAX_VALUE := 1.0
const SLIDER_STEP := 0.01

# ------------------------------
# 設定區：版面位置與間距
# Vector4 依序代表 left、top、right、bottom。
# ------------------------------
const ANCHOR_HOST := Vector4(0.400, 0.000, 0.785, 1.000)
const ANCHOR_TOP_MENU := Vector4(0.665, 0.020, 0.972, 0.122)
const ANCHOR_SETTINGS_POPUP := Vector4(0.36, 0.22, 0.68, 0.55)
const ANCHOR_SAVE_LOAD_POPUP := Vector4(0.0, 0.0, 1.0, 1.0)
# 卡片面板（main_panel）相對於上面全螢幕背景的內縮比例，留出四周空間
# 讓bg_save_load_office.png的書房場景可以被看到，呼應mockup的「面板浮在
# 書房場景上」構圖。高度留到0.92才能放滿2排存檔格+標題列，不被框邊裁切。
const ANCHOR_SAVE_LOAD_CARD := Vector4(0.06, 0.06, 0.94, 0.94)
const ANCHOR_DIALOGUE_LOG_POPUP := Vector4(0.18, 0.12, 0.82, 0.72)

# 標題列（圖片資產，圖中已含「案件目標」文字跟展開/收合箭頭，
# 寬364px對應370x76原圖比例，固定顯示、不隨展開/收合改變位置）。
const ANCHOR_OBJECTIVE_HEADER := Vector4(0.795, 0.425, 0.985, 0.494)
# 詳細目標內容框：高度貼合mockup「單行目標+留白」的緊湊比例，
# 不是用來塞長篇內容的大面板。
const ANCHOR_OBJECTIVE_CONTENT := Vector4(0.795, 0.494, 0.985, 0.555)
const ANCHOR_DIALOGUE_BOX := Vector4(0.035, 0.650, 0.985, 0.945)
# 寬422px對應姓名牌原圖961x208的比例（高約91px），維持原圖長寬比例
# 避免六邊形尖角被拉伸變形（用TextureRect KEEP_ASPECT_CENTERED顯示）。
# 寬度只要貼合「莉希雅」這種2~4字姓名+左右留白即可，不需要跟對話框
# 一樣寬——之前0.265右緣（寬422px）對短名字來說明顯過大，跟對話框內部
# 的金色裝飾線視覺上連成一片，看起來像姓名牌「蓋住整個對話框」。
const ANCHOR_NAME_PLATE := Vector4(0.090, 0.620, 0.285, 0.695)

const MARGIN_POPUP := Vector4(42, 30, 38, 30)
const MARGIN_SETTINGS_POPUP := Vector4(40, 28, 34, 28)
# 存讀檔卡片內距比一般彈窗更緊，把空間留給2排存檔格，避免格子被卡片
# 框邊裁切。
const MARGIN_SAVE_LOAD_POPUP := Vector4(34, 20, 30, 18)
const MARGIN_LOG_POPUP := Vector4(70, 30, 70, 30)
const MARGIN_SAVE_LOAD_SLOT_TEXT := Vector4(8, 0, 8, 8)
const MARGIN_LOG_ENTRY := Vector4(22, 12, 20, 12)
const MARGIN_OBJECTIVE := Vector4(20, 11, 18, 11)
const MARGIN_DIALOGUE := Vector4(92, 48, 78, 34)

const GAP_MENU := 14
const GAP_MENU_LABEL := 0
const GAP_POPUP_LAYOUT := 16
const GAP_SETTINGS_LAYOUT := 18
const GAP_TITLE_ROW := 12
const GAP_VOLUME_ROW := 16
const GAP_SAVE_LOAD_GRID_H := 16
const GAP_SAVE_LOAD_GRID_V := 16
# 存讀檔卡片的標題列跟格子之間用較小間距，把垂直空間留給存檔格本身。
const GAP_SAVE_LOAD_POPUP_LAYOUT := 10
const GAP_LOG_ENTRIES := 10
const GAP_LOG_ENTRY_TEXT := 5
const GAP_OBJECTIVE_LIST := 11
const GAP_OBJECTIVE_ITEM_ICON := 10
const GAP_DIALOGUE_LAYOUT := 18

# ------------------------------
# 設定區：原型測試資料
# ------------------------------
const CASE_OBJECTIVES := [
	"確認委託人的證言",
]

const TOP_MENU_ITEMS := [
	{"label": "保存", "key": "save"},
	{"label": "讀取", "key": "load"},
	{"label": "設定", "key": "settings"},
	{"label": "紀錄", "key": "log"},
	{"label": "自動", "key": "auto"},
]

const DIALOGUE_LINES := [
	{
		"type": "dialogue",
		"speaker_name": "莉希雅",
		"text": "第一份委託，終於走到我的門前了。"
	},
	{
		"type": "dialogue",
		"speaker_name": "莉希雅",
		"text": "先別急著相信任何證言。資料會比人誠實得多。"
	},
	{
		"type": "system",
		"speaker_name": "調查紀錄",
		"text": "案件目標已更新。"
	},
	{
		"type": "dialogue",
		"speaker_name": "莉希雅",
		"text": "把委託人的時間、地點和交易紀錄整理出來，我們再開始判斷。"
	},
]

# 存讀檔模式：只影響標題文字跟空白格是否可點擊，格子排版本身不變。
const SAVE_LOAD_MODE_SAVE := "save"
const SAVE_LOAD_MODE_LOAD := "load"

const SAVE_LOAD_STATE_SAVED := "saved"
const SAVE_LOAD_STATE_EMPTY := "empty"

const SAVE_LOAD_GRID_COLUMNS := 3
const SAVE_LOAD_LABEL_EMPTY := "空白檔案"

# 6個案件檔案格的原型測試資料：照mockup排版，前2格已存檔、其餘4格空白
# （見0mockup/save_load_ui_mockup.png）。
const SAVE_LOAD_SLOT_DATA := [
	{"state": SAVE_LOAD_STATE_SAVED, "chapter": "第1章", "location": "白塔街偵探所 / 調查中"},
	{"state": SAVE_LOAD_STATE_SAVED, "chapter": "第1章", "location": "白塔街偵探所 / 調查中"},
	{"state": SAVE_LOAD_STATE_EMPTY},
	{"state": SAVE_LOAD_STATE_EMPTY},
	{"state": SAVE_LOAD_STATE_EMPTY},
	{"state": SAVE_LOAD_STATE_EMPTY},
]

# ------------------------------
# 狀態區：畫面節點與互動狀態
# ------------------------------
var current_line_index := 0

var name_plate: TextureRect
var name_label: Label
var dialogue_label: Label
var objective_header_button: TextureButton
var objective_panel: PanelContainer
var objective_list: VBoxContainer
var objective_panel_collapsed := false
var settings_panel: PanelContainer
var save_load_panel: Control
var save_load_mode := SAVE_LOAD_MODE_SAVE
var save_load_selected_index := 0
var save_load_slot_buttons: Array[TextureButton] = []
var save_load_selection_frames: Array[TextureRect] = []
var dialogue_log_panel: Control
var auto_button: BaseButton
var auto_advance_timer: Timer
var auto_advance_enabled := false
var bgm_volume := BGM_VOLUME_INITIAL
var sfx_volume := SFX_VOLUME_INITIAL


# ------------------------------
# 建構區：進入點與主畫面
# ------------------------------
func _ready() -> void:
	_build_ui()
	_show_line(0)


func _build_ui() -> void:
	_build_background()
	_build_host_sprite()
	_build_objective_panel()
	_build_top_right_menu()
	_build_dialogue_box()
	_build_settings_popup()
	_build_save_load_popup()
	_build_dialogue_log_popup()
	_build_auto_advance_timer()


func _build_background() -> void:
	var background := TextureRect.new()
	background.name = "Background_DetectiveOffice_RainyNightV01"
	background.texture = load(BG_STORY_OFFICE)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(background)

	var vignette := ColorRect.new()
	vignette.name = "MoodOverlay_DimEdges"
	vignette.color = COLOR_VIGNETTE
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vignette)

	var dialogue_shadow := ColorRect.new()
	dialogue_shadow.name = "MoodOverlay_DialogueDepth"
	dialogue_shadow.color = COLOR_DIALOGUE_INNER_SHADOW
	_apply_anchors(dialogue_shadow, Vector4(0.0, 0.66, 1.0, 1.0))
	dialogue_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dialogue_shadow)


func _build_host_sprite() -> void:
	var host := TextureRect.new()
	host.name = "HostSprite_Lisia_StoryTransparentV01"
	host.texture = load(HOST_TEMP)
	_apply_anchors(host, ANCHOR_HOST)
	host.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	# 用CENTERED（不裁切）：COVERED會把立繪邊緣的半透明髮絲细節硬切掉，
	# 變成方形剪裁的違和感。錨點框已放大到跟圖片高度幾乎吻合，
	# CENTERED在這個框內本身就幾乎貼滿上下緣，不會再留空隙。
	host.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(host)


func _build_top_right_menu() -> void:
	var menu := HBoxContainer.new()
	menu.name = "TopRightMenu_SaveLoadSettingsLogAuto"
	_apply_anchors(menu, ANCHOR_TOP_MENU)
	menu.alignment = BoxContainer.ALIGNMENT_END
	menu.add_theme_constant_override("separation", GAP_MENU)
	add_child(menu)

	var menu_index := 0
	for item in TOP_MENU_ITEMS:
		var stack := VBoxContainer.new()
		stack.name = "MenuItem_%s" % item["label"]
		stack.alignment = BoxContainer.ALIGNMENT_CENTER
		stack.custom_minimum_size = MENU_STACK_SIZE
		stack.add_theme_constant_override("separation", GAP_MENU_LABEL)
		menu.add_child(stack)

		var button := _make_top_menu_button(item["label"], item["key"])
		_connect_top_menu_button(button, menu_index)
		stack.add_child(button)

		var label := Label.new()
		label.name = "Label_%s" % item["label"]
		label.text = item["label"]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_apply_label_style(label, FONT_MENU_LABEL, COLOR_TEXT_MAIN, COLOR_SHADOW_SOFT, SHADOW_OFFSET_SMALL)
		stack.add_child(label)
		menu_index += 1


func _build_dialogue_box() -> void:
	var dialogue_box := PanelContainer.new()
	dialogue_box.name = "DialogueBox"
	_apply_anchors(dialogue_box, ANCHOR_DIALOGUE_BOX)
	dialogue_box.add_theme_stylebox_override("panel", _make_texture_style(PANEL_DIALOGUE_BOX, STYLE_DIALOGUE_TEXTURE_MARGIN, STYLE_DIALOGUE_CONTENT_MARGIN))
	add_child(dialogue_box)

	var margin := MarginContainer.new()
	_apply_margins(margin, MARGIN_DIALOGUE)
	dialogue_box.add_child(margin)

	var dialogue_layout := VBoxContainer.new()
	dialogue_layout.add_theme_constant_override("separation", GAP_DIALOGUE_LAYOUT)
	margin.add_child(dialogue_layout)

	dialogue_layout.add_child(_make_detail_line(COLOR_LINE_GOLD))

	dialogue_label = Label.new()
	dialogue_label.name = "DialogueText"
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_label_style(dialogue_label, FONT_DIALOGUE_TEXT, COLOR_TEXT_BRIGHT, COLOR_SHADOW_DIALOGUE, SHADOW_OFFSET_DIALOGUE)
	dialogue_layout.add_child(dialogue_label)

	dialogue_layout.add_child(_make_detail_line(COLOR_LINE_SILVER))

	# 姓名牌是六邊形尖角造型，尖角貫穿整張圖的高度，不是傳統的「四角小
	# 裝飾+可伸縮邊」結構，硬套九宮格StyleBoxTexture會把尖角擠壓變形。
	# 改用單張圖整體等比例縮放（不裁切、不分區拉伸），文字直接疊在正中央。
	name_plate = TextureRect.new()
	name_plate.name = "NamePlate"
	name_plate.texture = load(PANEL_NAME_PLATE)
	# expand_mode預設EXPAND_KEEP_SIZE會把節點最小尺寸強制等於貼圖原始
	# 像素大小（961x208），蓋過下面的錨點設定。改成IGNORE_SIZE才會真正
	# 依照錨點框的大小顯示，不被貼圖原始尺寸綁架。
	name_plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	name_plate.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	name_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_anchors(name_plate, ANCHOR_NAME_PLATE)
	add_child(name_plate)

	name_label = Label.new()
	name_label.name = "SpeakerName"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_label_style(name_label, FONT_NAME_TEXT, COLOR_TEXT_BRIGHT, COLOR_SHADOW_NAME, SHADOW_OFFSET_SMALL)
	_apply_anchors(name_label, ANCHOR_NAME_PLATE)
	add_child(name_label)


# ------------------------------
# 建構區：案件目標面板
# ------------------------------
func _build_objective_panel() -> void:
	# 建立統一的案件目標小面板容器 (VBoxContainer)
	var widget := VBoxContainer.new()
	widget.name = "CaseObjectiveWidget"
	# 使用原本標題列的 left、right 錨點，高度則覆蓋整個標題列與內容框的範圍 (從 0.425 到 0.555)
	_apply_anchors(widget, Vector4(ANCHOR_OBJECTIVE_HEADER.x, ANCHOR_OBJECTIVE_HEADER.y, ANCHOR_OBJECTIVE_HEADER.z, ANCHOR_OBJECTIVE_CONTENT.w))
	widget.add_theme_constant_override("separation", -6) # 消除標題底部透明邊緣的垂直空隙
	add_child(widget)
	
	# 1. 建立標題列按鈕
	objective_header_button = TextureButton.new()
	objective_header_button.name = "Button_CaseObjectiveHeader"
	objective_header_button.ignore_texture_size = true
	objective_header_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	objective_header_button.custom_minimum_size = Vector2(0, 75)
	objective_header_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
	objective_header_button.focus_mode = Control.FOCUS_NONE
	objective_header_button.texture_normal = load(PANEL_OBJECTIVE_HEADER_EXPANDED)
	objective_header_button.pressed.connect(_toggle_objective_panel)
	widget.add_child(objective_header_button)

	# 2. 建立內容外邊距容器（對齊金屬邊框，左側 10px，右側 5px）
	var content_margin := MarginContainer.new()
	content_margin.name = "CaseObjectiveContentMargin"
	content_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_margin.add_theme_constant_override("margin_left", 10)
	content_margin.add_theme_constant_override("margin_right", 5)
	widget.add_child(content_margin)

	# 3. 建立詳細內容面板
	objective_panel = PanelContainer.new()
	objective_panel.name = "CaseObjectiveContentPanel"
	objective_panel.add_theme_stylebox_override("panel", _make_flat_panel_style(COLOR_PANEL_HEADER, COLOR_LINE_SILVER, OBJECTIVE_CONTENT_BORDER_WIDTH, OBJECTIVE_CONTENT_CORNER_RADIUS))
	content_margin.add_child(objective_panel)

	# 4. 建立內容邊距
	var margin := MarginContainer.new()
	_apply_margins(margin, MARGIN_OBJECTIVE)
	objective_panel.add_child(margin)

	# 5. 建立目標清單
	objective_list = VBoxContainer.new()
	objective_list.add_theme_constant_override("separation", GAP_OBJECTIVE_LIST)
	margin.add_child(objective_list)

	for objective in CASE_OBJECTIVES:
		objective_list.add_child(_make_objective_item_row(objective))




func _make_objective_item_row(objective_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", GAP_OBJECTIVE_ITEM_ICON)

	var icon := Label.new()
	icon.name = "ObjectiveIcon"
	icon.text = "◇"
	_apply_label_style(icon, FONT_OBJECTIVE_ITEM, COLOR_ACCENT_GREEN)
	row.add_child(icon)

	var text := Label.new()
	text.name = "ObjectiveText"
	text.text = objective_text
	_apply_label_style(text, FONT_OBJECTIVE_ITEM, COLOR_TEXT_MAIN)
	row.add_child(text)
	return row


# ------------------------------
# 建構區：設定、存讀檔、紀錄彈窗
# ------------------------------
func _build_settings_popup() -> void:
	settings_panel = PanelContainer.new()
	settings_panel.name = "SettingsPopup_BgmSfx"
	settings_panel.visible = false
	_apply_anchors(settings_panel, ANCHOR_SETTINGS_POPUP)
	settings_panel.add_theme_stylebox_override("panel", _make_texture_style(PANEL_DIALOGUE_BOX, STYLE_POPUP_TEXTURE_MARGIN, STYLE_POPUP_CONTENT_MARGIN))
	add_child(settings_panel)

	var layout := _make_popup_layout(settings_panel, MARGIN_SETTINGS_POPUP, GAP_SETTINGS_LAYOUT)
	var title_row := _make_popup_title_row(layout, "設定", _close_settings_popup, "Button_CloseSettings")
	layout.add_child(_make_volume_row("BGM", bgm_volume, _set_bgm_volume))
	layout.add_child(_make_volume_row("SFX", sfx_volume, _set_sfx_volume))
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _build_save_load_popup() -> void:
	save_load_panel = Control.new()
	save_load_panel.name = "SaveLoadPopup_CaseFiles"
	save_load_panel.visible = false
	_apply_anchors(save_load_panel, ANCHOR_SAVE_LOAD_POPUP)
	add_child(save_load_panel)

	# 近全螢幕的書房背景，讓卡片面板浮在場景上，呼應mockup構圖。
	var background := TextureRect.new()
	background.name = "Background_SaveLoadOffice"
	background.texture = load(BG_SAVE_LOAD_OFFICE)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	save_load_panel.add_child(background)

	var card := PanelContainer.new()
	card.name = "CardPanel_SaveLoadMain"
	_apply_anchors(card, ANCHOR_SAVE_LOAD_CARD)
	card.add_theme_stylebox_override("panel", _make_texture_style(PANEL_SAVE_LOAD_MAIN, STYLE_SAVE_LOAD_TEXTURE_MARGIN, STYLE_SAVE_LOAD_CONTENT_MARGIN))
	save_load_panel.add_child(card)

	var layout := _make_popup_layout(card, MARGIN_SAVE_LOAD_POPUP, GAP_SAVE_LOAD_POPUP_LAYOUT)
	_make_close_only_row(layout, _close_save_load_popup, "Button_CloseSaveLoad")

	var center_container := CenterContainer.new()
	center_container.name = "GridCenterContainer"
	center_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(center_container)

	var grid := GridContainer.new()
	grid.name = "SaveLoadSlotGrid"
	grid.columns = SAVE_LOAD_GRID_COLUMNS
	grid.add_theme_constant_override("h_separation", GAP_SAVE_LOAD_GRID_H)
	grid.add_theme_constant_override("v_separation", GAP_SAVE_LOAD_GRID_V)
	center_container.add_child(grid)

	save_load_slot_buttons.clear()
	save_load_selection_frames.clear()
	var slot_index := 0
	for slot_data in SAVE_LOAD_SLOT_DATA:
		grid.add_child(_make_save_load_slot(slot_index, slot_data))
		slot_index += 1

	_refresh_save_load_grid()


func _make_save_load_slot(slot_index: int, slot_data: Dictionary) -> Control:
	var slot_root := Control.new()
	slot_root.name = "SaveLoadSlot_%02d" % slot_index
	slot_root.custom_minimum_size = SAVE_LOAD_SLOT_SIZE
	slot_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot_root.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var is_saved: bool = slot_data["state"] == SAVE_LOAD_STATE_SAVED

	# 選取高亮框：現在疊在格子底圖（檔案紙張）之下，好讓發光效果從紙張後面透出來。
	# 同時為了對齊紙張實際大小（底圖左右有透明留白，而高亮框沒有），高亮框寬度要縮小、高度要拉高。
	var selection_frame := TextureRect.new()
	selection_frame.name = "SelectionFrame"
	selection_frame.texture = load(SAVE_LOAD_SLOT_SELECTED_FRAME)
	selection_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	selection_frame.stretch_mode = TextureRect.STRETCH_SCALE
	selection_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_frame.visible = false
	# 經過精確圖像分析計算，以使 833x771 大小之高亮框（發光區域 x:72~763, y:55~705）
	# 能完美對應並包裹對齊 1080x810 卡片中的紙張邊緣：
	# - 已存檔格子（紙張 x:218~909, y:28~765）：左 0.135, 右 0.906, 上 -0.042, 下 1.037
	# - 空白格子（紙張 x:206~897, y:49~720）：左 0.124, 右 0.895, 上 -0.010, 下 0.973
	if is_saved:
		selection_frame.anchor_left = 0.135
		selection_frame.anchor_right = 0.906
		selection_frame.anchor_top = -0.042
		selection_frame.anchor_bottom = 1.037
	else:
		selection_frame.anchor_left = 0.124
		selection_frame.anchor_right = 0.895
		selection_frame.anchor_top = -0.010
		selection_frame.anchor_bottom = 0.973
	selection_frame.offset_left = 0
	selection_frame.offset_top = 0
	selection_frame.offset_right = 0
	selection_frame.offset_bottom = 0
	slot_root.add_child(selection_frame)
	save_load_selection_frames.append(selection_frame)

	var button := TextureButton.new()
	button.name = "Button_Slot"
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
	button.focus_mode = Control.FOCUS_NONE
	button.texture_normal = load(SAVE_LOAD_SLOT_SAVED if is_saved else SAVE_LOAD_SLOT_EMPTY)
	button.pressed.connect(_on_save_load_slot_pressed.bind(slot_index))
	slot_root.add_child(button)
	save_load_slot_buttons.append(button)

	# 建立頂部標題 Label
	var title_label := Label.new()
	title_label.name = "TitleLabel"
	title_label.text = ("案件檔案 %02d" % (slot_index + 1)) if is_saved else SAVE_LOAD_LABEL_EMPTY
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_label_style(title_label, FONT_SAVE_LOAD_SLOT_TITLE, COLOR_TEXT_MAIN, COLOR_SHADOW_SOFT, SHADOW_OFFSET_SMALL)
	
	if is_saved:
		title_label.anchor_left = 0.11
		title_label.anchor_right = 0.91
	else:
		title_label.anchor_left = 0.1
		title_label.anchor_right = 0.9

	# 稍微再下移一點（由原先的 0.12~0.22 改為 0.15~0.25），避開紙張頂端的迴紋針裝飾，使文字更加美觀
	title_label.anchor_top = 0.15
	title_label.anchor_bottom = 0.25
	slot_root.add_child(title_label)

	if is_saved:
		# 解析 location 欄位以拆分地點與狀態（例如將 "白塔街偵探所 / 調查中" 拆分）
		var location_str: String = slot_data.get("location", "")
		var loc_parts := location_str.split(" / ")
		var loc_text := loc_parts[0] if loc_parts.size() > 0 else ""
		var status_text := loc_parts[1] if loc_parts.size() > 1 else "調查中"

		var chapter_label := Label.new()
		chapter_label.name = "ChapterLabel"
		chapter_label.text = slot_data.get("chapter", "")
		chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		chapter_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		chapter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_apply_label_style(chapter_label, FONT_SAVE_LOAD_SLOT_CHAPTER, COLOR_TEXT_MAIN, COLOR_SHADOW_SOFT, SHADOW_OFFSET_SMALL)
		chapter_label.anchor_left = 0.33
		chapter_label.anchor_right = 0.9
		chapter_label.anchor_top = 0.52
		chapter_label.anchor_bottom = 0.61
		slot_root.add_child(chapter_label)

		var location_label := Label.new()
		location_label.name = "LocationLabel"
		location_label.text = loc_text
		location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		location_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		location_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_apply_label_style(location_label, FONT_SAVE_LOAD_SLOT_LOCATION, COLOR_TEXT_MAIN, COLOR_SHADOW_SOFT, SHADOW_OFFSET_SMALL)
		location_label.anchor_left = 0.33
		location_label.anchor_right = 0.9
		location_label.anchor_top = 0.61
		location_label.anchor_bottom = 0.69
		slot_root.add_child(location_label)

		var status_label := Label.new()
		status_label.name = "StatusLabel"
		status_label.text = status_text
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		status_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_apply_label_style(status_label, FONT_SAVE_LOAD_SLOT_LOCATION, COLOR_ACCENT_GREEN, COLOR_SHADOW_SOFT, SHADOW_OFFSET_SMALL)
		status_label.anchor_left = 0.33
		status_label.anchor_right = 0.9
		status_label.anchor_top = 0.69
		status_label.anchor_bottom = 0.77
		slot_root.add_child(status_label)

	return slot_root


func _build_dialogue_log_popup() -> void:
	dialogue_log_panel = Control.new()
	dialogue_log_panel.name = "DialogueLogPopup"
	dialogue_log_panel.visible = false
	_apply_anchors(dialogue_log_panel, ANCHOR_SAVE_LOAD_POPUP)
	add_child(dialogue_log_panel)

	# 全螢幕書房背景
	var background := TextureRect.new()
	background.name = "Background_LogOffice"
	background.texture = load(BG_SAVE_LOAD_OFFICE)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_log_panel.add_child(background)

	# 大面板外框，與存讀檔面板一模一樣
	var card := PanelContainer.new()
	card.name = "CardPanel_LogMain"
	_apply_anchors(card, ANCHOR_SAVE_LOAD_CARD)
	card.add_theme_stylebox_override("panel", _make_texture_style(PANEL_SAVE_LOAD_MAIN, STYLE_SAVE_LOAD_TEXTURE_MARGIN, STYLE_SAVE_LOAD_CONTENT_MARGIN))
	dialogue_log_panel.add_child(card)

	# 主邊距容器 (左右邊距設為 156，以在 card 的 content_margin (18) 基礎上，等比例對齊 174px 的金屬邊框內緣磨砂面板，避免 entries 蓋在金屬框上)
	var main_margin := MarginContainer.new()
	main_margin.name = "LogMainMargin"
	main_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# 左右設為 156 (累加 content_margin 的 18px 後恰好等於 174px 金屬邊框內緣)，上下設為原先的 MARGIN_LOG_POPUP.y (30) 與 MARGIN_LOG_POPUP.w (30)
	_apply_margins(main_margin, Vector4(156, MARGIN_LOG_POPUP.y, 156, MARGIN_LOG_POPUP.w))
	card.add_child(main_margin)

	var main_layout := VBoxContainer.new()
	main_layout.name = "LogMainLayout"
	main_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_layout.add_theme_constant_override("separation", GAP_SAVE_LOAD_POPUP_LAYOUT)
	main_margin.add_child(main_layout)

	# 標題列需要左右 156px 的邊距，以與列表在同一垂直線上對齊金屬邊框內緣
	var title_margin := MarginContainer.new()
	title_margin.name = "LogTitleMargin"
	title_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_margins(title_margin, Vector4(156, 0, 156, 0))
	main_layout.add_child(title_margin)

	var title_row := HBoxContainer.new()
	title_row.name = "LogTitleRow"
	title_row.add_theme_constant_override("separation", GAP_TITLE_ROW)
	title_margin.add_child(title_row)

	var title := Label.new()
	title.name = "LogTitleLabel"
	title.text = "調查紀錄"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_label_style(title, FONT_POPUP_TITLE, COLOR_TEXT_MAIN)
	title_row.add_child(title)

	# 獨立的關閉按鈕直接放在 dialogue_log_panel 全螢幕 Control 下，以 ANCHOR_SAVE_LOAD_CARD 比例的右上角為基準進行絕對定位，避免加在 PanelContainer (card) 底下時被強制拉伸成全螢幕大小
	var close_button := _make_small_popup_button("×")
	close_button.name = "Button_CloseDialogueLog"
	close_button.add_theme_font_size_override("font_size", FONT_POPUP_CLOSE)
	close_button.pressed.connect(_close_dialogue_log_popup)
	close_button.anchor_left = ANCHOR_SAVE_LOAD_CARD.z # 0.94
	close_button.anchor_top = ANCHOR_SAVE_LOAD_CARD.y  # 0.06
	close_button.anchor_right = ANCHOR_SAVE_LOAD_CARD.z
	close_button.anchor_bottom = ANCHOR_SAVE_LOAD_CARD.y
	close_button.custom_minimum_size = POPUP_CLOSE_BUTTON_SIZE
	# 由於基準點對齊了卡片右上角比例 (1805, 65)，我們設定偏移量使其往右上微調，懸浮於金屬框外側
	close_button.offset_left = -120
	close_button.offset_top = 10
	close_button.offset_right = -56
	close_button.offset_bottom = 66
	dialogue_log_panel.add_child(close_button)

	# 為列表容器包裹一層邊距，將其頂部向下推，使其距離標題列更遠更美觀
	var scroll_margin := MarginContainer.new()
	scroll_margin.name = "LogScrollMargin"
	scroll_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_margins(scroll_margin, Vector4(0, 24, 0, 0))
	main_layout.add_child(scroll_margin)

	var scroll := ScrollContainer.new()
	scroll.name = "LogScrollContainer"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(100, 0)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_margin.add_child(scroll)

	var entries := VBoxContainer.new()
	entries.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entries.custom_minimum_size = Vector2(100, 0)
	entries.add_theme_constant_override("separation", GAP_LOG_ENTRIES)
	scroll.add_child(entries)

	# 藉由連動 ScrollContainer 的 resized 訊號動態將 entries 的寬度限制在其寬度之內（扣除捲軸裕量 24px），
	# 徹底避免 Godot ScrollContainer 子節點在自動折行時無法自適應縮小而撐大/溢出左右邊界的問題。
	scroll.resized.connect(func(): entries.custom_minimum_size.x = scroll.size.x - 24)

	for line in DIALOGUE_LINES:
		entries.add_child(_make_dialogue_log_entry(line))


# ------------------------------
# 輸入處理區：玩家操作
# ------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_set_auto_advance_enabled(false)
		_next_line()

	if event.is_action_pressed("ui_accept"):
		_set_auto_advance_enabled(false)
		_next_line()


func _connect_top_menu_button(button: BaseButton, menu_index: int) -> void:
	if menu_index == 0:
		button.pressed.connect(_open_save_popup)
	elif menu_index == 1:
		button.pressed.connect(_open_load_popup)
	elif menu_index == 2:
		button.pressed.connect(_open_settings_popup)
	elif menu_index == 3:
		button.pressed.connect(_open_dialogue_log_popup)
	elif menu_index == 4:
		auto_button = button
		button.pressed.connect(_toggle_auto_advance)


func _toggle_objective_panel() -> void:
	_set_objective_panel_collapsed(not objective_panel_collapsed)


func _set_objective_panel_collapsed(collapsed: bool) -> void:
	objective_panel_collapsed = collapsed
	# 收合/展開箭頭已經畫在標題列圖片裡，直接換整張圖即可。
	objective_header_button.texture_normal = load(PANEL_OBJECTIVE_HEADER_COLLAPSED if objective_panel_collapsed else PANEL_OBJECTIVE_HEADER_EXPANDED)
	objective_panel.visible = not objective_panel_collapsed


# ------------------------------
# 彈窗互動區：互斥顯示
# ------------------------------
func _open_settings_popup() -> void:
	_hide_all_popups()
	settings_panel.visible = true


func _close_settings_popup() -> void:
	settings_panel.visible = false


func _open_save_popup() -> void:
	_hide_all_popups()
	save_load_mode = SAVE_LOAD_MODE_SAVE
	_refresh_save_load_grid()
	save_load_panel.visible = true


func _open_load_popup() -> void:
	_hide_all_popups()
	save_load_mode = SAVE_LOAD_MODE_LOAD
	_refresh_save_load_grid()
	save_load_panel.visible = true


func _close_save_load_popup() -> void:
	save_load_panel.visible = false


# 讀取模式下空白格不可點擊（避免讀到空資料）；保存模式下所有格子都可點。
func _refresh_save_load_grid() -> void:
	var slot_index := 0
	for slot_data in SAVE_LOAD_SLOT_DATA:
		var is_saved: bool = slot_data["state"] == SAVE_LOAD_STATE_SAVED
		var button := save_load_slot_buttons[slot_index]
		button.disabled = save_load_mode == SAVE_LOAD_MODE_LOAD and not is_saved
		save_load_selection_frames[slot_index].visible = slot_index == save_load_selected_index
		slot_index += 1


func _on_save_load_slot_pressed(slot_index: int) -> void:
	save_load_selected_index = slot_index
	var i := 0
	for frame in save_load_selection_frames:
		frame.visible = i == slot_index
		i += 1


func _open_dialogue_log_popup() -> void:
	_hide_all_popups()
	dialogue_log_panel.visible = true


func _close_dialogue_log_popup() -> void:
	dialogue_log_panel.visible = false


func _hide_all_popups() -> void:
	if settings_panel != null:
		settings_panel.visible = false
	if save_load_panel != null:
		save_load_panel.visible = false
	if dialogue_log_panel != null:
		dialogue_log_panel.visible = false


# ------------------------------
# 自動播放區
# ------------------------------
func _build_auto_advance_timer() -> void:
	auto_advance_timer = Timer.new()
	auto_advance_timer.name = "AutoAdvanceTimer"
	auto_advance_timer.wait_time = AUTO_ADVANCE_SECONDS
	auto_advance_timer.one_shot = false
	auto_advance_timer.timeout.connect(_on_auto_advance_timeout)
	add_child(auto_advance_timer)


func _toggle_auto_advance() -> void:
	_set_auto_advance_enabled(not auto_advance_enabled)


func _set_auto_advance_enabled(enabled: bool) -> void:
	auto_advance_enabled = enabled
	if auto_advance_timer == null:
		return

	if auto_advance_enabled:
		auto_advance_timer.start()
	else:
		auto_advance_timer.stop()

	if auto_button != null:
		auto_button.modulate = Color(COLOR_ACCENT_GREEN) if auto_advance_enabled else Color.WHITE


func _on_auto_advance_timeout() -> void:
	if auto_advance_enabled:
		_next_line()


# ------------------------------
# 對白播放區
# ------------------------------
func _show_line(index: int) -> void:
	var line: Dictionary = DIALOGUE_LINES[index]
	dialogue_label.text = line["text"]

	if line["type"] == "narration":
		name_plate.visible = false
	else:
		name_plate.visible = true
		name_label.text = line["speaker_name"]

	if line["type"] == "system":
		_mark_first_objective_done()


func _next_line() -> void:
	current_line_index += 1

	if current_line_index >= DIALOGUE_LINES.size():
		current_line_index = 0

	_show_line(current_line_index)


func _mark_first_objective_done() -> void:
	if objective_list.get_child_count() < 1:
		return

	var first_row := objective_list.get_child(0) as HBoxContainer
	var icon := first_row.get_node("ObjectiveIcon") as Label
	var text := first_row.get_node("ObjectiveText") as Label
	icon.text = "◆"
	text.add_theme_color_override("font_color", Color(COLOR_ACCENT_GREEN))


# ------------------------------
# 設定值更新區
# ------------------------------
func _set_bgm_volume(value: float) -> void:
	bgm_volume = value


func _set_sfx_volume(value: float) -> void:
	sfx_volume = value


# ------------------------------
# 共用輔助函式區：節點樣式與小型 UI 工廠
# ------------------------------
func _make_top_menu_button(label_text: String, button_key: String) -> BaseButton:
	# 改回單一TextureButton：直接用各狀態裁切後的原始貼圖（沒有額外
	# 放大留白），按鈕框大小貼合圖示本身比例，避免鄰居按鈕互相疊到。
	var button := TextureButton.new()
	button.name = "Button_%s" % label_text
	button.tooltip_text = label_text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = MENU_BUTTON_SIZE
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.texture_normal = load(UI_SKIN_DIR + "button_top_" + button_key + TOP_MENU_BUTTON_SUFFIX_NORMAL)
	button.texture_hover = load(UI_SKIN_DIR + "button_top_" + button_key + TOP_MENU_BUTTON_SUFFIX_HOVER)
	button.texture_pressed = load(UI_SKIN_DIR + "button_top_" + button_key + TOP_MENU_BUTTON_SUFFIX_PRESSED)
	return button


func _make_small_popup_button(button_text: String) -> Button:
	return _make_framed_button(button_text, POPUP_CLOSE_BUTTON_SIZE, FONT_POPUP_BUTTON, STYLE_SMALL_BUTTON_TEXTURE_MARGIN, STYLE_SMALL_BUTTON_CONTENT_MARGIN)


func _make_framed_button(button_text: String, min_size: Vector2, font_size: int, texture_margin: int, content_margin: int) -> Button:
	var button := Button.new()
	var custom_font = load("res://assets/fonts/NotoSerifTC[wght].ttf")
	if custom_font:
		button.add_theme_font_override("font", custom_font)
	button.text = button_text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = min_size
	button.add_theme_stylebox_override("normal", _make_texture_style(BUTTON_NORMAL, texture_margin, content_margin))
	button.add_theme_stylebox_override("hover", _make_texture_style(BUTTON_HOVER, texture_margin, content_margin))
	button.add_theme_stylebox_override("pressed", _make_texture_style(BUTTON_PRESSED, texture_margin, content_margin))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", Color(COLOR_TEXT_MAIN))
	button.add_theme_color_override("font_hover_color", Color(COLOR_TEXT_WHITE))
	button.add_theme_color_override("font_pressed_color", Color(COLOR_ACCENT_GREEN))
	button.add_theme_font_size_override("font_size", font_size)
	return button


func _make_popup_layout(parent: PanelContainer, margins: Vector4, separation: int) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_margins(margin, margins)
	parent.add_child(margin)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", separation)
	margin.add_child(layout)
	return layout


func _make_popup_title_row(layout: VBoxContainer, title_text: String, close_callback: Callable, close_button_name: String) -> HBoxContainer:
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", GAP_TITLE_ROW)
	layout.add_child(title_row)

	var title := Label.new()
	title.text = title_text
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_label_style(title, FONT_POPUP_TITLE, COLOR_TEXT_MAIN)
	title_row.add_child(title)

	var close_button := _make_small_popup_button("×")
	close_button.name = close_button_name
	close_button.add_theme_font_size_override("font_size", FONT_POPUP_CLOSE)
	close_button.pressed.connect(close_callback)
	title_row.add_child(close_button)
	return title_row


# 存讀檔卡片不需要標題文字（mockup的「保存調查/讀取檔案」是外部觸發鈕，
# 不是面板內文字），只留右上角關閉鈕讓玩家可以離開面板。
func _make_close_only_row(layout: VBoxContainer, close_callback: Callable, close_button_name: String) -> HBoxContainer:
	var close_row := HBoxContainer.new()
	close_row.alignment = BoxContainer.ALIGNMENT_END
	layout.add_child(close_row)

	var close_button := _make_small_popup_button("×")
	close_button.name = close_button_name
	close_button.add_theme_font_size_override("font_size", FONT_POPUP_CLOSE)
	close_button.pressed.connect(close_callback)
	close_row.add_child(close_button)
	return close_row


func _make_volume_row(label_text: String, value: float, changed_callback: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", GAP_VOLUME_ROW)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = VOLUME_LABEL_SIZE
	_apply_label_style(label, FONT_VOLUME_LABEL, COLOR_TEXT_MAIN)
	row.add_child(label)

	var slider := HSlider.new()
	slider.min_value = SLIDER_MIN_VALUE
	slider.max_value = SLIDER_MAX_VALUE
	slider.step = SLIDER_STEP
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(changed_callback)
	row.add_child(slider)
	return row


func _make_dialogue_log_entry(line: Dictionary) -> PanelContainer:
	var entry := PanelContainer.new()
	entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entry.custom_minimum_size = Vector2(100, 0)
	entry.add_theme_stylebox_override("panel", _make_flat_panel_style("#141816d0", "#c9d3c633", 1, 4))

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.custom_minimum_size = Vector2(100, 0)
	_apply_margins(margin, MARGIN_LOG_ENTRY)
	entry.add_child(margin)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.custom_minimum_size = Vector2(100, 0)
	layout.add_theme_constant_override("separation", GAP_LOG_ENTRY_TEXT)
	margin.add_child(layout)

	var speaker := Label.new()
	speaker.text = line["speaker_name"] if line.has("speaker_name") else "旁白"
	speaker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_label_style(speaker, FONT_LOG_SPEAKER, COLOR_ACCENT_GREEN)
	layout.add_child(speaker)

	var text := Label.new()
	text.text = line["text"]
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.custom_minimum_size = Vector2(100, 0) # 避免 Label 最小寬度撐爆 ScrollContainer 邊界，迫使其在容器實際寬度內換行
	_apply_label_style(text, FONT_LOG_TEXT, COLOR_TEXT_BRIGHT)
	layout.add_child(text)
	return entry


func _make_detail_line(line_color: String) -> ColorRect:
	var line := ColorRect.new()
	line.color = Color(line_color)
	line.custom_minimum_size = Vector2(0, DECORATIVE_LINE_HEIGHT)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line


func _apply_anchors(control: Control, anchors: Vector4) -> void:
	control.anchor_left = anchors.x
	control.anchor_top = anchors.y
	control.anchor_right = anchors.z
	control.anchor_bottom = anchors.w
	control.offset_left = 0
	control.offset_top = 0
	control.offset_right = 0
	control.offset_bottom = 0


func _apply_margins(margin: MarginContainer, margins: Vector4) -> void:
	margin.add_theme_constant_override("margin_left", int(margins.x))
	margin.add_theme_constant_override("margin_top", int(margins.y))
	margin.add_theme_constant_override("margin_right", int(margins.z))
	margin.add_theme_constant_override("margin_bottom", int(margins.w))


func _apply_label_style(label: Label, font_size: int, font_color: String, shadow_color := "", shadow_offset := Vector2.ZERO) -> void:
	# 載入優雅的中文明體/宋體字型資產
	var custom_font = load("res://assets/fonts/NotoSerifTC[wght].ttf")
	if custom_font:
		label.add_theme_font_override("font", custom_font)
	label.add_theme_color_override("font_color", Color(font_color))
	label.add_theme_font_size_override("font_size", font_size)
	if shadow_color != "":
		label.add_theme_color_override("font_shadow_color", Color(shadow_color))
		label.add_theme_constant_override("shadow_offset_x", int(shadow_offset.x))
		label.add_theme_constant_override("shadow_offset_y", int(shadow_offset.y))


# 純色+細邊框面板（沒有對應圖片資產時使用），例如案件目標詳細內容框。
func _make_flat_panel_style(bg_color: String, border_color: String, border_width: int, corner_radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg_color)
	style.border_color = Color(border_color)
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	return style


func _make_texture_style(path: String, texture_margin: int, content_margin: int) -> StyleBoxTexture:
	return _make_texture_style_hv(path, texture_margin, texture_margin, content_margin)


# 左右、上下邊距分開設定：像姓名牌這種「兩側尖角+寶石、上下只是薄邊框」
# 的造型，左右需要很大的邊距才能完整保住尖角不被拉伸，但上下邊距太大
# 反而會超過框高、互相擠壞，所以不能用同一個數字套四邊。
func _make_texture_style_hv(path: String, margin_h: int, margin_v: int, content_margin: int) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = load(path)
	style.set_texture_margin(SIDE_LEFT, margin_h)
	style.set_texture_margin(SIDE_RIGHT, margin_h)
	style.set_texture_margin(SIDE_TOP, margin_v)
	style.set_texture_margin(SIDE_BOTTOM, margin_v)
	style.set_content_margin(SIDE_LEFT, content_margin)
	style.set_content_margin(SIDE_TOP, content_margin)
	style.set_content_margin(SIDE_RIGHT, content_margin)
	style.set_content_margin(SIDE_BOTTOM, content_margin)
	style.draw_center = true
	return style
