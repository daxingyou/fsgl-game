-- FileName: BangPaiZhanZhuJiang.lua
-- Author: xingchen
-- Date: 2015-10-27
-- Purpose: 选择帮派战主将
--[[TODO List]]

local BangPaiZhanZhuJiang = class("BangPaiZhanZhuJiang", function ( sParams ) 
	return requires("src/fsgl/layer/BangPai/BangPaiXinXi.lua"):create(sParams)
end)

function BangPaiZhanZhuJiang:initLayer(_data,_idx )
	local mParams = clone(BangPaiFengZhuangShuJu.getGuildData())
	self.lordListData = mParams.list or {}

	self.choseLordList = _data 
	self.exchangeIdx = _idx or 1
	local _choseLord =  {}
	for i=1,#self.choseLordList do
		_choseLord[tostring(self.choseLordList[i].charId)] = self.choseLordList[i]
	end
	--移除已经选择的
	for i=#self.lordListData,1,-1 do
		local _table = _choseLord[tostring(self.lordListData[i].charId)]
		if _table~=nil and next(_table)~=nil then
			table.remove(self.lordListData,i)
		end
	end
	table.sort(self.lordListData,function(data1,data2)
			if tonumber(data1.diffTime)==tonumber(data2.diffTime) then
				return tonumber(data1.charId) < tonumber(data2.charId)
			else
				return tonumber(data1.diffTime)<tonumber(data2.diffTime)
			end
		end)

	-- for i=1,10 do
	-- 	self._params[#self._params + 1] = clone(self._params[1])
	-- end
	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()
	if self._titleBack ~=nil then
		-- local _titleTextSp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_chooseLord.png")
		local _titleTextSp = XTHDLabel:create("选择主将",26,"res/fonts/def.ttf")
		_titleTextSp:setAnchorPoint(cc.p(0.5,0.5))
		_titleTextSp:setColor(cc.c3b(106,39,13))
		_titleTextSp:setPosition(cc.p(self._titleBack:getContentSize().width/2,self._titleBack:getContentSize().height/2))
		self._titleBack:addChild(_titleTextSp)
		local _titleDescSp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_lordprompt.png")
		_titleDescSp:setAnchorPoint(cc.p(0.5,1))
		_titleDescSp:setPosition(cc.p(self._titleBack:getContentSize().width/2,0))
		self._titleBack:addChild(_titleDescSp)
	end

	local _tableSize = cc.size(_worldSize.width*0.97, 387)
	local _cellSize = cc.size(_tableSize.width-6, 60)
    local _verticalPosTable = {158,68,146,148,108,174}
    local _imgKeyTable = { "member", "level", "power", "allContribute", "finallyLogin","operate"}
    local _fontSizes = { 20, 24, 24, 24, 20}

	local function cellSizeForTable(table, idx)
		return _cellSize.width,_cellSize.height
    end
    local function numberOfCellsInTableView(table)
        return #self.lordListData
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
		local data = self.lordListData[idx+1] or {}

		local _pic = "res/image/common/scale9_bg_12.png"

	    local pCellSize = cc.size(_cellSize.width, _cellSize.height - 1)
	   	local _memberBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
	    _memberBg:setContentSize(pCellSize)
	   	_memberBg:setAnchorPoint(cc.p(0.5, 0.5))
	   	_memberBg:setPosition(pCellSize.width*0.5, pCellSize.height*0.5)
	    _cell:addChild(_memberBg)

	    local offTime = nil
	    if data.onlineState == 0 then
            offTime = LANGUAGE_NAMES.online       -- 在线
        else
            offTime = XTHD.getTimeStrBySecond(tonumber(data["diffTime"]))
        end
	    local _info = {data.name, data.level, data.power, data.totalContribution, offTime}

	    local _linePosX = -3
	    for i=1,#_verticalPosTable do
	    	local nowX = _linePosX
	    	_linePosX = _verticalPosTable[i] + _linePosX

	        if i~=(#_verticalPosTable) then
	            -- local _verticalLine = ccui.Scale9Sprite:create(cc.rect(0,15,2,1),"res/image/guild/guildImg_tableSpacer.png")
	            -- _verticalLine:setAnchorPoint(cc.p(0.5, 0.5))
	            -- _verticalLine:setContentSize(cc.size(2, _cellSize.height - 12))
	            -- _verticalLine:setPosition(cc.p(_linePosX, _cellSize.height*0.5))
	            -- _memberBg:addChild(_verticalLine)

	            local _ttf = XTHDLabel:createWithSystemFont(_info[i], "Helvetica", _fontSizes[i])
			    _ttf:setColor(XTHD.resource.color.brown_desc)
			    _ttf:setAnchorPoint(0.5, 0.5)
			    _ttf:setPosition(nowX + _verticalPosTable[i]*0.5 , _cellSize.height*0.5)
				_memberBg:addChild(_ttf)
			else
				local _chooseBtn = XTHD.createCommonButton({
				    	btnColor = "write_1",
						btnSize = cc.size(150,46),
						isScrollView = true,
			            text = LANGUAGE_BTN_KEY.chooseLord,
						endCallback = function()
							self:chooseCallback(idx+1)
						end
					})
				_chooseBtn:setScale(0.6)
				_chooseBtn:setPosition(cc.p(nowX + _verticalPosTable[i]*0.5,_cellSize.height*0.5))
				_memberBg:addChild(_chooseBtn)
	        end
	    end

		return _cell
    end

	local spBack = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
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

 	local _tableView = CCTableView:create(cc.size(_tableSize.width-6, _tableSize.height - 44))
    _tableView:setPosition(3, 2)
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

function BangPaiZhanZhuJiang:chooseCallback(_idx)
	local _lordCharId = {}
	for i=1,#self.choseLordList do
		_lordCharId[i] = self.choseLordList[i].charId
	end
	local _newcharId = self.lordListData[tonumber(_idx)].charId
	local _newLordData = clone(self.choseLordList)
	local _index = self.exchangeIdx
	if #self.choseLordList >4 then
		_lordCharId[tonumber(_index)] = _newcharId
		_newLordData[tonumber(_index)].name = self.lordListData[tonumber(_idx)].name or ""
		_newLordData[tonumber(_index)].level = self.lordListData[tonumber(_idx)].level or 0
		_newLordData[tonumber(_index)].template = self.lordListData[tonumber(_idx)].template or 0
		_newLordData[tonumber(_index)].charId = self.lordListData[tonumber(_idx)].charId or 0
	end
	local _jsonlordId = json.encode(_lordCharId)
	ClientHttp.httpGuildSetLord(self,function()
			--刷新主将
			XTHD.dispatchEvent({name = "refreshGuildLordSp",data = {list = _newLordData} })
			XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.setLordSuccessToastXc)
			self:hideChoosePop()
		end,{groups = _jsonlordId})
end

function BangPaiZhanZhuJiang:hideChoosePop()
	self:hide()
end

function BangPaiZhanZhuJiang:create(_data,_idx)
	local params = {
		size = cc.size(821, 460),
	}
	local pLay = BangPaiZhanZhuJiang.new( params )
	pLay:initLayer(_data,_idx)
	LayerManager.addLayout(pLay,{noHide = true})
	return pLay
end

return BangPaiZhanZhuJiang