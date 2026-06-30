class_name InvestigationState
extends RefCounted

# ------------------------------
# 零件說明
# ------------------------------
# Detective Mode的純狀態核心：只保存穩定ID與可序列化數值，不載入UI、
# 場景、角色圖片或案件專屬答案。之後不論是2.5D場景、調查對話、筆記本、
# Excel Bridge或SaveSystem，都只能透過這組公開函式讀寫調查進度。
#
# 目前先維持可獨立建立的RefCounted，不登記Autoload。完成其他零件並確認
# 生命週期後，再由Case Flow或Autoload持有同一個實體。

# ------------------------------
# 訊號：只有狀態真的改變時才發出
# ------------------------------
signal evidence_collected(evidence_id: StringName)
signal evidence_seen(evidence_id: StringName)
signal deduction_unlocked(deduction_id: StringName)
signal deduction_seen(deduction_id: StringName)
signal flag_changed(flag_id: StringName, value: Variant)
signal location_unlocked(location_id: StringName)
signal dialogue_topic_unlocked(topic_id: StringName)
signal dialogue_topic_used(topic_id: StringName, use_count: int)
signal npc_trust_changed(npc_id: StringName, value: float)
signal hotspot_state_changed(hotspot_id: StringName, value: Variant)
signal case_progress_changed(value: float)
signal state_restored

# ------------------------------
# 設定區
# ------------------------------
const SERIALIZE_VERSION := 1
const CASE_PROGRESS_MIN := 0.0
const CASE_PROGRESS_MAX := 1.0
const DEFAULT_NPC_TRUST := 0.0
const SERIALIZED_TYPE_KEY := "__investigation_state_type"
const SERIALIZED_VALUE_KEY := "value"
const SERIALIZED_INT_TYPE := "int"
const DEFAULT_TOPIC_USE_COUNT := 0

# ------------------------------
# 狀態區
# Dictionary在這裡當作StringName set使用：key是ID，value固定為true。
# 這比Array更適合頻繁查詢，也能自然阻止重複收集。
# ------------------------------
var active_case_id: StringName = &""
var case_progress := CASE_PROGRESS_MIN

var collected_evidence_ids: Dictionary = {}
var unlocked_deduction_ids: Dictionary = {}
var investigation_flags: Dictionary = {}
var unlocked_location_ids: Dictionary = {}
var unlocked_dialogue_topic_ids: Dictionary = {}
var dialogue_topic_use_counts: Dictionary = {}
var npc_trust_values: Dictionary = {}
var hotspot_states: Dictionary = {}

var new_evidence_ids: Dictionary = {}
var new_deduction_ids: Dictionary = {}


# ------------------------------
# 生命週期：建立／重設案件狀態
# ------------------------------
func _init(case_id: StringName = &"") -> void:
	active_case_id = case_id


func reset(case_id: StringName = &"") -> void:
	active_case_id = case_id
	case_progress = CASE_PROGRESS_MIN
	collected_evidence_ids.clear()
	unlocked_deduction_ids.clear()
	investigation_flags.clear()
	unlocked_location_ids.clear()
	unlocked_dialogue_topic_ids.clear()
	dialogue_topic_use_counts.clear()
	npc_trust_values.clear()
	hotspot_states.clear()
	new_evidence_ids.clear()
	new_deduction_ids.clear()


# ------------------------------
# 證據與推論
# ------------------------------
func collect_evidence(evidence_id: StringName) -> bool:
	if evidence_id.is_empty() or collected_evidence_ids.has(evidence_id):
		return false
	collected_evidence_ids[evidence_id] = true
	new_evidence_ids[evidence_id] = true
	evidence_collected.emit(evidence_id)
	return true


func has_evidence(evidence_id: StringName) -> bool:
	return collected_evidence_ids.has(evidence_id)


func mark_evidence_seen(evidence_id: StringName) -> bool:
	if not new_evidence_ids.erase(evidence_id):
		return false
	evidence_seen.emit(evidence_id)
	return true


func is_evidence_new(evidence_id: StringName) -> bool:
	return new_evidence_ids.has(evidence_id)


func unlock_deduction(deduction_id: StringName) -> bool:
	if deduction_id.is_empty() or unlocked_deduction_ids.has(deduction_id):
		return false
	unlocked_deduction_ids[deduction_id] = true
	new_deduction_ids[deduction_id] = true
	deduction_unlocked.emit(deduction_id)
	return true


func has_deduction(deduction_id: StringName) -> bool:
	return unlocked_deduction_ids.has(deduction_id)


func mark_deduction_seen(deduction_id: StringName) -> bool:
	if not new_deduction_ids.erase(deduction_id):
		return false
	deduction_seen.emit(deduction_id)
	return true


func is_deduction_new(deduction_id: StringName) -> bool:
	return new_deduction_ids.has(deduction_id)


# ------------------------------
# Flags、地點與對話話題
# ------------------------------
func set_flag(flag_id: StringName, value: Variant) -> bool:
	if flag_id.is_empty():
		return false
	if investigation_flags.has(flag_id) and investigation_flags[flag_id] == value:
		return false
	investigation_flags[flag_id] = _copy_serializable_value(value)
	flag_changed.emit(flag_id, value)
	return true


func has_flag(flag_id: StringName, expected_value: Variant = true) -> bool:
	return investigation_flags.has(flag_id) and investigation_flags[flag_id] == expected_value


func get_flag(flag_id: StringName, default_value: Variant = null) -> Variant:
	return investigation_flags.get(flag_id, default_value)


func unlock_location(location_id: StringName) -> bool:
	if location_id.is_empty() or unlocked_location_ids.has(location_id):
		return false
	unlocked_location_ids[location_id] = true
	location_unlocked.emit(location_id)
	return true


func is_location_unlocked(location_id: StringName) -> bool:
	return unlocked_location_ids.has(location_id)


func unlock_dialogue_topic(topic_id: StringName) -> bool:
	if topic_id.is_empty() or unlocked_dialogue_topic_ids.has(topic_id):
		return false
	unlocked_dialogue_topic_ids[topic_id] = true
	dialogue_topic_unlocked.emit(topic_id)
	return true


func is_dialogue_topic_unlocked(topic_id: StringName) -> bool:
	return unlocked_dialogue_topic_ids.has(topic_id)


func record_dialogue_topic_use(topic_id: StringName) -> int:
	if topic_id.is_empty():
		return DEFAULT_TOPIC_USE_COUNT
	var next_count: int = get_dialogue_topic_use_count(topic_id) + 1
	dialogue_topic_use_counts[topic_id] = next_count
	dialogue_topic_used.emit(topic_id, next_count)
	return next_count


func get_dialogue_topic_use_count(topic_id: StringName) -> int:
	return int(dialogue_topic_use_counts.get(topic_id, DEFAULT_TOPIC_USE_COUNT))


# ------------------------------
# NPC信任值、Hotspot狀態與案件進度
# ------------------------------
func set_npc_trust(npc_id: StringName, value: float) -> bool:
	if npc_id.is_empty():
		return false
	if npc_trust_values.has(npc_id) and is_equal_approx(float(npc_trust_values[npc_id]), value):
		return false
	npc_trust_values[npc_id] = value
	npc_trust_changed.emit(npc_id, value)
	return true


func add_npc_trust(npc_id: StringName, amount: float) -> float:
	var next_value := get_npc_trust(npc_id) + amount
	set_npc_trust(npc_id, next_value)
	return next_value


func get_npc_trust(npc_id: StringName) -> float:
	return float(npc_trust_values.get(npc_id, DEFAULT_NPC_TRUST))


func set_hotspot_state(hotspot_id: StringName, value: Variant) -> bool:
	if hotspot_id.is_empty():
		return false
	if hotspot_states.has(hotspot_id) and hotspot_states[hotspot_id] == value:
		return false
	hotspot_states[hotspot_id] = _copy_serializable_value(value)
	hotspot_state_changed.emit(hotspot_id, value)
	return true


func get_hotspot_state(hotspot_id: StringName, default_value: Variant = null) -> Variant:
	return hotspot_states.get(hotspot_id, default_value)


func set_case_progress(value: float) -> bool:
	var clamped_value := clampf(value, CASE_PROGRESS_MIN, CASE_PROGRESS_MAX)
	if is_equal_approx(case_progress, clamped_value):
		return false
	case_progress = clamped_value
	case_progress_changed.emit(case_progress)
	return true


# ------------------------------
# 存檔序列化／還原
# ------------------------------
func serialize_state() -> Dictionary:
	return {
		"version": SERIALIZE_VERSION,
		"active_case_id": str(active_case_id),
		"case_progress": case_progress,
		"collected_evidence_ids": _sorted_string_ids(collected_evidence_ids),
		"unlocked_deduction_ids": _sorted_string_ids(unlocked_deduction_ids),
		"investigation_flags": _encode_serializable_value(investigation_flags),
		"unlocked_location_ids": _sorted_string_ids(unlocked_location_ids),
		"unlocked_dialogue_topic_ids": _sorted_string_ids(unlocked_dialogue_topic_ids),
		"dialogue_topic_use_counts": dialogue_topic_use_counts.duplicate(true),
		"npc_trust_values": npc_trust_values.duplicate(true),
		"hotspot_states": _encode_serializable_value(hotspot_states),
		"new_evidence_ids": _sorted_string_ids(new_evidence_ids),
		"new_deduction_ids": _sorted_string_ids(new_deduction_ids),
	}


func deserialize_state(data: Dictionary) -> bool:
	if data.is_empty():
		return false

	reset(StringName(str(data.get("active_case_id", ""))))
	case_progress = clampf(float(data.get("case_progress", CASE_PROGRESS_MIN)), CASE_PROGRESS_MIN, CASE_PROGRESS_MAX)
	_restore_id_set(collected_evidence_ids, data.get("collected_evidence_ids", []))
	_restore_id_set(unlocked_deduction_ids, data.get("unlocked_deduction_ids", []))
	_restore_id_set(unlocked_location_ids, data.get("unlocked_location_ids", []))
	_restore_id_set(unlocked_dialogue_topic_ids, data.get("unlocked_dialogue_topic_ids", []))
	_restore_id_set(new_evidence_ids, data.get("new_evidence_ids", []))
	_restore_id_set(new_deduction_ids, data.get("new_deduction_ids", []))

	# JSON物件的key讀回來一律是String；所有ID key要正規化回StringName，
	# 否則以StringName查詢時會找不到剛還原的狀態。
	investigation_flags = _restore_value_dictionary(data.get("investigation_flags", {}))
	dialogue_topic_use_counts = _restore_int_dictionary(data.get("dialogue_topic_use_counts", {}))
	npc_trust_values = _restore_float_dictionary(data.get("npc_trust_values", {}))
	hotspot_states = _restore_value_dictionary(data.get("hotspot_states", {}))
	state_restored.emit()
	return true


# ------------------------------
# 共用輔助函式
# ------------------------------
func _restore_id_set(target: Dictionary, source: Variant) -> void:
	target.clear()
	if typeof(source) != TYPE_ARRAY:
		return
	for raw_id in source:
		var item_id := StringName(str(raw_id))
		if not item_id.is_empty():
			target[item_id] = true


func _sorted_string_ids(source: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for raw_id in source.keys():
		result.append(str(raw_id))
	result.sort()
	return result


func _restore_value_dictionary(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if typeof(value) != TYPE_DICTIONARY:
		return result
	for raw_id in value.keys():
		var item_id := StringName(str(raw_id))
		if not item_id.is_empty():
			result[item_id] = _decode_serializable_value(value[raw_id])
	return result


func _restore_int_dictionary(value: Variant) -> Dictionary:
	var result := _restore_value_dictionary(value)
	for item_id in result.keys():
		result[item_id] = int(result[item_id])
	return result


func _restore_float_dictionary(value: Variant) -> Dictionary:
	var result := _restore_value_dictionary(value)
	for item_id in result.keys():
		result[item_id] = float(result[item_id])
	return result


func _copy_serializable_value(value: Variant) -> Variant:
	if typeof(value) == TYPE_DICTIONARY or typeof(value) == TYPE_ARRAY:
		return value.duplicate(true)
	return value


# JSON會把整數讀回浮點數；以輕量型別標記保存整數，避免案件狀態比較失真。
func _encode_serializable_value(value: Variant) -> Variant:
	if typeof(value) == TYPE_INT:
		return {
			SERIALIZED_TYPE_KEY: SERIALIZED_INT_TYPE,
			SERIALIZED_VALUE_KEY: value,
		}
	if typeof(value) == TYPE_DICTIONARY:
		var encoded_dictionary: Dictionary = {}
		for key in value.keys():
			encoded_dictionary[key] = _encode_serializable_value(value[key])
		return encoded_dictionary
	if typeof(value) == TYPE_ARRAY:
		var encoded_array: Array = []
		for item in value:
			encoded_array.append(_encode_serializable_value(item))
		return encoded_array
	return value


func _decode_serializable_value(value: Variant) -> Variant:
	if typeof(value) == TYPE_DICTIONARY:
		if value.size() == 2 and value.get(SERIALIZED_TYPE_KEY, "") == SERIALIZED_INT_TYPE and value.has(SERIALIZED_VALUE_KEY):
			return int(value[SERIALIZED_VALUE_KEY])
		var decoded_dictionary: Dictionary = {}
		for key in value.keys():
			decoded_dictionary[key] = _decode_serializable_value(value[key])
		return decoded_dictionary
	if typeof(value) == TYPE_ARRAY:
		var decoded_array: Array = []
		for item in value:
			decoded_array.append(_decode_serializable_value(item))
		return decoded_array
	return value
