extends Control

# ------------------------------
# 零件說明：
# 這是「UI調校工具」(05_ui_tweaker_tool.*) 的獨立測試場景。放3個假的UI
# 元素（一個按鈕、兩個面板）讓調校工具掃描，驗證：
#   1. 下拉選單能列出畫面上的Control節點。
#   2. SpinBox調整Position/Size/Scale時，畫面上的元素會即時跟著變。
#   3. 拖拽模式可以用滑鼠直接拖動選中的元素。
#   4. 「複製參數」按鈕能正確把數值寫進系統剪貼簿。
# 跟正式UI零件（02/03/04）完全無關，純粹驗證調校工具本身可用。
# ------------------------------

const SAMPLE_BUTTON_POS := Vector2(120, 120)
const SAMPLE_BUTTON_SIZE := Vector2(160, 50)
const SAMPLE_PANEL_A_POS := Vector2(400, 200)
const SAMPLE_PANEL_A_SIZE := Vector2(200, 120)
const SAMPLE_PANEL_B_POS := Vector2(700, 350)
const SAMPLE_PANEL_B_SIZE := Vector2(180, 100)
const COLOR_PANEL_A := Color(0.2, 0.4, 0.3, 0.9)
const COLOR_PANEL_B := Color(0.4, 0.2, 0.25, 0.9)

const TWEAKER_TOOL_SCENE := "res://05_ui_tweaker_tool.tscn"


func _ready() -> void:
	_build_sample_button()
	_build_sample_panel("SamplePanelA", SAMPLE_PANEL_A_POS, SAMPLE_PANEL_A_SIZE, COLOR_PANEL_A)
	_build_sample_panel("SamplePanelB", SAMPLE_PANEL_B_POS, SAMPLE_PANEL_B_SIZE, COLOR_PANEL_B)
	_attach_tweaker_tool()


func _build_sample_button() -> void:
	var button := Button.new()
	button.name = "SampleButton"
	button.text = "假按鈕（拿來測試調校）"
	button.position = SAMPLE_BUTTON_POS
	button.size = SAMPLE_BUTTON_SIZE
	add_child(button)


func _build_sample_panel(node_name: String, pos: Vector2, size: Vector2, color: Color) -> void:
	var panel := Panel.new()
	panel.name = node_name
	panel.position = pos
	panel.size = size
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var label := Label.new()
	label.text = node_name
	label.position = Vector2(10, 10)
	panel.add_child(label)


func _attach_tweaker_tool() -> void:
	var tweaker_scene: PackedScene = load(TWEAKER_TOOL_SCENE)
	var tweaker := tweaker_scene.instantiate()
	add_child(tweaker)
