--赏金猎人排行界面
--@author hezhitao 2015.0.20
local ShangJinLieRenRankPop = class("ShangJinLieRenRankPop",function()
    return XTHDPopLayer:create()
end)

local fontColor = cc.c3b(53,25,26)  --通用字体颜色
function ShangJinLieRenRankPop:ctor(data)
    self:init(data)
end

function ShangJinLieRenRankPop:init(data)

    self._rank_arr = {}
    self._rank_arr = data
    self._tableview = nil

    local tableview_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
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

    local title_bg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 50))
    title_bg:setPosition(tableview_bg:getContentSize().width/2,tableview_bg:getContentSize().height-10)
    tableview_bg:addChild(title_bg)

    local title_font = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_HURTRANGE,------"伤害排行",
        fontSize = 26,
        color = cc.c3b(104, 33, 11)
        })
    title_font:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2+5)
    title_bg:addChild(title_font)

    if #self._rank_arr == 0 then
        local no_rank = XTHDLabel:createWithParams({
            text = LANGUAGE_KEY_NONEHURTRANGE,-------"暂无伤害排行",
            fontSize = 22,
            color = fontColor
            })
        no_rank:setPosition(tableview_bg:getContentSize().width/2,tableview_bg:getContentSize().height/2)
        tableview_bg:addChild(no_rank)
    end

    -- tableView背景
    local rewardBg = ccui.Scale9Sprite:create()
    rewardBg:setContentSize( cc.size(515, tableview_bg:getContentSize().height-77) )
    rewardBg:setAnchorPoint( cc.p( 0.5, 0 ) )
    rewardBg:setPosition( tableview_bg:getContentSize().width*0.5, 26 )
    tableview_bg:addChild( rewardBg )

     --伤害奖励tableview
    local tableview_reward = CCTableView:create( cc.size(tableview_bg:getContentSize().width-10, tableview_bg:getContentSize().height-75) );
    tableview_reward:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL );
    tableview_reward:setPosition( cc.p(5, 25) );
    tableview_reward:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN );
    tableview_reward:setBounceable(true);
    tableview_reward:setDelegate();
    tableview_bg:addChild(tableview_reward);
    self._tableview = tableview_reward

-- tableView注册事件
    local function numberOfCellsInTableView( table )
        return  #self._rank_arr
    end
    local function cellSizeForTable( table, idx )
        return tableview_reward:getContentSize().width,85
    end
    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell();
        if cell == nil then
            local size = cc.size(tableview_reward:getContentSize().width,85 )
            cell = cc.TableViewCell:new();
            cell:setContentSize( size );
            -- cell:retain()
        else
            cell:removeAllChildren()
        end

        return self:initCellRank(cell,idx+1)
    end


    tableview_reward:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableview_reward:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableview_reward:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    tableview_reward:reloadData()
end

function ShangJinLieRenRankPop:initCellRank( cell,idx )
    local data = self._rank_arr[idx]
    if data == nil or next(data) == nil then
        return cell
    end


    -- local bg = ccui.Scale9Sprite:create( cc.rect( 12, 12, 1, 1 ), "res/image/common/scale9_bg_26.png" )--ccui.Scale9Sprite:create("res/image/common/scale9_bg_12.png")
    local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png" )
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
    --     rank_icon = cc.Sprite:create("res/image/ranklistreward/"..idx..".png")
    -- else
        rank_icon = XTHDLabel:createWithParams({
            text = idx,
            fontSize = 28,
            color = fontColor
            })
    -- end
    rank_icon:setPosition(30,bg:getContentSize().height/2)
    bg:addChild(rank_icon)

    --玩家名字
    local name = XTHDLabel:createWithParams({
        text = data.name,
        fontSize = 18,
        color = fontColor
        })
    name:setAnchorPoint(0,0.5)
    name:setPosition(68,bg:getContentSize().height/2)
    bg:addChild(name)

     --帮派图标
    local camp_icon_path = ""
    if tonumber(data["campId"]) == 1 then   --天道盟
        camp_icon_path = "res/image/common/camp_Icon_1.png"
    else                                    
        camp_icon_path = "res/image/common/camp_Icon_2.png"
    end
    local camp_icon = cc.Sprite:create(camp_icon_path)
    camp_icon:setPosition(name:getPositionX()+name:getContentSize().width+25,name:getPositionY())
    -- camp_icon:setPosition(227,name:getPositionY())
    camp_icon:setScale(0.7)
    bg:addChild(camp_icon)


    --今日伤害总量
    local hurt_txt = cc.Sprite:create("res/image/goldcopy/today_hurt_1.png")
    hurt_txt:setAnchorPoint(0,0.5)
    hurt_txt:setPosition(240,camp_icon:getPositionY())
    bg:addChild(hurt_txt)

    local today_hurt_num = self:getArtFont(data["hurt"])
    today_hurt_num:setScale(0.6)
    today_hurt_num:setAnchorPoint(0,0.5)
    today_hurt_num:setPosition(hurt_txt:getContentSize().width+hurt_txt:getPositionX(),hurt_txt:getPositionY())
    bg:addChild(today_hurt_num)



    

    return cell
end

function ShangJinLieRenRankPop:getArtFont( str )
    return XTHDLabel:createWithParams({fnt = "res/fonts/10/red6.fnt" , text = str , kerning = -2})
end

function ShangJinLieRenRankPop:create(data)
    local _layer = self.new(data)
    return _layer
end
return ShangJinLieRenRankPop