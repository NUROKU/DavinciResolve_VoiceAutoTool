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

local voiceBinClipsNameStorage = {}
local function isNotExistVoiceInVBin(filePath,mediaPool)
  --VBinに該当のファイルが無かったらTrue(正常みたいな意味合い)を返す
  --filePath: 確認するファイル、絶対パスで来る想定
  
  --1回目の処理でvoiceBinClipsNameStorageにvoiceBinに入ってるクリップ全部の名前をぶちこむ
  if #voiceBinClipsNameStorage == 0 then
    print("hoge")
    voiceBin = GotoVBin(mediaPool)
    voiceBinClips = voiceBin:GetClipList()
    for voiceBinindex in pairs(voiceBinClips) do
      if type(voiceBinClips[voiceBinindex]) == "userdata" then
        voiceBinClipsNameStorage[#voiceBinClipsNameStorage+1] = voiceBinClips[voiceBinindex]:GetName()
      end
    end
    if #voiceBinClipsNameStorage == 0 then
      return true
    end
  end

  local voiceBinClipNames = voiceBinClipsNameStorage


  for Nameindex in ipairs(voiceBinClipNames) do
    local voiceBinClipPath = string.format("%s\\%s",VOICEFOLDER_PATH,voiceBinClipNames[Nameindex])
    if voiceBinClipPath == filePath then
      return false
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

    --.wavのみ持ってくるようフィルタ、Luaだとfor文のcontinueが無いのでgotoで代用
    local isSoundFile = string.sub(fileList[i], -4) == ".wav"
    if isSoundFile == false then
      goto continue
    end

    --既に存在してるファイルをimportしない処理
    local isAlreadyExist = isNotExistVoiceInVBin(fileList[i],mediaPool)
    if isAlreadyExist then
      local filetable = mediaPool:ImportMedia(fileList[i])

      --Luaはテーブルの添え字が1から始まるらしい、きにくわない
      local addingFile = filetable[1]
      table.insert(clips, addingFile)
    end
    ::continue::
  end
  print("Voice ",#clips,"file Pulled")
  return clips
end

local function PutVoiceToTimeline(project, mediaPool,clips)
  --タイムラインにメディアプール上の音声ファイルを置くだけ

  --タイムラインが無い時には新たに作成しておく
  if project:GetCurrentTimeline() == nil then
    print("Create Empty Timeline")
    mediaPool:CreateEmptyTimeline("Timeline_1")
  end
  -- CreateEmptyTimeline("Timeline_1")
  

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
  PutVoiceToTimeline(project,mediaPool,clips)
  print("[Debug]MoveSound End---------------")
end

MoveSoundUsecase()