--世界boss推送弹窗1 huangjunjian XiongShouLaiXiHatredPop
local XiongShouLaiXuKillPop = class("XiongShouLaiXuKillPop",function()
    return XTHD.createPopLayer()
end)
local fontColor = cc.c3b(53,25,26)  --通用字体颜色
function XiongShouLaiXuKillPop:ctor(data)
    self.campid=data.campid or 1
    self.name = data.name or ""
    self.bossid=data.rewardid or 1
    if self.name~="" then 
	   self.reward_data=gameData.getDataFromCSV("MonsterAttack",{["id"] =self.bossid})["killreward"]	
       self:initKill()
    else
       self.reward_data=gameData.getDataFromCSV("MonsterAttack",{["id"] =self.bossid})["battlereward"]
       self:initOver() 
    end 	
end

function XiongShouLaiXuKillPop:initKill()
    if self._containerLayer then
        self._containerLayer:setTouchEndedCallback(function() 
        end)
    end
    local _popBgSprite = ccui.Scale9Sprite:create(cc.rect(69,69,1,1),"res/image/common/scale9_bg_1.png")
    _popBgSprite:setContentSize(cc.size(470,292))
    _popBgSprite:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
    self:addContent(_popBgSprite)
    local title_bg = XTHD.createSprite("res/image/worldboss/kill_top.png")
    title_bg:setAnchorPoint(0.5,1)
    title_bg:setPosition(_popBgSprite:getContentSize().width*0.5,_popBgSprite:getContentSize().height-5)
    _popBgSprite:addChild(title_bg)

    local camp_sp=cc.Sprite:create("res/image/worldboss/camp_"..self.campid..".png")
    camp_sp:setPosition(255,camp_sp:getContentSize().height*0.5 + 10)
    title_bg:addChild(camp_sp)

    local tableview_bg = ccui.Scale9Sprite:create("res/image/common/common_opacity.png")
    self.tableview_bg=tableview_bg
    tableview_bg:setContentSize(_popBgSprite:getContentSize().width-18,_popBgSprite:getContentSize().height-70-60)
    tableview_bg:setAnchorPoint(0,0)
    tableview_bg:setPosition(9,60+15)
    _popBgSprite:addChild(tableview_bg)

    local kill_name=XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS239,
        size = 20,
        color= cc.c3b(132,28,31),
        anchor = cc.p(1, 1),
        pos = cc.p(tableview_bg:getContentSize().width*0.5, tableview_bg:getContentSize().height-20)
    })
    tableview_bg:addChild(kill_name)

    local kill_name2 = XTHDLabel:createWithParams({
        text = self.name,
        size = 20,
        pos = cc.p(tableview_bg:getContentSize().width*0.5,tableview_bg:getContentSize().height-20),
        color = cc.c3b(74,34,34),
        anchor = cc.p(0, 1)
    })
    tableview_bg:addChild(kill_name2)

    local function _touchEnd( ... )
        cc.Director:getInstance():resume()
        XTHDHttp:requestAsyncInGameWithParams({
            modules = "exitEctype?",
            successCallback = function(data)
                if tonumber(data.result) == 0 then
                    self:removeFromParent()
                    cc.Director:getInstance():getScheduler():setTimeScale(1.0)
                    cc.Director:getInstance():popScene() 
                else
                   XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
                end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end

    local ok_btn = XTHD.createCommonButton({
        text = LANGUAGE_KEY_SURE,
        isScrollView = false,
        btnSize = cc.size(130, 51),
        fontSize = 22,
        anchor = cc.p(0.5, 0),
        pos = cc.p(_popBgSprite:getContentSize().width*0.5,15),
        endCallback = _touchEnd,
    })
    _popBgSprite:addChild(ok_btn)

     self:createItem()
end 

function XiongShouLaiXuKillPop:initOver()
    local _popBgSprite = ccui.Scale9Sprite:create(cc.rect(69,69,1,1),"res/image/common/scale9_bg_1.png")
    _popBgSprite:setContentSize(cc.size(470,292))
    _popBgSprite:setPosition(self:getContentSize().width*0.5,self:getContentSize().height*0.5)
    self:addContent(_popBgSprite)

    local tableview_bg = ccui.Scale9Sprite:create("res/image/common/common_opacity.png")
    self.tableview_bg=tableview_bg
    tableview_bg:setContentSize(_popBgSprite:getContentSize().width-18,_popBgSprite:getContentSize().height-70-60)
    tableview_bg:setAnchorPoint(0,0)
    tableview_bg:setPosition(9,60+15)
    _popBgSprite:addChild(tableview_bg)

    local kill_name=XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS240,
        color = cc.c3b(73,34,34),
        anchor = cc.p(0.5,0),
        size = 24,
        pos = cc.p(tableview_bg:getContentSize().width*0.5, tableview_bg:getContentSize().height+5),
    })
    tableview_bg:addChild(kill_name)

    local kill_name2 = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS241,
        pos = cc.p(tableview_bg:getContentSize().width*0.5, tableview_bg:getContentSize().height-20),
        color = cc.c3b(74,34,34),
        anchor = cc.p(0.5, 1),
        size = 20,
    })
    tableview_bg:addChild(kill_name2)

    local function _endCall( ... )
        cc.Director:getInstance():resume()
        XTHDHttp:requestAsyncInGameWithParams({
            modules = "exitEctype?",
            successCallback = function(data)
                if tonumber(data.result) == 0 then
                    self:removeFromParent()
                    cc.Director:getInstance():getScheduler():setTimeScale(1.0)
                    cc.Director:getInstance():popScene() 
                else
                   XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
                end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end

    local ok_btn = XTHD.createCommonButton({
        text = LANGUAGE_KEY_SURE,
        isScrollView = false,
        btnSize = cc.size(130, 51),
        fontSize = 22,
        anchor = cc.p(0.5,0),
        pos = cc.p(_popBgSprite:getContentSize().width*0.5, 15),
        endCallback = _endCall
    })
    _popBgSprite:addChild(ok_btn)
    self:createItem()
end 


function XiongShouLaiXuKillPop:createItem()
	local table  = string.split(self.reward_data,",")
    local  fall_items={}
	for k,v in ipairs(table) do
		v=string.split(v,"#")
		fall_items[#fall_items+1]=v
	end
	-- 可能掉落
	self.drop_data=fall_items
	local pos_table=SortPos:sortFromMiddle( cc.p(self.tableview_bg:getContentSize().width/2,25), tonumber(#fall_items),80)
	for i,var in ipairs(fall_items) do
		print(i)
		local item_bg=nil
		local items_info=nil 
		items_info = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = var[2]} )
		item_bg = ItemNode:createWithParams({
		itemId =tonumber(var[2]),--items_info["itemid"],
		needSwallow = true,
		_type_ =tonumber(var[1]),
		count=tonumber(var[3])
		})
		item_bg:setScale(0.7)
        item_bg:setAnchorPoint(0.5,0)
		item_bg:setPosition(pos_table[i])
		self.tableview_bg:addChild(item_bg)
		if tonumber(var[1])==10 then--神石
			items_info["name"]=LANGUAGE_TABLE_RESOURCENAME[10]
		elseif tonumber(var[1])==2 then--银两
			items_info["name"]=LANGUAGE_TABLE_RESOURCENAME[2]
		elseif tonumber(var[1])==3 then--元宝
			items_info["name"]=LANGUAGE_TABLE_RESOURCENAME[3]
		elseif tonumber(var[1])==6 then--翡翠
			items_info["name"]=LANGUAGE_TABLE_RESOURCENAME[6]
		elseif tonumber(var[1])==50 then--英雄	
			items_info["name"]=gameData.getDataFromCSV("GeneralInfoList", {["heroid"]=tonumber(var[2])})["name"] or ""
		end 
		local item_name_label = XTHDLabel:createWithParams({
            text = items_info["name"],
            anchor=cc.p(0.5,1),
            fontSize = 18,--字体大小
            color = cc.c3b(74,34,34),
            pos = cc.p(item_bg:getContentSize().width/2,-2),
        })
        item_bg:addChild(item_name_label)
	end
end

function XiongShouLaiXuKillPop:create(data)
    local _layer = self.new(data)
    return _layer
end

return XiongShouLaiXuKillPop