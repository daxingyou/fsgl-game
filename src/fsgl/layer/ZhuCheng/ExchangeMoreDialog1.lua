local ExchangeMoreDialog1 = class("ExchangeMoreDialog1",function()
		return XTHDPopLayer:create()
	end)
function ExchangeMoreDialog1:ctor(_layer)
	self.data = {}
	self._layer = _layer 
	self._exchangedCount = self._layer.exchangedCount or 0
	self:init()
end

function ExchangeMoreDialog1:init()
	
	local _nameStr = 1--LANGUAGE_TIPS_WORDS139 ----"金手指"
	local _imgPath = "res/image/common/header_gold.png"
	self._exchangeLastCount = gameUser.getGoldSurplusExchangeCount()
	if self._layer._type and self._layer._type == "feicui" then
		_nameStr = 2--LANGUAGE_TIPS_WORDS140 -----"翡翠手"
		_imgPath = "res/image/common/header_feicui.png"
		self._exchangeLastCount = gameUser.getFeicuiSurplusExchangeCount()
	else
		_nameStr = 1--LANGUAGE_TIPS_WORDS139-----"金手指"
		_imgPath = "res/image/common/header_gold.png"
		self._exchangeLastCount = gameUser.getGoldSurplusExchangeCount()
	end

	self:setMyData()


	local popNode = ccui.Scale9Sprite:create( cc.rect(40,40,1,2), "res/image/common/scale9_bg_34.png" )
    popNode:setContentSize(419,270)
	popNode:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2+90))
	self:getContainerLayer():addChild(popNode)

	local _cancelBtn = XTHD.createCommonButton({
        btnColor = "red",
        btnSize = cc.size(150,51),
        isScrollView = false,
        text = LANGUAGE_KEY_CANCEL,
        fontSize = 22,
        endCallback       = function()
                self:hide({music = true})
            end,--
    })
    _cancelBtn:setPosition(cc.p(popNode:getContentSize().width/4,60))
    popNode:addChild(_cancelBtn)

    local _sureBtn = XTHD.createCommonButton({
        btnColor = "green",
        btnSize = cc.size(150,51),
        isScrollView = false,
        text = LANGUAGE_KEY_SURE,
        fontSize = 22,
        endCallback       = function()
                local _hadIngot = gameUser.getIngot()
                if tonumber(_hadIngot)<tonumber(self.data.costnum) then
                    local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=1})
                    cc.Director:getInstance():getRunningScene():addChild(StoredValue)
                    return
                end
                self._layer:httpToExchange(self.data.exchangeNum)
                self:hide({music = true})
            end,--
    })
    _sureBtn:setPosition(cc.p(popNode:getContentSize().width/4*3,60))
    popNode:addChild(_sureBtn)

    local _posX = 110
    --兑换
    local _exchange_label = XTHDLabel:create(LANGUAGE_VERBS.exchange,20)----"兑换"
    _exchange_label:setAnchorPoint(cc.p(0,1))
    _exchange_label:setColor(cc.c4b(67,28,4,255))
    _exchange_label:setPosition(cc.p(_posX,popNode:getContentSize().height - 40))
    popNode:addChild(_exchange_label)
    local _number = XTHDLabel:create(self.data.exchangeNum,22)
    _number:setAnchorPoint(cc.p(0,0))
    _number:setColor(cc.c4b(26,158,207,255))
    _number:setPosition(cc.p(_exchange_label:getBoundingBox().x + _exchange_label:getBoundingBox().width,_exchange_label:getBoundingBox().y))
    popNode:addChild(_number)
    local _otherLabel = XTHDLabel:create(LANGUAGE_EXCHANGEMORE_EXCHANGE(_nameStr),20)----"次"
    _otherLabel:setAnchorPoint(cc.p(0,0))
    _otherLabel:setColor(cc.c4b(67,28,4,255))
    _otherLabel:setPosition(cc.p(_number:getBoundingBox().x + _number:getBoundingBox().width,_number:getBoundingBox().y))
    popNode:addChild(_otherLabel)

    --需要消耗
    local _cost_label = XTHDLabel:create(LANGUAGE_TIPS_WORDS141,20) ----"需要消耗:"
    _cost_label:setAnchorPoint(cc.p(0,1))
    _cost_label:setColor(cc.c4b(67,28,4,255))
    _cost_label:setPosition(cc.p(_posX,_exchange_label:getBoundingBox().y - 27))
    popNode:addChild(_cost_label)

    local _exchangeSp = cc.Sprite:create("res/image/common/common_gold.png")
    _exchangeSp:setAnchorPoint(cc.p(0.5,0.5))
    _exchangeSp:setPosition(cc.p(_cost_label:getBoundingBox().x + _cost_label:getBoundingBox().width + 25,_cost_label:getBoundingBox().y + _cost_label:getBoundingBox().height/2))
    popNode:addChild(_exchangeSp)

    local _costNumlabel = getCommonYellowBMFontLabel(getHugeNumberWithLongNumber(self.data.costnum,100000))
    _costNumlabel:setScale(1.1)
    _costNumlabel:setAnchorPoint(cc.p(0,0))
    _costNumlabel:setPosition(cc.p(_cost_label:getBoundingBox().x + _cost_label:getBoundingBox().width + 55,_cost_label:getBoundingBox().y-14))
    popNode:addChild(_costNumlabel)

    --至少获得
    local _get_label = XTHDLabel:create(LANGUAGE_TIPS_WORDS142,20)-----"至少获得:"
    _get_label:setAnchorPoint(cc.p(0,1))
    _get_label:setColor(cc.c4b(67,28,4,255))
    _get_label:setPosition(cc.p(_posX,_cost_label:getBoundingBox().y - 27))
    popNode:addChild(_get_label)

    local _getSp = cc.Sprite:create(_imgPath)
    _getSp:setAnchorPoint(cc.p(0.5,0.5))
    _getSp:setPosition(cc.p(_get_label:getBoundingBox().x + _get_label:getBoundingBox().width+25,_get_label:getBoundingBox().y + _get_label:getBoundingBox().height/2))
    popNode:addChild(_getSp)

    local _getNumlabel = getCommonWhiteBMFontLabel(getHugeNumberWithLongNumber(self.data.harvest,100000))
    _getNumlabel:setAnchorPoint(cc.p(0,0))
    _getNumlabel:setScale(1.1)
    _getNumlabel:setPosition(cc.p(_get_label:getBoundingBox().x + _get_label:getBoundingBox().width + 55,_get_label:getBoundingBox().y-14))
    popNode:addChild(_getNumlabel)


	self:show()
end

function ExchangeMoreDialog1:getButtonNode(_path)
	local _node = ccui.Scale9Sprite:create(cc.rect(50,0,30,51),_path)
	_node:setContentSize(cc.size(150,51))
	return _node
end

function ExchangeMoreDialog1:setMyData()
	self.data.exchangeNum = 0
	self.data.costnum = 0
	self.data.harvest = 0
	if tonumber(self._exchangeLastCount) > 9 then
		self.data.exchangeNum = 10
	else
		self.data.exchangeNum = tonumber(self._exchangeLastCount)
	end
	if self._layer.exchangeListData==nil or next(self._layer.exchangeListData)==nil then
		return
	end
	local _startidx = self._exchangedCount + 1
	local _endidx = self._exchangedCount + self.data.exchangeNum
	for i=_startidx,_endidx do
        if self._layer.exchangeListData[tonumber(i)]==nil or next(self._layer.exchangeListData[tonumber(i)])==nil then
            break
        end
		local _currentData = clone(self._layer.exchangeListData[tonumber(i)] or {})
		local _cost = _currentData["yuanbao"] or 0
		local _harvest = _currentData["mix"] or 0
		self.data.costnum = self.data.costnum + _cost
		self.data.harvest = self.data.harvest + _harvest
	end
end

function ExchangeMoreDialog1:create(_layer_,_num)
	local _layer = self.new(_layer_)
	return _layer
end
return ExchangeMoreDialog1