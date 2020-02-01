--  Created by zhangchao on 14-11-03.

XTHDCheckBox = class("XTHDCheckBox", function(params)
    local obj = cc.Sprite:create()
    --如果传入的时字符串就代表是文件名
    if type(params) == "string" and cc.Sprite:create(params) then
        obj = cc.Sprite:create(params)
    end
    return XTHDTouchExtend.extend(obj)
end)


function XTHDCheckBox:ctor(params)
    --创建默认参数
    local defaultParams = {
        normalNode        = nil,--默认状态下显示的node，通常为精灵
        selectedNode      = nil,--选中状态下显示的node,通常为精灵
        normalFile        = nil,--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = nil,--选中状态下显示的精灵的文件名(如果同时传入selectedNode,则优先使用selectedNode)
        needSwallow       = true,--是否吞噬事件
        clickable         = true,--是否可以点击
        check             = false,--默认不选中
        enable            = true,--true代表可点击，false代表不可点击，且按钮变灰，默认为true
        touchSize         = cc.size(0,0),--点击区域，如果没有传值，则默认点击区域为getBoundingBox()
        beganCallback     = nil,
        endCallback       = nil,--
        anchor            = cc.p(0.5,0.5),--锚点
        pos               = cc.p(0,0),--坐标
        x                 = 0,--x
        y                 = 0--y
    }

    --如果接收的是文件名
    if ((params == nil) or (type(params) == "string")) then params = {} end
    for k, v in pairs(defaultParams) do
        if params[k] == nil then
            params[k] = v
        end
    end

    self:setTouchSize(params.touchSize)
    self:setStateNormal(params.normalNode)
    self:setStateSelected(params.selectedNode)
    self:setTouchBeganCallback(params.beganCallback)
    self:setTouchEndedCallback(params.endCallback)
    self:setSwallowTouches(params.needSwallow)
    self:setClickable(params.clickable)
    self:setEnable(params.enable)
    self:setCheck(params.check)
    if params.x ~= nil then
        self:setPositionX(params.x)
    end
    if params.y ~= nil then
        self:setPositionY(params.y)
    end

    if params.pos ~= nil then
        self:setPosition(params.pos)
    end
    if params.anchor ~= nil then
        self:setAnchorPoint(params.anchor)
    end
    --如果传入了普通状态下的文件名，则优先选择该文件名创建的精灵
    if params.normalFile and self.normalNode == nil then
        local normalNode = cc.Sprite:create(params.normalFile)
        self:setStateNormal(normalNode)
    end

    if params.selectedFile and self.selectedNode == nil  then
        local selectedNode = cc.Sprite:create(params.selectedFile)
        self:setStateSelected(selectedNode)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(self._needSwallow)

    --点击事件
    listener:registerScriptHandler(function(touch, event)
        local isVisible = self:isAllParentsVisible(self);
        local isContain = self:isContainTouch(self,touch);
        --父节点可见 and 在触摸区域 and 可点击 and 使能打开 and 非选中状态
        if isVisible and isContain and self:isClickable() and self:isEnable() and self._selected ~= true then
            --响应点击事件
            if self:getTouchBeganCallback() then
                self:getTouchBeganCallback()()
            end
            return true
        end
        return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    --[[滑动事件]]  --貌似没用
    listener:registerScriptHandler(function(touch, event)
        end, cc.Handler.EVENT_TOUCH_MOVED)

    listener:registerScriptHandler(function(touch, event)
        local isVisible = self:isAllParentsVisible(self);
        local isContain = self:isContainTouch(self,touch);
        --[[选中按钮不可见]]
        if isContain then
            if self:getCheck() then
                self:getStateSelected():setVisible(false)
                self:setCheck(false)
            else
                self:getStateSelected():setVisible(true)
                self:setCheck(true)
            end
        end


        --[[如果可见、在触摸区域、可点击，则触发事件]]
        if isVisible and isContain and self:isClickable() and self:isEnable()  then
            if self:getTouchEndedCallback() then
                self:getTouchEndedCallback()()
            end
        end

    end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    --给精灵添加点击事件
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    self._listener = listener

end
--设置正常时的图片精灵
function XTHDCheckBox:setStateNormal(label)
    if self._normalNode ~= label then
        if label ~= nil then
            label:setPosition(cc.p(self:getContentSize().width / 2 , self:getContentSize().height / 2))
            self:addChild(label)
        end

        if self:getStateNormal() then
            self:getStateNormal():removeFromParent()
        end
        self._normalNode = label
    end
    self:_resetChildrenPosition()
end

function XTHDCheckBox:getStateNormal()
    return self._normalNode
end

--设置选中时的图片精灵
function XTHDCheckBox:setStateSelected(label)
    if self._selectedNode ~= label then
        if label ~= nil then
            label:setPosition(cc.p(self:getContentSize().width / 2 , self:getContentSize().height / 2))
            self:addChild(label)
            label:setVisible(self._check)
        end

        if self:getStateSelected() then
            self:getStateSelected():removeFromParent()
        end
        self._selectedNode = label
    end
    self:_resetChildrenPosition()
end

function XTHDCheckBox:getStateSelected()
    return self._selectedNode
end
function XTHDCheckBox:setCheck(flag)
    self._check = flag
    if flag then
        self:getStateSelected():setVisible(true)
    else
        if self:getStateSelected() then
            self:getStateSelected():setVisible(false)
        end
    end
end
function XTHDCheckBox:getCheck()
    return self._check
end
--设置三种状态图片,label等到默认位置
function XTHDCheckBox:_resetChildrenPosition()
    local size = cc.size(0,0)
    if self._normalNode then
        size = cc.size(self._normalNode:getBoundingBox().width , self._normalNode:getBoundingBox().height)
        self:setContentSize(size)
    end

    if self:getStateNormal() then
        self:getStateNormal():setPosition(cc.p(size.width / 2 , size.height / 2))
    end
    if self:getStateSelected() then
        self:getStateSelected():setPosition(cc.p(size.width / 2 , size.height / 2))
    end
end
--是否可以点击
--设置按钮是否可用
function XTHDCheckBox:setEnable(flag)
    self._enable = flag
end
function XTHDCheckBox:isEnable()
    return self._enable
end
--[[创建一个button，该button实质就是一个精灵]]
function XTHDCheckBox:create()
    local obj = XTHDCheckBox.new()
    return obj
end