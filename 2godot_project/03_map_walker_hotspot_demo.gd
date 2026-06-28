extends Control

# ------------------------------
# 零件說明：
# 這是 Map Walker 2D 走查系統的第一個零件 demo，驗證「同一張大地圖上，
# 不同類型熱點分別觸發不同效果」這個機制：
#   - clue（關鍵線索）：點擊彈出特寫卡，之後會接案件目標更新。
#   - flavor（純風味/環境細節）：點擊彈出特寫卡，純氣氛用，不影響案件。
#   - collectible（收藏品，呼應莉莉的M-001、M-002…故障器具收藏癖）：
#     點擊只彈一個簡短的「已收藏」提示，完整收藏清單畫面是另一個獨立
#     零件（見0readme.md零件規劃表），這裡先不做。
# 不串接案件1真實線索內容，特寫卡內容全部是無意義占位文字（依嚴格規則4）。
# ------------------------------

# ------------------------------
# 設定區：資產路徑
# ------------------------------
const UI_SKIN_DIR := "res://assets/ui/map_walker/"
const BG_EXHIBITION_HALL := UI_SKIN_DIR + "bg_exhibition_hall_main_d1.png"
const ICON_MAGNIFIER_NORMAL := UI_SKIN_DIR + "icon_magnifier_normal.png"
const ICON_MAGNIFIER_HOVER := UI_SKIN_DIR + "icon_magnifier_hover.png"

# ------------------------------
# 設定區：色彩與字級（沿用0mockup/ui_style_guide_v0.1.md定義的色票，
# 跟02_story_dialogue_ui_demo.gd保持一致，避免兩個零件視覺風格分裂）
# ------------------------------
const COLOR_TEXT_MAIN := "#f0eadb"
const COLOR_TEXT_BRIGHT := "#f7f1e4"
const COLOR_TEXT_MUTED := "#c9c2ae"
const COLOR_ACCENT_GREEN := "#bde8cc"
const COLOR_LINE_SILVER := "#c9d3c6aa"
const COLOR_LINE_GOLD := "#b8a06d9a"
const COLOR_PANEL_BG := "#10231fcc"
const COLOR_SHADOW_SOFT := "#000000a8"
const COLOR_OVERLAY_DIM := Color(0.0, 0.0, 0.0, 0.55)

const FONT_HOTSPOT_LABEL := 16
const FONT_CLOSEUP_TITLE := 26
const FONT_CLOSEUP_BODY := 20
const FONT_CLOSEUP_CLOSE := 30
const FONT_TOAST_TEXT := 20

# ------------------------------
# 設定區：熱點外觀與版面
# ------------------------------
const HOTSPOT_ICON_SIZE := Vector2(56, 56)

const ANCHOR_CLOSEUP_OVERLAY := Vector4(0.0, 0.0, 1.0, 1.0)
const ANCHOR_CLOSEUP_CARD := Vector4(0.28, 0.16, 0.72, 0.84)
const MARGIN_CLOSEUP_CARD := Vector4(36, 28, 36, 28)
const GAP_CLOSEUP_LAYOUT := 18

# 收藏品提示Toast：短暫出現在畫面下方中央，跟對話框同一個垂直區段呼應。
const ANCHOR_TOAST := Vector4(0.30, 0.84, 0.70, 0.93)
const TOAST_VISIBLE_SECONDS := 1.6
const TOAST_FADE_SECONDS := 0.4

# 熱點被收藏/查看過後的淡化程度（modulate alpha）
const HOTSPOT_COLLECTED_ALPHA := 0.35

# ------------------------------
# 設定區：熱點類型（決定點擊後的行為）
# ------------------------------
const HOTSPOT_TYPE_CLUE := "clue"
const HOTSPOT_TYPE_FLAVOR := "flavor"
const HOTSPOT_TYPE_COLLECTIBLE := "collectible"

# ------------------------------
# 設定區：原型測試資料（占位用熱點，依嚴格規則4不放真實案件線索）
# 座標為相對於背景的比例位置 (0.0~1.0)，方便不同解析度下都對齊背景插畫。
# 對應case1_script_draft_v0.1.md場景③⑤的4個劇本熱點（洽談室門、側門、
# 塔克、席默）+ 1個收藏品熱點（呼應莉莉的M編號收藏癖），位置先用大致
# 比例占位，等D1九宮格第2/3/4/5/8格的正式特寫卡素材到位後再微調對齊。
# ------------------------------
const HOTSPOT_DATA := [
	{
		"id": "negotiation_room_door",
		"type": HOTSPOT_TYPE_CLUE,
		"position": Vector2(0.78, 0.40),
		"label": "洽談室門",
		"closeup_title": "洽談室門（占位）",
		"closeup_body": "苹果香蕉測試文字：此處之後接D1第5格正式特寫卡素材跟案件1真實線索，目前只驗證機制本身。"
	},
	{
		"id": "side_door",
		"type": HOTSPOT_TYPE_CLUE,
		"position": Vector2(0.88, 0.62),
		"label": "側門",
		"closeup_title": "側門（占位）",
		"closeup_body": "苹果香蕉測試文字：此處之後接D1第8格正式特寫卡素材跟案件1真實線索，目前只驗證機制本身。"
	},
	{
		"id": "npc_tucker",
		"type": HOTSPOT_TYPE_FLAVOR,
		"position": Vector2(0.16, 0.52),
		"label": "門衛塔克",
		"closeup_title": "門衛塔克（占位）",
		"closeup_body": "苹果香蕉測試文字：此處之後接D1第2格正式特寫卡素材跟NPC對話，目前只驗證機制本身。"
	},
	{
		"id": "npc_silmer",
		"type": HOTSPOT_TYPE_FLAVOR,
		"position": Vector2(0.46, 0.58),
		"label": "工匠席默",
		"closeup_title": "工匠席默（占位）",
		"closeup_body": "苹果香蕉測試文字：此處之後接D1第4格正式特寫卡素材跟NPC對話，目前只驗證機制本身。"
	},
	{
		"id": "collectible_curio",
		"type": HOTSPOT_TYPE_COLLECTIBLE,
		"position": Vector2(0.62, 0.66),
		"label": "不起眼的小物件",
		"collectible_name": "M-0XX（占位編號）",
		"toast_text": "已收藏：M-0XX（占位編號）"
	},
]

# ------------------------------
# 狀態區：畫面節點與互動狀態
# ------------------------------
var closeup_overlay: Control
var closeup_title_label: Label
var closeup_body_label: Label
var toast_panel: PanelContainer
var toast_label: Label
var toast_tween: Tween
var hotspot_buttons_by_id: Dictionary = {}
var collected_hotspot_ids: Dictionary = {}


# ------------------------------
# 建構區：進入點與主畫面
# ------------------------------
func _ready() -> void:
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_background()
	_build_hotspots()
	_build_closeup_popup()
	_build_collectible_toast()


func _build_background() -> void:
	var background := TextureRect.new()
	background.name = "Background_ExhibitionHallMain_D1"
	background.texture = load(BG_EXHIBITION_HALL)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)


# ------------------------------
# 建構區：可點擊熱點
# ------------------------------
func _build_hotspots() -> void:
	hotspot_buttons_by_id.clear()
	for hotspot_data in HOTSPOT_DATA:
		add_child(_make_hotspot(hotspot_data))


func _make_hotspot(hotspot_data: Dictionary) -> Control:
	var hotspot_root := Control.new()
	hotspot_root.name = "Hotspot_%s" % hotspot_data["id"]
	var pos: Vector2 = hotspot_data["position"]
	hotspot_root.anchor_left = pos.x
	hotspot_root.anchor_top = pos.y
	hotspot_root.anchor_right = pos.x
	hotspot_root.anchor_bottom = pos.y
	hotspot_root.offset_left = -HOTSPOT_ICON_SIZE.x / 2.0
	hotspot_root.offset_top = -HOTSPOT_ICON_SIZE.y / 2.0
	hotspot_root.offset_right = HOTSPOT_ICON_SIZE.x / 2.0
	hotspot_root.offset_bottom = HOTSPOT_ICON_SIZE.y / 2.0

	var button := TextureButton.new()
	button.name = "Button_Hotspot"
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.focus_mode = Control.FOCUS_NONE
	button.texture_normal = load(ICON_MAGNIFIER_NORMAL)
	button.texture_hover = load(ICON_MAGNIFIER_HOVER)
	button.pressed.connect(_on_hotspot_pressed.bind(hotspot_data))
	hotspot_root.add_child(button)
	hotspot_buttons_by_id[hotspot_data["id"]] = button

	var label := Label.new()
	label.name = "Label_Hotspot"
	label.text = hotspot_data["label"]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.anchor_left = 0.0
	label.anchor_right = 1.0
	label.anchor_top = 1.0
	label.anchor_bottom = 1.0
	label.offset_top = 4
	label.offset_bottom = 24
	_apply_label_style(label, FONT_HOTSPOT_LABEL, COLOR_TEXT_BRIGHT, COLOR_SHADOW_SOFT)
	hotspot_root.add_child(label)

	return hotspot_root


func _on_hotspot_pressed(hotspot_data: Dictionary) -> void:
	match hotspot_data["type"]:
		HOTSPOT_TYPE_COLLECTIBLE:
			_collect_hotspot(hotspot_data)
		_:
			_open_closeup_popup(hotspot_data)


# ------------------------------
# 收藏品互動區
# ------------------------------
func _collect_hotspot(hotspot_data: Dictionary) -> void:
	var hotspot_id: String = hotspot_data["id"]
	if collected_hotspot_ids.has(hotspot_id):
		return

	collected_hotspot_ids[hotspot_id] = true
	var button: TextureButton = hotspot_buttons_by_id.get(hotspot_id)
	if button != null:
		button.modulate.a = HOTSPOT_COLLECTED_ALPHA
		button.disabled = true

	_show_collectible_toast(hotspot_data["toast_text"])


func _build_collectible_toast() -> void:
	toast_panel = PanelContainer.new()
	toast_panel.name = "CollectibleToast"
	toast_panel.visible = false
	toast_panel.modulate.a = 0.0
	_apply_anchors(toast_panel, ANCHOR_TOAST)
	toast_panel.add_theme_stylebox_override("panel", _make_flat_panel_style(COLOR_PANEL_BG, COLOR_LINE_GOLD, 1, 6))
	add_child(toast_panel)

	var margin := MarginContainer.new()
	_apply_margins(margin, Vector4(20, 10, 20, 10))
	toast_panel.add_child(margin)

	toast_label = Label.new()
	toast_label.name = "ToastLabel"
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_label_style(toast_label, FONT_TOAST_TEXT, COLOR_ACCENT_GREEN)
	margin.add_child(toast_label)


func _show_collectible_toast(message: String) -> void:
	if toast_tween != null and toast_tween.is_valid():
		toast_tween.kill()

	toast_label.text = message
	toast_panel.visible = true
	toast_panel.modulate.a = 0.0

	toast_tween = create_tween()
	toast_tween.tween_property(toast_panel, "modulate:a", 1.0, TOAST_FADE_SECONDS)
	toast_tween.tween_interval(TOAST_VISIBLE_SECONDS)
	toast_tween.tween_property(toast_panel, "modulate:a", 0.0, TOAST_FADE_SECONDS)
	toast_tween.finished.connect(func() -> void:
		toast_panel.visible = false
	)


# ------------------------------
# 建構區：特寫卡彈窗（clue / flavor 共用）
# ------------------------------
func _build_closeup_popup() -> void:
	closeup_overlay = Control.new()
	closeup_overlay.name = "CloseupOverlay"
	closeup_overlay.visible = false
	_apply_anchors(closeup_overlay, ANCHOR_CLOSEUP_OVERLAY)
	add_child(closeup_overlay)

	var dim := ColorRect.new()
	dim.name = "DimBackground"
	dim.color = COLOR_OVERLAY_DIM
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	closeup_overlay.add_child(dim)

	var card := PanelContainer.new()
	card.name = "CloseupCard"
	_apply_anchors(card, ANCHOR_CLOSEUP_CARD)
	card.add_theme_stylebox_override("panel", _make_flat_panel_style(COLOR_PANEL_BG, COLOR_LINE_SILVER, 1, 6))
	closeup_overlay.add_child(card)

	var margin := MarginContainer.new()
	_apply_margins(margin, MARGIN_CLOSEUP_CARD)
	card.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", GAP_CLOSEUP_LAYOUT)
	margin.add_child(layout)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", GAP_CLOSEUP_LAYOUT)
	layout.add_child(title_row)

	closeup_title_label = Label.new()
	closeup_title_label.name = "CloseupTitle"
	closeup_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_label_style(closeup_title_label, FONT_CLOSEUP_TITLE, COLOR_TEXT_MAIN)
	title_row.add_child(closeup_title_label)

	var close_button := Button.new()
	close_button.name = "Button_CloseCloseup"
	close_button.text = "×"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_size_override("font_size", FONT_CLOSEUP_CLOSE)
	close_button.add_theme_color_override("font_color", Color(COLOR_TEXT_MAIN))
	close_button.pressed.connect(_close_closeup_popup)
	title_row.add_child(close_button)

	closeup_body_label = Label.new()
	closeup_body_label.name = "CloseupBody"
	closeup_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	closeup_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_label_style(closeup_body_label, FONT_CLOSEUP_BODY, COLOR_TEXT_MUTED)
	layout.add_child(closeup_body_label)


func _open_closeup_popup(hotspot_data: Dictionary) -> void:
	closeup_title_label.text = hotspot_data["closeup_title"]
	closeup_body_label.text = hotspot_data["closeup_body"]
	closeup_overlay.visible = true


func _close_closeup_popup() -> void:
	closeup_overlay.visible = false


# ------------------------------
# 輸入處理區：玩家操作
# ------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if closeup_overlay != null and closeup_overlay.visible and event.is_action_pressed("ui_cancel"):
		_close_closeup_popup()


# ------------------------------
# 共用輔助函式區
# ------------------------------
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


func _apply_label_style(label: Label, font_size: int, font_color: String, shadow_color := "") -> void:
	var custom_font = load("res://assets/fonts/NotoSerifTC[wght].ttf")
	if custom_font:
		label.add_theme_font_override("font", custom_font)
	label.add_theme_color_override("font_color", Color(font_color))
	label.add_theme_font_size_override("font_size", font_size)
	if shadow_color != "":
		label.add_theme_color_override("font_shadow_color", Color(shadow_color))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)


func _make_flat_panel_style(bg_color: String, border_color: String, border_width: int, corner_radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg_color)
	style.border_color = Color(border_color)
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	return style
