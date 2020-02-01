--[[
	图鉴界面
	唐实聪
	2015.11.24
]]
local TuJianLayer  = class( "TuJianLayer", function( ... )
	return XTHD.createBasePageLayer({bg = "res/image/illustration/bottombg.jpg"})
end)

function TuJianLayer:onEnter()
	musicManager.playMusic(XTHD.resource.music.effect_tujian_bgm )
end

function TuJianLayer:onExit()
	musicManager.playMusic(XTHD.resource.music.music_bgm_main )
end

function TuJianLayer:create( params )
	return self.new( params )
end
function TuJianLayer:ctor( params )
	self:initData( params )
	self:initUI()
	self:refreshUI()
end
function TuJianLayer:onCleanup()
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey( "res/image/illustration/bottombg.jpg" )
	textureCache:removeTextureForKey( "res/image/illustration/middlebg.png" )
	textureCache:removeTextureForKey( "res/image/illustration/selected.png" )
	textureCache:removeTextureForKey( "res/image/illustration/herobg.png" )
	textureCache:removeTextureForKey( "res/image/illustration/bamboo.png" )
	textureCache:removeTextureForKey( "res/image/illustration/lotus.png" )
	textureCache:removeTextureForKey( "res/image/illustration/sorttypebg_big.png" )
	textureCache:removeTextureForKey( "res/image/illustration/sorttype_up.png" )
	textureCache:removeTextureForKey( "res/image/illustration/sorttype_down.png" )
	textureCache:removeTextureForKey( "res/image/illustration/illustration.png" )
	textureCache:removeTextureForKey( "res/image/illustration/titlebg.png" )
	textureCache:removeTextureForKey( "res/image/ranklistreward/splitX.png" )
end
-- 创建数据
function TuJianLayer:initData( params )
	-- ui
	-- 1:"按站位排序",
	-- 2:"按属性排序",
	-- 3:"按能力排序",
	self._sortType = 1
	self._selectedId = 0
	self._selectedIndex = 1
	self._typebtnList = {}
	-- 类型按钮
	self._sortTypesLabel = {}
	self._sortTypesBtn = {}
	self._sortTypesSplit = {}

	self._typeNum = 1
	self._allHerolist = gameData.getDataFromCSV( "HeroData" )
	self._heroList = gameData.getDataFromCSV( "HeroData" )
	local rankList = gameData.getDataFromCSV( "GeneralInfoList" )
	
	for i, v in ipairs( self._heroList ) do
		v.rank = gameData.getDataFromCSV( "GeneralInfoList",{heroid = v.id} ).rank
	end

	for i, v in ipairs( self._allHerolist ) do
		v.rank = gameData.getDataFromCSV( "GeneralInfoList",{heroid = v.id} ).rank
	end
	
	self._heroData = {{}}
	self._heroIcon = {}
end
-- 创建界面
function TuJianLayer:initUI()
	-- 通用背景
	local bottomBg = XTHD.createSprite( "res/image/common/layer_bottomBg.png" )
    bottomBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	bottomBg:setPosition( self:getContentSize().width * 0.5, ( self:getContentSize().height - self.topBarHeight )*0.5 )
	self._bg = bottomBg
	self:addChild( bottomBg )
	self._size = bottomBg:getContentSize()

	local title = "res/image/public/herotujian_title.png"
	XTHD.createNodeDecoration(bottomBg,title)

	-- 英雄预览背景
	local middleBg = ccui.Scale9Sprite:create("res/image/illustration/middlebg.png" )
	middleBg:setOpacity(0)
	middleBg:setContentSize( self._size.width - 20, bottomBg:getContentSize().height - 63 - 20 )
	middleBg:setAnchorPoint( cc.p( 0.5, 0 ) )
	middleBg:setPosition( self._size.width*0.5, ( self._size.height - self.topBarHeight - bottomBg:getContentSize().height )*0.5 + 20 )
	self._bg:addChild( middleBg,5 )

	-- 羁绊
	local fetterBtn = XTHD.createButton({
		normalFile = "res/image/illustration/recommend.png",
		selectedFile = "res/image/illustration/recommend2.png"
	})
	fetterBtn:setScale(0.8)
	fetterBtn:setTouchEndedCallback(function()
		if self._recommondPop then
			self._recommondPop:hide()
			self._recommondPop = nil
			return
		end
		local layer = requires("src/fsgl/layer/JiBan/JiBanLayer.lua"):create()
		self:addChild(layer)
		layer:show()
	end)
	fetterBtn:setPosition(self._bg:getContentSize().width * 0.1 - 30, self._bg:getContentSize().height * 0.8 + 50)
	self._bg:addChild(fetterBtn)

	-- 排序类型
	local sortTypeBg = ccui.Scale9Sprite:create("res/image/illustration/sorttypebg_big2.png" )
	sortTypeBg:setContentSize( 200, 33)
	sortTypeBg:setAnchorPoint( cc.p( 0, 0 ) )
	sortTypeBg:setPosition(150, middleBg:getContentSize().height + 10)
	middleBg:addChild( sortTypeBg )
	sortTypeBg:setZOrder(10)
	-- 排序列表弹窗背景
	-- local sortTypesBg = ccui.Scale9Sprite:create( cc.rect( 6, 6, 1, 1 ), "res/image/illustration/sorttypebg_big.png" )
	local sortTypesBg = ccui.Scale9Sprite:create("res/image/illustration/sorttypebg_big.png" )
	sortTypesBg:setContentSize( sortTypeBg:getContentSize().width,45 )
	sortTypesBg:setAnchorPoint( cc.p( 0, 1 ) )
	sortTypesBg:setPosition( 0, 0 )
	sortTypeBg:addChild( sortTypesBg )
	sortTypesBg:setVisible(false)
	self._sortTypesBg = sortTypesBg

	local touchLayer_normal = XTHD.createSprite()
 	touchLayer_normal:setContentSize( 10000, 10000 )
 	local touchLayer_selected = XTHD.createSprite()
 	touchLayer_selected:setContentSize( 10000, 10000 )
 	local touchLayer = XTHD.createButton({
 		normalNode = touchLayer_normal,
 		selectedNode = touchLayer_selected,
 		needSwallow = true,
 		touchSize = cc.size( 10000, 10000 ),
 		anchor = cc.p( 0.5, 0.5 ),
 		pos = cc.p( 0,0 )
	})
	sortTypesBg:addChild( touchLayer )
	touchLayer:setEnable(false)
	self._touchLayer = touchLayer

	-- 当前排序
	local sortTypeLabel = XTHD.createLabel({
		text      = LANGUAGE_ILLUSTRATION_SORT[self._sortType],
		fontSize  = 18,
		color     = cc.c3b( 70, 34, 34 ),
		anchor    = cc.p( 0, 0.5 ),
		pos       = cc.p( 12, sortTypeBg:getContentSize().height*0.5 ),
		clickable = false,
	})
	sortTypeBg:addChild( sortTypeLabel )
	self._sortTypeLabel = sortTypeLabel

	for i = 1, 1 do
		-- 排序方式
		local sortTypesLabel = XTHD.createLabel({
			fontSize  = 18,
			anchor    = cc.p( 0, 0.5 ),
			color     = cc.c3b( 70, 34, 34 ),
			clickable = false,
		})
		local sortTypesBtn = XTHD.createButton({
			anchor    = cc.p( 0, 1 ),
			pos       = cc.p( 0, 50 - i*50 ),
			needSwallow = true,
		})
		sortTypesBtn:setVisible( false )
		sortTypesBtn:setContentSize( sortTypeBg:getContentSize().width, 50 )
		sortTypesLabel:setPosition( 12, sortTypesBtn:getContentSize().height*0.5 )
		sortTypesBtn:addChild( sortTypesLabel )
		sortTypeBg:addChild( sortTypesBtn )
		-- 分隔
		local split = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
		split:setContentSize( sortTypeBg:getContentSize().width, 2 )
		split:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		split:setPosition( sortTypeBg:getContentSize().width*0.5, sortTypesBtn:getPositionY() )
		split:setVisible( false )
		sortTypeBg:addChild( split )

		self._sortTypesLabel[i] = sortTypesLabel
		self._sortTypesBtn[i] = sortTypesBtn
		self._sortTypesSplit[i] = split
	end
	
	-- 排序种类按钮
	-- normal
	local sortTypeBtn_normal = XTHD.createSprite()
	sortTypeBtn_normal:setContentSize( sortTypeBg:getContentSize() )
	local sortTypeBtn_normalBtn = XTHD.createSprite( "res/image/illustration/sorttype_up.png" )
	sortTypeBtn_normalBtn:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	sortTypeBtn_normalBtn:setPosition( sortTypeBtn_normal:getContentSize().width - 20, sortTypeBtn_normal:getContentSize().height*0.5 - 2 )
	sortTypeBtn_normal:addChild( sortTypeBtn_normalBtn )
	-- selected
	local sortTypeBtn_selected = XTHD.createSprite()
	sortTypeBtn_selected:setContentSize( sortTypeBg:getContentSize() )
	local sortTypeBtn_selectedBtn = XTHD.createSprite( "res/image/illustration/sorttype_down.png" )
	sortTypeBtn_selectedBtn:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	sortTypeBtn_selectedBtn:setPosition( sortTypeBtn_selected:getContentSize().width - 20, sortTypeBtn_selected:getContentSize().height*0.5 - 2 )
	sortTypeBtn_selected:addChild( sortTypeBtn_selectedBtn )
	-- btn
	local sortTypeBtn = XTHD.createButton({
		normalNode = sortTypeBtn_normal,
		selectedNode = sortTypeBtn_selected,
		needSwallow = true,
		anchor = cc.p( 0, 0 ),
		pos = cc.p( 0, 0 ),
	})
	sortTypeBg:addChild( sortTypeBtn )
	self._sortTypeBtn = sortTypeBtn

	-- 触摸响应事件
	for i, v in ipairs( self._sortTypesBtn ) do
		v:setTouchEndedCallback(function()
			sortTypeBtn_normalBtn:setFlippedY( false )
			self:clickTypeCallback( i )
		end)
	end
	sortTypeBtn:setTouchEndedCallback(function()
		sortTypeBtn:setEnable( false )
		sortTypeBtn_normalBtn:setFlippedY( true )
		sortTypesBg:setVisible(true)
		-- 背景拉伸
		-- sortTypesBg:runAction( cc.Sequence:create( cc.ScaleTo:create( 0.25, 1, 50*(self._typeNum-1)/33+1 ), cc.CallFunc:create(function()
		sortTypesBg:runAction(cc.CallFunc:create(function()

			-- 分界线
			for i, v in ipairs( self._sortTypesSplit ) do
				v:setVisible( true )
			end
			-- 排序类型按钮
			for i, v in ipairs( self._sortTypesBtn ) do
				v:setVisible( true )
			end
			-- 排序类型按钮文字
			for i, v in ipairs( self._sortTypesLabel ) do
				local labelIndex = i
				if i >= self._sortType then
					labelIndex = i + 1
				end
				v:setString( LANGUAGE_ILLUSTRATION_SORT[labelIndex] )
			end

			touchLayer:setEnable( true )
		end)  )
	end)
	touchLayer:setTouchBeganCallback(function()
		touchLayer:setEnable( false )
		sortTypeBtn_normalBtn:setFlippedY( false )
		sortTypeBtn:setEnable( true )
		-- 隐藏分界线
		for i, v in ipairs( self._sortTypesSplit ) do
			v:setVisible( false )
		end
		-- 隐藏排序类型按钮
		for i, v in ipairs( self._sortTypesBtn ) do
			v:setVisible( false )
		end
		sortTypesBg:setVisible(false)
		-- sortTypesBg:runAction( cc.ScaleTo:create( 0.25, 1, 1 ) )
	end)
	

	--三个站位排序按钮
	for i = 1, 3 do
		local normal = cc.Sprite:create("res/image/illustration/btn/btn_1_".. i .. "_down.png")
		local recommendBtn = XTHD.createButton({
			normalFile = "res/image/illustration/btn/btn_1_".. i .. "_up.png",
			selectedFile = "res/image/illustration/btn/btn_1_".. i .. "_down.png"
		})
		recommendBtn:setPosition(sortTypeBg:getPositionX() + sortTypeBg:getContentSize().width*1.5 + (i - 1) *(recommendBtn:getContentSize().width),sortTypeBg:getPositionY() + 15)
		middleBg:addChild(recommendBtn)
		recommendBtn:setTouchEndedCallback(function()
			self._selectedIndex = i
			self:SelectedHeroList()
		end)
		self._typebtnList[#self._typebtnList + 1] = recommendBtn
	end

	self:initTableView()
end

function TuJianLayer:initTableView( index )
	self._talbeView = CCTableView:create(cc.size(self._bg:getContentSize().width , 415))
	self._talbeView:setPosition(0,17)--17
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._bg:addChild(self._talbeView)

	local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,215
    end
    local function numberOfCellsInTableView(table)
        return math.ceil(#self._heroList/6)
    end
    local function tableCellTouched(table,cell)
    end
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,200)
        else
            cell:removeAllChildren()
        end
		for i = 1, 6 do
			if idx*6+i <= #self._heroList then
				local index = idx*6+i
				self:createCell(cell,i,index)
			end
		end
        return cell
    end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)


    self._talbeView:reloadData()

end

function TuJianLayer:createCell(cell, posIndex ,index)
	local isGray = false
	
	if self._heroList[index]._isHave == 1 then
		isGray = false
	else
		isGray = true
	end

	local picStr = "res/image/illustration/herobg".. self._heroList[index].rank .. ".png"
	local cellbg = ccui.Scale9Sprite:create(picStr)
	cellbg:setContentSize(cc.size(cellbg:getContentSize().width *0.6,cellbg:getContentSize().height *0.6))
	cell:addChild(cellbg)
	local x = cellbg:getContentSize().width *0.5+ (posIndex -1)*(cellbg:getContentSize().width * 1.2 - 5) + 20
	cellbg:setPosition(x,cell:getContentSize().height *0.5)
	XTHD.setGray(cellbg,isGray)

	local heroNode = ccui.ListView:create()
	heroNode:setAnchorPoint(0.5,0.5)
	heroNode:setContentSize(cellbg:getContentSize().width - 22,cellbg:getContentSize().height*0.75 - 13)
	cellbg:addChild( heroNode )
	heroNode:setPosition(cellbg:getContentSize().width / 2,cellbg:getContentSize().height*0.75 - 30)
	heroNode:setScrollBarEnabled(false)
	heroNode:setSwallowTouches(false)

	
    -- 英雄头像背景
	local heroIconBg = cc.Sprite:create( "res/image/newHeroLayer/heroka_" .. self._heroList[index].id .. ".png" )
	heroIconBg:setScale(0.55)
	heroIconBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	heroIconBg:setPosition( heroNode:getContentSize().width*0.5, heroNode:getContentSize().height*0.5 - 15)
	heroNode:addChild( heroIconBg )
	XTHD.setGray(heroIconBg,isGray)

	local heroName = XTHDLabel:create(self._heroList[index].name,20)
	heroName:setAnchorPoint(0.5,0.5)
	heroName:setColor(cc.c3b(255,255,255))
	heroName:enableOutline(cc.c4b(0,0,0,255),2.5)
	cellbg:addChild(heroName)
	heroName:setPosition(cellbg:getContentSize().width *0.5,heroName:getContentSize().height)

	local heroType = cc.Sprite:create("res/image/newHeroLayer/heroType_" .. self._heroList[index].type .. ".png")
	cellbg:addChild(heroType)
	heroType:setScale(0.7)
	heroType:setPosition(heroType:getContentSize().width *0.5 + 5,cellbg:getContentSize().height - heroType:getContentSize().height *0.5 - 15)
	XTHD.setGray(heroType,isGray)

	local heroRank = cc.Sprite:create("res/image/newHeroLayer/heroRank_" .. self._heroList[index].rank .. ".png")
	cellbg:addChild(heroRank)
	heroRank:setAnchorPoint(1,0.5)
	heroRank:setScale(0.4)
	heroRank:setPosition(cellbg:getContentSize().width - 10,cellbg:getContentSize().height - heroRank:getContentSize().height *0.5 - 5)
	XTHD.setGray(heroRank,isGray)

	local starNum = 3
	local starType = 1
	if self._heroList[index].rank == 1 then
		starNum = 3
		starType = 1
	elseif self._heroList[index].rank == 2 then
		starNum = 4
		starType = 1
	elseif self._heroList[index].rank == 3 then
		starNum = 3
		starType = 2
	elseif self._heroList[index].rank == 4 then
		starNum = 4
		starType = 2
	elseif self._heroList[index].rank == 5 then
		starNum = 5
		starType = 2
	end
	for i = 1,starNum do
		local star = cc.Sprite:create("res/image/newHeroLayer/star_".. starType ..".png")
		star:setScale(0.8)
		cellbg:addChild(star)
		local x = cellbg:getContentSize().width*0.5 - 20 + (starNum-1) *star:getContentSize().width *0.5 - (i-1)*(star:getContentSize().width - 10) + (10 - starNum *2) *2.5
		star:setPosition(x,cellbg:getContentSize().height - star:getContentSize().height *0.5 - 130)
	end

	--创建透明按钮
	 local herobtn = XTHDPushButton:createWithParams({
        touchSize =cc.size(cellbg:getContentSize().width,cell:getContentSize().height),
		needEnableWhenMoving = true,
		musicFile = XTHD.resource.music.effect_btn_common,
     })
	herobtn:setSwallowTouches(false)
	cellbg:addChild(herobtn)
	herobtn:setTag(index)
	herobtn:setPosition(cellbg:getContentSize().width*0.5,cellbg:getContentSize().height *0.5)

	herobtn:setTouchBeganCallback(function()
		cellbg:setScale(0.98)
	end)

	herobtn:setTouchMovedCallback(function()
		cellbg:setScale(1)
	end)
	
	herobtn:setTouchEndedCallback(function()
		cellbg:setScale(1)
		self:HeroParticulars(herobtn:getTag())
	end)

end

-- 挑战英雄详情界面
function TuJianLayer:HeroParticulars(tag)
	-- 为了实现在点击状态跳转到英雄信息界面，延迟1秒处理跳转
	local heroId = self._heroList[tag].id
	self:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(
				0.01
			),
			cc.CallFunc:create(
			function()
				local layer = requires("src/fsgl/layer/TuJian/TuJianHeroLayer.lua"):create( {
					id = heroId,
					sort = self._sortType,
					callBack = function(heroId)
						self._selectedId = heroId
						for i, v in ipairs(self._heroData) do
							for j, u in ipairs(v) do
								if u.id == heroId then
									self._selected:setPosition(self._heroIcon[u.index]:getPosition())
								end
							end
						end
					end
				} )
				LayerManager.addLayout(layer, { noHide = true })
			end
			)
		)
	)
end

-- 点击类型
function TuJianLayer:clickTypeCallback( index )

	if index >= self._sortType then
		self._sortType = index + 1
	else
		self._sortType = index
	end

	for i = 1, #self._typebtnList do
		local name = "res/image/illustration/btn/btn_" .. self._sortType .. "_".. i .. "_up.png"
		local name2 = "res/image/illustration/btn/btn_" .. self._sortType .. "_".. i .. "_down.png"
		self._typebtnList[i]:setStateNormal(name)
		self._typebtnList[i]:setStateSelected(name2)
	end
	-- 隐藏分界线
	for i, v in ipairs( self._sortTypesSplit ) do
		v:setVisible( false )
	end
	-- 隐藏排序类型按钮
	for i, v in ipairs( self._sortTypesBtn ) do
		v:setVisible( false )
	end

	self._sortTypesBg:setVisible(false)
	-- self._sortTypesBg:runAction( cc.ScaleTo:create( 0.25, 1, 1 ) )
	self._sortTypeLabel:setString( LANGUAGE_ILLUSTRATION_SORT[self._sortType] )
	self._touchLayer:setEnable( false )
	self._sortTypeBtn:setEnable( true )
	self:refreshUI()
end
-- 重新排序，重新设置位置
function TuJianLayer:refreshUI()
	--self._sortType == 1(站位排序),--self._sortType == 2(属性) self._sortType == 3（能力）
	self._allHerolist = gameData.getDataFromCSV( "HeroData" )
	local allHero = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_HERO)
	local rankList = gameData.getDataFromCSV( "GeneralInfoList" )
	for i, v in ipairs( self._allHerolist ) do
		v.rank = gameData.getDataFromCSV( "GeneralInfoList",{heroid = v.id} ).rank
	end
	for i = 1, #self._allHerolist do
		for j = 1,#allHero do
			self._allHerolist[i]._isHave = 2
			if allHero[j].heroid == self._allHerolist[i].id then
				self._allHerolist[i]._isHave = 1
				break
			end
		end
	end

	for i = 1, #self._allHerolist do
		self._allHerolist[i].mode3class = self._allHerolist[i].mode3class + 10 *self._allHerolist[i]._isHave
	end
	
	print("------------------------>>>",self._sortType)
	local list = {{},{},{}}

	if self._sortType == 1 then
		for k,v in pairs(self._allHerolist) do
			if v.mode1class == 1 then
				list[1][#list[1] + 1] = v
			elseif v.mode1class == 2 then
				list[2][#list[2] + 1] = v
			elseif v.mode1class == 3 then
				list[3][#list[3] + 1] = v
			end
		end

		for i = 1,#list do
			if #list[i] then
				table.sort(list[i],function(a,b)
					return a.mode3class < b.mode3class
				end)
			end
		end
		print("============================")
	elseif self._sortType == 2 then
		for k,v in pairs(self._allHerolist) do
			if v.mode2class == 1 then
				list[1][#list[1] + 1] = v
			elseif v.mode2class == 2 then
				list[2][#list[2] + 1] = v
			elseif v.mode2class == 3 then
				list[3][#list[3] + 1] = v
			end
		end

		for i = 1,#list do
			if #list[i] then
				table.sort(list[i],function(a,b)
					return a.mode3class < b.mode3class
				end)
			end
		end
	end
	self._allHerolist = list
	self:SelectedHeroList()
end

--选定数组
function TuJianLayer:SelectedHeroList()
	for i = 1, #self._typebtnList do
		self._typebtnList[i]:setSelected(false)
	end
	self._typebtnList[self._selectedIndex]:setSelected(true)
	local list = {}
	list = self._allHerolist[self._selectedIndex]
	self._heroList = {}
	self._heroList = list
	self._talbeView:reloadData()
end

-- 对数据排序self._selectedId 
function TuJianLayer:sortData()
	
end

function TuJianLayer:getHeroName(name,id)
	local num = string.len(name)
	local res={}
	if id ~= 47 then
		for i=1,num do
			res[i]=string.sub(name,(i-1)*3+1,i*3)
			res[i] = res[i].." "
		end
		for i = 1,#res do
			if res[i] == "" then
				res[i] = nil
			end
		end
		local heroName = ""
		for i = 1,#res do
			heroName = heroName..res[i]
		end
		return heroName
	else
		heroName = "神 · 李 师 师"
		return heroName
	end
	
end

return TuJianLayer