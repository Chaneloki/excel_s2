extends Control

# ------------------------------
# 零件說明
# ------------------------------
# 「案件資料結構」零件的獨立測試場景：不依賴任何其他UI零件，純粹驗證
# CaseData (07_case_data.gd) 能正確讀取/解析 data/cases/case_01.json，
# 對齊「零件先行」原則——資料結構零件要先獨立測試可動，才換成02/01
# 兩個既有demo改讀這份資料。
#
# 測試方式：開這個scene按F6，畫面會列出每一項檢查的PASS/FAIL，全部
# PASS代表CaseData讀取/解析邏輯正確。

const TEST_CASE_ID := "case_01"

@onready var result_label: Label = $ResultLabel


# ------------------------------
# 互動處理
# ------------------------------
func _ready() -> void:
	result_label.text = _run_checks()


# ------------------------------
# 核心邏輯：測試案例
# ------------------------------
func _run_checks() -> String:
	var lines: Array[String] = []
	var case_data := CaseData.load_case(TEST_CASE_ID)

	lines.append(_check("案件資料讀取成功", not case_data.is_empty()))
	lines.append(_check("chapter_name有值", case_data.get("chapter_name", "") != ""))

	var dialogue := CaseData.get_dialogue_lines(case_data)
	lines.append(_check("對白腳本至少有1句", dialogue.size() > 0))

	var first_line: Dictionary = dialogue[0] if dialogue.size() > 0 else {}
	lines.append(_check("第一句type為narration", first_line.get("type", "") == "narration"))

	var objective_text := CaseData.get_objective_text(case_data, "obj_01")
	lines.append(_check("obj_01文字讀取正確", objective_text == "接下克雷斯商會的委託"))

	var active_objectives := CaseData.get_active_objectives(case_data, "obj_03")
	lines.append(_check("obj_03進行中時，前面目標數量為3", active_objectives.size() == 3))
	if active_objectives.size() == 3:
		lines.append(_check("obj_01已標記done", active_objectives[0].get("state") == "done"))
		lines.append(_check("obj_03標記active", active_objectives[2].get("state") == "active"))

	var stage := CaseData.get_excel_stage(case_data, "stage_countifs")
	lines.append(_check("stage_countifs可用函數含COUNTIFS", stage.get("available_functions", []).has("COUNTIFS")))

	var host_character := CaseData.get_character(case_data, "host")
	lines.append(_check("host角色名稱為莉希雅", host_character.get("name", "") == "莉希雅"))

	var missing_case := CaseData.load_case("case_does_not_exist")
	lines.append(_check("讀取不存在的案件回傳空Dictionary", missing_case.is_empty()))

	return "\n".join(lines)


func _check(label: String, passed: bool) -> String:
	return ("[PASS] " if passed else "[FAIL] ") + label
