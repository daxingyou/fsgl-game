--2019/06/11
--帮派Boss界面
local BangPaiBoos = class("BangPaiBoos",function()
    return XTHD.createBasePageLayer()
end)

function BangPaiBoos:ctor(data)
	self.httpAgain = nil
	self.isKillingIdx = 1
	self.bossData = {}
	self:getStaticData()
	self:setBossData(data)
	self:initLayer()
end

function BangPaiBoos:initLayer()
	local _topBarHeight = self.topBarHeight or 40

    local _bg = cc.Sprite:create()
    _bg:setContentSize(cc.size(1024,513))
    _bg:setPosition(cc.p(self:getContentSize().width/2,(self:getContentSize().height - _topBarHeight)/2 ))
    self:addChild(_bg)

	local _bottomBg = cc.Node:create()--("res/image/common/layer_bottomBg.png")
	_bottomBg:setContentSize(cc.size(self:getContentSize().width,_bg:getContentSize().height ))
	_bottomBg:setAnchorPoint(cc.p(0.5,0.5))
	_bottomBg:setPosition(cc.p(_bg:getContentSize().width/2,_bg:getContentSize().height * 0.5))
	_bg:addChild(_bottomBg)
	local _bottomUpPosY = 50
	local _bottomDownPosY = 40
	local _lastTimeLabel = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.guildBossTimeTextXc .. "：",20)
	_lastTimeLabel:setColor(cc.c3b(243,178,84))
	_lastTimeLabel:setAnchorPoint(cc.p(0,0))
	_lastTimeLabel:setPosition(cc.p(40,_bottomUpPosY))
	_bottomBg:addChild(_lastTimeLabel)
	local _lastTimeStr = "0"
	local _lastTime = XTHDLabel:create(_lastTimeStr,22,"res/fonts/def.ttf")
	self.lastTime = _lastTime
	_lastTime:setAnchorPoint(cc.p(0,0))
	_lastTime:enableShadow(BangPaiFengZhuangShuJu.getTextColor("baise"),cc.size(0.4,-0.4),1)
	_lastTime:enableOutline(cc.c4b(0,0,0,255),0.5)
	_lastTime:setColor(cc.c3b(255,255,255))
	_lastTime:setPosition(cc.p(_lastTimeLabel:getBoundingBox().x+_lastTimeLabel:getBoundingBox().width,_lastTimeLabel:getBoundingBox().y))
	_bottomBg:addChild(_lastTime)

	self:setLastTime()

	--lastChalleng count
	local _lastTitle = cc.Sprite:create("res/image/guild/guildBoss/imgText_lastChallengeCount.png")
	_lastTitle:setAnchorPoint(cc.p(0,0))
	_lastTitle:setPosition(cc.p(self:getContentSize().width - 330,_bottomUpPosY))
	_bottomBg:addChild(_lastTitle)
	local _lastCountLabel = XTHDLabel:create("0",20+2,"res/fonts/def.ttf")
	self.lastCountLabel = _lastCountLabel
	_lastCountLabel:setAnchorPoint(cc.p(0,0))
	_lastCountLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("baise"))
	_lastCountLabel:enableShadow(BangPaiFengZhuangShuJu.getTextColor("baise"),cc.size(0.4,-0.4),1)
	_lastCountLabel:enableOutline(cc.c4b(0,0,0,255),0.5)
	_lastCountLabel:setPosition(cc.p(_lastTitle:getBoundingBox().x+_lastTitle:getBoundingBox().width+3,_bottomUpPosY))
	_bottomBg:addChild(_lastCountLabel)
	self:setLastChallengeCount()

	local _introduceLabel = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.guildBossIntroduceTextXc,20)
	_introduceLabel:setColor(cc.c3b(243,178,84))
	-- _introduceLabel:enableShadow(BangPaiFengZhuangShuJu.getTextColor("juhongse"),cc.size(0.4,-0.4),0.4)
	_introduceLabel:setAnchorPoint(cc.p(0,1))
	_introduceLabel:setPosition(cc.p(_lastTimeLabel:getPositionX(),_bottomDownPosY))
	_bottomBg:addChild(_introduceLabel)

	--rewardBtn
	local _rewardBtn = XTHD.createButton({
			normalFile = "res/image/guild/guildBoss/guildBoss_reward_normal.png",
			selectedFile = "res/image/guild/guildBoss/guildBoss_reward_selected.png",
		})
	_rewardBtn:setTouchEndedCallback(function()
			self:rewardBtnCallback()
		end)
	_rewardBtn:setScale(0.7)
	_rewardBtn:setPosition(cc.p(_bottomBg:getContentSize().width - 57,_bottomDownPosY))
	_bottomBg:addChild(_rewardBtn, 1)

	--红点提示
	self.red_point = XTHD.createSprite("res/image/common/heroList_redPoint.png")
    self.red_point:setPosition(_rewardBtn:getContentSize().width-15,_rewardBtn:getContentSize().height-15)
    _rewardBtn:addChild(self.red_point)
	self.red_point:setVisible(false)
	XTHD.addEventListener({name = "GuildBossreward",callback = function( event )
        if event.data.name == "reward" then
            if tonumber(event.data.visible) == 2 then
                if tonumber(event.data.visible) == 2 and self.red_point ~=nil then
                self.red_point:setVisible(true)
                end
            end
        end
    end})
    XTHD.addEventListener({name = "GuildBossreward2",callback = function( event )
        if event.data.name == "reward" then
            if tonumber(event.data.visible) ~= 2 and self.red_point ~=nil then
                self.red_point:setVisible(false)
            end
        end
    end})



	--BossItems
	local _tableViewSize = cc.size(self:getContentSize().width,_bottomBg:getContentSize().height)
	self.tableViewCellSize  = cc.size(270,_tableViewSize.height)

	local _tableView = CCTableView:create(_tableViewSize)
	TableViewPlug.init(_tableView)
    _tableView:setBounceable(false)
	_tableView:setDelegate()
	_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) 
	_tableView:setPosition(cc.p(0,40))
	self.tableView = _tableView
	_bottomBg:addChild(_tableView)

	local function numberOfCellsInTableView(table)
		return #self.bossData.list
	end

	local function cellSizeForTable(table, idx)
		return self.tableViewCellSize.width,self.tableViewCellSize.height
	end

	local function tableCellAtIndex(table, idx)
		local cell = table:dequeueCell()
		if cell then
			cell:removeAllChildren()
		else
			cell = cc.TableViewCell:create()
			cell:setContentSize(self.tableViewCellSize.width,self.tableViewCellSize.height)
		end
		local _bossBg = self:createCellItem(idx+1)
		_bossBg:setPosition(cc.p(self.tableViewCellSize.width/2,self.tableViewCellSize.height/2))
		cell:addChild(_bossBg)

		return cell
	end
	_tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView.getCellNumbers=numberOfCellsInTableView
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView.getCellSize=cellSizeForTable
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData()
    self:scrollToKillingCell()

end

function BangPaiBoos:createCellItem(_idx)
	local _bossData = self.bossData.list[_idx] or {}
	local _bossStaticData = self.staticFactionBoss[tonumber(_bossData.configId)]
	local _bossId = _bossStaticData.imageName or 1
	local _bossBg = XTHD.createButton({
			normalFile = "res/image/guild/guildBoss/guildBoss_item" .. _bossId .. ".png",
			touchScale = 0.95,
			touchSize = cc.size(270,411),
			needEnableWhenMoving = true,
			needSwallow = false
		})
		_bossBg:setScale(0.7)
	_bossBg:setClickable(false)
	_bossBg:setTouchEndedCallback(function()
			self:challengeBtnCallback(_idx)
		end)
	--击杀奖励（所有人都有的）
	if _bossData.rewardData==nil or next(_bossData.rewardData)==nil then
		local _rewardData = string.split(_bossStaticData.killreward1,"#")
		_bossData.rewardData = _rewardData	
	end
	--
	local _bossState = _bossData.deadRewardState or 0
	--killed
	local _labelPosY = 85
	local _rewardPosY = 40

	if _bossData.curHp and tonumber(_bossData.curHp) <= 0 then
		XTHD.setGray(_bossBg:getStateNormal() ,true)
		local _killedSp = cc.Sprite:create("res/image/guild/guildBoss/imgText_killed.png")
		_killedSp:setPosition(cc.p(_bossBg:getContentSize().width/2,_bossBg:getContentSize().height/2+10))
		_bossBg:addChild(_killedSp)
		local _killerStr = LANGUAGE_TIPS_WORDS239 .. _bossData.killName
		local _killerLabel = XTHDLabel:create(_killerStr,20)
		_killerLabel:setColor(cc.c3b(0,0,0))
		_killerLabel:setPosition(cc.p(_bossBg:getContentSize().width/2,_labelPosY))
		_bossBg:addChild(_killerLabel)
		local _getRewardBtn = nil
		if _bossState==1 then
			_getRewardBtn = XTHD.createCommonButton({
				btnColor = "write_1",
				isScrollView = true,
				btnSize = cc.size(148,46),
				text = LANGUAGE_KEY_FETCHREWARD,
				fontSize = 20,
			})
			_getRewardBtn:setScale(0.7)
			_getRewardBtn:setTouchEndedCallback(function()
				self:getRewardBtnCallback(_idx,function()
	                    local _posx = _getRewardBtn:getPositionX()
	                    _getRewardBtn:removeFromParent()
	                    _getRewardBtn = cc.Sprite:create("res/image/vip/yilingqu.png")
	                    _getRewardBtn:setScale(0.7)
	                    _getRewardBtn:setPosition(cc.p(_posx,_rewardPosY))
	                    _bossBg:addChild(_getRewardBtn)
					end)
			end)
		else
			_getRewardBtn = cc.Sprite:create("res/image/vip/yilingqu.png")
			_getRewardBtn:setScale(0.7)
		end
		
		_getRewardBtn:setPosition(cc.p(_bossBg:getContentSize().width/2,_rewardPosY))
		_bossBg:addChild(_getRewardBtn)
		
	else
		local _rewardTitle = cc.Sprite:create("res/image/guild/guildBoss/imgText_reward.png")
		_rewardTitle:setAnchorPoint(cc.p(0,0.5))
		_rewardTitle:setPosition(cc.p(80,_rewardPosY))
		_bossBg:addChild(_rewardTitle)
		local _rewardSp = cc.Sprite:create("res/image/common/header_contri.png")
		_rewardSp:setAnchorPoint(cc.p(0,0.5))
		_rewardSp:setPosition(cc.p(_rewardTitle:getBoundingBox().width+_rewardTitle:getBoundingBox().x,_rewardPosY))
		_bossBg:addChild(_rewardSp)
		local _rewardValue = getCommonWhiteBMFontLabel(_bossData.rewardData[3] or 0)
		_rewardValue:setAnchorPoint(cc.p(0,0.5))
		_rewardValue:setPosition(cc.p(_rewardSp:getBoundingBox().x+_rewardSp:getBoundingBox().width,_rewardPosY-7))
		_bossBg:addChild(_rewardValue)
		if self.isKillingIdx and self.isKillingIdx == _idx then--killing
			-- local _bloodTitleLabel = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.guildBossLastBloodTextXc,20)
			local _bloodTitleLabel = cc.Sprite:create("res/image/guild/guildBoss/syxl.png")
			_bloodTitleLabel:setAnchorPoint(cc.p(1,0.5))
			_bloodTitleLabel:setPosition(cc.p(_bossBg:getContentSize().width/2+10,_labelPosY))
			_bossBg:addChild(_bloodTitleLabel)
			local _bloodValue = string.format("%.4f", _bossData.curHp/_bossData.maxHp)*100 .. "%"
			local _bloodLabel = XTHDLabel:create(_bloodValue,30)
			_bloodLabel:setAnchorPoint(cc.p(0,0.5))
			_bloodLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("hongse"))
			_bloodLabel:setPosition(cc.p(_bloodTitleLabel:getBoundingBox().x+_bloodTitleLabel:getBoundingBox().width + 5,_bloodTitleLabel:getPositionY()))
			_bossBg:addChild(_bloodLabel)
			_bossBg:setClickable(true)
		else
			XTHD.setGray(_bossBg:getStateNormal() ,true)
			XTHD.setGray(_rewardTitle,true)
			XTHD.setGray(_rewardSp,true)
			local _labelSp = cc.Sprite:create("res/image/guild/guildBoss/imgText_needKill.png")
			_labelSp:setPosition(cc.p(_bossBg:getContentSize().width/2,_labelPosY))
			_bossBg:addChild(_labelSp)
		end
	end

	return _bossBg
end

function BangPaiBoos:setLastTime()
	self:stopActionByTag(666)
	if self.lastTime==nil then
		return
	end
	local _timeNumber = self.bossData.resetTime or 0
	local _timetable = {}
	_timetable._day = math.floor(_timeNumber/86400)
	_timeNumber = _timeNumber%86400
	_timetable._hour = math.floor(_timeNumber/3600)
	_timetable._hournext = "_day"
	_timeNumber = _timeNumber%3600
	_timetable._minute = math.floor(_timeNumber/60)
	_timetable._minutenext = "_hour"
	_timeNumber = _timeNumber%60
	_timetable._second = _timeNumber
	_timetable._secondnext = "_minute"
	local function _timeFunc(_timetable_,_key)
		if _key == nil then
			return nil
		end
		if _timetable_[_key]~=nil and tonumber(_timetable_[_key]) == 0 then
			_timetable_[_key] = 60-1
			return _timeFunc(_timetable_,_timetable_[_key .. "next"])
		elseif _timetable_[_key]==nil then
			return nil
		else
			-- print("shatter>>>>" .. _timetable_[_key])
			_timetable_[_key] = (tonumber(_timetable_[_key])+60-1)%60
			return _timetable_
		end
	end
	self.lastTime:setString(LANGUAGE_KEY_GETTIME(_timetable))
	schedule(self,function()
			local _new_timeTable_ = _timeFunc(_timetable,"_second")
			if _new_timeTable_==nil or next(_new_timeTable_) ==nil then
				self:stopActionByTag(666)
				return 
			end
			_timetable = _new_timeTable_
			self.lastTime:setString(LANGUAGE_KEY_GETTIME(_new_timeTable_))
        end,1,666)

end

function BangPaiBoos:setLastChallengeCount()
	if self.lastCountLabel ==nil then
		return
	end
	self.lastCountLabel:setString(self.bossData.surplusCount or 0)
end

function BangPaiBoos:challengeBtnCallback(_idx)
	if tonumber(self.bossData.surplusCount or 0)<=0 then
		XTHDTOAST(LANGUAGE_TIPS_WORDS214)
		return
	end
	LayerManager.addShieldLayout()
	local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):create(BattleType.GUILD_BOSS_PVE,_idx)
	fnMyPushScene(_layer)
	self:refreshRedPoint()
end

function BangPaiBoos:getRewardBtnCallback(_idx,_callback)
	ClientHttp:httpGuild( "guildBossDeadReward?", self, function(_data)
			if _data.bagItems~=nil then
				for i=1,#_data.bagItems do
					local item_data = _data.bagItems[i]
					DBTableItem.updateCount(gameUser.getUserId(), item_data, item_data.dbId)
				end
			end
			local mDatas = BangPaiFengZhuangShuJu.getGuildData()
            if mDatas.list and #mDatas.list > 0 then
                for k,v in pairs(mDatas.list) do
                    if v.charId == gameUser.getUserId() then
                        v.dayContribution = tonumber(_data.dayContribution) or 0
                        v.totalContribution = tonumber(_data.totalContribution) or 0
                        break
                    end
                end
            end
            BangPaiFengZhuangShuJu.setGuildData(mDatas)
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
            self.bossData.list[_idx].deadRewardState = 0

			local _rewardData = {}
			if self.staticFactionBoss[tonumber(_idx)].rewardData==nil or next(self.staticFactionBoss[tonumber(_idx)].rewardData)==nil then
				_rewardData = string.split(self.staticFactionBoss[tonumber(_idx)].killreward1,"#")
			else
				_rewardData = self.staticFactionBoss[tonumber(_idx)].rewardData
			end
			local _rewardTable = {}
			_rewardTable[1] = {rewardtype = tonumber(_rewardData[1] or 1),id = tonumber(_rewardData[2] or 0),num = tonumber(_rewardData[3] or 0)}
			ShowRewardNode:create(_rewardTable)
			if _callback~=nil then
				_callback()
			end
		end,{configId = self.bossData.list[_idx].configId})
end

function BangPaiBoos:rewardBtnCallback()
	ClientHttp:httpGuild( "guildBossHurtRewarList?", self, function(_data)
			local _popLayer = requires("src/fsgl/layer/BangPai/BangPaiBoosJiangLi.lua"):create(_data)
		    self:addChild(_popLayer)
		end)
	
end

function BangPaiBoos:scrollToKillingCell(flag)
	if self.isKillingIdx == nil or self.tableView==nil then
		return 
	end
	local _flag = true
	-- if  flag~=nil and flag==false then
	-- 	_flag = false
	-- end
	local _index = self.isKillingIdx - 3
	_index = _index >0 and _index or 0
	self.tableView:scrollToCell(_index,_flag)

end

function BangPaiBoos:refreshDataAndLayer()
	self.tableView:reloadDataAndScrollToCurrentCell()
	self:scrollToKillingCell(false)
	self:setLastChallengeCount()
	self:setLastTime()
end

function BangPaiBoos:getStaticData()
	self.staticFactionBoss = {}
	self.staticFactionBoss = gameData.getDataFromCSV("SectBoss")
end

function BangPaiBoos:setBossData(_data)
	self.bossData = {}
	self.isKillingIdx = #_data.list or 1
	for i=1,#_data.list do
		if _data.list[i].curHp and tonumber(_data.list[i].curHp)>0 then
			self.isKillingIdx = i
			break
		end
	end
	self.bossData = _data
end

function BangPaiBoos:httpAgainCallback()
	local function _successFunc(data)
		self:setBossData(data)
		self:refreshDataAndLayer()
	end
	ClientHttp:httpGuild( "guildBossList?", self, function(_data)
			_successFunc(_data)
		end)
	
end

function BangPaiBoos:onEnter()
	if self.httpAgain~=nil then
		self:httpAgainCallback()
	end
	self.httpAgain = true
	 self:refreshRedPoint()


end
function BangPaiBoos:refreshRedPoint()
	--加红点提示
	ClientHttp:httpGuild( "guildBossHurtRewarList?", self, function(_data)
		local dataList = _data.list
		for i=1,#dataList do
			XTHD.dispatchEvent({name = "GuildBossreward",data = {["name"] = "reward",["visible"] = dataList[i]["state"]}})
		end
	end)
end

function BangPaiBoos:onCleanup()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
end

function BangPaiBoos:create(data)
	local _layer = self.new(data)
	return _layer
end

return BangPaiBoos