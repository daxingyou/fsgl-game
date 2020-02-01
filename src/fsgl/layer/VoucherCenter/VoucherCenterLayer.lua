--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local VoucherCenterLayer = class("VoucherCenterLayer",function()
	return XTHD.createBasePageLayer()
end)

function VoucherCenterLayer:ctor()
	self._voucherNode = nil
	self:init()
end

function VoucherCenterLayer:init()
	local _bg = cc.Sprite:create("res/image/VoucherCenter/bg.png")
	_bg:setContentSize(933,468)
	self:addChild(_bg)
	_bg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)
	self._bg = _bg

	local btnNames = {"chaozhi","yuekai","chongzhi","danbi","fuli"}
	local btnPos = {cc.p(53,320),cc.p(53,138),cc.p(157,330),cc.p(157,223),cc.p(157,115)}
	--左边按钮们
	for i = 1, 5 do
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/VoucherCenter/btn_"..btnNames[i].."_up.png",
			selectedFile = "res/image/VoucherCenter/btn_"..btnNames[i].."_down.png"
		})
		_bg:addChild(btn)
		btn:setScale(0.85)
		btn:setPosition(btnPos[i])
		btn:setTouchEndedCallback(function()
			self:SwichVoucherNode(i)
		end)
	end
	self:SwichVoucherNode(3)
end

function VoucherCenterLayer:SwichVoucherNode(_index)
	local nodeFileName = {"","","VoucherChongzhi","VoucherDanbi","VoucherFuli"}
	if self._voucherNode then
		self._voucherNode:removeFromParent()
		self._voucherNode = nil
	end
	
	local node = requires("src/fsgl/layer/VoucherCenter/" .. nodeFileName[_index] .. ".lua"):create()
	self._bg:addChild(node)
	node:setPosition(self._bg:getContentSize().width *0.6 + 20,self._bg:getContentSize().height *0.5 - 20)
	self._voucherNode = node
end

function VoucherCenterLayer:create()
	return VoucherCenterLayer.new()
end

return VoucherCenterLayer

--endregion
