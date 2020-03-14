--[[
-- 限时挑战界面
]]

local XianShiTiaoZhanLayer = class("XianShiTiaoZhanLayer",function( )
	local node = cc.Node:create()
	node:setContentSize(cc.size(866,518))
	node:setAnchorPoint(0.5,0.5)
	return node
end)

function XianShiTiaoZhanLayer:ctor(data)
	self._selfRangeBg = nil
	self._killList = nil
	self._ingotCost10 = nil -----元宝消耗结点
	self._ingotCost1 = nil -----元宝消耗结点
	self._freeTimes = nil ------免费挑战次数
	self._labelTodayFree = nil ------今日免费次数标签
	self._noneRangeLabel = nil -----"目前还没有排行产生"标签
	self._spineTiger = nil
	self._didChallenge = false
	self._selectedTagNode = nil -------选中的标签节点

	self._serverData = data
end

function XianShiTiaoZhanLayer:create(node,serverData)
	self._parent = node
    self.serverData = serverData
    XTHDHttp:requestAsyncInGameWithParams({
        modules = "yearBeastInfo?",
        successCallback = function(data)
	        if tonumber(data.result) == 0 then
				local layer = XianShiTiaoZhanLayer.new(data)
				if layer then 
					node:removeAllChildren()
					node:addChild(layer)
					layer:setTag(10)
					layer:setPosition(node:getContentSize().width/2 + 79,node:getContentSize().height/2 - 20)
					layer:init()
				end
			else 
				XTHDTOAST(data.msg)
			end 
		end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function XianShiTiaoZhanLayer:onCleanup( )
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/activities/nian/monster_nian_bg.png")
    textureCache:removeTextureForKey("res/image/activities/nian/monster_nian_bg2.png")
    textureCache:removeTextureForKey("res/image/activities/nian/monster_nian_bg3.png")
    textureCache:removeTextureForKey("res/image/activities/nian/monster_nian_label1.png")
end

function XianShiTiaoZhanLayer:init( )
	self:setScale(0.8)
	 local herobtn = XTHDPushButton:createWithParams({
        touchSize =cc.size(self._parent:getContentSize().width,self._parent:getContentSize().height),
		musicFile = XTHD.resource.music.effect_btn_common,
     })
	herobtn:setSwallowTouches(true)
	self._parent:addChild(herobtn,-1)
	herobtn:setPosition(self._parent:getContentSize().width*0.5,self._parent:getContentSize().height *0.5)

	------左边的击杀排行
	local _layout = ccui.Layout:create()
	self:addChild(_layout)
	_layout:setContentSize(cc.size(350,390))
	_layout:setAnchorPoint(0,0.5)
	_layout:setPosition(60,self:getContentSize().height / 2 + 15)
	------击杀排行列表背景
	local _bg = cc.Sprite:create("res/image/goldcopy/font_bg.png")
	_bg:setScaleY((_layout:getContentSize().height + 115) / _bg:getContentSize().height)
	_layout:addChild(_bg)
	_bg:setPosition(_layout:getContentSize().width / 2,_layout:getContentSize().height / 2)
	self:initKillRankList(_layout)
	-----我的排行背景
	 _bg = cc.Sprite:create("res/image/activities/nian/monster_nian_bg2.png")
	_bg:setContentSize(_bg:getContentSize().width - 180,_bg:getContentSize().height)
	self:addChild(_bg)
	_bg:setAnchorPoint(0,1)
	_bg:setScaleY(0.6)
	_bg:setPosition( -20 + 35 ,_layout:getPositionY() - _layout:getContentSize().height / 2)
	self._selfRangeBg = _bg
	self:refreshSelfKillRange()
	-------活动时间 
	-- local str = string.format(LANGUAGE_MAINCITY_TIPS16,self._serverData.beginMonth,self._serverData.endDay,self._serverData.endMonth, self._serverData.beginDay)
	local str = "活动剩余时间："..LANGUAGE_KEY_CARNIVALDAY(self._serverData.close)
	local _time = XTHDLabel:createWithSystemFont(str,XTHD.SystemFont,18)
	_time:setColor(cc.c3b(197,204,254))
	_time:enableShadow(cc.c4b(197,204,254,0xff),cc.size(0.5,0.5))
	self:addChild(_time)
	_time:setAnchorPoint(0,1)
	_time:setPosition(_bg:getPositionX() + 20,_bg:getPositionY() - _bg:getContentSize().height + 19)
	self.Time = _time
	self:updateTime()
	------击败年兽
	local _label = cc.Sprite:create("res/image/activities/nian/monster_nian_label1.png")
	_label:setScale(0.8)
	self:addChild(_label)
	_label:setAnchorPoint(0,0)
	_label:setPosition(70,_layout:getPositionY() + _layout:getContentSize().height / 2)
	------帮助说明按钮
	local _button = XTHD.createPushButtonWithSound({
		normalFile = "res/image/common/btn/tip_up.png",
		selectedFile = "res/image/common/btn/tip_down.png"
	},3)
	self:addChild(_button)
	_button:setTouchEndedCallback(function( )
        local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=19}); --byhuangjunjian玩法说明
        cc.Director:getInstance():getRunningScene():addChild(StoredValue)
	end)
	_button:setAnchorPoint(0,0)
	_button:setPosition(20,_label:getPositionY() - 5)	
	self:initRight()
end

function XianShiTiaoZhanLayer:updateTime()
    self:stopActionByTag(10)
    schedule(self, function()
        self._serverData.close = self._serverData.close - 1
        local time = "活动剩余时间："..LANGUAGE_KEY_CARNIVALDAY(self._serverData.close) 
        self.Time:setString(time)
    end,1,10)
end

function XianShiTiaoZhanLayer:initRight( )
	-- local _bg = cc.Sprite:create("res/image/activities/nian/monster_nian_bg3.png")
	-- self:addChild(_bg)
	-- _bg:setPosition(self:getContentSize().width * 2/3 + 40,self:getContentSize().height / 2 - 110)
	-----老虎
	local _size = self:getContentSize()
	local size = cc.Director:getInstance():getWinSize()
	local scaleX = size.width / _size.width
	local scaleY = size.height / _size.height
    local _spine = XTHD.getHeroSpineById(self.serverData.list[1].petId)
	_spine:setAnimation(0,"idle",true)
    _spine:setScaleX(-1)
    local _node = cc.Node:create()
    self:addChild(_node)
    _node:setPosition(self:getContentSize().width * 2/3,self:getContentSize().height / 2 - 100)
    _node:addChild(_spine)    
    self._spineTiger = _spine
    -------奖励箱子
    -- local _box = XTHDPushButton:createWithParams({
    --     normalFile = "res/image/goldcopy/reward_btn_normal.png",
    --     selectedFile = "res/image/goldcopy/reward_btn_selected.png",
    --     musicFile = XTHD.resource.music.effect_btn_common,
    -- })
    -- self:addChild(_box)
    -- _box:setPosition(self:getContentSize().width - _box:getContentSize().width,150)
    -- _box:setTouchEndedCallback(function (  )
    --     local reward_layer = requires("src/fsgl/layer/ShangJinLieRen/ShangJinLieRenRewardPop.lua")
    --     self:addChild(reward_layer:create(), 1)
    -- end)
	-------挑战一次
	normal = ccui.Scale9Sprite:create("res/image/activities/nian/anniu.png")
	-- normal:setContentSize(cc.size(140,46))
	selected = ccui.Scale9Sprite:create("res/image/activities/nian/anniu.png")
	-- selected:setContentSize(cc.size(140,46))
	local _button = XTHD.createPushButtonWithSound({ ------挑战10次
		normalNode = normal,
		selectedNode = selected
	},3)
	_button:setScale(0.8)
	self:addChild(_button)
	_button:setTouchBeganCallback(function()
		_button:setScale(0.78)
	end)
	_button:setTouchMovedCallback(function()
		_button:setScale(0.8)
	end)
	_button:setTouchEndedCallback(function( )
		_button:setScale(0.8)
		self:doChallenge(1)
	end)
	_button:setAnchorPoint(0,0.5)	
	_button:setPosition(self:getContentSize().width / 2 -10,60*scaleY - 10)

	_word = XTHDLabel:create(self._serverData.surplusCount > 0 and "免费挑战" or string.format(LANGUAGE_TIPS_WORDS281,1),22,"res/fonts/def.ttf")
	_word:enableOutline(cc.c4b(45,13,103,255),2)
	_button:addChild(_word)
	_word:setColor(cc.c3b(255,255,255))
	self._wordBtn = _word
	_word:setPosition(_button:getContentSize().width / 2,_button:getContentSize().height / 2 - 3)
    ------免费挑战次数 
    _label = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS282..":",XTHD.SystemFont,20) -----今日挑战次数
    self:addChild(_label)
    _label:setAnchorPoint(0.5,0)
    _label:setPosition(_button:getPositionX() + _button:getBoundingBox().width / 2,_button:getPositionY() + _button:getBoundingBox().height / 2)
    self._labelTodayFree = _label
    -----次数 
    local _times = XTHDLabel:createWithSystemFont(5,XTHD.SystemFont,20)
    self:addChild(_times)
    _times:setColor(cc.c3b(44,216,83))
    _times:setAnchorPoint(0,0)
    _times:setPosition(_label:getPositionX() + _label:getBoundingBox().width / 2,_label:getPositionY())
    self._freeTimes = _times
    ------元宝消耗
	str = string.format(
		"<color fontSize=20 >%s</color><img=res/image/common/header_ingot.png /><color=#fbfe00 fontSize=22 >%d</color>",
		LANGUAGE_VERBS.cost1..":",self._serverData.fixedCostIngot
	)
	multiLabel = RichLabel:createARichText(str,false)
	multiLabel:setAnchorPoint(0.5,0)
	multiLabel:setPosition(_button:getPositionX() + _button:getBoundingBox().width / 2,_button:getPositionY() + 42)
	self:addChild(multiLabel)
	multiLabel:setVisible(false)
	self._ingotCost1 = multiLabel
    -------挑战按钮
	local normal = ccui.Scale9Sprite:create("res/image/activities/nian/anniu.png")
	-- normal:setContentSize(cc.size(140,46))
	local selected = ccui.Scale9Sprite:create("res/image/activities/nian/anniu.png")
	-- selected:setContentSize(cc.size(140,46))
	local _button10 = XTHD.createPushButtonWithSound({ ------挑战10次
		normalNode = normal,
		selectedNode = selected
	},3)
	self:addChild(_button10)
	_button10:setScale(0.8)
	_button10:setTouchBeganCallback(function()
		_button10:setScale(0.78)
	end)
	_button10:setTouchMovedCallback(function()
		_button10:setScale(0.8)
	end)
	_button10:setTouchEndedCallback(function( )
		_button10:setScale(0.8)
		self:doChallenge(10)
	end)
	_button10:setAnchorPoint(0,0.5)
	_button10:setPosition(_button:getPositionX() + _button:getBoundingBox().width + 50,60*scaleY - 10)

	local _word = XTHDLabel:create(string.format(LANGUAGE_TIPS_WORDS281,10),22,"res/fonts/def.ttf")
	_button10:addChild(_word)
	_word:enableOutline(cc.c4b(45,13,103,255),2)
	_word:setColor(cc.c3b(255,255,255))
	_word:setPosition(_button10:getContentSize().width / 2,_button10:getContentSize().height / 2 - 3)
    ------元宝消耗
	local str = string.format(
		"<color fontSize=20 >%s</color><img=res/image/common/header_ingot.png /><color=#fbfe00 fontSize=22 >%d</color>",
		LANGUAGE_VERBS.cost1..":",self._serverData.costIngot
	)
	local multiLabel = RichLabel:createARichText(str,false)
	multiLabel:setAnchorPoint(0.5,0)
	multiLabel:setPosition(_button10:getPositionX() + _button10:getBoundingBox().width / 2,_button10:getPositionY() + 42)
	self:addChild(multiLabel)
	self._ingotCost10 = multiLabel

    self:refreshFightCostAndTimes()    
end

function XianShiTiaoZhanLayer:initKillRankList(target)
    local function cellSizeForTable(table,idx)
        return target:getContentSize().width,80
    end

    local function numberOfCellsInTableView(table)
    	return #self._serverData.rankList
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
        end
        local node = self:createKillCell(idx + 1)
        if node then 
            cell:addChild(node)
            node:setPosition(node:getContentSize().width / 2,node:getContentSize().height / 2)
        end 
        return cell
    end

    local view = CCTableView:create(target:getContentSize())
    TableViewPlug.init(view)
    view:setPosition(-45,0)
    view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    view:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    view:setDelegate()
    target:addChild(view,0)

    view:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    view.getCellNumbers=numberOfCellsInTableView
    view:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    view.getCellSize=cellSizeForTable
    view:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._killList = view
    view:reloadData()
    ------------如果没有排行 
    local _label = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS27,XTHD.SystemFont,22)---"目前还没有排行产生"
    target:addChild(_label)
    _label:setPosition(target:getContentSize().width / 2, target:getContentSize().height / 2)
    self._noneRangeLabel = _label
    if #self._serverData.rankList > 0 then -----有排行
    	self._killList:setVisible(true)
    	self._noneRangeLabel:setVisible(false)
    else 
    	self._killList:setVisible(false)
    	self._noneRangeLabel:setVisible(true)
    end 
end

function XianShiTiaoZhanLayer:createKillCell(index)
	local node = XTHDPushButton:createWithParams({
		needSwallow = false,
		needEnableWhenMoving = true,
	})
	-- node:setAnchorPoint(0,0)
	node:setTouchSize(cc.size(350,90))
	node:setContentSize(cc.size(350,90))
	node:setTouchBeganCallback(function( )
		node:setScale(0.9)
	end)
	node:setTouchMovedCallback(function( )
		node:setScale(1.0)		
	end)
	node:setTouchEndedCallback(function()
		node:setScale(1.0)		
		HaoYouPublic.httpLookFriendInfo(self,node.userID,function( sData )
			LayerManager.addShieldLayout()
			local _infolayer = requires("src/fsgl/layer/HaoYou/ChaKanOtherPlayerInfoLayer.lua"):create(sData)
			LayerManager.addLayout(_infolayer)
		end)
	end)
	local data = self._serverData.rankList[index]
	if not data then 
		return node
	end 
	-------名次	
	node.userID = data.charId
	local _icon = nil
	if index < 4 then 
		local _icon = cc.Sprite:create("res/image/ranklistreward/"..index..".png")
		node:addChild(_icon)
		_icon:setScale(0.6)
		_icon:setPosition(_icon:getContentSize().width / 2 + 5,node:getContentSize().height / 2 - 5)
	else
		local _icon = cc.Sprite:create("res/image/ranklist/rank_4.png")
		node:addChild(_icon)
		_icon:setScale(0.7)
		_icon:setPosition(_icon:getContentSize().width / 2 - 5,node:getContentSize().height / 2 - 5)
		-----数字 
		local _numb = cc.Label:createWithBMFont("res/fonts/paihangbangword.fnt",index)
		_numb:setAdditionalKerning(-1)
		if index > 9 then 
			_numb:setScale(0.7)
		else
			_numb:setScale(0.9)			
		end 
		_icon:addChild(_numb)
		_numb:setPosition(_icon:getContentSize().width / 2,_icon:getContentSize().height / 2 - 5)
	end 
	------种族ICon
	local _campIcon = cc.Sprite:create("res/image/camp/camp_icon_small"..data.campId..".png")
	node:addChild(_campIcon)
	_campIcon:setScale(0.75)
	_campIcon:setAnchorPoint(0,0.5)
	_campIcon:setPosition(60,node:getContentSize().height / 2 - 7)
	----名字
	local _name = string.format("%s LV:%d",data.name,data.level) ------%sLv%d\
	_name = XTHDLabel:createWithSystemFont(_name,XTHD.SystemFont,15)
	_name:setColor(cc.c3b(255,255,255))
	_name:enableShadow(cc.c4b(255,255,255,255),cc.size(0.5,-0.5))
	_name:setAnchorPoint(0,0.5)
	node:addChild(_name)
	_name:setPosition(_campIcon:getPositionX() + _campIcon:getBoundingBox().width,_campIcon:getPositionY())	
	-----击杀
	local _kill = XTHDLabel:createWithSystemFont(LANGUAGE_VERBS.kill.."：",XTHD.SystemFont,16)-----击杀
	_kill:setColor(cc.c3b(255,255,255))
	_kill:enableShadow(cc.c4b(0xff,0xff,0xff,0xff),cc.size(0.5,-0.5))
	_kill:setAnchorPoint(0,0.5)
	node:addChild(_kill)
	_kill:setPosition(node:getContentSize().width * 2/3 + 30,_name:getPositionY())
	-----击杀数量
	local _amount = XTHDLabel:createWithSystemFont(data.killSum,XTHD.SystemFont,18)-----击杀
	_amount:setColor(cc.c3b(251,254,0))
	_amount:enableShadow(cc.c4b(251,254,0xff),cc.size(0.5,-0.5))
	_amount:setAnchorPoint(0,0.5)
	node:addChild(_amount)
	_amount:setPosition(_kill:getPositionX() + _kill:getBoundingBox().width,_kill:getPositionY())
	--------底部的图片
	local _bottomBg = cc.Sprite:create("res/image/activities/nian/millde_line.png")
	_bottomBg:setContentSize(node:getContentSize())
	_bottomBg:setScaleX((node:getContentSize().width + 10)/ _bottomBg:getContentSize().width)
	_bottomBg:setAnchorPoint(0.5,0)
	node:addChild(_bottomBg,-1)
	_bottomBg:setPosition(node:getContentSize().width / 2 - 20,0)	
	return node
end
-----刷新自己的排行
function XianShiTiaoZhanLayer:refreshSelfKillRange( )
	if self._selfRangeBg then 
		self._selfRangeBg:removeAllChildren()
		local str = string.format("%s：%s",LANGUAGE_KEY_SEFLRANGE,LANGUAGE_KEY_OUTOFRANGE)
		if self._serverData.myRank > 0 then 
			str = string.format("%s：%s",LANGUAGE_KEY_SEFLRANGE,self._serverData.myRank)
		end 
		local _label = XTHDLabel:createWithSystemFont(str,XTHD.SystemFont,20) ---我的排行 
		_label:setScaleY(1.5)
		_label:enableShadow(cc.c4b(0xff,0xff,0xff,0xff),cc.size(0.5,0.5))
		self._selfRangeBg:addChild(_label)
		_label:setAnchorPoint(0,0.5)
		_label:setPosition(20,self._selfRangeBg:getContentSize().height / 2)
		-----击杀
		local _kill = XTHDLabel:createWithSystemFont(LANGUAGE_VERBS.kill..":",XTHD.SystemFont,20)-----击杀
		_kill:enableShadow(cc.c4b(0xff,0xff,0xff,0xff),cc.size(0.5,-0.5))
		_kill:setScaleY(1.5)
		_kill:setAnchorPoint(0,0.5)
		self._selfRangeBg:addChild(_kill)
		_kill:setPosition(self._selfRangeBg:getContentSize().width * 2/3 - 20,self._selfRangeBg:getContentSize().height / 2)
		-----击杀数量
		local _amount = XTHDLabel:createWithSystemFont(self._serverData.mykillSum,XTHD.SystemFont,22)-----击杀
		_amount:setColor(cc.c3b(251,254,0))
		_amount:enableShadow(cc.c4b(251,254,0xff),cc.size(0.5,-0.5))
		_amount:setScaleY(1.5)
		_amount:setAnchorPoint(0,0.5)
		self._selfRangeBg:addChild(_amount)
		_amount:setPosition(_kill:getPositionX() + _kill:getBoundingBox().width,_kill:getPositionY())
	end 
end

function XianShiTiaoZhanLayer:doChallenge(_type,cost)
	if not self._didChallenge then 
		self._didChallenge = true
	    XTHDHttp:requestAsyncInGameWithParams({
	        modules = "challengeYearBeast?",
	        params = {count = _type},
	        successCallback = function(data)
		        if tonumber(data.result) == 0 then
		        	self:updatePlayerDatas(data)
				else 
					self._didChallenge = false
					XTHDTOAST(data.msg)
				end 
			end,
	        failedCallback = function()
				self._didChallenge = false
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
	        end,--失败回调
	        loadingParent = self,
	        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	end 
end

function XianShiTiaoZhanLayer:updatePlayerDatas(data)
    XTHD.saveItem({items = data.bagItems}) ------存储获得的物品
    local _reward = {}
    for k,v in pairs(data.rewardList) do 
    	_reward[k] = {
	        rewardtype = v.rewardType,
	        id = v.rewardId,
	        num = v.rewardSum,
		}
    end
    if self._spineTiger then -----播放受击动作
		self._spineTiger:setAnimation(1.0,BATTLE_ANIMATION_ACTION.DEATH,false)
		self._spineTiger:setTimeScale(1.1)
	end
	local callback = function()
		self._spineTiger:setAnimation(1.0,BATTLE_ANIMATION_ACTION.IDLE,false)
	end
	performWithDelay(self,function( )
		self._didChallenge = false
	    ShowRewardNode:create(_reward,nil,callback)
	    if data.playerProperty then 
		    for i=1,#data.playerProperty do
	            local _tb = string.split(data.playerProperty[i],",")
		        gameUser.updateDataById(_tb[1], _tb[2])
		    end
	    	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
		end
		self:reRequestBaseInfo()
	end,0.4)
end
-----刷新元宝挑战，免费挑战次数
function XianShiTiaoZhanLayer:refreshFightCostAndTimes( )
	if self._freeTimes and self._serverData.surplusCount > 0 then -----免费 
		self._ingotCost1:setVisible(false)
		self._freeTimes:setVisible(true)
		self._freeTimes:setString(self._serverData.surplusCount)
		self._labelTodayFree:setVisible(true)
	elseif self._ingotCost1 then 
		self._ingotCost1:setVisible(true)
		self._freeTimes:setVisible(false)
		self._labelTodayFree:setVisible(false)
	end 
end

function XianShiTiaoZhanLayer:reRequestBaseInfo( )
    XTHDHttp:requestAsyncInGameWithParams({
        modules = "yearBeastInfo?",
        successCallback = function(data)
	        if tonumber(data.result) == 0 then
	        	self._serverData = data
	        	self:refreshSelfKillRange() ----更新自己的排行 
	        	self:refreshFightCostAndTimes()
	        	if #self._serverData.rankList > 0 then 
	        		self._killList:setVisible(true)
	        		self._noneRangeLabel:setVisible(false)
	        		self._killList:reloadDataAndScrollToCurrentCell()
	        	else 
	        		self._killList:setVisible(false)	        		
	        		self._noneRangeLabel:setVisible(true)
	        	end 
	        	self._wordBtn:setString(self._serverData.surplusCount > 0 and "免费挑战" or string.format(LANGUAGE_TIPS_WORDS281,1)) 
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

return XianShiTiaoZhanLayer