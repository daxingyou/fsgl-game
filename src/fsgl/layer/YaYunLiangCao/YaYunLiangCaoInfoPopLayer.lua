local YaYunLiangCaoInfoPopLayer = class("YaYunLiangCaoInfoPopLayer",function()
	return XTHDPopLayer:create()
end)

function YaYunLiangCaoInfoPopLayer:ctor(_data)
	self.escortInfoData = {}
	self.rewardData = {}
	self:setEscortInfoData(_data)
	self:setRewardStaticData()

	self:initLayer()
end

function YaYunLiangCaoInfoPopLayer:initLayer()
	local _popSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
	_popSprite:setContentSize(cc.size(466,366))
	local _container = self:getContainerLayer()
	local _popNode = XTHDPushButton:createWithParams({
			normalNode = _popSprite
		})
	self.popNode = _popNode
	_popNode:setPosition(cc.p(_container:getContentSize().width/2,_container:getContentSize().height/2))
	_container:addChild(_popNode)

	local _titleBg = ccui.Scale9Sprite:create("res/image/login/zhanghaodenglu.png")
	-- _titleBg:setContentSize(cc.size(_popSprite:getContentSize().width - 7*2,44))
	_titleBg:setAnchorPoint(cc.p(0.5,0.5))
	_titleBg:setPosition(cc.p(_popNode:getContentSize().width/2,_popNode:getContentSize().height - 7))
	_popNode:addChild(_titleBg)


	-- local _campPath = "res/image/worldboss/camp_" .. (self.escortInfoData.dartInfo.campId or 1) .. ".png"
	-- local _campSp = cc.Sprite:create(_campPath)
	-- _campSp:setAnchorPoint(cc.p(0.5,0.5))
	-- _campSp:setPosition(cc.p(_titleBg:getContentSize().width/2,_titleBg:getContentSize().height/2))
	-- _titleBg:addChild(_campSp)
	local _campTab = {"仙 族","魔 族"}
	local campidx = self.escortInfoData.dartInfo.campId or 1
	local titleLabel = XTHDLabel:create(_campTab[campidx],26)
	titleLabel:setColor(cc.c3b(106,36,13))
	titleLabel:setAnchorPoint(0.5,0.5)
	titleLabel:setPosition(cc.p(_titleBg:getContentSize().width/2,_titleBg:getContentSize().height/2))
	_titleBg:addChild(titleLabel)


	--close

    local _closeBtn = XTHD.createBtnClose(function()
        self:hide()
    end)
    _closeBtn:setPosition(cc.p(_popNode:getContentSize().width-10,_popNode:getContentSize().height-10))
	_popNode:addChild(_closeBtn,5)
	
	--kuang
	local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	kuang:setContentSize(cc.size(446,223))
	kuang:setAnchorPoint(0.5,1)
	kuang:setPosition(_popNode:getBoundingBox().width/2,_titleBg:getPositionY()-_titleBg:getBoundingBox().height+5)
	_popNode:addChild(kuang)

    --my Escort
    local _teamBg = ccui.Scale9Sprite:create()
    _teamBg:setContentSize(cc.size(440,117))
    _teamBg:setAnchorPoint(cc.p(0.5,1))
    _teamBg:setPosition(cc.p(_popNode:getContentSize().width/2,_titleBg:getBoundingBox().y-5))
    _popNode:addChild(_teamBg)

    local _teamTitleLabel = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_HISTEAMTITLE(self.escortInfoData.dartInfo.name),"Helvetica",22)
    _teamTitleLabel:setColor(cc.c3b(70,34,34))
    _teamTitleLabel:setAnchorPoint(cc.p(0.5,1))
    _teamTitleLabel:setPosition(cc.p(_teamBg:getContentSize().width/2,_teamBg:getContentSize().height+5))
    _teamBg:addChild(_teamTitleLabel)

    local _teamData = self.escortInfoData.dartInfo.teams[1].heros or {}
    local _teamPosY = _teamTitleLabel:getBoundingBox().y/2 + 2
    local _teamPosTable = SortPos:sortFromMiddle(cc.p(_teamBg:getContentSize().width/2,_teamPosY),#_teamData,82)
    for i=1,#_teamData do
    	local _heroSp = HeroNode:createWithParams({
			heroid   = _teamData[i]["petId"] or 1,
			star   = _teamData[i]["star"] or 1,
			level = _teamData[i]["level"] or 0,
			advance = _teamData[i]["phase"] or 1,
			clickable = false
		})
		_heroSp:setScale(72/_heroSp:getContentSize().width)
		_heroSp:setPosition(cc.p(_teamPosTable[i].x,_teamPosTable[i].y))
		_teamBg:addChild(_heroSp)
    end

    --reward
    local _rewardBg = ccui.Scale9Sprite:create()
    _rewardBg:setContentSize(cc.size(440,110))
    _rewardBg:setAnchorPoint(cc.p(0.5,1))
    _rewardBg:setPosition(cc.p(_popNode:getContentSize().width/2,_teamBg:getBoundingBox().y-5))
	_popNode:addChild(_rewardBg)
	
	--线
	local splitBottom = cc.Sprite:create("res/image/daily_task/escort_task/split_dark.png")
	splitBottom:setAnchorPoint(cc.p(0.5,0))
	splitBottom:setScale(0.7)
    splitBottom:setPosition(_rewardBg:getPositionX(),_rewardBg:getPositionY())
	_popNode:addChild(splitBottom)
    
    local _rewardTitleLabel = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_WINNER_GET_LABEL,"Helvetica",22)
    _rewardTitleLabel:setColor(cc.c3b(70,34,34))
    _rewardTitleLabel:setAnchorPoint(cc.p(0.5,1))
    _rewardTitleLabel:setPosition(cc.p(_rewardBg:getContentSize().width/2,_rewardBg:getContentSize().height - 8))
    _rewardBg:addChild(_rewardTitleLabel)

    local _rewardPosY = tonumber(_rewardTitleLabel:getBoundingBox().y)/2
    local _rewardPosTable = SortPos:sortFromMiddle(cc.p(_rewardBg:getContentSize().width/2,_rewardPosY),#self.rewardData,69)
    for i=1,#self.rewardData do
    	local _rewardSp = ItemNode:createWithParams({
	        _type_          = self.rewardData[i].rewardType,                --[[类型,1:元宝；2.银两；3.翡翠；4.道具]]
	        itemId          = self.rewardData[i].rewardId,
	        count           = self.rewardData[i].rewardNum,              --[[个数]]
	    })
		_rewardSp:setScale(61/_rewardSp:getContentSize().width)
		_rewardSp:setPosition(cc.p(_rewardPosTable[i].x,_rewardPosTable[i].y))
		_rewardBg:addChild(_rewardSp)
    end

    --抢夺
    local function getBtnNode(_path)
		local _node = ccui.Scale9Sprite:create(cc.rect(64,0,1,49),_path)
		_node:setContentSize(cc.size(256,49))
		return _node
	end
    local _attackBtn = XTHD.createCommonButton({
                        btnSize = cc.size(130,46),
						text = LANGUAGE_BTN_KEY.escort,
						isScrollView = false,
						btnColor = "write_1",
						fontSize = 26,
						fontColor = cc.c3b(255,255,255)
					})
					_attackBtn:setScale(0.7)
    _attackBtn:setTouchEndedCallback(function()
    		self:attackCallback()
    	end)
    _attackBtn:setPosition(cc.p(_popNode:getContentSize().width/2,43))
    _popNode:addChild(_attackBtn)

	self:show()
end

function YaYunLiangCaoInfoPopLayer:attackCallback()
	local challageData = self.escortInfoData.dartInfo
	LayerManager.addShieldLayout()
    local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")
    local _layerHandler = SelHeroLayer:create(BattleType.PVP_CUTGOODS, nil, challageData)
	-- self:hide()
	self:removeFromParent()
    fnMyPushScene(_layerHandler)
end

function YaYunLiangCaoInfoPopLayer:setEscortInfoData(_data)
	self.escortInfoData = {}
	if _data == nil then
		return
	end
	self.escortInfoData = _data
end

function YaYunLiangCaoInfoPopLayer:setRewardStaticData()
	self.rewardData = {}
	local _table = gameData.getDataFromCSV("LiangcaoStore") or {}
	
	local _rewardid = tonumber(self.escortInfoData["taskId"])
	local _rewardNum = tonumber(self.escortInfoData["rewardNum"])
	local _rewardData = _table[_rewardid] or {}
	local _rewardMs = tonumber(self.escortInfoData["rewardMs"])
	for i=1,_rewardNum do
		if _rewardData["reward" .. i] == nil then
			break
		end
		local _rewardStr = _rewardData["reward" .. i]
		local _rewardIndexData = string.split(_rewardStr,"#")
		local _rewardNum = math.floor(tonumber(_rewardIndexData[3]) * _rewardMs)
		if _rewardNum>0 then
			local _index = #self.rewardData +1
			self.rewardData[_index] = {}
			self.rewardData[_index].rewardType = tonumber(_rewardIndexData[1])
			self.rewardData[_index].rewardId = tonumber(_rewardIndexData[2])
			self.rewardData[_index].rewardNum = tonumber(_rewardNum)
		end
	end
end

function YaYunLiangCaoInfoPopLayer:create(_data)
	local _layer = self.new(_data)
	return _layer
end

return YaYunLiangCaoInfoPopLayer