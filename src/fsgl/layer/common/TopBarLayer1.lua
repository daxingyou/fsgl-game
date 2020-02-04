--[[
备注：在页面跳转的时候，需要先把上一个页面的TopBar移除，再创建新的页面.否则会出现上一个TopBar在onExit中会把新创建TopBar的通知监听移除
]]
TopBarLayer1 = class( "TopBarLayer1", function ( instancingid )
	 return XTHDDialog:create();
end)

function TopBarLayer1:setBackCallFunc( callfunc )
	self._callfunc = callfunc;
end

function TopBarLayer1:ctor(isNewBack, showPlus, showGF)
	self:setSwallowTouches(false)
	self._needReleaseGuide = true
	self._isNewBack = isNewBack or false
	self._showPlus = showPlus == nil and true or showPlus
	self._showGF = showGF == nil and true or showGF
	self._topHeight = self:getTopBarHeight()


	local size = self:getContentSize();
	local touch_size = cc.size(36,37)

	--为老板准备的
	local _topElementPosY = size.height-8-self._topHeight/2

	--最上边那一栏的背景
	local T_bg = ccui.Scale9Sprite:create("res/image/common/Titile_bg.png")
	T_bg:setContentSize(self:getContentSize().width,50)
	T_bg:setAnchorPoint(cc.p(0.5,1))
	T_bg:setPosition(self:getContentSize().width/2,self:getContentSize().height)
	self:addChild(T_bg)
	T_bg:setName("T_bg")
	-- 返回按钮
	local _btnBack = nil
	-- if self._isNewBack and self._isNewBack == true then
	_btnBack = XTHD.createButton({
		normalNode = cc.Sprite:create("res/image/common/btn/btn_back_normal.png"),
		selectedNode = cc.Sprite:create("res/image/common/btn/btn_back_selected.png"),
		needSwallow = true,
		enable = true,
		musicFile = XTHD.resource.music.effect_btn_commonclose,
		touchSize = cc.size(150,60),
		endCallback = function ()
			----引导 
			YinDaoMarg:getInstance():guideTouchEnd() 
			if self._needReleaseGuide then 
				YinDaoMarg:getInstance():releaseGuideLayer()
			end
			------------------------------------------
			if self._callfunc then
				self._callfunc();
			end
		end});
	_btnBack:setAnchorPoint(cc.p(1, 1));
	_btnBack:setName("topBarBackBtn")
	if ZC_targetPlatform == cc.PLATFORM_OS_IPHONE then  --返回按钮 左移 为适配 iPhone X 刘海屏
		_btnBack:setPosition(cc.p(size.width - 30, size.height));
	else
		_btnBack:setPosition(cc.p(size.width, size.height));
	end
	self._btnBack = _btnBack

	self:addChild(_btnBack);
	_topElementPosY = _btnBack:getBoundingBox().y+_btnBack:getBoundingBox().height/2-3
	-- else
	-- 	_btnBack = XTHD.createButton({
	-- 		normalNode = cc.Sprite:create("res/image/common/btn/btn_green_back_normal.png"),
	-- 		selectedNode = cc.Sprite:create("res/image/common/btn/btn_green_back_selected.png"),
	-- 		needSwallow = true,
	-- 		enable = true,
	-- 		musicFile = XTHD.resource.music.effect_btn_commonclose,
	-- 		touchSize = cc.size(150,60),
	-- 		endCallback = function ()
	-- 		    ----引导 
	-- 		    YinDaoMarg:getInstance():guideTouchEnd() 
	-- 		    if self._needReleaseGuide then 
	-- 		    	YinDaoMarg:getInstance():releaseGuideLayer()
	-- 		    end
	-- 		    ------------------------------------------
	-- 			if self._callfunc then
	-- 				self._callfunc();
	-- 			end
	-- 		end});
	-- 	_btnBack:setAnchorPoint(cc.p(1, 0.5));
	-- 	_btnBack:setName("topBarBackBtn")
	-- 	_btnBack:setPosition(cc.p(size.width-size.width*0.02, _topElementPosY));
	-- 	self:addChild(_btnBack);
	-- end
	
	local _tmp_change_x = -30 --
	--背景
	local _topbarItemBgPath = "res/image/common/goldbg.png"
	-- 体力图标
	local _physicalBg = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create(_topbarItemBgPath),
		selectedNode = cc.Sprite:create(_topbarItemBgPath),
        needEnableWhenOut = true
	})
    _physicalBg:setTouchBeganCallback(function( )
        _physicalBg:setScale(0.9)
        self:showBoxTips(_physicalBg,1)
    end)
    _physicalBg:setTouchMovedCallback(function( )
        _physicalBg:setScale(0.9)
    end)
    _physicalBg:setTouchEndedCallback(function( )
        _physicalBg:setScale(1.0)
		if self._boxTips then 
			self._boxTips:removeFromParent()
			self._boxTips = nil
		end 
    end)
	_physicalBg:setAnchorPoint(cc.p(0.5,0.5))
	_physicalBg:setPosition(cc.p(size.width*0.24 + _tmp_change_x,_topElementPosY))
	self:addChild(_physicalBg)
	_physicalBg:setName("_physicalBg")
	local _spPhysical = cc.Sprite:create("res/image/common/header_tili.png");
	_spPhysical:setAnchorPoint(cc.p(0.5, 0.5));
	_spPhysical:setPosition(cc.p(18,_physicalBg:getContentSize().height/2));
	_physicalBg:addChild(_spPhysical);

	-- 体力信息
	local _labPhysical = getCommonWhiteBMFontLabel("100000",1000000)
	_labPhysical:setAnchorPoint(cc.p(0.5, 0.5));
	_labPhysical:setPosition(cc.p(_physicalBg:getContentSize().width/2,_physicalBg:getContentSize().height/2-7));
	_physicalBg:addChild(_labPhysical);
	self._labPhysical = _labPhysical;
	-- TopBarLayer1._labPhysical = _labPhysical;

	-- +体力按钮
	local _btnPhysicalPlus = XTHD.createButton({
		normalNode = cc.Sprite:create("res/image/common/btn/btn_plus_normal.png"),
		selectedNode = cc.Sprite:create("res/image/common/btn/btn_plus_selected.png"),
		needSwallow = true,
		enable = true,
		-- musicFile = XTHD.resource.music.effect_btn_common,
		touchSize = touch_size,
		endCallback = function ()
            local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=2})--byhuangjunjian 获得资源共用方法（1.元宝2.体力3.银两4.翡翠）
            cc.Director:getInstance():getRunningScene():addChild(StoredValue)
		end
		});
	_btnPhysicalPlus:setAnchorPoint(cc.p(0.5, 0.5));
	_btnPhysicalPlus:setPosition(cc.p(_physicalBg:getContentSize().width,_physicalBg:getContentSize().height/2));
	_physicalBg:addChild(_btnPhysicalPlus);
	if self._showPlus == false then
		_btnPhysicalPlus:setVisible(false)
	end

	-- 银两图标
	local _goldBg = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create(_topbarItemBgPath),
		selectedNode = cc.Sprite:create(_topbarItemBgPath),
        needEnableWhenOut = true
	})
    _goldBg:setTouchBeganCallback(function( )
        _goldBg:setScale(0.9)
        self:showBoxTips(_goldBg,2)
    end)
    _goldBg:setTouchMovedCallback(function( )
        _goldBg:setScale(0.9)
    end)
    _goldBg:setTouchEndedCallback(function( )
        _goldBg:setScale(1.0)
		if self._boxTips then 
			self._boxTips:removeFromParent()
			self._boxTips = nil
		end 
    end)
	_goldBg:setAnchorPoint(cc.p(0.5,0.5))
	_goldBg:setPosition(cc.p(size.width*0.43+ _tmp_change_x,_topElementPosY))
	self:addChild(_goldBg)
	_goldBg:setName("_goldBg")
	local _spGold = cc.Sprite:create("res/image/common/header_gold.png");
	_spGold:setAnchorPoint(cc.p(0.5, 0.5));
	_spGold:setPosition(cc.p(18,_goldBg:getContentSize().height/2));
	_goldBg:addChild(_spGold);

	-- 银两
	local _labGold = getCommonWhiteBMFontLabel("100000",1000000)
	_labGold:setAnchorPoint(cc.p(0.5, 0.5));
	_labGold:setPosition(cc.p(_goldBg:getContentSize().width/2,_goldBg:getContentSize().height/2-7));
	_goldBg:addChild(_labGold);
	self._labGold = _labGold;
	-- TopBarLayer1._labGold = _labGold;
		-- 加翡翠按钮
	local _labGoldPlus = XTHD.createButton({
		normalNode = cc.Sprite:create("res/image/common/btn/btn_plus_normal.png"),
		selectedNode = cc.Sprite:create("res/image/common/btn/btn_plus_selected.png"),
		needSwallow = true,
		enable = true,
		touchSize = touch_size,
		-- musicFile = XTHD.resource.music.effect_btn_common,
		endCallback = function ()
			replaceLayer({id = 48,fNode = self:getParent()})
			-- local _exchangePopLayer = requires("src/fsgl/layer/ZhuCheng/ExchangeByIngotPopLayer1.lua")
   --          _exchangePopLayer = _exchangePopLayer:create("silver",self:getParent())
   --          self:getParent():addChild(_exchangePopLayer,3)
		end
		});
	_labGoldPlus:setAnchorPoint(cc.p(0.5, 0.5));
	_labGoldPlus:setPosition(cc.p(_goldBg:getContentSize().width,_goldBg:getContentSize().height/2));
	_goldBg:addChild(_labGoldPlus);
	if self._showGF == false then
		_labGoldPlus:setVisible(false)
	end



	-- 翡翠图标
	local _EmeraldBg = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create(_topbarItemBgPath),
		selectedNode = cc.Sprite:create(_topbarItemBgPath),
        needEnableWhenOut = true
	})
    _EmeraldBg:setTouchBeganCallback(function( )
        _EmeraldBg:setScale(0.9)
        self:showBoxTips(_EmeraldBg,3)
    end)
    _EmeraldBg:setTouchMovedCallback(function( )
        _EmeraldBg:setScale(0.9)
    end)
    _EmeraldBg:setTouchEndedCallback(function( )
        _EmeraldBg:setScale(1.0)
		if self._boxTips then 
			self._boxTips:removeFromParent()
			self._boxTips = nil
		end 
    end)
	_EmeraldBg:setAnchorPoint(cc.p(0.5,0.5))
	_EmeraldBg:setPosition(cc.p(size.width*0.62+ _tmp_change_x,_topElementPosY))
	self:addChild(_EmeraldBg)
	_EmeraldBg:setName("_EmeraldBg")
	local _spEmerald = cc.Sprite:create("res/image/common/header_feicui.png");
	_spEmerald:setAnchorPoint(cc.p(0.5, 0.5));
	_spEmerald:setPosition(cc.p(18,_EmeraldBg:getContentSize().height/2));
	_EmeraldBg:addChild(_spEmerald);

	-- 翡翠
	local _labEmerald =getCommonWhiteBMFontLabel("100000",1000000)
	_labEmerald:setPosition(cc.p(_EmeraldBg:getContentSize().width/2,_EmeraldBg:getContentSize().height/2-7));
	_EmeraldBg:addChild(_labEmerald);
	self._labEmerald = _labEmerald;
	-- TopBarLayer1._labEmerald = _labEmerald;

		-- 加翡翠按钮
	local _labEmeraldPlus = XTHD.createButton({
		normalNode = cc.Sprite:create("res/image/common/btn/btn_plus_normal.png"),
		selectedNode = cc.Sprite:create("res/image/common/btn/btn_plus_selected.png"),
		needSwallow = true,
		enable = true,
		touchSize = touch_size,
		-- musicFile = XTHD.resource.music.effect_btn_common,
		endCallback = function ()
			replaceLayer({id = 48,fNode = self:getParent()})
			 -- local _exchangePopLayer = requires("src/fsgl/layer/ZhuCheng/ExchangeByIngotPopLayer1.lua")
    --           _exchangePopLayer = _exchangePopLayer:create("feicui",self:getParent())
    --           self:getParent():addChild(_exchangePopLayer,3)
		end
		});
	_labEmeraldPlus:setAnchorPoint(cc.p(0.5, 0.5));
	_labEmeraldPlus:setPosition(cc.p(_EmeraldBg:getContentSize().width,_EmeraldBg:getContentSize().height/2));
	_EmeraldBg:addChild(_labEmeraldPlus);
	if self._showGF == false then
		_labEmeraldPlus:setVisible(false)
	end


	-- 元宝图标
	local _IngotBg = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create(_topbarItemBgPath),
		selectedNode = cc.Sprite:create(_topbarItemBgPath),
        needEnableWhenOut = true
	})
    _IngotBg:setTouchBeganCallback(function( )
        _IngotBg:setScale(0.9)
        self:showBoxTips(_IngotBg,4)
    end)
    _IngotBg:setTouchMovedCallback(function( )
        _IngotBg:setScale(0.9)
    end)
    _IngotBg:setTouchEndedCallback(function( )
        _IngotBg:setScale(1.0)
		if self._boxTips then 
			self._boxTips:removeFromParent()
			self._boxTips = nil
		end 
    end)
	_IngotBg:setAnchorPoint(cc.p(0.5,0.5))
	_IngotBg:setPosition(cc.p(size.width*0.81+ _tmp_change_x,_topElementPosY))
	self:addChild(_IngotBg)
	_IngotBg:setName("_IngotBg")
	local _spIngot = cc.Sprite:create("res/image/imgSelHero/img_gold.png");
	_spIngot:setAnchorPoint(cc.p(0.5, 0.5));
	_spIngot:setPosition(cc.p(18,_IngotBg:getContentSize().height/2));
	_IngotBg:addChild(_spIngot);

	-- 元宝信息
	local _labIngot = getCommonWhiteBMFontLabel("100000",1000000)
	_labIngot:setPosition(cc.p(_IngotBg:getContentSize().width/2,_IngotBg:getContentSize().height/2-7));
	_IngotBg:addChild(_labIngot);
	self._labIngot = _labIngot;
	-- TopBarLayer1._labIngot = _labIngot;

	-- 加元宝按钮
	local _btnIngotPlus = XTHD.createButton({
		normalNode = cc.Sprite:create("res/image/common/btn/btn_plus_normal.png"),
		selectedNode = cc.Sprite:create("res/image/common/btn/btn_plus_selected.png"),
		needSwallow = true,
		enable = true,
		-- musicFile = XTHD.resource.music.effect_btn_common,
		touchSize = touch_size,
		endCallback = function ()
			-- local addGold = requires("src/fsgl/layer/ZhuCheng/AddGoldPopLayer1.lua"):create()
	  --       self:getParent():addChild(addGold,3)
   		    XTHD.createRechargeVipLayer( self:getParent(),nil,2)
		end
		});
	_btnIngotPlus:setAnchorPoint(cc.p(0.5, 0.5));
	_btnIngotPlus:setPosition(cc.p(_IngotBg:getContentSize().width,_IngotBg:getContentSize().height/2));
	_IngotBg:addChild(_btnIngotPlus);
	if self._showPlus == false then
		_btnIngotPlus:setVisible(false)
	end

	-- 时间
	self._labTimer = getCommonWhiteBMFontLabel(os.date("%H:%M"))
	self._labTimer:setPosition(cc.p(size.width-size.width*0.94, _btnBack:getBoundingBox().y+_btnBack:getBoundingBox().height/2-7));
	self:addChild(self._labTimer);
	self._labTimer:setName("_labTimer")
	-- 开启计时器
	schedule(self._labTimer, function ()
		self._labTimer:setString( os.date("%H:%M") );
	end, 60)

	self:refreshData() 	
end

function TopBarLayer1:setBackMusic(file)
	self._btnBack:setMusicFile(file)
end

function TopBarLayer1:getTopBarHeight()
	return 40
end

function TopBarLayer1:onEnter()
	self:refreshData()
	XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_TOP_INFO,node = self,callback = function(event)
 	 	self:refreshData() --刷新当前的
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，
		XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_BUILDINFO_AFTERLEVELUP}) ----刷新建筑升级时底部数据 
 	end})
end

function TopBarLayer1:onExit()
	-- self._callfunc = nil
	-- local _eventName = CUSTOM_EVENT_REFRESH_TOP_INFO(self:getTopBarSocketTime())
	-- XTHD.removeEventListener(_eventName)
end

function TopBarLayer1:refreshData()
	if not self._labPhysical or not self._labGold or not self._labEmerald or not self._labIngot then
		return
	end
	local _physical = gameUser.getTiliNow() or "0";
	local _maxPhysical = gameUser.getTiliMax() or "0";
	local _gold = gameUser.getGold() or "0";
	local _emerald = gameUser.getFeicui() or "0";
	local _ingot = gameUser.getIngot() or "0";
	-- 体力
    if gameUser.getTiliNow() > gameUser.getPreTiliNow() then 
        letTheLableTint(self._labPhysical,true)
    elseif gameUser.getTiliNow() < gameUser.getPreTiliNow() then 
        letTheLableTint(self._labPhysical,false)
    end 
    gameUser.setPreTiliNow(gameUser.getTiliNow())
	self._labPhysical:setString(_physical .. "/" .. _maxPhysical);
	-- 银两
    if gameUser.getGold() > gameUser.getPreGold() then 
        letTheLableTint(self._labGold,true)
    elseif gameUser.getGold() < gameUser.getPreGold() then 
        letTheLableTint(self._labGold,false)
    end 
    gameUser.setPreGold(gameUser.getGold())
	self._labGold:setString( getHugeNumberWithLongNumber(_gold,1000000));
	-- 翡翠
    if gameUser.getFeicui() > gameUser.getPreFeicui() then 
        letTheLableTint(self._labEmerald,true)
    elseif gameUser.getFeicui() < gameUser.getPreFeicui() then 
        letTheLableTint(self._labEmerald,false)
    end 
    gameUser.setPreFeicui(gameUser.getFeicui())
	self._labEmerald:setString( getHugeNumberWithLongNumber(_emerald,1000000));	
	-- 元宝
    if gameUser.getIngot() > gameUser.getPreIngot() then 
        letTheLableTint(self._labIngot,true)
    elseif gameUser.getIngot() < gameUser.getPreIngot() then 
        letTheLableTint(self._labIngot,false)
    end 
    gameUser.setPreIngot(gameUser.getIngot())
	self._labIngot:setString( getHugeNumberWithLongNumber(_ingot,1000000));
	-- 刷新当前时间
	self._labTimer:setString( os.date("%H:%M") );
end

function TopBarLayer1:onCleanup()
end

function TopBarLayer1:create(isNewBack, showPlus, showGF)
	local _layer = self.new(isNewBack, showPlus, showGF);	
	return _layer;
end

function TopBarLayer1:showBoxTips( target,index )
    local winSize = cc.Director:getInstance():getWinSize()
    local boxTips = requires("src/fsgl/common_layer/BoxTipsNode.lua")
    self._boxTips = boxTips:create({index = index})
    if self._boxTips and target then 
    	self._boxTips:setName("_boxTips")
        self._boxTips:setAnchorPoint(1,1)
        if self:getParent() then 
        	self:getParent():removeChildByName("_boxTips")
        	self:getParent():addChild(self._boxTips,2048)
    	end 
        local pos = target:convertToWorldSpace(cc.p(0,0))
        pos = self:convertToNodeSpace(pos)
        self._boxTips:setPosition(pos.x + 25,pos.y - target:getBoundingBox().height / 2)
        if self._boxTips:getPositionX() < self._boxTips:getBoundingBox().width then 
            self._boxTips:setAnchorPoint(0,1)
            self._boxTips:setPosition(pos.x + target:getBoundingBox().width - 25,pos.y - target:getBoundingBox().height / 2)
        end 
    end     
end

function TopBarLayer1:setNeedReleaseGuide( isRelase )
	self._needReleaseGuide = isRelase
end

return TopBarLayer1