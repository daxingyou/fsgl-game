local JiangJunFuLayer = class("JiangJunFuLayer", function()
	return cc.Layer:create()
end)

function JiangJunFuLayer:ctor()
	
end

-- self.CloseBtn = XTHDPushButton:createWithParams({
-- 		touchSize = cc.size(10000,10000),
--         endCallback = function ()
--             self:removeFromParent()
--         end
--     })

function JiangJunFuLayer:create(heroID,parent)
    self._parent = parent
    self._heroID = heroID
	local JiangJunFuLayer = JiangJunFuLayer:new(data)
	if JiangJunFuLayer then
		JiangJunFuLayer:init(data)
	end
	return JiangJunFuLayer
end

function JiangJunFuLayer:init(data)
	self._equipment = {1,2,3,4,5,6}
	self._btn_equipment = {}
	self._wlgj = 0 		    --物理攻击力
    self._fsgj = 0          --魔法攻击力
	self._wlfy = 0 			--物理防御力
    self._fsfy = 0          --魔法防御力
    self._hp = 0            --生命值
    self._curLucky = 0      --当前幸运值
    self._maxLucky = 0      --升级所需幸运值
    self._curRank = 0
	self._needNum = 0		--赏赐所需材料
	self._isProgressing = false
	self._isRequest = false
	--侍仆装备
	self._petEequipments = {
							["1"] = {},
							["2"] = {},
                            ["3"] = {},
                            ["4"] = {},
                            ["5"] = {},
                            ["6"] = {}
						   }

    self._skillList = {}
    self._petList = {{},{},{},{},{}}
    self._shuxingValueLable = {}
	self._shuxingLable = {}
    self._clockList = {}
    self._isHavePet = false
    self._petIndex = 1
	self._Pro = {
					 "生　命　值：　",
					 "物理攻击力：　",
					 "物理防御力：　",
                     "魔法攻击力：　",
					 "魔法防御力：　"
			    }

    self.petData = gameData.getDataFromCSV("ServantUp")
	
			for k,v in pairs(DBPetData.DBData) do
				if v.petId == self._heroID then
					self._nowPet = v
					self._isHavePet = true
					self._wlgj = self._nowPet.physicalattack
					self._fsgj = self._nowPet.manaattack
					self._wlfy = self._nowPet.physicaldefence
					self._fsfy = self._nowPet.manadefence
					self._hp = self._nowPet.hp
					self._curLucky = self._nowPet.curLucky
					self._maxLucky = self.petData[self._nowPet.templateId].maxlucky
					self._curRank = self.petData[self._nowPet.templateId].rank
				end
            end
	-- dump(self._nowPet,"当前侍仆")

    print(self._curRank)

    for i = 1,6 do
		if self._nowPet ~= nil then
        self._petEequipments[tostring(i)] = self._nowPet["items"..tostring(i)]
		end
    end

    self._ProNumber = { self._hp, self._wlgj, self._wlfy, self._fsgj, self._fsfy}

	local bg = ccui.Scale9Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/bg_1.png")
    self:addChild(bg)
    bg:setAnchorPoint(cc.p(0.5,0.5))
    bg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
    self._bg = bg

    --返回按钮
    local close_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/plugin/JiangJuFuGeneralRoom/backbtn.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = "res/image/plugin/JiangJuFuGeneralRoom/backbtn.png",
        touchScale = 0.9,
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            LayerManager.setChatRoomVisable(true)
       		 LayerManager.removeLayout()
        end,
    })
    self:addChild(close_btn)
    close_btn:setPosition(cc.p(close_btn:getContentSize().width / 2,self:getContentSize().height - close_btn:getContentSize().height / 2))

    --宠物
    local pet = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/puren_1.png")
    self:addChild(pet)
    pet:setVisible(self._isHavePet)
    pet:setAnchorPoint(cc.p(0.5,0.5))
    pet:setPosition(cc.p(self:getContentSize().width /2 -190,self:getContentSize().height/2 + 15))
    self._pet = pet

   	local petNamebg = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/bg_3.png")
   	self:addChild(petNamebg)
   	petNamebg:setPosition(self._pet:getPositionX(),self._pet:getPositionY() + self._pet:getContentSize().height / 2 + 40)

    local name = nil
    if self._nowPet ~= nil then
        name = self.petData[self._nowPet.templateId].name .. "+"..tostring(self._curRank)
    end
   	--宠物名
   	local petName = XTHDLabel:createWithParams({
        text = name,
        fontSize = 16,
        color = cc.c3b(255,255,255),
    })

   	petName:setAnchorPoint(cc.p(0.5,0.5))
   	petNamebg:addChild(petName)
   	petName:setPosition(cc.p(petNamebg:getContentSize().width / 2,petNamebg:getContentSize().height /2))
    self._petName = petName

    -- --向左按钮
    -- local leftArrow = XTHDPushButton:createWithParams({
    --     musicFile = XTHD.resource.music.effect_btn_common,
    --     normalFile = "res/image/plugin/saint_beast/leftArrow_up.png",
    --     selectedFile = "res/image/plugin/saint_beast/leftArrow_down.png",
    --     touchSize = cc.size(50, 60),
    -- })
    -- leftArrow:setAnchorPoint(0.5,0.5)
    -- leftArrow:setPosition(self._pet:getPositionX() - 120,self._pet:getPositionY() + 40)
    -- self:addChild(leftArrow)

    -- leftArrow:setTouchEndedCallback(function ()
    --     --for i=1,#self._petList do
    --         self:onUpdateInfo(1)
    --     --end
    -- end)
    -- leftArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(
    --     cc.EaseInOut:create(cc.MoveBy:create(1,cc.p(-15,0)),1.5),
    --     cc.EaseInOut:create(cc.MoveBy:create(1,cc.p(15,0)),1.5)
    -- )))

    -- --向右按钮
    --  local rightArrow = XTHDPushButton:createWithParams({
    --     musicFile = XTHD.resource.music.effect_btn_common,
    --     normalFile = "res/image/plugin/saint_beast/rightArrow_up.png",
    --     selectedFile = "res/image/plugin/saint_beast/rightArrow_down.png",
    --     touchSize = cc.size(50, 60),
    -- })
    -- rightArrow:setAnchorPoint(0.5,0.5)
    -- rightArrow:setPosition(self._pet:getPositionX() + 120,self._pet:getPositionY() + 40 )
    -- self:addChild(rightArrow)

    -- rightArrow:setTouchEndedCallback(function ()
    --     --for i=1,#self._petList do
    --         self:onUpdateInfo(2)
    --     --end
    -- end)

    -- rightArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(
    --     cc.EaseInOut:create(cc.MoveBy:create(1,cc.p(15,0)),1.5),
    --     cc.EaseInOut:create(cc.MoveBy:create(1,cc.p(-15,0)),1.5)
    -- )))

   	--进度条
    local bar_bg = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/progress_timer_1.png")
    self:addChild(bar_bg)
    bar_bg:setScale(0.9)
    bar_bg:setAnchorPoint(0.5,1)
    bar_bg:setPosition(self._pet:getPositionX(),self._pet:getPositionY() - self._pet:getContentSize().height / 2 +20 )
    self.bar_bg = bar_bg
    ---经验进度条
    local _exp_progress_timer = cc.ProgressTimer:create(cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/progress_timer_2.png"))
    _exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    _exp_progress_timer:setMidpoint(cc.p(0, 0))
    _exp_progress_timer:setBarChangeRate(cc.p(1, 0))
    _exp_progress_timer:setPosition(bar_bg:getContentSize().width/2 + 22, bar_bg:getContentSize().height/2)
    bar_bg:addChild(_exp_progress_timer)
    self._exp_progress_timer = _exp_progress_timer

    local percentage = self._curLucky / self._maxLucky *100
    self._exp_progress_timer:setPercentage(percentage)

	local LuckyLable = XTHDLabel:createWithParams({
            text = tostring(self._curLucky).." / "..tostring(self._maxLucky),
            fontSize = 22,
            color = XTHD.resource.color.brown_desc,
            anchor = cc.p(0.5, 0),
        })
    LuckyLable:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(LuckyLable)
    LuckyLable:setPosition(cc.p(bar_bg:getPositionX() + 20,bar_bg:getPositionY()-50))
    self._LuckyLable = LuckyLable

    --辭退按鈕
    local btn_citui = XTHDPushButton:createWithParams({
        normalFile        = "res/image/plugin/JiangJuFuGeneralRoom/shipu-an_3.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = "res/image/plugin/JiangJuFuGeneralRoom/shipu-an_4.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            self:DismissPet()
        end,
    })
    btn_citui:setVisible(self._isHavePet)
    self:addChild(btn_citui)
    btn_citui:setPosition(self:getContentSize().width / 2 - 10,self:getContentSize().height / 2 - 100)
    self._btn_citui = btn_citui

      --赏赐
    local btn_shangci = XTHDPushButton:createWithParams({
        normalFile        = "res/image/plugin/JiangJuFuGeneralRoom/shipu-an_1.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = "res/image/plugin/JiangJuFuGeneralRoom/shipu-an_2.png",
        touchScale = 0.9,
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            self:Award()
        end,
    })
    btn_shangci:setVisible(not self._isHavePet)
    self:addChild(btn_shangci)
    btn_shangci:setPosition(self._pet:getPosition())
    self._btn_shangciPet = btn_shangci

    --赏赐
    local btn_shangci = XTHDPushButton:createWithParams({
        normalFile        = "res/image/plugin/JiangJuFuGeneralRoom/shangci_1.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = "res/image/plugin/JiangJuFuGeneralRoom/shangci_2.png",
        musicFile = XTHD.resource.music.effect_btn_common,
    })
    self:addChild(btn_shangci)
    btn_shangci:setPosition(bar_bg:getPositionX() + 65,btn_shangci:getContentSize().height - 5)
    self._btn_shangci = btn_shangci

	self._btn_shangci:setTouchBeganCallback(function ()
		self:stopScheduler()
        schedule(self, function()
            schedule(self, function()
                self._isUsing = true
                if self:getActionByTag(10000) then
                    self:stopActionByTag(10000)
                end
				if not self._isProgressing and not self._isRequest then
					self:Pamper(true)    
				end
            end, 0.5, 10001)
        end, 1, 10000) 
	end)	
	
	self._btn_shangci:setTouchMovedCallback(function( touch )
        if not cc.rectContainsPoint( cc.rect( 0, 0, self._btn_shangci:getBoundingBox().width, self._btn_shangci:getBoundingBox().height ), self._btn_shangci:convertToNodeSpace( touch:getLocation() ) ) then
            self:stopScheduler()
            self._isUsing = false
        end
    end)
	
	self._btn_shangci:setTouchEndedCallback(function ()
        self:stopScheduler()
        if not self._isUsing and not self._isProgressing then
            self:Pamper(false)
        end
        self._isUsing = false
    end)

	local lable = XTHDLabel:createWithParams({
				text = "已进阶至最高等级",
				fontSize = 26,
				color = XTHD.resource.textColor.green_text,
				anchor = cc.p(0.5, 0),
				})
	self:addChild(lable)
	lable:setPosition(self._btn_shangci:getPositionX() - 40,self._btn_shangci:getPositionY() + 20)
	lable:setName("JinjieLable")
	lable:setVisible(false)
	
    --灯笼背景
    local denglong = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/bg_4.png")
    self:addChild(denglong)
    denglong:setPosition(cc.p(denglong:getContentSize().width / 2,denglong:getContentSize().height / 2))

    for i = 1,#self._equipment do
    	local btn = XTHDPushButton:createWithParams({
	        normalFile        = "res/image/plugin/JiangJuFuGeneralRoom/jjf_10.png",
	        selectedFile      = "res/image/plugin/JiangJuFuGeneralRoom/jjf_10.png",
	        musicFile = XTHD.resource.music.effect_btn_common,
	        endCallback       = function()
	           
	        end,
    	})
    	local x,y
    	local index = 0
    	if i %2 == 0 then
    		x = btn:getContentSize().width * 2 - 5 + 370
    		index = index + 1
    	else
    		x = btn:getContentSize().width * 2 - 5
    	end

    	if i == 3 or i == 4 then
    		y = self._bg:getContentSize().height - (btn:getContentSize().height*4 - 35)
    	elseif i == 5 or i == 6 then
    		y = self._bg:getContentSize().height - (btn:getContentSize().height*6 - 65)
    	else
    		y = self._bg:getContentSize().height - btn:getContentSize().height*2 + 10
    	end
    	self:addChild(btn)
        btn:setAnchorPoint(0.5,0.5)
    	btn:setPosition(cc.p(x,y))
    	self._btn_equipment[i] = btn
       -- local clock = cc.Sprite:create("res/image/plugin/saint_beast/lock.png")
        -- self._btn_equipment[i]:addChild(clock)
        -- clock:setPosition(self._btn_equipment[i]:getContentSize().width /2,self._btn_equipment[i]:getContentSize().height / 2)
        -- self._clockList[i] = clock
        -- local clockLabel = XTHDLabel:createWithParams({
        --     text = tostring(i + 1) .. "级解锁",
        --     fontSize = 16,
        --     color = cc.c3b(0,0,0),
        -- })
        -- clockLabel:setAnchorPoint(cc.p(0.5,0.5))
        -- self._clockList[i]:addChild(clockLabel)
        -- clockLabel:setPosition(cc.p(self._clockList[i]:getContentSize().width / 2,0)) 
    end

    local propertybg = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/bg_2.png")
    self:addChild(propertybg)
    propertybg:setAnchorPoint(cc.p(0.5,0.5))
    propertybg:setScale(0.9)
    propertybg:setPosition(cc.p(self:getContentSize().width / 2 + propertybg:getContentSize().width /2 + 35,self:getContentSize().height / 2 - 23))
    self._propertybg = propertybg

     --元宝显示
    for i = 1, 2 do
    	local res = {"res/image/common/header_gold.png","res/image/common/header_feicui.png"}
	    local _barkBG = cc.Sprite:create("res/image/common/topbarItem_bg.png")
	    _barkBG:setAnchorPoint(cc.p(0.5,0.5))
	    self:addChild(_barkBG)
	    _barkBG:setPosition(cc.p(self:getContentSize().width - 295 + ((i-1)*(_barkBG:getContentSize().width*1.5) - (i -1)*10) ,self:getContentSize().height - _barkBG:getContentSize().height / 2))

	    local _numLabel = getCommonWhiteBMFontLabel("999")
	    _barkBG:addChild(_numLabel)
	    _numLabel:setPosition(cc.p(_barkBG:getContentSize().width/2,_barkBG:getContentSize().height/2 - 5))
	    local num = nil 
	    if i == 1 then
	    	num = gameUser.getGold()
	    elseif i == 2 then
	    	num = gameUser.getFeicui()
	    end
	    _numLabel:setString(getHugeNumberWithLongNumber(gameUser.getGold(),1000000))
	    self._numLabel = _numLabel

	    local gold = cc.Sprite:create(res[i])
	    gold:setAnchorPoint(cc.p(0.5,0.5))
	    _barkBG:addChild(gold)
	    gold:setPosition(cc.p(0,_barkBG:getContentSize().height/2))

	    --增加元宝按钮
	    local _addButton  = XTHDPushButton:createWithParams({
	        normalFile        = "res/image/common/btn/btn_plus_normal.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
	        selectedFile      = "res/image/common/btn/btn_plus_selected.png",
	        musicFile = XTHD.resource.music.effect_btn_common,
	        endCallback       = function()
	  			if i == 1 then
	            	replaceLayer({id = 48,fNode = self})
	            else
	            	replaceLayer({id = 48,fNode = self})
	            end 
	        end,
	    })
	    _addButton:setTag(i)
	    local _size = _addButton:getContentSize()
	    _addButton:setAnchorPoint(1,0.5)
	    _addButton:setPosition(_barkBG:getContentSize().width + 10, _barkBG:getContentSize().height/2)
	    _barkBG:addChild(_addButton)
	    _addButton:setTouchSize(cc.size(_addButton:getContentSize().width + 20,_addButton:getContentSize().height))
	    _addButton:setTouchSize(cc.size(_size.width + 20,_size.height + 20))
	end

	local Sprsx = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/property.png")
	self._propertybg:addChild(Sprsx)
	Sprsx:setPosition(self._propertybg:getContentSize().width / 2,self._propertybg:getContentSize().height - Sprsx:getContentSize().height - 10)
	self._spProperty = Sprsx

	for i = 1,#self._Pro do
		local shuxing = XTHDLabel:createWithParams({
            text = self._Pro[i],
            fontSize = 26,
            color = cc.c3b(0,0,0),
        })
		self._propertybg:addChild(shuxing)
		shuxing:setAnchorPoint(cc.p(0,0.5))
        local numblevalue = XTHDLabel:createWithParams({
            text = tostring(self._ProNumber[i]) or "0",
            fontSize = 26,
            color = cc.c3b(0,0,0),
        })
        self._propertybg:addChild(numblevalue)
        numblevalue:setAnchorPoint(cc.p(0,0.5))
        shuxing:setPosition(self._propertybg:getContentSize().width / 2 - shuxing:getContentSize().width / 2 - 30,Sprsx:getPositionY() - (i) *shuxing:getContentSize().height - 10 )
        numblevalue:setPosition(shuxing:getContentSize().width*1.5 + 10 ,shuxing:getPositionY())
        self._shuxingValueLable[i] = numblevalue
		self._shuxingLable[i] = shuxing
	end
	
	local Tishi = XTHDLabel:createWithParams({
            text = "当前没有佩戴侍仆！",
            fontSize = 36,
            color = cc.c3b(0,0,0),
    })
	self._propertybg:addChild(Tishi)
	Tishi:setAnchorPoint(cc.p(0.5,0.5))
	Tishi:setPosition(self._propertybg:getContentSize().width / 2,self._propertybg:getContentSize().height / 2)
	self._Tishi = Tishi

	local Sprskill = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/skill.png")
	self._propertybg:addChild(Sprskill)
	Sprskill:setPosition(self._propertybg:getContentSize().width / 2,self._propertybg:getContentSize().height /2 - Sprsx:getContentSize().height - 50)
	self._spSkill = Sprskill

	for i = 1, 4 do
		local skill = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/jjf_10.png")
		self._propertybg:addChild(skill)
		skill:setAnchorPoint(cc.p(0.5,0.5))
		skill:setPosition(cc.p(skill:getContentSize().width *1.3*i +10,skill:getContentSize().height*1.5))
        self._skillList[i] = skill
		self._skillList[i]:setVisible(false)
	end
	local skillLable = XTHDLabel:createWithParams({
				text = "此功能暂未开放",
				fontSize = 30,
				color = XTHD.resource.textColor.green_text,
				anchor = cc.p(0.5, 0),
	})
	self._propertybg:addChild(skillLable)
	skillLable:setPosition(self._propertybg:getContentSize().width/2,100)
	self._skllLable = skillLable

    --self:ShowBtn()
    self:ShowInitScene()
    self:createHerosPetEquipments()
	self:createItemNode()
end

function JiangJunFuLayer:ShowInitScene(  )
    self._btn_shangciPet:setVisible(not self._isHavePet)
    self._btn_citui:setVisible(self._isHavePet)
    self._pet:setVisible(self._isHavePet)
	
    if self._nowPet then
        local name = "res/image/plugin/JiangJuFuGeneralRoom/puren_".. self.petData[self._nowPet.templateId]._type-500 ..".png"
        self._pet:setTexture(name)
		local petrank = self.petData[self._nowPet.templateId].rank
		if petrank >= 15 then
			self.bar_bg:setVisible(false)
			self._btn_shangci:setVisible(false)
			self._LuckyLable:setVisible(false)
			self:getChildByName("JinjieLable"):setVisible(true)
		else
			self.bar_bg:setVisible(self._isHavePet)
			self._btn_shangci:setVisible(self._isHavePet)
			self._LuckyLable:setVisible(self._isHavePet)
			self:getChildByName("JinjieLable"):setVisible(false)
		end
		
		self._wlgj = self._nowPet.physicalattack
		self._fsgj = self._nowPet.manaattack
		self._wlfy = self._nowPet.physicaldefence
		self._fsfy = self._nowPet.manadefence
		self._hp = self._nowPet.hp	
		self._ProNumber = { self._hp, self._wlgj, self._wlfy, self._fsgj, self._fsfy}
	else
			self.bar_bg:setVisible(self._isHavePet)
			self._btn_shangci:setVisible(self._isHavePet)
			self._LuckyLable:setVisible(self._isHavePet)
    end
	
	for i = 1,#self._shuxingValueLable do
        self._shuxingValueLable[i]:setString(tostring(self._ProNumber[i]))
		self._shuxingValueLable[i]:setVisible(self._isHavePet)
		self._shuxingLable[i]:setVisible(self._isHavePet)
    end

    for i = 1, #self._btn_equipment  do
        self._btn_equipment[i]:setVisible(self._isHavePet)
    end
	self._Tishi:setVisible(not self._isHavePet)
	self._spSkill:setVisible(self._isHavePet)
	self._spProperty:setVisible(self._isHavePet)
	for i = 1,#self._skillList do
		self._skillList[i]:setVisible(false)
	end
	self._skllLable:setVisible(self._isHavePet)
end

--把仆从赏赐给英雄
function JiangJunFuLayer:Award(  )
	local JiangJunFuFootmanLayer = requires("src/fsgl/layer/JiangJunFu/JiangJunFuFootmanLayer.lua"):create(self._heroID,self)
    self:addChild(JiangJunFuFootmanLayer)
    JiangJunFuFootmanLayer:show()
end

--赏赐仆从更新界面
function JiangJunFuLayer:UpdataShangCi(data)
    if data.petId == self._heroID then
        self._isHavePet = true
    else
        self._isHavePet = false
    end
    self._nowPet = data
    self._wlgj = data.physicalattack
    self._fsgj = data.manaattack
    self._wlfy = data.physicaldefence or 100
    self._fsfy = data.manadefence or 100
    self._hp = data.hp
    self._ProNumber = {self._wlgj, self._fsgj, self._wlfy, self._fsfy, self._hp}
	
	self._curLucky = data.curLucky
	self._maxLucky = self.petData[data.templateId].needlucky
	self:UpdateRichLable(self._curLucky,self._maxLucky)
	print(self._curLucky,self._maxLucky)
	
	local per = self._curLucky /self._maxLucky *100
	self._exp_progress_timer:setPercentage(per)	

    self:ShowInitScene()
	for i = 1,6 do
        if self._nowPet ~= nil then
        self._petEequipments[tostring(i)] = self._nowPet["items"..tostring(i)]
        end
    end
    self:createHerosPetEquipments()
	self:createItemNode()
	self._curRank = self.petData[data.templateId].rank
	local name = XTHD.resource.name[self.petData[data.templateId]._type] .. "+"..tostring(self._curRank)
	self._petName:setString(name)
	
end

--辞退仆从更新界面
function JiangJunFuLayer:UpdataCiTui( data )
	print("777777777777777777777777")
    self._isHavePet = false
    self._nowPet = data
  
    self:ShowInitScene()
    for i = 1,#self._shuxingValueLable do
        self._shuxingValueLable[i]:setVisible(false)
		self._shuxingLable[i]:setVisible(false)
    end
	self._petName:setString("")
	if self._ItemNode then
		self._ItemNode:removeFromParent()
		self._ItemNode = nil
	end
	self:ShowInitScene()
end

--赏赐仆从
function JiangJunFuLayer:Pamper(flag)
		self._isRequest = true
		print("aaaaa",self._nowPet.servantId)
        ClientHttp:requestAsyncInGameWithParams({
            modules = "servantPhase?",
            params  = {servantId = self._nowPet.servantId},
            successCallback = function( data )
				 self._isRequest = false
				-- dump(data)
                if data.result == 0 then
					if not flag then
                        XTHDTOAST(LANGUAGE_TIPS_PRESSLONG)
                    end
                    local addlucky = string.split( self.petData[self._nowPet.templateId].addlucky,'#')
					self._curLucky = data.curLucky
					self._nowPet.curLucky = data.curLucky
					self._nowPet.templateId = data.templateId
					self:UpdataProgress(addlucky[1])
					self._maxLucky = self.petData[self._nowPet.templateId].needlucky
					self._curRank = self.petData[self._nowPet.templateId].rank
					self._petName:setString(self.petData[self._nowPet.templateId].name .. "+" .. self._curRank)
					if self._curLucky == 0 then
						self:stopScheduler()
						self._btn_shangci:setSelected(false)
					end
					if data.items then
						for i = 1, #data.items do
							_data = data.items[i]
							DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
							if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
								self._last_select_dbid = nil
							end
						end
					 end

					if data.items then
						for i = 1, #data.items do
							local _data = data.items[i]
							DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
						end
						if self._ItemNode then
							self._ItemNode:removeFromParent()
							self._ItemNode = nil
						end
						self:createItemNode()
					end
					
					if data["petProperty"] then
						for j = 1,#data["petProperty"] do
							local _petItemData = string.split( data["petProperty"][j],',')
							DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],data["petId"])	
							if tonumber(_petItemData[1]) == 407 then
										--self._newFightValue = tonumber(_petItemData[2])
							end
						end
					end
					
					local tab = DBTableHero.getHeroData(data.petId)
					self:reFreshLeftLayer2(tab)
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

--辞退该名仆从
function JiangJunFuLayer:DismissPet(  )
    local dismiss = function ( ... )
        ClientHttp:requestAsyncInGameWithParams({
            modules = "petDropServant?",
            params  = {petId = self._heroID},
            successCallback = function( data )
                local petDatastr = {"hp", "physicalattack", "physicaldefence", "manaattack", "manadefence"}
				print("========================>>>>>",self._heroID)
                   self._nowPet.petId = 0
                   self._nowPet.hp = 0
                   self._nowPet.physicalattack =0
                   self._nowPet.physicaldefence =0
                   self._nowPet.manaattack =0
                   self._nowPet.manadefence =0
                   self:UpdataCiTui(DBPetData.DBData[data.servantId])
				
				if data["petProperty"] then
					for j = 1,#data["petProperty"] do
						local _petItemData = string.split( data["petProperty"][j],',')
						DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],data["petId"])	
						if tonumber(_petItemData[1]) == 407 then
									--self._newFightValue = tonumber(_petItemData[2])
						end
					end
				end
				local tab = DBTableHero.getHeroData(data.petId)
				self:reFreshLeftLayer2(tab)
            end,
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
            loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            loadingParent = node,
        })
    end
    local _confirmLayer = XTHDConfirmDialog:createWithParams( {
        rightCallback = dismiss,
        rightText = "辞  退",
        msg = ("辞退仆从会降低该仆从的好感度并花费100元宝，您确定要辞退吗")
    } );
    self:addChild(_confirmLayer, 1)
end

--给侍仆穿戴装备
function JiangJunFuLayer:ZhuangBei( index )
    local JiangJunFuShiPuZhuangBei = requires("src/fsgl/layer/JiangJunFu/JiangJunFuShiPuZhuangBei.lua"):create(index,self)
    self:addChild(JiangJunFuShiPuZhuangBei)
    JiangJunFuShiPuZhuangBei:show()
end

function JiangJunFuLayer:UpdataProgress(index)
	self._isProgressing = true
    local percentage = index / self._maxLucky * 100
    local Seq = cc.Sequence:create(cc.ProgressTo:create(0.3,self._exp_progress_timer:getPercentage() + percentage),cc.CallFunc:create(function( ... )
		self._isProgressing = false
		if self._curLucky <= self._maxLucky then
			self:UpdateRichLable(self._curLucky,self._maxLucky)
		else
			self._curLucky = self._maxLucky
			self:UpdateRichLable(self._curLucky,self._maxLucky)
			self._curLucky = 0
		end
        if self._curLucky == 0 then
           self._exp_progress_timer:setPercentage(0)
        end
        self:UpdateRichLable(self._curLucky,self._maxLucky)
		self._petName:setString(self.petData[self._nowPet.templateId].name .. "+" .. self._curRank)
    end))
    self._exp_progress_timer:runAction(Seq) 
end

--更新富文本显示
function JiangJunFuLayer:UpdateRichLable(str1, str2)
    self._LuckyLable:setString(tostring(str1) .. " / " .. tostring(str2))
end

--当前侍仆佩戴的装备
function JiangJunFuLayer:createHerosPetEquipments()
    --self._btn_equipment
    for i = 1,6 do
        local icon = cc.Sprite:create("res/image/plugin/hero/item_bg.png")
        self._btn_equipment[i]:addChild(icon)
        icon:setAnchorPoint(0.5,0.5)
        icon:setPosition(self._btn_equipment[i]:getContentSize().width/2,self._btn_equipment[i]:getContentSize().height/2)
        icon:setScale(1.6)
        if self._petEequipments[tostring(i)] ~= -1 then
			local gameBtn = ItemNode:createWithParams({
                    _type_ = 4,
                    itemId = self._petEequipments[tostring(i)],
                    needSwallow = true,
                    touchShowTip = false
            })
            self._btn_equipment[i]:addChild(gameBtn)
            gameBtn:setScale(0.7)
            gameBtn:setPosition(cc.p(gameBtn:getContentSize().width/2-15,gameBtn:getContentSize().height/2-17))
			gameBtn:setTouchEndedCallback(function ()
				 local GemPop = requires("src/fsgl/layer/JiangJunFu/JiangJuFuShiPuGemPop.lua"):create(i,self._petEequipments[tostring(i)],self)
                 self:addChild(GemPop)
                 GemPop:show()
			end)
        else
            local ChuandaiZhuangBei = XTHDPushButton:createWithParams({
                normalFile        = "res/image/plugin/hero/addMaterialNumber.png",
                selectedFile      = "res/image/plugin/hero/addMaterialNumber.png",
                touchScale = 0.9,
                musicFile = XTHD.resource.music.effect_btn_common,
                endCallback       = function()
                   self:ZhuangBei(i)
                end,
            })
            self._btn_equipment[i]:addChild(ChuandaiZhuangBei)
            ChuandaiZhuangBei:setAnchorPoint(0.5,0.5)
            ChuandaiZhuangBei:setScale(1.5)
            ChuandaiZhuangBei:setPosition(self._btn_equipment[i]:getContentSize().width/2-20,self._btn_equipment[i]:getContentSize().height/2 + 18)
        end
    end
end

--佩戴装备
function JiangJunFuLayer:EquipmentPet(dbid,index)
    ClientHttp:requestAsyncInGameWithParams({
        modules = "equipServant?",
        params  = {servantId = self._nowPet.servantId, dbId = dbid, index = index},
        successCallback = function( data )
			-- dump(data,"装备装备")
			if  data.result == 0 then
				local petDatastr = {"hp", "physicalattack", "physicaldefence", "manaattack", "manadefence"}
				for i = 1,5 do
					self._nowPet[petDatastr[i]] = data.servantProperty[20 .. tostring(i-1)] or 0
				end
				for i = 1,#data.servantItems do
					self._petEequipments[tostring(i)] = data.servantItems[i]
					self._nowPet["items"..tostring(i)] = data.servantItems[i]
				end
				for i = 1,#self._btn_equipment do
					self._btn_equipment[i]:removeAllChildren()
				end

                if data.bagItems then
                    for i = 1, #data.bagItems do
                        _data = data.bagItems[i]
                        DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                        if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
                            self._last_select_dbid = nil
                        end
                    end
                end
                
				if data["petProperty"] then
					for j = 1,#data["petProperty"] do
						local _petItemData = string.split( data["petProperty"][j],',')
						DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],data["petId"])	
						if tonumber(_petItemData[1]) == 407 then
									--self._newFightValue = tonumber(_petItemData[2])
						end
					end
				end
				local tab = DBTableHero.getHeroData(data.petId)
				self:reFreshLeftLayer2(tab)			
				self:createHerosPetEquipments()
				self:ShowInitScene()
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

--卸下装备
function JiangJunFuLayer:unloadGem(index)
	 ClientHttp:requestAsyncInGameWithParams({
            modules = "servantDropEquip?",
            params  = {servantId = self._nowPet.servantId,index = index},
            successCallback = function( data )
            if  data.result == 0 then
				local petDatastr = {"hp", "physicalattack", "physicaldefence", "manaattack", "manadefence"}
				--for i = 1,#petDatastr do
				-- dump(data.servantProperty)
				self._nowPet.hp = data.servantProperty["200"] or 0
				self._nowPet.physicalattack = data.servantProperty["201"] or 0
				self._nowPet.physicaldefence = data.servantProperty["202"] or 0
				self._nowPet.manaattack = data.servantProperty["203"] or 0
				self._nowPet.manadefence = data.servantProperty["204"] or 0
				--end

				for i = 1,#data.godItems do
					self._petEequipments[tostring(i)] = data.godItems[i]
					self._nowPet["items"..tostring(i)] = data.godItems[i]
				end
				for i = 1,#self._btn_equipment do
					self._btn_equipment[i]:removeAllChildren()
				end
                if data.bagItems then
                    for i = 1, #data.bagItems do
                        _data = data.bagItems[i]
                        DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                        if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
                            self._last_select_dbid = nil
                        end
                    end
                end
				
				if data["Petproperty"] then
					for j = 1,#data["Petproperty"] do
						local _petItemData = string.split( data["Petproperty"][j],',')
						DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],data["petId"])	
						if tonumber(_petItemData[1]) == 407 then
									--self._newFightValue = tonumber(_petItemData[2])
						end
					end
				end	
				local tab = DBTableHero.getHeroData(data.petId)
				self:reFreshLeftLayer2(tab)
				self:createHerosPetEquipments()
				self:ShowInitScene()
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

--
function JiangJunFuLayer:showSelectGem(index)
    local allGem = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{item_type = 7})
    -- ZCLOG(gemData)
    if allGem.itemid then
        allGem = {allGem}
    end
    if #allGem == 0 then
        --如果包里没有宝石
        --TODO
        XTHDTOAST(LANGUAGE_TIPS_WORDS8)-----("您的背包中没有玄符，请去神器商店中获取！")
        return
    end
    local GemSelectPop = requires("src/fsgl/layer/JiangJunFu/JiangJunFuShiPuGemSelectPop.lua"):create(allGem,function (dbid)
        self:changeGem(dbid,index)
    end)
    self:addChild(GemSelectPop)
    GemSelectPop:show()
end

function JiangJunFuLayer:changeGem(dbid,index)
    XTHDHttp:requestAsyncInGameWithParams({
        modules = "equipServant?",
        params = {servantId = self._nowPet.servantId, dbId = dbid, index = index},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
				self._nowPet.hp = data.servantProperty["200"] or 0
				self._nowPet.physicalattack = data.servantProperty["201"] or 0
				self._nowPet.physicaldefence = data.servantProperty["202"] or 0
				self._nowPet.manaattack = data.servantProperty["203"] or 0
				self._nowPet.manadefence = data.servantProperty["204"] or 0
                DBTableHero.multiUpdate(gameUser.getUserId(),data.petId,data.petProperty)
                local tmpList = {}
                for k,v in pairs(data.petProperty) do
					if k < 6 then
						local tab = string.split(v,",")
						local n = 200 + tonumber(k)-1
						local index = XTHD.resource.PetbutesName[n]
						tmpList[index] = tab[2]
					end
                end
                DBTableArtifact.multiUpdate(data.godId,tmpList,data.godItems)
                XTHD.saveItem({items = data.bagItems})

                --更新属性
                for i = 1,#data["petProperty"] do
                    local _petItemData = string.split( data["petProperty"][i],',')
                    DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[1],_petItemData[2],data["petId"])	
                    self._ProNumber[i] = _petItemData[2]
					self._petEequipments[tostring(i)] = data.servantItems[i]
					self._nowPet["items"..tostring(i)] = data.servantItems[i]
                end

				for i = 1,#self._btn_equipment do
					self._btn_equipment[i]:removeAllChildren()
				end
                if data.bagItems then
                    for i = 1, #data.bagItems do
                        _data = data.bagItems[i]
                        DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                        if self._last_select_dbid == _data["dbId"] and tonumber(_data["count"]) == 0 then
                            self._last_select_dbid = nil
                        end
                    end
                end
				local tab = DBTableHero.getHeroData(data.petId)
				self:reFreshLeftLayer2(tab)
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_HERO_INFO})
				self:createHerosPetEquipments()
				self:ShowInitScene()
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function JiangJunFuLayer:reFreshLeftLayer2(data)
    self._parent:reFreshLeftLayer(data)
end

function JiangJunFuLayer:stopScheduler()
    self:stopActionByTag(10000)
    self:stopActionByTag(10001)
end

--进阶材料
function JiangJunFuLayer:createItemNode()
	if self._nowPet then
		local itemID = nil
		local num = nil
		local petrank = self.petData[self._nowPet.templateId].rank
		if petrank < 15 then
			if petrank < 5 then
				itemID = self.petData[self._nowPet.templateId].needitem1
				num = self.petData[self._nowPet.templateId].num1
			elseif petrank >= 5 and petrank <= 9 then
				itemID = self.petData[self._nowPet.templateId].needitem2
				num = self.petData[self._nowPet.templateId].num2
			elseif petrank >= 10 and petrank <= 14 then
				itemID = self.petData[self._nowPet.templateId].needitem3
				num = self.petData[self._nowPet.templateId].num3
			end
			self._needNum = num
			local item1Num = XTHD.resource.getItemNum(itemID)

			local item_node = ItemNode:createWithParams({
				_type_ = 4,
				itemId = itemID,
				count = item1Num.."/".. num,
				isShowCount = true,
				fnt_type = item1Num >= num and 1 or 2
			})
			item_node:setScale(0.7)
			self:addChild(item_node)
			item_node:setPosition(cc.p(self._btn_shangci:getPositionX() - item_node:getContentSize().width * 1.4, self._btn_shangci:getPositionY()))
			self._ItemNode = item_node
			if item1Num < num then
				local btn = XTHDPushButton:createWithParams({
					normalFile        = "res/image/plugin/hero/addMaterialNumber.png",
					selectedFile      = "res/image/plugin/hero/addMaterialNumber.png",
					touchScale = 0.9,
					musicFile = XTHD.resource.music.effect_btn_common,
					endCallback       = function()
						local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
						popLayer= popLayer:create( tonumber( itemID) )
						self:addChild( popLayer, 3 )
					end,
				})
				btn:setAnchorPoint(0.5,0.5)
				self._ItemNode:addChild(btn)
				btn:setScale(1.5)
				btn:setPosition(self._ItemNode:getContentSize().width*0.3,self._ItemNode:getContentSize().height*0.7)
			end
		else
			self.bar_bg:setVisible(false)
			self._btn_shangci:setVisible(false)
			self._LuckyLable:setVisible(false)
			self:getChildByName("JinjieLable"):setVisible(true)
		end
	end
end

return JiangJunFuLayer