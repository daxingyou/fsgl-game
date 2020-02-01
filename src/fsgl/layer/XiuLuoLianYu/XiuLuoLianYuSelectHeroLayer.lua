--Created By Liuluyang 2015年10月21日
local XiuLuoLianYuSelectHeroLayer = class("XiuLuoLianYuSelectHeroLayer",function ()
	return XTHDDialog:create()
end)

IS_HAVE_ARENASELECT_LAYER = false

function XiuLuoLianYuSelectHeroLayer:ctor(data)
	self.rivalData = data or {}
	self._nowSelectNum = 0
	self._nowEnemySelect = 0
	self._nowSelectHero = {}
	--[[
		campId
		charId
		name
		level
		first
		templateId
	]]
	self:initUI()
	self:registSocket()
	self:startPlayerBg()
end

function XiuLuoLianYuSelectHeroLayer:registSocket()
    XTHD.addEventListenerWithNode({
		node = self,
        name = CUSTOM_EVENT.REFRESH_RIVAL_TEAM,
        callback = function (event)
        	self:refreshRivalHero(event.data)
        end
    })
    XTHD.addEventListenerWithNode({
		node = self,
        name = CUSTOM_EVENT.KICK_OUT_ARENA,
        callback = function (event)
        	LayerManager.removeLayout(self)
        end
    })
end

function XiuLuoLianYuSelectHeroLayer:onCleanup()
	IS_HAVE_ARENASELECT_LAYER = false
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey("res/image/camp/xiuluolianyu.png")
end

function XiuLuoLianYuSelectHeroLayer:initUI()
	local bg = XTHD.createSprite("res/image/camp/xiuluolianyu.png")
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	bg:setContentSize(cc.Director:getInstance():getWinSize())
	self:addChild(bg)
end

function XiuLuoLianYuSelectHeroLayer:startPlayerBg()
	self._enemyBar = XTHD.createSprite("res/image/daily_task/arena/hero_bg2.png")
	self._enemyBar:setAnchorPoint(1,1)
	self._enemyBar:setPosition(self:getBoundingBox().width+self._enemyBar:getBoundingBox().width,self:getBoundingBox().height-60)
	self:addChild(self._enemyBar)

	self.enemyHeroList = {}
	for i=1,5 do
		local noHero = XTHD.createSprite("res/image/daily_task/arena/no_hero.png")
		noHero:setPosition(XTHD.resource.getPosInArr({
			lenth = -10,
			bgWidth = self._enemyBar:getBoundingBox().width,
			num = 5,
			nodeWidth = noHero:getBoundingBox().width,
			now = i,
		})-30,self._enemyBar:getBoundingBox().height*0.5)

		if i == 5 then
			_file = "res/image/imgSelHero/teambg_1.png"
		elseif i > 2 then
			_file = "res/image/imgSelHero/teambg_2.png"
		else
			_file = "res/image/imgSelHero/teambg_3.png"
		end
		_tag = XTHD.createSprite(_file)
		_tag:setAnchorPoint(0, 1)
		_tag:setPosition(10, noHero:getContentSize().height - 10)
		noHero:addChild(_tag, 2)

		self._enemyBar:addChild(noHero)
		self.enemyHeroList[#self.enemyHeroList+1] = noHero
	end

	-- local enemyAvatarBg = XTHD.createSprite("res/image/daily_task/arena/avatar_bg.png")
	-- enemyAvatarBg:setAnchorPoint(1,1)
	-- enemyAvatarBg:setPosition(self._enemyBar:getBoundingBox().width-7,self._enemyBar:getBoundingBox().height+30)
	-- self._enemyBar:addChild(enemyAvatarBg)

	local enemyAvatar = HaoYouPublic.getFriendIcon({templateId = self.rivalData.templateId,level = self.rivalData.level}, {notShowCamp = true})
	enemyAvatar:setAnchorPoint(1,1)
	enemyAvatar:setPosition(self._enemyBar:getBoundingBox().width-17,self._enemyBar:getBoundingBox().height-20)
	-- enemyAvatar:setScale(1)
	self._enemyBar:addChild(enemyAvatar)

	local enemyName = XTHDLabel:createWithParams({
		text = self.rivalData.name,
		fontSize = 20,
		color = cc.c3b(206,110,240)
	})
	enemyName:setAnchorPoint(1,0)
	enemyName:setPosition(enemyAvatar:getPositionX()-enemyAvatar:getBoundingBox().width-70,self._enemyBar:getBoundingBox().height)
	self._enemyBar:addChild(enemyName)

	local enemyFaction = XTHD.createSprite("res/image/daily_task/arena/faction_"..tostring(self.rivalData.campId)..".png")
	enemyFaction:setScale(0.8)
	enemyFaction:setAnchorPoint(1,0.5)
	enemyFaction:setPosition(enemyAvatar:getPositionX()-enemyAvatar:getBoundingBox().width,enemyName:getPositionY()+enemyName:getBoundingBox().height/2+15)
	self._enemyBar:addChild(enemyFaction)

	self._enemyBar:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveBy:create(0.7, cc.p(-self._enemyBar:getBoundingBox().width,0)), 2),cc.CallFunc:create(function ()
		self:flipCoin()
	end)))

	----------

	self.playerHeroList = {}
	self._playerBar = XTHD.createSprite("res/image/daily_task/arena/hero_bg1.png")
	self._playerBar:setAnchorPoint(0,0)
	self._playerBar:setPosition(-self._playerBar:getBoundingBox().width,-5)
	self:addChild(self._playerBar)

	local _file, _tag
	for i=1,5 do
		local noHero = XTHD.createSprite("res/image/daily_task/arena/no_hero.png")
		noHero:setPosition(XTHD.resource.getPosInArr({
			lenth = -10,
			bgWidth = self._playerBar:getBoundingBox().width,
			num = 5,
			nodeWidth = noHero:getBoundingBox().width,
			now = i,
		})+30, self._playerBar:getBoundingBox().height*0.5)
		self._playerBar:addChild(noHero)

		if i == 1 then
			_file = "res/image/imgSelHero/teambg_1.png"
		elseif i < 4 then
			_file = "res/image/imgSelHero/teambg_2.png"
		else
			_file = "res/image/imgSelHero/teambg_3.png"
		end
		_tag = XTHD.createSprite(_file)
		_tag:setAnchorPoint(0, 1)
		_tag:setPosition(10, noHero:getContentSize().height - 10)
		noHero:addChild(_tag, 2)

		self.playerHeroList[#self.playerHeroList+1] = noHero
	end

	-- local playerAvatarBg = XTHD.createSprite("res/image/daily_task/arena/avatar_bg.png")
	-- playerAvatarBg:setAnchorPoint(0, 1)
	-- playerAvatarBg:setPosition(7,self._playerBar:getBoundingBox().height+30)
	-- self._playerBar:addChild(playerAvatarBg)
	-- playerAvatarBg:setOpacity(0)

	local playerAvatar = HaoYouPublic.getFriendIcon({templateId = gameUser.getTemplateId(),level = gameUser.getLevel()}, {notShowCamp = true})
	playerAvatar:setAnchorPoint(0, 1)
	playerAvatar:setPosition(37,self._playerBar:getBoundingBox().height-20)
	-- playerAvatar:setScale(1)
	self._playerBar:addChild(playerAvatar)

	local playerName = XTHDLabel:createWithParams({
		text = gameUser.getNickname(),
		fontSize = 20,
		color = cc.c3b(206,110,240)
	})
	playerName:setAnchorPoint(0,0)
	playerName:setPosition(playerAvatar:getPositionX()+playerAvatar:getBoundingBox().width+70,self._playerBar:getBoundingBox().height)
	self._playerBar:addChild(playerName)

	local playerFaction = XTHD.createSprite("res/image/daily_task/arena/faction_"..gameUser.getCampID()..".png")
	playerFaction:setAnchorPoint(0,0.5)
	playerFaction:setScale(0.8)
	playerFaction:setPosition(playerAvatar:getPositionX()+playerAvatar:getContentSize().width-30,playerName:getPositionY()+playerName:getBoundingBox().height/2+10)
	self._playerBar:addChild(playerFaction)

	self._playerBar:runAction(cc.Sequence:create(cc.EaseOut:create(cc.MoveBy:create(0.7, cc.p(self._playerBar:getBoundingBox().width,0)), 2)))

	self._heroData = DBTableHero.getData(gameUser.getUserId())
	table.sort(self._heroData,function (a,b)
		return a.power > b.power
	end)
	self._powerList = {}
	for k,v in pairs(self._heroData) do
		self._powerList[#self._powerList+1] = v
	end
	table.sort(self._powerList,function (a,b)
		return a.power > b.power
	end)

	self._heroTableView = CCTableView:create(cc.size(self:getBoundingBox().width-120,90))--761
    self._heroTableView:setPosition(60,-90)--20
    self._heroTableView:setBounceable(true)
    self._heroTableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) --设置横向纵向
    self._heroTableView:setDelegate()
    self._heroTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._playerBar:addChild(self._heroTableView)

    local function cellSizeForTable(table,idx)
        return 90,90
    end

    local function numberOfCellsInTableView(table)
        return #self._heroData
    end

    -- self._allHeroNode = {}
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else
            cell:removeAllChildren()
        end
        -- if self._cellIds[_heroId] and  then
        -- 	self._allHeroNode[cell.heroId] = nil
        -- end

        local hero = HeroNode:createWithParams({
        	heroid = self._heroData[idx+1].heroid
        })
        hero:setScale(0.85)
        hero:setPosition(45,45)
        cell:addChild(hero)
        local _heroId = self._heroData[idx+1].heroid
        cell.heroId = _heroId
        cell.hero = hero
        -- self._allHeroNode[_heroId] = hero
        hero:setTouchEndedCallback(function ()
        	self:selectHero(_heroId)
        end)

        local flag = self:isHeroSelect(_heroId)
        if flag == 1 then
        	self:setOneSelected(_heroId, true)
        end

        return cell
    end

    local leftArrow = XTHD.createSprite("res/image/plugin/stageChapter/btn_left_arrow.png")
    leftArrow:setAnchorPoint(1,0.5)
    leftArrow:setPosition(self._heroTableView:getPositionX(),self._heroTableView:getPositionY()+self._heroTableView:getBoundingBox().height/2)
    self._playerBar:addChild(leftArrow)

    local rightArrow = XTHD.createSprite("res/image/plugin/stageChapter/btn_right_arrow.png")
    rightArrow:setAnchorPoint(0,0.5)
    rightArrow:setPosition(self._heroTableView:getPositionX()+self._heroTableView:getBoundingBox().width,self._heroTableView:getPositionY()+self._heroTableView:getBoundingBox().height/2)
    self._playerBar:addChild(rightArrow)

    local function scrollViewDidScroll(view)
        local offset = -self._heroTableView:getContentOffset().x
        if offset <= 0 then
            leftArrow:setVisible(false)
            rightArrow:setVisible(true)
        elseif offset >= (#self._heroData*90)-(self:getBoundingBox().width-120) then
            leftArrow:setVisible(true)
            rightArrow:setVisible(false)
        else
            leftArrow:setVisible(true)
            rightArrow:setVisible(true)
        end
    end

    self._heroTableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._heroTableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._heroTableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._heroTableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._heroTableView:reloadData()
end

function XiuLuoLianYuSelectHeroLayer:getCellByHeroId( heroId )
	if not self._heroTableView then
		return nil
	end
	for i = 1, #self._heroData do
		local v = self._heroTableView:cellAtIndex((i-1))
		if v and v.heroId and v.heroId == heroId then
			return v.hero
		end
	end
	return nil
end

function XiuLuoLianYuSelectHeroLayer:setOneSelected( heroId, isSelect )
	local _heroid = heroId
	if not _heroid then
		return
	end
	local hero = self:getCellByHeroId(_heroid)
	if not isSelect then
		if hero then
			if hero:getChildByName("selectBg") then
				hero:getChildByName("selectBg"):removeFromParent()
			end
			for i=1, #self.playerHeroList do
				local _data = self.playerHeroList[i]:getChildByName("heroIcon")
				if _data and _data._heroId == _heroid then
					_data:removeFromParent()
					_data = nil
					break
				end
			end
			if hero.heroIcon then
				hero.heroIcon:removeFromParent()
				hero.heroIcon = nil
			end
		end
		for i=1,#self._nowSelectHero do
			if self._nowSelectHero[i] == _heroid then
				--已经选择过了
				table.remove(self._nowSelectHero, i)
			end
		end
		return
	end

	self._nowSelectNum = self._nowSelectNum or 0
	if self._nowSelectNum <= #self._nowSelectHero then
		XTHDTOAST(LANGUAGE_KEY_ARENA_SELECTHERO(self._nowSelectNum))
		return
	end
	local isHave = self:isHeroSelect(_heroid)
	--------------new changed -----------------
	local targetBg
	local _idx = 1
	for i=1, self._nowSelectNum do
		targetBg = self.playerHeroList[#self._selectedHeroList + i]
		if not targetBg:getChildByName("heroIcon") then
			_idx = i
			break
		end
	end
	if isHave == 0 then
		table.insert(self._nowSelectHero, _idx, _heroid)
	end
	--------------end ---------------
	-- if isHave == 0 then
	-- 	self._nowSelectHero[#self._nowSelectHero+1] = _heroid
	-- end
	-- local targetBg = self.playerHeroList[#self._selectedHeroList+1]
	-- if targetBg:getChildByName("heroIcon") then
	-- 	targetBg = self.playerHeroList[#self._selectedHeroList+#self._nowSelectHero]
	-- end
	local heroIcon = HeroNode:createWithParams({
		heroid = _heroid
	})
	heroIcon._heroId = _heroid
	heroIcon:setScale(80/heroIcon:getBoundingBox().width)
	heroIcon:setPosition(targetBg:getContentSize().width/2,targetBg:getContentSize().height/2-1)
	targetBg:addChild(heroIcon)
	heroIcon:setName("heroIcon")

	heroIcon:setTouchEndedCallback(function ()
		self:setOneSelected(_heroid)
		-- heroIcon:removeFromParent()
		-- heroIcon = nil
		-- for i=1,#self._nowSelectHero do
		-- 	if self._nowSelectHero[i] == _heroid then
		-- 		local targetHero = self:getCellByHeroId(_heroid)
		-- 		if targetHero and targetHero:getChildByName("selectBg") then
		-- 			targetHero:getChildByName("selectBg"):removeFromParent()
		-- 		end
		-- 		table.remove(self._nowSelectHero,i)
		-- 	end
		-- end
	end)

	if not hero then 
		return
	end
	
	local selectBg = XTHD.createSprite("res/image/illustration/selected.png")
	selectBg:setPosition(hero:getContentSize().width/2 - 0.5, hero:getContentSize().height/2 - 1)
	selectBg:setScaleY(0.98)
	hero:addChild(selectBg)
	selectBg:setName("selectBg")
end

function XiuLuoLianYuSelectHeroLayer:isHeroSelect( heroId )
	local flag = 0 --是否选择了这个英雄
	for i=1,#self._nowSelectHero do
		if self._nowSelectHero[i] == heroId then
			--已经选择过了
			flag = 1
		end
	end
	return flag
end

function XiuLuoLianYuSelectHeroLayer:selectHero(heroId)

	local flag = self:isHeroSelect(heroId)
	local pTag = self:setOneSelected(heroId, flag == 0)
	
	-- XTHD.setGray(normalSp, self._nowSelectNum > #self._nowSelectHero)
	-- XTHD.setGray(selectedSp, self._nowSelectNum > #self._nowSelectHero)
	if self._confirmBtn then
		self._confirmBtn:setEnable(self._nowSelectNum <= #self._nowSelectHero)
	end
end

function XiuLuoLianYuSelectHeroLayer:startSelectHero()
	if self._swallowBg then
		self._swallowBg:removeFromParent()
		self._swallowBg = nil
	end
	self._playerBar:runAction(cc.EaseOut:create(cc.MoveTo:create(0.5, cc.p(0,100)), 2))
	self._selectedHeroList = self._selectedHeroList or {} --玩家现在已经选成功的所有英雄 id
	self._nowSelectHero = {} --当前选中的英雄
	self._nowSelectNum = 2 --当前需要选几个英雄
	if #self._selectedHeroList == 0 then
		if self.rivalData.first == 1 then
			self._nowSelectNum = 1
		elseif self.rivalData.first == 0 then
			self._nowSelectNum = 3
		end
	end

	--点击确定回调
	local function confirmCallBack()
    	self:endSelectHero()
	end

	--时间到了 自动选择回调
	local function autoChoose()
		LayerManager.addShieldLayout()
		local needNum = self._nowSelectNum - #self._nowSelectHero
		if needNum > 0 then
			local flag = 1
			for i=1,needNum do
				for j=1,#self._powerList do
					flag = 1
					for k=1,#self._nowSelectHero do
						if self._nowSelectHero[k] == self._powerList[j].heroid then
							flag = 0
							break
						end
					end
					if flag == 1 then
						self:selectHero(self._powerList[j].heroid)
						break
					end
				end
			end
		end
		confirmCallBack()
	end

	local timeLeftStr = XTHD.createSprite("res/image/daily_task/arena/your_left_time.png")
	-- timeLeftStr:setScale(0.8)
	timeLeftStr:setAnchorPoint(1,0.5)
	timeLeftStr:setPosition(self:getBoundingBox().width/2-60,self:getBoundingBox().height/2+40)
	self:addChild(timeLeftStr)
	self._timeLeftStr = timeLeftStr

	function countDown(label)
		label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
	        label.cd = label.cd - 1
	        if label.cd > 0 then
	            label:setString(getCdStringWithNumber(label.cd,{h=":"}))
	        else
	            label:stopAllActions()
	            autoChoose()
	        end
	    end))))
	end

	local CDTIME = 15

	local cdLabel = cc.Label:createWithBMFont("res/image/tmpbattle/bigyellowword.fnt",CDTIME)
	cdLabel:setAnchorPoint(1,0.5)
	cdLabel:setPosition(timeLeftStr:getPositionX()+cdLabel:getBoundingBox().width,timeLeftStr:getPositionY()+50)
	self:addChild(cdLabel)
	cdLabel.cd = CDTIME
	countDown(cdLabel)
	self._cdLabel = cdLabel

	local secStr = XTHD.createSprite("res/image/daily_task/arena/second.png")
	secStr:setAnchorPoint(0,1)
	secStr:setPosition(cdLabel:getPositionX(),timeLeftStr:getPositionY()+timeLeftStr:getBoundingBox().height/2)
	self:addChild(secStr)
	self._secStr = secStr

	--确认按钮
	local _btnSize = cc.size(135,46)
	local disableSp = XTHD.getScaleNode("res/image/common/btn/btn_write_1_disable.png",_btnSize)
	XTHD.setGray(disableSp,true)
	self._confirmBtn = XTHD.createCommonButton({
			btnSize = _btnSize,
			isScrollView = false,
			--disableNode = disableSp,
			btnColor = "write_1",
			text = LANGUAGE_BTN_KEY.sure,
			pos = cc.p(self._playerBar:getBoundingBox().width-20, self._playerBar:getBoundingBox().height*0.5),
	        endCallback = confirmCallBack,
		})
	self._confirmBtn:setScale(0.7)
	self._confirmBtn:setEnable(false)
	self._playerBar:addChild(self._confirmBtn)
	
	--加闪烁
	for i=1,self._nowSelectNum do
		local targetBg = self.playerHeroList[#self._selectedHeroList+i]
		if targetBg then
			local lightBg = XTHD.createSprite("res/image/daily_task/arena/selected2.png")
			lightBg:setScale(0.7)
			lightBg:setPosition(targetBg:getBoundingBox().width/2,targetBg:getBoundingBox().height/2)
			targetBg:addChild(lightBg)
			lightBg:setName("lightBg")
			lightBg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5),cc.FadeIn:create(0.5))))
		end
	end
end

function XiuLuoLianYuSelectHeroLayer:showEnemySelect()
	self._fadeBg = XTHD.createSprite("res/image/daily_task/arena/select_bg.png")
    self._fadeBg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
    self:addChild(self._fadeBg)
    local fadeStr = XTHD.createSprite("res/image/daily_task/arena/enemy_select.png")
    fadeStr:setPosition(self._fadeBg:getBoundingBox().width/2,self._fadeBg:getBoundingBox().height/2)
    self._fadeBg:addChild(fadeStr)
    self._fadeBg:setCascadeOpacityEnabled(true)
    self._fadeBg:setOpacity(0)
    -- self._fadeBg:runAction(cc.Sequence:create(cc.FadeIn:create(0.15),cc.DelayTime:create(1),cc.FadeOut:create(0.5),cc.RemoveSelf:create()))
    self._fadeBg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1),cc.FadeOut:create(1))))

    self._nowEnemySelect = 2 --当前敌方需要选几个英雄
    self._enemyHeroData = self._enemyHeroData or {}
	if #self._enemyHeroData == 0 then
		if self.rivalData.first == 0 then
			self._nowEnemySelect = 1
		elseif self.rivalData.first == 1 then
			self._nowEnemySelect = 3
		end
	end
	for i=1,self._nowEnemySelect do
		local targetBg = self.enemyHeroList[5-(#self._enemyHeroData+(i-1))]
		if targetBg then
			local lightBg = XTHD.createSprite("res/image/daily_task/arena/selected2.png")
			lightBg:setPosition(targetBg:getBoundingBox().width/2,targetBg:getBoundingBox().height/2)
			lightBg:setScale(0.7)
			targetBg:addChild(lightBg)
			lightBg:setName("lightBg")
			lightBg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5),cc.FadeIn:create(0.5))))
		end
	end
	performWithDelay(self._fadeBg, function ( ... )
		LayerManager.removeLayout(self)
		XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
	end, 20)
end

function XiuLuoLianYuSelectHeroLayer:hideEnemySelect()
	if self._fadeBg then
		self._fadeBg:stopAllActions()
		self._fadeBg:runAction(cc.FadeOut:create(1))
	end
	for i=1,#self.enemyHeroList do
		if self.enemyHeroList[i]:getChildByName("lightBg") then
			local light = self.enemyHeroList[i]:getChildByName("lightBg")
			light:removeFromParent()
			light = nil
		end
	end
end

function XiuLuoLianYuSelectHeroLayer:endSelectHero()
	for i=1,#self._nowSelectHero do
		local _pId = self._nowSelectHero[i]
		self._selectedHeroList[#self._selectedHeroList+1] = _pId
		for k,v in pairs(self._powerList) do
			if v.heroid == _pId then
				table.remove(self._powerList, k)
				break
			end
		end
	end
	local tb = {num = #self._nowSelectHero, ids = clone(self._nowSelectHero)}
	self._timeLeftStr:removeFromParent()
	self._cdLabel:removeFromParent()
	self._secStr:removeFromParent()
	if self._swallowBg then
		self._swallowBg:removeFromParent()
		self._swallowBg = nil
	end
	self._swallowBg = XTHDDialog:create()
	self:addChild(self._swallowBg)
	self._playerBar:runAction(cc.Sequence:create(
		cc.EaseOut:create(cc.MoveTo:create(0.3, cc.p(0,-5)), 2),
		cc.CallFunc:create(function ()
			for i=#self._heroData, 1, -1 do
				local _hId = self._heroData[i].heroid
				for k,v in pairs(self._nowSelectHero) do
					if v == _hId then
						table.remove(self._heroData, i)
						break
					end
				end
			end
			self._heroTableView:reloadData()
			self:sendArenaChooseHero(tb)
			if #self._selectedHeroList == 5 and #self._enemyHeroData == 5 then
				self:selectFinish()
			else
				self:showEnemySelect()
			end
		end)
	))

	self._confirmBtn:removeFromParent()
	self._confirmBtn = nil
	local _data, _tmpSp
	for i=1, #self.playerHeroList do
		_data = self.playerHeroList[i]
		_tmpSp = _data:getChildByName("lightBg")
		if _tmpSp then
			_tmpSp:removeFromParent()
			_tmpSp = nil
		end
		_tmpSp = _data:getChildByName("heroIcon")
		if _tmpSp and _tmpSp.setTouchEndedCallback then
			_tmpSp:setTouchEndedCallback(function() 
			end)
		end
	end
end

function XiuLuoLianYuSelectHeroLayer:refreshRivalHero(sData)
	if not sData or not sData.charId then
		return
	end
	if sData.charId == gameUser.getUserId() then
		return
	end
	self._enemyHeroData = sData.list
	self:hideEnemySelect()
	for i=1,#self._enemyHeroData do
		local targetBg = self.enemyHeroList[5-(i-1)]
		targetBg:removeAllChildren()
		local heroIcon = HeroNode:createWithParams({
			heroid = self._enemyHeroData[i].heroID,
			advance = self._enemyHeroData[i].advance,
			star = self._enemyHeroData[i].star,
			level = self._enemyHeroData[i].level
		})
		heroIcon:setScale(0.9)
		heroIcon:setPosition(targetBg:getBoundingBox().width/2,targetBg:getBoundingBox().height/2)
		targetBg:addChild(heroIcon)
		--self.enemyHeroList
	end

	if self._selectedHeroList and #self._selectedHeroList == 5 and #self._enemyHeroData == 5 then
		--选完了
		self:selectFinish()
	else
		--对面选完人 开始选人
		self:startSelectHero()
	end
end

function XiuLuoLianYuSelectHeroLayer:selectFinish()
	local countDown = cc.Label:createWithBMFont("res/image/tmpbattle/bigyellowword.fnt",3)
	countDown:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2+20)
	self:addChild(countDown)
	countDown.cd = 3
	countDown:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
		countDown.cd = countDown.cd - 1
		if countDown.cd == 0 then
			self:startBattle()
			countDown:stopAllActions()
		else
			countDown:setString(countDown.cd)
		end
	end))))
end

function XiuLuoLianYuSelectHeroLayer:startBattle()
	local pLay = cc.Layer:create()
    local _battle_type = BattleType.PVP_SHURA
	pLay._selectedHeroList = clone(self._selectedHeroList)
	pLay._enemyList = clone(self._enemyHeroData)
	pLay._enemyList.rivalData = self.rivalData
	pLay._winInfo = {-1,-1,-1}
	pLay._count = 0
	local runningScene = cc.Director:getInstance():getRunningScene()
	runningScene:addChild(pLay)
	local _scene
	local _battleLayer

	local function go_battle( )
		local _httpTar = _scene or pLay
		ClientHttp.http_StartChallenge( _httpTar, _battle_type, nil, function(data)
        	if pLay._count == 0 then
        		LayerManager.removeLayout()
        	end
        	if _battleLayer then
        		_battleLayer:removeFromParent()
        	end
        	musicManager.stopBackgroundMusic()
	    	local teamListLeft = {}
	    	local teamListRight = {}
	    	local bgList = {}
	    	local function _heroSort( a, b )
				local n1 = tonumber(a.data.attackrange) or 0
				local n2 = tonumber(b.data.attackrange) or 0
				return n1 < n2
			end
        	pLay._count = pLay._count + 1
	    	local pLeftInfos = {}
			if data.myTeams and next(data.myTeams) ~= nil then
				for i=1, #data.myTeams do
					local _data = data.myTeams[i]
					local _heroId = _data.petId
					pLeftInfos[#pLeftInfos + 1] = {level = _data.level, petId = _data.petId}
					local animal = {id = _heroId ,_type = ANIMAL_TYPE.PLAYER, data = _data}
					-- local animal = createAnimal({id = _heroId ,_type = ANIMAL_TYPE.PLAYER, data = _data})
					-- if animal == nil then
					-- 	return
					-- end
		   --  		if animal:getStandRange() > 250 then
		   --  			animal:getSkills()["skillid"].range = animal:getSkills()["skillid"].range
		   --  		end
			    	teamListLeft[#teamListLeft + 1] = animal
			    end
		    	table.sort(teamListLeft, _heroSort)
			end
			--[[--敌人的队伍]]
			local pRightInfos = {}
			if data.hero and next(data.hero) ~= nil then
				local rightData = {}
				local team = {}
				for i=1, #data.hero do
					local _data = data.hero[i]
					pRightInfos[#pRightInfos + 1] = {level = _data.level, petId = _data.petId}
					local _heroId = _data.petId
					local animal = {id = _heroId ,_type = ANIMAL_TYPE.PLAYER , data = _data}
					-- local animal = createAnimal({id = _heroId ,_type = ANIMAL_TYPE.PLAYER , data = _data})
					-- if animal == nil then
					-- 	return
					-- end
		   --  		if animal:getStandRange() > 250 then
		   --  			animal:getSkills()["skillid"].range = animal:getSkills()["skillid"].range
		   --  		end
	    			team[#team + 1] = animal
	    		end
				--[[--排队]]
		    	table.sort(team, _heroSort)
				rightData.team = team
				teamListRight[#teamListRight + 1] = rightData
			end

			bgList[#bgList + 1] = "res/image/background/bg_pvp.jpg"

			if not _scene then
				_scene = cc.Scene:create()
				cc.Director:getInstance():pushScene(_scene)
			end
			_battleLayer = requires("src/battle/BattleLayer.lua"):create()
			local data = {
				playerList = pLay._selectedHeroList,
				enemyList = pLay._enemyList,
				winInfo = pLay._winInfo,
				nowCount = pLay._count,
			}
			local uiPvpRobberyLayer = BattleUINXNLayer:create(data, _battle_type)
			_battleLayer:initWithParams({
				bgList 			= bgList,
				bgm    			= "res/sound/bgm_battle_pvp.mp3",
				battleTime      = 90,
				teamListLeft	={teamListLeft},
				teamListRight	=teamListRight,
				battleType 		= _battle_type,
				battleEndCallback = function(params)
					pLay._winInfo[pLay._count] = params.result
					ClientHttp.http_SendFightValidation( _httpTar, function( data )
                    	_battleLayer:hideWithoutBg()
                    	local function _endCall()
                    		LayerManager.addShieldLayout()
					    	if pLay._count == 3 then
					    		ClientHttp.http_AsuraBattleResult(_httpTar, function( data )
						        	if pLay then
	                            		pLay:removeFromParent()
	                            		pLay = nil
	                            	end
	                            	data.backCallback = function() 
    									cc.Director:getInstance():popScene()
									end
						        	_battleLayer:addChild(requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoNVN.lua"):create(data, _battle_type))
					    		end, function()
					    			createFailHttpTipToPop()
		                            if pLay then
	                            		pLay:removeFromParent()
	                            		pLay = nil
	                            	end
					    		end )
					    	else
					    		go_battle()
					    	end
					    end
					    local _info = {
						    result = params.result,
						    leftInfos = pLeftInfos,
						    rightInfos = pRightInfos,
					    }
					    createOneFightTips(_scene, _info, _endCall)
					    musicManager.stopBackgroundMusic()
					end, function()
						createFailHttpTipToPop()
                        if pLay then
                    		pLay:removeFromParent()
                    		pLay = nil
                    	end
					end, params)
				end,
			})
			_scene:addChild(_battleLayer)
			_battleLayer:setUILay(uiPvpRobberyLayer)
			_scene:addChild(uiPvpRobberyLayer)
			_battleLayer:start()
		end, function()
			if pLay then
        		pLay:removeFromParent()
        		pLay = nil
        	end
		end)
	end

	go_battle()
end

function XiuLuoLianYuSelectHeroLayer:flipCoin()
	local coin = sp.SkeletonAnimation:create( "res/spine/effect/coin/yb.json", "res/spine/effect/coin/yb.atlas",1.0)
	coin:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addChild(coin)
	self.coin = coin
	local animName = self.rivalData.first == 1 and "jin" or "yu"
	local firstStr = self.rivalData.first == 1 and "first_select" or "second_select"
	coin:setAnimation(0,animName,false)
	performWithDelay(coin, function()
		coin:runAction(cc.Sequence:create(
			cc.DelayTime:create(1),
			cc.FadeOut:create(0.3),
			cc.CallFunc:create(function ()
				coin:removeFromParent()
            	coin = nil
	        	local fadeBg = XTHD.createSprite("res/image/daily_task/arena/select_bg.png")
	            fadeBg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	            self:addChild(fadeBg)
	            local fadeStr = XTHD.createSprite("res/image/daily_task/arena/"..firstStr..".png")
	            fadeStr:setPosition(fadeBg:getBoundingBox().width/2,fadeBg:getBoundingBox().height/2)
	            fadeBg:addChild(fadeStr)
	            fadeBg:setCascadeOpacityEnabled(true)
	            fadeBg:setOpacity(0)
	            fadeBg:runAction(cc.Sequence:create(
	            	cc.FadeIn:create(0.15),
	            	cc.DelayTime:create(1),
	            	cc.FadeOut:create(0.5),
	            	cc.CallFunc:create(function ()
	            		fadeBg:removeFromParent()
		            	if self.rivalData.first == 1 then
		            		--你是先手 开始选人
		            		self:startSelectHero()
		            	else
		            		self:showEnemySelect()
		            	end
		            end)
	            ))
        	end)
		))
	end, 3)
end

function XiuLuoLianYuSelectHeroLayer:sendArenaChooseHero( obj )
	local object = SocketSend:getInstance()
	if object then 
		object:writeChar(obj.num)
		for i=1, obj.num do
			object:writeInt(obj.ids[i])	
		end
		object:send(MsgCenter.MsgType.CLIENT_REQUEST_ARENACHOOSE)
	end 
end

function XiuLuoLianYuSelectHeroLayer:onExit()
	if self.coin then
		self.coin:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
	end
end

function XiuLuoLianYuSelectHeroLayer:create(data)
	return XiuLuoLianYuSelectHeroLayer.new(data)
end

return XiuLuoLianYuSelectHeroLayer