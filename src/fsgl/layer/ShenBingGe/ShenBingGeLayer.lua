-- 神兵阁界面

local ShenBingGeLayer=class("ShenBingGeLayer",function (data)
    return XTHD.createBasePageLayer({bg = "res/image/equipCopies/copies_bg.png"})
end)

function ShenBingGeLayer:ctor(data)
	cc.SpriteFrameCache:getInstance():addSpriteFrames("res/image/equipCopies/shang.plist", "res/image/equipCopies/shang.png")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("res/image/equipCopies/xia.plist", "res/image/equipCopies/xia.png")
	self.staticItemData = gameData.getDataFromCSV("ShenbinggeList")
    self:setColor(cc.c3b(0,0,0))
    self:setOpacity(80)
    if data then 
    	self:initUI(data)
	end

	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_EQUIPCOPY,callback = function (event)
		self:changeBtnState()
    end})
end

function ShenBingGeLayer:onCleanup()
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_EQUIPCOPY)
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/equipCopies/copies_bg.png")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile('res/image/equipCopies/shang.plist')
    textureCache:removeTextureForKey("res/image/equipCopies/shang.png")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile('res/image/equipCopies/xia.plist')
    textureCache:removeTextureForKey("res/image/equipCopies/xia.png")
    textureCache:removeTextureForKey("res/image/equipCopies/title.png")
    textureCache:removeTextureForKey("res/image/equipCopies/dropbg.png")
    textureCache:removeTextureForKey("res/image/equipCopies/copies_name.png")
    textureCache:removeTextureForKey("res/image/equipCopies/drop_info.png")
    textureCache:removeTextureForKey("res/image/equipCopies/equip_base.png")
    for i=2, 6 do
    	textureCache:removeTextureForKey("res/image/equipCopies/equip_" .. i .. "_" .. 1 ..".png")
    	textureCache:removeTextureForKey("res/image/equipCopies/equip_" .. i .. "_" .. 2 ..".png")
    end
end

function ShenBingGeLayer:onEnter()
	self:addGuide()
end

function ShenBingGeLayer:changeBtnState()
	ClientHttp:httpEquipEctypes(self, function ( data )
		self.state=data["ectypes"][1]["state"]
   		if self.state == 1 and self.tongguan then
   			self.tongguan:setVisible(true)
   		end
	end)
end
	
function ShenBingGeLayer:initUI(data)
	self.id=data["ectypes"][1]["ectypeId"]
	self.state=data["ectypes"][1]["state"]
	self.data=data 
	self.surplusRefreshSum=data.surplusRefreshSum or 0

    local size = self:getContentSize()
    self.bg = XTHD.createSprite()
    self.bg:setContentSize(size.width,size.height - self.topBarHeight)
    self.bg:setPosition(size.width*0.5, (size.height - self.topBarHeight)*0.5)
    self:addChild(self.bg)

	local title = cc.Sprite:create("res/image/equipCopies/title.png")
	title:setAnchorPoint(0,1)
	title:setPosition(50,self.bg:getContentSize().height-20)
	title:setScale(0.8)
	self.bg:addChild(title)
	--掉落区域 装备展示区域
	self:createDropBg()
	--极限刷新
	self.btnrefreshbest_status=true
	local btn_refreshmax = XTHD.createCommonButton({
		btnColor = "write",
		isScrollView = false,
        text = LANGUAGE_BTN_KEY.jixianshuaxin,
        btnSize = cc.size(130, 51),
        fontSize = 26,
		endCallback=function ( )
			if self.btnrefreshbest_status==true then
				self:doRefreshEquipEctypes(true)
		    end 
		end
    })
	btn_refreshmax:setAnchorPoint(0.5,0.5)
	btn_refreshmax:setPosition(160,80-50)
	btn_refreshmax:setScale(0.7)
	self.bg:addChild(btn_refreshmax,1)
	-- local refreshmax_label=XTHD.resource.getButtonImgTxt("jixianshuaxin_lan")--XTHDLabel:createWithParams({text="极限刷新",ttf="",size=18})
	-- refreshmax_label:setPosition(btn_refreshmax:getContentSize().width/2,btn_refreshmax:getContentSize().height/2)
	-- btn_refreshmax:addChild(refreshmax_label)

    local nummax_bg=ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")--cc.Sprite:create("res/image/equipCopies/dikuang.png")
    nummax_bg:setContentSize(cc.size(100,30))
	nummax_bg:setAnchorPoint(0.5,0)
	nummax_bg:setPosition(160,btn_refreshmax:getPositionY()+30)
	self.bg:addChild(nummax_bg)
	local str = LANGUAGE_TIP_REFRESH_COST ----刷新消耗
	self.refresh_num=XTHDLabel:createWithParams({text= str.."：",ttf="res/fonts/def.ttf",size=18}) 
	-- self.refresh_num:setColor(cc.c3b(55,54,112))
	self.refresh_num:setAnchorPoint(0.5,0.5)
	self.refresh_num:setPosition(68,btn_refreshmax:getPositionY()+45)
	self.bg:addChild(self.refresh_num)
	local  gold=cc.Sprite:create("res/image/common/common_gold.png")
	gold:setAnchorPoint(0.5,0.5)
	gold:setScale(0.8)
	gold:setPosition(10,nummax_bg:getContentSize().height/2)
	nummax_bg:addChild(gold)

	self.refresh_num3=XTHDLabel:createWithParams({text=tostring(50+25*(data.maxBestRefreshSum-data.surplusBestRefreshSum)),ttf="res/fonts/def.ttf",size=18}) 
	self.refresh_num3:setAnchorPoint(0.5,0.5)
	self.refresh_num3:setPosition(nummax_bg:getContentSize().width/2 ,nummax_bg:getContentSize().height/2)
	nummax_bg:addChild(self.refresh_num3)

	local maxrefresh_count_bg=ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
	maxrefresh_count_bg:setContentSize(cc.size(100,30))
	maxrefresh_count_bg:setAnchorPoint(0.5,0)
	maxrefresh_count_bg:setPosition(160,btn_refreshmax:getPositionY()+30+40)
	self.bg:addChild(maxrefresh_count_bg)

	local lable = XTHDLabel:createWithParams({text= LANGUAGE_KEY_REFRESHTIMES.."：",ttf="res/fonts/def.ttf",size=18}) 
	lable:setAnchorPoint(0.5,0.5)
	lable:setPosition(maxrefresh_count_bg:getContentSize().width/2 - 93, maxrefresh_count_bg:getContentSize().height/2)
	maxrefresh_count_bg:addChild(lable)

	self.maxrefresh_num=XTHDLabel:create(tostring(data.surplusBestRefreshSum.."/"..data.maxBestRefreshSum), 18,"res/fonts/def.ttf") 
	self.maxrefresh_num:setAnchorPoint(0.5,0.5)
	self.maxrefresh_num:setPosition(maxrefresh_count_bg:getContentSize().width/2, maxrefresh_count_bg:getContentSize().height/2)
	-- self.maxrefresh_num:setColor(cc.c3b(55,54,112))
	maxrefresh_count_bg:addChild(self.maxrefresh_num)
	--刷新
	local btn_refresh = XTHD.createCommonButton({
		text = LANGUAGE_BTN_KEY.shuaxin,
		isScrollView = false,
        btnSize = cc.size(130, 51),
        fontSize = 26,
		pos = cc.p(398, 80-50),
		endCallback = function()
			self:doRefreshEquipEctypes(false)
		end
	})
	btn_refresh:setScale(0.7)
	self.bg:addChild(btn_refresh, 1)

	local num_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
	num_bg:setContentSize(cc.size(100,30))
	num_bg:setAnchorPoint(0.5,0)
	num_bg:setPosition(398, btn_refresh:getPositionY()+30)
	self.bg:addChild(num_bg)
	local str = LANGUAGE_TIP_REFRESH_COST .. "："
	self.refresh_num1 = XTHDLabel:createWithParams({
		text = str,
		size = 18,
		anchor = cc.p(0.5, 0.5),
		pos = cc.p(306,75)
	}) 
	self.bg:addChild(self.refresh_num1)

	local baozi1 = cc.Sprite:create("res/image/common/common_baozi.png")
	baozi1:setAnchorPoint(0,0.5)
	baozi1:setPosition(-5,num_bg:getContentSize().height/2)
	num_bg:addChild(baozi1)

	self.refresh_num2 = XTHDLabel:createWithParams({
		text = tostring(1+1*(data.maxRefreshSum-data.surplusRefreshSum)),
		anchor = cc.p(0,0.5),
		pos = cc.p(baozi1:getPositionX()+baozi1:getContentSize().width+10,num_bg:getContentSize().height/2),
		size = 18
	}) 
	num_bg:addChild(self.refresh_num2)

	local refresh_count_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
	refresh_count_bg:setContentSize(cc.size(100, 30))
	refresh_count_bg:setAnchorPoint(0.5, 0)
	refresh_count_bg:setPosition(398, 100)
	self.bg:addChild(refresh_count_bg)

	local lable =XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_REFRESHTIMES.."：",
		size = 18,
		pos = cc.p(306, btn_refresh:getPositionY()+30+55),
		anchor = cc.p(0.5,0.5)
	}) 
	self.bg:addChild(lable)

	self.refresh_count=XTHDLabel:createWithParams({
		text = tostring(data.surplusRefreshSum.."/"..data.maxRefreshSum),
		size = 18,
		pos = cc.p(400, btn_refresh:getPositionY()+30+55),
		anchor = cc.p(0.5,0.5)
	}) 
	self.bg:addChild(self.refresh_count)
	--人数限制
	local limitnum_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
	limitnum_bg:setContentSize(cc.size(100, 30))
	limitnum_bg:setAnchorPoint(1, 0)
	limitnum_bg:setPosition(self.bg:getContentSize().width-130,btn_refresh:getPositionY()+30+40)
	self.bg:addChild(limitnum_bg)

	local lable = XTHDLabel:createWithParams({
		text = LANGUAGE_TIPS_WORDS39,
		size = 18,
		pos = cc.p(self.bg:getContentSize().width-348, btn_refresh:getPositionY()+30+55),
		anchor = cc.p(0,0.5)
	})
	self.bg:addChild(lable)

	self.limit_num = XTHDLabel:createWithParams({
		text = self.staticItemData[tonumber(self.id)]["herolimit"],
		size = 18,
		pos = cc.p(self.bg:getContentSize().width-185, btn_refresh:getPositionY()+30+55),
		anchor = cc.p(0,0.5)
	})
	self.bg:addChild(self.limit_num)


	--体力消耗
	local tilinum_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
	tilinum_bg:setContentSize(cc.size(100,30))
	tilinum_bg:setAnchorPoint(1,0)
	tilinum_bg:setPosition(self.bg:getContentSize().width-130,btn_refresh:getPositionY()+30)
	self.bg:addChild(tilinum_bg)

	local str = LANGUAGE_TIP_CHALLENGE_COST .. ": "
	self.tilinum = XTHDLabel:createWithParams({
		text = str,
		size = 18,
		pos = cc.p(self.bg:getContentSize().width-320,btn_refresh:getPositionY()+40),
		anchor = cc.p(0,0.5)
	})
	self.bg:addChild(self.tilinum)

	local  baozi1 = cc.Sprite:create("res/image/common/common_baozi.png")
	baozi1:setAnchorPoint(0,0.5)
	baozi1:setPosition(-10,tilinum_bg:getContentSize().height/2)
	tilinum_bg:addChild(baozi1)

	local pNum = self.staticItemData[tonumber(self.id)].hpcost
	self.tilinum1 = XTHDLabel:createWithParams({
		text=" " .. pNum,
		size=18,
		pos = cc.p(tilinum_bg:getContentSize().width/2,tilinum_bg:getContentSize().height/2),
		anchor = cc.p(0.5,0.5)
	})
	tilinum_bg:addChild(self.tilinum1)

end
function ShenBingGeLayer:createDropBg()
	--装备掉落
	if self.dropbg then
	   self.dropbg:removeFromParent()
	end	

	self.dropbg=ccui.Scale9Sprite:create()
	self.dropbg:setContentSize(508,319)
	self.dropbg:setAnchorPoint(1,1)
	self.dropbg:setPosition(self.bg:getContentSize().width,self.bg:getContentSize().height-10)
	self.bg:addChild(self.dropbg,1)

	local copiesName=cc.Sprite:create("res/image/equipCopies/copies_name.png")
	copiesName:setAnchorPoint(0,1)
	copiesName:setPosition(10+80,self.dropbg:getContentSize().height-40)
	self.dropbg:addChild(copiesName)
	local copiesName2=cc.Sprite:create("res/image/equipCopies/copies_name2.png")
	copiesName2:setAnchorPoint(0,1)
	copiesName2:setPosition(10+80,self.dropbg:getContentSize().height-100)
	self.dropbg:addChild(copiesName2)
	local zi_bg = cc.Sprite:create("res/image/equipCopies/zi_bg.png")
	zi_bg:setPosition(copiesName2:getContentSize().width/2,copiesName2:getContentSize().height/2)
	copiesName2:addChild(zi_bg)
	---------进回收商店
	local _shop = XTHD.createPushButtonWithSound({
		normalFile = "res/image/plugin/reforge/smelt_change_normal.png",
		selectedFile = "res/image/plugin/reforge/smelt_change_selected.png",
	},3)
	_shop:setTouchEndedCallback(function(  )
		local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("recycle")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
	end)
	_shop:setScale(0.7)
	self.dropbg:addChild(_shop)
	_shop:setPosition(copiesName:getPositionX() + copiesName:getBoundingBox().width + _shop:getContentSize().width+50,copiesName:getPositionY() - copiesName:getBoundingBox().height / 2+8)

	local  drop_info=cc.Sprite:create("res/image/equipCopies/drop_info.png")
	drop_info:setAnchorPoint(0,0)
	drop_info:setScale(0.8)
	drop_info:setPosition(10+80,self.dropbg:getContentSize().height/2-20)
	self.dropbg:addChild(drop_info)
	--掉落道具信息
	local dropData=self.staticItemData[tonumber(self.id)]["dropshow"]
	local temp=string.split(dropData, '#')
	for k=1,4 do  
		local equip_item=nil 
		if k==4 then
			equip_item = self:makeDropItem(temp[k])
		else
	    	equip_item = self:makeDropEquip(temp[k])
		end
	    local _item_scale = 1
	    equip_item:setAnchorPoint(0,1)
	    equip_item:setScale(_item_scale)
	    equip_item:setPosition(90+102*(k-1)*_item_scale, 120)
	    equip_item:setOpacity(0)
		equip_item:runAction(cc.Sequence:create(cc.FadeOut:create(0.1),cc.FadeIn:create(0.5)) )
	    self.dropbg:addChild(equip_item)
                        
    end

    --装备展示
    if self.base then
	   self.base:removeFromParent()
	end	
	-- local sp=
    self.base=cc.Sprite:create()
    -- self.base:setContentSize(cc.size(sp:getContentSize().width,sp:getContentSize().height))
	self.base:setAnchorPoint(0.5,0.5)
	self.base:setPosition(self.bg:getContentSize().width*0.3 - 30,self.bg:getContentSize().height*0.3)
	self.bg:addChild(self.base)
	-- self.bottomLight = self:playAnim({
    --     imageName = "xia_",
    --     start = 0,
    --     count = 14,
    --     delaytime=0,
    --     x = self.base:getBoundingBox().width/2,
    --     y = self.base:getBoundingBox().height-18
	-- })
	self.base:setScale(0.8)
    -- self.bottomLight:setScale(1.9)
    -- self.base:addChild(self.bottomLight)
	local rank=self.staticItemData[tonumber(self.id)]["rank"]
	local equip_sp=cc.Sprite:create("res/image/equipCopies/equip_"..rank.."_"..self.staticItemData[tonumber(self.id)]["typeE"]..".png")--cc.Sprite:create("res/image/equipCopies/equip_zi.png")
	equip_sp:setOpacity(0)
	-- local updown = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(0,50)),)
	equip_sp:runAction(cc.Sequence:create(cc.FadeOut:create(0.1),cc.FadeIn:create(0.5)) )
	equip_sp:setAnchorPoint(0.5,0)                 
	equip_sp:setPosition(self.base:getContentSize().width/2,self.base:getContentSize().height/2+30+30)
	self.base:addChild(equip_sp)
	-- self.topLight= self:playAnim({
    --     imageName = "shang_",
    --     start = 0,
    --     count = 14,
    --     delaytime=0,
    --     x = self.base:getBoundingBox().width/2,
    --     y = self.base:getBoundingBox().height+50
    -- })
	-- self.topLight:setScale(1.9)
	self.topLight = sp.SkeletonAnimation:create( "res/image/equipCopies/shenbingge.json", "res/image/equipCopies/shenbingge.atlas", 1.0)
	self.topLight:setAnimation(0,"shenbingge",true)
	self.topLight:setPosition(self.base:getContentSize().width/2,equip_sp:getPositionY() + 120)
    self.base:addChild(self.topLight)

	self.tongguan=cc.Sprite:create("res/image/equipCopies/compies_over.png")
	self.tongguan:setPosition(self.topLight:getContentSize().width/2,self.topLight:getContentSize().height/2)
	-- self.tongguan:setScale(0.5)
	self.tongguan:setVisible(false)
	if self.state and self.state==1 then
		self.tongguan:setVisible(true)
	end
	self.topLight:addChild(self.tongguan)
	for i=1,tonumber(self.staticItemData[tonumber(self.id)]["rank"]-1) do
		local star=cc.Sprite:create("res/image/equipCopies/star.png")
		star:setScale(1.2)
		star:setAnchorPoint(0.5,0.5)
		-- star:setPosition(equip_bg:getContentSize().width/2,equip_bg:getContentSize().height*2/3)
		star:setPosition(-150,120+40*(i-1))
		self.base:addChild(star)
	end

	if self.sweep_label then
	   self.sweep_label:removeFromParent()
	end
	if self.attack_btn then
	   self.attack_btn:removeFromParent()
	   self.attack_btn = nil
	end
	if self._effect then
	   	self._effect:removeFromParent()
		self._effect = nil
	end
	-- 文字和按钮
	if tonumber( gameUser.getLevel() ) < self.staticItemData[tonumber(self.id)].quickfinsh then
    	-- 挑战
    	-- 征战文字
    	local transformStar = {
    		LANGUAGE_PROPERTIES[1],
    		LANGUAGE_PROPERTIES[2],
    		LANGUAGE_PROPERTIES[4],
    		LANGUAGE_PROPERTIES[7],
    		LANGUAGE_PROPERTIES[12],
    		LANGUAGE_PROPERTIES[18],
    	}
    	self.sweep_label = XTHD.createLabel({
    		text      = LANGUAGE_KEY_EQUIPCOPYSWEEPLEVEL( self.staticItemData[tonumber(self.id)].quickfinsh, transformStar[self.staticItemData[tonumber(self.id)].rank] ),
			fontSize  = 18,
			color     = cc.c3b( 255, 126, 0 ),
			anchor    = cc.p( 0.5, 0.5 ),
			pos       = cc.p( self.bg:getContentSize().width-280, 30 ),
			clickable = false,
		})
		self.bg:addChild(self.sweep_label)

		-- 挑战按钮
	    local _btn, _effect = XTHD.createFightBtn({
	    	par = self.bg,
	    	pos = cc.p(self.bg:getContentSize().width - 70, 100)
		})
	    self.attack_btn = _btn
	    self._effect = _effect
		self.attack_btn:setTouchBeganCallback(function()
			if self._effect then
				self._effect:setScale(0.9)
			end
		end)

		self.attack_btn:setTouchMovedCallback(function()
			if self._effect then
				self._effect:setScale(1)
			end
		end)

	    self.attack_btn:setTouchEndedCallback(function (  )
			if self._effect then
				self._effect:setScale(1)
			end
	   		if tonumber(self.state)==0 then
				LayerManager.addShieldLayout()
		  		local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):create(BattleType.EQUIP_PVE,self.id)
		  		fnMyPushScene(_layer)
		  	else 
		  		local tishipop=self:refreshPop()
		  		self.bg:addChild(tishipop,1)
	  	    end
	    end)
    else
    	-- 征战
    	-- 征战文字
    	self.sweep_label = XTHD.createLabel({
    		text      = LANGUAGE_KEY_EQUIPCOPYSWEEP[1],
			fontSize  = 18,
			color     = cc.c3b( 255, 126, 0 ),
			anchor    = cc.p( 0.5, 0.5 ),
			pos       = cc.p( self.bg:getContentSize().width-280, 30 ),
			clickable = false,
		})
		-- sweepLabel:setPosition( self.dropbg:convertToNodeSpace( cc.p( self.bg:getContentSize().width-280, 30 ) ) )
    	self.bg:addChild(self.sweep_label)
    	-- 征战按钮
	    self.attack_btn  = XTHDPushButton:createWithFile({
	        normalFile = "res/image/equipCopies/sweep_up.png",
	        selectedFile = "res/image/equipCopies/sweep_down.png",
	        musicFile = XTHD.resource.music.effect_btn_common,
	    })
	    self.attack_btn:setPosition(self.bg:getContentSize().width-70,50)
		self.bg:addChild(self.attack_btn)
		self.attack_btn:setScale(0.7)
	    self.attack_btn:setTouchEndedCallback(function (  )
	   		if tonumber(self.state)==0 then
				ClientHttp:httpSweepEquipEctype(self, function( data )
					self.state = 1
			    	-- 更新属性
			    	if data.property and #data.property > 0 then
		                for i=1, #data.property do
		                    local pro_data = string.split( data.property[i], ',' )
		                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
		                end
		            end
		            -- 更新背包
		            if data.bagItems and #data.bagItems > 0 then
		                for i=1, #data.bagItems do
		                    local item_data = data.bagItems[i]
	                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
		                end
		            end
		            local befSmeltPoint = gameUser.getSmeltPoint()
				    gameUser.setSmeltPoint(data.curSmelt)
				    gameUser.setTiliNow(data.tili)
				    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
				    self:createDropBg()
					-- 成功获取弹窗
                    local iconData = {}
                    for i, v in ipairs( data.addItems ) do
                    	local tmp = string.split( v, "," )
                    	iconData[#iconData + 1] = {
                    		rewardtype = 4,
                    		id = tonumber( tmp[1] ),
                    		num = tonumber( tmp[2] ),
                    	}
                    end
                    if tonumber( data.curSmelt ) - befSmeltPoint > 0 then
                        iconData[#iconData + 1] = {
                    		rewardtype = XTHD.resource.type.smeltPoint,
                    		num = tonumber( data.curSmelt ) - befSmeltPoint,
                    	}
                    end
					if data.addExp and data.addExp > 0 then
						iconData[#iconData + 1] = {
                    		rewardtype = 1,
                    		num = tonumber( data.addExp ),
                    	}
					end
			    	ShowRewardNode:create( iconData )
				end, {ectypeId = self.id})
		  	else 
		  		local tishipop = self:refreshPop()
	  		 	self.bg:addChild(tishipop,1)
	  	    end
	    end)
    end
end
--提示刷新
function ShenBingGeLayer:refreshPop( )
	print("进入页面")
    local popLayer = XTHDDialog:create()--XTHDPopLayer:create()
    --按钮取消
        local bg_sp = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png" )
    	bg_sp:setContentSize(375,228)
        bg_sp:setCascadeOpacityEnabled(true)
        bg_sp:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        popLayer:addChild(bg_sp,2)
        local txt_content  = nil

        if not contentNode then 
            txt_content = XTHDLabel:create(LANGUAGE_FORMAT_TIPS10(1+1*(self.data.maxRefreshSum-self.surplusRefreshSum)),18)----"关卡已通关,是否花费""点体力刷新？",18)
            txt_content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
            txt_content:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
            txt_content:setColor(XTHD.resource.color.gray_desc)
            --解决文字过短居中的问题
            if tonumber(txt_content:getContentSize().width)<306 then
                txt_content:setDimensions(tonumber(txt_content:getContentSize().width), 120)
            else
                txt_content:setDimensions(306, 120)
            end
        else 
            txt_content = contentNode
        end
        txt_content:setPosition(bg_sp:getContentSize().width/2,bg_sp:getContentSize().height/2 + 30)
        bg_sp:addChild(txt_content)
        local btn_left = XTHD.createCommonButton({
            btnColor = "write_1",
			text = LANGUAGE_KEY_CANCEL,
			isScrollView = false,
            fontSize = 22,
            btnSize = cc.size(130, 51),
            pos = cc.p(100 + 5,50),
            endCallback = function()
                popLayer:removeFromParent()
            end
		})
		btn_left:setScale(0.8)
        btn_left:setCascadeOpacityEnabled(true)
        btn_left:setOpacity(255)
        bg_sp:addChild(btn_left)
        local btn_right = XTHD.createCommonButton({
			btnColor = "write",
			text = LANGUAGE_KEY_SURE,
			isScrollView = false,
            btnSize = cc.size(130, 51),
            fontSize = 22,
            pos = cc.p(bg_sp:getContentSize().width-100-5,btn_left:getPositionY()),
            endCallback = function()
	            self:doRefreshEquipEctypes(false)
           		popLayer:removeFromParent()
           	end,
		   })
		   btn_right:setScale(0.8)
        btn_right:setCascadeOpacityEnabled(true)
        btn_right:setOpacity(255)
        bg_sp:addChild(btn_right)
	return popLayer
end

function ShenBingGeLayer:doRefreshEquipEctypes( isBeast )
	ClientHttp:httpRefreshEquipEctypes(self, function ( sData )
		self.id = sData["ectypes"][1]["ectypeId"]
		self.state = sData["ectypes"][1]["state"]
		self.limit_num:setString(self.staticItemData[tonumber(self.id)]["herolimit"])-----"上阵英雄数量 : "..self.staticItemData[tonumber(self.id)]["herolimit"])
		if isBeast then
			self.refresh_num3:setString(tostring(50+25*(self.data.maxBestRefreshSum-sData.surplusBestRefreshSum)))
			self.maxrefresh_num:setString(tostring(sData.surplusBestRefreshSum.."/"..self.data.maxBestRefreshSum))-------"刷新次数 : "..tostring(refreshBest_data.surplusBestRefreshSum.."/"..data.maxBestRefreshSum)) 	
			gameUser.setIngot(sData.ingot)
		else
        	self.refresh_num2:setString(tostring(1+1*(self.data.maxRefreshSum-sData.surplusRefreshSum)))
	    	self.surplusRefreshSum = sData.surplusRefreshSum
        	self.refresh_count:setString(tostring(sData.surplusRefreshSum.."/"..self.data.maxRefreshSum))-----"刷新次数 : "..tostring(refresh_data.surplusRefreshSum.."/"..data.maxRefreshSum)) 
		    gameUser.setTiliNow(sData.tili)
		end
		self:createDropBg()
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
	end, isBeast)
end

--当创建的是银两、翡翠等东西时，使用该方法
function ShenBingGeLayer:makeDropItem(id)
	local num=self.staticItemData[tonumber(self.id)]["reword"] or 1
    return ItemNode:createWithParams({
            _type_ = XTHD.resource.type.smeltPoint,
            isShowCount = true,
            count =num
        })
end
--创建掉落的装备，名字
function ShenBingGeLayer:makeDropEquip(id)
    local item_info = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=id})
    local equip_box_bg = ItemNode:createWithParams({
            _type_ = 4,
            itemId = item_info["itemid"],
        })
    return equip_box_bg
end

function ShenBingGeLayer:playAnim(data,isRepeat)--若isRepeat不为空则重复播放
    local imageName = data.imageName
    local x = data.x
    local y = data.y
    local count = data.count
    local start = data.start
    local delaytime = data.delaytime
    local scale = data.scale
    if delaytime == nil then
        delaytime = 0
    end
    local getFrames = function()
        local frames = {}
        for i = start,count do
            local frame = nil
            if i < 10 then
            	frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(imageName.."0"..i..".png")
            else
            	frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(imageName..i..".png")
            end
            frames[i] = frame
        end
        return frames
    end
    local frames = getFrames()
    if frames then
        local sprite = cc.Sprite:createWithSpriteFrame(frames[1])
        if sprite == nil then
            return
        end
        if scale then
            sprite:setScale(scale)
        end
        sprite:setPosition(x,y)
        local animation = self:newAnimation(frames, 0.05)
        local animate = cc.Animate:create(animation)
        if isRepeat then
            sprite:runAction(cc.Sequence:create(animate,cc.RemoveSelf:create()))
            return sprite
        end
        sprite:runAction(cc.RepeatForever:create(cc.Sequence:create(animate,
            cc.DelayTime:create(delaytime)
        )))
        return sprite
    end
end

function ShenBingGeLayer:newAnimation(frames, time)
    local count = #frames
    local array = {}
    for i = 1, count do
        table.insert(array, frames[i])
    end
    time = time or 1.0 / count
    -- print(array)
    return cc.Animation:createWithSpriteFrames(array, time)
end

function ShenBingGeLayer:create( par )
	local function _create( data )
        local _layer = ShenBingGeLayer.new(data)
        LayerManager.addLayout(_layer)
    end
	ClientHttp:httpEquipEctypes(par, _create)
end

function ShenBingGeLayer:addGuide( )
	YinDaoMarg:getInstance():addGuide({index = 4,parent = self},19)
    YinDaoMarg:getInstance():doNextGuide()
end

return ShenBingGeLayer