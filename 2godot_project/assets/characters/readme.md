# 角色立繪（Story Dialogue UI用）

這個資料夾放 `02_story_dialogue_ui_demo` 用的角色去背立繪，包含每位角色
的預設立繪跟表情差分。原始檔分散在`1char/host_face/`、`1char/sophia_
face/`、`1char/case1_npc/`，複製進來方便Godot專案內引用。

| 檔案 | 角色 | 用途 |
|---|---|---|
| `host_lisia_story_transparent_v0_1.png` | 莉希雅 | 預設立繪 |
| `host_lisia_confidence_v0_1.png` | 莉希雅 | 表情差分：自信 |
| `host_lisia_dramatic_cry_v0_1.png` | 莉希雅 | 表情差分：誇張哭腔 |
| `host_lisia_fake_serious_v0_1.png` | 莉希雅 | 表情差分：假裝正經 |
| `host_lisia_fake_stupid_v0_1.png` | 莉希雅 | 表情差分：裝傻 |
| `host_lisia_no_comment_v0_1.png` | 莉希雅 | 表情差分：無言/沒意見 |
| `sophia_story_transparent_v0_1.png` | 蘇菲亞 | 預設立繪 |
| `sophia_elegant_v0_1.png` | 蘇菲亞 | 表情差分：優雅（來源`I_am_elegant.png`） |
| `sophia_funny_think_v0_1.png` | 蘇菲亞 | 表情差分：疑惑思考 |
| `sophia_no_comment_v0_1.png` | 蘇菲亞 | 表情差分：無言/沒意見 |
| `sophia_please_v0_1.png` | 蘇菲亞 | 表情差分：害羞懇求 |
| `sophia_pretend_accept_v0_1.png` | 蘇菲亞 | 表情差分：戴著笑臉面具假裝接受 |
| `evis_story_transparent_v0_1.png` | 艾維斯 | 預設立繪（來源`aldric.png`），目前無表情差分 |
| `tucker_story_transparent_v0_1.png` | 塔克 | 預設立繪（來源`tak.png`），目前無表情差分 |
| `shimmer_story_transparent_v0_1.png` | 席默 | 預設立繪（來源`simor.png`），目前無表情差分 |
| `rena_story_transparent_v0_1.png` | 瑞娜 | 預設立繪（來源`rina.png`），目前無表情差分 |
| `beloit_story_transparent_v0_1.png` | 貝洛特 | 預設立繪（來源`belot/得體假笑.png`） |
| `beloit_calm_v0_1.png` | 貝洛特 | 表情差分：太鎮定（來源`belot/太鎮定.png`） |
| `beloit_cracking_v0_1.png` | 貝洛特 | 表情差分：裂縫僵硬（來源`belot/裂縫僵硬.png`） |
| `beloit_silent_warning_v0_1.png` | 貝洛特 | 表情差分：沉默警告（來源`belot/沉默警告.png`） |

哪個角色有哪些表情、哪句對白要換成哪張，見
[data/cases/case_01.json](../../data/cases/case_01.json)的`characters`
（含`expressions`子欄位）跟各句的`"expression"`欄位；換貼圖邏輯見
`02_story_dialogue_ui_demo.gd`的`_resolve_sprite_path()`／
`_update_speaker_sprite()`。沒有表情差分的角色（艾維斯/塔克/席默/瑞娜）
只會顯示預設立繪，不影響功能，之後補表情差分素材時只需要在json的
`expressions`新增對照即可，不用改程式碼。
