--Created By Liuluyang 2015年06月16日
local YingXiongSelectPop = class("YingXiongSelectPop",function ()
	return XTHD.createPopLayer()
end)

function YingXiongSelectPop:ctor(callFunc)
	self:initUI(callFunc)
end

function YingXiongSelectPop:initUI(callFunc)
    -- local Bg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/scale9_bg_34.png")
    local Bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	Bg:setContentSize(cc.size(560,443))
	Bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(Bg)
    -- local titleBg = XTHD.getScaleNode(cc.size(Bg:getContentSize().width - 7*2,44))
    local titleBg = ccui.Scale9Sprite:create()
    titleBg:setContentSize(cc.size(Bg:getContentSize().width - 7*2,44))
    titleBg:setAnchorPoint(0.5, 1)
    titleBg:setPosition(Bg:getContentSize().width/2, Bg:getContentSize().height-7)
    Bg:addChild(titleBg)
    local title = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_ARTIFACT_SELECT_HERO,
        fontSize = 18,
        color = XTHD.resource.color.brown_desc,
        pos = cc.p(titleBg:getContentSize().width/2, titleBg:getContentSize().height/2),
    })
    titleBg:addChild(title)
    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(Bg:getContentSize().width-5,Bg:getContentSize().height-5)
    Bg:addChild(close)

    local confirm = XTHD.createCommonButton({
        btnColor = "write_1",
        text = LANGUAGE_KEY_SURE,
        isScrollView = false,
        fontSize = 30,
        anchor = cc.p(0.5,0),
        pos = cc.p(Bg:getContentSize().width/2, Bg:getContentSize().height/2 - 201),
        endCallback = function()
            if callFunc and self._selectedHero then
                callFunc(self._selectedHero)
            end
            self:hide()
        end,
    })
    confirm:setScale(0.6)
    Bg:addChild(confirm)
    self.confrimBtn = confirm

	local allHero = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_HERO)
	local allartifact = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ARTIFACT)
	local petIdlist = {}
	for i = 1, #allHero do
		allHero[i].sortType = 1
		for j = 1, #allartifact do
				allHero[i].isArtifact = 1
			if allHero[i].heroid == allartifact[j].petId then
				allHero[i].sortType = allHero[i].sortType + allHero[i].sortType*1000000
				allHero[i].isArtifact = 2
				break
			end
		end
	end
	
	for i = 1, #allHero do
		allHero[i]._rank = gameData.getDataFromCSV("GeneralInfoList",{heroid = allHero[i].heroid}).rank
	end
	
	
	allHero = self:SortList(allHero)
    -- local tableBg = ccui.Scale9Sprite:create(cc.rect(12,12,1,1), "res/image/common/scale9_bg_25.png")
    local tableBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    tableBg:setContentSize(Bg:getContentSize().width-16,330)
    tableBg:setAnchorPoint(0.5, 1)
    tableBg:setPosition(cc.p(Bg:getContentSize().width/2, titleBg:getPositionY()-45))
    Bg:addChild(tableBg)

	local heroTable = cc.TableView:create(cc.size(tableBg:getContentSize().width-26,tableBg:getContentSize().height-16))
	heroTable:setPosition(8,13)
    heroTable:setBounceable(true)
    heroTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    heroTable:setDelegate()
    heroTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableBg:addChild(heroTable)

    local function cellSizeForTable(table,idx)
    	if idx == 0 then
    		return tableBg:getContentSize().width-6,2
    	end
        return tableBg:getContentSize().width-6,105
    end

    local function numberOfCellsInTableView(table)
        return math.ceil(#allHero/5)+1
    end

    local function tableCellTouched(table,cell)

    end

    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(tableBg:getContentSize().width-6,105)
        else
            for i = 1, 5 do
                local item = cell:getChildByTag(i)
                if item and item == self._selectedIcon then
                    self._selectedIcon = nil
                end
            end
            cell:removeAllChildren()
        end
        if idx == 0 then
        	return cell
        end
		
        for i=1,5 do
        	if (idx-1)*5+i <= #allHero then
        		local nowData = allHero[(idx-1)*5+i]
        		local heroIcon = HeroNode:createWithParams({
        			heroid = nowData.heroid,
					isScrollView = true
        		})
                heroIcon:setTag(i)
                heroIcon:setScale(0.9)

				if nowData.isArtifact == 2 then
					local yizhuangbei = cc.Sprite:create("res/image/common/yizhuangbei.png")
					heroIcon:addChild(yizhuangbei)
					yizhuangbei:setScale(0.9)
					yizhuangbei:setPosition(heroIcon:getContentSize().width - yizhuangbei:getContentSize().width *0.5 + 1.5 ,heroIcon:getContentSize().height - yizhuangbei:getContentSize().height *0.5 + 3)
				end

                if self._selectedHero and self._selectedHero == nowData.heroid then
                    self:createMask(heroIcon)
                end
        		heroIcon:setPosition(XTHD.resource.getPosInArr({
        			lenth = 15,
        			bgWidth = tableBg:getContentSize().width-6,
        			num = 5,
        			nodeWidth = heroIcon:getBoundingBox().width,
        			now = i
        		}),50)
        		heroIcon:setTouchEndedCallback(function ()

                    if self._selectedIcon and self._selectedIcon == heroIcon then
                        return
                    end

                    self._selectedHero = nowData.heroid
                    if self._selectedIcon then
                        self._selectedIcon:getChildByName("mask"):removeFromParent()
                    end
                    self:createMask(heroIcon)
        		end)
                if idx == 1 and i == 1 then
                    self.iconBtn = heroIcon
                end
        		cell:addChild(heroIcon)
        	end
        end
        return cell
    end
    heroTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    heroTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    heroTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    heroTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    heroTable:reloadData()
    self:addGuide()
end

function YingXiongSelectPop:SortList(list)
	for i = 1, #list do
		list[i].sortType = list[i].sortType + list[i].level * 10000 + list[i].star *10 + list[i]._rank
	end
	
	table.sort(list,function(a,b)
		return a.sortType > b.sortType
	end)

	return list
end

function YingXiongSelectPop:createMask(heroIcon)
    -- local mask = cc.LayerColor:create(cc.c4b(234,208,139,150))
    local mask = ccui.Scale9Sprite:create(cc.rect(45,45,1,1), "res/image/common/item_select_box.png")
    -- local mask = XTHD.createSprite("res/image/common/item_select_box.png")
    -- mask:setOpacity(200)
    mask:setContentSize( cc.size(heroIcon:getContentSize().width+12, heroIcon:getContentSize().height+12) ) 
    mask:setName("mask")
    mask:setPosition(cc.p(heroIcon:getContentSize().width/2, heroIcon:getContentSize().height/2))
    heroIcon:addChild(mask)
    self._selectedIcon = heroIcon
end
function YingXiongSelectPop:create(callFunc)
	return YingXiongSelectPop.new(callFunc)
end

function YingXiongSelectPop:addGuide()
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self.iconBtn, -----点击英雄头像
        index = 4,
    },26)
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self.confrimBtn, -----点击确定按钮
        index = 5,
    },26)
    YinDaoMarg:getInstance():doNextGuide()    
end

return YingXiongSelectPop