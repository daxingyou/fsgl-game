--Created By Liuluyang 2015年05月04日
local WanBaoGeDescPop = class("WanBaoGeDescPop",function ( sParams )
	local _removeLayout = sParams.removeLayout
	local _params = {isRemoveLayout = _removeLayout}
	-- if sParams.opacityValue and sParams.hideCallback then
	-- 	_params
	-- end
	
	return XTHDPopLayer:create(_params)
end)

function WanBaoGeDescPop:ctor( sParams )
	self.flower = sParams.sFlower
	self.func = sParams.sCallFn
	self.type = sParams.sType
	self.time = sParams.sTime
	self.prayId = sParams.sPrayId
	self.prayDay = sParams.sPrayDay
	self.parentLayer = sParams.parentLayer
	self._removeLayout = sParams.removeLayout
	self:initUI(sParams.sData)
end

function WanBaoGeDescPop:initUI( sWweaponData)
	local weaponData = sWweaponData
	local itemId = weaponData.itemId

	-- local bg = ccui.Scale9Sprite:create(cc.rect(14,15,1,1),"res/image/common/equip_selected.png")
	-- local bg = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_2.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
	bg:setName("bg")
	bg:setContentSize(cc.size(355,444))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)
	--第二个框
	local bg_2 = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	bg_2:setContentSize(cc.size(325,300))
	bg_2:setPosition(bg:getContentSize().width/2,bg:getBoundingBox().height/4+20)
	bg_2:setAnchorPoint(0.5,0)
	bg:addChild(bg_2)
	-- print("itemId"..itemId)

	local ItemData = {}
	ItemData = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = itemId})
	ItemData.ownNum = XTHD.resource.getItemNum(itemId)
	if self.prayId and self.prayId ~= 0 then
		if weaponData._type_ == 3 then
			ItemData.effect = LANGUAGE_RESOURCEDESCRIBETIONS[weaponData._type_]
			ItemData.description = ""
			ItemData.name = LANGUAGE_KEY_COIN
			ItemData.ownNum = gameUser.getIngot()
		elseif weaponData._type_ == 2 then
			ItemData.effect = LANGUAGE_RESOURCEDESCRIBETIONS[weaponData._type_]
			ItemData.description = ""
			ItemData.name = LANGUAGE_KEY_GOLD
			ItemData.ownNum = gameUser.getGold()
		elseif weaponData._type_ == 6 then
			ItemData.effect = LANGUAGE_RESOURCEDESCRIBETIONS[weaponData._type_]
			ItemData.description = ""
			ItemData.name = LANGUAGE_KEY_JADE
			ItemData.ownNum = gameUser.getFeicui()
		end
	end
	-- dump( ItemData,"itemData" )
	local EquipData = nil
	if ItemData.type == 3 then
		EquipData = gameData.getDataFromCSV("EquipInfoList",{itemid = itemId})
	end

	local ItemIcon = nil
	local ItemName = nil

	local itemIconData = {
		itemId = itemId,
        _type_ = 4,
	}
	if self.prayId and self.prayId ~= 0 then
		itemIconData._type_ = weaponData._type_
		itemIconData.count = weaponData.count
	end
	ItemIcon = ItemNode:createWithParams(itemIconData)
	ItemIcon:setAnchorPoint(0,1)
	ItemIcon:setPosition(25,bg:getBoundingBox().height-35)
	bg:addChild(ItemIcon)

	ItemName = XTHDLabel:createWithParams({
        text = ItemData.name,
        fontSize = 20,
        color = XTHD.resource.color.brown_desc
    })
    ItemName:setAnchorPoint(0,1)
    ItemName:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
    ItemName:setPosition(ItemIcon:getPositionX()+ItemIcon:getBoundingBox().width+10,ItemIcon:getPositionY())
    bg:addChild(ItemName)

    local OwnLabel1 = XTHDLabel:createWithParams({  --拥有xx个 (富文本英文版需要修改 by andong)
        text = LANGUAGE_VERBS.owned,------"拥有",
        fontSize = 20,
        color = XTHD.resource.color.brown_desc
    })
    OwnLabel1:setAnchorPoint(0,0.5)
    OwnLabel1:setPosition(ItemIcon:getPositionX()+ItemIcon:getBoundingBox().width+10,ItemIcon:getPositionY()-ItemIcon:getBoundingBox().height/2)
    bg:addChild(OwnLabel1)

    local ownNum = getCommonWhiteBMFontLabel(ItemData.ownNum)
    -- XTHDLabel:createWithParams({
    --     text = XTHD.resource.getItemNum(itemId),
    --     fontSize = 20,
    --     color = XTHD.resource.textColor.green_text
    -- })
    ownNum:setAnchorPoint(0,0.5)
    ownNum:setPosition(OwnLabel1:getPositionX()+OwnLabel1:getBoundingBox().width,ItemIcon:getPositionY()-ItemIcon:getBoundingBox().height/2-7)
    bg:addChild(ownNum)

    local OwnLabel1 = XTHDLabel:createWithParams({
        text = LANGUAGE_UNKNOWN.a,------"个",
        fontSize = 20,
        color = XTHD.resource.color.brown_desc
    })
    OwnLabel1:setAnchorPoint(0,0.5)
    OwnLabel1:setPosition(ownNum:getPositionX()+ownNum:getBoundingBox().width,ItemIcon:getPositionY()-ItemIcon:getBoundingBox().height/2)
    bg:addChild(OwnLabel1)

    if ItemData.type == 3 then
    	--若为装备 显示可用英雄类型
	    local HeroType = XTHDLabel:createWithParams({
	        text = LANGUAGE_KEY_CANUSETYPE..":",------可用类型：",
	        fontSize = 20,
	        color = cc.c3b(70, 34, 34)
	    })
	    HeroType:setAnchorPoint(0,0)
	    HeroType:setPosition(ItemName:getPositionX(),ItemIcon:getPositionY()-ItemIcon:getBoundingBox().height)
	    bg:addChild(HeroType)

	    local _tb = string.split(EquipData.herotype,"#")
	    for i=1,#_tb do
	    	local nowIcon = cc.Sprite:create("res/image/plugin/hero/hero_type_".._tb[i]..".png")
	    	nowIcon:setPosition(HeroType:getPositionX()+HeroType:getBoundingBox().width+nowIcon:getBoundingBox().width/2+((i-1)*nowIcon:getBoundingBox().width),HeroType:getPositionY()+HeroType:getBoundingBox().height/2)
	    	bg:addChild(nowIcon)
	    end
	end

	local attributesBg = ccui.Scale9Sprite:create(cc.rect(10,10,1,1),"res/image/common/scale9_bg_5.png")
	attributesBg:setOpacity(0)
	attributesBg:setContentSize(cc.size(324,26+23))
	attributesBg:setAnchorPoint(0.5,1)
	attributesBg:setPosition(bg:getBoundingBox().width/2,ItemIcon:getPositionY()-ItemIcon:getBoundingBox().height-10)
	bg:addChild(attributesBg)

	attributesBg.num = 0
	attributesBg.tmpnum = 0

	if ItemData.type == 3 then
		for i=1,#XTHD.resource.AttributesNum do
			local nowData = tostring(EquipData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]])
			if nowData ~= "0" then
				attributesBg.tmpnum = attributesBg.tmpnum + 1
			end
		end
		local bgPlus = attributesBg.tmpnum > 1 and 24.5 or 0
		attributesBg:setContentSize(cc.size(attributesBg:getBoundingBox().width,attributesBg:getBoundingBox().height+(attributesBg.tmpnum*24.5)-bgPlus))

		for i=1,#XTHD.resource.AttributesNum do
			local nowData = tostring(EquipData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]])
			if nowData ~= "0" then
				attributesBg.num = attributesBg.num + 1
				local nowAttributesLabel = XTHDLabel:createWithParams({--XTHD.resource.AttributesNum[i]
			        text = XTHD.resource.getAttributes(XTHD.resource.AttributesNum[i]),
			        fontSize = 18,
			        color = XTHD.resource.color.brown_desc
			    })
			    nowAttributesLabel:setAnchorPoint(0,1)
			    nowAttributesLabel:setPosition(8,attributesBg:getBoundingBox().height-5-((attributesBg.num-1)*(nowAttributesLabel:getBoundingBox().height+5)))
			    attributesBg:addChild(nowAttributesLabel)
			    local _tb = string.split(nowData,"#")
			    local nowAttributes = XTHDLabel:createWithParams({--XTHD.resource.AttributesNum[i]
			        text = "+ ("..XTHD.resource.addPercent(XTHD.resource.AttributesNum[i],_tb[1])
			        	.."-"..XTHD.resource.addPercent(XTHD.resource.AttributesNum[i],_tb[2])..")",
			        fontSize = 18,
			        color = cc.c3b(104,157,0)
			    })
			    nowAttributes:setAnchorPoint(0,1)
			    nowAttributes:enableShadow(cc.c4b(0,0,0,255),cc.size(0.4,-0.4))
			    nowAttributes:setPosition(nowAttributesLabel:getPositionX()+nowAttributesLabel:getBoundingBox().width,nowAttributesLabel:getPositionY())
			    attributesBg:addChild(nowAttributes)

		    	self.lastSplit = cc.Sprite:create("res/image/plugin/reforge/main_bg_split.png")
			    self.lastSplit:setPosition(attributesBg:getBoundingBox().width/2,nowAttributes:getPositionY()-nowAttributes:getBoundingBox().height-3)
			    attributesBg:addChild(self.lastSplit)
			end
		end
		if self.lastSplit then
			self.lastSplit:removeFromParent()
		end
	else
		local ItemEffect = XTHDLabel:createWithParams({
	        text = ItemData.effect,
	        fontSize = 18,
	        color = cc.c3b(70,34,34)--XTHD.resource.color.brown_desc
	    })
	    ItemEffect:setAnchorPoint(0,0.5)
	    -- ItemEffect:setDimensions(260,138)
	    ItemEffect:setWidth(300)
	    local bgPlus = ItemEffect:getBoundingBox().height > 24 and 23 or 0
	    attributesBg:setContentSize(attributesBg:getBoundingBox().width,attributesBg:getBoundingBox().height+ItemEffect:getBoundingBox().height-bgPlus)
	    local limitHeight = attributesBg:getPositionY() - 130
	    if self.type and self.type == 3 and tonumber(weaponData.vip or 0) > 0 then
	    	limitHeight = limitHeight - 30
		end
		local scrollview = ccui.ScrollView:create()
		scrollview:setScrollBarEnabled(false)
		attributesBg:addChild( scrollview )
		scrollview:setAnchorPoint( 0, 0 )
		scrollview:setPosition( 0, 10 )
		scrollview:setTouchEnabled(true)
		scrollview:setDirection( ccui.ScrollViewDir.vertical )
		if attributesBg:getContentSize().height > limitHeight then
			-- 超长
			scrollview:setContentSize( cc.size( attributesBg:getContentSize().width, limitHeight - 20 ) )
			scrollview:setInnerContainerSize( cc.size( attributesBg:getContentSize().width, ItemEffect:getContentSize().height ) )
			scrollview:setBounceEnabled(true)
			attributesBg:setContentSize( attributesBg:getContentSize().width, limitHeight )
	    	ItemEffect:setPosition(8,scrollview:getInnerContainerSize().height/2)
		else
			scrollview:setContentSize( cc.size( attributesBg:getContentSize().width, attributesBg:getContentSize().height - 20 ) )
			scrollview:setInnerContainerSize( cc.size( attributesBg:getContentSize().width, ItemEffect:getContentSize().height ) )
			scrollview:setBounceEnabled(false)
	    	ItemEffect:setPosition(8,scrollview:getInnerContainerSize().height/2)
		end
	    scrollview:addChild(ItemEffect)
	end

	-- local Split_middle = cc.Sprite:create("res/image/plugin/reforge/reforge_split.png")
	-- Split_middle:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-265)
	-- bg:addChild(Split_middle)

	local ItemDesc = XTHDLabel:createWithParams({
        text = ItemData.description,
        fontSize = 18,
        color = cc.c3b(255,79,2)
    })
    ItemDesc:setAnchorPoint(0,1)
    ItemDesc:setPosition(22,attributesBg:getPositionY()-attributesBg:getBoundingBox().height-5)
    -- ItemDesc:setDimensions(260,60)
    ItemDesc:setWidth(308)
    bg:addChild(ItemDesc)

 --    local Split_down = cc.Sprite:create("res/image/plugin/reforge/reforge_split.png")
	-- Split_down:setPosition(Split_middle:getPositionX(),ItemDesc:getPositionY()-60-Split_down:getBoundingBox().height/2)
	-- bg:addChild(Split_down)

	local costBg = ccui.Scale9Sprite:create(cc.rect(43,18,1,1),"res/image/common/op_white.png")
	costBg:setOpacity(0)
	costBg:setContentSize(cc.size(327,40))
	costBg:setAnchorPoint(0.5,0)
	costBg:setPosition(bg:getBoundingBox().width/2,85)
	bg:addChild(costBg)
	costBg:setName("costBg")

	local _needVip = 0
	if self.type and self.type == 3 then
		local vip = tonumber(weaponData.vip) or 0
		if vip > 0 then
			_needVip = vip
			local costLabel = XTHDLabel:createWithParams({
		        text = LANGUAGE_TIPS_WORDS222(_needVip),-----"购买消耗",
		        fontSize = 18,
		        color = cc.c3b(70, 34, 34),
		        anchor = cc.p(0, 0),
		        pos = cc.p(10, costBg:getBoundingBox().height + 5)
		    })
		    costLabel:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
		    costBg:addChild(costLabel)
		end
	end

	local costLabel_text = ""
	if self.prayId and self.prayId ~= 0 then
		costLabel_text = LANGUAGE_KEY_PRAYER[7]
	else
		costLabel_text = LANGUAGE_TIP_BUYCOST
	end
	local costLabel = XTHDLabel:createWithParams({
        text = costLabel_text,-----"购买消耗",
        fontSize = 18,
        color = cc.c3b(70, 34, 34)
    })
    costLabel:setAnchorPoint(0,0.5)
    costLabel:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
    costLabel:setPosition(10,costBg:getBoundingBox().height*0.5)
    costBg:addChild(costLabel)
    costLabel:setName("costLabel")


    local ConsumeIcon, ConsumeNum
    if self.type and self.type == 1 then
    	local _tb = string.split(weaponData.price,"#")
        ConsumeNum = getCommonWhiteBMFontLabel(_tb[3])
        if tonumber(_tb[1]) ~= XTHD.resource.type.item then
            ConsumeIcon = cc.Sprite:create(XTHD.resource.getResourcePath((_tb[1])))
        else
            ConsumeIcon = cc.Sprite:create(IMAGE_KEY_HEADER_PSYCHICSTONE)
        end
    elseif self.type and self.type == 3 then
        ConsumeIcon = cc.Sprite:create(IMAGE_KEY_HEADER_FLOWER)
        ConsumeNum = getCommonWhiteBMFontLabel(weaponData.price)
    elseif self.prayId and self.prayId ~= 0 then
    	ConsumeNum = getCommonWhiteBMFontLabel(1)
	end
    ConsumeNum:setAnchorPoint(1,0.5)
    ConsumeNum:setPosition(costBg:getBoundingBox().width-20,costLabel:getPositionY()-7)
    costBg:addChild(ConsumeNum)
    if not self.prayId or self.prayId == 0 then
	    ConsumeIcon:setAnchorPoint(1,0.5)
	    ConsumeIcon:setPosition(ConsumeNum:getPositionX()-ConsumeNum:getBoundingBox().width-10,ConsumeNum:getPositionY()+7)
	    costBg:addChild(ConsumeIcon)
	end

	local BuyBtn, _text, _endCall
    if self.prayId and self.prayId ~= 0 then
    	-- 许愿
    	_text = LANGUAGE_BTN_KEY.querenxuyuan
		_endCall = function()
			BuyBtn:setEnable( false )
			ClientHttp:requestAsyncInGameWithParams({
				modules = "wishRequest?",
				params = {configId = ( self.prayDay - 1 )*10 + self.prayId},
                successCallback = function( data )
                	-- dump(data,"许愿返回")
                    if tonumber(data.result) == 0 then
						self.parentLayer._curWishPoint = data.curWishPoint or 0
						self.parentLayer._canWishCount = data.canWishCount or 0
						self.parentLayer._dayRevert = data.dayRevert
						self.parentLayer._diffTime = data.diffTime
						self.parentLayer._prayedIcons = data.list
						self.parentLayer:createAnimationIcon( self.prayId )
				    	self.parentLayer:refreshUI( true, true )
			    	else
                        XTHDTOAST(data.msg)
                    end
			    	self:hide({music = true})
                end,
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
					--self:hide({music = true})
                end,--失败回调
				loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
				loadingParent = self,
            })
		end
    else
    	_text = LANGUAGE_BTN_KEY.querengoumai
    	_endCall = function()
			if self.type and self.type == 3 then
        		if gameUser.getVip() < _needVip then
        			local s = LANGUAGE_TIPS_WORDS223(_needVip)
					XTHDTOAST(s)
					return
        		end
        		local _cost = tonumber(weaponData.price) or 0
        		if self.flower < _cost then
		        	XTHDTOAST(LANGUAGE_TIPS_WORDS203)------"鲜花数量不足！")
	        		return
	        	end
        		if self.time <= 0 then
	        		XTHDTOAST(LANGUAGE_TIPS_WORDS204)-------"今日可购买次数已用完！")
	        		return
	        	end
        	end
        	
        	local _modules = self.type == 1 and "buyWeaponItem?" or "buyFlowerItem?"
        	XTHDHttp:requestAsyncInGameWithParams({
        		modules = _modules,
                params = {configId = weaponData.configId},
                successCallback = function(data)
	                if tonumber(data.result) == 0 then
	                	XTHD.saveItem({items = data.items})
	                	if self.type == 1 then
		                	gameUser.setGold(data.gold)
		                	gameUser.setIngot(data.ingot)
		                	gameUser.setFeicui(data.feicui)
		                end
	                	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
	                	XTHDTOAST(LANGUAGE_TIP_SUCCESS_TO_BUY)-------"购买成功")
	                    self.func()
	                    -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER})
	                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
	                    self:hide({music = true})
                    elseif tonumber(data.result) == 2000 then
		                XTHD.createExchangePop(3)
	                else
	                    XTHDTOAST(data.msg)
	                end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
		end
    end
    BuyBtn = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
        btnSize = cc.size(336,66),
        text = _text,
        fontSize = 26,
        musicFile = "res/sound/ShopBuySomeThing.mp3",
        endCallback = _endCall
	})
	BuyBtn:setScale(0.6)
    BuyBtn:setAnchorPoint(0.5,0)
    BuyBtn:setPosition(bg:getBoundingBox().width/2,42)
    bg:addChild(BuyBtn)
end

function WanBaoGeDescPop:getBg()
	return self:getChildByName("bg")
end

function WanBaoGeDescPop:create(params)
	return self.new(params)
end

return WanBaoGeDescPop