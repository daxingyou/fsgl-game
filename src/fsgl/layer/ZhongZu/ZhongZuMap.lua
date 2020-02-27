--[[
authored by LITAO
种族战场的地图
]]
local ZhongZuMap = class("ZhongZuMap",function( )
	return cc.Layer:create()
end)

local scale_X = 1--宽度足够宽，无需缩放，不然有的城池无法显示
local scale_Y = cc.Director:getInstance():getWinSize().height / 615

function ZhongZuMap:ctor(parent)
	self.__parent = parent
	self._switchBtn = nil ---地图切换按钮
	self.__currentHost = 1 ---当前城镇是谁的，默认是自己的，2 敌方的
	self.__switchOk = true ---切换城市是否完成 
	self._canShowButtons = true
	self._didMove = false
	self._selfCitys = {} ---城市些
	self._enemyCitys = {}

	self._grayParall = {}----灰色方格(1-5,左边的，6-10，右边的)
	self._occupyIcon = {}----被占领图标（1-5，左边的，6-10，右边的）
	self._ratioLabel = nil ----中间两种族的城市陷落比例
	self._selfDefenceNum = nil ----自己总的防守队伍 label
	self._selfDefendTeam = {} -----自己的防守队伍，与城市ID关联

	self.__backgrounds = {} ---背景们,天、云、山、地、前景
	self.__selectedCityIndex = 0 --进入的城市索引
	self.__maxCitys = 5 ---最大的城市数量
	self.__enemyCitysPos = {{x = 205*scale_X,y = 225*scale_Y},{x = 491*scale_X,y = 250*scale_Y},{x = 735*scale_X,y = 312*scale_Y},{x = 1030*scale_X,y = 260*scale_Y},{x = 1295*scale_X,y = 375*scale_Y}}	
	self.__selfCitysPos = {{x = 1335*scale_X,y = 225*scale_Y},{x = 1050*scale_X,y = 250*scale_Y},{x = 805*scale_X,y = 315*scale_Y},{x = 505*scale_X,y = 260*scale_Y},{x = 245*scale_X,y = 375*scale_Y}}	
	self._slowDownSchedulerID = 0

	self._frames = {}
	self._buildEffect = {}
	self._EffectNode = cc.Node:create()

	self._bBurningFrame = {} ----建筑煅烧动画 
    ---帧特效
    for i = 1,4 do     
        ----战斗按钮上的A特效
        local texture = cc.Director:getInstance():getTextureCache():addImage("res/image/camp/frames/hm0"..i..".png")
        self._bBurningFrame[i] = cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,texture:getPixelsWide(),texture:getPixelsHigh()))      
    end     

	self.color = {
		red = cc.c3b(255,31,3),
		orange = cc.c3b(255,123,28),
		green = cc.c3b(53,255,67)
	}
	self.Tag = {
		ktag_slowdown = 50,----地图滑动动画
		ktag_buildButtons = 51,---
		ktag_actBuildBurning = 1024,----建筑在燃烧
		ktag_actBuildRuin = 1025,----建筑被打垮
	}
    self:loadFrams() -----加载帧
    XTHD.addEventListener({name = CUSTOM_EVENT.SHOW_CAMPSTART_BURNING,callback = function( event )-----种族战、世界boss功能开启 时候 的快捷入口 
    	local _show = event.data.show
    	self:showBurningBox(_show)
    	self:requestEnemyCityList()
    end})
    XTHD.addEventListener({name = CUSTOM_EVENT.SHOW_CAMPWARRESULT_DIALOG,callback = function(event) ----显示当种族战结束时的对话框
        self:showCampResultDialog(event.data)
    end})
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_CAMP_SELFCITIES,callback = function(event)
		self:updateCitysTips()
		self:refreshTopBars()
	end})
	if not ZhongZuDatas:isCampWarStart() then 
    	self:showBurningBox(false)		
	end 
end

function ZhongZuMap:create(parent)
	ZhongZuDatas.requestServerData({
	    method = "selfCampCityList?",
	    success = function( )
	        ZhongZuDatas.requestServerData({
	            method = "searchMyDefendGroup?", 
	            success = function( )
					local map = ZhongZuMap.new(parent)	
					if map then 		            
						map:init()
						map:registerScriptHandler(function( _type )
							if _type == "enter" then 
								map:onEnter()
							elseif _type == "exit" then 
								map:onExit()
							elseif _type == "cleanup" then 
								map:onCleanup()
							end 
						end)
					end 
        			LayerManager.addLayout(map)
	        	end
	        })
		end
	})
end

function ZhongZuMap:init( )
	if self.__parent then 
		self.__parent.__gotoBattleCounter = 0
	end

	local winSize = self:getContentSize()
	self:addChild(self._EffectNode)
	--返回按钮
	local x,y 
	local backButton = XTHD.createNewBackBtn(function( )
        LayerManager.removeLayout()
	end)
	self:addChild(backButton,3)
	backButton:setPosition(winSize.width,winSize.height)

	x,y = backButton:getPosition()
	---左右两边的种族标志
	local _brownBg = cc.Sprite:create("res/image/camp/map/camp_label_bg1.png") --右背景
	self:addChild(_brownBg,3)
	_brownBg:setAnchorPoint(0,0.5)
	_brownBg:setPosition(self:getContentSize().width / 2,self:getContentSize().height - _brownBg:getContentSize().height / 2 - 8)
	local _name = cc.Sprite:create("res/image/camp/camp_name2.png") ---右名字
	_brownBg:addChild(_name)
	_name:setAnchorPoint(0,0.5)
	_name:setPosition(60,_brownBg:getContentSize().height / 2)
	local _icon = cc.Sprite:create("res/image/homecity/camp_icon2.png")---右图标 
	_brownBg:addChild(_icon)
	_icon:setAnchorPoint(0,0.5)
	_icon:setPosition(_name:getPositionX() + _name:getContentSize().width + 1,_name:getPositionY())

	_brownBg = cc.Sprite:create("res/image/camp/map/camp_label_bg1.png") --左背景
	_brownBg:setFlippedX(true)
	self:addChild(_brownBg,3)
	_brownBg:setAnchorPoint(1,0.5)
	_brownBg:setPosition(self:getContentSize().width / 2,self:getContentSize().height - _brownBg:getContentSize().height / 2 - 8)
	_name = cc.Sprite:create("res/image/camp/camp_name1.png") ---左名字
	_brownBg:addChild(_name)
	_name:setAnchorPoint(1,0.5)
	_name:setPosition(_brownBg:getContentSize().width - 60,_brownBg:getContentSize().height / 2)
	_icon = cc.Sprite:create("res/image/homecity/camp_icon1.png")---左图标 
	_brownBg:addChild(_icon)
	_icon:setAnchorPoint(1,0.5)
	_icon:setPosition(_name:getPositionX() - _name:getContentSize().width - 3,_name:getPositionY())
	----中间vs
	local titleVS = cc.Sprite:create("res/image/camp/map/camp_title_VS.png")
	self:addChild(titleVS,3)
	titleVS:setPosition(self:getContentSize().width / 2,self:getContentSize().height - titleVS:getContentSize().height / 2 - 5)
	---中间的字
	local _bi = cc.Label:createWithBMFont("res/fonts/baisezi.fnt","0-0")
	titleVS:addChild(_bi)
	_bi:setPosition(titleVS:getContentSize().width / 2,10)
	_bi:setAdditionalKerning(-1)
	self._ratioLabel = _bi
	-----条们
	local _barRight = cc.Sprite:create("res/image/camp/map/camp_paral_red.png") ---右边的条
	self:addChild(_barRight,3)
	_barRight:setAnchorPoint(0,1)
	_barRight:setPosition(titleVS:getPositionX() + 32,titleVS:getPositionY() - 3)
	local _barBoxRight = cc.Sprite:create("res/image/camp/map/camp_paral_alpha.png")----右边的条框
	self:addChild(_barBoxRight,3)
	_barBoxRight:setAnchorPoint(0,1)
	_barBoxRight:setPosition(_barRight:getPositionX() - 3,_barRight:getPositionY() + 3)

	local _barLeft = cc.Sprite:create("res/image/camp/map/camp_paral_blue.png") ---左边的条
	self:addChild(_barLeft,3)
	_barLeft:setAnchorPoint(1,1)
	_barLeft:setPosition(titleVS:getPositionX() - 32,titleVS:getPositionY() -3)
	local _barBoxLeft = cc.Sprite:create("res/image/camp/map/camp_paral_alpha.png")----左边的条框
	_barBoxLeft:setFlippedX(true)
	self:addChild(_barBoxLeft,3)
	_barBoxLeft:setAnchorPoint(1,1)
	_barBoxLeft:setPosition(_barLeft:getPositionX() + 3,_barLeft:getPositionY() + 3)
	----图标们
	local x = 1
	local x2 = 27
	for i = 1,10 do 
		local _paral = cc.Sprite:create("res/image/camp/map/camp_paral_gray.png")
		_paral:setAnchorPoint(0,0.5)
		local _occupy = nil
		if i < 6 then --左边 
			_barLeft:addChild(_paral)
			_paral:setFlippedX(true)
			_paral:setPosition(x,_paral:getContentSize().height / 2)
			x = x + _paral:getContentSize().width - 19
			if i == 5 then 
				x = -7
				x2 = 20
			end 
		else
			_barRight:addChild(_paral)
			_paral:setPosition(x,_paral:getContentSize().height / 2)
			x = x + _paral:getContentSize().width - 19
		end 
		_paral:setVisible(false)
		self._grayParall[i] = _paral
	end 
	--切换领地按钮
	local switchBtn = XTHDPushButton:createWithParams({
		normalFile = "res/image/camp/camp_map_switch21.png",
		selectedFile = "res/image/camp/camp_map_switch22.png",
		musicFile = XTHD.resource.music.effect_btn_common,
	})
	self:addChild(switchBtn,3)
	switchBtn:setAnchorPoint(0,0)
	switchBtn:setPosition(10,10)
	switchBtn:setTouchEndedCallback(function( )
		self:switchMap()
	end)
	self._switchBtn = switchBtn
	-----右边按钮们
	local _bg = cc.Sprite:create("res/image/camp/map/camp_label_bg2.png")
	self:addChild(_bg,2)
	_bg:setScale(0.8)
	_bg:setAnchorPoint(1,0.5)
	_bg:setPosition(self:getContentSize().width,_bg:getBoundingBox().height / 2)
	self._menuBg = _bg

	local x = _bg:getContentSize().width - 10
	local _normal = {
		"res/image/camp/map/camp_funcBtn11.png",
		"res/image/camp/map/camp_funcBtn21.png",
		"res/image/camp/map/camp_phb1.png",
		"res/image/goldcopy/reward_btn_normal.png",
	}
	local _selected = {
		"res/image/camp/map/camp_funcBtn12.png",
		"res/image/camp/map/camp_funcBtn22.png",
		"res/image/camp/map/camp_phb2.png",
		"res/image/goldcopy/reward_btn_selected.png",
	}
	for i = 1,3 do 
		local _btn = XTHD.createPushButtonWithSound({
			normalFile = _normal[i],
			selectedFile = _selected[i],
		})
		_btn:setTag(i)
		_btn:setTouchEndedCallback(function( )
			self:doSouthEastBtns(_btn:getTag())
			self:removeBuildButtons()
		end)
		_bg:addChild(_btn)
		_btn:setAnchorPoint(1,0.5)
		_btn:setPosition(x,_bg:getContentSize().height / 2)
		x = x - _btn:getBoundingBox().width - 15
		if i == 1 then 
			local _numberBox = cc.Sprite:create("res/image/camp/map/camp_number_box.png")
			_btn:addChild(_numberBox)
			_numberBox:setAnchorPoint(0,0)
			_numberBox:setPosition(_btn:getBoundingBox().width - _numberBox:getContentSize().width + 5,_btn:getBoundingBox().height / 2)
			------数量
			self._selfDefenceNum = cc.Label:createWithBMFont("res/fonts/nuqizengjia.fnt",0)
			_numberBox:addChild(self._selfDefenceNum)
			self._selfDefenceNum:setScale(0.5)
			self._selfDefenceNum:setPosition(_numberBox:getContentSize().width / 2,_numberBox:getContentSize().height / 2)
            self.adjustBtn = _btn
            self:addGuide()
		end 
	end 
    self:createMap()     
	self._EffectNode:setContentSize(self.__backgrounds[3]:getContentSize())
    if self._EffectNode then 
		self._EffectNode:setAnchorPoint(self.__backgrounds[3]:getAnchorPoint())
		self._EffectNode:setPosition(self.__backgrounds[3]:getPosition())	
		self._EffectNode:setLocalZOrder(self.__backgrounds[3]:getLocalZOrder() + 1)	
	end 
	self:initMapCity(self._EffectNode,1)	
	self:initMapCity(self._EffectNode,2)

	self:initTouches()
	self:refreshTopBars()
	self:showBurningBox(true)
	self:updateCitysTips()
end

function ZhongZuMap:initTouches( )
	local beganPos = cc.p(0,0)
	local _limit = self.__backgrounds[3]:getContentSize().width - self:getContentSize().width
	local _speed = 0

    local function touchBegan(touch, event)    	
    	beganPos = touch:getLocation()
		local cityIndex = self:isClickedBuild(beganPos)
		if self._selfCitys[cityIndex] then
			self._selfCitys[cityIndex]:setScale(0.98)
		end
        return true
    end

    local function touchMoved(touch, event)
    	local nowPos = touch:getLocation()
    	local diff = cc.pSub(nowPos,beganPos) 

    	if math.abs(diff.x) > 10 then 
    		self._didMove = true
    	end    
    	if self._didMove then 
			local x,y = self.__backgrounds[3]:getPosition()---草地
			if x + diff.x <= 0 and x + diff.x >= (0 - math.abs(_limit)) then 
				self.__backgrounds[3]:setPosition(x + diff.x,y)
				self._EffectNode:setPosition(x + diff.x,y)
				if self._cloundCover then 
					self._cloundCover:setPosition(x + diff.x,y)
				end 
				
				x,y = self.__backgrounds[4]:getPosition()	---前景
				self.__backgrounds[4]:setPosition(x + diff.x * 1.1,y)

				x,y = self.__backgrounds[1]:getPosition()	---天空
				self.__backgrounds[1]:setPosition(x + diff.x * 1/5,y)

				x,y = self.__backgrounds[2]:getPosition()----山
				self.__backgrounds[2]:setPosition(x + diff.x * 5/6,y)	
			end 
	    	beganPos = nowPos
			_speed = diff.x
			self:removeBuildButtons()
		end 
    end

    local function touchEnded(touch, event)
		local a = math.abs(_speed / 15)
		local function slowDown( )				
			local newSpeed = (math.abs(_speed) - a)
			if newSpeed <= 0 then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._slowDownSchedulerID)
				self._slowDownSchedulerID = 0
			else 			 
				newSpeed = newSpeed * (_speed/math.abs(_speed)) ----正负
				local x,y = self.__backgrounds[3]:getPosition()
				if x + newSpeed >= 0 or x + newSpeed <= (0 - math.abs(_limit)) then 
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._slowDownSchedulerID)
					self._slowDownSchedulerID = 0
				else 
					self.__backgrounds[3]:setPosition(x + newSpeed,y)
					self._EffectNode:setPosition(x + newSpeed,y)
					if self._cloundCover then 
						self._cloundCover:setPosition(x + newSpeed,y)
					end 

					x,y = self.__backgrounds[4]:getPosition()	---前景
					self.__backgrounds[4]:setPosition(x + newSpeed * 1.1,y)

					x,y = self.__backgrounds[1]:getPosition()	---天空
					x = x + newSpeed * 1/5
					if x < 0 and x > (0 - math.abs(_limit)) then 
						self.__backgrounds[1]:setPosition(x,y)					
					end 

					x,y = self.__backgrounds[2]:getPosition()----山
					x = x + newSpeed * 5/6
					if x < 0 and x > (0 - math.abs(_limit)) then 					
						self.__backgrounds[2]:setPosition(x,y)	
					end 
					
					_speed = newSpeed			
				end 
			end
		end
		if self._slowDownSchedulerID == 0 then 
			self._slowDownSchedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(slowDown,0.0,false)
		end 
		local _touchPos = touch:getLocation()
		local clicked = self:isClickedBuild(_touchPos)
		if clicked == 0 then 
			self:removeBuildButtons()		
		elseif not self._didMove and self.__currentHost == 1 and self._canShowButtons then 
			self:showBuildButtons(self._selfCitys[clicked],_touchPos)			
		end 
		self._didMove = false
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(touchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(touchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(touchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function ZhongZuMap:createMap()
	for i = 1,4 do -----背景，从天、山、地、前景
		local node = cc.Node:create()
		self:addChild(node)
		local bg1,bg2
		if self.__currentHost == 1 then 
			bg1 = cc.Sprite:create("res/image/camp/map/camp_map_bg"..i.."2.png")
			bg1:setFlippedX(true)
			bg2 = cc.Sprite:create("res/image/camp/map/camp_map_bg"..i.."1.png")
			bg2:setFlippedX(true)
		elseif self.__currentHost == 2 then 
			bg1 = cc.Sprite:create("res/image/camp/map/camp_map_bg"..i.."1.png")			
			bg2 = cc.Sprite:create("res/image/camp/map/camp_map_bg"..i.."2.png")
		end 
		node:addChild(bg1)
		bg1:setAnchorPoint(cc.p(0,0))
		bg1:setPosition(0,0)
		bg1:setScaleX(scale_X)
		bg1:setScaleY(scale_Y)
		local _size = bg1:getContentSize()
		node:addChild(bg2)
		bg2:setAnchorPoint(cc.p(0,0))
		bg2:setPosition(bg1:getBoundingBox().width,0)	
		bg2:setContentSize(self:getContentSize())
		node:setContentSize(cc.size(bg1:getContentSize().width + _size.width,bg1:getContentSize().height))
		if self.__currentHost == 1 then 
			node:setPosition(self:getContentSize().width - node:getContentSize().width,0)
		elseif self.__currentHost == 2 then 
			node:setPosition(0,0)			
		end 
		self.__backgrounds[i] = node
	end 
    if self._EffectNode then 
		self._EffectNode:setAnchorPoint(self.__backgrounds[3]:getAnchorPoint())
		self._EffectNode:setPosition(self.__backgrounds[3]:getPosition())	
		self._EffectNode:setLocalZOrder(self.__backgrounds[3]:getLocalZOrder() + 1)	
	end 
end

function ZhongZuMap:initMapCity(targ,host)
	----地图上的建筑
	for i = 5,1,-1 do
		local _icon = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."map/camp_map_building"..i..".png")
		local build = XTHDPushButton:createWithParams({
			musicFile = XTHD.resource.music.effect_btn_common,
			needSwallow = false,
			needEnableWhenMoving = true,
			touchSize = _icon:getContentSize(),
		})				
		targ:addChild(build)
		build:addChild(_icon)		
		if i == 4 or i == 5 then 
			local _size = _icon:getContentSize()
			build:setTouchSize(cc.size(_size.width,_size.height * 1/2))
		end 		
		------------防守队伍数量图标
		local _defenceIcon = cc.Sprite:create("res/image/camp/map/camp_defence_icon.png")
		build:addChild(_defenceIcon)
		_defenceIcon:setAnchorPoint(0.5,0)
		---名字
		local nameBox = cc.Sprite:create("res/image/camp/map/camp_city_name"..i..".png")
		build:addChild(nameBox)
		if host == 2 then 
			build:setPosition(self.__enemyCitysPos[i].x,self.__enemyCitysPos[i].y)
			nameBox:setAnchorPoint(cc.p(0,0.5))
			nameBox:setPosition(_icon:getPositionX() + _icon:getBoundingBox().width / 2,_icon:getPositionY() + 15)
			_defenceIcon:setPosition(nameBox:getPositionX() + _defenceIcon:getContentSize().width / 2 - 2,nameBox:getPositionY() + nameBox:getBoundingBox().height / 2 - 3)
		elseif host == 1 then 
			build:setPosition(self.__selfCitysPos[i].x,self.__selfCitysPos[i].y)
			_icon:setScaleX(-1)
			nameBox:setAnchorPoint(cc.p(1,0.5))
			nameBox:setPosition(_icon:getPositionX() - _icon:getBoundingBox().width / 2,_icon:getPositionY() + 15)
			_defenceIcon:setPosition(nameBox:getPositionX() - _defenceIcon:getContentSize().width / 2 + 2,nameBox:getPositionY() + nameBox:getBoundingBox().height / 2 - 3)
		end 
		build:setTag(i)
		build:setTouchEndedCallback(function ()
			self:handlBuildCicked(build)
		end)
		-----防守数量
		local _number = cc.Label:createWithBMFont("res/fonts/baisezi.fnt",0)
		_defenceIcon:addChild(_number)
		_number:setScale(0.8)
		_number:setPosition(_defenceIcon:getContentSize().width / 2,_defenceIcon:getContentSize().height / 2 - 5)
		_number:setAdditionalKerning(-1)
		build._perCityAllTeam = _number
		if host == 1 then 
			-----自己在该城里的防守队伍数量
			local _defenceIcon = cc.Sprite:create("res/image/camp/map/camp_selfdefence_bg.png")
			build:addChild(_defenceIcon)
			_defenceIcon:setPosition(build:getContentSize().width / 2,_icon:getContentSize().height / 2 + 15)
			---数量 
			local _selfNum = XTHDLabel:createWithParams({
				text = "",
				fontSize = 16,
				color = cc.c3b(255,252,0),
			})
			_defenceIcon:addChild(_selfNum)					
			_selfNum:setPosition(_defenceIcon:getContentSize().width / 2,_defenceIcon:getContentSize().height / 2)
			build._selfTeamPerCity = _selfNum
		else 
			build._selfTeamPerCity = nil
		end
		----各种图标 被占领 可进攻 未开启
		local _space = 5
		local _mark = cc.Sprite:create("res/image/camp/camp_map_getted.png")
		build:addChild(_mark)
		_mark:setAnchorPoint(0.5,0)
		_mark:setPosition(_icon:getPositionX(),_icon:getPositionY() + _icon:getBoundingBox().height / 2 - _space)
		_mark:setVisible(false)
		build._capturedIcon = _mark

		_mark = cc.Sprite:create("res/image/camp/camp_map_atk.png")
		build:addChild(_mark)
		_mark:setAnchorPoint(0.5,0)
		_mark:setPosition(_icon:getPositionX(),_icon:getPositionY() + _icon:getBoundingBox().height / 2 - _space)
		_mark:setVisible(false)
		build._atkIcon = _mark

		_mark = cc.Sprite:create("res/image/camp/camp_map_unreachable.png")
		build:addChild(_mark)
		_mark:setAnchorPoint(0.5,0)
		_mark:setPosition(_icon:getPositionX(),_icon:getPositionY() + _icon:getBoundingBox().height / 2 - _space)
		build._unreachableIcon = _mark

		build._icon = _icon
		if host == 1 then 
			build._unreachableIcon:setVisible(false)
			self._selfCitys[i] = build
		else
			build._unreachableIcon:setVisible(true)
			self._enemyCitys[i] = build
		end 
	end	
end
--更换城市 
function ZhongZuMap:switchMap( )
	local function canDo(isReal)
		if not self.__switchOk then 
			return 
		end 
		self.__switchOk = false
		local function doSwitch(needShow) ----是否需要显示敌人城市 
			for i = 1,#self.__backgrounds do 
				self.__backgrounds[i]:removeFromParent()
				self.__backgrounds[i] = nil
			end 
			local _zorder = self._switchBtn:getLocalZOrder()
			if self._switchBtn then 
				local _btn = XTHDPushButton:createWithParams({
					normalFile = "res/image/camp/camp_map_switch"..(3 - self.__currentHost).."1.png",
					selectedFile = "res/image/camp/camp_map_switch"..(3 - self.__currentHost).."2.png",
					musicFile = XTHD.resource.music.effect_btn_common,
				})
				self._switchBtn:getParent():addChild(_btn,_zorder)
				_btn:setPosition(self._switchBtn:getPosition())
				_btn:setTag(self._switchBtn:getTag())
				_btn:setAnchorPoint(self._switchBtn:getAnchorPoint())
				_btn:setTouchEndedCallback(self._switchBtn:getTouchEndedCallback())
				self._switchBtn:removeFromParent()
				self._switchBtn = _btn
				self:createMap()
				if needShow == true then -----正常显示
					self:refreshTopBars()
					self:updateCitysTips()		
				elseif needShow == 4808 then ----种族战即将开启 
					self:displayBuildsByHost(2,true)
				elseif needShow == 4821 then ---种族战已结束 
					self:displayBuildsByHost(2,true)
					self:enemyAllCityRuin()
				end 
			end 			
		end

		local _left = cc.Sprite:create("res/image/plugin/stageChapter/yun_left.png")
		self:addChild(_left,2)
		_left:setAnchorPoint(1,0.5)
		_left:setPosition(0,self:getContentSize().height / 2)
		_left:setScaleY(self:getContentSize().height / _left:getContentSize().height)
		_left:setScaleX(self:getContentSize().width / _left:getContentSize().width)

		local _right = cc.Sprite:create("res/image/plugin/stageChapter/yun_right.png")
		self:addChild(_right,2)
		_right:setAnchorPoint(0,0.5)
		_right:setPosition(self:getContentSize().width,self:getContentSize().height / 2)
		_right:setScaleY(self:getContentSize().height / _right:getContentSize().height)
		_right:setScaleX(self:getContentSize().width / _right:getContentSize().width)

		local time = 0.5
		local act1 = cc.MoveTo:create(time,cc.p(self:getContentSize().width * 3/4,self:getContentSize().height / 2))
		local act2 = cc.MoveTo:create(time,cc.p(0,self:getContentSize().height / 2))
		_left:runAction(cc.Sequence:create(act1,cc.CallFunc:create(function()
			if self._cloundCover then 
				self._cloundCover:removeFromParent()
				self._cloundCover = nil
			end				
		end),act2))

		act1 = cc.MoveTo:create(time,cc.p(self:getContentSize().width * 1/2,self:getContentSize().height / 2))
		act2 = cc.MoveTo:create(time,cc.p(self:getContentSize().width,self:getContentSize().height / 2))
		_right:runAction(cc.Sequence:create(act1,cc.CallFunc:create(function( )
			doSwitch(isReal)
		end),act2,cc.CallFunc:create(function( )
			self.__switchOk = true
			_left:removeFromParent()
			_right:removeFromParent()
		end)))
	end


	self.__currentHost = (self.__currentHost + 1) % 3
	self.__currentHost = self.__currentHost == 0 and 1 or self.__currentHost
	if self.__currentHost == 1 then 
        ZhongZuDatas.requestServerData({
			target = self,
            method = "selfCampCityList?",
            success = function( )
            	canDo(true)
                self:showBurningBox(true)
            end,
        })
	else 
        ZhongZuDatas.requestServerData({
			target = self,
            method = "rivalCampCityList?",
            success = function( )
            	canDo(true)
                self:showBurningBox(false)
            end,
            failure = function(data)
            	if data ~= nil and (data.result == 4808 or data.result == 4821) then ----种族战即将开启
            		canDo(data.result)
            	end 
            end
        })
	end 	
end
--更新城镇的提示，被占领还是什么
function ZhongZuMap:updateCitysTips()	
	if self._selfDefenceNum then
		self._selfDefenceNum:setString(#ZhongZuDatas._serverSelfDefendTeam.teams)
	end 
	self:displayBuildsByHost(self.__currentHost,false)
	local data = nil 	
	local targ = nil
	if self.__currentHost == 1 then --我方
		data = ZhongZuDatas._serverSelfCity.citys
		targ = self._selfCitys
	else ---敌方
		data = ZhongZuDatas._serverEnemyCity and ZhongZuDatas._serverEnemyCity.citys or nil
		targ = self._enemyCitys
	end 	
	if not data then 
		return 
	end 
	for i = 1,5 do 
		self:showBuildEffect(self.Tag.ktag_actBuildBurning,true,targ[i],i)
		self:showBuildEffect(self.Tag.ktag_actBuildRuin,true,targ[i],i)		
		if tonumber(data[i].state) == 1 then ---已陷落
			targ[i]._capturedIcon:setVisible(true)
			targ[i]._atkIcon:setVisible(false)
			targ[i]._unreachableIcon:setVisible(false)
			
			targ[i]._icon:setTexture("res/image/camp/map/camp_map_building"..i.."2.png")

			local _burning = targ[i]:getChildByTag(self.Tag.ktag_actBuildBurning)
			local _ruin = targ[i]:getChildByTag(self.Tag.ktag_actBuildRuin)
			if _burning then 
				_burning:setVisible(false)
			end
			if _ruin then 
				_ruin:setVisible(true)
			end  

			if targ[i]._selfTeamPerCity then 
				targ[i]._selfTeamPerCity:getParent():setVisible(false)
			end 
			if targ[i]._perCityAllTeam then 
				targ[i]._perCityAllTeam:getParent():setVisible(false)
			end 
		else
			targ[i]._icon:setTexture("res/image/camp/map/camp_map_building"..i..".png")
			targ[i]._capturedIcon:setVisible(false)
			local _burning = targ[i]:getChildByTag(self.Tag.ktag_actBuildBurning)
			local _ruin = targ[i]:getChildByTag(self.Tag.ktag_actBuildRuin)
			if self.__currentHost == 1 then --自己
				if _burning then 
					_burning:setVisible(false)
				end
				if _ruin then 
					_ruin:setVisible(false)
				end  
			else		
				local canAttack = ZhongZuDatas.isCampWarStart()
				local id = ZhongZuDatas._localCity[tonumber(data[i].cityId)].previouseCity
				local res = string.split(id,"#")	
				for k,v in pairs(res) do 
					if self:isTheCityCaptured(data,tonumber(v)) then 
						canAttack = true
						break
					else 
						canAttack = false
					end 
				end			
				if canAttack then ----可进攻					
					targ[i]._atkIcon:setVisible(true)
					targ[i]._unreachableIcon:setVisible(false)
					if _burning then 
						_burning:setVisible(true)
					end
					if _ruin then 
						_ruin:setVisible(false)
					end  
				else 
					targ[i]._atkIcon:setVisible(false)
					targ[i]._unreachableIcon:setVisible(true)						
					if _burning then 
						_burning:setVisible(false)
					end
					if _ruin then 
						_ruin:setVisible(false)
					end  
				end 
				targ[i].canAttack = canAttack
			end 
			if targ[i]._selfTeamPerCity then 
				local _teams = ZhongZuDatas._selfTeams[tonumber(data[i].cityId)]
				if _teams and #_teams > 0 then 
					targ[i]._selfTeamPerCity:getParent():setVisible(true)
					targ[i]._selfTeamPerCity:setString(#_teams..LANGUAGE_UNKNOWN.team)---"队")
				else 				
					targ[i]._selfTeamPerCity:getParent():setVisible(false)
				end 
			end 
			if targ[i]._perCityAllTeam then 
				targ[i]._perCityAllTeam:getParent():setVisible(true)
				targ[i]._perCityAllTeam:setString(data[i].defendSum)
			end 
		end 		
	end 
end

function ZhongZuMap:isTheCityCaptured(cityData,index)	
	if index == 0 then 
		return true
	end 
	if not cityData then 
		return false
	end 	
	local data = cityData[index]
	if data then 
		if tonumber(data.state) == 1 then 
			return true
		else 
			return false
		end 
	end 
	return false
end

function ZhongZuMap:handlBuildCicked( sender )	
	local i = sender:getTag()
	local data = nil
	if self.__currentHost == 1 then 
		data = ZhongZuDatas._serverSelfCity.citys
	elseif self.__currentHost == 2 then 
		if ZhongZuDatas:isCampWarStart() == true then 
			data = ZhongZuDatas._serverEnemyCity.citys
		else
			self:requestEnemyCityData(self.__selectedCityIndex)
		end 
	end 
	if not data then 
		return 
	end 
	if self.__currentHost == 1 and tonumber(data[i].state) == 1 then 
		XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS4)
		self._canShowButtons = false
		self:removeBuildButtons()
		return 
	elseif self.__currentHost == 2 and tonumber(data[i].state) == 1 then 
		XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS5)
		self._canShowButtons = false
		return 
	end 	
	if self.__currentHost == 1 then 					
		self._canShowButtons = true
	elseif self.__currentHost == 2 then 
		self.__selectedCityIndex = i
		self:requestEnemyCityData(self.__selectedCityIndex)
	end 
end

function ZhongZuMap:onEnter( )
	if ZhongZuDatas:isCampWarStart() == true and self.__currentHost == 1 then 
		self:switchMap()
	end
end

function ZhongZuMap:onExit( )
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._slowDownSchedulerID)
	self._slowDownSchedulerID = 0	
end

function ZhongZuMap:onCleanup( )
    XTHD.removeEventListener(CUSTOM_EVENT.SHOW_CAMPSTART_BURNING)	
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_CAMP_SELFCITIES)	
    XTHD.removeEventListener(CUSTOM_EVENT.SHOW_CAMPWARRESULT_DIALOG)  
end
----左下角按钮们
function ZhongZuMap:doSouthEastBtns(btnIndex)
	if btnIndex then 
		if btnIndex == 1 then -----调整队伍	
            YinDaoMarg:getInstance():guideTouchEnd()
			if ZhongZuDatas:isCampWarStart() == true then 
				XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS35)
				return 
			end 
			local embattle = requires("src/fsgl/layer/ZhongZu/ZhongZuAdjustEmbattle.lua")
			embattle = embattle:create(nil,self)
			self:addChild(embattle,4)
		elseif btnIndex == 2 then ----规则说明 
			local _detail = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua")
			local layer = _detail:create({type = 1})
			self:addChild(layer,4)
			layer:show()
			
			
		elseif btnIndex == 3 then ---击杀排行
			self:showATKRankList(self)
		elseif btnIndex == 4 then ---奖励说明 
			local reward = requires("src/fsgl/layer/ZhongZu/RewardDetailLayer1.lua")
			local layer = reward:create()
			self:addChild(layer,4)
			layer:show()
		end 
	end 
end

function ZhongZuMap:showATKRankList( target )
    ZhongZuDatas.requestServerData({
		target = target,
        method = "hurtRank?",
        params = {cityId = cityID},
        success = function(data)
        	if data.result == 0 then 
				local layer = requires("src/fsgl/layer/ZhongZu/ZhongZuRangeLayer.lua"):create(data.rankList,"attack")
				target:addChild(layer,4)
				layer:show()
        	end 
        end
    })
end

function ZhongZuMap:showBuildButtons(build,touchPos)
	local isLeft = true
	if touchPos.x > self:getContentSize().width / 2 then 
		isLeft = false
	end 
	local target = self._EffectNode
	if target and build then 		
		local _buttons = target:getChildByTag(self.Tag.ktag_buildButtons)
		local x,y = build:getPosition()
		if _buttons then
			if _buttons.targTag == build:getTag() then 
				_buttons:removeFromParent()
			else 
				_buttons.targTag = build:getTag()
				if isLeft then 
					_buttons:setPosition(x + build:getTouchSize().width / 2,y)
				else 
					_buttons:setPosition(x - build:getTouchSize().width / 2,y)
				end 
				_buttons:setCityID(build:getTag())
			end 
		else 			
			local _defendSum = ZhongZuDatas._serverSelfCity.citys[build:getTag()]
			_buttons = requires("src/fsgl/layer/ZhongZu/ZhongZuBuildDialog.lua"):create(build:getTag(),self,_defendSum)
			_buttons:setTag(build:getTag())
			target:addChild(_buttons)
			_buttons:setTag(self.Tag.ktag_buildButtons)
			_buttons.targTag = build:getTag()
			if isLeft then 
				_buttons:setPosition(x + build:getTouchSize().width / 2,y)
			else 
				_buttons:setPosition(x - build:getTouchSize().width / 2,y)
			end 
		end 
	end 
end

function ZhongZuMap:isClickedBuild(pos)
	pos = self.__backgrounds[3]:convertToNodeSpace(pos)
	for k,v in pairs(self._selfCitys) do 
		local x,y = v:getPosition()		
		local size = v:getTouchSize()
		x = x - size.width / 2
		y = y - size.height / 2
		local _rect = cc.rect(x,y,size.width ,size.height)
		if cc.rectContainsPoint( _rect, pos ) then 
			return k
		end 
	end 
	return 0
end

function ZhongZuMap:removeBuildButtons( )
	if self._EffectNode and self._EffectNode:getChildByTag(self.Tag.ktag_buildButtons) then 
		self._EffectNode:removeChildByTag(self.Tag.ktag_buildButtons)
	end 
end
----更新城市占领情况
function ZhongZuMap:refreshTopBars()
	local data = nil 
	if self.__currentHost == 1 then 
		data = ZhongZuDatas._serverSelfCity
	else 
		data = ZhongZuDatas._serverEnemyCity		
	end 
	if data then 
		if self._ratioLabel then ----中间的攻占比例
			self._ratioLabel:setString(data.caveRatio)
		end 
		local rate = string.split(data.caveRatio,"-") ---1为光明谷，2 为暗月岭
		if rate and #rate == 2 then 
			for i = 1,5 do ---
				if i <= tonumber(rate[1]) then 
					self._grayParall[i]:setVisible(true)
				else 
					self._grayParall[i]:setVisible(false)
				end 
				if i <= tonumber(rate[2]) then 
					self._grayParall[10 - i + 1]:setVisible(true)
				else 
					self._grayParall[10 - i + 1]:setVisible(false)
				end 
			end 
		end 
	end 
end

function ZhongZuMap:loadFrams( )
	self._frames.attack = {}
	self._frames.smoke = {}
	for i = 1,12 do 
		local _path = string.format("res/image/camp/frames/%02d.png",i)
        local texture = cc.Director:getInstance():getTextureCache():addImage(_path)
        self._frames.smoke[i] = cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,texture:getPixelsWide(),texture:getPixelsHigh()))
        if i < 5 then 
	        texture = cc.Director:getInstance():getTextureCache():addImage("res/image/camp/frames/hm0"..i..".png")
	        self._frames.attack[i] = cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,texture:getPixelsWide(),texture:getPixelsHigh()))       
	    end 
	end 
end
-----显示煅烧的框
function ZhongZuMap:showBurningBox(isShow)
	if isShow and self.__currentHost == 1 and ZhongZuDatas:isCampWarStart() == true then ----当前是自己并且种族战已开启
	    local _burning = sp.SkeletonAnimation:create("res/image/camp/frames/zyzc.json","res/image/camp/frames/zyzc.atlas",1.0)
	    self:addChild(_burning,1)
	    _burning:setName("burningBox")
	    _burning:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	    _burning:setAnimation(0,"animation",true)
		
		local winSize = cc.Director:getInstance():getWinSize()
		local scale_X = winSize.width / 1024
		local scale_Y = winSize.height / 615
		_burning:setScaleX(scale_X)
		_burning:setScaleY(scale_Y)
	else
		self:removeChildByName("burningBox")
	end 
end

function ZhongZuMap:showBuildEffect(tag,isShow,targ,index)----显示在建筑上的特效，受到攻击及被打乱冒烟的特效	
	local build = targ
	if isShow then ---显示	
		if not build:getChildByTag(tag)	then 
			local act = cc.Animation:createWithSpriteFrames(self._frames.attack,1/6)
			if tag == self.Tag.ktag_actBuildBurning then ----建筑燃烧
			    act = cc.Animation:createWithSpriteFrames(self._frames.attack,1/6)
			elseif tag == self.Tag.ktag_actBuildRuin then 
			    act = cc.Animation:createWithSpriteFrames(self._frames.smoke,1/6)
			end 
		    act = cc.Animate:create(act)
		    act = cc.RepeatForever:create(act)
		    act:setTag(tag)
		    local target = cc.Sprite:create()
		    build:addChild(target,100,tag)
		    target:setPosition(build:getBoundingBox().width / 2,build:getBoundingBox().height / 2)
		    if tag == self.Tag.ktag_actBuildRuin then 
		    	local _scaleX = {4.02,4.02,5.64,4.73,7.4}
		    	local _scaleY = {3.34,3.61,3.82,3.02,3.02}
		    	local cy = {40,40,40,10,25}
		    	target:setScaleX(_scaleX[index])
		    	target:setScaleY(_scaleY[index])
		    	target:setPosition(build:getBoundingBox().width / 2,cy[index])
		    elseif tag == self.Tag.ktag_actBuildBurning then 
		    	local _scaleX = {1,1.05,1.295,1.453,2.203}
		    	local _scaleY = {1,1.37,1.505,1.803,2.215}
		    	local y = build:getBoundingBox().height
		    	local x = build:getBoundingBox().width / 2
		    	local cy = {y - 10,y + 50,y + 40,y + 20,y}
		    	target:setScaleX(_scaleX[index])
		    	target:setScaleY(_scaleY[index])
		    	target:setPosition(x,cy[index])
		    end 
		    target:runAction(act)	 
		end 
	else ----不显示
		build:removeChildByTag(tag)
	end	 	
end

function ZhongZuMap:requestEnemyCityData( cityIndex )
    ZhongZuDatas.requestServerData({
        target = self,
        method = "campRivalCity?",
        params = {cityId = cityIndex},
        success = function(data)       		
            HttpRequestWithParams("campBossInfo",{cityId = cityIndex,campId = gameUser.getCampID() == 1 and 2 or 1}, function(data1)
                LayerManager.createModule("src/fsgl/layer/ZhongZu/ZhongZuShouWei.lua", { par = self ,serverData = data1,cityID = cityIndex,mapData = data})
--               self:updateEnemyCityDFDSUM(cityIndex,data)
--			    local page = requires("src/fsgl/layer/ZhongZu/EnemyCitySPLayer1.lua"):create(cityIndex,self.__currentHost,self)
--			    self:addChild(page,4)	
            end )	
    	end,
    	failure = function(data)
    		if data and data.result == 4801 then  ----城市已被占领
				ZhongZuDatas.requestServerData({
					target = self,
				    method = "rivalCampCityList?",
				    success = function( )
				    	self:updateCitysTips()
				    	self:refreshTopBars()
				    end
				})
    		end 
    	end
    })
end

function ZhongZuMap:requestEnemyCityList()
	ZhongZuDatas.requestServerData({
		target = self,
	    method = "rivalCampCityList?",
	    success = function( )
	    	self:updateCitysTips()
	    	self:refreshTopBars()
	    end,
	    failure = function( data )
	    	if data and data.result == 4808 and self.__currentHost == 2 then ----种族战即将开启、
				self:displayBuildsByHost(2,true)
			elseif data and data.result == 4821 and self.__currentHost == 2 then ----种族战结束
				self:displayBuildsByHost(2,true)
				self:enemyAllCityRuin()
	    	end 
	    end
	})
end
-----根据当前地图所有的种族方来显示城市 ，noamount,是否显示城市上面的人数
function ZhongZuMap:displayBuildsByHost( host,noAmount )
	for i = 1,5 do 
		if host == 1 then 
			self._selfCitys[i]:setVisible(true)
			self._enemyCitys[i]:setVisible(false)
		else 
			self._selfCitys[i]:setVisible(false)
			self._enemyCitys[i]:setVisible(true)
			if self._enemyCitys[i]._perCityAllTeam then 
				if noAmount then 
					self._enemyCitys[i]._perCityAllTeam:getParent():setVisible(false)
				else
					self._enemyCitys[i]._perCityAllTeam:getParent():setVisible(true)
				end 
			end 
		end 
	end 
end

function ZhongZuMap:showCampResultDialog(data)------当种族战结束的时候，提示框
	local _layer = requires("src/fsgl/layer/ZhongZu/ZhongZuWarOverLayer.lua"):create(data)
	self:addChild(_layer,4)
	_layer:show()
end
-----当种族战结束时一直即将开启之时，敌方城市都是废墟
function ZhongZuMap:enemyAllCityRuin()	
	if ZhongZuDatas._ruinAmount > 0 then 
		for i = 1,ZhongZuDatas._ruinAmount do 
			local v = self._enemyCitys[i]
			self:showBuildEffect(self.Tag.ktag_actBuildBurning,false,v,i)
			self:showBuildEffect(self.Tag.ktag_actBuildRuin,true,v,i)
			
			v._capturedIcon:setVisible(true)
			v._atkIcon:setVisible(false)
			v._unreachableIcon:setVisible(false)		

			v._icon:setTexture("res/image/camp/map/camp_map_building"..i.."2.png")

			local _ruin = v:getChildByTag(self.Tag.ktag_actBuildRuin)
			if _ruin then 
				_ruin:setVisible(true)
			end  
			if v._selfTeamPerCity then 
				v._selfTeamPerCity:getParent():setVisible(false)
			end 
			if v._perCityAllTeam then 
				v._perCityAllTeam:getParent():setVisible(false)
			end 
		end 
	end 
end
-------更新敌方城市的剩余敌军数量
function ZhongZuMap:updateEnemyCityDFDSUM(index,data)
	if self.__currentHost == 2 then
	 	if data then 
			self._enemyCitys[index]._perCityAllTeam:setString(data.defendSum)
		end 
	end 
end

function ZhongZuMap:addGuide( )
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self.adjustBtn, -----点击队伍调整按钮
        index = 5,
    },25)
    YinDaoMarg:getInstance():doNextGuide()    
end

return ZhongZuMap