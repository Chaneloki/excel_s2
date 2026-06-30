# 案件資料結構（data/cases）

這個資料夾放「案件資料結構」零件的JSON資料檔，跟UI完全解耦——
`02_story_dialogue_ui_demo.gd`（Story Dialogue UI）跟
`01_excel_simulator_step1_countif.gd`（Excel解謎器）都改成讀這裡的
JSON，不再各自把對白/案件目標/可用函數清單寫死在程式碼裡。

讀取邏輯見 [`07_case_data.gd`](../../07_case_data.gd)（`CaseData`），
獨立測試見 [`07_case_data_test.gd`](../../07_case_data_test.gd) /
[`07_case_data_test.tscn`](../../07_case_data_test.tscn)。

## 檔案

| 檔案 | 用途 |
|---|---|
| `case_01.json` | 案件一《缺席者的名字》（第1章）完整資料：對白腳本、案件目標、Excel解謎器三關（COUNTIF/COUNTIFS/SUMIF）設定、登場角色立繪＋表情差分對照、場景背景／CG插畫對照、存檔用章節/地點/狀態文字。內容對齊 [3case/case1_script_draft_v0.1.md](../../../3case/case1_script_draft_v0.1.md) v1.0 劇本與附錄A。 |

## JSON結構

```text
{
  "case_id", "case_title", "chapter_id", "chapter_name",
  "save_data": { "location", "status" },
  "characters": {
    "<character_id>": {
      "name", "sprite",
      "expressions": { "<expression_id>": "<圖檔路徑>" }
    }
  },
  "backgrounds": { "<background_id>": "<圖檔路徑>" },
  "cg_images": { "<cg_id>": "<圖檔路徑>" },
  "bgm_tracks": { "<bgm_id>": "<音檔路徑>" },
  "objectives": [ { "id", "text" } ],
  "excel_stages": [
    {
      "stage_id", "scene_ref", "title",
      "available_functions": [...],
      "objective_text", "formula_skeleton", "fixed_answer_note",
      "success_message", "unsupported_formula_message"
    }
  ],
  "dialogue": [
    {
      "id", "scene_id",
      "type": "dialogue" | "narration" | "system" | "hotspot" | "excel_stage_trigger",
      "speaker_id", "speaker_name", "text",
      "objective_update": "<objective id，可省略>",
      "stage_id": "<excel_stage_trigger專用，指向excel_stages的stage_id>",
      "effect": "<可省略，shake/flash/punch_zoom，見08_dialogue_effects.gd>",
      "background": "<可省略，指向backgrounds的id，這句話開始要換成這個背景>",
      "bgm": "<可省略，指向bgm_tracks的id，這句話開始要換成這首背景音樂>",
      "se": "<可省略；可填單一檔名或檔名陣列，陣列內音效會同時播放>",
      "bg_zoom": "<可省略，普通背景或CG縮放到的倍率，例如1.06，沒填沿用上一次設定過的值>",
      "bg_pos": "<可省略，普通背景或CG往哪個方向靠，值見下方bg_pos關鍵字表，沒填沿用上一次設定過的值>",
      "bg_zoom_duration": "<可省略，縮放/位移花多久秒數，沒填用09_chapter1_dialogue.gd的BG_ZOOM_DEFAULT_DURATION預設值>",
      "expression": "<可省略，指向該speaker_id的expressions，沒填或對不到就用sprite預設圖>",
      "scene": "<可省略，值為\"cg\"時這句進入CG全螢幕模式>",
      "cg": "<scene為cg時才有意義，指向cg_images的id>"
    }
  ]
}
```

- **`scene_id`欄位 vs `scene`欄位**：兩者是完全不同的東西，命名很像但故意分開，
  別搞混——`scene_id`只是給人看的劇本場景標籤（對應劇本①～⑩，例如`"s04"`，
  純粹方便人類對照劇本，程式不靠它做任何判斷）；`scene`是Story Dialogue UI
  （02）真正會讀的旗標，目前唯一有意義的值是`"cg"`，代表這句要切換成全螢幕CG
  插畫模式（見`02_story_dialogue_ui_demo.gd`的`_resolve_display_line()`／
  `_show_line()`）。早期版本兩者曾經共用同一個`"scene"`鍵名，導致CG判斷永遠
  比對不到`"cg"`字串、CG模式完全沒被觸發過，發現後拆成兩個欄位修正。
- **Chapter 1純故事模式**：目前`09_chapter1_dialogue.gd`只播放
  `dialogue`／`narration`／`system`，會自動略過`hotspot`與
  `excel_stage_trigger`。這兩種結構資料仍保留在JSON，未來重新接回地圖
  或數據計算儀時不需要重寫劇本。
- **`effect`欄位**：對應[08_dialogue_effects.gd](../../08_dialogue_effects.gd)（劇情特效零件）支援的效果——`shake`（震動，衝擊瞬間）、`flash`（全螢幕白閃，揭曉瞬間）、`punch_zoom`（瞬間放大彈回，強調關鍵句）。沒有這個欄位代表這句話不觸發任何特效，純文字播放。
- **`background`欄位**：值是`backgrounds`字典的id。`02_story_dialogue_ui_demo.gd`的`_switch_background()`處理：劇情開場第一次設定背景時直接換貼圖（沒有「前一張背景」可以淡出，跳過轉場）；之後每次真的換到不同背景，才透過`08_dialogue_effects.gd`的`fade_to_black()`/`fade_from_black()`包住換貼圖的瞬間，不是瞬間切圖。只需要在「換到新場景的第一句」標記，沒換場景的句子不用重複填。
- **`bgm`欄位**：值是`bgm_tracks`字典的id，目前只有[整合Demo](../09_chapter1_dialogue.gd)接上（`_switch_bgm()`），02獨立demo沒有這個功能（02沒有BGM播放器節點）。第一次開始播放直接`play()`，之後每次換成不同曲目會先淡出、換`stream`、再淡入，不是硬切。填空字串或不存在於`bgm_tracks`的id會停止目前BGM；不存在的id另會輸出警告，方便發現拼字或資料錯誤。設定彈窗的「BGM音量」滑桿會直接控制播放器音量。
- **`se`欄位**：可填[assets/se](../../assets/se)內不含`.mp3`的單一檔名，例如`"se":"door_open"`；也可填陣列，例如`"se":["door_open","bell"]`，陣列內音效會使用各自的播放器同時播放。SE不會中斷BGM，所有正在播放的SE都由設定彈窗的「音效音量」滑桿共同控制，播完後播放器會自動移除。
- **`expression`欄位**：值是該句`speaker_id`對應角色的`expressions`字典裡的id。沒填、或填了角色根本沒有這個表情，都會自動退回該角色的預設`sprite`，不會報錯或留白。表情切換目前是「直接換貼圖」，沒有交叉淡化動畫；同一位角色換另一張立繪（例如换成別的角色說話）也是直接換貼圖，只有「顯示/隱藏」這個動作才會走`fade_sprite_visibility()`淡入淡出。
- **`bg_zoom`／`bg_pos`／`bg_zoom_duration`欄位**：背景緩慢縮放/位移
  （呼應[08_dialogue_effects.gd](../../08_dialogue_effects.gd)的
  `ken_burns()`），做法參考使用者舊作v2專案`code/ui_v2_story.js`的
  "sticky camera"設計（`currentBgZoom`/`currentBgFx`/`currentBgFy`
  持久狀態＋CSS `transition: transform`），不是自己發明的格式：
  - **逐句手動標記，不是換背景就自動觸發**——只有這句話真的帶了
    `bg_zoom`或`bg_pos`才會更新鏡頭目標，沒帶這兩個欄位的句子完全不會
    去動背景的縮放/位移，前一句還在跑、還沒跑完的動畫會繼續跑完，不會
    被打斷或重置。
  - **CG沿用完全相同的欄位**：當該句有`"scene":"cg"`時，運鏡會套在
    `cg_image_rect`；一般句則套在場景背景。CG不需要另外發明`cg_zoom`或
    `cg_pos`欄位，例如`"scene":"cg", "cg":"cg1", "bg_zoom":1.08,
    "bg_pos":"left"`即可讓CG緩慢放大並往左取景。
  - **`bg_pos`是方向關鍵字，不是座標**：`center`/`left`/`right`/`top`/
    `bottom`/`left bottom`/`right bottom`/`left top`/`right top`/
    `center bottom`，對照v2的`posFactors`表算出方向係數`(fx,fy)`
    （每個成分只會是-1/0/1），再乘上「縮放倍率產生的多餘範圍」算出實際
    要位移多少像素——縮放越大、可以位移的範圍越大，但永遠不會超出縮放
    後多出來的範圍，不會露出背景圖以外的空白，也不需要自己猜安全的像素
    數字。
  - **不用Control的scale/pivot_offset transform，改成直接動畫
    offset_left/top/right/bottom**：`ken_burns()`歷經兩輪修正——v1用
    scale+pivot_offset，每次呼叫強制重設成`scale=(1,1)`/`position=
    (0,0)`再開始動畫，使用者回報「看起來像lag、會抖動」；改成「目前值
    當起點」（不強制重設）後實測仍會抖動，懷疑是scale/pivot_offset這套
    Control transform本身的問題；v3改成完全不碰scale/pivot_offset，
    直接動畫滿版背景Control的四個錨點偏移值，讓矩形本身往外長大再整體
    偏移，這是Godot裡改變Control尺寸最基本的方式，理論上不會有transform
    層級的問題。換新target時只殺掉前一個target身上還在跑的Tween，不會
    重設offset數值，所以連續幾句設定同一個方向時，畫面只是順順地持續
    往那個方向靠近，不會看到回彈。
- **CG模式（`scene`:`cg`）**：`cg`欄位指向`cg_images`的id，`_show_line()`會把對應的圖設成`cg_image_rect`的texture並顯示；如果`cg`欄位是空的或對不到任何id，`cg_image_rect`維持隱藏，畫面會退回顯示`cg_layer`原本的佔位色+「CG（佔位）」文字，不會整個畫面開窗。CG模式下不顯示姓名牌跟角色立繪（沿用既有規則），只有矮文字條+全螢幕插畫。

## 規則

- **乾淨資料固定不變**：`excel_stages`裡的`fixed_answer_note`只是給程式/
  劇本對照用的人類可讀說明，不是Excel解謎器實際運算用的儲存格資料。
  各關卡實際的表格數值（簽到名冊/離場記錄/區域進出記錄/費用明細）屬於
  Excel解謎器零件自己的資料生成範圍（裝飾性資料邏輯生成、破案關鍵資料
  寫死），不在這份檔案內，避免案件資料結構跟Excel解謎器表格渲染邏輯
  綁死。
- **dialogue陣列的`type`欄位**：
  - `dialogue` / `narration` / `system`：對應 story_dialogue_ui_component_
    spec_v0.1.md 第6節三種對白類型，`narration`沒有`speaker_id`，姓名牌
    隱藏，畫面上也不會顯示任何角色立繪（即使該角色其實在場——目前引擎
    只在「這句的speaker_id是誰」時才顯示對應立繪）。
  - `hotspot`：對應劇本裡的〔走查熱點〕標記，純文字記錄，之後Map Walker
    要接上真實熱點時可參照。
  - `excel_stage_trigger`：劇情該進入Excel解謎器的時間點，`stage_id`
    對應`excel_stages`裡的關卡，串接邏輯留給整合Demo零件處理。
- **角色立繪／表情差分**：`characters`的`sprite`是預設立繪，`expressions`
  是可選的表情差分對照（複製自`1char/host_face/`、`1char/sophia_face/`、
  `1char/case1_npc/belot/`正式素材，去背PNG）。貝洛特的3張表情（calm太
  鎮定／cracking裂縫僵硬／silent_warning沉默警告，得體假笑是預設sprite）
  直接對應他在場景⑨對質過程的情緒轉折；host/sophia的表情差分則是比較
  誇張的「反應表情」（confidence／dramatic_cry／fake_serious／fake_
  stupid／no_comment／elegant／funny_think／please／pretend_accept），
  用在台詞語氣明顯誇張、好笑、或情緒轉折的句子上，不是每句都要配。某個
  角色若真的還沒有任何美術素材，`sprite`留空字串，Story Dialogue UI
  讀到空字串時不顯示立繪，不需要改資料結構。
- 新增章節時，在這個資料夾新增`case_0X.json`（或同案件多章節時自行
  決定`chapter_id`/`case_id`命名），不要直接改寫`case_01.json`既有內容。
- **不再用「」標記角色說的話**：姓名牌已經顯示是誰在說話，`「」`是
  多餘的視覺重複，所以`text`欄位裡的角色台詞一律是不加引號的純文字。
  `「」`改成完全不使用；如果原本劇本裡有用`（動作/表情描述）`標示角色
  說話時的動作或表情（例如原劇本的「我（看了看門）：」），轉成資料時
  保留這個`（動作描述）`前綴、去掉人名跟冒號，變成`"（看了看門）設計圖
  最後就放在這裡的文件袋。"`——`（）`現在的用途是動作/表情描述，不是
  引號。**沒有姓名牌的句子（`narration`／`system`，沒有`speaker_id`）
  不需要`（）`**：旁白本來就沒有名牌可以對應「這是誰的動作」，原始劇本
  裡單純當「旁白標記」用的`（旁白）`前綴、或整句純粹拿來當舞台指示的
  外層括號，轉成資料時都直接拿掉，旁白就是普通敘述文字。
- **`text`欄位的換行規則**：每一句最多40個中文字（含標點）。超過40字
  要換行，但**只能在完整句子結束處換行**（句尾是。！？），**逗號不算
  句子結束，不能在逗號處換行**；如果單一句子本身就超過40字，整句維持
  原樣不拆，寧可那一行超過40字，也不要把一句話從中間切斷。
  **每一行最後都會是獨立的`dialogue`陣列項目，不是同一句text裡用`\n`
  換行**：旁白／角色台詞／拆出來的下一句，只要依上面規則判定成不同行，
  就會拆成各自獨立的JSON物件（各自一次點擊、各自顯示在自己的對話框
  畫面），id用`-2`、`-3`……接續原id（例如`ch1_0020`拆成`ch1_0020`／
  `ch1_0020-2`），不會擠在同一個對話框畫面裡造成文字溢出框外。背景/CG/
  特效/案件目標更新這類「轉場類」欄位只留在拆出來的第一個物件上，不會
  因為拆分被重複觸發。
  寫新對白時手動套用這幾條規則；既有內容已用腳本套用過（保留全部原文，
  只調整換行/分句/拆分位置，沒有刪減任何文字）。
