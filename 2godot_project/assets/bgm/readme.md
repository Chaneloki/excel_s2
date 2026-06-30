# 背景音樂（整合Demo用）

這個資料夾放整合Demo（`09_chapter1_dialogue.gd`）用的背景音樂，原始檔在
`1bgm/`，複製進來方便Godot專案內引用。Claude無法實際聽音檔判斷旋律，
這份對照是依檔名語意先排的草案，實際播放效果以使用者聽過確認為準。

| 檔案 | 原始檔名 | 用途 |
|---|---|---|
| `bgm_lycia_soft.mp3` | `lycia_soft.mp3` | 莉希雅獨自安靜的時刻（s01開場） |
| `bgm_sophia_soft.mp3` | `sophia_soft.mp3` | 蘇菲亞主導的安靜對話（s07走廊） |
| `bgm_lycia_and_sophia_warm.mp3` | `lycia_and_sophia_warm.mp3` | 兩人溫暖互動（s01重逢、s10結尾） |
| `bgm_charm_detective.mp3` | `charm_detective.mp3` | 莉希雅接案的興奮/魅力時刻 |
| `bgm_chill_investigate.mp3` | `chill_investigate.mp3` | 輕鬆調查（s03第一次走查，案件一無陷阱） |
| `bgm_energy_investigate.mp3` | `energy_investigate.mp3` | 稍緊湊的調查（s02接案、s05第二次走查） |
| `bgm_intense_investigate.mp3` | `intense_investigate.mp3` | 緊張調查（Excel三關COUNTIF/COUNTIFS/SUMIF） |
| `bgm_emotional_1.mp3` | `1_emotional.mp3` | 情感高潮一（s08結尾決定對質、cg2） |
| `bgm_emotional_2.mp3` | `2_emotional.mp3` | 情感高潮二（s09b結尾兩人對視微笑、cg3_closeup） |
| `bgm_touching.mp3` | `touching.mp3` | 溫情時刻（s09b開場走出旅館） |
| `bgm_finish_case.mp3` | `finish_case.mp3` | 結案（s10開場） |
| `bgm_sad.mp3` | `sad.mp3` | 悲傷（瑞娜抱回設計圖「我畫了三年」） |
| `bgm_funny.mp3` | `funny.mp3` | 搞笑/輕鬆（莉莉的冷面笑話、s10數錢） |
| `bgm_town.mp3` | `town.mp3` | 小鎮日常，目前案件一沒有用到，留給之後場景 |
| `bgm_theme_song_noble.mp3` | `theme_song_noble.mp3` | 主題曲（貴族向），目前沒有主選單場景可以用，留給之後 |
| `bgm_theme_song_high_energy.mp3` | `theme_song_high_energy.mp3` | 主題曲（高能量版），目前案件一沒有用到，留給之後 |

哪句對白觸發哪首BGM，見[data/cases/case_01.json](../../data/cases/case_01.json)
的`bgm_tracks`字典跟各句的`"bgm"`欄位；播放/切換邏輯見
`09_chapter1_dialogue.gd`的`_build_bgm_player()`/`_switch_bgm()`。
