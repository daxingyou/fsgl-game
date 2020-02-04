--  Created by zhangchao on 15-04-20.
--[[用户道具表]]
DBTableItem = {};
DBTableItem.DBData = {}

DB_TABLE_NAME_ITEM = "item"

function DBTableItem.insertData(userid , param )
	local Params = {};	
	if param["property"] and next(param["property"])~=nil then
		param["baseProperty"]  = param["property"]["baseProperty"] or ""; 
        param["strengLevel"]  	= param["property"]["strengLevel"] or 0;
        param["phaseProperty"] = param["property"]["phaseProperty"] or "";
        param["phaseLevel"]  	= param["property"]["phaseLevel"] or 0;
        param["plusTempProperty"] = param["property"]["plusTempProperty"] or "";
	end

	Params["dbid"]             = getRideOfSingleQuote(param["dbId"]);
	Params["itemid"]           = tonumber(param["itemId"])
	Params["resourceid"]       = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=param["itemId"]})["resourceid"] or 0
	Params["name"]             = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=param["itemId"]})["name"] or ""
	Params["count"]            = tonumber(param["count"]) or 0;
	Params["quality"]          = tonumber(param["quality"]) or 0;
	Params["item_type"]        = tonumber(param["item_type"]) or 0;
	Params["position"]         = tonumber(param["position"]) or 0;
	Params["power"]            = tonumber(param["power"]) or 0;
	Params["baseProperty"]     = getRideOfSingleQuote(param["baseProperty"] or "");
	Params["strengLevel"]      = tonumber(param["strengLevel"]) or 0;
	Params["phaseProperty"]    = getRideOfSingleQuote(param["phaseProperty"] or "")
	Params["phaseLevel"]       = tonumber(param["phaseLevel"]) or 0;
	Params["plusTempProperty"] = getRideOfSingleQuote(param["plusTempProperty"] or "")
	Params["effecttype"]       = gameData.getDataFromCSV("ArticleInfoSheet", {["itemid"]=param["itemId"]})["effecttype"] or 0

	if gameUser.getPackageRedPoint() == 0 then
        if 	Params["effecttype"] == 1 or 
        	Params["effecttype"] == 2 or 
        	Params["effecttype"] == 3 or 
        	Params["effecttype"] == 6 or 
        	Params["effecttype"] == 8 or 
        	Params["effecttype"] == 10 	then
        	gameUser.setPackageRedPoint(1)
        end
	end

	DBTableItem.DBData[Params.dbid] = Params
	--神器红点更新
	DBTableItem.artifactRedDot(Params)
end

--测试 yanyuling
function DBTableItem.insertMultiData(userid , params )

	for i=1,#params do
		local _temp_data = params[i]
		_temp_data["baseProperty"] = _temp_data["property"]["baseProperty"] or ""
		_temp_data["strengLevel"] = tonumber(_temp_data["property"]["strengLevel"]) or 0
		_temp_data["phaseProperty"] = _temp_data["property"]["phaseProperty"] or ""
		_temp_data["phaseLevel"] = tonumber(_temp_data["property"]["phaseLevel"]) or 0
		_temp_data["plusTempProperty"] = _temp_data["property"]["plusTempProperty"] or ""
		DBTableItem.insertData(userid , _temp_data)
	end
--	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {['name'] = "bag"}})
end

function DBTableItem.updateCount(userid, data, dbid )

	local Params = {}	
	--此处做一个判断处理，外部可以只需进行更新问题，避免因疏忽而导致数量为0的数据迟勋存在
	if tonumber(data["count"]) <= 0 then
		DBTableItem.deleteData(userid,dbid)
	else
		if DBTableItem.DBData[dbid] then 
			DBTableItem.DBData[dbid].count = tonumber(data.count)
			--神器红点更新(只更新数量的时候，修改)
			DBTableItem.artifactRedDot(DBTableItem.DBData[dbid])
		else 
			Params[#Params+1] = data
			DBTableItem.insertMultiData(userid, Params )
		end
	end
end

--检查神器的红点条件
function DBTableItem.artifactRedDot(data)
	--更新数据，判断神器红点条件
	local _id = tonumber(data.itemid) or tonumber(data.itemId)
	if _id == 2020 or _id == 2021 or _id == 2022 or _id == 2023 then
		local itemType = {
			[2020] = 30, --青龙
			[2021] = 32, --朱雀
			[2022] = 31, --白虎
			[2023] = 33, --玄武
		}
		if tonumber(data.count) > tonumber(DBTableArtifact.needCostNum[itemType[_id]])-1 then
			DBTableArtifact.addArtifactRedDot({_artifactType=itemType[_id]})
		else
			DBTableArtifact.deleteRedDotData(itemType[_id], tonumber(data.count))
		end
	end 
end

function DBTableItem.deleteData(userid, dbid )
	local Params = {};
	--记录id
	local _id
	if DBTableItem.DBData[dbid] then --这里的判断是防止已经删除的数据再次调用 deleteData
		_id = tonumber(DBTableItem.DBData[dbid].itemid) or tonumber(DBTableItem.DBData[dbid].itemId)
	end
	--清除数据
	DBTableItem.DBData[dbid] = nil
	--判断神器红点条件
	if _id then
		if _id == 2020 or _id == 2021 or _id == 2022 or _id == 2023 then
			local itemType = {
				[2020] = 30, --青龙
				[2021] = 32, --朱雀
				[2022] = 31, --白虎
				[2023] = 33, --玄武
			}
			DBTableArtifact.deleteRedDotData(itemType[_id], 0)
		end
	end 
end

function DBTableItem.deleteDataWithItemId(userid,itemid)
	for k,v in pairs(DBTableItem.DBData) do 
		if v.itemid == tonumber(itemid) then 
			DBTableItem.DBData[k] = nil
		end 
	end 
end

function DBTableItem.getData(userid, condition)	
	return gameData.getDataFromDynamicDB(userid, DB_TABLE_NAME_ITEM, condition)
end

function DBTableItem:getDataByID( dbid )
	if dbid then 
		return DBTableItem.DBData[dbid]
	else 
		return DBTableItem.DBData
	end 
end

--获取物品数量根据dbid
function DBTableItem.getCountByID( dbid )
	print("getCountById:"..dbid)
	if dbid then 
		if DBTableItem.DBData[dbid] then
			return DBTableItem.DBData[dbid].count
		else
			return 0
		end
	else 
		return 0
	end 
end

function DBTableItem.updatebaseProperty(userid,data,dbid)
	local Params = {};
	if DBTableItem.DBData[dbid] then 
		DBTableItem.DBData[dbid].baseProperty = data.baseProperty
	end 	
end

function DBTableItem.updateMultiData(userid,dbid,params)
	if not params or not next(params) then 
		return 
	end 
	if DBTableItem.DBData[dbid] then 
		for k,v in pairs(params) do 
			v = tonumber(v) or v
			DBTableItem.DBData[dbid][k] = v
		end 
	end 	
end

function DBTableItem.updatephaseLevel(userid,data,dbid)
	if DBTableItem.DBData[dbid] then 
		DBTableItem.DBData[dbid].phaseLevel = tonumber(data.phaseLevel)
	end 	
end

function DBTableItem.updatephaseProperty(userid,data,dbid)
	if DBTableItem.DBData[dbid] then 
		DBTableItem.DBData[dbid].phaseProperty = data.phaseProperty
	end 	
end

function DBTableItem.updateStrengthenLevel(userid,data,dbid)
	if DBTableItem.DBData[dbid] then 
		DBTableItem.DBData[dbid].strengLevel = tonumber(data.strengLevel)
	end 	
end

function DBTableItem.updateCountByItemId(userid, data, _itemId )
	for k,v in pairs(DBTableItem.DBData) do 
		if v.itemid == tonumber(_itemId) then 
			v.count = tonumber(data)
		end 
	end
end

function DBTableItem.updatePower(userid,dbid,power)
	if DBTableItem.DBData[dbid] then 
		DBTableItem.DBData[dbid].power = tonumber(power)
	end 	
end

-----获取位置大于0的物品,并且按Power排序
function DBTableItem.getDatasByPosition( )
	local _temp = {}
	for k,v in pairs(DBTableItem.DBData) do 
		if v.position > 0 then 
			_temp[#_temp + 1] = clone(v)
		end 
	end 	
	table.sort(_temp,function(a,b)
		return tonumber(a.power) < tonumber(b.power)
	end)
	return _temp
end
--[[
	获取玩家英雄数量
]]
function DBTableItem.getItemsCount(userid)
	local count = 0
	for k,v in pairs(DBTableItem.DBData) do 
		count = count + 1
	end 
	return count
end