--Created By Liuluyang 2015年05月19日
-- 准备战斗
ShenQiYiZhiPop = class("ShenQiYiZhiPop",function ()
	return XTHDPopLayer:create()
end)

function ShenQiYiZhiPop:ctor(id,data,params)
	self:initUI(id,data,params)
end

function ShenQiYiZhiPop:onCleanup()
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_GODBEAST_CHAPTER)
end

function ShenQiYiZhiPop:initUI(id,data,params)
	local chapterData = gameData.getDataFromCSV("RelicsEnemyList", {["instancingid"] = id})
	local _type = chapterData._type

	local bg = nil
	local bgShadow = nil
	if _type == 4 or _type == 5 then
		bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png" )
    	bg:setContentSize(440,441)
		bgShadow = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
		bgShadow:setContentSize(cc.size(410,287))
		bgShadow:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-60)
	else
		bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png" )
    	bg:setContentSize(442,279)
		bgShadow = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
		bgShadow:setContentSize(cc.size(410,118))
		bgShadow:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-60)
	end
	-- bg:setContentSize(cc.size(453,252))
	bgShadow:setAnchorPoint(0.5,1)
	
	bg:addChild(bgShadow)
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)

	local popTitle = cc.Sprite:create("res/image/plugin/saint_beast/pop_title.png")
	popTitle:setAnchorPoint(0.5,0)
	popTitle:setScale(0.8)
	popTitle:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-30)
	bg:addChild(popTitle)
	
	local chapterName = XTHDLabel:createWithParams({------------------敌人配置
        text = chapterData.chaptername,
        fontSize = 26,
		color = cc.c3b(106,36,13),
		ttf = "res/fonts/def.ttf"
    })
    chapterName:setPosition(popTitle:getContentSize().width/2,popTitle:getContentSize().height/2)
	popTitle:addChild(chapterName)
	--关闭按钮
	local closeBtn = XTHD.createButton({
		normalFile = "res/image/common/btn/btn_red_close_normal.png",
		selectedFile = "res/image/common/btn/btn_red_close_selected.png",
	})
	closeBtn:setScale(0.8)
	closeBtn:setPosition(bg:getContentSize().width-5,bg:getContentSize().height-10)
	closeBtn:setAnchorPoint(0.5,0.5)
	bg:addChild(closeBtn)
	closeBtn:setTouchEndedCallback(function ()
		self:hide()
	end)

	if tonumber(_type) == 3 then
		--宝箱
		local confirmLabel = XTHDLabel:createWithParams({
	        text = LANGUAGE_TIPS_WORDS182,--------"打开后可能获得",
	        fontSize = 20 ,
	        color = cc.c3b(55,54,112),
			ttf = "res/fonts/def.ttf"
	    })
	    confirmLabel:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-42)
	    bg:addChild(confirmLabel)

	    local pId = tonumber(data.ectypeType) or 0
	    local openListData = gameData.getDataFromCSV("ServantOpenList", {id = pId})
	    local rewardList = string.split(openListData.reword,"#")
	    local dropList = gameData.getDataFromCSV("ExploreDropList", {dropid = rewardList[1]})
	    if dropList ~= nil and next(dropList) ~= nil then
		    for i=1, 3 do
		    	if dropList["dropprops" .. i] ~= nil then
			    	local _num = string.split(dropList["dropprops" .. i],"#")[1]
			    	local itemIcon = ItemNode:createWithParams({
			    		_type_ = 4,
			    		itemId = _num
			    	})
			    	itemIcon:setScale(0.85)
			    	itemIcon:setPosition(XTHD.resource.getPosInArr({
			    		lenth = 7,
						bgWidth = bgShadow:getBoundingBox().width,
						num = 3,
						nodeWidth = itemIcon:getBoundingBox().width,
						now = i,
			    	}),bgShadow:getBoundingBox().height/2)
			    	bgShadow:addChild(itemIcon)
			    end
		    end
		end

		local getBtn = XTHD.createCommonButton({
			text =LANGUAGE_BTN_KEY.kaiqibaozang,
			isScrollView = false,
			btnSize = cc.size(130, 49),
			fontSize = 22,
		})
		getBtn:setScale(0.7)
	    getBtn:setPosition(bg:getBoundingBox().width/2,50)
	    bg:addChild(getBtn)
	    getBtn:setTouchEndedCallback(function ()
	    	print("登界游方----------openServantEctypeBox")
	    	XTHDHttp:requestAsyncInGameWithParams({
	    		modules="openServantEctypeBox?",
                params = {ectypeId=id},
                successCallback = function(data)
                if tonumber(data.result) == 0 then
                	local tmpAdd = {}
                	for i=1,#data.addItems do
                		local _tb = string.split(data.addItems[i],",")
                		tmpAdd[_tb[1]] = _tb[2]
                	end
                	if #data.itemReward == 0 then
                		-- XTHDTOAST("然而并没有获得什么东西")
                	else
                		XTHD.saveItem({items = data.itemReward})
                		local showList = {}
	                	for i=1,#data.itemReward do
		                	if data.itemReward[i].position >= 0 then
		                		local tmpList = {
		                			rewardtype = 4,
		                			dbId = data.itemReward[i].dbId,
		                			num = data.itemReward[i].count
			                	}
			                	showList[#showList+1] = tmpList
			                else
			                	local tmpList = {
		                			rewardtype = 4,
		                			dbId = data.itemReward[i].dbId,
		                			num = tmpAdd[tostring(data.itemReward[i].itemId)]
			                	}
			                	-- ZCLOG(data.itemReward[i].itemId)
			                	showList[#showList+1] = tmpList
			                end
	                	end
	                	-- ZCLOG(tmpAdd)
	                	-- ZCLOG(showList)
	                	ShowRewardNode:create(showList)
                	end
                	if self:getParent() and self:getParent().refreshMap then
	                	self:getParent():refreshMap(id)
	                end
                	self:removeFromParent()
                else
                    XTHDTOAST(data.msg)
                end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
	    end)
    elseif tonumber(_type) == 1 or tonumber(_type) == 2 then
    	--战斗
    	local _copyData = clone(data.hps)
    	local selectData = {
    		players = _copyData.petHps
		}
    	local hpData = nil

    	for i=1,#_copyData.monsterHps do
    		if _copyData.monsterHps[i].ectypeId == id then
    			-- data.hps.monsterHps[i].hp[1].petId = data.hps.monsterHps[i].hp[1].petId
    			-- hpData = data.hps.monsterHps[i].hp
    			hpData = _copyData.monsterHps[i]["hp"]

    			-- print("测试用： 怪物血量");
    			-- ZCLOG(hpData)
    		end
    	end
    
    	hpData = hpData or {}
    	for i=1,#hpData do
    		-- ZCLOG(chapterData)
    		local EnemyIcon = HeroNode:createWithParams({
    			heroid = hpData[i].heroId,
    			needHp = true,
    			isHero = true,
    			level = tonumber(hpData[i].level) or 0,
    			-- percent = (hpData[i].hp / enemyData.hp) * 100
    			curNum = hpData[i].hp,
    			maxNum = hpData[i].maxHp
			})
			local pCover = tonumber(chapterData.ishprecover) or 0
			if pCover ~= 0 then
				local _now = EnemyIcon:getHp()
				if _now ~= 0 then
					local _maxHp = EnemyIcon:getMaxHp()
					local pNum = _now + _maxHp*pCover*0.01
					pNum = pNum > _maxHp and _maxHp or pNum
					hpData[i].hp = pNum
					EnemyIcon:setHp(pNum, nil , false)
				end
			end

			EnemyIcon:setScale(0.75)
			EnemyIcon:setPosition(XTHD.resource.getPosInArr({
				lenth = 5,
				bgWidth = bgShadow:getBoundingBox().width,
				num = #hpData,
				nodeWidth = EnemyIcon:getBoundingBox().width,
				now = i
			}),bgShadow:getBoundingBox().height/2)
			bgShadow:addChild(EnemyIcon)
    	end

    	selectData.enemys = hpData

    	local function goSelectHero( ... )
    		 XTHD.addEventListener({
		        name = CUSTOM_EVENT.REFRESH_GODBEAST_CHAPTER,
		        callback = function (event)
			        local par = self:getParent()
	  				event.data.data.finishEctypes = data.finishEctypes
		        	par:refreshData(event.data.data)
	  				self:removeFromParent()
		        	if(event.data.isWin) then
			        	par:refreshMap(id)
			        end
		        end
		    })
        	--再次接入选将界面 for yanyuling
        	--设置成神兽副本
        	LayerManager.addShieldLayout()
			local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongCopyLayer.lua"):createWithParams({
	  			battle_type	=BattleType.SERVANT_PVE,
	  			instancingid	=id,
	  			godBeast_data	= {
			  			["hps"] = selectData,
			  			["hprecover"] = chapterData.hprecover, 
			  			["refreshFunc"] = function(battleData)
				  			if _type == 2 and params.par then
			  					params.par:removeFromParent()
				  			end
			  				-- self:getParent():refreshMap(id)
			  				-- self:removeFromParent()
			  			end,
		  			}
	  			})
			fnMyPushScene(_layer)
    	end


		local attackBtn = XTHD.createButton({
			normalFile = "res/image/common/btn/zbzd_up.png",
			selectedFile = "res/image/common/btn/zbzd_down.png",
		
		--local attackBtn = XTHD.createCommonButton({
			-- btnColor = "blue",
			-- text = LANGUAGE_BTN_KEY.zhunbeizhandou,
			-- fontSize = 20,
			--btnSize = cc.size(130, 49),
	        endCallback = function ()
	            print("登界游方开始挑战-----------------")
	        	if _type == 2 and (params.totleProgress - params.nowProgress) ~= 1 then
		        	local exitConfirm = XTHDConfirmDialog:createWithParams({
		        		msg = LANGUAGE_TIPS_WORDS183,-------"你正在挑战BOSS关卡，获得胜利后将直接完成副本，无法继续探索该副本。是否确定开始挑战？",
		        		rightCallback = function ()
			        		performWithDelay(self, function ( ... )
			        			goSelectHero()
			        		end, 0.2)
		        			
		        		end
		    		})
		    		self:addChild(exitConfirm, 5)
	        	else
	        		goSelectHero()
	        	end
	        end
		})
		--attackBtn:getLabel():setPositionX(attackBtn:getLabel():getPositionX()-15)
		--attackBtn:getLabel():setPositionY(attackBtn:getLabel():getPositionY()-10)
	    attackBtn:setPosition(bg:getBoundingBox().width/2 + 6,66)
	    bg:addChild(attackBtn)

    elseif tonumber(_type) == 4 then
    	--治疗
    	local split = cc.Sprite:create("res/image/plugin/stageChapter/split.png")
		split:setPosition(bg:getBoundingBox().width/2,120)
		bg:addChild(split)
		split:setVisible(false)
    	-- ZCLOG(data.hps.petHps)
    	local healList = {}

    	for i=1,#data.hps.petHps do
    		local nowHero = data.hps.petHps[i]
    		local heroData = gameData.getDataFromDynamicDB(gameUser.getUserId(), "hero", {heroid = nowHero.petId})
    		if tonumber(nowHero.hp) ~= tonumber(heroData.hp) and tonumber(nowHero.hp) > 0 then
    			local tmplist = {
    				heroid = nowHero.petId,
    				cur = nowHero.hp,
    				max = heroData.hp
				}
				healList[#healList+1] = tmplist
    		end
    	end

    	local healBtn = XTHD.createCommonButton({
			text = LANGUAGE_BTN_KEY.lijizhiliao,
			isScrollView = false,
			fontSize = 22,
			btnSize = cc.size(130, 49),
	    })
	    healBtn:setPosition(bg:getBoundingBox().width/2+80,37.5+8)
	    bg:addChild(healBtn)
		healBtn:setScale(0.8)
	    healBtn:setTouchEndedCallback(function ()
	    	XTHDHttp:requestAsyncInGameWithParams({
	    		modules="servantEctypeZhiliao?",
                params = {ectypeId=id,petId=self.selectedId},
                successCallback = function(healData)
                if tonumber(healData.result) == 0 then
                	self.allHero[self.selectedId]:setHp(healData.curHp)
                	gameUser.setGold(healData.gold)
                	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) 
                	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
                	for k,v in pairs(data.hps.petHps) do
                    	if v.petId == self.selectedId then
                    		v.hp = healData.curHp
                    	end
                    end
                	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
                		self:getParent():refreshData(data)
                		self:getParent():refreshMap(id)
	                	self:removeFromParent()
                	end)))
                else
                    XTHDTOAST(healData.msg or LANGUAGE_TIPS_WEBERROR)------ "网络请求失败")
                end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
	    end)

	    local noHealBtn = XTHD.createCommonButton({
	    	btnColor = "write",
			text = LANGUAGE_BTN_KEY.fangqizhiliao,
			isScrollView = false,
			fontSize = 22,
			btnSize = cc.size(130, 49),
	        endCallback = function ()
	        	XTHDHttp:requestAsyncInGameWithParams({
	        		modules="servantEctypeZhiliao?",
	                params = {ectypeId=id,petId=-1},
	                successCallback = function(healData)
	                if tonumber(healData.result) == 0 then
	                    self:getParent():refreshMap(id)
	                	self:removeFromParent()
	                else
	                    XTHDTOAST(healData.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
	                end
	                end,--成功回调
	                failedCallback = function()
	                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
	                end,--失败回调
	                targetNeedsToRetain = self,--需要保存引用的目标
	                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	            })
	        end
		})
		noHealBtn:setScale(0.8)
	    noHealBtn:setPosition(bg:getBoundingBox().width/2-80,37.5+8)
	    bg:addChild(noHealBtn)

	    local needMoneyLabel = XTHDLabel:createWithParams({
	        text = LANGUAGE_TIPS_WORDS184,------"选择你要治疗的目标：",
	        fontSize = 18 ,
	        color = XTHD.resource.color.gray_desc
	    })
	    needMoneyLabel:setAnchorPoint(0,0.5)
	    needMoneyLabel:setPosition(20,bg:getBoundingBox().height-42)
	    bg:addChild(needMoneyLabel)

	    local MoneyIcon = XTHD.createHeaderIcon(XTHD.resource.type.gold)
	    MoneyIcon:setAnchorPoint(0,0.5)
	    MoneyIcon:setPosition(needMoneyLabel:getPositionX()+needMoneyLabel:getBoundingBox().width,needMoneyLabel:getPositionY())
	    bg:addChild(MoneyIcon)
	    MoneyIcon:setVisible(false)

    	local needMoney = getCommonWhiteBMFontLabel("")
    	-- XTHDLabel:createWithParams({
	    --     text = "",
	    --     fontSize = 22,
	    --     color = cc.c3b(237, 232, 193)
	    -- })
	    needMoney:setAnchorPoint(0,0.5)
	    needMoney:setPosition(MoneyIcon:getPositionX()+MoneyIcon:getBoundingBox().width/2+15,MoneyIcon:getPositionY()-7)
	    bg:addChild(needMoney)

    	if #healList == 0 then
    		local noHero = XTHDLabel:createWithParams({
		        text = LANGUAGE_TIPS_WORDS185,-------"没有需要治疗的英雄",
		        fontSize = 24,
		        color = cc.c3b(237, 232, 193)
		    })
		    noHero:setPosition(bg:getBoundingBox().width/2,280)
		    bg:addChild(noHero)
		    noHealBtn:setPosition(bg:getBoundingBox().width/2,37.5+8)
		    healBtn:setVisible(false)
    	else
    		MoneyIcon:setVisible(true)
    		self.selectedId = healList[1].heroid
    		self.heroList = {}
    		self.allHero = {}
    		self._healTable = cc.TableView:create(cc.size(bgShadow:getBoundingBox().width,bgShadow:getBoundingBox().height-10))--761
		    self._healTable:setPosition(35 ,0)
		    self._healTable:setInertia(true) --设置惯性
		    self._healTable:setBounceable(true)
		    self._healTable:setDirection(zctech.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
		    self._healTable:setDelegate()
		    self._healTable:setVerticalFillOrder(zctech.TABLEVIEW_FILL_TOPDOWN)
		    bgShadow:addChild(self._healTable)

		    local function cellSizeForTable(table,idx)
		        return 80,bgShadow:getBoundingBox().width -- 68
		    end

		    local function numberOfCellsInTableView(table)
		        return math.ceil(#healList/5)
		    end

		    local function tableCellTouched(table,cell)
		    end

		    local function tableCellAtIndex(table1,idx)
		    	local cell = table1:dequeueCell()
		        if cell == nil then
		            cell = cc.TableViewCell:new()
		        else
		            cell:removeAllChildren()
		        end

		        for i=1,5 do
		        	if idx*5+i <= #healList then
		        		local listData = healList[idx*5+i]
		        		local heroIcon = HeroNode:createWithParams({
		        			heroid = listData.heroid,
		        			curNum = listData.cur,
		        			-- maxNum = listData.max,
		        			needHp = true,
		        			needSwallow = false,
		        		})
		        		heroIcon:setScale(0.75)
		        		heroIcon:setTouchSize(cc.size(heroIcon:getBoundingBox().width*0.8,heroIcon:getBoundingBox().height*0.8))
		        		heroIcon:setPosition(XTHD.resource.getPosInArr({
		        			lenth = 9,
		        			bgWidth = bgShadow:getBoundingBox().width,
		        			num = 5,
		        			nodeWidth = heroIcon:getBoundingBox().width,
		        			now = i
	        			}),80/2)
		        		cell:addChild(heroIcon)
		        		self.allHero[listData.heroid] = heroIcon
		        		local selectedBg = cc.Sprite:create("res/image/common/item_select_box.png")
		        		selectedBg:setScale(0.85)
		        		selectedBg:setPosition(heroIcon:getPositionX(),heroIcon:getPositionY())
		        		cell:addChild(selectedBg)
		        		if self.selectedId ~= listData.heroid then
			        		selectedBg:setVisible(false)
			        	end

			        	self.heroList[idx*5+i] = selectedBg

			        	if needMoney:getString() == "" then
		        			local pNum = math.modf((heroIcon:getMaxHp()-heroIcon:getHp())*0.1)
		        			needMoney:setString(pNum)
			        	end

		        		heroIcon:setTouchEndedCallback(function ()
		        			for i=1,#self.heroList do
		        				local heroIdx = i%5 == 0 and math.floor(i/5)-1 or math.floor(i/5)
		        				if self._healTable:cellAtIndex(heroIdx) then
		        					self.heroList[i]:setVisible(false)
		        				end
		        			end
		        			selectedBg:setVisible(true)
		        			self.selectedId = listData.heroid
		        			local pNum = math.modf((heroIcon:getMaxHp()-heroIcon:getHp())*0.1)
		        			needMoney:setString(pNum)
		        			-- heroIcon:setHpByPercent(100)
		        		end)
		        	end
		        end

		        return cell
		    end

		    self._healTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
		    self._healTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
		    self._healTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
		    self._healTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
		    self._healTable:reloadData()
    	end

    elseif tonumber(_type) == 5 then

    	local healList = {}

    	for i=1,#data.hps.petHps do
    		local nowHero = data.hps.petHps[i]
    		local heroData = gameData.getDataFromDynamicDB(gameUser.getUserId(), "hero", {heroid = nowHero.petId})
    		if tonumber(nowHero.hp) <= 0 then
    			local tmplist = {
    				heroid = nowHero.petId,
    				cur = nowHero.hp,
    				max = heroData.hp
				}
				healList[#healList+1] = tmplist
    		end
    	end

    	local healBtn = XTHD.createCommonButton({
			text = LANGUAGE_BTN_KEY.lijifuhuo,
			isScrollView = false,
			fontSize = 22,
			btnSize = cc.size(130, 49),
	    })
	    healBtn:setPosition(bg:getBoundingBox().width/2+80,37.5+8)
	    bg:addChild(healBtn)
		healBtn:setScale(0.8)
	    healBtn:setTouchEndedCallback(function ()
	    	XTHDHttp:requestAsyncInGameWithParams({
	    		modules="servantEctypeRevive?",
                params = {ectypeId=id,petId=self.selectedId},
                successCallback = function(ReviveData)
                if tonumber(ReviveData.result) == 0 then
                    self.allHero[self.selectedId]:setHp(ReviveData.curHp)
                	gameUser.setGold(ReviveData.gold)
                	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) 
                	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
                    for k,v in pairs(data.hps.petHps) do
                    	if v.petId == self.selectedId then
                    		v.hp = ReviveData.curHp
                    	end
                    end
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
                    	self:getParent():refreshData(data)
                    	self:getParent():refreshMap(id)
	                	self:removeFromParent()
                    end)))
                else
                    XTHDTOAST(ReviveData.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
                end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
	    end)

	    local noHealBtn = XTHD.createCommonButton({
			btnColor = "write_1",
			isScrollView = false,
			text = LANGUAGE_BTN_KEY.fangqifuhuo,
			fontSize = 22,
			btnSize = cc.size(130, 49),
	        endCallback = function ()
	        	XTHDHttp:requestAsyncInGameWithParams({
	        		modules="servantEctypeRevive?",
	                params = {ectypeId=id,petId=-1},
	                successCallback = function(ReviveData)
	                if tonumber(ReviveData.result) == 0 then
	                    self:getParent():refreshMap(id)
	                	self:removeFromParent()
	                else
	                    XTHDTOAST(ReviveData.msg or LANGUAGE_TIPS_WEBERROR)-------"网络请求失败")
	                end
	                end,--成功回调
	                failedCallback = function()
	                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
	                end,--失败回调
	                targetNeedsToRetain = self,--需要保存引用的目标
	                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	            })
	        end
		})
		noHealBtn:setScale(0.8)
	    noHealBtn:setPosition(bg:getBoundingBox().width/2-80,37.5+8+10)
	    bg:addChild(noHealBtn)

	    local needMoneyLabel = XTHDLabel:createWithParams({
	        text = LANGUAGE_TIPS_WORDS186,-------"选择你要复活的目标：",
	        fontSize = 18 ,
	        color = XTHD.resource.color.gray_desc
	    })
	    needMoneyLabel:setAnchorPoint(0,0.5)
	    needMoneyLabel:setPosition(20,bg:getBoundingBox().height-42)
	    bg:addChild(needMoneyLabel)

	    local MoneyIcon = XTHD.createHeaderIcon(XTHD.resource.type.gold)
	    MoneyIcon:setAnchorPoint(0,0.5)
	    MoneyIcon:setPosition(needMoneyLabel:getPositionX()+needMoneyLabel:getBoundingBox().width,needMoneyLabel:getPositionY())
	    bg:addChild(MoneyIcon)
	    MoneyIcon:setVisible(false)

    	local needMoney = getCommonWhiteBMFontLabel("")
	    needMoney:setAnchorPoint(0,0.5)
	    needMoney:setPosition(MoneyIcon:getPositionX()+MoneyIcon:getBoundingBox().width/2+10,MoneyIcon:getPositionY()-7)
	    bg:addChild(needMoney)

    	if #healList == 0 then
    		local noHero = XTHDLabel:createWithParams({
		        text = LANGUAGE_TIPS_WORDS187,-------"没有需要复活的英雄：",
		        fontSize = 22,
		        color = cc.c3b(237, 232, 193)
		    })
		    noHero:setPosition(bg:getBoundingBox().width/2,250)
		    healBtn:setVisible(false)
		    noHealBtn:setPosition(bg:getBoundingBox().width/2,37.5+8)
		    bg:addChild(noHero)
    	else
    		MoneyIcon:setVisible(true)
    		self.selectedId = healList[1].heroid
    		self.heroList = {}
    		self.allHero = {}
    		self._healTable = cc.TableView:create(cc.size(bgShadow:getBoundingBox().width,bgShadow:getBoundingBox().height))--761
		    self._healTable:setPosition(0 ,1)
		    self._healTable:setInertia(true) --设置惯性
		    self._healTable:setBounceable(true)
		    self._healTable:setDirection(zctech.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
		    self._healTable:setDelegate()
		    self._healTable:setVerticalFillOrder(zctech.TABLEVIEW_FILL_TOPDOWN)
		    bgShadow:addChild(self._healTable)

		    local function cellSizeForTable(table,idx)
		        return 80,bgShadow:getBoundingBox().width -- 68
		    end

		    local function numberOfCellsInTableView(table)
		        return math.ceil(#healList/5)
		    end

		    local function tableCellTouched(table,cell)
		    end

		    local function tableCellAtIndex(table1,idx)
		    	local cell = table1:dequeueCell()
		        if cell == nil then
		            cell = cc.TableViewCell:new()
		        else
		            cell:removeAllChildren()
		        end

		        for i=1,5 do
		        	if idx*5+i <= #healList then
		        		local listData = healList[idx*5+i]
		        		local heroIcon = HeroNode:createWithParams({
		        			heroid = listData.heroid,
		        			curNum = listData.cur,
		        			-- maxNum = listData.max,
		        			needHp = true,
		        			needSwallow = false,
		        		})
		        		heroIcon:setScale(0.75)
		        		heroIcon:setTouchSize(cc.size(heroIcon:getBoundingBox().width*0.8,heroIcon:getBoundingBox().height*0.8))
		        		heroIcon:setPosition(XTHD.resource.getPosInArr({
		        			lenth = 9,
		        			bgWidth = bgShadow:getBoundingBox().width,
		        			num = 5,
		        			nodeWidth = heroIcon:getBoundingBox().width,
		        			now = i
	        			}),80/2)
		        		cell:addChild(heroIcon)
		        		self.allHero[listData.heroid] = heroIcon
		        		local selectedBg = cc.Sprite:create("res/image/common/item_select_box.png")
		        		selectedBg:setScale(0.85)
		        		selectedBg:setPosition(heroIcon:getPositionX(),heroIcon:getPositionY())
		        		cell:addChild(selectedBg)
		        		if self.selectedId ~= listData.heroid then
			        		selectedBg:setVisible(false)
			        	end

			        	self.heroList[idx*5+i] = selectedBg

			        	if needMoney:getString() == "" then
		        			local pNum = math.modf(heroIcon:getMaxHp()*0.1)
			        		needMoney:setString(pNum)
			        	end

		        		heroIcon:setTouchEndedCallback(function ()
		        			for i=1,#self.heroList do
		        				local heroIdx = i%5 == 0 and math.floor(i/5)-1 or math.floor(i/5)
		        				if self._healTable:cellAtIndex(heroIdx) then
		        					self.heroList[i]:setVisible(false)
		        				end
		        			end
		        			selectedBg:setVisible(true)
		        			self.selectedId = listData.heroid
		        			local pNum = math.modf(heroIcon:getMaxHp()*0.1)
		        			needMoney:setString(pNum)
		        			-- heroIcon:setHpByPercent(100)
		        		end)
		        	end
		        end

		        return cell
		    end

		    self._healTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
		    self._healTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
		    self._healTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
		    self._healTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
		    self._healTable:reloadData()
    	end
	end

end

function ShenQiYiZhiPop:create(id,data, params)
	return ShenQiYiZhiPop.new(id,data, params)
end

return ShenQiYiZhiPop