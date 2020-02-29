--[[
authored by LITAO
]]
LiaoTianRoomLayer = class("LiaoTianRoomLayer", function(param)
    return cc.Node:create()
end )

LiaoTianRoomLayer.msgFont = {
    selfSize = 18,
    -- 只是自己可见的消息文字大小
    publicSize = 16,
    -- 公共消息的文字大小
    linkerSize = 16,
    -- 超连接，可点击的文字大小
    playerNameSize = 18-- 玩家名字大小
}
LiaoTianRoomLayer.msgColor = {
    playerNameColor = cc.c3b(70,34,34),
    -- 玩家名字颜色
    publicColor = cc.c3b(105,77,56),
    -- 公共消息文字颜色
    BPNameColor = cc.c3b(62,40,24),
    -- 帮派名字颜色
    CDColor = cc.c4b(59,115,0,255)-- CD颜色
}

LiaoTianRoomLayer.chatCDTime = {
    -- 聊天CD
    world = 15,
    camp = 3,
    bp = 3
}
LiaoTianRoomLayer.__isAtShowing = false
LiaoTianRoomLayer.rooms = { }
LiaoTianRoomLayer.rooms[16] = { CD = 0, scheduling = false, exitTime = 0 } -- 世界
LiaoTianRoomLayer.rooms[32] = { CD = 0, scheduling = false, exitTime = 0 } -- 种族
LiaoTianRoomLayer.rooms[8] = { CD = 0, scheduling = false, exitTime = 0 } -- 帮派
LiaoTianRoomLayer.rooms[20] = { CD = 0, scheduling = false, exitTime = 0 } -- 综合 
LiaoTianRoomLayer.rooms[40] = { CD = 0, scheduling = false, exitTime = 0 } -- 队伍 

LiaoTianRoomLayer.Functions = {
    -----功能们
    MultiplyCopy = "multiplyCopy",
    ----多人副本
    Camp = "camp",----种族
}
function LiaoTianRoomLayer:ctor(btn, darkBG, modeBg)
    self.__parentButton = btn
    self._darkBg = darkBG
    self._modeBg = modeBg
    self._where = nil

    self.Tag = {
        ktag_loadItemSchedule = 100,
        ktag_chatCDScedule = 101,
    }

    self.__actionComplete = true
    self.__campIcon = nil
    -- 输入框左边的图片
    self.__chatBoard = nil
    self.__canUpdateObj = { }
    self.__chatSize = cc.size(0, 0)
    self.__tableViewSize = cc.size(328, 380)
    self.__tableCellSize = cc.size(328, 140)
    self.__sourcePath = IMAGE_KEY_CHATROOM_RES_PATH
    self.__MAXLINES = 4
    -- 显示消息处的最大行数
    self.__perLinesH = 16
    -- 显示的消息每行的最大高度
    self.__sendNodes = { }
    --- 发送按钮（三个频道的）button,word
    self.__redDot = { }
    ----红点

    self._newTipsNode = nil
    ------新消息来的提醒

    self.__badgeIconPath = {
        --- 聊天徽章资源路径
        "res/image/chatroom/chatroom_icon2.png",----称号图标的路径
        "res/image/chatroom/chatroom_icon4.png",----VIP 图标路径
        "res/image/plugin/competitive_layer/competitive_rank_%d%d.png",----竞技场排名前十且分种族徽章
        "res/image/common/rank_icon/rankIcon_%d.png",----段位
        "res/image/camp/camp_marker_logo%d.png",-----种族
    }

    LiaoTianRoomLayer.currentChannel = 20
    --- 当前所在的频道
    ----背景
    local bg = ccui.Scale9Sprite:create("res/image/chatroom/chat_bg.png")
    local pos = cc.p(0, 0)

    local winSize = self._modeBg:getContentSize()
    -- cc.Director:getInstance():getWinSize()
    self:setContentSize(cc.size(winSize.width, winSize.height))

    local size = bg:getContentSize()
    local winSize = cc.Director:getInstance():getWinSize()
    self:setContentSize(cc.size(size.width, winSize.height))

    bg:setContentSize(cc.size(size.width, winSize.height))

    local _back = XTHDPushButton:createWithParams( {
        normalNode = bg,
    } )
    self:addChild(_back)
    _back:setPosition(0, self:getContentSize().height / 2)
    self._back = _back

    self:setAnchorPoint(1, 0.5)
    if self.__parentButton then
        self:setPosition(self.__parentButton:getPositionX() + self._back:getContentSize().width - 10, self:getContentSize().height / 2)
    else
        self:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    end

    local gongaokuang = cc.Sprite:create("res/image/chatroom/gongao.png")
    self._back:addChild(gongaokuang)
    gongaokuang:setPosition(self._back:getContentSize().width * 0.5 + 5, self._back:getContentSize().height - gongaokuang:getContentSize().height - 5)
    self._gongaokuang = gongaokuang

    local lable = cc.Sprite:create("res/image/chatroom/gongaolable.png")
    lable:setAnchorPoint(0, 0.5)
    gongaokuang:addChild(lable)
    lable:setPosition(5, gongaokuang:getContentSize().height * 0.5)

    local gonggaoListview = ccui.ListView:create()
    gonggaoListview:setContentSize(gongaokuang:getContentSize().width - lable:getContentSize().width - 5, gongaokuang:getContentSize().height)
    gonggaoListview:setDirection(ccui.ScrollViewDir.horizontal)
    gonggaoListview:setScrollBarEnabled(false)
    gonggaoListview:setBounceEnabled(true)
    gonggaoListview:setPosition(gonggaoListview:getContentSize().width / 2 - 7, 0)
    gongaokuang:addChild(gonggaoListview)
    gonggaoListview:setTouchEnabled(false)
    self._gonggaoListview = gonggaoListview
    self:PaoMaDeng()

    local close_btn = XTHDPushButton:createWithParams( {
        normalFile = "res/image/chatroom/btn_close_1.png",
        selectedFile = "res/image/chatroom/btn_close_2.png",
    } )
    close_btn:setTouchEndedCallback( function()
        self:showPanel("exit")
    end )
    self._back:addChild(close_btn)
    close_btn:setPosition(cc.p(self._back:getContentSize().width + 5, self._back:getContentSize().height * 0.5))
end

function LiaoTianRoomLayer:CallBack()
    local moveby = cc.MoveBy:create(0.5, cc.p(- self._back:getContentSize().width, 0))
    local animate = cc.Sequence:create(cc.CallFunc:create( function()
        self._back:runAction(moveby)
    end ), cc.DelayTime:create(0.5), cc.CallFunc:create( function()
        self:stopActionByTag(10001)
        if self._schedule then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schedule)
            self._schedule = nil
        end
        self:setDisplayStatu(false)
        self._modeBg:removeFromParent()
        self._darkBg:removeFromParent()
        self:removeFromParent()
    end ))
    self:runAction(animate)
end

function LiaoTianRoomLayer:create(parentBtn, darkBG, modeBg)
    local room = LiaoTianRoomLayer.new(parentBtn, darkBG, modeBg)
    if room then
        room:init()
        room:registerScriptHandler( function(_type)
            if _type == "enter" then
                room:onEnter()
            elseif _type == "exit" then
                room:onExit()
            end
        end )
    end
    return room
end

function LiaoTianRoomLayer:getEffeciantContent()
    return self._back
end

function LiaoTianRoomLayer:init()
    local x = 4
    local y = 5
    self.__chatSize = self:getContentSize()
    ------标题背景
    local titleBG = ccui.Scale9Sprite:create()
    titleBG:setContentSize(546, 64)
    self._back:addChild(titleBG)
    titleBG:setAnchorPoint(0, 1)
    titleBG:setPosition(8, self.__chatSize.height - 70)
    self.__tableViewSize = cc.size(self._back:getContentSize().width - 65, self._back:getContentSize().height - 140)
    self._titleBg = titleBG
    local i = 1
    local x = x
    -- local _type = {20,16,32,8}  ------公告(综合)/世界、种族、帮派
    local _type = { 20, 16, 32, 8, 40, 0 } --0是引导调试用
    ------世界、种族、帮派、队伍
    for i = 1, #_type - 1 do
        local _normal = cc.Sprite:create("res/image/chatroom/chatroom_channel" .. i .. "_1.png")
        local _selected = cc.Sprite:create("res/image/chatroom/chatroom_channel" .. i .. "_2.png")

        local btn_tab = XTHDPushButton:createWithParams( {
            normalNode = _normal,
            selectedNode = _selected,
        } )
        y = self._back:getContentSize().height -((i - 1) * btn_tab:getContentSize().height) -15
        local size = btn_tab:getContentSize()
        btn_tab:setTouchSize(cc.size(size.width, size.height + 20))
        btn_tab:setAnchorPoint(0, 1)
        btn_tab:setPosition(x, y)
        self._back:addChild(btn_tab)
        btn_tab:setTag(_type[i])
        btn_tab.index = i
        -- x = x + btn_tab:getContentSize().width + 5
        btn_tab:setTouchEndedCallback( function()
            if btn_tab:getTag() == 40 and not isInTeam then
                XTHDTOAST("您当前不在队伍中，不能使用该功能！")
                return
            end
            btn_tab:setSelected(true)
            if self._last_tab then
                self._last_tab:setSelected(false)
            end
            self._last_tab = btn_tab
            if self.__sendNodes[LiaoTianRoomLayer.currentChannel] then
                self.__sendNodes[LiaoTianRoomLayer.currentChannel].button:setVisible(false)
            end
            LiaoTianRoomLayer.currentChannel = btn_tab:getTag()
            if self.__sendNodes[LiaoTianRoomLayer.currentChannel] then
                self.__sendNodes[LiaoTianRoomLayer.currentChannel].button:setVisible(true)
            end
            if self.__redDot[LiaoTianRoomLayer.currentChannel] then
                ----去掉红点
                self.__redDot[LiaoTianRoomLayer.currentChannel]:setVisible(false)
                LiaoTianDatas.hasNewMsg[LiaoTianRoomLayer.currentChannel] = false
            end
            self:reloadData()
        end )
        ------红点
        local redDot = cc.Sprite:create("res/image/common/heroList_redPoint.png")
        btn_tab:addChild(redDot)
        redDot:setPosition(btn_tab:getContentSize().width - 10, btn_tab:getContentSize().height - 10)
        self.__redDot[_type[i]] = redDot
        if LiaoTianRoomLayer.currentChannel ~= _type[i] and LiaoTianDatas.hasNewMsg[_type[i]] == true then
            redDot:setVisible(true)
        else
            redDot:setVisible(false)
        end

        if i == 1 then
            btn_tab:setSelected(true)
            self._last_tab = btn_tab
        end
    end

    -- 输入框的背景
    local EditBoxBg = cc.Sprite:create("res/image/chatroom/login_input_bg.png")
    self._back:addChild(EditBoxBg)
    EditBoxBg:setPosition(self._back:getContentSize().width * 0.5 - 10, EditBoxBg:getContentSize().height + 5)

    -- 输入框左边的图片区域
    local icon = nil
    local campID = gameUser.getCampID()
    if campID == 1 then
        --- 天道盟
        icon = XTHDImage:create("res/image/chatroom/chatroom_camp1.png")
    else
        --
        icon = XTHDImage:create("res/image/chatroom/chatroom_camp2.png")
    end
    icon:setScale(0.8)

    self._back:addChild(icon)
    self.__campIcon = icon
    icon:setAnchorPoint(0.5, 0.5)
    icon:setPosition(icon:getContentSize().width * 0.5 + 5, icon:getContentSize().height * 0.5 + 2)
    x, y = icon:getPosition()


    local inputBox = ccui.EditBox:create(EditBoxBg:getContentSize(), ccui.Scale9Sprite:create(), nil, nil)
    inputBox:setFontColor(cc.c3b(52, 25, 25))
    inputBox:setPlaceHolder(LANGUAGE_KEY_INPUT_WORDA)
    -------"请输入你的信息")
    inputBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    inputBox:setAnchorPoint(0.5, 0.5)
    inputBox:setMaxLength(30)
    inputBox:setPosition(EditBoxBg:getPosition())
    inputBox:setPlaceholderFontColor(cc.c3b(52, 25, 25))
    inputBox:setFontName("res/fonts/def.ttf")
    inputBox:setPlaceholderFontName("res/fonts/def.ttf")
    inputBox:setFontSize(22)
    inputBox:setPlaceholderFontSize(22)
    inputBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    inputBox:setText(_name);
    -- inputBox:setVisible(false)

    self._back:addChild(inputBox)
    self.__inputBox = inputBox
    x, y = inputBox:getPosition()

    -- 发送按钮
    for i = 1, 4 do
        local sendButton = XTHDPushButton:createWithParams( {
            normalFile = "res/image/chatroom/liaotian_fs1.png",
            selectedFile = "res/image/chatroom/liaotian_fs2.png",
        } )
        sendButton:setAnchorPoint(0, 0.5)
        sendButton:setLabelColor(cc.c4b(255, 255, 255))
        sendButton:setPosition(self._back:getContentSize().width - sendButton:getContentSize().width - 15, y)
        sendButton:setScale(1)
        self._back:addChild(sendButton, 0)
        sendButton:setTouchEndedCallback( function()
            self:sendMessage()
        end )

        local label = XTHDLabel:create("", 24, "res/fonts/def.ttf")
        label:setColor(cc.c3b(255, 255, 255))
        label:enableOutline(cc.c4b(150, 79, 39, 255), 2)
        sendButton:addChild(label)
        label:setPosition(sendButton:getContentSize().width / 2, sendButton:getContentSize().height / 2 + 2)
        sendButton:setVisible(i == 1)
    end
    --- 如果有频道的聊天CD还没有冷却，则继续
    local now = os.time()
    local needSchedul = false
    for k, v in pairs(LiaoTianRoomLayer.rooms) do
        local past = now - v.exitTime
        if past >= v.CD then
            v.CD = 0
            v.scheduling = false
        else
            v.CD = v.CD - past
            needSchedul = false
        end
        v.exitTime = 0
    end
    if needSchedul then
        self:showColdCD()
    end
    performWithDelay(self, function()

    end , 0.5)
    self:initTabelView(self._back)
    self:showPanel("enter")
end

function LiaoTianRoomLayer:initTabelView(targ)
    local function scrollViewEvent(sender, _type)
        if _type == ccui.ScrollviewEventType.scrollToTop then
            self:removeNewMsgTip()
        end
    end

    local tableView = ccui.ListView:create()
    tableView:setContentSize(self.__tableViewSize.width, self.__tableViewSize.height)
    tableView:setDirection(ccui.ScrollViewDir.vertical)
    tableView:setScrollBarEnabled(false)
    tableView:setBounceEnabled(true)
    tableView:setPosition(targ:getContentSize().width / 2 - self.__tableViewSize.width / 2 + 20, 70)
    tableView:addScrollViewEventListener(scrollViewEvent)
    targ:addChild(tableView)
    self.__msgTableView = tableView
    self:reloadData()
end

function LiaoTianRoomLayer:onEnter()
    LiaoTianDatas.hasNewMsgs = false
    XTHD.addEventListener( {
        name = EVENT_NAME_REFRESH_CHATLIST,
        callback = function(event)
            if self.__msgTableView then
                local msgType = event.data.chatType
                if LiaoTianRoomLayer.currentChannel == msgType or(LiaoTianRoomLayer.currentChannel == 20 and msgType == 36)
                    or(LiaoTianRoomLayer.currentChannel == 20 and msgType == 16) then
                    ----如果在世界聊天显示公告和战报

                    if msgType == 20 then
                        event.data.message = RichLabel:getStringOnly(event.data.message)
                    end

                    local container = self.__msgTableView:getInnerContainer()
                    local x, y = container:getPosition()

                    local node = self:createVeiwCell(event.data)
                    self.__msgTableView:insertCustomItem(node, 0)
                    local size = node:getContentSize()
                    if math.abs(y) + self.__tableViewSize.height < container:getContentSize().height then
                        self:showNewMsgTip()
                        container:setPosition(x, y + size.height)
                    end

                    if #self.__msgTableView:getItems() > 50 then
                        self.__msgTableView:removeLastItem()
                    end
                end
            end
        end
    } )
    XTHD.addEventListener( {
        name = CUSTOM_EVENT.SHOW_CHATROOM_CHANNEL_REDDOT,
        callback = function(event)
            ----给频道显示红点
            local channel = event.data
            channel =(channel == 36 and 20) or channel
            if self.__redDot[channel] and LiaoTianRoomLayer.currentChannel ~= channel then
                self.__redDot[channel]:setVisible(true)
            end
        end
    } )
end

function LiaoTianRoomLayer:onExit()
    XTHD.removeEventListener(EVENT_NAME_REFRESH_CHATLIST)
    XTHD.removeEventListener(CUSTOM_EVENT.SHOW_CHATROOM_CHANNEL_REDDOT)
    self._where = nil

    for k, v in pairs(LiaoTianRoomLayer.rooms) do
        v.exitTime = os.time()
    end
end

function LiaoTianRoomLayer:getDisplayStatu()
    return LiaoTianRoomLayer.__isAtShowing
end

function LiaoTianRoomLayer:setDisplayStatu(statu)
    LiaoTianRoomLayer.__isAtShowing = statu
end

function LiaoTianRoomLayer:reloadData()
    if self.__msgTableView then
        self:removeNewMsgTip()
        self.__msgTableView:removeAllChildren()
        self:stopActionByTag(self.Tag.ktag_loadItemSchedule)

        local data
        local length
        if LiaoTianRoomLayer.currentChannel == 0 then
            data = LiaoTianDatas._helperMsg
        else
            data = LiaoTianDatas.getMsgsByType(LiaoTianRoomLayer.currentChannel)
        end
        length = #data > 50 and 50 or #data

        local function refreshData(index)
            if data[index] then
                if data[index].chatType == LiaoTianDatas.__chatType.TYPE_ANNOUNCEMENT then
                    data[index].message = RichLabel:getStringOnly(data[index].message)
                end
                local node = self:createVeiwCell(data[index])
                self.__msgTableView:pushBackCustomItem(node)
            end
        end

        for i = 1, length do
            ------一进来开始创建十条，其它的每1.5秒创建一条
            refreshData(i)
        end
    end
end

function LiaoTianRoomLayer:createVeiwCell(data)
    local _height = self:getMsgShowingHeight(data, LiaoTianRoomLayer.msgFont.publicSize, self.__tableCellSize.width) + 60
    local _temH = 65
    if _height > _temH then
        _temH = _height
    end
    -------创建一个超连接
    local _linker = nil
    if data.multiConfigID and data.multiConfigID > 0 then
        ----多人副本
        _linker = self:createALinkerWord(string.format("(%s)", LANGUAGE_MULTICOPY_TIPS11), function()
            -----点击加入队伍
            XTHD.acceptMultiCopyInvite( {
                teamID = data.multiTeamID,
                configID = data.multiConfigID
            } )
            self:showPanel("exit")
        end )
    elseif data.reportLogID then
        ------战报
        _linker = self:createALinkerWord(string.format("(%s)", LANGUAGE_TIPS_WORDS283), function()
            ----点击查看记录
            ClientHttp:httpReplayBatlle(nil, data.reportLogID)
            self:showPanel("exit")
        end )
    elseif data.BP and data.BP ~= " " then
        -- 招贤纳士
        -- print("----------------创建加入帮派的超链接-----------------")
        _linker = self:createALinkerWord(string.format("(%s)", "点击加入帮派"), function()
            -----点击加入帮派
            ClientHttp.httpApplyJoinGuild(self, function(data)
                XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildSendedApplyToastXc)
            end , { guildId = tonumber(data.BP) })
        end )
    elseif data.chatType == LiaoTianDatas.__chatType.TYPE_HELPER then
        _linker = self:createALinkerWord(string.format("(%s)", data.message), function()
            -----触发助手引导
            self:showPanel("exit")
            YinDaoMarg:getInstance():triggerGuide(0, data.group)
        end )

        local icon = cc.Sprite:create("res/image/chatroom/chat_system_repbox.png")
        icon:setScale(0.7)
        local background = ccui.Scale9Sprite:create("res/image/chatroom/chat_msg_bg2.png")
        icon:setPosition(self.__tableCellSize.width - 50, _temH - 20)
        background:setPosition(10, _temH / 2)

        background:setContentSize(cc.size(self.__tableCellSize.width - 75, _temH))
        background:setAnchorPoint(0, 0.5)

        background:addChild(_linker)
        _linker:setPosition(30, _linker:getContentSize().height)

        local node = ccui.Layout:create()
        _temH = _temH + _linker:getContentSize().height + 10
        node:setContentSize(cc.size(self.__tableCellSize.width, _temH + 10))
        node:addChild(background)
        return node
    end

    if data["shareItem"] ~= "" and data["shareItem"] ~= nil then
        if type(data["shareItem"]) == "string" then
            local chat = json.decode(data["shareItem"])
            data["shareItem"] = chat
        end
        _linker = self:createSharebtn(data)
    end

    local node = ccui.Layout:create()
    if _linker then
        _temH = _temH + _linker:getContentSize().height + 10
    end
    node:setContentSize(cc.size(self.__tableCellSize.width, _temH + 10))
    if node then
        ----头像
        local icon = nil
        local background = nil
        if data.chatType == LiaoTianDatas.__chatType.TYPE_ANNOUNCEMENT or data.chatType == LiaoTianDatas.__chatType.TYPE_FIGHTREPORT then
            ----公告/战报
            icon = cc.Sprite:create("res/image/chatroom/chat_system_repbox.png")
            icon:setScale(0.7)
            background = ccui.Scale9Sprite:create("res/image/chatroom/chat_msg_bg2.png")
            icon:setPosition(self.__tableCellSize.width - 50, node:getContentSize().height - 30)
            background:setPosition(10, node:getContentSize().height / 2)
        else
            background = ccui.Scale9Sprite:create("res/image/chatroom/chat_msg_bg1.png")
            icon = self:createIcon(data.iconID, data.badge[1], data.level, data.senderID)
            icon:setPosition(10, node:getContentSize().height - 30)
            background:setPosition(icon:getContentSize().width + icon:getPositionX() -35, node:getContentSize().height / 2)
        end
        node:addChild(icon)
        icon:setAnchorPoint(0, 1)
        --- 上面背景
        background:setContentSize(cc.size(self.__tableCellSize.width - 75, _temH - 10))
        background:setAnchorPoint(0, 0.5)
        node:addChild(background)

        ----
        local content = cc.Node:create()
        content:setContentSize(background:getContentSize())
        content:setAnchorPoint(0, 0.5)
        node:addChild(content)
        content:setPosition(background:getPosition())
        --- 时间
        local time = HaoYouPublic.getTimeStr(data.msgTime)
        local timeLabel = XTHDLabel:createWithSystemFont(time, "Helvetica", 16)
        -- timeLabel:setColor(LiaoTianRoomLayer.msgColor.publicColor)
        content:addChild(timeLabel)
        timeLabel:setAnchorPoint(1, 0.5)
        timeLabel:setVisible(false)
        -------暂时隐藏掉时间
        --------
        local x = 30
        local y = 0
        if data.senderID and data.senderID == gameUser.getUserId() then
            -----如果是自己发的消息
            icon:setAnchorPoint(1, 0.5)
            icon:setPosition(self.__tableCellSize.width - 8, node:getBoundingBox().height / 2)
            background:setFlippedX(true)
            print("自己的消息", icon:getPositionX() - icon:getBoundingBox().width - 14 + 18)
            background:setPosition(8, node:getBoundingBox().height / 2)
            content:setAnchorPoint(0, 0.5)
            content:setPosition(background:getPosition())
            x = 18
        end
        ----
        if data.chatType == LiaoTianDatas.__chatType.TYPE_ANNOUNCEMENT or data.chatType == LiaoTianDatas.__chatType.TYPE_FIGHTREPORT then
            ----公告/战报
            ----
            local _icon = cc.Sprite:create("res/image/chatroom/chat_announce_icon.png")
            content:addChild(_icon)
            _icon:setAnchorPoint(0, 0.5)
            _icon:setPosition(x - 20, content:getContentSize().height - _icon:getContentSize().height / 2 - 5)
            --- 系统公告
            local _title = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_SYSTEMTIPS .. ":", "Helvetica", 18)
            _title:setColor(XTHD.resource.color.gray_desc)
            content:addChild(_title)
            _title:setAnchorPoint(0, 0.5)
            _title:setPosition(_icon:getPositionX() + _icon:getContentSize().width, _icon:getPositionY())
            local msg = self:createMsg(data.message, _height)
            content:addChild(msg)
            msg:setAnchorPoint(cc.p(0, 1))
            msg:setPosition(_icon:getPositionX(), _title:getPositionY() - _title:getContentSize().height / 2 - 5)
            timeLabel:setPosition(content:getContentSize().width - 25, _title:getPositionY())

            background:setContentSize(cc.size(self.__tableCellSize.width - 70, _temH - 10))
        else
            -----玩家名字，等级，徽章
            local temSize = node:getContentSize()
            local fontSize = LiaoTianRoomLayer.msgFont.playerNameSize
            local color = LiaoTianRoomLayer.msgColor.playerNameColor
            -- 名字
            local name = XTHDLabel:createWithSystemFont(tostring(data.name), "Helvetica", 14)
            name:setColor(XTHD.resource.color.gray_desc)
            content:addChild(name)
            name:setAnchorPoint(0, 0.5)
            name:setPosition(x - 5, content:getBoundingBox().height - name:getContentSize().height / 2 - 5)

			timeLabel:setPosition(content:getContentSize().width - 20, name:getPositionY())
			local i = 1
			if data.titleId ~= nil and data.titleId > 0 then
				local _titleInfo = gameData.getDataFromCSV("TitleInfo",{id = data.titleId})
				local _color = string.split(_titleInfo.rgb,"，")
				local tilteName = XTHDLabel:create("《".._titleInfo.name.."》",14)
				tilteName:setAnchorPoint(0,0.5)
				tilteName:setColor(cc.c3b(255,0,130))
				content:addChild(tilteName)
				tilteName:setPosition(name:getPositionX() + name:getContentSize().width,name:getPositionY())

				x, y = tilteName:getPosition()
				-- 徽章

				x = x + tilteName:getBoundingBox().width + 5
				y = y - tilteName:getBoundingBox().height / 2 - 2
			else
				x, y = name:getPosition()
				-- 徽章
           
				x = x + name:getBoundingBox().width + 5
				y = y - name:getBoundingBox().height / 2 - 2
			end
		
			
            if data.badge[2] > 0 then
                local icon = cc.Sprite:create("res/image/vip/vipl_0" .. tonumber(data.badge[2]) .. ".png")
                icon:setScale(0.3)
                if icon then
                    content:addChild(icon)
                    icon:setAnchorPoint(0, 0.5)
                    icon:setPosition(x, name:getPositionY())
                    y = icon:getPositionY() - icon:getBoundingBox().height / 2 - 10
                end
            end
            --- 消息内容
            local msg = self:createMsg(data.message, _height)
            content:addChild(msg)
            msg:setAnchorPoint(cc.p(0, 1))
            msg:setPosition(name:getPositionX(), y + 5)
        end
        if (data.chatType == LiaoTianDatas.__chatType.TYPE_WORLD_CHAT or data.chatType == LiaoTianDatas.__chatType.TYPE_FIGHTREPORT) and _linker then
            content:addChild(_linker)
            _linker:setPosition(30, _linker:getContentSize().height)
        end
    end
    return node
end

function LiaoTianRoomLayer:createMsg(mesg, height)
    local color = LiaoTianRoomLayer.msgColor.publicColor
    if gameUser.getCampID() == 1 and LiaoTianRoomLayer.currentChannel == 32 then
        ----天道盟
        color = cc.c3b(223, 106, 3)
    elseif gameUser.getCampID() == 2 and LiaoTianRoomLayer.currentChannel == 32 then
        --- 逆天营
        color = cc.c3b(14, 159, 206)
    end
    local str = mesg
    local msg = XTHDLabel:createWithSystemFont(str, "Helvetica", LiaoTianRoomLayer.msgFont.publicSize)
    msg:setTextColor(cc.c4b(105, 77, 56, 255))
    msg:setContentSize(cc.size(self.__tableCellSize.width - 103, height))
    msg:setDimensions(self.__tableCellSize.width - 103, height)
    return msg
end

function LiaoTianRoomLayer:showOperDialog(index)
    --- be triggered by clicked the players' name
    local function checkTheDetail()
        print("check the player's detail")
    end

    local function addToFriend()
        print("add to friend")
    end

    local dialog = XTHDConfirmDialog:createWithParams( {
        leftText = LANGUAGE_KEY_CHECK_FRIEND_DETAIL,
        rightText = LANGUAGE_KEY_ADD_TO_FRIEND,
        leftCallback = checkTheDetail,
        rightCallback = addToFriend
    } )
    local targ = self:getParent()
    if targ then
        targ:addChild(dialog)
        dialog:setLocalZOrder(self:getLocalZOrder() + 1)
    end
end

function LiaoTianRoomLayer:calcWordDisplayLines(index)
    local data = LiaoTianDatas.getMsgsByType(LiaoTianRoomLayer.currentChannel)
    if data and #data >= index then
        data = data[index]
        if data and _G.next(data) then
            local str = data.message
            local len = string.len(str)
            return math.ceil(len / 70)
        end
    end
    return 1
end
------计算消息实际显示时的高度
function LiaoTianRoomLayer:getMsgShowingHeight(data, fontSize, maxWidth)
    if data and next(data) then
        local str = XTHDLabel:createWithSystemFont(data.message, XTHD.SystemFont, fontSize)
        str:setWidth(maxWidth - 40)
        local size = str:getContentSize()
        return size.height
    end
    return 0
end

function LiaoTianRoomLayer:sendMessage()
    if LiaoTianRoomLayer.rooms[LiaoTianRoomLayer.currentChannel].scheduling then
        XTHDTOAST(LANGUAGE_TOASTE_CANNOTSEND)
        return
    elseif gameUser.getLevel() < 26 then
        -----
        XTHDTOAST(string.format(LANGUAGE_MAINCITY_TIPS17, "26"))
        return
    end
    if self.__inputBox then
        local msg = self.__inputBox:getText()
        self.__inputBox:setText("")
        local _channel =(LiaoTianRoomLayer.currentChannel == 20) and 16 or LiaoTianRoomLayer.currentChannel
        ----如果是在综合频道发的走世界聊天
        if msg and type(msg) == "string" and msg ~= "" then
            local object = SocketSend:getInstance()
            if object then
                object:writeInt(_channel)
                object:writeInt(0)
                object:writeString(msg)
                object:send(MsgCenter.MsgType.CLIENT_REQUEST_CHAT)
            end
            if _channel == 16 then
                ------系统（综合）/世界
                LiaoTianRoomLayer.rooms[16].CD = 15
                LiaoTianRoomLayer.rooms[20].CD = 15
            else
                LiaoTianRoomLayer.rooms[_channel].CD = 3
            end
            self:showColdCD()
            local str = string.format("冷却:%d", LiaoTianRoomLayer.rooms[LiaoTianRoomLayer.currentChannel].CD)
        else
            XTHDTOAST(LANGUAGE_TIPS_WORDS12)
            -----"不能发送空内容")
        end
    end
end

function LiaoTianRoomLayer:showColdCD()
    ------------------------------------------------------------------------------------------------------------------------------
    local function worldTick()
        local times = 0
        ----记录是否是四个频道的倒计时都完了
        for k, v in pairs(LiaoTianRoomLayer.rooms) do
            if v.CD > 0 then
                v.CD = v.CD - 1
                local str = string.format("冷却:%d", v.CD)
                v.scheduling = false
            else
                v.scheduling = false
                v.CD = 0
                v.exitTime = 0
                times = times + 1
            end
            if times >= 4 then
                self:stopActionByTag(self.Tag.ktag_chatCDScedule)
            end
        end
    end
    ------------------------------------------------------------------------------------------------------------------------------
    if not self:getActionByTag(self.Tag.ktag_chatCDScedule) then
        schedule(self, worldTick, 1.0, self.Tag.ktag_chatCDScedule)
    end
end

--- 显示与关闭聊天面板 
function LiaoTianRoomLayer:showPanel(what)
    if self.__parentButton and self.__actionComplete then
        self.__actionComplete = false
        local action = nil
        local callback = nil
        local time = 0.4
        local rate = 0.3

        local offsetX = self._back:getContentSize().width - 5
        local action = nil
        if what and what == "enter" then
            LiaoTianRoomLayer.__isAtShowing = true
            action = cc.MoveBy:create(time, cc.p(self._back:getContentSize().width * 0.5, 0))
            callback = cc.CallFunc:create( function()
                self.__actionComplete = true
            end )
        elseif what and what == "exit" then
            LiaoTianRoomLayer.__isAtShowing = false
            action = cc.MoveBy:create(time, cc.p(- self._back:getContentSize().width, 0))
            callback = cc.CallFunc:create( function()
                self:stopActionByTag(10001)
                if self._darkBg then
                    self._darkBg:removeFromParent()
                end

                if self._modeBg then
                    self._modeBg:removeFromParent()
                end
                self:removeFromParent()
                self.__actionComplete = true
            end )
        end
        if action and callback then
            -- 执行动作
            self._back:runAction(cc.Sequence:create(action, callback))
        end
    end
end
-----创建头像
function LiaoTianRoomLayer:createIcon(iconID, campID, level, senderID)
    if not iconID or iconID == 0 then
        iconID = 1
    end
    local normalNode = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById(iconID))
    local selectedNode = cc.Sprite:createWithTexture(normalNode:getTexture())
    selectedNode:setScale(0.9)
    local icon = XTHDPushButton:createWithParams( {
        normalNode = normalNode,
        selectedNode = selectedNode,
        needSwallow = false,
        enable = (senderID ~= gameUser.getUserId())
    } )
    icon.senderID = senderID
    icon:setTouchEndedCallback( function()
        if senderID == gameUser.getUserId() or self._where == LiaoTianRoomLayer.Functions.MultiplyCopy then
            ----如果是自己或者是在多人副本里
            return
        end
        if IS_MULTICOPYPREPARELAYER_EXIT then
            XTHDTOAST(LANGUAGE_MULTICOPY_TIPS16)
            return
        end
        local function showFirendInfo(...)
            self._darkBg:setVisible(false)
            self._modeBg:setVisible(false)
            self:setVisible(false)
            HaoYouPublic.showFirendInfo(senderID, self._darkBg, self:getParent():getLocalZOrder())
        end
        local pData = HaoYouPublic.getFriendData()
        if not pData then
            HaoYouPublic.httpGetFriendData(self, showFirendInfo)
        else
            showFirendInfo()
        end
    end )
    local iconBox = cc.Sprite:create("res/image/plugin/competitive_layer/hero_board" .. campID .. ".png")
    iconBox:setScale(0.9)
    if iconBox and icon then
        icon:addChild(iconBox, -1)
        iconBox:setPosition(icon:getBoundingBox().width / 2, icon:getBoundingBox().height / 2)
        icon:setScale(0.5)
        -----level
        local _level = getCommonWhiteBMFontLabel(level)
        if _level then
            icon:addChild(_level)
            _level:setAnchorPoint(0, 0.5)
            _level:setPosition(5, _level:getBoundingBox().height / 2 - 10)
        end
        local campIcon = cc.Sprite:create("res/image/homecity/camp_icon" .. campID .. ".png")
        if campIcon then
            icon:addChild(campIcon)
            campIcon:setPosition(icon:getContentSize().width, 10)
        end
        -- end
    end
    return icon
end

function LiaoTianRoomLayer:showNewMsgTip()
    if not self._newTipsNode then
        local str = LANGUAGE_TIPS_WORDS14
        ------"你有条新消息哦！"
        local word = XTHDLabel:createWithSystemFont(str, XTHD.SystemFont, 20)

        local tipsBg = ccui.Scale9Sprite:create("res/image/common/tips_bg.png")
        tipsBg:setContentSize(cc.size(word:getContentSize().width + 20, 40))
        tipsBg:addChild(word)
        word:setPosition(tipsBg:getContentSize().width / 2, tipsBg:getContentSize().height / 2)
        if self._titleBg then
            self._titleBg:getParent():addChild(tipsBg)
            tipsBg:setAnchorPoint(1, 1)
            tipsBg:setPosition(self.__msgTableView:getPositionX() + self.__msgTableView:getContentSize().width - 15, self.__msgTableView:getPositionY() + self.__msgTableView:getContentSize().height)
        end
        self._newTipsNode = tipsBg
    end
end

function LiaoTianRoomLayer:removeNewMsgTip()
    if self._newTipsNode then
        local action = cc.FadeOut:create(0.5)
        self._newTipsNode:runAction(cc.Sequence:create(action, cc.CallFunc:create( function()
            self._newTipsNode:removeFromParent()
            self._newTipsNode = nil
        end )))
    end
end

function LiaoTianRoomLayer:createALinkerWord(str, clickFunc)
    local _container = ccui.Layout:create()
    local _word = XTHDLabel:createWithSystemFont(str, XTHD.SystemFont, LiaoTianRoomLayer.msgFont.publicSize)
    _word:setColor(cc.c3b(10, 10, 0xff))
    _word:enableShadow(cc.c4b(10, 10, 0xff, 0xff), cc.size(1, 0))
    _container:setContentSize(_word:getContentSize())
    _container:addChild(_word)
    _word:setPosition(_container:getContentSize().width / 2, _container:getContentSize().height / 2 - 10)
    ------按钮
    local _button = XTHDPushButton:createWithParams( { isScrollView = false })
    _button:setTouchSize(cc.size(_word:getContentSize().width + 30, _word:getContentSize().height + 10))
    _container:addChild(_button)
    _button:setPosition(_container:getContentSize().width / 2, _container:getContentSize().height / 2)
    _button:setTouchEndedCallback( function()
        -- if self._where == LiaoTianRoomLayer.Functions.MultiplyCopy then ------如果是从多人副本发出的
        if IS_MULTICOPYPREPARELAYER_EXIT then
            XTHDTOAST(LANGUAGE_MULTICOPY_TIPS15)
        else
            if clickFunc then
                clickFunc()
            end
        end
    end )
    ------下画线
    local _line = cc.Sprite:create("res/image/common/line_1.png")
    _line:setScaleX(_word:getContentSize().width / _line:getContentSize().width)
    _container:addChild(_line)
    _line:setPosition(_word:getPositionX(), -10)
    return _container
end
	
function LiaoTianRoomLayer:createSharebtn(itme_data)
    local data = itme_data.shareItem
    local _container = ccui.Layout:create()
    _container:setAnchorPoint(0, 0.5)
    local info = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = data.propet.itemId })
    local str = info.name
    local _word = XTHDLabel:create(str, 16, "res/fonts/def.ttf")
    _word:setAnchorPoint(0, 0.5)
    _word:setColor(XTHD.resource.btntextcolor.green)
    -- _word:enableShadow(cc.c4b(10,10,0xff,0xff),cc.size(1,0))
    _container:setContentSize(_word:getContentSize().width, _word:getContentSize().height - 20)
    _container:addChild(_word)
    _word:setPosition(-11, _word:getContentSize().height / 2 + 10)
    ------按钮
    local _button = XTHDPushButton:createWithParams( {
    } )
    _button:setTouchSize(cc.size(_word:getContentSize().width + 10, _word:getContentSize().height + 10))
    _container:addChild(_button)
    _button:setPosition(_container:getContentSize().width / 2 - 11, _container:getContentSize().height / 2 + 20)
    _button:setTouchEndedCallback( function()
        local XingNangSellPop = requires("src/fsgl/layer/LiaoTian/LiaoTianShare.lua"):create(data)
        self:getParent():addChild(XingNangSellPop, self:getLocalZOrder() + 10)
    end )

    ------下画线
    local _line = cc.Sprite:create("res/image/common/line_1.png")
    _line:setAnchorPoint(0, 0.5)
    _line:setScaleX(_word:getContentSize().width / _line:getContentSize().width)
    _container:addChild(_line)
    _line:setPosition(_word:getPositionX(), _word:getPositionY() - _word:getContentSize().height * 0.5)
    return _container
end

function LiaoTianRoomLayer:PaoMaDeng()
    local lable = XTHDLabel:create("哈塞给哈塞给哈塞给哈塞给哈塞给哈塞给哈塞给哈塞给哈塞给哈塞给", 18, "res/fonts/def.ttf")
    self._gonggaoListview:addChild(lable)
    lable:setAnchorPoint(0, 0.5)
    lable:setColor(XTHD.resource.textColor.red_text)
    lable:setPosition(self._gonggaoListview:getContentSize().width, self._gonggaoListview:getContentSize().height * 0.5)
    print("===================>>>", lable:getContentSize().width)
    schedule(self, function()
        lable:setPositionX(lable:getPositionX() -0.5)
        if math.abs(lable:getPositionX()) > lable:getContentSize().width + self._gonggaoListview:getContentSize().width then
            lable:setString("滴滴滴滴滴滴")
            lable:setPositionX(self._gonggaoListview:getContentSize().width)
        end
    end , 0.01, 10001)
end

------设置当前聊天窗是在哪里
function LiaoTianRoomLayer:setTheFrom(where)
    self._where = where
end