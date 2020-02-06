-- Create By hezhitao 2015年07月16日
-- VIP特权界面
local VipRewardLayer1 = class("VipRewardLayer1", function()
   return XTHDPopLayer:create()
end )

function VipRewardLayer1:ctor(data,parent)
	self._parent = parent
    self:initUI(data)
    -- 添加监听事件
    XTHD.addEventListener( {
        name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG,
        callback = function()
            -- print(" REFRESH_RECHARGE_MSG =============== ")
            XTHD.setVIPRewardExist(false)
            XTHD.createVipLayer(self:getParent(), self, 2)
        end
    } )
end

function VipRewardLayer1:initUI(data)
    XTHD.setVIPRewardExist(true)
	self._left_arrow = nil
    self._right_arrow = nil
    self._cell_tab = { }
    self.__cell_tab = { }
    self._already_cliam_reward = { }
    self._vip = 1
    -- 记录当前混动到的vip

    self._already_cliam_reward = data["vipReward"]
    self:dealDateForCell()

    
    local center = cc.Sprite:create("res/image/VoucherCenter/VipReward/bg.png")
    center:setAnchorPoint(0.5, 0.5)
    center:setPosition(self:getContentSize().width * 0.5,self:getContentSize().height * 0.5)
    self:addContent(center)
	self._centerBg = center
	
	local btn_close = XTHDPushButton:createWithParams({
		normalFile = "res/image/VoucherCenter/VipReward/btn_close_1.png",
		selectedFile = "res/image/VoucherCenter/VipReward/btn_close_2.png",
	})
	self._centerBg:addChild(btn_close)
	btn_close:setPosition(self._centerBg:getContentSize().width - btn_close:getContentSize().width *0.5,self._centerBg:getContentSize().height - btn_close:getContentSize().height *0.5 - 48)
	btn_close:setTouchEndedCallback(function()
		self:hide()
	end)

	local size = center:getContentSize()

    local background = cc.Sprite:create()
    background:setContentSize(cc.size(self._centerBg:getContentSize().width -3, 470))
    background:setPosition(size.width / 2, size.height / 2 - 32)
    self._centerBg:addChild(background)


    local newInfobg = cc.Sprite:create()
    newInfobg:setContentSize(cc.size(self._centerBg:getContentSize().width , self._centerBg:getContentSize().height))
    newInfobg:setAnchorPoint(1,0.5)
    newInfobg:setPosition(size.width,background:getContentSize().height/2)
    self._centerBg:addChild(newInfobg)

    -- 在充值多少的背景
    self._vip_bg = ccui.Scale9Sprite:create("res/image/VoucherCenter/VipRecharge/chongzhikuang.png")
    self._vip_bg:setAnchorPoint(0.5,0.5)
    self._vip_bg:setPosition(self._centerBg:getContentSize().width *0.45,self._vip_bg:getContentSize().height + 45)
    self._centerBg:addChild(self._vip_bg,2)

    local tableBg = ccui.Scale9Sprite:create("res/image/vip/chongzhi_scale9.png")
    tableBg:setContentSize(cc.size(self._centerBg:getContentSize().width * 0.8, self._centerBg:getContentSize().height *0.6 + 10))
    tableBg:setAnchorPoint(0.5,0.5)
	tableBg:setOpacity(0)
    tableBg:setPosition(self._centerBg:getContentSize().width *0.5 - 2,self._centerBg:getContentSize().height *0.5 + 15)
    self._centerBg:addChild(tableBg)
	self._tableBg = tableBg

    -- 当前vip等级，如果不是vip用户，则进入界面后，显示vip1的界面
    local current_vip = gameUser.getVip()
    if current_vip and tonumber(current_vip) >= 1 then
        vip = tonumber(current_vip)
    end
    self:dealDateForCell(vip)
    self._vip = self:ungetVip(data)

    local initPosx = 30
    if size.width < 1000 then
        initPosx = 5
    end

    -- 再充多少元宝到达的下一个vip
    local total_gold = gameUser.getIngotTotal()
    -- 当前玩家充值元宝总数量
    local vip_data = gameData.getDataFromCSV("VipInfo", { id = 1 }) or { }
    local gold_number = 0
    -- 还差多少元宝升级到下一vip
    -- local next_gold_num = vip_data["vip"..(vip+1)] or 1   --到下一vip需要充值的总元宝数
    local next_gold_num = vip_data["vip" ..(tonumber(gameUser.getVip()) + 1)] or 1
    -- 到下一vip需要充值的总元宝数
    if next_gold_num ~= nil then
        gold_number = tonumber(next_gold_num) - tonumber(total_gold)
        if gold_number > 100000 then
            gold_number = getHugeNumberWithLongNumber(tonumber(gold_number))
        end
    end

    -- 元宝数量
    local gold_num = XTHDLabel:createWithParams( {
        text = gold_number,
        fontSize = 22,
        color = cc.c3b(28,71,80),
        ttf = "res/fonts/hkys.ttf"
    } )
    gold_num:setAnchorPoint(0, 0.5)
    gold_num:setPosition(self._vip_bg:getContentSize().width *0.35 + 5, self._vip_bg:getContentSize().height *0.5 - 3)
    self._vip_bg:addChild(gold_num)

    -- 下个vip级别
    if gameUser.getVip() < 17 then
			if gameUser.getVip() < 10 then
			local next_vip = cc.Sprite:create("res/image/vip/vip_" .. tonumber(gameUser.getVip()).. ".png")
			next_vip:setAnchorPoint(0,0.5)
			next_vip:setPosition(self._vip_bg:getContentSize().width*0.75 + 5, self._vip_bg:getContentSize().height *0.5)
			self._vip_bg:addChild(next_vip)
			next_vip:setScale(0.6)
		else
			local vip_index = tonumber(gameUser.getVip() - 10)
			local next_vip = cc.Sprite:create("res/image/vip/vip_1.png")
			next_vip:setAnchorPoint(0,0.5)
			next_vip:setPosition(self._vip_bg:getContentSize().width*0.7 + 20, self._vip_bg:getContentSize().height *0.5)
			self._vip_bg:addChild(next_vip)
			next_vip:setScale(0.6)
	
			local next_vip_2 = cc.Sprite:create("res/image/vip/vip_" .. vip_index ..".png")
			next_vip_2:setAnchorPoint(0,0.5)
			next_vip_2:setPosition(next_vip:getPositionX()+next_vip:getContentSize().width *0.5,next_vip:getPositionY())
			self._vip_bg:addChild(next_vip_2)
			next_vip_2:setScale(0.6)
		end
	end

    -- vip进度条背景
    local bar_bg = cc.Sprite:create("res/image/VoucherCenter/VipRecharge/barbg.png")
    bar_bg:setPosition(self._vip_bg:getPositionX(), self._vip_bg:getPositionY() - self._vip_bg:getContentSize().height*0.5 - bar_bg:getContentSize().height *0.5)
    self._centerBg:addChild(bar_bg)

    -- vip进度条
    local progress_bar = cc.ProgressTimer:create(cc.Sprite:create("res/image/VoucherCenter/VipRecharge/bar.png"))
    progress_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress_bar:setMidpoint(cc.p(0, 0))
    progress_bar:setBarChangeRate(cc.p(1, 0))
    progress_bar:setPosition(cc.p(bar_bg:getContentSize().width / 2, bar_bg:getContentSize().height / 2))
    progress_bar:setPercentage(0)
    bar_bg:addChild(progress_bar)

    progress_bar:runAction(cc.ProgressTo:create(0.3, total_gold / next_gold_num * 100))

    -- 判断VIP是否满级
    if vip == 17 then
        self._vip_bg:removeAllChildren()
        -- vip满级信息
        local full_vip_msg = XTHDLabel:createWithParams( {
            text = LANGUAGE_TIPS_WORDS198,
            ------"恭喜你,你的VIP等级已经达到最高级",
            fontSize = 22,
            color = cc.c3b(178,27,27),
            anchor = cc.p(0.5,0.5),
        } )
        full_vip_msg:setPosition(self._vip_bg:getPositionX(),self._vip_bg:getPositionY() - 5)
		self._centerBg:addChild(full_vip_msg)
		self._vip_bg:setVisible(false)
    else
        self._vip_bg:setVisible(true)
    end

    -- 充值按钮
    local recharge_btn = XTHDPushButton:createWithParams({
		normalFile = "res/image/VoucherCenter/VipReward/btn_vip_1.png",
		selectedFile = "res/image/VoucherCenter/VipReward/btn_vip_2.png",
	})
    recharge_btn:setAnchorPoint(0.5, 0.5)
    local adaptationX = 5
    if self:getContentSize().width > 1000 then
        adaptationX = 50
    end
    recharge_btn:setPosition(self._centerBg:getContentSize().width *0.8, self._centerBg:getContentSize().height *0.15 + 5)
    self._centerBg:addChild(recharge_btn)
    recharge_btn:setTouchEndedCallback( function()
		self._parent:SwichVoucherNode(1)
		self:removeFromParent()
    end )

	local tishi = cc.Sprite:create("res/image/VoucherCenter/VipReward/tishi.png")
	self._centerBg:addChild(tishi)
	tishi:setPosition(recharge_btn:getPositionX(),recharge_btn:getPositionY() - recharge_btn:getContentSize().height)

	local myvip = cc.Sprite:create("res/image/VoucherCenter/VipReward/vip_bg.png")
	myvip:setAnchorPoint(0.5,0)
	myvip:setPosition(self._centerBg:getContentSize().width *0.15,recharge_btn:getPositionY() - recharge_btn:getContentSize().height *0.5 - 30)
	self._centerBg:addChild(myvip,1)

    local myviplevel = cc.Sprite:create("res/image/VoucherCenter/VipReward/vip_" .. tonumber(gameUser.getVip()) .. ".png")
    myviplevel:setAnchorPoint(0.5,0) 
    myviplevel:setPosition(myvip:getContentSize().width *0.5,myvip:getContentSize().height *0.5)
    myvip:addChild(myviplevel,1)

    local current_max_vip = 17
    local bsize = tableBg:getContentSize()
    self.psize = cc.size(bsize.width - 6, bsize.height)
	
				-- 左右箭头
    local left_arrow = XTHDPushButton:createWithParams( {
        normalFile = "res/image/common/arrow_left_normal.png",
        selectedFile = "res/image/common/arrow_left_selected.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        touchSize = cc.size(80,80)
    } )
	left_arrow:setScale(1.2)
    left_arrow:setPosition(20 + left_arrow:getContentSize().width *1.2 *0.5, tableBg:getContentSize().height*3/4-70)
    tableBg:addChild(left_arrow,2)

    local right_arrow = XTHDPushButton:createWithParams( {
        normalFile = "res/image/common/arrow_right_normal.png",
        selectedFile = "res/image/common/arrow_right_selected.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        touchSize = cc.size(80,80)
    } )
	right_arrow:setScale(1.2)
    right_arrow:setPosition(tableBg:getContentSize().width - 20 - right_arrow:getContentSize().width * 1.2 *0.5, left_arrow:getPositionY())
    tableBg:addChild(right_arrow,2)

    left_arrow:setTouchEndedCallback( function()
        self.pager:scrollToLast()
    end )

    right_arrow:setTouchEndedCallback( function()
        self.pager:scrollToNext()
    end )

    self._left_arrow = left_arrow
    self._right_arrow = right_arrow

	local lastVip = cc.Sprite:create("res/image/vip/vipl_01.png")
	tableBg:addChild(lastVip)
	lastVip:setPosition(self._left_arrow:getPositionX(),self._left_arrow:getPositionY() - self._left_arrow:getContentSize().height *0.5 - 10)
	lastVip:setScale(0.6)
	self._lastVip = lastVip

	local nextVip = cc.Sprite:create("res/image/vip/vipl_01.png")
	tableBg:addChild(nextVip)
	nextVip:setPosition(self._right_arrow:getPositionX(),self._right_arrow:getPositionY() - self._right_arrow:getContentSize().height *0.5 - 10)
	nextVip:setScale(0.6)
	self._nextVip = nextVip

    local pager = ccui.PageView:create()
    PageViewPlug.init(pager)
    pager:setContentSize(self.psize)
	pager:setTouchEnabled(false)
    pager:setPosition(5, -0.5)
    tableBg:addChild(pager)
    self.pager = pager

    pager:onLoadListener( function(page,index)
        -- 左边背景框
        local left_background = ccui.Scale9Sprite:create("res/image/VoucherCenter/VipReward/cellbg.png")
        left_background:setAnchorPoint(0, 0)
        left_background:setContentSize(self.psize.width, self.psize.height)
        -- left_background:setAnchorPoint(0,0.5)
		left_background:setOpacity(0)
        left_background:setPosition(0, 0)
		self._left_background = left_background
        page:addChild(left_background)

        local left_top_bar = cc.Sprite:create()
        left_top_bar:setContentSize(cc.size(left_background:getContentSize().width, 35))
        left_top_bar:setAnchorPoint(0, 1)
        left_top_bar:setPosition(0, left_background:getContentSize().height)
        left_background:addChild(left_top_bar)
        self:initLeftUI(left_background, index)

--        -- 右边背景框
--        local right_background = ccui.Scale9Sprite:create("res/image/vip/info_scale9.png")
--        right_background:setAnchorPoint(0, 0)
--        right_background:setContentSize(self.psize.width / 2 - 15, self.psize.height*3/4 + 82)
--        right_background:setPosition(self.psize.width / 2 + 4, 6)
--        page:addChild(right_background)

--        local right_top_bar = cc.Sprite:create()
--        right_top_bar:setContentSize(self.psize.width / 2, 35)
--        right_top_bar:setAnchorPoint(0, 1)
--        right_top_bar:setPosition(0, right_background:getContentSize().height)
--        right_background:addChild(right_top_bar)
--        self:initRightUI(right_background, index)
    end )

    pager:onSelectedListener( function(page, index)
		self._vip = index
		self:refreshVipOnArrow(index)
    end )

    pager:reloadData(self._vip,current_max_vip)



    self:checkRewardCliam()
end

-- vip字体和VIP数字  is_big控制是否为大的VIP字体，vip_num是VIP的级别
function VipRewardLayer1:createVipFont(is_big, vip_num)
    local vip_file = ""
    local vip_num_file = ""
    local offset_x = 0
    -- x轴上的偏移量
    local offset_y = 0
    if is_big == true then
        vip_file = "res/image/vip/vip_big.png"
        vip_num_file = ""
        offset_x = 20
        offset_y = 16
    else
        vip_file = "res/image/vip/vip_small.png"
        vip_num_file = "s_"
        offset_y = -3
    end
    local vip_icon = cc.Sprite:create(vip_file)

    if vip_num < 0 then
        vip_num = 0
    end

    -- vip 数字
    local vip_num_sp = XTHD.createSprite()
    -- 一个透明的精灵，用于存放VIP数字，并且通过vip_num的大小确定，vip_num_sp的大小
    if tonumber(vip_num) < 10 then
        local tmp_vip_num = cc.Sprite:create("res/image/vip/vip_" .. vip_num_file .. vip_num .. ".png")
        vip_num_sp:setContentSize(tmp_vip_num:getContentSize().width, tmp_vip_num:getContentSize().height)
        tmp_vip_num:setPosition(vip_num_sp:getContentSize().width / 2, vip_num_sp:getContentSize().height / 2)
        vip_num_sp:addChild(tmp_vip_num)
    else
        local gewei = vip_num % 10
        local shiwei =(vip_num - gewei) / 10
        local gewei_vip_num = cc.Sprite:create("res/image/vip/vip_" .. vip_num_file .. gewei .. ".png")
        local shiwei_vip_num = cc.Sprite:create("res/image/vip/vip_" .. vip_num_file .. shiwei .. ".png")
        vip_num_sp:setContentSize(gewei_vip_num:getContentSize().width + shiwei_vip_num:getContentSize().width, gewei_vip_num:getContentSize().height)

        -- 十位上的数字在前面
        shiwei_vip_num:setPosition(shiwei_vip_num:getContentSize().width / 2, shiwei_vip_num:getContentSize().height / 2)
        vip_num_sp:addChild(shiwei_vip_num)

        gewei_vip_num:setPosition(gewei_vip_num:getContentSize().width + shiwei_vip_num:getContentSize().width / 2 - 5, gewei_vip_num:getContentSize().height / 2)
        vip_num_sp:addChild(gewei_vip_num)
    end

    local sp_bg = XTHD.createSprite()
    sp_bg:setContentSize(vip_icon:getContentSize().width + vip_num_sp:getContentSize().width, vip_icon:getContentSize().height)
    vip_icon:setPosition(vip_icon:getContentSize().width / 2, vip_icon:getContentSize().height / 2)
    sp_bg:addChild(vip_icon)

    vip_num_sp:setPosition(vip_icon:getContentSize().width + vip_num_sp:getContentSize().width / 2 - offset_x, vip_icon:getContentSize().height / 2 - offset_y)
    sp_bg:addChild(vip_num_sp)

    return sp_bg
end

function VipRewardLayer1:initRightUI(right_bg, vip)

    local vip_data = gameData.getDataFromCSV("VipGradeAward", { viplevel = vip })
    if vip_data == nil then
        return
    end
    -- dump(vip_data,"vip_data")

    local offset_x = 14
    local offset_x2 = 8
    if vip > 9 then
        offset_x = 10
        offset_x2 = 15
    end

    local iconBg = cc.Sprite:create("res/image/vip/myvip_bg.png")
    iconBg:setPosition(right_bg:getContentSize().width / 2, right_bg:getContentSize().height - 20)
    iconBg:setScale(0.6)
    right_bg:addChild(iconBg)

    local vipLabel = XTHDLabel:createWithParams( {
        text = LANGUAGE_KEY_VIP_REWARD(VIPLABEL[vip + 1]),
        fontSize = 24,
        color = cc.c3b(19,15,182),
        anchor = cc.p(0.5,0.5),
        pos = cc.p(iconBg:getContentSize().width / 2,iconBg:getContentSize().height / 2),
    } )
    iconBg:addChild(vipLabel)

    local name_tab = { }
    name_tab["type2"] = LANGUAGE_KEY_GOLD
    ----- "银两"
    name_tab["type6"] = LANGUAGE_KEY_JADE
    ------ "翡翠"
    name_tab["type30"] = LANGUAGE_KEY_DRAGON
    ------"轩辕"
    name_tab["type31"] = LANGUAGE_KEY_TIGER
    ------"盘古"
    name_tab["type32"] = LANGUAGE_KEY_VERMILION
    ----------"伏羲"
    name_tab["type33"] = LANGUAGE_KEY_TORTOISE
    -----------"昆仑"

    for i = 1, tonumber(vip_data["rewordnum"]) do
        local x = i % 2 == 0 and right_bg:getContentSize().width / 4 * 3 - 10 or right_bg:getContentSize().width / 4 + 10
        local y = i < 3 and right_bg:getContentSize().height / 4 * 3 - 5 or right_bg:getContentSize().height / 4 + 30 + 30
        local itemid = vip_data["reward" .. i .. "ID"]
        local itemtype = vip_data["reward" .. i .. "type"]
        if not itemid or not itemtype then
            return
        end
        local item = ItemNode:createWithParams( {
            itemId = itemid,
            _type_ = itemtype,
            count = vip_data["reward" .. i .. "Num"],
        } )
        item:setScale(0.8)
        item:setPosition(x, y)
        right_bg:addChild(item)

        local item_name_str = ""
        local item_type = vip_data["reward" .. i .. "type"]
        if tonumber(item_type) ~= 4 then
            item_name_str = name_tab["type" .. item_type]
        else
            item_name_str = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = vip_data["reward" .. i .. "ID"] })["name"] or ""
        end

        local item_name = XTHDLabel:createWithParams( {
            text = item_name_str,
            fontSize = 16,
            color = cc.c3b(54,55,112),
        } )
        item_name:setPosition(x, y - 55)
        right_bg:addChild(item_name)

        -- 添加特效
        function add_effect(...)
            -- local xingxing_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/teshu.json", "res/spine/effect/exchange_effect/teshu.atlas",1 )
            -- xingxing_effect:setPosition(x,y)
            -- right_bg:addChild(xingxing_effect)
            -- xingxing_effect:setAnimation(0,"animation",true)
            local sp = XTHD.createSprite("res/image/vip/effect/effect1.png")
            item:addChild(sp)
            sp:setPosition(item:getContentSize().width / 2 - 1, item:getContentSize().height / 2 + 2)
            local xingxing_effect = getAnimation("res/image/vip/effect/effect", 1, 8, 1 / 10)
            -- 点击
            sp:setScale(0.9)
            sp:runAction(cc.RepeatForever:create(xingxing_effect))
        end

        -- 品级大于等于紫色的，要显示特效
        if tonumber(itemtype) == 4 then
            local item_quality = gameData.getDataFromCSV("ArticleInfoSheet", { itemid = itemid })["rank"] or 1
            print(item_quality, "item_quality")
            if tonumber(item_quality) >= 4 then
                add_effect()
            end
        end

        if tonumber(itemtype) >= 30 then
            add_effect()
        end

    end


    if vip <= gameUser.getVip() then
        -- 判断是否领取
        local already_cliam_flag = false
        for i = 1, #self._already_cliam_reward do
            local flag = self._already_cliam_reward[i]
            if vip == flag then
                already_cliam_flag = true
            end
        end

        -- 已领取
        if already_cliam_flag == true then
            local already_cliam = cc.Sprite:create("res/image/vip/yibuy.png")
            already_cliam:setPosition(right_bg:getContentSize().width / 2, right_bg:getContentSize().height/2 - 135)
            right_bg:addChild(already_cliam)
			already_cliam:setScale(0.6)
        else
            local gold_icon = cc.Sprite:create("res/image/common/common_gold.png")
            gold_icon:setAnchorPoint(0, 0.5)

            -- -- 元宝数量
            local needGold = string.split(vip_data.buySum,'#')
            local gold_num = cc.Label:createWithBMFont("res/fonts/whitered_.fnt", tonumber(needGold[2]))
            gold_num:setAnchorPoint(0, 0.5)
            local layout = cc.Node:create()
    
            local _size = cc.size(gold_icon:getContentSize().width + gold_num:getContentSize().width + 10, gold_icon:getContentSize().height + 10)
            layout:setContentSize(_size)
            layout:setAnchorPoint(cc.p(0.5,0.5))
            layout:setPosition(right_bg:getContentSize().width / 2 - 40, 70)
            layout:setScale(0.7)
            
            layout:addChild(gold_icon)
            layout:addChild(gold_num)
            gold_icon:setPosition(layout:getContentSize().width *0.5 + 5,layout:getContentSize().height*0.5)
            gold_num:setPosition(gold_icon:getPositionX() + gold_icon:getContentSize().width,layout:getContentSize().height*0.5 -7)
            right_bg:addChild(layout)

            local cliam_btn = XTHD.createCommonButton( {
                text = "可购买",
                isScrollView = false,
                btnSize = cc.size(180,46),
            } )
			cliam_btn:setScale(0.6)
            cliam_btn:setPosition(right_bg:getContentSize().width / 2, 40)
            right_bg:addChild(cliam_btn)
            cliam_btn:setTouchEndedCallback( function()
                local _dialog = XTHDConfirmDialog:createWithParams({
                    msg = "确定购买该档VIP礼包嘛？",
                    rightCallback = function()
                        self:cliamReward(cliam_btn, right_bg,layout)
                    end
                })
                self:addChild(_dialog)
            end )
			local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
			cliam_btn:addChild( fetchSpine )
			fetchSpine:setPosition( cliam_btn:getBoundingBox().width*0.5+27, cliam_btn:getContentSize().height/2+20-17 )
			fetchSpine:setAnimation( 0, "querenjinjie", true )
			fetchSpine:setScaleY(0.8)
        end

    else
        local can_not_cliam = XTHDLabel:createWithParams( {
            text = LANGUAGE_TIPS_WORDS199,
            -------"VIP等级不足,不能领取",
            fontSize = 18,
            color = cc.c3b(54,55,112)
        } )
        can_not_cliam:setPosition(right_bg:getContentSize().width / 2, 40)
        right_bg:addChild(can_not_cliam)
    end
end

function VipRewardLayer1:initCell(cell, idx)

    -- local item_str = self.__cell_tab[idx]
    -- 659 ,360
    -- 左边背景框
    local bHeight = 352 + 30
    -- local left_background = cc.Sprite:create()
    local left_background = ccui.Scale9Sprite:create("res/image/vip/info_scale9.png")
    left_background:setAnchorPoint(0, 0)
    left_background:setContentSize(340 *(self:getContentSize().width / 1024) -20, bHeight - 10)
    -- left_background:setAnchorPoint(0,0.5)
    left_background:setPosition(2, 1)
    cell:addChild(left_background)

    -- local left_top_bar = ccui.Scale9Sprite:create(cc.rect(15,25,1,1), "res/image/vip/new_top_bar.png")
    local left_top_bar = cc.Sprite:create()
    left_top_bar:setContentSize(cc.size(left_background:getContentSize().width, 35))
    left_top_bar:setAnchorPoint(0, 1)
    left_top_bar:setPosition(0, left_background:getContentSize().height)
    left_background:addChild(left_top_bar)
    self:initLeftUI(left_background, idx)


    -- 右边背景框
    -- local right_background = cc.Sprite:create()
    local right_background = ccui.Scale9Sprite:create("res/image/vip/info_scale9.png")
    right_background:setAnchorPoint(1, 0)
    right_background:setContentSize(cc.size((self._tableWidth - left_background:getContentSize().width - 7), bHeight - 10))
    right_background:setPosition(self._tableWidth - 3, 1)
    cell:addChild(right_background)

    -- local right_top_bar = ccui.Scale9Sprite:create(cc.rect(15,25,1,1), "res/image/vip/new_top_bar.png")
    local right_top_bar = cc.Sprite:create()
    right_top_bar:setContentSize(cc.size(right_background:getContentSize().width, 35))
    right_top_bar:setAnchorPoint(0, 1)
    right_top_bar:setPosition(0, right_background:getContentSize().height)
    right_background:addChild(right_top_bar)

    self:initRightUI(right_background, idx)

    return cell
end

-- 更新箭头上的vip显示
function VipRewardLayer1:refreshVipOnArrow(vip_num)
	if vip_num - 1 >= 1 then
		self._lastVip:setTexture("res/image/vip/vipl_0" .. vip_num - 1 .. ".png")
	end
	if  vip_num + 1 <= 17 then
		self._nextVip:setTexture("res/image/vip/vipl_0" .. vip_num + 1 .. ".png")
	end
    -- 更新箭头上的vip显示
	if vip_num == 1 then
		self._lastVip:setVisible(false)
        self._left_arrow:setVisible(false)
    else
		self._lastVip:setVisible(true)
        self._left_arrow:setVisible(true)
    end

    local current_max_vip = 1
    local current_vip = gameUser.getVip()
    if current_vip < 12 and current_vip >= 0 then
        current_max_vip = 12
    elseif current_vip >= 12 and current_vip < 17 then
        current_max_vip = current_vip + 1
    elseif current_vip == 17 then
        current_max_vip = current_vip
    end

    if vip_num == current_max_vip then
		self._nextVip:setVisible(false)
        self._right_arrow:setVisible(false)
    else
		self._nextVip:setVisible(true)
        self._right_arrow:setVisible(true)
    end

end


-- 更新左边上面vip信息
function VipRewardLayer1:initLeftUI(left_bg, idx)

    -- local tequan = left_bg:getChildByName("vip_icon")
    -- local tequan_font = left_bg:getChildByName("vip_tequan_font")
    -- if tequan ~= nil and tequan_font ~= nil then
    --     tequan:removeFromParent()
    --     tequan_font:removeFromParent()
    -- end
    local offset_x = 14
    local offset_x2 = 8
    if idx > 9 then
        offset_x = 10
        offset_x2 = 14
    end

	local lastFile = nil
	local nextFile = nil

	local jianglibg = cc.Sprite:create("res/image/VoucherCenter/VipReward/bg2.png")
	local vip_level = cc.Sprite:create("res/image/vip/vipl_0"..idx..".png")
	local vip_jieshao = cc.Sprite:create("res/image/VoucherCenter/VipReward/title.png")

	local nodeSize = cc.size(jianglibg:getContentSize().width + vip_level:getContentSize().width + vip_jieshao:getContentSize().width,jianglibg:getContentSize().height)
	
	local node = cc.Node:create()
	node:setContentSize(nodeSize)
	node:setAnchorPoint(0.5,0.5)
	left_bg:addChild(node)
	node:setPosition(left_bg:getContentSize().width *0.5,left_bg:getContentSize().height - node:getContentSize().height *0.5 - 15)

	node:addChild(jianglibg)
	node:addChild(vip_level)
	node:addChild(vip_jieshao)

	jianglibg:setPosition(jianglibg:getContentSize().width *0.5,node:getContentSize().height *0.5)
	vip_level:setPosition(jianglibg:getPositionX() + jianglibg:getContentSize().width *0.5 + vip_level:getContentSize().width *0.5 + 5,node:getContentSize().height *0.5)
	vip_jieshao:setPosition(vip_level:getPositionX() + vip_level:getContentSize().width *0.5 + vip_jieshao:getContentSize().width *0.5 + 5, node:getContentSize().height *0.5)


    -- 遍历数组，确定scrollview的大小
    local scrollview_size = cc.size(left_bg:getContentSize().width - 30, left_bg:getContentSize().height - 30 - node:getContentSize().height*0.6)
    local scrollview_inner_size = scrollview_size
    local _idx = 1
    if idx > 0 and idx < 18 then
        _idx = idx
    else
        _idx = 1
    end
    -- local tmp_tab = self._cell_tab[_idx] or {}
    local tmp_tab = self:compareDataForVip(_idx) or { }
    scrollview_inner_size = cc.size(left_bg:getContentSize().width, #tmp_tab * 31)

    local scrollview = ccui.ScrollView:create()
    scrollview:setTouchEnabled(true)
	scrollview:setScrollBarEnabled(false)
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    scrollview:setContentSize(scrollview_size)
    scrollview:setInnerContainerSize(scrollview_inner_size)
    scrollview:setPosition(10, 0)
    self._left_background:addChild(scrollview)

    local need_gold_label = XTHDLabel:createWithParams( {
        text = LANGUAGE_TIPS_WORDS200,
        -------"需要累计充值元宝：",
        fontSize = 20,
        color = cc.c3b(152,82,19),
        ttf = "res/fonts/def.ttf"
    } )
    need_gold_label:setAnchorPoint(0, 0.5)

    local gold_num = gameData.getDataFromCSV("VipInfo", { id = 1 })["vip" .. _idx] or 0

    local need_gold_num = XTHDLabel:createWithParams( {
        text = gold_num,
        fontSize = 22,
        color = cc.c3b(182,15,19)

    } )
    need_gold_num:setAnchorPoint(0, 0.5)

	local node_2 = cc.Node:create()
	node_2:setContentSize(need_gold_label:getContentSize().width + need_gold_num:getContentSize().width,need_gold_num:getContentSize().height)
	node_2:setAnchorPoint(0.5,0.5)
	scrollview:addChild(node_2)
	node_2:setPosition(scrollview:getContentSize().width *0.5,scrollview:getInnerContainerSize().height - node_2:getContentSize().height)

	node_2:addChild(need_gold_label)
	node_2:addChild(need_gold_num)

	need_gold_label:setPosition(5,node_2:getContentSize().height *0.5)
	need_gold_num:setPosition(need_gold_label:getPositionX() + need_gold_label:getContentSize().width + 5,node_2:getContentSize().height *0.5)	

	local _index = 0
    for i = 1, #tmp_tab do
        local item_data = tmp_tab[i]
        local temp_color = cc.c3b(182, 15, 19)
        local shadow_color = cc.c4b(255, 255, 255, 255)
        local temp_str = tmp_tab[i]
        if item_data["not_same"] ~= nil and item_data["not_same"] == true then
            temp_color = cc.c3b(54, 55, 112)
            shadow_color = cc.c4b(255, 252, 24, 255)
        end

        if temp_str ~= nil and temp_str["string"] ~= nil and string.len(temp_str["string"]) ~= nil then
            temp_str = temp_str["string"]
        end

        local temp_str1 = temp_str
        local kuang = string.sub(temp_str, 1, 3)
        local textStr = string.sub(temp_str1, 4, string.len(temp_str1))
        local stkuangLabr = XTHDLabel:createWithParams( {
            text = i .. ".",
            fontSize = 16,
            color = temp_color,
            ttf = "res/fonts/def.ttf"
        } )
        stkuangLabr:setAnchorPoint(0, 0.5)
        local str = XTHDLabel:createWithParams( {
            text = textStr,
            fontSize = 18,
            color = temp_color,
            ttf = "res/fonts/def.ttf"
        } )	
		str:setAnchorPoint(0,0.5)
		
		local node = cc.Node:create()
		node:setContentSize(stkuangLabr:getContentSize().width + str:getContentSize().width,str:getContentSize().height)
		node:setAnchorPoint(0.5,0.5)
		scrollview:addChild(node)
		node:setPosition(scrollview:getContentSize().width *0.5,scrollview:getInnerContainerSize().height - node:getContentSize().height - node_2:getContentSize().height - (i - 1)* 30 - 20)

		node:addChild(stkuangLabr)
		node:addChild(str)

		stkuangLabr:setPosition(5,node:getContentSize().height *0.5)
		str:setPosition(stkuangLabr:getPositionX() + stkuangLabr:getContentSize().width + 5,node:getContentSize().height *0.5)	
    end
end

-- 比对当前显示VIP与下一VIP奖励的数据
function VipRewardLayer1:compareDataForVip(idx)
    local temp_tab_1 = { }
    local temp_tab_2 = { }
    if idx == 1 then
        return self._cell_tab[idx]
    end

    -- 当前VIP奖励数据
    temp_tab_1 = self._cell_tab[idx]
    -- 前一VIP奖励数据
    temp_tab_2 = self._cell_tab[tonumber(idx) -1]

    -- 存放不相同数据
    local temp_tab_3 = { }
    -- 存放相同数据
    local temp_tab_4 = { }
    -- 存放最总数据
    local temp_tab_5 = { }

    for i = 1, #temp_tab_1 do
        local is_same = false
        local table_1 = { }
        local str_1 = temp_tab_1[i]

        for j = 1, #temp_tab_2 do
            local str_2 = temp_tab_2[j]
            if tostring(str_1) == tostring(str_2) then
                is_same = true
            end

            if is_same == true then
                table_1["string"] = str_2
                table_1["not_same"] = false
                temp_tab_4[#temp_tab_4 + 1] = table_1

                break
            end
        end

        if is_same == false then
            table_1["string"] = str_1
            table_1["not_same"] = true
            temp_tab_3[#temp_tab_3 + 1] = table_1
        end
    end

    for i = 1, #temp_tab_4 do
        temp_tab_3[#temp_tab_3 + 1] = temp_tab_4[i]
    end

    return temp_tab_3

end

-- 领取VIP奖励
function VipRewardLayer1:cliamReward(btn, right_bg,layout)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "vipOneReward?",
        params = { level = self._vip },
        successCallback = function(data)
            -- dump(data,"cliamreward_data")
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                return
            end
            if data["result"] == 0 then
                -- 设置领取按钮状态
                btn:setVisible(false)
                layout:setVisible(false)
                -- local already_cliam = XTHDLabel:createWithParams({
                --     text = "已领取",
                --     fontSize = 20,
                --     color = fontColor
                --     })
                local already_cliam = cc.Sprite:create("res/image/vip/yibuy.png")
                already_cliam:setPosition(right_bg:getContentSize().width / 2, right_bg:getContentSize().height/2 - 135)
                right_bg:addChild(already_cliam)
				already_cliam:setScale(0.6)
                -- 处理领取后的数据
                self._already_cliam_reward[#self._already_cliam_reward + 1] = self._vip
                -- 检测是否还有奖励可领取，如果没有，则把主城红点消失
                self:checkRewardCliam()
                self:showReward(data)
                -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
                -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
            else
                XTHDTOAST(data["msg"])
            end

        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,
        -- 失败回调
        targetNeedsToRetain = node,
        -- 需要保存引用的目标
        loadingParent = node,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function VipRewardLayer1:checkRewardCliam()
    -- 如果self._already_cliam_reward的数组总数跟VIP等级相等，说明VIP奖励已经全部领取完毕，发送通知
    -- print(#self._already_cliam_reward,gameUser.getVip(),"self._vipself._vipself._vipself._vipself._vip")
    if #self._already_cliam_reward >= tonumber(gameUser.getVip()) then
        XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT, data = { name = "vip", visible = false } })
    end
end

-- 进入到本界面后，跳到到可以领取的位置
function VipRewardLayer1:ungetVip(data)
    local vip = gameUser.getVip()
    local vipReward = data["vipReward"] or { }
    for i = tonumber(vip), 1, -1 do
        local tmp_flag = true
        for j = 1, #vipReward do
            if i == vipReward[j] then
                tmp_flag = false
            end
        end
        if tmp_flag == true then
            return i
        end
    end

    return vip == 0 and 1 or vip
end

-- 领取完奖励，要跳转的cell
function VipRewardLayer1:scrollToCliamCell()
    local tmp_tab = self._already_cliam_reward
    local vip = self._vip

    -- 冒泡排序，从小到大
    local tmp_value = tmp_tab[1]
    for i = 1, #tmp_tab do
        for j = 1, #tmp_tab - i do
            if tmp_tab[j] > tmp_tab[j + 1] then
                tmp_value = tmp_tab[j]
                tmp_tab[j] = tmp_tab[j + 1]
                tmp_tab[j + 1] = tmp_value
            end
        end
    end
    -- self._already_cliam_reward = tmp_tab

    -- dump(self._already_cliam_reward,"pop xiao dao da")

    -- 跳到领取cell规则:向后遍历为先，首先查询后边是否有vip奖励可领取，如果没有，则向前查询

    -- 1、向后遍历
    for i = vip, tonumber(gameUser.getVip()) do
        local tmp_flag = true
        for j = 1, #tmp_tab do
            if i == tmp_tab[j] then
                tmp_flag = false
            end
        end
        if tmp_flag == true then
            return i
        end
    end

    -- 2、向前遍历
    for i = vip, 1, -1 do
        local tmp_flag = true
        for j = 1, #tmp_tab do
            if i == tmp_tab[j] then
                tmp_flag = false
            end
        end
        if tmp_flag == true then
            return i
        end
    end

    return self._vip

end

-- 显示奖励信息
function VipRewardLayer1:showReward(data)
    local item_list = data["items"]
    local property_list = data["property"]
    local reward_list = { }

    -- 处理银两和翡翠
    if property_list ~= nil then
        for i = 1, #property_list do
            local property = string.split(property_list[i], ",")
            local tmp_tab = { }
            local num = 0
            if tonumber(property[1]) == 402 then
                -- 银两
                num = tonumber(property[2]) - tonumber(gameUser.getGold())
				if num > 0 then
					tmp_tab["rewardtype"] = XTHD.resource.propertyToType[tonumber(property[1])]
					tmp_tab["num"] = num
					reward_list[#reward_list + 1] = tmp_tab
				end
                gameUser.setGold(property[2])
            elseif tonumber(property[1]) == 418 then
                -- 翡翠
                num = tonumber(property[2]) - tonumber(gameUser.getFeicui())
				if num > 0 then
					tmp_tab["rewardtype"] = XTHD.resource.propertyToType[tonumber(property[1])]
					tmp_tab["num"] = num
					reward_list[#reward_list + 1] = tmp_tab
				end
                gameUser.setFeicui(property[2])
            elseif tonumber(property[1]) == 446 then
                -- 奖牌 446
                num = tonumber(property[2]) - tonumber(gameUser.getBounty())
				if num > 0 then
					tmp_tab["rewardtype"] = XTHD.resource.propertyToType[tonumber(property[1])]
					tmp_tab["num"] = num
					reward_list[#reward_list + 1] = tmp_tab
				end
                gameUser.setBounty(property[2])
            end
        end
    end
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
    -- 刷新topbar数据
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO })
    --- 刷新主城市的，

    -- 拼接数据，为了ShowRewardNode显示
    for i = 1, #item_list do
        local temp_table = { }
        local item = item_list[i]
        local local_count = gameData.getDataFromDynamicDB(gameUser.getUserId(), "item", { itemid = item["itemId"] })
        local item_count = item["count"] or 1
        -- if local_count["count"] then
        --     item_count = tonumber(item["count"]) - tonumber(local_count["count"])
        -- else
        --     item_count = tonumber(item["count"])
        -- end

        if tonumber(item["itemId"]) < 100000 or(tonumber(item["itemId"]) >= 1110011 and tonumber(item["itemId"]) < 1640061) then
            local tmp_num = local_count["count"] or 0
            item_count = tonumber(item["count"]) - tonumber(tmp_num)
        end

        temp_table["rewardtype"] = 4
        temp_table["id"] = item["itemId"]
        temp_table["num"] = item_count

        reward_list[#reward_list + 1] = temp_table
    end

    -- 显示神兽信息
    local gods = data["gods"]
    if gods then
        for i = 1, #gods do
            local item_gods = gods[i]
            local rewardtype = gameData.getDataFromCSV("SuperWeaponUpInfo", { id = item_gods["templateId"] })["_type"]
            local tmp_tab = { }
            tmp_tab["rewardtype"] = rewardtype
            tmp_tab["num"] = 1

            reward_list[#reward_list + 1] = tmp_tab
        end
    end

    -- 领取奖励回调
    local function cliam_callback()
        self._vip = self:scrollToCliamCell()
        self.pager:scrollToPage(self._vip,0)
    end

    -- dump(reward_list,"reward_list")
    ShowRewardNode:create(reward_list, nil, cliam_callback)

    self:saveData(data)
end

-- 保存领取奖励数据
function VipRewardLayer1:saveData(data)
    for i = 1, #data["items"] do
        local item_data = data["items"][i]
        if item_data.count and tonumber(item_data.count) ~= 0 then
            DBTableItem.updateCount(gameUser.getUserId(), item_data, item_data.dbId)
        else
            DBTableItem.deleteData(gameUser.getUserId(), item_data.dbId)
        end
    end

    -- 保存用户属性
    local property = data["property"]
    if property then
        for i = 1, #property do
            local pro_data = string.split(property[i], ',')
            DBUpdateFunc:UpdateProperty("userdata", pro_data[1], pro_data[2])
        end
    end
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
    -- 刷新数据信息

    -- 保存神兽信息
    local gods = data["gods"]
    if gods then
        for i = 1, #gods do
            DBTableArtifact.analysDataAndUpdate(gods[i])
        end
    end
    RedPointManage:reFreshDynamicItemData()
end

function VipRewardLayer1:dealDateForCell()

    self._cell_tab = { }
    local vip = self._vip
    local vip_data = gameData.getDataFromCSV("VipInfo") or { }
    for j = 1, 17 do
        local tmp_tab = { }
        for i = 1, #vip_data do
            local tmp_data = vip_data[i]
            local vip_num = tmp_data["vip" .. j]

            -- vip_num不等于0，表示该vip特权已经开启，如果ftype等于1，表示功能开启，ftype==2表示开启了多少次数 ,id=7为精力上限，已弃用
            if tonumber(vip_num) ~= 0 and tmp_data["id"] ~= 1 and tmp_data["id"] ~= 7 then
                if tonumber(tmp_data["ftype"]) == 1 then
                    local str = tmp_data["functionname"] .. vip_num
                    tmp_tab[#tmp_tab + 1] = str
                elseif tonumber(tmp_data["ftype"]) == 2 then
                    local str = tmp_data["functionname"]
                    tmp_tab[#tmp_tab + 1] = str
                end
            end
        end
        self._cell_tab[#self._cell_tab + 1] = tmp_tab
    end
	print("================",111)
end


function VipRewardLayer1:create(data,parent)
    return VipRewardLayer1.new(data,parent)
end

function VipRewardLayer1:onExit()
end

function VipRewardLayer1:onEnter()

end

function VipRewardLayer1:onCleanup(...)
    XTHD.setVIPRewardExist(false)
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_RECHARGE_MSG)

    for k, v in pairs(self._cell_tab) do
        self._cell_tab[k] = nil
    end

    for k, v in pairs(self.__cell_tab) do
        self.__cell_tab[k] = nil
    end

    self._cell_tab = nil
    self.__cell_tab = nil

	self._left_arrow:removeFromParent()
    self._right_arrow:removeFromParent()
    self._already_cliam_reward = nil
end

return VipRewardLayer1