-- FileName: HaoYouSendPop.lua
-- Author: wangming
-- Date: 2015-09-14
-- Purpose: 好友赠送界面
--[[TODO List]]
local HaoYouSendPop = class( "HaoYouSendPop", function ( sParams )
    return requires("src/fsgl/layer/HaoYou/HaoYouBasePop.lua"):createOne(sParams)
end)

function HaoYouSendPop:create( sNode, tarDat)
	local function goCreate( sData )
		local params = {title = LANGUAGE_KEY_SENDFLOWER, size = cc.size(540, 330)}
		local pLay = HaoYouSendPop.new(params)
		pLay:init(tarDat, sData)
		LayerManager.addLayout(pLay, {noHide = true})
	end
	ClientHttp:httpFriendSendFlowerState(sNode, goCreate, {charId = tarDat.charId})
end

function HaoYouSendPop:init( sData, stateInfo )
	
	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()
	local _data = sData
	self._stateInfo = stateInfo.list
	self.title:setPositionY(self.title:getPositionY()+20)
	self.title:setColor(cc.c3b(152,22,22))
	self.title:setFontSize(28)

	local picTb = {"res/image/friends/friendPic_","",".png"}
	local picPos = {0.18,0.5,0.82}
	local picFiles = {
		{"58","68"},
		{"61","69"},
		{"63","70"},
	}

	local function freshState( node )
		for i=1,3 do
			local canUse = self:getCanSend(i)
			local pIcon = popNode:getChildByName("send"..i)
			if pIcon then 
				local tipSp = pIcon:getChildByName("sendTag")
				if not tipSp then
					tipSp = cc.Sprite:create("res/image/friends/friendPic_86.png")
					tipSp:setPosition(cc.p(pIcon:getContentSize().width*0.5, pIcon:getContentSize().height*0.5))
					pIcon:addChild(tipSp)
				end
				tipSp:setVisible(not canUse)
			end
		end
	end

	local function sendFlower( sType )

		ClientHttp:httpSendFlower( self, function( data )
			local _ingot = data.ingot
        	gameUser.setIngot(_ingot)
        	self._stateInfo = data.flowerState
        	local _flower = tonumber(data.flower) or 0
        	HaoYouPublic.updateFlowersById(_data.charId, _flower)
		    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
		    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
        	freshState()
        	XTHDTOAST(LANGUAGE_KEY_SENDSUCCESS)-------"赠送成功！")
		end, {charId = _data.charId, type = sType})
	end
	local zhiTab = {"1","10","100"}
	for i=1,3 do
		
		--背景图
		local bg = ccui.Scale9Sprite:create("res/image/friends/zs_bg.png")
		bg:setContentSize(cc.size(166,236))
		bg:setPosition(_worldSize.width*picPos[i], _worldSize.height*0.45)
		popNode:addChild(bg)

		--每天可送一支
		local songlabel = XTHDLabel:create("（每天可送一次）",15)
		songlabel:setColor(cc.c3b(241,233,125))
		songlabel:setPosition(_worldSize.width*picPos[i], _worldSize.height*0.25)
		popNode:addChild(songlabel)
		
		--送多少支
		local zhi = XTHDLabel:create("送" .. zhiTab[i] .. "支",22)
		zhi:setPosition(_worldSize.width*picPos[i], _worldSize.height*0.7)
		zhi:setColor(cc.c3b(100,100,255))
		popNode:addChild(zhi)

		--元宝数量
		local money = ccui.Scale9Sprite:create("res/image/friends/m" .. i .. ".png")
		money:setPosition(_worldSize.width*picPos[i], _worldSize.height*0.15+10)
		popNode:addChild(money)
		money:setScale(0.8)

		picTb[2] = picFiles[i][1]
		local file1 = table.concat(picTb)
		picTb[2] = picFiles[i][2]
		local file2 = table.concat(picTb)
		local _normalNode = cc.Sprite:create(file1)
		local _selectedNode = cc.Sprite:create(file2)
		local icon = XTHDPushButton:createWithParams({
	        normalNode = _normalNode,
	        selectedNode = _selectedNode,
	        musicFile = XTHD.resource.music.effect_btn_common,
	        needSwallow = false,
	        enable = true,
	        endCallback = function ()
		        local canUse = self:getCanSend(i)
		        if not canUse then
		        	XTHDTOAST(LANGUAGE_TIPS_WORDS86)-----"该档位今天已赠送过！")
		        	return
		        end
		        local _string = {1,10,100}
		        local _string1 = LANGUAGE_TIPS_WORDS87 -------{"本次免费","花费50元宝","花费500元宝"}
		        local _string2 = LANGUAGE_FORMAT_TIPS19(_string[i], _data.charName)------"是否赠送" .. _string[i] .. "朵鲜花给\"" .. sData.charName .. "\"，" .. _string1[i]
		        if i == 1 then
		        	sendFlower(i)
		        else
			        local _confirmLayer = XTHDConfirmDialog:createWithParams({
			            msg = _string2,
			            rightCallback = function ( ... )
					        sendFlower(i)
			            end
			        })
			        self:addChild(_confirmLayer,10)
			    end
	        	
	        end,
		})
		icon:setScale(0.7)
		icon:setPosition(_worldSize.width*picPos[i], _worldSize.height*0.45)
		-- icon:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
	    icon:setName("send"..i)
	    popNode:addChild(icon)
	end
	freshState()
end

function HaoYouSendPop:getCanSend( id )
	local pState = self._stateInfo
	if not pState then
		pState = {}
	end
	local pNum = tonumber(pState[id]) or 0
	if pNum == 1 then
		return false
	end
	return true
end


return HaoYouSendPop