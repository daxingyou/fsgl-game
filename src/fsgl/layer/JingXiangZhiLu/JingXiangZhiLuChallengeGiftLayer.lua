--[[
单挑之王福利界面
]]

local JingXiangZhiLuChallengeGiftLayer = class("JingXiangZhiLuChallengeGiftLayer",function( )
	return XTHDPopLayer:create()
end)

local fontColor = cc.c3b(53,25,26)  --通用字体颜色

function JingXiangZhiLuChallengeGiftLayer:ctor(data,_type,curLevel,callback)
	self._serverData = data
	self._battleType = _type
    self._curLevel = curLevel
    self._callBack = callback
    self._allReward = gameData.getDataFromCSV("OneVsOneReward")
    self._showData = {}
    self:initShowData()
end

function JingXiangZhiLuChallengeGiftLayer:onCleanup( )	
   
end

function JingXiangZhiLuChallengeGiftLayer:initShowData()
	self._showData = {}
	local tempData = {}
	for i = 1,#self._allReward do
        if self._allReward[i].group == self._battleType then
            table.insert(tempData,self._allReward[i])
        end
	end
    for i = 1,#self._serverData.list do
        tempData[i].state = self._serverData.list[i].state
    end
    self._showData = tempData
--    print("封装好的福利展示数据为：")
--    print_r(self._showData)
end

function JingXiangZhiLuChallengeGiftLayer:create(data,_type,curLevel,callback)
	local layer = JingXiangZhiLuChallengeGiftLayer.new(data,_type,curLevel,callback)
	if layer then 
		layer:init()
	end
	return layer
end

function JingXiangZhiLuChallengeGiftLayer:init()
	self:initUI()
end

function JingXiangZhiLuChallengeGiftLayer:initUI()

	local _popBgSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    _popBgSprite:setContentSize(cc.size(646,504-72))
    local popNode = XTHDPushButton:createWithParams({
                        normalNode = _popBgSprite
                    })
    popNode:setTouchEndedCallback(function ()
        
    end)
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addContent(popNode)
    self.popNode = popNode
    self:show()

    -- local title_bg = XTHD.getScaleNode("res/image/common/common_title_barBg.png", cc.size(_popBgSprite:getContentSize().width - 7*2, 44))
    local title_bg = ccui.Scale9Sprite:create()
    title_bg:setContentSize(cc.size(_popBgSprite:getContentSize().width - 7*2, 44))
    title_bg:setAnchorPoint(0.5,1)
    title_bg:setPosition(_popBgSprite:getContentSize().width/2,_popBgSprite:getContentSize().height-7)
    _popBgSprite:addChild(title_bg,1)

    local title_txt = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS117,-----"满足条件即可领取以下奖励,每天可以领取1次",
        fontSize = 22,
        color = fontColor
        })
    title_txt:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2)
    title_bg:addChild(title_txt)

    local close = XTHD.createBtnClose(function()
    	if self._callBack then
            self._callBack()
    	end
        self:hide()
    end)
    close:setPosition(_popBgSprite:getContentSize().width-5, _popBgSprite:getContentSize().height-5)
    _popBgSprite:addChild(close,2)

    local tableview_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")--common_opacity.png
    tableview_bg:setContentSize(_popBgSprite:getContentSize().width-30,_popBgSprite:getContentSize().height-72)
    tableview_bg:setAnchorPoint(0,0)
    tableview_bg:setPosition(14.5,30)
    _popBgSprite:addChild(tableview_bg)

     --tableview
    local tableview = cc.TableView:create( cc.size(tableview_bg:getContentSize().width-4, tableview_bg:getContentSize().height-10) );
    tableview:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL );
    tableview:setPosition( cc.p(2, 5) );
    tableview:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN );
    tableview:setBounceable(true);
--    tableview:setAutoAlign(false)
    tableview:setDelegate();
    tableview_bg:addChild(tableview);
   
    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        return  #self._showData
    end

    local function cellSizeForTable( table, idx )
        return tableview:getContentSize().width, 100
    end

    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell();
        if cell == nil then
            cell = cc.TableViewCell:new();
            cell:setContentSize( tableview:getContentSize().width,100 );
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
    self._tableView = tableview

end

function JingXiangZhiLuChallengeGiftLayer:initCellData( cell,idx )
	local data = self._showData[idx]
    if data == nil or next(data) == nil then
        return cell
    end

    local cell_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    cell_bg:setContentSize(cell:getContentSize().width-6,90)
    cell_bg:setPosition(cell:getContentSize().width/2,cell:getContentSize().height/2+5)
    cell:addChild(cell_bg)

    --描述信息
    local name = XTHDLabel:createWithParams({
        text = data["needs"],
        fontSize = 18,
        color = fontColor
        })
    name:setAnchorPoint(0,0.5)
    name:setPosition(20,cell:getContentSize().height/2)
    cell:addChild(name)

    local list_data = self:dealRewardDataToShow(idx)
    for i=1,#list_data do
        local item_reward = ItemNode:createWithParams({
                    itemId = list_data[i]["itemId"],
                    _type_ = list_data[i]["_type_"],
                    count = tonumber(list_data[i]["count"]) ,
                    needSwallow = false,
                    -- touchShowTip = false
                }) 
        item_reward:setScale(0.7)
        item_reward:setPosition(160+(i-1)*75,cell:getContentSize().height/2 + 5)
        cell:addChild(item_reward)
    end

    --图片
    local line = cc.Sprite:create("res/image/common/line.png")
    line:setPosition(cell:getContentSize().width/2,0)
    cell:addChild(line)

    local _state = tonumber(data.state)
    local _pos = cc.p(cell:getContentSize().width-80,cell:getContentSize().height/2)
    if _state == 2 then
        local already_cliam = cc.Sprite:create("res/image/plugin/stageChapter/reward_alyread.png")
        already_cliam:setPosition(_pos)
        already_cliam:setScale(0.7)
        cell:addChild(already_cliam)
    else
		local isVisble = false
        local _fontText = ""
        local _btnColor = ""
        if tonumber(data.state) == 1 then
			isVisble= true
            _fontText = LANGUAGE_TIPS_CANRECEIVE
            _btnColor = "write_1"
        elseif tonumber(data.state) == 0 then
            _fontText = LANGUAGE_ADJ.unreachable
            _btnColor = "write"
        end

        local cliam_btn = XTHD.createCommonButton({
            btnColor = _btnColor,
            isScrollView = true,
            text = _fontText,
            fontSize = 26,
            btnSize = cc.size(130, 51),
            needSwallow = false,
        })
        cliam_btn:setScale(0.7)
        cliam_btn:setPosition(cell:getContentSize().width-80,cell:getContentSize().height/2)
        cliam_btn:setTag(idx)
        cell:addChild(cliam_btn)
        cliam_btn:setTouchEndedCallback(function (  )
            self:onRecBtnClick(idx)
        end)
		
		local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		cliam_btn:addChild( fetchSpine )
		fetchSpine:setPosition( cliam_btn:getBoundingBox().width*0.5+27, cliam_btn:getContentSize().height/2+20-17 )
		fetchSpine:setAnimation( 0, "querenjinjie", true )
		fetchSpine:setVisible(isVisble)
    end

    return cell
end

function JingXiangZhiLuChallengeGiftLayer:dealRewardDataToShow(id)
	local reward_data = {}
	local temp_data = self._showData[id]
	for i=1, 4 do
        local _id = temp_data["item" .. i]
        if _id and _id ~= 0 then
            reward_data[#reward_data + 1] =  {
               itemId = temp_data["item" .. i],
               _type_ = 4,
               count = temp_data["num" .. i],
            } 
        end
    end
    return reward_data
end

function JingXiangZhiLuChallengeGiftLayer:onRecBtnClick(id)
	if self._showData[id].state == 0 then
        XTHDTOAST("无奖励可领取")
        return
    elseif self._showData[id].state == 2 then
    	XTHDTOAST("奖励已领取")
        return
	end
	HttpRequestWithParams("singleEctypePassReward",{configId = self._showData[id].id},function (data)
        -- print("领取福利服务器返回的数据为：")
        -- print_r(data)
        local show = {} --奖励展示
        --货币类型
        if data.property and #data.property > 0 then
            for i=1,#data.property do
                local pro_data = string.split( data.property[i],',')
                --如果奖励类型存在，而且不是vip升级(406)则加入奖励
                print(XTHD.resource.propertyToType[tonumber(pro_data[1])])
                if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
                    local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
                    if getNum > 0 then
                        local idx = #show + 1
                        show[idx] = {}
                        show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
                        show[idx].num = getNum
                    end
                end
                DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
            end
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})        --刷新数据信息
        end

        --物品类型
        if data.bagItems and #data.bagItems ~= 0 then
            for i=1,#data.bagItems do
                local item_data = data.bagItems[i]
                local showCount = item_data.count
                if item_data.count and tonumber(item_data.count) ~= 0 then
                    --print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
                    showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId))
                    DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
                else
                    DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
                end
                --如果奖励类型
                local idx = #show + 1
                show[idx] = {}
                show[idx].rewardtype = 4 -- item_data.item_type
                show[idx].id = item_data.itemId
                show[idx].num = showCount
            end
        end
        --显示领取奖励成功界面
        ShowRewardNode:create(show)
        self._showData[id].state = 2 
        self._tableView:reloadData()
    end)
end

return JingXiangZhiLuChallengeGiftLayer


