--Created By Liuluyang 2015年08月12日
local JingJiMainLayer = class("JingJiMainLayer",function ()
	return XTHD.createBasePageLayer()
end)

function JingJiMainLayer:ctor(data,extra,callback)
	self._exist = true
	self._needPointTo = extra ----是否需要用手指指向竞技场按钮（17 抢夺、63排位 ） 
	self._pointer = nil ----手指
	self._btnList = {}
	self._topbar = self:getChildByName("TopBarLayer1")
	self.Tag = {
		ktag_robberRecoverTag = 512,
	}
	self._globalScheduler = GlobalScheduler:create(self)
	self.callback = callback
	-- print("竞技场的数据为：")
	-- print_r(data)
	self._data = data
	self:initUI()
	
	self:refreshLayer(data)
	XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_PVP_MAIN_LAYER,
        callback = function (event)
        	ClientHttp:requestAsyncInGameWithParams({
		        modules = "arenaTeams?",
		        params = {},
		        successCallback = function(net_data)
		            if tonumber(net_data.result) == 0 then
		            	if self._exist then
		            		self:refreshLayer(net_data)
		            	end
		            else
		                XTHDTOAST(net_data.msg or LANGUAGE_TIPS_WEBERROR)----- "网络请求失败")
		            end
		        end,--成功回调
		        failedCallback = function()
		            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
		        end,--失败回调
		        targetNeedsToRetain = self,--需要保存引用的目标
		        loadingParent = self,
		        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		    })
        end
    })
end

function JingJiMainLayer:onCleanup()
	self._exist = false
    local textureCache = cc.Director:getInstance():getTextureCache()
	if self.callback and type(self.callback) == "function" then
		self.callback()
	end
	helper.collectMemory()
end

function JingJiMainLayer:initUI()
	-- 通用背景

	local btn_back = self._topbar:getChildByName("topBarBackBtn")
	
	btn_back:setStateNormal("res/image/plugin/competitive_layer/NewAthletics/btn_back.png")
	btn_back:setStateSelected("res/image/plugin/competitive_layer/NewAthletics/btn_back.png")
	btn_back:setTouchBeganCallback(function()
		btn_back:setScale(0.98)
	end)

	btn_back:setTouchMovedCallback(function()
		btn_back:setScale(1)
	end)

	local ceilBg = self._topbar:getChildByName("T_bg")
	ceilBg:setVisible(false)

	local _IngotBg = self._topbar:getChildByName("_IngotBg")
	_IngotBg:setVisible(false)

	local _physicalBg = self._topbar:getChildByName("_physicalBg")
	_physicalBg:setVisible(false)
	
	local _labTimer = self._topbar:getChildByName("_labTimer")
	_labTimer:setVisible(false)

	local _goldBg = self._topbar:getChildByName("_goldBg")
	_goldBg:setPositionX(_goldBg:getPositionX() + 80)

	local _EmeraldBg = self._topbar:getChildByName("_EmeraldBg")
	_EmeraldBg:setPositionX(_EmeraldBg:getPositionX() + 80)

	local titlebg = cc.Sprite:create("res/image/plugin/competitive_layer/NewAthletics/dantiaobg3.png")
	titlebg:setAnchorPoint(1,1)
	self:addChild(titlebg)
	titlebg:setPosition(self:getContentSize().width,self:getContentSize().height + 5)
	
	local title = cc.Sprite:create("res/image/plugin/competitive_layer/NewAthletics/title.png")
	titlebg:addChild(title)
	title:setPosition(titlebg:getContentSize().width*0.5 - 30,titlebg:getContentSize().height*0.5)	

	local nameList1 = {"btn_paiwei_","btn_ziyuan_","btn_xiuluo_","btn_kuafu_"}
	local nameList2 = {"btn_duiwu_","btn_fangshou_","btn_jiangli_","btn_jiangli_"}
	for i = 1, 4 do
		local btn = XTHDPushButton:createWithParams({
            normalFile = "res/image/plugin/competitive_layer/NewAthletics/"..nameList1[i].. 1 ..".png",
            selectedFile = "res/image/plugin/competitive_layer/NewAthletics/".. nameList1[i].. 1 ..".png",
        })
		self:addChild(btn)
		self._btnList[#self._btnList + 1] = btn
		local x = btn:getContentSize().width - 60 + (i - 1)*(btn:getContentSize().width + 50)
		local y = self:getContentSize().height *0.5 - 50
		btn:setPosition(x,y)
		btn:setTouchBeganCallback(function()
			btn:setScale(0.99)
		end)

		btn:setTouchMovedCallback(function()
			btn:setScale(1)
		end)

		btn:setTouchEndedCallback(function()
			btn:setScale(1)
			self:SelectedOtherScene(i)
		end)

		local btn2 = XTHDPushButton:createWithParams({
            normalFile = "res/image/plugin/competitive_layer/NewAthletics/"..nameList2[i].."up.png",
            selectedFile = "res/image/plugin/competitive_layer/NewAthletics/".. nameList2[i].."down.png",
        })
		btn:addChild(btn2)
		x = btn:getContentSize().width *0.5
		y = btn:getContentSize().height * 0.4 - 20
		btn2:setPosition(x,y)
		btn2:setTouchEndedCallback(function()
			self:btnCallFunc(i)
		end)

		if i == 1 then
			self.ladderDefBtn = btn2
			self._ladderBtn = btn
		elseif i == 2 then
			self._robberBtn = btn
		elseif i == 3 then
			self._xiuluoBtn = btn
		end

		if i <= 2 then
			local btn_report = XTHDPushButton:createWithParams({
				normalFile = "res/image/plugin/competitive_layer/NewAthletics/btn_report_up.png",
				selectedFile = "res/image/plugin/competitive_layer/NewAthletics/btn_report_down.png",
			})
			btn:addChild(btn_report)
			btn_report:setPosition(btn:getContentSize().width - btn_report:getContentSize().width + 10,btn:getContentSize().height * 0.3 - 20)
			btn_report:setTouchEndedCallback(function()
				self:BattalReport(i)
			end)
		end
		if i == 4 then
			XTHD.setGray(btn:getStateNormal(),true)
			XTHD.setGray(btn:getStateSelected(),true)
			XTHD.setGray(btn2:getStateNormal(),true)
			XTHD.setGray(btn2:getStateSelected(),true)
		elseif i == 3 then
			if gameUser.getLevel() < 27 then
				XTHD.setGray(btn:getStateNormal(),true)
				XTHD.setGray(btn:getStateSelected(),true)
				XTHD.setGray(btn2:getStateNormal(),true)
				XTHD.setGray(btn2:getStateSelected(),true)
			end
		elseif i == 2 then
			if gameUser.getLevel() < 10 then
				XTHD.setGray(btn:getStateNormal(),true)
				XTHD.setGray(btn:getStateSelected(),true)
				XTHD.setGray(btn2:getStateNormal(),true)
				XTHD.setGray(btn2:getStateSelected(),true)
			end
		end
	end
	
	local fightingbg = cc.Sprite:create("res/image/plugin/competitive_layer/NewAthletics/zhanlibg.png")
	self:addChild(fightingbg)
	fightingbg:setPosition(self:getContentSize().width *0.5,fightingbg:getContentSize().height - 10)

	local power = getCommonYellowBMFontLabel(self:getNuwHeroPower())
	fightingbg:addChild(power)
	power:setPosition(fightingbg:getContentSize().width *0.5 + 30,fightingbg:getContentSize().height *0.5 - 7)
	self._power = power

	local btn_shop = XTHDPushButton:createWithParams({
		normalFile = "res/image/plugin/competitive_layer/NewAthletics/btn_honor_up.png",
		selectedFile = "res/image/plugin/competitive_layer/NewAthletics/btn_honor_down.png",
	})
	self:addChild(btn_shop)
	btn_shop:setPosition(btn_shop:getContentSize().width + 2,self:getContentSize().height - btn_shop:getContentSize().height)
	btn_shop:setTouchEndedCallback(function()
		local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("arena")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
	end)

	local item_bg = cc.Sprite:create("res/image/plugin/competitive_layer/NewAthletics/item_num_bg.png")
	self:addChild(item_bg)
	item_bg:setPosition(item_bg:getContentSize().width + 7,btn_shop:getPositionY() - btn_shop:getContentSize().height *0.5 - item_bg:getContentSize().height *0.5 - 4)

	local item_img = cc.Sprite:create("res/image/common/header_award.png")
	item_bg:addChild(item_img)
	item_img:setScale(0.8)
	item_img:setPosition(item_img:getContentSize().width *0.2,item_bg:getContentSize().height *0.5)

	local item_num = XTHDLabel:create(tostring(gameUser.getAward()),18,"res/fonts/def.ttf")
	item_bg:addChild(item_num)
	item_num:setPosition(item_bg:getContentSize().width *0.5 + 5,item_bg:getContentSize().height *0.5)
	
	-- 保护时间
	local protectSp = XTHD.createLabel({
		text = "",
		fontSize = 18,
		color = XTHD.resource.color.gray_desc,
		anchor = cc.p( 0.5, 0.5 ),
		-- pos = cc.p( robberyDefBtn:getPositionX() - 90, robberyDefBtn:getPositionY() - 45 ),
		pos = cc.p(self._btnList[2]:getContentSize().width *0.5, self._btnList[2]:getContentSize().height/10 - 18 ),
	})
	self._btnList[2]:addChild(protectSp)
	self.protectSp = protectSp

	local nowRank = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt","")
	nowRank:setAnchorPoint(0,0.5)
	nowRank:setScale( 0.6 )
	--nowRank:setPosition(nowRankTitle:getPositionX() + 3, nowRankTitle:getPositionY() - 12 )
	self._btnList[2]:addChild(nowRank)
	self.nowRank = nowRank

	local nowRankSp = XTHD.createRichLabel({
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( 0, self._btnList[2]:getPositionY() - self._btnList[2]:getContentSize().height - 20 ),
	})
	self._btnList[2]:addChild(nowRankSp)
	self.nowRankSp = nowRankSp
	local nowRank = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt","")
	nowRank:setAnchorPoint(0,0.5)
	nowRank:setScale( 0.6 )
	nowRank:setPosition(self._btnList[2]:getPositionX() + 3, self._btnList[2]:getPositionY() - 12 )
	self._btnList[2]:addChild(nowRank)
	self.nowRank = nowRank

end

function JingJiMainLayer:SelectedOtherScene(index)
	if index == 1 then
		self:SelectedRankLayer()
	elseif index == 2 then
		self:LootResuose()
	elseif index == 3 then
		self:Xiuluolianyu()
	else
		XTHDTOAST("该功能暂未开启！")
	end

end

function JingJiMainLayer:btnCallFunc(index)
	if index == 1 then
		self:SettingRank()
	elseif index == 2 then
		self:SettingFangshou()
	elseif index == 3 then
		self:LookGift()
	else
		XTHDTOAST("该功能暂未开启！")
	end
end

function JingJiMainLayer:SettingFangshou()
	self:removePointer()
	if not XTHD.getUnlockStatus( 17, true ) then
		return
	end
	local PVPTeamPop = requires("src/fsgl/layer/JingJi/JingJiTeamPop.lua"):create(self._data.teams,nil,self)
	self:addChild(PVPTeamPop)
	PVPTeamPop:show()
end

function JingJiMainLayer:SettingRank()
	YinDaoMarg:getInstance():guideTouchEnd()
	self:removePointer()
	if not XTHD.getUnlockStatus( 63, true ) then
		return
	end
	local PVPTeamPop = requires("src/fsgl/layer/JingJi/JingJiTeamPop.lua"):create(self._data.orderTeams,2,self)
	self:addChild(PVPTeamPop)
	PVPTeamPop:show()
end

function JingJiMainLayer:LookGift()
	local reward_pop=requires("src/fsgl/layer/XiuLuoLianYu/XiuLuoLianYuRewardLayer.lua"):create(0)
	LayerManager.addLayout(reward_pop, {noHide = true})
end

--点击排位
function JingJiMainLayer:SelectedRankLayer()
	YinDaoMarg:getInstance():guideTouchEnd()
	self:removePointer(true)
	if not XTHD.getUnlockStatus(63, true) then
		return
	end
	XTHDHttp:requestAsyncInGameWithParams( {
		modules = "orderListRequest?",
		successCallback = function(data)
			if tonumber(data.result) == 0 then
				local PVPLadderLayer = requires("src/fsgl/layer/JingJi/JingJiLadderLayer.lua"):create(data, self._data.orderTeams,self)
				PVPMAINLAYER_TEMP = self
				LayerManager.addLayout(PVPLadderLayer, { par = self })
			elseif tonumber(data.result) == 2000 then
				XTHD.createExchangePop(3)
			elseif tonumber(data.result) == 2002 then
				XTHD.createExchangePop(1)
			elseif tonumber(data.result) == 2007 then
				XTHDTOAST(LANGUAGE_TIPS_WORDS20)
			else
				XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
			end
		end,
		failedCallback = function()
			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
		end,
		targetNeedsToRetain = self,
		loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
	} )
end

-- 点击抢夺资源
function JingJiMainLayer:LootResuose()
	YinDaoMarg:getInstance():guideTouchEnd()
	self:removePointer(true)
	if not XTHD.getUnlockStatus(17, true) then
		return
	end
	XTHDHttp:requestAsyncInGameWithParams( {
		modules = "strongRequest?",
		successCallback = function(data)
			if tonumber(data.result) == 0 then
				data.robberyTime = self._data.lootLeftCount
				self:doCountDown(0)
				if data.rivals and #data.rivals > 0 then
					local PVPRobberyLayer = requires("src/fsgl/layer/JingJi/JingJiRobberyLayer.lua"):create(data)
					LayerManager.addLayout(PVPRobberyLayer, { par = self })
				end
			elseif tonumber(data.result) == 2000 then
				XTHD.createExchangePop(3)
			elseif tonumber(data.result) == 2002 then
				XTHD.createExchangePop(1)
			elseif tonumber(data.result) == 2007 then
				XTHDTOAST(LANGUAGE_TIPS_WORDS20)
			else
				XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
			end
		end,
		failedCallback = function()
			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
		end,
		targetNeedsToRetain = self,
		loadingType = HTTP_LOADING_TYPE.CIRCLE,
	} )
end

--修罗炼狱
function JingJiMainLayer:Xiuluolianyu()
	YinDaoMarg:getInstance():guideTouchEnd()
	XTHD.createXiuLuo(self)
end

function JingJiMainLayer:BattalReport(index)
	if index == 1 then
		XTHDHttp:requestAsyncInGameWithParams({
            modules="orderFightRecord?",
            successCallback = function(data)
                if tonumber(data.result) == 0 then
                    local PVPRepLayer = requires("src/fsgl/layer/JingJi/JingJiRepLayer.lua"):create(data)
                    self:addChild(PVPRepLayer)
                    PVPRepLayer:show()
                end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                -- self:removeFromParent()
                LayerManager.removeLayout(self)
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
	else 
		XTHD.createBattleReport(self)
	end
end

function JingJiMainLayer:refreshLayer(data)
	if not self._exist then
		return
	end
	self._data = data

	if not self.noTime then
		self.noTime = XTHD.createLabel({
			text = LANGUAGE_UNKNOWN.none,
			fontSize = 18,
			color = cc.c3b(205, 25, 25),
		})
		self.noTime:setAnchorPoint(0,0.5)
		self.noTime:setPosition(self.protectSp:getPositionX()+self.protectSp:getBoundingBox().width ,self.protectSp:getPositionY())
		self._btnList[2]:addChild(self.noTime)
	end

	if not self.cdTime then
		self.cdTime = XTHD.createLabel({
			text = getCdStringWithNumber(self._data.guardTime,{h = ":"}),
			fontSize = 18,
			color = cc.c3b( 205, 101, 8 ),
		})
		self.cdTime:setAnchorPoint(0,0.5)
		self.cdTime:setPosition(self.protectSp:getPositionX()+self.protectSp:getBoundingBox().width+5,self.protectSp:getPositionY())
		self._btnList[2]:addChild(self.cdTime)
	end
	self:doCountDown(self._data.guardTime)

	-- self.nowRankSp
	self.nowRank:setString(self._data.myRank)
	self.nowRankSp:setPositionX( self.nowRank:getPositionX() - self.nowRank:getBoundingBox().width - 5 )

	--self.robberyTimeLabel:setString(self._data.lootLeftCount)
	--self:startRobberRecover(data)
end

function JingJiMainLayer:doCountDown( sTime )
	--LANGUAGE_UNKNOWN
	self._globalScheduler:removeCallback("ROBBERY_TIME")
	local _time = tonumber(sTime) or 0
	if _time <= 0 then
		self.cdTime.cd = 0
		self.cdTime:setString("")
		self.noTime:setVisible(false)
		return
	end
	self.noTime:setVisible(false)
	local function _freshTime( time )
		self.cdTime:setString(getCdStringWithNumber(time, {h = ":"}))
        self.cdTime.cd = time
	end
	_freshTime(_time)
	self._globalScheduler:addCallback("ROBBERY_TIME", {
		cdTime = _time,
		endCall = function ()
			self._globalScheduler:removeCallback("ROBBERY_TIME")
            self.cdTime:setString("")
            self.noTime:setVisible(true)
		end,
		perCall = _freshTime
	})
end


function JingJiMainLayer:create(data,extra,callback)
	return JingJiMainLayer.new(data,extra,callback)
end

function JingJiMainLayer:onEnter( )
    	--战斗结果页监听
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
	XTHD.addEventListener({name = "GOLD_COPY_GET_GOLD_NUM1" ,callback = function(event)
        local data = event["data"]
	    local PVPRobberyLayer = requires("src/fsgl/layer/JingJi/JingJiRobberyLayer.lua"):create(data)
		LayerManager.addLayout(PVPRobberyLayer, {par = self})
    end})
    self:addGuide()
end

function JingJiMainLayer:onExit( ... )
	XTHD.removeEventListener("GOLD_COPY_GET_GOLD_NUM1")
	self:removePointer()
end

function JingJiMainLayer:removePointer(needClean)
	if self._pointer then 
		self._pointer:removeFromParent()
		self._pointer = nil
		if needClean == true then 
			self._needPointTo = nil
		end 
	end 
end

function JingJiMainLayer:startRobberRecover(data)
	if self._robberRecover and data then 
		-- local _restTimes = tonumber(data.lootLeftCount)
		local _recoverTime = tonumber(data.lootCoolTime)
		if _recoverTime > 0 then --_restTimes <= 0 and 
			self._robberRecover:setVisible(true)
            self.noTime:setVisible(false)
			local format = LANGUAGE_FORMAT_TIPS9-------"%s分%s秒后回复一次抢夺次数"
			local str = LANGUAGE_FORMAT_TIPS9(math.floor(_recoverTime / 60),_recoverTime % 60)
			self._robberRecover:setString(str)

			local function countDown( )
				_recoverTime = _recoverTime - 1
				if _recoverTime <= 0 then 
					self:stopActionByTag(self.Tag.ktag_robberRecoverTag)
					-- self.guide_robberyBtn:setVisible(true)
					self._robberRecover:setVisible(false)
					ClientHttp:requestAsyncInGameWithParams({
				        modules = "arenaTeams?",
				        params = {},
				        successCallback = function(net_data)
				            if tonumber(net_data.result) == 0 then
				            	self:refreshLayer(net_data)
				            else
				                XTHDTOAST(net_data.msg or LANGUAGE_TIPS_WEBERROR)----- "网络请求失败")
				            end
				        end,--成功回调
				        failedCallback = function()
				            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
				        end,--失败回调
				        targetNeedsToRetain = self,--需要保存引用的目标
				        loadingParent = self,
				        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
				    })
				end 
				local minute = math.floor(_recoverTime / 60)
				local second = _recoverTime % 60
				local str = LANGUAGE_FORMAT_TIPS9(minute,second)
				self._robberRecover:setString(str)
			end
			if not self:getActionByTag(self.Tag.ktag_robberRecoverTag) then 
				schedule(self,countDown,1.0,self.Tag.ktag_robberRecoverTag)
			end 
		else 
			-- self.guide_robberyBtn:setVisible(true)
			self._robberRecover:setVisible(false)
		end 
	end 
end

--获取当前战斗力
function JingJiMainLayer:getNuwHeroPower()
	local power = 0
	for i = 1,#self._data.orderTeams do
		local hero = DBTableHero.getHeroData(self._data.orderTeams[i])
		power = power + hero.power
	end
	return power
end

function JingJiMainLayer:refreshPower()
	self._power:setString(self:getNuwHeroPower())
end


function JingJiMainLayer:addStoryToNewRobber( )------添加新功能开启抢夺的引导 
	local function nextCall( )
    	self._pointer = Guide:addAHandToTarget( self.robberyDefBtn )		
	end
	layer = StoryLayer:createWithParams({storyId = 20001,callback = nextCall,auto = false})
	self:addChild(layer,10)	
end

function JingJiMainLayer:addHandToRobberBtn( )
	if self._needPointTo == 17 then ---抢夺
    	self._pointer = Guide:addAHandToTarget( self.guide_robberyBtn )			
    end 
end

function JingJiMainLayer:addGuide( )
    YinDaoMarg:getInstance():addGuide({index = 3,parent = self},9)
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self.ladderDefBtn,-----排位赛设置防守队伍
        index = 6,
        needNext = false
    },11)
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._ladderBtn,-----点击排位
        index = 9,
        needNext = false
    },11)
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._robberBtn,-----点击资源
        index = 4,
        needNext = false
    },9)
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._xiuluoBtn,
        index = 3,
        needNext = false
    },20)
    YinDaoMarg:getInstance():doNextGuide()
end

return JingJiMainLayer