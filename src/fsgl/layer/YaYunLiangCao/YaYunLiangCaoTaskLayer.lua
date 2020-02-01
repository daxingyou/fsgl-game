--派遣队伍
local YaYunLiangCaoTaskLayer = class("YaYunLiangCaoTaskLayer",function ()
	return XTHD.createBasePageLayer()	
end)

function YaYunLiangCaoTaskLayer:ctor(data,callBack,_type)

	self._callBack = callBack
	self._data = data
	self.passTime = 0
	self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
		self.passTime = self.passTime + 1
	end))))
	self._lastBtn = nil
	self._type = _type

	self:initUI()
end

function YaYunLiangCaoTaskLayer:refreshData()
	ClientHttp:requestAsyncInGameWithParams({
        modules = "openDart?",
        params = {},
        successCallback = function(data)
            if data.result==0 then
                self._data = data
				self:refreshLayer()
              else
                XTHDTOAST(data.msg)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function YaYunLiangCaoTaskLayer:onCleanup()
	local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/lock_sp.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/choose_up.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/choose_down.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/need_sp.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/need_disable.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/lan.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/dot_enable.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/line_enable.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/lock_bg.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/dot_disable.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/line_disable.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/double.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/finish_task.png")
    textureCache:removeTextureForKey("res/image/daily_task/escort_task/finish_sp.png")
end

function YaYunLiangCaoTaskLayer:initUI()
	self:getChildByName("TopBarLayer1"):setBackCallFunc(function ()
        if self._callBack and type(self._callBack) == "function" then
        	self._callBack()
        end
        LayerManager.removeLayout(self)
    end)

	local Bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
	Bg:setPosition(self:getBoundingBox().width/2,self:getContentSize().height/2 - self.topBarHeight/2)
	self:addChild(Bg,0)
	self.Bg = Bg
	
	local title = "res/image/public/paiqian_title.png"
	XTHD.createNodeDecoration(self.Bg,title)
	--阴影
--	local shadow = ccui.Scale9Sprite:create("res/image/common/common_black_shadow.png")
--	shadow:setPosition(Bg:getContentSize().width + 25, Bg:getContentSize().height/2)
--	shadow:setAnchorPoint(1,0.5)
--	Bg:addChild(shadow)
    local bsize=Bg:getContentSize()

	self._bg2 = cc.Sprite:create()
	self._bg2:setContentSize(bsize.width -80,bsize.height-42)
	self._bg2:setAnchorPoint(cc.p(0,0))
    self._bg2:setPosition(12, 21)
    self.Bg:addChild(self._bg2, 1)

	--
	local lockBg = cc.Sprite:create("res/image/daily_task/escort_task/lock_sp.png")
	lockBg:setPosition(bsize.width/2,bsize.height/2)
	self.Bg:addChild(lockBg,1)
	self._lockBg = lockBg
	local Desc = XTHDLabel:createWithParams({
		text = "",
		fontSize = 30,
		color = cc.c3b(212,99,54)
	})
	Desc:setName("Desc")
	Desc:setPosition(lockBg:getContentSize().width/2,lockBg:getContentSize().height/2)
	lockBg:addChild(Desc)
	lockBg:setVisible(false)

	self._leftBg = cc.Sprite:create()
	self._leftBg:setAnchorPoint(0,0)
	self._leftBg:setContentSize(420,self._bg2:getContentSize().height)
	self._leftBg:setPosition(20,0)
	self._bg2:addChild(self._leftBg)

	self._rightBg = cc.Sprite:create()
	self._rightBg:setAnchorPoint(1,0.5)
	self._rightBg:setContentSize(cc.size(self.Bg:getContentSize().width*(520/1024),self._bg2:getContentSize().height))
	self._rightBg:setPosition(self._bg2:getContentSize().width-15,self._bg2:getContentSize().height/2)
	self._bg2:addChild(self._rightBg)

    -- local line = cc.Sprite:create("res/image/ranklistreward/splitY.png")
    -- line:setRotation(180)
    -- line:setPosition(38, self._rightBg:getContentSize().height/2)
	-- self._rightBg:addChild(line,0)
	

	--框1；
	local kuang1 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
    kuang1:setPosition(cc.p(self._leftBg:getContentSize().width/2-10,220))
    kuang1:setAnchorPoint(0.5,1)
    kuang1:setContentSize(self._leftBg:getContentSize().width-40,200)
    self._leftBg:addChild(kuang1) 
	--任务条件
	-- local taskNeed = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS255 .. ":","Helvetica", 20)
	local taskNeed = cc.Sprite:create("res/image/daily_task/escort_task/rwtj.png")
    taskNeed:setAnchorPoint(0.5,0.5)
    taskNeed:setPosition(kuang1:getContentSize().width/2, kuang1:getContentSize().height)--20,450
    kuang1:addChild(taskNeed)

	local taskTotalLab = {
		[1] = LANGUAGE_KEY_CLIENT,
		[2] = LANGUAGE_KEY_ALLADVANCE,
		[3] = LANGUAGE_KEY_ETATIME,
		[4] = LANGUAGE_KEY_ALLSTAR,
		[5] = LANGUAGE_KEY_HEROLIMIT,
		[6] = LANGUAGE_KEY_ALLLEVEL,
	}
	self._taskLab={}
	local beginPosX1 = 50
	local beginPosX2 = 280
	local beginposY = 90
	for i = 1, 6 do
		local lan = cc.Sprite:create("res/image/daily_task/escort_task/lan.png")
		lan:setAnchorPoint(0.5,1)
		lan:setPosition(beginPosX1, beginposY-(i-5)/2*60-5)
		self._leftBg:addChild(lan)
		local lab1 = XTHDLabel:createWithSystemFont("", "Helvetica", 20)
		lab1:setColor(cc.c3b(0,0,0))
		lab1:setAnchorPoint(cc.p(0,1))
		lab1:setString(taskTotalLab[i] .. ":")
		lab1:setPosition(beginPosX1+lan:getContentSize().width/2, beginposY-(i-5)/2*60-5)
		self._leftBg:addChild(lab1)

		local labInfo
		if i == 5  then
			
			local str1 = "<color=#462222 fontSize=20 >".."0".."</color>".."<img="..IMAGE_KEY_COMMON_LIGHT_STAR.." /></color><color=#462222 fontSize=18>"..LANGUAGE_KEY_NEEDSTAR.."</color>"
			labInfo = RichLabel:createARichText(str1,false)
			labInfo:setAnchorPoint(cc.p(0,0.5))
			labInfo:setPosition(lab1:getPositionX()+lab1:getContentSize().width,lab1:getPositionY())
			self._leftBg:addChild(labInfo)

		elseif i == 4 then
			local str2 = "<color=#462222 fontSize=20 >".."0".."</color>".."<img="..IMAGE_KEY_COMMON_LIGHT_STAR.." /></color>"
			labInfo = RichLabel:createARichText(str2,false)
			labInfo:setAnchorPoint(cc.p(0,0.5))
			labInfo:setPosition(lab1:getPositionX()+lab1:getContentSize().width,lab1:getPositionY())
			self._leftBg:addChild(labInfo)

		else
			labInfo = XTHDLabel:createWithSystemFont("", "Helvetica", 20)
			labInfo:setColor(cc.c3b(0,0,0))
			labInfo:setAnchorPoint(cc.p(0,1))
			labInfo:setPosition(lab1:getPositionX()+lab1:getContentSize().width,lab1:getPositionY())
			self._leftBg:addChild(labInfo)
		end


		self._taskLab[#self._taskLab + 1] = labInfo

	end

	-- --line
	-- local line = ccui.Scale9Sprite:create(cc.rect(0,0,20,2),"res/image/ranklistreward/splitX.png")
	-- line:setContentSize(cc.size(self._rightBg:getContentSize().width -10,2))
	-- line:setAnchorPoint(0.5,0.5)
	-- line:setPosition(self._rightBg:getContentSize().width / 2,340)
	-- self._rightBg:addChild(line)
	--根据要求选择英雄
	local bottomDesc = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_TIPS0 .. ":",
		fontSize = 20,
		color = cc.c3b(106,36,13),
		ttf = "res/fonts/def.ttf"
	})
	--bottomDesc:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),2)
	--bottomDesc:enableOutline(cc.c4b(45,13,103,255),1)
	bottomDesc:setAnchorPoint(cc.p(0,0.5))
	bottomDesc:setPosition(40,340 - 60)
	self._rightBg:addChild(bottomDesc)
	self.bottomDesc = bottomDesc

	local selectedPos = {
		[1] = cc.p(60,260),
		[2] = cc.p(60+150,260),
		[3] = cc.p(60+150*2,260),
		[4] = cc.p(60 +150/2, 260 - 110),
		[5] = cc.p(60 +150/2 + 150, 260 - 110),
	}

	self._selectHero = {}
	for i = 1, 5 do 
		local selectBtn = XTHDPushButton:createWithParams({
			normalFile = "res/image/daily_task/escort_task/choose_up.png",
			selectedFile = "res/image/daily_task/escort_task/choose_down.png",
            musicFile = XTHD.resource.music.effect_btn_common,
            anchor =cc.p(0,1),
            pos = selectedPos[i]
		})
		selectBtn:setScale(0.8)
		self._rightBg:addChild(selectBtn)
		self._selectHero[#self._selectHero + 1] = selectBtn


	end

    --left

	--kuang2
	local kuang2 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
    kuang2:setPosition(cc.p(self._leftBg:getContentSize().width/2-10,self._leftBg:getContentSize().height - 20))
    kuang2:setAnchorPoint(0.5,1)
    kuang2:setContentSize(self._leftBg:getContentSize().width-40,200)
    self._leftBg:addChild(kuang2)
	-- local tabName = XTHDLabel:createWithSystemFont("","Helvetica","28")
	local tabName = cc.Sprite:create("res/image/daily_task/escort_task/yyrw.png")
	tabName:setAnchorPoint(cc.p(0.5,0.5))
	-- tabName:setColor(cc.c3b(192,45,0))
	tabName:setPosition(kuang2:getContentSize().width/2, kuang2:getContentSize().height)
	kuang2:addChild(tabName)
	self._name = tabName

	local needBg = cc.Sprite:create()
	needBg:setContentSize(cc.size(380,174))
	needBg:setPosition(self._leftBg:getContentSize().width/2, self._leftBg:getContentSize().height - 140)
	self._leftBg:addChild(needBg)
	self._needBg = needBg

	local needSp = cc.Sprite:create("res/image/daily_task/escort_task/need_sp.png")
	needSp:setAnchorPoint(cc.p(0,0.5))
	needSp:setPosition(43,needBg:getPositionY() + needBg:getBoundingBox().height/2-10)
	self._leftBg:addChild(needSp)

	--line
	local leftLine = ccui.Scale9Sprite:create(cc.rect(0,0,20,2),"res/image/ranklistreward/splitX.png")
	leftLine:setContentSize(cc.size(self._leftBg:getContentSize().width -10,2))
	leftLine:setPosition(self._leftBg:getContentSize().width / 2,needBg:getPositionY()- needBg:getContentSize().height/2- 5)
	self._leftBg:addChild(leftLine)
	leftLine:setOpacity(0)

	local rewardBg = cc.Sprite:create()
	rewardBg:setContentSize(cc.size(380,174))
	rewardBg:setAnchorPoint(cc.p(0.5,1))
	rewardBg:setPosition(self._rightBg:getContentSize().width/2,490)
	self._rightBg:addChild(rewardBg)
	self._rewardBg = rewardBg
	--任务奖励
	local rewardSp = XTHDLabel:create("奖励:",20,"res/fonts/def.ttf")
	rewardSp:setColor(cc.c3b(106,36,13))
	--rewardSp:enableShadow(cc.c4b(255,255,255,255),cc.size(1,0),2)
	--rewardSp:enableOutline(cc.c4b(45,13,103,255),1)
	rewardSp:setPosition(30,435)--48,188
	rewardSp:setAnchorPoint(cc.p(0,0.5))
	self._rightBg:addChild(rewardSp)

	--TAB三个大按钮
	self.tabBtnList = {}
	local justPosX = self.Bg:getContentSize().width +  60
	local justPosY = self.Bg:getContentSize().height
	for i=1,3 do
        local tabBtn = XTHDPushButton:createWithParams({
            normalNode      = getCompositeNodeWithImg("res/image/common/btn/btn_tabClassify_normal.png","res/image/daily_task/escort_task/tab_"..i.."_down.png"),
            selectedNode    = getCompositeNodeWithImg("res/image/common/btn/btn_tabClassify_selected.png","res/image/daily_task/escort_task/tab_"..i.."_up.png"),
            musicFile = XTHD.resource.music.effect_btn_common,
            anchor          =cc.p(1,1),
            --pos             = cc.p(self.Bg:getContentSize().width,justPosY -95*(i-1))
        })
		tabBtn:setPosition(cc.p(self.Bg:getContentSize().width - 44,justPosY -95*(i-1) - 20))
		self.Bg:addChild(tabBtn,0)
		tabBtn:setSelected(false)
		tabBtn:setTag(i)
		tabBtn:setScale(0.8)
		self.tabBtnList[#self.tabBtnList+1] = tabBtn

		if i == tonumber(self._type) then
			self:changeTab(tabBtn)
		end

		tabBtn:setTouchEndedCallback(function ()
			self:changeTab(tabBtn)
		end)
	end
end

function YaYunLiangCaoTaskLayer:changeTab(sender)

	local function doChangeTab()
		local tag = sender:getTag()
		self._type = tag
		print("tag == ", tag)
		if self._beginBtn then
			self._beginBtn:removeFromParent()
			self._beginBtn = nil
		end
		if self._data.data[tag].lockState == 0 then --表示已经开启此等级运镖
			self._bg2:setVisible(true)
			self._lockBg:setVisible(false)
			
			self:refreshLayer(self._type)
		else
			self._bg2:setVisible(false)
			self._lockBg:setVisible(true)
			local needNum = self._type == 2 and 1 or 3
			self._lockBg:getChildByName("Desc"):setString(LANGUAGE_KEY_UNLOCK_ESCORT(needNum))

		end
	end
	
	if self._lastBtn == nil then
		sender:setSelected(true)
		self._lastBtn = sender
		sender:setLocalZOrder(1)

		doChangeTab()
	elseif sender ~= self._lastBtn then
		self._lastBtn:setSelected(false)
		self._lastBtn:setLocalZOrder(0)
		sender:setSelected(true)
		sender:setLocalZOrder(1)
		self._lastBtn = sender
		doChangeTab()
	end
end

function YaYunLiangCaoTaskLayer:refreshLayer()
	local useType = self._type
	local nowData = self._data.data[tonumber(useType)]
	local nowCSV = gameData.getDataFromCSV("LiangcaoStore",{id = nowData.taskId})
	
	self._nowData = nowData
	self._nowCSV = nowCSV

	--刷新两个条里的Label
	self._taskLab[1]:setString(nowCSV.clent)
	self._taskLab[2]:setString(nowData.teamPhaseLevel)
	self._taskLab[3]:setString(LANGUAGE_KEY_MINUTE(nowCSV.needtime))
	local str2 = "<color=#462222 fontSize=20 >"..nowData.teamStar.."</color>".."<img="..IMAGE_KEY_COMMON_LIGHT_STAR.." />" .."</color>"
	self._taskLab[4]:setString(str2)
	local str1 = "<color=#462222 fontSize=20 >"..nowCSV.star.."</color>".."<img="..IMAGE_KEY_COMMON_LIGHT_STAR.." /></color><color=#462222 fontSize=18>"..LANGUAGE_KEY_NEEDSTAR.."</color>"
	self._taskLab[5]:setString(str1)
	self._taskLab[6]:setString(nowData.teamRank)


	--name
	local nameTable = {
		LANGUAGE_KEY_LEVEL_ESCORTTASK(1),
		LANGUAGE_KEY_LEVEL_ESCORTTASK(2),
		LANGUAGE_KEY_LEVEL_ESCORTTASK(3),
	}

	-- self._name:setString(nameTable[useType])

	--刷新左边的面板
	if self._rewardBg then
		self._rewardBg:removeAllChildren()
	end

	if self._needBg then
		self._needBg:removeAllChildren()
	end

	--任务需要
	local taskNum = 0 --一共有多少任务
	local finishNum = 1 + #nowData.meetTerm
	local taskStr = {}
	for i=1,3 do
		if tonumber(nowCSV["typeCan"..i]) ~= 0 then
			taskNum = taskNum + 1
			local spPath = "need_disable"
			local labelColor = cc.c3b(0,0,0)
			local isFinish = false
			for j=1,#nowData.meetTerm do
				if nowData.meetTerm[j] == i then
					isFinish = true
				end
			end
			if isFinish == true then
				spPath = "lan"
				labelColor = cc.c3b(0,0,0)
			end
			local needFlag = cc.Sprite:create("res/image/daily_task/escort_task/"..spPath..".png")
			needFlag:setPosition(50,130-(i-1)*30)
			self._needBg:addChild(needFlag)

			taskStr[i] = LANGUAGE_ESCORT_TASKNEED(i,nowCSV["typeCan"..i])
			if i == 4 then
				taskStr[i] = LANGUAGE_ESCORT_TASKNEED(i,gameData.getDataFromCSV("GeneralInfoList",{heroid = nowData.holdHeroId}).name)
			end
			local needStr = taskStr[i]
			local needLabel = XTHDLabel:createWithParams({
				text = needStr,
				fontSize = 20,
				color = labelColor
			})
			needLabel:setAnchorPoint(0,0.5)
			needLabel:setPosition(needFlag:getPositionX()+needFlag:getBoundingBox().width/2+10,needFlag:getPositionY())
			self._needBg:addChild(needLabel)


		end
	end

	--奖励信息
	self._rewardList = {}
	for i=1,4 do
		local rewardData = string.split(nowCSV["reward"..i],"#") --1类型  2装备id  3数量
		local rewardCount = #nowData.meetTerm == taskNum and tonumber(rewardData[3])*2 or tonumber(rewardData[3])

		local itemIcon = ItemNode:createWithParams({
			_type_ = tonumber(rewardData[1]),
			itemId = tonumber(rewardData[2]),
			count = rewardCount
		})

		local dotPath = "res/image/daily_task/escort_task/dot_enable.png"
		local linePath = "res/image/daily_task/escort_task/line_enable.png"
		local nameColor = XTHD.resource.color.brown_desc
		if finishNum < i then
			local lock = cc.Sprite:create("res/image/daily_task/escort_task/lock_bg.png")
			lock:setPosition(itemIcon:getBoundingBox().width/2,itemIcon:getBoundingBox().height/2)
			itemIcon:addChild(lock)
			dotPath = "res/image/daily_task/escort_task/dot_disable.png"
			linePath = "res/image/daily_task/escort_task/line_disable.png"
			nameColor = cc.c3b(138,118,96)
		else
			self._rewardList[#self._rewardList+1] = {
				rewardtype = tonumber(rewardData[1]),
				id = tonumber(rewardData[2]),
				num = rewardCount
			}
		end
		
		itemIcon:setScale(0.7)
		itemIcon:setPosition(XTHD.resource.getPosInArr({
			lenth = 30,
			bgWidth = self._rewardBg:getBoundingBox().width,
			num = 4,
			nodeWidth = itemIcon:getBoundingBox().width,
			now = i,
		}),self._rewardBg:getBoundingBox().height/2+5)
		self._rewardBg:addChild(itemIcon)


		local itemName = XTHDLabel:createWithParams({
			text = itemIcon._Name,
			fontSize = 18,
			color = nameColor
		})
		itemName:setPosition(itemIcon:getPositionX(),itemIcon:getPositionY()-itemIcon:getBoundingBox().height/2-13)
		self._rewardBg:addChild(itemName)

		local dotIcon = cc.Sprite:create(dotPath)
		dotIcon:setPosition(itemIcon:getPositionX(),itemName:getPositionY()-30)
		self._rewardBg:addChild(dotIcon,1)
		if i ~= 1 then
			local lineIcon = cc.Sprite:create(linePath)
			lineIcon:setAnchorPoint(1,0.5)
			lineIcon:setScaleX(0.2)
			lineIcon:setPosition(dotIcon:getPositionX(),dotIcon:getPositionY())
			self._rewardBg:addChild(lineIcon)
		end

		if #nowData.meetTerm == taskNum then
			local double = cc.Sprite:create("res/image/daily_task/escort_task/double.png")
			self._rewardBg:addChild(double)
			double:setPosition(itemIcon:getPositionX(), itemIcon:getPositionY()+itemIcon:getBoundingBox().height/2+13)
		end
	end


	--英雄信息
	for i=1,5 do
		if self._selectHero[i]:getChildByName("heroIcon") then
			self._selectHero[i]:getChildByName("heroIcon"):removeFromParent()
		end
		if i <= #nowData.team then
			local heroIcon = HeroNode:createWithParams({
				heroid = nowData.team[i],
			})
			heroIcon:setPosition(self._selectHero[i]:getContentSize().width/2,self._selectHero[i]:getContentSize().height/2)
			heroIcon:setName("heroIcon")
			self._selectHero[i]:addChild(heroIcon)
			
		end

		if nowData.flag ~= 0 then
			self._selectHero[i]:setTouchEndedCallback(function() end)
		else
			self._selectHero[i]:setTouchEndedCallback(function() 
				self:selectHero(i)
			end)
		end
	end

	--更新配置选将信息
	local _dartInfo = {_dartType = nowData.dartType}
	_dartInfo._conditionTable = {
		[1] = nowCSV.typeCan1,
		[2] = nowCSV.typeCan2,
		[3] = nowCSV.typeCan3,
		[4] = nowData.holdHeroId == 0 and nil or nowData.holdHeroId,
    }
	_dartInfo._teamTable = {}
	for i=1,#self._data.data do
		_dartInfo._teamTable[#_dartInfo._teamTable+1] = self._data.data[i].team
	end
	self._selectHeroParams = {
		battle_type = BattleType.PVP_DART_DEFENCE,
		param = {{team = nowData.team}},
		source_type = "PVP_DART_DEFENCE",
		teamIndex = 1,
		dartInfo = _dartInfo,
		heroLimit = nowCSV.star,
	}

	
	local btnStr 
	if nowData.flag == 0 then
		btnStr = LANGUAGE_TIPS_WORDS252
	elseif nowData.flag == 1 then
		btnStr = LANGUAGE_TIPS_WORDS254
	elseif nowData.flag == 2 then
		btnStr = LANGUAGE_KEY_FETCHREWARD
	end


	if self._beginBtn then
		self._beginBtn:removeFromParent()
	end

	--完成任务按钮
    self._beginBtn = XTHD.createCommonButton({
    	btnColor = "write_1",
		btnSize = cc.size(163,46),
		isScrollView = false,
  		text = btnStr,
  		fontColor = cc.c3b(255,255,255),
  		fontSize = 26,
	})
	self._beginBtn:setScale(0.7)
    self._beginBtn:setTag(1)
    self._beginBtn:setPosition(self._rightBg:getContentSize().width/2+10, 20)
    self._rightBg:addChild(self._beginBtn)
    self._beginBtn:setTouchEndedCallback(function()
    	self:requstData()
    end)
    local beginLab = self._beginBtn:getLabel()

    if nowData.flag == 0 then
		self.bottomDesc:setString(LANGUAGE_KEY_TIPS0)

	elseif nowData.flag == 1 then
		self.bottomDesc:setString(LANGUAGE_KEY_TIPS1)
		local goldIcon = XTHD.createHeaderIcon(XTHD.resource.type.ingot)
		goldIcon:setAnchorPoint(1,0.5)
		goldIcon:setName("goldIcon")
		local needGold = getCommonWhiteBMFontLabel(nowCSV.needyuanbao)
		needGold:setAnchorPoint(0,0.5)
		needGold:setName("needGold")
		--beginLab:setAnchorPoint(0,0.5)
		goldIcon:addChild(needGold)

		local posx =  self._beginBtn:getBoundingBox().width/2-(goldIcon:getBoundingBox().width+needGold:getBoundingBox().width+beginLab:getContentSize().width)/2
		goldIcon:setPosition(posx,self._beginBtn:getContentSize().height/2)
		needGold:setPosition(goldIcon:getContentSize().width + 5, goldIcon:getContentSize().height / 3);
		self._beginBtn:addChild(goldIcon)

		nowData.leftTime = tonumber(nowData.leftTime)
		if nowData.leftTime > 0 then
			local CDLabel = getCommonWhiteBMFontLabel(getCdStringWithNumber(self._data.data[useType].leftTime - self.passTime,{h = ":"}))
			CDLabel:setAnchorPoint(0,0.5)
			local CDStr = cc.Sprite:create("res/image/daily_task/escort_task/finish_task.png")
			CDStr:setAnchorPoint(0,0.5)
			CDLabel:setPosition(self._beginBtn:getBoundingBox().width/2-(CDLabel:getContentSize().width+CDStr:getContentSize().width)/2,self._beginBtn:getContentSize().height - 5)
			CDStr:setPosition(CDLabel:getPositionX()+CDLabel:getBoundingBox().width + 2,CDLabel:getPositionY()+7)
			self._beginBtn:addChild(CDLabel)
			self._beginBtn:addChild(CDStr)

			CDStr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
				local nowTime = 0
				nowTime = self._data.data[useType].leftTime - self.passTime
				if nowTime == 0 then
					--时间归零
					self:refreshData()
					return
				end
				CDLabel:setString(getCdStringWithNumber(nowTime,{h = ":"}))
				CDLabel:setPosition(self._beginBtn:getBoundingBox().width/2-(CDLabel:getContentSize().width+CDStr:getContentSize().width)/2,self._beginBtn:getContentSize().height - 5)
				CDStr:setPosition(CDLabel:getPositionX()+CDLabel:getBoundingBox().width + 2,CDLabel:getPositionY()+7)
			end))))
		end
	elseif nowData.flag == 2 then
		self.bottomDesc:setString(LANGUAGE_KEY_TIPS2)
		local finishSp = cc.Sprite:create("res/image/daily_task/escort_task/finish_sp.png")
		finishSp:setPosition(self._beginBtn:getContentSize().width/2,self._beginBtn:getContentSize().height + 10)
		self._beginBtn:addChild(finishSp)

	end
end

function YaYunLiangCaoTaskLayer:selectHero(index)
    ----引导
    if index == 1 then 
	    YinDaoMarg:getInstance():guideTouchEnd()
		YinDaoMarg:getInstance():releaseGuideLayer()
	end 
    ------------------------------------------             
	LayerManager.addShieldLayout()
    local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")
	local _layerHandler = SelHeroLayer:createWithParams(self._selectHeroParams)
	
	_layerHandler._endCallBack = function ( sData )
		self._data.data[tonumber(sData.data.dartType)] = sData.data
		self:refreshLayer(sData.data.dartType)
	end
	fnMyPushScene(_layerHandler)
end

function YaYunLiangCaoTaskLayer:requstData()
	
	local useData = self._nowData
	local useType = self._type
	local rewardList = self._rewardList
	local nowCSV = self._nowCSV
	if useData.flag == 0 then
		if #useData.team == 0 then
			XTHDTOAST(LANGUAGE_KEYESCORTWARNING)
			return
		end
		local YaYunLiangCaoConfirmPop = requires("src/fsgl/layer/YaYunLiangCao/YaYunLiangCaoConfirmPop.lua"):create({team = useData.team,reward = rewardList,ETA = nowCSV.needtime},function ()
			XTHDHttp:requestAsyncInGameWithParams({
		        modules = "startDart?",
		        params = {dartType = useType},
		        successCallback = function(data)
			        if tonumber(data.result) == 0 then
			        	-- ZCLOG(self._data.data[useType])
			        	self._data.data[useType].flag = data.flag
			        	self._data.data[useType].leftTime = data.leftTime
			        	-- self:refreshLayer(_type)
			        	if self._callBack and type(self._callBack) == "function" then
				        	self._callBack()
				        end
				        
				        LayerManager.removeLayout(self)
			        else
			            XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
			        end
		        end,--成功回调
		        failedCallback = function()
		            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
		        end,--失败回调
		        targetNeedsToRetain = self,--需要保存引用的目标
		        loadingParent = self,
		        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		    })
		end)
        self:addChild(YaYunLiangCaoConfirmPop,10)
        YaYunLiangCaoConfirmPop:show()

	elseif useData.flag == 1 then
		
		local YaYunLiangCaoRewardPop = requires("src/fsgl/layer/YaYunLiangCao/YaYunLiangCaoRewardPop.lua"):create(rewardList,nowCSV.needyuanbao,function ()
			XTHDHttp:requestAsyncInGameWithParams({
		        modules = "finishDart?",
		        params = {dartType = useType},
		        successCallback = function(data)
			        if tonumber(data.result) == 0 then
			        	self._data.data[useType].flag = data.flag
			        	self._data.data[useType].leftTime = data.leftTime
			        	XTHD.updateProperty(data.property)
			        	XTHD.saveItem({items = data.items})
			        	for i=1,#data.petData do
			        		for j=1,#data.petData[i].property do
			        			local petItemData = string.split( data.petData[i].property[j],',')
			        			DBTableHero.updateDataByPropId(gameUser.getUserId(),petItemData[1],petItemData[2],data.petData[i].baseId)
			        		end
			        	end
			        	-- ShowRewardNode(rewardList)
			        	local _rewardList = self:getRewardListTb(data)
			        	ShowRewardNode:create(_rewardList)
			        	self._data.data[useType] = data.data
			        	self:refreshLayer()
			        else
			            XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
			        end
		        end,--成功回调
		        failedCallback = function()
		            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
		        end,--失败回调
		        targetNeedsToRetain = self,--需要保存引用的目标
		        loadingParent = self,
		        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		    })
		end)
		self:addChild(YaYunLiangCaoRewardPop,10)
		YaYunLiangCaoRewardPop:show()

	elseif useData.flag == 2 then		
		XTHDHttp:requestAsyncInGameWithParams({
	        modules = "dartReward?",
	        params = {dartType = useType},
	        successCallback = function(data)
		        if tonumber(data.result) == 0 then
		        	self._data.data[useType].flag = data.flag
		        	XTHD.updateProperty(data.property)
		        	XTHD.saveItem({items = data.items})
		        	for i=1,#data.petData do
		        		for j=1,#data.petData[i].property do
		        			local petItemData = string.split( data.petData[i].property[j],',')
		        			DBTableHero.updateDataByPropId(gameUser.getUserId(),petItemData[1],petItemData[2],data.petData[i].baseId)
		        		end
		        	end
		        	-- ShowRewardNode(rewardList)
		        	local _rewardList = self:getRewardListTb(data)
		        	ShowRewardNode:create(_rewardList)
		        	self._data.data[useType] = data.data
		        	self:refreshLayer()
		        else
		            XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
		        end
	        end,--成功回调
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
	        end,--失败回调
	        targetNeedsToRetain = self,--需要保存引用的目标
	        loadingParent = self,
	        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	end
end

function YaYunLiangCaoTaskLayer:getRewardListTb( data )
	local rewardList = {}
    local _addSilver = tonumber(data.addSilver) or 0
    if _addSilver > 0 then
        rewardList[#rewardList+1] = {
            rewardtype = XTHD.resource.type.gold,
            num = _addSilver,
        }
    end
    local _addFeicui = tonumber(data.addFeicui) or 0
    if _addFeicui > 0 then
        rewardList[#rewardList+1] = {
            rewardtype = XTHD.resource.type.feicui,
            num = _addFeicui,
        }
    end
    local _addRenown = tonumber(data.addRenown) or 0
    if _addRenown > 0 then
        rewardList[#rewardList+1] = {
            rewardtype = XTHD.resource.type.reputation,
            num = _addRenown,
        }
    end
    if data.addItems and #data.addItems > 0 then
        for i=1, #data.addItems do
            local info = string.split(data.addItems[i],",")
            if tonumber(info[2]) > 0 then
                rewardList[#rewardList+1] = {
                    rewardtype = XTHD.resource.type.item,
                    id = info[1],
                    num = info[2],
                }
            end
        end
    end
    return rewardList
end

function YaYunLiangCaoTaskLayer:create(data,callBack,_type)
	return YaYunLiangCaoTaskLayer.new(data,callBack,_type)
end

function YaYunLiangCaoTaskLayer:onEnter( )
	self:addGuide()
end

function YaYunLiangCaoTaskLayer:addGuide( )
    -- if self._selectHero[1] then 
    --     YinDaoMarg:getInstance():addGuide({ ------引导选人
    --         parent = self,
    --         target = self._selectHero[1],
    --         index = 6,
    --         needNext = false,
    --     },20)
    -- end 
    -- YinDaoMarg:getInstance():doNextGuide()
end

return YaYunLiangCaoTaskLayer