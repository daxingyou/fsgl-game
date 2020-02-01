--[[
资源缺少公共pop框by.huangjunjian 2015.7.15
参数：1.元宝不足2.体力不足3.银两不足4.翡翠不足5.强化石不足 6.幸运币不足
changed by xingchen 2016/1/13
]]
local SourceLackPop1=class("SourceLackPop1",function ()
	return XTHDConfirmDialog:createWithParams()
end)
function SourceLackPop1:ctor(data)
    local id = 1
    self.endCallback=nil
    if data.Callback then
        self.endCallback=data.Callback
        print(self.endCallback)
    end
    if data and data.id then
        id = data.id
    end
	self:initUi(id)
end

function SourceLackPop1:onCleanup()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TASKLIST })
end

function SourceLackPop1:initUi(ID)
    local _sourceId = tonumber(ID)
    if _sourceId == 2 then
        self:TiliLack(_sourceId)
    elseif _sourceId>0 and _sourceId<7 then
        self:GoldLack(_sourceId)
    end
	self:show()
end
--[[
体力
]]
function SourceLackPop1:TiliLack()
	local canbuy=true
	local txt_content  = nil 
    local txt_content2  = nil 
    local playerVip = tostring("vip" .. gameUser.getVip())
    local canBuyTimes = tonumber( gameData.getDataFromCSV("VipInfo", {["id"] = 3})[playerVip] )  --根据VIP取表
    local timesBought = tonumber(gameUser.getTiliBuyCount())
    local thisTimeCost = tonumber(gameData.getDataFromCSV("BuySteamedBuns", {["buyphysicaltimes"] = timesBought+1 })["costingot"] )  --根据(timesBought+1)取表  花元宝
  
    local bg_sp = self.containerBg

    if not contentNode then 
        txt_content = XTHDLabel:create("txt_content",18)
        txt_content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
        txt_content:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        txt_content:setColor(XTHD.resource.color.gray_desc)
        txt_content2 = XTHDLabel:create("txt_content2",18)
        txt_content2:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
        txt_content2:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        txt_content2:setColor(XTHD.resource.color.gray_desc)
        --解决文字过短居中的问题
        -- if tonumber(txt_content:getContentSize().width)<300 then
        --     txt_content:setDimensions(tonumber(txt_content:getContentSize().width), 50)
        -- else
        --     txt_content:setDimensions(306, 50)
        -- end
    else 
        txt_content = contentNode
    end
    if timesBought < canBuyTimes then
        txt_content:setString(LANGUAGE_FORMAT_TIPS33(thisTimeCost,100)) --------"确定花费" .. thisTimeCost .. "元宝购买100点体力？")
        txt_content2:setString(LANGUAGE_TIPS_LASTBUYTILITIMES(tostring(canBuyTimes-timesBought))) ------剩余购买体力次数:"
    else
        txt_content:setString(LANGUAGE_TIPS_WORDS161)------今日购买次数已用完 
        txt_content2:setString(LANGUAGE_TIPS_TILI_NOTIMES)
        canbuy=false
    end
    txt_content:setPosition(bg_sp:getContentSize().width/2,bg_sp:getContentSize().height/2 + 30)
    bg_sp:addChild(txt_content)
    txt_content2:setPosition(bg_sp:getContentSize().width/2,bg_sp:getContentSize().height/2 )
    bg_sp:addChild(txt_content2)
    self:setCallbackRight(function (  )
        if canbuy==true then
            ClientHttp:requestAsyncInGameWithParams({
                modules = "buyTili?",
                params = {},
                successCallback = function(data)
                    if tonumber(data.result) == 0 then
                        gameUser.setTiliNow(data.curTili)
                        gameUser.setIngot(data.ingot)
                        gameUser.setTiliBuyCount(data.buyCount)
                       local  thisCost = tonumber(gameData.getDataFromCSV("BuySteamedBuns", {["buyphysicaltimes"] = tonumber(gameUser.getTiliBuyCount())+1 })["costingot"] )
                            if tonumber(gameUser.getTiliBuyCount()) < canBuyTimes then
                                txt_content:setString(LANGUAGE_FORMAT_TIPS33(thisCost,100)) --------"确定花费" .. thisTimeCost .. "元宝购买100点体力？")
                                txt_content2:setString(LANGUAGE_TIPS_LASTBUYTILITIMES(tostring(canBuyTimes-data.buyCount))) ------剩余购买体力次数:"
                            else
                                txt_content :setString(LANGUAGE_TIPS_WORDS161)-------"今天不能再购买，明天再试")
                                canbuy=false
                                txt_content2:setString(LANGUAGE_TIPS_TILI_NOTIMES)

                                local left = self:getLeftButton()
                                local right = self:getRightButton()
                                left:setVisible(false)
                                right:setPositionX(self.containerBg:getContentSize().width/2)
                            end
                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
                        if self.endCallback and type(self.endCallback) == "function" then
                            self.endCallback()
                        end
                    elseif tonumber(data.result) == 2004 then
                        self:removeFromParent()
                        local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=1})
                        cc.Director:getInstance():getRunningScene():addChild(StoredValue)
                    else
                        XTHDTOAST(data.msg)
                    end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
        else
            self:removeFromParent()
        end
    end)

    self:setCallbackLeft(function (  )
        self:removeFromParent()
    end)
    
    if canbuy == false then
        local left = self:getLeftButton()
        local right = self:getRightButton()
        left:setVisible(false)
        right:setPositionX(self.containerBg:getContentSize().width/2)
    end
end 
--[[
元宝
]]  
function SourceLackPop1:GoldLack(id)
	local bg_sp = self.containerBg
    local txt_content  = nil

    if not contentNode then 
        txt_content = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.noEnoughCoinTextXc,18)-------"元宝不足，是否前往充值?",18)
        -- if id==1 then 
        --     -- txt_conten:setString("元宝不足，是否前往充值?")
        -- elseif id==3 then
        --     txt_content:setString(LANGUAGE_KEY_HERO_TEXT.noEnoughGoldAndNoTimes)
        --     -- if tonumber(gameUser.getGoldSurplusExchangeCount()) >0 then
        --     --     txt_content:setString(LANGUAGE_KEY_HERO_TEXT.noEnoughGold)-------"银两不足，是否前往兑换！")
        --     -- else
        --     --     txt_content:setString(LANGUAGE_KEY_HERO_TEXT.noEnoughGoldAndNoTimes)-------"银两不足，且兑换次数已用完，是否前往竞技场抢夺?")
        --     -- end
        -- elseif id==4 then
        --     txt_content:setString(LANGUAGE_KEY_HERO_TEXT.noEnoughJadeAndNoTimes)-------"翡翠不足，且兑换次数已用完，是否前往竞技场抢夺?")
            
        --     -- if tonumber(gameUser.getFeicuiSurplusExchangeCount())>0 then
        --     --     txt_content:setString(LANGUAGE_KEY_HERO_TEXT.noEnoughJade)------"翡翠不足，是否前往兑换！")
        --     -- else
        --     --     txt_content:setString(LANGUAGE_KEY_HERO_TEXT.noEnoughJadeAndNoTimes)-------"翡翠不足，且兑换次数已用完，是否前往竞技场抢夺?")
        --     -- end
        -- elseif id == 5 then
        --     txt_content:setString(LANGUAGE_KEY_HERO_TEXT.noStrengthStone)------"强化石不足，是否前往兑换！")
        -- else
        if id == 6 then
            txt_content:setString(LANGUAGE_KEY_LUCKYTURN.noEnoughLuckyMoney)
        end
        txt_content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
        txt_content:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        txt_content:setColor(XTHD.resource.color.gray_desc)
        --解决文字过短居中的问题
        if tonumber(txt_content:getContentSize().width)<306 then
            txt_content:setDimensions(tonumber(txt_content:getContentSize().width), 120)
        else
            txt_content:setDimensions(306, 120)
        end
    else 
        txt_content = contentNode
    end
    txt_content:setPosition(bg_sp:getContentSize().width/2,bg_sp:getContentSize().height/2 + 30)
    bg_sp:addChild(txt_content)
    self:setCallbackRight(function (  )
        -- if id==1 then
        --     -- XTHDTOAST("what ara you wang na jump")
        --     XTHD.createRechargeVipLayer(self:getParent(),cc.Director:getInstance():getRunningScene())
        -- elseif id==3 then
        --     txt_content:setString(LANGUAGE_KEY_HERO_TEXT.noEnoughGoldAndNoTimes)------"银两不足，且兑换次数已用完，是否前往竞技场抢夺?")
        --     XTHD.createCompetitiveLayer(cc.Director:getInstance():getRunningScene())
        -- elseif id==4 then
        --     txt_content:setString(LANGUAGE_KEY_HERO_TEXT.noEnoughJadeAndNoTimes)-------"翡翠不足，且兑换次数已用完，是否前往竞技场抢夺?")
        --     XTHD.createCompetitiveLayer(cc.Director:getInstance():getRunningScene())
        -- elseif id ==5 then
        --     replaceLayer({id = 5})
        -- else
        if id == 6 then
            XTHD.createRechargeVipLayer( cc.Director:getInstance():getRunningScene())
        end
        self:removeFromParent()
    end)

    self:setCallbackLeft(function (  )
        self:removeFromParent()
    end)
 end 
 function SourceLackPop1:create(data)
    -- data.id = math.random(1,6)
    if data.id and tonumber(data.id) == 2 or tonumber(data.id) == 6 then
        return SourceLackPop1.new(data)
    elseif data.id then
        local StoredValue = requires("src/fsgl/layer/common/SourceLackDetailPop1.lua"):create(data.id)
        return StoredValue
    end
 end
return SourceLackPop1