-- 冲榜活动界面

QuanmingjingjiActivityLayer = class("QuanmingjingjiActivityLayer",function(param)
	return XTHD.createPopLayer()
end)

function QuanmingjingjiActivityLayer:ctor()
	self._ActivityBtn = {}
	self._ActivityList = {}
	self._btnBg = {}
	self._JiangLi = {}
	self._nowSelected = 1
	self._countDown = self._data.activityEndTime /1000 - os.time()
	local activityStatic = {
		--竞技
		[1] = {
            urlId      = 32,
            priority   = 120,
            isOpen     = 0,                     -- 0：根据isOpenid控制活动是否开启，1：长期开启，不判断isOpenid
            isOpenid   = 32,                     -- 活动开启id，后端控制
            pictureid  = 32,
            redPointid = 32,
			_type		= 12,
        },
    }
	self._activityOpen = {}
	local _openState = gameUser.getActivityOpenStatus() or {}
	for k,v in pairs(activityStatic) do
		if tonumber(v.isOpen) == 1 then
			self._activityStatus[# self._activityStatus + 1] = v
		else
			local activityState = _openState[tostring( v.isOpenid or 0 )] or 0
			if activityState == 1 then
				self._activityOpen[#self._activityOpen + 1] = v
			end
		end
	end
	-- dump(self._activityStatus)
	table.sort(self._activityOpen,function(data1,data2)
            return tonumber(data1.priority) < tonumber(data2.priority)
        end)
	self._activityOpen = activityStatic
    self._tabNumber = table.nums(self._activityOpen)	
	
	self._canClick = false
	----背景
	local bg = cc.Sprite:create("res/image/activities/chongbang/chongbangbg_1.png" )
	bg:setAnchorPoint(cc.p(0.5, 0.5))
	local winSize = cc.Director:getInstance():getWinSize()	
	self:setContentSize(cc.size(winSize.width, winSize.height))
	bg:setScale(1)
    bg:setPosition(cc.p(winSize.width / 2, winSize.height / 2))

	local title = cc.Sprite:create("res/image/activities/quanmingjingji/jingji_title.png" )
	bg:addChild(title)
	title:setPosition(bg:getContentSize().width *0.5 + 15,bg:getContentSize().height - title:getContentSize().height*0.5 - 5)
    
	-- 关闭按钮
	local _normalFile = "res/image/ziyuanzhaohui/zyguan_up.png"
	local _selectFile = "res/image/ziyuanzhaohui/zyguan_down.png"

	local _back = XTHDPushButton:createWithParams({
		normalFile = _normalFile,
		selectedFile = _selectFile,
		musicFile = XTHD.resource.music.effect_btn_commonclose,
		endCallback = function ()
			self:stopActionByTag(10)
			self:hide()
		end
	})
	_back:setPosition(cc.p(bg:getContentSize().width - 30, bg:getContentSize().height - 80))

	bg:addChild(_back)
	self:addContent(bg)
    self.bg = bg

	local bg_2 = cc.Sprite:create("res/image/activities/chongbang/chongbangbg_2.png" )
	bg_2:setAnchorPoint(cc.p(0.5, 0.5))
	self.bg:addChild(bg_2)
    bg_2:setPosition(cc.p(self.bg:getContentSize().width - bg_2:getContentSize().width + 30, self.bg:getContentSize().height / 2 - 30))
	
	--我要变强按钮
	local btn_bianqiang = XTHDPushButton:createWithParams({
		normalFile = "res/image/activities/chongbang/btn/bianqiang_1.png",
		selectedFile = "res/image/activities/chongbang/btn/bianqiang_2.png",
		endCallback = function ()
			self:ShowBianQiang()
		end
	})
	bg_2:addChild(btn_bianqiang)
	btn_bianqiang:setPosition(bg_2:getContentSize().width / 2,btn_bianqiang:getContentSize().height - 25)

	local btn_rank = XTHDPushButton:createWithParams({
		normalFile = "res/image/activities/chongbang/btn/rankbtn_1.png",
		selectedFile = "res/image/activities/chongbang/btn/rankbtn_2.png",
		endCallback = function ()
			self:ShowRank()
		end
	})
	self.bg:addChild(btn_rank)
	btn_rank:setPosition(self.bg:getContentSize().width - btn_rank:getContentSize().width - 40,btn_rank:getContentSize().height + 5)

	local myRankLable = XTHDLabel:create(tostring(10000),20,"res/fonts/def.ttf")
	myRankLable:setColor(XTHD.resource.textColor.green_text)
	bg_2:addChild(myRankLable)
	myRankLable:setPosition(cc.p(bg_2:getContentSize().width / 2,bg_2:getContentSize().height /2 + 78))
	self._myRankLable = myRankLable
	
	local powerLable =  XTHDLabel:create("",20,"res/fonts/def.ttf")
	powerLable:setColor(XTHD.resource.textColor.green_text)
	bg_2:addChild(powerLable)
	powerLable:setPosition(cc.p(bg_2:getContentSize().width / 2,bg_2:getContentSize().height /2))
	self._powerLable = powerLable

	--

	local ActivityTime = XTHDLabel:create("活动剩余时间：",20,"res/fonts/def.ttf")
	ActivityTime:setColor(cc.c3b(92,45,7))
	self.bg:addChild(ActivityTime)
	ActivityTime:setPosition(self.bg:getContentSize().width / 2 - ActivityTime:getContentSize().width / 2 ,55)
	self._ActivityTime = ActivityTime
		
	local time = LANGUAGE_KEY_CARNIVALDAY(self._countDown)
	local TimeLable = XTHDLabel:create(time,20,"res/fonts/def.ttf")
	TimeLable:setAnchorPoint(0,1)
	TimeLable:setColor(cc.c3b(92,45,7))
	ActivityTime:addChild(TimeLable)
	TimeLable:setPosition( ActivityTime:getContentSize().width - 10,TimeLable:getContentSize().height)
	self._endTimeLable = TimeLable

	local tip = XTHDLabel:create("活动结束后奖励将通过邮件发放",16,"res/fonts/def.ttf")
	tip:setAnchorPoint(0,1)
	tip:setColor(cc.c3b(92,45,7))
	self.bg:addChild(tip)
	tip:setPosition(self.bg:getContentSize().width / 2 - ActivityTime:getContentSize().width / 2 - 30 ,35)

	self._title = cc.Sprite:create("res/image/activities/quanmingjingji/logo_1.png")
	bg_2:addChild(self._title)	
	self._title:setPosition(bg_2:getContentSize().width / 2,bg_2:getContentSize().height /2 + 40)

	self:initBtnTableView()
	self:initJLTableView(1)
	self:updateTime()
	--self:initJLTableView(1)
end

function QuanmingjingjiActivityLayer:initBtnTableView()
	local scorllRect = ccui.ListView:create()
    scorllRect:setContentSize(cc.size(590, 70))
    scorllRect:setDirection(ccui.ScrollViewDir.horizontal)
    scorllRect:setBounceEnabled(true)
	scorllRect:setScrollBarEnabled(false)
	scorllRect:setSwallowTouches(true)
    self.bg:addChild(scorllRect,10)
    scorllRect:setPosition(cc.p(self.bg:getContentSize().width /4 + 5, self.bg:getContentSize().height - 155))
    self.scorllRect = scorllRect
	
	local iconWidth = 140
    for i, v in ipairs( self._activityOpen ) do
    	local layout = ccui.Layout:create()
		layout:setContentSize(130,45)

		local _activityData = self._activityOpen[i] or {}
		
		local name1,name2
		name1 = string.format("res/image/activities/chongbang/btn/btn_%d_1.png",_activityData.urlId)
        local btn = XTHDPushButton:createWithParams({
			normalFile = name1,
			selectedFile = name1,
			isScrollView = true,
		})
		layout:addChild(btn)
		btn:setPosition(cc.p(btn:getContentSize().width / 2 + 10 ,layout:getContentSize().height/2 + 10))
		btn:setTag(i)
		btn:setSwallowTouches(false)
		btn:setTouchBeganCallback(function()
			for i = 1,#self._btnBg do
				self._btnBg[i]:setVisible(false)
			end
			print("=========================>>>>>>>",btn:getTag())
			self._btnBg[btn:getTag()]:setVisible(true)
		end)
		
		btn:setTouchEndedCallback(function()
			self:ChongBangRank(btn:getTag())
			--self:initJLTableView(btn:getTag())
		end)
		
		name1 = string.format("res/image/activities/chongbang/btn/btn_%d_2.png",_activityData.urlId)
		local btnBg = cc.Sprite:create(name1)
		btn:addChild(btnBg)
		btnBg:setPosition(btn:getContentSize().width / 2,btn:getContentSize().height / 2)
		btnBg:setName("btnBg")
		btnBg:setVisible(false)
		self._btnBg[#self._btnBg + 1] = btnBg
		
		self.scorllRect:pushBackCustomItem(layout)
	end
end

function QuanmingjingjiActivityLayer:initJLTableView(index)
	local rivalRankList = {"青铜组","白银组","黄金组","白金组","钻石组","至尊组","王者组"}
	self._myRankLable:setString(tostring(self._data.rivalRank))
	self._powerLable:setString(rivalRankList[self._data.duanId])
	if tonumber(self._data.myData) == 0 then
		self._myRankLable:setString("未上榜")
	else
		self._myRankLable:setString(tostring(self._data.myRank))
	end
	--self._powerLable:setString(tostring(self._data.myData))
	if self._data.myRank and self._rankList == nil or #self._rankList < 1 then
		self._myRankLable:setString("未上榜")
	end 

	local name = string.format("res/image/activities/quanmingjingji/logo_%d.png",index)
	self._title:setTexture(name)
	local _type = self._activityOpen[index]._type
	local JiangLiList = gameData.getDataFromCSV("Leaderboard",{type = _type})
	
	if self._JLtableview then
		self._JLtableview:removeFromParent()
		self._JLtableview = nil
	end
	local tableView = cc.TableView:create(cc.size(403,295))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL );
    tableView:setPosition( cc.p(self.bg:getContentSize().width /4 + 5, 75));
    tableView:setBounceable(true)
	tableView:setDirection(ccui.ScrollViewDir.vertical)
	tableView:setDelegate()
	--tableView:setScrollBarEnabled(false)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.bg:addChild(tableView);
    self._JLtableview = tableView

	local function numberOfCellsInTableView( table )
        return #JiangLiList
    end

    local function cellSizeForTable( table, idx )
		return tableView:getContentSize().width - 5,110
    end

    local function tableCellAtIndex( table, idx )
		print("==================",idx)
		self._ActivityList = {}
		local index = idx + 1
        local cell = cc.TableViewCell:new()
        cell:setContentSize(table:getContentSize().width - 5,110)
		local cellbg = cc.Sprite:create("res/image/activities/chongbang/chongbangbg_3.png")
		cell:addChild(cellbg)
		cellbg:setPosition(cellbg:getContentSize().width/2,cellbg:getContentSize().height/2)
		if index <= 3 then
			local text = nil
			if index == 1 then
				text = "第一名："
			elseif index == 2 then
				text = "第二名："
			else
				text = "第三名："
			end
			local lable = XTHDLabel:create(text, 20, "res/fonts/def.ttf")
			lable:setColor(cc.c3b(0,0,0))
			cellbg:addChild(lable)
			lable:setAnchorPoint(cc.p(0,0.5))
			lable:setPosition(30,cellbg:getContentSize().height - lable:getContentSize().height - 5)
			
			local name
			if self._nowSelected ~= 15 then
				if self._rankList ~= nil and self._rankList[index]~= nil then
					name = self._rankList[index].charName
				else
					name= ""
				end
			else
				if self._rankList ~= nil and self._rankList[index]~= nil then
					name = self._rankList[index].guildName
				else
					name= ""
				end
			end
			local nameLable = XTHDLabel:create(name, 20, "res/fonts/def.ttf")
			nameLable:setColor(cc.c3b(0,0,0))
			cellbg:addChild(nameLable)
			nameLable:setAnchorPoint(cc.p(0,0.5))
			nameLable:setPosition(lable:getContentSize().width + 35,cellbg:getContentSize().height - lable:getContentSize().height - 5)
			nameLable:setName("nameLable")
			if self._nowSelected == 14 then
				--GeneralShow
				if self._rankList[index] then
					local heroData = gameData.getDataFromCSV("GeneralShow",{heroid = self._rankList[index].petId})
					local heroName = XTHDLabel:create("(" .. heroData.name .. ")",16,"res/fonts/def.ttf")
					heroName:setAnchorPoint(0,0.5)
					heroName:setColor(XTHD.resource.textColor.green_text)
					cellbg:addChild(heroName)
					heroName:setPosition(nameLable:getPositionX() + nameLable:getContentSize().width + 15,nameLable:getPositionY())
				end	
			end
		else
			local str =nil
			local _data = string.split(JiangLiList[index].order,"#")
			if _data[1] ~= _data[2] then
				str = string.format("第%d名 ~ 第%d名：",_data[1],_data[2])
			else
				str = string.format("第%d名:",_data[1],_data[2])
			end
			local lable = XTHDLabel:create(str, 20, "res/fonts/def.ttf")
			lable:setColor(cc.c3b(0,0,0))
			cellbg:addChild(lable)
			lable:setAnchorPoint(cc.p(0,0.5))
			lable:setPosition(30,cellbg:getContentSize().height - lable:getContentSize().height - 5)
		end
		
		local btn_lingqu = XTHDPushButton:createWithParams({
			normalFile = "res/image/activities/chongbang/btn/lingqu_1.png",
			selectedFile = "res/image/activities/chongbang/btn/lingqu_2.png",
			isScrollView = true,
			endCallback = function ()
				XTHDTOAST("活动结束后奖励将通过邮件发放")
			end
		})
		cellbg:addChild(btn_lingqu)
		btn_lingqu:setPosition(cellbg:getContentSize().width - btn_lingqu:getContentSize().width + 10,cellbg:getContentSize().height / 2 - 15)	
		btn_lingqu:setVisible(false)	

		local list = JiangLiList[index]

		if list.rewardingot > 0 then
			local item = ItemNode:createWithParams({
				 --dbId = nil,
				-- itemId = _itemData and _itemData.reward1id or 0,
				_type_ = 3,
				showDrropType = 2,
				 count = list.rewardingot
			})
			self._ActivityList[#self._ActivityList + 1] = item
		end
		if list.rewardgold > 0 then
			local item = ItemNode:createWithParams({
				 _type_ = 2,
				showDrropType = 2,
				 count = list.rewardgold
			})
			self._ActivityList[#self._ActivityList + 1] = item
		end
		if list.rewardjade > 0 then
			local item = ItemNode:createWithParams({
			 _type_ = 6,
			showDrropType = 2,
			 count = list.rewardjade
			})
			self._ActivityList[#self._ActivityList + 1] = item
		end
		if list.rewardfaction > 0 then
			local item = ItemNode:createWithParams({
			 _type_ = 203,
			showDrropType = 2,
			 count = list.rewardfaction
			})
			self._ActivityList[#self._ActivityList + 1] = item
		end

		for i = 1, 4 do
			if list["reward"..i.."num"] > 0 then 
				local item = ItemNode:createWithParams({
					 itemId = list["reward"..i.."id"],
					 _type_ = list["reward"..i.."type"],
					 count = list["reward"..i.."num"],
					showDrropType = 2,
				})
				self._ActivityList[#self._ActivityList + 1] = item
			end
		end
		
		for i = 1, #self._ActivityList do
			self._ActivityList[i]:setScale(0.5)
			cellbg:addChild(self._ActivityList[i])
			self._ActivityList[i]:setPosition(self._ActivityList[i]:getContentSize().width*0.6 + (i - 1)*self._ActivityList[i]:getContentSize().width*0.6,cellbg:getContentSize().height / 2 - 15)
		end

		return cell
    end

    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:reloadData()

    --tableView:reloadData()
end

function QuanmingjingjiActivityLayer:ChongBangRank(index)
	self._nowSelected = index
	local list = {"arena"}
	self._rankList = nil
	ClientHttp:requestAsyncInGameWithParams({
        modules = "leaderBoardRank?",
		params = { type  = list[index] },
        successCallback = function( data )
			-- dump(data,"1111")
			if data.result == 0 then
				if #data.list > 0 then
					self._rankList = data.list
				end
				self._data = data
				self:initJLTableView(index)
			end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function QuanmingjingjiActivityLayer:ShowBianQiang(index)
	ClientHttp:requestAsyncInGameWithParams({
        modules = "scoreList?",
        successCallback = function( data )
            -- dump(data,"aaa")
            if tonumber(data.result) == 0 then
				local luckyTrunLayer = requires("src/fsgl/layer/ZhuCheng/BianQiangLayer.lua")
				local layer = luckyTrunLayer:create(data,self)
				self:addChild(layer)
            else
                XTHDTOAST(data.msg)
            end 
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
	})
end

function QuanmingjingjiActivityLayer:ShowRank()
	local rankNameList = {"竞技"}
	local rivalRankList = {"青铜组","白银组","黄金组","白金组","钻石组","至尊组","王者组"}
	local rankLayerbg = cc.LayerColor:create(cc.c3b(0,0,0))
	rankLayerbg:setContentSize(self:getContentSize())
	self:addChild(rankLayerbg)
	rankLayerbg:setOpacity(100)
	
	local node = ccui.Scale9Sprite:create("res/image/challenge/rank/dtphbg_06.png")
    node:setContentSize(cc.size(748,465))
    -- node:setCascadeOpacityEnabled( false )
    rankLayerbg:addChild(node)
    node:setPosition(rankLayerbg:getContentSize().width / 2,rankLayerbg:getContentSize().height / 2 - 30)

    local op_btn = XTHDPushButton:createWithParams({
            touchSize = cc.size(rankLayerbg:getContentSize().width,rankLayerbg:getContentSize().height),
            musicFile = XTHD.resource.music.effect_btn_common,
            })
    op_btn:setPosition(rankLayerbg:getContentSize().width/2,rankLayerbg:getContentSize().height/2)
--    node:addChild(op_btn,-1)self._nowSelected

	local rankName = cc.Sprite:create("res/image/activities/quanmingjingji/ranklogo_" .. self._nowSelected ..".png")
	node:addChild(rankName)
	rankName:setPosition(node:getContentSize().width / 2,node:getContentSize().height - rankName:getContentSize().height *0.5 -18)

	 --关闭按钮
    local close = XTHD.createBtnClose(function()
          rankLayerbg:removeFromParent()
    end)
    node:addChild(close)
    close:setPosition(node:getContentSize().width - 5,node:getContentSize().height - 5) 

	if node:getChildByName("tishi") then
		node:getChildByName("tishi"):removeFromParent()
	end

	local tishi = XTHDLabel:create("暂无排行",30,"res/fonts/def.ttf")
	node:addChild(tishi)
	tishi:setPosition(node:getContentSize().width / 2,node:getContentSize().height/2)
	tishi:setVisible(false)
	tishi:setName("tishi")

	if self._rankList == nil then
		tishi:setVisible(true)
		return
	end
	
	local rankTableView = cc.TableView:create(cc.size(650,390))
	rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL );
    rankTableView:setPosition( cc.p(40, 28));
    rankTableView:setBounceable(true)
	rankTableView:setDirection(ccui.ScrollViewDir.vertical)
	rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	rankTableView:setDelegate()
	node:addChild(rankTableView)

	local function numberOfCellsInTableView( table )
        return #self._rankList
    end
	local cellSize = cc.size(650,80)
    local function cellSizeForTable( table, idx )
		return cellSize.width,cellSize.height
    end

    local function tableCellAtIndex( table, idx )
        local cell = cc.TableViewCell:new()
		local cellBg = ccui.Scale9Sprite:create("res/image/challenge/rank/dtphbg_09.png")
		cellBg:setContentSize(630,70)
		cell:addChild(cellBg)
		cellBg:setPosition(cellBg:getContentSize().width/2 +15,cellBg:getContentSize().height/2)
		
		index = idx + 1
        -- 排名icon
        local rankIcon = XTHD.createSprite()
        rankIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
        rankIcon:setPosition( 60, cellSize.height*0.5 - 4 )
        cellBg:addChild( rankIcon )

        local rankNum = cc.Label:createWithBMFont( "res/fonts/paihangbangword.fnt", 0 )
	    rankNum:setPosition( 60, cellSize.height*0.5 - 10)
	    cellBg:addChild( rankNum )
	    rankNum:setString( index )
		local rankIconPath = ""
        if index <= 10 then
		    if index <= 3 then
			    rankIconPath = "res/image/ranklistreward/"..( index)..".png"
			    rankNum:setVisible(false)
		    else
			    rankIconPath = "res/image/ranklist/rank_4.png"
			    rankNum:setVisible(true)
		    end
		    rankIcon:setTexture( rankIconPath )
		    rankIcon:setScale(0.8)
		    rankIcon:setVisible( true )
        else
            rankIcon:setVisible( false )
        end
	
		local name = nil
		if self._nowSelected == 15 then
			name = self._rankList[index].guildName
		else
			name = self._rankList[index].charName
		end

		--昵称
		local nameLable = XTHDLabel:create(name,20,"res/fonts/def.ttf")
		nameLable:setColor(cc.c3b(107,70,43))
		nameLable:setAnchorPoint(0,0.5)
		nameLable:setPosition(130,cellBg:getContentSize().height*0.5)
		cellBg:addChild(nameLable)
		
		--种族
		local camp = nil
		if self._rankList[index].campId == 1 then
			camp = "(仙族)"
		else
			camp = "(魔族)"
		end
		local campLable = XTHDLabel:create(camp,16,"res/fonts/def.ttf")
		campLable:setColor(cc.c3b(107,70,43))
		nameLable:addChild(campLable)
		campLable:setAnchorPoint(0,0.5)
		campLable:setPosition(nameLable:getContentSize().width + 5,campLable:getContentSize().height / 2)
		
		
		if self._nowSelected == 14 then
			--GeneralShow
			local heroData = gameData.getDataFromCSV("GeneralShow",{heroid = self._rankList[index].petId})
			local heroName = XTHDLabel:create(heroData.name,20,"res/fonts/def.ttf")
			heroName:setAnchorPoint(0,0.5)
			heroName:setColor(cc.c3b(107,70,43))
			cellBg:addChild(heroName)
			heroName:setPosition(nameLable:getPositionX(),cellBg:getContentSize().height*0.5 + 10)

			nameLable:setFontSize(16)
			nameLable:setPositionY(heroName:getPositionY() - 20)
			nameLable:setString("(" ..self._rankList[index].charName ..")" )

			campLable:setFontSize(14)
			campLable:setPositionX(campLable:getPositionX() - 5)
		end


		local typeLable = XTHDLabel:create("",20,"res/fonts/def.ttf")
		typeLable:setColor(cc.c3b(107,70,43))
		typeLable:setAnchorPoint(0.5,0.5)
		typeLable:setPosition(cellBg:getContentSize().width / 2 +120,cellBg:getContentSize().height /2)
		cellBg:addChild(typeLable)

		typeLable:setString(rivalRankList[self._rankList[index].duanId])
		return cell
    end

    rankTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	rankTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	rankTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	rankTableView:reloadData()
	
end

function QuanmingjingjiActivityLayer:updateTime()
	self:stopActionByTag(10)
	schedule(self, function(dt)
		self._countDown = self._countDown - 1
		local time = LANGUAGE_KEY_CARNIVALDAY(self._countDown)	
		self._endTimeLable:setString(time)
		self._ActivityTime:setVisible(true)
	end,1,10)
end

function QuanmingjingjiActivityLayer:create(data)
	--rank == 1 但是 list == nil 显示未上榜
    -- print("毕业典礼的数据为：")
    -- print_r(self.data)
	self._data = data
	self._rankList = data.list
	local QuanmingjingjiActivityLayer = QuanmingjingjiActivityLayer.new()
	if QuanmingjingjiActivityLayer then 
		QuanmingjingjiActivityLayer:init()
		QuanmingjingjiActivityLayer:registerScriptHandler(function(event )
			if event == "enter" then 
				QuanmingjingjiActivityLayer:onEnter()
			elseif event == "exit" then 
				QuanmingjingjiActivityLayer:onExit()
			end 
		end)	
    end
	return QuanmingjingjiActivityLayer
end

function QuanmingjingjiActivityLayer:init( )
	self._canClick = true	
end



function QuanmingjingjiActivityLayer:onEnter( )
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
    		--self:removeFromParent()
    	end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(TOUCH_EVENT_BEGAN,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(TOUCH_EVENT_MOVED,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(TOUCH_EVENT_ENDED,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
end

function QuanmingjingjiActivityLayer:onExit( ) 
end

return QuanmingjingjiActivityLayer


