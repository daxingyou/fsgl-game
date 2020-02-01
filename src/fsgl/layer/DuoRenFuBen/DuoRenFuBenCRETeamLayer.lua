--[[
-------多人副本，当选中某个特定的副本

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
　　┃ 		　┣┓
　　┃　　　  　┃
　　┗┓┓ ┏━┳┓ ┏┛
　　　┃┫┫　┃┫┫
　　　┗┻┛　┗┻┛
神兽镇楼，代码永无bug
]]

local DuoRenFuBenCRETeamLayer = class("DuoRenFuBenCRETeamLayer",function( )
	return XTHD.createBasePageLayer()
end)

function DuoRenFuBenCRETeamLayer:ctor( id,parent,data)
	self._copyID = id
	self._parent = parent
	self._localData = data

	self._difficultyBtn = {} ----难度按钮 ,从上到下，普通、困难、炼狱、恶梦
	self._heroNodeContainer = nil ---选择英雄头像的容器
	self._flowerCostLabel = nil ------消耗的鲜花
	self._selectedHeroID = -1 ------当前选择的英雄ID
	self._selectedDiffIndex = 1 ----选中的难度索引 
	self._selectedBox = nil -------选择难度浮动的玩意儿
	self._selectedDiffBtn = nil ------当前选中的难度按钮
	self._difficultyBg = nil ------难度选择处的背景
	self._difficultyREBg = nil -----难度的奖励容器
	self._adviceWord = nil ----在选择难度上面建议上阵英雄

	self._difficultyAva = 1 -----当前可达到的难度
	for k,v in pairs(self._localData) do 
		if v.needlv <= gameUser.getLevel() then 
			self._difficultyAva = k
		end 
	end 

    self.Tag = {
    	ktag_heroNode = 100,
	}
	self:registerNotification()
end

function DuoRenFuBenCRETeamLayer:create(id,parent,data)
	local layer = DuoRenFuBenCRETeamLayer.new(id,parent,data)
	if layer then 
		layer:init()
	end 
	return layer
end

function DuoRenFuBenCRETeamLayer:init( )
	local topBar = self:getChildByName("TopBarLayer1")
	topBar:setBackCallFunc(function( )
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MULTICOPY_TEAMS})
		LayerManager.removeLayout()
	end)
	------背景
	local bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
	self:addChild(bg)
	self._backG = bg
	bg:setPosition(self:getContentSize().width / 2,(self:getContentSize().height - self.topBarHeight) / 2)
    local bsize=bg:getContentSize()

	--kuang1 
	local kuang1 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
	kuang1:setContentSize(430,280)
	kuang1:setAnchorPoint(0.5,1)
	kuang1:setPosition(bsize.width * 1/4,bsize.height - 70)
	self._backG:addChild(kuang1)
	
	-----选择难度 
	local _bg = cc.Sprite:create("res/image/multiCopy/xznd.png")
	kuang1:addChild(_bg)
    _bg:setAnchorPoint(0.5,1)
	_bg:setPosition(430/2,320)
	
	----字
	local _word = XTHDLabel:create(self._localData[1].shuoming,16,"res/fonts/def.ttf")
	_word:setColor(cc.c3b(54,55,112))
	kuang1:addChild(_word)
    _word:setAnchorPoint(0.5,0)
	_word:setPosition(430/2,280-30)
	self._adviceWord = _word
	-------第二层背景
	local _leftBg = ccui.Scale9Sprite:create()
	_leftBg:setContentSize(cc.size(430,225))
	self._backG:addChild(_leftBg)
	_leftBg:setAnchorPoint(0.5,1)
	_leftBg:setPosition(kuang1:getPositionX(),kuang1:getPositionY()-30)
	self._difficultyBg = _leftBg
	self:initDifficultyBtn(_leftBg)

	-- kuang2
	local kuang2 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
	kuang2:setContentSize(430,135)
	kuang2:setAnchorPoint(0.5,1)
	kuang2:setPosition(_leftBg:getPositionX(),_leftBg:getPositionY() - _leftBg:getContentSize().height - 25)
	self._backG:addChild(kuang2)
	------副本奖励
	-- _bg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,34))
	_bg = cc.Sprite:create("res/image/multiCopy/fbjl.png")
	self._backG:addChild(_bg)
	_bg:setAnchorPoint(0.5,1)
	_bg:setPosition(_leftBg:getPositionX(),_leftBg:getPositionY() - _leftBg:getContentSize().height - 10)
	
	------字
	_word = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_COPYREWARD,XTHD.SystemFont,16)
	_word:setColor(XTHD.resource.color.gray_desc)
	-- _bg:addChild(_word)
	_word:setPosition(_bg:getContentSize().width / 2,_bg:getContentSize().height / 2)
	------放奖励的面板 
	self._difficultyREBg = ccui.Layout:create()
	self._backG:addChild(self._difficultyREBg)
	self._difficultyREBg:setContentSize(cc.size(420,105))
	self._difficultyREBg:setAnchorPoint(0.5,1)
	self._difficultyREBg:setPosition(_bg:getPositionX(),_bg:getPositionY() - _bg:getContentSize().height - 7)
	----------右边背景
	local _line = cc.Sprite:create("res/image/common/line.png")
	self._backG:addChild(_line)
	_line:setScaleY(300 / _line:getContentSize().width)
	_line:setRotation(90)
    _line:setAnchorPoint(0.5,0)
	_line:setPosition(500,(bsize.height -  16)/2)
	_line:setOpacity(0)
	local _rightSplit = cc.Sprite:create("res/image/ranklistreward/splitY.png")
	_rightSplit:setFlippedX(true)
	_rightSplit:setScaleY(480 / _rightSplit:getContentSize().height)
	self._backG:addChild(_rightSplit)
	_rightSplit:setAnchorPoint(0,0.5)
	_rightSplit:setPosition(_line:getPositionX(),_line:getPositionY())
	self:initRightContent()
	self:initDifficultyReward(self._selectedDiffIndex)
end

function DuoRenFuBenCRETeamLayer:initDifficultyBtn(target)
	if target then 
		target:removeAllChildren()
		-------特别的选中框
		local _selectedBox = ccui.Scale9Sprite:create("res/image/common/common_selected1.png")
		_selectedBox:setContentSize(cc.size(415,46))
		_selectedBox:setAnchorPoint(0.5,1)
		target:addChild(_selectedBox,1)
		self._selectedBox = _selectedBox
		local y = target:getContentSize().height - 7
		for i = 1,4 do 
			local normal = ccui.Scale9Sprite:create("res/image/common/select_bg_10.png")
			local selected = ccui.Scale9Sprite:create("res/image/common/select_bg_10.png")
			local _nameColor = cc.c3b(255,255,255)
			if i > self._difficultyAva then 
				_nameColor = cc.c3b(255,255,255)
				normal = ccui.Scale9Sprite:create("res/image/common/select_bg_10.png")
				selected = ccui.Scale9Sprite:create("res/image/common/select_bg_10.png")
			end 
			normal:setContentSize(cc.size(415,46))
			selected:setContentSize(cc.size(415,46))
			local _button = XTHD.createPushButtonWithSound({
				normalNode = normal,
				selectedNode = selected,
			},3)
			_button:setAnchorPoint(0.5,1)
			target:addChild(_button)
			_button:setPosition(target:getContentSize().width / 2,y)
			_button:setTouchEndedCallback(function( )
				self:doChooseADifficulty(_button,i)
			end)
			y = y - _button:getContentSize().height - 9
			self._difficultyBtn[i] = _button
			---------
			local _name = XTHDLabel:create(LANGUAGE_MULTICOPY_DIFFICULTY[i],26,"res/fonts/def.ttf")
			_name:setColor(_nameColor)
			_button:addChild(_name)
			_name:enableOutline(cc.c4b(54,55,112,255),1)
			_name:setPosition(_button:getContentSize().width / 2,_button:getContentSize().height / 2)
			----锁
			if i > self._difficultyAva then 
				local _lock = cc.Sprite:create("res/image/common/img_lock_gray.png")
				_button:addChild(_lock)
				_lock:setPosition(_button:getContentSize().width - 30,_button:getContentSize().height / 2)
			end 
			------线
			if i < 4 then 
				-- local _line = cc.Sprite:create("res/image/ranklistreward/splitcell.png")
			    -- target:addChild(_line)
			    -- _line:setScaleX((target:getBoundingBox().width - 2)/ _line:getContentSize().width)
			    -- _line:setPosition(target:getContentSize().width / 2,y + 4)
			end 
			if i == 1 then 				
				self._selectedBox:setPosition(_button:getPosition())
				_button:setSelected(true)
				self._selectedDiffBtn = _button
			end 
		end 
	end 
end

function DuoRenFuBenCRETeamLayer:initRightContent( )

	--背景
	local right_bg = ccui.Scale9Sprite:create("res/image/multiCopy/right_bg.png")
	right_bg:setScaleX(0.6)
	right_bg:setScaleY(0.75)
	-- right_bg:setContentSize(430,500)
	right_bg:setAnchorPoint(0.5,1)
	right_bg:setPosition(self._backG:getContentSize().width * 3/4,self._backG:getContentSize().height - self.topBarHeight - 50)
	self._backG:addChild(right_bg)
	-----选择出战英雄 
	-- local _bg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,34))
	local _bg = cc.Sprite:create("res/image/multiCopy/xzczyx.png")
	self._backG:addChild(_bg)
	_bg:setPosition(self._backG:getContentSize().width * 3/4,self._backG:getContentSize().height - self.topBarHeight - 50)
	----字
	local _word = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_CHOOSEHERO,XTHD.SystemFont,18)
	_word:setColor(XTHD.resource.color.gray_desc)
	-- _bg:addChild(_word)
	_word:setPosition(_bg:getContentSize().width / 2,_bg:getContentSize().height / 2)
	------圈
	local _circleBg = cc.Sprite:create("res/image/plugin/compose/compose_itemBg.png")
	self._backG:addChild(_circleBg)
	_circleBg:setAnchorPoint(0.5,1)
	_circleBg:setPosition(_bg:getPositionX(),_bg:getPositionY() - _bg:getContentSize().height / 2 - 20)
	-------线
	-- local _line = cc.Sprite:create("res/image/common/titlepattern_left.png")
	-- self:addChild(_line)
	-- _line:setAnchorPoint(1,0.5)
	-- _line:setPosition(_circleBg:getPositionX() - _circleBg:getContentSize().width / 2 - 10,_circleBg:getPositionY() - _circleBg:getContentSize().height / 2)
	-- ---
	-- _line = cc.Sprite:createWithTexture(_line:getTexture())
	-- _line:setFlippedX(true)
	-- self:addChild(_line)
	-- _line:setAnchorPoint(0,0.5)
	-- _line:setPosition(_circleBg:getPositionX() + _circleBg:getContentSize().width / 2 + 10,_circleBg:getPositionY() - _circleBg:getContentSize().height / 2)
	-------没有英雄的
	local _noHero = cc.Sprite:create("res/image/common/no_hero.png")
	_circleBg:addChild(_noHero)
	_noHero:setPosition(_circleBg:getContentSize().width / 2,_circleBg:getContentSize().height / 2) 
	_noHero:setOpacity(0)
	------外围的框 
	local _border = cc.Sprite:create("res/image/multiCopy/copy_black_head.png")
	_circleBg:addChild(_border)
	_border:setPosition(_noHero:getPosition())	
	_noHero:setScaleX((_border:getContentSize().width - 4) / _noHero:getContentSize().width)
	_noHero:setScaleY(_border:getContentSize().height / _noHero:getContentSize().height)
	_border:setOpacity(0)
	self._heroNodeContainer = _border
	---plus
	local _plus = cc.Sprite:create("res/image/plugin/hero/label_add_green.png")
	_plus:setCascadeOpacityEnabled( false )
	_border:addChild(_plus)
	_plus:setPosition(_border:getContentSize().width / 2,_border:getContentSize().height / 2)	

	local selected = cc.Sprite:create("res/image/common/no_hero.png")
	local _button = XTHD.createPushButtonWithSound({
	},3)
	_button:setTouchSize(_border:getContentSize())
	_circleBg:addChild(_button)
	_button:setTouchEndedCallback(function( )
		self:doSelectHero()
	end)
	_button:setPosition(_border:getPosition())
	-----文字 ,点击头像可更换英雄
	local _word = XTHDLabel:create(LANGUAGE_TIPS_WORDS260,22,"res/fonts/def.ttf")
	-- _word:enableShadow(cc.c4b(238,219,187,255),cc.size(0,0),2)
	_word:setColor(cc.c3b(238,219,187))
	_word:enableOutline(cc.c4b(0,0,0,255),1)
	self._backG:addChild(_word)
	_word:setPosition(_bg:getPositionX(),_circleBg:getPositionY() - _circleBg:getContentSize().height - 25)
	-----挑战次数
	local data = DuoRenFuBenDatas.copyListData.list
	-- print("多人副本挑战次数数据为：CopyID:"..self._copyID)
	-- print_r(data)
	local max,cur = 0,0
	for k,v in pairs(data) do
		if v.ectypeType == self._copyID then 
			v = v.curCount
			max,cur = v[1].maxCount,v[1].curCount
			break
		end 
	end 
	cur = max - cur
	local _chlgTime = XTHDLabel:create(LANGUAGE_TIPS_CHALLENGETIMES(cur,max),18,"res/fonts/def.ttf") ----挑战次数
	self._chlgTime = _chlgTime
	_chlgTime:setColor(XTHD.resource.color.gray_desc)
	self._backG:addChild(_chlgTime)
	_chlgTime:setPosition(_word:getPositionX(),_word:getPositionY() - 70)
	----挑战消耗
	local _chlgCost = XTHDLabel:create(LANGUAGE_TIPS_WORDS261..":",18,"res/fonts/def.ttf")
	_chlgCost:setColor(XTHD.resource.color.gray_desc)
	self._backG:addChild(_chlgCost)
	_chlgCost:setAnchorPoint(0,0.5)
	----花
	local _vim = cc.Sprite:create(IMAGE_KEY_HEADER_TILI)
	self._backG:addChild(_vim)
	_vim:setScale(0.8)
	_vim:setAnchorPoint(0,0.5)
	---值 
	local _val = XTHDLabel:createWithSystemFont(self._localData[self._selectedDiffIndex].costFlower,XTHD.SystemFont,18)
	self._backG:addChild(_val)
	_val:setColor(XTHD.resource.color.gray_desc)
	_val:setAnchorPoint(0,0.5)
	local x = _chlgCost:getContentSize().width + _vim:getContentSize().width + _vim:getContentSize().width
	x = (self._backG:getContentSize().width / 2 - x) / 2 + self._backG:getContentSize().width / 2 + 5
	_chlgCost:setPosition(x + 15,_chlgTime:getPositionY() - _chlgTime:getContentSize().height - 10)
	_vim:setPosition(x + _chlgCost:getContentSize().width + 15,_chlgCost:getPositionY())
	_val:setPosition(_vim:getPositionX() + _vim:getContentSize().width,_chlgCost:getPositionY())
	self._flowerCostLabel = _val
	-----好友之间可以互赠鲜花
	-- _word = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_WORDS262,XTHD.SystemFont,16)
	-- _word:setColor(cc.c3b(128,112,91))
	-- self:addChild(_word)
	-- _word:setPosition(_bg:getPositionX(),_chlgCost:getPositionY() - _chlgCost:getContentSize().height - 10)
	----按钮
	-- local normal = ccui.Scale9Sprite:create("res/image/common/btn/btn_blue_up.png")
	-- normal:setContentSize(cc.size(140,46))
	-- local selected = ccui.Scale9Sprite:create("res/image/common/btn/btn_blue_down.png")
	-- selected:setContentSize(cc.size(140,46))
	-- _button = XTHD.createPushButtonWithSound({
	-- 	normalNode = normal,
	-- 	selectedNode = selected
	-- },3)
	_button = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		text = "创建队伍",
		fontSize = 24,
	})
	_button:setScale(0.8)
	self._backG:addChild(_button)
	_button:setTouchSize(cc.size(140,60))
	_button:setTouchEndedCallback(function( )
		self:doCreateTeam()
	end)
	_button:setPosition(_bg:getPositionX(),_chlgCost:getPositionY() - _chlgCost:getContentSize().height - 50)
	-----按钮上的字
	-- _word = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_CREATETEAM,XTHD.SystemFont,20)
	-- _button:addChild(_word)
	-- _word:setColor(XTHD.resource.color.gray_desc)
	-- _word:setPosition(_button:getContentSize().width / 2,_button:getContentSize().height / 2)
end

function DuoRenFuBenCRETeamLayer:initDifficultyReward(difficulty)
	if self._difficultyREBg and self._localData[difficulty] then 
		self._difficultyREBg:removeAllChildren()
		local _rewardData = self._localData[difficulty].dropToSee2
		_rewardData = string.split(_rewardData,"#")
		local _width = 0
		local items = {}
		for k,v in pairs(_rewardData) do 
	        local _item = ItemNode:createWithParams({
	            _type_ = 4,
	            itemId = v,
	            isShowCount = false,
	            needSwallow = true,
	        })
	        _item:setAnchorPoint(0,0.5)
	        self._difficultyREBg:addChild(_item)      
	        items[k] = _item  
	        _width = _item:getBoundingBox().width + _width
		end 
		local x = (self._difficultyREBg:getContentSize().width - _width - (#_rewardData - 1) * 15) / 2
		for k,v in pairs(items) do 
			v:setPosition(x,self._difficultyREBg:getContentSize().height / 2)
			x = x + v:getBoundingBox().width + 15
		end 
	end 
end

function DuoRenFuBenCRETeamLayer:onEnter( )	
end

function DuoRenFuBenCRETeamLayer:onExit( )	
end

function DuoRenFuBenCRETeamLayer:onCleanup( )
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_MULTICOPY_AFTERCHOOSE)
    XTHD.removeEventListener(CUSTOM_EVENT.GO_MULTICOPY_PREPARE_LAYER)	
    
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/multiCopy/copy_null_holder.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_black_head.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_box_bg.png")
    textureCache:removeTextureForKey("res/image/multiCopy/copy_yellowplus.png")
end

function DuoRenFuBenCRETeamLayer:doChooseADifficulty(sender,index )
	if index <= self._difficultyAva and index ~= self._selectedDiffIndex then 
		self._selectedDiffIndex = index
		self._selectedBox:setPosition(sender:getPosition())
		sender:setSelected(true)
		if self._selectedDiffBtn then 
			self._selectedDiffBtn:setSelected(false)
		end 
		self._selectedDiffBtn = sender
		self._flowerCostLabel:setString(self._localData[index].costFlower)
		self:initDifficultyReward(self._selectedDiffIndex)
		if self._adviceWord then 
			self._adviceWord:setString(self._localData[self._selectedDiffIndex].shuoming)
		end 

		local data = DuoRenFuBenDatas.copyListData.list
		local max,cur = 0,0
		for k,v in pairs(data) do
			if v.ectypeType == self._copyID then 
				v = v.curCount
				max,cur = v[index].maxCount,v[index].curCount
				break
			end 
		end 
		cur = max - cur
		-- print("点击了"..index.."按钮".."  "..LANGUAGE_TIPS_CHALLENGETIMES(cur,max))
		self._chlgTime:setString(LANGUAGE_TIPS_CHALLENGETIMES(cur,max))
	elseif index > self._difficultyAva then  
		local str = string.format(LANGUAGE_MULTICOPY_TIPS3,self._localData[index].needlv)
		XTHDTOAST(str)
	end 
end
------选择一个英雄上阵
function DuoRenFuBenCRETeamLayer:doSelectHero( )
	local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):createWithParams({
		battle_type = BattleType.MULTICOPY_DEFENCE, 	--战斗类型
		heroId = self._selectedHeroID,
		heroQuiltyLimit = self._localData[self._selectedDiffIndex].limitRank,
        instancingid = self._localData[self._selectedDiffIndex].id,	    	
	})		 
	fnMyPushScene(_layer)
end

function DuoRenFuBenCRETeamLayer:doCreateTeam( )
	if self._selectedHeroID > -1 and self._localData[self._selectedDiffIndex] then 
		-----创建多人副本队伍 
		local object = SocketSend:getInstance()
		if object then 
			object:writeShort(self._localData[self._selectedDiffIndex].id)
			object:writeInt(self._selectedHeroID)
			object:send(MsgCenter.MsgType.CLIENT_REQUEST_CREATEMULTITEAM)
		end 
	else
		XTHDTOAST(LANGUAGE_MULTICOPY_TIPS7) -----你还没有选择英雄哦
	end 
end

function DuoRenFuBenCRETeamLayer:refreshSelectedHero( id )
	if self._heroNodeContainer and id > -1 then 
		self._selectedHeroID = id
		self._heroNodeContainer:removeChildByTag(self.Tag.ktag_heroNode)
		local _hero = HeroNode:createWithParams({
			heroid = id
		})
		self._heroNodeContainer:addChild(_hero,1,self.Tag.ktag_heroNode)
		_hero:setPosition(self._heroNodeContainer:getContentSize().width / 2 + 1.5,self._heroNodeContainer:getContentSize().height / 2 + 3)
	end 
end

function DuoRenFuBenCRETeamLayer:registerNotification()
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_MULTICOPY_AFTERCHOOSE,callback = function( event )-----选好人了之后刷出选中的人
		local id = event.data.heroId
		self:refreshSelectedHero(id)
    end})
	XTHD.addEventListener({name = CUSTOM_EVENT.GO_MULTICOPY_PREPARE_LAYER,callback = function( event )-----前往多人副本准备页面
		local heroID = event.data
	    local _layer = requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenPrepareLayer.lua"):create({
	    	id = heroID,
	    	parent = self._parent,
	    	_type = 1,
	    	fristID = self._localData[self._selectedDiffIndex].id,
	    })
    	LayerManager.removeLayout(self)
	    LayerManager.addLayout(_layer)
	end})
end

return DuoRenFuBenCRETeamLayer