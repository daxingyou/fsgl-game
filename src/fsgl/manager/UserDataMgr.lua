--全局玩家临时数据,后期运营活动的开启与否也可以用此处管理
UserDataMgr={}
UserDataMgr._buildData = {}
UserDataMgr._PreSpine = {
	"res/spin/001", ---熊猫
	"res/spin/302", ----鳄鱼
	"res/spin/013", ----毛牛
}
------------------------------------------------------------------------------------------------------------------------
------------------------主城建筑
-----登陆时存储主城建筑数据 
function UserDataMgr:setMainCityData( data )
	self._mainCity_data = data ---主城建筑服务器数据 
end
----
function UserDataMgr:getMainCityData(  )
	return self._mainCity_data or {}
end
---更新主城建筑的数据(产出，等级，加速状态)
function UserDataMgr:updateCityBuild(data)	
	self:setBuildClock()
	if data then 
		local isHave = false
		if not self._mainCity_data or not self._mainCity_data.builds then 
			return 
		end 
		for k,v in pairs(self._mainCity_data.builds) do 
			if tonumber(v.buildId) == tonumber(data.buildId) then 
				for _k,_v in pairs(data) do 
					v[_k] = _v
				end 
				isHave = true
			end 
		end 
		if not isHave then 
			self._mainCity_data.builds[#self._mainCity_data.builds + 1] = data
		end 
	    -----将建筑产出的相关数据存入
	    self:pushBuildingData(data)
		XTHD.dispatchEvent({ ---刷新主城建筑
	    	name = CUSTOM_EVENT.REFRESH_CITY_BUILDINGS,
	    	data = data,
	    })
	end 
end

function UserDataMgr:popBuildingData( id )
	if self._buildData and self._buildData[id] then 
		self._buildData[id] = nil
	end 
end

function UserDataMgr:pushBuildingData( data )
    if self._buildData == nil then 
    	self._buildData = {}
    end 
    local Okay = false
    for k,v in pairs(self._buildData) do 
    	if v.buildId == data.buildId then 
    		v = data
    		Okay = true	    		
    		break 
    	end 
    end 
    if not Okay then 
    	self._buildData[data.buildId] = data
    end 
end

function UserDataMgr:getCityDataByID( id )
	if id then 
		for k,v in pairs(self._mainCity_data.builds) do 
			if tonumber(v.buildId) == tonumber(id) then 
				return v
			end 
		end 
	end 
	return nil
end

function UserDataMgr:getBuildingsStaticData( )
	if not self._cityBuildingsData then  ---主城建筑静态数据 
		self._cityBuildingsData = gameData.getDataFromCSV("LayoutOfBuilding")
	end 
	return self._cityBuildingsData
end

---根据建筑的id ,等级返回该建筑的本地数据与服务器数据 
function UserDataMgr:getTheSpecifiedBuildingsData(id,level)
	local data = {}
	if id and level then 
		if self._cityBuildingsData and self._mainCity_data then 
			for k,v in pairs(self._cityBuildingsData) do 
				if tonumber(v.buildingid) == tonumber(id) and tonumber(v.level) == tonumber(level) then 
					data.localData = v
					break
				end 
			end 
			for k,v in pairs(self._mainCity_data.builds) do 
				if tonumber(v.buildId) == tonumber(id) and tonumber(v.level) == tonumber(level) then 
					data.serverData = v
					break
				end 
			end 
		end 
		return data
	end 
	return nil
end
-----获取一个建筑可升到的最大级数 
function UserDataMgr:getBuildingMaxLevel( id )
	self:getBuildingsStaticData()
	if id and self._cityBuildingsData then 
		local level = {}
		local i = 1
		for k,v in pairs(self._cityBuildingsData) do 
			if tonumber(v.buildingid) == tonumber(id) then 
				level[i] = tonumber(v.level)
				i = i + 1
			end 
		end 
		if #level > 0 then 
			return math.max(unpack(level))
		end 
	end 
	return 0
end

function UserDataMgr:getBuildClock( )
	return self.buildClock or os.time()
end

function UserDataMgr:setBuildClock( )
	self.buildClock = os.time()
end
----预加载spine
function UserDataMgr:preLoadSpine( )
	for k,v in pairs(self._PreSpine) do 
		sp.SkeletonAnimation:create(v..".json", v..".atlas", 1.0)
	end 
end

function UserDataMgr:preLoadSpine()    
    local _spine = {
        "res/image/homecity/frames/spine/shengdian",
        "res/image/homecity/frames/spine/abj",
        "res/image/homecity/frames/spine/ck",
    }
    for k,v in pairs(_spine) do 
        sp.SkeletonAnimation:create(v..".json",v..".atlas", 1.0)
    end 
end
------------------------------------------------------------------------------------------------------------------------