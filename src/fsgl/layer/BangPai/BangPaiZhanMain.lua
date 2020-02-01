--帮派战初始界面

local BangPaiZhanMain = class("BangPaiZhanMain",function()
		return XTHD.createBasePageLayer({bg="res/image/guild/guildWar/guildWar_bg.png",isOnlyBack = true})
	end)

function BangPaiZhanMain:ctor(_data)
	self._fontSize = 18
	self.btnPos = nil
	self.seasonNamePos = nil
	self.seasonTimePos = nil
	-- self.applyDescPos = cc.p(self.seasonTimePos.x,self.seasonNamePos.y - 75)

	self.stageTimeLabelTable = {}
	self.guildWarData = {}

	self:setGuildWarData(_data)
	self:initLayer()
end

function BangPaiZhanMain:onCleanup()
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey("res/image/guild/guildWar/guildWar_fightBg.png")
end

function BangPaiZhanMain:initLayer()

	local _currentStage = self.guildWarData.state or 1

	local _introduceBtn = XTHD.createButton({
        normalFile = "res/image/common/btn/tip_up.png"
        ,selectedFile  = "res/image/common/btn/tip_down.png"
        ,endCallback = function()
            local _popLayer = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=18},true)
            LayerManager.addLayout(_popLayer,{noHide = true})
        end
        })
    _introduceBtn:setAnchorPoint(cc.p(0,1))
    _introduceBtn:setPosition(cc.p(32,self:getContentSize().height-30))
    self:addChild(_introduceBtn)

    self.seasonNamePos = cc.p(self:getContentSize().width/2,self:getContentSize().height - 15)
    self.seasonTimePos = cc.p(self.seasonNamePos.x,self.seasonNamePos.y - 68 - 10)
    self.applyDescPos = cc.p(self.seasonTimePos.x,self.seasonTimePos.y - 40)

	local _upPosY = self:getContentSize().height-257
	local _progressBg = cc.Sprite:create("res/image/activities/logindaily/logindaily_progressBg.png")
	_progressBg:setScale(0.75)
	-- _progressBg:setScale((self:getContentSize().width - 415)/_progressBg:getContentSize().width)
	_progressBg:setAnchorPoint(cc.p(0.5,0.5))
	_progressBg:setPosition(cc.p(self:getContentSize().width/2,_upPosY))
	_progressBg:setRotation(-30)
	self:addChild(_progressBg)
	
	-- _progressSprite:setScaleY(0.75)
	local _progress = cc.ProgressTimer:create(cc.Sprite:create("res/image/activities/logindaily/logindaily_progress.png"))
	self.progress = _progress
	_progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	_progress:setMidpoint(cc.p(0,0.5))
	_progress:setBarChangeRate(cc.p(1,0))
	_progress:setPercentage(0)
	_progress:setPosition(cc.p(_progressBg:getContentSize().width/2,_progressBg:getContentSize().height/2))
	_progressBg:addChild(_progress)

	for i=1,4 do
		local _imgkey = "logindaily_Spbg.png"
		if i == 4 then
			_imgkey = "logindaily_Spbg.png"
		elseif  i==1 then
			_imgkey = "logindaily_Spbg.png"
		end
		local _posX = _progressBg:getContentSize().width/3*(i-1)
		local _stageSp = cc.Sprite:create("res/image/activities/logindaily/" .. _imgkey)
		_stageSp:setName("stageSp" .. i)
		_stageSp:setPosition(cc.p(_posX,_progressBg:getContentSize().height/2))
		_progressBg:addChild(_stageSp)

		local _timeLabel = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_STAGE[i],22,"res/fonts/def.ttf")
		_timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
		_timeLabel:setName("timeLabel" .. i)
		_timeLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("baise"))
		_timeLabel:enableShadow(BangPaiFengZhuangShuJu.getTextColor("baise"),cc.size(0.4,-0.4),0.4)
		_timeLabel:setPosition(cc.p(_posX,_progressBg:getContentSize().height/2 + 35))
		_progressBg:addChild(_timeLabel)
		local _stageBg = ccui.Scale9Sprite:create()
		_stageBg:setContentSize(60,40)
		_stageBg:setPosition(cc.p(_posX,_progressBg:getContentSize().height/2 - 43))
		_progressBg:addChild(_stageBg)
		local guildWarstage = {"点将","调整","对战","结果"}
		local _stagetext = XTHDLabel:create(guildWarstage[i],30,"res/fonts/def.ttf")
		_stagetext:enableOutline(cc.c4b(0,0,0,255),2)
		_stagetext:setPosition(cc.p(_stageBg:getContentSize().width/2,_stageBg:getContentSize().height/2))
		_stageBg:addChild(_stagetext)
	end

	local _allBtnBg = cc.Sprite:create("res/image/guild/guildWar/guildWar_operateBg.png")
	_allBtnBg:setAnchorPoint(cc.p(1,0))
	_allBtnBg:setPosition(cc.p(self:getContentSize().width,5))
	self:addChild(_allBtnBg)
	_allBtnBg:setOpacity(0)
	--六个按钮
	--战报按钮
	local zhanbao = XTHD.createButton({
		normalFile = "res/image/guild/guildWar/operateBtnNormal_record.png",
    	selectedFile = "res/image/guild/guildWar/operateBtnSelected_record.png"
	})
	zhanbao:setTouchEndedCallback(function()
		self:selectedCallback(5)
	end)
	zhanbao:setAnchorPoint(0,0.5)
	zhanbao:setScale(0.8)
	zhanbao:setPosition(_introduceBtn:getPositionX(),_introduceBtn:getPositionY()-60-zhanbao:getContentSize().height/2)
	self:addChild(zhanbao)
	--奖励
	local jiangli = XTHD.createButton({
		normalFile = "res/image/guild/guildWar/operateBtnNormal_reward.png",
    	selectedFile = "res/image/guild/guildWar/operateBtnSelected_reward.png"
	})
	jiangli:setTouchEndedCallback(function()
		self:selectedCallback(6)
	end)
	jiangli:setAnchorPoint(0,0.5)
	jiangli:setScale(0.8)
	jiangli:setPosition(zhanbao:getPositionX(),zhanbao:getPositionY()-40-jiangli:getContentSize().height/2)
	self:addChild(jiangli) 
	--主将
	local zhujiang = XTHD.createButton({
		normalFile = "res/image/guild/guildWar/operateBtnNormal_lord.png",
    	selectedFile = "res/image/guild/guildWar/operateBtnSelected_lord.png"
	})
	zhujiang:setTouchEndedCallback(function()
		self:selectedCallback(1)
	end)
	zhujiang:setAnchorPoint(1,0.5)
	zhujiang:setScale(0.8)
	zhujiang:setPosition(self:getContentSize().width-32, self:getContentSize().height * 0.4)
	--self:addChild(zhujiang) 
	--编队
	local biandui = XTHD.createButton({
		normalFile = "res/image/guild/guildWar/operateBtnNormal_formation.png",
    	selectedFile = "res/image/guild/guildWar/operateBtnSelected_formation.png"
	})
	biandui:setTouchEndedCallback(function()
		--self:selectedCallback(2)
		self:AdjustmentTroops()
	end)
	biandui:setAnchorPoint(1,0.5)
	biandui:setScale(0.8)
	biandui:setPosition(self:getContentSize().width-32,66)
	self:addChild(biandui) 
	--布阵
	local buzhen = XTHD.createButton({
		normalFile = "res/image/guild/guildWar/operateBtnNormal_embattle.png",
    	selectedFile = "res/image/guild/guildWar/operateBtnSelected_embattle.png"
	})
	buzhen:setTouchEndedCallback(function()
		self:AdjustmentTroops()
	end)
	buzhen:setAnchorPoint(1,0.5)
	buzhen:setScale(0.8)
	buzhen:setPosition(self:getContentSize().width-32,biandui:getPositionY()-50-buzhen:getContentSize().height/2)
--	self:addChild(buzhen)
	--排行榜
	local paihangbang = XTHD.createButton({
		normalFile = "res/image/guild/guildWar/operateBtnNormal_rank.png",
    	selectedFile = "res/image/guild/guildWar/operateBtnSelected_rank.png"
	})
	paihangbang:setTouchEndedCallback(function()
		self:selectedCallback(4)
	end)
	paihangbang:setAnchorPoint(1,0.5)
	paihangbang:setScale(0.8)
	paihangbang:setPosition(self:getContentSize().width-32-paihangbang:getContentSize().width,66)
	self:addChild(paihangbang)
	print("=================>>>",paihangbang:getPositionX())

	local _midSize = cc.size(self:getContentSize().width,_upPosY -_allBtnBg:getBoundingBox().height - 60-_allBtnBg:getBoundingBox().y )
	local _midBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,_midSize.width,_midSize.height))
	_midBg:setOpacity(0)
	self.midBg = _midBg
	_midBg:setAnchorPoint(cc.p(0.5,0))
	_midBg:setPosition(cc.p(self:getContentSize().width/2,_allBtnBg:getBoundingBox().y+_allBtnBg:getBoundingBox().height))
	self:addChild(_midBg)

	self.btnPos = cc.p(self.midBg:getContentSize().width/2,self.midBg:getContentSize().height/5)
    
    self:initStageLayer(_currentStage)
end

function BangPaiZhanMain:initStageLayer(_idx)
	if _idx == nil or self.midBg== nil then
		return
	end
	self.midBg:removeAllChildren()
	
	if tonumber(self.guildWarData.joinState) == 0 and tonumber(self.guildWarData.state)~=1 and tonumber(self.guildWarData.state)~=4 then
		self:initStageCloseLayer()
		return 
	end
	self:setProgressState(_idx)
	if _idx == 1 then
		self:initStageApplyLayer()
	elseif _idx == 2 then
		self:initStageAdjustLayer()
	elseif _idx == 3 then
		self:initStageFightLayer()
	elseif _idx == 4 then
		self:initStageResultLayer()
	end
	-- os.data("%Y%m%d",)
end
--帮战休息期间或者未成功报名者
function BangPaiZhanMain:initStageCloseLayer()
	--本次帮战未报名
	local _noapplayDesc = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.noApplyTextXc,self._fontSize+4)
	_noapplayDesc:setColor(BangPaiFengZhuangShuJu.getTextColor("baise"))
	_noapplayDesc:setPosition(cc.p(self.btnPos.x,self.midBg:getContentSize().height/2))
	self.midBg:addChild(_noapplayDesc)
end

function BangPaiZhanMain:initStageApplyLayer()

	local _applyBtn = self:createOperateBtn("btnText_apply.png")
	_applyBtn:getLabel():setScale(0.7)
	_applyBtn:setPosition(cc.p(self.btnPos.x,self.btnPos.y))
	self.midBg:addChild(_applyBtn)
	_applyBtn:setName("applyBtn")
	--参加报名，普通成员。你所在的帮派未报名参加，请等待帮主报名
	--参加报名，帮主。帮派中有15名或以上成员即可报名参加
	if self.guildWarData.joinState and tonumber(self.guildWarData.joinState) ==1 then 	--已报名
		
		print("8431>>Agasrga")
		_applyBtn:setLabel(cc.Sprite:create("res/image/guild/guildWar/btnText_applyed.png"))
		_applyBtn:getLabel():setScale(0.7)
		_applyBtn:setTouchEndedCallback(function()
				XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.guildApplyedToastXc)
			end)
	else 			--未报名
		_applyBtn:setLabel(cc.Sprite:create("res/image/guild/guildWar/btnText_apply.png"))
		_applyBtn:getLabel():setScale(0.7)
		_applyBtn:setTouchEndedCallback(function()
				self:applyBtnCallback()
			end)
		local _applyDescStr = ""
		if tonumber(gameUser.getGuildRole())==1 then
			_applyDescStr = LANGUAGE_KEY_GUILDWAR_TEXT.guildMasterApplyConditionTextXc
		else
			_applyDescStr = LANGUAGE_KEY_GUILDWAR_TEXT.waitMasterApplyTextXc
		end
		local _applyDescLabel = XTHDLabel:create(_applyDescStr,self._fontSize)
		_applyDescLabel:setName("applyDescLabel")
		_applyDescLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("baise"))
		_applyDescLabel:setPosition(cc.p(self.seasonTimePos.x,self.btnPos.y - 55))
		self.midBg:addChild(_applyDescLabel)
	end
end
function BangPaiZhanMain:initStageAdjustLayer()
	local _startTimeSp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_startTime.png")
	_startTimeSp:setAnchorPoint(cc.p(0.5,0))
	_startTimeSp:setPosition(cc.p(self.btnPos.x,self.midBg:getContentSize().height/4*3+6-20))
	self.midBg:addChild(_startTimeSp)

	local _startTimeLabel = self:getStartTimeLabel()
	_startTimeLabel:enableShadow(cc.c4b(0,0,0,188),cc.size(1,-1),0.5)
	_startTimeLabel:setAnchorPoint(cc.p(0.5,1))
	_startTimeLabel:setPosition(cc.p(self.btnPos.x,self.midBg:getContentSize().height/4*3-20))
	self.midBg:addChild(_startTimeLabel)

	local _adjustDesc = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.lordAdjustDescTextXc,self._fontSize+4)
	_adjustDesc:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1),0.4)
	_adjustDesc:setColor(BangPaiFengZhuangShuJu.getTextColor("lianghuangse"))
	_adjustDesc:setPosition(cc.p(self.btnPos.x,self.btnPos.y - 15))
	self.midBg:addChild(_adjustDesc)
end
function BangPaiZhanMain:initStageFightLayer()
	local _exploreBtn = self:createOperateBtn("btnText_explore.png")
	_exploreBtn:getLabel():setScale(0.7)
	_exploreBtn:setPosition(cc.p(self.btnPos.x,self.btnPos.y - 10))
	self.midBg:addChild(_exploreBtn)
	_exploreBtn:setTouchEndedCallback(function()
			self:exploreBtnCallback()

		end)

	local _lastChallengeSp = cc.Sprite:create("res/image/daily_task/arena/challenge_time.png")
	_lastChallengeSp:setPosition(cc.p(self.btnPos.x - 8,self.btnPos.y+45))
	self.midBg:addChild(_lastChallengeSp)
	local _lastCount = XTHDLabel:create(self.guildWarData.surplusTime or 0,self._fontSize+2)
	_lastCount:setName("lastCount")
	_lastCount:enableShadow(cc.c4b(0,0,0,200),cc.size(1,-1),0.5)
	_lastCount:setAnchorPoint(cc.p(0,0.5))
	_lastCount:setPosition(cc.p(_lastChallengeSp:getBoundingBox().x+_lastChallengeSp:getBoundingBox().width + 5,_lastChallengeSp:getPositionY()))
	self.midBg:addChild(_lastCount)

	local _enemyName = LANGUAGE_KEY_GUILDWAR_guildWarEnemyTextXc(self.guildWarData.rivalGuildName or "aaaaaa")
	local _enemyLabel = XTHDLabel:create(_enemyName,self._fontSize+8)
	_enemyLabel:setAnchorPoint(cc.p(0.5,0))
	_enemyLabel:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1),0.5)
	_enemyLabel:setPosition(cc.p(self.btnPos.x,self.midBg:getContentSize().height/4*3-40))
	self.midBg:addChild(_enemyLabel)

	XTHD.addEventListenerWithNode({name = "refreshGuildFightCount",node = self,callback = function(event)
        	self:refreshLastCount(event.data.surplusTime)
        end})
end
function BangPaiZhanMain:initStageResultLayer()
	local _overSp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_end.png")
	_overSp:setPosition(cc.p(self.btnPos.x,self.btnPos.y))
	self.midBg:addChild(_overSp)

	--本轮排行
	local _rankSp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_currentrank.png")
	_rankSp:setAnchorPoint(cc.p(0.5,0))
	self.midBg:addChild(_rankSp)
	local _rankStr = tonumber(self.guildWarData.rank or 0) 
	_rankStr = _rankStr > 0 and _rankStr or 0
	local _rankLabel = XTHDLabel:create(_rankStr,self._fontSize+6)
	_rankLabel:setAnchorPoint(cc.p(0,0))
	_rankSp:setPosition(cc.p(self.btnPos.x -_rankLabel:getBoundingBox().width/2 - 5 ,self.midBg:getContentSize().height/3*2+10))
	_rankLabel:setPosition(cc.p(_rankSp:getBoundingBox().x+_rankSp:getBoundingBox().width+10,_rankSp:getBoundingBox().y))
	self.midBg:addChild(_rankLabel)
	--积分
	local _gradeSp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_grade.png")
	_gradeSp:setAnchorPoint(cc.p(0.5,1))
	self.midBg:addChild(_gradeSp)
	local _gradeStr = tonumber(self.guildWarData.jifen or 0)
	_gradeStr = _gradeStr > 0 and _gradeStr or 0
	local _gradeLabel = XTHDLabel:create(_gradeStr,self._fontSize+6)
	_gradeLabel:setAnchorPoint(cc.p(0,0))
	_gradeSp:setPosition(cc.p(self.btnPos.x -_gradeLabel:getBoundingBox().width/2 - 5 ,self.midBg:getContentSize().height/3*2-10))
	_gradeLabel:setPosition(cc.p(_gradeSp:getBoundingBox().x+_gradeSp:getBoundingBox().width+10,_gradeSp:getBoundingBox().y))
	self.midBg:addChild(_gradeLabel)
end

function BangPaiZhanMain:selectedCallback(_idx)
	if _idx == nil then
		return 
	end
	local _fileNameTable = {
		"BangPaiZhanQueRenZhuJiang.lua",
		"BangPaiZhanQueRenDuiYuan.lua",
		"",
		"BangPaiZhanRank.lua",
		"",
		""

	}
	local _httpCallbackTable = {
		ClientHttp.httpGuildBattleLordList,
		ClientHttp.httpGuildBattleGroupList,
		-- ClientHttp.httpGuildChangeRival
		"",
		ClientHttp.httpGuildJifenRank,
	}
	LayerManager.addShieldLayout()
	if _idx == 3 then
		if self.guildWarData.state and tonumber(self.guildWarData.state)==3 then
			XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.fighterAdjustTeamDescTextXc)
			return
		end
		ClientHttp.httpGetMyGuildGroup(self,function ( sData )
			local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):create(BattleType.GUILDWAR_TEAM, nil, {list = sData.list})
	    	fnMyPushScene(_layer)
		end)
		
		return
	elseif _idx == 5 then
		ClientHttp.httpGuildLookBattleRecord(self, function ( data )
			requires("src/fsgl/layer/BangPai/BangPaiZhanJiLu.lua"):createOne(data)
		end)
    	return
	elseif _idx == 6 then
		requires("src/fsgl/layer/BangPai/BangPaiZhanJiangLi.lua"):createOne()
		return
	end
	_httpCallbackTable[_idx](self,function(data)
        local _newLayer = requires("src/fsgl/layer/BangPai/" .. _fileNameTable[_idx]):create(data)
        LayerManager.addLayout(_newLayer,{noHide = true})
    end)
end

function BangPaiZhanMain:setProgressState()
	--刷新点，progress
	--名字变红
	local _stageValue = self.guildWarData.state or 1
	if self.guildWarData.state and tonumber(self.guildWarData.state)>1 and tonumber(self.guildWarData.state)~=4 and tonumber(self.guildWarData.joinState or 0)==0 then
		_stageValue = 0
	end
	for i=1,4 do
		local _color = BangPaiFengZhuangShuJu.getTextColor("baise")
		if i==_stageValue then
			_color = BangPaiFengZhuangShuJu.getTextColor("lianghuangse")
			if self.progress~=nil then
				-- self.progress:setPercentage(100)
				self.progress:setPercentage((i-1)*100/3)
			end
		elseif i<_stageValue then
			_color = BangPaiFengZhuangShuJu.getTextColor("huise")
		end
		if i<=_stageValue then
			if self:getChildByName("stageSp" .. i) then
				local _stageSp = self:getChildByName("stageSp" .. i)
				local _dotSp = cc.Sprite:create("res/image/activities/logindaily/logindaily_dotSp.png")
				_dotSp:setPosition(cc.p(_stageSp:getContentSize().width/2,_stageSp:getContentSize().height/2))
				_stageSp:addChild(_dotSp)
			end
		end
		if self:getChildByName("timeLabel" .. i) then
			self:getChildByName("timeLabel" .. i):setColor(_color)
			self:getChildByName("timeLabel" .. i):enableShadow(_color,cc.size(0.4,-0.4),0.4)
		end
	end
end

----------------------Get----------------------------
function BangPaiZhanMain:getSeasonTimeStr()
	if self.guildWarData==nil or self.guildWarData.seasonBeginTime==nil or self.guildWarData.seasonEndTime==nil then
		return 
	end
	-- local _startStr = os.date("%Y.%m.%d",tonumber(self.guildWarData.seasonBeginTime))
	-- local _endStr = os.date("%Y.%m.%d",tonumber(self.guildWarData.seasonEndTime))
	local _startStr = self.guildWarData.seasonBeginTime or ""
	local _endStr = self.guildWarData.seasonEndTime or ""
	local _seasonTimeStr = _startStr .. "-" .. _endStr
	return _seasonTimeStr
end

function BangPaiZhanMain:getStartTimeLabel()
	local _starTimeLabel = XTHDLabel:create("0",self._fontSize + 8)
	local _timeValue = tonumber(self.guildWarData.battleSurplusTime or 0)
	_starTimeLabel:setString(getCdStringWithNumber(_timeValue,{m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second,h = LANGUAGE_UNKNOWN.hour}))
	schedule(_starTimeLabel,function(dt)
		_timeValue = _timeValue - 1
		_starTimeLabel:setString(getCdStringWithNumber(_timeValue,{m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second,h = LANGUAGE_UNKNOWN.hour}))
		if tonumber(_timeValue)<=0 then
			--刷新跳转
			if self:getScheduler() then
				self:unscheduleUpdate()
			end
			ClientHttp.httpGuildBaseInfo(self,function(data)
				self:setGuildWarData(data)
                local _currentStage = self.guildWarData.state or 1
				self:initStageLayer(_currentStage)
	        end)
			
			return
		end
	end,1)
	return _starTimeLabel
end

----------------------create-------------------------

function BangPaiZhanMain:createGuildWarTitle()
	local _order = 7
	local _titleSp = cc.Sprite:createWithTexture(nil,cc.rect(0,0,459,68))
	_titleSp:setOpacity(0)
	--数字
	-- local _numberSp = cc.Label:createWithBMFont("res/image/tmpbattle/goldword001.fnt",tostring(_order))
	-- _numberSp:setAnchorPoint(cc.p(0.5,0.5))
	-- _numberSp:setPosition(cc.p(269,_titleSp:getContentSize().height/2-2+4))
	-- _titleSp:addChild(_numberSp)
	--帮派争霸战第几季
	-- local _textSp = cc.Sprite:create("res/image/guild/guildWar/guildWar_title.png")
	-- _textSp:setAnchorPoint(cc.p(0,0.5))
	-- _textSp:setPosition(cc.p(0,_titleSp:getContentSize().height/2))
	-- _titleSp:addChild(_textSp)
	return _titleSp
end

function BangPaiZhanMain:createOperateBtn(_path)
	local _applyBtn = XTHD.createButton({
			normalFile = "res/image/common/btn/btn_guildWar_normal.png",
			selectedFile = "res/image/common/btn/btn_guildWar_selected.png",
			label = cc.Sprite:create("res/image/guild/guildWar/" .. _path)

		})
	return _applyBtn
end


----------------------callback--------------------------
-- 开始报名
function BangPaiZhanMain:applyBtnCallback()
	ClientHttp.httpGuildToBattle(self,function()
			XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.applySuccessTextXc)
			if self.midBg~=nil and self.midBg:getChildByName("applyBtn") then
				if self.midBg:getChildByName("applyDescLabel") then
					self.midBg:removeChildByName("applyDescLabel")
				end
				local _applyBtn = self.midBg:getChildByName("applyBtn")
				_applyBtn:setLabel(cc.Sprite:create("res/image/guild/guildWar/btnText_applyed.png"))
				_applyBtn:getLabel():setScale(0.7)
				_applyBtn:setTouchEndedCallback(function()
						XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.guildApplyedToastXc)
					end)
			end
		end)
end

function BangPaiZhanMain:exploreBtnCallback()
	ClientHttp.httpGuildChangeRival(self,function(data)
			self.guildWarData.surplusTime = data.surplusTime or 0
			self:refreshLastCount()
			LayerManager.addShieldLayout()
			local _newLayer = requires("src/fsgl/layer/BangPai/BangPaiZhanKaiZhan.lua"):create(data)
	        LayerManager.addLayout(_newLayer,{noHide = true})
		end)
end

function BangPaiZhanMain:refreshLastCount(_number)
	if self.midBg ~=nil and _number~=nil then
		self.guildWarData.surplusTime = _number
		if self.midBg:getChildByName("lastCount") then
			self.midBg:getChildByName("lastCount"):setString(self.guildWarData.surplusTime or 0)
		end
	end
end

function BangPaiZhanMain:setGuildWarData(_data)
	self.guildWarData = _data or {}
end

function BangPaiZhanMain:AdjustmentTroops()
	ClientHttp:requestAsyncInGameWithParams( {
        modules = "myGuildBattleGroup?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
               local embattle = requires("src/fsgl/layer/BangPai/BangPaiDuiWu.lua"):create(data,self)
				--embattle = embattle:create(data,self)
				LayerManager.addLayout(embattle,{noHide = true})
            else
				XTHDTOAST(data.msg)
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function BangPaiZhanMain:create(data)
	local _layer = self.new(data)
	return _layer
end

return BangPaiZhanMain