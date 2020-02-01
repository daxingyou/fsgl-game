-- FileName: DuoCengScrollLayer.lua
-- Author: wangming
-- Date: 2015-08-07
-- Purpose: 封装多层滚动类
--[[TODO List]]
local g_winSize
local DuoCengScrollLayer = class("DuoCengScrollLayer",function()
	local obj = cc.Layer:create()
	g_winSize = obj:getContentSize()
	obj:setTouchEnabled(true)
	local function scriptHandler( tag )
		if tag == "enter" then
            obj:onEnter()
        elseif tag == "exit" then
            obj:onExit()
        elseif tag == "cleanup" then
        	obj:onCleanup()
        end
    end
    obj:registerScriptHandler(scriptHandler)
	return obj
end)

function DuoCengScrollLayer:createOne()
	local obj = DuoCengScrollLayer.new()
	obj:init()
    return obj
end

function DuoCengScrollLayer:onEnter( ... )
	self:startUpdate()
	self:freshBackLayData(true)
end

function DuoCengScrollLayer:onExit( ... )
	self:unscheduleUpdate()
	-- self:stopActionByTag(self._updateAction)
end

function DuoCengScrollLayer:onCleanup( ... )
	XTHD.removeEventListener(CUSTOM_EVENT.RELEASE_MAINCITYBACK)
	self:freshBackLayData(false)
end

function DuoCengScrollLayer:init( ... )
	self._haveInit = true
	self._isAutoScrolling = false
	self._isPageType = false
	self._startPage = 0
	self.backLayInfos = {  --添加的层级tag值 以及其对应zorder层
		{1,8},
		{2,6},
		{3,4},
		{4,2},
	}
	self._updateAction = 101
	self._speedScale = 6
	self._freeWidth = 1
	self._refreshTexture = true
	self._touchCounts = 0
	self._bounce = 0

	local function _isOut( x, y )
		if(x < 0 or x > g_winSize.width) then
			return true
		end
		if(y < 0 or y > g_winSize.height) then
			return true
		end
		return false
	end

	self:registerScriptTouchHandler(function ( eventType, x, y )
		local pPos = cc.p(x,y) --cc.Director:getInstance():convertToGL(cc.p(x,y))	
		if (eventType == "began") then
			if(_isOut(x, y)) then
				return false
			end
			if self._touchCounts == 1 then
				return
			end
			if (self._isAutoScrolling) then
				self:stopLaysAllAction()
				self._isAutoScrolling = false
			end
			
			self._touchCounts = 1
			self._moveCount = 0
			self:stopAction(self._checkMoveAction)
			self:onTouchBegan(pPos)
			-- print("began")
			self._checkMoveAction = schedule(self, function ( ... )
				if self._moveCount == 1 then
					self._moveCount = 0
				else
					self._touchCounts = 0
					self:stopAction(self._checkMoveAction)
				end
			end, 1)
			return true
		elseif (eventType == "moved") then
			if(_isOut(x, y)) then
				return false
			end
			-- print("moved")
			local pPrePos = self._movedPos or self._beganPos
			self._moveCount = 1
			self:onTouchMoved(pPos , pPrePos)
		elseif (eventType == "ended") then
			-- print("ended")
			self:onTouchEnded(pPos)
			self._touchCounts = 0
			self:stopAction(self._checkMoveAction)
		elseif (eventType == "canceled") then
			-- print("canceled")
			self:onTouchEnded(pPos)
			self._touchCounts = 0
			self:stopAction(self._checkMoveAction)
		end
	end)
end

-- update更新
function DuoCengScrollLayer:startUpdate( ... )
	-- self:stopActionByTag(self._updateAction)
	local topLay = self:getTopLay()
	if (not topLay) then
		return
	end
	self._updateStartX = topLay:getPositionX()
	local function update( dt )
		local topLay = self:getTopLay()
		if (not topLay) then
			return
		end
		local pPosX = topLay:getPositionX()
		if (self._updateStartX == pPosX) then
			return
		end
		local pChange = pPosX - self._updateStartX

		self._updateStartX = pPosX

		self:updateTexture(pPosX) -- 更新地图加载情况
		if (self._scrollCall) then -- 滚动回调
			self._scrollCall()
		end
	end
	self:scheduleUpdateWithPriorityLua(update, 0)
end

-- 设置是否开启动态释放更新地图纹理
function DuoCengScrollLayer:setRefreshTexutre( sFresh )
	self._refreshTexture = sFresh
end

-- 更新场景元素的状态
function DuoCengScrollLayer:updateSprite( sSprite, sFile, isShow )
	if(not sSprite) then
		return
	end
	local _isVisible = sSprite:isVisible()
	if (isShow) then
		if (not sSprite.isInit or (self._refreshTexture and not _isVisible)) then
			local texture = cc.Director:getInstance():getTextureCache():addImage(sFile)
			if (texture) then
				if (not sSprite.isInit) then
					sSprite.isInit = true
					if (sSprite._fnInitData) then
						sSprite._fnInitData(sSprite, sSprite._idx)
					end
					sSprite:initWithTexture(texture)
			    	sSprite:setAnchorPoint(cc.p(0, 0.5))
			    	sSprite:setPositionY(g_winSize.height*0.5)
				else
					sSprite:setTexture(texture)
				end
			end
		end
		sSprite:setVisible(true)
	else
		if (not self._refreshTexture) then
			return
		end
		if (_isVisible) then
			-- local ptexture = sSprite:getTexture()
			-- local texture = cc.Director:getInstance():getTextureCache():addImage(sFile)
			sSprite:setVisible(false)
			-- sSprite:setTexture(nil)
			-- if (texture == ptexture) then
			-- 	cc.Director:getInstance():getTextureCache():removeTexture(ptexture)
			-- end
		end
	end
end

--根据位置更新 texture的加载释放处理
function DuoCengScrollLayer:updateTexture( sPos )
	if (not self._pageGroup or #self._pageGroup < 1) then
		return
	end

	local _mPos = sPos or self:getTopLay():getPositionX()
	local _hideshow = false
	if not sPos then
		_hideshow = true
	end

	for k,v in pairs(self._pageGroup) do
		local info = v
		if (info) then
			local _pos = info.pos or 0
			local _width = info.width or 0
			local _sprite = info.sprite or nil
			local _file = info.file

	
			if (_mPos + _pos > g_winSize.width * self._freeWidth or _mPos + _pos + _width < 0 - g_winSize.width * self._freeWidth) then
				if not _hideshow then
					self:updateSprite(_sprite, _file, false)
				end
			else
				self:updateSprite(_sprite, _file, true)
			end
		end
	end
end

-- 添加滚动的回调
function DuoCengScrollLayer:addScrollCall( callFn )
	self._scrollCall = callFn
end

--检查是否有某一tag的层级
function DuoCengScrollLayer:checkHaveTag( slevel )
	local pLevel = tonumber(slevel) or 0
	for i=1, #self.backLayInfos do
		if (self.backLayInfos[i][1] == pLevel) then
			return true
		end
	end
	return false
end

function DuoCengScrollLayer:addNewBackLay(sNode, pZOrder, pTag)
	local pLay = self:getChildByTag(pTag)
	if (pLay) then
		pLay:removeFromParent()
		pLay = nil
	end

	sNode:setAnchorPoint(0,0)
    sNode:setPosition(0, 0)
	self:addChild(sNode,pZOrder,pTag)
end


-- 添加背景层方法，目前支持任意层，
-- arg ： slevel 显示层级，数字越小层级越高，暂时只支持1，2，3
function DuoCengScrollLayer:addBackLay( sNode, slevel)
	if (not sNode) then
		return
	end
	local pLevel = tonumber(slevel) or 0
	
	if(not self:checkHaveTag(pLevel)) then
		return
	end

	local pZOrder = self.backLayInfos[pLevel][2]
	local pTag = self.backLayInfos[pLevel][1]

	local pLay = self:getChildByTag(pTag)
	if (pLay) then
		pLay:removeFromParent()
		pLay = nil
	end
	sNode:setAnchorPoint(0,0.5)
    sNode:setPosition(0, g_winSize.height*0.5)
	self:addChild(sNode,pZOrder,pTag)
end

-- 设置响应点击回调的方法
function DuoCengScrollLayer:setClickCallFunc( sFunc ) 
	self._clickCallFunc = sFunc
end

-- 设置响应点击回调的方法
function DuoCengScrollLayer:getCurrentPage(  ) 
	local pTopLay = self:getTopLay()
	local pos = math.abs(pTopLay:getPositionX())
	local width = self:getContentSize().width
	local curPage, left
	if not self._pageGroup then
		local curPage, left = math.modf(pos / width)
		if(left > 0.5) then
			curPage = curPage + 1
		end
	else
		curPage = 0
		for i = 1, #self._pageGroup do
			local info = self._pageGroup[i]
			curPage = i - 1
			if pos < info.pos + info.width*0.5 then
				break
			end
		end
		if(curPage > #self._pageGroup - 1) then
			curPage = #self._pageGroup - 1
		end
	end
	
	return curPage
end

-- 设置页信息 
-- {
-- 	{pos = "x坐标", width = "宽度", sprite = "图片对象", file = "图片文件名"},
-- }
function DuoCengScrollLayer:setPagePos( posGroup )
	self._pageGroup = posGroup
end

-- 设置页信息 
-- {
-- 	{pos = "x坐标", width = "宽度", sprite = "图片对象", file = "图片文件名"},
-- }
function DuoCengScrollLayer:resetPagePos( )
	if not self._pageGroup then
		return
	end
	for k,v in pairs(self._pageGroup) do
		local _sprite = v.sprite or nil
		if _sprite then
			_sprite.isInit = false
			_sprite:setVisible(false)
			local ptexture = _sprite:getTexture()
			cc.Director:getInstance():getTextureCache():removeTexture(ptexture)
			_sprite:setTexture(nil)
		end
	end

end

-- 移动到指定页数，page从0开始， isMoveTo为false则直接跳转，没有滚动过程
function DuoCengScrollLayer:scrollToPage( page, isMoveTo ) 
	if (self._isAutoScrolling) then
		return
	end
	local pTopLay = self:getTopLay()
	local width = self:getContentSize().width
	
	if page > #self._pageGroup - 1 then
		page = #self._pageGroup - 1
	elseif page < 0 then
		page = 0
	end

	local info = self._pageGroup[page+1]
	local pos = 0 - (info.pos + info.width*0.5 - width * 0.5)

	local dis = pos - pTopLay:getPositionX()
	local pTime = isMoveTo and 0.15 or 0
	local function callFn( ... )
		self._isAutoScrolling = false
	end
	self:setAutoMove(pTime, dis, callFn)
end

-- 获取背景层方法，目前支持3层，slevel = 前(1)、中(2)、后(3)
function DuoCengScrollLayer:getBackLay( slevel )
	local pLevel = tonumber(slevel) or 0
	if (not self:checkHaveTag(pLevel)) then
		return nil
	end
	return self:getChildByTag(pLevel)
end

-- 根据点获取层级滑动的实际可用x
function DuoCengScrollLayer:getBackLayNewX( sNode, sX )
	local pX = sX
	local pWidth = sNode:getContentSize().width
	local pMaxX = 0
	local pMinX = g_winSize.width - pWidth
	if (pX > pMaxX) then
		pX = pMaxX
	elseif (pX < pMinX) then
		pX = pMinX
	end
	return pX
end

-- 根据变化值获取层级滑动的实际可用变化值
function DuoCengScrollLayer:getBackLayEaseX( sNode, sEX , sBounces)
	local pEX = sEX
	local pWidth = sNode:getContentSize().width
	local pPosX = sNode:getPositionX()
	print("shatter>>pPosX>>" .. pPosX)
	print("shatter>>sEX>>" .. sEX)
	local pMaxX = 0 - sBounces
	local pMinX = g_winSize.width - pWidth + sBounces
	print("shatter>>pMaxX>>" .. pMaxX)
	print("shatter>>pMinX>>" .. pMinX)
	if (pEX + pPosX > pMaxX) then
		pEX = pMaxX - pPosX
		print("shatter>>pMaxX>>")
	elseif (pEX + pPosX < pMinX) then
		pEX = pMinX - pPosX
		print("shatter>>pMinX>>")
	end
	print("shatter>>pEX>>" .. pEX)
	return pEX
end

function DuoCengScrollLayer:stopLaysAllAction( ... )
	for i=1,#self.backLayInfos do
		local pLay = self:getBackLay(i)
		if (pLay) then
			pLay:stopAllActions()
		end
	end
end

function DuoCengScrollLayer:onTouchBegan( sPos )
	self._beganPos = sPos
	self._start_time = os.clock()
	self:stopLaysAllAction()
	self._isAutoScrolling = false
	if self._isPageType then
		self._startPage = self:getCurrentPage()
	end
end

function DuoCengScrollLayer:onTouchMoved( sPos, sPrePos )
	self._movedPos = sPos
	local changeX = sPos.x - sPrePos.x 
	self._lastChangeX = changeX

	local pPreLay = nil
	local pPosX
	for i=1, #self.backLayInfos do
		local pLay = self:getBackLay(i)
		if (pLay) then
			if (pPreLay) then
				local pX = pPreLay:getPositionX()
				pPosX = pX * (pLay:getContentSize().width - g_winSize.width)/(pPreLay:getContentSize().width - g_winSize.width)
			else
				pPosX = pLay:getPositionX() + changeX
			end
			pPosX = self:getBackLayNewX(pLay, pPosX)
			pLay:setPositionX(pPosX)
			pPreLay = pLay
		end
	end
end

function DuoCengScrollLayer:onTouchEnded( sPos )
	if not self._isPageType then
		if (self._beganPos and self._movedPos and self._lastChangeX and math.abs(self._lastChangeX) > 1.5) then
			local end_time = os.clock()
			local time = (tonumber(end_time) - tonumber(self._start_time)) * self._speedScale
			local length = tonumber(sPos.x) - tonumber(self._beganPos.x)
			local speed = math.abs(length / time)
			if (speed > self:getContentSize().width * 1.5) then
				speed = self:getContentSize().width * 1.5
			end
			if (self._lastChangeX < 0) then
				speed = 0 - speed
			end
			local run_disx = speed
			local pPreLay = nil
			local pBounces = self._bounce
			for i=1, #self.backLayInfos do
				local pLay = self:getBackLay(i)
				if (pLay) then
					if (pPreLay) then
						run_disx = run_disx * (pLay:getContentSize().width - g_winSize.width) / (pPreLay:getContentSize().width - g_winSize.width)
						pBounces = pBounces * (pLay:getContentSize().width - g_winSize.width) / (pPreLay:getContentSize().width - g_winSize.width)
					end
					run_disx = self:getBackLayEaseX(pLay ,run_disx, pBounces)
					if(run_disx ~= 0) then
						local pActionEase = cc.EaseCubicActionOut:create(cc.MoveBy:create(0.7, cc.p(run_disx, 0)))
			            pLay:runAction(pActionEase)
			        end
			        pPreLay = pLay
				end
	        end
		end
	end

	local pBool = false
	if (not self._lastChangeX or (self.lastChangeX and math.abs(self._lastChangeX) < 1.5)) then
		pBool = true
	end
	if (self._clickCallFunc) then
		self._clickCallFunc(sPos, pBool)
	end
	if self._isPageType then
		local isTouchFast = false
		local end_time = os.clock()
		local time = (tonumber(end_time) - tonumber(self._start_time)) * self._speedScale
		local length = tonumber(sPos.x) - tonumber(self._beganPos.x)
		local speed = math.abs(length / time)
		if (speed > self:getContentSize().width * 0.6) then
			speed = self:getContentSize().width * 0.6
			isTouchFast = true
		end
		if math.abs(length) > self:getContentSize().width*0.15 or isTouchFast then
			if length > 0 then
				self._startPage = self._startPage - 1
			else
				self._startPage = self._startPage + 1
			end
		end
		self:scrollToPage(self._startPage, true)
	elseif self._bounce ~= 0 then
		local dis = self:checkNeedBounce()
		if dis ~= 0 then
			self:setAutoMove(0.5, dis, nil)
		end

	end

	self._lastChangeX = nil
	self._beganPos = nil
	self._movedPos = nil
end

function DuoCengScrollLayer:freshBounce( ... )
	if self._bounce ~= 0 then
		local dis = self:checkNeedBounce()
		if dis ~= 0 then
			self:setAutoMove(0, dis, nil)
		end
	end
end

function DuoCengScrollLayer:checkNeedBounce( ... )
	local topLay = self:getTopLay()
	if topLay then
		local px = self:getBackLayEaseX(topLay, 0, self._bounce)
		return px
	end
	return 0
end

-- 设置滚动响应的缩放比例，数值越大反应越不灵敏
function DuoCengScrollLayer:setScrollAutoScale( sScale )
	local pNum = tonumber(sScale) or 6
	self._speedScale = pNum
end

-- 设置背景层可否手动滑动
function DuoCengScrollLayer:setScrollTouchEnabled( sBool )
	self:setTouchEnabled(sBool)
end

function DuoCengScrollLayer:setPageType( sBool )
	self._isPageType = sBool
end

function DuoCengScrollLayer:setBounce( sNum )
	self._bounce = tonumber(sNum) or 0 		--回弹值
	self._bounce = self._bounce < 0 and 0 or self._bounce
end

-- 重置背景层到初始位置 0
function DuoCengScrollLayer:resetBackLay( ... )
	for i=1, #self.backLayInfos do
		local pLay = self:getBackLay(i)
		if (pLay) then
			pLay:setPositionX(0+self._bounce)
		end
	end
	self:freshBounce()
end

-- 获取最高层lay
function DuoCengScrollLayer:getTopLay( ... )
	for i=1, #self.backLayInfos do
		local pLay = self:getBackLay(i)
		if(pLay) then
			return pLay
		end
	end
	return nil
end

-- 获取层级的数量
function DuoCengScrollLayer:getLayCount( ... )
	local count = 0
	for i=1, #self.backLayInfos do
		local pLay = self:getBackLay(i)
		if (pLay) then
			count = count + 1
		end
	end
	return count
end

-- 背景层自动移动
-- args: sTime 时间;
--       sMoveDis 移动距离，正值向右移动，负值向左移动;
--       callFn 移动完成后的回调，可以没有
function DuoCengScrollLayer:setAutoMove( sTime, sMoveDis, callFn, isEase)
	self:stopLaysAllAction()
	self._isAutoScrolling = true
	local run_disx = sMoveDis
	local run_time = sTime
	local pPreLay
	local index = 0
	local count = self:getLayCount()
	local _isEase = isEase == nil and true or _isEase

    if(#self.backLayInfos == 0) then
    	self._isAutoScrolling = false
    	if(callFn) then
			callFn()
		end
    end
	local pBounces = self._bounce
	for i=1, #self.backLayInfos do
		local pLay = self:getBackLay(self.backLayInfos[i][1])
		if (pLay) then
			index = index + 1
			if (pPreLay) then
				run_disx = run_disx * (pLay:getContentSize().width - g_winSize.width) / (pPreLay:getContentSize().width - g_winSize.width)
				pBounces = pBounces * (pLay:getContentSize().width - g_winSize.width) / (pPreLay:getContentSize().width - g_winSize.width)
			end
			run_disx = self:getBackLayEaseX(pLay ,run_disx, pBounces)
			if (run_disx ~= 0) then
				if (run_time == 0) then
					local posX = pLay:getPositionX() + run_disx
					pLay:setPositionX(posX)
					if (index == count) then
						self._isAutoScrolling = false
						if(callFn) then
							callFn()
						end
					end
				else
					local pArray = {}
					local posX = pLay:getPositionX() + run_disx
					local posY = pLay:getPositionY()
					local pAction = cc.MoveTo:create(run_time, cc.p(posX, posY))
					local pActionEase = cc.EaseCubicActionOut:create(pAction)
					if _isEase == true then
						pActionEase = cc.EaseCubicActionOut:create(pAction)
					else
						pActionEase = pAction
					end
					table.insert(pArray, pActionEase)
					if (index == count) then
						pAction = cc.CallFunc:create(function ( ... )
							self._isAutoScrolling = false
							if (callFn) then
								callFn()
							end
						end)
					end
					table.insert(pArray, pAction)
					local seqAction = cc.Sequence:create(pArray)
		            pLay:runAction(seqAction)
				end
			else
				if (index == count) then
					self._isAutoScrolling = false
					if(callFn) then
						callFn()
					end
				end
	        end
	        pPreLay = pLay
		end
    end
end

function DuoCengScrollLayer:setBackLayData( _data )
	self._enterLoadData = _data
	if self._enterLoadData then
		XTHD.addEventListener({name = CUSTOM_EVENT.RELEASE_MAINCITYBACK,callback = function( event )
			self:freshBackLayData(false)
	    end})
	end
end

function DuoCengScrollLayer:freshBackLayData( isEnter )
	if (self._haveInit and isEnter) or (not self._haveInit and not isEnter) then
		return
	end
	self._haveInit = isEnter
	if self._enterLoadData then
		for k,v in pairs(self._enterLoadData) do
			local pLay = self:getBackLay(v.id)
			if pLay then
				local pBackData = v.data or {}
				if #pBackData > 0 then
					for i = 1, #pBackData do
						local pSp = pLay:getChildByName("back_"..i)
						if pSp then
							if isEnter then
								local ptexture = cc.Director:getInstance():getTextureCache():addImage(pBackData[i])
								if ptexture then
									pSp:setTexture(ptexture)
								end
							else
								local ptexture = pSp:getTexture()
								pSp:setTexture(nil)
								if ptexture then
									cc.Director:getInstance():getTextureCache():removeTexture(ptexture)
								end
							end
						end
					end
				end
			end
		end
	end
end

return DuoCengScrollLayer
