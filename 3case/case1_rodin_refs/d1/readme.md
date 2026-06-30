# D1 展示廳 Rodin 建模參考圖

本資料夾依`case1_bg/d1_exhibition_hall_main.png`的材質與物件分布，整理成
適合逐件交給 Rodin image-to-3D 的單體參考圖。原場景圖只作設計參考，
沒有直接裁切或修改。

## 第一批：場景主要可重用模型

| 圖檔 | 3D物件 | 場景建議 |
|---|---|---|
| `d1_display_island.png` | 中央玻璃展示島 | 建模一次，複製並調整尺寸；玻璃材質建議在Blender重設。 |
| `d1_wall_display_cabinet.png` | 牆邊展示櫃 | 建模一次，沿牆重用。 |
| `d1_registration_desk.png` | 前台登記桌 | 唯一物件，蜜雅互動區。 |
| `d1_tea_break_table.png` | 茶歇桌 | 唯一物件，茶具與污漬另放。 |
| `d1_negotiation_room_door.png` | 洽談室門連門框 | 兩個門把是雙重機械鎖；門板、門框、兩把手匯入後應拆成獨立mesh。 |
| `d1_service_door.png` | 展示廳內側側門 | 同樣保留兩把手，但第二把手是內側逃生解除機構；門板、門框、把手應拆件。 |
| `d1_glass_entrance_door.png` | 高拱雙扇玻璃入口門 | 雙門板、門框與拱形上窗應拆件；玻璃材質在Blender重設。 |
| `d1_arcane_instrument.png` | 黃銅環形魔法儀器 | 建模一次後可縮放、旋轉並換晶體形狀重用。 |
| `d1_wall_sconce.png` | 雙燈壁燈 | 建模一次，複製到牆面；實際燈光由Godot處理。 |
| `d1_guild_banner.png` | 商會長旗連掛桿 | 建模一次，布料可用簡化低模。 |
| `d1_potted_plant.png` | 方盆闊葉植物 | 建模一次後重用；葉片宜用alpha card或簡化低模。 |

## 第二批：近距離互動物

| 圖檔 | 3D物件 | 用途 |
|---|---|---|
| `d1_registration_ledger.png` | 簽到名冊 | 前台Inspect物。內頁文字不要烘入模型，改用貼圖。 |
| `d1_tucker_notebook.png` | 塔克記錄本 | Talk後取得／Inspect近景。 |
| `d1_white_glove.png` | 白手套 | 側門旁紅鯡魚。 |
| `d1_tea_service_tray.png` | 茶具托盤組 | 可先作一個組合模型；若Rodin產生黏連，再拆成茶壺、杯碟、托盤。 |

## D1角色：Rodin全身參考

角色圖放在`characters/`，全部使用完整頭到腳、三分之四視角及接近A-pose的
構圖，方便Rodin辨認身體與服裝輪廓。

| 圖檔 | 角色 | 備註 |
|---|---|---|
| `characters/d1_miya_full_body_3d.png` | 蜜雅 | 新版劇本新增角色；目前是第一版商會前台制服設計。 |
| `characters/d1_tucker_full_body_3d.png` | 塔克 | 沿用既有臉孔、背心與記錄本；記錄本建議最後拆成獨立mesh。 |
| `characters/d1_shimmer_full_body_3d.png` | 席默（保留備用，不屬D1） | 劇情已改為莉希雅取得資料後致電；D1不需要生成或放置席默3D模型。 |
| `characters/d1_rena_full_body_3d.png` | 瑞娜 | 沿用既有工匠長外套、斜肩帶與量測器方向。 |

角色模型生成後仍需在Blender檢查手指、眼鏡、頭髮、長外套下擺及交疊配件；
這些位置最容易被image-to-3D黏成同一塊。角色待命／交談姿勢應在骨架綁定後
製作，不要為每個姿勢重新生成另一個模型。

目前D1實際需要交給Rodin的角色只有蜜雅、塔克、瑞娜。席默圖片不刪除，
留作日後工房場景或其他章節使用，但不可放進本次展示廳配置。

## 不需要交給 Rodin 的部分

- 牆板、天花、牆腳、門洞、地板、拱窗：在Blender用規則幾何搭建，較容易
  保持比例與碰撞正確。
- 茶漬、餅乾屑、地面反射及商會徽章細節：使用decal或材質貼圖。
- 玻璃透明、淡藍晶體發光、壁燈火光：匯入後在Blender／Godot重設材質，
  不依賴Rodin自動生成結果。
- NPC：人物模型／2D cutout屬另一批，不與場景道具混合生成。

所有參考圖均使用單一物件、乾淨背景及三分之四視角生成；沒有UI、文字或
hotspot圖示。
