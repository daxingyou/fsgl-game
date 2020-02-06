--[[
    月卡和至尊卡界面
]]
local VoucherYueka = class("VoucherYueka", function()
    local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(705,468)
	return node
end)

function VoucherYueka:ctor( data )
    self._size = self:getContentSize()
    self.serverData = data
    self.closeTime = 0
    self.localData = gameData.getDataFromCSV("MonthCard")
    self:initUI()
end

function VoucherYueka:onCleanup()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    helper.collectMemory()
end

-- 初始化界面
function VoucherYueka:initUI()
	
    self.monthcardUnBuy = cc.Node:create()
    self.monthcardBuy = cc.Node:create()
    self.zhizuncardUnBuy = cc.Node:create()
    self.zhizuncardBuy = cc.Node:create()

    --月卡
    local yuekaBg = cc.Sprite:create("res/image/VoucherCenter/yueka/bg1.png")
	yuekaBg:setScale(0.85)
    self:addChild(yuekaBg)
    yuekaBg:setPosition(self:getContentSize().width*0.45 - 5,self:getContentSize().height * 0.55 + 5)
    self.monthcardUnBuy:setContentSize(yuekaBg:getContentSize())
    self.monthcardBuy:setContentSize(yuekaBg:getContentSize())
    yuekaBg:addChild(self.monthcardUnBuy,10)
    yuekaBg:addChild(self.monthcardBuy,10)    

    local buyBtn1 = XTHDPushButton:createWithFile({
    normalFile = "res/image/VoucherCenter/yueka/btn_yueka_1.png",
    selectedFile = "res/image/VoucherCenter/yueka/btn_yueka_2.png",
    musicFile = XTHD.resource.music.effect_btn_commonclose,
    endCallback  = function()
        -- print("购买月卡")
        XTHD.pay(gameData.getDataFromCSV("StoredValue",{id = 7}),4,self)
    end,
    })
    self.monthcardUnBuy:addChild(buyBtn1)
    buyBtn1:setPosition(yuekaBg:getContentSize().width/2 - 5,-buyBtn1:getContentSize().height)

    local tip1 = cc.Sprite:create("res/image/activities/monthcard/tip1.png")
    self.monthcardBuy:addChild(tip1)
    tip1:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height - 75)
    for i = 1, 4 do
        if self.localData[1]["num"..tostring(i)] ~= nil and self.localData[1]["num"..tostring(i)] > 0 then
            local item = ItemNode:createWithParams({
                _type_ = self.localData[1]["rewardType" .. tostring(i)],
                itemId = self.localData[1]["id" .. tostring(i)],
                count = self.localData[1]["num"..tostring(i)]
            })
            item:setScale(0.6)
            self.monthcardBuy:addChild(item)
            item:setPosition(item:getContentSize().width *0.4 + 2 + (i-1) *(item:getContentSize().width *0.5 + 13),yuekaBg:getContentSize().height*0.15)
           
        end
    end
    self.Time = XTHDLabel:create("",16,"res/fonts/def.ttf")
    self.Time:setColor(cc.c3b(255,250,205))
    self.monthcardBuy:addChild(self.Time)
    self.Time:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height/2 - 85)
    -- self:updateTime()
    local receiveBtn1 = XTHDPushButton:createWithFile({
    normalFile = "res/image/VoucherCenter/yueka/btn_lingqu_1.png",
    selectedFile = "res/image/VoucherCenter/yueka/btn_lingqu_2.png",
    musicFile = XTHD.resource.music.effect_btn_commonclose,
    endCallback  = function()
       self:receiveBtnClick(1)
    end,
    })
    self.monthcardBuy:addChild(receiveBtn1)
    receiveBtn1:setName("receiveBtn")
    receiveBtn1:setPosition(yuekaBg:getContentSize().width/2 - 5,-receiveBtn1:getContentSize().height)
    local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
    receiveBtn1:addChild(fetchSpine)
    fetchSpine:setScaleX(0.75)
    fetchSpine:setScaleY(0.65)
    fetchSpine:setPosition(receiveBtn1:getBoundingBox().width*0.5 + 1, receiveBtn1:getContentSize().height*0.5+2)
    fetchSpine:setAnimation(0, "querenjinjie", true )
    local yilingqu1 = cc.Sprite:create("res/image/activities/chengzhangjijin/yilingqu.png")
    self.monthcardBuy:addChild(yilingqu1)
    yilingqu1:setName("yilingqu")
    yilingqu1:setPosition(yuekaBg:getContentSize().width/2 - 5,-receiveBtn1:getContentSize().height)

    --至尊卡
    local zhizunBg = cc.Sprite:create("res/image/VoucherCenter/yueka/bg2.png")
	zhizunBg:setScale(0.85)
    self:addChild(zhizunBg)
    zhizunBg:setPosition(self:getContentSize().width/4*3 + 35,self:getContentSize().height * 0.55 + 5)
    self.zhizuncardUnBuy:setContentSize(zhizunBg:getContentSize())
    self.zhizuncardBuy:setContentSize(zhizunBg:getContentSize())
    zhizunBg:addChild(self.zhizuncardUnBuy,10)
    zhizunBg:addChild(self.zhizuncardBuy,10)
    
    local buyBtn2 = XTHDPushButton:createWithFile({
    normalFile = "res/image/VoucherCenter/yueka/btn_zhizunka_1.png",
    selectedFile = "res/image/VoucherCenter/yueka/btn_zhizunka_2.png",
    musicFile = XTHD.resource.music.effect_btn_commonclose,
    endCallback  = function()
        -- print("购买至尊卡")
        XTHD.pay(gameData.getDataFromCSV("StoredValue",{id = 8}),4,self)
    end,
    })
    self.zhizuncardUnBuy:addChild(buyBtn2)
    buyBtn2:setPosition(zhizunBg:getContentSize().width/2 - 5,-buyBtn2:getContentSize().height)

    local tip2 = cc.Sprite:create("res/image/activities/monthcard/tip2.png")
    self.zhizuncardBuy:addChild(tip2)
    tip2:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height - 75)
    for i = 1, 4 do
        if self.localData[2]["num"..tostring(i)] ~= nil and self.localData[2]["num"..tostring(i)] > 0 then
            local item = ItemNode:createWithParams({
                _type_ = self.localData[2]["rewardType" .. tostring(i)],
                itemId = self.localData[2]["id" .. tostring(i)],
                count = self.localData[2]["num"..tostring(i)]
            })
            item:setScale(0.6)
            self.zhizuncardBuy:addChild(item)
			item:setPosition(item:getContentSize().width *0.4 + 2 + (i-1) *(item:getContentSize().width *0.5 + 13),zhizunBg:getContentSize().height*0.15)
        end
    end
	
    local receiveBtn2 = XTHDPushButton:createWithFile({
    normalFile = "res/image/VoucherCenter/yueka/btn_lingqu_1.png",
    selectedFile = "res/image/VoucherCenter/yueka/btn_lingqu_2.png",
    musicFile = XTHD.resource.music.effect_btn_commonclose,
    endCallback  = function()
       self:receiveBtnClick(2)
    end,
    })
    self.zhizuncardBuy:addChild(receiveBtn2)
    receiveBtn2:setName("receiveBtn")
    receiveBtn2:setPosition(zhizunBg:getContentSize().width/2 - 5,-receiveBtn2:getContentSize().height)
    local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
    receiveBtn2:addChild(fetchSpine)
    fetchSpine:setScaleX(0.75)
    fetchSpine:setScaleY(0.65)
    fetchSpine:setPosition(receiveBtn2:getBoundingBox().width*0.5 + 1, receiveBtn2:getContentSize().height*0.5+2)
    fetchSpine:setAnimation(0, "querenjinjie", true )
    local yilingqu2 = cc.Sprite:create("res/image/activities/chengzhangjijin/yilingqu.png")
    self.zhizuncardBuy:addChild(yilingqu2)
    yilingqu2:setName("yilingqu")
    yilingqu2:setPosition(zhizunBg:getContentSize().width/2 - 5,-receiveBtn2:getContentSize().height)

    self:freshData()

end

function VoucherYueka:receiveBtnClick(_type)
    -- print("领取奖励类型为：".._type)
    HttpRequestWithParams("receiveMouthCardReward",{type = _type},function (data)
        -- print("领取奖励服务器返回的数据为：")
        -- print_r(data)
         -- 更新属性
        local show_data = {}
        if data.property then
            for i = 1, #data.property do
                local _data = string.split(data.property[i],",")
                local num_1 = gameUser.getDataById(_data[1])
                if num_1 ~= nil then
                    local getNum = tonumber(_data[2]) - tonumber(num_1)
                    if getNum > 0 then
                        local idx = #show_data + 1
                        show_data[idx] = {}
                        show_data[idx].rewardtype = XTHD.resource.propertyToType[tonumber(_data[1])]
                        show_data[idx].num = getNum
                    end
                    gameUser.updateDataById(_data[1],_data[2])
                end
            end
        end
        for i = 1 ,#data.bagItems do
            local _data = data.bagItems[i]
            local num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0
            local num = _data.count - num_2
            show_data[#show_data+1] = {rewardtype = 4,id =_data.itemId,num = num}
            DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
        end
        ShowRewardNode:create(show_data)
        self:freshData()
        --刷新主城信息
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
    end)
end


function VoucherYueka:freshData()
    RedPointState[18].state = 0
    HttpRequestWithOutParams("mouthCardState",function (data)
        -- print("刷新月卡至尊卡：")
        -- print_r(data)
        --根据服务器相关状态进行处理
        if data.monthCardState == 0 then
            self.monthcardUnBuy:setVisible(true)
            self.monthcardBuy:setVisible(false)
        elseif data.monthCardState == 1 then
            self.monthcardUnBuy:setVisible(false)
            self.monthcardBuy:setVisible(true)
            if self.monthcardBuy:getChildByName("receiveBtn") then
                self.monthcardBuy:getChildByName("receiveBtn"):setVisible(true)
            end
            if self.monthcardBuy:getChildByName("yilingqu") then
                self.monthcardBuy:getChildByName("yilingqu"):setVisible(false)
            end
            if data.monthTime then
                self.closeTime = data.monthTime
                self:updateTime()
            end
            RedPointState[18].state = 1
        else
            self.monthcardUnBuy:setVisible(false)
            self.monthcardBuy:setVisible(true)
            if self.monthcardBuy:getChildByName("receiveBtn") then
                self.monthcardBuy:getChildByName("receiveBtn"):setVisible(false)
            end
            if self.monthcardBuy:getChildByName("yilingqu") then
                self.monthcardBuy:getChildByName("yilingqu"):setVisible(true)
            end
            if data.monthTime then
                self.closeTime = data.monthTime
                self:updateTime()
            end
        end

        if data.zhiZunCardState == 0 then
            self.zhizuncardUnBuy:setVisible(true)
            self.zhizuncardBuy:setVisible(false)
        elseif data.zhiZunCardState == 1 then
            self.zhizuncardUnBuy:setVisible(false)
            self.zhizuncardBuy:setVisible(true)
            if self.zhizuncardBuy:getChildByName("receiveBtn") then
                self.zhizuncardBuy:getChildByName("receiveBtn"):setVisible(true)
            end
            if self.zhizuncardBuy:getChildByName("yilingqu") then
                self.zhizuncardBuy:getChildByName("yilingqu"):setVisible(false)
            end
            RedPointState[18].state = 1
        else
            self.zhizuncardUnBuy:setVisible(false)
            self.zhizuncardBuy:setVisible(true)
            if self.zhizuncardBuy:getChildByName("receiveBtn") then
                self.zhizuncardBuy:getChildByName("receiveBtn"):setVisible(false)
            end
            if self.zhizuncardBuy:getChildByName("yilingqu") then
                self.zhizuncardBuy:getChildByName("yilingqu"):setVisible(true)
            end
        end
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "monthandzcard"}})
    end)
end

function VoucherYueka:updateTime()
    self:stopActionByTag(10)
    self.Time:setString("剩余时间："..LANGUAGE_KEY_CARNIVALDAY(self.closeTime))
    schedule(self, function()
        self.closeTime = self.closeTime - 1
        if self.closeTime < 0 then
            self:freshData()
            return
        end
        local time = "剩余时间："..LANGUAGE_KEY_CARNIVALDAY(self.closeTime)
        self.Time:setString(time)
    end,1,10)
end

function VoucherYueka:create(data)
    return VoucherYueka.new(data)
end

return VoucherYueka