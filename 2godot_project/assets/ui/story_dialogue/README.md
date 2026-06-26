# Story Dialogue UI Skin Kit v0.1

這個資料夾放 Story Dialogue UI Component 使用的 PNG skin。

文字不要畫死在圖片裡。PNG 只負責框、底色、邊線、光感；按鈕文字、對白文字、案件目標文字都由 Godot UI 顯示。

---

## Button States

### 通用外框按鈕（彈窗關閉鈕、案件目標收合鈕、存檔格動作鈕共用）

| File | Purpose |
|---|---|
| `button_icon_frame_normal.png` | 通用小按鈕 normal 狀態（搭配文字/符號） |
| `button_icon_frame_hover.png` | 通用小按鈕 hover 狀態 |
| `button_icon_frame_pressed.png` | 通用小按鈕 pressed 狀態 |
| `button_story_small_normal.png` / `_hover.png` / `_pressed.png` | 早期版本的右上小按鈕，已被下方`button_top_*`取代，保留作比較用 |

### 右上角五個功能鈕（保存／讀取／設定／紀錄／自動）

來源美術：`1UI/main_menus/top_menu_ui_normal|hover|click`。每個狀態都是「圖示+外框」已合成好的完整美術圖，不是通用外框疊icon。

| File | Purpose |
|---|---|
| `button_top_<key>_normal.png` | `<key>`為`save`/`load`/`settings`/`log`/`auto`，對應按鈕normal狀態 |
| `button_top_<key>_hover.png` | hover狀態 |
| `button_top_<key>_pressed.png` | pressed狀態（原始素材資料夾稱為click） |

這5×3張圖已經統一處理成284×258的透明畫布。處理邏輯演進過程：

1. 直接用任意alpha>0的bounding box去裁切置中——hover原圖的alpha>0範圍
   含柔邊光暈（約256×232），比normal的alpha>0範圍（約203×172）大很多，
   若把兩者的bounding box直接拉到同一大小，等於把hover「真正的圖案核心」
   縮小了約25%，三態切換時還是會感覺在縮放。
2. **目前採用**：用「高alpha門檻（核心圖案的最大透明度的60%）」分別找出
   normal/hover/pressed各自的**核心圖案bounding box**（排除柔邊光暈），
   確認三者核心大小幾乎完全一致（差異<1px，不需要縮放）。裁切時保留
   hover原本完整的柔邊光暈（不裁掉、不縮放），但貼到畫布時用「核心圖案
   中心」對齊畫布中心，而不是用含光暈的整張bounding box對齊。
   這樣三態的「圖案本體」像素級對齊一致，hover只是核心外圍多了一圈
   自然的柔邊光暈，不會看起來像整體被放大或縮小。
`02_story_dialogue_ui_demo.gd`裡的`MENU_BUTTON_SIZE`維持小尺寸（64x56），
五個按鈕在右上角排開不會互相覆蓋。

---

## Panels

| File | Purpose |
|---|---|
| `panel_dialogue_box.png` | 早期版本對白框，已被`_ornate`版取代，保留作比較用 |
| `panel_dialogue_box_ornate.png` | 目前使用的正式對白框，來源`1UI/story_dialogue/dialogue_box.png`，已裁到不透明邊界+8px留白 |
| `panel_name_plate.png` | 早期版本姓名框，已被`_ornate`版取代，保留作比較用 |
| `panel_name_plate_ornate.png` | 目前使用的正式姓名框，來源`1UI/story_dialogue/name_tag.png`，已裁到不透明邊界+8px留白 |
| `panel_case_objective.png` / `panel_case_objective_ornate.png` | 小型案件目標面板（ornate為目前使用的正式版，也兼用於存檔格、調查紀錄項目） |
| `panel_character_placeholder.png` | 暫時用的角色立繪 placeholder 外框，已不再使用 |

---

## Backgrounds

| File | Purpose |
|---|---|
| `bg_detective_office_temp.png` | 早期幾何 placeholder 背景，保留作比較用 |
| `bg_detective_office_rainy_night.png` | Story Dialogue UI 目前使用的雨夜偵探所正式背景，來源是`1bg/bg_detective_office_rainy_night.png` |

---

## Godot Usage

目前 `02_story_dialogue_ui_demo.gd` 用 `StyleBoxTexture` 讀取面板類PNG，
右上角五個功能鈕改用 `TextureButton` 直接讀取`button_top_*`三態貼圖。

之後如果要正式拆零件，可以把它們分別接到：

- `DialogueBox`
- `NamePlate`
- `TopRightMenu`
- `CaseObjectiveMiniPanel`
