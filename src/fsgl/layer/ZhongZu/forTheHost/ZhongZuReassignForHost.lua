--[[
-----在城主争霸战斗完的时候，赢的那方可以将自己的队伍派遣到当前的城市
]]

local ZhongZuReassignForHost = class("ZhongZuReassignForHost",function( )
    return XTHDDialog:create()	
end)

function ZhongZuReassignForHost:ctor(cityID,level)
	self.__cityID = cityID
	self._cityLevel = level
	
	self._selectedTeamID = 0 -------选中的队伍ID
	self._selectedNode = nil ----当前被选中的

	self.Tag = {
		ktag_action1 = 1024,
		ktag_nodeMoveButton = 2048,
	}

	self.color = {
		yellow = cc.c3b(255,234,0),
		brown = cc.c3b(64,30,6),
		darkBrown = cc.c3b(66,28,7),
		darkRed = cc.c3b(255,90,0)
	}
end

function ZhongZuReassignForHost:create(cityID,level)
	local layer = ZhongZuReassignForHost.new(cityID,level)
	if layer then 
		layer:init()
	end	 
	return layer
end 

function ZhongZuReassignForHost:init( )
	local bg = cc.LayerColor:create(cc.c4b(0,0,0,150),self:getContentSize().width,self:getContentSize().height)
	self:addChild(bg)
	
	---背景
	local back = cc.Sprite:create("res/image/camp/camp_bg2.png")	
	back:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self:addChild(back)
	----返回按钮
	local _backBtn = XTHD.createPushButtonWithSound({
    	normalFile = "res/image/common/btn/btn_back_normal.png",
    	selectedFile = "res/image/common/btn/btn_back_selected.png",
    	-- text = LANGUAGE_KEY_EXIT,
    	-- fontColor = cc.c3b(160,76,43),
    	-- fontSize = 20,
	},1)
	_backBtn:setScale(0.8)
	_backBtn:setTouchEndedCallback(function( )
		cc.Director:getInstance():popScene()
	end)
	self:addChild(_backBtn)
	_backBtn:setPosition(self:getContentSize().width - _backBtn:getBoundingBox().width / 2 - 5,self:getContentSize().height - _backBtn:getBoundingBox().height / 2 - 3)
	-------右边显示队伍的容器
	local _teamContainer = ccui.Layout:create()
	_teamContainer:setContentSize(cc.size(635,back:getContentSize().height - 20))
	back:addChild(_teamContainer)
	_teamContainer:setAnchorPoint(0,0.5)
	self:initListView(_teamContainer)
	-------左边建筑及属性的盛放容器
	local _buildContainer = ccui.Layout:create()
	_buildContainer:setContentSize(cc.size(261,back:getContentSize().height - 20))
	back:addChild(_buildContainer)
	_buildContainer:setAnchorPoint(0,0.5)

	local x = _teamContainer:getContentSize().width + _buildContainer:getContentSize().width + 10 
	x = (back:getContentSize().width - x) / 2
	_buildContainer:setPosition(x+10,back:getContentSize().height / 2 - 57-20)
	_teamContainer:setPosition(x + _buildContainer:getContentSize().width + 10,_buildContainer:getPositionY())
	-----标题条
	local titleBg = cc.Sprite:create("res/image/camp/camp_label19.png")
	_teamContainer:addChild(titleBg)
	titleBg:setAnchorPoint(0.5,1)
	titleBg:setPosition(_teamContainer:getContentSize().width / 2,_teamContainer:getContentSize().height - 10)
	------确定按钮
	local _sureButton = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		text = LANGUAGE_KEY_SUREMOVETO,
		fontColor = cc.c3b(255,255,255),
		fontSize = 20,
	})
	_sureButton:setScale(0.8)
	_teamContainer:addChild(_sureButton)
	_sureButton:setPosition(_teamContainer:getContentSize().width / 2+190,_sureButton:getContentSize().height / 2 + 30+80)
	_sureButton:setTouchEndedCallback(function( )
		self:reassignTeams()
	end)
	---城市建筑图标 
	local buildIcon = cc.Sprite:create("res/image/camp/map/camp_buildSmall"..self.__cityID..".png")
	_buildContainer:addChild(buildIcon)
	buildIcon:setAnchorPoint(0.5,1)
	buildIcon:setPosition(_buildContainer:getContentSize().width / 2,_buildContainer:getContentSize().height - 30)
	----城市名字
	local nameIcon = cc.Sprite:create("res/image/camp/map/camp_cityName_yellow"..self.__cityID..".png")
	buildIcon:addChild(nameIcon)
	nameIcon:setAnchorPoint(0,0.5)
	----等级 
	local _level = XTHDLabel:create("LV:"..ZhongZuDatas._serverSelfCityDatas.cityLevel,24,"res/fonts/def.ttf")
	_level:setColor(cc.c3b(254,239,0))
	_level:enableShadow(cc.c4b(253,239,0,0xff),cc.size(1,0))
	_level:setAnchorPoint(0,0.5)
	buildIcon:addChild(_level)

	local x = nameIcon:getContentSize().width + _level:getContentSize().width
	x = (buildIcon:getContentSize().width - x) / 2
	nameIcon:setPosition(x,nameIcon:getContentSize().height / 2)
	_level:setPosition(nameIcon:getPositionX() + nameIcon:getContentSize().width,nameIcon:getPositionY())
	-----白背景
	local _bg = cc.Sprite:create("res/image/camp/camp_bg6.png")
	_buildContainer:addChild(_bg)
	_bg:setAnchorPoint(0.5,1)
	_bg:setPosition(_buildContainer:getContentSize().width / 2,buildIcon:getPositionY() - buildIcon:getContentSize().height - 15)
	-----buff效果提示字
	local _castellenLabel = cc.Sprite:create("res/image/camp/camp_label20.png")
	_bg:addChild(_castellenLabel)
	_castellenLabel:setAnchorPoint(0.5,1)
	_castellenLabel:setPosition(_bg:getContentSize().width / 2,_bg:getContentSize().height - 7)
	----------属性
	local _propData = ZhongZuDatas:getCityPropByLevel(self._cityLevel,self.__cityID)
	local x,y = _bg:getContentSize().width * 2/3,_castellenLabel:getPositionY() - _castellenLabel:getContentSize().height - 8
	for k,v in pairs(_propData) do 
		------属性名
		local _name = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_BUILDPROPERTY[v.propID]..":",XTHD.SystemFont,18)
		_name:setColor(cc.c3b(255,255,255))
		_name:setAnchorPoint(1,1)
		_bg:addChild(_name)
		_name:setPosition(x,y)
		-----原来的值
		local _val = v.propCur 
		if v.propID ~= 6 and v.propID ~= 7 then 
			_val = _val.."%"
		end 
		local _preVal = XTHDLabel:createWithSystemFont(_val,XTHD.SystemFont,20)
		_preVal:setColor(cc.c3b(30,255,0))
		_preVal:setAnchorPoint(0,0.5)
		_bg:addChild(_preVal)
		_preVal:setPosition(_name:getPositionX() + 2,_name:getPositionY() - _name:getContentSize().height / 2)
		-----线
		if k < 5 then 
			local _line = cc.Sprite:create("res/image/common/line3.png")
			_bg:addChild(_line)
			_line:setAnchorPoint(0.5,1)
			_line:setPosition(_bg:getContentSize().width / 2,_name:getPositionY() - _name:getContentSize().height - 3)

			y = _line:getPositionY() - 10
		end 
	end 	
end

function ZhongZuReassignForHost:initListView(targ)
	posy = targ:getContentSize().height - 45
	for i = 1,3 do 		
		local data = ZhongZuDatas._serverSelfDefendTeam.teams[i]
		local node = self:createListCell(i,data)
		targ:addChild(node)
		node:setAnchorPoint(0,1)
		node:setPosition(3,posy)
		posy = posy - node:getContentSize().height - 5
	end 
end 

function ZhongZuReassignForHost:createListCell( indx,data)
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")	
	bg:setContentSize(663,120)
	bg:setTag(indx)
	bg:setScaleX(0.95)
	local node = ccui.Layout:create()
	node:setContentSize(cc.size(bg:getBoundingBox().width,bg:getContentSize().height))
	node:setAnchorPoint(0.5,0.5)
	bg:addChild(node)
	node:setPosition(bg:getBoundingBox().width / 2,bg:getContentSize().height / 2)
	--防守位置背景
	local world_bg = ccui.Scale9Sprite:create("res/image/plugin/saint_beast/title_bg2.png")
	world_bg:setAnchorPoint(0,0.5)
	world_bg:setPosition(17,node:getContentSize().height - world_bg:getContentSize().height / 2 - 7)
	node:addChild(world_bg)
	----防守位置 
	local _word = cc.Sprite:create("res/image/camp/camp_adjust_word2.png")
	node:addChild(_word)
	_word:setAnchorPoint(0,0.5)
	_word:setPosition(17,node:getContentSize().height - _word:getContentSize().height / 2 - 12)
	--城池名字
	local _name = cc.Sprite:create("res/image/camp/map/camp_label6.png")
	if data and data.cityId > 0 then 
		_name = cc.Sprite:create("res/image/camp/map/camp_cityName_yellow"..data.cityId..".png")		
	end 
	node:addChild(_name)
	_name:setAnchorPoint(0,0.5)
	_name:setPosition(_word:getPositionX() + _word:getContentSize().width + 10,_word:getPositionY())
	---队数
	local _teams = cc.Sprite:create("res/image/camp/map/camp_team"..indx..".png")
	node:addChild(_teams)
	_teams:setScale(0.8)
	_teams:setAnchorPoint(0,1)
	_teams:setPosition(10,_word:getPositionY() - 20)	
	
	if data then 
		--调整按钮
		local _path2 = "res/image/plugin/hero/item_bg.png"
		local _path1 = "res/image/friends/friendPic_46.png"
		local button = ccui.CheckBox:create(_path2,_path2,_path1,_path1,_path1)
	    button:addEventListener(function(sender,eventType)
	    	if sender.canPoint == false then
		    	XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS33) ------当前队伍正在防守该城市
	    		sender:setSelected(true)
	    	else 
		        local selected = sender:isSelected()
		        if self._selectedNode then 
		        	self._selectedNode:setSelected(false)
		        end 
		        if selected then 
		        	button:setSelected(true)
		        	self._selectedTeamID = button:getTag()
		        	self._selectedNode = button
		        else 
		        	self._selectedTeamID = 0        	
		        	self._selectedNode = nil
		        end 
		    end 
	    end)
		button:setTag(data.teams[1].teamId)
		node:addChild(button)
		node.checkBtn = button		
		button:setAnchorPoint(1,0.5)
		button.canPoint = true ------当前队伍是否能够指定
		button:setPosition(node:getContentSize().width - 5,node:getContentSize().height * 1/3)
		if tonumber(data.cityId) == self.__cityID then 
			button:setSelected(true)
			button.canPoint = false
		end 
		local x = button:getPositionX() - button:getBoundingBox().width - 5
		--------战斗力logo
		local _icon = cc.Sprite:create("res/image/common/fightValue_Image.png")
		node:addChild(_icon)
		_icon:setAnchorPoint(0,0.5)
		_icon:setScale(0.8)
		_icon:setPosition(_teams:getPositionX() + _teams:getContentSize().width + 5,node:getContentSize().height * 1/3)
		---值 
		local _value = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",data.teams[1].power)
		_value:setAdditionalKerning(-2)
		node:addChild(_value)
		_value:setAnchorPoint(0,0.5)
		_value:setPosition(_icon:getPositionX() + _icon:getBoundingBox().width,_icon:getPositionY() - 5)
		-----头像们
		x = x - 47 * 5
		local space = 6
		for i = 1,5 do 
			local v = data.teams[1].heros[i]
			local head = nil 
			if v then 
				head = HeroNode:createWithParams({
					heroid = v.petId,
					star = v.star,
					level = v.level,
					needHp = true,
					curNum = v.curHp,
					maxNum = v.property['200'],
					advance = v.phase,
				})
				head:setScale(0.57)
			else 
				head = cc.Sprite:create("res/image/common/no_hero.png")
				head:setScale(0.65)
			end 
			node:addChild(head)
			head:setAnchorPoint(1,0.5)
			head:setPosition(x,button:getPositionY()+6)
			x = x + head:getBoundingBox().width + space
		end 
	else 		
		local _label = XTHDLabel:createWithParams({
			text = LANGUAGE_CAMP_TIPSWORDS13,
			fontSize = 18,
			color = cc.c3b(255,161,60),
		})
		node:addChild(_label)
		_label:setPosition(node:getContentSize().width / 2,node:getContentSize().height * 1/3)
	end 
	-- bg:setTouchEndedCallback(function( )
	-- 	if node.checkBtn then 
	-- 		if node.checkBtn.canPoint then 
	-- 			local isSelected = node.checkBtn:isSelected()
	-- 			node.checkBtn:setSelected(not isSelected)
	-- 	        if self._selectedNode then 
	-- 	        	self._selectedNode:setSelected(false)
	-- 	        end 
	-- 	        if not isSelected then ----选中
	-- 	        	node.checkBtn:setSelected(true)
	-- 	        	self._selectedTeamID = node.checkBtn:getTag()
	-- 	        	self._selectedNode = node.checkBtn
	-- 	        else ----没选中
	-- 	        	self._selectedTeamID = 0
	-- 	        	self._selectedNode = nil
	-- 	        end 		        
	-- 	    else 
	-- 	    	XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS33) ------当前队伍正在防守该城市
	-- 	    	node.checkBtn:setSelected(true)
	-- 	    end 
	-- 	end 
	-- end)
	return bg
end

function ZhongZuReassignForHost:reassignTeams( )	
	if self._selectedTeamID > 0 then 
		ClientHttp:requestAsyncInGameWithParams({
	        modules = "replaceCityDefendTeam?",
	        params = {teamId = self._selectedTeamID},
	        successCallback = function(net_data)
	            if tonumber(net_data.result) == 0 then
	            	self:refreshMapData()
	            else
	            	XTHDTOAST(net_data.msg)	            
	            end
	        end,--成功回调
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
	        end,--失败回调
	        targetNeedsToRetain = self,--需要保存引用的目标
	        loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	else 
		XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS26) -----请指定一个队伍防守该城市 
	end 
end

function ZhongZuReassignForHost:refreshMapData( )
	ZhongZuDatas.requestServerData({
		success = function( )
			ZhongZuDatas.requestServerData({
				target = self,
				method = "selfCampCityList?",
				success = function( )
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_CAMP_SELFCITIES})
	            	cc.Director:getInstance():popScene()
				end,
			})
		end,
		method = "searchMyDefendGroup?",
        target = self,
	})	
end

return ZhongZuReassignForHost