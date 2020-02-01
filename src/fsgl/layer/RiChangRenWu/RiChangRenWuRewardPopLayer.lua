local RiChangRenWuRewardPopLayer = class("RiChangRenWuRewardPopLayer",function()
		return XTHDPopLayer:create()
	end)

function RiChangRenWuRewardPopLayer:ctor(data,dicelayer)
    self.dicelayer = dicelayer
	self.data = data
    self._fontSize = 20
    self.rewardData = {}
    self.rewardedLevelData = {}

    self._tableview = nil
    -- self.isScrolling = false
    self:setRewardedLevelData(self.data.proficiencyGotState)
    self:setRewardData()

	self:initLayer()
end
function RiChangRenWuRewardPopLayer:initLayer()
	local _popBgSprite  = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg3_34.png")
 	_popBgSprite:setContentSize(cc.size(530,485))
 	local popNode = XTHDPushButton:createWithParams({
        normalNode = _popBgSprite
    })
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:getContainerLayer():addChild(popNode)
    self.popNode = popNode

    local _closeBtn = XTHD.createBtnClose(function()
        self:hide()
    end)
    _closeBtn:setPosition(cc.p(popNode:getContentSize().width-15,popNode:getContentSize().height - 15))
    popNode:addChild(_closeBtn)

    --熟练度title
    local _titleBg = ccui.Scale9Sprite:create("res/image/login/zhanghaodenglu.png")
    -- _titleBg:setContentSize(cc.size(230,34))
    _titleBg:setAnchorPoint(cc.p(0.5,0.5))
    _titleBg:setPosition(cc.p(popNode:getContentSize().width/2,popNode:getContentSize().height))
    popNode:addChild(_titleBg)

    local _titleLabel = XTHDLabel:create(LANGUAGE_KEY_TITLENAME.proficientyRewardTitleTextXc,self._fontSize+2)
    _titleLabel:setColor(cc.c3b(104, 33, 11))
    _titleLabel:setPosition(cc.p(_titleBg:getContentSize().width/2,_titleBg:getContentSize().height/2))
    _titleBg:addChild(_titleLabel)

    local _proficientyLevelSp = cc.Sprite:create("res/image/daily_task/destiny_dice/currtProficientyLeveltext.png")
    _proficientyLevelSp:setAnchorPoint(cc.p(0.5,0))
    _proficientyLevelSp:setPosition(cc.p(popNode:getContentSize().width/2,popNode:getContentSize().height-57))
    popNode:addChild(_proficientyLevelSp)

    local _proficientyLabel = XTHDLabel:createWithParams({fnt = "res/image/common/common_num/2_0.fnt" , text = self.data.proficiencyRank or 0 , kerning = 0})
    _proficientyLabel:setScale(1.3)
    _proficientyLabel:setAnchorPoint(cc.p(0,0))
    _proficientyLabel:setPosition(cc.p(_proficientyLevelSp:getBoundingBox().x+_proficientyLevelSp:getBoundingBox().width+3,_proficientyLevelSp:getBoundingBox().y-15))
    popNode:addChild(_proficientyLabel)

    self:setRewardListLayer()

	self:show()
end

function RiChangRenWuRewardPopLayer:setRewardListLayer()
    -- tableView背景
    local tableViewBg = ccui.Scale9Sprite:create( "res/image/common/scale9_bg2_25.png" )
    tableViewBg:setContentSize( 512, 392 )
    tableViewBg:setAnchorPoint( cc.p( 0, 0 ) )
    tableViewBg:setPosition( 9, 30 )
    self.popNode:addChild( tableViewBg )

    local _tableviewSize = cc.size(498,366)
    self._tableview = cc.TableView:create(_tableviewSize)
TableViewPlug.init(self._tableview)
    self._tableview:setBounceable(false)
    self._tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableview:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableview:setDelegate()
    self._tableview:setPosition(16,42)
    self.popNode:addChild(self._tableview)

    local tableViewCellSize = cc.size(_tableviewSize.width,90+8)

    local function numberOfCellsInTableView(table_view)
        local _listNumber = 10
        if tonumber(#self.rewardData) < tonumber(_listNumber) then
            _listNumber = tonumber(#self.rewardData)
        end
        return _listNumber
    end
    local function cellSizeForTable(table_view, idx)
        return tableViewCellSize.width,tableViewCellSize.height
    end
    -- local function scrollViewDidScoll(table_view)
    --     self.isScrolling = true
    -- end

    local function tableCellAtIndex(table_view, idx)
        local cell = table_view:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
			cell:setContentSize(tableViewCellSize.width,tableViewCellSize.height)
        end
        local _cellBg = self:createCellSprite(idx+1)
        _cellBg:setAnchorPoint(cc.p(0.5,0))
        _cellBg:setPosition(cc.p(tableViewCellSize.width/2,4))
        cell:addChild(_cellBg)

        -- 分隔线
        -- local splitCellLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
        -- splitCellLine:setContentSize( 508, 2 )
        -- splitCellLine:setAnchorPoint( cc.p( 0.5, 0 ) )
        -- splitCellLine:setPosition( tableViewCellSize.width*0.5, -2 )
        -- cell:addChild( splitCellLine )

        return  cell
    end

self._tableview.getCellNumbers=numberOfCellsInTableView
    self._tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
self._tableview.getCellSize=cellSizeForTable
    self._tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    -- self._tableview:registerScriptHandler(scrollViewDidScoll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableview:reloadData()
end

function RiChangRenWuRewardPopLayer:createCellSprite(_idx)

    local _bgSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png" )--ccui.Scale9Sprite:create(cc.rect(52,52,1,1),"res/image/common/scale9_bg_3.png")
    _bgSprite:setContentSize(cc.size(504,90))
    local _rewardData = self.rewardData[tonumber(_idx)]
    if _rewardData==nil or next(_rewardData)==nil then
        return _bgSprite
    end

    -- 熟练度等级
    local _proficientyLabel = XTHDLabel:create(LANGUAGE_KEY_DESTINYDICE.proficientyReceiveTextXc,self._fontSize)
    _proficientyLabel:setColor(self:getTextColor("shenhese"))
    _proficientyLabel:setAnchorPoint(cc.p(0,0.5))
    _proficientyLabel:setPosition(cc.p(18,_bgSprite:getContentSize().height/2))
    _bgSprite:addChild(_proficientyLabel)

    local _rewardLevel = tonumber(_rewardData.level or 0)
    -- _rewardLevel = 23
    local _proficientyLevelLabel = XTHDLabel:create(_rewardLevel,self._fontSize + 8)
    _proficientyLevelLabel:setColor(self:getTextColor("hongse"))
    _proficientyLevelLabel:setAnchorPoint(cc.p(0,0))
    _proficientyLevelLabel:setPosition(cc.p(_proficientyLabel:getBoundingBox().x+_proficientyLabel:getBoundingBox().width+2,_proficientyLabel:getBoundingBox().y-2))
    _bgSprite:addChild(_proficientyLevelLabel)

    local _proficientyGradeLabel = XTHDLabel:create(LANGUAGE_NAMES.level,self._fontSize)
    _proficientyGradeLabel:setColor(self:getTextColor("shenhese"))
    _proficientyGradeLabel:setAnchorPoint(cc.p(0,0.5))
    _proficientyGradeLabel:setPosition(cc.p(_proficientyLevelLabel:getBoundingBox().x+_proficientyLevelLabel:getBoundingBox().width+2,_proficientyLabel:getPositionY()))
    _bgSprite:addChild(_proficientyGradeLabel)

    --领取按钮
    local _btnText = LANGUAGE_BTN_KEY.noAchieve
    local _textColor = cc.c3b(255,255,255)
    local _btnImg = "write"
    if _rewardLevel <= tonumber(self.data.proficiencyRank or 0) then
        _btnText = LANGUAGE_BTN_KEY.getReward
        _textColor = cc.c3b(255,255,255)
        _btnImg = "write_1"
    end
    local _rewardBtn = XTHD.createButton({
            normalFile = "res/image/common/btn/btn_" .. _btnImg .. "_up.png",
            selectedFile = "res/image/common/btn/btn_" .. _btnImg .. "_down.png",
            label = XTHDLabel:create(_btnText,20,"res/fonts/def.ttf"),
            fontColor = _textColor,
            needEnableWhenMoving = true,
			isScrollView = true,
            fontSize = 26,
            endCallback = function()
                -- if self.isScrolling~=nil and self.isScrolling == false then
                    if _rewardLevel > tonumber(self.data.proficiencyRank or 0) then
                        XTHDTOAST(LANGUAGE_TIPS_WORDS217)
                        return
                    end
                    self:httpToGetReward(_idx)
                -- end
                -- self.isScrolling = false
            end
        })
        _rewardBtn:setScale(0.7)
        if _btnImg == "write_1" then
            _rewardBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
        elseif _btnImg == "write" then
            _rewardBtn:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
        end
    _rewardBtn:setSwallowTouches(false)
    --按钮上的特效
    if _rewardLevel <= tonumber(self.data.proficiencyRank or 0) then
        local _btnEffect = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)
        _rewardBtn:addChild( _btnEffect )
        _btnEffect:setPosition( _rewardBtn:getContentSize().width*0.5+7, _rewardBtn:getContentSize().height/2+3 )
        _btnEffect:setAnimation( 0, "querenjinjie", true)
    end
    _rewardBtn:setPosition(cc.p(_bgSprite:getContentSize().width-80,_bgSprite:getContentSize().height/2))
    _bgSprite:addChild(_rewardBtn)

    local _rewardItemPosX = (_rewardBtn:getBoundingBox().x +_proficientyGradeLabel:getBoundingBox().x+_proficientyGradeLabel:getBoundingBox().width)/2 - (60/2+7)

    for i=1,2 do
        if not _rewardData["num" .. i] or tonumber(_rewardData["num" .. i])<1 then
            break
        end
        local _posX = _rewardItemPosX + (i-1)*(60/2+7)*2
        local _rewardItem = ItemNode:createWithParams({
                dbId = nil,
                itemId = _rewardData["id" .. i] or 0,
                _type_ = _rewardData["rewardtype" .. i] or 0,
                touchShowTip = true,
                count = _rewardData["num" .. i] or 0
            })
        _rewardItem:setScale(60/_rewardItem:getBoundingBox().width)
        _rewardItem:setPosition(cc.p(_posX,_bgSprite:getContentSize().height/2))
        _bgSprite:addChild(_rewardItem)
    end
    return _bgSprite
end

function RiChangRenWuRewardPopLayer:httpToGetReward(_idx)
    local _level = self.rewardData[tonumber(_idx)].level or 0
    ClientHttp:requestAsyncInGameWithParams({
        modules = "getProficiencyReward?",
        params = {rank = _level},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                self:reFreshHttpData(data)
                -- local _showRewardData = clone(self.rewardData[tonumber(_idx)])
                self:removeDataAndCell(_level)
                self._tableview:reloadDataAndScrollToCurrentCell()
                self:createNonePromptLabel()
                -- local _rewardTable = {}
                -- for i=1,2 do
                --     if not _showRewardData["num" .. i] or tonumber(_showRewardData["num" .. i])<1 then
                --         break
                --     end
                --     _rewardTable[i] = {}
                --     _rewardTable[i].rewardtype = tonumber(_showRewardData["rewardtype" .. i])
                --     _rewardTable[i].id = tonumber(_showRewardData["id" .. i])
                --     _rewardTable[i].num = tonumber(_showRewardData["num" .. i])
                -- end
                -- ShowRewardNode:create(_rewardTable)
            else
               XTHDTOAST(data.msg)
            end
        end,--成功回调
        targetNeedsToRetain = button,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function RiChangRenWuRewardPopLayer:createNonePromptLabel()
    if tonumber(#self.rewardData) <1 then
        local _promptLabel = XTHDLabel:create(LANGUAGE_KEY_DESTINYDICE.proficientyRewardNoneTextXc,24)
        _promptLabel:setColor(cc.c4b(70,34,34,255))
        _promptLabel:setPosition(cc.p(self.popNode:getContentSize().width/2,self.popNode:getContentSize().height/2))
        self.popNode:addChild(_promptLabel)
    end
end

--在移除数据的时候，把数据show出来
function RiChangRenWuRewardPopLayer:removeDataAndCell(level)
    if level==nil then
        return
    end
    local _level = level
    local _showRewardData = {}
    for i=1,#self.rewardData do
        local _needLevel = self.rewardData[i].level or 0
        if _needLevel == level then
            _showRewardData = clone(self.rewardData[i] or {})
            table.remove(self.rewardData,i)
            break
        end
    end
    -- --把领取的物品显示出来
    -- local _rewardTable = {}
    -- for i=1,4 do
    --     if _showData[tostring("num" .. i)] and tonumber(_showData[tostring("num" .. i)])>0 then
    --         local _index = #_rewardTable + 1
    --         _rewardTable[_index] = {}
    --         _rewardTable[_index].rewardtype = _showData[tostring("type" .. i)] or 0
    --         _rewardTable[_index].id = _showData[tostring("id" .. i)] or 0
    --         _rewardTable[_index].num = _showData[tostring("num" .. i)] or 0
    --     end
    -- end
    -- ShowRewardNode:create(_rewardTable)
    local _rewardTable = {}
    for i=1,2 do
        if not _showRewardData["num" .. i] or tonumber(_showRewardData["num" .. i])<1 then
            break
        end
        _rewardTable[i] = {}
        _rewardTable[i].rewardtype = tonumber(_showRewardData["rewardtype" .. i])
        _rewardTable[i].id = tonumber(_showRewardData["id" .. i])
        _rewardTable[i].num = tonumber(_showRewardData["num" .. i])
    end
    ShowRewardNode:create(_rewardTable)
end

function RiChangRenWuRewardPopLayer:reFreshHttpData(data)
    if data == nil or next(data)==nil then
        return
    end
    for i=1,#data["property"] do
        local pro_data = string.split( data["property"][i],',')
        gameUser.updateDataById(pro_data[1],pro_data[2])
        -- DBUpdateFunc:UpdateProperty("userdata"
    end

    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    local _rewarddbid = nil
    for i=1,#data["items"] do
        local _dbid = data.items[i].dbId
        _rewarddbid = _dbid
        if data.items[i].count and tonumber(data.items[i].count)>0 then
            DBTableItem.updateCount(gameUser.getUserId(),data.items[i],_dbid)
        else
            DBTableItem.deleteData(gameUser.getUserId(),_dbid)
        end
    end
    self:setRewardedLevelData(data.proficiencyGotState)
    self.dicelayer:refreshProficietyData(data)
end

function RiChangRenWuRewardPopLayer:setRewardedLevelData(data)
    self.rewardedLevelData = {}
    if data==nil or next(data)==nil then
        return
    end
    for i=1,#data do
        self.rewardedLevelData[tostring(data[i])] = 1
    end
end

function RiChangRenWuRewardPopLayer:setRewardData()
    self.rewardData = {}
    self.rewardData = gameData.getDataFromCSV("DiceGame")
    for i=1,6 do
        table.remove(self.rewardData,1)
    end
    for i=#self.rewardData,1,-1 do
        local _level = self.rewardData[i].level or 0
        if (not self.rewardData[i]["typeA"] or tonumber(self.rewardData[i]["typeA"])==1) or (self.rewardedLevelData[tostring(_level)] and tonumber(self.rewardedLevelData[tostring(_level)]) == 1) then
            table.remove(self.rewardData,i)
        end
    end
end

function RiChangRenWuRewardPopLayer:getTextColor(_str)
    local _color = {
        shenhese = cc.c4b(55,54,112,255),                        --深褐色，用的比较多
        hongse = cc.c4b(204,2,2,255), 
        baise = cc.c3b(255,255,255)                          --红色
    }
    return _color[_str]
end

function RiChangRenWuRewardPopLayer:create(data,dicelayer)
	--这里是:或者还是.
	local _layer = self.new(data,dicelayer)
	return _layer
end

return RiChangRenWuRewardPopLayer