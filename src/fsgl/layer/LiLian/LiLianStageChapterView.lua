-- FileName: LiLianStageChapterView.lua
-- Author: wangming
-- Date: 2016-01-14
-- Purpose: 新的历练主ui逻辑类滚动类
--[[TODO List]]
requires("src/fsgl/layer/LiLian/LiLianStageChapterData.lua")

local LiLianStageChapterView = class("LiLianStageChapterView",function()
	return XTHD.createBasePageLayer({
		isShadow = true, 
		ZOrder = 3,
		isCreateBg = false,
	})
end)


function LiLianStageChapterView:onCleanup()
	-- musicManager.playBackgroundMusic(self._lastMusic, true)
	if self._callBack then
		self._callBack()
	end
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TASKLIST})
	
	helper.collectMemory()
end

function LiLianStageChapterView:onEnter()
	-- musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_selectchapter, true)

	performWithDelay(self,function (  )
		self:showWinStory()

		if self._clickCover then 
			self._clickCover:removeFromParent()
			self._clickCover = nil
		end 
	end,0.05)
end

function LiLianStageChapterView:onExit()
	self._arrow_sp = nil
end

function LiLianStageChapterView:ctor( sParams )

	self._lastMusic = musicManager._lastMusicPath

	local _params = sParams or {}
	_params.target_instancingid = sParams.targetId or 0

	self._callBack = _params.callback
	
	self._chapterType = _params.chapter_type or ChapterType.Diffculty
	self:freshMaxInfo()
	local _targetStageId = tonumber(_params.target_instancingid)
	if _targetStageId == 0 then
		_targetStageId = nil
	end

	local _info, _page 
	if _targetStageId ~= nil then
		_info = LiLianStageChapterData.getStageInfoById(_targetStageId) 
	end
	if _info == nil or next(_info) == nil then
		_targetStageId = nil
		_info = self:getNowMaxInfo()
	end
	_page = _info.chapterid

	local _params = {
		chapterId = _page,
		chapterType = self._chapterType,
		stageId = _targetStageId,
	}

	self:initUI(_params)

end

function LiLianStageChapterView:freshMaxInfo()
	self._maxDiffculty = LiLianStageChapterData.getMaxChapterStage(ChapterType.Diffculty)
end

function LiLianStageChapterView:getNowMaxInfo()
	return self._maxDiffculty
end

function LiLianStageChapterView:initUI( sParams )

	local title_bg_path = "res/image/plugin/stageChapter/title_bg_normal.png"
	local title_bg = XTHD.createSprite(title_bg_path)
	title_bg:setAnchorPoint(0,1)
	title_bg:setPosition(11 , self:getContentSize().height - 65)
	-- self:addChild(title_bg, 2)
	-- self._title_bg = title_bg
	--章节名字文本
	local title_current = XTHD.createSprite()
	title_current:setAnchorPoint(cc.p(0, 0.5))
	title_current:setPosition(cc.p(65, title_bg:getContentSize().height / 2-6))
	-- title_bg:addChild(title_current)
	-- self._title_current = title_current

	--页面改变后续操作
	local function _freshStageName()
		local _page = self._bgView:getCurrentPage()
		-- local spFrame = XTHD.resource.getNormalChapterNameSpFrame(_page)
		-- if spFrame then
		-- 	title_current:setSpriteFrame(spFrame)
		-- end

		self._currentPage = _page
		self:afterChangePage()
	end

	local function _touchStageCall()
		local _page = self._bgView:getCurrentPage()
		local _params = {
			chapterId = _page,
			chapterType = self._chapterType
		}
		self:showTable(false)
		self:showStageInfo(_params)
	end

                    -- print("os33333333333--------------> ", socket.gettime() )

	local view = requires("src/fsgl/layer/common/StageViewLayer1.lua"):create(sParams.chapterId)
	self:addChild(view)
	view:setPageFreshCall(_freshStageName)
	view:setTouchedCall(_touchStageCall)
	view:setSwapCall(function() self:showTable(false) end)
	self._bgView = view
	_freshStageName()

                    -- print("os22222222222--------------> ", socket.gettime() )


	local _enterBtn = XTHD.createButton({
        normalFile = "res/image/plugin/stageChapter/newBg/jinru_up.png",
        selectedFile = "res/image/plugin/stageChapter/newBg/jinru_down.png",
        needSwallow = false,
        anchor = cc.p(1, 0),
        pos = cc.p(self:getContentSize().width, 0),
        endCallback = _touchStageCall
    })
    -- self:addChild(_enterBtn)

	if sParams.stageId ~= nil then --指定进入 
		self:showStageInfo(sParams)
	end

	--arrow
	-- local pArrow_sp = cc.Sprite:create()
 --    local brust_animation = getAnimation("res/image/plugin/stageChapter/arrow_sp_animal/jt", 1, 6, 1/7)
 --    pArrow_sp:runAction(cc.RepeatForever:create(brust_animation))
 --    self:addChild(pArrow_sp)
 --    pArrow_sp:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
	-- pArrow_sp:runAction(cc.RepeatForever:create(
	-- 	cc.Sequence:create(cc.MoveBy:create(0.8, cc.p(0, 15)),
	-- 	cc.DelayTime:create(0.1),
	-- 	cc.MoveBy:create(0.8, cc.p(0, -15)),
	-- 	cc.DelayTime:create(0.1))
	-- ))

	-- do
	-- 	return
	-- end 

	--普通  精英 噩梦
	local normal_btn = XTHDPushButton:createWithParams({
		normalFile = "res/plugin/stageChapter/btn_normal_normal_up.png",
		selectedFile = "res/plugin/stageChapter/btn_normal_normal_down.png",
	})
	self.normal_btn = normal_btn
	normal_btn:setAnchorPoint(cc.p(1,0))
	--local name_normal = XTHDLabel:create("普通",26,"res/fonts/def.ttf")
	--name_normal:enableOutline(cc.c4b(45,13,103,255),2)
	--name_normal:setPosition(normal_btn:getContentSize().width/2,normal_btn:getContentSize().height/2)
	--normal_btn:addChild(name_normal)
	--normal_btn:setPosition(self:getContentSize().width, 150)
	normal_btn:setPosition(self:getContentSize().width * 0.5 - 10 - normal_btn:getContentSize().width*0.5, 8)
	normal_btn.source_type = ChapterType.Normal
	normal_btn:setTouchEndedCallback(function()

		LayerManager.addShieldLayout(nil, 1)
		XTHD.playYunActionIn(self, function()
			self:getParent():runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()

				XTHD.playYunActionOut(cc.Director:getInstance():getRunningScene())
				LayerManager.removeLayout(self)

		        local _data = {chapter_type = ChapterType.Normal}
		        local layer = requires("src/fsgl/layer/LiLian/LiLianStageChapterLayer.lua"):create(_data)
		        LayerManager.addLayout(layer)
			end)))
		end)


	end)

	local elite_btn = XTHDPushButton:createWithParams({
		normalFile = "res/plugin/stageChapter/btn_elite_normal_up.png",
		selectedFile = "res/plugin/stageChapter/btn_elite_normal_down.png",
	})
	self.elite_btn=elite_btn
	elite_btn:setAnchorPoint(cc.p(1,0))
	elite_btn:setPosition(normal_btn:getPositionX() + normal_btn:getContentSize().width  + 10, normal_btn:getPositionY())
	--elite_btn:setPosition(normal_btn:getPositionX(),normal_btn:getPositionY()-elite_btn:getContentSize().height/2-20)
	--local elite_normal = XTHDLabel:create("精英",26,"res/fonts/def.ttf")
	--elite_normal:enableOutline(cc.c4b(45,13,103,255),2)
	--elite_normal:setPosition(elite_btn:getContentSize().width/2,elite_btn:getContentSize().height/2)
	--elite_btn:addChild(elite_normal)
	elite_btn.source_type = ChapterType.ELite
	elite_btn:setTouchEndedCallback(function()
		LayerManager.addShieldLayout(nil, 1)
		XTHD.playYunActionIn(self, function()
			self:getParent():runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()

				XTHD.playYunActionOut(cc.Director:getInstance():getRunningScene())
				LayerManager.removeLayout(self)

		        local _data = {chapter_type = ChapterType.ELite}
		        local layer = requires("src/fsgl/layer/LiLian/LiLianStageChapterLayer.lua"):create(_data)
		        LayerManager.addLayout(layer)
		    end)))
		end)




	end)
	--噩梦副本
	local diff_btn = XTHDPushButton:createWithParams({
		normalFile = "res/plugin/stageChapter/btn_diffculty_normal_up.png",
		selectedFile = "res/plugin/stageChapter/btn_diffculty_normal_down.png",
	})
	self.diff_btn=diff_btn
	diff_btn:setAnchorPoint(cc.p(1,0))
	diff_btn:setPosition(elite_btn:getPositionX() + diff_btn:getContentSize().width  + 10, normal_btn:getPositionY())
	--diff_btn:setPosition(normal_btn:getPositionX(), elite_btn:getPositionY() - elite_btn:getContentSize().height/2-20)

	--local diff_normal = XTHDLabel:create("噩梦",26,"res/fonts/def.ttf")
	--diff_normal:enableOutline(cc.c4b(45,13,103,255),2)
	--diff_normal:setPosition(diff_btn:getContentSize().width/2,diff_btn:getContentSize().height/2)
	--diff_btn:addChild(diff_normal)

	--local selected_box_2 = cc.Sprite:create("res/image/common/stage_l.png")
	--selected_box_2:setPosition(diff_btn:getContentSize().width/2, diff_btn:getContentSize().height/2)
	--selected_box_2:setVisible(false)
	--local name_selected = XTHDLabel:create("噩梦",26,"res/fonts/def.ttf")
	--name_selected:enableOutline(cc.c4b(45,13,103,255),2)
	--name_selected:setPosition(selected_box_2:getContentSize().width/2,selected_box_2:getContentSize().height/2)
	--selected_box_2:addChild(name_selected)
	--diff_btn:addChild(selected_box_2)

--	local selected_box_2 = cc.Sprite:create("res/image/plugin/stageChapter/btn_chapter_box.png")
--	selected_box_2:setPosition(elite_btn:getContentSize().width/2, elite_btn:getContentSize().height/2)
--	diff_btn:addChild(selected_box_2)
	--normal_btn:setScale(0.7)
	--elite_btn:setScale(0.7)
	--diff_btn:setScale(0.7)
	
	self:addChild(normal_btn, 1)
	self:addChild(elite_btn, 1)
	self:addChild(diff_btn, 1)

	--转盘按钮
    local turn_btn = XTHD.createButton({
        normalFile           = "res/image/plugin/stageChapter/turn_levelUp_normal.png",
        selectedFile         = "res/image/plugin/stageChapter/turn_levelUp_selected.png",
        needSwallow          = false,
        anchor               = cc.p(1,1),
        pos                  = cc.p(self:getContentSize().width-20, self:getContentSize().height - 60),
        endCallback = function()
        	XTHD.createLevelUpTurn(self, function(_turnData)
        		local function refresh(backdata)
    				if gameUser.getZhuanpanCount() == 0 and gameUser.getLevel() > 40 then
    					if self._turnBtn then
    						self._turnBtn:setVisible(false)
    					end
    				end
					if gameUser.getZhuanpanCount() == 0 then
						if self._turnRedDot then
				    		self._turnRedDot:setVisible(false)
				    	end
					end
        		end
				self:showTable(false)
		        local pop = requires("src/fsgl/layer/LiLian/LiLianlevelUpLuckTurnPop.lua"):create({data = _turnData, _callback = refresh})
        		LayerManager.addLayout(pop, {noHide = true})
        	end)
        end,
    })
    turn_btn:setVisible(false)
	self:addChild(turn_btn,1)
	self._turnBtn = turn_btn
    local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
    turn_btn:addChild(redDot)
    redDot:setPosition(turn_btn:getBoundingBox().width - 5, turn_btn:getBoundingBox().height - 20)
    redDot:setVisible(false)
	self._turnRedDot = redDot
	if gameUser.getZhuanpanCount() > 0 then
    	self._turnRedDot:setVisible(true)
	end
	if gameUser.getLevel() < 40 then
    	turn_btn:setVisible(true)
	else
		if gameUser.getZhuanpanCount() > 0 then
    		turn_btn:setVisible(true)
		end
	end

	--选择章节

	-- local di = cc.Sprite:create("res/image/plugin/stageChapter/zhuan_di_tu.png")
	local di = XTHDImage:create("res/image/plugin/stageChapter/zhuan_di_tu.png")
	di:setAnchorPoint(0, 0)
	di:setPosition(1, 1)
	self:addChild(di, 5)

	local chapterId = self._bgView:getCurrentPage()
	self._currentPage = chapterId


	self._chapterInfo = LiLianStageChapterData.getChapterInfoById(self._chapterType, self._currentPage)
	self._allStar = LiLianStageChapterData.getChapterStars(self._chapterType, self._currentPage)

	local chapterName = XTHDLabel:createWithParams({
		text = self._chapterInfo.name or "",
		fontSize = 20,
		color = XTHD.resource.color.brown_desc,
		anchor = cc.p(0, 0.5),
		pos = cc.p(17, di:getContentSize().height/2),
	})
	di:addChild(chapterName)
	
	local star = cc.Sprite:create("res/image/common/star_light.png")
	star:setAnchorPoint(0.5, 0.5)
	star:setPosition(226, di:getContentSize().height/2)
	di:addChild(star)

	local starNum = XTHDLabel:createWithParams({
		text = self._allStar.."/"..self._chapterInfo.totalstar,
		fontSize = 20,
		color = XTHD.resource.color.brown_desc,
		anchor = cc.p(0, 0.5),
		pos = cc.p(star:getPositionX()+star:getContentSize().width/2, di:getContentSize().height/2),
	})
	di:addChild(starNum)

	self._chapterName = chapterName
	self._starNum = starNum
	
    local infoBtn = XTHD.createButton({
    	touchSize = cc.size(120,50),
    	endCallback = function()
    		self:showTable(self._isUp)
    	end,
    	pos = cc.p(di:getContentSize().width-26, di:getContentSize().height/2),
    })
    self._infoBtn = infoBtn
    -- di:addChild(infoBtn, 12)

    di:setTouchEndedCallback(function()
		self:showTable(self._isUp)
    end)
    local normal = cc.Sprite:create("res/image/illustration/shangsheng_up.png")
    normal:setAnchorPoint(0.5, 0.5)
    normal:setPosition(di:getContentSize().width-20, di:getContentSize().height/2)
    di:addChild(normal)
    normal:setScale(0.7)
    self._normal = normal
    local selected = cc.Sprite:create("res/image/illustration/sorttype_up.png")
    selected:setAnchorPoint(0.5, 0.5)
    selected:setPosition(di:getContentSize().width-20, di:getContentSize().height/2)
    di:addChild(selected)
    selected:setVisible(false)
    selected:setScale(0.7)
    self._selected = selected
    self._isUp = true

end
function LiLianStageChapterView:showTable(_type)

	-- print("_type --> ", _type)
	if _type == true then

		self._allChapter = LiLianStageChapterData.getAllChapterStar(self._chapterType)

		if #self._allChapter == 0 then
			return 
		end
		local sizeHeight = {
			[1] = 70,
			[2] = 110,
			[3] = 150,
			[4] = 190,
			[5] = 230,
			[6] = 260,
		}
		local _height = sizeHeight[#self._allChapter] or sizeHeight[6]

		-- print("_height --> ", _height)
		local tableSize = cc.size(323, _height)
		local tableNode = self
		
		local myTableBg = ccui.Scale9Sprite:create(cc.rect(15,15,1,1), "res/image/plugin/stageChapter/zhuan_table_bg.png")
		myTableBg:setContentSize(tableSize)
		myTableBg:setAnchorPoint(cc.p(0, 0))
		myTableBg:setPosition(cc.p(1, 58))
		tableNode:addChild(myTableBg)

		self._myTableBg = myTableBg

		local titleLab = XTHDLabel:createWithParams({
			text = "请选择跳转章节",
			fontSize = 18,
			color = cc.c3b(255, 230, 22),
			anchor = cc.p(0.5, 1),
			pos = cc.p(myTableBg:getContentSize().width/2, myTableBg:getContentSize().height-7),
		})
		myTableBg:addChild(titleLab)

		local leftSp = cc.Sprite:create("res/image/common/titlepattern_left.png")
		leftSp:setAnchorPoint(1, 0.5)
		leftSp:setPosition(titleLab:getPositionX()-titleLab:getContentSize().width/2, myTableBg:getContentSize().height-18)
		myTableBg:addChild(leftSp)
		local rightSp = cc.Sprite:create("res/image/common/titlepattern_right.png")
		rightSp:setAnchorPoint(0, 0.5)
		rightSp:setPosition(titleLab:getPositionX()+titleLab:getContentSize().width/2, leftSp:getPositionY())
		myTableBg:addChild(rightSp)
		
		local myTable = cc.TableView:create(cc.size(myTableBg:getContentSize().width-4,myTableBg:getContentSize().height-35))
		TableViewPlug.init(myTable)
		myTable:setPosition(2,2)
		myTable:setBounceable(false)
		myTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
		myTable:setDelegate()
		myTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
		
		self._myTable = myTable
		myTableBg:addChild(myTable)
		
		myTable.getCellSize = function(table,idx)
			return tableSize.width,37 
		end
		
		myTable.getCellNumbers = function(table)
		    return #self._allChapter
		end

		local function tableCellAtIndex(table,idx)
			local nowIdx = idx + 1
			local cell = table:dequeueCell()
		    if cell == nil then
		        cell = cc.TableViewCell:new()
		        cell:setContentSize(cc.size(tableSize.width, 37))
		    else
		    	cell:removeAllChildren()
		    end
		    self:buildCell(cell, nowIdx)
		    return cell
		end
		myTable:registerScriptHandler(myTable.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
		myTable:registerScriptHandler(myTable.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
		myTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
		
		myTable:reloadData()
		
		if self._currentPage then

			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()

				if self._myTable then
					self._myTable:scrollToCell(self._currentPage-1,false)
				end
			end)))

		end

	else
		if self._myTableBg  then
			self._myTableBg:removeFromParent()
			self._myTableBg=nil
			self._myTable = nil
		end
	end
	if _type == true then
		self._normal:setVisible(false)
		self._selected:setVisible(true)
		self._isUp = false
	else
		self._isUp = true
		if self._normal and self._selected then
			self._normal:setVisible(true)
			self._selected:setVisible(false)
		end
	end

end

function LiLianStageChapterView:buildCell(cell, nowIdx)

	local chapterData = self._allChapter[nowIdx]
	-- dump(chapterData, "chapterData ====== ")
	local cellSize = cell:getContentSize()

	local _path = "res/image/plugin/stageChapter/zhuan_cell_bg.png"
	if nowIdx == self._currentPage then
		_path = "res/image/plugin/stageChapter/zhuan_choose_img.png"
	end
	local cellImg = cc.Sprite:create(_path)
	cellImg:setAnchorPoint(0.5, 0.5)
	cellImg:setPosition(cellSize.width/2, cellSize.height/2)
	-- cell:addChild(cellImg)

	local cellBtn = XTHD.createButton({
		needSwallow = false,
		normalNode = cellImg,
		endCallback = function()
			-- print("clicked ... ======================")
			if nowIdx ~= tonumber(self._currentPage) then
				-- print("to go to page ........ ")
				self:gotoPage(nowIdx)
			end
		end,
		touchSize = cellSize,
		pos = cc.p(cellSize.width/2, cellSize.height/2),
		needEnableWhenMoving = true,
		-- pos = cc.p(0, 0)
	})
	cell:addChild(cellBtn)

	local chapterName = XTHDLabel:createWithParams({
		text = chapterData.name or "",
		fontSize = 18,
		color = cc.c3b(253,230,193),
		anchor = cc.p(0, 0.5),
		pos = cc.p(27, cell:getContentSize().height/2),
	})
	cell:addChild(chapterName)
	
	local star = cc.Sprite:create("res/image/common/star_light.png")
	star:setAnchorPoint(0.5, 0.5)
	star:setPosition(220, cell:getContentSize().height/2)
	cell:addChild(star)

	local _labColor = cc.c3b(255,255,255)
	if tonumber(chapterData.rewardState) == 1 then
		_labColor = cc.c3b(51, 216, 24)
	elseif tonumber(chapterData.rewardState) == 0 then
		_labColor = cc.c3b(243, 32, 22)
	end

	local starNum = XTHDLabel:createWithParams({
		text = chapterData.allStar.."/"..chapterData.totalstar,
		fontSize = 22,
		color = _labColor,
		anchor = cc.p(0, 0.5),
		pos = cc.p(star:getPositionX()+star:getContentSize().width/2 + 10, cell:getContentSize().height/2),
	})
	cell:addChild(starNum)

end

function LiLianStageChapterView:gotoPage(_id)
	--showPage之后的操作 fresh
	self._bgView:showPage(_id)
end

--改变页面之后的后续操作
function LiLianStageChapterView:afterChangePage()
	if self._myTableBg and self._myTable then
		--更新数据
		self._allChapter = LiLianStageChapterData.getAllChapterStar(self._chapterType)
		self._myTable:reloadDataAndScrollToCurrentCell()
	end
	self._chapterInfo = LiLianStageChapterData.getChapterInfoById(self._chapterType, self._currentPage)
	self._allStar = LiLianStageChapterData.getChapterStars(self._chapterType, self._currentPage)
	if self._chapterName then
		self._chapterName:setString(self._chapterInfo.name)
	end
	if self._starNum then
		self._starNum:setString(self._allStar.."/"..self._chapterInfo.totalstar)
	end
	if gameUser.getZhuanpanCount() > 0 and self._turnRedDot then
    	self._turnRedDot:setVisible(true)
	end
end

function LiLianStageChapterView:showStageInfo( sParams )
	local function _showPass( _nowType , isPass)
		-- print("pass   ========= ", _nowType, isPass)
		self._chapterType = _nowType or ChapterType.Diffculty
		if isPass == true then
			self:showStagePassEffect()
		end
		--
		self._isLoging = false
		self:afterChangePage()
	end
	local isOpen, _chapterType = LiLianStageChapterData.hasOpened(sParams.chapterId)
	if not isOpen then
		XTHDTOAST(LANGUAGE_KEY_NOTOPEN)
		return
	end
	sParams._callBack = _showPass
	if self._isLoging then
		return 
	end
	self._isLoging = true
	performWithDelay(self, function()
		local luaPop = requires("src/fsgl/layer/LiLian/LiLianStageNewLayer.lua")
		LayerManager.addLayout(luaPop:create(sParams), {noHide = _noHide})
	end, 0.01)

end

function LiLianStageChapterView:showStagePassEffect()
	local _oldInfo = self:getNowMaxInfo()
	self:freshMaxInfo()

	local pass_dialog = XTHDDialog:create()
	pass_dialog:setSwallowTouches(true)
	pass_dialog:setColor(cc.c3b(0,0,0))
	pass_dialog:setOpacity(100)
	local effect_light = cc.Sprite:create("res/image/exchange/reward/reward_light_circle.png")
	effect_light:runAction(cc.RepeatForever:create( cc.RotateBy:create(1,20) ))
	effect_light:setPosition(pass_dialog:getContentSize().width/2, pass_dialog:getContentSize().height/2+70)

	local effect_spine = sp.SkeletonAnimation:create( "res/spine/effect/chapter_pass/lingqujuanzhou.json", "res/spine/effect/chapter_pass/lingqujuanzhou.atlas",1.0);
	effect_spine:setPosition(pass_dialog:getContentSize().width/2, pass_dialog:getContentSize().height/2)
	local effect_spine2 = sp.SkeletonAnimation:create( "res/spine/effect/chapter_pass/lingquziti.json", "res/spine/effect/chapter_pass/lingquziti.atlas",1.0);
	effect_spine2:setPosition(effect_spine:getContentSize().width*0.5, effect_spine:getContentSize().height)
	effect_spine:addChild(effect_spine2)
	
	-- local chapter_name_sp  = XTHD.resource.getNormalChapterNameSpFrame(_oldInfo.chapterid)
	-- if not chapter_name_sp then
	-- 	return
	-- end
	local pStringName = LiLianStageChapterData.getChapterInfoById(self._chapterType, _oldInfo.chapterid).name

	local label_name = XTHDLabel:createWithParams({
		text = pStringName,
		anchor = cc.p(0.5, 0.5),
		color = cc.c3b(70,34,34),
		size = 20,
		pos = cc.p(effect_spine:getContentSize().width*0.5-30, effect_spine:getContentSize().height*0.5)
	})
	effect_spine:addChild(label_name)
	-- label_name:runAction(cc.Sequence:create(cc.FadeOut:create(0.205),cc.FadeIn:create(0.205)))
			
	local label_pass = XTHDLabel:createWithParams({
		text = LANGUAGE_FORMAT_TIPS49,
		size = 20,
		anchor = cc.p(0, 0.5),
		color = cc.c3b(187,27,10),
		pos = cc.p(effect_spine:getContentSize().width*0.5-30+label_name:getContentSize().width*0.5+10, effect_spine:getContentSize().height*0.5)
	})
	effect_spine:addChild(label_pass)
	-- label_pass:runAction(cc.Sequence:create(cc.FadeOut:create(0.205),cc.FadeIn:create(0.205)))
	
	
	-- local label_level = XTHDLabel:createWithParams({
	-- 	text = LANGUAGE_KEY_NEXT_STAGE(pStringLevel),
	-- 	size = 20,
	-- 	anchor = cc.p(0.5, 0.5),
	-- 	color = cc.c3b(194,172,51),
	-- 	pos = cc.p(effect_spine:getContentSize().width/2,effect_spine:getContentSize().height/2-40),
	-- })
	-- effect_spine:addChild(label_level)
	-- label_level:runAction(cc.Sequence:create(cc.FadeOut:create(0.205),cc.FadeIn:create(0.205)))
			
	effect_spine:runAction(cc.Sequence:create(cc.FadeOut:create(0.205),cc.FadeIn:create(0.205)))
	effect_spine:setAnimation(0,"lingqujuanzhou",false)
	effect_spine2:setAnimation(0,"tgl",false)
	pass_dialog:addChild(effect_light)
	pass_dialog:addChild(effect_spine)
	self:addChild(pass_dialog,4)
	performWithDelay(pass_dialog,function()
		effect_spine:setAnimation(0,"lingqujuanzhou_loop",true)
		effect_spine2:setAnimation(0,"tgl_loop",true)
		pass_dialog:setTouchEndedCallback(function()
			pass_dialog:removeFromParent()
			local _nowInfo = self:getNowMaxInfo()
			if _nowInfo.chapterid ~= _oldInfo.chapterid then
				local _level = LiLianStageChapterData.getChapterInfoById(self._chapterType, _nowInfo.chapterid).levelfloor
				if _level <= gameUser.getLevel() then
					self._bgView:goNext()
				end
			end
		end)
	end, 0.9)
end

function LiLianStageChapterView:create( sParams )
	local obj = LiLianStageChapterView.new(sParams)
    return obj
end

function LiLianStageChapterView:showWinStory( )
	local nowBlock = gameUser.getInstancingId()	
	local isWin = gameUser.getFightingBlockStatu()
	if isWin == 1 and nowBlock > gameUser._storyDisplayedID then ----赢了
		local data = gameData.getDataFromCSV("ExploreInfoList",{instancingid = nowBlock})
		if data and data.winstoryID and data.winstoryID ~= 0 then 			
			layer = StoryLayer:createWithParams({storyId = data.winstoryID})
			self:addChild(layer,5)
			gameUser._storyDisplayedID = nowBlock -----
		end 
	end 
end

return LiLianStageChapterView
