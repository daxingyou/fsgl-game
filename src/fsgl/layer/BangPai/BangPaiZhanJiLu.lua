------帮派战记录页
local BangPaiZhanJiLu = class("BangPaiZhanJiLu", function ( sParams ) 
	return requires("src/fsgl/layer/BangPai/BangPaiXinXi.lua"):create(sParams)
end)

function BangPaiZhanJiLu:createOne( sParams)
	local params = {
		size = cc.size(521, 450),
		titleNode = cc.Sprite:create("res/image/guild/guildWar/guildWarText_record.png"),
	}
	local pLay = BangPaiZhanJiLu.new(params)
	pLay:init(sParams)
	LayerManager.addLayout(pLay, {noHide = true})
	return pLay
end

function BangPaiZhanJiLu:init(params)	
	local mParams = params or {}	
	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()
	self.containerSize = _worldSize

	self._params.list = mParams.list or {}
	
	-- {attackName = "test", defendName = "test2", result = 1, lore = 1}
	-- for i=1, 100 do
	-- 	local pData = self._params.list[i]
	-- 	pData.result = math.random(2) == 1 and 1 or 0
	-- 	pData.lore = math.random(2) == 1 and 1 or 0
	-- 	table.insert(self._params.list, pData)
	-- end
	self._nowPage = 1
	self._maxPage = 1
	local tmp = 0
	self._maxPage, tmp = math.modf(#self._params.list/10)
	print(self._maxPage)
	if tmp > 0 then
		self._maxPage = self._maxPage + 1
	end

	----翻页 左
	local _leftBtn = XTHD.createPushButtonWithSound({
        normalFile = "res/image/common/btn/btn_gray_small_normal.png",
        selectedFile = "res/image/common/btn/btn_gray_small_selected.png" 
	},3)
	self._popNode:addChild(_leftBtn)	
	_leftBtn:setAnchorPoint(0,0.5)
	_leftBtn:setTouchEndedCallback(function( )
		self:doTurnPage(-1)
	end)
    local _word = cc.Sprite:create("res/image/guild/btnText_previousPage.png")
    _leftBtn:addChild(_word)
    _word:setPosition(_leftBtn:getContentSize().width / 2,_leftBtn:getContentSize().height / 2)
    ---右
    local _rightBtn = XTHD.createPushButtonWithSound({
        normalFile = "res/image/common/btn/btn_gray_small_normal.png",
        selectedFile = "res/image/common/btn/btn_gray_small_selected.png" 
	},3)
	self._popNode:addChild(_rightBtn)
	_rightBtn:setAnchorPoint(0,0.5)
	_rightBtn:setTouchEndedCallback(function( )
		self:doTurnPage(1)
	end)
	_word = cc.Sprite:create("res/image/guild/btnText_nextPage.png")
	_rightBtn:addChild(_word)
	_word:setPosition(_rightBtn:getContentSize().width / 2,_rightBtn:getContentSize().height / 2)

    local _pageBg = ccui.Scale9Sprite:create(cc.rect(10,0,50,36),"res/image/common/shadow_bg.png")
    _pageBg:setContentSize(cc.size(76, 31))
    self._popNode:addChild(_pageBg)
    _pageBg:setAnchorPoint(0, 0.5)

    local _pageLabel = XTHDLabel:createWithSystemFont("1/1",XTHD.SystemFont,18)
    _pageLabel:setColor(XTHD.resource.color.gray_desc)    
    _pageBg:addChild(_pageLabel)
    _pageLabel:setPosition(_pageBg:getContentSize().width / 2,_pageBg:getContentSize().height / 2)
    self._pageLabel = _pageLabel

    local x = _leftBtn:getContentSize().width + _rightBtn:getContentSize().width + _pageBg:getContentSize().width
    x = (self.containerSize.width - x) / 2
    _leftBtn:setPosition(x,_leftBtn:getContentSize().height / 2 + 10)
    _pageBg:setPosition(_leftBtn:getPositionX() + _leftBtn:getContentSize().width + 5,_leftBtn:getPositionY())
    _rightBtn:setPosition(_pageBg:getPositionX() + _pageBg:getContentSize().width + 5,_pageBg:getPositionY())
    ------暗色背景
    local _listBg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/scale9_bg_23.png")
    _listBg:setContentSize(cc.size(self.containerSize.width - 15,self.containerSize.height - self._titleBack:getContentSize().height - _leftBtn:getPositionY() * 2 -7))
    self._popNode:addChild(_listBg)    
    _listBg:setPosition(self.containerSize.width / 2,self.containerSize.height / 2 - 2)
    self._listBg = _listBg
    
    ----竖线
	local _line = ccui.Scale9Sprite:create(cc.rect(0,15,2,1), "res/image/guild/guildImg_tableSpacer.png")
	_line:setContentSize(2, self._listBg:getContentSize().height)
	_line:setPosition(self._listBg:getContentSize().width/3, self._listBg:getContentSize().height*0.5)
	self._listBg:addChild(_line)

	_line = ccui.Scale9Sprite:create(cc.rect(0,15,2,1), "res/image/guild/guildImg_tableSpacer.png")
	self._listBg:addChild(_line)
	_line:setContentSize(2, self._listBg:getContentSize().height)
	_line:setPosition(self._listBg:getContentSize().width*2/3, self._listBg:getContentSize().height*0.5)
	-------格子标题	
	local _title = cc.Sprite:create("res/image/guild/guildWar/guildWarTitleText_ourmember.png")
	self._listBg:addChild(_title)

	
	local _hulfH = _title:getContentSize().height*0.5 + 5
	
	_title:setPosition(self._listBg:getContentSize().width/6, self._listBg:getContentSize().height - _hulfH)
	-------
	local _title2 = cc.Sprite:create("res/image/guild/guildWar/guildWarTitleText_enemymember.png")
	self._listBg:addChild(_title2)
	_title2:setPosition(self._listBg:getContentSize().width*0.5, _title:getPositionY())
	------
	local _title3 = cc.Sprite:create("res/image/guild/guildWar/guildWarTitleText_result.png")
	self._listBg:addChild(_title3)
	_title3:setPosition(self._listBg:getContentSize().width*5/6, _title:getPositionY())

	_line = ccui.Scale9Sprite:create(cc.rect(4,0,1,2), "res/image/guild/guild_horizontalLine.png")
    _line:setPosition(self._listBg:getContentSize().width*0.5, _title:getPositionY() - _hulfH)
	_line:setContentSize(cc.size(self._listBg:getContentSize().width, 2))
	self._listBg:addChild(_line)

	self._infoGroup = {}
	
	local pY = _line:getPositionY() - _hulfH
	for i=1, 9 do
		local pTb = {}
		local name = XTHDLabel:createWithParams({
	        text = "",
	        fontSize = 20,
	        color = XTHD.resource.color.brown_desc,
	        anchor = cc.p(0.5, 0.5),
	        pos = cc.p(self._listBg:getContentSize().width/6, pY)
        })
        pTb[1] = name
	    self._listBg:addChild(name)
		local name2 = XTHDLabel:createWithParams({
	        text = "",
	        fontSize = 20,
	        color = XTHD.resource.color.brown_desc,
	        anchor = cc.p(0.5, 0.5),
	        pos = cc.p(self._listBg:getContentSize().width*0.5, pY)
        })
        pTb[2] = name2
	    self._listBg:addChild(name2)
        local name3 = XTHDLabel:createWithParams({
	        text = "",
	        fontSize = 20,
	        anchor = cc.p(0.5, 0.5),
	        pos = cc.p(self._listBg:getContentSize().width*5/6, pY)
        })
        pTb[3] = name3
	    self._listBg:addChild(name3)
		if i ~= 9 then
			_line = ccui.Scale9Sprite:create(cc.rect(4,0,1,2), "res/image/guild/guild_horizontalLine.png")
		    _line:setContentSize(cc.size(self._listBg:getContentSize().width, 2))
		    _line:setPosition(self._listBg:getContentSize().width*0.5, pY - _hulfH)
			self._listBg:addChild(_line)
		end
		pY = _line:getPositionY() - _hulfH
		self._infoGroup[i] = pTb 
	end

	self:freshGrid()
end

function BangPaiZhanJiLu:doTurnPage( what )
	if self._maxPage == 1 then
		XTHDTOAST(LANGUAGE_KEY_GUILDWAR_TEXT.onlyOnePageTextXc)
		return 
	end
	self._nowPage = self._nowPage + what
	if self._nowPage <= 0 then
		self._nowPage = self._maxPage
	elseif self._nowPage > self._maxPage then
		self._nowPage = 1
	end
	self:freshGrid()
end

function BangPaiZhanJiLu:freshGrid( )
	self._pageLabel:setString(self._nowPage.."/"..self._maxPage)
	local pMin = (self._nowPage - 1)*10
	local pMax = pMin + 10
	local colorWin = cc.c3b(104, 157, 0)
	local colorLoss = cc.c3b(204, 2, 2)
	local descWin = LANGUAGE_KEY_GUILDWAR_TEXT.successTextXc
	local descLoss = LANGUAGE_ADJ.failed
	local descPing = LANGUAGE_KEY_GUILDWAR_TEXT.equalTextXc
	local descLossKill = LANGUAGE_KEY_GUILDWAR_TEXT.failurekillTextXc
	local descWinKill = LANGUAGE_KEY_GUILDWAR_TEXT.winkillTextXc
	for i = 1, 9 do
		local j = pMin + i
		local pData = self._params.list[j]
		if pData then
			self._infoGroup[i][1]:setString(pData.attackName)
			self._infoGroup[i][2]:setString(pData.defendName)
			if pData.result == 1 then
				if pData.attackLore == 1 then
					self._infoGroup[i][3]:setString(descWinKill)
				else
					self._infoGroup[i][3]:setString(descWin)
				end
				self._infoGroup[i][3]:setColor(colorWin)
			elseif pData.result == 0 then
				if pData.defendLore == 1 then
					self._infoGroup[i][3]:setString(descLossKill)
				else
					self._infoGroup[i][3]:setString(descLoss)
				end
				self._infoGroup[i][3]:setColor(colorLoss)
			elseif pData.result == 2 then
				self._infoGroup[i][3]:setString(descPing)
				self._infoGroup[i][3]:setColor(XTHD.resource.color.blue_desc)
			end
		else
			for k=1,3 do
				self._infoGroup[i][k]:setString("")
			end
		end
	end
end


return BangPaiZhanJiLu