--changed by LITAO 2015年06月09日
DBTableArtifact = {}
DBTableArtifact.DBData = {}
 
DBTableArtifact.redDotData = {} --神器红点条件
DBTableArtifact.needCostNum = { --神器进价消耗需求
	[30] = 0,	
	[31] = 0,	
	[32] = 0,	
	[33] = 0,	
}

DB_TABLE_NAME_ARTIFACT = "artifact"
--根据用户id创建数据库名称

function DBTableArtifact.inserData(userid,param)	
	DBTableArtifact.DBData[param.godid] = param
end

function DBTableArtifact.analysDataAndUpdate(data)
	local _temp = {}
	_temp["godid"]					= getRideOfSingleQuote(data["godId"])
	_temp["templateId"]				= tonumber(data["templateId"])
	_temp["petId"]					= tonumber(data["petId"])
	_temp["hp"] 					= tonumber(data["property"]["200"])
	_temp["physicalattack"] 		= tonumber(data["property"]["201"])
	_temp["physicaldefence"] 		= tonumber(data["property"]["202"])
	_temp["manaattack"] 			= tonumber(data["property"]["203"])
	_temp["manadefence"] 			= tonumber(data["property"]["204"])
	_temp["hit"] 					= tonumber(data["property"]["300"])
	_temp["dodge"] 					= tonumber(data["property"]["301"])
	_temp["crit"] 					= tonumber(data["property"]["302"])
	_temp["crittimes"] 				= tonumber(data["property"]["303"])
	_temp["anticrit"] 				= tonumber(data["property"]["304"])
	_temp["antiattack"] 			= tonumber(data["property"]["305"])
	_temp["attackbreak"] 			= tonumber(data["property"]["306"])
	_temp["antiphysicalattack"] 	= tonumber(data["property"]["307"])
	_temp["physicalattackbreak"]	= tonumber(data["property"]["308"])
	_temp["antimanaattack"] 		= tonumber(data["property"]["309"])
	_temp["manaattackbreak"] 		= tonumber(data["property"]["310"])
	_temp["suckblood"] 				= tonumber(data["property"]["311"])
	_temp["heal"] 					= tonumber(data["property"]["312"])
	_temp["behealed"] 				= tonumber(data["property"]["313"])
	_temp["antiangercost"] 			= tonumber(data["property"]["314"])
	_temp["hprecover"] 				= tonumber(data["property"]["315"])
	_temp["angerrecover"] 			= tonumber(data["property"]["316"])	
	_temp["items1"] 				= tonumber(data["items"][1])
	_temp["items2"]					= tonumber(data["items"][2])
	_temp["items3"] 				= tonumber(data["items"][3])
	_temp["items4"] 				= tonumber(data["items"][4])
	_temp["items5"] 				= tonumber(data["items"][5])
	_temp["items6"] 				= tonumber(data["items"][6])
	_temp["curLucky"] 				= tonumber(data["curLucky"])
	_temp["cdTime"] 				= tonumber(data["cdTime"])
	_temp["_artifactType"]          = gameData.getDataFromCSV("SuperWeaponUpInfo", {id=tonumber(data["templateId"])})["_type"]
	_temp["needNum"]          		= gameData.getDataFromCSV("SuperWeaponUpInfo", {id=tonumber(data["templateId"])})["num1"]


	DBTableArtifact.inserData(gameUser.getUserId(),_temp)
	--	
	DBTableArtifact.addArtifactRedDot(_temp)
end

function DBTableArtifact.addArtifactRedDot(data)
	local itemNum = 0
	if tonumber(data._artifactType) == 30 then --青龙
		itemNum = XTHD.resource.getItemNum(2020) --青龙进价石
		DBTableArtifact.redDotData[30] = itemNum
	elseif tonumber(data._artifactType) == 31 then --白虎
		itemNum = XTHD.resource.getItemNum(2022)--白虎进价石
		DBTableArtifact.redDotData[31] = itemNum
	elseif tonumber(data._artifactType) == 32 then --朱雀
		itemNum = XTHD.resource.getItemNum(2021)--朱雀进价石
		DBTableArtifact.redDotData[32] = itemNum
	elseif tonumber(data._artifactType) == 33 then --玄武
		itemNum = XTHD.resource.getItemNum(2023)--玄武进价石
		DBTableArtifact.redDotData[33] = itemNum
	end

	--判断神器需求
	if data.needNum then
		if  DBTableArtifact.needCostNum[tonumber(data._artifactType)] == 0 or --如果没有神器
			DBTableArtifact.needCostNum[tonumber(data._artifactType)] > tonumber(data.needNum) then --或者

			DBTableArtifact.needCostNum[tonumber(data._artifactType)] = tonumber(data.needNum)
		end
	end

	if DBTableArtifact.needCostNum[tonumber(data._artifactType)] == 0 then
		itemNum = 0
		DBTableArtifact.redDotData[tonumber(data._artifactType)] = 0
		return
	end
	if tonumber(gameUser.getArtifactRedPoint()) == 0 and itemNum >= DBTableArtifact.needCostNum[tonumber(data._artifactType)] then
		gameUser.setArtifactRedPoint(1)
	end
end

--更新神器进价的消耗
-- function DBTableArtifact.ifHaveThisArtifact()

-- 	for k, v in pairs(DBTableArtifact.DBData) do
-- 		if DBTableArtifact.needCostNum[tonumber(v._artifactType)] == 0 or --如果没有神器
-- 			DBTableArtifact.needCostNum[tonumber(v._artifactType)] > tonumber(v.needNum) then --或者

-- 			DBTableArtifact.needCostNum[tonumber(v._artifactType)] = tonumber(v.needNum)
-- 		end
-- 	end
-- end

--这个接口是在更新完dbtableItem数据后调用的，刷新一下神器数据
function DBTableArtifact.refreshRedDot()
	for i = 1, 4 do
		DBTableArtifact.addArtifactRedDot({_artifactType = 29+i})
	end
end

--神器进价石使用后处理红点条件
function DBTableArtifact.deleteRedDotData(_type, _delNum)
	if DBTableArtifact.needCostNum[tonumber(_type)] == 0 then --如果没有这件神器
		return 
	end
	if DBTableArtifact.redDotData[tonumber(_type)] then
		DBTableArtifact.redDotData[tonumber(_type)] = tonumber(_delNum)
	end
	local redDot = 0
	for k,v in pairs(DBTableArtifact.redDotData) do
		if tonumber(v) >= DBTableArtifact.needCostNum[tonumber(_type)] then
			redDot = 1
			break
		end
	end
	gameUser.setArtifactRedPoint(redDot)
end

function DBTableArtifact.DeleteOldArtifact(userid,heroId)
	if not heroId or heroId == "" then
		return
	end
	for k,v in pairs(DBTableArtifact.DBData) do 
		if v.petId == tonumber(heroId) then 
			v.petId = 0 
			break
		end 
	end 
end
function DBTableArtifact.getDataByHeroid(heroId)
	if not heroId or heroId == "" then
		return
	end
	for k,v in pairs(DBTableArtifact.DBData) do 
		if v.petId == tonumber(heroId) then 
			return v
		end 
	end 
	return {}
end

--[[改变一条数据]]
function DBTableArtifact.UpdateAtfData(userid,godid, type_id, data)
	if type_id==nil or type_id =="" then
		return
	end	
	if DBTableArtifact.DBData[godid] and DBTableArtifact.DBData[godid][type_id] then 	
		DBTableArtifact.DBData[godid][type_id] = tonumber(data)
	end 
end

--[[把多条UPDATE语句整合成一句一起执行 提高效率
	此方法只支持后端返回的特定数据 神器的属性表和宝石表
]]
function DBTableArtifact.multiUpdate(godid,godProperty,godItems)
	if DBTableArtifact.DBData[godid] then 
		if godProperty then
			for k,v in pairs(godProperty) do
				if DBTableArtifact.DBData[godid][k] then
					DBTableArtifact.DBData[godid][k] = tonumber(v)
				end
			end
		end
		if godItems then
			for i = 1, #godItems do
				if DBTableArtifact.DBData[godid]["items"..i] then
					DBTableArtifact.DBData[godid]["items"..i] = tonumber(godItems[i])
				end
			end
		end
	end
end