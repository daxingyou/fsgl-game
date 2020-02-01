-- 卡牌羁绊界面

JiBanLayer = class("JiBanLayer",function(param)
	return XTHDPopLayer:create()
end)

function JiBanLayer:ctor(heroid)
	self._jibanConfigList = {}	
	self._canClick = false
	self._heroid = heroid
	self._scrollIndex = 1
	----背景
	local bg = cc.Sprite:create("res/image/jiban/jibanbg1.png" )
	bg:setAnchorPoint(cc.p(0.5, 0.5))
	local winSize = cc.Director:getInstance():getWinSize()	
	self:setContentSize(cc.size(winSize.width, winSize.height))

	bg:setPosition(cc.p(winSize.width / 2, winSize.height / 2))

	self:addContent(bg)
	self.bg = bg
end

function JiBanLayer:create(heroid)
	local JiBanLayer = JiBanLayer.new(heroid)
	if JiBanLayer then 
		JiBanLayer:init()
		JiBanLayer:registerScriptHandler(function(event )
			if event == "enter" then 
				JiBanLayer:onEnter()
			elseif event == "exit" then 
				JiBanLayer:onExit()
			end 
		end)	
    end
	return JiBanLayer
end

function JiBanLayer:init( )
	--self:initTabelView()   	
	self._canClick = true	

	self.jibanData = gameData.getDataFromCSV("Fetters")
	self.HeroData = gameData.getDataFromCSV("GeneralShow")
	for k,v in pairs(self.jibanData) do
		local data = string.split(v.needID,"#")
		for i = 1, #data do
			if self._heroid == tonumber(data[i]) then
				self._scrollIndex = k
			end
		end
	end
	self:reloadData()
end

function JiBanLayer:initTabelView(data)
    local tableView = cc.TableView:create(cc.size(479, 349))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	tableView:setBounceable(true)
    tableView:setPosition(294, 68)
	tableView:setDelegate()
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.bg:addChild(tableView)
	TableViewPlug.init(tableView)

	tableView.getCellNumbers = function( table )
		return #self.jibanData
	end
	
	tableView.getCellSize = function( table, idx )
		return 460,110
	end

	local function tableCellAtIndex( table, idx )
		local index = idx + 1
		local cell = table:dequeueCell()
		if cell then
    		cell:removeAllChildren()
		else
    		cell = cc.TableViewCell:new()
			cell:setContentSize(460,110)
		end
		local config = self.jibanData[index].state == 2
		self:createVeiwCell(cell, self.jibanData[index], self.jibanData[index].id, config)
		return cell
	end
	tableView:registerScriptHandler(tableView.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableView:registerScriptHandler(tableView.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.__msgTableView = tableView
	self.__msgTableView:scrollToCell(self._scrollIndex,true)
end

-- 奖励创建个tableView
function JiBanLayer:createTabelView()
	local tableView = ccui.ListView:create()
    tableView:setContentSize(cc.size(300, 80))
    tableView:setDirection(ccui.ScrollViewDir.horizontal)
    tableView:setBounceEnabled(true)
	tableView:setPosition(11, -3)
	tableView:setScrollBarEnabled(false)
	return tableView
end

function JiBanLayer:onEnter( )
    local function TOUCH_EVENT_BEGAN( touch,event )
    	return true
    end

    local function TOUCH_EVENT_MOVED( touch,event )
    	-- body
    end

    local function TOUCH_EVENT_ENDED( touch,event )
    	if self._canClick == false then
    		return
    	end
    	local pos = touch:getLocation()
    	local rect = self.bg:getBoundingBox()
    	if cc.rectContainsPoint(rect,pos) == false then
    		self._canClick = false
    		self:removeFromParent()
    	end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(TOUCH_EVENT_BEGAN,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(TOUCH_EVENT_MOVED,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(TOUCH_EVENT_ENDED,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
end

function JiBanLayer:onExit( ) 
end


function JiBanLayer:reloadData( )
	--if self.__msgTableView then 
	--	self.__msgTableView:removeAllChildren()
		local _url = "fettersWindow?"
		XTHDHttp:requestAsyncInGameWithParams({
			modules = _url,
			successCallback = function(data)
				if tonumber(data.result) == 0 then
					-- dump(data,"请求羁绊数据返回")
					self._jibanConfigList = data.configList
					-- print("向服务器请求的羁绊界面数据为：")
					-- print_r(data)
--					for i = #self.jibanData, 1, -1 do
--						local config = nil
--						for k,v in pairs(data.configList) do
--							if v.configId == i then
--								config = true
--							end
--						end

--						local node = self:createVeiwCell(self.jibanData[i], i, config)				
--						self.__msgTableView:insertCustomItem(node,0)
--						self.__msgTableView:setItems(self._scrollIndex)
--					end
					self:sortData()
					self:initTabelView(data)
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
				else
				   XTHDTOAST(data.msg)
				end
			end,--成功回调
			failedCallback = function()
				XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
			end,--失败回调
			targetNeedsToRetain = self,--需要保存引用的目标
			loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		})
	--end 	
end

function JiBanLayer:sortData()
	for i = 1,#self.jibanData do
		self.jibanData[i].state = 1
	end
	for i = 1, #self._jibanConfigList do
		for j = 1,#self.jibanData do
			if self._jibanConfigList[i].configId == self.jibanData[j].id then
				self.jibanData[j].state = 2
			end
		end
	end
	table.sort(self.jibanData,function(a,b)
		return tonumber(a.state) > tonumber(b.state)   
    end)
end

-- 激活羁绊
function JiBanLayer:activeJB(data, item)
	-- body
	local _url = "activateFetters?"
	XTHDHttp:requestAsyncInGameWithParams({
		modules = _url,
		params = {configId = data.id},
		successCallback = function(backData)
			if tonumber( backData.result ) == 0 then
				-- dump(backData,"77777")
				self._jibanConfigList = {}
				self._jibanConfigList = backData.configList
				-- 更新主角属性
				local property = backData.property
		    	if property and #property > 0 then
	                for i=1, #property do
	                    local pro_data = string.split( property[i], ',' )
	                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
	                end
	                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
	            end
	            -- 更新背包
	            if backData.bagItems and #backData.bagItems ~= 0 then
	                for i=1, #backData.bagItems do
	                    local item_data = backData.bagItems[i]
	                    if item_data.count and tonumber( item_data.count ) ~= 0 then
	                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
	                    else
	                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
	                    end
	                end
	            end
	            -- 更新英雄属性
	            if backData.petPropertys then
	            	for i, v in ipairs( backData.petPropertys ) do
	            		DBTableHero.multiUpdate( gameUser.getUserId(), v.baseId, v.property )
	            	end
	            end
				-- 设置当前为已激活
				local activeBtn  = item:getChildByName("activeBtn")
				local yActiveBtn = item:getChildByName("yActiveBtn")

				if activeBtn then
					activeBtn:setVisible(false)
				end
				if yActiveBtn then
					yActiveBtn:setVisible(true)
				end
				self:sortData()
				self.__msgTableView:reloadData()
            else
                XTHDTOAST(backData.msg)
            end
		end
	})
end

function JiBanLayer:showBoxTips( target,index )
    local winSize = cc.Director:getInstance():getWinSize()
    local boxTips = requires("src/fsgl/common_layer/BoxTipsNodeHero.lua")
    self._boxTips = boxTips:create({index = index , data = self.HeroData})
    if self._boxTips and target then 
    	self._boxTips:setName("_boxTips")
        self._boxTips:setAnchorPoint(1,1)
        if self:getParent() then 
        	self:getParent():removeChildByName("_boxTips")
        	self:getParent():addChild(self._boxTips,2048)
    	end 
        local pos = target:convertToWorldSpace(cc.p(0,0))
		pos = self:convertToNodeSpace(pos)
		
		self._boxTips:setAnchorPoint(0,1)

        self._boxTips:setPosition(pos.x,pos.y - target:getBoundingBox().height / 2 + 50)
        -- if self._boxTips:getPositionX() < self._boxTips:getBoundingBox().width then 
        --     self._boxTips:setAnchorPoint(0,1)
        --     self._boxTips:setPosition(pos.x + target:getBoundingBox().width - 25,pos.y - target:getBoundingBox().height / 2)
        -- end 
    end     
end

function JiBanLayer:createVeiwCell(cell, data, index, config)
	local cellBg = cc.Sprite:create("res/image/jiban/jibanbg2.png")
	cellBg:setAnchorPoint(cc.p(0.5, 0.5))
	cellBg:setContentSize(cc.size(460,110))
	cellBg:setPosition(cc.p(cell:getContentSize().width / 2 + 12, cell:getContentSize().height / 2))
	cell:addChild(cellBg)
	
	local tishi = cc.Sprite:create("res/image/jiban/tishi.png")
	cellBg:addChild(tishi)
	tishi:setPosition(cc.p(cellBg:getContentSize().width - tishi:getContentSize().width *0.65,cellBg:getContentSize().height - tishi:getContentSize().height/ 2 - 5))

	-- 标题
	local titleLabel = XTHD.createButton({
		normalNode = cc.Sprite:create("res/image/jiban/jbname"..index..".png"),
		selectNode = cc.Sprite:create("res/image/jiban/jbname"..index..".png"),
		needEnableWhenMoving = true,
		needEnableWhenOut = true,
		isScrollView = true,
	})
	titleLabel:setAnchorPoint(0,1)
	titleLabel:setPosition(19, cellBg:getContentSize().height - 4)
	cellBg:addChild(titleLabel)

	titleLabel:setTouchEndedCallback(function ()
		self:showJiBanInfo(index)
	end)

	local function getAvatar_Item(heroId)
		if heroId then
--			local heroNode = HeroNode:createWithParams({
--				heroid = heroId,
--				level = -1,
--				star = -1,
--				clickable = true,
--				needSwallow = true,
--				-- heroid   =hero_data["petId"],
--				-- star   = hero_data["star"],
--				-- level = hero_data["level"],
--				-- advance = hero_data["phase"],
--			})

			-- local targetData = gameData.getDataFromDynamicDB(gameUser.getUserId(), "hero", {heroid = heroId})

			local advance = cc.Sprite:create(XTHD.resource.getQualityHeroBgPath(gameData.getDataFromCSV("GeneralInfoList",{heroid = heroId}).rank or 0))

			local heroNode = XTHD.createButton({
				normalFile        = XTHD.resource.getHeroAvatorImgById(heroId),
				selectedFile      = XTHD.resource.getHeroAvatorImgById(heroId),
				musicFile = XTHD.resource.music.effect_btn_common,
				needEnableWhenMoving = true,
				isScrollView = true
			})
			advance:addChild(heroNode)			
			heroNode:setPosition(advance:getBoundingBox().width/2,advance:getBoundingBox().height/2)	
	
			heroNode:setTouchBeganCallback(function ()
				self:showBoxTips(heroNode, heroId)
			end)
			
			heroNode:setTouchMovedCallback(function(touch)
				 if not cc.rectContainsPoint( cc.rect( 0, 0, heroNode:getBoundingBox().width, heroNode:getBoundingBox().height ), heroNode:convertToNodeSpace( touch:getLocation() ) ) then
					if self._boxTips then 
						self._boxTips:removeFromParent()
						self._boxTips = nil
					end 
				end
			end)

			heroNode:setTouchEndedCallback(function() 
				if self._boxTips then 
					self._boxTips:removeFromParent()
					self._boxTips = nil
				end 
			end)
			
			local weihuode = cc.Sprite:create("res/image/common/weihuode.png")
			heroNode:addChild(weihuode)
			weihuode:setPosition(heroNode:getContentSize().width*0.5,heroNode:getContentSize().height - weihuode:getContentSize().height*0.5)

			---dump(DBTableHero.DBData[24],"英雄列表")
			local n = tonumber(heroId)
			if DBTableHero.DBData[n] == nil then
				XTHD.setGray(heroNode:getStateNormal(),true)
				XTHD.setGray(heroNode:getStateSelected(),true)
				weihuode:setVisible(true)
				for z = 1,#self.jibanData do
					if self.jibanData[z].id == index then
						self.jibanData[z].state = 0
						break
					end	
				end
				--XTHD.setGray(heroNode:getChildByName("item_border"):getChildByName("hero_img"),true)
			else
				XTHD.setGray(heroNode:getStateNormal(),false)
				XTHD.setGray(heroNode:getStateSelected(),false)
				weihuode:setVisible(false)
				--XTHD.setGray(heroNode:getChildByName("item_border"):getChildByName("hero_img"),false)
			end
			return advance
		end
	end

	local jibanList = string.split(data.needID, "#")
	local _tabView = nil
	if #jibanList > 6 then
		_tabView = self:createTabelView() 
		cellBg:addChild(_tabView)
	end
	--羁绊列表
	for i = 1, #jibanList do
		local heroData = jibanList[i]
        local item = getAvatar_Item(heroData)
		
	 	item:setScale(0.6)
	 	if not _tabView then
	 		item:setPosition((i - 1) * 65 + 40, 42)
	 		cellBg:addChild(item)
	 	else
			local itemSize = cc.size(60, 60)
			local node = ccui.Layout:create()
			node:setContentSize(itemSize)
			node:addChild(item)
			item:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
			_tabView:insertCustomItem(node, 0)
		end
	end

	local yActiveBtn = cc.Sprite:create("res/image/jiban/yijihuo.png")
	yActiveBtn:setName("yActiveBtn")
	yActiveBtn:setAnchorPoint(cc.p(1, 0.5))
	yActiveBtn:setPosition(cellBg:getContentSize().width - 6, cellBg:getContentSize().height * 0.5)
	cellBg:addChild(yActiveBtn)

	if not config then
		--羁绊是否激活
		local normalFile = "res/image/jiban/jihuo_up.png"
		local selectFile = "res/image/jiban/jihuo_down.png"

		local activeBtn = XTHD.createButton({
			normalFile = normalFile,
			selectedFile = selectFile,
			needEnableWhenMoving = true,
			endCallback = function ()
				self:activeJB(data, cellBg)
			end
		})
		activeBtn:setName("activeBtn")
		activeBtn:setAnchorPoint(cc.p(1, 0.5))
		activeBtn:setScale(0.8)
		activeBtn:setPosition(cellBg:getContentSize().width - 20, cellBg:getContentSize().height * 0.5 - 22)
		cellBg:addChild(activeBtn)
		for z = 1,#self.jibanData do
			if self.jibanData[z].id == index then
				if self.jibanData[z].state == 0 then
					XTHD.setGray(activeBtn:getStateNormal(),true)
					XTHD.setGray(activeBtn:getStateSelected(),true)
				else
					local Character = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
					activeBtn:addChild(Character)
					Character:setScale(0.8)
					Character:setPosition(activeBtn:getBoundingBox().width *0.65, activeBtn:getContentSize().height*0.5+2)
					Character:setAnimation(0, "querenjinjie", true )	
					XTHD.setGray(activeBtn:getStateNormal(),false)
					XTHD.setGray(activeBtn:getStateSelected(),false)
					XTHD.setGray(activeBtn:getStateNormal(),false)
					XTHD.setGray(activeBtn:getStateSelected(),false)
				end
				break
			end	
		end
		yActiveBtn:setVisible(false)
	end

end

function JiBanLayer:showJiBanInfo(index)
	local layer = requires("src/fsgl/layer/JiBan/ShowPopJiBanInfo.lua"):create(index)
	self:addChild(layer)
end

return JiBanLayer