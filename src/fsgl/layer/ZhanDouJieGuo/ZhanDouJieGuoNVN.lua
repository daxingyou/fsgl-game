-- FileName: ZhanDouJieGuoNVN.lua
-- Author: wangming
-- Date: 2015-10-26
-- Purpose: NVP战斗结果页面
--[[TODO List]]

local ZhanDouJieGuoNVN = class("ZhanDouJieGuoNVN",function ( )
	return XTHDDialog:create()
end)

function ZhanDouJieGuoNVN:ctor(params, _battle_type)
	self._battleData = params 

	local isWin = 1
	if _battle_type == BattleType.PVP_SHURA then
		isWin = tonumber(self._battleData.isWin) or 0
	elseif _battle_type == BattleType.PVP_GUILDFIGHT then
		isWin = tonumber(self._battleData.attackResult) or 0
	end

	local background = cc.Sprite:create("res/image/tmpbattle/battle_result_bg.png")
	background:setName("background")
	background:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
	self:addChild(background)
	local _bgSize = background:getContentSize()
    local function getBtnNode(imgpath,_size,_rect)
        local btn_node = ccui.Scale9Sprite:create(_rect,imgpath)
        btn_node:setContentSize(_size)
        btn_node:setCascadeOpacityEnabled(true)
        btn_node:setCascadeColorEnabled(true)
        return btn_node
    end

	local backbtn = XTHD.createCommonButton({
		btnSize = cc.size(142,49),
		isScrollView = false,
        text = LANGUAGE_KEY_SURE,
        fontSize = 22,
		anchor = cc.p(1, 0),
        pos = cc.p(_bgSize.width - 65, 10),
        endCallback = function ( ... )
        	if self._battleData.backCallback then
        		self._battleData.backCallback()
        	end
        end
	})
	backbtn:setScale(0.8)
    background:addChild(backbtn)

	local _size = cc.size(_bgSize.width, 280)
    local scrollView = ccui.ScrollView:create()
    scrollView:setAnchorPoint(0.5, 0.5)
    scrollView:setTouchEnabled(true)
    scrollView:setBounceEnabled(true)
    scrollView:setContentSize(_size)
    scrollView:setPosition(cc.p(_bgSize.width*0.5, _bgSize.height*0.5))
    background:addChild(scrollView)
	scrollView:setScrollBarEnabled(false)

    local pCount = 0
    local _height = 0
	if _battle_type == BattleType.PVP_SHURA then
		self._battleData.data = self._battleData.data or {}
		pCount = #self._battleData.data
		local _leftData, pNode
		_height = 500
		local _lastY = _height
		for i = 1, pCount do
			_data = self._battleData.data[i]
			local pLeftInfos = {}
			local _ids = string.split(_data.leftId, ",")
			local _levels = string.split(_data.leftLevel, ",")
			for j=1,#_ids do
				pLeftInfos[#pLeftInfos + 1] = {level = tonumber(_levels[j]), petId = tonumber(_ids[j])} 
			end
			local pRightInfos = {}
			_ids = string.split(_data.rightId, ",")
			_levels = string.split(_data.rightLevel, ",")
			for j=1,#_ids do
				pRightInfos[#pRightInfos + 1] = {level = tonumber(_levels[j]), petId = tonumber(_ids[j])} 
			end
			local _info = {
			    result = tonumber(_data.result),
			    leftInfos = pLeftInfos,
			    rightInfos = pRightInfos,
		    }
			pNode = createOneFightInfoForLRInfos(_info)
			local _height = 50
			if i == 2 then
				_height = 150
			elseif i == 3 then
				_height = 200
			end
			_lastY = _lastY - _height
			pNode:setPosition(_bgSize.width*0.5, _lastY)
			scrollView:addChild(pNode)
		end
	elseif _battle_type == BattleType.PVP_GUILDFIGHT then
		self._battleData.list = self._battleData.list or {}
		local _data
		pCount = #self._battleData.list
		_height = 100*pCount
		for i=1, pCount do
			_data = self._battleData.list[i]
			local pInfo = {
				leftId = _data.attackTemplateId, 
				leftLevel = _data.aLevel, 
				leftName = _data.attackName, 
				rightId = _data.defendTemplateId, 
				rightLevel = _data.bLevel, 
				rightName = _data.defendName, 
				result = _data.result,
				attackLore = _data.attackLore,
				defendLore = _data.defendLore,
				teamId = _data.teamId,
			}
			pNode = createOneFightInfo(pInfo)
			pNode:setPosition(cc.p(_bgSize.width*0.5, (pCount-(i-1))*100 - 50))
			scrollView:addChild(pNode)
		end
	end
	if _height > scrollView:getInnerContainerSize().height then
		scrollView:setInnerContainerSize(cc.size(_bgSize.width, _height))
	end

	local effVoice
	local effTitle
	if isWin == BATTLE_RESULT.WIN  then--成功
		effVoice = XTHD.resource.music.effect_battle_victory
		-- effTitle = sp.SkeletonAnimation:create( "res/spine/effect/battle_win/shengli.json", "res/spine/effect/battle_win/shengli.atlas",1.0)
		-- effTitle:setAnimation(0,"4",false)
		-- performWithDelay(effTitle, function( ... )
		-- 	effTitle:setAnimation(0,"4_4",true)
		-- end, 2.0)
	--新特效
	effTitle = sp.SkeletonAnimation:create( "res/spine/effect/battle_win/shengli_01.json", "res/spine/effect/battle_win/shengli_01.atlas",1.0)
	effTitle:setAnimation(0,"shengli_01",false)
	effTitle:setScale(0.6)
   
    elseif isWin == BATTLE_RESULT.FAIL  then--失败
    	effVoice = XTHD.resource.music.effect_battle_lost
		effTitle = cc.Sprite:create("res/image/tmpbattle/result_faild.png")
    elseif isWin == BATTLE_RESULT.TIMEOUT  then--超时
    	effVoice = XTHD.resource.music.effect_battle_lost
		effTitle = cc.Sprite:create("res/image/guild/guildWar/guildWar_evenSp.png")
    end
    if effVoice then
        musicManager.playEffect(effVoice, false)
    end
	if effTitle then
		if isWin == BATTLE_RESULT.WIN then
			effTitle:setPosition(_bgSize.width*0.5, _bgSize.height-140)
			background:addChild(effTitle)
		else
			effTitle:setPosition(_bgSize.width*0.5, _bgSize.height-40)
			background:addChild(effTitle)
		end
	end

	if _battle_type == BattleType.PVP_SHURA then
		if self._battleData.winsPointsAdd and self._battleData.asuraBloodAdd then
			local pStr = LANGUAGE_TIP_GET_ARENA_POINTS(self._battleData.winsPointsAdd, self._battleData.asuraBloodAdd)
			local _leftName = XTHDLabel:createWithSystemFont(pStr, "Helvetica", 20)
		    _leftName:setColor(XTHD.resource.color.white_desc)
		    _leftName:setAnchorPoint(cc.p(0, 0))
		    _leftName:setPosition(cc.p(200 , 20))
		    background:addChild(_leftName)	   
		end
		if self._battleData.winsPointsGmg and self._battleData.winsPointsAyl then
			XTHD.dispatchEvent({
				name = CUSTOM_EVENT.REFRESH_WIN_POINT,
				data = {Gmg = self._battleData.winsPointsGmg, Ayl = self._battleData.winsPointsAyl}
			})
	    end
	    if self._battleData.asuraBlood then
		    gameUser.setAsura(self._battleData.asuraBlood)
	    end
	elseif _battle_type == BattleType.PVP_GUILDFIGHT then
		if self._battleData.addJifen then
			local pStr = LANGUAGE_TIP_GET_POINTS(self._battleData.addJifen)
			local _leftName = XTHDLabel:createWithSystemFont(pStr, "Helvetica", 20)
		    _leftName:setColor(XTHD.resource.color.white_desc)
		    _leftName:setAnchorPoint(cc.p(0, 0))
		    _leftName:setPosition(cc.p(200 , 20))
		    background:addChild(_leftName)	   
		end
	end

    musicManager.stopBackgroundMusic()
end

function ZhanDouJieGuoNVN:onCleanup()
    musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_main,true)
end

function ZhanDouJieGuoNVN:create(params, _battle_type)
	return ZhanDouJieGuoNVN.new(params, _battle_type)
end

return ZhanDouJieGuoNVN