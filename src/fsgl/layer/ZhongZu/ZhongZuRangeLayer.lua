--[[
排行榜页面
]]
local ZhongZuRangeLayer = class("ZhongZuRangeLayer",function( )
	return XTHDPopLayer:create()
end)

function ZhongZuRangeLayer:ctor( data,_type )
    self.__rankData = data or {}
    self._type = _type 
    if self._type == "attack" then -----种族战击杀排行
        self._titleWord = LANGUAGE_CAMP_ATTACKRANGE
    elseif self._type == "donate" then -----城市捐献排行
        self._titleWord = LANGUAGE_CAMP_TIPSWORDS41
    end 
end

function ZhongZuRangeLayer:create(data,_type)
	local rank = ZhongZuRangeLayer.new(data,_type)
	if rank then 
		rank:init()
	end 
	return rank
end

function ZhongZuRangeLayer:init( )
    ---背景
    local back = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")  
    back:setContentSize(cc.size(524,465))   
    back:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addContent(back)
    self:getContainerLayer():setClickable(false)
    ---黄色标头背景
    local titleBG = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 50))
    back:addChild(titleBG)
    titleBG:setPosition(back:getContentSize().width / 2,back:getContentSize().height - titleBG:getBoundingBox().height / 2 + 15)
    ----击杀排行榜
    local _label = XTHDLabel:createWithParams({
    	text = self._titleWord,---- "击杀排行榜",
    	fontSize = 26,
        color = cc.c3b(104, 33, 11),
        ttf = "res/fonts/def.ttf"
    })
    titleBG:addChild(_label)
    _label:setPosition(titleBG:getContentSize().width / 2,titleBG:getContentSize().height / 2+5)
    ---关闭按钮
    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    back:addChild(close)
    close:setPosition(back:getContentSize().width - 5,back:getContentSize().height - 5)

    if #self.__rankData > 0 then 
        local viewSize = cc.size(back:getContentSize().width - 20,back:getContentSize().height - titleBG:getBoundingBox().height - 20)
        self:initList(back,viewSize)
    else 
        local label = XTHDLabel:createWithParams({
            text = LANGUAGE_CAMP_TIPSWORDS27,------"当前没有排行",
            font = 20,
            color = cc.c3b(0,0,0)
        })
        back:addChild(label)
        label:setPosition(back:getContentSize().width / 2,back:getContentSize().height / 2)
    end 
end

function ZhongZuRangeLayer:initList(targ,viewSize)
	local cellSize = cc.size(viewSize.width,80)
	
	local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
        return #self.__rankData
    end

    local function tableCellTouched(table,cell)
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else 
        	cell:removeAllChildren()
        end
        local node = self:createCell(idx + 1,cellSize)
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        cell.node = node
        return cell
    end

    local tableView = CCTableView:create(viewSize)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(10,10)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    


	tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    targ:addChild(tableView)
end 

function ZhongZuRangeLayer:createCell( index,cellSize)
    local node = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
    node:setContentSize(cc.size(cellSize.width,cellSize.height - 5))    
    local serverData = self.__rankData[index]
    local _cupsPath = {
        "res/image/ranklist/rank_1.png",
        "res/image/ranklist/rank_2.png",
        "res/image/ranklist/rank_3.png",
    }    
    local _cup = nil
	local _scale = 1
    if index < 4 then 
		_scale = 1
        _cup = cc.Sprite:create(_cupsPath[index])
    else
		_scale = 0.8
        _cup = cc.Sprite:create("res/image/ranklist/rank_4.png")
        -----名将        
        local _rank = cc.Label:createWithBMFont("res/fonts/paihangbangword.fnt",index)
        _rank:setPosition(_cup:getContentSize().width / 2,_cup:getContentSize().height / 2 - 7)
        if index > 9 then 
            _rank:setScale(0.75)        
            _rank:setPosition(_cup:getContentSize().width / 2,_cup:getContentSize().height / 2 - 5)
        end 
        _cup:addChild(_rank)
        _rank:setAdditionalKerning(-2)
    end 
    node:addChild(_cup)
	_cup:setScale(_scale)
    _cup:setAnchorPoint(0,0.5)
    _cup:setPosition(15,node:getContentSize().height / 2)
    if self._type == "attack" then 
        self:createAttackCell(node,serverData,cc.p(_cup:getPositionX() + _cup:getContentSize().width + 10,_cup:getPositionY()))
    elseif self._type == "donate" then 
        self:createDonateCell(node,serverData,cc.p(_cup:getPositionX() + _cup:getContentSize().width + 10,_cup:getPositionY()))
    end 
    return node 
end

function ZhongZuRangeLayer:createAttackCell(node,data,pos)
    ------玩家名字
    local _name = XTHDLabel:createWithSystemFont(data.name,XTHD.SystemFont,18)
    _name:setColor(XTHD.resource.color.gray_desc)
    node:addChild(_name)
    _name:setAnchorPoint(0,0.5)
    _name:setPosition(pos)
    -----种族图标 
    local _campIcon = cc.Sprite:create("res/image/camp/camp_icon_small"..data.campId..".png")
	_campIcon:setScale(0.8)
    node:addChild(_campIcon)
    _campIcon:setAnchorPoint(0,0.5)
	_campIcon:setScale(0.7)
    _campIcon:setPosition(_name:getPositionX() + _name:getContentSize().width + 10,_name:getPositionY())
    ------击杀排行
    local _label = cc.Sprite:create("res/image/camp/map/camp_label9.png")
    node:addChild(_label)
    _label:setAnchorPoint(0,0.5)
    _label:setPosition(_campIcon:getPositionX() + _campIcon:getContentSize().width + 10,_campIcon:getPositionY())
    -----傎 
    local _value = cc.Label:createWithBMFont("res/fonts/wuligongji.fnt",data.killSum)
    node:addChild(_value)
    _value:setAnchorPoint(0,0.5)
    _value:setScale(0.6)
    _value:setAdditionalKerning(-2)
    _value:setPosition(_label:getPositionX() + _label:getContentSize().width + 10,_label:getPositionY())
end

function ZhongZuRangeLayer:createDonateCell(node,data,pos)
    ----名字
    local  _name = XTHDLabel:createWithSystemFont(data.name,XTHD.SystemFont,20)
    _name:setColor(XTHD.resource.color.gray_desc)
    node:addChild(_name)
    _name:setAnchorPoint(0,0.5)
    _name:setPosition(pos.x + 10,pos.y)
    ----次数
    local _times = XTHDLabel:createWithSystemFont(data.count,XTHD.SystemFont,20)
    _times:setColor(XTHD.resource.color.gray_desc)
    _times:setAnchorPoint(1,0.5)
    node:addChild(_times)
    _times:setPosition(node:getContentSize().width - 25,_name:getPositionY())
end

return ZhongZuRangeLayer