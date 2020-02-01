--[[
	竞技战报界面
]]
-- local MailDataType = {
--     defend = 1,-- 防守日志
--     attack = 2,-- 进攻日志
-- }	
local JingJiBattleReport = class( "JingJiBattleReport", function ()
	return XTHD.createBasePageLayer()
end)

function JingJiBattleReport:ctor(net_data)

    -- 设置该界面的所有信息
    if self.m_AllData == nil then
        self.m_AllData = {}
    end
    -- 设置防守日志信息
    self._defendData = net_data["defend"] or {}
    -- 设置攻击日志信息
    self._attackData = net_data["attack"] or {}

    self._tabState = nil  
    self:initUI()
end

--[[
	创建UI
]]
function JingJiBattleReport:initUI()
    local width = self:getContentSize().width
    local height = self:getContentSize().height

    self._red_point = nil

    local background = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    background:setPosition(cc.p(width/2,(height - self.topBarHeight)/2  ))
	self._bg = background
    self:addChild(background)

	local title = "res/image/public/zhanbao_title.png"
	XTHD.createNodeDecoration(self._bg,title)

    --屏幕大小的sprite,用于存放管理各个活动界面的sprite和tableview
    local _bgSprite = cc.Sprite:createWithTexture(nil, cc.rect(0,0,922,576))
    _bgSprite:setOpacity(0)
    _bgSprite:setAnchorPoint(cc.p(0.5,0.5))
    _bgSprite:setPosition(cc.p(background:getContentSize().width/2,background:getContentSize().height/2))
    background:addChild(_bgSprite)
    -- self._bg = _bgSprite

    -- 背景图
    local _bg = cc.Sprite:create("res/image/common/tab_contentBg.png")
    _bg:setOpacity(0)
    _bg:setPosition( cc.p(self:getContentSize().width-_bg:getContentSize().width/2-63,self:getContentSize().height/2 - self.topBarHeight/2) )
    _bg:setName("_bg")
    self:addChild( _bg,1)

    -- 背景宽/高
    local bgWidth = _bg:getContentSize().width
    local bgHeight = _bg:getContentSize().height 

    -- 右边的2个按钮
    self._btnSet = {}

    local normal_file = {"res/image/plugin/competitive_layer/battlereport/def_normal.png","res/image/plugin/competitive_layer/battlereport/att_normal.png"}
    local selected_file = {"res/image/plugin/competitive_layer/battlereport/def_selected.png","res/image/plugin/competitive_layer/battlereport/att_selected.png",}

    local _target_posx = self._bg:getContentSize().width
    local init_posY = self._bg:getContentSize().height
    
    for i = 1, 2 do
        local pageItem = XTHDPushButton:createWithParams({
                normalNode      = getCompositeNodeWithImg("res/image/common/btn/btn_tabClassify_normal.png",normal_file[i]),
                selectedNode    = getCompositeNodeWithImg("res/image/common/btn/btn_tabClassify_selected.png",selected_file[i]),
                needSwallow = true,
                musicFile = XTHD.resource.music.effect_btn_common,
                enable = true,
            })
        pageItem:setScale(0.7)
        pageItem:setAnchorPoint( cc.p(1, 1) )
        pageItem:setPosition( cc.p(self._bg:getContentSize().width - pageItem:getContentSize().width / 2 + 13, init_posY-(i-1)*85 - 20))
        self._bg:addChild( pageItem)
        pageItem:setTouchEndedCallback( function ()
            self:_changeBtnStatus(i)
        end)

        self._btnSet[i] = pageItem
    end
    --如果没有数据，则显示提示语
    local textTip = {LANGUAGE_TIPS_WORDS126, LANGUAGE_TIPS_WORDS127}
    self._tip = {}
    for i = 1, 2 do
        local tip_msg = XTHDLabel:createWithParams({
            text = textTip[i],-----"你还没有抢夺过任何玩家!",
            fontSize = 25,
            color = cc.c3b(70, 34, 34)
            })
        tip_msg:setPosition(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2)
        self._bg:addChild(tip_msg)
        tip_msg:setVisible(false)
        self._tip[i] = tip_msg
    end



	--[[
        下面为构建防御战报界面
    ]]
    local tablePosy = (self._bg:getContentSize().height-background:getContentSize().height)/2-self.topBarHeight/2+30
    local reportTablview = cc.TableView:create( cc.size(self._bg:getContentSize().width-100, bgHeight + 5) )
    reportTablview:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
    reportTablview:setPosition( cc.p(28, tablePosy + 7.5) )
    reportTablview:setVerticalFillOrder( cc.TABLEVIEW_FILL_BOTTOMUP )
    reportTablview:setBounceable(true)
    reportTablview:setDelegate()
    self._bg:addChild(reportTablview,2)

    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        return self:numberOfCellsInTableView( table )
    end
    local function cellSizeForTable( table, idx )
        return self:cellSizeForTable( table, idx )
    end
    local function tableCellAtIndex( table, idx )
        return self:tableCellAtIndex( table, idx )
    end
    reportTablview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    reportTablview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    reportTablview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._reportTablview = reportTablview
    -- reportTablview:reloadData()



    -- 初始化右方按钮
    self:_changeBtnStatus(1)
end

    -- 根据按钮状态，显示不同界面
function JingJiBattleReport:_changeBtnStatus(btntype)

    --相同的按钮
    if self._tabState == btntype then
    else
        self._tabState = self._tabState == nil and 2 or self._tabState
        --处理按钮
        self._btnSet[btntype]:setSelected(true)
        self._btnSet[btntype]:setLocalZOrder(2)
        self._btnSet[self._tabState]:setSelected(false)
        self._btnSet[self._tabState]:setLocalZOrder(0)

        self._tabState = btntype

        if btntype == 1 then --防守
            self._tip[2]:setVisible(false)
            if table.nums(self._defendData) == 0 then
                self._tip[1]:setVisible(true)
            elseif table.nums(self._defendData) > 0 then
                self._tip[1]:setVisible(false)
            end

        elseif btntype == 2 then --进攻
            self._tip[1]:setVisible(false)
            if table.nums(self._attackData) == 0 then
                self._tip[2]:setVisible(true)
            elseif table.nums(self._attackData) > 0 then
                self._tip[2]:setVisible(false)
            end
        end
        self._reportTablview:reloadData()
        
    end
end

--[[
    tableView的回调事件
]]
function JingJiBattleReport:numberOfCellsInTableView( table )
    if self._tabState == 1 then 
        return #self._defendData 
    else
        return #self._attackData 
    end  
end

function JingJiBattleReport:cellSizeForTable( table, idx )
    return self._reportTablview:getContentSize().width, 135 
end

function JingJiBattleReport:tableCellAtIndex( table, idx )
    local cell = table:dequeueCell()
    if cell then
        cell:removeFromParent()
    end
    if self._tabState == 1 then
        return self:getReportItem( 1, idx+1 )
    elseif self._tabState == 2 then
        return self:getReportItem( 2, idx+1  )
    end
    return nil;
end

function JingJiBattleReport:getReportItem( kReportType, index )
    --[[
        构建队伍信息
    ]]
    -- 做当前队伍id使用的临时变量
    local _teamId = 1;
    -- 获取当前人物的信息
    local function _getThePlayerData()
        local _theReportList = kReportType == 1 and self._defendData or self._attackData

        if _theReportList == nil or next(_theReportList) == nil then
            return {}
        end
        if index > #_theReportList then
            return {}
        end
        -- 这个时候，该数据结构为{ ["teamId"] = xx, [team] = { [["petId"] = xx, ["level"] = xx, ["star"] = xx, ["phase"] = xx ] } }
        local _reportData = _theReportList[index];
        if _reportData == nil or next(_reportData) == nil then
            return {}
        end
        return _reportData;
    end
    -- 获取所有队伍信息
    local function _getAllTeamsData()
        local _reportData = _getThePlayerData()
        -- 获取队伍列表
        local _teamsData = _reportData["teams"]
        return _teamsData or {}
    end
    -- 获取当前队伍信息
    local function _getTheTeamData()
        local _teamsData = _getAllTeamsData();
        if _teamsData == nil or next(_teamsData) == nil then
            return {}
        end
        -- 获取对应队伍的英雄信息
        if _teamId > #_teamsData then
            return {}
        end
        local _theTeamData = _teamsData[_teamId]
        if _theTeamData == nil or next(_theTeamData) == nil then
            return {}
        end

        -- 取出对应team中的数据进行构建英雄列表
        local _herosInfo = _theTeamData["team"]
        return _herosInfo or {}
    end

    -- 保存该人物信息的临时变量
    local _thePlayerData = _getThePlayerData()

    -- 背景底图
    -- local _bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_26.png")
    local _bg = ccui.Scale9Sprite:create("res/image/common/shenqing_bg.png")
    _bg:setContentSize(self._reportTablview:getContentSize().width - 5,135)
    local bgWidth = _bg:getContentSize().width;
    local bgHeight = _bg:getContentSize().height;


    local _cell = cc.TableViewCell:new()
    _cell:setContentSize( self._reportTablview:getContentSize().width, 135)

    _bg:setPosition( cc.p(bgWidth*0.5, bgHeight*0.5) )
    _cell:addChild( _bg )

    -- 防守胜利或失败提示后的背景图
    local _winOrLoseTipBgFilePath = "res/image/plugin/competitive_layer/battlereport/shibai.png"
    local _winOrLoseBgFilePath = "res/image/plugin/competitive_layer/battlereport/bg_1.png"
    
    if kReportType == 1 then
        if _thePlayerData["result"] and tonumber(_thePlayerData["result"]) == 1 then
            _winOrLoseTipBgFilePath = "res/image/plugin/competitive_layer/battlereport/shengli.png"
        else
            _winOrLoseTipBgFilePath = "res/image/plugin/competitive_layer/battlereport/shibai.png"
        end
    elseif kReportType == 2 then
        if _thePlayerData["result"] and tonumber(_thePlayerData["result"]) == 1 then
            _winOrLoseTipBgFilePath = "res/image/plugin/competitive_layer/battlereport/attack_success.png"
        else
            _winOrLoseTipBgFilePath = "res/image/plugin/competitive_layer/battlereport/attack_fail.png"
        end
    end

    if _thePlayerData["result"] and tonumber(_thePlayerData["result"]) == 1 then
        _winOrLoseBgFilePath = "res/image/plugin/competitive_layer/battlereport/bg_1.png"
    else
        _winOrLoseBgFilePath = "res/image/plugin/competitive_layer/battlereport/bg_2.png"
    end

    local _winOrLoseBg = cc.Sprite:create( _winOrLoseBgFilePath )
    _winOrLoseBg:setAnchorPoint( cc.p(0, 1) )
    _winOrLoseBg:setPosition( cc.p(7, bgHeight-6) )
    _winOrLoseBg:setScale(0.9)
    _bg:addChild( _winOrLoseBg )

    local _winOrLoseFont = cc.Sprite:create( _winOrLoseTipBgFilePath );
    _winOrLoseFont:setPosition(_winOrLoseFont:getContentSize().width/2+30,_winOrLoseBg:getContentSize().height/2)
    _winOrLoseBg:addChild(_winOrLoseFont)
   
   

    function show_challenge_msg( liuyan_id )
        if tonumber(liuyan_id) == 0 then
            liuyan_id = 1
        end
        -- 防守日志显示   --result = 1 胜利，=0 失败
        if kReportType == 1 then  
            if _thePlayerData["result"] and tonumber(_thePlayerData["result"]) == 0 then
                local msg_1 = gameData.getDataFromCSV("PlunderMessage",{id = liuyan_id})
                if type(msg_1) == "table" then
                    local msg = LANGUAGE_MAIL_FORMAT1(msg_1["msg"])
                    return msg , cc.c3b(78,48,13)
                end
            else
                local msg_1 = gameData.getDataFromCSV("PlunderMessage",{id = liuyan_id})
                if type(msg_1) == "table" then
                    return msg_1["msg"] , cc.c3b(78,48,13)
                end
            end
        end

         -- 进攻日志显示
        if kReportType == 2 then
            --result = 1 胜利，=0 失败
            if _thePlayerData["result"] and tonumber(_thePlayerData["result"]) == 1 then
                local msg_1 = gameData.getDataFromCSV("PlunderMessage",{id = liuyan_id})
                if type(msg_1) == "table" then
                    local msg = LANGUAGE_MAIL_FORMAT2(msg_1.msg)------- "你说:\""..msg_1["msg"]
                    return msg ,cc.c3b(78,48,13)
                end
            else
                local msg_1 = gameData.getDataFromCSV("PlunderMessage",{id = liuyan_id})
                if type(msg_1) == "table" then
                    return msg_1["msg"] , cc.c3b(78,48,13)
                end
            end
        end
    end


    -- 留言
    -- local _labMessageText = "对您说:\"手下败将,有本事来挑战我啊\""   --使用messageId从表中获取数据 
    local _labMessageText,font_color = show_challenge_msg( _thePlayerData["messageId"] or 1 )
    local _labMessage = XTHDLabel:createWithParams( {
            ["text"] = _labMessageText ,
            ["size"] = 16,
            ["color"] = font_color
        } );
    _labMessage:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(0.5,-0.5))
    _labMessage:setAnchorPoint( cc.p(0, 0.5) )
    _labMessage:setPosition( cc.p(bgWidth*0.245-43, _winOrLoseBg:getPositionY() - _winOrLoseBg:getBoundingBox().height*0.5 - 3) );
    _bg:addChild( _labMessage )


    function __getFormatTimer( diffTime )
        local day_time = 24*60
        local hour_time = 60
        local timer = math.floor(diffTime/day_time)

        --显示天数
        if tonumber(timer) > 1 then
            local hour = (diffTime%day_time)/hour_time
            if math.floor(hour) == 0 then
                return LANGUAGE_TIME_FORMAT1(timer)---"%d天前",timer)
            else
                return LANGUAGE_TIME_FORMAT2(timer,math.floor(hour))----"%d天%d小时前",timer,hour)
            end
            
        else
            --显示小时数
            if (diffTime/hour_time)>1 then
                local hour = diffTime/hour_time
                local minute = (diffTime%hour_time)%60
                return LANGUAGE_TIME_FORMAT3(math.floor(hour),minute)----"%d小时%d分钟前",hour,minute)
            --显示分钟数
            else
                local minute = diffTime%60
                return LANGUAGE_TIME_FORMAT4(minute)----"%d分钟前",minute)
            end
        end
    end

    local _labTime = XTHDLabel:createWithParams( {
            ["text"] = __getFormatTimer( _thePlayerData["diffTime"] ) ,
            ["size"] = 18,
            ["color"] = cc.c3b(78, 48, 13)
        } );
    _labTime:setAnchorPoint( cc.p(0.5, 0.5) )
    _labTime:setPosition( cc.p(bgWidth*0.97-110, _labMessage:getPositionY() + 5) )
    _bg:addChild( _labTime )
	_labTime:enableBold()

    --[[
        关于攻击/防守 -- 胜利/失败 的布局
        攻击    1. 胜利 只有获得的情况
                2. 失败 获得银两/元宝 失去威望，只是将 失去和获得交换位置
        防守    1. 胜利 失去元宝/银两 获得威望
                2. 失败 失去所有的  也就是说，在防守的情况下，直接将 获得 隐藏    
    ]]

    -- 玩家头像背景图

    local avatorbgPath = "res/image/plugin/competitive_layer/hero_board1.png"
    if tonumber(_thePlayerData["campId"]) == 1 then  -- campid 1 光明谷，2 暗月岭
        avatorbgPath = "res/image/plugin/competitive_layer/hero_board1.png"
    else
        avatorbgPath = "res/image/plugin/competitive_layer/hero_board2.png"
    end
    local _spPlayerAvatorBg = cc.Sprite:create(avatorbgPath)
    _spPlayerAvatorBg:setScale(0.6)
    _spPlayerAvatorBg:setPosition( cc.p(_spPlayerAvatorBg:getContentSize().width*0.7 + 3, bgHeight*0.42) )
    -- _spPlayerAvatorBg:setScale(0.8)
    _bg:addChild( _spPlayerAvatorBg )

    -- 玩家头像
    local _spPlayerAvator = cc.Sprite:create("res/image/avatar/avatar_1.png")
    _spPlayerAvator:setPosition( cc.p(_spPlayerAvatorBg:getContentSize().width*0.5, _spPlayerAvatorBg:getContentSize().height*0.5+2) );
    _spPlayerAvatorBg:addChild( _spPlayerAvator )

    

    -- 玩家所属种族
    local camp_id = "res/image/common/camp_Icon_1.png"
    if tonumber(_thePlayerData["campId"]) == 1 then  -- campid 1 光明谷，2 暗月岭
        camp_id = "res/image/common/camp_Icon_1.png"
    else
        camp_id = "res/image/common/camp_Icon_2.png"
    end
    local _spPlayerCamp = cc.Sprite:create(camp_id)
    _spPlayerCamp:setScale(0.6);
    _spPlayerCamp:setPosition( cc.p(16, 15) )
    _spPlayerAvatorBg:addChild( _spPlayerCamp )


    -- 玩家名称
    local _labPlayerName = XTHDLabel:createWithParams( {
            ["text"] = _thePlayerData["name"] ,
            ["size"] = 26,
            ["color"] = cc.c3b(78, 48, 13),
        } )
    _labPlayerName:setAnchorPoint( cc.p(0, 0.5) )
	_labPlayerName:setScale(1.5)
    _labPlayerName:setPosition( cc.p(_spPlayerAvatorBg:getContentSize().width + 10, _spPlayerAvatorBg:getContentSize().height - _labPlayerName:getContentSize().height))
    _spPlayerAvatorBg:addChild( _labPlayerName )
	_labPlayerName:enableBold()

    -- 玩家等级
    local _labPlayerLevel = XTHDLabel:createWithParams( {
            ["text"] = _thePlayerData["level"] .. "级" ,
            ["size"] = 26,
            ["color"] = cc.c3b(78, 48, 13)
        } )
	_labPlayerLevel:setAnchorPoint(0,0.5)
	_labPlayerLevel:setScale(1.5)
    _labPlayerLevel:setPosition( cc.p( _spPlayerAvatorBg:getContentSize().width + 10, _labPlayerLevel:getContentSize().height) );
    _spPlayerAvatorBg:addChild( _labPlayerLevel );
	_labPlayerLevel:enableBold()

    --战斗力背景
    local zl_bg = cc.Sprite:create("res/image/common/zl_bg.png")
    zl_bg:setAnchorPoint(0,0.5)
    zl_bg:setPosition(_labPlayerName:getPositionX() + _labPlayerName:getContentSize().width + 10,55)
    _bg:addChild(zl_bg)
    --战斗力
    local _power_icon = cc.Sprite:create("res/image/common/fightValue_Image.png")
    _power_icon:setPosition(_labPlayerName:getPositionX() + _labPlayerName:getContentSize().width + 45,55)
    _bg:addChild(_power_icon)

    --战斗力数字
    local _power_num = getCommonYellowBMFontLabel(_thePlayerData["firstTeamComper"] or "")
    _power_num:setAnchorPoint(0,0.5)
    _power_num:setScale(1.3)
    _power_num:setPosition(_power_icon:getPositionX()+_power_icon:getContentSize().width/2+10,_power_icon:getPositionY()-6)
    _bg:addChild(_power_num)

	 -- 左边/失去提示
    local _labLose = XTHDLabel:createWithParams( {
            ["text"] = LANGUAGE_VERBS.lost..":",-----失去:" ,
            ["size"] = 24,
            ["color"] = cc.c3b(78, 48, 13)
        } );
	_labLose:setAnchorPoint(0,0.5)
    _labLose:setPosition( cc.p(zl_bg:getContentSize().width + zl_bg:getPositionX() + _labLose:getContentSize().width + 10, bgHeight*0.5 - _labLose:getContentSize().height *0.5) )
    _bg:addChild( _labLose )
	_labLose:enableBold()

    -- 铜币
    local _spCopper = cc.Sprite:create("res/image/common/header_gold.png")
    _spCopper:setPosition( cc.p(_labLose:getPositionX() + _labLose:getContentSize().width +  _spCopper:getContentSize().width *0.5 +10, bgHeight*0.61-8) )
    _bg:addChild( _spCopper )

    -- 铜币提示
    local _labCopper = XTHDLabel:createWithParams( {
            ["text"] = _thePlayerData["addFeicui"] ,
            ["size"] = 22,
            ["color"] = cc.c3b(78, 48, 13)
        } )
    _labCopper:setAnchorPoint( cc.p(0, 0.5) )
    _labCopper:setPosition( cc.p(_spCopper:getPositionX() + _spCopper:getContentSize().width*0.5 + 5, _spCopper:getPositionY()) )
    _bg:addChild( _labCopper )
	_labCopper:enableBold()

    -- 翡翠
    local _spGold = cc.Sprite:create("res/image/common/header_feicui.png")
    _spGold:setScale(1)
    _spGold:setPosition( cc.p(_labLose:getPositionX() + _labLose:getContentSize().width +  _spGold:getContentSize().width *0.5 +18, bgHeight*0.41-18 ) )
    _bg:addChild( _spGold )

    -- 翡翠提示
    local _labGold = XTHDLabel:createWithParams( {
            ["text"] = _thePlayerData["addGold"] ,
            ["size"] = 22,
            ["color"] = cc.c3b(78, 48, 13)
        } )
    _labGold:setAnchorPoint( cc.p(0, 0.5) )
    _labGold:setPosition( cc.p(_spGold:getPositionX() + _spGold:getContentSize().width*0.5 + 7.5, _spGold:getPositionY()) )
    _bg:addChild( _labGold )
	_labGold:enableBold()

    -- 提示- 获得
    local _labGet = XTHDLabel:createWithParams( {
            ["text"] = LANGUAGE_VERBS.get..":",-----获得:" ,
            ["size"] = 24,
            ["color"] = cc.c3b(78, 48, 13)
        } )
	_labGet:setAnchorPoint(0,0.5)
    _labGet:setPosition( cc.p(_labLose:getPositionX(), bgHeight*0.5 - 12) )
    _bg:addChild( _labGet )
	_labGet:enableBold()
        if kReportType == 1 then 
            _labGet:setVisible(false)
        elseif kReportType == 2 then 
            _labLose:setVisible( false )
        end


    -- 战报是否过期
    local _bReportOutOfDate = false
    if not _bReportOutOfDate then
        -- 战报分享
        local _btnShare = XTHDPushButton:createWithParams({
             normalNode = cc.Sprite:create("res/image/plugin/competitive_layer/battlereport/btn_share_up.png"),
             selectedNode = cc.Sprite:create("res/image/plugin/competitive_layer/battlereport/btn_share_down.png"),
             needSwallow = true,
             enable = true,
        })
        _btnShare:setPosition( cc.p(bgWidth*0.865-48, bgHeight*0.5 + 12) )
        _bg:addChild(_btnShare)
        _btnShare:setTouchEndedCallback( function ()
            -- do XTHDTOAST(LANGUAGE_TIPS_WORDS11) return end
            ClientHttp:requestAsyncInGameWithParams({
                modules = "shareReport?",
                params = {reportId=_thePlayerData["reportId"]},
                successCallback = function(net_data)
                    if tonumber(net_data.result) == 0 then
                        XTHDTOAST(LANGUAGE_TIPS_WORDS129)-----"战报分享成功")
                    else
                        XTHDTOAST(net_data.msg)
                    end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)----"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
        end)
        _btnShare:setScale(0.7)

        -- 战报回放
        local _btnReplay = XTHDPushButton:createWithParams({
             normalNode = cc.Sprite:create("res/image/plugin/competitive_layer/battlereport/btn_replay_up.png"),
             selectedNode = cc.Sprite:create("res/image/plugin/competitive_layer/battlereport/btn_replay_down.png"),
             needSwallow = true,
             enable = true,
        })
        _btnReplay:setPosition( cc.p(bgWidth*0.935+12-52, bgHeight*0.5 + 12) );
        _bg:addChild(_btnReplay)
        _btnReplay:setTouchEndedCallback( function ()
            ClientHttp:httpReplayBatlle(self, _thePlayerData["reportId"])
        end)
        _btnReplay:setScale(0.7)
    end

    -- 复仇
    if kReportType == 1 then
        local _btnRevenge = nil
        if _thePlayerData["canRevenge"] == 1 then  -- 可以复仇
            _btnRevenge = XTHD.createCommonButton({
                btnColor = "write",
                isScrollView = true,
                btnSize = cc.size(111,46),
                text = LANGUAGE_BTN_KEY.fuchou,
                needSwallow = true,
                enable = true,
            })
            _btnRevenge:setScale(0.6)
            _btnRevenge:setTouchEndedCallback( function ()
                ClientHttp:requestAsyncInGameWithParams({
                    modules = "revenge?",
                    params = {reportId=_thePlayerData["reportId"]},
                    successCallback = function(net_data)
                        if tonumber(net_data.result) == 0 then
                            LayerManager.addShieldLayout()
                            local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")
                            local _layerHandler = SelHeroLayer:create(BattleType.PVP_CHALLENGE, nil, net_data)
                            fnMyPushScene(_layerHandler)

                            --把数据改为0，表示已经复仇
                            _thePlayerData["canRevenge"] = 0
                            _btnRevenge:setVisible(false)
                            local tmp_label = XTHDLabel:createWithParams( {
                                ["text"] = LANGUAGE_TIPS_WORDS130,-----"不能复仇" ,
                                ["size"] = 20,
                                ["color"] = cc.c3b(53,25,26)
                            } )
                            tmp_label:setPosition( cc.p(bgWidth*0.9+5-30, bgHeight*0.28-7))
                            _bg:addChild(tmp_label)
                        else
                            XTHDTOAST(net_data["msg"])
                        end
                    end,--成功回调
                    failedCallback = function()
                        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)----"网络请求失败")
                    end,--失败回调
                    targetNeedsToRetain = self,--需要保存引用的目标
                    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                })
            end)
        else
            _btnRevenge = XTHDLabel:createWithParams( {
                ["text"] = LANGUAGE_TIPS_WORDS130,------"不能复仇" ,
                ["size"] = 26,
                ["color"] = cc.c3b(53,25,26)
            } )
        end
        _btnRevenge:setPosition( cc.p(bgWidth*0.9+5-50, bgHeight*0.28) )
        _bg:addChild(_btnRevenge)
    end
    return _cell
end

function JingJiBattleReport:create(net_data)
	return self.new(net_data)
end

function JingJiBattleReport:onCleanup(  )
end


return JingJiBattleReport
