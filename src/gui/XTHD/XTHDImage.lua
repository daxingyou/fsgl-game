XTHDImage = class("XTHDImage", function(params)
    local obj = cc.Sprite:create()
    if type(params) == "string" and cc.Sprite:create(params) then
        obj = cc.Sprite:create(params)
    end
    return XTHDTouchExtend.extend(obj)
end )
function XTHDImage:ctor(fileName)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(self._needSwallow)
    listener:registerScriptHandler( function(touch, event)
        local isVisible = self:isAllParentsVisible(self)
        local isContain = self:isContainTouch(self, touch)
        if isVisible and isContain and self:isClickable() then
            if self:getTouchBeganCallback() then
                self:getTouchBeganCallback()()
            end
            return true
        end
        return false
    end , cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler( function(touch, event)
    end , cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler( function(touch, event)
        local isVisible = self:isAllParentsVisible(self)
        local isContain = self:isContainTouch(self, touch)
        if isVisible and isContain and self:isClickable() and self:getTouchEndedCallback() then
            self:getTouchEndedCallback()()
        end
    end , cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    self._listener = listener
end
function XTHDImage:create(fileName)
    return XTHDImage.new(fileName)
end
function XTHDImage:createWithFileOrUrlDirectory(fileName, imageUrlDirectory)
    local image = XTHDImage:create()
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local textureCache = cc.Director:getInstance():getTextureCache()
    local texture = textureCache:addImage(fileName)
    local savePath = writablePath .. fileName
    local function reset(texture)
        image:setTexture(texture)
        local rect = cc.rect(0, 0, texture:getContentSize().width, texture:getContentSize().height)
        image:setTextureRect(rect)
    end
    if not texture then
        print("load image[" .. fileName .. "]failed , search in [" .. savePath .. "]")
        if string.sub(fileName, 1, 1) ~= "/" and textureCache:addImage(savePath) then
            texture = textureCache:addImage(savePath)
        end
        if not texture and imageUrlDirectory then
            local imgUrl = imageUrlDirectory .. "/" .. fileName
            print("imgUrl>>>>>>>>" .. imgUrl)
            print("load image[" .. savePath .. "]failed , downloading...")
            LMHttp:requestImgWithAsync(imgUrl, function(response, obj)
                local suceess = response:saveDataToFile(savePath)
                if suceess and textureCache:addImage(savePath) then
                    texture = textureCache:addImage(savePath)
                    reset(texture)
                else
                end
            end )
        elseif texture then
            reset(texture)
        end
    else
        reset(texture)
    end
    return image
end
function XTHDImage:createWithFileInGame(fileName, imageUrlDirectory)
    if imageUrlDirectory == nil or imageUrlDirectory == "" then
        imageUrlDirectory = "http://image.wssg.zhanchenggame.com"
    end
    return self:createWithFileOrUrlDirectory(fileName, imageUrlDirectory)
end
