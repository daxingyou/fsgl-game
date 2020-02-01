--[[
-----好友邀请
-----
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

local DuoRenFuBenInvite = class("DuoRenFuBenInvite",function( )
	return XTHD.createBasePageLayer({
        ZOrder = 1,
    })
end)

function DuoRenFuBenInvite:ctor()
	self._splitPos = {}
	self._friendList = nil
	self._friednData = {}
	local pDatas = HaoYouPublic.getData()
	for i=1,#pDatas do
		local _data = pDatas[i]
		if _data.onLine then
			self._friednData[#self._friednData + 1] = _data
		end
	end
end

function DuoRenFuBenInvite:init( )
	------背景
	local bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
	self:addChild(bg)
	self._bg = bg
	bg:setPosition(self:getContentSize().width / 2,(self:getContentSize().height - self.topBarHeight) / 2)
	-------第二层背景
	local secondBg = ccui.Scale9Sprite:create()
	secondBg:setContentSize(cc.size(self._bg:getContentSize().width - 8,bg:getContentSize().height - 38))
	self._bg:addChild(secondBg)
	secondBg:setPosition(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2)
	self._usefulBg = secondBg
	--表头背景 
	local bt_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_25.png")
	bt_bg:setContentSize(cc.size(self._bg:getContentSize().width - 8,48))
	bt_bg:setPosition(secondBg:getContentSize().width/2,secondBg:getContentSize().height-2)
	bt_bg:setAnchorPoint(0.5,1)
	secondBg:addChild(bt_bg)
	------表格标题
	local _title1 = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS269,XTHD.SystemFont,20) -----好友名称
	_title1:setColor(cc.c3b(54,55,112))
	secondBg:addChild(_title1)
	_title1:setPosition(secondBg:getContentSize().width * 1/6 - 25,secondBg:getContentSize().height - _title1:getContentSize().height / 2 - 10)
	local _line = cc.Sprite:create("res/image/common/line_1.png")
	secondBg:addChild(_line)
	_line:setScaleX(33 / _line:getContentSize().width)
	_line:setRotation(90)
	_line:setPosition(_title1:getPositionX() * 2,_title1:getPositionY() + 2)
	local x,y = _line:getPosition()
	self._splitPos[1] = {_line:getPosition()}
	------
	local _title2 = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_LEVEL,XTHD.SystemFont,20) ----等级
	_title2:setColor(cc.c3b(54,55,112))
	_title2:setAnchorPoint(0,0.5)
	secondBg:addChild(_title2)
	_title2:setPosition(_line:getPositionX() + 50,_title1:getPositionY())
	x = _title2:getPositionX() + _title2:getContentSize().width + 50
	_line = cc.Sprite:create("res/image/common/line_1.png")
	secondBg:addChild(_line)
	_line:setScaleX(33 / _line:getContentSize().width)
	_line:setRotation(90)
	_line:setPosition(x,y)
	x,y = _line:getPosition()
	self._splitPos[2] = {_line:getPosition()}
	------
	local _title3 = XTHDLabel:createWithSystemFont(LANGUAGE_NAMES.fightVim,XTHD.SystemFont,20) ------战斗力
	_title3:setColor(cc.c3b(54,55,112))
	_title3:setAnchorPoint(0,0.5)
	secondBg:addChild(_title3)
	_title3:setPosition(x + 150,_title2:getPositionY())
	x = _title3:getPositionX() + _title3:getContentSize().width + 150

	_line = cc.Sprite:create("res/image/common/line_1.png")
	secondBg:addChild(_line)
	_line:setScaleX(33 / _line:getContentSize().width)
	_line:setRotation(90)
	_line:setPosition(x,y)
	x,y = _line:getPosition()
	self._splitPos[3] = {_line:getPosition()}
	---------
	local _title4 = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS265,XTHD.SystemFont,20) ------操作
	_title4:setColor(cc.c3b(54,55,112))
	secondBg:addChild(_title4)
	_title4:setPosition((secondBg:getContentSize().width - x) / 2 + x,_title2:getPositionY())

	if #self._friednData > 0 then
		self:initFriendsList()
	else
		local _name = XTHDLabel:createWithParams({
			text = LANGUAGE_KEY_NOONLINEFRIEND,
			fontSize = 26,
			color = XTHD.resource.color.gray_desc,
			pos = cc.p(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5),
		})
		bg:addChild(_name)
	end
end

function DuoRenFuBenInvite:initFriendsList()
	local _diHeight = 5
	local _size = cc.size(self._usefulBg:getContentSize().width, self._usefulBg:getContentSize().height - 35 - _diHeight)
    local _cellSize = cc.size(_size.width, 62)
    local function cellSizeForTable(table,idx)
        return _cellSize.width,_cellSize.height+20
    end

    local function numberOfCellsInTableView(table)
    	local _num = self._friednData and #self._friednData or 0
    	return _num
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
            cell:setContentSize(_cellSize)
        end
        local _bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
		_bg:setContentSize(_cellSize.width - 5, _cellSize.height+15)
		_bg:setAnchorPoint(0.5, 0.5)
		_bg:setPosition(_cellSize.width*0.5, _cellSize.height*0.5)
		cell:addChild(_bg)

		local _num = idx + 1

		local _max = self._friednData and #self._friednData or 0
		if _num ~= _max then
			local _line = ccui.Scale9Sprite:create(cc.rect(150,0,1,1), "res/image/common/line_1.png")
			_line:setContentSize(_cellSize.width, 1)
			_line:setPosition(_cellSize.width*0.5, 0)
			cell:addChild(_line)
		end
		self:createFriendCell(_num, _bg)
        return cell
    end

    self._friendList = CCTableView:create(_size)
    self._friendList:setPosition(cc.p(0, _diHeight-15))
    self._friendList:setBounceable(true)
    self._friendList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._friendList:setDelegate()
    self._friendList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._usefulBg:addChild(self._friendList)

    self._friendList:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._friendList:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._friendList:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._friendList:reloadData()
end

function DuoRenFuBenInvite:createFriendCell( _num, _bg )
	local _data = self._friednData[_num]
    if not _data then
    	return
    end
	local _size = _bg:getContentSize()
	-------副本名字
	local _name = XTHDLabel:createWithParams({
		text = _data.charName,
		fontSize = 20,
		color = XTHD.resource.color.gray_desc,
		pos = cc.p(self._splitPos[1][1]*0.5, _size.height*0.5),
	})
	_bg:addChild(_name)
	----分隔线
	local _line = cc.Sprite:create("res/image/common/line_1.png")
	_line:setScaleX(33 / _line:getContentSize().width)
	_line:setRotation(90)
	_bg:addChild(_line)
	_line:setPosition(self._splitPos[1][1] - 5, _size.height*0.5)
	-------等级

	local x = self._splitPos[2][1] - self._splitPos[1][1]
	local _level = XTHDLabel:createWithParams({
		text = _data.level,
		fontSize = 20,
		color = XTHD.resource.color.gray_desc,
		pos = cc.p(self._splitPos[1][1] + x*0.5, _size.height*0.5)
	})
	_bg:addChild(_level)	

	_line = cc.Sprite:create("res/image/common/line_1.png")
	_line:setScaleX(33 / _line:getContentSize().width)
	_line:setRotation(90)
	_bg:addChild(_line)
	_line:setPosition(self._splitPos[2][1] - 5, _size.height*0.5)
	--------战斗力
	x = self._splitPos[3][1] - self._splitPos[2][1]
	local _fightVim = XTHDLabel:createWithParams({
		text = _data.power,
		fontSize = 20,
		color = XTHD.resource.color.gray_desc,
		pos = cc.p(self._splitPos[2][1] + x*0.5, _size.height*0.5)
	})
	_bg:addChild(_fightVim)	

	_line = cc.Sprite:create("res/image/common/line_1.png")
	_line:setScaleX(33 / _line:getContentSize().width)
	_line:setRotation(90)
	_bg:addChild(_line)
	_line:setPosition(self._splitPos[3][1] - 5, _size.height*0.5)
	-------加入按钮
	local _inviteBtn
	local function _doInvite()
		local object = SocketSend:getInstance()
		if object then 
			object:writeInt(_data.charId)
			object:send(MsgCenter.MsgType.CLIENT_REQUEST_INVITEFRIEND)
		end 
		_inviteBtn:setEnable(false)
		_inviteBtn:setText(LANGUAGE_KEY_INVITED)
	end

	_inviteBtn = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		text = LANGUAGE_KEY_INVITE,
		fontSize = 20,
		fontColor = cc.c3b(255,255,255),
		pos = cc.p((_size.width - self._splitPos[3][1])*0.5 + self._splitPos[3][1], _size.height*0.5),
		endCallback = _doInvite,
	})
	_inviteBtn:setScale(0.7)
	_bg:addChild(_inviteBtn)

end

function DuoRenFuBenInvite:create( node )
	local function createLayer()
		local lay = DuoRenFuBenInvite.new()
		lay:init()
        LayerManager.addLayout(lay)
	end
	HaoYouPublic.httpGetFriendData( node, createLayer)	
end

return DuoRenFuBenInvite