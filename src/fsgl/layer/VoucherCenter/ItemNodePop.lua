--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ItemNodePop = class("ItemNodePop",function()
	return XTHDPopLayer:create()
end)

function ItemNodePop:ctor(data,key)
	self._data = data
	self._key = key
	dump(self._data)
	self:init()
end

function ItemNodePop:init()
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
	bg:setName("bg")
	bg:setContentSize(cc.size(355,444))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)
	
	local item_img = nil
	local item_name = nil
	if self._key == "fuli" then
		item_img = "res/image/VoucherCenter/fulilibao/fulilibao_" .. self._data.id ..".png"
		item_name = self._data.name
	elseif self._key == "danbi" then
		item_img = "res/image/VoucherCenter/danbi/danbi_" .. self._data.id ..".png"
		item_name = self._data.name
	elseif self._key == "chaozhi" then
		item_img = "res/image/VoucherCenter/viplibao/itemNode.png"
		item_name = "VIP"..self._data.viplevel .."礼包"
	end	

	local itembg = cc.Sprite:create(item_img)
	bg:addChild(itembg)
	itembg:setPosition(itembg:getContentSize().width *0.5 + 10,bg:getContentSize().height - itembg:getContentSize().height *0.5 - 10)

	
	local itemName = XTHDLabel:create(item_name,18)
	bg:addChild(itemName)
	itemName:setAnchorPoint(0,0.5)
	itemName:setColor(cc.c3b(0,0,0))
	itemName:setPosition(itembg:getPositionX() + itembg:getContentSize().width *0.5,itembg:getPositionY() + itembg:getContentSize().height *0.5 - 15 - itemName:getContentSize().height *0.5)

	if self._key == "fuli" then
		local _index = 0
		while true do
			_index = _index + 1
			if self._data["reward".. _index .."type"] then
				local _data = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = self._data["reward".. _index .."ID"]})
				local name = nil
				if self._data["reward".. _index .."type"] == 4 then
					name = XTHDLabel:create(_data.name.."：",18)
				else
					if self._data["reward".. _index .."type"] == 3 then
						name = XTHDLabel:create("元宝".."：",18)
					elseif self._data["reward".. _index .."type"] == 6 then
						name = XTHDLabel:create("翡翠".."：",18)
					elseif self._data["reward".. _index .."type"] == 2 then
						name = XTHDLabel:create("银两".."：",18)
					end
				end
			
				bg:addChild(name)
				name:setAnchorPoint(0,0.5)
				name:setColor(cc.c3b(0,0,0))
				local y = itembg:getPositionY() - itembg:getContentSize().height *0.5 - name:getContentSize().height *0.5 - (_index-1)* name:getContentSize().height - 10
				name:setPosition(itembg:getPositionX() - itembg:getContentSize().width *0.5 + 10,y)			

				local itemNum = XTHDLabel:create(self._data["reward".. _index .."Num"].."个",18)
				itemNum:setAnchorPoint(0,0.5)
				itemNum:setColor(cc.c3b(0,0,0))
				bg:addChild(itemNum)
				itemNum:setPosition(name:getPositionX() + name:getContentSize().width,name:getPositionY())
			else
				break
			end
		end
	elseif self._key == "danbi" then
		local _index = 0
		while true do
			_index = _index + 1
			if self._data["item".. _index .."type"] then
				local _data = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = self._data["item".. _index .."ID"]})
				local name = nil
				if self._data["item".. _index .."type"] == 4 then
					name = XTHDLabel:create(_data.name.."：",18)
				else
					if self._data["item".. _index .."type"] == 3 then
						name = XTHDLabel:create("元宝".."：",18)
					elseif self._data["item".. _index .."type"] == 6 then
						name = XTHDLabel:create("翡翠".."：",18)
					elseif self._data["item".. _index .."type"] == 2 then
						name = XTHDLabel:create("银两".."：",18)
					end
				end
			
				bg:addChild(name)
				name:setAnchorPoint(0,0.5)
				name:setColor(cc.c3b(0,0,0))
				local y = itembg:getPositionY() - itembg:getContentSize().height *0.5 - name:getContentSize().height *0.5 - (_index-1)* name:getContentSize().height - 10
				name:setPosition(itembg:getPositionX() - itembg:getContentSize().width *0.5 + 10,y)			

				local itemNum = XTHDLabel:create(self._data["item".. _index .."num"].."个",18)
				itemNum:setAnchorPoint(0,0.5)
				itemNum:setColor(cc.c3b(0,0,0))
				bg:addChild(itemNum)
				itemNum:setPosition(name:getPositionX() + name:getContentSize().width,name:getPositionY())
			else
				break
			end
		end
	elseif self._key == "chaozhi" then
		local _index = 0
		while true do
			_index = _index + 1
			if self._data["reward".. _index .."type"] then
				local _data = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = self._data["reward".. _index .."ID"]})
				local name = nil
				if self._data["reward".. _index .."type"] == 4 then
					name = XTHDLabel:create(_data.name.."：",18)
				else
					if self._data["reward".. _index .."type"] == 3 then
						name = XTHDLabel:create("元宝".."：",18)
					elseif self._data["reward".. _index .."type"] == 6 then
						name = XTHDLabel:create("翡翠".."：",18)
					elseif self._data["reward".. _index .."type"] == 2 then
						name = XTHDLabel:create("银两".."：",18)
					end
				end
			
				bg:addChild(name)
				name:setAnchorPoint(0,0.5)
				name:setColor(cc.c3b(0,0,0))
				local y = itembg:getPositionY() - itembg:getContentSize().height *0.5 - name:getContentSize().height *0.5 - (_index-1)* name:getContentSize().height - 10
				name:setPosition(itembg:getPositionX() - itembg:getContentSize().width *0.5 + 10,y)			

				local itemNum = XTHDLabel:create(self._data["reward".. _index .."Num"].."个",18)
				itemNum:setAnchorPoint(0,0.5)
				itemNum:setColor(cc.c3b(0,0,0))
				bg:addChild(itemNum)
				itemNum:setPosition(name:getPositionX() + name:getContentSize().width,name:getPositionY())
			else
				break
			end
		end
	end
	
end

function ItemNodePop:create(data,key)
	return ItemNodePop.new(data,key)
end

return ItemNodePop

--endregion
