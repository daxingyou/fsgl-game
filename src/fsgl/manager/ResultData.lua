ResultData = {};

--[[
整个数据结构为

reward = { {["itemid"] = xx, ["count"] = xx } };


{
	{ }	
}
]]

function echo( _data )
	for k, v in pairs(_data) do
		print(">>> k: " .. tostring(k) .. "  v: " .. tostring(v));
	end
end

function ResultData:_getRandom()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local data = math.random(0, 100);
	return data
end

-- 接受的为首次奖励/奖励的字符串形式
function ResultData:_analysisData( _data )
	-- 拆分数据
	local _tabAllItemsData = string.split( _data, '#' );
	local _rewardsList = {};
	local function __getRewardData( _dropid ) -- 返回{["itemid"] = xx, ["count"] = xx}
		-- 每个掉落组中会掉落多个物品，物品列表

		local _rewardData = gameData.getDataFromCSV("ExploreDropList", {["dropid"] = _dropid} );
		-- 掉落道具列表
		local _dropPropsList = {};
		-- 掉落id
		local _dropid = _rewardData["dropid"];
		-- 掉落几率
		local _dropprobability = _rewardData["dropprobability"];
		-- 掉落倍率
		local _droprate = _rewardData["droprate"];
		-- 抽取间隔
		local _decimationinterval = _rewardData["decimationinterval"];
		-- 最少掉落数量
		local _mindropcount = _rewardData["mindropcount"];
		-- 最大掉落数量
		local _maxdropcount = _rewardData["maxdropcount"];
		-- 掉落数量倍率
		local _dropcountrate = _rewardData["dropcountrate"];
		for i = 1, 8 do
			local _subData = _rewardData["dropprops" .. tostring(i)];
			if _subData ~= nil and _subData ~= "" then
				_dropPropsList[#_dropPropsList+1] = _subData;
			end
		end
		
		-- 根据概率，如果不掉落直接返回空
		if self:_getRandom() > tonumber(_dropprobability) * tonumber(_droprate) then
			return {};
		end

		local _itemGetCount = 0;
		-- 确定了掉落然后收集每个掉落组中掉落的物品
		local function ____getDropItem( _dropItemData )
			local _tabData = string.split( _dropItemData, '#' );
			local _itemid = _tabData[1];
			local _itemcount = _tabData[2];
			local _itemratio = _tabData[3];
			if self:_getRandom() > tonumber(_itemratio) then
				return {};
			else
				_itemGetCount = _itemGetCount + _itemcount;
				return {["itemid"] = _itemid, ["count"] = _itemcount * _dropcountrate };
			end
		end

		local function _foreachDropPropsList()
			-- 获取每个掉落组中的数据
			for i = 1, #_dropPropsList do
				local _dropItem = ____getDropItem(_dropPropsList[i]);
				if next(_dropItem) ~= nil then
					local _bInsert = true;
					for subidx = 1, #_rewardsList do
						if _rewardsList[subidx]["itemid"] == _dropItem["itemid"] then
							_rewardsList[subidx]["count"] = _rewardsList[subidx]["count"] + _dropItem["count"];
							_bInsert = false;
						end
					end

					if _bInsert then
						_rewardsList[#_rewardsList+1] = _dropItem;
					end
					-- 超过后不再采集
					if _itemGetCount >= _maxdropcount then
						break;
					end
				end
			end
		end
		while _itemGetCount < _mindropcount do
			_foreachDropPropsList();
		end
	end
	for i = 1, #_tabAllItemsData do
		__getRewardData( _tabAllItemsData[i] );
	end
	return _rewardsList;
end