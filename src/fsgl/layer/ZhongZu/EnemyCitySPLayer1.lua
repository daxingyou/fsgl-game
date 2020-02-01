local EnemyCitySPLayer1 = class("EnemyCitySPLayer1",function( )
	return XTHDDialog:create()		
end)

function EnemyCitySPLayer1:ctor(buildIndex,host,parent)
	self._buildIndex = buildIndex
	self._host = host
	self._parent = parent	

	self._cityName = { ----当前进的城市名字
		current = nil, 
		name = nil
	}
	self._killedAmount = { ----击杀排行(左边的已击杀敌军)
		label = nil,
		value = nil
	}
	self._remainderArmy = { ---剩余敌军
		label = nil,
		value = nil,
	}
	self._countDown = { ---倒计时
		label = nil,
		countDown = nil
	}
	self._numberOne = { ----击杀榜第一名
		label = nil,
		name = nil,
		atkAmount = nil,
	}
	self._fightCD = { ---战斗冷却时间 
		label = nil,
		time = nil,
	} -----挑战的冷却CD
	self._midBg = nil
	self._midList = nil
	self._leftBg = nil
	self._leftList = nil
	self._rightBg = nil
	self._rightList = nil
	self.Tag = {
		ktag_actionWarOverCD = 100, ----种族战结束倒计时
		ktag_actionColdCD = 101,----种族CD
	}
	self._isEnter = false

    self:sortDatas() 
    XTHD.addEventListener({name = CUSTOM_EVENT.CAMPWAR_OVERED , callback = function(event) ---种族战结束 
        self:backToMap()
    end})
end

function EnemyCitySPLayer1:create(buildIndex,host,parent)
	local _enemyCity = EnemyCitySPLayer1.new(buildIndex,host,parent)
	if _enemyCity then 
		_enemyCity:init()
	end 
	return _enemyCity
end

function EnemyCitySPLayer1:onEnter( )
	if self._isEnter then 
		self:reRequestCurrentCityData()		
	end 
	self._isEnter = true
end

function EnemyCitySPLayer1:onCleanup(  )
    XTHD.removeEventListener(CUSTOM_EVENT.CAMPWAR_OVERED)    	
end

function EnemyCitySPLayer1:init( )
	local winSize = cc.Director:getInstance():getWinSize()
	local bg = cc.Sprite:create("res/image/camp/camp_bg2.jpg")
	self:addChild(bg)
	bg:setContentSize(winSize)
	bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	----返回按钮
	local _backBtn = XTHD.createNewBackBtn(function( )
		self:removeFromParent()
	end)
	self:addChild(_backBtn)
	_backBtn:setPosition(self:getContentSize().width,self:getContentSize().height)
	---背景
	local back = cc.Sprite:create("res/image/camp/camp_bg3.png")	
	back:setContentSize(cc.size(1024 * winSize.width / 1024,528 * winSize.height / 615))
	back:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2 - 15)
	self:addChild(back)
	-----当前城市
	local titleBg = cc.Sprite:create("res/image/camp/map/camp_city_mark.png")
	titleBg:setAnchorPoint(0,0.5)	
	self:addChild(titleBg)
	self._cityName.current = titleBg
	----城市名字
	local _name = cc.Sprite:create("res/image/camp/map/camp_cityName_yellow"..self._buildIndex..".png")
	_name:setAnchorPoint(0,0.5)
	self:addChild(_name)
	self._cityName.name = _name
	local x = titleBg:getContentSize().width + _name:getContentSize().width
	x = (self:getContentSize().width - x) / 2
	titleBg:setPosition(x,back:getPositionY() + back:getBoundingBox().height / 2 + titleBg:getContentSize().height / 2)
	_name:setPosition(x + titleBg:getContentSize().width,titleBg:getPositionY())
	----中间的框 
	local _bgMid = cc.Sprite:create("res/image/camp/map/camp_cityInfo_bg3.png")
	back:addChild(_bgMid)
	_bgMid:setPosition(back:getBoundingBox().width / 2,back:getBoundingBox().height / 2 - 8)
	self._midBg = _bgMid
	----左框 
	local campID = gameUser.getCampID()
	local _bgLeft = cc.Sprite:create("res/image/camp/map/camp_cityInfo_bg"..campID..".png")
	back:addChild(_bgLeft)
	_bgLeft:setAnchorPoint(1,0.5)
	_bgLeft:setPosition(_bgMid:getPositionX() - _bgMid:getContentSize().width / 2 - 5,_bgMid:getPositionY())
	self._leftBg = _bgLeft
	---底
	local _bottom = cc.Sprite:create("res/image/camp/camp_box_bottom1.png")
	_bgLeft:addChild(_bottom)
	_bottom:setPosition(_bgLeft:getContentSize().width / 2,_bottom:getContentSize().height / 2)
	----右框 
	campID = 3 - gameUser.getCampID()
	_bgRight = cc.Sprite:create("res/image/camp/map/camp_cityInfo_bg"..campID..".png")
	back:addChild(_bgRight)
	_bgRight:setAnchorPoint(0,0.5)
	_bgRight:setPosition(_bgMid:getPositionX() + _bgMid:getContentSize().width / 2 + 5,_bgMid:getPositionY())
	self._rightBg = _bgRight
	---底
	_bottom = cc.Sprite:create("res/image/camp/camp_box_bottom2.png")
	_bgRight:addChild(_bottom)
	_bottom:setPosition(_bgRight:getContentSize().width / 2,_bottom:getContentSize().height / 2)
	-----剩余时间 
	local _label = cc.Sprite:create("res/image/camp/camp_remainder_time.png")
	self._midBg:addChild(_label)
	_label:setAnchorPoint(0,0.5)
	local _time = getCdStringWithNumber(60,{m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second,h = LANGUAGE_UNKNOWN.hour})
	_time = XTHDLabel:createWithSystemFont(_time,XTHD.SystemFont,18)
	_time:enableShadow(cc.c4b(255, 255, 255, 255), cc.size(1, 0))
	self._midBg:addChild(_time)
	_time:setAnchorPoint(0,0.5)
	x = _label:getContentSize().width + _time:getBoundingBox().width
	x = (self._midBg:getContentSize().width - x) / 2	
	_label:setPosition(x,self._midBg:getContentSize().height - 30)
	_time:setPosition(_label:getPositionX() + _label:getContentSize().width,_label:getPositionY())
	self._countDown.label = _label
	self._countDown.countDown = _time
	----------击杀大侠
	_label = cc.Sprite:create("res/image/camp/camp_kill_No1.png")
	self._midBg:addChild(_label)
	_label:setAnchorPoint(0,0.5)
	self._numberOne.label = _label
	---名字
	_name = XTHDLabel:createWithSystemFont("",XTHD.SystemFont,16)
	_name:setColor(cc.c3b(255,186,0))
	self._midBg:addChild(_name)
	_name:setAnchorPoint(0,0.5)
	-----击杀数量s
	local amount = XTHDLabel:createWithSystemFont(LANGUAGE_VERBS.kill.."123",XTHD.SystemFont,16)
	amount:setColor(cc.c3b(255,240,0))
	self._midBg:addChild(amount)
	amount:enableShadow(cc.c4b(255,240,0,255),cc.size(1,0))
	amount:setAnchorPoint(0,0.5)
	x = _label:getContentSize().width + _name:getContentSize().width + amount:getContentSize().width
	x = (self._midBg:getContentSize().width - x) / 2
	_label:setPosition(x,_time:getPositionY() - _time:getContentSize().height - 5)
	_name:setPosition(_label:getPositionX() + _label:getContentSize().width,_label:getPositionY() - 2)
	amount:setPosition(_name:getPositionX() + _name:getContentSize().width,_label:getPositionY() - 2)
	self._numberOne.name = _name
	self._numberOne.atkAmount = amount
	------中间的列表 
	local _size = cc.size(self._midBg:getContentSize().width - 10,320)
	self:initMidList(_size)
	-----底参战
	local _join = XTHD.createCommonButton({
        btnColor = "write_1",
		btnSize = cc.size(130,49),
		isScrollView = false,
	})
	_join:setScale(0.8)
	self._midBg:addChild(_join)
	_join:setPosition(self._midBg:getContentSize().width *0.5 + 10, _join:getContentSize().height / 2 - 5)
	_join:setTouchEndedCallback(function( )
		self:doJoinBattle()
	end)
	---字
	local _word = XTHD.resource.getButtonImgTxt("canzhan_lv")
	_join:addChild(_word)
	_word:setAnchorPoint(0,0.5)
	---图标
	local _icon = cc.Sprite:create("res/image/camp/camp_fight_icon.png")
	_join:addChild(_icon)
	_icon:setAnchorPoint(0,0.5)
	x = _icon:getContentSize().width + _word:getContentSize().width
	x = (_join:getContentSize().width - x) / 2
	_icon:setPosition(x,_join:getContentSize().height / 2)
	_word:setPosition(_icon:getPositionX() + _icon:getContentSize().width,_icon:getPositionY())
	------战斗 CD 
	_label = cc.Sprite:create("res/image/camp/map/camp_label10.png")
	self._midBg:addChild(_label)
	_label:setAnchorPoint(0,0.5)
	_label:setPosition(0,_join:getPositionY())
	self._fightCD.label = _label
	---CD
	_value = XTHDLabel:createWithSystemFont(0,XTHD.SystemFont,22)
	self._midBg:addChild(_value)
	_value:setAnchorPoint(0,0.5)
	_value:setPosition(_label:getPositionX() + _label:getBoundingBox().width,_label:getPositionY())
	self._fightCD.time = _value
	if not self._serverEnemyCityDatas or not self._serverEnemyCityDatas.cd then 
		_label:setVisible(false)
		_value:setVisible(false)
	end 

	self:initLeftContent()
	self:initRightContent()	
	self:refreshUI()
	self:startWarOverCountDown()
end

function EnemyCitySPLayer1:initLeftContent( )
	-----已击杀敌军
	local _hasKilled = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS10,XTHD.SystemFont,18)
	self._leftBg:addChild(_hasKilled)
	_hasKilled:setAnchorPoint(0,0.5)
	local _value = cc.Label:createWithBMFont("res/fonts/blueword.fnt",120)
	_value:setScale(0.7)
	_value:setAdditionalKerning(-2)
	self._leftBg:addChild(_value)
	_value:setAnchorPoint(0,0.5)
	local x = _hasKilled:getContentSize().width + _value:getContentSize().width
	x = (self._leftBg:getContentSize().width - x) / 2
	_hasKilled:setPosition(x,self._leftBg:getContentSize().height - _hasKilled:getContentSize().height)
	_value:setPosition(_hasKilled:getContentSize().width + _hasKilled:getPositionX(),_hasKilled:getPositionY() - 1)
	self._killedAmount.label = _hasKilled
	self._killedAmount.value = _value
	----参战势力
	local campID = gameUser.getCampID()
	local _powerImg = cc.Sprite:create("res/image/camp/camp_power"..campID..".png")
	self._leftBg:addChild(_powerImg)
	_powerImg:setAnchorPoint(0.5,1)
	_powerImg:setPosition(self._leftBg:getContentSize().width / 2,_hasKilled:getPositionY() - _hasKilled:getContentSize().height / 2 - 5)
	----
	local viewSize = cc.size(self._leftBg:getContentSize().width - 10,_powerImg:getPositionY() - _powerImg:getContentSize().height - 10)
	self:initLeftList(viewSize)
end

function EnemyCitySPLayer1:initRightContent( )
	-----剩余敌军
	local _remainder = XTHDLabel:createWithSystemFont(LANGUAGE_TIP_REST_ENEMY..":",XTHD.SystemFont,18)
	self._rightBg:addChild(_remainder)
	_remainder:setAnchorPoint(0,0.5)
	local _value = cc.Label:createWithBMFont("res/fonts/campbegin.fnt",120)
	_value:setScale(0.7)
	self._rightBg:addChild(_value)
	_value:setAdditionalKerning(-2)
	_value:setAnchorPoint(0,0.5)
	local x = _remainder:getContentSize().width + _value:getContentSize().width
	x = (self._rightBg:getContentSize().width - x) / 2
	_remainder:setPosition(x,self._rightBg:getContentSize().height - _remainder:getContentSize().height)
	_value:setPosition(_remainder:getContentSize().width + _remainder:getPositionX(),_remainder:getPositionY() - 1)
	self._remainderArmy.label = _remainder
	self._remainderArmy.value = _value	
	----参战势力
	local campID = 3 - gameUser.getCampID()
	local _powerImg = cc.Sprite:create("res/image/camp/camp_power"..campID..".png")
	self._rightBg:addChild(_powerImg)
	_powerImg:setAnchorPoint(0.5,1)
	_powerImg:setPosition(self._rightBg:getContentSize().width / 2,_remainder:getPositionY() - _remainder:getContentSize().height / 2 - 5)
	----
	local viewSize = cc.size(self._rightBg:getContentSize().width - 10,_powerImg:getPositionY() - _powerImg:getContentSize().height - 10)
	self:initRightList(viewSize)
end

function EnemyCitySPLayer1:initLeftList(viewSize)
    local cellSize = cc.size(viewSize.width,25)
    
    local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
    	return #ZhongZuDatas._serverEnemyCityDatas.aList
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else 
            cell:removeAllChildren()
        end
        local node = self:createHeroInfoCell(idx + 1,true)
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        return cell
    end

    local tableView = CCTableView:create(viewSize)
    tableView:setPosition(0,10)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self._leftBg:addChild(tableView)
    self._leftList = tableView
end

function EnemyCitySPLayer1:initRightList( viewSize )
    local cellSize = cc.size(viewSize.width,25)
    
    local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
    	return #ZhongZuDatas._serverEnemyCityDatas.bList
    end

    local function tableCellTouched(table,cell)        
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else 
            cell:removeAllChildren()
        end
        local node = self:createHeroInfoCell(idx + 1,false) 
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        return cell
    end

    local tableView = CCTableView:create(viewSize)
    tableView:setPosition(0,10)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self._rightBg:addChild(tableView)
    self._rightList = tableView
end

function EnemyCitySPLayer1:initMidList( viewSize )
    local cellSize = cc.size(viewSize.width,25)
    
    local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
        return #ZhongZuDatas._serverEnemyCityDatas.logs
    end

    local function tableCellTouched(table,cell)        
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else 
            cell:removeAllChildren()
        end
        local node = self:createFightLogCell(idx + 1)
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        return cell
    end

    local tableView = CCTableView:create(viewSize)
    tableView:setPosition(6,80)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self._midBg:addChild(tableView)
    self._midList = tableView
end

function EnemyCitySPLayer1:createHeroInfoCell( index,isSelf)
	local _infor = cc.Node:create()
	local _data = ZhongZuDatas._serverEnemyCityDatas
	if isSelf then -----左边
		_data = _data.aList[index]
	else  -----右边
		_data = _data.bList[index]
	end 
	if _data then 
		local str = LANGUAGE_FORMAT_TIPS48(_data.level,_data.name)
		_infor = XTHDLabel:createWithSystemFont(str,XTHD.SystemFont,18)
		local color = cc.c3b(26,158,207)
		if not isSelf then 
			color = cc.c3b(204,2,2)
		end 
		_infor:setColor(color)
	end 
	return _infor
end

function EnemyCitySPLayer1:createFightLogCell( index )
	local _data = ZhongZuDatas._serverEnemyCityDatas.logs
	local _infor = cc.Node:create()
	if _data[index] then 
		local _winner = _data[index].attackName
		local _loser = _data[index].defendName
		local _format = "<color=#1a9ecf fontSize=16 >%s</color><color=#cd6508 fontSize=16 >%s</color><color=#cc0202 fontSize=16 >%s</color>"
		local str = string.format(_format,_winner,(LANGUAGE_VERBS.kill..LANGUAGE_UNKNOWN.l),_loser) --富文本暂不处理string.format(英文版统一处理)
		_infor = RichLabel:createARichText(str,false)
	end 
	return _infor
end
-----更新数据 
function EnemyCitySPLayer1:refreshUI( )
	local _data = ZhongZuDatas._serverEnemyCityDatas 
	if _data then 
		------更新城市剩余敌军
		local x,y = self._remainderArmy.label:getPosition()
		local _remaind = _data.defendSum
		self._remainderArmy.value:setString(_remaind)
		x = self._remainderArmy.label:getBoundingBox().width + self._remainderArmy.value:getBoundingBox().width
		x = (self._rightBg:getBoundingBox().width - x) / 2
		self._remainderArmy.label:setPosition(x,y)
		self._remainderArmy.value:setPosition(x + self._remainderArmy.label:getBoundingBox().width, y - 2)
		----更新城市已击杀敌军数量 
		x,y = self._killedAmount.label:getPosition()
		self._killedAmount.value:setString(_data.killSum)
		x = self._killedAmount.label:getBoundingBox().width + self._killedAmount.value:getBoundingBox().width
		x = (self._leftBg:getBoundingBox().width - x) / 2
		self._killedAmount.label:setPosition(x,y)
		self._killedAmount.value:setPosition(x + self._killedAmount.label:getBoundingBox().width, y - 2)
		-----击杀榜第一名
		if _data.fristKillName ~= "" then 
			self._numberOne.name:setString(_data.fristKillName)			
			self._numberOne.atkAmount:setString(LANGUAGE_KEY_KILLED_NUMBER(_data.maxKillSum))
		else 
			self._numberOne.name:setString(LANGUAGE_KEY_WAITTINGHEADER)
			self._numberOne.atkAmount:setString("")
		end 
		x = self._numberOne.label:getBoundingBox().width + self._numberOne.name:getBoundingBox().width + self._numberOne.atkAmount:getBoundingBox().width
		x = (self._midBg:getBoundingBox().width - x) / 2
		self._numberOne.label:setPositionX(x)
		self._numberOne.name:setPositionX(x + self._numberOne.label:getBoundingBox().width)
		self._numberOne.atkAmount:setPositionX(self._numberOne.name:getPositionX() + self._numberOne.name:getBoundingBox().width)
		-------冷却倒计时
		self:startFightAginCD()
	end 
end

function EnemyCitySPLayer1:startWarOverCountDown( )
	if self._countDown.countDown then 
		local function adjustPos()
			local x = self._countDown.countDown:getBoundingBox().width + self._countDown.label:getBoundingBox().width
			x = (self._midBg:getBoundingBox().width - x) / 2
			self._countDown.label:setPositionX(x)
			self._countDown.countDown:setPositionX(x + self._countDown.label:getBoundingBox().width)
		end 
		ZhongZuDatas:getWarOverCountDown(self._countDown.countDown,self.Tag.ktag_actionWarOverCD,adjustPos)
	end 
end

function EnemyCitySPLayer1:startFightAginCD(start)	
	if self._fightCD.time then 
		if start == false then 
			self._fightCD.time:stopActionByTag(self.Tag.ktag_actionColdCD)
		else 
			local _data = ZhongZuDatas._serverEnemyCityDatas
			if _data and _data.cd then 
				self._fightCD.time:setString(_data.cd)
				local _second = _data.cd
				if _second > 0 then 
					self._fightCD.time:setVisible(true)
	                self._fightCD.label:setVisible(true)
	                self._fightCD.time:setString(_second)
				end 
				if not self._fightCD.time:getActionByTag(self.Tag.ktag_actionColdCD) then 
		            schedule(self._fightCD.time,function ( )
		                ZhongZuDatas._serverEnemyCityDatas.cd = ZhongZuDatas._serverEnemyCityDatas.cd - 1
		                if ZhongZuDatas._serverEnemyCityDatas.cd < 1 then 
		                    self._fightCD.time:stopActionByTag(self.Tag.ktag_actionColdCD)
		                    self._fightCD.time:setVisible(false)
		                    self._fightCD.label:setVisible(false)
		                else 
		                    self._fightCD.time:setVisible(true)
		                    self._fightCD.label:setVisible(true)
		                    self._fightCD.time:setString(ZhongZuDatas._serverEnemyCityDatas.cd)
		                end 
		            end,1.0,self.Tag.ktag_actionColdCD)
		        end 
			end 
		end 
	end 
end

function EnemyCitySPLayer1:reRequestCurrentCityData( )
    ZhongZuDatas.requestServerData({
        target = self,
        method = "campRivalCity?",
        params = {cityId = self._buildIndex},
        success = function(data)
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_CAMPBASE})
        	self._parent:updateEnemyCityDFDSUM(self._buildIndex,data)
        	self:sortDatas()
        	self:refreshUI()	
        	if self._leftList then 
        		self._leftList:reloadData()
        	end 	
        	if self._rightList then 
        		self._rightList:reloadData()
        	end 
        	if self._midList then 
        		self._midList:reloadData()
        	end 
    	end,
    	failure = function(data)
    		if data and data.result == 4821 then ----种族战结束了
				XTHD.dispatchEvent({name = CUSTOM_EVENT.CAMPWAR_OVERED})
    		elseif data and data.result == 4801 then ---该城市被占领
    			self:backToMap()
    		end 
    	end
    })
end

function EnemyCitySPLayer1:sortDatas( )
	if ZhongZuDatas._serverEnemyCityDatas then 
		table.sort(ZhongZuDatas._serverEnemyCityDatas.aList,function(a,b)
			return a.level > b.level
		end)
		table.sort(ZhongZuDatas._serverEnemyCityDatas.bList,function( a,b )
			return a.level > b.level
		end)
	end 
end

function EnemyCitySPLayer1:doJoinBattle( ) -----点击参战按钮
	ZhongZuDatas.requestServerData({
		target = self,
		method = "changeRival?",
		params = {cityId = self._buildIndex},
		success = function(data)
			-- dump(data)
			local _layer = requires("src/fsgl/layer/ZhongZu/ChooseOPLayer1.lua"):create(self)
			self:addChild(_layer)		
			self:startFightAginCD(false)
		end,
		failure = function(data)
			if data and data.result == 4801 then  ----城市已被占领
				self:backToMap()
			elseif data and data.result == 4821 then ----种族战结束
				XTHD.dispatchEvent({name = CUSTOM_EVENT.CAMPWAR_OVERED})
			end 
		end
	})
end

function EnemyCitySPLayer1:backToMap( )
	self._parent:requestEnemyCityList()
	self:removeFromParent()
end

return EnemyCitySPLayer1