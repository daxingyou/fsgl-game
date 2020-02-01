-- FileName: HaoYouAddPop.lua
-- Author: wangming
-- Date: 2015-09-14
-- Purpose: 添加好友界面
--[[TODO List]]
local HaoYouAddPop = class( "HaoYouAddPop", function ( sParams )
    return requires("src/fsgl/layer/HaoYou/HaoYouBasePop.lua"):createOne(sParams)
end)

function HaoYouAddPop:create( sNode, sParams)
	local params = sParams or {}
	params.title = LANGUAGE_TIPS_FRIENDINFO_ADD-------"添加好友"
	params.size = cc.size(660, 430)
	ClientHttp:httpRecommend(sNode, function ( data )
		local pLay = HaoYouAddPop.new(params)
		pLay:init(data)
		LayerManager.addLayout(pLay, {noHide = true})
	end)
end

function HaoYouAddPop:onCleanup()
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_FRIEND_ADDLIST)
end

function HaoYouAddPop:init( sData)
	XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_FRIEND_ADDLIST,
        callback = function (event)
        	self:freshData(self._data)
        end
    })
	self:freshData(sData)

	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()
	self.title:setPositionY(self.title:getPositionY()+20)
	self.title:setFontSize(26)
	self.title:setColor(cc.c3b(106,36,13))--"添加好友"
	
	--框
	local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
	kuang:setContentSize(_worldSize.width-20,_worldSize.height-70)
	kuang:setPosition(popNode:getContentSize().width/2,popNode:getContentSize().height/2-10)
	popNode:addChild(kuang)


	local _y = _worldSize.height - 80
	local _tipTTF = XTHDLabel:createWithParams({
    	text = LANGUAGE_TIPS_WORDS75,-------"输入玩家昵称或者ID",
    	fontSize = 22,
    	color = cc.c3b(106,36,13),
    })
    _tipTTF:setAnchorPoint(0, 0.5)
    _tipTTF:setPosition(35 , _y)
	popNode:addChild(_tipTTF, 2)


	local _size = cc.size(255, 40)
    local input_bg_account = ccui.Scale9Sprite:create("res/image/friends/input_bg.png")
    input_bg_account:setAnchorPoint(0, 0.5)
    input_bg_account:setContentSize(_size)
    input_bg_account:setPosition(cc.p(_tipTTF:getPositionX() + _tipTTF:getContentSize().width + 5 , _y))
    popNode:addChild(input_bg_account, 2)

    local editbox_account = ccui.EditBox:create(cc.size(_size.width-15, _size.height-5), ccui.Scale9Sprite:create(), nil, nil)
    editbox_account:setFontColor(cc.c3b(255,255,255))
    editbox_account:setPlaceHolder("请输入昵称或编号")-------"请输入信息")
    editbox_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    editbox_account:setAnchorPoint(0,0.5)
    editbox_account:setMaxLength(15)
    editbox_account:setPosition(10 , input_bg_account:getContentSize().height/2)
    editbox_account:setPlaceholderFontColor(cc.c3b(200,187,165))
    editbox_account:setFontName("Helvetica")
    editbox_account:setPlaceholderFontName("Helvetica")
    editbox_account:setFontSize(22)
    editbox_account:setPlaceholderFontSize(22)
    editbox_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editbox_account:setText(_name);
    input_bg_account:addChild(editbox_account)
    self._editbox = editbox_account

	local _btnAction = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create("res/image/friends/friendPic_07.png"),
		selectedNode = cc.Sprite:create("res/image/friends/friendPic_09.png"),
		musicFile = XTHD.resource.music.effect_btn_common,
		needSwallow = true,
		enable = true,
		endCallback = function ( ... )
			local string = editbox_account:getText()
			if string == nil or string.len(string) < 1 then
                XTHDTOAST(LANGUAGE_TIPS_WORDS76)------"查找信息不可为空！")
                return
            end
            ClientHttp:httpFindPlayer( self, function( data )
            	self:freshData(data, true)
            end, {charName = string})
		end
	})
	_btnAction:setScale(0.6)
	_btnAction:setAnchorPoint(0, 0.5)
	_btnAction:setPosition(cc.p(input_bg_account:getPositionX() + input_bg_account:getContentSize().width + 5, _y))
	popNode:addChild(_btnAction, 2)

	local _line = cc.Sprite:create("res/image/friends/friendPic_55.png")
    _line:setPosition(cc.p(_worldSize.width*0.5, _worldSize.height - 110))
    popNode:addChild(_line, 2)

	local _tipTTF = XTHDLabel:createWithParams({
    	text = LANGUAGE_KEY_RECOMMENDBODY,-------"推荐好友",
    	fontSize = 22,
    	color = cc.c3b(106,36,13),
    })
    _tipTTF:setAnchorPoint(0, 0.5)
    _tipTTF:setPosition(35 , _line:getPositionY() - 25)
	popNode:addChild(_tipTTF, 2)

	local _scale = cc.p(0.6,0.8)
    -- local _touchSize = cc.size(_normalNode:getContentSize().width*_scale.x, _normalNode:getContentSize().height*_scale.y)
	local _btnAction = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		text = LANGUAGE_TIPS_FRIENDINFO_CHANGE,
		fontSize = 26,
		musicFile = XTHD.resource.music.effect_btn_common,
		needSwallow = true,
		enable = true,
		-- touchSize = _touchSize,
		endCallback = function ( ... )
			ClientHttp:httpRecommend(self, function ( data )
				self:freshData(data)
			end)
		end
	})
	_btnAction:setScale(0.6)
	-- _btnAction:setScaleX(_scale.x)
	-- _btnAction:setScaleY(_scale.y)
	_btnAction:setAnchorPoint(0, 0.5)
	_btnAction:setPosition(cc.p(_tipTTF:getPositionX() + _tipTTF:getContentSize().width + 5, _tipTTF:getPositionY()))
	popNode:addChild(_btnAction, 2)


	local pTables = {1,1,1,1,1,1,1,1,1,1,1}
	local _length = 10
	local _cellSize = cc.size(_worldSize.width*0.95, 100)
	local _tableSize = cc.size(_worldSize.width*0.95, _worldSize.height - 180)
	local function cellSizeForTable(table,idx)
		return  _cellSize.width,_cellSize.height
    end
    local function numberOfCellsInTableView(table)
    	local pNum, floa = math.modf(#self._data * 0.5)
    	if floa > 0 then
    		pNum = pNum + 1
    	end
        return pNum
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

	    self:freshCellAtIndex(node, idx)
	    
		return _cell
    end

 	local _tableView = CCTableView:create(_tableSize)
    _tableView:setPosition(cc.p((_worldSize.width - _tableSize.width)*0.5, 27))
    _tableView:setBounceable(true)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    _tableView:setDelegate()
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
 
	_tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData()  

    popNode:addChild(_tableView)
	self._friendTableView = _tableView  
end

function HaoYouAddPop:freshCellAtIndex( node, idx )
	local pCellSize = node:getContentSize()
	local function initCell( sData, isLeft )
	    local _di = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
	    _di:setContentSize(cc.size(pCellSize.width*0.5 - 10, pCellSize.height))
	    if isLeft then
		    _di:setAnchorPoint(0, 0)
		    _di:setPosition(5, 0)
		else
			_di:setAnchorPoint(1, 0)
			_di:setPosition(pCellSize.width - 5, 0)
		end
	    node:addChild(_di)

	    local _isFriend = HaoYouPublic.isFriend(sData.charId)
		local function headTouchCall( ... )
			requires("src/fsgl/layer/HaoYou/HaoYouInfoPop.lua"):create(self, {data = sData, isFriend = _isFriend})
		end
		local icon = HaoYouPublic.getFriendIcon(sData, {callFn = headTouchCall})
		icon:setAnchorPoint(0,0.5)
		icon:setPosition(25, pCellSize.height*0.5)
		icon:setScale(0.6)
		_di:addChild(icon)

	    local _ttfX = 100
	    local _nameString = sData.charName
		local _nameTTF = XTHDLabel:create(_nameString,18, "res/fonts/def.ttf")
	    _nameTTF:setAnchorPoint(0, 0.5)
		_nameTTF:setColor(cc.c3b(106,36,13))---------推荐好友名
		--_nameTTF:enableOutline(cc.c4b(0,0,0,255),1)
	    _nameTTF:setPosition(_ttfX , pCellSize.height*0.70)
		_di:addChild(_nameTTF)

		local level = sData.level or 1
		local string = HaoYouPublic.getCampStr(sData.campId)
		local _infoString = LANGUAGE_KEY_PLAYER_CAMP_LEVEL(level,string)-----------"级 " .. string
	    local _flowTTF = XTHDLabel:createWithParams({
	    	text = _infoString,
	    	fontSize = 18,
	    	color = cc.c3b(131, 76, 52),
	    })
	    _flowTTF:setAnchorPoint(0, 0.5)
	    _flowTTF:setPosition(_ttfX , pCellSize.height*0.30)
		_di:addChild(_flowTTF)

		local _fileStr = {"42","44"}
		if _isFriend then
			_fileStr[1] = "46"
			_fileStr[2] = "48"
		end
		
		local _btnSend 
		_btnSend = XTHDPushButton:createWithParams({
			normalNode = cc.Sprite:create("res/image/friends/friendPic_".._fileStr[1]..".png"),
			selectedNode = cc.Sprite:create("res/image/friends/friendPic_".._fileStr[2]..".png"),
			musicFile = XTHD.resource.music.effect_btn_common,
			needSwallow = false,
			enable = not _isFriend,
			touchSize = _touchSize,
			endCallback = function ( ... )
				if HaoYouPublic.isFriend(sData.charId) then
					XTHDTOAST(LANGUAGE_TIPS_WORDS77)------"已与该玩家是好友关系！")
					_btnSend:setEnable(false)
	        		_btnSend:setStateNormal(cc.Sprite:create("res/image/friends/friendPic_".._fileStr[1]..".png"))
					return
				end
				ClientHttp:httpAddRequest(self, function ( data )
					_btnSend:setEnable(false)
	        		_btnSend:setStateNormal(cc.Sprite:create("res/image/friends/friendPic_46.png"))
		        	XTHDTOAST(LANGUAGE_KEY_SENDBEGSUCCESS)-----"发送请求成功！")
				end, {charId = sData.charId})
			end
		})
		
		
		_btnSend:setPosition(_di:getContentSize().width - 40 , pCellSize.height*0.5)
		_di:addChild(_btnSend)
	end

	local pNum = (idx + 1)*2 - 1

	local data1 = self._data[pNum]
	if data1 then
		initCell(data1, true)
	end
	local data2 = self._data[pNum + 1]
	if data2 then
		initCell(data2, false)
	end
end

function HaoYouAddPop:freshData( sData, isFind)
	self._data = sData.list or {}
	-- dump(sData, "self._data")
	if self._friendTableView then
		self._friendTableView:reloadData()
	end
	if #self._data > 0 then
		if self._infoTip then
			self._infoTip:setVisible(false)
		end
		return
	end
	if not self._infoTip then
		self._infoTip = XTHDLabel:createWithParams({
	    	text = "",
	    	fontSize = 26,
	    	color = cc.c3b(31,30,255),
	    	anchor = cc.p(0.5, 0.5),
	    	pos = cc.p(self._popNode:getContentSize().width*0.5, self._popNode:getContentSize().height*0.4), 
	    })
	    self._popNode:addChild(self._infoTip)
	end
	self._infoTip:setVisible(true)
	if isFind then
		self._infoTip:setString(LANGUAGE_TIPS_WORDS78)------"没有查找到该玩家")
	else
		self._infoTip:setString(LANGUAGE_TIPS_WORDS79)------"暂无推荐好友")
	end
end

function HaoYouAddPop:removeOneData( sData )
	local isHave = nil
	for k,v in pairs(self._data) do
		if v.charId == sData.charId then
			isHave = v
			break
		end
	end
	if isHave then
		table.remove(self._data, v)
		self:freshData(self._data)
	end
end

return HaoYouAddPop