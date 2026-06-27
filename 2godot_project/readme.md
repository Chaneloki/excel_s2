# excel_game_s2 Godot 專案

這個資料夾是 `excel_game_s2` 的 Godot 專案。

採用「零件式」開發：每一個主要玩法或 UI 都先獨立做成清楚命名的 scene，
穩定後再組成完整遊戲。每個零件的檔名前面都有**編號**（`01_`、`02_`...），
方便在檔案越來越多時快速辨認與排序，編號代表零件建立的先後順序，
不代表遊戲內實際執行順序。

---

## 目前主場景

```text
res://02_story_dialogue_ui_demo.tscn
```

這是目前最新的UI零件：Story Dialogue UI Component v0.1 prototype。

---

## 檔案說明

| 檔案 | 用途 |
|---|---|
| `project.godot` | Godot 專案設定。主場景指向 `02_story_dialogue_ui_demo.tscn`。 |
| `01_excel_simulator_step1_countif.tscn` | Excel解謎器（數據計算儀）第1個零件：COUNTIF原型 scene。 |
| `01_excel_simulator_step1_countif.gd` | COUNTIF原型的程式邏輯，內部依「設定→建構→輸入處理→運算核心→公式解析」分區，詳見檔案內註解。 |
| `02_story_dialogue_ui_demo.tscn` | Story Dialogue UI 第2個零件：劇情對話畫面 demo scene。 |
| `02_story_dialogue_ui_demo.gd` | Story Dialogue UI 的程式邏輯，內部依「設定→建構→輸入處理→彈窗互動→自動播放→對白播放→共用輔助函式」分區，詳見檔案內註解。之後可再拆成 DialogueBox、NamePlate、CharacterSpriteLayer 等更小的子零件。存讀檔彈窗（`SaveLoadPopup_CaseFiles`）已用`1UI/save_load`正式美術零件做出6格案件檔案格，由右上角「保存」「讀取」按鈕共用，依模式決定空白格是否可點擊。 |
| `assets/ui/story_dialogue/` | Story Dialogue UI 使用的 PNG skin，包括對白框、姓名框、案件目標面板，以及右上角保存/讀取/設定/紀錄/自動五個功能鈕的`button_top_<功能>_<狀態>.png`（每個狀態都是圖示+外框合成好的完整美術圖，來源是`1UI/main_menus/top_menu_ui_normal\|hover\|click`）。 |
| `assets/ui/save_load/` | 存讀檔彈窗使用的 PNG skin（主面板、空白格、已存檔格、選取高亮框），來源是`1UI/save_load/`，細節見資料夾內README。 |
| `app_icon.svg` | Godot 專案 icon。 |
| `.godot/` | Godot 自動產生的專案快取資料夾，不需要手動修改。 |

---

## Story Dialogue UI v0.1 範圍

目前 demo 已有：

- 偵探所背景 placeholder
- Host 立繪 placeholder
- 姓名框
- 對白框
- 點擊滑鼠左鍵下一句
- Space / Enter 下一句
- 右上角按鈕：保存、讀取、設定、紀錄、自動
- 小型案件目標面板，可展開/收合
- 設定 prototype：BGM / SFX 音量 slider，暫時只保存畫面數值
- 保存/讀取 prototype：案件簿彈窗與6個存檔格 UI（套用正式save_load美術，2排x3欄），讀取模式空白格不可點擊，暫時不寫入實際檔案
- 紀錄 prototype：可滾動調查紀錄彈窗，暫時從 demo 對白生成
- 自動播放 prototype：按鈕切換自動播放狀態，手動點擊時會關閉
- Host 透明立繪 prototype
- 測試對白資料

目前 demo 暫時不做：

- 真正保存 / 讀取檔案
- 真正設定資料持久化與 AudioBus 連接
- 真正隨玩家閱讀進度追加的對白紀錄
- 角色最終正式立繪
- 背景正式美術
- Excel Solver 連接
- Map Walker 連接
- 獨立 Save/Load、Settings、Dialogue Log 場景；目前這些只是在 Story Dialogue UI 內做可互動 prototype

---

## Map Walker 技術路線（已定案）

曾經試做過「3D box-out場景 + 第一人稱固定觀察點」（`03_map_walker_3d_lite_demo`）
驗證NPC比例問題，但實測發現門/旗幟/展示桌這類2D插畫貼上3D幾何後，視覺上仍有明顯
「貼紙感」，品質天花板不夠高，**該demo已移除**。

Map Walker正式定案改用**純2D環境插畫＋熱點彈出特寫卡**：畫面是一張完整的AI生成
場景插畫（不放玩家自己的avatar，因此不需要處理avatar比例問題），玩家點擊熱點
（放大鏡icon）後彈出對應的特寫卡片。場景插畫見`3case/case1_bg/`，多機位9宮格
（鏡位備選）見`3case/case1_bg_grid9/`，生成prompt見`3case/case1_bg_prompts_flat_v1.md`。

---

## 怎麼打開

1. 打開 Godot。
2. Import / Open project。
3. 選擇這個資料夾裡的 `project.godot`。
4. 按 Play / F5。

如果 Godot 問要不要載入目前主場景，選擇 `02_story_dialogue_ui_demo.tscn`。

---

## 命名規則

1. **全部小寫 + 底線**：不使用空白或大寫字母（例如 `story_dialogue_ui_mockup.png`，
   不要 `UI_style_guide v0.1.md`）。
2. **編號前綴**：每個零件的`.gd`/`.tscn`檔名前面加兩位數編號（`01_`、`02_`...），
   同一個零件的`.gd`跟`.tscn`要用同一個編號，方便配對辨識。
3. **檔名要清楚反映用途**：禁止 `test`、`scene1`、`new_script`、`main` 這種
   無意義命名。
4. 例外：Godot 規定的固定檔名（`project.godot`）跟自動生成的快取/匯入檔
   （`.godot/`、`*.uid`、`*.import`）不受此規則限制，不要手動改它們的名字。

建議之後新零件依此規則命名：

- `03_excel_simulator_step2_sumif.gd` / `.tscn`
- `04_save_load_ui_demo.gd` / `.tscn`
- `05_settings_ui_demo.gd` / `.tscn`
- `06_map_walker_demo.gd` / `.tscn`（純2D環境插畫+熱點彈出特寫卡版本）

---

## 程式碼規範

1. **所有註解使用繁體中文**，並依邏輯執行順序分區說明（設定 → 建構 →
   輸入處理 → 核心邏輯），參考`01_excel_simulator_step1_countif.gd`跟
   `02_story_dialogue_ui_demo.gd`檔案開頭的區塊註解寫法。
2. **禁止不必要的硬編碼**：重複出現的顏色、字體大小、間距、版面數字，
   一律在檔案最上面的「設定區」集中定義成具名常數，函式裡只能引用
   常數，不能直接寫魔法數字/顏色字串。
3. 結構性常數（畫面版面設計本身的參數，例如表格大小、案件目標清單
   內容）可以保留具名常數的形式，不算違規硬編碼。
