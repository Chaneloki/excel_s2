# 案件一 Detective Mode 任務與2.5D場景元素清單 v0.1

本文件規劃案件一《缺席者的名字》的 Detective Mode，以及之後案件可重用的
系統骨架。故事演出繼續由 `09_chapter1_dialogue.*` 負責；數據計算儀沿用
現有公式引擎，不在本次重做。案件一探索內容依劇本 v1.1 場景③、⑤草稿，
場景構圖參考 `3case/case1_bg_grid9/` 與 `3case/case1_bg/`。

---

## 1. 已定案範圍

- Detective Mode 使用固定第一人稱 POV，不顯示玩家角色。
- 世界畫面使用 `Node2D`／`Sprite2D`／`Camera2D`，UI才使用 `Control`。
- Camera只可在有限範圍內向左、右、上、下平移，不可自由走動或旋轉。
- 場景採2D分層視差製作，不使用把2D圖貼上3D幾何的box-out方案。
- 所有初始位置、縮放、旋轉、`z_index`與碰撞多邊形保存在`.tscn`，可在
  Godot 2D編輯器用滑鼠調整；程式不可在`_ready()`重設這些值。
- 可互動物件的圖片、`Area2D`、`CollisionPolygon2D`、提示與互動元件必須
  位於同一個可移動的`Node2D`根節點下。
- 畫在某個視差圖層內的物件，其hotspot也必須是同一圖層的子節點。
- 案件一的Excel表格保持無陷阱；地圖探索可有紅鯡魚與裝飾性觀察。

---

## 2. 案件一模式流程

| 流程 | 模式 | 內容 |
|---|---|---|
| 場景① | Story | 偵探所日常 |
| 場景② | Story | 接案、解鎖展示廳、得知蜜雅與塔克 |
| 場景③ | Detective | 展示廳第一次調查 |
| 場景④ | Excel | COUNTIF，確認行蹤矛盾 |
| 場景⑤ | Detective | 展示廳第二次調查、進入洽談室 |
| 場景⑥ | Excel | COUNTIFS，確認犯案機會 |
| 場景⑦ | Story | 走廊喘息 |
| 場景⑧ | Excel | SUMIF，確認金錢動機 |
| 場景⑨ | Confrontation | 對質；後續獨立零件，不與地圖原型混做 |
| 場景⑨b、⑩ | Story | 旅館外與結案收尾 |

---

## 3. 可重用系統任務清單

以下零件按編號順序逐一開發。每個零件完成獨立測試後，才開始下一個。

### 10　Investigation State

- [x] 建立`10_investigation_state.gd`。
- [x] 狀態只保存穩定ID：證據、推論、flags、話題、地點、NPC信任值、
  hotspot狀態與目前案件。
- [x] 實作證據去重、flag讀寫、話題解鎖、地點解鎖。
- [x] 實作`serialize_state()`／`deserialize_state()`。
- [x] 建立`10_investigation_state_test.gd/.tscn`。
- [x] 以虛構ID測試重複收集、空狀態還原、完整JSON存檔往返。

完成標準：✅ 不載入任何UI或案件一場景，Godot 4.6.3獨立測試23項全部通過。

### 11　固定POV Camera與編輯器輔助線

- [ ] 建立`11_detective_pov_camera.gd/.tscn`獨立測試場景。
- [ ] 支援滑鼠靠近邊緣及方向輸入。
- [ ] Camera目標限制於Inspector設定的水平／垂直最大範圍。
- [ ] 平滑移動使用幀率無關插值。
- [ ] 保持2D transform／vertex pixel snap關閉，避免慢速平移逐像素跳動。
- [ ] 建立`@tool`編輯器輔助線：1920×1080畫面框、最大pan邊界、安全區。
- [ ] 輔助線在遊戲執行與正式匯出時不可見。

完成標準：placeholder分層圖在不同FPS下平滑移動、不露空白、不抖動。

### 12　POV視差圖層

- [ ] 建立`12_pov_parallax_layer.gd`，深度係數由Inspector設定。
- [ ] 所有圖層的初始Transform只讀`.tscn`，程式只施加運行時視差偏移。
- [ ] 預設深度建議：遠景0.15、背景0.30、中景0.55、近景0.80、前景1.00。
- [ ] 驗證子hotspot跟圖層同步移動，畫面與點擊範圍不漂移。

完成標準：任意移動一個圖層根節點後，其圖片、物件及hotspot仍完全對齊。

### 13　通用Detective Interactable

- [ ] 建立`13_detective_interactable.gd/.tscn`。
- [ ] 根節點使用`Node2D`，子節點至少包含`Sprite2D`、`Area2D`、
  `CollisionPolygon2D`、`Marker2D`及互動提示。
- [ ] 支援Talk／Observe／Inspect／Scan／Exit五種行為；Present Evidence由
  Detective Dialogue處理。
- [ ] 支援required flags、blocked flags、一次性／可重複、證據獎勵、
  完成後flags與狀態變體。
- [ ] hover只提示可互動物件，不讓所有線索永久發光。
- [ ] 建立不規則多邊形點擊、重疊物件與前後景遮擋測試。

完成標準：設計者只需拖拉根節點及畫CollisionPolygon2D，不需輸入座標。

### 14　Detective Dialogue Panel

- [ ] 建立與Story Dialogue完全獨立的短對話面板。
- [ ] 支援NPC預設話題、證據／推論／flag解鎖話題、一次性與重複話題。
- [ ] 支援出示證據與正確／錯誤回應；錯誤不直接game over。
- [ ] 支援對話結果發放證據、設定flag及改變信任值。
- [ ] 視覺沿用`0mockup`規則，但不複製Story的完整CG／自動播放流程。

完成標準：用一個假NPC驗證初次話題、解鎖話題、重複話題與錯誤出示。

### 15　調查筆記本與推論

- [ ] 建立證據分類與詳情顯示。
- [ ] 支援多選證據與「連結線索」。
- [ ] 推論使用穩定ID組合，區分exact／subset規則。
- [ ] 無效組合回傳偵探語氣提示，不卡住或結束遊戲。
- [ ] 區分必要、支持、可選、角色相關證據及未確認觀察。
- [ ] 顯示新證據、新推論、未解問題及已確認結論。

完成標準：至少驗證一組有效推論及兩組無效／紅鯡魚組合。

### 16　Excel Bridge

- [ ] 不修改現有公式解析與計算核心。
- [ ] 新增薄橋接層，接收`stage_id`並檢查所需資料表證據是否齊備。
- [ ] Excel完成後只回傳`result_deduction_id`及flags。
- [ ] COUNTIF／COUNTIFS／SUMIF三關分別回傳行蹤、機會、動機推論。

完成標準：Detective State可開啟現有Excel場景並正確接收結果，不把案件
邏輯寫進公式引擎。

### 17　Case Flow Controller

- [ ] 建立Story／Detective／Excel／Confrontation模式切換介面。
- [ ] 各模式只發出`mode_finished(result_id)`，不直接載入下一個模式。
- [ ] 以穩定event id記錄目前流程，不依賴對白陣列index。
- [ ] 支援保存中途模式、location id、view id與調查狀態。

完成標準：用placeholder完成Story→Detective→Excel→Story往返，沒有互相
直接引用對方內部節點。

### 18　存檔擴充

- [ ] 沿用`06_save_system.gd`的檔案讀寫，不建立第二套Save Manager。
- [ ] 存入Investigation State、目前mode／event／location／view。
- [ ] 只保存Resource ID，不保存完整Resource物件。
- [ ] 加入`save_version`及缺欄位向後相容預設值。

完成標準：在第二次展示廳調查中存檔，重開後NPC、hotspot、證據、Camera
視角與下一個流程全部正確還原。

---

## 4. 案件一專屬整合任務

### 劇本與資料

- [ ] 將場景②、③、⑤ v1.1定稿後合併到正式案件一劇本。
- [ ] 固定角色ID：`miya`、`tucker`、`shimmer`、`rena`、`beloit`。
- [ ] 固定必要證據ID：`ev_sign_in_roster`、`ev_tucker_exit_log`、
  `ev_tucker_testimony`、`ev_side_door_unlogged_exit`、
  `ev_zone_access_log`、`ev_rena_testimony`。
- [ ] 固定紅鯡魚ID；純風味內容若不進筆記本則不給ID。
- [ ] 定義三個Excel結果推論：行蹤矛盾、犯案機會、未申報費用。
- [ ] 定義展示廳visit 01／visit 02完成條件。

### 展示廳visit 01

- [ ] 初始view為主展廳。
- [ ] 蜜雅、塔克、席默可交談；瑞娜不可見。
- [ ] 可Inspect洽談室門、側門及必要文件。
- [ ] 可Observe茶漬等場景內容。
- [ ] 收齊簽到名冊與塔克離場記錄後開啟COUNTIF。

### 展示廳visit 02

- [ ] 沿用同一場景，不複製第二份展示廳layout。
- [ ] 瑞娜出現，蜜雅話題更新，已完成hotspot保持狀態。
- [ ] 洽談室內部view解鎖。
- [ ] 取得區域進出記錄與瑞娜證詞後開啟COUNTIFS。

### 案件一QA

- [ ] 必要hotspot可用任何合理順序完成。
- [ ] 不點純風味hotspot也能完成案件。
- [ ] 紅鯡魚能進筆記本並正常得到無效連結回應。
- [ ] 必要證據不會因重複互動重複發放。
- [ ] 切view、開UI、進Excel後Camera與視差位置正確恢復。
- [ ] 1920×1080及目標視窗縮放模式下不露邊、不錯位。

---

## 5. 2.5D共同素材規格

- 設計viewport：1920×1080。
- 建議每個固定POV的工作畫布：2560×1440；最少需涵蓋Camera最大pan後的
  額外範圍。若pan為水平±160、垂直±90，最低安全尺寸為2240×1260。
- 每個POV只能選一個固定透視。九宮格不同編號是不同Camera，不可直接把
  不同編號的物件拼進同一個視差場景。
- 第一版建議所有透明圖層保持相同完整畫布與原點，方便精準疊合；確認後
  才裁切透明範圍最佳化記憶體。
- 移動物件的接觸陰影／反射應跟物件同組，或另外提供同步圖層；不可把
  陰影完全烘焙在背景後再大幅移動物件。
- 所有素材無文字、無hotspot icon、無UI、透明背景乾淨。
- 檔名全部小寫底線，例如`d1_mid_display_case_center.png`。

---

## 6. 案件一場景元素清單

### D1　展示廳主視角

參考：`case1_bg_grid9/d1_exhibition_hall_main.png`。九宮格1、6為高角度，
不適合第一人稱主鏡；2、3、7、8、9較接近人眼高度。正式2.5D版應選其中
一個方向重新建立較寬的2560×1440 master。現有`case1_bg/d1_...`是高角度
總覽，只適合構圖／物件分布參考，不宜直接當第一人稱底圖。

#### 可沿用作設計參考的建築與大型元素

- [ ] 深木牆板、金屬飾條、天花與牆腳。
- [ ] 拋光深色石地板、地面幾何線與反射。
- [ ] 左側高拱窗／玻璃門與午後斜光。
- [ ] 中央大型門、右側門／通道框。
- [ ] 商會徽章長旗與壁燈。
- [ ] 牆邊玻璃展示櫃及淡藍魔法器具。
- [ ] 中央展示島與玻璃罩。
- [ ] 盆栽及牆角小型裝飾。

#### 建議輸出圖層

- [ ] `d1_far_architecture.png`：最遠牆面、門窗外景。
- [ ] `d1_back_wall_fixtures.png`：旗幟、壁燈、牆邊展示櫃。
- [ ] `d1_mid_display_islands.png`：中央展示島群。
- [ ] `d1_near_display_case.png`：靠近Camera的展示櫃／桌角。
- [ ] `d1_foreground_mask.png`：最前景遮擋邊緣。
- [ ] `d1_light_dust_overlay.png`：斜光、微塵；低透明度、不可遮擋點擊。
- [ ] `d1_floor_reflection_overlay.png`：必要時獨立控制，不與可移動人物綁死。

#### v1.1需要但現有九宮格缺少／不明確的新增元素

- [ ] 前台登記桌，留出蜜雅站／坐位置。
- [ ] 簽到名冊近景或可分離桌面文件。
- [ ] 補登委託資料文件。
- [ ] 茶歇桌、茶杯、茶壺、餅乾盤。
- [ ] 打翻茶漬與碎餅乾屑（Observe）。
- [ ] 明確可辨識的洽談室入口標誌／門框。
- [ ] 展示廳內側的側門視角；現有D3主要是門外巷道。
- [ ] 側門旁白手套。
- [ ] 塔克的記錄本近景。

#### NPC透明元素

- [ ] 蜜雅：待命／交談姿勢；visit 01緊張、visit 02較放鬆可用表情或姿態差分。
- [ ] 塔克：站立、拿記錄本。
- [ ] 席默：緊張、摸袖口。
- [ ] 瑞娜：visit 02才顯示，站在洽談室門口。
- [ ] 蘇菲亞場景cutout（可選）；若只用Detective Dialogue頭像則不必放世界人物。

#### D1互動根節點

- [ ] `miya_front_desk`（Talk／Inspect文件）。
- [ ] `negotiation_room_door`（Inspect／切換view）。
- [ ] `tea_break_table`（Observe）。
- [ ] `side_door_inside`（Inspect／Exit或切換view）。
- [ ] `white_glove`（Inspect／紅鯡魚）。
- [ ] `tucker`（Talk／取得記錄本）。
- [ ] `shimmer`（Talk／行為觀察）。
- [ ] `rena`（Talk；只在visit 02啟用）。

### D2　洽談室內部

參考：`case1_bg_grid9/d2_exhibition_hall_negotiation_room.png`。九宮格2、3、
5、8、9為人眼高度候選；4是文件袋特寫，可直接作Inspect特寫參考。現有
`case1_bg/d2_...`已是可用的寬構圖基礎，但需要為小幅Camera pan補出畫面外範圍。

#### 建築與固定元素

- [ ] 深木牆板、木地板、圓形地毯。
- [ ] 窗戶、白色窗簾、窗外城市及日光。
- [ ] 左側門與通往展示廳的開口。
- [ ] 右側矮櫃／書架。
- [ ] 玻璃展示櫃及淡藍魔法器具。

#### 可分離中近景元素

- [ ] 圓桌桌面／桌腳。
- [ ] 左椅、右椅；前景椅背可作遮擋層。
- [ ] 設計圖文件袋：閉合、被抽開／攤開兩態。
- [ ] 文件袋紅繩／封口細節。
- [ ] 點心紙盒及糖霜痕跡（紅鯡魚，現有圖沒有）。
- [ ] 桌面接觸陰影與椅腳陰影。

#### 建議輸出圖層

- [ ] `d2_far_room_shell.png`。
- [ ] `d2_back_window_cabinet.png`。
- [ ] `d2_mid_round_table.png`。
- [ ] `d2_mid_chairs.png`。
- [ ] `d2_near_chair_mask.png`。
- [ ] `d2_document_bag_closed.png`／`d2_document_bag_open.png`。
- [ ] `d2_snack_box_crumpled.png`。
- [ ] `d2_sunlight_overlay.png`。

#### D2互動根節點

- [ ] `design_document_bag`（Inspect）。
- [ ] `snack_box`（Inspect／紅鯡魚）。
- [ ] `display_cabinet`（Observe，可選風味）。
- [ ] `return_to_main_hall`（Exit）。

### D3　側門內外

參考：`case1_bg_grid9/d3_exhibition_hall_side_door.png`。現有九宮格及
`case1_bg/d3_...`都是**外側巷道**：石牆、木門、濕地、夕陽。v1.1第一次
發現側門與白手套發生在展示廳內，因此正式製作至少需要補一個內側POV。

#### 必要的內側POV（新增）

- [ ] 與D1同材質的展示廳內牆。
- [ ] 不起眼的小型側門與門框。
- [ ] 門把、鎖具、門縫光。
- [ ] 門旁牆腳及地面陰影。
- [ ] 白手套。
- [ ] 返回主展廳的Exit區域。

#### 現有外側POV可拆元素

- [ ] 遠方城市建築、夕陽與樹影。
- [ ] 狹窄巷道的左右石牆。
- [ ] 濕石板路、水窪與反光。
- [ ] 木門、石門框、門把與鎖。
- [ ] 門上壁燈。
- [ ] 常春藤。
- [ ] 木箱、木桶及牆角雜物。
- [ ] 近景牆面／箱子遮擋層。

#### 建議輸出圖層

- [ ] `d3_far_city_sunset.png`。
- [ ] `d3_back_alley_walls.png`。
- [ ] `d3_mid_side_door.png`。
- [ ] `d3_mid_ivy_lantern.png`。
- [ ] `d3_near_crates_barrels.png`。
- [ ] `d3_foreground_wall_mask.png`。
- [ ] `d3_wet_ground_reflection.png`。

#### D3互動根節點

- [ ] `side_door_lock`（Inspect）。
- [ ] `alley_ground`（Observe，可選）。
- [ ] `crates`（Observe，可選風味）。
- [ ] `return_inside`（Exit）。

案件一若不需要玩家真正走到門外，D3外側可延後；第一版只完成D1內側門
hotspot即可，不要為了現有素材強迫劇本增加沒有用途的場景。

### 偵探所九宮格

`case1_bg_grid9/a_detective_office.png`可作未來2.5D辦公室／案件選單場景參考，
但案件一Detective Mode目前不需要探索偵探所。它不列入第一版必要素材，
避免同時製作與展示廳調查無關的場景。

---

## 7. 案件一第一版最小素材包

為避免一開始拆太多圖，第一個可玩prototype只需要：

1. D1一張2560×1440主鏡位底圖。
2. D1前景展示櫃遮擋層。
3. 前台登記桌、茶歇桌、洽談室門、內側側門四個可分離元素。
4. 蜜雅、塔克、席默、瑞娜四張透明站立圖。
5. 簽到名冊、塔克記錄本、茶漬、白手套四個互動元素或近景圖。
6. D2一張2560×1440洽談室底圖。
7. D2前景椅遮擋層、文件袋開／關、點心盒。
8. placeholder的hover／scan提示；沿用現有放大鏡素材亦可。

先用這個最小包驗證Camera、視差、hotspot與兩次visit狀態，再決定是否細拆
壁燈、旗幟、玻璃櫃、光束和反射。不要在機制未驗證前一次拆完所有裝飾物。

---

## 8. 未來章節套用檢查表

新增案件／章節時，只新增內容，不修改通用管理器：

- [ ] 新case id、segment id、location id、view id全部唯一且穩定。
- [ ] 新Location用POV場景template建立。
- [ ] 每個固定POV選定單一透視master及安全pan範圍。
- [ ] 新物件使用通用Interactable scene，不複製互動程式。
- [ ] 新NPC只提供Resource資料、圖片與話題，不新增NPC專用管理器。
- [ ] 新證據／推論只新增Resource與ID，不修改Investigation State核心。
- [ ] Excel新關卡只新增stage資料與必要公式實作，不把場景邏輯塞進引擎。
- [ ] Story／Detective／Excel轉場只修改Case Flow資料。
- [ ] 所有手動Transform與CollisionPolygon2D保留在`.tscn`。
- [ ] 每個新場景先做獨立demo，再接正式章節流程。
