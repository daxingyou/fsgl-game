local TAG = "LiaoTianShare"

local  LiaoTianShare  = class( "LiaoTianShare", function ( ... )
    return XTHDPopLayer:create()
end)

function LiaoTianShare:InitUI(item_data)
    local scale9_popNode =  ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
    scale9_popNode:setContentSize(cc.size(355,355))
    scale9_popNode:setCascadeOpacityEnabled(true)
    scale9_popNode:setCascadeColorEnabled(true)
    scale9_popNode:setOpacity(200)

	local pop_bg =XTHDPushButton:createWithParams({
        normalNode = scale9_popNode,
    })
    pop_bg:setAnchorPoint(0.5,1)
	pop_bg:setPosition(self:getContentSize().width/2,self:getContentSize().height-85)
	self:addContent(pop_bg)
	self.popNode = pop_bg

	local close_btn = XTHD.createBtnClose(function()
        self:hide()
    end)
    close_btn:setPosition(cc.p(pop_bg:getContentSize().width-8,pop_bg:getContentSize().height-8))
    pop_bg:addChild(close_btn)


    local item_info = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=item_data.propet.itemId})        
    --装备图标
		local item_sp = ItemNode:createWithParams({
            _type_ = 4,
            itemId = item_info.itemid,
--			count  = item_data.propet.count,
        })

--    local item_sp = cc.Sprite:create("res/image/item/props"..tostring(item_data.propet.resourceid)..".png")
    item_sp:setName("item_sp")
    item_sp:setAnchorPoint(0,1)
    item_sp:setPosition(17, 320 )
    pop_bg:addChild(item_sp)


    --装备名字
    self._item_name_label = XTHDLabel:createWithParams({
        text = item_data.propet.name,
        anchor=cc.p(0,1),
        fontSize = 18,--字体大小
        pos = cc.p(item_sp:getPositionX() + item_sp:getContentSize().width+5,item_sp:getPositionY() - 10),
        color = cc.c3b(70,34,34)
    })
    self._item_name_label:enableShadow(cc.c4b(70,34,34,255),cc.size(0.4,-0.4),1)

    --self:initScene
    pop_bg:addChild(self._item_name_label)

    if tonumber(item_data.propet["item_type"]) == 3 then
		scale9_popNode:setContentSize(cc.size(355,360))
        local limit_label = XTHDLabel:createWithParams({
            text = LANGUAGE_KEY_HERO_TEXT.itemHeroTypeTextXc,------"限制  ",
            anchor=cc.p(0,0),
            fontSize = 18,--字体大小
            pos = cc.p(self._item_name_label:getPositionX(),item_sp:getPositionY()-item_sp:getContentSize().height + 15),
            color = self._item_name_label:getColor()
        })
        pop_bg:addChild(limit_label)
        local equip_info  = gameData.getDataFromCSV("EquipInfoList", {["itemid"]=item_data.propet.itemId})
        print("传过去的ID",item_data.propet.itemid)
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
        local property =  item_data.propet.property
        local strengLevel = XTHDLabel:createWithParams({
            text = "强化等级：+"..tostring(property.strengLevel),------"限制  ",
            anchor=cc.p(0,0),
            fontSize = 18,--字体大小
            pos = cc.p(item_sp:getPositionX(),item_sp:getPositionY()-item_sp:getContentSize().height *1.5 ),
            color = self._item_name_label:getColor()
        })
        pop_bg:addChild(strengLevel)
        
        local phaseLevel = XTHDLabel:createWithParams({
            text = "装备升星：",------"限制  ",
            anchor=cc.p(0,0),
            fontSize = 18,--字体大小
            pos = cc.p(item_sp:getPositionX(),strengLevel:getPositionY() - strengLevel:getContentSize().height *2),
            color = self._item_name_label:getColor()
        })
        pop_bg:addChild(phaseLevel)
        local count = property.phaseLevel
        if count >= 1 then
            for i = 1,count do
                local star = cc.Sprite:create("res/image/equipCopies/star.png")
                pop_bg:addChild(star)
                star:setPosition(phaseLevel:getContentSize().width + star:getContentSize().width + (i-1)*star:getContentSize().width *1.2,phaseLevel:getPositionY() +star:getContentSize().height /2)
            end
        end

        local basedata =  string.split(property["baseProperty"], '#')
        print("***********************",basedata[2])
        if basedata[2] == nil then
            local str = nil
            local itmedata = string.split(basedata[1], ",")
            if itmedata[1] == "203" then
                str = "魔攻加成：+"..tostring(itmedata[2])
            elseif itmedata[1] == "201" then
                str = "物攻加成：+"..tostring(itmedata[2])
            elseif itmedata[1] == "200" then
                str = "生命加成：+"..tostring(itmedata[2])
            end
            local baseProperty = XTHDLabel:createWithParams({
                text = str,------"限制  ",
                anchor=cc.p(0,0),
                fontSize = 18,--字体大小
                pos = cc.p(item_sp:getPositionX(),phaseLevel:getPositionY() - phaseLevel:getContentSize().height *2),
                color = self._item_name_label:getColor()
            })
            pop_bg:addChild(baseProperty)
        else
            local str1,str2
            local itmedata = string.split(basedata[1], ",")
            local itmedata_2 = string.split(basedata[2], ",")
            if itmedata[1] == "202" and itmedata_2[1] == "204" then
                str1 = "物防加成：+"..tostring(itmedata[2])
                str2 = "魔防加成：+"..tostring(itmedata_2[2])
            end

            if itmedata[1] == "201" and itmedata_2[1] == "203" then
                str1 = "物攻加成：+"..tostring(itmedata[2])
                str2 = "魔攻加成：+"..tostring(itmedata_2[2])
            end

            local baseProperty = XTHDLabel:createWithParams({
                text = str1,------"限制  ",
                anchor=cc.p(0,0),
                fontSize = 18,--字体大小
                pos = cc.p(item_sp:getPositionX(),phaseLevel:getPositionY() - phaseLevel:getContentSize().height *2),
                color = self._item_name_label:getColor()
            })
            pop_bg:addChild(baseProperty)

            local baseProperty_2 = XTHDLabel:createWithParams({
                text = str2,------"限制  ",
                anchor=cc.p(0,0),
                fontSize = 18,--字体大小
                pos = cc.p(item_sp:getPositionX(),baseProperty:getPositionY() - baseProperty:getContentSize().height *2),
                color = self._item_name_label:getColor()
            })
            pop_bg:addChild(baseProperty_2)
        end

    else
        --dump(item_data)
		scale9_popNode:setContentSize(cc.size(355,300))
        local item_info = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=item_data.itemId})
        print(item_data.itemId)
        --dump(item_info,"77777777777")   
        local phaseLevel = XTHDLabel:createWithParams({
            text = item_info.effect,
            anchor=cc.p(0,0),
            fontSize = 16,--字体大小
            color = self._item_name_label:getColor()
        })
        phaseLevel:setDimensions(pop_bg:getContentSize().width - 50, 300)
        phaseLevel:setAnchorPoint(cc.p(0,1))
        phaseLevel:setPosition(cc.p(20,200))
        pop_bg:addChild(phaseLevel)
    end

	self:show()
end

function LiaoTianShare:ctor(item_data)
	self:InitUI(item_data)
end
function LiaoTianShare:create(item_data,sellCallback)
	local layer = self.new(item_data,sellCallback)
	layer.beginPos = cc.p(layer:getContentSize().width*2,layer:getContentSize().height)
	return layer
end

return LiaoTianShare