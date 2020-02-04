local TAG = "LiLianReceiveBoxReward"

local LiLianReceiveBoxReward = class("LiLianReceiveBoxReward", function()
	return XTHDPopLayer:create()
end)

function LiLianReceiveBoxReward:ctor( sParams )
	local params = sParams or {}
 	self.get_state={}
 	local _modules="ectypeBoxList?"
 	if params.instancint_type == ChapterType.Normal then	
	 	_modules = "ectypeBoxList?"
	else
		_modules = "eliteEctypeBoxList?"
	end
	ClientHttp:requestAsyncInGameWithParams({
        modules =_modules,
        params={chapterId=params.chapterid},
        successCallback = function(data)
	        if tonumber(data.result) == 0 then
	        	YinDaoMarg:getInstance():releaseGuideLayer()
				self.get_state=data.list
				self:initUI(params)
	        else
        		YinDaoMarg:getInstance():tryReguide() -----引导在上个页面
	            XTHDTOAST(data.msg)
	        end
        end,--成功回调
        failedCallback = function()
        	YinDaoMarg:getInstance():tryReguide() -----引导在上个页面
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
           -- self:removeFromParent()
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end

function LiLianReceiveBoxReward:onCleanup( )
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey("res/image/plugin/stageChapter/sweep_bg.png")

end

function LiLianReceiveBoxReward:initUI(params)
	self:setColor(cc.c3b(0,0,0))
	self:setOpacity(100)
	--initUI 
	local bg_sp = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create("res/image/plugin/stageChapter/sweep_bg.png")
	})
	bg_sp:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self:addContent(bg_sp)
	self.popNode = bg_sp
	local back_label=XTHDLabel:createWithParams({text=LANGUAGE_KEY_CLICKSCENEEXIT,ttf="",size=18})
	back_label:setColor(cc.c3b(204,115,69))
	back_label:setPosition(bg_sp:getContentSize().width/2,-20)
	bg_sp:addChild(back_label)
	local widthsize=bg_sp:getContentSize().width/2-30

	local pNum = tonumber(params.totalstar)-tonumber(params.getstar)
	if pNum > 0 then
		local star_num=XTHDLabel:createWithParams({text=pNum,ttf="",size=22})
		star_num:setAnchorPoint(1,0.5)
		star_num:setPosition(widthsize,250)
		bg_sp:addChild(star_num)
		
		local star_sp=cc.Sprite:create("res/image/plugin/stageChapter/starbox_star2.png")
		star_sp:setAnchorPoint(0,0.5)
		star_sp:setPosition(widthsize,250)
		bg_sp:addChild(star_sp)

		local title_left=cc.Sprite:create("res/image/plugin/stageChapter/reward_left.png")
		title_left:setAnchorPoint(1,0.5)
		title_left:setPosition(star_num:getPositionX()-star_num:getContentSize().width,250)
		bg_sp:addChild(title_left)

		local title_right=cc.Sprite:create("res/image/plugin/stageChapter/reward_right.png")
		title_right:setAnchorPoint(0,0.5)
		title_right:setPosition(star_sp:getPositionX()+star_sp:getContentSize().width,250)
		bg_sp:addChild(title_right)
	else
		local title_get = cc.Sprite:create("res/image/plugin/stageChapter/reward_allGet.png")
		title_get:setPosition(widthsize + 30,250)
		bg_sp:addChild(title_get)
	end

    local _per_star_num = tonumber(params.totalstar)/tonumber(params.prizecount)

    for i=1,1 do --tonumber(params.prizecount) do

    	local _pre_num = tonumber(params.getstar)
    	local _cout_color = cc.c3b(255,255,255)
    	if _pre_num >= _per_star_num*i then
    		_pre_num = _per_star_num*i
    		 _cout_color = cc.c3b(0,255,0)
    	end

    	local key  = "prizeitemsid"..tostring(i)
		local _reward_ = params["chapter_reward"][key]
		local _reward_item = string.split(_reward_, '#')
		-- local _reward_str = "打开这个宝箱可以获得"
		local _reward_prize = {}
		local pLength = #_reward_item or 0
		local pos_table = SortPos:sortFromMiddle(
			cc.p(bg_sp:getContentSize().width/2, bg_sp:getContentSize().height/2-23), 
			tonumber(#_reward_item), 
			110
		)

		for k=1,pLength do
			local _item_data = string.split(_reward_item[k], ',')
			local _static_data =  gameData.getDataFromCSV( "ArticleInfoSheet",{itemid=_item_data[2]})
			-- local _item_name = _static_data["name"] or LANGUAGE_KEY_COIN ---------"元宝";
			_reward_prize[#_reward_prize+1]=_item_data

			local reward_item = ItemNode:createWithParams({
					_type_ = tonumber(_item_data[1]),
					itemId = _item_data[2], 
					needSwallow = true,
					isShowCount = true,
					count = _item_data[3]
				})
			reward_item:setScale(0.8)
			reward_item:setAnchorPoint(0.5,0.5)
			reward_item:setPosition(pos_table[k])
			bg_sp:addChild(reward_item)
			local _item_name = reward_item._Name
			local item_name_label = XTHDLabel:createWithParams({
	            text = _item_name,
	            anchor=cc.p(0.5,1),
	            fontSize = 22,--字体大小
	            color = cc.c3b(227,184,10),
	            pos = cc.p(reward_item:getContentSize().width/2,-2),
            })
            reward_item:addChild(item_name_label)
			item_name_label:enableBold()
		end

		local receive_statuus = 0 --领取状态
		for k=1,#self.get_state do
			if tonumber(self.get_state[1]) and _pre_num >= tonumber(self.get_state[1]) then
				receive_statuus = 1 --已领取 状态
			end
		end

		local _star_bg_pos = nil
		if receive_statuus == 1 then
			local already_sp = cc.Sprite:create("res/image/vip/yilingqu.png")
			already_sp:setAnchorPoint(0.5,0)
			already_sp:setPosition(bg_sp:getContentSize().width/2,20)
			bg_sp:addChild(already_sp)
			 
		else         	
			local _normalNode = nil
			local _selectedNode = nil
			local _label = nil
			local _callback = nil
			_normalNode = cc.Sprite:create("res/image/common/btn/btn_guild_normal.png")
			_selectedNode = cc.Sprite:create("res/image/common/btn/btn_guild_selected.png")
			if pNum > 0 then
				_label = XTHD.resource.getButtonImgTxt("weidacheng_hong")
				XTHD.setGray(_normalNode, true)
				XTHD.setGray(_selectedNode, true)
				XTHD.setGray(_label, true)
			else
				_label = XTHD.resource.getButtonImgTxt("lingqujiangli_lv")
			end

			local collect_btn = XTHDPushButton:createWithParams({
				normalNode    = _normalNode,
				selectedNode = _selectedNode,
				musicFile = XTHD.resource.music.effect_btn_common,
				label = _label,
				anchor = cc.p(0.5,0),
				pos = cc.p(bg_sp:getContentSize().width/2,20),
			})
			collect_btn._reward_prize = _reward_prize
			collect_btn._star_cout = _per_star_num*i
			
			bg_sp:addChild(collect_btn)
			self._guideCollectBtn = collect_btn 
			--------引导
			YinDaoMarg:getInstance():getACover(self)
			self:addGuide()
			--------
        	if receive_statuus == 2 then
        		collect_btn:setTouchEndedCallback(function()
					-----引导
					YinDaoMarg:getInstance():guideTouchEnd() 
					YinDaoMarg:getInstance():releaseGuideLayer()
					--------------------------------------------------
        			XTHDTOAST(LANGUAGE_TIPS_WORDS177)--------"您当前不满足领取条件!")
        		end)
			elseif receive_statuus == 0 then
				collect_btn:setTouchEndedCallback(function()
					-----引导
					YinDaoMarg:getInstance():guideTouchEnd() 
					--------------------------------------------------
					if pNum > 0 then
						YinDaoMarg:getInstance():releaseGuideLayer()
						XTHDTOAST(LANGUAGE_TIPS_WORDS177)
						return
					end
					if collect_btn.get_type and collect_btn.get_type == LANGUAGE_ADJ.unreachable then --------"未达成" then
						YinDaoMarg:getInstance():releaseGuideLayer()
						XTHDTOAST(LANGUAGE_TIPS_WORDS177)------"您当前不满足领取条件!")
						return
					elseif collect_btn.get_type and collect_btn.get_type == LANGUAGE_ADJ.hasGet then ------"已领取" then
						YinDaoMarg:getInstance():releaseGuideLayer()
						XTHDTOAST(LANGUAGE_TIPS_WORDS235)-------"您已领取该星级对应奖励!")
						return
					end
					 local _modules = "getBox?"
					 if params.instancint_type == ChapterType.Normal then	
					 	_modules = "getBox?"
					else
						_modules = "eliteBoxReward?"
					end
					ClientHttp:requestAsyncInGameWithParams({
		                modules = _modules,
				        params = {groupId=params.chapterid,star=collect_btn._star_cout},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
				        successCallback = function(data)
					        if tonumber(data.result) == 0 then
					        	YinDaoMarg:getInstance():releaseGuideLayer()
					        	--领取成功之后，先存储领取状态，刷新数据，然后再做展示操作
								CopiesData.changeCopiesReward(params.chapterid, data.star, params.instancint_type)
						    	--领取之后添加已领取提示
						        collect_btn:setVisible(false)

						        local already_sp = cc.Sprite:create("res/image/vip/yilingqu.png")
								already_sp:setAnchorPoint(0.5,0)
								already_sp:setPosition(bg_sp:getContentSize().width/2,20)
								bg_sp:addChild(already_sp)
								
						    	--更新数据库数量
					        	for i=1,#data.items do
					        	 	local _tmp_data = data.items[i]
					        	 	_tmp_data["dbid"] = _tmp_data["dbId"]
									 DBTableItem.updateCount(gameUser.getUserId(),_tmp_data,  _tmp_data["dbid"]  )
					        	end
					        	if data["ingot"] then
						        	gameUser.setIngot(tonumber(data["ingot"]))
					        	end
					        	if data["gold"] then
					        		gameUser.setGold(data.gold)
					        	end
					        	if data["feicui"] then
					        		gameUser.setFeicui(data.feicui)
					        	end
					        	if data["smeltPoint"] then
					        		gameUser.setSmeltPoint(data.smeltPoint)
					        	end
				        		-- 更新属性
								if data.property and #data.property > 0 then
							        for i=1, #data.property do
							            local pro_data = string.split( data.property[i], ',' )
							            DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
							        end
							    end
					        	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
								XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})

								--
					        	if params.callback and type(params.callback) == "function" then
					        		params.callback(data)
					        	else
					        	 	if self:getParent() then
						        		self:getParent():ConstructBoxData()
						        	end
					        	end
					        	self:ShowRewardList( collect_btn._reward_prize)
					        	self:removeFromParent()
					        else
					        	YinDaoMarg:getInstance():tryReguide()
			                    XTHDTOAST(data.msg)
					        end
				        end,--成功回调
				        failedCallback = function()
					        YinDaoMarg:getInstance():tryReguide()
				            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
				        end,--失败回调
				        targetNeedsToRetain = self,--需要保存引用的目标
				        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
					})
				end)
			end
    	end   	 
	end
	self:show()
end

function LiLianReceiveBoxReward:ShowRewardList(reward_data)
    local show_data = {}
	for i=1,#reward_data do
	   show_data[#show_data+1] = {rewardtype = tonumber(reward_data[i][1]),id=reward_data[i][2],num =  tonumber(reward_data[i][3])}
	end
	ShowRewardNode:create(show_data,nil,function( )
	    YinDaoMarg:getInstance():doNextGuide()
	end)
end

function LiLianReceiveBoxReward:create(params)
	local dialog = self.new(params)
	 return dialog
end

function LiLianReceiveBoxReward:onEnter( )
end

function LiLianReceiveBoxReward:onExit( )
	YinDaoMarg:getInstance():removeCover(self)
end

function LiLianReceiveBoxReward:addGuide( )
	YinDaoMarg:getInstance():addGuide({ ---返回 
        parent = self,
        target = self._guideCollectBtn,
        index = 5,
		needNext = false,	
		updateServer = true,			
    },3)
    performWithDelay(self,function( )    	
	    YinDaoMarg:getInstance():removeCover(self)
	    YinDaoMarg:getInstance():doNextGuide()
    end,0.3)
end

return LiLianReceiveBoxReward
