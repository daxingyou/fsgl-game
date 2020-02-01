--[[
资源缺少公共pop框分支版，只有元宝，银两，翡翠，强化石。
参数：1.元宝不足2.体力不足3.银两不足4.翡翠不足5.强化石不足
]]
local SourceLackDetailPop1=class("SourceLackDetailPop1",function ()
	return XTHDPopLayer:create()
end)
function SourceLackDetailPop1:ctor(id)
	self:initUi(id)
end

function SourceLackDetailPop1:onCleanup()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TASKLIST })
end

function SourceLackDetailPop1:initUi(Id)
    local _sourceTable = {
        [1] = {
            {pictureId = 4,textId = 4,id = 58},
            {pictureId = 5,textId = 5,id = 44},
            {pictureId = 5,textId = 6,id = 42},
        },
        [3] = {
            {pictureId = 1,textId = 1,id = 25},
            {pictureId = 2,textId = 2,id = 17},
            {pictureId = 3,textId = 3,id = 69},
        },
        [4] = {
            {pictureId = 9,textId = 9,id = 26},
            {pictureId = 2,textId = 2,id = 17},
            {pictureId = 3,textId = 3,id = 69},
        },
    }
    self.functionInfoData = {}
    self:setStaticData()

    self:initLayer(_sourceTable[tonumber(Id)],Id)
end

function SourceLackDetailPop1:initLayer(data,_id)
    local _worldSize = cc.size(538, 418)
    local _titleBgSize = cc.size(_worldSize.width-7*2,44)

    local popNode = XTHD.getScaleNode("res/image/common/scale9_bg1_34.png",_worldSize)
    self._popNode = popNode
    popNode:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
    self:addContent(popNode)

    local close_btn = XTHD.createBtnClose(function()
        self:hide()
    end)
    close_btn:setPosition(_worldSize.width - 10, _worldSize.height - 10)
    popNode:addChild(close_btn, 3)
    
    -- local _titleBgSp = XTHD.getScaleNode("res/image/common/common_title_barBg.png",_titleBgSize)
    local _titleBgSp = ccui.Scale9Sprite:create()
    _titleBgSp:setContentSize(_titleBgSize)
    _titleBgSp:setAnchorPoint(cc.p(0.5,1))
    _titleBgSp:setPosition(cc.p(popNode:getContentSize().width/2,popNode:getContentSize().height-7))
    popNode:addChild(_titleBgSp)


    local _titleName = XTHDLabel:create(LANGUAGE_SOURCELACK_TITLENAME(_id),22)
    _titleName:enableShadow(cc.c3b(54,55,112),cc.size(0.4,-0.4),0.4)
    _titleName:setColor(cc.c3b(54,55,112))
    _titleName:setPosition(cc.p(_titleBgSp:getContentSize().width/2,_titleBgSp:getContentSize().height/2))
    _titleBgSp:addChild(_titleName)

    local _contentHeight = _titleBgSp:getBoundingBox().y-8
    local _itemheight = (_contentHeight-8*4)/3
    for i=1,3 do
        local _itemPosY = 8+2 + (_contentHeight-4)/6*(7-i*2)+10
        local normalsp = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
        normalsp:setContentSize(cc.size(_worldSize.width-20,_itemheight))
        local _btnItem = XTHD.createButton({
                -- normalNode = BangPaiFengZhuangShuJu.createListCellBg(cc.size(_worldSize.width-20,_itemheight)),
                normalNode = normalsp,
                touchScale = 0.95,
                toucheSize = cc.size(_worldSize.width-20,_itemheight),
            })
        local _imgSp = cc.Sprite:create("res/image/plugin/sourcelack/sourceTurn_" .. data[i].pictureId .. ".png")
        _imgSp:setPosition(cc.p(45,_btnItem:getContentSize().height/2))
        _btnItem:addChild(_imgSp)

        local _textSp = XTHDLabel:create(LANGUAGE_SOURCELACK_TURNNAME[tonumber(data[i].textId)],22)
        _textSp:setColor(XTHD.resource.textColor.gray_text)
        _textSp:setPosition(cc.p(_btnItem:getContentSize().width/2,_btnItem:getContentSize().height/2))
        _btnItem:addChild(_textSp)
        local functionData = self.functionInfoData[tonumber(data[i].id)] or {}
        _btnItem:setTouchEndedCallback(function()
                self:removeFromParent()
                replaceLayer({
                        id = functionData.goid,
                        functionId = functionData.id,
                    })
            end)
        _btnItem:setPosition(cc.p(popNode:getContentSize().width/2,_itemPosY))
        popNode:addChild(_btnItem)
    end
    self:show()
end

function SourceLackDetailPop1:setStaticData()
    self.functionInfoData = gameData.getDataFromCSV("FunctionInfoList")
end

function SourceLackDetailPop1:create(id)
    return SourceLackDetailPop1.new(id)
end
return SourceLackDetailPop1