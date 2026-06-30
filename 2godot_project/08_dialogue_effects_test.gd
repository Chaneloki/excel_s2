extends Control

# ------------------------------
# 零件說明
# ------------------------------
# 「劇情特效」零件的獨立測試場景：放6顆按鈕，分別手動觸發
# 08_dialogue_effects.gd的六個效果，肉眼驗證動畫正確，不依賴02 demo。
# 對齊「零件先行」原則——特效引擎要先自己測試可動，才接進Story
# Dialogue UI讀case_01.json的"effect"欄位觸發。
#
# 測試方式：開這個scene按F6，依序按6顆按鈕觀察：
#   - 震動：黃色方塊應該左右快速擺動後精準回到原位置。
#   - 閃光：畫面應該快速亮白後淡出，不會卡在全白。
#   - 放大彈回：黃色方塊應該瞬間放大再彈回原大小。
#   - 黑屏轉場：畫面應該淡入全黑、停頓、再淡出恢復。
#   - 立繪淡入淡出：黃色方塊應該交替淡出隱藏／淡入顯示，不是瞬間消失。
#   - Ken Burns：黃色方塊應該極緩慢地放大+往左上位移，幾乎看不出來在
#     動，要耐心觀察幾秒才會發現畫面有變化（時間拉短成2秒方便測試時
#     肉眼驗證，正式使用時duration會用預設的16秒）。

const TARGET_SIZE := Vector2(120, 120)
const TARGET_START_POSITION := Vector2(400, 220)
const BUTTON_START_Y := 460
const BUTTON_GAP := 50

@onready var effects: Control = $DialogueEffects
@onready var target_box: ColorRect = $TargetBox
@onready var bg_test_rect: ColorRect = $BgTestRect  # 鋪滿整個畫面，專門給Ken Burns測試用——ken_burns()假設target是滿版錨點的Control，TargetBox不是滿版，不能共用

var sprite_fade_target_visible := true
var bg_test_rect_base_size := Vector2.ZERO  # bg_test_rect在offset全部=0時的原始尺寸，ken_burns()算新目標要用這個，不能用動畫進行中已經變大的target.size


func _ready() -> void:
	target_box.color = Color("#e0c84a")
	target_box.position = TARGET_START_POSITION
	target_box.size = TARGET_SIZE
	bg_test_rect_base_size = bg_test_rect.size

	_add_test_button("1. Shake 震動", 0, _on_shake_pressed)
	_add_test_button("2. Flash 全螢幕閃光", 1, _on_flash_pressed)
	_add_test_button("3. Punch Zoom 放大彈回", 2, _on_punch_zoom_pressed)
	_add_test_button("4. Fade to Black 黑屏轉場", 3, _on_fade_black_pressed)
	_add_test_button("5. 立繪淡入淡出", 4, _on_sprite_fade_pressed)
	_add_test_button("6. Ken Burns 緩慢縮放位移", 5, _on_ken_burns_pressed)


func _add_test_button(label: String, index: int, callback: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.position = Vector2(400, BUTTON_START_Y + index * BUTTON_GAP)
	button.custom_minimum_size = Vector2(240, 0)
	button.pressed.connect(callback)
	add_child(button)


func _on_shake_pressed() -> void:
	effects.shake(target_box)


func _on_flash_pressed() -> void:
	effects.flash()


func _on_punch_zoom_pressed() -> void:
	effects.punch_zoom(target_box)


func _on_fade_black_pressed() -> void:
	await effects.fade_to_black()
	await get_tree().create_timer(0.3).timeout
	await effects.fade_from_black()


func _on_sprite_fade_pressed() -> void:
	sprite_fade_target_visible = not sprite_fade_target_visible
	effects.fade_sprite_visibility(target_box, sprite_fade_target_visible)


# 測試用duration縮短成2秒（正式使用duration通常是10秒以上，測試時等
# 太久不好驗證）。連續按這顆按鈕會在兩個目標之間來回，重點是要驗證
# 「目前值當起點」而不是「先跳回原點再動」——修正前的版本每次呼叫都會
# 先把scale/position重設成(1,1)/(0,0)，造成使用者回報的抖動/像lag的
# 問題，連續按下這顆按鈕時應該看到平滑地從目前位置繼續移動到新目標，
# 不會有瞬間跳回原點的頓挫感。
var ken_burns_toggle := false

func _on_ken_burns_pressed() -> void:
	ken_burns_toggle = not ken_burns_toggle
	var zoom := effects.KEN_BURNS_DEFAULT_ZOOM if ken_burns_toggle else 1.0
	var pan := effects.KEN_BURNS_DEFAULT_PAN if ken_burns_toggle else Vector2.ZERO
	effects.ken_burns(bg_test_rect, bg_test_rect_base_size, zoom, pan, 2.0)
