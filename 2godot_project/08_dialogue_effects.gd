extends Control

# ------------------------------
# 零件說明
# ------------------------------
# 「劇情特效」零件：提供Story Dialogue UI（02）共用的畫面特效——震動
# (shake)、全螢幕閃光(flash)、瞬間放大彈回(punch_zoom)、黑屏轉場
# (fade_to_black/fade_from_black)、角色立繪淡入淡出(fade_sprite_
# visibility)。本身不認識DIALOGUE_LINES/case_data任何劇本內容，只認得
# 「要對哪個節點做什麼效果、做多久」，由呼叫端（02_story_dialogue_ui_
# demo.gd）依對白資料的"effect"欄位決定何時呼叫，對齊「零件先行」原則
# 跟COUNTIF引擎「不綁定特定問題」的精神一樣，這裡不綁定特定對白文字。
#
# 用法：跟05_ui_tweaker_tool一樣是可以`add_child()`掛載的工具節點，
# 掛上去後鋪滿父節點（用PRESET_FULL_RECT），呼叫端拿到實體後直接呼叫
# 上面五個public函式即可。
#
# 獨立測試：見08_dialogue_effects_test.gd/.tscn，5顆按鈕分別觸發。

# ------------------------------
# 設定區：效果參數預設值（呼叫端可覆寫，但沒指定時用這些，避免到處
# 重複寫魔法數字）
# ------------------------------
const SHAKE_DEFAULT_MAGNITUDE := 6.0      # 震動位移幅度（像素），刻意偏小，對齊「安靜懸疑」調性
const SHAKE_DEFAULT_DURATION := 0.3
const SHAKE_OSCILLATIONS := 4             # 震動來回幾次，次數太多會拖長動畫、看起來像故障而非衝擊

const FLASH_DEFAULT_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const FLASH_DEFAULT_DURATION := 0.25
const FLASH_PEAK_ALPHA := 0.85            # 不用滿不透明，避免畫面瞬間全白到看不見任何東西

const PUNCH_ZOOM_DEFAULT_SCALE := 1.08
const PUNCH_ZOOM_DEFAULT_DURATION := 0.18

const FADE_BLACK_DEFAULT_DURATION := 0.4
const FADE_BLACK_COLOR := Color(0.0, 0.0, 0.0, 1.0)

const SPRITE_FADE_DEFAULT_DURATION := 0.25

# 背景緩慢縮放/位移（Ken Burns效果）：靜態場景背景一直完全靜止會顯得
# 死板，套一個很慢、幾乎看不出來在動的緩慢放大+平移，畫面會有呼吸感。
# 幅度跟shake/punch_zoom刻意拉開等級差——這是「察覺不到正在動，但比較
# 久之後會發現畫面變了」的慢速效果，不是強調用的快動畫。
const KEN_BURNS_DEFAULT_ZOOM := 1.06
# pan_factor是x/y各自-1~1的方向係數（不是像素），0=不偏移、往正負1的
# 方向貼到放大後多出來的範圍邊界，實際像素由ken_burns()依base_size跟
# zoom_to算出來。
const KEN_BURNS_DEFAULT_PAN := Vector2(-1.0, -0.5)
const KEN_BURNS_DEFAULT_DURATION := 16.0


# ------------------------------
# 狀態區：畫面節點
# ------------------------------
var overlay: ColorRect
# 記著目前正在跑Ken Burns效果的target跟它的Tween，換新背景時要先把
# 上一個殺掉再重設scale/position，否則舊的動畫還在跑會跟新動畫打架，
# 而且如果不重設、每次都從「上次動畫跑到一半的位置」繼續算，位移會
# 一次比一次偏，越換背景畫面就越歪。
var ken_burns_target: Control
var ken_burns_tween: Tween
# Godot的Control預設會吸附到整數像素；慢速移動背景時會形成「停幾幀、
# 跳一像素」的階梯感。Ken Burns播放期間暫時關閉所屬Viewport的GUI像素
# 吸附，結束或零件離開場景時再還原，不永久改變其他UI的清晰度設定。
var ken_burns_viewport: Viewport
var ken_burns_previous_pixel_snap := true
var is_ken_burns_pixel_snap_overridden := false
var ken_burns_animation_id := 0


# ------------------------------
# 建構
# ------------------------------
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	overlay = ColorRect.new()
	overlay.name = "EffectsOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color(1.0, 1.0, 1.0, 0.0)
	add_child(overlay)


func _exit_tree() -> void:
	_restore_ken_burns_pixel_snap()


# ------------------------------
# 核心邏輯：畫面特效
# ------------------------------

## 震動：target在原位置附近左右/上下快速來回擺動，結束後精準回到原位置。
## 用在情緒衝擊瞬間（被拆穿、聽到壞消息），target通常是整個畫面的根
## Control或對話框面板。
func shake(target: Control, magnitude: float = SHAKE_DEFAULT_MAGNITUDE, duration: float = SHAKE_DEFAULT_DURATION) -> void:
	var original_position: Vector2 = target.position
	var tween := create_tween()
	var step_duration: float = duration / float(SHAKE_OSCILLATIONS * 2)

	for i in range(SHAKE_OSCILLATIONS):
		# 每次來回幅度遞減，模擬震動逐漸停止，而不是固定幅度後突然停住。
		var current_magnitude: float = magnitude * (1.0 - float(i) / float(SHAKE_OSCILLATIONS))
		var offset := Vector2(current_magnitude, 0.0) if i % 2 == 0 else Vector2(-current_magnitude, 0.0)
		tween.tween_property(target, "position", original_position + offset, step_duration)

	tween.tween_property(target, "position", original_position, step_duration)


## 全螢幕閃光：疊一層半透明色快速亮起再淡出，用在揭曉/真相確認瞬間。
func flash(color: Color = FLASH_DEFAULT_COLOR, duration: float = FLASH_DEFAULT_DURATION) -> void:
	var peak_color := Color(color.r, color.g, color.b, FLASH_PEAK_ALPHA)
	var transparent_color := Color(color.r, color.g, color.b, 0.0)

	overlay.color = transparent_color
	var tween := create_tween()
	tween.tween_property(overlay, "color", peak_color, duration * 0.2)
	tween.tween_property(overlay, "color", transparent_color, duration * 0.8)


## 瞬間放大彈回：target從原比例快速放大到scale_amount，再彈回原比例，
## 用在強調關鍵台詞/證據（呼應Ace Attorney式「這就是矛盾點」演出）。
func punch_zoom(target: Control, scale_amount: float = PUNCH_ZOOM_DEFAULT_SCALE, duration: float = PUNCH_ZOOM_DEFAULT_DURATION) -> void:
	target.pivot_offset = target.size / 2.0
	var original_scale: Vector2 = target.scale

	var tween := create_tween()
	tween.tween_property(target, "scale", original_scale * scale_amount, duration * 0.4)
	tween.tween_property(target, "scale", original_scale, duration * 0.6)


## 黑屏轉場（淡入黑幕）：用在大場景/章節切換前，呼叫端await這個函式
## 結束後再切換背景/對白內容，切完再呼叫fade_from_black()淡出黑幕。
func fade_to_black(duration: float = FADE_BLACK_DEFAULT_DURATION) -> void:
	overlay.color = Color(FADE_BLACK_COLOR.r, FADE_BLACK_COLOR.g, FADE_BLACK_COLOR.b, 0.0)
	var tween := create_tween()
	tween.tween_property(overlay, "color", FADE_BLACK_COLOR, duration)
	await tween.finished


## 黑屏轉場（淡出黑幕，露出底下新的畫面內容）。
func fade_from_black(duration: float = FADE_BLACK_DEFAULT_DURATION) -> void:
	var transparent_black := Color(FADE_BLACK_COLOR.r, FADE_BLACK_COLOR.g, FADE_BLACK_COLOR.b, 0.0)
	var tween := create_tween()
	tween.tween_property(overlay, "color", transparent_black, duration)
	await tween.finished


## 角色立繪淡入淡出：取代「瞬間visible=true/false」的切換方式。
## target_visible=true時，先把節點設成visible再把透明度從0淡入到1；
## target_visible=false時，先把透明度淡出到0再把節點設成不可見，避免
## 切換瞬間留下完全不透明的殘影。
func fade_sprite_visibility(sprite: CanvasItem, target_visible: bool, duration: float = SPRITE_FADE_DEFAULT_DURATION) -> void:
	var tween := create_tween()
	if target_visible:
		sprite.visible = true
		sprite.modulate.a = 0.0
		tween.tween_property(sprite, "modulate:a", 1.0, duration)
	else:
		tween.tween_property(sprite, "modulate:a", 0.0, duration)
		tween.finished.connect(func() -> void:
			sprite.visible = false
			sprite.modulate.a = 1.0
		)


## 背景緩慢縮放/位移：**不用Control的scale/pivot_offset transform**，
## 改成直接動畫`offset_left/top/right/bottom`四個錨點偏移值，讓滿版
## 背景的矩形本身往外長大（=zoom）、整個矩形再往pan_factor方向偏移
## （=pan），靠STRETCH_KEEP_ASPECT_COVERED自然把放大後的範圍畫滿、蓋住
## 多出來的部分。改用這個做法是因為scale+pivot_offset的版本經使用者
## 實測仍會有「上下抖動」，懷疑是Control transform跟錨點佈局系統互相
## 影響；offset版本排除了transform/pivot互相影響，但實測仍會出現緩慢
## 上下移動像卡頓的階梯感。原因是Control預設吸附整數像素，所以本函式
## 播放期間會暫時關閉Viewport的GUI像素吸附，結束後還原原設定。
##
## base_size是target在offset全部=0（也就是「沒有放大」）時的原始尺寸，
## 呼叫端要在背景剛建立、offset還是0的時候量一次存起來，不能用
## target.size現場量（動畫進行中target.size已經反映「放大後」的尺寸，
## 拿來算新目標會越算越大）。pan_factor是x/y各自-1~1的方向係數（0=不動，
## 1/-1=貼到對應邊界）。動畫永遠從「目前實際的offset」過渡到新目標，
## 不會先跳回0，連續設定同一個目標不會有回彈的頓挫感。
func ken_burns(target: Control, base_size: Vector2, zoom_to: float = KEN_BURNS_DEFAULT_ZOOM, pan_factor: Vector2 = Vector2.ZERO, duration: float = KEN_BURNS_DEFAULT_DURATION) -> void:
	if ken_burns_tween != null and ken_burns_tween.is_valid():
		ken_burns_tween.kill()

	ken_burns_animation_id += 1
	var animation_id := ken_burns_animation_id
	_override_ken_burns_pixel_snap(target.get_viewport())

	var margin: Vector2 = (zoom_to - 1.0) / 2.0 * base_size
	var shift: Vector2 = pan_factor * margin
	var target_left: float = -margin.x + shift.x
	var target_right: float = margin.x + shift.x
	var target_top: float = -margin.y + shift.y
	var target_bottom: float = margin.y + shift.y

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(true)
	tween.tween_property(target, "offset_left", target_left, duration)
	tween.tween_property(target, "offset_top", target_top, duration)
	tween.tween_property(target, "offset_right", target_right, duration)
	tween.tween_property(target, "offset_bottom", target_bottom, duration)
	tween.finished.connect(func() -> void:
		# 舊Tween被新指令取代時不可以提早恢復像素吸附，否則新動畫播放到
		# 一半又會重新出現逐像素跳動。
		if animation_id == ken_burns_animation_id:
			_restore_ken_burns_pixel_snap()
	)

	ken_burns_target = target
	ken_burns_tween = tween


# ------------------------------
# 共用輔助函式：Ken Burns像素吸附管理
# ------------------------------

func _override_ken_burns_pixel_snap(viewport: Viewport) -> void:
	if is_ken_burns_pixel_snap_overridden:
		return

	ken_burns_viewport = viewport
	ken_burns_previous_pixel_snap = viewport.gui_snap_controls_to_pixels
	viewport.gui_snap_controls_to_pixels = false
	is_ken_burns_pixel_snap_overridden = true


func _restore_ken_burns_pixel_snap() -> void:
	if not is_ken_burns_pixel_snap_overridden:
		return

	if is_instance_valid(ken_burns_viewport):
		ken_burns_viewport.gui_snap_controls_to_pixels = ken_burns_previous_pixel_snap

	ken_burns_viewport = null
	is_ken_burns_pixel_snap_overridden = false
