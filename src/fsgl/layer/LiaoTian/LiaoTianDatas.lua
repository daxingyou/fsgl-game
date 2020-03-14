--[[
Authored by LITao
the chat room's message managerment
]]
LiaoTianDatas = LiaoTianDatas or { }
LiaoTianDatas._helperMsg = { }
LiaoTianDatas.__worldMsg = { } -- 世界频道的消息
LiaoTianDatas.__BPMsg = { } -- 帮派频道的消息
LiaoTianDatas.__campMsg = { } -- 种族频道的消息
LiaoTianDatas.__System = { } --- 系统消息（公告，战报等）
LiaoTianDatas.__teamMsg = { }
LiaoTianDatas.__ChatMsg = {}
LiaoTianDatas.newMsg = {
    -- 是否有新的未查看的消息
    _world = 0,
    _camp = 0,
    _BP = 0,
    _system = 0,
    _team = 0,
}
LiaoTianDatas.__Data = { } -----聊天数据 
LiaoTianDatas.hasNewMsg = { } ----是否有新消息（每个频道的）
LiaoTianDatas.hasNewMsgs = false -----是否有新消息未读(总的)

LiaoTianDatas.__chatType = {
    TYPE_HELPER = 0,
    -- 助手
    TYPE_PRIVATE_CHAT = 1,
    -- 私人聊天
    TYPE_WORLD_CHAT = 16,
    -- 世界聊天
    TYPE_CAMP_CHAT = 32,
    -- 种族聊天
    TYPE_BP_CAHT = 8,
    -- 帮派聊天
    TYPE_ANNOUNCEMENT = 20,
    -- 公告
    TYPE_PAOMADENG = 21,
    -- 专属跑马灯
    TYPE_FIGHTREPORT = 36,
    -- 战报
    TYPE_TEAM_CHAT = 40,-- 队伍聊天
	--聊天界面的滚动公告
	TYPE_CHATROOM_MAG = 99,
}
LiaoTianDatas.MAXMSG = 50

function LiaoTianDatas.insertHelperData(datas)
    if datas then
        LiaoTianDatas._helperMsg = datas
    end
end

--[[
@_type	当前消息的频道 16 世界频道，8 帮派频道，32 种族频道
@isSelf	是否是自己发的
@msg 	消息内容
]]
-- local i = 0
function LiaoTianDatas.insertMsg(_type, isSelf, Msg)
    -- print("聊天信息为：")
    -- print_r(Msg)

    if isSelf then
        -- 是自己发的
        local data = LiaoTianDatas.consistSelfMsg(Msg)
        if _type == LiaoTianDatas.__chatType.TYPE_WORLD_CHAT then
            -- 世界信息
            table.insert(LiaoTianDatas.__worldMsg, 1, data)
        elseif _type == LiaoTianDatas.__chatType.TYPE_BP_CAHT then
            -- 帮派信息
            table.insert(LiaoTianDatas.__BPMsg, 1, data)
        elseif _type == LiaoTianDatas.__chatType.TYPE_CAMP_CHAT then
            -- 种族信息
            table.insert(LiaoTianDatas.__campMsg, 1, data)
        elseif _type == LiaoTianDatas.__chatType.TYPE_TEAM_CHAT then
            -- 队伍聊天
            table.insert(LiaoTianDatas.__teamMsg, 1, data)
            XTHD.dispatchEvent( { name = CUSTOM_EVENT.DISPLAY_PLAYER_SPEEK, _data = { roleID = data.senderID, wordIndex = data.message } })
        end
	else
        local data = LiaoTianDatas.analysisServerMsg(Msg)
        if _type == LiaoTianDatas.__chatType.TYPE_WORLD_CHAT then
            -- 世界信息
            if data then
                LiaoTianDatas.newMsg._world = LiaoTianDatas.newMsg._world + 1
                if LiaoTianDatas.newMsg._world > LiaoTianDatas.MAXMSG then
                    LiaoTianDatas.newMsg._world = LiaoTianDatas.MAXMSG
                end
                table.insert(LiaoTianDatas.__worldMsg, 1, data)
                -------把世界聊天加进公告里		
                LiaoTianDatas.newMsg._system = LiaoTianDatas.newMsg._system + 1
                if LiaoTianDatas.newMsg._system > LiaoTianDatas.MAXMSG then
                    LiaoTianDatas.newMsg._system = LiaoTianDatas.MAXMSG
                end
                table.insert(LiaoTianDatas.__System, 1, data)
            end
        elseif _type == LiaoTianDatas.__chatType.TYPE_BP_CAHT then
            -- 帮派信息
            if data then
                LiaoTianDatas.newMsg._BP = LiaoTianDatas.newMsg._BP + 1
                if LiaoTianDatas.newMsg._BP > LiaoTianDatas.MAXMSG then
                    LiaoTianDatas.newMsg._BP = LiaoTianDatas.MAXMSG
                end
                table.insert(LiaoTianDatas.__BPMsg, 1, data)
            end
        elseif _type == LiaoTianDatas.__chatType.TYPE_CAMP_CHAT then
            -- 种族信息
            if data then
                LiaoTianDatas.newMsg._camp = LiaoTianDatas.newMsg._camp + 1
                if LiaoTianDatas.newMsg._camp > LiaoTianDatas.MAXMSG then
                    LiaoTianDatas.newMsg._camp = LiaoTianDatas.MAXMSG
                end
                table.insert(LiaoTianDatas.__campMsg, 1, data)
            end
        elseif _type == LiaoTianDatas.__chatType.TYPE_TEAM_CHAT then
            -- 队伍聊天
            if data then
                LiaoTianDatas.newMsg._team = LiaoTianDatas.newMsg._team + 1
                if LiaoTianDatas.newMsg._team > LiaoTianDatas.MAXMSG then
                    LiaoTianDatas.newMsg._team = LiaoTianDatas.MAXMSG
                end
                table.insert(LiaoTianDatas.__teamMsg, 1, data)
                local _data = data
                XTHD.dispatchEvent( { name = CUSTOM_EVENT.DISPLAY_PLAYER_SPEEK, data = { roleID = _data.senderID, wordIndex = _data.message } })
            end
        elseif _type == LiaoTianDatas.__chatType.TYPE_ANNOUNCEMENT then
            -- 公告
            if data then
                ----------公告的节点
                local node = cc.Director:getInstance():getNotificationNode()
                local announce = node:getChildByName("announcement")
                -----加入公告
                if data.isNewMsg == true then
                    XTHDMarqueeNode:insertAData(data.message)
                    if announce then
                        announce:run()
                    end
                end
                ---------------------
                LiaoTianDatas.newMsg._system = LiaoTianDatas.newMsg._system + 1
                if LiaoTianDatas.newMsg._system > LiaoTianDatas.MAXMSG then
                    LiaoTianDatas.newMsg._system = LiaoTianDatas.MAXMSG
                end
                table.insert(LiaoTianDatas.__System, 1, data)
            end
        elseif _type == LiaoTianDatas.__chatType.TYPE_FIGHTREPORT then
            --- 战报
            if data then
                LiaoTianDatas.newMsg._system = LiaoTianDatas.newMsg._system + 1
                if LiaoTianDatas.newMsg._system > LiaoTianDatas.MAXMSG then
                    LiaoTianDatas.newMsg._system = LiaoTianDatas.MAXMSG
                end
                table.insert(LiaoTianDatas.__System, 1, data)
            end
		elseif _type == LiaoTianDatas.__chatType.TYPE_CHATROOM_MAG then
			table.insert(LiaoTianDatas.__ChatMsg, 1, data)
        end
        LiaoTianDatas.dispatchChatMsgs(data)
    end
    LiaoTianDatas.removeNotNeeded()
end

function LiaoTianDatas.updateMsg(newMsg)
    -- print("更新聊天内容信息")
    -- print_r(newMsg)
    for i = 1, #LiaoTianDatas.__worldMsg do
        if LiaoTianDatas.__worldMsg[i].senderID then
            if LiaoTianDatas.__worldMsg[i].senderID == newMsg.senderID then
                LiaoTianDatas.__worldMsg[i].senderName = newMsg.senderName
                LiaoTianDatas.__worldMsg[i].senderVIP = newMsg.senderVIP
                LiaoTianDatas.__worldMsg[i].iconID = newMsg.iconID
                LiaoTianDatas.__worldMsg[i].senderCampID = newMsg.senderCampID
            end
        end
    end
    for i = 1, #LiaoTianDatas.__BPMsg do
        if LiaoTianDatas.__BPMsg[i].senderID then
            if LiaoTianDatas.__BPMsg[i].senderID == newMsg.senderID then
                LiaoTianDatas.__BPMsg[i].senderName = newMsg.senderName
                LiaoTianDatas.__BPMsg[i].senderVIP = newMsg.senderVIP
                LiaoTianDatas.__BPMsg[i].iconID = newMsg.iconID
                LiaoTianDatas.__BPMsg[i].senderCampID = newMsg.senderCampID
            end
        end
    end
    for i = 1, #LiaoTianDatas.__campMsg do
        if LiaoTianDatas.__campMsg[i].senderID then
            if LiaoTianDatas.__campMsg[i].senderID == newMsg.senderID then
                LiaoTianDatas.__campMsg[i].senderName = newMsg.senderName
                LiaoTianDatas.__campMsg[i].senderVIP = newMsg.senderVIP
                LiaoTianDatas.__campMsg[i].iconID = newMsg.iconID
                LiaoTianDatas.__campMsg[i].senderCampID = newMsg.senderCampID
            end
        end
    end
    for i = 1, #LiaoTianDatas.__System do
        if LiaoTianDatas.__System[i].senderID then
            if LiaoTianDatas.__System[i].senderID == newMsg.senderID then
                LiaoTianDatas.__System[i].senderName = newMsg.senderName
                LiaoTianDatas.__System[i].senderVIP = newMsg.senderVIP
                LiaoTianDatas.__System[i].iconID = newMsg.iconID
                LiaoTianDatas.__System[i].senderCampID = newMsg.senderCampID
            end
        end
    end
    for i = 1, #LiaoTianDatas.__teamMsg do
        if LiaoTianDatas.__teamMsg[i].senderID then
            if LiaoTianDatas.__teamMsg[i].senderID == newMsg.senderID then
                LiaoTianDatas.__teamMsg[i].senderName = newMsg.senderName
                LiaoTianDatas.__teamMsg[i].senderVIP = newMsg.senderVIP
                LiaoTianDatas.__teamMsg[i].iconID = newMsg.iconID
                LiaoTianDatas.__teamMsg[i].senderCampID = newMsg.senderCampID
            end
        end
    end
end

function LiaoTianDatas.consistSelfMsg(msg)
    local data = { }
    data.level = gameUser.getLevel()
    data.name = gameUser.getNickname()
    data.BP = " "
    data.badge = { }
    -- 徽章
    if gameUser.getVip() and tonumber(gameUser.getVip()) > 0 then
        data.badge[4] = 4
    end
    data.message = msg
    return data
end

function LiaoTianDatas.analysisServerMsg(msg)
    if msg then
        local data = { }
        data.chatType = msg.chatType
        data.level = msg.senderLevel
        data.senderID = msg.senderID
        data.name = msg.senderName == "" and LANGUAGE_TIPS_WORDS13 or msg.senderName
        data.msgTime = msg.msgTime
        --- 该条消息时间
        data.iconID = msg.iconID
        ----头像ID
        data.badge = { }
        --- 徽章
        data.badge[1] = msg.senderCampID
        -- 种族
        data.badge[2] = msg.senderVIP
        -- vip等级
        data.badge[3] = msg.leaderRange
        -- 竞技场排名徽章
        data.badge[4] = msg.senderArenaID
        --- 竞技场段ID
        -------多人副本特有
        data.multiBlackPos = msg.multiBlackPos
        -------当前多人副本队伍还差多少人满
        data.multiConfigID = msg.multiConfigID
        -------表ID
        data.multiTeamID = msg.multiTeamID
		data.titleId = msg.titleId
        --------
        if msg.shareItem then
            data.shareItem = msg.shareItem
        else
            data.shareItem = msg.item
        end
        ------------------------------------------------
        data.BP = msg.senderBPName == "" and " " or msg.senderBPName
        if data.chatType == LiaoTianDatas.__chatType.TYPE_FIGHTREPORT then
            --- 战报
            data.reportLogID = msg.chatMsg
            -------战报ID
            local source = string.split(msg.chatMsg, ",")
--            dump(msg.chatMsg, "战报")
            data.message = LiaoTianDatas.consistFightReport(source)
        else
            data.message = msg.chatMsg
        end
        if data.msgTime and tonumber(data.msgTime) > tonumber(gameUser.getSocketLoginTime()) then
            -----登录之后发的消息
            data.isNewMsg = true
            if LiaoTianRoomLayer and LiaoTianRoomLayer.__isAtShowing and LiaoTianRoomLayer.currentChannel == data.chatType then
                --- 如果聊天框在且频道与该消息一样
                data.hasRead = true
            else
                data.hasRead = false
                if data.chatType == LiaoTianDatas.__chatType.TYPE_FIGHTREPORT and LiaoTianRoomLayer and LiaoTianRoomLayer.currentChannel ~= LiaoTianDatas.__chatType.TYPE_ANNOUNCEMENT then
                    LiaoTianDatas.hasNewMsg[LiaoTianDatas.__chatType.TYPE_ANNOUNCEMENT] = true
                else
                    LiaoTianDatas.hasNewMsg[data.chatType] = true
                end
            end
        else
            data.isNewMsg = false
            data.hasRead = true
        end
        return data
    end
    return nil
end

function LiaoTianDatas.consistFightReport(msg)
    local content = ""
    if msg and #msg > 0 then
        local result = LANGUAGE_ADJ.failed
        ------ "失败"
        if tonumber(msg[6]) > 0 then
            --- 挑战成功
            result = LANGUAGE_ADJ.success
            -----"胜利"
        end
        local time = tostring(msg[7])
        content = LANGUAGE_KEY_CHALLENGE_REPORT(msg[3], msg[5], result) .. os.date("%y.%m.%d--%H:%M:%S", string.sub(time, 1, #time - 3))
    end
    return content
end

function LiaoTianDatas.getMsgsByType(_type)
    if _type == LiaoTianDatas.__chatType.TYPE_WORLD_CHAT then
        LiaoTianDatas.newMsg._world = 0
        return LiaoTianDatas.__worldMsg
    elseif _type == LiaoTianDatas.__chatType.TYPE_BP_CAHT then
        LiaoTianDatas.newMsg._BP = 0
        return LiaoTianDatas.__BPMsg
    elseif _type == LiaoTianDatas.__chatType.TYPE_CAMP_CHAT then
        LiaoTianDatas.newMsg._camp = 0
        return LiaoTianDatas.__campMsg
    elseif _type == LiaoTianDatas.__chatType.TYPE_ANNOUNCEMENT then
        LiaoTianDatas.newMsg._system = 0
        return LiaoTianDatas.__System
    elseif _type == LiaoTianDatas.__chatType.TYPE_TEAM_CHAT then
        LiaoTianDatas.newMsg._team = 0
        return LiaoTianDatas.__teamMsg
    end
end

function LiaoTianDatas:getMsgByTypeWithoutCleanStatus(_type)
    if _type == LiaoTianDatas.__chatType.TYPE_WORLD_CHAT then
        return LiaoTianDatas.__worldMsg
    elseif _type == LiaoTianDatas.__chatType.TYPE_BP_CAHT then
        return LiaoTianDatas.__BPMsg
    elseif _type == LiaoTianDatas.__chatType.TYPE_CAMP_CHAT then
        return LiaoTianDatas.__campMsg
    elseif _type == LiaoTianDatas.__chatType.TYPE_ANNOUNCEMENT then
        return LiaoTianDatas.__System
    elseif _type == LiaoTianDatas.__chatType.TYPE_TEAM_CHAT then
        return LiaoTianDatas.__teamMsg
    end
end

function LiaoTianDatas.getMsgsLengthByType(_type)
    if _type == LiaoTianDatas.__chatType.TYPE_WORLD_CHAT then
        return #LiaoTianDatas.__worldMsg
    elseif _type == LiaoTianDatas.__chatType.TYPE_BP_CAHT then
        return #LiaoTianDatas.__BPMsg
    elseif _type == LiaoTianDatas.__chatType.TYPE_CAMP_CHAT then
        return #LiaoTianDatas.__campMsg
    elseif _type == LiaoTianDatas.__chatType.TYPE_ANNOUNCEMENT then
        return #LiaoTianDatas.__System
    elseif _type == LiaoTianDatas.__chatType.TYPE_TEAM_CHAT then
        return #LiaoTianDatas.__teamMsg
    end
end
--[[
@type 当前的聊天类型，如果不传则返回是否有未读消息
]]
function LiaoTianDatas.getUnreadMsgByType(_type)
    if not _type then
        for k, v in pairs(LiaoTianDatas.newMsg) do
            if tonumber(v) > 0 then
                return v
            end
        end
    elseif _type == LiaoTianDatas.__chatType.TYPE_WORLD_CHAT then
        return LiaoTianDatas.newMsg._world
    elseif _type == LiaoTianDatas.__chatType.TYPE_BP_CAHT then
        return LiaoTianDatas.newMsg._BP
    elseif _type == LiaoTianDatas.__chatType.TYPE_CAMP_CHAT then
        return LiaoTianDatas.newMsg._camp
    elseif _type == LiaoTianDatas.__chatType.TYPE_ANNOUNCEMENT then
        return LiaoTianDatas.newMsg._system
    elseif _type == LiaoTianDatas.__chatType.TYPE_TEAM_CHAT then
        return LiaoTianDatas.newMsg.__teamMsg
    end
    return 0
end

function LiaoTianDatas.removeNotNeeded()
    local i = 1
    if #LiaoTianDatas.__worldMsg > LiaoTianDatas.MAXMSG then
        for i = LiaoTianDatas.MAXMSG, #LiaoTianDatas.__worldMsg do
            LiaoTianDatas.__worldMsg[i] = nil
        end
    end
    if #LiaoTianDatas.__campMsg > LiaoTianDatas.MAXMSG then
        for i = LiaoTianDatas.MAXMSG, #LiaoTianDatas.__campMsg do
            LiaoTianDatas.__campMsg[i] = nil
        end
    end
    if #LiaoTianDatas.__BPMsg > LiaoTianDatas.MAXMSG then
        for i = LiaoTianDatas.MAXMSG, #LiaoTianDatas.__BPMsg do
            LiaoTianDatas.__BPMsg[i] = nil
        end
    end
    if #LiaoTianDatas.__System > LiaoTianDatas.MAXMSG then
        for i = LiaoTianDatas.MAXMSG, #LiaoTianDatas.__System do
            LiaoTianDatas.__System[i] = nil
        end
    end
    if #LiaoTianDatas.__teamMsg > LiaoTianDatas.MAXMSG then
        for i = LiaoTianDatas.MAXMSG, #LiaoTianDatas.__teamMsg do
            LiaoTianDatas.__teamMsg[i] = nil
        end
    end
end
--- 当有消息来的时候刷新需要刷新的地方
function LiaoTianDatas.dispatchChatMsgs(data)
    XTHD.dispatchEvent( {
        --- 刷新聊天面板
        name = EVENT_NAME_REFRESH_CHATLIST,
        data = data
    } )
    if data and data.hasRead == false then
        LiaoTianDatas.hasNewMsgs = true
        XTHD.dispatchEvent( {
            ----出小红点
            name = EVENT_NAME_CHANGE_CHAT_REDDOT,
            data = { visible = true },
        } )
        XTHD.dispatchEvent( {
            name = CUSTOM_EVENT.SHOW_CHATROOM_CHANNEL_REDDOT,
            data = data.chatType
        } )
    end
    XTHD.dispatchEvent( {
        name = EVENT_NAME_REFRESH_CAMPCHAT_ATCAMP
    } )
    data.hasRead = true
end
--------获取聊天记录
function LiaoTianDatas.getChatRecord()
    if #LiaoTianDatas.__worldMsg > 0 then
        return
    end
    XTHDHttp:requestAsyncInGameWithParams( {
        modules = "chatRecord?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                for k, v in pairs(data.chatList) do
                    -- dump(v,"77777777777777")
                    if v.content ~= nil and v.content ~= "" or v.item ~= nil then
                        local chat = {
                            chatType = v.scope,
                            -- 聊天类型 (1 private chat,8 society chat,16 world chat,20 announcement,32 camp)
                            senderID = v.fromRoleId,
                            -- 发送者ID
                            senderName = v.fromName,
                            -- 发送都名称
                            iconID = v.fromTemplateId,
                            ----头像ID
                            reciverID = v.toRoleId,
                            -- 接收都ID.The value would be 0 while the chat type is not private
                            reciverName = v.toName,
                            -- 接收都名字. The value would be 0 while the chat type is not private
                            chatMsg = v.content,
                            ----聊天内容
                            senderLevel = v.level,
                            -- 发送者等级	
                            senderCampID = v.campId,
                            -- 发送都种族ID
                            senderBPName = v.guildName,
                            -- 发送者公会名字，
                            senderArenaID = v.duanId,
                            -- 发送者竞技场段位ID，
                            senderVIP = v.vipLevel,
                            ----发送者VIP等级
                            msgTime = v.time,
                            ----该消息的服务器时间
                            leaderRange = v.leaderRank,
                            --- 领袖排名
                            skyGuardID = v.guardId,
                            --- 在天外天中获得的守卫ID
                            multiTeamID = v.moreEctypeGroupId,
                            -----队伍 （>0 是多人副本世界邀请，<= 0 都不是）
                            multiConfigID = v.moreEctypeConfigId,
                            -------多人副本静态表第一列ID
                            multiBlackPos = v.moreEctypeSurplusSum,
                            -----多人副本里当前组还有多少个空位
                            shareItem = v.item,-- 服务器返回的json
							titleId = v.titleId
                        }
                        LiaoTianDatas.insertMsg(chat.chatType, false, chat)
                    end
                end
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.NONE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function LiaoTianDatas.reset()
    LiaoTianDatas.__worldMsg = { }
    -- 世界频道的消息
    LiaoTianDatas.__BPMsg = { }
    -- 帮派频道的消息
    LiaoTianDatas.__campMsg = { }
    -- 种族频道的消息
    LiaoTianDatas.__System = { }
    LiaoTianDatas.__teamMsg = { }
    LiaoTianDatas.hasNewMsgs = false
    LiaoTianDatas.newMsg = {
        -- 是否有新的未查看的消息
        _world = 0,
        _camp = 0,
        _BP = 0,
        _system = 0,
        _team = 0,
    }
end