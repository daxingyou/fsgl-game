--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ZhaoqinLayer = class("XiangqinLayer",function()
	local node = cc.Node:create()
	node:setAnchorPoint(0.5,1)
	node:setContentSize(682,387)
	return node
end)

function ZhaoqinLayer:ctor()
	self:init()
end

function ZhaoqinLayer:init()
	local title = cc.Sprite:create("res/image/Biwuzhaoqin/title_biwuzhaoqin.png")
	self:addChild(title)
	title:setPosition(self:getContentSize().width *0.5,self:getContentSize().height - title:getContentSize().height *0.5 - 10)

	local btn_help = XTHDPushButton:createWithParams({
		normalFile = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile = "res/image/camp/lifetree/wanfa_down.png",
		musicFile = XTHD.resource.music.effect_btn_common,
	})
	self:addChild(btn_help)
	btn_help:setPosition(btn_help:getContentSize().width *0.5 + 20, self:getContentSize().height - btn_help:getContentSize().height *0.5 - 10)
	btn_help:setTouchEndedCallback(function()

	end)

	local tablebg = cc.Sprite:create("res/image/common/scale9_bg2_34.png")
	self:addChild(tablebg)
	tablebg:setContentSize(self:getContentSize().width,self:getContentSize().height *0.75)
	tablebg:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.4 - 10)
	tablebg:setOpacity(0)

	self._talbeView = cc.TableView:create(tablebg:getContentSize())
	self._talbeView:setPosition(0,0)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tablebg:addChild(self._talbeView)

	local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,160
    end
    local function numberOfCellsInTableView(table)
        return 3
    end
	
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,160)
        else
            cell:removeAllChildren()
        end
		self:buildCell(idx,cell)
        return cell
    end
	local function tableCellTouched(table,cell)
		print("***************************")
	end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
	self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
	self._talbeView:reloadData()
end

function ZhaoqinLayer:buildCell(index,cell)
	for i = 1, 2 do
		local cellbg = cc.Sprite:create("res/image/Biwuzhaoqin/cellbg.png")
		cell:addChild(cellbg)
		local x = cellbg:getContentSize().width *0.5 + ((i-1) * (cellbg:getContentSize().width + 10)) + 10
		cellbg:setPosition(x,cell:getContentSize().height *0.5)

		local btn_heli = XTHDPushButton:createWithParams({
			normalFile = "res/image/Biwuzhaoqin/btn_look_1.png",
			selectedFile = "res/image/Biwuzhaoqin/btn_look_2.png",
		})
		cellbg:addChild(btn_heli)
		btn_heli:setPosition(btn_heli:getContentSize().width *0.5 + 35,btn_heli:getContentSize().height *0.5 + 10)
		btn_heli:setTouchEndedCallback(function()

		end)

		local yuanfenlable = XTHDLabel:create("缘分值要求：",16)
		yuanfenlable:setAnchorPoint(0,0.5)
		yuanfenlable:setPosition(cellbg:getContentSize().width *0.45,cellbg:getContentSize().height *0.3 - 6)
		cellbg:addChild(yuanfenlable)

		local timelable = XTHDLabel:create("剩余时间：",16)
		timelable:setAnchorPoint(0,0.5)
		timelable:setPosition(cellbg:getContentSize().width *0.45,cellbg:getContentSize().height *0.1)
		cellbg:addChild(timelable)

		local jiaobiao = cc.Sprite:create("res/image/Biwuzhaoqin/buxian.png")
		jiaobiao:setAnchorPoint(0.5,1)
		cellbg:addChild(jiaobiao)
		jiaobiao:setPosition(jiaobiao:getContentSize().width *0.5,cellbg:getContentSize().height)
	end
end

function ZhaoqinLayer:create()
	return ZhaoqinLayer.new()
end

return ZhaoqinLayer


--endregion
