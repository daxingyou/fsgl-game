-- FileName: LiLianStageChapterLayer.lua
-- Author: wangming
-- Date: 2015-11-30
-- Purpose: 历练封装类重构
--[[ TODO List ]]
requires("src/fsgl/layer/LiLian/LiLianStageChapterData.lua")
local mGameUser = gameUser
local mGameData = gameData
local LiLianStageChapterLayer = class("LiLianStageChapterLayer", function()
    return XTHD.createBasePageLayer( {
        isShadow = false, 
		ZOrder = 3,
		isCreateBg = false,
    } )
end )

local Linepos = {
					{"242,256","226,267","210,280","198,295","189,314","186,334"},
					{"336,153","317,162","300,175","288,190","276,208"},
					{"458,220","440,205","423,194","405,185"},
					{"507,360","500,341","495,321","489,302","484,282"},
					{"640,309","622,324","605,337","593,351","577,364"},
					{"720.172","710,189","701,207","694,227","684,245","676,263"},
					{"872,194","853,185","834,175","817,165","799,154","778,153"},
					{"881,383","866,370","861,350","869,331","880,317","883,299","886,279","884,258","880,239","879,214"},
				}


function LiLianStageChapterLayer:onCleanup()
    musicManager.playMusic(XTHD.resource.music.music_bgm_main )
    if self._callBack then
        self._callBack()
    end
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK })
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TASKLIST })
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT, data = { ["name"] = "equip" } })
    XTHD.removeEventListener("EVENT_LEVEUP")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("res/image/plugin/stageChapter/shui1.plist")
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/plugin/stageChapter/shui1.png")
    textureCache:removeTextureForKey("res/image/plugin/stageChapter/starbox_di.png")
    textureCache:removeTextureForKey("res/image/plugin/stageChapter/yun01.png")
    textureCache:removeTextureForKey("res/image/plugin/stageChapter/yun02.png")
    helper.collectMemory()
end

function LiLianStageChapterLayer:create(sParams)
    local layer = LiLianStageChapterLayer.new(sParams)
    return layer
end

function LiLianStageChapterLayer:ctor(sParams)
    self._isChangeChapter = false
    --------是否完成了章节切换

    self._lastMusic = musicManager._lastMusicPath
    local _params = sParams or { }
    self._callBack = _params.callBack
    self._chapter_type = _params.chapter_type or ChapterType.Normal
    self._target_instancingid = tonumber(_params.target_instancingid)
    self._parent = sParams.parent

    if self._target_instancingid == 0 then
        self._target_instancingid = nil
    end
    self._select_reward_data = { prizecount = 1 }
    self:freshMaxInfo(true)

    self:initUI()

    XTHD.addEventListener( {
        name = "EVENT_LEVEUP",
        callback = function(event)
            self:refreshEvent()
            YinDaoMarg:getInstance():doNextGuide()
        end
    } )


    ---------下列代码是测试新功能开启的，暂时不要删
    --    local inputBox = ccui.EditBox:create(cc.size(400,40), "res/image/chatroom/chatroom_input_back.png")
    --    inputBox:setFontSize(22)
    --    inputBox:setFontName("Arial")
    --    inputBox:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2 + 50)
    --    inputBox:setPlaceholderFontColor(cc.c3b(255,255,255))
    --    inputBox:setAnchorPoint(0.5,0.5)
    --    self:addChild(inputBox)
    -- local _button = XTHDPushButton:createWithParams({
    -- 	normalFile = "res/image/common/btn/btn_equip_normal.png",
    -- 	selectedFile = "res/image/common/btn/btn_equip_selected.png",
    -- })
    -- self:addChild(_button)
    -- _button:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    -- _button:setTouchEndedCallback(function( )
    -- 	local data = inputBox:getText()
    -- 	if not string.find(data,"|") then
    -- 		DBUpdateFunc:UpdateProperty("userdata",400,tonumber(data),nil,false)
    -- 	else
    -- 		data = string.split(data,"|")
    -- 		gameUser.setInstancingId(tonumber(data[2]))
    -- 	end
    -- end)
end

-- 最大关卡数据记录处理
function LiLianStageChapterLayer:freshMaxInfo(isInit)
    self.iseffect = true
    if isInit then
        -- gameUser.setInstancingId(225)

        local _chapterInfo = mGameData.getDataFromCSV("EliteCopyList", { ["instancingid"] = gameUser.getEliteInstancingId() + 1 })
        if not _chapterInfo or not _chapterInfo.chapterid then
            _chapterInfo = mGameData.getDataFromCSV("EliteCopyList", { ["instancingid"] = gameUser.getEliteInstancingId() })
        end
        gameUser.setPassEliteChapterStatus(_chapterInfo.chapterid or 1)
        _chapterInfo = mGameData.getDataFromCSV("ExploreInfoList", { ["instancingid"] = gameUser.getInstancingId() + 1 })
        if not _chapterInfo or not _chapterInfo.chapterid then
            _chapterInfo = mGameData.getDataFromCSV("ExploreInfoList", { ["instancingid"] = gameUser.getInstancingId() })
        end
        gameUser.setPassNormalChapterStatus(_chapterInfo.chapterid or 1)
    end

    local _instancingId
    if self._chapter_type == ChapterType.Normal then
        _instancingId = gameUser.getInstancingId()
        self._chapter_reward_data = mGameUser.getCopiesReward()
    else
        _instancingId = gameUser.getEliteInstancingId()
        self._chapter_reward_data = mGameUser.getEliteCopiesReward()
    end
    if _instancingId == 0 then
        self._maxInfo = self:getStageInfoById(1)
    else
        self._maxInfo = self:getStageInfoById(_instancingId)
    end
    self._nextInfo = self:getStageInfoById(_instancingId + 1)
    if self._nextInfo and not next(self._nextInfo) then
        self._nextInfo = self._maxInfo
    end
    self._totalChapterPage = self._nextInfo.chapterid
    local pNum = tonumber(self._nextInfo.instancingid)
    self._target_instancingid = self._target_instancingid or pNum
    self._target_instancingid = self._target_instancingid > pNum and pNum or self._target_instancingid
end

function LiLianStageChapterLayer:onEnter()
    -- musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_selectchapter,true)
    -- -------引导，防止王裔的狂点
	musicManager.playMusic(XTHD.resource.music.effect_lilian_bgm )
    self._clickCover = YinDaoMarg:getInstance():getACover(self)
    if self.pager then
        performWithDelay(self, function()
            self:showWinStory()
            self:showWhyGetIngot1000()
            self:addGuide()
            if self._clickCover then
                self._clickCover:removeFromParent()
                self._clickCover = nil
            end
        end , 0.05)
    end
    if gameUser.getZhuanpanCount() > 0 and self._turnRedDot then
        self._turnRedDot:setVisible(true)
    end
end

function LiLianStageChapterLayer:onExit()
    if LayerManager.getBaseLayer() then
        LayerManager.getBaseLayer():addGuide()
        performWithDelay(LayerManager.getBaseLayer(), function()
            YinDaoMarg:getInstance():doNextGuide()
        end , 0.01)
    end
    YinDaoMarg:getInstance():removeCover(self)
    self._arrow_sp = nil
end

function LiLianStageChapterLayer:initUI()
	self._bgImgPath = { "", 1, ".jpg" }
    self._topBar = self:getChildByName("TopBarLayer1")	

	self._topBar:getChildByName("T_bg"):setVisible(false)

	self._topBar:getChildByName("_physicalBg"):setVisible(false)

	self._topBar:getChildByName("_goldBg"):setVisible(false)

	self._topBar:getChildByName("_EmeraldBg"):setVisible(false)

	self._topBar:getChildByName("_labTimer"):setVisible(false)

	self._topBar:getChildByName("_IngotBg"):setVisible(false)

	local btn_back = self._topBar:getChildByName("topBarBackBtn")
	btn_back:setStateNormal("res/image/plugin/stageChapter/btn_back_1.png")
	btn_back:setStateSelected("res/image/plugin/stageChapter/btn_back_2.png")
	btn_back:setPositionX(btn_back:getContentSize().width + 10)
	--_IngotBg

    self._bgImgPath = { "", 1, ".jpg" }
    self._topBar = self:getChildByName("TopBarLayer1")
    -- userinfo
    -- 章节名称背景板
    local title_bg_path
    if self._chapter_type == ChapterType.ELite then
        title_bg_path = "res/image/plugin/stageChapter/title_bg_elite.png"
    else
        title_bg_path = "res/image/plugin/stageChapter/title_bg_normal.png"
    end
    local title_bg = XTHD.createSprite(title_bg_path)
    title_bg:setAnchorPoint(0, 1)
    title_bg:setPosition(11,  title_bg:getContentSize().height + 30)
    self:addChild(title_bg, 2)
    self._title_bg = title_bg
    -- 章节名字文本
    local title_current = XTHD.createSprite()
    title_current:setAnchorPoint(cc.p(0, 0.5))
    title_current:setPosition(cc.p(65, title_bg:getContentSize().height / 2 - 6))
    title_bg:addChild(title_current)
    self._title_current = title_current

    -- 章节奖励说明
    local Award = XTHD.createSprite()
    Award:setAnchorPoint(cc.p(0.5, 0.5))
    Award:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height - Award:getContentSize().height - 40))
    self:addChild(Award,2)
    self._Award = Award
    -- 宝箱
    local box_di = cc.Sprite:create("res/image/plugin/stageChapter/starbox_di.png")
    box_di:setAnchorPoint(0, 0)
    box_di:setPosition(0, 2)
    self:addChild(box_di, 1)
    local box_btn = XTHDImage:create("res/image/plugin/stageChapter/star_reward.png")
    box_btn:setOpacity(100)
    box_btn:setPosition(self:getContentSize().width - box_btn:getContentSize().width *0.5 - 10, box_di:getContentSize().height * 0.5 + 10)
    box_di:addChild(box_btn, 1)

    -- 转盘按钮
    local turn_btn = XTHD.createButton( {
        normalFile = "res/image/plugin/stageChapter/turn_levelUp_normal.png",
        selectedFile = "res/image/plugin/stageChapter/turn_levelUp_selected.png",
        needSwallow = false,
        anchor = cc.p(1,1),
        pos = cc.p(self:getContentSize().width - 20,self:getContentSize().height - 60),
        endCallback = function()
            YinDaoMarg:getInstance():guideTouchEnd()

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
                local pop = requires("src/fsgl/layer/LiLian/LiLianlevelUpLuckTurnPop.lua"):create( { data = _turnData, _callback = refresh, parent = self })
                LayerManager.addLayout(pop, { noHide = true })
            end )
        end,
    } )
    turn_btn:setVisible(false)
    self:addChild(turn_btn, 1)
    self._turnBtn = turn_btn
    local redDot = XTHDImage:create("res/image/common/heroList_redPoint.png")
    turn_btn:addChild(redDot)
    redDot:setPosition(turn_btn:getBoundingBox().width - 5, turn_btn:getBoundingBox().height - 20)
    redDot:setVisible(false)
    if gameUser.getZhuanpanCount() > 0 then
        redDot:setVisible(true)
    end
    self._turnRedDot = redDot
    if gameUser.getLevel() < 40 then
        turn_btn:setVisible(true)
    else
        if gameUser.getZhuanpanCount() > 0 then
            turn_btn:setVisible(true)
        end
    end
    self._turnplateBtn = turn_btn


    self.max_star_txt = getCommonWhiteBMFontLabel(0)
    self.max_star_txt:setAnchorPoint(1, 1)
    self.max_star_txt:setPosition(box_btn:getContentSize().width * 0.5, 5)
    box_btn:addChild(self.max_star_txt)
    local star_bg1 = cc.Sprite:create("res/image/plugin/stageChapter/starbox_star3.png")
    star_bg1:setAnchorPoint(0, 1)
    star_bg1:setPosition(self.max_star_txt:getPositionX(), self.max_star_txt:getPositionY())
    box_btn:addChild(star_bg1)

    local effect_spine = sp.SkeletonAnimation:create("res/spine/effect/qiandai/qiandai.json", "res/spine/effect/qiandai/qiandai.atlas", 1.0)
    effect_spine:setPosition(box_btn:getPositionX(), box_btn:getPositionY())
    effect_spine:setAnimation(0, "xx1", true)
    box_di:addChild(effect_spine, box_btn:getLocalZOrder())
    self._box_effect_spine = effect_spine

    -- 星星数背景
    local star_bg = cc.Sprite:create("res/image/plugin/stageChapter/starbox_star.png")
    star_bg:setPosition(box_btn:getPositionX() - box_btn:getContentSize().width - 20, box_btn:getPositionY() + 2)
    box_di:addChild(star_bg, box_btn:getLocalZOrder())

    self._current_page_star_txt = getCommonWhiteBMFontLabel(0)
    self._current_page_star_txt:setPosition(star_bg:getContentSize().width / 2, -12)
    star_bg:addChild(self._current_page_star_txt)
    box_btn:setTouchEndedCallback( function()
        ----引导
        YinDaoMarg:getInstance():guideTouchEnd()
        ------------------------------
        musicManager.playEffect(XTHD.resource.music.effect_btn_common)
        local _chapter_reward = self:getChapterInfoById(self.pager:getCurrentIndex())
        self._select_reward_data["chapter_reward"] = _chapter_reward
        self:addChild(requires("src/fsgl/layer/LiLian/LiLianReceiveBoxReward.lua"):create(self._select_reward_data), 3)
    end )
    self._guideBoxBtn = box_btn

     -- 两个箭头
    local _leftBtn = XTHDImage:create("res/image/plugin/stageChapter/btn_left_arrow2.png")
    _leftBtn:setAnchorPoint(0, 0.5)
    _leftBtn:setPosition(36, self:getContentSize().height / 2)
    self:addChild(_leftBtn, 2)

    local _rightBtn = XTHDImage:create("res/image/plugin/stageChapter/btn_right_arrow2.png")
    _rightBtn:setAnchorPoint(1, 0.5)

    _rightBtn:setPosition(self:getContentSize().width - 80, _leftBtn:getPositionY())
    self:addChild(_rightBtn, 2)

    local leftMove_1 = cc.MoveBy:create(0.5, cc.p(-10, 0))
    local leftMove_2 = cc.MoveBy:create(0.5, cc.p(10, 0))
    local rightMove_1 = cc.MoveBy:create(0.5, cc.p(10, 0))
    local rightMove_2 = cc.MoveBy:create(0.5, cc.p(-10, 0))

    _leftBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(leftMove_1, leftMove_2)))
    _rightBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(rightMove_1, rightMove_2)))

    _leftBtn:setTouchEndedCallback( function()
		self:SwichOtherSection()
        self.pager:scrollToLast(0)
    end )
    _rightBtn:setTouchEndedCallback( function()
--		local index = self.pager:getCurrentIndex() + 1
--        local _data = self:getChapterInfoById(index)
--        self._open_new_chapter_level = _data.levelfloor
--        if index == self.totalPage and self._open_new_chapter_level > mGameUser:getLevel() then
--            local confirmDialog = XTHDConfirmDialog:createWithParams({
--                msg = self._open_new_chapter_level.."级开启新的章节！",
--                leftVisible = false,
--            })
--            confirmDialog:setCallbackRight(function ()
--                confirmDialog:removeFromParent()
--            end)
--            self:addChild(confirmDialog)
--            return
--        end
		self:SwichOtherSection()
        self.pager:scrollToNext(0)
    end )

   -- 普通  精英
    local normal_btn = XTHDPushButton:createWithParams({
		normalFile = "res/image/plugin/stageChapter/btn_normal_normal_up.png",
		selectedFile = "res/image/plugin/stageChapter/btn_normal_normal_down.png",
	})
    self.normal_btn = normal_btn
    normal_btn:setAnchorPoint(cc.p(1, 0))
    -- local name_normal = ZCLabel:create("普通",26,"res/fonts/def.ttf")
    -- name_normal:enableOutline(cc.c4b(45,13,103,255),2)
    -- name_normal:setPosition(normal_btn:getContentSize().width/2,normal_btn:getContentSize().height/2)
    -- normal_btn:addChild(name_normal)
    -- normal_btn:setPosition(self:getContentSize().width, 150)
    normal_btn:setPosition(self:getContentSize().width * 0.5 - 10 - normal_btn:getContentSize().width*0.5, 8)

    local selected_box = cc.Sprite:create("res/image/plugin/stageChapter/btn_chapter_box.png")
    selected_box:setPosition(normal_btn:getContentSize().width / 2, normal_btn:getContentSize().height / 2)
    selected_box:setVisible(false)
    -- local name_selected = XTHDLabel:create("普通",26,"res/fonts/def.ttf")
    -- name_selected:enableOutline(cc.c4b(45,13,103,255),2)
    -- name_selected:setPosition(selected_box:getContentSize().width/2,selected_box:getContentSize().height/2)
    -- selected_box:addChild(name_selected)
    normal_btn.selected_box = selected_box
    normal_btn:addChild(selected_box)

    normal_btn.source_type = ChapterType.Normal
    normal_btn:setTouchEndedCallback( function()
        if self._chapter_type == ChapterType.Normal or self._swith_action then
            return
        end
        musicManager.playEffect(XTHD.resource.music.effect_btn_common)
        self:SwitchChapterTypeAndRefreshData(normal_btn, true)
    end )

   local elite_btn = XTHDPushButton:createWithParams({
		normalFile = "res/image/plugin/stageChapter/btn_elite_normal_up.png",
		selectedFile = "res/image/plugin/stageChapter/btn_elite_normal_down.png",
	})
    self.elite_btn = elite_btn
    elite_btn:setAnchorPoint(cc.p(1, 0))
    -- elite_btn:setPosition(normal_btn:getPositionX(),normal_btn:getPositionY()-elite_btn:getContentSize().height/2-20)
    elite_btn:setPosition(normal_btn:getPositionX() + normal_btn:getContentSize().width  + 10, normal_btn:getPositionY())

    -- local elite_normal = XTHDLabel:create("精英",26,"res/fonts/def.ttf")
    -- elite_normal:enableOutline(cc.c4b(45,13,103,255),2)
    -- elite_normal:setPosition(elite_btn:getContentSize().width/2,elite_btn:getContentSize().height/2)
    -- elite_btn:addChild(elite_normal)

--    local selected_box_2 = cc.Sprite:create("res/image/plugin/stageChapter/btn_chapter_box.png")
--    selected_box_2:setPosition(elite_btn:getContentSize().width / 2, elite_btn:getContentSize().height / 2)
--    selected_box_2:setVisible(false)
--    elite_btn.selected_box = selected_box_2
--    elite_btn:addChild(selected_box_2)
    -- local elite_selected = XTHDLabel:create("精英",26,"res/fonts/def.ttf")
    -- elite_selected:enableOutline(cc.c4b(45,13,103,255),2)
    -- elite_selected:setPosition(selected_box_2:getContentSize().width/2,selected_box_2:getContentSize().height/2)
    -- selected_box_2:addChild(elite_selected)

    elite_btn.source_type = ChapterType.ELite
    elite_btn:setTouchEndedCallback( function()
        YinDaoMarg:getInstance():guideTouchEnd()

        if self._chapter_type == ChapterType.ELite or self._swith_action then
            return
        end
        musicManager.playEffect(XTHD.resource.music.effect_btn_common)

        local _elite_open_data = gameData.getDataFromCSV("FunctionInfoList", { ["id"] = 19 })
        if tonumber(_elite_open_data["unlocktype"]) == 2 then
            if gameUser.getInstancingId() < tonumber(_elite_open_data["unlockparam"]) then
                XTHDTOAST(LANGUAGE_KEY_NOTOPEN)
                ------"精英副本暂未开启!")
                return
            end
        end
        if tonumber(_elite_open_data["unlocktype"]) == 1 then
            if gameUser.getLevel() < tonumber(_elite_open_data["unlockparam"]) then
                XTHDTOAST(LANGUAGE_TIPS_OPEN_ELITE(_elite_open_data["unlockparam"]))
                ------"精英副本暂未开启!")
                return
            end
        end
        self:SwitchChapterTypeAndRefreshData(elite_btn, true)
    end )

     -- 噩梦副本
    local diff_btn = XTHDPushButton:createWithParams({
		normalFile = "res/image/plugin/stageChapter/btn_diffculty_normal_up.png",
		selectedFile = "res/image/plugin/stageChapter/btn_diffculty_normal_down.png",
	})
    self.diff_btn = diff_btn
    diff_btn:setAnchorPoint(cc.p(1, 0))
    -- diff_btn:setPosition(normal_btn:getPositionX(), elite_btn:getPositionY() - elite_btn:getContentSize().height/2-20)
    diff_btn:setPosition(elite_btn:getPositionX() + diff_btn:getContentSize().width  + 10, normal_btn:getPositionY())

    diff_btn:setTouchEndedCallback( function()
        LayerManager.addShieldLayout(nil, 1)
        XTHD.createDiffcultyCopy(self)
    end )
    -- local diff_normal = XTHDLabel:create("噩梦",26,"res/fonts/def.ttf")
    -- diff_normal:enableOutline(cc.c4b(45,13,103,255),2)
    -- diff_normal:setPosition(diff_btn:getContentSize().width/2,diff_btn:getContentSize().height/2)
    -- diff_btn:addChild(diff_normal)

    local _elite_open_data = mGameData.getDataFromCSV("FunctionInfoList", { ["id"] = 19 })
    if tonumber(_elite_open_data["unlocktype"]) == 2 then
        if mGameUser.getInstancingId() < tonumber(_elite_open_data["unlockparam"]) then
            elite_btn:setVisible(false)
            normal_btn:setVisible(false)
        end
    end


    -- normal_btn:setScale(0.7)
    -- elite_btn:setScale(0.7)
    -- diff_btn:setScale(0.7)
    self:addChild(normal_btn, 1)
    self:addChild(elite_btn, 1)
    self:addChild(diff_btn, 1)
    self._eliteBtn = elite_btn

    -- 关卡switch_btn	默认状态是普通副本，如果要进入普通副本，则不需手动设置状态，如果是精英副本，则需要
    if self._chapter_type == ChapterType.ELite then
        self:SwitchChapterTypeAndRefreshData(elite_btn)
    else
        self:SwitchChapterTypeAndRefreshData(normal_btn)
    end
end

function LiLianStageChapterLayer:refreshEvent()
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
    local isPassChapter = self:isPassChapter()

    self:reloadData(self._chapter_type,isPassChapter)
    self:ConstructBoxData()

    local elite_clock = isTheFunctionAvailable(19)
    if elite_clock == true then
        self.normal_btn:setVisible(true)
        self.elite_btn:setVisible(true)
    end
    if self.pager then
        performWithDelay(self, function()
            self:showWinStory()
            self:addGuide()
            if self._clickCover then
                self._clickCover:removeFromParent()
                self._clickCover = nil
            end
        end , 0.05)
    end
end

-- 通关的判断以及处理
function LiLianStageChapterLayer:isPassChapter()
    local ispass = false

    local old_target_chapter, now_target_chapter
    if self._chapter_type == ChapterType.Normal then
        old_target_chapter = self:getStageInfoById(gameUser.getInstancingId())
        now_target_chapter = self:getStageInfoById(gameUser.getInstancingId() + 1)
    else
        old_target_chapter = self:getStageInfoById(gameUser.getEliteInstancingId())
        now_target_chapter = self:getStageInfoById(gameUser.getEliteInstancingId() + 1)
    end
    if now_target_chapter and next(now_target_chapter) == nil then
        now_target_chapter = old_target_chapter
    end
    now_target_chapter = now_target_chapter or old_target_chapter

    local _num1 = tonumber(self._maxInfo.instancingid) or 0
    local _num2 = tonumber(old_target_chapter.instancingid) or 1
    if _num2 == 1 or _num1 ~= _num2 then
        self._target_instancingid = now_target_chapter.instancingid
    end

    if now_target_chapter.chapterid ~= old_target_chapter.chapterid then
        local function isPassEffect()
            local pass_dialog = XTHDDialog:create()
            pass_dialog:setSwallowTouches(true)
            pass_dialog:setColor(cc.c3b(0, 0, 0))
            pass_dialog:setOpacity(100)
            local effect_light = cc.Sprite:create("res/image/exchange/reward/reward_light_circle.png")
            effect_light:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 20)))
            effect_light:setPosition(pass_dialog:getContentSize().width / 2, pass_dialog:getContentSize().height / 2 + 70)

            -- local effect_spine = sp.SkeletonAnimation:create( "res/spine/effect/chapter_pass/guoguan.json", "res/spine/effect/chapter_pass/guoguan.atlas",1.0);
            local effect_spine = sp.SkeletonAnimation:create("res/spine/effect/chapter_pass/lingqujuanzhou.json", "res/spine/effect/chapter_pass/lingqujuanzhou.atlas", 1.0);
            effect_spine:setPosition(pass_dialog:getContentSize().width / 2, pass_dialog:getContentSize().height / 2)
            -- wenzi
            local effect_spine2 = sp.SkeletonAnimation:create("res/spine/effect/chapter_pass/lingquziti.json", "res/spine/effect/chapter_pass/lingquziti.atlas", 1.0);
            effect_spine2:setPosition(effect_spine:getContentSize().width * 0.5, effect_spine:getContentSize().height)
            effect_spine:addChild(effect_spine2)

            local chapter_name_sp = XTHD.resource.getNormalChapterNameSpFrame(old_target_chapter.chapterid)
            if not chapter_name_sp then
                return
            end
            local pStringName = self:getChapterInfoById(old_target_chapter.chapterid).name
            local pStringLevel = self:getChapterInfoById(now_target_chapter.chapterid).levelfloor

            local label_name = XTHDLabel:createWithParams( {
                text = pStringName,
                anchor = cc.p(0.5,0.5),
                color = cc.c3b(70,34,34),
                size = 20,
                pos = cc.p(effect_spine:getContentSize().width * 0.5 - 30,effect_spine:getContentSize().height * 0.5)
            } )
            effect_spine:addChild(label_name)
            -- label_name:runAction(cc.Sequence:create(cc.FadeOut:create(0.205),cc.FadeIn:create(0.205)))

            local label_pass = XTHDLabel:createWithParams( {
                text = LANGUAGE_FORMAT_TIPS49,
                size = 20,
                anchor = cc.p(0,0.5),
                color = cc.c3b(187,27,10),
                pos = cc.p(effect_spine:getContentSize().width * 0.5 - 30 + label_name:getContentSize().width * 0.5 + 10,effect_spine:getContentSize().height * 0.5)
            } )
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

            effect_spine:runAction(cc.Sequence:create(cc.FadeOut:create(0.205), cc.FadeIn:create(0.205)))
            effect_spine:setAnimation(0, "lingqujuanzhou", false)
            effect_spine2:setAnimation(0, "tgl", false)
            pass_dialog:addChild(effect_light)
            pass_dialog:addChild(effect_spine)
            self:addChild(pass_dialog, 4)
            performWithDelay(pass_dialog, function()
                effect_spine:setAnimation(0, "lingqujuanzhou_loop", true)
                effect_spine2:setAnimation(0, "tgl_loop", true)
                pass_dialog:setTouchEndedCallback( function()
                    pass_dialog:removeFromParent()
                    if self._open_new_chapter_level <= mGameUser.getLevel() then
                        LayerManager.addShieldLayout(nil, 0.5)
                        -----加个屏蔽层
                        self.pager:scrollToPage(now_target_chapter.chapterid)
                        self._isChangeChapter = true
                    end
                    if gameUser.getInstancingId() == 27 then
                        local popLayer = requires("src/fsgl/layer/ConstraintPoplayer/QiXinTanPopLayer.lua"):create()
                        cc.Director:getInstance():getRunningScene():addChild(popLayer)
                    end
					XTHD.FristChongZhiPopLayer(self)
                end )
            end , 0.9)
        end

        local _data = self:getChapterInfoById(now_target_chapter.chapterid)
        if self._chapter_type == ChapterType.ELite then
            local _num1 = tonumber(now_target_chapter.chapterid) or 0
            local _num2 = tonumber(gameUser.bIsPassEliteChapter()) or _num1
            if _num2 < _num1 then
                ispass = true
                isPassEffect()
                gameUser.setPassEliteChapterStatus(now_target_chapter.chapterid)
            end
        else
            local _num1 = tonumber(now_target_chapter.chapterid) or 0
            local _num2 = tonumber(gameUser.bIsPassNormalChapter()) or _num1
            if _num2 < _num1 then
                ispass = true
                isPassEffect()
                gameUser.setPassNormalChapterStatus(now_target_chapter.chapterid)
            end
        end
    end
    return ispass
end

-- 切换完按钮的状态之后，切换副本的数据，然后刷新数据,force参数标示强力执行改函数，
function LiLianStageChapterLayer:SwitchChapterTypeAndRefreshData(sender, bol_animation)
    -- self._nowPage = nil
    if self._last_sender then
--        self._last_sender.selected_box:setVisible(false)
    end
--    self._arrow_sp = nil
--    sender.selected_box:setVisible(true)
    self._last_sender = sender

    local size = self:getContentSize()


    local newer_titlebg_imgPath

    if bol_animation then
        local _left_yun = XTHDImage:create("res/image/plugin/stageChapter/yun_left.png")
--        _left_yun:setScale(2)
		_left_yun:setContentSize(size.width/3*2,size.height)
        _left_yun:setAnchorPoint(1, 0.5)
        _left_yun:setPosition(0, size.height / 2)

        local _right_yun = XTHDImage:create("res/image/plugin/stageChapter/yun_right.png")
--        _right_yun:setScale(_left_yun:getScaleX())
		_right_yun:setContentSize(size.width/3*2,size.height)
        _right_yun:setAnchorPoint(0, 0.5)
        _right_yun:setPosition(size.width, size.height / 2)
        self:addChild(_left_yun, 3)
        self:addChild(_right_yun, 3)

        self._swith_action = true
        _left_yun:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.3, cc.p(_right_yun:getBoundingBox().width, _left_yun:getPositionY())),
        cc.CallFunc:create( function()
            -- 切换副本，标题背景图也需要替换
            if sender.source_type == ChapterType.ELite then
                self._title_bg:setTexture("res/image/plugin/stageChapter/title_bg_elite.png")
            else
                self._title_bg:setTexture("res/image/plugin/stageChapter/title_bg_normal.png")
            end
            self._target_instancingid = nil
            self:reloadData(sender.source_type)
            self._swith_action = false
        end ),
        cc.DelayTime:create(0.3),
        cc.MoveTo:create(0.3, cc.p(0, _left_yun:getPositionY())),
        cc.RemoveSelf:create(true)
        ))
        _right_yun:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.3, cc.p(size.width - _right_yun:getBoundingBox().width, _right_yun:getPositionY())),
        cc.DelayTime:create(0.3),
        cc.MoveTo:create(0.3, cc.p(size.width, _left_yun:getPositionY())),
        cc.RemoveSelf:create(true)
        ))
    else
        self:initPager(false,true)
    end
end

-- 选择别的章节特效
function LiLianStageChapterLayer:SwichOtherSection()
	local size = self:getContentSize()
	local _left_yun = XTHDImage:create("res/image/plugin/stageChapter/yun_left.png")
	_left_yun:setContentSize(size.width / 3 * 2, size.height)
	_left_yun:setAnchorPoint(1, 0.5)
	_left_yun:setPosition(0, size.height / 2)

	local _right_yun = XTHDImage:create("res/image/plugin/stageChapter/yun_right.png")
	_right_yun:setContentSize(size.width / 3 * 2, size.height)
	_right_yun:setAnchorPoint(0, 0.5)
	_right_yun:setPosition(size.width, size.height / 2)
	self:addChild(_left_yun, 3)
	self:addChild(_right_yun, 3)

	_left_yun:runAction(cc.Sequence:create(
		cc.MoveTo:create(0.3, cc.p(_right_yun:getBoundingBox().width, _left_yun:getPositionY())),
		cc.DelayTime:create(0.3),
		cc.MoveTo:create(0.3, cc.p(0, _left_yun:getPositionY())),
		cc.RemoveSelf:create(true)
	))
	_right_yun:runAction(cc.Sequence:create(
		cc.MoveTo:create(0.3, cc.p(size.width - _right_yun:getBoundingBox().width, _right_yun:getPositionY())),
		cc.DelayTime:create(0.3),
		cc.MoveTo:create(0.3, cc.p(size.width, _left_yun:getPositionY())),
		cc.RemoveSelf:create(true)
	))
end

function LiLianStageChapterLayer:initPager(switchChapter,switchType)
    local pageIndex = self._nextInfo.chapterid
    self.totalPage = self._totalChapterPage <= 0 and 1 or self._totalChapterPage
    if self.pager == nil then
        local size = self:getContentSize()

        local pager = ccui.PageView:create()
        PageViewPlug.init(pager)
        pager:setContentSize(size.width,size.height)
        pager:setAnchorPoint(0.5, 0.5)
        pager:setPosition(size.width / 2, size.height / 2)
		--pager:setTouchEnabled(false)
        pager:setSaveCache(true)
        self:addChild(pager)
        self.pager = pager
		self.pager:setTouchEnabled(false)

        pager:onLoadListener( function(page, index)
            local pageBg=page:getChildByName("PageBg")
            local psize=page:getContentSize()
            if pageBg==nil then
                local bgImgString = self:getBgImgFile(index)
                pageBg = XTHD.createSprite(bgImgString)
                pageBg:setPosition(size.width * 0.5, size.height * 0.5)
                pageBg:setContentSize(psize.width + 6,psize.height)
                page:addChild(pageBg)
                pageBg:setName("PageBg")
            end
            self:loadCellById(pageBg, index)
        end )

		pager:onSelectedListener( function(page, index)
            local _data = self:getChapterInfoById(index)
            self._open_new_chapter_level = _data.levelfloor
            if index == self.totalPage and self._open_new_chapter_level > mGameUser:getLevel() then
                XTHDTOAST(LANGUAGE_KEY_NEXT_STAGE(self._open_new_chapter_level))
            end
            self:ConstructBoxData(index)
        end )
    end
    local lastPage = self.pager:getCurrentIndex()
    if switchChapter==true and lastPage then
        self.pager:reloadData(lastPage, self.totalPage)
    elseif switchType == true or lastPage==nil then
        self.pager:reloadData(pageIndex, self.totalPage)
    else
        self.pager:updatePageAtIndex(lastPage)
    end
end

function LiLianStageChapterLayer:reloadData(_type,isPassChapter)
    local _typeNow = self._chapter_type
    self._chapter_type = _type
    self:freshMaxInfo()

--    self._arrow_sp = nil

    self:initPager(isPassChapter,_type ~= _typeNow)
    -------引导
    if _type == ChapterType.ELite then
        ------切到精英关卡
        performWithDelay(self, function()
            ------到此处精英与普通的切换动画还没有结束，加一个延迟
            -----引导
            YinDaoMarg:getInstance():doNextGuide()
            -------------------------
        end , 0.4)
    end
end

function LiLianStageChapterLayer:loadCellById(sBgSprite, sID)
    if not sBgSprite then
        return
    end
    local stage_bg = sBgSprite
    stage_bg:removeAllChildren()
    local bsize=stage_bg:getContentSize()
    local idx = tonumber(sID) or 1
    local last_stage_idx, last_stage_pos, last_stage_rect
    local stage_data = { }
    local _my_instancing = 0
    if self._chapter_type == ChapterType.Normal then
        stage_data = mGameData.getDataFromCSV("ExploreInfoList", { chapterid = tostring(idx) })
        _my_instancing = mGameUser.getInstancingId()
    elseif self._chapter_type == ChapterType.ELite then
        stage_data = mGameData.getDataFromCSV("EliteCopyList", { chapterid = tostring(idx) })
        _my_instancing = mGameUser.getEliteInstancingId()
    end
    -- 地图云特效
    if idx == 1 then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("res/image/plugin/stageChapter/shui1.plist", "res/image/plugin/stageChapter/shui1.png")
        local shui = XTHD.createSprite()
        shui:runAction(cc.RepeatForever:create(getAnimationBySpriteFrame("0", 1, 9, 0.15)))
        shui:setPosition(560*(bsize.width/1024), 245*(bsize.height/615))
        stage_bg:addChild(shui)
    end

    local function _getArrSp(...)
        local pArrow_sp = cc.Sprite:create()
        local brust_animation = getAnimation("res/image/plugin/stageChapter/arrow_sp_animal/jt", 1, 6, 1 / 7)
        pArrow_sp:runAction(cc.RepeatForever:create(brust_animation))
        return pArrow_sp
    end
    local function _getArrDi(...)
        local pArrow_di = cc.Sprite:create()
        local brust_animation = getAnimation("res/image/plugin/stageChapter/arrow_di_animal/gkgx", 1, 11, 1 / 10)
        pArrow_di:runAction(cc.RepeatForever:create(brust_animation))
        return pArrow_di
    end
    if stage_data and next(stage_data) ~= nil then
        local pTable = { }
        for index, var in ipairs(stage_data) do
            if var.instancingid <= _my_instancing + 2 then
                local isBoss = false
                local isOpen = true
                local touchsize
                local _diSp
                if var.bossid > 0 then
                    -- boss
                    isBoss = true
                    -- ly3.26
                    _diSp = XTHD.createSprite("res/image/plugin/stageChapter/boss_avator_bg.png")
                    _diSp:setOpacity(0)
                    touchsize = cc.size(140, 140)
                else
                    touchsize = cc.size(100, 100)
                end
                if var.instancingid == _my_instancing + 2 then
                    isOpen = false
                    -- print("index2" .. index)
                    if not isBoss then
                        _diSp = XTHD.createSprite("res/image/plugin/stageChapter/starbox_black" .. index .. ".png")
                    end
                    XTHD.setGray(_diSp, true)
                else
                    if not isBoss then
                        if var.instancingid == _my_instancing + 1 then
                            _diSp = XTHD.createSprite("res/image/plugin/stageChapter/starbox_black" .. index .. ".png")
                        else
                            _diSp =("res/image/plugin/stageChapter/starbox_light" .. index .. ".png")
                        end

                    end
                end

                local stage_icon = XTHD.createButton( {
                    normalNode = _diSp,
                    needSwallow = false,
                    needEnableWhenMoving = true,
                    touchSize = touchsize,
                } )
                table.insert(pTable, stage_icon)

                local _star = 0
                if isBoss then
                    -- ly3.26
                    -- print("bossID:" .. index)
                    -- if var.bossid > 0 then
                    -- 	var.bossid = math.random( 1,6)
                    -- end

                    local imgPath = "res/image/image/plugin/stageChapter/build" .. index .. ".png"
                    if not cc.Director:getInstance():getTextureCache():addImage(imgPath) then
                        imgPath = "res/image/plugin/stageChapter/build1.png"
                    end
					
					imgPath = "res/image/plugin/stageChapter/build1.png"
					local avator_sp = nil
					if var.heroid == nil then
						avator_sp = XTHD.createSprite(imgPath)
						avator_sp:setPosition(stage_icon:getContentSize().width * 0.5, stage_icon:getContentSize().height * 0.5)
					else
						avator_sp = XTHD.createSprite("res/image/plugin/stageChapter/dipan.png")
						avator_sp:setScale(1.3)
						avator_sp:setPosition(stage_icon:getContentSize().width * 0.5,-25)
						local heroherd = cc.Sprite:create("res/image/plugin/stageChapter/heroHead/heroHead_" .. var.heroid .. ".png")
						heroherd:setAnchorPoint(0.5,0)
						heroherd:setScale(0.5)
						heroherd:setPosition(avator_sp:getContentSize().width * 0.5,avator_sp:getContentSize().height)
						avator_sp:addChild(heroherd)
					end
                    stage_icon:addChild(avator_sp)
					
					local sword_sp = nil
					if var.heroid == nil then
						sword_sp = cc.Sprite:create("res/image/plugin/stageChapter/boss_avator_sword.png")
						sword_sp:setPosition(avator_sp:getContentSize().width * 0.5, avator_sp:getContentSize().height * 0.5 - 50)
					else
						sword_sp = cc.Sprite:create("res/image/plugin/stageChapter/boss_avator_sword.png")
						sword_sp:setScale(0.8)
						sword_sp:setPosition(avator_sp:getContentSize().width * 0.5, avator_sp:getContentSize().height * 0.5 + 10)
					end
                    avator_sp:addChild(sword_sp)
                    -- 黑星星
                    for i = 1, 3 do
                        local starbl = cc.Sprite:create("res/image/plugin/stageChapter/star_bl.png")
                        starbl:setPosition(sword_sp:getContentSize().width / 2 +(i - 2) * 28.5, 19)
                        sword_sp:addChild(starbl)
                    end


                    if isOpen == false then
                        XTHD.setGray(avator_sp, true)
                        XTHD.setGray(sword_sp, true)
                    end

                    if self._chapter_type == ChapterType.Normal then
                        _star = tonumber(CopiesData.GetNormalStar(var.instancingid)) or 0
                    elseif self._chapter_type == ChapterType.ELite then
                        _star = tonumber(CopiesData.GetEliteStar(var.instancingid)) or 0
                    end
                    if _star ~= 0 then
                        -- 关卡星级显示以及处理
                        local varInstanceID = tonumber(var.instancingid) or 0
                        local nowInstanceID = tonumber(self._maxInfo.instancingid)
                        for i = 1, _star do
                            local _star_sp
                            if varInstanceID <= _my_instancing and varInstanceID ~= nowInstanceID then
                                _star_sp = cc.Sprite:create("res/spine/effect/copies_star/xin.png")
                            elseif varInstanceID == nowInstanceID then
                                local pB = cc.UserDefault:getInstance():getBoolForKey(KEY_NAME_STAR_EFFECT, false)
                                if pB == true then
                                    _star_sp = sp.SkeletonAnimation:create("res/spine/effect/copies_star/xin.json", "res/spine/effect/copies_star/xin.atlas", 1.0)
                                    _star_sp:setVisible(false)
                                    _star_sp:runAction(cc.Sequence:create(cc.DelayTime:create(0.2 * i),
                                    cc.CallFunc:create( function()
                                        _star_sp:setVisible(true)
                                        _star_sp:setAnimation(0, "animation", false)
                                    end )
                                    ))
                                else
                                    _star_sp = cc.Sprite:create("res/spine/effect/copies_star/xin.png")
                                end
                            end
                            if _star_sp then
                                _star_sp:setPosition(sword_sp:getContentSize().width / 2 +(i - 2) * 28.5, 19)
                                sword_sp:addChild(_star_sp)
                            end
                        end
                        if varInstanceID == _my_instancing then
                            cc.UserDefault:getInstance():setBoolForKey(KEY_NAME_STAR_EFFECT, false)
                        end
                    end
                end
                stage_icon:setTouchEndedCallback( function()
                    if self._open_new_chapter_level > mGameUser:getLevel() then
                        XTHDTOAST(LANGUAGE_KEY_NEXT_STAGE(self._open_new_chapter_level))
                        return
                    end
                    ----引导
                    YinDaoMarg:getInstance():guideTouchEnd()
                    YinDaoMarg:getInstance():releaseGuideLayer()
                    ------
                    -- stage_icon:setScale(1)
                    if self._swith_action == true then
                        return
                    end
                    if isBoss and not isOpen then
                        return
                    end

                    local luaPop, _noHide
                    if isBoss then
                        luaPop = requires("src/fsgl/layer/LiLian/LiLianStageLayer.lua")
                        _noHide = false
                    else
                        luaPop = requires("src/fsgl/layer/LiLian/LiLianStageBoxPopLayer.lua")
                        _noHide = true
                    end

                    local laterBgPath = self:getBgImgFile(var.chapterid)
                    local datas = {
                        data = var,
                        file = laterBgPath,
                        par = self,
                        stageType = self._chapter_type,
                    }
                    LayerManager.addLayout(luaPop:create(datas), { noHide = _noHide })

                    -- if self._chapter_type == ChapterType.ELite then
                    -- 	mGameUser.setEliteFightingBlockID(var.instancingid)
                    -- else
                    -- 	mGameUser.setFightingBlockID(var.instancingid)
                    -- end
                    mGameUser.setFightingBlockStatu(-1)
                end )
                stage_icon:setTouchBeganCallback( function()
                    stage_icon:setScale(0.9)
                end )
                stage_icon:setTouchMovedCallback( function()
                    stage_icon:setScale(0.9)
                end )
                if not isOpen and self.iseffect == true then
                    stage_icon:setVisible(false)
                    stage_icon:setScale(0)
                    stage_icon:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.8 *(tonumber(var.instancingid) - tonumber(_my_instancing))),
                    cc.CallFunc:create( function()
                        stage_icon:setVisible(true)
                    end ),
                    cc.ScaleTo:create(0.15, 1.2),
                    cc.ScaleTo:create(0.04, 0.9),
                    cc.ScaleTo:create(0.02, 1)
                    ))
                    self.iseffect = false
                end

                local _tmp_pos = string.split(var["pos"] or "", '#')
                local pos = cc.p((_tmp_pos[1] or 150)*bsize.width/1024, (_tmp_pos[2] or 150)*bsize.height/615)
                stage_icon:setPosition(pos)

                -- 在到达最后一个点之前，三个连接成贝塞尔曲线，否则到达最后之前，无论有几个都一套连起来
                if last_stage_pos == nil then
                    last_stage_pos = pos
                    -- 每个单元cell的第一个点
                end
                if last_stage_idx == nil then
                    last_stage_idx = index
                else
                    if last_stage_idx < index then
                        local _pos_list = self:getPosListBetweenToPos(last_stage_idx)
                        local imgPth = "res/image/plugin/stageChapter/page_dot_selected.png"
                        if var.instancingid > _my_instancing then
                            imgPth = "res/image/plugin/stageChapter/page_dot_normal.png"
                        end

                        for i = 1, #_pos_list do
                            local domit_sp = cc.Sprite:create(imgPth)
							domit_sp:setScale(0.7)
                            domit_sp:setPosition(_pos_list[i])
                            stage_bg:addChild(domit_sp)
                            if var.instancingid == _my_instancing + 1 then
                                domit_sp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.3 *(#_pos_list - i)), cc.CallFunc:create( function()
                                    domit_sp:initWithFile("res/image/plugin/stageChapter/page_dot_selected.png")
                                end ), cc.DelayTime:create(0.3), cc.CallFunc:create( function()
                                    domit_sp:initWithFile("res/image/plugin/stageChapter/page_dot_normal.png")
                                end ), cc.DelayTime:create(0.3 *(i - 1)))))
                            elseif var.instancingid > _my_instancing then
                                if domit_sp then
                                    domit_sp:setVisible(false)
                                    if var.instancingid < _my_instancing + 3 then
                                        domit_sp:runAction(cc.Sequence:create(
                                        cc.DelayTime:create(0.8 *(tonumber(var.instancingid) - tonumber(_my_instancing))),
                                        cc.CallFunc:create( function()
                                            domit_sp:setVisible(true)
                                        end )
                                        ))
                                    end
                                end
                            end
                        end
                    end
                end
                last_stage_idx = index
                last_stage_pos = pos
                stage_bg:addChild(stage_icon, 2)


                if self._target_instancingid == var.instancingid then
                    local _arrow_sp = _getArrSp()
                    local _tmp = 0
                    if isBoss then
                        -- 小枫要求 删掉这个闪框
                        -- local _arrow_di = _getArrDi()
                        -- _arrow_di:setPosition(stage_icon:getPositionX() + 5, stage_icon:getPositionY())
                        -- stage_bg:addChild(_arrow_di, 1)	
                        _tmp = 5
                    end
                    _arrow_sp:setAnchorPoint(0.5, 0)
                    local _pos = cc.p(stage_icon:getPositionX() + _tmp, stage_icon:getPositionY() + stage_icon:getContentSize().height * 0.5 + 60)
                    _arrow_sp:setPosition(_pos)
                    _arrow_sp:setVisible(false)
                    _arrow_sp:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.6),
                    cc.CallFunc:create( function()
                        _arrow_sp:setVisible(true)
                        ------引导
                        local _guideLayer = YinDaoMarg:getInstance():getCurrentGuideLayer()
                        if _guideLayer then
                            _arrow_sp:setVisible(false)
                        end
                    end ),
                    cc.MoveBy:create(0.3, cc.p(0, -60))
                    ))
                    _arrow_sp:runAction(cc.RepeatForever:create(
                    cc.Sequence:create(cc.MoveBy:create(0.8, cc.p(0, 15)),
                    cc.DelayTime:create(0.1),
                    cc.MoveBy:create(0.8, cc.p(0, -15)),
                    cc.DelayTime:create(0.1))
                    ))
                    self._arrow_sp = _arrow_sp
                    stage_bg:addChild(_arrow_sp, 3)

                    ------引导
                    self:addBlockGuide(stage_icon)
                    if self._isChangeChapter then
                        ------如果是章节切换
                        YinDaoMarg:getInstance():doNextGuide()
                        self._isChangeChapter = false
                    end
                    local _currentArrow = false--self:getBlockArrow()
                    YinDaoMarg:getInstance():onlyCapter1Guide( {
                        -----第一章的引导
                        parent = self,
                        target = stage_icon,
                        needHideNode = _currentArrow
                    } )
                end
            end
        end

        local function pShort(b1, b2)
            return b1:getPositionY() > b2:getPositionY()
        end
        table.sort(pTable, pShort)
        for i = 1, #pTable do
            local pV = pTable[i]
            stage_bg:reorderChild(pV, 2)
        end
        pTable = nil
    end
end

-- 根据 chapterid 取 ChaptersList数据
function LiLianStageChapterLayer:getChapterInfoById(sID)
    if self._chapter_type == ChapterType.Normal then
        return mGameData.getDataFromCSV("CommonStarRewards", { ["chapterid"] = sID })
    else
        return mGameData.getDataFromCSV("EliteStarAward", { ["chapterid"] = sID })
    end
end

-- 根据 instancingid 取 InfoList 数据
function LiLianStageChapterLayer:getStageInfoById(sID)
    if self._chapter_type == ChapterType.Normal then
        return mGameData.getDataFromCSV("ExploreInfoList", { ["instancingid"] = sID })
    else
        return mGameData.getDataFromCSV("EliteCopyList", { ["instancingid"] = sID })
    end
end

-- 刷新关卡信息
function LiLianStageChapterLayer:ConstructBoxData(sPage)
    local pageIndex = sPage or self.pager:getCurrentIndex()
    --    if sPage and self._nowPage == pageIndex then
    --        return
    --    end
    -- self._nowPage = pageIndex
    -- 关卡名字
    local spFrame
    local Award
    if self._chapter_type == ChapterType.Normal then
        spFrame = XTHD.resource.getNormalChapterNameSpFrame(pageIndex)
        Award = string.format("res/image/plugin/StageTiShi/PuTong/putong_%d.png", pageIndex)
        self._Award:setVisible(true)
    else
        spFrame = XTHD.resource.getEliteChapterNameSpFrame(pageIndex)
        if pageIndex <= 10 then
            Award = string.format("res/image/plugin/StageTiShi/JingYing/jingying_%d.png", pageIndex)
            self._Award:setVisible(true)
        else
            self._Award:setVisible(false)
        end
    end
    if spFrame then
        self._title_current:setSpriteFrame(spFrame)
    end
    if Award then
        self._Award:setTexture(Award)
    end

    local _max = self._totalChapterPage
    if gameUser.getInstancingId() ~= 0 then
        local _data = self:getChapterInfoById(self._maxInfo.chapterid + 1)
        if _data and next(_data) then
            if _data.levelfloor > mGameUser.getLevel() then
                _max = _data.chapterid
            end
        end
    end

    -- 此处处理宝箱的状态
    local already_getTime = 0
    if self._chapter_reward_data[pageIndex] then
        if self._chapter_type == ChapterType.Normal then
            already_getTime = self._chapter_reward_data[pageIndex]["normal_times"] or ""
        elseif self._chapter_type == ChapterType.ELite then
            already_getTime = self._chapter_reward_data[pageIndex]["elite_times"] or ""
        end
    end

    -- 本章节总星数
    local _chapter_data = self:getChapterInfoById(pageIndex)
    if _chapter_data then
        self._select_reward_data["totalstar"] = _chapter_data.totalstar
    else
        self._select_reward_data["totalstar"] = 18
    end

    -- 当前已获得的星数
    local current_page_star = 0
    local _bl_enable_to_receive = 0
    -- 0标示不满足领取条件

    if already_getTime ~= "" then
        _bl_enable_to_receive = 2
        current_page_star = self._select_reward_data["totalstar"]
    else
        if self._chapter_type == ChapterType.Normal then
            local _chapter_data = mGameData.getDataFromCSV("ExploreInfoList", { ["chapterid"] = pageIndex })
            -- ["instacingid"]
            for i = 1, #_chapter_data do
                local _star_ = CopiesData.GetNormalStar(_chapter_data[i]["instancingid"]) or 0
                current_page_star = current_page_star + _star_
            end
        elseif self._chapter_type == ChapterType.ELite then
            local _chapter_data = mGameData.getDataFromCSV("EliteCopyList", { ["chapterid"] = pageIndex })
            -- ["instacingid"]
            for i = 1, #_chapter_data do
                local _star_ = CopiesData.GetEliteStar(_chapter_data[i]["instancingid"]) or 0
                current_page_star = current_page_star + _star_
            end
        end
        if current_page_star < self._select_reward_data["totalstar"] then
            _bl_enable_to_receive = 0
        else
            _bl_enable_to_receive = 1
        end
    end

    self._select_reward_data["get_time"] = already_getTime
    self._select_reward_data["getstar"] = current_page_star
    self._select_reward_data["chapterid"] = pageIndex
    self._select_reward_data["instancint_type"] = self._chapter_type
    if _bl_enable_to_receive == 1 then
        -- 播放宝箱特效
        self._box_effect_spine:setAnimation(0, "xx2", true)
    elseif _bl_enable_to_receive == 2 then
        self._box_effect_spine:setAnimation(0, "xx3", true)
    else
        self._box_effect_spine:setAnimation(0, "xx1", true)
    end
    self._starCanGet = _bl_enable_to_receive

    self._current_page_star_txt:runAction(cc.Sequence:create(
    cc.FadeOut:create(0.205),
    cc.CallFunc:create( function()
        current_page_star = current_page_star or 0
        self._select_reward_data["totalstar"] = self._select_reward_data["totalstar"] or 0
        self._current_page_star_txt:setString(current_page_star .. "/" .. self._select_reward_data["totalstar"])
    end ),
    cc.FadeIn:create(0.205)
    ))
    self.max_star_txt:runAction(cc.Sequence:create(
    cc.FadeOut:create(0.205),
    cc.CallFunc:create( function()
        self.max_star_txt:setString(self._select_reward_data["totalstar"])
    end ),
    cc.FadeIn:create(0.205)
    ))
end

--[[ 资源处理 ]]
function LiLianStageChapterLayer:getBgImgFile(index, sType)
    local _type = sType or self._chapter_type
    if _type == ChapterType.ELite then
        self._bgImgPath[1] = "res/image/plugin/stageChapter/pvrmaps/elite_chapter_bg_"
		self._bgImgPath[2] = index > 25 and 25 or index
    else
        self._bgImgPath[1] = "res/image/plugin/stageChapter/pvrmaps/chapter_bg_"
		self._bgImgPath[2] = 1
	end
    --self._bgImgPath[2] = index > 25 and 25 or index
    local bgImgString = table.concat(self._bgImgPath)
    return bgImgString
end

-- 根据一条贝塞尔曲线，获取线上的若干点
function LiLianStageChapterLayer:getPosListBetweenToPos(index)
    --    local _pos_list = { }
--    local distance_ = getDistance(pos1, pos2)
--    local _pos_count = math.floor(distance_ / 30)
--    for i = 1, _pos_count - 1 do
--        _pos_list[#_pos_list + 1] = cc.p(pos1.x +((pos2.x + (i -1)*10) - pos1.x) / _pos_count * i  + (i - 1) - 30, pos1.y +(pos2.y - pos1.y) / _pos_count * i)
--    end
	local _pos_list = { }
	for i = 1,#Linepos[index] do
		local data = string.split(Linepos[index][i],",")
		_pos_list[#_pos_list + 1] = cc.p(data[1],data[2])
	end
    return _pos_list
end

function LiLianStageChapterLayer:showWinStory()
    local nowBlock = gameUser.getInstancingId()
    local isWin = gameUser.getFightingBlockStatu()
    if isWin == 1 and nowBlock > gameUser._storyDisplayedID then
        ----赢了
        local data = gameData.getDataFromCSV("ExploreInfoList", { instancingid = nowBlock })
        if data and data.winstoryID and data.winstoryID ~= 0 then
            layer = StoryLayer:createWithParams( { storyId = data.winstoryID })
            self:addChild(layer, 5)
            gameUser._storyDisplayedID = nowBlock
            -----
        end
    end
end

function LiLianStageChapterLayer:showWhyGetIngot1000()
    local nowBlock = gameUser.getInstancingId()
    local isWin = gameUser.getFightingBlockStatu()
    if isWin == 1 and nowBlock == 10 and XTHD.resource.PVE11GiveIngot > 0 then
        ----赢了
        XTHD.resource.PVE11GiveIngot = 0
        local param = {
            { rewardtype = 4, id = 2306, num = 1 },
            { rewardtype = 4, id = 2306, num = 1 },
            { rewardtype = 4, id = 2306, num = 1 },
            { rewardtype = 4, id = 2306, num = 1 },
            { rewardtype = 4, id = 2306, num = 1 },
            { rewardtype = 4, id = 2306, num = 1 },
            { rewardtype = 4, id = 2306, num = 1 },
            { rewardtype = 4, id = 2306, num = 1 },
			{ rewardtype = 4, id = 2306, num = 1 },
			{ rewardtype = 4, id = 2306, num = 1 },
        }
		param.showLineNum = true
        ShowRewardNode:create(param)
        performWithDelay(self, function()
            local layer = StoryLayer:createWithParams( { storyId = 41 })
            cc.Director:getInstance():getRunningScene():addChild(layer, 10)
        end , 0.8)
    end
end

function LiLianStageChapterLayer:getBlockArrow()
    return self._arrow_sp
end

function LiLianStageChapterLayer:addGuide()
    local _back = self._topBar:getChildByName("topBarBackBtn")
    YinDaoMarg:getInstance():addGuide( {
        --- 返回
        parent = self,
        target = _back,
        needHideNode = false,--function()
--          return self:getBlockArrow()
--      end,
        needNext = false,
    } , {
        { 1, 1 },
        { 5, 1 },
        { 6, 1 },
        { 7, 1 },
        { 8, 1 },
        { 13, 1 },
        { 14, 1 },
        { 18, 1 },
    } )
    YinDaoMarg:getInstance():addGuide( {
        --- 领取星级宝箱
        parent = self,
        target = self._guideBoxBtn,
        index = 4,
        isButton = false,
        needNext = false,
        needHideNode = false,--function()
--            return self:getBlockArrow()
--        end,
    } , 3)
    YinDaoMarg:getInstance():addGuide( { parent = self, index = 2 }, 10)
    ----剧情			
    YinDaoMarg:getInstance():addGuide( {
        --- 精英关卡
        parent = self,
        target = self._eliteBtn,
        index = 3,
        isButton = false,
        needHideNode = false,--function()
--          return self:getBlockArrow()
--      end,
        needNext = false
    } , 8)
    if self._turnplateBtn then
        YinDaoMarg:getInstance():addGuide( {
            --- 点击转盘
            parent = self,
            target = self._turnplateBtn,
            index = 2,
            needHideNode = false,--function()
	--          return self:getBlockArrow()
	--      end,
            needNext = false,
        } , 3)
    end
    YinDaoMarg:getInstance():doNextGuide()
end

function LiLianStageChapterLayer:addBlockGuide(target)
    YinDaoMarg:getInstance():addGuide( {
        -----精英关卡第一关
        parent = self,
        target = target,
        needNext = false,
        needHideNode = false,--function()
--          return self:getBlockArrow()
--      end,
    } , {
        { 1, 7 },
        { 2, 11 },
        { 3, 6 },
        { 5, 8 },
        { 8, 4 },----精英关卡第一关			
    } )
end
------当点第一关的时候弹
function LiLianStageChapterLayer:displayTaskSpine()
    -- YinDaoMarg:getInstance():getACover(self)
    -- local flash_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/zhsm.json", "res/spine/effect/exchange_effect/zhsm.atlas",1 )
    --    flash_effect:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2 + 53)
    --    self:addChild(flash_effect,20)
    --    flash_effect:setAnimation(0,"mubiao1",false)
    --    performWithDelay(flash_effect, function()
    -- 	flash_effect:removeFromParent()
    -- 	YinDaoMarg:getInstance():removeCover(self)
    -- 	YinDaoMarg:getInstance():doNextGuide()
    -- end,2.0)
end

return LiLianStageChapterLayer