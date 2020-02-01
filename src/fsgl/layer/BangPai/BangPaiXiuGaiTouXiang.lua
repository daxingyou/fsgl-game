-- FileName: BangPaiXiuGaiTouXiang.lua
-- Author: wangming
-- Date: 2015-10-20
-- Purpose: 玩家选择帮派头像界面
--[[TODO List]]

local BangPaiXiuGaiTouXiang = class("BangPaiXiuGaiTouXiang", function ( sParams ) 
	return requires("src/fsgl/layer/BangPai/BangPaiXinXi.lua"):create(sParams)
end)

function BangPaiXiuGaiTouXiang:init( sParams )
	local mParams = sParams or {}
	self._nowSelect = sParams.id or 0
	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()

	local allDatas = gameData.getDataFromCSV("ArticleInfoSheet")
	local pTotleCellCount = math.ceil((#allDatas) * 0.2)
	if pTotleCellCount > 5 then
		pTotleCellCount = 3  --缺少图片资源，下标从0开始
	end

	local heroTableView = CCTableView:create(cc.size(_worldSize.width - 20, 300))
    heroTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    heroTableView:setPosition(cc.p(10, 35))
    heroTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    heroTableView:setBounceable(true)
    heroTableView:setDelegate()
    popNode:addChild(heroTableView)

    -- 注册事件
    local function numberOfCellsInTableView( table )
        return pTotleCellCount
    end

    local _cellSize = cc.size(_worldSize.width - 20, 100)
    local function cellSizeForTable( table, idx )
		return _cellSize.width,_cellSize.height
    end

    local function tableCellAtIndex( table, idx )
    	local _cell = table:dequeueCell()
	    if _cell then
	        _cell:removeAllChildren()
	    else
	        _cell = cc.TableViewCell:new()
	    end
	    local pCellSize = cc.size(_cellSize.width, _cellSize.height - 5)

	    for i = 1, 5 do
	    	local pIdx = idx*5 + i
	    	if allDatas[pIdx] then
	    		local isMoved = false
	    		local _guildIcon = BangPaiFengZhuangShuJu.createGuildButton(allDatas[pIdx].itemid, function ( ... )
	    			if isMoved then
	    			else
	    				self._nowSelect = allDatas[pIdx].itemid
		    			if mParams.callBack then
		    				mParams.callBack(self._nowSelect)
		    			end
		    			self:hide()
		    		end
		    		isMoved = false
				end)
				_guildIcon:setAnchorPoint(0, 0.5)
				_guildIcon:setPosition(cc.p(3 + (i-1)* 100, _cellSize.height*0.5))
				_cell:addChild(_guildIcon)
				_guildIcon:setTouchMovedCallback(function ( ... )
					isMoved = true
				end)
	    	end
	    end
        return _cell
    end
    heroTableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    heroTableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    heroTableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    heroTableView:reloadData()
end

function BangPaiXiuGaiTouXiang:createOne( sParams )
	local params = {
		size = cc.size(521, 380),
		titleNode = cc.Sprite:create("res/image/guild/guildTitleText_chooseGuildIcon.png"),
	}
	local pLay = BangPaiXiuGaiTouXiang.new( params )
	pLay:init(sParams)
	LayerManager.addLayout(pLay, {noHide = true})
	return pLay
end

return BangPaiXiuGaiTouXiang