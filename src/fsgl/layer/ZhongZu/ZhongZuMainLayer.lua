--[[
种族主界面 
]]
local ZhongZuMainLayer = class("ZhongZuMainLayer",function( )
	return XTHDDialog:create()	
end)

function ZhongZuMainLayer:ctor(funcID)
    self.__gotoBattleCounter = 0
    self.__funcID = funcID
	self.__TDGlobalPowerBar = nil --天道盟总的势力点条
	self.__TDGlobalPowerBarPercent = nil
	self.__WJGlobalPowerBar = nil --无极营总的势力点条	
	self.__WJGlobalPowerBarPercent = nil
	self.__rewardList = nil ---底部的凭势力点可获得的奖励
    self.__campMainPanle = nil -- 种族的基础面板 
    self.__campFunctions = {} --种族里的功能面板，1 种族任务，2 种族奖励，3 种族商店，4 种族祭拜
    self.__campFunctionBtn = {} --种族里的功能按键 
    self._funcLayers = {}
    self.__campBattleTime = nil --种族战场面板上的种族开战时间 
    self.__currentFunctionIndex = 1 --当前所在功能的索引
    self.__isNeedRefresh = false
    self.__worshipTimesLabel = nil ---神兽膜拜次数    
    self._extraBg = nil ------种族在开战前、开战时、开战后的提示背景
    self._beginTimeBg = nil -----种族战开启时间的背景
    self._pushSceneCount = 0
    self._isBuyItem = false
    self._redDotState = {}    --奖励领取任务小红点状态

    self.Tag = {
        ktag_campBeginTip = 100, 
    }

    self.__campTask = {---种族任务
        shiliPointLabel = nil, ---玩家为种族获得的势力点数的label
        shiliLabel = nil,--势力值后面的“势力值”label
        shiliPointBar = nil, ---势力点的进度条（带箱子的）    
        taskList = nil, --种族任务的列表    
        boxes = {},----箱子们
    }

    self.__campStore = {
        shiliPointLabel = nil ,
        shiliLabel = nil,
        honorLabel = nil,
        storeList = nil, -- 种族商店的列表
    }

    self.color = {
        tuHuang = cc.c3b(234,221,103),
        green = cc.c3b(52,255,106),
        darkBrown = cc.c3b(54,55,112),
        purple = cc.c3b(222,15,217),
        lightYellow = cc.c3b(207,100,17),
    }   
   
    musicManager.setBackMusic(XTHD.resource.music.music_bgm_camp)
end

function ZhongZuMainLayer:create(funcID,parent,zorder)
    ZhongZuDatas.requestServerData({
        method = "campBase?",
        success = function( )
            local camp = ZhongZuMainLayer.new(funcID)
            camp:init()
            LayerManager.addLayout(camp, {par = parent, zz = zorder})    
        end,
    })    
end

function ZhongZuMainLayer:onEnter( )  
    if self.__isNeedRefresh then 
        self.__isNeedRefresh = false
        self:refreshDatas()
    end 
    ---注册刷新数据函数
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_CAMP_MAINLAYER , callback = function(event) 
        self:refreshDatas()
    end})
    musicManager.switchBackMusic()
    --------引导 
    YinDaoMarg:getInstance():addGuide({parent = self,index = 3},10)----剧情
    YinDaoMarg:getInstance():doNextGuide()
end

function ZhongZuMainLayer:onExit( )
    self._pushSceneCount = 0
    if self._isBuyItem ~=nil and self._isBuyItem ==true then
        RedPointManage:reFreshDynamicItemData()
    end
end

function ZhongZuMainLayer:onCleanup( )
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_CAMP_MAINLAYER)
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
    LayerManager.removeChatRoom(LiaoTianRoomLayer.Functions.Camp)
    self:collectMemory()
end

function ZhongZuMainLayer:init()
    ZhongZuDatas.getLocalCampDatas()
    local selfSize = self:getContentSize()
    ---背景
    local bg = cc.Sprite:create("res/image/camp/camp_bg7.jpg")
    self:addChild(bg)
	local _size = bg:getContentSize()
	local size = cc.Director:getInstance():getWinSize()
	local scaleX = size.width / _size.width
	local scaleY = size.height / _size.height

	bg:setContentSize(size)
    bg:setPosition(selfSize.width / 2,selfSize.height / 2)

    ---帮助按钮
    local help = XTHDPushButton:createWithParams({
        normalFile = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
    })
    self:addChild(help)
    help:setPosition(help:getContentSize().width / 2 + 10,selfSize.height - help:getContentSize().height / 2 - 5)
    help:setTouchEndedCallback(function( )
        local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=1}); --byhuangjunjian玩法说明                              
        self:addChild(StoredValue)
    end)
    --进度条
    local barBack = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading_bg_new2.png")
    self:addChild(barBack)
    barBack:setPosition(self:getContentSize().width / 2,self:getContentSize().height - 50)
    self.__progressBarbg = barBack
    ----左边种族图标    
    local _icon = cc.Sprite:create("res/image/camp/camp_circle_icon1.png")
    self:addChild(_icon)
    _icon:setAnchorPoint(1,0.5)
    _icon:setPosition(barBack:getPositionX() - barBack:getContentSize().width / 2 + 7,barBack:getPositionY()-10)
    ----势力点文字
    local label = XTHDLabel:createWithParams({
        text = LANGUAGE_CAMP_SELF_POINT_PERCENT(0),
        fontSize = 16,  
        ttf = "res/fonts/def.ttf",              
    })
    self:addChild(label)
    label:setAnchorPoint(0,0.5)
    label:enableOutline(cc.c4b(0,0,0,255),1)
    -- label:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,-1))
    label:setPosition(_icon:getPositionX() + 10,barBack:getPositionY() + barBack:getContentSize().height / 2 + label:getContentSize().height / 2)
    self.__TDGlobalPowerBarPercent = label
    ----右边种族图标
    _icon = cc.Sprite:create("res/image/camp/camp_circle_icon2.png")
    self:addChild(_icon)
    _icon:setAnchorPoint(0,0.5)
    _icon:setPosition(barBack:getPositionX() + barBack:getContentSize().width / 2 - 7,barBack:getPositionY()-10)
    ----势力点文字     
    local label = XTHDLabel:createWithParams({
        text = LANGUAGE_CAMP_ENEMY_POINT_PERCENT(0),
        fontSize = 16, 
        color = cc.c3b(255,255,255),
        ttf = "res/fonts/def.ttf",              
    })
    self:addChild(label)
    label:setAnchorPoint(1,0.5)
    label:enableOutline(cc.c4b(0,0,0,255),1)
    -- label:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,-1))
    label:setPosition(_icon:getPositionX() - 10,barBack:getPositionY() + barBack:getContentSize().height / 2 + label:getContentSize().height / 2)
    self.__WJGlobalPowerBarPercent = label
    ----蓝进度条
    local blueBar = ccui.LoadingBar:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading_new2.png",50)
    barBack:addChild(blueBar)
    blueBar:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
    self.__TDGlobalPowerBar = blueBar
    ----红进度条
    local redBar = ccui.LoadingBar:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading_new1.png",50)
    barBack:addChild(redBar)
    redBar:setDirection(1) --设置从右到左
    redBar:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
    self.__WJGlobalPowerBar = redBar
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
    _icon:setScale(0.8)
    _icon:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
    self.__campVSIcon = _icon
    -- self.__campVSIcon:setAnchorPoint(0.5,0.5)
    -------水车动画
    -- local _waterwheel = sp.SkeletonAnimation:create("res/image/camp/frames/chelun.json","res/image/camp/frames/chelun.atlas",1.0)
    -- self:addChild(_waterwheel)
    -- _waterwheel:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    -- _waterwheel:setAnimation(0,"animation",true)

     --修正显示图标位置参数
    local extralY=0
    if screenRadio<=1.5 then
        extralY=-60*(1.667-screenRadio)
    end
    ---功能建筑
    local pos = {cc.p(332*scaleX,330*scaleY+extralY),cc.p(115*scaleX,240*scaleY+extralY),cc.p(845*scaleX,275*scaleY+extralY),cc.p(730*scaleX,440*scaleY+extralY),cc.p(500*scaleX,290*scaleY+extralY)} -----，夺城战,生命之树、商店,王城战,城主膜拜
    local _name = {"camp_nameFunc4","camp_nameFunc2","camp_nameFunc3","camp_nameFunc1","camp_nameFunc5"}
    for i = 1,5 do 
        local normal = cc.Sprite:create("res/image/camp/camp_build_btn"..i..".png")
        local selected = cc.Sprite:create("res/image/camp/camp_build_btn"..i..".png")
        selected:setScale(0.95)
        local btn = XTHDPushButton:createWithParams({
            normalNode = normal,
            selectedNode = selected,
            musicFile = XTHD.resource.music.effect_btn_common,
        })
        btn:setTag(i)
        btn:setTouchEndedCallback(function( )
            local _index = btn:getTag()
            if _index == 1 then -----种族战入口 
                self:changeFunction(4)
            elseif _index == 3 then  --种族商店
                self:changeFunction(3)
            elseif _index == 2 then 
                self:changeFunction(6)
            elseif _index == 5 then  --城主膜拜
                self:changeFunction(5)
            else 
                XTHDTOAST(LANGUAGE_KEY_NOTOPEN)
            end 
        end)
        bg:addChild(btn)
        btn:setPosition(pos[i])
        -----功能名字框
        local _name = cc.Sprite:create("res/image/camp/".._name[i]..".png")
        btn:addChild(_name)
        _name:setAnchorPoint(0,0)
        if i == 1 then             
            _name:setPosition(btn:getBoundingBox().width - 65,btn:getBoundingBox().height * 2/3-60) ------夺城战
        elseif i == 2 then
            _name:setPosition(btn:getBoundingBox().width - 25,btn:getBoundingBox().height * 2/3-100) ------生命之树         
        elseif i == 3 then
            _name:setPosition(btn:getBoundingBox().width - 35,btn:getBoundingBox().height * 2/3-80) ------种族商店
        elseif i == 4 then
            _name:setPosition(btn:getBoundingBox().width - 30,btn:getBoundingBox().height * 2/3-90) ------王城战
        else 
            _name:setPosition(btn:getBoundingBox().width - 25,btn:getBoundingBox().height * 2/3-100) ------城主膜拜 
        end 
    end 
    -------前景动画 
    -- local _foreSpine = sp.SkeletonAnimation:create("res/image/camp/frames/qianjin.json","res/image/camp/frames/qianjin.atlas",1.0)
    -- self:addChild(_foreSpine)
    -- _foreSpine:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    -- _foreSpine:setTimeScale(0.02)
    -- _foreSpine:setAnimation(0,"animation",true)
    ---返回按钮
    local close = XTHD.createNewBackBtn(function( )
        musicManager.setBackMusic(XTHD.resource.music.music_bgm_main)
        musicManager.switchBackMusic()
        LayerManager.removeChatRoom(LiaoTianRoomLayer.Functions.Camp)
        LayerManager.removeLayout(self)
    end)    
    self:addChild(close)
    close:setPosition(selfSize.width, selfSize.height)
    
    ------聊天按钮
    -- local _chatBtn = XTHDPushButton:createWithParams({
    --     normalFile = "res/image/homecity/menu_chat1.png",
    --     selectedFile = "res/image/homecity/menu_chat2.png"
    -- })
    -- local scene = cc.Director:getInstance():getRunningScene()
    -- scene:addChild(_chatBtn,10)
    -- _chatBtn:setAnchorPoint(0,0.5)
    -- _chatBtn:setPosition(0,winSize.height / 2 + 30)
    -- _chatBtn:setTouchSize(cc.size(_chatBtn:getContentSize().width + 5,_chatBtn:getContentSize().height + 16))
    -- _chatBtn:setTouchEndedCallback(function ()
    --     XTHD.showChatroom(_lay, self._chatBtn)
    -- end)
    if not self.__funcID then
        performWithDelay(self, function()
            local _chatBtn = LayerManager.addChatRoom({sType = LiaoTianRoomLayer.Functions.Camp})
        end, 0.1)
    end
    self:updateInforPowerBar()
    self:changeFunction(self.__funcID)
    
    ------功能按钮*(任务、奖励)
    local x = self:getContentSize().width - 15
    for i = 1,2 do 
        local btn = XTHDPushButton:createWithParams({
            normalFile = "res/image/camp/camp_btn"..i.."_1.png",
            selectedFile = "res/image/camp/camp_btn"..i.."_2.png",
            musicFile = XTHD.resource.music.effect_btn_common,
        })
        btn:setAnchorPoint(1,0)
        btn:setTag(i)
        btn:setTouchEndedCallback(function( )
            self:changeFunction(btn:getTag())
        end)
        btn:setScale(0.8)
        self:addChild(btn)
        btn:setPosition(x,1)
        local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
        btn:addChild(redDot)
        redDot:setPosition(btn:getBoundingBox().width, btn:getBoundingBox().height - 10)
        redDot:setVisible(true)
        self._redDotState[i] = redDot
        x = x - btn:getBoundingBox().width - 5
    end 

    --刷新小红点
    self:freshRedDot()
end 

--刷新小红点
function ZhongZuMainLayer:freshRedDot()
    local isHave1 = false
    local isHave2 = false
    local localData = ZhongZuDatas._localTaskBarData[index]
    local currentPower = tonumber(ZhongZuDatas._serverBasic.dayAddForce)
    for i = 1,#ZhongZuDatas._serverBasic.dayReward do
        if currentPower >= ZhongZuDatas._localTaskBarData[ZhongZuDatas._serverBasic.dayReward[i].configId].needPowerPoint and ZhongZuDatas._serverBasic.dayReward[i].state == 0 then
            isHave1 = true
            break
        end
    end

    local selfFoce = 0
    if gameUser.getCampID() == 1 then 
        selfFoce = ZhongZuDatas._serverBasic.aForce
    else 
        selfFoce = ZhongZuDatas._serverBasic.bForce
    end 
    for j = 1,#ZhongZuDatas._serverBasic.weekReward do
        local localData = ZhongZuDatas._localReward[tonumber(ZhongZuDatas._serverBasic.weekReward[j].configId)]
        if ZhongZuDatas._serverBasic.weekReward[j].state == 0 and selfFoce > localData.parameter then
            isHave2 = true
            break
        end
    end

    self._redDotState[1]:setVisible(isHave1)
    self._redDotState[2]:setVisible(isHave2)
end

--初始化靠势力点来获得奖励的奖励列表
function ZhongZuMainLayer:initPowerRewardList(targ,viewSize)
	local cellSize = cc.size(viewSize.width,100)
	
	local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
        return #ZhongZuDatas._serverBasic.weekReward
    end

    local function tableCellTouched(table,cell)
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(cellSize)
        else 
        	cell:removeAllChildren()
        end
        local node = self:createRewardCell(idx + 1,cellSize)
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        cell.node = node
        return cell
    end

    local tableView = cc.TableView:create(cc.size(viewSize.width,viewSize.height))
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(23,33)
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
    self.__rewardList = tableView
end
---初始化神兽祭拜
function ZhongZuMainLayer:initTaskList(targ,viewSize)
    local cellSize = cc.size(viewSize.width,82)
   
    local function tableCellTouched(table,cell)
        
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else 
            cell:removeAllChildren()
        end
        local node = self:createCampTaskCell(cell,idx + 1,cellSize) 
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        return cell
    end

    local tableView = cc.TableView:create(viewSize)
    TableViewPlug.init(tableView)
    tableView:setPosition(18,35)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    

    tableView.getCellNumbers = function( ... )
        return #ZhongZuDatas._localTask
    end

    tableView.getCellSize = function(table,idx)
        return cellSize.width, cellSize.height+10
    end

    tableView:registerScriptHandler(tableView.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(tableView.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    targ:addChild(tableView)
    self.__campTask.taskList = tableView
end
--创建种族任务的列表单元
function ZhongZuMainLayer:createCampTaskCell(cell,index,cellSize)
    cell:setContentSize(cellSize)
    local node = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
    node:setContentSize(cc.size(cellSize.width,cellSize.height+5))
    --每个任务的标题    
    local title = XTHDLabel:createWithParams({
        text = ZhongZuDatas._localTask[index].describe1,
        fontSize = 22,
        color = self.color.darkBrown
    })
    node:addChild(title)
    title:setAnchorPoint(0,0.5)
    title:setPosition(10,node:getContentSize().height / 2)
    ----每完成一个+1
    local label = XTHDLabel:createWithParams({
        text = ZhongZuDatas._localTask[index].describe2,
        fontSize = 22,
        color = cc.c3b(170,34,3),
        ttf = "res/fonts/def.ttf"
    })
    node:addChild(label)
    label:setAnchorPoint(0,0.5)
    label:setPosition(title:getPositionX() + title:getContentSize().width,node:getContentSize().height / 2)
    ---前庭获取按钮
    local button = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(130,49),
        isScrollView = true,
        musicFile = XTHD.resource.music.effect_btn_common,
        text = LANGUAGE_BTN_KEY.goForGetting
    })
    button:setScale(0.8)
    button:setAnchorPoint(1,0.5)
    node:addChild(button)
    button:setPosition(node:getContentSize().width - 20,node:getContentSize().height / 2)
    button:setTag(tonumber(ZhongZuDatas._localTask[index].gotoFunctionID))
    button:setTouchEndedCallback(function( )
        self:gotoSpecifiedFunction(button:getTag())        
    end)
    ---字
    -- local _word = XTHDLabel:createWithSystemFont(LANGUAGE_BTN_KEY.goForGetting,XTHD.SystemFont,22)
    -- if _word then 
    --     _word:setColor(cc.c3b(59,115,0))
    --     button:addChild(_word) 
    --     _word:setPosition(button:getContentSize().width / 2,button:getContentSize().height / 2)
    -- end 
    return node 
end
----创建用势力点来获得的奖励
function ZhongZuMainLayer:createRewardCell(index,cellSize)
    local node = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
    node:setContentSize(cc.size(cellSize.width,cellSize.height - 5))    
    if ZhongZuDatas._serverBasic.weekReward and ZhongZuDatas._localReward then 
        local serverData = ZhongZuDatas._serverBasic.weekReward[index]
        local localData = ZhongZuDatas._localReward[tonumber(serverData.configId)]
        local selfFoce = 0
        if gameUser.getCampID() == 1 then 
            selfFoce = ZhongZuDatas._serverBasic.aForce
        else 
            selfFoce = ZhongZuDatas._serverBasic.bForce
        end 
        ---领取按钮
       local _btnColor = "write_1"
        local str = "res/image/camp/camp_reward_get.png"
        local hasButton = true
        local _btnText = LANGUAGE_BTN_KEY.getReward
		local isVisible = true
        if tonumber(serverData.state) == 1 then ---已领取
            str = "res/image/camp/camp_reward_getted.png"
            hasButton = false
            _btnColor = nil
            _btnText = LANGUAGE_BTN_KEY.getReward
			isVisible = false
        elseif selfFoce < localData.parameter then ----未完成             
            _btnColor = "write"
            _btnText = LANGUAGE_BTN_KEY.noAchieve
			isVisible = false
        end 
        ---按钮上的文字 
        local word = cc.Sprite:create(str)
		word:setScale(0.7)
        if hasButton then 
            local getBtn = XTHD.createCommonButton({
                text = _btnText,
                btnColor = _btnColor,
                btnSize = cc.size(102,46),
                isScrollView = true,
                fontSize = 22
            })
            getBtn:setScale(0.8)
            node:addChild(getBtn)
            getBtn:setPosition(node:getContentSize().width - 77,node:getContentSize().height / 2)
            getBtn:setTag(index)
            getBtn:setTouchEndedCallback(function( )            
                self:getWeeklyReward(getBtn:getTag(),getBtn)            
            end)
	
			local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
			getBtn:addChild( fetchSpine )
			fetchSpine:setPosition( getBtn:getBoundingBox().width*0.5+22, getBtn:getContentSize().height/2+20-17 )
			fetchSpine:setAnimation( 0, "querenjinjie", true )
			fetchSpine:setVisible(isVisible)
        else
            node:addChild(word)
            word:setPosition(node:getContentSize().width - 77,node:getContentSize().height / 2)
        end 
        word:setTag(1)
        -----文字打醒 
        local tips = XTHDLabel:createWithParams({
            text = LANGUAGE_CAMP_TIPSWORDS25,
            fontSize = 22,
            color = XTHD.resource.color.brown_desc,
            ttf = "res/fonts/def.ttf"
        })
        node:addChild(tips)
        tips:setAnchorPoint(0,0.5)
        tips:setPosition(20,node:getContentSize().height / 2)
        ----条件
        local _amount = XTHDLabel:createWithParams({
            text = localData.parameter,
            fontSize = 22,
            color = cc.c3b(178,27,27),
            ttf = "res/fonts/def.ttf"
        })
        node:addChild(_amount)
        _amount:setAnchorPoint(0,0.5)
        _amount:setPosition(tips:getPositionX() + tips:getContentSize().width + 10,tips:getPositionY())
        ---图标
        local icon = ItemNode:createWithParams({
            _type_ = localData.rewardItemType,
            count = localData.rewardAmoun,          
        })
        node:addChild(icon)
        icon:setScale(0.75)
        icon:setPosition(node:getContentSize().width / 2,node:getContentSize().height / 2)
        node.iconNode = icon
    end 
    return node 
end
----创建用于兑换奖励的时候显示的花费消耗提示
function ZhongZuMainLayer:getCostLabelWhenExchange(configId)
    local node = cc.Node:create()
    local data = ZhongZuDatas._localStore[tonumber(configId)]
    if not data then 
        return node
    end 
    local fontSize = 18
    local word = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_ONLYISCOST,
        fontSize = fontSize,
        color = self.color.darkBrown
    })
    node:addChild(word)
    word:setPosition(word:getContentSize().width / 2,word:getContentSize().height / 2)
    node:setContentSize(word:getContentSize())
    --花费图标1
    local diamond = XTHD.createHeaderIcon(data.exchangeNeedType1)
    node:addChild(diamond)
    diamond:setAnchorPoint(0,0.5)
    diamond:setPosition(word:getPositionX() + word:getContentSize().width / 2,word:getPositionY())
    node:setContentSize(cc.size(node:getContentSize().width + diamond:getContentSize().width,node:getContentSize().height))
    ---花费数量1
    local num = XTHDLabel:createWithParams({
        text = data.amount1,
        fontSize = fontSize,
        color = self.color.darkBrown
    })
    node:addChild(num)
    num:setAnchorPoint(0,0.5)
    num:setPosition(diamond:getPositionX() + diamond:getContentSize().width ,word:getPositionY())
    node:setContentSize(cc.size(node:getContentSize().width + num:getContentSize().width,node:getContentSize().height))
    local _and = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_AND,
        fontSize = fontSize,
        color = self.color.darkBrown
    })
    node:addChild(_and)
    _and:setAnchorPoint(0,0.5)
    _and:setPosition(num:getPositionX() + num:getContentSize().width ,word:getPositionY())
    node:setContentSize(cc.size(node:getContentSize().width + _and:getContentSize().width,node:getContentSize().height))    
    --花费图标2    
    diamond = XTHD.createHeaderIcon(data.exchangeNeedType2)
    node:addChild(diamond)
    diamond:setAnchorPoint(0,0.5)
    diamond:setPosition(_and:getPositionX() + _and:getContentSize().width,word:getPositionY())
    node:setContentSize(cc.size(node:getContentSize().width + diamond:getContentSize().width,node:getContentSize().height))    
    --花费数量2
    num = XTHDLabel:createWithParams({
        text = data.amount2,
        fontSize = fontSize,
        color = self.color.darkBrown
    })
    node:addChild(num)
    num:setAnchorPoint(0,0.5)
    num:setPosition(diamond:getPositionX() + diamond:getContentSize().width ,word:getPositionY())
    node:setContentSize(cc.size(node:getContentSize().width + num:getContentSize().width,node:getContentSize().height))    
    --
    word = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_EXCHANGEREWARD,
        fontSize = fontSize,
        color = self.color.darkBrown
    })
    node:addChild(word)
    word:setAnchorPoint(0,0.5)
    word:setPosition(num:getPositionX() + num:getContentSize().width ,num:getPositionY())    
    node:setContentSize(cc.size(node:getContentSize().width + word:getContentSize().width,node:getContentSize().height))    
    node:setAnchorPoint(0.5,0.5)
    return node
end
--任务
function ZhongZuMainLayer:createTask( )
   -- LayerManager.setChatRoomVisable(false)
    -- if self._chatBtn then
    --     self._chatBtn:getParent():setVisible(false)
    -- end
    local layer
    if self.__funcID then 
        layer = XTHDPopLayer:create({
            callback = function( )
                self:resetTaskOrStoreObj(1)
                LayerManager.removeLayout(self)
            end
        })
    else
        layer = XTHDPopLayer:create({
            callback = function( )
                self:resetTaskOrStoreObj(1)
                layer:removeFromParent()
                -- self._chatBtn:getParent():setVisible(true)
                LayerManager.setChatRoomVisable(true)
            end
        })
    end 
    local node = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    node:setContentSize(cc.size(748,465))
    -- node:setCascadeOpacityEnabled( false )
    layer:addChild(node)
    node:setPosition(layer:getContentSize().width / 2,layer:getContentSize().height / 2 - 30)
    
    ---黄色顶背景
    local titleBG = ccui.Scale9Sprite:create("res/image/camp/camp_task_titlebg.png")
    titleBG:setContentSize(720,85)
    node:addChild(titleBG)
    titleBG:setPosition(node:getContentSize().width / 2,node:getContentSize().height - titleBG:getContentSize().height / 2 - 15)   
    --关闭按钮
    local close = XTHD.createBtnClose(function()
        if self.__funcID then 
            self:removeFromParent()
        else 
            layer:hide({music = true})
            layer = nil
        end 
    end)
    node:addChild(close)
    close:setPosition(node:getContentSize().width - 5,node:getContentSize().height - 5) 
    --你已为你的种族获得
    -- local label = cc.Sprite:create("res/image/camp/camp_taskLabel2.png")
    -- local label = XTHDLabel:create("你已为你的种族获得",24,"res/fonts/round_body.ttf")
    local label = XTHDLabel:createWithSystemFont("你已为你的种族获得",XTHD.SystemFont,20)

    label:setColor(cc.c4b(255,255,255,255))
    label:enableOutline(cc.c4b(0,0,0,255),2)
    titleBG:addChild(label)
    label:setAnchorPoint(0,0.5)
    label:setPosition(30,titleBG:getContentSize().height - label:getContentSize().height + 10)

    local data = tonumber(ZhongZuDatas._serverBasic.dayAddForce)
    data = data and data or 0 
    local num = cc.Label:createWithBMFont("res/fonts/nuqizengjia.fnt",data)
    titleBG:addChild(num)
    num:setScale(0.5)
    num:setAnchorPoint(0,0.5)
    num:setPosition(label:getPositionX() + label:getContentSize().width,label:getPositionY())
    self.__campTask.shiliPointLabel = num

    -- label = XTHDLabel:create("势力点",24,"res/fonts/round_body.ttf")
    local label = XTHDLabel:createWithSystemFont("势力点",XTHD.SystemFont,20)
    label:enableOutline(cc.c4b(0,0,0,255),2)
    titleBG:addChild(label)
    label:setAnchorPoint(0,0.5)
    label:setPosition(num:getPositionX() + num:getBoundingBox().width,num:getPositionY())
    self.__campTask.shiliLabel = label
    ---进度条
    local barBack = ccui.Scale9Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading_bg1.png")
    titleBG:addChild(barBack)
    barBack:setPosition(titleBG:getContentSize().width / 2,titleBG:getContentSize().height / 2 - 12)
    local loadingBar = ccui.LoadingBar:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading1.png",0) 
    barBack:addChild(loadingBar)
    loadingBar:setPosition(barBack:getBoundingBox().width / 2,barBack:getBoundingBox().height / 2)

    self.__campTask.shiliPointBar = loadingBar    
    local max = ZhongZuDatas.getTaskMaxForce()
    loadingBar:setPercent(tonumber(ZhongZuDatas._serverBasic.dayAddForce) / max * 100)
    ----箱子
    data = ZhongZuDatas._serverBasic.dayReward
    local space = (titleBG:getContentSize().width - barBack:getContentSize().width) / 2
    for i = 1,#data do
        local need = tonumber(ZhongZuDatas._localTaskBarData[tonumber(data[i].configId)].needPowerPoint)
        local x = need / max * barBack:getContentSize().width + space
        ---分段的数字        
        local phrase = XTHDLabel:createWithParams({
            text = tostring(need),
            fontSize = 22,
            color = cc.c3b(255,255,255),
            ttf = "res/fonts/def.ttf"
        })
        phrase:enableOutline(cc.c4b(54,55,112,255),1)
        titleBG:addChild(phrase)
        phrase:setPosition(x,barBack:getPositionY() - barBack:getBoundingBox().height / 2 - 10)
        ----箱子
        local box =XTHD.createPushButtonWithSound({
            musicFile = XTHD.resource.music.effect_btn_common,
        }) 
        box:setTouchSize(cc.size(64,73))
        box:setContentSize(cc.size(64,73))

		box:setTouchBeganCallback(function()
			if box._xiangzi then
				box._xiangzi:setScale(0.58)
			end
		end)

		box:setTouchMovedCallback(function()
			if box._xiangzi then
				box._xiangzi:setScale(0.6)
			end
		end)

        box:setTouchEndedCallback(function( )
			if box._xiangzi then
				box._xiangzi:setScale(0.6)
			end
            self:getDailyReward(box)
        end)
        box:setAnchorPoint(0.5,0)
        box:setPosition(x,phrase:getPositionY() + phrase:getContentSize().height / 2-10)
        box:setTag(tonumber(data[i].configId))
        titleBG:addChild(box)
        -----
        -- local _spine = sp.SkeletonAnimation:create("res/spine/effect/qiandai/qiandai.json","res/spine/effect/qiandai/qiandai.atlas", 1.0)
        -- box:addChild(_spine)       
        -- _spine:setPosition(box:getBoundingBox().width / 2,box:getBoundingBox().height / 2)
        -- if tonumber(data[i].state) == 0 then ----未领取
        --     _spine:setAnimation(0,"zy"..i.."0",true)
        -- else 
        --     _spine:setAnimation(0,"zy"..i.."2",true)
        -- end 

        --原来是动画现透明化
        -- _spine:setOpacity(255)
        -- box._spine = _spine
        --箱子图片
        local xiangzi = nil
        print("state:"..data[i].state)
        if tonumber(data[i].state) == 0 then --未领取
            xiangzi = cc.Sprite:create("res/image/camp/camp_task_box" .. i .. "_1.png")
        else
            xiangzi = cc.Sprite:create("res/image/camp/camp_task_box" .. i .. "_2.png")
        end
        xiangzi:setScale(0.6)
        xiangzi:setPosition(box:getBoundingBox().width / 2, box:getBoundingBox().height / 2-10)
        box:addChild(xiangzi)

        local index = tonumber(data[i].configId)
        local localData = ZhongZuDatas._localTaskBarData[index]
        local currentPower = tonumber(ZhongZuDatas._serverBasic.dayAddForce)
        if currentPower >= tonumber(localData.needPowerPoint) and tonumber(data[i].state) == 0 then 
            --_spine:setAnimation(0,"zy"..i.."1",true)
            xiangzi:initWithFile("res/image/camp/camp_task_box" .. i .. "_1.png")
        end 

        box._xiangzi = xiangzi
        self.__campTask.boxes[i] = box
    end
    ----中间暗色背景
    
    local viewSize = cc.size(node:getContentSize().width - 40,node:getContentSize().height - titleBG:getBoundingBox().height-53)
    local bg_an = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
    bg_an:setContentSize(cc.size(node:getContentSize().width - 30,node:getContentSize().height - titleBG:getBoundingBox().height-45))
    bg_an:setPosition(node:getContentSize().width/2,30)
    bg_an:setAnchorPoint(0.5,0)
    node:addChild(bg_an)
    self:initTaskList(node,viewSize)
    return layer
end
--奖励
function ZhongZuMainLayer:createReward( )
    local layer = XTHDPopLayer:create()    
    if self.__funcID then 
        layer = XTHDPopLayer:create({
            hideCallback = function( )
                self:removeFromParent()
                -- LayerManager.removeLayout(self)
            end
        })
    end  
    ---背景
    local back = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")  
    back:setContentSize(cc.size(668,454))   
    back:setPosition(layer:getContentSize().width / 2,layer:getContentSize().height / 2 - 10)
    layer:addContent(back)
    ---黄色标头背景
    local titleBG = ccui.Scale9Sprite:create("res/image/camp/camp_task_titlebg.png")
    titleBG:setContentSize(cc.size(640,70))
    back:addChild(titleBG)
    titleBG:setPosition(back:getContentSize().width / 2,back:getContentSize().height - titleBG:getContentSize().height / 2 - 14)
    ---关闭按钮
    local close = XTHD.createBtnClose(function()
        if self.__funcID then 
            self:removeFromParent()
        else 
            layer:hide({music = true})
            layer = nil
        end 
    end)
    back:addChild(close)
    close:setPosition(back:getContentSize().width - 5,back:getContentSize().height - 5)
    ----势力点值
    local value = 0
    if gameUser.getCampID() == 1 then 
        value = ZhongZuDatas._serverBasic.aForce
    else 
        value = ZhongZuDatas._serverBasic.bForce
    end 
    local label = XTHDLabel:createWithParams({
        text = LANGUAGE_CAMP_TIPSWORDS23,
        fontSize = 20,
        color = XTHD.resource.color.brown_desc,
        ttf = "res/fonts/def.ttf"
    })
    titleBG:addChild(label)
    label:setAnchorPoint(0,0.5)
    label:setPosition(30,titleBG:getContentSize().height - 40)
    -----数值
    local _numLabel = XTHDLabel:createWithParams({
        text = value,
        fontSize = 20,
        color = cc.c3b(204,2,2),
        ttf = "res/fonts/def.ttf"
    })
    titleBG:addChild(_numLabel)
    _numLabel:setAnchorPoint(0,0.5)
    _numLabel:setPosition(label:getPositionX() + label:getContentSize().width,label:getPositionY())
    ---=----
    label = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_SHILIPOINT,
        fontSize = 20,
        color = XTHD.resource.color.brown_desc,
        ttf = "res/fonts/def.ttf"
    })
    titleBG:addChild(label)
    label:setAnchorPoint(0,0.5)
    label:setPosition(_numLabel:getPositionX() + _numLabel:getContentSize().width,_numLabel:getPositionY())
    ----重复次数提醒
    local str = string.format("<color=#373670 fontSize=20 >%s</color><color=#b21b1b fontSize=20 >%s</color><color=#373670 fontSize=20 >%s</color>",LANGUAGE_CAMP_TIPSWORDS24,1,LANGUAGE_KEY_TIMES)
    local repeatTips = RichLabel:createARichText(str,false)
    titleBG:addChild(repeatTips)
    repeatTips:setAnchorPoint(1,0.5)
    repeatTips:setPosition(titleBG:getContentSize().width - 50,label:getPositionY() + repeatTips:getContentSize().height / 2)
    local viewSize = cc.size(back:getContentSize().width - 46,back:getContentSize().height - titleBG:getContentSize().height - 50)
    --背景
    local bg_an = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
    bg_an:setContentSize(cc.size(back:getContentSize().width - 30,back:getContentSize().height - titleBG:getBoundingBox().height-45))
    bg_an:setPosition(back:getContentSize().width/2,30)
    bg_an:setAnchorPoint(0.5,0)
    back:addChild(bg_an)
    self:initPowerRewardList(back,viewSize)
    return layer
end
----神兽祭拜
function ZhongZuMainLayer:createBestWorship( )
    -- local layer = XTHD.createPageLayer()
    -- local serverData = ZhongZuDatas._serverWorship
    -- if not serverData then 
    --     return layer
    -- end     
    -- ---背景
    -- local x,y
    -- local bg = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_monster_bg.jpg")
    -- layer:addChild(bg)
    -- bg:setPosition(bg:getContentSize().width / 2 + 8,bg:getContentSize().height / 2 + 9)
    -- -------剩余膜拜次数
    -- local barBG = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_worship_barbg.png")
    -- bg:addChild(barBG)
    -- barBG:setPosition(bg:getContentSize().width / 2,layer:getContentSize().height - barBG:getContentSize().height + 7)
    -- --次数
    -- local times = tonumber(serverData.maxWorship) - tonumber(serverData.worshipSum)
    -- local numLabel = XTHDLabel:createWithParams({
    --     text = string.format(LANGUAGE_CAMP_TIPSWORDS18,times),
    --     fontSize = 16,
    --     color = XTHD.resource.color.gray_desc
    -- })
    -- barBG:addChild(numLabel)
    -- numLabel:setAnchorPoint(0,0.5)
    -- numLabel:setPosition(30,barBG:getContentSize().height / 2)
    -- self.__worshipTimesLabel = numLabel
    -- ---奖励提示
    -- local tips = XTHDLabel:createWithParams({
    --     text = LANGUAGE_CAMP_TIPSWORDS19,
    --     fontSize = 16,
    --     color = cc.c3b(123,46,0)
    -- })
    -- barBG:addChild(tips)
    -- tips:setAnchorPoint(1,0.5)
    -- tips:setPosition(barBG:getContentSize().width - 30,barBG:getContentSize().height / 2)
    -- --神兽们
    -- x = 30   
    -- space = 10
    -- for i = 1,#serverData.list do
    --     local icon = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_monster"..i..".png")        
    --     bg:addChild(icon)
    --     icon:setAnchorPoint(0,0.5)
    --     icon:setPosition(x,bg:getContentSize().height * 2 / 3 - 20)
    --     ---段图标 
    --     local duan = cc.Sprite:create("res/image/common/rank_icon/rankIcon_"..serverData.list[i].duanId..".png")
    --     icon:addChild(duan)
    --     duan:setScale(0.2)
    --     duan:setPosition(duan:getBoundingBox().width / 2 - 20,icon:getBoundingBox().height - 15)
    --     --名字
    --     local name = XTHDLabel:createWithParams({
    --         text = serverData.list[i].name,
    --         fontSize = 20
    --         })
    --     icon:addChild(name)
    --     name:setAnchorPoint(0,0.5)
    --     name:setPosition(19,18)
    --     --消耗
    --     local label = XTHDLabel:createWithParams({
    --         text = LANGUAGE_KEY_ONLY_COST,
    --         fontSize = 20,
    --         color = self.color.tuHuang
    --         })
    --     bg:addChild(label)
    --     label:setAnchorPoint(0,0.5)
    --     label:setPosition(x + 5,icon:getPositionY() - icon:getContentSize().height / 2 - 20)
    --     label:enableShadow(cc.c4b(0,0,0,255),cc.size(2,-2))
    --     --元宝
    --     local gold = XTHD.createHeaderIcon(ZhongZuDatas._localWorship[i].costType)
    --     bg:addChild(gold)
    --     gold:setAnchorPoint(0,0.5)
    --     gold:setPosition(label:getPositionX() + label:getContentSize().width + 5,label:getPositionY())
    --     --膜拜一次花费
    --     local cost = XTHDLabel:createWithParams({
    --         text = tostring(ZhongZuDatas._localWorship[i].costAmount),
    --         fontSize = 20
    --         })
    --     bg:addChild(cost)
    --     cost:setAnchorPoint(0,0.5)
    --     cost:setPosition(gold:getPositionX() + gold:getContentSize().width + 5,label:getPositionY())
    --     cost:enableShadow(cc.c4b(0,0,0,255),cc.size(2,-2))
    --     ---膜拜按钮
    --     local btn = XTHDPushButton:createWithParams({
    --         normalFile = "res/image/common/btn1_normal.png",
    --         selectedFile = "res/image/common/btn1_select.png",
    --         text = LANGUAGE_KEY_WORSHIP,
    --         fontSize = 25
    --         })
    --     bg:addChild(btn)
    --     btn:setAnchorPoint(0,0.5)
    --     btn:setPosition(label:getPositionX(),label:getPositionY() - btn:getContentSize().height)
    --     btn:setTag(tonumber(ZhongZuDatas._localWorship[i].id))
    --     btn:setTouchEndedCallback(function( )
    --         self:doWorship(btn:getTag())
    --     end)
    --     --种族势力+10
    --     local str = string.format(LANGUAGE_CAMP_HONORADDEDTO,ZhongZuDatas._localWorship[i].rewardAmount)
    --     label = XTHDLabel:createWithParams({
    --         text = str,
    --         fontSize = 18,
    --         color = self.color.green
    --         })
    --     bg:addChild(label)
    --     label:setPosition(icon:getPositionX() + icon:getContentSize().width / 2,btn:getPositionY() - btn:getContentSize().height / 2 - 20)
    --     x = x + icon:getContentSize().width + space
    -- end
    -- return layer
end
----刷新任务面板的箱子特效为可领取
function ZhongZuMainLayer:showTaskBoxCanGet( )
    local data = ZhongZuDatas._serverBasic.dayReward
    if self.__campTask then         
        for k,v in pairs(self.__campTask.boxes) do 
            local index = tonumber(data[k].configId)
            local localData = ZhongZuDatas._localTaskBarData[index]
            local currentPower = tonumber(ZhongZuDatas._serverBasic.dayAddForce)
            if currentPower >= tonumber(localData.needPowerPoint) and tonumber(data[k].state) == 0 and v._xiangzi then --领取
                -- v._spine:setAnimation(0,"zy"..k.."1",true)
                v._xiangzi:initWithFile("res/image/camp/camp_task_box" .. k .. "_1.png")
            end 
        end 
    end  
end
--当点击右边的功能按钮时在这里切换功能界面
function ZhongZuMainLayer:changeFunction( index )
    if not index then ----外部跳到种族里指定的功能页面
        return 
    end 
    local layer = nil
    if index == 1 then ---1 种族任务，
        layer = self:createTask()
        self.__rewardList = nil
        self.__campStore.storeList = nil
        self:addChild(layer,2)
    elseif index == 2 then ---2 种族奖励，
        layer = self:createReward()
        layer:show()
        self.__campTask.taskList = nil
        self.__campStore.storeList = nil
        self:addChild(layer)
    elseif index == 3 then -----3 种族商店
        local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("camp")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
    elseif index == 4 then ---4 种族战入口 
        local layer = requires("src/fsgl/layer/ZhongZu/ZhongZuLayer.lua"):create(nil,self)
        LayerManager.addLayout(layer)
    elseif index == 6 then
        self:addLifeTree()
        -- local lifeTree = requires("src/fsgl/layer/ZhongZu/ShengMingZhiShu.lua"):create(nil,self)
        -- LayerManager.addLayout(lifeTree)
    elseif index == 5 then ---5 城主膜拜
        requires("src/fsgl/layer/ZhongZu/forTheHost/ZhongZuKingWorpShip.lua"):create(5)
        -- requires("src/fsgl/layer/ZhongZu/forTheHost/ZhongZuCastellenInfo.lua"):create(5,self,2)  --5是长安城
    end 
end

--生命之树（等进了界面再请求服务器会出息黑屏，所以要先请求服务器再加载界面）
function ZhongZuMainLayer:addLifeTree( )
    ClientHttp:requestAsyncInGameWithParams({
        modules = "openTree?",
        successCallback = function( data )
            local dataList = {}
            dataList._curExp = data.curExp
            dataList._maxExp = data.maxExp
            dataList._treeLevel = data.level 
            dataList._state = data.state
            dataList._List = data.list
            --self._addExperience = 0
            dataList._nextTime = data.nextTime/1000 - os.time()
            if dataList._nextTime <= 0 then
                dataList._nextTime = 0
            end
            dataList._freeCount = data.freeCount
            if data.result == 0 then
                -- dump(dataList,"获取服务器参数")
                local lifeTree = requires("src/fsgl/layer/ZhongZu/ShengMingZhiShu.lua"):create(dataList,self)
                LayerManager.addLayout(lifeTree)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    })
end

---更新种族信息面板的进度条
function ZhongZuMainLayer:updateInforPowerBar( )
    if self.__TDGlobalPowerBar and self.__WJGlobalPowerBar and ZhongZuDatas._serverBasic and self.__TDGlobalPowerBarPercent and self.__WJGlobalPowerBarPercent then 
        local all = tonumber(ZhongZuDatas._serverBasic.aForce) + tonumber(ZhongZuDatas._serverBasic.bForce)
        local percent = tonumber(ZhongZuDatas._serverBasic.aForce) / all * 100
        percent = percent > 0 and percent or 0
        self.__TDGlobalPowerBar:setPercent(percent)
        if self.__progressBarbg and self.__campVSIcon then 
            local x,y = self.__campVSIcon:getPosition()
            local vs_x = self.__progressBarbg:getBoundingBox().width * percent / 100
            self.__campVSIcon:setPosition(vs_x-15,y) 
        end 
        percent = math.ceil(percent)
        -- 不允许出现负数势力值
        self.__TDGlobalPowerBarPercent:setString(LANGUAGE_CAMP_SELF_POINT_PERCENT(percent))

        percent = tonumber(ZhongZuDatas._serverBasic.bForce) / all * 100
        percent = percent > 0 and percent or 0
        self.__WJGlobalPowerBar:setPercent(percent)
        percent = math.floor(percent)
        self.__WJGlobalPowerBarPercent:setString(LANGUAGE_CAMP_ENEMY_POINT_PERCENT(percent))
    end 
end
---领取种族信息面板下面的每周奖励
function ZhongZuMainLayer:getWeeklyReward(index,targ)
    local reward = ZhongZuDatas._serverBasic.weekReward[index]
    local localData = ZhongZuDatas._localReward[reward.configId]
    local selfFoce = 0
    if gameUser.getCampID() == 1 then 
        selfFoce = ZhongZuDatas._serverBasic.aForce
    else 
        selfFoce = ZhongZuDatas._serverBasic.bForce
    end 
    if not reward or not localData then 
        return 
    end 
    if selfFoce < localData.parameter then 
        XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS29)------("当前种族的总势力点不足，无法领取奖励")
        return 
    end 
    if tonumber(reward.state) == 0 then --未领取   
        local needPow = ZhongZuDatas._localReward[tonumber(reward.configId)].parameter
        local campID = gameUser.getCampID()        
        local nowPow = 0
        if campID == 1 then 
            nowPow = tonumber(ZhongZuDatas._serverBasic.aForce)
        else 
            nowPow = tonumber(ZhongZuDatas._serverBasic.bForce)
        end 
        if nowPow >= needPow then 
            ZhongZuDatas.requestServerData({
                method = "forceWeekReward?",
                params = {configId = reward.configId},
                target = self,        
                success = function( data)
                    ---显示获得的奖励东西，
                    ShowRewardNode:create({
                        {rewardtype = localData.rewardItemType,
                        num = localData.rewardAmoun}
                    })
                    ------更新玩家本地属性
                    local server = data.property
                    for k,v in pairs(server) do 
                        local values = string.split(v,',')
                        DBUpdateFunc:UpdateProperty("userdata",values[1],values[2])
                    end 
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                    ------
                    ZhongZuDatas._serverBasic.weekReward[index].state = 1
                    ----把targ设置成已经领取的状态
                    if targ then 
                        local _parent = targ:getParent()
                        ---领取按钮  
                        if _parent then 
                            local _word = cc.Sprite:create("res/image/camp/camp_reward_getted.png")
                            _parent:addChild(_word)
                            _word:setScale(0.7)
                            _word:setAnchorPoint(targ:getAnchorPoint())
                            _word:setPosition(targ:getPosition())
                        end 
                        targ:removeFromParent()
                    end 
                    --刷新小红点
                    self:freshRedDot()
                end
            })
        end 
    else 
        XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS30)------("已经领取过了，奖励会在下周重置")
    end 
    
end
-----获取每日奖励
function ZhongZuMainLayer:getDailyReward(targ)
    local index = targ:getTag()
    local localData = ZhongZuDatas._localTaskBarData[index]
    local currentPower = tonumber(ZhongZuDatas._serverBasic.dayAddForce)
    if currentPower >= tonumber(localData.needPowerPoint) then 
        ZhongZuDatas.requestServerData({            
            method = "forceDayReward?",
            params = {configId = localData.id},
            target = self,        
            success = function(data)
                ------更新玩家本地属性
                local server = data.property
                for k,v in pairs(server) do 
                    local values = string.split(v,',')
                    DBUpdateFunc:UpdateProperty("userdata",values[1],values[2])
                end 
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                ---显示获得的奖励
                ShowRewardNode:create({
                    {rewardtype = localData.rewardType,
                    id = 0,
                    num = localData.rewardAmount}
                })
                ------更新页面UI
                if targ and targ._xiangzi then 
                    -- targ._spine:setAnimation(0,"zy"..index.."2",true)
                    targ._xiangzi:initWithFile("res/image/camp/camp_task_box" .. index .. "_2.png")
                end 
                ---更新奖励领取的状态
                ZhongZuDatas._serverBasic.dayReward[index].state = 1
                ---更新自己的势力点值     
                local data = tonumber(ZhongZuDatas.getSelfPerDayForce())
                data = data and data or 0 
                if self.__campTask.shiliPointLabel then 
                    self.__campTask.shiliPointLabel:setString(data)
                    local x,y = self.__campTask.shiliPointLabel:getPosition()
                    if self.__campTask.shiliLabel then 
                        self.__campTask.shiliLabel:setPosition(x + self.__campTask.shiliPointLabel:getBoundingBox().width,y)
                    end 
                end 
                if self.__campTask.shiliPointBar then 
                    local max = ZhongZuDatas.getTaskMaxForce()
                    self.__campTask.shiliPointBar:setPercent(data / max * 100)
                end    
                self:showTaskBoxCanGet()
                --刷新小红点
                self:freshRedDot()
            end
        })
    else 
        XTHDTOAST(LANGUAGE_TIPS_WORDS9)-------("未达到领取条件")
    end 
    
end
------神兽祭拜
function ZhongZuMainLayer:doWorship(worshipType)
    -- local serverData = ZhongZuDatas._serverWorship
    -- if not serverData then 
    --     return 
    -- end 
    -- if tonumber(serverData.worshipSum) >= tonumber(serverData.maxWorship) then 
    --     XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS31)------("膜拜次数已用完")
    --     return 
    -- end 
    -- ----------构建要显示的提示节点
    -- local node = cc.Node:create()
    -- repeat
    --     local data = ZhongZuDatas._localWorship[worshipType]
    --     if not data then 
    --         break
    --     end 
    --     local fontSize = 18
    --     local word = XTHDLabel:createWithParams({
    --         text = LANGUAGE_KEY_ONLYISCOST,
    --         fontSize = fontSize,
    --         color = self.color.darkBrown
    --     })
    --     node:addChild(word)
    --     word:setPosition(word:getContentSize().width / 2,word:getContentSize().height / 2)
    --     node:setContentSize(word:getContentSize())
    --     --花费图标1
    --     local diamond = XTHD.createHeaderIcon(tonumber(data.costType))
    --     node:addChild(diamond)
    --     diamond:setAnchorPoint(0,0.5)
    --     diamond:setPosition(word:getPositionX() + word:getContentSize().width / 2,word:getPositionY())
    --     node:setContentSize(cc.size(node:getContentSize().width + diamond:getContentSize().width,node:getContentSize().height))
    --     ---花费数量1
    --     local num = XTHDLabel:createWithParams({
    --         text = data.costAmount,
    --         fontSize = fontSize,
    --         color = self.color.darkBrown
    --     })
    --     node:addChild(num)
    --     num:setAnchorPoint(0,0.5)
    --     num:setPosition(diamond:getPositionX() + diamond:getContentSize().width ,word:getPositionY())
    --     node:setContentSize(cc.size(node:getContentSize().width + num:getContentSize().width,node:getContentSize().height))       
    --     --
    --     local str = string.format("%s?",ZhongZuDatas._serverWorship.list[worshipType].name)
    --     word = XTHDLabel:createWithParams({
    --         text = LANGUAGE_KEY_WORSHIP(str),
    --         fontSize = fontSize,
    --         color = self.color.darkBrown
    --     })
    --     node:addChild(word)
    --     word:setAnchorPoint(0,0.5)
    --     word:setPosition(num:getPositionX() + num:getContentSize().width ,num:getPositionY())    
    --     node:setContentSize(cc.size(node:getContentSize().width + word:getContentSize().width,node:getContentSize().height))    
    --     node:setAnchorPoint(0.5,0.5)    
    -- until(true) 
    
    -- local dialog = XTHDConfirmDialog:createWithParams({
    --     contentNode = node,
    --     rightCallback = function( )
    --         ZhongZuDatas.requestServerData({
    --             method = "worship?",
    --             params = {worshipType = worshipType},
    --             target = self,        
    --             success = function(data)
    --                 ---更新属性
    --                 ZhongZuDatas._serverBasic.aForce = tonumber(data.aForce)
    --                 ZhongZuDatas._serverBasic.bForce = tonumber(data.bForce)
    --                 local server = data.property
    --                 if server and next(server) ~= nil then  
    --                     for k,v in pairs(server) do 
    --                         local values = string.split(v,',')
    --                         DBUpdateFunc:UpdateProperty("userdata",values[1],values[2])
    --                         if tonumber(values[1]) == 433 then ---每天增加的势力点数
    --                             ZhongZuDatas._serverBasic.dayAddForce = tonumber(values[2])
    --                         elseif tonumber(values[1]) == 434 then -----累计增加的势力点数
    --                             ZhongZuDatas._serverBasic.totalForce = tonumber(values[2])
    --                         end 
    --                     end 
    --                     XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    --                 end 
    --                 -----刷新膜拜次数
    --                 ZhongZuDatas._serverWorship.worshipSum = tonumber(data.worshipSum)
    --                 ZhongZuDatas._serverWorship.maxWorship = tonumber(data.maxWorship)
    --                 ----更新剩余的膜拜次数
    --                 if self.__worshipTimesLabel then 
    --                     local tims = tonumber(data.maxWorship) - tonumber(data.worshipSum)
    --                     self.__worshipTimesLabel:setString(LANGUAGE_CAMP_TIPSWORDS18(tims))
    --                 end
    --                 ----刷新两种族的势力点进度
    --                 self:updateInforPowerBar()
    --                 XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS32)------"恭喜你膜拜成功")
    --             end
    --         })
    --     end 
    -- })
    -- self:addChild(dialog)
end

function ZhongZuMainLayer:exchangeReward(configId,targ)
    local serverData = ZhongZuDatas._serverExchanges.list[configId]
    if tonumber(serverData.exchangeSum) < 1 then 
        XTHDTOAST(LANGUAGE_TIPS_WORDS10)-------"今日兑换次数已用完")
    else         
        local dialog = XTHDConfirmDialog:createWithParams({
            contentNode = self:getCostLabelWhenExchange(configId),
            rightCallback = function( )
                ZhongZuDatas.requestServerData({
                    method = "campExchange?",
                    params = {configId = configId},
                    target = self,        
                    success = function(data)
                        ------更新玩家本地属性
                        local server = data.property
                        if server and next(server) ~= nil then  
                            for k,v in pairs(server) do 
                                local values = string.split(v,',')
                                DBUpdateFunc:UpdateProperty("userdata",values[1],values[2])
                            end 
                            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                        end 
                        ---更新道具
                        server = data.items 
                        if server and next(server) then 
                            for k,v in pairs(server) do 
                                DBTableItem.updateCount(gameUser.getUserId(), v, v.dbId )
                            end 
                        end 
                        ---显示获得的奖励
                        local localData = ZhongZuDatas._localStore[configId]
                        ShowRewardNode:create({
                            {rewardtype = localData.resourceType,
                            id = localData.resourceID,
                            num = localData.resourceAmount}
                        })
                        ----更新荣誉值
                        if self.__campStore.honorLabel then 
                            self.__campStore.honorLabel:setString(tostring(gameUser.getHonor()))
                        end 
                        ------更新页面的数据
                        ZhongZuDatas._serverExchanges.list[configId].exchangeSum = data.exchangeSum
                        if targ then 
                            local str = LANGUAGE_CAMP_TODAYCANGET(data.exchangeSum)
                            targ:getParent().exchangeLabel:setString(str)
                        end 
                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
                        self._isBuyItem = true
                    end
                })            
            end
        })
        self:addChild(dialog)        
    end 
end

---商店里是否可以兑换奖励
function ZhongZuMainLayer:isAvialabelToExchange(index)
    if ZhongZuDatas._localStore then 
        local data = ZhongZuDatas._localStore[index]
        local selfValue = tonumber(ZhongZuDatas._serverBasic.totalForce)
        if selfValue and data then 
            if selfValue >= tonumber(data.exchangeNeed) then   
                return true
            else
                return false
            end 
        end 
    end 
    return false
end
----前往指定的功能
function ZhongZuMainLayer:gotoSpecifiedFunction( id)
    if id == 1 then  ---普通关卡
        -- if self._pushSceneCount > 0 then 
        --     return 
        -- end 
        -- self._pushSceneCount = self._pushSceneCount + 1
        cc.UserDefault:getInstance():setBoolForKey(KEY_NAME_STAR_EFFECT,false)
        replaceLayer({id = 1})
        self.__isNeedRefresh = true
    elseif id == 2 then ---精英关卡
        -- if self._pushSceneCount > 0 then 
        --     return 
        -- end 
        -- self._pushSceneCount = self._pushSceneCount + 1
        cc.UserDefault:getInstance():setBoolForKey(KEY_NAME_STAR_EFFECT,false)
        replaceLayer({id = 2})
        self.__isNeedRefresh = true
    elseif id == 3 then --竞技场
        XTHD.createCompetitiveLayer(self)
        self.__isNeedRefresh = true
    elseif id == 4 then ---天外天
        XTHDTOAST(LANGUAGE_TIPS_WORDS11)-------"该功能还未开启")
    elseif id == 5 then ---神兽剧本
        XTHD.createSaintBeastChapter(self)
    elseif id == 6 then ---膜拜强者
        self:changeFunction(4)
    elseif id == 7 then ---种族战
        requires("src/fsgl/layer/ZhongZu/ZhongZuMap.lua"):create(self)
    elseif id == 8 then ---任务界面
        XTHD.createTask(self,function( )
            self:refreshDatas()
        end)
    end 
end

function ZhongZuMainLayer:refreshSaintBeast() --神兽刷新用
    XTHD.createSaintBeastChapter(self)
end

function ZhongZuMainLayer:refreshDatas( )
    ZhongZuDatas.requestServerData({
        method = "campBase?",
        target = self,        
        success = function( )
            ZhongZuDatas.requestServerData({
                method = "campExchangeList?",
                target = self,        
                success = function( )                      
                    ---刷新奖励列表
                    if self.__rewardList then 
                        self.__rewardList:reloadDataAndScrollToCurrentCell()
                    end 
                    ----刷新两种族的势力点进度
                    self:updateInforPowerBar()
                    ----更新任务面板的进度条
                    if self.__campTask.shiliPointBar then 
                        local max = ZhongZuDatas.getTaskMaxForce()
                        self.__campTask.shiliPointBar:setPercent(tonumber(ZhongZuDatas._serverBasic.dayAddForce) / max * 100)
                    end    
                    ---更新自己的势力点值     
                    local data = tonumber(ZhongZuDatas._serverBasic.dayAddForce)
                    data = data and data or 0 
                    if self.__campTask.shiliPointLabel then 
                        self.__campTask.shiliPointLabel:setString(data)
                        local x,y = self.__campTask.shiliPointLabel:getPosition()
                        if self.__campTask.shiliLabel then 
                            self.__campTask.shiliLabel:setPosition(x + self.__campTask.shiliPointLabel:getBoundingBox().width,y)
                        end 
                    end 
                    ---刷新任务的箱子
                    self:showTaskBoxCanGet()
                    ----更新任务列表和商店列表 
                    if self.__campTask.taskList then 
                        self.__campTask.taskList:reloadDataAndScrollToCurrentCell()
                    end 
                end                 
            })
        end
    })
end
-------_type : 任务，商店
function ZhongZuMainLayer:resetTaskOrStoreObj( _type )
    if _type == 1 then 
        self.__campTask = {---种族任务
            shiliPointLabel = nil, ---玩家为种族获得的势力点数的label
            shiliLabel = nil,--势力值后面的“势力值”label
            shiliPointBar = nil, ---势力点的进度条（带箱子的）    
            taskList = nil, --种族任务的列表    
            boxes = {},
        }
    elseif _type == 2 then 
        self.__campStore = { ----种族商店
            shiliPointLabel = nil ,
            shiliLabel = nil,
            honorLabel = nil,
            storeList = nil, -- 种族商店的列表
        }
    end 
end

function ZhongZuMainLayer:collectMemory( )
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/camp/camp_adjust_word2.png")
    textureCache:removeTextureForKey("res/image/camp/camp_main_bg.jpg")
    textureCache:removeTextureForKey("res/image/camp/camp_armycell_bg.png")
    textureCache:removeTextureForKey("res/image/camp/camp_main_bg1.png")
    textureCache:removeTextureForKey("res/image/camp/zy.png")
    textureCache:removeTextureForKey("res/image/camp/frames/zyzc.png")
    textureCache:removeTextureForKey("res/image/camp/frames/zyz.png")
    textureCache:removeTextureForKey("res/image/camp/frames/dzt.png")
    textureCache:removeTextureForKey("res/image/camp/frames/chelun.png")
    textureCache:removeTextureForKey("res/image/camp/frames/qianjin.png")
    textureCache:removeTextureForKey("res/image/camp/map/camp_cityInfo_bg1.png")
    textureCache:removeTextureForKey("res/image/camp/map/camp_cityInfo_bg2.png")
    textureCache:removeTextureForKey("res/image/camp/map/camp_cityInfo_bg3.png")
    textureCache:removeTextureForKey("res/image/camp/map/camp_ellipse.png")
    textureCache:removeTextureForKey("res/image/camp/map/camp_label_bg1.png")
    textureCache:removeTextureForKey("res/image/camp/map/camp_label_bg2.png")
    textureCache:removeTextureForKey("res/image/camp/map/camp_team_bg1.png")
    textureCache:removeTextureForKey("res/image/camp/map/camp_title_VS.png")
    textureCache:removeTextureForKey("res/image/camp/camp_bg7.jpg")
    for i = 1,20 do 
        if i < 5 then 
            textureCache:removeTextureForKey("res/image/camp/frames/hm0"..i..".png")
            textureCache:removeTextureForKey("res/image/camp/map/camp_map_bg"..i.."1.png")
            textureCache:removeTextureForKey("res/image/camp/map/camp_map_bg"..i.."2.png")
            textureCache:removeTextureForKey("res/image/camp/camp_build_btn"..i..".png")
        end 
        if i < 6 then 
            textureCache:removeTextureForKey("res/image/camp/map/camp_buildSmall"..i..".png")            
            textureCache:removeTextureForKey("res/image/camp/map/camp_cityName_yellow"..i..".png")            
            textureCache:removeTextureForKey("res/image/camp/map/camp_map_building"..i..".png")            
            textureCache:removeTextureForKey("res/image/camp/map/camp_map_building"..i.."2.png")            
            textureCache:removeTextureForKey("res/image/camp/camp_task_box"..i.."_1.png")            
            textureCache:removeTextureForKey("res/image/camp/camp_task_box"..i.."_2.png")            
        end 
        if i < 13 then 
            local _path = string.format("res/image/camp/frames/%02d.png",i)
            textureCache:removeTextureForKey(_path)
        end 
        if i < 7 then 
            textureCache:removeTextureForKey("res/image/camp/camp_bg"..i..".png")
            textureCache:removeTextureForKey("res/image/camp/camp_btn"..i.."_1.png")
        	textureCache:removeTextureForKey("res/image/camp/camp_btn"..i.."_2.png")
        end 
        textureCache:removeTextureForKey("res/image/camp/camp_label"..i..".png")
        if i < 12 then 
            textureCache:removeTextureForKey("res/image/camp/map/camp_label"..i..".png")
        end 
    end 
    helper.collectMemory()
end

return ZhongZuMainLayer