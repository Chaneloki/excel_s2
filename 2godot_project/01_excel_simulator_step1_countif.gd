extends Control

# ============================================================
# Excel 模擬器 - Step 1 原型（只支援 COUNTIF）
#
# 這個檔案的目的：先驗證「假Excel視窗」的核心互動能不能跑通，
# 還不接真正案件的劇情資料，所以表格內容是無意義的測試文字。
#
# 程式碼的邏輯順序（從上到下對應實際執行順序）：
#   1. 設定區：表格大小、假資料、版面數字、配色 —— 之後要換真案件
#      資料或套用美術風格時，只需要改這一區，不用動下面的邏輯。
#   2. _ready()：畫面建構，照順序疊出標題 → fx輸入欄 → 表格 → 結果欄。
#   3. 格子建構函式：負責「外觀」，鎖住的格子(Label)跟可編輯的格子
#      (LineEdit)分開處理。
#   4. 使用者輸入處理：玩家在fx欄或格子裡打公式、按Enter、點別處離開
#      時，分別要做什麼。
#   5. 公式運算核心：把輸入文字算出結果，不管輸入是從fx欄或格子來的，
#      都共用同一套邏輯，確保兩邊算出來的答案一定一致。
#   6. 公式解析：把字串拆解成「範圍」「條件」這些參數，是最底層、
#      最先被呼叫的部分。
# ============================================================


# ------------------------------------------------------------
# 1. 設定區
# ------------------------------------------------------------

# 表格欄數/列數（目前只是Step1的測試版面，之後接真案件時可能會調整）
const COLS = ["A", "B", "C"]
const ROWS = 5

# 假資料：只有A欄有內容，是無意義文字，跟任何案件劇情無關，純粹測試
# COUNTIF算得對不對。
const COLUMN_DATA = {
	"A": ["苹果", "香蕉", "苹果", "橘子", "苹果"]
}

# 玩家唯一能直接點進去打公式的格子，其餘格子都鎖住唯讀。
# 之後若要開放更多格子可編輯，只要把這裡換成陣列、改一下判斷邏輯即可。
const EDITABLE_CELL = "B1"

# fx輸入欄上顯示的範例公式（同一個常數，避免之後改範例時兩處要分別改）
const EXAMPLE_FORMULA = '=COUNTIF(A1:A5,"苹果")'

# ---- 版面數字（統一管理，之後調整大小/間距只改這裡）----
const CELL_SIZE = Vector2(80, 32)
const PAGE_MARGIN = 24
const SECTION_SPACING = 12
const TITLE_FONT_SIZE = 20
const RESULT_FONT_SIZE = 16
const LOCKED_BORDER_WIDTH = 1
const EDITABLE_BORDER_WIDTH = 2

# ---- 配色（統一管理，之後套用「貴族華麗風」配色只改這裡）----
const COLOR_HEADER_BG = Color(0.2, 0.2, 0.2)
const COLOR_HEADER_TEXT = Color(1, 1, 1)
const COLOR_LOCKED_BG = Color(1, 1, 1)
const COLOR_LOCKED_BORDER = Color(0.7, 0.7, 0.7)
const COLOR_LOCKED_TEXT = Color(0, 0, 0)
const COLOR_EDITABLE_BG = Color(1, 0.96, 0.85)      # 淺黃底，讓玩家一看就知道「這格能打字」
const COLOR_EDITABLE_BORDER = Color(0.83, 0.69, 0.22)  # 金色邊框，呼應之後的貴族風格

# 執行期狀態（會在_ready()建構畫面時被指定，不是寫死的資料）
var cell_labels = {}  # 例如 "A1" -> 對應的 Label 節點（鎖住的格子）
var editable_cell_input: LineEdit
var editable_cell_formula: String = ""


# ------------------------------------------------------------
# 2. 畫面建構：依照「標題 → fx輸入欄 → 表格 → 結果欄」的順序疊畫面
# ------------------------------------------------------------
func _ready() -> void:
	var root_vbox = VBoxContainer.new()
	root_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_vbox.add_theme_constant_override("separation", SECTION_SPACING)
	add_child(root_vbox)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", PAGE_MARGIN)
	margin.add_theme_constant_override("margin_top", PAGE_MARGIN)
	margin.add_theme_constant_override("margin_right", PAGE_MARGIN)
	root_vbox.add_child(margin)

	var inner_vbox = VBoxContainer.new()
	inner_vbox.add_theme_constant_override("separation", SECTION_SPACING)
	margin.add_child(inner_vbox)

	# 2-1：標題
	var title = Label.new()
	title.text = "Excel 模擬器原型 - COUNTIF 測試（假資料）"
	title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	inner_vbox.add_child(title)

	# 2-2：操作提示
	var hint = Label.new()
	hint.text = "可編輯格：%s（其他格鎖住）。也可以用上面的 fx 欄輸入。" % EDITABLE_CELL
	inner_vbox.add_child(hint)

	# 2-3：fx 公式輸入欄（跟可編輯格子是兩個入口，但共用同一套運算邏輯）
	var formula_box = HBoxContainer.new()
	inner_vbox.add_child(formula_box)

	var fx_label = Label.new()
	fx_label.text = "fx"
	fx_label.custom_minimum_size = Vector2(32, 0)
	formula_box.add_child(fx_label)

	var formula_input = LineEdit.new()
	formula_input.placeholder_text = EXAMPLE_FORMULA
	formula_input.custom_minimum_size = Vector2(400, 0)
	formula_input.name = "FormulaInput"
	formula_input.text_submitted.connect(_on_formula_bar_submitted)
	formula_box.add_child(formula_input)

	# 2-4：表格本體（欄號/列號 + 資料格 + 1個可編輯格）
	var grid = GridContainer.new()
	grid.columns = COLS.size() + 1
	inner_vbox.add_child(grid)

	# 表頭列：先放一個空白角落格，再放A/B/C欄名
	grid.add_child(_make_header_cell(""))
	for col in COLS:
		grid.add_child(_make_header_cell(col))

	# 資料列：每列先放列號，再依序放這一列每一欄的格子
	for r in range(1, ROWS + 1):
		grid.add_child(_make_header_cell(str(r)))
		for col in COLS:
			var cell_id = col + str(r)
			if cell_id == EDITABLE_CELL:
				grid.add_child(_make_editable_cell())
			else:
				var value = ""
				if COLUMN_DATA.has(col) and r - 1 < COLUMN_DATA[col].size():
					value = COLUMN_DATA[col][r - 1]
				var cell = _make_data_cell(value)
				cell_labels[cell_id] = cell
				grid.add_child(cell)

	# 2-5：結果/提示訊息區（公式算完或出錯時的文字會顯示在這裡）
	var result_label = Label.new()
	result_label.name = "ResultLabel"
	result_label.text = "結果會顯示在這裡"
	result_label.add_theme_font_size_override("font_size", RESULT_FONT_SIZE)
	inner_vbox.add_child(result_label)


# ------------------------------------------------------------
# 3. 格子建構函式：只負責外觀，不處理運算邏輯
# ------------------------------------------------------------

# 一次設定4個邊框寬度，避免每個格子都要重複寫4行一樣的程式碼。
func _make_border_stylebox(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var bg = StyleBoxFlat.new()
	bg.bg_color = bg_color
	bg.border_color = border_color
	bg.border_width_left = border_width
	bg.border_width_right = border_width
	bg.border_width_top = border_width
	bg.border_width_bottom = border_width
	return bg


# 表頭格（最上面一排的A/B/C，跟最左邊一排的1/2/3...）
func _make_header_cell(text: String) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.custom_minimum_size = CELL_SIZE
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", COLOR_HEADER_TEXT)
	lbl.add_theme_stylebox_override("normal", _make_border_stylebox(COLOR_HEADER_BG, COLOR_HEADER_BG, 0))
	return lbl


# 鎖住的資料格（玩家只能看、不能點進去改）
func _make_data_cell(text: String) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.custom_minimum_size = CELL_SIZE
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_stylebox_override("normal", _make_border_stylebox(COLOR_LOCKED_BG, COLOR_LOCKED_BORDER, LOCKED_BORDER_WIDTH))
	lbl.add_theme_color_override("font_color", COLOR_LOCKED_TEXT)
	return lbl


# 唯一可編輯的格子（玩家可以點進去打公式）
func _make_editable_cell() -> LineEdit:
	var input = LineEdit.new()
	input.custom_minimum_size = CELL_SIZE
	input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	input.placeholder_text = "輸入公式"

	var bg = _make_border_stylebox(COLOR_EDITABLE_BG, COLOR_EDITABLE_BORDER, EDITABLE_BORDER_WIDTH)
	input.add_theme_stylebox_override("normal", bg)
	input.add_theme_stylebox_override("focus", bg)

	input.focus_entered.connect(_on_editable_cell_focus_entered)
	input.focus_exited.connect(_on_editable_cell_focus_exited)
	input.text_submitted.connect(_on_editable_cell_text_submitted)

	editable_cell_input = input
	return input


# ------------------------------------------------------------
# 4. 使用者輸入處理：玩家打公式後，依「輸入來源」分別處理，
#    但最後都會呼叫第5節的共用運算邏輯，確保結果一致。
# ------------------------------------------------------------

# 來源A：玩家在上方fx欄按下Enter
func _on_formula_bar_submitted(text: String) -> void:
	_apply_formula(text)
	if editable_cell_input != null:
		editable_cell_formula = text.strip_edges()
		editable_cell_input.text = _display_value_for(editable_cell_formula)


# 來源B：玩家點進可編輯格子 —— 點進去時，要把「結果數字」換回顯示
# 「公式原文」，這樣玩家才能繼續修改，行為跟真實Excel一致。
func _on_editable_cell_focus_entered() -> void:
	editable_cell_input.text = editable_cell_formula


# 來源B：玩家點到格子外面（離開焦點）—— 視同送出公式
func _on_editable_cell_focus_exited() -> void:
	_commit_editable_cell(editable_cell_input.text)


# 來源B：玩家在格子裡直接按下Enter —— 視同送出公式，並把焦點放掉
func _on_editable_cell_text_submitted(text: String) -> void:
	_commit_editable_cell(text)
	editable_cell_input.release_focus()


# 來源B共用：把玩家在格子裡打的公式記下來，算出結果後換成顯示結果數字
func _commit_editable_cell(text: String) -> void:
	var trimmed = text.strip_edges()
	editable_cell_formula = trimmed
	if trimmed == "":
		editable_cell_input.text = ""
		return
	_apply_formula(trimmed)
	editable_cell_input.text = _display_value_for(trimmed)


# 把公式算出來的「值」轉成字串，準備顯示在格子裡；
# 如果算不出來（不支援的公式），就保留玩家打的原始文字，不要清空或顯示亂碼。
func _display_value_for(formula_text: String) -> String:
	if formula_text == "":
		return ""
	var evaluation = _evaluate_countif(formula_text)
	if evaluation["ok"]:
		return str(evaluation["value"])
	return formula_text


# 把運算結果的提示訊息，顯示到畫面最下方的結果欄
func _apply_formula(text: String) -> void:
	var result_label = inner_result_label()
	var evaluation = _evaluate_countif(text)
	result_label.text = evaluation["message"]


func inner_result_label() -> Label:
	return find_child("ResultLabel", true, false)


# ------------------------------------------------------------
# 5. 公式運算核心：fx欄跟可編輯格子都會呼叫這裡，
#    確保「同一個公式、不管從哪裡打」都算出同一個答案。
# ------------------------------------------------------------
func _evaluate_countif(raw_text: String) -> Dictionary:
	# 第一步：先正規化大小寫（細節邏輯在第6節說明）
	var text = _normalize_formula(raw_text)

	# 第二步：拆解成「範圍」「條件」等參數
	var parsed = _parse_countif(text)
	if parsed == null:
		return {"ok": false, "value": null, "message": "目前案件用不到這個指令，先專心查 COUNTIF 試試看。"}

	var col_start = parsed["col_start"]
	var row_start = parsed["row_start"]
	var col_end = parsed["col_end"]
	var row_end = parsed["row_end"]
	var criteria = parsed["criteria"]

	# 第三步：檢查這個原型有沒有支援這種範圍寫法
	if col_start != col_end:
		return {"ok": false, "value": null, "message": "這個原型只支援同一欄的範圍，例如 A1:A5。"}

	if not COLUMN_DATA.has(col_start):
		return {"ok": false, "value": null, "message": "找不到欄位 %s 的資料。" % col_start}

	# 第四步：真正的COUNTIF邏輯 —— 數出範圍內符合條件的格子數量
	var data = COLUMN_DATA[col_start]
	var count = 0
	for r in range(row_start, row_end + 1):
		var idx = r - 1
		if idx >= 0 and idx < data.size():
			if data[idx] == criteria:
				count += 1

	var message = "=COUNTIF(%s%d:%s%d,\"%s\") 結果 = %d" % [col_start, row_start, col_end, row_end, criteria, count]
	return {"ok": true, "value": count, "message": message}


# ------------------------------------------------------------
# 6. 公式解析：把使用者打的字串，拆解成程式能讀的參數。
#    這是最底層的部分，被第5節的運算核心呼叫。
# ------------------------------------------------------------

# 把公式「引號外」的部分全部轉成大寫（函數名稱、欄位字母），
# 「引號內」的部分（玩家實際要查找的文字，例如人名）完全不動。
# 之後新增SUMIF、VLOOKUP等函數時，一律先呼叫這個函式處理大小寫，
# 不需要每個函數各自重複處理一次。
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


# 用正規表達式拆解 =COUNTIF(範圍起點:範圍終點,"條件") 這種格式，
# 拆出「起始欄」「起始列」「結束欄」「結束列」「查找條件」五個參數。
# 拆不出來（玩家打的不是這個格式）就回傳 null，交給上層顯示提示訊息。
func _parse_countif(text: String):
	var regex = RegEx.new()
	regex.compile("^=COUNTIF\\(([A-Za-z]+)(\\d+):([A-Za-z]+)(\\d+),\\s*\"([^\"]*)\"\\)$")
	var m = regex.search(text.strip_edges())
	if m == null:
		return null
	return {
		"col_start": m.get_string(1).to_upper(),
		"row_start": int(m.get_string(2)),
		"col_end": m.get_string(3).to_upper(),
		"row_end": int(m.get_string(4)),
		"criteria": m.get_string(5)
	}
