--Created By Liuluyang 2015年04月14日
local TAG = "ShengJiLayer"

local ShengJiLayer = class("ShengJiLayer",function ()
    return cc.Layer:create()
end)

function ShengJiLayer:ctor(levelNew, levelCur, extraCallback)
    self._extraCallbac = extraCallback
    self:setName("ShengJiLayer")
	if levelNew > levelCur then
	 	self:initUI(levelNew, levelCur)
	end
    self._isCanClose = false
    --开始注册点击事件
    self:registerScriptHandler(function(eventName)
        if eventName == "enter" then 
            self:onEnter()
        elseif eventName == "exit" then 
            self:onExit()
        elseif eventName == "cleanup" then
            self:onCleanup()
        end 
    end)

    local function touchBegan( touch,event )
        return true
    end

    local function touchEnded(touch,event)
        if self._isCanClose then 
            self:removeFromParent()
        end
    end

    self._listener = cc.EventListenerTouchOneByOne:create()
    self._listener:setSwallowTouches(true)
    self._listener:registerScriptHandler(touchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self._listener:registerScriptHandler(touchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._listener, self)
end

function ShengJiLayer:initUI(levelNew, levelCur)
    local _color = cc.LayerColor:create(cc.c4b(0,0,0,204),self:getContentSize().width,self:getContentSize().height)
    self:addChild(_color)    

    musicManager.playEffect("res/sound/LelveUp.mp3")
	local nowLevel = levelCur
	local difLevel = levelNew - nowLevel

	if levelNew >= 10 and gameUser.getMonthState() == 0 then
		local layer = requires("src/fsgl/layer/ConstraintPoplayer/ZhizunkaDalianye.lua"):create()
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
	end
    
	local NowData = gameData.getDataFromCSV("PlayerUpperLimit",{level = nowLevel})
    
	local UpData = gameData.getDataFromCSV("PlayerUpperLimit",{level = levelNew})

    local bg_effect = sp.SkeletonAnimation:create( "res/spine/effect/level_up/shengji.json", "res/spine/effect/level_up/shengji.atlas",1.0) 
    bg_effect:setScale(0.8)
    bg_effect:setAnimation(0,"shengji",false)
    bg_effect:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
    self:addChild(bg_effect)
    bg_effect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function ()
        bg_effect:setAnimation(0,"shengji_loop",false)
    end) )))

    local bg = cc.Sprite:create()
    bg:setContentSize(cc.size(bg_effect:getContentSize().width,bg_effect:getContentSize().height))
    bg:setPosition(bg_effect:getContentSize().width / 2,bg_effect:getContentSize().height / 2)
    bg_effect:addChild(bg)

    local function createInfo()
        local nameList = LANGUAGE_TIPS_WORDS156
        local _time = 0.4
        local _space = 0.05
        for i=1,4 do
            local splitLine = cc.Sprite:create("res/image/plugin/level_up/label_bg.png")
            splitLine:setPosition(bg:getBoundingBox().width / 2,bg:getBoundingBox().height + 25 - 155 - XTHD.resource.getPosInArr({
                lenth = 11,
                bgWidth = bg:getBoundingBox().height,
                num = 4,
                nodeWidth = splitLine:getBoundingBox().height,
                now = i
            }))
            bg:addChild(splitLine,-1)
            splitLine:setVisible(false)

            if i == 4 then 
                splitLine:runAction( cc.Sequence:create(  cc.DelayTime:create(_time / 2 * (i-1)),cc.CallFunc:create(function ( )
                    splitLine:setVisible(true)
                end),cc.MoveBy:create(_time - i*_space,cc.p(0,200)),cc.CallFunc:create(function( )
                    self:showBoardBottom(bg)
                end)))
            else 
                splitLine:runAction( cc.Sequence:create(  cc.DelayTime:create(_time / 2 * (i-1)),cc.CallFunc:create(function ( )
                    splitLine:setVisible(true)
                end),cc.MoveBy:create(_time - i*_space,cc.p(0,200))))
            end 


            local name = XTHDLabel:createWithParams({
                text = nameList[i],
                fontSize = 20,
                color = cc.c3b(255,207,139)--XTHD.resource.color.gray_desc
            })
            name:setAnchorPoint(0,0.5)
            name:setPosition(splitLine:getBoundingBox().width/2 - 115,splitLine:getContentSize().height/2)
            splitLine:addChild(name)
            
            

            if i == 2 then
                local nowPhy = getCommonWhiteBMFontLabel(NowData.maxphysical)
                nowPhy:setPosition(name:getPositionX()+name:getBoundingBox().width+15,name:getPositionY()-7)
                splitLine:addChild(nowPhy)

                nowPhy:setScale(0.9)

                local arrow = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
                arrow:setRotation(90)
                arrow:setPosition(name:getPositionX()+150,nowPhy:getPositionY()+7)
                splitLine:addChild(arrow)

                local nextPhy = getCommonGreenBMFontLabel(UpData.maxphysical)
                nextPhy:setScale(0.7)
                nextPhy:setPosition(arrow:getPositionX()+50,nowPhy:getPositionY()+5)
                splitLine:addChild(nextPhy)

            elseif i == 3 then
                local levelLabel = getCommonWhiteBMFontLabel(NowData.maxlevel)
                levelLabel:setPosition(name:getPositionX()+name:getBoundingBox().width+15,name:getPositionY()-7)
                splitLine:addChild(levelLabel)

                levelLabel:setScale(0.9)

                local arrow = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
                arrow:setRotation(90)
                arrow:setPosition(name:getPositionX()+150,levelLabel:getPositionY()+7)
                splitLine:addChild(arrow)

                local nextLevel = getCommonGreenBMFontLabel(UpData.maxlevel)
                nextLevel:setScale(0.7)
                nextLevel:setPosition(arrow:getPositionX()+50,levelLabel:getPositionY()+5)
                splitLine:addChild(nextLevel)
            elseif i == 4 then
                local phyIcon = XTHD.createHeaderIcon(XTHD.resource.type.tili)
                phyIcon:setScale(0.8)
                phyIcon:setAnchorPoint(1,0.5)
                phyIcon:setPosition(name:getPositionX()+name:getBoundingBox().width+25,name:getPositionY()-1)
                splitLine:addChild(phyIcon)

                local phyRecover = getCommonGreenBMFontLabel(difLevel*20)
                phyRecover:setScale(0.7)
                phyRecover:setPosition(phyIcon:getPositionX()+25,name:getPositionY()-2)--35
                splitLine:addChild(phyRecover)

            elseif i == 1 then
                local nowPhy = getCommonWhiteBMFontLabel(nowLevel)
                nowPhy:setPosition(name:getPositionX()+name:getBoundingBox().width+15,name:getPositionY()-7)
                splitLine:addChild(nowPhy)

                nowPhy:setScale(0.9)

                local arrow = cc.Sprite:create("res/image/plugin/hero/hero_propertyadd.png")
                arrow:setRotation(90)
                arrow:setPosition(name:getPositionX()+150,nowPhy:getPositionY()+7)
                splitLine:addChild(arrow)

                local nextPhy = getCommonGreenBMFontLabel(levelNew)
                nextPhy:setScale(0.7)
                nextPhy:setPosition(arrow:getPositionX()+50,nowPhy:getPositionY()+5)
                splitLine:addChild(nextPhy)
            end
        end 
    end
    bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ( )
        createInfo()
    end)))
end

function ShengJiLayer:showBoardBottom(target)
    local _node = cc.Node:create()
    _node:setContentSize(cc.size(226,190))
    _node:setCascadeOpacityEnabled(true)
    _node:setOpacity(0)
    -------效果文字 
    local _word = XTHDLabel:createWithSystemFont(LANGUAGE_LEVELUP_TIP2,XTHD.SystemFont,22)
    _word:setColor(cc.c3b(255,255,0))
    _node:addChild(_word)
    _word:enableShadow(cc.c4b(255,255,0,255),cc.size(1,0))
    -----升级效果
    local _sprite = cc.Sprite:create("res/image/plugin/level_up/level_bg2.png")
    _node:addChild(_sprite)
    _sprite:setPosition(_node:getContentSize().width / 2,_node:getContentSize().height - _word:getContentSize().height)
    _word:setPosition(_sprite:getPositionX(),_sprite:getPositionY())
    -----升级之后的提示
    local y = _sprite:getPositionY() - _sprite:getContentSize().height  - 5
    for k,v in pairs(LANGUAGE_LEVELUP_TIP) do
        local _otherTips = XTHDLabel:createWithSystemFont(v,XTHD.SystemFont,20)
        _node:addChild(_otherTips)
        _otherTips:setColor(cc.c3b(255,207,139))
        _otherTips:setAnchorPoint(0.5,1)
        _otherTips:setPosition(_sprite:getPositionX(),y)
        y = y - _otherTips:getContentSize().height - 8
    end 
    ------点击屏幕继续
    local _tips = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_CLICKSCENEIN,XTHD.SystemFont,18)
    _node:addChild(_tips)
    _tips:setColor(cc.c4b(255,240,216))
    _tips:setPosition(_node:getBoundingBox().width / 2,_tips:getContentSize().height / 2)

    target:addChild(_node)
    _node:setAnchorPoint(0.5,0.5)
    _node:setPosition(target:getContentSize().width / 2,-120)
    _node:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.CallFunc:create(function( )
        self._isCanClose = true
    end)))
end

function ShengJiLayer:onEnter( )
    print("the level up layer at onenter function")
end

function ShengJiLayer:onExit()
    print("the level up layer at on exit function")
    if self._extraCallbac then 
        self._extraCallbac()
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_NEWFUNCTIONOPEN_TIP}) ------刷新主城左上角的新功能开启提示
end

function ShengJiLayer:onCleanup()
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/spine/effect/level_up/xgn.png")
    textureCache:removeTextureForKey("res/image/plugin/level_up/level_bg2.png")
    textureCache:removeTextureForKey("res/image/plugin/level_up/label_bg.png")
end

function ShengJiLayer:setExtraCallback( callback ) ----i添加额外的回调函数
    if not self._extraCallbac then 
        self._extraCallbac = callback
    else 
        local _tempCall = self._extraCallbac
        self._extraCallbac = function( )
            callback()
            _tempCall()            
        end
    end 
end

return ShengJiLayer