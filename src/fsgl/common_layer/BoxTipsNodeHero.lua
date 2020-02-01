--[[
主城及topbar上的附件在点中时显示的tips，
]]
local BoxTipsNodeHero = class("BoxTipsNodeHero",function ()	
	-- return ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/tips_bg.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
	bg:setAnchorPoint(0.5,1)
	return bg
end)

function BoxTipsNodeHero:ctor( params )
	self._index = params.index
	self._data=params.data
	--if self._data == nil then
		self._words = {
			LANGUAGE_KEY_BOXTIPS1,  -->语言包中的函数
			LANGUAGE_KEY_BOXTIPS2,
			LANGUAGE_KEY_BOXTIPS3,
			LANGUAGE_KEY_BOXTIPS4,
		}
    --end
	self._suffixForEnergy = {
		LANGUAGE_KEY_BOXTIPSEXTRA1, -->语言包中的函数
		LANGUAGE_KEY_BOXTIPSEXTRA2,
	}
	self:init()
	self:registerScriptHandler(function(event)
		if event == "enter" then 
			self:onEnter()
		elseif event == "exit" then 
			self:onExit()
		end 
	end)
end

function BoxTipsNodeHero:create(params)
	return BoxTipsNodeHero.new(params) 
end

function BoxTipsNodeHero:init( )
	local maxWidth = 200
	local str = nil 
	----显示话
	if self._data == nil then
		 str = self:formatEnergyTips()
		if not str then 
			str = self._words[self._index]
		end 
	else
		self._index = tonumber(self._index)
		str = self._data[self._index]["name"].."\n"..self._data[self._index]["herodescription"]
    end
    local label = XTHDLabel:createWithParams({
		color = cc.c3b(88, 66, 122),
        text = str,
        fontSize = 18,
    })
	label:setDimensions(230,0)
    label:setAnchorPoint(0,0.5)
    local labelSize = label:getContentSize()  
    if labelSize.width > maxWidth - 20 then 
    	self:setContentSize(labelSize.width + 20,labelSize.height + 30)
    else 
    	self:setContentSize(maxWidth,labelSize.height + 30)
    end 
    self:addChild(label)
    label:setPosition(15,self:getBoundingBox().height / 2 + 10)
    self._label = label
    ----倒计时
    if self._index < 3 and self.fullCostTime and self.fullCostTime > 0 then 
    	schedule(self,function(  )    		
    		local str = self:formatEnergyTips()
    		self._label:setString(str)
    	end,1.0)
    else 
    	self:stopAllActions()
    end 
end

function BoxTipsNodeHero:onEnter( )
	musicManager.playEffect("res/sound/sound_effect_tips.wav")
end

function BoxTipsNodeHero:onExit( )
end

function BoxTipsNodeHero:formatEnergyTips( )
	local str = nil
	if self._index < 3 then 	
		str = self._words[self._index]
		local suffix = ""
		if self._index == 1 then -----体力
			self.currentValue = gameUser.getTiliNow()
			self.maxValue = gameUser.getTiliMax()
			if self.currentValue >= self.maxValue then ---已满
				suffix = self._suffixForEnergy[2]
			else 
				suffix = self._suffixForEnergy[1]
				self.fullCostTime = gameUser.getTiliRestCD()
				self.fullCostTime = self.fullCostTime - (os.time() - gameUser.getTiliSystemTime())
				gameUser.setTiliRestCD(self.fullCostTime)			
				gameUser.setTiliSysytemTime()	
			end 
		elseif self._index == 2 then -----精力
			self.currentValue = gameUser.getEnergy()
			self.maxValue = 20
			if self.currentValue >= self.maxValue then 
				suffix = self._suffixForEnergy[2]
			else 
				suffix = self._suffixForEnergy[1]
				self.fullCostTime = gameUser.getEnergyCD()
				self.fullCostTime = self.fullCostTime - (os.time() - gameUser.getEnergySystemTime())
				gameUser.setEnergyCD(self.fullCostTime)			
				gameUser.setEnergySystemTime()	
			end 
		end
		suffix = self:initCountDown(suffix, self._index)
		if type(suffix) == "function" then
			suffix = ""
		end
		if tonumber(self._index) == 1 then
			str = str(self.currentValue,self.maxValue,suffix)
		else
			str = string.format(str,self.currentValue,self.maxValue,suffix)
		end
	end 
	return str
end

function BoxTipsNodeHero:initCountDown(str, index)
	if self.fullCostTime and self.fullCostTime > 0 then 
		self.fullCostTime = math.floor(self.fullCostTime)
		local houre = math.floor(self.fullCostTime / 3600)
		local minute = math.floor(self.fullCostTime % 3600 / 60)
		local seconds = math.floor(self.fullCostTime % 3600 % 60)
		if index == 1 then
			str = str(houre,minute,seconds)
		else
			str = string.format(str,houre,minute,seconds)
		end
	end 
	return str
end

return BoxTipsNodeHero