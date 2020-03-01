--Created By Liuluyang 2015年10月10日
--演武场界面
local RiChangRenWuLayer = class("RiChangRenWuLayer",function ()
    local layer = XTHD.createBasePageLayer()
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
	self._selectedIndex  = 1
	self._isMove = false
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
            XTHD.GodDiceLayer(self._parent)
		end,id = 68},
		[2] = {name = "jade_gambling",callFunc = function ()
			XTHD.createStoneGambling(1)
		end,id = 69},
--		[3] = {name = "arena",callFunc = function ()
--            XTHD.createXiuLuo( self )
--		end,id = 77},
		[3] = {name = "escort_task",callFunc = function ()
            LayerManager.addShieldLayout()
			XTHD.YaYunLiangCaoLayer(self)
		end,id = 76},
		[4] = {name = "world_boss",callFunc = function ()
            LayerManager.createModule( "src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiLayer.lua", {par = self} )            
		end,id = 75},
		[5] = {name = "offer_reward",callFunc = function ()
			requires("src/fsgl/layer/XuanShangRenWu/XuanShangRenWuLayer.lua"):createForLayerManager({node = self})
		end,id = 71},
		[6] = {name = "gold_copy",callFunc = function () 
			XTHD.createGoldCopy(self) ----银两副本
		end,id = 25},
		[7] = {name = "jadite_copy",callFunc = function ()
			XTHD.createJaditeCopy(self)
		end,id = 26},
		[8] = {name = "equip_copies",callFunc = function ()
            XTHD.createEquipCopies(self)
		end,id = 27},
        [9] = {name = "saint_beast",callFunc = function ()
            XTHD.createSaintBeastChapter(self)
        end,id = 23},
        [10] = {name = "seek_treasure",callFunc = function ()
            XTHD.createSeekTreasureLayer(self)
        end,id = 79},
        [11] = {name = "duorenfuben",callFunc = function () ----多人副本
            requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenLayer.lua"):create()
        end,id = 80},
--		[12] = {name = "shipu",callFunc = function ()
--            XTHD.createServantsChapter(self)
--        end,id = 88},
		[12] = {name = "challenge",callFunc = function ()
            XTHD.createChallengeChapter(self)
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
            a1.open = XTHD.getUnlockStatus(a1.id)
        end
        if a2.open == nil then
            a2.open = XTHD.getUnlockStatus(a2.id)
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
            XTHD.setGray(btnNode,true)
            XTHD.setGray(btnNodeSelected,true)
        end
    	local taskIcon = XTHDPushButton:createWithParams({
    		normalNode = btnNode,
    		selectedNode = btnNodeSelected,
            needSwallow = false,
            needEnableWhenMoving = true,
            touchSize = cc.size(235,185),
            anchor = cc.p(0, 0.5)
    	})
    	taskIcon:setTouchEndedCallback(function ()
			if funcList[i].id == 88 then
				XTHDTOAST("该功能暂未开放，敬请期待！")
				return
			end
            if XTHD.getUnlockStatus(funcList[i].id, false) == false then
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
        if i == 4 then
            local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
            taskIcon:addChild(redDot)
            redDot:setPosition(50,taskIcon:getContentSize().height - 30)
            redDot:setVisible(RedPointState[16].state == 1)
            self.redDot = redDot
        end
        XTHD.addEventListener({name = "tempfresh", callback = function (event)--用来刷新等级、经验，银两，银币信息，按钮的显示与隐藏
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

	local btnLablelist = {"开山采矿","凶兽来袭","押运粮草","多人副本","悬赏任务","赏金猎人","趋吉避凶","试炼之塔","六六大顺","神器秘境","镜像之路","神兵阁","修罗炼狱","灵之圣域"}

	local sp = cc.Sprite:create("res/image/illustration/sorttypebg_big2.png")
	Bg:addChild(sp,2)
	sp:setAnchorPoint(0,0.5)
	sp:setContentSize(200, 33)
	sp:setPosition(32,Bg:getContentSize().height - sp:getContentSize().height - 50)
	sp:setVisible(false)
	
	local btnName = XTHDLabel:create(btnLablelist[self._selectedIndex], 18,"res/fonts/def.ttf")
	btnName:setColor(cc.c3b(0,0,0))
	sp:addChild(btnName)
	btnName:setAnchorPoint(0.5,0.5)
	btnName:setPosition(sp:getContentSize().width *0.5,sp:getContentSize().height *0.5)

	local sorttype_up = cc.Sprite:create("res/image/illustration/sorttype_up.png")
	sp:addChild(sorttype_up)
	sorttype_up:setPosition(sp:getContentSize().width - sorttype_up:getContentSize().width * 0.5,sp:getContentSize().height *0.5)

	local sorttype_down = cc.Sprite:create("res/image/illustration/sorttype_down.png")
	sp:addChild(sorttype_down)
	sorttype_down:setPosition(sp:getContentSize().width - sorttype_down:getContentSize().width * 0.5,sp:getContentSize().height *0.5)
	sorttype_down:setFlippedY(true)
	sorttype_down:setVisible(false)
	
	local listView = ccui.ListView:create()
	listView:setAnchorPoint(0,1)
    listView:setContentSize(cc.size(200,#self.funcList*35))
    listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setTouchEnabled(false)
    listView:setScrollBarEnabled(false)
    listView:setBounceEnabled(true)
	listView:setPosition(32,sp:getPositionY() - sp:getContentSize().height*0.5)
	Bg:addChild(listView,2)

	local bg = ccui.Scale9Sprite:create("res/image/illustration/sorttypebg_big.png")
	bg:setAnchorPoint(0.5,0.5)
	listView:addChild(bg)
	bg:setContentSize(200,#self.funcList*35)
	bg:setPosition(listView:getContentSize().width *0.5,listView:getContentSize().height *0.5 + bg:getContentSize().height)

	local drop = function()
		 bg:runAction(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0, -bg:getContentSize().height)),cc.CallFunc:create(function()
			sorttype_up:setVisible(not self._isMove)
			sorttype_down:setVisible(self._isMove)
		end)))
	end

	local goUp = function()
		 bg:runAction(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,bg:getContentSize().height)),cc.CallFunc:create(function()
			sorttype_up:setVisible(not self._isMove)
			sorttype_down:setVisible(self._isMove)
		end)))
	end

	local btn = XTHDPushButton:createWithParams({
		touchSize = Bg:getContentSize(),
        musicFile = XTHD.resource.music.effect_btn_common,
    })
    btn:setPosition(Bg:getContentSize().width/2,Bg:getContentSize().height/2)
    Bg:addChild(btn)
	btn:setVisible(false)
	btn:setTouchBeganCallback(function()
		if self._isMove then
			goUp()
		else
			drop()
		end
		self._isMove = not self._isMove
		btn:setVisible(self._isMove)
		if self._scrollview:getChildByName("tishi") then
			self._scrollview:getChildByName("tishi"):removeFromParent()
		end
	end)
	
    local op_btn = XTHDPushButton:createWithParams({
		touchSize = sp:getContentSize(),
        musicFile = XTHD.resource.music.effect_btn_common,
    })
    op_btn:setPosition(sp:getContentSize().width/2,sp:getContentSize().height/2)
    sp:addChild(op_btn)
	op_btn:setTouchBeganCallback(function()
		if self._isMove then
			goUp()
		else
			drop()
		end
		self._isMove = not self._isMove
		btn:setVisible(self._isMove)
		if self._scrollview:getChildByName("tishi") then
			self._scrollview:getChildByName("tishi"):removeFromParent()
		end
	end)

	
	for i = 1, #self.funcList do
		local normalnode = cc.Sprite:create("res/image/jiban/jibanbg2.png")
		normalnode:setContentSize(cc.size( bg:getContentSize().width,35))
		local selectednode = cc.Sprite:create("res/image/jiban/jibanbg2.png")
		selectednode:setContentSize(cc.size( bg:getContentSize().width,35))
		selectedbtn = XTHD.createButton({
				text = btnLablelist[i],
				btnColor = "write",
				normalNode = normalnode,
				selectedNode = selectednode,
				isScrollView = true,
				fontColor = cc.c3b(0,0,0),
				endCallback = function()
					self:selecedbtnNode(i)
				end
		})
		selectedbtn:setTag(i)
		--selectedbtn:setSwallowTouches(false)
        selectedbtn:setPosition(bg:getContentSize().width/2, bg:getContentSize().height - ((i-1) * 35) - selectedbtn:getContentSize().height *0.5)
        bg:addChild(selectedbtn)
		
	end
end

function RiChangRenWuLayer:selecedbtnNode(i)
	self._selectedIndex = i
	local wid_1  = self._scrollview:getInnerContainerSize().width / #self.funcList
	local num = math.ceil(self:getContentSize().width / wid_1)
	local name = self.funcList[num].name
	local obj = self.btnList[""..self.funcList[num].name]
	local x = obj:getPositionX()
	local y = obj:getPositionY()
	local pos = obj:convertToWorldSpace(cc.p(x,y))
	if pos.x > 1210 and i < num then
		return
	end
	local tag = i - num
	if tag <= 0 then
		tag = 0
	end
	self._scrollview:getInnerContainer():setPosition(-self._scrollview:getInnerContainerSize().width / #self.funcList * tag,0)
	
	if self._scrollview:getChildByName("tishi") then
		self._scrollview:getChildByName("tishi"):removeFromParent()
	end

	pos = obj:getParent():convertToNodeSpace(cc.p(x,y))
	if i > num -1 then
		local tishi = sp.SkeletonAnimation:create("res/spine/guide/yd.json", "res/spine/guide/yd.atlas", 1)
		tishi:setAnimation(0, "animation", true)
		tishi:setPosition(pos.x + obj:getContentSize().width*0.5 - 30,pos.y + obj:getContentSize().height *0.2)
		self._scrollview:addChild(tishi,10)
		tishi:setName("tishi")
	end
end

function RiChangRenWuLayer:create(extraFuncID,parent)
	return RiChangRenWuLayer.new(extraFuncID,parent)
end

function RiChangRenWuLayer:onEnter( )
	musicManager.playMusic(XTHD.resource.music.effect_yanwuchang_bgm )
    if self._funcIndex and self._funcIndex ~= 0 then 
        local _func = self:funcNameReflectInFUL(self._funcIndex)
        local target = self:guideTo(_func)
        self._pointer = YinDao:addAHandToTarget( target )
    end 
    self:addGuide()
end

function RiChangRenWuLayer:onExit( )
	musicManager.playMusic(XTHD.resource.music.music_bgm_main )
    self:removePointer()
    XTHD.removeEventListener("tempfresh")
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
    elseif _guideGroup == 22 and _guideIndex == 3 then 
        target = self:guideTo("escort_task")
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 3,
        },22)
    elseif _guideGroup == 19 and _guideIndex == 3 then 
        target = self:guideTo("equip_copies")
        YinDaoMarg:getInstance():addGuide({
            parent = self,
            target = target,
            index = 3,
        },19)
    -- elseif _guideGroup == 20 and _guideIndex == 3 then 
    --     target = self:guideTo("arena")
    --     YinDaoMarg:getInstance():addGuide({
    --         parent = self,
    --         target = target,
    --         index = 3,
    --     },20)
    end 
    YinDaoMarg:getInstance():doNextGuide()
end

return RiChangRenWuLayer