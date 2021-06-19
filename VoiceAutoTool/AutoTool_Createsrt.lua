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

--init
CONFIG_FILE_PATH = [[C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Config\VoiceAutoTool_Config\AutoTool_Config.lua]]
OUTPUT_PATH = [[C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Scripts\Comp\VoiceAutoTool\srt]]
config = dofile(CONFIG_FILE_PATH)

VOICEFOLDER_PATH = config["VOICEFOLDER_PATH"]
FHT_PATH = config["FHT_PATH"]
AUDIO_INDEX = config["AUDIO_INDEX"]

UTF8toSJIS = require("UTF8toSJIS")
fht = io.open(FHT_PATH , "r")

-- 字幕表示の時間計算にフレームレートが必要なのでここで計算しちゃう
resolve = Resolve()
projectManager = resolve:GetProjectManager()
proj = projectManager:GetCurrentProject()
FRAME_RATE = proj:GetSetting("timelineFrameRate")
BASE_FRAME = FRAME_RATE * 2880


local function ConvertFrameToTime(frame)
  --何故かDavinciResolveはデフォで1分足されてるので字幕ファイル用に1分引いてる、関数名詐欺じゃん・・・
  
  conma = (frame % FRAME_RATE) * (1000 / FRAME_RATE)
  second = (frame / FRAME_RATE) % 60
  min = (frame / FRAME_RATE) / 60 % 60
  hour = (frame / FRAME_RATE) / 60 / 60 % 60

  -- 00:00:00:000
  ret = string.format("%02d:%02d:%02d,%03d", hour,min,second,conma)
  return ret
end


local function getSubtitleTextFromFolder(soundFileName)
  -- 同じファイル名.txtを読み込んで文字列をもらう
  -- soundFileName: xxx.wav ←こんなかんじの。
  textFileName = string.format("%s.txt",string.sub(soundFileName, 1, -5))
  textFilePath = string.format("%s\\%s",VOICEFOLDER_PATH,textFileName)
  --なんかファイルパスに日本語が混ざってると文字コードがどうこうでエラるので、ライブラリの力を使ってどうにかする
  --https://github.com/AoiSaya/FlashAir_UTF8toSJIS          

  textFilePathConverted = UTF8toSJIS:UTF8_to_SJIS_str_cnv(fht, textFilePath)

  filein,err  = io.open(textFilePathConverted, "r")
  
  io.input(filein)
  text = io.read()

  return text

end

local function ConvertToTextFromClip(number,item)
  -- number: 何番目のアイテムか、いらないと思ってたけど必要って事に気づいて後付け
  -- item: タイムライン上の音 
  frameText = ""
  subtitleText = ""

  startTime = ConvertFrameToTime(item:GetStart())
  endTime = ConvertFrameToTime(item:GetEnd())
  frameText = string.format("%s --> %s", startTime,endTime)

  subtitleText = getSubtitleTextFromFolder(item:GetName())
  
  ret =  string.format("%s\n%s\n%s\n\n", number,frameText,subtitleText)
  return ret
end



local function TimelineToText(project,index)
  -- indx: 字幕化したいAudioタイムラインのindex
  -- return : srtファイルの中身とかそんなレベル

  timeline = project:GetCurrentTimeline()
  items = timeline:GetItemsInTrack("audio", index)
  text = ""
  for i, item in ipairs( items ) do
    text = text .. ConvertToTextFromClip(i, item)
  end

  return text
end

local function CreateSrtFromText(text)
  --return: 出力されたsrtファイルのパス
  print(text)
  outputFilePath = OUTPUT_PATH .. [[\srt_]] .. os.date("%Y%m%d_%H%M%S") .. ".srt"
  --↑例 srt_20212525010101.srt 
  f = io.open(outputFilePath, "w")
  f:write(text)
  f:close()
  
  return outputFilePath
end

local function MoveSrt2MediaPool(srtfile)
  --出力されたsrtをメディアプールに持ってくるだけ
  --srtfile: 出力されたsrtファイルのファイル名含めたパス
  mediaPool = project:GetMediaPool()
  rootBin = mediaPool:GetRootFolder()
  mediaPool:SetCurrentFolder(rootBin)
  print(srtfile)
  clips = mediaPool:ImportMedia(srtfile)
end

local function CreateLuaUsecase()

  resolve = Resolve()
  projectManager = resolve:GetProjectManager()
  project = projectManager:GetCurrentProject()

  srttext = TimelineToText(project,AUDIO_INDEX)

  srtfile = CreateSrtFromText(srttext)
  MoveSrt2MediaPool(srtfile)

end

CreateLuaUsecase()
