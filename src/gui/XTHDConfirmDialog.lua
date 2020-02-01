--  Created by zhangchao on 15-04-27.
XTHDConfirmDialog = class("XTHDConfirmDialog", function(params)
    return XTHDPopLayer:create()
end )

--[[ 设置左边按钮的点击事件 ]]
function XTHDConfirmDialog:setCallbackLeft(callback)
    self._btn_left:setTouchEndedCallback(callback)
end

--[[ 设置右边按钮的点击事件,如有需要可以在这里手动移除pop弹窗 ]]
function XTHDConfirmDialog:setCallbackRight(callback)
    self._btn_right:setTouchEndedCallback(callback)
end

--[[ 设置关闭回调 ]]
function XTHDConfirmDialog:setCallbackClose(callback)
    self.closeCallback = callback or nil
end

--设置提示语
function XTHDConfirmDialog:setMsg(msg)
    self.msgText:setString(msg)
end

--[[ 获取弹出框文字背景 ]]
function XTHDConfirmDialog:getContainer()
    return self.containerBg or nil
end

function XTHDConfirmDialog:ctor(params)
    local default = {
        msg = "",
        contentNode = nil,
        --- 中间需要显示的内容，如果是纯文本，传入msg即可，此值为默认值
        leftText = LANGUAGE_BTN_KEY.cancel,
        rightText = LANGUAGE_BTN_KEY.sure,
        leftVisible = true,
        rightVisible = true,
        leftLabel = nil,
        rightLabel = nil,
        fontSize = 18,
        leftCallback = nil,
        rightCallback = nil,
        closeCallback = nil,
        isHide = true,
        rightFrame = "queding_lv",
        leftFrame = "quxiao_hong",
    }

    if params == nil then params = { } end
    for k, v in pairs(default) do
        if params[k] == nil then
            params[k] = v
        end
    end

    local msg = params.msg
    local contentNode = params.contentNode
    local fontSize = params.fontSize
    local leftText = params.leftText
    local rightText = params.rightText
    local leftLabel = params.leftLabel
    local rightLabel = params.rightLabel
    local leftVisible = params.leftVisible
    local rightVisible = params.rightVisible
    local leftCallback = params.leftCallback
    local rightCallback = params.rightCallback
    local closeCallback = params.closeCallback
    local isHide = params.isHide
    local rightFrame = params.rightFrame
    local leftFrame = params.leftFrame

    self:setLeftTouchEndedCallback(leftCallback)
    self:setRightTouchEndedCallback(rightCallback)

    local width = self:getContentSize().width
    local height = self:getContentSize().height

    local bg_sp = ccui.Scale9Sprite:create(cc.rect(0, 0, 0, 0), "res/image/common/scale9_bg1_34.png")
    bg_sp:setContentSize(475, 328)
    self.containerBg = bg_sp
    bg_sp:setCascadeOpacityEnabled(true)
    bg_sp:setPosition(width / 2, height / 2)
    self:addContent(bg_sp)
    -- 后面小的框
    local bg_sp2 = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    bg_sp2:setContentSize(bg_sp:getContentSize().width - 40, bg_sp:getContentSize().height - 130)
    bg_sp2:setPosition(bg_sp:getContentSize().width / 2, bg_sp:getContentSize().height / 2 + 30)
    -- bg_sp2:setScale(0.5)
    bg_sp:addChild(bg_sp2)
	self._bgsp = bg_sp2

    -- local title_txt  = XTHDLabel:create("购买次数",18)
    -- title_txt:setPosition(bg_sp:getContentSize().width/2,bg_sp:getContentSize().height-20)
    -- bg_sp:addChild(title_txt)

    local txt_content = nil
    if not contentNode then
        txt_content = XTHDLabel:create(msg, fontSize)
        txt_content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        txt_content:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        txt_content:setColor(XTHD.resource.color.gray_desc)
        -- 解决文字过短居中的问题
        if tonumber(txt_content:getContentSize().width) < 326 then
            txt_content:setDimensions(tonumber(txt_content:getContentSize().width), 120)
        else
            txt_content:setDimensions(326, 120)
        end
    else
        txt_content = contentNode
    end
    txt_content:setName("txt_content")
    txt_content:setPosition(bg_sp:getContentSize().width / 2, bg_sp:getContentSize().height / 2 + 30)
    bg_sp:addChild(txt_content)
    self.msgText = txt_content

    local btn_left = XTHD.createCommonButton( {
        btnColor = "write_1",
        btnSize = cc.size(200,80),
        isScrollView = false,
        musicFile = XTHD.resource.music.effect_btn_common,
        text = leftText,
        -- text              = leftLabel == nil and leftText or nil,
        -- label             = leftLabel,
        fontSize = 26,
        pos = cc.p(100 + 5,50),
        endCallback = function()
            if self._left_callback_running == true then
                return
            end
            self._left_callback_running = true

            if self:getLeftTouchEndedCallback() then
                self:getLeftTouchEndedCallback()()
            end
            if isHide == true then
                self:hide( { music = true })
            end
        end
    } )
    btn_left:setScale(0.6)
    btn_left:setCascadeOpacityEnabled(true)
    btn_left:setOpacity(255)
    bg_sp:addChild(btn_left)
    ------------be added artistic word
    -- local _label = cc.Sprite:createWithSpriteFrame(XTHD.resource.getButtonImgFrame(leftFrame))
    -- btn_left:addChild(_label)
    -- _label:setPosition(btn_left:getContentSize().width / 2,btn_left:getContentSize().height / 2)

    local btn_right = XTHD.createCommonButton( {
        btnColor = "write",
        btnSize = rightLabel and cc.size(200,80) or cc.size(200,80),
        musicFile = XTHD.resource.music.effect_btn_common,
        isScrollView = false,
        text = rightText,
        -- label             = rightLabel,
        fontSize = 26,
        pos = cc.p(bg_sp:getContentSize().width - 100 - 5,btn_left:getPositionY()),
        endCallback = function()
            if self._right_callback_running == true then
                return
            end
            self._right_callback_running = true

            if self:getRightTouchEndedCallback() then
                self:getRightTouchEndedCallback()()
            end
            if isHide == true then
                xpcall( function()
                    self:hide( { music = true })
                end
                , function()
                    print("XTHDConfirmDialog已经被移除了，在这里你又移除？")
                    cclog("----------------------------------------")
                    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
                    cclog(debug.traceback())
                    cclog("----------------------------------------")
                end )
            end
        end
    } )
    btn_right:setScale(0.6)
    btn_right:setCascadeOpacityEnabled(true)
    btn_right:setOpacity(255)
    bg_sp:addChild(btn_right)
    ------------be added artistic word
    -- if not rightLabel then
    --     local _label = cc.Sprite:createWithSpriteFrame(XTHD.resource.getButtonImgFrame(rightFrame))
    --     btn_right:addChild(_label)
    --     _label:setPosition(btn_right:getContentSize().width / 2,btn_right:getContentSize().height / 2)
    -- end
    self.closeCallback = closeCallback or nil

    self._btn_left = btn_left
    self._btn_right = btn_right

    if leftVisible == false then
        btn_left:setVisible(false)
        btn_right:setPositionX(bg_sp:getContentSize().width / 2)
    end

    if rightVisible == false then
        btn_right:setVisible(false)
        btn_left:setPositionX(bg_sp:getContentSize().width / 2)
    end

    self:show(true)
end

function XTHDConfirmDialog:getBgImage()
    return self._bgsp
end

function XTHDConfirmDialog:setLeftTouchEndedCallback(callback)
    self._leftTouchEndedCallback = callback
end

function XTHDConfirmDialog:getLeftTouchEndedCallback()
    return self._leftTouchEndedCallback or nil
end

function XTHDConfirmDialog:setRightTouchEndedCallback(callback)
    self._rightTouchEndedCallback = callback
end

function XTHDConfirmDialog:getRightTouchEndedCallback()
    return self._rightTouchEndedCallback or nil
end

function XTHDConfirmDialog:onExit()
    if self.closeCallback then
        self.closeCallback()
    end
end

function XTHDConfirmDialog:createWithParams(params)
    local layer = XTHDConfirmDialog.new(params)
    return layer

end

function XTHDConfirmDialog:getLeftButton()
    return self._btn_left
end

function XTHDConfirmDialog:getRightButton()
    return self._btn_right
end
