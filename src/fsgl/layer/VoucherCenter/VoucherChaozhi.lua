--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local VoucherChongzhi = class("VoucherChongzhi",function()
	local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(705,468)
	return node
end)

function VoucherChongzhi:ctor(parent,data)
	self._parent = parent
	self._vipReward = data.vipReward
	dump(data)
	self._data = gameData.getDataFromCSV( "VipGradeAward" )
	self:refreshData()
	self:init()
end

function VoucherChongzhi:init()
	local _bg = cc.Sprite:create("res/image/newGuild/memberbg.png")
	_bg:setContentSize(450,370)
	self:addChild(_bg)
	_bg:setPosition(self:getContentSize().width *0.6 + 15,self:getContentSize().height *0.6 - 4)
	self._bg = _bg	
	self._bg:setOpacity(0)

	self._talbeView = cc.TableView:create(self._bg:getContentSize())
	self._talbeView:setPosition(0,-2)
    self._talbeView:setBounceable(true)
    self._talbeView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._talbeView:setDelegate()
    self._talbeView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._bg:addChild(self._talbeView)

	local function cellSizeForTable(table,idx)
        return self._talbeView:getContentSize().width,190
    end
    local function numberOfCellsInTableView(table)
        return math.ceil(#self._data/3)
    end
	
    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(self._talbeView:getContentSize().width,190)
        else
            cell:removeAllChildren()
        end
		self:createTableViewCell( idx, cell )
        return cell
    end
	local function tableCellTouched(table,cell)
		print("***************************")
	end
    self._talbeView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._talbeView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
	self._talbeView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._talbeView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
	self._talbeView:reloadData()
	
	local haibao = cc.Sprite:create("res/image/VoucherCenter/haibaobg.png")
	self:addChild(haibao)
	haibao:setScaleX(0.85)
	haibao:setScaleY(0.8)
	haibao:setPosition(self:getContentSize().width *0.5 - 20,haibao:getContentSize().height *0.5 + 5)

	local title = cc.Sprite:create("res/image/VoucherCenter/viplibao/title.png")
	haibao:addChild(title)
	title:setPosition(haibao:getContentSize().width *0.5,haibao:getContentSize().height *0.5)

end

function VoucherChongzhi:createTableViewCell(index,cell)
	for i = 1, 3 do
		local _index = index * 3 + i
		
		local _data = self._data[_index]

		if not _data then
			return
		end

		local cellbg = cc.Sprite:create("res/image/VoucherCenter/cellbg_2.png")
		cell:addChild(cellbg)
		cellbg:setScale(0.9)
		local x = cellbg:getContentSize().width *0.5 + (i - 1) * (cellbg:getContentSize().width + 10)
		cellbg:setPosition(x,cell:getContentSize().height *0.5)

		local itemName = XTHDLabel:create("VIP".._data.viplevel.."礼包",18,"res/fonts/hkys.ttf")
		itemName:setColor(cc.c3b(70,40,0))
		--itemName:enableOutline(cc.c4b(255,230,180,255),1)
		cellbg:addChild(itemName)
		itemName:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height - itemName:getContentSize().height *0.5 - 10)

		local itemBtn = XTHDPushButton:createWithParams({
			normalFile = "res/image/VoucherCenter/viplibao/itemNode.png",
			selectedFile = "res/image/VoucherCenter/viplibao/itemNode.png",
		})
		cellbg:addChild(itemBtn,10)
		itemBtn:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.5 + 10)
		itemBtn:setScale(0.7)
		itemBtn:setTouchEndedCallback(function()
			local layer = requires("src/fsgl/layer/VoucherCenter/ItemNodePop.lua"):create(_data,"chaozhi")
			cc.Director:getInstance():getRunningScene():addChild(layer)
			layer:show()
		end)		

		local _buySum  = string.split(_data.buySum,"#")
		
		local money = XTHDLabel:create(_buySum[2].."元宝",18,"res/fonts/hkys.ttf")
		money:setColor(cc.c3b(70,40,0))
		--money:enableOutline(cc.c4b(255,230,180,255),1)
		cellbg:addChild(money)
		money:setPosition(cellbg:getContentSize().width *0.5,money:getContentSize().height *0.5 + 27)
		
		local buyBtn = XTHDPushButton:createWithParams({
			touchSize =cc.size(cellbg:getContentSize().width,cell:getContentSize().height),
			needEnableWhenMoving = true,
		})
		cellbg:addChild(buyBtn)
		buyBtn:setPosition(cellbg:getContentSize().width *0.5,cellbg:getContentSize().height *0.5)
		
		buyBtn:setTouchBeganCallback(function()
			cellbg:setScale(0.83)
		end)
	
		buyBtn:setTouchMovedCallback(function()
			cellbg:setScale(0.85)
		end)
	
		buyBtn:setTouchEndedCallback(function()
			cellbg:setScale(0.85)
			local _confirmLayer = XTHDConfirmDialog:createWithParams( {
				rightCallback = function ( ... )
					self:buyVipLibao(_index)
				end,
				msg = ("是否花费".._buySum[2].."元宝购买VIP".._data.viplevel.."礼包？")
			} );
			cc.Director:getInstance():getRunningScene():addChild(_confirmLayer,1)
		end)

		if _data.stata == 0 then
			XTHD.setGray(cellbg,true)
			buyBtn:setEnable(false)
		end
	end
end

function VoucherChongzhi:buyVipLibao(index)
	ClientHttp:requestAsyncInGameWithParams( {
        modules = "vipOneReward?",
        params = { level = self._data[index].viplevel},
        successCallback = function(data)
            dump(data,"cliamreward_data")
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                return
            end
            if data["result"] == 0 then
				local show_list = {}
				if data.items then
					for i = 1,#data.items do
						local _data = data.items[i]
						local num = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ITEM,{itemid = _data.itemId}).count or 0 
						local num_1 = _data.count - num
						show_list[#show_list+1] = {rewardtype = 4,id =_data.itemId,num = num_1}
					end
				end

				if data.property then
					for i = 1, #data.property do
						local _data = data.property[i]
						local __data = string.split(_data,",")
						gameUser.updateDataById(__data[1],__data[2])
					end
				end
				self._vipReward = data.vipReward
				self:refreshData()
				self._talbeView:reloadData()
				ShowRewardNode:create(show_list)
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
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

function VoucherChongzhi:refreshData()
	for i = 1, #self._data do
		self._data[i].stata = 1
	end	

	for i = 1, #self._data do
		for j = 1, #self._vipReward do
			if self._vipReward[j] == self._data[i].viplevel then
				self._data[i].stata = 0
			end
		end
	end
end

function VoucherChongzhi:create(parent,data)
	return VoucherChongzhi.new(parent,data)
end

return VoucherChongzhi

--endregion
