extends CanvasLayer

# ------------------------------
# 零件說明：
# 這是「UI 運行時調校工具」零件：解決Vibe Coding寫死座標/大小數值，
# 沒辦法用滑鼠拖拉所見即所得調整的痛點。把這個零件的scene實例化成
# 任何畫面的子節點後，執行遊戲時畫面右側會多一個調校面板：
#   1. 用下拉選單選擇場景裡任何一個Control節點。
#   2. 用SpinBox直接輸入/微調該節點的Position／Size／Scale，
#      畫面即時更新（所見即所得）。
#   3. 開啟「拖拽模式」後可以直接用滑鼠拖動選中的節點。
#   4. 按「複製參數」把目前數值格式化成GDScript常數寫法，複製到
#      系統剪貼簿，方便直接貼回對應零件的程式碼設定區。
#   5. 調校面板自己的標題列可以拖動，面板本身的位置不固定在右上角。
#   6. 開啟「點選模式」後，直接在畫面上點想調校的元素即可選中，
#      不用在下拉選單裡找路徑。
# 掃描節點的時機延後兩個frame才執行：因為大部分零件的UI是在自己
# _ready()裡用程式碼動態建出來的，如果調校工具一載入就馬上掃描，
# 會比那些UI建立得更早，只掃到場景根節點本身。
# ------------------------------
# 這個零件只負責「調校＋輸出參數」，不負責真正把參數寫回任何.gd檔案，
# 也不會更動被調校節點以外的場景結構。
# ------------------------------

# ------------------------------
# 設定區：版面與字級常數
# ------------------------------
const PANEL_WIDTH := 280
const PANEL_MARGIN := 12
const ROW_HEIGHT := 28
const FONT_SIZE_LABEL := 14
const FONT_SIZE_TITLE := 16
const SPINBOX_STEP := 1.0
const SPINBOX_MIN := -4000.0
const SPINBOX_MAX := 4000.0
const SCALE_STEP := 0.01
const SCALE_MIN := 0.01
const SCALE_MAX := 10.0
const TITLE_BAR_HEIGHT := 26

# 調校面板色票，沿用0mockup/ui_style_guide_v0.1.md的深炭黑/銀框配色，
# 跟正式UI做出視覺區隔（暗酒紅標題），提醒這是debug工具不是正式畫面。
const COLOR_PANEL_BG := Color(0.07, 0.07, 0.08, 0.92)
const COLOR_BORDER := Color(0.79, 0.83, 0.78, 0.7)
const COLOR_TITLE := Color(0.65, 0.2, 0.22, 1.0)
const COLOR_TEXT := Color(0.94, 0.92, 0.86, 1.0)
const COLOR_DRAG_ON := Color(0.74, 0.91, 0.8, 1.0)

# ------------------------------
# 內部狀態
# ------------------------------
var _target_nodes: Array[Control] = []
var _selected_target: Control = null
var _drag_mode := false
var _is_dragging := false
var _drag_offset := Vector2.ZERO
var _is_panel_dragging := false
var _pick_mode := false
# 記錄每個節點第一次被掃描到時的原始Position/Size/Scale，方便誤改後一鍵還原。
var _original_transforms := {}

# ------------------------------
# 節點參照（_ready時建構）
# ------------------------------
var _option_button: OptionButton
var _spin_pos_x: SpinBox
var _spin_pos_y: SpinBox
var _spin_size_x: SpinBox
var _spin_size_y: SpinBox
var _spin_scale_x: SpinBox
var _spin_scale_y: SpinBox
var _drag_toggle_button: Button
var _pick_toggle_button: Button
var _status_label: Label
var _root_control: Control
var _panel: Panel

# ------------------------------
# 建構：組裝調校面板UI
# ------------------------------
func _ready() -> void:
	layer = 100
	_build_panel()
	# 等兩個frame，讓宿主場景自己_ready()裡動態建的UI都生成完才掃描。
	await get_tree().process_frame
	await get_tree().process_frame
	_rescan_targets()


func _build_panel() -> void:
	_root_control = Control.new()
	_root_control.name = "UiTweakerRoot"
	_root_control.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_root_control.position = Vector2(-PANEL_WIDTH - PANEL_MARGIN, PANEL_MARGIN)
	_root_control.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	add_child(_root_control)

	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = COLOR_PANEL_BG
	panel_style.border_color = COLOR_BORDER
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 10
	panel_style.content_margin_right = 10
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	_root_control.add_child(panel)
	_panel = panel

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	panel.add_child(vbox)
	# Panel本身不是Container，不會自動撐到符合內容大小，要手動跟著
	# VBoxContainer實際算出來的大小同步，否則點擊命中判定範圍會是錯的。
	vbox.resized.connect(_on_panel_vbox_resized.bind(vbox))

	var title_bar := Panel.new()
	title_bar.custom_minimum_size = Vector2(0, TITLE_BAR_HEIGHT)
	title_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	title_bar.gui_input.connect(_on_title_bar_gui_input)
	var title_bar_style := StyleBoxFlat.new()
	title_bar_style.bg_color = COLOR_BORDER
	title_bar_style.bg_color.a = 0.15
	title_bar.add_theme_stylebox_override("panel", title_bar_style)
	vbox.add_child(title_bar)

	var title := Label.new()
	title.text = "UI 調校工具（拖這列移動面板）"
	title.add_theme_font_size_override("font_size", FONT_SIZE_TITLE)
	title.add_theme_color_override("font_color", COLOR_TITLE)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_bar.add_child(title)

	_option_button = OptionButton.new()
	_option_button.custom_minimum_size = Vector2(0, ROW_HEIGHT)
	_option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# 關掉「依最長選項自動撐寬」，否則節點路徑一長，整個面板就被撐爆。
	_option_button.fit_to_longest_item = false
	_option_button.clip_text = true
	_option_button.item_selected.connect(_on_target_selected)
	vbox.add_child(_option_button)

	var rescan_button := Button.new()
	rescan_button.text = "重新掃描節點"
	rescan_button.pressed.connect(_rescan_targets)
	vbox.add_child(rescan_button)

	vbox.add_child(_build_spin_row("Position X", "_spin_pos_x"))
	vbox.add_child(_build_spin_row("Position Y", "_spin_pos_y"))
	vbox.add_child(_build_spin_row("Size X", "_spin_size_x"))
	vbox.add_child(_build_spin_row("Size Y", "_spin_size_y"))
	vbox.add_child(_build_spin_row("Scale X", "_spin_scale_x", SCALE_STEP, SCALE_MIN, SCALE_MAX))
	vbox.add_child(_build_spin_row("Scale Y", "_spin_scale_y", SCALE_STEP, SCALE_MIN, SCALE_MAX))

	_pick_toggle_button = Button.new()
	_pick_toggle_button.text = "點選模式：關"
	_pick_toggle_button.toggle_mode = true
	_pick_toggle_button.toggled.connect(_on_pick_toggle)
	vbox.add_child(_pick_toggle_button)

	_drag_toggle_button = Button.new()
	_drag_toggle_button.text = "拖拽模式：關"
	_drag_toggle_button.toggle_mode = true
	_drag_toggle_button.toggled.connect(_on_drag_toggle)
	vbox.add_child(_drag_toggle_button)

	var restore_button := Button.new()
	restore_button.text = "還原原始數值"
	restore_button.pressed.connect(_on_restore_pressed)
	vbox.add_child(restore_button)

	var copy_button := Button.new()
	copy_button.text = "複製參數到剪貼簿"
	copy_button.pressed.connect(_on_copy_pressed)
	vbox.add_child(copy_button)

	_status_label = Label.new()
	_status_label.text = "尚未選擇節點"
	_status_label.add_theme_font_size_override("font_size", FONT_SIZE_LABEL)
	_status_label.add_theme_color_override("font_color", COLOR_TEXT)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(_status_label)


func _on_panel_vbox_resized(vbox: VBoxContainer) -> void:
	_panel.size = vbox.size
	_root_control.size = vbox.size


# 建一行「Label + SpinBox」，並把SpinBox存進對應的內部變數名稱。
func _build_spin_row(label_text: String, field_name: String, step := SPINBOX_STEP, min_v := SPINBOX_MIN, max_v := SPINBOX_MAX) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, ROW_HEIGHT)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(80, 0)
	label.add_theme_font_size_override("font_size", FONT_SIZE_LABEL)
	label.add_theme_color_override("font_color", COLOR_TEXT)
	row.add_child(label)

	var spin := SpinBox.new()
	spin.step = step
	spin.min_value = min_v
	spin.max_value = max_v
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spin.value_changed.connect(_on_spin_value_changed)
	row.add_child(spin)

	set(field_name, spin)
	return row


# ------------------------------
# 節點掃描
# ------------------------------
# 掃描目前場景樹下所有Control節點（排除這個調校工具自己），列進下拉選單。
func _rescan_targets() -> void:
	_target_nodes.clear()
	_option_button.clear()

	var scene_root := get_tree().current_scene
	if scene_root == null:
		_status_label.text = "找不到目前場景"
		return

	_collect_controls(scene_root)

	if _target_nodes.is_empty():
		_status_label.text = "場景裡沒有可調校的Control節點"
		return

	for i in _target_nodes.size():
		_option_button.add_item("[%d] %s" % [i, _target_nodes[i].name])

	_status_label.text = "已掃描到 %d 個節點" % _target_nodes.size()


# 只收集「葉節點」型的Control（按鈕/標籤/面板/輸入框等），排除VBoxContainer/
# HBoxContainer/MarginContainer等版面排版容器——這些容器的Size是Godot
# 自動依排版規則決定的，手動拉大小只會把整個畫面排版弄壞，不該被選到。
func _collect_controls(node: Node) -> void:
	if node == self:
		return
	if node is Control and not (node is Container):
		_target_nodes.append(node)
		if not _original_transforms.has(node):
			_original_transforms[node] = {
				"position": node.position,
				"size": node.size,
				"scale": node.scale,
			}
	for child in node.get_children():
		_collect_controls(child)


# ------------------------------
# 互動處理：選擇節點 / 編輯數值 / 拖拽
# ------------------------------
func _on_target_selected(index: int) -> void:
	if index < 0 or index >= _target_nodes.size():
		return
	_selected_target = _target_nodes[index]
	_refresh_spin_values_from_target()


func _refresh_spin_values_from_target() -> void:
	if _selected_target == null:
		return
	_set_spin_silently(_spin_pos_x, _selected_target.position.x)
	_set_spin_silently(_spin_pos_y, _selected_target.position.y)
	_set_spin_silently(_spin_size_x, _selected_target.size.x)
	_set_spin_silently(_spin_size_y, _selected_target.size.y)
	_set_spin_silently(_spin_scale_x, _selected_target.scale.x)
	_set_spin_silently(_spin_scale_y, _selected_target.scale.y)
	_status_label.text = "目前選取：%s" % str(_selected_target.get_path())


# 更新SpinBox顯示用的數值時，先斷開訊號避免觸發一次多餘的_on_spin_value_changed。
func _set_spin_silently(spin: SpinBox, value: float) -> void:
	spin.value_changed.disconnect(_on_spin_value_changed)
	spin.value = value
	spin.value_changed.connect(_on_spin_value_changed)


func _on_spin_value_changed(_value: float) -> void:
	if _selected_target == null:
		return
	_selected_target.position = Vector2(_spin_pos_x.value, _spin_pos_y.value)
	_selected_target.size = Vector2(_spin_size_x.value, _spin_size_y.value)
	_selected_target.scale = Vector2(_spin_scale_x.value, _spin_scale_y.value)


# 拖動調校面板自己的標題列，跟下面「拖拽模式」拖動被選中節點是兩件事。
func _on_title_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_is_panel_dragging = event.pressed
	elif event is InputEventMouseMotion and _is_panel_dragging:
		_root_control.position += event.relative


func _on_drag_toggle(pressed: bool) -> void:
	_drag_mode = pressed
	_drag_toggle_button.text = "拖拽模式：開" if pressed else "拖拽模式：關"
	_drag_toggle_button.add_theme_color_override("font_color", COLOR_DRAG_ON if pressed else COLOR_TEXT)


func _on_pick_toggle(pressed: bool) -> void:
	_pick_mode = pressed
	_pick_toggle_button.text = "點選模式：開" if pressed else "點選模式：關"
	_pick_toggle_button.add_theme_color_override("font_color", COLOR_DRAG_ON if pressed else COLOR_TEXT)


# 把選中節點的Position/Size/Scale還原成這個零件第一次掃描到它時記下的數值，
# 用來救回被誤改（例如不小心拉爆排版容器）的節點。
func _on_restore_pressed() -> void:
	if _selected_target == null:
		_status_label.text = "請先選擇一個節點"
		return
	if not _original_transforms.has(_selected_target):
		_status_label.text = "沒有這個節點的原始數值紀錄"
		return

	var original: Dictionary = _original_transforms[_selected_target]
	_selected_target.position = original["position"]
	_selected_target.size = original["size"]
	_selected_target.scale = original["scale"]
	_refresh_spin_values_from_target()
	_status_label.text = "已還原 %s 到原始數值" % _selected_target.name


# 拖拽模式開啟時，直接攔截全域滑鼠事件來移動選中節點，
# 不依賴被選中節點本身的gui_input（它可能正好被其他UI蓋住而收不到事件）。
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# 點選模式優先判斷：點在調校面板本身範圍內就不挑選，留給面板自己的按鈕處理。
		if _pick_mode and not _root_control.get_global_rect().has_point(event.position):
			_pick_node_at(event.position)
			return

	if not _drag_mode or _selected_target == null:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _selected_target.get_global_rect().has_point(event.position):
				_is_dragging = true
				_drag_offset = event.position - _selected_target.global_position
			elif not event.pressed:
				_is_dragging = false
	elif event is InputEventMouseMotion and _is_dragging:
		var new_global_pos: Vector2 = event.position - _drag_offset
		_selected_target.global_position = new_global_pos
		_set_spin_silently(_spin_pos_x, _selected_target.position.x)
		_set_spin_silently(_spin_pos_y, _selected_target.position.y)


# 點選模式：在所有已掃描到的節點裡，找出滑鼠點擊位置命中、且面積最小
# （也就是最具體、最內層）的節點，視為玩家想選的目標。
func _pick_node_at(click_pos: Vector2) -> void:
	var best: Control = null
	var best_area := INF

	for node in _target_nodes:
		if not is_instance_valid(node) or not node.is_visible_in_tree():
			continue
		var rect := node.get_global_rect()
		if rect.has_point(click_pos):
			var area: float = rect.size.x * rect.size.y
			if area < best_area:
				best_area = area
				best = node

	if best == null:
		_status_label.text = "點擊位置沒有命中任何已掃描節點"
		return

	_selected_target = best
	var index := _target_nodes.find(best)
	if index != -1:
		_option_button.select(index)
	_refresh_spin_values_from_target()


# ------------------------------
# 輸出參數
# ------------------------------
func _on_copy_pressed() -> void:
	if _selected_target == null:
		_status_label.text = "請先選擇一個節點"
		return

	var node_name := _selected_target.name
	var text := "# %s 調校結果\nposition = Vector2(%.1f, %.1f)\nsize = Vector2(%.1f, %.1f)\nscale = Vector2(%.2f, %.2f)" % [
		node_name,
		_selected_target.position.x, _selected_target.position.y,
		_selected_target.size.x, _selected_target.size.y,
		_selected_target.scale.x, _selected_target.scale.y,
	]
	DisplayServer.clipboard_set(text)
	_status_label.text = "已複製%s的參數到剪貼簿" % node_name
