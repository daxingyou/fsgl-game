--[[
显示当前我方种族城市的队伍信息战斗力
]]
local ZhongZuCityInfoLayer = class("ZhongZuCityInfoLayer",function( )
	return XTHD.createBasePageLayer()
end)

function ZhongZuCityInfoLayer:ctor(cityID,parent,defendSum)
	self.__cityID = cityID
	self.__parent = parent

	self._selfTeamAmount = 0------自己在该城市里的队伍数量
	self._teamDatas = {}
	self._cityAllVIM = 0 ------该城市总战斗力
	self._cityAllTeam = defendSum -----总队伍 
	self._cityAllPerson = 0 ---总人数 
	self._currentPageIndex = 1 ----当前页
	
	self._bg = nil -------卷轴
	self._leftBg = nil ----左背景
	self._rightBg = nil ---右背景
	self._nextPageBtn = nil
	self._prePageBtn = nil
	self._pageNumber = nil

	self._totalPowerLabel = nil 
	self._totalHeroLabel = nil
	self._totalTeamLabel = nil
	self._teamList = nil
	self._cityData = ZhongZuDatas._localCity[cityID]

	self._cityProperty = {} -----城市属性数据
	local key = string.split(self._cityData.cityeffect,"#")
	local val = string.split(self._cityData.starteffect,"#")
	for i = 1,#key do
		self._cityProperty[tonumber(key[i])] = tonumber(val[i])
	end 
	self._cityLevel = ZhongZuDatas._serverSelfCityDatas.cityLevel
end

function ZhongZuCityInfoLayer:create(cityID,parent,defendSum)
    ZhongZuDatas.requestServerData({
		target = parent,
        method = "campSelfCity?",
        params = {cityId = cityID,page = 1},
        success = function( )
			local info = ZhongZuCityInfoLayer.new(cityID,parent,defendSum)
			if info then 
				info:init()
			end 
        	LayerManager.addLayout(info)
        end
    })
end

function ZhongZuCityInfoLayer:init( )	
	self:formatTeamDatas()----整合队伍数据
	----背景
	local bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
	self:addChild(bg)
	bg:setPosition(self:getContentSize().width / 2,(self:getContentSize().height - self.topBarHeight) / 2)
	self._bg = bg	
	
	local title = "res/image/public/chengchi_title.png"
	XTHD.createNodeDecoration(self._bg,title)
	
	-----左边背景
	bg1 = ccui.Scale9Sprite:create()
	bg1:setContentSize(cc.size(self._bg:getContentSize().width * 3/10 + 35,self._bg:getContentSize().height - 100))
	self._bg:addChild(bg1)
	bg1:setAnchorPoint(0,0.5)
	bg1:setPosition(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2)
	self._leftBg = bg1
	---右边背景
	bg2 = ccui.Scale9Sprite:create()
	bg2:setContentSize(cc.size(self._bg:getContentSize().width * 3/5 + 50,self._bg:getContentSize().height - 130))
	self._bg:addChild(bg2)
	bg2:setAnchorPoint(0,0.5)
	self._rightBg = bg2
	
	local x = self._leftBg:getContentSize().width + self._rightBg:getContentSize().width
	x = (self._bg:getContentSize().width - x) / 2
	self._leftBg:setPosition(x,self._bg:getContentSize().height*0.5 + 30)
	self._rightBg:setPosition(self._leftBg:getPositionX() + self._leftBg:getContentSize().width + 2,self._bg:getContentSize().height*0.5 + 50 )
	----城市总战力
	-- local _labelIcon = cc.Sprite:create("res/image/camp/map/camp_label1.png")
	local _labelIcon = XTHDLabel:create("该营地总战斗力：",24,"res/fonts/def.ttf")
	_labelIcon:setColor(cc.c3b(255,255,255))
	_labelIcon:enableOutline(cc.c4b(84,3,3,255),1)
	self._rightBg:addChild(_labelIcon)
	_labelIcon:setPosition(_labelIcon:getContentSize().width / 2 + 10,self._rightBg:getContentSize().height - _labelIcon:getContentSize().height / 2 - 10)
	----值	
	local _label = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",self._cityAllVIM)
	self._rightBg:addChild(_label)
	_label:setAnchorPoint(0,0.5)
	_label:setScale(0.8)
	_label:setPosition(_labelIcon:getPositionX() + _labelIcon:getContentSize().width / 2 + 3, _labelIcon:getPositionY()-2)
	self._totalPowerLabel = _label
	---总英雄数量值 
	_label = cc.Label:createWithBMFont("res/fonts/baisezi.fnt",self._cityAllPerson)
	self._rightBg:addChild(_label)
	_label:setAnchorPoint(1,0.5)
	_label:setPosition(self._rightBg:getContentSize().width - 10,self._rightBg:getContentSize().height - _label:getContentSize().height / 2 - 14)
	self._totalHeroLabel = _label
	----总英雄数量标签 
	-- _labelIcon = cc.Sprite:create("res/image/camp/map/camp_label2.png")
	_labelIcon = XTHDLabel:create("总英雄数量：",24,"res/fonts/def.ttf")
	_labelIcon:setColor(cc.c3b(255,255,255))
	_labelIcon:enableOutline(cc.c4b(84,3,3,255),1)
	self._rightBg:addChild(_labelIcon)
	_labelIcon:setAnchorPoint(1,0.5)
	_labelIcon:setPosition(_label:getPositionX() - _label:getContentSize().width - 3,self._rightBg:getContentSize().height - _labelIcon:getContentSize().height / 2 - 10)

	self:initListView(self._rightBg,cc.size(self._rightBg:getContentSize().width - 8,self._rightBg:getContentSize().height - _labelIcon:getContentSize().height - 15))
	-----页数
	local _darkBg = cc.Sprite:create("res/image/common/scale9_bg1_24.png")
	self._rightBg:addChild(_darkBg)
	_darkBg:setPosition(self._rightBg:getContentSize().width / 2,-55)	
	local str = string.format("%d/%d",self._currentPageIndex,ZhongZuDatas._serverSelfCityDatas.totalPage)
	local _pageNumber = XTHDLabel:create(str,20,"res/fonts/def.ttf")
	_pageNumber:setColor(cc.c3b(255,255,255))
	_darkBg:addChild(_pageNumber)
	_pageNumber:setPosition(_darkBg:getContentSize().width / 2,_darkBg:getContentSize().height / 2)
	self._pageNumber = _pageNumber
	------翻页前
	local _preBtn = XTHD.createPushButtonWithSound({
		normalFile = "res/image/guild/btnText_previousPage.png",
		selectedFile = "res/image/guild/btnText_previousPage.png",
		-- label = cc.Sprite:create("res/image/guild/guildText_previousPage.png"),
	},3)
	self._rightBg:addChild(_preBtn)
	_preBtn:setAnchorPoint(1,0.5)
	_preBtn:setPosition(_darkBg:getPositionX() - _darkBg:getContentSize().width / 2 - 8,_darkBg:getPositionY())
	_preBtn:setTouchEndedCallback(function( )
		self:doTurnTeamPage(1)
	end)
	self._prePageBtn = _preBtn
	----下一页
	local _nextBtn = XTHD.createPushButtonWithSound({
		normalFile = "res/image/guild/btnText_nextPage.png",
		selectedFile = "res/image/guild/btnText_nextPage.png",
		-- label = cc.Sprite:create("res/image/guild/guildText_nextPage.png"),
		needSwallow = true,
	},3)
	self._rightBg:addChild(_nextBtn)
	_nextBtn:setAnchorPoint(0,0.5)
	_nextBtn:setPosition(_darkBg:getPositionX() + _darkBg:getContentSize().width / 2 + 8,_darkBg:getPositionY())
	_nextBtn:setTouchEndedCallback(function( )
		self:doTurnTeamPage(2)
	end)
	self._nextPageBtn = _nextBtn		
	---城市建筑图标 
	local buildIcon = cc.Sprite:create("res/image/camp/map/camp_buildSmall"..self.__cityID..".png")
	self._leftBg:addChild(buildIcon)
	buildIcon:setPosition(self._leftBg:getContentSize().width / 2,self._leftBg:getContentSize().height - buildIcon:getContentSize().height / 2 + 10)
	----城市名字
	local nameIcon = cc.Sprite:create("res/image/camp/map/camp_cityName_yellow"..self.__cityID..".png")
	buildIcon:addChild(nameIcon)
	nameIcon:setAnchorPoint(0,0.5)
	----等级 
	local _level = XTHDLabel:create("LV:"..ZhongZuDatas._serverSelfCityDatas.cityLevel,24,"res/fonts/def.ttf")
	_level:setColor(cc.c3b(255,255,255))
	_level:enableShadow(cc.c4b(255,255,255,0xff),cc.size(1,0))
	_level:enableOutline(cc.c4b(84,3,3,255),1)
	_level:setAnchorPoint(0,0.5)
	buildIcon:addChild(_level)

	local x = nameIcon:getContentSize().width + _level:getContentSize().width
	x = (buildIcon:getContentSize().width - x) / 2
	nameIcon:setPosition(x,nameIcon:getContentSize().height)
	_level:setPosition(nameIcon:getPositionX() + nameIcon:getContentSize().width,nameIcon:getPositionY()-2)
	-----城主 
	-- local _castellenLabel = cc.Sprite:create("res/image/camp/camp_label17.png")
	local _castellenLabel = XTHDLabel:create("城主:",24,"res/fonts/def.ttf")
	_castellenLabel:setColor(cc.c3b(255,255,255))
	_castellenLabel:enableOutline(cc.c4b(84,3,3,255),1)
	self._leftBg:addChild(_castellenLabel)
	_castellenLabel:setAnchorPoint(0,0.5)
	-----城主名字
	str = string.format("%s lv:%d",ZhongZuDatas._serverSelfCityDatas.heroName,ZhongZuDatas._serverSelfCityDatas.heroLevel)
	local _castellenName = XTHDLabel:create(str,20,"res/fonts/def.ttf")
	_castellenName:enableOutline(cc.c4b(0,0,0,255),1)
	_castellenName:setColor(cc.c3b(205,101,8))
	self._leftBg:addChild(_castellenName)
	_castellenName:setAnchorPoint(0,0.5)

	x = _castellenLabel:getContentSize().width + _castellenName:getContentSize().width + 3
	x = (self._leftBg:getContentSize().width - x) / 2
	_castellenLabel:setPosition(x,buildIcon:getPositionY() - buildIcon:getContentSize().height / 2 - 20)
	_castellenName:setPosition(_castellenLabel:getPositionX() + _castellenLabel:getContentSize().width + 3,_castellenLabel:getPositionY())
	-----升级城主效果
	local _bg = ccui.Scale9Sprite:create("res/image/camp/map/common_scale_titlebg.png")
	-- _bg:setContentSize(cc.size(265,34))
	self._leftBg:addChild(_bg)
	_bg:setAnchorPoint(0.5,1)
	_bg:setPosition(self._leftBg:getContentSize().width / 2,_castellenLabel:getPositionY() - _castellenLabel:getContentSize().height + 10)
	----升级城主效果
	-- local _label = XTHDLabel:create(LANGUAGE_CAMP_TIPSWORDS40,24,"res/fonts/round_body.ttf")
	local _label = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS40,XTHD.SystemFont,18)
	-- _label:enableOutline(cc.c4b(0,0,0,255),1)
	_label:setColor(cc.c3b(206,110,240))
	_bg:addChild(_label)
	_label:setPosition(_bg:getContentSize().width / 2,_bg:getContentSize().height / 2)
	----------属性
	local _prorpData = ZhongZuDatas:getCityPropByLevel(self._cityLevel,self.__cityID)
	local x,y = self._leftBg:getContentSize().width * 2/3,_bg:getPositionY() - _bg:getContentSize().height - 10
	for k,v in pairs(_prorpData) do 
		------属性名
		local _name = XTHDLabel:create(LANGUAGE_CAMP_BUILDPROPERTY[v.propID]..":",18,"res/fonts/def.ttf")
		_name:setColor(XTHD.resource.color.gray_desc)
		_name:setAnchorPoint(0,1)
		self._leftBg:addChild(_name)
		_name:setPosition(90,y)
		-----原来的值
		local _val = v.propCur 
		if v.propID ~= 6 and v.propID ~= 7 then 
			_val = _val.."%"
		end 
		local _preVal = XTHDLabel:create(_val,18,"res/fonts/def.ttf")
		_preVal:setColor(XTHD.resource.color.gray_desc)
		_preVal:setAnchorPoint(0,0.5)
		self._leftBg:addChild(_preVal)
		_preVal:setPosition(_name:getPositionX() + _name:getContentSize().width + 2,_name:getPositionY() - _name:getContentSize().height / 2)

		y = y  - _name:getContentSize().height - 5		
	end 
	---线
	local _line = cc.Sprite:create("res/image/common/exchange_line.png")
	self._leftBg:addChild(_line)
	_line:setScale(0.5)	
	_line:setPosition(self._leftBg:getContentSize().width / 2,y - 30)
	---总队伍数量
	-- _labelIcon = cc.Sprite:create("res/image/camp/map/camp_label3.png")
	_labelIcon = XTHDLabel:create("总队伍数量：",20,"res/fonts/def.ttf")
	_labelIcon:enableOutline(cc.c4b(84,3,3,255),1)
	_labelIcon:setColor(cc.c3b(255,255,255))
	self._leftBg:addChild(_labelIcon)
	_labelIcon:setAnchorPoint(0.5,1)
	_labelIcon:setPosition(self._leftBg:getContentSize().width / 2 - 22,_line:getPositionY() - 15)
	---值 
	if self._cityData and self._cityData.limit > 0 then 
		_label = cc.Label:createWithBMFont("res/fonts/baisezi.fnt",self._cityAllTeam.."/"..self._cityData.limit)
	else 
		_label = cc.Label:createWithBMFont("res/fonts/baisezi.fnt",self._cityAllTeam)
	end 
	_label:setAdditionalKerning(-2)
	self._leftBg:addChild(_label)	
	_label:setAnchorPoint(0.5,1)
	_label:setPosition(self._leftBg:getContentSize().width / 2 + 65, _line:getPositionY() - 15)	
	self._totalTeamLabel = _label
end

function ZhongZuCityInfoLayer:initListView(targ,viewSize)
    local cellSize = cc.size(viewSize.width,90)
    
    local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height+5
    end

    local function numberOfCellsInTableView(table)
        return #self._teamDatas
    end

    local function tableCellTouched(table,cell)
        
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(cc.size(cellSize.width,cellSize.height+5))
        else 
            cell:removeAllChildren()
        end
        local node = self:createTeamCell(idx + 1,cellSize) 
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        return cell
    end

    local tableView = CCTableView:create(viewSize)
    tableView:setPosition(4,3)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    targ:addChild(tableView)
    self._teamList = tableView
end

function ZhongZuCityInfoLayer:createTeamCell(index,cellsize)
	local data = self._teamDatas[index]
	local node = cc.Node:create()
	node:setContentSize(cc.size(cellsize.width,cellsize.height - 3))
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
	bg:setContentSize(cc.size(cellsize.width,cellsize.height))	
	node:addChild(bg)
	bg:setPosition(node:getContentSize().width / 2,node:getContentSize().height - bg:getContentSize().height / 2)
	if data then 
		----头像
		local portrait = ZhongZuDatas:createCampHeroIcon( data.templateId,data.level)
		bg:addChild(portrait)
		portrait:setScale(0.75)
		portrait:setAnchorPoint(0,0.5)
		portrait:setPosition(15,bg:getContentSize().height / 2)
		----名字
		local name = XTHDLabel:createWithSystemFont(data.name,XTHD.SystemFont,18)
		if tonumber(data.charId) == gameUser.getUserId() then ----自己
			name:setColor(cc.c3b(205,101,8))
		else 
			name:setColor(XTHD.resource.color.gray_desc)
		end 
		bg:addChild(name)
		name:setAnchorPoint(0,0.5)
		name:setPosition(portrait:getPositionX() + portrait:getBoundingBox().width + 10,bg:getContentSize().height - name:getContentSize().height)
		----派出队伍
		local _lable = XTHDLabel:createWithParams({
			text = LANGUAGE_CAMP_SENDARMY,-----"派出队伍:",
			fontSize = 16,
			color = XTHD.resource.color.gray_desc,
		})
		bg:addChild(_lable)
		_lable:setAnchorPoint(0,0.5)
		_lable:setPosition(name:getPositionX(),name:getContentSize().height)
		----值 
		local _value = XTHDLabel:createWithParams({
			text = #data.team,
			fontSize = 16,
			color = XTHD.resource.color.gray_desc,
		})
		bg:addChild(_value)
		_value:setAnchorPoint(0,0.5)
		_value:setPosition(_lable:getPositionX() + _lable:getContentSize().width,_lable:getPositionY())
		---总战斗力
		local _power = XTHDLabel:createWithParams({
			text = LANGUAGE_CAMP_TOTALFIGHTVIM,------"总战斗力:",
			fontSize = 16,
			color = XTHD.resource.color.gray_desc,
		})
		bg:addChild(_power)
		_power:setAnchorPoint(0,0.5)
		_power:setPosition(_lable:getPositionX() + _lable:getContentSize().width + 15,_lable:getPositionY())
		----值 
		local _vim = 0
		for k,v in pairs(data.team) do 
			_vim = _vim + tonumber(v[1].power)
		end 
		_value = XTHDLabel:createWithParams({
			text = _vim,
			fontSize = 20,
			color = XTHD.resource.color.gray_desc,
		})
		bg:addChild(_value)
		_value:setAnchorPoint(0,0.5)
		_value:setPosition(_power:getPositionX() + _power:getContentSize().width,_power:getPositionY())
		-----挑战按钮
		local x = bg:getContentSize().width - 20
		if tonumber(data.charId) ~= gameUser.getUserId() then ----自己
			local _challengeBtn = XTHD.createCommonButton({
				btnColor = "write",
				text = LANGUAGE_VERBS.challenge,
				isScrollView = true,
				fontSize = 26,
				fontColor = cc.c3b(255,255,255),
			})
			_challengeBtn:setScale(0.7)
			bg:addChild(_challengeBtn)
			_challengeBtn:setAnchorPoint(1,0.5)
			_challengeBtn:setPosition(bg:getContentSize().width - 20,bg:getContentSize().height / 2)
			_challengeBtn:setTouchEndedCallback(function( )
				self:doLookTeams(bg:getTag(),2)
			end)
			x = x - _challengeBtn:getContentSize().width+50
		end 
		-----查看按钮
		local _lookBtn = XTHD.createCommonButton({
				btnColor = "write_1",
				text = LANGUAGE_VERBS.lookUp,
				isScrollView = true,
				fontSize = 26,
				fontColor = cc.c3b(255,255,255),
		})
		_lookBtn:setScale(0.7)
		bg:addChild(_lookBtn)
		_lookBtn:setAnchorPoint(1,0.5)
		_lookBtn:setPosition(x - 20 ,bg:getContentSize().height / 2)
		_lookBtn:setTouchEndedCallback(function( )
			self:doLookTeams(bg:getTag(),1)
		end)
		bg:setTag(index)
		-- if index < #self._teamDatas then 
		-- 	-------分隔线
		-- 	local _line = cc.Sprite:create("res/image/common/line_1.png")
		-- 	node:addChild(_line)
		-- 	_line:setScaleX(node:getContentSize().width / _line:getContentSize().width)
		-- 	_line:setPosition(node:getContentSize().width / 2,0)
		-- end 
	end 
	return node
end

function ZhongZuCityInfoLayer:doLookTeams(index,_type)
	print("doLookTeams:"..index)
	if _type == 2 then -------挑战
		if index >= 2 + self._selfTeamAmount and self._currentPageIndex == 1 then
			XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS54)
			return
		elseif self._currentPageIndex > 1 then
			XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS55)
			return
		end
		if #ZhongZuDatas._serverSelfDefendTeam.teams < 1 then -----还没有设置防守队伍 
			XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS50)-----"请先设置防守队伍后，再来挑战"
			return 
		elseif self._selfTeamAmount >= ZhongZuDatas._selfTeamsAmount then -----
			XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS51)-----没有可以替换对方的队伍配置，无法挑战"
			return 
		end 
	end 
	local modul = requires("src/fsgl/layer/ZhongZu/ZhongZuCityTeamLayer.lua")
	local data = self._teamDatas[index]
	local layer = modul:create(self,data,_type,self.__cityID)
	if layer then 
		self:addChild(layer)
		layer:show()
	end 
end
-----整合队伍数据，如果一个玩家有多个防守队伍，则把它归并到一个table里
function ZhongZuCityInfoLayer:formatTeamDatas( )
	local data = {}	
	local _selfTeam = {
		charId = nil,
		name = nil,
		templateId = nil,
		level = nil,
		team = {},
	}

	local i = 1
	local _hasSelf = false
	for k,v in pairs(ZhongZuDatas._serverSelfCityDatas.teams) do 
		if tonumber(v.charId) == gameUser.getUserId() then --自己的
			_selfTeam.charId = v.charId
			_selfTeam.name = v.name
			_selfTeam.templateId = v.templateId
			_selfTeam.level = v.level
			_selfTeam.vim = 0
			local _l = #_selfTeam.team
			_selfTeam.team[_l + 1] = v.team
			_hasSelf = true
		else 
			local continue = true
			for j = 1,#data do 
				if tonumber(data[j].charId) == tonumber(v.charId) then 
					local len = #data[j].team
					data[j].team[len + 1] = v.team
					data[j].vim = v.team[1].power + data[j].vim
					continue = false
					break
				end 
			end 
			if continue then 
				data[i] = {
					charId = v.charId,
					name = v.name,
					templateId = v.templateId,
					level = v.level,
					vim = v.team[1].power,
					team = {v.team},
				}			
				i = i + 1
			end
		end  
	end 	

	for i=1,#data do
		local d = data[i]
		for k,v in pairs(d) do
			if type(v) ~= "table" then
				print("k.."..k.."v: "..v)
			end
		end
	end

	table.sort(data,function(a,b)
		return a.vim < b.vim
	end)

	if _hasSelf then 
		self._selfTeamAmount = #_selfTeam.team
		table.insert(data,1,_selfTeam)
	end 

	self._teamDatas = data
	self._cityAllVIM = ZhongZuDatas._serverSelfCityDatas.cityPower
	self._cityAllTeam = #ZhongZuDatas._serverSelfCityDatas.teams
	self._cityAllTeam = ZhongZuDatas._serverSelfCity.citys[self.__cityID].defendSum
	self._cityAllPerson = ZhongZuDatas._serverSelfCityDatas.petCount
end
--------翻页处理函数 1 向前翻，2 向后翻
function ZhongZuCityInfoLayer:doTurnTeamPage( what )
	local _orig = self._currentPageIndex
	if what == 1 then ----前一页
		self._currentPageIndex = self._currentPageIndex - 1
	elseif what == 2 then -----下一页
		self._currentPageIndex = self._currentPageIndex + 1
	end 
	if self._currentPageIndex < 1 or self._currentPageIndex > ZhongZuDatas._serverSelfCityDatas.totalPage then 
		self._currentPageIndex = _orig
	else 
	    ZhongZuDatas.requestServerData({
			target = parent,
	        method = "campSelfCity?",
	        params = {cityId = self.__cityID,page = self._currentPageIndex},
	        success = function( )
	        	self:refreshUIAfterTurnPage()
	        end
	    })
	end 
end
-----在翻页之后刷新UI
function ZhongZuCityInfoLayer:refreshUIAfterTurnPage( )
	self:formatTeamDatas()
	if self._teamList then  ------队伍列表
		self._teamList:reloadData()
	end 
	if self._pageNumber then  -----刷新当前页数 
		local str = string.format("%d/%d",self._currentPageIndex,ZhongZuDatas._serverSelfCityDatas.totalPage)
		self._pageNumber:setString(str)
	end 
	if self._totalPowerLabel then -----城市总战力
		self._totalPowerLabel:setString(self._cityAllVIM)
	end 
	if self._totalHeroLabel then  -----城市总人数
		self._totalHeroLabel:setString(self._cityAllPerson)
	end 
end

return ZhongZuCityInfoLayer