# 案件一 Detective Mode 任務與3D混合場景元素清單 v0.2

本文件規劃案件一《缺席者的名字》的 Detective Mode，以及之後案件可重用的
系統骨架。故事演出繼續由 `09_chapter1_dialogue.*` 負責；數據計算儀沿用
現有公式引擎，不在本次重做。案件一探索內容依劇本 v1.1 場景③、⑤草稿，
場景構圖參考 `3case/case1_bg_grid9/` 與 `3case/case1_bg/`。

---

## 1. 已定案範圍

- Detective Mode使用第一人稱，不顯示玩家角色；D1環境保留為真正3D。
- 玩家可用WASD在受限制的參觀路線內前後左右行走，不可像FPS任意探索全場。
- 滑鼠只可在目前Observation Zone的基準方向附近小幅左右／上下查看。
- 入口、中央展示區、前台及門區各自提供鏡頭基準方向；換區時平滑轉向。
- 牆、地板、門、展示櫃與大型家具使用3D；遠景裝飾、圖案、污漬與角色對話
  立繪可使用2D貼圖、Decal或`Sprite3D`。
- NPC世界人物使用Billboard `Sprite3D`，並以家具、碰撞和接近區限制玩家不能
  繞到紙片背後；正式對話仍使用Detective Dialogue的精緻2D立繪。
- 所有初始位置、縮放、旋轉、碰撞及父子關係保存在`.tscn`／`.glb`，程式不可
  在`_ready()`重設設計者已調整的Transform。
- Blender `.blend`是來源檔；Godot正式場景使用經過整理及最佳化的`.glb`。
- 世界節點使用`Node3D`／`CharacterBody3D`／`Area3D`／`Camera3D`；只有UI使用
  `Control`。
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

### 11　D1 Blender場景匯入與3D基準

- [ ] 以`12.5D/D1_exhibition_hall_blockout.blend`作唯一場景來源，整館一次輸出
  成一個最佳化`.glb`；保留目前全部物件位置、比例、旋轉與父子階層。
- [ ] 不把300MB以上的`.blend`直接放進Godot資產目錄，也不在Godot重新排列
  Blender已完成的場景構圖。
- [ ] 建立`11_d1_3d_import_test.gd/.tscn`獨立測試場景。
- [ ] 統一1 Godot單位＝1公尺，確認正面方向、原點、門高及玩家眼高比例。
- [ ] 同一個`.glb`內保留環境mesh、可開門板、互動物及燈光的獨立節點名稱；
  「獨立節點」不代表分開輸出檔案或改變它們的位置。
- [ ] 牆、地板、展示櫃使用簡化`StaticBody3D`碰撞，不以高模網格直接碰撞。
- [ ] 檢查材質、透明玻璃、法線、燈光與陰影；淡藍發光不得誤用主角淡綠色。
- [ ] 先只驗證空場景，不加入Player、NPC、案件資料或正式互動。

完成標準：D1可在Godot獨立載入，比例／材質／碰撞正確，沒有遺失資源或
明顯效能警告。

### 12　有限第一人稱Player

- [ ] 建立`12_limited_first_person_controller.gd/.tscn`獨立測試場景。
- [ ] 根節點使用`CharacterBody3D`，包含`CollisionShape3D`、`Head`、
  `Camera3D`及中央互動射線。
- [ ] 支援WASD、加減速、重力與斜向速度正規化；所有移動均幀率無關。
- [ ] yaw／pitch限制由Inspector設定，不把角度數值散落硬編碼在函式內。
- [ ] 初始位置與面向只讀`.tscn`，程式不可在`_ready()`覆寫。
- [ ] 建立隱形參觀路線碰撞，禁止走入櫃後、牆角及模型未完成區域。

完成標準：placeholder房間內可穩定行走，不能穿牆、繞到限制區或任意轉身。

### 13　Observation Zone鏡頭構圖

- [ ] 建立`13_observation_zone.gd/.tscn`。
- [ ] 每區使用`Area3D`＋`Marker3D`保存基準面向、yaw／pitch範圍與優先度。
- [ ] 進入新區時以幀率無關方式平滑轉向，不瞬移、不抖動。
- [ ] Player保留相對觀察角度；離區或重疊區時使用明確優先規則。
- [ ] 建立入口、中央、前台、門區四個placeholder Zone測試。

完成標準：玩家真的能行走，但每區看到的仍是受控構圖，身旁必要互動物皆
可進入視野。

### 14　通用3D Detective Interactable

- [ ] 建立`14_detective_interactable.gd/.tscn`。
- [ ] 根節點使用`Node3D`，子節點至少包含`Area3D`、`CollisionShape3D`、
  `Marker3D`及可選的視覺／掃描提示節點。
- [ ] 支援Talk／Observe／Inspect／Scan／Exit五種行為；Present Evidence由
  Detective Dialogue處理。
- [ ] 支援required flags、blocked flags、一次性／可重複、證據獎勵、
  完成後flags與狀態變體。
- [ ] 中央準星射線只提示目前命中的可互動物，不讓所有線索永久發光。
- [ ] 驗證射線遮擋、互動距離、重疊Area及物件移動後碰撞仍同步。

完成標準：設計者移動一個根節點，其mesh、Area、提示與互動邏輯會一起移動。

### 15　Billboard Sprite3D NPC

- [ ] 建立`15_detective_npc_sprite3d.gd/.tscn`，根節點使用`Node3D`。
- [ ] `VisualPivot`下包含`Sprite3D`及`ShadowSprite3D`；互動`Area3D`不可跟隨
  呼吸動畫漂移。
- [ ] 支援Billboard、呼吸、眨眼、姿勢切換及對話中狀態。
- [ ] 支援最大顯示距離、正面接近角度與可互動距離。
- [ ] 玩家碰撞／家具配置必須阻止其繞到NPC背後。
- [ ] 以假NPC驗證世界Sprite與Detective Dialogue正式立繪切換。

完成標準：NPC在允許視角內沒有明顯紙片感，移動VisualPivot不會令互動範圍
錯位。

### 16　Detective Dialogue Panel

- [ ] 建立與Story Dialogue完全獨立的短對話面板。
- [ ] 支援NPC預設話題、證據／推論／flag解鎖話題、一次性與重複話題。
- [ ] 支援出示證據與正確／錯誤回應；錯誤不直接game over。
- [ ] 支援對話結果發放證據、設定flag及改變信任值。
- [ ] 視覺沿用`0mockup`規則，但不複製Story的完整CG／自動播放流程。

完成標準：用一個假NPC驗證初次話題、解鎖話題、重複話題與錯誤出示。

### 17　調查筆記本與推論

- [ ] 建立證據分類與詳情顯示。
- [ ] 支援多選證據與「連結線索」。
- [ ] 推論使用穩定ID組合，區分exact／subset規則。
- [ ] 無效組合回傳偵探語氣提示，不卡住或結束遊戲。
- [ ] 區分必要、支持、可選、角色相關證據及未確認觀察。
- [ ] 顯示新證據、新推論、未解問題及已確認結論。

完成標準：至少驗證一組有效推論及兩組無效／紅鯡魚組合。

### 18　Excel Bridge

- [ ] 不修改現有公式解析與計算核心。
- [ ] 新增薄橋接層，接收`stage_id`並檢查所需資料表證據是否齊備。
- [ ] Excel完成後只回傳`result_deduction_id`及flags。
- [ ] COUNTIF／COUNTIFS／SUMIF三關分別回傳行蹤、機會、動機推論。

完成標準：Detective State可開啟現有Excel場景並正確接收結果，不把案件
邏輯寫進公式引擎。

### 19　Case Flow Controller

- [ ] 建立Story／Detective／Excel／Confrontation模式切換介面。
- [ ] 各模式只發出`mode_finished(result_id)`，不直接載入下一個模式。
- [ ] 以穩定event id記錄目前流程，不依賴對白陣列index。
- [ ] 支援保存中途模式、location id、view id與調查狀態。

完成標準：用placeholder完成Story→Detective→Excel→Story往返，沒有互相
直接引用對方內部節點。

### 20　存檔擴充

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
- [ ] 蜜雅、塔克可在現場交談；瑞娜不可見。
- [ ] Inspect參展者聯絡記錄後解鎖席默通話；席默已回工房，不在D1現場。
- [ ] Inspect洽談室門後記錄雙重機械鎖；visit 01不可進入，莉希雅需要時間解讀。
- [ ] 側門同樣有雙把手，但內側第二把手是逃生解除機構，可直接確認無記錄出口。
- [ ] 可Observe茶漬等場景內容。
- [ ] 收齊簽到名冊與塔克離場記錄後開啟COUNTIF。

### 展示廳visit 02

- [ ] 沿用同一場景，不複製第二份展示廳layout。
- [ ] 瑞娜出現，蜜雅話題更新，已完成hotspot保持狀態。
- [ ] 只有已取得`negotiation_lock_inspected`，visit 02才可完成操作次序並解鎖洽談室內部view。
- [ ] 取得區域進出記錄與瑞娜證詞後開啟COUNTIFS。

### 案件一QA

- [ ] 必要hotspot可用任何合理順序完成。
- [ ] 不點純風味hotspot也能完成案件。
- [ ] 紅鯡魚能進筆記本並正常得到無效連結回應。
- [ ] 必要證據不會因重複互動重複發放。
- [ ] 切房間、開UI、進Excel後Player位置、Observation Zone及Camera相對角度正確恢復。
- [ ] 1920×1080及目標視窗縮放模式下準星、提示與3D射線命中一致。

---

## 5. 3D混合素材共同規格

- 設計viewport：1920×1080；3D世界不可依單一解析度寫死螢幕座標。
- Blender與Godot統一1單位＝1公尺；角色眼高、門高、桌面高度先校正再匯出。
- `.blend`只作來源檔，正式匯入使用單一場景`.glb`；匯出前檢查法線及不可見
  測試物，但不得為了整理而覆寫已完成的Transform或重新排位。
- 環境shell、可開門板與互動道具在同一`.glb`內保留獨立節點，讓Godot可
  分別加碰撞／互動；不可合併成單一mesh，也不需要拆成多個`.glb`。
- 玻璃、發光晶體、旗幟及植物可在Godot重設較便宜的材質；燈光不可依賴
  Blender viewport效果自然等同Godot。
- 地面花紋、牆徽章、茶漬、碎屑及封蠟優先使用貼圖或Decal，不為薄片細節
  增加不必要幾何。
- 所有互動物與NPC參考圖無文字、無hotspot icon、無UI，檔名全部小寫底線。
- 模型接觸陰影由Godot燈光／shadow或獨立陰影Sprite處理，不烘焙成會錯位的
  固定背景陰影。

---

## 6. 案件一場景元素清單

### D1　展示廳主視角

Blender來源：`12.5D/D1_exhibition_hall_blockout.blend`。現有
`case1_bg/d1_exhibition_hall_main.png`及九宮格只作材質、構圖與物件分布
參考，不再作可玩場景背景。Godot正式使用由Blender整理輸出的D1 `.glb`。

#### 可沿用作設計參考的建築與大型元素

- [ ] 深木牆板、金屬飾條、天花與牆腳。
- [ ] 拋光深色石地板、地面幾何線與反射。
- [ ] 左側高拱窗／玻璃門與午後斜光。
- [ ] 中央大型門、右側門／通道框。
- [ ] 商會徽章長旗與壁燈。
- [ ] 牆邊玻璃展示櫃及淡藍魔法器具。
- [ ] 中央展示島與玻璃罩。
- [ ] 盆栽及牆角小型裝飾。

#### D1單一場景GLB內部結構

- [ ] 只輸出一個`d1_exhibition_hall.glb`，完整保留Blender現有布局。
- [ ] GLB內的牆、地板、天花、展示櫃、前台、茶歇桌維持可辨識節點名稱。
- [ ] 入口、洽談室門與側門的門板、門框、兩把手維持獨立子節點，但不改位置。
- [ ] 魔法儀器與大型裝飾保留現有世界Transform，之後按需要掛互動元件。
- [ ] 簡化參觀路線碰撞可在Godot另建，不要求回頭改動或重排Blender模型。
- [ ] 旗幟圖案、地面花紋、茶漬及碎屑使用材質／Decal，不另做高模。

#### v1.1需要但現有九宮格缺少／不明確的新增元素

- [ ] 前台登記桌，留出蜜雅站／坐位置。
- [ ] 簽到名冊近景或可分離桌面文件。
- [ ] 補登委託資料文件。
- [ ] 茶歇桌、茶杯、茶壺、餅乾盤。
- [ ] 打翻茶漬與碎餅乾屑（Observe）。
- [ ] 明確可辨識的洽談室入口標誌／門框，以及兩個各自驅動機構的門把。
- [ ] 展示廳內側的側門視角；現有D3主要是門外巷道。
- [ ] 側門旁白手套。
- [ ] 塔克的記錄本近景。

#### NPC Sprite3D元素

- [ ] 蜜雅：待命／交談姿勢；visit 01緊張、visit 02較放鬆可用表情或姿態差分。
- [ ] 塔克：站立、拿記錄本。
- [ ] 席默不製作D1世界人物；通話沿用既有對話立繪／頭像及音訊表現。
- [ ] 瑞娜：visit 02才顯示，站在洽談室門口。
- [ ] 蘇菲亞場景cutout（可選）；若只用Detective Dialogue頭像則不必放世界人物。

#### D1互動根節點

- [ ] `miya_front_desk`（Talk／Inspect文件）。
- [ ] `negotiation_room_door`（Inspect／切換view）。
- [ ] `tea_break_table`（Observe）。
- [ ] `side_door_inside`（Inspect／Exit或切換view）。
- [ ] `white_glove`（Inspect／紅鯡魚）。
- [ ] `tucker`（Talk／取得記錄本）。
- [ ] `shimmer_contact_record`（Inspect／解鎖席默通話）。
- [ ] `rena`（Talk；只在visit 02啟用）。

### D2　洽談室內部

參考：`case1_bg_grid9/d2_exhibition_hall_negotiation_room.png`及
`case1_bg/d2_...`只作構圖／材質參考。D2若允許行走，正式版本同樣建立獨立
3D房間shell；若第一版只作門後短Inspect，也可先使用受控Camera的3D小房間。

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

#### 建議3D／混合輸出

- [ ] `d2_environment_shell.glb`：固定房間、門洞與窗。
- [ ] `d2_furniture.glb`：圓桌、椅、矮櫃與展示櫃，各自保留節點。
- [ ] `d2_document_bag.glb`：文件袋閉合／打開狀態。
- [ ] `d2_snack_box.glb`：點心盒；糖霜痕跡可用Decal。
- [ ] 窗外城市與遠景使用2D平面；日光由Godot燈光處理。

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
- [ ] 兩個門把、鎖具、門縫光；第二把手在內側直接解除逃生鎖舌。
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

#### 建議3D／混合輸出

- [ ] 第一版只沿用D1內側側門mesh與碰撞，不製作完整外巷。
- [ ] 日後需要外巷時，石牆、門、箱桶與地面使用3D；城市夕陽使用2D遠景。
- [ ] 水窪、濕地反光與污痕使用材質／Decal，常春藤使用alpha card。

#### D3互動根節點

- [ ] `side_door_lock`（Inspect）。
- [ ] `alley_ground`（Observe，可選）。
- [ ] `crates`（Observe，可選風味）。
- [ ] `return_inside`（Exit）。

案件一若不需要玩家真正走到門外，D3外側可延後；第一版只完成D1內側門
hotspot即可，不要為了現有素材強迫劇本增加沒有用途的場景。

### 偵探所九宮格

`case1_bg_grid9/a_detective_office.png`可作未來辦公室／案件選單場景參考，
但案件一Detective Mode目前不需要探索偵探所。它不列入第一版必要素材，
避免同時製作與展示廳調查無關的場景。

---

## 7. 案件一第一版最小素材包

為避免一開始拆太多圖，第一個可玩prototype只需要：

1. 保留完整布局的單一`d1_exhibition_hall.glb`及Godot簡化碰撞。
2. 有限第一人稱Player與入口／中央／前台／門區四個Observation Zone。
3. 前台、茶歇桌、洽談室門、側門及必要互動物保持獨立3D節點。
4. 蜜雅、塔克、瑞娜三個Billboard Sprite3D NPC；席默只用通話立繪／頭像。
5. 簽到名冊、塔克記錄本、茶漬、白手套四個互動物或Decal。
6. D2最小3D房間、文件袋開／關及點心盒。
7. placeholder準星、hover／scan提示。

先用這個最小包驗證匯入、行走、Zone構圖、3D射線及兩次visit狀態，再決定
是否細修壁燈、旗幟、玻璃、光束和反射。

---

## 8. 未來章節套用檢查表

新增案件／章節時，只新增內容，不修改通用管理器：

- [ ] 新case id、segment id、location id、view id全部唯一且穩定。
- [ ] 新Location用3D場景template建立，來源模型輸出成最佳化`.glb`。
- [ ] 每個Location定義行走碰撞、Observation Zone基準方向及yaw／pitch範圍。
- [ ] 新物件使用通用Interactable scene，不複製互動程式。
- [ ] 新NPC只提供Resource資料、圖片與話題，不新增NPC專用管理器。
- [ ] 新證據／推論只新增Resource與ID，不修改Investigation State核心。
- [ ] Excel新關卡只新增stage資料與必要公式實作，不把場景邏輯塞進引擎。
- [ ] Story／Detective／Excel轉場只修改Case Flow資料。
- [ ] 所有手動Transform、`CollisionShape3D`及父子關係保留在`.tscn`／`.glb`。
- [ ] 每個新場景先做獨立demo，再接正式章節流程。
