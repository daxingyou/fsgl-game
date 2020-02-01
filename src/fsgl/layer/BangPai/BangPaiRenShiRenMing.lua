-- FileName: BangPaiRenShiRenMing.lua
-- Author: wangming
-- Date: 2015-10-21
-- Purpose: 帮会退位
--[[TODO List]]

local BangPaiRenShiRenMing = class("BangPaiRenShiRenMing", function ( sParams ) 
	return requires("src/fsgl/layer/BangPai/BangPaiXinXi.lua"):create(sParams)
end)

function BangPaiRenShiRenMing:init( sParams )
	local mParams = sParams or {}
	self._params = mParams
	-- for i=1,10 do
	-- 	self._params[#self._params + 1] = clone(self._params[1])
	-- end
	local popNode = self._popNode
	local _titleBack = self._titleBack
	_titleBack:setVisible(false)
	--文字
	local wenzi = cc.Sprite:create("res/image/guild/guildTitleText_hrManager.png")
	wenzi:setPosition(popNode:getContentSize().width/2,popNode:getContentSize().height-7-15)
	popNode:addChild(wenzi)
	local _worldSize = popNode:getContentSize()

	local _tableSize = cc.size(_worldSize.width*0.98, 400)
	local _cellSize = cc.size(_tableSize.width*0.98, 64)
    local _verticalPosTable = {0.21,0.08,0.1,0.16,0.13,0.32}
    local _imgKeyTable = { "member", "level", "duty", "allContribute", "finallyLogin","operate"}
    local _fontSizes = { 20, 24, 20, 24, 20}

	local function cellSizeForTable(table, idx)
		return  _cellSize.width,_cellSize.height
    end
    local function numberOfCellsInTableView(table)
        return #self._params
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
		local data = self._params[idx+1] or {}

		local _pic = "res/image/common/scale9_bg_12.png"

	    local pCellSize = cc.size(_cellSize.width, _cellSize.height - 1)
	   	local _memberBg = BangPaiFengZhuangShuJu.createListCellBg(pCellSize)
	   	_memberBg:setAnchorPoint(cc.p(0.5, 0.5))
	   	_memberBg:setPosition(pCellSize.width*0.5, pCellSize.height*0.5)
	    _cell:addChild(_memberBg)

	    local offTime
	    if data.onlineState == 0 then
            offTime = LANGUAGE_NAMES.online       -- 在线
        else
            offTime = XTHD.getTimeStrBySecond(tonumber(data["diffTime"]))
        end
	    local _info = {data.name, data.level, LANGUAGE_GUILD_PERMISSION[data.roleId], data.totalContribution, offTime}

	    local _linePosX_ = 0 - (_tableSize.width *0.01)
	    for i=1,#_verticalPosTable do
	    	local _curWidth = _tableSize.width * _verticalPosTable[i]
	        _linePosX_ = _curWidth + _linePosX_
	    	
	        if i~=(#_verticalPosTable) then

	            -- local _verticalLine = BangPaiFengZhuangShuJu.createListVerticalLine(_cellSize.height - 2)
	            -- _verticalLine:setAnchorPoint(cc.p(0.5, 0.5))
	            -- _verticalLine:setPosition(cc.p(_linePosX_, _cellSize.height*0.5))
	            -- _memberBg:addChild(_verticalLine)

	            local _ttf = XTHDLabel:createWithSystemFont(_info[i], "Helvetica", 22)
			    _ttf:setColor(XTHD.resource.color.brown_desc)
			    _ttf:setAnchorPoint(0.5, 0.5)
			    _ttf:setPosition(_linePosX_ - _curWidth*0.5 , _cellSize.height*0.5)
				_memberBg:addChild(_ttf)
			else
				local _btn1 = XTHD.createCommonButton({
						btnColor = "write",
						btnSize = cc.size(102,46),
						isScrollView = true,
						text = LANGUAGE_BTN_KEY.tichu,
						anchor = cc.p(0, 0.5),
						pos = cc.p(_linePosX_ - _curWidth*0.5 +3, _cellSize.height*0.5),
						endCallback = function ( ... )
							self:createEixtConfirm(idx)
						end
					})
					_btn1:setScale(0.6)
				_memberBg:addChild(_btn1)

				local _btn2 = XTHD.createCommonButton({
						btnColor = "write_1",
						btnSize = cc.size(102,46),
						isScrollView = true,
						text = LANGUAGE_BTN_KEY.biandong,
						anchor = cc.p(1, 0.5),
						pos = cc.p(_linePosX_ - _curWidth*0.5 -5, _cellSize.height*0.5),
						endCallback = function ( ... )
							self:createChangeDoConfirm(idx)
						end
					})
					_btn2:setScale(0.6)
				_memberBg:addChild(_btn2)
	        end
	    end

		return _cell
	end
	
	

	local spBack = BangPaiFengZhuangShuJu.createListBg(_tableSize)
	spBack:setAnchorPoint(0, 0)
	spBack:setContentSize(_tableSize)
	spBack:setPosition((_worldSize.width - _tableSize.width)*0.5, 25)
	popNode:addChild(spBack)
	--表头的背景
	local bt_bg = cc.Sprite:create("res/image/common/scale9_bg1_25.png")
	bt_bg:setScaleY(0.75)
	bt_bg:setScaleX(0.60)
	bt_bg:setPosition(spBack:getContentSize().width/2,spBack:getContentSize().height-bt_bg:getContentSize().height/2-5)
	spBack:addChild(bt_bg)

    local _linePosY = spBack:getContentSize().height-35
    -- local _upline = BangPaiFengZhuangShuJu.createListLine(spBack:getContentSize().width - 4)
    -- _upline:setAnchorPoint(cc.p(0.5,0.5))
    -- _upline:setPosition(cc.p(spBack:getContentSize().width/2,_linePosY))
    -- spBack:addChild(_upline)

    local _linePosX = 0
	for i=1,#_verticalPosTable do
        local _curWidth = spBack:getContentSize().width*_verticalPosTable[i]
        _linePosX = _curWidth + _linePosX
        local _titleLabel = XTHDLabel:create(LANGUAGE_GUILDTITLE_KEY[_imgKeyTable[i]],18)
        _titleLabel:setColor(cc.c3b(54,55,112))
        _titleLabel:setAnchorPoint(cc.p(0.5,0.5))
        _titleLabel:setPosition(cc.p(_linePosX - _curWidth/2,_linePosY + 34/2-10))
        spBack:addChild(_titleLabel)

        if i~=(#_verticalPosTable) then
            local _lineHeight = 35
            local _verticalLine = BangPaiFengZhuangShuJu.createListVerticalLine(_lineHeight)
            -- _verticalLine:setScaleY(35/_verticalLine:getContentSize().height)
            -- ccui.Scale9Sprite:create(cc.rect(0,34,2,1),)
            _verticalLine:setAnchorPoint(cc.p(0.5,0.5))
            _verticalLine:setPosition(cc.p(_linePosX,_linePosY + _lineHeight/2-10))
            spBack:addChild(_verticalLine)
        end
    end

 	local _tableView = cc.TableView:create(cc.size(_tableSize.width, _tableSize.height - 55))
    _tableView:setPosition((_worldSize.width - _cellSize.width)*0.5, 25)
    _tableView:setBounceable(true)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    _tableView:setDelegate()
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	

	_tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData()  
    self._tableView = _tableView

    popNode:addChild(_tableView)
end

function BangPaiRenShiRenMing:createEixtConfirm( idx)
	local data = self._params[idx+1] or {}
	local show_msg = LANGUAGE_TIPS_guildDismissPlayerTextXc(tostring(data.name))
    local confirmDialog = XTHDConfirmDialog:createWithParams({
    	msg = show_msg,
    	fontSize = 22,
    	isHide = false
	})
    self:addChild(confirmDialog, 10)

    confirmDialog:setCallbackRight(function (  )
    	ClientHttp.httpGuildKickOff(self, function ( sData )
    		for k,v in pairs(self._params) do
    			if v.charId == data.charId then
	    			table.remove(self._params, k)
	    			v = nil
	    			break
    			end
    		end
    		local mGuildData = BangPaiFengZhuangShuJu.getGuildData()
    		for k,v in pairs(mGuildData.list) do
    			if v.charId == data.charId then
	    			table.remove(mGuildData.list, k)
	    			v = nil
	    			break
    			end
    		end
    		BangPaiFengZhuangShuJu.setGuildData(mGuildData)
    		self._tableView:reloadData()
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_INFO})
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
    	end, {otherId = data.charId}) -- {otherId}
        confirmDialog:removeFromParent()

    end)

    confirmDialog:setCallbackLeft(function (  )
        confirmDialog:removeFromParent()
    end)
end


function BangPaiRenShiRenMing:createChangeDoConfirm( idx )
	local pMy = 6 - gameUser.getGuildRole()
	if pMy <= 0 then
		XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildNoOperatePermissionToastXc)
		return
	end
	local partY = 60
	local pHelpLayer = XTHDPopLayer:create()
	self:addChild(pHelpLayer, 10)
	local pSize = cc.size(345,0)
	pSize.height = partY*pMy + 80
	local popNode = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_16.png")
	popNode:setContentSize(pSize)
	popNode:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
	pHelpLayer:addContent(popNode)

	for i=1, pMy do
		local _guildBg = ccui.Scale9Sprite:create(cc.rect(0,0,0,0),"res/image/common/select_bg_10.png")
		_guildBg:setContentSize(245, partY-5)
		local _btn = XTHD.createButton({
			normalNode = _guildBg,
			touchScale = 0.98,
			anchor = cc.p(0.5, 0),
			pos = cc.p(pSize.width*0.5, 47 + partY*(i-1)),
			endCallback = function ( ... )
				local data = self._params[idx+1] or {}
				local changeId = 6-(i-1)
				ClientHttp.httpGuildMemberAppoint(self, function ( sData )
					pHelpLayer:hide()
					for k,v in pairs(self._params) do
		    			if v.charId == data.charId then
		    				v.roleId = changeId
			    			break
		    			end
		    		end
		    		local mGuildData = BangPaiFengZhuangShuJu.getGuildData()
		    		for k,v in pairs(mGuildData.list) do
		    			if v.charId == data.charId then
		    				v.roleId = changeId
			    			break
		    			end
		    		end
		    		BangPaiFengZhuangShuJu.setGuildData(mGuildData)
		    		self._tableView:updateCellAtIndex(idx)
		            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
				end, {otherId = data.charId, roleId = changeId})
			end
		})
		popNode:addChild(_btn)

		local str = LANGUAGE_TIPS_guildSetPermissionTextXc(LANGUAGE_GUILD_PERMISSION[6-(i-1)])
		local _ttf = XTHDLabel:createWithSystemFont(str, "Helvetica", 20)
	    _ttf:setColor(XTHD.resource.color.brown_desc)
	    _ttf:setAnchorPoint(0, 0.5)
	    _ttf:setPosition(pSize.width*0.5 - 80 , partY*0.5)
		_btn:addChild(_ttf)
	end

end


function BangPaiRenShiRenMing:createOne( sParams ) -- {BangPaiFengZhuangShuJu}
	local params = {
		size = cc.size(821, 460),
		titleNode = cc.Sprite:create("res/image/guild/guildTitleText_hrManager.png"),
	}
	local pLay = BangPaiRenShiRenMing.new( params )
	pLay:init(sParams)
	LayerManager.addLayout(pLay,{noHide = true})
	return pLay
end

return BangPaiRenShiRenMing