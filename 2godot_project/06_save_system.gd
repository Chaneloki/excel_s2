# ------------------------------------------------------------
# 06_save_system.gd
# ------------------------------------------------------------
# 存讀檔零件：負責真正把遊戲進度寫進磁碟/從磁碟讀回來，跟UI完全分離。
# UI（目前是02_story_dialogue_ui_demo.gd的存讀檔彈窗）只需要呼叫這裡的
# 靜態函式查詢/讀寫某一格的存檔，不需要知道檔案放在哪裡、用什麼格式存。
#
# 存檔資料是單純的Dictionary（章節名稱、地點、目前對白index、目標完成
# 狀態...），用JSON存成純文字檔，方便之後案件資料結構零件接手時擴充
# 欄位，不需要换檔案格式。
extends RefCounted
class_name SaveSystem

# ------------------------------
# 設定區：存檔位置與格數
# ------------------------------
const SAVE_DIR := "user://saves/"
const SAVE_FILE_PREFIX := "slot_"
const SAVE_FILE_SUFFIX := ".json"

# 存檔格數：跟存讀檔彈窗的6格畫面版面對齊（見0mockup/save_load_ui_mockup.png）。
const SLOT_COUNT := 6


# ------------------------------
# 查詢區：確認某一格是否已有存檔、讀取其摘要資訊
# ------------------------------
static func has_save(slot_index: int) -> bool:
	return FileAccess.file_exists(_get_slot_path(slot_index))


# 讀取某一格存檔的完整內容；沒有存檔或檔案損毀時回傳空Dictionary。
static func load_slot(slot_index: int) -> Dictionary:
	var path := _get_slot_path(slot_index)
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("無法開啟存檔檔案：" + path)
		return {}

	var raw_text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(raw_text)
	if parsed is Dictionary:
		return parsed
	push_error("存檔檔案內容格式錯誤：" + path)
	return {}


# ------------------------------
# 寫入區：把目前遊戲進度存進某一格
# ------------------------------
static func save_slot(slot_index: int, data: Dictionary) -> bool:
	_ensure_save_dir_exists()

	var file := FileAccess.open(_get_slot_path(slot_index), FileAccess.WRITE)
	if file == null:
		push_error("無法建立存檔檔案：" + _get_slot_path(slot_index))
		return false

	file.store_string(JSON.stringify(data))
	file.close()
	return true


# ------------------------------
# 共用輔助函式區
# ------------------------------
static func _get_slot_path(slot_index: int) -> String:
	return SAVE_DIR + SAVE_FILE_PREFIX + str(slot_index) + SAVE_FILE_SUFFIX


static func _ensure_save_dir_exists() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
