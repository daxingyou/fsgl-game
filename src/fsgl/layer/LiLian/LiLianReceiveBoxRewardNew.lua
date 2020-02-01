local TAG = "LiLianReceiveBoxReward"

local LiLianReceiveBoxReward = class("LiLianReceiveBoxReward", function()
	return XTHDPopLayer:create()
end)

function LiLianReceiveBoxReward:ctor( sParams )
	local params = sParams or {}
 	self.get_state={}
 	local _modules="diffcultyEctypeBoxList?" --宝箱列表请求

	ClientHttp:requestAsyncInGameWithParams({
        modules =_modules,
        params={chapterId=params.chapterid},
        successCallback = function(data)
	        if tonumber(data.result) == 0 then
				self.get_state=data.list
				--计算领取状态
				local _canGetNum = math.floor(tonumber(sParams.getstar)/(tonumber(sParams.totalstar)/tonumber(sParams.prizecount))) --可领取奖励个数

				self._rewardState = { --可领取或者未领取状态
					[1] = true,
					[2] = true,
					[3] = true,
				}
				for k,v in pairs(data.list) do --调整已经领取状态
					if tonumber(v) == 10 then
						self._rewardState[1] = false
					elseif tonumber(v) == 20 then
						self._rewardState[2] = false
					elseif tonumber(v) == 30 then
						self._rewardState[3] = false
					end
				end

				table.sort(self.get_state, function(a, b) return a < b  end )
				self:initUI(params)
	        else
	            XTHDTOAST(data.msg)
	        end
        end,--成功回调
        failedCallback = function()
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
	-- dump(params)
	self:setColor(cc.c3b(0,0,0))
	self:setOpacity(100)



	--initUI 
	local bg_sp = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create("res/image/plugin/stageChapter/sweep_bg.png")
	})
	bg_sp:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self:addContent(bg_sp, 5)
	self.popNode = bg_sp

	local back_label=XTHDLabel:createWithParams({text=LANGUAGE_KEY_CLICKSCENEEXIT,ttf="",size=18})
	back_label:setColor(cc.c3b(204,115,69))
	back_label:setAnchorPoint(cc.p(0.5, 0))
	back_label:setPosition(bg_sp:getContentSize().width/2,-30)
	bg_sp:addChild(back_label)
	
	--左右按钮
	self._tab = 1
	self._leftBtn = XTHDImage:create("res/image/plugin/stageChapter/btn_left_arrow.png")
	self._leftBtn:setScale(1.3)
    self._leftBtn:setAnchorPoint(0, 0.5)
    self._leftBtn:setPosition(60, bg_sp:getContentSize().height/2)
    bg_sp:addChild(self._leftBtn, 2)
    self._leftBtn:setTouchSize(cc.size(120, 100))
    self._leftBtn:setVisible(false)

    self._rightBtn = XTHDImage:create("res/image/plugin/stageChapter/btn_right_arrow.png")
	self._rightBtn:setScale(1.3)
    self._rightBtn:setAnchorPoint(1, 0.5)
    self._rightBtn:setPosition(bg_sp:getContentSize().width - 60, bg_sp:getContentSize().height/2)
    self._rightBtn:setTouchSize(cc.size(120, 100))
    bg_sp:addChild(self._rightBtn, 2)

    local leftMove_1 = cc.MoveBy:create(0.5, cc.p(-10, 0))
    local leftMove_2 = cc.MoveBy:create(0.5, cc.p(10, 0))
    local rightMove_1 = cc.MoveBy:create(0.5, cc.p(10, 0))
    local rightMove_2 = cc.MoveBy:create(0.5, cc.p(-10, 0))

    self._leftBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(leftMove_1, leftMove_2)))
    self._rightBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(rightMove_1, rightMove_2)))

    self._leftBtn:setTouchEndedCallback(function()
    	-- print("_leftBtn ")
		if self._isChanging then
			return
		end
		self:goPre()
    end)
    self._rightBtn:setTouchEndedCallback(function()
    	-- print("_rightBtn ")
		if self._isChanging then
			return
		end
        self:goNext()
    end)

    local _normalNode = cc.Sprite:create()
    _normalNode:setContentSize(cc.size(self:getContentSize().width*3,366))
    -- self._scroll = XTHDPushButton:createWithParams({
    	-- normalNode = _normalNode,
    	-- needEnableWhenMoving = false,
    -- })
    -- self._scroll = cc.Node:create()
    self._scroll = cc.Layer:create()
	self._scroll:setTouchEnabled(true)

    -- self._scroll:setContentSize(cc.size(self:getContentSize().width*3,366))
    self._scroll:setAnchorPoint(0, 0) 
    self._scroll:setContentSize(cc.size(self:getContentSize().width*3,366))
    self._scroll:setPosition(cc.p((bg_sp:getContentSize().width-self:getContentSize().width)/2, 0))
    bg_sp:addChild(self._scroll)
    -- print("size --> ", self._scroll:getContentSize().width, self._scroll:getContentSize().height)

    local _size = self:getContentSize()
	local function _isOut( x, y )
		-- print("x --> ",x)
		-- print("y --> ",y)

		if(x < 0 or x > _size.width) then
			return true
		end
		if(y<118 or y > 480) then
			self:hide()
		end
		return false
	end
	local _beginPosX = 0
	self._scroll:registerScriptTouchHandler(function ( eventType, x, y )
		if self._isChanging then
			return
		end
		if (eventType == "began") then
			if(_isOut(x, y)) then
				return false
			end
			_beginPosX = x
			return true
		elseif (eventType == "ended") then
			if(_isOut(x, y)) then
				return
			end
			local _num = x - _beginPosX 
			if math.abs(_num) < _size.width*0.02 then
				return
			end
			self._isChanging = true
			if _num > 0 then
				self:goPre()
			else
				self:goNext()
			end
		end
	end)


    --可领取奖励数量
    for i = 1, tonumber(params.prizecount) do 
		local _path = "res/image/common/scale9_bg_12.png"
		if i == 2 then
			_path =	"res/image/common/scale9_bg_13.png"
		end

		-- local myScale9 = ccui.Scale9Sprite:create(cc.rect(26,25,1,1), _path)
		local myScale9 = cc.Sprite:create()
		myScale9:setContentSize(cc.size(self:getContentSize().width,261))
		myScale9:setAnchorPoint(cc.p(0.5, 0))
		myScale9:setPosition(cc.p(self:getContentSize().width / 2 + (i-1)*self:getContentSize().width, 0))
		self._scroll:addChild(myScale9)

		local widthsize=myScale9:getContentSize().width/2-30

	    local _per_star_num = tonumber(params.totalstar)/tonumber(params.prizecount)

		local _levelStar = _per_star_num * i

		local pNum = tonumber(_levelStar)-tonumber(params.getstar)
		if pNum > 0 then
			local star_num=XTHDLabel:createWithParams({text=pNum,ttf="",size=22})
			star_num:setAnchorPoint(1,0.5)
			star_num:setPosition(widthsize,250)
			myScale9:addChild(star_num)
			
			local star_sp=cc.Sprite:create("res/image/plugin/stageChapter/starbox_star2.png")
			star_sp:setAnchorPoint(0,0.5)
			star_sp:setPosition(widthsize,250)
			myScale9:addChild(star_sp)

			local title_left=cc.Sprite:create("res/image/plugin/stageChapter/reward_left.png")
			title_left:setAnchorPoint(1,0.5)
			title_left:setPosition(star_num:getPositionX()-star_num:getContentSize().width,250)
			myScale9:addChild(title_left)

			local title_right=cc.Sprite:create("res/image/plugin/stageChapter/reward_right.png")
			title_right:setAnchorPoint(0,0.5)
			title_right:setPosition(star_sp:getPositionX()+star_sp:getContentSize().width,250)
			myScale9:addChild(title_right)
		else
			local title_get = cc.Sprite:create("res/image/plugin/stageChapter/reward_allGet.png")
			title_get:setPosition(widthsize + 30,250)
			myScale9:addChild(title_get)
		end


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
				cc.p(myScale9:getContentSize().width/2, myScale9:getContentSize().height/2+35), 
				tonumber(#_reward_item), 
				130
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
				reward_item:setAnchorPoint(0.5,0.5)
				reward_item:setPosition(pos_table[k])
				myScale9:addChild(reward_item)
				local _item_name = reward_item._Name
				local item_name_label = XTHDLabel:createWithParams({
		            text = _item_name,
		            anchor=cc.p(0.5,1),
		            fontSize = 17,--字体大小
		            color = XTHD.resource.color.white_desc,
		            pos = cc.p(reward_item:getContentSize().width/2,-2),
	            })
	            reward_item:addChild(item_name_label)
			end

			local receive_statuus = 0 --领取状态
			for k,v in pairs(self.get_state) do
				if tonumber(v) == _per_star_num*i then
					receive_statuus = 1
					break
				end
			end

			local _star_bg_pos = nil
			if receive_statuus == 1 then
				local already_sp = cc.Sprite:create("res/image/vip/yilingqu.png")
				already_sp:setAnchorPoint(0.5,0)
				already_sp:setPosition(myScale9:getContentSize().width/2,20)
				myScale9:addChild(already_sp)
				 
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
					receive_statuus = 2
				else
					_label = XTHD.resource.getButtonImgTxt("lingqujiangli_lv")
				end

				local collect_btn = XTHDPushButton:createWithParams({
					normalNode    = _normalNode,
					selectedNode = _selectedNode,
					musicFile = XTHD.resource.music.effect_btn_common,
					label = _label,
					anchor = cc.p(0.5,0),
					pos = cc.p(myScale9:getContentSize().width/2,20),
				})
				collect_btn._reward_prize = _reward_prize
				collect_btn._star_cout = _per_star_num*i
				
				myScale9:addChild(collect_btn)

				--------
	        	if receive_statuus == 2 then
	        		collect_btn:setTouchEndedCallback(function()
	        			XTHDTOAST(LANGUAGE_TIPS_WORDS177)--------"您当前不满足领取条件!")
	        		end)
				elseif receive_statuus == 0 then
					collect_btn:setTouchEndedCallback(function()
						if pNum > 0 then
							XTHDTOAST(LANGUAGE_TIPS_WORDS177)
							return
						end
						--------------------------------------------------
						if collect_btn.get_type and collect_btn.get_type == LANGUAGE_ADJ.unreachable then --------"未达成" then
							XTHDTOAST(LANGUAGE_TIPS_WORDS177)------"您当前不满足领取条件!")
							return
						elseif collect_btn.get_type and collect_btn.get_type == LANGUAGE_ADJ.hasGet then ------"已领取" then
							XTHDTOAST(LANGUAGE_TIPS_WORDS235)-------"您已领取该星级对应奖励!")
							return
						end
						local _modules = "diffcultyBoxReward?"
						ClientHttp:requestAsyncInGameWithParams({
			                modules = _modules,
					        params = {groupId=params.chapterid,star=collect_btn._star_cout},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
					        successCallback = function(data)
						        if tonumber(data.result) == 0 then
						        	--领取成功之后，先存储领取状态，刷新数据，然后再做展示操作
									CopiesData.changeCopiesReward(params.chapterid, data.star, params.instancint_type)
							    	--领取之后添加已领取提示
							        collect_btn:setVisible(false)

							        local already_sp = cc.Sprite:create("res/image/vip/yilingqu.png")
									already_sp:setAnchorPoint(0.5,0)
									already_sp:setPosition(bg_sp:getContentSize().width/2,20)
									myScale9:addChild(already_sp)
									
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
									XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})

									--
						        	if params.callback and type(params.callback) == "function" then
						        		params.callback(data)
						        	else
						        	 	if self:getParent() then
							        		self:getParent():ConstructBoxData()
							        	end
						        	end
						        	self:ShowRewardList( collect_btn._reward_prize, function()
							        	--先判断是否还有可以领取的
							        	--更新奖励列表状态
							        	local _id = tonumber(collect_btn._star_cout) / (tonumber(params.totalstar)/tonumber(params.prizecount))
							        	print("_id ----------------> ", _id)
							        	if _id and self._rewardState[_id] then
							        		self._rewardState[_id] = false
							        	end
							        	local _haveReward = false
							        	local _gotoPage = 1
							        	for i = 1, #self._rewardState do
							        		if self._rewardState[i] == true then
							        			_haveReward = true
							        			_gotoPage = i
							        			break
							        		end
							        	end
							        	if _haveReward then
							        		self:gotoPage(_gotoPage)
							        	else
							        		self:removeFromParent()
							        	end
							        end)
						        else
				                    XTHDTOAST(data.msg)
						        end
					        end,--成功回调
					        failedCallback = function()
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
	local _gotoPage = 1
	local _haveReward = false
	for i = 1, #self._rewardState do
		if self._rewardState[i] == true then
			_gotoPage = i
			_haveReward = true
			break
		end
	end
	-- print("_gotoPage   -----------> ", _gotoPage)
	-- print("_haveReward -----------> ", _haveReward)

	if _haveReward then
		self:gotoPage(_gotoPage)
	end

end

function LiLianReceiveBoxReward:gotoPage(_page)
	if self._isChanging then
		return
	end
	if tonumber(_page) == tonumber(self._tab) then
		return
	else
		local _needGoNum = math.abs(tonumber(_page) - tonumber(self._tab))
		local _right = true
		if _page < self._tab then
			_right = false
		end
		print("_needGoNum ----> ", _needGoNum)
		local _arr = {}
		for i = 1, _needGoNum do
			_arr[#_arr+1] = cc.CallFunc:create(function() 
				if _right then
					self:goNext()
				else
					self:goPre()
				end
			end )
		end
		self:runAction(cc.Sequence:create(_arr))
	end
end

function LiLianReceiveBoxReward:goPre()

	if self._tab == 1 then
		self._isChanging = false
		return
	end
	self._tab = self._tab - 1

	if self._tab == 1 then
		self._leftBtn:setVisible(false)
	end
	self._rightBtn:setVisible(true)

	local _arr = {}
	local _per = self:getContentSize().width/50
	for i = 1, 50 do
		_arr[#_arr+1] = cc.MoveBy:create(0.01, cc.p(_per, 0))
	end
	_arr[#_arr+1] = cc.CallFunc:create(function() self._isChanging = false end)
	self._scroll:runAction(cc.Sequence:create(_arr))

end

function LiLianReceiveBoxReward:goNext()
	if self._tab == 3 then
		self._isChanging = false
		return
	end
	self._tab = self._tab + 1
	if self._tab == 3 then
		self._rightBtn:setVisible(false)
	end
	self._leftBtn:setVisible(true)

	local _arr = {}
	local _per = self:getContentSize().width/50
	for i = 1, 50 do
		_arr[#_arr+1] = cc.MoveBy:create(0.01, cc.p(-_per, 0))
	end
	_arr[#_arr+1] = cc.CallFunc:create(function() self._isChanging = false end)
	self._scroll:runAction(cc.Sequence:create(_arr))

end

function LiLianReceiveBoxReward:ShowRewardList(reward_data, _callback)
    local show_data = {}
	for i=1,#reward_data do
	   show_data[#show_data+1] = {rewardtype = tonumber(reward_data[i][1]),id=reward_data[i][2],num =  tonumber(reward_data[i][3])}
	end
	ShowRewardNode:create(show_data, nil, _callback)
end

function LiLianReceiveBoxReward:create(params)
	local dialog = self.new(params)
	 return dialog
end

function LiLianReceiveBoxReward:onEnter( )
end

function LiLianReceiveBoxReward:onExit( )
end

return LiLianReceiveBoxReward

