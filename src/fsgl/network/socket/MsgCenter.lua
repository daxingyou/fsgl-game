--[[
send data to server or receive data from server by socket
socket data 
authored by LITAO
time 2015.5.6
]]
--require "src/gui/XTHDConfirmDialog"
requires("src/fsgl/network/socket/SocketSend.lua")
local SocketTCP = requires("src/fsgl/network/socket/SocketTCP.lua")
local socket = nil

MsgCenter = {}

MsgCenter.didInit = false
---static area
MsgCenter.lastMsg = nil

MsgCenter.pingSchedule = 0

MsgCenter.isSocketSafe = false
--static area end
MsgCenter.MsgType = {
	CLIENT_REQUEST_LOGIN = 1001, --user login
	CLIENT_REQUEST_CHAT = 1002, -- chat (above all chat type)
	CLIENT_REQUEST_ARENASTART = 1003, -- 修罗战开始匹配
	CLIENT_REQUEST_ARENASTOP = 1004, -- 修罗战停止匹配
	CLIENT_REQUEST_ARENACHOOSE = 1005, -- 修罗战选择英雄
	CLIENT_REQUEST_CREATEMULTITEAM = 1006,----创建多人副本队伍 
	CLIENT_REQUEST_EXITMULTITEAM = 1007, ----退出多人副本的队伍
	CLIENT_REQUEST_JOINMULTITEAM = 1008, ---加入多人副本的某个队伍
	CLIENT_REQUEST_EXCHANGEROLEMULTI = 1009,----多人副本更换英雄
	CLIENT_REQUEST_KICKOUTSOMEONE = 1010,----多人副本里踢出某个人
	CLIENT_REQUEST_MULTISPEEKOUT = 1011, ----多人副本喊话 
	CLIENT_REQUEST_INVITEFROMWORLD = 1012, -------多人副本世界邀请
	CLIENT_REQUEST_INVITEFRIEND = 1013, -----多人副本邀请好友
	CLIENT_REQUEST_PREPARE = 1014, -----准备消息/取消准备
	CLIENT_REQUEST_DOFIGHT = 1015, ------可开战了
	CLIENT_REQUEST_FASTJOINTEAM = 1016, -----快速加入 
}

local MSGID = {
	SERVER_CONNECT_SUCCESS = 5000, ---socket连接成功
	SERVER_RESPONSE_LOGIN = 5001, --socket登陆成功
	SERVER_RESPONSE_ERROR = 5002, ----错误消息
	SERVER_RESPONSE_CHAT = 5003, ----聊天
	SERVER_RESPONSE_EMAILS = 5004, --邮件
	SERVER_RESPONSE_FRIEND_GETREQUEST = 5005, --获得请求好友信息
	SERVER_RESPONSE_ENERGY = 5006, ---体力
	SERVER_RESPONSE_JINGENERGY = 5007, ---精力	
	SERVER_RESPONSE_SKILLDOT = 5008, ---技能点
	SERVER_RESPONSE_BUILDINGS = 5010, --城市建筑
	SERVER_RESPONSE_TASKAVA = 5011, --任务能完成提醒(红点)
	SERVER_RESPONSE_ACTIVITYCANGET = 5012, --有活动可领取(红点)
	SERVER_RESPONSE_CANCHOUKA_TOOLS = 5013, --道具能招募(红点)
	SERVER_RESPONSE_CANCHOUKA_HERO = 5014, --英雄能招募(红点)
	SERVER_RESPONSE_VIPREWARD = 5015, --VIP奖励(红点)
	SERVER_RESPONSE_FRIEND_DOREQUEST = 5016, --同意请求好友信息
	SERVER_RESPONSE_FRIEND_ONLINE = 5017, --好友上线信息
	SERVER_RESPONSE_FRIEND_SEND = 5018, --好友赠送信息
	SERVER_RESPONSE_FRIEND_FIGHT = 5019, --切磋结果提醒
	SERVER_RESPONSE_FRIEND_OFFLINE = 5020, --好友下线信息
	SERVER_RESPONSE_FRIEND_DELETE = 5021, --删除好友信息 
	SERVER_RESPONSE_VIPOUTOFPOWER = 5022, --vip过期提醒
	SERVER_RESPONSE_OPENSERVERPACKAGE = 5023, --开服奖励提醒
	SERVER_RESPONSE_LOGOUT = 5024, --强制登出
	SERVER_RESPONSE_GUILDCHANGE = 5025, --帮派状态变更
	SERVER_RESPONSE_WORLDBOSSKILL=5026, --世界boss击杀
	SERVER_RESPONSE_WORLDBOSSOVER=5027,	--世界boss结束排名
	SERVER_RESPONSE_CAMPTIPS = 5028,----阵营开战提醒 

	SERVER_RESPONSE_MATCHING = 5030,----修罗战场匹配
	SERVER_RESPONSE_RIVALTEAM = 5031,----修罗战场对手信息
	SERVER_RESPONSE_WORLDBOSSHURT=5033,--世界boss血量推送
	SERVER_RESPONSE_CAMPRESULT = 5034,----阵营战结果
	SERVER_RESPONSE_KICKOUTARENA = 5035,----踢出修罗选将
	SERVER_RESPONSE_ESCORTTIPS = 5036,----劫镖提醒
	SERVER_RESPONSE_TIMEBATTLEOPEN = 5037,----限时战（boss/帮派/修罗）
	SERVER_RESPONSE_SEVENDAYREDPOINT = 5038,----7日狂欢红点控制(红点)
	SERVER_RESPONSE_ARENASTARTRESULT = 5039,----修罗战场选匹配上结果消息 
	SERVER_RESPONSE_ARENAQUITRESULT = 5040,----修罗战场选取消匹配结果
	SERVER_RESPONSE_ARENANOFIGHTER = 5041,----修罗战场匹配不到合适的对手

	SERVER_RESPONSE_MCCREATETEAMSU = 5042, -----多人副本创建队伍成功
	SERVER_RESPONSE_MCCAPTAINCHANGED = 5043,----多人副本队长变动
	SERVER_RESPONSE_MCCMEMBERQUIT = 5044, ----多人副本成员离队
	SERVER_RESPONSE_MCCNEWMEMBEJOIN = 5045, ------多人副本有新成员加入
	SERVER_RESPONSE_MCCPREEMEMBERS = 5046,-----多人副本原有成员列表
	SERVER_RESPONSE_MCCEXCHANGEROLE = 5047,----多人副本更换英雄
	SERVER_RESPONSE_MCCTALK = 5048,----多人副本聊天消息
	SERVER_RESPONSE_MCCINVITEFRIEND = 5049,----多人副本好友邀请提醒
	SERVER_RESPONSE_MCCREADY = 5050,----多人副本队友准备提醒/取消准备
	SERVER_RESPONSE_MCCOPEN= 5051,----多人副本开启提醒
	SERVER_RESPONSE_PPRECHARGEOVER= 5052,----pp充值完成提醒
	SERVER_RESPONSE_CASTELLANFIGHT= 5053,----城主被抢提醒
	SERVER_RESPONSE_NEWCHATMSG= 5055,----新的聊天消息头
	SERVER_RESPONSE_LUCKYLIST = 5056,  --幸运转盘幸运榜
	SERVER_RESPONSE_DINGHAO = 5058,  --顶号
	SC_BEAT_MSG = 5059,  --心跳消息
	SC_ECHO_MSG = 5060,  --心跳响应
	SC_ACTIVITY_CZYL_MSG = 5061, --节日狂欢 充值有礼(红点)
	SC_ACTIVITY_XFHL_MSG = 5062, --节日狂欢 消费好礼(红点)
	SC_ACTIVITY_HYYL_MSG = 5063,   --活跃有礼(红点)
	SC_ACTIVITY_TZJH_MSG = 5064,   --投资计划(红点)
	SC_ACTIVITY_XFYL_MSG = 5065,   --消费有礼(红点)
	SC_ACTIVITY_BYDL_MSG = 5066,   --毕业典礼(红点)
	SC_ACTIVITY_CZFL_MSG = 5067,   --日常活动 充值返利(红点)
	SC_ACTIVITY_XFFL_MSG = 5068,   --日常活动 消费返利(红点)
	SC_ACTIVITY_KCFL_MSG = 5069,   --日常活动 开采返利(红点)
	SC_ACTIVITY_ZMFL_MSG = 5070,   --日常活动 招募返利(红点)
	SC_ACTIVITY_SBFL_MSG = 5071,   --日常活动 神兵返利(红点)
	SC_ACTIVITY_SQFL_MSG = 5072,   --日常活动 神器返利(红点)
	SC_ACTIVITY_DLYL_MSG = 5073,   --日常活动 登录有礼(红点)
	SC_ACTIVITY_HS_MSG = 5074,   --回收(红点)
	SC_ACTIVITY_BG_MSG = 5075,   --闭关(红点)
	SERVER_RESPONSE_UPDATEICON  = 5076,   --更新聊天的信息
	SC_ACTIVITY_CLDH_MSG = 5077,   --节日狂欢 材料兑换(红点)
	SC_ACTIVITY_SZDH_MSG = 5078,   --节日狂欢 神装兑换(红点)
	SC_ACTIVITY_YXDH_MSG = 5079,   --节日狂欢 英雄兑换(红点)
	SC_ACTIVITY_XYDH_MSG = 5080,   --节日狂欢 稀有兑换(红点)
	SC_ACTIVITY_CZJJ_MSG = 5081,	--缤纷有礼 成长基金（红点）
	SC_ACTIVITY_SCSC_MSG = 5082,	--三次首冲（红点）
	SC_ACTIVITY_SCTG_MSG = 5083,	--缤纷有礼 首冲团购（红点）
	SC_ACTIVITY_YKZZK_MSG = 5084,	--月卡至尊卡（红点）
    SC_BAG_CAN_OPEN_REMIND_MSG = 5085, --背包可开启提醒
	SC_TITLE_ACTIVITE_REMIND_MSG = 5086, --获得新称号提示

}
MsgCenter.MSGID = MSGID

local HEADERLENGTH = 4
MsgCenter.HEADERLENGTH = HEADERLENGTH

local function onMsgRecive(event)
	if event then 		
		local msgID = event.data.msgID
		repeat
			if msgID == MSGID.SERVER_CONNECT_SUCCESS then --connect to server successfully
				local len = event.data.msg:readShort()
				local time = event.data.msg:readStringBytes(len)
                gameUser._socketLoginTime = tonumber(time) -----socket登录时间
                
				MsgCenter:sendLoginMsg(gameUser.getUUID())
				break
			elseif msgID == MSGID.SERVER_RESPONSE_LOGIN then --login
				local loginResult = event.data.msg:readChar() --login result (1 login successfully,0 login failure)		
				if tonumber(loginResult) > 0 then 
					MsgCenter.isSocketSafe = true
					LiaoTianDatas.getChatRecord() ------请求聊天记录
				else
					MsgCenter.isSocketSafe = false
				end 
				break
			elseif msgID == MSGID.SERVER_RESPONSE_ERROR then --errors tips
				local errorID = event.data.msg:readShort() --the errors' code 
				local len = event.data.msg:readShort()
				local errorContent = event.data.msg:readStringBytes(len)-- the errors' contents
				SocketSend:getInstance():erroHandle(errorID,{
					errorID = errorID,
					msg = errorContent
				})

				print("wm-----errorContent : " .. tostring(errorID) .. " , " .. tostring(errorContent))
				-- 5822 上阵了重复的英雄
				-- 5821 数量错误
				XTHDTOAST(errorContent)		
				break
			elseif msgID == MSGID.SERVER_RESPONSE_CHAT then --chat online
				local chat = {}
				chat.chatType = event.data.msg:readChar() --聊天类型 (1 private chat,8 society chat,16 world chat,20 announcement,32 camp)

				chat.senderID = event.data.msg:readInt() -- 发送者ID

				local len = event.data.msg:readShort()
				chat.senderName = event.data.msg:readStringBytes(len) --发送都名称

				chat.iconID = event.data.msg:readInt() ----头像ID

				chat.reciverID = event.data.msg:readInt() --接收都ID.The value would be 0 while the chat type is not private

				len = event.data.msg:readShort()
				chat.reciverName = event.data.msg:readStringBytes(len) -- 接收都名字. The value would be 0 while the chat type is not private

				len = event.data.msg:readShort()
				chat.chatMsg = event.data.msg:readStringBytes(len)	----聊天内容

				chat.senderLevel = event.data.msg:readChar() --发送者等级		

				chat.senderCampID = event.data.msg:readChar() --发送都阵营ID

				len = event.data.msg:readShort()
				chat.senderBPName = event.data.msg:readStringBytes(len) --发送者公会名字，

				chat.senderArenaID = event.data.msg:readChar() --发送者竞技场段位ID，

				chat.senderVIP = event.data.msg:readChar() ----发送者VIP等级

				len = event.data.msg:readShort()
				chat.msgTime = event.data.msg:readStringBytes(len)----该消息的服务器时间 

				chat.leaderRange = event.data.msg:readChar()---领袖排名 

				chat.skyGuardID = event.data.msg:readInt() ---在天外天中获得的守卫ID

				chat.multiTeamID = event.data.msg:readInt() -----队伍 （>0 是多人副本世界邀请，<= 0 都不是）
				chat.multiConfigID = event.data.msg:readShort() -------多人副本静态表第一列ID
				chat.multiBlackPos = event.data.msg:readChar() -----多人副本里当前组还有多少个空位
				
				len = event.data.msg:readShort()
				chat.item = event.data.msg:readStringBytes(len)
				chat.titleId = event.data.msg:readInt()
				if chat.chatType == LiaoTianDatas.__chatType.TYPE_PRIVATE_CHAT then
					HaoYouPublic.addTalkMsg(chat)
				elseif chat.chatType == LiaoTianDatas.__chatType.TYPE_PAOMADENG then
					-- print("---------------专属跑马灯---------------")
					local data = LiaoTianDatas.analysisServerMsg(chat)	
					if data then
                        local node = cc.Director:getInstance():getNotificationNode()	
						local announce = node:getChildByName("announcement")					
						XTHDMarqueeNode:insertAData(data.message)
						if announce then 
							announce:run()
						end 
					end
				else
					LiaoTianDatas.insertMsg(chat.chatType,false,chat)	
				end	
				break
			elseif msgID == MSGID.SERVER_RESPONSE_UPDATEICON then
				local newchat = {}
				newchat.senderID = event.data.msg:readInt()
				local len = event.data.msg:readShort()
				newchat.senderName = event.data.msg:readStringBytes(len) 
				newchat.senderVIP = event.data.msg:readShort()
				newchat.iconID = event.data.msg:readInt()
				newchat.senderCampID = event.data.msg:readInt()
				LiaoTianDatas.updateMsg(newchat)
				break
			elseif msgID == MSGID.SERVER_RESPONSE_SKILLDOT then ---技能点	
                print("技能点推送")
				local _value = event.data.msg:readInt()
				gameUser.setSkillPointNow(_value) ----当前技能点值

				_value = event.data.msg:readInt()
				gameUser.setMaxSkillPoint(_value) ---最大技能点

				_value = event.data.msg:readShort()
				gameUser.setSkillPointBuyCount(_value) ---已购买技能点次数

				local CD = event.data.msg:readInt()

				_value = event.data.msg:readShort()
				gameUser.setMaxSkillPointBuyCount(_value) ---最大技能点购买次数

				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_SKILLPOINT})
				break
			elseif msgID == MSGID.SERVER_RESPONSE_ENERGY then ----体力
                print("体力推送")
				local energy = {}
				energy.currentEnergy = event.data.msg:readInt()
				energy.maxEnergy = event.data.msg:readInt()
				energy.hasBuyTimes = event.data.msg:readShort()
				energy.CD = event.data.msg:readInt()
				energy.maxBuyTimes = event.data.msg:readShort()
				gameUser.setTiliNow(energy.currentEnergy)
				gameUser.setTiliMax(energy.maxEnergy)
				gameUser.setTiliBuyCount(energy.hasBuyTimes)
				gameUser.setTiliRestCD(energy.CD)
				gameUser.setTiliSysytemTime()
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) ---刷新TopBar
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) --刷新主城
				break
			elseif msgID == MSGID.SERVER_RESPONSE_JINGENERGY then ----精力
                print("精力推送")
				local currentValue = event.data.msg:readInt()
				local maxValue = event.data.msg:readInt()
				local CD = event.data.msg:readInt()
				gameUser.setEnergy(currentValue)
				gameUser.setEnergyCD(CD)
				gameUser.setEnergySystemTime()
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) ---刷新TopBar
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) --刷新主城
				break
			elseif msgID == MSGID.SERVER_RESPONSE_BUILDINGS then  ----城市建筑
                print("城市建筑推送")
				local build = {}
				build.buildId = event.data.msg:readInt()
				build.level = event.data.msg:readInt()
				build.gold = event.data.msg:readInt()
				build.feicui = event.data.msg:readInt()
				build.upEndTime = event.data.msg:readInt()
				build.addSpeedEndTime = event.data.msg:readInt()
				UserDataMgr:updateCityBuild(build)
				break
			elseif msgID == MSGID.SERVER_RESPONSE_EMAILS then ----邮件
				local newamount = event.data.msg:readShort()
				local recamount = event.data.msg:readShort()
				print("长连接推送新邮件内容-------------"..newamount)
				print("长连接推送未领取邮件内容-------------"..recamount)
				gameUser.setEmailAmount( newamount )
				ISUNREADMAIL = false
				if newamount > 0 then 
					ISUNREADMAIL = true
				end 
				RedPointState[15].state = 0
				if recamount > 0 then
					RedPointState[15].state = 1
				end
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "mail"}})
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RED_POINT})
				break
			elseif msgID == MSGID.SERVER_RESPONSE_TASKAVA then -----任务
				print("task任务红点推送")
				gameUser.setTaskGettinState(1)		
				RedPointState[10].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "task",['visible'] = true}})
				break
            elseif msgID == MSGID.SC_BAG_CAN_OPEN_REMIND_MSG then
                local flag = event.data.msg:readInt()
                print("行囊可开启推送:"..flag)
                RedPointState[29].state = flag
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "bag"}})
                break
			elseif msgID == MSGID.SC_TITLE_ACTIVITE_REMIND_MSG then
				local len = event.data.msg:readShort()
				local data =  event.data.msg:readStringBytes(len)
				local heroData = json.decode(data)
				RefreshHeroInfo(heroData)
				

				len = event.data.msg:readShort()
				local data = event.data.msg:readStringBytes(len)
				dump(data)
				local Titledata = json.decode(data)
				RefreshTitlList(Titledata)
				
			elseif msgID == MSGID.SERVER_RESPONSE_ACTIVITYCANGET then ----有活动可领取
				local statu = event.data.msg:readChar() ----1 有东西可领，0 没东西可领
				local innerStatu = {}
				local _amount= event.data.msg:readChar() ---集合数量
				for i = 1,_amount do 
					innerStatu[i] = event.data.msg:readChar()
				end 
				print("活动红点推送")
				print_r(innerStatu)
				gameUser.setActivityStatus(innerStatu)	
				RedPointState[2].state = gameUser.getWonderfulPointDot()
				RedPointState[4].state = gameUser.getDailyPointDot()
				RedPointState[17].state = gameUser.getNewLoginRewardDot()
				gameUser.setLoginRewardState(statu)
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ACTIVITIESTAB_REDPOINT})
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "activity",visible = (statu == 1)}})	
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "jchd"}})	
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "newlgdl"}})
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "zxjl"}})
				-- 更新主界面排行奖励红点
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "rankReward",visible = (innerStatu[7] == 1)}})		
			elseif msgID == MSGID.SERVER_RESPONSE_CANCHOUKA_HERO or msgID == MSGID.SERVER_RESPONSE_CANCHOUKA_TOOLS then ----可免费抽英雄或者抽装备
                print("七星坛红点推送")
				if msgID == MSGID.SERVER_RESPONSE_CANCHOUKA_HERO then 
					gameUser.setFreeChouHero(1)
				elseif msgID == MSGID.SERVER_RESPONSE_CANCHOUKA_TOOLS then 
					gameUser.setFreeChouTools(1)
				end 
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "chouka",visible = true}})
			elseif msgID == MSGID.SERVER_RESPONSE_VIPREWARD then -----vip奖励
                print("vip领奖红点推送")
				gameUser._vipRewardStatu = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "vip",visible = true}})			
			elseif msgID == MSGID.SERVER_RESPONSE_FRIEND_GETREQUEST then -----获得请求好友信息 5005
				local _info = {charId = 1, charName = "", level = 1, templateId = 1, sMsgType = FriendMsgType.ADD_FRIEND}
				_info.charId = event.data.msg:readInt()
				local len = event.data.msg:readShort()
				_info.charName = event.data.msg:readStringBytes(len) 
				_info.level = event.data.msg:readShort()
				_info.templateId = event.data.msg:readInt()
				_info.campId = event.data.msg:readInt()
				HaoYouPublic.addNewMsgs(_info)
			elseif msgID == MSGID.SERVER_RESPONSE_FRIEND_DOREQUEST then -----同意请求好友信息 5016
				local _info = {charId = 1, charName = "", level = 1, templateId = 1, campId = 1, onLine = false, 
					flower = 0, duan = 0, power = 0, lastLogout = 0}
				_info.charId = event.data.msg:readInt()
				local len = event.data.msg:readShort()
				_info.charName = event.data.msg:readStringBytes(len) 
				_info.level = event.data.msg:readShort()
				_info.templateId = event.data.msg:readInt()
				_info.campId = event.data.msg:readInt()
				_info.onLine = event.data.msg:readChar() == 1 and true or false
				_info.flower = event.data.msg:readInt()
				_info.duan = event.data.msg:readInt()
				_info.power = event.data.msg:readInt()
				_info.lastLogout = event.data.msg:readDouble()
				HaoYouPublic.addData(_info)
			elseif msgID == MSGID.SERVER_RESPONSE_FRIEND_ONLINE then -----好友上线信息 5017
				local charId = event.data.msg:readInt()
				HaoYouPublic.freshFriendOnline(charId, true)
			elseif msgID == MSGID.SERVER_RESPONSE_FRIEND_SEND then -----好友赠送信息 5018
				local _info = {charId = 1, charName = "", level = 1, campId = 1, count = 0, sMsgType = FriendMsgType.SEND_FLOWER} 
				_info.charId = event.data.msg:readInt()
				local len = event.data.msg:readShort()
				_info.charName = event.data.msg:readStringBytes(len) 
				_info.campId = event.data.msg:readInt()
				_info.level = event.data.msg:readInt()
				_info.count = event.data.msg:readInt()
				HaoYouPublic.addNewMsgs(_info)
			elseif msgID == MSGID.SERVER_RESPONSE_FRIEND_FIGHT then -----切磋结果提醒 5019
				local _info = {charId = 1, charName = "", level = 1, templateId = 1, sMsgType = FriendMsgType.FIGHT_FRIEND , isWin = false}
				_info.charId = event.data.msg:readInt()
				local len = event.data.msg:readShort()
				_info.charName = event.data.msg:readStringBytes(len) 
				_info.campId = event.data.msg:readInt()
				_info.level = event.data.msg:readInt()
				_info.isWin = event.data.msg:readChar() == 1 and true or false
				HaoYouPublic.addNewMsgs(_info)
			elseif msgID == MSGID.SERVER_RESPONSE_FRIEND_OFFLINE then -----好友下线信息 5020
				local charId = event.data.msg:readInt()
				HaoYouPublic.freshFriendOnline(charId, false)
			elseif msgID == MSGID.SERVER_RESPONSE_FRIEND_DELETE then ------删除好友信息 5021
				local charId = event.data.msg:readInt()
				HaoYouPublic.removeDataById(charId)
			elseif msgID == MSGID.SERVER_RESPONSE_VIPOUTOFPOWER then -----vip过期提醒
                print("vip过期提醒推送")
				local preVIPLevel = event.data.msg:readChar() ------当前vip等级
				local nowVIPLevel = event.data.msg:readChar() ------降到的vip等级
				local goldRestExT = event.data.msg:readShort() -----银两剩余兑换次数
				local feicuiRestExT = event.data.msg:readShort() -----银两剩余兑换次数
				gameUser.setVip(tonumber(nowVIPLevel))
				gameUser.setGoldSurplusExchangeCount(tonumber(goldRestExT) or 0)
				gameUser.setFeicuiSurplusExchangeCount(tonumber(feicuiRestExT) or 0)
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
			elseif msgID == MSGID.SERVER_RESPONSE_OPENSERVERPACKAGE then ------开服奖励提醒 
    -- 			gameUser.setBigPackageGetting(1)
				-- if gameUser.isPlayerInGame() then 
				-- 	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "liucunPackage",visible = true}})
				-- end 
			elseif msgID == MSGID.SERVER_RESPONSE_LOGOUT then -----强制玩家下线
				local _typNum = event.data.msg:readByte()
				-- print("服务器强制下线的数据为：".._typNum)
				_typNum = tonumber(_typNum) or 0
				local isZuobi = _typNum == 1
				LayerManager.backToLoginLayer(isZuobi)	
            elseif msgID == MSGID.SERVER_RESPONSE_GUILDCHANGE then ----5025 公会状态变更
                print("工会状态变更推送")
            	local _guildId = event.data.msg:readShort()
            	gameUser.setGuildId(_guildId)
				local len = event.data.msg:readShort()
				local _guildName = event.data.msg:readStringBytes(len) 
            	gameUser.setGuildName(_guildName)
            	local _guildRole = event.data.msg:readByte()
            	gameUser.setGuildRole(_guildRole)
                local _maxTili = event.data.msg:readInt()
            	gameUser.setTiliMax(_maxTili)
            	
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDINFO})
        		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
        		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
            elseif msgID == MSGID.SERVER_RESPONSE_WORLDBOSSKILL then-- --5026世界boss击杀
    --         	local tab={}
    --         	tab.campid=event.data.msg:readChar()
    --         	local len = event.data.msg:readShort()
				-- tab.name = event.data.msg:readStringBytes(len)
				-- tab.rewardid=event.data.msg:readInt()
				-- XTHD.dispatchEvent({name = CUSTOM_EVENT.WORLDBOSS_KILL,data=tab})
            elseif msgID == MSGID.SERVER_RESPONSE_WORLDBOSSOVER then-- --5027世界boss结束
                print("世界boss结束推送")
            	local tab={}
            	tab.charid=event.data.msg:readInt()
				tab.campid=event.data.msg:readChar()
				local len = event.data.msg:readShort()
				tab.name = event.data.msg:readStringBytes(len)
				tab.rank=event.data.msg:readInt()
				gameUser._worldBossOver=1
				gameUser._worldBossOver_data=tab
				XTHD.dispatchEvent({name = CUSTOM_EVENT.WORLDBOSS_KILL})
            elseif msgID ==MSGID.SERVER_RESPONSE_WORLDBOSSHURT then   --世界boss血量推送
                print("世界boss血量推送")
            	local tab={}
            	tab.hurt=event.data.msg:readInt()
				XTHD.dispatchEvent({name = CUSTOM_EVENT.WORLDBOSS_HURT,data=tab})
            elseif msgID == MSGID.SERVER_RESPONSE_CAMPTIPS then ----阵营开战前10分钟提示
            	local time = event.data.msg:readShort() -----阵营开战时间 大于0 离阵营开战剩余时间（分钟） == 0 阵营战已开启 <0 阵营战已结束
                print("阵营战开启推送"..time)
				if time >= 10 then ----还有十分钟开启阵营战
					ZhongZuDatas._isCampWarStart = 0					
					XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_BATTLE_TIPSLAYER,data = "camp"})
            	end 
            elseif msgID == MSGID.SERVER_RESPONSE_CAMPRESULT then -----阵营战结果
                print("阵营战结果推送")
            	local _result = event.data.msg:readChar() ---1 光明谷 2 暗月岭 0 平局
            	
            	local len = event.data.msg:readShort()
            	local name = event.data.msg:readStringBytes(len) ------光明谷的第一名
            	local killAmount = event.data.msg:readShort() -----杀人数量

            	len = event.data.msg:readShort()
            	local name2 = event.data.msg:readStringBytes(len) ------暗月岭的第一名
            	local killAmount2 = event.data.msg:readShort() -----杀人数量

            	local selfRank = event.data.msg:readShort() ----自己的排名 -----可能是-1 表示没排行 
            	local selfKillAmount = event.data.msg:readShort() ----自己的杀人数

            	ZhongZuDatas:setCampWarLatestResult(_result)
            	local _tem = {result = _result,strong = {{name,killAmount},{name2,killAmount2}},selfRank = selfRank,selfnum = selfKillAmount}
				XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_CAMPWARRESULT_DIALOG,data = _tem})
        	elseif msgID == MSGID.SERVER_RESPONSE_MATCHING then
                print("修罗炼狱匹配推送")
        		local rivalData = {}
        		rivalData.charId = event.data.msg:readInt()
        		rivalData.name = event.data.msg:readStringBytes(event.data.msg:readShort())
        		rivalData.level = event.data.msg:readShort()
        		rivalData.templateId = event.data.msg:readInt()
        		rivalData.campId = event.data.msg:readInt()
        		rivalData.first = event.data.msg:readByte()
        		rivalData.time = event.data.msg:readByte()
        		XTHD.dispatchEvent({name = CUSTOM_EVENT.MATCHINGRIVAL,data = rivalData})
    		elseif msgID == MSGID.SERVER_RESPONSE_RIVALTEAM then
                print("修罗战对手信息推送推送")
    			local roleID = event.data.msg:readInt()
    			local heroSize = event.data.msg:readChar()
    			local heroList = {}
    			for i=1, heroSize do
    				heroList[#heroList+1] = {}
    				heroList[#heroList].heroID = event.data.msg:readInt()
    				heroList[#heroList].level = event.data.msg:readShort()
    				heroList[#heroList].star = event.data.msg:readChar()
    				heroList[#heroList].advance = event.data.msg:readChar()
    			end
    			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RIVAL_TEAM, data = {charId = roleID, list = heroList}})
			elseif msgID == MSGID.SERVER_RESPONSE_KICKOUTARENA then
                print("修罗战踢出对手推送")
				local id = event.data.msg:readInt()
				local leftTime = event.data.msg:readByte()
				XTHD.dispatchEvent({name = CUSTOM_EVENT.KICK_OUT_ARENA})
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_LEFT_TIME,data = leftTime})
			elseif msgID == MSGID.SERVER_RESPONSE_ESCORTTIPS then -- 5036,劫镖提醒
                print("劫镖提醒推送")
				local _info = {charId = 1, charName = "", level = 1, templateId = 1, sMsgType = FriendMsgType.ESCORT_FIGHT , isWin = false}
				_info.charId = event.data.msg:readInt()
				local len = event.data.msg:readShort()
				_info.charName = event.data.msg:readStringBytes(len) 
				_info.campId = event.data.msg:readInt()
				_info.level = event.data.msg:readInt()
				_info.isWin = event.data.msg:readChar() == 1 and true or false
				HaoYouPublic.addNewMsgs(_info)
			elseif msgID == MSGID.SERVER_RESPONSE_TIMEBATTLEOPEN then -----限时战开启提醒
				local _type = event.data.msg:readChar() -----(1:boss; 2: 帮派战;3 : 修罗战场 4：阵营战),
				local _statu = event.data.msg:readChar()------(状态  1 : 开启; 0 : 关闭)
				print("限时战开启提示的长连接数据,类型，状态：",_type,_statu)
				gameUser.setLimitBattle(_type,_statu)
				local isShow = true
				if _statu == 1 then ----战斗开始
					if _type == 1 then ---Boss
						for k,v in pairs(gameUser.getLimitBattle()) do ----查询当前是否还有其它限时战还未结束 
				            if v > 0 then 
				                if k > 1 then
				                	isShow = false
				                end
				                break
				            end 
				        end 
				        if isShow then
				        	XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_BATTLE_TIPSLAYER,data = "boss"})
				        end		
					elseif _type == 4 then ----阵营
						ZhongZuDatas._isCampWarStart = 1
						XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_BATTLE_TIPSLAYER,data = "campstart"})
						XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_CAMPSTART_BURNING,data = {show = true}})
					else -----不是Boss、阵营
						XTHD.dispatchEvent({name = CUSTOM_EVENT.DISPLAY_BATTLEBEGINS_TIP,data = {war = true,warIndex = _type}})						
					end 
				else -----战斗结束
					if _type == 4 then ----阵营
						ZhongZuDatas._isCampWarStart = -1					            		 
						XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_CAMPWAROVERED}) ----把还在阵营战里的人踢出来 ，	
						XTHD.dispatchEvent({name = CUSTOM_EVENT.CAMPWAR_OVERED}) ----阵营战结束
						XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_CAMPSTART_BURNING,data = {show = false}})										
					end 
					XTHD.dispatchEvent({name = CUSTOM_EVENT.DISPLAY_BATTLEBEGINS_TIP,data = {war = false}})
				end 
			elseif msgID == MSGID.SERVER_RESPONSE_SEVENDAYREDPOINT then ----7日活动红点控制  5038
				gameUser.setSevenDayRedPoint(1)
				print("7日狂欢活动红点推送")
				RedPointState[3].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "sevenDay"}})
			elseif msgID == MSGID.SERVER_RESPONSE_ARENASTARTRESULT then ----修罗战场选匹配上结果消息 5039
				XTHD.dispatchEvent({name = CUSTOM_EVENT.ENTER_RIVAL})
			elseif msgID == MSGID.SERVER_RESPONSE_ARENAQUITRESULT then ----修罗战场选取消匹配结果 5040
				XTHD.dispatchEvent({name = CUSTOM_EVENT.KICK_OUT_ARENA})
			elseif msgID == MSGID.SERVER_RESPONSE_ARENANOFIGHTER then ----修罗战场匹配不到合适的对手 5041
				XTHDTOAST(LANGUAGE_TIPS_WORDS256)
				------------多人副本
			elseif msgID == MSGID.SERVER_RESPONSE_MCCREATETEAMSU then 								----多人副本创建队伍成功
				local id = event.data.msg:readInt()
				XTHD.dispatchEvent({name = CUSTOM_EVENT.GO_MULTICOPY_PREPARE_LAYER,data = id})
			elseif msgID == MSGID.SERVER_RESPONSE_MCCAPTAINCHANGED then 							----多人副本队长变动
				local preCaptain = event.data.msg:readInt() ----先前的队长角色ID（角色ID即玩家ID）
				local nowCaptain = event.data.msg:readInt() -----现在的队长角色ID
    			XTHD.dispatchEvent({name = CUSTOM_EVENT.SWITCHCMULTICAPTAIN,data = {preCaptain = preCaptain,nowCaptain = nowCaptain}}) ----更换队长
			elseif msgID == MSGID.SERVER_RESPONSE_MCCMEMBERQUIT then								----多人副本成员离队
				local quitMemberID = event.data.msg:readInt() 
				XTHD.dispatchEvent({name = CUSTOM_EVENT.SOMEONEHASLEFT,data = quitMemberID})
			elseif msgID == MSGID.SERVER_RESPONSE_MCCEXCHANGEROLE then								----多人副本更换英雄
				local roleID = event.data.msg:readInt() ----玩家ID
				local heroID = event.data.msg:readInt() -----更换的英雄ID
				local fightVIM = event.data.msg:readInt() -----更换的英雄战力
				XTHD.dispatchEvent({name = CUSTOM_EVENT.ADDNEWMEMBERTOTEAM,data = {hasPortrait = true,roleID = roleID,heroID = heroID,fightVIM = fightVIM}})
			elseif msgID == MSGID.SERVER_RESPONSE_MCCNEWMEMBEJOIN then 								----多人副本有新成员加入
				local roleID = event.data.msg:readInt() ----玩家ID
				local len = event.data.msg:readShort()
				local name = event.data.msg:readStringBytes(len) --玩家名字
				XTHD.dispatchEvent({name = CUSTOM_EVENT.ADDNEWMEMBERTOTEAM,data = {hasPortrait = false,roleID = roleID,playerName = name}})
			elseif msgID == MSGID.SERVER_RESPONSE_MCCPREEMEMBERS then 								----多人副本原有成员列表
                print("多人副本成员列表推送")
				local ID = event.data.msg:readInt() -----当前进的副本ID（第一列的ID）
				local loop = event.data.msg:readChar()
				local teams = {}
				for i = 1,loop do
					teams[i] = {} 
					teams[i].roleID = event.data.msg:readInt() ----玩家ID
					local len = event.data.msg:readShort()
					teams[i].name = event.data.msg:readStringBytes(len) ---名字
					local isCaptain = event.data.msg:readChar() ----是否是队长
					teams[i].isCaptain = (isCaptain == 1)
					teams[i].heroID = event.data.msg:readInt() ----英雄ID
					teams[i].fightVim = event.data.msg:readInt() ----英雄战斗力
					teams[i].didPrepare = event.data.msg:readChar() ----当前玩家是否是准备状态 
				end 
				if DuoRenFuBenDatas.afterInvitedCall then 
					DuoRenFuBenDatas.afterInvitedCall({configID = ID,teams = teams})
					DuoRenFuBenDatas.afterInvitedCall = nil
				end 
				XTHD.dispatchEvent({name = CUSTOM_EVENT.GO_MULTICOPY_PREPARE_FROMTEAMLIST,data = {preTeam = teams,id = ID}})
			elseif msgID == MSGID.SERVER_RESPONSE_MCCTALK then										----多人副本喊话消息	5048
				local roleID = event.data.msg:readInt()
				local wordIndex = event.data.msg:readChar()
				XTHD.dispatchEvent({name = CUSTOM_EVENT.DISPLAY_PLAYER_SPEEK,data = {roleID = roleID,wordIndex = wordIndex}})				
			elseif msgID == MSGID.SERVER_RESPONSE_MCCINVITEFRIEND then								----多人副本好友邀请提醒	5049
				local _info = {charId = 1, charName = "", level = 1, templateId = 1, sMsgType = FriendMsgType.MULTIPLE_INVITE}
				local len = event.data.msg:readShort()
				_info.charName = event.data.msg:readStringBytes(len) 
				_info.teamId = event.data.msg:readInt()
				_info.stageId = event.data.msg:readShort()
				HaoYouPublic.addNewMsgs(_info)
			elseif msgID == MSGID.SERVER_RESPONSE_MCCREADY then										-----队友准备提醒	5050
				local roleID = event.data.msg:readInt()
				local statu = event.data.msg:readChar() -------1 准备，0取消准备
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESHPREPARESTATUS,data = {roleID = roleID,prepare = statu == 1}})
			elseif msgID == MSGID.SERVER_RESPONSE_MCCOPEN then										----多人副本开启提醒	5051
				XTHD.dispatchEvent({name = CUSTOM_EVENT.BATTLECANGETIN})
			elseif msgID == MSGID.SERVER_RESPONSE_PPRECHARGEOVER then ---- pp充值完成提醒-- 5052 	
                print("充值完成提醒推送")
				--pp充值完成提醒，这里添加相关处理
--				local callbackLua = XTHD.doPayFinish()
--				if callbackLua then
--					callbackLua()
--				end
			elseif msgID == MSGID.SERVER_RESPONSE_CASTELLANFIGHT then ----城主被抢提醒 5053
                print("城主被抢提醒推送")
				local _info = {charName = "", level = 1, sMsgType = FriendMsgType.CASTELLANFIGHT}
				local len = event.data.msg:readShort()
				_info.charName = event.data.msg:readStringBytes(len) --玩家名字
				_info.level = event.data.msg:readShort() --等级
				local len2 = event.data.msg:readShort()
				_info.cityName = event.data.msg:readStringBytes(len2) --玩家名字
				HaoYouPublic.addNewMsgs(_info)
			elseif msgID == MSGID.SERVER_RESPONSE_NEWCHATMSG then ----新的聊天消息头 5055
                print("新的聊天消息推送")
				local info = {}
				local len = event.data.msg:readShort()
				info.charName = event.data.msg:readStringBytes(len) or ""--玩家名字
				info.id = event.data.msg:readInt() or 1
				gameUser.setZhongjiangInfo(info)
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GONGXIFACAI})
			elseif msgID == MSGID.SERVER_RESPONSE_LUCKYLIST then   --幸运转盘幸运榜 5056  结构和5055一样
                print("转盘幸运榜推送")
                local info = {}
				local len = event.data.msg:readShort()
				info.charName = event.data.msg:readStringBytes(len) or ""--玩家名字
				info.id = event.data.msg:readInt() or 1
				-- print("幸运转盘幸运榜服务器返回的数据为：")
				-- print_r(info)
				local node = cc.Director:getInstance():getNotificationNode()	
				local announce = node:getChildByName("announcement")	
				local static = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = info.id})
				local playerName = info.charName
				local message = "幸运轮盘大奖降临！恭喜<color=#fea4fb >"..playerName.."</color>抽中了<color=#fff000 >"..static.name.."</color>x1,运气爆棚！"	
				local luckyData = {}
				luckyData.playerName = playerName
				luckyData.name = static.name
				luckyData.num = 1			
				gameUser.addLuckyListData(luckyData)  --保存幸运转盘的数据
				XTHDMarqueeNode:insertAData(message)
				if announce then 
					announce:run()
				end 
			elseif msgID == MSGID.SERVER_RESPONSE_DINGHAO then
				ISDINGHAO = true
				showDingHaoDialog()
			elseif msgID == MSGID.SC_ECHO_MSG then  --5060
				BEATCOUNTDOWN = 0
				-- local msg = event.data.msg:readInt() or 0
				-- print("服务器心跳响应：")
			elseif msgID == MSGID.SC_ACTIVITY_CZYL_MSG then  --5061
				print("充值有礼活动红点推送")
				RedPointState[1].state = 1
				RedPointState[23].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "jrkh"}})
			elseif msgID == MSGID.SC_ACTIVITY_XFHL_MSG then --5062
				print("消费好礼活动红点推送")
				RedPointState[24].state = 1
				RedPointState[1].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "jrkh"}})
			elseif msgID == MSGID.SC_ACTIVITY_HYYL_MSG then  --5063
				print("活跃有礼活动红点推送")
				RedPointState[5].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "hyyl"}})
			elseif msgID == MSGID.SC_ACTIVITY_TZJH_MSG then  --5064
				print("投资计划活动红点推送")
				RedPointState[6].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "tzjh"}})
			elseif msgID == MSGID.SC_ACTIVITY_XFYL_MSG then  --5065
				print("消费有礼活动红点推送")
				RedPointState[7].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "czdh"}})
			elseif msgID == MSGID.SC_ACTIVITY_BYDL_MSG then  --5066
				print("毕业典礼活动红点推送")
				RedPointState[9].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "bydl"}})
			elseif msgID == MSGID.SC_ACTIVITY_CZFL_MSG then  --5067
				print("充值返利活动红点推送")
				RedPointState[8].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "rchd"}})
			elseif msgID == MSGID.SC_ACTIVITY_XFFL_MSG then  --5068
				print("消费返利活动红点推送")
				RedPointState[8].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "rchd"}})
			elseif msgID == MSGID.SC_ACTIVITY_KCFL_MSG then  --5069
				print("开采返利活动红点推送")
				RedPointState[8].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "rchd"}})
			elseif msgID == MSGID.SC_ACTIVITY_ZMFL_MSG then  --5070
				print("招募返利活动红点推送")
				RedPointState[8].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "rchd"}})
			elseif msgID == MSGID.SC_ACTIVITY_SBFL_MSG then  --5071
				print("神兵返利活动红点推送")
				RedPointState[8].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "rchd"}})
			elseif msgID == MSGID.SC_ACTIVITY_SQFL_MSG then  --5072
				print("神器返利活动红点推送")
				RedPointState[8].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "rchd"}})
			elseif msgID == MSGID.SC_ACTIVITY_DLYL_MSG then  --5073
				print("登录有礼活动红点推送")
				RedPointState[8].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "rchd"}})
			elseif msgID == MSGID.SC_ACTIVITY_HS_MSG then  --5074
				print("回收红点推送")
				RedPointState[14].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "hs"}})
			elseif msgID == MSGID.SC_ACTIVITY_BG_MSG then  --5075
				print("闭关红点推送")
				RedPointState[11].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "bg"}})
			elseif msgID == MSGID.SC_ACTIVITY_CLDH_MSG then  --5077
				print("材料兑换红点推送")
				RedPointState[1].state = 1
				RedPointState[25].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "jrkh"}})
			elseif msgID == MSGID.SC_ACTIVITY_SZDH_MSG then  --5078
				print("神装兑换红点推送")
				RedPointState[26].state = 1
				RedPointState[1].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "jrkh"}})
			elseif msgID == MSGID.SC_ACTIVITY_YXDH_MSG then  --5079
				print("英雄兑换红点推送")
				RedPointState[27].state = 1
				RedPointState[1].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "jrkh"}})
			elseif msgID == MSGID.SC_ACTIVITY_XYDH_MSG then  --5080
				print("稀有兑换红点推送")
				RedPointState[28].state = 1
				RedPointState[1].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "jrkh"}})
			elseif msgID == MSGID.SC_ACTIVITY_CZJJ_MSG then
				print("成长基金红点推送")
				RedPointState[19].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "bfyl"}})
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ACTIVITY_BFYL})
			elseif msgID == MSGID.SC_ACTIVITY_SCSC_MSG then
				print("三次首冲红点推送")
				RedPointState[22].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "scsc"}})
			elseif msgID ==	MSGID.SC_ACTIVITY_SCTG_MSG then
				print("首冲团购红点推送")
				RedPointState[20].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "bfyl"}})
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ACTIVITY_BFYL})
			elseif msgID == MSGID.SC_ACTIVITY_YKZZK_MSG then
				print("月卡至尊卡红点推送")
				RedPointState[18].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "monthandzcard"}})
			end
		until true
	end 
end

function MsgCenter:getInstance( )
	if not MsgCenter.didInit then 
		local ip = gameUser.getSocketIP()
		local port = gameUser.getSocketPort()
		if ip == 0 or port == 0 or (type(ip) == "string" and #ip <= 1) or (type(port) == "string" and #port <= 1) then 
			return self
		end		
		socket = SocketTCP.new(ip,port)
	    XTHD.addEventListener({name = SocketTCP.EVENT_CONNECTED , callback = function(event) 
	    	if MsgCenter.lastMsg then --重新发送最近一条消息
	    		self:msgSend(MsgCenter.lastMsg)
	    		MsgCenter.lastMsg = nil
	    	end 
			self:showOrHideWaitting()
			print("成功连接到socket服务器")
			local node = cc.Director:getInstance():getNotificationNode()
			node:stopActionByTag(10000)
			local scene = cc.Director:getInstance():getRunningScene()
		    if scene and scene:getChildByName("webReconnect2Dialog") then 
		        scene:removeChildByName("webReconnect2Dialog")
		    end 
		    CONNECTTIME = 30

			BEATCOUNTDOWN = 0
			node:stopActionByTag(9999)
		    schedule(node, function(dt)
		        local object = SocketSend:getInstance()
		        if object then 
		            object:writeInt(5)         
		            object:send(MsgCenter.MSGID.SC_BEAT_MSG)
		            if BEATCOUNTDOWN >= 3 then
		                showDisconnectTip()
		                node:stopActionByTag(9999)
		                return
		            end
		            BEATCOUNTDOWN = BEATCOUNTDOWN + 1
		        end 
		    end,1,9999)
	    end})
	    XTHD.addEventListener({name = SocketTCP.EVENT_CLOSED , callback = function(event) 
	    	--如果是顶号则return
	    	if ISDINGHAO == true then
	    		ISDINGHAO = false
	    		return 
	    	end
	        print("断开与socket服务器的连接,正常尝试重新连接")
	        if event.data == true then 
	        	self:doReconnect()
	        end 
	    end})
	    XTHD.addEventListener({name = SocketTCP.EVENT_CONNECT_FAILURE , callback = function(event) 
	    	if event.data == true then 
	    		self:doReconnect()
	    	end 
	    end})
		XTHD.addEventListener({ name = SocketTCP.EVENT_DATA , callback = onMsgRecive })
		
		socket:connect()
		MsgCenter.didInit = true
	end
	return self
end

--[[
@obj uuid
]]
function MsgCenter:sendLoginMsg(obj)
	if socket and obj then 
		local data = ByteArray.new(ByteArray.ENDIAN_BIG)	
		local len = HEADERLENGTH + 2 + string.len(obj)
		data:writeShort(len)			
		data:writeShort(MsgCenter.MsgType.CLIENT_REQUEST_LOGIN)

		data:writeShort(string.len(obj))
		data:writeStringBytes(obj)
		
		socket:send(data:getPack())
	end 
end
--[[
obj = {type,data} 
@type 	message type id,such as MSGID.CLIENT_REQUEST_LOGIN
@data 	what you want to send(message body)
]]
function MsgCenter:msgSend( obj )
	if not socket or not socket.isConnected then 	
		print("------------------重连中------------")	
		self:doReconnect()
		MsgCenter.lastMsg = obj
	elseif MsgCenter.isSocketSafe and obj then
		socket:send(obj:getPack())
	else
		print("wrong uuid")
	end 
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function MsgCenter:doReconnect( )
	local ip = gameUser.getSocketIP()
	local port = gameUser.getSocketPort()
	if ip == 0 or port == 0 or (type(ip) == "string" and #ip <= 1) or (type(port) == "string" and #port <= 1) then 
		return
	else
		if socket then 
			local statu = socket:_connect()
			if not statu then 			
				print("the socket connect status",statu)
				-- self:showOrHideWaitting(true,true)
				self:pingServer()
			else 
				print("the socket connet perfectly")
				socket:connect()
			end 
		else
			print("the socket is nil")
		end 
	end		
end

function MsgCenter:pingServer( )----重连接socket之前试探当前用户是否有效
	local count = 0
	local successCount = 0
	local function ping( )
	    count = count + 1
		if count > 3 and MsgCenter.pingSchedule ~= 0 then 
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(MsgCenter.pingSchedule)
			MsgCenter.pingSchedule = 0
			count = 0
			successCount = 0
			self:showOrHideWaitting()
			return 
		end 
		XTHDHttp:requestAsyncInGameWithParams({
	        modules = "pingServer?",
	        successCallback = function(data)	     
	            if tonumber(data.result) == 0 and tonumber(data.state) == 1 then
	            	successCount = successCount + 1
	           		print("ping server success times",successCount)
	            	if successCount >= 2 and socket then -----如果ping的数据成功次数大于2可连接
						socket:close()
						socket:setReconnTime(10.0) -----如果socket没有重连成功，则10秒重连一次共连6次，如果都失败则暂时停止连接
						socket:setConnFailTime(60.0)
			        	socket:connect()
			        	if MsgCenter.pingSchedule ~= 0 then 
							cc.Director:getInstance():getScheduler():unscheduleScriptEntry(MsgCenter.pingSchedule)
							MsgCenter.pingSchedule = 0
							count = 0
							successCount = 0
							self:showOrHideWaitting()
						end 
	            	end 
	           	elseif tonumber(data.result) == 1009 or tonumber(data.result) == 1026 then -----账号在其它地方登录 (uuid失效)
		        	if MsgCenter.pingSchedule ~= 0 then 
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(MsgCenter.pingSchedule)
						MsgCenter.pingSchedule = 0
						count = 0
						successCount = 0
						self:showOrHideWaitting()
					end 
	            end
	        end,
	        failedCallback = function()	        
				self:showOrHideWaitting()
	        end,--失败回调
        	loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	end
	if MsgCenter.pingSchedule == 0 then 
		MsgCenter.pingSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(ping,1.0,false)		
	end 
end

function MsgCenter:showOrHideWaitting( isShow,isMode,target )
	local node = cc.Director:getInstance():getRunningScene()
	if node and not isShow then 		  
		node:removeChildByName("socketWait")
	else 
		local _circle = DengLuCircleLayer:create()
		if node and not node:getChildByName("socketWait") then 
			if isMode then 
				local _modeLayer = YinDao:create()
				local color = cc.LayerColor:create(cc.c4b(0,0,0,50),winSize.width,winSize.height)
				_modeLayer:addChild(color)
				color:addChild(_circle)

				node:addChild(_modeLayer,10)
				_modeLayer:setName("socketWait")
			else 
				local _layer = cc.Layer:create()
				node:addChild(_layer)
				_layer:addChild(_circle)
				-- _circle:setName("socketWait")
				_layer:setName("socketWait")
			end 
		end 
	end 
end

function MsgCenter:reset( )
	local node = cc.Director:getInstance():getNotificationNode() 
	if node then
	    node:removeChildByName("announcement")
	end
	self:showOrHideWaitting()
	MsgCenter.didInit = false	
	MsgCenter.lastMsg = nil
	SocketSend.instance = nil
    gameUser._socketLoginTime = 0
    gameUser._isInGame = false----玩家退出游戏
    gameUser.setLimitBattle(0)
	LiaoTianDatas.reset()
	XTHD.removeEventListener(SocketTCP.EVENT_CONNECTED)
	XTHD.removeEventListener(SocketTCP.EVENT_CLOSED)
	XTHD.removeEventListener(SocketTCP.EVENT_CONNECT_FAILURE)
	XTHD.removeEventListener(SocketTCP.EVENT_DATA)
	if socket then 
		socket:close()
		socket:setReconnTime(0.5)
		socket:setConnFailTime(3)
		socket = nil
	end 
end