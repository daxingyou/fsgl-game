
XTHDTouchSpine = class("XTHDTouchSpine", function(id,jsonfile,atlasfile,_scale_, sSpine)
    local _spine = sSpine
    if not _spine then
		local res = string.find(jsonfile,".skel")
		if res and res > 0 then
			_spine =  sp.SkeletonAnimation:createWithBinaryFile(jsonfile, atlasfile, _scale_)
		else
			_spine =  sp.SkeletonAnimation:create(jsonfile,atlasfile,_scale_)
		end
    end
    dump(_spine)
	return  XTHDTouchExtend.extend(_spine) 
end)

function XTHDTouchSpine:onExit()
end

function XTHDTouchSpine:ctor(id,jsonfile,atlasfile,_scale_)
	self._Execute = true
    self.isMove = false
    self.isNeedMoveFunc = false
    self.isShowDes = false
    self.heroid = id
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(self._needSwallow)

    --少年英雄人物形象缩小
    local heroData = gameData.getDataFromCSV("GeneralInfoList", { heroid = self.heroid })
    if heroData.mark == 1 then
        self:setScale(0.75)
    else
        self:setScale(1.15)
    end
    -- print(self.heroid.."英雄的数据为：")
    -- print_r(heroData)

    --加上英雄属性图片
    -- local heroData = gameData.getDataFromCSV("GeneralInfoList", { heroid = self.heroid })
    -- local type_bg = cc.Sprite:create("res/image/plugin/hero/hero_type_" .. (heroData.type or 1) .. ".png")
    -- self:addChild(type_bg)
    -- type_bg:setPosition(-50,200)

    listener:registerScriptHandler(function(touch, event)
		self._Execute = true
		self._pos = touch:getLocation()
        print("registerScriptHandler")
        local isVisible = self:isAllParentsVisible(self);
        local isContain = self:isContainTouch(self,touch);
        print("hero begin >>>>> "..tostring(isContain))
        if isVisible and isContain and self:isClickable() then
            if self:getTouchBeganCallback() then
                self:getTouchBeganCallback()()
            end
            return true
        end
        return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function(touch, event)
        self.isMove = true
		local pos = touch:getLocation()
		local x = pos.x - self._pos.x
		local y = pos.y - self._pos.y
		if self:getneedEnableWhenMoving() and math.abs(x) > 500 or math.abs(y) > 300 then
			self._Execute = false
		else
			self._Execute = true
		end
	end, cc.Handler.EVENT_TOUCH_MOVED)

    listener:registerScriptHandler(function(touch, event)
        print("XTHDTouchSpine: ")
        local isVisible = self:isAllParentsVisible(self);
        local isContain = self:isContainTouch(self,touch);
        if isVisible and self:isClickable() then  --and isContain
            if self:getTouchEndedCallback() and self._Execute then
                if self.isNeedMoveFunc then
                    if self.isMove then
                        self.isMove = false
                        self:getTouchEndedCallback()()
                    end
                else
                    self:getTouchEndedCallback()()
                end
            end
            if self.isMove == false and self.isShowDes then
                -- print("----------只触发点击事件-----------"..self.heroid)
                local layer = requires("src/fsgl/layer/common/HeroIntroduceLayer.lua"):createWithParams(self.heroid)
                cc.Director:getInstance():getRunningScene():addChild(layer)
            end
        end

    end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    --给精灵添加点击事件
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    self._listener = listener
end

function XTHDTouchSpine:setShowDes(flag)
    self.isShowDes = flag
end

function XTHDTouchSpine:setNeedMoveFunc(flag)
    self.isNeedMoveFunc = flag
end

function XTHDTouchSpine:setneedEnableWhenMoving(b)
	self._needEnableWhenMoving = b
end

function XTHDTouchSpine:getneedEnableWhenMoving()
	return self._needEnableWhenMoving
end

function XTHDTouchSpine:isContainTouch(node,touch)
    dump(touch:getLocation())
    if node == nil then return end
    local point = node:convertToNodeSpace(touch:getLocation())
	self._pos = point
    dump(point)
    point.x = point.x*node:getScaleX()
    point.y = point.y*node:getScaleY()
    local s ={width=0,height = 0} 
    s.width= node:getBox().width + 30
    s.height = node:getBox().height + 30

    local rect_ =  cc.rect(-20, 0, s.width, s.height)
    local touchSize = node._touchSize
    if (touchSize ~= nil) and touchSize.width > 0 and touchSize.height > 0 then
        rect_ =  cc.rect( (node:getBoundingBox().width - touchSize.width) / 2 
            , (node:getBoundingBox().height - touchSize.height) / 2 , touchSize.width , touchSize.height)
    end

    dump(rect_)
    return cc.rectContainsPoint( rect_, point )
end

function XTHDTouchSpine:create(id,jsonfile,atlasfile,_scale_)
	return self.new(id,jsonfile,atlasfile,_scale_)
end