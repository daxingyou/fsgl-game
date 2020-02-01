--author hezhitao 2015.07.08
--兑换激活码
local ExchangeCodePop1 = class("ExchangeCodePop1",function()
    return XTHDPopLayer:create()
end)

local fontColor = cc.c3b(54,55,112)
function ExchangeCodePop1:ctor()

	self:init()
    self:setTouchEndedCallback(function (  )
        
    end)
end

function ExchangeCodePop1:init()

    local _bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png" )
    _bg:setContentSize(549,350)
    --框
    local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    kuang:setContentSize(500,200)
    kuang:setPosition(_bg:getContentSize().width/2,_bg:getContentSize().height/2+10)
    _bg:addChild(kuang)

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
        text = LANGUAGE_TIPS_WORDS136,------"请输激活码",
        fontSize = 20,
        color = fontColor,
        ttf = "res/fonts/def.ttf"
        })
    input_label:setPosition(popNode:getContentSize().width/2,popNode:getContentSize().height-35)
    popNode:addChild(input_label)

	local input_bg_account = ccui.Scale9Sprite:create("res/image/login/login_input_bg.png")
    input_bg_account:setContentSize(300,40)
    input_bg_account:setPosition(cc.p(popNode:getContentSize().width / 2+20 , popNode:getContentSize().height/2))
    popNode:addChild(input_bg_account)

    local input_num = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS137,-----"激活码:",
        fontSize = 20,
        color = fontColor,
        ttf = "res/fonts/def.ttf"
        })
    input_num:setAnchorPoint(0,0.5)
    input_num:setPosition(60,input_bg_account:getPositionY())
    popNode:addChild(input_num)



	--输入框
	local editbox_account = ccui.EditBox:create(cc.size(300,input_bg_account:getContentSize().height), ccui.Scale9Sprite:create(),nil,nil)
    editbox_account:setFontColor(cc.c3b(255,255,255))
    editbox_account:setPlaceHolder(LANGUAGE_TIPS_WORDS138)------"输入激活码")
    editbox_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    editbox_account:setAnchorPoint(0,0.5)
    editbox_account:setMaxLength(30)
    editbox_account:setPosition(0 , input_bg_account:getContentSize().height/2)
    editbox_account:setPlaceholderFontColor(cc.c3b(255,255,255))
    editbox_account:setFontName("Helvetica")
    editbox_account:setPlaceholderFontName("Helvetica")
    editbox_account:setFontSize(24)
    editbox_account:setPlaceholderFontSize(24)
    editbox_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    input_bg_account:addChild(editbox_account)


    function exchange(  )
        local _str = tostring(editbox_account:getText() or "")
        ClientHttp:requestAsyncInGameWithParams({
            modules = "activateGift?",
            params = {code=_str},
            successCallback = function(data)
            -- dump(data,"datadatadata")
            if tonumber(data.result) == 0 then
                if data.property then
                    for i=1,#data.property do
                        local pro_data = string.split( data.property[i],',')
                        gameUser.updateDataById(pro_data[1],pro_data[2])
                    end
                end
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
                local _rewarddbid = nil
                for i=1,#data["bagItems"] do
                    local _dbid = data.bagItems[i].dbId
                    _rewarddbid = _dbid
                    if data.bagItems[i].count and tonumber(data.bagItems[i].count)>0 then
                        DBTableItem.updateCount(gameUser.getUserId(),data.bagItems[i],_dbid)
                    else
                        DBTableItem.deleteData(gameUser.getUserId(),_dbid)
                    end
                end
                local _rewardTable = {}
                local _showTable = string.split(data.rewards,",")
                if _showTable~=nil and next(_showTable)~=nil then
                    for i=1,#_showTable do
                        local _rewardData = string.split(_showTable[i],"#")
                        if _rewardData[3] and tonumber(_rewardData[3])>0 then
                            local _index = #_rewardTable + 1
                            _rewardTable[_index] = {}
                            _rewardTable[_index].rewardtype = tonumber(_rewardData[1]) or 1
                            _rewardTable[_index].id = tonumber(_rewardData[2]) or 1
                            _rewardTable[_index].num = tonumber(_rewardData[3]) or 0
                        end
                    end    
                end
                ShowRewardNode:create(_rewardTable)
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
        -- XTHDTOAST("接口暂没实现")
    end


	local itemGet_btn = XTHD.createCommonButton({
        btnColor = "write",
        isScrollView = false,
        text = LANGUAGE_KEY_SURE,
        fontSize = 22,
        endCallback = function ()
            exchange()
        end
    })
    itemGet_btn:setScale(0.8)
    itemGet_btn:setPosition(cc.p(popNode:getContentSize().width/2,50))
    popNode:addChild(itemGet_btn)

	self:show()
end

function ExchangeCodePop1:create()
	local _layer = self.new()
	return _layer
end

return ExchangeCodePop1