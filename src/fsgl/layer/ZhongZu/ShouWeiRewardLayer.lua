--种族守卫奖励展示界面
local ShouWeiRewardLayer = class("ShouWeiRewardLayer",function()
    return XTHD.createPopLayer({isRemoveLayout = true})
end)
function ShouWeiRewardLayer:ctor()
	self.reward_data=gameData.getDataFromCSV("CampBossRankReward")								   
    self:init()
    self:show()
end

function ShouWeiRewardLayer:init()
    local _popBgSprite = ccui.Scale9Sprite:create("res/image/worldboss/scale9_bg1_34.png")
    _popBgSprite:setContentSize(cc.size(646,504-72))
    _popBgSprite:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
    self:addContent(_popBgSprite)

    -- local title_bg = XTHD.getScaleNode("res/image/common/common_title_barBg.png", cc.size(639-10, 44))
    local title_bg = ccui.Scale9Sprite:create()
    title_bg:setContentSize(cc.size(639-10, 44))
    title_bg:setAnchorPoint(0.5,1)
    title_bg:setPosition(_popBgSprite:getContentSize().width*0.5, _popBgSprite:getContentSize().height-7)
    _popBgSprite:addChild(title_bg,1)

    local title_txt = XTHDLabel:createWithParams({
        text = "种族守卫排名奖励预览",
        fontSize = 28,
        color = cc.c3b(91,63,169),
        pos = cc.p(title_bg:getContentSize().width*0.5, title_bg:getContentSize().height*0.5-5),
    })
    title_bg:addChild(title_txt)

    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(_popBgSprite:getContentSize().width-5,_popBgSprite:getContentSize().height-5)
    _popBgSprite:addChild(close,1)

    local tableview_bg = BangPaiFengZhuangShuJu.createListBg(cc.size(_popBgSprite:getContentSize().width-18,_popBgSprite:getContentSize().height-72))
    tableview_bg:setAnchorPoint(0,0)
    tableview_bg:setPosition(9,10)
    _popBgSprite:addChild(tableview_bg)

     --tableview
    local tableview = CCTableView:create( cc.size(tableview_bg:getContentSize().width-2, tableview_bg:getContentSize().height-10) )
    tableview:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
    tableview:setPosition( cc.p(1, 5) )
    tableview:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
    tableview:setBounceable(true)
    tableview:setDelegate()
    tableview_bg:addChild(tableview)
   
    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        return  #self.reward_data
    end

    local function cellSizeForTable( table, idx )
        return tableview:getContentSize().width,105
    end

    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell();
        if cell == nil then
            cell = cc.TableViewCell:new();
            cell:setContentSize( tableview:getContentSize().width,100 )
            -- cell:retain()
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


function ShouWeiRewardLayer:initCellData( cell,idx )
    local data = self.reward_data[idx]
    if data == nil or next(data) == nil then
        return cell
    end

    -- local layer_num = {"10","二十","三十","四十","五十","六十","七十"}  
  

    local cell_bg = BangPaiFengZhuangShuJu.createListCellBg(cc.size(cell:getContentSize().width-6, 100))
    -- cell_bg:setAnchorPoint(0.5, 1)
    cell_bg:setPosition(cell:getContentSize().width*0.5, cell:getContentSize().height/2+4)
    cell:addChild(cell_bg)

    --描述信息
    local name = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_WORLDBOSS_RANKLIST_SHOWRANK(string.gsub(data["rank"],"#","-")),
        fontSize = 22,
        color = cc.c3b(77,56,62),
        anchor = cc.p(0, 0.5),
        pos = cc.p(15,cell:getContentSize().height*0.5+3)
    })
    cell:addChild(name)
   
	local table  = string.split(data["reward"],",")
    local  fall_items={}
	for k,v in ipairs(table) do
		v=string.split(v,"#")
		fall_items[#fall_items+1]=v
	end
	-- 可能掉落
	self.drop_data=fall_items
	local pos_table=SortPos:sortFromMiddle(cc.p(cell:getContentSize().width*0.5,cell:getContentSize().height*0.5 + 11), tonumber(#fall_items),80)
	for i,var in ipairs(fall_items) do
		print(i)
		local item_bg=nil
		local items_info=nil 
		items_info = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = var[2]} )
		item_bg = ItemNode:createWithParams({
    		itemId =tonumber(var[2]),--items_info["itemid"],
    		needSwallow = true,
    		_type_ =tonumber(var[1]),
    		count=tonumber(var[3])
		})
		item_bg:setScale(0.7)
		item_bg:setPosition(pos_table[i])
        item_bg:setPositionX(item_bg:getPositionX() + 35)
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
            fontSize = 22,--字体大小
            color = cc.c3b(77,56,62),
            pos = cc.p(item_bg:getContentSize().width*0.5,-2),
        })
        item_bg:addChild(item_name_label)
	end

    --图片
    -- local line = cc.Sprite:create("res/image/common/line.png")
    -- line:setPosition(cell:getContentSize().width*0.5, 4)
    -- cell:addChild(line)

    return cell

end

function ShouWeiRewardLayer:create()
    LayerManager.addShieldLayout(false, 0.1)
    local _layer = self.new()
    return _layer
end
return ShouWeiRewardLayer