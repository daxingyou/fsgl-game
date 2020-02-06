--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local VoucherCenterLayer = class("VoucherCenterLayer",function()
	return XTHD.createBasePageLayer()
end)

function VoucherCenterLayer:ctor()
	self._selectedIndex = nil
	self._voucherNode = nil
	self:init()
end

function VoucherCenterLayer:init()
	local _bg = cc.Sprite:create("res/image/VoucherCenter/bg.png")
	self:addChild(_bg)
	_bg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)
	self._bg = _bg

	local btnNames = {"chaozhi","yuekai","chongzhi","danbi","fuli"}
	local btnPos = {cc.p(51,350),cc.p(51,148),cc.p(150,362),cc.p(150,242),cc.p(150,120)}
	--左边按钮们
	for i = 1, 5 do
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/VoucherCenter/btn_"..btnNames[i].."_up.png",
			selectedFile = "res/image/VoucherCenter/btn_"..btnNames[i].."_down.png"
		})
		_bg:addChild(btn)
		btn:setScale(0.9)
		btn:setPosition(btnPos[i])
		btn:setTouchEndedCallback(function()
			self:SwichVoucherNode(i)
		end)
	end

	self:SwichVoucherNode(1)
end

function VoucherCenterLayer:SwichVoucherNode(_index)
	if self._selectedIndex == _index then
		return
	end

	if _index == 2 then
		HttpRequestWithOutParams("mouthCardState", function(data)
			if self._voucherNode then
				if self._voucherNode.onCleanup then
					self._voucherNode:onCleanup()
				end
				self._voucherNode:removeFromParent()
				self._voucherNode = nil
			end			

			local node = requires("src/fsgl/layer/VoucherCenter/VoucherYueka.lua"):create(data)
			self._bg:addChild(node)
			node:setPosition(self._bg:getContentSize().width *0.6 + 20,self._bg:getContentSize().height *0.5)
			self._voucherNode = node
			self._selectedIndex = _index
		end )
	elseif _index == 3 then
		HttpRequestWithOutParams("payWindows", function(data)
			if self._voucherNode then
				if self._voucherNode.onCleanup then
					self._voucherNode:onCleanup()
				end
				self._voucherNode:removeFromParent()
				self._voucherNode = nil
			end			

			local node = requires("src/fsgl/layer/Vip/VipRechargeLayer1.lua"):create(data,self)
			self._bg:addChild(node)
			node:setPosition(self._bg:getContentSize().width *0.6 + 20,self._bg:getContentSize().height *0.5)
			self._voucherNode = node
			self._selectedIndex = _index
		end )
	elseif _index == 4 then
		HttpRequestWithOutParams("singlePayRewardList", function(data)
			if self._voucherNode then
				if self._voucherNode.onCleanup then
					self._voucherNode:onCleanup()
				end
				self._voucherNode:removeFromParent()
				self._voucherNode = nil
			end			

			local node = requires("src/fsgl/layer/HuoDong/NewDanBiChongZhiLayer.lua"):create(self,data)
			self._bg:addChild(node)
			node:setPosition(self._bg:getContentSize().width *0.6 + 20,self._bg:getContentSize().height *0.5)
			self._voucherNode = node
			self._selectedIndex = _index
		end )
	elseif _index == 5 then
		HttpRequestWithOutParams("welfareShopList", function(data)
			if self._voucherNode then
				if self._voucherNode.onCleanup then
					self._voucherNode:onCleanup()
				end
				self._voucherNode:removeFromParent()
				self._voucherNode = nil
			end			

			local node = requires("src/fsgl/layer/VoucherCenter/VoucherFuli.lua"):create(self,data)
			self._bg:addChild(node)
			node:setPosition(self._bg:getContentSize().width *0.6 + 20,self._bg:getContentSize().height *0.5)
			self._voucherNode = node
			self._selectedIndex = _index
		end )
	elseif _index == 1 then
		HttpRequestWithOutParams("vipRewardRecord", function(data)
			if self._voucherNode then
				if self._voucherNode.onCleanup then
					self._voucherNode:onCleanup()
				end
				self._voucherNode:removeFromParent()
				self._voucherNode = nil
			end			

			local node = requires("src/fsgl/layer/VoucherCenter/VoucherChaozhi.lua"):create(self,data)
			self._bg:addChild(node)
			node:setPosition(self._bg:getContentSize().width *0.6 + 20,self._bg:getContentSize().height *0.5)
			self._voucherNode = node
			self._selectedIndex = _index
		end )
		
	end
end

function VoucherCenterLayer:freshRedDot()

end

function VoucherCenterLayer:onExit()

end

function VoucherCenterLayer:onEnter()

end

function VoucherCenterLayer:onCleanup( ... )
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_VIP_MSG)
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_VIP_SHOW)
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TASKLIST })
    -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER })
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
    XTHD.setVIPExist(false)
end

function VoucherCenterLayer:create()
	return VoucherCenterLayer.new()
end

return VoucherCenterLayer

--endregion
