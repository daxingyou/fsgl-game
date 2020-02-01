-- FileName: XuanShangRenWuGetPopLayer.lua
-- Author: andong
-- Date: 2015-12-01
-- Purpose: 悬赏任务奖励
--[[TODO List]]

local XuanShangRenWuGetPopLayer = class("XuanShangRenWuGetPopLayer",function()
    return XTHDPopLayer:create({isRemoveLayout = true})
end)
function XuanShangRenWuGetPopLayer:ctor(params)

    self._params = params
    self._type = params.type
    self:initData()
    self:init()
    self:show()
end

function XuanShangRenWuGetPopLayer:initData()

    local static = gameData.getDataFromCSV("XsTaskReward")
    self._static = {}
    for i = 1, #static do
        self._static[i] = {}
        --奖励1
        local rewardTable = string.split(static[i].item, ",")
        for j = 1, #rewardTable do
            self._static[i][j] = {}
            local item = string.split(rewardTable[j], "#")
            self._static[i][j].id = tonumber(item[1])
            self._static[i][j].num = tonumber(item[2])
            self._static[i][j].type = 4
            self._static[i][j].name = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = item[1]}).name
        end
        --奖励2
        if static[i].bountyreward and tonumber(static[i].bountyreward) > 0 then
            local idx = #self._static[i] + 1
            self._static[i][idx] = {}
            self._static[i][idx].num = tonumber(static[i].bountyreward)
            self._static[i][idx].type = XTHD.resource.type.bounty
            self._static[i][idx].name = LANGUAGE_TABLE_RESOURCENAME[XTHD.resource.type.bounty]
        end
    end
end

function XuanShangRenWuGetPopLayer:init()
    
    local popNode = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    popNode:setContentSize(cc.size(500,350))
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:addNodeOnContainer(popNode)

    local title_bg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 50))
    title_bg:setAnchorPoint(0.5,1)
    title_bg:setPosition(popNode:getContentSize().width/2, popNode:getContentSize().height + title_bg:getContentSize().height * 0.25)
    popNode:addChild(title_bg)
    local stage_name = XTHDLabel:create(LANGUAGE_KEY_FETCHREWARD,26,"res/fonts/def.ttf")
    stage_name:setColor(cc.c3b(104, 33, 11))
    stage_name:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2 + 2)
    title_bg:addChild(stage_name)

    local fall_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    fall_bg:setContentSize(cc.size(470,162))
    fall_bg:setAnchorPoint(0.5,1)
    fall_bg:setPosition(popNode:getContentSize().width / 2,popNode:getContentSize().height -50)
    popNode:addChild(fall_bg)

    local pos_table=SortPos:sortFromMiddle( cc.p(fall_bg:getContentSize().width/2,fall_bg:getContentSize().height/2), tonumber(#self._static[self._type]), 150 )

    for i = 1, #self._static[self._type] do
        local item  = ItemNode:createWithParams({
            itemId =self._static[self._type][i].id,
            needSwallow = true,
            _type_ =self._static[self._type][i].type,
            count=self._static[self._type][i].num,
        })
        item:setPosition(pos_table[i])
        fall_bg:addChild(item)
        local item_name_label = XTHDLabel:createWithParams({
            text = self._static[self._type][i].name,
            anchor=cc.p(0.5,1),
            fontSize = 18,--字体大小
            color = cc.c3b(74,34,34),
            pos = cc.p(item:getContentSize().width/2,-2),
        })
        item:addChild(item_name_label)

    end


    if self._params.state == 2 then
        local already_sp = cc.Sprite:create("res/image/vip/yilingqu.png")
        already_sp:setAnchorPoint(0.5,0)
        already_sp:setPosition(popNode:getContentSize().width/2,48)
        already_sp:setScale(0.7)
        popNode:addChild(already_sp)
    else
        local normalnode 
        local _label
        if self._params.state == 1 then
            _label = LANGUAGE_BTN_KEY.getTheRewards
            normalnode = "write_1"
        elseif self._params.state == 0 then
            _label = LANGUAGE_BTN_KEY.noAchieve
            normalnode = "write"

        end
        local challenge_btn = XTHD.createCommonButton({
            btnSize = cc.size(200, 46),
            btnColor = normalnode,
            isScrollView = false,
            text = _label,
        })
        challenge_btn:setScale(0.8)
        challenge_btn:setPosition(popNode:getContentSize().width / 2,66)
        popNode:addChild(challenge_btn)

        challenge_btn:setTouchEndedCallback(function()
            if self._params.state == 0 then
                XTHDTOAST(LANGUAGE_TIPS_WORDS177)
            elseif self._params.state == 1 then
                ClientHttp:requestAsyncInGameWithParams({
                    modules = "wantedStarReward?",
                    params = {star = gameData.getDataFromCSV("XsTaskReward", {["id"]=self._type}).stars},
                    successCallback = function(data)
                        if tonumber(data.result) == 0 then
                            -- bagItems  背包 
                            if data.bagItems then
                                for i=1,#data.bagItems do
                                   DBTableItem.updateCount(gameUser.getUserId(),data.bagItems[i], data.bagItems[i]["dbId"])
                                end
                            end
                            -- 更新属性
                            if data.property and #data.property > 0 then
                                for i=1, #data.property do
                                    local pro_data = string.split( data.property[i], ',' )
                                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
                                end
                            end
                            if data.bounty then
                                gameUser.setBounty( data.bounty )
                            end
                            local show = {}
                            for i = 1, #self._static[self._type] do
                                show[i] = {}
                                show[i].rewardtype = self._static[self._type][i].type
                                show[i].id = self._static[self._type][i].id
                                show[i].num = self._static[self._type][i].num
                            end
                            ShowRewardNode:create(show)
                            if self._params.callback and type(self._params.callback) == "function" then
                                self._params.callback(data)
                            end
                            self:hide() 
                        else
                           XTHDTOAST(data.msg) 
                        end
                    end,--成功回调
                    loadingParent = self,
                    failedCallback = function()
                        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
                    end,--失败回调
                    targetNeedsToRetain = self,
                    loadingType = HTTP_LOADING_TYPE.CIRCLE,
                })
            end
        end)
    end
end

function XuanShangRenWuGetPopLayer:create(params)
    local _layer = self.new(params)
    return _layer
end
return XuanShangRenWuGetPopLayer