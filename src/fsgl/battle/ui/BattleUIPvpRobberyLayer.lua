
--竞技
BattleUIPvpRobberyLayer = class("BattleUIPvpRobberyLayer", function()

    return XTHD.createLayer()
end)

function BattleUIPvpRobberyLayer:ctor(data,battle_type)
	--自动战斗按钮
	self._battle_type = battle_type
	-- local btnAuto = createAutoButton(battle_type)--XTHDSprite:create("res/image/tmpbattle/autocombat_off.png")
	-- btnAuto:setPosition(cc.p(btnAuto:getContentSize().width / 2 + 17, self:getContentSize().height - btnAuto:getContentSize().height / 2 - 10))
	-- self:addChild(btnAuto)	
	
   	self.addfeicui=tonumber(data.addFeicui) or 0
	self.allgold=tonumber(data.addSilver) or 0
	self.allhp=0

	-- 构建双方头像和名字
	local playerCampId = gameUser.getCampID()
	playerCampId = playerCampId == 0 and 1 or playerCampId
	local targetCampId = data.campId or gameUser.getCampID()
	targetCampId = targetCampId == 0 and 1 or targetCampId
	
	local playerName = gameUser.getNickname()
	local targetName =data.name 
	local _battleType = data.battleType or BattleType.PVP_CHALLENGE
	if _battleType == BattleType.PVP_SHURA then
		self._notPlay = true
	end

	local width = self:getContentSize().width;
	local height = self:getContentSize().height;

	-- 名字背景图
	local _nameBg = cc.Sprite:create("res/image/plugin/competitive_layer/pvp_nameBg.png");
	_nameBg:setAnchorPoint( cc.p(0.5, 1) );
	_nameBg:setPosition( cc.p(width*0.5, height-7) );
	self:addChild(_nameBg);

	-- 玩家徽章
	local playerCampIcon = cc.Sprite:create("res/image/common/camp_Icon_" .. playerCampId .. ".png" );
	playerCampIcon:setScale(0.8);
	playerCampIcon:setPosition( cc.p(43, _nameBg:getContentSize().height/2-3) );
	_nameBg:addChild(playerCampIcon);

	local _labPlayerName = XTHDLabel:createWithParams( {
			["text"] = playerName ,
			["size"] = 18,
			["color"] = cc.c3b(255, 255, 255)
		} );
	_labPlayerName:setAlignment(cc.TEXT_ALIGNMENT_LEFT)--？？
	_labPlayerName:setAnchorPoint(cc.p(0.5,0.5));
	_labPlayerName:setPosition( cc.p(130, playerCampIcon:getPositionY()) );
	_nameBg:addChild( _labPlayerName );


	-- 对手徽章
	local targetCampIcon = cc.Sprite:create("res/image/common/camp_Icon_" .. targetCampId .. ".png" );
	if targetCampIcon then
		targetCampIcon:setScale(0.8);
		targetCampIcon:setPosition( cc.p(_nameBg:getContentSize().width-playerCampIcon:getPositionX(), playerCampIcon:getPositionY()) );
		_nameBg:addChild(targetCampIcon);
	end

	local _labEnemyName = XTHDLabel:createWithParams( {
			["text"] = targetName ,
			["size"] = 18,
			["color"] = cc.c3b(255, 255, 255)
		} );
	_labEnemyName:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
	_labEnemyName:setAnchorPoint(cc.p(0.5,0.5));
	_labEnemyName:setPosition( cc.p(_nameBg:getBoundingBox().width-_labPlayerName:getPositionX(), _labPlayerName:getPositionY()) );
	_nameBg:addChild( _labEnemyName );
	-- print(battle_type..BattleType.PVP_CHALLENGE.."类型")
	if battle_type and battle_type == BattleType.PVP_CHALLENGE then
		
		local pDaaa = data.team or data.teams
		if pDaaa and pDaaa[1].heros then
			local teaminfo = pDaaa[1].heros
			for k,v in pairs(teaminfo) do
				self.allhp = math.ceil(self.allhp+tonumber(v.curHp))
			end
		end
		-- 可掠夺
		local _plunderBg = cc.Sprite:create("res/image/plugin/competitive_layer/pvp_robe.png" );
		_plunderBg:setAnchorPoint(1,0.5)
		_plunderBg:setPosition(self:getContentSize().width-145, self:getContentSize().height-24)
		self:addChild(_plunderBg);


		 --银两
	    local gold_bg = cc.Sprite:create("res/image/common/topbarItem_bg.png") 
	    gold_bg:setScaleX(111/136)
	    gold_bg:setAnchorPoint(1,0.5)
	    gold_bg:setPosition(self:getContentSize().width-13, _plunderBg:getPositionY())
	    self:addChild(gold_bg)

	    local _gold = cc.Sprite:create("res/image/common/header_gold.png") 
	    _gold:setScaleX(1/gold_bg:getScaleX())
	    _gold:setPosition(0, gold_bg:getContentSize().height/2)
	    gold_bg:addChild(_gold)

	    local _labGoldCount = getCommonWhiteBMFontLabel("0",1000000)
	    _labGoldCount:setPosition(gold_bg:getPositionX()-gold_bg:getContentSize().width/2+10, gold_bg:getPositionY()-7)
	    self:addChild(_labGoldCount)

	    --翡翠
	    local _feicui_bg = cc.Sprite:create("res/image/common/topbarItem_bg.png")
	    _feicui_bg:setScaleX(gold_bg:getScaleX())
	    _feicui_bg:setAnchorPoint(1,0.5)
	    _feicui_bg:setPosition(gold_bg:getPositionX(), gold_bg:getPositionY()-37)
	    self:addChild(_feicui_bg)

	     local _feicui  = cc.Sprite:create("res/image/common/header_feicui.png")
	     _feicui:setScaleX(1/gold_bg:getScaleX())
	    _feicui:setPosition(0, _feicui_bg:getContentSize().height/2)
	    _feicui_bg:addChild(_feicui)

	    local _labFeicuiCount = getCommonWhiteBMFontLabel("0",1000000)
	    _labFeicuiCount:setPosition(_feicui_bg:getPositionX()-_feicui_bg:getContentSize().width/2+10, _feicui_bg:getPositionY()-7)
	    self:addChild(_labFeicuiCount)

	    -- 监听/刷新 银两/翡翠 数据
		local  total_num=0
		XTHD.addEventListener({name = "GOLD_COPY_GET_GOLD_NUM" ,callback = function(event)
        local data = event["data"]
	        local hurt_num = data["hurt_num"] or 0
	        total_num=total_num+tonumber(hurt_num)

	        local _goldSet = math.ceil((total_num/self.allhp)*tonumber(self.allgold))
	        if _goldSet>=tonumber(self.allgold) then
	           _goldSet=tonumber(self.allgold)
	    	end
		    print("获取资源"..total_num.."总血量"..self.allhp.."银两".._goldSet)
	        local _feicuiSet =math.ceil((total_num/tonumber(self.allhp))*tonumber(self.addfeicui))
	        if _feicuiSet>=tonumber(self.addfeicui) then
	           _feicuiSet=tonumber(self.addfeicui)
	    	end
	        _labGoldCount:runAction(cc.Sequence:create(cc.EaseSineIn:create(cc.ScaleTo:create(0.15,1.5)),cc.CallFunc:create(function()
	        		_labGoldCount:setString(tostring(_goldSet));
	        	end),cc.EaseSineOut:create(cc.ScaleTo:create(0.05,1.0))))

	         _labFeicuiCount:runAction(cc.Sequence:create(cc.EaseSineIn:create(cc.ScaleTo:create(0.15,1.5)),cc.CallFunc:create(function()
	        		_labFeicuiCount:setString(tostring(_feicuiSet));
	        	end),cc.EaseSineOut:create(cc.ScaleTo:create(0.05,1.0))))

    	end})
	else
		XTHD.removeEventListener("GOLD_COPY_GET_GOLD_NUM")
	end
    -- 波次提示0
 --    self.m_labIndex = getCommonWhiteBMFontLabel("1/1");
	-- self.m_labIndex:setPosition( cc.p(width*0.5, height*0.9-14) );
	-- self:addChild( self.m_labIndex );
	
	if _battleType == BattleType.CAMP_PVP then  --------种族战
    	XTHD.addEventListener({name = CUSTOM_EVENT.SHOW_CAMPWAROVERED,callback = function( ) 
    		XTHD.dispatchEvent({name = EVENT_NAME_BATTLE_PAUSE})
	        local layer = XTHDConfirmDialog:createWithParams({
	            msg = LANGUAGE_CAMP_WAROVERTIP,--------
	            leftVisible = false,
	            rightCallback = function( )
                	cc.Director:getInstance():popScene()
    				musicManager.setBackMusic(XTHD.resource.music.music_bgm_camp)
	            end
	        })
	        layer:getContainerLayer():setClickable(false)
	        self:addChild(layer)
    	end})
	end 

    local handle = function ( event )
        if event == "cleanup" then
            self:onCleanup()
        end
    end
    self:registerScriptHandler(handle)
end

function BattleUIPvpRobberyLayer:onCleanup()
    XTHD.removeEventListener(CUSTOM_EVENT.SHOW_CAMPWAROVERED)    	
    XTHD.removeEventListener("GOLD_COPY_GET_GOLD_NUM")
    if self._battle_type == BattleType.CAMP_PVP or self._battle_type == BattleType.CAMP_TEAMCOMPARE or self._battle_type == BattleType.CASTELLAN_FIGHT then
	    musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_camp,true)
    else
	    if not self._notPlay then
		    musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_main,true)
		end
	end
end
function BattleUIPvpRobberyLayer:create(data,battle_type)
    return BattleUIPvpRobberyLayer.new(data,battle_type) 
end
