---@diagnostic disable: lowercase-global
---↑仮にまじめなもの作るとしたらこのdiagnosticは消す

---@diagnostic disable: undefined-global
---↑fuとかbmdとか認識してくれないからしかたない



--どーせ固定値だからいいと思う
CONFIG_FILE_PATH = [[C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Config\VoiceAutoTool_Config\AutoTool_Config.lua]]

--デフォの値
VOICEFOLDER_PATH=""
AUDIO_INDEX = 1
VOICEBIN_NAME="AutoTool"
FHT_PATH=[[C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Modules\Lua\Utf8Sjis.tbl]]

config = { 
  VOICEFOLDER_PATH = [[C:\hogehoge]],
  AUDIO_INDEX = 1,
  VOICEBIN_NAME = [[VoiceAutoTool]],
  FHT_PATH = [[C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Modules\Lua\Utf8Sjis.tbl]]
}

--Config設定
config_isexist=io.open(CONFIG_FILE_PATH,"r")
io.close()
if config_isexist~=nil then 
--Configファイルから値読み込み、実際は外部の.Lua実行結果の返り値を持ってきてるだけ
  config = dofile(CONFIG_FILE_PATH)
end
--uiのうんぬん
ui = fu.UIManager
disp = bmd.UIDispatcher(ui)
local width,height = 600,350

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'My First Window',
  Geometry = { 100, 100, width, height },
  Spacing = 10,

  ui:VGroup{
    ID = 'root',

    -- Add your GUI elements here:
    ui:Label{ ID = 'Label1', Text = 'VOICEFOLDER_PATH(音声ファイルや字幕テキストが入ってるフォルダを指定)'},
    ui:LineEdit{ Text = config["VOICEFOLDER_PATH"], ID = "Line1" },
    ui:Label{ ID = 'Label2', Text = 'AUDIO_INDEX(エディットページで字幕化したい音声が置かれている位置、A1だと1でA2だと2で…)'},
    ui:SpinBox{ Value = config["AUDIO_INDEX"], ID = "Spin1" },
    ui:Label{ ID = 'Label3', Text = 'VOICEBIN_NAME(メディアプールに本ツール用に追加されるBinの名前を指定)'},
    ui:LineEdit{ Text = config["VOICEBIN_NAME"], ID = "Line2" },
    ui:Label{ ID = 'Label5', Text = '-'},
    ui:Button { Text = "保存", ID = "ButtonA" },
    ui:Button { Text = "終了", ID = "ButtonB" }
  },
})
itm = win:GetItems()

function win.On.ButtonA.Clicked(ev)
    --AutoTool_Config.luaに保存する
    f = io.open(CONFIG_FILE_PATH,"w")
    f:write("tbl = { \n")
    f:write("VOICEFOLDER_PATH = [[".. itm['Line1'].Text .."]],\n")
    f:write("AUDIO_INDEX = ".. itm['Spin1'].Value ..",\n")
    f:write("VOICEBIN_NAME = [[" .. itm['Line2'].Text .. "]],\n")
    f:write("FHT_PATH = [[".. config["FHT_PATH"] .. "]]\n")
    f:write("} \n")
    f:write("return tbl")
    io.close() 

    itm["Label5"].Text = "保存完了！！！！"
end

function win.On.ButtonB.Clicked(ev)
  disp:ExitLoop()
end

function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end
 
win:Show()
disp:RunLoop()
win:Hide()

--http://www.steakunderwater.com/wesuckless/viewtopic.php?p=36549&t=1411
--↑ui云々のリファレンス探したんだけど、ここにしか情報が見当たらない
