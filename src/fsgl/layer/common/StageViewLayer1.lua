-- FileName: StageViewLayer1.lua
-- Author: wangming
-- Date: 2015-12-23
-- Purpose: 封装副本滚动类
--[[TODO List]]

local StageViewLayer1 = class("StageViewLayer1",function()
	local obj = cc.Layer:create()
	obj:setTouchEnabled(true)
	local function scriptHandler( tag )
		if tag == "enter" then
            -- obj:onEnter()
        elseif tag == "exit" then
            -- obj:onExit()
        elseif tag == "cleanup" then
        	obj:onCleanup()
        end
    end
    obj:registerScriptHandler(scriptHandler)
	return obj
end)

function StageViewLayer1:create( sStarPage )
	local obj = StageViewLayer1.new( sStarPage )
    return obj
end

function StageViewLayer1:onCleanup()
	for i=1, #self._bgList do
		_cengGroup = self._bgList[i]
		for j=1, #_cengGroup do
			_bgNode = _cengGroup[j]
			if _bgNode:isVisible() then
				local _texture = _bgNode:getTexture()
				_bgNode:setTexture(nil)
				_bgNode:setVisible(false)
				cc.Director:getInstance():getTextureCache():removeTexture(_texture)
			end
			local _pic = _bgNode:getChildByTag(1024)
			if _pic then
				_pic:removeFromParent()
			end
		end
	end
end

function StageViewLayer1:ctor( sStarPage )
	self._resource = "res/image/plugin/stageChapter/newBg/"
	self._bgStringInfo = {self._resource .. "a",0,"_",0,".png"}
	self._guangPoints = {
		{0, 0},
		{0, 0},
		{0, 0},
		{0, 0},
		{0, 0},
		{0, 0},
		{0, 0},
		{400, 280},
		{0, 0},
	}
	self._totleIndex = 25
	self._totleIndex2 = 8
	self._diffCeng = 4
	self._moveTime = 1
	self._isChanging = false
	self._curIndex = tonumber(sStarPage) or 1
	self._curIndex = self._curIndex > self._totleIndex and self._totleIndex or self._curIndex
	self._curIndex = self._curIndex < 1 and 1 or self._curIndex

	self._bgList = {}

	local _size = self:getContentSize()
	self._bgNode = cc.Node:create()
	self._bgNode:setPosition(_size.width*0.5,_size.height*0.5)
	local size_ = cc.size(1024,615)	
	local scale_X = _size.width / size_.width
	local scale_Y = _size.height / size_.height
	self._bgNode:setScaleX(scale_X)
	self._bgNode:setScaleY(scale_Y)
	self:addChild(self._bgNode)


	self._uiNode = cc.Node:create()
	self._uiNode:setPosition(_size.width*0.5, _size.height*0.5)
	self:addChild(self._uiNode)

	self:initBgCeng()
	self:createScrollView()
	self:createBtn()


	self:showPage(self._curIndex)

	local function _isOut( x, y )
		if(x < 0 or x > _size.width) then
			return true
		end
		if(y < 0 or y > _size.height) then
			return true
		end
		return false
	end

	local _beginPosX = 0
	self:registerScriptTouchHandler(function ( eventType, x, y )
		if self._isChanging then
			return
		end
		if (eventType == "began") then
			if(_isOut(x, y)) then
				return false
			end
			_beginPosX = x
			return true
		elseif (eventType == "ended") then
			if(_isOut(x, y)) then
				return
			end
			local _num = x - _beginPosX 
			if math.abs(_num) < _size.width*0.2 then
				return
			end
			if _num > 0 then
				self:goPre()
			else
				self:goNext()
			end
		end
	end)
end

function StageViewLayer1:initBgCeng( )
	local _size = self:getContentSize()
	-- local _bg = cc.LayerColor:create(cc.c4b(40, 51, 79, 255))
	-- _bg:setPosition(-_size.width*0.5, -_size.height*0.5)
	local _bg = XTHD.createSprite(self._resource .. "bg.png")
	_bg:setContentSize(self:getContentSize())
	self._bgNode:addChild(_bg, -1)

	local function _xxAction( xx )
		local _speed = math.random(20, 40)/10
		xx:runAction(cc.Sequence:create(
			cc.DelayTime:create(math.random(50, 100)/10),
			cc.Spawn:create(
				cc.FadeOut:create(_speed),
				cc.ScaleTo:create(_speed, 0.1)
			),
			cc.CallFunc:create(function()
				xx:setVisible(false)
				xx:setOpacity(255)
				xx:setScale(1.0)
				local _delay = math.random(30, 60)/10
				performWithDelay(xx, function()
					xx:setVisible(true)
					_xxAction(xx)
				end, _delay)
			end)
		))
	end
	local function _xxAction_0( xx, isShow)
		if isShow then
			xx:setVisible(true)
			_xxAction(xx)
			return
		end
		local _delay = math.random(30, 60)/10
		xx:setVisible(false)
		performWithDelay(xx, function()
			xx:setVisible(true)
			_xxAction(xx)
		end, _delay)
	end

	local _randomX = _size.width*0.25
	local _randomY = _size.height*0.15
	for i = 0, 7 do
		for j=1, 8 do
			local _posX = (i%4)*_randomX + math.random(_randomX)
			local _posY = math.random(_randomY)
			local _star = math.random(1, 3)
			local _sp = XTHD.createSprite(self._resource .. "star/xx_" .. _star .. ".png")
			_bg:addChild(_sp, 1)

			if i > 3 then
				_posY = _size.height*0.65 + _randomY + _posY
			else
				_posY = _size.height*0.65 + _posY
			end
			_sp:setPosition(_posX, _posY)

			local _show = math.random(1, 2) == 1 and true or false
			_xxAction_0(_sp, _show)
		end
	end

	local function _xzAction( xz, isFirst )
		if isFirst then
			local _notShowNow = math.random(1, 2) == 1 and true or false
			if _notShowNow then
				xz:setVisible(false)
				performWithDelay(xz, function()
					_xzAction(xz)
				end, math.random(30, 50)/10)
				return
			end
		end
		xz:setVisible(true)
		xz:setOpacity(0)
		local _speed = math.random(30, 60)/10
		xz:runAction(cc.Sequence:create(
			cc.FadeIn:create(_speed),
			cc.DelayTime:create(math.random(20, 40)/10),
			cc.FadeOut:create(_speed),
			cc.CallFunc:create(function()
				xz:setVisible(false)
			end),
			cc.DelayTime:create(math.random(30, 60)/10),
			cc.CallFunc:create(function()
				_xzAction(xz)
			end)
		))
	end

	for i=1, 5 do
		local _sp = XTHD.createSprite(self._resource .. "star/xz_" .. i .. ".png")
		_sp:setPosition(_size.width/6 * i, _size.height*0.8 + (i%2==1 and 70 or 0))
		_bg:addChild(_sp, 2)
		_xzAction(_sp, true)
	end


	self._nowIndex = 4
	cc.SpriteFrameCache:getInstance():addSpriteFrames(self._resource .. "yl.plist", self._resource .. "yl.png")
	local _yue = cc.Sprite:createWithSpriteFrameName("yl" .. self._nowIndex .. ".png")
	self._yue = _yue
	_yue:setScale(2)
	_yue:setOpacity(255*0.8)
	-- _yue:setPositionX(_size.width/5)
	_yue:setPositionY(100)
	self._bgNode:addChild(_yue, -1)
end

function StageViewLayer1:doYLAnimation( sDir )
	-- do return end
	local _mmax = 32
	local _mmin = 1
	local _perUnit = 1/4
	local _action

	local function _getFame( num, dir )
		local a1 = num + dir
		if dir > 0 then
			a1 = a1 > _mmax and _mmin or a1
		else
		    a1 = a1 < _mmin and _mmax or a1
		end
		return a1
	end
	cc.SpriteFrameCache:getInstance():addSpriteFrames(self._resource .. "yl.plist", self._resource .. "yl.png")
    local animation = cc.Animation:create()
    for i=1, 4 do
    	local _num = _getFame(self._nowIndex, sDir == 1 and 1 or -1)
    	self._nowIndex = _num
    	local _frame = cc.SpriteFrameCache:getInstance():getSpriteFrame( "yl" .. _num .. ".png")
    	if _frame then
	    	animation:addSpriteFrame(_frame)
	    end
    end
    animation:setDelayPerUnit( _perUnit )
    animation:setRestoreOriginalFrame(true)
    action = cc.Animate:create(animation)

	-- if sDir == 1 then
	-- 	action = getAnimationBySpriteFrame("yl", _min, _max, _perUnit)
 --    else
	-- 	cc.SpriteFrameCache:getInstance():addSpriteFrames(self._resource .. "yl.plist", self._resource .. "yl.png")
	--     local animation = cc.Animation:create()
	--     for i = _max , _min, -1 do
	--         local filepath = "yl" .. i .. ".png"
 --        	animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(filepath))
	--     end
	--     animation:setDelayPerUnit( _perUnit )
	--     animation:setRestoreOriginalFrame(true)
	--     action = cc.Animate:create(animation)
 --    end
    self._yue:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
	    	local filepath = "yl" .. self._nowIndex .. ".png"
	    	self._yue:initWithSpriteFrameName(filepath)
	    end)))
end

function StageViewLayer1:createScrollView()
	local _holeCent = 4
	local _posYs =  {-self:getContentSize().height*0.5 - 2, 0, -118*0.5, -118*0.5}
	local _pYunY = -self:getContentSize().height*0.5 + (315/615)*self:getContentSize().height
	local _width1 = 638
	local _width2 = 537
	local _moveSpeed = 12
	local function _runaction( _node1, _idx, _node2 )
		_node1:runAction(cc.Sequence:create(
			cc.MoveBy:create(_moveSpeed * _idx, cc.p(-_width1*_idx, 0)),
			cc.CallFunc:create(function()
				_node1:runAction(cc.RepeatForever:create(cc.Sequence:create(
					cc.CallFunc:create(function()
						local _posX = _node2:getPositionX() + _width1
						_node1:setPositionX(_posX)
					end),
					cc.MoveBy:create(_moveSpeed*3, cc.p(-_width1*3, 0))
				)))
			end)
		))
	end


	local _fileName = ""
	local _cengIndex = 1
	for i=1, _holeCent do
		local _tb = {}
		_cengIndex = (_holeCent - i)*2
		local _totleIdx = self._totleIndex
		if i == 3 or i == 4 then
			_totleIdx = self._totleIndex2
		end
		for j=1, _totleIdx do
			self._bgStringInfo[2] = i
			self._bgStringInfo[4] = j
			_fileName = table.concat(self._bgStringInfo)
			-- local _pg = XTHD.createSprite(_fileName)
			local _pg = XTHD.createSprite()
			_pg._fileName = _fileName
			local _pNum = j%8 
			if j == 24 then
				_pNum = 9
			elseif j == 25 then
				_pNum = 8
			elseif _pNum == 0 then
				_pNum = 8
			end
			_pg._guangId = _pNum
			self._bgNode:addChild(_pg, _cengIndex)
			_pg:setPositionY(_posYs[i])
			if i == 1 then
				_pg:setAnchorPoint(0.5, 0)
			end
			_tb[#_tb + 1] = _pg
			if i == self._diffCeng then
				_pg:setScaleX(-1)
			end
			_pg:setVisible(false)
		end
		self._bgList[#self._bgList + 1] = _tb
		if i == 4 then
			local _yun1 = XTHD.createSprite(self._resource .. "yun1.png")
			_yun1:setAnchorPoint(0, 0.5)
			self._bgNode:addChild(_yun1, _cengIndex)
			local _yun2 = XTHD.createSprite(self._resource .. "yun2.png")
			self._bgNode:addChild(_yun2, _cengIndex)
			_yun2:setAnchorPoint(0, 0.5)
			local _yun3 = XTHD.createSprite(self._resource .. "yun1.png")
			_yun3:setAnchorPoint(0, 0.5)
			self._bgNode:addChild(_yun3, _cengIndex)

			_yun1:setPosition(-_width1*0.5, _pYunY)
			_yun2:setPosition(_yun1:getPositionX() + _width1, _pYunY)
			_yun3:setPosition(_yun2:getPositionX() + _width1, _pYunY)

			
			_runaction(_yun1, 1, _yun3)
			_runaction(_yun2, 2, _yun1)
			_runaction(_yun3, 3, _yun2)
		end
	end

	local _size = self:getContentSize()
	self._hideCengW = 770
	self._hideCengX = 312
	local _px = self._hideCengW - self._hideCengX

	local _hideCeng1 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.7), _size.width - 312*2, _size.height)
    _hideCeng1:setAnchorPoint(0.5, 0.5)
    _hideCeng1:setPosition(-_hideCeng1:getContentSize().width*0.5, -_hideCeng1:getContentSize().height*0.5)  
    self._bgNode:addChild(_hideCeng1, -100)
	self._hideCeng1 = _hideCeng1

    self._resource = "res/image/plugin/stageChapter/newBg/"
    local _hideCeng0 = XTHD.createSprite(self._resource .. "hideCeng.png")
    _hideCeng0:setAnchorPoint(0, 0.5)
    _hideCeng0:setPositionX(_size.width*0.5 - _px)
    self._bgNode:addChild(_hideCeng0, 100)
	self._hideCeng0 = _hideCeng0

    local _hideCeng2 = XTHD.createSprite(self._resource .. "hideCeng.png")
    _hideCeng2:setAnchorPoint(0, 0.5)
    _hideCeng2:setScale(-1)
    _hideCeng2:setPositionX(-(_size.width*0.5 - _px))
    self._bgNode:addChild(_hideCeng2, 100)
	self._hideCeng2 = _hideCeng2
end

function StageViewLayer1:createBtn()
	local g_winSize = self:getContentSize()
	self._leftBtn = XTHDImage:create("res/image/plugin/stageChapter/btn_left_arrow.png")
    self._leftBtn:setAnchorPoint(0, 0.5)
    self._leftBtn:setPosition(-g_winSize.width*0.5 + 32, 0)
    self._uiNode:addChild(self._leftBtn, 2)

    self._rightBtn = XTHDImage:create("res/image/plugin/stageChapter/btn_right_arrow.png")
    self._rightBtn:setAnchorPoint(1, 0.5)
    self._rightBtn:setPosition(g_winSize.width*0.5 - 32, 0)
    self._uiNode:addChild(self._rightBtn, 2)

    local leftMove_1 = cc.MoveBy:create(0.5, cc.p(-10, 0))
    local leftMove_2 = cc.MoveBy:create(0.5, cc.p(10, 0))
    local rightMove_1 = cc.MoveBy:create(0.5, cc.p(10, 0))
    local rightMove_2 = cc.MoveBy:create(0.5, cc.p(-10, 0))

    self._leftBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(leftMove_1, leftMove_2)))
    self._rightBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(rightMove_1, rightMove_2)))

    self._leftBtn:setTouchEndedCallback(function()
		self:goPre()
    end)
    self._rightBtn:setTouchEndedCallback(function()
        self:goNext()
    end)
    --监听界面，用来删除主界面的table
    local swapBtn = XTHDPushButton:createWithParams({
    	needSwallow = false,
    	needEnableWhenMoving = true,
    	endCallback = function()
    		if self._swapPageCall and type(self._swapPageCall) == "function" then
    			self._swapPageCall()
    		end
    	end,
    })
    swapBtn:setPositionY(swapBtn:getPositionY()-30)
    swapBtn:setTouchSize(cc.size(self:getContentSize().width, self:getContentSize().height - 70))
    self._uiNode:addChild(swapBtn)


    local btn_battle = XTHDPushButton:createWithParams({
    	needSwallow = false,
    	needEnableWhenMoving = true,
    	endCallback = function() 
            if self._isChanging then
            	return
        	end
        	if self._touchedCall ~= nil and type(self._touchedCall) == "function" then
				self._touchedCall()
			end 
        end})
    btn_battle:setTouchSize(cc.size(600,500))
    self._uiNode:addChild(btn_battle)
end

function StageViewLayer1:_getNext( _index, _ceng )
	local _totleIdx = self._totleIndex
	local _pNum = _index + 1
	if _ceng == 3 or _ceng == 4 then
		_totleIdx = self._totleIndex2
		_pNum = _pNum%_totleIdx
		_pNum = _pNum < 1 and _totleIdx or _pNum
		-- print("_getNext : " .. _index .. " , " .. _pNum)
	else
		_pNum = _pNum > _totleIdx and 1 or _pNum
	end
	return _pNum
end

function StageViewLayer1:_getPre( _index, _ceng )
	local _totleIdx = self._totleIndex
	local _pNum = _index - 1
	if _ceng == 3 or _ceng == 4 then
		_totleIdx = self._totleIndex2
		_pNum = _pNum%_totleIdx
		_pNum = _pNum < 1 and _totleIdx or _pNum
		-- print("_getPre : " .. _index .. " , " .. _pNum)
	else
		_pNum = _pNum < 1 and _totleIdx or _pNum
	end
	return _pNum
end

function StageViewLayer1:goNext( )
	if self._isChanging then
		return
	end
	--进入下一关 1先判断等级是否满足能进入
	local chapterInfo = LiLianStageChapterData.getChapterInfoById(ChapterType.Diffculty, tonumber(self._curIndex) + 1)
	if chapterInfo and chapterInfo.levelfloor and tonumber(chapterInfo.levelfloor) > gameUser.getLevel() then
		XTHDTOAST(LANGUAGE_FORMAT_TIPS0(chapterInfo.levelfloor, tonumber(self._curIndex) + 1)) ------"等级达到""级开启第""章")
		return 
	end
	--进入下一关 2判断本章节是否通过
	local isPassed = LiLianStageChapterData.hasOpened(tonumber(self._curIndex) + 1)
	if not isPassed then
		return 
	end


	self:_goPage(1)
	self:doYLAnimation(1)
end

function StageViewLayer1:goPre( )
	if self._isChanging then
		return
	end
	if self._curIndex == 1 then
		return
	end

	self:_goPage(-1)
	self:doYLAnimation(-1)
end

function StageViewLayer1:_moveNode( _node, _dir )
	_node:runAction(
		cc.MoveBy:create(self._moveTime, cc.p(-1*_dir*_node:getContentSize().width, 0))
	)
end

function StageViewLayer1:_moveNode2( _node, _dir )
	_node:runAction(
		cc.MoveBy:create(self._moveTime, cc.p(-1*_dir*self:getContentSize().width, 0))
	)
end

function StageViewLayer1:_goPage( sDir )
	self._isChanging = true
	local _dir = tonumber(sDir) or 1
	local _index = self._curIndex

	local _preIndex, _nextIndex, _partIndex
	local _preIndex2, _nextIndex2, _preIndex3, _nextIndex3
	local _cengGroup, _bgNode, _pDir, _nowIndex
	for i=1, #self._bgList do
		_cengGroup = self._bgList[i]
		if i ~= self._diffCeng then
			_pDir = 1
		else
			_pDir = -1
		end
		_preIndex = self:_getPre(_index, i)
		_nextIndex = self:_getNext(_index, i)
		_partIndex = _dir < 0 and  self:_getPre(_preIndex, i) or self:_getNext(_nextIndex, i)
		if i == 3 or i == 4 then
			_nowIndex = _index%self._totleIndex2
			_nowIndex = _nowIndex < 1 and self._totleIndex2 or _nowIndex
			_preIndex2 = self:_getPre(_preIndex, i)
			_nextIndex2 = self:_getNext(_nextIndex, i)
			_preIndex3 = self:_getPre(_preIndex2, i)
			_nextIndex3 = self:_getNext(_nextIndex2, i)
		else
			_nowIndex = _index
			_preIndex2 = nil
			_nextIndex2 = nil
			_preIndex3 = nil
			_nextIndex3 = nil
		end
		for j=1, #_cengGroup do
			_bgNode = _cengGroup[j]
			
			if j == _nowIndex then
				self:_moveNode(_bgNode, _pDir*_dir)
			elseif j == _preIndex then
				self:_moveNode(_bgNode, _pDir*_dir)
			elseif j == _nextIndex then
				self:_moveNode(_bgNode, _pDir*_dir)
			elseif j == _preIndex2 then
				self:_moveNode(_bgNode, _pDir*_dir)
			elseif j == _nextIndex2 then
				self:_moveNode(_bgNode, _pDir*_dir)
			elseif j == _preIndex3 then
				self:_moveNode(_bgNode, _pDir*_dir)
			elseif j == _nextIndex3 then
				self:_moveNode(_bgNode, _pDir*_dir)
			elseif j == _partIndex then
				_bgNode:setTexture(_bgNode._fileName)
				_bgNode:setVisible(true)
				_bgNode:setPositionX(_pDir*_dir*_bgNode:getContentSize().width*2)
				self:_moveNode(_bgNode, _pDir*_dir)
			else
				-- _bgNode:setTexture(nil)
				_bgNode:setVisible(false)
				-- cc.Director:getInstance():getTextureCache():removeTextureForKey(_bgNode._fileName)
			end
		end
	end

	local _open1 = self:freshHideState(self._curIndex)

	local _preIndex = self:_getPre(_index)
	local _nextIndex = self:_getNext(_index)
	self._curIndex = _dir < 0 and _preIndex or _nextIndex

	local _open2 = LiLianStageChapterData.hasOpened(self._curIndex)
	if _open1 ~= _open2 then
		local _size = self:getContentSize()
		local _pX = _size.width*0.5 - (self._hideCengW - self._hideCengX)
		local _ceng = XTHD.createSprite(self._resource .. "hideCeng.png")
	    _ceng:setAnchorPoint(0, 0.5)
	    self._bgNode:addChild(_ceng, 100)

		if not _open2 then
			self._hideCeng1:setVisible(true)
			local _posX = self._hideCeng1:getPositionX() + _dir*self:getContentSize().width
			self._hideCeng1:setPositionX(_posX)
			if _dir == 1 then
			    _ceng:setScale(-1)
			    _ceng:setPositionX(-_pX + _size.width*2)
			else
			    _ceng:setPositionX(_pX - _size.width*2)
			end
		else
			if _dir == 1 then
			    _ceng:setPositionX(_pX + _size.width)
			else
			    _ceng:setScale(-1)
			    _ceng:setPositionX(-_pX - _size.width)
			end
		end

		self:_moveNode2(self._hideCeng0, _dir)
		self:_moveNode2(self._hideCeng1, _dir)
		self:_moveNode2(self._hideCeng2, _dir)
		self:_moveNode2(_ceng, _dir)
		
		performWithDelay(_ceng, function()
			_ceng:removeFromParent()
		end, self._moveTime)
	end

	performWithDelay(self, function()
		
		self:showPage(self._curIndex)
		self._isChanging = false
	end, self._moveTime)
end

function StageViewLayer1:showPage( _index )

	self._curIndex = _index
	--如果第一关和最后一关修改相应按钮
	local maxChapter = table.nums(gameData.getDataFromCSV("NightmareStarRewards"))

	if self._curIndex == 1 then
		self._leftBtn:setVisible(false)
		self._rightBtn:setVisible(true)
	elseif self._curIndex == maxChapter then
		self._leftBtn:setVisible(true)
		self._rightBtn:setVisible(false)
	else
		self._leftBtn:setVisible(true)
		self._rightBtn:setVisible(true)
	end
	local isPassed = LiLianStageChapterData.hasOpened(tonumber(self._curIndex) + 1)
	if not isPassed then
		self._rightBtn:setVisible(false)
	end
	if self._swapPageCall and type(self._swapPageCall) == "function" then
		self._swapPageCall()
	end

	local _preIndex, _nextIndex, _diffPre, _diffNext
	local _preIndex2, _nextIndex2, _diffPre2, _diffNext2, _preIndex3, _nextIndex3, _diffPre3, _diffNext3

	local _cengGroup, _bgNode, _nowIndex
	for i=1, #self._bgList do
		_cengGroup = self._bgList[i]

		_preIndex = self:_getPre(_index, i)
		_nextIndex = self:_getNext(_index, i)
		_diffPre = _nextIndex
		_diffNext = _preIndex
		if i == 3 or i == 4 then
			_nowIndex = _index%self._totleIndex2
			_nowIndex = _nowIndex < 1 and self._totleIndex2 or _nowIndex
			_preIndex2 = self:_getPre(_preIndex, i)
			_nextIndex2 = self:_getNext(_nextIndex, i)
			_diffPre2 = _nextIndex2
			_diffNext2 = _preIndex2
			_preIndex3 = self:_getPre(_preIndex2, i)
			_nextIndex3 = self:_getNext(_nextIndex2, i)
			_diffPre3 = _nextIndex3
			_diffNext3 = _preIndex3
		else
			_nowIndex = _index
			_preIndex2 = nil
			_nextIndex2 = nil
			_diffPre2 = nil
			_diffNext2 = nil
			_preIndex3 = nil
			_nextIndex3 = nil
			_diffPre3 = nil
			_diffNext3 = nil
		end
		for j=1, #_cengGroup do
			_bgNode = _cengGroup[j]
			if i ~= self._diffCeng then
				if j == _nowIndex then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(0)
				elseif j == _preIndex then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(-1 * _bgNode:getContentSize().width)
				elseif j == _nextIndex then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(_bgNode:getContentSize().width)
				elseif j == _preIndex2 then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(-2 * _bgNode:getContentSize().width)
				elseif j == _nextIndex2 then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(2 * _bgNode:getContentSize().width)
				elseif j == _preIndex3 then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(-3 * _bgNode:getContentSize().width)
				elseif j == _nextIndex3 then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(3 * _bgNode:getContentSize().width)
				else
					_bgNode:setTexture(nil)
					_bgNode:setVisible(false)
					cc.Director:getInstance():getTextureCache():removeTextureForKey(_bgNode._fileName)
				end
			else
				if j == _nowIndex then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(0)
				elseif j == _diffPre then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(-1 * _bgNode:getContentSize().width)
				elseif j == _diffNext then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(_bgNode:getContentSize().width)
				elseif j == _diffPre2 then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(-2 * _bgNode:getContentSize().width)
				elseif j == _diffNext2 then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(2 * _bgNode:getContentSize().width)
				elseif j == _diffPre3 then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(-3 * _bgNode:getContentSize().width)
				elseif j == _diffNext3 then
					_bgNode:setTexture(_bgNode._fileName)
					_bgNode:setVisible(true)
					_bgNode:setPositionX(3 * _bgNode:getContentSize().width)
				else
					_bgNode:setTexture(nil)
					_bgNode:setVisible(false)
					cc.Director:getInstance():getTextureCache():removeTextureForKey(_bgNode._fileName)
				end
			end
			if i == 2 then
				if j == _nowIndex then
					local _pic = XTHD.createSprite(self._resource .. "b_" .. _bgNode._guangId .. ".png")
					_pic:setAnchorPoint(0, 0)
					local _point = self._guangPoints[_bgNode._guangId] or {512, 308}
					_pic:setPosition(_point[1], _point[2])
					_pic:setOpacity(0)
					_bgNode:addChild(_pic, 1, 1024)
					_pic:runAction(cc.RepeatForever:create(cc.Sequence:create(
						cc.FadeTo:create(1.5, 255*0.9),
						cc.FadeTo:create(1.5, 0)
					)))
				else
					local _pic = _bgNode:getChildByTag(1024)
					if _pic then
						_pic:removeFromParent()
					end
				end
			end
		end
	end

	self:freshHideState(self._curIndex)


	if self._freshPageCall ~= nil and type(self._freshPageCall) == "function" then
		self._freshPageCall()
	end
end

function StageViewLayer1:freshHideState( _index )
	local _size = self:getContentSize()
	local _pX = _size.width*0.5 - (self._hideCengW - self._hideCengX)

	local _isOpen = LiLianStageChapterData.hasOpened(_index)
	if _isOpen then
		self._hideCeng0:setPositionX(_pX)
		self._hideCeng1:setVisible(false)
		self._hideCeng1:setPositionX(-self._hideCeng1:getContentSize().width*0.5)
		self._hideCeng2:setPositionX(-_pX)
	else
		self._hideCeng0:setPositionX(_pX - _size.width)
		self._hideCeng1:setVisible(true)
		self._hideCeng1:setPositionX(-self._hideCeng1:getContentSize().width*0.5)
		self._hideCeng2:setPositionX(-_pX + _size.width)
	end
	return _isOpen
end

function StageViewLayer1:setTouchedCall( sCallBack )
	self._touchedCall = sCallBack
end

function StageViewLayer1:setPageFreshCall( sCallBack )
	self._freshPageCall = sCallBack
end
function StageViewLayer1:setSwapCall( sCallBack )
	self._swapPageCall = sCallBack
end

function StageViewLayer1:getCurrentPage( )
	return self._curIndex
end


return StageViewLayer1
