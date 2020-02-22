-- FileName: QIRiKuangHuang.lua
-- Date: 20190603
-- Purpose: 七日狂欢
--[[TODO List]]

local QIRiKuangHuang = class("QIRiKuangHuang", function()
	return XTHD.createPopLayer()
end)

function QIRiKuangHuang:onCleanup()
	self._globalScheduler:destroy(true)
	self._globalScheduler = nil
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_TASKLIST)
    local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey("res/image/activities/carnivalSevenDay/carnival_bg.png")
--	textureCache:removeTextureForKey("res/image/activities/carnivalSevenDay/carnival_title.png")
end

function QIRiKuangHuang:ctor( sData )
	self._globalScheduler = GlobalScheduler:create(self)

	self._listData = {}
	self._timeUpdateName = "CARNIVAL_SEVENDAY"
	local _bg = XTHD.createSprite("res/image/activities/carnivalSevenDay/carnival_bg.png")
	_bg:setPosition(self:getContentSize().width*0.5, (self:getContentSize().height)*0.5)
	self._bg = _bg
	-- _bg:setScaleX(self:getContentSize().width/_bg:getContentSize().width)
	-- _bg:setScaleY(self:getContentSize().height/_bg:getContentSize().height)
	self:addContent(_bg)

	local btn_close = XTHDPushButton:createWithFile({
		normalFile = "res/image/activities/chaozhiduihuan/btn_close_up.png",
		selectedFile = "res/image/activities/chaozhiduihuan/btn_close_down.png",
		musicFile = XTHD.resource.music.effect_btn_commonclose,
		endCallback  = function()
           self:hide()
		end,
	})
	self._bg:addChild(btn_close)
	btn_close:setPosition(self._bg:getContentSize().width - btn_close:getContentSize().width * 0.5 + 5,self._bg:getContentSize().height - btn_close:getContentSize().height * 0.5 - 16)

	local bg_2 = cc.Sprite:create("res/image/activities/carnivalSevenDay/bg_2.png")
	_bg:addChild(bg_2)
	bg_2:setPosition(bg_2:getContentSize().width *0.5 + 85,_bg:getContentSize().height *0.5 - 48)
	--插图
	local chatu = XTHD.createSprite("res/image/activities/carnivalSevenDay/qirikuanghuanchatu.png")
	chatu:setAnchorPoint(0.5,0.5)
	chatu:setScaleX(0.8)
	chatu:setScaleY(0.9)
	chatu:setPosition(bg_2:getContentSize().width *0.5,bg_2:getContentSize().height/2)
	bg_2:addChild(chatu)
	local _bgSize = _bg:getContentSize()
	self._bgSize = _bgSize

--	local _title = XTHD.createSprite("res/image/activities/carnivalSevenDay/carnival_title.png")
--    _title:setPosition(_bgSize.width*0.5, _bgSize.height - 30)
--	_bg:addChild(_title)

	--活动倒计时
	local _timeTTF = XTHDLabel:createWithParams({
		text = "",
		ttf = "res/fonts/hkys.ttf",
		size = 16,
		color = cc.c3b(200,0,20),
		pos = cc.p(bg_2:getContentSize().width *0.5, bg_2:getContentSize().height - 25)
	})
	bg_2:addChild(_timeTTF)
	self._timeTTF = _timeTTF


	local _pinkBgSize = cc.size(525, 338)

	local _pinkBg = cc.Node:create()-- ccui.Scale9Sprite:create("res/image/activities/carnivalSevenDay/carnival_di1.png")
	_pinkBg:setAnchorPoint(0, 0)
	_pinkBg:setContentSize(_pinkBgSize)
	_pinkBg:setPosition(280, 15)
	_bg:addChild(_pinkBg)

	local _tableView = cc.TableView:create(_pinkBgSize)
	TableViewPlug.init(_tableView)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _tableView:setBounceable(true)
    _tableView:setDelegate()
    _pinkBg:addChild(_tableView)

    local _cellSize = cc.size(_pinkBgSize.width, 120)
    
	_tableView.getCellNumbers = function( table )
    	local count = #self._listData
        return count
    end
	
	_tableView.getCellSize = function( table, idx )
        return _cellSize.width, _cellSize.height + 5
    end
     
    local function tableCellAtIndex( table, idx )
        local _cell = table:dequeueCell()
        if _cell == nil then
            _cell = cc.TableViewCell:new()
            _cell:setContentSize(_cellSize)
        else
            _cell:removeAllChildren()
        end

        local _cellDi = ccui.Scale9Sprite:create("res/image/activities/carnivalSevenDay/cellbg.png")
		_cellDi:setContentSize(_cellSize.width - 4, _cellSize.height)
		_cellDi:setAnchorPoint(0.5, 0)
		_cellDi:setPosition(_cellSize.width*0.5, 0)
		_cell:addChild(_cellDi)


		local _mData = self._listData[idx + 1]
		if _mData then
			self:createCell(_cellDi, _mData)
		end
	
        return _cell
    end

    _tableView:registerScriptHandler(_tableView.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    _tableView:registerScriptHandler(_tableView.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView = _tableView

    --右侧标签
    self._typeBtns = {}
	for i=1, 4 do
		local _btn
		_btn = XTHD.createButton({
			normalFile = "res/image/activities/carnivalSevenDay/carnival_rBtn1.png",
			selectedFile = "res/image/activities/carnivalSevenDay/carnival_rBtn2.png",
			-- text = LANGUAGE_TIPS_WORDS248[i],
			fontSize = 20,
			fontColor = cc.c3b(88, 81, 115),
			endCallback = function( ... )
				self:doSelectType(_btn)
			end,
			anchor = cc.p(0, 0.5),
		})
		_btn:setPosition(self._bg:getContentSize().width - _btn:getContentSize().width - 73, self._bg:getContentSize().height - _btn:getContentSize().height*0.5 - 28 - (i-1)*(_btn:getContentSize().height + 3))
		local _redPoint = XTHD.createSprite("res/image/common/heroList_redPoint.png")
		_redPoint:setAnchorPoint(0.5, 0.5)
		_redPoint:setPosition(_btn:getContentSize().width - 5, _btn:getContentSize().height - 5)
		_btn:addChild(_redPoint)

		_btn._redPoint = _redPoint
		_btn._typeIndex = i

		self._bg:addChild(_btn)
		self._typeBtns[i] = _btn
	end

--    local _line = XTHD.createSprite("res/image/activities/carnivalSevenDay/carnival_line.png")
--    _line:setPosition(_pinkBgSize.width, 0)
--    _line:setAnchorPoint(0, 0)
--	_pinkBg:addChild(_line, 1)

	--底部天数按钮
    self._dayBtns = {}
	for i=1, 7 do 
		local _btn 
		_btn = XTHD.createButton({
			normalFile = "res/image/activities/carnivalSevenDay/btn_" .. tostring(i) .. "_up.png",
			selectedFile = "res/image/activities/carnivalSevenDay/btn_" .. tostring(i) .. "_down.png",
			fontSize = 20,
			fontColor = cc.c3b(246, 252, 210),
			endCallback = function( ... )
				self:doSelectDay(_btn)
			end,
			anchor = cc.p(0.5, 1),
		})
		_btn:setPosition(40 + _btn:getContentSize().width + (_btn:getContentSize().width + 6)*(i - 1) , self._bg:getContentSize().height - _btn:getContentSize().height - 5)
		local _redPoint = XTHD.createSprite("res/image/common/heroList_redPoint.png")
		_redPoint:setScale(0.6)
		_redPoint:setAnchorPoint(0.5, 0.5)
		_redPoint:setPosition(_btn:getContentSize().width - _redPoint:getContentSize().width *0.2, _btn:getContentSize().height - _redPoint:getContentSize().height *0.2)
		_btn:addChild(_redPoint)

		_btn._redPoint = _redPoint
		_btn._dayIndex = i

		_bg:addChild(_btn)
		self._dayBtns[i] = _btn
	end
	
	self:updateSelfDatas(sData)
	self:doSelectDay(self._dayBtns[1])
	XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_TASKLIST,
        callback = function ()
            self:refreshList(true)
        end,
    })
end
--更新整体数据
function QIRiKuangHuang:updateSelfDatas( sData )
	self._datas = sData
	for k,v in pairs(self._datas.list) do
		local _db = gameData.getDataFromCSV("OpenCarnival", {id = v.configId})
		self._datas.list[k].day = _db.day
		self._datas.list[k].tagpart = _db.tagpart
	end
	if self._datas.diffTime <= 0 then
		self._globalScheduler:removeCallback(self._timeUpdateName)
		self._timeTTF:setString(LANGUAGE_TIPS_WORDS249)
	else
		self._timeTTF:setString(LANGUAGE_KEY_CARNIVALDAY(self._datas.diffTime))

		self._globalScheduler:addCallback(self._timeUpdateName, {
			cdTime = self._datas.diffTime,
			endCall = function ()
				self._globalScheduler:removeCallback(self._timeUpdateName)
				self._timeTTF:setString(LANGUAGE_TIPS_WORDS249)
			end,
			perCall = function ( time )
				self._timeTTF:setString(LANGUAGE_KEY_CARNIVALDAY(time))
			end
		})
	end
end
--获取某一天的数据封装
function QIRiKuangHuang:getWebInfosByDay( _day )
	local _tb = {}
	local _db
	for k,v in pairs(self._datas.list) do
		-- _db = gameData.getDataFromCSV("OpenCarnival", {id = v.configId})
		if v.day == _day then
			-- local _data = clone(v)
			-- _data.day = _day
			-- _data.tagpart = _db.tagpart
			-- _tb[#_tb + 1] = _data
			_tb[#_tb + 1] = v
		end
	end
	return _tb
end
--更新刷新列表
function QIRiKuangHuang:refreshList( isStay )
	if not self._lastDayBtn then
		return
	end
	local _day = self._lastDayBtn._dayIndex
	local _type = self._lastTypeBtn._typeIndex
	local datas = gameData.getDataFromCSV("OpenCarnival", {day = _day, tagpart = _type})
	if #datas <= 0 then
		datas = {datas}
	end
	
	local function _orderDatas( ... )
		if #datas > 0 then
			for k,v in pairs(datas) do
				local Id = v.id
				for key,value in pairs(self._datas.list) do
					if value.configId == v.id then
						datas[k].state = value.state
						datas[k].curNum = value.curNum
						datas[k].maxNum = value.maxNum
						break
					end
				end
			end
			table.sort(datas, function ( a, b )
				if a.state == 2 or b.state == 2 and a.state ~= b.state then
					return a.state ~= 2
				end
				return a.id < b.id
			end)
		end
		-- printTime()
		local _today = tonumber(self._datas.day) or 1
		local _datas, _haveDayRed, haveRed
		local _typesRed = {false,false,false,false}
		for i=1, 7 do
			_datas = self:getWebInfosByDay(i)
			_haveDayRed = false
			if #_datas > 0 then
				for k,v in pairs(_datas) do
					if i <= _today then
						if v.state == 1 then
							_haveDayRed = true
							if i == _day then
								_typesRed[v.tagpart] = true
							else
								break
							end
						end
					end
				end
			end
			if _haveDayRed then
				haveRed = true
			end
			-- printTime(i,"time" .. i)
			if i == _day then
				self._dayBtns[i]._redPoint:setVisible(false)
				for j=1, 4 do
					if j == _type then
						_typesRed[j] = false
					end
					self._typeBtns[j]._redPoint:setVisible(_typesRed[j])
				end
			else
				self._dayBtns[i]._redPoint:setVisible(_haveDayRed)
			end
		end

		if not haveRed then
			gameUser.setSevenDayRedPoint(0)
		else
			gameUser.setSevenDayRedPoint(1)
		end
		self._listData = datas
	end

	if isStay then --需要更新重新拉取数据
		local function _fresh( sData )
			self:updateSelfDatas(sData)
			_orderDatas()
			self._tableView:reloadDataAndScrollToCurrentCell()
		end
		LayerManager.addShieldLayout()
		ClientHttp.http_OpenServerActivityList(self, _fresh)
	else
		_orderDatas()
		self._tableView:reloadData()
	end
end
--选择天
function QIRiKuangHuang:doSelectDay( sBtn )
	local index = sBtn._dayIndex
	local _today = tonumber(self._datas.day) or 1
	if index > _today then
		XTHDTOAST(LANGUAGE_KEY_CARNIVALTIP(index))
		return
	end
	if self._lastDayBtn == sBtn then
		return
	end
	if self._lastDayBtn then
		self._lastDayBtn:setSelected(false)
		-- self._lastDayBtn:setEnable(true)
	end
	sBtn:setSelected(true)
	-- sBtn:setEnable(false)
	for i=1,4 do
		local datas = gameData.getDataFromCSV("OpenCarnival", {day = index, tagpart = i})
		if #datas <= 0 then
			datas = {datas}
		end
		if datas and datas[1] and next(datas[1]) ~= nil then
			self._typeBtns[i]:setVisible(true)
			self._typeBtns[i]:setText(datas[1].taskname)
		else
			self._typeBtns[i]:setVisible(false)
		end
	end
	self._lastDayBtn = sBtn
	self:doSelectType(self._typeBtns[1], true)
end
--选择右侧标签
function QIRiKuangHuang:doSelectType( sBtn , sReset)
	if not sReset and self._lastTypeBtn == sBtn then
		return
	end
	local index = sBtn._typeIndex
	if self._lastTypeBtn then
		self._lastTypeBtn:setSelected(false)
		-- self._lastTypeBtn:setEnable(true)
		self._lastTypeBtn:setLocalZOrder(0)
	end
	sBtn:setSelected(true)
	-- sBtn:setEnable(false)
	sBtn:setLocalZOrder(1)
	self._lastTypeBtn = sBtn
	self:refreshList()
end
--创建物品icon
function QIRiKuangHuang:createIcons( data )
	-- icons容器
	local icons = cc.Node:create()
	icons:setContentSize( 300, 80 )
	-- icons数据，ShowResult弹窗使用
	local iconData = {}
	for i = 1, 4 do
        if data["reward"..i.."type"] then
            local count = data["reward"..i.."param"]
            local itemid = nil
            if data["reward"..i.."type"] == 4 then
                local tempTable = string.split(data["reward"..i.."param"],"#")
                itemid = tempTable[1]
                count = tempTable[2]
            end
            local rewardIcon = ItemNode:createWithParams({
                _type_ = data["reward"..i.."type"],
                itemId = itemid,
                count = count,
				showDrropType = 2,
            })
            rewardIcon:setScale(0.7)
            rewardIcon:setAnchorPoint(0.5, 0.5 )
            rewardIcon:setPosition(50 + 70*(i-1), 40 )
            icons:addChild( rewardIcon )
            if data["reward"..i.."type"] == 4 then
            	iconData[#iconData + 1] = {
	                rewardtype = data["reward"..i.."type"],
	                id = itemid,
	                num = count,
	        	}
	        else
	            iconData[#iconData + 1] = {
	                rewardtype = data["reward"..i.."type"],
	                num = count,
	        	}
	        end
        end
    end
    return icons, iconData
end
--更新某任务的状态
function QIRiKuangHuang:updateListState( configId, state)
	for k,v in pairs(self._datas.list) do
		if v.configId == configId then
			v.state = state
			break
		end
	end
end
--创建列表元素
function QIRiKuangHuang:createCell( cell, data )
--	dump(data)
	local _cellDiSize = cc.size(cell:getBoundingBox().width, cell:getBoundingBox().height - 30)
	--描述
	local _desc = XTHDLabel:createWithParams({
		text = data.description,
		size = 19,
		color = cc.c3b(61, 55, 99),
		anchor = cc.p(0, 0),
		pos = cc.p(40, _cellDiSize.height - 2)
	})
	cell:addChild(_desc)
	--任务tip
	local _tip = getCompositeNodeWithImg("res/image/activities/carnivalSevenDay/jianglibg.png", "res/image/activities/carnivalSevenDay/jianglibg.png")
	_tip:setAnchorPoint(0, 0.5)
	_tip:setPosition(10, _cellDiSize.height*0.5 + 1)
	cell:addChild(_tip)

	--奖励icon
	local icons, iconData = self:createIcons(data)
	icons:setAnchorPoint(cc.p(0, 0.5))
	icons:setPosition(50, _cellDiSize.height*0.5)
	cell:addChild(icons)

	local _state = tonumber(data.state) or -1
	local _x = 74
	local _num = ""
	local _cur = tonumber(data.curNum) or 0
	local _max = tonumber(data.maxNum) or 1
	if _max > 1000 then
--		_num = math.modf(_cur/_max*100)
--		_num = _num > 100 and 100 or _num
--		_num = _num .. "%"
		_num = tostring(getHugeNumberWithLongNumber(_cur,10000)) .. "/" .. _max
	else
		_num = _cur .. "/" .. _max
	end
	-- 任务按钮
	local _showNode
	if _state == 1 then
		local _progress1 = XTHD.createLabel({
			text      = LANGUAGE_TASK_PROGRESS .. ":",
			fontSize  = 15,
			anchor    = cc.p(0, 0.5 ),
			pos       = cc.p(_cellDiSize.width - _x - 15, _cellDiSize.height*0.8),
			color     = cc.c3b(70, 34, 34),
		})
		local _progress2 = XTHD.createLabel({
			text      = _num,
			fontSize  = 15,
			anchor    = cc.p(0, 0.5 ),
			pos       = cc.p(_cellDiSize.width - _x + 3, _cellDiSize.height*0.8),
			color     = cc.c3b(255, 112, 62),
		})
		local node = cc.Node:create()
		node:setAnchorPoint(0.5,0.5)
		node:setContentSize(_progress1:getContentSize().width + _progress2:getContentSize().width + 10,_progress1:getContentSize().height)
		cell:addChild(node)
		node:setPosition(_cellDiSize.width - _x - 6, _cellDiSize.height*0.8)

		node:addChild(_progress1)
		node:addChild(_progress2)

		_progress1:setPosition(4,node:getContentSize().height *0.5)
		_progress2:setPosition(_progress1:getContentSize().width + _progress1:getPositionX(),node:getContentSize().height *0.5)
		-- 领取
		_showNode = XTHD.createButton({
			normalFile = "res/image/activities/hdbtn/btn_gray_up.png",
			selectedFile = "res/image/activities/hdbtn/btn_gray_down.png",
			text = LANGUAGE_KEY_SPACEFETCH,
			isScrollView = true,
			fontColor = cc.c3b(255, 255, 255),
			fontSize = 23,
			touchSize = cc.size(130, 60),
			anchor = cc.p(0.5, 0.5),
			endCallback = function()
				LayerManager.addShieldLayout()
				ClientHttp.http_OpenServerActivityReward(self, function ( sData )
					self:updateListState(data.id, 2)
                  	self:refreshList()
                  	-- 成功获取弹窗
				    ShowRewardNode:create(iconData)
			    	-- 更新属性
			    	if sData.property and #sData.property > 0 then
		                for i=1, #sData.property do
		                    local pro_data = string.split(sData.property[i], ',')
		                    DBUpdateFunc:UpdateProperty("userdata", pro_data[1], pro_data[2])
		                end
		                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
		                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
		            end
		            -- 更新背包
		            if sData.bagItems and #sData.bagItems ~= 0 then
		                for i=1, #sData.bagItems do
		                    local item_data = sData.bagItems[i]
		                    if item_data.count and tonumber(item_data.count) ~= 0 then
		                        DBTableItem.updateCount(gameUser.getUserId(), item_data, item_data.dbId)
		                    else
		                        DBTableItem.deleteData(gameUser.getUserId(), item_data.dbId)
		                    end
		                end
		            end
				end, {configId = data.id})
			end,
		})
		_showNode:getLabel():setPositionY(_showNode:getLabel():getPositionY() - 2)
		_showNode:getStateNormal():setScale(0.8)
		_showNode:getStateSelected():setScale(0.8)
		_showNode:setPosition(_cellDiSize.width - _x - 6, _cellDiSize.height*0.35 )
		cell:addChild(_showNode)
		--按钮动画
		local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		_showNode:addChild(fetchSpine)
		fetchSpine:setScale(0.8)
		fetchSpine:setPosition(_showNode:getBoundingBox().width*0.5, _showNode:getContentSize().height*0.5+2)
		fetchSpine:setAnimation(0, "querenjinjie", true )
	elseif _state == 2 then
		-- 已领取
		_showNode = XTHD.createSprite("res/image/vip/yilingqu.png")
		_showNode:setPosition(_cellDiSize.width - _x - 5 , _cellDiSize.height*0.5 )
		cell:addChild(_showNode)
	elseif data.gotype ~= 0 then
		-- 可前往
		local _progress1 = XTHD.createLabel({
			text      = LANGUAGE_TASK_PROGRESS .. ":",
			fontSize  = 15,
			anchor    = cc.p(0.5, 0.5 ),
			pos       = cc.p(_cellDiSize.width - _x - 15, _cellDiSize.height*0.8),
			color     = cc.c3b(70, 34, 34),
		})
		cell:addChild(_progress1)
		local _progress2 = XTHD.createLabel({
			text      = _num,
			fontSize  = 15,
			anchor    = cc.p(0, 0.5 ),
			pos       = cc.p(_cellDiSize.width - _x + 17, _cellDiSize.height*0.8),
			color     = cc.c3b(255, 112, 62),
		})
		cell:addChild(_progress2)

		_showNode = XTHD.createButton({
			normalFile = "res/image/activities/hdbtn/btn_gray_up.png",
			selectedFile = "res/image/activities/hdbtn/btn_gray_down.png",
			text = LANGUAGE_KEY_SPACEGOTO,
			isScrollView = true,
			fontColor = cc.c3b( 255, 255, 255 ),
			fontSize = 26,
			anchor = cc.p( 0.5, 0.5 ),
			touchSize = cc.size(130, 60),
			endCallback = function()
				LayerManager.addShieldLayout()
				replaceLayer({
                    fNode = self,
                    id = data.gotype,
                    chapterId = data.goparam,
                    callback = function ()
                        self:refreshList(true)
                    end,
                })
			end,
		})
		_showNode:getLabel():setPositionY(_showNode:getLabel():getPositionY()-2)
		_showNode:getStateNormal():setScale(0.8)
		_showNode:getStateSelected():setScale(0.8)
		_showNode:setPosition(_cellDiSize.width - _x - 6, _cellDiSize.height*0.35 )
		cell:addChild(_showNode)
	else-- 未完成
		_showNode = XTHD.createButton({
			normalFile = "res/image/activities/hdbtn/btn_gray_up.png",
			selectedFile = "res/image/activities/hdbtn/btn_gray_down.png",
			text = LANGUAGE_KEY_NOTREACHABLE,
			fontSize = 26,
			anchor = cc.p( 0.5, 0.5 ),
			touchSize = cc.size(130, 60),
			isScrollView = true,
	        pos = cc.p( _cellDiSize.width - _x - 6, _cellDiSize.height*0.5 ),
	   })
		_showNode:getStateNormal():setScale(0.8)
		_showNode:getStateSelected():setScale(0.8)
		cell:addChild(_showNode)
	end
	if _state == 2 then
		_showNode:setScale(0.7)
	else
		_showNode:setScale(0.8)
	end
	
end

function QIRiKuangHuang:create( data )
	return QIRiKuangHuang.new(data)
end

--转换时间格式


return QIRiKuangHuang