--[[
种族城主信息
]]

local ZhongZuCastellenInfo = class("ZhongZuCastellenInfo",function( )
	return XTHDDialog:create()	
end)

function ZhongZuCastellenInfo:ctor(cityID,parent,serverData)
	self._cityID = cityID
	self._parent = parent
	self._serverData = serverData or {}

	self._castellenDec = nil -------城主宣言
	self._isCastellen = false ------是否是城主
	self._castellenName = nil
	self._castellenIcon = nil
	self._inputBg = nil ------宣言的输入框背景
	self._castellenInput = nil

	if self._serverData.cityBase and self._serverData.cityBase.masterType == 1 then
		self._isCastellen = (self._serverData.cityBase.baseId == gameUser.getUserId())
	end 
end

function ZhongZuCastellenInfo:create(cityID,parent)
	XTHDHttp:requestAsyncInGameWithParams({
        modules = "cityMasterBase?",
        params = {cityId = cityID},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
				local layer = ZhongZuCastellenInfo.new(cityID,parent,data)
				if layer then
					layer:init()
				end 
				LayerManager.addLayout(layer)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = parent,
        loadingType = HTTP_LOADING_TYPE.CIRCLE--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZhongZuCastellenInfo:init( )
	local size = cc.Director:getInstance():getWinSize()
	local _bg = cc.Sprite:create("res/image/camp/camp_bg11.png")
	_bg:setContentSize(size)
	self:addChild(_bg)
	_bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	------上边框
	local _borderU = cc.Sprite:create("res/image/camp/camp_border.png")
	self:addChild(_borderU)
	_borderU:setOpacity(0)
	_borderU:setAnchorPoint(0.5,1)
	_borderU:setPosition(self:getContentSize().width / 2,self:getContentSize().height)
	-----关闭按钮
	local button = XTHD.createPushButtonWithSound({
		normalFile = "res/image/common/btn/btn_back_normal.png",
		selectedFile = "res/image/common/btn/btn_back_selected.png",
	},3)
	button:setTouchEndedCallback(function( )
		LayerManager.removeLayout()
	end)
	button:setAnchorPoint(1,1)
	self:addChild(button)
	button:setPosition(self:getContentSize().width,self:getContentSize().height)
	------下边框
	local _borderD = cc.Sprite:createWithTexture(_borderU:getTexture())	
	_bg:addChild(_borderD)
	_borderD:setOpacity(0)
	_borderD:setFlippedY(true)
	_borderD:setFlippedX(true)
	_borderD:setAnchorPoint(0.5,0)
	_borderD:setPosition(self:getContentSize().width / 2,0)
	------城主
	local _castellen = cc.Sprite:create("res/image/camp/camp_castellen_name.png")
	_bg:addChild(_castellen)
	_castellen:setPosition(_bg:getContentSize().width / 2 + 5,_bg:getContentSize().height -_castellen:getContentSize().height - 30 )
	------玩家名字加等级 
	local _name = XTHDLabel:create(self._serverData.cityBase.heroName,24,"res/fonts/def.ttf")
	_name:setColor(cc.c3b(255,255,255))
	_name:enableShadow(cc.c4b(0,0,0,0xff),cc.size(1,0))
	_name:enableOutline(cc.c4b(54,55,112,255),1)
	_bg:addChild(_name)
	_name:setScale(0.9)
	_name:setAnchorPoint(0.5,1)
	_name:setPosition(_castellen:getPositionX() - 5,_castellen:getPositionY() - _castellen:getContentSize().height / 2-15)
	self._castellenName = _name
	-------放头像的 
	local portraitBox = cc.Sprite:create("res/image/camp/camp_head_box2.png")
	_bg:addChild(portraitBox)
	portraitBox:setOpacity(255)
	portraitBox:setAnchorPoint(0.5,0.5)
	portraitBox:setPosition(_bg:getContentSize().width * 0.5,_bg:getContentSize().height*0.5 + portraitBox:getContentSize().height * 0.75)
	--------人物头像
	--local _portrait = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById(self._serverData.cityBase.heroId))
	local _portrait = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById1(self._serverData.cityBase.heroId))
	_portrait:setAnchorPoint(0.5,0.5)
	portraitBox:addChild(_portrait)
	_portrait:setPosition(portraitBox:getContentSize().width * 0.5 + 3,portraitBox:getContentSize().height * 0.5 + 3)
	self._castellenIcon = _portrait
	----边框 
	local _border = cc.Sprite:create("res/image/multiCopy/copy_black_head.png")
	portraitBox:addChild(_border)
	_border:setPosition(_portrait:getPosition())
	-------城主宣言
	local declare = cc.Sprite:create("res/image/camp/camp_label12.png")
	_bg:addChild(declare)
	declare:setAnchorPoint(0.5,1)
	declare:setPosition(_bg:getContentSize().width * 0.5,_bg:getContentSize().height*0.5)

    local inputBg = ccui.Scale9Sprite:create("res/image/camp/scale9_bg_33.png")
    self:addChild(inputBg)
    inputBg:setContentSize(cc.size(466,50))
    inputBg:setAnchorPoint(0.5,1)
    inputBg:setPosition(declare:getPositionX(),declare:getPositionY() - declare:getContentSize().height - 35)
    self._inputBg = inputBg

    local str = self._serverData.cityBase.manifesto == "" and LANGUAGE_KEY_NA or self._serverData.cityBase.manifesto
	self._castellenDec = XTHDLabel:create(str,22,"res/fonts/def.ttf")
	self._castellenDec:setColor(cc.c3b(54,55,112))
	-- self._castellenDec:enableShadow(cc.c4b(54,55,112,255),cc.size(1,-1))
	inputBg:addChild(self._castellenDec)
	self._castellenDec:setPosition(inputBg:getContentSize().width / 2,inputBg:getContentSize().height / 2)

    self:displayManifestoInput(self._isCastellen)

    -------提示
    local tips = XTHDLabel:create(LANGUAGE_CAMP_TIPSWORDS44,20,"res/fonts/def.ttf") ----每周几可以抢城主
    tips:setColor(cc.c3b(255,255,255))
	-- tips:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
	tips:enableOutline(cc.c4b(0,0,0,255),1)
    tips:setAnchorPoint(0.5,1)
    tips:setPosition(inputBg:getPositionX(),inputBg:getPositionY() - inputBg:getContentSize().height - 30)
    self:addChild(tips)
    -----城主抢夺按钮
    local btn = XTHD.createPushButtonWithSound({
    	normalFile = "res/image/camp/qiangduocz_up.png",
    	selectedFile = "res/image/camp/qiangduocz_down.png",
	},3)
	-- local btn = XTHD.createCommonButton({
	-- 	btnColor = "blue",
	-- 	text = "抢夺城主",
	-- 	fontSize = 20,
	-- })
	--btn:getLabel():setPosition(btn:getLabel():getPositionX()-15,btn:getLabel():getPositionY()-8)
    btn:setAnchorPoint(0.5,1)
    self:addChild(btn)
    btn:setPosition(self:getContentSize().width / 2,tips:getPositionY() - tips:getContentSize().height - 30)
    btn:setTouchEndedCallback(function(  )
		requires("src/fsgl/layer/ZhongZu/forTheHost/ZhongZuCastellenMain.lua"):create(self._cityID,self)
    end)
    ----------
    local x,y = self:getContentSize().width - 20,70
    for i = 2,1,-1 do 
    	local _btn = XTHD.createPushButtonWithSound({
    		normalFile = "res/image/camp/camp_btn"..(i + 4).."_1.png",
    		selectedFile = "res/image/camp/camp_btn"..(i + 4).."_2.png",
    	},3)
    	_btn:setAnchorPoint(1,0.5)
    	self:addChild(_btn)
    	_btn:setPosition(x,y)
    	_btn:setTag(i)
    	x = x - _btn:getContentSize().width - 20
    	_btn:setTouchEndedCallback(function( )
    		self:doRightBottomBtn(_btn)
    	end)
    end 
end

function ZhongZuCastellenInfo:doRightBottomBtn( sender )
	if sender:getTag() == 1 then  ------城主捐献 
		requires("src/fsgl/layer/ZhongZu/forTheHost/ZhongZuCityDonate.lua"):create(self._cityID,self._parent)
	elseif sender:getTag() == 2 then  ------发放奖励
		if self._isCastellen then 
			local layer = requires("src/fsgl/layer/ZhongZu/forTheHost/ZhongZuGiveoutReward.lua"):create(self._cityID,self)
			LayerManager.addLayout(layer)
		else 
			XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS47) ----奖励只能由城主代发
		end 
	end 
end
-------更改宣言
function ZhongZuCastellenInfo:doChangeDeclare(str)
	XTHDHttp:requestAsyncInGameWithParams({
        modules = "cityManifesto?",
        params = {content = str},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
            	-- dump(data)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZhongZuCastellenInfo:refreshCastellen( )
	XTHDHttp:requestAsyncInGameWithParams({
        modules = "cityMasterBase?",
        params = {cityId = self._cityID},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
            	if data.cityBase then 
	            	self._serverData = data
	            	self._castellenName:setString(data.cityBase.heroName)
	            	self._castellenIcon:setTexture("res/image/avatar/castellan/chengzhu_"..data.cityBase.heroId..".png")---------------------城主头像路径
	            	if data.cityBase.masterType == 1 then
						self._isCastellen = (self._serverData.cityBase.baseId == gameUser.getUserId())
						self:displayManifestoInput(self._isCastellen)
					end 
				end 
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE--加载图显示 circle 光圈加载 head 头像加载
    })
end


function ZhongZuCastellenInfo:displayManifestoInput(isShow)
	print("is show input box ",isShow)
	if isShow then 
		if not self._castellenInput then 
			local str = self._serverData.cityBase.manifesto == "" and LANGUAGE_KEY_NA or self._serverData.cityBase.manifesto
			self._castellenDec:setString(str)
		    local inputBox = ccui.EditBox:create(cc.size(466,50),ccui.Scale9Sprite:create(),nil,nil)
		    inputBox:setFontSize(22)
		    inputBox:setFontName(XTHD.SystemFont)
		    inputBox:setMaxLength(460)
		    self._inputBg:addChild(inputBox)
		    inputBox:setPosition(self._inputBg:getContentSize().width / 2,self._inputBg:getContentSize().height / 2)    
		    inputBox:registerScriptEditBoxHandler(function(event,sender)
				if event == "began" then
					if self._castellenDec then 
						sender:setText(self._castellenDec:getString())
						self._castellenDec:setVisible(false)
					end 
				elseif event == "return" then
					if self._castellenDec then 
						self._castellenDec:setString(sender:getText())				
						self._castellenDec:setVisible(true)		
						self:doChangeDeclare(sender:getText())
						sender:setText("")
					end 
				end 
		    end)
		    self._castellenInput = inputBox		
		end
	else 
		if self._castellenInput then 
			self._castellenInput:removeFromParent()
			self._castellenInput = nil
		end 
	end 
end

return ZhongZuCastellenInfo 