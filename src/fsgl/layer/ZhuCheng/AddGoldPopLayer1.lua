--author hezhitao 2015.07.08
local AddGoldPopLayer1 = class("AddGoldPopLayer1",function()
    return XTHDPopLayer:create()
end)

local fontColor = cc.c3b(53,25,26)
function AddGoldPopLayer1:ctor()

	self:init()
    self:setTouchEndedCallback(function (  )
        
    end)
end

function AddGoldPopLayer1:init()

    local _bg = ccui.Scale9Sprite:create( cc.rect(40,40,1,2), "res/image/common/scale9_bg_34.png" )
    _bg:setContentSize(375,228)
	local popNode = XTHDPushButton:createWithParams({
        normalNode = _bg
    }) --18211131064 13552939199
    popNode:setTouchEndedCallback(function ()

    end)
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addContent(popNode)
    self.popNode = popNode

    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(popNode:getContentSize().width-20,popNode:getContentSize().height-20)
    popNode:addChild(close)


    local input_label = XTHDLabel:createWithParams({
        text = LANGUAGE_MAINCITY_TIPS1,------"请输入要充值的金额",
        fontSize = 20,
        color = fontColor
        })
    input_label:setPosition(popNode:getContentSize().width/2,popNode:getContentSize().height-45)
    popNode:addChild(input_label)

	local input_bg_account = ccui.Scale9Sprite:create("res/image/common/op_white.png")
    input_bg_account:setContentSize(340,40)
    input_bg_account:setPosition(cc.p(popNode:getContentSize().width / 2 , popNode:getContentSize().height/2+20))
    popNode:addChild(input_bg_account)

    local input_num = XTHDLabel:createWithParams({
        text = LANGUAGE_MAINCITY_TIPS2,-----"金    额:",
        fontSize = 20,
        color = fontColor
        })
    input_num:setAnchorPoint(0,0.5)
    input_num:setPosition(20,input_bg_account:getContentSize().height/2)
    input_bg_account:addChild(input_num)



	--输入框
	local editbox_account = ccui.EditBox:create(cc.size(300,input_bg_account:getContentSize().height), ccui.Scale9Sprite:create(),nil,nil)
    editbox_account:setFontColor(cc.c3b(92,91,91))
    editbox_account:setPlaceHolder(LANGUAGE_MAINCITY_TIPS3)------"输入需要充值的数量")
    editbox_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    editbox_account:setAnchorPoint(0,0.5)
    editbox_account:setMaxLength(30)
    editbox_account:setPosition(116 , input_bg_account:getPositionY())
    editbox_account:setPlaceholderFontColor(cc.c3b(181,181,181))
    editbox_account:setFontName("Helvetica")
    editbox_account:setPlaceholderFontName("Helvetica")
    editbox_account:setFontSize(24)
    editbox_account:setPlaceholderFontSize(24)
    editbox_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    popNode:addChild(editbox_account)


    function addGold( count )
        ClientHttp:requestAsyncInGameWithParams({
            modules = "addGold?",
            params = {gold=tonumber(count)},
            successCallback = function(data)
            -- dump(data,"datadatadata")
            if tonumber(data.result) == 0 then
                for i=1,#data["property"] do
                    local pro_data = string.split( data["property"][i],',')
                      --当前VIP等级发生变化时显示
                    if tonumber(pro_data[1]) == 406 then   --判断当前VIP
                        if tonumber(pro_data[2]) > tonumber(gameUser.getVip()) then
                            gameUser.setVip(pro_data[2])
                            local vip_levelup = requires("src/fsgl/layer/Vip/VipLevelUpLayer1.lua")
                            cc.Director:getInstance():getRunningScene():addChild(vip_levelup:create(true))
                        end
                        
                    end
                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
                end

                --设置银两、翡翠兑换次数
                gameUser.setGoldSurplusExchangeCount(data["silverSurplusSum"])
                gameUser.setFeicuiSurplusExchangeCount(data["feicuiSurplusSum"])
                gameUser.setIngotTotal(data["totalIngot"])

                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})      --刷新topbar数据
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，

                self:hide()
            else
                XTHDTOAST(data.msg)
            end
            end,--成功回调
            failedCallback = function()
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end


	local itemGet_btn = XTHD.createCommonButton({
        text = LANGUAGE_KEY_SURE,
        btnSize = cc.size(130, 51),
        isScrollView = false,
        fontSize = 22,
        endCallback = function ()
            local count = tonumber(editbox_account:getText()) or 0
            if count < 1 then
                XTHDTOAST(LANGUAGE_MAINCITY_TIPS4)------"请输入数字，并且数字大于0")
            else
               addGold(count)
            end
        end
    })
    itemGet_btn:setPosition(cc.p(popNode:getContentSize().width/2,50))
    popNode:addChild(itemGet_btn)

	self:show()
end

function AddGoldPopLayer1:create()
	local _layer = self.new()
	return _layer
end

return AddGoldPopLayer1