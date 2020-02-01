ZhuangBeiItem =  class("ZhuangBeiItem", function (item_data,simele)
	--return cc.Node:create()

	local _equipItem = nil

	if item_data["dbId"] then
		--若要以dbId创建（显示星级)
		local UserData = DBTableItem.getData(gameUser.getUserId(),{dbid = "'"..item_data["dbId"].."'"})
	    if #UserData == 0 then
	        UserData = DBTableEquipment.getData(gameUser.getUserId(), {dbid = "'"..item_data["dbId"].."'"})
	    end
	    item_data["id"] = UserData[1].itemid
	    item_data["phaseLevel"] = UserData[1].phaseLevel
	end

	if simele == true then
		_equipItem = ZhuangBeiItem:getItemNode(item_data)
	else
		local _selectScale = item_data["selectScale"] or 0.95 --点击缩放比例 默认0.95
		_equipItem = XTHDPushButton:createWithParams({
			normalNode = ZhuangBeiItem:getItemNode(item_data),
			selectedNode = ZhuangBeiItem:getItemNode(item_data,_selectScale),
			needSwallow = false,
			enable = true,
			isScrollView = true,
			-- needEnableWhenMoving = true
		})
		_equipItem:setCascadeOpacityEnabled(true)
	end
	if not item_data["quality"] and item_data["resourceid"] then
		--若没传入品级 则查品级
	end
	item_data["strengLevel"] = item_data["strengLevel"] or 0

	local label_level = getCommonWhiteBMFontLabel(item_data["strengLevel"] or 0)
	local _width = 28
	if tonumber(label_level:getContentSize().width)>28 then
		_width = tonumber(label_level:getContentSize().width)+2
	end
	
	local level_bg = cc.Sprite:createWithTexture(nil,cc.rect(0,0,_width,19))
    level_bg:setColor(cc.c3b(0,0,0))
    level_bg:setOpacity( 125.0 )
    level_bg:setAnchorPoint(0,0)
    level_bg:setPosition(4,25)
    _equipItem.level_bg = level_bg
    _equipItem.strengLevel = label_level

    label_level:setAnchorPoint(cc.p(0.5,0.5))
    label_level:setCascadeColorEnabled(true)
    label_level:setPosition(level_bg:getContentSize().width/2, level_bg:getContentSize().height / 2-7)
  
	 if  tonumber(item_data["strengLevel"]) <= 0 then
    	level_bg:setVisible(false)
    	label_level:setVisible(false)
    end
  
    _equipItem:addChild(level_bg)
    level_bg:addChild(label_level)

	_equipItem:setCascadeColorEnabled(true)
	_equipItem:setCascadeOpacityEnabled(true)
	return _equipItem
end)

function ZhuangBeiItem:ctor( item_data,simele )
	if item_data["count"] then
		local _num_label = getCommonWhiteBMFontLabel(item_data["count"])
		-- _num_label:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(2,-2),3)
		_num_label:setName("_num_label")
		_num_label:setAnchorPoint(1,0.5)
		-- _num_label:setSystemFontSize(18)
		-- _num_label:setString(item_data["count"])
		_num_label:setPosition(self:getContentSize().width-3-3, 10)
		self:addChild(_num_label)
	end

	if item_data["phaseLevel"] then
		local ILevel = tonumber(item_data["phaseLevel"])
	    local filePath = "res/image/common/copper_star.png"
	    if ILevel > 5 and ILevel <= 10 then
	        filePath = "res/image/common/silver_star.png"
	    elseif ILevel > 10 and ILevel <= 15 then
	        filePath = "res/image/common/gold_star.png"
	    end
	    local starnum = 0
	    if ILevel ~= 0 then
	        starnum = ILevel%5 == 0 and 5 or ILevel%5
	    end
	    for i=1,starnum do
	        local star = cc.Sprite:create(filePath)
	        star:setScale(0.5)
	        local lenth = 0
            local bgwidth = self:getBoundingBox().width
            local minbg = (bgwidth-(starnum*star:getBoundingBox().width)-(starnum*lenth))/2
            star:setPosition(minbg+((i-1)*(lenth+star:getBoundingBox().width))+star:getBoundingBox().width/2,self:getBoundingBox().height*0.15)
	        self:addChild(star)
	    end
	end

	self._enableTouch = true

	if item_data["needTips"] and item_data["needTips"] == true then
		if self._enableTouch == true then
			self:setEnableWhenOut(true)
			self:setTouchBeganCallback(function ()
				local tmpPos = self:convertToWorldSpace(cc.p(0,0))

				self.TipsBg = self:_getTipsLayer(item_data["id"])

				if tmpPos.x > cc.Director:getInstance():getWinSize().width/2 and tmpPos.y > cc.Director:getInstance():getWinSize().height/2 then --第一象限
					self.TipsBg:setAnchorPoint(cc.p(1,1))
					self.TipsBg:setPosition(tmpPos.x,tmpPos.y)
				elseif tmpPos.x < cc.Director:getInstance():getWinSize().width/2 and tmpPos.y > cc.Director:getInstance():getWinSize().height/2 then --第二象限
					self.TipsBg:setAnchorPoint(cc.p(0,1))
					self.TipsBg:setPosition(tmpPos.x+self:getBoundingBox().width,tmpPos.y)
				elseif tmpPos.x < cc.Director:getInstance():getWinSize().width/2 and tmpPos.y < cc.Director:getInstance():getWinSize().height/2 then --第三象限
					self.TipsBg:setAnchorPoint(cc.p(0,0))
					self.TipsBg:setPosition(tmpPos.x+self:getBoundingBox().width,tmpPos.y+self:getBoundingBox().height)
				elseif tmpPos.x > cc.Director:getInstance():getWinSize().width/2 and tmpPos.y < cc.Director:getInstance():getWinSize().height/2 then --第四象限
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
end
function ZhuangBeiItem:setEnableTouch(flag)
	self._enableTouch = flag
end
function ZhuangBeiItem:isEnableTouch()
	return self._enableTouch
end
function ZhuangBeiItem:onExit()
	if self.TipsBg then
		self.TipsBg:removeFromParent()
		self.TipsBg = nil
	end
end
--刷新数量
function ZhuangBeiItem:setCountNumber(_num)
	if self:getChildByName("_num_label") then
		self:getChildByName("_num_label"):setString(_num)
	end
end
--刷新强化等级
function ZhuangBeiItem:refreshStregthenLevel(_streng_level)
	if self.strengLevel then
		if tonumber(_streng_level) <= 0 then
	    	self.level_bg:setVisible(false)
	    	self.strengLevel:setVisible(false)
	    else
	    	self.level_bg:setVisible(true)
	    	self.strengLevel:setVisible(true)
	    end
		self.strengLevel:setString(_streng_level)
	end
end

--装备id，装备品级 ,
function ZhuangBeiItem:getItemNode(item_data,_scale)
	_scale = _scale or 1
    
   
    local _imgBgpath = XTHD.resource.getQualityItemBgPath(item_data["quality"])
    local imgPath = ""
    local _img_scale = 0
    if item_data["item_type"] and tonumber(item_data["item_type"]) == 2 then
    	imgPath = XTHD.resource.getHeroAvatorImgById(item_data["resourceid"])
    	_img_scale = 0.85
    	_imgBgpath = "res/image/quality/chip_" .. (item_data.quality or 1) .. ".png"
    else
    	imgPath = XTHD.resource.getItemImgById(item_data["resourceid"])
    end
    local item_bg = cc.Sprite:create(_imgBgpath) 
    item_bg:setCascadeOpacityEnabled(true)
    item_bg:setCascadeColorEnabled(true)

    local item_image = cc.Sprite:create(imgPath)

    if _img_scale > 0 then
    	-- item_image:setScale(_img_scale)
    end
    item_image:setCascadeOpacityEnabled(true)
    item_image:setCascadeColorEnabled(true)
    item_image:setPosition(item_bg:getContentSize().width/2, item_bg:getContentSize().height/2)
    item_bg:addChild(item_image,-1)
    item_bg:setScale(_scale)

    return item_bg
end

--该方法创建的装备会显示，数量之类的东西，后期会根据需求添加可能需要显示的信息，
function ZhuangBeiItem:createClickedItem(item_data)
	return self.new(item_data)
end

--创建简单的装备图标，只显示外框和图片，
function ZhuangBeiItem:createSimpleItem(item_data)
	return self.new(item_data,true)
end

--[[
	该方法用穿进来的新数据刷新所有显示数据，构造成一个完全新颖的item，旨在省去移除老的，创建新的这种操作
]]
function ZhuangBeiItem:refreshItemWithNewData(item_data)
end
function ZhuangBeiItem:_getTipsLayer(id)
	-- local bg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/tips_bg.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
	bg:setContentSize(cc.size(281,115))
	local shadow = cc.Sprite:create("res/image/common/tips_shadow.png")
	shadow:setScaleX(bg:getBoundingBox().width/shadow:getBoundingBox().width)
	shadow:setScaleY(1.1)
	shadow:setAnchorPoint(0.5,0)
	shadow:setPosition(bg:getContentSize().width/2,8)
	bg:addChild(shadow)
	if id then

        local dbData = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = id})
		local descLabel = XTHDLabel:createWithParams({
            text = dbData.description,
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

		local item = self:createClickedItem({
            id = id,
            selectScale = 1,
        })
        item:setScale(0.7)
        item:setPosition(10+item:getBoundingBox().width/2,bg:getBoundingBox().height-10-item:getBoundingBox().height/2)
        bg:addChild(item)

        local nameLabel = XTHDLabel:createWithParams({
            text = dbData.name,
            fontSize = 18,
            color = cc.c3b(255,255,255)
        })
        nameLabel:setAnchorPoint(0,1)
        nameLabel:setPosition(item:getPositionX()+item:getBoundingBox().width/2+10,item:getPositionY()+item:getBoundingBox().height/2)
        bg:addChild(nameLabel)

        local levelword = LANGUAGE_KEY_LEVEL_LIMIT..":"..dbData.level -----需求等级
        if dbData.level == -1 then
        	levelword = LANGUAGE_KEY_LEVEL_LIMIT_NONE--------"无等级限制"
        end

        local levelLabel = XTHDLabel:createWithParams({
            text = levelword,
            fontSize = 18,
            color = cc.c3b(255,240,160)
        })
        levelLabel:setAnchorPoint(0,1)
        levelLabel:setPosition(item:getPositionX()+item:getBoundingBox().width/2+10,item:getPositionY()-item:getBoundingBox().height/2+levelLabel:getBoundingBox().height)
        bg:addChild(levelLabel)

        local ownNum = 0
        local ownData = DBTableItem.getData( gameUser.getUserId(), {itemId = id} )
        if #ownData ~= 0 and type(ownData[1]) == "table" then
        	for i=1,#ownData do
        		ownNum = ownNum + ownData[i].count
        	end
        else
        	ownNum = ownData.count or 0
        end

        local ownData = DBTableEquipment.getData(gameUser.getUserId(), {itemid = id} )
        if #ownData ~= 0 and type(ownData[1]) == "table" then
        	for i=1,#ownData do
        		ownNum = ownNum + 1
        	end
        end

        local ownLabel = XTHDLabel:createWithParams({
            text = LANGUAGE_FORMAT_TIPS32(ownNum),-------"(拥有"..ownNum.."件)",
            fontSize = 16,
            color = cc.c3b(255,240,160)
        })
        ownLabel:setAnchorPoint(1,1)
        ownLabel:setPosition(bg:getBoundingBox().width-10,nameLabel:getPositionY())
        bg:addChild(ownLabel)

        local priceLabel = XTHDLabel:createWithParams({
            text = dbData.price,
            fontSize = 18,
            color = cc.c3b(255,240,160)
        })
        priceLabel:setAnchorPoint(1,1)
        priceLabel:setPosition(bg:getBoundingBox().width-10,levelLabel:getPositionY())
        bg:addChild(priceLabel)

        local priceIcon = cc.Sprite:create("res/image/common/task_gold_icon_2.png")
        priceIcon:setPosition(priceLabel:getPositionX()-priceLabel:getBoundingBox().width-priceIcon:getBoundingBox().width/2,priceLabel:getPositionY()-priceLabel:getBoundingBox().height/2)
        bg:addChild(priceIcon)

        

	end
	return bg
end