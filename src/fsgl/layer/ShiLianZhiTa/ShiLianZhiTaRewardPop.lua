
--@author hezhitao 2015.07.04
local ShiLianZhiTaRewardPop = class("ShiLianZhiTaRewardPop",function()
    return XTHDPopLayer:create()
end)
local fontColor = cc.c3b(53,25,26)  --通用字体颜色
function ShiLianZhiTaRewardPop:ctor(data)
    self:init(data)
end

function ShiLianZhiTaRewardPop:init(data)

    self._reward_arr = data
--	print("试炼之塔服务器返回的奖励状态为：")
--	print_r(data)

    local _popBgSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    _popBgSprite:setContentSize(cc.size(646,504-72))
    local popNode = XTHDPushButton:createWithParams({
                        normalNode = _popBgSprite
                    })
    popNode:setTouchEndedCallback(function ()
        
    end)
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addContent(popNode)
    self.popNode = popNode
    self:show()

    -- local title_bg = XTHD.getScaleNode("res/image/common/common_title_barBg.png", cc.size(_popBgSprite:getContentSize().width - 7*2, 44))
    local title_bg = ccui.Scale9Sprite:create()
    title_bg:setContentSize(cc.size(_popBgSprite:getContentSize().width - 7*2, 44))
    title_bg:setAnchorPoint(0.5,1)
    title_bg:setPosition(_popBgSprite:getContentSize().width/2,_popBgSprite:getContentSize().height-7)
    _popBgSprite:addChild(title_bg,1)

    local title_txt = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS117,-----"满足条件即可领取以下奖励,每天可以领取1次",
        fontSize = 22,
        color = fontColor
        })
    title_txt:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2)
    title_bg:addChild(title_txt)

    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(_popBgSprite:getContentSize().width-5, _popBgSprite:getContentSize().height-5)
    _popBgSprite:addChild(close,2)

    local tableview_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")--common_opacity.png
    tableview_bg:setContentSize(_popBgSprite:getContentSize().width-30,_popBgSprite:getContentSize().height-72)
    tableview_bg:setAnchorPoint(0,0)
    tableview_bg:setPosition(14.5,25)
    _popBgSprite:addChild(tableview_bg)

     --tableview
    local tableview = CCTableView:create( cc.size(tableview_bg:getContentSize().width-4, tableview_bg:getContentSize().height-10) );
    tableview:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL );
    tableview:setPosition( cc.p(2, 5) );
    tableview:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN );
    tableview:setBounceable(true);
    tableview:setDelegate();
    tableview_bg:addChild(tableview);
   
    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        return  #self._reward_arr
    end

    local function cellSizeForTable( table, idx )
        return tableview:getContentSize().width,90
    end

    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell();
        if cell == nil then
            cell = cc.TableViewCell:new();
            cell:setContentSize( tableview:getContentSize().width,90 );
            -- cell:retain()
        else
            cell:removeAllChildren()
        end
        return self:initCellData(cell,idx+1)
    end

    tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)


    tableview:reloadData()

end


function ShiLianZhiTaRewardPop:initCellData( cell,idx )
    local data = self._reward_arr[idx]
    if data == nil or next(data) == nil then
        return cell
    end

    local temp_data = gameData.getDataFromCSV("TrialTowerTreasure",{["id"]=idx})

    local cell_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    cell_bg:setContentSize(cell:getContentSize().width-6,90)
    cell_bg:setPosition(cell:getContentSize().width/2,cell:getContentSize().height/2)
    cell:addChild(cell_bg)

    -- 分隔线
    -- local splitCellLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
    -- splitCellLine:setContentSize( cell:getContentSize().width, 2 )
    -- splitCellLine:setAnchorPoint( cc.p( 0.5, 0 ) )
    -- splitCellLine:setPosition( cell:getContentSize().width*0.5, 4 )
    -- cell:addChild( splitCellLine )

    --描述信息
    local name = XTHDLabel:createWithParams({
        text = temp_data["needs"],
        fontSize = 18,
        color = fontColor
        })
    name:setAnchorPoint(0,0.5)
    name:setPosition(20,cell:getContentSize().height/2)
    cell:addChild(name)

    local list_data = self:dealRewardDataToShow(idx)
    for i=1,#list_data do
        local item_reward = ItemNode:createWithParams({
                    itemId = list_data[i]["itemId"],
                    _type_ = list_data[i]["_type_"],
                    count = tonumber(list_data[i]["count"]) ,
                    needSwallow = false,
                    -- touchShowTip = false
                }) 
        item_reward:setScale(0.7)
        item_reward:setPosition(160+(i-1)*75,cell:getContentSize().height/2 + 2 )
        cell:addChild(item_reward)
    end

    --图片
    local line = cc.Sprite:create("res/image/common/line.png")
    line:setPosition(cell:getContentSize().width/2,0)
    cell:addChild(line)

    local _state = tonumber(data.state)
    local _pos = cc.p(cell:getContentSize().width-80,cell:getContentSize().height/2)
    if _state == 2 then
        local already_cliam = cc.Sprite:create("res/image/plugin/stageChapter/reward_alyread.png")
        already_cliam:setPosition(_pos)
        already_cliam:setScale(0.7)
        cell:addChild(already_cliam)
    else
		local isVisible = false
        local _fontText = ""
        local _btnColor = ""
        if tonumber(data.state) == 1 then
			isVisible = true
            _fontText = LANGUAGE_TIPS_CANRECEIVE
            _btnColor = "write_1"
        elseif tonumber(data.state) == 0 then
            _fontText = LANGUAGE_ADJ.unreachable
            _btnColor = "write"
        end

        local cliam_btn = XTHD.createCommonButton({
            btnColor = _btnColor,
            text = _fontText,
            isScrollView = true,
            fontSize = 26,
            btnSize = cc.size(130, 51),
            needSwallow = false,
        })
        cliam_btn:setScale(0.7)
        cliam_btn:setPosition(cell:getContentSize().width-80,cell:getContentSize().height/2)
        cliam_btn:setTag(idx)
        cell:addChild(cliam_btn)
        cliam_btn:setTouchEndedCallback(function (  )
            self:cliamReward(data["diffculty"],cliam_btn)
        end)

		local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		cliam_btn:addChild( fetchSpine )
		fetchSpine:setPosition( cliam_btn:getBoundingBox().width*0.5+27, cliam_btn:getContentSize().height/2+20-17 )
		fetchSpine:setAnimation( 0, "querenjinjie", true )
		fetchSpine:setVisible(isVisible)
		fetchSpine:setScaleY(0.8)

    end

    return cell

end

function ShiLianZhiTaRewardPop:cliamReward( id,btn )
    ClientHttp:requestAsyncInGameWithParams({
        modules = "feicuiEctypeTongguanReward?",
        params = {difficulty=id},
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end
        if data["result"] == 0 then
            self:showReward(data,btn:getTag())
             if self._reward_arr[btn:getTag()]["state"] ~= nil then
                self._reward_arr[btn:getTag()]["state"] = 2
            end
            self:checkRedPoint()
            
            if btn ~= nil then
                local already_cliam = cc.Sprite:create("res/image/plugin/stageChapter/reward_alyread.png")
                already_cliam:setPosition(btn:getPositionX(),btn:getPositionY())
                already_cliam:setScale(0.7)
                btn:getParent():addChild(already_cliam)
                btn:setVisible(false)
            end
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

--保存数据
function ShiLianZhiTaRewardPop:saveData( data )
    for i=1,#data["items"] do
        local item_data = data["items"][i]
        if item_data.count and tonumber(item_data.count) ~= 0 then
            DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
        else
            DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
        end
        
    end
    RedPointManage:reFreshDynamicItemData()
end

--显示奖励信息
function ShiLianZhiTaRewardPop:showReward( data,idx )
    --更新红点中的item数据，在下面的gameUser.setFeicui中刷新主城上的红底那状态
    

    local list_data = self:dealRewardDataToShow(idx) or {}
    -- dump(list_data,"list_datalist_data")
    local item_list = data["items"]
    local reward_list = {}

    --处理翡翠
    local feicui_data = {}
    -- local feicui_num = tonumber(data["feicui"]) - tonumber(gameUser.getFeicui())
    local feicui_num = list_data[1]["count"] or 0
    feicui_data["rewardtype"] = XTHD.resource.type.feicui
    feicui_data["num"] = feicui_num
    reward_list[#reward_list+1] = feicui_data
    --处理魂玉
    local hunyu = {}
    hunyu.rewardtype = XTHD.resource.type.soul
    hunyu.num = list_data[2]["count"] or 0
    reward_list[#reward_list+1] = hunyu


    --更新topbar翡翠数据
    gameUser.setFeicui(data["feicui"])
    --更新魂玉数据
    gameUser.setSoul(data["hunyu"])
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})      --刷新topbar数据
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，

    --拼接数据，为了ShowRewardNode显示
    for i=1,#item_list do
        local temp_table = {}
        local item = item_list[i]
        local local_count = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = item["itemId"]})
        local item_count = 0
        if local_count["count"] then
            item_count = tonumber(item["count"]) - tonumber(local_count["count"])
        else
            item_count = tonumber(item["count"])
        end
        

        temp_table["rewardtype"] = 4
        temp_table["id"] = item["itemId"]
        temp_table["num"] = item_count

        reward_list[#reward_list+1] = temp_table
    end

    -- dump(reward_list, "reward_list========")
    ShowRewardNode:create(reward_list)
    self:saveData(data)
end

--处理通关奖励数据
function ShiLianZhiTaRewardPop:dealRewardDataToShow( id )
    local temp_data = gameData.getDataFromCSV("TrialTowerTreasure",{["id"]=id})
    local reward_data = {
        [1] = {
           itemId = 1,
           _type_ = XTHD.resource.type.feicui,
           count = temp_data["feicui"],
        },
        [2] = {
           itemId = 1,
           _type_ = XTHD.resource.type.soul,
           count = temp_data["hunyu"],
        }
    }
    for i=1, 4 do
        local _id = temp_data["item" .. i]
        if _id and _id ~= 0 then
            reward_data[#reward_data + 1] =  {
               itemId = temp_data["item" .. i],
               _type_ = 4,
               count = temp_data["num" .. i],
            } 
        end
    end
    return reward_data
   
end

--获取当前奖励的个数
function ShiLianZhiTaRewardPop:getRewardNum( item_data )
    
    local num = 0
    -- for i=1,4 do
    --     local item_idx  = tostring("item"..i)
    --     print("item_idx",item_idx,item_data."item"..i,item_data["item1"],item_data["needs"])
    --     dump(item_data,"item_data")
    --     if item_data.item_idx ~= nil then
    --         print("numnum",num)
    --         num = num + 1
    --     end
    -- end
    if item_data["item4"] ~= nil then
        num = 6
    elseif item_data["item3"] ~= nil then
        num = 5
    elseif item_data["item2"] ~= nil then
        num = 4
    elseif item_data["item1"] ~= nil then
        num = 3
    else
        num = 2
    end

    return num
   
end

--检测是否显示红点
function ShiLianZhiTaRewardPop:checkRedPoint(  )
    local flag = false
    for i=1,#self._reward_arr do
        local item = self._reward_arr[i]
        if tonumber(item["state"]) == 1 then
            flag = true
        end
    end

    local parent = self:getParent()
    if parent ~= nil then
        parent:setRedPointVisible(flag)
    end
    print("asdjfklajsdf",flag)
end

function ShiLianZhiTaRewardPop:create(data)
    local _layer = self.new(data)
    return _layer
end
return ShiLianZhiTaRewardPop