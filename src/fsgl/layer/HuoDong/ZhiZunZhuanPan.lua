--2019/06/11
--至尊转盘界面
local ZhiZunZhuanPan = class("ZhiZunZhuanPan", function(params)
    return XTHD.createFunctionLayer(cc.size(839, 420))
end)

function ZhiZunZhuanPan:ctor(params)
    self:setOpacity(0)
    self.parentlayer = params.parentLayer or nil
    local _data = params.httpData or {}
    self.itemStaticData = {}
    self.turnTableStaticData = {}
    self.turnTableData = {}

    self.costLuckyNum = nil
    
    -- self:setItemStaticData()
    self:setStaticData()
    self:setTurnTableData(_data)
    self:initLayer()
end

function ZhiZunZhuanPan:onCleanup()
    local textureCache = cc.Director:getInstance():getTextureCache()
    -- textureCache:removeTextureForKey("res/image/activities/levelreward/levelreward_advertsp.png")
    -- textureCache:removeTextureForKey("res/image/activities/levelreward/levelreward_titlesp.png")
end

function ZhiZunZhuanPan:initLayer()
    local _upHeight = 5

    -- local _actBg = cc.Sprite:create("res/image/activities/luckyturn/lucky_bg.png")
    -- _actBg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
    -- self:addChild(_actBg)
    --左边背景
    local left_bg = ccui.Scale9Sprite:create("res/image/activities/luckyturn/lucky_bg1.png")
    left_bg:setAnchorPoint(0, 0.5)
    left_bg:setContentSize(457,485)
    left_bg:setPosition(-36,self:getContentSize().height/2 - 18)
    self:addChild(left_bg)

    --右边背景
    local right_bg = ccui.Scale9Sprite:create("res/image/activities/luckyturn/lucky_bg2.png")
    right_bg:setAnchorPoint(1,0.5)
    right_bg:setContentSize(457, 488)
    right_bg:setPosition(self:getContentSize().width + 35,self:getContentSize().height/2 - 19)
    self:addChild(right_bg)

    -- local _lineVerticalSp = cc.Sprite:create("res/image/activities/luckyturn/lucky_line.png")
    -- _lineVerticalSp:setAnchorPoint(cc.p(0,0.5))
    -- _lineVerticalSp:setPosition(cc.p(407,self:getContentSize().height/2))
    -- self:addChild(_lineVerticalSp)
    
    --advert picture
    local _leftContentSize = cc.size(435,self:getContentSize().height-5)
    local _leftBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,397,441))
    _leftBg:setOpacity(0)
    -- XTHD.getScaleNode("res/image/activities/luckyturn/lucky_leftBg.png",_leftContentSize)
    self.leftBg = _leftBg
    _leftBg:setAnchorPoint(cc.p(0,0))
    _leftBg:setPosition(cc.p(2,3))
    self:addChild(_leftBg)

    

    local _linePosY = 110
    -- local _lineSp = ccui.Scale9Sprite:create(cc.rect(130,0,140,4),"res/image/common/common_split_line.png")
    -- _lineSp:setContentSize(cc.size(400,2))
    -- _lineSp:setPosition(cc.p(_leftBg:getContentSize().width/2,_linePosY))
    -- _leftBg:addChild(_lineSp)

    -- 幸运等级
    local _introduceLabel3 = XTHDLabel:create(LANGUAGE_KEY_LUCKYTURN.desc[2],20)
    _introduceLabel3:setColor(cc.c3b(246, 252, 210))
    _introduceLabel3:setAnchorPoint(cc.p(0,0.5))
    _introduceLabel3:enableShadow(cc.c4b(64,51,70,255),cc.size(0.4,-0.4),0.4)
    _introduceLabel3:setPosition(cc.p(5,20))
    _leftBg:addChild(_introduceLabel3)

    -- 幸运描述
    local _introduceLabel2 = XTHDLabel:create(LANGUAGE_KEY_LUCKYTURN.desc[1],20)
    _introduceLabel2:setColor(cc.c3b(246, 252, 210))
    _introduceLabel2:setAnchorPoint(cc.p(0,0.5))
    _introduceLabel2:enableShadow(cc.c4b(64,51,70,255),cc.size(0.4,-0.4),0.4)
    _introduceLabel2:setPosition(cc.p(5,_introduceLabel3:getPositionY() +28))
    _leftBg:addChild(_introduceLabel2)

    local _vipLevel = math.abs((gameUser.getVip()-1)/4)
    local _luckyLevel = math.floor(_vipLevel)+1
    if _luckyLevel >4 then
        _luckyLevel = 4
    elseif _luckyLevel <1 then
        _luckyLevel = 1
    end

    local _introduceLabel1 = XTHDLabel:create(LANGUAGE_KEY_LUCKYTURN.level .. "lv" .. _luckyLevel,20)
    _introduceLabel1:setColor(cc.c3b(243,220,0))
    _introduceLabel1:setAnchorPoint(cc.p(0,0.5))
    _introduceLabel1:enableShadow(cc.c4b(243,220,0,255),cc.size(0.4,-0.4),0.4)
    _introduceLabel1:setPosition(cc.p(5,_introduceLabel2:getPositionY()+28))
    _leftBg:addChild(_introduceLabel1)

    --Button
    local _btnPosy = _linePosY + 28
    -- local _refreshBtn = XTHD.createButton({
    --         normalFile = "res/image/common/btn/btn_write_up.png",      --"res/image/common/btn/btn_write_1_up.png"
    --         selectedFile = "res/image/common/btn/btn_write_down.png",
    --         btnSize = cc.size(130,46),
    --     })
    -- _refreshBtn:setAnchorPoint(cc.p(1,0.5))
    -- _refreshBtn:setScale(0.8)
    -- _refreshBtn:setPosition(cc.p(_leftBg:getContentSize().width/2 - 15,_btnPosy))
    -- _leftBg:addChild(_refreshBtn)
    -- self.refreshBtn = _refreshBtn
    -- _refreshBtn:setTouchEndedCallback(function()
    --         self:refreshBtnCallback()
    --     end)
    -- self:setRefreshBtnLabel()
    local _rewardBtn = XTHD.createCommonButton({
            btnColor = "write",
            isScrollView = false,
            btnSize = cc.size(130,46),
            text = LANGUAGE_KEY_SPACEFETCH,
            fontSize = 26,
        })
    _rewardBtn:setAnchorPoint(cc.p(0,0.5))
    _rewardBtn:setPosition(cc.p(_leftBg:getContentSize().width/2 -75,_leftBg:getContentSize().height/2-90))
    _rewardBtn:setScale(0.8)
    _leftBg:addChild(_rewardBtn)
    _rewardBtn:setTouchEndedCallback(function()
            self:getRewardBtnCallback()
        end)
    --rewarditems
    self.rewardItemsTable = {}
    self:setRewardItemsPart()


    --right
    local _midPosX = _leftBg:getContentSize().width +_leftBg:getBoundingBox().x

    local _rightMidPosX = (self:getContentSize().width + _midPosX)/2 + 25
    local _rightBg = cc.Sprite:create("res/image/activities/luckyturn/lucky_turnTable.png")
    _rightBg:setScale(0.8)
    self.rightBg = _rightBg
    _rightBg:setPosition(cc.p(_rightMidPosX,self:getContentSize().height/2 - 5))
    self:addChild(_rightBg)
    self:setRightPart()

    --幸运币
    local _textColor = cc.c4b(243,220,0,255)
    local _turnUpPosY = self:getContentSize().height - 21 - 10
    local _luckyTitle = XTHDLabel:create(LANGUAGE_KEY_LUCKYTURN.myLucky .. ":",20)
    _luckyTitle:setColor(_textColor)
    _luckyTitle:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
    _luckyTitle:setAnchorPoint(cc.p(1,0.5))
    _luckyTitle:setPosition(cc.p(_rightMidPosX,_turnUpPosY))
    self:addChild(_luckyTitle)
    local _luckSp = cc.Sprite:create("res/image/common/header_luck.png")
    _luckSp:setAnchorPoint(cc.p(0,0.5))
    _luckSp:setPosition(cc.p(_luckyTitle:getBoundingBox().x+_luckyTitle:getBoundingBox().width+3,_turnUpPosY))
    self:addChild(_luckSp)
    local _luckLabel = XTHDLabel:create(0,20)
    self.luckNumLabel = _luckLabel
    _luckLabel:setColor(_textColor)
    _luckLabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
    _luckLabel:setAnchorPoint(cc.p(0,0.5))
    _luckLabel:setPosition(cc.p(_luckSp:getBoundingBox().x+_luckSp:getBoundingBox().width+3,_turnUpPosY))
    self:addChild(_luckLabel)
    self:setLuckNumberLabel()
    --中星率
    local _starProbabilityStr = LANGUAGE_KEY_LUCKYTURN.starChance
    local _probabilityTitle = XTHDLabel:create(_starProbabilityStr,20)
    _probabilityTitle:setColor(_textColor)
    _probabilityTitle:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
    _probabilityTitle:setAnchorPoint(cc.p(1,0.5))
    _probabilityTitle:setPosition(cc.p(_rightMidPosX+10,0))
    self:addChild(_probabilityTitle)
    local _probabilityLabel = XTHDLabel:create(0 .. "%",20)
    _probabilityLabel:setColor(_textColor)
    _probabilityLabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
    self.probabilityLabel = _probabilityLabel
    _probabilityLabel:setAnchorPoint(cc.p(0,0.5))
    _probabilityLabel:setPosition(cc.p(_probabilityTitle:getBoundingBox().x+_probabilityTitle:getBoundingBox().width,0))
    self:addChild(_probabilityLabel)
    self:setProbabilityLabel()

    --兑换
    local _exchangeBtn = XTHD.createButton({
            normalFile = "res/image/homecity/menu_charge1.png",
            selectedFile = "res/image/homecity/menu_charge2.png",
        })
    _exchangeBtn:setAnchorPoint(cc.p(1,1))
    _exchangeBtn:setPosition(cc.p(self:getContentSize().width + 5,self:getContentSize().height - 12))
    self:addChild(_exchangeBtn)
    _exchangeBtn:setTouchEndedCallback(function()
            self:exchangeBtnCallback()
        end)

    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK,node=self,callback = function( event)
        self.turnTableData.luckMoney = gameUser.getLuckyMoney()
        self:setLuckNumberLabel()
    end})
end

function ZhiZunZhuanPan:setRightPart()
    if self.rightBg ==nil then
        return
    end
    local _turnStarPosTable = {
        cc.p(0,108),cc.p(76,78),cc.p(98.5,0),cc.p(86,-76),
        cc.p(0.5,-108),cc.p(-75,-74),cc.p(-101,3),cc.p(-76,79),
    }
    self.turnStarPosTable = _turnStarPosTable

    --arrow
    -- local _turnArrow = cc.Sprite:create("res/image/activities/luckyturn/lucky_arrow.png")
    -- self.turnArrow = _turnArrow
    -- _turnArrow:setAnchorPoint(cc.p(0.5,0.3))
    -- _turnArrow:setPosition(cc.p(self.rightBg:getContentSize().width/2,self.rightBg:getContentSize().height/2))
    -- self.rightBg:addChild(_turnArrow)


    
    local _btnPos = cc.p(self.rightBg:getContentSize().width/2+1,self.rightBg:getContentSize().height/2+10)
    local _turnBtn = XTHD.createButton({
            normalFile = "res/image/activities/luckyturn/lucky_arrow.png",
            selectedFile = "res/image/activities/luckyturn/lucky_arrow_up.png",
        })
    self.turnBtn = _turnBtn
    _turnBtn:setPosition(_btnPos)
    self.rightBg:addChild(_turnBtn)
    self.turnArrow = _turnBtn


    _turnBtn:setTouchEndedCallback(function()
            if tonumber(self.turnTableData.turnCost)>tonumber(gameUser.getLuckyMoney()) then
                local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=6})
                self.parentlayer:addChild(StoredValue)
                return    
            end
            self:turnBtnCallback()
        end)
    -- dump(self.rightBg:convertToWorldSpace(cc.p(0.5,0.5)))
    local _turnWorldPos = _turnBtn:convertToWorldSpace(cc.p(0.5,0.5))
    -- dump(_turnWorldPos)
    local _midPointPos = cc.p(self.rightBg:getPositionX()+1,self.rightBg:getPositionY()+2)
    self.midPointPos = _midPointPos
    -- dump(_midPointPos)

    local _luckySp = cc.Sprite:create("res/image/common/header_luck.png")
    _luckySp:setAnchorPoint(cc.p(1,0.5))
    _luckySp:setPosition(cc.p((self:getContentSize().width + self.leftBg:getContentSize().width +self.leftBg:getBoundingBox().x)/2+30,25))
    self:addChild(_luckySp)
    local _luckyNumLabel = XTHDLabel:create(self.turnTableData.turnCost or 0,18)
    self.costLuckyNum = _luckyNumLabel
    _luckyNumLabel:setAnchorPoint(cc.p(0,0.5))
    
    _luckyNumLabel:setColor(cc.c4b(122,64,35))
    _luckyNumLabel:setPosition(cc.p((self:getContentSize().width + self.leftBg:getContentSize().width +self.leftBg:getBoundingBox().x)/2+30,25))
    self:addChild(_luckyNumLabel)

    self:refreshCostLuckyNum()

    self.starSpList = {}
    for i=1,8 do
        self.starSpList[i] = nil
        local _starState = self.turnTableData.starList and self.turnTableData.starList[i] or 0
        if tonumber(_starState)==1 then
            local _starSp = cc.Sprite:create("res/image/activities/luckyturn/lucky_star.png")
            _starSp:setPosition(cc.p(_turnStarPosTable[i].x+_midPointPos.x,_turnStarPosTable[i].y+_midPointPos.y))
            _starSp:setScale(0.6)
            self:addChild(_starSp)
            self.starSpList[i] = _starSp
        end
    end

end

function ZhiZunZhuanPan:setRefreshBtnLabel()
    if self.refreshBtn == nil then
        return
    end
    local _refreshBtn = self.refreshBtn
    if _refreshBtn:getChildByName("btnLabel")~=nil then
        _refreshBtn:removeChildByName("btnLabel")
    end
    if _refreshBtn:getChildByName("otherSp")~=nil then
        _refreshBtn:removeChildByName("otherSp")
    end
    local _refreshlabel = XTHDLabel:create(LANGUAGE_BTN_KEY.shuaxin,26,"res/fonts/def.ttf")
    _refreshlabel:setName("btnLabel")
    -- _refreshlabel:enableShadow(XTHD.resource.btntextcolor.red,cc.size(0.4,-0.4),0.4)
    _refreshlabel:setColor(cc.c3b(255,255,255))
    _refreshlabel:enableOutline(cc.c4b(106,36,13,255),2)
    _refreshlabel:setPosition(cc.p(_refreshBtn:getContentSize().width/2,_refreshBtn:getContentSize().height/2 + 5))
    _refreshBtn:addChild(_refreshlabel)
    local _surplusCount = self.turnTableData.surplusCount or 0
    local _contentOffset =0
    local _otherSp = nil
    if tonumber(_surplusCount) >0 then
        _otherSp = XTHDLabel:create(_surplusCount .. "/3",26,"res/fonts/def.ttf")
        _otherSp:setColor(cc.c3b(255,255,255))
        _otherSp:setAnchorPoint(cc.p(0,0.5))
        _otherSp:enableOutline(cc.c4b(106,36,13,255),2)
        _otherSp:setPosition(cc.p(0,_refreshBtn:getContentSize().height/2+5 ))
        _refreshBtn:addChild(_otherSp)

        _contentOffset = _otherSp:getContentSize().width
    else
        _otherSp = cc.Sprite:create("res/image/common/header_luck.png")

        _otherSp:setAnchorPoint(cc.p(0,0.5))

        local _ingotNumLabel = XTHDLabel:create(self.turnTableData.refreshCost or 0,20)
        _ingotNumLabel:setColor(cc.c3b(255,255,255))
        _ingotNumLabel:enableOutline(cc.c4b(106,36,13,255),2)
        _ingotNumLabel:setAnchorPoint(cc.p(0,0.5))

        _contentOffset = _otherSp:getBoundingBox().width + _ingotNumLabel:getBoundingBox().width

        _otherSp:setPosition(cc.p(0 ,_refreshBtn:getContentSize().height/2 + 5))
        _ingotNumLabel:setPosition(cc.p(_otherSp:getBoundingBox().width ,_otherSp:getContentSize().height/2 + 5))

        _refreshBtn:addChild(_otherSp)
        _otherSp:addChild(_ingotNumLabel)
    end
    _otherSp:setName("otherSp")
    _refreshlabel:setPositionX(_refreshBtn:getContentSize().width/2-_contentOffset/2)
    _refreshlabel:setPositionY( _refreshlabel:getPositionY()-5)
    _otherSp:setPosition(cc.p(_refreshlabel:getBoundingBox().x+_refreshlabel:getBoundingBox().width+5 ,_refreshBtn:getContentSize().height/2))
end

function ZhiZunZhuanPan:setRewardItemsPart()
    local _leftBg = self.leftBg
    local _rewardItemPosTable = SortPos:sortFromMiddle(cc.p(_leftBg:getContentSize().width/2,_leftBg:getContentSize().height - 20-60) ,4,80+19)
    for i=1,8 do
        if self.rewardItemsTable[i]~=nil then
            self.rewardItemsTable[i]:removeFromParent()
            self.rewardItemsTable[i] = nil
        end
        local _rewardItemData = self.turnTableData.rewardList and self.turnTableData.rewardList[i] or {}
        local _rewardItem = ItemNode:createWithParams({
                itemId = _rewardItemData.rewardId or 0,
                _type_ = _rewardItemData.rewardType or 1,
                touchShowTip = true,
                count = _rewardItemData.rewardCount or 0,
                isShowCount = true
            })
            _rewardItem:setScale(0.8)
        local _posIndex = (i-1)%4+1
        local _itemPosY = _rewardItemPosTable[_posIndex].y - (math.ceil(i/4)-1)*(80+35)
        _rewardItem:setPosition(cc.p(_rewardItemPosTable[_posIndex].x - 10,_itemPosY))
        _leftBg:addChild(_rewardItem)

        -- local _rewardStaticData = self.itemStaticData[tostring(_rewardItemData.rewardId)]
        local _namestr = _rewardItem._Name or ""
        -- _rewardStaticData and _rewardStaticData.name or ""
        local _nameLabel = XTHDLabel:create(_namestr,17)
        _nameLabel:setColor(cc.c3b(246, 252, 210))
        _nameLabel:setAnchorPoint(cc.p(0.5,0.5))
        _nameLabel:setPosition(cc.p(_rewardItem:getContentSize().width/2,-15))
        _rewardItem:addChild(_nameLabel)

        local _rare = _rewardItemData.rare or 0
        if _rare == 1 then
            local xingxing_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/teshu.json", "res/spine/effect/exchange_effect/teshu.atlas",1 )
            xingxing_effect:setPosition(cc.p(_rewardItem:getContentSize().width/2,_rewardItem:getContentSize().height/2))
            xingxing_effect:setAnimation(0,"animation",true)
            _rewardItem:addChild(xingxing_effect)
        end

        if (self.turnTableData.luckyStar or 0)<i then
            local _coverSp = cc.Sprite:create("res/image/activities/luckyturn/lucky_rewardBg.png")
            _coverSp:setName("coverSp")
            _coverSp:setPosition(cc.p(_rewardItem:getContentSize().width/2,_rewardItem:getContentSize().height/2))
            _rewardItem:addChild(_coverSp)
            _coverSp:setCascadeOpacityEnabled(true)
            
            local _needText = cc.Sprite:create("res/image/activities/luckyturn/lucky_need.png")
            _needText:setAnchorPoint(cc.p(0.5,0.5))
            _needText:setPosition(cc.p(_coverSp:getContentSize().width/2,_coverSp:getContentSize().height/2 + 13))
            _coverSp:addChild(_needText)
            local _indexLabel = getCommonWhiteBMFontLabel(i)
            _indexLabel:setAnchorPoint(cc.p(0,0.5))
            _indexLabel:setPosition(cc.p(_needText:getBoundingBox().x+3,_coverSp:getContentSize().height/2-17))
            _coverSp:addChild(_indexLabel)
            local _starSp = cc.Sprite:create("res/image/activities/luckyturn/lucky_star.png")
            _starSp:setName("starSp")
            _starSp:setScale(0.6)
            _starSp:setAnchorPoint(cc.p(0,0.5))
            _starSp:setPosition(cc.p(_coverSp:getContentSize().width/2-3,_coverSp:getContentSize().height/2-10))
            _coverSp:addChild(_starSp)
        end
        self.rewardItemsTable[i] = _rewardItem
    end
end

function ZhiZunZhuanPan:refreshStarState()
    for i=1,8 do
        if self.starSpList[i]~=nil then
            self.starSpList[i]:removeFromParent()
        end
        self.starSpList[i] = nil
        local _starState = self.turnTableData.starList and self.turnTableData.starList[i] or 0
        if tonumber(_starState)==1 then
            local _starSp = cc.Sprite:create("res/image/activities/luckyturn/lucky_star.png")
            _starSp:setPosition(cc.p(self.turnStarPosTable[i].x + self.midPointPos.x,self.turnStarPosTable[i].y+self.midPointPos.y))
            _starSp:setScale(0.6)
            self:addChild(_starSp)
            self.starSpList[i] = _starSp
        end
    end
end

function ZhiZunZhuanPan:getStarAnimation(_idx)
    if _idx==nil or self.starSpList[_idx]==nil or self.rewardItemsTable[_idx]==nil then
        self.turnBtn:setClickable(true)
        return
    end
    local _starTarget = self.starSpList[_idx]

    
    local _rewardItem = self.rewardItemsTable[tonumber(self.turnTableData.luckyStar)]
    -- if _rewardItem==nil then
    --     return
    -- end
    local _worldpos = _rewardItem:convertToWorldSpace(cc.p(0.5,0.5))

    local _starSpine = sp.SkeletonAnimation:create("res/spine/effect/luckturn/xzk.json", "res/spine/effect/luckturn/xzk.atlas", 1)
    _starSpine:setName("starSpine")
    _starSpine:setAnimation(0,"atk1",false)
    _starSpine:setPosition(cc.p(_starTarget:getContentSize().width/2,_starTarget:getContentSize().height/2))
    _starTarget:addChild(_starSpine)
    
    local _pos = self:convertToNodeSpace(_worldpos)
    local _purposePos = cc.p(_pos.x + _rewardItem:getContentSize().width/2,_pos.y+_rewardItem:getContentSize().height/2)
    local _posDistance = cc.pGetDistance(_purposePos, cc.p(_starTarget:getPositionX(),_starTarget:getPositionY()))
    local _moveTime = 1/600*_posDistance
    _starTarget:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function()
            if _starTarget:getChildByName("starSpine") then
                _starTarget:removeChildByName("starSpine")
            end
            local emitter = cc.ParticleSystemQuad:create("res/spine/effect/luckturn/xgc.plist") 
            emitter:setAutoRemoveOnFinish(false)
            emitter:setPosition(_starTarget:getContentSize().width/2,_starTarget:getContentSize().height/2)
            _starTarget:addChild(emitter)
        end)
    ,cc.MoveTo:create(_moveTime,_purposePos),cc.CallFunc:create(function()
                _starTarget:setPosition( cc.p(-300,500))
                local _coverSp = _rewardItem:getChildByName("coverSp")
                if _coverSp~=nil and _coverSp:getChildByName("starSp") then
                    local _starCoverSp = _coverSp:getChildByName("starSp")
                    local _starSpine = sp.SkeletonAnimation:create("res/spine/effect/luckturn/xzk.json", "res/spine/effect/luckturn/xzk.atlas", 1)
                    _starSpine:setScale(1.3)
                    _starSpine:setAnimation(0,"atk2",false)
                    _starSpine:setPosition(cc.p(_starCoverSp:getContentSize().width/2,_starCoverSp:getContentSize().height/2))
                    _starCoverSp:addChild(_starSpine)
                    _starCoverSp:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                            self:refreshRewardItemState()
                        end),cc.DelayTime:create(0.8),cc.CallFunc:create(function()
                            self.turnBtn:setClickable(true)
                            self.starSpList[_idx] = nil
                            _starTarget:removeAllChildren()
                            _starTarget:removeFromParent()
                        end)))
                else
                    self:refreshRewardItemState()
                    self.starSpList[_idx] = nil
                    _starTarget:removeAllChildren()
                    _starTarget:removeFromParent()
                    self.turnBtn:setClickable(true)
                end
            end)))
end

function ZhiZunZhuanPan:refreshRewardItemState()
    for i=1,self.turnTableData.luckyStar do
        if self.rewardItemsTable[i]:getChildByName("coverSp") then
            local _coverSp = self.rewardItemsTable[i]:getChildByName("coverSp")
            _coverSp:runAction(cc.Sequence:create(cc.FadeOut:create(1),cc.CallFunc:create(function()
                    _coverSp:removeAllChildren()
                    _coverSp:removeFromParent()
                end)))
        end
    end
end

function ZhiZunZhuanPan:refreshCostLuckyNum()
    self.costLuckyNum:setString(self.turnTableData.turnCost or 0)
end

function ZhiZunZhuanPan:setLuckNumberLabel()
    if self.luckNumLabel ==nil then
        return
    end
    self.luckNumLabel:setString(self.turnTableData.luckMoney or 0)
end

function ZhiZunZhuanPan:setProbabilityLabel()
    if self.probabilityLabel ==nil then
        return
    end
    local _probilityValue = 100                -----------------------------100-tonumber(self.turnTableData.luckyStar)/8*100 ---------------------中星率100%
    self.probabilityLabel:setString(_probilityValue .. "%")
end

function ZhiZunZhuanPan:turnBtnCallback()
    local _actionrate = 1
    local _turnAnimation1 = cc.Spawn:create(cc.EaseIn:create(cc.RotateBy:create(2,360*3),1.5),
        cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                _actionrate = _actionrate + 0.1
            end)),4))
    local _turnAnimation2 = cc.RepeatForever:create(cc.RotateBy:create(4,360*9))
    
    self.turnArrow:runAction(cc.Sequence:create(_turnAnimation1,_turnAnimation2))

    local _failureFunc = function()
        self.turnBtn:setClickable(true)
        self.turnArrow:stopAllActions()
        local _turnRotateFail = 360-self.turnArrow:getRotation()
        local _turnTimeFail = 2/360/3*_turnRotateFail
        local _turnAnimationFail = cc.EaseOut:create(cc.RotateTo:create(_turnTimeFail,360),_actionrate)
        self.turnArrow:runAction(cc.Sequence:create( _turnAnimationFail))
    end
    self.turnBtn:setClickable(false)
    ClientHttp:requestAsyncInGameWithParams({
        modules = "yaoTurnTable?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                data.curIndex = data.curIndex +1
                self.turnTableData.starList[tonumber(data.curIndex)] = 0
                self:refreshTurnTableData(data)
                self:refreshCostLuckyNum()
                self:setLuckNumberLabel()
                
                self.turnArrow:stopAllActions()
                local _turnRotate1 = 360-self.turnArrow:getRotation() + 45*(tonumber(data.curIndex)-1)
                if _turnRotate1<180 then
                    _turnRotate1 = _turnRotate1 + 360
                end
                local _turnTime1 = 2/360/3*_turnRotate1
                local _turnAnimation1 = cc.RotateBy:create(_turnTime1,_turnRotate1)
                -- local _turnRotate2 = 45*(tonumber(data.curIndex)-1)
                -- local _turnTime2 = 2/360/3*_turnRotate2
                -- local _turnAnimation2 = cc.EaseOut:create(cc.RotateTo:create(_turnTime2,_turnRotate2),_actionrate)
                self.turnArrow:runAction(cc.Sequence:create(_turnAnimation1,cc.CallFunc:create(function()
                    end),cc.CallFunc:create(function()
                        self:setProbabilityLabel()
                        self.turnArrow:setRotation(45*(tonumber(data.curIndex)-1))
                        self:getStarAnimation(data.curIndex)
                    end)))
            else
                XTHDTOAST(data.msg)
                _failureFunc()
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST("网络请求失败")
            _failureFunc()
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZhiZunZhuanPan:refreshBtnCallback()
    if tonumber(self.turnTableData.luckyStar)>0 then
        XTHDTOAST(LANGUAGE_KEY_LUCKYTURN.getStarToast)
        return
    end
    ClientHttp:httpCommon("refreshTurnTable?",self,{},function(data)
            self:refreshTurnTableData(data)
            self:setRewardItemsPart()
            self:setRefreshBtnLabel()
            self:refreshCostLuckyNum()
            self:setLuckNumberLabel()
            self:setProbabilityLabel()
        end)
end

function ZhiZunZhuanPan:getRewardBtnCallback()
    if self.turnTableData.luckyStar < 8 and self.turnTableData.luckyStar > 0 then
         local confirmLayer = XTHDConfirmDialog:createWithParams({
             rightCallback=function()
                ClientHttp:httpCommon("turnTableReward?",self,{},function(data)
                    self:setShowReward(self.turnTableData.rewardList,self.turnTableData.luckyStar)
                    self:reFreshHttpData(data)
                    self.turnArrow:stopAllActions()
                    self.turnBtn:setClickable(true)
                    self.turnArrow:setRotation(0)
                    self.turnTableData.starList = {1,1,1,1,1,1,1,1}
                    self:refreshTurnTableData(data)
                    self:refreshStarState()
                    self:setRewardItemsPart()
                    self:setRefreshBtnLabel()
                    self:refreshCostLuckyNum()
                    self:setLuckNumberLabel()
                    self:setProbabilityLabel()
                end)
            end,                 
            msg = "未达到8星，确定领取吗?"
        })
		cc.Director:getInstance():getRunningScene():addChild(confirmLayer)
        --self:addChild(confirmLayer) 
    else
         ClientHttp:httpCommon("turnTableReward?",self,{},function(data)
            self:setShowReward(self.turnTableData.rewardList,self.turnTableData.luckyStar)
            self:reFreshHttpData(data)
            self.turnArrow:stopAllActions()
            self.turnBtn:setClickable(true)
            self.turnArrow:setRotation(0)
            self.turnTableData.starList = {1,1,1,1,1,1,1,1}
            self:refreshTurnTableData(data)
            self:refreshStarState()
            self:setRewardItemsPart()
            self:setRefreshBtnLabel()
            self:refreshCostLuckyNum()
            self:setLuckNumberLabel()
            self:setProbabilityLabel()
        end)
    end

end

function ZhiZunZhuanPan:exchangeBtnCallback()
    XTHD.createRechargeVipLayer(self.parentlayer)
end

function ZhiZunZhuanPan:setShowReward(data,num)
    if data == nil or next(data) == nil then
        return
    end
    local _rewardTable = {}
    for i=1,num do
        _rewardTable[i] = {}
        _rewardTable[i].rewardtype = data[i].rewardType
        _rewardTable[i].id = data[i].rewardId
        _rewardTable[i].num = data[i].rewardCount
    end
    ShowRewardNode:create(_rewardTable)
end

function ZhiZunZhuanPan:reFreshHttpData(data)
    if data == nil or next(data)==nil then
        return
    end
    for i=1,#data["property"] do
        local pro_data = string.split( data["property"][i],',')
        gameUser.updateDataById(pro_data[1],pro_data[2])
    end

    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    local _rewarddbid = nil
    for i=1,#data["bagItems"] do
        local _dbid = data.bagItems[i].dbId
        if data.bagItems[i].count and tonumber(data.bagItems[i].count)>0 then
            DBTableItem.updateCount(gameUser.getUserId(),data.bagItems[i],_dbid)
        else
            DBTableItem.deleteData(gameUser.getUserId(),_dbid)
        end
    end
end

function ZhiZunZhuanPan:refreshTurnTableData(data)
    -- print("精彩活动至尊转盘数据为：")
    -- print_r(data)
    if data.rewardList ~=nil then
        self.turnTableData.rewardList = data.rewardList    
        table.sort(self.turnTableData.rewardList,function(data1,data2)
                return tonumber(data1.groupId)<tonumber(data2.groupId)
            end)
    end
    if data.turnCost~=nil then
        self.turnTableData.turnCost = data.turnCost    
    end
    if data.surplusCount~=nil then
        self.turnTableData.surplusCount = data.surplusCount    
    end
    if data.luckMoney~=nil then
        self.turnTableData.luckMoney = data.luckMoney    
        gameUser.setLuckyMoney(data.luckMoney)
    end
    self:getTurnStarNum()
end

function ZhiZunZhuanPan:getTurnStarNum()
    -- dump(self.turnTableData)
    local _starList = self.turnTableData.starList or {}
    local _starNum = 0
    for i=1,#_starList do
        if tonumber(_starList[i]) == 0 then
            _starNum = _starNum + 1
        end
    end
    self.turnTableData.luckyStar = _starNum
end

function ZhiZunZhuanPan:setTurnTableData(data)
    self.turnTableData = {}
    if data==nil or next(data)==nil then
        return
    end
    self.turnTableData = data
    self:getTurnStarNum()
    self.turnTableData.luckMoney = gameUser.getLuckyMoney()
    table.sort(self.turnTableData.rewardList,function(data1,data2)
            return tonumber(data1.groupId)<tonumber(data2.groupId)
        end)
end

function ZhiZunZhuanPan:setItemStaticData()
    self.itemStaticData = {}
    -- self.itemStaticData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
end

function ZhiZunZhuanPan:setStaticData()
    self.turnTableStaticData = {}
    self.turnTableStaticData = gameData.getDataFromCSV("ExtremeRoulette")
end

function ZhiZunZhuanPan:create(params)
    return self.new(params)
end

return ZhiZunZhuanPan