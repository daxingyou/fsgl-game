
BATTLE_DIM_COLOR = cc.c3b(100,100,100)
BATTLE_DIRECTION = {
    LEFT = "left",
    RIGHT = "right",
}

BATTLE_SIDE = {
    LEFT = "left",
    RIGHT = "right"
}

BATTLE_MP_VICTIMCTRL = {
    TAG = 1024,
    TIME = 0.5,
}

BATTLE_MP = {
    VICTIM   = 50,
    ATTACKER = 90,
    DEAD     = 300,
    AUTO     = 50,
    MAX      = 1000,
}
--[[--战斗结果]]
BATTLE_RESULT = {
    WIN         = 1,
    FAIL        = 0,
    TIMEOUT     = 2,---[[时间到]]
}

--[[--2倍速和3倍速可能会改成2.1倍或者3.1倍，所以需要单独抽出来作为常量控制]]
BATTLE_SPEED = {
    X1          = 1,
    X2          = 1.5,
    X3          = 2,
    
    -- X1          = 1.25,
    -- X2          = 2,
    -- X3          = 2,
}

BATTLE_STATUS = {
    IDLE 		= "idle",
    RUN 		= "run",
    WALK        = "walk",
    SUPER 		= "super",--[[大招]]
    DEAD 		= "dead",
    DEFENSE 	= "defense",
    ATTACK 		= "atk",
    ATK1 		= "atk1",
    ATK2 		= "atk2",
    ATK3 		= "atk3",
    ATKDONE 	= "atkdone",--[[攻击技能执行结束]]
    DIZZ 		= "dizz",--[[--眩晕]]
    ADDICT      = "addict",
    INVINCIBLE  = "invincible",--[[--无敌]]
    BIAN        = "yd_bian",--[[--变身]]
}
--[[
动作
	atk1   技能1
	atk2   技能2
	atk3   技能3
	...    ...
]]
BATTLE_ANIMATION_ACTION = {
    ATTACK 		= "atk",--[[普通攻击]]
    IDLE 		= "idle",--[[待机]]
    RUN 		= "run",--[[跑]]
    WALK        = "walk",--[[行走]]
    SUPER 		= "atk0",--[[大招]]
    DEATH 		= "death",--[[死亡]]
    WIN 	    = "win",--[[胜利]]
    DEFENSE     = "atkd",--[[受击]]
    ATK1 		= "atk1",
    ATK2 		= "atk2",
    ATK3 		= "atk3",
    PAUSED 		= "paused",--[[--定身]]
    DIZZ        = "vertigo",--[[--眩晕]]
    BIAN        = "yd_bian",--[[--变身]]
    BIAN_SUPER  = "yd_atk0",--[[--变身大招]]
    BIAN_DEATH  = "yd_death",--[[--变身死亡]]
    BIAN_IDLE   = "yd_idle",--[[--变身待机]]
    BIAN_RUN    = "yd_run",--[[--变身跑]]
    BIAN_DEFENSE= "yd_atkd",--[[--变身受击]]
    BIAN_DIZZ   = "yd_vertigo",--[[--变身受击]]
}

ANIMAL_TYPE = {
    PLAYER 		= "player",--[[玩家英雄]]
    MONSTER 	= "monster",--[[关卡怪物]]
}

BATTLE_PAUSE_LIMIT = 11
BATTLE_SPPEDX2_LIMIT = 5
BATTLE_SPPEDX3_LIMIT = 40
BATTLE_AUTO_LIMIT = 0
BATTLE_MAX_HURT_REMP = 200
--[[
常用动作回调事件
(注：某些人物有单独的事件，需要格外注意)
]]
BATTLE_ANIMATION_EVENT = {
    onAtkDone 			= "onAtkDone",--[[普通攻击结束事件]]
    onAtk0Begin 		= "onAtk0Begin",--[[大招结束事件]]

    onAtk0Done 	    	= "onAtk0Done",--[[大招结束]]
    onAtk0Done2 	    = "onAtk0Done2",--[[最后一击，只有个别英雄才有该事件，例如雪豹]]
    onAtk1Done     		= "onAtk1Done",--[[技能1结束]]
    onAtk2Done     		= "onAtk2Done",
    onAtk3Done     		= "onAtk3Done",
    onAtk0Done_1     	= "onAtk0Done_1",--[[大象大招]]
}

BATTLE_TALENT_TYPE = {
    TYPE_DOHURT              = 100, --每次攻击命中时掉血时
    TYPE_BEHURT              = 101, --被击中掉血时
    TYPE_NORMAL_HIT_NUM      = 102, --普通攻击每命中hptrigger次时
    TYPE_HP_LOW              = 103, --生命血量低于hptrigger（百分比）时
    TYPE_DODGE               = 104, --每次闪避时
    TYPE_DODGE_AND_HIT       = 105, --每次闪避或攻击命中
}

EVENT_NAME_BATTLE_PLAY_EFFECT               = "event_name_battle_play_effect"
EVENT_NAME_BATTLE_DEAD                      = "event_name_battle_dead"--[[人物死亡事件]]
EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS     = "event_name_battle_get_all_alive_targets"
EVENT_NAME_BATTLE_GET_RANDOM                = "event_name_battle_get_random"
EVENT_NAME_BATTLE_REPLAY                    = "event_name_battle_replay"
EVENT_NAME_BATTLE_RESUME                    = "event_name_battle_resume"
EVENT_NAME_BATTLE_PAUSE                     = "event_name_battle_PAUSE"
EVENT_NAME_BATTLE_ISAUTO                    = "event_name_battle_isauto"
EVENT_NAME_BATTLE_AUTO_SUPER                = "event_name_battle_auto_super"--[[--自动释放大招]]
EVENT_NAME_BATTLE_AUTO                      = "event_name_battle_auto"
EVENT_NAME_BATTLE_ADDICT                    = "event_name_battle_addict"--[[--魅惑]]
EVENT_NAME_BATTLE_MUSIC_PLAY                = "event_name_battle_music_play"
EVENT_NAME_BATTLE_DATA_HURT_RECORD          = "event_name_battle_data_hurt_record"--[[--伤害数据统计]]
EVENT_NAME_BATTLE_GET_ALL_ATTACKABLE_TARGETS= "event_name_battle_get_all_attackable_targets"
EVENT_NAME_BATTLE_PLAY_WORLD_EFFECT         = "event_name_battle_play_world_effect"
-- EVENT_NAME_BATTLE_ADD_GUIDE                 = "event_name_battle_add_guide"
EVENT_NAME_BATTLE_FRESH_ZORDER              = "event_name_battle_fresh_zorder"
EVENT_NAME_BATTLE_ISREPLAY                  = "event_name_battle_isreplay"
EVENT_NAME_BATTLE_GETGUIDESTATE             = "event_name_battle_getguidestate"
-- EVENT_NAME_BATTLE_ADD_AVATARBUTTONGUIDE     = "event_name_battle_add_avatarbuttonguide"

function EVENT_NAME_REFRESH_HERO_PERCENTAGE(heroId)
    return "event_name_refresh_hero_percentage_"..heroId
end

function EVENT_NAME_BATTLE_CLEAR_MP(heroId)
    return "event_name_battle_clear_mp_"..heroId
end

function EVENT_NAME_BATTLE_AVATAR_GRAY(heroId)
    return "event_name_battle_avatar_gray_"..heroId
end
function EVENT_NAME_BATTLE_AVATAR_BUTTON(heroId)
    return "event_name_battle_avatar_button_"..heroId
end

MOVE_SPEED = 4.0

XTHD = XTHD or {}
XTHD.battle = XTHD.battle or {}
function XTHD.battle.getAnimalPathByHeroId(heroId)
    local target = nil
    if heroId == 1 then
        target = "HuaMuLan"
    elseif heroId == 3 or heroId == 1003 then
        target = "BaiQi"
    elseif heroId == 4 or heroId == 1004 then
        target = "ZhuGeLiang"
    elseif heroId == 5 then
        target = "JiFa"
    elseif heroId == 6 then
        target = "LiYuanBa"
    elseif heroId == 7 then
        target = "LiShiShi"
    elseif heroId == 8 then
        target = "LuoCheng"
    elseif heroId == 9 then
        target = "XiangYu"
    elseif heroId == 12 then
        target = "HongFuNv"
    elseif heroId == 13 then
        target = "ChenYaoJin"
    elseif heroId == 15 then
        target = "JiangZiYa"
    elseif heroId == 17 then
        target = "LingZhen"
    elseif heroId == 20 then
        target = "NvWa"
    elseif heroId == 21 then
        target = "MinYue"
    elseif heroId == 22 then
        target = "LuZhiShen"
    elseif heroId == 24 then
        target = "XuChu"
    elseif heroId == 25 then
        target = "SunShangXiang"
    elseif heroId == 26 then
        target = "Giraffe"
    elseif heroId == 27 then
        target = "WangZhaoJun"
    elseif heroId == 28 then
        target = "ZhangLiao"
    elseif heroId == 29 then
        target = "YuJi"
    elseif heroId == 30 then
        target = "SuDaJi"
    elseif heroId == 31 or heroId == 1031 then
        target = "ZhangFei"
    elseif heroId == 32 then
        target = "LiGuang"
    elseif heroId == 34 then
        target = "WenZhong"
    elseif heroId == 35 then
        target = "YangYuHuan"
    elseif heroId == 36 then
        target = "ShenGongBao"
    elseif heroId == 37 then
        target = "ZhuRongFuRen"
    elseif heroId == 39 then
        target = "ZhenFu"
    elseif heroId == 40 then
        target = "PanJinLian"
    elseif heroId == 41 then
        target = "JingKe"
    elseif heroId == 42 then 
        target = "SnowMonster"
    elseif heroId == 44 then
        target = "DianWei"
    elseif heroId == 46 then
        target = "WeiZiFu"
    elseif heroId == 47 then
        target = "ShenLiShiShi"
	elseif heroId == 48 then
        target = "ssyyh"
    elseif heroId == 49 then
        target = "sslzs"
    elseif heroId == 50 then 
        target = "ssmy"
    elseif heroId == 51 then
        target = "ssssx"
    elseif heroId == 52 then
        target = "sssgb"
    elseif heroId == 54 then
        target = "sslz"
    elseif heroId == 62 then
        target = "ssyj"
    elseif heroId == 67 then 
        target = "ssjk"
    elseif heroId == 70 then
        target = "ssxc"
    elseif heroId == 72 then
        target = "sslc"
	elseif heroId == 79 then
        target = "Snqx"
    elseif heroId == 80 then
        target = "Snbx"
    elseif heroId == 81 then
        target = "Snhj"
    elseif heroId == 82 then
        target = "Snjlsm"
    elseif heroId == 83 then
        target = "Snjs"
    elseif heroId == 84 then
        target = "Snsgb"
    elseif heroId == 85 then
        target = "Snsdj"
    elseif heroId == 86 then
        target = "Sntxs"
    elseif heroId == 87 then 
        target = "Snjwh"
    elseif heroId == 88 then
        target = "Snljgz"
    elseif heroId == 89 then
        target = "Snhy"
    elseif heroId == 90 then
        target = "Snnw"
	elseif heroId == 91 then
        target = "Snkx"
    elseif heroId == 92 then
        target = "Snyx"
    elseif heroId == 93 then 
        target = "Snhxm"
    elseif heroId == 94 then
        target = "Snyaoji"
    elseif heroId == 95 then
        target = "Snlpp"
    elseif heroId == 96 then
        target = "Snjzy"
    elseif heroId == 97 then
        target = "Snyinjiao"
    elseif heroId == 98 then 
        target = "Snyinhong"
    elseif heroId == 99 then
        target = "Snjinzha"
    elseif heroId == 100 then
        target = "Snhfh"
	elseif heroId == 101 then 
        target = "Sndjg"
    elseif heroId == 102 then
        target = "Snngs"
    elseif heroId == 103 then
        target = "Snzgm"
    elseif heroId == 104 then
        target = "Snmuzha"
    elseif heroId == 105 then
        target = "Sndcy"
    elseif heroId == 106 then 
        target = "Snwz"
    elseif heroId == 107 then
        target = "Snysn"
    elseif heroId == 108 then
        target = "Snyangjian"
    elseif heroId == 109 then
        target = "Snhth"
	elseif heroId == 110 then
        target = "Snjifa"		
    elseif heroId == 301 then
        target = "monster/SiShen"
    elseif heroId == 302 then
        target = "monster/DaDaoBing"
    elseif heroId == 303 then
        target = "monster/NuBing"
    elseif heroId == 304 then
        target = "monster/DaoDunBing"
    elseif heroId == 305 then
        target = "monster/ChangGeXiaoBing"
    elseif heroId == 306 then
        target = "monster/HuoQiangBing"
    elseif heroId == 307 then
        target = "monster/ShuangFuBing"
    elseif heroId == 308 then
        target = "monster/WuPo"
    elseif heroId == 309 then
        target = "monster/TouDanShou"
    elseif heroId == 310 then
        target = "monster/ChangQiangBing"
    elseif heroId == 311 then
        target = "monster/ChangGongShou"
    elseif heroId == 312 then
        target = "monster/ChaBing"
    elseif heroId == 313 then
        target = "monster/JiSi"
    elseif heroId == 314 then
        target = "monster/RenZhe"
    elseif heroId == 315 then
        target = "monster/ChiHou"
    elseif heroId == 316 then
        target = "monster/JiGuanKuiLei"
    elseif heroId == 317 then
        target = "monster/ChangMaoQiBing"
    elseif heroId == 318 then
        target = "monster/DaoBing"
    elseif heroId == 319 then
        target = "monster/TouMaoBing"
    elseif heroId == 320 then
        target = "monster/JinGuaWuShi"
    elseif heroId == 321 then
        target = "monster/DuanGongBing"
    elseif heroId == 322 then
        target = "monster/BaiQi322"
    elseif heroId == 801 or heroId == 802 then
        target = "monster/QiuNiu"
    end
    print("heroId="..tostring(heroId))
    return "src/fsgl/battle/heros/"..target..".lua"
end

function XTHD.battle.getWorldBuffByTypeId(_typeId)
    local target = nil
    if _typeId == 1 then
        target = "PoisonFog"
    elseif _typeId == 2 then
        target = "Lightning"
    elseif _typeId == 3 then
        target = "Thorn"
    end
    print("_typeId="..tostring(_typeId))
    if not target then
        return nil
    end
    return "src/fsgl/battle/worldBuffs/"..target..".lua"
end


BATTLE_GUIDEBG_TYPE = {
    TYPE_NORMAL = 0,
    TYPE_BRIDGE = 1,
    TYPE_SHIP = 2,
}

function XTHD.battle.getBattleBgByTypeId(_typeId)
    local target = nil
    _typeId = _typeId or BATTLE_GUIDEBG_TYPE.TYPE_NORMAL
    if _typeId == BATTLE_GUIDEBG_TYPE.TYPE_NORMAL then
        target = "BgNormal"
    elseif _typeId == BATTLE_GUIDEBG_TYPE.TYPE_BRIDGE then
        target = "BgBridge"
    elseif _typeId == BATTLE_GUIDEBG_TYPE.TYPE_SHIP then
        target = "BgShip"
    end
    print("_typeId="..tostring(_typeId))
    if not target then
        return nil
    end
    return "src/fsgl/battle/backgrounds/"..target..".lua"
end
