--[[
单挑之王排行榜界面
]]

local JingXiangZhiLuChallengeRankLayer = class("JingXiangZhiLuChallengeRankLayer",function( )
	return XTHDDialog:create()		
end)

function JingXiangZhiLuChallengeRankLayer:ctor(data,battleType)
	self._battleType = battleType
	self._rankData = data
	self._showRank = {}
	self:initRankData()
end

function JingXiangZhiLuChallengeRankLayer:onCleanup( )	
   
end

function JingXiangZhiLuChallengeRankLayer:create(data,battleType)
	local layer = JingXiangZhiLuChallengeRankLayer.new(data,battleType)
	if layer then 
		layer:init()
	end
	LayerManager.addLayout(layer)
end

function JingXiangZhiLuChallengeRankLayer:init()
	self:initTopUI()
	self:initContent()
end

function JingXiangZhiLuChallengeRankLayer:initTopUI()

	local bg = cc.Sprite:create("res/image/challenge/rank/dtphbg_02.png")
	bg:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
	bg:setContentSize(cc.Director:getInstance():getWinSize())
	self:addChild(bg)
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

	--排行榜文字
	local textBg = cc.Sprite:create("res/image/challenge/dantiaobg3.png")
	textBg:setPosition(self:getContentSize().width - 130,self:getContentSize().height - 30)
	self:addChild(textBg)
	local textwz = cc.Sprite:create("res/image/challenge/rank/dtphbg_012.png")
	textwz:setPosition(textBg:getPositionX() - 30,textBg:getPositionY())
	self:addChild(textwz)

	--我的排名
    local rank_label = XTHDLabel:create("我的排名:",23,"res/fonts/def.ttf")
    rank_label:setColor(cc.c3b(255,255,255))
    rank_label:enableOutline(cc.c4b(139,69,19,255),2)
    self:addChild(rank_label)
    rank_label:setPosition(self:getContentSize().width/4 - 165,self:getContentSize().height - 30)
    local rankNum = XTHDLabel:create("未上榜",23,"res/fonts/def.ttf")
    rankNum:setAnchorPoint(0,0.5)
    rankNum:setColor(cc.c3b(255,255,255))
    rankNum:enableOutline(cc.c4b(139,69,19,255),2)
    self:addChild(rankNum)
    rankNum:setPosition(rank_label:getPositionX() + 65,rank_label:getPositionY())
    self._rankNum = rankNum

end

function JingXiangZhiLuChallengeRankLayer:initContent()
	local bg = cc.Sprite:create("res/image/challenge/rank/dtphbg_06.png")
	bg:setPosition(self:getContentSize().width/2,self:getContentSize().height/2 - 20)
	bg:setScale(0.9)
	self:addChild(bg)
	local content = cc.Sprite:create("res/image/challenge/rank/dtphbg_011.png")
	bg:addChild(content)
	content:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2 - 30)
	self._contentBg = bg

	--上方文字提示
	local tip1 = XTHDLabel:create("排名   |",29)
	tip1:setColor(cc.c3b(139,69,19))
	bg:addChild(tip1)
	tip1:setPosition(bg:getContentSize().width/4 - 75,bg:getContentSize().height - 75)
	local tip2 = XTHDLabel:create("玩家名   |",29)
	tip2:setColor(cc.c3b(139,69,19))
	bg:addChild(tip2)
	tip2:setPosition(tip1:getPositionX() + 150,tip1:getPositionY())
	local tip3 = XTHDLabel:create("等级    |",29)
	tip3:setColor(cc.c3b(139,69,19))
	bg:addChild(tip3)
	tip3:setPosition(tip2:getPositionX() + 150,tip1:getPositionY())
	local tip4 = XTHDLabel:create("种族    |",29)
	tip4:setColor(cc.c3b(139,69,19))
	bg:addChild(tip4)
	tip4:setPosition(tip3:getPositionX() + 135,tip1:getPositionY())
	local tip5 = XTHDLabel:create("通关数   |",29)
	tip5:setColor(cc.c3b(139,69,19))
	bg:addChild(tip5)
	tip5:setPosition(tip4:getPositionX() + 135,tip1:getPositionY())

	--创建滚动框
	local function cellSizeForTable(table,idx)
        return content:getContentSize().width,content:getContentSize().height/5
    end

    local function numberOfCellsInTableView(table)
    	return #self._showRank
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end
        local node = self:createRankCell(idx + 1)
        if node then 
            cell:addChild(node)
            node:setPosition(node:getContentSize().width/2 + 12,node:getContentSize().height/2)
        end 
        return cell
    end

    local view = cc.TableView:create(content:getContentSize())
    view:setPosition(0,0)
    view:setAnchorPoint(0,0)
    view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    view:setBounceable(true)
--    view:setInertia(true) --设置惯性
--    view:setAutoAlign(true)
    view:setDelegate()
    content:addChild(view)

    view:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    view:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    view:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self.listBg = view
    view:reloadData()

end

function JingXiangZhiLuChallengeRankLayer:createRankCell(id)
	local pic = cc.Sprite:create("res/image/challenge/rank/dtphbg_09.png")
	--排名
	local rankicon = cc.Sprite:create("res/image/challenge/rank/rank.png")
	pic:addChild(rankicon)
	rankicon:setPosition(pic:getContentSize().width/4 - 135,pic:getContentSize().height/2)
	if self._showRank[id].rankNum < 4 then
         rankicon:initWithFile("res/image/challenge/rank/rank"..self._showRank[id].rankNum..".png")
    else
         rankicon:initWithFile("res/image/challenge/rank/rank.png")
	end
	local ranknum = XTHDLabel:create(tostring(self._showRank[id].rankNum),20)
	rankicon:addChild(ranknum)
	ranknum:setPosition(rankicon:getContentSize().width*0.5,rankicon:getContentSize().height*0.5)

	--玩家名
	local name = XTHDLabel:create(self._showRank[id].name,23)
	name:setColor(cc.c3b(139,69,19))
    pic:addChild(name)
    name:setPosition(pic:getContentSize().width/2 - 160,pic:getContentSize().height/2)

    local level = XTHDLabel:create(self._showRank[id].level,23)
	level:setColor(cc.c3b(139,69,19))
    pic:addChild(level)
    level:setPosition(pic:getContentSize().width/2 - 5,pic:getContentSize().height/2)

    local camp = XTHDLabel:create(self._showRank[id].camp,23)
	camp:setColor(cc.c3b(139,69,19))
    pic:addChild(camp)
    camp:setPosition(pic:getContentSize().width/2 + 130,pic:getContentSize().height/2)

    local force = XTHDLabel:create(self._showRank[id].layer,23)
	force:setColor(cc.c3b(139,69,19))
    pic:addChild(force)
    force:setPosition(pic:getContentSize().width - 85,pic:getContentSize().height/2)

	if gameUser.getUserId() == self._showRank[id].uid then
		self._rankNum:setString(self._showRank[id].rankNum)
	end
    return pic
end

function JingXiangZhiLuChallengeRankLayer:initRankData()
	self._showRank = {}
	for i = 1,#self._rankData.list do
--        if self._rankData.list[i].type == self._battleType and self._rankData.list[i].name ~= "" then
            local temp = {}
			temp.rankNum = self._rankData.list[i].rank
			temp.uid = self._rankData.list[i].charId
            temp.name = self._rankData.list[i].name
            temp.level = self._rankData.list[i].level
            temp.camp = self._rankData.list[i].campId == 1 and "仙族" or "魔族"
            temp.layer = self._rankData.list[i].layer
            table.insert(self._showRank,temp)
--        end
	end
end

return JingXiangZhiLuChallengeRankLayer


