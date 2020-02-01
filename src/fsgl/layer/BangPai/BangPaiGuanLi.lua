-- FileName: BangPaiGuanLi.lua
-- Author: wangming
-- Date: 2015-10-19
-- Purpose: 玩家所属帮派界面
--[[TODO List]]

local BangPaiGuanLi = class("BangPaiGuanLi", function ( sParams ) 
	local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(cc.size(420,435))
	return node
end)

function BangPaiGuanLi:ctor( sParams )
	self:init()
end

function BangPaiGuanLi:init( sParams )
	local popNode = self._popNode
	local _worldSize = self:getContentSize()
	local mParams = sParams or {}
	self._params = BangPaiFengZhuangShuJu.getGuildData()
	local _rootFiles = {
		{"guildImgText_infoExchange.png","guildImgText_appointment.png"},
		{"guildImText_recruit.png","guildImgText_titleExchange.png"},
		{"guildImgText_abdicate.png","guildImgText_dissolveGuild.png"},
	}

	--文字
	local wenzi = {{"资料修改","职位调整"},{"招贤纳士","帮派红包"},{"移交帮主","解散帮派"}}
	local _rootInfo = gameData.getDataFromCSV("SectPosition", {id = gameUser.getGuildRole()})
	local _rootCan = {
		{_rootInfo.right5, _rootInfo.right6},
		{_rootInfo.right1, _rootInfo.right2},
		{_rootInfo.right8, _rootInfo.right9},
	}

	_rootCan[1][1] = _rootInfo.right5
	_rootCan[1][2] = _rootInfo.right5
	for i=1, 3 do
		for j=1, 2 do
			local pCan = _rootCan[i][j] == 1
			local btn = self:getButtonNode(_rootFiles[i][j], wenzi[i][j],pCan, function ( ... )
				if not pCan then
					XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildNoPermissionToFunctionToastXc)
					return
				end
				if i == 1 and j == 1 then--修改信息
				    requires("src/fsgl/layer/BangPai/BangPaiCreate.lua"):createOne({guildData = sParams})
				elseif i == 1 and j == 2 then--人事任命
					local _fuData = {}
					local pMy = gameUser.getGuildRole()
					if self._params.list and #self._params.list > 0 then
						for k,v in pairs(self._params.list) do
							if v.roleId > pMy then
								_fuData[#_fuData + 1] = v
							end
						end
					end
					if #_fuData == 0 then
						XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildNoneCanOperateMemberToastXc)
						return
					end
					-- local _fuData = self._params.list
				    requires("src/fsgl/layer/BangPai/BangPaiRenShiRenMing.lua"):createOne(_fuData)
			    elseif i == 2 and j == 1 then--招贤纳士
			    	if (os.time() - lastGuideRecuritTime) <= 180 then
			    	     XTHDTOAST(tostring(180 - (os.time() - lastGuideRecuritTime)).."秒后才能再次发布信息")
			    	else
                         self:guildRecruit()
			    	end
				elseif i == 2 and j == 2 then--帮派红包
					XTHDTOAST(LANGUAGE_TIPS_WORDS11)
				elseif i == 3 and j == 1 then--退位
					local _fuData = {}
					if self._params.list and #self._params.list > 0 then
						for k,v in pairs(self._params.list) do
							if v.roleId == 2 then
								_fuData[#_fuData + 1] = v
							end
						end
					end
					if #_fuData == 0 then
						XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildNoInheritorToastXc)
						return
					end
				    requires("src/fsgl/layer/BangPai/BangZhuTuiWei.lua"):createOne(_fuData)
				elseif i == 3 and j == 2 then--解散
					self:createEixtConfirm()
				end
			end)
   			local pX = -1
   			if j == 2 then
				pX = 1
			end
			local x = (j-1) *(btn:getContentSize().width - 30) + btn:getContentSize().width *0.5 - 10
			local y = self:getContentSize().height - ((i-1) *(btn:getContentSize().height) + btn:getContentSize().height *0.5 + 10 )
			btn:setScale(0.8)
			btn:setPosition(x,y)
			self:addChild(btn)
		end
	end
end

--招贤纳士
function BangPaiGuanLi:guildRecruit()
	ClientHttp:requestAsyncInGameWithParams({
        modules="guildRecruit?",
        successCallback = function( data )
            -- print("招贤纳士服务器返回的数据为：")
            -- print_r(data)
            if tonumber( data.result ) == 0 then
                --刷新挂机信息
                if data.property and #data.property > 0 then
                    for i=1,#data.property do
                        local pro_data = string.split( data.property[i],',')
                        --如果奖励类型存在，而且不是vip升级(406)则加入奖励
                        print(XTHD.resource.propertyToType[tonumber(pro_data[1])])
                        DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
                    end
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})        --刷新数据信息
                end
                lastGuideRecuritTime = os.time()
                XTHDTOAST("消息发布成功")
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    })  
end

function BangPaiGuanLi:getButtonNode( _path,wenzipath,isCan, callBack)
	local _size = cc.size(235, 90)
	local _guildBg = ccui.Scale9Sprite:create(cc.rect(0,0,0,0),"res/image/common/select_bg_110.png")
	_guildBg:setContentSize(_size)
	if not isCan then
		XTHD.setGray(_guildBg)
	end
	local _btn = XTHD.createPushButtonWithSound({
		normalNode = _guildBg,
		touchScale = 0.95,
		needSwallow = false,
		endCallback = callBack
	})

	local _guildIcon1 = cc.Sprite:create("res/image/guild/" .. _path)
	_guildIcon1:setAnchorPoint(0.5, 0.5)
	_guildIcon1:setPosition(_size.width*0.2+5, _size.height*0.5)
	--文字
	local bp_label = XTHDLabel:create(wenzipath,30,"res/fonts/hwzs.ttf")
	bp_label:setPosition(_btn:getContentSize().width/2+40,_btn:getContentSize().height/2)
	bp_label:setColor(cc.c3b(106, 9, 34))
	--bp_label:enableOutline(cc.c4b(45,13,103,255),2)
	_btn:addChild(bp_label)
	_guildIcon1:setScale(0.8)
	_btn:addChild(_guildIcon1)
	if not isCan then
		XTHD.setGray(_guildIcon1)
	end
	return _btn
end

function BangPaiGuanLi:createEixtConfirm()
	local show_msg = LANGUAGE_KEY_GUILD_TEXT.guildWantToDissolveTextXc
    local confirmDialog = XTHDConfirmDialog:createWithParams({
    	msg = show_msg,
    	fontSize = 22,
    	isHide = false
	})
    cc.Director:getInstance():getRunningScene():addChild(confirmDialog, 10)
   	
   	local pLable = XTHDLabel:createWithParams({
   		text = LANGUAGE_KEY_GUILD_TEXT.guildNeedNoneMemberTextXc,
   		fontSize = 18,
   		color = cc.c3b(128, 112, 91),
   		pos = cc.p(confirmDialog.containerBg:getContentSize().width*0.5, confirmDialog.containerBg:getContentSize().height*0.5), 
	})
	confirmDialog.containerBg:addChild(pLable)

    confirmDialog:setCallbackRight(function (  )
    	if #self._params.list > 1 then
			XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildCannotDissolveToastXc)
			return
		end
        confirmDialog:removeFromParent()
		self:createEixtConfirm2()
    end)

    confirmDialog:setCallbackLeft(function (  )
        confirmDialog:removeFromParent()
    end)
end

function BangPaiGuanLi:createEixtConfirm2()
	local show_msg = LANGUAGE_KEY_GUILD_TEXT.guildSureToDissolveTextXc
    local confirmDialog = XTHDConfirmDialog:createWithParams({
    	msg = show_msg,
    	isHide = false,
    	fontSize = 22
	})
    cc.Director:getInstance():getRunningScene():addChild(confirmDialog, 10)
   	
   	local pLable = XTHDLabel:createWithParams({
   		text = LANGUAGE_KEY_GUILD_TEXT.guildOpareteCannotBackToSureTextXc	,
   		fontSize = 18,
   		color = cc.c3b(204, 2, 2),
   		pos = cc.p(confirmDialog.containerBg:getContentSize().width*0.5, confirmDialog.containerBg:getContentSize().height*0.5), 
	})
	confirmDialog.containerBg:addChild(pLable)

    confirmDialog:setCallbackRight(function (  )
    	ClientHttp.httpDissolveGuild(self, function ( sData )
			gameUser.setGuildId(0)
			gameUser.setGuildRole(0)
			gameUser.setGuildName("")
			LayerManager.addShieldLayout()
    		BangPaiFengZhuangShuJu.createGuildLayer({parNode = self, callBack = function ( ... )
				LayerManager.removeLayout()
				XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildIsDissolvedTextXc)
			end})
    	end)
    	confirmDialog:removeFromParent()
    end)

    confirmDialog:setCallbackLeft(function (  )
        confirmDialog:removeFromParent()
    end)
end

function BangPaiGuanLi:create( sParams )
	local pLay = BangPaiGuanLi.new( params )
	return pLay
end

return BangPaiGuanLi