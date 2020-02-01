--[[
	图鉴英雄界面
	唐实聪
	2015.11.25
]]
local TuJianHeroLayer  = class( "TuJianHeroLayer", function( ... )
	return XTHD.createBasePageLayer()
end)

function TuJianHeroLayer:create( params )
	return self.new( params )
end
function TuJianHeroLayer:ctor( params )
	self:initData( params )
	self:initUI()
	self:refreshUI()
end
function TuJianHeroLayer:onCleanup()
	if self._callBack then
		self._callBack( self._heroList[self._heroIndex].id )
	end
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey( "res/image/plugin/hero/heroTitle_bg.png" )
	textureCache:removeTextureForKey( "res/image/ranklistreward/splitX.png" )
	textureCache:removeTextureForKey( "res/image/illustration/progressbg.png" )
	textureCache:removeTextureForKey( "res/image/illustration/progress.png" )
	textureCache:removeTextureForKey( "res/image/ranklistreward/splitY.png" )
	textureCache:removeTextureForKey( "res/image/illustration/cloud.png" )
	-- textureCache:removeTextureForKey( "res/image/common/star_dark.png" )
	-- textureCache:removeTextureForKey( "res/image/common/star_light.png" )
	textureCache:removeTextureForKey( "res/image/illustration/namebg.png" )
	textureCache:removeTextureForKey( "res/image/illustration/otherbg.png" )
	textureCache:removeTextureForKey( "res/image/illustration/recommend.png" )
	textureCache:removeTextureForKey( "res/image/illustration/recommondtext.png" )
	textureCache:removeTextureForKey( "res/image/illustration/fetter.png" )
	textureCache:removeTextureForKey( "res/image/illustration/fettertext.png" )
	textureCache:removeTextureForKey( "res/image/illustration/selected.png" )
	textureCache:removeTextureForKey( "res/image/plugin/stageChapter/btn_left_arrow.png" )
	textureCache:removeTextureForKey( "res/image/plugin/stageChapter/btn_right_arrow.png" )
end
function TuJianHeroLayer:initData( params )
	-- dump( params, "initData" )
	self._callBack = params.callBack
	self._heroId = params.id
	-- ui
	-- self._star = {}
	self._recommondPop = nil
	self._fetterPop = nil
	-- data
	self._heroList = gameData.getDataFromCSV( "HeroData" )
	local rankList = gameData.getDataFromCSV( "GeneralInfoList" )
	for i, v in ipairs( self._heroList ) do
		v.rank = gameData.getDataFromCSV( "GeneralInfoList",{heroid = v.id} ).rank
	end
	table.sort( self._heroList, function( a, b )
		if a["mode"..params.sort.."class"] ~= b["mode"..params.sort.."class"] then
			return a["mode"..params.sort.."class"] < b["mode"..params.sort.."class"]
		elseif a.rank ~= b.rank then
			return a.rank > b.rank
		else
			return a.id < b.id
		end
	end)
	-- dump( self._heroList, "sorted" )
	self._heroIndex = self:searchIndexById( params.id )
	self._heroCell = nil
	self._skillList = {}
	self._animation = 1
	math.newrandomseed()
end
-- 创建界面
function TuJianHeroLayer:initUI()
	-- 通用背景
	local bottomBg = XTHD.createSprite( "res/image/common/layer_bottomBg.png" )
	self._size = bottomBg:getContentSize()
    bottomBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	bottomBg:setPosition( self:getContentSize().width * 0.5, ( self:getContentSize().height - self.topBarHeight )*0.5 )
	self._bg = bottomBg
	self:addChild( bottomBg )

	local title = "res/image/public/heroxiangqing_title.png"
	XTHD.createNodeDecoration(self._bg,title)

	self._middleSize = cc.size( self._size.width*0.36, self._size.height*0.5 + bottomBg:getContentSize().height*0.5 - 151 )
	self._rightSize = cc.size( self._size.width*0.31, self._size.height*0.5 + bottomBg:getContentSize().height*0.5 - 151 )
	self._leftSize = cc.size( self._size.width - self._middleSize.width - self._rightSize.width, self._size.height*0.5 + bottomBg:getContentSize().height*0.5 - 151 )
	self._bottomSize = cc.size( self._size.width, 111 )
	-- 中间
	self:initMiddle()
	-- 右边
	self:initRight()
	-- 左边
	self:initLeft()
	-- 底部
	self:initBottom()
end
-- 中间
function TuJianHeroLayer:initMiddle()
	-- 容器
	local middleContainer = XTHD.createSprite()
	middleContainer:setContentSize( self._middleSize )
	middleContainer:setAnchorPoint( cc.p( 0, 0 ) )
	middleContainer:setPosition( self._bg:getContentSize().width/4 + 50, self._bottomSize.height )
	self._bg:addChild( middleContainer )

	--英雄介绍框
    local kuang1 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
    kuang1:setPosition(self._middleSize.width*0.5, self._middleSize.height - 70)
    --设置一下框的大小
    kuang1:setContentSize(self._middleSize.width,155)
	middleContainer:addChild(kuang1)
	
	-- 英雄介绍标题背景
	local descriptionTitleBg = XTHD.createSprite( "res/image/plugin/hero/YXJS.png" )
	descriptionTitleBg:setAnchorPoint( cc.p( 0.5, 1 ) )
	descriptionTitleBg:setPosition( self._middleSize.width*0.5, self._middleSize.height + 20 )
	middleContainer:addChild( descriptionTitleBg )
	-- 英雄介绍标题
	local descriptionTitle = XTHD.createLabel({
		text = LANGUAGE_KEY_HERO_TEXT.heroIntroduceTextXc,
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		clickable = false,
	})
	descriptionTitle:setOpacity(0)
	getCompositeNodeWithNode( descriptionTitleBg, descriptionTitle )
	-- 英雄介绍
	self._description = XTHD.createLabel({
		fontSize  = 16,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 0.5, 1 ),
		pos = cc.p( self._middleSize.width*0.5, self._middleSize.height - 10 ),
		clickable = false,
	})
	self._description:setWidth( self._middleSize.width - 40 )
	middleContainer:addChild( self._description )
	-- 英雄签名
	self._autograph = XTHD.createLabel({
		fontSize  = 16,
		color     = cc.c3b( 178, 118, 117 ),
		anchor = cc.p( 0.5, 0 ),
		pos = cc.p( self._middleSize.width*0.5, 225 ),
		clickable = false,
	})
	middleContainer:addChild( self._autograph )

	-- 分界线
	-- local splitLine = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
	-- splitLine:setContentSize( self._middleSize.width, 2 )
	-- splitLine:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	-- splitLine:setPosition( self._middleSize.width*0.5, 240 )
	-- middleContainer:addChild( splitLine )

	local kuang2 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
    kuang2:setPosition(self._middleSize.width*0.5, self._middleSize.height - 278)
    --设置一下框的大小
    kuang2:setContentSize(self._middleSize.width,230)
	middleContainer:addChild(kuang2)

	-- 英雄属性标题背景
	local propertyTitleBg = XTHD.createSprite("res/image/illustration/yxsx.png")
	propertyTitleBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	propertyTitleBg:setPosition( kuang2:getContentSize().width*0.5, kuang2:getContentSize().height )
	kuang2:addChild( propertyTitleBg )
	-- -- 英雄属性标题
	-- local propertyTitle = XTHD.createLabel({
	-- 	text = LANGUAGE_KEY_HERO_TEXT.heroPropertyTextXc,
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 70, 34, 34 ),
	-- 	clickable = false,
	-- })
	-- getCompositeNodeWithNode( propertyTitleBg, propertyTitle )

	local lineDis = 36
	local beginY = 140

	-- 生命评分文字
	local hpText = XTHD.createLabel({
		text = LANGUAGE_ILLUSTRATION_HEROSCORE[1],
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 1, 0.5 ),
		pos = cc.p( 105, beginY ),
		clickable = false,
	})
	middleContainer:addChild( hpText )
	-- 生命进度条
	local hpProgressBg = XTHD.createSprite( "res/image/illustration/progressbg.png" )
	hpProgressBg:setScaleX(0.6)
    hpProgressBg:setAnchorPoint( 0, 0.5 )
    hpProgressBg:setPosition( 108, hpText:getPositionY() )
    middleContainer:addChild( hpProgressBg )
    self._hpProgress = cc.ProgressTimer:create( cc.Sprite:create( "res/image/illustration/progress.png" ) )
    self._hpProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._hpProgress:setBarChangeRate( cc.p( 1, 0 ) )
    self._hpProgress:setMidpoint( cc.p( 0, 0.5 ) )
    self._hpProgress:setPosition( hpProgressBg:getContentSize().width*0.5, hpProgressBg:getContentSize().height*0.55 )
    hpProgressBg:addChild( self._hpProgress )
	-- 生命评分
	self._hpNum = XTHD.createLabel({
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( 300, hpText:getPositionY() ),
		clickable = false,
	})
	middleContainer:addChild( self._hpNum )

	-- 物攻评分文字
	local atText = XTHD.createLabel({
		text = LANGUAGE_ILLUSTRATION_HEROSCORE[2],
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 1, 0.5 ),
		pos = cc.p( 105, beginY - lineDis ),
		clickable = false,
	})
	middleContainer:addChild( atText )
	-- 物攻进度条
	local atProgressBg = XTHD.createSprite( "res/image/illustration/progressbg.png" )
	atProgressBg:setScaleX(0.6)
    atProgressBg:setAnchorPoint( 0, 0.5 )
    atProgressBg:setPosition( 108, atText:getPositionY() )
    middleContainer:addChild( atProgressBg )
    self._atProgress = cc.ProgressTimer:create( cc.Sprite:create( "res/image/illustration/progress.png" ) )
    self._atProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._atProgress:setBarChangeRate( cc.p( 1, 0 ) )
    self._atProgress:setMidpoint( cc.p( 0, 0.5 ) )
    self._atProgress:setPosition( atProgressBg:getContentSize().width*0.5, atProgressBg:getContentSize().height*0.55 )
    atProgressBg:addChild( self._atProgress )
	-- 物攻评分
	self._atNum = XTHD.createLabel({
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( 300, atText:getPositionY() ),
		clickable = false,
	})
	middleContainer:addChild( self._atNum )

	-- 物防评分文字
	local dfText = XTHD.createLabel({
		text = LANGUAGE_ILLUSTRATION_HEROSCORE[3],
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 1, 0.5 ),
		pos = cc.p( 105, beginY - lineDis*2 ),
		clickable = false,
	})
	middleContainer:addChild( dfText )
	-- 物防进度条
	local dfProgressBg = XTHD.createSprite( "res/image/illustration/progressbg.png" )
	dfProgressBg:setScaleX(0.6)
    dfProgressBg:setAnchorPoint( 0, 0.5 )
    dfProgressBg:setPosition( 108, dfText:getPositionY() )
    middleContainer:addChild( dfProgressBg )
    self._dfProgress = cc.ProgressTimer:create( cc.Sprite:create( "res/image/illustration/progress.png" ) )
    self._dfProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._dfProgress:setBarChangeRate( cc.p( 1, 0 ) )
    self._dfProgress:setMidpoint( cc.p( 0, 0.5 ) )
    self._dfProgress:setPosition( dfProgressBg:getContentSize().width*0.5, dfProgressBg:getContentSize().height*0.55 )
    dfProgressBg:addChild( self._dfProgress )
	-- 物防评分
	self._dfNum = XTHD.createLabel({
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( 300, dfText:getPositionY() ),
		clickable = false,
	})
	middleContainer:addChild( self._dfNum )

	-- 魔攻评分文字
	local matText = XTHD.createLabel({
		text = LANGUAGE_ILLUSTRATION_HEROSCORE[4],
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 1, 0.5 ),
		pos = cc.p( 105, beginY - lineDis*3 ),
		clickable = false,
	})
	middleContainer:addChild( matText )
	-- 魔攻进度条
	local matProgressBg = XTHD.createSprite( "res/image/illustration/progressbg.png" )
	matProgressBg:setScaleX(0.6)
    matProgressBg:setAnchorPoint( 0, 0.5 )
    matProgressBg:setPosition( 108, matText:getPositionY() )
    middleContainer:addChild( matProgressBg )
    self._matProgress = cc.ProgressTimer:create( cc.Sprite:create( "res/image/illustration/progress.png" ) )
    self._matProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._matProgress:setBarChangeRate( cc.p( 1, 0 ) )
    self._matProgress:setMidpoint( cc.p( 0, 0.5 ) )
    self._matProgress:setPosition( matProgressBg:getContentSize().width*0.5, matProgressBg:getContentSize().height*0.55 )
    matProgressBg:addChild( self._matProgress )
	-- 魔攻评分
	self._matNum = XTHD.createLabel({
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( 300, matText:getPositionY() ),
		clickable = false,
	})
	middleContainer:addChild( self._matNum )

	-- 魔防评分文字
	local mdfText = XTHD.createLabel({
		text = LANGUAGE_ILLUSTRATION_HEROSCORE[5],
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 1, 0.5 ),
		pos = cc.p( 105, beginY - lineDis*4 ),
		clickable = false,
	})
	middleContainer:addChild( mdfText )
	-- 魔防进度条
	local mdfProgressBg = XTHD.createSprite( "res/image/illustration/progressbg.png" )
	mdfProgressBg:setScaleX(0.6)
    mdfProgressBg:setAnchorPoint( 0, 0.5 )
    mdfProgressBg:setPosition( 108, mdfText:getPositionY() )
    middleContainer:addChild( mdfProgressBg )
    self._mdfProgress = cc.ProgressTimer:create( cc.Sprite:create( "res/image/illustration/progress.png" ) )
    self._mdfProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._mdfProgress:setBarChangeRate( cc.p( 1, 0 ) )
    self._mdfProgress:setMidpoint( cc.p( 0, 0.5 ) )
    self._mdfProgress:setPosition( mdfProgressBg:getContentSize().width*0.5, mdfProgressBg:getContentSize().height*0.55 )
    mdfProgressBg:addChild( self._mdfProgress )
	-- 魔防评分
	self._mdfNum = XTHD.createLabel({
		fontSize  = 18,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( 300, mdfText:getPositionY() ),
		clickable = false,
	})
	middleContainer:addChild( self._mdfNum )

	-- -- 辅助评分文字
	-- local astText = XTHD.createLabel({
	-- 	text = LANGUAGE_ILLUSTRATION_HEROSCORE[6],
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 70, 34, 34 ),
	-- 	anchor = cc.p( 1, 0.5 ),
	-- 	pos = cc.p( 105, 30 ),
	-- 	clickable = false,
	-- })
	-- middleContainer:addChild( astText )
	-- -- 辅助进度条
	-- local astProgressBg = XTHD.createSprite( "res/image/illustration/progressbg.png" )
 --    astProgressBg:setAnchorPoint( 0, 0.5 )
 --    astProgressBg:setPosition( 108, astText:getPositionY() )
 --    middleContainer:addChild( astProgressBg )
 --    self._astProgress = cc.ProgressTimer:create( cc.Sprite:create( "res/image/illustration/progress.png" ) )
 --    self._astProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
 --    self._astProgress:setBarChangeRate( cc.p( 1, 0 ) )
 --    self._astProgress:setMidpoint( cc.p( 0, 0.5 ) )
 --    self._astProgress:setPosition( astProgressBg:getBoundingBox().width*0.5, astProgressBg:getBoundingBox().height*0.5 )
 --    astProgressBg:addChild( self._astProgress )
	-- -- 辅助评分
	-- self._astNum = XTHD.createLabel({
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 70, 34, 34 ),
	-- 	anchor = cc.p( 0, 0.5 ),
	-- 	pos = cc.p( 300, astText:getPositionY() ),
	-- 	clickable = false,
	-- })
	-- middleContainer:addChild( self._astNum )
end
-- 右边
function TuJianHeroLayer:initRight()
	-- 容器
	local rightContainer = XTHD.createSprite()
	rightContainer:setContentSize( self._rightSize )
	rightContainer:setAnchorPoint( cc.p( 1, 0 ) )
	rightContainer:setPosition( self._size.width - 15, self._bottomSize.height )
	self._bg:addChild( rightContainer )

	--英雄特点框
    local kuang1 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
    kuang1:setPosition(self._middleSize.width*0.5-20, self._middleSize.height - 70)
    --设置一下框的大小
    kuang1:setContentSize(self._middleSize.width-70,155)
	rightContainer:addChild(kuang1)

	-- 分隔
	-- local splitY = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
	-- splitY:setContentSize( self._rightSize.height, 2 )
	-- splitY:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	-- splitY:setPosition( 0, self._rightSize.height*0.5 )
	-- splitY:setRotation( 90 )
	-- rightContainer:addChild( splitY )
	-- 英雄特点标题背景
	local featureTitleBg = XTHD.createSprite("res/image/illustration/yxtd.png")
	featureTitleBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	featureTitleBg:setPosition( kuang1:getContentSize().width*0.5, kuang1:getContentSize().height - 3)
	kuang1:addChild( featureTitleBg )
	-- -- 英雄特点标题
	-- local featureTitle = XTHD.createLabel({
	-- 	text = LANGUAGE_ILLUSTRATION_HEROINFO[1],
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 70, 34, 34 ),
	-- 	clickable = false,
	-- })
	-- getCompositeNodeWithNode( featureTitleBg, featureTitle )
	-- 英雄特点
	self._feature = XTHD.createLabel({
		fontSize  = 16,
		color     = cc.c3b( 54, 55, 112 ),
		anchor = cc.p( 0.5, 1 ),
		pos = cc.p( self._rightSize.width*0.5+5, self._rightSize.height - 10 ),
		clickable = false,
	})
	self._feature:setWidth( self._rightSize.width - 50 )
	rightContainer:addChild( self._feature )

	-- -- 分界线
	-- local splitLine = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
	-- splitLine:setContentSize( self._rightSize.width, 2 )
	-- splitLine:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	-- splitLine:setPosition( self._rightSize.width*0.5, 240 )
	-- rightContainer:addChild( splitLine )

	local kuang2 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
    kuang2:setPosition(self._middleSize.width*0.5-20, self._middleSize.height - 278)
    --设置一下框的大小
    kuang2:setContentSize(self._middleSize.width-70,230)
	rightContainer:addChild(kuang2)

	-- 英雄技能标题背景
	local skillTitleBg = XTHD.createSprite("res/image/illustration/yxjn.png")
	skillTitleBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	skillTitleBg:setPosition( kuang2:getContentSize().width*0.5, kuang2:getContentSize().height + 1 )
	kuang2:addChild( skillTitleBg )
	-- 英雄技能标题
	-- local skillTitle = XTHD.createLabel({
	-- 	text = LANGUAGE_ILLUSTRATION_HEROINFO[2],
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 70, 34, 34 ),
	-- 	clickable = false,
	-- })
	-- getCompositeNodeWithNode( skillTitleBg, skillTitle )

	-- 英雄技能
	self._skillTableView = cc.TableView:create( cc.size( self._rightSize.width - 24, 176 ) )
	self._skillTableView:setPosition( 12, -15 )
	self._skillTableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	self._skillTableView:setDelegate()
	self._skillTableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	local function numberOfCellsInTableView( table )
		return math.ceil(#self._skillList/3)
	end
	local function cellSizeForTable( table, index )
		return self._skillTableView:getContentSize().width,88
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
		if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end
        for i = 1, 3 do
        	if self._skillList[index*3 + i] then
        		local skillIcon = JiNengItem:createSkillById( tonumber( self._skillList[index*3 + i] ) )
        		-- show tip pos
        		skillIcon:setTipPosition( function()
        			local tmpPos = skillIcon:convertToWorldSpace(cc.p(0,0))
					local tipsBg = skillIcon:getTips()

					tipsBg:setAnchorPoint( cc.p( 1, 0 ) )
					tipsBg:setPosition( tmpPos.x, tmpPos.y )

					cc.Director:getInstance():getRunningScene():addChild(tipsBg)
					tipsBg:setScale(0)
			        tipsBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.05),cc.ScaleTo:create(0.01,1)))
        		end )
        		skillIcon:setSwallowTouches( false )
        		skillIcon:setScale( 0.7 )
        		skillIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
        		skillIcon:setPosition( self._skillTableView:getContentSize().width/3*( i - 0.5 ), 44 )
        		cell:addChild( skillIcon )
        	end
        end
        return cell
    end
    self._skillTableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    self._skillTableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    self._skillTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    rightContainer:addChild( self._skillTableView )
end
-- 左边
function TuJianHeroLayer:initLeft()
	-- 容器
	local leftContainer = XTHD.createSprite()
	leftContainer:setContentSize( self._leftSize )
	leftContainer:setAnchorPoint( cc.p( 0, 0 ) )
	leftContainer:setPosition( -15, self._bottomSize.height - 10 )
	self._bg:addChild( leftContainer )
	-- 分界
	-- local splitSprite = XTHD.createSprite( "res/image/ranklistreward/splitY.png" )
	-- splitSprite:setAnchorPoint( cc.p( 1, 0.5 ) )
	-- splitSprite:setScaleY( self._leftSize.height/splitSprite:getContentSize().height )
	-- splitSprite:setPosition( self._leftSize.width, self._leftSize.height*0.5 )
	-- leftContainer:addChild( splitSprite )
	-- local splitY = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
	-- splitY:setContentSize( self._leftSize.height, 2 )
	-- splitY:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	-- splitY:setPosition( self._leftSize.width, self._leftSize.height*0.5 )
	-- splitY:setRotation( 90 )
	-- leftContainer:addChild( splitY )
	-- -- 顶部云朵
	-- local topCloud = XTHD.createSprite( "res/image/illustration/cloud.png" )
	-- topCloud:setFlippedY( true )
	-- topCloud:setAnchorPoint( cc.p( 1, 1 ) )
	-- topCloud:setPosition( self._leftSize.width, self._leftSize.height )
	-- leftContainer:addChild( topCloud )
	-- -- 底部云朵
	-- local bottomCloud = XTHD.createSprite( "res/image/illustration/cloud.png" )
	-- bottomCloud:setAnchorPoint( cc.p( 1, 0 ) )
	-- bottomCloud:setPosition( self._leftSize.width, 0 )
	-- leftContainer:addChild( bottomCloud )
	-- 英雄预览背景
	self._heroBg = cc.Sprite:create( "res/image/plugin/hero/heroBg_Image.png" )
 	self._heroBg:setPosition( self._leftSize.width*0.5, ( self._leftSize.height + 145 )*0.5 )
 	leftContainer:addChild( self._heroBg )
	-- 星级
	-- for i = 1, 5 do
	-- 	local starDark = XTHD.createSprite( "res/image/common/star_dark.png" )
	-- 	starDark:setAnchorPoint( cc.p( 0, 0 ) )
	-- 	starDark:setPosition( 20, 215 + i*25 )
	-- 	leftContainer:addChild( starDark )
	-- end
	-- for i = 1, 5 do
	-- 	self._star[i] = XTHD.createSprite( "res/image/common/star_light.png" )
	-- 	self._star[i]:setAnchorPoint( cc.p( 0, 0 ) )
	-- 	self._star[i]:setPosition( 20, 215 + i*25 )
	-- 	leftContainer:addChild( self._star[i] )
	-- end
	-- 英雄名字背景
	local nameBg = XTHD.createSprite( "res/image/illustration/name_bg.png" )
	nameBg:setAnchorPoint( cc.p( 0.5, 0 ) )
	nameBg:setPosition( self._leftSize.width*0.5, 100 )
	leftContainer:addChild( nameBg )
	-- 英雄名字
	self._name = XTHD.createLabel({
		fontSize  = 20,
		clickable = false,
	})
	self._name:setColor(cc.c3b(70, 34, 34))
	getCompositeNodeWithNode( nameBg, self._name )
	-- 推荐阵容背景
	local recommendBg = XTHD.createSprite( "res/image/illustration/otherbg.png" )
	recommendBg:setAnchorPoint( cc.p( 1, 0 ) )
	recommendBg:setPosition( self._leftSize.width*0.5 +40, 20 )
	recommendBg:setOpacity(0)
	leftContainer:addChild( recommendBg )
	-- 推荐阵容
	local recommendBtn = XTHD.createButton({
		normalFile = "res/image/illustration/recommend.png",
		selectedFile = "res/image/illustration/recommend2.png"
	})
	recommendBtn:setScale(0.8)
	
	recommendBtn:setTouchBeganCallback(function()
		recommendBtn:setScale(0.78)
	end)

	recommendBtn:setTouchMovedCallback(function()
		recommendBtn:setScale(0.8)
	end)

	recommendBtn:setTouchEndedCallback(function()
		recommendBtn:setScale(0.8)
		local layer = requires("src/fsgl/layer/JiBan/JiBanLayer.lua"):create(self._heroId)
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
--		if self._fetterPop then
--			self._fetterPop:hide()
--			self._fetterPop = nil
--			return
--		end

--		-- 数据
--		local recommendData = string.split( self._heroList[self._heroIndex].recommendteam, "&" )
--		for i, v in ipairs(recommendData) do
--			recommendData[i] = string.split( v, "|" )
--			recommendData[i][2] = string.split( recommendData[i][2], "#" )
--		end
--		-- dump( recommendData, "recommendData" )
--		local recommendOutHeight = 0
--		local recommendInnerHeight = 0
--		-- 弹窗
--		self._recommondPop = XTHD.createPopLayer({opacityValue = 0})
--		self._recommondPop._containerLayer:setAnchorPoint( cc.p( 0, 0 ) )
--		self._recommondPop._containerLayer:setPosition( 0, recommendBtn:getContentSize().height)
--		self._recommondPop:setHideCallback(function()
--			self._recommondPop = nil
--		end)
--		recommendBtn:addChild( self._recommondPop )
--		self._recommondPop:show()
--		-- 背景
--		local popBg = ccui.Scale9Sprite:create( "res/image/common/scale9_bg2_25.png" )
--		popBg:setAnchorPoint( cc.p( 0, 0 ) )
--		-- popBg:setOpacity(0)
--		popBg:setPosition( 0, 5 )
--		self._recommondPop:addContent( popBg )
--		-- scrollview
--		local recommondScrollView = ccui.ScrollView:create()
--		popBg:addChild( recommondScrollView )
--		recommondScrollView:setAnchorPoint( 0, 0 )
--		recommondScrollView:setPosition( 0, 0 )
--		recommondScrollView:setTouchEnabled( true )
--		recommondScrollView:setDirection( ccui.ScrollViewDir.vertical )
--		for i = #recommendData, 1, -1 do
--			if i == 1 then
--				recommendOutHeight = recommendInnerHeight
--			end
--			local data = recommendData[i]
--			-- 隔离
--	    	local split = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
--			split:setContentSize( 393, 2 )
--			split:setAnchorPoint( cc.p( 0.5, 0.5 ) )
--			split:setPosition( 393*0.5, recommendInnerHeight )
--			split:setFlippedY( true )
--			recommondScrollView:addChild( split )
--			-- 优点
--	    	local recommendAdventage = RichLabel:createARichText( string.format("<color=#D46134 fontSize=18 >%s</color><color=#6D2C2A fontSize=18 >%s</color>", "阵容优点:", data[3] ), false, 373 )
--	    	recommendInnerHeight = recommendInnerHeight + recommendAdventage:getContentSize().height
--	    	recommendAdventage:setAnchorPoint( cc.p( 0.5, 0 ) )
--			recommendAdventage:setPosition( 393*0.5, recommendInnerHeight + 4 )
--	    	recommondScrollView:addChild( recommendAdventage )
--	    	-- 头像
--	    	for j, v in ipairs( data[2] ) do
--	    		local heroIcon = HeroNode:createWithParams({
--		        	heroid = tonumber( v ),
--		        	level = -1,
--		        	advance = 1,
--		        	star = -1,--self._heroList[self:searchIndexById( tonumber( v ) )].mode3class,
--	        	})
--	        	heroIcon:setScale( 0.75 )
--	        	heroIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
--	        	heroIcon:setPosition( 78*j - 39, recommendInnerHeight + 40 )
--	        	recommondScrollView:addChild( heroIcon )
--	    	end
--	    	recommendInnerHeight = recommendInnerHeight + 80
--			-- 名称
--			--推荐队友
--		    local recommendName = XTHD.createLabel({
--		    	text = data[1],
--				fontSize  = 18,
--				color     = cc.c3b( 20, 114, 145 ),
--				anchor = cc.p( 0, 0 ),
--				pos = cc.p( 10, recommendInnerHeight ),
--				clickable = false,	
--	    	})
--	    	recommondScrollView:addChild( recommendName )
--	    	recommendInnerHeight = recommendInnerHeight + 27
--		end
--		recommendOutHeight = recommendInnerHeight - recommendOutHeight
--		if #recommendData > 1 then
--			recommondScrollView:setBounceEnabled( true )
--			self._recommondPop._containerLayer:setContentSize( 393, recommendOutHeight + 105 )
--			popBg:setContentSize( 393, recommendOutHeight + 100 )
--			recommondScrollView:setContentSize( 393, recommendOutHeight + 100 )
--		else
--			recommondScrollView:setBounceEnabled( false )
--			self._recommondPop._containerLayer:setContentSize( 393, recommendOutHeight+50 )
--			popBg:setContentSize( 393, recommendOutHeight+50 )
--			recommondScrollView:setContentSize( 393, recommendOutHeight+50 )
--		end
--		recommondScrollView:setInnerContainerSize( cc.size( 393, recommendInnerHeight ) )
	end)
	getCompositeNodeWithNode( recommendBg, recommendBtn )
	-- -- 推荐阵容文字
	-- local recommendText = XTHD.createSprite( "res/image/illustration/recommondtext.png" )
	-- recommendText:setPosition( recommendBg:getContentSize().width*0.5, 10 )
	-- recommendBg:addChild( recommendText )

	-- -- 羁绊文字
	-- local fetterText = XTHD.createSprite( "res/image/illustration/fettertext.png" )
	-- fetterText:setPosition( fetterBg:getContentSize().width*0.5, 10 )
	-- fetterBg:addChild( fetterText )
end
-- 底部
function TuJianHeroLayer:initBottom()
	-- 背景
	local bottomBg = ccui.Scale9Sprite:create(cc.rect(100,0,800,111),"res/image/common/scale9_bg_31.png")
	bottomBg:setOpacity(0)
	bottomBg:setContentSize( self._bottomSize )
	bottomBg:setAnchorPoint( cc.p( 0.5, 0 ) )
	bottomBg:setPosition( self._bottomSize.width*0.5,  - 30 )
	self._bg:addChild( bottomBg )

	local cellWidth = 104
	-- 中间头像
	self._heroIconTableView = cc.TableView:create( cc.size( cellWidth*8, self._bottomSize.height ) )
	self._heroIconTableView:setPosition( cc.p( ( bottomBg:getContentSize().width - cellWidth*8 )*0.5, 0 ) )
    self._heroIconTableView:setBounceable(true)
    self._heroIconTableView:setDirection( cc.SCROLLVIEW_DIRECTION_HORIZONTAL ) --设置横向纵向
    self._heroIconTableView:setDelegate()
    TableViewPlug.init(self._heroIconTableView)
    local function numberOfCellsInTableView( table )
		return #self._heroList
	end
	local function cellSizeForTable( table, index )
		return self._bottomSize.height, cellWidth
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
		if cell then
	        cell:removeAllChildren()
	    else
	        cell = cc.TableViewCell:new()
	    end
	    local heroIndex = index + 1
	    local heroData = self._heroList[heroIndex]
	    local heroIcon = HeroNode:createWithParams({
	    	heroid = heroData.id,
	    	level = -1,
	    	advance = 1,
	    	isShowType = true,
	    	star = -1,--heroData.mode3class,
		})
    	heroIcon:setScale( 92/heroIcon:getContentSize().width )
    	heroIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    	heroIcon:setPosition( cellWidth*0.5, self._bottomSize.height*0.5 )
		cell:addChild( heroIcon )
	    
		-- normal
		local heroIconBtn_normal = XTHD.createSprite()
		heroIconBtn_normal:setContentSize( heroIcon:getContentSize() )
		-- selected
		-- local heroIconBtn_selected = ccui.Scale9Sprite:create( cc.rect( 10, 10, 2, 2 ), "res/image/illustration/selected.png" )
		local heroIconBtn_selected = ccui.Scale9Sprite:create("res/image/illustration/selected.png" )
		-- heroIconBtn_selected:setContentSize( heroIcon:getContentSize().width+30,heroIcon:getContentSize().height+30 )
		-- btn
		local heroIconBtn = XTHD.createButton({
			normalNode = heroIconBtn_normal,
			selectedNode = heroIconBtn_selected,
			needSwallow = false,
			needEnableWhenMoving = true,
		})
		getCompositeNodeWithNode( heroIcon, heroIconBtn )
		cell._heroIconBtn = heroIconBtn
		
		if self._heroIndex == heroIndex then
    		self._heroCell = cell
    		heroIconBtn:setSelected( true )
    		heroIconBtn:setEnable( false )
    	end
		heroIconBtn:setTouchEndedCallback(function()
			if self._heroCell then
    			self._heroCell._heroIconBtn:setSelected( false )
    			self._heroCell._heroIconBtn:setEnable( true )
    		end
    		heroIconBtn:setSelected( true )
    		heroIconBtn:setEnable( false )
    		self._heroIndex = heroIndex
    		self._heroCell = cell
    		self:refreshUI()
		end)
	    return cell
	end
	self._heroIconTableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
	self._heroIconTableView.getCellNumbers = numberOfCellsInTableView
	self._heroIconTableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
	self._heroIconTableView.getCellSize = cellSizeForTable
	self._heroIconTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
	bottomBg:addChild( self._heroIconTableView )
	self._heroIconTableView:reloadData()
	if self._heroIndex - 5 < 0 then
		self._heroIconTableView:scrollToCell( 0, false )
	elseif self._heroIndex - 5 > #self._heroList - 8 then
		self._heroIconTableView:scrollToCell( #self._heroList - 8, false )
	else
		self._heroIconTableView:scrollToCell( self._heroIndex - 5, false )
	end

    -- 左边按钮
	local leftArrow = XTHD.createButton({
		normalFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
		touchScale = 0.95,
		anchor = cc.p( 0.5, 0.5 ),
		pos = cc.p( ( self._bottomSize.width - cellWidth*8 )*0.25 + 3, self._bottomSize.height*0.5 ),
		endCallback = function()
			self._heroIconTableView:scrollToCell( self._heroIconTableView:getCurrentPage() - 1, true )
		end,
	})
	bottomBg:addChild( leftArrow )
	-- 右边按钮
	local rightArrow = XTHD.createButton({
		normalFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
		touchScale = 0.95,
		anchor = cc.p( 0.5, 0.5 ),
		pos = cc.p( self._bottomSize.width - ( self._bottomSize.width - cellWidth*8 )*0.25 - 3, self._bottomSize.height*0.5 ),
		endCallback = function()
			self._heroIconTableView:scrollToCell( self._heroIconTableView:getCurrentPage() + 1, true )
		end,
	})
	bottomBg:addChild( rightArrow )
end
-- 英雄动画点击响应
function TuJianHeroLayer:clickHero( heroSpine, heroId )
	local animationName = { action_Atk0, action_Atk1, action_Atk2, action_Atk, action_Win }
	-- 大螳螂，技能不好看，删除...
	if tonumber( heroId ) == 29 then
		table.remove( animationName, 1 )
	elseif tonumber( heroId ) == 9 or tonumber( heroId ) == 12 then
		table.remove( animationName, 3 )
	end
	local randomNum = math.random( 1, #animationName )
	if self._animation then
		if self._animation == randomNum then
			self._animation = self._animation%(#animationName) + 1
		else
			self._animation = randomNum
		end
	else
		self._animation = randomNum
	end
	-- 技能动画
	heroSpine:setAnimation( 0, animationName[self._animation], false )
	--播放人物配音
	if self.heroDubSoundId and tonumber(self.heroDubSoundId) ~= 0 then
		musicManager.stopEffect(self.heroDubSoundId)
	end
	self.heroDubSoundId = 0
	self.heroDubSoundId = XTHD.playHeroDubEffect(heroId,animationName[self._animation])
	-- 技能音效
	if self.heroskillSoundId and tonumber(self.heroskillSoundId) ~= 0 then
		musicManager.stopEffect( self.heroskillSoundId )
	end
	self.heroskillSoundId = 0
	
	local skillKey = string.gsub( animationName[self._animation], "atk", "skillid" )
	if skillKey then
		-- 查技能id
		local heroSkillList = gameData.getDataFromCSV( "GeneralSkillList", {heroid = heroId}) or {}
		-- dump( heroSkillList, "heroSkillList")
		local skillId = heroSkillList[skillKey]
		if skillId then
			-- 查技能数据
			local skillData = gameData.getDataFromCSV( "JinengInfo" , {skillid = skillId}) or {}
			local soundStr  = skillData["sound"] and skillData["sound"] or nil
			local soundDelay = tonumber(skillData["sound_delay"] and skillData["sound_delay"] or nil)
			if soundStr and soundDelay then
				performWithDelay( heroSpine, function ()
					-- 技能音效
					local _szSound = "res/sound/skill/" .. soundStr .. ".mp3"
					self.heroskillSoundId = musicManager.playEffect( _szSound )
				end, soundDelay/1000) -- 此时的声音延时为ms
			end
		end
	end
	-- 回到idle状态
	heroSpine:addAnimation( 0, "idle", true )
end
-- 刷新函数
function TuJianHeroLayer:refreshUI(  )
	local data = self._heroList[self._heroIndex]
	-- dump( data, "refreshUI" )
	-- 英雄
	self._heroBg:removeAllChildren()
	local heroId = tostring( data.id );
	if string.len( heroId ) == 1 then
		heroId = "00" .. heroId;
	elseif string.len( heroId ) == 2 then
		heroId = "0" .. heroId;
	end
	
	local heroSpine = nil

	if heroId ~= 322 and heroId ~= 026 and heroId ~= 042 then
		heroSpine = sp.SkeletonAnimation:createWithBinaryFile( "res/spine/" .. heroId .. ".skel", "res/spine/" .. heroId .. ".atlas", 1 )
	else
		heroSpine = sp.SkeletonAnimation:create( "res/spine/" .. heroId .. ".json", "res/spine/" .. heroId .. ".atlas", 1 )
	end

	local tempData = gameData.getDataFromCSV( "GeneralInfoList",{heroid = data.id} )
	if tempData.mark == 1 then
		heroSpine:setScale(0.7)
	else
		heroSpine:setScale(1)
	end

	heroSpine:setPosition( self._heroBg:getContentSize().width*0.5, 32 )
	self._heroBg:addChild( heroSpine )
	heroSpine:setAnimation( 0, "idle", true )
	local heroSpineTouch = XTHD.createButton({
		touchSize = cc.size( 214, 254 ),
		endCallback = function()
			self:clickHero( heroSpine, data.id )
		end,
	})
	getCompositeNodeWithNode( self._heroBg, heroSpineTouch )
	-- 星星
	-- for i = 1, data.mode3class do
	-- 	self._star[i]:setVisible( true )
	-- end
	-- for i = data.mode3class + 1, #self._star do
	-- 	self._star[i]:setVisible( false )
	-- end
	-- 名字
	self._name:setString( data.name )
	self._description:setString( data.description )
	self._autograph:setString( data.autograph )
	self._hpProgress:runAction( cc.ProgressTo:create( 0.2, data.hppoint*10 ) )
	self._hpNum:setString( data.hppoint )
	self._atProgress:runAction( cc.ProgressTo:create( 0.2, data.atpoint*10 ) )
	self._atNum:setString( data.atpoint )
	self._dfProgress:runAction( cc.ProgressTo:create( 0.2, data.dfpoint*10 ) )
	self._dfNum:setString( data.dfpoint )
	self._matProgress:runAction( cc.ProgressTo:create( 0.2, data.matpoint*10 ) )
	self._matNum:setString( data.matpoint )
	self._mdfProgress:runAction( cc.ProgressTo:create( 0.2, data.mdfpoint*10 ) )
	self._mdfNum:setString( data.mdfpoint )
	-- self._astProgress:runAction( cc.ProgressTo:create( 0.2, data.astpoint*10 ) )
	-- self._astNum:setString( data.astpoint )
	self._feature:setString( data.feature )
	-- 技能列表
	if data.skillid then
		self._skillList = string.split( data.skillid, "#" )
	end
	if #self._skillList > 6 then
		self._skillTableView:setBounceable( true )
	else
		self._skillTableView:setBounceable( false )
	end
	self._skillTableView:reloadData()
end
-- 根据id查找index
function TuJianHeroLayer:searchIndexById( id )
	for i, v in ipairs(self._heroList) do
		if v.id == id then
			return i
		end
	end
	return 1
end

return TuJianHeroLayer