-- FileName: HaoYouInfoPop.lua
-- Author: wangming
-- Date: 2015-09-14
-- Purpose: 好友信息界面
--[[TODO List]]
local HaoYouInfoPop = class( "HaoYouInfoPop", function ( sParams )
    return requires("src/fsgl/layer/HaoYou/HaoYouBasePop.lua"):createOne(sParams)
end)

function HaoYouInfoPop:create( sNode, sParams)
	local params = sParams or {}
	local isFriend = params.isFriend
	if isFriend then
		params.size = cc.size(480, 340)
	else
		params.size = cc.size(480, 280)
	end
	
	local layer = LayerManager.getCurRoot()
	if layer:getChildByName("HaoYouInfoPop") then
		layer:getChildByName("HaoYouInfoPop"):hide()
	end
	local pLay = HaoYouInfoPop.new(sParams)
	pLay:setName("HaoYouInfoPop")
	pLay:init(params.zorder)
	LayerManager.addLayout(pLay, {noHide = true, zorder = params.zorder})
end

function HaoYouInfoPop:init( sZorder )
	self._zorder = sZorder
	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()
	
	local data = self._params.data

	local icon = HaoYouPublic.getFriendIcon(data, {notShowLv = true})
	icon:setAnchorPoint(0,0.5)
	icon:setPosition(55, _worldSize.height - 65)
	popNode:addChild(icon)

	local _ttfX = icon:getPositionX() + icon:getContentSize().width - 5
    local _nameString = data.charName
    local _nameTTF = XTHDLabel:createWithSystemFont(_nameString, "Helvetica", 18)
    _nameTTF:setColor(XTHD.resource.color.brown_desc)
    _nameTTF:setAnchorPoint(0, 0.5)
    _nameTTF:setPosition(_ttfX , _worldSize.height - 40)
	popNode:addChild(_nameTTF)

	local level = data.level or 1
	local _infoString = LANGUAGE_KEY_PLAYER_LEVEL(level)------"级"
    local _flowTTF = XTHDLabel:createWithParams({
    	text = _infoString,
    	fontSize = 18,
    	color = cc.c3b(131, 76, 52),
    })
    _flowTTF:setAnchorPoint(0, 0.5)
    _flowTTF:setPosition(_ttfX , _worldSize.height - 68)
	popNode:addChild(_flowTTF)

	--vip等级
	if data.vipLevel  then
		local vip_sp_res = string.format("res/image/vip/vipl_0%d.png",data.vipLevel ) --"res/image/vip/vipl_000" .. tonumber( data.vipLevel ) .. ".png"
		local vip_sp = cc.Sprite:create(vip_sp_res)
		vip_sp:setAnchorPoint(0,0.5)
		vip_sp:setScale(0.35)
		popNode:addChild(vip_sp)
		vip_sp:setPosition(_ttfX - 2,_worldSize.height - 92)
	end
    -- 徽章
    local _duan = tonumber(data.duan) or 0
    local teamBadge = cc.Sprite:create("res/image/common/rank_icon/rankIcon_".._duan..".png")
    teamBadge:setAnchorPoint(cc.p(1,0.5))
    teamBadge:setPosition(_worldSize.width - 55, icon:getPositionY())
    popNode:addChild(teamBadge)


    local _line = cc.Sprite:create("res/image/friends/friendPic_12.png")
    _line:setPosition(cc.p(_worldSize.width*0.5, icon:getPositionY() - 60))
    popNode:addChild(_line)

    local _flowerTip = XTHDLabel:createWithParams({
    	text = LANGUAGE_KEY_RECIVEFLOWERS..":",------收到鲜花 : ",
    	fontSize = 22,
    	color = XTHD.resource.color.brown_desc,
    })
    _flowerTip:setAnchorPoint(0, 0.5)
    _flowerTip:setPosition(_ttfX + 10 , _line:getPositionY() - 25)
	popNode:addChild(_flowerTip)

	local _flowerStr = tonumber(data.flower) or 0
	local _duoString = LANGUAGE_KEY_FLOWER_NUM(_flowerStr)------"朵"
	local _flowerDuo = XTHDLabel:createWithParams({
    	text = _duoString,
    	fontSize = 22,
    	color = cc.c3b(131, 76, 52),
    })
    _flowerDuo:setAnchorPoint(0, 0.5)
    _flowerDuo:setPosition(_flowerTip:getPositionX() + _flowerTip:getContentSize().width, _flowerTip:getPositionY())
	popNode:addChild(_flowerDuo)

	local _powerTip = XTHDLabel:createWithParams({
    	text = LANGUAGE_NAMES.fightVim..":",------战斗力 : ",
    	fontSize = 22,
    	color = XTHD.resource.color.brown_desc,
    })
    _powerTip:setAnchorPoint(0, 0.5)
    _powerTip:setPosition(_ttfX + 10 , _line:getPositionY() - 55)
	popNode:addChild(_powerTip)

	local _powerString = tonumber(data.power) or 0
	local _powerTTF = XTHDLabel:createWithParams({
    	text = _powerString,
    	fontSize = 22,
    	color = cc.c3b(131, 76, 52),
    })
    _powerTTF:setAnchorPoint(0, 0.5)
    _powerTTF:setPosition(_powerTip:getPositionX() + _powerTip:getContentSize().width , _powerTip:getPositionY())
	popNode:addChild(_powerTTF)

    local _line2 = cc.Sprite:create("res/image/friends/friendPic_12.png")
    _line2:setPosition(cc.p(_worldSize.width*0.5, _line:getPositionY() - 80))
    popNode:addChild(_line2)

	if self._params.isFriend then
		local pY = 30
		local par1 = 0.27
		local par2 = 0.72
		local tb = {isGreen = true, tipImg = "friendPic_41.png", ttfImg = LANGUAGE_TIPS_FRIENDINFO_CHAKAN, scale = cc.p(1.4,1)}
		tb.pos = cc.p(_worldSize.width*par1, _line2:getPositionY() - pY -5)
		tb.par = popNode
		tb.callFn = function ( ... )
			-- XTHDTOAST(LANGUAGE_TIPS_WORDS11)-------"该功能暂未开启，敬请期待！")
			-- return
			HaoYouPublic.httpLookFriendInfo(self, data.charId, function( sData )
				--添加好友信息的界面显示
				self:turnToPlayerInfoLayer(sData)
			end)
		end
		self:createBtn(tb)

		tb.tipImg = "friendPic_24.png"
		tb.ttfImg = LANGUAGE_TIPS_FRIENDINFO_HELP
		tb.callFn = function ( ... )
			if not HaoYouPublic.isFriend(data.charId) then
				XTHDTOAST(LANGUAGE_TIPS_WORDS82)------"该玩家已不是好友！")
				return
			end
			XTHDTOAST(LANGUAGE_TIPS_WORDS11)------"该功能暂未开启，敬请期待！")
			return
		end
		tb.pos = cc.p(_worldSize.width*par2, _line2:getPositionY() - pY - 5)
		self:createBtn(tb)

		tb.isGreen = false
		tb.tipImg = "friendPic_29.png"
		tb.ttfImg = LANGUAGE_TIPS_FRIENDINFO_QIECHUO
		tb.callFn = function ( ... )
			requires("src/fsgl/layer/HaoYou/HaoYouDeletePop.lua"):create(self:getParent(), {isFight = true, data = data, zorder = self._zorder})
		end
		tb.pos = cc.p(_worldSize.width*par1, _line2:getPositionY() - pY*2.5 - 5)
		self:createBtn(tb)


		tb.tipImg = "friendPic_16.png"
		tb.ttfImg = LANGUAGE_TIPS_FRIENDINFO_DELETE
		tb.pos = cc.p(_worldSize.width*par2, _line2:getPositionY() - pY*2.5 - 5)
		tb.callFn = function ( ... )
			if not HaoYouPublic.isFriend(data.charId) then
				XTHDTOAST(LANGUAGE_TIPS_WORDS82)------"该玩家已不是好友！")
				return
			end
			self:hide()
			requires("src/fsgl/layer/HaoYou/HaoYouDeletePop.lua"):create(self:getParent(), {data = data, zorder = self._zorder})
			
		end
		self:createBtn(tb)
	else
		local pY = 30
		local isSend = false
		local tb = {isGreen = true, tipImg = "friendPic_49.png", ttfImg = LANGUAGE_TIPS_FRIENDINFO_ADD,scale = cc.p(1.4,1)}
		tb.pos = cc.p(_worldSize.width*0.18, _line2:getPositionY() - pY)
		tb.par = popNode
		tb.callFn = function ( ... )
			if HaoYouPublic.isFriend(data.charId) then
				XTHDTOAST(LANGUAGE_TIPS_WORDS83)-----"已与该玩家是好友关系！")
				return
			end
			if isSend then
				XTHDTOAST(LANGUAGE_KEY_HASBEGGED)------"已发送请求！")
				return
			end
			ClientHttp:httpAddRequest( self, function ( data )
				isSend = true
	        	XTHDTOAST(LANGUAGE_KEY_SENDBEGSUCCESS)-----"发送请求成功！")
			end, {charId = data.charId})
			return
		end
		self:createBtn(tb)

		tb.tipImg = "friendPic_41.png"
		tb.ttfImg = LANGUAGE_TIPS_FRIENDINFO_CHAKAN
		tb.pos = cc.p(_worldSize.width*0.5, _line2:getPositionY() - pY)
		tb.callFn = function ( ... )
			-- XTHDTOAST(LANGUAGE_TIPS_WORDS11)-----"该功能暂未开启，敬请期待！")
			-- return
			HaoYouPublic.httpLookFriendInfo(self, data.charId, function( sData )
				--添加好友信息的界面显示
				self:turnToPlayerInfoLayer(sData)
			end)
		end
		self:createBtn(tb)

		tb.isGreen = false
		tb.tipImg = "friendPic_29.png"
		tb.ttfImg = LANGUAGE_TIPS_FRIENDINFO_QIECHUO
		tb.callFn = function ( ... )
			requires("src/fsgl/layer/HaoYou/HaoYouDeletePop.lua"):create(self:getParent(), {isFight = true, data = data, zorder = self._zorder})
		end
		tb.pos = cc.p(_worldSize.width*0.82, _line2:getPositionY() - pY)
		self:createBtn(tb)
	end
end

function HaoYouInfoPop:turnToPlayerInfoLayer(_data)
	LayerManager.addShieldLayout()
	local _infolayer = requires("src/fsgl/layer/HaoYou/ChaKanOtherPlayerInfoLayer.lua"):create(_data)
	LayerManager.addLayout(_infolayer, {zorder = self._zorder})
end

function HaoYouInfoPop:createBtn( params )
	local isGreen = params.isGreen
	local tipImg = "res/image/friends/"..params.tipImg
	local ttfImg = params.ttfImg
	local pScale = params.scale or cc.p(1,1)
	local callFn = params.callFn

	local file1 = isGreen and "write" or "write_1"

	local sp1 = cc.Sprite:create(file1)
	local _touchSize = cc.size(130*pScale.x, 46)
	local _btn = XTHD.createCommonButton({
		btnColor = file1,
		btnSize = _touchSize,
		isScrollView = false,
		text = ttfImg,
		fontSize = 28,
		musicFile = XTHD.resource.music.effect_btn_common,
		needSwallow = true,
		touchSize = _touchSize,
		endCallback = function ( ... )
			if callFn then
				callFn()
			end
		end
	})
	_btn:setScale(0.6)
	--按钮伤的文字
	-- local an_label = XTHDLabel:create(ttfImg,20)
	-- an_label:setPosition(_btn:getContentSize().width/2,_btn:getContentSize().height/2)
	-- _btn:addChild(an_label)

	

	local node = cc.Node:create()
	node:setContentSize(_touchSize)

	-- local imgTip = cc.Sprite:create(tipImg)
	-- imgTip:setAnchorPoint(0,0.5)
	-- node:addChild(imgTip)
	-- imgTip:setOpacity(0)

	local imgTTF = _btn:getLabel()
	imgTTF:setAnchorPoint(0.5,0.5)
	-- node:addChild(imgTTF)

	local _y = node:getContentSize().height*0.5
	local _x = node:getContentSize().width*0.5
	-- imgTip:setPosition(cc.p(_x+5, _y+5))
	imgTTF:setPosition(cc.p(_x-10, _y+16))

	_btn:setPosition(params.pos)
	params.par:addChild(_btn)
	node:setAnchorPoint(_btn:getAnchorPoint())
	node:setPosition(params.pos)
	params.par:addChild(node)

	return _btn, node
end


return HaoYouInfoPop