LoadingAnimLayer1 = class("LoadingAnimLayer1", function()
    return XTHDDialog:create()
end)

LoadingAnimLayer1.__index = LoadingAnimLayer1
--加载界面
--构造函数,LoadingAnimLayer1.new()的时候，会自动调用该构造函数
function LoadingAnimLayer1:ctor( rotation,callback )
    local function doLoading( ... )
        print("loadingSprite create")
        --local loadingSprite = cc.Sprite:create()
        
        -- local action = getAnimation("res/image/loading/newLoading/tc_VS_0000", 0, 7, 0.05)
        -- loadingSprite:runAction(cc.RepeatForever:create(action))
        -- loadingSprite:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
        -- self:addChild(loadingSprite)
        -- loadingSprite:setName("loadingSprite")

        local loadingSprite = sp.SkeletonAnimation:create( "res/image/loading/newLoading/skeleton.json", "res/image/loading/newLoading/skeleton.atlas",1.0)
        loadingSprite:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
        self:addChild(loadingSprite)

        loadingSprite:setAnimation(0,"animation",true)
        loadingSprite:setName("loadingSprite")
		loadingSprite:registerSpineEventHandler( function(event)
			self:removeFromParent()
			callback()
		end , sp.EventType.ANIMATION_END)
    end

    performWithDelay(self, doLoading, 0.5)
end

function LoadingAnimLayer1:create(rotation)
    local layer = LoadingAnimLayer1.new(rotation);
    return layer;
end

function LoadingAnimLayer1:getCircleRotate(  )
	local loadingSprite = self:getChildByName("loadingSprite")
	return loadingSprite:getRotation()   --返回当前circle旋转的角度
end
