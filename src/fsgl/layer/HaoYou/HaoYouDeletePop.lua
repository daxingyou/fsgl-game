-- FileName: HaoYouDeletePop.lua
-- Author: wangming
-- Date: 2015-09-14
-- Purpose: 删除好友界面
--[[TODO List]]
local HaoYouDeletePop = class( "HaoYouDeletePop", function ( sParams )
    return requires("src/fsgl/layer/HaoYou/HaoYouBasePop.lua"):createOne(sParams)
end)

function HaoYouDeletePop:create( sNode, sParams)
	local params = sParams or {}
	params.size = cc.size(480, 270)

	local function createLayer( )
		local _isShowBlack = true
		if params.isFight then
			local _num = HaoYouPublic.getRaceTime()
			if _num == 0 then
				XTHDTOAST(LANGUAGE_TIPS_WORDS80)------"今日切磋次数已用完！")
				return
			end
			_isShowBlack = false
		end
		sParams.isShowBlack = _isShowBlack
		local pLay = HaoYouDeletePop.new(params)
		pLay:init()
		LayerManager.addLayout(pLay, {noHide = true, zorder = params.zorder})
		-- sNode:addChild(pLay, 5)
	end

	local pData = HaoYouPublic.getFriendData()
	if not pData then
		HaoYouPublic.httpGetFriendData( sNode, createLayer)
	else
		createLayer()
	end	
end

function HaoYouDeletePop:init( ... )
	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()
	
	local data = self._params.data
	local _isFight = self._params.isFight

	local _str = LANGUAGE_TIPS_WORDS81------"是否删除该好友？"
	if _isFight then
		_str = LANGUAGE_FORMAT_TIPS13(HaoYouPublic.getRaceTime())----"今天还可以切磋" .. HaoYouPublic.getRaceTime() .. "次，是否开始切磋？"
	end

    local _tips = XTHDLabel:createWithParams({
    	text = _str,
    	fontSize = 22,
    	color = XTHD.resource.color.brown_desc,
    })
    _tips:setAnchorPoint(0.5, 0.5)
    _tips:setPosition(_worldSize.width*0.5, _worldSize.height - 40)
	popNode:addChild(_tips)

	local _line = cc.Sprite:create("res/image/friends/friendPic_12.png")
    _line:setPosition(cc.p(_worldSize.width*0.5, _tips:getPositionY() - 30))
    popNode:addChild(_line)

    local sData = self._params.data
	local icon = HaoYouPublic.getFriendIcon(sData, {notShowLv = true})
	icon:setAnchorPoint(0,0.5)
	icon:setPosition(_worldSize.width*0.5 - icon:getContentSize().width * 0.5, _line:getPositionY() - 55)
	popNode:addChild(icon)

	local _ttfX = icon:getPositionX() + icon:getContentSize().width - 5
    local _nameString = sData.charName
    local _nameTTF = XTHDLabel:createWithSystemFont(_nameString, "Helvetica", 18)
    _nameTTF:setColor(XTHD.resource.color.brown_desc)
    _nameTTF:setAnchorPoint(0, 0.5)
    _nameTTF:setPosition(_ttfX , icon:getPositionY() + 15)
	popNode:addChild(_nameTTF)

	local level = sData.level or 1
	local _infoString = LANGUAGE_KEY_PLAYER_LEVEL(level)---------lang"级"
    local _flowTTF = XTHDLabel:createWithParams({
    	text = _infoString,
    	fontSize = 18,
    	color = cc.c3b(131, 76, 52),
    })
    _flowTTF:setAnchorPoint(0, 0.5)
    _flowTTF:setPosition(_ttfX , icon:getPositionY() - 15)
	popNode:addChild(_flowTTF)


	local _line2 = cc.Sprite:create("res/image/friends/friendPic_12.png")
    _line2:setPosition(cc.p(_worldSize.width*0.5, icon:getPositionY() - 60))
    popNode:addChild(_line2)


	local _btnDo = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		text = LANGUAGE_KEY_CANCEL,
		fontSize = 28,
		musicFile = XTHD.resource.music.effect_btn_common,
		needSwallow = true,
		endCallback = function ( ... )
			self:hide()
		end
	})
	_btnDo:setScale(0.5)
	_btnDo:setPosition(cc.p(_worldSize.width*0.3, _line2:getPositionY() - 40))
	popNode:addChild(_btnDo)

	local _btnClose = XTHD.createCommonButton({
		btnColor = "write",
		isScrollView = false,
		text = LANGUAGE_KEY_SURE,
		fontSize = 28,
		musicFile = XTHD.resource.music.effect_btn_common,
		needSwallow = true,
		endCallback = function ( ... )
			local str = "delRelation?"
			if _isFight then
				str = "friendRace?"
				ClientHttp:httpFriendRace( self, function ( data )
					local challageData = data.rivals
	        		LayerManager.addShieldLayout()
                    local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")
                    local _layerHandler = SelHeroLayer:create(BattleType.PVP_FRIEND, nil, challageData)
		        	self:hide()
                    fnMyPushScene(_layerHandler)
				end, {charId = sData.charId})
			else
				ClientHttp:httpDelRelation( self, function ( data )
					HaoYouPublic.removeData(sData)
		        	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FRIEND_ADDLIST})
		        	self:hide()
				end, {charId = sData.charId})
			end
		end
	})
	_btnClose:setScale(0.5)
	_btnClose:setPosition(cc.p(_worldSize.width*0.7, _line2:getPositionY() - 40))
	popNode:addChild(_btnClose)

end


return HaoYouDeletePop