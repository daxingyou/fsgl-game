--Created By Liuluyang
local JingJiRankGamePop = class("JingJiRankGamePop",function ()
	return XTHD.createPopLayer()
end)

function JingJiRankGamePop:ctor(data,index,parent)
	self._data = data
	self._index = index
	self._parent = parent
	self:initUI()
end

function JingJiRankGamePop:initUI()
	local bg = cc.Sprite:create("res/image/rankGame/rankpopbg.png")
	self:addContent(bg)
	bg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)

	 local _closeBtn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/common/btn/btn_red_close_normal.png",
        selectedFile      = "res/image/common/btn/btn_red_close_selected.png",
        musicFile         = XTHD.resource.music.effect_close_pop,
        endCallback       = function()
                self:hide({music = true})
            end,
    })
    _closeBtn:setAnchorPoint(cc.p(0.5,0.5))
    _closeBtn:setPosition(cc.p(bg:getContentSize().width-15,bg:getContentSize().height-10))
    bg:addChild(_closeBtn,5)

	local power = 0
	for i = 1,#self._data do
		local node = HeroNode:createWithParams({
			heroid = self._data[i].petId,
			level = self._data[i].level,
			star = self._data[i].star,
		})
		bg:addChild(node)
		local x = bg:getContentSize().width*0.5 + (#self._data-1) *node:getContentSize().width *0.5 - (i-1)*node:getContentSize().width
		node:setScale(0.9)
		node:setPosition(x,bg:getContentSize().height - node:getContentSize().height - 40)
		power = power + self._data[i].curPowar
	end

	local fightingbg = cc.Sprite:create("res/image/plugin/competitive_layer/NewAthletics/zhanlibg.png")
	bg:addChild(fightingbg)
	fightingbg:setPosition(bg:getContentSize().width *0.5,bg:getContentSize().height *0.5 - 40)

	local power = getCommonYellowBMFontLabel(power)
	fightingbg:addChild(power)
	power:setPosition(fightingbg:getContentSize().width *0.5 + 30,fightingbg:getContentSize().height *0.5 - 7)

	local btn_tiaozhan = XTHDPushButton:createWithParams({
		normalFile = "res/image/rankGame/tiaozhan_2_up.png",
		selectedFile = "res/image/rankGame/tiaozhan_2_down.png",
	})
	bg:addChild(btn_tiaozhan)
	btn_tiaozhan:setPosition(bg:getContentSize().width *0.5,btn_tiaozhan:getContentSize().height)

	btn_tiaozhan:setTouchEndedCallback(function()
		self._parent:clickChallenge(self._index)
		self:hide()
	end)
end

function JingJiRankGamePop:create(data,index,parent)
	return JingJiRankGamePop.new(data,index,parent)
end
return JingJiRankGamePop