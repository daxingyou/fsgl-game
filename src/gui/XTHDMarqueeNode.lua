--  Created by zhangchao on 15-05-14.
--[[滚动文字]] --跑马灯
XTHDMarqueeNode = class("XTHDMarqueeNode", function(params)
    return XTHDSprite:create()
end)

XTHDMarqueeNode.data = {}

function XTHDMarqueeNode:ctor(params)
	--创建默认参数
    local defaultParams = {
        text            = "",
        bg 				= IMAGE_KEY_ANNOUNCEMENT_BACK,--[[背景图]]
        fontSize        = 20,--字体大小
        speed           = 50,
        pos             = cc.p(0,0),
        color           = cc.c3b(255, 255, 255),
        anchor          = cc.p(0.5,0.5),--锚点
        needSwallow     = false,--是否需要吞噬事件
        clickable       = true,--是否可以点击
        beganCallback   = nil,--点击事件的按下回调
        endCallback     = nil,--点击事件的抬起回调
        touchSize       = cc.size(0,0),--点击区域，如果没有传值，则默认点击区域为getBoundingBox()
        x               = 0,--x
        y               = 0--y
    }

    if params == nil then params = {} end
    for k, v in pairs(defaultParams) do
        if params[k] == nil then
            params[k] = v
        end
    end
    --[[初始化背景图]]
    local bg 			= params.bg
    local fontSize  	= params.fontSize
    local text 			= params.text
    local pos 			= params.pos
    local anchor 		= params.anchor
    local speed 		= params.speed
    local needSwallow 	= params.needSwallow
    local clickable 	= params.clickable
    local beganCallback = params.beganCallback
    local endCallback 	= params.endCallback

    self:initWithFile(bg)
    self:setAnchorPoint(anchor)
    self:setPosition(pos)

	self:setSwallowTouches(needSwallow)
    self:setClickable(clickable)

    self:setTouchBeganCallback(beganCallback)
    self:setTouchEndedCallback(endCallback)
	--[[初始化数据]]
	self._data = {}
	--[[默认不可见]]
	self:setVisible(false)
	--[[裁剪区域]]
	self:initClipping()

	--[[设置默认速度]]
	self:setSpeed(speed)

	self:setCascadeOpacityEnabled(true)
	self._isRunning = false

	self:setString(text)
end
--[[设置字体大小，可以保证不改变字体样式]]
function XTHDMarqueeNode:setFontSize(fontSize)
    self.__labelNode:setFontSize(fontSize)
end
--[[
@speed  每秒移动的像素
]]
function XTHDMarqueeNode:setSpeed(speed)
	self._speed = speed
end

function XTHDMarqueeNode:_excute()
	if #XTHDMarqueeNode.data > 0 then
		local text = table.remove(XTHDMarqueeNode.data,1)
		self:setVisible(true)

		if self.__labelNode then 
			self.__labelNode:removeFromParent()
		end 
		self.__labelNode = RichLabel:createAnAnnouncement(text)
		self.__labelNode:setAnchorPoint(0,0)
		self.__labelNode:setPosition(self:getContentSize().width - 20,self.__clip:getContentSize().height / 2)
		self.__clip:addChild(self.__labelNode)

		local speed = self._speed
		local len = self.__labelNode:getContentSize().width
		if len < self:getContentSize().width then 
			len = self:getContentSize().width 
		end 
		local time = len / speed
		local x,y = self.__labelNode:getPosition()

		local offsetX = self:getContentSize().width + self.__labelNode:getContentSize().width - 50
		local move = cc.MoveTo:create(time,cc.p(-offsetX,y))
		local call = cc.CallFunc:create(function( )
			self:_excute()
		end)
		local action = cc.Sequence:create(move,call)
		action:setTag(1)
		self.__labelNode:runAction(action)
	else
		if self.__labelNode then 
			self.__labelNode:removeFromParent()
			self.__labelNode = nil
		end 
		self._isRunning = false
		self:runAction(cc.FadeOut:create(0.2))
	end
end

function XTHDMarqueeNode:setString(text)
	if text == nil or string.len(tostring(text)) < 1 then
		return
	end
	self:insertAData(text)
	self:run()
end

function XTHDMarqueeNode:run( )
	if self._isRunning == false then 
		self._isRunning = true
		self:runAction(cc.FadeIn:create(0.2))
		self:_excute()
	end 
end

function XTHDMarqueeNode:create()
    return XTHDMarqueeNode.new()
end

function XTHDMarqueeNode:createWithParams(params)
    return XTHDMarqueeNode.new(params)
end

function XTHDMarqueeNode:setSource( data )
	if data then 
		self:insertAData(data)
		if self._isRunning == false then
			self._isRunning = true
			self:runAction(cc.FadeIn:create(0.2))
			self:_excute()
		end
	end 
end

function XTHDMarqueeNode:initClipping( )
    local list = ccui.ListView:create()
    self:addChild(list)
    list:setContentSize(cc.size(self:getContentSize().width - 10,self:getContentSize().height))
    list:setAnchorPoint(0,0)
    list:setPosition(10,0)

    local layout = ccui.Layout:create()
    layout:setContentSize(list:getContentSize())
    list:pushBackCustomItem(layout)
    self.__clip = layout
end

function XTHDMarqueeNode:insertAData( data )
	if data then 
		table.insert(XTHDMarqueeNode.data,1,data)
		if #XTHDMarqueeNode.data > 50 then 
			table.remove(XTHDMarqueeNode.data)
		end 
	end 
	-- print("跑马灯的数据为：")
	-- print_r(XTHDMarqueeNode.data)
end