--  Created by zhangchao on 15-04-01.
DBTableHero = {};
DBTableHero.DBData = {}
DBTableHero.DBData2 = {}
DBTableHero.maxAdvance = 0 -----当前玩家英雄中最高品质的

DB_TABLE_NAME_HERO = "hero"
--根据用户id创建数据库名称

function DBTableHero.resetData()
	DBTableHero.DBData = {}
	DBTableHero.DBData2 = {}
	DBTableHero.maxAdvance = 0 -----当前玩家英雄中最高品质的
end

function DBTableHero.insertData(userid , param )
	dump(param)
	local Params = {};
	Params["heroid"]				= tonumber(param["heroid"])
	Params["level"] 				= tonumber(param["level"])
	Params["star"] 					= tonumber(param["star"])
	Params["advance"] 				= tonumber(param["advance"])
	Params["curexp"] 				= tonumber(param["curexp"])
	Params["maxexp"] 				= tonumber(param["maxexp"])
	Params["power"] 				= tonumber(param["407"]) or 0 		-- power
	Params["hp"] 					= tonumber(param["200"]) or 0;  	-- hp
	Params["physicalattack"] 		= tonumber(param["201"]) or 0;  	-- physicalattack
	Params["physicaldefence"] 		= tonumber(param["202"]) or 0;  	-- physicaldefence
	Params["manaattack"] 			= tonumber(param["203"]) or 0;  	-- manaattack
	Params["manadefence"] 			= tonumber(param["204"]) or 0;  	-- manadefence
	Params["hit"] 					= tonumber(param["300"]) or 0;	-- hit
	Params["dodge"] 				= tonumber(param["301"]) or 0; 	-- dodge
	Params["crit"] 					= tonumber(param["302"]) or 0; 	-- crit
	Params["crittimes"] 			= tonumber(param["303"]) or 0;	-- crittimes
	Params["anticrit"] 				= tonumber(param["304"]) or 0;	-- anticrit
	Params["antiattack"] 			= tonumber(param["305"]) or 0;	-- antiattack
	Params["attackbreak"] 			= tonumber(param["306"]) or 0;	-- attackbreak
	Params["antiphysicalattack"]	= tonumber(param["307"]) or 0;	-- antiphysicalattack
	Params["physicalattackbreak"] 	= tonumber(param["308"]) or 0;	-- physicalattackbreak
	Params["antimanaattack"] 		= tonumber(param["309"]) or 0;	-- antimanaattack
	Params["manaattackbreak"] 		= tonumber(param["310"]) or 0;	-- manaattackbreak
	Params["suckblood"] 			= tonumber(param["311"]) or 0;	-- suckblood
	Params["heal"] 					= tonumber(param["312"]) or 0;	-- heal
	Params["behealed"] 				= tonumber(param["313"]) or 0;	-- behealed
	Params["antiangercost"] 		= tonumber(param["314"]) or 0;	-- antiangercost
	Params["hprecover"] 			= tonumber(param["315"]) or 0;	-- hprecover
	Params["angerrecover"] 			= tonumber(param["316"]) or 0;	-- angerrecover
	Params["neigongs"] 				= getRideOfSingleQuote(param["neigongs"] or "")	-- angerrecover
	--{"veinsType" =1, 哪条经脉
	--"level"=2,经脉等级
	--"energy"=1000}经脉当前已注入真气量
	Params["petVeins"] 				= DBTableHero.getSortPetVeinsData(param["petVeins"] or {})				--经脉。

	DBTableHero.DBData[Params.heroid] = Params
	DBTableHero.maxAdvance = (DBTableHero.maxAdvance > Params.advance) and DBTableHero.maxAdvance or Params.advance
	local Params2 = clone(Params)
	for k,v in pairs(Params2) do
		if k ~= "heroid" and k ~= "petVeins" then
			Params2[k] = iBaseCrypto:MD5Lua(v,false)
		end
	end
	DBTableHero.DBData2[Params2.heroid] = Params2
end

--通过英雄ID获取英雄信息
function DBTableHero.getHeroData(heroid)
	for k,v in pairs(DBTableHero.DBData) do
		if v.heroid == heroid then
			return v
		end
	end
end

--通过英雄ID删除英雄
function DBTableHero.removeHeroFromHeroid(heroid)
	for k,v in pairs(DBTableHero.DBData) do
		if v.heroid == heroid then
			DBTableHero.DBData[k] = nil
		end
	end
end

--测试 yanyuling
function DBTableHero.insertMultiData(userid , params )
	for i=1,#params do
		local _temp_data = params[i]
		DBTableHero.insertData(userid , _temp_data)
	end
end
--[[
	更新玩家的数据，
	参数 id来源于后端
	type_id : 属性id
	data : 最终结果值

	注：后期的需求，根据自己的需求和对应的id，自行更新相应的数据
]]
function DBTableHero.updateDataByPropId( userid, type_id, data, heroid )
	if not type_id then 
		return
	end
	type_id = tonumber(type_id)
	local _keyStr = DBTableHero.getHeroProKeyById(type_id)
	DBTableHero.updateHeroData(userid, data, heroid, _keyStr)
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PLAYERPOWER})
end

function DBTableHero.getHeroProKeyById(pro_id)
    local _keyStr = ""
    pro_id = tonumber(pro_id)
    if pro_id == 200 then
        _keyStr = "hp"
    elseif pro_id == 201 then
        _keyStr = "physicalattack"
    elseif pro_id == 202 then
        _keyStr = "physicaldefence"
    elseif pro_id == 203 then
        _keyStr = "manaattack"
    elseif pro_id == 204 then
        _keyStr = "manadefence"
    elseif pro_id == 300 then
        _keyStr = "hit"
    elseif pro_id == 301 then
        _keyStr = "dodge"
    elseif pro_id == 302 then
        _keyStr = "crit"
    elseif pro_id == 303 then
        _keyStr = "crittimes"
    elseif pro_id == 304 then
        _keyStr = "anticrit"
    elseif pro_id == 305 then
        _keyStr = "antiattack"
    elseif pro_id == 306 then
        _keyStr = "attackbreak"
    elseif pro_id == 307 then
        _keyStr = "antiphysicalattack"
    elseif pro_id == 308 then
        _keyStr = "physicalattackbreak"
    elseif pro_id == 309 then
        _keyStr = "antimanaattack"
    elseif pro_id == 310 then
        _keyStr = "manaattackbreak"
    elseif pro_id == 311 then
        _keyStr = "suckblood"
    elseif pro_id == 312 then
        _keyStr = "heal"
    elseif pro_id == 313 then
        _keyStr = "behealed"
    elseif pro_id == 314 then
        _keyStr = "antiangercost"
    elseif pro_id == 315 then
        _keyStr = "hprecover"
    elseif pro_id == 316 then
        _keyStr = "angerrecover"
    elseif pro_id == 400 then
        _keyStr = "level"
    elseif pro_id == 403 then
        ---gold无
        _keyStr = ""
    elseif pro_id == 406 then
        --vip无
        _keyStr = ""
    elseif pro_id == 407 then
        _keyStr = "power"
    elseif pro_id == 410 then
        --physical无
        _keyStr = ""
    elseif pro_id == 413 then
        _keyStr = "curexp"
    elseif pro_id == 414 then
        _keyStr = "maxexp"
    elseif pro_id == 415 then
        _keyStr = "star"
    elseif pro_id == 416 then
        _keyStr = "advance"
    elseif pro_id == 417 then
        _keyStr = ""
    end
    return _keyStr
end

function DBTableHero.updateHeroData(userid, _value, heroid, _type)
	if _type==nil or _type =="" then
		return
	end
	heroid = tonumber(heroid)
	if heroid and DBTableHero.DBData[heroid] and DBTableHero.DBData[heroid][_type] then 
		_value = tonumber(_value) or _value
		DBTableHero.DBData[heroid][_type] = _value
		if _type == "advance" then 
			DBTableHero.maxAdvance = (DBTableHero.maxAdvance > _value) and DBTableHero.maxAdvance or _value
		end 
		if DBTableHero.DBData2[heroid] and DBTableHero.DBData2[heroid][_type] then
			if _type ~= "heroid" and _type ~= "petVeins" then
				DBTableHero.DBData2[heroid][_type] = iBaseCrypto:MD5Lua(_value,false)
			end
		end
	end 	
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PLAYERPOWER})
end

function DBTableHero.getSortPetVeinsData(_data)
	if _data==nil then
		return
	end
	local _newData = {}
	for i=1,#_data do
		_newData[tonumber(_data[i].veinsType)] = _data[i]
	end
	return _newData
end

function DBTableHero.updateHeroPetVeinsData( _data, heroid)
	heroid = tonumber(heroid)
	if heroid and DBTableHero.DBData[heroid] and DBTableHero.DBData[heroid]["petVeins"] then 
		if next(DBTableHero.DBData[heroid]["petVeins"])==nil then
			DBTableHero.DBData[heroid]["petVeins"] = {}
		end
		local _veinType = tonumber(_data.veinsType)
		if _veinType == nil then
			return
		end
		DBTableHero.DBData[heroid]["petVeins"][_veinType] = _data
	end 
end

--[[把多条UPDATE语句整合成一句一起执行 提高效率
	此方法只支持后端返回的特定数据 一般为property和一个petId
	property的格式大概为{
		"200,16434",
	    "201,1930",
	    "202,570"
	}
	这种类型
]]
function DBTableHero.multiUpdate(userid,petId,property)
	petId = tonumber(petId)
	if petId and DBTableHero.DBData[petId] then 
		for i = 1,#property do 
			local kv = string.split(property[i],",")
			local key = DBTableHero.getHeroProKeyById(tonumber(kv[1]))			
			DBTableHero.DBData[petId][key] = tonumber(kv[2])
			if DBTableHero.DBData2[petId] and key ~= "heroid" and key ~= "petVeins" then
				DBTableHero.DBData2[petId][key] = iBaseCrypto:MD5Lua(tonumber(kv[2]), false)
			end
		end 
	end 
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PLAYERPOWER})
end

function DBTableHero.getData(userid, condition)
	return gameData.getDataFromDynamicDB(userid, DB_TABLE_NAME_HERO, condition)
end

function DBTableHero.getPerVeinsData(heroid)
	heroid = tonumber(heroid)
	if heroid and DBTableHero.DBData[heroid] and DBTableHero.DBData[heroid]["petVeins"] then
		return DBTableHero.DBData[heroid]["petVeins"]
	else
		return {}
	end
end

function DBTableHero.getPerVeinsDataByVeinstype(heroid,_veinsType)
	heroid = tonumber(heroid)
	if heroid and DBTableHero.DBData[heroid] and DBTableHero.DBData[heroid]["petVeins"] then
		if _veinsType and DBTableHero.DBData[heroid]["petVeins"][tonumber(_veinsType)] then
			return DBTableHero.DBData[heroid]["petVeins"][tonumber(_veinsType)]
		else
			return {}
		end
	else
		return {}
	end
end

function DBTableHero.getDataByID( heroid )
	if heroid then 
		return DBTableHero.DBData[tonumber(heroid)]
	else 
		return DBTableHero.DBData
	end 
end

--[[
	获取玩家英雄数量
]]
function DBTableHero.getHerosCount(userid)
	local count = 0
	for k,v in pairs(DBTableHero.DBData) do 
		count = count + 1
	end 
	return count
end

--获取玩家英雄总战力
function DBTableHero.getAllHeroPower()
	local allPower = 0
	for k,v in pairs(DBTableHero.DBData) do 
		allPower = allPower + v.power
	end 
	return allPower
end

function DBTableHero.getHeroDatasForFight( heroId )
	local _heroId = tonumber(heroId) or 0
	if not DBTableHero.DBData2[_heroId] or not DBTableHero.DBData[_heroId] then
		return {}
	end
	local _data = DBTableHero.getData(gameUser.getUserId(), {heroid = _heroId})
	local table = DBTableHero.DBData2[_heroId]
	for k,v in pairs(_data) do
		if k ~= "petVeins" then
			local pV
			if k == "heroid" then
				pV = v
			else
				pV = iBaseCrypto:MD5Lua(v, false)
			end
			if table[k] ~= nil and pV ~= table[k] then
				local _params = {
					_type = "getHeroData", 
					heroData = _data,
				}
				LayerManager.sendZuobi(_params)
				break
			end
		end
	end
	return _data
end