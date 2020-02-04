--[[
	开始挑战界面新UI
	by andong
	11-19
]]--
-- IS_NEI_TEST = true
local LiLianStageLayer = class("LiLianStageLayer", function()
	return XTHD.createBasePageLayer()
end)


function LiLianStageLayer:ctor( params )

	self._chapterId = params.chapterId 		 --章节id
	self._stageType = ChapterType.Diffculty  --副本类型
	self._toChapterId = params.stageId       --直接跳转id
	self:init()

	XTHD.addEventListener({
		name = "EVENT_LEVEUP",
		callback = function(event)
			-- print("level up")
		end
	})
end

--向服务器请求第一个通过此章节的人
function LiLianStageLayer:requestFirstOne(chaptertype,levelid,chapterid)
	-- print("当前的副本类型是："..chaptertype.."       章节id："..chapterid.."      关卡id："..levelid)
	local cType
	if chaptertype == ChapterType.ELite then
        cType = "elite"
    elseif chaptertype == ChapterType.Normal then
        cType = "ectype"
    else
        cType = "diffculty"
	end
	ClientHttp:requestAsyncInGameWithParams({
        modules = "ectypeRecordFristName?",
        params  = {ectypeType = cType,ectypeId = levelid},
        successCallback = function( data )
            -- print("请求噩梦副本千古留名服务器返回参数为：")
            -- print_r(data)
            if tonumber(data.result) == 0 then
            	if data.name ~= "" then
	                local str = "首次通关者："..data.name
	                self.first_name:setString(str)
	            else
                    self.first_name:setString("")
            	end
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

function LiLianStageLayer:initData()

	local function _showInfo()

			self.stage_data = LiLianStageChapterData.getStageInfoByChapterId(self._chapterId)
			--推关记录
			self._my_instancing = gameUser.getDiffcultyInstancingId()
			--记录上一个点击的instanceId
			self._last_instancing = self._my_instancing

			for i = 1, #self.stage_data do --整理数据
				local getStar = CopiesData.GetDiffcultyStar(self.stage_data[i].instancingid) or 0 --记录已经得到的星
				self.stage_data[i].getStar = getStar
				if tonumber(self.stage_data[i].instancingid) > tonumber(self._my_instancing) then
					local nums = #self.stage_data - i 
					for j = 1, nums do
						table.remove(self.stage_data, #self.stage_data)
					end
					break
				end
			end

			-- table.sort(self.stage_data, function(a, b)
			-- 	return tonumber(a.instancingid) > tonumber(b.instancingid)
			-- end)
			-- dump(self.stage_data, "self.stage_data ===========")

			if not self._myTable then
				self:initStageTable()
			else
				--打完之后，播放动画然后reload,再跳转到指定关卡
				self._myTable:reloadData()
			end
			if self._lastTotal and self._lastTotal == #self.stage_data then
				self._myTable:scrollToCell(self._lastClickIdx, false)
				self:clickCell(self._lastClickIdx)
			else
				if self._lastTotal and self._lastTotal ~= #self.stage_data then
					self._hasNewChpter = true
				end

				local initIdx = #self.stage_data
				if self._toChapterId then
					initIdx = LiLianStageChapterData.getChapterFirstIdx(self._toChapterId, self.stage_data)
					-- self._lastClickIdx = initIdx
					self._myTable:scrollToCell(initIdx, false)
					performWithDelay(self, function()
						self:clickCell(initIdx)
					end, 0.4)
				else
					-- self._lastClickIdx = initIdx
					self._myTable:scrollToCell(initIdx, false)
					performWithDelay(self, function()
						self:clickCell(initIdx)
					end, 0.2)
				end
			end

			self._lastTotal = #self.stage_data
			self:refreshStar()

	end
	--屏蔽层
	self._touchGet1 = XTHDPushButton:createWithParams({
		touchSize = cc.size(10000, 10000),
		endCallback = function()
			-- print("get touch ..................... ")
		end,
		pos = cc.p(self:getBoundingBox().width/2, self:getBoundingBox().height/2),
		needSwallow = true,
	})
	self:addChild(self._touchGet1, 10)

	if self._last_instancing then --播放动画
		local newGetStar = CopiesData.GetDiffcultyStar(self._last_instancing) or 0
		--需要播放动画
		if tonumber(newGetStar) > tonumber(self.stage_data[self._lastClickIdx].getStar) then
		-- if tonumber(newGetStar) > 0 then
			if self._myTable and self._myTable:cellAtIndex(self._lastClickIdx-1) then
				local cellimg = self._myTable:cellAtIndex(self._lastClickIdx-1):getChildByName("cellimg")
				local starNum = tonumber(newGetStar)-tonumber(self.stage_data[self._lastClickIdx].getStar)
				local _delayTime = 0.2
				for i = 1, 3 do
					local starBack = cellimg:getChildByName("starBack"..i)
					starBack:removeAllChildren()
				end

				-- print("tonumber(newGetStar)  -------------> ", tonumber(newGetStar))
				-- for i = 1, tonumber(newGetStar) do
				for i = 1, tonumber(newGetStar) do
					local starBack = cellimg:getChildByName("starBack"..i)
					local pos1 = cellimg:convertToWorldSpace(cc.p(starBack:getPositionX(), starBack:getPositionY()))
					-- print("star pos --============================> ", pos1.x, pos1.y)
					local starimg = XTHD.createSprite("res/image/plugin/stageChapter/starbox_star3.png")
					starimg:setPosition(starBack:getContentSize().width/2, starBack:getContentSize().height/2)
					starBack:addChild(starimg)
					starimg:setName("starimg")
					starimg:setVisible(false)
					-- starimg:setVisible(true)


					local starimg1 = XTHD.createSprite("res/image/plugin/stageChapter/starbox_star3.png")
					starimg1:setPosition(pos1.x, pos1.y)
					self:addChild(starimg1)
					--动画
					starimg1:setScale(5)
		    		starimg1:setOpacity(0)
		    		starimg1:runAction(cc.Sequence:create(
		    			cc.DelayTime:create(0.1+i*(0.2-(i*0.01))),
		    			cc.Spawn:create(
		    				cc.FadeIn:create(0.2),
		    				cc.Sequence:create(
		    					cc.DelayTime:create(0.1),
		    					cc.ScaleTo:create(0.15,1),
	    						cc.ScaleTo:create(0.07,1.1),
	    						cc.ScaleTo:create(0.03,1))
		    				),
    					cc.CallFunc:create(function() 
    						if starimg and tonumber(newGetStar) > 1 then
    							starimg:setVisible(true) 
    						end
    					end),
    					cc.RemoveSelf:create(true)
		    		))
		    		_delayTime = _delayTime + 0.1+i*(0.2-(i*0.01))
				end
				-- _delayTime = _delayTime + 0.3
				-- print(" _delayTime-----> ", _delayTime)
				performWithDelay(self, function()
					_showInfo()
				end, _delayTime)
			else
				_showInfo()
			end	
		else
			_showInfo()
		end
	else
		_showInfo()
	end

end
function LiLianStageLayer:init( )--在副本里添加了宝箱这个东西 所以弹出界面增加一个类型
	self._topBar = self:getChildByName("TopBarLayer1") --userinfo
	self._topBar:setNeedReleaseGuide(false)
    --backGround
    local background = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    background:setPosition(self:getContentSize().width/2, self:getContentSize().height/2 - self.topBarHeight/2)
    self:addChild(background)

	local title = "res/image/public/emeng_title.png"
	XTHD.createNodeDecoration(background,title)

    local contentimg = ccui.Scale9Sprite:create(cc.rect(200,200,1,1),"res/image/common/tab_contentBg.png")
	contentimg:setContentSize(background:getContentSize())
    contentimg:setAnchorPoint(cc.p(1,0.5))
    contentimg:setPosition(background:getContentSize().width*0.5, background:getPositionY() )
    -- self:addChild(contentimg)

	-- local content = XTHD.getScaleNode("res/image/common/scale9_bg_14.png", cc.size(self:getContentSize().width-90, contentimg:getContentSize().height))
	local content = cc.Sprite:create()
	content:setContentSize( cc.size(background:getContentSize().width, contentimg:getContentSize().height) )
	self._content = content
	content:setAnchorPoint(cc.p(0.5, 0.5))
	content:setPosition(background:getContentSize().width/2, background:getContentSize().height*0.5)
	background:addChild(content)

	-- local rightImg = XTHD.getScaleNode("res/image/common/scale9_bg_14.png", cc.size(430, self._content:getContentSize().height))
	local rightImg = XTHD.createSprite()
	rightImg:setContentSize(cc.size(460, self._content:getContentSize().height))
	rightImg:setAnchorPoint( cc.p(0.5, 0.5) )
	rightImg:setPosition(cc.p(self._content:getContentSize().width - rightImg:getContentSize().width * 0.5, self._content:getContentSize().height/2))
	self._content:addChild(rightImg)
	self._rightImg = rightImg

	--章节奖励背景
	local box_di = cc.Sprite:create("res/image/plugin/stageChapter/starbox_di.png")
	box_di:setAnchorPoint(0.5,0.5)
	box_di:setPosition(box_di:getContentSize().width*0.5,box_di:getContentSize().height*0.5 + 20)
	background:addChild(box_di,1)
	self._box_di = box_di


	self:createChapterReward(self._box_di)
	self:initData()

end

--创建章节奖励
function LiLianStageLayer:createChapterReward(box_di)

	--宝箱
	box_di:removeAllChildren()

	local box_btn = XTHDImage:create("res/image/plugin/stageChapter/star_reward.png")
	box_btn:setOpacity(100)
	box_btn:setPosition(130, box_di:getContentSize().height*0.5)
	box_di:addChild(box_btn,1)
	--章节总星数 30
	self._totalStar = LiLianStageChapterData.getChapterTotalStars(self._stageType, self._chapterId) 
	--章节当前已获得星数
	self._curStar = LiLianStageChapterData.getChapterStars(self._stageType, self._chapterId)
	-- self.max_star_txt = getCommonWhiteBMFontLabel(self._totalStar) 
	-- self.max_star_txt:setAnchorPoint(1,1)
	-- self.max_star_txt:setPosition(box_btn:getContentSize().width*0.5, 5)
	-- box_btn:addChild(self.max_star_txt)
	-- local star_bg1 = cc.Sprite:create("res/image/plugin/stageChapter/starbox_star3.png")
	-- star_bg1:setAnchorPoint(0,1)
	-- star_bg1:setPosition(self.max_star_txt:getPositionX(), self.max_star_txt:getPositionY())
	-- box_btn:addChild(star_bg1)
	local effect_spine = sp.SkeletonAnimation:create("res/spine/effect/qiandai/qiandai.json", "res/spine/effect/qiandai/qiandai.atlas",1.0)
	effect_spine:setPosition(box_btn:getPositionX(), box_btn:getPositionY())
	effect_spine:setAnimation(0,"xx1", true)
	box_di:addChild(effect_spine, box_btn:getLocalZOrder())
	self._box_effect_spine = effect_spine
	--星星数背景
	local star_bg = cc.Sprite:create("res/image/plugin/stageChapter/starbox_star.png")
	star_bg:setPosition(35+10, box_btn:getPositionY() + 10)
	box_di:addChild(star_bg,box_btn:getLocalZOrder())
	self._current_page_star_txt = getCommonWhiteBMFontLabel(0)
	self._current_page_star_txt:setPosition(star_bg:getContentSize().width/2,-20)
	star_bg:addChild(self._current_page_star_txt)
	box_btn:setTouchEndedCallback(function ()

		----引导 
		---....
		------------------------------
		musicManager.playEffect(XTHD.resource.music.effect_btn_common)
		local _chapter_reward = LiLianStageChapterData.getChapterInfoById(self._stageType, self._chapterId)
		local reward = {}
		reward["instancint_type"] = self._stageType
		reward["chapter_reward"] = _chapter_reward
		reward["chapterid"] = self._chapterId
		reward.totalstar = self._totalStar
		reward.prizecount = tonumber(_chapter_reward.prizecount)
		reward.getstar = self._curStar
		reward.callback = function()
			self:refreshStar()
		end
		self:addChild(requires("src/fsgl/layer/LiLian/LiLianReceiveBoxRewardNew.lua"):create(reward),3)
	end)
end
function LiLianStageLayer:refreshStar()
	local rewardState =  LiLianStageChapterData.getRewardState(self._stageType, self._chapterId)
	self._curStar = LiLianStageChapterData.getChapterStars(self._stageType, self._chapterId)
	self._current_page_star_txt:runAction(cc.Sequence:create(
		cc.FadeOut:create(0.205),
		cc.CallFunc:create(function()
	 		self._current_page_star_txt:setString(self._curStar.."/"..self._totalStar)
		end),
		cc.FadeIn:create(0.205)
	))
	local prizecount = tonumber(LiLianStageChapterData.getChapterInfoById(self._stageType, self._chapterId).prizecount) or 3
	local _perRewardStar = self._totalStar / prizecount
	local _canGetNum = math.floor(self._curStar/_perRewardStar) --可领取奖励个数

	local stateTable = {}
	if rewardState ~= "" then --说明已经领取过
		stateTable = string.split(rewardState, "#")
	end
	if #stateTable == prizecount then --已领取完
		self._box_effect_spine:setAnimation(0,"xx3",true)
	else
		if _canGetNum > #stateTable then --可领取
		 	self._box_effect_spine:setAnimation(0,"xx2",true)
		else
			self._box_effect_spine:setAnimation(0,"xx1",true)
		end
	end
end
function LiLianStageLayer:initRight(stage_data, nowIdx)
	-- print("--------------噩梦副本章节的数据为--------------")
 --    print_r(stage_data)

	local rightImg = self._rightImg
	rightImg:removeAllChildren()
	local imgSize = rightImg:getContentSize()
	local stage_name = XTHDLabel:create(stage_data.name,28)
	local _name_color = cc.c3b(192,45,0)
	if self._stageType == ChapterType.ELite then
		_name_color = cc.c3b(38,106,175)
	end
	stage_name:setColor(_name_color)
	stage_name:setAnchorPoint(cc.p(0.5,1))
	stage_name:setPosition(imgSize.width/2,imgSize.height - stage_name:getContentSize().height * 0.5 - 20)
	rightImg:addChild(stage_name)

	--千古留名
	local _first_color = cc.c3b(38,106,175)
    local first_name = XTHDLabel:create("",20)
    first_name:setColor(_first_color)
    first_name:setAnchorPoint(cc.p(0.5,0))
    first_name:setPosition(imgSize.width/2,imgSize.height - 75 )
    rightImg:addChild(first_name)
    self.first_name = first_name
    self:requestFirstOne(self._stageType,stage_data.instancingid,stage_data.chapterid)

	local stage_desc = XTHDLabel:create(stage_data.description,18)
	stage_desc:setColor(cc.c3b(128,112,91))
	stage_desc:setAnchorPoint(0.5, 1)
	if stage_desc:getContentSize().width > 355 then
	    stage_desc:setDimensions(400,50)
	else
		stage_desc:setDimensions(400,34)
	end
	stage_desc:setPosition(imgSize.width/2, imgSize.height -45)
	-- rightImg:addChild(stage_desc)

	local line_sp = ccui.Scale9Sprite:create(cc.rect(0,0,20,2),"res/image/ranklistreward/splitX.png")
	line_sp:setContentSize(cc.size(imgSize.width-20,2))
	line_sp:setAnchorPoint(0.5,0.5)
	line_sp:setPosition(imgSize.width / 2, rightImg:getContentSize().height-90)
	rightImg:addChild(line_sp)

	if tonumber(stage_data.bossid) > 0 then --关卡信息
		--奖励列表
		-- local rewardlist = self:getRewardListNode(rightImg, stage_data)
		local rewardlist = LiLianStageChapterData.getRewardListNode(rightImg, stage_data)
		rewardlist:setAnchorPoint(cc.p(0.5, 1))
		rewardlist:setPosition(cc.p(imgSize.width/2 , line_sp:getPositionY()-5))
		rightImg:addChild(rewardlist)

		--消耗背景
		local consumption_bg = ccui.Scale9Sprite:create("res/image/plugin/stagepop/xh_bg.png")
		consumption_bg:setContentSize(cc.size(425, 52))
		consumption_bg:setAnchorPoint(0.5, 1)
		consumption_bg:setPosition(imgSize.width / 2, imgSize.height - 275)
		rightImg:addChild(consumption_bg)
		local consumption = XTHDLabel:create(LANGUAGE_VERBS.cost1..":",18)-------消		耗: ",18)
		consumption:setColor(cc.c3b(69,32,17))
		consumption:setAnchorPoint(0,0.5)
		consumption:setPosition(20,consumption_bg:getContentSize().height / 2 )
		consumption_bg:addChild(consumption)
		local _spPhysical = cc.Sprite:create("res/image/common/header_tili.png");
		_spPhysical:setAnchorPoint(cc.p(0.5, 0.5));
		_spPhysical:setPosition(cc.p(consumption:getPositionX() + 40 + _spPhysical:getContentSize().width,consumption_bg:getContentSize().height/2));
		consumption_bg:addChild(_spPhysical);
		local label_consumption = XTHDLabel:create(stage_data.hpcost,24)
		label_consumption:setColor(cc.c3b(167,0,0))
		label_consumption:setPosition(_spPhysical:getPositionX() + _spPhysical:getContentSize().width,consumption_bg:getContentSize().height / 2)
		consumption_bg:addChild(label_consumption)
			-- print("挑战次数 ===== ")
		local challage_label = XTHDLabel:create(LANGUAGE_TIPS_WORDS189,18)---------"挑战次数: ",18)
		challage_label:setColor(cc.c3b(69,32,17))
		challage_label:setAnchorPoint(cc.p(0,0.5))
		challage_label:setPosition(35 + label_consumption:getPositionX() + label_consumption:getContentSize().width,consumption_bg:getContentSize().height/2 )
		consumption_bg:addChild(challage_label)
		local dao = cc.Sprite:create("res/image/plugin/stagepop/knife.png")
		dao:setAnchorPoint(cc.p(0,0.5))
		dao:setPosition(10 + challage_label:getPositionX() + challage_label:getContentSize().width,consumption_bg:getContentSize().height/2 )
		consumption_bg:addChild(dao)
		--经营副本有个购买次数的小东西
		if self._stageType == ChapterType.Diffculty then
			self._last_fight_times =CopiesData.GetDiffcultyTimes(stage_data.instancingid) or 3
			self._reset_times = CopiesData.GetDiffcultyRefreshTimes(stage_data.instancingid ) or 0
			self._challage_time_txt = XTHDLabel:create(self._last_fight_times.."/3",18) 
			self._challage_time_txt:setColor(cc.c3b(167,0,0))
			self._challage_time_txt:setAnchorPoint(cc.p(0,0.5))
			self._challage_time_txt:setPosition(10 + dao:getPositionX() + dao:getContentSize().width,consumption_bg:getContentSize().height/2 )
			consumption_bg:addChild(self._challage_time_txt)

			local add_time_btn = XTHDPushButton:createWithParams({
				selectedFile = "res/image/common/btn/btn_add_selected.png",
				normalFile = "res/image/common/btn/btn_add_normal.png",
				musicFile = XTHD.resource.music.effect_btn_common,
				pos = cc.p(30 + self._challage_time_txt:getPositionX() + self._challage_time_txt:getContentSize().width,consumption_bg:getContentSize().height/2 )		
			})
			add_time_btn:setScale(0.8)
			add_time_btn:setTouchEndedCallback(function()
				if tonumber(self._last_fight_times) > 0  then
					XTHDTOAST(LANGUAGE_FORMAT_TIPS39(self._last_fight_times))-----"当前剩余挑战次数为".. tostring(self.self._last_fight_times) .."次,无法购买!")
					return
				end
				--如果重置次数用完，提示
				local resetInfo = gameData.getDataFromCSV("VipInfo", {["id"]=47})
				local selfVip = gameUser.getVip() or 0
				if resetInfo["vip"..selfVip] and tonumber(resetInfo["vip"..selfVip]) == tonumber(self._reset_times) then
					XTHDTOAST(LANGUAGE_TIPS_NO_RESETTIMES)
					return
				end
				local _confirmLayer = XTHDConfirmDialog:createWithParams( {
		            rightCallback  = function ()
		            	LiLianStageChapterData.httpBuyChallengeTimes({
		            		parNode = self,
		            		id = stage_data.instancingid,
		            		callback = function(net_data)
				            	self._last_fight_times = tonumber(net_data["surplusCount"])
				            	self._reset_times = tonumber(net_data["resetCount"])
				            	self._challage_time_txt:setString(net_data["surplusCount"].."/3")
				            	self:setSweepBtnStatus()
								CopiesData.ChangeDiffcultyTimes(stage_data.instancingid,net_data["surplusCount"])
				            	CopiesData.ChangeDiffcultyRefreshTimes(stage_data.instancingid,net_data["resetCount"])
				            	if net_data["ingot"] then
					            	gameUser.setIngot(net_data["ingot"])
					            end
				            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
				            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
		            		end,
		            	})
		            end,
		            msg = LANGUAGE_FORMAT_TIPS40((self._reset_times+1)*50)------"您确定要花费".. tostring((self._reset_times+1)*50).."元宝购买挑战次数吗？"
		        } )
		        self:addChild(_confirmLayer)
			end)
			consumption_bg:addChild(add_time_btn);
		else
			local infinite = XTHDLabel:create(LANGUAGE_ADJ.nolimit,18)---------"挑战次数: ",18)
			infinite:setColor(cc.c3b(167,0,0))
			infinite:setAnchorPoint(cc.p(0,0.5))
			infinite:setPosition(10 + dao:getPositionX() + dao:getContentSize().width,consumption_bg:getContentSize().height/2 )
			consumption_bg:addChild(infinite)
		end

		--征战10次
		local sweep_times = 1
		--按钮bg
		local label_sp = nil
		if self._stageType == ChapterType.Normal then
			label_sp = XTHD.resource.getButtonImgTxt("saodangshici_lan")
			sweep_times = 10
		elseif self._stageType == ChapterType.ELite then
			label_sp =  XTHD.resource.getButtonImgTxt("saodangsanci_lan")
			sweep_times = 3
		elseif self._stageType == ChapterType.Diffculty then
			label_sp =  XTHD.resource.getButtonImgTxt("saodangsanci_lan")
			sweep_times = 3
		end
		local sweepTen_disableNode = ccui.Scale9Sprite:create("res/image/common/btn/btn_write_1_disable.png")
		sweepTen_disableNode:setContentSize(cc.size(163,75))

		local sweep_10_btn = XTHD.createCommonButton({
			text = "征战三次",
			isScrollView = false,
			btnColor = "write",
			btnSize = cc.size(150,46),
			disableNode = sweepTen_disableNode,
			fontColor = cc.c3b(255,255,255),
			fontSize = 24,
			endCallback = function()
				local tili_num = 50
				if self._stageType == ChapterType.Normal then
					tili_num = 50
				elseif self._stageType == ChapterType.ELite then
					tili_num = 30
				elseif self._stageType == ChapterType.Diffculty then
					tili_num = 30
				end
				if gameUser.getTiliNow() < tonumber(tili_num) then
					self:showPayDialog()
					return
				end
				self:SweepRequest(sweep_times,stage_data.instancingid )
			end
		})
		-- sweep_10_btn:getLabel():setPositionX(sweep_10_btn:getLabel():getPositionX()-15)
		-- sweep_10_btn:getLabel():setPositionY(sweep_10_btn:getLabel():getPositionY()-5)
		sweep_10_btn:setScale(0.8)
		sweep_10_btn:setAnchorPoint(0,0)
		sweep_10_btn:setPosition(15, sweep_10_btn:getContentSize().height*0.5 + 10)
		
		--征战一次
		local sweepOne_disableNode = ccui.Scale9Sprite:create("res/image/common/btn/btn_write_1_disable.png")
		sweepOne_disableNode:setContentSize(cc.size(163,75))
		XTHD.setGray(sweepOne_disableNode,true)
		local sweep_btn = XTHD.createCommonButton({
			btnColor = "write_1",
			isScrollView = false,
			disableNode = sweepOne_disableNode,
			text = "征战一次",
			btnSize = cc.size(150,46),
			fontColor = cc.c3b(255,255,255),
			fontSize = 24,
			endCallback = function()
				if gameUser.getTiliNow() < 5 then
					self:showPayDialog()
					return
				end
				self:SweepRequest(1,stage_data.instancingid )
			end
		})
		-- sweep_btn:getLabel():setPositionX(sweep_btn:getLabel():getPositionX()-15)
		-- sweep_btn:getLabel():setPositionY(sweep_btn:getLabel():getPositionY()-5)
		sweep_btn:setScale(0.8)
		sweep_btn:setAnchorPoint(0,0)
		sweep_btn:setPosition(15, sweep_10_btn:getPositionY() + sweep_btn:getContentSize().height*0.5 + 15)


		self._sweep_10_btn = sweep_10_btn
		self._sweep_btn = sweep_btn
		--先判断次数时候允许开区
		self:setSweepBtnStatus()
		
		--在判断关卡书否允许开启
		if tonumber(stage_data["bossid"]) == 0 or (tonumber(stage_data["bossid"]) > 0 and tonumber( stage_data["instancingid"]) > self._my_instancing  ) then
			sweep_10_btn:setEnable(false)
			sweep_btn:setEnable(false)
			sweep_10_btn:setVisible(false)
			sweep_btn:setVisible(false)
		end
		rightImg:addChild(sweep_10_btn)
		rightImg:addChild(sweep_btn)


		-- self:show()
		local challenge_btn, battle_effect = XTHD.createFightBtn({
	        par = rightImg,
	        pos = cc.p(250, 110),
	    })
		
		challenge_btn:setTouchBeganCallback(function()
			if battle_effect then
				battle_effect:setScale(0.98)
			end
		end)

		challenge_btn:setTouchMovedCallback(function()
			if battle_effect then
				battle_effect:setScale(1)
			end
		end)

		challenge_btn:setTouchEndedCallback(function ()
			if battle_effect then
				battle_effect:setScale(1)
			end
			musicManager.playEffect(XTHD.resource.music.effect_btn_common)
			self:challageEvent(stage_data)
		end)
		self._challeng_btn = challenge_btn
	else --宝箱

		local rewardlist =  LiLianStageChapterData.getRewardListNode(rightImg, stage_data)
		rewardlist:setAnchorPoint(cc.p(0.5, 1))
		rewardlist:setPosition(cc.p(imgSize.width/2 , line_sp:getPositionY()-30))
		rightImg:addChild(rewardlist)

		local challenge_btn = XTHD.createCommonButton({
				btnSize = cc.size(200,46),
				isScrollView = false,
				text = LANGUAGE_BTN_KEY.getTheRewards,
			})
		challenge_btn:setPosition(rightImg:getContentSize().width / 2, 70)
		rightImg:addChild(challenge_btn)
		challenge_btn:setTouchEndedCallback(function ()
			-----引导
			-- ....

			--------------------------------------------------
			if  tonumber(stage_data["bossid"]) == -1 then
				LiLianStageChapterData.openBoxEvent(self, stage_data, self._stageType, function(data)
					local info = LiLianStageChapterData.getStageInfoByChapterId(self._chapterId)
					-- print("lengths --> ", #(self.stage_data))
					-- print("lengths --> ", #(info))

					if #(self.stage_data) == #info then

						-- print("to new page -----> ")
						local stageType = self._stageType
						self._isPassed = true
						-- self._callback(stageType, true) --已经通关，跳出
						LayerManager.removeLayout(self)
					else
						self:initData()
					end
				end)
			end 
		end)

		--通关提示
		local get_rewardlabel=XTHDLabel:createWithParams({text="通关前置关卡可领取奖励!",ttf="",size=20})
		get_rewardlabel:setColor(cc.c3b(131,0,0))
		get_rewardlabel:setPosition(rightImg:getContentSize().width / 2,challenge_btn:getPositionY()+30)
		rightImg:addChild(get_rewardlabel)
		get_rewardlabel:setVisible(false)
		if tonumber(stage_data["instancingid"])> self._my_instancing +1 then 
			  challenge_btn:setVisible(false)
			  get_rewardlabel:setVisible(true)
		elseif tonumber(stage_data["instancingid"])<= self._my_instancing then 
			  challenge_btn:setVisible(false)
			  local already_sp = cc.Sprite:create("res/image/vip/yilingqu.png")
			  already_sp:setAnchorPoint(0.5,0)
			  already_sp:setPosition(rightImg:getContentSize().width/2,40)
			  rightImg:addChild(already_sp)
		end	

	end


	--预加载资源
	self:preload()
end
function LiLianStageLayer:preload()
	local function preloadAni( id )
		local nId = id
		id = tostring(id)
		if string.len(id) == 1 then
			id = "00" .. id
		elseif string.len(id) == 2 then
			id = "0" .. id
		end
		if id ~= 322 and id ~= 026 and id ~= 042 then
			sp.SkeletonAnimation:createWithBinaryFile("res/spine/" .. id .. ".skel", "res/spine/" .. id .. ".atlas", 1)
		else
			sp.SkeletonAnimation:create("res/spine/" .. id .. ".json", "res/spine/" .. id .. ".atlas", 1)
		end
	end

	local function preSpine( ... )
		local _pve_heros = DBUserTeamData:getPVETeamData()
		local pCount = 0
		if _pve_heros and #_pve_heros > 0 then
			for i = 1, 5 do
				local pNum = tonumber(_pve_heros["heroid"..i]) or 0
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
function LiLianStageLayer:initStageTable()

	local tableSize = cc.size(self._content:getContentSize().width-self._rightImg:getContentSize().width-4, self._rightImg:getContentSize().height-120)
	local tableNode = self._content
	
	local myTableBg = ccui.Scale9Sprite:create()
	myTableBg:setContentSize(tableSize)
	myTableBg:setAnchorPoint(cc.p(0.5, 1))
	myTableBg:setPosition(cc.p(myTableBg:getContentSize().width*0.5 + 10, tableNode:getContentSize().height - 25))
	tableNode:addChild(myTableBg)

	-- local yinying= ccui.Scale9Sprite:create(cc.rect(7,18,1,1), "res/image/plugin/stageChapter/yinying.png")
	-- local yinying= XTHD.getScaleNode("res/image/plugin/stageChapter/yinying.png", cc.size(myTableBg:getContentSize().width, 36))
	-- -- myScale9:setContentSize(cc.size(myTableBg:getContentSize().width, 36))
	-- yinying:setAnchorPoint(cc.p(0.5, 1))
	-- yinying:setPosition(cc.p(tableSize.width/2, tableSize.height))
	-- myTableBg:addChild(yinying, 2)

	
	local myTable = cc.TableView:create(cc.size(myTableBg:getContentSize().width-4,myTableBg:getContentSize().height-8))
	TableViewPlug.init(myTable)
	myTable:setPosition(2,4)
	myTable:setBounceable(false)
	myTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
	myTable:setDelegate()
	myTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	
	self._myTable = myTable
	myTableBg:addChild(myTable)
	self._cellSize = cc.size(tableSize.width, 100)

	local function cellSizeForTable(table,idx)
		return tableSize.width,100
	end
	local function numberOfCellsInTableView(table)
	    return #self.stage_data
	end
	local function tableCellAtIndex(table,idx)
		local nowIdx = idx + 1
		local cell = table:dequeueCell()
	    if cell == nil then
	        cell = cc.TableViewCell:new()
	        cell:setContentSize(cc.size(tableSize.width, 100))
	    else
            local mask = cell:getChildByName("cellimg"):getChildByName("mask")

            if mask then
                self._clickedCell = nil
            end

	    	cell:removeAllChildren()
	    end
	    self:buildCell(cell, nowIdx)

	    return cell
	end

    myTable.getCellNumbers=numberOfCellsInTableView
	myTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    myTable.getCellSize=cellSizeForTable
	myTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
	myTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
	
	myTable:reloadData()
	
end

function LiLianStageLayer:buildCell(cell, nowIdx)

	local stageData = self.stage_data[nowIdx]

	local cellimg1 = XTHD.getScaleNode("res/image/common/scale9_bg_32.png", cc.size(cell:getContentSize().width-10,cell:getContentSize().height-3))
	local cellimg2 = XTHD.getScaleNode("res/image/common/scale9_bg_32.png", cc.size(cell:getContentSize().width-10,cell:getContentSize().height-3))
	local cellimg = XTHDPushButton:createWithParams({
		normalNode = cellimg1,
		selectedNode = cellimg2,
		touchSize = cc.size(cell:getContentSize().width-5, cell:getContentSize().height-5),
		pos = cc.p(cell:getContentSize().width/2-2, cell:getContentSize().height/2+1),
		needSwallow = false,
		needEnableWhenMoving = true,
		endCallback = function()
			--如果点击的不一样
			if self._lastClickIdx ~= nowIdx then
				self:clickCell(nowIdx)
			end
		end,
	})
	cellimg:setName("cellimg")
	cell:addChild(cellimg)

	local _diSp = XTHD.createSprite("res/image/plugin/competitive_layer/hero_board1.png")
	local imgPath =	self:getAvatorAsIWant(stageData)
	local boss = cc.Sprite:create(imgPath)
	_diSp:setScale(0.6)
	boss:setPosition(_diSp:getContentSize().width/2, _diSp:getContentSize().height/2)
	_diSp:addChild(boss)
	_diSp:setAnchorPoint(0,0.5)
	_diSp:setPosition(cc.p(20,cellimg:getContentSize().height/2))
	cellimg:addChild(_diSp, 1)
	
	local cellline = ccui.Scale9Sprite:create(cc.rect(0,0,20,2),"res/image/ranklistreward/splitX.png")
	cellline:setContentSize( cc.size(cellimg:getContentSize().width-100,2) )
	cellline:setAnchorPoint(cc.p(1, 0.5))	
	cellline:setPosition(cc.p(cellimg:getContentSize().width-10, cellimg:getContentSize().height - 32))
	cellimg:addChild(cellline, 1)

	local name = XTHDLabel:createWithParams({
		-- text = LANGUAGE_STAGE_TIPS_GUANQIA.."-"..(#self.stage_data+1-nowIdx),
		text = stageData.name,
		fontSize = 18,
		color = cc.c3b(158, 19, 19),
		anchor = cc.p(0, 1),
		pos = cc.p(100, cellimg:getContentSize().height-5),
	})
	cellimg:addChild(name, 1)
	
	if self._lastClickIdx == nowIdx then
		local myScale9 = ccui.Scale9Sprite:create(cc.rect(15,15,1,1), "res/image/common/common_selected2.png")
		myScale9:setContentSize(cc.size(cell:getContentSize().width-10,cell:getContentSize().height-3))
		myScale9:setAnchorPoint(cc.p(0.5, 0.5))
		self._clickedCell = myScale9 --XTHD.getScaleNode("res/image/common/common_selected2.png", cc.size(cell:getContentSize().width-10,cell:getContentSize().height-3))
		self._clickedCell:setName("mask")
		self._clickedCell:setPosition(cc.p(cellimg:getContentSize().width/2, cellimg:getContentSize().height/2))
		cellimg:addChild(self._clickedCell, 0)

--		local myScale9 = ccui.Scale9Sprite:create("res/image/common/scale9_bg_13.png")
--		myScale9:setContentSize(cc.size(cell:getContentSize().width-10,cell:getContentSize().height-3))
--		myScale9:setAnchorPoint(cc.p(0.5, 0.5))
--		myScale9:setPosition(cc.p(self._clickedCell:getContentSize().width/2, self._clickedCell:getContentSize().height/2))
		-- self._clickedCell:addChild(myScale9)
	end

	--des
	local tipLab = XTHDLabel:create(stageData.description or "",18)
	tipLab:setAnchorPoint(cc.p(0,1))
	tipLab:setPosition(110, cellimg:getContentSize().height-42)
	tipLab:setColor(cc.c3b(69,32,17))
	tipLab:setWidth(cell:getContentSize().width - 120)
	cellimg:addChild(tipLab, 1)

	--如果是箱子，就不走以下逻辑
	if tonumber(stageData.bossid) == -1 then
		return 
	end
	local myLab = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_FINISHRECORD.." :",
		fontSize = 20,
		color = cc.c3b(168, 144, 117),
		anchor = cc.p(1, 1),
		pos = cc.p(cellimg:getContentSize().width-140, cellimg:getContentSize().height-5),
	})
	cellimg:addChild(myLab, 1)
	myLab:setVisible(false)

	local _star = CopiesData.GetDiffcultyStar(stageData.instancingid) or 0 --星星数量

	for i = 1, 3 do
		local starBack = XTHD.createSprite("res/image/tmpbattle/star_back.png")
		starBack:setAnchorPoint(cc.p(0, 1))
		starBack:setPosition(cc.p(myLab:getPositionX()+10+(i-1)*30, name:getPositionY()))
		cellimg:addChild(starBack, 1)
		starBack:setName("starBack"..i)

		if _star >= i then
			local starimg = XTHD.createSprite("res/image/plugin/stageChapter/starbox_star3.png")
			starimg:setPosition(starBack:getContentSize().width/2, starBack:getContentSize().height/2)
			starBack:addChild(starimg)
		end
	end
end

function LiLianStageLayer:createCell(_size, nowIdx)

	local stageData = self.stage_data[nowIdx]

	local cellimg = XTHD.getScaleNode("res/image/common/scale9_bg_26.png", cc.size(_size.width-10, _size.height-3))

	local _diSp = XTHD.createSprite("res/image/plugin/stageChapter/boss_avator_bg.png")
	local imgPath =	self:getAvatorAsIWant(stageData)
	local boss = cc.Sprite:create(imgPath)
	if boss then
		boss:setPosition(_diSp:getContentSize().width/2, _diSp:getContentSize().height/2)
		_diSp:addChild(boss)
	end

	_diSp:setAnchorPoint(0,0.5)
	_diSp:setPosition(cc.p(10,cellimg:getContentSize().height/2))
	cellimg:addChild(_diSp)
	
	local cellline = ccui.Scale9Sprite:create(cc.rect(0,0,20,2),"res/image/ranklistreward/splitX.png")
	cellline:setContentSize( cc.size(cellimg:getContentSize().width-100,2) )
	cellline:setAnchorPoint(cc.p(1, 0.5))	
	cellline:setPosition(cc.p(cellimg:getContentSize().width-10, cellimg:getContentSize().height - 32))
	cellimg:addChild(cellline)

	local name = XTHDLabel:createWithParams({
		-- text = LANGUAGE_STAGE_TIPS_GUANQIA.."-"..(#self.stage_data+1-nowIdx),
		text = stageData.name,

		fontSize = 18,
		color = cc.c3b(158, 19, 19),
		anchor = cc.p(0, 1),
		pos = cc.p(100, cellimg:getContentSize().height-5),
	})
	cellimg:addChild(name)

	--des
	local tipLab = XTHDLabel:create(stageData.description or "",18)
	tipLab:setAnchorPoint(cc.p(0,1))
	tipLab:setPosition(110, cellimg:getContentSize().height-42)
	tipLab:setColor(cc.c3b(69,32,17))
	tipLab:setWidth(_size.width - 120)
	cellimg:addChild(tipLab)

	--如果是箱子，就不走以下逻辑
	if tonumber(stageData.bossid) ~= -1 then
		local myLab = XTHDLabel:createWithParams({
			text = LANGUAGE_KEY_FINISHRECORD.." :",
			fontSize = 20,
			color = cc.c3b(168, 144, 117),
			anchor = cc.p(1, 1),
			pos = cc.p(cellimg:getContentSize().width-140, cellimg:getContentSize().height-5),
		})
		cellimg:addChild(myLab)
		myLab:setVisible(false)

		local _star = CopiesData.GetDiffcultyStar(stageData.instancingid) or 0 --星星数量

		for i = 1, 3 do
			local starBack = XTHD.createSprite("res/image/tmpbattle/star_back.png")
			starBack:setAnchorPoint(cc.p(0, 1))
			starBack:setPosition(cc.p(myLab:getPositionX()+10+(i-1)*30, name:getPositionY()))
			cellimg:addChild(starBack)
			starBack:setName("starBack"..i)

			if _star >= i then
				local starimg = XTHD.createSprite("res/image/plugin/stageChapter/starbox_star3.png")
				starimg:setPosition(starBack:getContentSize().width/2, starBack:getContentSize().height/2)
				starBack:addChild(starimg)
			end
		end
	end

	return cellimg
end
--点击效果
function LiLianStageLayer:clickCell(nowIdx)
	print("self._lastClickIdx --> ", self._lastClickIdx)
	print("self.nowIdx --> ", nowIdx)
	-- print("self._hasNewChpter --> ", self._hasNewChpter)

	--第1次进来没有选择，与上次选择不一样，有开启新的关卡
	if not self._lastClickIdx or self._lastClickIdx ~= nowIdx or self._hasNewChpter then
		if self._clickedCell then
			self._clickedCell:removeFromParent()
			self._clickedCell = nil
		end
		local cell = self._myTable:cellAtIndex(nowIdx-1)
		if cell and cell:getChildByName("cellimg") then
			-- print(" to create mask ...... ")
			local cellimg = cell:getChildByName("cellimg")

			self._clickedCell = XTHD.getScaleNode("res/image/common/scale9_bg_32.png", cc.size(self._cellSize.width-10, self._cellSize.height-3))
			self._clickedCell:setName("mask")
			self._clickedCell:setPosition(cc.p(cellimg:getContentSize().width/2, cellimg:getContentSize().height/2))
			cell:getChildByName("cellimg"):addChild(self._clickedCell, 0)

			local myScale9 = ccui.Scale9Sprite:create(cc.rect(15,15,1,1), "res/image/common/common_selected2.png")
			myScale9:setContentSize(cc.size(cell:getContentSize().width-10,cell:getContentSize().height-3))
			myScale9:setAnchorPoint(cc.p(0.5, 0.5))
			myScale9:setPosition(cc.p(self._clickedCell:getContentSize().width/2, self._clickedCell:getContentSize().height/2))
			 self._clickedCell:addChild(myScale9)
		end
		--===
		-- print("self._hasNewChpter ------> ", self._hasNewChpter)
		-- print("cell --> ", cell)
		if cell and self._hasNewChpter then

			local _touchGet2 = XTHDPushButton:createWithParams({
				touchSize = cc.size(10000, 10000),
				endCallback = function()
				end,
				pos = cc.p(self._content:getContentSize().width/2, self._content:getContentSize().height/2),
				needSwallow = true,

			})
			self:addChild(_touchGet2, 10)

			local cellimg = cell:getChildByName("cellimg")
			local _parent = cell:getParent()
			-- local pos1 = self._myTable:convertToWorldSpace(cc.p(cellimg:getPositionX(), cellimg:getPositionY()))
			local pos1 = cellimg:convertToWorldSpace(cc.p(cellimg:getPositionX(), cellimg:getPositionY()))

			-- print("pos1 =======================> ", pos1.x, pos1.y)

			local actionImg= self:createCell(cell:getContentSize(), nowIdx)
			if actionImg then
			elseif actionImg == nil then
				-- print("is nil ======================= ")
			end
			if actionImg then
				self._content:addChild(actionImg)
				actionImg:setPosition(cc.p(pos1.x, pos1.y))
				cellimg:setVisible(false)
				actionImg:runAction(cc.Sequence:create(
					cc.ScaleTo:create(0.2, 1.3),
					cc.ScaleTo:create(0.15, 1.0),
					cc.CallFunc:create(function()
						cellimg:setVisible(true)
					end),
					cc.CallFunc:create(function()
						if _touchGet2 then
							_touchGet2:removeFromParent()
						end
					end),
					cc.RemoveSelf:create(true)
				))
			end
			self._hasNewChpter = false
		end
	end

	if self._touchGet1 then
		self._touchGet1:removeFromParent()
		self._touchGet1 = nil
	end

	self._lastClickIdx = nowIdx --记录当前选择的关卡
	local stageData = self.stage_data[nowIdx]
	if stageData and stageData.instancingid then
		self._last_instancing = stageData.instancingid --记录上一次点击的instancingid
		self:initRight(stageData, nowIdx)
	end
end

function LiLianStageLayer:onEnter()

	--------引导
	--...
	if self._continue then
		self:initData()
	end
	self._continue = true
	--------
end
--体力不足的时候显示的提示框
function LiLianStageLayer:showPayDialog(_tili_cost)
 	local confirm = XTHDConfirmDialog:createWithParams({
		msg = LANGUAGE_TIPS_IF_BUY_TILI,
		rightCallback = function()
			local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=2})--byhuangjunjian 获得资源共用方法（1.元宝2.体力3.银两4.翡翠）
		     cc.Director:getInstance():getRunningScene():addChild(StoredValue)	
		end,
	})
	self:addChild(confirm,10)
end

function LiLianStageLayer:setSweepBtnStatus()
	--只有精英副本才有征战次数限制
	if self._stageType == ChapterType.Diffculty  then
		self._last_fight_times =  self._last_fight_times or 0
		if self._last_fight_times > 0 and self._last_fight_times < 3 then
			self._sweep_10_btn:setEnable(false)
			self._sweep_10_btn:setLabelColor(cc.c3b(255,255,255))
			self._sweep_btn:setEnable(true)
			self._sweep_btn:setLabelColor(cc.c3b(255,255,255))
		elseif self._last_fight_times <= 0  then
			self._sweep_10_btn:setEnable(false)
			self._sweep_10_btn:setLabelColor(cc.c3b(255,255,255))
			self._sweep_btn:setEnable(false)
			self._sweep_btn:setLabelColor(cc.c3b(255,255,255))

		elseif self._last_fight_times >= 3  then
			self._sweep_10_btn:setEnable(true)
			self._sweep_10_btn:setLabelColor(cc.c3b(255,255,255))
			self._sweep_btn:setEnable(true)
			self._sweep_btn:setLabelColor(cc.c3b(255,255,255))

		end
	end
	
end
function LiLianStageLayer:getAvatorAsIWant(data)
	local heroid = data.bossid
	local imgPath =	"res/image/avatar/avatar_circle_"..heroid..".png"
	if not cc.Director:getInstance():getTextureCache():addImage(imgPath) then
		imgPath = 	"res/image/avatar/avatar_circle_1.png"
	end
	if tonumber(heroid) == -1 then
		imgPath = "res/image/plugin/stageChapter/reward_2.png"
		if tonumber(self._my_instancing) < tonumber(data.instancingid) then
			imgPath = "res/image/plugin/stageChapter/reward_1.png"
		end
	end
	return imgPath
end

function LiLianStageLayer:onExit( )
	-- if self._callback and type(self._callback) == "function" then
	-- 	self._callback(self._stageType, false)
	-- end
end
function LiLianStageLayer:onCleanup()
	-- print("self._isPassed ------> ", self._isPassed )
	if self._callback and type(self._callback) == "function" then
		self._callback(self._stageType, self._isPassed)
	end
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TASKLIST})
	XTHD.removeEventListener("EVENT_LEVEUP")
end
function LiLianStageLayer:SweepRequest(times,instancingid)
	--征战限制 by hezhitao  began
	local tmp_data = gameData.getDataFromCSV("FunctionInfoList", {id = 30})
	local unlocktype = tmp_data["unlocktype"] or 2
	local unlockparam = tmp_data["unlockparam"] or 0
	if tonumber(unlocktype) == 2 then   --根据关卡开启
		if gameUser.getInstancingId() < tonumber(unlockparam) then
			XTHDTOAST(tmp_data["tip"])
			return
		end
	elseif tonumber(unlocktype) == 1 then   --根据玩家等级开启
		if gameUser.getLevel() < tonumber(unlockparam) then
			XTHDTOAST(tmp_data["tip"])
			return
		end
	end

	--end
	local _modules = "sweepDiffcultyEctype?"
	ClientHttp:requestAsyncInGameWithParams({
			modules = _modules,
            params = {ectypeId=instancingid,times=times},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
            successCallback = function(net_data)
	            if tonumber(net_data.result) == 0 then
	            	local playerProperty = net_data["property"]
	            	if playerProperty then
				        for i=1,#playerProperty do
				            local pro_data = string.split( playerProperty[i],',')
				              DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
				        end
				    end
	            	 --更新数据库稍微延时了，刷新数据的时候，没有及时更新到数据 yanyuling
	            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
	            	local LiLianSweepPopLayer = requires("src/fsgl/layer/LiLian/LiLianSweepPopLayer.lua"):create(net_data)
	            	self._content:addChild(LiLianSweepPopLayer,2)
	            	if self._stageType == ChapterType.Diffculty then
	            		self._last_fight_times = tonumber(net_data["surplusCount"])
		            	self._challage_time_txt:setString(net_data["surplusCount"].."/3")
		            	self:setSweepBtnStatus()
		            	CopiesData.ChangeDiffcultyTimes(instancingid,net_data["surplusCount"])
	            	end
	            	LiLianSweepPopLayer:setHideCallback()
					XTHD.dispatchEvent({name = "EVENT_LEVEUP"}) 
	            else
	            	XTHDTOAST(net_data.msg)
	            end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
end

function LiLianStageLayer:challageEvent (stage_data)

	local _battleType, min_level, tiliCost
	if self._stageType == ChapterType.Normal then
		_battleType = BattleType.PVE
		local _chapterInfo = gameData.getDataFromCSV("CommonStarRewards", {chapterid = stage_data.chapterid})
		min_level = _chapterInfo.levelfloor or 1
		tiliCost = stage_data.hpcost or 5
	elseif self._stageType == ChapterType.Elite then
		_battleType = BattleType.ELITE_PVE
		local _chapterInfo = gameData.getDataFromCSV("EliteStarAward", {chapterid = stage_data.chapterid})
		min_level = _chapterInfo.levelfloor or 1
		tiliCost = stage_data.hpcost or 10
	elseif self._stageType == ChapterType.Diffculty then
		_battleType = BattleType.DIFFCULTY_COPY
		local _chapterInfo = gameData.getDataFromCSV("NightmareStarRewards", {chapterid = stage_data.chapterid})
		min_level = _chapterInfo.levelfloor or 1
		tiliCost = stage_data.hpcost or 10
	end
	if gameUser.getLevel() < tonumber(min_level) then
		XTHDTOAST(LANGUAGE_FORMAT_TIPS41(min_level))-------"等级达到"..min_level.."级才能挑战")
		return
	end
	if gameUser.getTiliNow() < tiliCost then
		self:showPayDialog()
		return
	end
		
	ClientHttp.http_StartChallenge(self, BattleType.DIFFCULTY_COPY, {ectypeId = stage_data.instancingid}, function(data)
		----引导 
	    ------------------------------------

		LayerManager.addShieldLayout()
		local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):createForPve(BattleType.DIFFCULTY_COPY, stage_data.instancingid, data)
		fnMyPushScene(_layer)
	end)
end

--引导的进入战斗
function LiLianStageLayer:_goToBattle( sData )

	ClientHttp.http_EctypeBattleBegin(self, function()
		LayerManager.addShieldLayout()
		local _heroData = {}
		local _table = DBTableHero.getData(gameUser.getUserId())
		if _table then 
			if #_table > 1 then 
				_heroData = _table
			else
				_heroData[1] = _table
			end 
		end
		local _reward_item = sData or {}
		local _helps = {}
		if _reward_item.helps and _reward_item.helps[1] then --为了不影响正常使用临时屏蔽
			_helps = _reward_item.helps[1]
		end
		
     	local _arrDropList = _reward_item["itemReward"]
     	local _dropList = {}
     	for i = 1, #_arrDropList do
     		local _szData = _arrDropList[i];
     		local _tabData = string.split( _szData, ',' )
     		_dropList[tostring(_tabData[1])] = _tabData[2]
     	end
        --更新动态数据库中的体力data
       	gameUser.setTiliNow(tonumber(_reward_item.tili))

    	local teamListLeft = {}
    	local teamListRight = {}
    	local bgList = {}

    	for k,v in pairs(_helps) do
    		local animal = {id = v.heroid, _type = ANIMAL_TYPE.PLAYER, helps = v}
    		teamListLeft[#teamListLeft + 1] = animal
    	end
    	local _isGuidingHero = #_helps > 0 and true or false
    	for i=1, #_heroData do
    		local _heroId = _heroData[i].heroid
    		local _data = HeroDataInit:InitHeroDataSelectHero( _heroId )
    		local animal = {id = _heroId, _type = ANIMAL_TYPE.PLAYER, data = _data, isGuidingHero = _isGuidingHero}
    		teamListLeft[#teamListLeft + 1] = animal
			if #teamListLeft == 5 then
				break
			end
    	end
  		-- local _heroId = 1
		-- local _data = HeroDataInit:InitHeroDataSelectHero( _heroId )
		-- local animal = {id = _heroId, _type = ANIMAL_TYPE.PLAYER, data = _data, isGuidingHero = true}
		-- teamListLeft[#teamListLeft + 1] = animal
		-- local _heroId = 12
		-- local _data = HeroDataInit:InitHeroDataSelectHero( _heroId )
		-- local animal = {id = _heroId, _type = ANIMAL_TYPE.PLAYER, data = _data, isGuidingHero = true}
		-- teamListLeft[#teamListLeft + 1] = animal

    	table.sort(teamListLeft, function(a,b) 
    		local _range1 = a.helps and a.helps.attackrange or a.data.attackrange
    		_range1 = tonumber(_range1) or 0
    		local _range2 = b.helps and b.helps.attackrange or b.data.attackrange
    		_range2 = tonumber(_range2) or 0
    		return _range1 < _range2
    	end)

    	for k,v in pairs(teamListLeft) do
    		v.data = nil
    	end
		
        local instanceData
        local _battleType = _reward_item.battleType

        local sInstancingid = _reward_item.instancingid
		if _battleType == BattleType.PVE then
			instanceData = gameData.getDataFromCSV("ExploreInfoList", {["instancingid"]=sInstancingid})
		else
			instanceData = gameData.getDataFromCSV("EliteCopyList", {["instancingid"]=sInstancingid})
		end
		local bossid 	   = instanceData.bossid
		local sound 	   = "res/sound/"..tostring(instanceData.sound)..".mp3"
		local _time = instanceData.maxtime 

		local storyIds = string.split(instanceData.storyID,"#")
		local worldEffects = _reward_item.effects
		local background   = instanceData.background
		local bgs = string.split(background,"#")

		for k,bgId in pairs(bgs) do
			bgList[#bgList + 1] = "res/image/background/bg_"..bgId..".jpg"
		end
		local _bgType = instanceData.fubentype or -1
		
        local monsters = _reward_item.monsters
        for index=1,#monsters do
			local rightData 		= {}
			local storyId 			= storyIds[index]
			--[[--剧情id]]
        	if storyId and tonumber(storyId) and tonumber(storyId) > 0 and sInstancingid > gameUser.getInstancingId() then
				rightData.storyId 	= storyId
			end
			--[[--该波的怪物]]
        	local waveMonsters 		= monsters[index]
        	local team 				= {}
        	for k,monster in pairs(waveMonsters) do
        		local monsterid = monster.monsterid
        		local isBoss = false
        		if monster.heroid == 801 then
        			isBoss = true
        		end
        		local animal = {id = monsterid , _type = ANIMAL_TYPE.MONSTER,monster = monster, isWorldBoss = isBoss}
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
       
		local _helpsData = _helps
		local scene = cc.Scene:create()
		local battleLayer = requires("src/battle/BattleLayer.lua"):create()
		local uiExploreLayer = BattleUIExploreLayer:create(_battleType, false)            
		battleLayer:initWithParams({
			bgList 			= bgList,
			bgm    			= sound,
			battleTime      = _time,
			instancingid    = sInstancingid,
			teamListLeft	= {teamListLeft},
			teamListRight	= teamListRight,
			battleType 		= _battleType,
			bgType			= _bgType,
			isGuide			= _reward_item.guideIndex,
			helps 			= _helpsData,
			loadingType = HTTP_LOADING_TYPE.ANIM,
			worldBuff       = worldEffects,
			battleEndCallback = function(params)
				if _helpsData and #_helpsData > 0 and params.left and params.left[1] and #params.left[1] > 0 then
					for k,v in pairs(params.left[1]) do
						for key,value in pairs(_helpsData) do
							if value.heroid == v.id then
								v.type = ANIMAL_TYPE.MONSTER
								v.id = value.monsterid
							end
						end
					end
				end
				ClientHttp.http_SendFightValidation(battleLayer, function(data)
		            local _instancingid = params.instancingid
					local _star = data.star
					if tonumber(data["fightResult"]) == 1 then
						local refresh_data = {}
						refresh_data["type"] = _battleType == BattleType.PVE and ChapterType.Normal or ChapterType.ELite
			            refresh_data["instancingid"] = _instancingid
			            refresh_data["star"] = _star
			            refresh_data["surplusCount"] = data["surplusCount"] or 0
						CopiesData.refreshDataBase(refresh_data)
					end
					performWithDelay(battleLayer, function()
						battleLayer:hideWithoutBg()
						data.backCallback = function() 
							cc.Director:getInstance():popScene()
						end
						scene:addChild(requires( "src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoPVELayer.lua"):create(data))
					end, 2)
                end, function()
	             	createFailHttpTipToPop()
				end, params)
			end,
		})
		
		scene:addChild(battleLayer)
		battleLayer:setUILay(uiExploreLayer)
		scene:addChild(uiExploreLayer)
		
		cc.Director:getInstance():pushScene(scene)
		battleLayer:start()

		local _team_data = {}
	  	for i = 1, #teamListLeft do
	  		local _data = teamListLeft[i]
	  		if _data.id ~= 12 then
			  	_team_data["heroid"..i] = _data.id
		  	end
	  	end
	  	_team_data.teamid = 1
		DBUserTeamData:UpdatePVETeamData(_team_data)
	end)
end

function LiLianStageLayer:create( params )
	if params._callBack then
		self._callback = params._callBack
	end
	local layer = LiLianStageLayer.new(params)
	return layer
end


return LiLianStageLayer;