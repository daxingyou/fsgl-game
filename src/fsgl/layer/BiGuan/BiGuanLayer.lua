--修仙圣境界面

local BiGuanLayer = class("BiGuanLayer",function( )
    return XTHD.createBasePageLayer()
end)

function BiGuanLayer:ctor(params)
    self._hangUpIndex = self:getHangUpIndexByName(params.which) or 1 ------当前选中的是哪个挂机类型
    self.serverData = params.data
    self._hangUpButtons = {}    --保存挂机按钮
    self._progressBar = {}      --保存进度条
    self._des = {}              --保存说明文字
    self._planBtn = {}          --收获按钮
    self._redDot = {}           --所有小红点
    self.selectedIndex = 0  --当前选中的按钮
    self._localTimeData = gameData.getDataFromCSV("HangUpTime")
    self._localTypeData = gameData.getDataFromCSV("HangUpType")
	self._allTimeData = {}
    self._showLog = {}
    self.isShowTime = false
	self._endTimelist = {}
	self._timeLableList = {}
	self._btnLable = {}
	
	self._btnName = {"粗略提炼#深度提炼","粗略雕琢#深度雕琢","浅度打坐#深度打坐","粗略提炼#深度提炼","粗略寻宝#深度寻宝","粗略培育#深度培育","粗略淬炼#深度淬炼","粗略研习#深度研习","粗略炼制#深度炼制"}
	self._tishiLable = {
							{"粗略提炼","深度提炼"},
							{"粗略雕琢","深度雕琢"},
							{"浅度打坐","深度打坐"},
							{"粗略寻宝","深度寻宝"},
							{"粗略培育","深度培育"},
							{"粗略淬炼","深度淬炼"},
							{"粗略研习","深度研习"},
							{"粗略炼制","深度炼制"},
						}
	self._BebingbtnName = {"提炼中","雕琢中","打坐中","寻宝中","培育中","淬炼中","研习中","炼制中"}
    --用于展示的数据
    self._showData = {
        {
			[1] = {configId = 1,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 1,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 2,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 2,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 3,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 3,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 4,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 4,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 5,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 5,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 6,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 6,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 7,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 7,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 8,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 8,timeId = 2,isCanGet = false,endTime = 0}
		},
    }
   
end

function BiGuanLayer:create(params)
	local hungup = BiGuanLayer.new(params)
	if hungup then 
		hungup:init()
	end 
	return hungup
end

function BiGuanLayer:onEnter( )

end

function BiGuanLayer:onExit( )
	
    RedPointManage:reFreshDynamicItemData()
end

function BiGuanLayer:onCleanup( )
    
end

function BiGuanLayer:init( )
    local mask = cc.LayerColor:create(cc.c4b(0,0,0, 255*0.5))
    self:addChild(mask)
    -- print("------------width:"..self:getContentSize().width.."      -------------height:"..self:getContentSize().height)
    local bg = XTHD.createSprite("res/image/hangup/xxzlbg1.png")  
--	local size = cc.Director:getInstance():getWinSize()
--	bg:setContentSize(size)
    bg:setPosition(self:getContentSize().width/2, (self:getContentSize().height)/2 - 20)  
    self:addChild(bg)
	self._bg = bg

    --挂机按钮滚动框
    local scrollView = ccui.ListView:create()
    scrollView:setContentSize(cc.size(780,437))
    scrollView:setDirection(ccui.ScrollViewDir.horizontal)
	scrollView:setScrollBarEnabled(false)
    scrollView:setBounceEnabled(true)
    scrollView:setAnchorPoint(0,0)
    scrollView:setPosition(169,30)
    self._bg:addChild(scrollView,1)
    self._buttonList = scrollView

    --初始化挂机日志tableview
    local function cellSizeForTable(table,idx)
        return 255,50
    end

    local function numberOfCellsInTableView(table)
        return #self._showLog
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
        end
        local node = self:createLogCell(idx + 1)
        if node then 
            cell:addChild(node)
            node:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
        end 
        return cell
    end

    local view = cc.TableView:create(cc.size(255,135))
    view:setPosition(self:getContentSize().width/2 + 105,self:getContentSize().height/2 - 235)
    view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    view:setBounceable(true)
    view:setDelegate()
    self:addChild(view)

    view:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    view:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    view:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self.listBg = view
	self.listBg:setVisible(false)

	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=33});
            self:addChild(StoredValue,100)
        end,
	})
	self:addChild(help_btn)
	help_btn:setPosition(self:getContentSize().width  -  help_btn:getContentSize().width/2 ,self:getContentSize().height - help_btn:getContentSize().height - 20)

    --加载左边按钮
    self:loadButtons()

end

function BiGuanLayer:createLogCell(id)
    local content = XTHDLabel:create(self._showLog[id],18)
    content:setColor(cc.c3b(139,69,19))
    content:setDimensions(255,50)
    return content
end

function BiGuanLayer:loadButtons()
    --封装好当前需要加载的挂机按钮
    local btnTable = {}
    local btnNameTable = {}
    for i = 1,#self._localTypeData do
        if gameUser.getVip() >= self._localTypeData[i].condition then
                table.insert(btnTable,self._localTypeData[i])
                table.insert(btnNameTable,self._btnName[i])      
        end
    end
    -- print("需要显示的挂机类型按钮为：")
    -- print_r(btnTable)
    -- print_r(btnNameTable)
    self._btnTable = btnTable
    self._btnNameTable = btnNameTable
	
    for j = 1,#btnTable do
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(250,self._buttonList:getContentSize().height))
	
		local _index = j % 3 + 1
		local SpriteFile = string.format("res/image/hangup/cellbg_%d.png",_index)
	
        local normal = cc.Sprite:create(SpriteFile)
		local selected = cc.Sprite:create(SpriteFile)

        local button = XTHD.createPushButtonWithSound({
            normalNode = normal,
            selectedNode = selected,
            needSwallow = false,
        },3)
        
        button:setTag(j)
        button.index = j
        layout:addChild(button)
        button:setPosition(layout:getContentSize().width / 2,layout:getContentSize().height / 2)
			
		local titleFile = string.format("res/image/hangup/cellTitle_%d.png",j)
		local title = cc.Sprite:create(titleFile)
		button:addChild(title)
		title:setPosition(button:getContentSize().width *0.5,button:getContentSize().height - title:getContentSize().height *0.5 - 10)

		local typebgFile = string.format("res/image/hangup/type%d.png",btnTable[j].id)
		local typebg = cc.Sprite:create(typebgFile)
		typebg:setScale(0.6)
		button:addChild(typebg)
		typebg:setPosition(button:getContentSize().width*0.5,button:getContentSize().height *0.5 + typebg:getContentSize().height *0.2)

		local timelist = {}
		local colorlist = {cc.c3b(234,212,190),cc.c3b(56,23,1)}
		local timedata = {}
		local timeLablelist = {}
		local btnlable = {}
		 --挂机任务进度条
		for i = 1,#self._localTimeData do
			local tableData = string.split(self._btnName[j],"#")
			
			local normal;
			local selected;
			if i == 1 then
				normal = cc.Sprite:create("res/image/hangup/btn_chuji_up.png")
				selected = cc.Sprite:create("res/image/hangup/btn_chuji_down.png")
			else
				normal = cc.Sprite:create("res/image/hangup/btn_gaoji_up.png")
				selected = cc.Sprite:create("res/image/hangup/btn_gaoji_down.png")
			end
			
			local planBtn = XTHD.createPushButtonWithSound({
				normalNode = normal,
				selectedNode = selected,
				text = tableData[i],
				fontColor = cc.c3b(88,37,26),
				needSwallow = false,
			},3)
			button:addChild(planBtn)
			planBtn:setPosition(button:getContentSize().width*0.5 - 10,button:getContentSize().height *0.5  - 90 - (i-1)*(planBtn:getContentSize().height - 5)*2)
			planBtn:setTag(j *10 + i)
			planBtn:setTouchEndedCallback(function( )
				self:onPlanBtnClick(planBtn:getTag())
			end) 

			btnlable[i] = planBtn:getLabel()

			if i == 1 then
				local lable = XTHDLabel:create("(免费)",16,"res/fonts/def.ttf")
				lable:setColor(cc.c3b(249,241,133))
				lable:setAnchorPoint(0,0.5)
				lable:setPosition(planBtn:getPositionX() + planBtn:getContentSize().width *0.5 + 10,planBtn:getPositionY())
				button:addChild(lable)
			else
				local icon = cc.Sprite:create("res/image/common/common_gold.png")
				icon:setScale(0.7)
				icon:setAnchorPoint(0,0.5)
				button:addChild(icon)
				icon:setPosition(planBtn:getPositionX() + planBtn:getContentSize().width *0.5 + 2,planBtn:getPositionY())

				local lable = XTHDLabel:create("200",16,"res/fonts/def.ttf")
				lable:setColor(cc.c3b(238,241,19))
				lable:setAnchorPoint(0,0.5)
				lable:setPosition(icon:getPositionX() + icon:getContentSize().width *0.5 + 10,icon:getPositionY())
				button:addChild(lable)
			end

			local timelable = XTHDLabel:create(LANGUAGE_KEY_HANGUP(0),16,"res/fonts/def.ttf")
			timelable:setAnchorPoint(0.5,0.5)
			timelable:setColor(colorlist[i])
			button:addChild(timelable)
			timelable:setPosition(planBtn:getPositionX(),planBtn:getPositionY() - planBtn:getContentSize().height + 2)
			timeLablelist[i] = timelable
			
			timedata[i] = gameData.getDataFromCSV("HangUpTime",{id = i})
		end
		self._allTimeData[#self._allTimeData + 1] = timedata
		self._timeLableList[#self._timeLableList + 1] = timeLablelist
		self._btnLable[#self._btnLable  + 1] = btnlable
        layout:setTag(j)

        local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
        button:addChild(redDot)
        redDot:setPosition(button:getBoundingBox().width + 15, button:getBoundingBox().height)
        redDot:setVisible(true)
        redDot:setScale(0.7)
        self._redDot[j] = redDot
        self._hangUpButtons[j] = button

        self._buttonList:pushBackCustomItem(layout)
    end 
    -- self:freshRedDot()
    self:changeHangUp(self._hangUpIndex)
end

function BiGuanLayer:changeHangUp(id)
    -- print("-------------------id:"..id)
    if self.selectedIndex == id then
        return
    end

    for i = 1,#self._planBtn do
        self._labelNormal[i]:setString(self._btnNameTable[id])
        self._labelSelect[i]:setString(self._btnNameTable[id])
        local hour = self._localTimeData[i].hangupTime/60 < 1 and tostring(self._localTimeData[i].hangupTime).."分钟" or tostring(self._localTimeData[i].hangupTime/60).."小时"
        local value = math.floor(self._localTimeData[i].hangupTime/self._btnTable[id].outputtime*self._btnTable[id].count)
        local str = self._btnNameTable[id]..hour.."获得"..tostring(value)..self._btnTable[id].name
        self._des[i]:setString(str)
    end

    --self:freshData(id)

    self._hangUpButtons[id]:setSelected(true)
    if self._selectedButton then 
        self._selectedButton:setSelected(false)
    end 
    self._selectedButton = self._hangUpButtons[id]

    self.selectedIndex = id

    self:requestHangUpInfo(id)
    self:getHangUpLog(id)

end

--刷新数据
function BiGuanLayer:freshData(id)
	local typeId = math.floor(id / 10)
	local btnId = id - typeId *10
    --重置数据
    self._showData = {
        {
			[1] = {configId = 1,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 1,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 2,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 2,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 3,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 3,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 4,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 4,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 5,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 5,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 6,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 6,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 7,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 7,timeId = 2,isCanGet = false,endTime = 0}
		},
		{
			[1] = {configId = 8,timeId = 1,isCanGet = false,endTime = 0},
			[2] = {configId = 8,timeId = 2,isCanGet = false,endTime = 0}
		},
    }

	for j = 1 ,#self._hangUpButtons do
		local tempData = {}
		if #self.serverData.list == 0 then
			for i = 1,#self._showData[j] do
				self._showData[j][i].configId = self._btnTable[j].id
				self._showData[j][i].isCanGet = false
				self._showData[j][i].endTime = 0
			end
		else
			for i = 1,#self.serverData.list do
				if self._btnTable[j].id == self.serverData.list[i].configId then
					tempData = self.serverData.list[i]
					break
				end
			end
			for i = 1,#self._showData[j] do
				if self._showData[j][i].timeId == tempData.timeId then
					self._showData[j][i].configId = self._btnTable[j].id
					self._showData[j][i].isCanGet = tempData.state == 1
					self._showData[j][i].endTime = math.floor(tempData.endTime/1000)
				else
					self._showData[j][i].configId = self._btnTable[j].id
					self._showData[j][i].isCanGet = false
					self._showData[j][i].endTime = 0
				end
			end
		end
	end	
     self.isShowTime = false
     self.timeID = 1
	for i = 1, #self._showData do
		for j = 1,#self._showData[i] do
			if self._showData[i][j].endTime == 0 then
				local data = string.split(self._btnName[i],"#")
				if self._btnLable[i] then
					self._btnLable[i][j]:setString(data[j])
				end
			else
				 if self._showData[i][j].isCanGet == true then
					self._btnLable[i][j]:setString("领取")
					 if self._showData[i][j].endTime - os.time() > 0 then
						self.timeID = j
						self.isShowTime = true
					 end
				else
					self._btnLable[i][j]:setString(self._BebingbtnName[i])
					 self.timeID = j
					 self.isShowTime = true
				end
			end
		end
	end


	for i = 1,#self._timeLableList do
		for j = 1, #self._timeLableList[i] do
			 self._timeLableList[i][j]:setVisible(false)
		end
	end
	
	for i = 1,#self.serverData.list do
		local data = self.serverData.list[i]
		for j = 1, #self._timeLableList[data.configId] do
			local a = os.time()
			local time = math.floor(data.endTime / 1000) - os.time()
			self._endTimelist[data.configId] = time
			self._timeLableList[data.configId][data.timeId]:setVisible(true)
			if self._endTimelist[data.configId] <= 0 then
				self._timeLableList[data.configId][data.timeId]:setVisible(false)
			end
			self._timeLableList[data.configId][data.timeId]:setString(LANGUAGE_KEY_HANGUP(time))
		end
	end
	
	self:stopActionByTag(10)
	schedule(self, function()
		for i = 1, #self.serverData.list do
			local data = self.serverData.list[i]
			self._endTimelist[data.configId] = self._endTimelist[data.configId] - 1
			if self._endTimelist[data.configId] <= 0 then
				--self._timeLableList[data.configId][data.timeId]:setVisible(false)
			end
			for j = 1, #self._timeLableList[data.configId] do
				self._timeLableList[data.configId][j]:setString(LANGUAGE_KEY_HANGUP(self._endTimelist[data.configId]))
			end
		end
    end,1,10)

end

function BiGuanLayer:onPlanBtnClick(id)
	local typeId = math.floor(id / 10)
	local btnId = id - typeId*10
    print("timeId:"..id.."   configId:"..self._btnTable[self.selectedIndex].id)
    if gameUser.getVip() < self._allTimeData[typeId][btnId].mincondition then
        --加入充值跳转提示
        local show_msg = "抱歉，只有VIP"..self._allTimeData[typeId][btnId].mincondition .."才能"..self._btnNameTable[self.selectedIndex]..tostring(self._allTimeData[typeId][btnId].hangupTime/60).."小时,是否前往充值？"
        local confirmDialog = XTHDConfirmDialog:createWithParams({msg = show_msg})
        self:addChild(confirmDialog)
        confirmDialog:setCallbackRight(function ()
            LayerManager.addShieldLayout()
            XTHD.createRechargeVipLayer(self)
            confirmDialog:removeFromParent()
        end)
        return
    end
    if self._showData[typeId][btnId].endTime ~= 0 and self._showData[typeId][btnId].isCanGet == false then
        XTHDTOAST("正在"..self._tishiLable[typeId][btnId].."中，无法操作！")
        return
    end
    if self._showData[typeId][btnId].isCanGet == true then
		if self._endTimelist[self._showData[typeId][btnId].configId] > 0 then
			local _confirmLayer = XTHDConfirmDialog:createWithParams( {
				rightText = "确 定",
				rightCallback = function ( ... )
					 self:getHungUpReward(self._showData[typeId][btnId].configId)
				end,
				msg = ("当前未达到24小时是否提前领取奖励?(消耗元宝不返回)")
			} );
			self:addChild(_confirmLayer)
		else
			self:getHungUpReward(self._showData[typeId][btnId].configId)
		end
    else
		if btnId == 2 then
			local _confirmLayer = XTHDConfirmDialog:createWithParams( {
				rightText = "确 定",
				rightCallback = function ( ... )
					 self:startHungUp(self._showData[typeId][btnId].configId,btnId,id)
				end,
				msg = ("是否花费200元宝进行修行？")
			} );
			self:addChild(_confirmLayer)
		else
			self:startHungUp(self._showData[typeId][btnId].configId,btnId,id)
		end
    end 
    
end

--刷新进度条
function BiGuanLayer:freshProgressBar(bar,id)
    if (self._showData[id].endTime - os.time() <= 0)  then  --可收获了
        bar:setPercentage(0)
        -- self:requestHangUpInfo()
        return
    end
    local rate = (self._showData[id].endTime - os.time())/(self._localTimeData[id].hangupTime*60)
    bar:setPercentage(rate*100)
--     print("1:"..self._showData[id].endTime.."   2:"..os.time().."   3:"..self._localTimeData[id].hangupTime*60)
--     print("--------刷新进度条id:"..id.."     百分比："..rate)
end

--刷新小红点
function BiGuanLayer:freshRedDot()
    for i = 1,#self._redDot do
        self._redDot[i]:setVisible(false)
    end
    RedPointState[11].state = 0
    if #self.serverData.list ~= 0 then
        for i = 1,#self.serverData.list do
            if self.serverData.list[i].state == 1 then  --可收获
                for j = 1,#self._btnTable do
                    if self._btnTable[j].id == self.serverData.list[i].configId then
                        self._redDot[j]:setVisible(true)
                    end
                end
                RedPointState[11].state = 1
            end
        end
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "bg"}})
end

function BiGuanLayer:initHangUpLog(data)
    self._showLog = {}
    for i = 1,#data.hangUpLog do
        print("------------------type:"..type(data.hangUpLog[i]))
        --if type(data.hangUpLog[i]) ~= "userdata" then
            local str = "通过您孜孜不倦地"..self._btnNameTable[self.selectedIndex]..",收获了"..self._btnTable[self.selectedIndex].name.."x"..data.hangUpLog[i]
            table.insert(self._showLog,str)
       -- end
    end
    -- print("封装好的挂机日志为：")
    -- print_r(self._showLog)
    self.listBg:reloadData()
end

--刷新挂机信息
function BiGuanLayer:requestHangUpInfo(id)
    HttpRequestWithOutParams("hangUpList",function (data)
        -- print("刷新挂机信息服务器返回的数据为：")
        -- print_r(data)
        --刷新挂机信息
        self.serverData = data
        self:freshRedDot()
        self:freshData(id)
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
    end)
end

--请求挂机
function BiGuanLayer:startHungUp(id,timeId,typeId)
    HttpRequestWithParams("addHangUp",{configId = id,timeId = timeId},function (data)
        -- print("开始挂机服务器返回的数据为：")
        -- print_r(data)
        self:requestHangUpInfo(typeId)
		local _data = string.split(data.property[1],",")
		gameUser.updateDataById(_data[1],_data[2])
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
    end)
end

--请求收获
function BiGuanLayer:getHungUpReward(id)
	print("id============================",id)
    HttpRequestWithParams("getHangUpReward",{configId = id},function (data)
--         print("挂机收获服务器返回的数据为：")
--         print_r(data)
        local show = {} --奖励展示
        --货币类型
        if data.property and #data.property > 0 then
            for i=1,#data.property do
                local pro_data = string.split( data.property[i],',')
                --如果奖励类型存在，而且不是vip升级(406)则加入奖励
                print(XTHD.resource.propertyToType[tonumber(pro_data[1])])
                if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
                    local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
                    if getNum > 0 then
                        local idx = #show + 1
                        show[idx] = {}
                        show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
                        show[idx].num = getNum
                    end
                end
                DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
            end
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})        --刷新数据信息
        end

        --物品类型
        if data.bagItems and #data.bagItems ~= 0 then
            for i=1,#data.bagItems do
                local item_data = data.bagItems[i]
                local showCount = item_data.count
                if item_data.count and tonumber(item_data.count) ~= 0 then
                    --print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
                    showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId))
                    DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
                else
                    DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
                end
                --如果奖励类型
                local idx = #show + 1
                show[idx] = {}
                show[idx].rewardtype = 4 -- item_data.item_type
                show[idx].id = item_data.itemId
                show[idx].num = showCount
            end
        end
        --显示领取奖励成功界面
        ShowRewardNode:create(show)
        RedPointManage:reFreshDynamicItemData()
        self:requestHangUpInfo(self.selectedIndex)
        self:getHangUpLog(self.selectedIndex)
    end)
end

--请求挂机记录
function BiGuanLayer:getHangUpLog(id)
    HttpRequestWithParams("getHangUpLog",{configId = self._btnTable[id].id},function (data)
--        print("服务器返回的挂机日志数据为：")
--        print_r(data)
        self:initHangUpLog(data)
    end) 
end

function BiGuanLayer:getHangUpIndexByName( name )
    local index = {
        yingliang = 1,  
        feicui = 2,
        roleexp = 3,
        hsd = 4,
        jyg = 5,
        sqjjs = 6,
        tlz = 7,
        jjd = 8
    }
    return index[name]
end

return BiGuanLayer