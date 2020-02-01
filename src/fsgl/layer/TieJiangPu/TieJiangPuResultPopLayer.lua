local TieJiangPuResultPopLayer = class("TieJiangPuResultPopLayer",function()
		return XTHDPopLayer:create()
	end)
function TieJiangPuResultPopLayer:ctor(_lightArr)
	self._fontSize = 18
	self.resultData = {}
    self.staticItemData = {}

    self.popNode = nil

    if _lightArr~=nil and tonumber(#_lightArr)>0 then
        self:initComposeAnimateLayer(_lightArr)
    end
    
end

function TieJiangPuResultPopLayer:initComposeAnimateLayer(_lightArr)
    self:show(false)
    local _containerLayer= self:getContainerLayer()
    _containerLayer:setClickable(false)
    local _composeAni_sp = sp.SkeletonAnimation:create("res/spine/effect/compose_effect/ronglianlu.json", "res/spine/effect/compose_effect/ronglianlu.atlas",1.0)
    _composeAni_sp:setName("composeAni_sp")
    _composeAni_sp:setAnimation(0,"atk",false)
    -- 
    _composeAni_sp:setPosition(cc.p(_containerLayer:getContentSize().width/2,_containerLayer:getContentSize().height/2))
    _containerLayer:addChild(_composeAni_sp)
	_composeAni_sp:setTimeScale(2)
    -- _composeAni_sp:registerSpineEventHandler( function ( event )
    --         if event.eventData.name == "atk" then
    --             -- XTHDTOAST("adgag")
    --             _composeAni_sp:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
    --             -- _composeAni_sp:setVisible(false)
    --             _containerLayer:setClickable(true)
    --             self:initLayer(_data)
    --         end
    --     end, sp.EventType.ANIMATION_EVENT)
    local _spinePos = _composeAni_sp:getNodeForSlot("xiaoguo_00017"):convertToWorldSpace(cc.p(0.5,0.5))
    _spinePos = _containerLayer:convertToNodeSpace(_spinePos)

    for i=1,#_lightArr do
        local _lightSp = cc.Sprite:create("res/image/plugin/compose/compose_lightSp.png")
        _lightSp:setScale(2)
        local _pos = _containerLayer:convertToNodeSpace(_lightArr[i])
        _lightSp:setPosition(_pos)
        _containerLayer:addChild(_lightSp)
        _lightSp:runAction(cc.Sequence:create(cc.Sequence:create(cc.DelayTime:create((0.05+0.13*i)*0.5)
            ,cc.MoveBy:create(0.06 * 0.5,cc.p(0,80-i*20))
            ,cc.DelayTime:create(0.05 * 0.5)
            ,cc.Spawn:create(cc.MoveTo:create(0.3 * 0.5,_spinePos),cc.ScaleTo:create(0.15 * 0.5,1))
            ,cc.CallFunc:create(function()
                _composeAni_sp:setAnimation(0,"atk",true)
                _lightSp:removeFromParent()
            end))))
    end

end

function TieJiangPuResultPopLayer:showItemResult(_data,callback1)
    if _data == nil then
        self:removeFromParent()
        return
    end
    local _containerLayer = self:getContainerLayer()
    local _composeAni_sp = _containerLayer:getChildByName("composeAni_sp")
    if _composeAni_sp ~=nil then
        _composeAni_sp:registerSpineEventHandler( function ( event )
                    if event.animation == "atk" then
                        _composeAni_sp:addAnimation(0,"atk",false)
                        _composeAni_sp:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
                        _composeAni_sp:registerSpineEventHandler( function ( event )
                                if event.eventData.name == "atk" then
                                    if callback1 then
                                        _data = callback1(_data)
                                    end
                                    -- XTHDTOAST("adgag")
                                    _composeAni_sp:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
                                    -- _composeAni_sp:setVisible(false)
                                    
                                    self:initLayer(_data)
                                end
                            end, sp.EventType.ANIMATION_EVENT)
                        
                    end     
                end, sp.EventType.ANIMATION_COMPLETE)
        
    else
        self:initLayer(_data)
    end
    
end

function TieJiangPuResultPopLayer:initLayer(_data)
    self:setStaticItemData()
    self:setResultData(_data)
    
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
            self:getContainerLayer():setClickable(true)
            if self:getContainerLayer():getChildByName("composeAni_sp") then
                self:getContainerLayer():removeChildByName("composeAni_sp")
            end
        end)))
    if next(self.resultData)==nil then
        self:removeFromParent()
        return
    end



    if not self.resultData.allCount or not self.resultData.successCount or not self.resultData.failureCount then
        return
    end
    if tonumber(self.resultData.allCount) == tonumber(self.resultData.successCount) then
        self:initSuccessLayer()
    elseif tonumber(self.resultData.allCount) == tonumber(self.resultData.failureCount) then
        self:initFailureLayer()
    else
        self:initSynthesisLayer()
    end

	self:show()
end

function TieJiangPuResultPopLayer:initSuccessLayer()
    self:setSuccessPopNode(215)


    if self.popNode == nil then
        return
    end
    local _successPart = self:getSuccessPart()
    _successPart:setAnchorPoint(cc.p(0.5,1))
    _successPart:setPosition(cc.p(self.popNode:getContentSize().width/2,self.popNode:getContentSize().height-24))
    self.popNode:addChild(_successPart)
end

function TieJiangPuResultPopLayer:initFailureLayer()
    local _containerLayer= self:getContainerLayer()
    -- _containerLayer:setClickable(false)
    local _tureAniSpr = cc.Sprite:create("res/image/common/popBox_failureLight.png")
    _tureAniSpr:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2+130))
    _containerLayer:addChild(_tureAniSpr)
    _tureAniSpr:runAction(cc.RepeatForever:create(cc.RotateBy:create(60,360)))
    --中间框
    local popNode = ccui.Scale9Sprite:create(cc.rect(0,80,485,100),"res/image/plugin/compose/composeBg_failure.png")
    popNode:setContentSize(cc.size(485,283))
    self.popNode = popNode
    popNode:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
    _containerLayer:addChild(popNode)

    local _failurePart = self:getFailurePart()
    _failurePart:setAnchorPoint(cc.p(0.5,1))
    _failurePart:setPosition(cc.p(popNode:getContentSize().width/2+5,213))
    popNode:addChild(_failurePart)
end

function TieJiangPuResultPopLayer:initSynthesisLayer()
    self:setSuccessPopNode(435)
    if self.popNode == nil then
        return
    end

    local _successPart = self:getSuccessPart()
    _successPart:setAnchorPoint(cc.p(0.5,1))
    _successPart:setPosition(cc.p(self.popNode:getContentSize().width/2,self.popNode:getContentSize().height-24))
    self.popNode:addChild(_successPart)

    local _failurePart = self:getFailurePart()
    _failurePart:setAnchorPoint(cc.p(0.5,1))
    _failurePart:setPosition(cc.p(self.popNode:getContentSize().width/2,self.popNode:getContentSize().height-200))
    self.popNode:addChild(_failurePart)

    local _lineSp = cc.Sprite:create("res/image/plugin/compose/compose_line.png")
    _lineSp:setPosition(cc.p(self.popNode:getContentSize().width/2,54))
    self.popNode:addChild(_lineSp)

    --总结
    local _summaryposY = 20
    local _allcountlabelSp = cc.Sprite:create("res/image/plugin/compose/compose_summaryText.png")
    _allcountlabelSp:setAnchorPoint(cc.p(0,0))
    _allcountlabelSp:setPosition(cc.p(18,_summaryposY))
    self.popNode:addChild(_allcountlabelSp)
    local _allCountLabel = getCommonWhiteBMFontLabel(self.resultData.allCount)
    _allCountLabel:setAnchorPoint(cc.p(0,0))
    _allCountLabel:setPosition(cc.p(_allcountlabelSp:getBoundingBox().x+_allcountlabelSp:getBoundingBox().width+4,_allcountlabelSp:getBoundingBox().y - 13))
    self.popNode:addChild(_allCountLabel)
    local _countlabel = cc.Sprite:create("res/image/activities/onlinereward/onlinereward_ci.png")
    _countlabel:setScale(0.9)
    _countlabel:setAnchorPoint(cc.p(0,0))
    _countlabel:setPosition(cc.p(_allCountLabel:getBoundingBox().x+_allCountLabel:getBoundingBox().width,_allcountlabelSp:getBoundingBox().y+1))
    self.popNode:addChild(_countlabel)

    --成功次数
    local _successcountSp = cc.Sprite:create("res/image/plugin/compose/compose_successText.png")
    _successcountSp:setAnchorPoint(cc.p(0,0))
    _successcountSp:setPosition(cc.p(213,_summaryposY))
    self.popNode:addChild(_successcountSp)
    local _successLabel = XTHDLabel:create(self.resultData.successCount .. LANGUAGE_KEY_TIMES,self._fontSize+2)
    _successLabel:setColor(self:getTextColor("shenhese"))
    _successLabel:setAnchorPoint(cc.p(0,0.5))
    _successLabel:setPosition(cc.p(_successcountSp:getBoundingBox().x+_successcountSp:getBoundingBox().width+4,_successcountSp:getBoundingBox().y + _successcountSp:getBoundingBox().height/2))
    self.popNode:addChild(_successLabel)

    --失败次数
    local _failurecountSp = cc.Sprite:create("res/image/plugin/compose/compose_failureText.png")
    _failurecountSp:setAnchorPoint(cc.p(0,0))
    _failurecountSp:setPosition(cc.p(319,_summaryposY))
    self.popNode:addChild(_failurecountSp)
    local _failureLabel = XTHDLabel:create(self.resultData.failureCount .. LANGUAGE_KEY_TIMES,self._fontSize+2)
    _failureLabel:setColor(self:getTextColor("shenhese"))
    _failureLabel:setAnchorPoint(cc.p(0,0.5))
    _failureLabel:setPosition(cc.p(_failurecountSp:getBoundingBox().x+_failurecountSp:getBoundingBox().width+4,_failurecountSp:getBoundingBox().y+_failurecountSp:getBoundingBox().height/2))
    self.popNode:addChild(_failureLabel)

end

function TieJiangPuResultPopLayer:setSuccessPopNode(_height)
    local _nodeheight = _height or 215
    local _containerLayer= self:getContainerLayer()
    local _tureAniSpr = cc.Sprite:create("res/image/common/popBox_successLight.png")
    _tureAniSpr:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2+130))
    _containerLayer:addChild(_tureAniSpr)
    _tureAniSpr:runAction(cc.RepeatForever:create(cc.RotateBy:create(60,360)))
    --中间框
    local _contentNormalNode = ccui.Scale9Sprite:create(cc.rect(),"res/image/common/popBox_middlesp.png")
    _contentNormalNode:setContentSize(cc.size(424,_nodeheight))
    local _contentSpr = XTHDPushButton:createWithParams({
            normalNode = _contentNormalNode
        })
    self.popNode = _contentSpr
    _contentSpr:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
    _containerLayer:addChild(_contentSpr)
    --上下卷轴
    local _up_spr = cc.Sprite:create("res/image/common/popBox_topsp.png")
    _up_spr:setPosition(cc.p(_contentSpr:getContentSize().width/2,_contentSpr:getContentSize().height ))
    _contentSpr:addChild(_up_spr)
    local _down_spr = cc.Sprite:create("res/image/common/popBox_topsp.png")
    _down_spr:setPosition(cc.p(_contentSpr:getContentSize().width/2,0))
    _contentSpr:addChild(_down_spr)
    --左右挂饰
    local _rightAdornsp = cc.Sprite:create("res/image/common/popBox_adornsp.png")
    _rightAdornsp:setAnchorPoint(cc.p(0.5,1))
    _rightAdornsp:setPosition(cc.p(24,_up_spr:getContentSize().height-2))
    _up_spr:addChild(_rightAdornsp)
    local _leftAdornsp = cc.Sprite:create("res/image/common/popBox_adornsp.png")
    _leftAdornsp:setAnchorPoint(cc.p(0.5,1))
    _leftAdornsp:setPosition(cc.p(_up_spr:getContentSize().width-13,_up_spr:getContentSize().height-3))
    _up_spr:addChild(_leftAdornsp)

    --进阶成功
    local _composeResultTitle = cc.Sprite:create("res/image/plugin/compose/compose_titleText.png")
    _composeResultTitle:setAnchorPoint(cc.p(0.5,0))
    _composeResultTitle:setPosition(cc.p(_contentSpr:getContentSize().width/2,_contentSpr:getContentSize().height-5))
    _contentSpr:addChild(_composeResultTitle)
end

function TieJiangPuResultPopLayer:getSuccessPart()
    local _successPartBg = self:getPartBg("res/image/plugin/compose/compose_successTitleText.png")

    if self.resultData.newItems~=nil and #self.resultData.newItems >0 and tonumber(self.resultData.successCount)>0 then
        local _itemCount = 1
        local _distance = tonumber(_successPartBg:getContentSize().width - 20 - 80 * _itemCount)/(_itemCount+1)
        local _itemPosY = -14
        for i=1,_itemCount do
            local _itemSp = ItemNode:createWithParams({
                dbId = self.resultData.newItems[i].dbId or nil,
                itemId = self.resultData.newItems[i].itemId or 0,
                _type_ = 4,
                count = self.resultData.newItems[i].addCount or 0,
                touchShowTip = true
            })
            _itemSp:setAnchorPoint(cc.p(0,1))
            _itemSp:setPosition(cc.p(i*_distance + (i-1)*_itemSp:getBoundingBox().width + 5,_itemPosY + 10))
            _successPartBg:addChild(_itemSp)
            local _itemNamelabel = XTHDLabel:create(self.resultData.newItems[i].name or "",self._fontSize)
            _itemNamelabel:enableShadow(self:getTextColor("shenhese"),cc.size(0.4,-0.4),1)
            _itemNamelabel:setColor(self:getTextColor("shenhese"))
            _itemNamelabel:setAnchorPoint(cc.p(0.5,0))
            _itemNamelabel:setPosition(cc.p(_itemSp:getBoundingBox().x+_itemSp:getBoundingBox().width/2,_itemSp:getBoundingBox().y-24))
            _successPartBg:addChild(_itemNamelabel)
        end
    else
        local _nosuccessItem = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.composeNoneItemsMakeTextXc ,self._fontSize+4)
        _nosuccessItem:setColor(self:getTextColor("shenhese"))
        _nosuccessItem:setPosition(cc.p(_successBg:getContentSize().width/2,(_successPartBg:getContentSize().height-40)/2))
        _successBg:addChild(_nosuccessItem)
    end
    return _successPartBg
end

function TieJiangPuResultPopLayer:getFailurePart()
    local _failurePartBg = self:getPartBg("res/image/plugin/compose/compose_failureTitleText.png")

    if self.resultData.returnItems~=nil and #self.resultData.returnItems >0 then
        local _itemCount = tonumber(#self.resultData.returnItems)
        local _distance = tonumber(_failurePartBg:getContentSize().width - 20 - 80 * _itemCount)/(_itemCount+1)
        local _itemPosY = -14
        for i=1,_itemCount do
            local _itemSp = ItemNode:createWithParams({
                dbId = self.resultData.returnItems[i].dbId or nil,
                itemId = self.resultData.returnItems[i].itemId or 0,
                _type_ = 4,
                count = self.resultData.returnItems[i].count or 0,
                touchShowTip = true
            })
            _itemSp:setAnchorPoint(cc.p(0,1))
            _itemSp:setPosition(cc.p(i*_distance + (i-1)*_itemSp:getBoundingBox().width + 10,_itemPosY))
            _failurePartBg:addChild(_itemSp)
            
            local _nameTable = self.staticItemData[tostring(self.resultData.returnItems[i].itemId)] or {}
            local _nameStr = _nameTable and _nameTable.name or ""
            local _itemNamelabel = XTHDLabel:create(_nameStr,self._fontSize)
            _itemNamelabel:enableShadow(self:getTextColor("shenhese"),cc.size(0.4,-0.4),1)
            _itemNamelabel:setColor(self:getTextColor("shenhese"))
            _itemNamelabel:setAnchorPoint(cc.p(0.5,0))
            _itemNamelabel:setPosition(cc.p(_itemSp:getBoundingBox().x+_itemSp:getBoundingBox().width/2,_itemSp:getBoundingBox().y-24))
            _failurePartBg:addChild(_itemNamelabel)
        end
    else
        local _nofailureItem = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.composeNoneItemsBackTextXc ,self._fontSize+4)
        _nofailureItem:setColor(self:getTextColor("shenhese"))
        _nofailureItem:setPosition(cc.p(_failurePartBg:getContentSize().width/2,-44))
        _failurePartBg:addChild(_nofailureItem)
    end
    return _failurePartBg
end

function TieJiangPuResultPopLayer:getPartBg(_path)
    local _successPartBg = cc.Sprite:create("res/image/plugin/compose/compose_partBg.png")
    local _successTitleLabelSp = cc.Sprite:create(_path)
    _successTitleLabelSp:setPosition(cc.p(_successPartBg:getContentSize().width/2,_successPartBg:getContentSize().height/2))
    _successPartBg:addChild(_successTitleLabelSp)

    local _successTitleleftSp = cc.Sprite:create("res/image/plugin/weaponshop/pattern_left.png")
    _successTitleleftSp:setAnchorPoint(cc.p(1,0.5))
    _successTitleleftSp:setPosition(cc.p(_successTitleLabelSp:getBoundingBox().x - 5,_successTitleLabelSp:getPositionY()))
    _successPartBg:addChild(_successTitleleftSp)
    local _successTitlerightSp = cc.Sprite:create("res/image/plugin/weaponshop/pattern_right.png")
    _successTitlerightSp:setAnchorPoint(cc.p(0,0.5))
    _successTitlerightSp:setPosition(cc.p(_successTitleLabelSp:getBoundingBox().x + _successTitleLabelSp:getBoundingBox().width + 5,_successTitleLabelSp:getPositionY()))
    _successPartBg:addChild(_successTitlerightSp)
    return _successPartBg
end


function TieJiangPuResultPopLayer:setResultData(_data)
	if _data==nil or next(_data)==nil then
		return
	end
    self.resultData = _data
    local _newItems = _data["newItems"] or {}
    local _successCount = tonumber(_newItems[1] and _newItems[1].addCount or 0)
    self.resultData.successCount = _successCount
    local _allCount = tonumber(self.resultData.allCount or 0)
    self.resultData.allCount = _allCount
    local _failureCount = _allCount - _successCount
    _failureCount = _failureCount >=0 and _failureCount or 0
    self.resultData.failureCount = _failureCount
end

function TieJiangPuResultPopLayer:setStaticItemData()
    self.staticItemData = {}
    self.staticItemData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
end

function TieJiangPuResultPopLayer:getTextColor(_str)
	local _color = {
		huanghese = cc.c4b(237, 232, 193,255),
        shenhese = cc.c4b(67,28,4,255)
	}
	return _color[tostring(_str)]
end

function TieJiangPuResultPopLayer:create(_lightArr)
	local _layer = self.new(_lightArr)
	return _layer
end
return TieJiangPuResultPopLayer