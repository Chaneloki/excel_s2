# SE 音效素材

這個資料夾存放 Chapter 1 劇情對白可逐句觸發的短音效。素材複製自專案
根目錄的 `1se/`；複製進 Godot 專案時已把檔名空白統一改成小寫底線，
原始素材沒有修改。

## 對白使用方式

在 `data/cases/case_01.json` 的任一句對白加入 `se` 欄位，值使用不含
`.mp3` 的檔名：

```json
{
  "id": "ch1_example",
  "type": "narration",
  "text": "門鎖發出一聲輕響。",
  "se": "door_open"
}
```

播放邏輯位於 `09_chapter1_dialogue.gd`：進入該句時播放
`res://assets/se/door_open.mp3` 一次，音量由設定畫面的「音效音量」控制，
不影響背景音樂。

同一句需要同時播放兩個或更多音效時，改用陣列：

```json
{
  "text": "門被推開，遠處的鐘聲同時響起。",
  "se": ["door_open", "bell"]
}
```

新增素材時，檔名必須使用小寫字母、數字與底線，不可使用空白；目前播放
器統一讀取 MP3。
