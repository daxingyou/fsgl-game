--Created By Liuluyang 2015年05月18日
--神器遗址开始挑战界面
local ShenQiYiZhiChapterLayer = class("ShenQiYiZhiChapterLayer",function ()
	return XTHD.createBasePageLayer({
		isCreateBg = false, 
		ZOrder = 2, 
		isOnlyBack = true,
	})
end)

function ShenQiYiZhiChapterLayer:ctor(data, id, callBack)
	self.id = id
	self._callBack = callBack
	self._bgImgFile = "res/image/plugin/saint_beast/godstage.jpg"
	self._popNames = LANGUAGE_TIPS_WORDS178 ---------{"神器守卫","决战BOSS","神器宝藏","恢复药剂","复活十字"}
    self._filePath = {"res/image/plugin/saint_beast/",""}
    self._popFiles = {
    	{"05.png","05_1.png","ss.png","07.png","10.png"},
    	{"04.png","04_1.png","02.png","06.png","11.png"},
    	{"13.png","13_1.png","03.png","09.png"},
    	{"12.png","12_1.png","03.png","08.png"},
    	{"14.png","14_1.png","03.png","08.png"},
	}
	self:initUI(data)
	-- XTHD.addEventListener({
 --        name = CUSTOM_EVENT.GO_RETURN_SAINT,
 --        callback = function (event)
 --        	LayerManager.removeLayout()
 --        end
 --    })
end

function ShenQiYiZhiChapterLayer:onEnter()
	local _length = #self.data.finishEctypes
	if _length == 0 then
		self.scrollview:jumpToPercentBothDirection(cc.p(50,50))
		return
	end
	local pId = self.data.finishEctypes[_length]
	local sPos = cc.p(0,0)
	local baseSize = self._worldSize
	local selfSize = self:getContentSize()

	for k,v in pairs(self.chapterData) do
    	if v.instancingid == pId then
    		local posSplit = string.split(v.pos,"#")
    		sPos = cc.p(baseSize.width*0.5 -- - self:getContentSize().width*0.5]]
    			 + posSplit[1],
    			baseSize.height*0.5 -- - self:getContentSize().height*0.5
    			 + posSplit[2])
    		break
    	end
    end
    local _innerNode = self.scrollview:getInnerContainer()

    local x = selfSize.width*0.5 - sPos.x
    local y = selfSize.height*0.5 - sPos.y

    x = x > 0 and 0 or x 
    local pMax = selfSize.width - baseSize.width
    x = x < pMax and pMax or x
    y = y > 0 and 0 or y
    local pMax = selfSize.height - baseSize.height
    y = y < pMax and pMax or y

    _innerNode:setPosition(cc.p(x,y))

end

function ShenQiYiZhiChapterLayer:onCleanup()
	if self._callBack then
		self._callBack()
	end
	-- XTHD.removeEventListener(CUSTOM_EVENT.GO_RETURN_SAINT)
	
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey(self._bgImgFile)
end

function ShenQiYiZhiChapterLayer:refreshData( data )
	if data then
		self.data = data
		self:analysData(data.finishEctypes)
	end
end

function ShenQiYiZhiChapterLayer:refreshMap(id)
	-- self.data.finishEctypes[#self.data.finishEctypes+1] = id
	-- self:analysData(self.data.finishEctypes)
	self:openNext(id)
	-- self.mapTable:reloadDataAndScrollToCurrentCell()
end

function ShenQiYiZhiChapterLayer:analysData(data)
	-- ZCLOG(self.chapterData)
	self.chapterStatus = {}
	for i=1,#self.chapterData do
		local nowData = self.chapterData[i]
		self.chapterStatus[nowData.instancingid] = 0 --0没开 1开了 2过了
	end
	for i=1,#self.chapterData do
		local nowData = self.chapterData[i]
		if nowData.unlockid == 0 then
			self.chapterStatus[nowData.instancingid] = 1
		end
		for j=1,#data do
			local unlockid = string.split(nowData.unlockid,"#")
			for k=1,#unlockid do
				if tonumber(unlockid[k]) == data[j] then
					self.chapterStatus[nowData.instancingid] = 1
					break
				end
			end
		end
	end
	for i=1,#data do
		self.chapterStatus[data[i]] = 2
	end
	
	-- ZCLOG(self.chapterStatus)
end

function ShenQiYiZhiChapterLayer:getTagSprite( Data, sprite, callFn )
	local openStatus = self.chapterStatus[Data.instancingid]
	local chpTip = nil
	local pType = tonumber(Data._type) or 1
	local _filePath = self._popFiles[pType]
	if openStatus == 2 then
		self._filePath[2] = _filePath[2]
	else
		self._filePath[2] = _filePath[3]
		local pFile = table.concat(self._filePath)
		chpTip = XTHD.createButton({
			normalFile = pFile,
			needSwallow = false,
			endCallback = function ( ... )
				if callFn then
					callFn()
				end
			end,
		})
		-- 
		local pos = 0
		local pAnc = cc.p(0.5, 0)
		if _filePath[5] then
			pos = 20
			pAnc.x = 0
			self._filePath[2] = _filePath[5]
			pFile = table.concat(self._filePath)
			local sp1 = cc.Sprite:create(pFile)
			sp1:setAnchorPoint(cc.p(1,0))
			sp1:setPosition(cc.p(chpTip:getContentSize().width*0.5 - 15, chpTip:getContentSize().height*0.57))
			chpTip:addChild(sp1)
		end
		self._filePath[2] = _filePath[4]
		pFile = table.concat(self._filePath)
		local sp2 = cc.Sprite:create(pFile)
		sp2:setAnchorPoint(pAnc)
		sp2:setPosition(cc.p(chpTip:getContentSize().width*0.5 - pos, chpTip:getContentSize().height*0.57))
		chpTip:addChild(sp2)

		local _nameTTF = XTHDLabel:createWithParams({
			text = self._popNames[pType],
			fontSize = 18,
			color = XTHD.resource.color.white_desc
		})
		--cc.Label:createWithTTF(self._popNames[pType], "", 18)
		_nameTTF:setAnchorPoint(cc.p(0.5, 0))
	  	_nameTTF:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(2, -2))
	    _nameTTF:setPosition(cc.p(chpTip:getContentSize().width*0.5 , 27))
		chpTip:addChild(_nameTTF)
	end

	if chpTip then
		sprite:addChild(chpTip)
		sprite.chpTip = chpTip
		chpTip:setAnchorPoint(cc.p(0.5, 0))
		chpTip:setPosition(cc.p(sprite:getBoundingBox().width*0.5, sprite:getBoundingBox().height))
	end
	return chpTip
end

function ShenQiYiZhiChapterLayer:getTexture(Data)
	local openStatus = self.chapterStatus[Data.instancingid]
	local chpIcon = nil
	local pType = tonumber(Data._type) or 1
	local _filePath = self._popFiles[pType]
	if openStatus == 2 then
		self._filePath[2] = _filePath[2]
		chpIcon = table.concat(self._filePath)
	else
		self._filePath[2] = _filePath[1]
		chpIcon = table.concat(self._filePath)
	end
	return chpIcon
end

function ShenQiYiZhiChapterLayer:initUI(data)
	XTHD.saveItem({items = data.bagItems})
	self.data = data
	if self.data.groupId then
		self.groupId = self.data.groupId
	end
	-- ZCLOG(self.data)
	if self.data.ectypeType then
		self.ectypeType = self.data.ectypeType
	end
	-- data.hps.petHps = self:tmpList()

	if self:getChildByName("_notic_bg") then
		self:getChildByName("_notic_bg"):removeFromParent()
	end

	self.chapterData = gameData.getDataFromCSV("RelicsEnemyList",{chapterlist = self.data.groupId})
	self.allData = gameData.getDataFromCSV("RelicsEnemyList")
	
	-- self.data.finishEctypes = {
	--     -- [1] = 1601,
	--     -- [2] = 1602,
	--     -- [3] = 1603,
	--     -- [4] = 1604,
	--     -- [5] = 1605,
	--     -- [6] = 1607
	-- }
	self:analysData(data.finishEctypes)

	-- local loadingBarBg = cc.Sprite:create("res/image/common/common_progress_bg.png")
 --    loadingBarBg:setAnchorPoint(1,0)
 --    loadingBarBg:setPosition(self:getBoundingBox().width-10,10)
 --    self:addChild(loadingBarBg,1)

 --    self.loadingBar = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/common_progress.png"))
 --    self.loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
 --    self.loadingBar:setBarChangeRate(cc.p(1,0))
 --    self.loadingBar:setMidpoint(cc.p(0,0.5))
 --    self.loadingBar:setPosition(loadingBarBg:getBoundingBox().width/2,loadingBarBg:getBoundingBox().height/2)
 --    loadingBarBg:addChild(self.loadingBar)
 --    self.loadingBar:setPercentage(50)

 --    local completedDegree = XTHDLabel:createWithParams({
 --        text = "副本完成度：",
 --        fontSize = 16 ,
 --        color = cc.c3b(237, 232, 193)
 --    })
 --    completedDegree:setAnchorPoint(1,0.5)
 --    completedDegree:setPosition(loadingBarBg:getPositionX()-loadingBarBg:getBoundingBox().width,
 --    	loadingBarBg:getPositionY() + loadingBarBg:getBoundingBox().height*0.5)
 --    self:addChild(completedDegree,1)

    -- local percentLabel = getCommonWhiteBMFontLabel("")
    -- percentLabel:setPosition(loadingBarBg:getBoundingBox().width/2,loadingBarBg:getBoundingBox().height/2-6)
    -- loadingBarBg:addChild(percentLabel)
    -- self.percentLabel = percentLabel

    local beastBg = cc.Sprite:create(self._bgImgFile)

    local scrollview = ccui.ScrollView:create()
    scrollview:setTouchEnabled(true)
	scrollview:setScrollBarEnabled(false)
    scrollview:setDirection(ccui.ScrollViewDir.both)
    scrollview:setContentSize(self:getContentSize())
    scrollview:setInnerContainerSize(beastBg:getContentSize())
    scrollview:setPosition(0,0)
    self._worldSize = beastBg:getContentSize()
    self:addChild(scrollview)

    beastBg:setPosition(beastBg:getBoundingBox().width/2,beastBg:getBoundingBox().height/2)
    scrollview:addChild(beastBg)
    self.scrollview = scrollview

    -- scrollview:jumpToBottomRight()
    -- scrollview:jumpToDestination(cc.p(-1045,0))
    --todo
    -- self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
    -- 	scrollview:jumpToBottomRight()
    -- end)))
    -- scrollview:jumpToPercentBothDirection(cc.p(beastBg:getBoundingBox().width/2,beastBg:getBoundingBox().height/2))
    -- scrollview:scrollToBottomRight(0,false)
    -- do return end
    
    local chapterList = {}
    local pTable = {}
    for i=1,#self.chapterData do
    	local nowData = self.chapterData[i]

    	local filePath = self:getTexture(nowData)

    	local chapter = XTHD.createButton({
    		normalFile = filePath,
    		needSwallow = false,
    	})
    	--cc.Sprite:create(filePath)
    	local posSplit = string.split(nowData.pos,"#")
    	chapter:setPosition(beastBg:getBoundingBox().width*0.5 + posSplit[1], beastBg:getBoundingBox().height * 0.5 + posSplit[2])
    	scrollview:addChild(chapter,1)
    	-- chapter:setName(nowData.chapterlist)
    	chapter.unlockid = nowData.unlockid
    	chapter.id = nowData.instancingid
    	chapterList[nowData.instancingid] = chapter
    	table.insert(pTable, chapter)
    	if nowData.unlockid ~= 0 then
			chapter:setVisible(false)
		end

		local function touchCall()
	  		if self.chapterStatus[nowData.instancingid] == 0 then
	  			XTHDTOAST(LANGUAGE_KEY_UNLOCK)------"关卡未解锁！")
			elseif self.chapterStatus[nowData.instancingid] == 1 then
				local p1 = #self.data.finishEctypes
				local p2 = #self.chapterData
				local ptb = {nowProgress = p1, totleProgress = p2, par = self}
				if not self.data.ectypeType then
					self.data.ectypeType = self.id
				end
				local chapterPop = requires("src/fsgl/layer/ShenQiYiZhi/ShenQiYiZhiPop.lua"):create(nowData["instancingid"],self.data, ptb)
	            self:addChild(chapterPop, 3)
	            chapterPop:show()
			elseif self.chapterStatus[nowData.instancingid] == 2 then
				XTHDTOAST(LANGUAGE_KEY_HASPAST)---------"已过关！")
			end
		end
		chapter:setTouchEndedCallback(touchCall)

		self:getTagSprite(nowData, chapter, touchCall)
    end
    local function pShort( b1, b2)
		return b1:getPositionY() > b2:getPositionY()
	end
	table.sort(pTable, pShort)
	for i = 1, #pTable do
		local pV = pTable[i]
		scrollview:reorderChild(pV, 1)
	end
    pTable = nil
    self.chapterList = chapterList

    for k,v in pairs(chapterList) do
    	if v.unlockid ~= 0 then
    		local unlockid = string.split(v.unlockid,"#")
    		for i=1,#unlockid do
    			local targetChapter = chapterList[tonumber(unlockid[i])]
	    		local posList = self:getPointPos(v:getPositionX(),v:getPositionY(),targetChapter:getPositionX(),targetChapter:getPositionY())
	    		targetChapter.points = targetChapter.points or {}
	    		local tempList = {}
				for k=1,#posList do
					local point = cc.Sprite:create("res/image/plugin/stageChapter/page_dot_selected.png")
					local _tb = string.split(posList[k],",")
					point:setPosition(_tb[1], _tb[2])
					tempList[#tempList+1] = point
					scrollview:addChild(point)
					point:setVisible(false)
				end
				tempList[#tempList+1] = v
				targetChapter.points[#targetChapter.points+1] = tempList
    		end
    	end
    end

    --显示已经完成的关卡
    for i=1,#self.data.finishEctypes do
    	local nowChapter = chapterList[self.data.finishEctypes[i]]
    	nowChapter:setVisible(true)
    	for k,v in pairs(chapterList) do
    		if v.unlockid == nowChapter.id then
    			local targetChapter = v
    			targetChapter:setVisible(true)
    			for j=1,#nowChapter.points do
    				if nowChapter.points[j] then
		    			for k=1,#nowChapter.points[j] do
		    				nowChapter.points[j][k]:setVisible(true)
		    			end
		    		end
    			end
    		end
    	end
    end

	local exitBtn = XTHD.createButton({
		normalNode = cc.Sprite:create("res/image/plugin/saint_beast/tiaozhanchongzhi.png"),
        selectedNode = cc.Sprite:create("res/image/plugin/saint_beast/tiaozhanchongzhiS.png"),
        needSwallow = true,
        enable = true,
        -- text = "退 出",
        endCallback = function ()
	        -- self:openNext()
        	local exitConfirm = XTHDConfirmDialog:createWithParams({
        		msg = LANGUAGE_TIPS_WORDS179,--------"当前副本尚未通关，确认退出吗？退出会重置该副本。",
        		rightCallback = function ()
        			XTHDHttp:requestAsyncInGameWithParams({
        				modules="exitServant?",
		                -- params = {method="exitBeast?"},
		                successCallback = function(data)
			                if tonumber(data.result) == 0 then
			                	-- self:getParent().temp = nil
			                	-- self:getParent()._callFunc()
			                	LayerManager.removeLayout()
			                else
			                    XTHDTOAST(data.msg)
			                end
		                end,--成功回调
		                failedCallback = function()
		                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
		                end,--失败回调
		                targetNeedsToRetain = self,--需要保存引用的目标
		                loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
		            })
        		end
    		})
    		self:addChild(exitConfirm,5)
        	
        end
    })
    exitBtn:setAnchorPoint(0,0)
    exitBtn:setPosition(30,10)
    self:addChild(exitBtn)

    -- local beastData = gameData.getDataFromCSV("SuperWeaponList",{id = self.ectypeType})

    local chapterTitle = cc.Sprite:create("res/image/plugin/saint_beast/1255.png")
    chapterTitle:setAnchorPoint(0,0.5)
    chapterTitle:setPosition(20,self:getBoundingBox().height*0.9)
    self:addChild(chapterTitle)

    local beastNum = math.ceil(self.ectypeType/4)
    local diffNum = math.ceil(self.ectypeType%4 == 0 and 4 or self.ectypeType%4)

    local titleNode0 = cc.Sprite:create("res/image/plugin/saint_beast/wenzi/tar_".. beastNum .. "_0.png")
    titleNode0:setAnchorPoint(0.5,0.5)
    titleNode0:setPosition(30,chapterTitle:getBoundingBox().height*0.5 + 6)
    chapterTitle:addChild(titleNode0)

    local titleNode = cc.Sprite:create("res/image/plugin/saint_beast/wenzi/tar_"..beastNum .. "_" .. diffNum .. ".png")
    titleNode:setAnchorPoint(0,0.5)
    titleNode:setPosition(titleNode0:getPositionX() + titleNode0:getContentSize().width*0.5, chapterTitle:getBoundingBox().height*0.5 + 4)
    chapterTitle:addChild(titleNode)




    self:freshPercentInfo()
end

function ShenQiYiZhiChapterLayer:freshPercentInfo( ... )
	-- local percent = (#self.data.finishEctypes/#self.chapterData)*100
	-- percent = math.floor(percent)
	-- self.loadingBar:setPercentage(percent)
	-- self.percentLabel:setString(percent.."%")
end

function ShenQiYiZhiChapterLayer:openNext(id)
	-- data = {
	--     [1] = 1601,
	--     -- [2] = 1602,
	--     -- [3] = 1603,
	--     -- [4] = 1604,
	--     -- [5] = 1605,
	--     -- [6] = 1607
	-- }

	local openChapter = id
	self.data.finishEctypes[#self.data.finishEctypes+1] = id
	self:analysData(self.data.finishEctypes)

	self:freshPercentInfo()
	
	--获取解锁关卡
	local finishData = gameData.getDataFromCSV("RelicsEnemyList",{instancingid = openChapter})
	if finishData._type == 2 then
		LayerManager:removeLayout()
		return
	end
	local unlockNode = self.chapterList[openChapter]
	-- unlockNode:setTexture(self:getTexture(finishData))
	unlockNode:setStateNormal(cc.Sprite:create(self:getTexture(finishData)))
	if unlockNode.chpTip then
		unlockNode.chpTip:removeFromParent()
		unlockNode.chpTip = nil
	end
	-- unlockNode:setStateSelected(self:getTexture(finishData))
	-- ZCLOG(unlockNode.points)
	unlockNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.25),cc.CallFunc:create(function ()
		if unlockNode.points then
			for i=1,#unlockNode.points do
				local nowPointList = unlockNode.points[i]
				for j=1,#nowPointList do
					local nowPoint = nowPointList[j]
					if nowPoint:isVisible() == false then
						nowPoint:setVisible(true)
						if nowPoint.chpTip then
							nowPoint.chpTip:setVisible(false)
							nowPoint.chpTip:setEnable(false)
						end

						nowPoint:setOpacity(0)
						if j ~= #nowPointList then
							nowPoint:runAction(cc.FadeIn:create(0.1))
						else
							local unlockData = gameData.getDataFromCSV("RelicsEnemyList",{instancingid = nowPoint.id})
							nowPoint:setStateNormal(cc.Sprite:create(self:getTexture(unlockData)))
							-- nowPoint:setStateSelected(self:getTexture(unlockData))
							nowPoint:setEnable(false)
							nowPoint:setScale(0)
							nowPoint:runAction(cc.Sequence:create(
								cc.Spawn:create(
									cc.FadeIn:create(0.1),
									cc.ScaleTo:create(0.15,1.2)
								),
								cc.ScaleTo:create(0.04,0.9),
								cc.ScaleTo:create(0.02,1),
								cc.CallFunc:create(function( ... )
									if nowPoint.chpTip then
										nowPoint.chpTip:setVisible(true)
										nowPoint.chpTip:setPositionY(nowPoint.chpTip:getPositionY() + 80)
										nowPoint.chpTip:runAction(cc.Sequence:create(
											cc.MoveBy:create( 0.08, cc.p(0, -100)),
											cc.MoveBy:create( 0.04, cc.p(0, 40)),
											cc.MoveBy:create( 0.02, cc.p(0, -30)),
											cc.MoveBy:create( 0.01, cc.p(0, 20)),
											cc.MoveBy:create( 0.01, cc.p(0, -10)),
											cc.CallFunc:create(function( ... )
												nowPoint.chpTip:setEnable(true)
												nowPoint:setEnable(true)
											end)
										))
									else
										nowPoint:setEnable(true)
									end
							end)))
						end
						break
					end
				end
			end
		end
	end))))
end

-- function LiLianSaintBeastChapterLayer:tmpList()
-- 	local tmplist = {
-- 		{petId = 1,hp = 0},
-- 		{petId = 8,hp = 0},
-- 		{petId = 9,hp = 0},
-- 		{petId = 4,hp = 0},
-- 		{petId = 5,hp = 0},
-- 		{petId = 12,hp = 0},
-- 		{petId = 15,hp = 0},
-- 		{petId = 17,hp = 0},
-- 		{petId = 29,hp = 0},
-- 		{petId = 31,hp = 0},
-- 		{petId = 32,hp = 0},
-- 		{petId = 37,hp = 0},
-- 		{petId = 40,hp = 0},
-- 	}
-- 	return tmplist
-- end

function ShenQiYiZhiChapterLayer:getPointPos(x1,y1,x2,y2,i,all,list)
	list = list or {}
	i = i or 1
	local Vx = x1-x2
	local Vy = y1-y2
	local Dis = 35
	if not all then
		local allDis = math.sqrt(math.pow(Vx,2)+math.pow(Vy,2))
		all = math.floor(allDis/Dis)
	end

	local n = math.sqrt(math.pow(Dis*i,2)/(math.pow(Vx,2)+math.pow(Vy,2)))

	if i <= all then
		i = i + 1
		list[#list+1] = x2+Vx*n..","..y2+Vy*n
		return self:getPointPos(x1,y1,x2,y2,i,all,list)
	else
		return list
	end
end

function ShenQiYiZhiChapterLayer:create(data,id,callfunc)
	return ShenQiYiZhiChapterLayer.new(data,id,callfunc)
end

return ShenQiYiZhiChapterLayer