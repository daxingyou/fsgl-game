
local GameLoadingLayer = class("GameLoadingLayer", function(params)
    local label = cc.Layer:create()
    return label
end)

--[[**************************异步更新 声明 **************************

        异步更新在GameLoadingLayer界面中实现由于异步更新导致
        GameLoadingLayer或者游戏出现问题了，请联系何智陶，谢谢!  

        ！！！注意：异步更新中，可以清除游戏的缓存数据，如果是MAC
        模拟机，缓存数据存放在Documents目录下，如果清除缓存的话清
        除的数据为Documents目录中的 所有 内容，在清除缓存之前请确
        保Documents目录下文件的备份。如果是IOS模拟机，缓存数据存放
        在沙盒中，清除缓存是清除沙盒中的内容。
    **************************异步更新 声明 **************************]]

local BG_TAY = 1000
requires("src/fsgl/GameUpdater.lua")

function GameLoadingLayer:create(params)
    return GameLoadingLayer.new(params)
end

function GameLoadingLayer:ctor( sParams )

    helper.collectMemory(true)
    local params = sParams == nil and {} or sParams

    local width = cc.Director:getInstance():getWinSize().width
    local height = cc.Director:getInstance():getWinSize().height
    
    local login_bg = requires("src/fsgl/layer/DengLuBeiJing/SwitchSceneBgLayer1.lua"):create()
    self:addChild(login_bg)

    local switchLayer = requires("src/fsgl/layer/DengLuBeiJing/SwitchSceneLayer1.lua"):create({showLogo = true})
    
    self:addChild(switchLayer)

    self._switchLayer = switchLayer
    
    self._progressTitle = switchLayer:getText()
    self._loadingProgress = switchLayer:getLoadingBar()

    if params.checkDatas then
        if ISFIRSTUPDATE then
            self:isFirstUpdate(params.checkDatas)
        else
            self:showAnnouncement(params.checkDatas)
        end   
        print("GameLoadingLayer:ctor   ----- showAnnouncement")
    else
        if getFlagUpdate() == true then
            self:checkUpdate()
        else
            self:switchScene()
        end
    end
    --hezhitao end
end

function GameLoadingLayer:switchScene( flag )
    -- self:initSDK()
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1) , cc.CallFunc:create(function()
        self._switchLayer:setText(LANGUAGE_OTHER_TXTLOADING.."...")
    end) , cc.Sequence:create(cc.DelayTime:create(2) , cc.CallFunc:create(function()
        -- print("********CTX_log:游戏初始化，如果有热更新，则进行热更新，没有则进入登陆界面*********")
        XTHD.replaceToLoginScene()
    end) )))
end

--检查版本更新  hezhitao
function GameLoadingLayer:checkUpdate()
    --解析本地Manifest文件
    local params = {
        par = self, 
        loadingType = HTTP_LOADING_TYPE.NONE,
        succCall = function( data )
            if ISFIRSTUPDATE then
                self:isFirstUpdate(data)
            else
                self:showAnnouncement(data)
            end  
            print("GameLoadingLayer:checkUpdate   ----- showAnnouncement")
        end, 
        failCall = function()
            self:switchScene()
        end
    }
    local manifest = checkUpdate(params)
    if manifest == nil then
        return
    end
    --当前版本号
    local __bg = XTHD.createSprite()
    __bg:setContentSize(XTHD.resource.visibleSize)
    __bg:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
    self:addChild(__bg)

    local version_str = manifest["version"] .. "." .. manifest["svn"]
    gameUser.setVersion(version_str)
    local versionId = XTHDLabel:createWithParams({
        text = gameUser.getVersion(),
        fontSize = 20,
        color = cc.c3b(255, 255, 255),
    })
    versionId:setAnchorPoint(cc.p(0, 0))
    versionId:setPosition(cc.p(20, self:getContentSize().height - 50))
    self:addChild(versionId, 3)
end

-- function GameLoadingLayer:checkUpdate()
--     --解析本地Manifest文件
--     local manifest = self:parseManifest()
    
--     if manifest == nil then
--         return
--     end

--     --当前版本号
--     local __bg = XTHD.createSprite()
--     __bg:setContentSize(XTHD.resource.visibleSize)
--     __bg:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
--     self:addChild(__bg)

--     local version_str = manifest["version"] .. "." .. manifest["svn"]
--     gameUser.setVersion(version_str)
--     local versionId = XTHDLabel:createWithParams({
--         text = gameUser.getVersion(),
--         fontSize = 24,
--         color = cc.c3b(255, 255, 255),
--     })
--     versionId:setAnchorPoint(cc.p(0, 0))
--     versionId:setPosition(cc.p(20, 10))
--     self:addChild(versionId, 3)


--     --测试异步更新使用预留字段
--     -- local permission = ""
--     -- if manifest["permission"] ~= nil and string.len(manifest["permission"]) ~= 0 then
--     --     permission = "&permission=" .. manifest["permission"]    --manifest["permission"] = “zctech_test”为开发者测试使用
--     -- end

--     local testing = ""

--     if manifest["testing"] ~= nil then
--         testing = "&testing=" .. manifest["testing"]
--     end

--     -- local GAME_UPDATE_CHANNEL = "appstore"
--     -- 请求最新的版本信息
--     local lastVersionParams = {

--         url = manifest["lastVersionUrl"] .. "&bundle=" .. manifest["bundle"] .. "&version=" .. manifest["version"] .. "&update_channel=" .. manifest["update_channel"] .. testing,

--         successCallback = function(data)
--             if data ~= nil then
--                 if tonumber(data.status) == 1 then
--                     self:showAnnouncement(data)
--                 elseif tonumber(data.status) == 5 then   --5表示强制更新
--                     self:showAnnouncement(data)
--                 else
--                     self:switchScene()
--                 end
--             end 
--         end,
--         failedCallback = function()
--             self:switchScene()
--         end,
--         targetNeedsToRetain = self,
--         loadingType = HTTP_LOADING_TYPE.NONE,
--     }

--     XTHDHttp:requestAsyncWithParams(lastVersionParams)
-- end

--读取Manifest中的信息
function GameLoadingLayer:parseManifest()
    local file = nil
    local table = nil
    if cc.FileUtils:getInstance():isFileExist(XTHD.resource.getWritablePath() .. "project.manifest") then
        file = cc.FileUtils:getInstance():getStringFromFile(XTHD.resource.getWritablePath() .. "project.manifest")
    else
        file = cc.FileUtils:getInstance():getStringFromFile("src/project.manifest")
    end

    if file ~= nil then
        table = json.decode(file)
    end
    return table
end

--显示最新版本信息提示页面
function GameLoadingLayer:showAnnouncement(data)
    if self._switchLayer then
        self._switchLayer:setVisible(false)
    end
    --创建提示层Layout
    local noticeLayout = cc.LayerColor:create(cc.c4b(0,0,0,150))
    noticeLayout:setTouchEnabled(true)
    noticeLayout:setAnchorPoint(cc.p(0, 0))
    noticeLayout:setPosition(cc.p(0, 0))
    noticeLayout:registerScriptTouchHandler(function ( eventType, x, y )
        if (eventType == "began") then
            return true
        end
    end)
    self:addChild(noticeLayout, BG_TAY)

    --增加提示背景框
    local bg = cc.Sprite:create("res/image/common/hotTip.png")
    bg:setPosition(cc.p(noticeLayout:getContentSize().width*0.5 , noticeLayout:getContentSize().height*0.5))
    noticeLayout:addChild(bg)

    --local notic_title = cc.Sprite:create("res/image/common/noticeTitle1.png")
    --notic_title:setAnchorPoint(cc.p(0.5, 0))
    --notic_title:setPosition(bg:getContentSize().width*0.5,bg:getContentSize().height - 45)
    --bg:addChild(notic_title, 2)

    local bgWidth = bg:getContentSize().width
    local bgHeight = bg:getContentSize().height
    
    --增加滚动控件
    local wm_test = true -- 添加scrollview与WebView方式的切换， addBy wangming 20150812
    if wm_test then
        -- local view = ccexp.WebView:create()
        local _size = cc.size(bgWidth - 20 * 2,bgHeight - 120)
        -- view:setContentSize(_size)
        -- view:setPosition(cc.p(_size.width*0.5 + 50,  _size.height*0.5 + 80))
        -- view:setScalesPageToFit(true)
        -- view:loadURL("http://www.zol.com.cn")--直接加载地址显示

        -- html代码加载
        -- 添加项目对web view中直接加载loadHTMLString的支持，修改了GameLoadingLayer中得调用实例，替换了部分3.7版本代码进项目。
        -- 具体修改了包括cocos2dx底层c++代码 3个文件，libcocos2dx中得java代码 2个文件。
        -- 需要生效请重新编译，打底包，否则ios版本不能生效，安卓版本可能报错卡死（jni会error找不到方法）。
        
        local patchSize = ""
        --处理更新大小
        if data.patchsize ~= nil and data.patchsize > 0 then
            patchSize = LANGUAGE_OTHER_TXTPACKAGESIZE
            if data.patchsize > (1024 * 1024) then
                patchSize = patchSize .. string.format("%.1f", data.patchsize / (1024 * 1024)) .. " MB"
            else
                patchSize = patchSize .. string.format("%.1f", data.patchsize / 1024) .. " KB"
            end
        end

        -- local string = "<body style=\"font-size:50px\">Hello World" 
        --             .. "<img src=\"http://newpub.hanjiangsanguo.com/hj3.2/static/img/pop/tradepop_th.png\"/>"--网络图片资源
        --             .. "<img src=\"res/image/avatar/avatar_000.jpg\"/> </body>" -- 本地图片资源
        -- local _head = "<head><metahttp-equiv = \"charset=utf-8\"></head>"
        -- local string = "<body \"background-color\"=transparent>"..data.announcement.. "<br/><br/><font color=\"#25810F\">" .. patchSize.."</font></body>"
        -- local baseurl = "" -- 本地地址路径，可以不填写
        -- view:loadHTMLString(string, baseurl)--加载页面
        -- bg:addChild(view)
        -- self._webview = view
        self.tipText = XTHD.createLabel({
            text = data.announcement..patchSize,
            fontSize = 20,
            color = cc.c3b(255, 140, 0),
        })
        bg:addChild(self.tipText)
        self.tipText:setPosition(cc.p(_size.width*0.5 - 50,  _size.height*0.5 + 80))
    else
        local _bgSize = bg:getContentSize()
        local _size = cc.size(bgWidth - 20 * 2,bgHeight - 30)
        local scrollView = ccui.ScrollView:create()
		scrollView:setScrollBarEnabled(false)
        scrollView:setAnchorPoint(0.5, 1)
        scrollView:setTouchEnabled(true)
        scrollView:setBounceEnabled(true)
        scrollView:setContentSize(_size)
        scrollView:setPosition(cc.p(_bgSize.width*0.5, _bgSize.height - 30))
        scrollView:setName("scrollView")

        bg:addChild(scrollView)
        local patchSize = ""
        --处理更新大小
        if data.patchsize ~= nil and data.patchsize > 0 then
            patchSize = LANGUAGE_OTHER_TXTPACKAGESIZE
            if data.patchsize > (1024 * 1024) then
                patchSize = patchSize .. string.format("%.1f", data.patchsize / (1024 * 1024)) .. " MB"
            else
                patchSize = patchSize .. string.format("%.1f", data.patchsize / 1024) .. " KB"
            end
        end

        --提示文字
        local announcement = XTHDLabel:createWithParams({
            text = "\n" .. data.announcement .. "\n\n" .. patchSize,
            fontSize = 20,
            color = cc.c3b(255, 140, 0),
            anchor = cc.p(0, 1)
        })
        announcement:setAnchorPoint(0, 1)
        announcement:setDimensions(_size.width - 20, 0)
        scrollView:addChild(announcement)
        local textHeight = announcement:getBoundingBox().height
        announcement:setDimensions(_size.width - 20, textHeight)

        local innerSize = cc.size(_size.width, _size.height + 10)
        if textHeight < _size.height then--文本高度小于背景高度
            scrollView:setInnerContainerSize(innerSize)
        else--文本高度大于背景高度
            innerSize.height = textHeight + 10
            scrollView:setInnerContainerSize(innerSize)
        end
        announcement:setPosition(10, innerSize.height)
    end

    local btnTitle = ""

    if tonumber(data.status) == 5 then   --status == 1 可以更新 ；status == 3已经是最新版本；status == 5强制更新
        btnTitle = LANGUAGE_BTN_KEY.qianwangxiazai
    else
        btnTitle = LANGUAGE_BTN_KEY.querengengxin
    end

    local url_tab = nil
    local url = ""
    --[[
        注意：在管理平台上如果需要输入强制更新的链接，首先需要输入Android的链接，接着输入IOS的链接，两个链接之间用“;”分开，“;”用英文的
        输入格式为：  http://pre.im/gfcqios;http://pre.im/gfcqand
    ]]
    if data["addr"] ~= nil and string.len(data["addr"]) ~= 0 then
        url_tab = string.split(data["addr"],";")
    
        if (cc.PLATFORM_OS_ANDROID == ZC_targetPlatform) then
            url = url_tab[1]
        elseif (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) or (cc.PLATFORM_OS_MAC == ZC_targetPlatform)  then
            -- url = "http://pre.im/gfcqios"
            url = url_tab[2]
        end
    end

    local confirmButton = XTHD.createCommonButton({
        btnColor = "gray",
        btnSize = cc.size(205,46),
        isScrollView = false,
        fontSize = 20,
        text = btnTitle,
        pos = cc.p(bgWidth*0.5, 47),
        endCallback = function()
            if tonumber(data.status) == 1 then
                if (self._webview) then
                    self._webview:removeFromParent()
                    self._webview = nil
                end
                noticeLayout:setVisible(false)
                self:updateLua()
            elseif tonumber(data.status) == 5 then
                if url ~= "" and string.len(url) ~= 0 then
                    cc.Application:getInstance():openURL(url)
                    --用户一旦选择强制更新，则删除本地缓存数据
                    cc.FileUtils:getInstance():removeDirectory(XTHD.resource.getWritablePath())
                end
            end
        end
    })
    bg:addChild(confirmButton, 3)

end

function GameLoadingLayer:isFirstUpdate(data)
    if tonumber(data.status) == 1 then
        self:updateLua()
    elseif tonumber(data.status) == 5 then
        if url ~= "" and string.len(url) ~= 0 then
            cc.Application:getInstance():openURL(url)
            --用户一旦选择强制更新，则删除本地缓存数据
            cc.FileUtils:getInstance():removeDirectory(XTHD.resource.getWritablePath())
        end
    end
end

function GameLoadingLayer:updateLua()
    if self._switchLayer then
        self._switchLayer:setVisible(true)
    end
    local am = cc.AssetsManagerEx:create("src/project.manifest", XTHD.resource.getWritablePath())
    am:setMaxConcurrentTask(4)
    am:retain()

    local loadingProgressInAction = false

    if not am:getLocalManifest():isLoaded() then
        cc.Director:getInstance():getEventDispatcher():removeAllEventListeners()
        self:switchScene()
    else
        local function onUpdateEvent(event)
            local eventCode = event:getEventCode()

            if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
                self._progressTitle:setString(LANGUAGE_TIPS_LOCALERROR)
                cc.Director:getInstance():getEventDispatcher():removeAllEventListeners()
                self:switchScene()
            elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
                local assetId = event:getAssetId()
                local percent = event:getPercentByFile()-- event:getPercent()
                
                local strInfo = ""
                if assetId == cc.AssetsManagerExStatic.VERSION_ID or assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
                    strInfo = "正在解析资源..., 不消耗流量!"
                    self._progressTitle:setString(strInfo)
                end
                if assetId ~= cc.AssetsManagerExStatic.VERSION_ID and assetId ~= cc.AssetsManagerExStatic.MANIFEST_ID then
                    strInfo = string.format(LANGUAGE_TIPS_PROGRESS..": %d%%", percent)
                    if loadingProgressInAction == false then
                        cc.Director:getInstance():getActionManager():removeAllActionsFromTarget(self._loadingProgress)
                        loadingProgressInAction = true
                    end
                    self._loadingProgress:setPercentage(tonumber(percent))
                    if percent > 99 then
                        cc.Director:getInstance():getActionManager():removeAllActionsFromTarget(self._loadingProgress)
                        self._loadingProgress:setPercentage(100)
                        strInfo = LANGUAGE_TIPS_UNPACKING.."..."
                    end
                end
                self._progressTitle:setString(strInfo)
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or
                eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
                local errorInfo = ""
                if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST then
                    errorInfo = LANGUAGE_TIPS_DOWNLOADERRO
                else
                    errorInfo = LANGUAGE_TIPS_GETTINGERROR
                end
                self._progressTitle:setString(errorInfo)
                cc.Director:getInstance():getEventDispatcher():removeAllEventListeners()
                self:switchScene()
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE or
                eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
                self._progressTitle:setString(LANGUAGE_TIPS_UPDATEOK)
                self._loadingProgress:setPercentage(100)
                am:release()
                cc.Director:getInstance():getEventDispatcher():removeAllEventListeners()
                gameUser = nil
                --重新加载lua文件，不执行此步骤，则不能正确加载已经更新的内容
                helper.reloadAllFile()
                requires("src/main.lua")
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
                print("热更ERROR_UPDATING  asset:"..event:getAssetId()..",   msg:"..event:getMessage())
                -- self:switchScene()
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then
                self._progressTitle:setString(LANGUAGE_TIPS_UPDATEERROR)
                -- XTHDTOAST("由于网络问题导致本次更新失败，需要重新下载！")
                cc.Director:getInstance():getEventDispatcher():removeAllEventListeners()
                if self:getChildByName("hotDialog") then --cc.Director:getInstance():getNotificationNode():getChildByName("hotDialog")
                    self:getChildByName("hotDialog"):removeFromParent()
                end
                self:tipsDialog()
            end
        end

        local listener = cc.EventListenerAssetsManagerEx:create(am,onUpdateEvent)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
        am:update()
    end
end

function GameLoadingLayer:tipsDialog()
    local show_msg = "由于网络问题导致本次更新失败，需要重新下载！"

    local confirmDialog = XTHDConfirmDialog:createWithParams({msg = show_msg,leftVisible = false})

    local platform = cc.Application:getInstance():getTargetPlatform()

    if platform == cc.PLATFORM_OS_ANDROID then
        self:addChild(confirmDialog)
    elseif platform == cc.PLATFORM_OS_IPHONE or cc.PLATFORM_OS_IPAD or cc.PLATFORM_OS_MAC then
        self:addChild(confirmDialog)
    end
    
    confirmDialog:setName("hotDialog")

    confirmDialog:setCallbackRight(function ()
        -- cc.FileUtils:getInstance():removeDirectory(XTHD.resource.getWritablePath())
        helper.reloadAllFile()
        requires("src/main.lua")
    end)

end

--[[ cc.EventAssetsManagerEx.EventCode = {
    ERROR_NO_LOCAL_MANIFEST = 0,
    ERROR_DOWNLOAD_MANIFEST = 1,
    ERROR_PARSE_MANIFEST = 2,
    NEW_VERSION_FOUND = 3,
    ALREADY_UP_TO_DATE = 4,
    UPDATE_PROGRESSION = 5,
    ASSET_UPDATED = 6,
    ERROR_UPDATING = 7,
    UPDATE_FINISHED = 8,
    UPDATE_FAILED = 9,
    ERROR_DECOMPRESS = 10
} ]]

return GameLoadingLayer