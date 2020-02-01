--[[
新功能开启
]]
requires("src/fsgl/staticdata/GuideStep.lua")

FunctionYinDao = class("FunctionYinDao",function( )
	return cc.Layer:create()
end)
--[[
		FunctionYinDao.funcDatas = {
			blockData = {}, -----以关上开启的新功能数据 
			maxBlock = 0, ---- 在上述关卡当中最的关卡数
			levelData = {}, ----以等级开启的新功能数据 
			maxLevel = 0 -----上述的等级当中最高的等级
		}
]]
FunctionYinDao.funcDatas = nil 
FunctionYinDao.warIsWin = false
FunctionYinDao.isLevelUp = false
function FunctionYinDao:ctor(data,isBuild,callback)
	print("新功能开启所需的数据为：")
	print_r(data)
	self.__functionBoard = nil
	self._newFunctData = data
	self._iconPath = data.pic
	self._canClick = false
	self._callback = callback
	self._guideLayer = nil ---当前的引导层
end

function FunctionYinDao:create(data,isBuild,callback)
	local _guide = FunctionYinDao.new(data,isBuild,callback)
	if _guide then 
		_guide:init()
		_guide:registerScriptHandler(function(event )
			if event == "enter" then 
				_guide:onEnter()
			elseif event == "exit" then 
				_guide:onExit()
			elseif event == "cleanup" then 
				_guide:onCleanup()
			end 
		end)
	end 
	return _guide
end

function FunctionYinDao:showNewFunction(callback)	
	local _block = gameUser.getInstancingId()  -----当前玩家玩到的关卡数	
	local _level = gameUser.getLevel() ----当前玩家的等级
	local parent = cc.Director:getInstance():getRunningScene()
	if parent and FunctionYinDao.funcDatas then  
		local data = nil
		if FunctionYinDao.warIsWin then 
			data = FunctionYinDao.funcDatas.blockData[_block]
		end 
		if FunctionYinDao.isLevelUp then 
			data = FunctionYinDao.funcDatas.levelData[_level]
		end 
		print("is level up ,is new block",FunctionYinDao.isLevelUp,FunctionYinDao.warIsWin)
		if data then 
			local _guide = self:create(data,nil,callback)
			if _guide then 
				parent:addChild(_guide,10)
			end
		end  
	end 
end

function FunctionYinDao:init( )
	local _handLayer,_storyLayer = YinDaoMarg:getInstance():getCurrentGuideLayer()
	self._guideLayer = _handLayer or _storyLayer
	if self._guideLayer then 
		self._guideLayer:setVisible(false)
	end 

	local _color = cc.LayerColor:create(cc.c4b(0,0,0,100),self:getContentSize().width,self:getContentSize().height)
	self:addChild(_color)

	local board = cc.Node:create()	
	self:addChild(board)
	board:setContentSize(cc.size(539,341))
	board:setAnchorPoint(0.5,0.5)
	board:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self.__functionBoard = board
	----特效
	local _spine = sp.SkeletonAnimation:create("res/spine/effect/level_up/xgn.json", "res/spine/effect/level_up/xgn.atlas", 1.0)
	board:addChild(_spine)
	_spine:setPosition(board:getContentSize().width / 2,board:getContentSize().height / 2)
	_spine:setAnimation(0,"1",false)
	performWithDelay(self,function( )
		---前往按钮
	    local _word = LANGUAGE_KEY_SURE  --LANGUAGE_BTN_KEY.qianwang
		if self._guideLayer then  -----正处于引导期
			_word = LANGUAGE_KEY_SURE
		end 
		local _gotoBtn = XTHD.createCommonButton({
			text = _word,
			isScrollView = false,
			btnSize = cc.size(130, 49),	
			fontSize = 22,
		})
		board:addChild(_gotoBtn)
		_gotoBtn:setTouchEndedCallback(function( )
			if self._guideLayer == nil then ----没有引导 
--				if YinDaoMarg:getInstance()._group == 6 then
					YinDaoMarg:getInstance()._isGuiding = false
--				end
				gotoMaincity()
	        	--XTHD.dispatchEvent({name = CUSTOM_EVENT.GOTO_SPECIFIEDBUILDING,data = {funcID = self.__funcID,isBuild = self._isBuild,funcData = self._newFunctData}})
			end 
			self:removeFromParent()
		end)
		_gotoBtn:setScale(0.8)
		_gotoBtn:setPosition(board:getContentSize().width / 2,90)
		_gotoBtn.guiding = false 
				
		---功能图标
		if self._iconPath then 
			local _funcIcon = cc.Sprite:create("res/image/daily_task/"..self._iconPath..".png") 
			if _funcIcon then 
				board:addChild(_funcIcon)
				_funcIcon:setScale(0.7)
				_funcIcon:setPosition(board:getContentSize().width / 2,board:getContentSize().height / 2 + 20)
			end 
		end 
		self._canClick = true		
	end,1.0)
	performWithDelay(self,function ( )
		if _spine then 
			_spine:setAnimation(0,"2",true)
		end 
	end,1.0)
end

function FunctionYinDao:onEnter( )
    local function selfTouchBegan(touch, event)
        return true
    end

    local function selfTouchMoved(touch, event)
    end

    local function selfTouchEnded(touch, event)
    	if not self._canClick then 
    		return 
    	end 
    	local pos = touch:getLocation()                    
    	local _rect = self.__functionBoard:getBoundingBox()
    	if not cc.rectContainsPoint( _rect, pos ) then 
    		self._canClick = false
    	end 
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(selfTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(selfTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(selfTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function FunctionYinDao:onExit( )
	FunctionYinDao.warIsWin = false
	FunctionYinDao.isLevelUp = false
end

function FunctionYinDao:onCleanup( )
	if self._guideLayer then 
		self._guideLayer:setVisible(true)
		self._guideLayer = nil
	end 
end

function FunctionYinDao:formatDatas( ) -----重新组织数据
	if not FunctionYinDao.funcDatas then 
		FunctionYinDao.funcDatas = {
			blockData = {},
			maxBlock = 0, ----
			levelData = {},
			maxLevel = 0
		}	
		for k,v in pairs(GuideStep) do 
			if v.trigger == 2 and v.condition > 0 and v.pic ~= 0 then ----关卡
				FunctionYinDao.funcDatas.blockData[v.condition] = v
				if FunctionYinDao.funcDatas.maxBlock < v.condition then 
					FunctionYinDao.funcDatas.maxBlock = v.condition
				end 
			elseif v.trigger == 1 and v.condition > 0 and v.pic ~= 0 then -----等级
				FunctionYinDao.funcDatas.levelData[v.condition] = v
				if FunctionYinDao.funcDatas.maxLevel < v.condition then 
					FunctionYinDao.funcDatas.maxLevel = v.condition
				end 
			end 
		end 
	end 
end

function FunctionYinDao:reset( )
	FunctionYinDao.funcDatas = nil 
	FunctionYinDao.warIsWin = false
	FunctionYinDao.isLevelUp = false
end