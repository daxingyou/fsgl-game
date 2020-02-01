--Created By Liuluyang 2015年10月10日
--演武场界面
local RiChangRenWuLayer = class("RiChangRenWuLayer",function ()
    local layer = zc.createBasePageLayer()
	return layer
end)

function RiChangRenWuLayer:onCleanup()
    local textureCache = cc.Director:getInstance():getTextureCache()
    for k,v in pairs(self.funcList) do
        textureCache:removeTextureForKey("res/image/daily_task/"..v.name..".png")
        textureCache:removeTextureForKey("res/image/daily_task/"..v.name.."_selected.png")
    end
    helper.collectMemory()
end

function RiChangRenWuLayer:ctor(extraFuncID,parent)
    self._funcIndex = extraFuncID
    self._parent = parent
    self._typeEnum = {
        goldGambling = 1,
        destinyDice = 2,
        jadeGambling = 3,
        arena = 4,
        escortTask = 5,
        worldBoss = 6,
        offerReward = 7,
        goldCopy = 8,
        jaditeCopy = 9,
        equipCopies = 10,
        saintBeastChapter = 11,
        multiCopy = 12,
		servants = 13, 
		challenge = 14,
    }
    self._localData = gameData.getDataFromCSV("MartialList")
    self._showData = {}
    self:initData()
	self:initUI()
end

function RiChangRenWuLayer:guideTo(_type)
    if self.btnList[_type]:getPositionX() > self:getBoundingBox().width/2 then
        self._scrollview:jumpToPercentHorizontal(((self.btnList[_type]:getPositionX()-self:getBoundingBox().width/2)/(self._scrollview:getInnerContainerSize().width-self:getBoundingBox().width))*100)
    end
    return self.btnList[_type]
end

function RiChangRenWuLayer:initData()
    self._showData = {}
    for i = 1,#self._localData do
        self._showData[i] = {}
        for j = 1,3 do
            if self._localData[i]["rewardtype"..j] ~= nil then
                local temp = {}
                if self._localData[i]["rewardtype"..j] == 4 then
                    temp.itemtype = 4
                    temp.itemid = self._localData[i]["canshu"..j]
                else
                    temp.itemtype = self._localData[i]["rewardtype"..j]
                end
                table.insert(self._showData[i],temp)
            end
        end
    end
    -- print("封装好的演武场的数据为：")
    -- print_r(self._showData)
end

function RiChangRenWuLayer:initUI()

	self.infoList = gameData.getDataFromCSV("FunctionInfoList")
	local funcList = {
		[1] = {name = "destiny_dice",callFunc = function ()
            zc.GodDiceLayer(self._parent)
		end,id = 68},
		[2] = {name = "jade_gambling",callFunc = function ()
			zc.createStoneGambling(1)
		end,id = 69},
		[3] = {name = "arena",callFunc = function ()
            zc.createXiuLuo( self )
		end,id = 77},
		[4] = {name = "escort_task",callFunc = function ()
            LayerManager.addShieldLayout()
			zc.YaYunLiangCaoLayer(self)
		end,id = 76},
		[5] = {name = "world_boss",callFunc = function ()
            LayerManager.createModule( "src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiLayer.lua", {par = self} )            
		end,id = 75},
		[6] = {name = "offer_reward",callFunc = function ()
			requires("src/fsgl/layer/XuanShangRenWu/XuanShangRenWuLayer.lua"):createForLayerManager({node = self})
		end,id = 71},
		[7] = {name = "gold_copy",callFunc = function () 
			zc.createGoldCopy(self) ----银两副本
		end,id = 25},
		[8] = {name = "jadite_copy",callFunc = function ()
			zc.createJaditeCopy(self)
		end,id = 26},
		[9] = {name = "equip_copies",callFunc = function ()
            zc.createEquipCopies(self)
		end,id = 27},
        [10] = {name = "saint_beast",callFunc = function ()
            zc.createSaintBeastChapter(self)
        end,id = 23},
        [11] = {name = "seek_treasure",callFunc = function ()
            zc.createSeekTreasureLayer(self)
        end,id = 79},
        [12] = {name = "duorenfuben",callFunc = function () ----多人副本
            requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenLayer.lua"):create()
        end,id = 80},
		[13] = {name = "shipu",callFunc = function ()
            zc.createServantsChapter(self)
        end,id = 88},
		[14] = {name = "challenge",callFunc = function ()
            zc.createChallengeChapter(self)
        end,id = 87},
	}
    self.funcList = funcList

    local Bg = cc.Sprite:create("res/image/common/jhl_bg.png")
	local size = cc.Director:getInstance():getWinSize()
	Bg:setContentSize(size)
    Bg:setPosition(self:getBoundingBox().width/2,self:getContentSize().height/2 - self.topBarHeight/2)
    self:addChild(Bg)
    local taskPicWidth = 342
    local scrollHeight = 496
    self._scrollview = ccui.ScrollView:create()
    self._scrollview:setTouchEnabled(true)
    self._scrollview:setDirection(ccui.ScrollViewDir.horizontal)
    self._scrollview:setContentSize(cc.size(self:getContentSize().width, scrollHeight+80))
    self._scrollview:setInnerContainerSize(cc.size(taskPicWidth *0.8*#funcList-1,scrollHeight))
    self._scrollview:setAnchorPoint(0,0.5)
    self._scrollview:setPosition(0, (size.height-self.topBarHeight)/2+55)
	self._scrollview:setScrollBarEnabled(false)
    Bg:addChild(self._scrollview)

    --排序
    table.sort(funcList,function (a1,a2)
        if a1.open == nil then
            a1.open = zc.getUnlockStatus(a1.id)
        end
        if a2.open == nil then
            a2.open = zc.getUnlockStatus(a2.id)
        end
        if a1.open ~= a2.open then
            return a1.open
        end
        if self.infoList[a1.id].unlocktype ~= self.infoList[a2.id].unlocktype then
            return self.infoList[a1.id].unlocktype < self.infoList[a2.id].unlocktype
        end
        return self.infoList[a1.id].unlockparam < self.infoList[a2.id].unlockparam
    end)

    self.btnList = {}
    for i=1,#funcList do
		-- print("=========================",i)
        local btnNode = cc.Sprite:create("res/image/daily_task/"..funcList[i].name..".png")
        local btnNodeSelected = cc.Sprite:create("res/image/daily_task/"..funcList[i].name.."_selected.png")
        if funcList[i].open == false then
            zc.setGray(btnNode,true)
            zc.setGray(btnNodeSelected,true)
        end
    	local taskIcon = ZCPushButton:createWithParams({
    		normalNode = btnNode,
    		selectedNode = btnNodeSelected,
            needSwallow = false,
            needEnableWhenMoving = true,
            touchSize = cc.size(235,185),
            anchor = cc.p(0, 0.5)
    	})
    	taskIcon:setTouchEndedCallback(function ()
			if funcList[i].id == 88 then
				ZCTOAST("该功能暂未开放，敬请期待！")
				return
			end
            if zc.getUnlockStatus(funcList[i].id, false) == false then
                local RiChangRenWuPop = requires("src/fsgl/layer/RiChangRenWu/RiChangRenWuPop.lua"):create(funcList[i])
                self:addChild(RiChangRenWuPop)
                RiChangRenWuPop:show()
                return
            end
            ----引导
            YinDaoMarg:getInstance():guideTouchEnd() 
            YinDaoMarg:getInstance():releaseGuideLayer()
            ------------------------------------------   
            self:removePointer()
    		funcList[i].callFunc()
        end)
        taskIcon:setScale(0.8)
        if i == 1 then
            local redDot = ZCImage:create("res/image/common/heroList_redPoint.png")
            taskIcon:addChild(redDot)
            redDot:setPosition(50,taskIcon:getContentSize().height - 30)
            redDot:setVisible(RedPointState[16].state == 1)
            self.redDot = redDot
        end
        zc.addEventListener({name = "tempfresh", callback = function (event)--用来刷新等级、经验，银两，银币信息，按钮的显示与隐藏
            self.redDot:setVisible(RedPointState[16].state == 1)
        end})
        local lenth = (scrollHeight-214*2)/3
        --x: (midDis/2+320/2+(midDis/2+320/2)*(i-1)
    	taskIcon:setPosition((i - 1) * taskPicWidth * 0.8, lenth+taskIcon:getBoundingBox().height/2+10) --or scrollHeight-taskIcon:getBoundingBox().height/2+lenth+40)
        local x = taskIcon:getContentSize().width * 1/(#self._showData[i] + 1) 
        if #self._showData[i] == 2 then
            x = taskIcon:getContentSize().width * 1/(#self._showData[i] + 1) - 2
        else
            x = taskIcon:getContentSize().width * 1/(#self._showData[i] + 1) + 15
        end 
        for k,v in pairs(self._showData[i]) do 
            local _item = ItemNode:createWithParams({
                _type_ = v.itemtype, 
                itemId = v.itemid or 0,
                isShowCount = false,
                needSwallow = true,
                isGrey = funcList[i].open == false,
            })
            _item:setScale(0.6)
            taskIcon:addChild(_item)        
            _item:setPosition(x,_item:getBoundingBox().height + 110)
            if #self._showData[i] == 2 then
                x = x + _item:getBoundingBox().width*2
            else
                x = x + _item:getBoundingBox().width + 10
            end   
        end 
        self._scrollview:addChild(taskIcon)
        self.btnList[funcList[i].name] = taskIcon
    end
end

function RiChangRenWuLayer:create(extraFuncID,parent)
	return RiChangRenWuLayer.new(extraFuncID,parent)
end

function RiChangRenWuLayer:onEnter( )
    if self._funcIndex and self._funcIndex ~= 0 then 
        local _func = self:funcNameReflectInFUL(self._funcIndex)
        local target = self:guideTo(_func)
        self._pointer = YinDao:addAHandToTarget( target )
    end 
    self:addGuide()
end

function RiChangRenWuLayer:onExit( )
    self:removePointer()
    zc.removeEventListener("tempfresh")
end
------功能ID映射到功能的枚举名字
function RiChangRenWuLayer:funcNameReflectInFUL(ID)
    if ID == 76 then ----运镖
        return "escort_task"
    elseif ID == 27 then ----装备副本
        return "equip_copies"
    elseif ID == 69 then ----切翡翠
        return "jade_gambling"
    elseif ID == 68 then ----骰子
        return "destiny_dice"
    -- elseif ID == 70 then ----切金矿
    --     return "gold_gambling"
    elseif ID == 77 then ----修罗
        return "arena"
    elseif ID == 75 then ----世界boss
        return "world_boss"
    elseif ID == 71 then ----悬赏任务
        return "offer_reward"
    elseif ID == 25 then ----银两副本
        return "gold_copy"
    elseif ID == 26 then ----翡翠副本
        return "jadite_copy"
    elseif ID == 23 then ----神兽副本
        return "saint_beast"
    elseif ID == 70 then --求签
        return "seek_treasure"
    elseif ID == 80 then -----多人副本
        return "duorenfuben"
	elseif ID == 88 then  --登界游方
        return "servants"
	elseif ID == 87 then  --单挑之王
        return "challenge"
    end 
end

function RiChangRenWuLayer:removePointer( )
    if self._pointer then
        self._pointer:removeFromParent()
        self._pointer = nil
        self._funcIndex = nil
    end          
end

function RiChangRenWuLayer:addGuide( )
    -- local target = nil 
    local _guideGroup,_guideIndex = YinDaoMarg:getInstance():getGuideSteps()
    -- if _guideGroup == 3 and _guideIndex == 3 then 
    --     target = self:guideTo("jade_gambling")
    --     YinDaoMarg:getInstance():addGuide({
    --         parent = self,
    --         target = target,
    --         index = 3,
    --     },3)    
    -- elseif _guideGroup == 7 and _guideIndex == 3 then 
    --     target = self:guideTo("world_boss")
    --     YinDaoMarg:getInstance():addGuide({
    --         parent = self,
    --         target = target,
    --         index = 3,
    --     },7)
    if _guideGroup == 14 and _guideIndex == 3 then 
        YinDaoMarg:getInstance():addGuide({parent = self,index = 3},14)----剧情
        target = self:guideTo("gold_copy")
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 4,
            needNext = false,
        },14)
    elseif _guideGroup == 15 and _guideIndex == 3 then 
        target = self:guideTo("seek_treasure")
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 3,
        },15)
        target = self:guideTo("jadite_copy")
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 8,
        },15)
    elseif _guideGroup == 13 and _guideIndex == 3 then 
        target = self:guideTo("offer_reward")
        YinDaoMarg:getInstance():addGuide({parent = self,index = 3},13)----剧情
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 4,
            needNext = false,
        },13)
    elseif _guideGroup == 18 and _guideIndex == 3 then 
        target = self:guideTo("saint_beast")
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 3,
            needNext = false,
        },18)
    elseif _guideGroup == 16 and _guideIndex == 3 then 
        YinDaoMarg:getInstance():addGuide({parent = self,index = 3},16)----剧情
        target = self:guideTo("destiny_dice")
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 4,
            needNext = false,
        },16)
    elseif _guideGroup == 12 and _guideIndex == 3 then 
        target = self:guideTo("duorenfuben")
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 3,
        },12)
    -- elseif _guideGroup == 20 and _guideIndex == 3 then 
    --     target = self:guideTo("escort_task")
    --     YinDaoMarg:getInstance():addGuide({
    --         parent = self,
    --         target = target,
    --         index = 3,
    --     },20)
    elseif _guideGroup == 19 and _guideIndex == 3 then 
        target = self:guideTo("equip_copies")
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 3,
        },19)
    elseif _guideGroup == 20 and _guideIndex == 3 then 
        target = self:guideTo("arena")
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 3,
        },20)
    end 
    YinDaoMarg:getInstance():doNextGuide()
end

return RiChangRenWuLayer