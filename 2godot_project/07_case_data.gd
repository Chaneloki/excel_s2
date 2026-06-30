class_name CaseData
extends RefCounted

# ------------------------------
# 零件說明
# ------------------------------
# 「案件資料結構」零件：把每個章節的對白腳本／案件目標／Excel解謎器
# 各關設定，從Story Dialogue UI demo (02)、Excel解謎器demo (01) 內部
# 寫死的占位常數，搬到跟UI完全解耦的JSON資料檔（見data/cases/）。
# 本檔案只負責「讀JSON、轉成好用的GDScript資料結構」，不畫任何畫面、
# 不認識任何UI節點，方便獨立測試（見07_case_data_test.gd/.tscn）。

# ------------------------------
# 設定區：資料檔路徑
# ------------------------------
const CASE_DATA_DIR := "res://data/cases/"


# ------------------------------
# 核心邏輯：讀取與解析
# ------------------------------

## 依案件id讀取對應JSON檔，回傳整份資料的Dictionary（讀取失敗回傳空Dictionary）。
static func load_case(case_id: String) -> Dictionary:
	var file_path := CASE_DATA_DIR + case_id + ".json"
	if not FileAccess.file_exists(file_path):
		push_error("CaseData: 找不到案件資料檔 " + file_path)
		return {}

	var file := FileAccess.open(file_path, FileAccess.READ)
	var raw_text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(raw_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("CaseData: 案件資料檔格式錯誤 " + file_path)
		return {}

	return parsed


## 取出對白腳本陣列（每句是Dictionary，欄位見data/cases/readme.md）。
static func get_dialogue_lines(case_data: Dictionary) -> Array:
	return case_data.get("dialogue", [])


## 依id取出單一案件目標的文字（找不到回傳空字串）。
static func get_objective_text(case_data: Dictionary, objective_id: String) -> String:
	for objective in case_data.get("objectives", []):
		if objective.get("id", "") == objective_id:
			return objective.get("text", "")
	return ""


## 依目前已觸發到的objective_update id，算出「目前案件目標清單」：
## 該id及之前的目標視為已完成(done)，該id本身視為目前進行中(active)，
## 之後的目標尚未出現，不列入清單。沒有任何objective_update時回傳空陣列。
static func get_active_objectives(case_data: Dictionary, current_objective_id: String) -> Array:
	var result: Array = []
	if current_objective_id == "":
		return result

	var reached_current := false
	for objective in case_data.get("objectives", []):
		var obj_id: String = objective.get("id", "")
		var state := "done" if not reached_current else ""
		if obj_id == current_objective_id:
			state = "active"
			reached_current = true
		result.append({"id": obj_id, "text": objective.get("text", ""), "state": state})
		if reached_current and obj_id == current_objective_id:
			break
	return result


## 依stage_id取出單一Excel解謎器關卡設定（找不到回傳空Dictionary）。
static func get_excel_stage(case_data: Dictionary, stage_id: String) -> Dictionary:
	for stage in case_data.get("excel_stages", []):
		if stage.get("stage_id", "") == stage_id:
			return stage
	return {}


## 取出某個角色的顯示名稱／立繪路徑設定（找不到回傳空Dictionary）。
static func get_character(case_data: Dictionary, character_id: String) -> Dictionary:
	return case_data.get("characters", {}).get(character_id, {})
