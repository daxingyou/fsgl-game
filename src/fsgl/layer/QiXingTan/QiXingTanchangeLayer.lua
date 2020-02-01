--Create By hezhitao 2015年08月17日
--七星坛主界面
local QiXingTanchangeLayer = class("QiXingTanchangeLayer",function ()
    return XTHD.createBasePageLayer({bg = "res/image/exchange/qixiangtanbg.png"})
end)

local zhekou = 0.9
local HEROMIANFEI_ONE = 10001
local EQUIPMIANFEI_ONE = 100001
function QiXingTanchangeLayer:onEnter()
	musicManager.playMusic(XTHD.resource.music.effect_qixingtan_bgm )
end

function QiXingTanchangeLayer:onExit()
	musicManager.playMusic(XTHD.resource.music.music_bgm_main )
end

function QiXingTanchangeLayer:ctor(data,callback)
	self._callback = callback
	self._one_Herotimes_cd = data.petCD
	self._one_Equiptimes_cd = data.itemCD
	self._one_times_btn = nil
	dump(data,"777")
    local mengban_bg = cc.LayerColor:create(cc.c4b(0,0,0, 0))
    self:addChild(mengban_bg)

    local size = self:getContentSize()
    local layer_height = size.height - self.topBarHeight
    local bg = XTHD.createSprite()
    bg:setContentSize(XTHD.resource.visibleSize.width,layer_height)
    bg:setPosition(size.width/2, layer_height/2)
    self:addChild(bg)
	self._bg = bg

	-- local help_btn = XTHDPushButton:createWithParams({
	-- 	normalFile        = "res/image/camp/lifetree/wanfa_up.png",
 --        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
 --        musicFile = XTHD.resource.music.effect_btn_common,
 --        endCallback       = function()
 --            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=39});
 --            self:addChild(StoredValue)
 --        end,
	-- })
	-- self:addChild(help_btn)
	-- help_btn:setPosition(self:getContentSize().width - help_btn:getContentSize().width,self._bg:getContentSize().height - help_btn:getContentSize().height)

    --玩法说明
    local help_btn = XTHDPushButton:createWithParams({
    normalFile        = "res/image/common/btn/tip_up.png",
    selectedFile      = "res/image/common/btn/tip_down.png",
    musicFile = XTHD.resource.music.effect_btn_common,
    endCallback       = function()
        local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=37});
        StoredValue:setAnchorPoint(0.5,0.5)
        local layer = cc.Director:getInstance():getRunningScene()
        StoredValue:setPosition(0,0)
        layer:addChild(StoredValue,5)
    end,
    })
    help_btn:setScale(0.9)
    self:addChild(help_btn)
    help_btn:setPosition(50,self:getContentSize().height - 90)

	self:createLeftUI()
	self:createRightUI()

	local zhaohuanshibg = cc.Sprite:create("res/image/exchange/topbarItem_bg.png")
	self._bg:addChild(zhaohuanshibg)
	zhaohuanshibg:setContentSize(zhaohuanshibg:getContentSize().width *0.75,zhaohuanshibg:getContentSize().height *0.75)
	zhaohuanshibg:setPosition(self._bg:getContentSize().width/4+10,zhaohuanshibg:getContentSize().height - 10)
	
	local icon = cc.Sprite:create("res/image/exchange/exchange_diamond.png")
	zhaohuanshibg:addChild(icon)
	icon:setScale(0.8)
	icon:setPosition(icon:getContentSize().width *0.25,zhaohuanshibg:getContentSize().height*0.5 + 2.5)
	
	local num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0
	local zhaohuanshiNum = XTHDLabel:create(num,16,"res/fonts/def.ttf")
	zhaohuanshibg:addChild(zhaohuanshiNum)
	zhaohuanshiNum:setPosition(zhaohuanshibg:getContentSize().width *0.5 + 10,zhaohuanshibg:getContentSize().height*0.5)
	self._zhaohuanshiNum = zhaohuanshiNum
	
	local tianxingshibg = cc.Sprite:create("res/image/exchange/topbarItem_bg.png")
	self._bg:addChild(tianxingshibg)
	tianxingshibg:setContentSize(tianxingshibg:getContentSize().width *0.75,tianxingshibg:getContentSize().height *0.75)
	tianxingshibg:setPosition(self._bg:getContentSize().width/4*3 - 10,tianxingshibg:getContentSize().height - 10)

	local icon = cc.Sprite:create("res/image/exchange/exchange_soul_icon.png")
	tianxingshibg:addChild(icon)
	icon:setScale(0.8)
	icon:setPosition(icon:getContentSize().width *0.25,tianxingshibg:getContentSize().height*0.5 + 2.5)

	local num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count or 0
	local tianxingshiNum = XTHDLabel:create(num,16,"res/fonts/def.ttf")
	tianxingshibg:addChild(tianxingshiNum)
	tianxingshiNum:setPosition(tianxingshibg:getContentSize().width *0.5 + 10,tianxingshibg:getContentSize().height*0.5)
	self._tianxingshiNum = tianxingshiNum
	--羁绊
	local btn_jiban = XTHDPushButton:createWithParams({
		normalFile = "res/image/exchange/btn_jiban_up.png",
		selectedFile = "res/image/exchange/btn_jiban_down.png",
	})
	self._bg:addChild(btn_jiban)
	btn_jiban:setScale(0.8)
	btn_jiban:setPosition(-btn_jiban:getContentSize().width *0.5 + 10,btn_jiban:getContentSize().height *0.5 - 10)
	btn_jiban:setTouchEndedCallback(function()
		local layer = requires("src/fsgl/layer/JiBan/JiBanLayer.lua"):create()
		self:addChild(layer)
		layer:show()
	end)

	--图鉴
	local btn_tujian = XTHDPushButton:createWithParams({
		normalFile = "res/image/exchange/btn_tujian_up.png",
		selectedFile = "res/image/exchange/btn_tujian_down.png",
	})
	self._bg:addChild(btn_tujian)
	btn_tujian:setScale(0.8)
	btn_tujian:setPosition(btn_jiban:getPositionX() + btn_jiban:getContentSize().width - 10,btn_jiban:getPositionY())
	btn_tujian:setTouchEndedCallback(function()
		local illustrationlayer = requires("src/fsgl/layer/TuJian/TuJianLayer.lua"):create()
		LayerManager.addLayout(illustrationlayer)
	end)

	--装备兑换
	local Equipduihuan = XTHDPushButton:createWithParams({
		normalFile = "res/image/exchange/btn_duihuanzhuangbei_up.png",
		selectedFile = "res/image/exchange/btn_duihuanzhuangbei_down.png",
	})
	self._bg:addChild(Equipduihuan)
	Equipduihuan:setScale(0.8)
	Equipduihuan:setPosition(self._bg:getContentSize().width + Equipduihuan:getContentSize().width*0.5 - 10,btn_jiban:getPositionY())
	Equipduihuan:setTouchEndedCallback(function()
		local exchange_equip_sum = requires("src/fsgl/layer/QiXingTan/QiXingTanchangeEquipSubLayer.lua"):create()
        LayerManager.addLayout(exchange_equip_sum, {par = self})
	end)

	--英雄兑换
	local Heroduihuan = XTHDPushButton:createWithParams({
		normalFile = "res/image/exchange/btn_duihuanyingxiong_up.png",
		selectedFile = "res/image/exchange/btn_duihuanyingxiong_down.png",
	})
	self._bg:addChild(Heroduihuan)
	Heroduihuan:setScale(0.8)
	Heroduihuan:setPosition(Equipduihuan:getPositionX() - Heroduihuan:getContentSize().width + 10,btn_jiban:getPositionY())
	Heroduihuan:setTouchEndedCallback(function()
		local exchange_equip_sum = requires("src/fsgl/layer/QiXingTan/QiXingTanchangeHeroSubLayer.lua"):create()
        LayerManager.addLayout(exchange_equip_sum, {par = self})
	end)

    if tonumber(gameUser.getFreeChouHero()) == 0 then --gameUser.getFreeChouHero()==1 免费抽取， == 0 不能免费
        self._hero_red_point :setVisible(false)
    elseif tonumber(gameUser.getFreeChouHero()) == 1 then
        self._hero_red_point :setVisible(true)
    end

    if tonumber(gameUser.getFreeChouTools()) == 0 then
        self._equip_red_point:setVisible(false)
    elseif tonumber(gameUser.getFreeChouTools()) == 1 then
        self._equip_red_point:setVisible(true)
    end
    
    XTHD.addEventListener({name = "EXCHANGE_REFRESH_RED_POINT" ,callback = function ( event )
        -- dump(event.data,"aksdjfasjdfl_event")
        local temp_data = event["data"]
        if temp_data["_type"] == "hero" and temp_data["free"] == true then
            self._hero_red_point :setVisible(true)
        elseif temp_data["_type"] == "hero" and temp_data["free"] == false then
            self._hero_red_point :setVisible(false)
        elseif temp_data["_type"] == "equip" and temp_data["free"] == true then
            self._equip_red_point:setVisible(true)
        elseif temp_data["_type"] == "equip" and temp_data["free"] == false then
            self._equip_red_point:setVisible(false)
        end
    end})
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_QIXINGTAN_NUMLABLE,callback = function ()
        self:refreshNumLable()
		self:refreshBuyLabel()
    end})
	self:checkFreeExchange()
	self:addGuide()
end

function QiXingTanchangeLayer:createLeftUI()
	--招募英雄
    local hero_img = cc.Sprite:create("res/image/exchange/exchange_hero_img.png")
    hero_img:setPosition(self._bg:getContentSize().width/4+10,self._bg:getContentSize().height/2 + 10)
    self._bg:addChild(hero_img)

	for i = 1, 2 do
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/exchange/zhaomu_".. i .. "_up.png",
			selectedFile = "res/image/exchange/zhaomu_".. i .. "_down.png",
		})
		hero_img:addChild(btn)
		btn:setPosition(15 + btn:getContentSize().width + (i-1)*(btn:getContentSize().width + 20),btn:getContentSize().height + 35)
		if i == 1 then
			 --可以免费抽取红点提示
			local hero_red_point = XTHD.createSprite("res/image/common/heroList_redPoint.png")
			hero_red_point:setPosition(btn:getContentSize().width-5,btn:getContentSize().height-5)
			hero_red_point:setScale(0.5)
			btn:addChild(hero_red_point)
			self._hero_red_point = hero_red_point
			self._one_times_btn = btn
		end
		btn:setTouchEndedCallback(function()
			self:SwichHero(i)
		end)
	end

	local lablebg = cc.Sprite:create("res/image/exchange/topbarItem_bg.png")
	lablebg:setContentSize(lablebg:getContentSize().width *0.75,lablebg:getContentSize().height *0.75)
	hero_img:addChild(lablebg)
	lablebg:setPosition(hero_img:getContentSize().width - lablebg:getContentSize().width + 2.5,lablebg:getContentSize().height + 8)

	local icon = cc.Sprite:create("res/image/common/yxmlicon1.png")
	icon:setScale(0.7)
	lablebg:addChild(icon)
	icon:setAnchorPoint(0,0.5)
	icon:setPosition(5,lablebg:getContentSize().height*0.5)
	
	local current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}).count or 0
	local HeroNumLable = XTHDLabel:create(current_num.."/"..10*zhekou,16,"res/fonts/def.ttf")
	HeroNumLable:setAnchorPoint(0.5,0.5)
	lablebg:addChild(HeroNumLable)
	HeroNumLable:setPosition(lablebg:getContentSize().width *0.5 + 10,lablebg:getContentSize().height*0.5)
	self._HeroNumLable = HeroNumLable

	local HeromianfeiLable = XTHDLabel:create("（本次免费）",18,"res/fonts/def.ttf")
	HeromianfeiLable:setColor(cc.c3b(18,255,0))
	HeromianfeiLable:setAnchorPoint(0,0.5)
	hero_img:addChild(HeromianfeiLable)
	HeromianfeiLable:setPosition(45,lablebg:getPositionY())
	self._HeromianfeiLable = HeromianfeiLable
	
	local Herocdlable = XTHDLabel:create("00:00:00 后免费",14,"res/fonts/def.ttf")
	Herocdlable:setColor(cc.c3b(18,255,0))
	Herocdlable:setAnchorPoint(0,0.5)
	hero_img:addChild(Herocdlable)
	Herocdlable:setPosition(45,lablebg:getPositionY())
	self._Herocdlable = Herocdlable
	self._Herocdlable:setVisible(false)
end

function QiXingTanchangeLayer:createRightUI()
    --抽取装备
    local equip_img = cc.Sprite:create("res/image/exchange/exchange_equip_img.png")
    equip_img:setPosition(self._bg:getContentSize().width/4*3 - 10,self._bg:getContentSize().height/2 + 10)
    self._bg:addChild(equip_img)

	for i = 1, 2 do
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/exchange/zhaohuan_".. i .. "_up.png",
			selectedFile = "res/image/exchange/zhaohuan_".. i .. "_down.png",
		})
		equip_img:addChild(btn)
		btn:setPosition(15 + btn:getContentSize().width + (i-1)*(btn:getContentSize().width + 20),btn:getContentSize().height + 35)
		if i == 1 then
			 --可以免费抽取红点提示
			local equip_red_point = XTHD.createSprite("res/image/common/heroList_redPoint.png")
			equip_red_point:setPosition(btn:getContentSize().width-5,btn:getContentSize().height-5)
			equip_red_point:setScale(0.5)
			btn:addChild(equip_red_point)
			self._equip_red_point = equip_red_point
		end
		btn:setTouchEndedCallback(function()
			self:SwichItems(i)
		end)
	end

	local lablebg = cc.Sprite:create("res/image/exchange/topbarItem_bg.png")
	lablebg:setContentSize(lablebg:getContentSize().width *0.75,lablebg:getContentSize().height *0.75)
	equip_img:addChild(lablebg)
	lablebg:setPosition(equip_img:getContentSize().width - lablebg:getContentSize().width + 2.5,lablebg:getContentSize().height + 8)

	local icon = cc.Sprite:create("res/image/common/sbhjicon1.png")
	icon:setScale(0.7)
	lablebg:addChild(icon)
	icon:setAnchorPoint(0,0.5)
	icon:setPosition(5,lablebg:getContentSize().height*0.5)

	local current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}).count or 0
	local EquipNumLable = XTHDLabel:create(current_num.."/"..10*zhekou,16,"res/fonts/def.ttf")
	EquipNumLable:setAnchorPoint(0.5,0.5)
	lablebg:addChild(EquipNumLable)
	EquipNumLable:setPosition(lablebg:getContentSize().width *0.5 + 10,lablebg:getContentSize().height*0.5)
	self._EquipNumLable = EquipNumLable

	local EquipmianfeiLable = XTHDLabel:create("（本次免费）",18,"res/fonts/def.ttf")
	EquipmianfeiLable:setColor(cc.c3b(18,255,0))
	EquipmianfeiLable:setAnchorPoint(0,0.5)
	equip_img:addChild(EquipmianfeiLable)
	EquipmianfeiLable:setPosition(45,lablebg:getPositionY())
	self._EquipmianfeiLable = EquipmianfeiLable

	local Equipcdlable = XTHDLabel:create("00:00:00 后免费",14,"res/fonts/def.ttf")
	Equipcdlable:setColor(cc.c3b(18,255,0))
	Equipcdlable:setAnchorPoint(0,0.5)
	equip_img:addChild(Equipcdlable)
	Equipcdlable:setPosition(45,lablebg:getPositionY())
	self._Equipcdlable = Equipcdlable
	self._Equipcdlable:setVisible(false)
end

function QiXingTanchangeLayer:SwichHero( index )
     current_num = 0
     if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}) then
		current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}).count or 0
     end
     if index == 1 then
		if current_num < 1 and self._HeromianfeiLable:isVisible() == false then
			self:noItemsDialog(2306)
		else
			self:doHttpRequest(1,1)
		end
     else
		if current_num < 9 and self._HeromianfeiLable:isVisible() == false then
			self:noItemsDialog(2306)
		else
			self:doHttpRequest(1,10)
		end
     end
end

function QiXingTanchangeLayer:SwichItems( index )
    current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}) then
		current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}).count or 0
    end
    if index == 1 then
		if current_num < 1 and self._EquipmianfeiLable:isVisible() == false then
			self:noItemsDialog(2307)
		else
			self:doHttpRequest(2,1)
		end
    else
		if current_num < 9 and self._EquipmianfeiLable:isVisible() == false then
			self:noItemsDialog(2307)
		else
			self:doHttpRequest(2,10)
		end
    end
end

function QiXingTanchangeLayer:doHttpRequest(_recruitType, times )
    --recruitType = 1 表示英雄， recruitType = 2 表示道具
    YinDaoMarg:getInstance():guideTouchEnd()
    ClientHttp:requestAsyncInGameWithParams({
        modules = "recruitRequest?",
        params = {recruitType=_recruitType,sum=times},
        successCallback = function(data)
            --获取奖励成功
            if  tonumber(data.result) == 0 then
                ----引导 
                -- YinDaoMarg:getInstance():doNextGuide()
                ------------------------------------------
                --刷新用户数据                self:refreshTopBarData(data)
				self:getHeroReward(_recruitType,data)
                self._one_Herotimes_cd = tonumber(data.petCD) - 1
                self._one_Equiptimes_cd = tonumber(data.itemCD)
                self:checkFreeExchange()   
                self:refreshBuyLabel()             
            else
                YinDaoMarg:getInstance():tryReguide()
                XTHDTOAST(data.msg)
            end
            if data["ingot"] then
                gameUser.setIngot(data["ingot"])
            end
            if data["gold"] then
                gameUser.setGold( data["gold"])
            end          
        end,--成功回调
        failedCallback = function()
            YinDaoMarg:getInstance():tryReguide()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function QiXingTanchangeLayer:noItemsDialog(_itemid)
	local _dialog = XTHDConfirmDialog:createWithParams({
		msg = LANGUAGE_KEY_HERO_TEXT.noItemsToGetTextXc
		,rightCallback = function()
		    local popLayer = requires("src/fsgl/layer/YingXiong/BuyExpByIngotPopLayer1.lua")
		    popLayer= popLayer:create(_itemid, self)
		    popLayer:setName("BuyExpPop")
		    self:addChild(popLayer)
		end
	})
	self:addChild(_dialog)
end

function QiXingTanchangeLayer:refreshBuyLabel()
    local current_num = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}) then
        current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2306}).count or 0
    end
    self._HeroNumLable:setString(current_num.."/"..10*zhekou)

	local current_num_2 = 0
    if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}) then
        current_num_2 = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2307}).count or 0
    end
	self._EquipNumLable:setString(current_num_2.."/"..10*zhekou)
end

function QiXingTanchangeLayer:getHeroReward(_type, data )
    local _data = data
    if not _data then
        return
    end
    if not _data["addPets"] or not _data["resultList"] then
        return
    end
    _data.parent = self
    local function _goShowReward()
		if _type == 1 then
			local showReward = requires("src/fsgl/layer/QiXingTan/QiXingTanShowHeroRewardPop.lua"):create(_data)
			LayerManager.pushModule(showReward)
		else
			local showReward = requires("src/fsgl/layer/QiXingTan/QiXingTanShowEquipRewardPop.lua"):create(data)
			LayerManager.pushModule(showReward)
		end
    end 

    if _data.serverAddress ~= "" and _data.token ~= "" then
        gameUser.setToken(_data.token)
        gameUser.setNewLoginToken(_data.token) 
        GAME_API = _data.serverAddress.."/game/"
        XTHDHttp:requestAsyncWithParams({
            url = _data.serverAddress .. "/game/newLogin?token="..gameUser.getNewLoginToken(),
            successCallback = function( sData )
                if sData.result == 0 then
                    cc.UserDefault:getInstance():setStringForKey(KEY_NAME_LAST_UUID, sData["uuid"])
                    cc.UserDefault:getInstance():flush()
                    gameUser.setSocketIP(0)
                    gameUser.setSocketPort(0)
                    gameUser.initWithData(sData)
                    MsgCenter:getInstance()
                    _goShowReward()
                    return 
                end
                gameUser.setToken(nil)
                LayerManager.backToLoginLayer()
            end,
            failedCallback = function()
                gameUser.setToken(nil)
                LayerManager.backToLoginLayer()
            end,
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    else
        if _data.serverAddress ~= "" then
            MsgCenter:getInstance()
        end
        _goShowReward()
    end
end

function QiXingTanchangeLayer:checkFreeExchange(  )
    if self._one_Herotimes_cd <= 0 then
		self._HeromianfeiLable:setVisible(true)
		self._Herocdlable:setVisible(false)
        gameUser.setFreeChouHero(1)  --设置可以免费抽取状态
        XTHD.dispatchEvent({name = "EXCHANGE_REFRESH_RED_POINT",data = {_type = "hero",free = true}})
    else
		self._Herocdlable:setVisible(true)
		self._HeromianfeiLable:setVisible(false)
		self:stopActionByTag(HEROMIANFEI_ONE)
		schedule(self,function()
			self._one_Herotimes_cd = self._one_Herotimes_cd - 1
			self._Herocdlable:setString(self:getTimeLable(self._one_Herotimes_cd).."后免费")
		end,1,HEROMIANFEI_ONE)
        gameUser.setFreeChouHero(0)  --设置不可以免费抽取状态
        XTHD.dispatchEvent({name = "EXCHANGE_REFRESH_RED_POINT",data = {_type = "hero",free = false}})
    end

	if self._one_Equiptimes_cd <= 0 then
		self._EquipmianfeiLable:setVisible(true)
		self._Equipcdlable:setVisible(false)
        gameUser.setFreeChouHero(1)  --设置可以免费抽取状态
        XTHD.dispatchEvent({name = "EXCHANGE_REFRESH_RED_POINT",data = {_type = "equip",free = true}})
    else
		self:stopActionByTag(EQUIPMIANFEI_ONE)
		schedule(self,function()
			self._one_Equiptimes_cd = self._one_Equiptimes_cd - 1
			self._Equipcdlable:setString(self:getTimeLable(self._one_Equiptimes_cd).."后免费")
		end,1,EQUIPMIANFEI_ONE)
		self._Equipcdlable:setVisible(true)
		self._EquipmianfeiLable:setVisible(false)
        gameUser.setFreeChouHero(0)  --设置不可以免费抽取状态
        XTHD.dispatchEvent({name = "EXCHANGE_REFRESH_RED_POINT",data = {_type = "equip",free = false}})
    end
	
    --检测是否可以免费抽取，如果不能，则把主城的红点消失
    if tonumber(self._one_Herotimes_cd) > 0 and tonumber(self._one_Equiptimes_cd) > 0 then
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "chouka",visible = false} })
    end

end

function QiXingTanchangeLayer:refreshNumLable()
	local num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2301}).count or 0
	self._tianxingshiNum:setString(num)
	num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2302}).count or 0
	self._zhaohuanshiNum:setString(num)
end

function QiXingTanchangeLayer:getTimeLable(time)
	local pTime = tonumber(time) or 0
	local hour = math.floor(pTime / 3600)
	pTime = math.floor(pTime % 3600)
	local minute = math.floor(pTime / 60)
	pTime = math.floor(pTime % 60)
	if string.len(hour) < 2 then
		hour = "0"..hour
	end
	if string.len(minute) < 2 then
		minute = "0"..minute
	end
	if string.len(pTime) < 2 then
		pTime = "0"..pTime
	end
	return hour..":"..minute..":"..pTime
end

function QiXingTanchangeLayer:addGuide( )
    YinDaoMarg:getInstance():addGuide({ ----点击抽一次
        parent = self,
        target = self._one_times_btn,
        index = 3,
        updateServer = true,
        needNext = false
    },1)
    
    local close = self:getChildByName("TopBarLayer1"):getChildByName("topBarBackBtn")
    if close then 
        YinDaoMarg:getInstance():addGuide({ ----点击返回
            parent = self,
            target = close,
            index = 5,
            autoBackMainCity = false,
            needNext = false,
        },1)
    end 
   
    YinDaoMarg:getInstance():doNextGuide()   
    -------------------
end


function QiXingTanchangeLayer:create(data,callback)
    return self.new(data,callback)
end

function QiXingTanchangeLayer:onCleanup(  )
    XTHD.removeEventListener("EXCHANGE_REFRESH_RED_POINT")
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_QIXINGTAN_NUMLABLE)
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/exchange/reward/reward_background.jpg") 
    textureCache:removeTextureForKey("res/image/exchange/exchange_hero_img.png") 
    textureCache:removeTextureForKey("res/image/exchange/exchange_equip_img.png")
	if self._callback ~= nil and type(self._callback) == "function" then
       self._callback()
    end 
end

return QiXingTanchangeLayer