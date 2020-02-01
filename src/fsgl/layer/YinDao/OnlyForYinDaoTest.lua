--[[
引导测试用的
]]
local OnlyForYinDaoTest = class("OnlyForYinDaoTest",function( )
	return XTHDDialog:create()
end)

function OnlyForYinDaoTest:ctor( )
	
end

function OnlyForYinDaoTest:create( )
	local layer = OnlyForYinDaoTest.new()
	if layer then 
		layer:init()
	end 
	return layer
end

function OnlyForYinDaoTest:init( )
	local colorLayer = cc.LayerColor:create(cc.c4b(0,0,0,0xff),self:getContentSize().width,self:getContentSize().height)
	self:addChild(colorLayer)
	local _close = XTHDPushButton:createWithParams({
		normalFile = "res/image/common/btn/btn_equip_normal.png",
		selectedFile = "res/image/common/btn/btn_equip_selected.png",
	})
	self:addChild(_close)
	_close:setPosition(self:getContentSize().width,self:getContentSize().height)
	_close:setTouchEndedCallback(function(  )
		self:removeFromParent()
	end)
	---------下列代码是测试新功能开启的，暂时不要删
	local _label = XTHDLabel:createWithSystemFont("关卡：",XTHD.SysteFont,20)
	colorLayer:addChild(_label)
	_label:setPosition(260,self:getContentSize().height / 2 + 70)

    local _blockInput = ccui.EditBox:create(cc.size(400,40), "res/image/chatroom/chatroom_input_back.png")
    _blockInput:setFontSize(22)
    _blockInput:setFontName("res/fonts/def.ttf")
    _blockInput:setPosition(self:getContentSize().width / 2,_label:getPositionY() - 50)
    _blockInput:setPlaceholderFontColor(cc.c3b(255,255,255))
    _blockInput:setAnchorPoint(0.5,0.5)
    self:addChild(_blockInput)

	local _label = XTHDLabel:createWithSystemFont("引导：",XTHD.SysteFont,20)
	colorLayer:addChild(_label)
	_label:setPosition(260,_blockInput:getPositionY() - 25)

    local _guideInput = ccui.EditBox:create(cc.size(400,40), "res/image/chatroom/chatroom_input_back.png")
    _guideInput:setFontSize(22)
    _guideInput:setFontName("res/fonts/def.ttf")
    _guideInput:setPosition(self:getContentSize().width / 2,_label:getPositionY() - 50)
    _guideInput:setPlaceholderFontColor(cc.c3b(255,255,255))
    _guideInput:setAnchorPoint(0.5,0.5)
    self:addChild(_guideInput)

	local _button = XTHDPushButton:createWithParams({
		normalFile = "res/image/common/btn/btn_equip_normal.png",
		selectedFile = "res/image/common/btn/btn_equip_selected.png",
	})
	self:addChild(_button)
	_button:setPosition(self:getContentSize().width / 2,100)
	_button:setTouchEndedCallback(function( )

		local blockID = tonumber(_blockInput:getText())
		if blockID then 
			print("00000000000000000000000000000 set block id is",blockID)
			gameUser.setInstancingId(blockID)
		end 

		-- local guide = _guideInput:getText()		
		-- print("000000000000000000000000 skip guide is",guide)
		-- guide = string.split(guide,"-")
		-- -- dump(guide)
		-- if #guide >= 2 then 
		-- 	YinDaoMarg:getInstance():testForASection({group = tonumber(guide[1]),index = tonumber(guide[2])})
		-- end 
		CopiesData._testGuide = true
		self:removeFromParent()
	end)
end

return OnlyForYinDaoTest