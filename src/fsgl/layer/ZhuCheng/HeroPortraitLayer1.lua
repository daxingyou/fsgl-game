--[[
	created by LITAO ,only for players to exchange thier protrait.
]]
--更改头像界面
local HeroPortraitLayer1 = class("HeroPortraitLayer1",function(  )
	return XTHDPopLayer:create()
end)

function HeroPortraitLayer1:ctor(parent)
	self._parent = parent
	self._iconView = nil
    self._iconTitleBGSize = cc.size(509,29)
    self._typebtnList = {}
    self._selectedIndex = 0

    self._sourceData = {{},{},{},{}} -----1 默认头像、2 普通、3VIP、4特殊
    self._okayData = {{},{},{},{}}
	local _data = gameData.getDataFromCSV("PlayerHeadOn") ------将数据分组存储    
    for i = 1,#_data do 
        _data[i].canGet = self:isTheProtraitOkay(_data[i])
        if _data[i].typeA == 1 then 
            self._sourceData[1][#self._sourceData[1] + 1] = _data[i]  
        elseif _data[i].typeA == 2 then
            self._sourceData[2][#self._sourceData[2] + 1] = _data[i]
        elseif _data[i].typeA == 3 then
            self._sourceData[3][#self._sourceData[3] + 1] = _data[i]
        elseif _data[i].typeA == 4 then
            self._sourceData[4][#self._sourceData[4] + 1] = _data[i]
        end 
    end 
    for i = 1,4 do  
        if #self._sourceData[i] > 0 then 
            table.sort(self._sourceData[i],function( a,b )
                if a.canGet ~= b.canGet then
                    return a.canGet
                end
                return a.id < b.id 
            end)
        end 
    end 	
end

function HeroPortraitLayer1:create(parent)
	local _layer = HeroPortraitLayer1.new(parent)
	if _layer then 
		_layer:init()
	end 
	return _layer
end

function HeroPortraitLayer1:init( )
    self:setColor(cc.c3b(0,0,0))
    self:setOpacity(70)
    local avatorsBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    avatorsBg:setContentSize(cc.size(569,468))
    avatorsBg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
    self:addContent(avatorsBg)
     --背景
    local tableviewBg=ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    tableviewBg:setContentSize(cc.size(avatorsBg:getContentSize().width - 60, avatorsBg:getContentSize().height - 50))
    tableviewBg:setAnchorPoint(0,0)
    tableviewBg:setPosition(cc.p(30, 25));
    avatorsBg:addChild(tableviewBg)
    --关闭
    local closeBtn = XTHD.createBtnClose(function(  )
    	self:removeFromParent()
    end)
    closeBtn:setAnchorPoint(cc.p(0.5, 0.5));
    closeBtn:setPosition(cc.p(avatorsBg:getContentSize().width-10, avatorsBg:getContentSize().height - 10))
    avatorsBg:addChild(closeBtn)
    --三个标签页
    for i = 1, 3 do
        local normal = cc.Sprite:create("res/image/illustration/btn/btn_1_".. i .. "_down.png")
        local recommendBtn = XTHD.createButton({
            normalFile = "res/image/common/btn/heroPortraitbtn_".. i .. "_up.png",
            selectedFile = "res/image/common/btn/heroPortraitbtn_".. i .. "_down.png"
        })
        recommendBtn:setPosition(150*i - 12,avatorsBg:getContentSize().height - 55)
        avatorsBg:addChild(recommendBtn)
        recommendBtn:setTouchEndedCallback(function()
            self:reloadData(i + 1)
        end)
        self._typebtnList[#self._typebtnList + 1] = recommendBtn
    end
    --经典头像tableview
    local tableView = ccui.ListView:create()
    tableView:setContentSize(cc.size(avatorsBg:getContentSize().width - 60, avatorsBg:getContentSize().height - 120))
    tableView:setName("classical")
    tableView:setDirection(ccui.ScrollViewDir.vertical)
    tableView:setScrollBarEnabled(false)
    tableView:setBounceEnabled(true)
    tableView:setPosition(cc.p(30, 40))
    avatorsBg:addChild(tableView)
    self._iconView = tableView
    self:reloadData(2)
end

function HeroPortraitLayer1:reloadData(index)
    -- if self._selectedIndex == index then return end
    for i = 1,#self._typebtnList do
        self._typebtnList[i]:setSelected(false)
    end
    self._typebtnList[index - 1]:setSelected(true)
    self._iconView:removeAllChildren()
    if #self._sourceData[index] > 0 then 
        local _layout = ccui.Layout:create()
        _layout:setContentSize(self._iconTitleBGSize)
        -------标题
        -- local classicalAvatorFontBg = cc.Sprite:create("res/image/setting/avatorbg_vip.png")
        -- classicalAvatorFontBg:setAnchorPoint(cc.p(0.5, 1))
        -- classicalAvatorFontBg:setPosition(cc.p(_layout:getContentSize().width / 2, _layout:getContentSize().height / 2 + 15))
        -- _layout:addChild(classicalAvatorFontBg)
        -- local classicalAvatorFont = XTHDLabel:createWithParams({text = LANGUAGE_KEY_PLAYERPORTRAITNAME[i],ttf = "",size = 22})-----"普通头像"
        -- classicalAvatorFont:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1,-1))
        -- classicalAvatorFont:setColor(cc.c3b(228,214,80))
        -- classicalAvatorFont:setAnchorPoint(cc.p(0, 0.5))
        -- classicalAvatorFont:setPosition(cc.p(10, classicalAvatorFontBg:getContentSize().height/2))
        -- classicalAvatorFontBg:addChild(classicalAvatorFont)
        self._iconView:pushBackCustomItem(_layout)
        -----头像
        local j = 1
        local hasAdded = false
        local _node = ccui.Layout:create()
        _node:setContentSize(cc.size(self._iconTitleBGSize.width,75))            
        for k,v in pairs(self._sourceData[index]) do   
            local avator = HeroNode:createWithParams({
                heroid = v.resource,
                star   = 0,
                level  = 0,
                isHero = false,
                advance   = 0,
				isScrollView=true
            }) 
            avator:setPosition(cc.p(65 + (j-1)*(avator:getBoundingBox().width-5-8)-11, avator:getBoundingBox().height/2-10))
            avator:setScale(0.7)
            local isclock = v.canGet
            if isclock == false then 
                XTHD.setGray(avator:getChildByName("item_border"):getChildByName("hero_img"),true)
            end
            avator:setTouchEndedCallback(function (  )
                if isclock == true then
                    self._parent:changAcator(v.resource)--头像排序暂时按照英雄id来by。huangjunjian
                    self:removeFromParent()
                else
                    -- XTHDTOAST(LANGUAGE_FORMAT_TIPS29(v.condition))--------"人物等级达到"..."级解锁！")
                    XTHDTOAST(LANGUAGE_KEY_UNAVAILABLEICON)
                end
            end)
            _node:addChild(avator)
            hasAdded = false
            if j == 6 then 
                self._iconView:pushBackCustomItem(_node)
                _node = ccui.Layout:create()
                _node:setContentSize(cc.size(self._iconTitleBGSize.width,75))
                hasAdded = true
                j = 1
            else 
                j = j + 1
            end 
        end 
        if hasAdded == false then 
            self._iconView:pushBackCustomItem(_node)
        end 
    end 
    self._selectedIndex = index
end

function HeroPortraitLayer1:isTheProtraitOkay(data)
    local isOkay = false
    if data then 
        local _level = gameUser.getLevel()
        local _vip = gameUser.getVip()
        if data.typeB == 1 then ----玩家等级
            if _level >= data.condition then 
                isOkay = true                
            end 
        elseif data.typeB == 2 then  -----vip等级
            if _vip >= data.condition then 
                isOkay = true
            end 
        elseif data.typeB == 3 then  ---需要对应的英雄ID
            local _heroData = DBTableHero.getDataByID( data.condition )
            if _heroData and next(_heroData) ~= nil then 
                isOkay = true
            end 
        end 
    end 
    return isOkay
end

return HeroPortraitLayer1