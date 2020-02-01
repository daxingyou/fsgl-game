--Created By Liuluyang 2015年04月08日
ResourceItem1 = class("ResourceItem1",function (itemtype,num)
	local bgPath = nil
	if itemtype == 1 then
		bgPath = "res/image/common/item_purpleBg.png"
	elseif itemtype == 2 then
		bgPath = "res/image/common/item_purpleBg.png"
	elseif itemtype == 3 then
		bgPath = "res/image/common/item_orangeBg.png"
	elseif itemtype == 5 then
		bgPath = "res/image/common/item_purpleBg.png"
	end
	local bg = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create(bgPath),
		selectedNode = cc.Sprite:create(bgPath),
		needSwallow = true,
		enable = true,

	})
	bg:setCascadeOpacityEnabled(true)
	return bg
end)

function ResourceItem1:ctor(itemtype,num)
	local itemPath = nil
	if itemtype == 1 then
		itemPath = "res/image/common/task_exp_icon.png"
	elseif itemtype == 2 then
		itemPath = "res/image/common/task_gold_icon.png"
	elseif itemtype == 3 then
		itemPath = "res/image/common/task_rmb_icon.png"
	elseif itemtype == 5 then
		itemPath = "res/image/common/task_vit_icon.png"
	end

	self.ResourceItem1 = {
		[1] = LANGUAGE_KEY_PLACEEXP,------"领地经验",
		[2] = LANGUAGE_KEY_GOLD,-----"银两",
		[3] = LANGUAGE_KEY_COIN,----"元宝",
		[5] = LANGUAGE_TABLE_RESOURCENAME[5],-------"体力",
	}

	self.ResourceDesc = LANGUAGE_KEY_UNKNOWNTABLE

	local item = cc.Sprite:create(itemPath)
	item:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addChild(item)

	if num then
		local _num_label =cc.Label:create()
		_num_label:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(2,-2))
		_num_label:setName("_num_label")
		_num_label:setAnchorPoint(1,0)
		_num_label:setSystemFontSize(18)
		_num_label:setString(num)
		_num_label:setPosition(self:getContentSize().width-3-3, 3)
		self:addChild(_num_label)
	end
	self:setEnableWhenOut(true)
	self._enableTouch = true

	if self._enableTouch == true then
		self:setTouchBeganCallback(function ()
			local tmpPos = self:convertToWorldSpace(cc.p(0,0))
			self.TipsBg = self:_getTipsLayer(itemtype,num)
			if tmpPos.x >= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y >= cc.Director:getInstance():getWinSize().height/2 then --第一象限
				self.TipsBg:setAnchorPoint(cc.p(1,1))
				self.TipsBg:setPosition(tmpPos.x,tmpPos.y)
			elseif tmpPos.x <= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y >= cc.Director:getInstance():getWinSize().height/2 then --第二象限
				self.TipsBg:setAnchorPoint(cc.p(0,1))
				self.TipsBg:setPosition(tmpPos.x+self:getBoundingBox().width,tmpPos.y)
			elseif tmpPos.x <= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y <= cc.Director:getInstance():getWinSize().height/2 then --第三象限
				self.TipsBg:setAnchorPoint(cc.p(0,0))
				self.TipsBg:setPosition(tmpPos.x+self:getBoundingBox().width,tmpPos.y+self:getBoundingBox().height)
			elseif tmpPos.x >= cc.Director:getInstance():getWinSize().width/2 and tmpPos.y <= cc.Director:getInstance():getWinSize().height/2 then --第四象限
				self.TipsBg:setAnchorPoint(cc.p(1,0))
				self.TipsBg:setPosition(tmpPos.x,tmpPos.y+self:getBoundingBox().height)
			end

			cc.Director:getInstance():getRunningScene():addChild(self.TipsBg)
		end)
		self:setTouchEndedCallback(function ()
			if self.TipsBg then
				self.TipsBg:removeFromParent()
				self.TipsBg = nil
			end
		end)
	end
end

function ResourceItem1:setCountNumber(_num)
	if self:getChildByName("_num_label") then
		self:getChildByName("_num_label"):setString(_num)
	end
end

function ResourceItem1:setEnableTouch(flag)
	self._enableTouch = flag
end

function ResourceItem1:isEnableTouch(flag)
	return self._enableTouch
end

function ResourceItem1:createItemByType(itemtype,num)
	--[[
	self.ResourceItem1 = {
		[1] = "领地经验",
		[2] = "银两",
		[3] = "元宝",
		[5] = "体力",
	}
	]]--
	return self.new(itemtype,num)
end

function ResourceItem1:onExit()
	if self.TipsBg then
		self.TipsBg:removeFromParent()
		self.TipsBg = nil
	end
end

function ResourceItem1:_getTipsLayer(itemtype,num)
	local bg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/tips_bg.png")
	bg:setContentSize(cc.size(281,115))
	local shadow = cc.Sprite:create("res/image/common/tips_shadow.png")
	shadow:setScaleX(bg:getBoundingBox().width/shadow:getBoundingBox().width)
	shadow:setScaleY(1.1)
	shadow:setAnchorPoint(0.5,0)
	shadow:setPosition(bg:getContentSize().width/2,8)
	bg:addChild(shadow)
	if itemtype then
		local descLabel = XTHDLabel:createWithParams({
            text = self.ResourceDesc[tonumber(itemtype)],
            fontSize = 18,
            color = cc.c3b(255,255,255)
        })
        descLabel:setAnchorPoint(0,1)
        if descLabel:getBoundingBox().width > 252 then
        	bg:setContentSize(cc.size(281,115+20))
        	shadow:setScaleY(2.2)
        end
        descLabel:setDimensions(253,60)
        descLabel:setPosition(13,shadow:getPositionY()+shadow:getBoundingBox().height)
        bg:addChild(descLabel)

		local item = self:createItemByType(itemtype)
        item:setScale(0.7)
        item:setPosition(10+item:getBoundingBox().width/2,bg:getBoundingBox().height-10-item:getBoundingBox().height/2)
        bg:addChild(item)

        if self:getChildByName("_num_label") then
	        local levelLabel = XTHDLabel:createWithParams({
	            text = self:getChildByName("_num_label"):getString()..self.ResourceItem1[tonumber(itemtype)],
	            fontSize = 18,
	            color = cc.c3b(255,240,160)
	        })
	        levelLabel:setAnchorPoint(0,1)
	        levelLabel:setPosition(item:getPositionX()+item:getBoundingBox().width/2+10,item:getPositionY()-item:getBoundingBox().height/2+levelLabel:getBoundingBox().height)
	        bg:addChild(levelLabel)
	    end

        local nameLabel = XTHDLabel:createWithParams({
            text = self.ResourceItem1[tonumber(itemtype)],
            fontSize = 18,
            color = cc.c3b(255,255,255)
        })
        nameLabel:setAnchorPoint(0,1)
        nameLabel:setPosition(item:getPositionX()+item:getBoundingBox().width/2+10,item:getPositionY()+item:getBoundingBox().height/2)
        bg:addChild(nameLabel)
	end
	return bg
end