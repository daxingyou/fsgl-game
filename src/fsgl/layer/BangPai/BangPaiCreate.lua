-- FileName: BangPaiCreate.lua
-- Author: wangming
-- Date: 2015-10-20
-- Purpose: 玩家创建/修改帮派信息界面
--[[TODO List]]

local BangPaiCreate = class("BangPaiCreate", function ( sParams ) 
	return requires("src/fsgl/layer/BangPai/BangPaiXinXi.lua"):create(sParams)
end)

function BangPaiCreate:init( sParams )

    self._containerLayer:setTouchEndedCallback(nil)
	local mParams = sParams or {}
	self._guildData = BangPaiFengZhuangShuJu.getGuildData()
	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()
	local pCostNum = 1000

	--第二个底框
	local popNode_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
	popNode_bg:setContentSize(320,310)
	popNode_bg:setPosition(popNode:getContentSize().width*0.5, popNode:getContentSize().height*0.5+15)
	-- popNode_bg:setScaleX(0.35)
	-- popNode_bg:setScaleY(0.6)
	popNode:addChild(popNode_bg)

    local _btnText = LANGUAGE_BTN_KEY.sureModify
    if self._guildData ==nil then
        _btnText = LANGUAGE_BTN_KEY.sureCreate
    end
	 --创建按钮
    local _createBtn = XTHD.createCommonButton({
			btnColor = "write",
			btnSize = cc.size(150,46),
			isScrollView = false,
            text = _btnText,
    		pos = cc.p(_worldSize.width*0.5, 13),
    		anchor = cc.p(0.5, 0),
    		endCallback = function ( ... )
    			self:httpToDoGuild()
    		end
		})
		_createBtn:setScale(0.8)
    popNode:addChild(_createBtn)

		--帮派图标
	local function _goChossIcon ( _callBack )
		requires("src/fsgl/layer/BangPai/BangPaiXiuGaiTouXiang.lua"):createOne({callBack = _callBack})
	end

	local function _createNewIcon( id )
		local ani = cc.p(0.5, 0.5)
		if self._guildIcon then
			self._guildIcon:removeFromParent()
			self._guildIcon = nil
		end
		self._nowSelectIcon = id
		local _guildIcon = BangPaiFengZhuangShuJu.createGuildButton(id, function ( ... )
			_goChossIcon(_createNewIcon)
		end)
		_guildIcon:setAnchorPoint(ani)
		local pos = cc.p(popNode_bg:getContentSize().width *0.5 + 10,popNode_bg:getContentSize().height + 10)
		_guildIcon:setPosition(pos)
		popNode:addChild(_guildIcon)
		self._guildIcon = _guildIcon
	end
    local allDatas = gameData.getDataFromCSV("ArticleInfoSheet")
	local pNum = self._guildData and self._guildData.icon or allDatas[1].itemid
	_createNewIcon(pNum)

    local _inputSize =  cc.size(307,40)
	
	--name
    local _guildNameBg = ccui.Scale9Sprite:create("res/image/login/login_input_bg.png")
    _guildNameBg:setAnchorPoint(cc.p(0.5,0))
    _guildNameBg:setContentSize(_inputSize)
    _guildNameBg:setPosition(cc.p(popNode_bg:getContentSize().width*0.5, popNode_bg:getContentSize().height *0.5 - 30))
    popNode_bg:addChild(_guildNameBg)

	 local _guildNameTitleSp = cc.Sprite:create("res/image/guild/guildText_exchangeName.png")
	_guildNameTitleSp:setAnchorPoint(cc.p(0.5,0.5))
	_guildNameTitleSp:setPosition(cc.p(_guildNameBg:getContentSize().width*0.5, _guildNameBg:getContentSize().height + _guildNameTitleSp:getContentSize().height *0.5 + 5))
	_guildNameBg:addChild(_guildNameTitleSp)

	
    local _costLabel = XTHDLabel:createWithParams({
    	text = LANGUAGE_KEY_ONLY_COST,
    	fontSize = 18,
    	color = cc.c3b(0, 0, 0),
    	anchor = cc.p(0, 0.5),
    	pos = cc.p(_guildNameBg:getContentSize().width*0.5-70, - _guildNameBg:getContentSize().height*0.5)
	})
    _guildNameBg:addChild(_costLabel)

	 local _costSp = cc.Sprite:create("res/image/common/header_ingot.png")
    _costSp:setAnchorPoint(cc.p(1, 0.5))
    _costSp:setPosition(cc.p(_costLabel:getPositionX() + _costSp:getContentSize().width + _costLabel:getContentSize().width + 5,_costLabel:getPositionY()))
    _guildNameBg:addChild(_costSp)    

    local _costNumLabel = getCommonWhiteBMFontLabel(pCostNum)
    _costNumLabel:setAnchorPoint(cc.p(1, 0.5))
    _costNumLabel:setPosition(cc.p(_costSp:getPositionX() + _costSp:getContentSize().width + 10, _costLabel:getPositionY() - 6))
    _guildNameBg:addChild(_costNumLabel)
--    if self._guildData then
--    	_costNumLabel:setString(0)
--    end

    local _guildName_editbox = ccui.EditBox:create(cc.size(_inputSize.width-15, _inputSize.height-5),ccui.Scale9Sprite:create(),nil,nil)
    _guildName_editbox:setFontColor(cc.c4b(255,255,255,255))
    _guildName_editbox:setPlaceHolder(LANGUAGE_KEY_GUILD_TEXT.guildNameInputWordXc)
    if self._guildData then
    	local pString = tostring(self._guildData.guildName)
    	-- _guildName_editbox:setPlaceHolder(pString)
    	_guildName_editbox:setText(pString)
    end
    _guildName_editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)   
    _guildName_editbox:setAnchorPoint(cc.p(0.5, 0.5))
    _guildName_editbox:setMaxLength(5)
    _guildName_editbox:setPosition(_inputSize.width*0.5, _inputSize.height*0.43)
    _guildName_editbox:setPlaceholderFontColor(cc.c4b(176,163,144,255))
    _guildName_editbox:setFontSize(20)
    _guildName_editbox:setPlaceholderFontSize(20)
    _guildName_editbox:setFontName("Helvetica")
    _guildName_editbox:setPlaceholderFontName("Helvetica")
    _guildName_editbox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    _guildNameBg:addChild(_guildName_editbox)
    self._guildNameEdit = _guildName_editbox
    if self._guildData then
		_guildName_editbox:registerScriptEditBoxHandler(function (strEventName, pSender)
    		if strEventName == "ended" or strEventName == "return" then
    			local pText = pSender:getText()
    			local pString = tostring(self._guildData.guildName)
    			if pText ~= pString then
    				_costNumLabel:setString(pCostNum)
    			else
    				_costNumLabel:setString(0)
    			end
				_costSp:setPosition(cc.p(_costNumLabel:getPositionX() - _costNumLabel:getContentSize().width - 5,_costLabel:getPositionY()))
			end
    	end)
    end

	--等级限制
    local _joinlimitBg = ccui.Scale9Sprite:create("res/image/login/login_input_bg.png")
    _joinlimitBg:setAnchorPoint(cc.p(0.5,0))
    _joinlimitBg:setContentSize(_inputSize)
    _joinlimitBg:setPosition(cc.p(popNode_bg:getContentSize().width*0.5, 20))
    popNode_bg:addChild(_joinlimitBg)

	 local _joinLimitTitleSp = cc.Sprite:create("res/image/guild/guildText_levelLimit.png")
	_joinLimitTitleSp:setAnchorPoint(cc.p(0.5, 0.5))
	_joinLimitTitleSp:setPosition(cc.p(_joinlimitBg:getContentSize().width*0.5, _joinlimitBg:getContentSize().height + _joinLimitTitleSp:getContentSize().height * 0.5 + 5))
	_joinlimitBg:addChild(_joinLimitTitleSp)


    local _joinlimit_editbox = ccui.EditBox:create(cc.size(_inputSize.width-15, _inputSize.height-5),ccui.Scale9Sprite:create(),nil,nil)
    _joinlimit_editbox:setFontColor(cc.c4b(255,255,255,255))
    _joinlimit_editbox:setPlaceHolder(LANGUAGE_KEY_GUILD_TEXT.guildLevelLimitInputWordXc)
    if self._guildData then
    	local pString = tostring(self._guildData.limitLevel)
    	_joinlimit_editbox:setPlaceHolder(pString)
    end
    _joinlimit_editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    _joinlimit_editbox:setAnchorPoint(cc.p(0.5, 0.5))
    _joinlimit_editbox:setMaxLength(2)
    _joinlimit_editbox:setPosition(_inputSize.width*0.5, _inputSize.height*0.43)
    _joinlimit_editbox:setPlaceholderFontColor(cc.c4b(176,163,144,255))
    _joinlimit_editbox:setFontSize(20)
    _joinlimit_editbox:setPlaceholderFontSize(20)
    _joinlimit_editbox:setFontName("Helvetica")
    _joinlimit_editbox:setPlaceholderFontName("Helvetica")
    _joinlimit_editbox:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    _joinlimitBg:addChild(_joinlimit_editbox)
    self._limitEdit = _joinlimit_editbox
end

function BangPaiCreate:getButtonNode(_path)
	local _node = ccui.Scale9Sprite:create(cc.rect(64,34.5,1,1),_path)
	_node:setContentSize(cc.size(332,68))
	return _node
end

function BangPaiCreate:httpToDoGuild( ... )
	local nameStr = self._guildNameEdit:getText()
	if nameStr == nil or string.len(nameStr) < 1 then
        XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildNameCannotNoneToastXc)------"查找信息不可为空！")
        return
    end
    local levelStr = tonumber(self._limitEdit:getText()) or 1
    levelStr = levelStr < 0 and 0 or levelStr
    local pTb = {icon = self._nowSelectIcon, name = nameStr, limitLevel = levelStr} 
    if self._guildData then
    	ClientHttp.httpModifyGuildBase( self, function ( sData )
	    	self:hide()
            XTHDTOAST(LANGUAGE_TIPS_WORDS227)
			gameUser.setGuildName(sData.guildName)
			gameUser.setIngot(sData.ingot)
            self._guildData.guildName = sData.guildName
            self._guildData.icon = self._nowSelectIcon
            self._guildData.limitLevel = levelStr
            BangPaiFengZhuangShuJu.setGuildData(self._guildData)
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_INFO})
            --刷新界面数据
	    end, pTb) 
    else
	    ClientHttp.httpCreateGuild( self, function ( sData )
	    	self:hide()
			gameUser.setGuildId(sData.guildId)
			gameUser.setGuildRole(sData.guildRole)
			gameUser.setGuildName(sData.guildName)
			gameUser.setIngot(sData.ingot)
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
			BangPaiFengZhuangShuJu.createGuildLayer({parNode = self, callBack = function ( ... )
				LayerManager.removeLayout()
			end})
	    end, pTb)
	end
end

function BangPaiCreate:createOne( sParams ) -- {BangPaiFengZhuangShuJu}
	local params = {
		size = cc.size(354, 430),
		titleNode = cc.Sprite:create("res/image/guild/guildTitleText_createGuild.png"),
	}
	local pLay = BangPaiCreate.new( params )
	pLay:init(sParams)
	LayerManager.addLayout(pLay,{noHide = true})
	return pLay
end

return BangPaiCreate