local PlayerNamePoplayer = class("PlayerNamePoplayer",function()
	return XTHDPopLayer:create({isHide = true})
end)

function PlayerNamePoplayer:ctor(data,node)
	self._node = node
	self._data = data
	self._playerName = nil
	self._sex = 1
	self._sexbtnlist = {}
	self:init()
end

function PlayerNamePoplayer:init()
	local popNode = cc.Sprite:create("res/image/PlayerName/popNodebg.png")
	self:addContent(popNode)
	popNode:setContentSize(self:getContentSize())
	popNode:setPosition(self:getContentSize().width *0.5,self:getContentSize().height *0.5)

	local _bg = cc.Sprite:create("res/image/PlayerName/bg.png")
	popNode:addChild(_bg,1)
	_bg:setPosition(self:getContentSize().width*0.5,self:getContentSize().height *0.5)

	local playerName = self:RandomPayerName()
	self._playerName = playerName

	local editbg = cc.Sprite:create("res/image/PlayerName/exditbg.png")
	_bg:addChild(editbg)
	editbg:setPosition(_bg:getContentSize().width*0.5 + editbg:getContentSize().width *0.55,_bg:getContentSize().height *0.5 + editbg:getContentSize().height)

	local inputBox = ccui.EditBox:create(cc.size(editbg:getContentSize().width - 2,editbg:getContentSize().height - 2), ccui.Scale9Sprite:create(), nil, nil)
    inputBox:setFontColor(cc.c3b(52,25,25))
    inputBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    inputBox:setAnchorPoint(0.5,0.5)
    inputBox:setMaxLength(30)
    inputBox:setPosition(editbg:getContentSize().width *0.5,editbg:getContentSize().height *0.5)
    inputBox:setPlaceholderFontColor(cc.c3b(52,25,25))
    inputBox:setFontName("res/fonts/def.ttf")
    inputBox:setPlaceholderFontName("res/fonts/def.ttf")
    inputBox:setFontSize(22)
    inputBox:setPlaceholderFontSize(22)
    inputBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	inputBox:setText(self._playerName)
	editbg:addChild(inputBox)
	
	

	local btn_reset = XTHDPushButton:create({
		normalFile = "res/image/PlayerName/btn_shaizi_up.png",
		selectedFile = "res/image/PlayerName/btn_shaizi_down",
	})
	_bg:addChild(btn_reset)
	btn_reset:setPosition(editbg:getPositionX() + editbg:getContentSize().width *0.5 + btn_reset:getContentSize().width *0.5 + 10,editbg:getPositionY())
	btn_reset:setTouchEndedCallback(function()
		self._playerName = self:RandomPayerName()
		inputBox:setText(self._playerName)
	end)

	genderfiles = {"boy","girl"}
	for i = 1, 2 do
		local btn = XTHDPushButton:createWithParams({
			normalFile = "res/image/PlayerName/point_normal.png",
			selectedFile = "res/image/PlayerName/point_select.png",
		})
		_bg:addChild(btn)
		btn:setAnchorPoint(0,0.5)
		btn:setPosition(editbg:getPositionX() - editbg:getContentSize().width *0.5 + (i - 1) * 120,_bg:getContentSize().height *0.5 - 30)
		self._sexbtnlist[#self._sexbtnlist + 1] = btn		

		local gender = cc.Sprite:create("res/image/PlayerName/"..genderfiles[i]..".png")
		_bg:addChild(gender)
		gender:setAnchorPoint(0,0.5)
		gender:setPosition(btn:getPositionX() + btn:getContentSize().width + 10,btn:getPositionY())
		
		if i == 1 then
			btn:setSelected(true)
		end 
		btn:setTouchEndedCallback(function()
			self:selelctGender(i)
		end)
	end

	local start = XTHDPushButton:createWithParams({
		normalFile = "res/image/PlayerName/btn_start_up.png",
		selectedFile = "res/image/PlayerName/btn_start_down.png",
	})
	_bg:addChild(start)
	start:setPosition(_bg:getContentSize().width - start:getContentSize().width - 45,_bg:getContentSize().height *0.4 - start:getContentSize().height - 20)
	start:setTouchEndedCallback(function()
		self._playerName = inputBox:getText()
		self:StartGame()
	end)
end

function PlayerNamePoplayer:StartGame()
		if self._playerName == nil or self._playerName == "" then
			XTHDTOAST("请填写您的昵称")
			return
		end
		local token = self._data.token
		gameUser.setToken(token)
		local campID = self._data.campId
		requires("src/fsgl/layer/YinDaoJieMian/YinDaoFight0.lua"):create()
		
		local _templateId = 1
		if self._sex == 1 then
			_templateId = 3
		else
			_templateId = 1
		end
		--------------不进先种族界面直接创建角色进游戏------------------------------------------------
		XTHDHttp:requestAsyncInGameWithParams({
			modules = "createCharacter?",
			params = {campId = campID,templateId = _templateId,serverId = serverId,token = gameUser.getToken(),name = self._playerName,sex = self._sex},
			successCallback = function(data)
				if data.result == 0 then
					gameUser.setGuideID({id = 1,index = 1})
					DengLuUtils.doNewLogin(self._node,nil,true)
					self:hide()
				else
					XTHDTOAST(data.msg)
				end 
				end,--成功回调
			failedCallback = function()
				XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
			end,--失败回调
			targetNeedsToRetain = node,--需要保存引用的目标
			loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		})
end

function PlayerNamePoplayer:RandomPayerName()
	local prefixLen = #PrefixName
	local midLen = #MidName
    local suffixLen = #SuffixName
    local hasMid = math.random(100) % 2
    local index = math.random(prefixLen)
    local name = PrefixName[index]
    if hasMid == 1 then 
		index = math.random(midLen)
        name = name..MidName[index]
    end 
    index = math.random(suffixLen)
    name = name..SuffixName[index]         
    return name
end

function PlayerNamePoplayer:selelctGender(index)
	for i = 1,#self._sexbtnlist do
		if i == index then
			self._sexbtnlist[i]:setSelected(true)
		else
			self._sexbtnlist[i]:setSelected(false)
		end
	end
	self._sex = index
end

function PlayerNamePoplayer:create(data,node)
	return PlayerNamePoplayer.new(data,node)
end

return PlayerNamePoplayer
