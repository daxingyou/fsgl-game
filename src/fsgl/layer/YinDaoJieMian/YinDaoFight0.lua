
local YinDaoFight0 = class("YinDaoFight0", function(params)
    return XTHDDialog:create(255)
end)

function YinDaoFight0:onCleanup( )
 	local textureCache = cc.Director:getInstance():getTextureCache()
 	for k,v in pairs(self._picTb) do
		textureCache:removeTextureForKey("res/image/story/" .. tostring(v.pic) .. ".jpg")
 	end
end

function YinDaoFight0:ctor(params)
	self._curIndex = 1
	self._picTb = {
		{pic = "3", time = 10.5, text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_1, sound = "guide_1"},
		{pic = "yindao1-1", time = 11.5, text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_2, sound = "guide_2"},
		{pic = "5", time = 6.5, text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_3, sound = "guide_3"},
		{pic = "yindao1-5", time = 11.5, text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_4, sound = "guide_4"},
		{pic = "1", time = 11.5, text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_5, sound = "guide_5"},
	}
	local winWidth  = self:getContentSize().width
	local winHeight = self:getContentSize().height

	local btn_battle
	local function _goEnd()
		if btn_battle then
            btn_battle:setClickable(false)
        end
        musicManager.stopAllEffects()
        musicManager.stopMusic()

        local scene = cc.Scene:create()
        cc.Director:getInstance():replaceScene(scene)

		local layer = XTHD.createCampRegisterLayer(scene, function(data)
			local pLay = XTHD.createSelectHeroLayer(scene, function()
		        LayerManager.pushModule( nil, true, {guide = true})
			    replaceLayer({id = 1, parent = LayerManager.getBaseLayer()})
			end)
	        scene:addChild(pLay, 1)
        end)
        -- scene:addChild(layer)

  --       local pLay = XTHDDialog:create(255)
  --       scene:addChild(pLay, 1)     
  --       local labTxt =  XTHD.createLabel({color = cc.c3b(255,255,255) , fontSize = 30}) 
		-- labTxt:setDimensions(800,150)
		-- labTxt:setAnchorPoint(cc.p(0.5,0.5))
		-- labTxt:setPosition(winWidth / 2 , winHeight / 2)
		-- labTxt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		-- labTxt:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		-- labTxt:setOpacity(0)
		-- labTxt:setString("请选择您的种族")
		-- pLay:addChild(labTxt)
		-- labTxt:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.FadeIn:create(3.0),cc.FadeOut:create(2.0),cc.CallFunc:create(function( ... )
		-- 	pLay:removeFromParent()
		-- end)))
	end

    btn_battle = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		fontSize = 26,
        text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_28,
        endCallback = _goEnd
	})
	btn_battle:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
	btn_battle:setScale(0.7)
    btn_battle:setPosition(cc.p(winWidth - 60, winHeight - 30))
    self:addChild(btn_battle, 10)

	local _fadeTime = 3.0
	local function showSelf()
		local _centerLayer = XTHDDialog:create()
		_centerLayer:setCascadeOpacityEnabled(true)
		_centerLayer:setOpacity(0)
		local winSize = cc.Director:getInstance():getWinSize()
		self:addChild(_centerLayer)
		local _file = self._picTb[self._curIndex].pic
		local _time = self._picTb[self._curIndex].time
		local _text = self._picTb[self._curIndex].text
		local _sound = self._picTb[self._curIndex].sound

		local bg = XTHD.createSprite("res/image/story/" .. tostring(_file) .. ".jpg")
		bg:setPosition(winWidth*0.5 , winHeight*0.5)
		bg:setContentSize(winSize)
		_centerLayer:addChild(bg)

		local text_bg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
		text_bg:setContentSize(cc.size(winWidth, 150))
		_centerLayer:addChild(text_bg)

		local labTxt =  XTHD.createRichLabel({color = cc.c3b(255, 255, 255) , fontSize = 30}) 
		labTxt:setDimensions(cc.size(800, 150))
		labTxt:setAnchorPoint(cc.p(0.5, 0))
		labTxt:setPosition(winWidth*0.5 , 0)
		labTxt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		labTxt:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		labTxt:setString(_text)
		_centerLayer:addChild( labTxt )

		local function gotoNext( ... )
			if self._soundEffId then
				musicManager.stopEffect(self._soundEffId)
				self._soundEffId = nil
			end
			self._curIndex = self._curIndex + 1
			_centerLayer:setOpacity(255)
			_centerLayer:runAction(cc.Sequence:create(
				cc.FadeOut:create(_fadeTime),
				cc.CallFunc:create(function()
					_centerLayer:removeFromParent()
					if self._curIndex <= #self._picTb then
						showSelf()
					else
						_goEnd()
					end
				end)
			))
		end

		-- self._soundEffId = musicManager.playEffect("res/sound/guide/" .. _sound .. ".mp3")
		_centerLayer:runAction(cc.Sequence:create(
			cc.FadeIn:create(_fadeTime),
			cc.CallFunc:create(function()
				_centerLayer:setTouchEndedCallback(function() 
					_centerLayer:setClickable(false)
					gotoNext()
				end)
			end),
			cc.DelayTime:create(_time - _fadeTime),
			cc.CallFunc:create(function()
				gotoNext()
			end)
		))
	end
	showSelf()
end

function YinDaoFight0:create(params)
	return YinDaoFight0.new(params)
end

return YinDaoFight0