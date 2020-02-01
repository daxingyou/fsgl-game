-- FileName: FriendPop.lua
-- Author: wangming
-- Date: 2015-09-14
-- Purpose: 好友模块弹窗基础类
--[[TODO List]]
local HaoYouBasePop = class( "HaoYouBasePop", function ()
    return XTHDPopLayer:create({isRemoveLayout = true})
end)

function HaoYouBasePop:createOne( sParams )
	local pLay = HaoYouBasePop.new(sParams)
	return pLay
end

--[[
	size : 弹窗尺寸
	title ： 标题

]]--
function HaoYouBasePop:ctor( sParams )
	local params = sParams or {}
	self._params = params
	local _worldSize = params.size or cc.size(639, 387)

	local isShowBlack = params.isShowBlack == nil and true or params.isShowBlack
	-- if isShowBlack then
	-- 	local pLayer = cc.LayerColor:create(cc.c4b(0,0,0,150))
	-- 	self:addChild(pLayer, -1)
	-- end

	local popNode = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	popNode:setContentSize(_worldSize)
	self._popNode = popNode
	popNode:setPosition(self:getContentSize().width*0.5,self:getContentSize().height*0.5)
	self:addContent(popNode)

	local close_btn = XTHD.createBtnClose(function()
        self:hide()
    end)
	close_btn:setPosition(_worldSize.width - 10, _worldSize.height - 10)
	popNode:addChild(close_btn,2)

	local _titleString = params.title or ""
	if _titleString and _titleString ~= "" then
		local _titleSp = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,50))
		popNode:addChild(_titleSp, 2)
		_titleSp:setAnchorPoint(cc.p(0.5, 1))
		_titleSp:setPosition(cc.p(_worldSize.width*0.5, _worldSize.height + 10))

		local _nameTTF = XTHDLabel:createWithParams({
	    	text = _titleString,
	    	fontSize = 24,
	    	color = cc.c3b(255,255,255),
	    })
	    _nameTTF:setPosition(_titleSp:getContentSize().width*0.5 , _titleSp:getContentSize().height*0.5 - 15)
		_titleSp:addChild(_nameTTF)
		self.title = _nameTTF
	end
	
	self:show()
end

return HaoYouBasePop