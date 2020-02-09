--[[
    月卡和至尊卡界面
]]
local YueKaAndZhiZunKa = class("YueKaAndZhiZunKa", function()
    return XTHD.createPopLayer()
end)

function YueKaAndZhiZunKa:ctor( data )
    self._size = self:getContentSize()
    self.serverData = data
    self.closeTime = 0
    self.localData = gameData.getDataFromCSV("MonthCard")
    self:initUI()
end

function YueKaAndZhiZunKa:onCleanup()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    helper.collectMemory()
end

-- 初始化界面
function YueKaAndZhiZunKa:initUI()
    -- 背景
    local contentBg = XTHD.createSprite( "res/image/activities/monthcard/bg.png" )
    contentBg:setPosition( self:getContentSize().width/2, self:getContentSize().height/2)
    self:addContent( contentBg )
    self._contentBg = contentBg

    local btn_close = XTHDPushButton:createWithFile({
    normalFile = "res/image/activities/TimelimitActivity/btn_close_up.png",
    selectedFile = "res/image/activities/TimelimitActivity/btn_close_down.png",
    musicFile = XTHD.resource.music.effect_btn_commonclose,
    endCallback  = function()
       self:hide()
    end,
    })
    self._contentBg:addChild(btn_close)
    btn_close:setPosition(self._contentBg:getContentSize().width - btn_close:getContentSize().width * 0.5 + 18,self._contentBg:getContentSize().height - btn_close:getContentSize().height * 0.5 - 10)

    self.monthcardUnBuy = cc.Node:create()
    self.monthcardBuy = cc.Node:create()
    self.zhizuncardUnBuy = cc.Node:create()
    self.zhizuncardBuy = cc.Node:create()

    --月卡
    local yuekaBg = cc.Sprite:create("res/image/activities/monthcard/bg1.png")
    self._contentBg:addChild(yuekaBg)
    yuekaBg:setPosition(self._contentBg:getContentSize().width/4 + 35,self._contentBg:getContentSize().height/2 - 20)
    self.monthcardUnBuy:setContentSize(yuekaBg:getContentSize())
    self.monthcardBuy:setContentSize(yuekaBg:getContentSize())
    yuekaBg:addChild(self.monthcardUnBuy,10)
    yuekaBg:addChild(self.monthcardBuy,10)
    local guang1 = cc.Sprite:create("res/image/activities/monthcard/guang.png")
    yuekaBg:addChild(guang1)
    guang1:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height/2)
    guang1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(30,360))))

    local title1 = cc.Sprite:create("res/image/activities/monthcard/title1.png")
    self.monthcardUnBuy:addChild(title1)
    title1:setPosition(yuekaBg:getContentSize().width/2,yuekaBg:getContentSize().height - 75)
    local icon1 = cc.Sprite:create("res/image/activities/monthcard/yueka2.png")
    self.monthcardUnBuy:addChild(icon1)
    icon1:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height/2 + 35)
    local text1 = cc.Sprite:create("res/image/activities/monthcard/yueka1.png")
    self.monthcardUnBuy:addChild(text1)
    text1:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height/2 - 40)
    local line1 = cc.Sprite:create("res/image/activities/monthcard/shadow1.png")
    self.monthcardUnBuy:addChild(line1)
    line1:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height/2 - 55)

    local buyBtn1 = XTHDPushButton:createWithFile({
    normalFile = "res/image/activities/monthcard/buyBtn_normal.png",
    selectedFile = "res/image/activities/monthcard/buyBtn_selected.png",
    musicFile = XTHD.resource.music.effect_btn_commonclose,
    endCallback  = function()
        -- print("购买月卡")
        XTHD.pay(gameData.getDataFromCSV("StoredValue",{id = 7}),4,self)
    end,
    })
    self.monthcardUnBuy:addChild(buyBtn1)
    buyBtn1:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height/2 - 135)

    local tip1 = cc.Sprite:create("res/image/activities/monthcard/tip1.png")
    self.monthcardBuy:addChild(tip1)
    tip1:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height - 75)
    for i = 1, 4 do
        if self.localData[1]["num"..tostring(i)] ~= nil and self.localData[1]["num"..tostring(i)] > 0 then
            local item = ItemNode:createWithParams({
                _type_ = self.localData[1]["rewardType" .. tostring(i)],
                itemId = self.localData[1]["id" .. tostring(i)],
                count = self.localData[1]["num"..tostring(i)],
				showDrropType = 2,
            })
            item:setScale(0.6)
            self.monthcardBuy:addChild(item)
            if i == 1 then
                item:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height/2 + 60)
            else
                local pos = SortPos:sortFromMiddle(cc.p(yuekaBg:getContentSize().width/2 - 5, yuekaBg:getContentSize().height/2 - 20),3,80)
                item:setPosition(pos[i - 1])
            end
           
        end
    end
    self.Time = XTHDLabel:create("",16,"res/fonts/def.ttf")
    self.Time:setColor(cc.c3b(255,250,205))
    self.monthcardBuy:addChild(self.Time)
    self.Time:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height/2 - 85)
    -- self:updateTime()
    local receiveBtn1 = XTHDPushButton:createWithFile({
    normalFile = "res/image/activities/monthcard/btn1.png",
    selectedFile = "res/image/activities/monthcard/btn2.png",
    musicFile = XTHD.resource.music.effect_btn_commonclose,
    endCallback  = function()
       self:receiveBtnClick(1)
    end,
    })
    self.monthcardBuy:addChild(receiveBtn1)
    receiveBtn1:setName("receiveBtn")
    receiveBtn1:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height/2 - 135)
    local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
    receiveBtn1:addChild(fetchSpine)
    fetchSpine:setScaleX(0.75)
    fetchSpine:setScaleY(0.65)
    fetchSpine:setPosition(receiveBtn1:getBoundingBox().width*0.5 + 1, receiveBtn1:getContentSize().height*0.5+2)
    fetchSpine:setAnimation(0, "querenjinjie", true )
    local yilingqu1 = cc.Sprite:create("res/image/activities/chengzhangjijin/yilingqu.png")
    self.monthcardBuy:addChild(yilingqu1)
    yilingqu1:setName("yilingqu")
    yilingqu1:setPosition(yuekaBg:getContentSize().width/2 - 5,yuekaBg:getContentSize().height/2 - 135)

    --至尊卡
    local zhizunBg = cc.Sprite:create("res/image/activities/monthcard/bg2.png")
    self._contentBg:addChild(zhizunBg)
    zhizunBg:setPosition(self._contentBg:getContentSize().width/4*3 - 30,self._contentBg:getContentSize().height/2 - 20)
    self.zhizuncardUnBuy:setContentSize(zhizunBg:getContentSize())
    self.zhizuncardBuy:setContentSize(zhizunBg:getContentSize())
    zhizunBg:addChild(self.zhizuncardUnBuy,10)
    zhizunBg:addChild(self.zhizuncardBuy,10)
    local guang2 = cc.Sprite:create("res/image/activities/monthcard/guang.png")
    zhizunBg:addChild(guang2)
    guang2:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height/2)
    guang2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(30,360))))
    local title2 = cc.Sprite:create("res/image/activities/monthcard/title2.png")
    self.zhizuncardUnBuy:addChild(title2)
    title2:setPosition(zhizunBg:getContentSize().width/2,zhizunBg:getContentSize().height - 75)
    local icon2 = cc.Sprite:create("res/image/activities/monthcard/zhizun2.png")
    self.zhizuncardUnBuy:addChild(icon2)
    icon2:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height/2 + 35)
    local text2 = cc.Sprite:create("res/image/activities/monthcard/zhizun1.png")
    self.zhizuncardUnBuy:addChild(text2)
    text2:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height/2 - 40)
    local line2 = cc.Sprite:create("res/image/activities/monthcard/shadow2.png")
    self.zhizuncardUnBuy:addChild(line2)
    line2:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height/2 - 55)
    local buyBtn2 = XTHDPushButton:createWithFile({
    normalFile = "res/image/activities/monthcard/buyBtn_normal.png",
    selectedFile = "res/image/activities/monthcard/buyBtn_selected.png",
    musicFile = XTHD.resource.music.effect_btn_commonclose,
    endCallback  = function()
        -- print("购买至尊卡")
        XTHD.pay(gameData.getDataFromCSV("StoredValue",{id = 8}),4,self)
    end,
    })
    self.zhizuncardUnBuy:addChild(buyBtn2)
    buyBtn2:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height/2 - 135)

    local tip2 = cc.Sprite:create("res/image/activities/monthcard/tip2.png")
    self.zhizuncardBuy:addChild(tip2)
    tip2:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height - 75)
    for i = 1, 4 do
        if self.localData[2]["num"..tostring(i)] ~= nil and self.localData[2]["num"..tostring(i)] > 0 then
            local item = ItemNode:createWithParams({
                _type_ = self.localData[2]["rewardType" .. tostring(i)],
                itemId = self.localData[2]["id" .. tostring(i)],
                count = self.localData[2]["num"..tostring(i)],
				showDrropType = 2,
            })
            item:setScale(0.6)
            self.zhizuncardBuy:addChild(item)
            if i == 1 then
                item:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height/2 + 60)
            else
                local pos = SortPos:sortFromMiddle(cc.p(zhizunBg:getContentSize().width/2 - 5, zhizunBg:getContentSize().height/2 - 20),3,80)
                item:setPosition(pos[i - 1])
            end
           
        end
    end
    local biaoti = cc.Sprite:create("res/image/activities/monthcard/biaoti.png")
    self.zhizuncardBuy:addChild(biaoti)
    biaoti:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height/2 - 85)
    local receiveBtn2 = XTHDPushButton:createWithFile({
    normalFile = "res/image/activities/monthcard/btn1.png",
    selectedFile = "res/image/activities/monthcard/btn2.png",
    musicFile = XTHD.resource.music.effect_btn_commonclose,
    endCallback  = function()
       self:receiveBtnClick(2)
    end,
    })
    self.zhizuncardBuy:addChild(receiveBtn2)
    receiveBtn2:setName("receiveBtn")
    receiveBtn2:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height/2 - 135)
    local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
    receiveBtn2:addChild(fetchSpine)
    fetchSpine:setScaleX(0.75)
    fetchSpine:setScaleY(0.65)
    fetchSpine:setPosition(receiveBtn2:getBoundingBox().width*0.5 + 1, receiveBtn2:getContentSize().height*0.5+2)
    fetchSpine:setAnimation(0, "querenjinjie", true )
    local yilingqu2 = cc.Sprite:create("res/image/activities/chengzhangjijin/yilingqu.png")
    self.zhizuncardBuy:addChild(yilingqu2)
    yilingqu2:setName("yilingqu")
    yilingqu2:setPosition(zhizunBg:getContentSize().width/2 - 5,zhizunBg:getContentSize().height/2 - 135)

    self:freshData()

end

function YueKaAndZhiZunKa:receiveBtnClick(_type)
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
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
    end)
end


function YueKaAndZhiZunKa:freshData()
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

function YueKaAndZhiZunKa:updateTime()
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

function YueKaAndZhiZunKa:create(data)
    return YueKaAndZhiZunKa.new(data)
end

return YueKaAndZhiZunKa