--[[
	FileName: buyHunyu.lua
	Author: andong
	Date: 2016-1-23
	Purpose: 购买魂玉界面
]]
local buyHunyu = class("buyHunyu", function()
	return XTHDPopLayer:create( { isRemoveLayout = true })
end )
function buyHunyu:ctor(params)
	self:initData(params)
	self:initUI()
	self:show()
end
function buyHunyu:initData(params)
	self._params = params
end
function buyHunyu:initUI()
	local popSize = cc.size(375, 228)
	local popNode = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	popNode:setContentSize(popSize)
	popNode:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self:addContent(popNode)

	local tip1 = XTHDLabel:createWithParams( {
		text = "",
		fontSize = 20,
		color = XTHD.resource.color.brown_desc,
		anchor = cc.p(0.5,0.5),
		pos = cc.p(popSize.width / 2,popSize.height / 2 + 40),
	} )
	popNode:addChild(tip1)
	local tip2 = XTHDLabel:createWithParams( {
		text = "",
		fontSize = 20,
		color = XTHD.resource.color.brown_desc,
		anchor = cc.p(0.5,0.5),
		pos = cc.p(popSize.width / 2,popSize.height / 2),
	} )
	popNode:addChild(tip2)

	local str1 = LANGUAGE_BUY_HUNYU(self._params.buyNeedGold)
	self._str1 = str1
	-- local str2 = LANGUAGE_KEY_HERO_TEXT.buyItemLastCountTextXc..self._params.surplusBuyCount
	-- if tonumber(self._params.surplusBuyCount) <= 0 then
	-- str1 = LANGUAGE_TIPS_WORDS204
	-- str2 = LANGUAGE_TIPS_TILI_NOTIMES
	-- end
	tip1:setString(str1)
	self._tip1 = tip1
	-- tip2:setString(str2)

	local cancel = XTHD.createCommonButton( {
		btnColor = "write_1",
		btnSize = cc.size(130,51),
		isScrollView = false,
		text = LANGUAGE_BTN_KEY.cancel,
		needSwallow = false,
		endCallback = function()
			LayerManager.removeLayout(self)
		end,
		anchor = cc.p(0.5,0),
		pos = cc.p(popSize.width / 2 - 85,25),
	} )
	cancel:setScale(0.8)
	self._cancel = cancel
	popNode:addChild(cancel)

	local buyBtn = XTHD.createCommonButton( {
		btnColor = "write",
		btnSize = cc.size(130,51),
		isScrollView = false,
		text = LANGUAGE_BTN_KEY.sure,
		fontSize = 22,
		fontColor = cc.c3b(255,255,255),
		needSwallow = false,
		endCallback = function()
			self:BuyCallBack()
		end,
		anchor = cc.p(0.5,0),
		pos = cc.p(popSize.width / 2 + 85,25),
	} )
	buyBtn:setScale(0.8)
	self._buyBtn = buyBtn
	popNode:addChild(buyBtn)
	self._buyBtn = buyBtn
	-- if tonumber(self._params.surplusBuyCount) <= 0 then
	--- self._cancel:setVisible(false)
	-- self._buyBtn:setPositionX(popSize.width/2)
	-- self._buyBtn:setTouchEndedCallback(function()
	-- 	LayerManager.removeLayout(self)
	-- end)
	-- end

end

function buyHunyu:BuyCallBack()
	ClientHttp:requestAsyncInGameWithParams( {
		modules = "buyHunyu?",
		-- 接口
		successCallback = function(data)
			if tonumber(data.result) == 0 then
				-- 请求成功
				local show = {
					rewardtype = XTHD.resource.type.soul,
					num = 100,
				}
				ShowRewardNode:create( { show })
				self._buyBtn:setEnable(false)
				self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create( function()
					self._buyBtn:setEnable(true)
				end )))
				-- 更新属性
				if data.playerProperty and #data.playerProperty > 0 then
					for i = 1, #data.playerProperty do
						local pro_data = string.split(data.playerProperty[i], ',')
						DBUpdateFunc:UpdateProperty("userdata", pro_data[1], pro_data[2])
					end
					XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
					-- 刷新数据信息
				end
				if self._params.callback and type(self._params.callback) == "function" then
					self._params.callback(data)
				end
				local str1 = LANGUAGE_BUY_HUNYU(data.buyNeedGold)

				self._tip1:setString(str1)

			else
				XTHDTOAST(data.msg)
				-- 出错信息(后端返回)
			end
		end,
		-- 成功回调
		loadingParent = self,
		failedCallback = function()
			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
			-----"网络请求失败")
		end,
		-- 失败回调
		targetNeedsToRetain = self,
		-- 需要保存引用的目标
		loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
	} )
end

function buyHunyu:create(params)
	return self.new(params)
end

function buyHunyu:onEnter()
end
function buyHunyu:onCleanup()
end
function buyHunyu:onExit()
end

return buyHunyu