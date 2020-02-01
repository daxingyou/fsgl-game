
--@author hezhitao 2015.0.20
local ShiLianZhiTaRankPop = class("ShiLianZhiTaRankPop",function()
    return XTHDPopLayer:create()
end)

local fontColor = cc.c3b(53,25,26)  --通用字体颜色
function ShiLianZhiTaRankPop:ctor(data)
    self:init(data)
end

function ShiLianZhiTaRankPop:init(data)

    self._rank_arr = {}
    self._rank_arr = data
    self._tableview = nil

    local tableview_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    tableview_bg:setContentSize(533,456)
    local popNode = XTHDPushButton:createWithParams({
        normalNode = tableview_bg
    })
    popNode:setTouchEndedCallback(function ()
        
    end)
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addContent(popNode)
    self.popNode = popNode
    self:show()

    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(tableview_bg:getContentSize().width,tableview_bg:getContentSize().height)
    tableview_bg:addChild(close)

    local title_bg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 60))
    title_bg:setPosition(tableview_bg:getContentSize().width/2,tableview_bg:getContentSize().height - 15)
    tableview_bg:addChild(title_bg)

    local title_font = XTHDLabel:createWithParams({
        text = LANGUAGE_FUNCNAME6,-----"试炼排行榜",
        fontSize = 26,
        color = cc.c3b(104, 33, 11)
        })
    title_font:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2)
    title_bg:addChild(title_font)

    if #self._rank_arr == 0 then
        local no_rank = XTHDLabel:createWithParams({
            text = LANGUAGE_TIPS_WORDS116,-------"暂无试炼排行",
            fontSize = 22,
            color = fontColor
            })
        no_rank:setPosition(tableview_bg:getContentSize().width/2,tableview_bg:getContentSize().height/2)
        tableview_bg:addChild(no_rank)
    end

    --试炼排行
    local tableview_rank = CCTableView:create( cc.size(tableview_bg:getContentSize().width-10, tableview_bg:getContentSize().height-75) );
    tableview_rank:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL );
    tableview_rank:setPosition( cc.p(4, 30) );
    tableview_rank:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN );
    tableview_rank:setBounceable(true);
    tableview_rank:setDelegate();
    tableview_bg:addChild(tableview_rank);

    local function numberOfCellsInTableView( table )
        return #self._rank_arr
    end
    local function cellSizeForTable( table, idx )
        return tableview_rank:getContentSize().width,85
    end
    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell();
        if cell == nil then
            local size = cc.size(tableview_rank:getContentSize().width,85 )
            cell = cc.TableViewCell:new();
            cell:setContentSize( size );
            -- cell:retain()
        else
            cell:removeAllChildren()
        end
        return self:initCellRank(cell,idx+1)
    end


    tableview_rank:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableview_rank:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableview_rank:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    tableview_rank:reloadData()
end

function ShiLianZhiTaRankPop:initCellRank( cell,idx )
    local data = self._rank_arr[idx]
    if data == nil or next(data) == nil then
        return cell
    end


    local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png" )--ccui.Scale9Sprite:create("res/image/common/scale9_bg_12.png")
    bg:setContentSize(505,80)
    bg:setPosition(cell:getContentSize().width/2,cell:getContentSize().height/2)
    cell:addChild(bg)

    -- 分隔线
    -- local splitCellLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
    -- splitCellLine:setContentSize( bg:getContentSize().width, 2 )
    -- splitCellLine:setAnchorPoint( cc.p( 0.5, 0 ) )
    -- splitCellLine:setPosition( cell:getContentSize().width*0.5, -2 )
    -- cell:addChild( splitCellLine )

    --排名
    local rank_icon = nil
    -- if idx <= 3 then
        -- rank_icon = cc.Sprite:create("res/image/ranklistreward/"..idx..".png")
    -- else
        rank_icon = cc.Sprite:create("res/image/ranklist/rank_4.png")
        -- XTHDLabel:createWithParams({
        --     text = idx,
        --     fontSize = 28,
        --     color = fontColor
        --     })
        rank_icon:setScale(0.8)
        local rank_idx=cc.Label:createWithBMFont("res/fonts/paihangbangword.fnt",idx)
        rank_idx:setPosition(rank_icon:getContentSize().width/2,rank_icon:getContentSize().height/2 - 7)
        rank_icon:addChild(rank_idx)
    -- end
    rank_icon:setPosition(40,bg:getContentSize().height/2)
    bg:addChild(rank_icon)

    

    --帮派图标
    local camp_icon_path = ""
    if tonumber(data["campId"]) == 1 then   --天道盟
        camp_icon_path = "res/image/common/camp_Icon_1.png"
    else                                    
        camp_icon_path = "res/image/common/camp_Icon_2.png"
    end
    local camp_icon = cc.Sprite:create(camp_icon_path)
    camp_icon:setAnchorPoint(cc.p(0,0.5))
    -- camp_icon:setPosition(name:getPositionX()+name:getContentSize().width+20,name:getPositionY())
    camp_icon:setPosition(cc.p(77,bg:getContentSize().height/2))
    -- camp_icon:setPosition(227,name:getPositionY())
    camp_icon:setScale(0.7)
    bg:addChild(camp_icon)

    --玩家名字
    local name = XTHDLabel:createWithParams({
        text = data["name"],
        fontSize = 18,
        color = fontColor
        })
    name:setAnchorPoint(0,0.5)
    name:setPosition(camp_icon:getBoundingBox().x+camp_icon:getBoundingBox().width+3,bg:getContentSize().height/2)
    bg:addChild(name)


    --今日伤害总量
    local hurt_txt = cc.Sprite:create("res/image/jaditecopy/max_layer_1.png")
    hurt_txt:setAnchorPoint(0,0.5)
    hurt_txt:setPosition(260,camp_icon:getPositionY())
    bg:addChild(hurt_txt)

    local today_hurt_num = self:getArtFont(data["layer"])
    today_hurt_num:setScale(0.6)
    today_hurt_num:setAnchorPoint(0,0.5)
    today_hurt_num:setPosition(hurt_txt:getContentSize().width+hurt_txt:getPositionX()+10,hurt_txt:getPositionY()+2)
    bg:addChild(today_hurt_num)

    return cell
end

function ShiLianZhiTaRankPop:getArtFont( str )
    return XTHDLabel:createWithParams({fnt = "res/fonts/10/red6.fnt" , text = str , kerning = -2})
end

function ShiLianZhiTaRankPop:create(data)
    local _layer = self.new(data)
    return _layer
end
return ShiLianZhiTaRankPop