# 案件一 NPC 角色設定圖／立繪生成 Prompt 清單

本文件整理案件一劇本（[case1_setting_v1.pdf](case1_setting_v1.pdf)）裡需要美術定案的
NPC角色prompt。塔克、席默（出現在展示廳・主展場D1）優先完成，艾維斯／瑞娜／貝洛特
三位（出現在B商會接待室、D2洽談室、E旅館茶室）的prompt也已補上，等候生圖與審核。

**狀態**：
- 塔克、席默的角色設定圖＋立繪皆已完成並通過審核
  （[1char_setting/case1_npc/](../1char_setting/case1_npc/)、
  [1char/case1_npc/](../1char/case1_npc/)），服裝/髮型/配色在兩張圖之間一致，
  且都正確遵守「淡綠光僅限數據計算儀」規則（席默的量測儀器用藍光）。
- 貝洛特、艾維斯、瑞娜：prompt已寫好（見下方），尚未生圖/審核。貝洛特優先度最高
  （場景⑨對質戲靈魂角色，已準備4種表情差分prompt），艾維斯、瑞娜各只需1張立繪
  （情緒線單一，暫不需要表情差分）。

美術風格錨點對齊 [0mockup/character_style_guide_v0.1.md](../0mockup/character_style_guide_v0.1.md)：
半寫實2.5D、貴族偵探×魔法資料學×安靜懸疑的世界觀下，**階級用服裝材質與細節表現**，
魔法元素克制，避免anime大眼/chibi/手遊抽卡式裝飾。

**每位角色需要兩張不同規格的圖，缺一不可**：

1. **角色設定圖（3視圖）**：對齊現有
   [1char_setting/host_setting.png](../1char_setting/host_setting.png) 的格式——
   左側一張臉部特寫，右側三張全身視圖（正面／3/4側面／背面），白底，同一套服裝
   設計，用來定案角色的完整外觀，之後立繪、Sprite3D billboard都以此為準。
2. **立繪（頭到胸口的半身像）**：對齊現有
   [1char/host.png](../1char/host.png) 的格式——只到胸口的近距離半身肖像，
   手上可以拿一個能代表這個角色的小道具，白底/透明底，用於Story Dialogue UI跟
   Map Walker的Sprite3D billboard。

兩張圖的**服裝、髮型、配色必須完全一致**（立繪是角色設定圖定案後的延伸應用，
不是重新設計）。

---

## 塔克（Tak）— 展示會門衛

人物卡依據：58歲，立場是關鍵證人。體型壯碩、說話大聲，笑容憨厚。相信「人會忘記但
本子不會」，凡事都記在隨身的記錄本上，本人沒有任何隱瞞，只是側門那段沒注意到。

**階級視覺定位**：依角色風格指南第5節「勞工/低收入角色」與「商人/委託人」之間——
門衛是受僱於商會的基層工作人員，服裝要**實用、整潔但不奢華**，不要畫成貧窮或骯髒，
是有穩定工作、受商會信任的角色。

### 1. 角色設定圖（3視圖）

```
character design reference sheet, semi-realistic 2.5D Korean game character illustration, western fantasy detective world, mature visual novel character, grounded magic setting, white background, one close-up face portrait on the left side plus three full-body views on the right side (front view, 3/4 side view, back view), identical outfit and proportions across all views, detailed fabric texture, clean lines, soft studio lighting, professional concept art quality, no text, no watermark, not anime, not chibi, a 58-year-old male exhibition hall door guard, stocky and burly build, weathered honest face with deep laugh lines, warm goofy reassuring smile, graying short hair, big calloused hands, simple practical guard/usher uniform — a sturdy vest over a plain shirt, thick leather belt, worn sturdy boots, plain dark and brown color palette, neat but unpretentious working-class presentation appropriate for trusted staff at a respectable merchant guild hall, a worn leather-bound notebook/ledger tucked at his belt as his signature prop, no jewelry, no flashy accessories, calm steady stance, restrained magic aesthetic with no visible magic effects on him, not gothic horror, not photorealistic photography, not a 3D render
```

### 2. 立繪（頭到胸口半身像）

```
semi-realistic 2.5D Korean game character illustration, head-and-chest bust portrait, close-up framing cropped at the chest, western fantasy detective world, mature visual novel character, white or transparent background, same outfit and design as the character reference sheet, a 58-year-old male exhibition hall door guard, stocky build, weathered honest face with deep laugh lines, warm goofy reassuring smile, graying short hair, simple vest over a plain shirt, holding his worn leather-bound notebook/ledger close to his chest with one hand as his signature prop, detailed fabric texture, clean lines, soft cinematic lighting, professional concept art quality, no text, no watermark, not anime, not chibi, not photorealistic photography, not a 3D render
```

**立繪規格建議**：1張（站立/拿筆記本、笑容）即可，他在劇本裡只出現一次（場景③），
不需要表情差分。

---

## 席默（Simor）— 參展工匠

人物卡依據：29歲，立場是無辜但行為可疑（天然煙幕彈）。高瘦、說話有點急促，習慣在
緊張時摸自己的袖口。有點神經質，聰明但容易焦慮，活在「快要被超越」的恐懼裡。與瑞娜
同期出道，早期有專利糾紛、關係冷淡。

**階級視覺定位**：依角色風格指南第5節「大學/學者/魔法技術者」——長外套、工具袋、
手套，顏色較冷靜克制，可有少量魔法晶石/量測工具，不要滿身魔法陣。

### 1. 角色設定圖（3視圖）

```
character design reference sheet, semi-realistic 2.5D Korean game character illustration, western fantasy detective world, mature visual novel character, grounded magic setting, white background, one close-up face portrait on the left side plus three full-body views on the right side (front view, 3/4 side view, back view), identical outfit and proportions across all views, detailed fabric texture, clean lines, soft studio lighting, professional concept art quality, no text, no watermark, not anime, not chibi, a 29-year-old male independent magical-device craftsman, tall and noticeably thin almost gaunt build, slightly hunched nervous posture, narrow anxious face, restless eyes, one hand habitually touching his own sleeve cuff as a nervous tic, neat fitted long craftsman's coat in muted cool grey-blue tones, a leather tool satchel slung across the body, fingerless gloves, a small measuring instrument or magical gauge clipped to his coat with a faint restrained pale blue-white glow (NOT green — green is reserved for the protagonist's data-calculator device), composed outward appearance with subtle visible tension underneath, restrained magic aesthetic, not gothic horror, not photorealistic photography, not a 3D render
```

### 2. 立繪（頭到胸口半身像）

```
semi-realistic 2.5D Korean game character illustration, head-and-chest bust portrait, close-up framing cropped at the chest, western fantasy detective world, mature visual novel character, white or transparent background, same outfit and design as the character reference sheet, a 29-year-old male independent magical-device craftsman, thin gaunt build, narrow anxious face, restless eyes, one hand touching his own sleeve cuff as a nervous tic, neat fitted long craftsman's coat in muted cool grey-blue tones, a small measuring instrument or magical gauge clipped to his coat with a faint restrained pale blue-white glow (NOT green), composed outward appearance with subtle visible tension underneath, detailed fabric texture, clean lines, soft cinematic lighting, professional concept art quality, no text, no watermark, not anime, not chibi, not photorealistic photography, not a 3D render
```

**立繪規格建議**：1張（站姿、隱約緊張的表情）即可，他在劇本裡只出現一次
（場景③），不需要表情差分。

---

## 貝洛特（Belot）— 場景⑨真兇

人物卡依據：42歲，真正的竊賊，名冊上身份是「採購商代表」，實際受維德商行指使。
西裝筆挺、頭髮梳得整齊、說話客氣但眼神總在觀察。劇本場景⑨對質戲的靈魂角色，
全案表情演出最重，**需要至少4種表情差分**：得體假笑、太鎮定、裂縫僵硬、沉默警告。

**階級視覺定位**：依角色風格指南第5節「商人/委託人」——表面打扮成有錢的採購商，
整潔且飾品偏亮（顯示是花錢打點出來的體面，不是世代貴族的沉穩），西裝剪裁精準但
細節處可以有一點過度修飾的痕跡，呼應劇本「得體像一層上過漆的木頭，光滑，卻摸不出
底下的紋路」的描寫。

### 1. 角色設定圖（3視圖）

```
character design reference sheet, semi-realistic 2.5D Korean game character illustration, western fantasy detective world, mature visual novel character, grounded magic setting, white background, one close-up face portrait on the left side plus three full-body views on the right side (front view, 3/4 side view, back view), identical outfit and proportions across all views, detailed fabric texture, clean lines, soft studio lighting, professional concept art quality, no text, no watermark, not anime, not chibi, a 42-year-old male posing as a wealthy merchant procurement representative, neat trim build, impeccably groomed slicked-back dark hair, smooth composed face with a polished practiced smile that never quite reaches the eyes, watchful calculating gaze, sharply tailored formal suit in dark tones with a faintly too-polished sheen, an expensive but slightly ostentatious cufflink and ring (money rather than generations of inherited wealth), crisp pocket square, immaculately clean manicured hands, neutral calm default expression, restrained magic aesthetic with no visible magic effects on him, not gothic horror, not photorealistic photography, not a 3D render
```

### 2. 立繪（頭到胸口半身像，4種表情差分）

**差分①　得體假笑**（社交場合的標準表情，光滑得體但沒有溫度）：

```
semi-realistic 2.5D Korean game character illustration, head-and-chest bust portrait, close-up framing cropped at the chest, western fantasy detective world, mature visual novel character, white or transparent background, same outfit and design as the character reference sheet, a 42-year-old male posing as a wealthy merchant procurement representative, impeccably groomed slicked-back dark hair, sharply tailored dark suit, a polished practiced courteous smile that does not reach the eyes, smooth composed expression, watchful calculating gaze beneath the smile, detailed fabric texture, clean lines, soft cinematic lighting, professional concept art quality, no text, no watermark, not anime, not chibi, not photorealistic photography, not a 3D render
```

**差分②　太鎮定**（聽到敏感問題時刻意維持的過度平靜，像放太久的茶）：

```
semi-realistic 2.5D Korean game character illustration, head-and-chest bust portrait, close-up framing cropped at the chest, western fantasy detective world, mature visual novel character, white or transparent background, same outfit and design as the character reference sheet, a 42-year-old male posing as a wealthy merchant procurement representative, impeccably groomed slicked-back dark hair, sharply tailored dark suit, an unnervingly flat and overly composed expression, eyes unusually still and unblinking, smile fading into neutral stillness, subtle controlled tension just beneath an otherwise unreadable surface, detailed fabric texture, clean lines, soft cinematic lighting, professional concept art quality, no text, no watermark, not anime, not chibi, not photorealistic photography, not a 3D render
```

**差分③　裂縫僵硬**（被點破身份瞬間，得體的表情第一次裂開）：

```
semi-realistic 2.5D Korean game character illustration, head-and-chest bust portrait, close-up framing cropped at the chest, western fantasy detective world, mature visual novel character, white or transparent background, same outfit and design as the character reference sheet, a 42-year-old male posing as a wealthy merchant procurement representative, impeccably groomed slicked-back dark hair, sharply tailored dark suit, a sudden stiff frozen posture, the polished smile cracking slightly at one corner, eyes widening just a fraction with poorly suppressed alarm, knuckles faintly whitening, the practiced composure visibly slipping for the first time, detailed fabric texture, clean lines, soft cinematic lighting, professional concept art quality, no text, no watermark, not anime, not chibi, not photorealistic photography, not a 3D render
```

**差分④　沉默警告**（交出設計圖後，留下最後一句警告時的眼神）：

```
semi-realistic 2.5D Korean game character illustration, head-and-chest bust portrait, close-up framing cropped at the chest, western fantasy detective world, mature visual novel character, white or transparent background, same outfit and design as the character reference sheet, a 42-year-old male posing as a wealthy merchant procurement representative, impeccably groomed slicked-back dark hair, sharply tailored dark suit now slightly less immaculate, no trace of the earlier smile, a quiet defeated but stubbornly defiant gaze, a low warning intensity in the eyes, jaw set, composed but cold, detailed fabric texture, clean lines, soft cinematic lighting, professional concept art quality, no text, no watermark, not anime, not chibi, not photorealistic photography, not a 3D render
```

---

## 艾維斯（Aldric）— 克雷斯商會辦事處負責人

人物卡依據：62歲，謹慎保守、說話慢條斯理，習慣思考時用手指敲桌子，渾濁的眼睛、
佈滿皺紋的手。出現於B場景②（接案）、⑦（走廊片段）、E場景⑧（費用申報）。
**貴族/中產商人混合定位**：不是世代貴族，是靠資歷跟人脈撐起來的資深商會負責人。

**階級視覺定位**：依角色風格指南第5節「商人/委託人」（資深、有錢者）與「貴族」
之間——服裝沉穩保守、剪裁傳統，飾品低調但確實高級（銀懷錶、印章戒指），不追新潮，
牆上掛著魔法器具專利證書暗示他長年處理商會專利事務。

### 1. 角色設定圖（3視圖）

```
character design reference sheet, semi-realistic 2.5D Korean game character illustration, western fantasy detective world, mature visual novel character, grounded magic setting, white background, one close-up face portrait on the left side plus three full-body views on the right side (front view, 3/4 side view, back view), identical outfit and proportions across all views, detailed fabric texture, clean lines, soft studio lighting, professional concept art quality, no text, no watermark, not anime, not chibi, a 62-year-old male senior merchant guild office director, solidly built with stooped cautious posture, deeply lined weathered face, heavy-lidded watchful eyes, neatly combed thinning grey hair, conservative old-fashioned formal long coat in dark muted tones with subtle silver trim, a low-key but evidently fine silver pocket watch chain and a signet ring as his signature props, hands posed mid-gesture as if tapping a table, deliberate unhurried bearing, restrained magic aesthetic with no visible magic effects on him, not gothic horror, not photorealistic photography, not a 3D render
```

### 2. 立繪（頭到胸口半身像）

```
semi-realistic 2.5D Korean game character illustration, head-and-chest bust portrait, close-up framing cropped at the chest, western fantasy detective world, mature visual novel character, white or transparent background, same outfit and design as the character reference sheet, a 62-year-old male senior merchant guild office director, deeply lined weathered face, heavy-lidded watchful eyes, neatly combed thinning grey hair, conservative dark formal long coat with subtle silver trim, one hand raised mid-gesture as if tapping a table, a fine silver pocket watch chain visible at his chest, calm deliberate cautious expression, detailed fabric texture, clean lines, soft cinematic lighting, professional concept art quality, no text, no watermark, not anime, not chibi, not photorealistic photography, not a 3D render
```

**立繪規格建議**：1張（沉穩、思考中的表情）即可，他在劇本裡情緒起伏不大，
暫不需要表情差分。

---

## 瑞娜（Rina）— 獨立工匠、設計圖持有人

人物卡依據：26歲，獨立工匠，身材纖細、雙手交握在身前，指節邊緣有一層磨得發亮的
厚繭（長年握同一種工具留下的痕跡），眼神銳利、直視不躲。出現於D2附近（場景⑤）
跟⑩收尾，花了三年畫設計圖、對作品有強烈的擁有感。

**階級視覺定位**：依角色風格指南第5節「大學/學者/魔法技術者」——長外套、工具袋、
手套，顏色冷靜克制，可有少量魔法晶石/量測工具，但比席默更獨立自尊：站姿更直、
眼神更穩定，不是緊張型角色。

### 1. 角色設定圖（3視圖）

```
character design reference sheet, semi-realistic 2.5D Korean game character illustration, western fantasy detective world, mature visual novel character, grounded magic setting, white background, one close-up face portrait on the left side plus three full-body views on the right side (front view, 3/4 side view, back view), identical outfit and proportions across all views, detailed fabric texture, clean lines, soft studio lighting, professional concept art quality, no text, no watermark, not anime, not chibi, a 26-year-old female independent magical-device craftswoman and inventor, slender but upright confident posture, sharp direct unwavering eyes, practical fitted long craftswoman's coat in muted cool tones, sleeves rolled or cuffed to reveal hands with visible calluses along the knuckles and fingertips from years of gripping drafting tools, a leather tool satchel or rolled blueprint case slung across the body as her signature prop, a small precision measuring instrument with a faint restrained pale blue-white glow clipped to her coat (NOT green — green is reserved for the protagonist's data-calculator device), proud self-reliant bearing, restrained magic aesthetic, not gothic horror, not photorealistic photography, not a 3D render
```

### 2. 立繪（頭到胸口半身像）

```
semi-realistic 2.5D Korean game character illustration, head-and-chest bust portrait, close-up framing cropped at the chest, western fantasy detective world, mature visual novel character, white or transparent background, same outfit and design as the character reference sheet, a 26-year-old female independent magical-device craftswoman and inventor, sharp direct unwavering eyes, practical fitted long craftswoman's coat in muted cool tones, one hand visible with calluses along the knuckles holding a rolled blueprint case close to her chest as her signature prop, proud composed expression with a faint undertone of protectiveness, detailed fabric texture, clean lines, soft cinematic lighting, professional concept art quality, no text, no watermark, not anime, not chibi, not photorealistic photography, not a 3D render
```

**立繪規格建議**：1張（站姿、抱著設計圖的保護性姿態）即可，她在劇本裡情緒線
單一（擔憂→失而復得），暫不需要表情差分。
