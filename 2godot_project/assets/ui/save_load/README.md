# Save/Load UI Skin Kit v0.1

這個資料夾放存讀檔彈窗（在`02_story_dialogue_ui_demo.gd`裡的
`SaveLoadPopup_CaseFiles`）使用的 PNG skin，來源是`1UI/save_load/`。

文字不要畫死在圖片裡，跟story_dialogue那套規則一樣：PNG只負責框、底色、
邊線、選取高亮，章節/地點/「空白檔案」文字都由Godot Label顯示。

---

## 檔案對照

| File | 來源 | 用途 |
|---|---|---|
| `bg_save_load_office.png` | `1UI/save_load/_source_1_save_load_bg.png` | 近全螢幕書房背景，彈窗打開時鋪滿整個畫面，卡片面板浮在上面 |
| `panel_main_save_load.png` | `1UI/save_load/_source_3_main_panel.png` | 卡片面板外框（深綠面板+金色角飾），套用StyleBoxTexture |
| `slot_empty_normal.png` | `1UI/save_load/_source_2_save_slot_empty_normal.png` | 空白檔案格底圖 |
| `slot_saved_normal.png` | `1UI/save_load/_source_4_save_slot_saved_normal.png` | 已有存檔的檔案格底圖 |
| `frame_slot_selected.png` | `1UI/save_load/_source_6_save_load_tab_save_normal.png.png` | 選取中格子疊加的綠色發光外框 |

`1UI/save_load/_source_5_save_load_tab.png`（小標籤牌）v0.1暫時沒用到，
保留在原始素材資料夾。

---

## Godot Usage

`02_story_dialogue_ui_demo.gd`的`_build_save_load_popup()`先鋪一張近
全螢幕的`bg_save_load_office.png`背景，再疊一個套`panel_main_save_load`
樣式的卡片面板（`CardPanel_SaveLoadMain`），裡面用`GridContainer`排出
2列x3欄共6個`SaveLoadSlot`。每格疊圖順序固定為：格子底圖
（`slot_empty_normal`/`slot_saved_normal`）→ 選取高亮框
（`frame_slot_selected`）→ 章節/地點文字，順序顛倒會讓高亮框蓋住文字。

右上角「保存」「讀取」兩個按鈕共用同一個彈窗與同一組格子資料：
- 保存模式（`SAVE_LOAD_MODE_SAVE`）：所有格子都可點擊。
- 讀取模式（`SAVE_LOAD_MODE_LOAD`）：空白格`disabled = true`，不可點擊，
  避免玩家讀到空資料。

目前只用`SAVE_LOAD_SLOT_DATA`假資料（前2格已存檔、其餘4格空白），不寫入
真實存檔檔案，符合「原型階段不放真實案件資料」的規則。
