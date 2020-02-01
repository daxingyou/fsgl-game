--[[
	神兽副本征战弹窗
	唐实聪
	2015.11.16
]]
local ShenQiYiZhiSweepLayer = class("ShenQiYiZhiSweepLayer",function ()
	local layer = XTHD.createPopLayer({isRemoveLayout = true})
	return layer
end)

function ShenQiYiZhiSweepLayer:ctor( params )
	self._callback = params.callback
	self:initUI( params )
end

function ShenQiYiZhiSweepLayer:initUI( params )
	self._bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png" )
    self._bg:setContentSize(375,278)
	self._bg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	self._bg:setPosition( self:getContentSize().width*0.5, self:getContentSize().height*0.5 )
	self:addContent( self._bg )
	--kuang 
	local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	kuang:setContentSize(self._bg:getContentSize().width-20,self._bg:getContentSize().height/2)
	kuang:setPosition(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2+10)
	self._bg:addChild(kuang)
	
	self._bgSize = self._bg:getContentSize()
	-- 顶部提示
	local tipLabel = XTHD.createLabel({
		text = LANGUAGE_KEY_SAINTBEASTSWEEP[1],
		fontSize = 18,
		color = cc.c3b( 55, 54, 112 ),
		ttf = "res/fonts/def.ttf"
	})
	tipLabel:setAnchorPoint( cc.p( 0.5, 1 ) )
	tipLabel:setPosition( self._bgSize.width*0.5, self._bgSize.height - 20 )
	self._bg:addChild( tipLabel )
	-- 征战消耗
	local consumeTip = XTHD.createLabel({
		text = LANGUAGE_KEY_SAINTBEASTSWEEP[2].."：",
		fontSize = 16,
		color = cc.c3b( 55, 54, 112 ),
		ttf = "res/fonts/def.ttf"
	})
	consumeTip:setAnchorPoint( cc.p( 0, 0.5 ) )
	consumeTip:setPosition( self._bgSize.width*0.23, self._bgSize.height - 105 )
	self._bg:addChild( consumeTip )
	local consumeIcon = XTHD.createSprite( "res/image/plugin/saint_beast/saintbeasticon.png" )
	consumeIcon:setAnchorPoint( cc.p( 0, 0.5 ) )
	consumeIcon:setPosition( consumeTip:getPositionX() + consumeTip:getContentSize().width + 10, consumeTip:getPositionY() )
	self._bg:addChild( consumeIcon )
	local consumeNum = XTHD.createLabel({
		text = params.consume,
		fontSize = 20,
		color = cc.c3b( 255, 255, 255 ),
		ttf = "res/fonts/def.ttf"
	})
	consumeNum:setAnchorPoint( cc.p( 0, 0.5 ) )
	consumeNum:setPosition( consumeIcon:getPositionX() + consumeIcon:getContentSize().width + 10, consumeTip:getPositionY() )
	self._bg:addChild( consumeNum )
	-- 当前拥有
	local currentTip = XTHD.createLabel({
		text = LANGUAGE_KEY_SAINTBEASTSWEEP[3].."：",
		fontSize = 16,
		color = cc.c3b(  55, 54, 112 ),
		ttf = "res/fonts/def.ttf"
	})
	currentTip:setAnchorPoint( cc.p( 0, 0.5 ) )
	currentTip:setPosition( consumeTip:getPositionX(), consumeTip:getPositionY() - 35 )
	self._bg:addChild( currentTip )
	local currentIcon = XTHD.createSprite( "res/image/plugin/saint_beast/saintbeasticon.png" )
	currentIcon:setAnchorPoint( cc.p( 0, 0.5 ) )
	currentIcon:setPosition( consumeIcon:getPositionX(), currentTip:getPositionY() )
	self._bg:addChild( currentIcon )
	local currentNum = XTHD.createLabel({
		text = XTHD.resource.getItemNum( params.own ),
		fontSize = 20,
		color = cc.c3b( 255, 255, 255 ),
		ttf = "res/fonts/def.ttf"
	})
	currentNum:setAnchorPoint( cc.p( 0, 0.5 ) )
	currentNum:setPosition( consumeNum:getPositionX(), currentTip:getPositionY() )
	self._bg:addChild( currentNum )

	local sweepTenBtn = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		text = LANGUAGE_BTN_KEY.saodangshici,
		fontSize = 22,
		btnSize = cc.size(130, 49),
		endCallback = function()
			XTHDHttp:requestAsyncInGameWithParams({
                modules="sweepServant?",
                params = {ectypeType = params.id, count = 10},
                successCallback = function( finishTask )
                    -- dump(finishTask,"神兽副本征战10返回")
                    if tonumber( finishTask.result ) == 0 then
                        -- 成功获取弹窗
                        local iconData = {}
                        if finishTask.addWanlingpo ~= 0 then
                        	iconData[1] = {
                        		rewardtype = XTHD.resource.type.servant,
                        		num = finishTask.addWanlingpo,
                        	}
                        end
                        for i, v in ipairs( finishTask.addItems ) do
                        	local tmp = string.split( v, "," )
                        	iconData[#iconData + 1] = {
                        		rewardtype = 4,
                        		id = tonumber( tmp[1] ),
                        		num = tonumber( tmp[2] ),
                        	}
                        end
				    	ShowRewardNode:create( iconData )
				    	-- 更新属性
				    	if finishTask.property and #finishTask.property > 0 then
			                for i=1, #finishTask.property do
			                    local pro_data = string.split( finishTask.property[i], ',' )
			                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
			                end
			                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
			            end
			            -- 更新背包
			            gameUser.setServant( finishTask.wanlingpo )
			            if finishTask.bagItems and #finishTask.bagItems ~= 0 then
			                for i=1, #finishTask.bagItems do
			                    local item_data = finishTask.bagItems[i]
			                    if item_data.count and tonumber( item_data.count ) ~= 0 then
			                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
			                    else
			                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
			                    end
			                end
			            end
			            -- 更新当前拥有试炼水晶数量
			            currentNum:setString( XTHD.resource.getItemNum( params.own ) )
			            -- 更新modeLayer界面试炼水晶数量
			            if self._callback then
			            	self._callback()
			            end
                    else
                        XTHDTOAST(finishTask.msg)
                    end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
		end,
	})
	sweepTenBtn:setScale(0.7)
	sweepTenBtn:setAnchorPoint( cc.p( 1, 0.5 ) )
	sweepTenBtn:setPosition( self._bgSize.width*0.5 - 15, 50 )
	self._bg:addChild( sweepTenBtn )

	local sweepOneBtn = XTHD.createCommonButton({
		btnColor = "write",
		isScrollView = false,
		text = LANGUAGE_BTN_KEY.saodangyici,
		fontSize = 22,
		btnSize = cc.size(130, 49),
		endCallback = function()
			XTHDHttp:requestAsyncInGameWithParams({
                modules="sweepServant?",
                params = {ectypeType = params.id, count = 1},
                successCallback = function( finishTask )
                    -- dump(finishTask,"神兽副本征战1返回")
                    if tonumber( finishTask.result ) == 0 then
                        -- 成功获取弹窗
                        local iconData = {}
                        if finishTask.addWanlingpo ~= 0 then
                        	iconData[1] = {
                        		rewardtype = XTHD.resource.type.servant,
                        		num = finishTask.addWanlingpo,
                        	}
                        end
                        for i, v in ipairs( finishTask.addItems ) do
                        	local tmp = string.split( v, "," )
                        	iconData[#iconData + 1] = {
                        		rewardtype = 4,
                        		id = tonumber( tmp[1] ),
                        		num = tonumber( tmp[2] ),
                        	}
                        end
				    	ShowRewardNode:create( iconData )
				    	-- 更新属性
				    	if finishTask.property and #finishTask.property > 0 then
			                for i=1, #finishTask.property do
			                    local pro_data = string.split( finishTask.property[i], ',' )
			                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
			                end
			                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
			            end
			            -- 更新背包
			            gameUser.setServant( finishTask.wanlingpo )
			            if finishTask.bagItems and #finishTask.bagItems ~= 0 then
			                for i=1, #finishTask.bagItems do
			                    local item_data = finishTask.bagItems[i]
			                    if item_data.count and tonumber( item_data.count ) ~= 0 then
			                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
			                    else
			                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
			                    end
			                end
			            end
			            -- 更新当前拥有试炼水晶数量
			            currentNum:setString( XTHD.resource.getItemNum( params.own ) )
			            -- 更新modeLayer界面试炼水晶数量
			            if self._callback then
			            	self._callback()
			            end
                    else
                        XTHDTOAST(finishTask.msg)
                    end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
		end,
	})
	sweepOneBtn:setScale(0.7)
	sweepOneBtn:setAnchorPoint( cc.p( 0, 0.5 ) )
	sweepOneBtn:setPosition( self._bgSize.width*0.5 + 15, 50 )
	self._bg:addChild( sweepOneBtn )
end

function ShenQiYiZhiSweepLayer:create(params)
	return self.new(params)
end

return ShenQiYiZhiSweepLayer