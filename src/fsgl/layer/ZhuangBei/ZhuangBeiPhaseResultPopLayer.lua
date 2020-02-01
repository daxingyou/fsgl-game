local ZhuangBeiPhaseResultPopLayer = class("ZhuangBeiPhaseResultPopLayer",function()
		return XTHDPopLayer:create()
	end)
function ZhuangBeiPhaseResultPopLayer:ctor(_type,_data)
	local _resoultType = _type or "failure"
	if _resoultType == "success" then
		self:initSuccesslayer(_data)
	else
		self:initFailureLayer()
	end
end
function ZhuangBeiPhaseResultPopLayer:initSuccesslayer(_data)
	local _containerLayer= self:getContainerLayer()
	_containerLayer:setClickable(false)

	-- 背景
	local background = XTHD.createSprite( "res/image/plugin/equip_layer/starupbg.png" )
	background:setScale( 2 )

	-- 容器
	local container = XTHD.createSprite()
	container:setContentSize( background:getBoundingBox() )
	container:setPosition( self:getContentSize().width*0.5, self:getContentSize().height*0.5 - 20 )
	_containerLayer:addChild( container )

	containerSize = container:getContentSize()
	background:setPosition( containerSize.width*0.5, containerSize.height*0.5 )
	container:addChild( background )

	-- 升星成功标题
	local spine = sp.SkeletonAnimation:create( "res/image/plugin/hero/starupFrames/rwsx.json", "res/image/plugin/hero/starupFrames/rwsx.atlas", 1.0)   
    spine:setPosition( containerSize.width*0.5, containerSize.height - 20 )
    container:addChild( spine )
    spine:setAnimation( 0, "idle2", true )

	-- 箭头
	local _arrow = cc.Sprite:create("res/image/plugin/hero/advanceAni_arrow.png")
	_arrow:setPosition(cc.p(containerSize.width/2,containerSize.height - 100))
	container:addChild(_arrow)
	-- before
	local _equipBefore_sp = ItemNode:createWithParams({
		_type_ = 4,
        itemId = _data.oldData.itemid,
        needSwallow = false,
        touchShowTip = false
	})
	_equipBefore_sp:setScale(65/_equipBefore_sp:getBoundingBox().width)
	_equipBefore_sp:setPosition(cc.p(containerSize.width/2-120,_arrow:getPositionY()))
	container:addChild(_equipBefore_sp)
	-- 星星
    -- dump(_data,"HeroupData")
	local befStar = tonumber( _data.oldData.phaseLevel or 0 )
	local befStarWidth = befStar*25
	if befStar > 0 then
		for i = 1, befStar do
			local star_light = sp.SkeletonAnimation:create( "res/image/plugin/hero/starupFrames/xx.json", "res/image/plugin/hero/starupFrames/xx.atlas", 1.0)
			star_light:setPosition(_equipBefore_sp:getPositionX()-befStarWidth*0.5+25*(i-0.5), _equipBefore_sp:getPositionY() - 50 )
			container:addChild( star_light )
			star_light:setAnimation( 0, "idle", true )
		end
	end
	-- 战力
	local befFight = XTHD.createSprite( "res/image/common/fightValue_Image.png" )
	local befFightNum = getCommonYellowBMFontLabel(_data.oldData.power)
	local befFightWidth = befFight:getBoundingBox().width + befFightNum:getBoundingBox().width
	befFight:setAnchorPoint(cc.p(0,0.5))
	befFight:setScale(0.9)
	befFight:setPosition( _equipBefore_sp:getPositionX()-befFightWidth*0.5, _equipBefore_sp:getPositionY() - 83 )
	container:addChild( befFight )
	befFightNum:setAnchorPoint(cc.p(1,0.5))
	befFightNum:setPosition( _equipBefore_sp:getPositionX()+befFightWidth*0.5, befFight:getPositionY() - 6 )
	container:addChild( befFightNum )

	-- after
	local _equipAfter_sp = ItemNode:createWithParams({
		_type_ = 4,
        itemId = _data.newData.itemId,
        needSwallow = false,
        touchShowTip = false
	})
	_equipAfter_sp:setScale(65/_equipAfter_sp:getBoundingBox().width)
	_equipAfter_sp:setPosition(cc.p(containerSize.width/2+120,_arrow:getPositionY()))
	container:addChild(_equipAfter_sp)
	-- 星星
	local aftStar = tonumber( _data.newData.phaseLevel or 0 )
	local aftStarWidth = aftStar*25
	if aftStar > 0 then
		for i = 1, aftStar - 1 do
			local star_light = sp.SkeletonAnimation:create( "res/image/plugin/hero/starupFrames/xx.json", "res/image/plugin/hero/starupFrames/xx.atlas", 1.0)
			star_light:setPosition(_equipAfter_sp:getPositionX()-aftStarWidth*0.5+25*(i-0.5), _equipAfter_sp:getPositionY() - 50 )
			container:addChild( star_light )
			star_light:setAnimation( 0, "idle", true )
		end
		local lastStar = sp.SkeletonAnimation:create( "res/image/plugin/hero/starupFrames/xx.json", "res/image/plugin/hero/starupFrames/xx.atlas", 1.0)
		lastStar:setPosition(_equipAfter_sp:getPositionX()-aftStarWidth*0.5+25*(aftStar-0.5), _equipAfter_sp:getPositionY() - 50 )
		container:addChild( lastStar )
		lastStar:setAnimation( 0, "atk", false )
	    lastStar:addAnimation( 0, "idle", true )
	end
	-- 战力
	local aftFight = XTHD.createSprite( "res/image/common/fightValue_Image.png" )
	local aftFightNum = getCommonYellowBMFontLabel(_data.newData.power)
	local aftFightWidth = aftFight:getBoundingBox().width + aftFightNum:getBoundingBox().width
	aftFight:setAnchorPoint(cc.p(0,0.5))
	aftFight:setScale(0.9)
	aftFight:setPosition( _equipAfter_sp:getPositionX()-aftFightWidth*0.5, _equipAfter_sp:getPositionY() - 83 )
	container:addChild( aftFight )
	aftFightNum:setAnchorPoint(cc.p(1,0.5))
	aftFightNum:setPosition( _equipAfter_sp:getPositionX()+aftFightWidth*0.5, aftFight:getPositionY() - 6 )
	container:addChild( aftFightNum )

	-- 属性
	for i, v in ipairs(_data.property) do
		local propertyY = _equipAfter_sp:getPositionY() - 90 - 30*i
		-- 原属性
		local befTextLabel = XTHDLabel:create(v.name..":",20)
		befTextLabel:setColor(cc.c4b(255,207,139))
		befTextLabel:enableShadow(cc.c4b(),cc.size(0.4,-0.4),0.4)
		befTextLabel:setAnchorPoint( cc.p( 1, 0.5 ) )
		befTextLabel:setPosition(containerSize.width*0.5-70,propertyY)
		container:addChild( befTextLabel )
		local befNumLabel = getCommonWhiteBMFontLabel(" "..v.bef)
		befNumLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
		befNumLabel:setPosition( befTextLabel:getPositionX() + 10, propertyY-7 )
		container:addChild( befNumLabel )
		-- 升星后属性
		local arrowSp = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
		arrowSp:setRotation(90)
		arrowSp:setAnchorPoint(cc.p(1,0.5))
		arrowSp:setPosition(containerSize.width*0.5+70,propertyY-7)
		container:addChild(arrowSp)
		local aftNumLabel = getCommonGreenBMFontLabel(" "..v.aft)
		aftNumLabel:setScale(0.7)
		aftNumLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
		aftNumLabel:setPosition( arrowSp:getPositionX()+20, propertyY )
		container:addChild( aftNumLabel )
	end

	
	
    -- 点击屏幕继续
    performWithDelay(self, function()
    	local _tips = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_CLICKSCENEIN,XTHD.SystemFont,18)
	    _tips:setColor(cc.c4b(255,240,216,255))
	    _tips:setPosition(containerSize.width / 2,-15)
	    container:addChild(_tips)
		_containerLayer:setClickable(true)
	end,0.5)

	self:show()
end

function ZhuangBeiPhaseResultPopLayer:initFailureLayer()
	self:show(false)
	local _containerLayer = self:getContainerLayer()
	local _failureSp = sp.SkeletonAnimation:create("res/spine/effect/equip/jjsb.json", "res/spine/effect/equip/jjsb.atlas",1.0)
	_failureSp:setPosition(cc.p(_containerLayer:getContentSize().width/2,_containerLayer:getContentSize().height/2))
	_failureSp:setAnimation(0,"atk",false)
	_failureSp:addAnimation(0,"idle",true)
	_containerLayer:addChild(_failureSp)
end

function ZhuangBeiPhaseResultPopLayer:create(_type,_data)
	local _layer = self.new(_type,_data)
	return _layer
end

return ZhuangBeiPhaseResultPopLayer
