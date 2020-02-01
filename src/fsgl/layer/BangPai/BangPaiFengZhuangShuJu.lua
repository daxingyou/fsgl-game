-- FileName: BangPaiFengZhuangShuJu.lua
-- Author: wangming
-- Date: 2015-10-15
-- Purpose: 帮派封装数据
--[[TODO List]]

BangPaiFengZhuangShuJu = {}

function BangPaiFengZhuangShuJu.createGuildLayer( sParams )
	--musicManager.playEffect(XTHD.resource.music.effect_bangpai_bgm,false)
	musicManager.playMusic(XTHD.resource.music.effect_bangpai_bgm )
	local isopen,data = isTheFunctionAvailable(72)----帮派
	if not isopen then 
		XTHDTOAST(data.tip)
		return 
	end  
	local parNode = sParams.parNode
	if not parNode then
        return
    end
    if gameUser.getGuildId() == 0 then --没有公会，先去公会列表
    	ClientHttp.httpGetGuildList(parNode, function( sData )
    		BangPaiFengZhuangShuJu.setGuildData(nil)
    		if sParams.callBack then
                sParams.callBack(sData)
            end
    		local pLay = LayerManager.createModule("src/fsgl/layer/BangPai/BangPaiLieBiao.lua", sData)
    		if pLay then
    			LayerManager.addLayout(pLay)
    		end
    	end)
    else -- 有公会，取自己公会信息
    	ClientHttp.httpGuildMemberList(parNode, function( sData )
    		BangPaiFengZhuangShuJu.setGuildData(sData)
    		if sParams.callBack then
                sParams.callBack(sData)
            end
    		local pLay = LayerManager.createModule("src/fsgl/layer/BangPai/BangPaiMain.lua",sData)
    		if pLay then
    			LayerManager.addLayout(pLay)
    		end
    	end)
    end
end

function BangPaiFengZhuangShuJu.getGuildData( sData )
	return BangPaiFengZhuangShuJu.data
end

function BangPaiFengZhuangShuJu.setGuildData( sData )
	BangPaiFengZhuangShuJu.data = sData
end
function BangPaiFengZhuangShuJu.addGuildListData(sData)
	if sData == nil or next(sData)==nil then
		return
	end
	if BangPaiFengZhuangShuJu.data.list == nil then
		BangPaiFengZhuangShuJu.data.list = {}
	end
	for i=1,#sData do
		BangPaiFengZhuangShuJu.data.list[#BangPaiFengZhuangShuJu.data.list + 1] = sData[i]
	end
end

-- local function httpDo( sParams )
-- 	local parNode = sParams.parNode
--     local callBack = sParams.callBack
--     local _params = sParams.params
--     local _modules = sParams.modules
--     local _failureCallback = sParams.failureCallback
--     XTHDHttp:requestAsyncInGameWithParams({
--         modules = _modules,
--         params = _params,
--         successCallback = function(data)
--             if tonumber(data.result) == 0 then
--             	if data.maxTili then--最大体力值改变
--             		gameUser.setTiliMax(data.maxTili)
--             		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
--             		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
--             	end
--                 if callBack then
--                     callBack(data)
--                 end
--             else
--                 XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
-- 			    if _failureCallback then
-- 			    	_failureCallback()
-- 			    end
--             end
--         end,--成功回调
--         failedCallback = function()
--             XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
-- 		    if _failureCallback then
-- 		    	_failureCallback()
-- 		    end
--         end,--失败回调
--         targetNeedsToRetain = parNode,--需要保存引用的目标
--         loadingParent = parNode,
--         loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
--     })
-- end

-- --帮派列表请求
-- function ClientHttp.httpGetGuildList( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
-- 	local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "guildList?",
-- 	}
-- 	httpDo(_params)
-- end

-- --创建帮派请求
-- function ClientHttp.httpCreateGuild( sParNode, sCallBack, sParams ) -- {icon, name, limitLevel}
-- 	if not sParNode then
--         return
--     end
-- 	local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "createGuild?",
-- 		params = sParams,
-- 	}
-- 	httpDo(_params)
-- end

-- --申请加入帮派
-- function ClientHttp.httpApplyJoinGuild( sParNode, sCallBack, sParams ) -- {guildId}
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "applyJoinGuild?",
-- 		params = sParams,
-- 	}
-- 	httpDo(_params)
-- end

-- --加入申请列表
-- function ClientHttp.httpApplyJoinGuildList( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "applyJoinGuildList?",
-- 	}
-- 	httpDo(_params)
-- end

-- --同意用户加入请求
-- function ClientHttp.httpAgreeGuildApply( sParNode, sCallBack, sParams ) -- {list}
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "agreeGuildApply?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end

-- --拒绝用户加入请求
-- function ClientHttp.httpRejectGuildApply( sParNode, sCallBack, sParams ) -- {list}
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "rejectGuildApply?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end

-- --帮派log列表
-- function ClientHttp.httpGuildLogList( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "guildLogList?"
-- 	}
-- 	httpDo(_params)
-- end

-- --帮派成员列表
-- function ClientHttp.httpGuildMemberList( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "guildMemberList?"
-- 	}
-- 	httpDo(_params)
-- end

-- --修改帮派公告
-- function ClientHttp.httpModifyGuildNotice( sParNode, sCallBack, sParams ) -- {content}
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "modifyGuildNotice?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end

-- --修改帮派基本信息
-- function ClientHttp.httpModifyGuildBase( sParNode, sCallBack, sParams ) -- {icon, name, limitLevel}
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "modifyGuildBase?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end

-- --退出帮派
-- function ClientHttp.httpExitGuild( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "exitGuild?",
-- 	}
-- 	httpDo(_params)
-- end

-- --帮主退位
-- function ClientHttp.httpConcessionGuild( sParNode, sCallBack, sParams ) -- {otherId}
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "concessionGuild?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end

-- --解散帮派
-- function ClientHttp.httpDissolveGuild( sParNode, sCallBack ) 
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "dissolveGuild?"
-- 	}
-- 	httpDo(_params)
-- end

-- --帮派踢人
-- function ClientHttp.httpGuildKickOff( sParNode, sCallBack, sParams ) -- {otherId}
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "guildKickOff?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end

-- --人事任命
-- function ClientHttp.httpGuildMemberAppoint( sParNode, sCallBack, sParams ) -- {otherId, roleId}
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "appointGuildMember?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end

-- --祭拜列表
-- function ClientHttp.httpGuildWorshipList( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "guildWorshipList?"
-- 	}
-- 	httpDo(_params)
-- end

-- --祭拜 
-- function ClientHttp.httpGuildWorship( sParNode, sCallBack, sParams ) -- {worshipType}
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "guildWorship?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end

-- --祭拜奖励列表
-- function ClientHttp.httpGuildWorshipListReward( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "worshipRewardList?"
-- 	}
-- 	httpDo(_params)
-- end

-- --祭拜领取奖励
-- function ClientHttp.httpGuildWorshipReward( sParNode, sCallBack, sParams )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "worshipReward?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end


-- ---------------------------------帮派战------------------------------------------
-- -- 基本信息请求
-- function ClientHttp.httpGuildBaseInfo( sParNode, sCallBack )
-- 	if not sParNode then
--         -- return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "guildBattleBase?"
-- 	}
-- 	httpDo(_params)
-- end
-- --参战 请求
-- function ClientHttp.httpGuildToBattle( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "joinGuildBattle?",
-- 	}
-- 	httpDo(_params)
-- end
-- --设置 主将 请求
-- function ClientHttp.httpGuildSetLord( sParNode, sCallBack, sParams )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "appointLord?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end
-- --主将列表 请求
-- function ClientHttp.httpGuildBattleLordList( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "lordList?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end
-- -- 帮派战队伍列表 请求
-- function ClientHttp.httpGuildBattleGroupList( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "guildBattleGroupList?",
-- 	}
-- 	httpDo(_params)
-- end
-- --切换 帮派战 队伍列表 请求
-- function ClientHttp.httpGuildChangeBattleGroupList( sParNode, sCallBack ,sParams) 
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "changeGuildBattleGroupList?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end
-- --主将 选择 预备 成员 请求
-- function ClientHttp.httpGuildChooseGroupMemberList( sParNode, sCallBack ) 
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "chooseGroupMemberList?",
-- 	}
-- 	httpDo(_params)
-- end
-- -- 设置帮派战 队伍 请求
-- function ClientHttp.httpGuildBattleGroupMember( sParNode, sCallBack, sParams,failureCallback )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "resetBattleGroupMember?",
-- 		params = sParams,
-- 		failureCallback = failureCallback
-- 	}
-- 	httpDo(_params)
-- end
-- --获取 队员自己 上阵的防守队伍  请求
-- function ClientHttp.httpGetMyGuildGroup( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "myGuildBattleGroup?",
-- 	}
-- 	httpDo(_params)
-- end
-- --设置 队员自己 上阵的防守队伍  请求
-- function ClientHttp.httpGuildSetDefenceGroup( sParNode, sCallBack, sParams )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "embattleMyGroup?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end
-- --更换 对手  请求
-- function ClientHttp.httpGuildChangeRival( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "changeGuildRival?",
-- 	}
-- 	httpDo(_params)
-- end
-- -- 调整 攻击 顺序  请求
-- function ClientHttp.httpGuildAdjustAttackSequence( sParNode, sCallBack, sParams )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "adjustAttackSequence?",
-- 		params = sParams
-- 	}
-- 	httpDo(_params)
-- end
-- -- 帮派战 一轮攻击log  请求
-- function ClientHttp.httpGuildBattleAttackLog( sParNode, sCallBack, sFailCall )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		failureCallback = sFailCall,
-- 		modules = "guildBattleAttackLog?",
-- 	}
-- 	httpDo(_params)
-- end
-- --  帮派战 记录  请求
-- function ClientHttp.httpGuildLookBattleRecord( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "lookGuildBattleRecord?",
-- 	}
-- 	httpDo(_params)
-- end
-- -- 帮派战 积分 排名  请求
-- function ClientHttp.httpGuildJifenRank( sParNode, sCallBack )
-- 	if not sParNode then
--         return
--     end
--     local _params = {
-- 		parNode = sParNode,
-- 		callBack = sCallBack,
-- 		modules = "guildJifenRank?",
-- 	}
-- 	httpDo(_params)
-- end


function BangPaiFengZhuangShuJu.getTextColor(_str)
	local _textColor = {
		hongse = cc.c4b(204,2,2,255), 							--红色
		shenhese = cc.c4b(55,54,112,255),						--深褐色，用的比较多
		lanse = cc.c4b(26,158,207,255),							--蓝色
		chenghongse = cc.c4b(205,101,8,255),					--橙红色
		zongse = cc.c4b(128,112,91,255), 						--棕色，有点深灰色的感觉
		baise = cc.c4b(255,255,255,255),                        --白色
		lvse = cc.c4b(104,157,0,255),                           --绿色
		lianghuangse = cc.c4b(255,234,0,255), 					--亮黄色
		danhuangse = cc.c4b(255,234,137,255),					--淡黄色
		juhongse = cc.c4b(244,133,80,255),						--橘红色
		juhuangse = cc.c4b(224,116,1,255), 						--橘黄色
		shenlvse = cc.c4b(40,212,48,255), 						--深绿色
		huise = cc.c4b(192,189,189,255), 						--灰色
	}
	return _textColor[_str]
end

function BangPaiFengZhuangShuJu.createGuildIcon( id )
	local Di = cc.Sprite:create("res/image/plugin/tasklayer/iconside.png")
	local _node = cc.Sprite:create("res/image/plugin/tasklayer/iconbg.png")
	_node:setAnchorPoint(cc.p(0.5, 0.5))
	if Di then
		-- _node:addChild(Di, 1)
		Di:setPosition(_node:getContentSize().width*0.5, _node:getContentSize().height*0.5)
		local res = XTHD.resource.getItemImgById(id,1)
		local pSp = cc.Sprite:create(res)
		if pSp then
			pSp:setScale(84/pSp:getContentSize().width)
			pSp:setPosition(_node:getContentSize().width*0.5, _node:getContentSize().height*0.5)
			pSp:setCascadeOpacityEnabled( false )
			_node:addChild(pSp)
			_node:setOpacity(0)
		end
	end
	return _node
end

function BangPaiFengZhuangShuJu.createGuildButton( id, callBack )
	local _guildIcon1 = BangPaiFengZhuangShuJu.createGuildIcon(id)
	local _guildIcon2 = BangPaiFengZhuangShuJu.createGuildIcon(id)
	local _guildIcon = XTHD.createPushButtonWithSound({
		normalNode = _guildIcon1,
		selectedNode = _guildIcon2,
		needSwallow = false,
		needEnableWhenMoving = false,
		needEnableWhenOut = false,
		endCallback = callBack
	})
	return _guildIcon
end
-- {
-- 	btnSize = cc.size(102,46)
-- 	,labelStr = "create"
-- 	,imgStr = "createGuild"
-- }
function BangPaiFengZhuangShuJu.createGuildBtnNode(_btnData)

	local _btnSize = _btnData.btnSize or cc.size(102,46)
	local _labelStr = _btnData.labelStr or "create_text"
	local _imgStr = _btnData.imgStr or "createGuild"
	local _fontSize = _btnData.fontSize or 20
	local _btn = XTHD.createCommonButton({
			text = _btnData.text or LANGUAGE_BTN_KEY[_labelStr],
			btnColor = _btnData.btnColor or "gray",
			btnSize = _btnSize,
			isScrollView = false,
			fontSize = _fontSize,
            fontColor =cc.c3b(255,255,255)
        })
	-- local _btnImg = cc.Sprite:create("res/image/guild/btnImg_" .. _imgStr .. ".png")
	--设置按钮上文字的位置的方法
    -- _btn:getLabel():setPositionX(_btn:getContentSize().width/2 + _btnImg:getContentSize().width/2-5)
    -- _btnImg:setAnchorPoint(cc.p(1,0.5))
    -- _btnImg:setPosition(cc.p(_btn:getLabel():getBoundingBox().x-2,_btn:getContentSize().height/2))
    -- _btn:addChild(_btnImg)
    return _btn
end

function BangPaiFengZhuangShuJu.createListBg(_bgSize)
	local _node = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
	_node:setContentSize(_bgSize)
	return _node
end

function BangPaiFengZhuangShuJu.createListCellBg(_bgSize,_idx)
	local imgpath = "res/image/common/scale9_bg2_26.png"
	if _idx and _idx % 2 == 0 then
		imgpath = "res/image/common/scale9_bg3_26.png"
	end
	local _node = ccui.Scale9Sprite:create(imgpath)
	_node:setContentSize(_bgSize)
	return _node
end


function BangPaiFengZhuangShuJu.createTitleNameBg(_bgSize)
	return XTHD.getScaleNode1("res/image/login/zhanghaodenglu.png", _bgSize)
end

function BangPaiFengZhuangShuJu.createListLine(_linewidth)
	local _node = ccui.Scale9Sprite:create( cc.rect( 0, 0, 3, 2 ), "res/image/ranklistreward/splitcell.png" )
	_node:setContentSize(cc.size(_linewidth,2))
	return _node
end
function BangPaiFengZhuangShuJu.createListVerticalLine(_lineHeight)
	local _node = ccui.Scale9Sprite:create("res/image/ranklistreward/splitY.png" )
	_node:setContentSize(cc.size(2,_lineHeight))
	return _node
end
