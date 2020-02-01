-- FileName: HaoYouLayer.lua
-- Author: wangming
-- Date: 2015-09-11
-- Purpose: 好友类封装
--[[TODO List]]

local HaoYouLayer = class( "HaoYouLayer", function ()
    return XTHD.createBasePageLayer()
end)

function HaoYouLayer:create( node )
	local function createLayer( data )
		local lay = HaoYouLayer.new(data)
		lay:initUI()
        LayerManager.addLayout(lay)
	end
	HaoYouPublic.httpGetFriendData( node, createLayer)
end

function HaoYouLayer:ctor( _data )

	self._layTop = -40
	self._layMid = -10
	self._nowCharId = -1
	self._nowSelect = -1
end

function HaoYouLayer:initUI( )
	
	local _bg = cc.Sprite:create("res/image/common/friend_bg.png")
	_bg:setPosition(self:getContentSize().width/2, self:getContentSize().height/2 - self.topBarHeight/2)
	-- _bg:setScale(0.75)
    self._bg = _bg
	local title = "res/image/public/haoyou_title.png"
	XTHD.createNodeDecoration(self._bg,title)

	self._leftSize = cc.size(self._bg:getContentSize().width*(512/1024), 445)
	self:addChild(_bg) 
	self:initRight()
	self:initLeft()
	self:freshRight()

	XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_FRIEND_TALKLIST,
        callback = function (event)
        	if event.data and event.data.charId then
	        	local pID = tonumber(event.data.charId) or 0
        		if pID == self._nowCharId and self._talkTableView then
        			self._talkTableView:reloadData()
        		end
        	end
        end
    })

    XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_FRIEND_LIST,
        callback = function (event)
	        if not HaoYouPublic.isFriend(self._nowCharId) then
		        self._nowCharId = -1
		        self._nowSelect = -1
		        self:freshRight()
		    end
		    if self._friendTableView then

	        	if self._noFriend then
	        		self._noFriend:setVisible(false)
	        	end
		        if event.data and event.data.charTag then
		        	local pDatas = HaoYouPublic.getData()
		        	self._friendTableView:updateCellAtIndex(event.data.charTag - 1)
		        else
			        if self._nowCharId ~= -1 then
			        	local pDatas = HaoYouPublic.getData()
				        for i=1,#pDatas do
				        	if pDatas[i].charId == self._nowCharId then
				        		self._nowSelect = i -1
				        		break
				        	end
				        end
				    end
		        	self._friendTableView:reloadDataAndScrollToCurrentCell()
		        end
		    end
        end
    })
end

function HaoYouLayer:onEnter( )
	local topLay = self:getChildByName("TopBarLayer1")
	if topLay then
		topLay:refreshData()
	end
	
    self._nowCharId = -1
    self._nowSelect = -1
    self:freshRight()
    if self._friendTableView then
    	self._friendTableView:reloadDataAndScrollToCurrentCell()
    end
end

function HaoYouLayer:freshFList( event )
	if not HaoYouPublic.isFriend(self._nowCharId) then
        self._nowCharId = -1
        self._nowSelect = -1
        self:freshRight()
    end
    if self._friendTableView then
        if event.data.charTag then
        	self._friendTableView:updateCellAtIndex(event.data.charTag)
        else
	        if self._nowCharId ~= -1 then
	        	local pDatas = HaoYouPublic.getData()
		        for i=1,#pDatas do
		        	if pDatas[i].charId == self._nowCharId then
		        		self._nowSelect = i -1
		        		break
		        	end
		        end
		    end
        	self._friendTableView:reloadDataAndScrollToCurrentCell()
        end
    end
end


function HaoYouLayer:onCleanup( )
	HaoYouPublic.setMsgs(false)
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_FRIEND_TALKLIST)
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_FRIEND_LIST)
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TASKLIST})
end

function HaoYouLayer:initRight( )
	local winSize = cc.Director:getInstance():getWinSize()

	-------------left base	-------------
	local _leftSize = self._leftSize
	local _layTop = self._layTop
	local _layMid = self._layMid

	local _bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_25.png")
    _bg:setContentSize(_leftSize.width*0.95, _leftSize.height - 70)
	_bg:setAnchorPoint(0, 0.5)
	_bg:setOpacity(0)
    _bg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5 + _layTop + 30))

    self:addChild(_bg)
    self._leftBg = _bg

    --如果没有好友
    if tonumber(table.nums(HaoYouPublic.getFriendData().list)) <= 0 then
	    local noFriend = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS275, "Helvetica",25)
	    noFriend:setPosition(_bg:getContentSize().width/2, _bg:getContentSize().height/2 + 20)
	    noFriend:setColor(cc.c3b(52,25,25))
	    _bg:addChild(noFriend)
	    self._noFriend = noFriend
	end

    local _diBar = cc.Sprite:create()
    _diBar:setContentSize(self._bg:getContentSize().width *0.5, 60)
    _diBar:setAnchorPoint(0, 0.5)
	_diBar:setPosition(cc.p(self._bg:getContentSize().width/2,45))
    self._bg:addChild(_diBar, 2)

    local _touchSize = cc.size(_diBar:getContentSize().width*0.3, _diBar:getContentSize().height*0.8)
    local function createDiBtns( sCall, isLeft)
    	local _pN = isLeft and 0.1 or 0.85

	    local normalFile = "write_1"
	    if not isLeft then
	    	normalFile = "write"
	    end
	    local _btnAction = XTHD.createCommonButton({
			btnColor = normalFile,
			btnSize = cc.size(_touchSize.width - 50,46),
			isScrollView = false,
			needSwallow = true,
			enable = true,
			touchSize = _touchSize,
			endCallback = sCall,
			text = "",
			pos = cc.p(_diBar:getContentSize().width*_pN, 45),
		})
		_btnAction:setScale(0.8)
		_diBar:addChild(_btnAction)

		local _iconFile = isLeft and "res/image/friends/friend_exchange_new.png" or "res/image/friends/friendAdd_new.png"
		local _actionIcon = cc.Sprite:create(_iconFile)
		_btnAction:addChild(_actionIcon)

		local _ttfFile = isLeft and LANGUAGE_TIPS_WORDS272 or LANGUAGE_TIPS_FRIENDINFO_ADD
		local _ttfLab = _btnAction:getLabel()
		_ttfLab:setString(_ttfFile)

		_actionIcon:setPosition(cc.p(_btnAction:getContentSize().width/2-_ttfLab:getContentSize().width/2+5, _btnAction:getContentSize().height/2 + 5))
		_ttfLab:setFontSize(20)
		_ttfLab:setAnchorPoint(cc.p(0, 0.5))
		_ttfLab:setPosition(cc.p(_actionIcon:getPositionX()+_actionIcon:getContentSize().width/2, _btnAction:getContentSize().height/2))
	end

	createDiBtns(function()
		self:intracationFriend()
	end, true)
	createDiBtns(function()
		self:addFriend()
	end, false)	

	--顶部按钮



    local _upBar = cc.Sprite:create()
    _upBar:setContentSize(_bg:getContentSize().width - 10, 45)
    _upBar:setAnchorPoint(0, 0.5)
	_upBar:setPosition(cc.p(_bg:getPositionX(), _bg:getPositionY() + _bg:getContentSize().height*0.5 + 20))
    self:addChild(_upBar, 2)

	local function createUPBtn()
	    -- local shadow = cc.Sprite:create("res/image/common/shadow_bg.png")
		-- local shadow = ccui.Scale9Sprite:create(cc.rect(40,18,1,1), "res/image/common/shadow_bg.png")
		local shadow = ccui.Scale9Sprite:create("res/image/friends/input_bg.png")
	    shadow:setAnchorPoint(0,0.5)
	    shadow:setContentSize(cc.size(185,36))
	    shadow:setPosition(20, _upBar:getContentSize().height/2 - 13)
	    _upBar:addChild(shadow)

	    local flower = cc.Sprite:create(IMAGE_KEY_HEADER_FLOWER)
	    shadow:addChild(flower)
	    flower:setPosition(10,shadow:getContentSize().height/2)
	    flower:setScale(0.9)

	    local ownNum = getCommonWhiteBMFontLabel(HaoYouPublic.getFriendData().flowerCount)
	    shadow:addChild(ownNum)
	    ownNum:setAnchorPoint(0,0.5)
	    ownNum:setPosition(35, 10)

	    -- local testbg = ccui.Scale9Sprite:create(cc.rect(20,20,1,1), "res/image/common/scale9_bg_14.png")
	    -- testbg:setContentSize(cc.size(150,70))
	    -- testbg:setPosition(_upBar:getContentSize().width - 90,_upBar:getContentSize().height/2 + 15)
	    -- _upBar:addChild(testbg)

	    local flowerBtn = XTHDPushButton:createWithParams({
	    		touchSize = cc.size(150,70),
	    		normalFile = "res/image/friends/flowerShop.png",
	    		selectedFile = "res/image/friends/flowerShop_down.png",
				musicFile = XTHD.resource.music.effect_btn_common,

	    	})
	    flowerBtn:setPosition(self._bg:getContentSize().width - 90,self._bg:getContentSize().height-30)
	    self._bg:addChild(flowerBtn)
	    local normal = flowerBtn:getStateNormal()
	    local selected = flowerBtn:getStateSelected()
	    normal:setPositionY(normal:getPositionY() - 15)
	    selected:setPositionY(selected:getPositionY() - 15)


	    flowerBtn:setTouchBeganCallback(function()
    		flowerBtn:setScale(0.9)
    	end)
	    flowerBtn:setTouchEndedCallback(function()
	    	local isOpen = XTHD.getUnlockStatus(10,true)
	    	if isOpen then
            	local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("flower")
				cc.Director:getInstance():getRunningScene():addChild(layer)
				layer:show()
            end     
	    end)
	end

	createUPBtn()




	local _cellSize = cc.size(_leftSize.width*0.95, 120)
	local _tableSize = cc.size(_leftSize.width*0.95, _leftSize.height - 100)
	local function cellSizeForTable(table, idx)
		return _cellSize.width,_cellSize.height
    end
    local function numberOfCellsInTableView(table)
    	local pData = HaoYouPublic.getData()
        return #pData
    end
    local function tableCellTouched(table, cell)
    	self:freshRight(cell)
    end
	local function tableCellAtIndex(table, idx)
		local _cell = table:dequeueCell()
	    if _cell then
	        _cell:removeAllChildren()
	    else
	        _cell = cc.TableViewCell:new()
	    end
	    _cell._idx = idx
	    local pData = HaoYouPublic.getData()
		local data = pData[idx+1] or {}

		local _pic = "res/image/common/scale9_bg1_26.png"
	    local pCellSize = cc.size(_cellSize.width, _cellSize.height - 5)
	    local _di = ccui.Scale9Sprite:create(_pic)
	    _di:setContentSize(pCellSize)
	    _di:setAnchorPoint(0, 0)
	    _di:setPosition(_tableSize.width/2-_cellSize.width/2, 0)
	    _di:setName("cellDi")
	    _cell:addChild(_di, -1)

	    local mask = cc.LayerColor:create()

		if data.charId == self._nowCharId then
			mask:setColor(cc.c3b(234,200,134))
			mask:setContentSize(pCellSize)
			mask:setOpacity(100)
			mask:setAnchorPoint(0,0)
			mask:setPosition(_tableSize.width/2-_cellSize.width/2, 0)
			_cell:addChild(mask,0)
		elseif not data.onLine then
			mask:setColor(cc.c3b(177,177,177))
			mask:setContentSize(pCellSize)
			mask:setOpacity(100)
			mask:setAnchorPoint(0,0)
			mask:setPosition(_tableSize.width/2-_cellSize.width/2, 0)
			_cell:addChild(mask,0)
		end

		local node = cc.Node:create()
		node:setContentSize(pCellSize)
	    _cell:addChild(node)

	    self:freshFriendCellAtIndex(node, data)
	    
		return _cell
    end




 	local _tableView = CCTableView:create(_tableSize)
    TableViewPlug.init(_tableView)
    _tableView:setPosition(cc.p((_bg:getContentSize().width - _tableSize.width)*0.5, 17))
    _tableView:setBounceable(true)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    _tableView:setDelegate()
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
 
	_tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView.getCellNumbers=numberOfCellsInTableView
    _tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    _tableView.getCellSize=tableCellTouched
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData() 

	local testbg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_14.png")
    testbg:setContentSize(_tableSize)
    testbg:setAnchorPoint(cc.p(0,0))
    testbg:setPosition(_tableView:getPosition())
    -- _bg:addChild(testbg) 

    _bg:addChild(_tableView)
	self._friendTableView = _tableView  
end

function HaoYouLayer:initLeft( ... )
	local _leftSize = self._leftSize
	local _layTop = self._layTop
	local _layMid = self._layMid

    local _rightSize = cc.size(_leftSize.width - 20, _leftSize.height)
	local _bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_19.png")
    _bg:setContentSize(_rightSize.width + 10, _rightSize.height - 60)
	_bg:setAnchorPoint(cc.p(1, 0.5))
	_bg:setOpacity(0)
    _bg:setPosition(cc.p(winSize.width*0.5 -27, winSize.height*0.5 + _layTop + 30))

    self:addChild(_bg)
    self._rightBg = _bg


    -- local splitY = cc.Sprite:create("res/image/ranklistreward/splitY.png")
    -- splitY:setAnchorPoint(0.5,0.5)
    -- splitY:setPosition(self:getContentSize().width/2-60, self:getContentSize().height/2 + _layTop + 20)
    -- self:addChild(splitY)


    local _touchSize = cc.size(90, 46)
		
	local _btnAction = XTHD.createCommonButton({
		btnColor = "write_1",
		btnSize = _touchSize,
		isScrollView = false,
		needSwallow = true,
		enable = false,
		touchSize = _touchSize,
		endCallback = function ( ... )
			self:sendMsg()
		end,
		text = LANGUAGE_KEY_SEND,
	})
	_btnAction:setScale(0.6)
	_btnAction:setPosition(cc.p(60 ,60))
	self._btnAction = _btnAction
	self._bg:addChild(_btnAction, 2)

    local _y = - 40
    local _size = cc.size(self._bg:getContentSize().width*0.5-_btnAction:getContentSize().width - 25, 40)
	-- local input_bg_account = ccui.Scale9Sprite:create(cc.rect(6,6,1,1),"res/image/friends/input_bg.png")
	local input_bg_account = ccui.Scale9Sprite:create("res/image/friends/input_bg.png")
    input_bg_account:setAnchorPoint(0, 0.5)
    input_bg_account:setContentSize(_size)
    input_bg_account:setPosition(cc.p(_btnAction:getPositionX()+_btnAction:getContentSize().width/2 -20, _btnAction:getPositionY()))

    self._bg:addChild(input_bg_account, 2)

    local editbox_account = ccui.EditBox:create(cc.size(_size.width-15, _size.height-5), ccui.Scale9Sprite:create(), nil, nil)
    editbox_account:setFontColor(cc.c3b(52,25,25))
    editbox_account:setPlaceHolder(LANGUAGE_KEY_INPUT_WORDA)-------"请输入你的信息")
    editbox_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    editbox_account:setAnchorPoint(0,0.5)
    editbox_account:setMaxLength(30)
    editbox_account:setPosition(10 , input_bg_account:getContentSize().height*0.43)
    editbox_account:setPlaceholderFontColor(cc.c3b(52,25,25))
    editbox_account:setFontName("res/fonts/def.ttf")
    editbox_account:setPlaceholderFontName("res/fonts/def.ttf")
    editbox_account:setFontSize(22)
    editbox_account:setPlaceholderFontSize(22)
    editbox_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editbox_account:setText(_name);
    editbox_account:setVisible(false)
    input_bg_account:addChild(editbox_account)
    self._editbox = editbox_account

    local _scale = cc.p(0.6,0.8)


	local _titleBar = cc.Sprite:create("res/image/friends/LT.png")
	_titleBar:setPosition(cc.p(_bg:getContentSize().width*0.5, _bg:getContentSize().height + 15))
    _bg:addChild(_titleBar, 2)

    -- local _title = XTHDLabel:createWithParams({
    --     text = LANGUAGE_TIPS_WORDS273,------"好友列表",
    --     fontSize = 18,
    --     color = cc.c3b(70, 34, 34)
    -- })
    -- _title:setPosition(cc.p(_titleBar:getContentSize().width*0.5, _titleBar:getContentSize().height*0.5))
    -- _titleBar:addChild(_title)


    local sendFlower = cc.Sprite:create("res/image/friends/sendFlower1.png")
    sendFlower:setPosition(280, 270/2)
	self._bg:addChild(sendFlower,3)
	sendFlower:setScale(0.8)
	self._sendFlower = sendFlower
	local sendflower2 = cc.Sprite:create("res/image/friends/sendFlower2.png")
	sendflower2:setPosition(0,0)
	sendflower2:setScale(0.8)
	sendflower2:setAnchorPoint(0.5,0)
	sendFlower:addChild(sendflower2)
	--女性暴露
	-- sendflower2:setOpacity(0)
	local sendflower3 = cc.Sprite:create("res/image/friends/sendFlower3.png")
	sendflower3:setPosition(sendFlower:getContentSize().width/2,sendFlower:getContentSize().height/2+5)
	sendflower3:setAnchorPoint(1,0)
	sendFlower:addChild(sendflower3)
	local sendflower4 = cc.Sprite:create("res/image/friends/sendFlower4.png")
	sendflower4:setPosition(sendFlower:getContentSize().width/2,sendFlower:getContentSize().height/2+5)
	sendflower4:setAnchorPoint(0,0)
	sendFlower:addChild(sendflower4)
	local sendflower5 = cc.Sprite:create("res/image/friends/sendFlower5.png")
	sendflower5:setPosition(sendFlower:getContentSize().width/2+10,sendFlower:getContentSize().height/2-15)
	sendflower5:setAnchorPoint(0.5,0.5)
	sendFlower:addChild(sendflower5)


    local textLab = XTHDLabel:createWithSystemFont("请输入要发送的内容","Helvetica",22)
    textLab:setColor(cc.c3b(244,255,209))
    textLab:setPosition(input_bg_account:getContentSize().width/2, input_bg_account:getContentSize().height/2)
    input_bg_account:addChild(textLab)
    self._textLab = textLab

    

	local _cellSize = cc.size(_rightSize.width + 10, 80)
	local _tableSize = cc.size(_rightSize.width +10, _rightSize.height - 80)
	local function cellSizeForTable(table,idx)
		return _cellSize.width,_cellSize.height
    end
    local function numberOfCellsInTableView(table)
    	local _datas = HaoYouPublic.getTalkMsgByCharId(self._nowCharId)
        return #_datas
    end
    local function tableCellTouched(table,cell)
    end
	local function tableCellAtIndex(table,idx)
		local _cell = table:dequeueCell()
	    if _cell then
	        _cell:removeAllChildren()
	    else
	        _cell = cc.TableViewCell:new()
	    end
	    local pCellSize = cc.size(_cellSize.width, _cellSize.height - 5)
		local node = cc.Node:create()
		node:setContentSize(pCellSize)
	    _cell:addChild(node)

	    local _datas = HaoYouPublic.getTalkMsgByCharId(self._nowCharId)
	    local pData = _datas[idx+1]
	    self:freshTalkCellAtIndex(node, pData)
	    
		return _cell
    end

 	local _tableView = CCTableView:create(_tableSize)
    _tableView:setPosition(cc.p((_rightSize.width - _tableSize.width)*0.5+6, 25))
    _tableView:setBounceable(true)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    _tableView:setDelegate()
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
 
	_tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData()  

    _bg:addChild(_tableView)
	self._talkTableView = _tableView 
end

function HaoYouLayer:freshFriendCellAtIndex( sNode, data )
	local pCellSize = sNode:getContentSize()
	
	local function headTouchCall( ... )
		local _isFriend = HaoYouPublic.isFriend(data.charId)
		requires("src/fsgl/layer/HaoYou/HaoYouInfoPop.lua"):create(self, {data = data, isFriend = _isFriend})
	end
	local icon = HaoYouPublic.getFriendIcon(data, {callFn = headTouchCall, isCheckOnline = true})
	icon:setAnchorPoint(0,0.5)
	icon:setPosition(25, pCellSize.height*0.5)
	sNode:addChild(icon)

	local _talkNum = HaoYouPublic.getTalkNewsFlag(data.charId)

	if _talkNum > 0 then
		if self._nowCharId ~= data.charId then
			local pSize = icon:getBoundingBox()
			local _numberBox = cc.Sprite:create("res/image/friends/friendTipDi.png")
			if _numberBox then
				_numberBox:setPosition(cc.p(icon:getPositionX() + pSize.width, icon:getPositionY() + pSize.height*0.5))
				sNode:addChild(_numberBox)
				------数量
				local _numFNT = cc.Label:createWithBMFont("res/image/friends/littlewhiteword.fnt", _talkNum)
			    _numFNT:setPosition(cc.p(_numberBox:getContentSize().width*0.5, -1))
				_numberBox:addChild(_numFNT)
			end
		else
			HaoYouPublic.freshTalkNewsFlag(data.charId, false, true)
		end
	end

	local _color = XTHD.resource.color.brown_desc
	local _ttfX = 100
	local _nameTTF = XTHDLabel:create(data.charName, 22,"res/fonts/def.ttf")
	_nameTTF:setColor(cc.c3b(206,110,240))
	_nameTTF:enableOutline(cc.c4b(0,0,0,255),2)
    _nameTTF:setAnchorPoint(cc.p(0, 0.5))
    _nameTTF:setPosition(cc.p(_ttfX+10 , pCellSize.height*0.70))
	sNode:addChild(_nameTTF)

	local _flowerStr = tonumber(data.flower) or 0
    local _flowTTF = XTHDLabel:createWithParams({
    	text = LANGUAGE_VERBS.owned .. ":", ------"拥有鲜花".._flowerStr.."朵",
    	fontSize = 22,
    	color = _color,
    	anchor = cc.p(0,0.5),
		pos = cc.p(_ttfX+10 , pCellSize.height*0.30),
		ttf = "res/fonts/def.ttf"
    })
	sNode:addChild(_flowTTF)
	local flower = cc.Sprite:create(IMAGE_KEY_HEADER_FLOWER)
	flower:setPosition(_flowTTF:getPositionX()+_flowTTF:getContentSize().width + 20,_flowTTF:getPositionY())
	sNode:addChild(flower)
	flower:setScale(0.8)

	local flowerNum = XTHDLabel:createWithSystemFont(_flowerStr, "Helvetica",20)
	flowerNum:setColor(cc.c3b(53,25,26))
	flowerNum:setAnchorPoint(0,0.5)
	flowerNum:setPosition(flower:getPositionX()+flower:getContentSize().width - 15,_flowTTF:getPositionY())
	sNode:addChild(flowerNum)



	local _btnSend = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create("res/image/friends/send_down.png"),--send_down
		selectedNode = cc.Sprite:create("res/image/friends/send_up.png"),
		musicFile = XTHD.resource.music.effect_btn_common,
		needSwallow = false,
		enable = true,
		touchSize = cc.size(50,70),
		endCallback = function ( ... )
			requires("src/fsgl/layer/HaoYou/HaoYouSendPop.lua"):create(self, data)
		end
	})
	_btnSend:setScale(0.7)
	_btnSend:setPosition(pCellSize.width - 50 , pCellSize.height*0.5)
	sNode:addChild(_btnSend)

	local _btnLook = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create("res/image/common/btn/btn_explore_normal.png"),
		selectedNode = cc.Sprite:create("res/image/common/btn/btn_explore_selected.png"),
		musicFile = XTHD.resource.music.effect_btn_common,
		needSwallow = false,
		enable = true,
		touchSize = cc.size(50,70),
		endCallback = function ( ... )
			local _isFriend = HaoYouPublic.isFriend(data.charId)
			requires("src/fsgl/layer/HaoYou/HaoYouInfoPop.lua"):create(self, {data = data, isFriend = _isFriend})
		end
	})
	_btnLook:setPosition(pCellSize.width - 100 , pCellSize.height*0.5)
	sNode:addChild(_btnLook)
end

function HaoYouLayer:freshTalkCellAtIndex( sNode, sData )
	local pCellSize = sNode:getContentSize()
	--头像
	local pData = HaoYouPublic.getData()
	local data = sData or {}
	local pD = {templateId = data.iconID, level = data.senderLevel, campId = data.senderCampID}
	local icon = HaoYouPublic.getFriendIcon(pD)
	icon:setAnchorPoint(cc.p(0, 0.5))
	icon:setPosition(40, pCellSize.height*0.5)
	icon:setScale(0.7)
	sNode:addChild(icon)
	--背景条
	local _backSize = cc.size(pCellSize.width - 115, pCellSize.height)
	-- local background = ccui.Scale9Sprite:create(cc.rect(22,35,1,1),"res/image/chatroom/chat_msg_bg1.png")
	local background = ccui.Scale9Sprite:create("res/image/chatroom/chat_msg_bg1.png")
	background:setContentSize(_backSize)
	background:setAnchorPoint(cc.p(0.5, 0.5))
	background:setPosition(icon:getPositionX() + icon:getBoundingBox().width + 4 + _backSize.width*0.5, pCellSize.height*0.5)
	sNode:addChild(background)

	--信息承载node
	local _contentSize = cc.size(_backSize.width - 20, _backSize.height)
	local contentNode = cc.Node:create()
	contentNode:setContentSize(_contentSize)
	contentNode:setAnchorPoint(cc.p(0,0.5))
	contentNode:setPosition(icon:getPositionX() + icon:getBoundingBox().width + 4 + 20, pCellSize.height*0.5)
	sNode:addChild(contentNode)


	local _y1 = pCellSize.height*0.75
    -- 名字
    local nameTTF = XTHDLabel:createWithSystemFont(data.senderName, "Helvetica", 18)
    nameTTF:setColor(XTHD.resource.color.brown_desc)
    nameTTF:setAnchorPoint(cc.p(0, 0.5))
    nameTTF:setPosition(cc.p(10, _y1))
    contentNode:addChild(nameTTF)
	local time = HaoYouPublic.getTimeStr(data.msgTime)
    local timeLabel = XTHDLabel:createWithParams({
    	text = tostring(time),
    	fontSize = 16,
    	color = XTHD.resource.color.brown_desc,
    	anchor = cc.p(1, 0.5),
    	pos = cc.p(_contentSize.width - 10, _y1), 
    })
    contentNode:addChild(timeLabel)

 --    ---消息内容
	local str = data.chatMsg
	local _y2 = pCellSize.height*0.6
	local _msgSize = cc.size(_contentSize.width - 15, _y2)
	local msg = XTHDLabel:createWithSystemFont(str, "Helvetica", 16)
	msg:setColor(cc.c3b(131, 76, 52))
    msg:setWidth(_msgSize.width)
    msg:visit()
    local _isSingle = 1
    local pH = msg:getBoundingBox().height
    if pH < 25 then
    	_isSingle = 0.8
    else
		msg:setHeight(_msgSize.height)
    end    
    contentNode:addChild(msg)
    msg:setAnchorPoint(cc.p(0,1))
    msg:setPosition(cc.p(nameTTF:getPositionX(), _y2 * _isSingle))

	local isSelf = data.senderID == gameUser.getUserId()
	if isSelf then
		icon:setAnchorPoint(cc.p(1, 0.5))
		icon:setPosition(pCellSize.width - 16, pCellSize.height*0.5)
		background:setFlippedX(true)
		background:setPositionX(icon:getPositionX() - icon:getBoundingBox().width - 4 - _backSize.width*0.5)
		contentNode:setAnchorPoint(cc.p(1,0.5))
		contentNode:setPosition(icon:getPositionX() - icon:getBoundingBox().width - 4 - 20, pCellSize.height*0.5)

		-- nameTTF:setAnchorPoint(cc.p(1, 0.5))
		-- nameTTF:setPositionX(_contentSize.width - 10)
		-- timeLabel:setAnchorPoint(cc.p(0, 0.5))
		-- timeLabel:setPositionX(10)
	end

end

function HaoYouLayer:freshRight( cell )

	local pDatas = HaoYouPublic.getData()

	local pSelectData
	if cell then
		local idx = cell._idx
		local pData = pDatas[idx+1]
		if self._nowCharId == pData.charId then
			return
		else
			self._nowCharId = pData.charId
			if self._nowSelect >= 0 then
				self._friendTableView:updateCellAtIndex(self._nowSelect)
			end
			pSelectData = pData
			self._nowSelect = idx
			if self._nowSelect >= 0 then
				self._friendTableView:updateCellAtIndex(self._nowSelect)
			end
		end
	else
		self._nowCharId = -1
		if self._nowSelect >= 0 then
			self._friendTableView:updateCellAtIndex(self._nowSelect)
		end
		self._nowSelect = -1
	end
	if self._nowCharId < 0 or not pSelectData then
		self._editbox:setVisible(false)
		if not self._rightTip then
			self._rightTip = XTHDLabel:createWithParams({
		    	text = LANGUAGE_TIPS_WORDS84,------"请选择要聊天的好友",
		    	fontSize = 20,
		    	color = cc.c3b(128,112,91),
		    	anchor = cc.p(0.5, 0.5),
		    	pos = cc.p(self._rightBg:getContentSize().width*0.5, self._rightBg:getContentSize().height*0.5+100), 
		    })
		    self._rightBg:addChild(self._rightTip)
		end
		self._rightTip:setVisible(true)
		return
	end

    HaoYouPublic.freshTalkNewsFlag(self._nowCharId)
	self._editbox:setVisible(true)
	self._btnAction:setEnable(true)
	self._textLab:setVisible(false)
	self._sendFlower:runAction(cc.Sequence:create(		
		cc.MoveBy:create(0.1, cc.p(50,0)), 
		cc.Spawn:create(cc.EaseIn:create(cc.MoveBy:create(0.4, cc.p(-600,0)), 0.4),cc.FadeOut:create(0.4)),
	cc.CallFunc:create(function()
			self._sendFlower:setVisible(false)
	end)))



	if self._rightTip then
		self._rightTip:setVisible(false)
	end
	self._talkTableView:reloadData()
end

function HaoYouLayer:sendMsg( )
	local pNowData = HaoYouPublic.getDataByCharId(self._nowCharId)
	if not pNowData or not pNowData.onLine then
		XTHDTOAST(LANGUAGE_TIPS_WORDS85)------"该好友当前不在线！")
		return
	end
	local msg = self._editbox:getText()
	self._editbox:setText("")
	if msg and type(msg) == "string" and msg ~= "" then 
		local object = SocketSend:getInstance()
		if object then 
			object:writeInt(LiaoTianDatas.__chatType.TYPE_PRIVATE_CHAT)
			object:writeInt(self._nowCharId)
			object:writeString(msg)				
			object:send(MsgCenter.MsgType.CLIENT_REQUEST_CHAT)
		end 		
	else
		XTHDTOAST(LANGUAGE_TIPS_WORDS12)-----"不能发送空内容")
	end 
end

function HaoYouLayer:addFriend( ... )
	requires("src/fsgl/layer/HaoYou/HaoYouAddPop.lua"):create(self)
end

function HaoYouLayer:intracationFriend( ... )
	requires("src/fsgl/layer/HaoYou/HaoYouIntracationPop.lua"):create(self)
end



return HaoYouLayer
