XTHDLabel = class("XTHDLabel", function(params)
	local label = cc.Label:create()
	return XTHDTouchExtend.extend(label)
end )
function XTHDLabel:ctor(params)
	local defaultParams = {
		text = "",
		fontSize = nil,
		size = nil,
		ttf = nil,
		fnt = nil,
		kerning = 0,
		pos = cc.p(0,0),
		color = cc.c3b(255,255,255),
		anchor = cc.p(0.5,0.5),
		needSwallow = false,
		clickable = true,
		beganCallback = nil,
		endCallback = nil,
		touchSize = cc.size(0,0),
		x = 0,
		y = 0
	}
	if params == nil then
		params = { }
	end
	for k, v in pairs(defaultParams) do
		if params[k] == nil then
			params[k] = v
		end
	end
	local fontSize = 30
	if params.size ~= nil then
		fontSize = tonumber(params.size)
	elseif params.fontSize ~= nil then
		fontSize = tonumber(params.fontSize)
	end
	self:setString(params.text)
	self:setColor(params.color)
	if params.fnt ~= nil and type(params.fnt) == "string" and 0 < string.len(params.fnt) then
		self:setBMFontFilePath(params.fnt)
		self:setAdditionalKerning(params.kerning)
	elseif params.ttf ~= nil and type(params.ttf) == "string" and 0 < string.len(params.ttf) then
		local ttfConfig = { }
		ttfConfig.fontFilePath = params.ttf
		ttfConfig.fontSize = fontSize
		self:setTTFConfig(ttfConfig)
	else
		params.ttf = "res/fonts/def.ttf"
		local ttfConfig = { }
		ttfConfig.fontFilePath = params.ttf
		ttfConfig.fontSize = fontSize
		self:setTTFConfig(ttfConfig)
		--    self:setSystemFontName("Helvetica")
		--    self:setSystemFontSize(fontSize)
	end
	self:setCascadeOpacityEnabled(true)
	self._fontSize = fontSize
	self._ttf = params.ttf
	self._fnt = params.fnt
	self:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self:setSwallowTouches(params.needSwallow)
	self:setClickable(params.clickable)
	self:setTouchBeganCallback(params.beganCallback)
	self:setTouchEndedCallback(params.endCallback)
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
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(self._needSwallow)
	listener:registerScriptHandler( function(touch, event)
		local isVisible = self:isAllParentsVisible(self)
		local isContain = self:isContainTouch(self, touch)
		if isVisible and isContain and self:isClickable() then
			if self:getTouchBeganCallback() then
				self:getTouchBeganCallback()()
			end
			return true
		end
		return false
	end , cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler( function(touch, event)
	end , cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler( function(touch, event)
		local isVisible = self:isAllParentsVisible(self)
		local isContain = self:isContainTouch(self, touch)
		if isVisible and isContain and self:isClickable() and self:getTouchEndedCallback() then
			self:getTouchEndedCallback()()
		end
	end , cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	self._listener = listener
end
function XTHDLabel:setFontSize(fontSize)
	if self._ttf ~= nil then
		local ttfConfig = self:getTTFConfig()
		ttfConfig.fontSize = fontSize
		self:setTTFConfig(ttfConfig)
	else
		self:setSystemFontSize(fontSize)
	end
	self._fontSize = fontSize
end
function XTHDLabel:createWithParams(params)
	local label = XTHDLabel.new(params)
	return label
end
function XTHDLabel:create(text, fontSize, ttf)
	local label = XTHDLabel:createWithParams( {
		text = text,
		ttf = ttf,
		fontSize = fontSize
	} )
	return label
end

function XTHDLabel:createWithSystemFont(text, font, fontSize)
    --替换cc.Label:createWithSystemFont，以便于整体字体格式统一
    local label = XTHDLabel:createWithParams( {
        text = text,
        fontSize = fontSize
    } )
    return label
end