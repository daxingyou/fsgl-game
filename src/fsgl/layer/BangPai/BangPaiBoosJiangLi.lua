--2015/12/2
--帮派Boss奖励界面
local BangPaiBoosJiangLi = class("BangPaiBoosJiangLi",function()
		return XTHDPopLayer:create()
	end)
function BangPaiBoosJiangLi:ctor(_data)
    self.rewardIdx = 1
    self.staticFactionBossReward = {}
    self.rewardData = {}
    self:getStaticData()
    self:getRewardData(_data)
	self:initLayer()
end

function BangPaiBoosJiangLi:initLayer()
	local popNode  = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
 	popNode:setContentSize(cc.size(533,400))
 	popNode:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
 	self:addContent(popNode)
 	local _closeBtn = XTHD.createBtnClose(function()
        self:hide()
    end)
    _closeBtn:setPosition(cc.p(popNode:getContentSize().width-10,popNode:getContentSize().height-10))
    popNode:addChild(_closeBtn)

    local title_bg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 50))
    title_bg:setPosition(popNode:getContentSize().width/2,popNode:getContentSize().height - 10)
    popNode:addChild(title_bg)

    local title_font = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_HURTREWARD,------"伤害奖励",
        fontSize = 26,
        color = cc.c3b(104, 33, 11),
        ttf = "res/fonts/def.ttf"
        })
        -- title_font:setAnchorPoint(0.5,0.5)
    title_font:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2 + 3)
    title_bg:addChild(title_font)

    --今日伤害总量
    local total_hurt_sp = cc.Sprite:create("res/image/goldcopy/today_hurt_1.png")
    total_hurt_sp:setAnchorPoint(0,0.5)
    total_hurt_sp:setPosition(title_bg:getPositionX()-title_bg:getContentSize().width/2 + 45,title_bg:getPositionY()-total_hurt_sp:getContentSize().height - 10)
    --popNode:addChild(total_hurt_sp)

    local totalHurt = self.rewardData.totalHurt or 0
    local today_hurt_num = XTHDLabel:createWithParams({fnt = "res/fonts/10/red6.fnt" , text = totalHurt , kerning = -2})
    today_hurt_num:setScale(0.7)
    today_hurt_num:setAnchorPoint(0,0.5)
    today_hurt_num:setPosition(total_hurt_sp:getContentSize().width+total_hurt_sp:getPositionX(),total_hurt_sp:getPositionY())
    --popNode:addChild(today_hurt_num)

	local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(total_hurt_sp:getContentSize().width + today_hurt_num:getContentSize().width + 10,today_hurt_num:getContentSize().height + 10)
	popNode:addChild(node)
	node:setPosition(popNode:getContentSize().width *0.5,title_bg:getPositionY()-total_hurt_sp:getContentSize().height - 10)

	node:addChild(total_hurt_sp)
	total_hurt_sp:setPosition(10,node:getContentSize().height *0.5)
	
	node:addChild(today_hurt_num)
	today_hurt_num:setPosition( total_hurt_sp:getContentSize().width + 10,node:getContentSize().height *0.5 )

    --伤害奖励tableview
    local _tableViewSize = cc.size(popNode:getContentSize().width-10, popNode:getContentSize().height-105)
    self.tableViewCellSize = cc.size(_tableViewSize.width,102)
    local tableview_reward = CCTableView:create( _tableViewSize );
    TableViewPlug.init(tableview_reward)
    tableview_reward:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL );
    tableview_reward:setPosition( cc.p(5, 30) );
    tableview_reward:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN );
    tableview_reward:setBounceable(true);
    tableview_reward:setDelegate();
    self.tableView = tableview_reward
    popNode:addChild(tableview_reward);
    self._tableview = tableview_reward

    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        return  #self.rewardData.list
    end
    local function cellSizeForTable( table, idx )
        return self.tableViewCellSize.width,self.tableViewCellSize.height
    end
    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell();
        if cell == nil then
            cell = cc.TableViewCell:new();
        else
            cell:removeAllChildren()
        end

        local _rewardBg = self:initRewardItem(idx+1)
        _rewardBg:setPosition(cc.p(self.tableViewCellSize.width/2 - 5,self.tableViewCellSize.height/2))
        cell:addChild(_rewardBg)

        return cell
    end

    tableview_reward:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableview_reward.getCellNumbers=numberOfCellsInTableView
    tableview_reward:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableview_reward.getCellSize=cellSizeForTable
    tableview_reward:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    tableview_reward:reloadData()

    self:show()
end

function BangPaiBoosJiangLi:initRewardItem(_idx)
	local _rewardItemBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
	_rewardItemBg:setContentSize(cc.size(505,94))

    local _rewardItemData = self.rewardData.list[_idx] or {}
    local _rewardStaticData = self.staticFactionBossReward[self.rewardData.list[_idx].configId] or {}

    local _hurtTitle = XTHDLabel:create(LANGUAGE_TIPS_WORDS99,20)
    _hurtTitle:setAnchorPoint(cc.p(0,0.5))
    _hurtTitle:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _hurtTitle:setPosition(cc.p(20,_rewardItemBg:getContentSize().height/2))
    _rewardItemBg:addChild(_hurtTitle)

    local _hurtValue = XTHDLabel:create(getHugeNumberWithLongNumber(_rewardStaticData.damge or 0,10000),22)
    _hurtValue:setAnchorPoint(cc.p(0.5,0.5))
    _hurtValue:setColor(BangPaiFengZhuangShuJu.getTextColor("hongse"))
    _hurtValue:enableShadow(BangPaiFengZhuangShuJu.getTextColor("hongse"),cc.size(0.4,-0.4),0.4)
    _hurtValue:setPosition(cc.p(_hurtTitle:getBoundingBox().x+_hurtTitle:getBoundingBox().width+30,_rewardItemBg:getContentSize().height/2))
    _rewardItemBg:addChild(_hurtValue)

    local _itemPosX = 310
    local _rewardNum = 1
    local _itemNodePos = SortPos:sortFromMiddle(cc.p(_itemPosX,_rewardItemBg:getContentSize().height/2) ,_rewardNum,60+7)
    for i=1,_rewardNum do
        local _rewardItemSp = ItemNode:createWithParams({
            _type_ = XTHD.resource.type.guild_contri,
            itemId = nil,
            count = _rewardStaticData.reward or 0,
            isShowCount = true,
        })
        _rewardItemSp:setScale(60/_rewardItemSp:getContentSize().width)
        _rewardItemSp:setPosition(_itemNodePos[i])
        _rewardItemBg:addChild(_rewardItemSp)
    end

    local _btnText = LANGUAGE_BTN_KEY.noAchieve
    local _textColor = XTHD.resource.btntextcolor.red
    local _btnImg = "write"
    local _isBtn = true
    if _rewardItemData.state and _rewardItemData.state ~= 0 then
        if _rewardItemData.state == 2 then
            _btnText = LANGUAGE_BTN_KEY.getReward
        else
            _btnText = LANGUAGE_BTN_KEY.rewarded
            _isBtn = false
        end
        _textColor = XTHD.resource.btntextcolor.green
        _btnImg = "write_1"
    end
    local _rewardBtn = nil
    local _rewardPosY = _rewardItemBg:getContentSize().height/2
    if _isBtn ==true then
        _rewardBtn = XTHD.createButton({
            normalFile = "res/image/common/btn/btn_" .. _btnImg .. "_up.png",
            selectedFile = "res/image/common/btn/btn_" .. _btnImg .. "_down.png",
            label = XTHDLabel:create(_btnText,26,"res/fonts/def.ttf"),
            fontColor = cc.c3b(255,255,255),
        })
        if _btnImg == "write_1" then
            --可领取的时候按钮的特效
            local rewardSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)
            rewardSpine:setName("rewardSpine")
            _rewardBtn:addChild( rewardSpine )
            rewardSpine:setPosition( _rewardBtn:getContentSize().width*0.5+7, _rewardBtn:getContentSize().height/2+2 )
            rewardSpine:setAnimation( 0, "querenjinjie", true)
            --描边
            _rewardBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
        else
            _rewardBtn:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
        end
        _rewardBtn:setScale(0.7)
        _rewardBtn:setTouchEndedCallback(function()
            self:rewardBtnCallback(_idx,function()
                    -- _rewardBtn:getLabel():setString(LANGUAGE_BTN_KEY.rewarded)
                    if _rewardBtn:getChildByName("rewardSpine") then
                        _rewardBtn:removeChildByName("rewardSpine")
                    end
                    local _posx = _rewardBtn:getPositionX()
                    _rewardBtn:removeFromParent()
                    _rewardBtn = cc.Sprite:create("res/image/vip/yilingqu.png")
                    _rewardBtn:setScale(0.7)
                    _rewardBtn:setPosition(cc.p(_posx,_rewardPosY))
                    _rewardItemBg:addChild(_rewardBtn)
                end)
        end)
    else
        _rewardBtn = cc.Sprite:create("res/image/vip/yilingqu.png")
        _rewardBtn:setScale(0.7)
    end
    _rewardBtn:setAnchorPoint(cc.p(0.5,0.5))
    _rewardBtn:setPosition(cc.p(_rewardItemBg:getContentSize().width - 65,_rewardPosY))
    _rewardItemBg:addChild(_rewardBtn)
	return _rewardItemBg
end

function BangPaiBoosJiangLi:rewardBtnCallback(_idx,_callback)
    ClientHttp:httpGuild( "guildBossHurtRewar?", self, function(_data)
            local mDatas = BangPaiFengZhuangShuJu.getGuildData()
            if mDatas.list and #mDatas.list > 0 then
                for k,v in pairs(mDatas.list) do
                    if v.charId == gameUser.getUserId() then
                        v.dayContribution = tonumber(_data.dayContribution) or 0
                        v.totalContribution = tonumber(_data.totalContribution) or 0
                        break
                    end
                end
            end
            BangPaiFengZhuangShuJu.setGuildData(mDatas)
            -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
            self.rewardData.list[tonumber(_idx)].state = 1
			self.rewardData.list = self:SortList(self.rewardData.list)

            local _rewardData = self.staticFactionBossReward[tonumber(_idx)]
            local _rewardTable = {}
            _rewardTable[1] = {rewardtype = tonumber(XTHD.resource.type.guild_contri),id =0,num = tonumber(_rewardData.reward or 0)}
            ShowRewardNode:create(_rewardTable)
            if _callback~=nil then
                _callback()
            end
            if self.rewardData.list[_idx].state and self.rewardData.list[_idx].state ~= 2 then
                XTHD.dispatchEvent({name = "GuildBossreward2",data = {["name"] = "reward",["visible"] = self.rewardData.list[_idx].state}})
            end
            ClientHttp:httpGuild( "guildBossHurtRewarList?", self, function(_data)
                local dataList = _data.list
                for i=1,#dataList do
                    XTHD.dispatchEvent({name = "GuildBossreward",data = {["name"] = "reward",["visible"] = dataList[i]["state"]}})
                end
            end)
			self._tableview:reloadData()
        end,{configId = self.rewardData.list[_idx].configId})
end


function BangPaiBoosJiangLi:scrollToRewardCell()
    if self.rewardIdx == nil or self.tableView==nil then
        return 
    end
    local _flag = true
    self.tableView:scrollToCell(self.rewardIdx - 1,_flag)
end

function BangPaiBoosJiangLi:getRewardData(_data)
    self.rewardData = {}
    table.sort(_data.list,function(data1,data2)
            return tonumber(data1.configId)<tonumber(data2.configId)
        end)
    for i=1,#_data.list do
        if _data.list[i].state and tonumber(_data.list[i].state)==2 then
            self.rewardIdx = _data.list[i].configId
            break
        elseif _data.list[i].state and tonumber(_data.list[i].state)==0 then
            break
        end
    end
	_data.list = self:SortList(_data.list)
    self.rewardData = _data
end

function BangPaiBoosJiangLi:SortList( _table )
	local list_1,list_2,list_3 = {},{},{}
	for k,v in pairs(_table) do
		if v.state == 0 then
			list_2[#list_2 + 1] = v
		elseif v.state == 2 then
			list_1[#list_1 + 1] = v
		else
			list_3[#list_3 + 1] = v
		end
	end
	local listData = {}
	_table = {}
	for k,v in pairs(list_1) do
		listData[#listData + 1] = v
	end

	for k,v in pairs(list_2) do
		listData[#listData + 1] = v
	end

	for k,v in pairs(list_3) do
		listData[#listData + 1] = v
	end
	_table = listData
	return _table
end

function BangPaiBoosJiangLi:getStaticData()
    self.staticFactionBossReward = {}
    self.staticFactionBossReward = gameData.getDataFromCSV("SectBossReward")
end

function BangPaiBoosJiangLi:create(_data)
	local _layer = self.new(_data)
	return _layer
end

return BangPaiBoosJiangLi