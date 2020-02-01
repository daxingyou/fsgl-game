--[[
七星坛打脸页
]]

local QiXinTanPopLayer = class("QiXinTanPopLayer",function( )
	return XTHDPopLayer:create({isHide = true})
end)

function QiXinTanPopLayer:ctor()
   
end

function QiXinTanPopLayer:onCleanup( )	
   
end

function QiXinTanPopLayer:create()
	local layer = QiXinTanPopLayer.new()
	if layer then 
		layer:init()
	end
	return layer
end

function QiXinTanPopLayer:init()
	self:initUI()
end

function QiXinTanPopLayer:initUI()

	local _popBgSprite = cc.Sprite:create("res/image/dalianye/qxt/bg.png")
	self._popBgSprite = _popBgSprite
    local popNode = XTHDPushButton:createWithParams({
                        normalNode = _popBgSprite
                    })
    popNode:setTouchEndedCallback(function ()
        
    end)
	_popBgSprite:setScale(1)
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2 + 50)
    self:addContent(popNode)
    self.popNode = popNode
    self:show()

    local close = XTHDPushButton:createWithParams({
            normalFile = "res/image/dalianye/qxt/closeBtn1.png",
            selectedFile = "res/image/dalianye/qxt/closeBtn2.png",
            needEnableWhenOut = true,
        })
    close:setTouchEndedCallback(function()
        self:hide()
    end)
    close:setPosition(_popBgSprite:getContentSize().width - 15, _popBgSprite:getContentSize().height/2 + 15)
    _popBgSprite:addChild(close,2)

    --前往按钮
	local goBtn = XTHDPushButton:createWithParams({
            normalFile = "res/image/dalianye/qxt/goBtn1.png",
            selectedFile = "res/image/dalianye/qxt/goBtn2.png",
            needEnableWhenOut = true,
        })
	goBtn:setTouchEndedCallback(function()
	    self:onGoBtnClick()
	end)
	goBtn:setPosition(_popBgSprite:getContentSize().width/2,_popBgSprite:getContentSize().height/2 - 185)
	_popBgSprite:addChild(goBtn)
end

function QiXinTanPopLayer:onGoBtnClick()
    local node = cc.Director:getInstance():getRunningScene()
	XTHD.createExchangeLayer(node,nil,nil)
    self:hide()
end

return QiXinTanPopLayer


