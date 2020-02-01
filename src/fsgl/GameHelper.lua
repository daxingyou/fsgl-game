helper = {}

helper.getAllLuaFileInMem = function()
    local allLuaInMem = {};
    local _global = package.loaded;
    for key, value in pairs(_global) do
        local pos = string.find(tostring(key), ".lua");
        if pos ~= nil and ((type(value) == "boolean" and value == true) or type(value) == "table") then
            allLuaInMem[#allLuaInMem+1] = key;
        end
    end
    return allLuaInMem;
end

helper.reloadAllFile = function()
    local _global = package.loaded
    for key, value in pairs(_global) do
        local pos = string.find(tostring(key), ".lua");
        if pos ~= nil then
            package.loaded[key] = nil;   --赋值为nil的目的是为了重新加载.lua文件，值为true是标记已经加载过了
        end
    end
    XTHD.dispatchEvent({name = "REMOVE_UNUSED_SPINE_DATA"})
    cc.SpriteFrameCache:getInstance():removeSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeAllTextures()
end

local function _releaseMemory( ... )
    XTHD.dispatchEvent({name = "REMOVE_UNUSED_SPINES"})
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local textureCache = cc.Director:getInstance():getTextureCache()
    spriteFrameCache:removeUnusedSpriteFrames()
    textureCache:removeUnusedTextures()
    collectgarbage("collect")
    print("*************清理纹理*************")
    -- textureCache:removeAllTextures()
    -- print(string.format("collect time:"..(os.clock() - start)))
    -- ueserMem = textureCache:getUseMemNum()
    -- string = string.format("wm____removeUnusedTextures after : ".. ueserMem)
    -- print(string)
end


-- 主动释放不用的spriteframe和texture  addby wangming 20150813 
-- tip : 请谨慎使用, 小心刚加载，还没被引用就被释放掉得情况出现
helper.collectMemory = function( isForcible, _sNum )
    local memoryTop = tonumber(_sNum) or 70 
    -- 纯纹理内存控制的最大值，大约为实际内存占用量的一半左右，到达则做释放无用纹理处理，可根据做成变量，不同环境具体调整参数

    local textureCache = cc.Director:getInstance():getTextureCache()
    if isForcible then
        _releaseMemory()
    elseif textureCache.getUseMemNum then
        local ueserMem = textureCache:getUseMemNum()
        print("wm----check to collectMemory : " .. tostring(ueserMem))
        if ueserMem >= memoryTop then
           _releaseMemory()
        end
    end
end
