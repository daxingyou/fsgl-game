XTHD = XTHD or { }
XTHD.resource = XTHD.resource or { }

function XTHD.resource.getWritablePath(params)
    return cc.FileUtils:getInstance():getWritablePath() .. ".fsgl/"
end

function requires(filename)
    print("path=" .. filename)
    local loaded = package.loaded;
    if loaded[filename] then
        loaded[filename] = nil
    end
    return require(filename)
end

-- function requires(filename)
--     local path
--     local fileUtils = cc.FileUtils:getInstance()
--     local writablePath = XTHD.resource.getWritablePath()
--     if fileUtils:isAbsolutePath(filename) then
--         path = filename
--     else
--         local tmp = writablePath .. filename
--         if fileUtils:isFileExist(tmp .. ".luac") then
--             path = tmp .. ".luac"
--         elseif fileUtils:isFileExist(tmp .. ".lua") then
--             path = tmp .. ".lua"
--         elseif fileUtils:isFileExist(tmp .. "c") then
--             path = tmp .. "c"
--         elseif fileUtils:isFileExist(tmp) then
--             path = tmp
--         else
--             path = filename
--         end
--     end
--     print("path=" .. path)
--     local loaded = package.loaded;
--     if loaded[path] then
--         loaded[path] = nil
--     end

--     return require(path)
-- end
