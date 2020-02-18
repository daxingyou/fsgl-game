--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Biwuzhaoqin = class("Biwuzhaoqin",function()
	return XTHD.createBasePageLayer()
end)

function Biwuzhaoqin:ctor()
	self._nodeLayer = nil
	self:init()
end

function Biwuzhaoqin:init()
	local bg = cc.Sprite:create("res/image/Biwuzhaoqin/bg.png")
	self:addChild(bg)
	bg:setPosition(self:getContentSize().width *0.5, (self:getContentSize().height - self.topBarHeight) *0.5)
	self._bg = bg

	local btnNames = {"btn_hunyan_","btn_shuangxiu_","btn_zhaoqin_","btn_xiangqin_","btn_qiangqin_"}
	local btnPos = {cc.p(51,350),cc.p(51,148),cc.p(150,362),cc.p(150,242),cc.p(150,120)}
	for i = 1, #btnNames do
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/Biwuzhaoqin/"..btnNames[i].."1.png",
			selectedFile = "res/image/Biwuzhaoqin/"..btnNames[i].."2.png",
		})
		self._bg:addChild(btn)
		btn:setPosition(btnPos[i])
		btn:setTouchEndedCallback(function()
			self:swichLayer(i)
		end)
	end

	local contentbg = cc.Sprite:create("res/image/common/scale9_bg2_34.png")
	self._bg:addChild(contentbg)
	contentbg:setOpacity(0)
	contentbg:setPosition(self._bg:getContentSize().width *0.625,self._bg:getContentSize().height *0.5 + 5)
	contentbg:setContentSize(self:getContentSize().width *0.65 - 20,self._bg:getContentSize().height - 25)
	self._contentbg = contentbg

	
	local btn_xiangqin = XTHDPushButton:createWithParams({
		normalFile = "res/image/Biwuzhaoqin/btn_startxiangqin_1.png",
		selectedFile = "res/image/Biwuzhaoqin/btn_startxiangqin_2.png",
	})
	self._contentbg:addChild(btn_xiangqin)
	btn_xiangqin:setPosition(btn_xiangqin:getContentSize().width *0.5 + 75,btn_xiangqin:getContentSize().height *0.5)
	btn_xiangqin:setTouchEndedCallback(function()

	end)

	local btn_zhaoqin = XTHDPushButton:createWithParams({
		normalFile = "res/image/Biwuzhaoqin/btn_startzhaoqin_1.png",
		selectedFile = "res/image/Biwuzhaoqin/btn_startzhaoqin_2.png",
	})
	self._contentbg:addChild(btn_zhaoqin)
	btn_zhaoqin:setPosition(btn_xiangqin:getPositionX() + btn_xiangqin:getContentSize().width + 5,btn_xiangqin:getPositionY())
	btn_zhaoqin:setTouchEndedCallback(function()

	end)
	
	local btn_hunyan = XTHDPushButton:createWithParams({
		normalFile = "res/image/Biwuzhaoqin/btn_party_1.png",
		selectedFile = "res/image/Biwuzhaoqin/btn_party_2.png",
	})
	self._contentbg:addChild(btn_hunyan)
	btn_hunyan:setPosition(self._contentbg:getContentSize().width - 80 - btn_hunyan:getContentSize().width *0.5,btn_zhaoqin:getPositionY())
	btn_hunyan:setTouchEndedCallback(function()

	end)
end

function Biwuzhaoqin:swichLayer(index)
	local files = {"HaohuahunyanLayer","","ZhaoqinLayer","XiangqinLayer","QiangqinLayer"}
	if index ~= 2 then
		if self._nodeLayer ~= nil then
			self._nodeLayer:removeFromParent()
			self._nodeLayer = nil
		end
		local node = requires("src/fsgl/layer/Biwuzhaoqin/"..files[index]..".lua"):create()
		self._contentbg:addChild(node)
		node:setPosition(self._contentbg:getContentSize().width *0.5,self._contentbg:getContentSize().height)
		self._nodeLayer = node
	end
end

function Biwuzhaoqin:create()
	return Biwuzhaoqin.new(index)
end

return Biwuzhaoqin
--endregion
