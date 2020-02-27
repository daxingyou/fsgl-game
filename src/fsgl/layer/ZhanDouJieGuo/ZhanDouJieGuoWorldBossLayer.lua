--[[
BattleType.OFFERREWARD_PVE=10 --悬赏任务
BattleType.WORLDBOSS_PVE=11 --世界Boss
BattleType.SINGLECHALLENGE=23 --单挑之王
]]
local ZhanDouJieGuoWorldBossLayer = class("ZhanDouJieGuoWorldBossLayer", function()
	return XTHDDialog:create()--XTHD.createPopLayer():create()
end)
function ZhanDouJieGuoWorldBossLayer:ctor(params)
	self.battleType=params.battleType
	self:initUI(params)
	musicManager.stopBackgroundMusic()
end

function ZhanDouJieGuoWorldBossLayer:onCleanup( )
	musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_main,true)
end

function ZhanDouJieGuoWorldBossLayer:initUI(params)
	-- print("世界Boss结算数据：")
	-- print_r(params)
	self:setColor(cc.c3b(0,0,0))
	self:setOpacity(100)
	--背景
	self._battle_data = params
	local bg_sp = ccui.Scale9Sprite:create("res/image/worldboss/result_bg2.png")
	bg_sp:setContentSize(1024,304)
	bg_sp:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self:addChild(bg_sp)
	self.popNode = bg_sp
	self.bg_sp = bg_sp
	local widthsize=bg_sp:getContentSize().width/2-30

	--确定按钮
	local close_btn = XTHD.createCommonButton({
		text = LANGUAGE_KEY_SURE,
		isScrollView = false,
        fontSize = 26,
        btnSize = cc.size(130,51),
        musicFile = XTHD.resource.music.effect_close_pop,
        endCallback = function()     
        	cc.Director:getInstance():popScene()
        end
	})
	-- close_btn:setScale(0.7)
    close_btn:setAnchorPoint(0.5,0)
    close_btn:setPosition(bg_sp:getContentSize().width/2, 10)
	bg_sp:addChild(close_btn)

    if self.battleType == BattleType.WORLDBOSS_PVE then   --世界Boss
        if #params.bagItems == 0 then
	        XTHDTOAST("每日挑战BOSS超过50次后将不再获得挑战奖励，排名和最后一击奖励不受影响！")
		end
    end

	if self.battleType == BattleType.WORLDBOSS_PVE or self.battleType == BattleType.GUILD_BOSS_PVE or self.battleType == BattleType.CAMP_SHOUWEI then 
		--标题图片
		local title_sp=cc.Sprite:create("res/image/worldboss/battle_over.png")
		title_sp:setPosition(bg_sp:getContentSize().width*0.5, bg_sp:getContentSize().height)
		bg_sp:addChild(title_sp)
		--世界boss血量
		local precent_one=string.format("%.4f", (params.curHurt/self.bossdata.hp))*100
		local precent_all=string.format("%.4f", (params.totalHurt/self.bossdata.hp))*100
		local str = LANGUAGE_KEY_WORLDBOSS_GETDPSCOUNT(params.curHurt, precent_one, params.totalHurt, precent_all)
		local hurt_labrl=XTHDLabel:createWithParams({
			text = str,
			size = 18,
			pos = cc.p(bg_sp:getContentSize().width*0.5, bg_sp:getContentSize().height-50),
			anchor = cc.p(0.5, 1)
		})
		bg_sp:addChild(hurt_labrl)
		self:itemData(params)
		self:createItem()
	elseif self.battleType == BattleType.OFFERREWARD_PVE or self.battleType == BattleType.SINGLECHALLENGE then
		local effVoice
		local title_sp=cc.Sprite:create("res/image/worldboss/battle_over.png")
		title_sp:setPosition(bg_sp:getContentSize().width*0.5, bg_sp:getContentSize().height)
		bg_sp:addChild(title_sp)
		if params.fightResult and  tonumber(params.fightResult)==1 then 
			-- title_sp:setText()
			if self.battleType == BattleType.SINGLECHALLENGE then  --单挑之王刷新副本进度
                self:freshLevelInfo()
			end
			self:itemData(params)
			self:createItem()
			effVoice = XTHD.resource.music.effect_battle_victory
		elseif tonumber(params.fightResult)==0 then 
			title_sp:setTexture("res/image/worldboss/result_faild.png")
			local fail_sp=cc.Sprite:create("res/image/worldboss/fail_sp.png")
			fail_sp:setPosition(bg_sp:getContentSize().width/2,bg_sp:getContentSize().height/2)
			bg_sp:addChild(fail_sp)
	    	effVoice = XTHD.resource.music.effect_battle_lost
		end  
		if effVoice then
	        musicManager.playEffect(effVoice, false)
	    end        
	elseif self.battleType == BattleType.PVP_CUTGOODS  then
		local effVoice
		local title_sp
		local presult = tonumber(params.fightResult) or 0
		if presult == BATTLE_RESULT.WIN  then--成功
			title_sp = sp.SkeletonAnimation:create( "res/spine/effect/battle_win/shengli.json", "res/spine/effect/battle_win/shengli.atlas",1.0)
			effVoice = XTHD.resource.music.effect_battle_victory
			self:itemData(params)
			self:createItem()

			local _sp0 = cc.Sprite:create("res/image/daily_task/escort_task/jiebiaojiangli.png")
			bg_sp:addChild(_sp0)
			_sp0:setPosition(bg_sp:getContentSize().width*0.5, bg_sp:getContentSize().height - 90) 
			local _sp1 = cc.Sprite:create("res/image/common/titlepattern_left.png") 
			_sp1:setAnchorPoint(cc.p(1, 0.5))
			_sp1:setPosition(_sp0:getPositionX() - _sp0:getContentSize().width*0.5 - 1, _sp0:getPositionY())
			bg_sp:addChild(_sp1)
			local _sp2 = cc.Sprite:create("res/image/common/titlepattern_right.png") 
			_sp2:setAnchorPoint(cc.p(0, 0.5))
			_sp2:setPosition(_sp0:getPositionX() + _sp0:getContentSize().width*0.5 + 1, _sp0:getPositionY())
			bg_sp:addChild(_sp2)
		else
			title_sp = cc.Sprite:create("res/image/tmpbattle/result_faild.png")
	    	effVoice = XTHD.resource.music.effect_battle_lost

			local _sp0 = cc.Sprite:create("res/image/daily_task/escort_task/overShow1.png")
			bg_sp:addChild(_sp0)
			_sp0:setAnchorPoint(cc.p(0.5, 0))
			_sp0:setPosition(bg_sp:getContentSize().width*0.5 - 210, bg_sp:getContentSize().height - 208) 

			local item_name_label = XTHDLabel:createWithParams({
	            text = LANGUAGE_KEY_ZHUREN,
	            anchor = cc.p(0, 0.5),
	            fontSize = 22,--字体大小
	            color = cc.c3b(225, 152, 102),
	            pos = cc.p(bg_sp:getContentSize().width*0.5 - 80, bg_sp:getContentSize().height - 130),
	        })
	        bg_sp:addChild(item_name_label)
			item_name_label = XTHDLabel:createWithParams({
	            text = LANGUAGE_KEY_BUYAOQINEI, --items_info["name"],
	            anchor = cc.p(0, 0.5),
	            fontSize = 22,--字体大小
	            color = cc.c3b(225, 152, 102),
	            pos = cc.p(bg_sp:getContentSize().width*0.5 - 80, bg_sp:getContentSize().height - 170),
	        })
	        bg_sp:addChild(item_name_label)
		end  
		if effVoice then
	        musicManager.playEffect(effVoice, false)
	    end
	    if title_sp then
	    	title_sp:setPosition(bg_sp:getContentSize().width*0.5, bg_sp:getContentSize().height)
			bg_sp:addChild(title_sp)

			self._hurt_data = {}
		    self._hurt_data["afurts"] = params["afurts"]
		    self._hurt_data["bfurts"] = params["bfurts"]
			local function _touchEnd( ... )
				local pop = requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoShowHurtLayer.lua"):create(self._hurt_data,self.battleType)
        		self:addChild(pop)
			end

			local _bt = XTHD.createButton({
				normalFile = "res/image/daily_task/escort_task/overShow2.png",
				touchScale = 0.95,
				anchor = cc.p(0.5, 1),
				pos = cc.p(bg_sp:getContentSize().width*0.5 + 200, bg_sp:getContentSize().height - 10),
				endCallback = _touchEnd,
			})
			bg_sp:addChild(_bt)
		end		
	end 
	--
	if params.playerProperty then
		self:UpdateLordData(params.playerProperty)
	end	
 	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ESCORT_LAYER}) 
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) 
    if self.battleType == BattleType.GUILD_BOSS_PVE then
        local mDatas = BangPaiFengZhuangShuJu.getGuildData()
        if mDatas.list and #mDatas.list > 0 then
            for k,v in pairs(mDatas.list) do
                if v.charId == gameUser.getUserId() then
                    v.dayContribution = tonumber(self._battle_data.dayContribution) or 0
                    v.totalContribution = tonumber(self._battle_data.totalContribution) or 0
                    break
                end
            end
        end
        BangPaiFengZhuangShuJu.setGuildData(mDatas)
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
    elseif self.battleType == BattleType.CAMP_SHOUWEI then
        --刷新种族守卫界面的数据
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ZHONGZU_SHOUWEI})
    end
end

function ZhanDouJieGuoWorldBossLayer:itemData(params)
	local fall_items={}
	if params["addBounty"] and tonumber(params["addBounty"])>=1 then 
        fall_items[#fall_items + 1] =  {
            ["_type_"] = XTHD.resource.type.bounty,
            ["count"] =params["addBounty"],
        }
    end
    if params["addFeicui"] and tonumber(params["addFeicui"])>=1 then 
        fall_items[#fall_items + 1] =  {
            ["_type_"] = XTHD.resource.type.feicui,
            ["count"] =params["addFeicui"],
        }
    end
    if params["addIngot"] and tonumber(params["addIngot"])>=1 then 
        fall_items[#fall_items + 1] =  {
            ["_type_"] = XTHD.resource.type.ingot,
            ["count"] =params["addIngot"],
        }
    end
    if params["addSilver"] and tonumber(params["addSilver"])>=1 then 
        fall_items[#fall_items + 1] =  {
            ["_type_"] = XTHD.resource.type.gold,
            ["count"] =params["addSilver"],
        }
    end
    if params["addContribution"] and tonumber(params["addContribution"])>=1 then 
        fall_items[#fall_items + 1] =  {
            ["_type_"] = XTHD.resource.type.guild_contri,
            ["count"] =params["addContribution"],
        }
    end
    if params["addRenown"] and params["addRenown"] > 0 then
        fall_items[#fall_items + 1] = {
            ["_type_"] = XTHD.resource.type.reputation,
            ["isShowCount"] = true,
            ["count"] = params["addRenown"]
        }
    end

    if params["addItem"] and #params["addItem"] > 0 then
    	for i=1, #params["addItem"] do
            local pD = string.split(params["addItem"][i],",")
            -- local item_info = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=pD[1]})
            fall_items[#fall_items + 1] = {
				["_type_"] = XTHD.resource.type.item,
            	["count"] = pD[2],
            	["itemId"] = pD[1], 
            }
        end
    end
    if params["items"] and #params["items"] > 0 then
    	for i=1, #params["items"] do
    		local _data = params["items"][i]
            local pD = string.split(_data, ",")
            fall_items[#fall_items + 1] = {
				["_type_"] = XTHD.resource.type.item,
            	["count"] = pD[2],
            	["itemId"] = pD[1], 
            }
        end
    end
    if params and params.bagItems then
        for i=1,#params.bagItems do
           DBTableItem.updateCount(gameUser.getUserId(),params.bagItems[i], params.bagItems[i]["dbId"])
        end
	end
	if self.battleType == BattleType.PVP_CUTGOODS  then
    	self._battle_data.allPets = self._battle_data.allPets or {}
        if #self._battle_data.allPets > 0 then
            for i=1,#self._battle_data.allPets do
                local hero_data = self._battle_data.pet[tostring(self._battle_data.allPets[i])]
                if hero_data and hero_data["property"] then
			        for i=1,#hero_data["property"] do
			            local pro_data = string.split( hero_data[i],',')
			            DBUpdateFunc:UpdateProperty( "userheros", pro_data[1], pro_data[2], self._battle_data.allPets[i])
			        end
                end
            end
        end
	end 
	self.drop_data = fall_items
end
function ZhanDouJieGuoWorldBossLayer:createItem()
	local pos_table=SortPos:sortFromMiddle( cc.p(self.bg_sp:getContentSize().width/2,self.bg_sp:getContentSize().height/2), tonumber(#self.drop_data), 100 )
	for i,var in ipairs(self.drop_data) do
		local item_bg=nil
		local item_bg = ItemNode:createWithParams({
				needSwallow = true,
				_type_ =tonumber(var["_type_"]),
				count=tonumber(var["count"]),
				itemId=tonumber(var["itemId"]) or 1
			})	
		item_bg:setScale(0.9)
		item_bg:setPosition(pos_table[i])
		self.bg_sp:addChild(item_bg)
		local item_name_label = XTHDLabel:createWithParams({
            text = item_bg._Name, --items_info["name"],
            anchor=cc.p(0.5,1),
            fontSize = 18,--字体大小
            -- color = cc.c3b(74,34,34),
            pos = cc.p(item_bg:getContentSize().width/2,-2),
        })
        item_bg:addChild(item_name_label)
	end

end

function ZhanDouJieGuoWorldBossLayer:freshLevelInfo()
	 ClientHttp:requestAsyncInGameWithParams({
        modules="ectypeSingleRecord?",
        successCallback = function( data )
            -- print("单挑之王服务器返回的数据为：")
            -- print_r(data)
            if tonumber( data.result ) == 0 then
                gameUser.setNormalChallenge(data.ectypeRecord["1"])
			    gameUser.setDiffChallenge(data.ectypeRecord["2"])
			    gameUser.setNightChallenge(data.ectypeRecord["3"])
			    gameUser.setPurChallenge(data.ectypeRecord["4"])
			    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_SINGLECHALLENGE})
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    })  
end

function ZhanDouJieGuoWorldBossLayer:UpdateLordData(playerProperty)
    --更新玩家基本数据
    if playerProperty then
        for i=1,#playerProperty do
            local pro_data = string.split( playerProperty[i],',')
            DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2])
        end
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
end

function ZhanDouJieGuoWorldBossLayer:create(params)
	self.bossdata=params.bossdata
	self._backCallback = params.backCallback
	local dialog = self.new(params)
	 return dialog
end

function ZhanDouJieGuoWorldBossLayer:onEnter( )
end



return ZhanDouJieGuoWorldBossLayer
