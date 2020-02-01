local TAG = "XuanZeYingXiongCopyLayer"

local XuanZeYingXiongCopyLayer = class("XuanZeYingXiongCopyLayer", function()
	return XTHDDialog:create()
end)

function XuanZeYingXiongCopyLayer:ctor(battle_type  ,instancingid)
	self._effSoundTb = {}
	self._battle_type = battle_type
	self._instancingid = instancingid
	self:setColor(cc.c3b(0,0,0))
	self:setOpacity(150)
	self._total_power = 0 --标记战斗力总值，进入界面之后，如果有预设队伍，则战斗力label需要有初始值，或者PVP模式3个队伍切换的时候，需要这个值来标记总战斗力
	self.m_heroItem = {} --存放已经选择的英雄
	self._Spine_List={} --存放所有的spine
end

function XuanZeYingXiongCopyLayer:onCleanup( ... )
end

function XuanZeYingXiongCopyLayer:onEnter()
	musicManager.playMusic(XTHD.resource.music.effect_seleceteHero_bgm )
end

function XuanZeYingXiongCopyLayer:selfDestroy( needCall )
	for k,v in pairs(self._effSoundTb) do
		local _id = tonumber(k) or 0
		self:playSoundEffect(_id)
	end
	if not needCall then
		cc.Director:getInstance():popScene()
		XTHD.dispatchEvent({name = "REMOVE_UNUSED_SPINES"})
	else
		self:removeFromParent()
	end
end

function XuanZeYingXiongCopyLayer:cleanTexture( ... )
    local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey(self._bg_imgpath)
    textureCache:removeTextureForKey("res/spine/effect/bossBackEff/haidi.png")
    helper.collectMemory()
end

function XuanZeYingXiongCopyLayer:init( battle_type  ,instancingid )
	self._selectData = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongDatas.lua")
	self._selectData.init(self)
    -- 返回按钮
    local _btnBack
    local function endCallback()
    	if _btnBack then
			_btnBack:setTouchEndedCallback(nil)
		end
	    self:cleanTexture()
		self:selfDestroy()
		musicManager.playMusic(XTHD.resource.music.music_bgm_main )
	end
	_btnBack = XTHD.createNewBackBtn(endCallback)
	self:addChild(_btnBack,2)

    --背景图的选取当前章节的第一个背景图，富有衔接感 嗯哼 →_→ 👈
    local bg_imgpath = self._selectData.getBackFileStr()
    self._bg_imgpath = bg_imgpath
	local bg_sp = cc.Sprite:create(bg_imgpath)
	bg_sp:setContentSize(self:getContentSize())
	bg_sp:setName("bg_sp")
	bg_sp:setPosition(self:getContentSize().width*0.5 , self:getContentSize().height*0.5)-- - TopBarLayer1:getContentSize().height-10)
	self:addChild(bg_sp)
	if bg_imgpath == "res/image/background/bg_53.jpg" then
		local __sp = sp.SkeletonAnimation:create("res/spine/effect/bossBackEff/haidi.json", "res/spine/effect/bossBackEff/haidi.atlas", 1.0)
	    local pos = cc.p(bg_sp:getContentSize().width*0.5, bg_sp:getContentSize().height*0.5)
	    __sp:setPosition(pos)
	    bg_sp:addChild(__sp)
	    __sp:setAnimation(0, "animation", true)
	end

	--开始战斗
	self._start_battle_btn, self._battle_effect = XTHD.createFightBtn({
    	par = self,
    	pos = cc.p(self:getContentSize().width - 90, self:getContentSize().height*0.5),
    	zorder2 = 2
	})
	self._battle_effect:setVisible(false)
	
	local list_bg_sp = ccui.Scale9Sprite:create("res/image/common/scale9_bg_20.png")
	list_bg_sp:setContentSize(cc.size(self:getContentSize().width, 110))
	list_bg_sp:setName("list_bg_sp")
	self._list_bg_sp = list_bg_sp
	list_bg_sp:setAnchorPoint(0.5,0)
	list_bg_sp:setPosition(self:getContentSize().width*0.5,0)
	self:addChild(list_bg_sp)
	--[[总战斗力 ,虽然我很不喜欢这个名字，但是还是先用着吧，等下全局替换之 O(∩_∩)O~
			之所以把总战力label生命在前面，是因为，后面切换按钮状态的时候，有些数据的展示，需要用到这个label
		]]
	self._battle_power_label = cc.Sprite:create("res/image/common/fightValue_Image.png")
	self._battle_power_label:setCascadeOpacityEnabled(true)
	self._battle_power_label:setVisible(false)
	self._battle_power_label:setAnchorPoint(0,0.5)
	
	self.m_labTotalCombatData = getCommonYellowBMFontLabel(self._total_power) 
	self.m_labTotalCombatData:setVisible(false)
	self.m_labTotalCombatData:setScale(1.5)
	self.m_labTotalCombatData:setAnchorPoint(cc.p(0, 0.5))
	self.m_labTotalCombatData:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1),1)

	self._battle_power_label:setPosition( 64, list_bg_sp:getContentSize().height + self._battle_power_label:getContentSize().width*0.5 + 5)
	self.m_labTotalCombatData:setPosition(self._battle_power_label:getPositionX() + self._battle_power_label:getContentSize().width + 5, self._battle_power_label:getPositionY() - 9)
	list_bg_sp:addChild(self._battle_power_label)	
	list_bg_sp:addChild(self.m_labTotalCombatData)
	self:ChangeBtnStatusAndRefreshData(nil,"right")
	
	--上阵英雄数目限制
	if self._battle_type == BattleType.EQUIP_PVE 
	  or self._battle_type == BattleType.JADITE_COPY_PVE 
	  or self._battle_type == BattleType.OFFERREWARD_PVE
	  or self._battle_type == BattleType.SINGLECHALLENGE then
	  	local tipDi = cc.Sprite:create("res/image/imgSelHero/x_40.png")
		tipDi:setAnchorPoint(0.5, 0.5)
		tipDi:setPosition(self:getContentSize().width*0.5, self:getContentSize().height - 25)
		self:addChild(tipDi,0)
		local limit_sp = cc.Sprite:create("res/image/imgSelHero/hero_num_limit.png")
		limit_sp:setAnchorPoint(0.7,0.5)
		limit_sp:setPosition(self:getContentSize().width*0.5, self:getContentSize().height-25)
		self:addChild(limit_sp,2)

		local count_label = getCommonWhiteBMFontLabel(self._hero_num_limit)
		count_label:setAnchorPoint(0,0.5)
		count_label:setScale(1.2)
		count_label:setPosition(limit_sp:getPositionX()+limit_sp:getContentSize().width*0.3, limit_sp:getPositionY()-9)
		self:addChild(count_label,limit_sp:getLocalZOrder())
	end

	self._start_battle_btn:setTouchBeganCallback(function()
		if self._battle_effect then
			self._battle_effect:setScale(0.98)
		end
	end)	
	
	self._start_battle_btn:setTouchMovedCallback(function()
		if self._battle_effect then
			self._battle_effect:setScale(1)
		end
	end)

	self._start_battle_btn:setTouchEndedCallback(function()
		if self._battle_effect then
			self._battle_effect:setScale(1)
		end
		self:addShieldLayout()
		local function star_battle()
			self:SaveAttackTeamInfo()
			self:BattleClickCallback(instancingid)
		end
		if self._selectData.haveCanOnTeam() then
			self:showTipDialog(star_battle)
		else
			star_battle()
		end
	end)
	self:initTablview()

	local function preloadAni( id , isStr)
		local nId = self._selectData.getAniId(id)
		local p = nil
		if nId ~= 322 and nId ~= 026 and nId ~= 042 then
			p = sp.SkeletonAnimation:createWithBinaryFile("res/spine/" .. nId .. ".skel", "res/spine/" .. nId .. ".atlas", 1)
		else
			p = sp.SkeletonAnimation:create("res/spine/" .. nId .. ".json", "res/spine/" .. nId .. ".atlas", 1)
		end
		
		if (isStr) then
			p:setPosition(-1000,-1000)
			self:addChild(p)
		end
		return p
	end
	if cc.PLATFORM_OS_ANDROID == ZC_targetPlatform then
		if(#self._totalHeroData > 0) then
			preloadAni(self._totalHeroData[1].heroid,true)
		end
	end

	if #self._heroIdCacheTb > 0 then
		local pLay = XTHD.createLayer()
		pLay:setTouchEnabled(true)
		pLay:registerScriptTouchHandler(function ( eventType, x, y )
			if (eventType == "began") then
				return true
			end
		end)
		self:addChild(pLay, 100)
		local loading_label = XTHDLabel:create(LANGUAGE_KEY_LOADINGWAIT.."...",20)--------正在加载资源，请稍后...",20)
		loading_label:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5 - 90)
		self:addChild(loading_label,100)
		local count = 1
		local function addGuide( ... )
			loading_label:removeFromParent()
			loading_label = nil
			pLay:removeFromParent()
			pLay = nil
			helper.collectMemory()
		end

		local aniList = {}
		local function prefreshAni( ... )
			local _heroId = self._heroIdCacheTb[count].id
			local pB = #self._heroIdCacheTb ~= 1
			local tmpData = {heroid = _heroId, isInit = pB, sData = _data, _spine = aniList[count]}
			self:RefreshSpine(tmpData)
			count = count + 1
			if count > #self._heroIdCacheTb then
				aniList = nil
				performWithDelay(self, addGuide, 0.2)
			else
				performWithDelay(self, prefreshAni, 0.05)
			end
		end

		local function preSpine( ... )
			for i = 1, #self._heroIdCacheTb do
				local _heroId = self._heroIdCacheTb[i].id
				aniList[i] = preloadAni(_heroId)
			end
			performWithDelay(self, prefreshAni, 0.01)
		end
		performWithDelay(self, preSpine, 0.01)
	end
end

--上阵人数没达到人数限制的时候，弹出提示框
function XuanZeYingXiongCopyLayer:showTipDialog(callback)
	local _confirmLayer 
	_confirmLayer = XTHDConfirmDialog:createWithParams( {
		isHide = false,
		leftCallback = function ( ... )
			_confirmLayer:removeFromParent()
		end,
        rightCallback  = function ()
        	if callback then
        		
        		callback()
        	end
    	end,
        msg = LANGUAGE_TIPS_WORDS164,----------"还有英雄可以上阵，是否直接进入战斗？"
    } );
	self:addChild(_confirmLayer,4)
end

function XuanZeYingXiongCopyLayer:initTablview(  )
	self._heroData = DBTableHero.getData(gameUser.getUserId()) or 1
	self.__roles = {}

	local bg_sp = self:getChildByName("bg_sp");
	local list_bg_sp =self:getChildByName("list_bg_sp")
	local pStartX = (self:getContentSize().width - 800)*0.5
	
	--英雄或者装备列表 list_bg_sp:getContentSize().width-80
	self.m_tableView = cc.TableView:create(cc.size(800-20, list_bg_sp:getContentSize().height));
	TableViewPlug.init(self.m_tableView)
	self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);
	self.m_tableView:setBounceable(true)
	self.m_tableView:setPosition(cc.p(pStartX + 10,0));
	self.m_tableView:setDelegate();
	list_bg_sp:addChild(self.m_tableView);

	local arrow_left_sp = XTHDImage:create("res/image/plugin/stageChapter/btn_left_arrow.png")
	-- arrow_left_sp:setFlippedX(true)
	arrow_left_sp:setPosition(pStartX-20, self.m_tableView:getPositionY() + self.m_tableView:getViewSize().height*0.5)
	arrow_left_sp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.8,cc.p(-10,0)),cc.MoveBy:create(0.8,cc.p(10,0)))))
	list_bg_sp:addChild(arrow_left_sp)

	local arrow_right_sp = XTHDImage:create("res/image/plugin/stageChapter/btn_right_arrow.png")
	arrow_right_sp:setPosition(list_bg_sp:getContentSize().width - pStartX+20, arrow_left_sp:getPositionY())
	arrow_right_sp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.8,cc.p(10,0)),cc.MoveBy:create(0.8,cc.p(-10,0)))))
	list_bg_sp:addChild(arrow_right_sp)
	-- 注册事件
	local function numberOfCellsInTableView( table )
		return self:numberOfCellsInTableView( table );
	end
	local function cellSizeForTable( table, idx )
		return self:cellSizeForTable( table, idx )
	end
	local function tableCellAtIndex( table, idx )
		return self:tableCellAtIndex( table, idx )
	end
    self.m_tableView.getCellNumbers = numberOfCellsInTableView
	self.m_tableView.getCellSize = cellSizeForTable

	local function scrollToPage(flag)
        local currPage = self.m_tableView:getCurrentPage()
        if flag == "left" then
            if currPage > 0 then
                self.m_tableView:scrollToCell(currPage - 1,true)
            end
        else
            if currPage < self:numberOfCellsInTableView(self.m_tableView)-1 then
                self.m_tableView:scrollToCell(currPage + 1,true)
            end
        end
    end

    arrow_left_sp:setTouchEndedCallback(function()
          scrollToPage("left")
    end)

    arrow_right_sp:setTouchEndedCallback(function()
          scrollToPage("right")
    end)

	 self.m_tableView.currentPageIndex = self.m_tableView:getCurrentPage()
	 self.m_tableView:registerScriptHandler(
	        function (view)
	        	local offsetx = self.m_tableView:getContentOffset().x
	        	local _ ,cell_width = self:cellSizeForTable(self.m_tableView)
	        	local offsetx2 = self.m_tableView:getContentOffset().x + self:numberOfCellsInTableView(self.m_tableView)*cell_width -self.m_tableView:getViewSize().width
	            if self:numberOfCellsInTableView(self.m_tableView)*cell_width <= self.m_tableView:getViewSize().width then
	            	--如果所有cell都显示出来，
	            	arrow_left_sp:setVisible(false)
		            arrow_right_sp:setVisible(false)
	            else
	            	--否则，根据偏移量来判断引导箭头的隐现
	            	 if offsetx > 0 then
		            	arrow_left_sp:setVisible(false)
		            elseif offsetx2 <=0  then
		            	arrow_right_sp:setVisible(false)
		            else
		            	arrow_left_sp:setVisible(true)
		            	arrow_right_sp:setVisible(true)
		            end
	            end
	           
	        end,cc.SCROLLVIEW_SCRIPT_SCROLL)

	self.m_tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    self.m_tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self.m_tableView:reloadData()
    if self._target_cellIndex and self._target_cellIndex>1 then
    	self.m_tableView:scrollToCell(self._target_cellIndex-1)
    end
end

function XuanZeYingXiongCopyLayer:cellSizeForTable(table,idx) 
    return self.m_tableView:getViewSize().height, (self.m_tableView:getViewSize().width)/7
end
function XuanZeYingXiongCopyLayer:numberOfCellsInTableView(table)
	if #self._data_source < 7 then
		if self._hero_tip and self._hero_tip < 1 then
			-- XTHDTOAST("暂时没有符合该条件的英雄")
		end
		self._hero_tip = 1
		return 7
	else
		self._hero_tip  = 0
	end
	return math.ceil(#self._data_source);
end

function XuanZeYingXiongCopyLayer:tableCellAtIndex(table, idx)
	local percellCount = 1 --每个cell节点数
   	local cell = table:dequeueCell();
    if cell then
    	cell:removeAllChildren()
    else
    	cell =  cc.TableViewCell:new();
    end
    cell:setContentSize(cc.size(90, 110));
   

	local temp_data = self._data_source[ idx+1]

	if temp_data then
		local item = nil 
		local _bSel = self:_bTheItemIsSelect(temp_data) --判断当前数据是否在已经选中的英雄或者道具列表中
		
		local _needHp = false
		local _curNum = 0 
		local _haveInit = false
		local pData
		if self._battle_type == BattleType.GODBEASE_PVE or self._battle_type == BattleType.SERVANT_PVE then
			pData = self._godBeast_selfInfo[tostring(temp_data["heroid"])]
			_needHp = true
			if pData then
				_curNum = pData["hp"] or nil
				_haveInit = pData["HaveInit"]
			end
		end
		item = HeroNode:createWithParams({
			heroid 	= temp_data["heroid"],
			star   	= temp_data["star"],
			level 	= temp_data["level"],
			advance = temp_data["advance"],
			needHp          = _needHp,--是否需要显示血条
			curNum          = _curNum,--当前血量
			deadNeedCall 	= true,
			isShowType      = true,
			deadCallback 	= function ()
				XTHDTOAST(LANGUAGE_TIPS_WORDS165)-------"已死亡，不能上阵")
			end
		})
		if self._battle_type == BattleType.GODBEASE_PVE or self._battle_type == BattleType.SERVANT_PVE then
			local _maxHp = item:getMaxHp()
			if pData then
				self._godBeast_selfInfo[tostring(temp_data["heroid"])]["maxHp"] = _maxHp
				if not _haveInit and self._godBeast_coverHp ~= 0 then
					local _now = item:getHp()
					if _now ~= 0 then
						local pNum = _now + _maxHp * self._godBeast_coverHp * 0.01
						pNum = pNum > _maxHp and _maxHp or pNum
						item:setHp(pNum, nil , false)
						self._godBeast_selfInfo[tostring(temp_data["heroid"])]["hp"] = pNum
						self._godBeast_selfInfo[tostring(temp_data["heroid"])]["HaveInit"] = true
					end
				end
			else
				local _now = item:getMaxHp()
				item:setHp(_now, nil , false)
				self._godBeast_selfInfo[tostring(temp_data["heroid"])] = {hp = _now, sp = 0, HaveInit = false, maxHp = _maxHp}
			end
		end

		if item then

			item:setEnableWhenMoving(true)
			-- Warning : 在PVP 模式下、再切换队伍的时候，需要刷新展示的spine，在此处处理可能是个错误，Who knows~
			local Target_id = temp_data["heroid"]
			
			if _bSel then
				-- local mask_layer = cc.LayerColor:create()
				-- mask_layer:setContentSize(item:getContentSize())
				-- mask_layer:setColor(cc.c3b(0,0,0))
				-- mask_layer:setOpacity(75)
				-- mask_layer:setVisible(_bSel)
				-- item:addChild(mask_layer)

				local m_tick = cc.Sprite:create("res/image/common/heroSelected_sp.png");
				m_tick:setName("m_tick")
				m_tick:setVisible(_bSel)
				m_tick:setAnchorPoint(cc.p(0.5, 0.5));
				m_tick:setPosition(cc.p(item:getContentSize().width*0.5, item:getContentSize().height*0.5));
				item:addChild(m_tick)
			end
			local pic
			if temp_data.isForcedCan then
				pic = cc.Sprite:create("res/image/imgSelHero/battleHeroType_bi.png")
	 			
	 		elseif temp_data.isForcedCannot then
				pic = cc.Sprite:create("res/image/imgSelHero/battleHeroType_jin.png")
		 	end
		 	if pic then
		 		pic:setPosition(item:getContentSize().width - 10,item:getContentSize().height - 10)
		 		item:addChild(pic)
		 		if item.typePic then
		 			item.typePic:setVisible(false)
		 		end
		 	end
				
			item:setName("hero")--设置不同的名字。用来区分点击的是装备还是英雄
			item:setTag(idx)--标记自己处于哪一个cell
			item:setTouchEndedCallback(function ()
				musicManager.playEffect(XTHD.resource.music.effect_btn_common) 
				self:ItemClickCallback(item,temp_data)
	   		end)

			local _y_pos,_x_pos = self:cellSizeForTable(table, idx) --self.m_tableView:getViewSize().height*0.5
			item:setPosition(cc.p(_x_pos*0.5, _y_pos*0.5));

			self.__roles[idx + 1] = item
	   		cell:addChild(item);
		end
	else
		local hero_box = cc.Sprite:create("res/image/imgSelHero/hero_box.png")
		local _y_pos,_x_pos = self:cellSizeForTable(table, idx) --self.m_tableView:getViewSize().height*0.5
		hero_box:setPosition(cc.p(_x_pos*0.5, _y_pos*0.5));
		cell:addChild(hero_box);
	end

    return cell
end

function XuanZeYingXiongCopyLayer:ItemClickCallback(sender,temp_data)
	local is_selected = self:_bTheItemIsSelect(temp_data )  --is_selected true:标示在已选列表中，false，标示不在已选列表中
	if is_selected == false then
		if not self._selectData.haveCanOnTeam() then
		-- if #self.m_heroItem >= self._hero_num_limit then
			XTHDTOAST(LANGUAGE_TIPS_WORDS174)------"上阵英雄数量已达上限")
			return
		end
		if self._selectData.isForcedIdCannot(temp_data["heroid"]) then
			XTHDTOAST(LANGUAGE_TIPS_WORDS212)------
			return
		end
		if self._selectData.isNotOnlyUseType(temp_data["heroid"]) then
			XTHDTOAST(LANGUAGE_TIPS_WORDS212)------
			return
		end
	else
		if self._selectData.isForcedIdCan(temp_data["heroid"]) then
			XTHDTOAST(LANGUAGE_TIPS_WORDS171)
			return
		end
	end
	self:AddOrRemoveData(temp_data,is_selected)			--操作数据，添加或者移除

	local tmpData = {heroid = temp_data["heroid"], _bSel = is_selected, bl_need_animation = false, cellindex = sender:getTag()}
	self:RefreshSpine(tmpData)  --操作展示区域的spine，添加或者移除
	
	if is_selected == true then
		self.m_labTotalCombatData:setString(tonumber(self.m_labTotalCombatData:getString()) - tonumber(temp_data["power"]))
	elseif is_selected == false then
		self.m_labTotalCombatData:setString(tonumber(self.m_labTotalCombatData:getString()) + tonumber(temp_data["power"]))
	end
	self:playSoundEffect(temp_data["heroid"], not is_selected)
	self.m_tableView:updateCellAtIndex(sender:getTag())
	
end

function XuanZeYingXiongCopyLayer:playSoundEffect( _heroId, show )
	if self._effSoundTb[_heroId] then
		musicManager.stopEffect(self._effSoundTb[_heroId])
		self._effSoundTb[_heroId] = nil
	end
	if show then
		local _id = XTHD.playHeroDubEffect(_heroId, "idle")
		if _id then
			self._effSoundTb[_heroId] = _id
		end
	end
end

--添加或者移除数据，从已选列表中移除，PVP模式总是要多判断的啦，或许以后还会有其他模式，But don't worry, we can make it.
function XuanZeYingXiongCopyLayer:AddOrRemoveData(tpm_data,_bSel)
	if _bSel == false then
		self.m_heroItem[#self.m_heroItem + 1] = tpm_data --往表中添加数据
	elseif _bSel == true then
		for i=1,#self.m_heroItem do
			if tonumber(self.m_heroItem[i]["heroid"]) == tonumber(tpm_data["heroid"]) then
				table.remove(self.m_heroItem,i)
				break
			end
		end
	end	
end

--切换按钮的状态，并且刷新当前列表的数据
function XuanZeYingXiongCopyLayer:ChangeBtnStatusAndRefreshData(sender,_type)
	-- if not sender then
	-- 	return
	-- end
	-- self.m_dataSourceType = "Hero"
	if _type == "right" then
		self._target_cellIndex = nil

	 -- 	if self._last_right_btn then
		-- 	if self._last_right_btn == sender then
		-- 		return
		-- 	end
		-- 	self._last_right_btn:setSelected(false)
		-- end
		-- sender:setSelected(true)
		-- self._last_right_btn = sender 
		self._data_source={}
		-- local _tag = tonumber(sender:getTag())
		local _tag = 1
		if _tag == 1 then
			self._data_source = self._totalHeroData
		elseif _tag == 2  then
			for i=1,#self._totalHeroData do
				if tonumber(self._totalHeroData[i]["attackrange"]) <IntervalBeforeAndMiddle then
					self._data_source[#self._data_source +1] = self._totalHeroData[i]
				end
			end
		elseif _tag == 3  then
			for i=1,#self._totalHeroData do
				if tonumber(self._totalHeroData[i]["attackrange"]) > IntervalBeforeAndMiddle and tonumber(self._totalHeroData[i]["attackrange"]) <IntervalMiddleAndAfter then
					self._data_source[#self._data_source +1] = self._totalHeroData[i]
				end
			end
		elseif _tag == 4  then
			for i=1,#self._totalHeroData do
				if tonumber(self._totalHeroData[i]["attackrange"]) > IntervalMiddleAndAfter then
					self._data_source[#self._data_source +1] = self._totalHeroData[i]
				end
			end
		elseif _tag == 5  then
			for i=1,#self._totalHeroData do
				if tonumber(self._totalHeroData[i]["attackrange"]) <IntervalBeforeAndMiddle then
					self._data_source[#self._data_source +1] = self._totalHeroData[i]
				end
			end
		end
	
		for i=1,#self._data_source do
			if	self:_bTheItemIsSelect(self._data_source[i]) then
				self._target_cellIndex = i 
				break
			end
		end

		if self.m_tableView then
			self.m_tableView:reloadData()
			if self._target_cellIndex then
		    	self.m_tableView:scrollToCell(self._target_cellIndex-1)
		    end
		end
	end
end


--刷新展示区的spine，增删操作 bl_need_animation,标示是否需要执行添加或者删除的烟雾动画
--,cellindex 标示该英雄在列表中的位置 
function XuanZeYingXiongCopyLayer:RefreshSpine( sParams )	
	local heroid = sParams.heroid
	local _bSel = sParams._bSel
	local bl_need_animation = sParams.bl_need_animation
	local cellindex = sParams.cellindex
	local isInit = sParams.isInit
	local _sData = sParams.sData
	local bg_sp = self --self:getChildByName("bg_sp")
	if not heroid then
		return
	end

	local function freshPos( ... )
		if(not isInit and #self._Spine_List == 1) then
			self._Spine_List[1]["spine"]:setLocalZOrder(1);
			self._Spine_List[1]["spine"]:setPosition(self._getPreviewItemPos[2])
		else
			for i =1, #self._Spine_List  do
				if i > 5 then
					break
				end
				if i % 2 == 0 then
					self._Spine_List[i]["spine"]:setLocalZOrder(2);
				else
					self._Spine_List[i]["spine"]:setLocalZOrder(1);
				end
				self._Spine_List[i]["spine"]:setPosition(self._getPreviewItemPos[i])
			end
		end
	end

	if not _bSel then
		local spine  = self:_newSkeltonton(heroid, sParams._spine)
		spine.heroid = heroid
		if cellindex then
			spine.cellindex = cellindex
		end
		spine:setAnimation(0,"idle",true)
		local _heroScale = spine:getScale();
		spine:setAnchorPoint(cc.p(0.5, 0));
		spine:setPosition(1000, 1000)
		spine:setScale(_heroScale);
		spine:setVisible(false)
		bg_sp:addChild(spine,tonumber(heroid)%3+1);
		local _attackrange = 0

		for i=1,#self.m_heroItem do
			if tonumber(self.m_heroItem[i]["heroid"]) == tonumber(heroid) then
				_attackrange = tonumber(self.m_heroItem[i]["attackrange"])
				break
			end
		end
		self._Spine_List[#self._Spine_List+1] = {["heroid"]= heroid ,["spine"]= spine,["attackrange"] =_attackrange}
		
		table.sort(self._Spine_List, function ( data1, data2 )
			local num1 = tonumber(data1["attackrange"]) or 0
			local num2 = tonumber(data2["attackrange"]) or 0
			if num1 ~= num2 then
				return num1 < num2
			end
			return data1["heroid"] < data2["heroid"]
		end)

		freshPos()
		
		if  bl_need_animation then
			spine:setScale(_heroScale)
			spine:setVisible(true)
		else
			spine:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function ()
				local spSmoke = sp.SkeletonAnimation:create("res/spine/effect/line_up/yxsz.json","res/spine/effect/line_up/yxsz.atlas")
				spSmoke:setAnchorPoint(cc.p(0.5, 0));
				spSmoke:setPosition(spine:getPosition());
				spSmoke:setScale(2)
				spSmoke:setAnimation(0,"animation",false)
				bg_sp:addChild(spSmoke,spine:getLocalZOrder()-1)
				performWithDelay(spSmoke,function()
					spSmoke:removeFromParent()
					end, 2)
				spine:setOpacity(60)
				local scaleAction = cc.ScaleTo:create(0.2, _heroScale);
				spine:runAction(cc.Spawn:create(scaleAction,cc.Sequence:create(cc.DelayTime:create(0.04),cc.CallFunc:create(function()
					spine:setVisible(true);
					end),cc.FadeTo:create(0.14,255))))

			end) ))
		end
	else
		for i = #self._Spine_List,1,-1 do
			if tostring(self._Spine_List[i]["heroid"]) == tostring(heroid) then
				local spine =self._Spine_List[i]["spine"]
				table.remove(self._Spine_List,i)
				spine:removeFromParent()
				if  bl_need_animation then
					freshPos()
				else
					freshPos()
				end
				break
			end
		end
	end

	if self._start_battle_btn then
		if #self._Spine_List < 1 then
			self._start_battle_btn:setVisible(false)
			self._battle_effect:setVisible(false)
		else
			self._start_battle_btn:setVisible(true)
			self._battle_effect:setVisible(true)
		end
	end
	
	if self._battle_power_label then
		self._battle_power_label:setVisible(self._start_battle_btn:isVisible())
	end
	if self.m_labTotalCombatData then
		self.m_labTotalCombatData:setVisible(self._battle_power_label:isVisible())
	end
end

--进入战斗，战斗
function XuanZeYingXiongCopyLayer:BattleClickCallback( sInstancingid )
	local _params = {ectypeId = sInstancingid}
	local instanceData
				
	if self._battle_type == BattleType.OFFERREWARD_PVE then
		_params = {configId = sInstancingid}
	elseif self._battle_type == BattleType.SINGLECHALLENGE then
        _params = {ectypeId = sInstancingid}
	elseif self._battle_type == BattleType.WORLDBOSS_PVE or self._battle_type == BattleType.JADITE_COPY_PVE then
		local _tb = {}
		for i=1, #self._Spine_List do
			local id = self._Spine_List[i]["heroid"] or 0   
			_tb[#_tb + 1] = id
		end
		_params.myTeam = json.encode(_tb)
	elseif self._battle_type == BattleType.GUILD_BOSS_PVE then
		_params = {configId = sInstancingid}	
	end
	ClientHttp.http_StartChallenge(self, self._battle_type, _params, function(data)
		local teamListLeft = {}
    	local teamListRight = {}
    	local bgList = {}
    	local _instanceId, sound, battle_time, battleUILayer, endCallBack
    	local battleLayer = requires("src/battle/BattleLayer.lua"):create()

		if self._battle_type == BattleType.GOLD_COPY_PVE then -- 银两副本
			XTHD.dispatchEvent({name = "JADITE_IS_NEED_REFRESH"})
			for i=1,#self._Spine_List do
				local id = self._Spine_List[i]["heroid"] or 0  
				local animal = {id = id ,_type = ANIMAL_TYPE.PLAYER}
		    	teamListLeft[#teamListLeft + 1] = animal
			end

			local instanceData = gameData.getDataFromCSV("SilverGame", {["instancingid"]=data["ectypeLevel"]})
			_instanceId = data["ectypeLevel"]
			sound = "res/sound/"..tostring(instanceData.sound)..".mp3"
			local background = instanceData.background
			bgList[#bgList + 1] = "res/image/background/bg_"..background..".jpg"
			--当前银两副本的等级
			local gold_level = instanceData["gold"] or 0.1

			local monster = data.monsterProperty
			if monster then
				local rightData 		= {}
            	local team 				= {}
            	local monsterid = monster.monsterid
        		local animal = {id = monsterid, _type = ANIMAL_TYPE.MONSTER, monster = monster}
			    team[#team + 1]=animal
				--[[--排队]]
		    	table.sort( team, function(a,b) 
		    		local n1 = tonumber(a.monster.attackrange) or 0
		    		local n2 = tonumber(b.monster.attackrange) or 0
		    		return n1 < n2
		    	end )
				rightData.team = team
				teamListRight[#teamListRight + 1] = rightData
			end
			battle_time = instanceData["maxtime"] or 60
			battleUILayer = requires("src/fsgl/battle/ui/BattleUIGoldCopyLayer.lua"):create(battle_time, tonumber(gold_level), data["ectypeLevel"], battleLayer)
			endCallBack = function(params)
				--如果大象被打死
				if tonumber(params.result) == 1 then
					local killaward = gameData.getDataFromCSV("SilverGame", {level = data["ectypeLevel"]})["killaward"] or 0
					XTHD.dispatchEvent({name = "GOLD_COPY_GET_GOLD_NUM",data = {killmoney = killaward} }) 
				end
				ClientHttp.http_SendFightValidation(battleLayer, function(data)
					performWithDelay(battleLayer, function()
	                	battleLayer:hideWithoutBg()
						data.backCallback = function() 
							cc.Director:getInstance():popScene()
						end
	                	battleLayer:addChild(requires( "src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoPVELayer.lua"):create(data))
					end, 2)
				end, function()
					createFailHttpTipToPop()
				end, params)
			end
		elseif self._battle_type == BattleType.JADITE_COPY_PVE or self._battle_type == BattleType.EQUIP_PVE then
			XTHD.dispatchEvent({name = "JADITE_IS_NEED_REFRESH"})
			if data.heros and next(data.heros) ~= nil then
	    		for k,hero in pairs(data.heros) do
					local petId = hero.petId
					local _staticData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = petId}) or {}
					hero.attackrange = _staticData.attackrange 
					local animal = {id = petId ,_type = ANIMAL_TYPE.PLAYER , data = hero }
		    		teamListLeft[#teamListLeft + 1] = animal
				end
				--[[--排队]]
				table.sort(teamListLeft, function(a,b) 
		    		local n1 = tonumber(a.data.attackrange) or 0
		    		local n2 = tonumber(b.data.attackrange) or 0
		    		return n1 < n2
		    	end )
			else
				for i=1,#self._Spine_List do
					local id = self._Spine_List[i]["heroid"] or 0  
					local animal = {id = id ,_type = ANIMAL_TYPE.PLAYER}
			    	teamListLeft[#teamListLeft + 1] = animal
				end
			end

			local instanceData
			if self._battle_type == BattleType.JADITE_COPY_PVE then
				instanceData = gameData.getDataFromCSV("TrialTower", {["instancingid"]=sInstancingid})
			else
				instanceData = gameData.getDataFromCSV("ShenbinggeList", {["instancingid"]=sInstancingid})
			end
			_instanceId = sInstancingid
			sound = "res/sound/"..tostring(instanceData.sound)..".mp3"
			battle_time = instanceData.maxtime
			local background   = instanceData.background
			bgList[#bgList + 1] = "res/image/background/bg_"..background..".jpg"
			local rightData = {}
            --[[--该波的怪物]]
        	local waveMonsters 		= data.monsters
        	local team 				= {}
        	for k,monster in pairs(waveMonsters) do
        		local monsterid = monster.monsterid
        		local animal = {id = monsterid , _type = ANIMAL_TYPE.MONSTER,monster = monster}
			    team[#team + 1]=animal
        	end
			if team ~= nil and #team > 0 then
		    	--[[--排队]]
		    	table.sort( team, function(a,b) 
		    		local n1 = tonumber(a.monster.attackrange) or 0
		    		local n2 = tonumber(b.monster.attackrange) or 0
		    		return n1 < n2
		    	end )
				rightData.team = team
				teamListRight[#teamListRight + 1] = rightData
			end
			battleUILayer = requires("src/fsgl/battle/ui/BattleUIEquipCopyLayer.lua"):create()
			endCallBack = function(params)
				ClientHttp.http_SendFightValidation(battleLayer, function(data)
					performWithDelay(battleLayer, function()
						battleLayer:hideWithoutBg()
						data.backCallback = function() 
							cc.Director:getInstance():popScene()
						end
                		battleLayer:addChild(requires( "src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoPVELayer.lua"):create(data))
					end, 2)
				end, function()
					createFailHttpTipToPop()
				end, params)
			end
		elseif self._battle_type == BattleType.GODBEASE_PVE or self._battle_type == BattleType.SERVANT_PVE then
			for i=1,#self._Spine_List do
				local id = self._Spine_List[i]["heroid"] or 0 
				local pData = self._godBeast_selfInfo[tostring(id)]
				local _hp, _sp, _maxHp
				if pData then
					_hp = tonumber(pData["hp"]) or 0
					_sp = tonumber(pData["sp"]) or 0
					_maxHp = tonumber(pData["maxHp"]) or 0
				end
				local animal = {
					id = id,
					_type = ANIMAL_TYPE.PLAYER,
					startHp = _hp,
					startMaxHp = _maxHp,
					startSp = _sp,
				}
		    	teamListLeft[#teamListLeft + 1] = animal
			end

			local rightData = {}							
			local team = {}

			local instanceData = gameData.getDataFromCSV("RelicsEnemyList", {["instancingid"]=sInstancingid})
			sound = "res/sound/"..tostring(instanceData.sound)..".mp3"
			battle_time = instanceData.maxtime
			bgList[#bgList + 1] = "res/image/background/bg_"..instanceData.background..".jpg"

			local _monsterList = data.monsterList
			local _lengthCount = #_monsterList
			if _lengthCount > 0 then
				for i = 1, _lengthCount do
					local monster = _monsterList[i]
					if monster.curHp ~= 0 then
						for k,v in pairs(self._godBeast_enemyInfo) do
							if(v.petId == monster.monsterid) then
								monster.curHp = v.hp
							end
						end
						local animal = {id = monster.monsterid , _type = ANIMAL_TYPE.MONSTER, monster = monster}
						team[#team + 1] = animal
					end
				end
			end
			if team ~= nil and #team > 0 then
		    	--[[--排队]]
		    	table.sort( team, function(a,b) 
		    		local n1 = tonumber(a.monster.attackrange) or 0
		    		local n2 = tonumber(b.monster.attackrange) or 0
		    		return n1 < n2
		    	end )
				rightData.team = team
				teamListRight[#teamListRight + 1] = rightData
			end
			
			
			battleUILayer = requires("src/fsgl/battle/ui/BattleUIEquipCopyLayer.lua"):create()
			endCallBack = function(params)
				ClientHttp.http_SendFightValidation(battleLayer, function(data)
					if tonumber(data.bagGodStone) then
                        gameUser.setSaintStone(data.bagGodStone)
                    end
					performWithDelay(battleLayer, function()
						battleLayer:hideWithoutBg()
						data.backCallback = function() 
							cc.Director:getInstance():popScene()
						end
	                	battleLayer:addChild(requires( "src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoPVELayer.lua"):create(data))
                	end, 2)
                end, function()
					createFailHttpTipToPop()
				end, params)
			end
		elseif self._battle_type == BattleType.OFFERREWARD_PVE or self._battle_type == BattleType.SINGLECHALLENGE then
			for i=1,#self._Spine_List do
				local id = self._Spine_List[i]["heroid"] or 0  
				local animal = {id = id ,_type = ANIMAL_TYPE.PLAYER}
		    	teamListLeft[#teamListLeft + 1] = animal
			end
			local instanceData
			if self._battle_type == BattleType.OFFERREWARD_PVE then
                instanceData = gameData.getDataFromCSV("XsTaskList", {["instancingid"] = sInstancingid})
            elseif self._battle_type == BattleType.SINGLECHALLENGE then
                instanceData = gameData.getDataFromCSV("OneVsOne", {["instancingid"] = sInstancingid})
			end
			sound = "res/sound/"..tostring(instanceData.sound)..".mp3"
			battle_time = instanceData.maxtime
			local background  = instanceData.background
			local bgs = string.split(background,"#")
			for k,bgId in pairs(bgs) do
				bgList[#bgList + 1] = "res/image/background/bg_"..bgId..".jpg"
			end
        	local monsters = data.monsters
            for index = 1,#monsters do
				local rightData = {}
            	local waveMonsters = monsters[index]
            	local team = {}
            	for k,monster in pairs(waveMonsters) do
            		local monsterid = monster.monsterid
            		local animal = {id = monsterid , _type = ANIMAL_TYPE.MONSTER,monster = monster}
				    team[#team + 1]=animal
            	end
				if team ~= nil and #team > 0 then
			    	--[[--排队]]
			    	table.sort( team, function(a,b) 
			    		local n1 = tonumber(a.monster.attackrange) or 0
			    		local n2 = tonumber(b.monster.attackrange) or 0
			    		return n1 < n2
			    	end )
					rightData.team = team
					teamListRight[#teamListRight + 1] = rightData
				end
            end
            battleUILayer = requires("src/fsgl/battle/ui/BattleUIEquipCopyLayer.lua"):create()
            endCallBack = function(params)
				ClientHttp.http_SendFightValidation(battleLayer, function(data)
					performWithDelay(battleLayer, function()
						battleLayer:hideWithoutBg()
						data.backCallback = function() 
							cc.Director:getInstance():popScene()
						end
	                	battleLayer:addChild(requires( "src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoWorldBossLayer.lua"):create(data))
                	end, 2)
                end, function()
					createFailHttpTipToPop()
				end, params)
			end
		elseif self._battle_type == BattleType.WORLDBOSS_PVE then
			if data.heros and next(data.heros) ~= nil then
	    		for k,hero in pairs(data.heros) do
					local petId = hero.petId
					local _staticData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = petId}) or {}
					hero.attackrange = _staticData.attackrange 
					local animal = {id = petId ,_type = ANIMAL_TYPE.PLAYER , data = hero }
		    		teamListLeft[#teamListLeft + 1] = animal
				end
				--[[--排队]]
				table.sort(teamListLeft, function(a,b) 
		    		local n1 = tonumber(a.data.attackrange) or 0
		    		local n2 = tonumber(b.data.attackrange) or 0
		    		return n1 < n2
		    	end )
			else
				for i=1,#self._Spine_List do
					local id = self._Spine_List[i]["heroid"] or 0  
					local animal = {id = id ,_type = ANIMAL_TYPE.PLAYER}
			    	teamListLeft[#teamListLeft + 1] = animal
				end
			end
			sound = "res/sound/bgm_world_boss.mp3"
			battle_time = 180
			bgList[#bgList + 1] = "res/image/worldboss/unOpenBack0.png"
			local rightData = {}
        	local monsters = {{data.boss}}
            for index=1, #monsters do
				local rightData 		= {}
				--[[--该波的怪物]]
            	local waveMonsters 		= monsters[index]
            	local team 				= {}
            	for k,monster in pairs(waveMonsters) do
            		local monsterid = monster.monsterid
            		local animal = {
            			id = monsterid, 
            			_type = ANIMAL_TYPE.MONSTER,
            			monster = monster, 
            			isWorldBoss = true,
            			m_startHp = monster.curHp
            		}
				    team[#team + 1]=animal
            	end
				if team ~= nil and #team > 0 then
			    	--[[--排队]]
			    	table.sort( team, function(a,b) 
			    		local n1 = tonumber(a.monster.attackrange) or 0
			    		local n2 = tonumber(b.monster.attackrange) or 0
			    		return n1 < n2
			    	end )
					rightData.team = team
					teamListRight[#teamListRight + 1] = rightData
				end
			end
			local bossdata = data.boss
            battleUILayer = requires("src/fsgl/battle/ui/BattleUIWorldBoss.lua"):create(bossdata)
			endCallBack = function(params)
				ClientHttp.http_SendFightValidation(battleLayer, function(data)
					performWithDelay(battleLayer, function()
						battleLayer:hideWithoutBg()
						data.backCallback = function() 
							cc.Director:getInstance():popScene()
						end
						data.bossdata = bossdata
	                	battleLayer:addChild(requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoWorldBossLayer.lua"):create(data))
                	end, 2)
                end, function()
					createFailHttpTipToPop()
				end, params)  
			end		
        elseif self._battle_type == BattleType.GUILD_BOSS_PVE then
			for i=1,#self._Spine_List do
				local id = self._Spine_List[i]["heroid"] or 0  
				local animal = {id = id ,_type = ANIMAL_TYPE.PLAYER}
		    	teamListLeft[#teamListLeft + 1] = animal
			end
			local instanceData = gameData.getDataFromCSV("SectBoss", {["id"] = sInstancingid})
			sound = "res/sound/"..tostring(instanceData.bgm)..".mp3"
			battle_time = instanceData.time
			local background  = instanceData.background or 1
			bgList[#bgList + 1] = "res/image/background/bg_"..background..".jpg"
			local rightData = {}
        	local monsters = {data.monsters}
        	local bossdata
            for index=1, #monsters do
				local rightData 		= {}
				--[[--该波的怪物]]
            	local waveMonsters 		= monsters[index]
            	local team 				= {}
            	for k,monster in pairs(waveMonsters) do
            		local monsterid = monster.monsterid
            		local animal = {
            			id = monsterid, 
            			_type = ANIMAL_TYPE.MONSTER,
            			monster = monster, 
            			m_startHp = monster.curHp
            		}
            		bossdata = monster
				    team[#team + 1]=animal
            	end
				if team ~= nil and #team > 0 then
			    	--[[--排队]]
			    	table.sort( team, function(a,b) 
			    		local n1 = tonumber(a.monster.attackrange) or 0
			    		local n2 = tonumber(b.monster.attackrange) or 0
			    		return n1 < n2
			    	end )
					rightData.team = team
					teamListRight[#teamListRight + 1] = rightData
				end
            end
            battleUILayer = requires("src/fsgl/battle/ui/BattleUIWorldBoss.lua"):create(bossdata)
			endCallBack = function(params)
				ClientHttp.http_SendFightValidation(battleLayer, function(data)
					performWithDelay(battleLayer, function()
						battleLayer:hideWithoutBg()
						data.backCallback = function() 
							cc.Director:getInstance():popScene()
						end
						data.bossdata = bossdata
	                	battleLayer:addChild(requires("src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoWorldBossLayer.lua"):create(data))
                	end, 2)
                end, function()
					createFailHttpTipToPop()
				end, params)  
			end		
		end
		battleLayer:initWithParams({
			bgList 			= bgList,
			bgm    			= sound,
			instancingid    = _instanceId,
			teamListLeft	= {teamListLeft},
			teamListRight	= teamListRight,
			battleType 		= self._battle_type,
			battleTime      = battle_time,
			battleEndCallback = endCallBack,
		})
		self:selfDestroy(true)
    	local scene = cc.Director:getInstance():getRunningScene()
		scene:addChild(battleLayer)
		battleLayer:setUILay(battleUILayer)
		scene:addChild(battleUILayer)
		-- cc.Director:getInstance():pushScene(scene)
		battleLayer:start()
	end)
end

function XuanZeYingXiongCopyLayer:_newSkeltonton( id , _spine)
	local nId = self._selectData.getAniId(id)
	local _hero = XTHDTouchSpine:create( id,"res/spine/" .. nId .. ".skel", "res/spine/" .. nId .. ".atlas", 1, _spine)
	if  _hero then
		_hero:setShowDes(true)
		_hero:setNeedMoveFunc(true)
		_hero:setTouchEndedCallback(function()
			if self._selectData.isForcedIdCan(_hero.heroid) then
				XTHDTOAST(LANGUAGE_TIPS_WORDS171)
				return
			end
			self:AddOrRemoveData({["heroid"]=_hero.heroid},true)			--操作数据，添加或者移除
			local tmpData = {heroid = _hero.heroid, _bSel = true}
			self:RefreshSpine(tmpData)
			if _hero.cellindex then
				self.m_tableView:updateCellAtIndex(_hero.cellindex)
			else
				self.m_tableView:reloadDataAndScrollToCurrentCell()
			end
			local _heroData = DBTableHero.getDataByID(id)
			local pNum = tonumber(_heroData["power"]) or 0
			self.m_labTotalCombatData:setString(tonumber(self.m_labTotalCombatData:getString()) - pNum)
			self:playSoundEffect(_hero.heroid, false)
		end)
		
		local _heroData = gameData.getDataFromCSV( "GeneralInfoList", {["heroid"]=id} )
		local _heroScale = _heroData["scale"]
		_hero:setScale( _heroScale )
		_hero._scale = _heroScale
		return _hero
	end	
end

--[[检查点击的元素是否已经被选中，此处只坐数据比较，不进行删除添加操作 其中:
	self.m_heroItem 存储所有选中的英雄，不区分副本模式还是PVP模式
	self.propsItem  存储所有选中的道具，同样不做任何模式的区分
]]
function XuanZeYingXiongCopyLayer:_bTheItemIsSelect(_temp_data)
	for i = #self.m_heroItem,1,-1  do
		if tonumber(self.m_heroItem[i]["heroid"]) == tonumber(_temp_data["heroid"]) then
			return true;
		end
	end
	return false;
end

function XuanZeYingXiongCopyLayer:SaveAttackTeamInfo()
	local _team_data = {}
  	for i = 1, 5 do
  		if(self._Spine_List[i]) then
	  		_team_data["heroid"..i] = tonumber(self._Spine_List[i]["heroid"]) or 0
  		else
  			_team_data["heroid"..i] = 0
	  	end
  	end
  	_team_data.teamid = 1
	DBUserTeamData:UpdatePVETeamData(_team_data)
end

--[[
--神兽副本需要传递英雄的当前血量信息，需要开此方法
	Hps = data.hps,
	refreshFunc
]]
function XuanZeYingXiongCopyLayer:setCallbackFuncs_GODBEASE(params)
	self._godBeats_data = params or {}
	self._godBeast_refreshFunc = params["refreshFunc"] or nil
	self._godBeast_enemyInfo = params["hps"]["enemys"]
	self._godBeast_selfInfo = {}

	local hprecover = tonumber(params["hprecover"]) or 0
	self._godBeast_coverHp = hprecover

	for i=1,#params["hps"]["players"] do
		local _tmp_data = params["hps"]["players"][i]
		if _tmp_data then
			local _key = tostring(_tmp_data["petId"])
			self._godBeast_selfInfo[_key] = {hp = _tmp_data["hp"], sp = _tmp_data["sp"], HaveInit = false}
		end
	end
end
function XuanZeYingXiongCopyLayer:getCallbackFuncs_GODBEASE()
	return self._godBeats_data or {}
end


function XuanZeYingXiongCopyLayer:create(battle_type, instancingid, param, source_type,teamIndex,cityId)
	if  source_type then
		self._user_data = param or {}
		self._target_teamIndex = teamIndex or 1 
	else
		if param and param["teams"] then
			self._user_data = param["teams"]
			-- 保存敌人的全部信息  
			self.m_tmpRivalData = param; 
		end
	end

	local obj = self.new(battle_type  ,instancingid)
	obj:init(battle_type  ,instancingid)
	return obj
end

function XuanZeYingXiongCopyLayer:addShieldLayout()
	local _lay = XTHDDialog:create(0)
	cc.Director:getInstance():getRunningScene():addChild(_lay, 100)
	performWithDelay(_lay, function()
		_lay:removeFromParent()
	end, 0.01)
end

--[[
	createWithParams{
		battle_type  	--战斗类型
		instancingid, 	--战斗关卡id
		teaminfo, 			--传进来的队伍信息，如果是进攻，则不需要传此参数，因为进攻队伍信息都存在本地了，目前只有PVP和种族战用到了该参数有用来设置防守队伍
		source_type,	--调用源
		teamIndex,		--目标队伍id，需要设置的防守队伍的队伍id
		cityId 			--种族战cityID 
		godBeast_data 	=  --神兽战需要传递进来的英雄和刷新数据函数
		Camp_data = hero_data --种族战战斗选人的时候，传进来的防守英雄信息，这些英雄不能参加战斗了啦
	}
]]
function XuanZeYingXiongCopyLayer:createWithParams(params)
	-- print("XuanZeYingXiongCopyLayer需要封装的数据")
	-- print_r(params)
	self._battle_type = params.battle_type 
	if params.battle_type == BattleType.GODBEASE_PVE or params.battle_type == BattleType.SERVANT_PVE then
		self:setCallbackFuncs_GODBEASE(params["godBeast_data"])
	end

	params.instancingid = params.instancingid or nil

	local obj = self.new(params.battle_type  ,params.instancingid)
	obj:init(params.battle_type  ,params.instancingid)
	return obj
end

return XuanZeYingXiongCopyLayer
