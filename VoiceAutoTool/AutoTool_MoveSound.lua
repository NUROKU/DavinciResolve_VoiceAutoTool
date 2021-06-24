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
  return clips
end


local function isSoundRoll(clip)
  --clipが音声ファイルかどうかの確認
  if type(clip) ~= "userdata" then 
    return false
  end

  local ret = false
  local meta = clip:GetMetadata()
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

local function FilterClipsForPuttingTimeline(clips)
  --clipsとvoiceBin配下のclipを比較して追加分だけ返すみたいなやつ
  --ついでに音声ファイルかどうかのフィルタもやってる。

  if #clips == 0 then
    return nil
  end

  --テーブルを比較できる標準ライブラリが欲しかったんだけど見当たらなかったから泥臭いことするよ
  local voiceBin = GotoVBin(mediaPool)
  local voiceBinClips = voiceBin:GetClipList()
  
  for index in pairs(clips) do
    local clip = clips[index]
    if isSoundRoll(clip) == false then
      break
    end

    for voiceBinindex in pairs(voiceBinClips) do
      local voiceBinClip = voiceBinClips[voiceBinindex]
      if clip:GetName() == voiceBinClip:GetName() then
        table.remove(clips,index)
        break
      end
    end
  end

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
    if isSoundRoll(clip) then
      print("Put Sound : ",clip:GetName())
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
  local clips = PullVoiceToVBin(mediaPool)
  print("[Debug]Sound pulled from folder")

  local filteredclips = FilterClipsForPuttingTimeline(clips)
  print("[Debug]Sound put to timeline")
  PutVoiceToTimeline(mediaPool,filteredclips)

  print("[Debug]MoveSound End---------------")
end

MoveSoundUsecase()


