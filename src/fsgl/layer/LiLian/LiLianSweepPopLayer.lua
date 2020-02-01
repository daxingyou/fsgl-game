local LiLianSweepPopLayer = class("LiLianSweepPopLayer", function()
	return XTHDPopLayer:create()
end)

function LiLianSweepPopLayer:onCleanup( )
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey("res/image/plugin/stageChapter/sweep_bg1.png")
	textureCache:removeTextureForKey("res/image/common/scale9_bg2_34.png")
	textureCache:removeTextureForKey("res/image/plugin/stageChapter/sweep_light.png")
	textureCache:removeTextureForKey("res/image/plugin/stageChapter/sweep_words.png")
end

function LiLianSweepPopLayer:InitUI(params)
	-- self:setClickable(false)
	-- self:setSwallowTouches(true)
	self._index = {
		[1] = {title = LANGUAGE_TIPS_WORDS191[1]},-------"第一轮",},
		[2] = {title = LANGUAGE_TIPS_WORDS191[2]},-------"第二轮",},
		[3] = {title = LANGUAGE_TIPS_WORDS191[3]},-------"第三轮",},
		[4] = {title = LANGUAGE_TIPS_WORDS191[4]},-------"第四轮",},
		[5] = {title = LANGUAGE_TIPS_WORDS191[5]},-------"第五轮",},
		[6] = {title = LANGUAGE_TIPS_WORDS191[6]},-------"第六轮",},
		[7] = {title = LANGUAGE_TIPS_WORDS191[7]},-------"第七轮",},
		[8] = {title = LANGUAGE_TIPS_WORDS191[8]},-------"第八轮",},
		[9] = {title = LANGUAGE_TIPS_WORDS191[9]},-------"第九轮",},
		[10] = {title = LANGUAGE_TIPS_WORDS191[10]},-------"第十轮",},
		[11] = {title = LANGUAGE_TIPS_WORDS191[11]},-------"额外奖励",},
	}
	-- local bg_Node = XTHDImage:create("res/image/plugin/stageChapter/sweep_bg1.png")
	local bg_Node = XTHD.getScaleNode("res/image/common/scale9_bg3_34.png", cc.size(418, 439))
	bg_Node:setAnchorPoint(0.5,0.5)
	self.popNode = bg_Node
	bg_Node:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
	self:addContent(bg_Node)
	
	local close_btn = XTHD.createBtnClose(function()
        self:hide()
    end)
    close_btn:setPosition(bg_Node:getContentSize().width-10, bg_Node:getContentSize().height-10)
	bg_Node:addChild(close_btn,2)
	
	self._reward_tab =  cc.TableView:create(cc.size(bg_Node:getContentSize().width,bg_Node:getContentSize().height-50))
	TableViewPlug.init(self._reward_tab)
--	self._reward_tab:setBoolEaseBack(true)
    self._reward_tab:setPosition(0 , 20)
    self._reward_tab:setBounceable(false)
    self._reward_tab:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._reward_tab:setDelegate()

    bg_Node:addChild(self._reward_tab)
    
    self._reward = params["rewards"]
    self._cell_tab={} -- 存放cell
	self._extra_reward = {}
	local _tab = {}
	for i=1,#self._reward do
		if self._reward[i]["buCangItem"] then
            local buCangItem = self._reward[i]["buCangItem"]
			--  存储用于额外奖励的数据
			for i=1,#buCangItem do
				_tab[#_tab +1] = buCangItem[i]
			end
		end
	end

	for i=1,#_tab do
		local _t = string.split(_tab[i],',')
		if #self._extra_reward > 0 then
			local _is_new_data = true
			for i=#self._extra_reward,1,-1 do
				if _t[1] == self._extra_reward[i]["id"] then
					_is_new_data = false
					self._extra_reward[i]["count"] = self._extra_reward[i]["count"] or 0
					self._extra_reward[i]["count"] = tonumber(self._extra_reward[i]["count"]) +_t[2]
					break
				end
			end
			if _is_new_data then
				self._extra_reward[#self._extra_reward+1] = {id = _t[1],count = _t[2] }
			end
		else
			self._extra_reward[1] ={id = _t[1],count = _t[2]}
		end
	end
    self._reward_tab:registerScriptHandler(function (table_view)
           return self:numberOfCellsInTableView(table_view)
        end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    self._reward_tab:registerScriptHandler(function (table_view,idx)
            return self:cellSizeForTable(table_view,idx)
        end,cc.TABLECELL_SIZE_FOR_INDEX)

     self._reward_tab:registerScriptHandler(function (table_view,idx)
            return self:tableCellAtIndex(table_view,idx)
        end,cc.TABLECELL_SIZE_AT_INDEX)
     self._reward_tab:registerScriptHandler(function(view)
     	
     	end,cc.SCROLLVIEW_SCRIPT_ZOOM)
     self._reward_tab:reloadData()
	self._reward_tab.getCellNumbers = function(tableview)
        return self:numberOfCellsInTableView(tableview)
    end
	self._reward_tab.getCellSize = function(tableview,id)
        return self:cellSizeForTable(tableview,id)
    end
    local function _upDateCell(idx)
    	local cell = self._reward_tab:cellAtIndex(idx)
		print("----------------idx:"..idx.."cellName:"..cell:getName())
    	local _time = 0.75
    	if idx == 0 or (cell and tonumber(cell:getName()) == 10) then
    		_time = 1.0
    	end
    	self:runAction(cc.Sequence:create(cc.CallFunc:create(function()
    		self._reward_tab:updateCellAtIndex(idx)
    		self._reward_tab:scrollToCell(idx,true)

	    		local cell = self._reward_tab:cellAtIndex(idx)

	    		if cell then
	    				local reward_word = cell:getChildByName("reward_word")
	    				
	    				if reward_word then
	    					reward_word:setVisible(false)
	    					reward_word:runAction(cc.Sequence:create(
	    					cc.DelayTime:create(0.5),
					        cc.Show:create(),
					        cc.ScaleTo:create(0, 3.14),
					        cc.ScaleTo:create(0.1, 0.8),
					        cc.ScaleTo:create(0.1,1.0),
					        cc.DelayTime:create(0.1),
					        cc.CallFunc:create(function()
					        end)))
	    				end
	    			for i=1,tonumber(cell:getName()) do
	    				local drop_item = cell:getChildByName("drop_item"..tostring(i))
	    				if drop_item then
	    					drop_item:setVisible(false)
	    					self:PlayItemAnimation(drop_item,i,#self._extra_reward)
	    				else
	    					break;
	    				end
	    			end
	    		end
    		end)
			,cc.DelayTime:create(_time)
			,cc.CallFunc:create(function()
    			if idx > 0 then
	    			_upDateCell(idx - 1)
	    		else
					self.isFinished = true
	    			self._reward_tab:setTouchEnabled(true)
	    		end
    		end)))
    end

	
	self._reward_tab:setTouchEnabled(false)
	_upDateCell(#self._reward)
	self:show()
end
function LiLianSweepPopLayer:onTouchEnded( touch, event )
	if not self._touch_times  then
		self._touch_times  =0
	end
	self._touch_times  = self._touch_times  +1
	if self._touch_times == 1 then
		self:stopAllActions()
		for idx=0,#self._reward-1 do
			local cell = self._reward_tab:cellAtIndex(idx)
			if cell then
				local reward_word = cell:getChildByName("reward_word")
				if reward_word then
					reward_word:setVisible(true)
				end
				
    			for i=1,tonumber(cell:getName()) do
    				local drop_item = cell:getChildByName("drop_item"..tostring(i))
    				if drop_item then
    					drop_item:setVisible(true)
    				else
    					break;
    				end
    			end
    		end
		end
		self._reward_tab:scrollToFirstCell(false)
		self._reward_tab:setTouchEnabled(true)
	elseif self._touch_times == 2 then
		self:hide()
	end
end
function LiLianSweepPopLayer:onExit()
	self._touch_times = nil
end
function LiLianSweepPopLayer:tableCellAtIndex(table_view,idx)
	local cell = table_view:dequeueCell()
	if cell then
		cell:removeAllChildren()
	else
		cell = cc.TableViewCell:new()
	end
	local _sizeX,_sizeY  = self:cellSizeForTable(table_view,idx)

	local cell_index_bg	= ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png") --cc.Sprite:create("res/image/plugin/stageChapter/sweep_index_bg.png")
	cell_index_bg:setContentSize(cc.size(390,125))
	cell_index_bg:setAnchorPoint(0.5,0)
	cell_index_bg:setPosition(_sizeX/2, 0)
	cell:addChild(cell_index_bg)

	local _txt = self._index[#self._reward-idx+1]["title"]
	if idx == 0 then
		_txt = self._index[#self._index]["title"]
	end


	local drop_data = self._reward[#self._reward-idx+1]
	if drop_data then
		local itemReward = drop_data["itemReward"]
		local extraNum = 0
		if drop_data.addGold then
            extraNum = 1
		end
		if drop_data.addZhenqi then
			extraNum = 2
		end
		--如果没有获取奖励物品
		if #itemReward < 0 then
	
			local text= LANGUAGE_SPECAIL_WORD2 --
			for i=1,10 do
				local tip_label = XTHDLabel:createWithParams({
		            text = text[i],
		            anchor=cc.p(0,0.5),
		            fontSize = 30,--字体大小
		            pos = cc.p(60+20*(i-1),cell_index_bg:getPositionY() - cell_index_bg:getContentSize().height/2-20),
		            color = cc.c3b(207,72,31),
		        })
		        tip_label:setScale(0.75)
		        tip_label:setName("drop_item"..tostring(i))
		        cell:addChild(tip_label)
		        if not self.isFinished then
					tip_label:setVisible(false)
				end
			end
			cell:setName(10)
	    else 
	    	cell:setName( #itemReward+extraNum)
	    	if #itemReward >= 5 then
	    	 	cell_index_bg:setContentSize(cc.size(390,225))
	    	end

	    	for i=1,#itemReward+extraNum do
				local _tab = string.split(itemReward[i],',')
				local _static_data =  gameData.getDataFromCSV( "ArticleInfoSheet",{itemid=_tab[1]})
				local drop_item = nil
				local _item_name = ""
				if i < #itemReward+1 then
					_item_name = _static_data["name"]
					drop_item = ItemNode:createWithParams({
			            _type_ = 4,
			            itemId = _tab[1],
			            needSwallow = true,
			            isShowCount = true,
			            count   = _tab[2] 
			        })
				else
					if extraNum == 1 then
						_item_name = LANGUAGE_KEY_GOLD ------"银两"
						drop_item = ItemNode:createWithParams({
				            ["_type_"] = XTHD.resource.type.gold,
				            itemId = _tab[1],
				            count   = drop_data["addGold"] ,
				            isShowCount = true,
				            needSwallow = true,
				        })
					elseif extraNum == 2 then
						if i < #itemReward+extraNum then
							_item_name = LANGUAGE_KEY_GOLD ------"银两"
							drop_item = ItemNode:createWithParams({
					            ["_type_"] = XTHD.resource.type.gold,
					            itemId = _tab[1],
					            count   = drop_data["addGold"] ,
					            isShowCount = true,
					            needSwallow = true,
					        })
						else
					        if drop_data["addZhenqi"] then
								_item_name = LANGUAGE_TABLE_RESOURCENAME[XTHD.resource.type.zhenQi] ------"韬略"
								drop_item = ItemNode:createWithParams({
						            ["_type_"] = XTHD.resource.type.zhenQi,
						            count   = drop_data["addZhenqi"] ,
						            isShowCount = true,
						            needSwallow = true,
						        })
					        end
					    end
				    end
				end

				local item_name_label = XTHDLabel:createWithParams({
		            text = _item_name,
		            anchor=cc.p(0.5,1),
		            fontSize = 22,--字体大小
		            color = cc.c3b(61,29,8),
		            pos = cc.p(drop_item:getContentSize().width/2,-2),
	            })
	            -- drop_item:addChild(item_name_label)


				drop_item:setAnchorPoint(0,1)
				drop_item:setScale(60/drop_item:getContentSize().width)
				if i < 6 then
					-- drop_item:setPosition(20+70*(i-1), 50+32)
					drop_item:setPosition(20+70*(i-1), cell_index_bg:getContentSize().height-40)
					-- cell_index_bg
				else
					drop_item:setPosition(20+70*(i-6), cell_index_bg:getContentSize().height-130)
				end
				drop_item:setName("drop_item"..tostring(i))
				cell:addChild(drop_item)
				if not self.isFinished then
					drop_item:setVisible(false)
				end
			end
		end
		if drop_data["addExp"] then
            local exp_sp = cc.Sprite:create("res/image/tmpbattle/battle_exp.png")
			exp_sp:setScale(0.8)
		    exp_sp:setAnchorPoint(0,0.5)
		    exp_sp:setPosition(11, cell_index_bg:getContentSize().height-18)
		    cell_index_bg:addChild(exp_sp)

			local exp_label = XTHDLabel:createWithParams({
		            text = "+" .. drop_data["addExp"],
		            anchor=cc.p(0,0.5),
		            fontSize = 18,--字体大小
		            pos = cc.p(exp_sp:getPositionX()+ exp_sp:getContentSize().width*exp_sp:getScaleX()+3,exp_sp:getPositionY()),
		            color = cc.c3b(123,79,26),
		        })
			cell_index_bg:addChild(exp_label)
		end
	
	else
		local light_bg = cc.Sprite:create("res/image/plugin/stageChapter/sweep_light.png")
		light_bg:setPosition(_sizeX/2,_sizeY - light_bg:getContentSize().height/2+10)
		cell:addChild(light_bg)
		light_bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.3,30)))

		local reward_word = cc.Sprite:create("res/image/plugin/stageChapter/sweep_words.png")
		reward_word:setPosition(light_bg:getPositionX(), light_bg:getPositionY())
		reward_word:setName("reward_word")
		cell:setName(#self._extra_reward)
		cell:addChild(reward_word)
		cell:setName( #self._extra_reward)
		for i=1,#self._extra_reward do
			
			local _static_data =  gameData.getDataFromCSV( "ArticleInfoSheet",{itemid=self._extra_reward[i]["id"]})
			local drop_item = ItemNode:createWithParams({
			            _type_ = 4,
			            itemId = self._extra_reward[i]["id"],
			            needSwallow = true,
			            isShowCount = true,
			            count   = self._extra_reward[i]["count"] 
			        })
			
			drop_item:setAnchorPoint(0,1)
			drop_item:setScale(60/drop_item:getContentSize().width)
			drop_item:setName("drop_item"..tostring(i))

			local item_name_label = XTHDLabel:createWithParams({
		            text = _static_data["name"],
		            anchor=cc.p(0.5,1),
		            fontSize = 22,--字体大小
		            color = cc.c3b(61,29,8),
		            pos = cc.p(drop_item:getContentSize().width/2,-2),
	            })
	         -- drop_item:addChild(item_name_label)

			if i < 6 then
				drop_item:setPosition(20+70*(i-1), cell_index_bg:getContentSize().height-40)
			else
				drop_item:setPosition(20+70*(i-6), cell_index_bg:getContentSize().height-130)
			end
			
			cell:addChild(drop_item)
			if not self.isFinished then
				reward_word:setVisible(false)
				drop_item:setVisible(false)
			end
		end
	end

	local index_label = XTHDLabel:createWithParams({
	           text = _txt,
	           fontSize = 22,--字体大小
	           anchor=cc.p(0.5,0),
	           pos = cc.p(cell_index_bg:getContentSize().width/2,cell_index_bg:getContentSize().height-2),
	           color = cc.c3b(123,79,26),
	       })
	
	cell_index_bg:addChild(index_label)
	
	return cell
end
--给每个装备执行动画
function LiLianSweepPopLayer:PlayItemAnimation(equip_item,idx,total_count)
	equip_item:runAction(cc.Sequence:create(cc.DelayTime:create(0.12*(idx+1)),cc.CallFunc:create(function()
         equip_item:setVisible(true)
     end),cc.EaseExponentialOut:create(cc.Sequence:create(cc.ScaleTo:create(0.07,0.85),cc.ScaleTo:create(0.07,0.7)))))
end
function LiLianSweepPopLayer:cellSizeForTable(table_view,idx)
	local _sizeX = 418 
	local _sizeY = 125
	if idx >  0 then
		local itemReward = self._reward[#self._reward-idx+1]["itemReward"]
		local extraNum = 1
		if self._reward.addZhenqi then
			extraNum = 2
		end
		local line_num = math.ceil((#itemReward+extraNum)/5)
		if line_num < 1 then line_num = 1 end
		_sizeY = 100*line_num+55
	else
		local line_num = math.ceil((#self._extra_reward)/5)
		if line_num < 1 then line_num = 1 end
		_sizeY =_sizeY+ 55 + 100*line_num
	end
	
	return _sizeX,_sizeY
end
function LiLianSweepPopLayer:numberOfCellsInTableView(table_view)
	return #self._reward +1
end

function LiLianSweepPopLayer:ctor(params)
	for i=1,#params["items"] do
		local _item_data = params["items"][i]
		if _item_data then
			DBTableItem.updateCount(gameUser.getUserId(),_item_data,_item_data["dbId"])
		end
	end
	self.isFinished = false
	self:setColor(cc.c3b(0,0,0))
	self:setOpacity(100)
	self:InitUI(params)
end

function LiLianSweepPopLayer:create(params)

	local layer = self.new(params);
	layer.beginPos = cc.p(layer:getContentSize().width/2,layer:getContentSize().height/2)
	
	return layer;
end

return LiLianSweepPopLayer;
