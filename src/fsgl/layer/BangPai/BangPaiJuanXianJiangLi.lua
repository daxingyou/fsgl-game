
--@author hezhitao 2015.10.22
local BangPaiJuanXianJiangLi = class("BangPaiJuanXianJiangLi",function(sParams)
    return requires("src/fsgl/layer/BangPai/BangPaiXinXi.lua"):create(sParams)
end)

function BangPaiJuanXianJiangLi:init(data)
    self._reward_arr = data["list"]
    
    local _popBgSprite = self._popNode
    local _titleBack = self._titleBack
	_titleBack:setVisible(false)

    local _worldSize = _popBgSprite:getContentSize()
    self.containerSize = _worldSize

    local title_txt = XTHDLabel:createWithParams({
        text = LANGUAGE_WORSHIP_REWARD_TIPS(data["worshipPoint"] or "0"),
        fontSize = 22,
        color = XTHD.resource.titleColor,
        anchor = cc.p(0.5, 0.5),
        pos = cc.p(_worldSize.width*0.5, _worldSize.height - 22-7)
    })
    _popBgSprite:addChild(title_txt)


    local tableview_bg =  BangPaiFengZhuangShuJu.createListBg(cc.size(_popBgSprite:getContentSize().width-18,_popBgSprite:getContentSize().height-70))
    tableview_bg:setAnchorPoint(0,0)
    tableview_bg:setPosition(9,25)
    _popBgSprite:addChild(tableview_bg)

     --tableview
    local tableview = CCTableView:create( cc.size(tableview_bg:getContentSize().width, tableview_bg:getContentSize().height - 5))
    tableview:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
    tableview:setPosition( cc.p(0, 3) )
    tableview:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
    tableview:setBounceable(true)
    tableview:setDelegate()
    tableview_bg:addChild(tableview)
   
    -- tableView注册事件
    local function numberOfCellsInTableView( table )
        return  #self._reward_arr
    end

    local function cellSizeForTable( table, idx )
        return tableview:getContentSize().width,100
    end

    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
            cell:setContentSize( tableview:getContentSize().width,100)
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



function BangPaiJuanXianJiangLi:initCellData( cell,idx )
    local data = self._reward_arr[idx]
    if data == nil or next(data) == nil then
        return cell
    end

    -- local layer_num = {"10","二十","三十","四十","五十","六十","七十"}  
    local temp_data = gameData.getDataFromCSV("SectDonate",{["id"]=idx+3}) or {}
    -- if #temp_data <= 0 then
    --     return cell
    -- end

    -- local cell_bg = BangPaiFengZhuangShuJu.createListCellBg(cc.size(cell:getContentSize().width-10,90))
    local cell_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    cell_bg:setContentSize(cc.size(cell:getContentSize().width-30,90))
    cell_bg:setPosition(cell:getContentSize().width/2,cell:getContentSize().height/2)
    cell:addChild(cell_bg)

    --描述信息
    local name = XTHDLabel:createWithParams({
        text = LANGUAGE_WORSHIP_REWARD_POINT(temp_data["need"]),
        fontSize = 18,
        color = cc.c3b(53,25,26)
    })
    name:setAnchorPoint(0,0.5)
    name:setPosition(25,cell:getContentSize().height/2)
    cell:addChild(name)

--翡翠和银两图标
    local list_data = self:dealRewardDataToShow(idx+3)
    for i=1,2 do
        local item_reward = ItemNode:createWithParams({
                    itemId = list_data[i]["itemId"],
                    _type_ = list_data[i]["_type_"],
                    count = tonumber(list_data[i]["count"]) ,
                    -- itemId = 1,
                    -- _type_ = 1,
                    -- count = tonumber(1) ,
                    needSwallow = false,
                }) 
        item_reward:setScale(0.7)
        item_reward:setPosition(250+(i-1)*90,cell:getContentSize().height/2)
        cell:addChild(item_reward)
    end

    --图片
    local line = cc.Sprite:create("res/image/common/line.png")
    line:setPosition(cell:getContentSize().width/2,0)
    cell:addChild(line)

--按钮
    local normal_file = nil
    local selected_file = nil
    local _btnColor = nil
    local _btnText = nil
    local flag = false
    if tonumber(data.state) == 1 then
        _btnText = LANGUAGE_BTN_KEY.getReward
        _btnColor = "write_1"
        flag = false
    elseif tonumber(data.state) == 0 then
        _btnColor = "write"
        _btnText = LANGUAGE_BTN_KEY.noAchieve
        flag = true
    elseif tonumber(data.state) == 2 then
        _btnColor = "write_1"
        flag = true
    end

    local cliam_btn = XTHD.createCommonButton({
            btnColor = _btnColor,
            isScrollView = true,
            normalFile = normal_file,
            selectedFile = selected_file,
            text = _btnText,
            needSwallow = false,
            fontSize = 26
        })
        cliam_btn:setScale(0.7)
    -- cliam_btn:setSelected(flag)
    cliam_btn:setPosition(cell:getContentSize().width-90,cell:getContentSize().height/2)
    cliam_btn:setTag(idx)
    cell:addChild(cliam_btn)
    cliam_btn:setTouchEndedCallback(function (  )
        self:cliamReward(data["configId"],cliam_btn)
       -- XTHDTOAST("data数据:" .. data["configId"])
    end)

    if tonumber(data.state) == 2 then
        cliam_btn:setVisible(false)
        local already_cliam = cc.Sprite:create("res/image/plugin/stageChapter/reward_alyread.png")
        already_cliam:setPosition(cell:getContentSize().width-90,cell:getContentSize().height/2)
        cell:addChild(already_cliam)
        already_cliam:setScale(0.7)
    elseif tonumber(data.state)==1 then
        --按钮上可以领取奖励的特效
        local rewardSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)
        rewardSpine:setName("rewardSpine")
        cliam_btn:addChild( rewardSpine )
        rewardSpine:setPosition( cliam_btn:getContentSize().width*0.5+6, cliam_btn:getContentSize().height/2+2 )
        rewardSpine:setAnimation( 0, "querenjinjie", true)
    end

    return cell

end


function BangPaiJuanXianJiangLi:cliamReward( id,btn )
    ClientHttp.httpGuildWorshipReward(self,function ( data )
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end
        if data["result"] == 0 then
            self:showReward(data,btn:getTag()+3)
             if self._reward_arr[btn:getTag()]["state"] ~= nil then
                self._reward_arr[btn:getTag()]["state"] = 2
                XTHD.dispatchEvent({name = "GuildWorshipreward2",data = {["name"] = "reward",["visible"] = self._reward_arr[btn:getTag()]["state"]}})
            end
            -- self:checkRedPoint()
            --刷新数据
            self:refreshData(data)
            --添加已领取标识
            if btn ~= nil then
                local already_cliam = cc.Sprite:create("res/image/plugin/stageChapter/reward_alyread.png")
                already_cliam:setPosition(btn:getPositionX(),btn:getPositionY())
                btn:getParent():addChild(already_cliam)
                btn:setVisible(false)
                already_cliam:setScale(0.7)
                XTHD.dispatchEvent({name = "GuildWorshipreward2",data = {["name"] = "reward",["visible"] = 0}})
            end
            ClientHttp.httpGuildWorshipListReward(self, function ( data )

                local dataList = data["list"]
                for i=1,#dataList do
                     --传消息
                    XTHD.dispatchEvent({name = "GuildWorshipreward",data = {["name"] = "reward",["visible"] = dataList[i]["state"]}})
                      
                end
                
            end)
        else
            XTHDTOAST(data["msg"])
        end
        
    end,{configId = id})
end


function BangPaiJuanXianJiangLi:refreshData( data )
    local mDatas = BangPaiFengZhuangShuJu.getGuildData()
    if mDatas.list and #mDatas.list > 0 then
        for k,v in pairs(mDatas.list) do
            if v.charId == gameUser.getUserId() then
                v.dayContribution = tonumber(data.dayContribution) or 0
                v.totalContribution = tonumber(data.totalContribution) or 0
                break
            end
        end
    end
    BangPaiFengZhuangShuJu.setGuildData(mDatas)
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
end

-- --保存数据
-- function BangPaiJuanXianJiangLi:saveData( data )
--     for i=1,#data["items"] do
--         local item_data = data["items"][i]
--         if item_data.count and tonumber(item_data.count) ~= 0 then
--             DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
--         else
--             DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
--         end
        
--     end
--     RedPointManage:reFreshDynamicItemData()
-- end

--显示奖励信息
function BangPaiJuanXianJiangLi:showReward( data,idx )
    --更新红点中的item数据，在下面的gameUser.setFeicui中刷新主城上的红底那状态
    

    local list_data = self:dealRewardDataToShow(idx) or {}
    local item_list = data["items"]
    local reward_list = {}

    --处理翡翠
    local feicui_data = {}
    -- local feicui_num = tonumber(data["feicui"]) - tonumber(gameUser.getFeicui())
    local feicui_num = list_data[1]["count"] or 0
    feicui_data["rewardtype"] = XTHD.resource.type.feicui
    feicui_data["num"] = feicui_num
    reward_list[#reward_list+1] = feicui_data

    local gold_data = {}
    local gold_num = list_data[2]["count"] or 0
    gold_data["rewardtype"] = XTHD.resource.type.gold
    gold_data["num"] = gold_num
    reward_list[#reward_list+1] = gold_data

    --更新topbar翡翠数据
    gameUser.setFeicui(data["feicui"])
    gameUser.setGold(data["gold"])
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})      --刷新topbar数据
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，

    --拼接数据，为了ShowRewardNode显示
    -- for i=1,#item_list do
    --     local temp_table = {}
    --     local item = item_list[i]
    --     local local_count = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = item["itemId"]})
    --     local item_count = 0
    --     if local_count["count"] then
    --         item_count = tonumber(item["count"]) - tonumber(local_count["count"])
    --     else
    --         item_count = tonumber(item["count"])
    --     end
        

    --     temp_table["rewardtype"] = 4
    --     temp_table["id"] = item["itemId"]
    --     temp_table["num"] = item_count

    --     reward_list[#reward_list+1] = temp_table
    -- end
    ShowRewardNode:create(reward_list)
    -- self:saveData(data)
end

--处理通关奖励数据
function BangPaiJuanXianJiangLi:dealRewardDataToShow( id )
    local temp_data = gameData.getDataFromCSV("SectDonate",{["id"]=id})
    local reward_data = {}
    for i=1,2 do
        local temp_tab = {}
        if i == 1 then
            temp_tab["itemId"] = 1
            temp_tab["_type_"] = XTHD.resource.type.feicui
            temp_tab["count"] = temp_data["feicui"]
        else
            temp_tab["itemId"] = 1
            temp_tab["_type_"] = XTHD.resource.type.gold
            temp_tab["count"] = temp_data["gold"]
        end
        reward_data[#reward_data+1] = temp_tab
    end
    return reward_data
   
end

function BangPaiJuanXianJiangLi:createOne( par )
    
    ClientHttp.httpGuildWorshipListReward(par, function ( data )
        local params = {
            size = cc.size(646, 504-72),
        }
        local pLay = BangPaiJuanXianJiangLi.new(params)
        pLay:init(data)
        LayerManager.addLayout(pLay, {noHide = true})
         
    end)

    
    return pLay
end



return BangPaiJuanXianJiangLi