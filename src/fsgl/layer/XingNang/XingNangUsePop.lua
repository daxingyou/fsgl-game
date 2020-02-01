--20150314 yanyuling
local TAG = "XingNangUsePop"

local  XingNangUsePop  = class( "XingNangUsePop", function ( ... )
    return XTHDPopLayer:create()
end)

function XingNangUsePop:InitUI()

	self._heros_data = {}
	local _heroData = DBTableHero.getData(gameUser.getUserId())
	if _heroData and next(_heroData)~=nil and #_heroData <1 then
		self._heros_data[#self._heros_data +1] = _heroData
	else
		for k,v in pairs(_heroData) do
			self._heros_data[#self._heros_data +1] = v
		end
	end
	--英雄排序
	table.sort(self._heros_data, function(a, b)
		if tonumber(a.power) ~= tonumber(b.power) then
			return tonumber(a.power) > tonumber(b.power)
		else
			return tonumber(a.advance) > tonumber(b.advance)
		end
	end)

	local scale9_sp = getScale9SpriteWithImg("res/image/common/scale9_bg1_34.png",cc.size(800,468))
	local pop_bg =  XTHDPushButton:createWithParams({normalNode =scale9_sp })
	-- XTHDImage:create("res/image/plugin/warehouse/warehouse_chose_hero_bg.png")
	pop_bg:setAnchorPoint(0.5,1)
	pop_bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height-85)
	self:addContent(pop_bg)
	self.popNode = pop_bg

	--标题
	-- local title_sp = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(385,34))
	-- title_sp:setPosition(pop_bg:getContentSize().width/2, pop_bg:getContentSize().height-34)
	-- pop_bg:addChild(title_sp)
	local star_num_label = XTHDLabel:createWithParams({
            text = LANGUAGE_TIPS_WORDS201,-------"长按英雄头像即可快速使用经验药水",
            anchor=cc.p(0.5,0.5),
            fontSize = 26,--字体大小
            pos = cc.p(pop_bg:getContentSize().width/2, pop_bg:getContentSize().height-34),
            color = cc.c3b(54,55,112),
        })
		pop_bg:addChild(star_num_label)

	-- local pattern_left =  cc.Sprite:create("res/image/plugin/stagepop/pattern_left.png")
	-- pattern_left:setAnchorPoint(1,0.5)
	-- pattern_left:setPosition(star_num_label:getPositionX()-star_num_label:getContentSize().width/2-10, star_num_label:getPositionY())
	-- title_sp:addChild(pattern_left)

	-- local pattern_right =  cc.Sprite:create("res/image/plugin/stagepop/pattern_left.png")
	-- -- pattern_right:setFlipX(true)
	-- pattern_right:setScaleX(-1)
	-- pattern_right:setAnchorPoint(1,0.5)
	-- pattern_right:setPosition(star_num_label:getPositionX() + star_num_label:getContentSize().width/2+10, star_num_label:getPositionY())
	-- title_sp:addChild(pattern_right)
	
	local close_btn = XTHD.createBtnClose(function()
     	if self._schedule  then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schedule)
			self._schedule = nil
		end
        self:removeFromParent()
    end)
    close_btn:setPosition(pop_bg:getContentSize().width-5, pop_bg:getContentSize().height-5)
	pop_bg:addChild(close_btn)
    
	   --记录总共使用了多少,从0开始计数
    self._use_count = 0 
    self._total_count = tonumber(self._Use_data["totalCount"]) --标示自己总共有多少道具
    self._top_level = tonumber(gameData.getDataFromCSV("PlayerUpperLimit", {id = gameUser.getLevel()})["maxlevel"])
    self._using =false --标示是否正在使用道具

    
	self._ItemTableview =  cc.TableView:create(cc.size(pop_bg:getContentSize().width,pop_bg:getContentSize().height-90))
    self._ItemTableview:setPosition(0 , 40)
    self._ItemTableview:setBounceable(true)
    self._ItemTableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._ItemTableview:setDelegate()
    self._ItemTableview:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    pop_bg:addChild(self._ItemTableview)

	
    self._ItemTableview:registerScriptHandler(function (table_view)
           return self:numberOfCellsInTableView(table_view)
        end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    self._ItemTableview:registerScriptHandler(function (table_view,idx)
            return self:cellSizeForTable(table_view,idx)
        end,cc.TABLECELL_SIZE_FOR_INDEX)

     self._ItemTableview:registerScriptHandler(function (table_view,idx)
            return self:tableCellAtIndex(table_view,idx)
        end,cc.TABLECELL_SIZE_AT_INDEX)

     self._ItemTableview:reloadData()


    self:show()
 
end

function XingNangUsePop:numberOfCellsInTableView(table_view)
	return  math.ceil(#self._heros_data/2)
end
function XingNangUsePop:cellSizeForTable(table_view,idx)
	return self._ItemTableview:getViewSize().width, 120
end

--根据当前经验值、 当前等级 获取目标经验、目标等级
function XingNangUsePop:getLevelInfo(add_exp,_level)
	--如果已达最大等级，则不进行下面的操作
	if tonumber(_level) > self._top_level then
		return
	end
	if not self._Exp_info then
		 self._Exp_info = gameData.getDataFromCSV("GeneralExpList", nil)
	end
	local _target_level = tonumber(_level)
	local _target_last_exp = tonumber(add_exp)
	local _result_tab = {}
	local function _add_exp(exp,level)
		local max_exp = tonumber(self._Exp_info[level]["heroexperience"])
		if tonumber(exp) >= tonumber(max_exp) then
			if tonumber(_target_level) == self._top_level  then
				_target_level = self._top_level
				_result_tab["level"] = _target_level
				_result_tab["curexp"] = max_exp
				_result_tab["maxexp"] = max_exp
			else
				exp = tonumber(exp) - tonumber(max_exp)
				_target_last_exp = exp
				_target_level = _target_level +1
				_add_exp(exp,tonumber(level)+1)
			end
		else
			_result_tab["level"] = level
			_result_tab["curexp"] = exp
			_result_tab["maxexp"] = max_exp
		end
	end
	 _add_exp(tonumber(add_exp),tonumber(_level))
	 return _result_tab
end
function XingNangUsePop:tableCellAtIndex(table_view,idx)
	local cell = table_view:dequeueCell();
    if cell then
    	if cell._scheduler_running == true then
    		self:stopScheduler()
    		cell._scheduler_running = false
    	end
        cell:removeAllChildren()
    else
        cell = cc.TableViewCell:new()
    end


    for i=1,2 do
    	local hero_data = self._heros_data[idx*2 + i]

	    if hero_data then
	    	if not hero_data._selfCount then
		 		hero_data._selfCount = 0
    		end

	    	local static_hero_data = gameData.getDataFromCSV("GeneralInfoList", {["heroid"]= hero_data["heroid"]})
	    	-- local hero_bg = getScale9SpriteWithImg("res/image/common/scale9_bg_4.png",cc.size(386,110))
			local hero_bg =requires("src/fsgl/layer/XingNang/TouchSprite.lua"):create( "res/image/common/scale9_bg_32.png" )
			hero_bg:setContentSize(cc.size(386,110))
	    	hero_bg:setAnchorPoint(0.5,0.5)
			hero_bg:setPosition( (self._ItemTableview:getViewSize().width)/2 -195, 60)
			if i==2 then
				hero_bg:setPosition( (self._ItemTableview:getViewSize().width)/2 +195, 60)
			end
			cell:addChild(hero_bg)

			local use_num_label = XTHDLabel:createWithParams({
					text = "",
		            anchor=cc.p(1,1),
		            fontSize = 30,--字体大小
		            pos = cc.p(hero_bg:getContentSize().width-50,hero_bg:getContentSize().height/2+16),
		            color = XTHD.resource.color.brown_desc,
				})
			use_num_label:setVisible(false)
			hero_bg:addChild(use_num_label)

			local heroimg = self:getAvatorNode(hero_data)-- requires("src/fsgl/layer/XingNang/TouchSprite.lua"):create(XTHD.resource.getHeroAvatorImgById(hero_data["heroid"]))
			heroimg:setPosition(heroimg:getContentSize().width/2+16, hero_bg:getContentSize().height/2)
			-- heroimg:setScale(1.06)
			heroimg.label_level = tonumber(hero_data["level"])
			hero_bg:addChild(heroimg)

			--类型背景
			local hero_type_bg = cc.Sprite:create("res/image/plugin/hero/hero_type_"..static_hero_data["type"]..".png") 
			-- cc.Sprite:create("res/image/plugin/warehouse/hero_type_bg.png")
			hero_type_bg:setAnchorPoint(0,1)
 			hero_type_bg:setPosition(heroimg:getPositionX() + heroimg:getBoundingBox().width/2 + 11,hero_bg:getContentSize().height - 15)
 			hero_bg:addChild(hero_type_bg)

			local hero_name_label = XTHDLabel:createWithParams({
					text = static_hero_data["name"],
					anchor = cc.p(0,0.5),
		            fontSize = 18,--字体大小
		            pos = cc.p(hero_type_bg:getPositionX()+hero_type_bg:getContentSize().width+8, hero_type_bg:getPositionY()-hero_type_bg:getContentSize().height/2),
		            color = cc.c3b(70,34,34) 
				})
			hero_bg:addChild(hero_name_label)

			-- local _advance_plus = XTHD.resource.getPlusNumWithAdvance(hero_data["advance"])
			local _advance_plus = tonumber(hero_data["advance"]) - 1

			if _advance_plus and _advance_plus > 0 then
					local advance_label = XTHDLabel:createWithParams({
						text = "+".. tostring(_advance_plus),
			            anchor=cc.p(0,0.5),
			            fontSize = 18,--字体大小
			            pos = cc.p(hero_name_label:getPositionX() + hero_name_label:getContentSize().width+15,hero_name_label:getPositionY()),
			            color = XTHD.resource.getRankColor_number(tonumber(hero_data["advance"]),tonumber(hero_data.heroid))["color"],
					})
				hero_bg:addChild(advance_label)
			end
		
			--经验条
			local progress_bg = cc.Sprite:create("res/image/common/common_progress_bg.png")
			progress_bg:setAnchorPoint(0,0)
			progress_bg:setPosition(heroimg:getPositionX()+heroimg:getContentSize().width/2+ 13, heroimg:getPositionY()-heroimg:getContentSize().height/2+10)
			hero_bg:addChild(progress_bg)
			local percent_ = tonumber(hero_data["curexp"])/tonumber(hero_data["maxexp"])*100
			local express_bar = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/common_progress.png"))
			express_bar:setName("express_bar"..tostring(i))
			express_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
			express_bar:setMidpoint(cc.p(0,0.5))
			express_bar:setBarChangeRate(cc.p(1,0))
			express_bar:setPercentage(percent_)
			express_bar:setPosition(progress_bg:getContentSize().width/2,progress_bg:getContentSize().height/2-1.5)
			progress_bg:addChild(express_bar)

			if percent_ == 100 and tonumber(hero_data["level"]) >= tonumber(self._top_level)  then
				local hero_cover = cc.Sprite:create("res/image/plugin/warehouse/hero_cover.png")
				hero_cover:setName("hero_cover")
				hero_bg.enable_callback =false  --标示刚进入的时候就已经满经验，则无法执行成功回调
				hero_cover:setPosition(hero_bg:getContentSize().width/2, hero_bg:getContentSize().height/2)
				hero_bg:addChild(hero_cover,2)
				local full_exp_label = XTHDLabel:createWithParams({
					text = LANGUAGE_KEY_EXPFULL,------"经验已满",
		            anchor=cc.p(1,0),
		            fontSize = 22,--字体大小
		            pos = cc.p(progress_bg:getPositionX() +progress_bg:getContentSize().width-9 ,progress_bg:getPositionY()+progress_bg:getContentSize().height),
		            color = cc.c3b(255,187,40),
				})
				hero_cover:addChild(full_exp_label)
			end
			
			--等级
			local level_label = XTHDLabel:createWithParams({
					text = "LV:".. hero_data["level"],
		            anchor=cc.p(0,0.5),
		            fontSize = 18,--字体大小
		            pos = cc.p(heroimg:getPositionX()+heroimg:getContentSize().width/2+15 ,heroimg:getPositionY()-5),
		            color = hero_name_label:getColor(),
				})
			level_label:setName("level_label"..tostring(i))
			hero_bg:addChild(level_label)

			local function Add_exp(heroid)
				if hero_bg:getChildByName("hero_cover") or tonumber(hero_data["level"]) > tonumber( self._top_level) then
					self:stopScheduler()
					cell._scheduler_running = false
					return
				end

				local cur_data = self:getLevelInfo(tonumber(self._Use_data["effect"])+tonumber(hero_data["curexp"]),tonumber(hero_data["level"]))
				--如果目标等级大于做大等级，则目标等级等于最大等级
				if tonumber(cur_data["level"]) >= tonumber( self._top_level) then
					cur_data["level"] =  tonumber( self._top_level) 
				end
				local _bool_levelup = false
				local add_level = tonumber(cur_data["level"]) - tonumber(hero_data["level"]) or 0
				if not add_level then add_level =0 end
				if tonumber(cur_data.level) > tonumber(hero_data.level) then
					_bool_levelup = true
				end

				for k,v in pairs(cur_data) do
					hero_data[k]=v
				end
				if tonumber(hero_data["level"]) >= tonumber( self._top_level) and  (tonumber(hero_data["curexp"]) >= tonumber(hero_data["maxexp"]) )   then
					hero_data["level"] = self._top_level
					
					self:stopScheduler()
					cell._scheduler_running = false

					local hero_cover = cc.Sprite:create("res/image/plugin/warehouse/hero_cover.png")
					hero_cover:setName("hero_cover")
					hero_cover:setPosition(hero_bg:getContentSize().width/2, hero_bg:getContentSize().height/2)
					hero_bg:addChild(hero_cover,2)
					XTHDTOAST(LANGUAGE_TIPS_WORDS110)-----"英雄等级已达上限,无法继续升级")

					hero_bg:setScale(1)
					local full_exp_label = XTHDLabel:createWithParams({
						text = LANGUAGE_KEY_EXPFULL,-----"经验已满",
			            anchor=cc.p(1,0),
			            fontSize = 22,--字体大小
			            pos = cc.p(progress_bg:getPositionX() +progress_bg:getContentSize().width-9 ,progress_bg:getPositionY()+progress_bg:getContentSize().height),
			            color = cc.c3b(255,187,40),
					})
					hero_cover:addChild(full_exp_label)
					-- self:RequestNetAndRefreshData(heroid)
				end

				local current_percent = express_bar:getPercentage()
				local  target_percent = tonumber(hero_data["curexp"])/tonumber(hero_data["maxexp"])*100

				if tonumber(self._use_count) > 0 then
					level_label:setString("LV:"..hero_data["level"])
					heroimg.label_level = tonumber(hero_data["level"])
					if _bool_levelup == true then
					 --需要添加升级动画
						--  local animation_sp = cc.Sprite:create()
						--  animation_sp:setPosition(heroimg:getContentSize().width/2, heroimg:getContentSize().height/2-3)
						--  heroimg:addChild(animation_sp)
						--  local animation = getAnimation("res/image/tmpbattle/level_up/level_up00",1,6,0.08)
						--  animation_sp:runAction(cc.Sequence:create(animation,cc.CallFunc:create(function()
						--           animation_sp:removeFromParent()
						--       end)))

						local animation_sp = sp.SkeletonAnimation:create( "res/image/tmpbattle/level_up/shengjila.json", "res/image/tmpbattle/level_up/shengjila.atlas",1.0)
						animation_sp:setAnimation(0,"shengjila",false)
						animation_sp:setPosition(heroimg:getContentSize().width/2, heroimg:getContentSize().height/2-3)
						heroimg:addChild(animation_sp)
						self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function ()
							animation_sp:removeFromParent()
						end)))
					end
					express_bar:setPercentage(target_percent)
				else
					if tonumber(add_level) > 0 then
						-- local animation_sp = cc.Sprite:create()
						-- animation_sp:setPosition(heroimg:getContentSize().width/2, heroimg:getContentSize().height/2-3)
						-- heroimg:addChild(animation_sp)
						-- local animation = getAnimation("res/image/tmpbattle/level_up/level_up00",1,6,0.08)
						-- animation_sp:runAction(cc.Sequence:create(animation,cc.CallFunc:create(function()
						--           animation_sp:removeFromParent()
						--       end)))
						local animation_sp = sp.SkeletonAnimation:create( "res/image/tmpbattle/level_up/shengjila.json", "res/image/tmpbattle/level_up/shengjila.atlas",1.0)
						animation_sp:setAnimation(0,"shengjila",false)
						animation_sp:setPosition(heroimg:getContentSize().width/2, heroimg:getContentSize().height/2-3)
						 heroimg:addChild(animation_sp)
						self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function ()
							animation_sp:removeFromParent()
						end)))

						if tonumber(add_level) == 1 then
						 	express_bar:runAction(cc.Sequence:create(cc.ProgressFromTo:create(0.2*(100-express_bar:getPercentage())/100,express_bar:getPercentage(),100),cc.CallFunc:create(function()
						 		heroimg.label_level = heroimg.label_level +1
				               		level_label:setString("LV:"..tonumber(heroimg.label_level))
				                	express_bar:setPercentage(0)
				            end),cc.ProgressFromTo:create(0.2*(target_percent)/100,0,target_percent)))
						else
						 	express_bar:runAction(cc.Sequence:create(cc.ProgressFromTo:create(0.2*(100-express_bar:getPercentage())/100,express_bar:getPercentage(),100),cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(function()
				                    express_bar:setPercentage(0)
				                    heroimg.label_level = heroimg.label_level +1
				                    level_label:setString("LV:"..tonumber(heroimg.label_level))

				                end),cc.ProgressFromTo:create(0.2,0,100)),tonumber(add_level)-1),cc.CallFunc:create(function()
									heroimg.label_level = heroimg.label_level + 1	
				               		level_label:setString("LV:"..tonumber(heroimg.label_level))
				                	express_bar:setPercentage(0)
				            end),cc.ProgressFromTo:create(0.2*(target_percent)/100,0,target_percent)))
						end
					else
						express_bar:runAction(cc.ProgressFromTo:create(0.2*(target_percent-express_bar:getPercentage())/100,express_bar:getPercentage(),target_percent))
					end
				end
			end

			hero_bg:setTouchBeganCallback(function()
				-- print("###setTouchBegan ===========")
				--每次重新开始之前，先把之前的schedule停止，或者点击不同的英雄的时候，先停止之前的schedule
				self:stopScheduler()
				if hero_bg:getChildByName("hero_cover") then
					-- XTHDTOAST("经验值已达上限,无法继续使用道具~")
					hero_bg:setScale(1)
					return
				end

				if self._total_count <= 0   then
					XTHDTOAST(LANGUAGE_TIPS_WORDS202)-----"没有多余的道具可以消耗!")
					hero_bg:setScale(1)
					return
				end

				if tonumber(heroimg.label_level) >=(tonumber(self._top_level)+1) or (tonumber(hero_data["level"]) >=( tonumber(self._top_level)+1)) then
					return
				end
				hero_bg:setScale(0.95)

				schedule(self,function()
					schedule(self, function()
							if self:getActionByTag(10000) then
								self:stopActionByTag(10000)
							end

							cell._scheduler_running = true --标示当前cell正在执行schedule
							self._using =true
							if self._use_count >= self._total_count  then
								self:stopScheduler()
								cell._scheduler_running = false
								XTHDTOAST(LANGUAGE_TIPS_WORDS111)-----"您的道具已经用完啦!")
								hero_bg:setScale(1)
								use_num_label:setVisible(false)
								return
							end
							use_num_label:setVisible(true)
							use_num_label:setOpacity(255)
							
							self._use_count = self._use_count +1
							hero_data._selfCount = hero_data._selfCount + 1
							use_num_label:setString("x"..hero_data._selfCount)
							Add_exp(hero_data["heroid"])

					end, 0.08, 10001)

				end, 1.0, 10000)
			end)
			hero_bg:setTouchMovedCallback(function()
				-- print("###setTouchMoved ===========")
				-- XTHDTOAST("setTouchMovedCallback >>>>>>>>")

				if self._using == false then --没有长按使用
					hero_bg:setScale(1)
					self._isMoving = true
					use_num_label:setVisible(false)
					self:stopScheduler()
					cell._scheduler_running = false
				end
			end)
			hero_bg:setTouchCanceledCallback(function()
				-- print("###setTouchCanceled ===========")
				use_num_label:setVisible(false)
				hero_bg:setScale(1)
				self:stopScheduler()
				cell._scheduler_running = false
				self:RequestNetAndRefreshData(hero_data["heroid"])
				self._cancelToRequest = true

			end)
			hero_bg:setTouchEndedCallback(function()
				-- print("###setTouchEnded ===========")
				-- XTHDTOAST("setTouchEndedCallback >>>>>>>>")
				hero_bg:setScale(1)
				if  hero_bg.enable_callback== false then
					return
				end

				if self._total_count <= 0 then
					return
				end

				self:stopScheduler()
				if self._isMoving then
					use_num_label:setVisible(false)
					self._isMoving = false
					return
				end

				if not self._cancelToRequest then
					if self._use_count == 0 then
						Add_exp(hero_data["heroid"])
						self._use_count =1

						use_num_label:setVisible(true)
						use_num_label:stopAllActions()
						use_num_label:setOpacity(255)

						hero_data._selfCount = hero_data._selfCount + 1
						use_num_label:setString("x"..hero_data._selfCount)
					end
				end

				cell._scheduler_running = false
				self._using = false
				self._cancelToRequest = false

				if hero_bg:getChildByName("hero_cover") then
					hero_bg.enable_callback =false
				end

				use_num_label:runAction(cc.Sequence:create( cc.DelayTime:create(0.2), cc.FadeOut:create(0.2)))
				self:RequestNetAndRefreshData(hero_data["heroid"])
				
			end)

		end
    end
    return cell
end
function XingNangUsePop:getAvatorNode(hero_data)
	-- local heroNode =requires("src/fsgl/layer/XingNang/TouchSprite.lua"):create(XTHD.resource.getQualityHeroBgPath(hero_data["advance"]) )
	local data = gameData.getDataFromCSV("GeneralInfoList")
	local _staticData = {}
	for k, v in pairs(data) do
		_staticData[v.heroid] = v
	end
    _staticData = _staticData[tonumber(hero_data["heroid"])] or {}
    local _advanceValue = _staticData.rank or 1
	local heroNode = cc.Sprite:create(XTHD.resource.getQualityHeroBgPath(_advanceValue))
	local avator_box = cc.Sprite:create(XTHD.resource.getHeroAvatorImgById(hero_data["heroid"]))
	avator_box:setPosition(heroNode:getContentSize().width/2, heroNode:getContentSize().height/2)
	heroNode:addChild(avator_box,-1)
	heroNode:setScale(0.8)

 	local star_number = hero_data["star"]
	local YueLiangnumber = math.floor(star_number / 6)
	star_number = star_number - YueLiangnumber*6
 	local star_pos_arr = SortPos:sortFromMiddle(cc.p(heroNode:getContentSize().width / 2,0) , star_number+YueLiangnumber , 14 + 3)
	for i = 0,YueLiangnumber-1 do
		local moon_sp = cc.Sprite:create("res/image/common/moon_icon.png")
 		moon_sp:setName("moon_sp" .. tostring(i))
 		moon_sp:setAnchorPoint(0.5,0)
		moon_sp:setPosition(star_pos_arr[i+1].x , star_pos_arr[i+1].y+5)
		moon_sp:setScale(0.8)
 		heroNode:addChild(moon_sp)
	end
	
	
 	for i=0,star_number-1 do
 		local star_sp = cc.Sprite:create("res/image/common/item_star.png")
 		star_sp:setName("star_sp" .. tostring(i + YueLiangnumber ))
 		star_sp:setAnchorPoint(0.5,0)
		 star_sp:setPosition(star_pos_arr[i+1+YueLiangnumber].x , star_pos_arr[i+1+YueLiangnumber].y+5)
		 star_sp:setScale(0.8)
 		heroNode:addChild(star_sp)
 	end
 	
	return heroNode
end
--停止升级调度
function XingNangUsePop:stopScheduler()
	self:stopActionByTag(10000)
	self:stopActionByTag(10001)
end

--使用道具之后请求网络
function XingNangUsePop:RequestNetAndRefreshData(heroid)
	self:stopScheduler()

	-- print("###self._cancelToRequest ------> ", self._cancelToRequest)
	if self._cancelToRequest then --每次点击由于cancel而请求的数据只能一次
		return 
	end
	-- print("###request data  =========================================== ")
	-- print("###use_count ---------> ", self._use_count)
	if tonumber(self._total_count) <= 0 or  tonumber(self._use_count) < 1  then
		return
	end
	ClientHttp:requestAsyncInGameWithParams({
		modules = "useItem?",
        params = {itemId=self._Use_data["itemid"],baseId=heroid,param=tostring(self._use_count),charType=1},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
        successCallback = function(data)
        if tonumber(data.result) == 0 then
            	self._use_count = 0
            	local item_data = data["items"][1]
            	self._total_count = tonumber(item_data["count"])
            	-- data["count"] = data["itemCount"]
            	DBTableItem.updateCount(gameUser.getUserId(),item_data,self._Use_data["dbid"])  --更新数据库
            	local callback = self._Use_data.callback
            	if callback then
            		-- data["dbid"] = self._Use_data["dbid"]
            		item_data["dbid"] = item_data["dbId"]
            		callback(item_data)
            	end
            	local property = data.property
            	if property then
            		for i=1,#property do
            			local _tab = string.split(property[i],',')
            			DBUpdateFunc:UpdateProperty("userheros", _tab[1],_tab[2],heroid);
            		end
            	end
        else
            XTHDTOAST(data.msg)
        end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function XingNangUsePop:onExit()
	self._heros_data = nil
	self:stopScheduler()
end
function XingNangUsePop:ctor(params)
	self._Use_data = params
	self:InitUI(params)
end

--[[
	itemid = 1 --物品id
	effect=static_item_info["effectvalue"],
    totalCount = item_data["count"]
    callback =  --使用回调，刷新数据什么的
]]
function XingNangUsePop:create(params)
	local layer = self.new(params)
	layer.beginPos = cc.p(layer:getContentSize().width/2,layer:getContentSize().height/2)
	return layer
end
return XingNangUsePop