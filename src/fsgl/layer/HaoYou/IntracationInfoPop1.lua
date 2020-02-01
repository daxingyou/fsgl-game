-- FileName: IntracationInfoPop1.lua
-- Author: wangming
-- Date: 2015-09-16
-- Purpose: 新增信息显示界面
--[[TODO List]]
local IntracationInfoPop1 = class( "IntracationInfoPop1", function ( sParams )
    return requires("src/fsgl/layer/HaoYou/HaoYouBasePop.lua"):createOne(sParams)
end)

function IntracationInfoPop1:create( sNode, sParams )
	local params = sParams or {}
	local pLay = IntracationInfoPop1.new(params)
	pLay:init()
	LayerManager.addLayout(pLay, {noHide = true})
	-- sNode:addChild(pLay, 5)
end


function IntracationInfoPop1:onEnter( ... )
	HaoYouPublic.setNews(false)
    XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_FRIEND_NEWMSG,
        callback = function (event)
	        self:freshMsgShow()
        end
    })
end

function IntracationInfoPop1:onExit( ... )
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_FRIEND_NEWMSG)
end

function IntracationInfoPop1:onCleanup( ... )
	HaoYouPublic.removeAllNewMsgs()
end

function IntracationInfoPop1:freshMsgShow( ... )
	if self._tableView then
    	self._tableView:reloadData()
    end
    local _data = HaoYouPublic.getNewMsgs() 
    if #_data == 0 and self._tipInfo then
    	self._tipInfo:setVisible(true)
    else
    	self._tipInfo:setVisible(false)
    end
end

function IntracationInfoPop1:init( )
	
	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()

	-- local _titleDi = cc.Sprite:create("res/image/building/title_bg.png")
	-- _titleDi:setAnchorPoint(cc.p(0.5, 0))
	-- _titleDi:setPosition(cc.p(_worldSize.width*0.5 , _worldSize.height - 5))
	-- popNode:addChild(_titleDi, 2)

	local _titleTTF = cc.Sprite:create("res/image/friends/zuixinxiaoxi_03.png")
	_titleTTF:setAnchorPoint(cc.p(0.5, 0.5))
	_titleTTF:setPosition(cc.p(_worldSize.width*0.5 , _worldSize.height - 25))
	popNode:addChild(_titleTTF)

	local sDatas = HaoYouPublic.getNewMsgs()

    local _tipInfo = XTHDLabel:createWithParams({
    	text = LANGUAGE_KEY_NONEMSG,--------"暂无消息",
    	fontSize = 24,
    	color = XTHD.resource.color.brown_desc,
    	anchor = cc.p(0.5, 0.5),
    	pos = cc.p(_worldSize.width*0.5 , _worldSize.height*0.5),
    })
	popNode:addChild(_tipInfo)
	self._tipInfo = _tipInfo

	if not sDatas or #sDatas == 0 then
		self._tipInfo:setVisible(true)
	else
		self._tipInfo:setVisible(false)
	end
	
	local _cellSize = cc.size(_worldSize.width*0.95, 80)
	local _tableSize = cc.size(_worldSize.width*0.95, _worldSize.height - 65)
	local function cellSizeForTable(table,idx)
		return _cellSize.width,_cellSize.height
    end
    local function numberOfCellsInTableView(table)
    	local _data = HaoYouPublic.getNewMsgs() 
        return #_data
    end
    local function tableCellTouched(table,cell)
    	
    end

	local function tableCellAtIndex(table,idx)
		local _cell = table:dequeueCell()
	    if _cell then
	        _cell:removeAllChildren()
	    else
	        _cell = cc.TableViewCell:new()
			_cell:setContentSize(_cellSize.width,_cellSize.height)
	    end

	    local pCellSize = cc.size(_cellSize.width, _cellSize.height - 5)
		local node = cc.Node:create()
		node:setContentSize(pCellSize)
	    _cell:addChild(node)

	    local _di = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
	    _di:setContentSize(pCellSize)
	    _di:setAnchorPoint(0, 0)
	    _di:setPosition(0, 0)
	    node:addChild(_di)

	    local _data = HaoYouPublic.getNewMsgs()
	    local pData = _data[idx + 1]
	    if not pData then
	    	return
	    end

	    local _name = tostring(pData.charName)
	    local _lv = tonumber(pData.level) or 1
	    local _camp = HaoYouPublic.getCampStr(pData.campId)
	    local _str = LANGUAGE_KEY_INTRACATION_NAMETIP(pData)
	    local _timeTTF = XTHDLabel:createWithSystemFont(_str, "Helvetica", 22)
	    _timeTTF:setColor(XTHD.resource.color.brown_desc)
	    _timeTTF:setAnchorPoint(0,0.5)
	    _timeTTF:setPosition( 20 , pCellSize.height*0.7)
		node:addChild(_timeTTF)

		local _btnSize = cc.size(102, 46)
		local _str2 = ""
		local _callBack
		local _picFile1 = nil
		local _picFile2 = nil
	    if pData.sMsgType == FriendMsgType.ADD_FRIEND then
	    	_str2 = LANGUAGE_TIPS_WORDS88-------"申请成为您的好友"
	    	local function goDoSomething( isDo )
	    		local _op = isDo and 1 or 0
	    		ClientHttp:httpAddFriend(self, function( data )
	    			if isDo then
		        		XTHDTOAST(data.msg or LANGUAGE_KEY_ADDFRIENDSUCCESS)-----"添加好友成功！")
		        	end
		        	HaoYouPublic.removeNewMsgs(pData)
		        	self:freshMsgShow()
	    		end, function( data )
	    			HaoYouPublic.removeNewMsgs(pData)
		        	self:freshMsgShow()
	    		end, {charId = pData.charId, op = _op})
	    	end

	    	_callBack = goDoSomething
	    	_picFile1 = LANGUAGE_BTN_KEY.hulue                   						 	 --"hulue_hong"
	    	_picFile2 = LANGUAGE_BTN_KEY.agree_text                   						 --"tongyi_lv"
	    elseif pData.sMsgType == FriendMsgType.SEND_FLOWER then
	    	local pCount = tonumber(pData.count) or 0
	    	_str2 = LANGUAGE_FORMAT_TIPS20(pCount)------- "赠送了您" .. pCount .. "朵鲜花"
	    	local function goDoSomething( isDo )
	        	if isDo then
		    		requires("src/fsgl/layer/HaoYou/HaoYouSendPop.lua"):create(self, pData)
		    	end
	    		HaoYouPublic.removeNewMsgs(pData)
	        	self:freshMsgShow()
	    	end
	    	_callBack = goDoSomething
	    	_picFile1 = LANGUAGE_BTN_KEY.hulue                   						 --"hulue_hong"
	    	_picFile2 = LANGUAGE_BTN_KEY.huizeng                   						 --"huizeng_lv"
    	elseif pData.sMsgType == FriendMsgType.FIGHT_FRIEND then
    		-- local pWin = pData.isWin and LANGUAGE_NAMES.you..LANGUAGE_NAMES.win or LANGUAGE_NAMES.you..LANGUAGE_NAMES.lose ------"你赢了" or "你输了"
    		-- _str2 = LANGUAGE_TIPS_WORDS89..pWin--------"和您切磋了一下  " .. pWin
    		_str2 = LANGUAGE_KEY_INTRACATION_TYPE3(pData.isWin)
		elseif pData.sMsgType == FriendMsgType.ESCORT_FIGHT then
			local function goDoSomething( ... )
				XTHD.YaYunLiangCaoLayer(self, function( )
					self:hide()
				end)
			end
			_str2 = LANGUAGE_KEY_INTRACATION_TYPE4(pData.isWin)
			_callBack = goDoSomething
			_picFile2 = LANGUAGE_BTN_KEY.go                   						 --"qianwang_lv"
	    elseif pData.sMsgType == FriendMsgType.MULTIPLE_INVITE then
	    	local function goDoSomething( ... )
	    		XTHD.acceptMultiCopyInvite({
	    			configID = pData.stageId,
	    			teamID = pData.teamId,
	    		})
				self:hide()
			end
			local _data = gameData.getDataFromCSV("TeamCopyList", {["id"] = pData.stageId})
			_str2 = LANGUAGE_KEY_INTRACATION_TYPE5(_data.name)
			_callBack = goDoSomething
			_picFile2 = LANGUAGE_BTN_KEY.go                   						 --"qianwang_lv"
	    elseif pData.sMsgType == FriendMsgType.CASTELLANFIGHT then
			_str2 = LANGUAGE_KEY_INTRACATION_TYPE6(pData.cityName)          
	    end

	    if _callBack then
			if _picFile1~=nil then
				local _btnNotDo = XTHD.createCommonButton({
						btnColor = "write",
						btnSize = _btnSize,
						isScrollView = true,
						touchSize = _btnSize,
						text = _picFile1,
						needSwallow = true,
						endCallback = function ( ... )
							_callBack(false)
						end
					})
					_btnNotDo:setScale(0.7)
				_btnNotDo:setPosition(cc.p(pCellSize.width - 200, pCellSize.height*0.5))
				node:addChild(_btnNotDo)
			end

			if _picFile2~=nil then
			    local _btnDo = XTHD.createCommonButton({
						btnSize = _btnSize,
						isScrollView = true,
						text = _picFile2,
						touchSize = _btnSize,
						needSwallow = true,
						endCallback = function ( ... )
							_callBack(true)
						end
					})
					_btnDo:setScale(0.7)
				_btnDo:setPosition(cc.p(pCellSize.width - 80, pCellSize.height*0.5))
				node:addChild(_btnDo)
			end
	    end

	    local _infoTTF = XTHDLabel:createWithSystemFont(_str2, "Helvetica", 22)
	    _infoTTF:setColor(cc.c3b(200, 61, 12))
	    _infoTTF:setAnchorPoint(0,0.5)
	    _infoTTF:setPosition( 20 , pCellSize.height*0.30)
		node:addChild(_infoTTF)

		return _cell
    end

 	local _tableView = CCTableView:create(_tableSize)
    _tableView:setPosition(cc.p((_worldSize.width - _tableSize.width)*0.5, 18))
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
	self._tableView = _tableView  
end

return IntracationInfoPop1