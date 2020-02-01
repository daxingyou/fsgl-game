-- FileName: YinDaoCGLayer.lua
-- Author: wangming
-- Date: 2015-08-27
-- Purpose: 新手CG播放类
--[[TODO List]]
local YinDaoCGLayer = class("YinDaoCGLayer", function()
    local obj = cc.Layer:create()
	obj:setTouchEnabled(true)
	local function scriptHandler( tag )
		if tag == "enter" then
            obj:onEnter()
        elseif tag == "cleanup" then
        	obj:onCleanup()
        end
    end
    obj:registerScriptHandler(scriptHandler)
	return obj
end)

function YinDaoCGLayer:onEnter()
	musicManager.PauseBackgroundMusic()
	self:setTouchEnabled(true)
	local _size = self:getContentSize()
	self:registerScriptTouchHandler(function ( eventType, x, y )
		local pPos = cc.p(x,y)
		if x < 0 or x > _size.width then
			return false
		end
		if y < 0 or y > _size.height then
			return false
		end
		if eventType == "began" then
			return true
		elseif eventType == "ended" then 
			if not self._params.callBack then
				self:updateServer()	
			end
		end
	end)
end

function YinDaoCGLayer:onCleanup()
	self:removeAllChildren()
	musicManager.resumBackgroundMusic()
end

function YinDaoCGLayer:createVideoPlayer( ... )
	if self._videoPlayer then
		self._videoPlayer:removeFromParent()
		self._videoPlayer = nil
	end

	local videoPlayer = ccexp.VideoPlayer:create()
	local _size = self:getContentSize()
    self._isPlayed = false
    self._isPause = false
    if videoPlayer then
        videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
        videoPlayer:setPosition(cc.p(_size.width * 0.5, _size.height * 0.5))
		videoPlayer:setContentSize(_size)
        videoPlayer:setFullScreenEnabled(true)
        videoPlayer:setKeepAspectRatioEnabled(true)
        videoPlayer:setFileName(self._videoFilePath)
        videoPlayer:play()
        self._videoPlayer = videoPlayer
        self:addChild(videoPlayer)

        local function onVideoEventCallback(sener, eventType)
            if eventType == ccexp.VideoPlayerEvent.PLAYING then
            	self._isPlayed = true
            	self._isPause = false
            elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
            	self._isPlayed = false
            	self._isPause = true
            elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
            	-- if cc.PLATFORM_OS_ANDROID == ZC_targetPlatform and self._videoPlayer.preparedRestart then
            	-- 	-- self:createVideoPlayer()
            	-- 	self:updateServer()
            	-- elseif cc.PLATFORM_OS_ANDROID ~= ZC_targetPlatform then
            	-- 	self:updateServer()
	            -- end
	            self:updateServer()
            elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
            	-- if cc.PLATFORM_OS_ANDROID ~= ZC_targetPlatform then
            	-- 	self._videoPlayer = nil
            	-- end
        		self:updateServer()
            end
        end
        videoPlayer:addEventListener(onVideoEventCallback)
    end
    return videoPlayer
end

function YinDaoCGLayer:init( sParams )
	self._isGo = false
	self._params = sParams or {}
	self._videoFilePath = self._params.file or "res/spine/camp/cg.mp4" 
	local _size = self:getContentSize()

	local _fileExist = cc.FileUtils:getInstance():isFileExist(self._videoFilePath)
	if _fileExist and ccexp.VideoPlayer then
	 	self:createVideoPlayer()
	 	
	 	if self._videoPlayer.preparedRestart then
	     --    local skip = XTHDLabel:createWithParams({
		    --     text = "跳过",
		    --     fontSize = 32,
		    --     touchSize = cc.size(100, 50),
		    --     endCallback = function()--触摸事件的回调函数
		    --     	self:updateServer()
		    --     end
		    -- })
		    -- self:addChild(skip)
		    -- skip:setPosition(_size.width - skip:getContentSize().width - 5, _size.height - skip:getContentSize().height - 15)
		end

	    local function update( dt )
	    	if not self._videoPlayer or self._isGo  then
	    		return
	    	end
	    	if cc.PLATFORM_OS_ANDROID == ZC_targetPlatform then
	    		if self._isPlayed then
	    			if self._videoPlayer.preparedRestart then
		    			self._videoPlayer:preparedRestart()
		    		else
		    			self._videoPlayer:play()
		    		end
	    			return
	    		end
	    	end
	    	if not self._videoPlayer:isPlaying() and self._isPause then
    			self._videoPlayer:resume()
    			return
    		end   		
	    end
		self:scheduleUpdateWithPriorityLua(update, 0)
    else
    	performWithDelay(self, function()
	    	self:updateServer()
	    end, 0.01)
    end
end

function YinDaoCGLayer:updateServer( ... )
	if self._isGo then
		return
	end
	self._isGo = true
	self:unscheduleUpdate()
	if self._videoPlayer and self._videoPlayer:isPlaying() then
		self._videoPlayer:pause()
	end
	if self._params.callBack then
		-- cc.Director:getInstance():popScene()
		performWithDelay(self, function ( ... )
			self._params.callBack()
			self:removeFromParent()
		end, 0.01)
	else
		local UpdateLayer = requires("src/fsgl/GameLoadingLayer.lua")
	    local scene = cc.Scene:create()
	    scene:addChild(UpdateLayer:create())
	    cc.Director:getInstance():replaceScene(scene)  
	end
end

function YinDaoCGLayer:create( sParams )
	local layer = self.new()
	layer:init(sParams)
    layer:setOpacity(0)
	return layer
end

return YinDaoCGLayer