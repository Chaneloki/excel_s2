# 場景背景（Story Dialogue UI用）

這個資料夾放 `02_story_dialogue_ui_demo` 在一般劇情對話模式用的場景背景，
跟Map Walker用的環境插畫（`assets/ui/map_walker/`）分開管理——前者是
Story Dialogue UI單張靜態背景，後者是可點熱點的探索場景。

| 檔案 | 用途 |
|---|---|
| `bg_detective_office.png` | 偵探所內部，來源`3case/case1_bg/a_detective_office.png`。對應劇本場景①開場、⑩收尾（同一地點重複用）。 |
| `bg_guild_reception_office.png` | 克雷斯商會辦事處（艾維斯辦公室），來源`3case/case1_bg/b_guild_reception_office.png`。對應劇本場景②。 |
| `bg_guild_corridor.png` | 商會辦事處走廊，來源`3case/case1_bg/c_guild_corridor.png`。對應劇本場景⑦。 |
| `bg_hotel_tea_room.png` | 旅館茶室，來源`3case/case1_bg/e_hotel_tea_room.png`。對應劇本場景⑨對質。 |
| `bg_hotel_exterior_street.png` | 旅館外日落街道，來源`3case/case1_bg/f_hotel_exterior_street.png`。對應劇本場景⑨b。 |

展示廳（D1/D2/D3）跟九宮格鏡位背景不在這裡，那些是Map Walker系統的素材，
放在`assets/ui/map_walker/`，因為劇本場景③⑤是地圖走查模式，不是Story
Dialogue UI的單張背景。哪個背景對應哪句對白，見
[data/cases/case_01.json](../../data/cases/case_01.json)的`backgrounds`
字典跟各句的`"background"`欄位，原始檔以`3case/case1_bg/`為準。
