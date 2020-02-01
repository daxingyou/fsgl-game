--  Created by zhangchao on 15-04-17.
--[[
	弹窗
	该对象实际就是一个XTHDDialog，背景全透明，其内部有一个container，用于装载ui
	（XTHDPopLayer只用于显示阴影层，其他的全部交给container）
	调用show方法显示并播放显示动画
]]
XTHDPopLayer = class("XTHDPopLayer", function()
    return XTHDDialog:create()
end)


function XTHDPopLayer:ctor(params)
	--创建默认参数
    local defaultParams = {
    	hideCallback = nil,
    	opacityValue = 127.5,
		isHide = false,
    }
    if params == nil then params = {} end
    for k, v in pairs(defaultParams) do
        if params[k] == nil then
            params[k] = v
        end
    end
	self._isHide = params.isHide
    self._hideCallback = params.hideCallback
    self._isRemoveLayout = params.isRemoveLayout or false
    self.opacityValue = params.opacityValue
	self._endCallback = nil
	self:setOpacity(0);
	-- local containerLayer = XTHDSprite:createWithTexture(nil,cc.rect(0,0,self:getContentSize().width,self:getContentSize().height))
	local containerLayer = XTHDSprite:create()
	containerLayer:setContentSize(self:getContentSize())
	containerLayer:setTouchSize(cc.size(10000,10000))
	containerLayer:setPosition(cc.p(self:getContentSize().width / 2 , self:getContentSize().height / 2))
	if params and params.pos then
		containerLayer:setPosition(cc.p(self:getContentSize().width / 2 + params.pos.width, self:getContentSize().height / 2 + params.pos.height))
	end
	self._containerLayer = containerLayer
	self:addChild(containerLayer)
	
	containerLayer:setTouchEndedCallback(function()
		if not self._isHide then 
			if self._endCallback then
				self._endCallback()
			else
				self:hide({music = true})
			end
		end
	end)
	self._containerLayer:setCascadeOpacityEnabled(true)
end

function XTHDPopLayer:setHideCallback(callback)
	self._hideCallback = callback
end

function XTHDPopLayer:getContainerLayer()
	return self._containerLayer
end

function XTHDPopLayer:addNodeOnContainer(node,zOrder) --直接在Container之上加东西，一般用来加入在Content和Container之间的吞噬层 Liuluyang
	zOrder = zOrder or 0
	self:getContainerLayer():addChild(node,zOrder)
end

function XTHDPopLayer:addContent(node,zOrder)
	zOrder = zOrder or 0
	local SwallowTouch = XTHDPushButton:createWithParams({
		--用于遮挡触摸 防止关闭窗口
		touchSize = node:getBoundingBox()
    })
    SwallowTouch:setPosition(node:getPositionX()+(0.5-node:getAnchorPoint().x)*node:getBoundingBox().width,node:getPositionY()+(0.5-node:getAnchorPoint().y)*node:getBoundingBox().height)
    self:getContainerLayer():addChild(SwallowTouch,zOrder)
	self:getContainerLayer():addChild(node,zOrder)
end

function XTHDPopLayer:show(animation)
	local _opacityValue = self.opacityValue or 127.5
	if nil == animation or animation == true then
		--[[背景逐渐变暗]]
		self:runAction(cc.FadeTo:create(0.3, _opacityValue))
		local containerLayer = self:getContainerLayer()
		XTHD.runActionPop(containerLayer)
	else
		self:setOpacity(_opacityValue)
	end
	return self
end

function XTHDPopLayer:hide(params)
	if self._isHiding then
		return
	end
	self._isHiding = true
	if params and params.music and params.music == true then
		musicManager.playEffect("res/sound/sound_closePanel_effect.mp3")
	end
	self:setOpacity(0)
	local containerLayer = self:getContainerLayer()
	XTHD.runHidePop(containerLayer)
	if self._isRemoveLayout then
		LayerManager.removeLayout(self, true)
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.RemoveSelf:create(true)))
	if self._hideCallback then
		self._hideCallback()
		self._hideCallback = nil
	end
end

function XTHDPopLayer:create(params)
	return XTHDPopLayer.new(params)
end
