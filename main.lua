--IS_NEI_TEST = 1
--[[
	游戏入口
]]

local WPATH = cc.FileUtils:getInstance():getWritablePath()
local GPATH = WPATH .. "/.fsgl/"
-- 将下载目录作为优先级最高的搜索目录，保证下载资源覆盖原有的
cc.FileUtils:getInstance():addSearchPath(GPATH, true)
-- 代码中存在相对路径和绝对路径加载，故需添加相对路径的资源搜索目录
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

require "src/requires.lua"
requires("src/init.lua")

function errorReport(msg)
    local id = -1;
    if gameUser and gameUser.getUserId then
        id = gameUser.getUserId()
    end
    local data = { uid = id, msg = msg };
    local url = XTHD.config.server.url_uc .. "errorMsg?"
    XTHDHttp:sendErrorMsg(url, data, function(args)
        print("Error Report Success!");
    end );
end

-- cclog
cclog = function(...)
    print(string.format("%s", ...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("-------------------Lua错误日志Begin---------------------")
    local str = tostring(msg)
    cclog("LUA ERROR: " .. str .. "\n")

    ----提示错误的日志
    if IS_NEI_TEST then
--        local tempLayer = requires("src/fsgl/layer/common/ShowBugNode.lua")
--        if cc.Director:getInstance():getRunningScene() then
--            cc.Director:getInstance():getRunningScene():addChild(tempLayer:create(msg), 1000)
--        end
    end

    cclog(debug.traceback())
    cclog("--------------------Lua错误日志End--------------------")
    errorReport(str .. "\n" .. debug.traceback());
    return msg
end

local function main()

    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    -- initialize director
    local director = cc.Director:getInstance()

    -- turn on display FPS
    director:setDisplayStats(false)
    -- director:setDisplayStats(false)

    -- set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)
    -- 适配方案改在lua里面实现，方便以后上线之后的修改  yanyuling begin
    if screenRadio <= 1.5 then
        director:getOpenGLView():setDesignResolutionSize(1024, 615, cc.ResolutionPolicy.FIXED_WIDTH)
    else
        director:getOpenGLView():setDesignResolutionSize(1024, 615, cc.ResolutionPolicy.FIXED_HEIGHT)
    end
    -- cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_AUTO)


    winSize = pDirector:getWinSize();
    -- 重新设置p
    winWidth = winSize.width;
    winHeight = winSize.height;
    -- plist中存放按钮上的文字
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/fonts/common_btnText.plist", "res/fonts/common_btnText.png")

    XTHD.getGameInfoFromSdk()

    local node = cc.Node:create()
    cc.Director:getInstance():setNotificationNode(node)
    node:setPosition(0, 0)

       -- requires("src/battle/test.lua")
       -- battle_test()

    local UpdateLayer = requires("src/fsgl/GameLoadingLayer.lua")
    local scene = cc.Scene:create()
    scene:addChild(UpdateLayer:create())
    cc.Director:getInstance():replaceScene(scene)
	frameSize=scene:getContentSize()
end

function doReconnect()
    print("the test for socket reconnect")
    MsgCenter:doReconnect()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
