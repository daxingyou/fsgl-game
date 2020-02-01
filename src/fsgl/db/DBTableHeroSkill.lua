--  Created by zhangchao on 15-04-01.
DBTableHeroSkill = {};
DBTableHeroSkill.DBData = {}
DBTableHeroSkill.DBData2 = {}

DB_TABLE_NAME_HERO_SKILL = "hero_skill"
--根据用户id创建数据库名称
function DBTableHeroSkill.resetData()
	DBTableHeroSkill.DBData = {}
	DBTableHeroSkill.DBData2 = {}
end

function DBTableHeroSkill.insertData(userid , param )
	local Params = {};
	Params["heroid"] 		= tonumber(param["heroid"])
	Params["talentlv"] 		= tonumber(param["talentlv"])
	Params["skillidlv"] 	= tonumber(param["skillidlv"])
	Params["skillid0lv"] 	= tonumber(param["skillid0lv"])
	Params["skillid1lv"] 	= tonumber(param["skillid1lv"])
	Params["skillid2lv"] 	= tonumber(param["skillid2lv"])
	Params["skillid3lv"] 	= tonumber(param["skillid3lv"])

	DBTableHeroSkill.DBData[Params.heroid] = Params

	local Params2 = clone(Params)
	for k,v in pairs(Params2) do
		if k ~= "heroid" then
			Params2[k] = iBaseCrypto:MD5Lua(v,false)
		end
	end
	DBTableHeroSkill.DBData2[Params2.heroid] = Params2
end


function DBTableHeroSkill.insertMultiData(userid,params )
	for i=1,#params do
		local _temp_data = params[i]
		DBTableHeroSkill.insertData(userid,_temp_data)
	end
end

function DBTableHeroSkill.updateByKey(userid,_key,_level,heroid)
	heroid = tonumber(heroid)
	if heroid and DBTableHeroSkill.DBData[heroid] and DBTableHeroSkill.DBData[heroid][_key] then 
		DBTableHeroSkill.DBData[heroid][_key] = tonumber(_level)
		if DBTableHeroSkill.DBData2[heroid] and DBTableHeroSkill.DBData2[heroid][_key] then
			if _key ~= "heroid" then
				DBTableHeroSkill.DBData2[heroid][_key] = iBaseCrypto:MD5Lua(tonumber(_level),false)
			end
		end
	end
end

function DBTableHeroSkill.getData(userid , condition )
	return gameData.getDataFromDynamicDB(userid, DB_TABLE_NAME_HERO_SKILL, condition)
end
function DBTableHeroSkill.getDataByID(heroid)
	if heroid then 
		return DBTableHeroSkill.DBData[tonumber(heroid)]
	else 
		return DBTableHeroSkill.DBData
	end 
end

function DBTableHeroSkill.getHeroSkillDatasForFight( heroId )
	local _heroId = tonumber(heroId) or 0
	if not DBTableHeroSkill.DBData2[_heroId] or not DBTableHeroSkill.DBData[_heroId] then
		return {}
	end
	local _data = DBTableHeroSkill.getData(gameUser.getUserId(), {heroid = _heroId})
	local table = clone(DBTableHeroSkill.DBData2[_heroId])
	for k,v in pairs(_data) do
		local pV
		if k == "heroid" then
			pV = v
		else
			pV = iBaseCrypto:MD5Lua(v, false)
		end
		if table[k] ~= nil and pV ~= table[k] then
			local _params = {
				_type = "getHeroSkill", 
				skillData = _data,
			}
			LayerManager.sendZuobi(_params)
			break
		end
	end
	return _data
end