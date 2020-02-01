--[[
---选定的特定副本里已有的队伍列表 
┏━━━┛┻━━━┛┻━━┓
┃｜｜｜｜｜｜｜┃
┃　　　━　　　 ┃
┃　┳┛ 　┗┳  　┃
┃　　　　　　　┃
┃　　　┻　　 　┃
┃　　　　　　　┃
┗━━┓　　　┏━┛
　　┃　史　┃　　
　　┃　诗　┃　　
　　┃　之　┃　　
　　┃　宠　┃
　　┃　　　┗━━━┓
　　┃         ┣┓
　　┃　　　  　┃
　　┗┓┓ ┏━┳┓ ┏┛
　　　┃┫┫　┃┫┫
　　　┗┻┛　┗┻┛
神兽镇楼，代码永无bug
]]

local DuoRenFuBenTEListLayer = class("DuoRenFuBenTEListLayer",function( )
	return XTHD.createBasePageLayer()
end)

function DuoRenFuBenTEListLayer:ctor(params)
	self._usefulBg = nil
	self._teamList = nil
	self._parent = params.parent ---
	self._copyID = params.index ----当前的副本类型id
	self._copyData = params.data ----当前副本的数据 
	self._splitPos = {} -------单元格分隔线的位置
	self._serverListData = {} ------队伍列表 
	self._pageNumber = nil -----分页数

	if DuoRenFuBenDatas.teamListData then 
		self._serverListData = DuoRenFuBenDatas.teamListData.list
	end 
	self:registerNotification()
end

function DuoRenFuBenTEListLayer:create(params)
	local layer = DuoRenFuBenTEListLayer.new(params)
	if layer then 
		layer:init()
	end 
	return layer
end

function DuoRenFuBenTEListLayer:onCleanup( )
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_MULTICOPY_TEAMS) 	
    XTHD.removeEventListener(CUSTOM_EVENT.GO_MULTICOPY_PREPARE_FROMTEAMLIST)-----在成功加入了队伍之后去准备页面
end

function DuoRenFuBenTEListLayer:init( )
	------背景
	local bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
	self:addChild(bg)
	self._bg = bg
	bg:setPosition(self:getContentSize().width / 2,(self:getContentSize().height - self.topBarHeight) / 2)

	local title = "res/image/public/duiwu_title.png"
	XTHD.createNodeDecoration(self._bg,title)
	
	-------第二层背景
	local secondBg = ccui.Scale9Sprite:create()
	secondBg:setContentSize(cc.size(self._bg:getContentSize().width - 8,bg:getContentSize().height - 38))
	self._bg:addChild(secondBg)
	secondBg:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
	self._usefulBg = secondBg
	self:initUI(secondBg)
end

function DuoRenFuBenTEListLayer:initUI(secondBg)
	if not secondBg then 
		return 
	end 
	secondBg:removeAllChildren()
	-----------底部按钮们
	local _line = cc.Sprite:create("res/image/common/line_1.png")
	secondBg:addChild(_line)
	_line:setScaleX((secondBg:getContentSize().width - 5)/ _line:getContentSize().width)
	_line:setPosition(secondBg:getContentSize().width / 2,60)
	-----翻页按钮们
	-- local _prePageBtn = XTHD.createPushButtonWithSound({
	-- 	normalFile = "res/image/common/btn/btn_gray_small_normal.png",
	-- 	selectedFile = "res/image/common/btn/btn_gray_small_selected.png",
	-- 	label = cc.Sprite:create("res/image/guild/guildText_previousPage.png"),
	-- },3)
	-- _prePageBtn:setTouchEndedCallback(function( )
	-- 	self:doTurnPage(1)
	-- end)
	-- local _nextPageBtn = XTHD.createPushButtonWithSound({
	-- 	normalFile = "res/image/common/btn/btn_gray_small_normal.png",
	-- 	selectedFile = "res/image/common/btn/btn_gray_small_selected.png",
	-- 	label = cc.Sprite:create("res/image/guild/guildText_nextPage.png"),		
	-- },3)
	-- _nextPageBtn:setTouchEndedCallback(function( )
	-- 	self:doTurnPage(2)
	-- end)
	-- -----页数
	-- local _darkBg = cc.Sprite:create("res/image/common/shadow_bg.png")
	-- secondBg:addChild(_darkBg)
	-- _darkBg:setPosition(secondBg:getContentSize().width / 2,30)	

	-- local _pageNumber = XTHDLabel:createWithSystemFont("1/1",XTHD.SystemFont,20)
	-- _pageNumber:setColor(XTHD.resource.color.gray_desc)
	-- _darkBg:addChild(_pageNumber)
	-- _pageNumber:setPosition(_darkBg:getContentSize().width / 2,_darkBg:getContentSize().height / 2)
	-- self._pageNumber = _pageNumber

	-- secondBg:addChild(_prePageBtn)
	-- _prePageBtn:setAnchorPoint(1,0.5)
	-- _prePageBtn:setPosition(_darkBg:getPositionX() - _darkBg:getContentSize().width / 2 - 10,_darkBg:getPositionY())
	-- secondBg:addChild(_nextPageBtn)
	-- _nextPageBtn:setAnchorPoint(0,0.5)
	-- _nextPageBtn:setPosition(_darkBg:getPositionX() + _darkBg:getContentSize().width / 2 + 10,_darkBg:getPositionY())
	------创建队伍、快速加入
	--ly3.26
	local _createBtn = XTHD.createCommonButton({
		btnColor = "write",
		isScrollView = false,
		text = LANGUAGE_KEY_CREATETEAM,
	})
	_createBtn:setScale(0.8)
	_createBtn:setTouchEndedCallback(function( )
		self:doCreateNewTeam()
	end)
	local _joinBtn = XTHD.createCommonButton({
		isScrollView = false,
		text = LANGUAGE_KEY_JOINFAST,
	})
	_joinBtn:setScale(0.8)
	_joinBtn:setTouchEndedCallback(function( )
		self:doFastJoin()
	end)
	secondBg:addChild(_createBtn)
	_createBtn:setAnchorPoint(1,0.5)
	secondBg:addChild(_joinBtn)
	_joinBtn:setAnchorPoint(1,0.5)
	_joinBtn:setPosition(secondBg:getContentSize().width - 10,30)
	_createBtn:setPosition(_joinBtn:getPositionX() - _joinBtn:getContentSize().width - 10,_joinBtn:getPositionY())
	---------
	if #self._serverListData > 0 then 
		--表头背景
		local bt_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_25.png")
		bt_bg:setContentSize(cc.size(secondBg:getContentSize().width - 10,40))
		bt_bg:setPosition(secondBg:getContentSize().width/2,secondBg:getContentSize().height-5)
		bt_bg:setAnchorPoint(0.5,1)
		secondBg:addChild(bt_bg)
		------表格标题
		local _title1 = XTHDLabel:create(LANGUAGE_TIPS_WORDS263,18,"res/fonts/def.ttf") -----挑战副本
		_title1:setColor(cc.c3b(55,54,112))
		secondBg:addChild(_title1)
		_title1:setPosition(secondBg:getContentSize().width * 1/6 - 60,secondBg:getContentSize().height - _title1:getContentSize().height / 2 - 15)
		_line = cc.Sprite:create("res/image/common/line_1.png")
		-- secondBg:addChild(_line)
		_line:setScaleX(33 / _line:getContentSize().width)
		_line:setRotation(90)
		_line:setPosition(_title1:getPositionX() * 2,_title1:getPositionY() + 2)
		self._splitPos[1] = {_line:getPosition()}
		------
		local _title2 = XTHDLabel:create(LANGUAGE_TIPS_WORDS264,18,"res/fonts/def.ttf") ----挑战成员
		_title2:setColor(cc.c3b(55,54,112))
		secondBg:addChild(_title2)
		_title2:setPosition(secondBg:getContentSize().width / 2,_title1:getPositionY())
		_line = cc.Sprite:create("res/image/common/line_1.png")
		-- secondBg:addChild(_line)
		_line:setScaleX(33 / _line:getContentSize().width)
		_line:setRotation(90)
		_line:setPosition(_title2:getPositionX() + _title2:getContentSize().width + 200,_title2:getPositionY() + 2)
		self._splitPos[2] = {_line:getPosition()}
		------
		local _title3 = XTHDLabel:create(LANGUAGE_TIPS_WORDS265,18,"res/fonts/def.ttf") ------操作
		_title3:setColor(cc.c3b(55,54,112))
		secondBg:addChild(_title3)
		_title3:setPosition(secondBg:getContentSize().width * 5/6 + 60,_title1:getPositionY())
		------线/底
		_line = cc.Sprite:create("res/image/common/line_1.png")
		-- secondBg:addChild(_line)
		_line:setScaleX((secondBg:getContentSize().width - 5)/ _line:getContentSize().width)
		_line:setPosition(_title2:getPositionX(),_title2:getPositionY() - _title2:getContentSize().height / 2 - 5)
		------
		local viewSize = cc.size(secondBg:getContentSize().width,secondBg:getContentSize().height - _title1:getContentSize().height - 85)
		local pos = cc.p(0,60)
		self:initTeamList(viewSize,pos)
	else
		local _tips = XTHDLabel:create(LANGUAGE_MULTICOPY_TIPS1,25,"res/fonts/def.ttf") ----挑战成员
		_tips:setColor(cc.c3b(55,54,112))
		secondBg:addChild(_tips)
		_tips:setPosition(secondBg:getContentSize().width / 2,secondBg:getContentSize().height / 2)
		if self._pageNumber then 
			self._pageNumber:setString("0/0")
		end 
	end 
end

function DuoRenFuBenTEListLayer:initTeamList(size,pos)
    local function cellSizeForTable(table,idx)
        return size.width,100
    end

    local function numberOfCellsInTableView(table)
    	return #self._serverListData
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
        end
        local node = self:createTeamCell(idx + 1)
        cell:addChild(node)
        return cell
    end

    self._teamList = CCTableView:create(size)
    self._teamList:setPosition(pos)
    self._teamList:setBounceable(true)
    self._teamList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._teamList:setDelegate()
    self._teamList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._usefulBg:addChild(self._teamList)

    self._teamList:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._teamList:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._teamList:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._teamList:reloadData()
end

function DuoRenFuBenTEListLayer:doTurnPage(index)	
end

function DuoRenFuBenTEListLayer:doCreateNewTeam( )
	local layer = requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenCRETeamLayer.lua"):create(self._copyID,self._parent,self._copyData)
    LayerManager.addLayout(layer)
end

function DuoRenFuBenTEListLayer:doFastJoin( )
	if #self._serverListData < 1 then 
		XTHDTOAST(LANGUAGE_MULTICOPY_TIPS2)
	else
		local object = SocketSend:getInstance()
		if object then 
			object:writeChar(self._copyID)
			object:send(MsgCenter.MsgType.CLIENT_REQUEST_FASTJOINTEAM)
		end 
	end 
end
------加入某个指定的队伍
function DuoRenFuBenTEListLayer:doJoinTeam( sender )
	DuoRenFuBenDatas:joinATeam({
		configID = sender.configID,
		teamID = sender.groupID
	})
end

function DuoRenFuBenTEListLayer:createTeamCell(index)
	local _serverData = self._serverListData[index]
	local _localData = gameData.getDataFromCSV("TeamCopyList",{id = _serverData.configId})
	local _container = ccui.Layout:create()
	_container:setContentSize(self._usefulBg:getContentSize().width,100)
	if _serverData and _localData then 
		local _bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
		_bg:setContentSize(cc.size(self._usefulBg:getContentSize().width - 10,92))
		_container:addChild(_bg)
		_bg:setPosition(_container:getContentSize().width / 2,_container:getContentSize().height / 2)
		-------副本名字
		local _name = XTHDLabel:create(_localData.name,20,"res/fonts/def.ttf")
		_bg:addChild(_name)
		_name:setColor(cc.c3b(55,54,112))
		_name:setPosition((self._splitPos[1][1]) / 2+15,_bg:getContentSize().height / 2)
		----分隔线
		local _line = cc.Sprite:create("res/image/common/line_1.png")
		-- _bg:addChild(_line)
		_line:setScaleX(_bg:getContentSize().height / _line:getContentSize().width)
		_line:setRotation(90)
		_line:setPosition(self._splitPos[1][1] - 5,_bg:getContentSize().height / 2)
		-----头像
		local _width = self._splitPos[2][1] - self._splitPos[1][1]
		local x = (_width - 64*5 - 50) / 2 + self._splitPos[1][1]
		for i = 1,5 do 
			local _head = cc.Sprite:create("res/image/common/no_hero.png")
			_head:setScale(0.8)
			local w,h = _head:getBoundingBox().width,_head:getBoundingBox().height
			local targ = _serverData.members[i]
			if targ then 
				_head = HeroNode:createWithParams({
					heroid = targ.petId,
					star = targ.star,
					level = targ.level,
					advance = targ.phaseLevel,
				})
				_head:setScaleX(w / _head:getContentSize().width)
				_head:setScaleY(h / _head:getContentSize().height)
			end 
			_bg:addChild(_head)
			_head:setAnchorPoint(cc.p(0,0.5))
			_head:setPosition(x,_bg:getContentSize().height / 2)
			x = x + _head:getBoundingBox().width + 15
		end 
		----
		_line = cc.Sprite:createWithTexture(_line:getTexture())
		-- _bg:addChild(_line)
		_line:setScaleX(_bg:getContentSize().height / _line:getContentSize().width)
		_line:setRotation(90)
		_line:setPosition(self._splitPos[2][1] - 5,_bg:getContentSize().height / 2)
		-------加入按钮
		--ly3.26
		local normal = ccui.Scale9Sprite:create("res/image/common/btn/btn_gray_up.png")
		normal:setContentSize(cc.size(139,46))
		local selected = ccui.Scale9Sprite:create("res/image/common/btn/btn_gray_down.png")
		selected:setContentSize(cc.size(139,46))
		-- local _addBtn = XTHD.createPushButtonWithSound({
		-- 	normalNode = normal,
		-- 	selectedNode = selected,
		-- 	text = LANGUAGE_KEY_JOINTEAM,
		-- 	fontSize = 20,
		-- 	fontColor = XTHD.resource.btntextcolor.gray,
		-- },3)
		local _addBtn = XTHD.createCommonButton({
			btnColor = "write_1",
			isScrollView = false,
			text = LANGUAGE_KEY_JOINTEAM,
			fontSize = 20,
		})
		_addBtn:setScale(0.7)
		_bg:addChild(_addBtn)
		_addBtn.groupID = _serverData.groupId
		_addBtn.costFlower = _localData.costFlower
		_addBtn.configID = _serverData.configId
		_addBtn:setTouchEndedCallback(function(  )
			self:doJoinTeam(_addBtn)
		end)
		_addBtn:setPosition((_bg:getContentSize().width - self._splitPos[2][1]) / 2 + self._splitPos[2][1],_addBtn:getContentSize().height / 2-5)
		-----消耗
		local _cost = XTHDLabel:create(LANGUAGE_VERBS.cost1.."：",18,"res/fonts/def.ttf")
		_cost:setAnchorPoint(0,0.5)
		_cost:setColor(cc.c3b(55,54,112))
		_bg:addChild(_cost)
		local _vim = cc.Sprite:create(IMAGE_KEY_HEADER_TILI)
		_vim:setAnchorPoint(0,0.5)	
		_vim:setScale(0.8)
		_bg:addChild(_vim)
		local _val = XTHDLabel:create(_localData.costFlower,18,"res/fonts/def.ttf")
		_bg:addChild(_val)
		_val:setColor(cc.c3b(255,255,255))
		_val:setAnchorPoint(0,0.5)
		local x = _cost:getContentSize().width + _vim:getBoundingBox().width + _val:getContentSize().width
		x = _addBtn:getPositionX() - x / 2
		_cost:setPosition(x,_bg:getContentSize().height - _cost:getContentSize().height / 2 - 10)
		_vim:setPosition(_cost:getPositionX() + _cost:getContentSize().width,_cost:getPositionY())
		_val:setPosition(_vim:getPositionX() + _vim:getContentSize().width,_vim:getPositionY())
		-----底线
		_line = cc.Sprite:createWithTexture(_line:getTexture())
		-- _container:addChild(_line)
		_line:setScaleX((_container:getContentSize().width)/ _line:getContentSize().width)
		_line:setPosition(_container:getContentSize().width / 2,0 - 0.5)
	end 
	return _container
end
------刷服务器的队伍
function DuoRenFuBenTEListLayer:refreshTeams( )
    XTHDHttp:requestAsyncInGameWithParams({
        modules = "moreEctypeGroupList?",
        params = {ectypeType = self._copyID},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                DuoRenFuBenDatas.tili = data.tili
                DuoRenFuBenDatas.teamListData = data
				if DuoRenFuBenDatas.teamListData then 
					self._serverListData = DuoRenFuBenDatas.teamListData.list
					if self._teamList then 
						self._teamList:reloadData()
					else 
						self:initUI(self._usefulBg)
					end 
				end 
            else
                XTHDTOAST(data.msg)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function DuoRenFuBenTEListLayer:registerNotification( )
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_MULTICOPY_TEAMS,callback = function( event )-----刷新当前副本里的队伍
    	self:refreshTeams()
    end})
    XTHD.addEventListener({name = CUSTOM_EVENT.GO_MULTICOPY_PREPARE_FROMTEAMLIST,callback = function( event )-----在成功加入了队伍之后去准备页面
    	-- dump(event.data)
    	local teams = event.data.preTeam
    	local id = event.data.id
	    local _layer = requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenPrepareLayer.lua"):create({
	    	id = -1,
	    	parent = self._parent,
	    	fristID = id,
	    	previouseTeam = teams,
	    })
	    LayerManager.addLayout(_layer)
	end})
end

return DuoRenFuBenTEListLayer
