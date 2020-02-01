--[[
	段位信息界面
	唐实聪
	2015.12.14
]]
local DuanWeiInfoLayer  = class( "DuanWeiInfoLayer", function ( ... )
	return XTHD.createBasePageLayer()
end )

function DuanWeiInfoLayer:ctor()
	local selfSize = self:getContentSize()
	-- 底层背景
    local bottomBg = XTHD.createSprite( "res/image/common/layer_bottomBg2.png" )
    bottomBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	bottomBg:setPosition( selfSize.width * 0.5, ( selfSize.height - self.topBarHeight ) * 0.5 )
	local bottomBgSize = bottomBg:getContentSize()
	bottomBg:setScale(0.75)
	self:addChild( bottomBg )
	
	-- 下面背景
	-- local allDuanBg = XTHD.createSprite( "res/image/plugin/duaninfo/allDuanBg.png" )
	local allDuanBg = ccui.Scale9Sprite:create( "res/image/plugin/duaninfo/allDuanBg.png" )
	allDuanBg:setContentSize(cc.size(895,369))
	-- allDuanBg:setScale(0.8)
	-- 边框
	-- local side = ccui.Scale9Sprite:create( cc.rect( 12, 12, 1, 1 ), "res/image/common/scale9_bg_25.png" )
	local side = ccui.Scale9Sprite:create()
	side:setContentSize( allDuanBg:getContentSize() )
	side:setAnchorPoint( cc.p( 0.5, 1 ) )
	side:setPosition( selfSize.width*0.5, bottomBg:getPositionY() + bottomBgSize.height*0.5 - 210 )
	getCompositeNodeWithNode( side, allDuanBg )
	self:addChild( side )
	-- 熊猫归来
	-- local xmgl = XTHD.createSprite( "res/image/plugin/duaninfo/xmgl.png" )
	-- xmgl:setAnchorPoint( cc.p( 0, 1 ) )
	-- xmgl:setPosition( 0, allDuanBg:getContentSize().height )
	-- allDuanBg:addChild( xmgl )
	-- 柱状图
	local duanInfoData = gameData.getDataFromCSV( "CompetitiveDaily" )
	local duanPath = {
		"res/image/plugin/duaninfo/qingtong.png",
		"res/image/plugin/duaninfo/baiyin.png",
		"res/image/plugin/duaninfo/huangjin.png",
		"res/image/plugin/duaninfo/baijin.png",
		"res/image/plugin/duaninfo/zuanshi.png",
		"res/image/plugin/duaninfo/dashi.png",
		"res/image/plugin/duaninfo/zongshi.png",
	}
	for i = 1, 7 do
		-- 背景
		-- local duanBg = ccui.Scale9Sprite:create( cc.rect( 50, 10, 1, 270 ), "res/image/plugin/duaninfo/duanBg.png" )
		local duanBg = ccui.Scale9Sprite:create("res/image/plugin/duaninfo/duanBg.png" )
		duanBg:setContentSize( 101, 119 + i*40 )
		duanBg:setAnchorPoint( cc.p( 0, 0 ) )
		duanBg:setPosition( 124.5*i - 101, 10 )
		allDuanBg:addChild( duanBg )
		local duanSize = duanBg:getContentSize()
		-- 图标
		local duanIcon = XTHD.createSprite( duanPath[i] )
		duanIcon:setAnchorPoint( cc.p( 0.5, 1 ) )
		duanIcon:setPosition( duanSize.width*0.5, duanSize.height )
		duanBg:addChild( duanIcon )
		--段位名字
		local name_tab = {"青铜组","白银组","黄金组","白金组","钻石组","至尊组","王者组"}
		local name = XTHDLabel:create(name_tab[i],22,"res/fonts/def.ttf")
		name:setPosition(duanIcon:getPositionX(),duanIcon:getPositionY()-duanIcon:getContentSize().height-10)
		name:enableShadow(cc.c3b(255,255,255),cc.size(0.4,-0.4),0.4)
		name:enableOutline(cc.c4b(55,54,112,255),1)
		duanBg:addChild(name)
		-- 元宝
		local ingot = duanInfoData[i]["rewardingot"]
		if ingot > 0 then
			local ingotBg = ccui.Scale9Sprite:create( cc.rect( 0, 0, 0, 0 ), "res/image/common/scale9_bg1_242.png" )
			ingotBg:setContentSize( 75, 25 )
			ingotBg:setAnchorPoint( cc.p( 0.5, 1 ) )
			ingotBg:setPosition( duanSize.width*0.5, duanSize.height - duanIcon:getBoundingBox().height - 30 )
			duanBg:addChild( ingotBg )
			local ingotNum = getCommonWhiteBMFontLabel( ingot )
			ingotNum:setPosition( ingotBg:getContentSize().width*0.5 + 5, ingotBg:getContentSize().height*0.5 - 7 )
			ingotBg:addChild( ingotNum )
			local ingotIcon = XTHD.createSprite( "res/image/imgSelHero/img_gold.png" )
			ingotIcon:setAnchorPoint( cc.p( 0, 0.5 ) )
			ingotIcon:setPosition(-25, ingotBg:getContentSize().height*0.5 )
			ingotBg:addChild( ingotIcon )
		end
		if i == 7 then
			local duanLimit = XTHD.createRichLabel({
				text = "",
		    	anchor = cc.p( 0.5, 0.5 ),
		    	pos = cc.p( duanSize.width*0.5, 35 ),
			})
			duanBg:addChild( duanLimit )
		end
	end
	-- 柱状图底部
	-- local duanBottom = ccui.Scale9Sprite:create( cc.rect( 5, 0, 9, 10 ), "res/image/plugin/duaninfo/bottom.png" )
	-- duanBottom:setContentSize( 848, 10 )
	-- duanBottom:setAnchorPoint( cc.p( 0.5, 0 ) )
	-- duanBottom:setPosition( allDuanBg:getContentSize().width*0.5, 10 )
	-- allDuanBg:addChild( duanBottom )

	-- 狐狸
	local fox = XTHD.createSprite( "res/image/plugin/duaninfo/fox.png" )
	fox:setAnchorPoint( cc.p( 0, 0 ) )
	fox:setPosition( selfSize.width*0.5 - allDuanBg:getContentSize().width*0.5, side:getPositionY()-130 )
	self:addChild( fox )
	-- 话背景
	local wordBg = ccui.Scale9Sprite:create( cc.rect( 0, 0, 0, 0 ), "res/image/plugin/duaninfo/wordBg.png" )
	wordBg:setContentSize( allDuanBg:getContentSize().width - fox:getContentSize().width + 100, 75 )
	wordBg:setAnchorPoint( cc.p( 0, 0.5 ) )
	wordBg:setScale(0.8)
	wordBg:setPosition( fox:getPositionX() + fox:getContentSize().width - 100, fox:getPositionY() + 150 )
	self:addChild( wordBg )
	-- 话
	local word = XTHD.createSprite( "res/image/plugin/duaninfo/word.png" )
	getCompositeNodeWithNode( wordBg, word )
end

function DuanWeiInfoLayer:onCleanup()
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/allDuanBg.png" )
	-- textureCache:removeTextureForKey( "res/image/plugin/duaninfo/xmgl.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/qingtong.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/baiyin.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/huangjin.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/baijin.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/zuanshi.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/dashi.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/zongshi.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/duanBg.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/bottom.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/fox.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/wordBg.png" )
	textureCache:removeTextureForKey( "res/image/plugin/duaninfo/word.png" )
end

function DuanWeiInfoLayer:create( params )
	local layer = self.new( params )
	return layer
end

return DuanWeiInfoLayer