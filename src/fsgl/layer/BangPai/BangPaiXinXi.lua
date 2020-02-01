-- FileName: BangPaiXinXi.lua
-- Author: wangming
-- Date: 2015-10-19
-- Purpose: 弹出框
--[[TODO List]]

local BangPaiXinXi = class("BangPaiXinXi", function (...) 
	return XTHDPopLayer:create({isRemoveLayout = true})
end)
--[=[
{
	size = cc.size(639, 387),
	titleBgSize = cc.size(629, 58),
	titleNode = cc.Node:create(),
}
]=]
function BangPaiXinXi:ctor( sParams )
	local params = sParams or {}
	self._params = params
	local _worldSize = params.size or cc.size(639, 450)
	local _titleBgSize = params.titleBgSize or cc.size(_worldSize.width-7*2,44)

	local popNode = XTHD.getScaleNode("res/image/common/scale9_bg3_34.png",_worldSize)
	self._popNode = popNode
	popNode:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
	self:addContent(popNode)

	local close_btn = XTHD.createBtnClose(function()
        self:hide()
    end)
	close_btn:setPosition(_worldSize.width - 10, _worldSize.height - 10)
	popNode:addChild(close_btn, 3)
	
	local _titleBgSp = cc.Sprite:create("res/image/login/zhanghaodenglu.png")
	self._titleBack = _titleBgSp
	_titleBgSp:setAnchorPoint(cc.p(0.5,1))
	_titleBgSp:setPosition(cc.p(popNode:getContentSize().width/2,popNode:getContentSize().height-7+35))
	popNode:addChild(_titleBgSp)

	local _titleNode = params.titleNode

	if _titleNode~=nil then
		_titleNode:setPosition(_titleBgSp:getContentSize().width*0.5 , _titleBgSp:getContentSize().height*0.5)
		_titleBgSp:addChild(_titleNode)
	end

	self:show()
end

function BangPaiXinXi:create( sParams )
	local pLay = BangPaiXinXi.new(sParams)
	return pLay
end

return BangPaiXinXi