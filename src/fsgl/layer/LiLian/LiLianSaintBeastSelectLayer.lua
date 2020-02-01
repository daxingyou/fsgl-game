--Created By Liuluyang 2015年08月31日
--神器遗址界面
local LiLianSaintBeastSelectLayer = class("LiLianSaintBeastSelectLayer",function ()
	return XTHD.createBasePageLayer({bg = "res/image/plugin/saint_beast/saint_beast_bg.png"})
end)

function LiLianSaintBeastSelectLayer:ctor(data)
	self:initUI()
	self.clearSum = data.clearSum > 10 and 10 or data.clearSum
	self:refreshLayer(self:dataAnalyzer(data))
end

function LiLianSaintBeastSelectLayer:onEnter()
	if self.saintBeastNum then
		self.saintBeastNum:setString(gameUser.getSaintStone())
	end
	-------引导 
	YinDaoMarg:getInstance():addGuide({parent = self,index = 4},18)----剧情	
    YinDaoMarg:getInstance():doNextGuide() 
end

function LiLianSaintBeastSelectLayer:onCleanup()
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_CAMP_MAINLAYER})
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/plugin/saint_beast/saint_beast_bg.png")
    textureCache:removeTextureForKey("res/image/plugin/saint_beast/top_desc.png")
    textureCache:removeTextureForKey("res/image/plugin/saint_beast/mode_dis.png")
    textureCache:removeTextureForKey("res/image/plugin/saint_beast/select_shine.png")
    for i=1, 4 do
	    textureCache:removeTextureForKey("res/image/plugin/saint_beast/saint_beast_bg_" .. i .. ".png")
	    textureCache:removeTextureForKey("res/image/plugin/saint_beast/act_" .. i .. ".png")
	    textureCache:removeTextureForKey("res/image/plugin/saint_beast/act_desc_" .. i .. ".png")
	    textureCache:removeTextureForKey("res/image/plugin/saint_beast/mode_" .. i .. ".png")
	    textureCache:removeTextureForKey("res/image/plugin/saint_beast/mode_sp_" .. i .. ".png")
	    textureCache:removeTextureForKey("res/image/plugin/saint_beast/mode_sp_dis" .. i .. ".png")
    end
end

function LiLianSaintBeastSelectLayer:initUI()
	local _size = self:getContentSize()
	local _layHeight = _size.height - self.topBarHeight
	local topDesc = cc.Sprite:create("res/image/plugin/saint_beast/top_desc.png")
	topDesc:setAnchorPoint(0.5,1)
	topDesc:setPosition(self:getBoundingBox().width/2,_layHeight -8)
	self:addChild(topDesc)
	--神石数量
	local saintBeastStone = cc.Sprite:create("res/image/plugin/saint_beast/stone_num.png")
	saintBeastStone:setAnchorPoint(0,0.5)
	saintBeastStone:setPosition(20,topDesc:getPositionY()-topDesc:getBoundingBox().height*0.7)
	self:addChild(saintBeastStone)

	local saintBeastIcon = XTHD.createHeaderIcon(XTHD.resource.type.stone)
	saintBeastIcon:setAnchorPoint(0,0.5)
	saintBeastIcon:setPosition(saintBeastStone:getPositionX()+saintBeastStone:getBoundingBox().width,saintBeastStone:getPositionY())
	self:addChild(saintBeastIcon)

	self.saintBeastNum = getCommonWhiteBMFontLabel(gameUser.getSaintStone())
	self.saintBeastNum:setAnchorPoint(0,0.5)
	self.saintBeastNum:setPosition(saintBeastIcon:getPositionX()+saintBeastIcon:getBoundingBox().width,saintBeastIcon:getPositionY()-7)
	self:addChild(self.saintBeastNum)

	local saintBeastChange = XTHDPushButton:createWithParams({
		normalFile = "res/image/plugin/saint_beast/change_normal.png",
		selectedFile = "res/image/plugin/saint_beast/change_selected.png",
		musicFile = XTHD.resource.music.effect_btn_common,
	})
	saintBeastChange:setAnchorPoint(1,0.5)
	saintBeastChange:setPosition(self:getBoundingBox().width-20,topDesc:getPositionY()-topDesc:getBoundingBox().height*0.95)
	self:addChild(saintBeastChange)

	saintBeastChange:setTouchEndedCallback(function ()
		local a,b = isTheFunctionAvailable(35)
		if a == false then
			XTHDTOAST("未通关第五章！")
			return
		end
		local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("Artifact")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
	end)

	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=31})
            self:addChild(StoredValue,20)
        end,
	})
	self:addChild(help_btn)
	help_btn:setPosition(saintBeastChange:getPositionX() - help_btn:getContentSize().width/2 -saintBeastChange:getContentSize().width - 20,saintBeastChange:getPositionY())
	help_btn:setZOrder(1)

	topDesc:setPosition(
		((saintBeastChange:getPositionX()-saintBeastChange:getBoundingBox().width)-(self.saintBeastNum:getPositionX()+self.saintBeastNum:getBoundingBox().width))/2+(self.saintBeastNum:getPositionX()+self.saintBeastNum:getBoundingBox().width),
		_layHeight - 8
	)

	local VecPos = (topDesc:getPositionY()-topDesc:getBoundingBox().height-187*2)/3
	local HorPos = (self:getBoundingBox().width-428*2)/3

	local bg_1 = XTHDPushButton:createWithParams({
		musicFile = XTHD.resource.music.effect_btn_common,
		normalFile = "res/image/plugin/saint_beast/saint_beast_bg_1.png",
		selectedFile = "res/image/plugin/saint_beast/saint_beast_bg_1.png",
		touchScale = 0.9,
		touchSize = cc.size(428,187)
	})
	--cc.Sprite:create("res/image/plugin/saint_beast/saint_beast_bg_1.png")
	-- bg_1:setAnchorPoint(0,1)
	bg_1:setPosition(HorPos+bg_1:getBoundingBox().width/2,topDesc:getPositionY()-topDesc:getBoundingBox().height-VecPos-bg_1:getBoundingBox().height/2)
	self:addChild(bg_1)

	local bg_2 = XTHDPushButton:createWithParams({
		musicFile = XTHD.resource.music.effect_btn_common,
		-- normalNode = XTHD.setGray(cc.Sprite:create("res/image/plugin/saint_beast/saint_beast_bg_2.png"),true),
		normalFile = "res/image/plugin/saint_beast/saint_beast_bg_2.png",
		selectedFile = "res/image/plugin/saint_beast/saint_beast_bg_2.png",
		touchScale = 0.9,
		touchSize = cc.size(428,187)
	})
	--cc.Sprite:create("res/image/plugin/saint_beast/saint_beast_bg_2.png")
	-- bg_2:setAnchorPoint(1,1)
	bg_2:setPosition(self:getBoundingBox().width-HorPos-bg_2:getBoundingBox().width/2,topDesc:getPositionY()-topDesc:getBoundingBox().height-VecPos-bg_2:getBoundingBox().height/2)
	self:addChild(bg_2)

	local bg_3 = XTHDPushButton:createWithParams({
		musicFile = XTHD.resource.music.effect_btn_common,
		normalFile = "res/image/plugin/saint_beast/saint_beast_bg_3.png",
		selectedFile = "res/image/plugin/saint_beast/saint_beast_bg_3.png",
		touchScale = 0.9,
		touchSize = cc.size(428,187)
	})
	--cc.Sprite:create("res/image/plugin/saint_beast/saint_beast_bg_3.png")
	-- bg_3:setAnchorPoint(0,0)
	bg_3:setPosition(HorPos+bg_3:getBoundingBox().width/2,VecPos+bg_3:getBoundingBox().height/2)
	self:addChild(bg_3)

	local bg_4 = XTHDPushButton:createWithParams({
		musicFile = XTHD.resource.music.effect_btn_common,
		normalFile = "res/image/plugin/saint_beast/saint_beast_bg_4.png",
		selectedFile = "res/image/plugin/saint_beast/saint_beast_bg_4.png",
		touchScale = 0.9,
		touchSize = cc.size(428,187)
	})
	--cc.Sprite:create("res/image/plugin/saint_beast/saint_beast_bg_4.png")
	-- bg_4:setAnchorPoint(1,0)
	bg_4:setPosition(self:getBoundingBox().width-HorPos-bg_4:getBoundingBox().width/2,VecPos+bg_4:getBoundingBox().height/2)
	self:addChild(bg_4)

	self.bg_1 = bg_1
	self.bg_2 = bg_2
	self.bg_3 = bg_3
	self.bg_4 = bg_4

	local artifactEnum = {
		[1] = 30,
		[2] = 31,
		[3] = 32,
		[4] = 33,
	}
	for i=1,4 do
		local nowBg = self["bg_"..i]
		local artifactIcon = cc.Sprite:create("res/image/plugin/saint_beast/act_"..i..".png")
		artifactIcon:setPosition(93,105)
		artifactIcon:setScale(0.9)
		-- artifactIcon:setScale()
		nowBg:addChild(artifactIcon)

		local actDesc = cc.Sprite:create("res/image/plugin/saint_beast/act_desc_"..i..".png")
		actDesc:setAnchorPoint(1,1)
		actDesc:setPosition(nowBg:getBoundingBox().width-30,nowBg:getBoundingBox().height-20)
		nowBg:addChild(actDesc)

		
	end
	
	

end

function LiLianSaintBeastSelectLayer:refreshData()
	XTHDHttp:requestAsyncInGameWithParams({
        modules="godBeastEctype?",
        -- params = {method="godBeastEctype?"},
        successCallback = function(godBeastEctype)
            if tonumber(godBeastEctype.result) == 0 then
            	self:refreshLayer(self:dataAnalyzer(godBeastEctype))
            else
                XTHDTOAST(godBeastEctype.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败！")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败！")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function LiLianSaintBeastSelectLayer:refreshLayer(data)
	local topLay = self:getChildByName("TopBarLayer1")
	if topLay then
		topLay:refreshData()
	end
	if self.saintBeastNum then
		self.saintBeastNum:setString(gameUser.getSaintStone())
	end
	for i=1,#data do
		local nowBg = self["bg_"..i]
		XTHD.setGray(nowBg:getStateNormal(),false)
		XTHD.setGray(nowBg:getStateSelected(),false)
		local allChild = nowBg:getChildren()
		for i=1,#allChild do
			if allChild[i]:getName() == "status" then
				allChild[i]:removeFromParent()
			else
				XTHD.setGray(allChild[i],false)
			end
		end

		if data[i]._type == 1 then
			local lockSp = cc.Sprite:create("res/image/plugin/saint_beast/lock_str_"..i..".png")
			lockSp:setAnchorPoint(1,0)
			lockSp:setPosition(nowBg:getBoundingBox().width-30,20)
			lockSp:setName("status")
			nowBg:addChild(lockSp)
			XTHD.setGray(nowBg:getStateNormal(),true)
			XTHD.setGray(nowBg:getStateSelected(),true)
			local allChild = nowBg:getChildren()
			for i=1,#allChild do
				XTHD.setGray(allChild[i],true)
			end

			nowBg:setTouchEndedCallback(function ()
				local ModeList = requires("src/fsgl/layer/LiLian/LiLianSaintBeastModeLayer.lua"):create(self.data,data[i]._type,i,function ()
					self:refreshData()
				end)
				self:addChild(ModeList, 1)
				ModeList:show()
			end)
		elseif data[i]._type == 2 then
			local challageable = cc.Sprite:create("res/image/plugin/saint_beast/challage_able.png")
			challageable:setAnchorPoint(1,0)
			challageable:setPosition(nowBg:getBoundingBox().width-40,20)
			challageable:setName("status")
			nowBg:addChild(challageable)

			nowBg:setTouchEndedCallback(function ()
				local ModeList = requires("src/fsgl/layer/LiLian/LiLianSaintBeastModeLayer.lua"):create(self.data,data[i]._type,i,function ()
					self:refreshData()
				end)
				self:addChild(ModeList, 1)
				ModeList:show()
			end)
		elseif data[i]._type == 3 then
			local challageable = cc.Sprite:create("res/image/plugin/saint_beast/challage_ing.png")
			challageable:setAnchorPoint(1,0)
			challageable:setPosition(nowBg:getBoundingBox().width-40,20)
			challageable:setName("status")
			nowBg:addChild(challageable)
			nowBg:setTouchEndedCallback(function ()
				XTHDHttp:requestAsyncInGameWithParams({
	                modules="chooseBeastEctype?",
	                params = {ectypeType=data[i].id},
	                successCallback = function(net)
	                if tonumber(net.result) == 0 then
	                	local LiLianSaintBeastChapterLayer = requires("src/fsgl/layer/LiLian/LiLianSaintBeastChapterLayer.lua"):create(net,data[i].id,function ()
	                		self:refreshData()
	                	end)
	                	LayerManager.addLayout(LiLianSaintBeastChapterLayer)
	                	-- self:refreshData()
	                else
	                    XTHDTOAST(net.msg)
	                end
	                end,--成功回调
	                failedCallback = function()
	                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败！")
	                end,--失败回调
	                targetNeedsToRetain = self,--需要保存引用的目标
	                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	            })
			end)
		elseif data[i]._type == 4 then
			local cdSp = cc.Sprite:create("res/image/plugin/saint_beast/cd_sp.png")
			cdSp:setAnchorPoint(1,0)
			cdSp:setPosition(nowBg:getBoundingBox().width-40,20)
			cdSp:setName("status")
			nowBg:addChild(cdSp)

			local cdNum = getCommonWhiteBMFontLabel(getCdStringWithNumber(data[i].time,{
	            h = ":",
	            m = ":",
	            s = "",
	        }))
			cdNum:setAnchorPoint(1,0.5)
			cdNum:setPosition(cdSp:getPositionX()-cdSp:getBoundingBox().width,cdSp:getPositionY()+cdSp:getBoundingBox().height/2-7)
			cdNum.cd = data[i].time
			nowBg:addChild(cdNum)
			self:doCount(cdNum)
			nowBg:setTouchEndedCallback(function ()
				local pNum = math.ceil((cdNum.cd)/60)*(1+self.clearSum)
				local BuyConfirm = XTHDConfirmDialog:createWithParams({
	                msg = LANGUAGE_FORMAT_TIPS38(pNum..LANGUAGE_KEY_COIN),-------"当前副本战斗正在冷却中，是否消耗\n"..pNum..LANGUAGE_KEY_COIN.."清空冷却时间？",
	                rightCallback = function ()
	                    XTHDHttp:requestAsyncInGameWithParams({
	                        modules="clearBeastCd?",
	                        params = {ectypeType=data[i].id},
	                        successCallback = function(data)
	                        if tonumber(data.result) == 0 then
	                        	local _nowIngot = gameUser.getIngot() - pNum
	                        	_nowIngot = _nowIngot > 0 and _nowIngot or 0
	                        	gameUser.setIngot(_nowIngot)
	                            self.clearSum = data.clearSum > 10 and 10 or data.clearSum
	                            cdNum:stopAllActions()
	                            cdNum:removeFromParent()
	                            self:refreshData()
	                        else
	                            XTHDTOAST(data.msg)
	                        end
	                        end,--成功回调
	                        failedCallback = function()
	                            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败！")
	                        end,--失败回调
	                        targetNeedsToRetain = self,--需要保存引用的目标
	                        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	                    })
	                end
	            })
				self:addChild(BuyConfirm)
			end)
		end
	end
end

function LiLianSaintBeastSelectLayer:doCount(node)
	node:stopAllActions()
    node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function ()
        if node.cd == 0 then
        	self:refreshData()
        end
        node:setString(getCdStringWithNumber(node.cd,{
            h = ":",
            m = ":",
            s = "",
        }))
        node.cd = node.cd - 1
    end),cc.DelayTime:create(1))))
end

function LiLianSaintBeastSelectLayer:dataAnalyzer(data)
	self.data = data
	local list = data.ectypes
	local tmpList = {} --1未开启 2可挑战 3挑战中 4CD
	local pState = 1
	for i=1,4 do
		pState = 1
		for j=1,4 do
			local nowData = list[(i-1)*4+j]
			if nowData.times ~= 0 then
				pState = 4
				tmpList[i] = {_type = 4,time = nowData.times,id = (i-1)*4+j}
				break
			end
			if nowData.isCost == 0 then
				pState = 3
				tmpList[i] = {_type = 3,id = (i-1)*4+j}
				break
			end
			if nowData.state == 1 then
				pState = 2
			end
		end
		if pState == 2 then
			tmpList[i] = {_type = 2} 
		elseif pState == 1 then
			tmpList[i] = {_type = 1}
		end
	end
	return tmpList
end

function LiLianSaintBeastSelectLayer:create(data)
	return LiLianSaintBeastSelectLayer.new(data)
end

return LiLianSaintBeastSelectLayer