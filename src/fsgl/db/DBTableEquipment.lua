--  Created by zhangchao on 15-05-05.
DBTableEquipment = {};
DBTableEquipment.DBData = {}

DB_TABLE_NAME_EQUIPMENT = "equipment"
--根据用户id创建数据库名称

function DBTableEquipment.insertData(userid , param )	
	if param["property"] and next(param["property"])~=nil then
		param["baseProperty"]     = param["property"]["baseProperty"] or ""; 
		param["strengLevel"]      = param["property"]["strengLevel"] or 0;
		param["phaseProperty"]    = param["property"]["phaseProperty"] or "";
		param["phaseLevel"]       = param["property"]["phaseLevel"] or 0;
		param["plusTempProperty"] = param["property"]["plusTempProperty"] or "";
	end

	local Params = {}
	Params["heroid"] 			= tonumber(param["heroid"])
	Params["dbid"] 				= getRideOfSingleQuote(param["dbid"])
	Params["itemid"] 			= tonumber(param["itemid"])
	Params["bagindex"] 			= tonumber(param["bagindex"]) or 0 --根据后端返回的装备信息中的position
	Params["quality"] 			= tonumber(param["quality"]) or 0	
	Params["power"] 			= tonumber(param["power"]) or 0
	Params["baseProperty"] 		= getRideOfSingleQuote(param["baseProperty"] or "")
	Params["strengLevel"] 		= tonumber(param["strengLevel"]) or 0
	Params["phaseProperty"] 	= getRideOfSingleQuote(param["phaseProperty"] or "")
	Params["phaseLevel"] 		= tonumber(param["phaseLevel"]) or 0
	Params["plusTempProperty"] 	= getRideOfSingleQuote(param["plusTempProperty"] or "")

	DBTableEquipment.DBData[Params.dbid] = Params
end
--批量插入数据
function DBTableEquipment.insertMultiData(userid , params )	
	for i=1,#params do
		DBTableEquipment.insertData(userid,params[i])
	end	
end

function DBTableEquipment.updateMultiData(userid,dbid,params)
	if DBTableEquipment.DBData[dbid] then 
		for k,v in pairs(params) do 
			if DBTableEquipment.DBData[dbid][k] then
				v = tonumber(v) or v
				DBTableEquipment.DBData[dbid][k] = v
			end 
		end 
	end 
end

function DBTableEquipment.updateAllItems(userid, itemid, heroid )
	for k,v in pairs(DBTableEquipment.DBData) do 
		if v.heroid == tonumber(heroid) then 
			v.itemid = tonumber(itemid)
		end 
	end 
end

function DBTableEquipment.updatebaseProperty(userid,data,dbid)
	if DBTableEquipment.DBData[dbid] and DBTableEquipment.DBData[dbid].baseProperty then 
		DBTableEquipment.DBData[dbid].baseProperty = data.baseProperty
	end 
end

function DBTableEquipment.updatephaseLevel(userid,data,dbid)
	if DBTableEquipment.DBData[dbid] and DBTableEquipment.DBData[dbid].phaseLevel then 
		DBTableEquipment.DBData[dbid].phaseLevel = tonumber(data.phaseLevel)
	end 
end

function DBTableEquipment.updatephaseProperty(userid,data,dbid)
	if DBTableEquipment.DBData[dbid] and DBTableEquipment.DBData[dbid].phaseProperty then 
		DBTableEquipment.DBData[dbid].phaseProperty = data.phaseProperty
	end 
end

function DBTableEquipment.updateStrengthenLevel(userid,data,dbid)
	if DBTableEquipment.DBData[dbid] and DBTableEquipment.DBData[dbid].strengLevel then 
		DBTableEquipment.DBData[dbid].strengLevel = tonumber(data.strengLevel)
	end 
end

function DBTableEquipment.updateItemId(userid, itemid, heroid, bagindex)
	for k,v in pairs(DBTableEquipment.DBData) do 
		if v.heroid == tonumber(heroid) and v.bagindex == bagindex then 
			v.itemid = tonumber(itemid)
		end 
	end 
end

function DBTableEquipment.updateHeroid(userid,heroid,dbid)
	if DBTableEquipment.DBData[dbid] and DBTableEquipment.DBData[dbid].heroid then 
		DBTableEquipment.DBData[dbid].heroid = tonumber(heroid)
	end 
end

function DBTableEquipment.updatePower(userid,dbid,power)
	if DBTableEquipment.DBData[dbid] and DBTableEquipment.DBData[dbid].power then 
		DBTableEquipment.DBData[dbid].power = tonumber(power)
	end 
end

function DBTableEquipment.deleteData(userid, dbid )
	if DBTableEquipment.DBData[dbid] then 
		DBTableEquipment.DBData[dbid] = nil
	end 
end

function DBTableEquipment.deleteDataByHeroid(userid, heroid )
	for k,v in pairs(DBTableEquipment.DBData) do 
		if v.heroid == tonumber(heroid) then 
			DBTableEquipment.DBData[k] = nil
		end 
	end 
end

function DBTableEquipment.getData(userid, condition)
	return gameData.getDataFromDynamicDB(userid, DB_TABLE_NAME_EQUIPMENT, condition)
end
function DBTableEquipment:getDataByID( dbid )
	if dbid then 
		return DBTableEquipment.DBData[dbid]
	else 
		return DBTableEquipment.DBData
	end 
end