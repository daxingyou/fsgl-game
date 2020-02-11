--Created By Liuluyang
local JingJiTeamPop = class("JingJiTeamPop",function ()
	return XTHD.createPopLayer()
end)

function JingJiTeamPop:ctor(data,_type,parent)
	self._parent = parent
	_type = _type or 1
	self._type = _type
	self:initUI(data,_type)
	self:refreshTeamInfo(data,_type)
end

function JingJiTeamPop:onCleanup()
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_TEAM_SETTING_LAYER)
end

function JingJiTeamPop:initUI(data,_type)
	data = {}
	-- local bg = ccui.Scale9Sprite:create( cc.rect(40,40,1,2), "res/image/common/scale9_bg_34.png" )
	--ly
	-- 背景后面大的
	local bgb = cc.Sprite:create("res/image/common/scale9_bg1_34.png")
	bgb:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	bgb:setScale(0.8)
	self:addContent(bgb)
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png" )
    bg:setContentSize(457,231)
	bg:setPosition(bgb:getContentSize().width/2,bgb:getContentSize().height/2+20)
	bgb:addChild(bg)
	self.bg = bg

	local closeBtn = XTHD.createBtnClose(function()
        self:hide()
    end)
    closeBtn:setPosition( bgb:getContentSize().width-20, bgb:getContentSize().height-20)
    bgb:addChild( closeBtn )

	local titleSp = cc.Sprite:create(_type == 1 and "res/image/plugin/competitive_layer/robbery_str.png" or "res/image/plugin/competitive_layer/ladder_str.png")
	titleSp:setAnchorPoint(0.5,1)
	titleSp:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height+50)
	bg:addChild(titleSp)

	local changeBtn = XTHDPushButton:createWithParams({
		normalFile = "res/image/common/btn/szteam_down.png",
		selectedFile = "res/image/common/btn/szteam_up.png",
		isScrollView = false,
	})
	changeBtn:setAnchorPoint(0.5,0)
	changeBtn:setPosition(bgb:getContentSize().width/2,40)
	bgb:addChild(changeBtn)
	self.changeBtn = changeBtn

	XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_TEAM_SETTING_LAYER,
        callback = function (event)
        	local _type = event.data._type or 1
        	local team = event.data.data[1][1]
        	-- ZCLOG(team)
        	local teamData = {}
        	for i=1,#team do
        		teamData[i] = team[i].heroid
        	end
        	local fNode = self:getParent()
        	-- XTHDTOAST(event._type)
        	if _type ~= 1 then
        		if fNode.refreshList then
        			-- fNode:refreshList()
        			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PVP_LADDER_LAYER})
	        		fNode = PVPMAINLAYER_TEMP
	        	end
	        	fNode._data.orderTeams = teamData
			else
				fNode._data.teams = teamData
        	end
            self:refreshTeamInfo(teamData)
        end
    })

	local function preloadAni( id )
		local nId = id
		id = tostring(id)
		if string.len(id) == 1 then
			id = "00" .. id
		elseif string.len(id) == 2 then
			id = "0" .. id
		end
		if id ~= 322 and id ~= 026 and id ~= 042 then
			sp.SkeletonAnimation:createWithBinaryFile("res/spine/"..id..".skel", "res/spine/"..id..".atlas", 1)
		else
			sp.SkeletonAnimation:create("res/spine/" .. id .. ".json", "res/spine/" .. id .. ".atlas", 1)
		end
	end

	local function preSpine( ... )
		if data and #data > 0 then
			for i = 1, 5 do
				local pNum = tonumber(_pve_heros[i]) or 0
				if pNum > 0 then
					local _heroId = pNum
					preloadAni(_heroId)
					pCount = pCount + 1
					if pCount >= 2 then
						break
					end
				end
			end
		end
	end
	performWithDelay(self, preSpine, 0.01)
end

function JingJiTeamPop:refreshTeamInfo(data,_type)
	if self.bg:getChildByName("teamBg") then
		self.bg:getChildByName("teamBg"):removeFromParent()
	end
	local teamBg = ccui.Scale9Sprite:create(cc.rect(11,11,1,1),"res/image/common/common_opacity.png")
	teamBg:setContentSize(cc.size(432,90))
	teamBg:setPosition(self.bg:getBoundingBox().width/2,self.bg:getBoundingBox().height/2+5)
	self.bg:addChild(teamBg)
	teamBg:setName("teamBg")

	local battleType = BattleType.PVP_DEFENCE
	if _type == 2 then
		battleType = BattleType.PVP_LADDER_DEFENCE
	end
	self.changeBtn:setTouchEndedCallback(function ()
		----------------------------------------------------------------
		YinDaoMarg:getInstance():guideTouchEnd()
        -- YinDaoMarg:getInstance():releaseGuideLayer()
		----------------------------------------------------------------
		self:hide()
		LayerManager.addShieldLayout()
		local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):create( battleType,nil,{{team = data}}, "PVP_Defence",1)
    	-- self:addChild(_layer)
    	fnMyPushScene(_layer)
	end)

	for i = 1,5 do--#teamData
		local _avator = nil
		if i <= #data then
			_avator = HeroNode:createWithParams({
				heroid   = data[i],
			})
			_avator:setScale(0.82)
		else
			_avator = cc.Sprite:create("res/image/common/no_hero.png")
			_avator:setScale(0.82)
		end
		_avator:setPosition(XTHD.resource.getPosInArr({
			lenth = 10.5,
			bgWidth = 432,
			num = 5,
			nodeWidth = _avator:getBoundingBox().width,
			now = i,
		}),teamBg:getBoundingBox().height/2)
		teamBg:addChild( _avator );
	end	
	
	if self._parent.refreshPower then
		self._parent:refreshPower()
	end	

	if self._type == 3 and self._parent then
		self._parent:refreshHeroDate(data)
	end
end

function JingJiTeamPop:create(data,_type,parent)
	return JingJiTeamPop.new(data,_type,parent)
end

function JingJiTeamPop:onExit( )
	if self._parent and self._parent.addHandToRobberBtn then 
		self._parent:addHandToRobberBtn()
	end 
end

function JingJiTeamPop:onEnter( )
	YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self.changeBtn,-----排位赛设置防守队伍
        index = 7,
        needNext = false
    },11)
    YinDaoMarg:getInstance():doNextGuide()
end

return JingJiTeamPop