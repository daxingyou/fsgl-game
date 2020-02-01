DBUserTeamData = {}
DBUserTeamData.DBData = {}

--[[
	该数据表的设计为：
	teamid ：1 pve 队伍信息
	teamid ：101-103 pvp队伍信息


	注：以后添加新的副本队伍信息，则可以自己定义teamid 的范围，
	之所以这么做，是想把所有的队伍信息集中在一个数据表中，虽然可能会给后来者造成困惑，但是编写此处的时候还是要这么做，理由就是前面说的

	最好把队伍信息的存储和读取全部放在内部来实现，这样使用者不用关心teamid 的问题。^_^
BattleType = {}
BattleType.PVE = 0 -- 玩家和怪物战斗
BattleType.PVP_CHALLENGE = 1 -- 竞技场挑战掠夺
BattleType.ELITE_PVE = 2 -- 精英副本
BattleType.GODBEASE_PVE = 3 -- 神兽副本
BattleType.CAMP_PVP 	= 4--种族pvp  战斗
BattleType.GOLD_COPY_PVE = 5 --银两副本
BattleType.JADITE_COPY_PVE = 6  --翡翠副本
BattleType.EQUIP_PVE = 7 -- 装备副本
BattleType.PVP_LADDER=8 --排位赛

BattleType.CAMP_DEFENCE = 100 -- 种族pvp 设置防守队伍
BattleType.PVP_DEFENCE = 101 -- pvp 设置防守队伍
BattleType.PVP_LADDER_DEFENCE = 102 --排位赛防守队伍


	]]
function DBUserTeamData:InsertData( param )
	local Params = {};
	Params["teamid"] 	= tonumber(param["teamid"])
	Params["heroid1"] 	= tonumber(param["heroid1"]) or 0
	Params["heroid2"] 	= tonumber(param["heroid2"]) or 0
	Params["heroid3"] 	= tonumber(param["heroid3"]) or 0
	Params["heroid4"] 	= tonumber(param["heroid4"]) or 0
	Params["heroid5"] 	= tonumber(param["heroid5"]) or 0

	DBUserTeamData.DBData[Params.teamid] = Params	
end

--普通股本的队伍信息存储
function DBUserTeamData:UpdatePVETeamData(team_data)
	if DBUserTeamData.DBData[0] then 
		for k,v in pairs(team_data) do 
			DBUserTeamData.DBData[0][k] = tonumber(v)
		end 
	else 
		team_data.teamid = 0
		DBUserTeamData:InsertData( team_data )		
	end 
end
function DBUserTeamData:initPveTeamData()
	if not DBUserTeamData.DBData[0] or next(DBUserTeamData.DBData[0]) == nil then
		return
	end
	local _tb = {}
	for k,v in pairs(DBUserTeamData.DBData[0]) do
		if k == teamid then
			_tb[k] = v
		else
			local _data = DBTableHero.getData(gameUser.getUserId(), {heroid = v})
			local _next = next(_data)
			if _next ~= nil then
				_tb[k] = v
			end
		end
	end
	DBUserTeamData.DBData[0] = _tb
end
--获取信息
function DBUserTeamData:getPVETeamData()
	return DBUserTeamData.DBData[0]
end
--PVP队伍信息的存储
function DBUserTeamData:UpdatePVPTeamData(param)	
	for i=1,#param do
		if DBUserTeamData.DBData[100 + i] then 
			for k,v in pairs(param[i]) do 
				DBUserTeamData.DBData[100 + i][k] = tonumber(v)
			end 
		else 			
			param[i]["teamid"] = 100+i
			DBUserTeamData:InsertData(param[i])
		end 
	end
end
--获取信息
function DBUserTeamData:getPVPTeamData()
	local _result_list = {}
	for i = 1,3 do
		local data = DBUserTeamData.DBData[100 + i] or {}		
		_result_list[#_result_list+1] = data
	end
	return _result_list
end
-----更新队伍数据信息
function DBUserTeamData:updateATeamData( param )
	if param then 
		DBUserTeamData:InsertData(param)
	end 
end

function DBUserTeamData:updateMultiTeamData( param )
	if param then 
		for k,v in pairs(param) do 
			DBUserTeamData:InsertData(v)
		end 
	end 
end

function DBUserTeamData:getTeamDataByType( _type )
	if _type then 
		return DBUserTeamData.DBData[_type]
	end 
end