DengLuCircleLayer = class("DengLuCircleLayer", function()
    return XTHDDialog:create()
end)
DengLuCircleLayer.__index = DengLuCircleLayer
--加载界面
--构造函数,LoadingLayer.new()的时候，会自动调用该构造函数
function DengLuCircleLayer:ctor( rotation )
    -- self:setOpacity(0)

    local function doLoading( ... )
        --local loadingBg = cc.Sprite:create("res/image/loading/newLoading/loading.png")
        --loadingBg:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5 - 10)
        --self:addChild(loadingBg)

        --local bar_bg = XTHD.createSprite("res/image/login/login_loading_bar_bg.png")
        --bar_bg:setPosition(cc.p(self:getContentSize().width / 2, 86))
        --self:addChild(bar_bg)
        --bar_bg:setScale(0.8)
--
        --self._loadingProgress = nil
--
        --local loadingProgress = cc.ProgressTimer:create(cc.Sprite:create("res/image/login/login_loading_bar.png"))
        --loadingProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        --loadingProgress:setMidpoint(cc.p(0, 0))
        --loadingProgress:setBarChangeRate(cc.p(1, 0))
        --loadingProgress:setPosition(cc.p(bar_bg:getContentSize().width / 2, bar_bg:getContentSize().height / 2))
        --loadingProgress:setPercentage(0)
        --bar_bg:addChild(loadingProgress)
        --self._loadingProgress = loadingProgress
--
--
        --local arr = {}
        --for i=1,10 do
        --    math.newrandomseed()
        --    local random = math.random()
        --    if random < 0.3 then
        --        random = random + 0.2
        --    end
        --    arr[#arr+1] = cc.ProgressTo:create(random, 100)
        --    arr[#arr+1] = cc.CallFunc:create(function()
        --                    loadingProgress:setPercentage(0)
        --                end)
        --end
--
        ----[[循环播放动画]]
        --loadingProgress:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))

        -- local loadingBg = cc.Sprite:create("res/image/loading/newLoading/jzBg.png")
        -- loadingBg:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5 - 10)
        -- self:addChild(loadingBg)
        print("loadingSprite create")
        local loadingSprite = cc.Sprite:create()
        
        local action = getAnimation("res/image/loading/newLoading/jz", 1, 15, 0.05)
        loadingSprite:runAction(cc.RepeatForever:create(action))
        loadingSprite:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
        self:addChild(loadingSprite)
        loadingSprite:setName("loadingSprite")
        print("addChild loadingSprite")
        -- local loadingSprite = sp.SkeletonAnimation:create( "res/image/loading/newLoading/loding.json", "res/image/loading/newLoading/loding.atlas",1.0)
        -- loadingSprite:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
        -- self:addChild(loadingSprite)

        -- loadingSprite:setAnimation(0,"loding",true)
        -- loadingSprite:setName("loadingSprite")
    end

    performWithDelay(self, doLoading, 0.5)


end

function DengLuCircleLayer:create(rotation)
    local layer = DengLuCircleLayer.new(rotation);
    return layer;
end

function DengLuCircleLayer:getCircleRotate(  )
	local loadingSprite = self:getChildByName("loadingSprite")
	return loadingSprite:getRotation()   --返回当前circle旋转的角度
end
