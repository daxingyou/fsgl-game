local TieJiangPuLayer = class("TieJiangPuLayer",function()
    return XTHD.createBasePageLayer()
end)
--铁匠铺

function TieJiangPuLayer:onCleanup()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
    -- XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER)
    -- XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_COSTMONEY_STATE)
    if self.isComposeItem~=nil and self.isComposeItem == true then
        RedPointManage:reFreshDynamicItemData()
    end
end
function TieJiangPuLayer:onEnter()
    self:reFreshLayerAfterTurnDrop()
end
function TieJiangPuLayer:ctor()
	self._type = 5  			--类型分别为装备，药剂，玄符
	self._itemInfo_pos = nil 	--信息框的位置
    self.isComposeItem = false

	self._fontSize = 16
	self._selectedOrder = 1 	--选中cell的序号
	self._selectedCell = nil 	--选中的cell
    self._tabkeNum = 1

    self.rightSize= nil
    self.leftSize = nil
    self.tableViewSize = cc.size(0,0)
    self.tableViewCellSize = cc.size(0,0)

	self._tabsTable = {}
	self._equipIcon = {}
	self._tabIndex = 1

	self.configId = nil

    self.countLabel = {}                --材料的数量label

	self.itemInfo_bg = nil 				--道君信息界面背景
	self.produce_Btn = nil 				--制作按钮
	-- self._currentItem = nil  			--当前选中的制作道具
	-- self._materialTitlelabel = nil 		--材料文字title
	-- self.property_bg = nil 				--属性背景
	self._successRateNumlabel = nil 	--成功率
	self._createNumLabel = nil  		--制作数量
	self._costSpr = nil 				--消耗品精灵
	self._costNumLabel = nil 			--消耗品数量
    self._produceItemBg = nil           --制作的item背景
    self.maxMakeCount = 0               --最大数量
    self.cannotMakeReason = {}          --不能制作原因

	self._tabBtn = {}
	self.classifyItemNumber = 0 		--当前分类的数量
	self.dynamicItemData = {} 			--动态数据库item
	self.iteminfoData = {} 				--静态数据库iteminfo
	-- self.itemEquipData = {} 			--静态数据库itemequip
	-- self.godbeaststoneData = {} 		--静态数据库Runelist
	self.itemComposeData = {} 			--静态数据库itemcompose
	-- self.itemsData = {} 				--存放itemCompose中的itemid对应的相关信息。改信息取自静态数据库iteminfo，静态数据库itemequip，静态数据库Runelist
	self.currentItemData = {} 			--当前选中item的compose信息，取自itemcompose对应信息
    
    -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER})
    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK,node=self,callback = function( event)
        self:reFreshLayerAfterTurnDrop()
    end})
	self:init()
end

function TieJiangPuLayer:init()
	--数据
	self:getDBData()

    --装备的合成被移到装备中了，不在铁匠铺中。所以这里只剩下一个玄符，这里的数量指的就是在铁匠铺中的合成。
    --因为装备合成它的type是1，所以每次都要特殊判断。
    --这里个人觉得如果把装备合成的itemtype改成0的话，要方便很多。
    local list = clone(self.itemComposeData)
    for i = 1,#list-1 do
        if list[i].itemtype > list[i+1].itemtype then
            local a = list[i+1]
            list[i+1] = list[i]
            list[i] = a
        end
    end
    local num = list[#list].itemtype

    self._tabkeNum = num or 1 --self.itemComposeData[#self.itemComposeData].itemtype or 1
    local _topBarHeight = self.topBarHeight or 45

    local _bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    _bg:setPosition(cc.p(self:getContentSize().width/2,(self:getContentSize().height - _topBarHeight)/2 ))
	self._bg = _bg
    self:addChild(_bg)

	self._rightSize = cc.size( 86*6-20, self._bg:getContentSize().height - 60 )

	local title = "res/image/public/tiejiangpu_title.png"
	XTHD.createNodeDecoration(self._bg,title)

    --阴影
--	local shadow = ccui.Scale9Sprite:create("res/image/common/common_black_shadow.png")
--	shadow:setPosition(_bg:getContentSize().width + 32,_bg:getContentSize().height/2)
--	shadow:setAnchorPoint(1,0.5)
--	_bg:addChild(shadow)
    local btn_normalpath = "res/image/common/btn/btn_tabClassify_normal.png"
    local btn_selectpath = "res/image/common/btn/btn_tabClassify_selected.png"
    -- local _textColor = self:getHeroListTextColor("shenhese")
    -- local _textPositionX = 26
    -- local _textFontsize = 20
    local _btnIntervalY = 4
    local _touchSize = cc.size(73,85)
    local _tabOffset = 73-20

    local itemComposeBg = ccui.Scale9Sprite:create()
    itemComposeBg:setContentSize(869,470)

    local _tabPosX = _bg:getContentSize().width
    local _tabTopPosY = _bg:getContentSize().height/2+itemComposeBg:getContentSize().height/2 - 4
--    local _tabLabel = {"keyin","yaoji","daoju"}
    -- {"yaoji","cailiao","keyin","zhuangbei"}
    --右侧按钮
    local _tabkeNum = self._tabkeNum
--    print("按鈕個數------------------->>>",_tabkeNum)
--     self.itemComposeData[#self.itemComposeData].itemtype or 1
--    for i=1,_tabkeNum do
--        local _btn = XTHD.createButton({
--                        normalNode = getCompositeNodeWithImg(btn_normalpath,"res/image/common/tabLabel_normal_" .. _tabLabel[i] .. ".png")
--                        ,selectedNode = getCompositeNodeWithImg(btn_selectpath,"res/image/common/tabLabel_selected_" .. _tabLabel[i] .. ".png")
--                        ,touchSize = _touchSize
--                    })
--        _btn:setAnchorPoint(1,1)
--        _btn:setPosition(_tabPosX-20,_tabTopPosY -_btnIntervalY -_btn:getContentSize().height*(i-1)*0.8)
--        _bg:addChild(_btn)
--        _btn:setScale(0.7)
--        self._tabBtn[#self._tabBtn+1] = _btn
--        _btn:setTouchEndedCallback(function ()
--            self:setTabClickFunc(i)
--        end)
--    end
--    self._tabBtn[1]:setSelected(true)

    self.itemComposeBg = itemComposeBg
    itemComposeBg:setAnchorPoint(cc.p(1,0.5))
    itemComposeBg:setPosition(cc.p(_tabPosX - _tabOffset,_bg:getContentSize().height/2))
    _bg:addChild(itemComposeBg,1)


    self.rightSize= cc.size(420,itemComposeBg:getContentSize().height)
    
    --item列表
	 
    local _itemList_bg=  ccui.Scale9Sprite:create()
    self.itemList_bg = _itemList_bg
	_itemList_bg:setContentSize(self.rightSize)
	_itemList_bg:setCascadeOpacityEnabled(true)
	_itemList_bg:setCascadeColorEnabled(true)
	_itemList_bg:setAnchorPoint(1,0.5)
	_itemList_bg:setPosition(itemComposeBg:getContentSize().width - 25,itemComposeBg:getContentSize().height/2)
	itemComposeBg:addChild(_itemList_bg)
    self.leftSize = cc.size(414,itemComposeBg:getContentSize().height)

	local _itemInfo_pos = cc.p(_itemList_bg:getBoundingBox().x - (self.leftSize.width + self._bg:getContentSize().width - 1024)/2, itemComposeBg:getContentSize().height/2)
    --item信息
    local _itemInfo_bg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,self.leftSize.width,self.leftSize.height))
    self.itemInfo_bg = _itemInfo_bg
    _itemInfo_bg:setOpacity(0)
    -- ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_2.png")
    -- self.itemInfo_bg:setContentSize(self.leftSize)
    _itemInfo_bg:setAnchorPoint(cc.p(0.5,0.5))
    _itemInfo_bg:setPosition(30,itemComposeBg:getContentSize().height/2)
    self.itemComposeBg:addChild(_itemInfo_bg)
	
	self:initRight()
--	self:setItemListLayer()
	self:setCurrentItemData(1)
	self:setItemInfoLayer()
end

function TieJiangPuLayer:setTabButtonRedPoint(_idx)
    for i=1,#self._tabBtn do
        local _btn = self._tabBtn[i]
        if i ~= tonumber(_idx) then
            local _state = RedPointManage:getTabComposeRedPoint(i)
            if _btn:getChildByName("redPoint")==nil and _state == true then
                local _redPointSp = cc.Sprite:create("res/image/common/heroList_redPoint.png")
                _redPointSp:setAnchorPoint(cc.p(1,1))
                _redPointSp:setName("redPoint")
                _redPointSp:setPosition(cc.p(_btn:getContentSize().width,_btn:getContentSize().height))
                _btn:addChild(_redPointSp)
            elseif _state == false then
                if _btn:getChildByName("redPoint")~=nil then
                    _btn:removeChildByName("redPoint")
                end
            end
        else
            if _btn:getChildByName("redPoint")~=nil then
                _btn:removeChildByName("redPoint")
            end
        end
    end
end

function TieJiangPuLayer:changeTab( index )
    self._tabsTable[self._tabIndex]:setSelected( false )
    self._tabsTable[self._tabIndex]:setEnable( true )
    self._tabsTable[self._tabIndex]:setLocalZOrder( 0 )
    self._tabsTable[index]:setSelected( true )
    self._tabsTable[index]:setEnable( false )
    self._tabsTable[index]:setLocalZOrder( 1 )
    self._tabIndex = index
end

--创建右侧列表
function TieJiangPuLayer:initRight()
    -- 容器
    local rightContainer = XTHD.createSprite()
    rightContainer:setAnchorPoint( 1,0.5 )
    rightContainer:setContentSize( self._rightSize )
    rightContainer:setPosition(self._bg:getContentSize().width - 15, self._bg:getContentSize().height * 0.5 )
    self._bg:addChild( rightContainer )

    -- tab点击处理
    local function tabCallback( index )
        if self._tabIndex ~= index then
            -- 更改tabs状态
            self:changeTab( index )
            self._equipIcon = {}
            self._itemListTableView:reloadData()
        end
    end

    -- 循环创建tab
    local colorTab = {"道具","VIP卡","兵书","攻击玄符","防御玄符","特殊玄符"}
    local colorIndex = {[1] = 5,[2] = 6,[3] = 4,[4] = 1,[5] = 2,[6] = 3,}
    for i = 1, 6 do
        local colorLabel = XTHDLabel:create(colorTab[i],22)
        local tabBtn_normal = cc.Sprite:create("res/image/common/btn/btn_tabTop_up.png")--getCompositeNodeWithImg( "res/image/common/btn/btn_tabTop_up.png", "res/image/plugin/equip_smelt/quality"..i.."_up.png",colorLabel )
        local tabBtn_selected = cc.Sprite:create("res/image/common/btn/btn_tabTop_down.png")--getCompositeNodeWithImg( "res/image/common/btn/btn_tabTop_down.png", "res/image/plugin/equip_smelt/quality"..i.."_down.png",colorLabel )
        local tabBtn = XTHD.createButton({
			text = colorTab[i],
            normalNode = tabBtn_normal,
            selectedNode = tabBtn_selected,
            anchor = cc.p( 0, 1 ),
            touchSize = cc.size( 86, 45 ),
            endCallback = function()
                tabCallback( i )
				self:setTabClickFunc(colorIndex[i])
            end,
        })
        tabBtn:setPosition( 80*( i - 1 ), self._rightSize.height-5 )
        tabBtn:setScale(0.8)
        rightContainer:addChild( tabBtn )
        self._tabsTable[i] = tabBtn
    end
    self._tabsTable[self._tabIndex]:setSelected( true )
    self._tabsTable[self._tabIndex]:setEnable( false )
    self._tabsTable[self._tabIndex]:setLocalZOrder( 1 )

    -- 下面的背景
    -- local tabBg = ccui.Scale9Sprite:create( cc.rect( 18, 12, 1, 1 ), "res/image/plugin/equip_smelt/smeltBg.png" )
    local tabBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png" )
    tabBg:setContentSize( self._rightSize.width-16, self._rightSize.height - 65 )
    tabBg:setAnchorPoint( cc.p( 0, 0 ) )
    tabBg:setPosition( 0, 20 )
    rightContainer:addChild( tabBg )

    -- tableview
    local cellWidth = self._rightSize.width - 23
    self._itemListTableView = CCTableView:create( cc.size( cellWidth, tabBg:getContentSize().height-10) )
    TableViewPlug.init(self._itemListTableView)
    self._itemListTableView:setPosition( 0, 5 )
    self._itemListTableView:setBounceable( true )
    self._itemListTableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL ) --设置横向纵向
    self._itemListTableView:setDelegate()
    self._itemListTableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
    local iconPosX = {}
    for i = 1, 5 do
        iconPosX[i] = cellWidth/5*( i - 0.5 )
    end
    local iconsPerCell = 5
    local function numberOfCellsInTableView( table )
        return math.ceil(self.classifyItemNumber/5)
    end
    local function cellSizeForTable( table, index )
        local tmp = math.ceil( (self.classifyItemNumber  - index*iconsPerCell )/5 )
        return cellWidth,( tmp < iconsPerCell/5 and tmp or iconsPerCell/5 )*90 
    end
    local function tableCellAtIndex( table, index )
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
			local tmp = math.ceil( (self.classifyItemNumber  - index*iconsPerCell )/5 )
			cell:setContentSize(cc.size(cellWidth,( tmp < iconsPerCell/5 and tmp or iconsPerCell/5 )*90))
        end		
    		
        -- 当前cell里icon行数
        local curLines = math.ceil( ( #self.itemComposeData - index*iconsPerCell )/5 )
        curLines = curLines < iconsPerCell/5 and curLines or iconsPerCell/5

        for i = 1, iconsPerCell do
			if index*iconsPerCell + i > self.classifyItemNumber then
				break
			end
            local _composeStaticData = self.itemComposeData[index*iconsPerCell + i]
			local _itemId = _composeStaticData.itemid or 110031
            if _composeStaticData then
                --头像
    			local equipIcon = ItemNode:createWithParams({
					dbId = nil,
					itemId = _itemId,
					_type_ = 4,
					touchShowTip = true,
                    isShowDrop = false,
                    count = self:getMaxCountById(index*iconsPerCell + i),
					isScrollView=true
				})
                -- equipIcon:setScale( 0.8 )
                equipIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
                equipIcon:setPosition( iconPosX[( i - 1 )%5 + 1], 42 + 90*( curLines - math.ceil( i/5 ) ) )
                cell:addChild( equipIcon )
                equipIcon:setScale(0.8)
                self._equipIcon[index*iconsPerCell + i] = equipIcon
                -- 选中框
                -- local selected = ccui.Scale9Sprite:create( cc.rect( 10, 10, 2, 2 ), "res/image/illustration/selected.png" )
                local selected = ccui.Scale9Sprite:create("res/image/illustration/selected.png" )
                -- selected:setContentSize( equipIcon:getContentSize() )
                -- selected:setContentSize( cc.size(105,105) )
                getCompositeNodeWithNode( equipIcon, selected )
                equipIcon._selected = selected
				equipIcon._selected:setVisible(false)
                equipIcon:setTouchEndedCallback( function()
					self._selectedOrder = index*iconsPerCell + i
					self:setCurrentItemData(index*iconsPerCell + i)
    				self:refreshItemInfoLayer()
					for z = 1,#self._equipIcon do
						if self._equipIcon[z]._selected then
							self._equipIcon[z]._selected:setVisible(false)
						end
					end
                    selected:setVisible( true )	
                end)
				if self._equipIcon[1]._selected then
					self._equipIcon[1]._selected:setVisible(true)
				end	
            end
        end

        return cell
    end
    self._itemListTableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    self._itemListTableView.getCellNumbers=numberOfCellsInTableView
    self._itemListTableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    self._itemListTableView.getCellSize=cellSizeForTable
    self._itemListTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tabBg:addChild( self._itemListTableView )

	self:setSelectedBtnCallback(colorIndex[1])
end

--右边Item列表
function TieJiangPuLayer:setItemListLayer()
	self.tableViewSize = cc.size(self.itemList_bg:getContentSize().width ,self.itemList_bg:getContentSize().height - 15)
	self._itemListTableView = CCTableView:create(self.tableViewSize)
	self._itemListTableView:setBounceable(false)
	self._itemListTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self._itemListTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self._itemListTableView:setDelegate()
	self._itemListTableView:setPosition(0,4)
	self.itemList_bg:addChild(self._itemListTableView)

    self.tableViewCellSize = cc.size(self.tableViewSize.width,88+6)


	self._itemListTableView:registerScriptHandler(
        function (table_view)
            return self.classifyItemNumber
        end
    ,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	self._itemListTableView:registerScriptHandler(
        function (table_view,idx)
            return self.tableViewCellSize.width,self.tableViewCellSize.height+10
        end
    ,cc.TABLECELL_SIZE_FOR_INDEX)

	self._itemListTableView:registerScriptHandler(
		function(view)
		end,cc.SCROLLVIEW_SCRIPT_SCROLL)

    self._itemListTableView:registerScriptHandler(
    	function (table_view,idx)
    		local cell = table_view:dequeueCell()
    		--如果cell是存在的，判断该cell是否被选中，是，清除cell上的节点，self._selectedCell置为nil
    		if cell then
    			if cell:getChildByName("cellBg") then
    				local _cell_bg = cell:getChildByName("cellBg")
    				local _cellBool = _cell_bg.isSelected or false
    				cell:getChildByName("cellBg"):removeFromParent()
    				if _cellBool==true then
    					self._selectedCell = nil
    				end
    			end
    			cell:removeAllChildren()
    		else
    			cell = cc.TableViewCell:create()
				cell:setContentSize(cc.size(self.tableViewCellSize))
    		end
            local _cellBgSize = cc.size(self.tableViewCellSize.width - 4*2,self.tableViewCellSize.height+10)
    		local _cellBg = XTHD.createButton({
		    	normalNode = XTHD.getScaleNode("res/image/common/scale9_bg1_26.png",_cellBgSize)
                ,selectedNode = XTHD.getScaleNode("res/image/common/scale9_bg1_26.png",_cellBgSize)
				,needSwallow = false
				,needEnableWhenMoving = true
				,touchSize = cc.size(333,82)
	    	})
	    	_cellBg:setName("cellBg")
    		_cellBg.isSelected = false
    		_cellBg:setAnchorPoint(cc.p(0.5,0.5))
    		_cellBg:setPosition(cc.p(self.tableViewSize.width/2,self.tableViewCellSize.height/2))

            local _selectedSp = XTHD.getScaleNode("res/image/common/scale9_bg_13.png",cc.size(self.tableViewCellSize.width + 6 ,self.tableViewCellSize.height+21))
            _selectedSp:setName("selectedSp")
            _selectedSp:setPosition(cc.p(_cellBg:getContentSize().width/2,_cellBg:getContentSize().height/2+3))
            _cellBg:addChild(_selectedSp,1)
            _selectedSp:setVisible(false)

            local _btnSetSelected = function(_target,_flag)
                if _target:getChildByName("selectedSp") then
                    _target:getChildByName("selectedSp"):setVisible(_flag)
                end
            end

    		_cellBg:setTouchEndedCallback(function()
    				if self._selectedCell~=nil then
                        _btnSetSelected(self._selectedCell,false)
    					-- self._selectedCell:setSelected(false)
    					self._selectedCell.isSelected = false
    				end
    				_cellBg.isSelected = true
                    _btnSetSelected(_cellBg,true)
    				self._selectedOrder = idx + 1
    				self._selectedCell = _cellBg
    				self:setCurrentItemData(idx+1)
    				self:refreshItemInfoLayer()
    			end)
    		if self._selectedOrder == (idx + 1) then
                _btnSetSelected(_cellBg,true)
    			_cellBg.isSelected = true
    			self:removeSelectedCell()
    			self._selectedCell = _cellBg
    		end
            local _composeStaticData = self.itemComposeData[idx+1] or {}
    		local _itemId = _composeStaticData.itemid or 110031
    		--头像
    		local _itemSpr = ItemNode:createWithParams({
		        dbId = nil,
		        itemId = _itemId,
		        _type_ = 4,
		        touchShowTip = true
		    })
		    _itemSpr:setScale(68/_itemSpr:getContentSize().width)
		    _itemSpr:setAnchorPoint(cc.p(0,0.5))
			_itemSpr:setPosition(10 , _cellBg:getContentSize().height / 2 )
			_cellBg:addChild(_itemSpr)

			--名称
			local _name = _composeStaticData.name or "" ------"敌敌畏"
			local _nameLabel = XTHDLabel:create(_name,self._fontSize)
			_nameLabel:setColor(XTHD.resource.textColor.gray_text)
            _nameLabel:enableShadow(XTHD.resource.textColor.gray_text,cc.size(0.4,-0.4),0.4)
			_nameLabel:setAnchorPoint(cc.p(0,1))
			_nameLabel:setPosition(cc.p(_itemSpr:getBoundingBox().x + _itemSpr:getBoundingBox().width + 5,_itemSpr:getBoundingBox().y + _itemSpr:getBoundingBox().height))
			_cellBg:addChild(_nameLabel)

			--是否可制作
			local _labelTable = {}
			_labelTable = self:getMakePromptInfo(idx+1)
			local _promptLabel = XTHDLabel:create(_labelTable._labelStr,self._fontSize)
            _promptLabel._labelType = _labelTable._labelType
			_promptLabel:setName("promptLabel")
			_promptLabel:setColor(_labelTable._labelColor)
            _promptLabel:enableShadow(_labelTable._labelColor,cc.size(0.4,-0.4),0.4)
			_promptLabel:setAnchorPoint(cc.p(1,1))
			_promptLabel:setPosition(cc.p(_cellBg:getContentSize().width-14,_nameLabel:getPositionY()))
			_cellBg:addChild(_promptLabel)
            
            -- end

            --tips
            local _tipsLabel = XTHDLabel:create(_composeStaticData.tips or "",self._fontSize)
            _tipsLabel:setColor(XTHD.resource.textColor.huihuang_text)
            _tipsLabel:setAnchorPoint(cc.p(0,0))
			_tipsLabel:setDimensions(310,60)
            _tipsLabel:setPosition(cc.p(_nameLabel:getPositionX(),_itemSpr:getBoundingBox().y-25))
            _cellBg:addChild(_tipsLabel)
            
    		cell:addChild(_cellBg)

            if idx ~= self.classifyItemNumber-1 then
                -- local _lineSp = ccui.Scale9Sprite:create( cc.rect( 0, 0, 3, 2 ), "res/image/ranklistreward/splitcell.png" )
                -- _lineSp:setContentSize(cc.size(self.tableViewCellSize.width - 2,2))
                -- _lineSp:setPosition(cc.p(self.tableViewCellSize.width/2,0)) 
                -- cell:addChild(_lineSp)
            end

    		return cell
	    end
    ,cc.TABLECELL_SIZE_AT_INDEX)

	self:setSelectedBtnCallback(5)
end
--等级是否达到，制作材料是否充足的提示语
function TieJiangPuLayer:getMakePromptInfo(_index)
	local _strTable = {}
	local _boolStr = tonumber(self.itemComposeData[tonumber(_index)].prompt)
	_strTable._labelStr = LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[3]------"材料不足"
	_strTable._labelColor =cc.c4b(255,6,6,255)
    _strTable._labelType =_boolStr or nil 

    if _boolStr == 1 then
        _strTable._labelColor = cc.c4b(7,105,4,255)
        _strTable._labelStr = LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[5]------"材料充足" 
    elseif _boolStr == 2 then
        _strTable._labelStr = LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[3]------"材料不足"
        _strTable._labelColor =cc.c4b(255,6,6,255)
    elseif _boolStr == 3 then
        _needLv = self.itemComposeData[tonumber(_index)].needlv
        _strTable._labelStr = LANGUAGE_KEY_LEVEL_LIMIT.._needLv-------"需要等级" .. _needLv
        _strTable._labelColor =cc.c4b(255,6,6,255)
    end

	return _strTable
end
--设置提示
function TieJiangPuLayer:setComposeDataPrompt()
    for i=1,#self.itemComposeData do
        local _str = self:getPromptStr(self.itemComposeData[i]) or 3
        self.itemComposeData[i].prompt = _str
    end
end
function TieJiangPuLayer:getPromptStr(_data)
    local _str = 2
    local _needLv = _data.needlv
    if tonumber(gameUser.getLevel())<_needLv then
        _str = 3
        return _str
    end
    local _labelBool = false
    _labelBool = self:isEnoughToMakeItem(_data)
    if _labelBool==true then
        _str = 1
    end
    return _str
end
--判断材料是否充足
function TieJiangPuLayer:isEnoughToMakeItem(_data)
    local _itemComposeData = _data or {}
    if next(_itemComposeData)==nil then
        return false
    end
    for i=1,4 do
        local _needItemid = _itemComposeData["need" .. i] or nil
        if _needItemid~=nil then
            --原料是否存在
            local _itemidData_ = self.dynamicItemData[tostring(_needItemid)] or {}
            if next(_itemidData_)~=nil then
                local _needItemCount = tonumber(_itemComposeData["num" .. i]) or 1
                local _itemidCount = tonumber(_itemidData_["count"]) or 0
                --原料存在，适量是否充足
                if _itemidCount<_needItemCount then
                    return false
                end
            else
                return false
            end
        else
            break
        end
    end
    return true
end
--设置左边item信息框
function TieJiangPuLayer:setItemInfoLayer()
    if self.itemInfo_bg ==nil then
        return
    end

	local posX = self.itemInfo_bg:getContentSize().width/2 + 135
    --制作按钮
    local _produceSize = cc.size(145,46)
    self.produce_Btn = XTHD.createCommonButton({
            btnColor = "write_1",
            btnSize = _produceSize,
            isScrollView = false,
            text = LANGUAGE_BTN_KEY.startMake,
            fontSize = self._fontSize+6,
			touchSize = _produceSize,
        })
    self.produce_Btn:setScale(0.7)   
    self.produce_Btn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
    self.produce_Btn:setCascadeOpacityEnabled(true)
	self.produce_Btn:setCascadeColorEnabled(true)
    self.produce_Btn:setAnchorPoint(cc.p(0.5,0.5))
    self.produce_Btn:setPosition(cc.p(posX,30))
    self.itemInfo_bg:addChild(self.produce_Btn)
    self.produce_Btn.cannotMakeType = {}

    self.produce_Btn:setTouchEndedCallback(function()
            if self.produce_Btn.cannotMakeType[1]~=nil then
                self:showCannotMakeReason(self.produce_Btn.cannotMakeType)
                return
            end
        	self:httpToMakeItems()
    	end)

    --信息框内容
    local _itemid = self.currentItemData.itemid
    local _currentResourceId = self.iteminfoData[tostring(_itemid)].resourceid

    --makeItem
    local _itemBottom = cc.Sprite:create("res/image/plugin/compose/compose_itemBottom.png")
    _itemBottom:setPosition(cc.p(posX,self.itemInfo_bg:getContentSize().height - 10 - _itemBottom:getContentSize().height/2))
    self.itemInfo_bg:addChild(_itemBottom)
    _itemBottom:runAction(cc.RepeatForever:create(cc.RotateBy:create(30,360)))
    _itemBottom:setOpacity(0)

    local _produceItemBg = cc.Sprite:create("res/image/plugin/compose/compose_itemBg.png")
    _produceItemBg:setPosition(cc.p(posX,_itemBottom:getPositionY()))
    -- _produceItemBg:setOpacity(0)
    self.itemInfo_bg:addChild(_produceItemBg)
    self._produceItemBg = _produceItemBg

    self:setLeftLayerItemSpr(_itemid)

    local _lineSp = cc.Sprite:create("res/image/plugin/compose/compose_line.png")
    _lineSp:setPosition(cc.p(posX,_itemBottom:getBoundingBox().y-87))    
    self.itemInfo_bg:addChild(_lineSp)
    _lineSp:setOpacity(0)
    --四个材料
    self:setMaterialItems()

    --最多可制作
    local _maxMakeNumTitle = XTHDLabel:create("当前最多可制作" .. ": ",18)
    _maxMakeNumTitle:enableShadow(XTHD.resource.textColor.anhong_text,cc.size(0.4,-0.4),0.4)
    _maxMakeNumTitle:setColor(cc.c3b(0,0,0))
    local _maxMakeNum = getCommonWhiteBMFontLabel(self.maxMakeCount or 0)
    _maxMakeNum:setAnchorPoint(cc.p(0,0.5))
    _maxMakeNum:setName("maxMakeNum")
    _maxMakeNumTitle:setPosition(cc.p(posX - _maxMakeNum:getContentSize().width/2,_lineSp:getBoundingBox().y-20))
    _maxMakeNum:setPosition(cc.p(_maxMakeNumTitle:getBoundingBox().x+_maxMakeNumTitle:getBoundingBox().width,_maxMakeNumTitle:getPositionY()-7))
    self.itemInfo_bg:addChild(_maxMakeNumTitle)
    self.itemInfo_bg:addChild(_maxMakeNum)

	--道具名
	local str = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = _itemid}).name
	local itemName = XTHDLabel:create(str,18)
	itemName:setName("itemName")
    itemName:enableShadow(XTHD.resource.textColor.anhong_text,cc.size(0.4,-0.4),0.4)
    itemName:setColor(cc.c3b(139,69,19))
	itemName:setPosition(cc.p(posX - _maxMakeNum:getContentSize().width/2 + 7,_lineSp:getBoundingBox().y + 110))
	self.itemInfo_bg:addChild(itemName)

    local _numShowPosY = _maxMakeNumTitle:getBoundingBox().y-30
	--制作数量
	-- local _createNameLabel = XTHDLabel:create(LANGUAGE_NAMES.number..":",self._fontSize,"res/fonts/round_body.ttf")----"数量："
    local _createNameLabel = XTHDLabel:createWithSystemFont(LANGUAGE_NAMES.number..":",XTHD.SystemFont,self._fontSize)
    _createNameLabel:setAnchorPoint(cc.p(1,0.5))
	_createNameLabel:setColor(cc.c3b(4,4,4))
    --_createNameLabel:enableOutline(cc.c4b(45,13,103,255),2)
    -- local _maxButton = XTHD.createMaxBtn()
    local _maxButton = XTHDPushButton:createWithParams({
            normalFile   = "res/image/common/btn/btn_max_normal.png",
            selectedFile = "res/image/common/btn/btn_max_selected.png",
            musicFile = XTHD.resource.music.effect_btn_common
        })
    _maxButton:setAnchorPoint(cc.p(0,0.5))
    _maxButton:setTouchEndedCallback(function()
            if self._createNumLabel~=nil and self.maxMakeCount and tonumber(self.maxMakeCount)>1 then
                self:setMakeNumLabel(self.maxMakeCount or 1)
            end
        end)
    local _createNum_bg = ccui.Scale9Sprite:create("res/image/friends/input_bg.png")
    _createNum_bg:setContentSize(147,39)
	_createNum_bg:setAnchorPoint(cc.p(0.5,0.5))
	_createNum_bg:setPosition(cc.p(posX,_numShowPosY))
	self.itemInfo_bg:addChild(_createNum_bg)

	self._createNumLabel = XTHDLabel:create("1",self._fontSize)
    -- getCommonWhiteBMFontLabel("1")
    -- XTHDLabel:create("1",self._fontSize)
	self._createNumLabel:setAnchorPoint(cc.p(0.5,0.5))
	self._createNumLabel:setColor(XTHD.resource.textColor.white_text)
    self._createNumLabel:enableShadow(XTHD.resource.textColor.white_text,cc.size(0.4,-0.4),0.4)
	self._createNumLabel:setPosition(cc.p(_createNum_bg:getContentSize().width/2,_createNum_bg:getContentSize().height/2))
	_createNum_bg:addChild(self._createNumLabel)
	--加
	local _addBtn = self:createBtn("add")
	_addBtn:setAnchorPoint(cc.p(0,0.5))
	_addBtn:setPosition(cc.p(_createNum_bg:getBoundingBox().x+_createNum_bg:getBoundingBox().width + 5,_createNum_bg:getPositionY()))
	self.itemInfo_bg:addChild(_addBtn)
	--减
	local _reduceBtn = self:createBtn("cut")
	_reduceBtn:setAnchorPoint(cc.p(1,0.5))
	_reduceBtn:setPosition(cc.p(_createNum_bg:getBoundingBox().x - 5,_createNum_bg:getPositionY()))
	self.itemInfo_bg:addChild(_reduceBtn)

	_createNameLabel:setPosition(cc.p(_reduceBtn:getBoundingBox().x,_createNum_bg:getPositionY()))
    _maxButton:setPosition(cc.p(_addBtn:getBoundingBox().x + _addBtn:getBoundingBox().width + 5,_createNum_bg:getPositionY()))
    self.itemInfo_bg:addChild(_maxButton)
	self.itemInfo_bg:addChild(_createNameLabel)

    
    local function editBoxEventHandle(eventName,pSender)
        if eventName == "began" then
            pSender:setText("")
            self._createNumLabel:setVisible(false)
        elseif eventName == "ended" or eventName == "return" then
            local msgStr = pSender:getText()
            self._createNumLabel:setVisible(true)
            self:setMakeNumLabel(tonumber(msgStr))
            pSender:setText("")
        elseif eventName == "changed" then
        else
            self._createNumLabel:setVisible(true)
            self:setMakeNumLabel(tonumber(pSender:getText()))
            pSender:setText("")
        end
    end
    local _noticeEdit = ccui.EditBox:create(cc.size(_createNum_bg:getContentSize().width,_createNum_bg:getContentSize().height - 10),ccui.Scale9Sprite:create(),nil,nil)
    _noticeEdit:setFontName("Helvetica")
    _noticeEdit:setFontSize(self._fontSize)
    _noticeEdit:setMaxLength(10)
	 _noticeEdit:setFontSize(20)
	_noticeEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    _noticeEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    _noticeEdit:setFontColor(BangPaiFengZhuangShuJu.getTextColor("baise"))
    _noticeEdit:registerScriptEditBoxHandler(editBoxEventHandle)
    _noticeEdit:setAnchorPoint(cc.p(0.5,0.5))
    _noticeEdit:setPosition(cc.p(_createNum_bg:getContentSize().width*0.5,_createNum_bg:getContentSize().height*0.5))
	_noticeEdit:setTextHorizontalAlignment(1)
    _createNum_bg:addChild(_noticeEdit)

    --属性
    local _costPosY = _numShowPosY-40
    --合成信息
    local _costTitleLabel = XTHDLabel:create(LANGUAGE_VERBS.cost1..":",self._fontSize - 2)------消耗："
    _costTitleLabel:setColor(XTHD.resource.textColor.gray_text)
    _costTitleLabel:setAnchorPoint(cc.p(0,0.5))
    _costTitleLabel:enableShadow(XTHD.resource.textColor.gray_text,cc.size(0.4,-0.4),1)
    _costTitleLabel:setPosition(cc.p(posX-143,_costPosY))
    self.itemInfo_bg:addChild(_costTitleLabel)

    local _costMoneyData = self:getCurrentCostMoneyData()
    self._costSpr = cc.Sprite:create(_costMoneyData._costsprPath or nil)
    self._costSpr:setAnchorPoint(cc.p(0,0.5))
    self._costSpr:setPosition(cc.p(_costTitleLabel:getBoundingBox().x+_costTitleLabel:getBoundingBox().width,_costPosY))
    self.itemInfo_bg:addChild(self._costSpr)
    self._costNumLabel = XTHDLabel:create(getHugeNumberWithLongNumber(_costMoneyData._costNum,1000000),self._fontSize)
    -- getCommonWhiteBMFontLabel(getHugeNumberWithLongNumber(_costMoneyData._costNum,1000000))
    -- XTHDLabel:create(_costNum,self._fontSize)
    self._costNumLabel:setAnchorPoint(cc.p(0,0.5))
    self._costNumLabel:setColor(XTHD.resource.textColor.gray_text)
    self:setCostNumState(_costMoneyData)
    self._costNumLabel:setPosition(cc.p(self._costSpr:getBoundingBox().x + self._costSpr:getBoundingBox().width + 10,_costPosY))
    self.itemInfo_bg:addChild(self._costNumLabel)
    -- 成功率
    local _successRateTitleLabel = XTHDLabel:create(LANGUAGE_KEY_SUCCESSRATE .. ": ",self._fontSize - 2)-----"成功率: "
    _successRateTitleLabel:setColor(XTHD.resource.textColor.gray_text)
    _successRateTitleLabel:enableShadow(XTHD.resource.textColor.gray_text,cc.size(0.4,-0.4),0.4)
    _successRateTitleLabel:setAnchorPoint(cc.p(0,0.5))
    _successRateTitleLabel:setPosition(cc.p(posX+60,_costPosY))
    self.itemInfo_bg:addChild(_successRateTitleLabel)
    local _successStr = self.currentItemData.probability or 0
    self._successRateNumlabel = XTHDLabel:create(_successStr .. "%",self._fontSize - 2)
    self._successRateNumlabel:setColor(XTHD.resource.textColor.green_text)
    self._successRateNumlabel:enableShadow(XTHD.resource.textColor.green_text,cc.size(0.4,-0.4),0.4)
    self._successRateNumlabel:setAnchorPoint(cc.p(0,0.5))
    self._successRateNumlabel:setPosition(cc.p(_successRateTitleLabel:getBoundingBox().x + _successRateTitleLabel:getBoundingBox().width,_successRateTitleLabel:getPositionY()))
    self.itemInfo_bg:addChild(self._successRateNumlabel) 
end
--设置头像
function TieJiangPuLayer:setLeftLayerItemSpr(_itemid)
    if self._produceItemBg == nil then
        return
    end
    if self._produceItemBg:getChildByName("produceItem") then 
        self._produceItemBg:removeAllChildren()
    end
    local _currentItem = ItemNode:createWithParams({
            dbId = nil,
            itemId = _itemid,
            _type_ = 4,
            touchShowTip = true
        })
    _currentItem:setName("produceItem")
    _currentItem:setPosition(cc.p(self._produceItemBg:getContentSize().width/2+1,self._produceItemBg:getContentSize().height/2+3))
    self._produceItemBg:addChild(_currentItem)
end
--设置四个材料的显示
function TieJiangPuLayer:setMaterialItems()
	if self.materialItems then
    	for i=1,4 do
    		if self.materialItems["item" .. i] then
    			self.materialItems["item" .. i]:removeAllChildren()
    			self.materialItems["item" .. i]:removeFromParent()
    			self.materialItems["item" .. i] = nil
    		end
    	end
    end
    self.materialItems = {}
    local _materialNum = 0
    for i=1,4 do
        if self.currentItemData["need" .. i]==nil or tonumber(self.currentItemData["num" .. i])<1 then
            break
        end
        _materialNum = i
    end
    local _itemBgTable = SortPos:sortFromMiddle(cc.p(self.itemInfo_bg:getContentSize().width/2 + 135,self.itemInfo_bg:getContentSize().height - 10 - 192-42) ,_materialNum,81+15)
    local _itemWidth = 68
    self.countLabel = {}
    for i=1,_materialNum do
    	local _itemid = self.currentItemData["need" .. i] or nil
    	local _itemNum = self.currentItemData["num" .. i] or 0
    	
        self.countLabel[tostring(i)] = nil
        --没有需求道具返回
    	if _itemid == nil then
    		break
    	end
    	local _itemidData_ = self.iteminfoData[tostring(_itemid)] or nil
        
        local _itemBg = cc.Sprite:create("res/image/plugin/compose/compose_materialBg.png")        
        _itemBg:setPosition(_itemBgTable[i])
        _itemBg:setCascadeOpacityEnabled(true)
        _itemBg:setCascadeColorEnabled(true)
        self.materialItems["item" .. i] = _itemBg
        self.itemInfo_bg:addChild(_itemBg)

        local _itemSpr = nil
        --背包中有这个道具
    	if self.dynamicItemData[tostring(_itemid)]~=nil and next(self.dynamicItemData[tostring(_itemid)])~=nil then
    		_itemSpr = ItemNode:createWithParams({
		        dbId = nil,
		        itemId = _itemid,
		        _type_ = 4,
		        touchShowTip = false,
                endCallback = function()
                    --掉落途径
                    -- self:gotoDropWay(_itemid)
                end
		    })
            local _hasNum_ = getHugeNumberWithLongNumber(self.dynamicItemData[tostring(_itemid)].count,1000)
            local _needNum_ = getHugeNumberWithLongNumber(_itemNum,1000)
		    self.countLabel[tostring(i)] = getCommonWhiteBMFontLabel(_hasNum_ .. "/" .. _needNum_)
		    self.countLabel[tostring(i)]:setAnchorPoint(cc.p(1,0))
		    self.countLabel[tostring(i)]:setPosition(cc.p(_itemSpr:getContentSize().width-5,-7))
            self.countLabel[tostring(i)]:setColor(cc.c4b(255,255,255,255))
		    _itemSpr:addChild(self.countLabel[tostring(i)])
		    if tonumber(_itemNum) > tonumber(self.dynamicItemData[tostring(_itemid)].count) then
		    	self.countLabel[tostring(i)]:setColor(cc.c4b(255,0,0,255))
                self:setCannotMakeReason("noMaterial")
		    end
    	else   --背包中没有这个道具
    		local _grayPath = XTHD.resource.getItemImgById(_itemidData_["resourceid"])
    		_itemSpr = cc.Sprite:create(_grayPath)
            XTHD.setGray(_itemSpr,true)
            
    		local _bgSpr = cc.Sprite:create(XTHD.resource.getQualityItemBgPath(1))
            _bgSpr:setAnchorPoint(cc.p(0.5,0.5))
            _bgSpr:setPosition(cc.p(_itemSpr:getContentSize().width/2,_itemSpr:getContentSize().height/2))
            _itemSpr:addChild(_bgSpr)
            XTHD.createStoneItemChip({
                itemtype = _itemidData_.type,
                rank = _itemidData_.rank,
                level = _itemidData_.level,
                target = _bgSpr,
                isGrey = true,
            })
            local _needNum_ = getHugeNumberWithLongNumber(_itemNum,1000)
            self.countLabel[tostring(i)] = getCommonWhiteBMFontLabel(0 .. "/" .. _needNum_)
            self.countLabel[tostring(i)]:setAnchorPoint(cc.p(1,0))
            self.countLabel[tostring(i)]:setPosition(cc.p(_bgSpr:getContentSize().width-5,-7))
            self.countLabel[tostring(i)]:setColor(cc.c4b(255,0,0,255))
            _bgSpr:addChild(self.countLabel[tostring(i)])

            local _normalSpr = cc.Sprite:create("res/image/plugin/hero/label_add_green.png")
    		local _selectSpr = cc.Sprite:create("res/image/plugin/hero/label_add_green.png")
    		_selectSpr:setScale(0.95)
    		local _noitemButton = XTHDPushButton:createWithParams({
    			normalNode = _normalSpr
    			,selectedNode = _selectSpr
                ,touchSize = cc.size(_itemSpr:getBoundingBox().width,_itemSpr:getBoundingBox().height)
                ,musicFile = XTHD.resource.music.effect_btn_common
    			})
    		_noitemButton:setTouchEndedCallback(function()
    				--掉落途径
                    self:gotoDropWay(_itemid)
    			end)
    		_noitemButton:setAnchorPoint(cc.p(0.5,0.5))
    		_noitemButton:setPosition(cc.p(_itemSpr:getContentSize().width/2,_itemSpr:getContentSize().height/2))
    		_itemSpr:addChild(_noitemButton)

            self:setCannotMakeReason("noMaterial")
    	end
    	_itemSpr:setScale(_itemWidth/80)
    	_itemSpr:setPosition(cc.p(_itemBg:getContentSize().width/2,_itemBg:getContentSize().height/2))
		_itemBg:addChild(_itemSpr)
    end
end
--加号减号按钮
function TieJiangPuLayer:createBtn(_type)
	local _path = "addDot"
	if _type == "cut" then
		_path = "reduceDot"
	end
    local _tousize = cc.size(60,60)
	local _btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/common/btn/btn_" .. _path .. "_normal.png"
			,selectedFile = "res/image/common/btn/btn_" .. _path .. "_selected.png"
            ,touchSize = _tousize
            ,needEnableWhenOut = true
            ,musicFile = XTHD.resource.music.effect_btn_common
		})
    _btn:setScale(0.8)
	_btn._changeValue = 1
	
	_btn.numbers = 0
	_btn.is_click = true
	_btn.ex_num = 0
	_btn.scheduleFunc = nil
	_btn.conditionFunc = nil
	_btn._toastStr = LANGUAGE_TIPS_WORDS101-----"大侠，不能再多了"
	if _type == "cut" then
		_btn._changeValue = -1
		_btn.conditionFunc = function()
			if _btn.ex_num > 1 then
				return true
	        end
	        return false
		end
		_btn._toastStr = LANGUAGE_TIPS_WORDS102-------"大侠，不能再少了"
	else
		_btn._changeValue = 1
		_btn.conditionFunc = function()
			if _btn.ex_num < self.maxMakeCount then
				return true
			end
			return false
		end
		_btn._toastStr = LANGUAGE_TIPS_WORDS101-----"大侠，不能再多了"
	end
	_btn.scheduleFunc = function()
			if true == _btn.conditionFunc() then
	            _btn.ex_num = _btn.ex_num + _btn._changeValue
	            _btn.numbers = _btn.numbers + 1
	        else
	            _btn:stopAllActions()
	            XTHDTOAST(_btn._toastStr)
	            _btn.numbers = 0
	        end
		end
	--[[按钮点击和长按操作]]
    _btn.quickExNum = function(  )
    	_btn.ex_num = tonumber(self._createNumLabel:getString())
        _btn.scheduleFunc()
        if tonumber(self.maxMakeCount)<tonumber(_btn.ex_num) then
            _btn:stopAllActions()
            self:showCannotMakeReason({self.cannotMakeReason})
            return
        else
            self:setMakeNumLabel(_btn.ex_num)
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
        -- 延时多少秒操作，此处是延时1秒后回调pressLongTimeCallback_reduce
        performWithDelay(_btn,_btn.pressLongTimeCallback_reduce,0.3)
        
    end)
    _btn:setTouchEndedCallback(function()
    	_btn.ex_num = tonumber(self._createNumLabel:getString())
        if _btn.is_click then
            _btn.scheduleFunc()
            if tonumber(self.maxMakeCount)<tonumber(_btn.ex_num) then
                _btn:stopAllActions()
                self:showCannotMakeReason({self.cannotMakeReason})
            else
                self:setMakeNumLabel(_btn.ex_num)
            end
        end
        _btn.is_click = true
        _btn:stopAllActions()
        _btn.numbers = 0
    end)

	return _btn
end

--设置标签点击函数
function TieJiangPuLayer:setTabClickFunc(_idx)
	if self._type == _idx then
		return
	end
	self._type = _idx
	self._equipIcon = {}
--	for i=1,self._tabkeNum do
--		if self._tabBtn[i] then
--			self._tabBtn[i]:setSelected(false)
--            self._tabBtn[i]:setLocalZOrder(0)
--		end
--	end
--	self._tabBtn[_idx]:setSelected(true)
--    self._tabBtn[_idx]:setLocalZOrder(1)
--	self:removeSelectedCell()
	self._selectedOrder = 1
	self:setSelectedBtnCallback(_idx)
	
	self:setCurrentItemData(1)
	self:refreshItemInfoLayer()
end

--移除选中cell
function TieJiangPuLayer:removeSelectedCell()
	if self._selectedCell~= nil then
		self._selectedCell.isSelected = false
		self._selectedCell:removeFromParent()
		self._selectedCell = nil
	end
end

--网络请求
function TieJiangPuLayer:httpToMakeItems()
	if self.configId==nil then
		XTHDTOAST(LANGUAGE_TIPS_WORDS113)------"道具无法制作")
		return 
	end
	local _countStr = self._createNumLabel:getString() or 0
    if tonumber(_countStr)<1 then
        XTHDTOAST(LANGUAGE_TIPS_WORDS278)
    end
    local _lightPosArr = {}
    if self.materialItems then
        for i=1,4 do
            if self.materialItems["item" .. i]~=nil then
                local _pos = self.materialItems["item" .. i]:convertToWorldSpace(cc.p(0.5,0.5))
                _pos = cc.p(_pos.x + self.materialItems["item" .. i]:getBoundingBox().width/2,self.materialItems["item" .. i]:getBoundingBox().height/2 + _pos.y)
                _lightPosArr[i] = _pos
            else
                break
            end
        end
    end
    local _resultlayer = requires("src/fsgl/layer/TieJiangPu/TieJiangPuResultPopLayer.lua"):create(_lightPosArr)
    self:addChild(_resultlayer,3)
	ClientHttp:requestAsyncInGameWithParams({
    	modules = "composeItem?",
        params = {configId=self.configId,count=_countStr},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
        successCallback = function(data)
            data.allCount = tonumber(_countStr)
            if tonumber(data.result) == 0 or tonumber(data.result) == 3009 then
                data.allCount = tonumber(_countStr)
                self.isComposeItem = true
            	gameUser.setFeicui(data.feicui)
            	gameUser.setGold(data.gold)

                _resultlayer:showItemResult(data,function(data)
                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})

                        --数据库刷新
                        --修改消耗品的数量，为0删除
                        for i=1,#data["items"] do
                            local _dbid = data.items[i].dbId
                            if data.items[i].count and tonumber(data.items[i].count)>0 then
                                DBTableItem.updateCount(gameUser.getUserId(),data.items[i],_dbid)
                            else
                                DBTableItem.deleteData(gameUser.getUserId(),_dbid)
                            end
                        end
                        --插入数据
                        -- local _newItemsTable = {}
                        for i=1,#data["newItems"] do
                            local _dbid = data["newItems"][i].dbId
                            if data["newItems"][i].item_type and tonumber(data["newItems"][i].item_type)==3 then
                                data.newItems[i].addCount = tonumber(data.newItems[i].count or 0)
                            else
                                local _itemData = self.dynamicItemData[tostring(data.newItems[i].itemId)] or {}
                                local _oldNumber = _itemData.count and tonumber(_itemData.count) or 0
                                local _addCount = tonumber(data.newItems[i].count) - tonumber(_oldNumber)
                                _addCount = _addCount>=0 and _addCount or 0
                                data.newItems[i].addCount = _addCount
                            end
                            if i>1 then
                                local _itemData = data.newItems[1]
                                if tonumber(_itemData.itemId) == tonumber(data.newItems[i].itemId) then
                                    _itemData.addCount = _itemData.addCount + data.newItems[i].addCount
                                end
                            end
                            DBTableItem.updateCount(gameUser.getUserId(),data["newItems"][i],_dbid)
                        end
                        self._createNumLabel:setString(1)
                        performWithDelay(self,function()
                                RedPointManage:reFreshDynamicItemData()
                                self:setCannotMakeReason()
                                self:refreshLayerAfterHttp()
                            end, 0.2)
                        return data
                        
                    end)
            else
                _resultlayer:removeFromParent()
            	XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)------ "网络请求失败") 
            end
        end,--成功回调
        failedCallback = function()
            _resultlayer:removeFromParent()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

--设置当前按钮是否可以制作，不可以制作的理由
function TieJiangPuLayer:setCannotMakeReason(_str)
    if _str == nil then
        self.produce_Btn.cannotMakeType = {}
        return
    end
    for i=1,#self.produce_Btn.cannotMakeType do
        if tostring(self.produce_Btn.cannotMakeType[i]) == tostring(_str) then
            return
        end
    end
    self.produce_Btn.cannotMakeType[#self.produce_Btn.cannotMakeType + 1] = _str
end
function TieJiangPuLayer:getCannotMakeReason()
    return self.produce_Btn.cannotMakeType or {}
end
function TieJiangPuLayer:removeCannotMakeReaon(_str)
    if _str==nil then
        return
    end
    for i=1,#self.produce_Btn.cannotMakeType do
        if tostring(self.produce_Btn.cannotMakeType[i]) == tostring(_str) then
            table.remove(self.produce_Btn.cannotMakeType,i)
            break
        end
    end
end
function TieJiangPuLayer:showCannotMakeReason(_typeData)
    if _typeData~=nil then
        if _typeData[1] == "noGold" then
            XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[1])
			local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=3})
			self:addChild(StoredValue, 3)
        elseif _typeData[1] == "noFeicui" then
            XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[2])
			local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=3})
			self:addChild(StoredValue, 3)
        elseif _typeData[1] == "noMaterial" then
            XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[3])
        elseif _typeData[1] == "noLevel" then
            XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[4])
        end
    end
end
--跳转界面
function TieJiangPuLayer:gotoDropWay(_itemid)
    local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
    local _layerid = 41
    popLayer = popLayer:create(_itemid,_layerid)
    popLayer:setName("dropPop")
    self:addChild(popLayer)
end

--获取当前消耗类型
function TieJiangPuLayer:getCurrentCostMoneyData()
    local _costMoneyData = {}
    _costMoneyData._costNum = 0
    _costMoneyData._haveNum = 0
    _costMoneyData._costType = "Gold"
    _costMoneyData._costsprPath = "res/image/common/header_gold.png"
    if self.currentItemData.needgold and tonumber(self.currentItemData.needgold)>0  then
        _costMoneyData._costNum = tonumber(self.currentItemData.needgold)
        _costMoneyData._haveNum = tonumber(gameUser.getGold())
        _costMoneyData._costType = "Gold"
        _costMoneyData._costsprPath = "res/image/common/header_gold.png"
    elseif self.currentItemData.needfc and tonumber(self.currentItemData.needfc) >0  then
        _costMoneyData._costNum = tonumber(self.currentItemData.needfc)
        _costMoneyData._haveNum = tonumber(gameUser.getFeicui())
        _costMoneyData._costType = "Feicui"
        _costMoneyData._costsprPath = "res/image/common/header_feicui.png"
    end
    return _costMoneyData
end

function TieJiangPuLayer:getNewContentOffset(_oldOrder,_newOrder)
    
    local _oldContentOffsetY = self._itemListTableView:getContentOffset().y
    local _oldSelectedOrder = _oldOrder or 0
    local _newSelectedOrder = _newOrder or 0
    local _subOrder = _newSelectedOrder - _oldSelectedOrder
    local _newContentOffsetY = _oldContentOffsetY+self.tableViewCellSize.height*_subOrder
    --tableview偏移量最大值
    local _allContentOffsetHeight = self.tableViewSize.height - self.tableViewCellSize.height*self.classifyItemNumber
    --tableview偏移量最大值大于0，表示tableview不需要滑动
    if _allContentOffsetHeight>0 then
        _newContentOffsetY = _allContentOffsetHeight
    --新偏移量大于0，不能为0
    elseif _newContentOffsetY>0 then
        _newContentOffsetY = 0
    elseif _newContentOffsetY<_allContentOffsetHeight then
        _newContentOffsetY = _allContentOffsetHeight
    end
    return _newContentOffsetY
end

--改变花费数量的状态
function TieJiangPuLayer:setCostNumState(_costData,_makeNum)
    if _costData ==nil or next(_costData)==nil or self._costNumLabel ==nil then
        return
    end
    local _costMoneyData = _costData
    local _makeNum_ = _makeNum or 1
    if (_costMoneyData._costNum*_makeNum_)>_costMoneyData._haveNum then
        self._costNumLabel:setColor(XTHD.resource.textColor.anhong_text)
        self:setCannotMakeReason("no" .. _costMoneyData._costType)
    else
        self._costNumLabel:setColor(XTHD.resource.textColor.gray_text)
        self:removeCannotMakeReaon("no" .. _costMoneyData._costType)
    end
end

--改变数量
function TieJiangPuLayer:setMakeNumLabel(_num)
    if self._createNumLabel == nil or _num==nil then
        return
    end
    if _num>self.maxMakeCount then
        _num = self.maxMakeCount
    elseif _num <0 then
        _num = 0
    end
    self._createNumLabel:setString(_num)
    self:refreshMaterialValue()
end

----------------------刷新Began---------------------------
--刷新翡翠或银两的需求状态
function TieJiangPuLayer:reFreshMoneyCostState(refreshSpr)
    local _costMoneyData = self:getCurrentCostMoneyData()
    local _number_ = tonumber(self._createNumLabel:getString()) or 1
    if self._costNumLabel~=nil then
        self._costNumLabel:setString(getHugeNumberWithLongNumber(_costMoneyData._costNum * _number_,1000000))
        self:setCostNumState(_costMoneyData,_number_)
    end
    if refreshSpr~=nil and refreshSpr==true and self._costSpr~=nil then
        self._costSpr:initWithFile(_costMoneyData._costsprPath)
        self._costSpr:setAnchorPoint(cc.p(0,0.5))
    end
end
--刷新材料的值
function TieJiangPuLayer:refreshMaterialValue()
    self:setCannotMakeReason()
    if next(self.countLabel)==nil then
        return
    end
    local _number = tonumber(self._createNumLabel:getString()) or 1
    for i=1,4 do
        if self.countLabel[tostring(i)]~=nil then
            local _itemid = self.currentItemData["need" .. i] or nil
            local _itemNum = self.currentItemData["num" .. i] or 0
            
            --没有需求道具返回
            if _itemid == nil then
                break
            end
            local _itemidCount_ = self.dynamicItemData[tostring(_itemid)] or {}
            _itemidCount_ = _itemidCount_ and _itemidCount_.count or 0
            local _hasNum_ = getHugeNumberWithLongNumber(_itemidCount_,1000)
            local _needNum_ = getHugeNumberWithLongNumber(_itemNum*_number,1000)
            self.countLabel[tostring(i)]:setString(_hasNum_ .. "/" .. _needNum_)
            if tonumber(_itemNum*_number) > tonumber(_itemidCount_) then
                self.countLabel[tostring(i)]:setColor(cc.c4b(255,0,0,255))
                self:setCannotMakeReason("noMaterial")
            else
                self.countLabel[tostring(i)]:setColor(cc.c4b(255,255,255,255))
            end
        end
    end
    self:reFreshMoneyCostState()
end

--刷新左边item信息框
function TieJiangPuLayer:refreshItemInfoLayer()
    self:setCannotMakeReason()
--    if self._selectedCell==nil then
--        return
--    end
--    --左侧列表
--    local _cellBg_ = self._selectedCell
--    local _prompt = _cellBg_:getChildByName("promptLabel")
--    local _labelType = _prompt._labelType or nil
--    if _labelType and tonumber(_labelType)==2 then
--        self:setCannotMakeReason("noMaterial")
--    elseif _labelType and tonumber(_labelType)==3 then
--        self:setCannotMakeReason("noLevel")
--    end

    --信息框内容
    local _itemid = self.currentItemData.itemid
    self:setLeftLayerItemSpr(_itemid)
    --四个材料
    self:setMaterialItems()
	--道具名
	if self.itemInfo_bg:getChildByName("itemName") then
        self.itemInfo_bg:getChildByName("itemName"):setString(gameData.getDataFromCSV("ArticleInfoSheet",{itemid = _itemid}).name)
    end
    --最大制作数量
    if self.itemInfo_bg:getChildByName("maxMakeNum") then
        self.itemInfo_bg:getChildByName("maxMakeNum"):setString(self.maxMakeCount or 0)
    end
    --属性
    if self._createNumLabel~=nil then
        self._createNumLabel:setString("1")
    end
    self:reFreshMoneyCostState(true)
    local _successStr = self.currentItemData.probability or 0
    if self._successRateNumlabel~=nil then
        self._successRateNumlabel:setString(_successStr .. "%")
    end
end
--刷新界面
function TieJiangPuLayer:refreshLayerAfterHttp()
    self:getDynamicItemData()
    self:setComposeDataPrompt()
    --刷新选中项
    self:setSelectedBtnCallback(self._type or 5,(self.configId or 1))
    self:setCurrentItemData(self._selectedOrder or 1)
    self:refreshItemInfoLayer()
end

--跳转刷新信息
function TieJiangPuLayer:reFreshLayerAfterTurnDrop()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ITEMDROP_HASNUMBER})
    self:refreshLayerAfterHttp()
end
----------------------刷新Began---------------------------

----------------------数据Began---------------------------
function TieJiangPuLayer:getDBData()
    self:getDynamicItemData()
	self:getStaticItemInfoData()
	-- self:getStaticItemEquipData()
	-- self:getStaticGodbeaststoneData()
	self:getStaticeComposeData()
end
--动态item
function TieJiangPuLayer:getDynamicItemData()
	self.dynamicItemData = {}
    local _table = DBTableItem:getDataByID()
    for k,v in pairs(_table) do
        self.dynamicItemData[tostring(v.itemid)] = v
    end
end
--ItemInfo
function TieJiangPuLayer:getStaticItemInfoData()
	self.iteminfoData = {}
	self.iteminfoData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
	-- for k,v in pairs(_table) do
	-- 	self.iteminfoData[tostring(v.itemid)] = v
	-- end
end
--ItemEquip
-- function TieJiangPuLayer:getStaticItemEquipData()
-- 	self.itemEquipData = {}
-- 	local _table = gameData.getDataFromCSV("EquipInfoList")
-- 	for k,v in pairs(_table) do
-- 		self.itemEquipData[tostring(v.itemid)] = v
-- 	end
-- end
--Runelist
-- function TieJiangPuLayer:getStaticGodbeaststoneData()
-- 	self.godbeaststoneData = {}
-- 	local _table = gameData.getDataFromCSV("Runelist")
-- 	for k,v in pairs(_table) do
-- 		self.godbeaststoneData[tostring(v.id)] = v
-- 	end
-- end
--ItemCompose
function TieJiangPuLayer:getStaticeComposeData()
    local _playerLevel = tonumber(gameUser.getLevel())
	--_property字段中存放该itemid的相关信息
	self.itemComposeData = {}
	-- self.itemsData = {} 
    local _table = gameData.getDataFromCSV("SmithyMakingList")
    table.sort(_table,function(data1,data2)
        return tonumber(data1.needlv)<tonumber(data2.needlv)
        end)
    --按照玩家等级达到需求等级。显示等级达到的，和下一个等级档次的。这个table，分别有4种分类的下一个等级档次
    local _nextLevelFloor ={
        ["1"] = 0,
        ["2"] = 0,
        ["3"] = 0,
        ["4"] = 0
    }
    --
    for i=1,#_table do
        --[[有一个当前等级的最大上限。如果item的需求等级小于玩家当前等级，最大上限为玩家当前等级，
        如果某一item大于玩家等级(按需求等级从小到大排)，最大上限为这个item的需求等级。]]
        --判断_nextLevelFloor相应type值是否为0，不是说明
        local _itemType = tonumber(_table[i].itemtype)
        if _itemType~=0 then
            local _itemid_needLevel = tonumber(_table[i].needlv)
            local _upLevel = _playerLevel       --等级上限
            if _playerLevel<_itemid_needLevel and (not _nextLevelFloor[tostring(_itemType)] or tonumber(_nextLevelFloor[tostring(_itemType)])==0) then
                _nextLevelFloor[tostring(_itemType)] =_itemid_needLevel
            end
            if _nextLevelFloor[tostring(_itemType)] and tonumber(_nextLevelFloor[tostring(_itemType)])>0 then
                _upLevel =tonumber(_nextLevelFloor[tostring(_itemType)])
            end
            if _upLevel>=_itemid_needLevel then
                local _itemsdata = {}
                self.itemComposeData[#self.itemComposeData + 1] = _table[i]
            end
        end
    end
	--按id排序
	table.sort(self.itemComposeData,function(data1,data2)
		return tonumber(data1.id)<tonumber(data2.id)
		end)
    self:setComposeDataPrompt()
end

function TieJiangPuLayer:setSelectedBtnCallback(_type,_configId)
	local c_type = _type or 1
	--
--	print("铁匠铺对应的数据为：".._type)
--	print_r(self.itemComposeData)
	table.sort(self.itemComposeData,function(data1,data2)
		local _multiple1 = 100000
		if tonumber(data1.itemtype)==tonumber(c_type) then
			_multiple1 = 10000
		end
		local _data1Num = tonumber(data1.itemtype)*_multiple1 + tonumber(data1.id) --+ tonumber(data1.prompt)*1000
		local _multiple2 = 100000
		if tonumber(data2.itemtype)==tonumber(c_type) then
			_multiple2 = 10000
		end
		local _data2Num = tonumber(data2.itemtype)*_multiple2 + tonumber(data2.id) --+ tonumber(data2.prompt)*1000
		return tonumber(_data1Num)<tonumber(_data2Num)

		end)
    
	self.classifyItemNumber = 0
	for i=1,#self.itemComposeData do
		if tonumber(self.itemComposeData[i].itemtype) ~=tonumber(c_type) then
			break
        else
            self.classifyItemNumber = i
		end
	end
    if _configId~=nil then
        local _oldSelectedOrder = self._selectedOrder
        
        for i=1,#self.itemComposeData do
            if tonumber(self.itemComposeData[i].id) ==tonumber(_configId) then
                self._selectedOrder = i
                break
            end
        end
        local _isEnoughBoolValue = self.itemComposeData[tonumber(self._selectedOrder)].prompt or nil
        --如果不为1，那么表示材料不足
        -- print("8431>>>_isEnoughBoolValue>" .. _isEnoughBoolValue)
        if _isEnoughBoolValue==nil or tonumber(_isEnoughBoolValue)~=1 then
            self._selectedOrder = 1
            self._itemListTableView:reloadData()
            return
        end
        local _newContentOffsetY = self:getNewContentOffset(_oldSelectedOrder,self._selectedOrder)
        -- self._itemListTableView:reloadDataAndScrollToCurrentCell()
        self._itemListTableView:reloadData()
--        self._itemListTableView:setContentOffset(cc.p(0,_newContentOffsetY))
    else
        self._itemListTableView:reloadData()
    end
	
    -- self._itemListTableView:scrollToCell(self._selectedOrder-1,false)
end

--排序重新加载tableview
--function TieJiangPuLayer:setSelectedBtnCallback(_type,_configId)
--	local c_type = _type or 1
--    -- c_type = 2
--    self:setTabButtonRedPoint(_type)
--	--
--	print("铁匠铺对应的数据为：".._type)
--	print_r(self.itemComposeData)
--	table.sort(self.itemComposeData,function(data1,data2)
--		local _multiple1 = 50000
--		if tonumber(data1.itemtype)==tonumber(c_type) then
--			_multiple1 = 10000
--		end
--		local _data1Num = tonumber(data1.itemtype)*_multiple1 + tonumber(data1.id) + tonumber(data1.prompt)*1000
--		local _multiple2 = 50000
--		if tonumber(data2.itemtype)==tonumber(c_type) then
--			_multiple2 = 10000
--		end
--		local _data2Num = tonumber(data2.itemtype)*_multiple2 + tonumber(data2.id)+ tonumber(data2.prompt)*1000
--		return tonumber(_data1Num)<tonumber(_data2Num)

--		end)

--	self.classifyItemNumber = 0
--	for i=1,#self.itemComposeData do
--		if tonumber(self.itemComposeData[i].itemtype) ~=tonumber(c_type) then
--			break
--        else
--            self.classifyItemNumber = i
--		end
--	end
--    if _configId~=nil then
--        local _oldSelectedOrder = self._selectedOrder

--        for i=1,#self.itemComposeData do
--            if tonumber(self.itemComposeData[i].id) ==tonumber(_configId) then
--                self._selectedOrder = i
--                break
--            end
--        end
--        local _isEnoughBoolValue = self.itemComposeData[tonumber(self._selectedOrder)].prompt or nil
--        --如果不为1，那么表示材料不足
--        -- print("8431>>>_isEnoughBoolValue>" .. _isEnoughBoolValue)
--        if _isEnoughBoolValue==nil or tonumber(_isEnoughBoolValue)~=1 then
--            self._selectedOrder = 1
--            self._itemListTableView:reloadData()
--            return
--        end
--        local _newContentOffsetY = self:getNewContentOffset(_oldSelectedOrder,self._selectedOrder)
--        -- self._itemListTableView:reloadDataAndScrollToCurrentCell()
--        self._itemListTableView:reloadData()
--        self._itemListTableView:setContentOffset(cc.p(0,_newContentOffsetY))
--    else
--        self._itemListTableView:reloadData()
--    end

--    -- self._itemListTableView:scrollToCell(self._selectedOrder-1,false)
--end

--设置最大可制作数量
function TieJiangPuLayer:setMaxMakeNumber()
    local _costMoneyCount = 0
    local _reason = nil
    local _costMoneyData = self:getCurrentCostMoneyData()
    _costMoneyCount = math.floor(tonumber(_costMoneyData._haveNum)/tonumber(_costMoneyData._costNum))
    _costMoneyCount = tonumber(_costMoneyCount >0 and _costMoneyCount or 0)
    _reason = "no" .. _costMoneyData._costType
    local _costItemCount = _costMoneyCount
    for i=1,4 do
        local _itemid = self.currentItemData["need" .. i] or nil
        local _itemNum = self.currentItemData["num" .. i] or 0
        
        --没有需求道具返回
        if _itemid == nil then
            break
        end
        local _itemidCount_ = self.dynamicItemData[tostring(_itemid)] or {}
        _itemidCount_ = _itemidCount_ and _itemidCount_.count or 0
        local _itemmakeCount = math.floor(tonumber(_itemidCount_)/tonumber(_itemNum))
        _itemmakeCount = tonumber(_itemmakeCount>0 and _itemmakeCount or 0)
--        if _itemmakeCount<_costItemCount then
            _costItemCount = _itemmakeCount
            _reason = "noMaterial"
--        end
    end
    self.maxMakeCount = tonumber(_costItemCount) -->0 and _costItemCount or 0
    self.cannotMakeReason = _reason
end

function TieJiangPuLayer:setCurrentItemData(_id)
	self.currentItemData = {}
	self.currentItemData = self.itemComposeData[tonumber(_id)] or {}
	self.configId = self.currentItemData["id"] or nil
    self.maxMakeCount = 1
    self.cannotMakeReason = nil
    self:setMaxMakeNumber()
end

function TieJiangPuLayer:getMaxCountById(id)
    local currentItemData = self.itemComposeData[tonumber(id)] or {}
    local _costMoneyCount = 0
    local _costMoneyData = self:getCurrentCostMoneyData()
    _costMoneyCount = math.floor(tonumber(_costMoneyData._haveNum)/tonumber(_costMoneyData._costNum))
    _costMoneyCount = tonumber(_costMoneyCount >0 and _costMoneyCount or 0)
    local _costItemCount = _costMoneyCount
    for i=1,4 do
        local _itemid = currentItemData["need" .. i] or nil
        local _itemNum = currentItemData["num" .. i] or 0
        
        --没有需求道具返回
        if _itemid == nil then
            break
        end
        local _itemidCount_ = self.dynamicItemData[tostring(_itemid)] or {}
        _itemidCount_ = _itemidCount_ and _itemidCount_.count or 0
        local _itemmakeCount = math.floor(tonumber(_itemidCount_)/tonumber(_itemNum))
        _itemmakeCount = tonumber(_itemmakeCount>0 and _itemmakeCount or 0)
        if _itemmakeCount<_costItemCount then
            _costItemCount = _itemmakeCount
        end
    end
    local maxMakeCount = tonumber(_costItemCount)>0 and _costItemCount or 0
    return maxMakeCount
end

----------------------数据End---------------------------

function TieJiangPuLayer:create()
	local _layer = self.new()
	return _layer
end
return TieJiangPuLayer