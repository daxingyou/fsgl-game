-- Created By Liuluyang 2015年04月10日
ShowRewardNode = class("ShowRewardNode", function()
    return XTHDDialog:create()
end )
-- 领取成功，合成成功，动画

function ShowRewardNode:ctor(params)
    self._parent = params.target
    self._zorder = params.zorder or 20
	self._showLineNum = params.showData.showLineNum or false

    self.callback = params.callback
    self:setName("ShowRewardNode")
    local param = { }
    for i = 1, #params.showData do
        if params.showData[i].rewardtype > 0 then
            param[#param + 1] = params.showData[i]
        end
    end
    self:runAction(cc.FadeTo:create(0.3, 70))
    local bg = cc.ProgressTimer:create(cc.Sprite:create("res/image/plugin/showreward/reward_bg.png"))
    local bglayer = XTHDImage:create()
    bglayer:setAnchorPoint(0.5, 0.5)
    bglayer:setContentSize(bg:getBoundingBox().width, bg:getBoundingBox().height)
    if params.pos then
        bglayer:setPosition(params.pos[1], params.pos[2])
    else
        bglayer:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    end
    self:addChild(bglayer)
    self.popNode = bglayer
    bg:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    bg:setBarChangeRate(cc.p(1, 0))
    bg:setMidpoint(cc.p(0.5, 0.5))
    bg:setPosition(bglayer:getContentSize().width / 2, bglayer:getContentSize().height / 2)
    bglayer:addChild(bg, 0)
    self._bg = bg
    local rewardReelLeft = cc.Sprite:create("res/image/plugin/showreward/reward_reel.png")
    rewardReelLeft:setPosition(bglayer:getBoundingBox().width / 2 - rewardReelLeft:getBoundingBox().width / 2, bg:getBoundingBox().height / 2)
    bglayer:addChild(rewardReelLeft, 1)

    local rewardReelRight = cc.Sprite:create("res/image/plugin/showreward/reward_reel.png")
    rewardReelRight:setPosition(bglayer:getBoundingBox().width / 2 + rewardReelRight:getBoundingBox().width / 2, bg:getBoundingBox().height / 2)
    bglayer:addChild(rewardReelRight, 1)

    bg:setPercentage(8.45)
    bg:runAction(cc.EaseOut:create(cc.ProgressTo:create(0.1, 100), 1.5))

    rewardReelLeft:runAction(cc.Sequence:create((cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(bg:getPositionX() - bg:getBoundingBox().width / 2 - rewardReelLeft:getBoundingBox().width / 3, bg:getBoundingBox().height / 2)), 1.5)), cc.MoveBy:create(0.05, cc.p(rewardReelLeft:getBoundingBox().width / 3, 0))))
    rewardReelRight:runAction(cc.Sequence:create((cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(bg:getPositionX() + bg:getBoundingBox().width / 2 + rewardReelLeft:getBoundingBox().width / 3, bg:getBoundingBox().height / 2)), 1.5)), cc.MoveBy:create(0.05, cc.p(- rewardReelLeft:getBoundingBox().width / 3, 0))))

    local _type = params._type or 1
    local titleSpine = sp.SkeletonAnimation:create("res/spine/effect/show_reward/lingquziti.json", "res/spine/effect/show_reward/lingquziti.atlas", 1.0)
    if _type == 3 then
        titleSpine = sp.SkeletonAnimation:create("res/spine/effect/show_reward/lqcg.json", "res/spine/effect/show_reward/lqcg.atlas", 1.0)
    end
    titleSpine:setTimeScale(0.5)
    titleSpine:setPosition(bglayer:getBoundingBox().width / 2, bglayer:getBoundingBox().height / 2 + 200)
    bglayer:addChild(titleSpine, 2)
    if _type == 1 then
        -- 领取成功
        titleSpine:setAnimation(0.5, "lqcg", false)
        titleSpine:setAnimation(0.5, "lqcg_loop", true)
        titleSpine:setPosition(bglayer:getBoundingBox().width / 2, bglayer:getBoundingBox().height / 2 + 50)
    elseif _type == 2 then
        -- 合成成功
        titleSpine:setAnimation(0.5, "hcjg", false)
        titleSpine:setAnimation(0.5, "hcjg_loop", true)
        titleSpine:setPosition(bglayer:getBoundingBox().width / 2, bglayer:getBoundingBox().height / 2 + 50)
    elseif _type == 3 then
        -- 任务奖励
        titleSpine:setAnimation(0.5, "rwjl", false)
    elseif _type == 4 then
        -- 我的奖品

    end
    local closeLabel = XTHDLabel:createWithParams( {
        text = LANGUAGE_KEY_CLICKTOCONTINUER,
        -------"点击任意区域继续",
        fontSize = 18,
        color = cc.c3b(0,0,0),
        anchor = cc.p(0.5,0),
    } )
    closeLabel:setPosition(bglayer:getBoundingBox().width / 2, -20)
    bglayer:addChild(closeLabel)
    closeLabel:setOpacity(0)

    local closeDelay = 1
    if gameUser.getLevel() > 20 then
        closeDelay = 0.5
    end

    self.CloseBtn = XTHDPushButton:createWithParams( {
        touchSize = cc.size(10000,10000),
        endCallback = function()
            self:removeFromParent()
        end
    } )
    self.CloseBtn:setPosition(bglayer:getBoundingBox().width / 2, bglayer:getBoundingBox().height / 2)
    bglayer:addChild(self.CloseBtn)
    self.CloseBtn:setEnable(false)

    bglayer:runAction(cc.Sequence:create(cc.DelayTime:create(closeDelay), cc.CallFunc:create( function()
        self.CloseBtn:setEnable(true)
        closeLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1), cc.FadeOut:create(1))))
    end )))
    local rewardNum = table.nums(param)
    if rewardNum < 9 then

        for i = 1, #param do
            if param[i].rewardtype and param[i].num then
                local _isLight = param[i].rewardtype == XTHD.resource.type.ingot and true or false
                local item = ItemNode:createWithParams( {
                    _type_ = param[i].rewardtype,
                    dbId = param[i].dbId,
                    itemId = param[i].id,
                    needSwallow = true,
                    count = param[i].num,
                    isShowCount = true,
                    isLightAct = _isLight,-- 是否有特效
                } )
                item:setClickable(false)
                if item then
                    local posY = bg:getBoundingBox().height / 2
                    if #param > 4 then
                        if i > 4 then
                            posY = bg:getBoundingBox().height / 2 - 60 + 10
                        else
                            posY = bg:getBoundingBox().height / 2 + 60 + 10
                        end
                    end
                    item:setPosition(XTHD.resource.getPosInArr( {
                        lenth = 50,
                        bgWidth = bg:getBoundingBox().width,
                        num = #param > 4 and 4 or #param,
                        nodeWidth = item:getBoundingBox().width,
                        now = i > 4 and i - 4 or i,
                    } ), posY)

                    item:setScale(2)
                    item:setOpacity(0)
                    bg:addChild(item, 1)
                    item:runAction(cc.Sequence:create(cc.DelayTime:create(0.1 + i *(0.2 -(i * 0.01))), cc.Spawn:create(cc.FadeIn:create(0.2),
                    cc.Sequence:create(cc.DelayTime:create(0.1), cc.ScaleTo:create(0.15, 0.8), cc.CallFunc:create( function()
                        -- item:setEnableTouch(true)
                        local Ashes = cc.Sprite:create("res/image/common/hero_orangeBg.png")
                        Ashes:setPosition(item:getPositionX(), item:getPositionY())
                        bg:addChild(Ashes)
                        Ashes:runAction(cc.Spawn:create(cc.FadeOut:create(0.3), cc.ScaleTo:create(0.6, 1.2)))

                        local itemName = XTHDLabel:createWithParams( {
                            text = item._Name,
                            fontSize = 18,
                            color = XTHD.resource.color.gray_desc
                        } )
                        itemName:setAnchorPoint(0.5, 1)
                        itemName:setPosition(item:getPositionX(), item:getPositionY() - item:getBoundingBox().height / 2 - 10)
                        bg:addChild(itemName)
                        itemName:setOpacity(0)
                        itemName:runAction(cc.FadeIn:create(0.3))
                    end ),
                    cc.ScaleTo:create(0.07, 0.9), cc.ScaleTo:create(0.03, 0.8), cc.CallFunc:create( function()
                        item:setClickable(true)
                    end )))))
                end
            end
        end
    else
        -- 如果奖励多于8个以上的，创建tablview
        self:createRewardTablview(param, rewardNum)
    end

    if cc.Director:getInstance():getRunningScene():getChildByName("ShengJiLayer") then
        cc.Director:getInstance():getRunningScene():getChildByName("ShengJiLayer"):setVisible(false)
    end
    if self._parent then
        self._parent:addChild(self, self._zorder)
    else
        cc.Director:getInstance():getRunningScene():addChild(self)
    end


    -- 如果有引导提示文字
    -- params.guideText = LANGUAGE_TIPS_WORDS280
    if params.guideText and string.len(params.guideText) > 0 then
        --
        local newPop = requires("src/fsgl/layer/common/ShowRewardMask1.lua"):create( {
            callback = function()

                bg:setVisible(false)
                local newbg = XTHD.createSprite("res/image/plugin/showreward/reward_bg.png")
                newbg:setPosition(bglayer:getContentSize().width / 2, bglayer:getContentSize().height / 2)
                bglayer:addChild(newbg, 0)
                local myLab = XTHDLabel:createWithParams( {
                    text = tostring(params.guideText),
                    fontSize = 20,
                    color = XTHD.resource.color.brown_desc,
                    anchor = cc.p(0.5,1),
                    pos = cc.p(self:getContentSize().width / 2,self:getContentSize().height / 2 + 80),
                } )
                self:addChild(myLab)
                myLab:setWidth(500)

                -- play action
                myLab:setVisible(false)
                local _textList = XTHD.getTextSplitList(myLab:getString())
                myLab:setString("")
                myLab:setVisible(true)
                if #_textList <= 1 then
                    return
                end
                local _textOrder = 1
                local _labelFunc = function()
                    myLab:setString(_textList[_textOrder])
                    if _textOrder >= #_textList then
                        myLab:stopActionByTag(2104)
                    end
                    _textOrder = _textOrder + 1
                end
                schedule(myLab, _labelFunc, 0.01, 2104)

                self.CloseBtn:setTouchEndedCallback( function()
                    if _textOrder >= #_textList then
                        self:removeFromParent()
                    else
                        myLab:setString(_textList[#_textList])
                        _textOrder = #_textList
                    end
                end )

            end
        } )
        if self._parent then
            self._parent:addChild(newPop, self._zorder)
        else
            cc.Director:getInstance():getRunningScene():addChild(newPop)
        end
    end
end

function ShowRewardNode:createRewardTablview(param, rewardNum)
    performWithDelay(self, function()

        local SwallowTouch = XTHDPushButton:createWithParams( {
            -- 用于遮挡触摸 防止关闭窗口
            touchSize = self._bg:getBoundingBox()
        } )
        SwallowTouch:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self:addChild(SwallowTouch, 1)

        -- how much lines
        local lineNum = math.floor((rewardNum - 1) / 4) + 1

        local _tableViewSize = cc.size(540, 240)
        local _tableViewCellSize = cc.size(540, 120)
        self._tableView = CCTableView:create(_tableViewSize)
        self._tableView:setAnchorPoint(cc.p(0.5, 0.5))
        self._tableView:setPosition(-270, -120)
        self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self._tableView:setDelegate()


        SwallowTouch:addChild(self._tableView)

        local function numberOfCellsInTableView(table)
            return lineNum
        end
        local function cellSizeForTable(table, idx)
            return _tableViewCellSize.width, _tableViewCellSize.height
        end
        local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()
            if cell then
                cell:removeAllChildren()
            else
                cell = cc.TableViewCell:create()
            end
			if not self._showLineNum then
				for i = 1, 4 do
					if (idx * 4 + i) < rewardNum + 1 then
						local _isLight = param[idx * 4 + i].rewardtype == XTHD.resource.type.ingot and true or false
						local item = ItemNode:createWithParams( {
							_type_ = param[idx * 4 + i].rewardtype,
							dbId = param[idx * 4 + i].dbId,
							itemId = param[idx * 4 + i].id,
							needSwallow = false,
							count = param[idx * 4 + i].num,
							isShowCount = true,
							isLightAct = _isLight,-- 是否有特效
						} )
						if item then
							item:setClickable(true)
							item:setScale(0.8)
							item:setPosition(90 +(i - 1) * 120, 70)
							cell:addChild(item)

							local itemName = XTHDLabel:createWithParams( {
								text = item._Name,
								fontSize = 18,
								color = XTHD.resource.color.gray_desc
							} )
							itemName:setAnchorPoint(0.5, 1)
							itemName:setPosition(item:getPositionX(), item:getPositionY() - item:getBoundingBox().height / 2 - 10)
							cell:addChild(itemName)
						end
					end
				end
			else
				self._tableView:setTouchEnabled(false)
				for i = 1, 5 do
					if (idx * 5 + i) < rewardNum + 1 then
						local _isLight = param[idx * 5 + i].rewardtype == XTHD.resource.type.ingot and true or false
						local item = ItemNode:createWithParams( {
							_type_ = param[idx * 5 + i].rewardtype,
							dbId = param[idx * 5 + i].dbId,
							itemId = param[idx * 5 + i].id,
							needSwallow = false,
							count = param[idx * 5 + i].num,
							isShowCount = true,
							isLightAct = _isLight,-- 是否有特效
						} )
						if item then
							item:setClickable(true)
							item:setScale(0.7)
							item:setPosition(60 +(i - 1) * 105, 70)
							cell:addChild(item)

							local itemName = XTHDLabel:createWithParams( {
								text = item._Name,
								fontSize = 18,
								color = XTHD.resource.color.gray_desc
							} )
							itemName:setAnchorPoint(0.5, 1)
							itemName:setPosition(item:getPositionX(), item:getPositionY() - item:getBoundingBox().height / 2 - 10)
							cell:addChild(itemName)
						end
					end
				end
			end
            return cell
        end
        self._tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self._tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self._tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        self._tableView:reloadData()

    end , 0.25)

end

function ShowRewardNode:createByItemId(param)
    --[[
		从item表里按id取
		param = {
			{id = xxx,num = xxx},
			{id = xxx,num = xxx},
			{id = xxx,num = xxx}
		}
	]]
    if #param == 0 then
        return
    end
    local newParam = { }
    for i = 1, #param do
        local tmpParam = { }
        tmpParam.rewardtype = 4
        if param[i].dbId then
            tmpParam.dbId = param[i].dbId
        else
            tmpParam.id = param[i].id
        end
        tmpParam.num = param[i].num
        newParam[#newParam + 1] = tmpParam
    end
    self:create(newParam)
end

function ShowRewardNode:createByType(param)
    --[[
		1经验 2银两 3元宝 5体力
		param = {
			{rewardtype = 1,num = xxx},
			{rewardtype = 2,num = xxx},
			{rewardtype = 3,num = xxx},
			{rewardtype = 5,num = xxx}
		}
	]]
    if #param == 0 then
        return
    end
    local newParam = { }
    for i = 1, #param do
        local tmpParam = { }
        if param[i].rewardtype == 1 or param[i].rewardtype == 2 or param[i].rewardtype == 3 or param[i].rewardtype == 5 then
            tmpParam.rewardtype = param[i].rewardtype
            tmpParam.num = param[i].num
            newParam[#newParam + 1] = tmpParam
        end
    end
    self:create(newParam)
end

function ShowRewardNode:create(param, _type, callback, pos)
    musicManager.playEffect("res/sound/GetReward.mp3", false)
    --[[
		如果可能获得道具也可能获得 经验 银两 元宝 体力
		如果是道具 rewardtype传4 id传对应物品id 或者dbid
		其他 1经验 2银两 3元宝 5体力 id不用传
		param = {
			{rewardtype = 1,num = xxx},
			{rewardtype = 4,id = xxx,num = xxx},
			{rewardtype = 4,dbid = xxx,num = xxx},
			{rewardtype = 5,num = xxx}
		}
	]]
    if #param == 0 then
        return
    end
    -- for i=1,#param do
    -- 	if not param[i].rewardtype then
    -- 		table.remove(param,i)
    -- 	end
    -- end
	
	-- 物品类型：0其他货币 1经验 2金币 3钻石 4道具 5体力 6翡翠(priorities[物品类型]=权重})
    local priorities = { }
    priorities[3] = 1
    priorities[6] = 2
    priorities[2] = 3
    priorities[1] = 4
    priorities[5] = 5
    priorities[0] = 6
    priorities[4] = 7

    table.sort(param, function(item1, item2)
        local p1 = priorities[item1.rewardtype] or priorities[0]
        local p2 = priorities[item2.rewardtype] or priorities[0]
        if item1.rewardtype == 4 and item2.rewardtype == 4 then
            -- 道具判断标准由品质高到低(rank值越大品质越高)
			local itemInfo1
            if item1.id then
                itemInfo1 = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = item1.id })
            else
                local UserData = DBTableItem.getData(gameUser.getUserId(), { dbid = item1.dbId })
                itemInfo1 = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = UserData.itemid })
            end
            
            local itemInfo2
            if item2.id then
                itemInfo2 = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = item2.id })
            else
                local UserData = DBTableItem.getData(gameUser.getUserId(), { dbid = item2.dbId })
                itemInfo2 = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = UserData.itemid })
            end
            return itemInfo1.rank > itemInfo2.rank
        else
            return p1 < p2
        end
    end )
	
    ShowRewardNode.new( { showData = param, _type = _type, callback = callback, pos = pos })

end
function ShowRewardNode:createWithParams(params)
    musicManager.playEffect("res/sound/GetReward.mp3", false)
    if not params and #params == 0 then
        return
    end
    --[[
	local params = {
		showData = nil,
		_type = nil,
		callback = nil,
		pos = nil,
		guideText = "", --引导文字
		target = parent,
		zorder = 20
	}
	]]
    ShowRewardNode.new(params)
end

function ShowRewardNode:onEnter()

end

function ShowRewardNode:onCleanup()
    if self.callback and type(self.callback) == "function" then
        self.callback()
    end
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/plugin/showreward/reward_bg.png")
    textureCache:removeTextureForKey("res/image/plugin/showreward/reward_reel.png")
end

function ShowRewardNode:onExit()
    if cc.Director:getInstance():getRunningScene():getChildByName("ShengJiLayer") then
        cc.Director:getInstance():getRunningScene():getChildByName("ShengJiLayer"):setVisible(true)
    end
end

return ShowRewardNode