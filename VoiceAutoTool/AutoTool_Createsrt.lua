--タイムラインに配置された音声を基に音声元ファイルと同フォルダのテキストを読み込んで字幕ファイルを作成する

--出力されるsrtファイルの例
--1
--00:00:00,000 --> 00:00:10,000
--0秒からhoghoegegegegsuohfs10秒間に表示する字幕の内容を書きます。
--
--2
--00:00:10,000 --> 00:00:30,000
--10秒から30秒間に表示する字幕の内容を書きます。 
--

---@diagnostic disable: undefined-global
---↑当たり前だけどLinterがResolveのこと認識してくれないのでしかたなく

--init
CONFIG_FILE_PATH = [[C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Config\VoiceAutoTool_Config\AutoTool_Config.lua]]
OUTPUT_PATH = [[C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Scripts\Comp\VoiceAutoTool\srt]]
CONFIG = dofile(CONFIG_FILE_PATH)

VOICEFOLDER_PATH = CONFIG["VOICEFOLDER_PATH"]
FHT_PATH = CONFIG["FHT_PATH"]
AUDIO_INDEX = CONFIG["AUDIO_INDEX"]

UTF8toSJIS = require("UTF8toSJIS")
FHT = io.open(FHT_PATH , "r")

local function getFrameRate()
  -- 字幕表示の時間計算にフレームレートが必要なので、ちゃんとプロジェクトから持ってきて返す
  resolve = Resolve()
  projectManager = resolve:GetProjectManager()
  proj = projectManager:GetCurrentProject()
  local frame_rate = proj:GetSetting("timelineFrameRate")
  return frame_rate
end

local function ConvertFrameToTime(frame)
  -- フレーム数を時間に変換する
  local frame_rate = getFrameRate() 
  local conma = (frame % frame_rate) * (1000 / frame_rate)
  local second = (frame / frame_rate) % 60
  local min = (frame / frame_rate) / 60 % 60
  local hour = (frame / frame_rate) / 60 / 60 % 60

  -- 00:00:00:000 みたいな感じのを返す
  local ret = string.format("%02d:%02d:%02d,%03d", hour,min,second,conma)
  return ret
end


local function getSubtitleTextFromFolder(soundFileName)
  -- 同じファイル名.txtを読み込んで文字列をもらう
  -- soundFileName: xxx.wav ←こんなかんじの。
  local textFileName = string.format("%s.txt",string.sub(soundFileName, 1, -5))
  local textFilePath = string.format("%s\\%s",VOICEFOLDER_PATH,textFileName)
  --なんかファイルパスに日本語が混ざってると文字コードがどうこうでエラるので、ライブラリの力を使ってどうにかする
  --https://github.com/AoiSaya/FlashAir_UTF8toSJIS          
  local textFilePathConverted = UTF8toSJIS:UTF8_to_SJIS_str_cnv(FHT, textFilePath)
  local filein = io.open(textFilePathConverted, "r")
  
  io.input(filein)
  local text = io.read()

  return text
end

local function ConvertToTextFromClip(number,item)
  -- number: 何番目のアイテムか、いらないと思ってたけど必要って事に気づいて後付け
  -- item: タイムライン上の何番目のサウンドか

  local frameText = ""
  local subtitleText = ""
  local startTime = ConvertFrameToTime(item:GetStart())
  local endTime = ConvertFrameToTime(item:GetEnd())

  frameText = string.format("%s --> %s", startTime,endTime)
  subtitleText = getSubtitleTextFromFolder(item:GetName())
  
  local ret =  string.format("%s\n%s\n%s\n\n", number,frameText,subtitleText)
  return ret
end



local function TimelineToText(project,index)
  -- indx: 字幕化したいAudioタイムラインのindex
  -- return : srtファイルの中身とかそんなレベル

  local timeline = project:GetCurrentTimeline()
  local items = timeline:GetItemsInTrack("audio", index)
  local text = ""

  for i, item in ipairs( items ) do
    text = text .. ConvertToTextFromClip(i, item)
  end

  return text
end

local function CreateSrtFromText(text)
  --return: 出力されたsrtファイルのパス
  print(text)
  local outputFilePath = OUTPUT_PATH .. [[\srt_]] .. os.date("%Y%m%d_%H%M%S") .. ".srt"
  --↑例 srt_20212525010101.srt 
  local f = io.open(outputFilePath, "w")
  f:write(text)
  f:close()
  
  return outputFilePath
end

local function MoveSrt2MediaPool(srtfile)
  --出力されたsrtをメディアプールに持ってくるだけ
  --srtfile: 出力されたsrtファイルのファイル名含めたパス

  --一応RootBinをcurrentFolderにしてるけど、そもそもcurrentFolderの仕様がよくわかってない
  local mediaPool = project:GetMediaPool()
  local rootBin = mediaPool:GetRootFolder()
  mediaPool:SetCurrentFolder(rootBin)

  print(srtfile)
  mediaPool:ImportMedia(srtfile)
end

local function CreateLuaUsecase()

  resolve = Resolve()
  projectManager = resolve:GetProjectManager()
  project = projectManager:GetCurrentProject()

  local srttext = TimelineToText(project,AUDIO_INDEX)

  local srtfile = CreateSrtFromText(srttext)
  MoveSrt2MediaPool(srtfile)

end

CreateLuaUsecase()
