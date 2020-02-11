local TAG = "XuanZeYingXiongNewLayer"
--重构，希望能够浴火重生
--[[
	1.self.m_heroItem 只存放全部选中的数据，不再在判断是否选中的时候进行数据的添加和删除操作，仅仅是判断而已 \(^o^)/~
	2.cell内部的点击方法摘出来，在里面太乱，而且改起来越来感觉越乱，有点hold不住，(⊙o⊙)
	3.此次重构，旨在把基础UI,数据构建，数据筛选分割开来，希望能够把逻辑梳理清晰，不要再给编者，维护者、潜在的查看着造成过多的困惑 ^_^
]]
local XuanZeYingXiongNewLayer = class("XuanZeYingXiongNewLayer", function()
	return XTHDDialog:create()
end)
local cclog = function(...)
    print(string.format(...))
end

function XuanZeYingXiongNewLayer:onEnter()
	musicManager.playMusic(XTHD.resource.music.effect_seleceteHero_bgm )
end

function XuanZeYingXiongNewLayer:onExit()
	LayerManager.removeChatRoom(LiaoTianRoomLayer.Functions.Camp)
end

function XuanZeYingXiongNewLayer:ctor()
	--存放已经选择的英雄
	self._effSoundTb = {}
	self._user_data = {}
	self.m_heroItem = {} 
	self._groupbtnList = {}
	self:setColor(cc.c3b(0,0,0))
	self:setOpacity(150)
	self._total_power = 0 --标记战斗力总值，进入界面之后，如果有预设队伍，则战斗力label需要有初始值，或者PVP模式3个队伍切换的时候，需要这个值来标记总战斗力
	self._Spine_List={} --存放所有的spine
	self._canSelectedHeros = {} -----能够选择的英雄们
	self._challengeActionPause = false
end

function XuanZeYingXiongNewLayer:selfDestroy( needCall )
	for k,v in pairs(self._effSoundTb) do
		local _id = tonumber(k) or 0
		self:playSoundEffect(_id)
	end
	self._challengeActionPause = true
	if not needCall then
		cc.Director:getInstance():popScene()
		self:cleanTexture()
		XTHD.dispatchEvent({name = "REMOVE_UNUSED_SPINES"})
	else
		self:removeFromParent()
	end
end

function XuanZeYingXiongNewLayer:cleanTexture( ... )
    local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey(self._bg_imgpath)
	textureCache:removeTextureForKey("res/image/imgSelHero/x_44.png")
	textureCache:removeTextureForKey("res/image/imgSelHero/x_40.png")
    textureCache:removeTextureForKey("res/spine/effect/bossBackEff/haidi.png")
    textureCache:removeTextureForKey("res/image/imgSelHero/target_back.png")
    textureCache:removeTextureForKey("res/image/imgSelHero/taget_cell.png")
    helper.collectMemory()
end

function XuanZeYingXiongNewLayer:init( ... )	
	self._selectData = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongDatas.lua")
	self._selectData.init(self)


    -- 返回按钮
    local _btnBack
    local function endCallback()
		-- if _btnBack then
		-- 	_btnBack:setTouchEndedCallback(nil)
		-- end
		if self._battle_type == BattleType.PVP_CHALLENGE or self._battle_type == BattleType.PVP_LADDER or self._battle_type == BattleType.PVP_DEFENCE or self._battle_type == BattleType.PVP_LADDER_DEFENCE then
			self._challengeActionPause = true
			local _confirmLayer = XTHDConfirmDialog:createWithParams( {
	            rightCallback  = function ()
		            self:SaveAttackTeamInfo()--更新队伍信息
		            performWithDelay(self,function()
		            	self:selfDestroy()
						musicManager.playMusic(XTHD.resource.music.music_bgm_main )
	            	end ,0.2)
	            end,
	            closeCallback = function ( ... )
	            	self._challengeActionPause = false
	            end,
	            msg = LANGUAGE_TIPS_WORDS166,---------"是否要中断这次挑战，返回竞技场主界面？"
	        } );
	        self:addChild(_confirmLayer,3)
		else
			self:SaveAttackTeamInfo()--更新队伍信息
        	self:selfDestroy()
			musicManager.playMusic(XTHD.resource.music.music_bgm_main )
		end
	end
	_btnBack = XTHD.createNewBackBtn(endCallback)
	self:addChild(_btnBack,3)

    --背景图的选取当前章节的第一个背景图，富有衔接感 嗯哼 →_→ �
    local bg_imgpath = self._selectData.getBackFileStr()
	local bg_sp = cc.Sprite:create(bg_imgpath)
	bg_sp:setContentSize(self:getContentSize())
	self._bg_imgpath = bg_imgpath
	bg_sp:setName("bg_sp")
	bg_sp:setPosition(self:getContentSize().width*0.5 , self:getContentSize().height*0.5)-- - TopBarLayer1:getContentSize().height-10)
	self:addChild(bg_sp)
	self._bg_sp = bg_sp
	if bg_imgpath == "res/image/background/bg_53.jpg" then
		local __sp = sp.SkeletonAnimation:create("res/spine/effect/bossBackEff/haidi.json", "res/spine/effect/bossBackEff/haidi.atlas", 1.0)
	    local pos = cc.p(bg_sp:getContentSize().width*0.5, bg_sp:getContentSize().height*0.5)
	    __sp:setPosition(pos)
	    bg_sp:addChild(__sp)
	    __sp:setAnimation(0, "animation", true)
	end

	if self._battle_type == BattleType.MULTICOPY_DEFENCE then
	  	local tipDi = cc.Sprite:create("res/image/imgSelHero/x_40.png")
		tipDi:setAnchorPoint(0.5, 0.5)
		tipDi:setPosition(self:getContentSize().width*0.5, self:getContentSize().height - 30)
		self:addChild(tipDi,2)
		local limit_sp = cc.Sprite:create("res/image/imgSelHero/hero_num_limit.png")
		limit_sp:setAnchorPoint(0.7,0.5)
		limit_sp:setPosition(self:getContentSize().width*0.5, self:getContentSize().height-30)
		self:addChild(limit_sp,2)

		local count_label = getCommonWhiteBMFontLabel(self._hero_num_limit)
		count_label:setAnchorPoint(0,0.5)
		count_label:setPosition(limit_sp:getPositionX()+limit_sp:getContentSize().width*0.3, limit_sp:getPositionY()-7)
		self:addChild(count_label,limit_sp:getLocalZOrder())
	end

	self:initStartBtn()
end

function XuanZeYingXiongNewLayer:initStartBtn( ... )
	--开始战斗
	if self._battle_type == BattleType.PVP_DEFENCE 
		or self._battle_type == BattleType.CAMP_DEFENCE 
		or self._battle_type == BattleType.PVP_LADDER_DEFENCE 
		or self._battle_type == BattleType.PVP_DART_DEFENCE
		or self._battle_type == BattleType.ZHENQI_DEFENCE
		or self._battle_type == BattleType.GUILDWAR_TEAM
		or self._battle_type == BattleType.MULTICOPY_DEFENCE then
		self._start_battle_btn = XTHDPushButton:createWithParams({
				normalNode    = cc.Sprite:create("res/image/imgSelHero/save_normal.png"),
				selectedNode  =  cc.Sprite:create("res/image/imgSelHero/save_selected.png"),
				musicFile = "res/sound/battleStart.mp3",
			})
		self._start_battle_btn:setPosition(self:getContentSize().width-self._start_battle_btn:getContentSize().width*0.5-32, self:getContentSize().height*0.5)
		self:addChild(self._start_battle_btn)
		if self._battle_type ~= BattleType.PVP_DART_DEFENCE 
		   and self._battle_type ~= BattleType.ZHENQI_DEFENCE
		   and self._battle_type ~= BattleType.MULTICOPY_DEFENCE then
			local tipDi = cc.Sprite:create("res/image/imgSelHero/x_40.png")
			tipDi:setAnchorPoint(0.5, 1)
			tipDi:setPosition(self:getContentSize().width*0.5, self:getContentSize().height)
			self:addChild(tipDi,2)

			local tipSp = cc.Sprite:create("res/image/imgSelHero/x_44.png")
			tipSp:setPosition(tipDi:getContentSize().width*0.5, tipDi:getContentSize().height*0.5)
			tipDi:addChild(tipSp)
		end

	else
		self._start_battle_btn, self._battle_effect = XTHD.createFightBtn({
	    	par = self,
	    	pos = cc.p(self:getContentSize().width - 90, self:getContentSize().height*0.5),
	    	zorder2 = 2
		})
		self._battle_effect:setVisible(false)
	end
	self._start_battle_btn:setVisible(false)
	
	self._start_battle_btn:setTouchBeganCallback(function()
		self._start_battle_btn:setScale(0.98)
		if self._battle_effect then
			self._battle_effect:setScale(0.98)
		end
	end)
	
	self._start_battle_btn:setTouchMovedCallback(function()
		self._start_battle_btn:setScale(1)
		if self._battle_effect then
			self._battle_effect:setScale(1)
		end
	end)
	
	self._start_battle_btn:setTouchEndedCallback(function()
		self._start_battle_btn:setScale(1)
		if self._battle_effect then
			self._battle_effect:setScale(1)
		end
		self:addShieldLayout()
		-- musicManager.playEffect("res/sound/battleStart.mp3")
	    ----引导 
	    YinDaoMarg:getInstance():guideTouchEnd()
	    YinDaoMarg:getInstance():releaseGuideLayer()
	    ------------------
		if self._battle_type == BattleType.PVP_DEFENCE 
			or self._battle_type == BattleType.CAMP_DEFENCE 
			or self._battle_type == BattleType.PVP_LADDER_DEFENCE 
			or self._battle_type == BattleType.PVP_DART_DEFENCE 
			or self._battle_type == BattleType.ZHENQI_DEFENCE
			or self._battle_type == BattleType.GUILDWAR_TEAM
			or self._battle_type == BattleType.MULTICOPY_DEFENCE then
			self:SavaDefenceTeamInfo()
		else
			local function star_battle()
				self:SaveAttackTeamInfo()
				if self._battle_type == BattleType.PVE 
					or self._battle_type == BattleType.ELITE_PVE 
					or self._battle_type == BattleType.DIFFCULTY_COPY then
					self:BattleClickCallback(self._instancingid)
				elseif self._battle_type == BattleType.PVP_CHALLENGE 
					or self._battle_type == BattleType.CAMP_PVP 
					or self._battle_type == BattleType.PVP_LADDER
					or self._battle_type == BattleType.PVP_FRIEND 
					or self._battle_type == BattleType.PVP_CUTGOODS 
					or self._battle_type == BattleType.CASTELLAN_FIGHT 
					or self._battle_type == BattleType.CAMP_TEAMCOMPARE 
					or self._battle_type == BattleType.ZHENQI_FIGHT_ROB 
					or self._battle_type == BattleType.ZHENQI_FIGHT_OCCUPY 
					then
					self:BattleClickCallback(self._instancingid)
				end
			end
			if self._selectData.haveCanOnTeam() then
				self:showTipDialog(star_battle)
			else
				star_battle()
			end
		end
	end)
	self:createMemberBar()
end

function XuanZeYingXiongNewLayer:createMemberBar( ... )
	local bg_sp = self._bg_sp

	local list_bg_sp = ccui.Scale9Sprite:create("res/image/common/scale9_bg_20.png")
	list_bg_sp:setContentSize(cc.size(self:getContentSize().width, 110))
	list_bg_sp:setName("list_bg_sp")
	self._list_bg_sp = list_bg_sp
	list_bg_sp:setAnchorPoint(0.5,0)
	list_bg_sp:setPosition(self:getContentSize().width*0.5,0)
	self:addChild(list_bg_sp)

	
	--[[总战斗力 ,虽然我很不喜欢这个名字，但是还是先用着吧，等下全局替换之 O(∩_∩)O~
		之所以把总战力label生命在前面，是因为，后面切换按钮状态的时候，有些数据的展示，需要用到这个label
	]]
	self._battle_power_label = cc.Sprite:create("res/image/common/fightValue_Image.png")
	self._battle_power_label:setCascadeOpacityEnabled(true)
	self._battle_power_label:setVisible(false)
	self._battle_power_label:setAnchorPoint(0,0.5)
	
	self.m_labTotalCombatData = getCommonYellowBMFontLabel(self._total_power) 
	self.m_labTotalCombatData:setVisible(false)
	self.m_labTotalCombatData:setScale(1.5)
	self.m_labTotalCombatData:setAnchorPoint(cc.p(0, 0.5))
	self.m_labTotalCombatData:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1),1)


	self._battle_power_label:setPosition( 64, list_bg_sp:getContentSize().height + self._battle_power_label:getContentSize().width*0.5 + 5)
	self.m_labTotalCombatData:setPosition(self._battle_power_label:getPositionX() + self._battle_power_label:getContentSize().width + 5, self._battle_power_label:getPositionY() - 9)
	list_bg_sp:addChild(self._battle_power_label)	
	list_bg_sp:addChild(self.m_labTotalCombatData)
	self:ChangeBtnStatusAndRefreshData(nil,"right")

	--如果是PVP模式，则需要添加分队按钮，^_^
	if self._battle_type ~= BattleType.PVE 
		and self._battle_type ~= BattleType.ELITE_PVE 
		and self._battle_type ~= BattleType.DIFFCULTY_COPY then	

		if self._battle_type ~= BattleType.PVP_DEFENCE 
			and self._battle_type ~= BattleType.CAMP_DEFENCE 
			and self._battle_type ~= BattleType.PVP_LADDER_DEFENCE 
			and self._battle_type ~= BattleType.GUILDWAR_TEAM
			and self._battle_type ~= BattleType.PVP_DART_DEFENCE
			and self._battle_type ~= BattleType.ZHENQI_DEFENCE
			and self._battle_type ~= BattleType.MULTICOPY_DEFENCE 
			and self._battle_type ~= BattleType.CASTELLAN_FIGHT then
			self._enemy_team_bg	 = ccui.Scale9Sprite:create(cc.rect(15,15,1,1),"res/image/common/common_scalebg_1.png")
			self._enemy_team_bg:setContentSize(380,75) 
			self._enemy_team_bg:setAnchorPoint(1,1)
			self._enemy_team_bg:setPosition(self:getContentSize().width-15-85, self:getContentSize().height-7)
			self:addChild(self._enemy_team_bg)

			local enemy_sp_bg = cc.Sprite:create("res/image/imgSelHero/enemy_txt_bg.png") -- 
			enemy_sp_bg:setAnchorPoint(1,1)
			enemy_sp_bg:setPosition(self._enemy_team_bg:getPositionX() - self._enemy_team_bg:getContentSize().width,self._enemy_team_bg:getPositionY()-5)
			self:addChild(enemy_sp_bg,2)

			local _txt = XTHDLabel:createWithParams({
					text = LANGUAGE_SPECAIL_WORD1,-------"敌\n方",
				    fontSize = 22,--字体大小
				    color = cc.c3b(240, 240, 240),
				    pos = cc.p(enemy_sp_bg:getContentSize().width*0.5,enemy_sp_bg:getContentSize().height*0.5)
				})
			enemy_sp_bg:addChild(_txt)
		end
		
		--一队，二队，三队
		self._target_teamIndex = self._target_teamIndex or 1
		if self._battle_type == BattleType.CAMP_DEFENCE or self._battle_type == BattleType.GUILDWAR_TEAM then
			--背景框 
			local bg_kuang = cc.Sprite:create("res/image/imgSelHero/target_back.png")
			bg_kuang:setPosition(20,self:getContentSize().height-60)
			bg_kuang:setAnchorPoint(0,1)
			self:addChild(bg_kuang)
			
			local team_tab = {0, 45, 60}
			for i=1, 3 do
				local team_btn = XTHD.createButton({
					normalNode = cc.Sprite:create("res/image/imgSelHero/campuse/image_selectBack.png"),  
					selectedNode = cc.Sprite:create("res/image/imgSelHero/campuse/image_selectBack.png"),
					btnSize = cc.size(326,58),
					anchor = cc.p(0, 0.5),
					pos = cc.p(22, self:getContentSize().height - 100 - (i-1)*65),
				})
				team_btn:setName("team_btn" .. tostring(i))
				team_btn:setTag(i)
				self._groupbtnList[#self._groupbtnList + 1] = team_btn
				-- self:getCompositeNodeAsIWant(i, team_btn)
				if i == self._target_teamIndex then
					self:ChangeBtnStatusAndRefreshData(team_btn, "team")
				end
				team_btn:setTouchEndedCallback(function()
--					for i = 1
--					if self._battle_type == BattleType.GUILDWAR_TEAM then
--						local _json_tab = {}
--						for i = 1,#self._PVP_Teams do 				
--							local _tab = {}
--							_tab.teamId = i	
--							_tab.petIds = {}
--							for j = 1,#self._PVP_Teams[i][1] do 
--								_tab.petIds[#_tab.petIds + 1] = self._PVP_Teams[i][1][j].heroid
--							end 
--							_json_tab[#_json_tab +1] =_tab
--						end 
--						_json_tab = json.encode(_json_tab)
--						ClientHttp.httpGuildSetDefenceGroup(self, function(net_data)
--        					self:ChangeBtnStatusAndRefreshData(team_btn,"team")
--							XTHD.dispatchEvent({name = REFRESH_GUILDBATTLEGROUP})
--						end, {list = _json_tab})
--					else
						self:ChangeBtnStatusAndRefreshData(team_btn,"team")
					--end
				end)
				self:addChild(team_btn, 2)
				local pData = self._PVP_Teams[i][1]
				team_btn._teamSp = cc.Sprite:create("res/image/imgSelHero/campuse/img_unselect_" .. i ..".png")
				team_btn._teamSp:setPosition(cc.p(20, team_btn:getContentSize().height*0.5))
				team_btn:addChild(team_btn._teamSp, 2)
			end
		else
			self:RefreshEnemyTeamData(true)
		end
		

		if self._battle_type == BattleType.PVP_DART_DEFENCE 
		  or self._battle_type == BattleType.ZHENQI_DEFENCE then
			local tipDi = cc.Sprite:create("res/image/imgSelHero/x_40.png")
			tipDi:setAnchorPoint(0.5, 0.5)
			tipDi:setPosition(self:getContentSize().width*0.5, self:getContentSize().height - 25)
			self:addChild(tipDi,2)

			local sp = cc.Sprite:create("res/image/imgSelHero/target_back.png")
			self:addChild(sp)
			sp:setScale(0.8)
			sp:setAnchorPoint(0, 1)
			sp:setPosition(cc.p(20, self:getContentSize().height - 60))
			local TitleLabel = XTHDLabel:create("满足所有条件，奖励翻倍",26)
			TitleLabel:setAnchorPoint(0.5,0.5)
			TitleLabel:setPosition(sp:getContentSize().width/2,sp:getContentSize().height-TitleLabel:getContentSize().height/2)
			sp:addChild(TitleLabel)
			local _size = sp:getContentSize()
			self._dartConditionStrings = {}
			-- self._dartConditionOver = {}
			local _have
			for i=1, 4 do
				local pNum = tonumber(self._conditionTable[i]) or 0
				if pNum ~= 0 then
					if i == 4 then
						-- local _data = gameData.getDataFromCSV("GeneralInfoList", {["heroid"]=pNum})
						-- pNum = _data.name
						break
					end
					_have = true
					-- local pDi = cc.Sprite:create("res/image/imgSelHero/taget_cell.png")
		            -- pDi:setAnchorPoint(cc.p(0, 0.5))
		            -- pDi:setPosition(cc.p(0, _size.height - 60 - (i-1)*30))
					-- sp:addChild(pDi)
					local lable = XTHDLabel:createWithParams({
		            	text = LANGUAGE_TASKNEED[i] .. pNum,
		                fontSize = 24,--字体大小
		                anchor = cc.p(0, 0.5),
		                pos = cc.p(10, _size.height - 60 - (i-1)*30)
		            })
		            sp:addChild(lable)
					self._dartConditionStrings[i] = lable
				end
			end
			if not _have then
				sp:setVisible(false)
			end
			self:_freshDartBarInfo()
		end

		self:refreshTeamMenberCount()
	end

	self:addHeroHeads()

	self._challengeAction = nil

	local function preloadAni( id , isStr)
		local nId = self._selectData.getAniId(id)
		local p = sp.SkeletonAnimation:createWithBinaryFile("res/spine/" .. nId .. ".skel", "res/spine/" .. nId .. ".atlas", 1)
		if (isStr) then
			p:setPosition(-1000,-1000)
			self:addChild(p)
		end
		return p
	end
	if cc.PLATFORM_OS_ANDROID == ZC_targetPlatform then
		if(#self._totalHeroData > 0) then
			preloadAni(self._totalHeroData[1].heroid,true)
		end
	end

	if #self._heroIdCacheTb == 0 then
		self:addAutoGo()
	else
		local pLay = XTHD.createLayer()
		pLay:setTouchEnabled(true)
		pLay:registerScriptTouchHandler(function ( eventType, x, y )
			if (eventType == "began") then
				return true
			end
		end)
		self:addChild(pLay, 100)
		local loading_label = XTHDLabel:create(LANGUAGE_KEY_LOADINGWAIT.."...",20)--------正在加载资源，请稍后...",20)
		loading_label:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5 - 90)
		self:addChild(loading_label,100)
		local count = 1
		local function addGuide( ... )
			loading_label:removeFromParent()
			loading_label = nil
			pLay:removeFromParent()
			pLay = nil
			self:addAutoGo()
			-------------引导,指引开战按钮
            local pos = self._start_battle_btn:convertToWorldSpace(cc.p(0,0))
            if YinDaoMarg:getInstance():getCurrentGuideLayer() then 
                YinDaoMarg:getInstance():getCurrentGuideLayer():refreshHand(pos)
            end
	        ------------------------
		end

		local aniList = {}
		local function prefreshAni( ... )
			local _heroId = self._heroIdCacheTb[count].id
			if not self._selectData.isNewHelps(_heroId) then
				local _data = self._heroIdCacheTb[count].data
				local pB = #self._heroIdCacheTb ~= 1
				local tmpData = {heroid = _heroId, isInit = pB, sData = _data, _spine = aniList[count]}
				self:RefreshSpine(tmpData)
			end
			count = count + 1
			if count > #self._heroIdCacheTb then
				aniList = nil
				performWithDelay(self, addGuide, 0.2)
			else
				performWithDelay(self, prefreshAni, 0.05)
			end
		end

		local function preSpine( ... )
			for i = 1, #self._heroIdCacheTb do
				local _heroId = self._heroIdCacheTb[i].id
				if not self._selectData.isNewHelps(_heroId) then
					aniList[i] = preloadAni(_heroId)
					local _data = self._heroIdCacheTb[i].data
					local pAni = createAnimal({id = _heroId, _type = ANIMAL_TYPE.PLAYER, helps = _data})
					if pAni == nil then
						return
					end
					if pAni then
						pAni:_unregisterSpineEventHandler()
					end
				end
			end
			performWithDelay(self, prefreshAni, 0.01)
		end
		performWithDelay(self, preSpine, 0.01)
	end
end

function XuanZeYingXiongNewLayer:addAutoGo( ... )
	if self._battle_type == BattleType.PVP_CHALLENGE or self._battle_type == BattleType.PVP_LADDER then
		local pCount = 45

		local id_txt = getCommonWhiteBMFontLabel(pCount)
	    id_txt:setAnchorPoint(0, 0.5)
	    id_txt:setPosition(50, self:getContentSize().height - id_txt:getContentSize().height)
	    self:addChild(id_txt, 3)

	    local countStr = cc.Sprite:create("res/image/plugin/competitive_layer/count_down_str.png")
		countStr:setAnchorPoint(cc.p(0, 0.5))
	    countStr:setPosition(id_txt:getPositionX() + id_txt:getBoundingBox().width + 5 , id_txt:getPositionY() + 7)
	    self:addChild(countStr, 3)

		local function updateTime( ... )
			if self._challengeActionPause then
				return
			end
			pCount = pCount - 0.1
			if pCount <= 0 then
				self:stopAction(self._challengeAction)

				local function checkCanAdd( ... )
					local pNum1 = tonumber(#self._PVP_Teams[self._current_Team_num][1]) or 0
					local pNum2 = tonumber(#self.m_heroItem) or 0
					if (pNum1 >= 5 or pNum2 >= 15) then
						return false
					end
					return true
				end
					
				for i = 1, #self._data_source do
					if(not checkCanAdd()) then
		   				break
		   			end
					local temp_data = self._data_source[i]
		   			local _bSel = self:_bTheItemIsSelect(temp_data) --判断当前数据是否在已经选中的英雄或者道具列表中
		   			if not _bSel then
		   				self:AddOrRemoveData(temp_data,false)
		   			end
				end
				self:BattleClickCallback()
				return
			end
			local pNum = math.modf(pCount)
			id_txt:setString(getCdStringWithNumber(pNum,{h = ":"}))
		end
		self._challengeActionPause = false
		self._challengeAction = schedule(self, updateTime, 0.1)
	end
	helper.collectMemory()
	----------------引导 
	self:addGuide()
	------------------------------	
end

function XuanZeYingXiongNewLayer:addHeroHeads( ... )

	local bg_sp = self._bg_sp
	local list_bg_sp =self:getChildByName("list_bg_sp")

	local pStartX = (self:getContentSize().width - 800)*0.5
	
	self.m_tableView = cc.TableView:create(cc.size(800 - 20, list_bg_sp:getContentSize().height))
    TableViewPlug.init(self.m_tableView)
	self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);
	self.m_tableView:setBounceable(true)
	self.m_tableView:setPosition(cc.p(pStartX + 10,0));
	self.m_tableView:setDelegate();
	list_bg_sp:addChild(self.m_tableView);

	local arrow_left_sp = XTHDImage:create("res/image/plugin/stageChapter/btn_left_arrow.png")
	arrow_left_sp:setPosition(pStartX-20, self.m_tableView:getPositionY() + self.m_tableView:getViewSize().height*0.5)
	arrow_left_sp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.8,cc.p(-10,0)),cc.MoveBy:create(0.8,cc.p(10,0)))))
	list_bg_sp:addChild(arrow_left_sp)

	local arrow_right_sp = XTHDImage:create("res/image/plugin/stageChapter/btn_right_arrow.png")
	arrow_right_sp:setPosition(list_bg_sp:getContentSize().width - pStartX+20,arrow_left_sp:getPositionY())
	arrow_right_sp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.8,cc.p(10,0)),cc.MoveBy:create(0.8,cc.p(-10,0)))))
	list_bg_sp:addChild(arrow_right_sp)
	-- 注册事件
	local function numberOfCellsInTableView( table )
		return self:numberOfCellsInTableView( table );
	end
	local function cellSizeForTable( table, idx )
		return self:cellSizeForTable( table, idx )
	end
	local function tableCellAtIndex( table, idx )
		return self:tableCellAtIndex( table, idx )
	end
    
    self.m_tableView.getCellNumbers = numberOfCellsInTableView
    self.m_tableView.getCellSize = cellSizeForTable
	local function scrollToPage(flag)
        local currPage = self.m_tableView:getCurrentPage()
        if flag == "left" then
            if currPage > 0 then
                self.m_tableView:scrollToCell(currPage - 1,true)
            end
        else
            if currPage < self:numberOfCellsInTableView(self.m_tableView)-1 then
                self.m_tableView:scrollToCell(currPage + 1,true)
            end
        end
    end

    arrow_left_sp:setTouchEndedCallback(function()
          scrollToPage("left")
    end)

    arrow_right_sp:setTouchEndedCallback(function()
          scrollToPage("right")
    end)

	self.m_tableView.currentPageIndex = self.m_tableView:getCurrentPage()
	self.m_tableView:registerScriptHandler(function (view)
		local offsetx = self.m_tableView:getContentOffset().x
		local _ ,cell_width = self:cellSizeForTable(self.m_tableView)
		local offsetx2 = self.m_tableView:getContentOffset().x + self:numberOfCellsInTableView(self.m_tableView)*cell_width -self.m_tableView:getViewSize().width
	    if self:numberOfCellsInTableView(self.m_tableView)*cell_width <= self.m_tableView:getViewSize().width then
	    	--如果所有cell都显示出来，
	    	arrow_left_sp:setVisible(false)
	        arrow_right_sp:setVisible(false)
	    else
	    	--否则，根据偏移量来判断引导箭头的隐现
	    	 if offsetx > 0 then
	        	arrow_left_sp:setVisible(false)
	        elseif offsetx2 <=0  then
	        	arrow_right_sp:setVisible(false)
	        else
	        	arrow_left_sp:setVisible(true)
	        	arrow_right_sp:setVisible(true)
	        end
	    end	   
	end,cc.SCROLLVIEW_SCRIPT_SCROLL)

	self.m_tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    self.m_tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self.m_tableView:reloadData()
    if self._target_cellIndex and self._target_cellIndex>1 then
    	self.m_tableView:scrollToCell(self._target_cellIndex-1)
    end  
end

--PVP模式下，队伍间人物切换时，刷新按钮上的显示
function XuanZeYingXiongNewLayer:refreshTeamMenberCount(sNum)
	if self._battle_type ~= BattleType.CAMP_DEFENCE and self._battle_type ~= BattleType.GUILDWAR_TEAM then
		return
	end
	local function freshTeamBtn( i )
		local team_btn = self:getChildByName("team_btn"..tostring(i))
		if not team_btn then
			return
		end
		if team_btn._memberNode then
			team_btn._memberNode:removeFromParent()
			team_btn._memberNode = nil
		end
		local _memberNode = cc.Node:create()
		_memberNode:setPosition(50, team_btn:getContentSize().height*0.5)
		team_btn:addChild(_memberNode)
		team_btn._memberNode = _memberNode
		local team = self._PVP_Teams[i][1]
		for j=1, 5 do
			local _data = team[j]
			local sp
			if _data then
				sp = HeroNode:createWithParams({
					heroid = _data.heroid,
					isShowType = true,
					advance = _data.advance
				})
				sp:setScale(0.5)
			else
				sp = cc.Sprite:create("res/image/imgSelHero/campuse/img_empty.png")
			end
			if sp then
				sp:setPosition(15 + 50*(j-1),0)
				_memberNode:addChild(sp)

				if _data and i ~= self._current_Team_num then
					local m_tick = cc.Sprite:create("res/image/imgSelHero/campuse/img_markTick.png")
					m_tick:setPosition(cc.p(sp:getContentSize().width*0.5, sp:getContentSize().height*0.5))
					sp:addChild(m_tick)
				end
			end
		end
	end
	-- local pNum = tonumber(sNum)
	-- if pNum then
	-- 	freshTeamBtn(pNum)
	-- else
		for i=1, 3 do
			freshTeamBtn(i)
		end
	-- end
end

function XuanZeYingXiongNewLayer:SavaDefenceTeamInfo()
	if self._battle_type == BattleType.PVP_DART_DEFENCE or self._battle_type == BattleType.ZHENQI_DEFENCE then
		local _team_str = "["
		if #self._Spine_List > 0 then
			for i = 1, #self._Spine_List do
				_team_str = _team_str .. self._Spine_List[i].heroid .. ","
			end
		end
		local _res_str = string.sub(_team_str, string.len(_team_str), -1)
		if _res_str == ',' then
			_team_str = string.sub(_team_str, 1, string.len(_team_str)-1)
		end
		_team_str = _team_str .. "]"
		local _modules = self._battle_type == BattleType.PVP_DART_DEFENCE and "setDartTeam?" or "setVeinsResourcePointTeam?"
		local _params = self._battle_type == BattleType.PVP_DART_DEFENCE and {petIds = _team_str, dartType = self._dartType} or {team = _team_str, ectypeId = self._dartType}
		ClientHttp:requestAsyncInGameWithParams({
	        modules = "setDartTeam?",
	        params = _params,
	        successCallback = function(net_data)
	            if tonumber(net_data.result) == 0 then
	            	if(self._endCallBack) then
		            	self._endCallBack(net_data)
		            end
	            	self:selfDestroy()
	            else
	             	XTHDTOAST(net_data.msg)
	            end
	        end,--成功回调
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
	        end,--失败回调
	        targetNeedsToRetain = self,--需要保存引用的目标
	        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	elseif self._battle_type == BattleType.PVP_DEFENCE or self._battle_type == BattleType.PVP_LADDER_DEFENCE then
		
		-- 检测是否有将已后队伍设置为空的情况
		-- 最初服务器返回的数据
		local _lastPVPDefenceTeam = self._tmp_user_data or {};
		-- 检测共有多少个队伍
		local _lastPVPDefenceTeamCount = 0;
		for i = 1, #_lastPVPDefenceTeam do
			if _lastPVPDefenceTeam[i]["team"] and next(_lastPVPDefenceTeam[i]["team"]) ~= nil then
				_lastPVPDefenceTeamCount = _lastPVPDefenceTeamCount + 1;
			end
		end
		-- 检测，现在的队伍信息，特别需要注意临界点，在刚开3对的时候，这个时候需要顺序检测，不能只检测个数，否则会出现1，3对设置的情况
		for i = 1, _lastPVPDefenceTeamCount do
			if self._PVP_Teams[i][1] == nil or next(self._PVP_Teams[i][1]) == nil then
				XTHDTOAST(LANGUAGE_FORMAT_TIPS34(i))---------"第" .. tostring(i) .. "队需要设置英雄" );
				return;
			end
		end

		local _team_str = "["
		for i=1,#self._PVP_Teams do
			_team_str = _team_str.."{\"teamId\":" .. tostring(i)..",\"petIds\":["
			for k=1,#self._PVP_Teams[i][1]  do
				if tonumber(self._PVP_Teams[i][1][k]["heroid"]) > 0 then
					_team_str = _team_str .. tostring(self._PVP_Teams[i][1][k]["heroid"]) .. ","
				end
			end
			local _res_str = string.sub(_team_str, string.len(_team_str), -1)
			if _res_str == ',' then
				_team_str = string.sub(_team_str, 1, string.len(_team_str)-1)
			end
			_team_str = _team_str .. "]},"
		end
		_team_str = _team_str .. "]"
		local modStr, mType
		if self._battle_type == BattleType.PVP_DEFENCE then
			modStr = "setTeam?"
			mType = 1
		else
			modStr = "setOrderTeam?"
			mType = 2
		end
		ClientHttp:requestAsyncInGameWithParams({
	        modules = modStr,
	        params = {teams=_team_str},
	        successCallback = function(net_data)
	            if tonumber(net_data.result) == 0 then
	            	self:selfDestroy()
	            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TEAM_SETTING_LAYER, data = {data = self._PVP_Teams,_type = mType}})
	            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PVP_TEAMINFO})
	            else
	             	XTHDTOAST(net_data.msg)
	            end
	        end,--成功回调
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
	        end,--失败回调
	        targetNeedsToRetain = self,--需要保存引用的目标
	        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	elseif self._battle_type == BattleType.CAMP_DEFENCE then
		local _json_tab = {}
		for i = 1,#self._PVP_Teams do 				
			local _tab = {}
			_tab.teamId = i	
			if self._user_data[i] then 			
				_tab.cityId = self._user_data[i].cityId or 0
			else
				_tab.cityId = 0 
			end 
			_tab.petIds = {}
			for j = 1,#self._PVP_Teams[i][1] do 
				_tab.petIds[#_tab.petIds + 1] = self._PVP_Teams[i][1][j].heroid
			end 
			_json_tab[#_json_tab +1] =_tab
		end 
		_json_tab = json.encode(_json_tab)	

		ClientHttp:requestAsyncInGameWithParams({
	        modules = "setCampGroup?",	        
	        params = {teams=_json_tab},
	        successCallback = function(net_data)
	         	XTHDTOAST(net_data.msg)
	            if tonumber(net_data.result) == 0 then
	            	self:selfDestroy()
	            	XTHD.dispatchEvent({name = EVENT_NAME_REFRESH_CAMPTEAMADJUSTED})
	            end
	        end,--成功回调
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
	        end,--失败回调
	        targetNeedsToRetain = self,--需要保存引用的目标
	        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	elseif self._battle_type == BattleType.GUILDWAR_TEAM then
		local _json_tab = {}
		for i = 1,#self._PVP_Teams do 				
			local _tab = {}
			_tab.teamId = i	
			_tab.petIds = {}
			for j = 1,#self._PVP_Teams[i][1] do 
				_tab.petIds[#_tab.petIds + 1] = self._PVP_Teams[i][1][j].heroid
			end 
			_json_tab[#_json_tab +1] =_tab
		end 
		_json_tab = json.encode(_json_tab)	

		ClientHttp.httpGuildSetDefenceGroup(self, function(net_data)
        	self:selfDestroy()
			XTHD.dispatchEvent({name = REFRESH_GUILDBATTLEGROUP})
		end, {list = _json_tab})
	elseif self._battle_type == BattleType.MULTICOPY_DEFENCE then
		local _heroId = -1
		if self._Spine_List[1] then
			_heroId = self._Spine_List[1].heroid
		end
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MULTICOPY_AFTERCHOOSE, data = {heroId = _heroId}})
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MULTICOPY_PREPAREHERO, data = {heroId = _heroId}})
    	self:selfDestroy()
	end
end

function XuanZeYingXiongNewLayer:SaveAttackTeamInfo()
	if self._battle_type == BattleType.PVE 
		or self._battle_type == BattleType.ELITE_PVE 
		or self._battle_type == BattleType.DIFFCULTY_COPY then
	  	local _team_data = {}
	  	for i = 1, 5 do
	  		if(self._Spine_List[i]) then
	  			if self._Spine_List[i].spine and self._Spine_List[i]._data then
			  		_team_data["heroid"..i] = 0
	  			else
			  		_team_data["heroid"..i] = tonumber(self._Spine_List[i]["heroid"]) or 0
	  			end
	  		else
	  			_team_data["heroid"..i] = 0
		  	end
	  	end
	  	_team_data.teamid = 1
		DBUserTeamData:UpdatePVETeamData(_team_data)
	elseif self._battle_type == BattleType.PVP_CHALLENGE 
		or self._battle_type == BattleType.PVP_LADDER 
		or self._battle_type == BattleType.PVP_FRIEND 
		or self._battle_type == BattleType.PVP_CUTGOODS
		or self._battle_type == BattleType.CAMP_PVP
		or self._battle_type == BattleType.CASTELLAN_FIGHT 
		or self._battle_type == BattleType.CAMP_TEAMCOMPARE  then
		local _team_data = {}
		for i=1,#self._PVP_Teams do
			local _tmp_data = {}
			for j=1,#self._PVP_Teams[i]["items"] do
				_tmp_data["itemid"..j] = self._PVP_Teams[i]["items"][j]["itemid"] or 0  -- pvp中道具列表
			end
			for k=1,5 do
				if(self._PVP_Teams[i][1][k]) then
					_tmp_data["heroid"..k] = tonumber(self._PVP_Teams[i][1][k]["heroid"]) or 0  
				else
					_tmp_data["heroid"..k] = 0
				end
			end
			_team_data[i] =_tmp_data
			_team_data[i].teamid = i
		end
		DBUserTeamData:UpdatePVPTeamData(_team_data)
	end
end
--进入战斗，战斗
function XuanZeYingXiongNewLayer:BattleClickCallback( sInstancingid )
	self._challengeActionPause = true
	if self._battle_type == BattleType.PVE 
		or self._battle_type == BattleType.ELITE_PVE
		or self._battle_type == BattleType.DIFFCULTY_COPY then
		local mParams = {}
		local _tb = {}
        for i=1, #self._Spine_List do
			local id = tonumber(self._Spine_List[i]["heroid"])
			_tb[#_tb + 1] = id
		end
		mParams.myTeam = json.encode(_tb)
		ClientHttp.http_EctypeBattleBegin(self, function( data )
			local pNum = #self.m_heroItem
			if self._helps then
				pNum = pNum + #self._helps
			end 
			if pNum == 0 then
				return
			end

	     	local _arrDropList = self._reward_item["itemReward"]
	     	local _dropList = {}
	     	for i = 1, #_arrDropList do
	     		local _szData = _arrDropList[i];
	     		local _tabData = string.split( _szData, ',' )
	     		_dropList[tostring(_tabData[1])] = _tabData[2]
	     	end
	        --更新动态数据库中的体力data
	       	gameUser.setTiliNow(tonumber(self._reward_item.tili))

	    	local teamListLeft = {}
	    	local teamListRight = {}
	    	local bgList = {}
	    	
		    -- 玩家选择的英雄初始化
		    if data.heros and next(data.heros) ~= nil then
	    		for k,hero in pairs(data.heros) do
					local petId = hero.petId
					local _staticData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = petId}) or {}
					hero.attackrange = _staticData.attackrange 
					local animal = {id = petId ,_type = ANIMAL_TYPE.PLAYER , data = hero }
		    		teamListLeft[#teamListLeft + 1] = animal
				end
				--[[--排队]]
				table.sort(teamListLeft, function(a,b) 
		    		local n1 = tonumber(a.data.attackrange) or 0
		    		local n2 = tonumber(b.data.attackrange) or 0
		    		return n1 < n2
		    	end )
			else
		        for i=1,#self._Spine_List do
					local id = tonumber(self._Spine_List[i]["heroid"])
					local pD = self._Spine_List[i]._data
					local pB = false
					if not pD and self._helps and #self._helps > 0 then
						pB = true
					end
		    		local animal = {id = id, _type = ANIMAL_TYPE.PLAYER, helps = pD, isGuidingHero = pB}
			    	teamListLeft[#teamListLeft + 1] = animal
		        end--[[--for end]]
		    end
	        local instanceData
	        local _battleType = self._battle_type
			if _battleType == BattleType.PVE then
				instanceData = gameData.getDataFromCSV("ExploreInfoList", {["instancingid"]=sInstancingid})
			elseif _battleType == BattleType.ELITE_PVE  then
				instanceData = gameData.getDataFromCSV("EliteCopyList", {["instancingid"]=sInstancingid})
			elseif _battleType == BattleType.DIFFCULTY_COPY then
				instanceData = gameData.getDataFromCSV("NightmareCopyList", {["instancingid"]=sInstancingid})
			end
			local bossid 	   = instanceData.bossid
			local sound 	   = "res/sound/"..tostring(instanceData.sound)..".mp3"
			local _time = instanceData.maxtime 

			local storyIds = string.split(instanceData.storyID,"#")
			local worldEffects = self._reward_item.effects
			local buffDamage = instanceData.buffdamage
			local background   = instanceData.background
			local bgs = string.split(background,"#")

			for k,bgId in pairs(bgs) do
				bgList[#bgList + 1] = "res/image/background/bg_"..bgId..".jpg"
			end
			local _bgType = instanceData.fubentype or BATTLE_GUIDEBG_TYPE.TYPE_NORMAL
			
	        local monsters = self._reward_item.monsters
	        for index=1,#monsters do
				local rightData 		= {}
				local storyId 			= storyIds[index]
				--[[--剧情id]]
	        	if storyId and tonumber(storyId) and tonumber(storyId) > 0 and sInstancingid > gameUser.getInstancingId() then
					rightData.storyId 	= storyId
				end
				--[[--该波的怪物]]
	        	local waveMonsters 		= monsters[index]
	        	local team 				= {}
	        	for k,monster in pairs(waveMonsters) do
	        		local monsterid = monster.monsterid
	        		local isBoss = false
	        		if monster.heroid == 801 then
	        			isBoss = true
	        		end
	        		local animal = {id = monsterid , _type = ANIMAL_TYPE.MONSTER,monster = monster, isWorldBoss = isBoss}
				    team[#team + 1]=animal
	        	end
				if team ~= nil and #team > 0 then
			    	--[[--排队]]
			    	table.sort( team, function(a,b) 
			    		local n1 = tonumber(a.monster.attackrange) or 0
			    		local n2 = tonumber(b.monster.attackrange) or 0
			    		return n1 < n2
			    	end )
					rightData.team = team
					teamListRight[#teamListRight + 1] = rightData
				end
	        end

			local _helpsData = self._helps
	    	local scene = cc.Director:getInstance():getRunningScene()
			local battleLayer = requires("src/battle/BattleLayer.lua"):create()
			local uiExploreLayer = BattleUIExploreLayer:create()            
			battleLayer:initWithParams({
				bgList 			= bgList,
				bgm    			= sound,
				battleTime      = _time,
				instancingid    = sInstancingid,
				teamListLeft	= {teamListLeft},
				teamListRight	= teamListRight,
				battleType 		= _battleType,
				bgType			= _bgType,
				-- isGuide			= 2,
				helps 			= _helpsData,
				worldBuff       = worldEffects,
				worldBuffDamage = buffDamage,
				battleEndCallback = function(params)
					if _helpsData and #_helpsData > 0 and params.left and params.left[1] and #params.left[1] > 0 then
						for k,v in pairs(params.left[1]) do
							for key,value in pairs(_helpsData) do
								if value.heroid == v.id then
									v.type = ANIMAL_TYPE.MONSTER
									v.id = value.monsterid
								end
							end
						end
					end
					ClientHttp.http_SendFightValidation(battleLayer, function(data)
			            local _instancingid = params.instancingid
						local _star = data.star
						if tonumber(data["fightResult"]) == 1 then --保存数据(普通、精英)
							local refresh_data = {}
							local _bType
							if _battleType == BattleType.PVE then
								_bType = ChapterType.Normal
							elseif _battleType == BattleType.ELITE_PVE then
								_bType = ChapterType.ELite
							elseif _battleType == BattleType.DIFFCULTY_COPY then
								_bType = ChapterType.Diffculty
							end
							refresh_data["type"] = _bType
				            refresh_data["instancingid"] = _instancingid
				            refresh_data["star"] = _star
				            refresh_data["surplusCount"] = data["surplusCount"] or 0
							CopiesData.refreshDataBase(refresh_data)
						end
						performWithDelay(battleLayer, function()
							battleLayer:hideWithoutBg()
							data.backCallback = function() 
								cc.Director:getInstance():popScene()
							end
							scene:addChild(requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoPVELayer.lua"):create(data))
						end, 2)
	                end, function()
		             	createFailHttpTipToPop()
					end, params)
				end,
			})
			
			self:selfDestroy(true)
			scene:addChild(battleLayer)
			battleLayer:setUILay(uiExploreLayer)
			scene:addChild(uiExploreLayer)
			
			-- cc.Director:getInstance():pushScene(scene)
			battleLayer:start()
		end, function()
			self._challengeActionPause = false
		end, mParams)
	elseif self._battle_type == BattleType.PVP_CHALLENGE 
		or self._battle_type == BattleType.PVP_LADDER 
		or self._battle_type == BattleType.PVP_FRIEND 
		or self._battle_type == BattleType.PVP_CUTGOODS 
		or self._battle_type == BattleType.CASTELLAN_FIGHT
		or self._battle_type == BattleType.CAMP_TEAMCOMPARE
		or self._battle_type == BattleType.ZHENQI_FIGHT_ROB 
	    or self._battle_type == BattleType.ZHENQI_FIGHT_OCCUPY then

		-- PVP
		local mParams
		if self._battle_type == BattleType.CASTELLAN_FIGHT then 
			mParams = {cityId = self.m_tmpRivalData.cityId}	
		elseif self._battle_type == BattleType.ZHENQI_FIGHT_ROB or self._battle_type == BattleType.ZHENQI_FIGHT_OCCUPY then
			mParams = {ectypeId = sInstancingid} 
		else
			mParams = {rivalId = self.m_tmpRivalData.charId}
			if (self._battle_type == BattleType.PVP_CUTGOODS) then
				mParams.dartType = self.m_tmpRivalData.dartType
			elseif self._battle_type == BattleType.CAMP_TEAMCOMPARE then
				mParams.cityId = self.m_tmpRivalData.cityId	
				mParams.teamId = self.m_tmpRivalData.teamId	
			elseif self._battle_type == BattleType.PVP_CHALLENGE
				or self._battle_type == BattleType.PVP_LADDER 
				or self._battle_type == BattleType.PVP_FRIEND then
				local _tb = {}
				for k=1,#self._PVP_Teams[1][1] do
					local id = self._PVP_Teams[1][1][k]["heroid"] or 0  
					_tb[#_tb + 1] = id
				end
				mParams.myTeam = json.encode(_tb)
			end
		end
		ClientHttp.http_StartChallenge(self, self._battle_type, mParams, function(data)
			if data.raceCount then
        		HaoYouPublic.setRaceTime(data.raceCount)
        	end
        	
        	if self._battle_type == BattleType.PVP_CUTGOODS and data.lootTimes then
        		XTHD.dispatchEvent({
					name = CUSTOM_EVENT.REFRESH_ESCORT_TIME,
					data = data.lootTimes,
				})
        	end
		    -- do return end
	    	local teamListLeft = {}
	    	local teamListRight = {}
	    	local bgList = {}

	    	local _haveLeft, _haveRight
	    	if data.heros and next(data.heros) ~= nil then
	    		_haveLeft = data.heros
	    		for k,hero in pairs(data.heros) do
					local petId = hero.petId
					local _staticData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = petId}) or {}
					hero.attackrange = _staticData.attackrange 
					local animal = {id = petId ,_type = ANIMAL_TYPE.PLAYER , data = hero }
		    		teamListLeft[#teamListLeft + 1] = animal
				end
				--[[--排队]]
				table.sort(teamListLeft, function(a,b) 
		    		local n1 = tonumber(a.data.attackrange) or 0
		    		local n2 = tonumber(b.data.attackrange) or 0
		    		return n1 < n2
		    	end )
			else
				for i=1,#self._PVP_Teams do
					table.sort(self._PVP_Teams[i][1], function ( data1, data2 )
						return  tonumber(data1["attackrange"]) < tonumber(data2["attackrange"])
					end)
				end 
				for i=1,#self._PVP_Teams do
					local _tmp_data = {}
					for k=1,#self._PVP_Teams[i][1] do
						local id = self._PVP_Teams[i][1][k]["heroid"] or 0  
						local animal = {id = id ,_type = ANIMAL_TYPE.PLAYER}
				    	teamListLeft[#teamListLeft + 1] = animal
					end
				end
	    	end
           
			--[[--敌人的第一个队伍]]

			if self._battle_type == BattleType.CASTELLAN_FIGHT and data.monsters and next(data.monsters) ~= nil then 
				local monsters = data.monsters
				local rightData 		= {}
	        	local team 				= {}
	        	for k,monster in pairs(monsters) do
	        		local monsterid = monster.monsterid
	        		local isBoss = false
	        		if monster.heroid == 801 then
	        			isBoss = true
	        		end
	        		local animal = {id = monsterid , _type = ANIMAL_TYPE.MONSTER,monster = monster, isWorldBoss = isBoss}
				    team[#team + 1]=animal
	        	end
				if team ~= nil and #team > 0 then
			    	--[[--排队]]
			    	table.sort( team, function(a,b) 
			    		local n1 = tonumber(a.monster.attackrange) or 0
			    		local n2 = tonumber(b.monster.attackrange) or 0
			    		return n1 < n2
			    	end )
					rightData.team = team
					teamListRight[#teamListRight + 1] = rightData
				end
			else
				if (self._battle_type == BattleType.CASTELLAN_FIGHT
				  or self._battle_type == BattleType.ZHENQI_FIGHT_ROB 
				  or self._battle_type == BattleType.ZHENQI_FIGHT_OCCUPY)
				   and data.rivals and next(data.rivals) ~= nil then 
					self._user_data = data.rivals.teams
				end
				_haveRight = self._user_data
				for k,teams in pairs(self._user_data) do
					local heroes = teams.heros
					local rightData = {}
					local team = {}
					for k,hero in pairs(heroes) do
						local petId = hero.petId
						local _staticData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = petId}) or {}
						hero.attackrange = _staticData.attackrange 
						local animal = {id = petId ,_type = ANIMAL_TYPE.PLAYER , data = hero }
			    		team[#team + 1]=animal
					end
					--[[--排队]]
					table.sort( team, function(a,b) 
			    		local n1 = tonumber(a.data.attackrange) or 0
			    		local n2 = tonumber(b.data.attackrange) or 0
			    		return n1 < n2
			    	end )
					rightData.team = team
					teamListRight[#teamListRight + 1] = rightData
				end--[[--for]]
			end

			if(self._battle_type == BattleType.PVP_CHALLENGE) then
				local bgId = math.random(1,53)
				bgList[#bgList + 1] = "res/image/background/bg_"..bgId..".jpg"
			elseif(self._battle_type == BattleType.PVP_CUTGOODS) then
				bgList[#bgList + 1] = self._bg_imgpath
			else
				bgList[#bgList + 1] = "res/image/background/bg_pvp.jpg"
			end
			
	    	local scene = cc.Director:getInstance():getRunningScene()
			local battleLayer = requires("src/battle/BattleLayer.lua"):create()
			local uiPvpRobberyLayer = BattleUIPvpRobberyLayer:create(self.m_tmpRivalData,self._battle_type)
			local m_tmpRivalData=self.m_tmpRivalData
			battleLayer:initWithParams({
				bgList 			= bgList,
				bgm    			= "res/sound/bgm_battle_pvp.mp3",
				instancingid    = sInstancingid,
				battleTime      = 90,
				teamListLeft	={teamListLeft},
				teamListRight	=teamListRight,
				battleType 		= self._battle_type,
				battleEndCallback = function(params)
					params.leftData = _haveLeft
					params.rightData = _haveRight
					ClientHttp.http_SendFightValidation(battleLayer, function(data)

						-- dump(data, "result dat ============== ")
						performWithDelay(battleLayer, function()
	                    	battleLayer:hideWithoutBg()
							data.backCallback = function() 
								cc.Director:getInstance():popScene()
							end
					  		if(params.battleType == BattleType.PVP_CHALLENGE) then
								battleLayer:addChild(requires( "src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoRobberyLayer.lua"):create(data,m_tmpRivalData))
							elseif (params.battleType == BattleType.PVP_CUTGOODS) then
								battleLayer:addChild(requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoWorldBossLayer.lua"):create(data))
	                        else
								battleLayer:addChild(requires( "src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoPVPLayer.lua"):create(data))
							end
						end, 2)
					end, function()
		             	createFailHttpTipToPop()
		             	if (params.battleType == BattleType.PVP_CUTGOODS) then
					        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ESCORT_LAYER}) 
					    end
					end, params)
				end
			})
			
			self:selfDestroy(true)
			scene:addChild(battleLayer)
			battleLayer:setUILay(uiPvpRobberyLayer)
			scene:addChild(uiPvpRobberyLayer)
			-- cc.Director:getInstance():pushScene(scene)
			battleLayer:start()
		end, function()
			self._challengeActionPause = false
		end)
	elseif self._battle_type == BattleType.CAMP_PVP then
		--种族战处理
		local camp_data = self:getCampBattleEnemyData()
		camp_data.campId = gameUser.getCampID() == 1 and 2 or 1
		camp_data.battleType = BattleType.CAMP_PVP
		local _params = {rivalId=camp_data["charId"],teamId=camp_data["team"][1]["teamId"]}
		ClientHttp.http_StartChallenge(self, self._battle_type, _params, function(data)
	    	local teamListLeft = {}
	    	local teamListRight = {}
	    	local bgList = {}

	        for i=1,#self._Spine_List do
				table.sort(self._Spine_List, function ( data1, data2 )
					return  tonumber(data1["attackrange"]) < tonumber(data2["attackrange"])
				end)
			end 

			local _tmp_data = {}
			for i=1,#self._Spine_List do
				local id = self._Spine_List[i]["heroid"] or 0  
				local animal = {id = id ,_type = ANIMAL_TYPE.PLAYER}
		    	teamListLeft[#teamListLeft + 1] = animal
			end

	    	local _team_data = {_tmp_data,{},{}}
			local heroes = data.rival["team"][1]["heros"]
			local rightData = {}
			local team = {}
			for k,hero in pairs(heroes) do
				local petId = hero.petId
				local pCurhp = tonumber(hero.curHp) or 0
				if(pCurhp ~= 0) then
					local _staticData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = petId}) or {}
					hero.attackrange = _staticData.attackrange 	
					local animal = {id = petId ,_type = ANIMAL_TYPE.PLAYER , data = hero }
		    		team[#team + 1]=animal
		    	end
			end
			--[[--排队]]
			table.sort( team, function(a,b) 
	    		local n1 = tonumber(a.data.attackrange) or 0
	    		local n2 = tonumber(b.data.attackrange) or 0
	    		return n1 < n2
	    	end )
			rightData.team = team
			teamListRight[#teamListRight + 1] = rightData

			bgList[#bgList + 1] = "res/image/background/bg_pvp.jpg"
			
	    	local scene = cc.Director:getInstance():getRunningScene()
			local battleLayer = requires("src/battle/BattleLayer.lua"):create()
			local uiPvpRobberyLayer = BattleUIPvpRobberyLayer:create(camp_data,self._battle_type)
			battleLayer:initWithParams({
				bgList 			= bgList,
				bgm    			= "res/sound/bgm_battle_pvp.mp3",
				instancingid    = sInstancingid,
				battleTime      = 90,
				teamListLeft	= {teamListLeft},
				teamListRight	= teamListRight,
				battleType 		= self._battle_type,
				battleEndCallback = function(params)
					ClientHttp.http_SendFightValidation(battleLayer, function(data)
						performWithDelay(battleLayer, function()
		                	battleLayer:hideWithoutBg()
							data.backCallback = function() 
								cc.Director:getInstance():popScene()
							end
		                	battleLayer:addChild(requires( "src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoPVPLayer.lua"):create(data))
						end, 2)
					end, function()
                        createFailHttpTipToPop()
					end, params)
				end,
			})
			
			self:selfDestroy(true)
			scene:addChild(battleLayer)
			battleLayer:setUILay(uiPvpRobberyLayer)
			scene:addChild(uiPvpRobberyLayer)

			-- cc.Director:getInstance():pushScene(scene)
			battleLayer:start()
		end, function()
			self._challengeActionPause = false
		end)
	end
end

--[[在PVP模式下、会传入挑战方对心的信息，在自己切换一、二、三队的同时，上方展示的地方对应的队伍信息，WQ
	在此处刷新每个队伍对应的spine、items比较好，我认为这是最完美的处理时机 �
]]--
function XuanZeYingXiongNewLayer:RefreshEnemyTeamData(bl_animation)
	-- ①先移除已有的spine和items
	if self._Spine_List then
		for i=#self._Spine_List,1,-1 do
			if self._Spine_List[i] then
				local tmpData = {heroid = self._Spine_List[i]["heroid"], _bSel = true}
				self:RefreshSpine(tmpData)
			end
		end
		self._Spine_List = {}
	end

	--②，添加应该展示的spine和items
	--print("RefreshEnemyTeamData >>>>> 1")
	---- ZCLOG(self._PVP_Teams)
	for i=1,#self._PVP_Teams[self._current_Team_num][1] do
		if self._PVP_Teams[self._current_Team_num][1][i] then
			local tmpData = {heroid = self._PVP_Teams[self._current_Team_num][1][i]["heroid"], bl_need_animation = bl_animation}
			self:RefreshSpine(tmpData)
			local p1 = tonumber(self.m_labTotalCombatData:getString()) or 0
			local p2 = tonumber(self._PVP_Teams[self._current_Team_num][1][i]["power"]) or 0
			self.m_labTotalCombatData:setString(p1+p2)
		end
	end
	--虽然在设置防守队伍的情况下已经隐藏了相关的敌方队伍信息，但此处还是不再继续(不进行不必要的操作)
	if self._battle_type == BattleType.PVP_DEFENCE 
		or self._battle_type == BattleType.PVP_LADDER_DEFENCE 
		or self._battle_type == BattleType.PVP_DART_DEFENCE
		or self._battle_type == BattleType.ZHENQI_DEFENCE
		or self._battle_type == BattleType.GUILDWAR_TEAM
		or self._battle_type == BattleType.MULTICOPY_DEFENCE
		or self._battle_type == BattleType.CASTELLAN_FIGHT then
		return
	end
	if self._battle_type == BattleType.CAMP_DEFENCE then
		if not self._defence_city_label then
			self._defence_city_label =  XTHDLabel:createWithParams({
		    		text = "",
		    	    fontSize = 24,--字体大小
		    	    color = cc.c3b(240, 240, 240),
		    	    pos = cc.p(self:getContentSize().width*0.5,self:getContentSize().height-20),
		    	    anchor = cc.p(0.5,1)
		    	})
			self._defence_city_label:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1),1)
			self:addChild(self._defence_city_label)
		end
		local _, _cityname = self:checkTeamAndCityInfoWhenCampDef(self._current_Team_num) 
		if _cityname then 
			self._defence_city_label:setString(LANGUAGE_FORMAT_TIPS35(_cityname))-------"该队伍当前防守: ".._cityname)
		else 
			self._defence_city_label:setString("")
		end 
	end

	local function getAvatar_Item(hero_data)
		if hero_data then
			return HeroNode:createWithParams({
						heroid   =hero_data["petId"],
						star   = hero_data["star"],
						level = hero_data["level"],
						isShowType = true,
						advance = hero_data["phase"],
					})
		end
	end

	--self._current_Team_num 当前所选中的队伍id
	if self._enemy_team_bg then
		self._enemy_team_bg:removeAllChildren()
		local _tmp_data
		if self._battle_type == BattleType.CAMP_PVP and self:getCampBattleEnemyData()["team"] and self:getCampBattleEnemyData()["team"][1] then
			_tmp_data = self:getCampBattleEnemyData()["team"][1]["heros"] or {}
		else
			if self._user_data and self._user_data[self._current_Team_num] then 
				_tmp_data = self._user_data[self._current_Team_num]["heros"] or {} 
			else
				_tmp_data = {}
			end
		end 
		
		if #_tmp_data > 0 then
			for i=1,5 do
				local avatar_box = getAvatar_Item(_tmp_data[i])
				if avatar_box then
					avatar_box:setAnchorPoint(0,0.5)
					avatar_box:setScale(0.8)
					avatar_box:setPosition(1+(avatar_box:getContentSize().width+3)*avatar_box:getScaleX()*(i-1), self._enemy_team_bg:getContentSize().height*0.5)
		    		self._enemy_team_bg:addChild(avatar_box)
		    	end
			end
		else
			local team_label = XTHDLabel:createWithParams({
	    		text = LANGUAGE_TIPS_WORDS167,---------"敌人暂无该队伍",
	    	    fontSize = 20,--字体大小
	    	    color = cc.c3b(240, 240, 240),
	    	    pos = cc.p(self._enemy_team_bg:getContentSize().width*0.5,self._enemy_team_bg:getContentSize().height*0.5),
	    	    anchor = cc.p(0.5,0.5)
	    	})
			self._enemy_team_bg:addChild(team_label)
		end
	end
end

function XuanZeYingXiongNewLayer:setSelectedOne( sender, isSelected)
	if not sender then
		return
	end
	local pNum = tonumber(sender:getTag()) or 1
	self:refreshTeamMenberCount(pNum)
	if isSelected then
		if not sender._selectTick then
			sender._selectTick = ccui.Scale9Sprite:create("res/image/imgSelHero/campuse/img_selectTick.png")
			sender._selectTick:setContentSize(314,69)
			sender:addChild(sender._selectTick)
			sender._selectTick:setAnchorPoint(0, 0.5)
			sender._selectTick:setPosition(-7, sender:getContentSize().height*0.5)
		end
		if sender._teamSp then
			sender._teamSp:setTexture("res/image/imgSelHero/campuse/img_select_" .. pNum ..".png")
		end
	else
		if sender._selectTick then
			sender._selectTick:removeFromParent()
			sender._selectTick = nil
		end
		if sender._teamSp then
			sender._teamSp:setTexture("res/image/imgSelHero/campuse/img_unselect_" .. pNum ..".png")
		end
	end
end

--切换按钮的状态，并且刷新当前列表的数据
function XuanZeYingXiongNewLayer:ChangeBtnStatusAndRefreshData(sender,_type)
	-- if not sender then
	-- 	return
	-- end
	if _type == "team" then
		if not sender then
			return
		end
		for i = 1, #self._groupbtnList do
			if self._groupbtnList[i]:getChildByName("hand") then
				self._groupbtnList[i]:getChildByName("hand"):removeFromParent()
			end
		end
	 	if self._last_team_btn then
			if self._last_team_btn == sender then
				return
			end
			self._last_team_btn:setSelected(false)
			self:setSelectedOne(self._last_team_btn, false)
		end
		if self.m_labTotalCombatData then
			self.m_labTotalCombatData:setString(0) 
		end
		self._current_Team_num =tonumber(sender:getTag())

		if self._last_team_btn then
			self:RefreshEnemyTeamData( false) --刷新敌人队伍信息
		else
			self:RefreshEnemyTeamData( true) --刷新敌人队伍信息
		end
		sender:setSelected(true)
		self:setSelectedOne(self._last_team_btn, false)
		--每次切换队伍，需要把之前的队伍战斗力置为0

		self._last_team_btn = sender
		self:setSelectedOne(self._last_team_btn, true)
		
		if self.m_tableView then
			self.m_tableView:reloadDataAndScrollToCurrentCell()
		end
	elseif _type == "right" then
		self._target_cellIndex = nil
	 -- 	if self._last_right_btn then
		-- 	if self._last_right_btn == sender then
		-- 		return
		-- 	end
		-- 	self._last_right_btn:setSelected(false)
		-- end
		--print("right >>>33")
		-- sender:setSelected(true)
		-- self._last_right_btn = sender 
		self._data_source={}
		-- local _tag = tonumber(sender:getTag())
		local _tag = 1
		if _tag == 1 then
			self._data_source = self._totalHeroData
		elseif _tag == 2  then
			for i=1,#self._totalHeroData do
				if tonumber(self._totalHeroData[i]["attackrange"]) < IntervalBeforeAndMiddle then
					self._data_source[#self._data_source +1] = self._totalHeroData[i]
				end
			end
		elseif _tag == 3  then
			for i=1,#self._totalHeroData do
				if tonumber(self._totalHeroData[i]["attackrange"]) > IntervalBeforeAndMiddle and tonumber(self._totalHeroData[i]["attackrange"]) < IntervalMiddleAndAfter then
					self._data_source[#self._data_source +1] = self._totalHeroData[i]
				end
			end
		elseif _tag == 4  then
			for i=1,#self._totalHeroData do
				if tonumber(self._totalHeroData[i]["attackrange"]) > IntervalMiddleAndAfter then
					self._data_source[#self._data_source +1] = self._totalHeroData[i]
				end
			end
		elseif _tag == 5  then
			for i=1,#self._totalHeroData do
				if tonumber(self._totalHeroData[i]["attackrange"]) < IntervalBeforeAndMiddle then
					self._data_source[#self._data_source +1] = self._totalHeroData[i]
				end
			end
		end
		if self._PVP_Teams then
			self._current_Team_num = self._current_Team_num or 1
			local _hero_data = self._PVP_Teams[self._current_Team_num][1]
			for i=1,#_hero_data do
				if	self:_bTheItemIsSelect({["heroid"]=_hero_data[i]}) then
					self._target_cellIndex = i 
					break
				end
			end
		else
			for i=1,#self._data_source do
				if	self:_bTheItemIsSelect(self._data_source[i]) then
					self._target_cellIndex = i 
					break
				end
			end
		end

		if self.m_tableView then
			self.m_tableView:reloadData()
			if self._target_cellIndex then
		    	self.m_tableView:scrollToCell(self._target_cellIndex-1)
		    end
		end
	end
end

--检测当前数据是在已选数据的哪一个队伍，此种情况只用在PVP模式下
function XuanZeYingXiongNewLayer:CheckTargetTeamId(heroid)
	for i= #self._PVP_Teams ,1,-1 do
		local _team_data = self._PVP_Teams[i][1]
		for j=#_team_data ,1,-1 do
			if tonumber(_team_data[j]["heroid"]) == tonumber(heroid) then
				return i 
			end
		end
	end

	return 0
end
--
--检测在种族PVP的时候，该英雄是否在防守队伍中
function XuanZeYingXiongNewLayer:chencIsInDefenceListWhenCampPVP(heroid)
	self.camp_pvp_def_data =self.camp_pvp_def_data or {}
	for i=1,#self.camp_pvp_def_data do
		if tonumber(self.camp_pvp_def_data[i]) == tonumber(heroid) then
			return true
		end
	end
	return false
end
--在种族战设置防守队伍的时候，如果需要切换英雄所在队伍id，所防守城市id，则需要简则该英雄当前的所属权问题
function XuanZeYingXiongNewLayer:checkTeamAndCityInfoWhenCampDef(teamid)
	if self._user_data then
		if self._user_data[teamid] and  self._user_data[teamid]["cityId"] then
			return self._user_data[teamid]["cityId"],self._user_data[teamid]["cityName"]
		end
	end
	return nil,nil
end

function XuanZeYingXiongNewLayer:cellSizeForTable(table,idx) 
	if table == self.m_item_list then
		return 95,400
	else
    	return (self.m_tableView:getViewSize().width)/7,self.m_tableView:getViewSize().height
    end
end

function XuanZeYingXiongNewLayer:numberOfCellsInTableView(table)
	
	if table == self.m_item_list then
		if not self._item_tip  then
			self._item_tip = 0
		end
		if #self._totalEquipData == 0 then
			if self._item_tip < 1 then
				XTHDTOAST(LANGUAGE_TIPS_WORDS41)-------"暂时没有符合该条件的道具")
			end
			self._item_tip  = 1
		else
			self._item_tip  = 0
		end
		return math.ceil(#self._totalEquipData/4)
	else

		if #self._data_source < 7 then
			if self._hero_tip and self._hero_tip < 1 then
				-- XTHDTOAST("暂时没有符合该条件的英雄")
			end
			self._hero_tip = 1
			return 7
		else
			self._hero_tip  = 0
		end
		return math.ceil(#self._data_source);
	end
end

function XuanZeYingXiongNewLayer:tableCellAtIndex(table, idx)
	local percellCount = 1 --每个cell节点数
	if table == self.m_item_list then
		percellCount = 4 --每个cell节点数
	end
   	local cell = table:dequeueCell();
    if cell then
    	cell:removeAllChildren()
    else
    	cell = cc.TableViewCell:new();
    end
    cell:setContentSize(cc.size(90, 110));

   	for i = 1, percellCount do
   		local temp_data = self._data_source[ idx*percellCount+i]
   		if temp_data and (not temp_data.isHelp or not self._selectData.isNewHelps(temp_data["heroid"]) or (temp_data.isHelp and temp_data.isInit and self._selectData.isNewHelps(temp_data["heroid"]))) then
   			local _bSel = self:_bTheItemIsSelect(temp_data) --判断当前数据是否在已经选中的英雄或者道具列表中
			local _needHp = false
			local _curNum = 0 
			if self._selectData.checkHaveCampPvpDefDeadInfo(temp_data["heroid"]) then
				_needHp = true
			end
			local item = HeroNode:createWithParams({
				heroid 	=temp_data["heroid"],
				star   	= temp_data["star"],
				level 	= temp_data["level"],
				advance = temp_data["advance"] or temp_data["rank"],
				needHp          = _needHp,--是否需要显示血条
    			curNum          = _curNum,--当前血量
    			deadNeedCall 	= true,
    			isShowType      = true,
    			deadCallback 	= function ()
    				XTHDTOAST(LANGUAGE_TIPS_WORDS165)------"已死亡，不能上阵")
    			end
			})
					
   			if item then
   				if self._battle_type == BattleType.CAMP_PVP  then
					local _bl = self:chencIsInDefenceListWhenCampPVP(temp_data["heroid"])
					if _bl then
						local mask_layer = XTHDDialog:create()
						mask_layer:setSwallowTouches(false)
						mask_layer:setContentSize(item:getContentSize())
						mask_layer:setColor(cc.c3b(0,0,0))
						mask_layer:setOpacity(100)
						item:addChild(mask_layer)
						item:setClickable(false)

						local fangshou_label = XTHDLabel:createWithParams({
					    	text = LANGUAGE_KEY_DEFENDING,--------"防守中",
					        fontSize = 20,--字体大小
					        color = cc.c3b(237, 220, 107),
					        pos = cc.p(item:getContentSize().width*0.5,item:getContentSize().height*0.5)
					    })
					    item:addChild(fangshou_label)
					end
				end
				self._canSelectedHeros[#self._canSelectedHeros + 1] = item		
   				item:setEnableWhenMoving(true)
   				-- Warning : 在PVP 模式下、再切换队伍的时候，需要刷新展示的spine，在此处处理可能是个错误，Who knows~
   				local Target_id = temp_data["heroid"]

				if _bSel then
					local m_tick
					if self._battle_type == BattleType.CAMP_DEFENCE or self._battle_type == BattleType.GUILDWAR_TEAM then
						m_tick = cc.Sprite:create("res/image/imgSelHero/campuse/img_markTick.png")
					else
						m_tick = cc.Sprite:create("res/image/common/heroSelected_sp.png")
					end
					m_tick:setAnchorPoint(cc.p(0.5, 0.5))
					m_tick:setPosition(cc.p(item:getContentSize().width*0.5, item:getContentSize().height*0.5))
					item:addChild(m_tick)
					if self._battle_type == BattleType.CAMP_DEFENCE then
						local _target_team_id = self:CheckTargetTeamId(Target_id)
						item._target_team_id = _target_team_id
						if _target_team_id > 0 then
							local bg_layer = cc.Sprite:create("res/image/imgSelHero/teambg_"..tostring(_target_team_id)..".png")
							bg_layer:setAnchorPoint(0,1)
							bg_layer:setPosition(0, item:getContentSize().height-0)
							item:addChild(bg_layer)
						end
					end
				end
				
				if temp_data.isHelp then
			 		local pic = cc.Sprite:create("res/image/imgSelHero/battleHeroType_yuan.png")
			 		if pic then
			 			item:addChild(pic)
			 			pic:setPosition(item:getContentSize().width - 10,item:getContentSize().height - 10)
			 			if item.typePic then
				 			item.typePic:setVisible(false)
				 		end
			 		end	
			 	end   
			 	if temp_data.isForcedCannot then
			 		
			 		local pNum = self._selectData.getTargetOtherTeam(Target_id)
			 		if pNum and pNum > 0 then
				 		local pString = "res/image/daily_task/escort_task/team_" .. pNum .. ".png"
						local pic = cc.Sprite:create(pString)
				 		if pic then
				 			local mask_layer = cc.LayerColor:create()
							mask_layer:setContentSize(item:getContentSize())
							mask_layer:setColor(cc.c3b(0,0,0))
							mask_layer:setOpacity(75)
							item:addChild(mask_layer)

				 			pic:setAnchorPoint(0, 1)
				 			pic:setPosition(0, item:getContentSize().height - 2)
				 			item:addChild(pic)
				 		end	
				 	else
				 		if self._battle_type == BattleType.PVP_DART_DEFENCE 
						  or self._battle_type == BattleType.ZHENQI_DEFENCE
				 	      or self._battle_type == BattleType.MULTICOPY_DEFENCE then
				 			local mask_layer = cc.LayerColor:create()
							mask_layer:setContentSize(item:getContentSize())
							mask_layer:setColor(cc.c3b(0,0,0))
							mask_layer:setOpacity(75)
							item:addChild(mask_layer)

							local pic = cc.Sprite:create("res/image/imgSelHero/battleHeroType_jin.png")
					 		if pic then
					 			pic:setAnchorPoint(0, 1)
					 			pic:setPosition(0, item:getContentSize().height - 2)
					 			item:addChild(pic)
					 			if item.typePic then
						 			item.typePic:setVisible(false)
						 		end
					 		end
			 			end
				 	end
		 		end		
				item:setName("hero")--设置不同的名字。用来区分点击的是装备还是英雄
				item:setTag(idx)--标记自己处于哪一个cell
   				item:setTouchEndedCallback(function ()
				    ----引导
				    YinDaoMarg:getInstance():guideTouchEnd()
				    ----------------------------------------
					musicManager.playEffect(XTHD.resource.music.effect_btn_common) 
   					if self._battle_type == BattleType.CAMP_PVP then
   						local _bl = self:chencIsInDefenceListWhenCampPVP(temp_data["heroid"])
   						if _bl then
   							XTHDTOAST(LANGUAGE_TIPS_WORDS168)------"该英雄在防守种族队伍中，无法参加战斗啦")
   							return
   						end
   					end
					if self._battle_type ~= BattleType.PVE 
						and self._battle_type ~= BattleType.ELITE_PVE 
						and self._battle_type ~= BattleType.DIFFCULTY_COPY then
						local _target_team_id = tonumber(self:CheckTargetTeamId(Target_id))
						
						if tonumber(_target_team_id) > 0 and ( tonumber(_target_team_id) ~= tonumber(self._current_Team_num)) then
							if #self._PVP_Teams[self._current_Team_num][1] == 5 then
								XTHDTOAST(LANGUAGE_TIPS_WORDS169)--------"该队伍所能携带的英雄数量已达上限")
								return
							end
							self:ChangeDataLocation(_target_team_id,temp_data,item)
						else
						 	if temp_data.isForcedCannot then
						 		local pNum = self._selectData.getTargetOtherTeam(Target_id)
			 					if (not pNum or pNum <= 0) and
			 					  (self._battle_type == BattleType.PVP_DART_DEFENCE or self._battle_type == BattleType.ZHENQI_DEFENCE) then
									XTHDTOAST(LANGUAGE_TIPS_WORDS228)
			 						return
			 					end
			 					if self._battle_type == BattleType.PVP_DART_DEFENCE or self._battle_type == BattleType.ZHENQI_DEFENCE then
									XTHDTOAST(LANGUAGE_TIPS_WORDS229)
			 					else
									XTHDTOAST(LANGUAGE_TIPS_WORDS212)
			 					end
								return
							end
							self:ItemClickCallback(item,temp_data)
						end
					else
						if temp_data.isHelp then
							XTHDTOAST(LANGUAGE_TIPS_WORDS171)-------"该英雄不可离开队伍！")
							return
						end
						self:ItemClickCallback(item,temp_data)
					end
		   		end)
		   		if table == self.m_item_list then
					item:setAnchorPoint(cc.p(0, 0.5))
		   			item:setPosition(cc.p(15+95*(i-1), 95*0.5))
				else
					local _y_pos,_x_pos = self:cellSizeForTable(table, idx) --self.m_tableView:getViewSize().height*0.5
					item:setPosition(cc.p(_x_pos*0.5, _y_pos*0.5))
				end
		   		cell:addChild(item)
   			end
   		else
   			-- break
   			local hero_box = cc.Sprite:create("res/image/imgSelHero/hero_box.png")
   			local _y_pos,_x_pos = self:cellSizeForTable(table, idx) --self.m_tableView:getViewSize().height*0.5
			hero_box:setPosition(cc.p(_x_pos*0.5, _y_pos*0.5));
			cell:addChild(hero_box);
   		end
   	end
    return cell
end

--如果需要吧其他组的数据移动到当前组，则调用该方法
function XuanZeYingXiongNewLayer:ChangeDataLocation(_target_team_id,temp_data,item)
	local _msg = LANGUAGE_TIPS_WORDS172 ------"当前英雄在其他队伍中,是否移动到当前队伍中?"
	local function callback()
		for k= 1 , #self._PVP_Teams[_target_team_id][1] do
			if tonumber(self._PVP_Teams[_target_team_id][1][k]["heroid"]) == tonumber(temp_data["heroid"]) then
				self:AddOrRemoveData(self._PVP_Teams[_target_team_id][1][k],true)
				table.remove(self._PVP_Teams[_target_team_id][1],k)
				break
			end
		end
		self:ItemClickCallback(item,temp_data, true)
	end
	
	local dialog = XTHDConfirmDialog:createWithParams({
		msg           = _msg,
		rightCallback = function()
			callback()
		end
		})
	self:addChild(dialog,6)

end

function XuanZeYingXiongNewLayer:ItemClickCallback(sender, temp_data, isFreshAll)
	local is_selected = self:_bTheItemIsSelect(temp_data )  --is_selected true:标示在已选列表中，false，标示不在已选列表中

	--先判断数量是否达到了上线，如果达到，则直接return
	local top_num = 5 
	if self._battle_type == BattleType.CAMP_DEFENCE then
		top_num = 15 
	elseif self._battle_type == BattleType.GUILDWAR_TEAM then
		top_num = 15 
	elseif self._battle_type == BattleType.MULTICOPY_DEFENCE then
		top_num = 1
	else
		if self._helps and #self._helps > 0 then
			top_num = top_num - #self._helps
			top_num = top_num > 0 and top_num or 0
		end
	end
	if self._battle_type ~= BattleType.PVE 
		and self._battle_type ~= BattleType.ELITE_PVE 
		and self._battle_type ~= BattleType.DIFFCULTY_COPY then
		if (#self._PVP_Teams[self._current_Team_num][1] >= 5 or #self.m_heroItem >= top_num)  and (is_selected == false) then
			XTHDTOAST(LANGUAGE_TIPS_WORDS169)------"该队上阵英雄数量已达上限")
			return
		end
	else
		if is_selected == false then
			if #self.m_heroItem >= top_num then
				XTHDTOAST(LANGUAGE_TIPS_WORDS174)------"上阵英雄数量已达上限")
				return
			end
			if self._selectData.isHelpId(temp_data["heroid"]) then
				XTHDTOAST(LANGUAGE_TIPS_WORDS211)
				return
			end
		end
	end

	-- Congratulations!! 既然你走到了这一步，那么你已经突破重围，可以攫取英雄或者道具了。�
	self:AddOrRemoveData(temp_data,is_selected)			--操作数据，添加或者移除

	local _heroId = temp_data["heroid"]
	local tmpData = {heroid = _heroId, _bSel = is_selected, bl_need_animation = false, cellindex = sender:getTag()}
	self:RefreshSpine(tmpData)  --操作展示区域的spine，添加或者移除
	local pNum = tonumber(temp_data["power"]) or 0
	if is_selected == true then
		self.m_labTotalCombatData:setString(tonumber(self.m_labTotalCombatData:getString()) - pNum)
	elseif is_selected == false then
		self.m_labTotalCombatData:setString(tonumber(self.m_labTotalCombatData:getString()) + pNum)
	end
	self:playSoundEffect(_heroId, not is_selected)
	self.m_tableView:updateCellAtIndex(sender:getTag())

	if self._battle_type ~= BattleType.PVE 
		and self._battle_type ~= BattleType.ELITE_PVE 
		and self._battle_type ~= BattleType.DIFFCULTY_COPY then
		if isFreshAll then
			self:refreshTeamMenberCount()
		else
			self:refreshTeamMenberCount(self._current_Team_num)
		end
	end
end

function XuanZeYingXiongNewLayer:playSoundEffect( _heroId, show )
	if self._effSoundTb[_heroId] then
		musicManager.stopEffect(self._effSoundTb[_heroId])
		self._effSoundTb[_heroId] = nil
	end
	if show then
		local _id = XTHD.playHeroDubEffect(_heroId, "idle")
		if _id then
			self._effSoundTb[_heroId] = _id
		end
	end
end

--添加或者移除数据，从已选列表中移除，PVP模式总是要多判断的啦，或许以后还会有其他模式，But don't worry, we can make it.
function XuanZeYingXiongNewLayer:AddOrRemoveData(tpm_data,_bSel)
	if _bSel == false then
		if self._battle_type ~= BattleType.PVE 
			and self._battle_type ~= BattleType.ELITE_PVE
			and self._battle_type ~= BattleType.DIFFCULTY_COPY then
			self._PVP_Teams[self._current_Team_num][1][#self._PVP_Teams[self._current_Team_num][1] +1] = tpm_data
		end
		if not tpm_data.isHelp then
			self.m_heroItem[#self.m_heroItem + 1] = tpm_data --往表中添加数据
		end
	elseif _bSel == true then
		if not tpm_data.isHelp then
			for i=1,#self.m_heroItem do
				if tonumber(self.m_heroItem[i]["heroid"]) == tonumber(tpm_data["heroid"]) then
					table.remove(self.m_heroItem,i)
					break
				end
			end
		end

		if self._battle_type ~= BattleType.PVE 
			and self._battle_type ~= BattleType.ELITE_PVE
			and self._battle_type ~= BattleType.DIFFCULTY_COPY then
			for j=1,#self._PVP_Teams[self._current_Team_num][1] do
				if tonumber(self._PVP_Teams[self._current_Team_num][1][j]["heroid"]) == tonumber(tpm_data["heroid"]) then
					table.remove(self._PVP_Teams[self._current_Team_num][1],j)
					break
				end
			end
		end
	end
end

function XuanZeYingXiongNewLayer:_newSkeltonton( id, _data, _spine)

	local nId = self._selectData.getAniId(id)
	cclog("上阵"..id .. "res/spine/" .. nId .. ".json", "res/spine/" .. nId .. ".atlas")
	local _hero = XTHDTouchSpine:create( id,"res/spine/" .. nId .. ".skel", "res/spine/" .. nId .. ".atlas", 1, _spine)
	if  _hero then
		_hero:setShowDes(true)
		_hero:setNeedMoveFunc(true)
		local _heroScale = _data and _data.scale or gameData.getDataFromCSV( "GeneralInfoList", {["heroid"]=id} )["scale"]
		_heroScale = tonumber(_heroScale) or 1
		_hero:setScale( _heroScale )
		_hero._scale = _heroScale
		
		_hero:setTouchEndedCallback(function()
			if _data and _data.isHelp then
				XTHDTOAST(LANGUAGE_TIPS_WORDS171)------"该英雄不可离开队伍！")
				return
			end
			self:AddOrRemoveData({["heroid"] = _hero.heroid},true)			--操作数据，添加或者移除
			local tmpData = {heroid = _hero.heroid, _bSel = true}
			self:RefreshSpine(tmpData)
			if _hero.cellindex then
				self.m_tableView:updateCellAtIndex(_hero.cellindex)
			else
				self.m_tableView:reloadDataAndScrollToCurrentCell()
			end
			
			local _heroData = DBTableHero.getDataByID(id)
			local pNum = tonumber(_heroData["power"]) or 0
			self.m_labTotalCombatData:setString(tonumber(self.m_labTotalCombatData:getString()) - pNum)
			self:playSoundEffect(_hero.heroid, false)
			self:refreshTeamMenberCount(self._current_Team_num) 
		end)
		
		return _hero;
	end	
end

--上阵人数没达到人数限制的时候，弹出提示框
function XuanZeYingXiongNewLayer:showTipDialog(callback)
	local _confirmLayer 
	_confirmLayer = XTHDConfirmDialog:createWithParams( {
		isHide = false,
		leftCallback = function ( ... )
			_confirmLayer:removeFromParent()
		end,
        rightCallback  = function ()
        	if callback then
        		callback()
        	end
    	end,
        msg = LANGUAGE_TIPS_WORDS164,--------"还有英雄可以上阵，是否直接进入战斗？"
    } );
	self:addChild(_confirmLayer,4)
end

--[[
	判断是否有英雄在阵上，如果有则返回true，否则返回false
]]
function XuanZeYingXiongNewLayer:_bHerosOnMartix()
	if self._Spine_List and #self._Spine_List > 0 then
		return true
	else
		return false
	end
end

function XuanZeYingXiongNewLayer:_freshDartBarInfo( ... )
	if (self._battle_type ~= BattleType.PVP_DART_DEFENCE and self._battle_type ~= BattleType.ZHENQI_DEFENCE)
	 or not self._dartConditionStrings then --or not self._dartConditionOver then
		return
	end
	local _allStar = 0
	local _allLv = 0
	local _allAd = 0
	local _haveHero = false
	local _pHeroId = tonumber(self._conditionTable[4]) or 0
	if #self._Spine_List > 0 then
		for k,v in pairs(self._Spine_List) do
			if _pHeroId == v.heroid then
				_haveHero = true
			end
			local pData = DBTableHero.getDataByID( v.heroid )
			if pData then
				_allStar = _allStar + tonumber(pData.star) or 0
				_allLv = _allLv + tonumber(pData.level) or 0
				_allAd = _allAd + tonumber(pData.advance) or 0
			end
		end
	end

	local _color1 = cc.c3b(30, 255, 56)
	local _color2 = cc.c3b(255, 255, 255)
	for i=1, #self._conditionTable do
		local pV = tonumber(self._conditionTable[i]) or 0
		local pStr = self._dartConditionStrings[i]
		-- local pSp = self._dartConditionOver[i]
		if pStr and pV > 0 then
			local isTrue = false
			if i == 1 then
				isTrue = _allStar >= pV
			elseif i == 2 then
				isTrue = _allLv >= pV
			elseif i == 3 then
				isTrue = _allAd >= pV
			elseif i == 4 then
				isTrue = _haveHero
			end

			pStr:setColor(isTrue and _color1 or _color2)
			-- if pSp then
			-- 	pSp:setVisible(isTrue)
			-- end
		end
	end
end

--刷新展示区的spine，增删操作 bl_need_animation,标示是否需要执行添加或者删除的烟雾动画
--,cellindex 标示该英雄在列表中的位置 
function XuanZeYingXiongNewLayer:RefreshSpine( sParams )	
	local heroid = sParams.heroid
	local _bSel = sParams._bSel
	local bl_need_animation = sParams.bl_need_animation
	local cellindex = sParams.cellindex
	local isInit = sParams.isInit
	local _sData = sParams.sData
	local bg_sp = self --self:getChildByName("bg_sp")
	if not heroid then
		return
	end

	local function freshPos( ... )
		if(not isInit and #self._Spine_List == 1) then
			self._Spine_List[1]["spine"]:setLocalZOrder(1);
			self._Spine_List[1]["spine"]:setPosition(self._getPreviewItemPos[2])
		else
			for i =1, #self._Spine_List  do
				if i > 5 then
					break
				end
				if i % 2 == 0 then
					self._Spine_List[i]["spine"]:setLocalZOrder(2);
				else
					self._Spine_List[i]["spine"]:setLocalZOrder(1);
				end
				self._Spine_List[i]["spine"]:setPosition(self._getPreviewItemPos[i])
			end
		end
	end

	if not _bSel then
		local spine = self:_newSkeltonton(heroid , _sData, sParams._spine)
		if spine then
			if cellindex then
				spine.cellindex = cellindex
			end
			spine:setAnimation(0,"idle",true)
			spine.heroid = heroid
			spine:setAnchorPoint(cc.p(0.5, 0))
			local _heroScale = spine._scale
			bg_sp:addChild(spine,tonumber(heroid)%3+1)
			local _attackrange = 0

			if _sData then
				_attackrange = tonumber(_sData.attackrange) or 0
			else
				for i=1,#self.m_heroItem do
					if tonumber(self.m_heroItem[i]["heroid"]) == tonumber(heroid) then
						_attackrange = tonumber(self.m_heroItem[i]["attackrange"])
						break
					end
				end
			end
			self._Spine_List[#self._Spine_List+1] = {["heroid"]= heroid ,["spine"]= spine,["attackrange"] =_attackrange, _data = _sData}
			
			table.sort(self._Spine_List, function ( data1, data2 )
				local num1 = tonumber(data1["attackrange"]) or 0
				local num2 = tonumber(data2["attackrange"]) or 0
				if num1 ~= num2 then
					return num1 < num2
				end
				return data1["heroid"] < data2["heroid"]
			end)
		
			freshPos()

			if not bl_need_animation then
				spine:setVisible(false)
				spine:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function ()
					local spSmoke = sp.SkeletonAnimation:create("res/spine/effect/line_up/yxsz.json","res/spine/effect/line_up/yxsz.atlas")
					spSmoke:setAnchorPoint(cc.p(0.5, 0))
					spSmoke:setPosition(spine:getPosition())
					spSmoke:setScale(2)
					spSmoke:setAnimation(0,"animation",false)
					bg_sp:addChild(spSmoke,spine:getLocalZOrder()-1)
					performWithDelay(spSmoke,function()
						spSmoke:removeFromParent()
						end, 2)
					spine:setOpacity(60)
					local scaleAction = cc.ScaleTo:create(0.2, _heroScale)
					spine:runAction(cc.Spawn:create( scaleAction, cc.Sequence:create(
						cc.DelayTime:create(0.04), 
						cc.CallFunc:create(function()
							spine:setVisible(true)
						end), 
						cc.FadeTo:create(0.14,255)
					)))
				end)))
			end
		end
	else
		for i = #self._Spine_List,1,-1 do
			if tostring(self._Spine_List[i]["heroid"]) == tostring(heroid) and not _sData then
				local spine =self._Spine_List[i]["spine"]
				table.remove(self._Spine_List,i)
				spine:removeFromParent()
				if  bl_need_animation then
					freshPos()
				else
					freshPos()
				end
				break
			end
		end
	end
	self:_freshDartBarInfo()
	if self._start_battle_btn then
		if #self._Spine_List < 1 then
			-- if self._battle_type == BattleType.PVE or self._battle_type == BattleType.ELITE_PVE then
				self._start_battle_btn:setVisible(false)
				if self._battle_effect then
					self._battle_effect:setVisible(false)
				end
			-- end
		else
			self._start_battle_btn:setVisible(true)
			if self._battle_effect then
				if self._battle_type ~= BattleType.PVP_DEFENCE 
					and self._battle_type ~= BattleType.CAMP_DEFENCE 
					and self._battle_type ~= BattleType.PVP_LADDER_DEFENCE 
					and self._battle_type ~= BattleType.PVP_DART_DEFENCE
					and self._battle_type ~= BattleType.ZHENQI_DEFENCE
					and self._battle_type ~= BattleType.GUILDWAR_TEAM then
					self._battle_effect:setVisible(true)
				end
			end
		end
	end
	
	if self._battle_power_label then
		self._battle_power_label:setVisible(self._start_battle_btn:isVisible())
	end
	if self.m_labTotalCombatData then
		self.m_labTotalCombatData:setVisible(self._battle_power_label:isVisible())
	end
end

--[[检查点击的元素是否已经被选中，此处只坐数据比较，不进行删除添加操作 其中:
	self.m_heroItem 存储所有选中的英雄，不区分副本模式还是PVP模式
]]
function XuanZeYingXiongNewLayer:_bTheItemIsSelect(_temp_data)
	if _temp_data.isHelp then
		return true
	end
	for i = #self.m_heroItem,1,-1  do
		if tonumber(self.m_heroItem[i]["heroid"]) == tonumber(_temp_data["heroid"]) then
			if not _temp_data.isHelp then
				return true
			end
		end
	end
	return false
end

--种族战需要传递一些敌方队伍信息，则在此开个方法
function XuanZeYingXiongNewLayer:setCampBattleEnemyData(camp_data)
	self._camp_enemy_data = camp_data
end

function XuanZeYingXiongNewLayer:getCampBattleEnemyData()
	return self._camp_enemy_data or {}
end

--[[
	@param: battle_type: 战斗类型 ①
	@param: instancingid: 关卡Id	 ②
	--------上面两个为普通副本的挑战布阵参数，且只需要上面两个，--下面的参数则是从设置防守队伍信息开始的-----

	@param: param { ["user_data"] = xx, ["rivalId"] = xx },从竞技场设置防守队伍开始，传进来已有的队伍信息，
	sour1_type,当设置自己的防守队伍的时候，该参数不为空，标示当前是设置防守队伍信息
				目前有PVP,种族战 需要设置防守队伍，其他的暂时还没有
	teamIndex ,同样是设置防守队伍携带的参数，表示是从第几队点击来的
	cityId , 种族战传进来的参数，且目前只有种族战才用到

	20160706
	注：EQUIP_PVE 装备副本模式下，传进来的instancingid 为道装备副本Id，根据此Id,查询ShenbinggeList数据表，获取该关卡的上阵人数限制(limit字段)，
]]

function XuanZeYingXiongNewLayer:create(battle_type, instancingid, param, source_type, teamIndex, cityId)
	-- print("the fightting block is",instancingid)
	local obj = XuanZeYingXiongNewLayer.new()
	obj._battle_type = battle_type or BattleType.PVE--战斗类型 BattleType.PVE BattleType.PVP_CHALLENGE
	obj._instancingid = instancingid
	if source_type then
		obj._user_data = param or {}
		obj._target_teamIndex = teamIndex or 1 
	else
		if param and param["teams"] then
			obj._user_data = param["teams"]
			obj.m_tmpRivalData = param; 
		end
	end
	-- 在这块用来判定是否能否将人物下阵，在设置防守队伍的时候
	if obj._battle_type == BattleType.PVP_DEFENCE 
		or obj._battle_type == BattleType.PVP_LADDER_DEFENCE 
		or obj._battle_type == BattleType.PVP_DART_DEFENCE 
		or obj._battle_type == BattleType.ZHENQI_DEFENCE then
		obj._tmp_user_data = obj._user_data
		obj._dartInfo = _dartInfo
	elseif obj._battle_type == BattleType.CAMP_DEFENCE then
		obj._cityId = cityId
	elseif obj._battle_type == BattleType.GUILDWAR_TEAM then
		obj.perGuildData = param.list
	end
	obj:init()
	return obj
end
function XuanZeYingXiongNewLayer:createForPve(battle_type, instancingid,rewardData,source_type)--pve副本专用byhuangjunjian
	-- print("XuanZeYingXiongNewLayer需要封装的数据")
	-- print_r(rewardData)
	local obj = XuanZeYingXiongNewLayer.new()
	obj._battle_type = battle_type or BattleType.PVE--战斗类型 BattleType.PVE BattleType.PVP_CHALLENGE
	obj._instancingid = instancingid
	if source_type then
		obj._user_data = param or {}
		obj._target_teamIndex = teamIndex or 1 
	else
		if param and param["teams"] then
			obj._user_data = param["teams"]
			obj.m_tmpRivalData = param; 
		end
	end
	obj._reward_item=rewardData
	if rewardData and rewardData.helps and rewardData.helps[1] then --为了不影响正常使用临时屏蔽
		obj._helps = rewardData.helps[1]
	end
	-- 在这块用来判定是否能否将人物下阵，在设置防守队伍的时候
	if obj._battle_type == BattleType.PVP_DEFENCE 
		or obj._battle_type == BattleType.PVP_LADDER_DEFENCE 
		or obj._battle_type == BattleType.PVP_DART_DEFENCE
		or obj._battle_type == BattleType.ZHENQI_DEFENCE then
		obj._tmp_user_data = obj._user_data
	elseif obj._battle_type == BattleType.CAMP_DEFENCE then
		obj._cityId = cityId
	end
	obj:init()
	return obj
end

--[[
	createWithParams{
		battle_type  	--战斗类型
		instancingid, 	--战斗关卡id
		teaminfo, 			--传进来的队伍信息，如果是进攻，则不需要传此参数，因为进攻队伍信息都存在本地了，目前只有PVP和种族战用到了该参数有用来设置防守队伍
		source_type,	--调用源
		teamIndex,		--目标队伍id，需要设置的防守队伍的队伍id
		cityId 			--种族战cityID 
		godBeast_data 	=  --神兽战需要传递进来的英雄和刷新数据函数
		Camp_data = hero_data --种族战战斗选人的时候，传进来的防守英雄信息，这些英雄不能参加战斗了啦
	}
]]
function XuanZeYingXiongNewLayer:createWithParams(params)	
 --    print("XuanZeYingXiongNewLayer需要封装的数据")
	-- print_r(params)
	local function initDatas( obj, params )
		obj._battle_type = params.battle_type or BattleType.PVE
		obj._instancingid = params.instancingid
		
		print(" params.instancingid --> ", params.instancingid)
		if params.source_type then
			obj._user_data = params.param or {}
			obj._target_teamIndex = params.teamIndex or 1 
		end

		--种族防守队伍设置参数解析
		if obj._battle_type == BattleType.CAMP_DEFENCE then
			obj._user_data = params.team_data
			obj._target_teamIndex = params.teamIndex or 1
			obj._cityId = params.cityId 
			obj._cityName = params.cityName
--			dump(params.team_data)
		end

		if params.teaminfo and params.teaminfo["teams"] then
			obj._user_data = params.teaminfo["teams"]
			-- 保存敌人的全部信息  
			obj.m_tmpRivalData = params.teaminfo
			obj._user_data = params.team_data
		end
	
		if obj._battle_type == BattleType.GUILDWAR_TEAM then
			obj._target_teamIndex = params.teamIndex or 1
			--obj._user_data = params.team_data
			obj._user_data = params.team_data
--			dump(params.team_data)
		end
		
		-- 在这块用来判定是否能否将人物下阵，在设置防守队伍的时候
		if obj._battle_type == BattleType.PVP_DEFENCE 
			or obj._battle_type == BattleType.PVP_LADDER_DEFENCE 
			or obj._battle_type == BattleType.PVP_DART_DEFENCE
			or obj._battle_type == BattleType.ZHENQI_DEFENCE then
			obj._tmp_user_data = obj._user_data
			if params.heroLimit then
				obj._selfHeroLimitStar = tonumber(params.heroLimit) or 1
			end
			if params.dartInfo then
				obj._dartType = tonumber(params.dartInfo._dartType) or 1
				obj._conditionTable = params.dartInfo._conditionTable or {}
				obj._teamTable = params.dartInfo._teamTable or {}
			end
		elseif obj._battle_type == BattleType.MULTICOPY_DEFENCE then
			obj._multiId = tonumber(params.heroId) or -1
			obj._multiQuiltyNum = tonumber(params.heroQuiltyLimit) or 0
		elseif obj._battle_type == BattleType.CAMP_PVP then
			obj._camp_pvp_def_data = params["Camp_data"]
			obj._camp_enemy_data = params["Camp_enemy_Data"]
		elseif obj._battle_type == BattleType.ZHENQI_FIGHT_ROB 
	  	   or obj._battle_type == BattleType.ZHENQI_FIGHT_OCCUPY then
			obj._camp_pvp_def_data = params["Camp_data"]
		end
	end

	local obj = XuanZeYingXiongNewLayer.new()
	initDatas(obj, params)
	obj:init()
	return obj
end

function XuanZeYingXiongNewLayer:showOneHelp( _heroId )
	if self._selectData.isNewHelps(_heroId) then
		local _data
		for k,v in pairs(self._heroIdCacheTb) do
			local pId = tonumber(v.id) or 0
			if pId == _heroId then
				_data = v.data
				break
			end
		end
		for k,v in pairs(self._data_source) do
			local pId = tonumber(v.heroid) or 0
			if pId == _heroId then
				v.isInit = true
				local pNum = tonumber(k) - 1
				self.m_tableView:updateCellAtIndex(pNum)
				break
			end
		end
		local pB = true
		local tmpData = {heroid = _heroId, isInit = pB, sData = _data}
		self:RefreshSpine(tmpData)
		local pAni = createAnimal({id = _heroId, _type = ANIMAL_TYPE.PLAYER, helps = _data})
		if pAni == nil then
			return
		end
		if pAni then
			pAni:_unregisterSpineEventHandler()
		end
	end
end

function XuanZeYingXiongNewLayer:GuildTishiGroup(data)
	data = json.decode(data._list)
--	dump(data)
	local idnex = 1
	for i = 1,#data do
		if #data[i].petIds < 1 then
			index = i
			break;
		end
	end
	
	for i = 1,#self._groupbtnList do
		if self._groupbtnList[i]:getChildByName("hand") then
			self._groupbtnList[i]:getChildByName("hand"):removeFromParent()
		end
	end

	local hand = sp.SkeletonAnimation:create("res/spine/guide/yd.json", "res/spine/guide/yd.atlas", 1)
	hand:setAnimation(0, "animation", true)
	hand:setPosition(self._groupbtnList[index]:getContentSize().width * 0.5,self._groupbtnList[index]:getContentSize().height*0.5)
	self._groupbtnList[index]:addChild(hand,10)
	hand:setName("hand")

--	--self._groupbtnList[index]:setSelected(true)
	print("========================",index)

end

function XuanZeYingXiongNewLayer:addShieldLayout()
	local _lay = XTHDDialog:create(0)
	cc.Director:getInstance():getRunningScene():addChild(_lay, 100)
	performWithDelay(_lay, function()
		_lay:removeFromParent()
	end, 0.01)
end

function XuanZeYingXiongNewLayer:addGuide( )
	-- if gameUser.getInstancingId() == 13 then -----第28组引导 	
 --        YinDaoMarg:getInstance():addGuide({index = 9,parent = self},28) ---- 
	--    	if #self._canSelectedHeros > 1 then 
	-- 	    YinDaoMarg:getInstance():addGuide({ -----选第一个人
	-- 	        parent = self,
	-- 	        target = self._canSelectedHeros[1],
	-- 	        index = 8,
	-- 	        isButton = false,
	-- 	    },28)
	-- 	end 
    YinDaoMarg:getInstance():addGuide({ -----开战        
        parent = self,
        target = self._start_battle_btn,
        index = 8,
		needNext = false,
    },11)	
    YinDaoMarg:getInstance():addGuide({index = 7,parent = self},20) ---- 
    YinDaoMarg:getInstance():doNextGuide()
    if #self._canSelectedHeros > 1 and self._selectData.haveCanOnTeam() then 
		YinDaoMarg:getInstance():onlyCapter1Guide({
            parent = self,
            target = self._canSelectedHeros[2],
            isButton = false,
            extraCall = function( )
	    		YinDaoMarg:getInstance():onlyCapter1Guide({
	    			parent = self,
	    			target = self._start_battle_btn
	    		}) -----执行第一章的特殊引导 (开战)			            	
            end
        }) -----执行第一章的特殊引导 (返回)
	else
	    YinDaoMarg:getInstance():onlyCapter1Guide({
	    	parent = self,
	    	target = self._start_battle_btn
	    }) -----执行第一章的特殊引导 (开战)			
	end 
end

return XuanZeYingXiongNewLayer
