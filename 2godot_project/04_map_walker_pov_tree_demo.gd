extends Control

# ------------------------------
# 零件說明：
# 這是 Map Walker 2D 走查系統的第2個零件 demo（v0.2規劃的「兩層熱點」結構），
# 規劃內容見2godot_project/readme.md「Map Walker v0.2規劃」。驗證重點：
#   - 主背景（大地圖）上的放大鏡熱點只負責「換視角」，點下去切換成對應的
#     子背景（D1九宮格第2/3/4/5/8格的正式素材），不直接顯示調查結果。
#   - 子背景上才有「真正調查」的熱點，依type分三種行為：
#     door（門）→ 真的切換到下一個場景背景（D2/D3的正式背景）；
#     npc（人物所在區域）→ 彈出多句占位對話，模擬之後會接Story Dialogue UI
#     播放的多句序列（非單行特寫卡）；
#     collectible（收藏品）→ 彈簡短「已收藏」提示，呼應莉莉的M編號收藏癖。
# 占位用熱點全部用無意義占位文字，不放案件1真實NPC/地點名稱（依嚴格規則4）。
# ------------------------------

# ------------------------------
# 設定區：資產路徑
# ------------------------------
const UI_SKIN_DIR := "res://assets/ui/map_walker/"
const ICON_MAGNIFIER_NORMAL := UI_SKIN_DIR + "icon_magnifier_normal.png"
const ICON_MAGNIFIER_HOVER := UI_SKIN_DIR + "icon_magnifier_hover.png"

const BG_MAIN := UI_SKIN_DIR + "bg_exhibition_hall_main_d1.png"
const BG_POV_2 := UI_SKIN_DIR + "bg_exhibition_hall_d1_pov_2.png"
const BG_POV_3 := UI_SKIN_DIR + "bg_exhibition_hall_d1_pov_3.png"
const BG_POV_4 := UI_SKIN_DIR + "bg_exhibition_hall_d1_pov_4.png"
const BG_POV_5 := UI_SKIN_DIR + "bg_exhibition_hall_d1_pov_5.png"
const BG_POV_8 := UI_SKIN_DIR + "bg_exhibition_hall_d1_pov_8.png"
# 門類子背景調查後會切到的「下一個場景」，先沿用案件1既有正式背景
# 素材本身（不算放真實案件線索資料，只是場景圖片資產），驗證真的能轉場。
const BG_NEXT_SCENE_A := UI_SKIN_DIR + "bg_exhibition_hall_d2_negotiation_room.png"
const BG_NEXT_SCENE_B := UI_SKIN_DIR + "bg_exhibition_hall_d3_side_door.png"

# ------------------------------
# 設定區：色彩與字級（沿用0mockup/ui_style_guide_v0.1.md定義的色票，
# 跟02/03demo保持一致，避免零件之間視覺風格分裂）
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
const FONT_BREADCRUMB := 18
const FONT_BACK_BUTTON := 18
const FONT_DIALOGUE_TITLE := 24
const FONT_DIALOGUE_LINE := 20
const FONT_TOAST_TEXT := 20

# ------------------------------
# 設定區：熱點外觀與版面
# ------------------------------
const HOTSPOT_ICON_SIZE := Vector2(56, 56)
const FADE_TRANSITION_SECONDS := 0.25

const ANCHOR_BREADCRUMB := Vector4(0.02, 0.02, 0.40, 0.07)
const ANCHOR_BACK_BUTTON := Vector4(0.02, 0.09, 0.16, 0.15)

const ANCHOR_DIALOGUE_OVERLAY := Vector4(0.0, 0.0, 1.0, 1.0)
const ANCHOR_DIALOGUE_CARD := Vector4(0.26, 0.20, 0.74, 0.80)
const MARGIN_DIALOGUE_CARD := Vector4(36, 28, 36, 28)
const GAP_DIALOGUE_LAYOUT := 14

const ANCHOR_TOAST := Vector4(0.30, 0.84, 0.70, 0.93)
const TOAST_VISIBLE_SECONDS := 1.6
const TOAST_FADE_SECONDS := 0.4

const HOTSPOT_COLLECTED_ALPHA := 0.35

# ------------------------------
# 設定區：子背景投資調查類型（決定子背景上「真正調查」熱點的行為）
# ------------------------------
const INVESTIGATE_TYPE_DOOR := "door"
const INVESTIGATE_TYPE_NPC := "npc"
const INVESTIGATE_TYPE_COLLECTIBLE := "collectible"

# ------------------------------
# 設定區：原型測試資料（占位用熱點，依嚴格規則4不放真實案件線索/人名）
# ------------------------------
# 第一層：主背景上的「換視角」熱點，位置為相對於背景的比例座標 (0.0~1.0)。
const MAIN_VIEW_HOTSPOTS := [
	{"id": "pov_2", "pov_key": "pov_2", "position": Vector2(0.16, 0.48), "label": "區域 2（占位）"},
	{"id": "pov_3", "pov_key": "pov_3", "position": Vector2(0.84, 0.42), "label": "區域 3（占位）"},
	{"id": "pov_4", "pov_key": "pov_4", "position": Vector2(0.46, 0.60), "label": "區域 4（占位）"},
	{"id": "pov_5", "pov_key": "pov_5", "position": Vector2(0.70, 0.34), "label": "區域 5（占位）"},
	{"id": "pov_8", "pov_key": "pov_8", "position": Vector2(0.86, 0.66), "label": "區域 8（占位）"},
]

# 第二層：每個子背景對應的資料，包含子背景圖、麵包屑顯示文字，以及
# 「真正調查」熱點的位置/類型/內容。
const POV_DATA := {
	"pov_2": {
		"background": BG_POV_2,
		"breadcrumb": "目前位置：區域 2（占位）",
		"investigate_position": Vector2(0.5, 0.55),
		"investigate_type": INVESTIGATE_TYPE_NPC,
		"dialogue_title": "對話片段（占位）",
		"dialogue_lines": [
			{"speaker": "角色甲（占位）", "text": "苹果香蕉測試對白第一句：此處之後接Story Dialogue UI真實對話。"},
			{"speaker": "莉莉（占位）", "text": "苹果香蕉測試對白第二句：模擬玩家提問。"},
			{"speaker": "角色甲（占位）", "text": "苹果香蕉測試對白第三句：模擬NPC回應。"},
		],
	},
	"pov_3": {
		"background": BG_POV_3,
		"breadcrumb": "目前位置：區域 3（占位）",
		"investigate_position": Vector2(0.5, 0.55),
		"investigate_type": INVESTIGATE_TYPE_COLLECTIBLE,
		"toast_text": "已收藏：M-0XX（占位編號）",
	},
	"pov_4": {
		"background": BG_POV_4,
		"breadcrumb": "目前位置：區域 4（占位）",
		"investigate_position": Vector2(0.5, 0.55),
		"investigate_type": INVESTIGATE_TYPE_NPC,
		"dialogue_title": "對話片段（占位）",
		"dialogue_lines": [
			{"speaker": "角色乙（占位）", "text": "苹果香蕉測試對白第一句：此處之後接Story Dialogue UI真實對話。"},
			{"speaker": "蘇菲亞（占位）", "text": "苹果香蕉測試對白第二句：模擬旁觀者反應。"},
		],
	},
	"pov_5": {
		"background": BG_POV_5,
		"breadcrumb": "目前位置：區域 5（占位）",
		"investigate_position": Vector2(0.5, 0.55),
		"investigate_type": INVESTIGATE_TYPE_DOOR,
		"next_scene_background": BG_NEXT_SCENE_A,
		"next_scene_breadcrumb": "已切換場景：場景A（占位）",
	},
	"pov_8": {
		"background": BG_POV_8,
		"breadcrumb": "目前位置：區域 8（占位）",
		"investigate_position": Vector2(0.5, 0.55),
		"investigate_type": INVESTIGATE_TYPE_DOOR,
		"next_scene_background": BG_NEXT_SCENE_B,
		"next_scene_breadcrumb": "已切換場景：場景B（占位）",
	},
}

const VIEW_MAIN := "main"

# ------------------------------
# 狀態區：畫面節點與互動狀態
# ------------------------------
var background_rect: TextureRect
var breadcrumb_label: Label
var back_button: Button
var main_view_layer: Control
var pov_view_layer: Control
var dialogue_overlay: Control
var dialogue_title_label: Label
var dialogue_lines_container: VBoxContainer
var toast_panel: PanelContainer
var toast_label: Label
var toast_tween: Tween

var current_view := VIEW_MAIN
var collected_pov_ids: Dictionary = {}


# ------------------------------
# 建構區：進入點與主畫面
# ------------------------------
func _ready() -> void:
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_background()
	_build_breadcrumb_and_back_button()
	_build_main_view_layer()
	_build_pov_view_layer()
	_build_dialogue_overlay()
	_build_collectible_toast()
	_show_main_view()


func _build_background() -> void:
	background_rect = TextureRect.new()
	background_rect.name = "Background_Current"
	background_rect.texture = load(BG_MAIN)
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_rect)


func _build_breadcrumb_and_back_button() -> void:
	breadcrumb_label = Label.new()
	breadcrumb_label.name = "BreadcrumbLabel"
	breadcrumb_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_anchors(breadcrumb_label, ANCHOR_BREADCRUMB)
	_apply_label_style(breadcrumb_label, FONT_BREADCRUMB, COLOR_TEXT_BRIGHT, COLOR_SHADOW_SOFT)
	add_child(breadcrumb_label)

	back_button = Button.new()
	back_button.name = "Button_BackToMain"
	back_button.text = "← 返回大地圖"
	back_button.focus_mode = Control.FOCUS_NONE
	back_button.visible = false
	_apply_anchors(back_button, ANCHOR_BACK_BUTTON)
	_apply_label_style(back_button, FONT_BACK_BUTTON, COLOR_TEXT_MAIN)
	back_button.add_theme_color_override("font_hover_color", Color(COLOR_ACCENT_GREEN))
	back_button.pressed.connect(_show_main_view)
	add_child(back_button)


# ------------------------------
# 建構區：第一層（主背景換視角熱點）
# ------------------------------
func _build_main_view_layer() -> void:
	main_view_layer = Control.new()
	main_view_layer.name = "MainViewLayer"
	main_view_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_view_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(main_view_layer)

	for hotspot_data in MAIN_VIEW_HOTSPOTS:
		main_view_layer.add_child(_make_icon_hotspot(hotspot_data["position"], hotspot_data["label"], _on_pov_hotspot_pressed.bind(hotspot_data["pov_key"])))


func _on_pov_hotspot_pressed(pov_key: String) -> void:
	_show_pov_view(pov_key)


# ------------------------------
# 建構區：第二層（子背景真正調查熱點）
# ------------------------------
func _build_pov_view_layer() -> void:
	pov_view_layer = Control.new()
	pov_view_layer.name = "PovViewLayer"
	pov_view_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	pov_view_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pov_view_layer.visible = false
	add_child(pov_view_layer)


func _refresh_pov_investigate_hotspot(pov_key: String) -> void:
	for child in pov_view_layer.get_children():
		child.queue_free()

	var pov_info: Dictionary = POV_DATA[pov_key]
	var investigate_label := "調查"
	if collected_pov_ids.has(pov_key):
		investigate_label = "已調查（占位）"

	pov_view_layer.add_child(_make_icon_hotspot(pov_info["investigate_position"], investigate_label, _on_investigate_pressed.bind(pov_key)))


func _on_investigate_pressed(pov_key: String) -> void:
	var pov_info: Dictionary = POV_DATA[pov_key]
	match pov_info["investigate_type"]:
		INVESTIGATE_TYPE_DOOR:
			_show_next_scene(pov_info["next_scene_background"], pov_info["next_scene_breadcrumb"])
		INVESTIGATE_TYPE_NPC:
			_open_dialogue_overlay(pov_info["dialogue_title"], pov_info["dialogue_lines"])
		INVESTIGATE_TYPE_COLLECTIBLE:
			_collect_pov(pov_key, pov_info["toast_text"])


# ------------------------------
# 視角切換區：主背景 / 子背景 / 下一個場景
# ------------------------------
func _show_main_view() -> void:
	current_view = VIEW_MAIN
	_fade_background_to(load(BG_MAIN))
	breadcrumb_label.text = "目前位置：D1主展場大地圖（占位）"
	back_button.visible = false
	main_view_layer.visible = true
	pov_view_layer.visible = false


func _show_pov_view(pov_key: String) -> void:
	var pov_info: Dictionary = POV_DATA[pov_key]
	current_view = pov_key
	_fade_background_to(load(pov_info["background"]))
	breadcrumb_label.text = pov_info["breadcrumb"]
	back_button.visible = true
	main_view_layer.visible = false
	pov_view_layer.visible = true
	_refresh_pov_investigate_hotspot(pov_key)


func _show_next_scene(next_background_path: String, breadcrumb_text: String) -> void:
	current_view = ""
	_fade_background_to(load(next_background_path))
	breadcrumb_label.text = breadcrumb_text
	back_button.visible = true
	main_view_layer.visible = false
	pov_view_layer.visible = false


func _fade_background_to(new_texture: Texture2D) -> void:
	var tween := create_tween()
	tween.tween_property(background_rect, "modulate:a", 0.0, FADE_TRANSITION_SECONDS)
	tween.tween_callback(func() -> void:
		background_rect.texture = new_texture
	)
	tween.tween_property(background_rect, "modulate:a", 1.0, FADE_TRANSITION_SECONDS)


# ------------------------------
# 收藏品互動區
# ------------------------------
func _collect_pov(pov_key: String, toast_text: String) -> void:
	if collected_pov_ids.has(pov_key):
		return
	collected_pov_ids[pov_key] = true
	_refresh_pov_investigate_hotspot(pov_key)
	_show_collectible_toast(toast_text)


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
# 建構區：NPC占位多句對話彈窗
# ------------------------------
func _build_dialogue_overlay() -> void:
	dialogue_overlay = Control.new()
	dialogue_overlay.name = "DialogueOverlay"
	dialogue_overlay.visible = false
	_apply_anchors(dialogue_overlay, ANCHOR_DIALOGUE_OVERLAY)
	add_child(dialogue_overlay)

	var dim := ColorRect.new()
	dim.name = "DimBackground"
	dim.color = COLOR_OVERLAY_DIM
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dialogue_overlay.add_child(dim)

	var card := PanelContainer.new()
	card.name = "DialogueCard"
	_apply_anchors(card, ANCHOR_DIALOGUE_CARD)
	card.add_theme_stylebox_override("panel", _make_flat_panel_style(COLOR_PANEL_BG, COLOR_LINE_SILVER, 1, 6))
	dialogue_overlay.add_child(card)

	var margin := MarginContainer.new()
	_apply_margins(margin, MARGIN_DIALOGUE_CARD)
	card.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", GAP_DIALOGUE_LAYOUT)
	margin.add_child(layout)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", GAP_DIALOGUE_LAYOUT)
	layout.add_child(title_row)

	dialogue_title_label = Label.new()
	dialogue_title_label.name = "DialogueTitle"
	dialogue_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_label_style(dialogue_title_label, FONT_DIALOGUE_TITLE, COLOR_TEXT_MAIN)
	title_row.add_child(dialogue_title_label)

	var close_button := Button.new()
	close_button.name = "Button_CloseDialogue"
	close_button.text = "×"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_size_override("font_size", FONT_DIALOGUE_TITLE)
	close_button.add_theme_color_override("font_color", Color(COLOR_TEXT_MAIN))
	close_button.pressed.connect(_close_dialogue_overlay)
	title_row.add_child(close_button)

	var scroll := ScrollContainer.new()
	scroll.name = "DialogueScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)

	dialogue_lines_container = VBoxContainer.new()
	dialogue_lines_container.name = "DialogueLinesContainer"
	dialogue_lines_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue_lines_container.add_theme_constant_override("separation", GAP_DIALOGUE_LAYOUT)
	scroll.add_child(dialogue_lines_container)


func _open_dialogue_overlay(title_text: String, lines: Array) -> void:
	dialogue_title_label.text = title_text

	for child in dialogue_lines_container.get_children():
		child.queue_free()

	for line in lines:
		dialogue_lines_container.add_child(_make_dialogue_line(line["speaker"], line["text"]))

	dialogue_overlay.visible = true


func _close_dialogue_overlay() -> void:
	dialogue_overlay.visible = false


func _make_dialogue_line(speaker_text: String, body_text: String) -> VBoxContainer:
	var line_layout := VBoxContainer.new()
	line_layout.add_theme_constant_override("separation", 2)

	var speaker_label := Label.new()
	speaker_label.text = speaker_text
	_apply_label_style(speaker_label, FONT_DIALOGUE_LINE, COLOR_ACCENT_GREEN)
	line_layout.add_child(speaker_label)

	var body_label := Label.new()
	body_label.text = body_text
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_apply_label_style(body_label, FONT_DIALOGUE_LINE, COLOR_TEXT_MUTED)
	line_layout.add_child(body_label)

	return line_layout


# ------------------------------
# 輸入處理區：玩家操作
# ------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if dialogue_overlay != null and dialogue_overlay.visible and event.is_action_pressed("ui_cancel"):
		_close_dialogue_overlay()


# ------------------------------
# 共用輔助函式區
# ------------------------------
func _make_icon_hotspot(position_ratio: Vector2, label_text: String, on_pressed: Callable) -> Control:
	var hotspot_root := Control.new()
	hotspot_root.name = "Hotspot_%s" % label_text
	hotspot_root.anchor_left = position_ratio.x
	hotspot_root.anchor_top = position_ratio.y
	hotspot_root.anchor_right = position_ratio.x
	hotspot_root.anchor_bottom = position_ratio.y
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
	button.pressed.connect(on_pressed)
	hotspot_root.add_child(button)

	var label := Label.new()
	label.name = "Label_Hotspot"
	label.text = label_text
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


func _apply_label_style(label: Control, font_size: int, font_color: String, shadow_color := "") -> void:
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
