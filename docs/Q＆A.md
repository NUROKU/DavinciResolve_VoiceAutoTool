# Q＆A

## スクリプト全般
*Q.* いちいちUI上でスクリプト指定するのめんどうくさい<br>
*A.* ショートカット登録機能があるので、それで頑張ってください<br>
上のタブから「Davinci Resolve→キーボードのカスタマイズ」を開き、コマンドの左の欄から「ワークスペース」を選択して右の欄から「スクリプト→VoiceAutoTool→AutoTool_MoveSound」を選択し、→の空白で登録したいショートカットキーを押す。<br>
私のおすすめはShift + Xです<br>

*Q.* Configが読み込めないって言われてる気がする<br>
*A.* ダウンロードしたVoiceAutoToolに含まれているConfigフォルダをそのまま下に再配置してください<br>
　C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion <br>
  つまるところ「‪C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Config\VoiceAutoTool_Config\AutoTool_Config.lua」にアクセスできれば大丈夫なはずです。それ以外だと多分バグです

*Q.* なんかうごかない<br>
*A.* 多分バグです、作者ツイッターかGithubのIssueにバグ報告くれるとありがたいです<br>
「ワークスペース→コンソール」を開いた状態でスクリプトを動かすとエラーメッセージが出力されるはずなので、そのエラーメッセージを作者宛に連絡くれるととても嬉しいです。

## MoveSound

## CreateSrt
*Q.* 字幕のテキストが「nil」になる<br>
*A.* 指定のフォルダに「音声ファイルと同じ名前のテキストファイル」が無かった可能性が高いです。それ以外だと多分バグです<br>

*Q.* 字幕が完成した動画に出力されてない<br>
*A.* レンダー設定の「字幕の書き出し」がオフになってると思うので、オンにしてください<br>

*Q.* 複数人の字幕をつけたい<br>
*A.* (Davinci Resolveの仕様的に)無理っぽいです。<br>





