--changed by LITAO 2015年06月09日
DBPetData = {}
DBPetData.DBData = {}
 
DBPetData.redDotData = {} --神器红点条件

DB_TABLE_NAME_PET = "pet"
--根据用户id创建数据库名称

function DBPetData.inserData(userid,param)
	DBPetData.DBData[param.godid] = param
end

function DBPetData.analysDataAndUpdate(data)
	local _temp = {}
	_temp["godid"]					= getRideOfSingleQuote(data["servantId"])
	_temp["templateId"]				= tonumber(data["templateId"])
	_temp["petId"]					= tonumber(data["petId"])
	_temp["hp"] 					= tonumber(data["property"]["200"])--生命值
	_temp["physicalattack"] 		= tonumber(data["property"]["201"])--物理攻击
	_temp["physicaldefence"] 		= tonumber(data["property"]["202"])--物理防御
	_temp["manaattack"] 			= tonumber(data["property"]["203"])--魔法攻击
	_temp["manadefence"] 			= tonumber(data["property"]["204"])--魔法防御
	_temp["hit"] 					= tonumber(data["property"]["300"])--命中
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
	_temp["servantId"]				= data.servantId
	_temp["_artifactType"]          = gameData.getDataFromCSV("SuperWeaponUpInfo", {id=tonumber(data["templateId"])})["_type"]
	_temp["needNum"]          		= gameData.getDataFromCSV("SuperWeaponUpInfo", {id=tonumber(data["templateId"])})["num1"]


	DBPetData.inserData(gameUser.getUserId(),_temp)
	--	
	--DBPetData.addArtifactRedDot(_temp)
end


function DBPetData.DeleteOldArtifact(userid,heroId)
	if not heroId or heroId == "" then
		return
	end
	for k,v in pairs(DBPetData.DBData) do 
		if v.petId == tonumber(heroId) then 
			v.petId = 0 
			break
		end 
	end 
end
function DBPetData.getDataByHeroid(heroId)
	if not heroId or heroId == "" then
		return
	end
	for k,v in pairs(DBPetData.DBData) do 
		if v.petId == tonumber(heroId) then 
			return v
		end 
	end 
	return {}
end

--[[改变一条数据]]
function DBPetData.UpdateAtfData(userid,godid, type_id, data)
	if type_id==nil or type_id =="" then
		return
	end	
	if DBPetData.DBData[godid] and DBPetData.DBData[godid][type_id] then 	
		DBPetData.DBData[godid][type_id] = tonumber(data)
	end 
end

--[[把多条UPDATE语句整合成一句一起执行 提高效率
	此方法只支持后端返回的特定数据 神器的属性表和宝石表
]]
function DBPetData.multiUpdate(godid,godProperty,godItems)
	if DBPetData.DBData[godid] then 
		if godProperty then
			for k,v in pairs(godProperty) do
				if DBPetData.DBData[godid][k] then
					DBPetData.DBData[godid][k] = tonumber(v)
				end
			end
		end
		if godItems then
			for i = 1, #godItems do
				if DBPetData.DBData[godid]["items"..i] then
					DBPetData.DBData[godid]["items"..i] = tonumber(godItems[i])
				end
			end
		end
	end
end