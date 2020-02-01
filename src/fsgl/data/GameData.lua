--[[游戏数据管理对象
	1.目前管理静态、动态数据库
  ]]
gameData = {}
--[[缓存数据的对象
]]
gameData._staticCacheData = {} ---静态数据缓存 
FILE_NAME_STATIC_DATA = "res/staticData.sqlite"

function gameData.firstInit()
	gameData.getDataFromCSV("ArticleInfoSheet")
	gameData.getDataFromCSV("LayoutOfBuilding")
	gameData.getDataFromCSV("VipInfo")
	gameData.getDataFromCSV("FunctionInfoList")
	gameData.getDataFromCSV("GeneralInfoList")
	gameData.getDataFromCSV("EquipUpList")
	gameData.getDataFromCSV("PlayerUpperLimit")
	gameData.getDataFromCSV("GeneralGrowthNeeds")
	gameData.getDataFromCSV("GeneralSkillList")
	gameData.getDataFromCSV("JinengUpNeed")
	gameData.getDataFromCSV("GeneralAdvanceInfo")
	gameData.getDataFromCSV("SmithyMakingList")
	gameData.getDataFromCSV("ContinuousClockIn")
	gameData.getDataFromCSV("JinengInfo")
	gameData.getDataFromCSV("EquipAscendingStar")
	gameData.getDataFromCSV("EquipInfoList")
	gameData.getDataFromCSV("OperationGuide")
end

function gameData.getDataFromCSV(tableName, condition)
	-- requires("src/fsgl/staticdata/"..tableName..".lua")
	-- gameData[tableName] = _G[tableName]
	if not gameData[tableName] then
		requires("src/fsgl/staticdata/"..tableName..".lua")
		gameData[tableName] = _G[tableName]
		gameData.analyseDataByPrimaryKey(tableName)
	end

	local data = nil	
	if tableName and #tableName > 0 then 
		if not condition then ---无条件查询
			data = gameData[tableName]
		else 
			local key = gameData.changeConditionToString(condition)
			-- print("the key is ",key)
			---先从缓存里取
			if gameData._staticCacheData[tableName] then 
				data = gameData._staticCacheData[tableName][key]
				if data and #data > 0 then 
					return clone(data)
				end 
			else 
				gameData._staticCacheData[tableName] = {}
			end 
			data = {}
			---缓存里没有再遍历查询
			local targData = gameData[tableName]
			if targData then 
				local index = {}	
				local j = 1		
				for i = 1,#targData do 
					local have = false
					for k,v in pairs(condition) do 
						local value = v
						if tonumber(v) then 
							value = tonumber(v)						
						end 			
						if targData[i][k] == value then 
							have = true
						else 
							have = false
							break
						end 
					end 
					if have then 
						index[j] = i
						j = j + 1
					end 
				end
				if #index == 1 then 
					data = targData[index[1]]	
					gameData._staticCacheData[tableName][key] = data			
				elseif #index > 1 then  
					for i = 1,#index do 
						data[i] = targData[index[i]]
					end
					gameData._staticCacheData[tableName][key] = data		
				end  
				-- dump(index)
			end 
		end 
	end 	
	-- dump(data)
	return clone(data or {})
end

function gameData.getDataFromCSVWithPrimaryKey(tableName)
	local data = nil
	if tableName and #tableName > 0 then 		
		data = gameData[tableName .. "ByKey"]
		if not data or next(data) == nil then
			gameData.analyseDataByPrimaryKey()
			data = gameData[tableName .. "ByKey"]
		end 
	end
	return data or {}
end

function gameData.changeConditionToString( condition )
	if condition then 
		local str = ""
		for k,v in pairs (condition) do 
			str = str..tostring(k)..tostring(v)
		end
		return str
	end 
	return nil
end

function gameData.getDataFromDynamicDB(userid, tableName, condition)
	local data = {}
	local targetTable = {}
	if tableName == "artifact" then 
		targetTable = DBTableArtifact.DBData
	elseif tableName == "instancing" then 
		targetTable = DBTableInstance.InstancingDBData
	elseif tableName == "eliteinstancing" then 
		targetTable = DBTableInstance.EliteInstancingDBData
	elseif tableName == "instancingreward" then 
		targetTable = DBTableInstance.InstancingRewardDBData
	elseif tableName == "equipment" then 
		targetTable = DBTableEquipment.DBData
	elseif tableName == "hero" then 
		targetTable = DBTableHero.DBData
	elseif tableName == "hero_skill" then 
		targetTable = DBTableHeroSkill.DBData
	elseif tableName == "item" then 
		targetTable = DBTableItem.DBData
	elseif tableName == "userteamdata" then 
		targetTable = DBUserTeamData.DBData
	elseif tableName == "pet" then
		targetTable = DBPetData.DBData
	end 			
	if targetTable then 
		for k,v in pairs(targetTable) do 
			local Okay = true
			if condition then 
				for conditionK,conditionV in pairs(condition) do 
					if tostring(v[conditionK]) ~= tostring(conditionV) then 
						Okay = false
						break
					end 
				end 
			end 
			if Okay then 
				data[#data + 1] = clone(v)
			end 
		end 
	end 
	if #data == 1 then 
		data = data[1]
	end 
	return data
end
----读取本地的游戏静态数据
-- function gameData.loadGameStaticDatas(needRequire)
-- 	local len = #GameFileNames
-- 	for i = 1,len do 
-- 		if needRequire then 
-- 			requires("src/fsgl/staticdata/"..GameFileNames[i]..".lua")
-- 		end 
-- 		gameData[GameFileNames[i]] = _G[GameFileNames[i]]
-- 	end
-- 	gameData.analyseDataByPrimaryKey()
-- end

----将一些表按主键再组织
function gameData.analyseDataByPrimaryKey( tableName )
	local function _do( v )
		local data = gameData[v]
		if not data then 
			return
		end
		local _temp = {}
		if v == "ContinuousClockIn" or v == "FunctionInfoList" or v == "PlayerUpperLimit" or v == "GeneralGrowthNeeds" then 
			for key,val in pairs(data) do 
				_temp[tostring(val.id)] = val
			end 
		elseif v == "ArticleInfoSheet" or v == "EquipInfoList" then 
			for key,val in pairs(data) do 
				_temp[tostring(val.itemid)] = val
			end 
		elseif v == "JinengInfo" then 
			for key,val in pairs(data) do 
				_temp[tostring(val.skillid)] = val
			end 
		elseif v == "EquipUpList" then 
			for key,val in pairs(data) do 
				_temp[tostring(val.itemlevel)] = val
			end 
		elseif v == "EquipAscendingStar" then 
			for key,val in pairs(data) do 
				_temp[tostring(val.stage)] = val
			end 
		elseif v == "GeneralInfoList" or v == "GeneralSkillList" then 
			for key,val in pairs(data) do 
				_temp[tostring(val.heroid)] = val
			end 
		elseif v == "JinengUpNeed" then 
			for key,val in pairs(data) do 
				_temp[tostring(val.level)] = val
			end 
		end 
		gameData[v.."ByKey"] = _temp
	end

	if tableName then
		_do(tableName)
	else
		local _tables = {
			"ContinuousClockIn",
			"ArticleInfoSheet",
			"JinengInfo",
			"EquipUpList",
			"EquipAscendingStar",
			"EquipInfoList",
			"FunctionInfoList",
			"GeneralInfoList",
			"PlayerUpperLimit",
			"GeneralGrowthNeeds",
			"GeneralSkillList",
			"JinengUpNeed",
		}
		for k,v in pairs(_tables) do
			requires("src/fsgl/staticdata/"..v..".lua")
			gameData[v] = _G[v]
			_do(v)
		end 
	end
end

--更新item数据
function gameData.saveDataToDB( data_tab,_type )
    if not data_tab or #data_tab == 0 then
        return
	end

    local function dealDataAndSaveData( data )
        local HerosParam = {}
        HerosParam["heroid"] = tostring(data.id)
        HerosParam["level"] = tostring(data.level)
        HerosParam["star"] = tostring(data.starLevel)
        HerosParam["advance"] = tostring(data.phaseLevel)
        HerosParam["curexp"] = tostring(data.curExp)
        HerosParam["maxexp"] = tostring(data.maxExp)
        HerosParam["neigongs"] = tostring(data.neigongs)
        HerosParam["petVeins"] = data.petVeins
        HerosParam["407"] = tostring(data.power)
        HerosParam["200"] = tostring(data["property"]["200"])
        HerosParam["201"] = tostring(data["property"]["201"])
        HerosParam["202"] = tostring(data["property"]["202"])
        HerosParam["203"] = tostring(data["property"]["203"])
        HerosParam["204"] = tostring(data["property"]["204"])
        HerosParam["300"] = tostring(data["property"]["300"])
        HerosParam["301"] = tostring(data["property"]["301"])
        HerosParam["302"] = tostring(data["property"]["302"])
        HerosParam["303"] = tostring(data["property"]["303"])
        HerosParam["304"] = tostring(data["property"]["304"])
        HerosParam["305"] = tostring(data["property"]["305"])
        HerosParam["306"] = tostring(data["property"]["306"])
        HerosParam["307"] = tostring(data["property"]["307"])
        HerosParam["308"] = tostring(data["property"]["308"])
        HerosParam["309"] = tostring(data["property"]["309"])
        HerosParam["310"] = tostring(data["property"]["310"])
        HerosParam["311"] = tostring(data["property"]["311"])
        HerosParam["312"] = tostring(data["property"]["312"])
        HerosParam["313"] = tostring(data["property"]["313"])
        HerosParam["314"] = tostring(data["property"]["314"])
        HerosParam["315"] = tostring(data["property"]["315"])
        HerosParam["316"] = tostring(data["property"]["316"])
        
        --写数据到heros表中
        DBTableHero.insertData(gameUser.getUserId(),HerosParam)

        local HeroSkillParam = {}
        HeroSkillParam["heroid"] = tostring(data.id)
        HeroSkillParam["talentlv"] = data.skills[1]
        HeroSkillParam["skillidlv"] = data.skills[2]
        HeroSkillParam["skillid0lv"] = data.skills[3]
        HeroSkillParam["skillid1lv"] = data.skills[4]
        HeroSkillParam["skillid2lv"] = data.skills[5]
        HeroSkillParam["skillid3lv"] = data.skills[6]

        --写数据到hero_skill表中
        DBTableHeroSkill.insertData(gameUser.getUserId(), HeroSkillParam)

    end

    --更新英雄数据
    if _type == 1 then
        for i=1,#data_tab do
            local hero_data = data_tab[i]
            dealDataAndSaveData(hero_data)
        end
    end

    --更新装备数据
    if _type == 2 then
        for i=1,#data_tab do
            local item_data = data_tab[i]
            if item_data.count and tonumber(item_data.count) ~= 0 then
                DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
            else
                DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
            end
            
            
        end
    end

end
