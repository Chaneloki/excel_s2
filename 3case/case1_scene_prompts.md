# 案件一《缺席者的名字》場景生成 Prompt 清單（風格參考用，已不再擴充）

> **狀態說明**：本檔案的全景圖確定**不會直接當成遊戲內背景**，Map Walker採用固定視角
> 單畫面構圖（參考 [0mockup/map_walker_mockup.png](../0mockup/map_walker_mockup.png)），
> 不是可環視全景。本檔案保留下來純粹作為**美術風格/構圖一致性的參考稿**，正式要用的
> 背景請見 [case1_bg_prompts_flat_v1.md](case1_bg_prompts_flat_v1.md)。

本文件整理案件一劇本（[case1_setting_v1.pdf](case1_setting_v1.pdf)）所需的場景背景圖，
全部採用**完整球形全景（full spherical equirectangular panorama，2:1比例，上下含天花板/
地板）**格式，原規劃方便之後在Godot Map Walker做可環視場景。

美術風格錨點對齊 [0mockup/ui_style_guide_v0.1.md](../0mockup/ui_style_guide_v0.1.md) 與
[0mockup/character_style_guide_v0.1.md](../0mockup/character_style_guide_v0.1.md)：
半寫實2.5D、貴族偵探×魔法資料學×安靜懸疑，深炭黑/深木色底、銀色/古銅金邊框、克制的淡綠魔法
互動光、象牙白文件感、**少量暗酒紅**用於警告/重要線索/危險感，避免anime/cyberpunk/華麗魔法陣/
普通RPG道具欄感。

---

## 場景清單

| 場景 | 對應劇本場景 | 用途 |
|---|---|---|
| A. 偵探所室內 | ①日常、⑩收尾 | host辦公室，案件起點與終點 |
| B. 克雷斯商會辦事處・接待會客室 | ②接案 | 莉莉/Sophia初次接案 |
| C. 克雷斯商會辦事處・走廊 | ⑦喘息 | 等帳務調閱時的小劇情 |
| D1. 展示廳・主展場 | ③⑤地圖走查 | 整體可走查空間 |
| D2. 展示廳・洽談室 | ③⑤走查熱點 | 案發現場 |
| D3. 展示廳・側門/後巷出口 | ③⑤走查熱點 | 貝洛特離場盲點 |
| E. 旅館大廳或附設茶室 | ⑨對質 | 三段式對質戲舞台 |

**門連結一致性**：B↔C、D1↔D2、D1↔D3 是同一建築/場景群內互通的空間，
兩端prompt使用完全相同的門外觀描述句，確保AI生圖時門長相一致。

---

## A. 偵探所室內

```
full spherical equirectangular panorama, 2:1 aspect ratio, must include ceiling at the top and floor at the bottom, not just a horizontal strip, seamless 360x180 coverage, semi-realistic 2.5D game environment art, western fantasy detective world, a noble detective's private office, dark charcoal and deep wood interior, silver trim details, ivory case-file papers stacked on an antique desk, a quiet magical data-calculator device with faint green glow on a side table, tall bookshelves with odd magical trinkets, dim warm lamp light, restrained magic aesthetic, mature elegant atmosphere, no characters, no text, no watermark, not anime, not chibi
```

---

## B. 克雷斯商會辦事處・接待會客室

```
full spherical equirectangular panorama, 2:1 aspect ratio, must include ceiling at the top and floor at the bottom, not just a horizontal strip, seamless 360x180 coverage, semi-realistic 2.5D game environment art, western fantasy noble city setting, a merchant guild reception office, polished dark wood paneling, silver and bronze accents, a formal desk for a senior negotiator, framed magical-device patent certificates on the wall, ivory curtains, faint cool daylight, professional and slightly tense atmosphere, restrained magic aesthetic, one side of the room has a tall dark wood door with a polished silver handle and a small engraved brass nameplate, closed, leading out to a corridor, no characters, no text, no watermark, not anime, not chibi
```

---

## C. 克雷斯商會辦事處・走廊

```
full spherical equirectangular panorama, 2:1 aspect ratio, must include ceiling at the top and floor at the bottom, not just a horizontal strip, seamless 360x180 coverage, semi-realistic 2.5D game environment art, western fantasy noble city interior corridor, dark charcoal walls with silver trim, rows of closed office doors, soft ambient lantern light, quiet and calm mood, faint dust in the air, ivory floor tiles, minimal restrained magic detail, along the corridor one door matches a reception office entrance: a tall dark wood door with a polished silver handle and a small engraved brass nameplate, no characters, no text, no watermark, not anime, not chibi
```

---

## D1. 展示廳・主展場

```
full spherical equirectangular panorama, 2:1 aspect ratio, must include ceiling at the top and floor at the bottom, not just a horizontal strip, seamless 360x180 coverage, semi-realistic 2.5D game environment art, western fantasy magical-device exhibition hall, rows of display tables showing small intricate magic devices under glass, dark wood and silver booth frames, soft green magical glow accents on display items, a guest registration desk near the entrance, ivory banners with the merchant guild crest, elegant but business-like atmosphere, restrained magic aesthetic, on one side a dark wood door with a small frosted glass panel set into the upper half, slightly ajar, leading to a private negotiation room, near a back corner a plain unmarked service door, slightly recessed into the wall, easy to overlook, no characters, no text, no watermark, not anime, not chibi
```

---

## D2. 展示廳・洽談室

```
full spherical equirectangular panorama, 2:1 aspect ratio, must include ceiling at the top and floor at the bottom, not just a horizontal strip, seamless 360x180 coverage, semi-realistic 2.5D game environment art, a small private negotiation room inside a magical-device exhibition hall, dark wood table with an empty leather document folder, two chairs, silver-framed window with sheer curtains, faint cool afternoon light, quiet and slightly ominous stillness, the entrance door matches the one seen from the main hall: dark wood with a small frosted glass panel set into the upper half, a single thin dark wine-red ribbon or wax-seal mark left on the empty document folder, hinting something important is missing, no characters, no text, no watermark, not anime, not chibi
```

---

## D3. 展示廳・側門/後巷出口

```
full spherical equirectangular panorama, 2:1 aspect ratio, must include ceiling/sky at the top and floor/ground at the bottom, not just a horizontal strip, seamless 360x180 coverage, semi-realistic 2.5D game environment art, a narrow side-door exit alley behind a noble city exhibition hall, worn stone wall, dim late-afternoon shadow light, damp cobblestone ground, overlooked and unremarkable feeling, quiet mystery undertone, the door matches the one seen from inside the exhibition hall: a plain unmarked service door, slightly recessed, slightly open, a faint dark wine-red smudge or scuff mark near the door handle, subtle, easy to miss, hinting at the danger of this overlooked exit, no characters, no text, no watermark, not anime, not chibi
```

---

## E. 旅館大廳或附設茶室

```
full spherical equirectangular panorama, 2:1 aspect ratio, must include ceiling at the top and floor at the bottom, not just a horizontal strip, seamless 360x180 coverage, semi-realistic 2.5D game environment art, an elegant hotel lobby tea room in a wealthy western fantasy town, dark charcoal and deep wood furniture, silver candle sconces, ivory tablecloths, small round tea tables with porcelain sets, soft warm evening light through tall windows, calm public space with an undercurrent of tension, restrained magic aesthetic, a single dark wine-red velvet detail on one chair or curtain trim, subtle accent hinting at underlying tension, no characters, no text, no watermark, not anime, not chibi
```
