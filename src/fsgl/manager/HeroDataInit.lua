HeroDataInit = {};


-- Init Player
--[[
	关于玩家英雄信息的初始化，需要计算自身数据，然后还有装备，进阶，等级，技能
]]
-- HeroInfo 这部分见结构1中的英雄模块
function HeroDataInit:InitHeroData( heroid )
	local tmpData = {};
	-- 获取动态数据库
	local DBUserHeroInfo = DBTableHero.getData(gameUser.getUserId(),{["heroid"] = heroid});
	if DBUserHeroInfo == nil or next(DBUserHeroInfo) == nil then
		return tmpData;
	end
	-- DBUserHeroInfo = DBUserHeroInfo[1];
	-- 获取静态数据库

	local StaticHeroData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = heroid} )

	if StaticHeroData == nil or next(StaticHeroData) == nil then
		return tmpData;
	end

	local _tmpSkill = DBTableHeroSkill.getData(gameUser.getUserId(), {["heroid"]=heroid})
	local _skill = {};
	_skill["talent"] = _tmpSkill[ "talentlv" ] or 0;
	_skill["skillid"] = _tmpSkill[ "skillidlv" ] or 0;
	_skill["skillid0"] = _tmpSkill[ "skillid0lv" ] or 0;
	_skill["skillid1"] = _tmpSkill[ "skillid1lv" ] or 0;
	_skill["skillid2"] = _tmpSkill[ "skillid2lv" ] or 0;
	_skill["skillid3"] = _tmpSkill[ "skillid3lv" ] or 0;

	tmpData["scale"] = StaticHeroData["scale"];  --xx
	tmpData["attackrange"] = StaticHeroData["attackrange"]; -- xx
	tmpData["attackprocess"] = StaticHeroData["attackprocess"];

	if _skill["skillid"] == 0 then
		tmpData["attackprocess"] = string.gsub(tmpData["attackprocess"], "0", "");
	end
	if _skill["skillid1"] == 0 then
		tmpData["attackprocess"] = string.gsub(tmpData["attackprocess"], "1", "");
	end
	if _skill["skillid2"] == 0 then
		tmpData["attackprocess"] = string.gsub(tmpData["attackprocess"], "2", "");
	end
	if _skill["skillid3"] == 0 then
		tmpData["attackprocess"] = string.gsub(tmpData["attackprocess"], "3", "");
	end
	tmpData["name"] = StaticHeroData["name"];
	tmpData["description"] = StaticHeroData["description"]
	tmpData["autograph"] = StaticHeroData["autograph"]
	tmpData["rank"] = StaticHeroData["rank"]
	
	tmpData["id"] = DBUserHeroInfo["heroid"];
	tmpData["level"] = DBUserHeroInfo["level"];
	tmpData["star"] = DBUserHeroInfo["star"];
	tmpData["advance"] = DBUserHeroInfo["advance"];
	tmpData["curexp"] = DBUserHeroInfo["curexp"];
	tmpData["maxexp"] = DBUserHeroInfo["maxexp"];
	tmpData["hp"] = DBUserHeroInfo["hp"]; -- 计算过的
	tmpData["physicalattack"] = DBUserHeroInfo["physicalattack"];
	tmpData["physicaldefence"] = DBUserHeroInfo["physicaldefence"];
	tmpData["manaattack"] = DBUserHeroInfo["manaattack"];
	tmpData["manadefence"] = DBUserHeroInfo["manadefence"];
	tmpData["hit"] = DBUserHeroInfo["hit"];
	tmpData["dodge"] = DBUserHeroInfo["dodge"];
	tmpData["crit"] = DBUserHeroInfo["crit"];
	tmpData["crittimes"] = DBUserHeroInfo["crittimes"];
	tmpData["anticrit"] = DBUserHeroInfo["anticrit"];
	tmpData["antiattack"] = DBUserHeroInfo["antiattack"];
	tmpData["attackbreak"] = DBUserHeroInfo["attackbreak"];
	tmpData["antiphysicalattack"] = DBUserHeroInfo["antiphysicalattack"];
	tmpData["physicalattackbreak"] = DBUserHeroInfo["physicalattackbreak"];
	tmpData["antimanaattack"] = DBUserHeroInfo["antimanaattack"];
	tmpData["manaattackbreak"] = DBUserHeroInfo["manaattackbreak"];
	tmpData["suckblood"] = DBUserHeroInfo["suckblood"];
	tmpData["heal"] = DBUserHeroInfo["heal"];
	tmpData["behealed"] = DBUserHeroInfo["behealed"];
	tmpData["antiangercost"] = DBUserHeroInfo["antiangercost"];
	tmpData["hprecover"] = DBUserHeroInfo["hprecover"];
	tmpData["angerrecover"] = DBUserHeroInfo["angerrecover"];
	tmpData["heroid"] = heroid;
	tmpData["monsterid"] = 0;
	tmpData["power"] = DBUserHeroInfo["power"];
	
	tmpData["beginanger"] = 0; -- 英雄没有初始怒气

	tmpData["equipments"] = _equipments;

	local _heroSkill = gameData.getDataFromCSV("GeneralSkillList", {["heroid"]=heroid});
	tmpData["skills"] = {};
	for k, level in pairs(_skill) do
		tmpData["skills"][k] = {};
		tmpData["skills"][k]["level"] = level;
		local _skillid = _heroSkill[k];
		local _skillBasicInfo = gameData.getDataFromCSV("JinengInfo", {["skillid"]=_skillid});

		tmpData["skills"][k]["skillid"] = _skillid;
		tmpData["skills"][k]["coldtime"] = _skillBasicInfo["coldtime"];
		tmpData["skills"][k]["hpcost"] = _skillBasicInfo["hpcost"];
		tmpData["skills"][k]["angercost"] = _skillBasicInfo["angercost"];
		tmpData["skills"][k]["range"] = _skillBasicInfo["range"];
		tmpData["skills"][k]["timeslimit"] = _skillBasicInfo["timeslimit"];
		tmpData["skills"][k]["attacktimes"] = _skillBasicInfo["attacktimes"];
		tmpData["skills"][k]["targettype"] = _skillBasicInfo["targettype"];
		tmpData["skills"][k]["target"] = _skillBasicInfo["target"];
		
		tmpData["skills"][k]["skilleffect"] = _skillBasicInfo["skilleffect"];
		tmpData["skills"][k]["ispassive"] = _skillBasicInfo["ispassive"];

		tmpData["skills"][k]["attackrangetype"] = _skillBasicInfo["attackrangetype"];
		tmpData["skills"][k]["attackrange"] = _skillBasicInfo["attackrange"];
		tmpData["skills"][k]["calculatetype"] = _skillBasicInfo["calculatetype"];
		tmpData["skills"][k]["hittype"] = _skillBasicInfo["hittype"];
		tmpData["skills"][k]["effecttype"] = _skillBasicInfo["effecttype"];
		tmpData["skills"][k]["datatype"] = _skillBasicInfo["datatype"];
		tmpData["skills"][k]["basedata"] = _skillBasicInfo["basedata"];
		tmpData["skills"][k]["levelupbase"] = _skillBasicInfo["levelupbase"];
		tmpData["skills"][k]["levelupgrow"] = _skillBasicInfo["levelupgrow"];
		
		tmpData["skills"][k]["buff1id"] = _skillBasicInfo["buff1id"];
		tmpData["skills"][k]["buff1idtargettype"] = _skillBasicInfo["buff1idtargettype"];
		tmpData["skills"][k]["buff1probabilitygrow"] = _skillBasicInfo["buff1probabilitygrow"];
		tmpData["skills"][k]["buff1basicgrow"] = _skillBasicInfo["buff1basicgrow"];
		
		tmpData["skills"][k]["buff2id"] = _skillBasicInfo["buff2id"];
		tmpData["skills"][k]["buff2idtargettype"] = _skillBasicInfo["buff2idtargettype"];
		tmpData["skills"][k]["buff2probabilitygrow"] = _skillBasicInfo["buff2probabilitygrow"];
		tmpData["skills"][k]["buff2basicgrow"] = _skillBasicInfo["buff2basicgrow"];

		tmpData["skills"][k]["buff3id"] = _skillBasicInfo["buff3id"];
		tmpData["skills"][k]["buff3idtargettype"] = _skillBasicInfo["buff3idtargettype"];
		tmpData["skills"][k]["buff3probabilitygrow"] = _skillBasicInfo["buff3probabilitygrow"];
		tmpData["skills"][k]["buff3basicgrow"] = _skillBasicInfo["buff3basicgrow"];

		tmpData["skills"][k]["sound"] = _skillBasicInfo["sound"];
		tmpData["skills"][k]["sound_hit"] = _skillBasicInfo["sound_hit"];
		tmpData["skills"][k]["sound_delay"] = _skillBasicInfo["sound_delay"];

		tmpData["skills"][k]["hit_effect"] = _skillBasicInfo["hit_effect"];
		tmpData["skills"][k]["max_effectframe"] = _skillBasicInfo["max_effectframe"];
		tmpData["skills"][k]["effectspeed"] = _skillBasicInfo["effectspeed"];
	end
	
	return tmpData;
end


function HeroDataInit:InitHeroDataSelectHero( heroid )
	local tmpData = {};
	-- 获取动态数据库
	local DBUserHeroInfo = DBTableHero.getData(gameUser.getUserId(),{["heroid"] = heroid});
	if DBUserHeroInfo == nil or next(DBUserHeroInfo) == nil then
		return tmpData;
	end
	-- DBUserHeroInfo = DBUserHeroInfo[1];
	-- 获取静态数据库

	local StaticHeroData = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = heroid} )
	if StaticHeroData == nil or next(StaticHeroData) == nil then
		return tmpData;
	end

-- 技能加成
	local _tmpSkill = DBTableHeroSkill.getData(gameUser.getUserId(), {["heroid"]=heroid})
	_tmpSkill = _tmpSkill and _tmpSkill[1] or {}
	local _skill = {};
	_skill["talent"] = _tmpSkill[ "talentlv" ] or 0;
	_skill["skillid"] = _tmpSkill[ "skillidlv" ] or 0;
	_skill["skillid0"] = _tmpSkill[ "skillid0lv" ] or 0;
	_skill["skillid1"] = _tmpSkill[ "skillid1lv" ] or 0;
	_skill["skillid2"] = _tmpSkill[ "skillid2lv" ] or 0;
	_skill["skillid3"] = _tmpSkill[ "skillid3lv" ] or 0;

	

	tmpData["scale"] = StaticHeroData["scale"];  --xx
	tmpData["attackrange"] = StaticHeroData["attackrange"]; -- xx
	tmpData["attackprocess"] = StaticHeroData["attackprocess"];
	
	if _skill["skillid"] == 0 then
		tmpData["attackprocess"] = string.gsub(tmpData["attackprocess"], "0", "");
	end
	if _skill["skillid1"] == 0 then
		tmpData["attackprocess"] = string.gsub(tmpData["attackprocess"], "1", "");
	end
	if _skill["skillid2"] == 0 then
		tmpData["attackprocess"] = string.gsub(tmpData["attackprocess"], "2", "");
	end
	if _skill["skillid3"] == 0 then
		tmpData["attackprocess"] = string.gsub(tmpData["attackprocess"], "3", "");
	end
	tmpData["name"] = StaticHeroData["name"];
	tmpData["description"] = StaticHeroData["description"]
	tmpData["autograph"] = StaticHeroData["autograph"]
	tmpData["type"] = StaticHeroData["type"]
	tmpData["rank"] = StaticHeroData["rank"]
	
	tmpData["id"] = DBUserHeroInfo["heroid"];
	tmpData["level"] = DBUserHeroInfo["level"];
	tmpData["star"] = DBUserHeroInfo["star"];
	tmpData["advance"] = DBUserHeroInfo["advance"];
	tmpData["curexp"] = DBUserHeroInfo["curexp"];
	tmpData["maxexp"] = DBUserHeroInfo["maxexp"];
	tmpData["hp"] = DBUserHeroInfo["hp"]; -- 计算过的
	tmpData["physicalattack"] = DBUserHeroInfo["physicalattack"];
	tmpData["physicaldefence"] = DBUserHeroInfo["physicaldefence"];
	tmpData["manaattack"] = DBUserHeroInfo["manaattack"];
	tmpData["manadefence"] = DBUserHeroInfo["manadefence"];
	tmpData["hit"] = DBUserHeroInfo["hit"];
	tmpData["dodge"] = DBUserHeroInfo["dodge"];
	tmpData["crit"] = DBUserHeroInfo["crit"];
	tmpData["crittimes"] = DBUserHeroInfo["crittimes"];
	tmpData["anticrit"] = DBUserHeroInfo["anticrit"];
	tmpData["antiattack"] = DBUserHeroInfo["antiattack"];
	tmpData["attackbreak"] = DBUserHeroInfo["attackbreak"];
	tmpData["antiphysicalattack"] = DBUserHeroInfo["antiphysicalattack"];
	tmpData["physicalattackbreak"] = DBUserHeroInfo["physicalattackbreak"];
	tmpData["antimanaattack"] = DBUserHeroInfo["antimanaattack"];
	tmpData["manaattackbreak"] = DBUserHeroInfo["manaattackbreak"];
	tmpData["suckblood"] = DBUserHeroInfo["suckblood"];
	tmpData["heal"] = DBUserHeroInfo["heal"];
	tmpData["behealed"] = DBUserHeroInfo["behealed"];
	tmpData["antiangercost"] = DBUserHeroInfo["antiangercost"];
	tmpData["hprecover"] = DBUserHeroInfo["hprecover"];
	tmpData["angerrecover"] = DBUserHeroInfo["angerrecover"];
	tmpData["heroid"] = heroid;
	tmpData["monsterid"] = 0;
	tmpData["power"] = DBUserHeroInfo["power"];
	tmpData["neigongs"] = DBUserHeroInfo["neigongs"];
	tmpData["petVeins"] = DBUserHeroInfo["petVeins"];
	
	tmpData["beginanger"] = 0; -- 英雄没有初始怒气

	tmpData["equipments"] = _equipments;

	tmpData["skills"] = {};
	
	
	return tmpData;
end

function HeroDataInit:InitHeroDataAllOwnHero()
	local tmpData = {};
	-- 获取动态数据库
	local _userHeroTable = DBTableHero.getData(gameUser.getUserId());
	
	if _userHeroTable == nil or next(_userHeroTable) == nil then
		return tmpData;
	end
	local DBUserHeroInfo = {}
	if _userHeroTable and next(_userHeroTable)~=nil and #_userHeroTable <1 then
		DBUserHeroInfo[tostring(_userHeroTable.heroid)] = _userHeroTable
	else
		for k,v in pairs(_userHeroTable) do
			DBUserHeroInfo[tostring(v.heroid)] = v
		end
	end
	-- 获取静态数据库
	local _staticHeroTable = gameData.getDataFromCSV("GeneralInfoList")
	if _staticHeroTable == nil or next(_staticHeroTable) == nil then
		return tmpData;
	end
	local StaticHeroData = {}
	if _staticHeroTable and next(_staticHeroTable)~=nil and #_staticHeroTable <1 then
		StaticHeroData[tostring(_staticHeroTable.heroid)] = _staticHeroTable
	else
		for k,v in pairs(_staticHeroTable) do
			StaticHeroData[tostring(v.heroid)] = v
		end
	end
	-- 技能加成
	local _tmpSkillTable = DBTableHeroSkill.getData(gameUser.getUserId())
	local _tmpSkill = {}
	if _tmpSkillTable and next(_tmpSkillTable)~=nil and #_tmpSkillTable <1 then
		_tmpSkill[tostring(_tmpSkillTable.heroid)] = _tmpSkillTable
	else
		for k,v in pairs(_tmpSkillTable) do
			_tmpSkill[tostring(v.heroid)] = v
		end
	end
	--英雄数据添加，用heroid作为key值

	local _skill = {};
	for k,v in pairs(_tmpSkill) do
		_skill[tostring(k)] = {}
		_skill[tostring(k)]["talent"] = v[ "talentlv" ] or 0;
		_skill[tostring(k)]["skillid"] = v[ "skillidlv" ] or 0;
		_skill[tostring(k)]["skillid0"] = v[ "skillid0lv" ] or 0;
		_skill[tostring(k)]["skillid1"] = v[ "skillid1lv" ] or 0;
		_skill[tostring(k)]["skillid2"] = v[ "skillid2lv" ] or 0;
		_skill[tostring(k)]["skillid3"] = v[ "skillid3lv" ] or 0;
	end
	

	for k,v in pairs(DBUserHeroInfo) do
		tmpData[tostring(k)] = {}
		tmpData[tostring(k)]["scale"] = StaticHeroData[tostring(k)]["scale"];  --xx
		tmpData[tostring(k)]["attackrange"] = StaticHeroData[tostring(k)]["attackrange"]; -- xx
		tmpData[tostring(k)]["attackprocess"] = StaticHeroData[tostring(k)]["attackprocess"];
		
		if _skill[tostring(k)]["skillid"] == 0 then
			tmpData[tostring(k)]["attackprocess"] = string.gsub(tmpData[tostring(k)]["attackprocess"], "0", "");
		end
		if _skill[tostring(k)]["skillid1"] == 0 then
			tmpData[tostring(k)]["attackprocess"] = string.gsub(tmpData[tostring(k)]["attackprocess"], "1", "");
		end
		if _skill[tostring(k)]["skillid2"] == 0 then
			tmpData[tostring(k)]["attackprocess"] = string.gsub(tmpData[tostring(k)]["attackprocess"], "2", "");
		end
		if _skill[tostring(k)]["skillid3"] == 0 then
			tmpData[tostring(k)]["attackprocess"] = string.gsub(tmpData[tostring(k)]["attackprocess"], "3", "");
		end
		tmpData[tostring(k)]["name"] = StaticHeroData[tostring(k)]["name"];
		tmpData[tostring(k)]["description"] = StaticHeroData[tostring(k)]["description"]
		tmpData[tostring(k)]["autograph"] = StaticHeroData[tostring(k)]["autograph"]
		tmpData[tostring(k)]["type"] = StaticHeroData[tostring(k)]["type"]
		tmpData[tostring(k)]["rank"] = StaticHeroData[tostring(k)]["rank"]
		
		tmpData[tostring(k)]["id"] = v["heroid"];
		tmpData[tostring(k)]["level"] = v["level"];
		tmpData[tostring(k)]["star"] = v["star"];
		tmpData[tostring(k)]["advance"] = v["advance"];
		tmpData[tostring(k)]["curexp"] = v["curexp"];
		tmpData[tostring(k)]["maxexp"] = v["maxexp"];
		tmpData[tostring(k)]["hp"] = v["hp"]; -- 计算过的
		tmpData[tostring(k)]["physicalattack"] = v["physicalattack"];
		tmpData[tostring(k)]["physicaldefence"] = v["physicaldefence"];
		tmpData[tostring(k)]["manaattack"] = v["manaattack"];
		tmpData[tostring(k)]["manadefence"] = v["manadefence"];
		tmpData[tostring(k)]["hit"] = v["hit"];
		tmpData[tostring(k)]["dodge"] = v["dodge"];
		tmpData[tostring(k)]["crit"] = v["crit"];
		tmpData[tostring(k)]["crittimes"] = v["crittimes"];
		tmpData[tostring(k)]["anticrit"] = v["anticrit"];
		tmpData[tostring(k)]["antiattack"] = v["antiattack"];
		tmpData[tostring(k)]["attackbreak"] = v["attackbreak"];
		tmpData[tostring(k)]["antiphysicalattack"] = v["antiphysicalattack"];
		tmpData[tostring(k)]["physicalattackbreak"] = v["physicalattackbreak"];
		tmpData[tostring(k)]["antimanaattack"] = v["antimanaattack"];
		tmpData[tostring(k)]["manaattackbreak"] = v["manaattackbreak"];
		tmpData[tostring(k)]["suckblood"] = v["suckblood"];
		tmpData[tostring(k)]["heal"] = v["heal"];
		tmpData[tostring(k)]["behealed"] = v["behealed"];
		tmpData[tostring(k)]["antiangercost"] = v["antiangercost"];
		tmpData[tostring(k)]["hprecover"] = v["hprecover"];
		tmpData[tostring(k)]["angerrecover"] = v["angerrecover"];
		tmpData[tostring(k)]["heroid"] = v.heroid;
		tmpData[tostring(k)]["monsterid"] = 0;
		tmpData[tostring(k)]["power"] = v["power"];
		tmpData[tostring(k)]["neigongs"] = v["neigongs"];
		tmpData[tostring(k)]["petVeins"] = v["petVeins"];
		
		tmpData[tostring(k)]["beginanger"] = 0; -- 英雄没有初始怒气

		tmpData[tostring(k)]["equipments"] = {};

		tmpData[tostring(k)]["skills"] = {};
	end	
	return tmpData;
end
