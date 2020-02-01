--[[
authored by LITAO
种族里的具体城市 
]]
local ZhongZuCity = class("ZhongZuCity",function( )
	return XTHDDialog:create()	
end)

function ZhongZuCity:ctor(cityIndex,isEnemy,parent)
	self.__isEnemy = isEnemy --是否是敌人的城市 ，1 为自己的，2 为敌人的
	self.__cityIndex = cityIndex --进入的是哪个城市 城市ID
	self.__parent = parent
	self.__tianBar = nil --天道盟的领地点进度条
	self.__wujiBar = nil --无极营的领地点进度条
	self.__cityNode = nil  --地图面板
	self.__inputBox = nil
	self.__friendList = nil  --己方种族的成员列表
	self.__enemyList = nil -- 敌方种族的成员列表
	self.__fightReportList = nil --战报列表
	self.__campChatList = nil ---种族聊天列表
	self.__selectedEnemyIndex = 1 --当前选中的敌方索引
	self.__changeBtnWord = nil --更换对手或者调整队伍按钮上的文字
	self.__selfCityTeams = nil --当前是自己的城市时，存储当前玩家在该城里的所有防守队伍
	self.__selfFriendDatas = nil --进入自己的城市时，当前城市里所有的友军列表
	self.__midBack = nil --中间黑的背景图片
	self.__tipsSetDefendTeam = nil ---提示玩家设置防守队伍的label
	self.__fightCountDownLabel = nil ---离种族战开战的倒计时
	self.__isAtChanllengeCD = false --当前是否处于挑战CD冷却阶段
	self.__isBattleBegin = false ---是否种族战已开始 
	self.__myDefendTeams = nil --我的守军

	self._fightCD = 0 ----

	self.__embattledTeams = {} --选择的战队里的成员
	self.color = {
		red = cc.c3b(255,0,0),
		green = cc.c3b(29,223,102),
		pink = cc.c3b(196,79,171),
		gray = cc.c3b(218,218,218)
	}
	self.tag = {
		ktag_action_chanllengeCD = 1024,
		ktag_action_campOverCD = 1025,
	}
end

function ZhongZuCity:create(cityindex,isEnemy,parent)
	return ZhongZuCity.new(cityindex,isEnemy,parent)
end

function ZhongZuCity:onEnter( )		
	self:requestData()
end

function ZhongZuCity:onExit( )
	if self.__midBack then 
		self.__midBack:removeAllChildren()
	end 
		
	XTHD.removeEventListener(EVENT_NAME_REFRESH_CAMPCHAT_ATCAMP)
	if self.scheduleID then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleID)
		self.scheduleID = 0	
	end 
	self:stopActionByTag(self.tag.ktag_action_chanllengeCD)
	self:stopActionByTag(self.tag.ktag_action_campOverCD)
	self:resetPriviteDatas()
end

function ZhongZuCity:requestData( )
	local method = "campSelfCity?"
	if self.__isEnemy == 2 then 
		method = "campRivalCity?"
	end 
    ZhongZuDatas.requestServerData({
        target = self,
        method = method,
        params = {cityId=self.__cityIndex},
        success = function( )
			XTHD.dispatchEvent({name = CUSTOM_EVENT.ISDISPLAY_CAMP_CHATBUTTON,data = false})
        	if self.__isEnemy == 2 then ---当前是进敌方城市 
        		if not ZhongZuDatas._serverEnemyCityDatas then 
	        		return 
	        	end 
	        	local num = tonumber(ZhongZuDatas._serverEnemyCityDatas.defendSum)
	        	if num and num < 1 then 
	        		-- XTHDTOAST("这座城市是你的了！！")
		    		ZhongZuDatas.requestServerData({
		    			method = "rivalCampCityList?",
        				target = self,
		    			success = function( )
							if self.__parent then 
								self.__parent:updateCitysTips()
		    					-- LayerManager.removeLayout(self)
		    					self:removeFromParent()
								XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_CAMP_SELFCITIES}) ---刷新种族主面板
							end         				
		    			end,
		    			failure = function( )
		    				-- LayerManager.removeLayout(self)
		    				self:removeFromParent()
		    			end
		    		})
	        		return 
	        	end 
	        end 
	      	ZhongZuDatas.requestServerData({
        		target = self,
	      		method = "searchMyDefendGroup?",
	      		success = function( )
        			self:init()						      			
	      		end,
	      		failure = function( )
	      			-- LayerManager.removeLayout(self)
	      			self:removeFromParent()
	      		end
	      	})
        end,
        failure = function(data)        	
        	if data and next(data) ~= nil and tonumber(data.result) == 4801 then ---该城市已经被占领了
	    		ZhongZuDatas.requestServerData({
        			target = self,
	    			method = "rivalCampCityList?",
	    			success = function( )
						if self.__parent then 
							self.__parent:updateCitysTips()
	    					-- LayerManager.removeLayout(self)
	    					self:removeFromParent()
							XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_CAMP_SELFCITIES}) ---刷新种族主面板
						end         				
	    			end,
	    			failure = function( )
	    				-- LayerManager.removeLayout(self)
	    				self:removeFromParent()
	    			end
	    		})
	    	else 
	            -- LayerManager.removeLayout(self)
	            self:removeFromParent()
            end
        end
    })
end

function ZhongZuCity:init(  )
	self.__selfFriendDatas = self:getSelfFriendsData()
	self.__selfDefendTeams = self:getSelfDefendTeams()
	--返回按钮
	local x,y 
	local backButton = XTHD.createNewBackBtn(function( )
        ZhongZuDatas.requestServerData({
        	target = self,
        	method = "selfCampCityList?",
			noCircle = true,
			success = function( )
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_CAMP_SELFCITIES})
			end
        })
		XTHD.dispatchEvent({name = CUSTOM_EVENT.ISDISPLAY_CAMP_CHATBUTTON,data = true})
		-- LayerManager.removeLayout(self)
		self:removeFromParent()
	end)
	self:addChild(backButton,1)
	backButton:setPosition(winSize.width,winSize.height)
	
	x,y = backButton:getPosition()
	---背景
	local cityBg = cc.Sprite:create("res/image/daily_task/arena/bg2.jpg")
	self:addChild(cityBg)
	cityBg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	----内容节点 
	self._contentNode = cc.Node:create()
	self._contentNode:setContentSize(XTHD.resource.visibleSize)
	self:addChild(self._contentNode)
	self._contentNode:setAnchorPoint(0.5,0.5)
	self._contentNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self.__cityNode = self._contentNode
	--进度条
	local barBack = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading_bg_new2.png")
	self._contentNode:addChild(barBack)
	barBack:setPosition(self._contentNode:getContentSize().width / 2,self._contentNode:getContentSize().height - 28)
	self.__progressBarbg = barBack
	----左边种族图标
	local _campID = gameUser.getCampID()
	local _icon = cc.Sprite:create("res/image/camp/camp_icon_small1.png")
	self._contentNode:addChild(_icon)
	_icon:setAnchorPoint(1,0.5)
	_icon:setPosition(barBack:getPositionX() - barBack:getContentSize().width / 2 + 7,barBack:getPositionY())
	----右边种族图标
	_icon = cc.Sprite:create("res/image/camp/camp_icon_small2.png")
	self._contentNode:addChild(_icon)
	_icon:setAnchorPoint(0,0.5)
	_icon:setPosition(barBack:getPositionX() + barBack:getContentSize().width / 2 - 7,barBack:getPositionY())
    ----蓝进度条
    local blueBar = ccui.LoadingBar:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading_new2.png",50)
    barBack:addChild(blueBar)
    blueBar:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
    self.__tianBar = blueBar
    ----红进度条
    local redBar = ccui.LoadingBar:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading_new1.png",50)
    barBack:addChild(redBar)
    redBar:setDirection(1) --设置从右到左
    redBar:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
    self.__wujiBar = redBar
    -----条上的动画
    local _barFlash = sp.SkeletonAnimation:create("res/image/camp/frames/dzt.json","res/image/camp/frames/dzt.atlas",1.0)
    if _barFlash then 
        barBack:addChild(_barFlash)
        _barFlash:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
        _barFlash:setAnimation(0,"animation",true)
    end 
	----中间的VS
	_icon = cc.Sprite:create("res/image/camp/camp_VS.png")
	barBack:addChild(_icon)
	_icon:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
	self.__campVSIcon = _icon
	--中间的背景
	local midBg = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_city_midbg2.png")
	self._contentNode:addChild(midBg)
	midBg:setAnchorPoint(0.5,1)
	midBg:setPosition(self._contentNode:getContentSize().width / 2,barBack:getPositionY() - barBack:getBoundingBox().height)
	self.__midBack = midBg
	---底部信息输入
    local inputBox = ccui.EditBox:create(cc.size(705,30),IMAGE_KEY_CAMP_RES_PATH.."camp_input_box3.png")
    inputBox:setFontSize(20)
    inputBox:setFontName("res/fonts/def.ttf")
    inputBox:setAnchorPoint(0.5,0.5)
    inputBox:setPlaceHolder(LANGUAGE_KEY_INPUT_WORDA)
    inputBox:setPosition(self._contentNode:getContentSize().width / 2,28)
    self._contentNode:addChild(inputBox)
    self.__inputBox = inputBox
    --展开聊天按钮
    local openBtn = XTHD.createCommonButton({
    	btnColor = "blue",
    	btnSize = cc.size(130,49),
		text = LANGUAGE_KEY_UNFOLD,
		isScrollView = false,
    	fontSize = 25,
		musicFile = XTHD.resource.music.effect_btn_common,
    })
    openBtn:setScale(0.7)
    self._contentNode:addChild(openBtn)
   	openBtn:setAnchorPoint(1,0.5)
    openBtn:setPosition(inputBox:getPositionX() - inputBox:getContentSize().width / 2 - 8,inputBox:getPositionY())
    openBtn:setTouchEndedCallback(function(  )
		print("open chat panel")
    end)
    openBtn:setVisible(false)
    --发送按钮
    local sendBtn = XTHD.createCommonButton({
        btnColor = "green",
		btnSize = cc.size(130,49),
		isScrollView = false,
    	text = LANGUAGE_KEY_SEND,
    	fontSize = 25,
		musicFile = XTHD.resource.music.effect_btn_common,
    })
    sendBtn:setScale(0.7)
    self._contentNode:addChild(sendBtn)
    sendBtn:setAnchorPoint(0,0.5)
    sendBtn:setPosition(inputBox:getPositionX() + inputBox:getContentSize().width / 2 + 8,inputBox:getPositionY())
    sendBtn:setTouchEndedCallback(function(  )
		self:sendChatMsg()
    end)
    -----聊天列表
    local viewSize = cc.size(850,midBg:getPositionY() - midBg:getBoundingBox().height - openBtn:getPositionY() - openBtn:getBoundingBox().height / 2)
	self:initCampChatList(self._contentNode,viewSize)
	-----
	local postImg = nil	
	local _str = ""
	local _number = 0
	if self.__isEnemy == 2 then ----敌方
		--种族战什么时候结束 
		local _label = XTHDLabel:createWithParams({
			text = LANGUAGE_CAMP_COUNTDOWNPRE,
			fontSize = 18,
		})
		self:addChild(_label)
		_label:setAnchorPoint(0,0.5)
		_label:setPosition(10,self:getContentSize().height - _label:getContentSize().height / 2 - 20)
		--沙漏
		local _sandClock = cc.Sprite:create("res/image/camp/camp_sandclock.png")
		self:addChild(_sandClock)
		_sandClock:setAnchorPoint(0,0.5)
		_sandClock:setPosition(_label:getPositionX() + _label:getContentSize().width,_label:getPositionY())
		local _warFinishCountDown = cc.Label:createWithBMFont("res/fonts/pvpshuzi.fnt","00:00")
		self:addChild(_warFinishCountDown)
		_warFinishCountDown:setAnchorPoint(0,0.5)
		_warFinishCountDown:setPosition(_sandClock:getPositionX() + _sandClock:getContentSize().width,_label:getPositionY() - 7)
		self.__warFinishCountDown = _warFinishCountDown
		--左种族图标	
		local icon = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_icon_gradient_new".._campID..".png")
		midBg:addChild(icon)
		icon:setAnchorPoint(0,0.5)
		icon:setPosition(240,midBg:getContentSize().height - icon:getContentSize().height / 2 - 8)
		----右种族图标
		icon = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_icon_gradient_new"..(3 - _campID)..".png")
		midBg:addChild(icon)
		icon:setAnchorPoint(1,0.5)
		icon:setPosition(675,midBg:getContentSize().height - icon:getContentSize().height / 2 - 8)
		----该城市剩余守军
		local img = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_rest_army_new.png")
		local num = ZhongZuDatas._serverEnemyCityDatas.defendSum
		midBg:addChild(img)
		img:setPosition(midBg:getContentSize().width / 2 - 20,midBg:getContentSize().height - 40)		
		--数字
		local armyNum = cc.Label:createWithBMFont("res/fonts/fashugongji.fnt",num)
		img:addChild(armyNum)
		armyNum:setAnchorPoint(0,0.5)	
		armyNum:setPosition(img:getContentSize().width,img:getContentSize().height / 2)
		armyNum:setScale(0.5)
		self.__myDefendTeams = armyNum
		----我已击伤次数
		local _y = img:getPositionY() - img:getContentSize().height - 10
		img = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_self_skillCount.png")
		num = ZhongZuDatas._serverEnemyCityDatas.myKillSum
		midBg:addChild(img)
		img:setPosition(midBg:getContentSize().width / 2 - 20,_y)
		--数字
		armyNum = cc.Label:createWithBMFont("res/fonts/wuligongji.fnt",num)
		img:addChild(armyNum)
		armyNum:setAnchorPoint(0,0.5)	
		armyNum:setPosition(img:getContentSize().width,img:getContentSize().height / 2)
		armyNum:setScale(0.5)
		self.__mykillCount = armyNum
		_str = LANGUAGE_CAMP_TIPSWORDS20
		if ZhongZuDatas._serverEnemyCityDatas then 
			_number = ZhongZuDatas._serverEnemyCityDatas.myKillRank
		end 
		-----数据
		self.__enemyDefendTeams = self:getEnemyDefentTeams()
		self:initFightReportList(midBg)
	else 
		----黄背景
		local _bg = cc.Sprite:create("res/image/camp/camp_defend_yellowbg.png")
		midBg:addChild(_bg)
		_bg:setPosition(midBg:getContentSize().width / 2 + 2,midBg:getContentSize().height - _bg:getContentSize().height / 2 - 9)
		--种族图标	
		local icon = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_icon_gradient_new".._campID..".png")
		_bg:addChild(icon)
		icon:setAnchorPoint(0,0.5)
		icon:setPosition(10,_bg:getBoundingBox().height / 2)
		----无聊的文字 
		local _word = cc.Sprite:create("res/image/camp/camp_defend_words".._campID..".png")
		_bg:addChild(_word)
		_word:setAnchorPoint(0,0.5)
		_word:setPosition(icon:getPositionX() + icon:getBoundingBox().width + 5,icon:getPositionY() + 10)
		---所在城市 
		local _cityTips = cc.Sprite:create("res/image/camp/camp_defend_words3.png")
		_bg:addChild(_cityTips)
		_cityTips:setAnchorPoint(0,0.5)
		_cityTips:setPosition(_word:getPositionX(),_word:getPositionY() - _word:getBoundingBox().height / 2 - _cityTips:getBoundingBox().height / 2 - 5)
		----城市名字
		local cityName = ZhongZuDatas._localCity[self.__cityIndex].cityName
		cityName = XTHDLabel:createWithParams({
			text = cityName,
			fontSize = 20,
			color = cc.c3b(179,27,28),
		})
		_bg:addChild(cityName)
		cityName:setAnchorPoint(0,0.5)
		cityName:setPosition(_cityTips:getPositionX() + _cityTips:getBoundingBox().width,_cityTips:getPositionY())
		---防守说明
		local str = string.format("<color=#cd6614 fontSize=16 >%s</color><color=#462222 fontSize=16 >%s</color>","\t"..LANGUAGE_KEY_ATTENTION..":",LANGUAGE_CAMP_TIPSWORDS6)
		local multiLabel = RichLabel:createARichText(str,false,365)
		multiLabel:setAnchorPoint(0.5,1)
		multiLabel:setPosition(460,250)
		midBg:addChild(multiLabel)
		-------剩余守军
		_str = LANGUAGE_CAMP_TIPSWORDS21
		if ZhongZuDatas._serverSelfCityDatas and ZhongZuDatas._serverSelfCityDatas.teams then 
			_number = #ZhongZuDatas._serverSelfCityDatas.teams
		end 
		--------数据
		if not self.__selfDefendTeams or _G.next(self.__selfDefendTeams) == nil then 
			local tip = XTHDLabel:createWithParams({
				text = LANGUAGE_CAMP_TIPSWORDS11,
				fontSize = 20,
				color = XTHD.resource.color.brown_desc,
			})
			midBg:addChild(tip)
			tip:setContentSize(cc.size(190,127))
			tip:setDimensions(190,127)
			tip:setPosition(785,200)
			self.__tipsSetDefendTeam = tip
		end 
		self:showFightingCountDownLabel(midBg)
	end 
    ----自己的击杀排名 
    local bg = cc.Sprite:create("res/image/camp/camp_self_rangebg.png")
    midBg:addChild(bg)
    bg:setPosition(bg:getContentSize().width / 2 + 13, midBg:getContentSize().height - bg:getContentSize().height / 2 - 10)
    local label = XTHDLabel:createWithParams({
    	text = _str,
    	fontSize = 16,
    	color = XTHD.resource.color.brown_desc,
    })
    bg:addChild(label)
    label:setAnchorPoint(0,0.5)
    label:setPosition(7,bg:getContentSize().height / 2)
    -------数字
    local numLabel = cc.Label:createWithBMFont("res/fonts/nuqizengjia.fnt",_number)
    bg:addChild(numLabel)
    numLabel:setScale(0.6)
    numLabel:setAnchorPoint(0,0.5)
    numLabel:setPosition(label:getPositionX() + label:getContentSize().width,label:getPositionY())
	self.__myDefendTeams = numLabel

	if self.__enemyDefendTeams and #self.__enemyDefendTeams > 0 then 
		if self.__selectedEnemyIndex > #self.__enemyDefendTeams then 
			self.__selectedEnemyIndex = #self.__enemyDefendTeams
		end 
	end 
	self:initLeftList(midBg)
	self:initRightList(midBg)
	self:createEmbattledIcon(self.__selectedEnemyIndex)
	self:displayColdCD()	
	self:startCampWarCountDown()
	self:createWarReward()
	self:updatePowerBar()
end
--构建传入选人界面的数据，
function ZhongZuCity:ConstructDataForbattle()
	local _target_ = {}
	local teams_data = ZhongZuDatas._serverSelfDefendTeam["teams"]
	if teams_data then
		for i=1,#teams_data do
			if tonumber(teams_data[i].cityId) > 0 then 
				local _tmp_data = teams_data[i]["teams"][1]["heros"] or {}			
				if _tmp_data then
					for j=1,#_tmp_data do
						_target_[#_target_+1] = _tmp_data[j]["petId"]
					end
				end
			end 
		end
	end
	return _target_
end
--初始化天道盟的人员列表
function ZhongZuCity:initLeftList(targ )
	local cellSize = cc.size(215,65)	
	local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
    	local data = nil 
    	if self.__isEnemy == 1 then --自己
    		if self.__selfFriendDatas then 
    			return #self.__selfFriendDatas
    		end 
        else 
        	data = ZhongZuDatas._serverEnemyCityDatas
        	if data then 
        		return #data.attackRank
        	end 
    	end 
    	return 0
    end

    local function tableCellTouched(table,cell)
    	
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else 
        	cell:removeAllChildren()
        end
        local node = self:createLeftListCell(idx + 1) 
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        return cell
    end
    ---------------------------------------------------------------------------------------------------------
    local tableView = CCTableView:create(cc.size(215,285))
    tableView:setPosition(15,102)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    

	tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    targ:addChild(tableView)
    self.__friendList = tableView
end

function ZhongZuCity:initRightList(targ)
	local cellSize = cc.size(215,65)	
	if self.__isEnemy == 1 then 
		cellSize = cc.size(215,90)	
	end 	
	local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
    	local data = nil
    	if self.__isEnemy == 1 then -- 自己	
        	data = self.__selfDefendTeams
        	return (data and data.teams) and #data.teams or 0
        else 
        	data = self.__enemyDefendTeams
        	return data and #data or 0
        end 
    end

    local function tableCellTouched(table,cell)
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else 
        	cell:removeAllChildren()
        end
        local node = self:createRightListCell(idx + 1) 
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)

        return cell
    end
    ----更换对手 
    -- local str = "tiaozhengduiwu_lan"
    local str = LANGUAGE_KEY_ADJUST_TEAM
    if self.__isEnemy == 2 then 
    	-- str = "shuaxinduishou_lan"
    	str = LANGUAGE_KEY_REFRESHENEMY
    end 

    local button = XTHD.createCommonButton({
    	btnColor = "blue",
		btnSize = cc.size(215,49),
		isScrollView = false,
        -- label = XTHD.resource.getButtonImgTxt(str),
        text = str,
        fontSize = 22,
		musicFile = XTHD.resource.music.effect_btn_common,
    })
    targ:addChild(button)
    button:setPosition(677 + button:getBoundingBox().width / 2,targ:getContentSize().height - button:getBoundingBox().height / 2 - 12)
    button:setTouchEndedCallback(function( )
    	self:handleChangeButton()
    end)
    -----对手列表 
    local tableView = CCTableView:create(cc.size(215,275))
    tableView:setPosition(677,102)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    

	tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    targ:addChild(tableView)
    self.__enemyList = tableView
    ---开战按钮
    if self.__isEnemy == 2 then 
	   	button = XTHD.createCommonButton({
			   btnSize = cc.size(215,66),
			   isScrollView = false,
	   	})
	   	targ:addChild(button)
	   	button:setPosition(677 + button:getBoundingBox().width / 2,button:getBoundingBox().height / 2 + 20)
	   	button:setTouchEndedCallback(function (  )
	   		self:handleFightButton()
	   	end)
	   	local btnName = XTHDLabel:createWithParams({
	   		text = LANGUAGE_KEY_CHALLENGE_ENEMY,
	   		fontSize = 20
	   	})
	   	button:addChild(btnName)
	   	btnName:setPosition(button:getContentSize().width / 2,button:getContentSize().height / 2)
	   	self.__changeBtnWord = btnName
	else 
		-----该队伍正在防守。。。。
		local label = XTHDLabel:createWithParams({
			text = LANGUAGE_CAMP_TIPSWORDS22,
			fontSize = 20,
			color = XTHD.resource.color.brown_desc,
		})
		targ:addChild(label)
		label:setPosition(782,72)
		--
		local cityName = XTHDLabel:createWithParams({
			text = ZhongZuDatas._localCity[self.__cityIndex].cityName,
			fontSize = 20,
			color = cc.c3b(179,27,28),
		})
		targ:addChild(cityName)
		cityName:setPosition(label:getPositionX(),label:getPositionY() - label:getBoundingBox().height)
	end 
end

function ZhongZuCity:initFightReportList(targ)
	local cellSize = cc.size(400,32)
	
	local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
    	local data = ZhongZuDatas._serverEnemyCityDatas.logs
        return data and #data or 0
    end

    local function tableCellTouched(table,cell)
    	
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else 
        	cell:removeAllChildren()
        end
        local node = self:createFightReportCell(idx + 1) 
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        return cell
    end

    local tableView = CCTableView:create(cc.size(422,185))
    tableView:setPosition(240,145)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    

	tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    targ:addChild(tableView)
    self.__fightReportList = tableView
end

function ZhongZuCity:initCampChatList(targ,viewSize)
	local cellSize = cc.size(viewSize.width,28)
	
	local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
        local data = LiaoTianDatas.getMsgsByType(LiaoTianDatas.__chatType.TYPE_CAMP_CHAT)
        return data and #data or 0
    end

    local function tableCellTouched(table,cell)
    	
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else 
        	cell:removeAllChildren()
        end
        local node = self:createChatCell(idx + 1) 
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        return cell
    end

    local tableView = CCTableView:create(viewSize)
    tableView:setPosition(
    	self.__midBack:getPositionX() - self.__midBack:getContentSize().width / 2 + 5,
    	self.__inputBox:getPositionY() + self.__inputBox:getBoundingBox().height / 2 + 2
    )
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)        

	tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    targ:addChild(tableView)
    self.__campChatList = tableView
   	XTHD.addEventListener({name = EVENT_NAME_REFRESH_CAMPCHAT_ATCAMP,callback = function( event)
		self:refreshChatList()
	end})
end
--显示种族战开始的倒计时
function ZhongZuCity:showFightingCountDownLabel(targ )
	local data = ZhongZuDatas._serverSelfCityDatas
	if not data then 
		return 
	end 	
	local label = XTHDLabel:createWithParams({
		text = LANGUAGE_CAMP_TIPSWORDS7,
		fontSize = 16,
		color = XTHD.resource.color.brown_desc,
	})
	targ:addChild(label)
	label:setPosition(430,300)

	local times = tonumber(data.times)
	local houre = times / 3600
	local minute = (times % 3600) / 60
	local seceond = (times % 3600) % 60
	data.times = tonumber(data.times) - 1
	local str = ""
	if data.times <= 0 then 
		label:setString(LANGUAGE_CAMP_TIPSWORDS17)
		self.__isBattleBegin = true
	else 
		str = LANGUAGE_CAMP_TIPSWORDS8(houre,minute,seceond)	
		local count = cc.Label:createWithBMFont("res/fonts/campbegin.fnt",str)
		targ:addChild(count)
		count:setPosition(label:getPositionX(),label:getPositionY() - label:getContentSize().height / 2 - count:getContentSize().height / 2 - 5)
		self.__fightCountDownLabel = count
		self:registFightingCountDown()
	end 
end 

function ZhongZuCity:registFightingCountDown( )
	if self.__isEnemy ~= 1 then 
		return 
	end 
	local data = ZhongZuDatas._serverSelfCityDatas
	if not data or not self.__fightCountDownLabel then  
		return 
	end 	

	local function countDwon( )		
		local times = tonumber(data.times)
		local houre = times / 3600
		local minute = (times % 3600) / 60
		local seceond = (times % 3600) % 60
		data.times = tonumber(data.times) - 1
		local str = LANGUAGE_CAMP_TIPSWORDS8(houre,minute,seceond)
		self.__fightCountDownLabel:setString(str)
		if times <= 0 then 
			self.__isBattleBegin = true
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleID)
			self.scheduleID = 0

			XTHD.dispatchEvent({name = EVENT_NAME_CAMPADJUSTLAYEREXIT})
		end 
	end
	self.scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(countDwon,1.0,false)
end
---创建左边的列表单元
function ZhongZuCity:createLeftListCell(index)
	local data = nil 
	local _iconID = 1
	if self.__isEnemy == 1 then --自己
		data = self.__selfFriendDatas
		_iconID = data[index].templateId
	else 
		data = ZhongZuDatas._serverEnemyCityDatas.attackRank	
		_iconID = data[index].templateId	
	end 
	if not data then
		return 
	end 
	local node = cc.Sprite:create()
	node:setContentSize(cc.size(215,62))
	---名次图标
	local rankIcon = nil
	local x = 15
	if self.__isEnemy == 2 then 
		if index < 4 then --图标
			rankIcon = cc.Sprite:create("res/image/ranklist/rank_"..index..".png")
			rankIcon:setScale(0.8)
		elseif index > 3 and index < 10 then --数字图标
			rankIcon = cc.Sprite:create("res/image/ranklist/rank_4.png")
			local _num = cc.Label:createWithBMFont("res/fonts/item_num.fnt",index)
			rankIcon:addChild(_num)
			_num:setScale(0.7)
			_num:setPosition(rankIcon:getContentSize().width / 2,rankIcon:getContentSize().height / 2)
		elseif index >= 10 then 
			rankIcon = cc.Label:createWithBMFont("res/fonts/item_num.fnt",index)
			rankIcon:setScale(0.6)
		end 
		node:addChild(rankIcon)
		rankIcon:setAnchorPoint(0,0.5)
		rankIcon:setPosition(2,node:getContentSize().height / 2)
		x = rankIcon:getPositionX() + rankIcon:getBoundingBox().width + 2
	end 
    ---头像
	local icon = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById(_iconID))
	node:addChild(icon)
	icon:setScale(0.63)
	icon:setTag(index)
	icon:setAnchorPoint(0,0.5)
	icon:setPosition(x,node:getContentSize().height / 2 + 3)
	local border = XTHDPushButton:createWithParams({
		normalFile = "res/image/plugin/competitive_layer/hero_board.png",
		selectedFile = "res/image/plugin/competitive_layer/hero_board.png",
		needSwallow = false,
		musicFile = XTHD.resource.music.effect_btn_common,
	})	
	border:setTouchEndedCallback(function(  )
		print("the number ",border:getTag()," be clicked")
	end)	
	node:addChild(border)
	border:setScale(0.63)
	border:setAnchorPoint(0,0.5)
	border:setPosition(icon:getPositionX() - 3,icon:getPositionY() + 1)
	local level = cc.Label:createWithBMFont("res/fonts/pvpshuzi.fnt",data[index].level)
	node:addChild(level)
	level:setScale(0.8)
	level:setPosition(border:getPositionX() + border:getBoundingBox().width - level:getBoundingBox().width / 2 - 5,level:getBoundingBox().height / 2)
	--名字
	if self.__isEnemy == 1 then 
		local name = XTHDLabel:createWithParams({
			text = data[index].name,
			fontSize = 16,
			color = XTHD.resource.color.brown_desc,
		})
		node:addChild(name)
		name:setAnchorPoint(0,0.5)
		name:setPosition(border:getPositionX() + border:getBoundingBox().width + 5,node:getContentSize().height - name:getContentSize().height )
	else 
		local name = XTHDLabel:createWithParams({
			text = data[index].name,
			fontSize = 16,
			color = XTHD.resource.color.brown_desc,
		})
		node:addChild(name)
		name:setAnchorPoint(0,0.5)
		name:setPosition(border:getPositionX() + border:getBoundingBox().width + 5,node:getContentSize().height - name:getContentSize().height / 2 - 5)
		--已经击杀
		local str = string.format("<color=#462222 fontSize=18 >%s</color><color=#cd0001 fontSize=18 >%s</color>",LANGUAGE_CAMP_TIPSWORDS10,data[index].killSum)
		local attackTime = RichLabel:createARichText(str,false)
		node:addChild(attackTime)
		attackTime:setAnchorPoint(0,0)
		attackTime:setPosition(name:getPositionX(),attackTime:getContentSize().height)
	end 
	----线
	local line = ccui.Scale9Sprite:create("res/image/chatroom/chat_fine_line.png")
	line:setContentSize(cc.size(node:getContentSize().width,1))
	node:addChild(line)
	line:setAnchorPoint(0,0.5)
	line:setPosition(0,1)
	return node
end
---创建右边的列表单元
function ZhongZuCity:createRightListCell(index)
	if self.__tipsSetDefendTeam then 
		self.__tipsSetDefendTeam:removeFromParent()
		self.__tipsSetDefendTeam = nil
	end 
	
	local data = nil 
	local _height = 63
	local _iconID = 1
	if self.__isEnemy == 1 then --自己
		data = self.__selfDefendTeams
		_height = 85
		_iconID = self.__selfDefendTeams.templateId
	else 
		data = self.__enemyDefendTeams
		_iconID = self.__enemyDefendTeams[index].templateId
	end 
	if not data then
		return 
	end 
	--头像
	local normal = ccui.Scale9Sprite:create("res/image/common/scale9_bg_12.png")
	normal:setContentSize(cc.size(215,_height))
	local _select = ccui.Scale9Sprite:create("res/image/common/scale9_bg_13.png")
	_select:setContentSize(cc.size(215,_height))
	local node = XTHDPushButton:create({
		normalNode = normal,
		selectedNode = _select,
		needSwallow = false,
		musicFile = XTHD.resource.music.effect_btn_common,
	})
	node:setTouchEndedCallback(function( )
		node:setSelected(true)
		if self.__selectEnemy then 
			self.__selectEnemy:setSelected(false)
		end 		
		self.__selectEnemy = node
		self.__selectedEnemyIndex = index
    	self:createEmbattledIcon(index)		
	end)
    if index == self.__selectedEnemyIndex then 
    	node:setSelected(true)
    	self.__selectEnemy = node
    end 
    ---头像
	local icon = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById(_iconID))
	node:addChild(icon)

	local border = cc.Sprite:create("res/image/plugin/competitive_layer/hero_board.png")
	node:addChild(border)

	if self.__isEnemy == 2 then 
		icon:setScale(0.63)
		border:setScale(0.63)
	else 
		icon:setScale(0.78)
		border:setScale(0.78)
	end 
	icon:setTag(index)
	icon:setAnchorPoint(0,0.5)
	icon:setPosition(20,node:getContentSize().height / 2)
	
	border:setAnchorPoint(0,0.5)
	border:setPosition(icon:getPositionX() - 5,icon:getPositionY() + 1)	
	if self.__isEnemy == 1 then 
		local level = cc.Label:createWithBMFont("res/fonts/pvpshuzi.fnt",gameUser.getLevel())
		node:addChild(level)
		level:setScale(0.8)
		level:setPosition(border:getPositionX() + border:getBoundingBox().width - level:getBoundingBox().width / 2 - 5,level:getBoundingBox().height / 2 + 2)
	else 
		local level = cc.Label:createWithBMFont("res/fonts/pvpshuzi.fnt",data[index].level)
		node:addChild(level)
		level:setScale(0.8)
		level:setPosition(border:getPositionX() + border:getBoundingBox().width - level:getBoundingBox().width / 2 - 5,level:getBoundingBox().height / 2)
	end 
	--名字
	local nameStr = ""
	local teamStr = ""
	if self.__isEnemy == 1 then 
		nameStr = gameUser.getNickname()
		teamStr = LANGUAGE_CAMP_TIPSWORDS12(data.teams[index][1].teamId)
	else 
		nameStr = data[index].name
		teamStr = LANGUAGE_CAMP_TIPSWORDS12(data[index].team[1].teamId)
	end 
	local name = XTHDLabel:createWithParams({
		text = nameStr,
		fontSize = 18,
		color = XTHD.resource.color.brown_desc,
	})
	name:setPosition(border:getPositionX() + border:getBoundingBox().width + 5,node:getContentSize().height / 2 + name:getContentSize().height / 2)	
	node:addChild(name)
	name:setAnchorPoint(0,0.5)
	local teamNum = XTHDLabel:createWithParams({
		text = teamStr,
		fontSize = 16,
		color = self.color.red
	})
	node:addChild(teamNum)
	teamNum:setAnchorPoint(0,0.5)
	teamNum:setPosition(name:getPositionX(),name:getPositionY() - name:getContentSize().height)

	return node
end
---创建战报
function ZhongZuCity:createFightReportCell(index )
	local node = cc.Node:create()
	node:setContentSize(cc.size(400,32))
	local data = ZhongZuDatas._serverEnemyCityDatas.logs	
	if data then 
		data = data[index]
	end 
	if not data then 
		return node
	end 
	local label = XTHDLabel:createWithParams({
		text = data.attackName,
		fontSize = 16,
		color = self.color.green
		})
	node:addChild(label)
	label:setAnchorPoint(0,0.5)
	label:setPosition(5,label:getBoundingBox().height / 2)
	node:setContentSize(label:getContentSize())
	local label1 = XTHDLabel:createWithParams({
		text = LANGUAGE_CAMP_TIPSWORDS0,
		fontSize = 16,
		color = XTHD.resource.color.brown_desc,
		})
	node:addChild(label1)
	label1:setAnchorPoint(0,0.5)
	label1:setPosition(label:getPositionX() + label:getBoundingBox().width + 2,label:getPositionY())	
	node:setContentSize(cc.size(node:getContentSize().width + label1:getContentSize().width + 7,node:getContentSize().height))

	local label2 = XTHDLabel:createWithParams({
		text = data.defendName,
		fontSize = 16,
		color = self.color.pink
		})	
	node:addChild(label2)
	label2:setAnchorPoint(0,0.5)
	label2:setPosition(label1:getPositionX() + label1:getBoundingBox().width + 2,label:getPositionY())
	node:setContentSize(cc.size(node:getContentSize().width + label2:getContentSize().width + 2,node:getContentSize().height))
	return node
end
--创建聊天信息
function ZhongZuCity:createChatCell(index)
	local node = cc.Node:create()
	local data = LiaoTianDatas.getMsgsByType(LiaoTianDatas.__chatType.TYPE_CAMP_CHAT)
	if not data then 
		return 
	end 
	data = data[index]
	local label = XTHDLabel:createWithParams({
		text = data.name..":",
		fontSize = 20,
		color = self.color.green
		})
	node:addChild(label)
	node:setContentSize(label:getContentSize())
	label:setAnchorPoint(0,0.5)
	label:setPosition(0,node:getContentSize().height / 2)
	local label1 = XTHDLabel:createWithParams({
		text = data.message,
		fontSize = 20
		})
	node:setContentSize(cc.size(node:getContentSize().width + label1:getContentSize().width,node:getContentSize().height))
	node:addChild(label1)
	label1:setAnchorPoint(0,0.5)
	label1:setPosition(label:getPositionX() + label:getContentSize().width,label:getPositionY())
	
	return node 
end
---创建上阵的人物头像
function ZhongZuCity:createEmbattledIcon(index)	
	local data = nil 
	local _level = 0
	local iconID = 1
	local badge = {}
	if self.__isEnemy == 1 then  --自己
		if not self.__selfDefendTeams then 
			return 
		end 
		data = self.__selfDefendTeams.teams[index]
		_level = gameUser.getLevel()
		badge[1] = gameUser.getCampID()---种族
		badge[2] = gameUser.getVip() --vip
		if ZhongZuDatas._serverSelfCityDatas and ZhongZuDatas._serverSelfCityDatas.leaderRank then ----竞技场排名 
			badge[3] = ZhongZuDatas._serverSelfCityDatas.leaderRank 
		else 
			badge[3] = 0
		end 
		badge[4] = gameUser.getDuanId() --竞技场段位
		iconID = self.__selfDefendTeams.templateId
	else
		if not self.__enemyDefendTeams or next(self.__enemyDefendTeams) == nil then  
			return 
		end 
		data = self.__enemyDefendTeams[index].team
		_level = self.__enemyDefendTeams[index].level
		badge[1] = 3 - gameUser.getCampID()---种族
		badge[2] = self.__enemyDefendTeams[index].vipLevel --vip
		badge[3] = self.__enemyDefendTeams[index].myCampRank --竞技场排名
		badge[4] = self.__enemyDefendTeams[index].duanId --竞技场段位
		iconID = self.__enemyDefendTeams[index].templateId
	end 
	if not data then 
		return 
	end 
	--------------------------------------------------------------------------------------------------------------------------------------------
	local x = 265
	local y = 55
	local space = 5 
	local i = 1
	for i = 1,#self.__embattledTeams do
		self.__embattledTeams[i]:removeFromParent()
		self.__embattledTeams[i] = nil
	end
	---头像
	for k,v in pairs(data[1].heros) do 
		local node = HeroNode:createWithParams({
			heroid = v.petId,
			star = v.star,
			level = v.level,
			needHp = true,
			curNum = v.curHp,
			maxNum = v.property['200'],
			advance = v.phase,
		})
		self.__midBack:addChild(node)
		node:setAnchorPoint(0,0.5)
		node:setPosition(x,y)
		node:setScale(0.72)
		---已阵亡
		if v.curHp <= 0 then 
			local _death = cc.Sprite:create("res/image/camp/camp_has_dead.png")
			node:addChild(_death)
			_death:setPosition(node:getContentSize().width / 2,node:getContentSize().height / 2)
		end 
		
		x = x + node:getBoundingBox().width + space
		self.__embattledTeams[i] = node
		i = i + 1
	end 
	----当前角色头像
	local icon = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById(iconID))
	self.__midBack:addChild(icon)
	icon:setTag(index)
	icon:setAnchorPoint(0,0.5)
	icon:setPosition(21,55)
	self.__embattledTeams[#self.__embattledTeams + 1] = icon
	local border = cc.Sprite:create("res/image/plugin/competitive_layer/hero_board.png")
	self.__midBack:addChild(border)
	border:setAnchorPoint(0,0.5)
	border:setPosition(icon:getPositionX() - 5,icon:getPositionY() + 1)
	self.__embattledTeams[#self.__embattledTeams + 1] = border
	local level = cc.Label:createWithBMFont("res/fonts/pvpshuzi.fnt",_level)
	border:addChild(level)
	level:setPosition(border:getBoundingBox().width - level:getBoundingBox().width / 2 - 7,level:getBoundingBox().height / 2 - 8)
	--名字
	local str = string.format("<color=#462222 fontSize=18 >%s</color><color=#cd6614 fontSize=18 >%s</color>",LANGUAGE_KEY_POWER,data[1].power)
	local name = RichLabel:createARichText(str,false)
	self.__midBack:addChild(name)
	name:setAnchorPoint(0,0.5)
	name:setPosition(border:getPositionX() + border:getBoundingBox().width + 5,border:getPositionY() + name:getBoundingBox().height)
	self.__embattledTeams[#self.__embattledTeams + 1] = name
	----玩家标志图标 种族、vip、竞技场排名、竞技场段位
	local x = name:getPositionX()
	local y = 38
    local camp = 0
	for k,v in pairs(badge) do 
    	local icon = nil
    	if v > 0 then 
	    	if k == 4 then ---竞技场段ID
	    		icon = cc.Sprite:create("res/image/common/rank_icon/rankIcon_"..v..".png")
	    		-- icon:setScale(0.18)
	    		icon:setScale(0.62)
	    	elseif k == 1 then --种族
	    		icon = cc.Sprite:create("res/image/chatroom/chatroom_camp"..v..".png") 
	    		camp = v
	    		icon:setScale(0.8)
	    	elseif k == 2 then --vip  
	    		icon = cc.Sprite:create("res/image/chatroom/chatroom_icon2.png") 
	    		icon:setScale(0.8)
	    	elseif k == 3 and v < 4 then ---竞技场排名,1,2,3有效		    		
	    		icon = cc.Sprite:create("res/image/chatroom/chatroom_camp"..camp.."_"..v..".png") 
	    		icon:setScale(0.8)
	    	end 
	    	self.__midBack:addChild(icon)
	    	icon:setAnchorPoint(0,0.5)
	    	icon:setPosition(x,y)
	    	x = x + icon:getBoundingBox().width
			self.__embattledTeams[#self.__embattledTeams + 1] = icon
	    end 
    end 
end
---更新领地点进度条
function ZhongZuCity:updatePowerBar( )
	local data = nil
	if self.__isEnemy == 1 then --自己
		data = ZhongZuDatas._serverSelfCity
	else 
		data = ZhongZuDatas._serverEnemyCity
	end 
	if data then 
		local all = tonumber(data.aTerritory) + tonumber(data.bTerritory)
		if self.__tianBar and self.__wujiBar then 
			self.__tianBar:setPercent(tonumber(data.aTerritory) / all * 100)
			self.__wujiBar:setPercent(tonumber(data.bTerritory) / all * 100)
		end 
		if self.__progressBarbg and self.__campVSIcon then 
			local x = tonumber(data.aTerritory) / all * self.__progressBarbg:getContentSize().width
			self.__campVSIcon:setPosition(x,self.__campVSIcon:getPositionY())
		end 
	end 
end
---获取自己的防守队伍 
function ZhongZuCity:getSelfDefendTeams(  )	
	local data = nil
	if self.__selfFriendDatas then 
		for k,v in pairs(self.__selfFriendDatas) do 
			if tonumber(v.charId) == tonumber(gameUser.getUserId()) then 
				data = v
			end 
		end 
	end 
	return data
end
----获得队友数据 主要去除重复
function ZhongZuCity:getSelfFriendsData( )
	local data = {}
	local i = 1 
	local temp = nil 
	if self.__isEnemy == 1 then  --自己
		temp = ZhongZuDatas._serverSelfCityDatas.teams
	else 
		temp = ZhongZuDatas._serverEnemyCityDatas.attackRank
	end 
	for k,v in pairs(temp) do 
		local continue = true
		for j = 1,#data do 
			if tonumber(data[j].charId) == (v.charId) then 
				local len = #data[j].teams
				data[j].teams[len + 1] = v.team
				continue = false
				break
			end 
		end 
		if continue then 
			data[i] = {
				charId = v.charId,
				name = v.name,
				templateId = v.templateId,
				level = v.level,
				teams = {v.team},
			}			
			i = i + 1
		end 
	end 
	return data
end
----获取给定城市的所有守军（敌方）
function ZhongZuCity:getEnemyDefentTeams()	
	local enemys = ZhongZuDatas._serverEnemyCityDatas.rivalTeams
	if enemys then 
		table.sort(enemys,function( a,b )
			if tonumber(a.charId) == tonumber(b.charId) then 
				return tonumber(a.team[1].teamId) < tonumber(b.team[1].teamId)
			else 
				return tonumber(a.charId) < tonumber(b.charId)
			end 
		end)
	end 
	return enemys
end
---在玩家调整了自己的防守队形之后刷新该UI
function ZhongZuCity:refreshCityAfterAdjustedTeams( )
	self.__selfFriendDatas = self:getSelfFriendsData()
	self.__selfDefendTeams = self:getSelfDefendTeams()
	if self.__myDefendTeams then  ---更新我的守军数量
		if ZhongZuDatas._serverSelfCityDatas and ZhongZuDatas._serverSelfCityDatas.teams then 
			self.__myDefendTeams:setString(#ZhongZuDatas._serverSelfCityDatas.teams)
		end 
	end 
	if self.__friendList then --更新盟军列表（左边列表）
		self.__friendList:reloadData()
	end 
	if self.__enemyList then ---更新自己的防守队伍（右边列表）
		self._last_enemyCell = nil
		self.__enemyList:reloadData()
	end 
	self:createEmbattledIcon(self.__selectedEnemyIndex) --显示在右边列表当中被选中的队伍上阵头像
	if self.__parent then 
		self.__parent:updateCitysTips()
	end 
end

function ZhongZuCity:sendChatMsg( )
	if self.__inputBox then 
		local msg = self.__inputBox:getText()
		self.__inputBox:setText("")
		if msg and type(msg) == "string" and msg ~= "" then 
			MsgCenter:getInstance():msgSend({
				type = MsgCenter.MsgType.CLIENG_REQUEST_CHAT,
				data = {
					chatType = LiaoTianDatas.__chatType.TYPE_CAMP_CHAT,
					reciverID = 0,--除了私聊外，都是0
					content = msg
				}
			})
		else
			XTHDTOAST(LANGUAGE_TIPS_WORDS12)------"不能发送空内容")
		end 
	end 
end

function ZhongZuCity:refreshChatList( )
	if self.__campChatList then 
		self.__campChatList:reloadData()
		local cellSize = cc.size(850,28)
		local msgLen = #LiaoTianDatas.getMsgsByType(LiaoTianDatas.__chatType.TYPE_CAMP_CHAT)		
		local x,y = self.__campChatList:getContentOffset()
		y = 0 - msgLen * cellSize.height
		self.__campChatList:setContentOffset(cc.p(x,0))
	end 
end
----显示挑战之后的CD冷却倒计时
function ZhongZuCity:displayColdCD( )
	if self.__isEnemy ~= 1 then 
		local CD = tonumber(ZhongZuDatas._serverEnemyCityDatas.cd)
		if not CD or CD < 1 then 
			self.__isAtChanllengeCD = false 
			return 
		end 
		if self.__changeBtnWord then 
			self.__isAtChanllengeCD = true
			self.__changeBtnWord:setString(string.format("CD:%d",CD))
			self.__changeBtnWord:setColor(cc.c3b(0,255,0))

			local function tick( )
				CD = CD - 1
				if CD < 0 then 
					self:stopActionByTag(self.tag.ktag_action_chanllengeCD)
					self.__isAtChanllengeCD = false
					self.__changeBtnWord:setString(LANGUAGE_KEY_CHALLENGE_ENEMY)
					self.__changeBtnWord:setColor(cc.c3b(255,255,255))
					return 
				end 
				if self.__changeBtnWord then 
					self.__changeBtnWord:setString(string.format("CD:%d",CD))
				end 				
			end
			schedule(self,tick,1.0,self.tag.ktag_action_chanllengeCD)
		end 
	end 
end
----右侧调整队伍，更换对手,清除Cd按钮点击事件
function ZhongZuCity:handleChangeButton( )
	if self.__isEnemy == 1 then ----调整队伍
		local embattle = requires("src/fsgl/layer/ZhongZu/ZhongZuAdjustEmbattle.lua")
		embattle = embattle:create(self.__cityIndex,self)
		self:addChild(embattle)
		-- embattle:show()
	else
		ZhongZuDatas.requestServerData({ --更换对手
        	target = self,
			method = "changeRival?",
			params = {cityId = self.__cityIndex},
			success = function( )					
				if self.__enemyList then 
					self.__enemyDefendTeams = self:getEnemyDefentTeams()
					self._last_enemyCell = nil
					self.__enemyList:reloadData()
				end 
			end
		})
	end 
end

function ZhongZuCity:handleFightButton( )
	if not self.__isAtChanllengeCD then  --开战
		if self.__enemyDefendTeams then 
			local data = self.__enemyDefendTeams[self.__selectedEnemyIndex]	
			----添加开战代码
			local hero_data = self:ConstructDataForbattle()
			LayerManager.addShieldLayout()
			local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):createWithParams({
		 		battle_type = BattleType.CAMP_PVP,
		 		Camp_data = hero_data,
		 		Camp_enemy_Data = data
		 	})
			fnMyPushScene(_layer)	 
		end 
	else 			 --清除CD
		if not ZhongZuDatas._serverEnemyCityDatas then 
			return 
		end 
		local money =  tonumber(ZhongZuDatas._serverEnemyCityDatas.clearCdSum)			
		if not money then 
			return 
		end 
		local CD = tonumber(ZhongZuDatas._serverEnemyCityDatas.cd)
		money = math.ceil(CD / 60) * (money + 50)
		local str = LANGUAGE_CAMP_TIPSWORDS16(money)
		local layer = XTHDConfirmDialog:createWithParams({
	  		msg = str,
	        rightCallback = function( )		        	
		        ZhongZuDatas.requestServerData({
        			target = self,
		        	method = "clearCampCd?",
		        	success = function(data)
		        		ZhongZuDatas._serverEnemyCityDatas.clearCdSum = data.clearCdSum
		        		gameUser.setIngot(tonumber(data.gold))

    					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO}) ---刷新主城市的，
    					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})

		        		self.__isAtChanllengeCD = false
		        		self.__changeBtnWord:stopAllActions()
		        		self.__changeBtnWord:setString(LANGUAGE_KEY_CHALLENGE_ENEMY)
						self.__changeBtnWord:setColor(cc.c3b(255,255,255))
						self:stopActionByTag(self.tag.ktag_action_chanllengeCD)
		        	end
		        }) 
	        end
	  	})
		self:addChild(layer)	
	end 	  	
end

function ZhongZuCity:resetPriviteDatas( )
	self.__tianBar = nil --天道盟的领地点进度条
	self.__wujiBar = nil --无极营的领地点进度条
	self.__cityNode = nil  --地图面板
	self.__inputBox = nil
	self.__friendList = nil  --己方种族的成员列表
	self.__enemyList = nil -- 敌方种族的成员列表
	self.__fightReportList = nil --战报列表
	self.__campChatList = nil ---种族聊天列表
	self.__changeBtnWord = nil --更换对手或者调整队伍按钮上的文字
	self.__selfCityTeams = nil --当前是自己的城市时，存储当前玩家在该城里的所有防守队伍
	self.__selfFriendDatas = nil --进入自己的城市时，当前城市里所有的友军列表
	self.__midBack = nil --中间黑的背景图片
	self.__tipsSetDefendTeam = nil ---提示玩家设置防守队伍的label
	self.__fightCountDownLabel = nil ---离种族战开战的倒计时
	self.__myDefendTeams = nil --我的守军	
	self.__embattledTeams = {}
end
----创建战报下面的奖励提示
function ZhongZuCity:createWarReward( )
	local data = {ZhongZuDatas._localReward[15],ZhongZuDatas._localReward[14]}
	local str = {LANGUAGE_CAMP_CHALLENGE_GET_LABEL,LANGUAGE_CAMP_WINNER_GET_LABEL .. ":"}
	local x = 251
	local y = 120
	for i = 1,#data do 
		local rewardLabel = XTHDLabel:createWithParams({
			text = str[i],
			fontSize = 16,
			color = XTHD.resource.color.brown_desc,
		})
		self.__midBack:addChild(rewardLabel)
		rewardLabel:setAnchorPoint(0,0.5)
		rewardLabel:setPosition(x,y)
		----暗色背景
		local darkBg = ccui.Scale9Sprite:create("res/image/equipCopies/dikuang9.png")
		darkBg:setContentSize(cc.size(100,25))
		darkBg:setAnchorPoint(0,0.5)
		self.__midBack:addChild(darkBg)
		darkBg:setPosition(rewardLabel:getPositionX() + rewardLabel:getContentSize().width + 18,rewardLabel:getPositionY())
		----奖励图标
		local icon = XTHD.createHeaderIcon(data[i].rewardItemType)
		darkBg:addChild(icon)
		icon:setPosition(0,darkBg:getContentSize().height / 2)
		---数量
		local amount = cc.Label:createWithBMFont("res/fonts/pvpshuzi.fnt",data[i].rewardAmoun)		
		darkBg:addChild(amount)
		amount:setAnchorPoint(0.5,1)
		amount:setPosition(darkBg:getContentSize().width / 2,darkBg:getContentSize().height - 3)
		x = darkBg:getPositionX() + darkBg:getContentSize().width + 20
	end 
end
----开始种族战的倒计时
function ZhongZuCity:startCampWarCountDown( )
	if self.__warFinishCountDown and ZhongZuDatas._serverEnemyCityDatas and ZhongZuDatas._serverEnemyCityDatas.campDiffTime then 
		local _data = ZhongZuDatas._serverEnemyCityDatas.campDiffTime
		local _hour = math.floor(_data / 3600)
		_data = _data % 3600
		local _minute = math.ceil(_data / 60)
		self.__warFinishCountDown:setString(LANGUAGE_TIPS_LINK_HOUR_MINUTE(_hour,_minute))
		if not self:getActionByTag(self.tag.ktag_action_campOverCD) then 
			schedule(self,function ( )
				ZhongZuDatas._serverEnemyCityDatas.campDiffTime = ZhongZuDatas._serverEnemyCityDatas.campDiffTime - 1			
				if ZhongZuDatas._serverEnemyCityDatas.campDiffTime < 1 then 
					self:stopActionByTag(self.tag.ktag_action_campOverCD)
				else 
					_data = ZhongZuDatas._serverEnemyCityDatas.campDiffTime
					_hour = math.floor(_data / 3600)
					_data = _data % 3600
					_minute = math.ceil(_data / 60)
					self.__warFinishCountDown:setString(LANGUAGE_TIPS_LINK_HOUR_MINUTE(_hour,_minute))
				end 
			end,1.0,self.tag.ktag_action_campOverCD)
		end 
	end 
end

return ZhongZuCity