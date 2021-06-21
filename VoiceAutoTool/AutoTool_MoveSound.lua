-- 特定フォルダ上の音声をメディアプールにぶちこんでタイムラインに置く
-- 音声メディアを置くBinのことを以下VoiceBinと呼ぶことにした

---@diagnostic disable: undefined-global
---↑当たり前だけどLinterがResolveのこと認識してくれないのでしかたなく

--init
CONFIG_FILE_PATH = [[C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Config\VoiceAutoTool_Config\AutoTool_Config.lua]]
CONFIG = dofile(CONFIG_FILE_PATH)

VOICEFOLDER_PATH = CONFIG["VOICEFOLDER_PATH"]
VOICEBIN_NAME = CONFIG["VOICEBIN_NAME"]
FHT_PATH = CONFIG["FHT_PATH"]
AUDIO_INDEX = CONFIG["AUDIO_INDEX"]


local function GotoVBin(mediaPool)
  --CurrentBinをVoiceBinにしたうえでVoiceBinを返す
  local rootBin = mediaPool:GetRootFolder()
  local folders = rootBin:GetSubFolders()

  local voiceBin = ""
  -- voiceBinを探すの、もっといい方法あるとおもんだけどなぁ・・・
  for folderIndex in pairs(folders) do
    local folder = folders[folderIndex]
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
  local clips = mediaPool:ImportMedia(VOICEFOLDER_PATH)
  -- ここで音声ファイルだけ引っ張る仕様にしようと思ったけど面倒くさくなった、どーせ後でフィルタしてるし
end


local function isSoundRoll(clip)
  --clipが音声ファイルかどうかの確認
  local meta = clip:GetMetadata()
  local ret = false
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
  local voiceBin = GotoVBin(mediaPool)

  local clips = voiceBin:GetClips()

  for clipIndex in pairs(clips) do
    local clip = clips[clipIndex]
    if isSoundRoll(clip) then
      mediaPool:AppendToTimeline(clip)
    end
  end
end

local function MoveSoundUsecase()
  print("[Debug]MoveSound_Start-----------")
  local resolve = Resolve()
  local projectManager = resolve:GetProjectManager()
  local project = projectManager:GetCurrentProject() 
  local mediaPool = project:GetMediaPool()

  GotoVBin(mediaPool)
  PullVoiceToVBin(mediaPool)
  print("[Debug]Sound pulled from folder")

  local rootBin = mediaPool:GetRootFolder()
  PutVoiceToTimeline(mediaPool)
  print("[Debug]Sound put to timeline")
  print("[Debug]MoveSound End---------------")
end

MoveSoundUsecase()


