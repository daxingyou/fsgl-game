-- FileName: LiLianStageChapterData.lua
-- Author: wangming
-- Date: 2016-01-15
-- Purpose: 新的历练主ui逻辑的数据封装类
--[[TODO List]]

LiLianStageChapterData = {}

--根据获取当前最大开放的关卡数据数据
function LiLianStageChapterData.getMaxChapterStage()
	local _instancingId = gameUser.getDiffcultyInstancingId()

	local _info = LiLianStageChapterData.getStageInfoById(_instancingId + 1)
	if _info == nil or next(_info) == nil then
		_info = LiLianStageChapterData.getStageInfoById(_instancingId)
	end
	return _info
end

--根据 关卡id 获取 关卡数据
function LiLianStageChapterData.getStageInfoById( sID )
	return gameData.getDataFromCSV("NightmareCopyList", {["instancingid"] = sID})
end

--根据 章节id 获取该章节的所有关卡数据
function LiLianStageChapterData.getStageInfoByChapterId(cID )
	return gameData.getDataFromCSV("NightmareCopyList", {["chapterid"] = cID})
end
--根据 chapterid 取 ChaptersList数据
function LiLianStageChapterData.getChapterInfoById(_type,  sID )
	if _type == ChapterType.Normal then
		return gameData.getDataFromCSV("CommonStarRewards", {["chapterid"] = sID})
	elseif _type == ChapterType.ELite then
		return gameData.getDataFromCSV("EliteStarAward", {["chapterid"] = sID})
	elseif _type == ChapterType.Diffculty then
		return gameData.getDataFromCSV("NightmareStarRewards", {["chapterid"] = sID})
	end
end
--获取当前章节所获得的星星数量
function LiLianStageChapterData.getChapterStars(_type, _cID)

	--当前已获得的星数
	local current_page_star = 0
	if _type == ChapterType.Normal then
		local _chapter_data = gameData.getDataFromCSV("ExploreInfoList", {["chapterid"] = _cID} )--["instacingid"]
		for i=1,#_chapter_data do
			local _star_ = CopiesData.GetNormalStar(_chapter_data[i]["instancingid"]) or 0
			current_page_star = current_page_star + _star_
		end
	elseif _type == ChapterType.ELite then
		local _chapter_data =  gameData.getDataFromCSV("EliteCopyList", {["chapterid"] = _cID} )--["instacingid"]
		for i=1,#_chapter_data do
			local _star_= CopiesData.GetEliteStar(_chapter_data[i]["instancingid"]) or 0
			current_page_star = current_page_star + _star_
		end
	elseif _type == ChapterType.Diffculty then
		local _chapter_data =  gameData.getDataFromCSV("NightmareCopyList", {["chapterid"] = _cID} )--["instacingid"]
		for i=1,#_chapter_data do
			local _star_= CopiesData.GetDiffcultyStar(_chapter_data[i]["instancingid"]) or 0
			current_page_star = current_page_star + _star_
		end
	end
	return current_page_star
end
--根据 chapterid 取 ChaptersList数据
function LiLianStageChapterData.getChapterTotalStars(_type, sID )
	return LiLianStageChapterData.getChapterInfoById(_type,  sID )["totalstar"] or 30
end
--根据 instanceid 获取idx
function LiLianStageChapterData.getChapterFirstIdx(_id, data )
	for i = 1, #data do
		if tonumber(data[i]["instancingid"]) == tonumber(_id) then
			return i 
		end
	end
	return 1
end
--获取当前最大关卡id
function LiLianStageChapterData.getInstancingId(chapterType)
	local _instancingId
	if chapterType == ChapterType.Normal then
		_instancingId = gameUser.getInstancingId() or 0
	else
		_instancingId = gameUser.getEliteInstancingId() or 0
	end
	return _instancingId
end
--初始进入是否开启
function LiLianStageChapterData.hasOpened(cID)
	local chapterTable = LiLianStageChapterData.getStageInfoByChapterId(cID)
	local playerInstanceId = tonumber(gameUser.getDiffcultyInstancingId())

	if chapterTable and next(chapterTable) then
		if chapterTable and tonumber(chapterTable[1].instancingid) > tonumber(playerInstanceId+1) then
			return false
		else
			return true
		end
	else
		return false
	end
end
function LiLianStageChapterData.hasOpenedByInstanceid(sId)
	local playerInstanceId = tonumber(gameUser.getDiffcultyInstancingId())
	return tonumber(sId) <= playerInstanceId  
end

--获取章节奖励状态
function LiLianStageChapterData.getRewardState(_type, _cID)

	if _type == ChapterType.Normal then
		return gameUser.getCopiesReward()[_cID]["normal_times"] or ""
	elseif _type == ChapterType.ELite then
		return gameUser.getEliteCopiesReward()[_cID]["elite_times"] or ""
	elseif _type == ChapterType.Diffculty then
		return gameUser.getDiffcultyCopiesReward()[_cID]["elite_times"] or ""
	end
end

function LiLianStageChapterData.getRewardListNode(node,stage_data)
	--587*119
	-- local fall_bg = ccui.Scale9Sprite:create(cc.rect(14,15,1,1),"res/image/common/scale9_bg_5.png")
	local fall_bg = cc.Sprite:create()
	fall_bg:setContentSize(cc.size(node:getContentSize().width,150))

	local _str = LANGUAGE_TIPS_WORDS190
	if tonumber(stage_data["bossid"]) == -1 then
		_str = LANGUAGE_VERBS.canGet
	end
	local label_probability_fall = XTHDLabel:create(_str,18)------"可能获得:",18)
	label_probability_fall:setColor(cc.c3b(69,32,17))
	label_probability_fall:setAnchorPoint(0.5,1)
	label_probability_fall:setPosition(fall_bg:getContentSize().width/2,fall_bg:getContentSize().height-8)
	fall_bg:addChild(label_probability_fall)

	local fall_items = string.split(stage_data.items,"#")
	if tonumber(stage_data["bossid"]) == -1 then
		local table  = string.split(stage_data.firstiawardid,",")
	    fall_items={}
		for k,v in ipairs(table) do
			v=string.split(v,"#")
			fall_items[#fall_items+1]=v
		end
	end

	-- 可能掉落
	local width=fall_bg:getContentSize().width /2 
	local space = 110
	local exNum = 0
	if stage_data.ZhenQi and tonumber(stage_data.ZhenQi) > 0 then
		exNum = 1
	end

	if #fall_items + exNum == 4 then
		space = 100
	elseif #fall_items + exNum == 5 then
		space = 85
	end
	local tabPos = SortPos:sortFromMiddle(cc.p(width ,fall_bg:getContentSize().height/2) , tonumber(#fall_items + exNum) , space)

	if tonumber(stage_data["bossid"]) == -1 then

	end

	local reward = {}
	if tonumber(stage_data["bossid"]) == -1 then
		for i = 1, #fall_items do
			reward[i] = {}
			reward[i].id = tonumber(fall_items[i][2])
			reward[i]._type = tonumber(fall_items[i][1])
			reward[i]._count = tonumber(fall_items[i][3])
		end
	else
		for i = 1, #fall_items do
			reward[i] = {}
			reward[i].id = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = fall_items[i]})["itemid"]
			reward[i]._type = 4
		end
	end
	--真气
	if stage_data.ZhenQi and tonumber(stage_data.ZhenQi) > 0 then
		local newIdx = #reward+1
		reward[newIdx] = {}
		reward[newIdx]._type = XTHD.resource.type.zhenQi
	end

	for i,var in ipairs(reward) do
		local item_bg=nil
		local items_info=nil 		
	    item_bg = ItemNode:createWithParams({
			itemId = var.id,
			needSwallow = true,
			_type_ = var._type,
			count = var._count, 
		})
	    print("item size ... ", item_bg:getContentSize().width, item_bg:getContentSize().height)
		item_bg:setScale(0.85)
		item_bg:setPosition(tabPos[i].x,tabPos[i].y - 10)
		fall_bg:addChild(item_bg)

		local item_name_label = XTHDLabel:createWithParams({
            text = item_bg._Name,
            anchor=cc.p(0.5,1),
            fontSize = 18,--字体大小
            color = cc.c3b(69,32,17),
            pos = cc.p(item_bg:getContentSize().width/2,-2),
        })
        item_bg:addChild(item_name_label)
	end
	return fall_bg
end

function LiLianStageChapterData.openBoxEvent(node, stage_data, _type, callback)
	local _modules = "challangeBoxDiffcultyEctype?"

	ClientHttp:requestAsyncInGameWithParams({	
		modules = _modules,
	    params = {ectypeId=stage_data.instancingid},
	    successCallback = function(data)
	        if tonumber(data.result) == 0 then
				YinDaoMarg:getInstance():releaseGuideLayer()
	        	if _type == ChapterType.Normal then	
	        		print("the saved block id is",stage_data.instancingid)
					gameUser.setInstancingId(stage_data.instancingid)
				elseif _type == ChapterType.ELite then
					gameUser.setEliteInstancingId(stage_data.instancingid)
				elseif _type == ChapterType.Diffculty then
					gameUser.setDiffcultyInstancingId(stage_data.instancingid)
				end
				
	        	local reward_data = {}
				if tonumber(stage_data["bossid"]) == -1 then
					local table  = string.split(stage_data.firstiawardid,",")
					for k,v in ipairs(table) do
						v=string.split(v,"#")
						reward_data[#reward_data+1]=v
					end
				end

	        	local function ActionCallback()
	        		local show_data = {}
					for i=1,#reward_data do
	  					show_data[#show_data+1] = {rewardtype = tonumber(reward_data[i][1]),id=reward_data[i][2],num =  tonumber(reward_data[i][3])}
					end

					-- XTHD.dispatchEvent({name = "EVENT_LEVEUP", data = {isAfterBox = true}})
					local _extraTips = nil
					local _group = YinDaoMarg:getInstance():getGuideSteps()
					if _group == 6 then 
						_extraTips = LANGUAGE_TIPS_WORDS280
					end 
					ShowRewardNode:createWithParams({
						showData = show_data,
						callback = function()
							XTHD.dispatchEvent({name = "EVENT_LEVEUP", data = {isAfterBox = true}})
	        				YinDaoMarg:getInstance():setCurrentGuideVisibleStatu(true)

				        	if callback and type(callback) == "function" then
				        		callback(data)
				        	end
						end,
						guideText = _extraTips,
					})	   
	        	end
	        	
	        	--更新数据      
	        	-- addPets 英雄 
	        	
	        	gameData.saveDataToDB(data["addPets"],1)
	        	-- property 属性 
	        	if data["property"] then
			        for i=1,#data["property"] do
			            local pro_data = string.split( data["property"][i],',')
			            DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2])
			        end
			    end
	        	-- bagItems  背包 
	        	if data.bagItems then
			        for i=1,#data.bagItems do
			           DBTableItem.updateCount(gameUser.getUserId(),data.bagItems[i], data.bagItems[i]["dbId"])
			        end
			    end  
			    if data.addGods then  
			    	for  i=1,#data.addGods  do  
			    		DBTableArtifact.analysDataAndUpdate(data.addGods[i])
			    	end 	
				end 
			    local iseffect=false 
			    for i,v in ipairs(reward_data) do
	        		if v[1] and tonumber(v[1])==50 then
        				local layer = requires("src/fsgl/layer/QiXingTan/QiXingTanGetNewHeroLayer.lua"):create({
		        			par = cc.Director:getInstance():getRunningScene(),
           					id =tonumber(v[2]),
            				star = tonumber(gameData.getDataFromCSV("GeneralInfoList",{heroid = tonumber(v[2])})["star"])or 0,
            				isAddScene=true,
            				from = "map",
            				callBack = ActionCallback,
        				})
        				iseffect=true 
	        		end
	        	end
	        	if iseffect==false then 
	        		ActionCallback()
	        	end 
	        	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
	        else
	        	YinDaoMarg:getInstance():tryReguide()
	         	XTHDTOAST(data.msg)
	         	-- self:hide()
	        end
	    end,--成功回调
	    failedCallback = function()
	        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
	        YinDaoMarg:getInstance():tryReguide()
	         -- self:hide()
	    end,--失败回调
	    loadingParent = node,
	    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end

function LiLianStageChapterData.httpBuyChallengeTimes(params)
	if not params.parNode then
		return
	end
	ClientHttp:requestAsyncInGameWithParams({
		modules = "resetDiffcultyEctype?",
        params = {ectypeId=params.id},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
        successCallback = function(net_data)
            if tonumber(net_data.result) == 0 then
            	params.callback(net_data)
            else
            	XTHDTOAST(net_data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = params.parNode,--需要保存引用的目标
	    loadingParent = params.parNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function LiLianStageChapterData.getAllChapterStar(_type)

	local allChapter = {} 

	local maxChapterInfo = LiLianStageChapterData.getMaxChapterStage()
	local maxChapter = tonumber(maxChapterInfo.chapterid) or 1
	local rewardAll = gameUser.getDiffcultyCopiesReward()

	for i = 1, maxChapter do
		local chapterInfo = LiLianStageChapterData.getChapterInfoById(_type, i)
		allChapter[i] = {}
		local allStar = LiLianStageChapterData.getChapterStars(_type, i)
		local rewardInfo = rewardAll[i].elite_times

		local rewardState = {}
		if rewardInfo ~= "" then --说明已经领取过
			rewardState = string.split(rewardInfo, "#")
		end

		local _canGetNum = math.floor(allStar/(tonumber(chapterInfo.totalstar)/tonumber(chapterInfo.prizecount))) --可领取奖励个数

		local _state
		if #rewardState == tonumber(chapterInfo.prizecount) then
			_state = 2 --已经完成
		else
			if _canGetNum > #rewardState then --可领取
				_state = 1 
			else --未完成
				_state = 0 
			end
		end

		allChapter[i].rewardState = _state
		allChapter[i].allStar = allStar
		allChapter[i].totalstar = chapterInfo.totalstar
		allChapter[i].chapterId = i
		allChapter[i].name = chapterInfo.name
	end

	return allChapter
end


return LiLianStageChapterData