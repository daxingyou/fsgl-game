--[[
	引导选择英雄界面
	唐实聪
	2016.3.5
]]
YinDaoSelectHeroLayer = class( "YinDaoSelectHeroLayer", function()
	local layer = XTHDDialog:create()
	return layer
end)

function YinDaoSelectHeroLayer:create( callback )
	return YinDaoSelectHeroLayer.new( callback )
end
 
function YinDaoSelectHeroLayer:ctor( callback )
	self:initData( callback )

	self:initBottomLayer()
	-- self:initMiddleLayer()
	-- self:initTopLayer()
	-- self:initAction()
	-- self:showTip()
	self._clickable = true
end

function YinDaoSelectHeroLayer:initData( callback )
	self._callback = callback
	self._root = "res/image/selecthero/"
	self._size = self:getContentSize()
	self._index = 2

	self._clickable = false

	self._heroId = { 8, 37, 17 }
	self._hero = {}
	self._gear = {}
	self.texiao = {}
end
-- 底层
function YinDaoSelectHeroLayer:initBottomLayer()
	-- 底层容器
	local bottomLayer = XTHD.createSprite()
	bottomLayer:setContentSize( self._size )
	bottomLayer:setPosition( self._size.width/2, self._size.height/2 )
	self:addChild( bottomLayer, 1 )
	-- 背景
	local background = XTHD.createSprite( self._root.."bg.png" )
	background:setPosition( self._size.width/2, self._size.height/2 )
	local winSize = cc.Director:getInstance():getWinSize()
	background:setContentSize(winSize)
	bottomLayer:addChild( background )
	--英雄选择
	local yxxe = cc.Sprite:create(self._root.."yxxz.png")
	yxxe:setAnchorPoint(0.5,1)
	yxxe:setPosition(background:getContentSize().width/2,background:getContentSize().height-30)
	background:addChild(yxxe)

	local selectBtn = XTHD.createButton({
		normalFile = self._root.."card.png",
		selectedFile = self._root.."card.png",
		endCallback = function()
			if self._clickable then
				-- if self._callback then
    --             	self._callback()
    --             end
				self:clickEnsureCallback()
			end
		end
	})
	selectBtn:setTouchBeganCallback(function( )
        selectBtn:setScale(0.98)
    end)
    selectBtn:setTouchMovedCallback(function( )
        selectBtn:setScale(0.98)
    end)
	background:addChild(selectBtn)
	selectBtn:setPosition(self:getContentSize().width/2 + 5,self:getContentSize().height/2 + 10)
	selectBtn:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveTo:create(1,cc.p(self:getContentSize().width/2 + 5,self:getContentSize().height/2 + 15)),
            cc.MoveTo:create(1,cc.p(self:getContentSize().width/2 + 5,self:getContentSize().height/2 + 10))
        )
    ))

	--特效
	local texiao = cc.Sprite:create(self._root.."tx.png")
	texiao:setAnchorPoint(0.5,0)
	texiao:setPosition(self:getContentSize().width/2,70)
	background:addChild(texiao)

	--装饰
	local content = cc.Node:create()
	background:addChild(content)
	content:setPosition(self:getContentSize().width/2,45)
	local des1 = cc.Sprite:create(self._root.."des1.png")
	content:addChild(des1)
	des1:setPosition(-200,0)
	local des2 = cc.Sprite:create(self._root.."des1.png")
	content:addChild(des2)
	des2:setScaleX(-1)
	des2:setPosition(230,0)
	local text = cc.Sprite:create(self._root.."des2.png")
	content:addChild(text)
	text:setPosition(15,0)
	des1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2),cc.FadeIn:create(2))))
	des2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2),cc.FadeIn:create(2))))
	text:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2),cc.FadeIn:create(2))))

end
-- 中层
function YinDaoSelectHeroLayer:initMiddleLayer()
	-- 中层容器
	local middleLayer = XTHD.createSprite()
	middleLayer:setCascadeOpacityEnabled( true )
	middleLayer:setOpacity( 0 )
	middleLayer:setContentSize( self._size )
	middleLayer:setPosition( self._size.width/2, self._size.height/2 )
	self:addChild( middleLayer, 2 )
	self._middleLayer = middleLayer
	-- 线
	local tipLine = XTHD.createSprite( self._root.."line.png" )
	tipLine:setCascadeOpacityEnabled( true )
	middleLayer:addChild( tipLine )
	self._tipLine = tipLine
	-- 提示背景
	local tipBg = XTHD.createSprite( self._root.."tipBg.png" )
	tipBg:setCascadeOpacityEnabled( true )
	middleLayer:addChild( tipBg )
	-- tipBg:setOpacity(0)
	self._tipBg = tipBg
	-- 英雄属性
	local heroTypeSp = XTHD.createSprite()
	heroTypeSp:setCascadeOpacityEnabled( true )
	middleLayer:addChild( heroTypeSp )
	self._heroTypeSp = heroTypeSp
	-- 英雄名字
	local heroNameLabel = XTHD.createLabel({
		fontSize = 20,
		color = XTHD.resource.color.purple_desc,--cc.c3b( 147, 87, 9 ),
	})
	heroNameLabel:setCascadeOpacityEnabled( true )
	middleLayer:addChild( heroNameLabel )
	self._heroNameLabel = heroNameLabel
	-- 英雄介绍
	local heroTipLabel = XTHD.createLabel({
		fontSize = 18,
		color = XTHD.resource.color.gray_desc,
	})
	heroTipLabel:setCascadeOpacityEnabled( true )
	middleLayer:addChild( heroTipLabel )
	self._heroTipLabel = heroTipLabel
end
-- 顶层
function YinDaoSelectHeroLayer:initTopLayer()
	-- 顶层容器
	local topLayer = XTHD.createSprite()
	topLayer:setContentSize( self._size )
	topLayer:setPosition( self._size.width/2, self._size.height/2 )
	self:addChild( topLayer, 3 )
	-- 抓手
	local tongs = sp.SkeletonAnimation:create( self._root.."zhua.json", self._root.."zhua.atlas", 1.0 )
	tongs:setPosition( self._size.width/2, self._size.height/2 + 160 )
	topLayer:addChild( tongs )
	self._tongs = tongs
	-- 按钮高度
	local _height = 70
	-- 左按钮
	local leftBtn_normal = XTHD.createSprite( self._root.."arrow_up.png" )
	local leftBtn_selected = XTHD.createSprite( self._root.."arrow_down.png" )
	local leftBtn = XTHD.createButton({
		normalNode = leftBtn_normal,
		selectedNode = leftBtn_selected,
		pos = cc.p( 70, _height ),
		endCallback = function()
			if self._clickable and self._index > 1 then
				self:clickLRBtnCallback( true )
			end
		end
	})
	topLayer:addChild( leftBtn )
	leftBtn:setScale( 0 )
	self._leftBtn = leftBtn
	-- 右按钮
	local rightBtn_normal = XTHD.createSprite( self._root.."arrow_up.png" )
	rightBtn_normal:setFlippedX( true )
	local rightBtn_selected = XTHD.createSprite( self._root.."arrow_down.png" )
	rightBtn_selected:setFlippedX( true )
	local rightBtn = XTHD.createButton({
		normalNode = rightBtn_normal,
		selectedNode = rightBtn_selected,
		pos = cc.p( 187, _height ),
		endCallback = function()
			if self._clickable and self._index < 3 then
				self:clickLRBtnCallback( false )
			end
		end
	})
	topLayer:addChild( rightBtn )
	rightBtn:setScale( 0 )
	self._rightBtn = rightBtn
	
end
-- 显示介绍
function YinDaoSelectHeroLayer:showTip()
	-- 阴影层
	local shadow_time = 0.5
	-- self._shadowLayer:runAction(
	-- 	cc.FadeTo:create(
	-- 		shadow_time, 150
	-- 	)
	-- )
	-- 英雄高亮
	-- self.texiao[self._index]:setVisible(true)
	-- self._hero[self._index]:setLocalZOrder( 3 )
	-- 弹窗
	local middle_time = 0.5
end
-- 隐藏提示
function YinDaoSelectHeroLayer:hideTip( ensureFlag )
	-- 弹窗
	local middle_time = 0.3
	-- self._middleLayer:stopAllActions()
	-- self._middleLayer:runAction(
	-- 	cc.FadeOut:create(
	-- 		middle_time
	-- 	)
	-- )
	-- 选中英雄不移除阴影层，英雄显示高亮
	if not ensureFlag then
		-- 阴影层
		local shadow_time = 0.3
		-- self._shadowLayer:runAction(
		-- 	cc.FadeOut:create(
		-- 		shadow_time
		-- 	)
		-- )
		-- 英雄
		self._hero[self._index]:setLocalZOrder( 1 )
		self.texiao[self._index]:setVisible(false)
	end
end
-- 开始动画
function YinDaoSelectHeroLayer:initAction()
	-- 传送带动作
	-- local speed = 5
	local width = self._conveyer_1:getContentSize().width
	self._conveyer_1:runAction(
		cc.RepeatForever:create(
			cc.Sequence:create(
				cc.MoveBy:create(
					speed, cc.p( -width, 0 )
				),
				cc.CallFunc:create(
					function()
						self._conveyer_1:setPositionX( width )
					end
				),
				cc.MoveBy:create(
					speed, cc.p( -width, 0 )
				)
			)
		)
	)
	self._conveyer_2:runAction(
		cc.RepeatForever:create(
			cc.Sequence:create(
				cc.MoveBy:create(
					speed*2, cc.p( -width*2, 0 )
				),
				cc.CallFunc:create(
					function()
						self._conveyer_2:setPositionX( width )
					end
				)
			)
		)
	)
	-- 爪子
	local tongs_delay = 1
	local tongs_time = 0.3
	self._tongs:runAction(
		cc.Sequence:create(
			-- 延时
			cc.DelayTime:create(
				tongs_delay
			),
			-- 位移
			cc.EaseOut:create(
				cc.MoveTo:create(
					tongs_time, cc.p( self._size.width/2, self._size.height/2 )
				), 3
			)
		)
	)
	-- 点击左右箭头切换英雄
	local arrowLabel_delay = tongs_delay + tongs_time
	local arrowLabel_time = 0.5
	self._arrowLabel:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(
				arrowLabel_delay
			),
			cc.FadeIn:create(
				arrowLabel_time
			)
		)
	)
	-- 左移按钮
	local left_delay = tongs_delay + tongs_time
	local left_big_time = 0.3
	local left_small_time = 0.1
	self._leftBtn:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(
				left_delay
			),
			cc.ScaleTo:create(
				left_big_time, 1.2
			),
			cc.ScaleTo:create(
				left_small_time, 1
			)
		)
	)
	-- 右移按钮
	local right_delay = left_delay + 0.1
	local right_big_time = 0.3
	local right_small_time = 0.1
	self._rightBtn:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(
				right_delay
			),
			cc.ScaleTo:create(
				right_big_time, 1.2
			),
			cc.ScaleTo:create(
				right_small_time, 1
			)
		)
	)
	-- 确定按钮
	local ensure_delay = right_delay + 0.1
	local ensure_big_time = 0.3
	local ensure_small_time = 0.1
	self._ensureBtn:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(
				ensure_delay
			),
			cc.ScaleTo:create(
				ensure_big_time, 1.2
			),
			cc.ScaleTo:create(
				ensure_small_time, 1
			)
		)
	)
	-- 显示介绍
	local tip_delay = tongs_delay + tongs_time
	self:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(
				tip_delay
			),
			cc.CallFunc:create(
				function()
					self:showTip()
				end
			)
		)
	)
	-- 接收点击
	local click_delay = ensure_delay + ensure_big_time + ensure_small_time
	self:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(
				click_delay
			),
			cc.CallFunc:create(
				function()
					self._clickable = true
				end
			)
		)
	)
end

-- 点击左右逻辑
function YinDaoSelectHeroLayer:clickLRBtnCallback( index )
	self._clickable = false
	print("index2 = " .. index)
	
	
	self:hideTip()
				
	self._index = index
	self:showTip()
	print("self.index = " .. self._index)
			
	self._clickable = true
				
end

-- 点击确定逻辑
function YinDaoSelectHeroLayer:clickEnsureCallback()
	self._clickable = false
	-- self:hideTip( true )
	self:getPet()
end
-- 去后端请求英雄
function YinDaoSelectHeroLayer:getPet()
	ClientHttp:requestAsyncInGameWithParams({
        modules = "guidePet?",
        -- params = {petId = self._heroId[self._index]},
        successCallback = function( backData )
            -- print("新引导选英雄服务器返回的数据为：")
            -- print_r(backData)
            if tonumber( backData.result ) == 0 then
                if backData and backData.addPet then ------更新英雄数据
                    local layer = requires("src/fsgl/layer/QiXingTan/QiXingTanGetNewHeroLayer.lua"):create({
                        par = self,
                        id = backData.addPet.id,
                        star = backData.addPet.starLevel,
                        callBack = function()
							DengLuUtils.UpdateHerosAndEquipmentsData({backData.addPet})
--							print("YinDaoSelectHeroLayer:getPet UpdateHerosAndEquipmentsData")
--							print("@@@@存的:" .. backData.addPet.id)
		                    if self._callback then
		                    	self._callback()
		                    end
                        end
                    })
                end 
            else
                XTHDTOAST(backData.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    })
end

return YinDaoSelectHeroLayer