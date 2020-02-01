--requires "AudioEngine"
musicManager = musicManager or {}

musicManager._lastMusicPath = nil

musicManager._isMusicEnable = cc.UserDefault:getInstance():getBoolForKey(KEY_NAME_MUSIC_ENABLE,true)
musicManager._isEffectEnable= cc.UserDefault:getInstance():getBoolForKey(KEY_NAME_EFFECT_ENABLE,true)--by.huangjunjian控制全局音效

--音乐管理类内部使用，使用者只需要关注musicManager对象即可
musicManager._sharedEngine = cc.SimpleAudioEngine:getInstance()

musicManager._currentBackMusic = nil
musicManager._preBackMusic = nil 

function musicManager.playSound(filename, isLoop)
    musicManager._sharedEngine:playEffect(filename, isLoop)
end

--设置音量
function musicManager.setVolume(value)
    musicManager._sharedEngine:setMusicVolume(value)
end
--获取音量
function musicManager.getVolume()
    return musicManager._sharedEngine:getMusicVolume()
end

function musicManager.playBackgroundMusic(fileName,isLoop)
	musicManager.playMusic(fileName,isLoop)
end


function musicManager.playMusic(fileName,isLoop)
    if isLoop == nil then
        isLoop = false
    end
    -- --如果音乐是开启，此处判断要严谨
    if musicManager.isMusicEnable() == true then
        if fileName and string.len(fileName) > 0 and cc.FileUtils:getInstance():isFileExist(fileName) == true then
            if musicManager._lastMusicPath and musicManager._lastMusicPath == fileName then
                musicManager._sharedEngine:resumeMusic()
            else
                musicManager._sharedEngine:playMusic(fileName,isLoop)
                musicManager._lastMusicPath = fileName
            end
        end
    else
        
    end
end


----通用按钮音效
function musicManager.playCommon(_type)
    local _path = XTHD.resource.music.effect_btn_common
    if _type == XTHD.SoundEnum.kSound_closePop then 
        _path = XTHD.resource.music.effect_close_pop
    elseif _type == XTHD.SoundEnum.kSound_closeCommon then 
        _path = XTHD.resource.music.effect_btn_commonclose
    end 
    musicManager.playEffect(_path,false)
end

---通用返回按钮音效
function musicManager.commonBackBtn( )
    local  _path = ""
    musicManager.playEffect(_path,false)
end

function musicManager.preloadAllEffect()
    local effects = {
        [1] = "res/sound_battle_victory_1.wav"
    }

    for i=1,#effects do
        musicManager._sharedEngine:preloadEffect(effects[i])
    end

end

--关闭背景音乐
function musicManager.stopBackgroundMusic()
    musicManager.stopMusic()
end

--暂停背景音乐
function musicManager.PauseBackgroundMusic()
    musicManager._sharedEngine:pauseMusic()
end

function musicManager.resumBackgroundMusic( )
    musicManager._sharedEngine:resumeMusic()
end


--音乐是否正在播放
function musicManager.isMusicPlaying()
	return (musicManager._isMusicEnable == true)
end

--@@@@@@@@@@@@@-------音效begin-----@@@@@@@@@@@@@@@@@--
function musicManager.playEffect(pszFilePath,bLoop)

    local _soundId = 0
    --pitch = 1.0f, float pan = 0.0f, float gain = 1.0f
    if  musicManager.isEffectEnable() and pszFilePath and string.len(tostring(pszFilePath)) > 0 then
        if bLoop == nil then
            bLoop = false
        end
        if cc.FileUtils:getInstance():isFileExist(pszFilePath) == true then
            _soundId = musicManager._sharedEngine:playEffect(pszFilePath,bLoop)
        end
    end
    return _soundId
end

function musicManager.preloadEffect(fileName)
    musicManager._sharedEngine:preloadEffect(fileName)
end

function musicManager.stopEffect(int_value)
    musicManager._sharedEngine:stopEffect(int_value)
end

function musicManager.setEffectVolume(volume)
    musicManager._sharedEngine:setEffectsVolume(volume)
end

function musicManager.stopAllEffects()
    musicManager._sharedEngine:stopAllEffects()
end
function musicManager.setMusicEnable(enable,music)--[[type传值在战斗中开启音乐播放战斗bg而不是主城by.huangjunjian]]
    musicManager._isMusicEnable = enable
     cc.UserDefault:getInstance():setBoolForKey(KEY_NAME_MUSIC_ENABLE,enable)
    if enable == true then
		if music == nil then
			musicManager.playMusic(XTHD.resource.music.music_bgm_main,true)
		else
			musicManager.playMusic(music,true)
		end
    else
         musicManager.stopMusic()
    end
    cc.UserDefault:getInstance():flush()
    --最好执行这行代码
    
end

function musicManager.isMusicEnable()
    return musicManager._isMusicEnable
end

function musicManager.setEffectEnable(enable)--设置中调用决定音效开启关不by。huangjunjian
    musicManager._isEffectEnable = enable
     cc.UserDefault:getInstance():setBoolForKey(KEY_NAME_EFFECT_ENABLE,enable)
    --最好执行这行代码
    cc.UserDefault:getInstance():flush()

end

function musicManager.isEffectEnable()
    return musicManager._isEffectEnable
end

function musicManager.stopMusic()
    musicManager._sharedEngine:stopMusic(false)
    musicManager._lastMusicPath = nil
end

function musicManager.switchBackMusic( what )------切换背景音乐
    if not musicManager._currentBackMusic then 
        musicManager._currentBackMusic = what
    end 
    musicManager.playBackgroundMusic(musicManager._currentBackMusic,true)
end

function musicManager.setBackMusic( what )
    musicManager._preBackMusic = musicManager._currentBackMusic    
    musicManager._currentBackMusic = what
end

function musicManager.playerPreBackMusic( )
    if musicManager._preBackMusic then 
        musicManager.playBackgroundMusic(musicManager._preBackMusic,true)    
    end 
end

function musicManager.reset( )
    musicManager._currentBackMusic = nil    
end
--cc.SimpleAudioEngine:getInstance():stopEffect(int)
--cc.SimpleAudioEngine:getInstance():stopAllEffects()
--cc.SimpleAudioEngine:getInstance():pauseEffect(int)
--cc.SimpleAudioEngine:getInstance():getEffectsVolume()
--cc.SimpleAudioEngine:getInstance():resumeEffect(int)
--cc.SimpleAudioEngine:getInstance():resumeAllEffects()
--cc.SimpleAudioEngine:getInstance():unloadEffect(pszFilePath)

--@@@@@@@@@@@@@-------音效end-----@@@@@@@@@@@@@@@@@--


