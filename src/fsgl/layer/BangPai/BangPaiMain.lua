-- FileName: BangPai.lua
-- Author: wangming
-- Date: 2015-10-15
-- Purpose: 玩家所属帮派界面
--[[TODO List]]

local BangPaiMain = class("BangPaiMain", function (...) 
    return XTHD.createBasePageLayer({
		bg = "res/image/newGuild/bg.png"
	})
end)

function BangPaiMain:init(sParams)
	self._fontSize = 20
    self.isMaster = false
    self.permissionData = {}
    self.guildData = {}
    self.myMemberData = {}
    self.verticalPos = {}           --列表数据位置
	self._rankListData = {}    
	self._btnList = {}
    self:resetGuildData()

    self.notificatelabel = nil


    local _topBarHeight = self.topBarHeight or 40
    local _bg = cc.Sprite:create("res/image/newGuild/guildbg.png")
    _bg:setPosition(cc.p(self:getContentSize().width/2,(self:getContentSize().height - _topBarHeight)/2 ))
    self:addChild(_bg)
	self._bg = _bg
	
	local title = "res/image/public/bangpai_title.png"
	XTHD.createNodeDecoration(self._bg,title)

	self._bg:getChildByName("hengliang"):setScale(0.91)
	self._bg:getChildByName("dibian"):setScale(0.91)

	--右边的四个按钮
	local btnName = {"zhuye_","chengyuan_","shenqing_","guanli_"}
	for i = 1, #btnName do
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/newGuild/"..btnName[i].."1.png",
			selectedFile = "res/image/newGuild/"..btnName[i].."2.png"
		})
		self._bg:addChild(btn)
		self._btnList[#self._btnList + 1] = btn
		btn:setPosition(self._bg:getContentSize().width - btn:getContentSize().width - 0.5 - 10,self._bg:getContentSize().height - btn:getContentSize().height *0.5 - ((i-1)*(btn:getContentSize().height + 3)) - 18)
		if i == 1 then
			btn:setSelected(true)
		end
		if i == 3 then
			self.red_point = XTHD.createSprite("res/image/common/heroList_redPoint.png")
			self.red_point:setPosition(btn:getContentSize().width-5,btn:getContentSize().height-5)
			self.red_point:setScale(0.8)
			self.red_point:setTag(2)
			btn:addChild(self.red_point)
			self.red_point:setVisible(false)
		end
		btn:setTouchEndedCallback(function()
			for j = 1,#self._btnList do
				if self._btnList[j] then
					self._btnList[j]:setSelected(false)
				end
			end
			if self._btnList[i] then
				self._btnList[i]:setSelected(true)
			end
			self:createUI(i)
		end)
	end

	if self.permissionData["right2"]==nil or tonumber(self.permissionData["right2"])~=1 then
		self._btnList[3]:setVisible(false)
	else 
        self:RedPoint()
	end
	
	if self.permissionData["right1"]==nil or tonumber(self.permissionData["right1"])~=1 then
		self._btnList[4]:setVisible(false)
	end
	
	local Node = cc.Node:create()
	Node:setAnchorPoint(cc.p(0.5,0.5))
	Node:setContentSize(_bg:getContentSize())
	self:addChild(Node)
	Node:setPosition(self:getContentSize().width/2,(self:getContentSize().height - _topBarHeight)/2 )
	self._node = Node

	local leftbg = cc.Sprite:create("res/image/newGuild/basicinfobg.png")
	self._bg:addChild(leftbg)
	leftbg:setPosition(leftbg:getContentSize().width*0.5,self._bg:getContentSize().height*0.5)
	self._leftbg = leftbg

	self._rightbg = cc.Sprite:create("res/image/newGuild/memberbg.png")
	self._rightbg:setContentSize(self._rightbg:getContentSize().width + 10,self._rightbg:getContentSize().height + 5)
	self._bg:addChild(self._rightbg)
	self._rightbg:setPosition(self._bg:getContentSize().width *0.5 + 140,self._bg:getContentSize().height *0.5 - 2)
	
	local help_btn = XTHDPushButton:createWithParams({
		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=36});
            self:addChild(StoredValue)
        end,
	})
	help_btn:setScale(0.8)
	self._leftbg:addChild(help_btn)
	help_btn:setPosition(help_btn:getContentSize().width*0.5,self._leftbg:getContentSize().height - help_btn:getContentSize().height *0.5)
	
	--帮派昵称
    local _guildName = XTHDLabel:createWithSystemFont(self.guildData.guildName or "","Helvetica",self._fontSize)
    self.guildName = _guildName
    _guildName:setColor(cc.c3b(250,248,199))
    _guildName:setAnchorPoint(cc.p(0.5,0.5))
    _guildName:setPosition(self._leftbg:getContentSize().width *0.5,self._leftbg:getContentSize().height - _guildName:getContentSize().height *0.5 - 8 )
    self._leftbg:addChild(_guildName,6)
	--_guildName:enableBold()

    --icon
    local _icon = self.guildData.icon or 1
    local _guildIconSp = BangPaiFengZhuangShuJu.createGuildIcon(_icon,self.guildData.level or 1)
    _guildIconSp.guildIcon = _icon
    self.guildIconSp = _guildIconSp
    _guildIconSp:setAnchorPoint(cc.p(0.5,0.5))
    _guildIconSp:setPosition(cc.p(_guildIconSp:getContentSize().width *0.5 + 50,self._leftbg:getContentSize().height - _guildIconSp:getContentSize().height *0.5 - 70))
    self._leftbg:addChild(_guildIconSp,5)
	_guildIconSp:setScale(0.83)

	--帮派ID：
    local _IDtitleLabel = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildIDTitleTextXc .. ":",self._fontSize-4)
    _IDtitleLabel:setColor(cc.c3b(46,1,1))
    _IDtitleLabel:setAnchorPoint(cc.p(0,0.5))
    _IDtitleLabel:setPosition(self.guildIconSp:getPositionX() - self.guildIconSp:getContentSize().width *0.5 + 8,self.guildIconSp:getPositionY() + self.guildIconSp:getContentSize().height*0.5 + 5)
    self._leftbg:addChild(_IDtitleLabel)
	--_IDtitleLabel:enableBold()

    --id号
    local _IDValueLabel = XTHDLabel:create(self.guildData.guildId or "",self._fontSize - 4)
    _IDValueLabel:setColor(cc.c3b(46,1,1))
    _IDValueLabel:setAnchorPoint(cc.p(0,0.5))
    _IDValueLabel:setPosition(cc.p(_IDtitleLabel:getBoundingBox().x+_IDtitleLabel:getBoundingBox().width + 5,_IDtitleLabel:getPositionY()))
    self._leftbg:addChild(_IDValueLabel)
	--_IDValueLabel:enableBold()

    local _infoPosX = _guildIconSp:getBoundingBox().x+_guildIconSp:getBoundingBox().width + 16

    --帮派等级
    local _guildLevel = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildLevelTitleTextXc .. "："..self.guildData.level,self._fontSize-4,"res/fonts/def.ttf")
    _guildLevel:setColor(cc.c3b(46,1,1))
    _guildLevel:setAnchorPoint(cc.p(0.5,0.5))
    _guildLevel:setPosition(cc.p(self._leftbg:getContentSize().width * 0.5 + 45,self._leftbg:getContentSize().height - _guildLevel:getContentSize().height *0.5 - 55))
    self._leftbg:addChild(_guildLevel)
	--_guildLevel:enableBold()
	self._guildLevel = _guildLevel

    local _expProgressBg = cc.Sprite:create("res/image/newGuild/progressbg.png")
    self.expProgressBg = _expProgressBg
    _expProgressBg:setAnchorPoint(cc.p(0.5,0.5))
    _expProgressBg:setPosition(cc.p(_guildLevel:getPositionX(), _guildLevel:getPositionY() - 18))
    self._leftbg:addChild(_expProgressBg)

    local _percentage = tonumber(self.guildData.curExp or 0)/tonumber(self.guildData.maxExp or 1) * 100
    local _expProgress = cc.ProgressTimer:create(cc.Sprite:create("res/image/newGuild/progressBar.png"))
    _expProgress:setName("expProgress")
    _expProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    _expProgress:setMidpoint(cc.p(0,0.5))
    _expProgress:setBarChangeRate(cc.p(1,0))
    _expProgress:setPosition(cc.p(_expProgressBg:getContentSize().width/2,_expProgressBg:getContentSize().height/2))
    _expProgress:setPercentage(_percentage)
    _expProgressBg:addChild(_expProgress)

	local lable = XTHDLabel:create(tostring(self.guildData.curExp or 0) .." / " ..tostring(self.guildData.maxExp or 1),12,"res/fonts/def.ttf")
	lable:setColor(cc.c3b(0,0,0))
	self.expProgressBg:addChild(lable)
	lable:setPosition( self.expProgressBg:getContentSize().width*0.5, self.expProgressBg:getContentSize().height *0.5- 1.5)
	self._expLable = lable

	local _guildBangzhu =  XTHDLabel:create("帮派帮主：",self._fontSize-6,"res/fonts/def.ttf")
	_guildBangzhu:setColor(cc.c3b(46,1,1))
	_guildBangzhu:setAnchorPoint(cc.p(0,0.5))
	self._leftbg:addChild(_guildBangzhu)
	_guildBangzhu:setPosition(_guildIconSp:getPositionX() + _guildBangzhu:getContentSize().width *0.5 + 5,self._leftbg:getContentSize().height *0.7 + _guildBangzhu:getContentSize().height *0.5 + 23)
	--_guildBangzhu:enableBold()

	local _nameLable = XTHDLabel:create(self.guildData.bangzhuName,self._fontSize-6,"res/fonts/def.ttf")
	_nameLable:setAnchorPoint(1,0.5)
	_nameLable:setColor(cc.c3b(46,1,1))
	self._leftbg:addChild(_nameLable)
	_nameLable:setPosition(self._leftbg:getContentSize().width  - _nameLable:getContentSize().width - 15,_guildBangzhu:getPositionY())
	--_nameLable:enableBold()
	
    --帮派人数
    local _guildMember = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildMemberNumberTitleTextXc .. "：",self._fontSize - 6,"res/fonts/def.ttf")
    _guildMember:setColor(cc.c3b(46,1,1))
    _guildMember:setAnchorPoint(cc.p(0,0.5))
    _guildMember:setPosition(cc.p(_guildBangzhu:getPositionX(), _guildBangzhu:getPositionY() - _guildBangzhu:getContentSize().height - 3))
    self._leftbg:addChild(_guildMember)
	--_guildMember:enableBold()

    local _memberNumberStr = XTHDLabel:create(self.guildData.curSum .. "/" .. self.guildData.maxSum,self._fontSize - 6)
    self.memberNumberStr = _memberNumberStr
    _memberNumberStr:setColor(cc.c3b(46,1,1))
    _memberNumberStr:setAnchorPoint(1,0.5)
    _memberNumberStr:setPosition(cc.p(_nameLable:getPositionX(), _guildMember:getPositionY()))
    self._leftbg:addChild(_memberNumberStr)
	--_memberNumberStr:enableBold()

	--帮派战力
	local _guildZhanli = XTHDLabel:create("帮派战力：",self._fontSize - 6,"res/fonts/def.ttf")
    _guildZhanli:setColor(cc.c3b(46,1,1))
    _guildZhanli:setAnchorPoint(cc.p(0,0.5))
    _guildZhanli:setPosition(cc.p(_guildMember:getPositionX(), _guildMember:getPositionY() - _guildMember:getContentSize().height - 3))
    self._leftbg:addChild(_guildZhanli)
	--_guildZhanli:enableBold()

	local powerLable = XTHDLabel:create(self.guildData.power,self._fontSize - 6,"res/fonts/def.ttf")
	powerLable:setColor(cc.c3b(46,1,1))
	powerLable:setAnchorPoint(1,0.5)
	powerLable:setPosition(cc.p(_memberNumberStr:getPositionX(), _guildZhanli:getPositionY()))
	--powerLable:enableBold()
	self._leftbg:addChild(powerLable)

	local btnNameList = {"guildList_","guildIncident_","guildShop_","guildQuit_"}
	for i = 1,#btnNameList do
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/newGuild/"..btnNameList[i].."1.png",
			selectedFile = "res/image/newGuild/"..btnNameList[i].."2.png",
		})
		self._leftbg:addChild(btn)
		btn:setPosition(55 + btn:getContentSize().width *0.5 + ((i-1) *(btn:getContentSize().width + 15)),btn:getContentSize().height *0.5 + 30)
		btn:setTouchEndedCallback(function()
			if i == 1 then
				 self:setBtnCallback(5)
			elseif i == 2 then
				self:setBtnCallback(3)
			elseif i == 3 then
				self:setBtnCallback(2)
			elseif i == 4 then
				self:exitGuildCallBack()
			end
		end)
	end

    self:createGuildNotification()

    --帮派按钮
	local _btnPosY = 15
    local _btnposX = 0
   
    XTHD.addEventListener({name = "GuildApply",callback = function( event )
        if event.data.name == "Apply" then
			if event.data.name == "Apply" and self.red_point ~= nil then
               self.red_point:setVisible(event.data.visible)
			end
        end
    end})

    --监听
    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_INFO ,node = self,callback = function(event)
            self:resetGuildData()
            self:refreshGuildInfoLayer()
        end})
    --刷新成员列表
    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST ,node = self,callback = function(event)
            self:resetGuildData()
            self:refreshGuildListLayer()
        end})
    --被移除帮派
    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_GUILDINFO ,node = self,callback = function(event)
            self:refreshGuildState()
        end})
	self:createUI(1)
end

--创建右边UI
function BangPaiMain:createUI(index)
	self._rightbg:removeAllChildren()
	if index == 1 then
		self:createZhuYeUI()
	elseif index == 2 then
		self:createChengYuanUI()
	elseif index == 3 then
		self:createShenQingLieBiaoUI()
	elseif index == 4 then
		self:createGuanLiUI()
	end
end

function BangPaiMain:createZhuYeUI()
	local juanxianbg = cc.Sprite:create("res/image/newGuild/donatebg.png")
	self._rightbg:addChild(juanxianbg)
	juanxianbg:setPosition(self._rightbg:getContentSize().width *0.5, self._rightbg:getContentSize().height - juanxianbg:getContentSize().height *0.5)

	self:initRankList(juanxianbg)

	local btn_rank = XTHDPushButton:createWithParams({
        normalFile = "res/image/newGuild/btn_paiming_down.png",
		selectedFile = "res/image/newGuild/btn_paiming_up.png",
	})
	juanxianbg:addChild(btn_rank,2)
	btn_rank:setPosition(juanxianbg:getContentSize().width *0.5,btn_rank:getContentSize().height *0.5)	
	btn_rank:setTouchEndedCallback(function()
		local layer = requires("src/fsgl/layer/BangPai/BaiPaiPaiHangBang.lua"):create(self._rankListData)
		self:addChild(layer,2)
		layer:show()
	end)
	
	local bangpaihuodong = requires("src/fsgl/layer/BangPai/BangPaiHuoDong.lua")
	local pos = cc.p(self._rightbg:getContentSize().width *0.5,220 *0.5)
	local pLay = bangpaihuodong:create(self,pos)
    self._rightbg:addChild(pLay)
	pLay:setPosition(self._rightbg:getContentSize().width *0.5,pLay:getContentSize().height *0.5)
end

function BangPaiMain:createChengYuanUI()
	local _listPosY = 65
    local _distance = 32
    local _imgKeyTable = { "member", "level", "duty","allContribute","finallyLogin"}
    local _linePosX = 45

    local _tabWidth = 135
	local _linePosY = self._rightbg:getContentSize().height - 40
    for i = 1,#_imgKeyTable do
		local nomalNode = cc.Sprite:create("res/image/common/btn/btn_shouji_up.png")
		nomalNode:setContentSize(nomalNode:getContentSize().width*0.45,nomalNode:getContentSize().height*0.6)
		local selectNode = cc.Sprite:create("res/image/common/btn/btn_shouji_down.png")
		selectNode:setContentSize(selectNode:getContentSize().width*0.45,selectNode:getContentSize().height*0.6)
		
        local _btn = XTHD.createButton({
            normalNode = nomalNode,
            selectedNode = selectNode,
            text = LANGUAGE_GUILDTITLE_KEY[_imgKeyTable[i]],
            fontSize = 14,
            fontColor = cc.c3b(56,14,14),
        })
        _btn:setAnchorPoint(cc.p(0.5, 0))
        if(i > 1) then
            _btn:setPosition(cc.p(_linePosX + 50, _linePosY))
            self.verticalPos[i] = _linePosX + 50
        else
            _btn:setPosition(cc.p(_linePosX, _linePosY))
            self.verticalPos[i] = _linePosX
        end
        _btn:setTouchEndedCallback(function()
            self:setSelectedCallBack(i)
        end)
        self._rightbg:addChild(_btn)

        _linePosX = _tabWidth * 0.61* i
    end

	 --list
    local _tableViewSize = cc.size(self._rightbg:getContentSize().width, self._rightbg:getContentSize().height - 54)
    local _tableViewCellSize = cc.size(_tableViewSize.width,35)
    self.tableViewCellSize = _tableViewCellSize
    local _tableView = CCTableView:create(_tableViewSize)
    TableViewPlug.init(_tableView)
    self.memberListTabelView = _tableView
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setBounceable(true)
    _tableView:setDelegate()
    _tableView:setPosition(cc.p(0,4))
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._rightbg:addChild(_tableView)

    local function numberOfCellsInTableView(table_view)
        return #self.guildData.list
    end
    local function cellSizeForTable(table_view, idx)
        return _tableViewCellSize.width,_tableViewCellSize.height
    end
    local function tableCellTouched(table, cell)
        local _charId = cell.charId
        if _charId~=nil and tonumber(_charId)~=tonumber(gameUser.getUserId()) then
            HaoYouPublic.showFirendInfo(_charId,self)
        end
    end
    local function tableCellAtIndex(table_view, idx)
        local cell = table_view:dequeueCell()
        if cell then
            cell.charId = nil
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
        end
        local _cellBg = self:createCellSprite(idx+1)
        _cellBg:setPosition(cc.p(_tableViewCellSize.width/2,_tableViewCellSize.height/2+0.5))
        cell:addChild(_cellBg)
        cell.charId = self.guildData.list[tonumber(idx+1)].charId
        return cell
    end
    _tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView.getCellNumbers=numberOfCellsInTableView
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView.getCellSize=cellSizeForTable
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    
    _tableView:reloadData()

end

function BangPaiMain:createShenQingLieBiaoUI()
	ClientHttp.httpApplyJoinGuildList( self, function(data)
		local _layer = requires("src/fsgl/layer/BangPai/BangPaiShenQingLieBiao.lua"):create(data)
		self._rightbg:addChild(_layer)
		_layer:setPosition(self._rightbg:getContentSize().width *0.5,self._rightbg:getContentSize().height *0.5)
	end)
end

function BangPaiMain:createGuanLiUI()
	local layer = requires("src/fsgl/layer/BangPai/BangPaiGuanLi.lua"):create(self.guildData)
	self._rightbg:addChild(layer)
	layer:setPosition(self._rightbg:getContentSize().width *0.5,self._rightbg:getContentSize().height*0.5)
end


-- 公会成员数据按照等级排序
function BangPaiMain:sortGuildLevel()
    table.sort( self.guildData.list, function (a, b)
        return a.level > b.level
    end )
end

-- 公会成员数据按照职务排序
function BangPaiMain:sortGuildDuty()
    table.sort( self.guildData.list, function (a, b)
        return a.roleId < b.roleId
    end )
end

-- 公会成员数据按照段位排名排序
function BangPaiMain:sortGuildPvpRank()
    table.sort( self.guildData.list, function (a, b)
        if a.duanId == b.duanId then 
            return a.rank < b.rank
        else 
            return a.duanId > b.duanId
        end
    end )
end

-- 公会成员数据按照贡献排序
function BangPaiMain:sortGuildContribute()
    table.sort( self.guildData.list, function (a, b)
        return a.dayContribution > b.dayContribution
    end )
end

--公会成员数据按照总贡献排序
function BangPaiMain:sortAllContribute()
    table.sort( self.guildData.list, function (a, b)
        return a.totalContribution > b.totalContribution
    end )
end

--公会成员数据按照时间排序
function BangPaiMain:sortDiffTime()
    table.sort( self.guildData.list, function (a, b)
        return a.diffTime < b.diffTime
    end )
end

-- 点击按钮回调
-- type 代表当前是什么类型
function BangPaiMain:setSelectedCallBack(type) 
    --1、玩家名称  2、等级 3、职务 4、段位排名 5、今日贡献 6、累计贡献  7、最后登录
    if type == 2 then 
        self:sortGuildLevel()
    elseif type == 3 then
        self:sortGuildDuty()
    elseif type == 4 then
		self:sortAllContribute()
        --self:sortGuildPvpRank()
    elseif type == 5 then
		self:sortDiffTime()
        --self:sortGuildContribute()
    elseif type == 6 then
        --self:sortAllContribute()
    elseif type == 7 then
        --self:sortDiffTime()
    end

    self:refreshGuildListLayer()
	self.memberListTabelView:reloadData()
    for k,v in pairs(self.guildData.list) do
        for value in pairs(v) do
            print("value:"..value)
        end
    end
end

function BangPaiMain:createGuildNotification()
    local _distance = 7
    local _posX = 440
    local _notifi_h = 300
    local _notifi_w = self:getContentSize().width - _posX - _distance-220
 
    local _notificateSize = cc.size(_notifi_w,120)
    local _notificateBg = cc.Sprite:create("res/image/newGuild/gonggaokuang.png")
    self.notificateBg = _notificateBg
    _notificateBg:setPosition(cc.p(_notificateBg:getContentSize().width *0.5 + 55,self._leftbg:getContentSize().height*0.5 - 20))
    self._leftbg:addChild(_notificateBg)
	
    local _notificateLabel = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildDefaultNotificationTextXc,self._fontSize-6,"res/fonts/def.ttf")
    _notificateLabel:setDimensions(230,100)
    _notificateLabel:setColor(cc.c3b(46,1,1))
    _notificateLabel:setAnchorPoint(cc.p(0,1))
    _notificateLabel:setPosition(cc.p(15,self.notificateBg:getContentSize().height - 25))
	--_notificateLabel:enableBold()
    _notificateBg:addChild(_notificateLabel)
    self.notificatelabel = _notificateLabel
    if self.guildData.notice~=nil and string.len(self.guildData.notice)>0 then
        _notificateLabel:setString(self:FunSetLinefeed(self.guildData.notice,22))
    end

    self:refreshNotificationState()

end

function BangPaiMain:initRankList(node)
	 ClientHttp:requestAsyncInGameWithParams({
        modules="guildWorshipRanks?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
				-- dump(data)
				self._rankListData = data.ranks
				self:createRankList(node)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,             --需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE, --加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    })
end

function BangPaiMain:updateRankList()
	ClientHttp:requestAsyncInGameWithParams({
        modules="guildWorshipRanks?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
				-- dump(data)
				self._rankListData = data.ranks
				if self._rankTableView then
					self._rankTableView:reloadData()
				end
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,             --需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE, --加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    })
end

function BangPaiMain:createRankList(node)
	local size = cc.size(node:getContentSize().width - 45, node:getContentSize().height - 30)
	local rankTableView = cc.TableView:create(size)
	rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL );
    rankTableView:setPosition( cc.p(22, 15));
    rankTableView:setBounceable(true)
	rankTableView:setDirection(ccui.ScrollViewDir.vertical)
	rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	rankTableView:setDelegate()
	self._rankTableView = rankTableView
	node:addChild(rankTableView)

	local function numberOfCellsInTableView( table )
        return #self._rankListData
    end
	local cellSize = cc.size(node:getContentSize().width,40)
    local function cellSizeForTable( table, idx )
		return cellSize.width,cellSize.height
    end

    local function tableCellAtIndex( table, idx )
		local index = idx + 1
        local cell = cc.TableViewCell:new()
	
		--昵称
		local nameLable = XTHDLabel:create(self._rankListData[index].charName,16,"res/fonts/def.ttf")
		nameLable:setColor(cc.c3b(107,70,43))
		nameLable:setAnchorPoint(0,0.5)
		nameLable:setPosition(60,cell:getContentSize().height /2 + 15)
		cell:addChild(nameLable)
	
		local GXLable = XTHDLabel:create(tostring(self._rankListData[index].totalContribution),16,"res/fonts/def.ttf")
		GXLable:setColor(cc.c3b(107,70,43))
		GXLable:setAnchorPoint(cc.p(1,0.5))
		GXLable:setPosition(cc.p(350,cell:getContentSize().height/2 + 15))
		cell:addChild(GXLable)
	
		 -- 排名icon
        local rankIcon = XTHD.createSprite()
        rankIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
        rankIcon:setPosition( 30, cell:getContentSize().height*0.5 + 3 +15)
        cell:addChild( rankIcon )
		
    	local rankNum = cc.Label:createWithBMFont( "res/fonts/paihangbangword.fnt", 0 )
		rankNum:setScale(0.8)
	    rankNum:setPosition( 30, cell:getContentSize().height*0.5 - 4 +17 )
	    cell:addChild( rankNum )
	    rankNum:setString( index )

		local _scale = 1
		if index < 10 then
			local rankIconPath = ""
			if index <= 3 then
				_scale = 0.6
				rankIconPath = "res/image/ranklistreward/"..( index)..".png"
				rankNum:setVisible(false)
			else
				_scale = 0.5
				rankIconPath = "res/image/ranklist/rank_4.png"
				rankNum:setVisible(true)
			end
			rankIcon:setTexture( rankIconPath )
			rankIcon:setScale(_scale)
			rankIcon:setVisible( true )
		else
			rankIcon:setVisible( false )
		end

		return cell
    end

    rankTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	rankTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	rankTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	rankTableView:reloadData()

end

 --强制换行函数
 function BangPaiMain:FunSetLinefeed( strText, nLineWidth ) --文本，行宽  
    --读取每个字符做中文英文判断，并且记录大小  
    local nStep = 1  
    local index = 1  
    local ltabTextSize = {}  
    while true do  
        c = string.sub(strText, nStep, nStep)  
        b = string.byte(c)  
  
        if b > 128 then  
            -- ltabTextSize[index] = 3  
            -- nStep = nStep + 3  
            -- index = index + 1 
            return strText
        else 
            ltabTextSize[index] = 1 
            nStep = nStep + 1
            index = index + 1 
            if string.len( strText ) < nLineWidth then
                return strText
            end
        end  
  
        if nStep > #strText then  
            break  
        end  
    end  
      
    --将字符按照限定行宽进行分组  
    local nLineCount = 1  
    local nBeginPos = 1  
    local lptrCurText = nil  
    local ltabText = {}  
    local nCurSize = 0  
    for i = 1, index - 1 do  
        nCurSize = nCurSize + ltabTextSize[i]  
        print("%%%:" .. nCurSize .. "**:" .. i)
        if nCurSize > nLineWidth then  
            print("进不来的啊")
            nCurSize = nCurSize - ltabTextSize[i]  
            ltabText[nLineCount] = string.sub( strText, nBeginPos, nBeginPos + nCurSize - 1 )  
            nBeginPos = nBeginPos + nCurSize  
            nCurSize = ltabTextSize[i]  
            nLineCount = nLineCount + 1 
        end  
    end  
    for i = 1, nLineCount - 1 do  
        print("&&&&&&:" .. i)
        if lptrCurText == nil then  
            lptrCurText = ltabText[i]  
        else  
            lptrCurText = lptrCurText .. "\n" .. ltabText[i]  
        end  
    end  
    return lptrCurText  
end 


function BangPaiMain:createCellSprite(_idx)
    local _distance = 0
    local _memberBg = BangPaiFengZhuangShuJu.createListCellBg(cc.size(self.tableViewCellSize.width - _distance*2  - 20,self.tableViewCellSize.height - 3*2),_idx)
	
    local _memberData = self.guildData.list[tonumber(_idx)] or {}
    if next(_memberData)==nil then
        return _memberBg
    end

    local _labelKeyTable = { "name", "level", "roleId","totalContribution","diffTime"}
    local _linePosX = 0-_distance
    local _linePosY = _memberBg:getContentSize().height/2
    local _labelPosXTable = {}
    local _labelPosY = _memberBg:getContentSize().height/2-1
    for i=1,#self.verticalPos do
        _labelPosXTable[i] = self.verticalPos[i]
        local _labelStr = _memberData[_labelKeyTable[i]] or ""
        local _fontSize = 14
        if i ==1 then
        elseif i == 3 then
            local _permissionid = tonumber(_memberData[_labelKeyTable[i]])
            _labelStr = LANGUAGE_GUILD_PERMISSION[_permissionid]
        elseif i == 5 then
            local _state = tonumber(_memberData[_labelKeyTable[i]])
            if _state == 0 then
                _labelStr = LANGUAGE_NAMES.online       -- 在线
            else
                _labelStr = XTHD.getTimeStrBySecond(tonumber(_memberData["diffTime"]))
            end
        end
        local _memberlabel = XTHDLabel:createWithSystemFont(_labelStr,"Helvetica",_fontSize)
		_memberlabel:setColor(cc.c3b(46,1,1))
        _memberlabel:setPosition(cc.p(self.verticalPos[i] - 10,_labelPosY))
        _memberBg:addChild(_memberlabel)  
		if i == 1 then
			_memberlabel:setAnchorPoint(0,0.5)
			_memberlabel:setPosition(cc.p(5,_labelPosY))
		end
    end
    return _memberBg
end

function BangPaiMain:setNotificateLabelString()
    self.notificatelabel:setVisible(true)
    if self.guildData.notice==nil or string.len(self.guildData.notice)<1 then
        self.notificatelabel:setString(LANGUAGE_KEY_GUILD_TEXT.guildDefaultNotificationTextXc)
    else
        self.notificatelabel:setString(self:FunSetLinefeed(self.guildData.notice,22))
        -- self.notificatelabel:setString(self.guildData.notice)
    end
end

function BangPaiMain:httpToExchangeNotice(_str)
    print("8431>>>>httpToExchangeNotice")
    if _str==nil or string.len(_str)<1 then
        self:setNotificateLabelString()
        return
    end
    ClientHttp.httpModifyGuildNotice( self, function(data)
--			print("修改帮派公告服务器返回的数据为：")
--			print_r(data)
            self.guildData.notice = tostring(data.content)
            self:setNotificateLabelString()
        end, {content = _str } )
end

function BangPaiMain:refreshGuildState()
    if tonumber(gameUser.getGuildId())<1 then
        self:exchangeGuildState()
    end
end

function BangPaiMain:exchangeGuildState()
    local confirmDialog = XTHDConfirmDialog:createWithParams({
        msg = LANGUAGE_KEY_GUILD_TEXT.guildDismissedFromGuildTextXc,
        leftVisible = false,
        fontSize = 22,
        closeCallback = function()
            LayerManager.addShieldLayout()
                BangPaiFengZhuangShuJu.createGuildLayer({parNode = self, callBack = function ( ... )
                    LayerManager.removeLayout()
                end})
        end
    })
    self:addChild(confirmDialog, 10)
end

---------------------------回调------------------------------
--{"activity","shop","log"}
function BangPaiMain:setBtnCallback(_idx)
    --
    if _idx==nil then
        return
    end
    local _index = tonumber(_idx)
    if _index == 1 then
        --帮派活动
        if tonumber(self.permissionData["right4"] or 0) ~=1 then
            XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildNoEnoughPermissionToastXc)
            return 
        end
        -- XTHDTOAST(LANGUAGE_TIPS_WORDS11)
        -- ClientHttp.httpGuildWorshipList(self,function ( sData )
        --     if tonumber(sData["result"]) == 0 then
                
        --     else
        --         XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        --     end
            
        -- end)
        local pLay = LayerManager.createModule("src/fsgl/layer/BangPai/BangPaiHuoDong.lua")
        if pLay then
            LayerManager.addLayout(pLay)
        end
        
    elseif _index == 2 then
        --帮派商店
        if tonumber(self.permissionData["right3"] or 0) ~=1 then
            XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildNoEnoughPermissionToastXc)
            return 
        end
        local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("guild")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
    elseif _index == 3 then
        --帮派日志
        ClientHttp.httpGuildLogList( self, function(data)
            local _logLayer = requires("src/fsgl/layer/BangPai/BangPaiShiJian.lua"):create(data)
            self:addChild(_logLayer, 1)
        end)
        
    elseif _index == 4 then
        --申请列表
        self:openApplyListCallback()
        self:RedPoint()
    elseif _index ==5 then
        --查看其他帮派
        self:lookOtherGuildCallback()
    end
end

--分是否是帮主。
function BangPaiMain:exitGuildCallBack()
    local show_msg = gameUser.getGuildRole() == 1 and LANGUAGE_KEY_GUILD_TEXT.guildExchangeStatusToOtherTextXc or LANGUAGE_KEY_GUILD_TEXT.guildIsExitTextXc
    local confirmDialog = XTHDConfirmDialog:createWithParams({
        msg = show_msg,
        rightText = gameUser.getGuildRole() == 1 and LANGUAGE_BTN_KEY.outPosition or nil,
        fontSize = 22,
        isHide = false
    })
    self:addChild(confirmDialog, 10)

    confirmDialog:setCallbackRight(function (  )
        if gameUser.getGuildRole() == 1 then
            local _fuData = {}
            local mParams = BangPaiFengZhuangShuJu.getGuildData()
            if mParams.list and #mParams.list > 0 then
                for k,v in pairs(mParams.list) do
                    if v.roleId == 2 then
                        _fuData[#_fuData + 1] = v
                    end
                end
            end
            if #_fuData == 0 then
                XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildNoInheritorToastXc)
            else
                requires("src/fsgl/layer/BangPai/BangZhuTuiWei.lua"):createOne(_fuData)
            end
        else
            ClientHttp.httpExitGuild(self, function ( sData )
                gameUser.setGuildId(0)
                gameUser.setGuildRole(0)
                gameUser.setGuildName("")
                LayerManager.addShieldLayout()
                BangPaiFengZhuangShuJu.createGuildLayer({parNode = self, callBack = function ( ... )
                    LayerManager.removeLayout()
                    XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildExitedToastXc)
                end})
            end) 
        end
        confirmDialog:removeFromParent()
    end)

    confirmDialog:setCallbackLeft(function (  )
        confirmDialog:removeFromParent()
    end)
end

--管理按钮回调
function BangPaiMain:setManageCallback()
     requires("src/fsgl/layer/BangPai/BangPaiGuanLi.lua"):createOne(self.guildData)
end
--申请列表按钮回调
function BangPaiMain:openApplyListCallback()
    ClientHttp.httpApplyJoinGuildList( self, function(data)
            local _layer = requires("src/fsgl/layer/BangPai/BangPaiShenQingLieBiao.lua"):create(data)
            LayerManager.addLayout(_layer)

        end)
end

function BangPaiMain:lookOtherGuildCallback()
    ClientHttp.httpGetGuildList(self, function( sData )
            local pLay = LayerManager.createModule("src/fsgl/layer/BangPai/BangPaiLieBiao.lua", sData)
            if pLay then
                LayerManager.addLayout(pLay)
            end
        end)
end

---------------------------刷新------------------------------
--刷新帮派详情界面
function BangPaiMain:refreshGuildInfoLayer()
    self:refreshGuildIcon()
    self:refreshExpValue()
    self:refreshGuildName()
	self:refreshGuildExp()
end

function BangPaiMain:refreshGuildExp()
	self._expLable:setString(tostring(self.guildData.curExp or 0) .." / " ..tostring(self.guildData.maxExp or 1))
end

function BangPaiMain:refreshGuildListLayer()
    self:refreshGuildMemberNumber()

    self:refreshNotificationState()
    self:refreshBtnState()
end

function BangPaiMain:refreshGuildIcon()
    if self.guildIconSp == nil or self.guildData.icon==nil then
        return 
    end
    if self.guildIconSp.guildIcon ~= nil and tonumber(self.guildIconSp.guildId) == self.guildData.icon then
        return
    end
    self.guildIconSp:removeFromParent()
    local _icon = self.guildData.icon
    self.guildIconSp = BangPaiFengZhuangShuJu.createGuildIcon(_icon,self.guildData.level or 1)
	self.guildIconSp:setScale(0.8)
    self.guildIconSp.guildIcon = _icon
    self.guildIconSp:setPosition(cc.p(self.guildIconSp:getContentSize().width *0.5 + 40,self._leftbg:getContentSize().height - self.guildIconSp:getContentSize().height *0.5 - 55))
    self._leftbg:addChild(self.guildIconSp)
end

function BangPaiMain:refreshExpValue()
    if self.expProgressBg ==nil then
        return
    end
    local _percentage = tonumber(self.guildData.curExp or 0)/tonumber(self.guildData.maxExp or 1) * 100
    if self.expProgressBg:getChildByName("expProgress") then
        self.expProgressBg:getChildByName("expProgress"):setPercentage(_percentage)
    end
    if self.expProgressBg:getChildByName("expLabel") then
        self.expProgressBg:getChildByName("expLabel"):setString(tonumber(self.guildData.curExp or 0) .. "/" .. tonumber(self.guildData.maxExp or 1))
    end
	if self._guildLevel then
		self._guildLevel:setString(self.guildData.level)
	end
end
function BangPaiMain:refreshGuildMemberNumber()
    if self.memberNumberStr ==nil then
        return
    end
    self.memberNumberStr:setString(self.guildData.curSum .. "/" .. self.guildData.maxSum)
end
function BangPaiMain:refreshGuildName()
    self.guildName:setString(self.guildData.guildName or "")
end

function BangPaiMain:refreshMemberList()
    self.memberListTabelView:reloadDataAndScrollToCurrentCell()
end

function BangPaiMain:refreshNotificationState()
    if self.permissionData["right7"]==nil or tonumber(self.permissionData["right7"])~=1 then
        if self.noticeEdit ~=nil then
            self.noticeEdit:removeFromParent()
            self.noticeEdit = nil
        end
        return
    end
    if self.noticeEdit ~=nil then
        return
    end
    if self.notificatelabel == nil or self.notificateBg == nil then
        return
    end
    local _noticeEdit = nil
    local function editBoxEventHandle(eventName,pSender)
        if eventName == "began" then
            pSender:setText(self.guildData.notice)
            self.notificatelabel:setVisible(false)
        elseif eventName == "ended" or eventName == "return" then
            local msgStr = pSender:getText()
            self.notificatelabel:setVisible(true)
            self:httpToExchangeNotice(msgStr)
            pSender:setText("")
        elseif eventName == "changed" then
        else
            self.notificatelabel:setVisible(true)
            self:httpToExchangeNotice(pSender:getText())
            pSender:setText("")
        end
    end
    self.noticeEdit = nil
    _noticeEdit = ccui.EditBox:create(cc.size(self.notificateBg:getContentSize().width - 30,self.notificateBg:getContentSize().height - 38),ccui.Scale9Sprite:create(),nil,nil)
    self.noticeEdit = _noticeEdit
    _noticeEdit:setFontName("Helvetica")
    _noticeEdit:setFontSize(self._fontSize - 2)
    _noticeEdit:setMaxLength(70) 
    _noticeEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    _noticeEdit:setFontColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _noticeEdit:registerScriptEditBoxHandler(editBoxEventHandle)
    _noticeEdit:setAnchorPoint(cc.p(0,0))
    _noticeEdit:setPosition(cc.p(16,13))
    self.notificateBg:addChild(_noticeEdit)

end
function BangPaiMain:refreshBtnState()
    if self.listBg == nil or self.applyListBtn ==nil or self.lookOtherGuildBtn == nil then
        return
    end

    --是否有申请列表操作权限
    if self.permissionData["right2"]==nil or tonumber(self.permissionData["right2"])~=1 then
        
        
        if self.applyListBtn:isVisible() == false then
            return
        else
            self.applyListBtn:setVisible(false)
            _btnposX = self.listBg:getContentSize().width - (3+135)*3
            self.lookOtherGuildBtn:setPositionX(_btnposX - 3)
        end
    else
        if self.applyListBtn:isVisible() == true then
            return
        else
            self.applyListBtn:setVisible(true)
            _btnposX = self.listBg:getContentSize().width - (3+135)*4
            self.lookOtherGuildBtn:setPositionX(_btnposX - 3)
        end
    end

end
---------------------------数据------------------------------
function BangPaiMain:resetGuildData()
    self:setGuildData()
    self:setGuildPermission()
	self:updateRankList()
end

function BangPaiMain:setGuildPermission()
    self.permissionData = {}
    self.myMemberData = {}
    local _charId = tonumber(gameUser.getUserId())
    local _permissionId = 6

    if self.guildData.list == nil or #self.guildData.list <1 then
        return 
    end
    for i=1,#self.guildData.list do
        if tonumber(self.guildData.list[i].charId) == _charId then
            self.myMemberData = self.guildData.list[i]
            break
        end
    end
    _permissionId = self.myMemberData.roleId or 6
    if tonumber(_permissionId) == 1 then
        self.isMaster = true
    end
    local _table = gameData.getDataFromCSV("SectPosition") or {}
    local _permissionData = _table[tonumber(_permissionId)] or 0
    self.permissionData = _permissionData
end

function BangPaiMain:setGuildData()
    self.guildData = {}
    local _data = BangPaiFengZhuangShuJu.getGuildData()
    if _data == nil then
        return 
    end
    self.guildData = _data
    local _charId = tonumber(gameUser.getUserId())
    table.sort(self.guildData.list,function(data1,data2)
            if tonumber(data1.charId) == _charId then
                return true
            elseif tonumber(data2.charId) == _charId then
                return false
            end
            local _data1Number = tonumber(data1.onlineState) + tonumber(data1.roleId)*10 + tonumber(data1.diffTime)*100
            local _data2Number = tonumber(data2.onlineState) + tonumber(data2.roleId)*10 + tonumber(data2.diffTime)*100

            if _data1Number == _data2Number then
                if tonumber(data1.dayContribution)==tonumber(data2.dayContribution) then
                    return tonumber(data1.charId)<tonumber(data2.charId)
                else
                    return tonumber(data1.dayContribution)>tonumber(data2.dayContribution)
                end
            else
                return _data1Number<_data2Number
            end
        end)
    self.guildData.curSum = #self.guildData.list
	local power = 0
	for i = 1, self.guildData.curSum do
		if self.guildData.list[i].roleId == 1 then
			self.guildData.bangzhuName = self.guildData.list[i].name
		end
		power = power + self.guildData.list[i].power
	end
	self.guildData.power = power
end

function BangPaiMain:createForLayerManager( sParams )
	local pLay = BangPaiMain.new()
	pLay:init(sParams)
	return pLay
end

function BangPaiMain:onEnter( )
--    YinDaoMarg:getInstance():addGuide({parent = self,index = 3},8)----剧情
--    YinDaoMarg:getInstance():doNextGuide() 
end
function BangPaiMain:RedPoint()
    --判断加不加红点
    ClientHttp.httpApplyJoinGuildList( self, function(data)
            if #data.list >=1 then
                XTHD.dispatchEvent({name = "GuildApply",data = {["name"] = "Apply",["visible"] = true}})
            -- else
            --     XTHD.dispatchEvent({name = "GuildApply",data = {["name"] = "Apply",["visible"] = false}})
            end
        end)    
end

function BangPaiMain:onCleanup( )	
	musicManager.playMusic(XTHD.resource.music.music_bgm_main )
   XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_CHONGZHIFANLI)
end

return BangPaiMain