--[[
单挑之王界面
]]

local JingXiangZhiLuSingleChallengeLayer = class("JingXiangZhiLuSingleChallengeLayer",function( )
	return XTHDDialog:create()
end)

ChallengeType ={
	None = 0,
	Normal = 1,    --普通
	Difficult = 2, --困难
	NightMare = 3, --噩梦
	Purgatory = 4, --炼狱
} 

function JingXiangZhiLuSingleChallengeLayer:onEnter()
	musicManager.playMusic(XTHD.resource.music.effect_jingxiangzhilu_bgm )
end

function JingXiangZhiLuSingleChallengeLayer:onExit()
	musicManager.playMusic(XTHD.resource.music.effect_yanwuchang_bgm )
end


function JingXiangZhiLuSingleChallengeLayer:ctor(data)
    self._chapterData = data
	self:setLevelInfo(data)
	self.listBg = nil
	self._allChapter = gameData.getDataFromCSV("OneVsOne")
	self._normalChapter = {}
	self._diffChapter = {}
	self._nightChapter = {}
	self._purChapter = {}
	self:initChapterData()
	self._propertyIcon = {}
	self._propertyLable = {}
	self._typeBtn = {}
	self._selectTypeIndex = 0  --当前选择的副本类型
	self._selectHeroIndex = 0  --当前选择的英雄关卡索引
    self.selectShadow = {} 
    self.selectTable = {}

	--副本等级限制
	self.typeLimit = {45,50,60,70}

    -- 添加监听事件
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_SINGLECHALLENGE ,callback = function()
        print("挑战成功刷新单挑之王界面")
        self:switchChapter()
        self:freshCurrentChapter()
        self:freshTopInfo()
        self:requestFirstOne(self._selectHeroIndex)
        self:freshRedDot()
    end})

end


function JingXiangZhiLuSingleChallengeLayer:freshCurrentChapter()
    self._chapter:setString("第"..self:findLevelByInstancingid().."关")
    -- for i = 1,#self._curHeroTable do
    --     if self:getLevelByType() >= self:getCurrentChapterData()[self._curHeroTable[i].index].instancingid then
    --         self._curHeroTable[i].level:setVisible(true)
    --         self._curHeroTable[i].pass:setVisible(true)
    --     else
    --         self._curHeroTable[i].level:setVisible(false)
    --         self._curHeroTable[i].pass:setVisible(false)
    --     end
    -- end
    if self:getLevelByType() < self:getCurrentChapterData()[self._selectHeroIndex].instancingid then
        self._sweepOneBtn:setVisible(false)
        self._sweepTenBtn:setVisible(false)
        self._challengeBtn:setPosition(self._rightbg:getContentSize().width/2,self._challengeBtn:getPositionY())
    else
        self._sweepOneBtn:setVisible(true)
        self._sweepTenBtn:setVisible(true)
        self._challengeBtn:setPosition(self._sweepOneBtn:getPositionX() + 135,self._challengeBtn:getPositionY())
    end
end

function JingXiangZhiLuSingleChallengeLayer:setLevelInfo(data)
    gameUser.setNormalChallenge(data["1"])
    gameUser.setDiffChallenge(data["2"])
    gameUser.setNightChallenge(data["3"])
    gameUser.setPurChallenge(data["4"])
end

function JingXiangZhiLuSingleChallengeLayer:getLevelByType()
    if self._selectTypeIndex == ChallengeType.Normal then
        return gameUser.getNormalChalenge()
    elseif self._selectTypeIndex == ChallengeType.Difficult then
        return gameUser.getDiffChalenge()
    elseif self._selectTypeIndex == ChallengeType.NightMare then
        return gameUser.getNightChalenge()
    elseif self._selectTypeIndex == ChallengeType.Purgatory then
        return gameUser.getPurChalenge()
    else 
        return gameUser.getNormalChalenge()
    end
end

function JingXiangZhiLuSingleChallengeLayer:initChapterData()
    for i = 1,#self._allChapter do
        if self._allChapter[i].group == ChallengeType.Normal then
            table.insert(self._normalChapter,self._allChapter[i])
        elseif self._allChapter[i].group == ChallengeType.Difficult then
        	table.insert(self._diffChapter,self._allChapter[i])
        elseif self._allChapter[i].group == ChallengeType.NightMare then
        	table.insert(self._nightChapter,self._allChapter[i])
        elseif self._allChapter[i].group == ChallengeType.Purgatory then
        	table.insert(self._purChapter,self._allChapter[i])
        end
    end
end

function JingXiangZhiLuSingleChallengeLayer:getCurrentChapterData()
	if self._selectTypeIndex == ChallengeType.Normal then
        return self._normalChapter
    elseif self._selectTypeIndex == ChallengeType.Difficult then
    	return self._diffChapter
    elseif self._selectTypeIndex == ChallengeType.NightMare then
    	return self._nightChapter
    elseif self._selectTypeIndex == ChallengeType.Purgatory then
    	return self._purChapter
    else 
    	return self._normalChapter
	end
end

function JingXiangZhiLuSingleChallengeLayer:create(data)
	local layer = JingXiangZhiLuSingleChallengeLayer.new(data)
	if layer then 
		layer:init()
	end
	LayerManager.addLayout(layer)
end

function JingXiangZhiLuSingleChallengeLayer:onCleanup( )	

   XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_SINGLECHALLENGE)
end

function JingXiangZhiLuSingleChallengeLayer:init( )
	local size=self:getContentSize()
    --地图
	local function cellSizeForTable(table,idx)
        return size.width,size.height
    end

    local function numberOfCellsInTableView(table)
    	return math.ceil(#self:getCurrentChapterData()/3)
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end
        print("***************************         "..idx)
        if idx <= 1 or idx >= math.ceil(#self:getCurrentChapterData()/3) - 2 then
             self.listBg:setBounceable(false)
        else
             self.listBg:setBounceable(true)
        end
        local node = self:createCell(idx)
        if node then 
            cell:addChild(node)
            self.selectShadow[idx + 1] = cell
            local nsize=node:getContentSize()
            node:setContentSize(size)
            node:setPosition(size.width/2,size.height/2)
        end 
        return cell
    end

    local view = cc.TableView:create(size)
    TableViewPlug.init(view)
	view.getCellNumbers = numberOfCellsInTableView
	view.getCellSize = cellSizeForTable
    view:setPosition(0,0)
    view:setAnchorPoint(0,0)
    view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    view:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP)
--    view:setInertia(true) --设置惯性
    -- view:setAutoAlign(true)
    view:setDelegate()
    self:addChild(view)

    view:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    view:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    view:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self.listBg = view
    view:reloadData()
    view:scrollToCell(0,false)

	self.topBarHeight =self.topBarHeight or 40

    self:initTopUI()
    self:initLeftUI()
    self:initRightUI()
    self:onTypeBtnClick(1)

end

function JingXiangZhiLuSingleChallengeLayer:createCell(id)
	local pic = cc.Sprite:create("res/image/challenge/dantiaobg1.png")
    pic:setName("pic")
	local heroTable = {}
	--后期要根据不同的副本进行切换
	for i = 1,3 do
		if self:getCurrentChapterData()[3*id + i] then
            --阴影
--            local shadow = cc.Sprite:create("res/image/challenge/yinying_33.png")
--            pic:addChild(shadow)
			local heroBtn = XTHDPushButton:createWithParams({
--	            normalFile = "res/image/avatar/image_"..self:getCurrentChapterData()[3*id + i].bossid..".png",
--	            selectedFile = "res/image/avatar/image_"..self:getCurrentChapterData()[3*id + i].bossid..".png",
	            needEnableWhenOut = true,
	        })   
            local _strid = string.format("%03d", self:getCurrentChapterData()[3*id + i].bossid)
	        local jsonFile = "res/spine/" .. _strid .. ".json"
			local atlasFile = "res/spine/" .. _strid .. ".atlas"
			if _strid ~= 322 and _strid ~= 026 and _strid ~= 042 then
				hero =  sp.SkeletonAnimation:createWithBinaryFile("res/spine/" .. _strid .. ".skel", "res/spine/" .. _strid .. ".atlas", 1.0)
			else
				hero = sp.SkeletonAnimation:create(jsonFile , atlasFile , 1.0)
			end
            hero:setVisible(false)
            hero:setPosition(heroBtn:getContentSize().width / 2 - 5,heroBtn:getContentSize().height/2 - 100)
            hero:setName("heroSpine")
            hero:setAnimation(0, "idle", true)
	        heroBtn:addChild(hero)
            heroBtn:stopActionByTag(10)
            local frame = cc.Sprite:create("res/image/challenge/1.png")
            frame:setName("select"..i)
            pic:addChild(frame)
            frame:setVisible(false)
            if self._selectHeroIndex == 3*id +i then
                frame:setVisible(true)
            end 
            local frameid = 1
            schedule(heroBtn, function()
                frame:initWithFile("res/image/challenge/"..frameid..".png")
                frameid = frameid + 1
                if frameid > 4 then
                    frameid = 1
                end
            end,0.1,10)
            self.selectTable[3*id + i] = frame
            heroBtn:setScale(0.65)
            heroBtn:setTouchSize(cc.size(75,75))
            heroBtn:setTouchBeganCallback(function( )
                heroBtn:setScale(0.55)
            end)
            heroBtn:setTouchEndedCallback(function( )
                self:onHeroBtnClick(3*id + i)
                heroBtn:setScale(0.65)
            end)
            --当前关卡
            local level = XTHDLabel:create("第 "..(3*id + i).." 关",23,"res/fonts/def.ttf")
            level:setColor(cc.c3b(252,255,225))
            level:enableOutline(cc.c4b(55,18,9,255),2)
            pic:addChild(level)
            heroBtn.level = level
            --是否通关
            local pass = XTHDLabel:create("已通关",23,"res/fonts/def.ttf")
            pass:setColor(cc.c3b(55,18,9))
            pic:addChild(pass)
            heroBtn.pass = pass
--            heroBtn.shadow = shadow
            heroBtn.select = frame
            heroBtn.index = 3*id + i
            if self:getLevelByType() >= self:getCurrentChapterData()[3*id + i].instancingid then
                heroBtn.level:setVisible(true)
                heroBtn.pass:setVisible(true)
            else
                heroBtn.level:setVisible(false)
                heroBtn.pass:setVisible(false)
            end
            heroTable[i] = heroBtn
    	end
	end
	if heroTable[1] then
        heroTable[1]:setPosition(self:getContentSize().width/2,self:getContentSize().height/4 - 20)
--        heroTable[1].shadow:setPosition(self:getContentSize().width/2 - 5,self:getContentSize().height/4 - 85)
        heroTable[1].select:setPosition(self:getContentSize().width/2 - 5,self:getContentSize().height/4 - 65)
        heroTable[1].level:setPosition(self:getContentSize().width/2 - 5,self:getContentSize().height/4 + 80)
        heroTable[1].pass:setPosition(self:getContentSize().width/2,self:getContentSize().height/4 - 115)
--        heroTable[1]:getStateNormal():setScaleX(-1)
--        heroTable[1]:getStateSelected():setScaleX(-1)
        heroTable[1]:getChildByName("heroSpine"):setScaleX(-1)
        heroTable[1]:getChildByName("heroSpine"):setScaleX(-1)
        pic:addChild(heroTable[1])
        performWithDelay(heroTable[1], function()
	        heroTable[1]:getChildByName("heroSpine"):setVisible(true)
	    end, 0) 
	end
	if heroTable[2] then
        heroTable[2]:setPosition(self:getContentSize().width/4,self:getContentSize().height/2 + 15)
--        heroTable[2].shadow:setPosition(self:getContentSize().width/4 - 5,self:getContentSize().height/2 - 50)
        heroTable[2].select:setPosition(self:getContentSize().width/4 - 5,self:getContentSize().height/2 - 30)
        heroTable[2].level:setPosition(self:getContentSize().width/4 - 5,self:getContentSize().height/2 + 115)
        heroTable[2].pass:setPosition(self:getContentSize().width/4,self:getContentSize().height/2 - 75)
        pic:addChild(heroTable[2])
        performWithDelay(heroTable[2], function()
	        heroTable[2]:getChildByName("heroSpine"):setVisible(true)
	    end, 0) 
	end
	if heroTable[3] then
        heroTable[3]:setPosition(self:getContentSize().width/2 + 30,self:getContentSize().height/4*3)
--        heroTable[3].shadow:setPosition(self:getContentSize().width/2 + 25,self:getContentSize().height/4*3 - 65)
        heroTable[3].select:setPosition(self:getContentSize().width/2 + 25,self:getContentSize().height/4*3 - 45)
        heroTable[3].level:setPosition(self:getContentSize().width/2 + 25,self:getContentSize().height/4*3 + 100)
        heroTable[3].pass:setPosition(self:getContentSize().width/2 + 30,self:getContentSize().height/4*3 - 95)
--        heroTable[3]:getStateNormal():setScaleX(-1)
--        heroTable[3]:getStateSelected():setScaleX(-1)       
        heroTable[3]:getChildByName("heroSpine"):setScaleX(-1)
        heroTable[3]:getChildByName("heroSpine"):setScaleX(-1) 
        pic:addChild(heroTable[3])
        performWithDelay(heroTable[3], function()
	        heroTable[3]:getChildByName("heroSpine"):setVisible(true)
	    end, 0) 
	end
    self._curHeroTable = heroTable
	return pic
end

function JingXiangZhiLuSingleChallengeLayer:initTopUI()
	-----关闭按钮
	local button = XTHD.createPushButtonWithSound({
		normalFile = "res/image/challenge/dtzwfh_up.png",
		selectedFile = "res/image/challenge/dtzwfh_down.png",
	},3)
	button:setTouchEndedCallback(function( )
		LayerManager.removeLayout()
	end)
	button:setAnchorPoint(1,1)
	self:addChild(button,1)
	button:setPosition(self:getContentSize().width,self:getContentSize().height)
	
	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
		anchor=cc.p(1,1),
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=30});
            self:addChild(StoredValue)
        end,
	})
	self:addChild(help_btn)
	help_btn:setPosition(self:getContentSize().width-320,self:getContentSize().height-4)

	--单挑之王文字
	local textBg = cc.Sprite:create("res/image/challenge/dantiaobg3.png")
	textBg:setPosition(self:getContentSize().width - 135,self:getContentSize().height - 30)
	self:addChild(textBg)
	local textwz = cc.Sprite:create("res/image/challenge/dtzw_icon1.png")
	textwz:setPosition(textBg:getPositionX() - 35,textBg:getPositionY())
	self:addChild(textwz)

	--出征令,银两,翡翠
    local space = 30
    local _iconSRC = {"res/image/challenge/header_taofa.png","res/image/common/common_baozi.png","res/image/common/common_gold.png"}
    local x = 30    
    for i = 1,3 do
        local _barkBG = XTHDPushButton:createWithParams({
            normalFile = "res/image/common/topbarItem_bg.png",
            selectedFile = "res/image/common/topbarItem_bg.png",
            needEnableWhenOut = true,
        })
        _barkBG:setScale(1)
        local _touchSize = _barkBG:getContentSize()
        _barkBG:setTouchSize(cc.size(_touchSize.width,_touchSize.height + 30))
        _barkBG:setTouchBeganCallback(function( )
            _barkBG:setScale(0.9)
        end)
        _barkBG:setTouchMovedCallback(function( )
            _barkBG:setScale(0.9)
        end)
        _barkBG:setTouchEndedCallback(function( )
            _barkBG:setScale(1)
        end)
        _barkBG:setPosition(x + _barkBG:getBoundingBox().width / 2, self:getContentSize().height - _barkBG:getBoundingBox().height / 2 - 10)
        self:addChild(_barkBG)

        local physical_icon = cc.Sprite:create(_iconSRC[i])
        physical_icon:setScale(0.9)
        physical_icon:setPosition(0, _barkBG:getContentSize().height/2)
        _barkBG:addChild(physical_icon)        
        self._propertyIcon[i] = physical_icon

        local _numLabel = getCommonWhiteBMFontLabel("0")
        _numLabel:setPosition(_barkBG:getContentSize().width / 2, physical_icon:getPositionY() - 7)
        _barkBG:addChild(_numLabel)
        self._propertyLable[i] = _numLabel

        local _addButton  = XTHDPushButton:createWithParams({
            normalFile        = "res/image/common/btn/btn_plus_normal.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
            selectedFile      = "res/image/common/btn/btn_plus_selected.png",
            musicFile = XTHD.resource.music.effect_btn_common,
            endCallback       = function()
                self:onAddBtnClick(i)
            end,
        })
        local _size = _addButton:getContentSize()
        _addButton:setAnchorPoint(1,0.5)
        _addButton:setPosition(_barkBG:getContentSize().width + 10, _barkBG:getContentSize().height/2)
        _barkBG:addChild(_addButton)
        _addButton:setTouchSize(cc.size(_addButton:getContentSize().width + 20,_addButton:getContentSize().height))
        _addButton:setTouchSize(cc.size(_size.width + 20,_size.height + 20))
        x = _barkBG:getPositionX() + _barkBG:getBoundingBox().width / 2 + space
    end 
    self:freshTopInfo()
end

function JingXiangZhiLuSingleChallengeLayer:initLeftUI()
	local extralX=0
	if screenRadio>1.8 then
		extralX=25
	end
	--当前关卡
	local chapter_label = XTHDLabel:create("通关进度:",22,"res/fonts/def.ttf")
    chapter_label:setColor(cc.c3b(252,255,225))
	chapter_label:enableOutline(cc.c4b(55,18,9,255),2)
	chapter_label:setAnchorPoint(0,1)
	chapter_label:setPosition(36+extralX,self:getContentSize().height - self.topBarHeight-20)
	self:addChild(chapter_label)

    local chapter = XTHDLabel:create("第1关",20,"res/fonts/def.ttf")
    chapter:enableOutline(cc.c4b(55,18,9,255),2)
	chapter:setAnchorPoint(0,1)
    chapter:setPosition(chapter_label:getPositionX() + 100,chapter_label:getPositionY())
    chapter:setColor(cc.c3b(255,183,0))
    self:addChild(chapter)
    self._chapter = chapter

	self.offsetX = GetScreenOffsetX()

    --排行榜按钮
    local rankBtn = XTHDPushButton:createWithParams({
            normalFile = "res/image/challenge/dtzwph_up.png",
            selectedFile = "res/image/challenge/dtzwph_down.png",
			anchor=cc.p(0,1),
            needEnableWhenOut = true,
        })
    rankBtn:setPosition(chapter_label:getPositionX() - 15 + self.offsetX,chapter_label:getPositionY() - 75)
    rankBtn:setTouchEndedCallback(function( )
		self:onRankBtnClick()
	end)
    self:addChild(rankBtn)
    --福利按钮
    local giftBtn = XTHDPushButton:createWithParams({
            normalFile = "res/image/challenge/dtzwfl_up.png",
            selectedFile = "res/image/challenge/dtzwfl_down.png",
			anchor=cc.p(0,1),
            needEnableWhenOut = true,
        })
    giftBtn:setPosition(rankBtn:getPositionX(),rankBtn:getPositionY() - 100)
    giftBtn:setTouchEndedCallback(function( )
		self:onGiftBtnClick()
	end)
    self:addChild(giftBtn)

    --福利小红点
    local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
    giftBtn:addChild(redDot)
    redDot:setPosition(giftBtn:getBoundingBox().width - 15, giftBtn:getBoundingBox().height - 10)
    redDot:setVisible(true)
    redDot:setScale(0.9)
    self._giftRedDot = redDot

    --挑战难度按钮
    for i = 1,4 do
        local typeBtn = XTHDPushButton:createWithParams({
            normalFile = "res/image/challenge/dtzw"..i.."_up.png",
            selectedFile = "res/image/challenge/dtzw"..i.."_down.png",
			anchor=cc.p(0,1),
            needEnableWhenOut = true,
        })
	    typeBtn:setTouchEndedCallback(function( )
			self:onTypeBtnClick(i)
		end)
	    self:addChild(typeBtn)
        self._typeBtn[i] = typeBtn
    end
    self._typeBtn[1]:setPosition(giftBtn:getPositionX() - 20,self:getContentSize().height/2 - 155)
    self._typeBtn[2]:setPosition(giftBtn:getPositionX() + 60,self:getContentSize().height/2 - 155)
    self._typeBtn[3]:setPosition(giftBtn:getPositionX() - 20,self:getContentSize().height/2 - 225)
    self._typeBtn[4]:setPosition(giftBtn:getPositionX() + 60,self:getContentSize().height/2 - 225)

end

function JingXiangZhiLuSingleChallengeLayer:initRightUI()
	--背景图
	local bg = cc.Sprite:create("res/image/challenge/dantiaobg2.png")
	bg:setScale(0.9)
	bg:setAnchorPoint(1,0.5)
	bg:setPosition(self:getContentSize().width - (12+self.offsetX),self:getContentSize().height/2 - 15)
	self:addChild(bg)
	self._rightbg = bg

    --关卡信息
    local levelbg = cc.Sprite:create("res/image/challenge/dantiaobg5.png")
    bg:addChild(levelbg)
    levelbg:setPosition(bg:getContentSize().width/2 - 57,bg:getContentSize().height - 60)
    local levelText = XTHDLabel:create("第1关",21,"res/fonts/def.ttf")
    levelText:enableOutline(cc.c4b(188,143,143,255),2)
    bg:addChild(levelText)
    levelText:setPosition(levelbg:getPositionX() - 50,levelbg:getPositionY() - 2)
    self._levelText = levelText
    local nameText = XTHDLabel:create("李元霸",20,"res/fonts/def.ttf")
    nameText:setColor(cc.c3b(252,255,225))
    nameText:enableOutline(cc.c4b(55,18,9,255),2)
    nameText:setAnchorPoint(0,0.5)
    bg:addChild(nameText)
    nameText:setPosition(levelText:getPositionX() + 50,levelText:getPositionY())
    self._nameText = nameText

	--首次通关者
	local first_label = XTHDLabel:create("首位通关者:",21,"res/fonts/def.ttf")
	first_label:setColor(cc.c3b(79,44,16))
    bg:addChild(first_label)
    first_label:setPosition(bg:getContentSize().width/2 - 90,levelbg:getPositionY() - 50)
    local name_label = XTHDLabel:create("暂无",21,"res/fonts/def.ttf")
    name_label:setAnchorPoint(0,0.5)
    name_label:setColor(cc.c3b(252,255,225))
    name_label:enableOutline(cc.c4b(55,18,9,255),2)
    bg:addChild(name_label)
    name_label:setPosition(first_label:getPositionX() + 65,first_label:getPositionY())
    self._nameLabel = name_label

    --最快通关者
    local fast_label = XTHDLabel:create("用时最少者:",21,"res/fonts/def.ttf")
    fast_label:setColor(cc.c3b(79,44,16))
    bg:addChild(fast_label)
    fast_label:setPosition(bg:getContentSize().width/2 - 90,first_label:getPositionY() - 30)
    local name_label2 = XTHDLabel:create("暂无",21,"res/fonts/def.ttf")
    name_label2:setAnchorPoint(0,0.5)
    name_label2:setColor(cc.c3b(252,255,225))
    name_label2:enableOutline(cc.c4b(55,18,9,255),2)
    bg:addChild(name_label2)
    name_label2:setPosition(fast_label:getPositionX() + 65,fast_label:getPositionY())
    self._fastnameLabel = name_label2

    --特别奖励按钮
    local specifalBtn = XTHDPushButton:createWithParams({
            normalFile = "res/image/challenge/dtzwtbjl_up.png",
            selectedFile = "res/image/challenge/dtzwtbjl_down.png",
            needEnableWhenOut = true,
        })
    specifalBtn:setScale(0.9)
    specifalBtn:setPosition(name_label:getPositionX() + 150,levelbg:getPositionY() - 5)
    specifalBtn:setTouchEndedCallback(function( )
		self:onSpecifalBtnClick()
	end)
    bg:addChild(specifalBtn)

    local des = XTHDLabel:create("敌人正挥舞着兵刃朝你冲来",21,"res/fonts/def.ttf")
    des:setColor(cc.c3b(55,18,9))
    bg:addChild(des)
    des:setPosition(levelbg:getPositionX() + 50,fast_label:getPositionY() - 35)

    --关卡掉落
    local dropbg = cc.Sprite:create("res/image/challenge/dtzw_icon13.png")
    bg:addChild(dropbg)
    dropbg:setPosition(levelbg:getPositionX() + 5,des:getPositionY() - 40)
    local dropText = cc.Sprite:create("res/image/challenge/dtzw_icon14.png")
    bg:addChild(dropText)
    dropText:setPosition(dropbg:getPositionX() - 10,dropbg:getPositionY())
    local itembg = cc.Sprite:create("res/image/challenge/dantiaobg4.png")
    bg:addChild(itembg)
    itembg:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
    --道具展示滚动框
    local itemView = ccui.ListView:create()
	itemView:setScrollBarEnabled(false)
    itemView:setContentSize(cc.size(280,80))
    itemView:setDirection(ccui.ScrollViewDir.horizontal)
    itemView:setBounceEnabled(true)
    itemView:setPosition(bg:getContentSize().width/2 - 140,bg:getContentSize().height/2 - 40)
    bg:addChild(itemView)
    self._itemList = itemView

    local limit = XTHDLabel:create("本关卡只允许李元霸上场",18,"res/fonts/def.ttf")
    limit:setColor(cc.c3b(223,44,22))
    limit:setAnchorPoint(0,0.5)
    limit:setDimensions(280,70)
    limit:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    limit:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    bg:addChild(limit)
    limit:setPosition(bg:getContentSize().width/2 - 135,itembg:getPositionY() - 65)
    self._limitText = limit

    --扫荡和挑战按钮
    local sweepOneBtn = XTHDPushButton:createWithParams({
            normalFile = "res/image/challenge/dtzwsd_up.png",
            selectedFile = "res/image/challenge/dtzwsd_down.png",
            needEnableWhenOut = true,
        })
    sweepOneBtn:setPosition(itembg:getPositionX() - 60,itembg:getPositionY() - 120)
    sweepOneBtn:setTouchEndedCallback(function( )
		self:onSweepBtnClick(1)
	end)
    bg:addChild(sweepOneBtn)
    self._sweepOneBtn = sweepOneBtn

    local sweepTenBtn = XTHDPushButton:createWithParams({
            normalFile = "res/image/challenge/dtzwsd10_up.png",
            selectedFile = "res/image/challenge/dtzwsd10_down.png",
            needEnableWhenOut = true,
        })
    sweepTenBtn:setPosition(sweepOneBtn:getPositionX(),sweepOneBtn:getPositionY() - 75)
    sweepTenBtn:setTouchEndedCallback(function( )
		self:onSweepBtnClick(10)
	end)
    bg:addChild(sweepTenBtn)
    self._sweepTenBtn = sweepTenBtn

    local challengeBtn = XTHDPushButton:createWithParams({
            normalFile = "res/image/challenge/dtzwtz_up.png",
            selectedFile = "res/image/challenge/dtzwtz_down.png",
            needEnableWhenOut = true,
        })
    challengeBtn:setPosition(sweepOneBtn:getPositionX() + 135,sweepOneBtn:getPositionY() - 40)
    challengeBtn:setTouchEndedCallback(function( )
		self:onChallengeBtnClick()
	end)
    bg:addChild(challengeBtn)
    self._challengeBtn = challengeBtn

    --消耗出征令
	local cicon = cc.Sprite:create("res/image/challenge/header_taofa.png")
    cicon:setScale(1)
    bg:addChild(cicon,1)
    cicon:setPosition(sweepTenBtn:getPositionX() - 30,sweepTenBtn:getPositionY() - 40)
	self._cicon = cicon
    local kuang = cc.Sprite:create("res/image/challenge/dantiaobg6.png")
    bg:addChild(kuang)
    kuang:setPosition(cicon:getPositionX() + 30,cicon:getPositionY())
    local count = XTHDLabel:create("50",18,"res/fonts/def.ttf")
    bg:addChild(count)
    count:setPosition(kuang:getPositionX() + 6,kuang:getPositionY())
	self._xhCount = count

end

--刷新顶部信息
function JingXiangZhiLuSingleChallengeLayer:freshTopInfo()
	local base = 1000000
	self._propertyLable[1]:setString(XTHD.resource.getItemNum(2309))   --出征令
	if gameUser.getGold() > gameUser.getPreGold() then 
        letTheLableTint(self._propertyLable[2],true)
    elseif gameUser.getGold() < gameUser.getPreGold() then 
        letTheLableTint(self._propertyLable[2],false)
    end 
    gameUser.setPreGold(gameUser.getGold())
    self._propertyLable[2]:setString(getHugeNumberWithLongNumber(gameUser.getTiliNow(),base)) --体力   

    if gameUser.getFeicui() > gameUser.getPreFeicui() then 
        letTheLableTint(self._propertyLable[3],true)
    elseif gameUser.getFeicui() < gameUser.getPreFeicui() then 
        letTheLableTint(self._propertyLable[3],false)
    end 
    gameUser.setPreFeicui(gameUser.getFeicui())
    self._propertyLable[3]:setString(getHugeNumberWithLongNumber(gameUser.getIngot(),base)) --元宝
end

--刷新掉落信息
function JingXiangZhiLuSingleChallengeLayer:freshItemList(id)
	self._itemList:removeAllChildren()
	local itemStr = string.split(self:getCurrentChapterData()[id].items,'#')
	for i = 1,#itemStr do
	    local layout = ccui.Layout:create()
	    layout:setContentSize(cc.size(self._itemList:getContentSize().width/4,self._itemList:getContentSize().height))
        local icon = ItemNode:createWithParams({
            _type_ = 4,
            itemId = itemStr[i],
        })
        layout:addChild(icon)
        icon:setPosition(layout:getContentSize().width/2,layout:getContentSize().height/2)
        icon:setScale(0.7)
    	self._itemList:pushBackCustomItem(layout)
	end
    
end

--刷新右侧关卡信息
function JingXiangZhiLuSingleChallengeLayer:freshChapterInfo(id)
    self._chapter:setString("第"..self:findLevelByInstancingid().."关")
    self._levelText:setString("第"..id.."关")
    self._nameText:setString(self:getCurrentChapterData()[id].name)
    self._limitText:setString("本关卡只允许"..self:getCurrentChapterData()[id].description.."上场")

	if self:getLevelByType() >= self:getCurrentChapterData()[id].instancingid then
		self._cicon:setTexture("res/image/challenge/header_taofa.png")
		self._xhCount:setString("1")
	else
		self._cicon:setTexture("res/image/common/common_baozi.png")
		self._xhCount:setString("50")
	end

    --没挑战过本关则隐藏
    if self:getLevelByType() < self:getCurrentChapterData()[id].instancingid then
        self._sweepOneBtn:setVisible(false)
        self._sweepTenBtn:setVisible(false)
        self._challengeBtn:setPosition(self._rightbg:getContentSize().width/2,self._challengeBtn:getPositionY())
    else
        self._sweepOneBtn:setVisible(true)
        self._sweepTenBtn:setVisible(true)
        self._challengeBtn:setPosition(self._sweepOneBtn:getPositionX() + 135,self._challengeBtn:getPositionY())
    end
    
	self:freshItemList(id)
end

function JingXiangZhiLuSingleChallengeLayer:findLevelByInstancingid()
    for i = 1,#self:getCurrentChapterData() do
        if self:getLevelByType() == self:getCurrentChapterData()[i].instancingid then
            return i
        end
    end
    return 0
end

function JingXiangZhiLuSingleChallengeLayer:findCellIdByLevel()
    local level = self:findLevelByInstancingid()
    if level == 0 then
        return 0
    else
        return math.ceil(level/3) - 1
    end
end

--副本跳转
function JingXiangZhiLuSingleChallengeLayer:switchChapter()
	--刷新失败则return
    --跳转到挑战进度
    self:jumpToCurLevel()
	self._selectHeroIndex = -1
	self:onHeroBtnClick(math.max(self:findLevelByInstancingid(),1))
end

--判断是否具有挑战条件
function JingXiangZhiLuSingleChallengeLayer:isCanChallenge()
    --先判断出征令够不够
--    if XTHD.resource.getItemNum(2309) < 1 then
--		local _dialog = XTHDConfirmDialog:createWithParams({
--			msg = "您的出征令不足，是否购买该道具？",
--			rightCallback = function()
--				self:tipDialog()
--			end
--		})
--		self:addChild(_dialog)
--		return false
--	end
	--判断有没有通关上一关卡
    if self._selectHeroIndex > self:findLevelByInstancingid() + 1 then
        XTHDTOAST("请先通过上一关卡！")
        return false
    end
    --再判断是否有相关英雄
	local _heroData = DBTableHero.getData(gameUser.getUserId())
	-- print("玩家身上的英雄数据为：")
	-- print_r(_heroData)
    local heroLimit = string.split(self:getCurrentChapterData()[self._selectHeroIndex].value1,'#')
    local length = #heroLimit
    local temp = {}
    local nonhero = {}
    local isCan = 0
    for i = 1,length do
        temp[i] = 0
        for k,v in pairs(_heroData) do
            if tonumber(heroLimit[i]) == v.heroid then
                isCan = isCan + 1
                temp[i] = 1
            end
        end
        if temp[i] == 0 then
            table.insert(nonhero,heroLimit[i])
        end
    end
    -- print("IsCan:"..isCan.."       length:"..length)
    -- print_r(nonhero)
    if isCan < length then
        local tip = ""
        for j = 1,#nonhero do
            tip = tip..gameData.getDataFromCSV("GeneralInfoList",{heroid = tonumber(nonhero[j])}).name..","
        end
        XTHDTOAST("您还缺少"..tip.."无法进行挑战！")
        return false
    else
        return true
    end
end

function JingXiangZhiLuSingleChallengeLayer:onTypeBtnClick(id)
	if self._selectTypeIndex == id then
        return
	end
	--条件限制判断
	print("按下了"..id.."副本按钮")
	--切换副本
	--判断等级是够是否达到
	if gameUser.getLevel() < self.typeLimit[id] then
		XTHDTOAST("开启该难度，需将角色等级提升至"..self.typeLimit[id].."级！")
		return
	end
	self._selectTypeIndex = id
	self:switchChapter()
    self:freshRedDot()
	for i = 1,4 do
        if i == id then
            XTHD.setGray(self._typeBtn[i]:getStateNormal(),false)
            XTHD.setGray(self._typeBtn[i]:getStateSelected(),false)
        else
            XTHD.setGray(self._typeBtn[i]:getStateNormal(),true)
            XTHD.setGray(self._typeBtn[i]:getStateSelected(),true)
        end
	end

end

function JingXiangZhiLuSingleChallengeLayer:onHeroBtnClick(id)
	if self._selectHeroIndex == id then
        return
	end
	--条件限制判断
    print("点击了"..id.."英雄按钮")
	self._selectHeroIndex = id
    for i = 1,#self.selectShadow do
        if self.selectShadow[i] then
            for j = 1,3 do
                if self.selectShadow[i]:getChildByName("pic"):getChildByName("select"..j) then
                    self.selectShadow[i]:getChildByName("pic"):getChildByName("select"..j):setVisible(false)
                end
            end
        end
    end
    self.selectTable[id]:setVisible(true)
    --刷新右侧信息
    self:requestFirstOne(id)
	self:freshChapterInfo(id)
end

function JingXiangZhiLuSingleChallengeLayer:onRankBtnClick()
	print("点击了排行榜按钮")
    HttpRequestWithOutParams("singleEctypeTop",function (data)
         -- print("单挑之王排行榜服务器返回的数据为：")
         -- print_r(data)
        requires("src/fsgl/layer/JingXiangZhiLu/JingXiangZhiLuChallengeRankLayer.lua"):create(data,self._selectTypeIndex)
    end)  
end

function JingXiangZhiLuSingleChallengeLayer:onGiftBtnClick()
	print("点击了福利按钮")
    HttpRequestWithParams("openEctypePassReward",{type = self._selectTypeIndex},function (data)
        -- print("单挑之王福利服务器返回的数据为：")
        -- print_r(data)
        local giftLayer = requires("src/fsgl/layer/JingXiangZhiLu/JingXiangZhiLuChallengeGiftLayer.lua"):create(data,self._selectTypeIndex,self:findLevelByInstancingid(),function ()
            self:freshRedDot()
        end)
        self:addChild(giftLayer,1)
    end)
end

function JingXiangZhiLuSingleChallengeLayer:onSpecifalBtnClick()
	print("点击了特别奖励按钮")
	 HttpRequestWithParams("singleRecord",{configId = self:getCurrentChapterData()[self._selectHeroIndex].instancingid},function (data)
--        print("单挑之王首次通关者数据为：")
--        print_r(data)
		local sdata = self:getCurrentChapterData()[self._selectHeroIndex].especially
		local specifalGiftLayer = requires("src/fsgl/layer/JingXiangZhiLu/JingXiangZhiLuSpecifalGiftLayer.lua"):create(sdata,data,self:getCurrentChapterData()[self._selectHeroIndex].instancingid)
		self:addChild(specifalGiftLayer,1)
    end) 
end

function JingXiangZhiLuSingleChallengeLayer:onSweepBtnClick(num)
	print("点击了扫荡"..num.."次按钮")
	if XTHD.resource.getItemNum(2309) < num then
		local _dialog = XTHDConfirmDialog:createWithParams({
			msg = "您的讨伐令不足，是否购买该道具？",
			rightCallback = function()
				self:tipDialog()
			end
		})
		self:addChild(_dialog)
		return false
	end
    HttpRequestWithParams("sweepSingleEctype",{ectypeId=self:getCurrentChapterData()[self._selectHeroIndex].instancingid,times=num},function (data)
        -- print("单挑之王扫荡服务器返回的数据为：")
        -- print_r(data)
        local playerProperty = data["property"]
        if playerProperty then
            for i=1,#playerProperty do
                local pro_data = string.split( playerProperty[i],',')
                  DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
            end
        end
         --更新数据库稍微延时了，刷新数据的时候，没有及时更新到数据 yanyuling
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
        local LiLianSweepPopLayer = requires("src/fsgl/layer/LiLian/LiLianSweepPopLayer.lua"):create(data)
        self:addChild(LiLianSweepPopLayer,2)
        LiLianSweepPopLayer:setHideCallback()
        self:freshTopInfo()
        XTHD.dispatchEvent({name = "EVENT_LEVEUP"}) 
    end)
end

function JingXiangZhiLuSingleChallengeLayer:onChallengeBtnClick()
	print("点击了挑战按钮")
    if self:isCanChallenge() then
		local _dialog = XTHDConfirmDialog:createWithParams({
			msg = "是否消耗50点体力进行挑战？",
			rightCallback = function()
				LayerManager.addShieldLayout()
				local _tab = {instancingid = self:getCurrentChapterData()[self._selectHeroIndex].instancingid, battle_type = BattleType.SINGLECHALLENGE, stageData = self:getCurrentChapterData()[self._selectHeroIndex]}
				local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):createWithParams( _tab )
				fnMyPushScene(_layer)
			end
		})
		self:addChild(_dialog)
    end
end

function JingXiangZhiLuSingleChallengeLayer:onAddBtnClick(index)
	if not index then 
        return 
    end 
    if index == 1 then ----出征令
		self:tipDialog()
    elseif index == 2 then
		local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=2})
		self:addChild(layer)
	elseif index == 3 then
		XTHD.createRechargeVipLayer( self)
    end 
end

--请求首次通关者
function JingXiangZhiLuSingleChallengeLayer:requestFirstOne(id)
    HttpRequestWithParams("singleRecord",{configId = self:getCurrentChapterData()[id].instancingid},function (data)
		-- print("服务器返回的首位通关者数据为：")
		-- print_r(data)
        if data.fristPass ~= "" then
            self._nameLabel:setString(data.fristPass)
        else 
            self._nameLabel:setString("暂无")
        end
        if data.minTime ~= "" then
            self._fastnameLabel:setString(data.minTime)
        else
            self._fastnameLabel:setString("暂无")
        end
    end) 
end

--跳转到挑战进度
function JingXiangZhiLuSingleChallengeLayer:jumpToCurLevel()
    local cellID = self:findCellIdByLevel()
    -- print("镜像之路跳转的id："..cellID)
    self.listBg:reloadData()
    self.listBg:scrollToCell(cellID,false)
    if self.listBg:getCurrentPage() <= math.min(cellID + 1,math.ceil(#self:getCurrentChapterData())/3 - 1) and self.listBg:getCurrentPage() >= math.max(cellID - 1,0) then
        if cellID <= 1 then
            self.listBg:scrollToCell(3,false)
            self.listBg:scrollToCell(cellID,false)
        elseif cellID >= math.ceil(#self:getCurrentChapterData())/3 - 2 then
            self.listBg:scrollToCell(math.ceil(#self:getCurrentChapterData())/3 - 4,false)
            self.listBg:scrollToCell(cellID,false)
        else
            self.listBg:scrollToCell(cellID - 2,false)
            self.listBg:scrollToCell(cellID,false)
        end
    else
        self.listBg:scrollToCell(cellID,true)
    end
end

--刷新福利小红点
function JingXiangZhiLuSingleChallengeLayer:freshRedDot()
    -- print("刷新福利小红点")
    HttpRequestWithParams("openEctypePassReward",{type = self._selectTypeIndex},function (data)
        local isNew = false
        for i = 1,#data.list do
            if data.list[i].state == 1 then
                isNew = true
            end
        end
        self._giftRedDot:setVisible(false)
        if isNew then
            self._giftRedDot:setVisible(true)
        end
    end)
end

--出征令不足提示
function JingXiangZhiLuSingleChallengeLayer:tipDialog()
	self.buyType = 3
	self.data = {num = 1,ingotprice = 50}
	local popLayer = requires("src/fsgl/layer/YingXiong/BuyExpByIngotPopLayer1.lua")
	popLayer= popLayer:create(2309,self)
	popLayer:setName("BuyExpPop")
	self:addChild(popLayer)
end

return JingXiangZhiLuSingleChallengeLayer