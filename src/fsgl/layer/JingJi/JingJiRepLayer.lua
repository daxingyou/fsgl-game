--Created By Liuluyang 2015年08月22日
-- 战斗记录界面
local JingJiRepLayer = class("JingJiRepLayer",function ()
	return XTHD.createPopLayer()
end)

function JingJiRepLayer:ctor(data)
	self:initUI(data)
end

function JingJiRepLayer:initUI(data)
	-- print("服务器的战斗记录为：")
	-- print_r(data)
    table.sort(data.list,function(data1,data2)
        local _data1Num = tonumber(data1.diffTime)*10000 + tonumber(data1.rank)
        local _data2Num = tonumber(data2.diffTime)*10000 + tonumber(data2.rank)
        return _data1Num < _data2Num
    end)
	local Bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	Bg:setContentSize(cc.size(650,453))
	Bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2-20)
	self:addContent(Bg)

    -- local titleBg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 34))
    local titleBg = cc.Sprite:create("res/image/login/zhanghaodenglu.png")
	titleBg:setAnchorPoint(0.5,1)
	titleBg:setPosition(Bg:getBoundingBox().width/2,Bg:getBoundingBox().height+30)
	Bg:addChild(titleBg)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_FIGHTRECORD,----"战斗记录",
        fontSize = 32,
        color = cc.c3b(106,36,13)
	})
	titleLabel:setPosition(titleBg:getBoundingBox().width/2,titleBg:getBoundingBox().height/2)
	titleBg:addChild(titleLabel)


	self._repTable = CCTableView:create(cc.size(620,385))
    self._repTable:setPosition((Bg:getBoundingBox().width-620)/2, 30)
    self._repTable:setBounceable(true)
    self._repTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._repTable:setDelegate()
    self._repTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    Bg:addChild(self._repTable)

    local function cellSizeForTable(table,idx)
        return 620,112
    end

    local function numberOfCellsInTableView(table)
        return #data.list
    end

    local function tableCellTouched(table,cell)
    end

    local function tableCellAtIndex(table1,idx)
        local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else
            cell:removeAllChildren()
        end

        local nowData = data.list[idx+1]

        local cell_bg = ccui.Scale9Sprite:create(cc.rect(0,0,0,0),"res/image/common/scale9_bg1_26.png")
        cell_bg:setContentSize(619,111)
        cell_bg:setAnchorPoint(0,0)
        cell:addChild(cell_bg)

        local split = cc.Sprite:create("res/image/plugin/competitive_layer/split.png")
        split:setPosition(120,cell_bg:getBoundingBox().height/2)
        cell_bg:addChild(split)

        local timeNum = nowData.diffTime
        local timePath = "res/image/plugin/competitive_layer/min_before.png"
        if timeNum > 60 then
        	timeNum = math.floor(nowData.diffTime/60)
        	timePath = "res/image/plugin/competitive_layer/hour_before.png"
        	if timeNum > 24 then
	        	timeNum = math.floor(timeNum/24)
	        	timePath = "res/image/plugin/competitive_layer/day_before.png"
	        	if timeNum > 7 then
		        	timeNum = 7
		        end
	        end
        end

        local timeLabel = getCommonWhiteBMFontLabel(timeNum)
        timeLabel:setAnchorPoint(0,0.5)

        local strLabel = cc.Sprite:create(timePath)
        strLabel:setAnchorPoint(0,0.5)

        timeLabel:setPosition((120-timeLabel:getBoundingBox().width-strLabel:getBoundingBox().width)/2,cell_bg:getBoundingBox().height/2-7)
        cell_bg:addChild(timeLabel)
        strLabel:setPosition(timeLabel:getPositionX()+timeLabel:getBoundingBox().width,cell_bg:getBoundingBox().height/2)
        cell_bg:addChild(strLabel)

        local battleType = tonumber(nowData.type) == 1 and LANGUAGE_KEY_BECHALLENGED or LANGUAGE_KEY_YOUCHALLENGED ------"挑战了你" or "你挑战了"
        local rivalName = XTHDLabel:createWithParams({
        	text = nowData.defendName or nowData.attackName,
        	fontSize = 20,
        	color = XTHD.resource.color.brown_desc
        })
        rivalName:setAnchorPoint(0,0.5)

        local battleStr = XTHDLabel:createWithParams({
        	text = battleType,
        	fontSize = 18,
        	color = XTHD.resource.color.brown_desc
        })
        battleStr:setAnchorPoint(0,0.5)

        local rstLabel = XTHDLabel:createWithParams({
        	text = tonumber(nowData.result) == 1 and LANGUAGE_TIP_YOU_WIN or LANGUAGE_TIP_YOU_LOSE,-----"你赢了" or "你输了",
        	fontSize = 20,
        	color = tonumber(nowData.result) == 1 and cc.c3b(104,157,0) or cc.c3b(178,27,27)
        })
        rstLabel:setAnchorPoint(0,0.5)

        if tonumber(nowData.type) == 1 then
	        rivalName:setPosition(split:getPositionX()+30,cell_bg:getBoundingBox().height-40)
	        battleStr:setString(" "..battleStr:getString()..", ")
	        battleStr:setPosition(rivalName:getPositionX()+rivalName:getBoundingBox().width,cell_bg:getBoundingBox().height-40)
	        rstLabel:setPosition(battleStr:getPositionX()+battleStr:getBoundingBox().width,cell_bg:getBoundingBox().height-40)
	    else
	        battleStr:setPosition(split:getPositionX()+30,cell_bg:getBoundingBox().height-40)
	        rivalName:setString(" "..rivalName:getString()..", ")
	    	rivalName:setPosition(battleStr:getPositionX()+battleStr:getBoundingBox().width,cell_bg:getBoundingBox().height-40)
	    	rstLabel:setPosition(rivalName:getPositionX()+rivalName:getBoundingBox().width,cell_bg:getBoundingBox().height-40)
	    end
        cell_bg:addChild(rivalName)
        cell_bg:addChild(battleStr)
        cell_bg:addChild(rstLabel)

        local rankLabel = XTHDLabel:createWithParams({
        	text = tonumber(nowData.result) == 1 and LANGUAGE_TIPS_WORDS37 or LANGUAGE_TIPS_WORDS38,-----"你的排名上升为：" or "你的排名下降到：",
        	fontSize = 18,
        	color = XTHD.resource.color.brown_desc
        })
        rankLabel:setAnchorPoint(0,0.5)
        rankLabel:setPosition(split:getPositionX()+30,40)
        cell_bg:addChild(rankLabel)

        if tonumber(nowData.rank) == -1 then
        	rankLabel:setString(LANGUAGE_TIPS_WORDS36)----"你的排名保持不变")
        else
        	local rankNum = XTHDLabel:createWithParams({
        		text = tonumber(nowData.rank),
        		fontSize = 18,
        		color = tonumber(nowData.result) == 1 and cc.c3b(104,157,0) or cc.c3b(178,27,27)
        	})
        	rankNum:setAnchorPoint(0,0.5)
        	rankNum:setPosition(rankLabel:getPositionX()+rankLabel:getBoundingBox().width,40)
        	cell_bg:addChild(rankNum)
        end


        return cell
    end

    self._repTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._repTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._repTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._repTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._repTable:reloadData()
end

function JingJiRepLayer:create(data)
	return JingJiRepLayer.new(data)
end

return JingJiRepLayer