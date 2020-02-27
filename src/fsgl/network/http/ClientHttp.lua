ClientHttp = {};


function ClientHttp:requestAsyncInGameWithParams( params )
	return XTHDHttp:requestAsyncInGameWithParams( params )
end

function ClientHttp:successCallback( data, modules )
	
end

function ClientHttp:failedCallback( data, modules )
	if data then
		XTHDTOAST( data["msg"] or "");
	end
end

function ClientHttp:httpDo( sParams )
	local parNode = sParams.parNode--self
	if not parNode then
		parNode = cc.Director:getInstance():getRunningScene()
	end
    local callBack = sParams.callBack--方法
    local _params = sParams.params--guildID
    local _modules = sParams.modules--命令
    local _failureCallback = sParams.failureCallback
    local _timeoutForRead = tonumber(sParams.timeoutForRead) or 10
    XTHDHttp:requestAsyncInGameWithParams({
        modules = _modules,
        params = _params,
        method = sParams.method,
        timeoutForRead = _timeoutForRead,
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                if callBack then
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RECHARGE_HUOYUEJIANGLI})
                    callBack(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
			    if _failureCallback then
			    	_failureCallback(data)
			    end
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
		    if _failureCallback then
		    	_failureCallback()
		    end
        end,--失败回调
        targetNeedsToRetain = parNode,--需要保存引用的目标
        loadingParent = parNode,
    })
end

-- 获取通用请求战报
function ClientHttp.http_SendFightValidation( sParNode, sCallBack, sFailCall, sParams )
    if not sParNode then
        return
    end

    if sParams.battleType == BattleType.GOLD_COPY_PVE then
        sParams.result = BATTLE_RESULT.WIN
    end

    local fightContent = {}
    fightContent["result"]              = sParams.result
    fightContent["type"]                = sParams.battleType
    fightContent["instancingid"]        = sParams.instancingid
    fightContent["right"]               = sParams.right
    fightContent["left"]                = sParams.left
    fightContent["battleVersion"]       = 2
    fightContent["star"]                = sParams.star
    fightContent["record_hurt_left"]    = sParams.record_hurt_left
    fightContent["record_hurt_right"]   = sParams.record_hurt_right
    fightContent["record_status_left"]  = sParams.record_status_left
    fightContent["record_status_right"] = sParams.record_status_right
    fightContent["battleCostTime"]      = sParams.battleCostTime
    fightContent["randomList"]          = sParams.randomList
    fightContent["superList"]           = sParams.superList
    fightContent["leftData"]            = sParams.leftData
    fightContent["rightData"]           = sParams.rightData

    local mParams = {fightContent = json.encode(fightContent)}

    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        failureCallback = sFailCall,
        params = mParams,
        modules = "fightValidation?",
        timeoutForRead = 15,
    }
    print("请求战斗结果：-------------------------------")
    print_r(_params)
    ClientHttp:httpDo(_params)
end

local _challengeHttpTitle = {
    "challangeEctype?", -- 0
    "challengeRequest?",--1 
    "challangeEliteEctype?",--2
    "challengeBeastEctype?",--3
    "challengeRival?", --4 
    "challengeGoldEctype?",--5
    "challengeFeicuiEctype?",--6
    "challengeEquipEctype?",--7
    "orderChallenge?",--8 
    "challengeRace?",--9 
    "challengeWanted?",--10
    "challengeBoss?",--11
    "lootDart?",--12 
    "asuraRivalInfo?",--13
    "",--14
    "challengeMoreEctype?",--15 多人副本开战
    "challengeGuildBoss?",--16 帮派Boss开战
    "challengeCityMaster?",--17 阵营城主开战
    "challengeCityDefendTeam?",--18 挑战城市防守队伍
    "attackVeinsBattlePoint?", --19真气副本抢夺
    "",--20
    "challangeDiffcultyEctype?", --21恶魔副本
    "challangeCampGuard?",--22
    "challangeSingleEctype?",  --23单挑之王
    "challengeServantEctype?", --24登界游方
}

-- 获取通用请求开始战斗战场战斗最后总结果
function ClientHttp.http_StartChallenge( sParNode, battleType, sParams, sCallBack, sFailCall)
    if not sParNode then
        return
    end
    local mModStr = _challengeHttpTitle[battleType+1]
    local _params = {
        parNode = sParNode,
        callBack = function ( sData )
            if battleType ~= BattleType.PVE and battleType ~= BattleType.ELITE_PVE then
                musicManager.stopBackgroundMusic()
            end
            if sCallBack then
                sCallBack(sData)
            end
        end,
        failureCallback = sFailCall,
        params = sParams,
        modules = mModStr,
    }
    ClientHttp:httpDo(_params)
end

-- 普通本、精英本、恶魔副本开启通知
function ClientHttp.http_EctypeBattleBegin( sParNode, sCallBack, sFailCall, sParams)
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        failureCallback = sFailCall,
        modules = "ectypeBattleBegin?",
        params = sParams,
    }
    ClientHttp:httpDo(_params)
end

-- 获取修罗战场战斗最后总结果
function ClientHttp.http_AsuraBattleResult( sParNode, sCallBack, sFailCall )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        failureCallback = sFailCall,
        modules = "asuraBattleResult?",
    }
    ClientHttp:httpDo(_params)
end

--------------------------7日狂欢活动------------------------

--开服 活动 列表请求
function ClientHttp.http_OpenServerActivityList( sParNode, sCallBack ) 
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "openServerActivityList?",
    }
    ClientHttp:httpDo(_params)
end

--领取开服 活动 奖励请求 {configId}
function ClientHttp.http_OpenServerActivityReward( sParNode, sCallBack, sParams )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "openServerActivityReward?",
        params = sParams,
    }
    ClientHttp:httpDo(_params)
end

------------------------------帮派--------------------------------

--帮派列表请求
function ClientHttp.httpGetGuildList( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "guildList?",
    }
    ClientHttp:httpDo(_params)
end

--创建帮派请求
function ClientHttp.httpCreateGuild( sParNode, sCallBack, sParams ) -- {icon, name, limitLevel}
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = function(data)
            if data.maxTili then--最大体力值改变
                gameUser.setTiliMax(data.maxTili)
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
            end
            sCallBack(data)
        end,
        modules = "createGuild?",
        params = sParams,
    }
    ClientHttp:httpDo(_params)
end

--申请加入帮派
function ClientHttp.httpApplyJoinGuild( sParNode, sCallBack, sParams ) -- {guildId}
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "applyJoinGuild?",
        params = sParams,
    }
    ClientHttp:httpDo(_params)
end

--加入申请列表
function ClientHttp.httpApplyJoinGuildList( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "applyJoinGuildList?",
    }
    ClientHttp:httpDo(_params)
end

--同意用户加入请求
function ClientHttp.httpAgreeGuildApply( sParNode, sCallBack, sParams ) -- {list}
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "agreeGuildApply?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

--拒绝用户加入请求
function ClientHttp.httpRejectGuildApply( sParNode, sCallBack, sParams ) -- {list}
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "rejectGuildApply?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

--帮派log列表
function ClientHttp.httpGuildLogList( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "guildLogList?"
    }
    ClientHttp:httpDo(_params)
end

--帮派成员列表
function ClientHttp.httpGuildMemberList( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "guildMemberList?"
    }
    ClientHttp:httpDo(_params)
end

--修改帮派公告
function ClientHttp.httpModifyGuildNotice( sParNode, sCallBack, sParams ) -- {content}
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "modifyGuildNotice?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

--修改帮派基本信息
function ClientHttp.httpModifyGuildBase( sParNode, sCallBack, sParams ) -- {icon, name, limitLevel}
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "modifyGuildBase?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

--退出帮派
function ClientHttp.httpExitGuild( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = function(data)
            if data.maxTili then--最大体力值改变
                gameUser.setTiliMax(data.maxTili)
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
            end
            sCallBack(data)
        end,
        modules = "exitGuild?",
    }
    ClientHttp:httpDo(_params)
end

--帮主退位
function ClientHttp.httpConcessionGuild( sParNode, sCallBack, sParams ) -- {otherId}
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "concessionGuild?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

--解散帮派
function ClientHttp.httpDissolveGuild( sParNode, sCallBack ) 
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = function(data)
            if data.maxTili then--最大体力值改变
                gameUser.setTiliMax(data.maxTili)
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
            end
            sCallBack(data)
        end,
        modules = "dissolveGuild?"
    }
    ClientHttp:httpDo(_params)
end

--帮派踢人
function ClientHttp.httpGuildKickOff( sParNode, sCallBack, sParams ) -- {otherId}
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "guildKickOff?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

--人事任命
function ClientHttp.httpGuildMemberAppoint( sParNode, sCallBack, sParams ) -- {otherId, roleId}
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "appointGuildMember?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

--祭拜列表
function ClientHttp.httpGuildWorshipList( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "guildWorshipList?"
    }
    ClientHttp:httpDo(_params)
end

--祭拜 
function ClientHttp.httpGuildWorship( sParNode, sCallBack, sParams ) -- {worshipType}
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "guildWorship?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

--祭拜奖励列表
function ClientHttp.httpGuildWorshipListReward( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "worshipRewardList?"
    }
    ClientHttp:httpDo(_params)
end

--祭拜领取奖励
function ClientHttp.httpGuildWorshipReward( sParNode, sCallBack, sParams )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "worshipReward?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

----------------------------帮派end-------------------------------

------------------------------帮派战--------------------------------
-- 基本信息请求
function ClientHttp.httpGuildBaseInfo( sParNode, sCallBack )
    if not sParNode then
        -- return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "guildBattleBase?"
    }
    ClientHttp:httpDo(_params)
end
--参战 请求
function ClientHttp.httpGuildToBattle( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "joinGuildBattle?",
    }
    ClientHttp:httpDo(_params)
end
--设置 主将 请求
function ClientHttp.httpGuildSetLord( sParNode, sCallBack, sParams )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "appointLord?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
--主将列表 请求
function ClientHttp.httpGuildBattleLordList( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "lordList?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 帮派战队伍列表 请求
function ClientHttp.httpGuildBattleGroupList( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "guildBattleGroupList?",
    }
    ClientHttp:httpDo(_params)
end
--切换 帮派战 队伍列表 请求
function ClientHttp.httpGuildChangeBattleGroupList( sParNode, sCallBack ,sParams) 
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "changeGuildBattleGroupList?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
--主将 选择 预备 成员 请求
function ClientHttp.httpGuildChooseGroupMemberList( sParNode, sCallBack ) 
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "chooseGroupMemberList?",
    }
    ClientHttp:httpDo(_params)
end
-- 设置帮派战 队伍 请求
function ClientHttp.httpGuildBattleGroupMember( sParNode, sCallBack, sParams,failureCallback )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "resetBattleGroupMember?",
        params = sParams,
        failureCallback = failureCallback
    }
    ClientHttp:httpDo(_params)
end
--获取 队员自己 上阵的防守队伍  请求
function ClientHttp.httpGetMyGuildGroup( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "myGuildBattleGroup?",
    }
    ClientHttp:httpDo(_params)
end
--设置 队员自己 上阵的防守队伍  请求
function ClientHttp.httpGuildSetDefenceGroup( sParNode, sCallBack, sParams)
    if not sParNode then
        return
    end
--    local _params = {
--        parNode = sParNode,
--        callBack = sCallBack,
--        modules = "embattleMyGroup?",
--        params = sParams,

--    }
    local _timeoutForRead = tonumber(timeoutForRead) or 10
    XTHDHttp:requestAsyncInGameWithParams({
        modules = "embattleMyGroup?",
        params = sParams,
        timeoutForRead = _timeoutForRead,
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                if sCallBack then
                    sCallBack(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
			    if sParNode.GuildTishiGroup then
					data._list = sParams.list
			    	sParNode:GuildTishiGroup(data)
			    end
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
		    if failureCallback then
		    	failureCallback()
		    end
        end,--失败回调
        targetNeedsToRetain = sParNode,--需要保存引用的目标
        loadingParent = sParNode,
    })
  --  ClientHttp:httpDo(_params)
end
--更换 对手  请求
function ClientHttp.httpGuildChangeRival( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "changeGuildRival?",
    }
    ClientHttp:httpDo(_params)
end
-- 调整 攻击 顺序  请求
function ClientHttp.httpGuildAdjustAttackSequence( sParNode, sCallBack, sParams )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "adjustAttackSequence?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 帮派战 一轮攻击log  请求
function ClientHttp.httpGuildBattleAttackLog( sParNode, sCallBack, sFailCall )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        failureCallback = sFailCall,
        modules = "guildBattleAttackLog?",
    }
    ClientHttp:httpDo(_params)
end
--  帮派战 记录  请求
function ClientHttp.httpGuildLookBattleRecord( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "lookGuildBattleRecord?",
    }
    ClientHttp:httpDo(_params)
end
-- 帮派战 积分 排名  请求
function ClientHttp.httpGuildJifenRank( sParNode, sCallBack )
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "guildJifenRank?",

    }
    ClientHttp:httpDo(_params)
end

----------------------------帮派战end-------------------------------

-- 各活动进入接口
function ClientHttp:httpCommon( sModule, sParNode,sParams, sCallBack ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = sModule,
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

------------------------------帮派Boss--------------------------------

-- 各活动进入接口
function ClientHttp:httpGuild( sModule, sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = sModule,
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end


----------------------------帮派BosseEnd-------------------------------

------------------------------英雄--------------------------------
-- 英雄列表招募英雄
function ClientHttp:httpHeroToRecruit( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "petExchange?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄化功返回材料信息
function ClientHttp:httpHeroResetBackInfo( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "advanceReset?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄一键穿装
function ClientHttp:httpHeroOneKeyEquip( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "okeyWearItem?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

-- 英雄一键强化
function ClientHttp:httpHeroOneKeyStrength( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "petOkyStreng?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄购买经验用品
function ClientHttp:httpHeroBuyExpItems( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "buyExpItem?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄进阶
function ClientHttp:httpHeroAdvance( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "upPhase?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

-- 英雄穿戴装备
function ClientHttp:httpHeroEquipItem( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "moveItemToBody?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄更换装备
function ClientHttp:httpHeroExchangeItem( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "exchangeEquip?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄卸下装备
function ClientHttp:httpHeroDemountItem( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "moveItemToBag?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄增强魔攻
function ClientHttp:httpHeroAddNeigong( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "upNeigong?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄重置魔攻等级
function ClientHttp:httpHeroResetNeigong( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "resetNeigong?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄升级
function ClientHttp:httpHeroLevelUp( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "useItem?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄化功
function ClientHttp:httpHeroReset( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "resetPet?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄购买技能点
function ClientHttp:httpHeroBuySkillPoint( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "buySkillPoint?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄升级技能点
function ClientHttp:httpHeroSkillUp( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "upSkill?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-- 英雄升星
function ClientHttp:httpHeroStarUp( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "upStar?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
----------------------------英雄end-------------------------------


-- 铁匠铺合成
function ClientHttp:httpComposeItem( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "composeItem?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
-----------------------------活动---------------------------------
-- 各活动进入接口
function ClientHttp:httpActivity( sModule, sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = sModule,
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

-- loginTask领取
function ClientHttp:httpLoginTaskReward( sParNode, sCallBack ,sParams ,sFailCall)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "acquireLoginReward?",
        failureCallback = sFailCall,
        params = sParams
    }
    ClientHttp:httpDo(_params)
end
----------------------------活动end-------------------------------

---------------------------好友-------------------------
function ClientHttp:httpFriendSendFlowerState( sParNode, sCallBack ,sParams)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "friendSendFlowerState?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

-- 推荐好友列表
function ClientHttp:httpRecommend( sParNode, sCallBack)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "recommend?",
    }
    ClientHttp:httpDo(_params)
end    

-- 查找好友
function ClientHttp:httpFindPlayer( sParNode, sCallBack, sParams )
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "findPlayer?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end 

-- 查找好友
function ClientHttp:httpDelRelation( sParNode, sCallBack, sParams )
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "delRelation?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end 

-- 查找好友
function ClientHttp:httpFriendRace( sParNode, sCallBack, sParams )
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "friendRace?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end 

-- 申请添加好友
function ClientHttp:httpAddRequest( sParNode, sCallBack, sParams )
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "addRequest?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end 

-- 同意添加好友
function ClientHttp:httpAddFriend( sParNode, sCallBack, sFailCall, sParams )
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        failureCallback = sFailCall,
        modules = "addFriend?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end

-- 好友互动log
function ClientHttp:httpInteractLog( sParNode, sCallBack )
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "interactLog?",
    }
    ClientHttp:httpDo(_params)
end 

-- 好友互动log
function ClientHttp:httpSendFlower( sParNode, sCallBack, sParams )
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "sendFlower?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end 

---------------------------装备副本-------------------------
function ClientHttp:httpEquipEctypes( sParNode, sCallBack)
    print("httpEquipEctypes>>>")
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "equipEctypes?",
    }
    ClientHttp:httpDo(_params)
end

function ClientHttp:httpRefreshEquipEctypes( sParNode, sCallBack, isBeast)
    local _module
    if isBeast then
        _module = "refreshBestEquipEctypes?"
    else
        _module = "refreshEquipEctypes?"
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = _module,
    }
    ClientHttp:httpDo(_params)
end

function ClientHttp:httpSweepEquipEctype( sParNode, sCallBack, sParams)
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "sweepEquipEctype?",
        params = sParams
    }
    ClientHttp:httpDo(_params)
end


---------show replay ----------
function ClientHttp:httpReplayBatlle( sParNode, replayId )
    -- do XTHDTOAST(LANGUAGE_TIPS_WORDS11) return end
    local function _callBack( sData )
        local _data = sData.content or {}
        if (_data.leftData and next(_data.leftData) ~= nil) 
            and (_data.rightData and next(_data.rightData) ~= nil) then

            local scene = cc.Scene:create()
            cc.Director:getInstance():pushScene(scene)

            local _battle_type = tonumber(_data.type) or 1
            local teamListLeft = {}
            local teamListRight = {}
            local bgList = {}

            for k,hero in pairs(_data.leftData) do
                local petId = hero.petId
                local _staticData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = petId}) or {}
                hero.attackrange = _staticData.attackrange 
                local animal = {id = petId ,_type = ANIMAL_TYPE.PLAYER , data = hero }
                teamListLeft[#teamListLeft + 1] = animal
            end
            --[[--排队]]
            table.sort(teamListLeft, function(a,b) 
                local n1 = tonumber(a.data.attackrange) or 0
                local n2 = tonumber(b.data.attackrange) or 0
                return n1 < n2
            end )
           
            for k,teams in pairs(_data.rightData) do
                local heroes = teams.heros
                local rightData = {}
                local team = {}
                for k,hero in pairs(heroes) do
                    local petId = hero.petId
                    local _staticData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = petId}) or {}
                    hero.attackrange = _staticData.attackrange 
                    local animal = {id = petId ,_type = ANIMAL_TYPE.PLAYER , data = hero }
                    team[#team + 1]=animal
                end
                --[[--排队]]
                table.sort( team, function(a,b) 
                    local n1 = tonumber(a.data.attackrange) or 0
                    local n2 = tonumber(b.data.attackrange) or 0
                    return n1 < n2
                end )
                rightData.team = team
                teamListRight[#teamListRight + 1] = rightData
            end--[[--for]]

            if(_battle_type == BattleType.PVP_CHALLENGE) then
                local bgId = math.random(1,53)
                bgList[#bgList + 1] = "res/image/background/bg_"..bgId..".jpg"
            else
                bgList[#bgList + 1] = "res/image/background/bg_pvp.jpg"
            end
            
            local battleLayer = requires("src/battle/BattleLayer.lua"):create()
            scene:addChild(battleLayer)
            battleLayer.BATTLE_RANDOM_RECORD = _data.randomList
            battleLayer.BATTLE_SUPER_RECORD = _data.superList
            battleLayer:replay({
                bgList          = bgList,
                bgm             = "res/sound/bgm_battle_pvp.mp3",
                instancingid    = sInstancingid,
                battleTime      = 90,
                teamListLeft    ={teamListLeft},
                teamListRight   =teamListRight,
                battleType      = _battle_type,
                replayEndCallback = function()
                    cc.Director:getInstance():popScene()
                end
            })
        
        else
            XTHDTOAST(LANGUAGE_KEY_ZHANBAOGUOQI)
        end        
    end
    local _params = {
        parNode = sParNode,
        callBack = _callBack,
        modules = "lookReport?",
        params = {reportId = replayId}
    }
    ClientHttp:httpDo(_params)
end