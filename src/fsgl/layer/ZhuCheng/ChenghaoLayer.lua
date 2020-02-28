--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ChenghaoLayer = class("ChenghaoLayer",function()
	return XTHDPopLayer:create()
end)

function ChenghaoLayer:ctor()
	self._cell = {}
	self._listData = {}
	self._selectedIndex = nil
	self:initdata()
	self:init()
end

function ChenghaoLayer:init()
	local bg = cc.Sprite:create("res/image/chenghao/bg.png")
	self:addContent(bg)
	bg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)
	self._bg = bg

	self._talbeView = CCTableView:create(cc.size(self._bg:getContentSize().width *0.7,self._bg:getContentSize().height *0.75))
	self._talbeView:setAnchorPoint(0.5,0.5)
	self._talbeView:setPosition(self._bg:getContentSize().width *0.15 - 6,73)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._bg:addChild(self._talbeView)

    local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,90
    end
    local function numberOfCellsInTableView(table)
        return #self._listData
    end
    local function tableCellTouched(table,cell)
    end
    local function tableCellAtIndex(table1,idx)
		idx = idx + 1 
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,90)
        else
            cell:removeAllChildren()
        end
		self:BuildCell(idx,cell)
		self._cell[idx] = cell
		return cell
	end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    self._talbeView:reloadData()

	local btn_peidai = XTHDPushButton:createWithParams({
		normalFile = "res/image/chenghao/btn_peidai_1.png",
		selectedFile = "res/image/chenghao/btn_peidai_2.png",
	})
	self._bg:addChild(btn_peidai)
	btn_peidai:setPosition(self._bg:getContentSize().width *0.5,btn_peidai:getContentSize().height *0.5 + 19)
	btn_peidai:setTouchEndedCallback(function()
		self:AdormChenghao()
	end)
end

function ChenghaoLayer:BuildCell(index,cell)
	local data = self._listData[index]
	local cellbg = cc.Sprite:create("res/image/chenghao/cellbg.png")
	cell:addChild(cellbg)
	cellbg:setPosition(cell:getContentSize().width *0.5,cell:getContentSize().height *0.5)

	if data.state == 0 then
		XTHD.setGray(cellbg,true)
	end

	local _color = string.split(data.rgb,"，")
	local titlename = XTHDLabel:create(data.name,17)
	titlename:setAnchorPoint(0,0.5)
	titlename:setColor(cc.c3b(tonumber(_color[1]),tonumber(_color[2]),tonumber(_color[3])))
	cellbg:addChild(titlename)
	titlename:setPosition(10,cellbg:getContentSize().height - titlename:getContentSize().height *0.5 - 4)

	local shuxing = XTHDLabel:create("属性：",12)
	shuxing:setAnchorPoint(0,0.5)
	shuxing:setColor(cc.c3b(0,0,0))
	cellbg:addChild(shuxing)
	shuxing:setPosition(10,cellbg:getContentSize().height *0.5 + 5)
	
	local params = {"hp", "physicalattack", "physicaldefence", "manaattack", "manadefence", "hit", "dodge", "crit", "crittimes", "anticrit",
					"antiattack", "attackbreak", "antiphysicalattack", "physicalattackbreak", "antimanaattack", "manaattackbreak",
					"suckblood", "heal", "behealed", "antiangercost", "hprecover", "angerrecover"}

	local _texts = {"基础生命","物理攻击","物理防御","法术攻击","法术防御","命中","闪避","暴击","暴击倍率","抗暴击","伤害减免","伤害穿透","物理攻击减免","物理攻击穿透",
					"法术攻击减免","法术攻击穿透","吸血","治疗加成","被治疗加成","怒气消耗减免","生命恢复","怒气恢复"}

	local text = ""
	local shuxinglist = {}
	for i = 1, #params do
		if data[tostring(params[i])] > 0 then
			shuxinglist[#shuxinglist + 1] = i
		end
	end

	for i = 1,#shuxinglist do
		print(_texts[i],index,data.id)
		local _index = shuxinglist[i]
		if _index == 6 or _index == 7 or _index == 8 or _index == 9 or _index == 10 or _index == 11 or _index == 12 or _index == 13
			or _index == 14 or _index == 15 or _index == 16 or _index == 17 or _index == 18 or _index == 19 or _index == 20 then
			text = text.._texts[_index]..data[tostring(params[_index])].."%"
		else
			text = text.._texts[_index]..data[tostring(params[_index])]
		end
		if i < #shuxinglist then
			text = text.."，"
		else
			text = text.."。"
		end
	end
	
	local lable = XTHDLabel:create(text,12)
	lable:setAnchorPoint(0,0.5)
	lable:setColor(cc.c3b(70,0,0))
	cellbg:addChild(lable)
	lable:setPosition(shuxing:getPositionX() + shuxing:getContentSize().width,shuxing:getPositionY())

	local Drop = XTHDLabel:create("获取途径：",12)
	Drop:setAnchorPoint(0,0.5)
	Drop:setColor(cc.c3b(0,0,0))
	cellbg:addChild(Drop)
	Drop:setPosition(shuxing:getPositionX(),cellbg:getContentSize().height *0.5 - 20)

	local Droplable = XTHDLabel:create(data.description,12)
	Droplable:setAnchorPoint(0,0.5)
	Droplable:setColor(cc.c3b(70,0,0))
	cellbg:addChild(Droplable)
	Droplable:setPosition(Drop:getPositionX() + Drop:getContentSize().width,Drop:getPositionY())

	local selectBox = XTHDPushButton:createWithParams({
		normalFile = "res/image/chenghao/select_box_1.png",
		selectedFile = "res/image/chenghao/select_box_1.png",
	})
	cellbg:addChild(selectBox)
	selectBox:setPosition(cellbg:getContentSize().width - selectBox:getContentSize().width *0.5 - 20,cellbg:getContentSize().height *0.5)
	cell.selectBox = selectBox
	selectBox:setTouchEndedCallback(function()
		if data.state == 0 then
			XTHDTOAST("暂未解锁该称号")
		else
			self:selectedChenghao(index)
		end
	end)
	
	local selectsp = cc.Sprite:create("res/image/chenghao/select_box_2.png")
	selectBox:addChild(selectsp)
	selectsp:setPosition(selectBox:getContentSize().width *0.5,selectBox:getContentSize().height *0.5)
	selectsp:setName("selectsp")
	selectsp:setVisible(false)
	if data.id == gameUser.getCurTitle() then
		selectsp:setVisible(true)
		self._selectedIndex = index
	end
end

function ChenghaoLayer:selectedChenghao(index)
	for i = 1, #self._cell do
		local selectBox = self._cell[i].selectBox
		if selectBox and selectBox:getChildByName("selectsp") then
				selectBox:getChildByName("selectsp"):setVisible(false)
		end
	end
	if self._cell[index].selectBox and self._cell[index].selectBox:getChildByName("selectsp") then
		self._cell[index].selectBox:getChildByName("selectsp"):setVisible(true) 
	end
	self._selectedIndex = index
end

function ChenghaoLayer:AdormChenghao()
	if gameUser.getCurTitle() == self._listData[self._selectedIndex].id then
		XTHDTOAST("已佩戴该称号")
		return
	end
	HttpRequestWithParams("updateTitle",{titleId = self._listData[self._selectedIndex].id},function (data)
        dump(data)
		gameUser.setCurTitle(data.titleId)
		XTHDTOAST("佩戴称号成功")
    end)
end

function ChenghaoLayer:initdata()
	local list = {}
	for k,v in pairs(gameData.getDataFromCSV("TitleInfo")) do
		if v.isDisplay == 1 then
			list[#list + 1] = v
			list[#list].state = 0
		end
	end

	for i = 1,#list do
		for k, v in pairs(gameUser.getCurTitleList()) do
			if list[i].id == v then
				list[i].state = 1
			end
		end
	end

	local list_1 = {}
	local list_2 = {}

	for k,v in pairs(list) do
		if v.state == 1 then
			list_1[#list_1 + 1] = v
		else
			list_2[#list_2 + 1] = v
		end
	end
	
	for k,v in pairs(list_1) do
		self._listData[#self._listData + 1] = v
	end

	for k,v in pairs(list_2) do
		self._listData[#self._listData + 1] = v
	end	
end

function ChenghaoLayer:create()
	return ChenghaoLayer.new()
end

return ChenghaoLayer

--endregion
