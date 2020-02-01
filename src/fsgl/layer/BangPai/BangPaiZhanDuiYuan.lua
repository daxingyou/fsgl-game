-- FileName: BangPaiZhanDuiYuan.lua
-- Author: xingchen
-- Date: 2015-10-27
-- Purpose: 选择帮派战队员
--[[TODO List]]

local BangPaiZhanDuiYuan = class("BangPaiZhanDuiYuan", function ( sParams )
	return requires("src/fsgl/layer/BangPai/BangPaiXinXi.lua"):create(sParams)
end)

function BangPaiZhanDuiYuan:initLayer(_data,_selectedData,_idx,_killpos )
	self.fightListData = _data.list or {}
	self.choseFightList = _selectedData or {}
	local _currentData = self.choseFightList[tonumber(_idx)] or {}
	if next(_currentData)~=nil then
		_currentData.isSelected = 1
		self.fightListData[#self.fightListData + 1] = _currentData
	end
	table.sort(self.fightListData,function(data1,data2)
			if tonumber(data1.power)==tonumber(data2.power) then
				return tonumber(data1.charId)<tonumber(data2.charId)
			else
				return tonumber(data1.power)>tonumber(data2.power)
			end
		end)
	self.exchangeIdx = _idx or 1
	self.killIdx = _killpos or 0

	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()
	if self._titleBack ~=nil then
		-- local _titleTextSp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_chooseMember.png")
		local _titleTextSp = XTHDLabel:create("选择帮派战成员",26,"res/fonts/def.ttf")
		_titleTextSp:setAnchorPoint(cc.p(0.5,0.5))
		_titleTextSp:setColor(cc.c3b(106,36,13))
		_titleTextSp:setPosition(cc.p(self._titleBack:getContentSize().width/2,self._titleBack:getContentSize().height/2))
		self._titleBack:addChild(_titleTextSp)
	end

	local _tableSize = cc.size(_worldSize.width*0.97, 387)
	local _cellSize = cc.size(_tableSize.width-6, 65)
    local _verticalPosTable = {154,70,145,245,175}
    local _imgKeyTable = { "member", "level", "power", "state","operate"}
    local _fontSizes = { 20, 24, 24, 20, 20}

	local function cellSizeForTable(table, idx)
		return _cellSize.width,_cellSize.height
    end
    local function numberOfCellsInTableView(table)
        return #self.fightListData
    end
  
	local function tableCellAtIndex(table, idx)
		local _cell = table:dequeueCell()
	    if _cell then
	        _cell:removeAllChildren()
	    else
	        _cell = cc.TableViewCell:new()
			_cell:setContentSize(_cellSize.width,_cellSize.height)
	    end
	    _cell._idx = idx
		local data = self.fightListData[idx+1] or {}

		local _pic = "res/image/common/scale9_bg_12.png"

	    local pCellSize = cc.size(_cellSize.width - 40, 65)
		local _memberBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
		--_memberBg:setScaleY(0.5)   
	    _memberBg:setContentSize(pCellSize.width,pCellSize.height)
	   	_memberBg:setAnchorPoint(cc.p(0.5, 0.5))
	   	_memberBg:setPosition(pCellSize.width*0.5 + 15, pCellSize.height*0.5)
	    _cell:addChild(_memberBg)

	    local offTime = nil
	    if data.onlineState == 0 then
            offTime = LANGUAGE_NAMES.online       -- 在线
        else
            offTime = XTHD.getTimeStrBySecond(tonumber(data["diffTime"]))
        end
	    local _info = {data.name, data.level, data.power, data.isSelected or 0, offTime}

	    local _linePosX = 10
	    for i=1,#_verticalPosTable do
	    	local nowX = _linePosX
	    	_linePosX = _verticalPosTable[i] + _linePosX

	        if i~=(#_verticalPosTable) then
	            -- local _verticalLine = ccui.Scale9Sprite:create(cc.rect(0,15,2,1),"res/image/guild/guildImg_tableSpacer.png")
	            -- _verticalLine:setAnchorPoint(cc.p(0.5, 0.5))
	            -- _verticalLine:setContentSize(cc.size(2, _cellSize.height - 12))
	            -- _verticalLine:setPosition(cc.p(_linePosX, _cellSize.height*0.5))
	            -- _memberBg:addChild(_verticalLine)

	            local _infoStr = _info[i]
	            local _infoColor = XTHD.resource.color.brown_desc
	            if i==4 then
	            	if _info[i] ~=nil and tonumber(_info[i])==1 then
	            		_infoStr = LANGUAGE_KEY_GUILDWAR_TEXT.beSelectedTextXc
	            		_infoColor = BangPaiFengZhuangShuJu.getTextColor("hongse")
	            	else
	            		_infoStr = LANGUAGE_KEY_GUILDWAR_TEXT.noJoinTextXc
	            		_infoColor = BangPaiFengZhuangShuJu.getTextColor("shenhese")
	            	end
	            end
	            local _ttf = XTHDLabel:createWithSystemFont(_infoStr, "Helvetica", _fontSizes[i])
			    _ttf:setColor(_infoColor)
			    _ttf:setAnchorPoint(0.5, 0.5)
			    _ttf:setPosition(nowX + _verticalPosTable[i]*0.5 , _cellSize.height*0.5)
				_cell:addChild(_ttf)
			else
				local _imgkey = "write_1"
				local _textKey = LANGUAGE_BTN_KEY.chooseWar
				local _isJoin = true
				if data.isSelected ~=nil and tonumber(data.isSelected)==1 then
					_imgkey = "write"
					_textKey = LANGUAGE_BTN_KEY.cancelQuali
					_isJoin = false
				else
					_imgkey = "write_1"
					_textKey = LANGUAGE_BTN_KEY.chooseWar
					_isJoin = true
				end
				-- local normalsp = ccui.Scale9Sprite:create(cc.rect(50,0,30,49),"res/image/common/btn/btn_" .. _imgkey .. "_small_normal.png")
				-- normalsp:setContentSize(cc.size(150,49))
				-- local selectedsp = ccui.Scale9Sprite:create(cc.rect(50,0,30,49),"res/image/common/btn/btn_" .. _imgkey .. "_small_selected.png")
				-- selectedsp:setContentSize(cc.size(150,49))
				local _chooseBtn = XTHD.createCommonButton({
						btnColor = _imgkey,
						btnSize = cc.size(150,46),
						isScrollView = true,
						text = _textKey,
						endCallback = function()
							self:chooseCallback(idx+1,_isJoin)
						end
					})
					-- _chooseBtn:setScale(0.8)
				-- XTHD.createButton({
				-- 		normalNode = normalsp,
				-- 		selectedNode = selectedsp,
				-- 		label = XTHD.resource.getButtonImgTxt(_textKey),
				-- 		touchSize = cc.size(120,40),
				-- 		endCallback = function()
				-- 			self:chooseCallback(idx+1,_isJoin)
				-- 		end
				-- 	})
				_chooseBtn:setScale(0.6)
				_chooseBtn:setPosition(cc.p(nowX + _verticalPosTable[i]*0.5 - 10,_cellSize.height*0.5))
				_cell:addChild(_chooseBtn)
	        end
	    end

		return _cell
    end

	local spBack = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/scale9_bg2_34.png")
	spBack:setAnchorPoint(0, 0)
	spBack:setContentSize(_tableSize.width,_tableSize.height-10)
	spBack:setPosition((_worldSize.width - _tableSize.width)*0.5, 20)
	popNode:addChild(spBack)

	local _linePosY = _tableSize.height - 32
    -- local _upline = ccui.Scale9Sprite:create(cc.rect(4,0,1,2),"res/image/guild/guild_horizontalLine.png")
    -- _upline:setAnchorPoint(cc.p(0.5,1))
    -- _upline:setContentSize(cc.size(_tableSize.width,2))
    -- _upline:setPosition(cc.p(_tableSize.width*0.5,_linePosY))
    -- spBack:addChild(_upline)

    local _linePosX = 0
    for i=1,#_verticalPosTable do
        _linePosX = _verticalPosTable[i] + _linePosX

        local _titleSp = cc.Sprite:create("res/image/guild/guildText_" .. _imgKeyTable[i] .. ".png")
        _titleSp:setAnchorPoint(cc.p(0.5,0.5))
        _titleSp:setPosition(cc.p(_linePosX - _verticalPosTable[i]*0.5,_linePosY + 30*0.5-10))
        spBack:addChild(_titleSp)

        if i~=(#_verticalPosTable) then
            -- local _verticalLine = ccui.Scale9Sprite:create(cc.rect(0,15,2,1),"res/image/guild/guildImg_tableSpacer.png")
            -- _verticalLine:setAnchorPoint(cc.p(0.5, 0))
            -- _verticalLine:setContentSize(cc.size(2, 30))
            -- _verticalLine:setPosition(cc.p(_linePosX,_linePosY + 2))
            -- spBack:addChild(_verticalLine)
        end
    end

    if #self.fightListData<1 then
		local _noPromptLabel = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.noCanOperateMemberTextXc,26)
		_noPromptLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
		_noPromptLabel:setPosition(cc.p(spBack:getContentSize().width/2,spBack:getContentSize().height/2))
		spBack:addChild(_noPromptLabel)
	end

 	local _tableView = CCTableView:create(cc.size(_tableSize.width-6, _tableSize.height - 34))
    _tableView:setPosition(3, -3)
    _tableView:setBounceable(true)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    _tableView:setDelegate()
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
 
	_tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData()  
    self._tableView = _tableView

    spBack:addChild(_tableView)
end

function BangPaiZhanDuiYuan:chooseCallback(_idx,_isJoin)
	local _fightCharId = {}
	for i=1,#self.choseFightList do
		_fightCharId[i] = self.choseFightList[i].charId
	end
	local _newcharId = self.fightListData[tonumber(_idx)].charId
	local _choseFightData = clone(self.choseFightList)
	--选为参战
	local _index = tonumber(self.exchangeIdx)
	if _isJoin~=nil and _isJoin==true then
		--如果当前位置有队员，替换掉，否则在最后一个添加上
		if _fightCharId[_index]~=nil then
			_fightCharId[_index] = _newcharId
		else
			_index = #_fightCharId + 1
			_fightCharId[_index] = _newcharId
		end
		_choseFightData[_index] = {}
	else 		--取消资格
		--如果当前位置有队员，移除掉
		if _fightCharId[_index]~=nil then
			table.remove(_fightCharId,_index)
			table.remove(_choseFightData,_index)
		end
	end
	if self.killIdx > #_choseFightData-1 then
		self.killIdx = #_choseFightData - 1
	end
	local _jsonlordId = json.encode(_fightCharId)
	ClientHttp.httpGuildBattleGroupMember(self,function(data)
			--刷新副将
			if data.addChar~=nil and next(data.addChar)~=nil then
				_choseFightData[_index] = data.addChar
			end
			XTHD.dispatchEvent({name = "refreshGuildFightSp",data = {list = _choseFightData,killIndex = data.killIndex} })
			XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.setFighterSuccessTextXc)
			self:hideChoosePop()
		end,{list = _jsonlordId,index = self.killIdx})
end

function BangPaiZhanDuiYuan:hideChoosePop()
	self:hide()
end

function BangPaiZhanDuiYuan:create(_data,_selectedData,_idx,_killpos)
	local params = {
		size = cc.size(821, 460),
		-- titleNode = cc.Sprite:create("res/image/guild/guildTitleText_hrManager.png"),
	}
	local pLay = BangPaiZhanDuiYuan.new( params )
	pLay:initLayer(_data,_selectedData,_idx,_killpos)
	LayerManager.addLayout(pLay,{noHide = true})
	return pLay
end

return BangPaiZhanDuiYuan