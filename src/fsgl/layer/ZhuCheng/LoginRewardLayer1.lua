--  Created by xingchen
local LoginRewardLayer1 = class("LoginRewardLayer1", function(params)
    return  XTHD.createBasePageLayer({bg = "res/image/plugin/loginreward/loginreward_bg.jpg"})
end)

function LoginRewardLayer1:onCleanup( )
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("res/image/plugin/loginreward/xiongmaoa.plist")
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/plugin/loginreward/loginreward_bg.jpg")
    textureCache:removeTextureForKey("res/image/plugin/loginreward/loginreward_heroBaseSp.png")
    textureCache:removeTextureForKey("res/image/plugin/loginreward/xiongmaoa.png")
    textureCache:removeTextureForKey("res/image/plugin/loginreward/loginreward_heroBaseEffect.png")
    textureCache:removeTextureForKey("res/image/plugin/loginreward/loginreward_heroDesc.png")
    for i=2,7 do
        textureCache:removeTextureForKey("res/image/plugin/loginreward/loginreward_descSp_" .. i .. ".png")
    end
end

function LoginRewardLayer1:ctor(data)
    self.httpData = {}
    self.httpData = data or nil
    self.layerBg = nil
    self.heroSp = nil
    self.animate = nil
    self.timeData = {}
    self.loginRewardData = {}
    self.rewardNumber = 4

    if self:getChildByName("BgSprite") then
        self.layerBg = self:getChildByName("BgSprite")
    else
        return
    end
    
    self:setTimeData()
    self:getLoginRewardData()
    if self.httpData==nil then
        return
    end

    self:initLayer()
end

function LoginRewardLayer1:initLayer(data)
    
    local layer_height = self:getContentSize().height - self.topBarHeight
    local _layerBg = cc.Sprite:createWithTexture(nil,cc.rect(0,0,922,576))
    _layerBg:setAnchorPoint(cc.p(0.5,0.5))
    _layerBg:setOpacity(0)
    self.layerBg =_layerBg 
    _layerBg:setPosition(cc.p(self:getContentSize().width/2,layer_height/2))
    self:addChild(_layerBg)
    local _heroid = 28

    self:initRewardLayer()
    
    local _heroBaseSp = cc.Sprite:create("res/image/plugin/loginreward/loginreward_heroBaseSp.png")
    _heroBaseSp:setAnchorPoint(cc.p(0,0))
    _heroBaseSp:setPosition(cc.p(25 + 15-5,82 + 30-80))
    self.layerBg:addChild(_heroBaseSp)

    local _heroNameBg = cc.Sprite:create("res/image/exchange/reward/reward_name.png")
    _heroNameBg:setAnchorPoint(cc.p(0,0))
    _heroNameBg:setPosition(cc.p(10,80+85))
    _heroBaseSp:addChild(_heroNameBg)
    local _heroNameSp = cc.Sprite:create("res/image/exchange/reward/hero_name/hero_name_".._heroid..".png")
    _heroNameSp:setPosition(_heroNameBg:getContentSize().width/2,_heroNameBg:getContentSize().height/2+25)
    _heroNameBg:addChild(_heroNameSp)

    --fire
    local _firePath = "res/image/homecity/frames/fire/1.png"
    local _fireposY = 72+60
    local _fireAnimate1 = getAnimation("res/image/homecity/frames/fire/",1,7,0.1)
    local _fireAnimate2 = getAnimation("res/image/homecity/frames/fire/",1,7,0.1)


    local _fireLeftSp = cc.Sprite:create(_firePath)
    _fireLeftSp:setAnchorPoint(cc.p(0.5,0))
    _fireLeftSp:setPosition(cc.p(27,_fireposY))
    _heroBaseSp:addChild(_fireLeftSp)
    _fireLeftSp:runAction(cc.RepeatForever:create(_fireAnimate1))

    local _fireRightSp = cc.Sprite:create(_firePath)
    _fireRightSp:setAnchorPoint(cc.p(0.5,0))
    _fireRightSp:setPosition(cc.p(_heroBaseSp:getContentSize().width - 30,_fireposY))
    _heroBaseSp:addChild(_fireRightSp)
    _fireRightSp:runAction(cc.RepeatForever:create(_fireAnimate2))

    

    local _starPosY = 325+85
    for i=1,3 do
        local _posX = _heroBaseSp:getContentSize().width/2 + (i-2)*40
        local _starSp = cc.Sprite:create("res/image/common/star_light.png")
        _starSp:setScale(1.5)
        _starSp:setPosition(cc.p(_posX,_starPosY))
        _heroBaseSp:addChild(_starSp)
    end
	
	local _heroSp = nil
	if heroId ~= 322 and heroId ~= 026 and heroId ~= 042 then
		_heroSp = sp.SkeletonAnimation:createWithBinaryFile( "res/spine/" .. _heroid .. ".skel", "res/spine/" .. _heroid .. ".atlas", 1 )
	else
		_heroSp = sp.SkeletonAnimation:create("res/spine/0" .. _heroid .. ".json", "res/spine/0" .. _heroid .. ".atlas", 1)
	end
    local _herobaseEffect = cc.Sprite:create("res/image/plugin/loginreward/loginreward_heroBaseEffect.png")
    _herobaseEffect:setScale(2)
    _herobaseEffect:setAnchorPoint(cc.p(0.5,0))
    _herobaseEffect:setPosition(cc.p(_heroBaseSp:getContentSize().width/2+10,_heroBaseSp:getContentSize().height-90+30-5))
    _heroBaseSp:addChild(_herobaseEffect)
    _herobaseEffect:setOpacity(100)
    _herobaseEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.75,90),cc.FadeTo:create(0.75,100))))

    self.heroSp = _heroSp
    _heroSp:setPosition(cc.p(_heroBaseSp:getContentSize().width/2,110+85))
    _heroBaseSp:addChild(_heroSp)
    _heroSp:setAnimation(0,"idle",true)

    --按钮
    local _heroClickBtn = XTHD.createButton({
            normalNode = cc.Sprite:create()
            ,selectedNode = cc.Sprite:create()
            ,touchSize = cc.size(200,300)
        })
    _heroClickBtn:setAnchorPoint(cc.p(0.5,0))
    _heroClickBtn:setPosition(cc.p(_heroBaseSp:getContentSize().width/2,_heroBaseSp:getContentSize().height))
    _heroBaseSp:addChild(_heroClickBtn)
    _heroClickBtn:setTouchEndedCallback(function()
            self:playHeroAnimation()
        end)

    --animation
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/image/plugin/loginreward/xiongmaoa.plist","res/image/plugin/loginreward/xiongmaoa.png")
    -- local _starupAnimation = getAnimation("",1,12,0.06)
    local _lightFrames = {}
    for i=1,15 do
        _lightFrames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame("huodong_000" .. i .. ".png")
    end
    local _light_animation = cc.Animation:createWithSpriteFrames(_lightFrames,0.1)
    local _lightAnimate = cc.Animate:create(_light_animation)
    local _lightSp = cc.Sprite:createWithSpriteFrame(_lightFrames[1])
    _lightSp:setAnchorPoint(cc.p(0.5,0))
    _lightSp:setScale(2)
    _lightSp:setPosition(cc.p(_heroSp:getContentSize().width/2+10,-40))
    _heroSp:addChild(_lightSp)
    _lightSp:runAction(cc.RepeatForever:create(_lightAnimate))

    local _herodescSp = cc.Sprite:create("res/image/plugin/loginreward/loginreward_heroDesc.png")
    _herodescSp:setAnchorPoint(cc.p(0.5,0))
    _herodescSp:setPosition(cc.p(_heroBaseSp:getContentSize().width/2,5+60))
    _heroBaseSp:addChild(_herodescSp)
end

function LoginRewardLayer1:initRewardLayer()
    local _tableViewSize = cc.size(600,493)
    local _tableViewCellSize = cc.size(600,493)
    self._tableView = cc.TableView:create(_tableViewSize)
	TableViewPlug.init(self._tableView)
    self._tableView:setTouchEnabled(false)
    self._tableView:setPosition(cc.p(322,0+30))
    self._tableView:setBounceable(false)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) --设置横向纵向
    self._tableView:setDelegate()
    self.layerBg:addChild(self._tableView)

    --左边箭头
    local _leftScrollBtn = XTHD.createButton({
            normalFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
            selectedFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
            touchScale = 0.95
            -- ,musicFile = XTHD.resource.music.effect_btn_common
        })
    _leftScrollBtn:setAnchorPoint(cc.p(0.5,0.5))
    _leftScrollBtn:setPosition(cc.p(0+5+_leftScrollBtn:getContentSize().width/2,self.layerBg:getBoundingBox().y+270+30))
    self:addChild(_leftScrollBtn)
    _leftScrollBtn:setTouchEndedCallback(function()
            local _page = self._tableView:getCurrentPage()
            if _page <1 then
                return
            end
            self._tableView:scrollToCell(_page-1)
        end)
    --右边箭头
    local _rightScrollBtn = XTHD.createButton({
            normalFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
            selectedFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
            touchScale = 0.95
            -- ,musicFile = XTHD.resource.music.effect_btn_common
        })
    _rightScrollBtn:setAnchorPoint(cc.p(0.5,0.5))
    _rightScrollBtn:setPosition(cc.p(self:getContentSize().width - 10+5 -_rightScrollBtn:getContentSize().width/2,self.layerBg:getBoundingBox().y+270+30))
    self:addChild(_rightScrollBtn)

    _rightScrollBtn:setTouchEndedCallback(function()
            local _page = self._tableView:getCurrentPage()
            if _page >(#self.loginRewardData-2) then
                return
            end
            self._tableView:scrollToCell(_page+1)
        end)

	self._tableView.getCellSize = function cellSizeForTable(table,idx)
        return _tableViewCellSize.width,_tableViewCellSize.height
    end
	
	self._tableView.getCellNumbers = function numberOfCellsInTableView(table)
        return #self.loginRewardData
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
        end
        local _rewardData = self.loginRewardData[idx+1] or {}
        local _dayIndex = tonumber(_rewardData["needlogin"])
        local _totalDay = tonumber(self.httpData["totalDay"])
        local _rewardDesc = cc.Sprite:create("res/image/plugin/loginreward/loginreward_descSp_" .. _dayIndex .. ".png")
        _rewardDesc:setAnchorPoint(cc.p(0,0))
        _rewardDesc:setPosition(cc.p(0,280))
        cell:addChild(_rewardDesc)
        
        local _rewardBtn = nil
        
        if _dayIndex<=_totalDay+1 then
            _rewardBtn = XTHD.createCommonButton({
                    btnSize = cc.size(280,46),
                    isScrollView = true,
                })
            
            if _dayIndex==_totalDay+1 then
                local _rewardTime = self:getRewardTime()
                local _timeLabel = getCommonWhiteBMFontLabel(XTHD.getTimeHMS(_rewardTime,true))
                _timeLabel:setName("timeLabel")
                _timeLabel:setPosition(cc.p(_rewardBtn:getContentSize().width/2,_rewardBtn:getContentSize().height/2-7))
                _rewardBtn:addChild(_timeLabel)
                LANGUAGE_SETTIMELABEL_LOGINREWARD(_rewardBtn)
                schedule(_timeLabel, function()
                        _rewardTime = _rewardTime - 1
                        if _rewardTime<1 then
                            self.httpData.totalDay = tonumber(self.httpData.totalDay) + 1
                            self.httpData["time"] = 24*60*60
                            self:setTimeData()
                            self._tableView:reloadDataAndScrollToCurrentCell()
                        end
                        _timeLabel:setString(XTHD.getTimeHMS(_rewardTime,true))
                    end,1)
                _rewardBtn:setTouchEndedCallback(function()
                    XTHDTOAST(LANGUAGE_TIPS_FETCHREWARD(_timeLabel:getString()))-----"后可领取奖励")
                    -- self:httpToGetReward(idx + 1)
                end)
            else
                local _btnText = ""
                if _rewardData.state and tonumber(_rewardData.state)==1 then
                    _btnText = LANGUAGE_REWARDTOAST_1
                    _rewardBtn:setTouchEndedCallback(function()
                        XTHDTOAST(LANGUAGE_TIPS_WORDS143)-----"该奖励已经被领取")
                    end)
                else
                    _btnText = LANGUAGE_REWARDTOAST_2
                    _rewardBtn:setTouchEndedCallback(function()
                        self:httpToGetReward(idx + 1)
                    end)
                end
                local _btnLabel = XTHDLabel:create(_btnText,22)
                _btnLabel:setColor(XTHD.resource.btntextcolor.green)
                _btnLabel:enableShadow(XTHD.resource.btntextcolor.green,cc.size(0.4,-0.4),0.4)
                _btnLabel:setPosition(cc.p(_rewardBtn:getContentSize().width/2,_rewardBtn:getContentSize().height/2))
                _rewardBtn:addChild(_btnLabel)
            end
            
        else
            _rewardBtn = XTHDLabel:create(LANGUAGE_REWARDTOAST_3,26)
            _rewardBtn:setColor(cc.c4b(236,55,0,255))
            _rewardBtn:enableShadow(cc.c4b(236,55,0,255),cc.size(0.4,-0.4),0.4)
        end
        _rewardBtn:setAnchorPoint(cc.p(0.5,0.5))
        
        _rewardBtn:setPosition(cc.p(_tableViewCellSize.width/2,80))
        cell:addChild(_rewardBtn)


        local _rewardBg = cc.Sprite:create("res/image/plugin/loginreward/loginreward_rewardBg.png")
        -- _rewardBg:setScaleX(1.2)
        _rewardBg:setAnchorPoint(cc.p(1,0))
        _rewardBg:setPosition(cc.p(_tableViewCellSize.width,112 + 8))
        cell:addChild(_rewardBg)
        local _itemPosY = _rewardBg:getContentSize().height/2-3 - 68/2
        local _itemPosTable = SortPos:sortFromMiddle(cc.p(_rewardBg:getContentSize().width/2+47,_itemPosY),4,100)
        for i=1,self.rewardNumber do
            -- local _itemPosX = 140+(i-1)*70
            local _itemPosX = _itemPosTable[i].x
            local _rewardItem = ItemNode:createWithParams({
                dbId = nil,
                itemId = _rewardData["reword" .. i .. "id"],
                _type_ = _rewardData["reword" .. i .. "type"],
                touchShowTip = true,
                count = _rewardData["reword" .. i .. "num"]
            })
            _rewardItem:setAnchorPoint(cc.p(1,0))
            if i~=1 then
                _rewardItem:setScale(68/_rewardItem:getBoundingBox().width)
            end
            _rewardItem:setPosition(cc.p(_itemPosX,_itemPosY))
            _rewardBg:addChild(_rewardItem)
            if _rewardData.state==nil or tonumber(_rewardData.state)~=1 then
                local _itemSize = _rewardItem:getContentSize()
                local _animationSp = cc.Sprite:create("res/image/vip/effect/effect1.png")
                _animationSp:setPosition(cc.p(_itemSize.width*0.5-1, _itemSize.height*0.5+2))
                _rewardItem:addChild(_animationSp)
                local brust_animation = getAnimation("res/image/vip/effect/effect",1,8,1/10) --点击
                _animationSp:setScale(0.9)
                _animationSp:runAction(cc.RepeatForever:create(brust_animation))
            end
            
        end
        if #self.loginRewardData == 1 then
            _rightScrollBtn:setVisible(false)
            _leftScrollBtn:setVisible(false)
        
        elseif idx == #self.loginRewardData-1 then
            _rightScrollBtn:setVisible(false)
            _leftScrollBtn:setVisible(true)
        elseif idx == 0 then
            _rightScrollBtn:setVisible(true)
            _leftScrollBtn:setVisible(false)
        else
            _rightScrollBtn:setVisible(true)
            _leftScrollBtn:setVisible(true)
        end

        return cell
    end
	
    self._tableView:registerScriptHandler(self._tableView.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(self._tableView.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    -- self._tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:reloadData()
end

function LoginRewardLayer1:httpToGetReward(_idx)
    local _dayIndex = self.loginRewardData[_idx or 1].needlogin
    ClientHttp:requestAsyncInGameWithParams({
        modules = "liucunReward?",
        params = {dayId=_dayIndex},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                self.httpData.liucunReward = data.liucunReward
                self.httpData.totalDay = data.totalDay or 0
                self:setDayindexState()
                self:reFreshHttpData(data)
                local _page = tonumber(self._tableView:getCurrentPage())
                if _page >= #self.loginRewardData-1 then
                    self._tableView:reloadDataAndScrollToCurrentCell()
                else
                    self._tableView:reloadData()
                    self._tableView:scrollToCell(_page+1)
                end
                
                local _rewardTable = {}
                for i=1,self.rewardNumber do
                    local _rewardData = self.loginRewardData[_idx or 1] or {}
                    _rewardTable[i] = {}
                    _rewardTable[i].rewardtype = tonumber(_rewardData["reword" .. i .. "type"] or 1)
                    _rewardTable[i].num = tonumber(_rewardData["reword" .. i .. "num"] or 0)
                    -- _rewardTable[i].dbId = _rewarddbid
                    _rewardTable[i].id = tonumber(_rewardData["reword" .. i .. "id"] or 1)
                end
                ShowRewardNode:create(_rewardTable)
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function LoginRewardLayer1:reFreshHttpData(data)
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
    RedPointManage:reFreshDynamicItemData()
end

function LoginRewardLayer1:playHeroAnimation()
    local _nameTable = {action_Atk0,action_Atk1,action_Atk2,action_Atk,action_Win}
    math.randomseed(tostring(os.time()):reverse():sub(1,6))
    local _time = math.random(1,#_nameTable)
    if not self.animate then
        self.animate = _time
    else
        if self.animate == _time then
            self.animate = self.animate%(#_nameTable)+1
        else
            self.animate = _time
        end
    end
    local _name =_nameTable[self.animate]
    self.heroSp:setAnimation(0,_name,false)
    self.heroSp:addAnimation(0,"idle",true)
end

function LoginRewardLayer1:setDayindexState()
    local _liucunRewardData = {}
    if #self.httpData.liucunReward>=6 then
        XTHD.dispatchEvent({name = CUSTOM_EVENT.UPDATE_ACTIVITYMENUS,data = {index = 1,visible = false}})
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "liucunPackage",visible = false}})
    end
    for i=1,#self.httpData.liucunReward do
        _liucunRewardData[tostring(self.httpData.liucunReward[i])] = 1
    end
    for i=1,#self.loginRewardData do
        self.loginRewardData[i].state = 0
        if _liucunRewardData[tostring(self.loginRewardData[i].needlogin)]~=nil and tonumber(_liucunRewardData[tostring(self.loginRewardData[i].needlogin)])==1 then
            self.loginRewardData[i].state = 1
        end
    end
end

function LoginRewardLayer1:getRewardTime()
    local _rewardTime = 0
    local _curClientTime = tonumber(os.time())
    _rewardTime = self.timeData._serverTime - (_curClientTime - self.timeData._clientTime)
    return _rewardTime
end

function LoginRewardLayer1:getBtnNode(_path)
    local _node = ccui.Scale9Sprite:create(cc.rect(50,0,30,49),_path)
    _node:setContentSize(cc.size(280,49))
    return _node
end

function LoginRewardLayer1:setTimeData()
    self.timeData = {}
    self.timeData._serverTime = tonumber(self.httpData["time"] or 0)
    self.timeData._clientTime = tonumber(os.time())
end

function LoginRewardLayer1:getLoginRewardData()
    self.loginRewardData = {}
    self.loginRewardData = gameData.getDataFromCSV("CumulativeLand")
    local _liucunreward = self.httpData["liucunReward"] or {}
    table.sort(_liucunreward,function(data1,data2)
            return tonumber(data1)<tonumber(data2)
        end)
    for i=#_liucunreward,1,-1 do
        table.remove(self.loginRewardData,tonumber(_liucunreward[i])-1)
    end
end

function LoginRewardLayer1:getTextColor(_str)
    local _color = {
        shenhese = cc.c4b(70,34,34,255)
    }
    return _color[tostring(_str)]
end

function LoginRewardLayer1:create(data)
    local _layer = self.new(data)
    return _layer
end

return LoginRewardLayer1