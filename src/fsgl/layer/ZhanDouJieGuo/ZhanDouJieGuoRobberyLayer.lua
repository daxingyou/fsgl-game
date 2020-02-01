--[[
被分离的robberylayer byhuangjingjian 
抢夺资源结算界面
]]
local ZhanDouJieGuoRobberyLayer=class("ZhanDouJieGuoRobberyLayer",function ( )
	return XTHDDialog:create()
end)
function ZhanDouJieGuoRobberyLayer:ctor(data )
	self:initUI(data )	
    -- musicManager.stopBackgroundMusic()
end

function ZhanDouJieGuoRobberyLayer:onCleanup()
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/tmpbattle/robbery_bg.jpg")
    textureCache:removeTextureForKey("res/image/tmpbattle/robbery_effect.png")
    textureCache:removeTextureForKey("res/image/tmpbattle/bigyellowword_0.png")
    textureCache:removeTextureForKey("res/image/tmpbattle/star_bg.png")
    textureCache:removeTextureForKey("res/image/tmpbattle/goldword001_0.png")
    textureCache:removeTextureForKey("res/image/tmpbattle/feicuiword001_0.png")
    textureCache:removeTextureForKey("res/image/tmpbattle/coin_label.png")
    textureCache:removeTextureForKey("res/image/tmpbattle/feicui_label.png")
end

function ZhanDouJieGuoRobberyLayer:initUI( data )
	local robbery_bg=cc.Sprite:create("res/image/tmpbattle/robbery_bg.png")
	robbery_bg:setPosition(0.5,0.5)
	robbery_bg:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
	self:addChild(robbery_bg)
	--评分
	local bg_width=robbery_bg:getContentSize().width+100
	local bg_height=robbery_bg:getContentSize().height
	local effect_light=cc.Sprite:create("res/image/tmpbattle/robbery_effect.png")
	effect_light:setPosition(bg_width/2-200,bg_height)
	robbery_bg:addChild(effect_light)
	local percent=math.floor((tonumber(data.addSilver)/self.max_coin)*100)

	local percent_num=cc.Label:createWithBMFont("res/image/tmpbattle/bigyellowword.fnt",percent.."%")
	percent_num:setPosition(effect_light:getPositionX(),effect_light:getPositionY()+50-20)
	robbery_bg:addChild(percent_num)
	--星级
	local star_bg=cc.Sprite:create("res/image/tmpbattle/star_bg.png")
	star_bg:setPosition(percent_num:getPositionX(),bg_height/3*2-50)
	robbery_bg:addChild(star_bg)
	local star_num=1
	if percent >= 100 then
		star_num=3
	elseif percent>= 66 then
		star_num=2
	end
	for i=1,3 do
		local star_black=cc.Sprite:create("res/image/tmpbattle/star_black.png")
		star_black:setPosition(65*i,star_bg:getContentSize().height/2)
		star_bg:addChild(star_black)
		local star_light=cc.Sprite:create("res/image/tmpbattle/star_light.png")
		star_light:setVisible(false)
		star_light:setPosition(65*i,star_bg:getContentSize().height/2)
		star_bg:addChild(star_light)
		if star_num>= i then
			star_light:setVisible(true)
		end
	end
	--
	local function setTxt(label_node,add_value, max_value,sp)
        if label_node then
            label_node:runAction(cc.Sequence:create(cc.DelayTime:create(1/60),cc.CallFunc:create(function()
                local _target_value = tonumber(label_node:getString()) + tonumber(add_value)
                if _target_value >= tonumber(max_value) then
                    _target_value = tonumber(max_value)
                end
                label_node:setString(_target_value)
                if tonumber(label_node:getString()) < tonumber(max_value) then
                    setTxt(label_node,add_value,max_value)
                end
            end)))
        end
    end

	--抢夺银两
	local coin_label=cc.Sprite:create("res/image/tmpbattle/coin_label.png")
	coin_label:setAnchorPoint(0,0.5)
	coin_label:setPosition(bg_width/2-50,bg_height-50)
	robbery_bg:addChild(coin_label)
	local coun_num=cc.Label:createWithBMFont("res/image/tmpbattle/goldword001.fnt",tostring(0))
	coun_num:setAnchorPoint(0,0.5)
	coun_num:setPosition(bg_width/2+50,coin_label:getPositionY()-40)
	robbery_bg:addChild(coun_num)
	local coin_sp=cc.Sprite:create("res/image/common/header_gold.png")
	coin_sp:setScale(1.5)
	coin_sp:setAnchorPoint(0,0.5)
	coin_sp:setPosition(bg_width/2-5,coin_label:getPositionY()-40-2)
	robbery_bg:addChild(coin_sp)
    local addvale=math.floor(tonumber(data.addSilver)/60)
        if addvale<=0 then
            addvale=1
        end
	setTxt(coun_num,addvale,data.addSilver,coin_sp)
	--抢夺翡翠header_feicui.png
	local feicui_label=cc.Sprite:create("res/image/tmpbattle/feicui_label.png")
	feicui_label:setAnchorPoint(0,0.5)
	feicui_label:setPosition(bg_width/2-50,coun_num:getPositionY()-50)
	robbery_bg:addChild(feicui_label)
	local feicui_num=cc.Label:createWithBMFont("res/image/tmpbattle/feicuiword001.fnt",tostring(0))
	feicui_num:setAnchorPoint(0,0.5)
	feicui_num:setPosition(bg_width/2+50,feicui_label:getPositionY()-40)
	robbery_bg:addChild(feicui_num)
	local feicui_sp=cc.Sprite:create("res/image/common/header_feicui.png")
	feicui_sp:setAnchorPoint(0,0.5)
	feicui_sp:setScale(1.5)
	feicui_sp:setPosition(bg_width/2-5,feicui_label:getPositionY()-40)
	robbery_bg:addChild(feicui_sp)
	feicui_num:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function (  )
        local addvale=math.floor(tonumber(data.addFeicui)/60)
        if addvale<=0 then
            addvale=1
        end
		setTxt(feicui_num,addvale,data.addFeicui,feicui_sp)
	end)))
	
	--获得奖牌header_award.png
	local reward_label=cc.Sprite:create("res/image/tmpbattle/reward_label.png")
	reward_label:setAnchorPoint(0,0.5)
	reward_label:setPosition(bg_width/2-50,feicui_num:getPositionY()-50)
	robbery_bg:addChild(reward_label)
	local reward_num=cc.Label:createWithBMFont("res/image/tmpbattle/jiangpaiword001.fnt","2")
	reward_num:setAnchorPoint(0,0.5)
	reward_num:setPosition(bg_width/2+50,reward_label:getPositionY()-40)
	robbery_bg:addChild(reward_num)

	local reward_sp=cc.Sprite:create("res/image/common/header_award.png")
	reward_sp:setAnchorPoint(0,0.5)
	reward_sp:setScale(1.5)
	reward_sp:setPosition(bg_width/2-5,reward_label:getPositionY()-40)
	robbery_bg:addChild(reward_sp)

	--数据
    self._battle_data_btn = XTHDPushButton:createWithParams({
        normalNode        ="res/image/tmpbattle/battle_data_normal.png" ,
        selectedNode      ="res/image/tmpbattle/battle_data_selected.png",
        needSwallow       = false,--是否吞噬事件
        fontSize=20,
        musicFile = XTHD.resource.music.effect_btn_common,
    })
    self._battle_data_btn:setAnchorPoint(1,0)
    self._battle_data_btn:setPosition(star_bg:getPositionX()-40,15)
    robbery_bg:addChild(self._battle_data_btn)
    self._battle_data_btn:setTouchEndedCallback(function()
        if self._battle_data_btn:getOpacity() < 255 then
            return
        end

        local pop=requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoShowHurtLayer.lua"):create(self._hurt_data,self._target_battle_type)
        self:addChild(pop)
    end)
    
    --留言
    local leavemsg_btn = XTHDPushButton:createWithParams({
        normalNode        ="res/image/tmpbattle/leavemsg_normal.png" ,
        selectedNode      ="res/image/tmpbattle/leavemsg_selected.png",
        needSwallow       = false,--是否吞噬事件
        fontSize=20,
    })
    leavemsg_btn:setVisible(false)
    leavemsg_btn:setAnchorPoint(0,0)
    leavemsg_btn:setPosition(star_bg:getPositionX()+40,15)
    if tonumber(data.fightResult) == 1 then
            leavemsg_btn:setVisible(true)
    end
    robbery_bg:addChild(leavemsg_btn)
    leavemsg_btn:setTouchEndedCallback(function()
        if leavemsg_btn:getOpacity() < 255 then
            return
        end
        self:ShowLeaveMsgPanel(self._reportId)
        -- print("点击留言")
    end)
	--返回
    local backbtn
    backbtn = XTHD.createCommonButton({
        btnSize = cc.size(142,49),
        isScrollView = false,
        text = "返  回",
        fontSize = 18,
        musicFile = XTHD.resource.music.effect_btn_commonclose,
        endCallback = function()
            --在完全显示出来之前，不执行点击事件
            if backbtn:getOpacity() < 255 then
                return
            end
            self:backBtn()
        end
    })
    backbtn:setName("backbtn")
    backbtn:setAnchorPoint(0.5,1)
    backbtn:setCascadeOpacityEnabled(true)
    backbtn:setPosition(bg_width/2,0)
    robbery_bg:addChild(backbtn)
	local lable = backbtn:getLabel()
	lable:setScale(1.4)

	--继续抢夺
	local  battle_again=  XTHD.createCommonButton({
        btnSize = cc.size(142,46),
        isScrollView = false,
        text = LANGUAGE_BTN_KEY.zaichoushici,
        fontSize = 22,
        musicFile = XTHD.resource.music.effect_btn_commonclose,
    })
    battle_again:setVisible(false)
    battle_again:setTouchEndedCallback(function()
        --在完全显示出来之前，不执行点击事件
        if battle_again:getOpacity() < 255 then
            return
        end
        -- XTHDTOAST("该功能暂未开启！")
        local function doRob()
			XTHDHttp:requestAsyncInGameWithParams({
	    		modules="strongRequest?",
		        -- params = {method="strongRequest?"},
		        successCallback = function(data)
			        if tonumber(data.result) == 0 then
			        	if data.rivals and #data.rivals > 0 then
			        		data.robberyTime = data.lootLeftCount
			        	local killaward=data 
			        	XTHD.dispatchEvent({name = "GOLD_COPY_GET_GOLD_NUM1",data = killaward }) 
						    self:backBtn()
						end
			        elseif tonumber(data.result) == 2000 then
		                XTHD.createExchangePop(3)
	                elseif tonumber(data.result) == 2002 then
		                XTHD.createExchangePop(1)
		            elseif tonumber(data.result) == 2007 then
		            	XTHDTOAST(LANGUAGE_TIPS_WORDS20)------"精力不足！")
			        else
			            XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)------"网络请求失败!")
			        end
		        end,--成功回调
		        failedCallback = function()
		            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
		        end,--失败回调
		        targetNeedsToRetain = self,--需要保存引用的目标
		        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		    })
		end
		doRob()
    end)
    battle_again:setCascadeOpacityEnabled(true)
    battle_again:setPosition(bg_width/2+100,-18)
    robbery_bg:addChild(battle_again)

    data.pet = data.pet or {}
    data.pet[1] = data.pet[1] or {}
    local _tb = data.pet[1].pets
    if _tb then
        for k,v in pairs(_tb) do
            local _data = 
            self:UpdateHeroData(v.property, k)
        end
    end
end

function ZhanDouJieGuoRobberyLayer:backBtn()
    musicManager.stopBackgroundMusic()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PVP_TEAMINFO}) 
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PVP_MAIN_LAYER}) 
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    -- LayerManager.popModule()
    cc.Director:getInstance():popScene()
end

function ZhanDouJieGuoRobberyLayer:UpdateHeroData(hero_data, heroid)
    --更新具体英雄的基本数据
    if hero_data then
        for i=1,#hero_data do
            local pro_data = string.split( hero_data[i],',')
            DBUpdateFunc:UpdateProperty( "userheros", pro_data[1], pro_data[2], heroid)
        end
    end
end

function ZhanDouJieGuoRobberyLayer:getBtnNode(imgpath,_size,_rect)

    local btn_node = ccui.Scale9Sprite:create(_rect,imgpath)
    btn_node:setContentSize(_size)
    btn_node:setCascadeOpacityEnabled(true)
    btn_node:setCascadeColorEnabled(true)

    return btn_node
end
function ZhanDouJieGuoRobberyLayer:ShowLeaveMsgPanel(report_id)--战报id
    local JingJiCompetitiveMsgPop = requires("src/fsgl/layer/JingJi/JingJiCompetitiveMsgPop.lua"):create(report_id,function ()
    end)
    self:addChild(JingJiCompetitiveMsgPop,4)
    JingJiCompetitiveMsgPop:show()
end
function ZhanDouJieGuoRobberyLayer:UpdateLordData(playerProperty)
     --更新玩家基本数据
    if playerProperty then
        for i=1,#playerProperty do
            local pro_data = string.split( playerProperty[i],',')
            DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
        end
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
end
function ZhanDouJieGuoRobberyLayer:create( data,max_data )
	local show = {}
	if data.bagItems and #data.bagItems ~= 0 then
        for i=1,#data.bagItems do
            local item_data = data.bagItems[i]
            local showCount = item_data.count
            if item_data.count and tonumber(item_data.count) ~= 0 then
                --print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
                showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId))
                DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
            else
                DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
            end
            --如果奖励类型
            local idx = #show + 1
            show[idx] = {}
            show[idx].rewardtype = 4 -- item_data.item_type
            show[idx].id = item_data.itemId
            show[idx].num = showCount
        end
    end
    --显示领取奖励成功界面
    ShowRewardNode:create(show)
	self._battle_data = data
	self._target_battle_type = tonumber(data["battleType"]) 
    self._reportId = data["reportId"]
    self._hurt_data = {}
    self._hurt_data["afurts"] = data["afurts"]
    self._hurt_data["bfurts"] = data["bfurts"]
    self.max_feicui=tonumber(max_data.addFeicui) or 0
    self.max_coin=tonumber(max_data.addSilver) or 0

    self:UpdateLordData(self._battle_data.playerProperty)
	return ZhanDouJieGuoRobberyLayer.new(data)
end
return ZhanDouJieGuoRobberyLayer