--[[
参战
]]
local ChooseOPLayer1 = class("ChooseOPLayer1",function( )
	return XTHDDialog:create()
end)

function ChooseOPLayer1:ctor(parent )
	self._armyList = nil
	self._warOverCountdown = nil ---种族战结束的倒计时
	self.__isAtChanllengeCD = false ---是否处于挑战冷却
	self._parent = parent
	self._backBG = nil
	self._fightCD = {
		label = nil,
		time = nil,
	}
	self._warriorPortrait = nil -----

	self.Tag = {
		ktag_actionCountdownCD = 100, ---倒计时
		ktag_actionFightCD = 101,
	}
	
    self:sortDatas()
end

function ChooseOPLayer1:create(parent)
	local _layer = ChooseOPLayer1.new(parent)
	if _layer then 
		_layer:init()
	end 
	return _layer
end

function ChooseOPLayer1:init( )
	local bg = cc.Sprite:create("res/image/camp/camp_bg2.jpg")
	self:addChild(bg)
	bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	----返回按钮
	local _backBtn = XTHD.createNewBackBtn(function( )
		self._parent:startFightAginCD(true)
		self:removeFromParent()
	end)
	self:addChild(_backBtn)
	_backBtn:setPosition(self:getContentSize().width,self:getContentSize().height)
	---背景
	local back = cc.Sprite:create("res/image/camp/camp_bg3.png")	
	back:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self:addChild(back)
	self._backBG = back
	-----标题条
	local _tipsLabel = cc.Sprite:create("res/image/camp/camp_fight_tips2.png")
	back:addChild(_tipsLabel)
	_tipsLabel:setAnchorPoint(0,0.5)
	_tipsLabel:setPosition(back:getContentSize().width * 3/8 + 20,back:getContentSize().height - 45)
	---结束时间提醒 
	local _timeTips = cc.Sprite:create("res/image/camp/camp_remainder_time.png")
	back:addChild(_timeTips)
	_timeTips:setAnchorPoint(0,0.5)
	_timeTips:setPosition(back:getContentSize().width * 2/3 + 30,_tipsLabel:getPositionY())
	local _time = getCdStringWithNumber(60,{m = LANGUAGE_UNKNOWN.minute,s = LANGUAGE_UNKNOWN.second,h = LANGUAGE_UNKNOWN.hour})
	_time = XTHDLabel:createWithSystemFont(_time,XTHD.SystemFont,16)
	back:addChild(_time)
	_time:setAnchorPoint(0,0.5)
	_time:setPosition(_timeTips:getPositionX() + _timeTips:getContentSize().width,_tipsLabel:getPositionY())
	self._warOverCountdown = _time
	--------更换对手
	local _button = XTHD.createCommonButton({
    	btnColor = "write_1",
    	btnSize = cc.size(130,49),
		text = LANGUAGE_KEY_CHANGE_ENEMY,
		isScrollView = false,
    	fontSize = 22,
	})
	_button:setScale(0.8)
	back:addChild(_button)
	_button:setPosition(back:getContentSize().width - _button:getContentSize().width,_button:getContentSize().height / 2)
	_button:setTouchEndedCallback(function( )
		self:changeEnemys()
	end)
	---字
	-- local _word = XTHD.resource.getButtonImgTxt("genghuanduishou_lan")
	-- _button:addChild(_word)
	-- _word:setPosition(_button:getContentSize().width / 2,_button:getContentSize().height / 2)
	------战斗 CD 
	local _label = cc.Sprite:create("res/image/camp/map/camp_label10.png")
	back:addChild(_label)
	_label:setAnchorPoint(0,0.5)
	_label:setPosition(back:getBoundingBox().width / 2 - _label:getBoundingBox().width + 15,_button:getPositionY())
	self._fightCD.label = _label
	---CD
	local _value = XTHDLabel:createWithSystemFont(0,XTHD.SystemFont,22)
	back:addChild(_value)
	_value:setAnchorPoint(0,0.5)
	_value:setPosition(_label:getPositionX() + _label:getBoundingBox().width,_label:getPositionY())
	self._fightCD.time = _value
	if not self._serverEnemyCityDatas or not self._serverEnemyCityDatas.cd then 
		_label:setVisible(false)
		_value:setVisible(false)
	end 

	local _size = cc.size(530,350)
	self:initArmyList(back,_size)
	self:refreshUI()
	self:initWarrior(back)
end

function ChooseOPLayer1:initArmyList(targ,viewSize)
    local cellSize = cc.size(viewSize.width,115)
    
    local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
    	return #ZhongZuDatas._serverEnemyDatas.rivalTeams
    end

    local function tableCellTouched(table,cell)    
    	self:showTeamInfo(cell:getIdx() + 1)
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(cellSize.width,cellSize.height)
        else 
            cell:removeAllChildren()
        end
        local node = self:createArmyCell(idx + 1)
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        return cell
    end

    local tableView = CCTableView:create(viewSize)
    tableView:setPosition(targ:getContentSize().width * 3/8 + 20,70)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    targ:addChild(tableView)
    self._armyList = tableView
end

function ChooseOPLayer1:createArmyCell( index )
	local _bg = cc.Sprite:create("res/image/camp/camp_armycell_bg.png")
	local _data = ZhongZuDatas._serverEnemyDatas
	if _data and _data.rivalTeams then 
		_data = _data.rivalTeams[index]
	end 
	if _data then 
		-----头像
		local _head = ZhongZuDatas:createCampHeroIcon( _data.templateId,_data.level,0.75 )
		_bg:addChild(_head)
		_head:setAnchorPoint(0,0.5)
		_head:setPosition(15,_bg:getContentSize().height / 2)
		----名字
		local _name = XTHDLabel:createWithSystemFont(_data.name,XTHD.SystemFont,20)
		_bg:addChild(_name)
		_name:setAnchorPoint(0,0.5)
		_name:setPosition(_head:getPositionX() + _head:getBoundingBox().width + 10,_bg:getContentSize().height * 3/4)
		----挑战
		local _challengBtn = XTHD.createCommonButton({
	        btnColor = "write_1",
	        btnSize = cc.size(130,49),
			text = LANGUAGE_VERBS.challenge,
			isScrollView = true,
	        fontSize = 22,
		})
		_challengBtn:setScale(0.8)
		_bg:addChild(_challengBtn)
		_challengBtn:setTag(index)
		_challengBtn:setPosition(_bg:getContentSize().width - _challengBtn:getBoundingBox().width / 2 - 15,_bg:getContentSize().height * 1/2)
		_challengBtn:setTouchEndedCallback(function( )
			self:doChallenge(_challengBtn:getTag())
		end)
		------字
		-- local _word = XTHD.resource.getButtonImgTxt("tiaozhan_hong")
		-- _challengBtn:addChild(_word)
		-- _word:setPosition(_challengBtn:getBoundingBox().width / 2,_challengBtn:getBoundingBox().height / 2)
		----战斗力
		local _vimLabel = cc.Sprite:create("res/image/camp/camp_fight_vim.png")
		_bg:addChild(_vimLabel)
		_vimLabel:setAnchorPoint(0,0.5)
		_vimLabel:setPosition(_name:getPositionX(),_challengBtn:getPositionY() - 10)
		---------
		local _value = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",_data.team[1].power)
		_value:setAdditionalKerning(-2)
		_bg:addChild(_value)
		_value:setAnchorPoint(0,0.5)
		_value:setPosition(_vimLabel:getPositionX() + _vimLabel:getContentSize().width,_vimLabel:getPositionY())
	end 
	return _bg
end

function ChooseOPLayer1:doChallenge(index)
	if not self.__isAtChanllengeCD then  --开战
		if ZhongZuDatas._serverEnemyDatas and ZhongZuDatas._serverEnemyDatas.rivalTeams then 
			local data = ZhongZuDatas._serverEnemyDatas.rivalTeams[index]	
			----添加开战代码
			local hero_data = self:ConstructDataForbattle()
			-- local hero_data = {}
			LayerManager.addShieldLayout()
			local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):createWithParams({
		 		battle_type = BattleType.CAMP_PVP,
		 		Camp_data = hero_data,
		 		Camp_enemy_Data = data
		 	})
			fnMyPushScene(_layer)	 
			self:removeFromParent()
		end 
	else 			 --清除CD
		if not ZhongZuDatas._serverEnemyCityDatas then 
			return 
		end 
		local money =  tonumber(ZhongZuDatas._serverEnemyCityDatas.clearCdSum)			
		if not money then 
			return 
		end 
		local CD = tonumber(ZhongZuDatas._serverEnemyCityDatas.cd)
		money = math.ceil(CD / 60) * (money + 50)
		local str = LANGUAGE_CAMP_TIPSWORDS16(money)
		local layer = XTHDConfirmDialog:createWithParams({
	  		msg = str,
	        rightCallback = function( )		        	
		        ZhongZuDatas.requestServerData({
        			target = self,
		        	method = "clearCampCd?",
		        	success = function(data)
		        		ZhongZuDatas._serverEnemyCityDatas.clearCdSum = data.clearCdSum
		        		ZhongZuDatas._serverEnemyCityDatas.cd = 0
		        		gameUser.setIngot(tonumber(data.gold))
    					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，
    					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
		        		self.__isAtChanllengeCD = false
	                    self._fightCD.time:stopActionByTag(self.Tag.ktag_actionFightCD)
	                    self._fightCD.time:setVisible(false)
	                    self._fightCD.label:setVisible(false)
		        	end
		        }) 
	        end
	  	})
		self:addChild(layer)	
	end 	  	
end

function ChooseOPLayer1:initWarrior( targ )
	local _data = ZhongZuDatas._serverEnemyDatas.fristRankChar
	------皇冠
	local _crown = cc.Sprite:create("res/image/common/crown_icon.png")
	targ:addChild(_crown)
	_crown:setAnchorPoint(0,0.5)
	local _header = cc.Sprite:create("res/image/camp/map/camp_header_label2.png")
	targ:addChild(_header)
	_header:setAnchorPoint(0,0.5)
	local x = _crown:getContentSize().width + _header:getContentSize().width 
	local mid = targ:getContentSize().width * 1/5 + 10
	_crown:setPosition(mid - x / 2,targ:getContentSize().height - 50)
	_header:setPosition(_crown:getPositionX() + _crown:getContentSize().width,_crown:getPositionY())	
	-----第一名人物形像
	self._warriorPortrait = self:createWarrior()
	targ:addChild(self._warriorPortrait)
	self._warriorPortrait:setPosition(mid,targ:getBoundingBox().height / 2)	
	-----击杀排行按钮
	local _button = XTHD.createCommonButton({
    	btnColor = "write_1",
		btnSize = cc.size(130,49),
		isScrollView = false,
    	text = LANGUAGE_CAMP_ATTACKRANK,
    	fontSize = 22,
	})
	_button:setScale(0.8)
	targ:addChild(_button)
	_button:setPosition(mid,_button:getBoundingBox().height / 2 + 15)
	_button:setTouchEndedCallback(function( )
		requires("src/fsgl/layer/ZhongZu/ZhongZuMap.lua"):showATKRankList( self )
	end)
	----字
	-- local _word = XTHD.resource.getButtonImgTxt("jishapaihang_lan")
	-- _button:addChild(_word)
	-- _word:setPosition(_button:getContentSize().width / 2,_button:getContentSize().height / 2)
end

function ChooseOPLayer1:createWarrior()
	local _heroPor = cc.Node:create()
	_heroPor:setContentSize(cc.size(319,324))
	_heroPor:setAnchorPoint(0.5,0.5)
	local _data = ZhongZuDatas._serverEnemyDatas.fristRankChar
	if next(_data) ~= nil then 
		---玩家名字
		local name = XTHDLabel:createWithSystemFont(_data.name,XTHD.SystemFont,22)
		_heroPor:addChild(name)
		name:setAnchorPoint(0,0.5)
		----等级 
		local level = XTHDLabel:createWithSystemFont("Lv:".._data.level,XTHD.SystemFont,20)
		level:setColor(cc.c3b(199,174,3))
		_heroPor:addChild(level)
		level:setAnchorPoint(0,0.5)
		x = name:getContentSize().width + level:getContentSize().width	
		name:setPosition((_heroPor:getContentSize().width - x) / 2,_heroPor:getContentSize().height - name:getBoundingBox().height + 20)
		level:setPosition(name:getPositionX() + name:getContentSize().width,name:getPositionY())
		-----击杀数量
		local _label = XTHDLabel:createWithSystemFont(LANGUAGE_TIP_KILL_NUMBER..":",XTHD.SystemFont,18)
		_heroPor:addChild(_label)
		_label:setAnchorPoint(0,0.5)
		_label:setColor(cc.c3b(199,174,3))
		_label:enableShadow(cc.c4b(0,0,0,255),cc.size(1,0))
		----数量
		local _value = XTHDLabel:createWithSystemFont(_data.killSum,XTHD.SystemFont,22)
		_heroPor:addChild(_value)
		_value:setAnchorPoint(0,0.5)
		_value:setColor(cc.c3b(199,174,3))
		_value:enableShadow(cc.c4b(0,0,0,255),cc.size(1,0))
		x = _label:getContentSize().width + _value:getContentSize().width
		_label:setPosition((_heroPor:getContentSize().width - x) / 2,name:getPositionY() - name:getContentSize().height)
		_value:setPosition(_label:getPositionX() + _label:getContentSize().width,_label:getPositionY())
		-----spine
		local _path = string.format("res/spine/%03d",_data.petId)
		local _spine = sp.SkeletonAnimation:createWithBinaryFile(_path..".skel",_path..".atlas",1.0)
		_spine:setScale(0.75)
		local _node = cc.Node:create()
		_spine:setAnimation(0,"idle",true)
		_node:addChild(_spine)
		_heroPor:addChild(_node,1)
		_node:setPosition(_heroPor:getContentSize().width / 2,_label:getPositionY() - 190)
		-----ellipse
		local _ellipse = cc.Sprite:create("res/image/camp/map/camp_ellipse.png")
		_heroPor:addChild(_ellipse)
		_ellipse:setPosition(_node:getPositionX(),_node:getPositionY() - 10)
		-----星星
		local _star = self:initHeroStar(_data.star)
		_heroPor:addChild(_star)
		_star:setAnchorPoint(0.5,0)
		_star:setPosition(_heroPor:getContentSize().width / 2,_ellipse:getPositionY() - _ellipse:getContentSize().height / 2 + 10)
		self._warriorStar = _star
		--------战斗力logo		
		local _fightVim = cc.Node:create()
		local _icon = cc.Sprite:create("res/image/common/fightValue_Image.png")
		_fightVim:addChild(_icon)
		_icon:setAnchorPoint(0,0.5)
		_icon:setScale(0.8)
		----值 
		_value = cc.Label:createWithBMFont("res/fonts/baisezi.fnt",_data.power)
		_value:setAdditionalKerning(-2)
		_fightVim:addChild(_value)
		_value:setAnchorPoint(0,0.5)

		_fightVim:setContentSize(cc.size(_icon:getBoundingBox().width + _value:getBoundingBox().width,_icon:getBoundingBox().height))
		_icon:setPosition(0,_fightVim:getContentSize().height / 2 - 10)
		_value:setPosition(_icon:getPositionX() + _icon:getBoundingBox().width,_icon:getPositionY() - 8)

		_heroPor:addChild(_fightVim)
		_fightVim:setAnchorPoint(0.5,1)
		_fightVim:setPosition(_node:getPositionX(),_ellipse:getPositionY() - _ellipse:getContentSize().height / 2)
	else 
		------虚位以待
		local _label = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_WAITTINGHEADER,XTHD.SystemFont,20)	
		_heroPor:addChild(_label)
		_label:setColor(cc.c3b(255,220,0))
		_label:setPosition(_heroPor:getContentSize().width / 2,_heroPor:getContentSize().height - _label:getContentSize().height)
		----问号
		local _mark = cc.Sprite:create("res/image/common/question.png")
		_heroPor:addChild(_mark)
		_mark:setPosition(_heroPor:getContentSize().width / 2,_heroPor:getContentSize().height / 2)
	end 
	return _heroPor
end

function ChooseOPLayer1:initHeroStar (starAmount)
	local _node = cc.Node:create()
	local x = 0
	local _height = 0
	local moonC = math.floor(starAmount/6)
	local starC = starAmount%6
	if starAmount <= 5 then
		for j=1,starAmount do
			local _star = cc.Sprite:create("res/image/common/star_icon.png")
			_node:addChild(_star)
			_star:setAnchorPoint(0,0.5)
			_star:setPosition(x,0)
			x = x + _star:getContentSize().width
			_height = _star:getContentSize().height
		end
	else
		for j = 1,moonC do
			local _star = cc.Sprite:create("res/image/common/moon_icon.png")
			_node:addChild(_star)
			_star:setAnchorPoint(0,0.5)
			_star:setPosition(x,0)
			x = x + _star:getContentSize().width
			_height = _star:getContentSize().height
		end
		for j = moonC + 1,moonC + starC do
			local _star = cc.Sprite:create("res/image/common/star_icon.png")
			_node:addChild(_star)
			_star:setAnchorPoint(0,0.5)
			_star:setPosition(x,0)
			x = x + _star:getContentSize().width
			_height = _star:getContentSize().height
		end
	end
	_node:setContentSize(cc.size(x,_height))
	_node:setAnchorPoint(0.5,0.5)
	return _node
end

function ChooseOPLayer1:showTeamInfo(index)
	local data = ZhongZuDatas._serverEnemyDatas.rivalTeams
	data = data and data[index] or nil
	if data then 
		local _infoLayer = requires("src/fsgl/layer/ZhongZu/EnemyTIFLayer1.lua")
		_infoLayer = _infoLayer:create(self,data)
		self:addChild(_infoLayer)
		_infoLayer:show()
	end 
end

function ChooseOPLayer1:refreshUI( )
	self:startWarOverCountdown()
	self:startFightAginCD()
end

function ChooseOPLayer1:startWarOverCountdown( )
	if self._warOverCountdown then 
		ZhongZuDatas:getWarOverCountDown(self._warOverCountdown,self.Tag.ktag_actionCountdownCD)
	end 
end

function ChooseOPLayer1:startFightAginCD( )
	if self._fightCD.time then 
		local _data = ZhongZuDatas._serverEnemyCityDatas
		if _data and _data.cd then 
			self._fightCD.time:setString(_data.cd)
			local _second = tonumber(_data.cd)
			if _second > 0  then 
				self.__isAtChanllengeCD = true
                self._fightCD.time:setVisible(true)
                self._fightCD.label:setVisible(true)
                self._fightCD.time:setString(_second)
			end 
			if not self._fightCD.time:getActionByTag(self.Tag.ktag_actionFightCD) then 
	            schedule(self._fightCD.time,function ( )
	                ZhongZuDatas._serverEnemyCityDatas.cd = ZhongZuDatas._serverEnemyCityDatas.cd - 1
	                if ZhongZuDatas._serverEnemyCityDatas.cd < 1 then 
	                    self._fightCD.time:stopActionByTag(self.Tag.ktag_actionFightCD)
	                    self._fightCD.time:setVisible(false)
	                    self._fightCD.label:setVisible(false)
						self.__isAtChanllengeCD = false
	                else 
	                    self._fightCD.time:setVisible(true)
	                    self._fightCD.label:setVisible(true)
	                    self._fightCD.time:setString(ZhongZuDatas._serverEnemyCityDatas.cd)
	                end 
	            end,1.0,self.Tag.ktag_actionFightCD)
	        end 
		end 
	end 
end
-----刷新对手
function ChooseOPLayer1:changeEnemys( )
	ZhongZuDatas.requestServerData({ --更换对手
    	target = self,
		method = "changeRival?",
		params = {cityId = self.__cityIndex},
		success = function( )	
			if self._armyList then 
				self._armyList:reloadData()
			end 
		end,
		failure = function(data)
			if data and data.result == 4801 then  ----城市已被占领
				self._parent:backToMap()
			elseif data and data.result == 4821 then ----种族战结束
				XTHD.dispatchEvent({name = CUSTOM_EVENT.CAMPWAR_OVERED})
			end 
		end
	})
end

--构建传入选人界面的数据，
function ChooseOPLayer1:ConstructDataForbattle()
	local _target_ = {}
	local teams_data = ZhongZuDatas._serverSelfDefendTeam["teams"]
	if teams_data then
		for i=1,#teams_data do
			if tonumber(teams_data[i].cityId) > 0 then 
				local _tmp_data = teams_data[i]["teams"][1]["heros"] or {}			
				if _tmp_data then
					for j=1,#_tmp_data do
						_target_[#_target_+1] = _tmp_data[j]["petId"]
					end
				end
			end 
		end
	end
	return _target_
end

function ChooseOPLayer1:sortDatas( )
	if ZhongZuDatas._serverEnemyDatas then 
		table.sort(ZhongZuDatas._serverEnemyDatas.rivalTeams,function( a,b )
			return a.team[1].power > b.team[1].power
		end)
	end 
end

return ChooseOPLayer1