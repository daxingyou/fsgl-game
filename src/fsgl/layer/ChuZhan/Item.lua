Item = class("Item", function ( _type, data )
-- 创建背景层
	local _item = nil;
	local _szBgFilePath = nil;
	if _type == Item.HERO then
		_szBgFilePath = XTHD.resource.getQualityItemBgPath(data["advance"])
	else
		_szBgFilePath = XTHD.resource.getQualityItemBgPath(data["advance"],"item")
	end
	-- _item = cc.Sprite:create(_szBgFilePath);
	_item = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create(_szBgFilePath),
		selectedNode = cc.Sprite:create(_szBgFilePath),
		needSwallow = false,
		enable = true,
		});

-- 构建头像图标
	local _avator = nil;
	if _type == Item.HERO then
		local xx = "res/image/imgSelHero/" .. data["heroid"] .. ".png";
		_avator = cc.Sprite:create(XTHD.resource.getHeroAvatorImgById(data["heroid"]));
	else
		_avator = cc.Sprite:create(XTHD.resource.getHeroAvatorImgById(data["itemid"]));
	end
	_avator:setPosition(cc.p(_item:getBoundingBox().width*0.5, _item:getBoundingBox().height*0.5));
	_item:addChild(_avator);

-- 创建item_buttom_mask
	local _mask = cc.Sprite:create("res/image/imgSelHero/img_ItemMask.png");
	_mask:setAnchorPoint(cc.p(0.5, 0));
	_mask:setPosition(cc.p(_item:getBoundingBox().width*0.5, 0));
	_item:addChild(_mask);

	local function _initHero( data )
		-- 初始化星星等级
		local _nStar = data["star"];
		local _stars = {};
		local __pos = SortPos:sortFromMiddle( cc.p(42, 10), _nStar, 20 );
		for i = 1, _nStar do
			local __star = cc.Sprite:create("res/image/common/item_star.png");
			__star:setPosition(__pos[i]);
			_item:addChild(__star);
			_stars[#_stars+1] = __star;
		end

		-- 获取自身大小
		local _bgWidth = _item:getBoundingBox().width;
		local _bgHeight = _item:getBoundingBox().height;
		-- 英雄等级背景图
		local _lvBg = cc.Sprite:create("res/image/common/lv_bg.png");
		_lvBg:setAnchorPoint(cc.p(0,0.5));
		_lvBg:setPosition(cc.p(2, _bgHeight*0.4));
		_item:addChild(_lvBg);
		-- 等级
		local _labLevel = XTHDLabel:createWithParams({
			text = tostring(data["level"]),
			fontSize = 18,
			});
		_labLevel:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(2,-2))
		_labLevel:setPosition(cc.p(_lvBg:getBoundingBox().width*0.5, _lvBg:getBoundingBox().height*0.5));
		_lvBg:addChild(_labLevel);
	end

	local function _initProps( data )
		local _labCount = CLabel:createWithParams({
			text = tostring(data["count"]),
			fontSize = 18,
			});
		_labCount:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(2,-2))
		_labCount:setPosition(cc.p(42, 10));
		_item:addChild(_labCount);
	end

-- 根据类型创建内容
	Item:_setType( _type );
	if _type == Item.HERO then
		_initHero(data);
	else
		_initProps(data);
	end
	return _item;
end)

Item.HERO = 1;
Item.PROPS = 2;

function Item:_setType( data )
	self.m_type = data;
end

function Item:_getType()
	return self.m_type or self.Hero;
end

function Item:addTick( data )
	if data then
		self.m_tick = cc.Sprite:create("res/image/imgSelHero/img_tick.png");
		self.m_tick:setAnchorPoint(cc.p(1, 1));
		self.m_tick:setPosition(cc.p(self:getBoundingBox().width, self:getBoundingBox().height));
		self:addChild(self.m_tick);
	else
		if self.m_tick then
			self.m_tick:removeFromParent();
			self.m_tick = nil;
		end
	end
end

function Item:setSelect( data )
	if data == self.m_bSelected then
		return;
	end
	self.m_bSelected = data;
	self:addTick(data);
end

-- 利用从数据库中取出的数据去创建
function Item:create( _type, data )
	return self.new( _type, data);
end