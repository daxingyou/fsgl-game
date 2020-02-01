--[[
authored by LITAO
]]
YinDao = class("YinDao",function( )
	return cc.Layer:create()
end)
--[[
params = {
	target, 需要添加引导的节点
    targPos,
    targSize,
	isMode = true,是否是模态的,
    targetBeganFunc = nil,
    originCallback = nil,当前引导的按钮的本身回调
	clickedCallBack = nil 点击手指定的功能之后的回调,
    needHand = true 是否要手，默认是有手的
    needSelfClose = trie 是否在引导点击之后自我销毁，默认会    
    delayHand = false,是否延迟显示指引手
    offset = cc.p(x,y),指引手的偏移量,
    needSelfRemove = true,是否需要自我移除
    needHandleMove = true,是否需要处理点击移动 
    isButton = true,当前引导的对象是否为button
    delayRemoveTouch = 0,
    notList = true, 当前引导的对象是否为list,
    direction = 2,1上，2下，3左，4右
    needCloser = false,---是否要求箭头与光圈相邻
    noTouchEvent = false---添加屏蔽层
    hasMask = true -----是否变黑遮罩
    extraCall = nil -----额外的回调函数
    LinerGuide = true ------
}
]]
function YinDao:ctor( params )
	print("引导界面所需的数据为：")
	print_r(params)
    self.targetBox = cc.rect(0,0,0,0)
    self._darkPieces = {} -----暗色的片背景
    self._clickedTimes = 0 -------在引导的区域内点击的次数
    self._noTouchEvent = false
    self._hasMask = true
	if params then 
        self._extraCallback = params.extraCall
        self._isCover = false
        self._target = params.target
        self.touchPos = self._target:convertToWorldSpace(cc.p(0,0))
        self._targSize = self._target:getBoundingBox()

        self._isMode = params.isMode == 1 and true or false
        self._delayHand = params.delayHand and true or false
        self._needSelfClose = params.needSelfClose and params.needSelfClose or true   
        self._clickedCallBack = params.clickedCallBack
        self._originCallback = params.originCallback or self._target:getTouchEndedCallback()
        self._needCloser = params.needCloser
        self._wordTips = params.wordTips
        self._wordTipsPos = params.pos
        self._noTouchEvent = false--params.noTouchEvent == nil and false or params.noTouchEvent
        self._hasMask = params.hasMask == nil and true or params.hasMask
        self._action = params.action or 2
        self._offset = params.offset or cc.p(0,0)
        self._direction = params.direction or 2
        self._notList = params.notList == nil and true or params.notList
        self._delayRemoveTouch = params.delayRemoveTouch or 0
        self._isButton = params.isButton == nil and true or params.isButton
        self._needHandlerMove = params.needHandleMove == nil and true or params.needHandleMove
        self._isLinerGuide = params.LinerGuide == nil and true or params.LinerGuide
        if self._isButton then 
            self._musicFile = params.target:getMusicFile()            
        end  
    else 
        self._isCover = true
        self._isMode = true
	end 
end

function YinDao:create(params)
	local guide = YinDao.new(params)
	if guide then 
		guide:init()
		guide:registerScriptHandler(function(event)
			if event == "enter" then 
				guide:onEnter()
			elseif event == "exit" then 
				guide:onExit()
			end 
		end)
	end
	return guide
end

function YinDao:init( )	
    if not self._isCover then 
        if not self._delayHand then 
            if self.touchPos then 
                self.touchPos = self:convertToNodeSpace(self.touchPos)
            end 
        end 
        if self._offset then 
            self.touchPos.x = self.touchPos.x + self._offset.x
            self.touchPos.y = self.touchPos.y + self._offset.y
        end 
        ------手
        local _spine = sp.SkeletonAnimation:create( "res/spine/guide/yd.json", "res/spine/guide/yd.atlas", 1.0)
        _spine:setAnimation(0,"animation",true)
        self._hand = cc.Sprite:create()
        self._hand:addChild(_spine)
        
        self:addChild(self._hand,3)
        if self._delayHand then 
            self._hand:setVisible(false)
        else 
            self._hand:setVisible(true)
        end 
        ----顶层layer,接收触摸
        self.handBox = cc.rect(self._hand:getPositionX(),self._hand:getPositionY(),75,75)
        self.targetBox = cc.rect(self.touchPos.x,self.touchPos.y,self._targSize.width,self._targSize.height)
        self:updateHandPos()           
    end 
    
    local function selfTouchBegan(touch, event)
        if self._isCover or self._delayHand then 
            self._outOfTarget = true
            return true        
        end 
        local touch = touch:getLocation()
        if cc.rectContainsPoint(self.targetBox,touch) or cc.rectContainsPoint(self.handBox,touch) then ----点中按钮本身 或者引导图标本身
            if self._isButton and self._target and (self._target.getStateSelected and self._target:getStateSelected())then  
                self._target:getStateSelected():setVisible(true)
                if (self._target.getStateNormal and self._target:getStateNormal()) then  
                    self._target:getStateNormal():setVisible(false)
                end 
            end 
            self._outOfTarget = false
        else 
            self._outOfTarget = true
        end 
        return true
    end

    local function selfTouchMoved(touch, event)
        if self._isCover or self._outOfTarget then
            return 
        end 
        local touch = touch:getLocation()
        if cc.rectContainsPoint(self.targetBox,touch) or cc.rectContainsPoint(self.handBox,touch) then----在按钮的点击区域内或者在引导图标的点击区域内
            if self._isButton and self._target and (self._target.getStateSelected and self._target:getStateSelected())then  
                self._target:getStateSelected():setVisible(true)
                if (self._target.getStateNormal and self._target:getStateNormal()) then  
                    self._target:getStateNormal():setVisible(false)
                end 
            end 
        else
            if self._isButton and self._target and (self._target.getStateSelected and self._target:getStateSelected())then  
                self._target:getStateSelected():setVisible(false)
                if (self._target.getStateNormal and self._target:getStateNormal()) then  
                    self._target:getStateNormal():setVisible(true)
                end 
            end 
        end 
    end

    local function selfTouchEnded(touch, event)
        if self._isCover then 
            return 
        end 
        local touch = touch:getLocation()        
        if self._isButton and self._target and (self._target.getStateNormal and self._target:getStateNormal()) then  
            self._target:getStateNormal():setVisible(true)
            if (self._target.getStateSelected and self._target:getStateSelected())then  
                self._target:getStateSelected():setVisible(false)
            end 
        end  
        if self._isMode and (cc.rectContainsPoint(self.targetBox,touch) or cc.rectContainsPoint(self.handBox,touch)) then----点中按钮区域或者引导图标区域内放开
            if self._originCallback and self._clickedTimes == 0 then  
                if self._musicFile then -----8音效
                    musicManager.playEffect(self._musicFile)
                end 
                self._originCallback()
            end 
            if self._extraCallback and self._clickedTimes == 0 then 
                self._extraCallback()
            end 
            self._clickedTimes = (self._clickedTimes or 0) + 1
            print("the clicked times is",self._clickedTimes)
        elseif not self._isMode and not (cc.rectContainsPoint(self.targetBox,touch) or cc.rectContainsPoint(self.handBox,touch)) then ---弱引导且没有在有效区域内  
            if self._isLinerGuide then 
                print("out of target area and weak guide ")
                YinDaoMarg:getInstance():overCurrentGuide(true)
            end 
        end
    end
    if not self._noTouchEvent then 
        self.topListener = cc.EventListenerTouchOneByOne:create()
        self.topListener:setSwallowTouches(self._isMode)
        self.topListener:registerScriptHandler(selfTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        self.topListener:registerScriptHandler(selfTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        self.topListener:registerScriptHandler(selfTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.topListener, self)
    end 
    ------------------------------------------------------------------------------------------------------------------------------
end 

function YinDao:onEnter( )
end

function YinDao:onExit( )
    print("the guidelayer has exit",self._id)
    -----------删除非引导区的暗色背景
    for k,v in pairs(self._darkPieces) do 
        v:removeFromParent()
    end 
    self._darkPieces = {}
    self._clickedTimes = 0
end
------重置在有效区域内点击次数的计数
function YinDao:resetClickCounter( )
    self._clickedTimes = 0
end
------把非引导区填充成暗色(从右边开始，逆时针)
function YinDao:fillOtherToDark()
    for k,v in pairs(self._darkPieces) do 
        v:removeFromParent()
    end 
    -----------------
    local _size = self:getContentSize()
    local rect = self._holdMask:getBoundingBox()
    local width = 0 
    local height = 0
    local x = 0
    local y = 0
    for i = 1,4 do 
        local anchor = cc.p(0.5,0.5)
        if i == 1 then ---右边
            width = _size.width - cc.rectGetMaxX(rect)
            height = _size.height - cc.rectGetMinY(rect)
            if height < 0 then 
                height = math.abs(height) + _size.height
            end 
            x,y = cc.rectGetMaxX(rect),cc.rectGetMinY(rect)   
            anchor = cc.p(0,0)      
        elseif i == 2 then ----上
            width = cc.rectGetMaxX(rect)
            height = _size.height - cc.rectGetMaxY(rect)
            x,y = cc.rectGetMaxX(rect),cc.rectGetMaxY(rect)
            anchor = cc.p(1,0)         
        elseif i == 3 then ----左
            width = cc.rectGetMinX(rect)
            height = cc.rectGetMaxY(rect)
            if height < 0 then 
                height = math.abs(height) + _size.height
            end 
            x,y = cc.rectGetMinX(rect),cc.rectGetMaxY(rect)
            anchor = cc.p(1,1)         
        elseif i == 4 then ----下
            width = _size.width - cc.rectGetMinX(rect)
            if width < 0 then 
                width = math.abs(width) + _size.width
            end 
            height = cc.rectGetMinY(rect)
            x,y = cc.rectGetMinX(rect),cc.rectGetMinY(rect)
            anchor = cc.p(0,1)         
        end 
        if (width > 0 and height > 0) then 
            local _dark = cc.Sprite:create("res/spine/guide/guide_mask_gray.png")
            _dark:setScaleX(width / _dark:getContentSize().width)
            _dark:setScaleY(height / _dark:getContentSize().height)
            _dark:setAnchorPoint(anchor)
            _dark:setPosition(x,y)
            self:addChild(_dark,2)
            self._darkPieces[i] = _dark
        end 
    end 
    performWithDelay(self,function( )
        self:showTipsWords()
    end,0.2)
end

function YinDao:showTipsWords( ) -------显示浣熊的提示对话框
    if self._wordTips and tonumber(self._wordTips) ~= 0 then 
        -- local _dialog = sp.SkeletonAnimation:create( "res/spine/guide/duihua.json", "res/spine/guide/duihua.atlas", 1.0)
        local _dialog = cc.Sprite:create("res/spine/guide/yindao.png")
        _dialog:setScale(1.2)
        local _board = cc.Node:create()
        _board:setContentSize(cc.size(231,90))
        _board:addChild(_dialog)
        _dialog:setPosition(_board:getContentSize().width / 2 - 30,_board:getContentSize().height / 2 + 5)
        self._wordDialog = _board
        
        self:addChild(_board,2)
        _board:setAnchorPoint(0.5,0)
        local x,y = self.targetBox.x + self.targetBox.width / 2,self.targetBox.y  + self.targetBox.height / 2
        if self._wordTipsPos and self._wordTipsPos.x ~= 0 and self._wordTipsPos.y ~= 0 then 
            _board:setPosition(x + self._wordTipsPos.x,y + self._wordTipsPos.y)
        else 
            self:autoAdjustWordDialog()
        end 
        ---
        local word = XTHDLabel:createWithSystemFont(self._wordTips,XTHD.SystemFont,20)
        word:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
        word:setDimensions(200,80)
        _board:addChild(word)
        word:setAnchorPoint(0,0.5)
        word:setPosition(50,15)
        
        -- _dialog:setAnimation(0,self._action.."_0",false)
        -- performWithDelay(self,function( )
        --     _dialog:setAnimation(0,self._action.."_1",true)
        -- end,1/3)
    end 
end
-----自动调整引导期间的对话框的位置
function YinDao:autoAdjustWordDialog( )
    local size = self._wordDialog:getContentSize()
    local x,y
    self._wordDialog:setAnchorPoint(0.5,0.5)
    if self.handBox.x - self.handBox.width - size.width < 10 then 
        x = self.handBox.x + self.handBox.width + size.width / 2
    else 
        x = self.handBox.x - self.handBox.width - size.width / 2
    end 
    if self.handBox.y - self.handBox.height - size.height < 10 then 
        y = self.handBox.y + self.handBox.height + size.height / 2
    else 
        y = self.handBox.y - self.handBox.height - size.height / 2
    end 
    self._wordDialog:setPosition(x,y)
end

function YinDao:doTouchedTarget( )
    if self._delayRemoveTouch > 0 then 
        self.targetBox = cc.rect(0,0,0,0)
        self.handBox = cc.rect(0,0,0,0)
        if self._hand then 
            self._hand:setVisible(false)
        end 
        performWithDelay(self,function( )      
            if self._clickedCallBack then 
                self._clickedCallBack()
            end 
        end,self._delayRemoveTouch)
    else 
        if self._clickedCallBack then 
            self._clickedCallBack()
        end  
    end 
end

function YinDao:refreshHand(pos,addOffset)
    if self._isButton then 
        self._musicFile = self._target:getMusicFile()            
    end  
    if self._hand and self._delayHand then 
        self.touchPos = self:convertToNodeSpace(pos)
        if self._offset then  
            self.touchPos.x = self.touchPos.x + self._offset.x
            self.touchPos.y = self.touchPos.y + self._offset.y
        end 
        self._hand:setVisible(true)        
        self._hand:stopAllActions()
        self.targetBox.x = self.touchPos.x
        self.targetBox.y = self.touchPos.y      
        
        self._delayHand = false
        self:updateHandPos()
    end 
end

function YinDao:updateHandPos( )
    if not self._delayHand and self._hasMask then 
        --------遮罩
        local _mask = cc.Sprite:create("res/spine/guide/guide_mask_hole.png")
        self:addChild(_mask,2)
        self._holdMask = _mask
    end 
    if self._hand then 
        if self.touchPos then     
            if self._direction == 2 then --下
                self._hand:setRotation(180)
            elseif self._direction == 3 then  ----左
                self._hand:setRotation(-90)
            elseif self._direction == 4 then  ----右    
                self._hand:setRotation(90)
            end 
            self._hand:setPosition(self.targetBox.x + self.targetBox.width / 2,self.targetBox.y  + self.targetBox.height / 2)
            
        end 
    end
    self.handBox = cc.rect(self._hand:getPositionX(),self._hand:getPositionY(),75,75)
    if not self._delayHand and self._holdMask then 
        self._holdMask:setPosition(self._hand:getPosition())            
        self:fillOtherToDark()
    elseif self._hasMask == false and self._wordTips then ------处于不需要暗层但是需要出提示的
        performWithDelay(self,function( )
            self:showTipsWords()
        end,0.2)
    end 
end

function YinDao:reset( )
    self._target = nil
    self._clickedCallBack = nil
    self._originCallback = nil
end

function YinDao:setHandVisible( visible )
    if self._hand then 
        self._hand:setVisible(visible)
    end 
end

function YinDao:getCurrentElement( )
    return self._target
end

function YinDao:addAHandToTarget( target )
    local _spine = sp.SkeletonAnimation:create( "res/spine/guide/yd.json", "res/spine/guide/yd.atlas", 1.0)
    local pointer = cc.Node:create()
    pointer:addChild(_spine)
    if pointer then 
        target:getParent():addChild(pointer,1024)
        local box = target:getBoundingBox()
        pointer:setPosition(box.x + box.width / 2,box.y + box.height / 2)
        _spine:setAnimation(0,"animation",true)
    end
    return pointer
end