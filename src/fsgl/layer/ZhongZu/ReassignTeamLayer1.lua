--[[
指定种族的防守队伍到指定的城市
]]
local ReassignTeamLayer1 = class("ReassignTeamLayer1",function( )
	return XTHDDialog:create()
end)

function ReassignTeamLayer1:ctor(cityID,parent)
	self.__cityID = cityID
	self.__parent = parent
	
	self._header = nil ----护城大侠数据 

	self._selectedTeam = {}

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

function ReassignTeamLayer1:create(cityID,parent)
	local layer = ReassignTeamLayer1.new(cityID,parent)
	if layer then 
		layer:init()
	end	 
	return layer
end 

function ReassignTeamLayer1:init( )
	self._header = self:findTheHeader()

	local bg = cc.Sprite:create("res/image/camp/camp_bg2.png")
	self:addChild(bg)
	bg:setContentSize(cc.Director:getInstance():getWinSize())
	bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	----返回按钮
	local _backBtn = XTHD.createNewBackBtn(function( )
		self:removeFromParent()
	end)
	self:addChild(_backBtn)
	_backBtn:setPosition(self:getContentSize().width,self:getContentSize().height)
	---背景
	local back = ccui.Scale9Sprite:create()	
	back:setContentSize(1024,483)
	back:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self:addChild(back)
	-----标题条
	local titleBg = cc.Sprite:create("res/image/camp/map/camp_label5.png")
	back:addChild(titleBg)
	titleBg:setAnchorPoint(0.5,1)
	titleBg:setPosition(back:getContentSize().width / 2 + 30,back:getContentSize().height - titleBg:getContentSize().height - 10)
	----城市名字
	local cityName = cc.Sprite:create("res/image/camp/map/camp_cityName_yellow"..self.__cityID..".png")
	back:addChild(cityName)
	cityName:setAnchorPoint(0,0.5)
	cityName:setPosition(titleBg:getPositionX() + titleBg:getContentSize().width / 2,titleBg:getPositionY() - titleBg:getContentSize().height / 2)
	------确定按钮
	local _sureButton = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		btnSize = cc.size(278,49),
		text = "确认保存"
	})
	back:addChild(_sureButton)
	_sureButton:setScale(0.7)
	_sureButton:setPosition(back:getContentSize().width * 3/5,_sureButton:getContentSize().height / 2 -20)
	_sureButton:setTouchEndedCallback(function( )
		self:reassignTeams()
	end)
	----按钮上的字
    -- local _word = cc.Sprite:createWithSpriteFrame(XTHD.resource.getButtonImgFrame("querenbaocun_lv"))
    -- _sureButton:addChild(_word)
    -- _word:setPosition(_sureButton:getContentSize().width / 2,_sureButton:getContentSize().height / 2)
	----左边的人
	self:createTeamHeader(back)
	
	self:initListView(back,titleBg:getPositionY() - titleBg:getContentSize().height)
end

function ReassignTeamLayer1:initListView(targ,posy)
	posy = posy - 10
	for i = 1,3 do 		
		local data = ZhongZuDatas._serverSelfDefendTeam.teams[i]
		local node = self:createListCell(i,data)
		targ:addChild(node)
		node:setAnchorPoint(0.5,1)
		node:setPosition(targ:getContentSize().width * 3/5 + 30,posy)
		posy = posy - node:getContentSize().height - 5
	end 
end 

function ReassignTeamLayer1:createListCell( indx,data)
	-- local node = XTHDImage:create("res/image/common/scale9_bg_32.png")	
	local node = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")	
	node:setContentSize(663,120)
	node:setTag(indx)
	local world_bg = ccui.Scale9Sprite:create("res/image/plugin/saint_beast/title_bg2.png")
	world_bg:setAnchorPoint(0,0.5)
	world_bg:setPosition(17,node:getContentSize().height - world_bg:getContentSize().height / 2 - 7)
	node:addChild(world_bg)
	----防守位置 
	local _word = cc.Sprite:create("res/image/camp/camp_adjust_word2.png")
	node:addChild(_word)
	_word:setAnchorPoint(0,0.5)
	_word:setPosition(17,node:getContentSize().height - _word:getContentSize().height / 2 - 17)
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
	_teams:setPosition(10,_word:getPositionY() - 18)	
	
	if data then 
		--调整按钮
		local _path2 = "res/image/plugin/hero/item_bg.png"
		local _path1 = "res/image/friends/friendPic_46.png"
		local button = ccui.CheckBox:create(_path2,_path2,_path1,_path1,_path1)		
	    button:addEventListener(function(sender,eventType) 
	        local selected = sender:isSelected()
	        if selected then 
	        	self._selectedTeam[button:getTag()] = button:getTag()
	        else 
	        	self._selectedTeam[button:getTag()] = nil        	
	        end 
	    end)
		button:setTag(indx)
		node:addChild(button)
		node.checkBtn = button
		button:setAnchorPoint(1,0.5)	
		button:setPosition(node:getContentSize().width - 5,node:getContentSize().height * 1/3+5)
		if tonumber(data.cityId) == self.__cityID then 
			button:setSelected(true)
			self._selectedTeam[button:getTag()] = button:getTag()
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
		_value:setScale(0.8)
		_value:setPosition(_icon:getPositionX() + _icon:getBoundingBox().width,_icon:getPositionY() - 3)
		-----头像们
		x = x - 50 * 5-5
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
				head:setScale(0.6)
			end 
			node:addChild(head)
			head:setAnchorPoint(1,0.5)
			head:setPosition(x,button:getPositionY())
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
	-- node:setTouchEndedCallback(function( )
	-- 	if node.checkBtn then 
	-- 		local isSelected = node.checkBtn:isSelected()
	-- 		node.checkBtn:setSelected(not isSelected)
	--         if not isSelected then ----选中
	--         	self._selectedTeam[node.checkBtn:getTag()] = node.checkBtn:getTag()
	--         else ----没选中
	--         	self._selectedTeam[node.checkBtn:getTag()] = nil
	--         end 
	-- 	end 
	-- end)
	return node
end
-----创建护城大侠
function ReassignTeamLayer1:createTeamHeader(targ)
	if targ and next(self._header) then 
		------皇冠
		local _crown = cc.Sprite:create("res/image/ranklistreward/1.png")
		targ:addChild(_crown)
		_crown:setAnchorPoint(0,0.5)
		local _header = cc.Sprite:create("res/image/camp/map/camp_header_label.png")
		targ:addChild(_header)
		_header:setAnchorPoint(0,0.5)
		local x = _crown:getContentSize().width + _header:getContentSize().width 
		_crown:setPosition((targ:getContentSize().width * 1/6 - 20) - x / 2,targ:getContentSize().height - 60)
		_header:setPosition(_crown:getPositionX() + _crown:getContentSize().width,_crown:getPositionY())
		---玩家名字
		x = targ:getContentSize().width * 1/6 - 10
		local name = XTHDLabel:create(self._header.name,22,"res/fonts/def.ttf")
		targ:addChild(name)
		name:setPosition(x,_crown:getPositionY() - _crown:getContentSize().height + 10)
		----等级 
		local level = XTHDLabel:create("LV:"..self._header.level,20,"res/fonts/def.ttf")
		level:setColor(cc.c3b(199,174,3))
		targ:addChild(level)
		level:setPosition(name:getPositionX(),name:getPositionY() - name:getContentSize().height)
		-----spine
		local _path = "res/spine/"..string.format("%03d",self._header.pet.petId)
		local _spine = sp.SkeletonAnimation:createWithBinaryFile(_path..".skel",_path..".atlas",1.0)
		local _node = cc.Node:create()
		_spine:setAnimation(0,"idle",true)
		_node:addChild(_spine)
		targ:addChild(_node,1)
		_node:setPosition(level:getPositionX(),110)
		-----ellipse
		local _ellipse = cc.Sprite:create("res/image/camp/map/camp_ellipse.png")
		targ:addChild(_ellipse)
		_ellipse:setScale(0.8)
		_ellipse:setPosition(_node:getPositionX(),_node:getPositionY())
		--------战斗力logo		
		local _fightVim = cc.Node:create()
		local _icon = cc.Sprite:create("res/image/common/fightValue_Image.png")
		_fightVim:addChild(_icon)
		_icon:setAnchorPoint(0,0.5)
		_icon:setScale(0.8)
		----值 
		local _value = cc.Label:createWithBMFont("res/fonts/baisezi.fnt",self._header.pet.power)
		_value:setAdditionalKerning(-2)
		_fightVim:addChild(_value)
		_value:setAnchorPoint(0,0.5)

		_fightVim:setContentSize(cc.size(_icon:getBoundingBox().width + _value:getBoundingBox().width,_icon:getBoundingBox().height))
		_icon:setPosition(0,_fightVim:getContentSize().height / 2)
		_value:setPosition(_icon:getPositionX() + _icon:getBoundingBox().width,_icon:getPositionY() - 10)

		targ:addChild(_fightVim)
		_fightVim:setAnchorPoint(0.5,1)
		_fightVim:setPosition(name:getPositionX(),_ellipse:getPositionY() - _ellipse:getContentSize().height / 2 - 10)
	end 
end
-----查找护城大侠的
function ReassignTeamLayer1:findTheHeader( )
	local data = ZhongZuDatas._serverSelfCityDatas 
	local header = {}
	if data then 
		table.sort(data.teams,function(a,b)
			return tonumber(a.team[1].power) > tonumber(b.team[1].power)
		end)
		data = ZhongZuDatas._serverSelfCityDatas.teams[1]
		if data then 
			header.name = data.name
			header.level = data.level
			local power = 0
			for i = 1,#data.team[1].heros do 
				if tonumber(data.team[1].heros[i].power) > power then 
					power = tonumber(data.team[1].heros[i].power)
					header.pet = data.team[1].heros[i]
				end 
			end 
		end 
	end 
	return header
end

function ReassignTeamLayer1:reassignTeams( )
	local newTeam = {}
	for i = 1,3 do 
		local data = ZhongZuDatas._serverSelfDefendTeam.teams[i]
		local _table = {}
		if data then 
			_table.teamId = data.teams[1].teamId
			_table.cityId = data.cityId
			if not self._selectedTeam[i] and data.cityId == self.__cityID then 
				_table.cityId = 0
			elseif i == self._selectedTeam[i] then 
				_table.cityId = self.__cityID
			end 
			_table.petIds = {}
			for j = 1,#data.teams[1].heros do 
				_table.petIds[#_table.petIds + 1] = data.teams[1].heros[j].petId
			end 	
		else
			_table = {
				teamId = i,
				cityId = 0,
				petIds = {}
			}
		end 	
		newTeam[#newTeam +1] = _table
	end 
	if next(newTeam) then 
		newTeam = json.encode(newTeam)	
		ClientHttp:requestAsyncInGameWithParams({
	        modules = "setCampGroup?",	        
	        params = {teams = newTeam},
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
	end 
end

function ReassignTeamLayer1:refreshMapData( )
	ZhongZuDatas.requestServerData({
		success = function( )
			ZhongZuDatas.requestServerData({
				target = self,
				method = "selfCampCityList?",
				success = function( )
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_CAMP_SELFCITIES})
					self:removeFromParent()			
				end,
			})
		end,
		method = "searchMyDefendGroup?",
        target = self,
	})	
end

return ReassignTeamLayer1