--鲜花商店
--Created By Liuluyang 2015年04月30日
local WanBaoGe = class("WanBaoGe",function ()  
    return XTHD.createBasePageLayer()
end)

function WanBaoGe:ctor(_type,_data,callback)
    self.callback = callback
    self._shopType = _type
    self._BuyData = _data
    self:initUI()
end

function WanBaoGe:onCleanup()
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
    RedPointManage:reFreshDynamicItemData()
    if self.callback and type(self.callback) == "function" then
        self.callback(self._BuyData.flower)
    end

    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/03.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/04.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/05.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/06.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/08.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/10.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/11.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/12.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/14.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/15.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/selected_bg.png")
    textureCache:removeTextureForKey("res/image/plugin/weaponshop/weapon_sold.png")
    -- self.tuskSpine:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
end

function WanBaoGe:initUI()
    local _bgSp = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    self:addChild(_bgSp)
    self._bgSp = _bgSp
	
	local title = "res/image/public/wanbaoge_title.png"
	XTHD.createNodeDecoration(self._bgSp,title)

    --hmbg
    local hd_bg = cc.Sprite:create("res/image/plugin/weaponshop/hd_bg.png")
    hd_bg:setPosition(0,10)
    hd_bg:setAnchorPoint(0,0)
    self._bgSp:addChild(hd_bg)
    hd_bg:setScale(0.8)
    self.hd_bg = hd_bg
    self.hd_bg:setVisible(false)
    

    local _hmSp = cc.Sprite:create()
    _bgSp:addChild(_hmSp)
    _hmSp:setAnchorPoint(cc.p(1, 0.5))
    _hmSp:setPosition(cc.p(_bgSp:getContentSize().width*0.5 - 150, _bgSp:getContentSize().height*0.5))
    self._hmSp = _hmSp

    --左右箭头
    local left_arrow = XTHD.createButton({
        normalFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
        touchSize = cc.size(70,70),
        anchor = cc.p(0, 0.5)
    })
    left_arrow:setPosition(32, _bgSp:getContentSize().height*0.5)
    _bgSp:addChild(left_arrow, 1)
	left_arrow:setVisible(false)

    local right_arrow = XTHD.createButton({
        normalFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
        touchSize = cc.size(70,70),
        anchor = cc.p(1, 0.5)
    })
    right_arrow:setPosition(_bgSp:getContentSize().width - 32, _bgSp:getContentSize().height*0.5)
    _bgSp:addChild(right_arrow, 1)
	right_arrow:setVisible(false)

    local leftMove_1 = cc.MoveBy:create(0.5, cc.p(-5, 0))
    local leftMove_2 = cc.MoveBy:create(0.5, cc.p(5, 0))
    local rightMove_1 = cc.MoveBy:create(0.5, cc.p(5, 0))
    local rightMove_2 = cc.MoveBy:create(0.5, cc.p(-5, 0))
    left_arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(leftMove_1, leftMove_2)))
    right_arrow:runAction(cc.RepeatForever:create(cc.Sequence:create(rightMove_1, rightMove_2)))

    left_arrow:setTouchEndedCallback(function (  )
        local pNum = self._shopType == 1 and 3 or 1
        self:switchLayer(pNum)
    end)

    right_arrow:setTouchEndedCallback(function (  )
        local pNum = self._shopType == 1 and 3 or 1
        self:switchLayer(pNum)
    end)

    self._left_arrow = left_arrow
    self._right_arrow = right_arrow

    -- self._left_arrow:setVisible(false)
    -- self._right_arrow:setVisible(false)
     
    
    self:initShop()
end

function WanBaoGe:initShop( )
    -- local _notic_bg = self:getChildByName("_notic_bg")
    local _bgSp = self._bgSp
    local _hmSp = self._hmSp
    
    local _bgFile = "res/image/common/layer_bottomBg.png"
    local _hmFile = "res/image/plugin/weaponshop/15.png"
    local _falseFile = "res/image/plugin/weaponshop/13.png"
	self._bgSp._title:initWithFile("res/image/public/wanbaoge_title.png")
    
    if self._shopType == 3 then
        _bgFile = "res/image/common/layer_bottomBg.png"
        _hmFile = "res/image/plugin/weaponshop/10.png"
        _falseFile = "res/image/plugin/weaponshop/09.png"
		self._bgSp._title:initWithFile("res/image/public/xianhuanshop_title.png")
        -- self._left_arrow:setVisible(true)
        -- self._right_arrow:setVisible(false)
    end
    _bgSp:setTexture(_bgFile)
    _bgSp:setPosition(self:getBoundingBox().width*0.5,
        self:getBoundingBox().height*0.5 - self.topBarHeight/2)

    if self.refreshLayer then
        self.refreshLayer:removeFromParent()
        self.refreshLayer = nil
    end

    local falseBg = ccui.Scale9Sprite:create(_falseFile)
    falseBg:setContentSize(cc.size(650, 370))
    falseBg:setAnchorPoint(0, 0)
    falseBg:setPosition(cc.p(_bgSp:getContentSize().width*0.5 - 240, 30))
    _bgSp:addChild(falseBg)
    self.refreshLayer = falseBg

    _hmSp:setTexture(_hmFile)
    _hmSp:setScale(0.6)
    if self._shopType == 3 then
        _hmSp:setPosition(cc.p(_bgSp:getContentSize().width*0.5 - 210, _bgSp:getContentSize().height*0.5))
        _hmSp:setScale(0.85)
        self.hd_bg:setVisible(true)
    elseif self._shopType == 1 then
        _hmSp:setPosition(cc.p(_bgSp:getContentSize().width*0.5 - 155, _bgSp:getContentSize().height*0.5))
        self.hd_bg:setVisible(false)
    end
    -- _hmSp:setPosition(cc.p(falseBg:getPositionX() + 40, _bgSp:getContentSize().height*0.5))

    self:createBuy(self._BuyData)
end

function WanBaoGe:switchLayer(num)
    local _modules = num == 1 and "weaponWindow?" or "flowerWindow?"
    XTHDHttp:requestAsyncInGameWithParams({
        modules = _modules,
        successCallback = function(weaponWindow)
            if tonumber(weaponWindow.result) == 0 then
                self._shopType = num
				if self._shopType == 1 then
					weaponWindow.items =self:SortList(weaponWindow.items)
				elseif self._shopType == 3 then
					weaponWindow.items =self:FlowerSortList(weaponWindow.items)
				end
                self._BuyData = weaponWindow
                self:initShop()
            else
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)---------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function WanBaoGe:noItemsDialog(_itemid)
	local _dialog = XTHDConfirmDialog:createWithParams({
		msg = LANGUAGE_KEY_HERO_TEXT.noItemsToGetTextXc
		,rightCallback = function()
		    local popLayer = requires("src/fsgl/layer/YingXiong/BuyExpByIngotPopLayer1.lua")
            self.isWBG = true
		    popLayer= popLayer:create(_itemid, self)
		    popLayer:setName("BuyExpPop")
		    self:addChild(popLayer)
		end
	})
	self:addChild(_dialog)
end

function WanBaoGe:refreshBuyLabel()
    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2303}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2303}).count or 0
    end

    self.refreshConsume:setString("1/"..current_num)
end

function WanBaoGe:createBuy(data)
    self.refreshLayer:removeAllChildren()
    -- if not self.CountDown then
    self.CountDown = tonumber(data.time+1)
    self:stopAllActions()
    self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        self.CountDown = self.CountDown - 1
        if self.CountDownLabel and self.CountDown ~= 0 then
            self.CountDownLabel:setString(getCdStringWithNumber(self.CountDown,{h=":"}))
        end
        if self.CountDown == 0 then
            if self:getChildByName("WanBaoGeDescPop") then
                self:getChildByName("WanBaoGeDescPop"):hide()
            end
            local _modules = self._shopType == 1 and "weaponWindow?" or "flowerWindow?"
            XTHDHttp:requestAsyncInGameWithParams({
                modules = _modules,
                successCallback = function(data)
                if tonumber(data.result) == 0 then
					if self._shopType == 1 then
						data.items = self:SortList(data.items)
					elseif self._shopType == 1 then
						data.items = self:FlowerSortList(data.items)
					end
                    self._BuyData = data
                    self:createBuy(data)
                else
                    XTHDTOAST(data.msg)
                end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)--------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
        end
        -- print(getCdStringWithNumber(self.CountDown,{h=":"}))
    end))))
    -- end
    -- if not self.BuyDB then
    --     self.BuyDB = self._shopType == 1 and gameData.getDataFromCSV("WanbaogeStore") or gameData.getDataFromCSV("FlowerMall")
    -- end

    local freshLayer = self.refreshLayer
    local bgwidth = freshLayer:getContentSize().width
    local bgheight = freshLayer:getContentSize().height

    if self._shopType == 1 then
        local tuskDialog = cc.Sprite:create("res/image/plugin/weaponshop/12.png")
        tuskDialog:setAnchorPoint(0, 0)
        tuskDialog:setPosition(cc.p(115, bgheight))
        freshLayer:addChild(tuskDialog)
        tuskDialog:setScale(0.8)
        --欢迎光临
        local tuskDialog1_1 = cc.Sprite:create("res/image/plugin/weaponshop/12_1.png")
        tuskDialog1_1:setPosition(cc.p(50,bgheight+tuskDialog:getContentSize().height+15))
        tuskDialog1_1:setScale(0.8)
        freshLayer:addChild(tuskDialog1_1)
        --万宝阁下面的背景
        local wb_bg = cc.Sprite:create("res/image/plugin/weaponshop/wb_bg.png")
        wb_bg:setPosition(cc.p(30+tuskDialog1_1:getContentSize().width,bgheight+tuskDialog:getContentSize().height+15))
        wb_bg:setScale(0.7)
        freshLayer:addChild(wb_bg)
        --万宝阁
        local tuskDialog1_2 = cc.Sprite:create("res/image/plugin/weaponshop/12_2.png")
        tuskDialog1_2:setPosition(cc.p(30+tuskDialog1_1:getContentSize().width,bgheight+tuskDialog:getContentSize().height+15))
        tuskDialog1_2:setScale(0.9)
        freshLayer:addChild(tuskDialog1_2)

        local flowBg = ccui.Scale9Sprite:create("res/image/friends/input_bg.png")
        flowBg:setContentSize(140,40)
        flowBg:setAnchorPoint(0, 0.5)
        flowBg:setPosition(-flowBg:getContentSize().width, 23)
        tuskDialog:addChild(flowBg)
        
        local flowerIcon = XTHD.createSprite(IMAGE_KEY_HEADER_PSYCHICSTONE)
        flowerIcon:setAnchorPoint(0, 0.5)
        flowerIcon:setPosition(5, flowBg:getBoundingBox().height*0.5)
        flowBg:addChild(flowerIcon)

        local _data = DBTableItem.getData(gameUser.getUserId(), {itemid = 2302})
        local pNum = tonumber(_data.count) or 0
        local flowerTTF = getCommonWhiteBMFontLabel(pNum)
        flowerTTF:setAnchorPoint(0,0.5)
        flowerTTF:setPosition(flowerIcon:getPositionX()+flowerIcon:getBoundingBox().width+25,flowerIcon:getPositionY()-6)
        flowBg:addChild(flowerTTF)
    elseif self._shopType == 3 then
        --今日可
        local jinri = cc.Sprite:create("res/image/plugin/weaponshop/05_2.png")
        jinri:setAnchorPoint(0.5, 0)
        jinri:setPosition(cc.p(50, bgheight + 40))
        freshLayer:addChild(jinri)
        jinri:setScale(0.8)
        --购买
        local tuskDialog = cc.Sprite:create("res/image/plugin/weaponshop/05.png")
        tuskDialog:setAnchorPoint(0.5, 0)
        tuskDialog:setPosition(cc.p(15+jinri:getContentSize().width, bgheight + 40))
        freshLayer:addChild(tuskDialog)
        tuskDialog:setScale(0.8)
        local pTime = tonumber(data.count) or 0
		local numArr = NumToCharArray(pTime)
--		print("-----------------------")
--		print_r(numArr)
        local pW = 0
        local function createNum( _num )
            if not _num or _num < 0 or _num > 9 then
                return
            end
            local numSp = cc.Sprite:create("res/image/plugin/weaponshop/num_" .. tostring(_num) .. ".png")
            if numSp then
                numSp:setAnchorPoint(0, 0.5)
                numSp:setPosition(cc.p(tuskDialog:getContentSize().width + pW, tuskDialog:getContentSize().height * 0.5))
                tuskDialog:addChild(numSp)
                pW = pW + numSp:getContentSize().width
            end
        end
		for i = 1,#numArr do
			createNum(tonumber(numArr[i]))
		end

        local tuskDialog2 = cc.Sprite:create("res/image/plugin/weaponshop/06.png")
        tuskDialog2:setAnchorPoint(0, 0)
        tuskDialog2:setPosition(cc.p(tuskDialog:getContentSize().width + pW, 0))
        tuskDialog:addChild(tuskDialog2)
        tuskDialog2:setScale(0.9)
        pW = pW + tuskDialog2:getContentSize().width

        local tuskDialog3 = cc.Sprite:create("res/image/plugin/weaponshop/08.png")
        tuskDialog3:setAnchorPoint(0, 1)
        tuskDialog3:setPosition(cc.p(tuskDialog:getContentSize().width+10, 5))
        tuskDialog:addChild(tuskDialog3)
        -- tuskDialog3:setScale(0.9)

        local flowBg = ccui.Scale9Sprite:create("res/image/friends/input_bg.png")
        flowBg:setAnchorPoint(1, 0)
        flowBg:setPosition(tuskDialog3:getPositionX() - 7, tuskDialog3:getPositionY() - tuskDialog3:getContentSize().height+3)
        flowBg:setContentSize(150,40)
        -- flowBg:setScale(0.8)
        tuskDialog:addChild(flowBg)
        
        local flowerIcon = XTHD.createSprite(IMAGE_KEY_HEADER_FLOWER)
        flowerIcon:setAnchorPoint(0, 0.5)
        flowerIcon:setPosition(-10, flowBg:getBoundingBox().height*0.5)
        flowBg:addChild(flowerIcon)

        local pNum = tonumber(data.flower) or 0
        local flowerTTF = getCommonWhiteBMFontLabel(pNum)
        flowerTTF:setAnchorPoint(0,0.5)
        flowerTTF:setPosition(flowerIcon:getPositionX()+flowerIcon:getBoundingBox().width,flowerIcon:getPositionY()-6)
        flowBg:addChild(flowerTTF)
    end

    local refreshBg = ccui.Scale9Sprite:create("res/image/friends/input_bg.png")
    refreshBg:setContentSize(120,33)
    refreshBg:setAnchorPoint(1,0.5)
    freshLayer:addChild(refreshBg)

    local refreshBtn = XTHD.createCommonButton({
        btnColor = "write_1",
        isScrollView = false,
        btnSize = cc.size(130,49),
        text = LANGUAGE_BTN_KEY.lijishuaxin,
        endCallback = function ()
            local _modules = self._shopType == 1 and "refreshWeapon?" or "refreshFlower?"
            XTHDHttp:requestAsyncInGameWithParams({
                modules = _modules,
                successCallback = function(data)
                    if tonumber(data.result) == 0 then
                        if self._shopType == 1 then
							data.items = self:SortList(data.items)
                            self:saveDataToDB(data)
                            gameUser.setIngot(data.ingot)
                        end
						if self._shopType == 3 then
							data.items = self:FlowerSortList(data.items)
						end
                        self._BuyData = data
                        XTHDTOAST(LANGUAGE_KEY_REFRESHOK)------"刷新完成")
                        -- ZCLOG(data)
                        self:createBuy(data)
                        
                        --self.refreshTimeLabel:setString("剩余刷新次数:"..tostring(data.count))
                        --self.CountDown = tonumber(data.time+1)
                        --self.CountDownLabel:setString(getCdStringWithNumber(self.CountDown,{h=":"}))
                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                        -- self.tuskSpine:setAnimation(0,"atk",false)
                    else
                        self:noItemsDialog(2303)
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
    })
    refreshBtn:setScale(0.7)
    refreshBtn:setAnchorPoint(1, 0)
    refreshBtn:setPosition(bgwidth-10, bgheight + refreshBtn:getContentSize().height * 0.25)
    freshLayer:addChild(refreshBtn)
    refreshBg:setPosition(refreshBtn:getPositionX() - refreshBtn:getContentSize().width + 30, refreshBtn:getPositionY()+refreshBtn:getContentSize().height*0.5 - 11)

    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2303}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2303}).count or 0
    end

    -- dump(self._BuyData)

    local _file = IMAGE_KEY_HEADER_REFRESHORDER
    -- if current_num == 0 then
    --     _file = IMAGE_KEY_HEADER_INGOT
    -- end

    if self._shopType == 3 then
        _file = IMAGE_KEY_HEADER_FLOWER
    end

    local lableStr = "1/"..tostring(current_num)

    if tonumber(data.needIngot) > 0 then
        lableStr = "1/"..tostring(current_num)
    else
        lableStr = "免费"
    end

    local RefreshIcon = cc.Sprite:create(_file)
    RefreshIcon:setAnchorPoint(0, 0.5)
	RefreshIcon:setScale(0.8)
    RefreshIcon:setPosition( 0, refreshBg:getBoundingBox().height*0.5)
    refreshBg:addChild(RefreshIcon)


    -- if current_num == 0 then
    --     lableStr = "200"
    -- end

    if self._shopType == 3 then -- 鲜花商店
        lableStr = tostring(data.needIngot)
    end
    
    self.refreshConsume = getCommonWhiteBMFontLabel(lableStr)
    self.refreshConsume:setAnchorPoint(0,0.5)
    self.refreshConsume:setPosition(RefreshIcon:getPositionX()+RefreshIcon:getBoundingBox().width,RefreshIcon:getPositionY())
    refreshBg:addChild(self.refreshConsume)
    self.refreshConsume:setFontSize(18)

    -- 刷新次数
    self.refreshTimeLabel = XTHDLabel:createWithParams({
        text = "",
        fontSize = 18,
        color = XTHD.resource.color.gray_desc
    })
    self.refreshTimeLabel:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
    self.refreshTimeLabel:setAnchorPoint(0,0.5)
    self.refreshTimeLabel:setPosition(refreshBg:getPositionX() - refreshBg:getBoundingBox().width - 5 - 150,
        refreshBtn:getPositionY() + refreshBtn:getContentSize().height + 7)
    freshLayer:addChild(self.refreshTimeLabel)
    self.refreshTimeLabel:setString("剩余刷新次数:"..tostring(data.count))
    self.refreshTimeLabel:setVisible(false)


    local RefreshLabel = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS205,---------"下次刷新时间：",
        fontSize = 18,
        color = XTHD.resource.color.gray_desc
    })
    RefreshLabel:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
    RefreshLabel:setAnchorPoint(0,0.5)
    RefreshLabel:setPosition(refreshBg:getPositionX() - refreshBg:getBoundingBox().width - 5,
        refreshBtn:getPositionY() + refreshBtn:getContentSize().height + 7)
    freshLayer:addChild(RefreshLabel)
    RefreshLabel:setVisible(false)

    self.CountDownLabel = getCommonWhiteBMFontLabel(getCdStringWithNumber(self.CountDown,{h=":"}))
    self.CountDownLabel:setAnchorPoint(0,0.5)
    self.CountDownLabel:setPosition(RefreshLabel:getBoundingBox().width+RefreshLabel:getPositionX(),RefreshLabel:getPositionY()-7)
    freshLayer:addChild(self.CountDownLabel)
    self.CountDownLabel:setVisible(false)

    local function onNodeEvent(event)
        if event == "exit" then
            self.CountDownLabel = nil
        end
    end
    self.CountDownLabel:registerScriptHandler(onNodeEvent)
    local _diFile = "res/image/plugin/weaponshop/14.png"
    if self._shopType == 3 then
        _diFile = "res/image/plugin/weaponshop/04.png"
    end
    local lenth = 5

    for i=1, #self._BuyData.items do
        local nowData = self._BuyData.items[i]
        local weapId = nowData.configId
        
        local itemBgTextureN = cc.Sprite:create(_diFile)
        itemBgTextureN:setScale(0.75)
        -- itemBgTextureN:setContentSize(110,160)
        -- local itemBgTextureS = ccui.Scale9Sprite:create(cc.rect(52,52,1,1),"res/image/common/scale9_bg_3.png")
        -- itemBgTextureS:setContentSize(180,160)
        
        local ItemBg = XTHDPushButton:createWithParams({
            normalNode = itemBgTextureN,
             -- selectedNode = itemBgTextureS
        })
        local _itemSize = ItemBg:getContentSize()
        local minbg = (bgwidth - (4*_itemSize.width)-(4*lenth))*0.5
        local _posX = minbg+(((i > 4 and i-4 or i) - 1)*(lenth+_itemSize.width))+_itemSize.width*0.5+lenth*0.5
        local _posY =  i > 4 and bgheight*0.5 - 7 - _itemSize.height*0.5 or bgheight*0.5 + 3 +_itemSize.height*0.5
        ItemBg:setPosition(_posX ,_posY)
        freshLayer:addChild(ItemBg)
        ItemBg:setTouchEndedCallback(function()
            self:DescFunc(nowData, data.flower, data.count)
        end)

        local itemData = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = nowData.itemId})
        local ItemName = XTHDLabel:createWithParams({
            text = itemData.name,
            fontSize = 16,
            color = XTHD.resource.color.gray_desc
        })
        ItemName:setPosition(ItemBg:getBoundingBox().width*0.5,ItemBg:getBoundingBox().height-20)
        ItemBg:addChild(ItemName)

        -- local WeaponEdge = cc.Sprite:create("res/image/plugin/weaponshop/weapon_edge.png")
        -- WeaponEdge:setPosition(ItemBg:getBoundingBox().width*0.5,149)
        -- ItemBg:addChild(WeaponEdge)

        local WeaponShadow = cc.Sprite:create("res/image/friends/input_bg.png")
        WeaponShadow:setPosition(ItemBg:getBoundingBox().width*0.5,28)
        WeaponShadow:setScale(0.8)
        ItemBg:addChild(WeaponShadow)

        local Item = ItemNode:createWithParams({
            itemId = nowData.itemId,
            clickable = false,
            _type_ = 4,
            count = nowData.itemCount
        })
        Item:setScale(0.8)
        Item:setPosition(ItemBg:getBoundingBox().width*0.5,ItemBg:getBoundingBox().height*0.5+8)
        ItemBg:addChild(Item)

        if nowData.tuijian == 1 then
            local recommended = cc.Sprite:create("res/image/vip/tuijian.png")
            recommended:setAnchorPoint(1,1)
            recommended:setPosition(ItemBg:getBoundingBox().width,ItemBg:getBoundingBox().height)
            ItemBg:addChild(recommended)
        end
        local ConsumeIcon, ConsumeNum
        if self._shopType == 1 then
            local _tb = string.split(nowData.price,"#")
            ConsumeNum = getCommonWhiteBMFontLabel(_tb[3])
            if tonumber(_tb[1]) ~= XTHD.resource.type.item then
                ConsumeIcon = cc.Sprite:create(XTHD.resource.getResourcePath(_tb[1]))
            else
                ConsumeIcon = cc.Sprite:create(IMAGE_KEY_HEADER_PSYCHICSTONE)
            end
        elseif self._shopType == 3 then
            ConsumeIcon = cc.Sprite:create(IMAGE_KEY_HEADER_FLOWER)
            ConsumeIcon:setScale(0.9)
            ConsumeNum = getCommonWhiteBMFontLabel(nowData.price)

            -- local quality = tonumber(Item._static_data.rank) or 0
            -- if quality >= 4 then
            if nowData.tuijian == 1 then
                local _animationSp = cc.Sprite:create("res/image/vip/effect/effect1.png")
                _animationSp:setPosition(cc.p(_itemSize.width*0.5-2, _itemSize.height*0.5 + 8))
                ItemBg:addChild(_animationSp)
                local brust_animation = getAnimation("res/image/vip/effect/effect",1,8,1/10)
                _animationSp:setScale(0.9)
                _animationSp:runAction(cc.RepeatForever:create(brust_animation))

            end
        end

        ConsumeIcon:setPosition(35,29)
        ItemBg:addChild(ConsumeIcon)
		
		ConsumeNum:setScale(0.9)
        ConsumeNum:setAnchorPoint(0,0.5)
        ConsumeNum:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1),1)
        ConsumeNum:setPosition(ConsumeIcon:getPositionX()+ConsumeIcon:getContentSize().width/2+2,ConsumeIcon:getPositionY()-5)
        ItemBg:addChild(ConsumeNum)

        if data.items[i].state == 1 then
            local Sold = cc.Sprite:create("res/image/plugin/weaponshop/weapon_sold.png")
            Sold:setPosition(ItemBg:getBoundingBox().width*0.5,ItemBg:getBoundingBox().height*0.5)
            ItemBg:addChild(Sold)
            Sold:setScaleX(0.85)
            Sold:setScaleY(0.95)

            local SoldLabel = cc.Sprite:create("res/image/plugin/weaponshop/sold.png")
            SoldLabel:setAnchorPoint(0,1)
            SoldLabel:setPosition(10,ItemBg:getBoundingBox().height-10)
            ItemBg:addChild(SoldLabel)

            ItemBg:setEnable(false)
        end
    end
end

--把数据写入到数据库中
function WanBaoGe:saveDataToDB( param )
    if param["costItems"] and #param["costItems"] ~= 0  then
        for i=1,#param["costItems"] do
            if param["costItems"][i].count and tonumber(param["costItems"][i].count) ~= 0 then
                DBTableItem.updateCount(gameUser.getUserId(),param["costItems"][i],param["costItems"][i].dbId)
            else
                DBTableItem.deleteData(gameUser.getUserId(),param["costItems"][i].dbId)
            end
        end
    end
end

function WanBaoGe:DescFunc(data , flower, time)
    local function callFn( ... )
        local _modules = self._shopType == 1 and "weaponWindow?" or "flowerWindow?"
        XTHDHttp:requestAsyncInGameWithParams({
            modules = _modules,
            successCallback = function(sData)
                if tonumber(sData.result) == 0 then
					if self._shopType == 1 then
						sData.items = self:SortList(sData.items)
					elseif self._shopType == 3 then
						sData.items = self:FlowerSortList(sData.items)
					end
                    self._BuyData = sData
                    self:createBuy(sData)
                else
                    XTHDTOAST(sData.msg)
                end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end
    local params = {sData = data, sCallFn = callFn, sType = self._shopType, sFlower = flower, sTime = time}
    local WanBaoGeDescPop = requires("src/fsgl/layer/WanBaoGe/WanBaoGeDescPop.lua"):create(params)
    WanBaoGeDescPop:setName("WanBaoGeDescPop")
    self:addChild(WanBaoGeDescPop)
    WanBaoGeDescPop:show()
end

function WanBaoGe:createWithType(_type, sParmas)
    if not sParmas or not sParmas.par then
        return
    end
    --[[
        type 1 购买
        type 2 回收
        type 3 鲜花
    ]]--
    local function create( sData )
        local pLay = WanBaoGe.new(_type, sData, sParmas.callFn)
        LayerManager.addLayout(pLay, sParmas)
    end
    if _type == 1 or _type == 3 then
        if not sParmas.data then
            local _modules = _type == 1 and "weaponWindow?" or "flowerWindow?"
            XTHDHttp:requestAsyncInGameWithParams({
                modules = _modules,
                successCallback = function(weaponWindow)
                    if tonumber(weaponWindow.result) == 0 then
						if _type == 1 then
							weaponWindow.items = self:SortList(weaponWindow.items)
						elseif _type == 3 then
							weaponWindow.items = self:FlowerSortList(weaponWindow.items)
						end
                        create( weaponWindow )
                    else
                        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
                    end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = sParmas.par,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
        else
            create(sParmas.data)
        end
    else
        create(sParmas.data)
    end
end

--万宝阁界面排序
function WanBaoGe:SortList(list)
	local ranklist = {{},{},{},{},{},{}}
	for i = 1, #list do
		local rank = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = list[i].itemId}).rank
		if tonumber(rank) == 6 then
			ranklist[1][#ranklist[1] + 1] = list[i]
			ranklist[1][#ranklist[1]].rank = rank
		elseif tonumber(rank) == 5 then
			ranklist[2][#ranklist[2] + 1] = list[i]
			ranklist[2][#ranklist[2]].rank = rank
		elseif tonumber(rank) == 4 then
			ranklist[3][#ranklist[3] + 1] = list[i]
			ranklist[3][#ranklist[3]].rank = rank
		elseif tonumber(rank) == 3 then
			ranklist[4][#ranklist[4] + 1] = list[i]
			ranklist[4][#ranklist[4]].rank = rank
		elseif tonumber(rank) == 2 then
			ranklist[5][#ranklist[5] + 1] = list[i]
			ranklist[5][#ranklist[5]].rank = rank
		elseif tonumber(rank) == 1 then
			ranklist[6][#ranklist[6] + 1] = list[i]
			ranklist[6][#ranklist[6]].rank = rank
		end
	end

	local list_2 = {{},{},{}}

	for i = 1,#ranklist do
		if #ranklist[i] > 0 then
			for k, v in pairs(ranklist[i]) do
				local data = string.split(v.price,"#")
				if tonumber(data[1]) == 2 then
					v._type = 1
				elseif tonumber(data[1]) == 6 then
					v._type = 2
				elseif tonumber(data[1]) == 3 then
					v._type = 3
				elseif tonumber(data[1]) == 4 then
					v._type = 4
				end
			end
		end
	end

	for i = 1,#ranklist do
		if #ranklist[i] > 0 then
			table.sort(ranklist[i],function( a,b )
                return a._type < b._type 
            end)
		end
	end
	
	list = {}
	
	for i = 1,#ranklist do
		for k, v in pairs(ranklist[i]) do
			list[#list + 1] = v
		end
	end

	return list
	
end

--鲜花商店界面排序
function WanBaoGe:FlowerSortList(list)
	local ranklist = {{},{},{},{},{},{}}
	for i = 1, #list do
		local rank = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = list[i].itemId}).rank
		if tonumber(rank) == 6 then
			ranklist[1][#ranklist[1] + 1] = list[i]
			ranklist[1][#ranklist[1]].rank = rank
		elseif tonumber(rank) == 5 then
			ranklist[2][#ranklist[2] + 1] = list[i]
			ranklist[2][#ranklist[2]].rank = rank
		elseif tonumber(rank) == 4 then
			ranklist[3][#ranklist[3] + 1] = list[i]
			ranklist[3][#ranklist[3]].rank = rank
		elseif tonumber(rank) == 3 then
			ranklist[4][#ranklist[4] + 1] = list[i]
			ranklist[4][#ranklist[4]].rank = rank
		elseif tonumber(rank) == 2 then
			ranklist[5][#ranklist[5] + 1] = list[i]
			ranklist[5][#ranklist[5]].rank = rank
		elseif tonumber(rank) == 1 then
			ranklist[6][#ranklist[6] + 1] = list[i]
			ranklist[6][#ranklist[6]].rank = rank
		end
	end

	for i = 1,#ranklist do
		if #ranklist[i] > 0 then
			table.sort(ranklist[i],function( a,b )
                return a.rank < b.rank 
            end)
		end
	end
	
	list = {}
	for i = 1,#ranklist do
		for k, v in pairs(ranklist[i]) do
			list[#list + 1] = v
		end
	end
	return list
end

function WanBaoGe:onEnter()
end

return WanBaoGe