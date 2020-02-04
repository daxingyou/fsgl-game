--[[
	重构的任务界面
	唐实聪
	2015.11.11
]]
local RenWuLayer  = class( "RenWuLayer", function ( ... )
	return XTHD.createBasePageLayer()
end )

function RenWuLayer:ctor( data, CallFunc, index ,sdata)
	self._exist = true
    self:setOpacity( 50 )
    self._CallFunc = CallFunc
    self._first = true

    -- 变量
    self._size = self:getContentSize()
    -- 所有任务列表
    -- print("任务服务器返回的数据为：")
    -- print_r(data)
    self._allTaskList = data and data.task_list or {}
    self.serverTaskData = data
    for i = 1,#sdata.list do
		local tempData = {}
		tempData.maxNum = 0
		tempData.task_status = sdata.list[i].state
		tempData.taskId = sdata.list[i].configId
		tempData.taskType = 4
		tempData.curNum = 0
		self._allTaskList[#self._allTaskList + 1] = tempData
	end
    self:SpecifalDeal(index)
end

function RenWuLayer:onEnter()
	if not self._first then
		self:refreshData()
	end
	self._first = false
end

function RenWuLayer:onExit( )
	if LayerManager.getBaseLayer() then 
        LayerManager.getBaseLayer():addGuide()      
		performWithDelay(LayerManager.getBaseLayer(),function( )
			YinDaoMarg:getInstance():doNextGuide()
		end,0.01)
	end
end
-- 清理函数
function RenWuLayer:onCleanup()
	self._exist = false
	-- 移除监听
	XTHD.removeEventListener( CUSTOM_EVENT.REFRESH_TASKLIST )
    XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_HELP_DATA })
	-- 移除动画
    if self._iconSpine then
    	self._iconSpine:removeFromParent()
    	self._iconSpine = nil
    end
	local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey( "res/image/plugin/tasklayer/panda.png" )
    textureCache:removeTextureForKey( "res/image/plugin/tasklayer/daily_up.png" )
    textureCache:removeTextureForKey( "res/image/plugin/tasklayer/daily_down.png" )
    textureCache:removeTextureForKey( "res/image/plugin/tasklayer/main_up.png" )
    textureCache:removeTextureForKey( "res/image/plugin/tasklayer/main_down.png" )
    textureCache:removeTextureForKey( "res/image/plugin/tasklayer/super_up.png" )
    textureCache:removeTextureForKey( "res/image/plugin/tasklayer/super_down.png" )
    -- 执行回调
	if self._CallFunc then
        self._CallFunc()
    end
    helper.collectMemory()
end

function RenWuLayer:SpecifalDeal(index)
	-- 过滤，分类之后的任务列表
    self._tabTaskData = {}
	self._tabTopTaskData = {}
	for i = 1, 4 do
		self._tabTaskData[i] = {}
		self._tabTopTaskData[i] = {}
	end
    local transform = {
    	[1] = 3,	-- 至尊 tab=3 type=1
    	[2] = 2,	-- 主线 tab=2 type=2
    	[3] = 1,	-- 日常 tab=1 type=3
    	[4] = 4,	-- 毕业典礼
	}
	self._tabIndex = transform[index or 3]
	-- 分页按钮
    self._tabsTable = {}
    -- 红点条件
    self._redDot = {}

    --  创建界面
    self:initUI()
	self:buildData()
    XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_TASKLIST,
        callback = function ()
        	if self._exist then
            	self:refreshData()
            end
        end,
    })
    self:refreshUI( true, true )
end

-- 初始化界面
function RenWuLayer:initUI()
    -- 底层背景
    self._bottomBg = XTHD.createSprite( "res/image/common/layer_bottomBg.png" )
    self._bottomBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	self._bottomBg:setPosition( self:getContentSize().width * 0.5, ( self:getContentSize().height - self.topBarHeight ) * 0.5 )
	self._bottomSize = self._bottomBg:getContentSize()
	self:addChild( self._bottomBg )

	local title = "res/image/public/renwu_title.png"
	XTHD.createNodeDecoration(self._bottomBg,title)
	--阴影
	self._shadow = ccui.Scale9Sprite:create("res/image/common/common_black_shadow.png")
	self._shadow:setPosition(self._bottomSize.width,self._bottomSize.height/2)
	self._shadow:setAnchorPoint(1,0.5)
	self._bottomBg:addChild(self._shadow)
	-- 创建界面
	self:initTabs()
    self:initTopTask()
    self:initTasks()
end
-- 创建tabs层
function RenWuLayer:initTabs()
	-- tabs层左边背景
	-- local tabBg = XTHD.createSprite( "res/image/common/tab_contentBg.png" )
	-- tabBg:setAnchorPoint( cc.p( 1, 0.5 ) )
	-- tabBg:setPosition( ( self._bottomSize.width + self._size.width ) * 0.5 - 62, self._bottomSize.height * 0.5 )
	-- self._bottomBg:addChild( tabBg, 1 )

	-- tab点击处理
	local function tabCallback( index )
		-- 引导
		-- YinDaoMarg:getInstance():guideTouchEnd()
		if self._tabIndex ~= index then
			-- 更改tabs状态
			self._tabsTable[self._tabIndex]:setSelected( false )
			self._tabsTable[self._tabIndex]:setEnable( true )
			self._tabsTable[self._tabIndex]:setLocalZOrder( 0 )
			self._tabsTable[index]:setSelected( true )
			self._tabsTable[index]:setEnable( false )
			self._tabsTable[index]:setLocalZOrder( 1 )
			self._tabIndex = index
			if self._tabIndex < 4 then
				self._topTask:setVisible(true)
			else
				self._topTask:setVisible(false)
			end
			-- 刷新界面
			self:refreshUI( false, false )
		end
	end
	-- tabs路径
	local tabsPathTable = {
		{
			"res/image/plugin/tasklayer/daily_up.png",
			"res/image/plugin/tasklayer/daily_down.png",
		},
		{
			"res/image/plugin/tasklayer/main_up.png",
			"res/image/plugin/tasklayer/main_down.png",
		},
		{
			"res/image/plugin/tasklayer/super_up.png",
			"res/image/plugin/tasklayer/super_down.png",
		},
		{
			"res/image/plugin/tasklayer/champion_up.png",
			"res/image/plugin/tasklayer/champion_down.png",
		},
	}
	-- 循环创建tab
	for i = 1, 4 do
		local tabBtn_normal = getCompositeNodeWithImg( "res/image/common/btn/btn_tabClassify_normal.png", tabsPathTable[i][1] )
		local tabBtn_selected = getCompositeNodeWithImg( "res/image/common/btn/btn_tabClassify_selected.png", tabsPathTable[i][2] )
		local tabBtn = XTHD.createButton({
			normalNode = tabBtn_normal,
			selectedNode = tabBtn_selected,
			anchor = cc.p( 0, 0 ),
			endCallback = function()
				tabCallback( i )
			end,
		})
		tabBtn:setScale(0.7)
		tabBtn:setPosition( 31, 432 - 85*i )
		self._shadow:addChild( tabBtn, 0 )
		self._tabsTable[i] = tabBtn
		-- 红点
		local redDot = cc.Sprite:create( "res/image/common/heroList_redPoint.png" )
        redDot:setAnchorPoint( 1, 1 )
        redDot:setPosition( tabBtn:getContentSize().width+5, tabBtn:getContentSize().height+5 )
        redDot:setName( "redDot" )
        tabBtn:addChild( redDot )
	end
	self._tabsTable[self._tabIndex]:setSelected( true )
	self._tabsTable[self._tabIndex]:setEnable( false )
	self._tabsTable[self._tabIndex]:setLocalZOrder( 1 )
end
-- 创建顶部任务
function RenWuLayer:initTopTask()
	-- 容器
	local topTask = XTHD.createSprite()
	topTask:setContentSize( self._size.width - 88, 50 )
	topTask:setAnchorPoint( cc.p( 0, 1 ) )
	topTask:setPosition( self._bottomSize.width*0.5 - self._size.width*0.5, self._bottomSize.height - 20 )
	self._bottomBg:addChild( topTask, 3 )
	local topTaskSize = topTask:getContentSize()
	self._topTask = topTask

	-- 创建所有任务已完成
	self._topFinishAllTasks = XTHD.createLabel({
		text = LANGUAGE_KEY_FINISHALLTASK,
		fontSize  = 18,
		color = cc.c3b( 205, 101, 8 ),
		anchor    = cc.p( 0.5, 0.5 ),
		pos       = cc.p( topTaskSize.width*0.5, topTaskSize.height*0.5 ),
		clickable = false,
		ttf = "res/fonts/def.ttf"
	})
	topTask:addChild( self._topFinishAllTasks )

	-- 创建进度条
	self._loadingbarBg = XTHD.createSprite( "res/image/plugin/tasklayer/common_progressBg_2.png" )
    self._loadingbarBg:setAnchorPoint( 0.5, 0.5 )
	self._loadingbarBg:setPosition( topTaskSize.width*0.5 + 80, topTaskSize.height*0.5 - 2 )
	self._loadingbarBg:setScaleX(0.8)
    topTask:addChild( self._loadingbarBg )
    self._loadingbar = cc.ProgressTimer:create( cc.Sprite:create( "res/image/plugin/tasklayer/common_progress_2.png" ) )
    self._loadingbar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._loadingbar:setBarChangeRate( cc.p( 1, 0 ) )
    self._loadingbar:setMidpoint( cc.p( 0, 0.5 ) )
    self._loadingbar:setPosition( self._loadingbarBg:getContentSize().width*0.5, self._loadingbarBg:getContentSize().height*0.5 )
    self._loadingbarBg:addChild( self._loadingbar )
	-- 创建进度条数字
	self._loadingbarNum = XTHD.createLabel({
		fontSize  = 22,
		anchor    = cc.p( 1, 0.5 ),
		pos       = cc.p( self._loadingbarBg:getContentSize().width-5, self._loadingbarBg:getContentSize().height*0.5 ),
		clickable = false,
		ttf = "res/fonts/def.ttf"
	})
	self._loadingbarNum:enableShadow( cc.c4b(0,0,0,255), cc.size(2,-2) )
	self._loadingbarBg:addChild( self._loadingbarNum )
	-- 创建进度条提示文字
	self._topTaskTip = XTHD.createLabel({
		fontSize  = 18,
		anchor    = cc.p( 1, 0.5 ),
		pos       = cc.p( self._loadingbarBg:getPositionX() - self._loadingbarBg:getContentSize().width*0.5 - 10+50, topTaskSize.height*0.5 - 2 ),
		color     = cc.c3b( 255, 255, 255 ),
		clickable = false,
		ttf = "res/fonts/def.ttf"
	})
	self._topTaskTip:enableOutline(cc.c4b(106,36,13,255),2)
	topTask:addChild( self._topTaskTip )
	-- 创建奖励图标
	self._topRewardIcon = XTHD.createButton()
	self._topRewardIcon:setScale(0.8)
	self._topRewardIcon:setContentSize( cc.size( 71, 54 ) )
	self._topRewardIcon:setTouchSize( cc.size( 71, 54 ) )
	self._topRewardIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	self._topRewardIcon:setPosition( self._loadingbarBg:getPositionX() + self._loadingbarBg:getContentSize().width*0.5, topTaskSize.height*0.5 -2)
	topTask:addChild( self._topRewardIcon )
	--任务奖励图片
	-- local taskreward = cc.Sprite:create("res/image/plugin/tasklayer/taskreward.png")
	-- taskreward:setPosition(self._topRewardIcon:getBoundingBox().width*0.5, self._topRewardIcon:getContentSize().height/3)
	-- taskreward:setScale(0.55)
	-- self._topRewardIcon:addChild( taskreward )

	--任务奖励按钮动作，先设置成透明，放上图片
	-- self._iconSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/kflb.json", "res/image/homecity/frames/spine/kflb.atlas", 1.0) 
	self._iconSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/renwu.json", "res/image/homecity/frames/spine/renwu.atlas", 1.0) 
	-- self._iconSpine:setOpacity(0)  
    self._iconSpine:setScale( 0.7 )
    self._topRewardIcon:addChild( self._iconSpine )
    self._iconSpine:setPosition( self._topRewardIcon:getBoundingBox().width*0.5, self._topRewardIcon:getContentSize().height/3+10 )
end
-- 创建任务列表
function RenWuLayer:initTasks()
	-- 容器
	local tasksBg = XTHD.createSprite()
	tasksBg:setContentSize( self._bottomSize.width - 118, self._bottomSize.height - 90 )
	tasksBg:setAnchorPoint( cc.p( 0, 0 ) )
	tasksBg:setPosition( -6, 20 )
	self._bottomBg:addChild( tasksBg, 2 )
	local tasksSize = tasksBg:getContentSize()

	-- tableView背景
	local tableViewBg = ccui.Scale9Sprite:create( "res/image/common/scale9_bg2_25.png" )
	tableViewBg:setContentSize( tasksSize.width -6, tasksSize.height - 4 )
	tableViewBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	tableViewBg:setPosition( tasksSize.width*0.5 + 35, tasksSize.height*0.5 )
	tasksBg:addChild( tableViewBg )

	-- tableView
	self._taskTableView = cc.TableView:create( cc.size( tableViewBg:getContentSize().width, tasksSize.height - 12 ) )
	TableViewPlug.init(self._taskTableView)
    self._taskTableView:setPosition( 35, 6 )
	self._taskTableView:setBounceable( true )
	self._taskTableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	self._taskTableView:setDelegate()
	self._taskTableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	tasksBg:addChild( self._taskTableView )
	local function numberOfCellsInTableView( table )
		return #self._tabTaskData[self._tabIndex]
	end
	local function cellSizeForTable( table, index )
		return  tableViewBg:getContentSize().width,135
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end
		cell:setContentSize(table:getContentSize().width,135)
        -- 数据
        index = index + 1
        local data = self._tabTaskData[self._tabIndex][index]
        -- dump( data, "data"..index )
        -- cell背景
        local cellBg = ccui.Scale9Sprite:create( "res/image/common/scale9_bg1_26.png" )
        cellBg:setContentSize( tableViewBg:getContentSize().width - 30, 128 )
        cellBg:setAnchorPoint( cc.p( 0, 0 ) )
        cellBg:setPosition( 16, -8 )
        cell:addChild( cellBg )
        -- 分隔线
        -- local splitCellLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
        -- splitCellLine:setContentSize( tableViewBg:getContentSize().width - 3, 2 )
        -- splitCellLine:setAnchorPoint( cc.p( 0, 0 ) )
        -- splitCellLine:setPosition( 3, 1 )
        -- cell:addChild( splitCellLine )
        -- 任务图标背景
        local taskIconBg = XTHD.createSprite( "res/image/plugin/tasklayer/iconbg.png" )
        taskIconBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		taskIconBg:setPosition( 60, 58 )
		taskIconBg:setScale(0.8)
        cellBg:addChild( taskIconBg )
        -- 任务图标
        local taskIcon = XTHD.createSprite( "res/image/plugin/tasklayer/taskicon/"..( data.icon or 1 )..".png" )
        taskIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		taskIcon:setPosition( 60, 60 )
		taskIcon:setScale(0.75)
        cellBg:addChild( taskIcon )
        -- 任务图标边框
        -- local taskIconSide = XTHD.createSprite( "res/image/plugin/tasklayer/iconside.png" )
        -- taskIconSide:setAnchorPoint( cc.p( 0.5, 0.5 ) )
        -- taskIconSide:setPosition( 60, 53 )
		-- cellBg:addChild( taskIconSide )
		--任务目标背景
		local rw_bg = ccui.Scale9Sprite:create("res/image/plugin/tasklayer/name_bg.png")
		rw_bg:setContentSize(cellBg:getContentSize().width-150,cellBg:getContentSize().height/4+10)
		rw_bg:setPosition(cc.p( 100, cellBg:getContentSize().height - 30 ))
		rw_bg:setAnchorPoint(0,0.5)
		cellBg:addChild(rw_bg)
        -- 任务目标
        local taskDest = XTHD.createLabel({
        	text      = LANGUAGE_KEY_TASKTARGET..":",
			fontSize  = 22,
			anchor    = cc.p( 0, 0.5 ),
			pos       = cc.p( 120, cellBg:getContentSize().height - 30 ),
			color     = cc.c3b( 54, 55, 112 ),
			clickable = false,
			ttf = "res/fonts/def.ttf"
    	})
    	cellBg:addChild( taskDest )
    	-- 任务描述
    	local taskDesc = XTHD.createLabel({
    		text      = data.description,
			fontSize  = 20,
			anchor    = cc.p( 0, 0.5 ),
			pos       = cc.p( taskDest:getPositionX() + taskDest:getContentSize().width + 10, cellBg:getContentSize().height - 30 ),
			color     = cc.c3b( 54, 55, 112 ),
			clickable = false,
			ttf = "res/fonts/def.ttf"
		})
    	cellBg:addChild( taskDesc )
    	-- 任务奖励分隔
    	-- local spliteRewardLine = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
        -- spliteRewardLine:setContentSize( tableViewBg:getContentSize().width - 130, 2 )
        -- spliteRewardLine:setAnchorPoint( cc.p( 0, 0 ) )
        -- spliteRewardLine:setPosition( 130, 70 )
        -- cellBg:addChild( spliteRewardLine )
    	-- 任务奖励图片
		-- local taskReward = getCompositeNodeWithImg( "res/image/plugin/tasklayer/taskrewardbg.png", "res/image/plugin/tasklayer/taskrewardtext.png" )
		local taskReward = cc.Sprite:create("res/image/plugin/tasklayer/taskrewardtext.png" )
		taskReward:setScale(0.7)
    	taskReward:setPosition( 130, 36 +15)
    	cellBg:addChild( taskReward )
    	-- 任务奖励icons
    	local icons, iconData = self:createIcons( data )
		icons:setAnchorPoint( cc.p( 0, 0.5 ) )
		icons:setPosition( 135, 40 )
    	cellBg:addChild( icons )
    	-- 任务进度
    	if data.curNum and data.maxNum then
	    	-- 任务进度文字
	    	local taskProcessText = XTHD.createLabel({
	    		text      = LANGUAGE_TASK_PROGRESS..":",
				fontSize  = 18,
				anchor    = cc.p( 1, 0.5 ),
				pos       = cc.p( cellBg:getContentSize().width - 90, cellBg:getContentSize().height - 30 ),
				color     = cc.c3b( 54, 55, 112 ),
				clickable = false,
			})
	    	cellBg:addChild( taskProcessText )
	    	if self._tabIndex < 4 then
	    		taskProcessText:setVisible(true)
	    	else
	    		taskProcessText:setVisible(false)
	    	end
	    	-- 任务进度数字
	    	local taskProcessNumText = ""
	    	if data.maxNum > 1000 then
	    		local tmp = math.modf(data.curNum/data.maxNum*100)
	    		taskProcessNumText = tmp.."%"
	    	else
	    		taskProcessNumText = data.curNum.."/"..data.maxNum
	    	end
	    	local taskProcessNum = XTHD.createLabel({
	    		text      = taskProcessNumText,
				fontSize  = 18,
				anchor    = cc.p( 0, 0.5 ),
				pos       = cc.p( cellBg:getContentSize().width - 87, cellBg:getContentSize().height - 30 ),
				color     = cc.c3b( 255, 112, 62 ),
				clickable = false,
			})
	    	cellBg:addChild( taskProcessNum )
	    	if self._tabIndex < 4 then
	    		taskProcessNum:setVisible(true)
	    	else
	    		taskProcessNum:setVisible(false)
	    	end
	    end
    	-- 任务按钮
    	if data.task_status == 1 then
    		-- 领取
    		local fetchButton = XTHD.createCommonButton({
				text = LANGUAGE_KEY_SPACEFETCH,
				isScrollView = true,
				fontColor = cc.c3b( 255, 255, 255 ),
				fontSize = 24,
				isScrollView = true,
				anchor = cc.p( 0.5, 0.5 ),
				touchSize = cc.size(130, 60),
				pos = cc.p( cellBg:getContentSize().width - 115, 43 ),
				endCallback = function()
					if self._tabIndex < 4 then
						self:receiveTask(data.configId,iconData)
					else
						self:reciveRewardOne(data.configId)
					end 
				end})
			fetchButton:setScale(0.8)
			cellBg:addChild( fetchButton )
			local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)  
			fetchSpine:setScaleX(1.2) 
		    fetchButton:addChild( fetchSpine )
		    fetchSpine:setPosition( fetchButton:getContentSize().width*0.5+7, fetchButton:getContentSize().height/2+3 )
			fetchSpine:setAnimation( 0, "querenjinjie", true )
    	elseif data.gotype ~= 0 then
    		-- 前往
    		local gotoButton = XTHD.createCommonButton({
				btnColor = "write",
				isScrollView = true,
				text = LANGUAGE_KEY_SPACEGOTO,
				fontColor = cc.c3b( 255, 255, 255 ),
				isScrollView = true,
				fontSize = 24,
				anchor = cc.p( 0.5, 0.5 ),
				touchSize = cc.size(130, 60),
				pos = cc.p( cellBg:getContentSize().width - 115, 43 ),
				endCallback = function()
					LayerManager.addShieldLayout()
					replaceLayer({
                        fNode = self,
                        id = data.gotype,
                        chapterId = data.goparam,
                        -- callback = function ()
                        --     self:refreshData()
                        -- end,
                    })
				end,
			})
			gotoButton:setScale(0.8)
			cellBg:addChild( gotoButton )
		elseif data.task_status == 2 then
			-- 已领取
	    	local yilingqu = XTHD.createLabel({
	    		text      = "已领取",
				fontSize  = 18,
				anchor    = cc.p( 0.5, 0.5 ),
				pos       = cc.p( cellBg:getContentSize().width - 60, 36 ),
				color     = cc.c3b( 54, 55, 112 ),
				clickable = false,
			})
	    	cellBg:addChild( yilingqu )
    	else
    		-- 未完成
	    	local taskNotFinishText = XTHD.createLabel({
	    		text      = LANGUAGE_TASK_TASKNOTFINISH,
				fontSize  = 18,
				anchor    = cc.p( 0.5, 0.5 ),
				pos       = cc.p( cellBg:getContentSize().width - 60, 36 ),
				color     = cc.c3b( 54, 55, 112 ),
				clickable = false,
			})
	    	cellBg:addChild( taskNotFinishText )
    	end

    	return cell
    end
	self._taskTableView.getCellNumbers=numberOfCellsInTableView
	self._taskTableView:registerScriptHandler( self._taskTableView.getCellNumbers, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    self._taskTableView.getCellSize=cellSizeForTable
    self._taskTableView:registerScriptHandler( self._taskTableView.getCellSize, cc.TABLECELL_SIZE_FOR_INDEX )
    self._taskTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    self._taskTableView:reloadData()

    -- local pandaBg = XTHD.createSprite( "res/image/plugin/tasklayer/panda.png" )
    -- -- pandaBg:setScale( 0.7 )
    -- pandaBg:setPosition( tableViewBg:getPositionX() + 60, tableViewBg:getPositionY() )
    -- tasksBg:addChild( pandaBg )
end

function RenWuLayer:receiveTask(id,iconData)
	ClientHttp:requestAsyncInGameWithParams({
            modules="finishTask?",
            params = {taskId = id},
            successCallback = function( finishTask )
                -- dump(finishTask,"领取任务奖励返回")
                if tonumber( finishTask.result ) == 0 then
     --                self._allTaskList = finishTask.task_list
					-- self:buildData()
     --                self:refreshUI( false, true )
     				self:freshDataAndUI(finishTask)
                    -- 成功获取弹窗
			    	ShowRewardNode:createWithParams({
						showData = iconData,
						target = self,
						zorder = 10
			    	})
			    	-- 更新属性
			    	if finishTask.property and #finishTask.property > 0 then
		                for i=1, #finishTask.property do
		                    local pro_data = string.split( finishTask.property[i], ',' )
		                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
		                end
		                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
		            end
		            -- 更新背包
		            if finishTask.bagItems and #finishTask.bagItems ~= 0 then
		                for i=1, #finishTask.bagItems do
		                    local item_data = finishTask.bagItems[i]
		                    if item_data.count and tonumber( item_data.count ) ~= 0 then
		                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
		                    else
		                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
		                    end
		                end
		            end
					XTHD.FristChongZhiPopLayer(cc.Director:getInstance():getRunningScene())
                else
                    XTHDTOAST(finishTask.msg)
                end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
end

function RenWuLayer:reciveRewardOne(id)
--	print("毕业典礼领取奖励id为："..id)
	local _url = "getGragraduationReward?"
	XTHDHttp:requestAsyncInGameWithParams({
		modules = _url,
		params = {configId = id},
		successCallback = function(data)
			if tonumber(data.result) == 0 then
				HttpRequestWithOutParams("taskList",function (taskdata)
					self:freshDataAndUI(taskdata)
			    end) 
				-- 总奖励会减去1 当奖励全部领完则不显示主城按钮
				if data.isShow == 0 then  --代表领取完了，关闭
                    gameUser.setGragraduationState(0)
				end
				local show = {} --奖励展示
				--货币类型
				if data.property and #data.property > 0 then
					for i=1,#data.property do
						local pro_data = string.split( data.property[i],',')
						--如果奖励类型存在，而且不是vip升级(406)则加入奖励
						print(XTHD.resource.propertyToType[tonumber(pro_data[1])])
						if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
							local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
							if getNum > 0 then
								local idx = #show + 1
								show[idx] = {}
								show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
								show[idx].num = getNum
							end
						end
						DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
					end
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 		--刷新数据信息
				end
	
				--物品类型
				if data.bagItems and #data.bagItems ~= 0 then
					for i=1,#data.bagItems do
						local item_data = data.bagItems[i]
						local showCount = item_data.count
						if item_data.count and tonumber(item_data.count) ~= 0 then
							--print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
							showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId));
							DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
						else
							DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
						end
						--如果奖励类型
						local idx = #show + 1
						show[idx] = {}
						show[idx].rewardtype = 4 -- item_data.item_type
						show[idx].id = item_data.itemId
						show[idx].num = showCount
					end
				end

				--显示领取奖励成功界面
				ShowRewardNode:create(show)
				RedPointManage:reFreshDynamicItemData()
			else
			   XTHDTOAST(data.msg)
			end
		end,--成功回调
		failedCallback = function()
			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
		end,--失败回调
		targetNeedsToRetain = self,--需要保存引用的目标
		loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end

-- 创建奖励icons
function RenWuLayer:createIcons( data )
	-- icons容器
	-- print("任务面板奖励数据：")
	-- print_r(data)
	local icons = XTHD.createSprite()
	icons:setContentSize( 500, 100 )
	-- icons数据，ShowResult弹窗使用
	local iconData = {}
	if data.taskType < 4 then
		for i = 1, 5 do
	        if data["reward"..i.."type"] then
	            local count = data["reward"..i.."param"]
	            local itemid = nil
	            if data["reward"..i.."type"] == 4 then
	                local tempTable = string.split(data["reward"..i.."param"],"#")
	                itemid = tempTable[1]
	                count = tempTable[2]
	            end
	            local rewardIcon = ItemNode:createWithParams({
	                _type_ = data["reward"..i.."type"],
	                itemId = itemid,
	                count = count,
	            })
	            rewardIcon:setScale(0.6)
	            rewardIcon:setAnchorPoint(0.5, 0.5 )
	            rewardIcon:setPosition( 80*i, 55 )
	            icons:addChild( rewardIcon )
	            if data["reward"..i.."type"] == 4 then
	            	iconData[#iconData + 1] = {
		                rewardtype = data["reward"..i.."type"],
		                id = itemid,
		                num = count,
		        	}
		        else
		            iconData[#iconData + 1] = {
		                rewardtype = data["reward"..i.."type"],
		                num = count,
		        	}
		        end
	        end
	    end
	else
		if data["reward"] then
            local tempTable = string.split(data["reward"],"#")
            local rewardIcon = ItemNode:createWithParams({
                _type_ = tonumber(tempTable[1]),
                itemId = tonumber(tempTable[2]),
                count = tonumber(tempTable[3]),
            })
            rewardIcon:setScale(0.6)
            rewardIcon:setAnchorPoint(0.5, 0.5 )
            rewardIcon:setPosition( 80, 55 )
            icons:addChild( rewardIcon )
            iconData[#iconData + 1] = {
                rewardtype = tonumber(tempTable[1]),
                num = tonumber(tempTable[3]),
        	}
        end
	end
	
    return icons, iconData
end
-- 过滤任务列表，删除前后端静态表不一致的任务
function RenWuLayer:buildData()
	-- 清理任务列表
	for i = 1, #self._tabTaskData do
		self._tabTaskData[i] = {}
		self._tabTopTaskData[i] = {}
	end
	-- 取任务数据，放到任务列表中
	for i = #self._allTaskList, 1, -1 do
		local taskData
		if self._allTaskList[i].taskType < 4 then
			taskData = gameData.getDataFromCSV( "RenwuList", {taskid = self._allTaskList[i].taskId} )
		else
			taskData = gameData.getDataFromCSV( "GraduatIonceremony", {id = self._allTaskList[i].taskId} )
		end
    	-- print("filterTasks  ",self._allTaskList[i].taskId)
    	if table.nums(taskData) == 0 then
    		-- dump( self._allTaskList[i], "空任务" )
    		table.remove( self._allTaskList, i )
		elseif IS_APP_STORE_CHANNAL() and ( taskData.needtype == 10 or taskData.needtype == 50 ) then
			-- dump( self._allTaskList[i], "充值任务" )
    		table.remove( self._allTaskList, i )
    	else
    		local transform = {
		    	[1] = 3,	-- 至尊 tab=3 type=1
		    	[2] = 2,	-- 主线 tab=2 type=2
		    	[3] = 1,	-- 日常 tab=1 type=3
		    	[4] = 4,    --毕业典礼
			}
			local index = transform[self._allTaskList[i].taskType]
			taskData.configId = self._allTaskList[i].taskId
			taskData.taskType = self._allTaskList[i].taskType
			taskData.curNum = self._allTaskList[i].curNum
			taskData.maxNum = self._allTaskList[i].maxNum
			taskData.task_status = self._allTaskList[i].task_status
			if self._allTaskList[i].taskType == 4 then
				taskData.gotype = 0
			end
			if taskData.needtype ~= 12 then
    			-- print("btm  ",self._allTaskList[i].taskId)
    			taskData.weight = self._allTaskList[i].task_status*10000 - self._allTaskList[i].taskId
    			self._tabTaskData[index][#(self._tabTaskData[index]) + 1] = taskData
    		else
    			-- print("top  ",self._allTaskList[i].taskId)
    			if self._allTaskList[i].taskType < 4 then
    				self._tabTopTaskData[index][#self._tabTopTaskData[index] + 1] = taskData
    			end
    			
    		end
			
    	end
    end
    -- 对任务列表排序
    for i = 1, 4 do
    	table.sort( self._tabTaskData[i], function( a, b )
	        return a.weight > b.weight
	    end)
	    table.sort( self._tabTopTaskData[i], function( a, b )
	        return a.taskid < b.taskid
	    end)
    end
    -- print("封装好的数据为：")
    -- print_r(self._tabTaskData)
end
-- 刷新界面
function RenWuLayer:refreshUI( toCurrentCell, refreshRedDotData )
	-- 防止任务界面直接被移除
	if not self._iconSpine then
		return
	end
	-- 更新topTask
	if self._tabIndex < 4 then
		self:refreshTopTask()
	end
	-- 更新tasks
	if toCurrentCell then
		self._taskTableView:reloadData()
	else
		self._taskTableView:reloadData()
	end
	-- 更新红点
	self:refreshRedDot( refreshRedDotData )
end
-- 刷新红点，遍历self._allTaskList，设置对应redDot，设置对应红点是否显示
function RenWuLayer:refreshRedDot( refreshRedDotData )
	-- 防止任务界面直接被移除
	if not self._iconSpine then
		return
	end
	if refreshRedDotData then
		-- 初始化红点条件
		self._redDot = {
	    	false,
	    	false,
	    	false,
	    	false,
		}
		for i = 1, #self._tabTaskData do
			for j, v in ipairs(self._tabTaskData[i]) do
				if v.task_status == 1 then
					self._redDot[i] = true
					break
				end
			end
			for j, v in ipairs(self._tabTopTaskData[i]) do
				if v.task_status == 1 then
					self._redDot[i] = true
					break
				end
			end
		end
		-- 根据红点条件设置红点是否显示
		local eventFlag = false
		for i, v in ipairs( self._redDot ) do
			self._tabsTable[i]:getChildByName("redDot"):setVisible( v )
			if v then
				eventFlag = true
			end
		end
		self._tabsTable[self._tabIndex]:getChildByName("redDot"):setVisible( false )
		-- 更新主界面红点
		if not eventFlag then
			XTHD.dispatchEvent({
	            name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,
	            data = {
	                name = "task",
	                visible = false
	            }
	        })
		end
	else
		for i, v in ipairs( self._redDot ) do
			self._tabsTable[i]:getChildByName("redDot"):setVisible( v )
		end
		self._tabsTable[self._tabIndex]:getChildByName("redDot"):setVisible( false )
	end
end
-- 刷新topTask
function RenWuLayer:refreshTopTask()
	-- 防止任务界面直接被移除
	if not self._iconSpine then
		return
	end
	-- dump( self._tabTopTask, "self._tabTopTask" )
	if #self._tabTopTaskData[self._tabIndex] == 0 then
		self._loadingbar:setVisible( false )
		self._loadingbarBg:setVisible( false )
		self._topTaskTip:setVisible( false )
		self._loadingbarNum:setVisible( false )
		self._topRewardIcon:setVisible( false )
		self._topRewardIcon:setEnable( false )
		self._topFinishAllTasks:setVisible( true )
	else
		self._loadingbar:setVisible( true )
		self._loadingbarBg:setVisible( true )
		self._topTaskTip:setVisible( true )
		self._loadingbarNum:setVisible( true )
		self._topRewardIcon:setVisible( true )
		self._topRewardIcon:setEnable( true )
		self._topFinishAllTasks:setVisible( false )
		local data = self._tabTopTaskData[self._tabIndex][1]
		if data.curNum < data.maxNum then
			self._topTaskTip:setString( LANGUAGE_TASK_FORMAT1( ( data.maxNum - data.curNum ), LANGUAGE_KEY_TASKTYPE( self._tabIndex ), "" ) )
			self._loadingbar:setPercentage( ( data.curNum/data.maxNum )*100 )
			self._iconSpine:setAnimation( 0, "idle", true )
	    	self._topRewardIcon:setTouchEndedCallback(function()
	    		local icons, iconData = self:createIcons( data )
	    		-- 预览弹窗
	   			local popLayer = XTHD.createPopLayer({opacityValue = 1})
   				popLayer._containerLayer:setContentSize( #iconData*80 + 20, 130 )
   				popLayer._containerLayer:setAnchorPoint( cc.p( 0.5, 1 ) )
   				popLayer._containerLayer:setPosition( self._topRewardIcon:getContentSize().width*0.5, 0 )
   				self._topRewardIcon:addChild( popLayer )
   				popLayer:show()
   				-- 预览背景
   				local previewPop = ccui.Scale9Sprite:create( "res/image/common/scale9_bg2_25.png" )
	    		previewPop:setAnchorPoint( cc.p( 0, 1 ) )
	    		previewPop:setPosition( 0, 110 )
	    		previewPop:setContentSize( #iconData*80 + 20, 100 )
	    		popLayer:addContent( previewPop )
	    		-- 预览标题
   				local previewTitle = XTHD.createSprite( "res/image/plugin/tasklayer/rewardtext.png" )
	    		previewTitle:setAnchorPoint( cc.p( 0.5, 1 ) )
	    		previewTitle:setPosition( previewPop:getContentSize().width*0.5, previewPop:getContentSize().height - 5 )
	    		previewPop:addChild( previewTitle )
	    		icons:setAnchorPoint( cc.p( 0, 0 ) )
				icons:setPosition( -30, -10 )
	    		previewPop:addChild( icons ) 
	    	end)
		else
			self._topTaskTip:setString( LANGUAGE_KEY_CANFETCHREWARD )
			self._loadingbar:setPercentage( 100 )
			-- self._iconSpine:setAnimation( 0, "2atk", true )
			self._iconSpine:setAnimation( 0, "renwu", true )
	    	self._topRewardIcon:setTouchEndedCallback(function()
	    		XTHDHttp:requestAsyncInGameWithParams({
		            modules="finishTask?",
		            params = {taskId = data.taskid},
		            successCallback = function( finishTask )
		                -- dump(finishTask,"领取顶部任务奖励返回")
		                if tonumber( finishTask.result ) == 0 then
		                	local icons, iconData = self:createIcons( data )
		     --                self._allTaskList = finishTask.task_list
							-- self:buildData()
		     --                self:refreshUI( true, true )
		     				self:freshDataAndUI(finishTask)
		                    -- 成功获取弹窗
					    	ShowRewardNode:createWithParams({
								showData = iconData,
								target = self,
								zorder = 10
					    	})
					    	-- 更新属性
					    	if finishTask.property and #finishTask.property > 0 then
				                for i=1, #finishTask.property do
				                    local pro_data = string.split( finishTask.property[i], ',' )
				                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
				                end
				                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
				            end
				            -- 更新背包
				            if finishTask.bagItems and #finishTask.bagItems ~= 0 then
				                for i=1, #finishTask.bagItems do
				                    local item_data = finishTask.bagItems[i]
				                    if item_data.count and tonumber( item_data.count ) ~= 0 then
				                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
				                    else
				                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
				                    end
				                end
				            end
							XTHD.FristChongZhiPopLayer(cc.Director:getInstance():getRunningScene())
		                else
		                    XTHDTOAST(finishTask.msg)
		                end
		            end,--成功回调
		            failedCallback = function()
		                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
		            end,--失败回调
		            targetNeedsToRetain = self,--需要保存引用的目标
		            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	            })
	    	end)
		end
		self._loadingbarNum:setString( data.curNum.."/"..data.maxNum )
	end
end
-- 重新请求数据，刷新界，完成任务的回调使用
function RenWuLayer:refreshData()
	XTHDHttp:requestAsyncInGameWithParams({
        modules="taskList?",
        successCallback = function( data )
        	-- dump(data, "其他界面返回后端数据" )
	        if tonumber(data.result) == 0 then
				-- 防止任务界面直接被移除
	        	if not self._iconSpine then
	        		return
	        	end
	        	-- 更新所有任务列表
			   self:freshDataAndUI(data)
	        else
	            XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)------"网络请求失败!")
	        end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function RenWuLayer:freshDataAndUI(Taskdata)
	 self.serverTaskData = Taskdata
	    HttpRequestWithOutParams("gragraduationRewardList",function (data)
			-- print("刷新毕业典礼的数据为")
			-- print_r(data)
			self._allTaskList = Taskdata and Taskdata.task_list or {}
			for i = 1,#data.list do
				local tempData = {}
				tempData.maxNum = 0
				tempData.task_status = data.list[i].state
				tempData.taskId = data.list[i].configId
				tempData.taskType = 4
				tempData.curNum = 0
				self._allTaskList[#self._allTaskList + 1] = tempData
			end
			self:buildData()
	   		self:refreshUI( true, true )
	    end)  
end

function RenWuLayer:create( data, CallFunc, index,sdata )
	return self.new( data, CallFunc, index ,sdata)
end

return RenWuLayer