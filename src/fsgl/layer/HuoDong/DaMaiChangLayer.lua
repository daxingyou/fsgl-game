--大卖场界面

local DaMaiChangLayer = class("DaMaiChangLayer",function( )
    return XTHD.createPopLayer()
end)

function DaMaiChangLayer:ctor(params)
    -- self._hangUpIndex = self:getHangUpIndexByName(params.which) or 1 ------当前选中的是哪个挂机类型
    self.serverData = params.data
    self._hyperButtons = {}    --保存活动按钮
    self.selectedIndex = 0  --当前选中的按钮
    self._localData = gameData.getDataFromCSV("Hypermarket")
    self.buyBtnGroup = {}
    self.receiveBtnGroup = {}
    self.textGroup = {}
    self.tipGroup = {}

    --用于展示的数据
    self._openData = {}

    self._btnName = {
        "丹药",
        "宝石",
        "玄符",
        "碎片",
        "兵书",
        "其他"
    }
    self:initData()
end

function DaMaiChangLayer:create(params)
	local hyper = DaMaiChangLayer.new(params)
	if hyper then 
		hyper:init()
		hyper:registerScriptHandler(function(event)
            if event == "enter" then 
                hyper:onEnter()
            elseif event == "exit" then 
                hyper:onExit()
            end 
        end) 
	end 

	return hyper
end

function DaMaiChangLayer:onEnter( )
	local function TOUCH_EVENT_BEGAN( touch,event )
        return true
    end

    local function TOUCH_EVENT_MOVED( touch,event )
        -- body
    end

    local function TOUCH_EVENT_ENDED( touch,event )
        if self._canClick == false then
            return
        end
        local pos = touch:getLocation()
        local rect = self.bg:getBoundingBox()
        if cc.rectContainsPoint(rect,pos) == false then
            self._canClick = false
            if self.isTurnAnimEnd == false then
                return
            end
            self:removeFromParent()
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(TOUCH_EVENT_BEGAN,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(TOUCH_EVENT_MOVED,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(TOUCH_EVENT_ENDED,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
end

function DaMaiChangLayer:onExit( )
	
end

function DaMaiChangLayer:onCleanup( )
    
end

function DaMaiChangLayer:init( )
	self._canClick = true
    local bg = XTHD.createSprite("res/image/activities/hypermarket/bg.png")  
    bg:setPosition(self:getContentSize().width/2, (self:getContentSize().height)/2)  
    self:addContent(bg)
	self.bg = bg

    --挂机按钮滚动框
    local scrollView = ccui.ListView:create()
    scrollView:setContentSize(cc.size(200,390))
    scrollView:setDirection(ccui.ScrollViewDir.vertical)
	scrollView:setScrollBarEnabled(false)
    scrollView:setBounceEnabled(true)
    scrollView:setAnchorPoint(0.5,0.5)
    scrollView:setPosition(self.bg:getContentSize().width/4 - 97 ,self.bg:getContentSize().height/4 + 105)
    self.bg:addChild(scrollView)
    self._buttonList = scrollView

	--关闭按钮
	local closeBtn = XTHDPushButton:createWithFile({
        normalFile = "res/image/activities/hypermarket/btn_close_up.png",
        selectedFile = "res/image/activities/hypermarket/btn_close_down.png",
		musicFile = XTHD.resource.music.effect_btn_commonclose,
        anchor = cc.p( 0.5, 0.5 ),
    })
	closeBtn:setPosition(self.bg:getContentSize().width/4*3 + 210,self.bg:getContentSize().height/4*3 + 10 )
	self.bg:addChild(closeBtn)
	closeBtn:setTouchEndedCallback(function()
		self:hide()
	end)
	
	local function cellSizeForTable(table,idx)
         return 225,260
     end

     local function numberOfCellsInTableView(table)
         -- return #self._openData[self.selectedIndex].sell or 0
         return 1
     end

     local function tableCellAtIndex(table,idx)
         local cell = table:dequeueCell()
         if cell then
             cell:removeAllChildren()
         else
             cell = cc.TableViewCell:create()
         end
         self:createShopCell(cell)
         -- local node = self:createShopCell(idx + 1)
         -- if node then 
         --     cell:addChild(node)
         --     node:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
         -- end 
         return cell
     end

     local view = cc.TableView:create(cc.size(665,300))
     view:setPosition(self.bg:getContentSize().width/4 - 15 ,self.bg:getContentSize().height/4 - 125)
     view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) --设置横向纵向
     view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
     view:setBounceable(true)
     view:setDelegate()
     self.bg:addChild(view)

     view:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
     view:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
     view:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
     self.listBg = view

	--加载左边按钮
    self:loadButtons()

    --倒计时
    local timeBg = cc.Sprite:create("res/image/activities/hypermarket/time.png")
    self.bg:addChild(timeBg)
	timeBg:setScale(1.2)
    timeBg:setPosition(self.bg:getContentSize().width/2 - 140,self.bg:getContentSize().height/2 + 170)

    local temptime = LANGUAGE_KEY_CARNIVALDAY(self._openData[self.selectedIndex].closeTime)  
    local timeText = XTHDLabel:create(temptime,14)
    timeText:setAnchorPoint(0,0.5)
    timeBg:addChild(timeText)
    timeText:setPosition(timeBg:getContentSize().width/2 - 15,timeBg:getContentSize().height/2 - 1)
    self.timeStr = timeText

end

function DaMaiChangLayer:loadButtons()

    for j = 1,#self._openData do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(200,65))

        local normal = cc.Sprite:create("res/image/activities/hypermarket/store"..self._openData[j].group.."_down.png")
        local selected = cc.Sprite:create("res/image/activities/hypermarket/store"..self._openData[j].group.."_up.png")          

        local button = XTHD.createPushButtonWithSound({
            normalNode = normal,
            selectedNode = selected,
            needSwallow = false,
        },3)
        
        button:setTag(j)
        button.index = j
        button:setTouchEndedCallback(function( )
            self:changeShop(button:getTag())
        end)        
        button:setScale(0.9)
        layout:addChild(button)
        button:setPosition(layout:getContentSize().width / 2,layout:getContentSize().height / 2)
        layout:setTag(j)

        self._hyperButtons[j] = button

        self._buttonList:pushBackCustomItem(layout)
    end 
    self:changeShop(1)
end

function DaMaiChangLayer:changeShop(id)
    -- print("-------------------id:"..id)
    if self.selectedIndex == id then
        return
    end

    self._hyperButtons[id]:setSelected(true)
    if self._selectedButton then 
        self._selectedButton:setSelected(false)
    end 
    self._selectedButton = self._hyperButtons[id]

    self.selectedIndex = id
    self:updateTime()
    self.listBg:reloadData()

end

function DaMaiChangLayer:createShopCell(cell)
    self.buyBtnGroup = {}
    self.receiveBtnGroup = {}
    self.textGroup = {}
    cell:setContentSize(665 + 225*math.max(#self._openData[self.selectedIndex].sell - 3,0),260)
    for i = 1,#self._openData[self.selectedIndex].sell do
        local itemBg = cc.Sprite:create("res/image/activities/hypermarket/itembg.png")
        local title = cc.Sprite:create("res/image/activities/hypermarket/title.png")
        itemBg:addChild(title)
        title:setAnchorPoint(0.5,1)
        title:setPosition(itemBg:getContentSize().width/2 + 1,itemBg:getContentSize().height + 7)
        local tip = cc.Sprite:create("res/image/activities/hypermarket/tip"..self._localData[self._openData[self.selectedIndex].sell[i].sellID].type..".png")
        title:addChild(tip)
        tip:setPosition(title:getContentSize().width/2,title:getContentSize().height/2)
        self.tipGroup[i] = tip
        local item = ItemNode:createWithParams( {
            _type_ = self._localData[self._openData[self.selectedIndex].sell[i].sellID].buytype,
            itemId = self._localData[self._openData[self.selectedIndex].sell[i].sellID].buyid,
            count = self._localData[self._openData[self.selectedIndex].sell[i].sellID].buynum,
        } )
		item:setScale(0.82)
        itemBg:addChild(item)
        item:setPosition(itemBg:getContentSize().width/2 - 2,itemBg:getContentSize().height/2 + 42)
        local itemName = XTHDLabel:create(self._localData[self._openData[self.selectedIndex].sell[i].sellID].buyitemname,18)
        itemName:enableShadow(XTHD.resource.textColor.anhong_text,cc.size(0.4,-0.4),0.4)
        itemName:setColor(cc.c3b(139,69,19))
        itemBg:addChild(itemName)
        itemName:setPosition(itemBg:getContentSize().width/2,itemBg:getContentSize().height/2 - 12)
        local consumeStr = "<color=#8B4513 fontSize=20 font=Helvetica>".."消耗"..":</color>".."<img="..IMAGE_KEY_HEADER_INGOT.." /><color=#8B4513 fontSize=20 font=Helvetica>"..self._localData[self._openData[self.selectedIndex].sell[i].sellID].buyyuanbao.."</color>"
        local consumeLabel = RichLabel:createARichText(consumeStr,false)
        consumeLabel:setScale(0.9)
        itemBg:addChild(consumeLabel)
        consumeLabel:setPosition(itemBg:getContentSize().width/4 - 7,itemBg:getContentSize().height/2 - 5)
        local buyBtn = XTHD.createButton({
            normalFile = "res/image/activities/hypermarket/buy1.png",
            selectedFile = "res/image/activities/hypermarket/buy2.png",
            anchor = cc.p( 0.5, 0 ),
        })
        local textcount = XTHDLabel:create("剩余购买次数："..self._openData[self.selectedIndex].sell[i].remainCount,16)
        textcount:setColor(cc.c3b(139,69,19))
        itemBg:addChild(textcount)
        textcount:setPosition(title:getPositionX(),itemName:getPositionY() - 50)
        self.textGroup[i] = textcount
        itemBg:addChild(buyBtn)
        buyBtn:setPosition(itemBg:getContentSize().width/2,itemBg:getContentSize().height/4 - 57)
        buyBtn:setTouchEndedCallback(function()
            self:onBuyBtnClick(i)
        end)
        self.buyBtnGroup[i] = buyBtn
        local receiveBtn = XTHD.createButton({
            normalFile = "res/image/activities/hypermarket/lingqu1.png",
            selectedFile = "res/image/activities/hypermarket/lingqu2.png",
            anchor = cc.p( 0.5, 0 ),
        })
        itemBg:addChild(receiveBtn)
        receiveBtn:setPosition(itemBg:getContentSize().width/2,itemBg:getContentSize().height/4 - 57)
        receiveBtn:setTouchEndedCallback(function()
            self:onBuyBtnClick(i)
        end)
        local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
        receiveBtn:addChild(fetchSpine)
        fetchSpine:setScale(0.6)
        fetchSpine:setPosition(receiveBtn:getBoundingBox().width*0.5, receiveBtn:getContentSize().height*0.5+2)
        fetchSpine:setAnimation(0, "querenjinjie", true )
        self.receiveBtnGroup[i] = receiveBtn
        if self._openData[self.selectedIndex].sell[i].state then
            self.receiveBtnGroup[i]:setVisible(true)
            self.buyBtnGroup[i]:setVisible(false)
            self.tipGroup[i]:initWithFile("res/image/activities/hypermarket/tip7.png")
        else
            self.receiveBtnGroup[i]:setVisible(false)
            self.buyBtnGroup[i]:setVisible(true)
            self.tipGroup[i]:initWithFile("res/image/activities/hypermarket/tip"..self._localData[self._openData[self.selectedIndex].sell[i].sellID].type..".png")
        end
        cell:addChild(itemBg)
        local pos = SortPos:sortFromMiddle(cc.p(cell:getContentSize().width/2,cell:getContentSize().height/2), #self._openData[self.selectedIndex].sell, 230)
        itemBg:setPosition(pos[i])
    end
    -- local itemBg = cc.Sprite:create("res/image/activities/hypermarket/itembg.png")
    -- local title = cc.Sprite:create("res/image/activities/hypermarket/title.png")
    -- itemBg:addChild(title)
    -- title:setAnchorPoint(0.5,1)
    -- title:setPosition(itemBg:getContentSize().width/2 + 1,itemBg:getContentSize().height + 7)
    -- local tip = cc.Sprite:create("res/image/activities/hypermarket/tip"..self._localData[self._openData[self.selectedIndex].sell[index].sellID].type..".png")
    -- title:addChild(tip)
    -- tip:setPosition(title:getContentSize().width/2,title:getContentSize().height/2)
    -- local item = ItemNode:createWithParams( {
    --     _type_ = self._localData[self._openData[self.selectedIndex].sell[index].sellID].buytype,
    --     itemId = self._localData[self._openData[self.selectedIndex].sell[index].sellID].buyid,
    --     count = self._localData[self._openData[self.selectedIndex].sell[index].sellID].buynum,
    -- } )
    -- itemBg:addChild(item)
    -- item:setPosition(itemBg:getContentSize().width/2,itemBg:getContentSize().height/2 + 40)
    -- local itemName = XTHDLabel:create(self._localData[self._openData[self.selectedIndex].sell[index].sellID].buyitemname,18)
    -- itemName:enableShadow(XTHD.resource.textColor.anhong_text,cc.size(0.4,-0.4),0.4)
    -- itemName:setColor(cc.c3b(139,69,19))
    -- itemBg:addChild(itemName)
    -- itemName:setPosition(itemBg:getContentSize().width/2,itemBg:getContentSize().height/2 - 25)
    -- local consumeStr = "<color=#8B4513 fontSize=20 font=Helvetica>".."消耗"..":</color>".."<img="..IMAGE_KEY_HEADER_INGOT.." /><color=#8B4513 fontSize=20 font=Helvetica>"..self._localData[self._openData[self.selectedIndex].sell[index].sellID].buyyuanbao.."</color>"
    -- local consumeLabel = RichLabel:createARichText(consumeStr,false)
    -- itemBg:addChild(consumeLabel)
    -- consumeLabel:setPosition(itemBg:getContentSize().width/4 - 7,itemBg:getContentSize().height/2 - 20)
    -- local buyBtn = XTHD.createButton({
    --     normalFile = "res/image/activities/hypermarket/buy1.png",
    --     selectedFile = "res/image/activities/hypermarket/buy2.png",
    --     anchor = cc.p( 0.5, 0 ),
    -- })
    -- itemBg:addChild(buyBtn)
    -- buyBtn:setPosition(itemBg:getContentSize().width/2,itemBg:getContentSize().height/4 - 57)
    -- buyBtn:setTouchEndedCallback(function()
    --     self:onBuyBtnClick(index)
    -- end)
    -- return itemBg
end

--请求收获
function DaMaiChangLayer:onBuyBtnClick(id)
    HttpRequestWithParams("buyHypemarketItem",{configId = self._openData[self.selectedIndex].sell[id].sellID},function (data)
        print("大卖场购买服务器返回的数据为：")
        print_r(data)
        local show = {} --奖励展示
        --领取状态
        if data.receiveState then
            self.receiveBtnGroup[id]:setVisible(true)
            self.buyBtnGroup[id]:setVisible(false)
            self.tipGroup[id]:initWithFile("res/image/activities/hypermarket/tip7.png")
        else
            self.receiveBtnGroup[id]:setVisible(false)
            self.buyBtnGroup[id]:setVisible(true)
            self.tipGroup[id]:initWithFile("res/image/activities/hypermarket/tip"..self._localData[self._openData[self.selectedIndex].sell[id].sellID].type..".png")
        end
        --剩余购买次数
        self.textGroup[id]:setString("剩余购买次数："..data.selfSurplusCount)
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
        RedPointManage:reFreshDynamicItemData()
    end)
end

function DaMaiChangLayer:updateTime()
    self:stopActionByTag(10)
    schedule(self, function()
        self._openData[self.selectedIndex].closeTime = self._openData[self.selectedIndex].closeTime - 1
        local time = LANGUAGE_KEY_CARNIVALDAY(self._openData[self.selectedIndex].closeTime)  
        self.timeStr:setString(time)
    end,1,10)
end

function DaMaiChangLayer:initData()
    --封装需要的数据
    self._openData = {}
    for i = 1,#self.serverData.time do
        if self.serverData.time[i].open <= 0 and self.serverData.time[i].close > 0 then
            local temp = {}
            temp.name = self._btnName[self.serverData.time[i].group]
            temp.group = self.serverData.time[i].group
            temp.closeTime = self.serverData.time[i].close
            table.insert(self._openData,temp)
        end
    end
    for i = 1,#self._openData do
        self._openData[i].sell = {}
    end
    for i = 1,#self.serverData.list do
        for j = 1,#self._openData do
            if self.serverData.list[i].group == self._openData[j].group then
                local temp = {}
                temp.sellID = self.serverData.list[i].configId
                temp.remainCount = self.serverData.list[i].selfSurplusCount
                temp.state = self.serverData.list[i].receiveState
                table.insert(self._openData[j].sell,temp)
            end
        end
    end
	if #self._openData == 0 then
		XTHDTOAST("大卖场活动未开启！")
		self:removeFromParent()
		return
	end

    -- print("封装好的数据为：")
    -- print_r(self._openData)
end

function DaMaiChangLayer:getHyperIndexByName( name )
    local index = {
        danyao = 1,  
        baoshi = 2,
        xuanfu = 3,
        suipian = 4,
        bingshu = 5,
        other = 6
    }
    return index[name]
end

return DaMaiChangLayer