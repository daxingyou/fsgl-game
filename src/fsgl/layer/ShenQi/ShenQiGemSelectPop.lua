--Created By Liuluyang 2015年06月12日
local ShenQiGemSelectPop = class("ShenQiGemSelectPop",function ()
	return XTHD.createPopLayer()
end)

function ShenQiGemSelectPop:ctor(allGem,callFunc)
	self:initData(allGem)
	self:initUI(allGem,callFunc)
end
function ShenQiGemSelectPop:initData(data)
	if data and  data.itemid then
		data = {data}
	end
	self._tabGem = {
		[1] = {}, --良品
		[2] = {}, --稀有
		[3] = {}, --顶级
	}
	for i = 1, #data do
		local nameStr = data[i].name
		local str1 = string.sub(nameStr, 1,1)
		local str2 = string.sub(nameStr, 2,2)

		local level = tonumber(str1) or 0
		if tonumber(str2) ~= nil then
			level = level*10+tonumber(str2)
		end
		data[i].level = level
		--按等级排序: 良品(1-5)稀有(6-10)顶级(11-15)
		if level < 6 then
			self._tabGem[1][#self._tabGem[1]+1] = data[i]
		elseif level < 11 then
			self._tabGem[2][#self._tabGem[2]+1] = data[i]
		elseif level < 16 then
			self._tabGem[3][#self._tabGem[3]+1] = data[i]
		end
	end
	--排序
	for i = 1, #self._tabGem do
		if #self._tabGem[i] > 0 then
			table.sort(self._tabGem[i], function(a, b)
				return a.level > b.level
			end)
		end
	end
end

function ShenQiGemSelectPop:initUI(allGem,callFunc)
	-- local Bg = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_34.png")
	local Bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    Bg:setContentSize(cc.size(700, 424))
	Bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(Bg)

	local close = XTHD.createBtnClose(function()
		self:hide()
	end)
	close:setPosition(Bg:getContentSize().width-5,Bg:getContentSize().height-5)
	Bg:addChild(close)

	local titleSp = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,55))
	titleSp:setPosition(Bg:getBoundingBox().width/2,Bg:getContentSize().height - 10)
	Bg:addChild(titleSp)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_TIPS_ARTIFACT_SELECT, --- "选择玄符",
		fontSize = 26,
		color = cc.c3b(104, 33, 11)
	})
	titleLabel:setPosition(titleSp:getBoundingBox().width/2,titleSp:getBoundingBox().height/2)
	titleSp:addChild(titleLabel)

	--tab
	local nameTab = {"liang","xiyou","dingji"}
	self._tabBtn = {}
	for i = 1, 3 do
        local tab_btn = XTHDPushButton:createWithParams({
            normalNode      = getCompositeNodeWithImg("res/image/common/btn/btn_tabClassify_normal.png", "res/image/plugin/saint_beast/"..nameTab[i].."_normal.png"),
            selectedNode    = getCompositeNodeWithImg("res/image/common/btn/btn_tabClassify_selected.png", "res/image/plugin/saint_beast/"..nameTab[i].."_selected.png"),
            musicFile = XTHD.resource.music.effect_btn_common,
            anchor          =cc.p(0,1),
            pos             = cc.p(Bg:getContentSize().width,Bg:getContentSize().height-40-85*(i-1)),
            endCallback = function()
            	self:changeTab(i)
            end,
        })
		tab_btn:setScale(0.7)
        Bg:addChild(tab_btn, -1)
        self._tabBtn[#self._tabBtn+1] = tab_btn
	end
    self:changeTab(1)


	local tableSize = cc.size(Bg:getContentSize().width-20, Bg:getContentSize().height-70)
	-- local myTableBg = ccui.Scale9Sprite:create(cc.rect(12,12,1,1), "res/image/common/scale9_bg_25.png")
	local myTableBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
	myTableBg:setContentSize(tableSize)
	myTableBg:setAnchorPoint(cc.p(0.5, 0))
	myTableBg:setPosition(cc.p(Bg:getContentSize().width/2, 30))
	Bg:addChild(myTableBg)

	self._gemTable = CCTableView:create(cc.size(tableSize.width-20, tableSize.height-20))
	self._gemTable:setPosition(8, 10)
    self._gemTable:setBounceable(true)
    self._gemTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._gemTable:setDelegate()
    self._gemTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    myTableBg:addChild(self._gemTable)

    local function cellSizeForTable(table,idx)
        return tableSize.width-10,103
    end
    local function numberOfCellsInTableView(table)
        return math.ceil(#self._allGem/2)
    end
    local function tableCellTouched(table,cell)
    end
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(tableSize.width-10,103)
        else
            cell:removeAllChildren()
        end
        for i=1,2 do
        	if idx*2+i <= #self._allGem then
        		local nowData = self._allGem[idx*2+i]
        		local cellNode = self:getBtnNode()
        		local cell_bg = XTHDPushButton:createWithParams({
        			 musicFile = XTHD.resource.music.effect_btn_common,
			         normalNode = cellNode[1],
			         selectedNode = cellNode[2],
			         needSwallow = false,
			         needEnableWhenMoving = true,
					 isScrollView = true,
			    })
			    cell_bg:setTouchBeganCallback(function()
		         	cell_bg:setScale(0.95)
		    	end)
			    cell_bg:setTouchEndedCallback(function()
		         	callFunc(nowData.dbid)
		         	self:hide()
			    end)


			    cell_bg:setAnchorPoint(i==1 and 0 or 1 , 0)
			    cell_bg:setPosition(i==1 and 2 or tableSize.width-22,7)
			    cell:addChild(cell_bg)

			    local itemIcon = ItemNode:createWithParams({
			    	itemId = nowData.itemid,
			    	_type_ = 4,
			    	count = nowData.count,
			    	clickable = false,
		    	})
		    	itemIcon:setScale(0.75)
		    	itemIcon:setAnchorPoint(0,0.5)
		    	itemIcon:setPosition(15,cell_bg:getBoundingBox().height/2)
		    	cell_bg:addChild(itemIcon)

		    	-- local nameBg = ccui.Scale9Sprite:create(cc.rect(115,15,130,1), "res/image/store/store_cell_title.png")
		    	local nameBg = XTHD.createSprite("res/image/plugin/competitive_layer/n_bg1.png")
				nameBg:setScaleX(160/330)
				nameBg:setScaleY(0.8)
		    	nameBg:setAnchorPoint(cc.p(0.5,0.5))
		    	nameBg:setPosition(cell_bg:getContentSize().width-230/2+20, cell_bg:getContentSize().height-10-30/2)
		    	cell_bg:addChild(nameBg)

		    	local itemName = XTHDLabel:createWithParams({
			        text = nowData.name,
			        fontSize = 18,
					color = cc.c3b(206,110,240),
					ttf = "res/fonts/def.ttf"
				})
				itemName:enableOutline(cc.c4b(0,0,0,255),1)
			    itemName:setPosition(nameBg:getPositionX()-60, nameBg:getPositionY())
			    -- itemName:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2)

			    cell_bg:addChild(itemName)

		    	-- local left = XTHD.createSprite("res/image/common/titlepattern_left.png")
		    	-- left:setAnchorPoint(cc.p(1, 0.5))
		    	-- left:setPosition(itemName:getPositionX()-itemName:getContentSize().width/2, itemName:getPositionY())
		    	-- cell_bg:addChild(left)
		    	-- local right = XTHD.createSprite("res/image/common/titlepattern_right.png")
		    	-- right:setAnchorPoint(cc.p(0, 0.5))
		    	-- right:setPosition(itemName:getPositionX()+itemName:getContentSize().width/2, itemName:getPositionY())
		    	-- cell_bg:addChild(right)

			    itemName._num = 0

			    local gemData = gameData.getDataFromCSV("Runelist",{id = nowData.itemid})
			    for i=1,#XTHD.resource.AttributesNum do
			    	if gemData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]] ~= 0 then
			    		local attrName = XTHDLabel:createWithParams({
					        text = XTHD.resource.getAttributes(XTHD.resource.AttributesNum[i]),
					        fontSize = 18,
					        color = XTHD.resource.color.gray_desc
					    })
					    attrName:setAnchorPoint(0,1)
					    attrName:setPosition(120,nameBg:getPositionY()-20-(itemName._num*attrName:getBoundingBox().height+3))
					    itemName._num = itemName._num + 1
					    cell_bg:addChild(attrName)
					    -- local percentStr = XTHD.resource.isPercent(XTHD.resource.AttributesNum[i]) == true and "%" or ""
						local tip = ""
						if gemData._type > 5 then
							tip = " +"..gemData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]].."%"
						else
							tip = " +"..gemData[XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]]
						end
					    local attrPlus = XTHDLabel:createWithParams({
					        text = tip,
					        fontSize = 20,
					        color = cc.c3b(104, 157, 0),
					    })
					    attrPlus:setAnchorPoint(0,0.5)
					    attrPlus:enableShadow(cc.c4b(104, 157, 0, 255), cc.size(0.4, -0.4))
					    attrPlus:setPosition(attrName:getPositionX()+attrName:getBoundingBox().width,attrName:getPositionY()-attrName:getBoundingBox().height/2)
					    cell_bg:addChild(attrPlus)
			    	end
			    end
        	end
        end
        -- local line = XTHD.getScaleNode("res/image/common/line.png", cc.size(tableSize.width-10, 2))
        -- line:setPosition((tableSize.width-10)/2, 2)
        -- cell:addChild(line)
        return cell
    end
    self._gemTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._gemTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._gemTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._gemTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)


    self._gemTable:reloadData()
end

function ShenQiGemSelectPop:changeTab(_type)
	if self._type == nil or  self._type ~= _type then
		if self._type == nil then
			self._type = _type
			self._tabBtn[self._type]:setSelected(true)
			self._tabBtn[self._type]:setLocalZOrder(0)
			self._allGem = self._tabGem[self._type]
		else
			if #self._tabGem[_type] == 0 then
				XTHDTOAST(LANGUAGE_TIPS_NO_KEYIN)
				return 
			end

			self._allGem = self._tabGem[_type]
			self._tabBtn[self._type]:setSelected(false)
			self._tabBtn[self._type]:setLocalZOrder(-1)

			self._type = _type
			self._tabBtn[self._type]:setSelected(true)
			self._tabBtn[self._type]:setLocalZOrder(0)
    		self._gemTable:reloadData()
		end
	end
end
function ShenQiGemSelectPop:getBtnNode()
    local _btnNodeTable = {}
	-- local _normalSprite = ccui.Scale9Sprite:create(cc.rect(15,15,1,1),"res/image/common/scale9_bg_26.png")
	local _normalSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    _normalSprite:setContentSize(cc.size(320,95))
	-- local _selectedSprite = ccui.Scale9Sprite:create(cc.rect(15,15,1,1),"res/image/common/scale9_bg_26.png")
	local _selectedSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    _selectedSprite:setContentSize(cc.size(320,95))
    _btnNodeTable[1] = _normalSprite
    _btnNodeTable[2] = _selectedSprite
    return _btnNodeTable
end

function ShenQiGemSelectPop:create(allGem,callFunc)
	return ShenQiGemSelectPop.new(allGem,callFunc)
end

return ShenQiGemSelectPop