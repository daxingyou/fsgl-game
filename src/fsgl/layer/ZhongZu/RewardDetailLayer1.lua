local RewardDetailLayer1 = class("RewardDetailLayer1",function( )
	return XTHDPopLayer:create()
end)

function RewardDetailLayer1:create( )
    local reward = RewardDetailLayer1.new()
    if reward then 
        reward:init()
    end 
    return reward
end

function RewardDetailLayer1:init( )
    ---背景
    local back = ccui.Scale9Sprite:create("res/image/common/scale9_bg_2.png")  
    back:setContentSize(cc.size(524,465))   
    back:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addContent(back)
    self:getContainerLayer():setClickable(false)
    ---黄色标头背景
    local titleBG = cc.Sprite:create("res/image/camp/camp_reward_bg2.png")
    back:addChild(titleBG)
    titleBG:setPosition(back:getContentSize().width / 2,back:getContentSize().height - titleBG:getBoundingBox().height / 2 - 3)
    ---关闭按钮
    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    back:addChild(close)
    close:setPosition(back:getContentSize().width - 5,back:getContentSize().height - 5)

    -----奖励领取说明 
    local _tips = cc.Sprite:create("res/image/camp/map/camp_label7.png")
    titleBG:addChild(_tips)
    _tips:setPosition(titleBG:getBoundingBox().width / 2,titleBG:getBoundingBox().height / 2)

    local viewSize = cc.size(back:getContentSize().width - 26,back:getContentSize().height - titleBG:getBoundingBox().height - 6)
    self:initList(back,viewSize)

end

function RewardDetailLayer1:initList(targ,viewSize)
	local cellSize = cc.size(viewSize.width,90)
	
	local function cellSizeForTable(table,idx)
        return cellSize.width,cellSize.height
    end

    local function numberOfCellsInTableView(table)
        return #ZhongZuDatas._serverBasic.weekReward
    end

    local function tableCellTouched(table,cell)
    end
    
    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else 
        	cell:removeAllChildren()
        end
        local node = self:createRewardCell(idx + 1,cellSize)
        cell:addChild(node)
        node:setAnchorPoint(0,0)
        node:setPosition(0,0)
        cell.node = node
        return cell
    end

    local tableView = CCTableView:create(viewSize)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(15,10)
    tableView:setBounceable(true)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)    

	tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    targ:addChild(tableView)
end 

function RewardDetailLayer1:createRewardCell( index,cellSize)
    local node = ccui.Scale9Sprite:create("res/image/common/scale9_bg_12.png")
    node:setContentSize(cc.size(cellSize.width,cellSize.height - 5))    
    if ZhongZuDatas._serverBasic.weekReward and ZhongZuDatas._localReward then 
        local serverData = ZhongZuDatas._serverBasic.weekReward[index]
        local localData = ZhongZuDatas._localReward[tonumber(serverData.configId)]
        local selfFoce = 0
        if gameUser.getCampID() == 1 then 
            selfFoce = ZhongZuDatas._serverBasic.aForce
        else 
            selfFoce = ZhongZuDatas._serverBasic.bForce
        end 
        ---领取按钮
        local _btnColor = "green"
        local str = "res/image/camp/camp_reward_get.png"
        local hasButton = true
        local _btnText = LANGUAGE_BTN_KEY.getReward
        if tonumber(serverData.state) == 1 then ---已领取
            str = "res/image/camp/camp_reward_getted.png"
            hasButton = false
            _btnColor = nil
            _btnText = LANGUAGE_BTN_KEY.getReward
        elseif selfFoce < localData.parameter then ----未完成             
            _btnColor = "red"
            _btnText = LANGUAGE_BTN_KEY.noAchieve
        end 
        ---按钮上的文字 
        local word = cc.Sprite:create(str)
        if hasButton then 
            local getBtn = XTHD.createCommonButton({
                text = _btnText,
                isScrollView = true,
                btnColor = _btnColor,
                btnSize = cc.size(102,46)
            })
            node:addChild(getBtn)
            getBtn:setPosition(node:getContentSize().width - 77,node:getContentSize().height / 2)
            getBtn:setTag(index)
            getBtn:setTouchEndedCallback(function( )            
                self:getWeeklyReward(getBtn:getTag(),getBtn)
            end)
        else
            node:addChild(word)
            word:setPosition(node:getContentSize().width - 77,node:getContentSize().height / 2)
        end 
        word:setTag(1)
        -----文字打醒 
        local tips = XTHDLabel:createWithParams({
            text = LANGUAGE_CAMP_TIPSWORDS25,
            fontSize = 18,
            color = XTHD.resource.color.brown_desc,
        })
        node:addChild(tips)
        tips:setAnchorPoint(0,0.5)
        tips:setPosition(20,node:getContentSize().height / 2)
        ----条件
        local _amount = XTHDLabel:createWithParams({
            text = localData.parameter,
            fontSize = 20,
            color = cc.c3b(178,27,27),
        })
        node:addChild(_amount)
        _amount:setAnchorPoint(0,0.5)
        _amount:setPosition(tips:getPositionX() + tips:getContentSize().width + 10,tips:getPositionY())
        ---图标
        local icon = ItemNode:createWithParams({
            _type_ = localData.rewardItemType,
            count = localData.rewardAmoun,          
        })
        node:addChild(icon)
        icon:setScale(0.8)
        icon:setPosition(node:getContentSize().width / 2,node:getContentSize().height / 2)
        node.iconNode = icon
    end 
    return node 
end

return RewardDetailLayer1