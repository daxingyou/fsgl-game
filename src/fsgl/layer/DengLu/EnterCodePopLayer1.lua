local EnterCodePopLayer1 = class("EnterCodePopLayer1",function()
		return XTHDPopLayer:create()
	end)
local fontColor = cc.c3b(53,25,26)
function EnterCodePopLayer1:ctor()
	local _bg = ccui.Scale9Sprite:create( cc.rect(40,40,1,2), "res/image/common/scale9_bg_34.png" )
    _bg:setContentSize(375,228)
	local popNode = XTHDPushButton:createWithParams({
                        normalNode = _bg
                    }) --18211131064 13552939199
    popNode:setTouchEndedCallback(function ()
        print("点到背景了")
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
        text = LANGUAGE_KEY_INPUT_WORDA,-------"请输入",
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
        text = LANGUAGE_KEY_CHARACTOR..":",------字符:",
        fontSize = 20,
        color = fontColor
        })
    input_num:setAnchorPoint(0,0.5)
    input_num:setPosition(20,input_bg_account:getContentSize().height/2)
    input_bg_account:addChild(input_num)



	--输入框
	local editbox_account = ccui.EditBox:create(cc.size(300,input_bg_account:getContentSize().height), ccui.Scale9Sprite:create(),nil,nil)
    editbox_account:setFontColor(cc.c3b(92,91,91))
    editbox_account:setPlaceHolder(LANGUAGE_KEY_INPUT_WORDA)------"输入需要的字符")
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

	local itemGet_btn = XTHD.createCommonButton({
        text = LANGUAGE_KEY_SURE,
        isScrollView = false,
        btnSize = cc.size(130, 51),
        fontSize = 22,
        endCallback = function ()
            if editbox_account:getText() == nil  or string.len(editbox_account:getText()) < 1 then
                XTHDTOAST(LANGUAGE_INPUTTIPS1)------"请输入数字，并且数字大于0")
            else
            	HTTP_VALID = editbox_account:getText()
        		self:hide()
            end
        end
    })
    itemGet_btn:setPosition(cc.p(popNode:getContentSize().width/2,50))
    popNode:addChild(itemGet_btn)

	self:show()
end

function EnterCodePopLayer1:init()


end

function EnterCodePopLayer1:create()
	local _layer = self.new()
	return _layer
end

return EnterCodePopLayer1