local ChongJiJiangLiLayer = class("ChongJiJiangLiLayer", function(params)
    return XTHD.createFunctionLayer(cc.size(856,415))
end)
--冲级奖励
function ChongJiJiangLiLayer:ctor(params)
    self.parentlayer = params.parentLayer or nil
    local _data = params.httpData or {}
    self.levelRewardStaticData = {}
    self.rewardedLevelData = {}

    self.levelRewardCellBgArr = {}

    self:setRewardedLevelData(_data.levelReward)
    self:setStaticData(_data)
    self:initWithData(_data)
end


function ChongJiJiangLiLayer:onCleanup()
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/activities/levelreward/levelreward_advertsp.png")
    textureCache:removeTextureForKey("res/image/activities/levelreward/levelreward_titlesp.png")
    -- print("8431>>>ChongJiJiangLiLayer:onCleanup()")
    for i=1,#self.levelRewardCellBgArr do
        self.levelRewardCellBgArr[i]:release()
    end
end

function ChongJiJiangLiLayer:initWithData(data)
    local _upHeight = 5
    local _midPosX = 305
    --advert picture
    local _advertSp = cc.Sprite:create("res/image/activities/levelreward/levelreward_advertsp.png")
    _advertSp:setScaleX(0.67)
    _advertSp:setScaleY(0.71)
    _advertSp:setAnchorPoint(cc.p(0,0))
    _advertSp:setPosition(cc.p(0,0))
    self:addChild(_advertSp)
    -- self:setOpacity(0)
    local _tableviewPosY = 5
    local _tableViewSize = cc.size(self:getContentSize().width - _midPosX -2,self:getContentSize().height - _tableviewPosY - _upHeight)
    local _tableViewCellSize = cc.size(_tableViewSize.width,112)
    self._tableView = cc.TableView:create(_tableViewSize)
    self._tableView:setPosition(cc.p(_midPosX -10,_tableviewPosY))
    self._tableView:setBounceable(true)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._tableView:setDelegate()
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(self._tableView)
	
	local function tableCellNumbers(table)
        return #self.levelRewardStaticData
    end

	local function tableCellSize(table,idx)
        return _tableViewCellSize.width,_tableViewCellSize.height
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
			cell:setContentSize(cc.size(_tableViewCellSize.width,_tableViewCellSize.height))
        end
        local _cellBg = self.levelRewardCellBgArr[idx+1] or nil
        if _cellBg~=nil then
            _cellBg:removeFromParent()
            cell:addChild(_cellBg)
            return cell
        end
        local _levelData = self.levelRewardStaticData[idx+1] or {}
        local _needLevel = tonumber(_levelData.level or 0)

        _cellBg = ccui.Scale9Sprite:create("res/image/activities/carnivalSevenDay/carnival_di2.png")
        _cellBg:setContentSize(cc.size(545,110))
        _cellBg:retain()
        self.levelRewardCellBgArr[idx+1] = _cellBg
        _cellBg:setAnchorPoint(cc.p(0,0))
        _cellBg:setPosition(cc.p(0,0))
        cell:addChild(_cellBg)
        local _titleBg = ccui.Scale9Sprite:create("res/image/activities/carnivalSevenDay/carnival_di1.png")
        _titleBg:setContentSize(cc.size(_cellBg:getContentSize().width,33))
        _titleBg:setAnchorPoint(cc.p(0.5,1))
        _titleBg:setPosition(_cellBg:getContentSize().width/2,_cellBg:getContentSize().height)
        _cellBg:addChild(_titleBg)

        local _levelLabel = XTHDLabel:create(LANGUAGE_FORMAT_LEVELREWARD(_needLevel),20)
        _levelLabel:setColor(cc.c4b(55,54,112,255))
        -- getCommonWhiteBMFontLabel(_needLevel)
        _levelLabel:enableShadow(cc.c4b(55,54,112,255),cc.size(0.4,-0.4),0.4)
        _levelLabel:setPosition(cc.p(_titleBg:getContentSize().width/2,_titleBg:getContentSize().height/2))
        _titleBg:addChild(_levelLabel)

        local _leftSp = cc.Sprite:create("res/image/activities/levelreward/levelreward_titlesp.png")
        _leftSp:setPosition(cc.p(_levelLabel:getBoundingBox().x - 5,_levelLabel:getPositionY()))
        _titleBg:addChild(_leftSp)
        _leftSp:setColor(cc.c3b(54,55,112))
        local _rightSp = cc.Sprite:create("res/image/activities/levelreward/levelreward_titlesp.png")
        _rightSp:setPosition(cc.p(_levelLabel:getBoundingBox().x + 5 + _levelLabel:getBoundingBox().width,_levelLabel:getPositionY()))
        _titleBg:addChild(_rightSp)
        _rightSp:setColor(cc.c3b(54,55,112))

        local _rewardposY = 6

        local _rewardSp = getCompositeNodeWithImg("res/image/plugin/tasklayer/taskrewardbg.png", "res/image/plugin/tasklayer/taskrewardtext1.png")
        _rewardSp:setAnchorPoint(cc.p(0.5,0))
        _rewardSp:setPosition(cc.p(30,0))
        _cellBg:addChild(_rewardSp)

        local _playerLevel = tonumber(gameUser.getLevel())
        local _imagekey = "write" 
        local _textStr = LANGUAGE_BTN_KEY.noAchieve
        if _playerLevel>=_needLevel then
            _imagekey = "write_1"
            _textStr = LANGUAGE_BTN_KEY.getReward
        else
            _imagekey = "write"
            _textStr = LANGUAGE_BTN_KEY.noAchieve
        end
        local _rewardBtn = XTHD.createCommonButton({
                btnColor = _imagekey,
                text = _textStr,
                isScrollView = true,
                needEnableWhenMoving = true,
                endCallback = function()
                    -- if self.isScrolling~=nil and self.isScrolling == false then
                        if tonumber(gameUser.getLevel())<_needLevel then
                            XTHDTOAST(LANGUAGE_TIPS_WORDS1)
                            return
                        end
                        self:httpToGetReward(_needLevel)
                    -- end
                    -- self.isScrolling = false
                end
            })
        _rewardBtn:setAnchorPoint(cc.p(0.5,0))
        _rewardBtn:setSwallowTouches(false)
        _rewardBtn:setScale(0.7)
        if _playerLevel>=_needLevel then
            --按钮特效
            local _btnEffect = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)
            _rewardBtn:addChild( _btnEffect )
            _btnEffect:setPosition( _rewardBtn:getBoundingBox().width*0.5+27, _rewardBtn:getContentSize().height/2+2 )
            _btnEffect:setAnimation( 0, "querenjinjie", true)
        end

        _rewardBtn:setPosition(cc.p(_tableViewCellSize.width - 70,_rewardposY))
        _cellBg:addChild(_rewardBtn)

        for i=1,4 do
            if _levelData["num" .. i]==nil or tonumber(_levelData["num" .. i])<1 then
                break
            end
            local _itemposX =_rewardSp:getBoundingBox().x+_rewardSp:getBoundingBox().width + i*(10+65)
            local _itemtype = _levelData["type" .. i] or 0
            local _itemid = _levelData["id" .. i] or 0 
            local _itemnum = _levelData["num" .. i] or 0
            local _rewardItem = ItemNode:createWithParams({
                dbId = nil, 
                itemId = _itemid,
                _type_ = _itemtype,
                touchShowTip = true,
                count = _itemnum
            })
            _rewardItem:setAnchorPoint(cc.p(1,0))
            _rewardItem:setScale(65/_rewardItem:getContentSize().width)
            _rewardItem:setPosition(cc.p(_itemposX,_rewardposY-5))
            _cellBg:addChild(_rewardItem)
        end

        return cell
    end

    self._tableView:registerScriptHandler(tableCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(tableCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:reloadData()
    self:createNonePromptLabel()
end

function ChongJiJiangLiLayer:httpToGetReward(_level)
    if _level == nil then
        return
    end
    ClientHttp:requestAsyncInGameWithParams({
        modules = "levelReward?",
        params = {level=_level},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                self:reFreshHttpData(data)
                self:removeDataAndCell(_level)
                self._tableView:reloadData()
                self:createNonePromptLabel()
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ChongJiJiangLiLayer:createNonePromptLabel()
    if tonumber(#self.levelRewardStaticData) <1 then
        local _promptLabel = XTHDLabel:create(LANGUAGE_KEY_ACTIVITIES.levelRewardNoneTextXc,24) ----------------奖励领完了
        _promptLabel:setColor(cc.c4b(242,202,11,255))
        _promptLabel:setPosition(cc.p((self:getContentSize().width+305)/2,self:getContentSize().height/2+20))
        self:addChild(_promptLabel)
    end
end

--在移除数据的时候，把数据show出来
function ChongJiJiangLiLayer:removeDataAndCell(level)
    if level==nil then
        return
    end
    local _level = level
    local _showData = {}
    for i=1,#self.levelRewardStaticData do
        local _needLevel = self.levelRewardStaticData[i].level or 0
        if _needLevel == level then
            _showData = clone(self.levelRewardStaticData[i] or {})
            table.remove(self.levelRewardStaticData,i)
            if self.levelRewardCellBgArr[i]~=nil then
                -- self.levelRewardCellBgArr[i]:removeAllChildren()
                self.levelRewardCellBgArr[i]:release()
                table.remove(self.levelRewardCellBgArr,i)
            end
            break
        end
    end
    --把领取的物品显示出来
    local _rewardTable = {}
    for i=1,4 do
        if _showData[tostring("num" .. i)] and tonumber(_showData[tostring("num" .. i)])>0 then
            local _index = #_rewardTable + 1
            _rewardTable[_index] = {}
            _rewardTable[_index].rewardtype = _showData[tostring("type" .. i)] or 0
            _rewardTable[_index].id = _showData[tostring("id" .. i)] or 0
            _rewardTable[_index].num = _showData[tostring("num" .. i)] or 0
        end
    end
    ShowRewardNode:create(_rewardTable)
end

function ChongJiJiangLiLayer:getBtnNode(_path)
    local _node = ccui.Scale9Sprite:create(cc.rect(40,0,50,39),_path)
    _node:setContentSize(cc.size(104,39))
    return _node
end

function ChongJiJiangLiLayer:reFreshHttpData(data)
    if data == nil or next(data)==nil then
        return
    end
    for i=1,#data["property"] do
        local pro_data = string.split( data["property"][i],',')
        gameUser.updateDataById(pro_data[1],pro_data[2])
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
    self:setRewardedLevelData(data.levelReward)
end

function ChongJiJiangLiLayer:setRewardedLevelData(data)
    self.rewardedLevelData = {}
    if data==nil or next(data)==nil then
        return
    end
    for i=1,#data do
        self.rewardedLevelData[tostring(data[i])] = 1
    end
end

function ChongJiJiangLiLayer:setStaticData()
    self.levelRewardStaticData = {}
    self.levelRewardStaticData = gameData.getDataFromCSV("GradeAward")
    for i=#self.levelRewardStaticData,1,-1 do
        local _level = self.levelRewardStaticData[i].level or 0
        if self.rewardedLevelData[tostring(_level)] and tonumber(self.rewardedLevelData[tostring(_level)]) == 1 then
            table.remove(self.levelRewardStaticData,i)
        end
    end
end

function ChongJiJiangLiLayer:create(params)
    return self.new(params)
end

return ChongJiJiangLiLayer