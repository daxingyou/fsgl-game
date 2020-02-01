local BianQiangLayer = class("BianQiangLayer", function (...) 
    return XTHD.createPopLayer()
end)
--SheZhiLayer.__index = SheZhiLayer

function BianQiangLayer:ctor()
    self._fighting = 0         --战斗力
    self._TJfighting = 300000       --推荐战斗力
	self._ListData = gameData.getDataFromCSV("BecomestrongerA")
    self._maxZLList = {}

    self._curZLList = {}
	
	for i = 1, #self._ListData do
		self._maxZLList[i] = self._ListData[i].credits
	end
	local score = self._ZhanDouLiData.score
	print("=========================",#score)
	for i = 1,14 do
		self._curZLList[i] = self._ZhanDouLiData.score[tostring(i)]
	end

    local n = 0
    for i = 1,#self._curZLList do
        n = n+self._curZLList[i]
    end
    self._fighting = n

    local bg = cc.Sprite:create("res/image/Strengthen/bg_1.png")
    self:addContent(bg)
    bg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height / 2))
    self.bg = bg
	self.bg:setScale(0.9)

    local listview = ccui.ListView:create()
    listview:setContentSize(cc.size(self.bg:getContentSize().width,self.bg:getContentSize().height - 90))
    listview:setDirection(ccui.ScrollViewDir.vertical)
    listview:setScrollBarEnabled(false)
    listview:setBounceEnabled(true)
    listview:setAnchorPoint(0.5,0.5)
    listview:setPosition(self.bg:getContentSize().width / 2,self.bg:getContentSize().height / 2 - 45)
    self.bg:addChild(listview)
    self._listview = listview

    local zhanlibg = ccui.Scale9Sprite:create("res/image/Strengthen/bg_2.png")
    self.bg:addChild(zhanlibg)
    zhanlibg:setContentSize(self.bg:getContentSize().width,zhanlibg:getContentSize().height*1 + 10)
    zhanlibg:setPosition(cc.p(self.bg:getContentSize().width / 2,self.bg:getContentSize().height - zhanlibg:getContentSize().height / 2 - 15))
    self._zhanlibg = zhanlibg

	for i = 1,3 do
		local sp = cc.Sprite:create("res/image/Strengthen/pingfji_0" .. i .. ".png")
		self._zhanlibg:addChild(sp)
		sp:setPosition(90 + (i -1)*(self._zhanlibg:getContentSize().width / 3),self._zhanlibg:getContentSize().height / 2)
	end

    local bgkuang = cc.Sprite:create("res/image/Strengthen/bianqiangbg01.png")
    self.bg:addChild(bgkuang)
    bgkuang:setPosition(cc.p(self.bg:getContentSize().width / 2,self.bg:getContentSize().height / 2 + 12))

    local _biaoti = cc.Sprite:create("res/image/Strengthen/bqlogo01.png")
    self.bg:addChild(_biaoti)
    _biaoti:setPosition(cc.p(self.bg:getContentSize().width / 2,self.bg:getContentSize().height + 2))

    --关闭按钮
    local btn_close = XTHDPushButton:createWithParams({
        normalFile        = "res/image/Strengthen/closebtn.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = "res/image/Strengthen/closebtn.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        touchScale = 0.9,
        endCallback       = function()
            self:hide()
        end,
    })
    self.bg:addChild(btn_close)
    btn_close:setPosition(cc.p(self.bg:getContentSize().width + btn_close:getContentSize().width / 2 - 5,
                            self.bg:getContentSize().height - btn_close:getContentSize().height /2 + 5))
    self._btn_close = btn_close


    local n = 6
    if self._fighting >= 250000 then
        n = 1
    elseif self._fighting < 250000 and self._fighting >= 200000 then 
        n = 2
    elseif self._fighting < 200000 and self._fighting >= 110000 then 
        n = 3
    elseif self._fighting < 110000 and self._fighting >= 60000 then
        n = 4
    elseif self._fighting < 60000 and self._fighting >= 20000 then
        n = 5
    else
        n = 6
    end

    local grade = cc.Sprite:create("res/image/Strengthen/pingfen_".. n ..".png")
    grade:setAnchorPoint(cc.p(0,0.5))
    self._zhanlibg:addChild(grade)
    grade:setPosition(cc.p(self._zhanlibg:getContentSize().width - grade:getContentSize().width / 2 - 65,
                            self._zhanlibg:getContentSize().height / 2))

    local _fightingLable = XTHDLabel:createWithParams({
        text = tostring(self._fighting),
        fontSize = 26,
        color = cc.c3b(255,255,255),
    })
    _fightingLable:setAnchorPoint(cc.p(0,0.5))
    self._zhanlibg:addChild(_fightingLable)
    _fightingLable:setPosition(cc.p(self._zhanlibg:getContentSize().width / 3 - _fightingLable:getContentSize().width, self._zhanlibg:getContentSize().height / 2))
    self._fightingLable = _fightingLable

    local _TJfightingLable = XTHDLabel:createWithParams({
        text = tostring(self._TJfighting),
        fontSize = 26,
        color = cc.c3b(255,255,255),
    })
    _TJfightingLable:setAnchorPoint(cc.p(0,0.5))
    self._zhanlibg:addChild(_TJfightingLable)
    _TJfightingLable:setPosition(cc.p(self._zhanlibg:getContentSize().width / 3 * 2 - _TJfightingLable:getContentSize().width+5, self._zhanlibg:getContentSize().height / 2))
    self._TJfightingLable = _TJfightingLable

    self:AddCell()
end

function BianQiangLayer:AddCell( ... )
    for i = 1,#self._ListData do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(self.bg:getContentSize().width,90))

        local cellbg = cc.Sprite:create("res/image/Strengthen/cellbg.png")
        layout:addChild(cellbg)
        cellbg:setAnchorPoint(cc.p(0.5,0.5))
        cellbg:setPosition(cellbg:getContentSize().width / 2 +15,layout:getContentSize().height / 2)

        local button = XTHD.createPushButtonWithSound({
            normalFile = "res/image/Strengthen/gobtn_1.png",
            selectedFile = "res/image/Strengthen/gobtn_2.png",
			isScrollView = true,
        })
        
        layout:addChild(button)
        button:setTag(i)
        button:setTouchEndedCallback(function( )
            self:GoNextScene(button:getTag())
        end)
        button:setPosition(cellbg:getContentSize().width - button:getContentSize().width / 2 - 20,cellbg:getContentSize().height / 2)
        local spr = cc.Sprite:create("res/image/Strengthen/icon_" .. i ..".png")
        cellbg:addChild(spr)
        spr:setAnchorPoint(cc.p(0.5,0.5))
        spr:setPosition(cc.p(spr:getContentSize().width/2 + 15,cellbg:getContentSize().height / 2))

        local spr_2 = cc.Sprite:create("res/image/Strengthen/bg_4.png")
        cellbg:addChild(spr_2)
        spr_2:setAnchorPoint(cc.p(0.5,0.5))
        spr_2:setPosition(cc.p(spr:getPositionX() + spr_2:getContentSize().width/2 + spr:getContentSize().width / 2 + 20,cellbg:getContentSize().height - 20))

        local bar_bg = cc.Sprite:create("res/image/Strengthen/login_loading_bar_bg.png")
        cellbg:addChild(bar_bg)
        bar_bg:setScale(0.9)
        bar_bg:setAnchorPoint(0.5,1)
        bar_bg:setScale(0.5)
        bar_bg:setPosition(cellbg:getContentSize().width / 2-70,cellbg:getContentSize().height / 2 - 5)

        ---经验进度条
        local _progress_timer = cc.ProgressTimer:create(cc.Sprite:create("res/image/Strengthen/login_loading_bar.png"))
        _progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        _progress_timer:setMidpoint(cc.p(0, 0))
        _progress_timer:setBarChangeRate(cc.p(1, 0))
        _progress_timer:setPosition(bar_bg:getContentSize().width/2, bar_bg:getContentSize().height/2)
        bar_bg:addChild(_progress_timer)
        local percentage = self._curZLList[i] / self._maxZLList[i] * 100
        _progress_timer:setPercentage(percentage)

        --英雄品质  英雄等级 技能 兵书  羁绊  强化  升星  神器  心法  修炼  玄符  装备
        local cellName = XTHDLabel:createWithParams({
            text = self._ListData[i].itemname,
            fontSize = 20,
            color = XTHD.resource.btntextcolor.write 
        })
        cellName:enableOutline(cc.c4b(0,0,0,0),2)
        cellName:setAnchorPoint(0,0.5)
        spr_2:addChild(cellName)
        cellName:setPosition(cc.p(20,spr_2:getContentSize().height / 2))
        self._listview:pushBackCustomItem(layout)
		
		local _text,_color = self:getTextAndColor(i)		
		local lable = XTHDLabel:create(_text, 18, "res/fonts/def.ttf")
		lable:setColor(_color)
		lable:setAnchorPoint(0,0.5)
		lable:setPosition(spr_2:getPositionX() + spr_2:getContentSize().width / 2 + 20,spr_2:getPositionY())
		cellbg:addChild(lable)

		local curPro = math.floor(self._curZLList[i] / self._maxZLList[i] * 100)
		local text = tostring(curPro) .. "％"
		local curProLable = XTHDLabel:create(text, 18, "res/fonts/def.ttf")
		curProLable:setColor(_color)
		curProLable:setAnchorPoint(0,0.5)
		curProLable:setPosition(bar_bg:getContentSize().width / 2 + 115,bar_bg:getPositionY() - 12)
		cellbg:addChild(curProLable)
    end 
end

function BianQiangLayer:GoNextScene( index )
    if index == 1 then
        local _layer = requires("src/fsgl/layer/YingXiong/YingXiongLayer.lua"):create()
        LayerManager.addLayout(_layer)
    elseif index ==2 then
        local _layer = requires("src/fsgl/layer/YingXiong/YingXiongLayer.lua"):create()
        LayerManager.addLayout(_layer)
    elseif index ==3 then
        local _layer = requires("src/fsgl/layer/YingXiong/YingXiongLayer.lua"):create()
        LayerManager.addLayout(_layer)
    elseif index == 4 then
        local _layer = requires("src/fsgl/layer/YingXiong/YingXiongLayer.lua"):create()
        LayerManager.addLayout(_layer)
    elseif index == 5 then
		local _layer = requires("src/fsgl/layer/YingXiong/YingXiongLayer.lua"):create()
        LayerManager.addLayout(_layer)
        --XTHD.showJiBanLayer()
    elseif index == 6 then
		local _layer = requires("src/fsgl/layer/YingXiong/YingXiongLayer.lua"):create()
        LayerManager.addLayout(_layer)
--        YinDaoMarg:getInstance():guideTouchEnd()
--        XTHD.createEquipLayer(nil,nil,nil)
    elseif index == 7 then
		local _layer = requires("src/fsgl/layer/YingXiong/YingXiongLayer.lua"):create()
		LayerManager.addLayout(_layer)
--        YinDaoMarg:getInstance():guideTouchEnd()
--        XTHD.createEquipLayer(nil,nil,2)
    elseif index == 8 then
		if gameUser.getLevel() >= 42 then
         YinDaoMarg:getInstance():guideTouchEnd()
         XTHD.createBibleLayer(self)
        else
            XTHDTOAST("玩家等级达到42级开启修炼功能")
        end
--		local hangup = requires("src/fsgl/layer/BiGuan/BiGuanLayer.lua"):create({which = 'yingliang',data = data})
--        LayerManager.addLayout(hangup)
        --self:enterArtifact()
    elseif index == 9 then
		XTHD.showJiBanLayer()
--        local _layer = requires("src/fsgl/layer/YingXiong/YingXiongLayer.lua"):create()
--        LayerManager.pushModule(_layer)
    elseif index == 10 then
		local _isOpen, _prompt = isTheFunctionAvailable(4)
		--_isOpen = true
		--if _isOpen then
			self:enterArtifact()
		--else
		--	XTHDToast(_prompt)
		--end
--		YinDaoMarg:getInstance():guideTouchEnd()
--        XTHD.createEquipLayer(nil,nil,nil)
        --self._parent:openXXSJ()
    elseif index == 11 then
        self:enterArtifact()
    elseif index == 12 then
        YinDaoMarg:getInstance():guideTouchEnd()
        XTHD.createEquipLayer(nil,nil,nil)
	elseif index == 13 then
		YinDaoMarg:getInstance():guideTouchEnd()
		XTHD.createEquipLayer(nil,nil,nil)
	elseif index == 14 then
		YinDaoMarg:getInstance():guideTouchEnd()
        XTHD.createEquipLayer(nil,nil,nil)
    end
end

function BianQiangLayer:enterArtifact(  )
     local isOpen,data = isTheFunctionAvailable(35)    
    if not isOpen then 
        XTHDTOAST(data.tip)
        return 
    end 
    local ownArtifact = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ARTIFACT)
    if ownArtifact and ownArtifact.godid then
        ownArtifact = {ownArtifact}
    end
    if #ownArtifact > 0 then 
        --主城界面选择神器
        local function getArtifact()
            local artifactData = gameData.getDataFromCSV("SuperWeaponUpInfo")
            table.sort(ownArtifact, function(a,b)
                if tonumber(artifactData[a.templateId].rank) == tonumber(artifactData[b.templateId].rank) then
                    return tonumber(artifactData[a.templateId]._type) < tonumber(artifactData[b.templateId]._type)
                else
                    return tonumber(artifactData[a.templateId].rank) > tonumber(artifactData[b.templateId].rank)
                end
            end)
            return ownArtifact[1].godid
        end
        local gid = getArtifact()
        XTHD.createArtifact(nil,nil, gid , nil)
    else 
        XTHDTOAST(LANGUAGE_TIPS_WORDS4)        
    end     
end

function BianQiangLayer:GotoHeroInfoLayer( _key )
    local dynamicEquipmentData = DBTableEquipment:getDataByID()
    -- dump(dynamicEquipmentData,"777777777777777")
    local _temp_data = HeroDataInit:InitHeroDataAllOwnHero()
    --获取当前所有已经装备上的信息
    local _equipmentData = {}
    for k,v in pairs(dynamicEquipmentData) do
        if not _equipmentData[tostring(v.heroid)] or next(_equipmentData[tostring(v.heroid)])==nil then
            _equipmentData[tostring(v.heroid)] = {}
        end
        _equipmentData[tostring(v.heroid)][#_equipmentData[tostring(v.heroid)]+1] = clone(v)
    end
    --组合成英雄数据
    self.m_herosData = {}
    for k,v in pairs(_temp_data) do
        v.equipments = {}
        v.equipments = _equipmentData[tostring(k)] or {}
        self.m_herosData[#self.m_herosData+1] = v
    end
    self:SortForMyHeroData()

    local dynamicItemData = {}
    dynamicItemData = DBTableItem:getDataByID()
    local staticItemData = {}
    staticItemData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
    local items_pairs = {}
    local items_data = {}
    items_pairs = dynamicItemData or {}
    local _EquipmentTable = gameData.getDataFromCSVWithPrimaryKey("EquipInfoList")
    for i,var in pairs(items_pairs) do
        items_data[tostring(var["dbid"])] = {}
        items_data[tostring(var["dbid"])] = var
        items_data[tostring(var["dbid"])].level = staticItemData[tostring(var["itemid"])] and staticItemData[tostring(var["itemid"])].levelfloor or 0
        items_data[tostring(var["dbid"])].resourceid = staticItemData[tostring(var["itemid"])] and staticItemData[tostring(var["itemid"])].resourceid or 0
        local _data_ = _EquipmentTable[tostring(var["itemid"])] or {}
        local _equipmentData = {
                                herotype = _data_.herotype or 1
                                ,equippos = _data_.equippos or 0
                            }
        items_data[tostring(var["dbid"])].equipment = _equipmentData
    end

    local _layer = requires("src/fsgl/layer/YingXiong/YingXiongInfoLayer.lua"):create({
                            dataNumber = DBTableHero.getHerosCount(gameUser.getUserId())
                            ,herosData = self.m_herosData--DBTableHero.getHeroDatasForFight(gameUser.getUserId())
                            ,items_data = items_data
                        })
    LayerManager.pushModule(_layer)
    _layer:setSelectedCallBack(_key)
end

--先现有英雄排序
function BianQiangLayer:SortForMyHeroData()
    if #self.m_herosData > 1 then
        table.sort(self.m_herosData, function ( data1, data2 )
            if data1["level"] ~= data2["level"]  then
                return tonumber(data1["level"]) > tonumber(data2["level"])
           elseif tonumber(data1.rank)~=tonumber(data2.rank) then
                return tonumber(data1.rank)>tonumber(data2.rank)
            else
                return tonumber(data1["heroid"]) < tonumber(data2["heroid"])
            end
        end)
    end
end

function BianQiangLayer:create(data,parent)
	self._ZhanDouLiData = data
    local BianQiangLayer = BianQiangLayer.new()
    if BianQiangLayer then 
        BianQiangLayer:init(parent)
        BianQiangLayer:registerScriptHandler(function(event)
            if event == "enter" then 
                BianQiangLayer:onEnter()
            elseif event == "exit" then 
                BianQiangLayer:onExit()
            end 
        end)    
    end
    return BianQiangLayer
end

function BianQiangLayer:init(parent)
    self._parent = parent
    self._canClick = true   
end


function BianQiangLayer:onEnter( )
    local function TOUCH_EVENT_BEGAN( touch,event )
        return true
    end

    local function TOUCH_EVENT_MOVED( touch,event )
        -- body
    end

    local function TOUCH_EVENT_ENDED( touch,event )
        if self._canClick == false then
            return
        end
        local pos = touch:getLocation()
        local rect = self.bg:getBoundingBox()
        if cc.rectContainsPoint(rect,pos) == false then
            self._canClick = false
            if self.isTurnAnimEnd == false then
                return
            end
            self:removeFromParent()
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(TOUCH_EVENT_BEGAN,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(TOUCH_EVENT_MOVED,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(TOUCH_EVENT_ENDED,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
end

function BianQiangLayer:getTextAndColor(index)
	--1.英雄品质，2.英雄兵书，3.英雄进阶，4.英雄心法，5.英雄升星，6.英雄等级，7.英雄技能等级，8.修炼，9.羁绊，10.神器，11.玄符，12.装备品质，13.装备升星，14.装备强化
	local needPro = { {45, 25}, {40, 20}, {40, 20}, {30, 13}, {60, 30}, {60, 40}, {60, 40}, {60, 30}, {60, 30}, {48, 22}, {60, 20}, {70, 40}, {50, 18}, {70, 28}}
	local text,color
	local curPro = self._curZLList[index] / self._maxZLList[index] * 100
	if curPro >= needPro[index][1] then
		text = "(相当完美)"
		color = XTHD.resource.textColor.yellow_text
	elseif curPro >= needPro[index][2] then
		text = "(基本达标)"
		color = XTHD.resource.textColor.green_text 
	else
		text = "(急需提升)"
		color = XTHD.resource.textColor.red_text
	end
	return text,color
end 

function BianQiangLayer:onExit( ) 
end

return BianQiangLayer