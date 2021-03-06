## VoiceAutoTool(仮)

Davinci Resolveで合成音声系の動画を作成するためのの作業効率化スクリプトが入っています。<br>
具体的には下の2つ
- 指定されたフォルダから音声ファイルををDavinciResolveに持ってきてタイムラインに置くスクリプト：AutoTool_MoveSound.lua
- DavinciResolveのタイムラインに置かれた音声ファイルを基に字幕ファイルを生成するスクリプト：AutoTool_Createsrt.lua

### ↓ここからダウンロードできます
https://github.com/NUROKU/DavinciResolve_VoiceAutoTool/releases

-------------------------------------------------------------
## インストール方法
1．VoiceAutoToolフォルダを↓のフォルダにそのまま置く<br>
　C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Scripts\Comp

2.　Luaフォルダを↓のフォルダにそのまま置く<br>
　C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Modules

3.　VoiceAutoTool_Configフォルダを↓のフォルダにそのまま置く<br>
　C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Config

以上。<br>

Davinci Resolveで適当なプロジェクトを開いて、上のタブから<br>
「ワークスペース→Script→Comp→VoiceAutoTool」でインストールしたスクリプト達にアクセスできます

--------------------------------------------------------------
## 前提条件
- 指定のフォルダに「音声ファイル」と「音声をテキスト化したテキストファイル」のどちらも入っている必要があります。また、この2つは拡張子以外同じファイル名である必要があります。
    - (VOICEROID勢はVoiceroidUtil使ってください…)

- Davinci Resolveの設定から「スクリプトの実行の許可」で設定が必要な可能性があります。
    - (デフォルトだと「ローカル環境のみ実行」になってると思うから大丈夫だとは思う…)

--------------------------------------------------------------
## 実行手順: AutoTool_MoveSound
指定されたフォルダから音声ファイルををDavinciResolveに持ってきてタイムラインに置くスクリプト


1. 上のタブから「ワークスペース→Script→Comp→VoiceAutoTool→**AutoTool_Config**」を選択
1. 開かれたウィンドウの「VOICEFOLDER_PATH」に、移動したい音声ファイルがおかれているフォルダを入力
1. 上のタブから「ワークスペース→Script→Comp→VoiceAutoTool→**AutoTool_MoveSound**」を実行

上記手順を行うことにより、音声がタイムラインに自動的に置かれるはずです


---------------------------------------------------------------
## 実行手順：AutoTool_CreateSrt

1. 上のタブから「ワークスペース→Script→Comp→VoiceAutoTool→**AutoTool_Config**」を選択
1. 開かれたウィンドウの「INDEX_AUDIO」に、字幕化したい音声ファイルが置かれているタイムラインのAudioの番号を指定<br>
(A1だと1,A2だと2...とりあえず一番上に置かれているものを字幕化したいなら1でOK)
1. 上のタブから「ワークスペース→Script→Comp→VoiceAutoTool→**AutoTool_CreateSrt**」を実行
1. メディアプールに出力されたsrtファイル(srt_9821397みたいな名前)を、タイムラインにドラッグ＆ドロップ

上記手順を行うことにより、音声に合わせた字幕が良い感じに置けるはずです

------------------------------------------------------------
他のいろんな情報はdocフォルダ下にあります。

連絡先

配布ページ：https://github.com/NUROKU/DavinciResolve_VoiceAutoTool/releases<br>
Githubページ：https://github.com/NUROKU/DavinciResolve_VoiceAutoTool<br>
作者Twitter(つまるところ連絡先): @nu_ro_ku

