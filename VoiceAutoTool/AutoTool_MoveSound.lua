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

UTF8toSJIS = require("UTF8toSJIS")
FHT = io.open(FHT_PATH , "r")


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


local function isNotExistVoiceInVBin(filePath,mediaPool)
  --VBinに該当のファイルが無かったらTrue(正常みたいな意味合い)を返す
  --filePath: 確認するファイル、絶対パスで来る想定

  voiceBin = GotoVBin(mediaPool)
  local voiceBinClips = voiceBin:GetClipList()
  if #voiceBinClips == 0 then
    return true
  end

  for voiceBinindex in pairs(voiceBinClips) do
    local voiceBinClip = voiceBinClips[voiceBinindex]
    if type(voiceBinClip) ~= "userdata" then 
      --なにか
    else
      local voiceBinClipPath = string.format("%s\\%s",VOICEFOLDER_PATH,voiceBinClip:GetName())

      if voiceBinClipPath == filePath then
        return false
      end
    end
  end

  return true
end


local function PullVoiceToVBin(mediaStorage,mediaPool)
  -- 特定フォルダ上の音声ファイル群をメディアプールに引っ張ってくる

  -- ただし、VoiceBinにあるものは持ってない
  -- MediaStoregeのGetFileList(folderPath)で一覧もってくる
  local fileList = mediaStorage:GetFileList(VOICEFOLDER_PATH)
  local clips = {}
  for i = 1, #fileList do

    --ここで音声フィルタと既に存在してるファイルを取得しない処理
    local isSoundFile = string.sub(fileList[i], -4) == ".wav"
    local isAlreadyExist = isNotExistVoiceInVBin(fileList[i],mediaPool)

    if isSoundFile and isAlreadyExist then
      local filetable = mediaPool:ImportMedia(fileList[i])

      --Luaはテーブルの添え字が1から始まるらしい、きにくわない
      local addingFile = filetable[1]
      table.insert(clips, addingFile)
    end
  end

  print("Voice ",#clips,"file Pulled")
  return clips
end



local function PutVoiceToTimeline(mediaPool,clips)
  --タイムラインにメディアプール上の音声ファイルを置くだけ
  if clips == nil then
    print("No Sound to Put Timeline !!!!!!!!!!")
    return 0
  end

  for clipIndex in pairs(clips) do
    local clip = clips[clipIndex]
    print("Put Sound : ",clip:GetName())
    mediaPool:AppendToTimeline(clip)
  end

end

local function MoveSoundUsecase()
  print("[Debug]MoveSound_Start-------------")
  resolve = Resolve()
  projectManager = resolve:GetProjectManager()
  project = projectManager:GetCurrentProject() 
  mediaPool = project:GetMediaPool()
  mediaStorage = resolve:GetMediaStorage()

  GotoVBin(mediaPool)
  local clips = PullVoiceToVBin(mediaStorage,mediaPool)
  print("[Debug]Sound pulled from folder")

  --local filteredclips = FilterClipsForPuttingTimeline(clips)
  print("[Debug]Sound put to timeline")
  PutVoiceToTimeline(mediaPool,clips)

  print("[Debug]MoveSound End---------------")
end

MoveSoundUsecase()


