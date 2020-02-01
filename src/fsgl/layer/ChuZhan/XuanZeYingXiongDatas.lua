-- FileName: XuanZeYingXiongDatas.lua
-- Author: wangming
-- Date: 2015-10-10
-- Purpose: 选将界面数据封装类
--[[TODO List]]

local mDatas = {
	_selectLayer = nil
}


function mDatas.init( layer )
	XTHD.dispatchEvent({name = CUSTOM_EVENT.RELEASE_MAINCITYBACK})
	local pLay = layer
	mDatas._selectLayer = pLay

	local pSize = pLay:getContentSize()

    -- 初始化英雄位置信息
	local beganX = pSize.width * 0.5 + (pSize.width * 0.07 + 30) * 2.5
	pLay._getPreviewItemPos = {1,2,3,4,5}
	for i=1,5 do
		local pPos = cc.p(0, 0)
		pPos.x = beganX - (pSize.width * 0.07 * i) - 30 * (i - 1)
		pPos.y = 180 + 15 * (i % 2 == 0 and 3 or 7)
		pLay._getPreviewItemPos[i] = pPos
	end

	-- 初始化可选英雄个数
	if pLay._battle_type == BattleType.EQUIP_PVE then
		pLay._hero_num_limit = tonumber(gameData.getDataFromCSV("ShenbinggeList", {["instancingid"]= pLay._instancingid })["herolimit"]) or 0
	elseif pLay._battle_type == BattleType.JADITE_COPY_PVE then
		pLay._hero_num_limit = tonumber(gameData.getDataFromCSV("TrialTower", {["instancingid"]= pLay._instancingid })["herolimit"]) or 0
	elseif pLay._battle_type == BattleType.OFFERREWARD_PVE or pLay._battle_type == BattleType.SINGLECHALLENGE then
		pLay._hero_num_limit = mDatas.getStageLimitNum()
		print("单挑之王关卡"..pLay._instancingid.."英雄限制数据"..pLay._hero_num_limit)
	elseif pLay._battle_type == BattleType.MULTICOPY_DEFENCE then
		pLay._hero_num_limit = 1
	else
		pLay._hero_num_limit = 5
	end
	if pLay._helps then
		pLay._hero_num_limit = pLay._hero_num_limit - #pLay._helps
	end


	local _heroData = {}
	local _table = DBTableHero.getData(gameUser.getUserId())
	if _table then 
		if #_table > 1 then 
			_heroData = _table
		else
			_heroData[1] = _table
		end 
	end
	if pLay._battle_type == BattleType.CAMP_PVP then
	  -- or pLay._battle_type == BattleType.ZHENQI_FIGHT_ROB 
	  -- or pLay._battle_type == BattleType.ZHENQI_FIGHT_OCCUPY then
		local pTb = {}
		for k,v in pairs(_heroData) do
			if not mDatas.checkHaveCampPvpDefDeadInfo(v.heroid) then
				table.insert(pTb, v)
			end
		end
		_heroData = pTb
	end

	-- 初始化当前选中信息
	if not mDatas.isPve() then
		pLay._PVP_Teams = {
			[1]={[1]={},["items"]={} },
			[2]={[1]={},["items"]={} },
			[3]={[1]={},["items"]={} },
		}
	end

	if pLay._battle_type == BattleType.OFFERREWARD_PVE
	  or pLay._battle_type == BattleType.ZHENQI_FIGHT_ROB 
	  or pLay._battle_type == BattleType.ZHENQI_FIGHT_OCCUPY
	  or pLay._battle_type == BattleType.MULTICOPY_DEFENCE
	  or pLay._battle_type == BattleType.SINGLECHALLENGE then

	elseif pLay._battle_type == BattleType.GUILDWAR_TEAM then
--	    if pLay._user_data and #pLay._user_data > 0 then
--	    	for k,v in pairs(pLay._user_data) do
--	    		local _tab = {heroid = v}
--				pLay._PVP_Teams[k][1][#pLay._PVP_Teams[k][1] + 1] =_tab
--	    	end
--	    end
		local _pve_heros = pLay._user_data
			local team_info, _tab, _heroId
			for i=1,#_pve_heros do
				team_info = _pve_heros[i]["team"]
				if team_info then
					for j=1,5 do
						_heroId = tonumber(team_info[j]) or 0
						if _heroId > 0 then
							_tab = {heroid = _heroId}
							if i == pLay._target_teamIndex and pLay._battle_type == BattleType.GUILDWAR_TEAM then
								pLay._PVP_Teams[i][1][#pLay._PVP_Teams[i][1] + 1] =_tab
							else
								pLay._PVP_Teams[i][1][#pLay._PVP_Teams[i][1] + 1] =_tab
							end
						end
					end
				end
			end
	elseif mDatas.isPve() then
		local _pve_heros = DBUserTeamData:getPVETeamData()
		if _pve_heros  then
			local pNum = pLay._hero_num_limit
			for i=1, 5 do
				local pId = tonumber(_pve_heros["heroid"..i]) or 0
				if pId  > 0 then
					if not mDatas.isHelpId(pId) and #pLay.m_heroItem < pNum then
						local canAdd = true
			    		if pLay._battle_type == BattleType.GODBEASE_PVE or pLay._battle_type == BattleType.SERVANT_PVE then
							local pData = pLay._godBeast_selfInfo[tostring(pId)]
							if pData then
								local _curNum = tonumber(pData["hp"]) or 0
								if _curNum == 0 then
									canAdd = false
			    				end
			    			end
						end
			    		if canAdd then
							local _tab = {heroid = _pve_heros["heroid"..i]}
							pLay.m_heroItem[#pLay.m_heroItem + 1]=_tab
						end
					end
				end
			end
		end
	else
		if pLay._battle_type == BattleType.PVP_DEFENCE or
		  pLay._battle_type == BattleType.CAMP_DEFENCE or
		  pLay._battle_type == BattleType.PVP_LADDER_DEFENCE or
		  pLay._battle_type == BattleType.PVP_DART_DEFENCE or
		  pLay._battle_type == BattleType.ZHENQI_DEFENCE then  --设置防守队伍信息
			local _pve_heros = pLay._user_data
			local team_info, _tab, _heroId
			for i=1,#_pve_heros do
				team_info = _pve_heros[i]["team"]
				if team_info then
					for j=1,5 do
						_heroId = tonumber(team_info[j]) or 0
						if _heroId > 0 then
							_tab = {heroid = _heroId}
							if i == pLay._target_teamIndex and pLay._battle_type == BattleType.CAMP_DEFENCE then
								pLay._PVP_Teams[i][1][#pLay._PVP_Teams[i][1] + 1] =_tab
							else
								pLay._PVP_Teams[i][1][#pLay._PVP_Teams[i][1] + 1] =_tab
							end
						end
					end
				end
			end
		else
			local _pve_heros = DBUserTeamData:getPVPTeamData()
			local _tab, _heroId
			for i=1,#_pve_heros do
				for j=1,5 do
					_heroId = tonumber(_pve_heros[i]["heroid"..j]) or 0
					if _heroId > 0 then
						local isCan = true
						if pLay._battle_type == BattleType.CAMP_PVP then
							local isHave = false
							for k,v in pairs(_heroData) do
								if v.heroid == _heroId then
									isHave = true
								end
							end
							if not isHave then
								isCan = false
							end
						end
						if isCan then
							_tab = {heroid = _heroId}
							pLay._PVP_Teams[i][1][#pLay._PVP_Teams[i][1] + 1] =_tab
						end
					end
				end
			end
		end
	end

	-----初始化可选英雄数据
	


	-- 准备预加载用得数据
	pLay._totalHeroData = {}
    pLay._heroIdCacheTb = {}
    pLay._canNotSelectNum = 0
    pLay._forcedNum = 0

	for i = 1, #_heroData do
    	local _heroId = _heroData[i]["heroid"]
    	if _heroId then
	    	local _data = HeroDataInit:InitHeroDataSelectHero( _heroId )
	    	
	    	if pLay._battle_type == BattleType.MULTICOPY_DEFENCE then
	    		if _data.advance < pLay._multiQuiltyNum then
	    			_data.isForcedCannot = true
	    			pLay._canNotSelectNum = pLay._canNotSelectNum + 1
	    		elseif _data.heroid == pLay._multiId and pLay._multiId ~= -1 then 
	    			local _tab = {heroid = _data["heroid"], attackrange = _data["attackrange"]}
					pLay.m_heroItem[#pLay.m_heroItem + 1] = _tab
	    			pLay._total_power = tonumber(pLay._total_power) + tonumber(_data["power"])
	    			table.insert(pLay._heroIdCacheTb, {id = _heroId, atk = _data["attackrange"]})
	    		end
	    	elseif pLay._battle_type == BattleType.OFFERREWARD_PVE or pLay._battle_type == BattleType.SINGLECHALLENGE then
	    		if mDatas.isForcedIdCan(_heroId) then
	    			pLay._forcedNum = pLay._forcedNum + 1
	    			_data.isForcedCan = true
	    			local _tab = {heroid = _data["heroid"], attackrange = _data["attackrange"]}
					pLay.m_heroItem[#pLay.m_heroItem + 1] = _tab
	    			pLay._total_power = tonumber(pLay._total_power) + tonumber(_data["power"])
	    			table.insert(pLay._heroIdCacheTb, {id = _heroId, atk = _data["attackrange"]})
	    		elseif mDatas.isForcedIdCannot(_heroId) then
	    			_data.isForcedCannot = true
	    			pLay._canNotSelectNum = pLay._canNotSelectNum + 1
	    		end
--			elseif pLay._battle_type == BattleType.GUILDWAR_TEAM then
--				for i=1,#pLay._PVP_Teams do
--		    		local idx_list	= pLay._PVP_Teams[i][1]
--		    		for j=1,#idx_list do
--		    			if idx_list[j]["heroid"] ==  tonumber(_heroId) then
--		    				idx_list[j]["attackrange"] = _data["attackrange"]
--		    				idx_list[j]["power"] =_data["power"]
--		    				pLay.m_heroItem[#pLay.m_heroItem+1] = idx_list[j]
--		    				break
--		    			end
--					end
--				end
	    	elseif mDatas.isPve() then
		    	for k=1, #pLay.m_heroItem do
		    		local pId = tonumber(pLay.m_heroItem[k]["heroid"]) or 0
		    		if pId == tonumber(_heroId) then
		    			pLay.m_heroItem[k]["attackrange"] =_data["attackrange"]
		    			pLay._total_power = tonumber(pLay._total_power) + tonumber(_data["power"])
		    			table.insert(pLay._heroIdCacheTb, {id = _heroId, atk = _data["attackrange"]})
		    			break
		    		end
		    	end
		    else --添加PVP 队伍英雄的攻击范围信息
		    	for i=1,#pLay._PVP_Teams do
		    		local idx_list	= pLay._PVP_Teams[i][1]
		    		for j=1,#idx_list do
		    			if idx_list[j]["heroid"] ==  tonumber(_heroId) then
		    				idx_list[j]["attackrange"] = _data["attackrange"]
		    				idx_list[j]["power"] =_data["power"]
		    				pLay.m_heroItem[#pLay.m_heroItem+1] = idx_list[j]
		    				break
		    			end
			    	end
			    end
			    if pLay._battle_type == BattleType.PVP_DART_DEFENCE
			      or pLay._battle_type == BattleType.ZHENQI_DEFENCE then
			    	if mDatas.isTargetInOtherTeam(_heroId) then
			    		_data.isForcedCannot = true
			    		pLay._canNotSelectNum = pLay._canNotSelectNum + 1
		    		elseif _heroData[i].star < pLay._selfHeroLimitStar then
		    			_data.isForcedCannot = true
			    		pLay._canNotSelectNum = pLay._canNotSelectNum + 1
			    	end
			    end
		    end
	    	pLay._totalHeroData[#pLay._totalHeroData+1] = _data
	    end
    end

    if pLay._helps and #pLay._helps > 0 then
		for i = 1, #pLay._helps do
			local _data = pLay._helps[i]
			_data.isHelp = true
	    	local _heroId = tonumber(_data["heroid"]) or 0 	
			table.insert(pLay._heroIdCacheTb, {id = _heroId, atk = _data["attackrange"], data = _data})
    		pLay._totalHeroData[#pLay._totalHeroData+1] = _data
		end
	end

    local function _sortDatas( data1, data2 )
    	if data1.isHelp ~= data2.isHelp then
    		return not data1.isHelp
    	end

    	if data1.isForcedCan ~= data2.isForcedCan then
    		return data1.isForcedCan
    	end

    	if data1.isForcedCannot ~= data2.isForcedCannot then
    		return not data1.isForcedCannot
    	end

		if data1["level"] ~= data2["level"]  then
		    return tonumber(data1["level"]) > tonumber(data2["level"])
		end
		if tonumber(data1["star"]) ~= tonumber(data2["star"]) then
			return tonumber(data1["star"]) > tonumber(data2["star"])
		end
		if tonumber(data1["attackrange"]) ~= tonumber(data2["attackrange"]) then
			return tonumber(data1["attackrange"]) > tonumber(data2["attackrange"])
		end
		
		return tonumber(data1["heroid"]) > tonumber(data2["heroid"])
    end
	table.sort(pLay._totalHeroData, _sortDatas)
	
	local function sortCahche( data1, data2 )
		local num1 = tonumber(data1["atk"]) or 0
		local num2 = tonumber(data2["atk"]) or 0
		if num1 ~= num2 then
			return num1 < num2
		end
		num1 = tonumber(data1["id"]) or 0
		num2 = tonumber(data2["id"]) or 0
		return num1 < num2
	end
	table.sort(pLay._heroIdCacheTb, sortCahche)

	if pLay._helps and #pLay._helps > 0 then
		local isInLevel
		local mInstancingid = tonumber(pLay._instancingid) or -1
		local pData = gameData.getDataFromCSV("ExploreInfoList", {["instancingid"] = mInstancingid})
		if pData and (pData.chapterid == 1 or pData.chapterid == 2) then
			isInLevel = true
		end
		if not isInLevel then
			return
		end
		pLay._newHelps = {}
		pData = gameData.getDataFromCSV("ExploreInfoList", {["instancingid"] = mInstancingid - 1})
		local lastHelps
		if pData then
			lastHelps = string.split(pData.help, '#')
		end
		lastHelps = lastHelps or {}
		for k,v in pairs(pLay._helps) do
			local pHid = tostring(v.monsterid)
			local pLenth = string.len(pHid)
			pHid = string.sub(pHid, pLenth-2, pLenth)
			local isNew = true
			for key,value in pairs(lastHelps) do
				local pHid2 = tostring(value)
				local pLenth2 = string.len(pHid2)
				pHid2 = string.sub(pHid2, pLenth2-2, pLenth2)
				if pHid == pHid2 then
					isNew = false
					break
				end
			end
			if isNew then
				pLay._newHelps[#pLay._newHelps + 1] = v
			end
		end

		local function sortHelp( data1, data2 )
			local num1 = tonumber(data1["attackrange"]) or 0
			local num2 = tonumber(data2["attackrange"]) or 0
			if num1 ~= num2 then
				return num1 > num2
			end
			num1 = tonumber(data1["heroid"]) or 0
			num2 = tonumber(data2["heroid"]) or 0
			return num1 > num2
		end
		table.sort(pLay._newHelps, sortHelp)
	end
end

function mDatas.isNewHelps( heroid )
	local pLay = mDatas._selectLayer
	if not pLay._newHelps or #pLay._newHelps <= 0 then
		return false
	end
	for k,v in pairs(pLay._newHelps) do
		if tonumber(v.heroid) == heroid then
			return true
		end
	end
	return false
end

function mDatas.getBackFileStr( )
	local bg_imgpath = ""
	local pLay = mDatas._selectLayer
	local mInstancingid = tonumber(pLay._instancingid) or -1
	if mInstancingid ~= -1 then
		local pString
		local _key = "instancingid"
		if pLay._battle_type == BattleType.PVE then
			pString = "ExploreInfoList"
		elseif pLay._battle_type == BattleType.ELITE_PVE then
			pString = "EliteCopyList"
		elseif pLay._battle_type == BattleType.DIFFCULTY_COPY then
			pString = "NightmareCopyList"
		elseif pLay._battle_type == BattleType.EQUIP_PVE  then
			pString = "ShenbinggeList"
		elseif pLay._battle_type == BattleType.JADITE_COPY_PVE  then  --翡翠副本
			pString = "TrialTower"
		elseif pLay._battle_type == BattleType.OFFERREWARD_PVE then
			pString = "XsTaskList"
		elseif pLay._battle_type == BattleType.MULTICOPY_DEFENCE then
			pString = "TeamCopyList"
			_key = "id"
		elseif pLay._battle_type == BattleType.GUILD_BOSS_PVE then
			pString = "SectBoss"
			_key = "id"
		end
		if pString then
			local background_data = gameData.getDataFromCSV(pString, {[_key] = mInstancingid})["background"] or 1
			local __tab = background_data
			if pLay._battle_type ~= BattleType.JADITE_COPY_PVE  then  --翡翠副本
				__tab = string.split(background_data, '#')[1]
			end
			bg_imgpath = "res/image/background/bg_" .. __tab .. ".jpg"
		end
	end
	if pLay._battle_type == BattleType.WORLDBOSS_PVE then
		bg_imgpath = "res/image/worldboss/unOpenBack0.png"
	elseif pLay._battle_type == BattleType.GOLD_COPY_PVE then
		bg_imgpath = "res/image/background/bg_44.jpg"
	elseif pLay._battle_type == BattleType.PVP_DART_DEFENCE then
		bg_imgpath = "res/image/background/bg_2.jpg"
	elseif pLay._battle_type == BattleType.PVP_CUTGOODS then
	    local pId = math.random(1,3)
		bg_imgpath = "res/image/background/bg_"..pId..".jpg"
	elseif pLay._battle_type ~= BattleType.PVE
	  and pLay._battle_type ~= BattleType.ELITE_PVE
	  and pLay._battle_type ~= BattleType.DIFFCULTY_COPY
	  and pLay._battle_type ~= BattleType.EQUIP_PVE
	  and pLay._battle_type ~= BattleType.JADITE_COPY_PVE
	  and pLay._battle_type ~= BattleType.OFFERREWARD_PVE
		then
		bg_imgpath = "res/image/plugin/competitive_layer/pvp_battle_bg.jpg"
	end
	if not cc.Director:getInstance():getTextureCache():addImage(bg_imgpath) then
		bg_imgpath = "res/image/background/bg_1.jpg"
	end
	return bg_imgpath
end

function mDatas.isHelpId( sId )
	local pLay = mDatas._selectLayer
	if pLay._helps then
		for k,v in pairs(pLay._helps) do
			if v.heroid == sId then
				return true
			end
		end
	end
	return false
end

function mDatas.getAniId( id )
	local nId = tostring(id)
	if string.len(nId) == 1 then
		nId = "00" .. nId
	elseif string.len(id) == 2 then
		nId = "0" .. nId
	end
	return nId
end

function mDatas.isPve( ... )
	local pLay = mDatas._selectLayer
	if pLay._battle_type == BattleType.EQUIP_PVE 
	  or pLay._battle_type == BattleType.PVE 
	  or pLay._battle_type == BattleType.ELITE_PVE 
	  or pLay._battle_type == BattleType.GODBEASE_PVE or pLay._battle_type == BattleType.SERVANT_PVE
	  or pLay._battle_type == BattleType.GOLD_COPY_PVE 
	  or pLay._battle_type == BattleType.JADITE_COPY_PVE
	  or pLay._battle_type == BattleType.WORLDBOSS_PVE
	  or pLay._battle_type == BattleType.GUILD_BOSS_PVE
	  or pLay._battle_type == BattleType.DIFFCULTY_COPY
	then
		return true
	end
	return false
end

function mDatas.getStateInfo( ... )
	local pLay = mDatas._selectLayer
	if pLay._battle_type ~= BattleType.OFFERREWARD_PVE and pLay._battle_type ~= BattleType.SINGLECHALLENGE then
		return nil
	end
	local mInstancingid = tonumber(pLay._instancingid) or -1
	if mInstancingid == -1 then
		return nil
	end
	if pLay._battle_type == BattleType.OFFERREWARD_PVE then
        return gameData.getDataFromCSV("XsTaskList", {["instancingid"] = mInstancingid})
    elseif pLay._battle_type == BattleType.SINGLECHALLENGE then
        return gameData.getDataFromCSV("OneVsOne", {["instancingid"] = mInstancingid})
	end
end

function mDatas.getStageLimitNum( ... )
	local pNum = 5
	local _stateData = mDatas.getStateInfo()
	if not _stateData then
		return pNum
	end
	local pType = tonumber(_stateData.condition1) or 0
	if pType == 4 then
		pNum = tonumber(_stateData.value1) or 0
	end
	local pType = tonumber(_stateData.condition2) or 0
	if pType == 4 then
		pNum = tonumber(_stateData.value2) or 0
	end
	return pNum
end

function mDatas.isForcedIdCan( id )
	local _stateData = mDatas.getStateInfo()
	if not _stateData then
		return false
	end
	local function _checkHave( sCond, sValue)
		local _cond = tonumber(sCond) or 0
		if _cond ~= 1 then
			return false
		end
		local _tab = string.split(sValue or "", '#') or {}
		for k,v in pairs(_tab) do
			local pV = tonumber(v) or 0
			if pV == id then
				return true
			end
		end
		return false
	end
	if _checkHave(_stateData.condition1, _stateData.value1) then
		return true
	end
	return _checkHave(_stateData.condition2, _stateData.value2)
end

function mDatas.isForcedIdCannot( id )
	local _stateData = mDatas.getStateInfo()
	if not _stateData then
		return false
	end
	local function _checkHave( sCond, sValue)
		local _cond = tonumber(sCond) or 0
		if _cond ~= 2 then
			if mDatas.isNotOnlyUseType(id) then
				return true
			end
			return false
		end
		local _tab = string.split(sValue or "", '#') or {}
		for k,v in pairs(_tab) do
			local pV = tonumber(v)
			if pV == id then
				return true
			end
		end
		return false
	end
	if _checkHave(_stateData.condition1, _stateData.value1) then
		return true
	end
	return _checkHave(_stateData.condition2, _stateData.value2) 
end

function mDatas.isNotOnlyUseType( id )
	local _stateData = mDatas.getStateInfo()
	if not _stateData then
		return false
	end
	local function _checkHave( sCond, sValue)
		local _cond = tonumber(sCond) or 0
		if _cond ~= 3 then
			return false
		end
		local _type = 0
		local _data = gameData.getDataFromCSV("GeneralInfoList", {["heroid"] = id})

		if _data then
			_type = tonumber(_data.type) or 0
		end
		local _tab = string.split(sValue or "", '#') or {}
		local pB = true
		for k,v in pairs(_tab) do
			local pV = tonumber(v)
			if _type ~= 0 and _type == pV then
				pB = false
				break
			end
		end
		return pB
	end
	if _checkHave(_stateData.condition1, _stateData.value1) then
		return true
	end
	return _checkHave(_stateData.condition2, _stateData.value2) 
end

function mDatas.haveCanOnTeam( ... )
	local pLay = mDatas._selectLayer
	local _numNow = #pLay.m_heroItem
	local _numTotle = #pLay._totalHeroData
	local _helpNum = pLay._helps and #pLay._helps or 0
	local _deathNum = 0
	if pLay._battle_type == BattleType.GODBEASE_PVE or pLay._battle_type == BattleType.SERVANT_PVE then
		local _tb = pLay._godBeast_selfInfo
		if _tb then
			for k,v in pairs(_tb) do
				local _curNum = tonumber(v.hp) or 0
				if _curNum == 0 then
					_deathNum = _deathNum + 1
				end
			end
		end
	end

	local canUseNum = _numTotle - pLay._canNotSelectNum - _helpNum - _deathNum
	if #pLay._Spine_List < pLay._hero_num_limit and _numNow < canUseNum then
		return true
	end
	return false
end

function mDatas.isTargetInOtherTeam( sId )
	local pId = mDatas.getTargetOtherTeam(sId)
	if pId ~= 0 then
		return true
	end
	return false
end

function mDatas.getTargetOtherTeam( sId )
	local pLay = mDatas._selectLayer
	if pLay._battle_type ~= BattleType.PVP_DART_DEFENCE
	  and pLay._battle_type ~= BattleType.ZHENQI_DEFENCE then
		return 0
	end

	for i=1, #pLay._teamTable do
		if i ~= pLay._dartType then
			local pTeam = pLay._teamTable[i]
			for k,v in pairs(pTeam) do
				if tonumber(v) == sId then
					return i
				end
			end
		end
	end
	return 0
end

function mDatas.isTargetInOtherPvpTeam( sId )
	local pId = mDatas.getTargetPvpTeam(sId)
	if pId ~= 0 then
		return true
	end
	return false
end

function mDatas.getTargetPvpTeam( sId )
	local pLay = mDatas._selectLayer
	if pLay._battle_type ~= BattleType.CAMP_DEFENCE then
		return 0
	end

	for i=1, #pLay._PVP_Teams do
		if i ~= pLay._dartType then
			local pTeam = pLay._teamTable[i]
			for k,v in pairs(pTeam) do
				if tonumber(v) == sId then
					return i
				end
			end
		end
	end
	return 0
end

function mDatas.checkHaveCampPvpDefDeadInfo( cId )
	local pLay = mDatas._selectLayer
	if pLay._battle_type ~= BattleType.CAMP_PVP 
	  and pLay._battle_type ~= BattleType.ZHENQI_FIGHT_ROB 
	  and pLay._battle_type~= BattleType.ZHENQI_FIGHT_OCCUPY then
		return false
	end
	local pLength = pLay._camp_pvp_def_data and #pLay._camp_pvp_def_data or 0
	local pID = tonumber(cId) or -1
	for i=1, pLength do
		local pNum = tonumber(pLay._camp_pvp_def_data[i]) or 0
		if(pID == pNum) then
			return true
		end
	end
	return false
end
	
return mDatas