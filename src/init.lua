--[[
	在这个地方进行文件的引用，这样可以将耦合做到最低
	200	生命 	300	命中(%)			400	级别
	201	物理攻击 	301	闪避(%)			401	当前hp
	202	物理防御	302	暴击(%)			402	银币
	203	法术攻击	303	暴击倍率(%) 		403	元宝
	204	法术防御	304	抗暴击(%)			404	当前状态
				305	伤害减免(%)		405	绑定状态
				306	伤害穿透(%)		406	VIP等级
				307	物理攻击减免(%)	407	战力
				308	物理攻击穿透(%)	408	称号id
				309	法术攻击减免(%)	409	活跃度
				310	法术攻击穿透(%)	410	当前体力
				311	吸血(%)			411	最大体力
				312	治疗加成(%)		412	购买体力次数
				313	被治疗加成(%)		413	当前经验值
				314	怒气消耗减免(%)	414	最大经验值
				315	生命恢复			415	升星 等级 
				316	怒气恢复 			416	品阶 等级
									417	剩余技能点
									418	翡翠
									419	精力
									420	竞技场掠夺的总翡翠
									421	竞技场掠夺的总银币
									422	竞技场掠夺的总次数
									423	种族id
									424	远征次数
									425	货币兑换次数 
									426	荣誉值
									427	绿魂石
									428	蓝魂石
									429	紫魂石
									430	赤魂石
									431	神石
									432	帮派贡献
									433	每天增加的势力点数
									434	累计增加的势力点数
									435	膜拜 次数

200   hp
201   physicalattack
202   physicaldefence
203   manaattack
204   manadefence
300   hit
301   dodge
302   crit
303   crittimes
304   anticrit
305   antiattack
306   attackbreak
307   antiphysicalattack
308   physicalattackbreak
309   antimanaattack
310   manaattackbreak
311   suckblood
312   heal
313   behealed
314   antiangercost
315   hprecover
316   angerrecover
]]
--[[这里的初始化顺序不能乱]]
json = require "cjson"
json.encode_sparse_array(true)
--hezhitao  began
requires("src/fsgl/GameHelper.lua")
--   end

requires("src/config.lua")
requires("src/fsgl/GameKey.lua")
requires("src/fsgl/GameEventName.lua")
requires "src/fsgl/language/init.lua"
requires "src/cocos/init.lua"
requires "src/utils/Init.lua"
requires("src/framework/init.lua")
requires("src/fsgl/network/init.lua")

------------------------------------------------------------------------------------------
--added by LITAO
requires("src/fsgl/network/socket/MsgCenter.lua")
------------------------------------------------------------------------------------------

requires("src/fsgl/manager/Init.lua")
requires("src/fsgl/db/init.lua")--数据库
requires("src/fsgl/data/init.lua")
-- requires("src/fsgl/staticdata/filenames.lua")
requires("src/fsgl/layer/common/init.lua") --yanyuling 0314
requires("src/gui/init.lua")
requires("src/fsgl/GameImages.lua")
requires("src/fsgl/GameResource.lua")
requires("src/fsgl/item/init.lua")
requires("src/fsgl/layer/LiaoTian/LiaoTianDatas.lua")
requires("src/fsgl/GameNickname.lua")
requires("src/fsgl/layer/ZhongZu/ZhongZuDatas.lua")
requires("src/utils/RichTextReader.lua")
requires("src/utils/FileReader.lua")
requires("src/fsgl/layer/YinDao/YinDaoLayer.lua")
requires("src/fsgl/layer/YinDao/YinDaoMarg.lua")
requires("src/fsgl/layer/YinDao/FunctionYinDao.lua")
requires("src/fsgl/layer/HaoYou/HaoYouPublic.lua")
requires("src/fsgl/layer/XuanShangRenWu/XuanShangRenWuData.lua")
requires("src/fsgl/layer/BangPai/BangPaiFengZhuangShuJu.lua")
requires("src/fsgl/layer/YouJian/YouJiangData.lua")
requires("src/fsgl/staticdata/RedPointState.lua")
-- requires("src/fsgl/layer/zhenqi_world/zhenqiData.lua") 


requires("src/fsgl/GameFuncs.lua")
requires("src/fsgl/action/init.lua")

requires("src/fsgl/battle/init.lua")
requires("src/fsgl/layer/YinDaoJieMian/init.lua")

------------------------------载入本地静态数据------------
-- for k,v in pairs(GameFileNames) do 
-- 	requires("src/fsgl/staticdata/"..v..".lua") ----载入登录小提示
-- end 
-- requires("src/fsgl/staticdata/GuidanceNotes.lua")----载入登录小提示
------------------------------------------------------------
ZhuChengMenuLayer = nil
isInTeam = false
pDirector = cc.Director:getInstance();
-- 屏幕size, width, height
winSize = pDirector:getWinSize();
winWidth = winSize.width;
winHeight = winSize.height;

frameSize = pDirector:getOpenGLView():getFrameSize();
frameWidth = frameSize.width;
frameHeight = frameSize.height;
screenRadio=0
if frameWidth>frameHeight then
	screenRadio=frameWidth/frameHeight
else
	screenRadio=frameHeight/frameWidth
end

ArenaGuideOSTime = os.time() ----系统每隔半小时监测，提示玩家进入竞技场


-- 英雄的类别: 玩家/敌人
HeroType = {};
HeroType.kHeroType_None = 0;
HeroType.kHeroType_Enemy = 1;
HeroType.kHeroType_Player = 2;
HeroType.kHeroType_Count = 3;

SCENEEXIST = {
	HEROLAYER = false,
	HEROINFOLAYER = false,
	STAGECHAPTER = false,
}

--关于前中后排的判断
--前排：<=250
IntervalBeforeAndMiddle = 250
--中排：>250 && <=400
IntervalMiddleAndAfter = 300
--后排：>400

-- 用来查看目前英雄的状态
HeroStatus = {};
HeroStatus.kHeroStatusIdle      = "idle";
HeroStatus.kHeroStatusRun       = "run";
HeroStatus.kHeroStatusAtkIng    = "atkIng";
HeroStatus.kHeroStatusSortIng	= "sortingPos";
HeroStatus.kHeroStatusAtk       = "atk";
HeroStatus.kHeroStatusAtk0      = "atk0";
HeroStatus.kHeroStatusAtk1      = "atk1";
HeroStatus.kHeroStatusAtk2      = "atk2";
HeroStatus.kHeroStatusAtk3      = "atk3";
HeroStatus.kHeroStatusAtkd      = "atkd";
HeroStatus.kHeroStatusWin       = "win";
HeroStatus.kHeroStatusDeath     = "death";
HeroStatus.kHeroStatusNext      = "next";


SKILL = {};
SKILL["talent"] = "talent";
SKILL["skillid"] = "skillid";
SKILL["skillid0"] = "skillid0";
SKILL["skillid1"] = "skillid1";
SKILL["skillid2"] = "skillid2";
SKILL["skillid3"] = "skillid3";


-- 集中定义动画的名字这样以后好修改
action_Idle     = "idle";
action_Run      = "run";
action_Atk0     = "atk0";   -- 大招
action_Atk1     = "atk1";   -- 技能1
action_Atk2     = "atk2";   -- 技能2
action_Atk3     = "atk3";   -- 技能三
action_Atk      = "atk";    -- 普攻
action_Atkd     = "atkd";
action_Death    = "death";
action_Win      = "win";

--[[
/** 玩家和怪物战斗 */
PVE(0),
/** 竞技场挑战 */
BattleType.PVP_CHALLENGE(1),
/** 精英副本  */
ELITE_PVE(2),
/** 神兽副本  */
GODBEASE_PVE(3),
/** 种族pvp  */
CAMP_PVP(4);
]]
BattleType = {}
BattleType.PVE = 0 -- 玩家和怪物战斗
BattleType.PVP_CHALLENGE = 1 -- 竞技场挑战掠夺
BattleType.ELITE_PVE = 2 -- 精英副本
BattleType.GODBEASE_PVE = 3 -- 神器副本
BattleType.CAMP_PVP 	= 4--种族pvp  战斗
BattleType.GOLD_COPY_PVE = 5 --银两副本
BattleType.JADITE_COPY_PVE = 6  --试炼之塔
BattleType.EQUIP_PVE = 7 -- 装备副本
BattleType.PVP_LADDER=8 --排位赛
BattleType.PVP_FRIEND=9 --好友切磋
BattleType.OFFERREWARD_PVE=10 --悬赏任务
BattleType.WORLDBOSS_PVE=11 --世界Boss
BattleType.PVP_CUTGOODS=12 --截镖
BattleType.PVP_SHURA=13 --修罗战场
BattleType.PVP_GUILDFIGHT=14 --帮派战场
BattleType.MULTICOPY_FIGHT = 15 ----多人副本开战
BattleType.GUILD_BOSS_PVE = 16 ----帮派Boss开战
BattleType.CASTELLAN_FIGHT = 17 -----种族城主争霸
BattleType.CAMP_TEAMCOMPARE = 18 ------种族队伍切磋
BattleType.ZHENQI_FIGHT_ROB = 19 --真气世界抢夺
BattleType.ZHENQI_FIGHT_OCCUPY = 20 --真气世界占领
BattleType.DIFFCULTY_COPY = 21 --恶运副本

BattleType.SINGLECHALLENGE = 23 --单挑之王
BattleType.SERVANT_PVE = 24  --登界游方

BattleType.CAMP_DEFENCE = 100 -- 种族pvp 设置防守队伍
BattleType.PVP_DEFENCE = 101 -- pvp 设置防守队伍
BattleType.PVP_LADDER_DEFENCE = 102 --排位赛防守队伍
BattleType.PVP_DART_DEFENCE = 103 --通缉防守队伍
BattleType.GUILDWAR_TEAM = 104 --帮派战队伍
BattleType.MULTICOPY_DEFENCE = 105 -----多人副本防守
BattleType.ZHENQI_DEFENCE = 106 --真气世界防守


-- BattleType.PVP = "pvp"
-- BattleType.GODBEASE_PVE ="mathical_animals"
---------------------------------------------------------------------
--注册的监听事件
CUSTOM_EVENT={}
CUSTOM_EVENT.REFRESH_TOP_INFO 						= "refresh_top_info" 						--刷新界面顶部条信息,
CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO 					= "refresh_maincity_top_info" 			--刷新界面顶部条信息,
CUSTOM_EVENT.REFRESH_MAINCITY_INFO 					= "refresh_maincity_info" 			--刷新主城界面信息,
CUSTOM_EVENT.REFRESH_SKILLPOINT 					= "refresh_skillpoint" 					--技能点
CUSTOM_EVENT.REFRESH_PVP_TEAMINFO 					= "refresh_pvp_teaminfo" 				--PVP设置防守队伍信息，刷新
CUSTOM_EVENT.REFRESH_CAMP_MAINLAYER 				= "refresh_camp_mainLayerData" 		--刷新种族主面板的数据 
CUSTOM_EVENT.REFRESH_CITY_BUILDINGS 				= "refresh_city_buildings" 			--刷新主城建筑数据
CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT 				= "refresh_red_dot_notification" 	---小红点功能提示
CUSTOM_EVENT.REFRESH_FUNCTION_REDPOINT 				= "refresh_function_redpoint" 	--英雄界面的小红点判断
CUSTOM_EVENT.GOTO_SPECIFIEDBUILDING 				= "goto_specified_building" 		--去往主城的某个指定建筑
CUSTOM_EVENT.REFRESH_RED_POINT 						= "refresh_mail_red_point"  				--刷新邮件中小红点
-- CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER = "refresh_dropwayBack_dataAndlayer"  	--刷新英雄数据和界面（在跳转到其他界面时用到）
CUSTOM_EVENT.REFRESH_VIP_MSG 						= "refresh_vip_msg"   						--充值成功后，刷新vip界面vip信息
CUSTOM_EVENT.REFRESH_HELP_DATA 						= "refresh_help_data" 					--刷新帮助界面的数据
CUSTOM_EVENT.REFRESH_COSTMONEY_STATE 				= "refresh_costmoney_state" 		--刷新界面中的翡翠，银两的状态（不足需求数量，label变红色，数量充足变为白色）
CUSTOM_EVENT.REFRESH_EQUIPCOPY 						= "refresh_equipcopy" 					--刷新装备副本界面
CUSTOM_EVENT.REFRESH_TASKLIST 						= "refresh_tasklist"
CUSTOM_EVENT.REFRESH_TEAM_SETTING_LAYER 			= "refresh_team_setting_layer"
CUSTOM_EVENT.REFRESH_PVP_MAIN_LAYER 				= "refresh_pvp_main_layer"
CUSTOM_EVENT.REFRESH_PVP_LADDER_LAYER 				= "refresh_pvp_ladder_layer"
CUSTOM_EVENT.REFRESH_GODBEAST_CHAPTER 				= "refresh_godbeast_chapter"
CUSTOM_EVENT.REFRESH_CAMP_SELFCITIES 				= "refresh_camp_selfcities"		----更新种族的自己的城市 
CUSTOM_EVENT.GO_RETURN_SAINT 						= "go_return_saint"						----返回神兽副本主页 
CUSTOM_EVENT.REFRESH_FRIEND_LIST 					= "refresh_friend_list"				----刷新好友列表控制 
CUSTOM_EVENT.REFRESH_FRIEND_ADDLIST 				= "refresh_friend_addlist"			----刷新添加好友列表控制 
CUSTOM_EVENT.REFRESH_FRIEND_TOPINFO 				= "refresh_friend_topinfo"			----刷新好友主界面头信息 
CUSTOM_EVENT.REFRESH_FRIEND_TALKLIST 				= "refresh_friend_talklist"		----刷新好友聊天界面 
CUSTOM_EVENT.REFRESH_FRIEND_NEWMSG 					= "refresh_friend_newmsg"			----刷新新消息列表 
CUSTOM_EVENT.UPDATE_ACTIVITYMENUS 					= "update_activities_menus"   		------更新活动按钮们（显示不显示，如开服礼包 ）
CUSTOM_EVENT.SHOW_CHATROOM_CHANNEL_REDDOT 			= "update_chatroom_channel_reddot"   			------显示在聊天室的聊天频道的红点
CUSTOM_EVENT.SHOW_CHAT_REDDOT_AT_CAMP 				= "show_chat_redDot_at_camp"   	------刷新聊天在种族里的红点 
CUSTOM_EVENT.ISDISPLAY_CAMP_CHATBUTTON 				= "showOrDisplayChatButton"   	------显示或者隐藏种族里的聊天按钮
CUSTOM_EVENT.REFRESH_ITEMDROP_HASNUMBER 			= "refresh_itemdrop_hasnumber"  ------刷新道具掉落途径框的数量

CUSTOM_EVENT.ENTER_RIVAL 							= "enter_rival" --进入修罗战场匹配
CUSTOM_EVENT.MATCHINGRIVAL 							= "mathing_rival" --修罗战场匹配对手
CUSTOM_EVENT.REFRESH_RIVAL_TEAM 					= "refresh_rival_team" --刷新修罗战场对手英雄
CUSTOM_EVENT.REFRESH_ESCORT_LAYER 					= "refresh_escort_layer" --刷新劫镖页面
CUSTOM_EVENT.REFRESH_WIN_POINT 						= "refresh_win_point" --刷新修罗战场胜点
CUSTOM_EVENT.REFRESH_LEFT_TIME 						= "refresh_left_time" --刷新修罗战场剩余次数
CUSTOM_EVENT.KICK_OUT_ARENA 						= "kick_out_arena" --踢出竞技场选人
CUSTOM_EVENT.REFRESH_ESCORT_TIME 					= "refresh_escort_time" --刷新劫镖次数

CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK 		= "refresh_uianddata_dropturnback"  		------通过掉落途径跳转后，刷新跳转前界面的UI和数据
CUSTOM_EVENT.REFRESH_GUILDINFO 						= "refresh_guildInfo" -- 刷新公会状态
CUSTOM_EVENT.REFRESH_ACTIVITIESTAB_REDPOINT 		= "refresh_activitiestab_redpoint" 			-- 刷新活动里面的tab上的红点
CUSTOM_EVENT.REFRESH_GUILDMAIN_INFO 				= "refresh_guildmain_info" 			-- 刷新帮派信息
CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST 				= "refresh_guildmain_list" 			-- 刷新帮派成员列表
CUSTOM_EVENT.RELEASE_MAINCITYBACK 					= "release_maincityback" 			-- 释放主城资源
CUSTOM_EVENT.CAMPWAR_OVERED 						= "camp_war_over" 			-- 种族战结束 
CUSTOM_EVENT.DISPLAY_BATTLEBEGINS_TIP 				= "display_battle_begin_tips" ----在主城显示在如种族战、世界boss等活动战开启的时候的快捷入口
CUSTOM_EVENT.SHOW_BATTLE_TIPSLAYER 					= "show_battle_tipslayer" ----当有新战斗快要开启的时候，显示提示页
CUSTOM_EVENT.SHOW_CAMPSTART_BURNING 				= "show_camp_burning" ----当种族战开启的时候，显示燃烧的窗口
CUSTOM_EVENT.SHOW_CAMPWARRESULT_DIALOG 				= "show_camp_war_resultDialog" ----显示当种族战结束的时候的对话框
CUSTOM_EVENT.SHOW_CAMPWAROVERED 					= "show_tip_campwarover" ----当种族战别人正在打就完，提示后弹出
CUSTOM_EVENT.REFRESH_CAMPBASE 						= "refresh_campbase_info" ----请求种族的基础数据 
CUSTOM_EVENT.REFRESH_BUILDINFO_AFTERLEVELUP 		= "refresh_buildInfo_afterLevelup" ----在建筑升级倒计时完了之后刷新建筑信息
CUSTOM_EVENT.REFRESH_FUNCTION_BTNSHOW 				= "refresh_function_btnShow" ------刷新主城里功能按钮的显示状态
CUSTOM_EVENT.REFRESH_CASTELLEN_AFTER_BATTLE 		= "refresh_castellen_after_battle" ------在城主争夺战结束之后刷新城主信息
CUSTOM_EVENT.REFRESH_NEWFUNCTIONOPEN_TIP 			= "refresh_newFunctionOpen_tip" -----刷新城主左上角的新功能开启提醒
CUSTOM_EVENT.REFRESH_ONLINEREWARD                   = "refresh_onlinereward"     --刷新在线奖励时间
CUSTOM_EVENT.REFRESH_PLAYERPOWER                    = "refresh_playerpower"     --刷新玩家战力
------多人副本
CUSTOM_EVENT.REFRESH_MULTICOPY_AFTERCHOOSE 			= "refresh_multiCopy_afterChoose" ------在多人副本选择好人了之后刷选到的英雄 
CUSTOM_EVENT.GO_MULTICOPY_PREPARE_LAYER 			= "go_multicopy_prepare_layer" ------前往多人副本准备页面
CUSTOM_EVENT.REFRESH_MULTICOPY_PREPAREHERO 			= "refresh_multiCopy_prepareHero" ------当玩家在多人副本准备页面换角色的时候，刷新重新设置的角色
CUSTOM_EVENT.REFRESH_MULTICOPY_TEAMS 				= "refresh_multiCopy_teams" ------刷新当前副本的队伍
CUSTOM_EVENT.GO_MULTICOPY_PREPARE_FROMTEAMLIST 		= "go_multicopy_prepare_layer_fromTeamList" ------在玩家加入某个队伍成功之后，从队长列表面前往多人副本准备页面
CUSTOM_EVENT.ADDNEWMEMBERTOTEAM 					= "add_new_member_to_team" -----有新玩家加入
CUSTOM_EVENT.SOMEONEHASLEFT 						= "multiCopy_someone_hasLeft" -----踢出某个玩家,或者某个玩家离队
CUSTOM_EVENT.SWITCHCMULTICAPTAIN 					= "multiCopy_switchCaptain" -----更换队长
CUSTOM_EVENT.REFRESHPREPARESTATUS 					= "multiCopy_refreshPrepareStatus" ------刷新玩家的准备状态 
CUSTOM_EVENT.BATTLECANGETIN 						= "multiCopy_battleCanGetIn" ------战斗可开启（每个队友都进战斗）
CUSTOM_EVENT.DISPLAY_PLAYER_SPEEK 					= "multiCopy_display_player_speekWord" ------显示玩家在准备页面的k喊话
CUSTOM_EVENT.ASYNCSERVER_AFTERBATTLE 				= "asyncServer_afterBattle_overed" -----在多人副本战斗结束后，刷新多人副本主界面的数据


CUSTOM_EVENT.WORLDBOSS_KILL 						= "worldboss_kill_info"
CUSTOM_EVENT.WORLDBOSS_OVER 						= "worldboss_over_info"
CUSTOM_EVENT.WORLDBOSS_HURT 						= "worldboss_hurt_info"
CUSTOM_EVENT.REFRESH_RECHARGE_MSG 					= "refresh_recharge_msg"   						--充值成功后，刷新充值活动界面信息

CUSTOM_EVENT.REFRESH_BIBLE 							= "refresh_bible" -- 刷新宝典
CUSTOM_EVENT.REFRESH_GONGXIFACAI                    = "refresh_gongxifacai" --刷新恭喜发财
CUSTOM_EVENT.REFRESH_HERODATABYID 					= "refresh_herodatabyid" --刷新经脉界面
CUSTOM_EVENT.REFRESH_SINGLECHALLENGE                = "refresh_singlechallenge"  --刷新单挑之王
CUSTOM_EVENT.REFRESH_GUILDRANKLIST					= "refresh_guildranklist" --刷新帮派捐献排行榜
CUSTOM_EVENT.REFRESH_GUILDBATTLEGROUP				= "refresh_guildbattlegroup"--刷新帮派战队伍信息
CUSTOM_EVENT.REFRESH_ACTIVITY_BFYL					= "refresh_activity_bfyl" --刷新缤纷有礼红点
CUSTOM_EVENT.REFRESH_QIXINGTAN_NUMLABLE				= "refresh_qixingtan_numlable"--刷新七星潭界面召唤师和天星石数量

function CUSTOM_EVENT_REFRESH_TOP_INFO(_sockettime)
	return CUSTOM_EVENT.REFRESH_TOP_INFO .. "_" .. _sockettime
end


ChapterType = {}
ChapterType.Normal = "normal_chapter" --普通副本
ChapterType.ELite = "elite_chapter" --精英副本
ChapterType.Diffculty = "diffculty_chapter" --恶魔副本


math.randomseed(os.clock())
gameData.firstInit()
local _logintips = gameData.getDataFromCSV("GuidanceNotes")
EsotericaIndex = math.random(#_logintips)------小秘籍的索引
EsotericaTime = 5.0

zctech = zctech or {}

--hezhitao   2015.09.15
GAME_MODEL_TYPE = "release"
-- GAME_MODEL_TYPE = "debug"
GAME_PAY_URL = "http://192.168.170.119:8092/pay/"
PAYURL_RELEASE = "http://123.59.58.109:8092/pay/"    --外网，线上的
PAYURL_DEBUG = "http://192.168.170.119:8092/pay/"      --内网，测试的
if GAME_MODEL_TYPE ~= nil and GAME_MODEL_TYPE == "release" then
	GAME_PAY_URL = PAYURL_RELEASE
else
	GAME_PAY_URL = PAYURL_DEBUG
end


--hezhitao   2015.06.05
-- requires "src/plugin/JavaBridge.lua"
-- requires "src/plugin/OCBridge.lua"
-- requires "src/plugin/LuaBridgeTool.lua"
requires("src/plugin/ChargeIOSPay.lua")
requires("src/plugin/ChargeResources.lua")
requires("src/plugin/Config.lua")
requires("src/plugin/JavaBridge.lua")
requires("src/plugin/OCBridge.lua")