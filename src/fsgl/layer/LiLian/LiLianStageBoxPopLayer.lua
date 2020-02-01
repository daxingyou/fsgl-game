--
local LiLianStageBoxPopLayer = class("LiLianStageBoxPopLayer", function()
    return XTHDPopLayer:create({isRemoveLayout = true})
end)

function LiLianStageBoxPopLayer:ctor( params )
	self._parent = params.par
	self.stage_data = params.data
	self._stageType = params.stageType
	self._guideGroup = 0
	self:init()
end

function LiLianStageBoxPopLayer:init( )--在副本里添加了宝箱这个东西 所以弹出界面增加一个类型
	local stage_data = self.stage_data
	local popNode = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")--XTHDImage:create("res/image/plugin/stagepop/pop_bg.png")
	popNode:setContentSize(cc.size(500,300))
	self.popNode = popNode
	popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2 )
	self:addContent(popNode)
	
	local title_bg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 50))
	title_bg:setAnchorPoint(0.5,1)
	title_bg:setPosition(popNode:getContentSize().width/2, popNode:getContentSize().height + 10)
	popNode:addChild(title_bg)

	local stage_name = XTHDLabel:create(stage_data.name,26,"res/fonts/def.ttf")
	local _name_color = cc.c3b(106,36,13)
	-- if self._stageType == ChapterType.ELite then
	-- 	_name_color = cc.c3b(104,195,255)
	-- end
	stage_name:setColor(_name_color)
	stage_name:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2+5)
	title_bg:addChild(stage_name)


	local close_btn = XTHD.createBtnClose(function()
        self:hide()
    end)
    close_btn:setPosition(popNode:getContentSize().width-18, popNode:getContentSize().height-18)
	popNode:addChild(close_btn,2)

	--587*119
	local fall_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	fall_bg:setContentSize(cc.size(470,162))
	fall_bg:setAnchorPoint(0.5,1)
	fall_bg:setPosition(popNode:getContentSize().width / 2,popNode:getContentSize().height -60)
	popNode:addChild(fall_bg)


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
	self.drop_data=fall_items
	local _my_instancing = 1
	if self._stageType == ChapterType.Normal then
		_my_instancing = gameUser.getInstancingId()-- tonumber(userData_table.instancingid)
	elseif self._stageType == ChapterType.ELite then
		_my_instancing = gameUser.getEliteInstancingId()--tonumber(userData_table.eliteinstancingid)
	end
	local size=100
	if  tonumber(#fall_items)>4 then 
		size=90
	end 
	local pos_table=SortPos:sortFromMiddle( cc.p(fall_bg:getContentSize().width/2,fall_bg:getContentSize().height/2), tonumber(#fall_items), size )
	for i,var in ipairs(fall_items) do
		print(i)
		local item_bg=nil
		local items_info=nil 
		if tonumber(stage_data["bossid"]) == -1 then 
			dump(stage_data)
			items_info = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = var[2]} )
			local hero = gameData.getDataFromCSV("GeneralStarId", {configid = var[2]} )
			self._heroDate = hero
			if hero.heroid == nil then
				item_bg = ItemNode:createWithParams({
				itemId =tonumber(var[2]),--items_info["itemid"],
				needSwallow = true,
				_type_ =tonumber(var[1]),
				count=tonumber(var[3])
				})
			else
				item_bg =  ItemNode:createWithParams({
					itemId = hero.heroid,
					_type_ = 50
				})
			end
		end 
		item_bg:setScale(0.9)
		item_bg:setPosition(pos_table[i])
		fall_bg:addChild(item_bg)
		local item_name_label = XTHDLabel:createWithParams({
            text = item_bg._Name,--items_info["name"],
            anchor=cc.p(0.5,1),
            fontSize = 18,--字体大小
            color = cc.c3b(74,34,34),
            pos = cc.p(item_bg:getContentSize().width/2,-2),
        })
        item_bg:addChild(item_name_label)
	end
	local challenge_btn = XTHD.createCommonButton({
			btnColor = "write_1",
			isScrollView = false,
			btnSize = cc.size(200,46),
			text = LANGUAGE_BTN_KEY.getTheRewards,
		})
		challenge_btn:setScale(0.7)
	challenge_btn:setPosition(popNode:getContentSize().width / 2,50)
	popNode:addChild(challenge_btn)
	challenge_btn:setTouchEndedCallback(function ()
		if  tonumber(stage_data["bossid"]) == -1 then
			self:openBoxEvent(stage_data)
		end 
	end)
	self._challeng_btn = challenge_btn

	--通关提示
	local get_rewardlabel=XTHDLabel:createWithParams({text="通关前置关卡可领取奖励!",ttf="",size=20})
	get_rewardlabel:setColor(cc.c3b(131,0,0))
	get_rewardlabel:setPosition(popNode:getContentSize().width / 2,50)
	popNode:addChild(get_rewardlabel)
	get_rewardlabel :setVisible(false)
	if tonumber(stage_data["instancingid"])> _my_instancing +1 then 
		  challenge_btn:setVisible(false)
		  get_rewardlabel:setVisible(true)
	elseif tonumber(stage_data["instancingid"])<= _my_instancing then 
		  challenge_btn:setVisible(false)
		  local already_sp = cc.Sprite:create("res/image/vip/yilingqu.png")
		  already_sp:setAnchorPoint(0.5,0)
		  already_sp:setScale(0.7)
		  already_sp:setPosition(popNode:getContentSize().width/2,30)
		  popNode:addChild(already_sp)
	end	
	self:show()
end

function LiLianStageBoxPopLayer:onEnter()
	--------引导
	YinDaoMarg:getInstance():getACover(self)
	performWithDelay(self,function( )
		YinDaoMarg:getInstance():removeCover(self)
		YinDaoMarg:getInstance():onlyCapter1Guide({ -----第一章的引导 (点击领取)
			parent = cc.Director:getInstance():getRunningScene(),
			target = self._challeng_btn,
		})
	end,0.3)
	--------
end

function LiLianStageBoxPopLayer:onExit( )
end

function LiLianStageBoxPopLayer:openBoxEvent(stage_data)
	if self._stageType == ChapterType.Normal then	
		_modules = "challangeBoxEctype?"
	elseif self._stageType == ChapterType.ELite then
		_modules = "challangeBoxEliteEctype?"
	end

	ClientHttp:requestAsyncInGameWithParams({	
		modules = _modules,
	    params = {ectypeId=stage_data.instancingid},
	    successCallback = function(data)
	    -- dump(data,"领取奖励")
	        if tonumber(data.result) == 0 then
	        	if self._stageType == ChapterType.Normal then	
	        		print("the saved block id is",stage_data.instancingid)
					gameUser.setInstancingId(stage_data.instancingid)
				elseif self._stageType == ChapterType.ELite then
					gameUser.setEliteInstancingId(stage_data.instancingid)
				end
				dump(data,"777777")
	        	local reward_data = self.drop_data
	        	local function ActionCallback()
	        		local show_data = {} 
					for i=1,#reward_data do
						local hero = gameData.getDataFromCSV("GeneralStarId", {configid = reward_data[i][2]} )
						if hero.heroid == nil then
	  						show_data[#show_data+1] = {rewardtype = tonumber(reward_data[i][1]),id=reward_data[i][2],num =  tonumber(reward_data[i][3])}
						else
							show_data[#show_data+1] = {rewardtype = 50,id=hero.heroid,num =  tonumber(reward_data[i][3])}
						end
					end
        			self:hide()
        			print("当前的普通副本id为："..gameUser.getInstancingId())

					ShowRewardNode:createWithParams({
						showData = show_data,
						callback = function()
							XTHD.dispatchEvent({name = "EVENT_LEVEUP", data = {isAfterBox = true}})
						end,
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
			    for i,v in ipairs(self.drop_data) do
	        		if v[1] and tonumber(v[1])==50 then
						local hero = gameData.getDataFromCSV("GeneralStarId", {configid = v[2]} )
        				local layer = requires("src/fsgl/layer/QiXingTan/QiXingTanGetNewHeroLayer.lua"):create({
		        			par = cc.Director:getInstance():getRunningScene(),
           					id = hero.heroid,
            				star = hero.star,
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
	         	XTHDTOAST(data.msg)
	         	-- self:hide()
	        end
	    end,--成功回调
	    failedCallback = function()
	        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
	         -- self:hide()
	    end,--失败回调
	    -- targetNeedsToRetain = self,--需要保存引用的目标
	    loadingParent = self,
	    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end

function LiLianStageBoxPopLayer:ShowRewardList(reward_data,callback)
    local show_data = {}
	for i=1,#reward_data do
	   show_data[#show_data+1] = {rewardtype = tonumber(reward_data[i][1]),id=reward_data[i][2],num =  tonumber(reward_data[i][3])}
	end
	ShowRewardNode:create(show_data,nil,callback)
end

function LiLianStageBoxPopLayer:create( params )
	local layer = LiLianStageBoxPopLayer.new( params )
	return layer
end

function LiLianStageBoxPopLayer:addGuide( )
	-- self._guideGroup = 3
	-- if gameUser.getInstancingId() == 2 then ---第三组引导 
	--     YinDaoMarg:getInstance():addGuide({ --打开宝箱
	--         addToRunning = true,
	--         target = self._challeng_btn,
	--         index = 3,
	-- 		-- needNext = false,
 --            nextSkip2 = {4,2},----跳过点击历练按钮
	--     },3)
	-- elseif gameUser.getInstancingId() == 5 then ---第六组引导 
	--     YinDaoMarg:getInstance():addGuide({ --打开宝箱
	--         addToRunning = true,
	--         target = self._challeng_btn,
	--         index = 3,
	-- 		needNext = false,
	-- 		updateServer = true,
	--     },6)
	-- 	self._guideGroup = 6
	-- elseif gameUser.getInstancingId() == 8 then ---第六组引导 
	--     YinDaoMarg:getInstance():addGuide({ --打开宝箱
	--         addToRunning = true,
	--         target = self._challeng_btn,
	--         index = 5,
	-- 		needNext = false,
	-- 		updateServer = true,
	--     },8)
	-- 	self._guideGroup = 8
	-- end 
 --    performWithDelay(self,function( )    	
	--     YinDaoMarg:getInstance():removeCover(self)
	--     YinDaoMarg:getInstance():doNextGuide()
 --    end,0.3)
end

return LiLianStageBoxPopLayer;