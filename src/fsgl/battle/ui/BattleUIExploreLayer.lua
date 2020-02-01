
BattleUIExploreLayer = class("BattleUIExploreLayer", function(tab)
    return XTHD.createLayer()
end)

function BattleUIExploreLayer:onCleanup()
    musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_main,true)
end

function BattleUIExploreLayer:ctor(_battleType, _isShowAuto)
	local handle = function ( event )
        if event == "cleanup" then
            self:onCleanup()
        end
    end
    self:registerScriptHandler(handle)
    
	-- local winWidth  = self:getContentSize().width
	-- local height  	= self:getContentSize().height
	-- -- 自动战斗
	-- local function _callBack( ... )
	-- 	if self._buildPointer then
	-- 		self._buildPointer:removeFromParent()
	-- 		self._buildPointer = false
	-- 	end
	-- end
	-- local _showAuto = _isShowAuto == nil and true or _isShowAuto
	-- if _showAuto then
	-- 	local btnAuto = createAutoButton(_battleType, _callBack)--XTHDSprite:create("res/image/tmpbattle/autocombat_off.png")
	-- 	btnAuto:setPosition(cc.p(115, height - btnAuto:getContentSize().height / 2))
	-- 	self:addChild(btnAuto)	

	-- 	if _battleType ~= BattleType.MULTICOPY_FIGHT then
	-- 		-- 暂停
	-- 		local btnPause = XTHDPushButton:createWithParams({
	-- 			normalNode = cc.Sprite:create("res/image/tmpbattle/pausebtn.png"),
	-- 			selectedNode = cc.Sprite:create("res/image/tmpbattle/pausebtn-disabled.png"),
	-- 			needSwallow = true,
	-- 			enable = true,
	-- 		})
			
	-- 		-- btnPause:setAnchorPoint(1,0.5)
	-- 		btnPause:setPosition(cc.p(40, height - btnPause:getContentSize().height/2))
	-- 		self:addChild(btnPause)

	-- 		btnPause:setTouchEndedCallback(function( )
	-- 			XTHD.dispatchEvent({
	-- 				name = EVENT_NAME_BATTLE_PAUSE,
	-- 			})
	-- 			self:addChild(BattleUIPauseLayer:create())
	-- 		end)
			
	-- 		------------added by litao 
	-- 		if gameUser.getLevel() < BATTLE_SPPEDX2_LIMIT then 
	-- 			btnPause:setVisible(false)
	-- 		else 
	-- 			btnPause:setVisible(true)
	-- 		end 
	-- 	end
	-- end
	----------
	-- XTHD.addEventListener({ name = EVENT_NAME_BATTLE_ADD_GUIDE , callback = function(event)
	-- 	if self._buildPointer == nil then
	-- 		local _isAuto = getAutoState(BattleType.PVE)
	-- 		if _isAuto == true then
	-- 			self._buildPointer = false
	-- 			return
	-- 		end
 --            self._buildPointer = YinDao:create({
 --                target = btnAuto,
 --                noTouchEvent = true,
 --                direction = 2,
 --                action = 1,
 --                isButton = false,
 --                hasMask = false,
 --                wordTips = LANGUAGE_TIPS_WORDS231,
 --                pos = cc.p(200, -200)
 --            })
 --        	self:addChild(self._buildPointer)
	-- 		performWithDelay(self._buildPointer, function ( ... )
	-- 			self._buildPointer:removeFromParent()
	-- 			self._buildPointer = false
	-- 		end, 7)
	-- 	end
 --    end})  
	-- local handle = function ( event )
 --        if event == "cleanup" then
 --        	XTHD.removeEventListener(EVENT_NAME_BATTLE_ADD_GUIDE)
 --        end
 --    end
 --    self:registerScriptHandler(handle)
end

function BattleUIExploreLayer:create( _battleType, _isShowAuto )
    return BattleUIExploreLayer.new(_battleType, _isShowAuto)
end