# 案件一 D1 展示廳・主展場 材質貼圖生成 Prompt 清單（技術路線已棄用，素材保留參考）

> **狀態說明**：本檔案原本是給`03_map_walker_3d_lite_demo`（3D box-out +
> 第一人稱固定觀察點）用的材質貼圖prompt。實測後發現2D插畫貼上3D幾何會有明顯
> 「貼紙感」，視覺品質天花板不夠，**該demo已移除**，Map Walker正式定案改用
> [case1_bg_prompts_flat_v1.md](case1_bg_prompts_flat_v1.md) 的純2D環境插畫
> +熱點彈出特寫卡。本檔案的**素材本體保留**（之後若要做特寫卡片或其他用途仍可
> 參考），但「貼3D幾何」的使用方式不再適用。

本文件原本是 `03_map_walker_3d_lite_demo` 技術路線（3D box-out + 第一人稱固定觀察點）下，
**展示廳・主展場（D1）**需要的材質貼圖prompt。跟
[case1_bg_prompts_flat_v1.md](case1_bg_prompts_flat_v1.md) 的「整張場景插畫」不是
同一種資產——這裡要的是**貼在簡單3D幾何（地板/牆面/門）上的材質貼圖**，所以prompt
寫法完全不同：要強調「無透視、無漸層光影、可重複拼貼」，不是「一張完整構圖」。

## 跟舊版flat背景prompt的差異

| 項目 | case1_bg_prompts_flat_v1.md（舊路線，已不用） | 本檔案（3D box-out材質） |
|---|---|---|
| 用途 | 整張畫面直接當背景 | 貼在3D幾何表面上的材質貼圖 |
| 構圖 | 有透視、有鏡頭角度 | **無透視**，正面/俯視拍攝，平面感 |
| 光影 | 場景氣氛光（午後斜光等） | **均勻打光**，不能有方向性陰影（因為Godot裡會疊加引擎自己的燈光） |
| 重複性 | 一張獨立畫面 | 地板/牆面要**可重複拼貼（seamless tileable）** |
| 比例 | 16:9 | 正方形或材質本身的合理比例，重點是能重複拼貼 |

---

## 美術風格錨點（沿用）

對齊 [0mockup/ui_style_guide_v0.1.md](../0mockup/ui_style_guide_v0.1.md)：深炭黑/深木色、
銀色/古銅金邊框、克制的淡綠魔法光（**只限數據計算儀，本場景不可用**，改用藍白色）、
象牙白文件感、少量暗酒紅點綴。半寫實2.5D，避免anime/cyberpunk/華麗魔法陣。

**門連結一致性**：洽談室門要跟D2共用、側門要跟D3共用同一張材質貼圖，確保Godot裡
從D1看到的門跟從D2/D3裡看到的門是同一個外觀。

---

## 1. 地板材質（深木地板紋）

**狀態：素材已完成**（3D demo技術路線已棄用，此圖保留作參考）——
[3case/case1_material/floor_texture_herringbone_wood.png](case1_material/floor_texture_herringbone_wood.png)，
深色魚骨拼木紋，均勻打光、色調對齊風格指南。

可重複拼貼的地板貼圖，貼在box-out地板的MeshInstance3D上（UV重複貼合）。

```
seamless tileable PBR texture swatch, top-down flat photograph of a dark wood herringbone parquet floor, no perspective, no directional shadows, uniform even lighting across the entire swatch, dark charcoal-brown wood tones with subtle warm undertone, fine wood grain detail, slightly worn but well-maintained, square aspect ratio, repeatable pattern with no visible seams at the edges, no characters, no text, no watermark, not anime, not stylized cartoon, suitable for 3D game engine texture mapping --ar 1:1
```

## 2. 牆面材質（深木牆板紋）

**狀態：素材已完成**（3D demo技術路線已棄用，此圖保留作參考）——
[3case/case1_material/wall_texture_dark_wood.png](case1_material/wall_texture_dark_wood.png)，
深木牆板紋+簡約銀灰線板。

可重複拼貼的牆面貼圖，貼在box-out牆面的MeshInstance3D上。

```
seamless tileable PBR texture swatch, flat front-on photograph of dark wood wall paneling, restrained simple panel grooves (avoid heavy baroque or ornate carving), no perspective, no directional shadows, uniform even lighting across the entire swatch, dark charcoal-brown wood tone with silver-grey trim lines between panels, subtle fabric/wood texture detail, square aspect ratio, repeatable pattern with no visible seams at the edges, no characters, no text, no watermark, not anime, not stylized cartoon, suitable for 3D game engine texture mapping --ar 1:1
```

## 3. 洽談室門外觀（與D2共用）

**狀態：素材已完成**（3D demo技術路線已棄用，此圖保留作參考）——
[3case/case1_material/negotiation_door.png](case1_material/negotiation_door.png)，
frosted glass窗格+銅製把手。

非重複貼合，是單一一張門的正面圖，貼在box-out門形狀的平面上（依門實際尺寸比例）。

```
flat front-on view of a single door, centered in frame, no perspective distortion, no surrounding wall or room visible, plain white or transparent background, dark wood door with a small frosted glass panel set into the upper half, polished silver door handle, restrained simple molding (avoid heavy ornate carving), uniform even lighting with no directional shadow, semi-realistic 2.5D illustrated game asset style, no characters, no text, no watermark, not anime, suitable for use as a 3D game engine texture --ar 3:4
```

## 4. 側門外觀（與D3共用）

**狀態：素材已完成**（3D demo技術路線已棄用，此圖保留作參考）——
[3case/case1_material/side_door.png](case1_material/side_door.png)，
素面深木門板無裝飾。

非重複貼合，單一一張門的正面圖。

```
flat front-on view of a single door, centered in frame, no perspective distortion, no surrounding wall or room visible, plain white or transparent background, a plain unmarked dark wood service door, slightly worn, simple flat panel design with no decoration, plain door handle, uniform even lighting with no directional shadow, semi-realistic 2.5D illustrated game asset style, no characters, no text, no watermark, not anime, suitable for use as a 3D game engine texture --ar 3:4
```

## 5. 商會旗幟／告示牌貼圖（牆面裝飾decal）

**狀態：素材已完成**（3D demo技術路線已棄用，此圖保留作參考）——
[3case/case1_material/guild_banner.png](case1_material/guild_banner.png)，
象牙白旗幟+銀色紋章，克制不誇張。

非重複貼合，貼在牆面上的單一裝飾物，建議透明背景方便疊加在牆面材質上。

```
flat front-on illustration of a tall narrow ivory banner hanging on a wall, centered in frame, no perspective distortion, transparent background, a simple restrained merchant guild crest emblem in silver and dark green, elegant but not overly ornate heraldry design, uniform even lighting with no directional shadow, semi-realistic 2.5D illustrated game asset style, no extra text other than the crest symbol itself, no watermark, not anime, suitable for use as a 3D game engine decal texture --ar 1:3
```

## 6. 展示桌／展示櫃外觀

**狀態：素材已完成**（3D demo技術路線已棄用，此圖保留作參考）——
[3case/case1_material/display_case.png](case1_material/display_case.png)，
深木銀框展示櫃，內部魔法道具**正確使用藍白光**（無誤用綠色）。

可作為box-out展示桌方塊的頂面+側面貼圖，或單獨一張俯視桌面圖（依Godot UV展開方式取用）。

```
seamless tileable PBR texture swatch combined with a top-down flat view of a dark wood and silver display table surface under glass, small intricate magic devices arranged neatly on top, a subtle pale blue-white arcane glow accent on the devices (use blue-white, NOT green — green is reserved exclusively for the protagonist's data-calculator device elsewhere in the game), no perspective, uniform even lighting with no directional shadow, semi-realistic 2.5D illustrated game asset style, no characters, no text, no watermark, not anime, suitable for 3D game engine texture mapping --ar 1:1
```

## 7. 入口登記桌外觀

**狀態：素材已完成**（3D demo技術路線已棄用，此圖保留作參考）——
[3case/case1_material/registration_desk.png](case1_material/registration_desk.png)。

可重複利用第1項（地板/牆面同色系深木材質）作為桌身材質，只需要額外一張桌面文件decal。

```
flat top-down view of a small pile of ivory case-file papers and a simple guest registration ledger on a dark wood desk surface, centered in frame, no perspective distortion, transparent background, uniform even lighting with no directional shadow, semi-realistic 2.5D illustrated game asset style, no readable text details, no watermark, not anime, suitable for use as a 3D game engine decal texture --ar 1:1
```

---

## 待補事項

- 本檔案的7項素材皆已生成完畢，但「貼3D幾何」這個原始用途已隨3D demo一起棄用。
- 若未來需要熱點特寫卡片（例如展示桌特寫、登記桌文件特寫），這些素材可以直接
  重複利用，不需要重新生成。
- 塔克、席默的立繪已完成（見
  [case1_character_setting_prompts.md](case1_character_setting_prompts.md)），
  跟Map Walker的串接方式待純2D技術路線（`case1_bg_prompts_flat_v1.md`）定案後再規劃。
