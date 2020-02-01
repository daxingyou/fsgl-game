--[[
多人副本，选择副本面板 

┏━━━┛┻━━━┛┻━━┓
┃｜｜｜｜｜｜｜┃
┃　　　━　　　 ┃
┃　┳┛ 　┗┳  　┃
┃　　　　　　　┃
┃　　　┻　　 　┃
┃　　　　　　　┃
┗━━┓　　　┏━┛
　　┃　史　┃　　
　　┃　诗　┃　　
　　┃　之　┃　　
　　┃　宠　┃
　　┃　　　┗━━━┓
　　┃         ┣┓
　　┃　　　  　┃
　　┗┓┓ ┏━┳┓ ┏┛
　　　┃┫┫　┃┫┫
　　　┗┻┛　┗┻┛
神兽镇楼，代码永无bug
]]

local DuoRenFuBenLayer = class("DuoRenFuBenLayer",function( )
	return XTHD.createBasePageLayer()
end)

function DuoRenFuBenLayer:ctor( parent)
	self._parent = parent
	self._copyList = nil 
	self._copyViewSize = cc.size(0,0)    
    self._challengeTimes = nil

    self._localData = {} -----
    local data = gameData.getDataFromCSV("TeamCopyList")
    for k,v in pairs(data) do 
        if self._localData[v.fbtype] then 
            table.insert(self._localData[v.fbtype],v)
        else 
            self._localData[v.fbtype] = {v}            
        end 
    end 
    table.sort(DuoRenFuBenDatas.copyListData.list,function(a,b)
        if a.openState == b.openState then 
            return a.ectypeType < b.ectypeType
        else 
            return a.openState > b.openState
        end 
    end)
    XTHD.addEventListener({name = CUSTOM_EVENT.ASYNCSERVER_AFTERBATTLE,callback = function( event ) ----当战斗完了之后刷新多人副本主界面数据
        self:asyncServerData()
    end})
end

function DuoRenFuBenLayer:create(parent)
    XTHDHttp:requestAsyncInGameWithParams({
        modules = "moreEctypeTypeList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                -- print("向服务器请求的多人副本的数据为：")
                -- print_r(data)
                DuoRenFuBenDatas.tili = data.tili
                DuoRenFuBenDatas.copyListData = data
                local layer = DuoRenFuBenLayer.new(parent)
                if layer then 
                    layer:init()
                end 
                LayerManager.addLayout(layer)
            else
                XTHDTOAST(data.msg)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = parent,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function DuoRenFuBenLayer:init( )
    local size=self:getContentSize()
    ------
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,(0xff / 2)),size.width,size.height)
    self:addChild(layer)
    -----挑战次数
    local data = DuoRenFuBenDatas.copyListData.list[1]
    -- dump(DuoRenFuBenDatas.copyListData.list)
    local curData = data.curCount[1]
    -- cur = curData.maxCount - curData.curCount
    -- local _chlgTime = XTHDLabel:createWithSystemFont(LANGUAGE_TIPS_CHALLENGETIMES(cur, curData.maxCount),XTHD.SystemFont,20) ----挑战次数
    -- self:addChild(_chlgTime)
    -- _chlgTime:enableShadow(cc.c4b(0xff,0xff,0xff,0xff),cc.size(0.5,-0.5))
    -- _chlgTime:setAnchorPoint(0,0.5)
    -- _chlgTime:setPosition(30,self:getContentSize().height - 65)
    -- self._challengeTimes = _chlgTime

	self._copyViewSize = cc.size(size.width - 40,size.height - 60)
	local function cellSizeForTable(table,idx)
        return 350,self._copyViewSize.height
    end

    local function numberOfCellsInTableView(table)
    	return 6
    end

    local function scrollViewDidScroll(view)
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
        end
        local node = self:loadCopys(idx + 1)
        node:setAnchorPoint(0,0.5)
        node:setPosition(0,self._copyViewSize.height/2)
        cell:addChild(node)
        return cell
    end

    self._copyList = CCTableView:create(self._copyViewSize)
    self._copyList:setAnchorPoint(0,0)
    self._copyList:setPosition(20,0)    
    self._copyList:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) --设置横向纵向
    self._copyList:setDelegate()
    self:addChild(self._copyList,0)

    self._copyList:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._copyList:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._copyList:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._copyList:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._copyList:reloadData()
end

function DuoRenFuBenLayer:onEnter( )
    self:addGuide()
end

function DuoRenFuBenLayer:onExit( )	
end

function DuoRenFuBenLayer:onCleanup( )
    XTHD.removeEventListener(CUSTOM_EVENT.ASYNCSERVER_AFTERBATTLE)      
    DuoRenFuBenDatas:reset() 
    self:collectMemery()
end

function DuoRenFuBenLayer:loadCopys(idx)
    local data = DuoRenFuBenDatas.copyListData.list[idx]
    if not data then 
        return 
    end 
    local layout = XTHD.createPushButtonWithSound({
        needSwallow = false,
        needEnableWhenMoving = true,
    },3)
    ------背景
    local bg = ccui.Scale9Sprite:create("res/image/multiCopy/copy_head_bg"..(data.ectypeType)..".png")
    bg:setContentSize(332,485)
    layout:setContentSize(bg:getContentSize())
    layout:setTouchSize(bg:getContentSize())
    layout:setTouchEndedCallback(function()
        self:doClickCopy(data.ectypeType,data)
    end)
    layout:addChild(bg)
    bg:setPosition(layout:getContentSize().width / 2,layout:getContentSize().height / 2)
    XTHD.setGray(bg,data.openState == 0)
    -----名字
    local _name = cc.Sprite:create("res/image/multiCopy/copy_name"..(data.ectypeType)..".png")
    bg:addChild(_name)
    _name:setAnchorPoint(0,0)
    _name:setPosition(70,bg:getContentSize().height - 35)
    XTHD.setGray(_name,data.openState == 0)
    -----人像
    local _portrait = ccui.Scale9Sprite:create("res/image/multiCopy/copy_head"..(data.ectypeType)..".png")
    _portrait:setScale(0.8)
    bg:addChild(_portrait)
    --先这么设置位置
    _portrait:setAnchorPoint(0.5,0.5)        
    _portrait:setPosition(bg:getContentSize().width/2,bg:getContentSize().height / 2 - 25)
    -- if data.ectypeType == 4 or data.ectypeType == 5 or data.ectypeType == 6 then  ------是熊猫、金刚狼和豹
    --     _portrait:setAnchorPoint(1,0.5)        
    --     _portrait:setPosition(bg:getContentSize().width,bg:getContentSize().height / 2 - 25)
    -- else 
    --     _portrait:setAnchorPoint(0,0.5)        
    --     _portrait:setPosition(0,bg:getContentSize().height / 2 - 25)
    -- end 
    XTHD.setGray(_portrait,data.openState == 0)
    ------副本奖励
    local _bg = cc.Sprite:create("res/image/multiCopy/copy_unkown_bg1.png")
    bg:addChild(_bg)
    _bg:setPosition(bg:getContentSize().width / 2,bg:getContentSize().height * 1/4)
    _bg:setScale(0.8)
    XTHD.setGray(_bg,data.openState == 0)
    -----字
    local _word = XTHDLabel:create(LANGUAGE_KEY_COPYREWARD,22,"res/fonts/def.ttf")
    _word:enableOutline(cc.c4b(55,54,112,255),2)
    _bg:addChild(_word)
    _word:setPosition(_bg:getContentSize().width / 2,_bg:getContentSize().height / 2)
    ----掉落的物品
    local rewardData = self._localData[data.ectypeType][1].dropToSee
    rewardData = string.split(rewardData,"#")
    local x = bg:getContentSize().width * 1/(#rewardData + 1) 
    for k,v in pairs(rewardData) do 
        local _item = ItemNode:createWithParams({
            _type_ = 4, 
            itemId = v,
            isShowCount = false,
            needSwallow = true,
            isGrey = data.openState == 0,
        })
        _item:setScale(0.6)
        bg:addChild(_item)        
        _item:setPosition(x,_item:getBoundingBox().height / 2 + 30)
		if #rewardData == 2 then
			x = x + _item:getBoundingBox().width*2
		else
        x = x + _item:getBoundingBox().width + 10
		end   
    end 
    return layout
end

function DuoRenFuBenLayer:doClickCopy(copyID,data)
    if data.openState == 0 then -----未开启
        str = string.format(LANGUAGE_TIPS_WORDS270,self:getCopyOpenStatus(data.ectypeType,false))
        XTHDTOAST(str)
    elseif data.openState == 1 then ------开启  
        XTHDHttp:requestAsyncInGameWithParams({
            modules = "moreEctypeGroupList?",
            params = {ectypeType = copyID},
            successCallback = function(data)
                if tonumber(data.result) == 0 then
                    DuoRenFuBenDatas.tili = data.tili
                    DuoRenFuBenDatas.teamListData = data
                    local _layer = requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenTEListLayer.lua"):create({index = copyID,parent = self,data = self._localData[copyID]})
                    LayerManager.addLayout(_layer)
                else
                    XTHDTOAST(data.msg)
                end
            end,
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            end,--失败回调
            loadingParent = self,
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end 
end
-----获取当前副本的开启时间
function DuoRenFuBenLayer:getCopyOpenStatus(copyType,isOpen)
    local str = ""
    if self._localData then 
        local data = self._localData[copyType][1]
        if data then 
            local _time = string.split(data.opentime2,"-")
            if isOpen then ----开启
                str = _time[2]
            else -----i没有开启,返回星期几
                --多人副本每天开启两个，每个副本会轮两次，所以要判断是否是轮第二次，如果当前是星期四，则是第二轮
                if tonumber(os.date("%w",os.time())) > 3 then
                    str = LANGUAGE_TABLE_WORDDATA[tonumber(data.opentime) + 3].._time[1]
                else
                    str = LANGUAGE_TABLE_WORDDATA[tonumber(data.opentime)].._time[1]
                end
                
            end 
        end 
    end 
    return str
end
------同步服务器数据 
function DuoRenFuBenLayer:asyncServerData()
    XTHDHttp:requestAsyncInGameWithParams({
        modules = "moreEctypeTypeList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                -- print("同步服务器多人副本数据：")
                -- print_r(data)
                DuoRenFuBenDatas.tili = data.tili
                if data.list then 
                    table.sort(data.list,function(a,b)
                        if a.openState == b.openState then 
                            return a.ectypeType < b.ectypeType
                        else 
                            return a.openState > b.openState
                        end 
                    end)
                end 
                DuoRenFuBenDatas.copyListData = data
                -- if self._challengeTimes then 
                --     local data = DuoRenFuBenDatas.copyListData.list[1]
                --     cur = data.maxCount - data.curCount
                --     self._challengeTimes:setString(LANGUAGE_TIPS_CHALLENGETIMES(cur,data.maxCount))
                -- end 
            else
                XTHDTOAST(data.msg)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingParent = self,        
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function DuoRenFuBenLayer:collectMemery( )
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/multiCopy/copy_unkown_bg1.png")
    for i = 1,7 do 
        textureCache:removeTextureForKey("res/image/multiCopy/copy_head_bg"..i..".png")
        textureCache:removeTextureForKey("res/image/multiCopy/copy_head"..i..".png")
        textureCache:removeTextureForKey("res/image/multiCopy/copy_name"..i..".png")
    end 
end

function DuoRenFuBenLayer:addGuide( )
    -----------引导
    YinDaoMarg:getInstance():addGuide({index = 4,parent = self},12) 
    YinDaoMarg:getInstance():doNextGuide()
end

return DuoRenFuBenLayer