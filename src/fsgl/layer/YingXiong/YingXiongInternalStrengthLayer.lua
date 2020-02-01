local YingXiongInternalStrengthLayer = class("YingXiongInternalStrengthLayer",function()
	return XTHD.createBasePageLayer()
end)
--心法
function YingXiongInternalStrengthLayer:ctor(_heroid)
	self.maxAddValue = 0
	self._reaSonStr = nil
	self.useAddValue = 0
	self.heroid = _heroid or 1

	self.middlebg = nil
	self.leftBg = nil
	self.rightbg = nil

	self.sureBtn = nil
	self.resetBtn = nil
	self.costStoneNode = nil
	self.costFeicuiNode = nil
	self._tableView = nil
	self.fightBg = nil
	self.tableViewCell = {}

	self.propertyKey = {"hp","physicalattack","physicaldefence","manaattack","manadefence"
	,"dodge","crit","crittimes","attackbreak","antiattack"}
	self.propertyName = LANGUAGE_TIPS_WORDS106-------{"生命","物攻","魔攻","物防","魔防","闪避","暴击","暴伤","伤穿","伤减"}
	self.internalStrengthStaticData = {}
	self:setInternalStrengthData()
	self.data = {}
	self:getHeroData()
	self.stoneItemData = {}
	self:getItemData()
	self.propertyValue = {}
	self:setPropertyValue()
	self.propertyAddValue = {}
	self._nextPropervalue = {0,0,0,0,0}

	self:setPropertyAddValue()
	
	self._fontSize = 16
	self:init()
end
function YingXiongInternalStrengthLayer:init()
	XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_COSTMONEY_STATE,node =self,callback = function( event)
		self:setMaxAddValue()
	end})


	local _size = cc.Director:getInstance():getWinSize()
	local _leftSize = cc.size(350,470)
	local _rightSize = cc.size(458,470)
	

	local _layerHeight = 476
	local _topBarHeight = self.topBarHeight or 40
    local _bg = cc.Sprite:create("res/image/newXinfa/xinfabg.png")
    _bg:setPosition(cc.p(self:getContentSize().width/2,(self:getContentSize().height - _topBarHeight)/2 ))
    self:addChild(_bg)

	local title = "res/image/public/xinfa.png"
	XTHD.createNodeDecoration(_bg,title)

    local _bgPosY = _bg:getContentSize().height/2
	local _bgPosX = _bg:getContentSize().width/2 - _bg:getContentSize().width/2

	local _line1 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
    _line1:setContentSize(400,3)
    _line1:setRotation(90)
    _line1:setPosition(_bgPosX + 298,_bgPosY)
    _bg:addChild(_line1)
    _line1:setOpacity(0)

    -- local _splitY = cc.Sprite:create("res/image/ranklistreward/splitY.png")
    -- _splitY:setRotation(180)
    -- _splitY:setPosition(_line1:getPositionX()+35, _bgPosY)
    -- _bg:addChild(_splitY)

	self.leftBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,298,_layerHeight))
	self.leftBg:setOpacity(0)
	-- ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_2.png") 
 	-- self.leftBg:setContentSize(_leftSize)
 	self.leftBg:setAnchorPoint(0,0.5)
 	self.leftBg:setPosition(cc.p(_bgPosX,_bgPosY))
 	_bg:addChild(self.leftBg)

 	self.middlebg = ccui.Scale9Sprite:create("res/image/newXinfa/middlebg.png")
 	self.middlebg:setAnchorPoint(0.5,0.5)
 	self.middlebg:setPosition(cc.p(_bg:getContentSize().width *0.5,_bgPosY))
 	_bg:addChild(self.middlebg)

	self.rightbg = cc.Sprite:create("res/image/newXinfa/rightbg.png")
	self.rightbg:setAnchorPoint(0,0.5)
	self.rightbg:setPosition(self.middlebg:getPositionX() + self.middlebg:getContentSize().width *0.5 + 5,_bgPosY)
	_bg:addChild(self.rightbg)

 	--介绍按钮
 	local _introduceBtn = XTHD.createButton({
        normalFile = "res/image/common/btn/tip_up.png"
        ,selectedFile  = "res/image/common/btn/tip_down.png"
        ,endCallback = function()
        	self:addChild(requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=16}))
        end
        })
 	_introduceBtn:setAnchorPoint(cc.p(0,1))
 	_introduceBtn:setPosition(cc.p(5,_bg:getContentSize().height -_introduceBtn:getContentSize().height*0.5 + 5))
 	_bg:addChild(_introduceBtn)

 	self:setMaxAddValue()

 	self:initLeftLayer()
 	self:initMiddleLayer()
	self:refreshHeroInfo()
end
function YingXiongInternalStrengthLayer:initLeftLayer()
	local _leftMidPosX = self.leftBg:getContentSize().width/2 + 5
	local _herobgPosY = 190
	--英雄
	local _heroBg_sp = cc.Sprite:create("res/image/plugin/hero/heroBg_Image.png")
	_heroBg_sp:setAnchorPoint(cc.p(0.5,0))
 	_heroBg_sp:setPosition(cc.p(_leftMidPosX,_herobgPosY-20))
     self.leftBg:addChild(_heroBg_sp)
     _heroBg_sp:setOpacity(0)

 	--战斗力
 	--战斗力
 	local fight_bg = XTHD.createPowerShowSprite(self.data.power)
 	 -- cc.Sprite:create("res/image/common/infotitle_bg.png")
	self.fightBg = fight_bg
	fight_bg:setAnchorPoint(cc.p(0.5,1))
	fight_bg:setPosition(cc.p(_leftMidPosX - 10,fight_bg:getContentSize().height + 10))
	self.leftBg:addChild(fight_bg)

	local _level = self:getInternalLevel()
	--按钮
    local _resetBtnSize = cc.size(163,75)
	local _disableNode = XTHD.getScaleNode("res/image/common/btn/btn_write_1_disable.png",_resetBtnSize)
	local _resetBtn = XTHD.createCommonButton({
            btnSize = _resetBtnSize,
            isScrollView = false,
            disableNode = _disableNode
            ,
            text = LANGUAGE_BTN_KEY.resetLevel
			,endCallback = function()
	        	self:ResetNeigongLevel()
	        end
		})
	if tonumber(_level) <1 then
        self:setButtonEnable(_resetBtn,false)
    end

    _resetBtn:setScale(0.6)
	self.resetBtn = _resetBtn
	_resetBtn:setAnchorPoint(cc.p(0.5,0))
	_resetBtn:setPosition(cc.p(_leftMidPosX,self.leftBg:getContentSize().height - _resetBtn:getContentSize().height))
	self.leftBg:addChild(_resetBtn)

	local _dotPosY = _resetBtn:getBoundingBox().y-_resetBtn:getBoundingBox().height * 0.5+15
	--名称
 	local heroname_bg = XTHD.createHeroNameShowSprite(self.data["name"], self.data["advance"],self.data.heroid)
 	heroname_bg:setAnchorPoint(cc.p(0.5,1))
 	heroname_bg:setPosition(cc.p(_leftMidPosX,_dotPosY))
 	self.leftBg:addChild(heroname_bg)
	
	local _internalLabel = XTHDLabel:create(LANGUAGE_KEY_TITLENAME.internalLevelTitleTextXc.."：",self._fontSize)----- 等级：" .. 0,self._fontSize+6)
	_internalLabel:setAnchorPoint(cc.p(1,0))
	_internalLabel:setColor(cc.c3b(111,9,9))
	_internalLabel:setPosition(cc.p(_leftMidPosX+25,heroname_bg:getPositionY() - heroname_bg:getContentSize().height - 35))
	self.leftBg:addChild(_internalLabel)

	--等级
	local _internalLevelLabel = XTHDLabel:create(0,self._fontSize +2)----- 等级：" .. 0,self._fontSize+6)
	_internalLevelLabel:setAnchorPoint(cc.p(0.5,0))
	_internalLevelLabel:setColor(cc.c3b(111,9,9))
	_internalLevelLabel:setName("internalLevelLabel")
	_internalLevelLabel:setPosition(cc.p(_internalLabel:getBoundingBox().x+_internalLabel:getBoundingBox().width +20,_internalLabel:getPositionY() - 2))
	self.leftBg:addChild(_internalLevelLabel)

	local _heroSp = self:createHeroSpine(self.data.heroid or 1)
 	_heroSp:setAnchorPoint(cc.p(0.5,0))
 	_heroSp:setPosition(cc.p(_leftMidPosX - 10,_heroBg_sp:getBoundingBox().y *0.5 - 20))
 	self.leftBg:addChild(_heroSp)
	
	self:setInternalLevel(_level)

end
function YingXiongInternalStrengthLayer:initMiddleLayer()
    local _rightMidPosX = self.middlebg:getContentSize().width/2
	
    local _sureBtnSize = cc.size(135,46)
    local _disableNode = XTHD.getScaleNode1("res/image/common/btn/btn_write_1_disable.png",_sureBtnSize)
	local _sureBtn = XTHD.createCommonButton({
                        btnColor = "write",
                        btnSize = _sureBtnSize,
                        isScrollView = false,
                        text = LANGUAGE_BTN_KEY.sureAddPoint,

                        -- disableNode = _disableNode,
                        endCallback = function()
				        	self:httpToAddValue()
				        end
                    })
    self.sureBtn = _sureBtn
    _sureBtn:setScale(0.6)
    self:setButtonEnable(_sureBtn,true)
	_sureBtn:setAnchorPoint(cc.p(0.5,0))
	_sureBtn:setPosition(cc.p(_rightMidPosX,30))
	self.middlebg:addChild(_sureBtn)
	--消耗
	local property_bg = ccui.Scale9Sprite:create("res/image/newXinfa/cailiao.png")
    property_bg:setAnchorPoint(0.5,0.5)
    property_bg:setPosition(_rightMidPosX,self.middlebg:getContentSize().height*0.4 - 5)
    self.middlebg:addChild(property_bg)

    local _feicuiNode =  ItemNode:createWithParams({
                _type_ = XTHD.resource.type.feicui,
                touchShowTip = true,
                isShowCount = true,
                consumeNeed = getHugeNumberWithLongNumber(self.internalStrengthStaticData.feicui,10000),
            })
    _feicuiNode:setScale(55/_feicuiNode:getContentSize().width)
    self.costFeicuiNode = _feicuiNode
    _feicuiNode:setPosition(cc.p(self.middlebg:getContentSize().width * 0.3,self.middlebg:getContentSize().height *0.25 + 2))
    self.middlebg:addChild(_feicuiNode)
    if tonumber(gameUser.getFeicui())<tonumber(self.internalStrengthStaticData.feicui) then
        print("getFeicui>>" .. gameUser.getFeicui())
        if _feicuiNode:getNumberLabel() then
            _feicuiNode:getNumberLabel():setColor(cc.c4b(255,0,0,255))
        end
    else
        if _feicuiNode:getNumberLabel() then
            _feicuiNode:getNumberLabel():setColor(cc.c4b(255,255,255,255))
        end
    end

    
    local _costStoneNode =  ItemNode:createWithParams({
                itemId = tonumber(self.internalStrengthStaticData.need1),
                _type_ = XTHD.resource.type.item,
                touchShowTip = true,
                isShowCount = true,
                consumeNeed =getHugeNumberWithLongNumber(self.stoneItemData.count or 0,10000) .. "/" .. getHugeNumberWithLongNumber(self.internalStrengthStaticData.num1,10000),
            })
    _costStoneNode:setScale(55/_costStoneNode:getContentSize().width)
    self.costStoneNode = _costStoneNode
    _costStoneNode:setPosition(cc.p(self.middlebg:getContentSize().width *0.5,self.middlebg:getContentSize().height *0.25 + 2))
    self.middlebg:addChild(_costStoneNode)
    if tonumber(self.internalStrengthStaticData.num1)>tonumber(self.stoneItemData.count or 0) then
        if _costStoneNode:getNumberLabel() then
            _costStoneNode:getNumberLabel():setColor(cc.c4b(255,0,0,255))
        end
    else
        if _costStoneNode:getNumberLabel() then
            _costStoneNode:getNumberLabel():setColor(cc.c4b(255,255,255,255))
        end
    end

    local _costStoneNode2 =  ItemNode:createWithParams({
                itemId = tonumber(self.internalStrengthStaticData.need2),
                _type_ = XTHD.resource.type.item,
                touchShowTip = true,
                isShowCount = true,
                consumeNeed =getHugeNumberWithLongNumber(self.stoneItemData2.count or 0,10000) .. "/" .. getHugeNumberWithLongNumber(self.internalStrengthStaticData.num2,10000),
            })
    _costStoneNode2:setScale(55/_costStoneNode2:getContentSize().width)
    self.costStoneNode2 = _costStoneNode2
    _costStoneNode2:setPosition(cc.p(self.middlebg:getContentSize().width *0.7,self.middlebg:getContentSize().height *0.25 + 2))
    self.middlebg:addChild(_costStoneNode2)
    if tonumber(self.internalStrengthStaticData.num2)>tonumber(self.stoneItemData2.count or 0) then
        if _costStoneNode2:getNumberLabel() then
            _costStoneNode2:getNumberLabel():setColor(cc.c4b(255,0,0,255))
        end
    else
        if _costStoneNode2:getNumberLabel() then
            _costStoneNode2:getNumberLabel():setColor(cc.c4b(255,255,255,255))
        end
    end

   	self.tableViewSize = cc.size(self.middlebg:getContentSize().width - 88,43*5)

   	local _tableView = cc.TableView:create(self.tableViewSize)
	TableViewPlug.init(_tableView)
   	self._tableView = _tableView
    _tableView:setPosition(45,property_bg:getBoundingBox().y + property_bg:getBoundingBox().height)
    _tableView:setTouchEnabled(false)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) 
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _tableView:setDelegate()
    self.middlebg:addChild(_tableView)
   

    local _propertyBtnSize = cc.size(200,46)
    local _propertyBtnPosY = self.middlebg:getContentSize().height - 25
    local _baseBtn = XTHD.createCommonButton({
	    	normalNode = cc.Sprite:create("res/image/plugin/hero/jcsx.png"),
            btnSize = _propertyBtnSize,
            isScrollView = false,
            -- text = LANGUAGE_BTN_KEY.baseProperty,
    		selectedNode = cc.Sprite:create("res/image/plugin/hero/jcsx.png"),
    	})
    self.baseBtn = _baseBtn
    _baseBtn:setAnchorPoint(cc.p(0.5,0.5))
    _baseBtn:setPosition(cc.p(_rightMidPosX,_propertyBtnPosY))
    --self.middlebg:addChild(_baseBtn,10)
    ----高级属性
    local _detailBtn = XTHD.createCommonButton({
            normalNode = cc.Sprite:create("res/image/plugin/hero/jcsx.png"),
            btnSize = _propertyBtnSize,
            isScrollView = false,
            text = LANGUAGE_BTN_KEY.highProperty,
    		selectedNode = cc.Sprite:create("res/image/plugin/hero/jcsx.png"),
    	})
    self.detailBtn = _detailBtn
    _detailBtn:setAnchorPoint(cc.p(0,0.5))
    _detailBtn:setPosition(cc.p(_rightMidPosX+3,_propertyBtnPosY))
   -- self.middlebg:addChild(_detailBtn)
    _baseBtn:setTouchEndedCallback(function()
	   	self:setBtnCallback(0)
    end)
    _detailBtn:setTouchEndedCallback(function()
	   	self:setBtnCallback(1)
    end)

    local _cellSize = cc.size(self.tableViewSize.width,self.tableViewSize.height)

	local function cellNumbers(table_view)
         return 2
    end

	local function cellSize(table_view,idx)
         return _cellSize.width , _cellSize.height
    end
	self._tableView.getCellNumbers = cellNumbers
	self._tableView.getCellSize = cellSize

    _tableView:registerScriptHandler(
        function (table_view)
            return 2
        end
    ,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    _tableView:registerScriptHandler(
        function (table_view,idx)
            return _cellSize.width , _cellSize.height
        end
    ,cc.TABLECELL_SIZE_FOR_INDEX)

    _tableView:registerScriptHandler(
        function(table_view,idx)
            local cell = table_view:dequeueCell()
    		if cell then
    			cell:removeAllChildren()
    		else
    			cell = cc.TableViewCell:create()
    		end
            for i=1,5 do
            	self:createCellPropertyContent(i + 5*(math.floor(idx%2)),cell)
            end
            return cell
        end
    ,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData()
    self:setBtnCallback(0)

end

function YingXiongInternalStrengthLayer:refreshHeroInfo()
	self.rightbg:removeAllChildren()
	local lables = {"生命上限：","物理伤害：","物理防御：","魔法伤害：","魔法防御：","命中加成：","暴击加成：","闪避加成："}
	local _powerTable= DBTableHero.getData(gameUser.getUserId(),{heroid=self.heroid})
	local _types = {"hp","physicalattack","physicaldefence","manaattack","manadefence","hit","dodge","crit"}
	for i = 1, #lables do
		local lable = XTHDLabel:create(lables[i].._powerTable[_types[i]],16,"res/fonts/def.ttf")
		self.rightbg:addChild(lable)
		lable:setColor(cc.c3b(0,0,0))
		lable:setAnchorPoint(0,0.5)	
		lable:setPosition(10,self.rightbg:getContentSize().height *0.45 - 5 - ((i-1)*(lable:getContentSize().height + 6)))

		if self._nextPropervalue[i] then
			if self._nextPropervalue[i] - _powerTable[_types[i]] > 0 then
				local properUpbg = cc.Sprite:create("res/image/newXinfa/jiantou.png")
				properUpbg:setAnchorPoint(0,0.5)
				self.rightbg:addChild(properUpbg)
				properUpbg:setPosition(self.rightbg:getContentSize().width *0.65,lable:getPositionY())
			
				local nextLable = XTHDLabel:create(self._nextPropervalue[i] - _powerTable[_types[i]],16,"res/fonts/def.ttf")
				self.rightbg:addChild(nextLable)
				nextLable:setColor(cc.p(0,0,0))
				nextLable:setAnchorPoint(0,0.5)
				nextLable:setPosition(properUpbg:getPositionX() + properUpbg:getContentSize().width + 10,properUpbg:getPositionY())
			end
		end
	end
end

function YingXiongInternalStrengthLayer:createCellPropertyContent(_idx,target)
    local _index = tonumber(_idx-1)%5+1
    local _midposY = self.tableViewSize.height/10 * (11-_index*2)
    local _propertyNameLabel = XTHDLabel:create(tostring(self.propertyName[tonumber(_idx)]) .. "：",self._fontSize + 2,"res/fonts/def.ttf")
    _propertyNameLabel:setColor(cc.c3b(74,8,7))
    _propertyNameLabel:setAnchorPoint(cc.p(0,0.5))
    _propertyNameLabel:setPosition(cc.p(5,_midposY))
    target:addChild(_propertyNameLabel)

    -- do return end

    local _key = self.propertyKey[tonumber(_idx)]
    local _propertyData_ = {}
    _propertyData_.currentValue = tonumber(self.propertyValue[tonumber(_idx)])                              --当前已加点数
    _propertyData_.uplimit = tonumber(self.internalStrengthStaticData[_key])   -- self.heroCurData[_key]    --上限值
    _propertyData_.upAdd = tonumber(self.internalStrengthStaticData["add" .. _key])                         --每点代表的值
    _propertyData_.upCount = math.floor(tonumber(_propertyData_.uplimit)/tonumber(_propertyData_.upAdd))    --上限点数
    _propertyData_.upPercent = tonumber(100/_propertyData_.upCount)                                         --每点代表的进度条的百分比

    local _midposY = _propertyNameLabel:getBoundingBox().y + _propertyNameLabel:getBoundingBox().height/2

    local _reduceBtnPosX = _propertyNameLabel:getBoundingBox().x+ _propertyNameLabel:getBoundingBox().width
    local _addBtnPosX = self.tableViewSize.width

    local _progressWidth = _addBtnPosX - _reduceBtnPosX - 60

    local _progressBg = cc.Sprite:create("res/image/plugin/hero/common_progressBg_3.png")
    _progressBg:setAnchorPoint(cc.p(0,0.5))
    _progressBg:setScaleX(_progressWidth/_progressBg:getContentSize().width)
    _progressBg:setScaleY(0.5)
    _progressBg:setPosition(_propertyNameLabel:getPositionX() + _propertyNameLabel:getContentSize().width + 22.5,_midposY - 2)
    target:addChild(_progressBg)
    
    local _addPercentValue = tonumber(_propertyData_.currentValue + self.propertyAddValue[tonumber(_idx)])*_propertyData_.upPercent
    local _progressUnreal = cc.ProgressTimer:create(cc.Sprite:create("res/image/plugin/hero/common_progress_3.png"))
    _progressUnreal:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    _progressUnreal:setMidpoint(cc.p(0,0.5))
    _progressUnreal:setBarChangeRate(cc.p(1,0))
    _progressUnreal:setPosition(cc.p(_progressBg:getContentSize().width/2,_progressBg:getContentSize().height/2+3.5))
    _progressUnreal:setPercentage(_addPercentValue)
    _progressBg:addChild(_progressUnreal)
    -- self:setProgressPercentage(_addPercentValue,_progressUnreal)

    local _percentValue = tonumber(_propertyData_.currentValue)/tonumber(_propertyData_.upCount)*100
    local _progressReal = cc.ProgressTimer:create(cc.Sprite:create("res/image/plugin/hero/common_progress_3_1.png"))
    _progressReal:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    _progressReal:setMidpoint(cc.p(0,0.5))
    _progressReal:setBarChangeRate(cc.p(1,0))
    _progressReal:setPosition(cc.p(_progressBg:getContentSize().width/2,_progressBg:getContentSize().height/2+3.5))
    _progressReal:setPercentage(_percentValue)
    _progressBg:addChild(_progressReal)
    -- self:setProgressPercentage(_percentValue,_progressReal)
    --放在进度条上
    local _addStr = (tonumber(self.propertyAddValue[tonumber(_idx)])*_propertyData_.upAdd) .. "%"
    local _progressAddValue = XTHDLabel:create(_addStr,self._fontSize+4)
    _progressAddValue:setAnchorPoint(cc.p(0.5,0.5))
    _progressAddValue:setColor(self:getTextColor("baise"))
    _progressAddValue:setPosition(cc.p(_progressBg:getContentSize().width/2,_progressBg:getContentSize().height/2))
    _progressBg:addChild(_progressAddValue)

    local _addValue = XTHDLabel:create("+" .. (_propertyData_.currentValue * _propertyData_.upAdd) .. "%",self._fontSize + 6)
    _addValue:setColor(cc.c3b(255,255,255))
    _addValue:setAnchorPoint(cc.p(0.5,0.5))
    _addValue:setPosition(cc.p(_progressBg:getContentSize().width *0.5,_progressBg:getContentSize().height *0.5 + 2.5))
    _progressBg:addChild(_addValue)
    
    if tonumber(self.propertyAddValue[tonumber(_idx)])>0 then
        _progressAddValue:setVisible(false)
    else
        _progressAddValue:setVisible(false)
    end
	local addNum = _propertyData_.currentValue
    local function createBtn(_type)
        local _path = "add"
        if _type == "reduce" then
            _path = "reduce"
        end
        local _tousize = cc.size(50,50)
        
        local _btn = XTHDPushButton:createWithParams({
                normalFile = "res/image/common/btn/btn_" .. _path .. "Dot_normal.png"
                ,selectedFile = "res/image/common/btn/btn_" .. _path .. "Dot_selected.png"
                ,touchSize = _tousize
                ,musicFile = XTHD.resource.music.effect_btn_common
                ,needEnableWhenOut = true
            })
        _btn._changeValue = 1
        _btn:setScale(0.7)
        _btn.numbers = 0
        _btn.is_click = true
        _btn.ex_num = 0
        _btn.scheduleFunc = nil
        _btn.conditionFunc = nil
        _btn._toastStr = LANGUAGE_TIPS_WORDS101-----"大侠，不能再多了"
        if _type == "reduce" then
            _btn._changeValue = -(_propertyData_.upPercent)
            _btn.conditionFunc = function()
                if _btn.ex_num > _percentValue then
                    return true
                end
                return false
            end
            _btn._toastStr = LANGUAGE_TIPS_WORDS102------"大侠，不能再少了"
        else
            _btn._changeValue = _propertyData_.upPercent
            _btn.conditionFunc = function()
                if _btn.ex_num < 100 then
                    return true
                end
                return false
            end
            _btn._toastStr = LANGUAGE_TIPS_WORDS101------"大侠，不能再多了"
        end
        _btn.scheduleFunc = function()
                if true == _btn.conditionFunc() then
					if _type == "add" then
						local curValue = math.max(addNum,_propertyData_.currentValue)
						print("当前的加点值为："..curValue.."上限为："..self.heroCurData[_key])
						if curValue >= self.heroCurData[_key] then
							XTHDTOAST("英雄星级不足，请提升英雄星级开启更高心法上限！")
							return
						end
						addNum = addNum + 1
					else
						addNum = addNum - 1
					end
                    _btn.ex_num = _btn.ex_num + _btn._changeValue
                    self:setUseAddValue(self.useAddValue + math.floor(_btn._changeValue/_propertyData_.upPercent))
                    _btn.numbers = _btn.numbers + 1
                else
                    _btn:stopAllActions()
                    XTHDTOAST(_btn._toastStr)
                    _btn.numbers = 0
                end
            end
        _btn.refreshFunc = function(_num)
            _progressUnreal:setPercentage(_num)
            -- self:setProgressPercentage(_num, _progressUnreal)
            self.propertyAddValue[tonumber(_idx)] = (tonumber(_progressUnreal:getPercentage()) - tonumber(_progressReal:getPercentage()))/tonumber(_propertyData_.upPercent)
			print("-----------:"..self.propertyAddValue[tonumber(_idx)].."      ------:".._propertyData_.upAdd)
            _addValue:setString((tonumber(self.propertyAddValue[tonumber(_idx)] + _propertyData_.currentValue)*_propertyData_.upAdd) .. "%")
            if tonumber(self.propertyAddValue[tonumber(_idx)])>0 then
                _progressAddValue:setVisible(false)
            else
                _progressAddValue:setVisible(false)
            end
            self:setCostNumber(self.useAddValue)
			
        end
        local _showReasonFunc = function()
            local _reason = self:getCannotAddReason()
            if _reason == "noFeicui" then
                local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=4})
                self:addChild(StoredValue)
            elseif _reason == "noItem1" then
                XTHDTOAST("道具"..gameData.getDataFromCSV("ArticleInfoSheet",{itemid = self.internalStrengthStaticData.need1}).name.."不足")
            elseif _reason == "noItem2" then
                XTHDTOAST("道具"..gameData.getDataFromCSV("ArticleInfoSheet",{itemid = self.internalStrengthStaticData.need2}).name.."不足")
            end
        end
        --[[按钮点击和长按操作]]
        _btn.quickExNum = function( )
            _btn.ex_num = tonumber(_progressUnreal:getPercentage())
            _btn.scheduleFunc()
            if tonumber(self.useAddValue)>tonumber(self.maxAddValue) then
                self:setUseAddValue(self.maxAddValue)
                _btn:stopAllActions()
                _showReasonFunc()
                return
            else
                _btn.refreshFunc(_btn.ex_num)
            end

            --如果减少次数持续10次，则加快减少速度
            if _btn.numbers > 10 and _btn.numbers < 30 then
                _btn:stopAllActions()
                schedule(_btn,_btn.quickExNum,0.05,100)
            elseif _btn.numbers > 30 then
                _btn:stopAllActions()
                schedule(_btn,_btn.quickExNum,0.01,100)
            end
        end
        _btn.pressLongTimeCallback_reduce = function(  )
            _btn.is_click = false
            schedule(_btn,_btn.quickExNum,0.1,100)
        end
        _btn:setTouchBeganCallback(function (  )
            _btn.is_click = true
            -- 延时多少秒操作，此处是延时1秒后回调pressLongTimeCallback_reduce
            performWithDelay(_btn,_btn.pressLongTimeCallback_reduce,0.3)
        end)
        _btn:setTouchEndedCallback(function()
            _btn.ex_num = tonumber(_progressUnreal:getPercentage())
            if _btn.is_click then
                _btn.scheduleFunc()
                if tonumber(self.useAddValue)>tonumber(self.maxAddValue) then
                    self:setUseAddValue(self.maxAddValue)
                    _btn:stopAllActions()
                    _showReasonFunc()
                else
                    _btn.refreshFunc(_btn.ex_num)
                end
            end
            _btn.is_click = true
            _btn:stopAllActions()
			self:refreshNextdata(_idx)
            _btn.numbers = 0
        end)

        return _btn
    end

    local _addBtn = createBtn("add")
    _addBtn:setAnchorPoint(cc.p(0,0.5))
    _addBtn:setPosition(cc.p(_addBtnPosX*0.95 - 15, _midposY))
    target:addChild(_addBtn)

    local _reduceBtn = createBtn("reduce")
    _reduceBtn:setAnchorPoint(cc.p(1,0.5))
    _reduceBtn:setPosition(cc.p(_reduceBtnPosX + 20, _midposY))
    target:addChild(_reduceBtn)

end

function YingXiongInternalStrengthLayer:setBtnCallback(_idx)
	if _idx ==nil or self.baseBtn == nil or self.detailBtn == nil then
		return
	end
	self.baseBtn:setSelected(_idx == 0 and true or false)
	self.detailBtn:setSelected(_idx == 1 and true or false)
	self._tableView:scrollToCell(_idx, false)
end

function YingXiongInternalStrengthLayer:httpToAddValue()
	local isAdd = false
	for i = 1,#self.propertyAddValue do
		if self.propertyAddValue[i] > 0 then
			isAdd = true
		end
	end
	if isAdd == false then
		XTHDTOAST("请先增加点数")
		return
	end
	local _addPointJs = json.encode(self.propertyAddValue)
	ClientHttp:httpHeroAddNeigong(self,function(data)
			--当前的翡翠
        	gameUser.setFeicui(data["feicui"])
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
            self:reFreshInternalStrengthData(data)
			--刷新英雄属性
			-- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER})
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
		end,{petId = self.heroid,addPoints = _addPointJs})
end

function YingXiongInternalStrengthLayer:ResetNeigongLevel()
	local _labelStr = LANGUAGE_KEY_HERO_TEXT.resetInternalPromptTextXc
	local _promptDialog = XTHDConfirmDialog:createWithParams({
			rightCallback = function()
				self:httpToResetNeigong()
			end
		})
	self:addChild(_promptDialog)
	local _confirmDialogBg = nil
	if _promptDialog:getContainer() then
		_confirmDialogBg = _promptDialog:getContainer()
	else
		_promptDialog:removeFromParent()
		return
	end
	local _label_prompt = XTHDLabel:create(_labelStr,self._fontSize + 2)
	_label_prompt:setAnchorPoint(cc.p(0.5,1))
	_label_prompt:setColor(XTHD.resource.color.gray_desc)
	_label_prompt:setPosition(cc.p(_confirmDialogBg:getContentSize().width/2,_confirmDialogBg:getContentSize().height/2+50))
	_confirmDialogBg:addChild(_label_prompt)

	local _label_introduce = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.resetInternalIntroducePromptTextXc,self._fontSize)
	_label_introduce:setAnchorPoint(cc.p(0.5,1))
	_label_introduce:setColor(XTHD.resource.color.gray_desc)
	_label_introduce:setPosition(cc.p(_confirmDialogBg:getContentSize().width/2,_confirmDialogBg:getContentSize().height/5*3 - 10))
	_confirmDialogBg:addChild(_label_introduce)
end
function YingXiongInternalStrengthLayer:httpToResetNeigong()
	ClientHttp:httpHeroResetNeigong(self,function(data)
			--当前的翡翠
        	gameUser.setFeicui(data["feicui"])
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
            self:reFreshInternalStrengthData(data)
			--刷新英雄属性
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
		end,{petId = self.heroid})
	-- ClientHttp:requestAsyncInGameWithParams({
 --    	modules = "resetNeigong?",
 --        params = {petId = self.heroid},
 --        successCallback = function(data)
 --            if tonumber(data.result) == 0 then
 --            	--当前的翡翠
 --            	gameUser.setFeicui(data["feicui"])
 --                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})

 --                self:reFreshInternalStrengthData(data)

	-- 			--刷新英雄属性
	-- 			-- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER})
	-- 			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})

 --                -- XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.buySkillPointSuccessTextXc)
 --            elseif tonumber(data.result) == 2010 then
 --            	self:toRechargeVIP()
 --            else
 --              XTHDTOAST(data.msg)
 --            end
 --        end,--成功回调
 --        failedCallback = function()
 --            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
 --        end,--失败回调
 --        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
 --    })
end

function YingXiongInternalStrengthLayer:setUseAddValue(_value)
	self.useAddValue = _value >=0 and _value or 0
	if tonumber(self.useAddValue)>0 then
        self:setButtonEnable(self.sureBtn,true)
	else
        self:setButtonEnable(self.sureBtn,true)
	end
end
--设置最大可添加点数
function YingXiongInternalStrengthLayer:setMaxAddValue()
    self.maxAddValue = 0
    local _feicuiCount = math.floor(tonumber(gameUser.getFeicui())/tonumber(self.internalStrengthStaticData.feicui))
    local _stoneItemCount = math.floor(tonumber(self.stoneItemData.count or 0)/tonumber(self.internalStrengthStaticData.num1))
    local _stoneItemCount2 = math.floor(tonumber(self.stoneItemData2.count or 0)/tonumber(self.internalStrengthStaticData.num2))
    if _stoneItemCount<_feicuiCount or _stoneItemCount2 < _feicuiCount then
        if _stoneItemCount < _stoneItemCount2 then
            self.maxAddValue  = _stoneItemCount
            self:setCannotAddReason("noItem1")
        else
            self.maxAddValue  = _stoneItemCount2
            self:setCannotAddReason("noItem2")
        end
    else
        self.maxAddValue  = _feicuiCount
        self:setCannotAddReason("noFeicui")
    end
end
function YingXiongInternalStrengthLayer:setCannotAddReason(_type)
	local _reason = "noFeicui"
	self._reaSonStr = _type or _reason
end
function YingXiongInternalStrengthLayer:getCannotAddReason()
	return self._reaSonStr or ""
end

function YingXiongInternalStrengthLayer:refreshNextdata()
	dump(self.propertyAddValue)
	local _addPointJs = json.encode(self.propertyAddValue)
	ClientHttp:requestAsyncInGameWithParams({
     	modules = "willNeiGong?",
        params = {petId = self.heroid,addPoints = _addPointJs},
        successCallback = function(data)
             if tonumber(data.result) == 0 then
				dump(data)
				local valuekeys = {"200","201","202","203","204"}
				for i = 1,#self._nextPropervalue do
					self._nextPropervalue[i] = data.property[tostring(valuekeys[i])]
				end
				self:refreshHeroInfo()
             else
               XTHDTOAST(data.msg)
             end
         end,--成功回调
         failedCallback = function()
             XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
         end,--失败回调
         loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
     })
	--self.propertyAddValue[tonumber(_idx)]
end

function YingXiongInternalStrengthLayer:setCostNumber(_number)
    _number = _number >0 and _number or 1
    self.costStoneNode:setCountNumber(getHugeNumberWithLongNumber(self.stoneItemData.count or 0,10000) .. "/" .. getHugeNumberWithLongNumber(_number*self.internalStrengthStaticData.num1,10000))
    if tonumber(self.internalStrengthStaticData.num1)*_number>tonumber(self.stoneItemData.count or 0) then
        if self.costStoneNode:getNumberLabel() then
            self.costStoneNode:getNumberLabel():setColor(cc.c4b(255,0,0,255))
        end
    else
        if self.costStoneNode:getNumberLabel() then
            self.costStoneNode:getNumberLabel():setColor(cc.c4b(255,255,255,255))
        end
    end
    self.costStoneNode2:setCountNumber(getHugeNumberWithLongNumber(self.stoneItemData2.count or 0,10000) .. "/" .. getHugeNumberWithLongNumber(_number*self.internalStrengthStaticData.num2,10000))
    if tonumber(self.internalStrengthStaticData.num2)*_number>tonumber(self.stoneItemData2.count or 0) then
        if self.costStoneNode2:getNumberLabel() then
            self.costStoneNode2:getNumberLabel():setColor(cc.c4b(255,0,0,255))
        end
    else
        if self.costStoneNode2:getNumberLabel() then
            self.costStoneNode2:getNumberLabel():setColor(cc.c4b(255,255,255,255))
        end
    end
    self.costFeicuiNode:setCountNumber(getHugeNumberWithLongNumber(_number * self.internalStrengthStaticData.feicui,10000))
    if tonumber(gameUser.getFeicui())<tonumber(_number * self.internalStrengthStaticData.feicui) then
        if self.costFeicuiNode:getNumberLabel() then
            self.costFeicuiNode:getNumberLabel():setColor(cc.c4b(255,0,0,255))
        end
    else
        if self.costFeicuiNode:getNumberLabel() then
            self.costFeicuiNode:getNumberLabel():setColor(cc.c4b(255,255,255,255))
        end
    end
end

function YingXiongInternalStrengthLayer:setInternalLevel(_levelStr)
	if self.leftBg == nil or self.leftBg:getChildByName("internalLevelLabel")==nil then
		return
	end
	self.leftBg:getChildByName("internalLevelLabel"):setString(_levelStr or 0)-----等级：" .. (_levelStr or 0))
end
--创建英雄
function YingXiongInternalStrengthLayer:createHeroSpine(_heroid)
	local _spine_sp = XTHD.getHeroSpineById(_heroid)
	_spine_sp:setAnimation(0,"idle",true)

	return _spine_sp
end
function YingXiongInternalStrengthLayer:setPropertyValue()
	local _propertyStr = self.data.neigongs or ""
	self.propertyValue = string.split(_propertyStr,",")
end

function YingXiongInternalStrengthLayer:setPropertyAddValue()
	self.propertyAddValue = {}
	for i=1,10 do
		self.propertyAddValue[i] = 0
	end
end

function YingXiongInternalStrengthLayer:setProgressPercentage(_percentValue,_target)
	if _target == nil then
		return
	end
	local _oldpercent = tonumber(_target:getPercentage())
	local _subPercent = tonumber(_percentValue or 0) - _oldpercent
	_subPercent = math.abs(_subPercent)
	local _progressTime = _subPercent/100*0.4
	_target:stopAllActions()
	_target:runAction(cc.ProgressTo:create(_progressTime,_percentValue))
end

function YingXiongInternalStrengthLayer:reFreshFightLabel(_power)
	local _value = _power or nil
	if not _value or tonumber(_value)<0 then
		local _powerTable= DBTableHero.getData(gameUser.getUserId(),{heroid=self.heroid})
		self.data.power = powerTable and powerTable.power or 0
		_value = self.data.power
	end
	XTHD.refreshPowerShowSprite(self.fightBg,_value)
end

function YingXiongInternalStrengthLayer:reFreshInternalStrengthData(_data)
	local _oldHeroData = self.data

    local property = _data.petProperty
    if property then
        for i=1,#property do
            local _tab = string.split(property[i],',')
            DBTableHero.updateDataByPropId( gameUser.getUserId(), _tab[1],_tab[2],_data["petId"]);
            gameUser.updateDataById(_tab[1],_tab[2])
        end
    end
    DBTableHero.updateHeroData(gameUser.getUserId(),tostring(_data["neigongs"]),_data["petId"], "neigongs")
	
	if _data["bagItems"] then
		for i = 1,#_data["bagItems"] do
			local _dbid = _data["bagItems"][i]["dbId"]
			if  _data["bagItems"][i]["count"] and _data["bagItems"][i]["count"] > 0 then
				DBTableItem.updateCount(gameUser.getUserId(),_data["bagItems"][i],_dbid)
			else
				DBTableItem.deleteData(gameUser.getUserId(),_dbid)
			end
		end
	end
    
    self:getItemData()
    self:getHeroData()

    local _newHeroData = clone(self.data)
    local _winsize = cc.Director:getInstance():getWinSize()
    local _pos = cc.p(_winsize.width/2,_winsize.height/2)
    self:reFreshFightLabel(self.data["power"])

    XTHD.createHeroBasePropertyToast(_oldHeroData,_newHeroData,_pos)

    self:reFreshHeroFunctionInfo()
end
function YingXiongInternalStrengthLayer:setButtonEnable(_target,_flag)
	if _target ==nil or _flag ==nil then
		return
	end
	_target:setEnable(_flag)
	if _target:getLabel()~=nil then
        if _flag == false then
            _target:getLabel():setColor(cc.c3b(255,255,255))
            -- _target:getLabel():enableShadow(XTHD.resource.btntextcolor.black,cc.size(0.4,-0.4),0.4)
        elseif _flag == true then
            _target:getLabel():setColor(cc.c3b(255,255,255))
            -- _target:getLabel():enableShadow(XTHD.resource.btntextcolor.green,cc.size(0.4,-0.4),0.4)
        end
		
	end
end

function YingXiongInternalStrengthLayer:reFreshHeroFunctionInfo()
	self:setCostNumber(0)
	self:setPropertyAddValue()
	self:setMaxAddValue()
	self:setUseAddValue(0)
	self:setPropertyValue()
	
	local _level = self:getInternalLevel()
	if tonumber(_level)>0 then
        self:setButtonEnable(self.resetBtn,true)
	else
        self:setButtonEnable(self.resetBtn,false)
	end
	self:setInternalLevel(_level)
	self._tableView:reloadDataAndScrollToCurrentCell()
end

function YingXiongInternalStrengthLayer:getInternalLevel()
	local _level = 0
	for i=1,#self.propertyValue do
		_level = _level + tonumber(self.propertyValue[i])
	end
	return _level
end

function YingXiongInternalStrengthLayer:getItemData()
    self.stoneItemData = clone(DBTableItem.getData(gameUser.getUserId(),{itemid = tonumber(self.internalStrengthStaticData.need1)}))
    self.stoneItemData2 = clone(DBTableItem.getData(gameUser.getUserId(),{itemid = tonumber(self.internalStrengthStaticData.need2)}))
end

function YingXiongInternalStrengthLayer:getHeroData()
	self.data = HeroDataInit:InitHeroDataSelectHero( self.heroid ) or {}
end

function YingXiongInternalStrengthLayer:setInternalStrengthData()
	self.internalStrengthStaticData = gameData.getDataFromCSV("GeneralXinfa",{id = self.heroid}) or {}
	self.heroStaticData = gameData.getDataFromCSV("GeneralXinfaB",{heroid = self.heroid})
	self.heroDyData = DBTableHero.getHeroData(self.heroid)
	self.heroCurData = {}
	for i = 1,#self.heroStaticData do
		if self.heroStaticData[i].star == self.heroDyData.star then
			self.heroCurData = self.heroStaticData[i]
			break
		end
	end
	-- print("确认加点提交给服务器的数据为：")
	-- print_r(self.heroCurData)
	-- print_r(self.heroDyData)
end


function YingXiongInternalStrengthLayer:getTextColor(_str)
	local _color = {
		shenhese = cc.c4b(54,55,112,255)
        ,lvse = cc.c4b(104,157,0,255),                           --绿色
        baise = cc.c4b(255,255,255,255)
	}
	return _color[_str]
end

function YingXiongInternalStrengthLayer:create(_heroid)
	local _layer = self.new(_heroid)
	return _layer
end
return YingXiongInternalStrengthLayer