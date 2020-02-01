-- FileName: LayerManager.lua
-- Author: wangming
-- Date: 2015-09-08
-- Purpose: 层的管理器
--[[TODO List]]

LayerManager = {}

local layerId = {
	[1] = "DanBiChongZhiLayer",		--单笔充值界面
}

local m_director = cc.Director:getInstance()
local m_baseLayer = nil
local m_chatRoom = nil
local isLayerOpen = {} --记录某个界面是否打开

local mMrgStack = {} -- 记录当前模块堆叠的容器栈

local nZPop = 100 -- 弹出窗口的初始Zorder
local nShieldLayoutTag = 666669 -- ShieldLayout 的 tag，用于检测是否存在

---------------------get set 控制 -------------------

local function getCurManager( ... )
	return mMrgStack[#mMrgStack]
end

function LayerManager.getCurRoot( ... )
	local _rootMgr = getCurManager()
	if not _rootMgr then
		return nil
	end
	return _rootMgr._layRoot
end

local function getCurStack( ... )
	local _rootMgr = getCurManager()
	if not _rootMgr then
		return nil
	end
	return _rootMgr._tbLayoutStack
end

local function getCurLay( ... )
	local _curStack = getCurStack()
	if not _curStack then
		return nil
	end
	return _curStack[#_curStack]
end

--创建一个全屏幕的layer ， 可控该层是否接收touch
local function getFullLayout( notGetTouch )
	local pLay = cc.Layer:create()
	if(notGetTouch) then
		pLay:setTouchEnabled(false)
	else
		pLay:setTouchEnabled(true)
		local function touchCall( eventType, x, y )
			if (eventType == "began") then
				return true
			end
		end
		pLay:registerScriptTouchHandler(touchCall)
	end
	return pLay
end

-- 某个充值界面是否打开
function LayerManager.isLayerOpen(id) 
	if isLayerOpen ~= nil and isLayerOpen[id] ~= nil then
		return isLayerOpen[id];
	end
	return nil;
end

-- 打开某个界面并存储 并存储脚本引用
function LayerManager.layerOpen(id, node)
	if isLayerOpen ~= nil then
		table.insert(isLayerOpen, id, node)
	end
end

-- 关闭某个界面并存储
function LayerManager.layerClose(id)
	if isLayerOpen ~= nil then
		isLayerOpen[id] = nil;
	end
end


--[[desc:屏蔽旧界面往新界面传递触摸 添加屏蔽层
—]]
function LayerManager.addShieldLayout( isOnlyGet, sTime )
	if isOnlyGet then
		return getFullLayout()
	end
	local runningScene = m_director:getRunningScene()
	if (runningScene == nil) then
		return
	end
	local touchLayer = getFullLayout()
	touchLayer:setTag(nShieldLayoutTag) 
	runningScene:addChild(touchLayer, nZPop)

	local _time = tonumber(sTime) or 0.01
	performWithDelay(runningScene,function()
		local shield = runningScene:getChildByTag(nShieldLayoutTag)
		if (shield) then
			shield:removeFromParent()
		end
	end, _time)
end

function LayerManager.getBaseLayer()
	return m_baseLayer
end

-------------------UI创建、移除控制-----------------------------

function LayerManager.pushModule( slayer, isFirst, params )
	local runningScene = cc.Scene:create()
	if isFirst then
		mMrgStack = {}
	end
	local mTable = {}
	local _layRoot = cc.Layer:create()
	runningScene:addChild(_layRoot)
	_layRoot._scene = runningScene
	mTable._layRoot = _layRoot

	mTable._tbLayoutStack = {} --附加到parent上的Layout的容器栈

	table.insert(mMrgStack, mTable)

	if isFirst then
		print("********CTX_log:第一次进入加载主城界面*********")
		_layer = requires("src/fsgl/layer/ZhuCheng/ZhuChenglayer.lua"):create(params)
		m_baseLayer = _layer
		LayerManager.addLayout(_layer)
		m_chatRoom = nil
	end
	
	if slayer then
		LayerManager.addLayout(slayer)
	end

	if isFirst then
		-- runningScene = cc.TransitionSlideInR:create(2.0, runningScene)
		LayerManager.isSend = nil
		m_director:replaceScene(runningScene)
	else
		m_director:pushScene(runningScene)
	end

	return runningScene
end

function LayerManager.popModule( )
	local _length = #mMrgStack
	if _length > 1 then
		local _curMgr = table.remove(mMrgStack)
		-- _curMgr._layRoot:removeFromParent()
		_curMgr._tbLayoutStack = {}
		m_director:popScene()
		helper.collectMemory()
	end
end

function LayerManager.popModuleToDefult( )
	while true do
		local _length = #mMrgStack
		if _length > 1 then
			local _curMgr = table.remove(mMrgStack)
			-- _curMgr._layRoot:removeFromParent()
			_curMgr._tbLayoutStack = {}
			-- helper.collectMemory()
		else
			break
		end
	end
	m_director:popToRootScene()
	-- helper.collectMemory()
end

function LayerManager.reset()
	m_baseLayer = nil
	mMrgStack = {}
	m_chatRoom = nil
end

function LayerManager.sendZuobi( sParams )
	if LayerManager.isSend == true then
		return
	end
	LayerManager.isSend = true
	local runningScene = m_director:getRunningScene()
	if (runningScene == nil) then
        -- createFailHttpTipToPop()
		LayerManager.backToLoginLayer(true)
		return
	end

	local _content = ""
	if sParams and next(sParams) ~= nil then
		_content = json.encode(sParams)
	end

	XTHDHttp:requestAsyncInGameWithParams({
        modules = "illegalModify?",
        encrypt = HTTP_ENCRYPT_TYPE.NONE,
        params = {illegalState = 0, illegalContent = _content},
        successCallback = function(data)
	        -- createFailHttpTipToPop()
		    LayerManager.backToLoginLayer(true)
        end,--成功回调
        failedCallback = function()
	        -- createFailHttpTipToPop()
		    LayerManager.backToLoginLayer(true)
        end,--失败回调
        targetNeedsToRetain = runningScene,--需要保存引用的目标
        loadingParent = runningScene,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function LayerManager.backToLoginLayer( isZuobi )
	local _layRoot = LayerManager.getCurRoot()
	if not _layRoot then
		return
	end
	gotoMaincity()
	LayerManager.reset()
	MsgCenter:reset()
	local _scene = XTHD.replaceToLoginScene()
	performWithDelay(_scene,function( )
		if isZuobi then
		    local confirmDialog = XTHDConfirmDialog:createWithParams({
		    	msg = LANGUAGE_KEY_ZUOBI,
		    	leftVisible = false,
		    	isHide = false
	    	})
		    _scene:addChild(confirmDialog,1024)
		    
		    local callbalc = confirmDialog:getContainerLayer()
		    if callbalc ~= nil then
		        callbalc:setTouchEndedCallback(function()end)
		    end

		    confirmDialog:setCallbackRight(function (  )
		        confirmDialog:removeFromParent()
		    end)
		else
			-- XTHDTOAST(LANGUAGE_KEY_NETWORKERROR)
		end
	end,0.5)	
	XTHD.logout()
end

function LayerManager.addChatRoom( params )
	local _layRoot = LayerManager.getCurRoot()
	if not _layRoot then
		return
	end
	if m_chatRoom then
		return
	end
	local _params = params or {}
	local _zorder = tonumber(_params.zorder) or 1
	local _type = _params.sType or LiaoTianRoomLayer.Functions.Camp

	local _lay = getFullLayout(true)
	_lay._functionsType = _type
	m_chatRoom = _lay
	local _chatBtn = XTHDPushButton:createWithParams({
        normalFile = "res/image/homecity/menu_chat1.png",
        selectedFile = "res/image/homecity/menu_chat2.png"
    })
    _lay:addChild(_chatBtn,1005)
    _chatBtn:setAnchorPoint(0,0.5)
    local _posX=0
    if screenRadio>1.8 then
        _posX=45
    end
    _chatBtn:setPosition(_posX, _lay:getContentSize().height / 2 + 30)
    _chatBtn:setTouchSize(cc.size(_chatBtn:getContentSize().width + 5,_chatBtn:getContentSize().height + 16))
    _chatBtn:setTouchEndedCallback(function ()
        XTHD.showChatroom(_lay, _chatBtn)
    end)
    _layRoot:addChild(_lay, _zorder)

     local _redDot =XTHD.createSprite("res/image/common/heroList_redPoint.png")
    _chatBtn:addChild(_redDot)
    _redDot:setPosition(_chatBtn:getContentSize().width,_chatBtn:getContentSize().height / 2 + 20)
    _redDot:setVisible(LiaoTianDatas.hasNewMsgs)

    -----注册刷新聊天红点
    XTHD.addEventListenerWithNode({
    	name = CUSTOM_EVENT.SHOW_CHAT_REDDOT_AT_CAMP,
    	node = _lay,
    	callback = function(event)
	        if event.data.visible == true and _redDot and not LiaoTianRoomLayer.__isAtShowing then 
	            _redDot:setVisible(true)
	        elseif event.data.visible == false and _redDot then 
	            _redDot:setVisible(false)            
	        end 
	    end})
    -------显示或者隐藏聊天按钮
    XTHD.addEventListenerWithNode({
    	name = CUSTOM_EVENT.ISDISPLAY_CAMP_CHATBUTTON, 
    	node = _lay,
    	callback = function( event )
	        if _chatBtn then 
	            _chatBtn:setVisible(event.data)
	        end 
	    end})
    return _chatBtn
end

function LayerManager.removeChatRoom( _type )
	if m_chatRoom and m_chatRoom._functionsType == _type then
		m_chatRoom:removeFromParent()
		m_chatRoom = nil
	end
end

function LayerManager.setChatRoomVisable( isVisable )
	if m_chatRoom then
		m_chatRoom:setVisible(isVisable)
	end
end


--[[desc:—
	params : 
		noHide 堆栈上一层隐藏控制
		delayHide 堆栈上一层的延迟隐藏控制

]]
function LayerManager.addLayout( sLayout, params )
	-- assert(sLayout, "addLayout : sLayout get nil ")
	if not sLayout then
		return
	end
	local _layRoot = LayerManager.getCurRoot()
	if not _layRoot then
		return
	end
	-- assert(_layRoot, "addLayout : _layRoot get nil ")
	local _params = params or {}
	local _zorder = tonumber(_params.zorder) or 0
	if _zorder ~= 0 then
		_layRoot:addChild(sLayout, _zorder)
	else
		_layRoot:addChild(sLayout)
	end
	local _curStack = getCurStack()
	table.insert(_curStack, sLayout)
	if not _params.noHide then
		local _length = #_curStack
		local pLay = _curStack[_length-1]
		if pLay then
			if pLay:getLocalZOrder() <= _zorder then
				local pDelayTime = tonumber(_params.delayHide) or 0
				if pDelayTime > 0 then
					performWithDelay(pLay, function() 
						pLay:setVisible(false)
					end, pDelayTime)
				else
					pLay:setVisible(false)
				end
			end
		end
	end

	--切换模块之后删除添加的触摸屏蔽层
	LayerManager.addShieldLayout()
end

function LayerManager.removeLayout( sLayout, notRemove )
	local _curStack = getCurStack()
	local _length = #_curStack
	if _length > 1 then
		local pLay = _curStack[_length-1]
		local popLayer = table.remove(_curStack)
		if popLayer then
			if not notRemove then
				popLayer:removeFromParent()
			end
			if pLay then
				pLay:setVisible(true)
			end
		end
	end
end

function LayerManager.removeLayoutToDefult( )
	while true do
		local _curStack = getCurStack()
		local _length = #_curStack
		if _length > 1 then
			local pLay = _curStack[_length-1]
			local popLayer = table.remove(_curStack)
			if popLayer then
				popLayer:removeFromParent()
				if pLay then
					pLay:setVisible(true)
				end
			end
		else
			break
		end
	end
	helper.collectMemory()
end


----------------------------module 创建方法--------------------------------------

function LayerManager.createModule( sName, sParams )
	local pModule = requires(sName)
	if not pModule then
		return
	end
	LayerManager.addShieldLayout()
	local _pLay = pModule:createForLayerManager(sParams)
	return _pLay
end
