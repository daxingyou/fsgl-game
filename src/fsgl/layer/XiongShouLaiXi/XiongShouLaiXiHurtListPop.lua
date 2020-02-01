-- FileName: XiongShouLaiXiHurtListPop.lua
-- Author: wangming
-- Date: 2015-11-04
-- Purpose: 世界boss未开启时的伤害列表界面
--[[TODO List]]

local XiongShouLaiXiHurtListPop = class("XiongShouLaiXiHurtListPop", function(sParams)
	return requires("src/fsgl/layer/HaoYou/HaoYouBasePop.lua"):createOne(sParams)
end)

function XiongShouLaiXiHurtListPop:initUI( listData )
    local popNode = self._popNode
    local title = self.title
    title:setPositionY(title:getPositionY()+20)
    title:setColor(cc.c3b(104, 33, 11))
    local _worldSize = popNode:getContentSize()
    local _datas = listData or {}
    if #_datas == 0 then
        local _nameTTF = XTHDLabel:createWithParams({
            text = LANGUAGE_KEY_NONEHURTLIST,--------"暂无消息",
            fontSize = 24,
            color = XTHD.resource.color.brown_desc,
            anchor = cc.p(0.5, 0.5),
            pos = cc.p(_worldSize.width*0.5 , _worldSize.height*0.5),
        })
        popNode:addChild(_nameTTF)
        return
    end
   

    local _cellSize = cc.size(_worldSize.width*0.95, 80)
    local _tableSize = cc.size(_worldSize.width*0.95, _worldSize.height - 65)
    local function cellSizeForTable(table,idx)
        return _cellSize.width,_cellSize.height
    end

    local function _showFriend( _charId )
        if not _charId then
            return
        end
        if _charId == gameUser.getUserId() then
            return
        end
        local function showFirendInfo( ... )
            HaoYouPublic.showFirendInfo(_charId, self)
        end
        local pData = HaoYouPublic.getFriendData()
        if not pData then
            HaoYouPublic.httpGetFriendData( self, showFirendInfo)
        else
            showFirendInfo()
        end 
    end
    local function numberOfCellsInTableView(table)
        return #_datas
    end
    local function tableCellTouched(table,cell)
        local _charId = cell._charId
        _showFriend(_charId)
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

        local _di = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
        _di:setContentSize(pCellSize)
        _di:setAnchorPoint(0, 0)
        _di:setPosition(0, 0)
        node:addChild(_di)

        local index = idx + 1
        local pData = _datas[index]
        if not pData then
            return
        end
        _cell._charId = pData.charId
        local rank_id
        if index >= 1 and index <= 3 then
            rank_id = cc.Sprite:create("res/image/worldboss/unOpen" .. index .. ".png")
        else
            rank_id = XTHDLabel:createWithParams({
                text = index, 
                color = cc.c3b(119, 89, 68),
                size = 22,
            })
        end
        rank_id:setPosition(35, pCellSize.height*0.5)
        _di:addChild(rank_id)
        local icon_mum = tonumber(pData.campId) or 1
        icon_mum = icon_mum == 0 and 1 or icon_mum
        local icon1 = XTHD.createSprite("res/image/common/camp_Icon_"..icon_mum..".png")
        icon1:setAnchorPoint(0, 0)
        icon1:setPosition(70, pCellSize.height*0.5-5)   
        icon1:setScale(0.55) 
        _di:addChild(icon1)

        local name = XTHDLabel:createWithParams({
            text = pData.name,
            size = 22,
            anchor = cc.p(0, 0),
            color = cc.c3b(119, 89, 68),--cc.c3b(200, 61, 12),
            pos = cc.p(icon1:getPositionX() + icon1:getContentSize().width - 10, pCellSize.height*0.5)
        })
        name:setAnchorPoint(0,0)
        name:setPosition(icon1:getPositionX() + icon1:getContentSize().width - 10, pCellSize.height*0.5)
        _di:addChild(name)

        --伤害
        local hurt = XTHDLabel:createWithParams({
            text = LANGUAGE_KEY_WORLDBOSS_TODAYATK(pData.hurt),
            anchor = cc.p(0, 1),
            color = cc.c3b(200, 61, 12),
            pos = cc.p(70, pCellSize.height*0.5 - 5),
            size = 22,
        })
        _di:addChild(hurt)

        return _cell
    end

    local _tableView = CCTableView:create(_tableSize)
    _tableView:setPosition(cc.p((_worldSize.width - _tableSize.width)*0.5, 18))
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

function XiongShouLaiXiHurtListPop:create( listData )
    LayerManager.addShieldLayout()
    local params = {title = "伤害榜", isShowBlack = false}
    local lay = XiongShouLaiXiHurtListPop.new(params)
    lay:initUI(listData)
    return lay
end

return XiongShouLaiXiHurtListPop