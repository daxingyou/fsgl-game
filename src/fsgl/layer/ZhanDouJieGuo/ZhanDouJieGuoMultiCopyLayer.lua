--[[
-----多人副本战斗结算面板 
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

local ZhanDouJieGuoMultiCopyLayer = class("ZhanDouJieGuoMultiCopyLayer",function()
    return XTHDDialog:create()
end)

function ZhanDouJieGuoMultiCopyLayer:ctor(params)
	self._resultData = params or {fightResult = 1}
	self._canClose = false
	self._turnCardTimes = 1
	self._availableArea = cc.rect(0,0,0,0)
	self._cardList = {}

	self._gettedReward = {} -------自己已获得的奖励
	self._ungettedReward = {} -----自己没有获得的奖励

	self._allItems = {} ----所有获得的物品
	if self._resultData.fightResult == 1 then ------赢了
		local j = 1
		for i = 1,#self._resultData.allItems do 
			if j > #self._resultData.addItem then 
				break
			elseif self._resultData.allItems[i] == self._resultData.addItem[j] then 
				table.remove(self._resultData.allItems,i)
				j = j + 1
			end 
		end 
	end 
end

function ZhanDouJieGuoMultiCopyLayer:create(params)
	local _layer = ZhanDouJieGuoMultiCopyLayer.new(params)
	if _layer then 
		_layer:init()
	end 
	return _layer
end

function ZhanDouJieGuoMultiCopyLayer:onCleanup( )		
	musicManager.setBackMusic(XTHD.resource.music.music_bgm_main)
	musicManager.switchBackMusic()
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/multiCopy/copy_label1.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_label2.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_reward_card1.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_reward_card2.png")
end

function ZhanDouJieGuoMultiCopyLayer:init( )
	if self._resultData.playerProperty then
		for i=1,#self._resultData.playerProperty do
            local pro_data = string.split(self._resultData.playerProperty[i], ',')
            DBUpdateFunc:UpdateProperty("userdata", pro_data[1], pro_data[2])
        end
	    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
	end	
	if self._resultData.bagItems then
        for i=1,#self._resultData.bagItems do
        	local _data = self._resultData.bagItems[i]
           	DBTableItem.updateCount(gameUser.getUserId(), _data, _data["dbId"])
        end
	end
	-----
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(layout)
	layout:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2 - 20)
	------背景
	local _bg = XTHDSprite:create("res/image/worldboss/result_bg.png")	
	_bg:setScaleY(370 / _bg:getContentSize().height)
	layout:setContentSize(cc.size(_bg:getBoundingBox().width,_bg:getBoundingBox().height))
	layout:addChild(_bg)
	_bg:setPosition(layout:getContentSize().width / 2,layout:getContentSize().height / 2)
	_bg:setTouchEndedCallback(function()
	end)
	-------数据查看 
	local _bt = XTHD.createButton({
		normalFile = "res/image/tmpbattle/battle_data_normal.png",
		touchScale = 0.95,
		anchor = cc.p(0.5, 1),		
		endCallback = function( )
			local pop = requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoShowHurtLayer.lua"):create(self._resultData,BattleType.MULTICOPY_FIGHT)
			self:addChild(pop)
		end,
	})
	_bt:setScale(0.8)
	layout:addChild(_bt)
	_bt:setPosition(self:getContentSize().width -  150,layout:getContentSize().height)
	-----点击空白区域继续
	local _tips = cc.Sprite:create("res/image/plugin/duanadvance/space_sp.png")
	layout:addChild(_tips)
	_tips:setPosition(_bg:getPositionX(),_bg:getPositionY() - _bg:getBoundingBox().height / 2 - _tips:getContentSize().height / 2 - 5)
	----
	if self._resultData.fightResult == 1 then 
		self:initWinUI(layout)
	else
		performWithDelay(self,function()
			self._canClose = true
		end,2.0)
		self:initLoseUI(layout)
	end 

	self:setTouchEndedCallback(function ()
		if not self._canClose then
			return
		end
		XTHD.dispatchEvent({name = CUSTOM_EVENT.ASYNCSERVER_AFTERBATTLE})
		cc.Director:getInstance():popScene()
	end)
end

function ZhanDouJieGuoMultiCopyLayer:initWinUI(target)
    local _winPic = sp.SkeletonAnimation:create( "res/spine/effect/battle_win/shengli.json", "res/spine/effect/battle_win/shengli.atlas",1.0)	
    local node = cc.Node:create()
    node:addChild(_winPic)
    target:addChild(node)
    node:setPosition(target:getContentSize().width / 2,target:getContentSize().height)
    -------请选择牌
    local _tips = XTHDLabel:createWithSystemFont(LANGUAGE_MULTICOPY_TIPS9,XTHD.SystemFont,18)
    _tips:setColor(cc.c3b(255,126,0))
    target:addChild(_tips)
    _tips:setPosition(target:getContentSize().width / 2,target:getContentSize().height - 70)
    -----
    self:createRewardCard(target)
end

function ZhanDouJieGuoMultiCopyLayer:initLoseUI(target)
	----
	local _loseIcon = cc.Sprite:create("res/image/tmpbattle/result_faild.png")
	target:addChild(_loseIcon)
	_loseIcon:setPosition(target:getContentSize().width / 2,target:getContentSize().height)
	----小熊
	local _bear = cc.Sprite:create("res/image/daily_task/escort_task/overShow1.png")
	target:addChild(_bear)
	_bear:setPosition(self:getContentSize().width * 1/3,target:getContentSize().height / 2 + 20)
	local item_name_label = XTHDLabel:createWithParams({ ---主人
        text = LANGUAGE_KEY_MASTER.."，",
        anchor = cc.p(0, 0.5),
        fontSize = 22,
        color = cc.c3b(225, 152, 102),
        pos = cc.p(target:getContentSize().width*0.5 - 80, target:getContentSize().height - 150),
    })
    target:addChild(item_name_label)
	item_name_label = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS277,
        anchor = cc.p(0, 0.5),
        fontSize = 22,
        color = cc.c3b(225, 152, 102),
        pos = cc.p(target:getContentSize().width*0.5 - 80, target:getContentSize().height - 190),
    })
    target:addChild(item_name_label)
end

function ZhanDouJieGuoMultiCopyLayer:createRewardCard(target)
	local x = (self:getContentSize().width - 900) / 2
	for i = 1,5 do 
		local _card = XTHDSprite:create("res/image/multiCopy/copy_reward_card1.png")
		self:addChild(_card)
		_card:setPosition(x + _card:getContentSize().width / 2+50,target:getPositionY() - target:getContentSize().height / 2 + _card:getContentSize().height / 2 + 25)
		_card:setTouchEndedCallback(function( )
			self:doTurnCard(_card)
		end)
		x = x + _card:getContentSize().width
		self._cardList[i] = _card
	end 
end
------翻牌
function ZhanDouJieGuoMultiCopyLayer:doTurnCard(sender)	
	local time = 0.1
	local scalein = cc.ScaleTo:create(time,0.05,1.0)
	local scaleOut = cc.ScaleTo:create(time,1.0,1.0)
	sender:setClickable(false)
	sender.hasTurned = true
	sender:runAction(cc.Sequence:create(scalein,cc.CallFunc:create(function( )
		sender:setTexture("res/image/multiCopy/copy_reward_card2.png")
		self:createItem(sender,self._resultData.addItem[self._turnCardTimes],true)
		self._turnCardTimes = self._turnCardTimes + 1			
		if self._turnCardTimes > 2 then 
			self:turnTheRestOfCard()
		end 
	end),scaleOut,cc.CallFunc:create(function( )
		local _hasGetIcon = cc.Sprite:create("res/image/vip/yilingqu.png") -------已领取标签 
		_hasGetIcon:setScale(0.8)
		sender:addChild(_hasGetIcon)
		_hasGetIcon:setPosition(sender:getContentSize().width / 2,_hasGetIcon:getContentSize().height - 5)
	end)))
end
------把剩下的牌翻开 
function ZhanDouJieGuoMultiCopyLayer:turnTheRestOfCard( )
	local delayTime,j,k = 0,0,1
	for i = 1,#self._cardList do 
		if not self._cardList[i].hasTurned then 
			self._cardList[i]:setClickable(false)
			self._cardList[i].hasTurned = true

			local time = 0.3
			local scalein = cc.ScaleTo:create(time,0.05,1.0)
			local scaleOut = cc.ScaleTo:create(time,1.0,1.0)
			self._cardList[i]:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime + j * time),scalein,cc.CallFunc:create(function( )
				self._cardList[i]:setTexture("res/image/multiCopy/copy_reward_card2.png")
				self:createItem(self._cardList[i],self._resultData.allItems[k])
				k = k + 1
			end),scaleOut))
			j = j + 1
		end 
	end 
	performWithDelay(self,function( )
		self._canClose = true
	end,2.0)
end

function ZhanDouJieGuoMultiCopyLayer:createItem(target,data,withEffect)
	if target and data then 
		local _temp = string.split(data,",")
		local item = ItemNode:createWithParams({
			_type_ = XTHD.resource.type.item,
	        itemId = tonumber(_temp[1]),
	        count = tonumber(_temp[2]),
	    })
	    item:setScale(0.9)
	    target:addChild(item)
	    item:setPosition(target:getContentSize().width / 2 + 1,target:getContentSize().height / 2 + 13)
	    ------=名字
	    local _name = XTHDLabel:createWithSystemFont(item:getName(),XTHD.SystemFont,17)
	    _name:setColor(cc.c3b(115,59,31))
	    target:addChild(_name)
	    _name:setPosition(item:getPositionX(),item:getPositionY() - item:getBoundingBox().height / 2 - _name:getContentSize().height + 10)
	    _name:enableShadow(cc.c4b(115,59,31,0xff),cc.size(1,0))
	    ----------------特效
	    if not withEffect then 
	    	return 
	    end 
	    local animationName = {"zz","cz","hz"}
	    local quality = item:getQuality()	    
	    if quality >= 4 then
			-- local _spine = sp.SkeletonAnimation:create("res/image/plugin/hero/equipSpine/zbg.json", "res/image/plugin/hero/equipSpine/zbg.atlas", 1)
			local _spine = sp.SkeletonAnimation:create("res/image/plugin/hero/equipSpine/wupinkuang.json", "res/image/plugin/hero/equipSpine/wupinkuang.atlas", 1)
    		local node = cc.Node:create()
    		node:addChild(_spine)
    		node:setScale(1.3)
    		item:addChild(node)    		
    		node:setPosition(item:getContentSize().width / 2,item:getContentSize().height / 2-10)
			-- _spine:setAnimation(0,animationName[quality - 3],true)
			_spine:setAnimation(0,"wupinkuang",true)
	    end 
	end 
end

return ZhanDouJieGuoMultiCopyLayer