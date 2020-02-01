--Create By hezhitao 2015年07月16日

local VipRechargeLayer1 = class("VipRechargeLayer1",function ()
    return XTHD.createBasePageLayer({
        isScale = true,
        isShadow = true,
        showGF = false,
        showPlus = false,
        bg = "res/image/vip/newBg.jpg"})
end)

function VipRechargeLayer1:ctor(data,isRefresh)
    XTHD.setVIPExist(true)
    self._tableview = nil
    self._right_bg = nil
    self._left_bg = nil
    self._cell_tab = {}
	self._isRefresh = isRefresh

    self._left_arrow = nil 
    self._right_arrow = nil

    self._vip = 1  --记录当前混动到的vip
    self._vip_bg = nil

    self._cell_tab = self:dealDataForVIP(data)
	self._TopData = data
    
    local center = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    center:setAnchorPoint(0.5, 0.5)
    center:setPosition(self:getContentSize().width * 0.5,self:getContentSize().height * 0.5 - self.topBarHeight/2)
    self:addChild(center)
	self._centerBg = center
	
	local title = "res/image/public/chongzhitequan_title.png"
	XTHD.createNodeDecoration(self._centerBg,title)

	local size = self._centerBg:getContentSize()

    local background = cc.Sprite:create()
    background:setContentSize(cc.size(self:getContentSize().width, 470))
    background:setPosition(size.width/2,size.height/2-32)
    self._centerBg:addChild(background)
	
	
   --animal_bg
   local animal_bg = ccui.Scale9Sprite:create("res/image/vip/animal_bg.png")
   animal_bg:setAnchorPoint(0,0.5)
   animal_bg:setPosition(0,animal_bg:getContentSize().height * 0.5 - 62)
   animal_bg:setScale(0.74)
   self._centerBg:addChild(animal_bg)

   --activity
   local thisActivityPath = "res/image/vip/activity_1.png"
   local activity = cc.Sprite:create(thisActivityPath)
   self._centerBg:addChild(activity,1)
   activity:setScale(0.8)
   activity:setAnchorPoint(0.5,0)
   activity:setPosition(355/2,activity:getContentSize().height/2)
   --少府
   local shaofu = cc.Sprite:create("res/image/vip/shaofu.png")
   shaofu:setPosition(50,activity:getPositionY()+activity:getContentSize().height/2+15)
   shaofu:setAnchorPoint(0,0)
   shaofu:setScale(0.75)
   self._centerBg:addChild(shaofu)
   --送项羽
   local song = cc.Sprite:create("res/image/vip/song.png")
   song:setPosition(shaofu:getPositionX()+shaofu:getContentSize().width-20,activity:getPositionY()+activity:getContentSize().height/2+13)
   song:setAnchorPoint(0,0)
   song:setScale(0.75)
   self._centerBg:addChild(song)
   --animal
   local thisAnimaPath = "res/image/vip/animal_1.png"
   local animal = cc.Sprite:create(thisAnimaPath)
   self._centerBg:addChild(animal,0)
   animal:setAnchorPoint(0.5,0)
   animal:setScale(0.7)
   animal:setPosition(361/2, activity:getContentSize().height+100)
   --user vip level

   local myvip = cc.Sprite:create("res/image/vip/myvip.png")
   myvip:setAnchorPoint(0.5,0)
   myvip:setScale(0.7)
   myvip:setPosition(myvip:getContentSize().width * 0.7* 0.55 ,self._centerBg:getContentSize().height - 48 - myvip:getContentSize().height * 0.5)
   self._centerBg:addChild(myvip,1)

    -- local myviplevel = cc.Label:createWithBMFont("res/fonts/viplevel.fnt", tonumber(gameUser.getVip()))
    local myviplevel = cc.Sprite:create("res/image/vip/vipl_0" .. tonumber(gameUser.getVip()) .. ".png")
    myviplevel:setScale(0.9)
    myviplevel:setAnchorPoint(0,0) 

    myviplevel:setPosition(myvip:getPositionX()+myviplevel:getContentSize().width - 45,myvip:getPositionY())
    self._centerBg:addChild(myviplevel,1)

    local newInfobg = cc.Sprite:create()
    newInfobg:setContentSize(cc.size(self._centerBg:getContentSize().width -activity:getContentSize().width , self._centerBg:getContentSize().height))
    newInfobg:setAnchorPoint(1,0.5)
    newInfobg:setPosition(size.width,background:getContentSize().height/2)
    self._centerBg:addChild(newInfobg)

    local newInfoSize = newInfobg:getContentSize()

    local touch = XTHDPushButton:createWithParams({
        touchSize = cc.size(newInfoSize.width-10, 72),
        needSwallow = true,
    })
    touch:setPosition(newInfoSize.width/2-2, newInfoSize.height - 36 )
    newInfobg:addChild(touch,1)

    self._vip_bg = ccui.Scale9Sprite:create("res/image/vip/vip_titile_bg.png")
    self._vip_bg:setContentSize(cc.size(newInfoSize.width+90, 72))
    self._vip_bg:setAnchorPoint(0.5,1)
    self._vip_bg:setPosition(newInfoSize.width/2-2-25,newInfoSize.height - 10)
    self._vip_bg:setScaleX(0.9)
    newInfobg:addChild(self._vip_bg,2)

    -- local tableBg = ccui.Scale9Sprite:create(cc.rect(35,30,1,1), "res/image/vip/table_bg.png")
    local tableBg = ccui.Scale9Sprite:create("res/image/vip/chongzhi_scale9.png")
    tableBg:setContentSize(cc.size(newInfoSize.width + 16, newInfoSize.height - 135))
    tableBg:setAnchorPoint(0.5,0)
    tableBg:setPosition(newInfoSize.width/2-2-27,40)
    newInfobg:addChild(tableBg)

        --当前vip等级，如果不是vip用户，则进入界面后，显示vip1的界面
        local vip = 1
        if tonumber(gameUser.getVip()) >= 1 then
            vip = tonumber(gameUser.getVip())
            self._vip = tonumber(gameUser.getVip())
        end
        

        local tableview = cc.TableView:create( cc.size(tableBg:getContentSize().width-6, tableBg:getContentSize().height ) );
        tableview:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL );
        tableview:setPosition( cc.p(3, 0) );
        tableview:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN );
        tableview:setBounceable(true);
        tableview:setDelegate();
        tableBg:addChild(tableview);
        self._tableview = tableview


        -- tableView注册事件
        local function numberOfCellsInTableView( table )
            return  math.ceil(#self._cell_tab / 3)
        end
        local function cellSizeForTable( table, idx )
            return tableview:getContentSize().width,210
        end
        local function tableCellAtIndex( table, idx )
            local cell = table:dequeueCell();
            if cell == nil then
                cell = cc.TableViewCell:new()
                cell:setContentSize(tableview:getContentSize().width, 210)
            else
                cell:removeAllChildren()
            end
            return self:initCell(cell,idx+1)
        end

        tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
        tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
        tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

        tableview:reloadData()

        --加载当前VIP信息
        self:refreshVIPMsg()


        XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_VIP_MSG ,callback = function()
            self._vip = gameUser.getVip()
            self:refreshVIPMsg()
            self:refreshData()
        end})

        --vip升级时，显示VIP升级
        XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_VIP_SHOW ,callback = function()
            local vip_levelup = requires("src/fsgl/layer/Vip/VipLevelUpLayer1.lua")
            self:addChild(vip_levelup:create())
            myviplevel:setTexture("res/image/vip/vipl_0" ..self._vip.. ".png")
            -- myviplevel:setString(self._vip)
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "vip",["visible"] = true}})
        end})

end


function VipRechargeLayer1:initCell( cell,idx )

        local cellSize = cc.size(self._tableview:getContentSize().width-5, 125)
        
		for i = 1, 3 do
			local _index = (idx - 1)*3+i
			if _index <= #self._cell_tab then
				local cellBg = cc.Sprite:create("res/image/vip/chongzhiCell.png")
				cellBg:setContentSize(cellBg:getContentSize().width + 13,cellBg:getContentSize().height + 15)
				cell:addChild(cellBg)
				local x = 9 + cellBg:getContentSize().width *0.5 + (i - 1)*(cellBg:getContentSize().width + 11)
				cellBg:setPosition(x,cell:getContentSize().height * 0.5)

			
				local item_data = self._cell_tab[_index]
				local needSpbg = cc.Sprite:create("res/image/vip/chongzhibtn.png")
				cellBg:addChild(needSpbg)
				needSpbg:setPosition(cellBg:getContentSize().width/2,needSpbg:getContentSize().height/2+10)
				needSpbg:setName("btn_TopBg")
				--充值按钮
				local first_btn = XTHD.createButton({
					touchSize = cc.size(cellBg:getContentSize().width - 10,cellBg:getContentSize().height - 10),
					musicFile = XTHD.resource.music.effect_btn_common,
					needEnableWhenMoving = true,
					isScrollView = true,
				})
				first_btn:setContentSize(cellBg:getContentSize().width - 10,cellBg:getContentSize().height - 10)
				first_btn:setPosition(cellBg:getContentSize().width/2,cellBg:getContentSize().height/2)
				first_btn:setSwallowTouches(false)
				cellBg:addChild(first_btn)
		
				first_btn:setTouchBeganCallback(function()
					cellBg:setScale(0.9)
				end)
			
				first_btn:setTouchMovedCallback(function()
					cellBg:setScale(1)
				end)

				first_btn:setTouchEndedCallback( function()
					cellBg:setScale(1)
					if item_data.configType == 2 then
						-- 至尊卡
						if tonumber(gameUser._vipRechargeTime.zhizunCard) ~= 0 then
							local restTime = os.time() - gameUser._vipRechargeTime.zhizunCard
							if restTime < 30 then
								-- 30秒的处理订单时间
								restTime = 30 - restTime
								local pop = requires("src/fsgl/layer/Vip/VipTimeTipPop1.lua"):create( { type = item_data.configType, time = restTime })
								LayerManager.addLayout(pop, { noHide = true })
							else
								gameUser._vipRechargeTime.zhizunCard = 0
								XTHD.pay(item_data,nil,self)
								-- self:StoredValue(item_data)
							end
						else
							local confirmDialog = XTHDConfirmDialog:createWithParams( {
								msg = LANGUAGE_KEY_RECHARGE_ONETIMES,
								fontSize = 18,
								rightText = LANGUAGE_TIPS_RECHARGE2,
								rightCallback = function()
									XTHD.pay(item_data,nil,self)
								end,
							} )
							self._centerBg:addChild(confirmDialog, 10)
						end
					elseif item_data.configType == 1 then
						-- 月卡
						if tonumber(gameUser._vipRechargeTime.monthCard) ~= 0 then
							local restTime = os.time() - gameUser._vipRechargeTime.monthCard
							if restTime < 30 then
								restTime = 30 - restTime
								local pop = requires("src/fsgl/layer/Vip/VipTimeTipPop1.lua"):create( { type = item_data.configType, time = restTime })
								LayerManager.addLayout(pop, { noHide = true })
							else
								gameUser._vipRechargeTime.monthCard = 0
								XTHD.pay(item_data)
								XTHD.pay(item_data,nil,self)
							end
						else
							XTHD.pay(item_data,nil,self)
						end
					else
						-- 普通充值
						XTHD.pay(item_data,nil,self)
					end
				end )
			
				self:createCellUi(cellBg,item_data,_index)
					--对月卡和至尊卡特殊处理
				--"monthKa" : 月卡状态 1 : 不能充; 0 : 可以充
				--"dayDiff" : 剩余天数 
				--zhizhunKa : 1:至尊卡生效  2：没有生效

				local month_flag = tonumber(item_data["monthKa"]) or 0
				if month_flag == 1 then
					first_btn:setTouchEndedCallback(function (  )
						cellBg:setScale(1)
						XTHDTOAST(LANGUAGE_FORMAT_TIPS43(item_data["dayDiff"])) -----------"距离可以充值还差:"..item_data["dayDiff"].."天")
					end)
				end
			end
		end


    return cell
end

function VipRechargeLayer1:updateCell()
	ClientHttp:requestAsyncInGameWithParams( {
        modules = "payWindows?",
        successCallback = function(data)
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                return
            end
            if data["result"] == 0 then
				self._TopData = data
				self._tableview:reloadData()
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

function VipRechargeLayer1:createCellUi(cellBg, item_data,index)
	local cellSize = cellBg:getContentSize()
	local btn_Top = cellBg:getChildByName("btn_TopBg")

	local _index = 1
	local _visible = false
	if tonumber(item_data["needRMB"]) == 25 then
		_index = 1
		_visible = true
	elseif tonumber(item_data["needRMB"]) == 98 then
		_index = 1
		_visible = true
	elseif tonumber(item_data["needRMB"]) == 6 then
		_index = 2
		_visible = true
	elseif tonumber(item_data["needRMB"]) == 30 then
		_index = 2
		_visible = true
	elseif tonumber(item_data["needRMB"]) == 68 then
		_index = 2
		_visible = true
	elseif tonumber(item_data["needRMB"]) == 198 then
		_index = 2
		_visible = true
	elseif tonumber(item_data["needRMB"]) == 328 then
		_index = 2
		_visible = true
	elseif tonumber(item_data["needRMB"]) == 648 then
		_index = 2
		_visible = true
	elseif tonumber(item_data["needRMB"]) == 1598 then
		_index = 2
		_visible = true
	else
		_index = 1
		_visible = false
	end

	for k,v in pairs(self._TopData.finishPays) do
		if v == item_data.configId and _index == 2 then
			_visible = false
		end
	end

	-- 推荐图标
	local tuijian_icon = cc.Sprite:create("res/image/vip/jiaobiao_".. _index .. ".png")
	tuijian_icon:setAnchorPoint(0.5,0.5)
	tuijian_icon:setPosition(tuijian_icon:getContentSize().width * 0.5, cellSize.height - tuijian_icon:getContentSize().height*0.5)
	tuijian_icon:setVisible(_visible)
	cellBg:addChild(tuijian_icon)

	if self._TopData.monthTime ~= nil then
		if tonumber(item_data["needRMB"]) == 25 and self._TopData.monthTime > 0 then
			self:stopActionByTag(10)
			tuijian_icon:setTexture("res/image/vip/yigoumai.png")
			local a =  os.time()
			print("=================...",a)
			self._TopData.monthTime = math.ceil(self._TopData.monthTime )
			self._TimeLable = XTHDLabel:create(LANGUAGE_KEY_CARNIVALDAY( self._TopData.monthTime),16,"res/fonts/def.ttf")
			self._TimeLable:setColor(cc.c3b(220,81,36))
			--self._TimeLable:enableOutline(cc.c4b(100,100,100,100),2) 
			cellBg:addChild(self._TimeLable)
			self._TimeLable:setPosition(cellBg:getContentSize().width*0.5,48)
			self:updateTime()
		end
	end

	
	
	local gold_icon = cc.Sprite:create("res/image/common/common_gold.png")
	gold_icon:setAnchorPoint(0, 0.5)

	-- 元宝数量
	local gold_num = cc.Label:createWithBMFont("res/fonts/whitered_.fnt", item_data["needGold"])
	gold_num:setAnchorPoint(0, 0.5)
	
	local node = cc.Node:create()
	node:setContentSize(cellBg:getContentSize())
	cellBg:addChild(node)
	
	local layout = cc.Node:create()
	
	local _size = cc.size(gold_icon:getContentSize().width + gold_num:getContentSize().width + 10, gold_icon:getContentSize().height + 10)
	layout:setContentSize(_size)
	layout:setAnchorPoint(cc.p(0.5,0.5))
	layout:setPosition(cellBg:getContentSize().width * 0.5,cellBg:getContentSize().height - layout:getContentSize().height * 0.5)

	local sp = cc.Sprite:create()
	sp:setContentSize(_size)
	layout:addChild(sp)
	sp:setPosition(0,layout:getContentSize().height - sp:getContentSize().height *0.5)
	
	sp:addChild(gold_icon)
	sp:addChild(gold_num)
	gold_icon:setPosition(layout:getContentSize().width *0.5 + 5,layout:getContentSize().height*0.5)
	gold_num:setPosition(gold_icon:getPositionX() + gold_icon:getContentSize().width,layout:getContentSize().height*0.5 -7)
	cellBg:addChild(layout)
	
	if tonumber(item_data["needRMB"]) == 25 then
		layout:setVisible(false)
		local title = cc.Sprite:create("res/image/vip/title_month.png")
		cellBg:addChild(title)
		title:setPosition(cellBg:getContentSize().width *0.5,cellBg:getContentSize().height - title:getContentSize().height * 0.5 - 10)
	end

	if tonumber(item_data["needRMB"]) == 98 then
		layout:setVisible(false)
		local title = cc.Sprite:create("res/image/vip/title_proper.png")
		cellBg:addChild(title)
		title:setPosition(cellBg:getContentSize().width *0.5,cellBg:getContentSize().height - title:getContentSize().height * 0.5 - 10)
	end
	
	
--	if tonumber(item_data["configType"]) == 1 then
--		gold_num:setVisible(false)
--		gold_icon:initWithFile("res/image/vip/title_month.png")
--	elseif tonumber(item_data["configType"]) == 2 then
--		gold_icon:initWithFile("res/image/vip/title_proper.png")
--	end

--	local desc_2 = XTHDLabel:createWithParams( {
--		text = LANGUAGE_TIPS_WORDS196,
--		------ "(限购1次)",
--		fontSize = 18,
--		color = cc.c3b(153,0,0)
--	} )
--	desc_2:setAnchorPoint(0, 0.5)
--	desc_2:setPosition(gold_icon:getPositionX() + gold_icon:getContentSize().width + 2, gold_icon:getPositionY())
--	cellBg:addChild(desc_2)

--	if tonumber(item_data.expand) == 0 then
--		desc_2:setVisible(false)

--	elseif tonumber(item_data.expand) == 1 then
--		desc_2:setVisible(true)
--	end

	local rmb_num = XTHDLabel:create("￥"..tostring(item_data["needRMB"]),20,"res/fonts/def.ttf")
	rmb_num:setAnchorPoint(0.5, 0.5)
	rmb_num:setColor(XTHD.resource.textColor.yellow_text)
	rmb_num:enableOutline(cc.c4b(103,34,13,255),2) --设置描边
	rmb_num:setPosition(btn_Top:getContentSize().width*0.5, btn_Top:getContentSize().height*0.5)
	btn_Top:addChild(rmb_num)

	-- 礼包图标

	--local icon_path = "res/image/vip/itemNode/" .. item_data.orderId .. ".png"

	local icon_path = "res/image/vip/itemNode/item_" .. item_data.orderId .. ".png"
	if _index == 2 and _visible == true then
		icon_path = "res/image/vip/itemNode/item_" .. item_data.orderId .. "_2.png"
	end

	local item_icon = cc.Sprite:create(icon_path)
	cellBg:addChild(item_icon)
	item_icon:setPosition(cellSize.width*0.5, cellBg:getContentSize().height / 2 + 5)

end

function VipRechargeLayer1:StoredValue(item_data)

    XTHDHttp:requestAsyncWithParams({
        --
        url = XTHD.config.server.url_pay.."pay/produceOrders?serverId="..tostring(gameUser.getServerId()).."&passportId="..tostring(gameUser.getPassportID()).."&charId="..tostring(gameUser.getUserId()).."&payConfigId="..tostring(item_data.configId).."&channel="..tostring(GAME_CHANNEL),
        -- url="http://www.baidu.com?",
        encrypt = HTTP_ENCRYPT_TYPE.NONE,
        successCallback = function(data)
            if data and tonumber(data.result) == 0 then
                local cpOrderId = data.cpOrderId
                local platfromId = data.platfromId
                local payUrl = data.payUrl
                local callbackLua = XTHD.doPayFinish({type=item_data.configType})

                local data = {
                    itemId        = item_data.configId,
                    itemName      = LANGUAGE_KEY_COIN_X(item_data.needGold),
                    itemPrice     = tostring(item_data.needRMB),
                    -- itemPrice     = "0.01",
                    serverId      = tostring(gameUser.getServerId()),
                    orderId       = tostring(cpOrderId),
                    callbackUrl   = tostring(payUrl),
                    accountId     = tostring(gameUser.getPassportID()),
                    roleId        = tostring(gameUser.getUserId()),
                    nickName      = tostring(gameUser.getNickname()),
                    serverName    = tostring(gameUser.getServerName()),
                    level         = tostring(gameUser.getLevel()),
                    vip           = tostring(gameUser.getVip()),
                    ingot         = tostring(gameUser.getIngot()),
                    platfromId    = tostring(platfromId)
                }

                local args = data
                if (cc.PLATFORM_OS_ANDROID == ZC_targetPlatform) then
                    -- local orderId = {
                    --     serverId = gameUser.getServerId(),
                    --     accountId = gameUser.getPassportID(),
                    --     roleId = gameUser.getUserId()
                    -- }
                    --[[--此处需要json.encode转换成字符串，否则java端获取到的是null]]
                    args = { json.encode(data) , callbackLua }
                else
                    --[[--再安卓平台上如果传入callbackLua会报json无法序列化的bug，所以此处单独处理]]
                    data.callback      = callbackLua
                end
                local sigs = "(Ljava/lang/String;I)V"
                XTHD.luaBridgeCall(LUA_BRIDGE_CLASS,"pay",args,sigs)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,
    })
end

function VipRechargeLayer1:refreshVIPMsg(  )
    local _vip_bg = self._vip_bg
    local vip = self._vip
    _vip_bg:removeAllChildren()

    --用于存提示信息和进度条

    local initPosx = 30
    if self:getContentSize().width < 1000 then
        initPosx = 5
    end
    local recharge_label = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_RECHARGEAGIN,------再充值:",
        fontSize = 22,
        color = cc.c3b(153,20,23)
        })
    recharge_label:setAnchorPoint(0,0.5)
    recharge_label:enableShadow(cc.c4b(153, 20, 23, 255),cc.size(0.2,-0.2),0.2)
    recharge_label:setPosition(initPosx,_vip_bg:getContentSize().height-25)
    _vip_bg:addChild(recharge_label)

    local ingot = cc.Sprite:create("res/image/common/header_ingot.png")
    ingot:setAnchorPoint(0,0)
    ingot:setScale(0.7)
    ingot:setPosition(recharge_label:getPositionX() + recharge_label:getContentSize().width + 3, recharge_label:getPositionY() - 14)
    _vip_bg:addChild(ingot)

     --再充多少元宝到达的下一个vip
    local total_gold = gameUser.getIngotTotal() --当前玩家充值元宝总数量
    local vip_data = gameData.getDataFromCSV("VipInfo",{id = 1}) or {}
    local gold_number = 0   --还差多少元宝升级到下一vip
    local next_gold_num = vip_data["vip"..(tonumber(gameUser.getVip())+1)] or 1   --到下一vip需要充值的总元宝数
    if next_gold_num ~= nil then
        gold_number = tonumber(next_gold_num) - tonumber(total_gold)
        if gold_number > 100000 then --如果大于10万，则用大数处理
            gold_number = getHugeNumberWithLongNumber(tonumber(gold_number))
        end 
    end

    --元宝数量
    local gold_num = XTHDLabel:createWithParams({
        text = gold_number,------"元宝",..LANGUAGE_KEY_COIN
        fontSize = 22,
        color = cc.c3b(254,254,139),
        ttf = "res/fonts/def.ttf"
        })
    gold_num:setAnchorPoint(0,0.5)
    -- gold_num:enableShadow(cc.c4b(255, 252, 24, 255),cc.size(0.2,-0.2),0.2)
    gold_num:setPosition(ingot:getPositionX() + ingot:getContentSize().width/2 + 11,recharge_label:getPositionY())
    _vip_bg:addChild(gold_num)

    --可达到的vip
    local can_levelup = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS197,-------"可升级至",
        fontSize = 22,
        color = cc.c3b(153,20,23)
        })
    can_levelup:setAnchorPoint(0,0.5)
    can_levelup:enableShadow(cc.c4b(153, 20, 23, 255),cc.size(0.2,-0.2),0.2)
    can_levelup:setPosition(gold_num:getPositionX()+gold_num:getContentSize().width+3,recharge_label:getPositionY())
    _vip_bg:addChild(can_levelup)

     --下个vip级别
	if gameUser.getVip() < 17 then
		local next_vip = cc.Sprite:create("res/image/vip/vipl_0" .. tonumber(gameUser.getVip())+1 .. ".png")
		next_vip:setAnchorPoint(0,0.5)
		next_vip:setPosition(can_levelup:getPositionX()+can_levelup:getContentSize().width+3,can_levelup:getPositionY())
		_vip_bg:addChild(next_vip)
		next_vip:setScale(0.6)
	end
    
    -- local vipNum = cc.Label:createWithBMFont("res/fonts/yellowred.fnt", tonumber(gameUser.getVip())+1)
    -- vipNum:setAnchorPoint(0,0.5)
    -- vipNum:setPosition(next_vip:getPositionX()+next_vip:getContentSize().width+2,next_vip:getPositionY()-3)
    -- _vip_bg:addChild(vipNum)


    --vip进度条背景
    local bar_bg = cc.Sprite:create("res/image/vip/vip_barBg.png")
    bar_bg:setPosition(400/2 + initPosx,_vip_bg:getContentSize().height-50)
    _vip_bg:addChild(bar_bg)

    --vip进度条
    local progress_bar = cc.ProgressTimer:create(cc.Sprite:create("res/image/vip/vip_bar.png"))
    progress_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress_bar:setMidpoint(cc.p(0, 0))
    progress_bar:setBarChangeRate(cc.p(1, 0))
    progress_bar:setPosition(cc.p(bar_bg:getContentSize().width / 2, bar_bg:getContentSize().height / 2))
    progress_bar:setPercentage(0)
    bar_bg:addChild(progress_bar)

    progress_bar:runAction(cc.ProgressTo:create(0.3,total_gold/next_gold_num*100))

    --判断VIP是否满级
    if vip == 17 then
        _vip_bg:removeAllChildren()
        --vip满级信息
        local full_vip_msg = XTHDLabel:createWithParams({
            text = LANGUAGE_TIPS_WORDS198,--------"恭喜你,你的VIP等级已经达到最高级",
            fontSize = 22,
            color = cc.c3b(178,27,27),
            anchor = cc.p(0, 0.5),
        })
        full_vip_msg:setPosition(cc.p(initPosx, _vip_bg:getContentSize().height/2))
        _vip_bg:addChild(full_vip_msg)
    else
        _vip_bg:setVisible(true)
    end

     --充值按钮
    local recharge_btn = XTHD.createCommonButton({
        text = LANGUAGE_TIPS_VIPSPECIAL,
        isScrollView = false,
        btnSize = cc.size(120, 46),
        btnColor = "write_1"
    })
    recharge_btn:setScale(0.6)
    recharge_btn:setAnchorPoint(1,0.5) 
    local adaptationX = 5
    if self:getContentSize().width > 1000 then
        adaptationX = 50
    end
    recharge_btn:setPosition(_vip_bg:getContentSize().width-adaptationX-20,_vip_bg:getContentSize().height-40)
    _vip_bg:addChild(recharge_btn)
    recharge_btn:setTouchEndedCallback(function (  )
        XTHD.createVipLayer(self:getParent(),self,2)
    end)

end


function VipRechargeLayer1:refreshData(  )
    ClientHttp:requestAsyncInGameWithParams({
        modules = "payWindows?",
        successCallback = function(data)
        if not data or next(data) == nil then
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end
        if data["result"] == 0 then
            self._cell_tab = self:dealDataForVIP(data)
            self._tableview:reloadData()
        else
            XTHDTOAST(data["msg"])
        end

        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,--失败回调
        targetNeedsToRetain = node,--需要保存引用的目标
        loadingParent = node,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })

end

function VipRechargeLayer1:dealDataForVIP(data)

    -- local vip_tab = gameData.getDataFromCSV("StoredValue")
    local vip_csv_tab = data.payList

    table.sort(vip_csv_tab, function(a, b)
        return tonumber(a.orderId) < tonumber(b.orderId)
    end)

    --对月卡数据处理
    if tonumber(data["monthKa"]) == 1 or tonumber(data["monthKa"]) == 0 then
        for k,v in pairs(vip_csv_tab) do
            if tonumber(v.configId) == 7 then
                -- vip_csv_tab[k]["dayDiff"] = data["dayDiff"]
                -- vip_csv_tab[k]["monthKa"] = data["monthKa"]
                table.remove(vip_csv_tab, k)
            end
        end
    end
    --对至尊卡数据处理
                                                        --"monthKa" : 月卡状态 1 : 不能充; 0 : 可以充
                                                        --"dayDiff" : 剩余天数 
                                                        --zhizhunKa : 1:至尊卡生效  0：没有生效
    --对至尊卡数据处理,只能充一次
    if tonumber(data["zhizhunKa"]) == 1 or tonumber(data["zhizhunKa"]) == 0 then
        for k,v in pairs(vip_csv_tab) do
            if tonumber(v.configId) == 8 then
                table.remove(vip_csv_tab, k)
            end
        end
    end 

    --用于审核(去掉月卡和至尊卡)
    if IS_APP_STORE_CHANNAL() then
        for k,v in pairs(vip_csv_tab) do
            if tonumber(v.configId) == 7 then
                table.remove(vip_csv_tab, k)
            end
        end
        for k,v in pairs(vip_csv_tab) do
            if tonumber(v.configId) == 8 then
                table.remove(vip_csv_tab, k)
            end
        end
    end

    return vip_csv_tab
end


function VipRechargeLayer1:create(data)
    return VipRechargeLayer1.new(data)
end


function VipRechargeLayer1:onExit( )
end

function VipRechargeLayer1:onEnter( )

end

function VipRechargeLayer1:onCleanup( ... )
--    if LayerManager.isLayerOpen(1) ~= nil then
--        local node = LayerManager.isLayerOpen(1);
--        node:refreshData();
--    end

    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_VIP_MSG)
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_VIP_SHOW)
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TASKLIST })
    -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_DROPWAYBACK_DATAANDLAYER })
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
    XTHD.setVIPExist(false)
end

function VipRechargeLayer1:updateTime()
	self:stopActionByTag(10)
	schedule(self, function(dt)
		self._TopData.monthTime = self._TopData.monthTime - 1
		self._TimeLable:setString(LANGUAGE_KEY_CARNIVALDAY( self._TopData.monthTime))
  	end,1,10)
end

return VipRechargeLayer1