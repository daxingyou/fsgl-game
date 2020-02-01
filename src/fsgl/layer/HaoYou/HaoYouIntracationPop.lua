-- FileName: HaoYouIntracationPop.lua
-- Author: wangming
-- Date: 2015-09-14
-- Purpose: 好友互动界面
--[[TODO List]]
local HaoYouIntracationPop = class( "HaoYouIntracationPop", function ( sParams )
    return requires("src/fsgl/layer/HaoYou/HaoYouBasePop.lua"):createOne(sParams)
end)

function HaoYouIntracationPop:create( sNode, sParams )
	local params = sParams or {}
	params.title = LANGUAGE_TIPS_WORDS272

	ClientHttp:httpInteractLog(sNode, function( data )
		local pLay = HaoYouIntracationPop.new(params)
		pLay:init( data )
		LayerManager.addLayout(pLay, {noHide = true})
	end)
end

function HaoYouIntracationPop:init( sData )
	
	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()

	local _datas = sData.list
	self.title:setPositionY(self:getPositionY()+25)
	self.title:setFontSize(26)
	self.title:setColor(cc.c3b(106,36,13))

	--背景框
	local bg_k = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
	bg_k:setContentSize(_worldSize.width-20,_worldSize.height-60)
	bg_k:setAnchorPoint(0,0)
	bg_k:setPosition(10,25)
	popNode:addChild(bg_k) 

	local function sortData( d1, d2 )
		return d1.sendTime > d2.sendTime
	end
	table.sort(_datas, sortData)

	if not _datas or #_datas == 0 then
		local _nameTTF = XTHDLabel:createWithParams({
	    	text = LANGUAGE_KEY_NONEMSG,--------"暂无消息",
	    	fontSize = 24,
	    	color = XTHD.resource.color.brown_desc,
	    	anchor = cc.p(0.5, 0.5),
	    	pos = cc.p(_worldSize.width*0.5 , _worldSize.height*0.5),
	    })
		popNode:addChild(_nameTTF)
		return
	end
	
	local _cellSize = cc.size(_worldSize.width*0.95, 95)
	local _tableSize = cc.size(_worldSize.width*0.95, _worldSize.height - 85)
	local function cellSizeForTable(table,idx)
		return _cellSize.width,_cellSize.height 
    end
    local function numberOfCellsInTableView(table)
        return #_datas
    end
    local function tableCellTouched(table,cell)
    	
    end

	local function tableCellAtIndex(table,idx)
		local _cell = table:dequeueCell()
	    if _cell then
	        _cell:removeAllChildren()
	    else
	        _cell = cc.TableViewCell:new()
	    end

	    local pCellSize = cc.size(_cellSize.width, _cellSize.height - 5)
		local node = cc.Node:create()
		node:setContentSize(pCellSize)
		_cell:addChild(node)
		
		-- local _di = ccui.Scale9Sprite:create("res/image/friends/friendPic_57.png")
		local _di = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
	    _di:setContentSize(pCellSize)
	    _di:setAnchorPoint(0, 0)
	    _di:setPosition(0, 0)
	    node:addChild(_di)

	    local pData = _datas[idx + 1]
	    if not pData then
	    	return
	    end

	    local dataTime = HaoYouPublic.getTimeStr(pData.sendTime) 
	    local _timeTTF = XTHDLabel:createWithSystemFont(dataTime, "Helvetica", 22)
	    _timeTTF:setColor(XTHD.resource.color.brown_desc)
	    _timeTTF:setAnchorPoint(0,0.5)
	    _timeTTF:setPosition( 20 , pCellSize.height*0.7)
		node:addChild(_timeTTF)
		
	    -- local dataInfo = {"","的\"","","\"赠送了","","朵鲜花给您"}
		local s1 = HaoYouPublic.getCampStr(pData.campId)
		local s2 = tostring(pData.charName)
		local s3 = tostring(pData.count)

		local _dataStr
		if pData.type == 1 then
			if pData.flag == 1 then   --flag是用于鲜花
				_dataStr = LANGUAGE_FORMAT_TIPS14(s1,s2,s3)------- s1 .. "的\"" .. s2 .. "\"赠送了" .. s3 .. "朵鲜花给您"
			else
				_dataStr = LANGUAGE_FORMAT_TIPS15(s3,s1,s2)-------"您赠送了" .. s3 .. "朵鲜花给" .. s1 .. "的\"" .. s2 .. "\""
			end
		elseif pData.type == 2 then
			local s4 = tonumber(pData.result) or 0
			if pData.charId == gameUser.getUserId() then
				local _s = s4 == 1 and LANGUAGE_NAMES.lose or LANGUAGE_NAMES.win-------"输了" or "赢了"
				_dataStr = LANGUAGE_FORMAT_TIPS17(s1,s2,_s)-------"您向" .. s1 .. "的\"" .. s2 .. "\"发起了切磋，您" .. _s
			elseif pData.toCharId == gameUser.getUserId() then
				local _s = s4 == 0 and LANGUAGE_NAMES.lose or LANGUAGE_NAMES.win-------"输了" or "赢了"
				_dataStr = LANGUAGE_FORMAT_TIPS16(s1,s2,_s)-----s1 .. "的\"" .. s2 .. "\"向您发起了切磋，您" .. _s
			end
		end
		
	    local _infoTTF = XTHDLabel:create(_dataStr,22 , "res/fonts/def.ttf")
	    _infoTTF:setColor(cc.c3b(54, 55, 112))
	    _infoTTF:setAnchorPoint(0,0.5)
	    _infoTTF:setPosition( 20 , pCellSize.height*0.30)
		node:addChild(_infoTTF)

		return _cell
    end

 	local _tableView = CCTableView:create(_tableSize)
    _tableView:setPosition(cc.p((_worldSize.width - _tableSize.width)*0.5, 40))
    _tableView:setBounceable(true)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    _tableView:setDelegate()
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
 
	_tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
	_tableView:reloadData() 
    popNode:addChild(_tableView)
	self._tableView = _tableView  
end

return HaoYouIntracationPop