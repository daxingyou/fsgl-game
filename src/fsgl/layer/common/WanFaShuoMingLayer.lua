--[[
玩法说明公用pop create by.huangjunjian 2015.7.17
]]
--[[
1   种族系统  ok
2   装备强化
3   装备进阶
4   装备洗练
5   演武场
6   装备回收
7   赏金猎人
8   试炼之塔
9   天兵阁
10  神器遗迹
11  奇珍轩-英雄
12	奇珍轩-装备
13	竞技场
14  玩法说明
15  种族调整队伍
16  魔攻
17  奇珍轩-装备
18  帮派战
19  年兽
20  排行榜奖励
]]



local WanFaShuoMingLayer=class("WanFaShuoMingLayer",function ()
	   return XTHDPopLayer:create()
end)          
function WanFaShuoMingLayer:ctor(data,isRemoveLayout)
    self._type = data.type
	local type=1
	if data.type then
		type=data.type
	end

    self._isRemoveLayout = isRemoveLayout or false
    self.closeCallback = function()
        self:removeFromParent()
    end
    if isRemoveLayout~=nil and isRemoveLayout == true then
        self.closeCallback = function()
            LayerManager.removeLayout()
        end
    end
	local source_tab={}
	for i=0,22 do
		if i==0 then
			source_tab[#source_tab+1]= LANGUAGE_KEY_HERO_TEXT.detailIntroduceTitle -------"属性说明"
		else
			source_tab[#source_tab+1]=LANGUAGE_KEY_DETAILINFONAME(tostring(XTHD.resource.AttributesNum[i])) .. ":"..LANGUAGE_KEY_DETAILINTRODUCE(tostring(XTHD.resource.AttributesNum[i]))
		end
	end
    LANGUAGE_GAME_DIRECTION[14] = source_tab
	self:initUI(LANGUAGE_GAME_DIRECTION[type])
end
function WanFaShuoMingLayer:initUI(tab)
    local _popBgSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png" )
    _popBgSprite:setContentSize(639,387)
    _popBgSprite:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
    self:addContent(_popBgSprite)
     --关闭按钮
    local close_btn = XTHD.createBtnClose(function()
        self:closeCallback()
    end)
    close_btn:setPosition(_popBgSprite:getContentSize().width - 10, _popBgSprite:getContentSize().height - 10)
    _popBgSprite:addChild(close_btn)
    local title_bg= BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 60))
    title_bg:setAnchorPoint(0.5,1)
    title_bg:setPosition(_popBgSprite:getContentSize().width/2,_popBgSprite:getContentSize().height + title_bg:getContentSize().height / 2 - 10)
    _popBgSprite:addChild(title_bg)
    local title_label=XTHDLabel:createWithParams({text=LANGUAGE_KEY_HERO_TEXT.playDetail,ttf="",size=28}) --------"玩法说明"
    title_label:setColor(cc.c3b(104, 33, 11))
    title_label:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height / 2)
    title_bg:addChild(title_label)
    --阴影底部
    
    local shadow_bg=ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    shadow_bg:setContentSize(cc.size(_popBgSprite:getContentSize().width-40,_popBgSprite:getContentSize().height-80))
    shadow_bg:setAnchorPoint(0.5,0)
    shadow_bg:setPosition(_popBgSprite:getContentSize().width/2,40)
    _popBgSprite:addChild(shadow_bg)
     local height=shadow_bg:getContentSize().height - 10
    local scrollView = ccui.ScrollView:create()
	scrollView:setScrollBarEnabled(false)
    scrollView:setAnchorPoint(0, 0)
    scrollView:setTouchEnabled(true)
    scrollView:setBounceEnabled(true)
    scrollView:setContentSize(cc.size(shadow_bg:getContentSize().width,height))
    scrollView:setPosition(cc.p(10,5))
    scrollView:setName("scrollView")
    shadow_bg:addChild(scrollView, 2)
    if #tab >10 then
        height=(height/6)*(tonumber(#tab)+1)
        -- print("********:" .. height)
        scrollView:setInnerContainerSize(cc.size(shadow_bg:getContentSize().width,height))
    end
    --蓝色31	210	255
    --     --提示文字
    local name = XTHDLabel:createWithParams({
        text = tab[1],
        fontSize = 18,
        color = cc.c3b(14, 117, 175),
    })
    name:setAnchorPoint(0,1)
    name:setPosition(30,height-10)
    scrollView:addChild(name)
    local namedian = cc.Sprite:create("res/image/common/playway_dian.png")
    namedian:setAnchorPoint(1,0.5)
    namedian:setPosition(25,height-10-11)
    scrollView:addChild(namedian)
    local y = name:getPositionY() - name:getBoundingBox().height - 5
    for i = 2,#tab do
        local announcement = XTHDLabel:createWithSystemFont(tab[i],XTHD.SystemFont,16)
        announcement:setColor(cc.c3b(71,37,30))
        announcement:setWidth(scrollView:getContentSize().width - 18)
	    announcement:setAnchorPoint(0,0)
	    announcement:setPosition(5,y - announcement:getBoundingBox().height)
        -- if self._type == 19 and i == #tab then -------年兽的说明
        --     announcement:setColor(cc.c3b(0xff,0,0))
        -- end 
	    scrollView:addChild(announcement)
        y = y - announcement:getBoundingBox().height - 5
	end

end
function WanFaShuoMingLayer:create(data,isRemoveLayout)
	local PopLayer=self.new(data,isRemoveLayout)
    PopLayer:show()
	return PopLayer
end
return WanFaShuoMingLayer

