--世界boss推送弹窗1 huangjunjian XiongShouLaiXiHatredPop
local XiongShouLaiXiHatredPop = class("XiongShouLaiXiHatredPop",function(sParams)
    return XTHD.createPopLayer(sParams)
    end)
local fontColor = cc.c3b(53,25,26)  --通用字体颜色
function XiongShouLaiXiHatredPop:ctor(sParams)
	self.reward_data=gameData.getDataFromCSV("MonsterAttackAward")								   
	-- dump(gameUser._worldBossOver_data,"hahah")
    self:init()
end

function XiongShouLaiXiHatredPop:init()
    local popNode = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    local _bgSize = cc.size(600, 504-72)
    popNode:setContentSize(_bgSize)
    popNode:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
    self:addContent(popNode)

    local title_bg = XTHD.createSprite("res/image/worldboss/title.png")
    title_bg:setAnchorPoint(0.5, 0)
    title_bg:setPosition(_bgSize.width*0.5, _bgSize.height-25)
    popNode:addChild(title_bg)

    local tishi_label = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS238,
        color = cc.c3b(102, 104, 96),
        anchor = cc.p(0.5, 1),
        pos = cc.p(_bgSize.width*0.5, _bgSize.height-28),
        size = 18,
    })
    popNode:addChild(tishi_label)

    local rank= gameUser._worldBossOver_data.rank or LANGUAGE_KEY_OUTOFRANGE
    --我的排行
    local rankSp = cc.Sprite:create("res/image/goldcopy/wodepaihang.png")
    rankSp:setAnchorPoint(0.5, 0)
    rankSp:setPosition(_bgSize.width/2, 10)
    rankSp:setScale(0.8)
    popNode:addChild(rankSp)
    local rankNum
    if type(rank) == "number" then
        rankNum = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt", rank)
        rankNum:setScale(0.7)
        rankNum:setAnchorPoint(0,0)
        rankNum:setPosition(rankSp:getContentSize().width/2+5+rankSp:getPositionX(),rankSp:getPositionY())
    else
        rankNum = XTHDLabel:createWithParams({
            text = rank,
            fontSize = 20,
            color = XTHD.resource.color.brown_desc,
            anchor = cc.p(0, 0),
            pos = cc.p(rankSp:getContentSize().width/2+5+rankSp:getPositionX(),rankSp:getPositionY())
        })
    end
    popNode:addChild(rankNum)
    rankSp:setPositionX(_bgSize.width/2-rankNum:getContentSize().width/2)
    rankNum:setPositionX(rankSp:getContentSize().width/2+5+rankSp:getPositionX())


    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(_bgSize.width-5,_bgSize.height-5)
    popNode:addChild(close)

    local tableview_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
    tableview_bg:setContentSize(_bgSize.width-18,_bgSize.height-70-30)
    tableview_bg:setAnchorPoint(0,0)
    tableview_bg:setPosition(9,39)
    popNode:addChild(tableview_bg)

    local _viewCell = cc.size(tableview_bg:getContentSize().width-6, tableview_bg:getContentSize().height-10)
     --tableview
    local tableview = CCTableView:create(_viewCell)
    tableview:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
    tableview:setPosition(cc.p(3, 5))
    tableview:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
    tableview:setBounceable(true)
    tableview:setDelegate()
    tableview_bg:addChild(tableview)
   
    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        return  #self.reward_data
    end

    local function cellSizeForTable( table, idx )
        return _viewCell.width,120
    end

    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
            cell:setContentSize(_viewCell.width, 120)
        else
            cell:removeAllChildren()
        end
        return self:initCellData(cell,idx+1)
    end

    tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    tableview:reloadData()
end


function XiongShouLaiXiHatredPop:initCellData( cell,idx )
    local data = self.reward_data[idx]
    if data == nil or next(data) == nil then
        return cell
    end

    -- local layer_num = {"10","二十","三十","四十","五十","六十","七十"}  
  

    local cell_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
    cell_bg:setContentSize(cell:getContentSize().width - 6, cell:getContentSize().height - 5)
    cell_bg:setPosition(cell:getContentSize().width*0.5, cell:getContentSize().height*0.5)
    cell:addChild(cell_bg)

    --排名
    local rank_icon = nil
    if idx <= 3 then
        rank_icon = cc.Sprite:create("res/image/ranklistreward/"..idx..".png")
    else
        rank_icon = XTHDLabel:createWithParams({
            text = idx,
            fontSize = 28,
            color = fontColor
            })
    end
    rank_icon:setPosition(45,cell_bg:getContentSize().height/2)
    cell_bg:addChild(rank_icon)

    --描述信息
    if idx ~= 1 then
        local _string = LANGUAGE_KEY_WORLDBOSS_RANKLIST_SHOWRANK(string.gsub(data["rank"],"#","-"))
        local rank_label = XTHDLabel:createWithParams({
            text = _string,
            fontSize = 18,
            color = fontColor,
            anchor = cc.p(0, 0.5),
            pos = cc.p(110, cell:getContentSize().height/2)
        })
        cell:addChild(rank_label)
    end
   
	local table  = string.split(data["reward"],",")
    local  fall_items={}
	for k,v in ipairs(table) do
		v=string.split(v,"#")
		fall_items[#fall_items+1]=v
	end
    --
    if idx==1 then
        local name= gameUser._worldBossOver_data.name or ""
        local campid= gameUser._worldBossOver_data.campid or 1
        local _string = LANGUAGE_KEY_WORLDBOSS_RANKLIST_SHOWNAME(campid, name)
        -- if gameUser._worldBossOver_data.campid and gameUser._worldBossOver_data.campid==1 then
        --     campid="光明谷"
        -- elseif  gameUser._worldBossOver_data.campid==2 then 
        --     campid="暗月岭"
        -- end 
        -- name:setString("")
        local one_sp=cc.Sprite:create("res/image/worldboss/rank_frist.png")
        one_sp:setAnchorPoint(0,0.5)
        one_sp:setPosition(110,cell:getContentSize().height/2)
        cell:addChild(one_sp)
        local camp = XTHDLabel:createWithParams({
            text = _string,
            fontSize = 18,
            color = fontColor,
            anchor = cc.p(0, 0.5),
            pos = cc.p(110+one_sp:getContentSize().width+25, cell:getContentSize().height-20),
        })
        cell:addChild(camp)

    end
	-- 可能掉落
	self.drop_data=fall_items
	local pos_table=SortPos:sortFromMiddle( cc.p(cell:getContentSize().width/2 + 65,25), tonumber(#fall_items),60)
	for i,var in ipairs(fall_items) do
		local item_bg=nil
		local items_info=nil 
		items_info = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = var[2]} )
		item_bg = ItemNode:createWithParams({
		itemId =tonumber(var[2]),--items_info["itemid"],
		needSwallow = true,
		_type_ =tonumber(var[1]),
		count=tonumber(var[3])
		})
		item_bg:setScale(0.6)
        item_bg:setAnchorPoint(0.5,0)
        item_bg:setPosition(pos_table[i])
        item_bg:setPositionX(item_bg:getPositionX() + 25)
		cell:addChild(item_bg)
		if tonumber(var[1])==10 then--神石
			items_info["name"]=LANGUAGE_TABLE_RESOURCENAME[10]
		elseif tonumber(var[1])==2 then--银两
			items_info["name"]=LANGUAGE_TABLE_RESOURCENAME[2]
		elseif tonumber(var[1])==3 then--元宝
			items_info["name"]=LANGUAGE_TABLE_RESOURCENAME[3]
		elseif tonumber(var[1])==6 then--翡翠
			items_info["name"]=LANGUAGE_TABLE_RESOURCENAME[6]
		elseif tonumber(var[1])==50 then--英雄	
			items_info["name"]=gameData.getDataFromCSV("GeneralInfoList", {["heroid"]=tonumber(var[2])})["name"] or ""
		end 
		local item_name_label = XTHDLabel:createWithParams({
            text = items_info["name"],
            anchor=cc.p(0.5,1),
            fontSize = 18,--字体大小
            color = cc.c3b(74,34,34),
            pos = cc.p(item_bg:getContentSize().width/2,-2),
        })
        item_bg:addChild(item_name_label)
	end

    --图片
    -- local line = cc.Sprite:create("res/image/common/line.png")
    -- line:setPosition(cell:getContentSize().width/2,0)
    -- cell:addChild(line)

    return cell

end

function XiongShouLaiXiHatredPop:create(sParams)
    local _layer = self.new(sParams)
    return _layer
end
return XiongShouLaiXiHatredPop