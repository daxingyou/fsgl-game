--赏金猎人奖励界面
--@author hezhitao 2015.0.20
local ShangJinLieRenRewardPop = class("ShangJinLieRenRewardPop",function()
    return XTHDPopLayer:create()
end)

local fontColor = cc.c3b(53,25,26)  --通用字体颜色
function ShangJinLieRenRewardPop:ctor(data,totalHurt,_rank)

    self:initData()
    self:init(data,totalHurt, _rank)
    self:show()

end
function ShangJinLieRenRewardPop:initData()
    local static = gameData.getDataFromCSV("SilverGmaeRankAward")
    self._rankData = {}
    for i = 1, #static do
        self._rankData[i] = {}
        if tonumber(static[i].mix) == tonumber(static[i].max) then
            self._rankData[i].name = LANGUAGE_GET_RANK(static[i].mix)
        elseif tonumber(static[i].max) > tonumber(static[i].mix) then
            self._rankData[i].name = LANGUAGE_GET_RANK(static[i].mix,static[i].max)
        end
        self._rankData[i].rewardtype = XTHD.resource.type.gold
        self._rankData[i].num = static[i].reward
    end
end

function ShangJinLieRenRewardPop:init(data,totalHurt, _rank)

    self._reward_arr = {}  --存放伤害奖励cell数据
    self._tableview = nil
    self._reward_arr = data

    local tableview_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
    tableview_bg:setContentSize(533,456)
    local popNode = XTHDPushButton:createWithParams({
        normalNode = tableview_bg
    })
    popNode:setTouchEndedCallback(function ()
        
    end)
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addContent(popNode)
    self.popNode = popNode
    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(tableview_bg:getContentSize().width,tableview_bg:getContentSize().height)
    tableview_bg:addChild(close)

    local title_bg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 50))
    title_bg:setPosition(tableview_bg:getContentSize().width/2,tableview_bg:getContentSize().height-5)
    tableview_bg:addChild(title_bg)

    local title_font = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_HURTREWARD,------"伤害奖励",
        fontSize = 26,
        color = cc.c3b(106,36,13)
    })
    title_font:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2+5)
    title_bg:addChild(title_font)
    self._title_font = title_font

    --今日伤害总量
    local total_hurt_sp = cc.Sprite:create("res/image/goldcopy/today_hurt_1.png")
    total_hurt_sp:setAnchorPoint(0.5, 0)
    total_hurt_sp:setPosition(tableview_bg:getContentSize().width/2 - 20, 20)
    tableview_bg:addChild(total_hurt_sp)
    local today_hurt_num = self:getArtFont(totalHurt)
    today_hurt_num:setScale(0.6)
    today_hurt_num:setAnchorPoint(0,0)
    tableview_bg:addChild(today_hurt_num)
    total_hurt_sp:setPositionX(tableview_bg:getContentSize().width/2-today_hurt_num:getContentSize().width/2)
    today_hurt_num:setPosition(total_hurt_sp:getContentSize().width/2+5+total_hurt_sp:getPositionX(),total_hurt_sp:getPositionY()+4)
    self._total_hurt_sp = total_hurt_sp
    self._today_hurt_num = today_hurt_num
    --我的排行
    self._myRank = cc.Sprite:create("res/image/goldcopy/wodepaihang.png")
    self._myRank:setAnchorPoint(0, 0)
    self._myRank:setPosition(20, 20)
    tableview_bg:addChild(self._myRank)
    if type(_rank) == "number" then
        self._rankNum = cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt", _rank)
        self._rankNum:setScale(0.7)
        self._rankNum:setAnchorPoint(0,0)
        self._rankNum:setPosition(self._myRank:getContentSize().width+5+self._myRank:getPositionX(),self._myRank:getPositionY()-2)
        tableview_bg:addChild(self._rankNum)
    else
        self._rankNum = XTHDLabel:createWithParams({
            text = _rank,
            fontSize = 20,
            color = XTHD.resource.color.brown_desc,
            anchor = cc.p(0, 0),
            pos = cc.p(self._myRank:getContentSize().width+5+self._myRank:getPositionX(),self._myRank:getPositionY()),
        })
        tableview_bg:addChild(self._rankNum)
    end
    self._sendLab = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_PAIHANG_SEND,
        fontSize = 20,
        color = XTHD.resource.color.red_desc,
        anchor = cc.p(0, 0),
        pos = cc.p(self._rankNum:getContentSize().width+self._rankNum:getPositionX()+25, 20),
        -- anchor = cc.p(0.5, 0),
        -- pos = cc.p(tableview_bg:getContentSize().width/2, 10),
    })
    tableview_bg:addChild(self._sendLab )

    -- tableView背景
    local rewardBg = ccui.Scale9Sprite:create()
    rewardBg:setContentSize( cc.size(515, tableview_bg:getContentSize().height-80) )
    rewardBg:setAnchorPoint( cc.p( 0.5, 0 ) )
    rewardBg:setPosition( tableview_bg:getContentSize().width*0.5, 46 )
    tableview_bg:addChild( rewardBg )

    --伤害奖励tableview
    local tableview_reward = CCTableView:create( cc.size(rewardBg:getContentSize().width-10, rewardBg:getContentSize().height-10) );
    TableViewPlug.init(tableview_reward)
    tableview_reward:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL );
    tableview_reward:setPosition( cc.p(5, 10) );
    tableview_reward:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN );
    tableview_reward:setBounceable(true);
    tableview_reward:setDelegate();
    rewardBg:addChild(tableview_reward);
    self._tableview = tableview_reward

    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        if self._type == 1 then
            return  #self._reward_arr
        else
            return #self._rankData
        end
    end
    local function cellSizeForTable( table, idx )
        return tableview_reward:getContentSize().width,102
    end
    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell();
        if cell == nil then
            local size = cc.size(tableview_reward:getContentSize().width,102 )
            cell = cc.TableViewCell:new();
            cell:setContentSize( size );
            -- cell:retain()
        else
            cell:removeAllChildren()
        end
        if self._type == 1 then
            return self:initCellReward(cell,idx+1)
        else
            return self:initCellRank(cell,idx+1)
        end
    end

    tableview_reward.getCellNumbers=numberOfCellsInTableView
    tableview_reward:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableview_reward.getCellSize=cellSizeForTable
    tableview_reward:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableview_reward:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
   
    --tab
    local nameTab = {"shanghai","jiangli"}
    self._tabBtn = {}
    for i = 1, 2 do
        local tab_btn = XTHDPushButton:createWithParams({
            normalNode      = getCompositeNodeWithImg("res/image/common/btn/btn_tabClassify_normal.png", "res/image/goldcopy/"..nameTab[i]..".png"),
            selectedNode    = getCompositeNodeWithImg("res/image/common/btn/btn_tabClassify_selected.png", "res/image/goldcopy/"..nameTab[i].."2.png"),
            musicFile = XTHD.resource.music.effect_btn_common,
            anchor          =cc.p(0,1),
            pos             = cc.p(popNode:getContentSize().width - 5,popNode:getContentSize().height-40-90*(i-1)),
            endCallback = function()
                self:changeTab(i)
            end,
        })
        tab_btn:setScale(0.7)
        popNode:addChild(tab_btn, -1)
        self._tabBtn[#self._tabBtn+1] = tab_btn
    end
    self:changeTab(1)
end

function ShangJinLieRenRewardPop:changeTab(_type)
    if self._type == nil or  self._type ~= _type then
        if self._type == nil then
            self._type = _type
            self._tabBtn[self._type]:setSelected(true)
            self._tabBtn[self._type]:setLocalZOrder(0)
        else

            self._tabBtn[self._type]:setSelected(false)
            self._tabBtn[self._type]:setLocalZOrder(-1)

            self._type = _type
            self._tabBtn[self._type]:setSelected(true)
            self._tabBtn[self._type]:setLocalZOrder(0)
        end
        if self._type == 1 then
            self._total_hurt_sp:setVisible(true)
            self._today_hurt_num:setVisible(true)
            self._myRank:setVisible(false)
            self._rankNum:setVisible(false)
            self._sendLab:setVisible(false)
            self._title_font:setString(LANGUAGE_KEY_HURTREWARD)
        else
            self._total_hurt_sp:setVisible(false)
            self._today_hurt_num:setVisible(false)
            self._myRank:setVisible(true)
            self._rankNum:setVisible(true)
            self._sendLab:setVisible(true)
            self._title_font:setString(LANGUAGE_TIPS_PAIHANG)
        end

        self:stopAllActions()
        if self._tableview then
            self._tableview:reloadData()
            if self._type == 1 then
                self:runAction(cc.Sequence:create( cc.DelayTime:create(0.3),cc.CallFunc:create(function (  )
                    self:scrollToIndexCell(self._tableview,self._reward_arr)
                end) ))
            end
        end
    end
end

function ShangJinLieRenRewardPop:initCellReward( cell,idx )
    local data = self._reward_arr[idx]
    if data == nil or next(data) == nil then
        return cell
    end

    -- local bg = ccui.Scale9Sprite:create( cc.rect( 12, 12, 1, 1 ), "res/image/common/scale9_bg1_26.png" )--ccui.Scale9Sprite:create("res/image/common/scale9_bg_12.png")
    local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png" )
    bg:setContentSize(505,94)
    bg:setPosition(cell:getContentSize().width/2 - 3,cell:getContentSize().height/2+3)
    cell:addChild(bg)

    -- 分隔线
    -- local splitCellLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
    -- splitCellLine:setContentSize( bg:getContentSize().width, 2 )
    -- splitCellLine:setAnchorPoint( cc.p( 0.5, 0 ) )
    -- splitCellLine:setPosition( cell:getContentSize().width*0.5, 0 )
    -- cell:addChild( splitCellLine )

    local hurt_num_font = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS99,------"今日伤害累计达到",
        fontSize = 20,
        color = fontColor
        })
    hurt_num_font:setAnchorPoint(0,0.5)
    hurt_num_font:setPosition(15,bg:getContentSize().height/2)
    bg:addChild(hurt_num_font)

    local hurt_num = XTHDLabel:createWithParams({
        text = self:getShortNum(tonumber(data.damge)),
        fontSize = 24,
        color = cc.c3b(255,0,0)
        })
    hurt_num:setAnchorPoint(0,0.5)
    hurt_num:setPosition(hurt_num_font:getPositionX()+hurt_num_font:getContentSize().width+10,hurt_num_font:getPositionY())
    bg:addChild(hurt_num)

    local hurt_num1 = XTHDLabel:createWithParams({
        text = self:getShortNum(tonumber(data.damge)),
        fontSize = 24,
        color = cc.c3b(255,0,0)
        })
    hurt_num1:setAnchorPoint(0,0.5)
    hurt_num1:setPosition(hurt_num_font:getPositionX()+hurt_num_font:getContentSize().width+10+0.5,hurt_num_font:getPositionY())
    bg:addChild(hurt_num1)

    local hurt_num2 = XTHDLabel:createWithParams({
        text = self:getShortNum(tonumber(data.damge)),
        fontSize = 24,
        color = cc.c3b(255,0,0)
        })
    hurt_num2:setAnchorPoint(0,0.5)
    hurt_num2:setPosition(hurt_num_font:getPositionX()+hurt_num_font:getContentSize().width+10-0.5,hurt_num_font:getPositionY())
    bg:addChild(hurt_num2)


    local item_reward = ItemNode:createWithParams({
                _type_ = 2,
                count = tonumber(data.reward) ,
                needSwallow = false
            })
    item_reward:setPosition(300,hurt_num_font:getPositionY())
    item_reward:setScale(0.8)
    bg:addChild(item_reward)

    local _pos = cc.p(cell:getContentSize().width-90,cell:getContentSize().height/2)
    if tonumber(data.state) == 1 then
        local already_cliam = cc.Sprite:create("res/image/plugin/stageChapter/reward_alyread.png")
        already_cliam:setPosition(_pos)
        already_cliam:setScale(0.7)
        cell:addChild(already_cliam)
    else
        local _fontText, _btnColor
        local flag = false
		local isVisible = false
        if tonumber(data.state) == 0 then
            _fontText = LANGUAGE_TIPS_CANRECEIVE
            _btnColor = "write_1"
            flag = false
			isVisible = true
        else
            _fontText = LANGUAGE_ADJ.unreachable
            _btnColor = "write"
            flag = false
        end

        local cliam_btn 
        cliam_btn = XTHD.createCommonButton({
            btnColor = _btnColor,
            fontSize = 28,
            isScrollView = true,
            btnSize = cc.size(130, 51),
            pos = _pos,
            text = _fontText,
            needSwallow = false,
            endCallback = function (  )
                if tonumber(data.state) == 0 then
                    self:cliamReward(data.configId,cliam_btn,idx)
                else
                    XTHDTOAST(LANGUAGE_TIPS_WORDS9)-------"未达到领取条件！")
                end
            end
        })
        cliam_btn:setSelected(flag)
        cliam_btn:setScale(0.7)
        cell:addChild(cliam_btn)
	
		local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		cliam_btn:addChild( fetchSpine )
		fetchSpine:setPosition( cliam_btn:getBoundingBox().width*0.5+22, cliam_btn:getContentSize().height/2+20-17 )
		fetchSpine:setAnimation( 0, "querenjinjie", true )
		fetchSpine:setVisible(isVisible)
    end

    return cell

end

function ShangJinLieRenRewardPop:initCellRank(cell,idx)

    local data = self._rankData[idx]
    if data == nil or next(data) == nil then
        return cell
    end

    -- local bg = ccui.Scale9Sprite:create( cc.rect( 12, 12, 1, 1 ), "res/image/common/scale9_bg_26.png" )--ccui.Scale9Sprite:create("res/image/common/scale9_bg_12.png")
    local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png" )
    bg:setContentSize(505,94)
    bg:setPosition(cell:getContentSize().width/2 - 3,cell:getContentSize().height/2+3)
    cell:addChild(bg)

    -- -- 分隔线
    -- local splitCellLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
    -- splitCellLine:setContentSize( bg:getContentSize().width, 2 )
    -- splitCellLine:setAnchorPoint( cc.p( 0.5, 0 ) )
    -- splitCellLine:setPosition( cell:getContentSize().width*0.5, 0 )
    -- cell:addChild( splitCellLine )

    --排名
    local rank_icon = nil
    if idx <= 3 then
        rank_icon = cc.Sprite:create("res/image/ranklistreward/"..idx..".png")
    else
        rank_icon = XTHDLabel:createWithParams({
            text = idx,
            fontSize = 28,
            color = fontColor
            })
    end
    rank_icon:setPosition(60,bg:getContentSize().height/2)
    bg:addChild(rank_icon)

    local nameLab = XTHDLabel:createWithParams({
        text = data.name,
        fontSize = 20,
        color = XTHD.resource.color.brown_desc,
        anchor = cc.p(0.5, 0.5),
        pos = cc.p(170, bg:getContentSize().height/2),
    })
    bg:addChild(nameLab)
    

    local item = ItemNode:createWithParams({
        _type_ = data.rewardtype,
        count = tonumber(data.num) ,
        needSwallow = false,
    })
    item:setPosition(350, bg:getContentSize().height/2)
	item:setScale(0.8)
    bg:addChild(item)
    return cell
end
--领取奖励信息
function ShangJinLieRenRewardPop:cliamReward( configId,btn,idx )
     ClientHttp:requestAsyncInGameWithParams({
        modules = "goldEctypeReward?",
        params = {configId=tonumber(configId)},
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end

        if data["result"] == 0 then
            --处理奖励信息数据
            local show_reward_tab = {}
            local temp_table = {}
            temp_table.rewardtype = XTHD.resource.type.gold
            temp_table.num = tonumber(data.gold-gameUser.getGold()) or 0
            show_reward_tab[#show_reward_tab+1] = temp_table

            --显示奖励
            ShowRewardNode:create(show_reward_tab)

            --刷新数据
            if data and data.gold then
                gameUser.setGold(data.gold)
            end
           
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})      --刷新topbar数据
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，

            --设置领奖按钮状态
            if btn ~= nil then
                btn:setVisible(false)
                local already_cliam = cc.Sprite:create("res/image/plugin/stageChapter/reward_alyread.png")
                already_cliam:setPosition(btn:getPositionX(),btn:getPositionY())
                already_cliam:setScale(0.7)
                btn:getParent():addChild(already_cliam)
            end
            -- btn:setSelected(true)

            if self._reward_arr[idx]["state"] then
                self._reward_arr[idx]["state"] = 1
            end
            self:checkRedPoint()
        else
            XTHDTOAST(data["msg"])
        end

        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

--检测是否显示红点
function ShangJinLieRenRewardPop:checkRedPoint(  )
    local flag = false
    for i=1,#self._reward_arr do
        local item = self._reward_arr[i]
        if tonumber(item["state"]) == 0 then
            flag = true
        end
    end

    local parent = self:getParent()
    if parent ~= nil then
        parent:setRedPointVisible(flag)
    end
end

function ShangJinLieRenRewardPop:scrollToIndexCell( tableview,list )
    function getIdx(  )
        local idx = 0
        for i=1,#list do
            local item = list[i]
            if item and item["state"] ~= 0 then  --0表示可以领取
                idx = idx +1
            elseif item and item["state"] == 0 then
                return idx
            end
        end
        return idx
    end
    if getIdx() ~= #list then
        tableview:scrollToCell(getIdx(),true)
    end
    
end

--把数字转换为多少万   --英文版数字表示方式不一样 需要修改
function ShangJinLieRenRewardPop:getShortNum( num )
    local tmp_num = tonumber(num)
    local str = ""
    if tmp_num < 10000 then
        return tmp_num
    elseif tmp_num >= 10000 then
        local wan = math.floor(tmp_num/10000)
        local qian = math.floor((tmp_num%10000)/1000)
        local bai = math.floor(((tmp_num%10000)%1000)/100)
        if tonumber(wan) <= 0 then
            str = tostring(tmp_num)
            return str
        elseif tonumber(qian) <= 0 and tonumber(bai) <= 0 then
            str = wan..LANGUAGE_UNKNOWN.w ------"万"
            return str
        elseif tonumber(qian) <= 0 and tonumber(bai) > 0 then
            str = wan..".0"..bai..LANGUAGE_UNKNOWN.w 
            return str
        elseif tonumber(qian) > 0 and tonumber(bai) <= 0 then
            str = wan.."."..qian..LANGUAGE_UNKNOWN.w 
            return str
        elseif tonumber(qian) > 0 and tonumber(bai) > 0 then
            str = wan.."."..qian..bai..LANGUAGE_UNKNOWN.w 
            return str
        end
    else
        return tmp_num
    end
end


function ShangJinLieRenRewardPop:getArtFont( str )
    return XTHDLabel:createWithParams({fnt = "res/fonts/10/red6.fnt" , text = str , kerning = -2})
end



function ShangJinLieRenRewardPop:create(data,totalHurt,_rank)
    local _layer = self.new(data,totalHurt,_rank)
    return _layer
end
return ShangJinLieRenRewardPop