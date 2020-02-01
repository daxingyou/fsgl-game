--createdBy xingchen 
--2015/10/27
--帮派战主将确认队员界面
local BangPaiZhanQueRenDuiYuan = class("BangPaiZhanQueRenDuiYuan",function()
    return XTHD.createBasePageLayer()
end)

function BangPaiZhanQueRenDuiYuan:ctor(data)
	self.fighterBgTable = {}
	self.fighterListData = {}
	self.adjustOrder = {}
	self:setFighterListData(data)
	self:initLayer()
end

function BangPaiZhanQueRenDuiYuan:initLayer()
	local _topBarHeight = self.topBarHeight or 40
    local _bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    _bg:setPosition(cc.p(self:getContentSize().width/2,(self:getContentSize().height - _topBarHeight)/2 ))
    self:addChild(_bg)
	-- local _bg = cc.Sprite:create("res/image/guild/guildContent_bg.png")
 --    _bg:setPosition(cc.p(self:getContentSize().width/2,(self:getContentSize().height - 55)/2 ))
 --    self:addChild(_bg)

    local _leftScrollBtn = XTHD.createButton({
            normalFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
            selectedFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
            touchScale = 0.95
        })
    _leftScrollBtn:setAnchorPoint(cc.p(0,0.5))
    _leftScrollBtn:setPosition(cc.p(_bg:getContentSize().width/2-self:getContentSize().width/2+5,_bg:getContentSize().height/2))
    _bg:addChild(_leftScrollBtn)
    _leftScrollBtn:setTouchEndedCallback(function()
    		self:arrowCallback(1)
        end)
    --右边箭头
    local _rightScrollBtn = XTHD.createButton({
            normalFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
            selectedFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
            touchScale = 0.95
            -- ,musicFile = XTHD.resource.music.effect_btn_common
        })
    _rightScrollBtn:setAnchorPoint(cc.p(1,0.5))
    _rightScrollBtn:setPosition(cc.p(_bg:getContentSize().width/2+self:getContentSize().width/2 -1,_bg:getContentSize().height/2))
    _bg:addChild(_rightScrollBtn)

    _rightScrollBtn:setTouchEndedCallback(function()
	    	self:arrowCallback(2)
        end)

    local _contentSize = cc.size(825,470)
    local _contentBg = BangPaiFengZhuangShuJu.createListBg(_contentSize)
	_contentBg:setPosition(cc.p(_bg:getContentSize().width/2,_bg:getContentSize().height/2))
	_bg:addChild(_contentBg)
	local _distance = (_contentBg:getContentSize().height - 10)/10
	self.distance = _distance
	local _fighterPosX = _contentBg:getContentSize().width/2
	self.fighterBgPos = {
		cc.p(_fighterPosX,_distance*9 + 5),cc.p(_fighterPosX,_distance*7+5),cc.p(_fighterPosX,_distance*5+5),cc.p(_fighterPosX,_distance*3+5),cc.p(_fighterPosX,_distance*1+5)
	}
	for i=1,5 do
		self.adjustOrder[i] = i
		-- local _normalSp = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/scale9_bg_21.png")
		-- _normalSp:setContentSize(cc.size(795,93))
		-- local _selectedSp = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/scale9_bg_21.png")
		-- _selectedSp:setContentSize(cc.size(795,93))
		local _fightSize = cc.size(810,86)
		local _fighterBg = XTHDPushButton:createWithParams({
				normalNode = BangPaiFengZhuangShuJu.createListCellBg(_fightSize),
				selectedNode = BangPaiFengZhuangShuJu.createListCellBg(_fightSize),
				needEnableWhenOut = true
			})
		self.fighterBgTable[i] = _fighterBg
		_fighterBg.posIndex = i
	    _fighterBg:setContentSize(_fightSize)
	    _fighterBg:setAnchorPoint(cc.p(0.5,0.5))
	    _fighterBg:setPosition(self.fighterBgPos[i]) 
	    _contentBg:addChild(_fighterBg)

	    local _fighterBgSp = self:getBtnNode("res/image/common/scale9_bg1_26.png",_fightSize)
	    _fighterBgSp:setName("fighterBgSp")
	    _fighterBgSp:setPosition(cc.p(_fighterBg:getContentSize().width/2,_fighterBg:getContentSize().height/2))
	    _fighterBg:addChild(_fighterBgSp)
	    _fighterBgSp:setVisible(false)
	end
	self:setCurrentFighterBgs()

    

	XTHD.addEventListenerWithNode({name = "refreshGuildFightSp",node = self,callback = function(event)
        	self:notificateToRefresh(event.data)
        end})

end

function BangPaiZhanQueRenDuiYuan:setCurrentFighterBgs()
	--暂时未决定在这里是否removeAllChildren
	for i=1,5 do
		local _fighterBg = self.fighterBgTable[i]
		if _fighterBg~=nil then
			if _fighterBg:getChildByName("indexBtn") then
				_fighterBg:removeChildByName("indexBtn")
			end
			if _fighterBg:getChildByName("adjustBtn") then
				_fighterBg:removeChildByName("adjustBtn")
			end
			if _fighterBg:getChildByName("fighterInfoBg") then
				_fighterBg:getChildByName("fighterInfoBg"):removeAllChildren()
				_fighterBg:removeChildByName("fighterInfoBg")
			end
			local _adjustBtn = XTHD.createCommonButton({
					btnColor = "write_1",
					isScrollView = false,
					disableFile = "res/image/common/btn/btn_write_1_disable.png",
					text = LANGUAGE_KEY_ADJUST,
					fontSize = 26,
					-- fontColor = XTHD.resource.btntextcolor.green
				})
				_adjustBtn:setScale(0.8)
			_adjustBtn:setName("adjustBtn")
			-- _adjustBtn:setScale(1.05)
			_adjustBtn:setTouchEndedCallback(function()
					local _fighterIndex = _fighterBg.posIndex
					self:selectedCallback(_fighterBg.posIndex)
				end)
			_adjustBtn:setPosition(cc.p(_fighterBg:getContentSize().width - 78,_fighterBg:getContentSize().height/2))
			_fighterBg:addChild(_adjustBtn)

			local _indexKey = i
			if self.killIndex == i-1 then
				_indexKey = "Over"
			end
			local _indexBtn = XTHD.createButton({
					normalFile = "res/image/guild/guildWar/guildWar_order" .. _indexKey .. ".png",
					selectedFile = "res/image/guild/guildWar/guildWar_order" .. _indexKey .. ".png",
					touchScale = 0.95,
				})
			_indexBtn:setTouchEndedCallback(function()
					--设置成绝杀。
					if _indexBtn.posIndex and tostring(_indexBtn.posIndex) == "over" then
						XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.currentPosIsKillToastXc)
					else
						self:setIndexBtnCallback(tonumber(_indexBtn.posIndex))
					end
				end)
			_indexBtn.posIndex = _indexKey
			_indexBtn:setName("indexBtn")
			_indexBtn:setPosition(cc.p(55,_fighterBg:getContentSize().height/2))
			_fighterBg:addChild(_indexBtn)

			

			--信息
			local _fighterData = self.fighterListData[i]
			if _fighterData ~=nil and next(_fighterData)~=nil then
				local _fighterInfoBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,575,_fighterBg:getContentSize().height))
				_fighterInfoBg:setOpacity(0)
				_fighterInfoBg:setName("fighterInfoBg")
				_fighterInfoBg:setAnchorPoint(cc.p(0.5,0.5))
				_fighterInfoBg:setPosition(cc.p(90+_fighterInfoBg:getContentSize().width/2,_fighterBg:getContentSize().height/2))
				_fighterBg:addChild(_fighterInfoBg)
				--name
				local _namePosX = 5
				local _nameLabel = XTHDLabel:createWithSystemFont(_fighterData.name,"Helvetica",22)
				_nameLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
				_nameLabel:setAnchorPoint(cc.p(0,0.5))
				_nameLabel:setPosition(cc.p(_namePosX,_fighterInfoBg:getContentSize().height - 32))
				_fighterInfoBg:addChild(_nameLabel)
				--level
				local _levelPosY = 18
				local _levelLabel = XTHDLabel:create("LV: " .. _fighterData.level,22)
				_levelLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
				_levelLabel:setAnchorPoint(cc.p(0,0))
				_levelLabel:setPosition(cc.p(_namePosX + 55,_levelPosY))
				_fighterInfoBg:addChild(_levelLabel)

				local _roleLabel = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.fighterTextXc,22)
				_roleLabel:setAnchorPoint(cc.p(0,0))
				_roleLabel:setPosition(cc.p(_namePosX,_levelPosY))
				_fighterInfoBg:addChild(_roleLabel)
				if _fighterData.isLord~=nil and tonumber(_fighterData.isLord) == 1 then
					_roleLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("hongse"))
					_roleLabel:enableShadow(BangPaiFengZhuangShuJu.getTextColor("hongse"),cc.size(0.4,-0.4),0.4)
					_roleLabel:setString(LANGUAGE_KEY_GUILDWAR_TEXT.lordTextXc)
					_adjustBtn:setVisible(false)
				else
					_roleLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
				end
				local _heroPosX = _namePosX + 255-75 - 85
				local _heroPosY = _fighterInfoBg:getContentSize().height/2
				-- local _heroPosTable = SortPos:sortFromMiddle(cc.p(self:getContentSize().width/2,_heroPosY) ,#_fighterData.pets,75)
				for j=1,#_fighterData.pets do
					local _heroSp = HeroNode:createWithParams({
						heroid   = _fighterData.pets[j].petId,
						star   = _fighterData.pets[j].star,
						level = _fighterData.pets[j].level,
						advance = _fighterData.pets[j].phase,
						clickable = false
					})
					_heroSp:setScale(65/_heroSp:getContentSize().width)
					_heroSp:setAnchorPoint(cc.p(0,0.5))
					_heroSp:setPosition(cc.p(_heroPosX + j*75,_heroPosY))
					_fighterInfoBg:addChild(_heroSp)
				end
				--查看其他人的排队
				if self.challengeState == 1 then
					_fighterBg:setClickable(true)
					_fighterBg:setTouchBeganCallback(function()
				    		local _fighterIndex = _fighterBg.posIndex
				    		self:doTouchBegan(_fighterBg)
				    	end)
				    _fighterBg:setTouchMovedCallback(function(touch)
				    		local _fighterIndex = _fighterBg.posIndex
				    		self:doTouchMoved(_fighterBg,touch,_fighterIndex)
				    	end)
				    _fighterBg:setTouchEndedCallback(function()
				    		local _fighterIndex = _fighterBg.posIndex
				    		self:doTouchEnded(_fighterBg)
				    	end)
				else
					_fighterBg:setClickable(false)
				end
			end
			--查看其他人的排队
			if self.challengeState ~= 1 then
				-- XTHD.setGray(_adjustBtn:getStateNormal())
				
				_adjustBtn:setEnable(false)
				-- _adjustBtn:getLabel():enableShadow(XTHD.resource.btntextcolor.black,cc.size(0.4,-0.4),0.4)
				_adjustBtn:setLabelColor(cc.c3b(255,255,255))
				_indexBtn:setClickable(false)
				_fighterBg:setClickable(false)
			end
		end
	end
end

function BangPaiZhanQueRenDuiYuan:doTouchBegan(target)
	target:setLocalZOrder(3)
	if target:getChildByName("fighterBgSp") then
		target:getChildByName("fighterBgSp"):setVisible(true)
	end
	-- target:setStateNormal(self:getBtnNode("res/image/common/scale9_bg_11.png"))
	-- target:setStateSelected(self:getBtnNode("res/image/common/scale9_bg_11.png"))
	target:setScale(1.08)
end
--_idx是它began的时候的位置
function BangPaiZhanQueRenDuiYuan:doTouchMoved(target,touch,_idx)
	-- local target = self.fighterBgTable[self.adjustOrder[tonumber(_idx)]]
	local x,y = target:getPosition()
	target:setScale(1.08)
	local nowPos = touch:getLocation()
	local prePos = touch:getPreviousLocation()
	local diff = cc.pSub(nowPos,prePos)		
	if not (y + diff.y > self.fighterBgPos[1].y) and not (y + diff.y < self.fighterBgPos[#self.fighterListData].y) then -----如果移到顶部或者移到底部就不能移动
		local _newPosY = y + diff.y
		target:setPosition(x,_newPosY)	
		local _newIndex = math.floor(_newPosY/self.distance)
		local _newPos = math.ceil((10-_newIndex)/2)
		self:setFighterBgNewPos(_idx,_newPos)
	end
end

function BangPaiZhanQueRenDuiYuan:doTouchEnded(target)
	target:setLocalZOrder(0)
	target:setScale(1)
	if target:getChildByName("fighterBgSp") then
		target:getChildByName("fighterBgSp"):setVisible(false)
	end
	-- target:setStateNormal(self:getBtnNode("res/image/common/scale9_bg_21.png"))
	-- target:setStateSelected(self:getBtnNode("res/image/common/scale9_bg_21.png"))
	--确定排序
	for i=1,5 do
		self.fighterBgTable[tonumber(self.adjustOrder[i])]:stopAllActions()
		self.fighterBgTable[tonumber(self.adjustOrder[i])]:setPosition(self.fighterBgPos[i])
	end
	self:setOrderCallback()
end

function BangPaiZhanQueRenDuiYuan:setOrderCallback()
	local _fightCharId = {}
	for i=1,#self.fighterListData do
		_fightCharId[#_fightCharId + 1] = self.fighterListData[tonumber(self.adjustOrder[i])].charId
	end

	local _jsonlordId = json.encode(_fightCharId)
	ClientHttp.httpGuildBattleGroupMember(self,function(data)
			XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.adjustFighterPosSuccessToastXc)
			self.killIndex = data.killIndex
			self:resetFighterBgPos()
			self:resetIndexBtnPos()
		end,{list = _jsonlordId,index = self.killIndex},function()
			self:backToPerviousListState()
		end)
end

function  BangPaiZhanQueRenDuiYuan:setIndexBtnCallback(_idx)
	if _idx ==nil then
		return
	end
	local _killIndex = _idx - 1
	local _fightCharId = {}
	for i=1,#self.fighterListData do
		_fightCharId[#_fightCharId + 1] = self.fighterListData[i].charId
	end
	local _jsonlordId = json.encode(_fightCharId)
	ClientHttp.httpGuildBattleGroupMember(self,function(data)
			XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.adjustLordPosSuccessToastXc)
			self.killIndex = data.killIndex
			self:resetIndexBtnPos()
		end,{list = _jsonlordId,index = _killIndex})
end

function BangPaiZhanQueRenDuiYuan:getBtnNode(_path,_size)
	local _normalSp = ccui.Scale9Sprite:create(_path)
	_normalSp:setContentSize(_size)
	return _normalSp
end
--—_idx是点击之前的位置
function BangPaiZhanQueRenDuiYuan:setFighterBgNewPos(_idx,_newPos)
	if _idx == nil or _newPos == nil then
		return
	end

	-- local _startIndex = 1
	-- local _endIndex = 5
	-- local _variate = 1
	-- if isUp == true then
	-- 	_startIndex = 5
	-- 	_endIndex = 1
	-- 	_variate = -1
	-- end
	-- --移动到新的位置
	-- local _sub = 0
	-- local _newAdjust = {}
	-- for i=_startIndex,_endIndex,_variate do
	-- 	if tonumber(self.adjustOrder[i])==_idx then
	-- 		_sub = _variate
	-- 		if i == _newPos then
	-- 			return
	-- 		end
	-- 	end
	-- 	if i == _newPos then
	-- 		_newAdjust[i] = _idx
	-- 		_sub = 0
	-- 	else
	-- 		_newAdjust[i] = self.adjustOrder[i + _sub]
	-- 		if _sub~=0 then
	-- 			local _fightBg = self.fighterBgTable[tonumber(self.adjustOrder[i])]
	-- 			_fightBg:stopAllActions()
	-- 			_fightBg:runAction(cc.MoveTo:create(0.3,cc.p(self.fighterBgPos[i])))
	-- 		end
	-- 	end
	-- end

	local _newAdjust = {}
	local _oldPos = 0
	for i=1,5 do
		_newAdjust[i] = self.adjustOrder[i]
		if tonumber(self.adjustOrder[i])==_idx then
			_oldPos = i
		end
	end
	if _oldPos == 0 or _oldPos==_newPos then
		return
	end
	local _variate = 1
	if _oldPos>_newPos then
		_variate = -1
	elseif _oldPos<_newPos then
		_variate = 1
	else
		return
	end
	for i=_oldPos,_newPos,_variate do
		if i == _newPos then
			_newAdjust[i] = _idx
		else
			local _fightBg = self.fighterBgTable[tonumber(self.adjustOrder[i+_variate])]
			_fightBg.posIndex = i
			_fightBg:stopAllActions()
			-- _fightBg:setPosition(self.fighterBgPos[i])
			_fightBg:runAction(cc.MoveTo:create(0.3,cc.p(self.fighterBgPos[i])))
			_newAdjust[i] = self.adjustOrder[i + _variate]
		end
	end
	--给予新的索引
	self.adjustOrder = {}
	self.adjustOrder = _newAdjust
end

function BangPaiZhanQueRenDuiYuan:backToPerviousListState()
	-- body
	for i=1,5 do
		local _fighterBg = self.fighterBgTable[i]
		_fighterBg:setPosition(self.fighterBgPos[i])
		self.adjustOrder[i] = i
	end
end

function BangPaiZhanQueRenDuiYuan:resetFighterBgPos()
	local _newFighterBgTable = {}
	local _newFighterListData = {}
	for i=1,5 do
		_newFighterBgTable[i] = self.fighterBgTable[tonumber(self.adjustOrder[i])]
		_newFighterListData[i] = self.fighterListData[tonumber(self.adjustOrder[i])]
		_newFighterBgTable[i]:stopAllActions()
		_newFighterBgTable[i]:setPosition(self.fighterBgPos[i])
		_newFighterBgTable[i].posIndex = i
		self.adjustOrder[i] = i
	end
	self.fighterBgTable = {}
	self.fighterBgTable = _newFighterBgTable
	self.fighterListData = _newFighterListData
	--刷新位置
end
--重选队员后调用
function BangPaiZhanQueRenDuiYuan:adjustKillIndex()
	if self.killIndex>#self.fighterListData-1 then
		self.killIndex = #self.fighterListData-1
	end
end

function BangPaiZhanQueRenDuiYuan:resetIndexBtnPos()
	-- local _isChange = false
	for i=1,#self.fighterListData do
		local _fighterBg = self.fighterBgTable[i]
		if _fighterBg~=nil and _fighterBg:getChildByName("indexBtn") then
			local _indexBtn = _fighterBg:getChildByName("indexBtn")
			
			if _indexBtn.posIndex and tostring(_indexBtn.posIndex) == "Over" then
				if self.killIndex ~= i-1 then
					--创建
					_indexBtn:setStateNormal(cc.Sprite:create("res/image/guild/guildWar/guildWar_order" .. i .. ".png"))
					_indexBtn:setStateSelected(cc.Sprite:create("res/image/guild/guildWar/guildWar_order" .. i .. ".png"))
					-- _isChange = true
					_indexBtn.posIndex = i
				end
			elseif self.killIndex == i-1 and _indexBtn.posIndex and tostring(_indexBtn.posIndex) ~= "Over" then
				_indexBtn:setStateNormal(cc.Sprite:create("res/image/guild/guildWar/guildWar_orderOver.png"))
				_indexBtn:setStateSelected(cc.Sprite:create("res/image/guild/guildWar/guildWar_orderOver.png"))
				_indexBtn.posIndex = "Over"
			elseif _indexBtn.posIndex and tostring(_indexBtn.posIndex)~=tostring(i) then
				_indexBtn:setStateNormal(cc.Sprite:create("res/image/guild/guildWar/guildWar_order" .. i .. ".png"))
				_indexBtn:setStateSelected(cc.Sprite:create("res/image/guild/guildWar/guildWar_order" .. i .. ".png"))
				_indexBtn.posIndex = i
				-- _isChange = true
			end
		end
	end
end
--direction,1是向左，二是向右
function BangPaiZhanQueRenDuiYuan:arrowCallback(_direction)
	ClientHttp.httpGuildChangeBattleGroupList(self,function(data)
			self:setFighterListData(data)
			self:setCurrentFighterBgs()
		end,{direction = _direction})
end

function BangPaiZhanQueRenDuiYuan:selectedCallback(_idx)
	
	ClientHttp.httpGuildChooseGroupMemberList(self,function(data)
		-- dump(data)
			requires("src/fsgl/layer/BangPai/BangPaiZhanDuiYuan.lua"):create(data,self.fighterListData,_idx,self.killIndex)
		end)
end
function BangPaiZhanQueRenDuiYuan:notificateToRefresh(_data)
	self:setFighterListData(_data)
	self:adjustKillIndex()
	self:setCurrentFighterBgs()
end

function BangPaiZhanQueRenDuiYuan:setFighterListData(data)
	self.fighterListData = {}
	self.fighterListData = data and data.list or {}
	self.killIndex = data and data.killIndex or 0
	self.challengeState = tonumber(data.changeState) or 1
end

function BangPaiZhanQueRenDuiYuan:create(data)
	local _layer = self.new(data)
	return _layer
end

return BangPaiZhanQueRenDuiYuan