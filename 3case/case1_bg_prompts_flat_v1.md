# 案件一《缺席者的名字》場景背景生成 Prompt 清單（固定視角・正式用）

**狀態：8張場景設定圖已全部完成**（A/B/C/D1/D2/D3/E/F，存於
[3case/case1_bg](case1_bg)），已審核確認無誤用綠光等規則問題。技術路線最終定案為
**單張完整插畫＋熱點彈出特寫卡**（不做3D box-out、不放真人avatar走查），所以這些
場景設定圖可以直接當最終背景使用，不強制要求先跑9宮格選鏡位（9宮格僅作為構圖
微調的備選工具，已有A/D1/D2/D3四個場景的版本，存於
[3case/case1_bg_grid9](case1_bg_grid9)）。

本文件整理案件一**正式要用的8張場景背景圖**，依據
[case1_script_draft_v0.1.md](case1_script_draft_v0.1.md) 劇本內容撰寫，取代
[case1_scene_prompts.md](case1_scene_prompts.md) 的720全景做法（該檔案的全景圖僅作風格參考，
解析度也只有1774x887，不夠拿來裁切當1920x1080正式背景用）。

## 設計模式變更說明

Map Walker（D1/D2/D3）原本規劃要在背景裡放一個會走動的玩家小avatar，但這個做法卡在
「avatar站進房間後比例顯小」的問題：純文字prompt對「角色應佔畫面35~45%高度」這類
抽象比例幾乎沒有控制力，AI還是習慣畫成對稱置中的全室建築展示鏡頭。

**改用新模式：環境全景 + 熱點彈出特寫卡**——畫面顯示完整環境，不放真人avatar走動，
玩家點擊熱點（放大鏡icon）後彈出對應的特寫卡片（文件袋蠟封、側門污漬等），互動方式
類似《逆轉裁判》《Return of the Obra Dinn》的固定鏡頭調查。這個模式下**不需要再顧慮
人物比例**，下方所有prompt已移除avatar比例相關限制，構圖可以回到比較舒服、有氣氛的
取景方式。

## 製作流程（三階段，避免再像D2一樣反覆試單張）

1. **場景設定圖（Scene Setting Reference）**：先產出一張確定整體環境設計（陳設、
   材質、氣氛、光線）的概念圖，這階段不用糾結最終鏡位，重點是把「這個地方長什麼樣」
   定下來，之後當作設計依據。
2. **多機位9宮格（Multi-angle Contact Sheet）**：以場景設定圖為設計基準，生成3x3
   共9格、9種不同鏡位/景深/視角的構圖選項（同一場景、同一套陳設，只是鏡頭不同），
   從裡面挑一張畫面感最好、熱點最清楚的鏡位。
3. **正式背景**：依選定的鏡位，重新生成一張乾淨的1920x1080最終背景（不含格線、
   編號），這一步等9宮格選完才進行，本檔案先做到步驟2。

## 通用Prompt模板

### 場景設定圖模板

```
16:9 widescreen aspect ratio (1920x1080), semi-realistic 2.5D illustrated game environment concept art, painterly digital illustration style (NOT photorealistic photography, NOT a 3D render, NOT real estate photography), single clear establishing view of [場景描述], [場景專屬陳設/光線/氣氛描述], this is a DESIGN REFERENCE sheet establishing the overall layout and mood — camera framing does not need to be final, [通用風格錨點/負面排除規則], no characters, no text, no UI, no watermark, not anime, not chibi --ar 16:9
```

### 多機位9宮格模板

```
3x3 grid contact sheet, 9 panels total, each panel showing the EXACT SAME interior location (identical furniture, wall design, props, color palette and lighting as the scene-setting reference image attached) but photographed from a different camera angle and distance — vary across: (1) wide establishing angle, (2) medium shot from the left corner, (3) medium shot from the right corner, (4) close shot near the main table/focal prop, (5) eye-level shot looking toward the main door, (6) slightly higher angle looking down, (7) slightly lower angle, (8) asymmetric off-center crop favoring the left side, (9) asymmetric off-center crop favoring the right side, consistent semi-realistic 2.5D painterly illustration style across all 9 panels, thin grid divider lines between panels, small number label (1-9) in the corner of each panel, no characters, no UI text, no watermark, not anime, not chibi --ar 1:1
```

下方每個場景小節（D1/D2/D3/A/B/C/E/F）都已經把這兩個模板套用好專屬描述，可以直接複製
對應場景的「場景設定圖prompt」跟「多機位9宮格prompt」使用，不需要自己手動替換`[場景描述]`。
九宮格生成時記得把對應場景的「場景設定圖」產出結果一併附上當參考圖（image prompt /
image-to-image功能），確保9宮格裡的陳設跟場景設定圖一致，只是鏡位不同。

---

## 美術風格錨點

對齊 [0mockup/ui_style_guide_v0.1.md](../0mockup/ui_style_guide_v0.1.md) 與
[0mockup/character_style_guide_v0.1.md](../0mockup/character_style_guide_v0.1.md)：
半寫實2.5D、貴族偵探×魔法資料學×安靜懸疑，深炭黑/深木色底、銀色/古銅金邊框、克制的淡綠魔法
互動光、象牙白文件感、**少量暗酒紅**用於警告/重要線索/危險感，避免anime/cyberpunk/華麗魔法陣/
普通RPG道具欄感。光線氣氛依各場景在劇本中的實際時間點調整（見各場景說明）。

**淡綠光是莉莉數據計算儀的專屬識別色，不可用在其他無關魔法器具上**：場景裡如果有
跟劇情、跟計算儀無關的裝飾性魔法道具（例如D1展示廳的展品、D2洽談室的擺設），一律
改用藍白色等其他冷色調魔法光，避免玩家誤以為那些道具也是計算儀或藏有計算儀。
只有A場景（偵探所室內）裡明確是莉莉的計算儀本體時，才使用淡綠光。

**門連結一致性**：B↔C、D1↔D2、D1↔D3 是同一建築/場景群內互通的空間，兩端prompt使用
完全相同的門外觀描述句，確保AI生圖時門長相一致（沿用舊版720全景prompt的做法）。

**通用負面排除規則**（已實測D2發現的偏移問題，套用到全部8張prompt）：生圖容易往
「擬真攝影/3D渲染、寬角魚眼鏡頭、哥德恐怖城堡感、過度華麗雕花、冷色調陰森打光」這幾個
方向偏，務必在每張prompt裡明確排除：not photorealistic photography, not a 3D render,
not wide-angle fisheye lens distortion, not gothic horror, not a haunted mansion, avoid
heavy baroque ornamentation, keep lighting warm not cold/horror-toned。

**720全景參考圖的用法**：每個有對應720全景的場景，下方都附了
[case1_720scene](case1_720scene) 資料夾裡對應圖檔的連結。生圖/繪製時請**參考其色調、
材質、家具陳設、整體氛圍**以維持跟既有美術定調一致，但**不要沿用其視角或構圖**——
全景是360度環視格式，解析度也偏低(1774x887)，跟本檔案要的固定視角單畫面構圖不同。

---

## 環境場景（D1、D2、D3 — 原Map Walker熱點場景，現為環境全景+熱點卡模式）

### D1. 展示廳・主展場

**狀態：已完成**——[case1_bg/d1_exhibition_hall_main.png](case1_bg/d1_exhibition_hall_main.png)，
9宮格見[case1_bg_grid9/d1_exhibition_hall_main.png](case1_bg_grid9/d1_exhibition_hall_main.png)。

對應劇本場景③⑤（地圖走查①②），熱點：洽談室門（→D2）、側門（→D3）、塔克（門衛NPC）、
席默（參展工匠NPC）。劇本時間：午後斜光。

風格參考（色調/材質/陳設參考，非視角參考）：[d1_exhibition_hall_main.png](case1_720scene/d1_exhibition_hall_main.png)

**場景描述**：western fantasy magical-device exhibition hall, rows of display tables
showing small intricate magic devices under glass, dark wood and silver booth frames,
soft pale blue-white arcane glow accents on display items (use blue-white, NOT green —
green is reserved exclusively for the protagonist's signature data-calculator device
elsewhere in the game and must not appear on these unrelated exhibit items), a guest
registration desk near the entrance, ivory banners with the merchant guild crest, warm
afternoon light slanting low through tall windows, dust visible in the light beams,
elegant but business-like atmosphere, restrained magic aesthetic, on one side a dark
wood door with a small frosted glass panel set into the upper half, slightly ajar,
leading to a private negotiation room, near a back corner a plain unmarked service
door, slightly recessed into the wall, easy to overlook

```
16:9 widescreen aspect ratio (1920x1080), semi-realistic 2.5D illustrated game environment concept art, painterly digital illustration style (NOT photorealistic photography, NOT a 3D render, NOT real estate photography), single clear establishing view of a western fantasy magical-device exhibition hall, rows of display tables showing small intricate magic devices under glass, dark wood and silver booth frames, soft pale blue-white arcane glow accents on display items (use blue-white, NOT green — green is reserved exclusively for the protagonist's signature data-calculator device elsewhere in the game and must not appear on these unrelated exhibit items), a guest registration desk near the entrance, ivory banners with the merchant guild crest, warm afternoon light slanting low through tall windows, dust visible in the light beams, elegant but business-like atmosphere, restrained magic aesthetic, on one side a dark wood door with a small frosted glass panel set into the upper half, slightly ajar, leading to a private negotiation room, near a back corner a plain unmarked service door, slightly recessed into the wall, easy to overlook, this is a DESIGN REFERENCE sheet establishing the overall layout and mood — camera framing does not need to be final, not photorealistic photography, not a 3D render, not wide-angle fisheye lens distortion, not gothic horror, not a haunted mansion, avoid heavy baroque ornamentation, keep lighting warm not cold/horror-toned, no characters, no text, no UI, no watermark, not anime, not chibi --ar 16:9
```

**多機位9宮格prompt**（搭配上方場景設定圖一併附上當image reference）：

```
3x3 grid contact sheet, 9 panels total, each panel showing the EXACT SAME western fantasy magical-device exhibition hall (identical display tables, dark wood and silver booth frames, pale blue-white arcane glow accents, guest registration desk, ivory guild banners, the frosted-glass negotiation room door, and the plain unmarked service door — same furniture, same color palette, same warm afternoon lighting as the scene-setting reference image attached) but photographed from a different camera angle and distance — vary across: (1) wide establishing angle, (2) medium shot from the left corner near the registration desk, (3) medium shot from the right corner, (4) close shot near the display tables, (5) eye-level shot looking toward the negotiation room door, (6) slightly higher angle looking down, (7) slightly lower angle, (8) asymmetric off-center crop favoring the service door corner, (9) asymmetric off-center crop favoring the negotiation room door, consistent semi-realistic 2.5D painterly illustration style across all 9 panels, thin grid divider lines between panels, small number label (1-9) in the corner of each panel, no characters, no UI text, no watermark, not anime, not chibi --ar 1:1
```

---

### D2. 展示廳・洽談室

**狀態：已完成**——[case1_bg/d2_exhibition_hall_negotiation_room.png](case1_bg/d2_exhibition_hall_negotiation_room.png)，
9宮格見[case1_bg_grid9/d2_exhibition_hall_negotiation_room.png](case1_bg_grid9/d2_exhibition_hall_negotiation_room.png)。

對應劇本場景③⑤，案發現場（設計圖原本放在這裡的文件袋），熱點：文件袋（線索物）、門（→D1）。
劇本時間：午後斜光。

風格參考（色調/材質/陳設參考，非視角參考）：[d2_exhibition_hall_negotiation_room.png](case1_720scene/d2_exhibition_hall_negotiation_room.png)

**場景描述**：a SMALL and modestly sized private negotiation room (roughly the size of
a single hotel meeting room, not a grand manor hall) attached to a magical-device
exhibition hall, plain dark wood wall panels with minimal restrained carving (avoid
heavy baroque or gothic-castle ornamentation), one small dark wood table with an empty
leather document folder placed prominently in clear view, two simple chairs, a single
modest window with light sheer curtains letting in warm soft afternoon daylight (NOT
cold blue light, NOT high-contrast horror lighting), a faint cool-toned glass display
case visible through the doorway or in a corner hinting this room connects to the
exhibition hall outside, one or two small unrelated exhibition magical devices on a
side shelf emitting a subtle pale blue-white arcane glow (NOT green — green is reserved
for the protagonist's data-calculator device), the entrance door matches the one seen
from the main hall: dark wood with a small frosted glass panel set into the upper half,
a single thin dark wine-red ribbon or wax-seal mark left on the empty document folder,
hinting something important is missing, mood: restrained quiet mystery, mature elegant
detective-fiction atmosphere — explicitly NOT gothic horror, NOT haunted mansion, NOT
vampire castle, NOT overly opulent palace room

```
16:9 widescreen aspect ratio (1920x1080), semi-realistic 2.5D illustrated game environment concept art, painterly digital illustration style (NOT photorealistic photography, NOT a 3D render, NOT real estate photography), single clear establishing view of a SMALL and modestly sized private negotiation room (roughly the size of a single hotel meeting room, not a grand manor hall) attached to a magical-device exhibition hall, plain dark wood wall panels with minimal restrained carving (avoid heavy baroque or gothic-castle ornamentation), one small dark wood table with an empty leather document folder placed prominently in clear view, two simple chairs, a single modest window with light sheer curtains letting in warm soft afternoon daylight (NOT cold blue light, NOT high-contrast horror lighting), a faint cool-toned glass display case visible through the doorway or in a corner hinting this room connects to the exhibition hall outside, one or two small unrelated exhibition magical devices on a side shelf emitting a subtle pale blue-white arcane glow (NOT green — green is reserved for the protagonist's data-calculator device), the entrance door matches the one seen from the main hall: dark wood with a small frosted glass panel set into the upper half, a single thin dark wine-red ribbon or wax-seal mark left on the empty document folder, hinting something important is missing, mood: restrained quiet mystery, mature elegant detective-fiction atmosphere — explicitly NOT gothic horror, NOT haunted mansion, NOT vampire castle, NOT overly opulent palace room, this is a DESIGN REFERENCE sheet establishing the overall layout and mood — camera framing does not need to be final, not photorealistic photography, not a 3D render, not wide-angle fisheye lens distortion, no characters, no text, no UI, no watermark, not anime, not chibi --ar 16:9
```

**多機位9宮格prompt**（搭配上方場景設定圖一併附上當image reference）：

```
3x3 grid contact sheet, 9 panels total, each panel showing the EXACT SAME small private negotiation room (identical dark wood table, the empty leather document folder with its wine-red ribbon, two simple chairs, the modest curtained window, the frosted-glass entrance door, and the side shelf with blue-white glowing instruments — same furniture, same color palette, same warm afternoon lighting as the scene-setting reference image attached) but photographed from a different camera angle and distance — vary across: (1) wide establishing angle, (2) medium shot from the left side near the window, (3) medium shot from the right side near the shelf, (4) close shot focused on the document folder on the table, (5) eye-level shot looking toward the entrance door, (6) slightly higher angle looking down at the table, (7) slightly lower angle, (8) asymmetric off-center crop favoring the window, (9) asymmetric off-center crop favoring the door, consistent semi-realistic 2.5D painterly illustration style across all 9 panels, thin grid divider lines between panels, small number label (1-9) in the corner of each panel, no characters, no UI text, no watermark, not anime, not chibi --ar 1:1
```

---

### D3. 展示廳・側門/後巷出口

**狀態：已完成**——[case1_bg/d3_exhibition_hall_side_door.png](case1_bg/d3_exhibition_hall_side_door.png)，
9宮格見[case1_bg_grid9/d3_exhibition_hall_side_door.png](case1_bg_grid9/d3_exhibition_hall_side_door.png)。

對應劇本場景③⑤，無記錄出口，熱點：側門痕跡（線索物）。劇本時間：午後斜光（傍晚漸近）。

風格參考（色調/材質/陳設參考，非視角參考）：[d3_exhibition_hall_side_door.png](case1_720scene/d3_exhibition_hall_side_door.png)

**場景描述**：a narrow side-door exit alley behind a noble city exhibition hall, worn
stone wall, late-afternoon shadow light turning slightly golden, damp cobblestone
ground, overlooked and unremarkable feeling, quiet mystery undertone, the door matches
the one seen from inside the exhibition hall: a plain unmarked service door, slightly
recessed, slightly open, a faint dark wine-red smudge or scuff mark near the door
handle, subtle, easy to miss, hinting at the danger of this overlooked exit

```
16:9 widescreen aspect ratio (1920x1080), semi-realistic 2.5D illustrated game environment concept art, painterly digital illustration style (NOT photorealistic photography, NOT a 3D render, NOT real estate photography), single clear establishing view of a narrow side-door exit alley behind a noble city exhibition hall, worn stone wall, late-afternoon shadow light turning slightly golden, damp cobblestone ground, overlooked and unremarkable feeling, quiet mystery undertone, the door matches the one seen from inside the exhibition hall: a plain unmarked service door, slightly recessed, slightly open, a faint dark wine-red smudge or scuff mark near the door handle, subtle, easy to miss, hinting at the danger of this overlooked exit, this is a DESIGN REFERENCE sheet establishing the overall layout and mood — camera framing does not need to be final, not photorealistic photography, not a 3D render, not wide-angle fisheye lens distortion, not gothic horror, not a haunted mansion, avoid heavy baroque ornamentation, keep lighting warm not cold/horror-toned, no characters, no text, no UI, no watermark, not anime, not chibi --ar 16:9
```

**多機位9宮格prompt**（搭配上方場景設定圖一併附上當image reference）：

```
3x3 grid contact sheet, 9 panels total, each panel showing the EXACT SAME narrow side-door exit alley (identical worn stone wall, the plain unmarked service door with its faint wine-red smudge near the handle, damp cobblestone ground — same materials, same color palette, same late-afternoon golden lighting as the scene-setting reference image attached) but photographed from a different camera angle and distance — vary across: (1) wide establishing angle, (2) medium shot from the left, (3) medium shot from the right, (4) close shot focused on the door handle and smudge mark, (5) eye-level shot looking straight at the door, (6) slightly higher angle looking down the alley, (7) slightly lower angle, (8) asymmetric off-center crop favoring the door, (9) asymmetric off-center crop favoring the open alley space, consistent semi-realistic 2.5D painterly illustration style across all 9 panels, thin grid divider lines between panels, small number label (1-9) in the corner of each panel, no characters, no UI text, no watermark, not anime, not chibi --ar 1:1
```

---

## Story Dialogue 固定BG（A、B、C、E、F）

### A. 偵探所室內

**狀態：已完成**（午後版）——[case1_bg/a_detective_office.png](case1_bg/a_detective_office.png)，
9宮格見[case1_bg_grid9/a_detective_office.png](case1_bg_grid9/a_detective_office.png)。夜晚版仍待補。

對應劇本場景①（日常）、⑩（收尾）。場景①是午後陽光，場景⑩是夜晚僅留檯燈光——
**同一地點兩種光線**，建議優先畫午後版（場景①出現得早），夜晚版可後續視需要再補，
或由engine用色調濾鏡模擬夜晚效果。

風格參考（色調/材質/陳設參考，非視角參考）：[a_detective_office.png](case1_720scene/a_detective_office.png)

**場景描述**：a noble detective's private office, dark charcoal and deep wood interior,
silver trim details, ivory case-file papers stacked on an antique desk, a quiet magical
data-calculator device with faint green glow on a side table, tall bookshelves lined
with odd labeled magical trinkets, warm afternoon sunlight slanting through tall
windows, dust motes visible in the light, restrained magic aesthetic, mature elegant
atmosphere

```
16:9 widescreen aspect ratio (1920x1080), semi-realistic 2.5D illustrated game environment concept art, painterly digital illustration style (NOT photorealistic photography, NOT a 3D render, NOT real estate photography), single clear establishing view of a noble detective's private office, dark charcoal and deep wood interior, silver trim details, ivory case-file papers stacked on an antique desk, a quiet magical data-calculator device with faint green glow on a side table, tall bookshelves lined with odd labeled magical trinkets, warm afternoon sunlight slanting through tall windows, dust motes visible in the light, restrained magic aesthetic, mature elegant atmosphere, this is a DESIGN REFERENCE sheet establishing the overall layout and mood — camera framing does not need to be final, not photorealistic photography, not a 3D render, not wide-angle fisheye lens distortion, not gothic horror, not a haunted mansion, avoid heavy baroque ornamentation, keep lighting warm not cold/horror-toned, no characters, no text, no UI, no watermark, not anime, not chibi --ar 16:9
```

**多機位9宮格prompt**（搭配上方場景設定圖一併附上當image reference）：

```
3x3 grid contact sheet, 9 panels total, each panel showing the EXACT SAME noble detective's private office (identical antique desk with case-file papers, the data-calculator device with its faint green glow, tall bookshelves with magical trinkets, the curtained window — same furniture, same color palette, same warm afternoon lighting as the scene-setting reference image attached) but photographed from a different camera angle and distance — vary across: (1) wide establishing angle, (2) medium shot from behind the desk, (3) medium shot from the bookshelf side, (4) close shot focused on the desk and data-calculator device, (5) eye-level shot looking toward the window, (6) slightly higher angle looking down at the desk, (7) slightly lower angle, (8) asymmetric off-center crop favoring the bookshelves, (9) asymmetric off-center crop favoring the window, consistent semi-realistic 2.5D painterly illustration style across all 9 panels, thin grid divider lines between panels, small number label (1-9) in the corner of each panel, no characters, no UI text, no watermark, not anime, not chibi --ar 1:1
```

---

### B. 克雷斯商會辦事處・接待會客室

**狀態：已完成**——
[case1_bg/b_guild_reception_office.png](case1_bg/b_guild_reception_office.png)，
已確認桌上裝飾儀器是暖黃燭光，沒有誤用綠光。9宮格尚未生成。

對應劇本場景②（接案）。劇本時間：日間。

風格參考（色調/材質/陳設參考，非視角參考）：[b_guild_reception_office.png](case1_720scene/b_guild_reception_office.png)

**場景描述**：western fantasy noble city setting, a merchant guild reception office,
polished dark wood paneling, silver and bronze accents, a formal desk for a senior
negotiator, framed magical-device patent certificates on the wall, ivory curtains,
faint cool daylight, professional and slightly tense atmosphere, restrained magic
aesthetic, one side of the room has a tall dark wood door with a polished silver
handle and a small engraved brass nameplate, closed, leading out to a corridor

```
16:9 widescreen aspect ratio (1920x1080), semi-realistic 2.5D illustrated game environment concept art, painterly digital illustration style (NOT photorealistic photography, NOT a 3D render, NOT real estate photography), single clear establishing view of western fantasy noble city setting, a merchant guild reception office, polished dark wood paneling, silver and bronze accents, a formal desk for a senior negotiator, framed magical-device patent certificates on the wall, ivory curtains, faint cool daylight, professional and slightly tense atmosphere, restrained magic aesthetic, one side of the room has a tall dark wood door with a polished silver handle and a small engraved brass nameplate, closed, leading out to a corridor, this is a DESIGN REFERENCE sheet establishing the overall layout and mood — camera framing does not need to be final, not photorealistic photography, not a 3D render, not wide-angle fisheye lens distortion, not gothic horror, not a haunted mansion, avoid heavy baroque ornamentation, keep lighting warm not cold/horror-toned, no characters, no text, no UI, no watermark, not anime, not chibi --ar 16:9
```

**多機位9宮格prompt**（搭配上方場景設定圖一併附上當image reference）：

```
3x3 grid contact sheet, 9 panels total, each panel showing the EXACT SAME merchant guild reception office (identical formal desk, framed patent certificates on the wall, ivory curtains, the tall dark wood door with brass nameplate — same furniture, same color palette, same faint cool daylight as the scene-setting reference image attached) but photographed from a different camera angle and distance — vary across: (1) wide establishing angle, (2) medium shot from behind the desk, (3) medium shot from the door side, (4) close shot focused on the desk, (5) eye-level shot looking toward the door, (6) slightly higher angle looking down, (7) slightly lower angle, (8) asymmetric off-center crop favoring the door, (9) asymmetric off-center crop favoring the certificate wall, consistent semi-realistic 2.5D painterly illustration style across all 9 panels, thin grid divider lines between panels, small number label (1-9) in the corner of each panel, no characters, no UI text, no watermark, not anime, not chibi --ar 1:1
```

---

### C. 克雷斯商會辦事處・走廊

**狀態：已完成**——
[case1_bg/c_guild_corridor.png](case1_bg/c_guild_corridor.png)。
9宮格尚未生成。

對應劇本場景⑦（走廊喘息）。劇本明確描述：傍晚橘紅光暈灑落長窗。

風格參考（色調/材質/陳設參考，非視角參考）：[c_guild_corridor.png](case1_720scene/c_guild_corridor.png)

**場景描述**：western fantasy noble city interior corridor, dark charcoal walls with
silver trim, rows of closed office doors, a tall window letting in warm orange-red
evening light that cuts across the floor in long bands, calm and slightly melancholic
mood, faint dust in the air, ivory floor tiles, minimal restrained magic detail, along
the corridor one door matches a reception office entrance: a tall dark wood door with
a polished silver handle and a small engraved brass nameplate

```
16:9 widescreen aspect ratio (1920x1080), semi-realistic 2.5D illustrated game environment concept art, painterly digital illustration style (NOT photorealistic photography, NOT a 3D render, NOT real estate photography), single clear establishing view of western fantasy noble city interior corridor, dark charcoal walls with silver trim, rows of closed office doors, a tall window letting in warm orange-red evening light that cuts across the floor in long bands, calm and slightly melancholic mood, faint dust in the air, ivory floor tiles, minimal restrained magic detail, along the corridor one door matches a reception office entrance: a tall dark wood door with a polished silver handle and a small engraved brass nameplate, this is a DESIGN REFERENCE sheet establishing the overall layout and mood — camera framing does not need to be final, not photorealistic photography, not a 3D render, not wide-angle fisheye lens distortion, not gothic horror, not a haunted mansion, avoid heavy baroque ornamentation, keep lighting warm not cold/horror-toned, no characters, no text, no UI, no watermark, not anime, not chibi --ar 16:9
```

**多機位9宮格prompt**（搭配上方場景設定圖一併附上當image reference）：

```
3x3 grid contact sheet, 9 panels total, each panel showing the EXACT SAME noble city interior corridor (identical dark charcoal walls with silver trim, rows of closed office doors, the tall window with orange-red evening light, the reception-office door with brass nameplate — same materials, same color palette, same evening lighting as the scene-setting reference image attached) but photographed from a different camera angle and distance — vary across: (1) wide establishing angle, (2) medium shot looking down the corridor, (3) medium shot from the window side, (4) close shot focused on the reception-office door, (5) eye-level shot facing down the corridor, (6) slightly higher angle looking down, (7) slightly lower angle, (8) asymmetric off-center crop favoring the window, (9) asymmetric off-center crop favoring the doors, consistent semi-realistic 2.5D painterly illustration style across all 9 panels, thin grid divider lines between panels, small number label (1-9) in the corner of each panel, no characters, no UI text, no watermark, not anime, not chibi --ar 1:1
```

---

### E. 旅館大廳附設茶室

**狀態：已完成**——
[case1_bg/e_hotel_tea_room.png](case1_bg/e_hotel_tea_room.png)，
暗酒紅椅子細節、立鐘皆已落實。9宮格尚未生成。

對應劇本場景⑨（旅館對質）。劇本時間：傍晚（案發當日，⑨在⑧之後、F之前）。

風格參考（色調/材質/陳設參考，非視角參考）：[e_hotel_tea_room.png](case1_720scene/e_hotel_tea_room.png)

**場景描述**：an elegant hotel lobby tea room in a wealthy western fantasy town, dark
charcoal and deep wood furniture, silver candle sconces, ivory tablecloths, small round
tea tables with porcelain sets, soft warm evening light through tall windows, calm
public space with an undercurrent of tension, restrained magic aesthetic, a single dark
wine-red velvet detail on one chair or curtain trim, subtle accent hinting at underlying
tension, an old standing clock visible in a corner

```
16:9 widescreen aspect ratio (1920x1080), semi-realistic 2.5D illustrated game environment concept art, painterly digital illustration style (NOT photorealistic photography, NOT a 3D render, NOT real estate photography), single clear establishing view of an elegant hotel lobby tea room in a wealthy western fantasy town, dark charcoal and deep wood furniture, silver candle sconces, ivory tablecloths, small round tea tables with porcelain sets, soft warm evening light through tall windows, calm public space with an undercurrent of tension, restrained magic aesthetic, a single dark wine-red velvet detail on one chair or curtain trim, subtle accent hinting at underlying tension, an old standing clock visible in a corner, this is a DESIGN REFERENCE sheet establishing the overall layout and mood — camera framing does not need to be final, not photorealistic photography, not a 3D render, not wide-angle fisheye lens distortion, not gothic horror, not a haunted mansion, avoid heavy baroque ornamentation, keep lighting warm not cold/horror-toned, no characters, no text, no UI, no watermark, not anime, not chibi --ar 16:9
```

**多機位9宮格prompt**（搭配上方場景設定圖一併附上當image reference）：

```
3x3 grid contact sheet, 9 panels total, each panel showing the EXACT SAME elegant hotel lobby tea room (identical dark wood furniture, silver candle sconces, small round tea tables with porcelain sets, the standing clock, the wine-red velvet detail — same furniture, same color palette, same warm evening lighting as the scene-setting reference image attached) but photographed from a different camera angle and distance — vary across: (1) wide establishing angle, (2) medium shot from the left, (3) medium shot from the right, (4) close shot focused on one tea table, (5) eye-level shot across the room, (6) slightly higher angle looking down, (7) slightly lower angle, (8) asymmetric off-center crop favoring the standing clock corner, (9) asymmetric off-center crop favoring the windows, consistent semi-realistic 2.5D painterly illustration style across all 9 panels, thin grid divider lines between panels, small number label (1-9) in the corner of each panel, no characters, no UI text, no watermark, not anime, not chibi --ar 1:1
```

---

### F. 旅館外・傍晚街道

**狀態：已完成**——
[case1_bg/f_hotel_exterior_street.png](case1_bg/f_hotel_exterior_street.png)。9宮格尚未生成。

對應劇本「旅館外　蘇菲亞真正被認可的瞬間」。劇本明確描述：走出旅館後夕陽斜照、風比白天涼。
**這是劇本定稿後才新增的場景，舊版scene_prompts.md沒有規劃過，沒有對應720全景可參考。**

**場景描述**：a quiet cobblestone street outside an elegant hotel in a wealthy western
fantasy town, warm low sunset light casting long soft shadows, a few street lamps not
yet lit, distant rooftops and chimneys silhouetted against the orange-pink sky, calm
end-of-day atmosphere with a faint bittersweet undertone, restrained magic aesthetic,
ivory-toned building facades with silver window trim

```
16:9 widescreen aspect ratio (1920x1080), semi-realistic 2.5D illustrated game environment concept art, painterly digital illustration style (NOT photorealistic photography, NOT a 3D render, NOT real estate photography), single clear establishing view of a quiet cobblestone street outside an elegant hotel in a wealthy western fantasy town, warm low sunset light casting long soft shadows, a few street lamps not yet lit, distant rooftops and chimneys silhouetted against the orange-pink sky, calm end-of-day atmosphere with a faint bittersweet undertone, restrained magic aesthetic, ivory-toned building facades with silver window trim, this is a DESIGN REFERENCE sheet establishing the overall layout and mood — camera framing does not need to be final, not photorealistic photography, not a 3D render, not wide-angle fisheye lens distortion, not gothic horror, not a haunted mansion, avoid heavy baroque ornamentation, no characters, no text, no UI, no watermark, not anime, not chibi --ar 16:9
```

**多機位9宮格prompt**（搭配上方場景設定圖一併附上當image reference）：

```
3x3 grid contact sheet, 9 panels total, each panel showing the EXACT SAME quiet cobblestone street outside an elegant hotel (identical ivory-toned building facades with silver window trim, unlit street lamps, distant rooftops and chimneys — same materials, same color palette, same warm sunset lighting as the scene-setting reference image attached) but photographed from a different camera angle and distance — vary across: (1) wide establishing angle, (2) medium shot from the left, (3) medium shot from the right, (4) close shot near a street lamp, (5) eye-level shot looking down the street, (6) slightly higher angle looking down, (7) slightly lower angle, (8) asymmetric off-center crop favoring the hotel entrance, (9) asymmetric off-center crop favoring the open street, consistent semi-realistic 2.5D painterly illustration style across all 9 panels, thin grid divider lines between panels, small number label (1-9) in the corner of each panel, no characters, no UI text, no watermark, not anime, not chibi --ar 1:1
```

---

## 待補事項

- A場景的夜晚版本（對應場景⑩）：可後續補一張專用夜景圖，或先用engine色調濾鏡模擬。
- 每個場景現在都已有「場景設定圖prompt」+「多機位9宮格prompt」，可直接生圖。
- 9宮格選定鏡位後，正式背景prompt（步驟3）待補——把選中的鏡位描述寫成單張prompt，
  移除「design reference / 9宮格」相關字句即可。
- 熱點特寫卡片素材（文件袋蠟封、側門污漬等）：規格與清單見對話紀錄，待場景設定圖
  定案後再個別生成。
- 互動UI元素（放大鏡熱點icon、特寫卡片彈窗框）：跨案件通用UI零件，建議併入Map
  Walker零件本身的開發範圍，不在本檔案的背景圖生成範圍內。
