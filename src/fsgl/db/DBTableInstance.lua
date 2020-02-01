--[[副本表]]
DBTableInstance = {};
DBTableInstance.InstancingDBData = {}
DBTableInstance.EliteInstancingDBData = {}
DBTableInstance.InstancingRewardDBData = {}

DB_TABLE_NAME_INSTANCING = "instancing"
DB_TABLE_NAME_INSTANCING_ELITE = "eliteinstancing"
DB_TABLE_NAME_INSTANCING_REWARD = "instancingreward"

--/**********************  普通副本 普通副本 普通副本 ***********************/
--EliteInstancing
function DBTableInstance.insertData(userid, param )	
	local Params = {};
	Params["id"]	 = tonumber(param["id"])
	Params["star"]	 = tonumber(param["star"])
	DBTableInstance.InstancingDBData[Params.id] = Params
end
--插入多条数据
function DBTableInstance.insertMulitData(userid,params )
	for i=1,#params do
		DBTableInstance.insertData(userid,params[i])
	end
end

function DBTableInstance.getStar(userid,instancing_id )
	instancing_id = tonumber(instancing_id)
	local data = DBTableInstance.InstancingDBData[instancing_id]
	if data then 
		return data.star
	else 
		return 0
	end 
end

function DBTableInstance.updateStar(userid, star, id )
	id = tonumber(id)
	if id and DBTableInstance.InstancingDBData[id] and DBTableInstance.InstancingDBData[id].star then 
		DBTableInstance.InstancingDBData[id].star = tonumber(star)
	end 
end



--/**********************  精英副本 精英副本 精英副本 ***********************/
--EliteInstancing
function DBTableInstance.insertEliteData( userid,param )
	local Params = {};
	Params["id"] 				= tonumber(param["id"])
	Params["star"] 				= tonumber(param["star"])
	Params["last_fight_times"] 	= tonumber(param["last_fight_times"]) --s剩余挑战次数
	Params["reset_times"] 		= tonumber(param["reset_times"])		--重置次数
	
	DBTableInstance.EliteInstancingDBData[Params.id] = Params
end

--获取剩余挑战次数
function DBTableInstance.getEliteFightTimes(userid,instancing_id)
	instancing_id = tonumber(instancing_id)
	local data = DBTableInstance.EliteInstancingDBData[instancing_id] 
	if data then 
		return data.last_fight_times
	else 
		return 0
	end 
end
--更新精英副本挑战次数
function DBTableInstance.updateEliteFightTimes(userid,instancing_id,_last_fight_time)
	instancing_id = tonumber(instancing_id)
	if instancing_id and DBTableInstance.EliteInstancingDBData[instancing_id] then 
		DBTableInstance.EliteInstancingDBData[instancing_id].last_fight_times = tonumber(_last_fight_time)
	end 
end

function DBTableInstance.getEliteResetTimes(userid,instancing_id)
	instancing_id = tonumber(instancing_id)
	local data = DBTableInstance.EliteInstancingDBData[instancing_id] 
	if data then 
		return data.reset_times
	else 
		return 0
	end 
end

function DBTableInstance.updateEliteResetTimes(userid,instancing_id ,reset_time)
	instancing_id = tonumber(instancing_id)
	if instancing_id then 
		if DBTableInstance.EliteInstancingDBData[instancing_id] then 
			DBTableInstance.EliteInstancingDBData[instancing_id].reset_times = tonumber(reset_time)
		end 
	else
		for k,v in pairs(DBTableInstance.EliteInstancingDBData) do 
			v.reset_times = tonumber(reset_time)
		end 
	end 
end

--插入多条数据
function DBTableInstance.insertMulitEliteData(userid,params)
	for i=1,#params do
		DBTableInstance.insertEliteData(userid,params[i])
	end
end

function DBTableInstance.getEliteStar(userid , instancing_id )
	instancing_id = tonumber(instancing_id)
	local data = DBTableInstance.EliteInstancingDBData[instancing_id] 
	if data then 
		return data.star
	else 
		return 0
	end
end

function DBTableInstance.updateEliteStar(userid , star, id )	
	id = tonumber(id)
	if id and DBTableInstance.EliteInstancingDBData[id] then 
		DBTableInstance.EliteInstancingDBData[id].star = tonumber(star)
	end 
end



--/**********************  章节宝箱领奖状态 章节宝箱领奖状态 章节宝箱领奖状态 ***********************/
--EliteInstancing
function DBTableInstance.insertRewardData(userid , param )
	local Params = {};
	Params["chapterid"] 		= tonumber(param["chapterid"])
	Params["normal_times"] 		= param["normal_times"] or "0";
	Params["elite_times"] 		= param["elite_times"] or "0";
	
	DBTableInstance.InstancingRewardDBData[Params.chapterid] = Params
end
--插入多条数据
function DBTableInstance.insertMulitRewardData(userid ,params )
	for i=1,#params do
		DBTableInstance.insertRewardData(userid,params[i])
	end
end
--更新精英副本领奖次数
function DBTableInstance.updateRwardTimes(userid ,chapterid,times)
	chapterid = tonumber(chapterid)
	if chapterid and DBTableInstance.InstancingRewardDBData[chapterid] then 
		DBTableInstance.InstancingRewardDBData[chapterid].normal_times = times 
	end 
end
--更新精英副本领奖次数
function DBTableInstance.updateEliteRwardTimes(userid ,chapterid,times)
	chapterid = tonumber(chapterid)
	if chapterid and DBTableInstance.InstancingRewardDBData[chapterid] then 
		DBTableInstance.InstancingRewardDBData[chapterid].elite_times = times 
	end 
end