--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local XiangqinLayer = class("XiangqinLayer",function()
	local node = cc.Node:create()
	node:setAnchorPoint(0.5,1)
	node:setContentSize(682,387)
	return node
end)

function XiangqinLayer:ctor()
	self:init()
end

function XiangqinLayer:init()
	local title = cc.Sprite:create("res/image/Biwuzhaoqin/title_xiangqinmain.png")
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

	local EditBoxbg = cc.Sprite:create("res/image/Biwuzhaoqin/edixboxbg.png")
	self:addChild(EditBoxbg)
	EditBoxbg:setAnchorPoint(1,0.5)
	EditBoxbg:setPosition(self:getContentSize().width - 30,self:getContentSize().height - EditBoxbg:getContentSize().height *0.5 - 20)
	
	local btn_sousuo = XTHDPushButton:createWithParams({
		normalFile = "res/image/Biwuzhaoqin/btn_explore_normal.png",
		selectedFile = "res/image/Biwuzhaoqin/btn_explore_selected.png",
	})
	btn_sousuo:setPosition(btn_sousuo:getContentSize().width *0.5 - 5,EditBoxbg:getContentSize().height *0.5)
	EditBoxbg:addChild(btn_sousuo)

	local function editBoxEventHandle(eventName,pSender)
        if eventName == "began" then
            
        elseif eventName == "ended" or eventName == "return" then
            
        elseif eventName == "changed" then
        else
            
        end
    end

	local EditBox = ccui.EditBox:create(cc.size(EditBoxbg:getContentSize().width - btn_sousuo:getContentSize().width + 5,EditBoxbg:getContentSize().height),ccui.Scale9Sprite:create(),nil,nil)
    EditBox:setFontName("Helvetica")
    EditBox:setFontSize(16)
    EditBox:setMaxLength(70) 
    EditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    EditBox:setFontColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    EditBox:registerScriptEditBoxHandler(editBoxEventHandle)
    EditBox:setAnchorPoint(cc.p(0,0.5))
    EditBox:setPosition(cc.p(btn_sousuo:getPositionX() + btn_sousuo:getContentSize().width *0.5,EditBox:getContentSize().height *0.5))
    EditBoxbg:addChild(EditBox)

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

function XiangqinLayer:buildCell(index,cell)
	for i = 1, 2 do
		local cellbg = cc.Sprite:create("res/image/Biwuzhaoqin/cellbg.png")
		cell:addChild(cellbg)
		local x = cellbg:getContentSize().width *0.5 + ((i-1) * (cellbg:getContentSize().width + 10)) + 10
		cellbg:setPosition(x,cell:getContentSize().height *0.5)

		local btn_heli = XTHDPushButton:createWithParams({
			normalFile = "res/image/Biwuzhaoqin/btn_heli_1.png",
			selectedFile = "res/image/Biwuzhaoqin/btn_heli_2.png",
		})
		cellbg:addChild(btn_heli)
		btn_heli:setPosition(cellbg:getContentSize().width *0.5,btn_heli:getContentSize().height *0.5 + 2)
		btn_heli:setTouchEndedCallback(function()

		end)

		local jiaobiao = cc.Sprite:create("res/image/Biwuzhaoqin/buxian.png")
		jiaobiao:setAnchorPoint(0.5,1)
		cellbg:addChild(jiaobiao)
		jiaobiao:setPosition(jiaobiao:getContentSize().width *0.5,cellbg:getContentSize().height)
	end
end

function XiangqinLayer:create()
	return XiangqinLayer.new()
end

return XiangqinLayer


--endregion
