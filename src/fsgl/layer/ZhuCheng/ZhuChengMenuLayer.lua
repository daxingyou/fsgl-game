
-- Date: 2015-08-13
-- Purpose: 主城菜单层封装类
--[[ TODO List ]]
requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenDatas.lua")
local mGameUser = gameUser
local ZhuChengMenuLayer = class("ZhuChengMenuLayer", function(...)
    local obj = cc.Layer:create()
    return obj
end )

function ZhuChengMenuLayer:create(parent)
    local obj = ZhuChengMenuLayer.new(parent)
    obj:init()
    obj:registerScriptHandler( function(_type)
        if _type == "enter" then
            obj:onEnter()
        elseif _type == "exit" then
            obj:onExit()
        elseif _type == "cleanup" then
            obj:onCleanup()
        end
    end )
    return obj
end

function ZhuChengMenuLayer:ctor(parent)

    mGameUser = gameUser
    self._parent = parent
    self._animateFrames = parent._animateFrames
    self._padding = 5
    self._pushSceneCount = 0
    self._extraFuncID = 0
    ------在新功能开启的时候，如进竞技场之后还需要指到的功能ID
    self._propertyLable = { }
    --- 顶上的，玩家的财产（体力、银两、翡翠、元宝）
    self._propertyIcon = { }
    ----顶上的，玩家的财产图标（体力、银两、翡翠、元宝）
    self._warExeLabel = nil
    self._7dayAni = { }
    ----七天活动
    self._leftupBtns = { }
    ------左上边的功能按钮们的位置 包括右边按钮位置
    self._orgPosList = { }
    self._ceilbtnNode = nil
    -- 主城上面的活动按钮的容器节点
    self._rightbtnNode = nil
    -- 主城右边中间的按钮容器节点
    self._leftbtnNode = nil
    -- 主城左下角的按钮容器
    self._leftTopBtnNode = nil
    -- 主城左上角的按钮容器
    self._rightfloorbtnNode = nil
    -- 主城右下角按钮容器
    self._ceilbtnList1 = { }
    self._ceilbtnList2 = { }

    self._rightbtnList = { }
    self._floorbtnList = { }
    self._leftTopBtnList = { }
    self._leftFloorBtnList = { }

    self.Tag = {
        ktag_liuCunFrameTag = 100,
        ------开服奖励
        ktag_7dayActionTag = 101,
        ------7天礼包
        ktag_buildGetSource = 102,------建筑收集资源
    }

    FunctionYinDao:formatDatas()
    --------新目标数据
    --[[
    ---主城里所有可以点击的功能按钮，
    1 左上角的头像，2加体力按钮，3加银两按钮，4加翡翠，5加元宝，6聊天，7邮件，8竞技场（左边进攻），9活动，10任务，11英雄，12历练（）13 装备,14 开服大礼包.,15 背包,16 商店，17帮派
    18 排行榜奖励 19 神器,20 七天活动,21 回收按钮,22 宝典,23 新年活动,24 年兽,25 日常活动，27 毕业典礼，28 幸运转盘 ,29限时英雄，30限时商城，31修仙圣境 ,32冲榜活动
    ]]
    self.__functionButtons = { }
    self._bottomBtns = { }
    -----底部的按钮们（）
    -----加载动画
    for i = 1, 12 do
        local texture = cc.Director:getInstance():getTextureCache():addImage("res/image/homecity/qrkh/qrkh" .. i .. ".png")
        self._7dayAni[i] = cc.SpriteFrame:createWithTexture(texture, cc.rect(0, 0, texture:getPixelsWide(), texture:getPixelsHigh()))
    end
    XTHD.addEventListener( {
        name = CUSTOM_EVENT.REFRESH_FUNCTION_BTNSHOW,
        callback = function(event)
            self:adjustBottomBtns()
        end
    } )
    XTHD.addEventListener( {
        name = CUSTOM_EVENT.REFRESH_NEWFUNCTIONOPEN_TIP,
        callback = function(event)
            ----(目前在玩家升级的时候会发一次该事件)
            self:createNewTargetTip()
        end
    } )

    self.startTime = 1
    self.endTime = self.startTime
    -- 结束时间
    self.scaleAction = true
    -- 是否正在伸缩

    cc.Director:getInstance():getScheduler():scheduleScriptFunc( function()
        if self.scaleAction then
            if self.startTime > 0 then
                self.startTime = self.startTime - 1
            else
                self.startTime = self.endTime
                self.scaleAction = false
            end
        end
    end , 1, false)

    self.floorstartTime = 1
    self.floorendTime = self.floorstartTime
    -- 结束时间
    self.floorscaleAction = true
    -- 是否正在伸缩

    cc.Director:getInstance():getScheduler():scheduleScriptFunc( function()
        if self.floorscaleAction then
            if self.floorstartTime > 0 then
                self.floorstartTime = self.floorstartTime - 1
            else
                self.floorstartTime = self.floorendTime
                self.floorscaleAction = false
            end
        end
    end , 0.5, false)

    self.rightstartTime = 1
    self.rightendTime = self.rightstartTime
    -- 结束时间
    self.rightscaleAction = true
    -- 是否正在伸缩

    cc.Director:getInstance():getScheduler():scheduleScriptFunc( function()
        if self.rightscaleAction then
            if self.rightstartTime > 0 then
                self.rightstartTime = self.rightstartTime - 1
            else
                self.rightstartTime = self.rightendTime
                self.rightscaleAction = false
            end
        end
    end , 0.5, false)

end

function ZhuChengMenuLayer:init()

    ------底部黑边
    -- local _darkBG = cc.LayerColor:create(cc.c4b(0,0,0,100),self:getContentSize().width,25)
    local _darkBG = cc.Sprite:create("res/image/homecity/bottom.png")
    _darkBG:setScale(0.8)
    self.darkBG = _darkBG
    self.darkBG:setVisible(false)

    self:initHeadBar()

    self:addChild(_darkBG)
    _darkBG:setPosition(self:getContentSize().width / 2 + 10, 40)

    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(cc.size(self:getContentSize().width * 0.5 + 230, 200))
    scrollView:setScrollBarEnabled(false)
    scrollView:setAnchorPoint(1, 0.5)
    scrollView:setTouchEnabled(false)
    scrollView:setBounceEnabled(false)
    scrollView:setPosition(cc.p(self:getContentSize().width - 60, self:getContentSize().height - scrollView:getContentSize().height * 0.5 - 45))
    self:addChild(scrollView)

    -- 顶部按钮的容器
    self._ceilbtnNode = cc.Node:create()
    self._ceilbtnNode:setAnchorPoint(0.5, 0.5)
    self._ceilbtnNode:setContentSize(cc.size(self:getContentSize().width * 0.5 + 200, 200))
    self._ceilbtnNode:setPosition(scrollView:getContentSize().width * 0.5, scrollView:getContentSize().height * 0.5)
    scrollView:addChild(self._ceilbtnNode)


    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(cc.size(115, 320))
    scrollView:setScrollBarEnabled(false)
    scrollView:setAnchorPoint(0, 0)
    scrollView:setTouchEnabled(false)
    scrollView:setBounceEnabled(false)
    scrollView:setPosition(cc.p(self:getContentSize().width - scrollView:getContentSize().width + 7, 95))
    self:addChild(scrollView)

    self._rightbtnNode = cc.Node:create()
    self._rightbtnNode:setAnchorPoint(0.5, 0.5)
    self._rightbtnNode:setContentSize(cc.size(80, 300))
    self._rightbtnNode:setPosition(scrollView:getContentSize().width * 0.5, scrollView:getContentSize().height * 0.5 - 10)
    scrollView:addChild(self._rightbtnNode)

    self._leftbtnNode = cc.Node:create()
    self._leftbtnNode:setAnchorPoint(0, 0)
    self._leftbtnNode:setContentSize(cc.size(350, 110))
    self._leftbtnNode:setPosition(20, 10)
    self:addChild(self._leftbtnNode)

    self._leftTopBtnNode = cc.Node:create()
    self._leftTopBtnNode:setAnchorPoint(0, 0.5)
    self._leftTopBtnNode:setContentSize(cc.size(300, 110))
    self._leftTopBtnNode:setPosition(20, self:getContentSize().height / 2 + 200)
    self:addChild(self._leftTopBtnNode)

    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(cc.size(600, 100))
    scrollView:setScrollBarEnabled(false)
    scrollView:setAnchorPoint(1, 0)
    scrollView:setTouchEnabled(false)
    scrollView:setBounceEnabled(false)
    scrollView:setPosition(self:getContentSize().width - 90, 10)
    self:addChild(scrollView)

    self._rightfloorbtnNode = cc.Node:create()
    self._rightfloorbtnNode:setAnchorPoint(0.5, 0.5)
    self._rightfloorbtnNode:setContentSize(cc.size(600, 100))
    self._rightfloorbtnNode:setPosition(scrollView:getContentSize().width * 0.5, scrollView:getContentSize().height * 0.5)
    scrollView:addChild(self._rightfloorbtnNode)


    -- 记录初始位置
    self._ceilbtnNodePos = cc.p(self._ceilbtnNode:getPosition())
    self._rightbtnNodePos = cc.p(self._rightbtnNode:getPosition())
    self._rightfloorNodePos = cc.p(self._rightfloorbtnNode:getPosition())

    LayerManager.addChatRoom()

    -- 默认展开需要收缩
    self.needScaleBtn = true
    -- 右上角按钮缩进状态

    self.floorneedScaleBtn = true
    -- 右底部按钮缩进状态

    self.rightneedScaleBtn = true
    -- 右边按钮缩进状态

    local scaleBtnbg = cc.Sprite:create("res/image/common/btn/suofang_1.png")
    scaleBtnbg:setScale(0.5)
    self._scaleBtnbg = scaleBtnbg
    -- 收缩按钮
    local scaleBtn = XTHD.createButton( {
        touchSize = scaleBtnbg:getContentSize(),
        endCallback = function()
            self:startSortPos()
        end,
        anchor = cc.p(0.5,0.5),
        pos = cc.p(self:getContentSize().width - 30,self._chargeBtn:getPositionY() -55)
    } )
    self.scaleBtn = scaleBtn
    self:addChild(scaleBtn)
    scaleBtn:addChild(scaleBtnbg)
    scaleBtnbg:setPosition(scaleBtn:getContentSize().width * 0.5 - 15, scaleBtn:getContentSize().height * 0.5)

    scaleBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(1, cc.p(15, 0)), cc.MoveBy:create(1, cc.p(-15, 0)))))

    -- 右下角缩放按钮
    local scaleBtnbg_2 = cc.Sprite:create("res/image/common/btn/suofang_1.png")
    self._scaleBtnbg_2 = scaleBtnbg_2
    local floorscaleBtn = XTHD.createButton( {
        touchSize = scaleBtnbg_2:getContentSize(),
        endCallback = function()
            self:startFloorSortPos()
        end,
        anchor = cc.p(0.5,0.5),
        pos = cc.p(self:getContentSize().width / 2 - 150,40)
    } )

    floorscaleBtn:setScale(0.5)
    floorscaleBtn:runAction(cc.RepeatForever:create(
    cc.Sequence:create(
    cc.ScaleTo:create(0.5, 0.6),
    cc.ScaleTo:create(0.5, 0.5)
    )
    ))
    self.floorscaleBtn = floorscaleBtn
    self:addChild(floorscaleBtn, 99)
    floorscaleBtn:addChild(scaleBtnbg_2)
    scaleBtnbg_2:setPosition(floorscaleBtn:getContentSize().width * 0.5, floorscaleBtn:getContentSize().height * 0.5)
    -- floorscaleBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(1,cc.p(floorscaleBtn:getPositionX() + 15,floorscaleBtn:getPositionY())),cc.MoveBy:create(1,cc.p(floorscaleBtn:getPositionX() - 15,floorscaleBtn:getPositionY())))))

    -- 右边缩放按钮
    local scaleBtnbg_3 = cc.Sprite:create("res/image/common/btn/suofang_1.png")
    scaleBtnbg_3:setRotation(90)
    self._scaleBtnbg_3 = scaleBtnbg_3
    local rightscaleBtn = XTHD.createButton( {
        touchSize = scaleBtnbg_3:getContentSize(),
        endCallback = function()
            self:startRightSortPos()
        end,
        anchor = cc.p(0.5,0.5),
        pos = cc.p(self:getContentSize().width - 52,self:getContentSize().height / 2 + 100)
    } )

    rightscaleBtn:setScale(0.5)
    rightscaleBtn:runAction(cc.RepeatForever:create(
    cc.Sequence:create(
    cc.ScaleTo:create(0.5, 0.6),
    cc.ScaleTo:create(0.5, 0.5)
    )
    ))
    self.rightscaleBtn = rightscaleBtn
    self:addChild(rightscaleBtn, 100)
    rightscaleBtn:addChild(scaleBtnbg_3)
    scaleBtnbg_3:setPosition(rightscaleBtn:getContentSize().width * 0.5, rightscaleBtn:getContentSize().height * 0.5)

    self:initLeftMenu()
    self:initNumberBar()
    self:initRightUpMenu()
    self:initBottomMenu()


    self:initLeftUpMenu()

    XTHD.addEventListener( {
        name = CUSTOM_EVENT.DISPLAY_BATTLEBEGINS_TIP,
        callback = function(event)
            -----种族战、世界boss功能开启 时候 的快捷入口
            local _war = event.data.war
            local index = event.data.warIndex
            self:switchFromNewGoalAndBattle(_war, index)
        end
    } )

    if mGameUser.getLevel() > 7 and mGameUser.getMeiRiQianDaoState() == 1 then
        local popLayer = requires("src/fsgl/layer/ConstraintPoplayer/MeiRiQianDaoPopLayer.lua"):create()
        self:addChild(popLayer)
    end
    self:refreshTopInfo()
    self:refreshBaseInfo()

end

-- 开始将按钮伸缩到指定位置
function ZhuChengMenuLayer:startSortPos()
    if self.scaleAction then return end
--     self:refreshBaseInfo()
    self.scaleBtn:setEnable(false)  
    if self.needScaleBtn then
        local time = 0.05
        for i = 1, #self._ceilbtnList1 do
            if self._ceilbtnList1[i]:getName() == "bosscome" then
                self._ceilbtnList1[i]:runAction(cc.Sequence:create(cc.DelayTime:create(time * i), cc.ScaleTo:create(time, 1.2, 1.2), cc.ScaleTo:create(time, 1, 1)))
            else
                self._ceilbtnList1[i]:runAction(cc.Sequence:create(cc.DelayTime:create(time * i), cc.ScaleTo:create(time, 0.8, 0.8), cc.ScaleTo:create(time, 0.6, 0.6)))
            end
        end

        for i = 1, #self._ceilbtnList2 do
            self._ceilbtnList2[i]:runAction(cc.Sequence:create(cc.DelayTime:create(time * i), cc.ScaleTo:create(time, 0.8, 0.8), cc.ScaleTo:create(time, 0.6, 0.6)))
        end

        self._ceilbtnNode:runAction(cc.Sequence:create(
        cc.DelayTime:create(time * #self._ceilbtnList1),
        cc.MoveTo:create(0.5, cc.p(self._ceilbtnNodePos.x + self._ceilbtnNode:getContentSize().width + 100, self._ceilbtnNodePos.y)),
        -- cc.DelayTime:create(10),
        cc.CallFunc:create( function()
            self.scaleBtn:setEnable(true)
            self._ceilbtnNode:setVisible(false)
            self.needScaleBtn = false
            self._scaleBtnbg:setTexture("res/image/common/btn/suofang_2.png")
        end )
        ))
    else
        local time = 0.5
        local time2 = 0.05
        -- 需要展开	
        self._ceilbtnNode:setVisible(true)
        self._ceilbtnNode:runAction(cc.Sequence:create(
        cc.MoveTo:create(time, cc.p(self._ceilbtnNodePos)),
        cc.CallFunc:create( function()
            self.scaleBtn:setEnable(true)
            self.needScaleBtn = true
            self._scaleBtnbg:setTexture("res/image/common/btn/suofang_1.png")
        end )
        ))
        for i = 1, #self._ceilbtnList1 do
            if self._ceilbtnList1[i]:getName() == "bosscome" then
                self._ceilbtnList1[i]:runAction(cc.Sequence:create(cc.DelayTime:create(time2 * i + time), cc.ScaleTo:create(time2, 1.2, 1.2), cc.ScaleTo:create(time2, 1, 1)))
            else
                self._ceilbtnList1[i]:runAction(cc.Sequence:create(cc.DelayTime:create(time2 * i + time), cc.ScaleTo:create(time2, 0.8, 0.8), cc.ScaleTo:create(time2, 0.6, 0.6)))
            end
        end

        for i = 1, #self._ceilbtnList2 do
            self._ceilbtnList2[i]:runAction(cc.Sequence:create(cc.DelayTime:create(time2 * i + time), cc.ScaleTo:create(time2, 0.8, 0.8), cc.ScaleTo:create(time2, 0.6, 0.6)))
        end
    end
end

-- 收缩右边按钮
function ZhuChengMenuLayer:startRightSortPos()

    -- self._rightbtnNodePos
    -- self._rightfloorNodePos
    -- if gameUser.getLevel() < 49 then
    -- 	XTHDTOAST("49级开启收缩功能！")
    -- 	return
    -- end
    if self.rightscaleAction then return end
    self.rightscaleBtn:setEnable(false)
    if self.rightneedScaleBtn then
        local time = 0.05

        for i = 1, #self._rightbtnList do
            self._rightbtnList[i]:runAction(cc.Sequence:create(cc.DelayTime:create(time *(i - 1)), cc.ScaleTo:create(time, 0.9, 0.9), cc.ScaleTo:create(time, 0.6, 0.6)))
        end

        self._rightbtnNode:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2 + #self._floorbtnList * time),
        cc.MoveTo:create(0.5, cc.p(self._rightbtnNodePos.x, self._rightbtnNodePos.y - self._rightbtnNode:getContentSize().height * 0.5 - 100)),
        cc.CallFunc:create( function()
            self.rightscaleBtn:setPosition(self:getContentSize().width - 52, 125)
            self.rightscaleBtn:setEnable(true)
            self._rightbtnNode:setVisible(false)
            self.rightneedScaleBtn = false
        end )
        ))

        self._scaleBtnbg_3:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2 + #self._floorbtnList * time),
        cc.CallFunc:create( function()
            self._scaleBtnbg_3:setScale(-1)
        end )
        ))
    else
        local time = 0.5
        local time2 = 0.05

        self.rightscaleBtn:setPosition(self:getContentSize().width - 52, self.rightPosY)
        self._rightbtnNode:setVisible(true)
        self._rightbtnNode:runAction(cc.Sequence:create(
        cc.MoveTo:create(time, cc.p(self._rightbtnNodePos)),
        cc.CallFunc:create( function()
            self.rightscaleBtn:setEnable(true)
            self.rightneedScaleBtn = true
        end )
        ))

        for i = 1, #self._rightbtnList do
            self._rightbtnList[i]:runAction(cc.Sequence:create(cc.DelayTime:create(time2 * i + time - 0.1), cc.ScaleTo:create(time2, 0.9, 0.9), cc.ScaleTo:create(time2, 0.6, 0.6)))
        end

        self._scaleBtnbg_3:runAction(cc.Sequence:create(
        cc.CallFunc:create( function()
            self._scaleBtnbg_3:setScale(1)
        end )
        ))
    end
end

-- 收缩右底部按钮
function ZhuChengMenuLayer:startFloorSortPos()

    -- self._rightbtnNodePos
    -- self._rightfloorNodePos
    -- if gameUser.getLevel() < 49 then
    -- 	XTHDTOAST("49级开启收缩功能！")
    -- 	return
    -- end
    if self.floorscaleAction then return end
    self.floorscaleBtn:setEnable(false)
    if self.floorneedScaleBtn then
        -- 收缩时添加引导
        YinDaoMarg:getInstance():addGuide( {
            parent = self,
            target = self.floorscaleBtn,
            needNext = false,
        } , {
            { - 1, 1 },
            { 2, 2 },
            { 6, 2 },
            { 21, 1 },
        } )

        local time = 0.05

        for i = 1, #self._floorbtnList do
            self._floorbtnList[i]:runAction(cc.Sequence:create(cc.DelayTime:create(time *(i - 1)), cc.ScaleTo:create(time, 0.9, 0.9), cc.ScaleTo:create(time, 0.7, 0.7)))
        end

        self._rightfloorbtnNode:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2 + #self._floorbtnList * time),
        cc.MoveTo:create(0.5, cc.p(self._rightfloorNodePos.x + self._rightfloorbtnNode:getContentSize().width + 100, self._rightfloorNodePos.y)),
        cc.CallFunc:create( function()
            self.floorscaleBtn:setPosition(self:getContentSize().width - 125, 40)
            self.floorscaleBtn:setEnable(true)
            self._rightfloorbtnNode:setVisible(false)
            self.floorneedScaleBtn = false
        end )
        ))
        self._scaleBtnbg_2:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2 + #self._floorbtnList * time),
        cc.CallFunc:create( function()
            self._scaleBtnbg_2:setScale(-1)
        end )
        ))
    else
        -- 展开时执行完当前引导并删除老的数据
        local group, step = YinDaoMarg:getInstance():getGuideSteps()
        if (group == -1 and step == 2) or(group == 2 and step == 3) or(group == 6 and step == 3) or(group == 21 and step == 2) then
            YinDaoMarg:getInstance():guideTouchEnd()
        end
        YinDaoMarg:getInstance():removeGuide( { group = - 1, step = 1 })
        YinDaoMarg:getInstance():removeGuide( { group = 2, step = 2 })
        YinDaoMarg:getInstance():removeGuide( { group = 6, step = 2 })
        YinDaoMarg:getInstance():removeGuide( { group = 21, step = 1 })

        local time = 0.5
        local time2 = 0.05

        self.floorscaleBtn:setPosition(self.rightFloorPosX, 40)
        self._rightfloorbtnNode:setVisible(true)
        self._rightfloorbtnNode:runAction(cc.Sequence:create(cc.MoveTo:create(time, cc.p(self._rightfloorNodePos)), cc.CallFunc:create( function()
            YinDaoMarg:getInstance():doNextGuide()
            self.floorscaleBtn:setEnable(true)
            self.floorneedScaleBtn = true
        end )))
        for i = 1, #self._floorbtnList do
            self._floorbtnList[i]:runAction(cc.Sequence:create(cc.DelayTime:create(time2 * i + time - 0.1), cc.ScaleTo:create(time2, 0.9, 0.9), cc.ScaleTo:create(time2, 0.7, 0.7)))
        end

        self._scaleBtnbg_2:runAction(cc.Sequence:create(
        cc.CallFunc:create( function()
            self._scaleBtnbg_2:setScale(1)
        end )
        ))
    end
end

-- 初始化头像模块
function ZhuChengMenuLayer:initHeadBar(...)
    -- ly3.17
    -----名字框
    local nameBox = ccui.Scale9Sprite:create("res/image/homecity/city_player_nameBox.png")
    -- nameBox:setContentSize(250,40)
    -- nameBox:setScaleY(0.7)
    -- nameBox:setScaleX(0.6)
    self:addChild(nameBox)
    nameBox:setAnchorPoint(0, 1)
    nameBox:setPosition(88, self:getContentSize().height - 10)

    -- 昵称ly3.17
    self._nick_name_label = XTHDLabel:create("梅长苏", 17, "res/fonts/def.ttf")
    self._nick_name_label:setAnchorPoint(0, 0.5)
    self._nick_name_label:setColor(cc.c3b(255, 255, 255))
    -- self._nick_name_label:enableOutline(cc.c4b(0,0,0,255),2)
    -- self._nick_name_label:setSystemFontSize(22)
    self._nick_name_label:setPosition(40, nameBox:getBoundingBox().height / 2 - 2)
    nameBox:addChild(self._nick_name_label)

    -- vipBox:setPosition(nameBox:getPositionX()+40,nameBox:getPositionY() - nameBox:getBoundingBox().height - 30)
    --- 经验进度条背景
    local bar_bg = cc.Sprite:create("res/image/homecity/city_player_bar_bg.png")
    self:addChild(bar_bg)
    bar_bg:setScale(0.9)
    bar_bg:setAnchorPoint(0, 1)
    bar_bg:setPosition(90, self:getContentSize().height - 72)

    --- 经验进度条
    self._exp_progress_timer = cc.ProgressTimer:create(cc.Sprite:create("res/image/homecity/city_player_bar.png"))
    -- self._exp_progress_timer:setScale(0.6)
    bar_bg:addChild(self._exp_progress_timer, 2)
    self._exp_progress_timer:setPosition(80, self._exp_progress_timer:getContentSize().height - 7)
    self._exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    self._exp_progress_timer:setMidpoint(cc.p(0, 0.5));
    self._exp_progress_timer:setPercentage(80.0);
    self._exp_progress_timer:setBarChangeRate(cc.p(1, 0));

    local expText = XTHDLabel:create(mGameUser.getExpNow() .. "/" .. mGameUser.getExpMax(), 13, "res/fonts/def.ttf")
    bar_bg:addChild(expText, 10)
    expText:setPosition(bar_bg:getContentSize().width / 2, bar_bg:getContentSize().height / 2 - 1)
    expText:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self.expText = expText

    -- 战力
    local fight = cc.Sprite:create("res/image/homecity/fightBg.png")
    self:addChild(fight)
    fight:setContentSize(fight:getContentSize().width, fight:getContentSize().height - 7)
    fight:setPosition(183, self:getContentSize().height - 59)

    local fightValue = XTHDLabel:create("0", 16, "res/fonts/def.ttf")
    fight:addChild(fightValue)
    fightValue:setAnchorPoint(0, 0.5)
    fightValue:setPosition(fight:getContentSize().width / 2 - 40, fight:getContentSize().height / 2 - 1)
    fightValue:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self.fightValue = fightValue
    XTHD.addEventListener( {
        name = CUSTOM_EVENT.REFRESH_PLAYERPOWER,
        callback = function(event)
            self.fightValue:setString(tostring(DBTableHero.getAllHeroPower()))
        end
    } )
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_PLAYERPOWER })

    -- ly3.15
    -- 头像框
    local avatar_bg = cc.Sprite:create("res/image/homecity/city_player_iconBox2.png")
    avatar_bg:setScale(0.9)
    avatar_bg:setPosition(avatar_bg:getContentSize().width / 2, self:getContentSize().height - avatar_bg:getContentSize().height / 2 - 5)
    self:addChild(avatar_bg)

    -- 显示当前时间
    self._curTime = XTHDLabel:create("0", 24, "res/fonts/def.ttf")
    -- self._curTime:enableOutline(cc.c4b(255,255,255,255),2)
    self._curTime:enableBold()
    self:addChild(self._curTime)
    self._curTime:setAnchorPoint(0, 0)
    -- self._curTime:setScale(0.7)
    self._curTime:setColor(cc.c3b(255, 255, 255))
    -- self._curTime:setPosition(avatar_bg:getPositionX() - avatar_bg:getContentSize().width/2 + 10, avatar_bg:getPositionY() - avatar_bg:getContentSize().height/2 - 40)
    self._curTime:setPosition(self:getContentSize().width - 65, self:getContentSize().height - 40)

    self._curTime:setString(os.date("%H:%M"))
    self._curTime:runAction(cc.RepeatForever:create(
    cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function()
        self._curTime:setString(os.date("%H:%M"))
    end )
    )))

    -- 修改便于在设置里修改主城头像
    -- ly3.15
    local avatornum = mGameUser.getTemplateId()
    self.avator = cc.Sprite:create(zctech.getHeroAvatorImgById(avatornum))
    self.avator:setScale(0.78)
    self:addChild(self.avator)

    self.avator:setPosition(avatar_bg:getPositionX(), avatar_bg:getPositionY() -2)
    local function changAvatorCallBack(id, data)
        -- hungjunjian 设置修改主城信息
        if id and id == 1 then
            self.avator:initWithFile(zctech.getHeroAvatorImgById(data))
            mGameUser.setTemplateId(data)
        elseif id and id == 2 then
            self:refreshTopInfo()
            self:refreshBaseInfo()
        end
    end
    self._avator = XTHDPushButton:createWithParams( {
        musicFile = XTHD.resource.music.effect_btn_common,
        needSwallow = true,
        enable = true,
        endCallback = function()
            LayerManager.addShieldLayout()
            self:getParent():cleanOperatorBtns()
            local settingLayer = requires("src/fsgl/layer/ZhuCheng/SheZhiLayer.lua")
            LayerManager.addLayout(settingLayer:create(changAvatorCallBack), { par = self, noHide = true })
        end,
        touchSize = cc.size(100,100)
    } )
    self._avator:setPosition(cc.p(avatar_bg:getBoundingBox().width / 2, avatar_bg:getBoundingBox().height / 2 - 2))
    avatar_bg:addChild(self._avator)
    --- 等级框
    -- ly3.17
    -- local levelBox = cc.Sprite:create("res/image/homecity/city_player_levelBox.png")
    -- self:addChild(levelBox)
    -- levelBox:setAnchorPoint(1,0.5)
    -- levelBox:setPosition(avatar_bg:getPositionX()+avatar_bg:getContentSize().width/2+20,avatar_bg:getPositionY()+30)
    -- levelBox:setScaleY(0.9)
    -- 等级
    self._level_label = getCommonWhiteBMFontLabel("0", 1000000)
    self._level_label:setPosition(21, nameBox:getBoundingBox().height / 2 - 3)
    self._level_label:setScale(0.5)
    nameBox:addChild(self._level_label)
    -- 种族框
    -- ly3.15
    -- local campBox = cc.Sprite:create("res/image/homecity/city_player_levelBox.png")
    -- self:addChild(campBox)
    -- campBox:setAnchorPoint(0,0)
    -- campBox:setPosition(avatar_bg:getPositionX()-20,avatar_bg:getPositionY()+15)
    ----种族图标
    -- ly3.15
    local _campIcon = cc.Sprite:create("res/image/homecity/camp_icon" .. mGameUser.getCampID() .. ".png")
    self:addChild(_campIcon)
    _campIcon:setAnchorPoint(0, 0.5)
    -- _campIcon:setPosition(avatar_bg:getPositionX(),avatar_bg:getPositionY()+35)
    _campIcon:setPosition(avatar_bg:getPositionX() - avatar_bg:getContentSize().width / 2 + 15, avatar_bg:getPositionY() - avatar_bg:getContentSize().height / 2 + 15)
    self.campIcon = _campIcon

    local vipNode = cc.Node:create()
    self:addChild(vipNode)
    vipNode:setPosition(280, self:getContentSize().height - 22)
    local vipBg = cc.Sprite:create("res/image/vip/vip_big.png")
    vipBg:setScale(0.4)
    vipNode:addChild(vipBg)
    if mGameUser.getVip() < 10 then
        local vipg = cc.Sprite:create("res/image/vip/vip_" .. tostring(mGameUser.getVip()) .. ".png")
        vipg:setScale(0.5)
        vipNode:addChild(vipg)
        vipNode:setContentSize(vipBg:getBoundingBox().width * 0.4 + vipg:getBoundingBox().width, vipBg:getBoundingBox().height)
        vipg:setPosition(vipBg:getBoundingBox().width - 23, vipBg:getBoundingBox().height / 2 - 22)
    else
        local vipg = cc.Sprite:create("res/image/vip/vip_" .. tostring((math.floor(mGameUser.getVip() / 10))) .. ".png")
        vipg:setScale(0.5)
        vipNode:addChild(vipg)
        local vips = cc.Sprite:create("res/image/vip/vip_" .. tostring((mGameUser.getVip() % 10)) .. ".png")
        vips:setScale(0.5)
        vipNode:addChild(vips)
        vipNode:setContentSize(vipBg:getBoundingBox().width * 0.4 + vipg:getBoundingBox().width * 0.5 + vips:getBoundingBox().width * 0.5, vipBg:getBoundingBox().height * 0.5)
        vipg:setPosition(vipBg:getBoundingBox().width - 23, vipBg:getBoundingBox().height / 2 - 22)
        vips:setPosition(vipBg:getBoundingBox().width + vipg:getBoundingBox().width - 26, vipBg:getBoundingBox().height / 2 - 22)
    end

    local vipBtn = XTHDPushButton:createWithParams( {
        musicFile = XTHD.resource.music.effect_btn_common,
        needSwallow = true,
        enable = true,
        touchSize = cc.size(65,30)
    } )
    self:addChild(vipBtn)
    vipBtn:setPosition(vipNode:getPosition())
    vipBtn:setTouchBeganCallback( function()
        vipNode:setScale(0.9)
    end )
    vipBtn:setTouchMovedCallback( function()
        vipNode:setScale(0.9)
    end )
    vipBtn:setTouchEndedCallback( function()
        XTHD.createVipLayer(self)
        vipNode:setScale(1)
    end )

    ----vip显示
    local vipBox = XTHDPushButton:createWithParams( {
        normalFile = "res/image/homecity/menu_vip1.png",
        selectedFile = "res/image/homecity/menu_vip2.png",
        musicFile = XTHD.resource.music.effect_btn_common,
    } )
    -- ly3.15
    vipBox:setScale(0.7)
    self:addChild(vipBox)
    vipBox:setAnchorPoint(0, 1)
    vipBox:setPosition(nameBox:getPositionX() + 30, nameBox:getPositionY() - nameBox:getBoundingBox().height - 26)
    self._vip_num_sp = XTHDLabel:create("0", 32, "res/fonts/def.ttf")
    -- self._vip_num_sp:enableOutline(cc.c4b(100,100,255,255),2)

    vipBox:addChild(self._vip_num_sp)
    self._vip_num_sp:setAnchorPoint(0.5, 0.5)
    -- self._vip_num_sp:setAdditionalKerning(-1)
    -- self._vip_num_sp:setScale(0.7)
    self._vip_num_sp:setColor(cc.c3b(255, 255, 255))
    self._vip_num_sp:setPosition(vipBox:getContentSize().width / 2 + 17, vipBox:getContentSize().height / 2 - 5)

    vipBox:setTouchEndedCallback( function()
        --        LayerManager.addShieldLayout()
        --        self:getParent():cleanOperatorBtns()
        XTHD.createVipLayer(self)
    end )
    local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
    redDot:setScale(0.8)
    vipBox:addChild(redDot)
    redDot:setPosition(vipBox:getBoundingBox().width + 15, vipBox:getBoundingBox().height - 5)
    redDot:setVisible(gameUser.hasVipReward())
    self._vipRedDot = redDot
    vipBox:setVisible(false)
    -----充值
    local charge = XTHDPushButton:createWithParams( {
        normalFile = "res/image/homecity/menu_charge1.png",
        selectedFile = "res/image/homecity/menu_charge2.png",
        musicFile = XTHD.resource.music.effect_btn_common,
    } )
    charge:setScale(0.9)
    self:addChild(charge)
    charge:setAnchorPoint(0, 1)
    charge:setPosition(vipBox:getPositionX() + vipBox:getBoundingBox().width + 35, vipBox:getPositionY() + 30)
    charge:setTouchEndedCallback( function()
      	local voucherLayer = requires("src/fsgl/layer/VoucherCenter/VoucherCenterLayer.lua"):create()
		LayerManager.addLayout(voucherLayer)
    end )
    self._chargeBtn = charge

    local switch = XTHDPushButton:createWithParams( {
        normalFile = "res/image/homecity/menu_charge1.png",
        selectedFile = "res/image/homecity/menu_charge2.png",
        musicFile = XTHD.resource.music.effect_btn_common,
    } )
    switch:setScale(0.7)
    self:addChild(switch)
    switch:setAnchorPoint(0, 1)
    switch:setPosition(vipBox:getPositionX() + vipBox:getBoundingBox().width + 65, vipBox:getPositionY() + 8)
    switch:setTouchEndedCallback( function()
        XTHD.switchAccount()
    end )
    switch:setVisible(false)

    local _strengthen = XTHDPushButton:createWithParams( {
        normalFile = "res/image/Strengthen/wybq_up.png",
        selectedFile = "res/image/Strengthen/wybq_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
    } )
    self:addChild(_strengthen)
    _strengthen:setPosition(cc.p(nameBox:getPositionX() + 165, fight:getPositionY()))
    _strengthen:setScale(0.8)
    _strengthen:setTouchEndedCallback( function()
        -- 	local layer = requires("src/fsgl/layer/JiBan/JiBanLayer.lua"):create()
        -- 	self:addChild(layer)
        self:StrengthenLayerCreate()
        -- local layer = requires("src/fsgl/layer/QiXingTan/QiXingTanGetNewHeroLayer.lua"):create({
        --      	par = self,
        --        id = 37,
        --        star =2,
        -- })
        -- 	local kuafuzhan = requires("src/fsgl/layer/KuaFuZhan/RankChooseLayer.lua")
        -- 	self:addChild(kuafuzhan)
        -- local layer = requires("src/fsgl/layer/ZhongZu/ZhongZuRegisterLayer.lua"):createWithParams( {
        --           campID = 1,
        --       })
        --       self:addChild(layer)
        -- self.lay = requires("src/fsgl/layer/YinDaoJieMian/YinDaoSelectHeroLayer.lua"):create( function()
        --          self.lay:removeFromParent()
        --      end )
        --      self:addChild(self.lay)
        --    local popLayer = requires("src/fsgl/layer/ConstraintPoplayer/MeiRiQianDaoPopLayer.lua"):create()
        -- self:addChild(popLayer)
        -- local popLayer = requires("src/fsgl/layer/ConstraintPoplayer/QiXinTanPopLayer.lua"):create()
        -- self:addChild(popLayer)
    end )
    -- _strengthen:setVisible(false)

    -- 竞技场段信息
    local cd_sp = XTHDSprite:create("res/image/common/topbarItem_bg.png")
    cd_sp:setScale(0.8)
    cd_sp:setAnchorPoint(0, 0.5)
    cd_sp:setPosition(20, avatar_bg:getPositionY() - avatar_bg:getContentSize().height / 2 - cd_sp:getBoundingBox().height / 2)
    self:addChild(cd_sp)
    cd_sp:setVisible(false)

    local haojiao = cc.Sprite:create("res/image/plugin/competitive_layer/competitiveDefense_Prestige.png")
    cd_sp:addChild(haojiao)
    haojiao:setScale(0.7)
    haojiao:setPosition(0, cd_sp:getContentSize().height / 2)

    self._arenaDuanIcon = XTHDSprite:create("res/image/common/rank_icon/rankIcon_0.png")
    self._arenaDuanIcon:setScale(0.16)
    self._arenaDuanIcon:setPosition(cd_sp:getContentSize().width, cd_sp:getContentSize().height / 2)
    cd_sp:addChild(self._arenaDuanIcon)

    self._cd_label = getCommonWhiteBMFontLabel("0", 1000000)
    -- XTHDLabel:create("",18)
    self._cd_label:setPosition(cd_sp:getContentSize().width / 2, cd_sp:getContentSize().height / 2 - 7)
    cd_sp:addChild(self._cd_label)
end

-- 初始化顶部的 玩家的财产 信息
function ZhuChengMenuLayer:initNumberBar()
    local space = 30
    local _iconSRC = { "res/image/common/header_tili.png", "res/image/common/header_gold.png", "res/image/common/header_feicui.png", "res/image/common/common_gold.png" }
    local x = 350
    for i = 1, 4 do
        --- 体力、银两、翡翠、元宝
        local _barkBG = XTHDPushButton:createWithParams( {
            normalFile = "res/image/common/topbarItem_bg.png",
            selectedFile = "res/image/common/topbarItem_bg.png",
            needEnableWhenOut = true,
        } )
        -- ly3.15
        _barkBG:setScale(0.9)
        local _touchSize = _barkBG:getContentSize()
        _barkBG:setTouchSize(cc.size(_touchSize.width, _touchSize.height + 30))
        _barkBG:setTouchBeganCallback( function()
            _barkBG:setScale(0.8)
            self:showBoxTips(_barkBG, i)
        end )
        _barkBG:setTouchMovedCallback( function()
            _barkBG:setScale(0.8)
        end )
        _barkBG:setTouchEndedCallback( function()
            _barkBG:setScale(0.9)
            if self._boxTips then
                self._boxTips:removeFromParent()
                self._boxTips = nil
            end
        end )
        _barkBG:setPosition(x + _barkBG:getBoundingBox().width / 2, self:getContentSize().height - _barkBG:getBoundingBox().height / 2 - 10)
        self:addChild(_barkBG)

        local physical_icon = cc.Sprite:create(_iconSRC[i])
        physical_icon:setScale(0.9)
        physical_icon:setPosition(0, _barkBG:getContentSize().height / 2)
        _barkBG:addChild(physical_icon)
        self._propertyIcon[i] = physical_icon

        local _numLabel = getCommonWhiteBMFontLabel("999")
        _numLabel:setPosition(_barkBG:getContentSize().width / 2, physical_icon:getPositionY() -7)
        _barkBG:addChild(_numLabel)
        self._propertyLable[i] = _numLabel

        local _addButton = XTHDPushButton:createWithParams( {
            normalFile = "res/image/common/btn/btn_plus_normal.png",
            -- 默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
            selectedFile = "res/image/common/btn/btn_plus_selected.png",
            musicFile = XTHD.resource.music.effect_btn_common,
            endCallback = function()
                self:getParent():cleanOperatorBtns()
                self:doTopAddButtons(i)
            end,
        } )
        local _size = _addButton:getContentSize()
        _addButton:setAnchorPoint(1, 0.5)
        _addButton:setPosition(_barkBG:getContentSize().width + 10, _barkBG:getContentSize().height / 2)
        _barkBG:addChild(_addButton)
        _addButton:setTouchSize(cc.size(_addButton:getContentSize().width + 20, _addButton:getContentSize().height))
        _addButton:setTouchSize(cc.size(_size.width + 20, _size.height + 20))
        x = _barkBG:getPositionX() + _barkBG:getBoundingBox().width / 2 + space
        -- if i==2 or i == 3 then
        --     _addButton:setVisible(false)
        -- end
    end
end

-- 初始化 左侧按钮
function ZhuChengMenuLayer:initLeftMenu()
    -- 战斗, 邮件, 装备, 任务, 活动, 帮助, 资源找回
    local menuInfo = { }
    menuInfo.fileName = { "menu_battle_left", "men_friend", "", "xxsj", "zyzh", "newmail" }
    menuInfo.menuFunction = function(sIndex)
        LayerManager.addShieldLayout()
        if (sIndex == 1) then
            ----引导
            YinDaoMarg:getInstance():guideTouchEnd()
            -------
            if self._Pointer then
                ----是从新功能来的
                self:removePointer()
                XTHD.createCompetitiveLayer(nil, self._extraFuncID)
                ----竞技场
            else
                XTHD.createCompetitiveLayer()
                ----竞技场
            end
        elseif (sIndex == 2) then
            requires("src/fsgl/layer/HaoYou/HaoYouLayer.lua"):create(self)
        elseif (sIndex == 3) then
            XTHD.showChatroom(self, self.__chatButton)
        elseif (sIndex == 4) then
            XTHD.createHangUpLayer(self)
        elseif sIndex == 5 then
            XTHD.showRecoveryLayer(self)
        elseif sIndex == 6 then
            XTHD.createMail(self)
        end
    end

    local menuBtns = self:createMenus(menuInfo)
    local menuBtn = nil
    local x = 15
    for i = 1, #menuBtns do
        menuBtn = menuBtns[i]
        menuBtn:setAnchorPoint(0, 0)
        menuBtn:setPosition(x, 2)
        if i == 1 then
            self.__functionButtons[8] = menuBtn
            -- 竞技按钮位置
            -- menuBtn:setPosition(cc.p(self:getContentSize().width-215,10))
            self:PushBtnToLeftNode(menuBtn)
        elseif (i == 2 or i == 3) then
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getContentSize().width - redDot:getContentSize().width, menuBtn:getContentSize().height - 15)
            redDot:setVisible(false)
            if (i == 2) then
                self._friendRedDot = redDot
                -- 好友按钮位置
                menuBtn:setScale(0.6)
                self:PushBtnToRightNode(menuBtn)
            elseif (i == 3) then
                local _posX = 12
                if screenRadio > 1.8 then
                    -- 适配刘海屏和全面屏-左移32个像素
                    _posX = 45
                end
                menuBtn:setAnchorPoint(0, 0.5)
                menuBtn:setPosition(cc.p(_posX, self:getContentSize().height * 0.5 + 0))
                menuBtn:setName("chat_button")
                menuBtn:setTouchSize(cc.size(menuBtn:getBoundingBox().width + 5, menuBtn:getBoundingBox().height + 30))
                redDot:setPosition(menuBtn:getBoundingBox().width, menuBtn:getBoundingBox().height * 0.5 + 20)
                redDot:setVisible(false)
                self.__chatButton = menuBtn
                self.__functionButtons[6] = menuBtn
                self.__chatRedDot = redDot
            end
        elseif i == 4 then
            -- 修仙圣境
            self:PushBtnToRightNode(menuBtn)
            menuBtn:setScale(0.6)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getContentSize().width - redDot:getContentSize().width, menuBtn:getContentSize().height - 15)
            redDot:setVisible(false)
            self.xxsjRedDot = redDot
            self.__functionButtons[31] = menuBtn
            self.__functionButtons[31]:setVisible(gameUser.getLevel() >= 40)
        elseif i == 5 then
            -- 资源找回按钮位置
            self:PushBtnToLeftNode(menuBtn)
            menuBtn:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
            cc.ScaleTo:create(0.5, 1),
            cc.ScaleTo:create(0.5, 0.9)
            )
            ))
            menuBtn:setAnchorPoint(0.5, 0)
            -- menuBtn:setPosition(cc.p(self:getContentSize().width/2 - 190, 3))
            menuBtn:setScale(0.7)
            self.__functionButtons[66] = menuBtn
        elseif i == 6 then
            -- 资源找回按钮位置
            menuBtn:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
            cc.ScaleTo:create(0.5, 1.2),
            cc.ScaleTo:create(0.5, 1)
            )
            ))
            menuBtn:setAnchorPoint(0.5, 0.5)
            menuBtn:setPosition(cc.p(self:getContentSize().width - 105, self:getContentSize().height - 25))
            menuBtn:setVisible(false)
            self.__functionButtons[67] = menuBtn
        end
        x = x + menuBtn:getBoundingBox().width + self._padding
    end

    XTHD.addEventListener( {
        name = EVENT_NAME_CHANGE_CHAT_REDDOT,
        callback = function(event)
            -- if event.data.visible == true and self.__chatRedDot and not LiaoTianRoomLayer.__isAtShowing then
            --     self.__chatRedDot:setVisible(true)
            -- elseif event.data.visible == false and self.__chatRedDot then
            --     self.__chatRedDot:setVisible(false)
            -- end
            XTHD.dispatchEvent( { name = CUSTOM_EVENT.SHOW_CHAT_REDDOT_AT_CAMP, data = { visible = event.data.visible } })
            -----刷新种族里的聊天红点
        end
    } )
end

-- 初始化 右侧按钮信息
function ZhuChengMenuLayer:initBottomMenu()
    -- 竞技, 英雄, 装备,行囊,商店，宝典,神器，回收，帮派
    local menuInfo = { }
    menuInfo.fileName = { "menu_experice", "menu_hero", "menu_equip", "menu_backpack", "menu_shangdian", "menu_baodian", "menu_artifact", "menu_smelt", "menu_bangpai" }
    menuInfo.pos = cc.p(self:getContentSize().width - self._padding, self._padding)
    menuInfo.menuFunction = function(sIndex)
        LayerManager.addShieldLayout()
        if (sIndex == 1) then
            self:onExpericeBtn()
        elseif (sIndex == 2) then
            self:onHeroBtn()
        elseif (sIndex == 3) then
            self:onEquipBtn()
        elseif (sIndex == 5) then
            self:toStoreLayer()
        elseif sIndex == 4 then
            local XingNangLayer = requires("src/fsgl/layer/XingNang/XingNangLayer.lua"):create()
            LayerManager.addLayout(XingNangLayer, { par = self })
        elseif sIndex == 9 then
            ----帮派
            YinDaoMarg:getInstance():guideTouchEnd()
            BangPaiFengZhuangShuJu.createGuildLayer( { parNode = self })
        elseif sIndex == 7 then
            ----神器
            YinDaoMarg:getInstance():guideTouchEnd()
            self:enterArtifact()
        elseif sIndex == 8 then
            self:onEquipSmeltBtn()
            -- 回收
        elseif sIndex == 6 then
            -----修炼
            YinDaoMarg:getInstance():guideTouchEnd()
            XTHD.createBibleLayer(self)
        end
    end

    local menuBtns = self:createMenus(menuInfo, "right")

    local menuBtn = nil
    local x = self:getContentSize().width - 5
    for i = 1, #menuBtns do
        menuBtn = menuBtns[i]
        menuBtn:setAnchorPoint(1, 0)
        menuBtn:setPosition(x, 5)
        menuBtn:setScale(0.8)
        if (i == 1) then
            self.__functionButtons[12] = menuBtn
            -- self:PushBtnToLeftNode(menuBtn)
            menuBtn:setPosition(self:getContentSize().width, 0)
            -- lilian
        elseif (i == 2) then
            -- yingxiong
            self:PushBtnTorightfloorNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getContentSize().width - redDot:getContentSize().width, menuBtn:getContentSize().height - 15)
            redDot:setVisible(false)
            self._heroRedDot = redDot
            self.__functionButtons[11] = menuBtn

            local canRecruit = cc.Sprite:create("res/image/homecity/zhaomu.png")
            menuBtn:addChild(canRecruit)
            canRecruit:setAnchorPoint(0, 0)
            canRecruit:setPosition(0, menuBtn:getBoundingBox().height - 10)
            canRecruit:setVisible(false)
            self._canRecruitTip = canRecruit
            canRecruit:runAction(
            cc.RepeatForever:create(
            cc.Sequence:create(
            cc.MoveBy:create(
            0.6, cc.p(0, 3)
            ),
            cc.MoveBy:create(
            0.6, cc.p(0, -3)
            )
            )
            )
            )
        elseif i == 3 then
            self:PushBtnTorightfloorNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getContentSize().width - redDot:getContentSize().width, menuBtn:getContentSize().height - 15)
            redDot:setVisible(false)
            self._equipRedDot = redDot
            local compose = XTHD.createSprite("res/image/homecity/compose.png")
            menuBtn:addChild(compose)
            compose:setAnchorPoint(0, 0)
            compose:setPosition(0, menuBtn:getBoundingBox().height - 10)
            compose:setVisible(false)
            self._composeRedDot = compose
            compose:runAction(
            cc.RepeatForever:create(
            cc.Sequence:create(
            cc.MoveBy:create(
            0.6, cc.p(0, 3)
            ),
            cc.MoveBy:create(
            0.6, cc.p(0, -3)
            )
            )
            )
            )
            --            local composeLabel = XTHD.createLabel({
            --                text = LANGUAGE_EQUIP_TEXT[20],
            --                fontSize = 16,
            --                color = cc.c3b( 107, 64, 42 ),
            --                pos = cc.p( 36, 38 ),
            --            })
            -- compose:addChild( composeLabel )
            self.__functionButtons[13] = menuBtn
            -- zhuangbei
            -- menuBtn:setPosition(self:getContentSize().width-300,10)
        elseif i == 4 then
            self:PushBtnTorightfloorNode(menuBtn)
            local canopen = XTHD.createSprite("res/image/homecity/canopen.png")
            menuBtn:addChild(canopen)
            canopen:setAnchorPoint(0, 0)
            canopen:setPosition(0, menuBtn:getBoundingBox().height - 10)
            canopen:setVisible(false)
            self._canopenTip = canopen
            canopen:runAction(
            cc.RepeatForever:create(
            cc.Sequence:create(
            cc.MoveBy:create(
            0.6, cc.p(0, 3)
            ),
            cc.MoveBy:create(
            0.6, cc.p(0, -3)
            )
            )
            )
            )
            self.__functionButtons[16] = menuBtn
            -- xingnang
            -- menuBtn:setPosition(cc.p(self:getContentSize().width-320,10))
        elseif i == 5 then
            self:PushBtnTorightfloorNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getContentSize().width - redDot:getContentSize().width, menuBtn:getContentSize().height - 15)
            -- redDot:setVisible(gameUser.getPackageRedPoint()== 1 and true or false)
            redDot:setVisible(false)
            self._packageRedDot = redDot
            self.__functionButtons[15] = menuBtn
            -- shangdian
            -- menuBtn:setPosition(cc.p(self:getContentSize().width-340,10))
        elseif i == 6 then
            -- 修炼
            self:PushBtnTorightfloorNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getContentSize().width - redDot:getContentSize().width, menuBtn:getContentSize().height - 15)
            redDot:setVisible(false)
            self._baodianRedDot = redDot
            self.__functionButtons[17] = menuBtn
            -- xiulian
            -- menuBtn:setPosition(cc.p(self:getContentSize().width-360,10))
        elseif i == 7 then
            self:PushBtnTorightfloorNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getContentSize().width - redDot:getContentSize().width, menuBtn:getContentSize().height - 15)
            -- redDot:setVisible(gameUser.getArtifactRedPoint()== 1 and true or false)
            redDot:setVisible(false)
            self._artifactRedDot = redDot
            self.__functionButtons[19] = menuBtn
            self.shenqiBtn = menuBtn
            -- menuBtn:setPosition(cc.p(self:getContentSize().width-380,10))
        elseif i == 8 then
            ------回收按钮
            self:PushBtnTorightfloorNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getContentSize().width - redDot:getContentSize().width, menuBtn:getContentSize().height - 15)
            redDot:setVisible(false)
            self.hsRedDot = redDot
            self.__functionButtons[21] = menuBtn
            -- huishou
            -- menuBtn:setPosition(cc.p(self:getContentSize().width-400,10))
        elseif i == 9 then
            ----帮派
            self:PushBtnTorightfloorNode(menuBtn)
            self.__functionButtons[22] = menuBtn
            -- bangpai
            -- menuBtn:setPosition(cc.p(self:getContentSize().width-420,10))
        end
        x = x - menuBtn:getContentSize().width - self._padding * 2
        self._bottomBtns[i] = menuBtn
        menuBtn:setVisible(false)
    end
    self:adjustBottomBtns()
end

function ZhuChengMenuLayer:initRightUpMenu()
    -- 任务、城主争霸,排行榜奖励
    local menuInfo = { }
    menuInfo.fileName = { "menu_task", "menu_castallen", "limitTimeBuy", "bosscome", "menu_shouchong", "damaichang", "chaozhiduihuan", "touzijihua", "huoyueyouli_", "bingfenfuli" }
    -- , "investment" ,"menu_rankreward"}--, "menu_help"}
    menuInfo.pos = cc.p(self:getContentSize().width - self._padding * 2, self._padding)
    menuInfo.menuFunction = function(sIndex)
        if (sIndex == 1) then
            self:onTaskBtn()
            -- 主城左下方的任务按钮
        elseif sIndex == 2 then
            -----争霸天下
            local result, _data = isTheFunctionAvailable(15)
            -----功能ID种族
            if result then
                YinDaoMarg:getInstance():guideTouchEnd()
                requires("src/fsgl/layer/ZhongZu/forTheHost/ZhongZuCastellenMain.lua"):create(1)
            else
                XTHDTOAST(_data.tip)
            end
        elseif sIndex == 3 then
            -- 限时购买
            -- 有问题
            XTHD.limitTimeBuyCallback(self, 1, false)
            -- 排行榜奖励按钮
            -- XTHD.createRankListRewardLayer( self )
        elseif sIndex == 4 then
            -- 凶兽来袭
            if mGameUser.getLevel() < 12 then
                XTHDTOAST("12级解锁世界Boss")
                return
            end
            YinDaoMarg:getInstance():guideTouchEnd()
            LayerManager.createModule("src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiLayer.lua", { par = self })
        elseif sIndex == 5 then
            -- 首冲
            local _popLayer = requires("src/fsgl/layer/HuoDong/ShouCiChongZhiNewLayer.lua"):create()
            if _popLayer ~= nil then
                cc.Director:getInstance():getRunningScene():addChild(_popLayer)
				_popLayer:setName("Poplayer")
            end
        elseif sIndex == 6 then
            -- 大卖场
            self:createHyperShop()
        elseif sIndex == 7 then
            self:ChaozhiduihuanActivityLayer()
        elseif sIndex == 8 then
            self:TouzijihuaActivityLayer()
        elseif sIndex == 9 then
            self:HuoyueyouliActivityLayer()
        elseif sIndex == 10 then
            self:Bingfenfuli()
        end
    end

    local menuBtns = self:createMenus(menuInfo, "right")
    local menuBtn = nil
    local x = self:getContentSize().width - 18
    local y = self:getContentSize().height - 200
    for i = 1, #menuBtns do
        menuBtn = menuBtns[i]
        menuBtn:setAnchorPoint(1, 0)
        menuBtn:setPosition(x, y)
        menuBtn:setScale(0.6)
        if (i == 1) then
            menuBtn:setAnchorPoint(0, 0)
            self:PushBtnToRightNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getContentSize().width - redDot:getContentSize().width, menuBtn:getContentSize().height - 15)
            redDot:setVisible(false)
            self._taskRedDot = redDot
            local recTip = cc.Sprite:create("res/image/homecity/canrec.png")
            menuBtn:addChild(recTip)
            recTip:setPosition(0,menuBtn:getContentSize().height - 15)
            recTip:runAction(cc.RepeatForever:create(
	            cc.Sequence:create(
	            cc.ScaleTo:create(0.5, 1.2),
	            cc.ScaleTo:create(0.5, 1)
            )
            ))
            self.recTip = recTip
            self.__functionButtons[10] = menuBtn
            -- 任务按钮位置
        elseif i == 2 then
            menuBtn:setAnchorPoint(0, 0)
            self.duoquanBtn = menuBtn
            self:PushBtnToRightNode(menuBtn)
            self._leftupBtns[12] = { x = menuBtn:getPositionX() -5, y = menuBtn:getPositionY(), targ = menuBtn, isActivity = true }
        elseif i == 3 then
            -- 限时购买
            self:PushBtnToLeftTopNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height)
            redDot:setVisible(true)
            self._limitTimeRedDot = redDot
            self.__functionButtons[18] = menuBtn
            self._leftupBtns[13] = { x = menuBtn:getPositionX() -5, y = menuBtn:getPositionY(), targ = menuBtn, isActivity = true }
        elseif i == 4 then
            menuBtn:setScale(1)
            menuBtn:setName("bosscome")
            self.bossBtn = menuBtn
            self:PushBtnToCeilNode(menuBtn)
        elseif i == 5 then
            -- 首冲
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self._shouchongRedDot = redDot
            self.__functionButtons[26] = menuBtn
            self._leftupBtns[14] = { x = menuBtn:getPositionX() -5, y = menuBtn:getPositionY(), targ = menuBtn, isActivity = true }
        elseif i == 6 then
            self.__functionButtons[33] = menuBtn
            self:PushBtnToCeilNode(menuBtn)
            self._leftupBtns[15] = { x = menuBtn:getPositionX() -5, y = menuBtn:getPositionY(), targ = menuBtn, isActivity = true }
        elseif i == 7 then
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.czdhRedDot = redDot
            self.__functionButtons[34] = menuBtn
            self._leftupBtns[16] = { x = menuBtn:getPositionX() -5, y = menuBtn:getPositionY(), targ = menuBtn, isActivity = true }
        elseif i == 8 then
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.tzjhRedDot = redDot
            self.__functionButtons[35] = menuBtn
            self._leftupBtns[17] = { x = menuBtn:getPositionX() -5, y = menuBtn:getPositionY(), targ = menuBtn, isActivity = true }
        elseif i == 9 then
            self:PushBtnToCeilNode(menuBtn)
            self.__functionButtons[36] = menuBtn
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.hyylRedDot = redDot
            self._leftupBtns[18] = { x = menuBtn:getPositionX() -5, y = menuBtn:getPositionY(), targ = menuBtn, isActivity = true }
        elseif i == 10 then
            self:PushBtnToLeftTopNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.bfflRedDot = redDot
            self.__functionButtons[42] = menuBtn
            self._leftupBtns[19] = { x = menuBtn:getPositionX() -5, y = menuBtn:getPositionY(), targ = menuBtn, isActivity = true }
        end
        -- if i ~= 1 and i ~= 10 then
        -- 	if self._leftupBtns[10+i].isActivity == true then
        -- 		y = y - menuBtn:getContentSize().height
        -- 	end
        -- end
    end
end

function ZhuChengMenuLayer:initLeftUpMenu()
    -- 活动，七天，开服礼包,排行榜,顶部的菜单栏按钮
    local menuInfo = { }
    menuInfo.fileName = { "menu_dailyWelfare", "menu_sevenDay", "menu_activityNew", "menu_activityNewYear", "menu_nian", "menu_timehero", "menu_activityDaily", "menu_biye", "luckylunpan", "supermaket", "QuanMingChongBang", "Zhanlijingsai", "quanmingjingji", "newlogin", "monthcard", "online" }
    menuInfo.menuFunction = function(sIndex)
        LayerManager.addShieldLayout()
        if (sIndex == 1) then
            ------每日福利
            requires("src/fsgl/layer/HuoDong/HuoDongLayer.lua"):createWithTab(1)
        elseif (sIndex == 2) then
            --- 开服狂欢
            -- requires("src/fsgl/layer/HuoDong/QIRiKuangHuang.lua"):create(self)
            self:Qirikuanghuan()
        elseif (sIndex == 3) then
            --- 精彩活动
            requires("src/fsgl/layer/HuoDong/JingCaiHuoDongRecLayer.lua"):createWithTab(1)
        elseif (sIndex == 4) then
            -----节日狂欢
            self:JieRiAnctivityLayer()
        elseif sIndex == 5 then
            ------年兽
            -- requires("src/fsgl/layer/HuoDong/XianShiTiaoZhanLayer.lua"):create()
        elseif sIndex == 6 then
            ------限时英雄
            self:TimelimitAnctivityLayer()
            -- XTHD.timeHeroListCallback(self)
        elseif sIndex == 7 then
            -----日常活动
            self:openRCHD()
        elseif sIndex == 8 then
            -- 正式服是毕业典礼，简玩是无限商城
            self:openBYDL()
        elseif sIndex == 9 then
            -- 幸运转盘
            self:openXYZP()
        elseif sIndex == 10 then
            -- 限时商城
            local _store = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create( { which = 'groupBuy' })
            LayerManager.addLayout(_store)
        elseif sIndex == 11 then
            self:QuanfuchongbangActivityLayer()
        elseif sIndex == 12 then
            self:ZhanlijingsaiActivityLayer()
        elseif sIndex == 13 then
            self:QuanmingjingjiActivityLayer()
        elseif sIndex == 14 then
            self:openNewLoginReward()
        elseif sIndex == 15 then
            self:openMonthCard()
        elseif sIndex == 16 then
            requires("src/fsgl/layer/HuoDong/HuoDongLayer.lua"):createWithTab(4)
        end
    end

    local menuBtns = self:createMenus(menuInfo)
    local menuBtn = nil
    print("================>>>>>>>>", #menuBtns)
    local _index = 0
    for i = 1, #menuBtns do
        menuBtn = menuBtns[i]
        menuBtn:setAnchorPoint(1, 0)
        menuBtn:setScale(0.6)
        if i == 1 then
            --- 每日福利
            self:PushBtnToLeftTopNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(true)
            self._everyDayRedDot = redDot
        elseif i == 2 then
            --- 开服狂欢
            self:PushBtnToLeftTopNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self._serverDayRedDot = redDot
            self.__functionButtons[20] = menuBtn
        elseif i == 3 then
            -- 精彩活动
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self._wonderfulactivityRedDot = redDot
        elseif i == 4 then
            -- 节日狂欢
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.jierikuanghuanRedDot = redDot
            self.__functionButtons[23] = menuBtn
        elseif i == 5 then
            -- 限时挑战
            self:PushBtnToCeilNode(menuBtn)
            menuBtn:removeFromParent()
            -- menuBtn:setVisible(false)
            -- self.__functionButtons[24] = menuBtn
        elseif i == 6 then
            -- 限时英雄
            self:PushBtnToCeilNode(menuBtn)
            self.__functionButtons[29] = menuBtn
        elseif i == 7 then
            -- 日常活动
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self._richangactivityRedDot = redDot
            self.__functionButtons[25] = menuBtn
        elseif i == 8 then
            -- 毕业典礼要加小红点
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width, menuBtn:getBoundingBox().height - 10)
            redDot:setVisible(false)
            menuBtn:setVisible(false)
            self.biyedianliRedDot = redDot
            self.__functionButtons[27] = menuBtn
        elseif i == 9 then
            self:PushBtnToCeilNode(menuBtn)
            self.__functionButtons[28] = menuBtn
        elseif i == 10 then
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.limittimeshopRedDot = redDot
            self.__functionButtons[30] = menuBtn
        elseif i == 11 then
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.__functionButtons[32] = menuBtn
        elseif i == 12 then
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.__functionButtons[40] = menuBtn
            self._zljsRedDot = redDot
        elseif i == 13 then
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.__functionButtons[41] = menuBtn
            self._qmjjRedDot = redDot
        elseif i == 14 then
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.__functionButtons[37] = menuBtn
            self.newloginrewardDot = redDot
        elseif i == 15 then
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.__functionButtons[38] = menuBtn
            self.monthcardRedDot = redDot
        elseif i == 16 then
            self:PushBtnToCeilNode(menuBtn)
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            menuBtn:addChild(redDot)
            redDot:setPosition(menuBtn:getBoundingBox().width + 15, menuBtn:getBoundingBox().height + 10)
            redDot:setVisible(false)
            self.__functionButtons[39] = menuBtn
            self.onlinerewardRedDot = redDot
            self.Time = XTHDLabel:create("", 20, "res/fonts/def.ttf")
            self.Time:setColor(cc.c3b(255, 246, 127))
            menuBtn:addChild(self.Time)
            self.Time:setPosition(menuBtn:getContentSize().width / 2, -10)
            XTHD.addEventListener( {
                name = CUSTOM_EVENT.REFRESH_ONLINEREWARD,
                callback = function(event)
                    HttpRequestWithOutParams("timeRewardRecord", function(data)
                        -- print("在线奖励服务器返回的数据为：")
                        -- print_r(data)
                        self.closeTime = data.surplusTime
                        self:updateOnlineTime()
                    end )
                end
            } )
            XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_ONLINEREWARD })
        end
        self._leftupBtns[i] = { x = menuBtn:getPositionX(), y = menuBtn:getPositionY(), targ = menuBtn, isActivity = true }
    end
end

function ZhuChengMenuLayer:createMenus(menuInfo, which, parent)
    local fileName = menuInfo.fileName
    local menuFunction = menuInfo.menuFunction

    local useFileName = { "res/image/homecity/", "", 1, ".png" }
    local normalName, selectName, menuBtn
    local pMenuBtns = { }

    for i = 1, #fileName do
        if fileName[i] == "zyzh" and gameUser.getRecoveryState() == 0 then
            break
        end
        if fileName[i] ~= "" then
            useFileName[2] = fileName[i]
            useFileName[3] = 1
            normalName = table.concat(useFileName)
            useFileName[3] = 2
            selectName = table.concat(useFileName)
        else
            normalName = nil
            selectName = nil
        end
        menuBtn = XTHDPushButton:createWithFile( {
            normalNode = normalName,
            selectedNode = selectName,
            musicFile = XTHD.resource.music.effect_btn_common,
            endCallback = function(...)
                self:getParent():cleanOperatorBtns()
                if (menuFunction) then
                    menuFunction(i)
                end
            end,
        } )

        menuBtn:setSwallowTouches(true)
        parent = parent or self
        parent:addChild(menuBtn)
        table.insert(pMenuBtns, menuBtn)
    end
    return pMenuBtns
end

function ZhuChengMenuLayer:onEnter()
    -- if gameUser.getOSPackageTimes() == 1 then -----1表示领取完 0 表示没有领取完
    --     self:updateActivityButtonPos(1,false)
    -- else
    --     -- self:updateActivityButtonPos(1,true)
    --     self:updateActivityButtonPos(1,false)
    --     self:adjustLeftUpMenu()
    --     -- self:runLiuCunAction(true)
    --     self:runLiuCunAction(false)
    -- end
    isLoginFlag = false
    print("-----------进入主城界面加载引导数据：----------")
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        self:setKeypadEnabled(true)
        self:registerScriptKeypadHandler( function(callback)
            if callback == "backClicked" then
                print("返回按钮监听")
                if XTHD.isEmbeddedSdk() == true then
                    XTHD.gameBack()
                end
            elseif callback == "menuClicked" then
                --            print("菜单监听")
            end
        end )
    end

    -- self:addGuide()
end

function ZhuChengMenuLayer:onExit()
    YinDaoMarg:getInstance():removeCover(self)
end

function ZhuChengMenuLayer:onCleanup()
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_NEWFUNCTIONOPEN_TIP)
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_ONLINEREWARD)
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_PLAYERPOWER)
end
------自适应底部的功能按钮们的位置 
function ZhuChengMenuLayer:adjustBottomBtns()
    -----为1的是默认开启的
    local _funcID = { 1, 1, 20, 31, 31, 81, 24, 29, 72 }
    -------历练、英雄、装备、行囊、商店、宝典、神器、回收,帮派
    if #self._bottomBtns > 0 and self.needScaleBtn then
        local x, y = self:getContentSize().width - 10, 5
        local _level = gameUser.getLevel()
        local _block = gameUser.getInstancingId()
        for k, v in pairs(self._bottomBtns) do
            local _tempData = gameData.getDataFromCSV("FunctionInfoList", { id = _funcID[k] })
            if _tempData then
                if (_tempData.unlocktype == 1 and _level >= _tempData.unlockparam) or(_tempData.unlocktype == 2 and _block >= _tempData.unlockparam) then
                    ------按等级开启
                    v:setVisible(true)
                    -- v:setPosition(x,y)
                    -- 调整底部按钮的间距
                    if k == 1 then
                        x = x - v:getBoundingBox().width - self._padding * 2 - 45
                    else
                        x = x - v:getBoundingBox().width - self._padding * 2 + 25
                    end
                else
                    v:setVisible(false)
                end
            end
        end
    end
end

--------------------------------------与主城对接方法--------------------------------------
-- 用来刷新等级、经验，银两，银币信息
function ZhuChengMenuLayer:refreshTopInfo()
    -- CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO
    print("--------------------刷新主城等级、经验，银两，银币------------------")

    local current_percent = tonumber(mGameUser.getExpNow()) / tonumber(mGameUser.getExpMax()) * 100
    self.expText:setString(mGameUser.getExpNow() .. "/" .. mGameUser.getExpMax())
    self._exp_progress_timer:setPercentage(current_percent)
    self._nick_name_label:setString(mGameUser.getNickname())
    self.campIcon:initWithFile("res/image/homecity/camp_icon" .. mGameUser.getCampID() .. ".png")
    self._level_label:setString(mGameUser.getLevel())

    if self._propertyLable and #self._propertyLable > 3 then
        local base = 1000000

        if mGameUser.getTiliNow() > mGameUser.getPreTiliNow() then
            letTheLableTint(self._propertyLable[1], true)
        elseif mGameUser.getTiliNow() < mGameUser.getPreTiliNow() then
            letTheLableTint(self._propertyLable[1], false)
        end
        mGameUser.setPreTiliNow(mGameUser.getTiliNow())
        self._propertyLable[1]:setString(tostring(mGameUser.getTiliNow()) .. "/" .. tostring(mGameUser.getTiliMax()))
        --- 体力

        if mGameUser.getGold() > mGameUser.getPreGold() then
            letTheLableTint(self._propertyLable[2], true)
        elseif mGameUser.getGold() < mGameUser.getPreGold() then
            letTheLableTint(self._propertyLable[2], false)
        end
        mGameUser.setPreGold(mGameUser.getGold())
        self._propertyLable[2]:setString(getHugeNumberWithLongNumber(mGameUser.getGold(), base))
        -- 银两

        if mGameUser.getFeicui() > mGameUser.getPreFeicui() then
            letTheLableTint(self._propertyLable[3], true)
        elseif mGameUser.getFeicui() < mGameUser.getPreFeicui() then
            letTheLableTint(self._propertyLable[3], false)
        end
        mGameUser.setPreFeicui(mGameUser.getFeicui())
        self._propertyLable[3]:setString(getHugeNumberWithLongNumber(mGameUser.getFeicui(), base))
        -- 翡翠

        if mGameUser.getIngot() > mGameUser.getPreIngot() then
            letTheLableTint(self._propertyLable[4], true)
        elseif mGameUser.getIngot() < mGameUser.getPreIngot() then
            letTheLableTint(self._propertyLable[4], false)
        end
        mGameUser.setPreIngot(mGameUser.getIngot())
        self._propertyLable[4]:setString(getHugeNumberWithLongNumber(mGameUser.getIngot(), base))
        -- 元宝
    end
    -- vip
    if self._vip_num_sp then
        -- 在这里加个判断，然后将数字换成文字
        self._vip_num_sp:setString(VIPLABEL[tonumber(mGameUser.getVip()) + 1])
    end
end

--用来刷新主城按钮的状态
function ZhuChengMenuLayer:refreshBaseInfo()
    -- CUSTOM_EVENT.REFRESH_MAINCITY_INFO
    print("--------------------刷新主城按钮状态和信息------------------")

    self:adjustLeftUpMenu()

    if self.needScaleBtn then
        -- 新年活动按钮
        local activityOpenStatus = gameUser.getActivityOpenStatus() or { }
        local newYearActivityId = {
            8,-- 抽奖
        }
        self._leftupBtns[4].isActivity = false
        self.__functionButtons[23]:setVisible(false)
--        self.jierikuanghuanRedDot:setVisible(false)
        for i, v in ipairs(newYearActivityId) do
            if activityOpenStatus[tostring(v)] == 1 then
--                self.jierikuanghuanRedDot:setVisible(RedPointState[1].state == 1)
                self._leftupBtns[4].isActivity = true
                self.__functionButtons[23]:setVisible(true)
                break
            end
        end

        self.__functionButtons[20]:setVisible(activityOpenStatus["3"] == 1)
        self._leftupBtns[2].isActivity = activityOpenStatus["3"] == 1
        -- 活动激活状态

        -----年兽按钮
        -- self.__functionButtons[24]:setVisible(false)--(activityOpenStatus["7"] == 1)
        -- 争霸天下
        self._leftupBtns[5].isActivity = activityOpenStatus["7"] == 1
        -----挑战元霸按钮
        self._leftupBtns[12].isActivity = true
        -- 活动激活状态

        -- 日常活动按钮
        local activityOpenStatus = gameUser.getActivityOpenStatus() or { }
        -- print("服务器控制活动的开关表为：")
        -- print_r(activityOpenStatus)
        local dailyActivityId = {
            12,-- 充值返利
            13,-- 消费返利
            14,-- 切石返利
            15,-- 群英返利
            16,-- 神兵返利
            17,-- 神器返利
            18,-- 登录有礼
        }

        -- 日常活动
        self._leftupBtns[7].isActivity = false
        -- print("日常活动小红点状态："..tostring(gameUser.getRCHDRedState()))
        self.__functionButtons[25]:setVisible(false)
        for i, v in ipairs(dailyActivityId) do
            if activityOpenStatus[tostring(v)] == 1 then
                self.__functionButtons[25]:setVisible(false)
                self._leftupBtns[7].isActivity = true
                break
            end
        end
        ---- 限时礼包
        self.__functionButtons[18]:setVisible(activityOpenStatus["19"] == 1)
        self._leftupBtns[13].isActivity = activityOpenStatus["19"] == 1

        ---- 首冲
        local _isvible = false
        if #gameUser.getThreeTimePayList() >= 1 or #gameUser.getFinishThreePayRewardList() < 3 then
            _isvible = true
        end
        self.__functionButtons[26]:setVisible(_isvible)
        if gameUser.getFirstPayState() == 2 then
            self._leftupBtns[14].isActivity = false
        end

--        if self._leftupBtns[1] then
--            --- 每日福利
--            -- local _visible = mGameUser.getLoginRewardState() > 0
--            self._leftupBtns[1].isActivity = true
--            RedPointState[4].state = gameUser.getDailyPointDot()
--            self._everyDayRedDot:setVisible(RedPointState[4].state == 1)
--        end
        if self._leftupBtns[6] then
            --- 限时英雄
            local isvisible = false
            if activityOpenStatus["7"] == 1 or activityOpenStatus["11"] == 1 then
                isvisible = true
            end
            self._heroRedDot:setVisible(activityOpenStatus["11"] == 1)
            self.__functionButtons[29]:setVisible(isvisible)
            self._leftupBtns[6].isActivity = activityOpenStatus["11"] == 1
        end

--        if self._leftupBtns[3] then
--            --- 精彩活动
--            local status = mGameUser.getWonderfulPointDot()
--            RedPointState[2].state = status
--            if status == 1 then
--                self._wonderfulactivityRedDot:setVisible(true)
--            else
--                self._wonderfulactivityRedDot:setVisible(false)
--            end
--        end

        if self._leftupBtns[8] then
            -- 毕业典礼
            -- gameUser.getBYDLRedState()
            self._leftupBtns[8].isActivity = false
            -- gameUser.getGragraduationState() == 1
            self.__functionButtons[27]:setVisible(false)
        end

        if self._leftupBtns[9] then
            -- 幸运转盘开启状态还需要修改，在服务器返回的activityState中获取，活动ID是20
            self._leftupBtns[9].isActivity = activityOpenStatus["20"] == 1
            self.__functionButtons[28]:setVisible(activityOpenStatus["20"] == 1)
        end

        if self._leftupBtns[10] then
            -- 限时商城
            self._leftupBtns[10].isActivity = gameUser.getLimitTimeShopState() == 1
            self.__functionButtons[30]:setVisible(gameUser.getLimitTimeShopState() == 1)
        end

        -- 新投资计划
        if self._leftupBtns[17] then
            self._leftupBtns[17].isActivity = activityOpenStatus["40"] == 1
			self.__functionButtons[35]:setVisible(false)
            --self.__functionButtons[35]:setVisible(activityOpenStatus["40"] == 1)
        end

        -- 活跃有礼
        if self._leftupBtns[18] then
            self._leftupBtns[18].isActivity = activityOpenStatus["42"] == 1
            self.__functionButtons[36]:setVisible(activityOpenStatus["42"] == 1)
        end

        -- 超值兑换
        if self._leftupBtns[16] then
            self._leftupBtns[16].isActivity =(activityOpenStatus["44"] == 1 or activityOpenStatus["43"] == 1)
			self.__functionButtons[34]:setVisible(false)
            --self.__functionButtons[34]:setVisible(activityOpenStatus["44"] == 1 or activityOpenStatus["43"] == 1)
        end

        -- 大卖场
        if self._leftupBtns[15] then
            self._leftupBtns[15].isActivity = activityOpenStatus["47"] == 1
            self.__functionButtons[33]:setVisible(activityOpenStatus["47"] == 1)
        end

        if self.__functionButtons[37] then
            self.__functionButtons[37]:setVisible(gameUser.getLeijidengluState() == 1)
        end

        -- 全服冲榜
        if self.__functionButtons[32] then
            self.__functionButtons[32]:setVisible(gameUser.getQMCBOpenState() == 1)
        end

        -- 战力竞赛
        if self.__functionButtons[40] then
            self.__functionButtons[40]:setVisible(gameUser.getZLJSOpenState() == 1)
        end

        -- 全民竞技
        if self.__functionButtons[41] then
            self.__functionButtons[41]:setVisible(gameUser.getQMJJOpenState() == 1)
        end

        self.scaleBtn:setRotation(0)

    end

    if self.__functionButtons[31] then
        -- 修仙圣境
        self.__functionButtons[31]:setVisible(gameUser.getLevel() >= 40)
    end

    if self.__functionButtons[66] then
        -- 资源找回
        -- print("++++++++++++++++++++++++++++++++++>>>+",gameUser.getRecoveryState())
        self.__functionButtons[66]:setVisible(gameUser.getRecoveryState() == 1)
    end

--    if self._friendRedDot then
--        if HaoYouPublic.haveMsgs() then
--            -----好友
--            self._friendRedDot:setVisible(true)
--        else
--            self._friendRedDot:setVisible(false)
--        end
--    end
--    if self._taskRedDot then
--        if mGameUser.getTaskGettingState() > 0 then
--            --- 任务
--            self._taskRedDot:setVisible(true)
--            if self.recTip then
--            	self.recTip:setVisible(true)
--            end
--        else
--            self._taskRedDot:setVisible(false)
--            if self.recTip then
--            	self.recTip:setVisible(false)
--            end
--        end
--    end

    -- self:adjustLeftUpMenu()
    self:refreshCeilNodeBtnPos()
    self:refreshRightNodeBtnPos()
    self:refreshRightFloorBtnPos()
    self:refreshLeftTopNodePos()
    self:refreshLeftFloorNodePos()
end

----创建新目标提示
function ZhuChengMenuLayer:createNewTargetTip()
    if not self._newFunctionBoard then
        local _bg = XTHDPushButton:createWithParams( {
            musicFile = XTHD.resource.music.effect_btn_common,
        } )
        self:addChild(_bg)
        _bg:setScale(0.7)
        _bg:setTouchSize(cc.size(280, 90))
        _bg:setContentSize(cc.size(280, 90))
        local _tempTarg = self._cd_label:getParent()
        _bg:setAnchorPoint(0.5, 1)
        local _posX = 12
        if screenRadio > 1.8 then
            _posX = 45
        end
        -- _bg:setPosition(100,15)
        _bg:setTouchBeganCallback( function()
            _bg:setScale(0.7)
        end )
        _bg:setTouchMovedCallback( function()
            _bg:setScale(0.7)
        end )
        _bg:setTouchEndedCallback( function()
            ----前往副本
            _bg:setScale(0.8)
            replaceLayer( { id = 1 })
        end )
        ----特效
        -- local blink = cc.Animation:createWithSpriteFrames(self._animateFrames.newGold,16/130)
        -- blink = cc.Animate:create(blink)
        -- local target = cc.Sprite:create()
        -- _bg:addChild(target)
        -- target:setAnchorPoint(0.5,0.5)
        -- --修改新目标位置
        -- --ly3.16
        -- target:setScale(0.9)
        -- target:setPosition(_bg:getTouchSize().width / 2+20,_bg:getContentSize().height / 2-10)
        -- target:runAction(cc.RepeatForever:create(blink))
        local xinmubiaoSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/newgoal/xinmubiao.json", "res/image/homecity/frames/newgoal/xinmubiao.atlas", 1.0)
        xinmubiaoSpine:setAnimation(0, "xinmubiao", true)
        xinmubiaoSpine:setPosition(_bg:getTouchSize().width / 2 + 30, _bg:getContentSize().height / 2 - 10)
        xinmubiaoSpine:setScale(0.9)
        _bg:addChild(xinmubiaoSpine)

        self._newFunctionBoard = _bg
        self._newFunctionBoard:setName("newTarget")
        self:PushBtnToLeftNode(self._newFunctionBoard)
    end

    if FunctionYinDao.funcDatas then
        local stageID = mGameUser.getInstancingId() + 1
        local _level = gameUser.getLevel() + 1
        local _maxBlockLimit = FunctionYinDao.funcDatas.maxBlock
        local _maxLevelLimit = FunctionYinDao.funcDatas.maxLevel
        if stageID < _maxBlockLimit or _level < _maxLevelLimit then
            ----如果新功能还没有提示完
            local _word = nil
            repeat
                _word = FunctionYinDao.funcDatas.blockData[stageID]
                local _tem = FunctionYinDao.funcDatas.levelData[_level]
                if (_word and _tem) and(_word.id > _tem.id) then
                    _word = _tem
                else
                    _word =(not _word) and _tem or _word
                end
                if not _word then
                    stageID = stageID + 1
                    _level = _level + 1
                    if stageID > _maxBlockLimit and _level > _maxLevelLimit then
                        self._newFunctionBoard:removeFromParent()
                        self._newFunctionBoard = nil
                        break
                    end
                else
                    local str = string.gsub(_word.info1, "*", "\n")
                    if not self._newFunctionBoard.condition then
                        -- ly3.16等级达到……
                        -- local _cond = XTHDLabel:createWithSystemFont(str,XTHD.SystemFont,16)
                        local _cond = XTHDLabel:create(str, 22, "res/fonts/def.ttf")
                        _cond:setColor(cc.c3b(252, 231, 204))

                        self._newFunctionBoard:addChild(_cond)
                        _cond:enableShadow(cc.c4b(252, 231, 204, 255), cc.size(1, 0), 2)
                        _cond:enableOutline(cc.c4b(0, 0, 0, 255), 1)
                        _cond:setAnchorPoint(0, 0.5)
                        _cond:setPosition(90, self._newFunctionBoard:getContentSize().height / 2 - 10)
                        self._newFunctionBoard.condition = _cond
                    else
                        self._newFunctionBoard.condition:setString(str)
                    end
                    local funcName = _word.info2
                    -- ly3.16新目标名称
                    if not self._newFunctionBoard.functionName then
                        -- local _name = XTHDLabel:createWithSystemFont(funcName,XTHD.SystemFont,20)
                        local _name = XTHDLabel:create(funcName, 24, "res/fonts/def.ttf")
                        _name:setColor(cc.c3b(255, 166, 62))

                        self._newFunctionBoard:addChild(_name)
                        _name:enableShadow(cc.c4b(252, 220, 5, 255), cc.size(1, 0))
                        _name:enableOutline(cc.c4b(0, 0, 0, 255), 1)
                        _name:setAnchorPoint(0, 0.5)
                        _name:setPosition(self._newFunctionBoard.condition:getPositionX() + 45, self._newFunctionBoard:getContentSize().height / 2 - _name:getContentSize().height / 2 + 2 - 10)
                        self._newFunctionBoard.functionName = _name
                    else
                        self._newFunctionBoard.functionName:setString(funcName)
                    end
                    break
                end
            until false
        else
            self._newFunctionBoard:removeFromParent()
            self._newFunctionBoard = nil
        end
    end
end

-- 显示按钮上的特效
function ZhuChengMenuLayer:displayMenuEffect(sSpriteFrames, sTag)
    self._animateFrames = sSpriteFrames
    self._Tags = sTag

    --- 战斗按钮上的特效
    local _effect = cc.Animation:createWithSpriteFrames(self._animateFrames.fightBtnA, 7 / 60)
    _effect = cc.Animate:create(_effect)
    _effect = cc.RepeatForever:create(cc.Sequence:create(_effect, cc.DelayTime:create(3)))
    if self.__functionButtons[12] and not self.__functionButtons[12]:getChildByTag(self._Tags.ktag_actionFightA) then
        -- target = cc.Sprite:create()
        -- target:runAction(_effect)
        -- target:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
        -- self.__functionButtons[12]:addChild(target,1,self._Tags.ktag_actionFightA)
        -- target:setPosition(self.__functionButtons[12]:getContentSize().width / 2,self.__functionButtons[12]:getContentSize().height / 2)
        -- 特效ly4.9
        local tex = sp.SkeletonAnimation:create("res/image/homecity/frames/fightBtnA/lilian.json", "res/image/homecity/frames/fightBtnA/lilian.atlas", 1.0)
        tex:setAnimation(0, "lilian", true)
        tex:setPosition(self.__functionButtons[12]:getContentSize().width / 2 + 5, self.__functionButtons[12]:getContentSize().height / 2 + 5)
        self.__functionButtons[12]:addChild(tex)
    end
    _effect = cc.Animation:createWithSpriteFrames(self._animateFrames.fightBtnB, 7 / 60)
    _effect = cc.Animate:create(_effect)
    _effect = cc.RepeatForever:create(cc.Sequence:create(_effect, cc.DelayTime:create(3)))
    if self.__functionButtons[8] and not self.__functionButtons[8]:getChildByTag(self._Tags.ktag_actionFightB) then
        -- target = cc.Sprite:create()
        -- target:runAction(_effect)
        -- target:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
        -- self.__functionButtons[8]:addChild(target,1,self._Tags.ktag_actionFightB)
        -- target:setPosition(self.__functionButtons[8]:getContentSize().width / 2,self.__functionButtons[8]:getContentSize().height / 2)

        -- 特效ly4.9
        local tex = sp.SkeletonAnimation:create("res/image/homecity/frames/fightBtnB/jingji.json", "res/image/homecity/frames/fightBtnB/jingji.atlas", 1.0)
        tex:setAnimation(0, "jingji", true)
        tex:setPosition(self.__functionButtons[8]:getContentSize().width / 2 + 15, self.__functionButtons[8]:getContentSize().height / 2 + 5)
        self.__functionButtons[8]:addChild(tex)
    end
    ------任务按钮上的特效
    _spine = sp.SkeletonAnimation:create("res/image/homecity/frames/spine/zg.json", "res/image/homecity/frames/spine/zg.atlas", 1.0)
    -- 0----任务、活动特效
    _parent = self.__functionButtons[10]:getParent()
    _target = self.__functionButtons[10]
    if _target and not self._taskRedDot then
        _spine:setAnimation(0, "animation", true)
        -- 任务特效转圈
        -- _parent:addChild(_spine,_target:getLocalZOrder() - 1)
        self.darkBG:addChild(_spine, self.darkBG:getLocalZOrder() + 1)
        _spine:setPosition(_target:getPositionX() - _target:getBoundingBox().width / 2 + 30, _target:getPositionY() + _target:getBoundingBox().height / 2 + 15)
        self._taskRedDot = _spine
    end
end 

-- 刷新部分menu的红点提示
function ZhuChengMenuLayer:freshRedPoints(event)
    -- CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT
    -- if gameUser.getLevel() == 7 and gameUser.getFirstLayerState() == 0 then
    -- 	if not self:getChildByName("shouchong") then
    -- 		local _popLayer = requires("src/fsgl/layer/HuoDong/ShouCiChongZhiNewLayer.lua"):create()
    -- 		self:addChild(_popLayer,10)
    -- 		_popLayer:setName("shouchong")
    -- 	end	
    -- end
    print("--------------------主城小红点------------------" .. event.data.name)
    if (not event) then
        return false
    end
    local isGet = true
    if event.data.name == "sevenDay" then
        -- 开服狂欢
        if self._serverDayRedDot then
            if gameUser.getSevenDayRedPoint() == -1 then
                self._leftupBtns[2].isActivity = false
                self._serverDayRedDot:setVisible(false)
            elseif gameUser.getSevenDayRedPoint() == 1 then
                self._leftupBtns[2].isActivity = true
                self._serverDayRedDot:setVisible(true)
            else
                self._leftupBtns[2].isActivity = true
                self._serverDayRedDot:setVisible(false)
            end
        end
    elseif event.data.name == "hero" then
        -- 英雄
        if self._canRecruitTip then
            self._canRecruitTip:setVisible(self:refreshHeroBtnTishi())
        end
        if self._heroRedDot then
            self._heroRedDot:setVisible(RedPointState[12].state == 1)
        end
    elseif event.data.name == "equip" then
        -- 装备
        -- 合成红点
        local composeFlag = RedPointManage:getEquipComposeRedPointState()
        if self._equipRedDot then
            local _visible = composeFlag or RedPointManage:getEquipRedPointState()
            self._equipRedDot:setVisible(_visible)
        end
        if self._composeRedDot then
            local _visible = composeFlag and gameUser:getLevel() <= 30
            self._composeRedDot:setVisible(_visible)
        end
    elseif event.data.name == "bag" then
        -- 背包
        if self._canopenTip then
--            local flag = XTHD.checkBagOpenTip()
            self._canopenTip:setVisible(RedPointState[29].state == 1)
        end
    elseif event.data.name == "task" then
        -- 任务
        if self._taskRedDot then
            self._taskRedDot:setVisible(event.data.visible)
            self.recTip:setVisible(event.data.visible)
        end
        if event.data.visible == false then
            mGameUser.setTaskGettinState(0)
        end
    elseif event.data.name == "baodian" then
        -- 修炼
        if self._baodianRedDot then
            local flag
            if event.data.visible == 0 then
                flag = false
            else
                flag = true
            end
            self._baodianRedDot:setVisible(false)
        end
    elseif event.data.name == "activity" then
        --- 每日福利
        if self._leftupBtns[1] then
            self._leftupBtns[1].isActivity = true
            self._everyDayRedDot:setVisible(RedPointState[4].state == 1)
        end
        if event.data.visible == false then
            mGameUser.setLoginRewardState(0)
        end
        self:adjustLeftUpMenu()
    elseif event.data.name == "vip" then
        -- vip
        if self._vipRedDot then
            self._vipRedDot:setVisible(event.data.visible)
        end
        if event.data.visible == false then
            gameUser._vipRewardStatu = 0
        end
    elseif event.data.name == "friend" then
        -- 好友
        if self._friendRedDot then
            self._friendRedDot:setVisible(event.data.visible)
        end
        -- elseif event.data.name == "package" then  --商城
        --     if self._packageRedDot then
        --         self._packageRedDot:setVisible(event.data.visible)
        --     end
        -- elseif event.data.name == "limitTime" then  --限购礼包
        --     if self._limitTimeRedDot then
        --         self._limitTimeRedDot:setVisible(event.data.visible)
        --     end
        -- elseif event.data.name == "shouchong" then  --首充
        --     if self._shouchongRedDot then
        --         self._shouchongRedDot:setVisible(event.data.visible)
        --     end
        -- elseif event.data.name == "touziPlan" then  --投资计划，放到了精彩活动里
        --     if self._touziPlanRedDot then
        --         self._touziPlanRedDot:setVisible(event.data.visible)
        --     end
    elseif event.data.name == "hs" then
        -- 回收
        if self.hsRedDot then
            self.hsRedDot:setVisible(RedPointState[14].state == 1)
        end
    elseif event.data.name == "artifact" then
        -- 神器
        if self._artifactRedDot then
            self._artifactRedDot:setVisible(event.data.visible)
        end
    elseif event.data.name == "jchd" then
        -- 精彩活动
        if self._wonderfulactivityRedDot then
            self._wonderfulactivityRedDot:setVisible(RedPointState[2].state == 1)
        end
    elseif event.data.name == "bydl" then
        -- 毕业典礼
        if self.biyedianliRedDot then
            self.biyedianliRedDot:setVisible(RedPointState[9].state == 1)
        end
    elseif event.data.name == "rchd" then
        -- 日常活动
        if self._richangactivityRedDot then
            self._richangactivityRedDot:setVisible(RedPointState[8].state == 1)
        end
    elseif event.data.name == "jrkh" then
        -- 节日狂欢
        if self.jierikuanghuanRedDot then
            self.jierikuanghuanRedDot:setVisible(RedPointState[1].state == 1)
        end
    elseif event.data.name == "bg" then
        -- 闭关
        if self.xxsjRedDot then
            self.xxsjRedDot:setVisible(RedPointState[11].state == 1)
        end
    elseif event.data.name == "hyyl" then
        -- 活跃有礼
        if self.hyylRedDot then
            self.hyylRedDot:setVisible(RedPointState[5].state == 1)
        end
    elseif event.data.name == "tzjh" then
        -- 投资计划
        if self.tzjhRedDot then
            self.tzjhRedDot:setVisible(RedPointState[6].state == 1)
        end
    elseif event.data.name == "czdh" then
        -- 超值兑换
        if self.czdhRedDot then
            self.czdhRedDot:setVisible(RedPointState[7].state == 1)
        end
    elseif event.data.name == "newlgdl" then
        -- 新累计登录
        if self.newloginrewardDot then
            self.newloginrewardDot:setVisible(RedPointState[17].state == 1)
        end
    elseif event.data.name == "monthandzcard" then
        -- 月卡至尊卡
        if self.monthcardRedDot then
            self.monthcardRedDot:setVisible(RedPointState[18].state == 1)
        end
    elseif event.data.name == "zxjl" then
        -- 在线奖励
        if self.onlinerewardRedDot then
            self.onlinerewardRedDot:setVisible(gameUser.getOnlineRewardDot() == 1)
        end
    elseif event.data.name == "bfyl" then
        if self.bfflRedDot then
            local _visible = false
            if RedPointState[19].state == 1 or RedPointState[20].state == 1 or gameUser.getSingleRechargeDot() == 1 then
                _visible = true
            end
            self.bfflRedDot:setVisible(_visible)
        end
    elseif event.data.name == "scsc" then
        if self._shouchongRedDot then
            self._shouchongRedDot:setVisible(RedPointState[22].state == 1)
        end
    else
        isGet = false
    end

    return isGet
end

-- 播放银两和翡翠的增加动画
function ZhuChengMenuLayer:playGJAddAction(buildingCollectNum, sG, sJ, collectResDone, callback)
    local gold = tonumber(self._propertyLable[2]:getString())
    --- 银两
    local jade = tonumber(self._propertyLable[3]:getString())
    ----翡翠

    local function getAct1(...)
        local act1 = cc.Repeat:create(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.ScaleTo:create(0.1, 1.0)), 3)
        act1:setTag(1)
        return act1
    end

    local function getAct2(...)
        local act2 = cc.Sequence:create(getAct1(), cc.CallFunc:create( function()
            if (callback) then
                callback()
            end
        end ))
        act2:setTag(1)
        return act2
    end

    if (collectResDone or(not self._propertyIcon[2]:getActionByTag(1) or not self._propertyIcon[3]:getActionByTag(1))) then
        if sJ >= sG then
            self._propertyIcon[3]:runAction(getAct2())
            if buildingCollectNum.addG > 0 then
                self._propertyIcon[2]:runAction(getAct1())
            end
        elseif sG >= sJ then
            if buildingCollectNum.addJ > 0 then
                self._propertyIcon[3]:runAction(getAct1())
            end
            self._propertyIcon[2]:runAction(getAct2())
        end
        collectResDone = false
    end

    local count1 = 0
    local count2 = 0
    local goldAfterCollect = tonumber(mGameUser.getGold()) + sG
    local emeraldAfterCollect = tonumber(mGameUser.getFeicui()) + sJ

    local function timeCount()
        gold = tonumber(self._propertyLable[2]:getString())
        if gold and gold < goldAfterCollect then
            self._propertyLable[2]:setString(gold + 1)
            letTheLableTint(self._propertyLable[2], true)
            count1 = count1 + 1
        end
        jade = tonumber(self._propertyLable[3]:getString())
        if jade and jade < emeraldAfterCollect then
            self._propertyLable[3]:setString(jade + 1)
            letTheLableTint(self._propertyLable[3], true)
            count2 = count2 + 1
        end
        if (sJ >= sG and count2 >= sJ) or(sJ <= sG and count1 >= sG) then
            if (callback) then
                callback(buildingCollectNum.id)
            end
        end
    end
    if gold or jade then
        schedule(self, timeCount, 0, self.Tag.ktag_buildGetSource)
    end
end

-- 移除银两和翡翠的增加动画的筛选器
function ZhuChengMenuLayer:removeSchedulerAddRes(...)
    self:stopActionByTag(self.Tag.ktag_buildGetSource)
end

-- 
function ZhuChengMenuLayer:setGJHugeNum(...)
    self._propertyLable[2]:setString(getHugeNumberWithLongNumber(mGameUser.getGold(), 1000000))
    self._propertyLable[3]:setString(getHugeNumberWithLongNumber(mGameUser.getFeicui(), 1000000))
end
-----进入神器
function ZhuChengMenuLayer:enterArtifact()
    local isOpen, data = isTheFunctionAvailable(35)
    if not isOpen then
        XTHDTOAST(data.tip)
        return
    end
    local ownArtifact = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ARTIFACT)
    if ownArtifact and ownArtifact.godid then
        ownArtifact = { ownArtifact }
    end
    if #ownArtifact > 0 then
        -- 主城界面选择神器
        local function getArtifact()
            local artifactData = gameData.getDataFromCSV("SuperWeaponUpInfo")
            table.sort(ownArtifact, function(a, b)
                if tonumber(artifactData[a.templateId].rank) == tonumber(artifactData[b.templateId].rank) then
                    return tonumber(artifactData[a.templateId]._type) < tonumber(artifactData[b.templateId]._type)
                else
                    return tonumber(artifactData[a.templateId].rank) > tonumber(artifactData[b.templateId].rank)
                end
            end )
            return ownArtifact[1].godid
        end
        local gid = getArtifact()
        XTHD.createArtifact(nil, nil, gid, nil)
    else
        XTHDTOAST(LANGUAGE_TIPS_WORDS4)
    end
end

--------------------------------------按键响应--------------------------------------

-- 历练按钮响应
function ZhuChengMenuLayer:onExpericeBtn(...)
    ----引导
    YinDaoMarg:getInstance():guideTouchEnd()
    ------------------
    replaceLayer( { id = 1, parent = self._parent })
end

-- 英雄按钮响应
function ZhuChengMenuLayer:onHeroBtn(...)
    ----引导
    YinDaoMarg:getInstance():guideTouchEnd()
    ------
    -- if self._pushSceneCount == 0 then
    self._pushSceneCount = self._pushSceneCount + 1
    local _layer = requires("src/fsgl/layer/YingXiong/YingXiongLayer.lua"):create()
    LayerManager.addLayout(_layer)
    -- end
end

-- 装备按钮响应
function ZhuChengMenuLayer:onEquipBtn(...)
    ----引导
    YinDaoMarg:getInstance():guideTouchEnd()
    local equipLayer = requires("src/fsgl/layer/ZhuangBei/ZhuangBeiLayer.lua"):create(heroid, dbid, _type, CallFunc)
    LayerManager.addLayout(equipLayer)
end

-- 任务按钮响应
function ZhuChengMenuLayer:onTaskBtn(...)
    -- 引导
    YinDaoMarg:getInstance():guideTouchEnd()
    ------
    XTHD.createTask(self)
end

-- 装备回收按钮响应
function ZhuChengMenuLayer:onEquipSmeltBtn(...)
    -- 引导
    YinDaoMarg:getInstance():guideTouchEnd()
    ------
    XTHD.createEquipSmeltLayer(nil, nil)
end

-----index 取值1-5，1 体力，2 精力，3 银两，4 翡翠，5 元宝
function ZhuChengMenuLayer:showBoxTips(target, index)
    self:removeChildByName("_boxTips")
    local winSize = cc.Director:getInstance():getWinSize()
    local boxTips = requires("src/fsgl/common_layer/BoxTipsNode.lua")
    self._boxTips = boxTips:create( { index = index })
    if self._boxTips and target then
        self._boxTips:setAnchorPoint(1, 1)
        local pos = target:convertToWorldSpace(cc.p(0, 0))
        pos = self:convertToNodeSpace(pos)
        self:addChild(self._boxTips)
        self._boxTips:setName("_boxTips")
        self._boxTips:setPosition(pos.x + 25, pos.y - target:getBoundingBox().height / 2)
        if self._boxTips:getPositionX() < self._boxTips:getBoundingBox().width then
            self._boxTips:setAnchorPoint(0, 1)
            self._boxTips:setPosition(pos.x + target:getBoundingBox().width - 25, pos.y - target:getBoundingBox().height / 2)
        end
    end
end

-- 数值增加按钮响应
function ZhuChengMenuLayer:doTopAddButtons(index)
    if not index then
        return
    end
    local _layer = nil
    if index == 1 then
        ----加体力
        _layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create( { id = 2 })
        -- byhuangjunjian 获得资源共用方法（1.元宝2.体力3.银两4.翡翠）
    elseif index == 2 then
        -----银两
        replaceLayer( { id = 48, fNode = self:getParent() })
    elseif index == 3 then
        -----翡翠
        replaceLayer( { id = 48, fNode = self:getParent() })
    elseif index == 4 then
        -----元宝
        XTHD.createRechargeVipLayer(self)
    end
    if _layer then
        self:addChild(_layer)
    end
end

function ZhuChengMenuLayer:toStoreLayer()
    local _store = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create( { which = 'yuanbao' })
    LayerManager.addLayout(_store)
end

-----用箭头指着指定功能的按钮
function ZhuChengMenuLayer:pointToSpecityMenu(funcID)
    ------------------------------------------------
    local index = self:menusReflectInFUL(tonumber(funcID))
    target = self.__functionButtons[index]
    if target then
        self:removePointer()
        self._extraFuncID = funcID
        self._Pointer = YinDao:addAHandToTarget(target)
        if index == 8 then
            -----竞技场
            self._Pointer:setRotation(60)
        end
    end
end

function ZhuChengMenuLayer:removePointer()
    if self._Pointer then
        self._Pointer:removeFromParent()
        self._Pointer = nil
    end
end
------主城页面的按钮在functioninfolist里的功能id映射
function ZhuChengMenuLayer:menusReflectInFUL(funcID)
    if funcID == 17 or funcID == 63 then
        -----竞技场抢夺/排位
        return 8
    elseif funcID == 72 then
        -------帮派
        return 17
    end
end

function ZhuChengMenuLayer:getBigPackageData()
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "liucunRewardRecord?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                self:getParent():cleanOperatorBtns()
                local _popLayer = requires("src/fsgl/layer/ZhuCheng/LoginRewardLayer1.lua"):create(data)
                LayerManager.addLayout(_popLayer, { par = self:getParent() })
            else
                XTHDTOAST(data.msg)
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function ZhuChengMenuLayer:onDailyTask()
    -- 每日活动
    local RiChangRenWuLayer = requires("src/fsgl/layer/RiChangRenWu/RiChangRenWuLayer.lua"):create()
    self:addChild(RiChangRenWuLayer)
end

-- function ZhuChengMenuLayer:updateActivityButtonPos(which,visible)
--     local target = self.__functionButtons[14]
--     target:setVisible(visible)
--     if visible == true then
--         gameUser.setOSPackageTimes(0)
--     elseif visible == false then
--         gameUser.setOSPackageTimes(1)
--         target:removeChildByName("_liucunBoxSpine")
--     end
-- end
-------送金刚狼的那玩意儿
-- function ZhuChengMenuLayer:runLiuCunAction( isRun )
--     local target = self.__functionButtons[14]
--     if target then
--         local _spine = target:getChildByName("_liucunBoxSpine")
--         if not _spine then
--             _spine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/kflb.json", "res/image/homecity/frames/spine/kflb.atlas", 1.0)
--             target:addChild(_spine)
--             _spine:setName("_liucunBoxSpine")
--             _spine:setPosition(target:getContentSize().width / 2,target:getContentSize().height * 1/3)
--         end
--         if isRun then
--             _spine:setAnimation(0,"atk",true)
--         else
--             _spine:setAnimation(0,"idle",true)
--             gameUser.setBigPackageGetting(0)
--         end
--     end
-- end
------7天礼包,是否显示动画 ，是否领取完了
function ZhuChengMenuLayer:addARoundLightEffect(isRun, target, nameTag, scaleFact, targetVisible)
    scaleFact = scaleFact == nil and 1.0 or scaleFact
    if target and nameTag then
        target:setVisible(isRun)
        if targetVisible then
            target:setVisible(targetVisible)
        end
        if isRun then
            --- 显示动画
            if not self:getChildByName(nameTag) then
                -- local _temp = cc.Sprite:create()
                -- _spine = cc.Animation:createWithSpriteFrames(self._7dayAni,1/7)
                -- _spine = cc.Animate:create(_spine)
                -- _spine = cc.RepeatForever:create(_spine)
                -- _temp:runAction(_spine)
                -- _temp:setScale(scaleFact)
                -- -- self:addChild(_temp,target:getLocalZOrder() - 1)
                -- _temp:setName(nameTag)
                -- _temp:setPosition(target:getPositionX() - target:getContentSize().width / 2 + 10,target:getPositionY() + target:getContentSize().height / 2 - 5)
                -- 特效spine ly0409
                local activitySpine = sp.SkeletonAnimation:create("res/image/homecity/qrkh/diban.json", "res/image/homecity/qrkh/diban.atlas", 1.0)
                activitySpine:setAnimation(0, "diban", true)
                -- activitySpine:setPosition(target:getPositionX() - target:getContentSize().width / 2 + 10,target:getPositionY() + target:getContentSize().height / 2 - 5)
                activitySpine:setPosition(target:getContentSize().width / 2, target:getContentSize().height / 2)
                activitySpine:setName(nameTag)
                target:addChild(activitySpine, -1)
            else
                local _temp = self:getChildByName(nameTag)
                _temp:setPosition(target:getPositionX() - target:getContentSize().width / 2 + 10, target:getPositionY() + target:getContentSize().height / 2 - 5)
            end
        else
            self:removeChildByName(nameTag)
        end
    end
end
------自适应左上边的按钮位置以及按钮显示和隐藏
function ZhuChengMenuLayer:adjustLeftUpMenu()
    if #self._leftupBtns > 0 and self.needScaleBtn then
        local index = { }
        local _nameTag = { "dailyWelfare", "wonderful_activity" }
        for k, v in pairs(self._leftupBtns) do
            ----分组，把显示的跟不显示的分开
            if v and v.isActivity and k < 12 then
                -- print("主城按钮状态："..k)
                index[#index + 1] = v
            end
        end
        local i = 1
        for k, v in pairs(index) do
            v.targ:setVisible(true)
            v.targ:setPosition(self._leftupBtns[i].x, self._leftupBtns[i].y)
            i = i + 1
        end
        -- if self._leftupBtns[2].targ:isVisible() == false then
        --     self._leftupBtns[4].targ:setPositionX(self._leftupBtns[4].x+80)
        -- end

        -- self._wonderfulactivityRedDot:setVisible(true)
        for i = 12, 18 do
            if self._leftupBtns[i].targ.isActivity then
                self._leftupBtns[i]:setPosition(self._leftupBtns[i].x, self._leftupBtns[i].y)
            end
        end
    end
    self:refreshCeilNodeBtnPos()
    self:refreshLeftTopNodePos()
    self:refreshLeftFloorNodePos()
end
----显示已经开始的战斗提示（种族战、世界boss...）
function ZhuChengMenuLayer:showExecuteBattleTips(isShow, index)
    if self._warExeLabel then
        self._warExeLabel:setVisible(isShow)
        if self._warExeLabel.warName then
            self._warExeLabel.warName:setString(LANGUAGE_WARS[index])
        end
    else
        local _btn = XTHDPushButton:createWithParams( {
            musicFile = XTHD.resource.music.effect_btn_common,
        } )
        _btn:setTouchSize(cc.size(230, 90))
        _btn:setContentSize(cc.size(230, 90))
        self:addChild(_btn)
        local _tempTarg = self._cd_label:getParent()
        _btn:setAnchorPoint(0, 0.5)
        local _posX = 4
        if screenRadio > 1.8 then
            _posX = 37
        end
        _btn:setPosition(_posX, _tempTarg:getPositionY() - _tempTarg:getContentSize().height - 20)
        _btn:setTouchBeganCallback( function()
            _btn:setScale(0.9)
        end )
        _btn:setTouchMovedCallback( function()
            _btn:setScale(0.9)
        end )
        _btn:setTouchEndedCallback( function()
            _btn:setScale(1.0)
            self:gotoExecuteBattle(gameUser._currentBattle)
        end )
        _btn:setVisible(isShow)
        self._warExeLabel = _btn

        ----特效
        local _texture = { }
        for i = 1, 16 do
            local texture = cc.Director:getInstance():getTextureCache():addImage("res/image/homecity/frames/vs/zyvs" .. i .. ".png")
            ----限时战上的特效
            _texture[i] = cc.SpriteFrame:createWithTexture(texture, cc.rect(0, 0, texture:getPixelsWide(), texture:getPixelsHigh()))
        end
        local blink = cc.Animation:createWithSpriteFrames(_texture, 16 / 130)
        blink = cc.Animate:create(blink)
        local target = cc.Sprite:create()
        _btn:addChild(target)
        target:setAnchorPoint(0.5, 0.5)
        target:setPosition(_btn:getTouchSize().width / 2 - 10, _btn:getContentSize().height / 2)
        target:runAction(cc.RepeatForever:create(blink))
        ------文字
        local _warName = XTHDLabel:createWithParams( {
            text = LANGUAGE_WARS[index],
            fontSize = 16,
            color = cc.c3b(253,235,195),
        } )
        _btn:addChild(_warName)
        _warName:setPosition(_btn:getBoundingBox().width / 2 + 5, _btn:getBoundingBox().height / 2 + _warName:getContentSize().height / 2)
        _btn.warName = _warName
        -----
        local _comeIn = XTHDLabel:createWithParams( {
            text = LANGUAGE_KEY_CLICKIN,
            fontSize = 20,
            color = cc.c3b(253,235,195),
        } )
        _btn:addChild(_comeIn)
        _comeIn:setPosition(_warName:getPositionX(), _comeIn:getContentSize().height + 5)
    end
end
-----在新目标与战斗开启间切换
function ZhuChengMenuLayer:switchFromNewGoalAndBattle(warStart, what)
    if 1 then
        -- 暂时屏蔽
        return
    end
    gameUser._currentBattle = what
    if gameUser.getLevel() <= 15 then
        return
    end
    if self._newFunctionBoard then
        self._newFunctionBoard:setVisible(not warStart)
    end
    if warStart == true then
        ------显示限时战
        self:showExecuteBattleTips(true, what)
    else
        ----不显示
        local index = 0
        for k, v in pairs(gameUser.getLimitBattle()) do
            ----查询当前是否还有其它限时战还未结束
            if v > 0 then
                index = k
                break
            end
        end
        if index == 0 then
            -------没有限时战了
            if self._warExeLabel then
                self._warExeLabel:removeFromParent()
                self._warExeLabel = nil
            end
        else
            -----还有
            gameUser._currentBattle = index
            if self._newFunctionBoard then
                ------关卡小提示
                self._newFunctionBoard:setVisible(false)
            end
            self:showExecuteBattleTips(true, index)
        end
    end
end


function ZhuChengMenuLayer:Bingfenfuli()
    local Bingfenfuli = requires("src/fsgl/layer/HuoDong/Bingfenfuli.lua")
    local layer = Bingfenfuli:create()
    cc.Director:getInstance():getRunningScene():addChild(layer)
	layer:setName("Poplayer")
    layer:show()
end

function ZhuChengMenuLayer:openRCHD()
    local activityDailyLayer = requires("src/fsgl/layer/HuoDong/RiChangHuoDongLayer.lua")
    local id = activityDailyLayer:firstActivityId()
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "totalActivateList?",
        params = { activateId = id },
        successCallback = function(backData)
            -- print("日常活动服务器返回的数据为：")
            -- print_r(backData)
            if tonumber(backData.result) == 0 then
                local layer = activityDailyLayer:create(backData)
                cc.Director:getInstance():getRunningScene():addChild(layer)
				layer:setName("Poplayer")
                layer:show()
            else
                XTHDTOAST(backData.msg)
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        targetNeedsToRetain = self,
        -- 需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    } )
end

function ZhuChengMenuLayer:openBYDL()
    local biyedianliLayer = requires("src/fsgl/layer/ZhuCheng/BiYeDianLiLayer.lua")
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "gragraduationRewardList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                local layer = biyedianliLayer:create(data)
                self:addChild(layer)
                layer:show()
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        targetNeedsToRetain = self,
        -- 需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    } )
end

function ZhuChengMenuLayer:openXYZP()
    local luckyTrunLayer = requires("src/fsgl/layer/ZhuCheng/XinYunZhuanPanLayer.lua")
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "openLuckyTurn?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                local layer = luckyTrunLayer:create(data)
                self:addChild(layer)
                layer:show()
            else
                XTHDTOAST(data.msg)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        targetNeedsToRetain = self,
        -- 需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    } )
end


------去往已开启的战斗
function ZhuChengMenuLayer:gotoExecuteBattle(index)
    local _funcID = { 75, 72, 77, 47 }
    -----(1:boss; 2: 帮派战;3 : 修罗战场 4：种族战),
    if gameUser.getLimitBattle(index) > 0 then
        -----当前的限时战是开启的
        local isOpen, _data = isTheFunctionAvailable(_funcID[index])
        -----种族
        local _jumpID = { 46, 52, 51, 27 }
        -----(1:boss; 2: 帮派战;3 : 修罗战场 4：种族战),
        if isOpen then
            -----
            replaceLayer( { fNode = self, id = _jumpID[index] })
        elseif _data then
            ----没开启
            XTHDTOAST(_data.tip or LANGUAGE_CAMP_TIPSWORDS34)
        end
    end
end

function ZhuChengMenuLayer:addGuide()
    local _experience = self.__functionButtons[12]
    ----历练按钮
    local _family = self.__functionButtons[22]
    -- 帮派
    local _hero = self.__functionButtons[11]
    ----英雄
    local _task = self.__functionButtons[10]
    --- 任务
    local _equip = self.__functionButtons[13]
    --- 装备
    local _baodian = self.__functionButtons[17]
    --- 宝典
    YinDaoMarg:getInstance():addGuide( {
        -----引导去英雄
        parent = self,
        target = _hero,
        needNext = false,
    } , {
        { 2, 3 },
        { 5, 2 },
        { 7, 2 },
        { 13, 2 },
    } )
    YinDaoMarg:getInstance():addGuide( {
        parent = self,
        target = _experience,
        -----历练
        index = 6,
        needNext = false,
    } , {
        { 1, 6 },
        { 2, 10 },
        { 5, 7 },
        { 8, 2 },
    } )
    YinDaoMarg:getInstance():addGuide( {
        parent = self,
        target = self.__functionButtons[8],
        -----竞技场
        needNext = false,
    } , {
        { 11, 2 },
        { 9, 2 },
        { 20, 2 },
    } )
    YinDaoMarg:getInstance():addGuide( {
        parent = self,
        target = _baodian,
        -----宝典
        index = 2,
        needNext = false,
    } , 17)

    YinDaoMarg:getInstance():addGuide( {
        parent = self,
        target = _equip,
        ----装备
        needNext = false,
    } , { { - 1, 2 }, { 6, 3 } })
    YinDaoMarg:getInstance():addGuide( {
        parent = self,
        target = _family,
        ----帮派
        index = 2,
        needNext = false,
    } , 21)
    YinDaoMarg:getInstance():addGuide( {
        parent = self,
        target = self.bossBtn,
        ----世界boss
        index = 2,
        needNext = false,
    } , 23)
    YinDaoMarg:getInstance():addGuide( {
        parent = self,
        target = self.duoquanBtn,
        ----夺权
        index = 2,
        needNext = false,
    } , 24)
    YinDaoMarg:getInstance():addGuide( {
        parent = self,
        target = self.shenqiBtn,
        ----神器
        index = 2,
        needNext = false,
    } , 26)
--     YinDaoMarg:getInstance():doNextGuide()
end

function ZhuChengMenuLayer:guide2Fight()
    YinDaoMarg:getInstance():onlyCapter1Guide( {
        -----第一章的引导
        parent = self,
        target = self.__functionButtons[12],----历练按钮,
    } )
end

function ZhuChengMenuLayer:StrengthenLayerCreate()
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "scoreList?",
        successCallback = function(data)
            -- dump(data,"aaa")
            if tonumber(data.result) == 0 then
                local luckyTrunLayer = requires("src/fsgl/layer/ZhuCheng/BianQiangLayer.lua")
                local layer = luckyTrunLayer:create(data, self)
                self:addChild(layer)
                layer:show()
            else
                XTHDTOAST(data.msg)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    } )
end

function ZhuChengMenuLayer:createHyperShop()
    HttpRequestWithOutParams("hypemarketList", function(data)
        -- print("大卖场服务器返回的数据为：")
        -- print_r(data)
        local hyper = requires("src/fsgl/layer/HuoDong/DaMaiChangLayer.lua"):create( { data = data })
        cc.Director:getInstance():getRunningScene():addChild(hyper)
		hyper:setName("Poplayer")
        hyper:show()
    end )
end

function ZhuChengMenuLayer:JieRiAnctivityLayer()
    -- 这里要进行一次对兑换剩余次数的数据处理
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "holidayActivatExchangeList?",
        successCallback = function(data)
            requires("src/fsgl/layer/HuoDong/JieRiKuangHuangLayer.lua"):createWithTab(1, data)
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    } )
end

-- 冲榜活动
function ZhuChengMenuLayer:QuanfuchongbangActivityLayer()
    local list = { "level", "power", "StoredValue", "cost", "flower", "sendFlower", "guild", "xiulian", "vines" }
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "leaderBoardRank?",
        params = { type = list[1] },
        successCallback = function(data)
            if data.result == 0 then
                local biyedianliLayer = requires("src/fsgl/layer/HuoDong/QuanfuchongbangActivity.lua")
                local layer = biyedianliLayer:create(data)
                cc.Director:getInstance():getRunningScene():addChild(layer)
				layer:setName("Poplayer")
                layer:show()
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    } )
end

-- 战力竞技
function ZhuChengMenuLayer:ZhanlijingsaiActivityLayer()
    local list = { "heroStar", "heroPhase", "heroPower", "equipStar", "godPhase" }
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "leaderBoardRank?",
        params = { type = list[1] },
        successCallback = function(data)
            if data.result == 0 then
                local biyedianliLayer = requires("src/fsgl/layer/HuoDong/ZhanlijingsaiActivityLayer.lua")
                local layer = biyedianliLayer:create(data)
                cc.Director:getInstance():getRunningScene():addChild(layer)
				layer:setName("Poplayer")
                layer:show()
            else
                XTHDTOAST(data.msg)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    } )
end
-- 全民竞技
function ZhuChengMenuLayer:QuanmingjingjiActivityLayer()
    local list = { "arena" }
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "leaderBoardRank?",
        params = { type = list[1] },
        successCallback = function(data)
            if data.result == 0 then
                local biyedianliLayer = requires("src/fsgl/layer/HuoDong/QuanmingjingjiActivityLayer.lua")
                local layer = biyedianliLayer:create(data)
                cc.Director:getInstance():getRunningScene():addChild(layer)
				layer:setName("Poplayer")
                layer:show()
            else
                XTHDTOAST(data.msg)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    } )
end

function ZhuChengMenuLayer:openNewLoginReward()
    HttpRequestWithOutParams("createLoginRewardList", function(data)
        -- print("新日常活动服务器返回的数据为：")
        -- print_r(data)
        local layer = requires("src/fsgl/layer/HuoDong/NewLDengLuYouLiLayer.lua"):create(data)
        cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:setName("Poplayer")
        layer:show()
    end )
end

function ZhuChengMenuLayer:openMonthCard()
    HttpRequestWithOutParams("mouthCardState", function(data)
        -- print("月卡至尊卡服务器返回的数据为：")
        -- print_r(data)
        local layer = requires("src/fsgl/layer/HuoDong/YueKaAndZhiZunKa.lua"):create(data)
        cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:setName("Poplayer")
        layer:show()
    end )
end

-- 超值兑换
function ZhuChengMenuLayer:ChaozhiduihuanActivityLayer()
    local biyedianliLayer = requires("src/fsgl/layer/HuoDong/ChaozhiduihuanActivityLayer.lua")
    local layer = biyedianliLayer:create(data)
    cc.Director:getInstance():getRunningScene():addChild(layer)
	layer:setName("Poplayer")
    layer:show()
end

-- 投资计划
function ZhuChengMenuLayer:TouzijihuaActivityLayer()
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "InvestPlanRecord?",
        params = { type = 1 },
        successCallback = function(data)
            if data.result == 0 then
                local biyedianliLayer = requires("src/fsgl/layer/HuoDong/NewTouzijihuaActivityLayer.lua")
                local layer = biyedianliLayer:create(data)
                cc.Director:getInstance():getRunningScene():addChild(layer)
				layer:setName("Poplayer")
                layer:show()
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    } )
end

-- 活跃有礼
function ZhuChengMenuLayer:HuoyueyouliActivityLayer()
	local newHuoyueyouli = requires("src/fsgl/layer/HuoDong/NewHuoyueyouli.lua"):create(1)
	LayerManager.addLayout(newHuoyueyouli)
--    ClientHttp:requestAsyncInGameWithParams( {
--        modules = "activeActivityList?",
--        params = { type = 1 },
--        successCallback = function(data)
--            if data.result == 0 then
--                local biyedianliLayer = requires("src/fsgl/layer/HuoDong/HuoyueyouliActivityLayer.lua")
--                local layer = biyedianliLayer:create(data)
--                cc.Director:getInstance():getRunningScene():addChild(layer)
--				layer:setName("Poplayer")
--                layer:show()
--            end
--        end,
--        failedCallback = function()
--            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
--            ------"网络请求失败")
--        end,
--        -- 失败回调
--        loadingType = HTTP_LOADING_TYPE.CIRCLE,
--        -- 加载图显示 circle 光圈加载 head 头像加载
--        loadingParent = node,
--    } )
end


-- 七日狂欢
function ZhuChengMenuLayer:Qirikuanghuan()
    local _timeoutForRead = 10
    XTHDHttp:requestAsyncInGameWithParams( {
        modules = "openServerActivityList?",
        params = nil,
        method = nil,
        timeoutForRead = _timeoutForRead,
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_RECHARGE_HUOYUEJIANGLI })
                local QIRiKuangHuang = requires("src/fsgl/layer/HuoDong/QIRiKuangHuang.lua")
                local layer = QIRiKuangHuang:create(data)
				layer:setName("Poplayer")
                cc.Director:getInstance():getRunningScene():addChild(layer)
                layer:show()
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
                -----"网络请求失败!")
                if _failureCallback then
                    _failureCallback(data)
                end
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            -------"网络请求失败!")
            if _failureCallback then
                _failureCallback()
            end
        end,
        -- 失败回调
        targetNeedsToRetain = self,
        -- 需要保存引用的目标
        loadingParent = self,
    } )
end

function ZhuChengMenuLayer:TimelimitAnctivityLayer()
    local layer = requires("src/fsgl/layer/HuoDong/timelimitActivity/TimelimitAnctivityLayer.lua"):create()
    cc.Director:getInstance():getRunningScene():addChild(layer)
	layer:setName("Poplayer")
    layer:show()
end

function ZhuChengMenuLayer:refreshHeroBtnTishi()
    -- 构建数据
    -- 获取所有已拥有英雄的数据
    local _temp_data = HeroDataInit:InitHeroDataAllOwnHero()

    -- 组合成英雄数据
    m_herosData = { }
    for k, v in pairs(_temp_data) do
        m_herosData[#m_herosData + 1] = v
    end

    other_herosData = gameData.getDataFromCSV("GeneralInfoList")
    local _allHeroData = { }
    _allHeroData = clone(other_herosData)

    local _myheroData = { }
    for j = 1, #m_herosData do
        _myheroData[tostring(m_herosData[j]["heroid"])] = m_herosData[j]
    end
    local _count = 0
    for i = #_allHeroData, 1, -1 do
        if _myheroData[tostring(_allHeroData[i]["heroid"])] ~= nil or tonumber(_allHeroData[i]["unlock"]) == 0 then
            table.remove(other_herosData, i)
        end
    end

    local dynamicItemData = DBTableItem:getDataByID()

    local canRecruit_herosData = { }
    local other_chipData = { }

    -- 魂石的item_type都是2
    for k, v in pairs(dynamicItemData) do
        if tonumber(v.item_type) == 2 then
            other_chipData[tostring(tonumber(v.itemid) -1000)] = { }
            other_chipData[tostring(tonumber(v.itemid) -1000)] = v
        end
    end

    local data = gameData.getDataFromCSV("GeneralGrowthNeeds") or { }
    local starupchipData = { }
    for k, v in pairs(data) do
        starupchipData[v.id] = v
    end

    local _otherNum = #other_herosData
    for i = _otherNum, 1, -1 do
        local _index = i
        local _heroid = other_herosData[_index]["heroid"]
        local _chipData = other_chipData[tostring(_heroid)] or { }
        other_herosData[_index].chipNumber = _chipData.count and _chipData.count or 0
        local _starNum = tonumber(other_herosData[_index].star)
        local _chipPercent = math.floor(tonumber(other_herosData[_index].chipNumber) / tonumber(starupchipData[tonumber(_heroid)]["starcount" .. _starNum]) * 100)
        other_herosData[_index].chipPercent = _chipPercent
        if _chipPercent >= 100 then
            canRecruit_herosData[#canRecruit_herosData + 1] = clone(other_herosData[_index])
        end
    end
    if #canRecruit_herosData >= 1 then
        return true
    else
        return false
    end
end

function ZhuChengMenuLayer:refreshZhaoMuTishi()
    local count = XTHD.resource.getItemNum(2306) or 0  --gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM, { itemid = 2306 }).count or 0
    local count2 = XTHD.resource.getItemNum(2307) or 0  --gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM, { itemid = 2307 }).count or 0
    if count >= 9 or count2 >= 9 then
        return true
    else
        return false
    end
end

-- 加入按钮至上方
function ZhuChengMenuLayer:PushBtnToCeilNode(btn)
    btn:retain()
    btn:removeFromParent()
    self._ceilbtnNode:addChild(btn)
    local childs = self._ceilbtnNode:getChildren()
    local _index = 0
    local x, y
    -- print("开启的活动的长度为："..#childs)
    if #childs <= 9 then
        x = self._ceilbtnNode:getContentSize().width - 60 -(#childs - 1) * btn:getContentSize().width * 0.7 + 10
        y = self._ceilbtnNode:getContentSize().height - btn:getContentSize().height + 25
    else
        _index = #childs - 9
        x = self._ceilbtnNode:getContentSize().width - 60 -(_index - 1) * btn:getContentSize().width * 0.7 + 10
        y = self._ceilbtnNode:getContentSize().height - btn:getContentSize().height * 2 + 25 * 2
    end
    btn:setPosition(x, y)
end

-- 刷新上方按钮位置
function ZhuChengMenuLayer:refreshCeilNodeBtnPos()
    self._ceilbtnList1 = { }
    self._ceilbtnList2 = { }
    local childs = self._ceilbtnNode:getChildren()
    local _index = 0
    local _index2 = 0
    local x, y
    for i = 1, #childs do
        if childs[i]:isVisible() then
            _index = _index + 1
            if _index <= 9 then
                x = self._ceilbtnNode:getContentSize().width - 10 -(_index - 1) * childs[i]:getContentSize().width * 0.6 - 32
                y = self._ceilbtnNode:getContentSize().height - childs[i]:getContentSize().height + 40
                self._ceilbtnList1[#self._ceilbtnList1 + 1] = childs[i]
            else
                _index2 = _index - 9
                x = self._ceilbtnNode:getContentSize().width - 10 -(_index2 - 1) * childs[i]:getContentSize().width * 0.6 - 90
                y = self._ceilbtnNode:getContentSize().height - childs[i]:getContentSize().height * 2 + 40 * 2
                self._ceilbtnList2[#self._ceilbtnList2 + 1] = childs[i]
            end
            if childs[i]:getName() == "bosscome" then
                childs[i]:setPosition(self._ceilbtnNode:getContentSize().width + 30, self._ceilbtnNode:getContentSize().height / 2 - 20)
            else
                childs[i]:setPosition(x, y)
            end
        end
    end
end

-- 加入按钮至右侧
function ZhuChengMenuLayer:PushBtnToRightNode(btn)
    btn:retain()
    btn:removeFromParent()
    self._rightbtnNode:addChild(btn)
    local childs = self._rightbtnNode:getChildren()
    local x, y
    x = self._rightbtnNode:getContentSize().width - btn:getContentSize().width * 0.5 - 17
    y =(btn:getContentSize().height * 0.75 - 10) * #childs

    btn:setPosition(x, y)
end

-- 刷新右侧按钮位置
function ZhuChengMenuLayer:refreshRightNodeBtnPos()
    if self.rightneedScaleBtn == false then
        return
    end
    self._rightbtnList = { }
    local childs = self._rightbtnNode:getChildren()
    local x, y
    local _idnex = 0
    for i = 1, #childs do
        if childs[i]:isVisible() then
            _idnex = _idnex + 1
            x = self._rightbtnNode:getContentSize().width - childs[i]:getContentSize().width * 0.5 - 17
            y =(childs[i]:getContentSize().height * 0.75 - 10) *(_idnex - 1) + 10
            childs[i]:setPosition(x, y)
            self._rightbtnList[#self._rightbtnList + 1] = childs[i]
            self.rightPosY = y + 190 *(cc.Director:getInstance():getWinSize().height / 615)
            self.rightscaleBtn:setPosition(self.rightscaleBtn:getPositionX(), self.rightPosY)
        end
    end
end

-- 加入按钮到左下角
function ZhuChengMenuLayer:PushBtnToLeftNode(btn)
    btn:retain()
    btn:removeFromParent()
    self._leftbtnNode:addChild(btn)
    btn:setScale(0.8)
    btn:setAnchorPoint(0, 0)
    local childs = self._leftbtnNode:getChildren()
    local x, y
    x =(btn:getContentSize().width - 20) *(#childs - 1) -23
    y = -9
    btn:setPosition(x, y)
end

-- 刷新左下角按钮位置
function ZhuChengMenuLayer:refreshLeftFloorNodePos()
    self._leftFloorBtnList = { }
    local childs = self._leftbtnNode:getChildren()
    local _index = 0
    local posX = 0
    local x, y
    for i = 1, #childs do
        if childs[i] and childs[i]:isVisible() then
            _index = _index + 1
            x = posX - 20
            y = -9
            posX = posX + childs[i]:getContentSize().width * 1.15
            if childs[i]:getName() == "newTarget" then
                childs[i]:setPosition(x - 50, y + 10)
            else
                childs[i]:setPosition(x, y)
            end
            self._leftFloorBtnList[#self._leftFloorBtnList + 1] = childs[i]
        end
    end
end

-- 加入按钮到左上角
function ZhuChengMenuLayer:PushBtnToLeftTopNode(btn)
    btn:retain()
    btn:removeFromParent()
    self._leftTopBtnNode:addChild(btn)
    btn:setScale(0.6)
    btn:setAnchorPoint(0, 0)
    local childs = self._leftTopBtnNode:getChildren()
    local x, y
    x =(btn:getContentSize().width - 35) *(#childs - 1) -15
    y = 6
    btn:setPosition(x, y)
end

-- 刷新左上角按钮位置
function ZhuChengMenuLayer:refreshLeftTopNodePos()
    self._leftTopBtnList = { }
    local childs = self._leftTopBtnNode:getChildren()
    local _index = 0
    local x, y
    for i = 1, #childs do
        if childs[i]:isVisible() then
            _index = _index + 1
            x =(childs[i]:getContentSize().width - 40) *(_index - 1) -10
            y = 6
            childs[i]:setPosition(x, y)
            self._leftTopBtnList[#self._leftTopBtnList + 1] = childs[i]
        end
    end
end

-- 加入按钮到右下角
function ZhuChengMenuLayer:PushBtnTorightfloorNode(btn)
    btn:retain()
    btn:removeFromParent()
    btn:setScale(0.75)
    self._rightfloorbtnNode:addChild(btn)
    local childs = self._rightfloorbtnNode:getChildren()
    local x, y
    x = self._rightfloorbtnNode:getContentSize().width -(btn:getContentSize().width * 0.7) *(#childs - 1) -5
    y = 0

    btn:setPosition(x, y)

end

-- 刷新右下角按钮位置
function ZhuChengMenuLayer:refreshRightFloorBtnPos()
    if self.floorneedScaleBtn == false then
        return
    end
    self._floorbtnList = { }
    local childs = self._rightfloorbtnNode:getChildren()
    local _index = 0
    local x, y
    for i = 1, #childs do
        if childs[i]:isVisible() then
            _index = _index + 1
            x = self._rightfloorbtnNode:getContentSize().width -(childs[i]:getContentSize().width * 0.7) *(_index - 1) -5
            y = 0
            childs[i]:setPosition(x, y)
            self._floorbtnList[#self._floorbtnList + 1] = childs[i]
            self.rightFloorPosX = x + 280 *(cc.Director:getInstance():getWinSize().width / 1024)
            self.floorscaleBtn:setPosition(self.rightFloorPosX, self.floorscaleBtn:getPositionY())
        end
    end
end

function ZhuChengMenuLayer:updateOnlineTime()
    self:stopActionByTag(10)
    if self.closeTime == -1 then
        self.Time:setString("今日已达上限")
        return
    end
    self.Time:setString(LANGUAGE_ONLINE_COUNTDOWN(self.closeTime))
    schedule(self, function()
        self.closeTime = self.closeTime - 1
        if self.closeTime <= 0 then
            self.Time:setString("领取奖励")
            return
        end
        local time = LANGUAGE_ONLINE_COUNTDOWN(self.closeTime)
        self.Time:setString(time)
    end , 1, 10)
end

return ZhuChengMenuLayer
