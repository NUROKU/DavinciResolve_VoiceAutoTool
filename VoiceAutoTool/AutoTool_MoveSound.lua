-- 特定フォルダ上の音声をメディアプールにぶちこんでタイムラインに置く
-- 音声メディアを置くBinのことを以下VoiceBinと呼ぶことにした


--init
CONFIG_FILE_PATH = [[C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Config\VoiceAutoTool_Config\AutoTool_Config.lua]]
config = dofile(CONFIG_FILE_PATH)

VOICEFOLDER_PATH = config["VOICEFOLDER_PATH"]
VOICEBIN_NAME = config["VOICEBIN_NAME"]
FHT_PATH = config["FHT_PATH"]
AUDIO_INDEX = config["AUDIO_INDEX"]


local function GotoVBin(mediaPool)
  --CurrentBinをVoiceBinにしたうえでVoiceBinを返す
  rootBin = mediaPool:GetRootFolder()
  folders = rootBin:GetSubFolders()

  voiceBin = ""
  -- voiceBinを探すの、もっといい方法あるとおもんだけどなぁ・・・
  for folderIndex in pairs(folders) do
    folder = folders[folderIndex]
    if folder:GetName() == VOICEBIN_NAME then
      voiceBin = folders[folderIndex]
    end
  end

  if voiceBin == "" then
    voiceBin = mediaPool:AddSubFolder(rootBin, VOICEBIN_NAME)
    print("[Debug]Bin Created")
  end

  mediaPool:SetCurrentFolder(voiceBin)
  return voiceBin
end

local function PullVoiceToVBin(mediaPool)
  -- 特定フォルダ上の音声ファイル群をメディアプールに引っ張ってくる]
  clips = mediaPool:ImportMedia(VOICEFOLDER_PATH)
  -- ここで音声ファイルだけ引っ張る仕様にしようと思ったけど面倒くさくなった、どーせ後でフィルタしてるし
end


local function isSoundRoll(clip)
  --clipが音声ファイルかどうかの確認
  meta = clip:GetMetadata()
  ret = false
  if meta ~= nil then
    for a,b in pairs(meta) do
      --Sound Roll #:	hogehoge.wav
      if a == "Sound Roll #" then
        ret = true
      end
    end
  end

  return ret
end

local function PutVoiceToTimeline(mediaPool)
  --タイムラインにメディアプール上の音声ファイルを置くだけ
  voiceBin = GotoVBin(mediaPool)

  clips = voiceBin:GetClips()

  for clipIndex in pairs(clips) do
    clip = clips[clipIndex]
    if isSoundRoll(clip) then
      mediaPool:AppendToTimeline(clip)
    end
  end
end

local function MoveSoundUsecase()
  print("[Debug]MoveSound_Start-----------")
  resolve = Resolve()
  projectManager = resolve:GetProjectManager()
  project = projectManager:GetCurrentProject() 
  mediaPool = project:GetMediaPool()

  GotoVBin(mediaPool)
  PullVoiceToVBin(mediaPool)
  print("[Debug]Sound pulled from folder")

  rootBin = mediaPool:GetRootFolder()
  PutVoiceToTimeline(mediaPool)
  print("[Debug]Sound put to timeline")
  print("[Debug]MoveSound End---------------")
end

MoveSoundUsecase()


