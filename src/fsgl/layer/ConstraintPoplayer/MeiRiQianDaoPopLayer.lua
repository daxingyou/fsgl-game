--[[
每日签到打脸页
]]

local MeiRiQianDaoPopLayer = class("MeiRiQianDaoPopLayer",function( )
	return XTHDPopLayer:create()
end)

function MeiRiQianDaoPopLayer:ctor(data)
	self._data = data
	dump(data)
	gameUser.setMeiRiQianDaoState(0)
end

function MeiRiQianDaoPopLayer:onCleanup( )	
   
end

function MeiRiQianDaoPopLayer:create(data)
	local layer = MeiRiQianDaoPopLayer.new(data)
	if layer then 
		layer:init()
	end
	return layer
end

function MeiRiQianDaoPopLayer:init()
	self:initUI()
end

function MeiRiQianDaoPopLayer:initUI()
	local bg = cc.Sprite:create("res/image/dalianye/mrqd/bg.png")
	self:addContent(bg)
	bg:setPosition(self:getContentSize().width* 0.5,self:getContentSize().height*0.5)

	local btn_close = XTHDPushButton:createWithParams({
		normalFile = "res/image/dalianye/mrqd/btn_close_up.png",
		selectedFIle = "res/image/dalianye/mrqd/btn_close_down.png",
	})
	bg:addChild(btn_close)
	btn_close:setPosition(bg:getContentSize().width - btn_close:getContentSize().width *0.5 + 5,bg:getContentSize().height - btn_close:getContentSize().height *0.5 - 40)
	btn_close:setTouchEndedCallback(function()
		self:hide()
	end)

	local bg2 = cc.Sprite:create("res/image/dalianye/mrqd/bg2.png")
	bg:addChild(bg2,2)
	bg2:setPosition(bg:getContentSize().width - bg2:getContentSize().width *0.7,bg2:getContentSize().height* 0.5 + 20)

	 local _advertSp = XTHD.createSprite("res/image/activities/checkin/checkin_advertsp" .. self._data.month .. ".png")
    _advertSp:setAnchorPoint(cc.p(0,0))
    _advertSp:setPosition(cc.p(bg:getContentSize().width *0.1 - 20,28))
	bg:addChild(_advertSp)
	_advertSp:setScale(0.65)

	local tablebg = cc.Sprite:create("res/image/common/common_bg_1.png")
	tablebg:setContentSize(bg:getContentSize().width *0.55,bg:getContentSize().height*0.65)
	tablebg:setAnchorPoint(0.5,0)
	bg:addChild(tablebg)
	tablebg:setPosition(bg:getContentSize().width *0.65 + 10,30)
	--tablebg:setOpacity(0)
	
	self._taskTable = cc.TableView:create(tablebg:getContentSize())
	TableViewPlug.init(self._taskTable)
    self._taskTable:setPosition(cc.p(0,0))
    self._taskTable:setBounceable(true)
    self._taskTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._taskTable:setDelegate()
    self._taskTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tablebg:addChild(self._taskTable)

	local _midPosX = 292
	local per       = 5--[[每行显示的个数]]
    self.total_row  = 0;

	local _sizeSpr = cc.Sprite:create("res/image/activities/checkin/checkin_item_bg_normal.png")
    local row_width = _sizeSpr:getContentSize().width * per
    local row_height = _sizeSpr:getContentSize().height - 10

	local _normalNode = cc.Sprite:create("res/image/activities/checkin/checkin_title_bg.png")
	_normalNode:setContentSize(tablebg:getContentSize().width,_normalNode:getContentSize().height)
	 --[[顶部信息]]
    local title = XTHDPushButton:createWithParams({
            normalNode = _normalNode,
            text = LANGUAGE_KEY_TITLE_MONTH_REWARD(self._data.month)
            })
    title:setPosition(cc.p((bg:getContentSize().width +_midPosX )/2 ,bg:getContentSize().height - 65))
    title:setAnchorPoint(cc.p(0.5,1))
    title:setLabelSize(18)
    title:setLabelColor(cc.c3b(255, 255, 255))
    bg:addChild(title)

    local color_label = cc.c3b(245,103,38)

    local _labelSprite = cc.Sprite:create("res/image/common/common_bg_1.png")
	_labelSprite:setContentSize(tablebg:getContentSize().width,30)
    _labelSprite:setOpacity(0)
    _labelSprite:setAnchorPoint(cc.p(0.5,0.5))
    _labelSprite:setPosition(tablebg:getPositionX(),tablebg:getPositionY() + tablebg:getContentSize().height + _labelSprite:getContentSize().height *0.5 + 5)
    bg:addChild(_labelSprite)

    local label_all_duty = cc.Sprite:create("res/image/activities/checkin/all_duty.png")--XTHDLabel:create("本月全勤奖励：",18)
    label_all_duty:setAnchorPoint(cc.p(0,0.5))
    label_all_duty:setScale(0.7)
    label_all_duty:setPosition(cc.p(10,15))

    local icon_gold = cc.Sprite:create(IMAGE_KEY_HEADER_INGOT)
    icon_gold:setAnchorPoint(cc.p(0,0.5))
    icon_gold:setScale(0.7)
    icon_gold:setPosition(cc.p(label_all_duty:getBoundingBox().x + label_all_duty:getBoundingBox().width , label_all_duty:getPositionY()))

    local color_txt = cc.c3b(255,255,255)
    local label_all_duty_num = XTHDLabel:create("1000",18)
    label_all_duty_num:setColor(color_txt)
    label_all_duty_num:setAnchorPoint(cc.p(0,0))
    label_all_duty_num:setScale(0.8)
    label_all_duty_num:setPosition(cc.p(icon_gold:getBoundingBox().x + icon_gold:getBoundingBox().width , label_all_duty:getBoundingBox().y + 3))
    
    local label_checkin = XTHDLabel:create(LANGUAGE_TIPS_SIGNUPTIMES,20)-------------------本月签到次数
    label_checkin:setAnchorPoint(cc.p(0,0.5))
    label_checkin:setPosition(cc.p(330,label_all_duty:getPositionY()))
    label_checkin:setColor(color_label)
    
    local label_checkin_txt = XTHDLabel:create("10",20)
    label_checkin_txt:setAnchorPoint(cc.p(0,0))
    label_checkin_txt:setPosition(cc.p(label_checkin:getBoundingBox().x + label_checkin:getBoundingBox().width+5 , label_checkin:getBoundingBox().y))
    label_checkin_txt:setColor(color_txt)
    label_checkin_txt:enableShadow(color_txt,cc.size(0.4,-0.4),0.4)
    
    _labelSprite:addChild(label_all_duty)
    _labelSprite:addChild(icon_gold)
    _labelSprite:addChild(label_all_duty_num)
    _labelSprite:addChild(label_checkin)
    _labelSprite:addChild(label_checkin_txt)
    
    self._initted = false
    --[[重新加载数据]]
    local function reloadData(data,idx) 
        local gotoIndex = 0
        local list_everyday = data["list_everyday"]
        local list_allduty  = data["list_allduty"]
        local checked_days = data["checked_days"]
        self.cost = data["cost"]
        label_checkin_txt:setString(tostring(checked_days))
        self.item_everyday = {}
        if list_everyday then
            for i=1,#list_everyday do
                local list_everyday_item = list_everyday[i]
                self.item_everyday[#self.item_everyday + 1] = list_everyday_item
                --0:不可签到,1:已领取,2:可补签，3:可签到
                local status   = list_everyday_item["status"]
                if status == 3 then
                    gotoIndex = i
                end
            end
        end
        --[[全勤奖励，目前只有一个奖励2015-04-20]]
        self.data_allduty = {}
        if list_allduty then
            for i=1,#list_allduty do
                self.data_allduty[#self.data_allduty + 1] = list_allduty[i]

                local allduty_item = list_allduty[i]
                local _type     = allduty_item["type"]
                local id        = allduty_item["id"]
                local count     = allduty_item["count"]
                local day       = allduty_item["day"]
                local istoday   = allduty_item["istoday"]

                label_all_duty_num:setString(tostring(count))
                icon_gold:initWithFile(XTHD.resource.getResourcePath(_type))
                icon_gold:setAnchorPoint(cc.p(0,0.5))
                
            end
        end

        local total_num = #self.item_everyday
        local currentPos = 0
        for j = 1,#self.item_everyday do
            if self.item_everyday[j].status == 3 or self.item_everyday[j].status == 2 then
                currentPos = j
                break
            end
        end
        self.total_row = total_num / per
        local tmp       = total_num % per
        if tmp > 0 then
            self.total_row   = self.total_row + 1
        end

        if gotoIndex == 0 then
            -- print("消除红点")
           -- local params = {name = "activity",visible = false}
           -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = params})
        end

        if self._taskTable then
            self._taskTable:reloadDataAndScrollToCurrentCell()
            self._taskTable:scrollToCell(math.floor(currentPos/per) , true)
        end
    end
    
		
	self._taskTable.getCellSize =  function(table,idx)
        return row_width,row_height
    end
	
	self._taskTable.getCellNumbers = function(table)
        return self.total_row
    end

    local function tableCellTouched(table,cell)
    end
    
    local function tableCellAtIndex(table1,idx)
        local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        end
        cell:removeAllChildren()
        cell:setContentSize(cc.size(row_width,row_height))
	
        local cell_bg = cc.Sprite:create("res/image/activities/carnivalSevenDay/cellbg.png")
        cell_bg:setOpacity(0)
        cell_bg:setPosition(row_width / 2,row_height / 2)
        cell:addChild(cell_bg)

        for i=1,per do
            if self.item_everyday[i + idx * per] ~= nil then
                local index = i + idx * per
                local list_everyday_item = self.item_everyday[index]
                --类型,1:元宝；2.银两；3.翡翠；4.道具
                local _type     = list_everyday_item["type"]
                local id        = list_everyday_item["id"]
                local count     = list_everyday_item["count"]
                local day       = list_everyday_item["day"]
                local istoday   = list_everyday_item["istoday"]
                --0:不可签到,1:已领取,2:可补签，3:可签到
                local status   = list_everyday_item["status"]

                local item_bg = XTHDSprite:create("res/image/activities/checkin/checkin_item_bg_normal.png")
                item_bg:setSwallowTouches(false)
                item_bg:setScale(0.8)
                local y = row_height / 2
                item_bg:setPosition(cc.p((i * 2 - 1) * (item_bg:getContentSize().width*0.8 / 2 + 5), y))
                cell_bg:addChild(item_bg)

                item_bg.data = list_everyday_item

                --背景特效
                if status == 3 then
                    local effect_bg=cc.Sprite:create("res/image/activities/checkin/checkin_item_bg_today.png")
                    effect_bg:setPosition(cc.p(item_bg:getContentSize().width / 2 , item_bg:getContentSize().height / 2))
                    item_bg:addChild(effect_bg)
                end

                local item_img = ItemNode:createWithParams({
                    _type_ = _type,
                    itemId = id,
                    count  = count
                    })
                item_img:setScale(0.8)
                item_img.data = data
                item_img:setPosition(cc.p(item_bg:getContentSize().width / 2 , item_bg:getContentSize().height / 2))
                item_bg:addChild(item_img)

                --光圈特效
                if status == 3 then
                    local effect_circle=cc.Sprite:create("res/spine/effect/logindaily_effect/1.png")
                    effect_circle:setScale(0.75)
                    effect_circle:setPosition(cc.p(item_bg:getContentSize().width / 2 , item_bg:getContentSize().height / 2))
                    item_bg:addChild(effect_circle)
                    local _animation = getAnimation("res/spine/effect/logindaily_effect/",1,8,0.1)
                    effect_circle:runAction(cc.RepeatForever:create(_animation))
                end

                --遮罩层
                local cover = XTHD.createSprite("res/image/activities/checkin/checkin_cover.png")
                cover:setPosition(item_img:getPosition())
                item_bg:addChild(cover)
                cover:setOpacity(200)
                cover:setVisible(false)

                --[[对勾]]
                local done = XTHD.createSprite("res/image/activities/checkin/checkin_done.png")
                done:setAnchorPoint(cc.p(1.0,0))
                done:setPosition(cc.p(item_bg:getContentSize().width - 10 , 5))
                item_bg:addChild(done)
                done:setVisible(false)

                --[[签到标签或者补签标签]]
                local checkin_past = XTHD.createSprite("res/image/activities/checkin/checkin_past.png")
                checkin_past:setPosition(cc.p(-1 , item_bg:getContentSize().height - 2))
                item_bg:addChild(checkin_past)
                checkin_past:setVisible(false)

                --如果已经签到
                if status == 1 then
                    cover:setVisible(true)
                    done:setVisible(true)
                elseif status == 2 then--[[可补签]]
                    item_img:setShowDrop(false)
                    checkin_past:setVisible(true)
                elseif status == 3 then--[[可签]]
                    -- effect_circle:setVisible(true)
                    -- effect_bg:setVisible(true)
                    item_img:setShowDrop(false)
                    checkin_past:setVisible(true)
                    checkin_past:initWithFile("res/image/activities/checkin/checkin_today.png")
                end

                checkin_past:setAnchorPoint(cc.p(0,1.0))

                local function doCheck(replenish)
                    local confirmDialog = XTHDConfirmDialog:createWithParams({msg = LANGUAGE_KEY_CHECKIN_COST(self.cost)})
                    -- local pos={self:getContentSize().width/2+30,self:getContentSize().height/2}
                    local function _rightCallback() 
                        XTHDHttp:requestAsyncInGameWithParams({
                                modules = "doCheckInDaily?",
                                params  = {day = item_bg.data.day,
                                          replenish = replenish},
                                successCallback = function(data)
                                    if tonumber(data.result) == 0 then
                                         ShowRewardNode:create({{rewardtype = item_bg.data.type ,id = item_bg.data.id, num = item_bg.data.count}},nil,nil)
                                         reloadData(data,idx)
                                         if data.isallduty == true then
                                            local allduty_reward = {}
                                            for i=1,#self.data_allduty do
                                                local allduty_item = self.data_allduty[i]
                                                local _type     = allduty_item["type"]
                                                local id        = allduty_item["id"]
                                                local count     = allduty_item["count"]
                                                local day       = allduty_item["day"]
                                                local istoday   = allduty_item["istoday"]

                                                local item = {rewardtype = _type ,
                                                              id         = id,
                                                              num        = count
                                                              }
                                                allduty_reward[#allduty_reward + 1] = item
                                            end
                                            ShowRewardNode:create(allduty_reward,nil,nil)
                                            if effect_circle and effect_bg then
                                                effect_circle:removeFromParent()
                                                effect_bg:removeFromParent()
                                            end
                                         end
                                        if data.items then
                                            XTHD.saveItem({items = data.items})
                                        end
                                         ------更新玩家本地属性
                                        local server = data.property
                                        if server then
                                            for k,v in pairs(server) do 
                                                local values = string.split(v,',')
                                                DBUpdateFunc:UpdateProperty("userdata",values[1],values[2])
                                            end 
                                        end
                                        XTHD.refreshUserInfoUI()
                                    else
                                        XTHDTOAST(data.msg)
                                    end
                                    --[[如果是补签，在领完之后需要关闭弹窗]]
                                    if replenish == 1 then
                                        confirmDialog:removeFromParent()
                                    end
                                end,--成功回调
                                failedCallback = function()
                                    XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                                end,--失败回调
                                targetNeedsToRetain = self,--需要保存引用的目标
                                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                            })
                    end
                    confirmDialog:setCallbackRight(function() 
                        _rightCallback()
                    end)
                    if replenish == 1 then
						self:addChild(confirmDialog)    
                    else
                        _rightCallback()
                    end
                end
                item_bg:setTouchEndedCallback(function() 
                    local status = item_bg.data.status
                    if status == 3 then  --可签到
                        doCheck()
                    elseif status == 2 then  --可补签
                        doCheck(1)
                        -- item_img:showTip()
                    else
                        -- item_img:showTip()
                    end
                end)
                -- item_img:setTouchShowTip(false)
            end
        end
        return cell
    end

    self._taskTable:registerScriptHandler(self._taskTable.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._taskTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._taskTable:registerScriptHandler(self._taskTable.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    self._taskTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    reloadData(self._data)

end

--刷新掉落信息
function MeiRiQianDaoPopLayer:freshItemList(cell)

    
end

function MeiRiQianDaoPopLayer:onGoBtnClick()
    self:hide()
	requires("src/fsgl/layer/HuoDong/HuoDongLayer.lua"):createWithTab(2)
end

return MeiRiQianDaoPopLayer


