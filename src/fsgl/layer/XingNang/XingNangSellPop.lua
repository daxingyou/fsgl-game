local TAG = "XingNangSellPop"

local  XingNangSellPop  = class( "XingNangSellPop", function ( ... )
    return XTHDPopLayer:create()
end)

function XingNangSellPop:InitUI(item_data)

    local scale9_popNode =  ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
    scale9_popNode:setContentSize(cc.size(355,445))
    scale9_popNode:setCascadeOpacityEnabled(true)
    scale9_popNode:setCascadeColorEnabled(true)

	local pop_bg =XTHDPushButton:createWithParams({
        normalNode = scale9_popNode,
    })
    pop_bg:setAnchorPoint(0.5,1)
	pop_bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height-85)
	self:addContent(pop_bg)
	self.popNode = pop_bg

	local close_btn = XTHD.createBtnClose(function()
        self:hide()
    end)
    close_btn:setPosition(cc.p(pop_bg:getContentSize().width-8,pop_bg:getContentSize().height-8))
    pop_bg:addChild(close_btn)


    local item_info = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=item_data.itemid})        
    --装备图标
    local item_sp = ZhuangBeiItem:createSimpleItem(item_data)
    item_sp:setName("item_sp")
    item_sp:setAnchorPoint(0,1)
    item_sp:setPosition(17, pop_bg:getContentSize().height-17 )
    pop_bg:addChild(item_sp)
    --装备名字
    self._item_name_label = XTHDLabel:createWithParams({
        text = item_info["name"],
        anchor=cc.p(0,1),
        fontSize = 18,--字体大小
        pos = cc.p(item_sp:getPositionX() + item_sp:getContentSize().width+5,item_sp:getPositionY()),
        color = cc.c3b(70,34,34)
    })
    self._item_name_label:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
    pop_bg:addChild(self._item_name_label)

    local _own_txt = XTHDLabel:createWithParams({
        text = LANGUAGE_VERBS.owned,------"拥有: ",
        anchor=cc.p(0,0.5),
        fontSize = 18,--字体大小
        pos = cc.p(self._item_name_label:getPositionX(),item_sp:getPositionY()- item_sp:getContentSize().height/2),
        color = self._item_name_label:getColor(),
    })
    pop_bg:addChild(_own_txt)

    local owm_label =getCommonWhiteBMFontLabel(item_data["count"])
    owm_label:setAnchorPoint(0,0.5)
    owm_label:setPosition(_own_txt:getPositionX()+ _own_txt:getContentSize().width,_own_txt:getPositionY()-5)
    pop_bg:addChild(owm_label)

    local jian_label = XTHDLabel:createWithParams({
        text = LANGUAGE_OTHER_TXTJIAN,---------- " 件",
        anchor=cc.p(0,0.5),
        fontSize = 18,--字体大小
        pos = cc.p(owm_label:getPositionX()+owm_label:getContentSize().width,_own_txt:getPositionY()),
        color = self._item_name_label:getColor(),
    })
    pop_bg:addChild(jian_label)

    if tonumber(item_data["item_type"]) == 3 then
        local limit_label = XTHDLabel:createWithParams({
            text = LANGUAGE_KEY_HERO_TEXT.itemHeroTypeTextXc,------"限制  ",
            anchor=cc.p(0,0),
            fontSize = 18,--字体大小
            pos = cc.p(self._item_name_label:getPositionX(),item_sp:getPositionY()-item_sp:getContentSize().height),
            color = self._item_name_label:getColor()
        })
        pop_bg:addChild(limit_label)
        local equip_info  = gameData.getDataFromCSV("EquipInfoList", {["itemid"]=item_data.itemid})
        if equip_info then
            local _tab = string.split(equip_info["herotype"], '#')
            for i=1,#_tab do
                
                local imgPath = nil
                if _tab[i] then
                   imgPath= "res/image/plugin/hero/hero_type_".._tab[i]..".png"
                else
                     imgPath= "res/image/plugin/hero/hero_type_1.png"
                end
               local _sp = cc.Sprite:create(imgPath)
                _sp:setScale(0.8)
                _sp:setAnchorPoint(0,0.5)
                _sp:setPosition(limit_label:getPositionX()+ limit_label:getContentSize().width+(_sp:getContentSize().width*_sp:getScale()+1)*(i-1),limit_label:getPositionY()+limit_label:getContentSize().height/2)
                pop_bg:addChild(_sp)
            end
        end
    end

    local price_bg = ccui.Scale9Sprite:create()
    price_bg:setContentSize(cc.size(325,58))
    price_bg:setCascadeOpacityEnabled(true)
    price_bg:setCascadeColorEnabled(true)
    price_bg:setAnchorPoint(0.5,1)
    price_bg:setPosition(pop_bg:getContentSize().width/2, item_sp:getPositionY()-item_sp:getContentSize().height-20)
    pop_bg:addChild(price_bg)


    local price_label =  XTHDLabel:createWithParams({
        text = LANGUAGE_SHOP_TIPS1,------"出售单价: ",
        anchor=cc.p(0,0.5),
        fontSize = 18,--字体大小
        pos = cc.p(13,price_bg:getContentSize().height/2),
        color = self._item_name_label:getColor(),
    })
    price_bg:addChild(price_label)

    local gold_sp = cc.Sprite:create("res/image/common/header_gold.png")
    gold_sp:setScale(0.85)
    gold_sp:setAnchorPoint(0,0.5)
    gold_sp:setPosition(price_label:getPositionX()+price_label:getContentSize().width+5, price_label:getPositionY())
    price_bg:addChild(gold_sp)

    local price_txt = getCommonWhiteBMFontLabel(item_info["price"])
    price_txt:setAnchorPoint(0,0.5)
    price_txt:setPosition(cc.p(gold_sp:getPositionX() + gold_sp:getContentSize().width-3 ,price_label:getPositionY()-5))

    price_bg:addChild(price_txt)

    local count_tosell_label =  XTHDLabel:createWithParams({
        text = LANGUAGE_SHOP_TIPS12..":",------选择出售数量:",
        anchor=cc.p(0,1),
        fontSize = 18,--字体大小
        pos = cc.p(30,price_bg:getPositionY() - price_bg:getContentSize().height-20),
        color = cc.c3b(255,79,2),--price_label:getColor(),
    })
    count_tosell_label:enableShadow(cc.c4b(255,79,2,255),cc.size(0.4,-0.4),1)
    pop_bg:addChild(count_tosell_label)

    --加减按钮，数量显示背景
    local sell_bg = ccui.Scale9Sprite:create()
    sell_bg:setContentSize(cc.size(325,58))
    sell_bg:setCascadeOpacityEnabled(true)
    sell_bg:setCascadeColorEnabled(true)
    sell_bg:setAnchorPoint(0.5,1)
    sell_bg:setPosition(price_bg:getPositionX(), count_tosell_label:getPositionY()-count_tosell_label:getContentSize().height -10)
    pop_bg:addChild(sell_bg)

    --拥有数量
    local owm_bg = ccui.Scale9Sprite:create()-- cc.Sprite:create("res/image/plugin/warehouse/owm_bg.png")
    owm_bg:setContentSize(cc.size(325,35))
    owm_bg:setAnchorPoint(0.5,0)
    owm_bg:setCascadeOpacityEnabled(true)
    owm_bg:setCascadeColorEnabled(true)
    owm_bg:setAnchorPoint(0.5,0)
    owm_bg:setName("owm_bg")
    owm_bg:setPosition(pop_bg:getContentSize().width/2, 105)
    pop_bg:addChild(owm_bg)

    local get_money_label = XTHDLabel:createWithParams({
        text = LANGUAGE_TIP_GET_MONEY,------"获得金钱",
        anchor=cc.p(0,0.5),
        fontSize = 18,--字体大小
        pos = cc.p(13, owm_bg:getContentSize().height/2),
        color = price_label:getColor(),
    })
    get_money_label:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)
    owm_bg:addChild(get_money_label)

    local get_gold_sp = cc.Sprite:create("res/image/common/header_gold.png")
    get_gold_sp:setScale(0.85)
    get_gold_sp:setAnchorPoint(0,0.5)
    get_gold_sp:setPosition(owm_bg:getContentSize().width-120, owm_bg:getContentSize().height/2)
    owm_bg:addChild(get_gold_sp)

    self._get_label = getCommonWhiteBMFontLabel(item_info["price"])
    self._get_label:setAnchorPoint(0,0.5)
    self._get_label:setPosition(cc.p(get_gold_sp:getPositionX() + get_gold_sp:getContentSize().width-3,get_money_label:getPositionY()-5))
    owm_bg:addChild(self._get_label)

    local count_num = 1
    local count_label = getCommonWhiteBMFontLabel("1")
    	--减少按钮
    local Reduce_btn = XTHDPushButton:createWithParams({
        normalFile     = "res/image/common/btn/btn_reduce_normal.png",
        selectedFile   = "res/image/common/btn/btn_reduce_selected.png",
        anchor         = cc.p(0,0.5),
        pos     	   = cc.p(12,sell_bg:getContentSize().height/2),
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback = function()
        	if tonumber( count_label:getString()) <= 1 then
        		XTHDTOAST(LANGUAGE_SHOP_TIPS3)------"数量最少为1!")
        		return
        	end
            count_num = count_num -1
            count_label:setString(tostring(count_num))
            if self._get_label then
        		self._get_label:setString(count_num*tonumber(item_info["price"]))
        	end
    	end
    })
    Reduce_btn:setLabelColor(cc.c3b(255,255,0))
    sell_bg:addChild(Reduce_btn)
           -- 黑背景
    local dark_bg = ccui.Scale9Sprite:create(cc.rect(64,14,1,1),"res/image/friends/input_bg.png")
    dark_bg:setContentSize(cc.size(151,31))
    dark_bg:setAnchorPoint(0,0.5)
    dark_bg:setPosition(Reduce_btn:getPositionX()+Reduce_btn:getContentSize().width+3, sell_bg:getContentSize().height/2)
    sell_bg:addChild(dark_bg)

    count_label:setPosition(dark_bg:getContentSize().width/2, dark_bg:getContentSize().height/2-7)
    dark_bg:addChild(count_label)

            --全部
    local All_btn = XTHDPushButton:createWithParams({
        normalFile     = "res/image/common/btn/btn_max_normal.png",
        selectedFile   = "res/image/common/btn/btn_max_selected.png",
        anchor         = cc.p(1,0.5),
        pos            = cc.p(sell_bg:getContentSize().width-12,sell_bg:getContentSize().height/2),
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback = function()
            if count_num == tonumber(item_data["count"]) then
                XTHDTOAST(LANGUAGE_KEY_TOLIMIT)------"数量已达上限!")
                return
            end
            count_num = item_data["count"]
            count_label:setString(tostring(count_num))
            if self._get_label then
                self._get_label:setString(count_num*tonumber(item_info["price"]))
            end
        end
    })
    All_btn:setLabelColor(cc.c3b(255,255,0))
    sell_bg:addChild(All_btn)
    --增加
    local Plus_btn = XTHDPushButton:createWithParams({
        normalFile     = "res/image/common/btn/btn_plus_normal.png",
        selectedFile   = "res/image/common/btn/btn_plus_selected.png",
        anchor         = cc.p(1,0.5),
        pos            = cc.p(All_btn:getPositionX() -All_btn:getContentSize().width -7,sell_bg:getContentSize().height/2),
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback = function()
            if count_num >= tonumber(item_data["count"]) then
                XTHDTOAST(LANGUAGE_KEY_TOLIMIT)------"数量已达上限,不可再增加!")
                return
            end
            count_num = count_num +1
            count_label:setString(tostring(count_num))
            if self._get_label then
                self._get_label:setString(count_num*tonumber(item_info["price"]))
            end
        end
    })
    Plus_btn:setLabelColor(cc.c3b(255,255,0))
    sell_bg:addChild(Plus_btn)   	

    self._sell_btn = XTHD.createCommonButton({
        btnColor = "write_1",
        isScrollView = false,
        btnSize = cc.size(334,69),
        text = LANGUAGE_KEY_ENSURE[1],
        fontSize = 25,
        musicFile = XTHD.resource.music.effect_btn_common,
        needSwallow = false,
    })
    self._sell_btn:setScale(0.8)
    self._sell_btn:setTouchEndedCallback(function()
  		ClientHttp:requestAsyncInGameWithParams({
            modules = "sellItem?",
	        params = {dbId=item_data["dbid"],count=tostring(count_num)},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
	        successCallback = function(data)
	        if tonumber(data.result) == 0 then
                    owm_label:setString(data["itemCount"])
                    count_label:setString("1")
                    count_num = 1
                    item_data["count"] = data["itemCount"]
                    item_sp:setCountNumber(data["itemCount"])

                    if data["property"] then
                        for i=1,#data["property"] do
                            local pro_data = string.split( data["property"][i],',')
                              DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
                        end
                    end
                    gameUser.setGold(data["silver"])
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
	           --获得资源数据存储，前界面数据刷新，所有涉及资源界面的数据刷新
	           if self._sellCallback  then
	           	  --出售资源成功回调
		           	XTHDTOAST(LANGUAGE_SHOP_TIPS13)-------"卖出成功!") --close_or_not
		           	if tonumber(data["itemCount"]) == 0 then
		           		self._sellCallback(data,true)
		           		self:hide()
		           	else
		           		self._sellCallback(data,false)
		           	end
	           end
	        else
                XTHDTOAST(data.msg)
	        end
	        end,--成功回调
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败")
	            --self:removeFromParent()
	        end,--失败回调
	        targetNeedsToRetain = self,--需要保存引用的目标
	        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	    })
  	end)
    self._sell_btn:setPosition(pop_bg:getContentSize().width/2, self._sell_btn:getContentSize().height/2+13)
    pop_bg:addChild(self._sell_btn)
	self:show()
end

function XingNangSellPop:ctor(item_data,sellCallback)
	self._sellCallback = sellCallback
	self:InitUI(item_data)
end
function XingNangSellPop:create(item_data,sellCallback)
	local layer = self.new(item_data,sellCallback)
	layer.beginPos = cc.p(layer:getContentSize().width/2,layer:getContentSize().height/2)
	return layer
end

return XingNangSellPop