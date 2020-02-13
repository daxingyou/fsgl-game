gameUser = {}
--[[
以下数据会在文件被重新加载后初始化(注:重新加载发生在手动将该文件从程序中卸载掉)
一般在异步更新之后会执行该操作
此处有2种设计方案：
1).添加一个方法，初始化gameUser
2).就是以下这种写法
]]
gameUser._today 			 = nil -------用于判定次日刷新()
gameUser._userId			 = 0
gameUser._level 			 = 0
gameUser._preLevel 			 = 0 -----

gameUser._passportID 		 = 0 ----获取新token用

gameUser._gold  			 = 0 	--[[银两]]
gameUser._ingot   			 = 0 	--[[元宝]]
gameUser._feicui   			 = 0    ----翡翠
gameUser._currTili   		 = 0 	--体力
gameUser._guildPoint 		 = 0 ----帮派贡献点
gameUser._awardPoint 		 = 0    --奖牌
gameUser._flower			 = 0

gameUser._preGold  			 = 0 	--[[最近一次更改前的银两]]
gameUser._preIngot   		 = 0 	--[[最近一次更改前的元宝]]
gameUser._preFeicui   		 = 0    ----最近一次更改前的翡翠
gameUser._preCurrTili   	 = 0 	--最近一次更改前的体力
gameUser._vowPoint 			 = 0 -----许愿点
gameUser._soul               = 0 --魂玉

gameUser._energy 			 = 0 	--精力（竞技场）
gameUser._energyCD 			 = 0  	----下次精力恢复的时间
gameUser._vip   			 = 0
gameUser._curexp   			 = 0
gameUser._maxexp   			 = 0
gameUser._totalingot   		 = 0 	--[[累计充值元宝]]
gameUser._instancingid   	 = 0 	--[[已经完成的最大普通关卡id]]
gameUser._fightBlockID   	 = 0 	--[[玩家正在打的关卡]]
gameUser._elitefightBlockID  = 1    --[[玩家正在打的精英]]
gameUser._isBlockWin		 = 0 ---玩家正在打的关卡是否赢了，0为输，1为赢，-1为还未打
gameUser._storyDisplayedID	 = 0 ----记录当前已弹过剧情的关卡
gameUser._vipRewardStatu 	 = 0 -----vip奖励领取状态

gameUser._eliteinstancingid  = 0 	--[[已经完成的最大精英副本id]]
gameUser._diffcultyInstancingId = 0 --[[已经完成的最大噩梦副本id]]
gameUser._batteleinstancingid= 0    --[[战斗关卡id]]
gameUser._lastUUID   		 = 0
gameUser._buyTiliCount		 = 0 	--[[体力够买次数]]
gameUser._honor 			 = 0 	----荣誉
gameUser._maxTili   		 = 0
gameUser._tiliCD			 = 0  	--下次体力恢复的时间
gameUser._uuid 		   		 = 0
gameUser._socketIP 	   		 = ""
gameUser._socketPort   		 = 0
gameUser._socketLoginTime 	 = 0
gameUser._isInGame			 = false ---玩家是否进入游戏

gameUser._luckyMoney 		 = 0 -------幸运币
gameUser._currSkillPoint	 = 0 	--[[技能点]]
gameUser._buySkillPointCount = 0
gameUser._lastbuySkillPointCount = 0--剩余技能点购买次数
gameUser._maxSkillPoint 	 = 0 	--最大技能点
gameUser._maxBuySkillPointCount = 0 --技能点最大购买次数

gameUser._campID			 = 0 	--种族ID 1是仙族，2是魔族
gameUser._token			 	 = "" 
gameUser._newLoginToken		 = "" 	---newlogin?接口需要用到的token
gameUser._loginServerTime 	 = 0   	----服务器登录时间
gameUser._emailAmount		 = 0 	----邮件数量
gameUser._taskGetState		 = 0 	----任务的可领取状态 
gameUser._baodianGetState    = 0 --宝典红点状态，0代表不显示，1代表显示
gameUser._loginLevelRewardState		 = 0 	----活动里的累计登陆和奖励是否为可领状态
gameUser._goldSurplusExchangeCount = 0 		-- 银两剩余兑换次数
gameUser._feicuiSurplusExchangeCount = 0 	-- 翡翠剩余兑换次数

gameUser._recruitStateTools       = 0  ------标识抽装备有免费
gameUser._recruitStateHero       = 0  ------标识抽英雄有免费
gameUser._templateVIPCD			 = 0 -----临时VIP剩余时间
gameUser._openServerPackage 	 = 0 -----开服礼包 1为已领取，0 未领取
gameUser._canBigPackageGet 		 = 0 -------是否有开服礼包可领取,1有可领取的，0没有
gameUser._limitBattle 			 = {} -----当前已开启的限时战（-(1:boss; 2: 帮派战;3 : 修罗战场 4：种族战),）
gameUser._currentBattle 		 = 0 ----当上述四个战都开启的时候，记录谁在最前面

gameUser._baseContent 		 = {}
gameUser._baseContent._duanid = 1  	---竞技场段ID
gameUser._baseContent._duanRank = 0 ---单单的竞技场排名，非领袖、武圣
gameUser._baseContent._shengwang = 0
gameUser._baseContent._prestige = 0

gameUser._nick_name			= ""
gameUser._guide 			= nil 	----始终存储下步需要引导的步数，index下一步需要引导的索引，id为下一步需要的引导id{index = 1,id = 1},如果为数字，1 为开场战斗 ，2为黑屏说话 
gameUser._bounty = 0 -------赏金
gameUser._sex = 1

gameUser._recruitExchangeSum = 0  	--[[可兑换英雄魂石次数  2015.05.22 hezhitao]]
gameUser._recruitExchangeEquipSum = 0 --[[可兑换装备次数  2015.07.21 hezhitao]]
gameUser._serverId = 0 --当前所在服务器id
gameUser._serverName=""--当前服务器名字
gameUser._version  = "1.0.0"  --当前版本号

gameUser._onlineTime = 0 			--在线时间，以分钟为单位
gameUser._expItemSurplusSum = {} 	--经验物品的购买次数
gameUser._godItemSurplusSum = {}    --神器进价石购买次数
gameUser._changeNameCount   = 1

gameUser._normalcopiesData={}
gameUser._elitecopiesData={}
gameUser._diffcultycopiesData={} --恶魔副本关卡信息
gameUser._copiesReward={}
gameUser._elitecopiesReward={}
gameUser._diffcultycopiesReward={} --恶魔副本星级奖励信息
gameUser._refresh_state=false
gameUser._timeVipCd = 0
gameUser._vipBattleSpeedLimit = 8--[[--战斗的3倍加速vip等级限制]]
gameUser._guildId = 0--[[--公会ID]]
gameUser._guildName = ""--[[--公会名字]]
gameUser._guildRole = 0--[[--公会中职级]]

gameUser._worldBossOver = 0    ---世界boss结束弹窗状态
gameUser._worldBossOver_data={} 
gameUser._activitysStatu = {} ------{每日签到，连续登陆，在线奖励，冲级奖励，累计充值，连续充值，排行奖励，vip工资,单笔充值,军需物资，老虎机，金币翡翠老虎机，投资计划，特权礼包，至尊转盘 }

gameUser._loginRewardState = 0 			--loginTask是否开启

gameUser._sevenDayRedPoint = 0 --7天活动红点
gameUser._packageRedPoint = 0 --背包物品中，effecttype为1,2,3,6,8，10的给背包加红点
gameUser._artifactRedPoint = 0 --神器红点

gameUser._recoveryState = 0			--是否有资源找回
gameUser._gragraduationState = 0	--是否有毕业典礼
gameUser._luckyTurnState = 0        --是否有幸运转盘
gameUser._lastServerId = 0   --上次登录服务器ID,为0则说明没登过服务器
gameUser._limitTimeShopState = 0  --限时商城开启状态
gameUser._curWorpship = 0   --剩余膜拜次数
gameUser._normalChallenge = 0  --单挑之王普通副本的挑战进度
gameUser._diffChallenge = 0  --单挑之王困难副本的挑战进度
gameUser._nightChallenge = 0 --单挑之王噩梦副本的挑战进度
gameUser._purChallenge = 0  --单挑之王炼狱副本的挑战进度
gameUser._servant = 0  --新的货币万灵魂
gameUser._taoFaLingSum = 0 --讨伐令的剩余购买次数
gameUser._battleSpeed = 1  --战斗的加速速率
gameUser._leijidengluState = 0 --累计登录开启状态 
gameUser._threeTimePayId = 1 --未完成的三次首充的状态
gameUser._threeTimePayList = {} --当前未领取的三次首冲奖励id列表
gameUser._firstLayerState = 0	--首冲界面是否弹出的状态
gameUser._finishThreePayRewardList = {} --单签已领取的奖励列表
gameUser._growthFund = 0	--成长基金是否开启状态
gameUser._monthState = 0	--至尊卡月卡打脸页状态
gameUser._meiRiQianDaoState = 0  --每日签到打脸页状态
gameUser._curTitleId = 0	--当前佩戴的称号
gameUser._Titlelist = {}	--当前已拥有称号

gameUser._rchdStateTabel = {        --日常活动红点状态表
    -- 登录有礼
        [1] = {
            urlId      = 18,
        },
        -- 充值返利
        [2] = {
            urlId      = 12,
        },
        -- 消费返利
        [3] = {
            urlId      = 13,
        },
        -- 开采返利
        [4] = {
            urlId      = 14,
        },
        -- 招募返利
        [5] = {
            urlId      = 15,
        },
        -- 神兵返利
        [6] = {
            urlId      = 16,
        },
        -- 神器返利
        [7] = {
            urlId      = 17,
        },
}       

gameUser.luckyListData = {}  --幸运转盘幸运榜数据


gameUser._skillPointTimeTable = {
	skillPointDot = 0, 				--技能点倒计时剩余秒数。
	loginOstime = 0 				--登录时的时间
}
gameUser._vipRechargeTime = {  --vip充值界面，月卡、至尊卡的倒计时
	monthCard = 0,
	zhizunCard = 0,
}

gameUser._firstPayState = 0 -- 首充，0：不能领取，1：能领取，2：已经领取
gameUser._zhenqi = 0 			--真气

--[[
	1 	老虎机-元宝
	2 	老虎机-银两翡翠
	3 	七日狂欢
	4 	单笔充值
	5 	神灯精灵
	6 	至尊转盘
	7 	春节活动-击退年兽
	8 	春节活动-抽奖
	9 	春节活动-累计充值
	10 	累计充值
	11 	限时英雄
	12  充值返利
	13  消费返利
	14  切石返利
	15  群英返利
	16  神兵返利
	17  神器返利
	18  登录有礼
	19  限时礼包
]]
gameUser._activityOpenStatus = {}

gameUser._zhongjiangInfo = {} --恭喜发财中奖信息

gameUser._shengjiZhuanpanCount = 0 --升级转盘摇奖次数

gameUser._roleCreateTime = 0

gameUser._syLoginData = {}

gameUser._syUserID = ""

function gameUser.getBattleSpeed()
	if gameUser._battleSpeed == 1 then
		return BATTLE_SPEED.X1
	elseif gameUser._battleSpeed == 2 then
		return BATTLE_SPEED.X2
	elseif gameUser._battleSpeed == 3 then
		return BATTLE_SPEED.X3
	else
		return BATTLE_SPEED.X1
	end
end

function gameUser.setBattleSpeed(val)
	if val then
		gameUser._battleSpeed = val
	end
end

function gameUser.getSYUserID()
	return gameUser._syUserID
end

function gameUser.setSYUserID(val)
	if val then
		gameUser._syUserID = val
	end
end

function gameUser.getSYLoginData()
	return gameUser._syLoginData
end

function gameUser.setSYLoginData(val)
	if val then
		gameUser._syLoginData = val
	end
end

function gameUser.getRoleCreateTime()
	return gameUser._roleCreateTime
end

function gameUser.setRoleCreateTime(stamp)
	gameUser._roleCreateTime = stamp/1000
end

function gameUser.gettaoFaLingSum()
    return gameUser._taoFaLingSum
end

function gameUser.settaoFaLingSum(val)
    if val then
		gameUser._taoFaLingSum = val	
	end
end

function gameUser.getServant()
	return gameUser._servant
end

function gameUser.setServant(val)
    if val then
        gameUser._servant = val
    end
end

function gameUser.getNormalChalenge()
	return gameUser._normalChallenge
end

function gameUser.setNormalChallenge(val)
	if val then
        gameUser._normalChallenge = val
	end
end

function gameUser.getDiffChalenge()
	return gameUser._diffChallenge
end

function gameUser.setDiffChallenge(val)
	if val then
        gameUser._diffChallenge = val
	end
end

function gameUser.getNightChalenge()
	return gameUser._nightChallenge
end

function gameUser.setNightChallenge(val)
	if val then
        gameUser._nightChallenge = val
	end
end

function gameUser.getPurChalenge()
	return gameUser._purChallenge
end

function gameUser.setPurChallenge(val)
	if val then
        gameUser._purChallenge = val
	end
end

function gameUser.getCurWorpShip()
    return gameUser._curWorpship
end

function gameUser.setCurWorpShip(val)
	if val then
        gameUser._curWorpship = val
	end
end

function gameUser.getLuckyListData()
	return gameUser.luckyListData
end

function gameUser.setLuckyListData(data)
	if data then
        gameUser.luckyListData = data
	end
end

function gameUser.addLuckyListData(data)
    if data then 
		table.insert(gameUser.luckyListData,data)
		if #gameUser.luckyListData > 20 then 
			table.remove(gameUser.luckyListData)
		end 
	end 
end

function gameUser.clearLuckyListData()
	gameUser.luckyListData = {}
end

function gameUser.setZhuanpanCount(_count)
	gameUser._shengjiZhuanpanCount = tonumber(_count) or 0
end
function gameUser.getZhuanpanCount()
	return gameUser._shengjiZhuanpanCount
end

function gameUser.getLastServerId()
	return gameUser._lastServerId
end

function gameUser.setLastaServerId(id)
	gameUser._lastServerId = id
end

function gameUser.getZhongjiangInfo()
	return gameUser._zhongjiangInfo
end
function gameUser.setZhongjiangInfo(_tab)
	local nums = #gameUser._zhongjiangInfo
	if nums >= 20 then
		local _infoTab = {}
		for i = 1, 19 do
			_infoTab[i] = gameUser._zhongjiangInfo[i+1]
		end
		_infoTab[#_infoTab] = _tab
		gameUser._zhongjiangInfo = nil
		gameUser._zhongjiangInfo = _infoTab
	else
		gameUser._zhongjiangInfo[#gameUser._zhongjiangInfo+1] = _tab
	end
end

function gameUser.getZhenqi( )
	return gameUser._zhenqi or 0
end

function gameUser.setZhenqi( val )
	gameUser._zhenqi = val
end

function gameUser.setSkillPointTimeTable( _skillPointDot,_loginOstime )
	gameUser._skillPointTimeTable.skillPointDot = _skillPointDot
	gameUser._skillPointTimeTable.loginOstime = _loginOstime
end

-- 获取精彩活动红点显示
function gameUser.getWonderfulPointDot()
	if gameUser._activitysStatu[5] == 1 or gameUser._activitysStatu[6] == 1 or gameUser._activitysStatu[8] == 1  or gameUser._activitysStatu[16] == 1
	  or gameUser._activitysStatu[14] == 1 or gameUser._activitysStatu[15] == 1 then
		return 1
	end
	return 0
end

-- 获取每日福利红点显示
function gameUser.getDailyPointDot()
	if gameUser._activitysStatu[1] == 1 or gameUser._activitysStatu[2] == 1 or gameUser._activitysStatu[3] == 1  or gameUser._activitysStatu[4] == 1
		or gameUser._activitysStatu[10] == 1 or gameUser._activitysStatu[11] == 1 or gameUser._activitysStatu[12] == 1 then
		return 1
	end
	return 0
end

--获取新累计登录红点显示
function gameUser.getNewLoginRewardDot()
	if gameUser._activitysStatu[17] == 1 then
		return 1
	end
	return 0
end

--获取单笔充值红点显示
function gameUser.getSingleRechargeDot()
	if gameUser._activitysStatu[9] == 1 then
		return 1
	end
	return 0
end

--获取在线奖励红点显示
function gameUser.getOnlineRewardDot()
	if gameUser._activitysStatu[3] == 1 then
		return 1
	end
	return 0
end

--获取累计充值红点显示
-- function gameUser.getTotalRechargeDot()
-- 	if gameUser._activitysStatu[5] == 1 then
-- 		return 1
-- 	end
-- 	return 0
-- end

--资源找回开启状态，0关闭，1开启
function gameUser.setRecoveryState(val)
	gameUser._recoveryState = val
end

function gameUser.getRecoveryState()
	return gameUser._recoveryState
end

--毕业典礼开启状态，0关闭，1开启
function gameUser.setGragraduationState(val)
	gameUser._gragraduationState = val
end

function gameUser.getGragraduationState()
	return gameUser._gragraduationState
end

--幸运转盘开启状态，0关闭，1开启
function gameUser.setLuckyTurnState(val)
	gameUser._luckyTurnState = val
end

function gameUser.getLuckyTurnState()
	return gameUser._luckyTurnState
end

function gameUser.setLimitTimeShopState(val)
	gameUser._limitTimeShopState = val
end

function gameUser.getLimitTimeShopState()
	return gameUser._limitTimeShopState
end

--累计登录开启状态
function gameUser.setLeijidengluState(val)
	gameUser._leijidengluState = val
end

function gameUser.getLeijidengluState()
	return gameUser._leijidengluState
end

--三次首冲状态
function gameUser.setThreeTimePayId(val)
	gameUser._threeTimePayId = val
end

function gameUser.getThreeTimePayId()
	return gameUser._threeTimePayId
end

--三次首冲领取状态
function gameUser.setThreeTimePayList(list)
	gameUser._threeTimePayList = list
end

function gameUser.getThreeTimePayList()
	return gameUser._threeTimePayList
end

function gameUser.setFirstLayerState(val)
	gameUser._firstLayerState = val
end

function gameUser.getFirstLayerState()
	return gameUser._firstLayerState
end

function gameUser.setFinishThreePayRewardList(list)
	gameUser._finishThreePayRewardList = list
end

function gameUser.getFinishThreePayRewardList()
	return gameUser._finishThreePayRewardList
end

--成长基金按钮是否显示状态
function gameUser.setGrowthFund(val)
	gameUser._growthFund = val
end

function gameUser.getGrowthFund()
	return gameUser._growthFund
end

function gameUser.setMonthState(val)
	gameUser._monthState = val
end

function gameUser.getMonthState()
	return gameUser._monthState
end

function gameUser.setMeiRiQianDaoState(val)
	if val then
		gameUser._meiRiQianDaoState = val
	end
end

function gameUser.getMeiRiQianDaoState()
	return gameUser._meiRiQianDaoState
end

function gameUser.setCurTitle(id)
	gameUser._curTitleId = id
end

function gameUser.getCurTitle()
	return gameUser._curTitleId
end

function gameUser.setCurTitleList(list)
	gameUser._Titlelist = list or {}
end

function gameUser.getCurTitleList()
	return gameUser._Titlelist
end

--刷新毕业典礼小红点
function gameUser.getBYDLRedState()
	RedPointState[9].state = 0
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "bydl"}})
    HttpRequestWithOutParams("gragraduationRewardList",function (data)
         for i = 1,#data.list do
            if data.list[i].state == 1 then
            	 RedPointState[9].state = 1
                 XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "bydl"}})
                 break
            end
        end
    end)
    if gameUser.getGragraduationState() == 0 then  --奖励全部领完
    	RedPointState[9].state = 0
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "bydl"}})
    end
end

--刷新演武场的小红点
function gameUser.getYWCRedState()
	if gameUser.getLevel() < 18 then return end
	HttpRequestWithOutParams("openCutJade",function (data)
         RedPointState[16].state = data.surplusFreeBuyCount > 0 and 1 or 0
         -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "ywc"}})
    end) 
end

function gameUser.getSkillPointDot( )
	return gameUser._skillPointTimeTable.skillPointDot or 0
end

function gameUser.getLoginOstime( )
	return gameUser._skillPointTimeTable.loginOstime or 0
end

function gameUser.setGuildPoint( val )
	gameUser._guildPoint = val
end

function gameUser.getGuildPoint( )
	return gameUser._guildPoint
end

function gameUser.setActivityLoginRewardState(val)
	gameUser._loginRewardState = val
end

function gameUser.getActivityLoginRewardState( )
	return gameUser._loginRewardState
end

function gameUser.setVowPoint(val)
	gameUser._vowPoint = val
end

function gameUser.getVowPoint( )
	return gameUser._vowPoint
end

function gameUser.setLimitBattle(_type,val)
	if not _type or _type == 0 then 
		gameUser._limitBattle = {}
	else 
		gameUser._limitBattle[_type] = val
	end 
end

function gameUser.getLimitBattle(_type)
	if _type then 
		return gameUser._limitBattle[_type]
	else 
		return gameUser._limitBattle
	end 
end

function gameUser.setActivityStatus( statu )
	gameUser._activitysStatu = statu
end

function gameUser.setActivityStatusById( id, statu )
	gameUser._activitysStatu[id] = statu
end

function gameUser.getActivibyStatus( )
	return gameUser._activitysStatu
end
function gameUser.setVipBattleSpeedLimit( value )
	gameUser._vipBattleSpeedLimit = value
end

function gameUser.getVipBattleSpeedLimit()
	return gameUser._vipBattleSpeedLimit
end

function gameUser.setBounty( value )
	local v = tonumber(value) or 0
	gameUser._bounty = v
end

function gameUser.getBounty( )
	return gameUser._bounty
end

function gameUser.setBigPackageGetting( statu )
	gameUser._canBigPackageGet = statu
end

function gameUser.getBigPackageGetting( )
	return gameUser._canBigPackageGet
end

function gameUser.setOSPackageTimes( times )
	gameUser._openServerPackage = times
end

function gameUser.getOSPackageTimes( )
	return gameUser._openServerPackage
end

function gameUser.setTemplateVIPCD(cd)
	gameUser._templateVIPCD = cd
end

function gameUser.getTemplateVIPCD( )
	return gameUser._templateVIPCD	
end

function gameUser.getPassportID( )
	return gameUser._passportID
end

function gameUser.isPlayerInGame()
	return gameUser._isInGame
end

function gameUser.hasVipReward( )
	return gameUser._vipRewardStatu == 1
end

function gameUser.setNameCount(num)
	gameUser._changeNameCount=num
end
function gameUser.getNameCount()
	return gameUser._changeNameCount
end

function gameUser.getRefreshState(  )
	return gameUser._refresh_state
end
function gameUser.setRefreshState( state )
	gameUser._refresh_state=state
end

function gameUser.getNowinstancingid(  )
	return gameUser._batteleinstancingid
end
function gameUser.setNowinstancingid(id )
	gameUser._batteleinstancingid=tonumber(id)
end

function gameUser.setNormalCopiesData ( data )
	if data then
		gameUser._normalcopiesData=data
	end
end
function gameUser.GetNormalCopiesData (  )
	return gameUser._normalcopiesData
end
function gameUser.setEliteCopiesData ( data )
	if data then
		gameUser._elitecopiesData=data 

	end
end
function gameUser.GetEliteCopiesData (  )
	return gameUser._elitecopiesData
end
function gameUser.setDiffcultyCopiesData ( data )
	if data then
		gameUser._diffcultycopiesData=data
	end
end
function gameUser.getDiffcultyCopiesData (  )
	return gameUser._diffcultycopiesData
end
function gameUser.setCopiesReward ( data )
	if data then
		gameUser._copiesReward=data 
	end
end
function gameUser.getCopiesReward (  )
	return gameUser._copiesReward
end
function gameUser.setEliteCopiesReward ( data )
	if data then
		gameUser._elitecopiesReward=data 
	end
end
function gameUser.getEliteCopiesReward (  )
	return gameUser._elitecopiesReward
end
function gameUser.setDiffcultyCopiesReward ( data )
	if data then
		gameUser._diffcultycopiesReward=data 

	end
end
function gameUser.getDiffcultyCopiesReward (  )
	return gameUser._diffcultycopiesReward
end

--引导不需要给默认值
function gameUser.setGuideID( data )	
	if data == "" then 
		gameUser._guide = {index = 1,id = 0} 
	else 
		gameUser._guide = data
	end 
end
function gameUser.getGuideID( )
	return gameUser._guide
end

function gameUser.setFeicui(feicui)
	if feicui == nil then
		feicui = 0
	end
	gameUser._preFeicui = gameUser._feicui
	gameUser._feicui = tonumber(feicui) or 0

	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "build"}})
end
function gameUser.getFeicui()
	return tonumber(gameUser._feicui)
end

function gameUser.getPreFeicui( )
	return gameUser._preFeicui
end
function gameUser.setPreFeicui( value )
	gameUser._preFeicui = tonumber(value) or 0
end

function gameUser.getTiliNow()
	return tonumber(gameUser._currTili)
end
function gameUser.setTiliNow(tili)
	if tili == nil then
		tili = 0
	end
	gameUser._preCurrTili = gameUser._currTili
	gameUser._currTili = tonumber(tili) or 0
end

function gameUser.getPreTiliNow( )
	return gameUser._preCurrTili
end
function gameUser.setPreTiliNow( value )
	gameUser._preCurrTili = tonumber(value) or 0
end

function gameUser.getGold()
	return tonumber(gameUser._gold)
end
function gameUser.setGold(gold)
	if gold == nil then
		gold = 0
	end
	gameUser._preGold = gameUser._gold
	gameUser._gold = tonumber(gold) or 0

	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "build"}})
end

function gameUser.setFlower(flower)
	gameUser._flower = flower
end

function gameUser.getFlower(flower)
	return gameUser._flower
end

function gameUser.getPreGold( )
	return gameUser._preGold
end
function gameUser.setPreGold(gold)
	gameUser._preGold = tonumber(gold) or 0
end

--[[获取当前元宝]]
function gameUser.getIngot()
	return tonumber(gameUser._ingot)
end
function gameUser.setIngot(ingot)
	if ingot == nil then
		ingot = 0
	end
	gameUser._preIngot = gameUser._ingot
	gameUser._ingot = tonumber(ingot) or 0
end

function gameUser.getPreIngot( )
	return gameUser._preIngot
end
function gameUser.setPreIngot( ingot )
	gameUser._preIngot = tonumber(ingot) or 0 
end


function gameUser.setToday( _today )
	gameUser._today = _today
end
function gameUser.getToday( )
	return gameUser._today
end

function gameUser.setLoginServerTime( time )
	if time == nil then
		time = 0
	end
	gameUser._loginServerTime = time
end
function gameUser.getLoginServerTime( )
	return gameUser._loginServerTime
end

function gameUser.getSocketLoginTime( )
	return gameUser._socketLoginTime
end

function gameUser.setLoginRewardState( value )
	if value == nil then
		value = 0
	end
	gameUser._loginLevelRewardState = value
end

function gameUser.getLoginRewardState( )
	return gameUser._loginLevelRewardState
end

function gameUser.getEmailAmount( )
	return gameUser._emailAmount
end

function gameUser.setEmailAmount( data )
	if data == nil then
		data =0
	end
	gameUser._emailAmount = data
end

function gameUser.getTaskGettingState( )
	return gameUser._taskGetState
end

function gameUser.setTaskGettinState(value)
	if value == nil then
		value = 0
	end
	gameUser._taskGetState = value
end

function gameUser.getbaodianGettingState( )
	return gameUser._baodianGetState
end

function gameUser.setbaodianGettinState(value)
	-- if value == nil then
	-- 	value = 0
	-- end
	gameUser._baodianGetState = value

	if tonumber(value) <= 0 then
    	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "baodian",["visible"] = 0}})
    else
    	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "baodian",["visible"] = 1}})
    end
end

function gameUser.getBaseContent()
	return gameUser._baseContent
end

function gameUser.setLevel(level)
	if level == nil then
		level = 0
	end
	ISLEVELUP = ISLEVELUP + 1
	gameUser._preLevel = gameUser._level
	gameUser._level = level
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "build"}})
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCTION_BTNSHOW})

	--小于40级(每升级5级获得一次转盘机会)
	if tonumber(gameUser._preLevel) < 40 and tonumber(gameUser._preLevel) > 0 then
		local _level1 = math.fmod(gameUser._preLevel, 5)
		local addLevel = tonumber(gameUser._level) - tonumber(gameUser._preLevel) + tonumber(_level1)
		if addLevel >= 5 then
			gameUser.setZhuanpanCount(1)
		end
	end
	
	--特殊平台 角色升级 需要上传角色信息
	if GAME_CHANNEL == CHANNEL_CODE_JW or GAME_CHANNEL == CHANNEL_CODE_XT or GAME_CHANNEL == CHANNEL_CODE_SY then
		if ISLEVELUP >= 2 then
			XTHD.uploadPlayerInfo(3)  --角色升级
		end	
	end
end

function gameUser.getLevel()
	return tonumber(gameUser._level) or 1
end

function gameUser.setNickname(_name)
	if _name == nil then
		_name = ""
	end
	gameUser._nick_name = _name
end

function gameUser.getNickname()
	return gameUser._nick_name or ""
end

function gameUser.setSex(val)
	gameUser._sex = val
end

function gameUser.getSex()
	return gameUser._sex
end

function gameUser.setUserId(id)
	if id==nil then
		id = 0
	end
	gameUser._userId = id
end

function gameUser.getUserId()
	return gameUser._userId
end

function gameUser.setUUID(id)
	if id == nil then
		id = 0
	end
	gameUser._uuid = id
end

function gameUser.getUUID()
	return gameUser._uuid
end

function gameUser.getLastUUID()
	return gameUser._lastUUID
end

function gameUser.setLastUUID(uuid)
	if uuid == nil then
		uuid = ""
	end
	gameUser._lastUUID = uuid
end

function gameUser.setEnergy(energy)
	if energy == nil then
		energy = 0
	end
	gameUser._energy = energy
end
function gameUser.getEnergy()
	return tonumber(gameUser._energy)
end

function gameUser.setEnergyCD(value)
	if value == nil then
		value = 0
	end
	gameUser._energyCD = value
end
function gameUser.getEnergyCD(  )
	return gameUser._energyCD
end

function gameUser.setEnergySystemTime( )
	gameUser.energySystemTime = os.time()
end
function gameUser.getEnergySystemTime( )
	return gameUser.energySystemTime
end


function gameUser.setVip(vip)
	if vip == nil then
		vip = 0
	end
	gameUser._vip = vip
end
function gameUser.getVip()
	return tonumber(gameUser._vip)
end

-- function gameUser.getFightingBlockID( )
-- 	return gameUser._fightBlockID
-- end
-- function gameUser.setFightingBlockID(id)
-- 	gameUser._fightBlockID = tonumber(id) or 0
-- end
-- function gameUser.getEliteFightingBlockID( )
-- 	return gameUser._elitefightBlockID
-- end
-- function gameUser.setEliteFightingBlockID(id)
-- 	gameUser._elitefightBlockID = tonumber(id) or 1
-- end

function gameUser.getFightingBlockStatu( )
	return gameUser._isBlockWin
end

function gameUser.setFightingBlockStatu( value )
	gameUser._isBlockWin = value
end

function gameUser.setInstancingId(instancingId,isInit) ------isInit 是否是初始化
	if instancingId == nil then
		instancingId = 0
	end
	gameUser._instancingid = instancingId		
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCTION_BTNSHOW})
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "build"}})
	if not isInit then 
		YinDaoMarg:getInstance():triggerGuide(2,tonumber(instancingId))
	end 
end
function gameUser.getInstancingId()
	return tonumber(gameUser._instancingid)
end

function gameUser.setEliteInstancingId(eliteinstancingid)
	if eliteinstancingid == nil then
		eliteinstancingid = 0
	end
	gameUser._eliteinstancingid = eliteinstancingid
end
function gameUser.getEliteInstancingId()
	return tonumber(gameUser._eliteinstancingid)
end

function gameUser.setDiffcultyInstancingId(_id)
	if _id == nil then
		_id = 0
	end
	gameUser._diffcultyInstancingId = _id
end

function gameUser.getDiffcultyInstancingId()
	return tonumber(gameUser._diffcultyInstancingId)
end

--[[获取当前体力]]


--[[获取体力最大值]]
function gameUser.getTiliMax()
	return tonumber(gameUser._maxTili)
end
function gameUser.setTiliMax(tili)
	if tili == nil then
		tili = 0
	end
	gameUser._maxTili = tili
end


function gameUser.getTiliBuyCount()
	return tonumber(gameUser._buyTiliCount)
end
function gameUser.setTiliBuyCount(buyTiliCount)
	if buyTiliCount == nil then
		buyTiliCount = 0
	end
	gameUser._buyTiliCount = buyTiliCount
end

function gameUser.getTiliRestCD( )
	return gameUser._tiliCD
end
function gameUser.setTiliRestCD( value )
	if value == nil then
		value = 0
	end
	gameUser._tiliCD = value
end

function gameUser.setTiliSysytemTime( )
	gameUser.tiliSystemTime = os.time()
end
function gameUser.getTiliSystemTime( )
	return gameUser.tiliSystemTime
end

--[[获取当前技能点数]]
function gameUser.getSkillPointNow()
	return tonumber(gameUser._currSkillPoint)
end

function gameUser.setSkillPointNow(skillpoint)
	if skillpoint == nil then
		skillpoint = 0
	end
	gameUser._currSkillPoint = skillpoint
end
--[[获取当前购买的技能点数]]
function gameUser.getSkillPointBuyCount()
	return tonumber(gameUser._buySkillPointCount)
end
function gameUser.setSkillPointBuyCount(buySkillPointCount)
	if buySkillPointCount == nil then
		buySkillPointCount = 0
	end
	gameUser._buySkillPointCount = buySkillPointCount
end

--[[获取当前最大的技能点数]]
function gameUser.getMaxSkillPoint()
	return tonumber(gameUser._maxSkillPoint)
end
function gameUser.setMaxSkillPoint(skillpoint)
	if skillpoint == nil then
		skillpoint = 0
	end
	gameUser._maxSkillPoint = skillpoint
end

--[[获取当前最大购买的技能点的次数]]
function gameUser.getMaxSkillPointBuyCount()
	return tonumber(gameUser._maxBuySkillPointCount)
end
function gameUser.setMaxSkillPointBuyCount(maxbuySkillPointCount)
	if maxbuySkillPointCount == nil then
		maxbuySkillPointCount = 0 
	end
	gameUser._maxBuySkillPointCount = maxbuySkillPointCount
end

--[[获取剩余技能点购买次数]]
function gameUser.getLastskillPointBuyCount()
	gameUser._lastbuySkillPointCount = tonumber(gameUser._maxBuySkillPointCount) - tonumber(gameUser._buySkillPointCount)
	gameUser._lastbuySkillPointCount = gameUser._lastbuySkillPointCount > 0 and gameUser._lastbuySkillPointCount or 0
	return tonumber(gameUser._lastbuySkillPointCount)
end

function gameUser.getSaintStone()
	return gameUser._saintStone
end

function gameUser.setSaintStone(saintStone)
	gameUser._saintStone = saintStone
end

--[[获取累计充值元宝]]
function gameUser.getIngotTotal()
	return tonumber(gameUser._totalingot)
end
function gameUser.setIngotTotal(totalingot)
	if totalingot == nil then
		totalingot = 0
	end
	gameUser._totalingot = totalingot
end

--[[获取当前经验值]]
function gameUser.getExpNow()
	return tonumber(gameUser._curexp)
end
function gameUser.setExpNow(exp)
	if exp == nil then
		exp = 0
	end
	gameUser._curexp = exp
end


--[[获取经验最大值]]
function gameUser.getExpMax()
	return tonumber(gameUser._maxexp)
end
function gameUser.setExpMax(exp)
	if exp == nil then
		exp = 0
	end
	gameUser._maxexp = exp
end


function gameUser.getDuanId()
	return gameUser._baseContent._duanid
end
function gameUser.setDuanId(duanId)
	if duanId == nil then
		duanId =1
	end
	gameUser._baseContent._duanid = duanId
end

function gameUser.getDuanRank( )
	return gameUser._baseContent._duanRank
end

function gameUser.setDuanRank(randk)
	if randk == nil then
		randk = 0
	end
	gameUser._baseContent._duanRank = randk
end

function gameUser.getShengwang()
	return gameUser._baseContent._shengwang
end

function gameUser.setShengwang(shengwang)
	if shengwang == nil then
		shengwang = 0
	end
	gameUser._baseContent._shengwang = shengwang
end

function gameUser.setTemplateId(_templateid)
	gameUser._templateId = _templateid
end

function gameUser.getTemplateId()
	return gameUser._templateId or 1
end

function gameUser.setSocketIP(ip)
	print("the socket ip be signed",ip)
	if ip == nil then
		ip = 0
	end
	gameUser._socketIP = ip
end

function gameUser.getSocketIP()
	return gameUser._socketIP or 0
end

function gameUser.setSocketPort( socketPort)
	print("the socket port be signed",socketPort)
	if socketPort == nil then
		socketPort = 0
	end
	gameUser._socketPort = socketPort
end

function gameUser.getSocketPort( )
	return gameUser._socketPort or 0
end

function gameUser.setCampID( id)
	if id == nil then
		id = 0
	end 
	gameUser._campID = id 
end

function gameUser.getCampID()
	return gameUser._campID or 1;
end

function gameUser.setRecruitExchangeSum( recruitExchangeSum )
	if recruitExchangeSum == nil then
		recruitExchangeSum = 0
	end
	gameUser._recruitExchangeSum = recruitExchangeSum 
end

function gameUser.getRecruitExchangeSum( )
	return gameUser._recruitExchangeSum 
end

function gameUser.setRecruitExchangeEquipSum( recruitExchangeEquipSum )
	if recruitExchangeEquipSum == nil then
		recruitExchangeEquipSum = 0
	end
	gameUser._recruitExchangeEquipSum = recruitExchangeEquipSum 
end

function gameUser.getRecruitExchangeEquipSum( )
	return gameUser._recruitExchangeEquipSum 
end

function gameUser.setToken(token)
	if token == nil then
		token = ""
	end
	gameUser._token = token
end

function gameUser.getToken( )
	return gameUser._token
end

function gameUser.setNewLoginToken(token)
	if token == nil then
		token = ""
	end
	gameUser._newLoginToken = token
end

function gameUser.getNewLoginToken( )
	return gameUser._newLoginToken
end

function gameUser.setGoldSurplusExchangeCount(_count)
	if _count == nil then
		_count = 0
	end
	gameUser._goldSurplusExchangeCount = _count
end

function gameUser.getGoldSurplusExchangeCount()
	return gameUser._goldSurplusExchangeCount
end

function gameUser.setFeicuiSurplusExchangeCount(_count)
	if _count == nil then
		_count = 0
	end
	gameUser._feicuiSurplusExchangeCount = _count
end

function gameUser.getFeicuiSurplusExchangeCount()
	return gameUser._feicuiSurplusExchangeCount
end

function gameUser.setSmeltPoint(smeltPoint)
	gameUser._smeltPoint = smeltPoint
end

function gameUser.getSmeltPoint()
	return gameUser._smeltPoint
end

function gameUser.setAward(AwardPoint)
	gameUser._awardPoint = AwardPoint
end

function gameUser.getAward()
	return gameUser._awardPoint or 0
end

function gameUser.setHonor(value )
	gameUser._honor = value
end
function gameUser.getHonor( )
	return gameUser._honor
end

function gameUser.setServerId( server_id )
	if tonumber(server_id) ~= 0 then
		gameUser._serverId = server_id
	end
end

function gameUser.getServerId(  )
	if tonumber(gameUser._serverId) ~= 0 then
		return gameUser._serverId
	end
	return 1
end
function gameUser.setServerName( sever_name )
	if sever_name and string.len(sever_name)>0 then
		gameUser._serverName = sever_name
	end
end

function gameUser.getServerName(  )
	if string.len(gameUser._serverName) > 0 then
		return gameUser._serverName
	end
	return ""
end

--登录初始化引导
function gameUser.handleGuideData( guide )
	gameUser.setGuideID(guide) 	
	YinDaoMarg:getInstance():handleSpecial(guide)
end
--再次记录当前是否满足打通关条件，如果通关，需要播放通关特效
function gameUser.bIsPassNormalChapter()
	return gameUser._pass_normalchapter_status and gameUser._pass_normalchapter_status or 1
end
function gameUser.setPassNormalChapterStatus(id)
	gameUser._pass_normalchapter_status = tonumber(id)
end

--再次记录当前是否满足打通关条件，如果通关，需要播放通关特效
function gameUser.bIsPassEliteChapter()
	return gameUser._pass_elitechapter_status and gameUser._pass_elitechapter_status or 1
end
function gameUser.setPassEliteChapterStatus(id)
	gameUser._pass_elitechapter_status = tonumber(id)
end

function gameUser.setFreeChouTools( state )
	gameUser._recruitStateTools = state
end
function gameUser.getFreeChouTools( )
	return gameUser._recruitStateTools
end

function gameUser.setFreeChouHero( state )
	gameUser._recruitStateHero = state
end
function gameUser.getFreeChouHero( )
	return gameUser._recruitStateHero
end

function gameUser.getRecruiteState()
	if gameUser._recruitStateHero > 0 or gameUser._recruitStateTools > 0 then 
		return 1
	else 
		return 0
	end  	
end 

function gameUser.setOnlineTime(_time)
	if _time==nil or tonumber(_time)<0 then
		_time = 0
	end
	gameUser._onlineTime = _time
end
function gameUser.getOnlineTime()
	return gameUser._onlineTime
end

function gameUser.setExpItemSurplusSum(_table)
	if _table==nil or next(_table)==nil then
		_table = {}
	end
	gameUser._expItemSurplusSum = _table
end
function gameUser.getExpItemSurplusSum()
	return gameUser._expItemSurplusSum
end
function gameUser.setGodItemSurplusSum(_table)
	if _table==nil or next(_table)==nil then
		_table = {}
	end
	gameUser._godItemSurplusSum = _table
end
function gameUser.getGodItemSurplusSum()
	return gameUser._godItemSurplusSum
end
function gameUser.getVersion(  )
	return gameUser._version
end

function gameUser.setVersion( version )
	if version ~= nil then
		gameUser._version = version
	end
end

function gameUser.getTimeVipCd(  )
	return gameUser._timeVipCd
end

function gameUser.setTimeVipCd( _num )
	local sNum = tonumber(_num) or 0
	gameUser._timeVipCd = sNum
end

function gameUser.getGuildId(  )
	return gameUser._guildId
end

function gameUser.setGuildId( _num )
	local sNum = tonumber(_num) or 0
	gameUser._guildId = sNum
end

function gameUser.getGuildName(  )
	return gameUser._guildName
end

function gameUser.setGuildName( _str )
	gameUser._guildName = _str
end

function gameUser.getGuildRole(  )
	return gameUser._guildRole
end

function gameUser.setLuckyMoney( valu )
	gameUser._luckyMoney = valu
end
function gameUser.getLuckyMoney( )
	return gameUser._luckyMoney
end

function gameUser.setReputation(_num)
	 gameUser._setReputation = _num
end

function gameUser.getReputation()
	return gameUser._setReputation
end

function gameUser.setAsura(_num)
	 gameUser._setAsura = _num
end

function gameUser.getAsura()
	return gameUser._setAsura
end

function gameUser.setGuildRole( _num )
	local sNum = tonumber(_num) or 0
	gameUser._guildRole = sNum
end

function gameUser.getSevenDayRedPoint( )
	return gameUser._sevenDayRedPoint
end

function gameUser.setSevenDayRedPoint( _num )
	local sNum = tonumber(_num) or 0
	--7天活动图标一旦被干掉就不能再显示
	if gameUser._sevenDayRedPoint == -1 or sNum == gameUser._sevenDayRedPoint then
		return
	end
	gameUser._sevenDayRedPoint = sNum
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT, data = {name = "sevenDay"}})
end

--背包红点
function gameUser.getPackageRedPoint()
	return gameUser._packageRedPoint
end
function gameUser.setPackageRedPoint(_num)
	gameUser._packageRedPoint = _num
	if tonumber(_num) <= 0 then
    	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "package",["visible"] = false}})
    else
    	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "package",["visible"] = true}})
    end
end
--神器红点
function gameUser.getArtifactRedPoint()
	return gameUser._artifactRedPoint
end
function gameUser.setArtifactRedPoint(_num) 
	gameUser._artifactRedPoint = _num
	if tonumber(_num) <= 0 then
    	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "artifact",["visible"] = false}})
    else
    	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "artifact",["visible"] = true}})
    end
end
function gameUser.getSoul()
	return gameUser._soul
end

function gameUser.setSoul(_num)
	gameUser._soul = tonumber(_num)
end

function gameUser.getFirstPayState()
	return gameUser._firstPayState
end
function gameUser.setFirstPayState( _num )
	gameUser._firstPayState = tonumber(_num)
end

--全民竞技开启状态
function gameUser.getQMJJOpenState()
	local flag = 0
	if gameUser._activityOpenStatus["32"] == 1 then
		flag = 1
	end
	return flag
end

--战力竞赛开启状态
function gameUser.getZLJSOpenState()
	local flag = 0
	if  gameUser._activityOpenStatus["27"] == 1 or gameUser._activityOpenStatus["28"] == 1 or gameUser._activityOpenStatus["29"] == 1 or gameUser._activityOpenStatus["30"] == 1 or 
		gameUser._activityOpenStatus["45"] == 1 then
		flag = 1
	end
	return flag
end

--全民冲榜开启状态
function gameUser.getQMCBOpenState()
	local flag = 0
	if gameUser._activityOpenStatus["21"] == 1 or gameUser._activityOpenStatus["22"] == 1 or gameUser._activityOpenStatus["23"] == 1 or gameUser._activityOpenStatus["24"] == 1 or 
	   gameUser._activityOpenStatus["25"] == 1 or gameUser._activityOpenStatus["26"] == 1 or gameUser._activityOpenStatus["31"] == 1 or gameUser._activityOpenStatus["33"] == 1 or gameUser._activityOpenStatus["46"] == 1	then
		flag = 1
	end
	return flag
end

-- 只有玩家第一次登陆的时候初始化使用，会清除数据再赋值
function gameUser.setActivityOpenStatus( _status )
	-- 先清理
	gameUser._activityOpenStatus = {}
	for i, v in ipairs( _status ) do
		gameUser._activityOpenStatus[ tostring( v.huodongId ) ] = tonumber( v.state )
	end
	
	-- 七天
	local sevenDayStatus = tonumber( gameUser._activityOpenStatus["3"] or 0 )
	gameUser._sevenDayRedPoint = 1
	gameUser.setSevenDayRedPoint( sevenDayStatus == 1 and 0 or -1 )
end
function gameUser.setActivityOpenStatusById( _id, _status )
	if _id and _status then
		gameUser._activityOpenStatus[tostring(_id)] = tonumber( _status )
	end
end
function gameUser.getActivityOpenStatus()
	return gameUser._activityOpenStatus
end
function gameUser.getActivityOpenStatusById( _id )
	return gameUser._activityOpenStatus[tostring( _id )] or 0
end

function gameUser.initWithData(json)
	local id 				= tonumber(json["id"])
	local today 		 	= tonumber(json["today"])-----用于次日刷新 
	local level 			= tonumber(json["level"])
	local energy  			= tonumber(json["energy"]) 		--返回数据中无该字段
	local energyCD 			= tonumber(json["energyTime"]) ---精力的倒计时
	local vip 				= tonumber(json["vip"])
	local curexp 			= tonumber(json["curExp"])
	local maxexp 			= tonumber(json["maxExp"])
	local ingot 			= tonumber(json["ingot"])
	local gold  			= tonumber(json["gold"])
	local totalingot 		= tonumber(json["totalIngot"])
	local feicui 			= tonumber(json["feicui"])
	local instancingid 		= tonumber(json["instancingid"])
	local eliteinstancingid = tonumber(json["eliteinstancingid"])
	local lastUUID 			= tostring(json["lastUUID"])
	local buyTiliCount 		= tonumber(json["buyTiliCount"])
	local currTili 			= tonumber(json["currTili"])
	local maxTili 			= tonumber(json["maxTili"])
	local tiliCd 			= tonumber(json["tiliTime"]) ---体力倒计时
	local uuid 		 		= tostring(json["uuid"])
	local currSkillPoint 	= tonumber(json["curSkillPoint"])
	local buySkillPointCount= tonumber(json["buySkillPointCount"])
	local campID			= tonumber(json["campId"])
	local saintStone 		= tonumber(json["godStone"])   	--返回数据中无该字段
	local taskState   		= tonumber(json["taskState"]) ----任务领取状态
	local mailAmount   		= tonumber(json["newEmail"]) ----新邮件数量
	local smeltPoint 		= tonumber(json["smeltPoint"]) --回收值
	local baseContent 		= json["baseContent"]
	local energy 			= tonumber(json["energy"])
	local duanid 			= tonumber(baseContent["duanId"])
	local duanRank 			= tonumber(baseContent["rankId"])
	local shengwang   		= tonumber(baseContent["shengwang"])
	local loginTime 		= tonumber(json["now"])
	local honor 			= tonumber(json["honor"])
	local recruitItemState	= tonumber(json["recruitItemState"])
	local recruitPetState	= tonumber(json["recruitPetState"])
	local award 			= tonumber(json["medal"])
	local templateId 		= tonumber(json["templateId"]) --存储头像的图片id 20150427
	local name 				= tostring(json["name"]) --存储昵称20150427
	local ip 				= tostring(json["socketIp"]) --存储昵称20150427
	local port 				= tostring(json["socketPort"]) --存储昵称20150427
	local expItemSurplusSum = json["expItemSurplusSum"] 				--经验道具剩余购买次数
	local stoneItemSurplusSum = json["stoneItemSurplusSum"] 			--神器进价石剩余购买次数
	local vipRewardStatu 	= json["vipRewardState"] ----vip奖励领取状态 
	local reputation 		= tostring(baseContent["renown"]) -- 声望
	local asura 			= tostring(baseContent["asuraBlood"]) --修罗血
	local limitShop         = tonumber(json["limitShop"])   --限时商城开启状态

	local recruitExchangeSum= tonumber(json["exchangePetSum"]) --存储兑换英雄次数 2015.05.22  
	local recruitExchangeEquipSum= tonumber(json["exchangeItemSum"]) --存储兑换装备次数 2015.08.03

	local goldSurplusCount 	= tonumber(json["silverSurplusSum"]) 	--银两剩余兑换次数
	local feicuiSurplusCount= tonumber(json["feicuiSurplusSum"]) 	--翡翠剩余兑换次数
	local server_id 		= tonumber(json["serverId"]) or 1
	local guide 			= json["guide"] --新手引导ID
	local nameCount   		=tonumber(json["changeNameCount"]) or 1   --已经更改名字次数
	local vipCD 			= tonumber(json['timeVipCd']) ----vip临时CD
	local osTimes 			= tonumber(json['liucunReward']) ----开服礼包状态1 领取完
	local timeVipCd 		= tonumber(json['timeVipCd']) ----开服礼包状态1 领取完
	local bounty 			= tonumber(json['bounty']) ------赏金数量 
	local guildId 			= tonumber(baseContent['guildId']) ----公会id
	local guildName 		= tostring(baseContent['guildName']) ------公会名字
	local guildRole 		= tonumber(baseContent['guildRole']) ------公会中等级 	
	local lastCampResult    = tonumber(json["lastCampResult"]) --最近一次种族战的结果0 : 平局; 1 : 光明古胜利; 2 ; 暗月岭胜利
	local loginRewardState 	= tonumber(json["loginRewardState"])
	local luckyMoney 		= tonumber(json["luckMoney"]) -----幸运币
	local firstPayState		= tonumber(json["fristPayState"]) -----首充
	local zhenqi 			= tonumber(json["zhenqi"] or 0) 		--真气 ，等后端加上这里还要改
	local soul 				= tonumber(json["hunyu"] or 0) --魂玉
	local activityStates    = json["activityStates"]
	local zhuanpanCount     = tonumber(json["levelZhuanPanPoint"]) --升级转盘摇奖次数
	local diffcultyInstancingId = tonumber(json["diffcultyInstancingId"])
	local curworpship = tonumber(json["curWorship"])  --剩余膜拜次数
	local servant           = tonumber(json["wanlingpo"])
	-- local baodian           = tonumber(json["bibleState"])--宝典的状态
	local roleCreateTime    = tonumber(json["createData"])
	local speed             = tonumber(json["speed"])

	ISLEVELUP = 0

	gameUser.setBattleSpeed(speed)
	gameUser.setRoleCreateTime(roleCreateTime)
    gameUser.setCurWorpShip(curworpship)
	gameUser.setZhuanpanCount(zhuanpanCount)
	gameUser.setSoul(soul)
	gameUser.setZhenqi(zhenqi)
	gameUser.setLuckyMoney(luckyMoney)
	gameUser.setOSPackageTimes(osTimes)
	gameUser.setTemplateVIPCD(vipCD)

	gameUser.setNameCount(nameCount)
	gameUser.setToday(today)
	gameUser._baseContent = baseContent
	gameUser.setLoginServerTime(loginTime)
	gameUser.setUserId(id)

	gameUser._preLevel = level
	gameUser._level = 0 --初始等级状态恢复为0

	gameUser.setLastUUID(lastUUID)
	gameUser.setFeicui(feicui)
	gameUser.setTiliRestCD(tiliCd)
	gameUser.setTiliSysytemTime()
	gameUser.setEnergyCD(energyCD)
	gameUser.setEnergySystemTime()
	gameUser.setVip(vip)
	gameUser.setHonor(honor)

	gameUser.setTiliNow(currTili)
	gameUser.setTiliMax(maxTili)

	gameUser.setSkillPointNow(currSkillPoint)

	gameUser.setIngot(ingot)
	gameUser.setIngotTotal(totalingot)
	gameUser.setGold(gold)

	gameUser.setFreeChouHero(recruitPetState)
	gameUser.setFreeChouTools(recruitItemState)

	gameUser.setExpMax(maxexp)
	gameUser.setExpNow(curexp)
	gameUser.setEnergy(energy)
	gameUser.setTiliBuyCount(buyTiliCount)
	gameUser.setSkillPointBuyCount(buySkillPointCount)

	gameUser.setSaintStone(saintStone)
	gameUser.setServant(servant)

	gameUser.setDuanId(duanid)
	gameUser.setDuanRank(duanRank)
	gameUser.setShengwang(shengwang)

	gameUser.setInstancingId(instancingid,true)
	gameUser.setEliteInstancingId(eliteinstancingid)
	gameUser.setDiffcultyInstancingId(diffcultyInstancingId)
	-- gameUser.setFightingBlockID(instancingid)

	gameUser._storyDisplayedID = instancingid
	gameUser.setBounty(bounty)
	gameUser.setGuildId(guildId)
	gameUser.setGuildRole(guildRole)
	gameUser.setGuildName(guildName)

	gameUser.setTemplateId(templateId)
	gameUser.setNickname(name)

	gameUser.setUUID(uuid)

	gameUser.setSocketPort(port)
	gameUser.setSocketIP(ip)
	gameUser.setAward(award)
	gameUser.setRecruitExchangeSum(recruitExchangeSum)
	gameUser.setRecruitExchangeEquipSum(recruitExchangeEquipSum)
	gameUser.setCampID(campID)

	gameUser.setGoldSurplusExchangeCount(goldSurplusCount)
	gameUser.setFeicuiSurplusExchangeCount(feicuiSurplusCount)

	gameUser.setEmailAmount(mailAmount)
	gameUser.setSmeltPoint(smeltPoint)
	gameUser.setTaskGettinState(taskState)
	-- print("@@:" .. baodian)
	-- gameUser.setbaodianGettinState(baodian)

	gameUser.setExpItemSurplusSum(expItemSurplusSum)
	gameUser.setGodItemSurplusSum(stoneItemSurplusSum)
	
	gameUser._preGold = gameUser.getGold()
	gameUser._preIngot = gameUser.getIngot()
	gameUser._preCurrTili = gameUser.getTiliNow()
	gameUser._preFeicui = gameUser.getFeicui()
	gameUser.setServerId(server_id)
	gameUser.setVersion("1.0.0")
	gameUser._vipRewardStatu = vipRewardStatu
	gameUser.setTimeVipCd(timeVipCd)

	gameUser.setReputation(reputation)
	gameUser.setAsura(asura)
	gameUser.setLimitTimeShopState(limitShop)

	-- gameUser.setActivityLoginRewardState(loginRewardState)

	gameUser.setFirstPayState(firstPayState)

	gameUser.setActivityOpenStatus(activityStates)

	gameUser.setPackageRedPoint(0) --清理
	gameUser.setArtifactRedPoint(0) --清理
	gameUser.setbaodianGettinState(0)

	ZhongZuDatas:setCampWarLatestResult(lastCampResult)----最近一次种族战的战斗结果 
	-----引导处理	
	gameUser.handleGuideData(guide)
	--清除本地幸运榜数据
    gameUser.clearLuckyListData()
    gameUser.setLevel(level)
	------------------------------------
	lastGuideRecuritTime = 0
	gameUser.getYWCRedState()
	print("重新初始化用户数据")  
end
--[[更新玩家的数据，
	参数 id来源于后端
	id : 属性id
	num : 最终结果值

	注：后期的需求，根据自己的需求和对应的id，自行更新相应的数据
]]
function gameUser.updateDataById(id,result_num)
	local prop_id = tonumber(id)
	if not prop_id then 
		return
	end
	prop_id = tonumber(prop_id)
	if prop_id == 400 then
		gameUser.setLevel(result_num)
	elseif prop_id == 401 then
		--todo
	elseif prop_id == 402 then
		gameUser.setGold(result_num)--银两
	elseif prop_id == 403 then
		gameUser.setIngot(result_num)--元宝 
	elseif prop_id == 404 then
	--todo
	elseif prop_id == 405 then
	--todo
	elseif prop_id == 406 then
		gameUser.setVip(result_num)
	elseif prop_id == 407 then
	--todo
	elseif prop_id == 408 then
	--todo
	elseif prop_id == 409 then
	--todo
	elseif prop_id == 410 then
		gameUser.setTiliNow(result_num)
	elseif prop_id == 411 then
	--todo
	elseif prop_id == 412 then
	--todo
	elseif prop_id == 413 then
		gameUser.setExpNow(result_num)
	elseif prop_id == 414 then
		gameUser.setExpMax(result_num)
	elseif prop_id == 415 then
		
	elseif prop_id == 416 then
	--todo
	elseif prop_id == 417 then
	--todo
	elseif prop_id == 418 then ----翡翠
		gameUser.setFeicui(result_num)
	elseif prop_id == 419 then
		gameUser.setEnergy(result_num)
	elseif prop_id == 426 then ----荣誉 
		gameUser.setHonor(result_num)
	elseif prop_id == 427 then --绿魂石
		
	elseif prop_id == 428 then --蓝魂石
		
	elseif prop_id == 429 then --紫魂石
		
	elseif prop_id == 430 then --赤魂石
		
	elseif prop_id == 431 then --神石
		gameUser.setSaintStone(result_num)
	elseif prop_id == 432 then --帮派贡献
		gameUser.setGuildPoint(result_num)
	elseif prop_id == 433 then --每天增加的势力点数
		ZhongZuDatas.setSelfPerDayForce(result_num)
	elseif prop_id == 434 then --累计增加的势力点数
		ZhongZuDatas.setSelfAllForce(result_num)
	elseif prop_id == 435 then --膜拜 次数

	elseif prop_id == 437 then ---- 回收值 
		gameUser.setSmeltPoint(tonumber(result_num or 0))
	elseif prop_id == 438 then ---奖牌
		gameUser.setAward(result_num)
	elseif prop_id == 443 then
		gameUser.setFlower(result_num)
	elseif prop_id == 446 then -----赏金
		gameUser._bounty = result_num
	elseif prop_id == 447 then -- 普通金矿

	elseif prop_id == 448 then -- 紫金金矿

	elseif prop_id == 449 then -- 天玄金矿

	elseif prop_id == 450 then -- 普通玉石

	elseif prop_id == 451 then -- 玄冰灵玉

	elseif prop_id == 452 then -- 天尊宝玉

	elseif prop_id == 453 then ---声望
		gameUser.setReputation(result_num)
	elseif prop_id == 454 then ----修罗
		gameUser.setAsura(result_num)
	elseif prop_id == 455 then ------许愿点
		gameUser.setVowPoint(result_num)
	elseif prop_id == 456 then --魂玉
		gameUser.setSoul(result_num)	
	elseif prop_id == 457 then ----幸运币
		gameUser.setLuckyMoney(result_num)
	elseif prop_id == 458 then ----首充
		gameUser.setFirstPayState(result_num)
	elseif prop_id == 459 then ------真气
		gameUser.setZhenqi(result_num)
    elseif prop_id == 460 then  --万灵魂
    	gameUser.setServant(result_num)
	end
end

function gameUser.getDataById(id)

	local prop_id = tonumber(id)
	if not prop_id then 
		return
	end
	prop_id = tonumber(prop_id)
	if prop_id == 400 then
		return gameUser.getLevel()
	elseif prop_id == 401 then
		--todo
	elseif prop_id == 402 then
		return gameUser.getGold()--银两
	elseif prop_id == 403 then
		return gameUser.getIngot()--元宝 
	elseif prop_id == 404 then
	--todo
	elseif prop_id == 405 then
	--todo
	elseif prop_id == 406 then
		return gameUser.getVip()
	elseif prop_id == 407 then
	--todo
	elseif prop_id == 408 then
	--todo
	elseif prop_id == 409 then
	--todo
	elseif prop_id == 410 then
		return gameUser.getTiliNow()
	elseif prop_id == 411 then
	--todo
	elseif prop_id == 412 then
	--todo
	elseif prop_id == 413 then
		return gameUser.getExpNow()
	elseif prop_id == 414 then
		return gameUser.getExpMax()
	elseif prop_id == 415 then
		
	elseif prop_id == 416 then
	--todo
	elseif prop_id == 417 then
	--todo
	elseif prop_id == 418 then --翡翠
		return gameUser.getFeicui()
	elseif prop_id == 419 then
		return gameUser.getEnergy()
	elseif prop_id == 426 then --荣誉值
		return gameUser.getHonor()
	elseif prop_id == 427 then --绿魂石
		
	elseif prop_id == 428 then --蓝魂石
		
	elseif prop_id == 429 then --紫魂石
		
	elseif prop_id == 430 then --赤魂石
		
	elseif prop_id == 431 then --神石
		return gameUser.getSaintStone()
	elseif prop_id == 432 then --帮派贡献
		return gameUser.getGuildPoint()
	elseif prop_id == 433 then --每天增加的势力点数
		return ZhongZuDatas.getSelfPerDayForce()
	elseif prop_id == 434 then --累计增加的势力点数
		return ZhongZuDatas.getSelfAllForce()
	elseif prop_id == 435 then --膜拜 次数
	elseif prop_id == 438 then --奖牌
		return gameUser.getAward()
	elseif prop_id == 446 then  ---赏金		
		return gameUser._bounty
	elseif prop_id == 447 then -- 普通金矿

	elseif prop_id == 448 then -- 紫金金矿

	elseif prop_id == 449 then -- 天玄金矿

	elseif prop_id == 450 then -- 普通玉石

	elseif prop_id == 451 then -- 玄冰灵玉

	elseif prop_id == 452 then -- 天尊宝玉

	elseif prop_id == 453 then ---声望
		return gameUser.getReputation()
	elseif prop_id == 454 then ----修罗
		return gameUser.getAsura()
	elseif prop_id == 455 then ------许愿点
		return gameUser.getVowPoint()
	elseif prop_id == 456 then --魂玉
		return gameUser.getSoul()
	elseif prop_id == 457 then ------幸运币
		return gameUser.getLuckyMoney()
	elseif prop_id == 458 then ------首充
		return gameUser.getFirstPayState()
	elseif prop_id == 459 then ------真气
		return gameUser.getZhenqi()
	elseif prop_id == 443 then
		return gameUser.getFlower(flower)
	end
end
------刷新明天的数据 
function gameUser.resetDataForTomorrow(now)
	if not gameUser._today then 
		gameUser._today = now
	else 
		if gameUser._today ~= now then 
			gameUser._today = now
			gameUser._buyTiliCount = 0 ---体力 
			gameUser._buySkillPointCount = 0 ---技能点
			local _data = gameData.getDataFromCSV("VipInfo")
			if _data then  
				local key = "vip"..gameUser:getVip()
				if _data[15] then 
					gameUser._goldSurplusExchangeCount = _data[15][key] 		-- 银两剩余兑换次数
				end 
				if _data[16] then 
					gameUser._feicuiSurplusExchangeCount = _data[16][key] 	-- 翡翠剩余兑换次数
				end 
			end 
			DBTableInstance.updateEliteResetTimes(gameUser.getUserId(),nil,0) ---精英副本重置次数
		end 
	end 
end
