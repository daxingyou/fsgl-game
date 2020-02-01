--[[
-----玩家在准备界面喊话

┏━━━┛┻━━━┛┻━━┓
┃｜｜｜｜｜｜｜┃
┃　　　━　　　 ┃
┃　┳┛ 　┗┳  　┃
┃　　　　　　　┃
┃　　　┻　　 　┃
┃　　　　　　　┃
┗━━┓　　　┏━┛
　　┃　史　┃　　
　　┃　诗　┃　　
　　┃　之　┃　　
　　┃　宠　┃
　　┃　　　┗━━━┓
　　┃         ┣┓
　　┃　　　  　┃
　　┗┓┓ ┏━┳┓ ┏┛
　　　┃┫┫　┃┫┫
　　　┗┻┛　┗┻┛
神兽镇楼，代码永无bug
]]

local DuoRenFuBenSpeekWord = class("DuoRenFuBenSpeekWord",function( )
	return cc.Layer:create()
end)

function DuoRenFuBenSpeekWord:ctor(triggerTarg,parent)
	self._triggerTarg = triggerTarg
	self._parent = parent
	self._wordList = {} ----能选择的话列表
	self._usefulBg = nil 
	self._usefulBgRect = cc.rect(0,0,0,0)
end

function DuoRenFuBenSpeekWord:create(triggerTarg,parent)
	local layer = DuoRenFuBenSpeekWord.new(triggerTarg,parent)
	if layer then 
		layer:init()
		layer:registerScriptHandler(function(_type)
			if _type == "enter" then 
				layer:onEnter()
			elseif _type == "exit" then 
				layer:onExit()
			elseif _type == "cleanup" then 
				layer:onCleanup()
			end 
		end)
	end 
	return layer	
end

function DuoRenFuBenSpeekWord:onEnter( )
    --开始注册点击事件
    local function touchBegan( touch,event )
        return true
    end

    local function touchMoved( touch,event )
    	
    end

    local function touchEnded( touch,event )
    	local pos = touch:getLocation()
    	if cc.rectContainsPoint(self._usefulBgRect,pos) then 
    		return 
    	else 
    		self:removeFromParent()
    	end 
    end

    self._listener = cc.EventListenerTouchOneByOne:create()
    self._listener:setSwallowTouches(true)
    self._listener:registerScriptHandler(touchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self._listener:registerScriptHandler(touchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._listener:registerScriptHandler(touchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._listener, self)
    -------------------------------------------------------------------------------------------
end

function DuoRenFuBenSpeekWord:onExit( )
	
end

function DuoRenFuBenSpeekWord:onCleanup( )

end

function DuoRenFuBenSpeekWord:init( )
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_16.png")
	bg:setContentSize(cc.size(296,140))
	self:addChild(bg)
	local x,y = self._triggerTarg:getPosition()
	local size = self._triggerTarg:getContentSize()
	local space = 5
	if y + bg:getContentSize().height < self:getContentSize().height and x + size.width / 2 + bg:getContentSize().width + space < self:getContentSize().width then 
		bg:setAnchorPoint(0,0)
		bg:setPosition(x + size.width / 2 + space,y)
		self._usefulBgRect = cc.rect(bg:getPositionX(),bg:getPositionY(),bg:getContentSize().width,bg:getContentSize().height)
	elseif y - bg:getContentSize().height > 0 and x - size.width / 2 - bg:getContentSize().width - space > 0 then 
		bg:setAnchorPoint(1,1)
		bg:setPosition(x - size.width / 2 - space,y)
		self._usefulBgRect = cc.rect(bg:getPositionX() - bg:getContentSize().width,bg:getPositionY() - bg:getContentSize().height,bg:getContentSize().width,bg:getContentSize().height)
	elseif y - bg:getContentSize().height > 0 and x + size.width / 2 + bg:getContentSize().width + space < self:getContentSize().width then 
		bg:setAnchorPoint(0,1)
		bg:setPosition(x + size.width / 2 + space,y)
		self._usefulBgRect = cc.rect(bg:getPositionX(),bg:getPositionY() - bg:getContentSize().height,bg:getContentSize().width,bg:getContentSize().height)
	elseif y + bg:getContentSize().height > self:getContentSize().height and x - size.width / 2 - bg:getContentSize().width - space > 0 then 
		bg:setAnchorPoint(1,0)
		bg:setPosition(x - size.width / 2 - space,y)
		self._usefulBgRect = cc.rect(bg:getPositionX() - bg:getContentSize().height,bg:getPositionY(),bg:getContentSize().width,bg:getContentSize().height)
	end 
	self._usefulBg = bg	
	------初始化字
	local y = bg:getContentSize().height	
	for k,v in pairs(LANGUAGE_MULTICOPY_SPEEKWORDS) do 
		-------
		local _button = XTHD.createPushButtonWithSound({
			selectedFile = "res/image/multiCopy/copy_speekword_bg.png"
		},3)
		_button:setTag(k)
		_button:setTouchEndedCallback(function( )
			self:doSelectedWord(_button:getTag())
		end)
		bg:addChild(_button)
		_button:setAnchorPoint(0.5,1)
		_button:setPosition(bg:getContentSize().width / 2,y - 5)
		---------------------------------
		local _word = XTHDLabel:createWithSystemFont(v,XTHD.SystemFont,18)
		_word:setColor(cc.c3b(253,227,0))
		_button:addChild(_word)
		_word:setPosition(_button:getContentSize().width / 2,_button:getContentSize().height / 2)
		y = y - _button:getContentSize().height
		self._wordList[k] = _button
	end 
end

function DuoRenFuBenSpeekWord:doSelectedWord( index )
	local target = self._wordList[index]
	if target then 
		if self._parent then 
			self._parent:setSelectedWord(index)
		end 
		self:removeFromParent()
	end 
end

return DuoRenFuBenSpeekWord