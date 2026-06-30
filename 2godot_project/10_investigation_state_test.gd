extends Control

# ------------------------------
# 零件說明
# ------------------------------
# InvestigationState的獨立測試場景。使用全是假ID，不讀案件一資料、不載入
# Story／Excel／Map／UI零件。按F6可在畫面查看PASS/FAIL；headless執行時
# 會把結果印到終端，任何一項失敗便以非0狀態結束。

# ------------------------------
# 設定區：測試ID
# ------------------------------
const TEST_CASE_ID := &"case_test"
const EVIDENCE_A := &"ev_test_a"
const EVIDENCE_B := &"ev_test_b"
const DEDUCTION_A := &"ded_test_a"
const FLAG_A := &"flag_test_a"
const LOCATION_A := &"location_test_a"
const TOPIC_A := &"topic_test_a"
const NPC_A := &"npc_test_a"
const HOTSPOT_A := &"hotspot_test_a"

const TRUST_INITIAL := 2.5
const TRUST_INCREMENT := 1.25
const PROGRESS_OVER_MAX := 1.5

@onready var result_label: Label = $ResultLabel


# ------------------------------
# 建構與測試入口
# ------------------------------
func _ready() -> void:
	var result := _run_checks()
	result_label.text = result["text"]
	print(result["text"])
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if result["all_passed"] else 1)


# ------------------------------
# 核心邏輯：測試案例
# ------------------------------
func _run_checks() -> Dictionary:
	var lines: Array[String] = []
	var all_passed := true
	var state := InvestigationState.new(TEST_CASE_ID)

	all_passed = _record(lines, "建立時保存active_case_id", state.active_case_id == TEST_CASE_ID, all_passed)

	# Array是參照型別，閉包內修改元素會反映到外部；直接捕捉整數只會修改
	# 閉包自己的值，不能用來驗證signal實際發出次數。
	var collected_signal_count := [0]
	state.evidence_collected.connect(func(_id: StringName) -> void: collected_signal_count[0] += 1)
	var first_collect := state.collect_evidence(EVIDENCE_A)
	var duplicate_collect := state.collect_evidence(EVIDENCE_A)
	all_passed = _record(lines, "證據首次收集成功", first_collect and state.has_evidence(EVIDENCE_A), all_passed)
	all_passed = _record(lines, "重複證據被拒絕", not duplicate_collect and collected_signal_count[0] == 1, all_passed)
	all_passed = _record(lines, "新證據標記可清除", state.is_evidence_new(EVIDENCE_A) and state.mark_evidence_seen(EVIDENCE_A) and not state.is_evidence_new(EVIDENCE_A), all_passed)

	all_passed = _record(lines, "推論首次解鎖且重複被拒絕", state.unlock_deduction(DEDUCTION_A) and not state.unlock_deduction(DEDUCTION_A), all_passed)
	all_passed = _record(lines, "推論查詢與新標記正確", state.has_deduction(DEDUCTION_A) and state.is_deduction_new(DEDUCTION_A), all_passed)

	all_passed = _record(lines, "flag首次設定成功", state.set_flag(FLAG_A, {"value": 3}), all_passed)
	all_passed = _record(lines, "相同flag值不重複變更", not state.set_flag(FLAG_A, {"value": 3}), all_passed)
	all_passed = _record(lines, "flag深層資料可查詢", state.has_flag(FLAG_A, {"value": 3}), all_passed)

	all_passed = _record(lines, "地點與話題解鎖去重", state.unlock_location(LOCATION_A) and not state.unlock_location(LOCATION_A) and state.unlock_dialogue_topic(TOPIC_A) and not state.unlock_dialogue_topic(TOPIC_A), all_passed)
	all_passed = _record(lines, "話題使用次數累加", state.record_dialogue_topic_use(TOPIC_A) == 1 and state.record_dialogue_topic_use(TOPIC_A) == 2, all_passed)

	state.set_npc_trust(NPC_A, TRUST_INITIAL)
	var trust_after_add := state.add_npc_trust(NPC_A, TRUST_INCREMENT)
	all_passed = _record(lines, "NPC信任值設定與累加", is_equal_approx(trust_after_add, TRUST_INITIAL + TRUST_INCREMENT), all_passed)

	var hotspot_value := {"inspected": true, "visit": 2}
	all_passed = _record(lines, "hotspot可保存結構狀態", state.set_hotspot_state(HOTSPOT_A, hotspot_value) and state.get_hotspot_state(HOTSPOT_A) == hotspot_value, all_passed)

	state.set_case_progress(PROGRESS_OVER_MAX)
	all_passed = _record(lines, "案件進度限制於0至1", is_equal_approx(state.case_progress, 1.0), all_passed)

	state.collect_evidence(EVIDENCE_B)
	var serialized := state.serialize_state()
	var json_text := JSON.stringify(serialized)
	var json_round_trip: Variant = JSON.parse_string(json_text)
	all_passed = _record(lines, "序列化結果可通過JSON往返", json_round_trip is Dictionary, all_passed)

	var restored_signal_count := [0]
	var restored := InvestigationState.new()
	restored.state_restored.connect(func() -> void: restored_signal_count[0] += 1)
	var restored_ok := restored.deserialize_state(json_round_trip)
	all_passed = _record(lines, "還原成功且只發一次完成訊號", restored_ok and restored_signal_count[0] == 1, all_passed)
	all_passed = _record(lines, "證據與推論完整還原", restored.has_evidence(EVIDENCE_A) and restored.has_evidence(EVIDENCE_B) and restored.has_deduction(DEDUCTION_A), all_passed)
	all_passed = _record(lines, "flag完整還原", restored.has_flag(FLAG_A, {"value": 3}), all_passed)
	all_passed = _record(lines, "地點／話題／使用次數完整還原", restored.is_location_unlocked(LOCATION_A) and restored.is_dialogue_topic_unlocked(TOPIC_A) and restored.get_dialogue_topic_use_count(TOPIC_A) == 2, all_passed)
	all_passed = _record(lines, "NPC信任值完整還原", is_equal_approx(restored.get_npc_trust(NPC_A), TRUST_INITIAL + TRUST_INCREMENT), all_passed)
	all_passed = _record(lines, "hotspot狀態完整還原", restored.get_hotspot_state(HOTSPOT_A) == hotspot_value, all_passed)
	all_passed = _record(lines, "案件進度完整還原", is_equal_approx(restored.case_progress, 1.0), all_passed)
	all_passed = _record(lines, "空Dictionary還原會安全失敗", not restored.deserialize_state({}), all_passed)

	lines.append("")
	lines.append("全部測試通過。" if all_passed else "有測試失敗，請查看上方項目。")
	return {"text": "\n".join(lines), "all_passed": all_passed}


func _record(lines: Array[String], label: String, passed: bool, current_result: bool) -> bool:
	lines.append(("[PASS] " if passed else "[FAIL] ") + label)
	return current_result and passed
