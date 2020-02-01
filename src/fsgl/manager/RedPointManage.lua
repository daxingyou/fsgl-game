--created by xingchen
RedPointManage = {};
--一定要及时刷新动态数据
function RedPointManage:startSetRedpoint()
	self._heroOperateKey = {"isCanEquip","isCanStreng","isCanLevelUp","isCanSkillUp","isCanAdvance","isCanStarUp"}
	self.heroredpointState = nil
	self:setData()
end
function RedPointManage:setData()
	self:setStaticData()
	self:setDynamicData()
end

---------------------------合成Began---------------------------------
function RedPointManage:getComposeRedPointState()
	local _ishaveRedpointOrnot = false
	_ishaveRedpointOrnot = self:getComposeFoundationRedPoint()
	return _ishaveRedpointOrnot
end
function RedPointManage:setComposeFoundationRedPoint()
	self.composeredpointState = false
	self.composeRedPoint = {}

	self:resetComposeRedPoint()
	
	--如果未解锁，返回false
	local _composeOpenBool = isTheFunctionAvailable(28)
	if _composeOpenBool~=nil and _composeOpenBool == false then
		return
	end
	
	--[[
	合成分成三部分，药剂，材料，玄符.
	只要碰到达到合成条件的，就返回。
	]]
	for i=1,#self.itemComposeData do
	-- for k,v in pairs(self.itemComposeData) do
		self.composeredpointState = self:getTabComposeRedPoint(i)
		if self.composeredpointState == true then
			break
		end
	end
end
function RedPointManage:resetComposeRedPoint()
	self.composeRedPoint = {}
	self.composeRedPoint.redpointState = nil
	for i=1,#self.itemComposeData do
	-- for k,v in pairs(self.itemComposeData) do
		self:resetComposeTabRedPoint(i)
	end
end
function RedPointManage:resetComposeTabRedPoint(_itemtype)
	self.composeRedPoint[tonumber(_itemtype or 1)] = {}
	self.composeRedPoint[tonumber(_itemtype or 1)].redpointState = nil
	for i=1,#self.itemComposeData[tonumber(_itemtype)] do
		self:resetItemRedPoint(_itemtype,i)
	end
end
function RedPointManage:resetItemRedPoint(_itemtype,_idx)
	self.composeRedPoint[tonumber(_itemtype or 1)][tonumber(_idx or 1)] = {}
	self.composeRedPoint[tonumber(_itemtype or 1)][tonumber(_idx or 1)].redpointState = nil
end

function RedPointManage:getComposeFoundationRedPoint()
	self:setComposeFoundationRedPoint()
	return self.composeredpointState
end

function RedPointManage:setTabComposeRedPoint(_itemtype)
	self.composeRedPoint[tonumber(_itemtype or 1)].redpointState = false
	for i=1,#self.itemComposeData[tonumber(_itemtype)] do
		self.composeRedPoint[tonumber(_itemtype or 1)].redpointState = self:getItemComposeRedPoint(_itemtype,i)
		if self.composeRedPoint[tonumber(_itemtype or 1)].redpointState == true then
			break
		end
	end
end

function RedPointManage:setItemComposeRedPoint(_itemtype,_idx)
	local _boolCompose = false
	_boolCompose = self:isCanCompose(_itemtype,_idx)
	self.composeRedPoint[tonumber(_itemtype)][tonumber(_idx)].redpointState = _boolCompose
end

function RedPointManage:isCanCompose(_itemtype,_idx)
	local _composeData = self.itemComposeData[tonumber(_itemtype)][tonumber(_idx)] or {}
	--先判断银两或者翡翠足够吗？
	if _composeData.needfc and tonumber(_composeData.needfc)>0 then
		if tonumber(gameUser.getFeicui()) < tonumber(_composeData.needfc) then
			return false
		end
	elseif _composeData.needgold and tonumber(_composeData.needgold)>0 then
		if tonumber(gameUser.getGold()) < tonumber(_composeData.needgold) then
			return false
		end
	end
	--再判断需求等级达到了吗？
	if not _composeData.needlv or tonumber(_composeData.needlv)>tonumber(gameUser.getLevel()) then
		return false
	end
	--再判断资源够吗？
	for i=1,4 do
        local _needItemid = _composeData["need" .. i] or nil
        if _needItemid~=nil then
            --原料是否存在
            local _itemidData_ = self.dynamicCostItemData[tostring(_needItemid)] or {}
            if next(_itemidData_)~=nil then
                local _needItemCount = tonumber(_composeData["num" .. i]) or 1
                local _itemidCount = tonumber(_itemidData_["count"]) or 0
                --原料存在，适量是否充足
                if _itemidCount<_needItemCount then
                    return false
                end
            else
                return false
            end
        else
            break
        end
    end
	return true
end

function RedPointManage:getTabComposeRedPoint(_itemtype)
	self:setTabComposeRedPoint(_itemtype)
	return self.composeRedPoint[tonumber(_itemtype)].redpointState or false
end

function RedPointManage:getItemComposeRedPoint(_itemtype,_idx)
	self:setItemComposeRedPoint(_itemtype,_idx)
	return self.composeRedPoint[tonumber(_itemtype)][tonumber(_idx)].redpointState
end

---------------------------合成Ended---------------------------------

---------------------------英雄Began---------------------------------
function RedPointManage:getHeroRedPointState()
	local _ishaveRedpointOrnot = false
	_ishaveRedpointOrnot = self:getHeroFoundationRedPoint()
	return _ishaveRedpointOrnot
end
-- [==[


--英雄功能红点
function RedPointManage:setHeroFoundationRedPoint()
	self.heroredpointState = false
	self.heroOperatePermission = {}
	-- self.staticOtherHeroData = {}
	--获取英雄，分成两批未招募和已招募
	--已拥有英雄有红点状态和英雄列表，英雄列表中有每个英雄的红点状态和各种操作的状态
	--未拥有英雄也有红点状态和英雄列表，英雄列表中有每个英雄的红点状态，也就是是否能够招募
	self.norecruitRedPoint = {}
	self:resetNoRecruitHeroRedPoint()
	self.recruitedRedPoint = {}
	self:resetRecruitHeroPoint()
	
	--设置未招募的情况
	-- self:setNoRecruitHeroRedPoint()
	self.heroredpointState = self:getNoRecruitHeroRedPoint()
	if self.heroredpointState == true then
		return
	end
	-- self:setRecruitedHeroRedPoint()
	self.heroredpointState = self:getRecruitedHeroRedPoint()
	if self.heroredpointState == true then
		return
	end
end

--获取英雄功能红点
function RedPointManage:getHeroFoundationRedPoint()
	self:setHeroFoundationRedPoint()
	return self.heroredpointState
end

--------------已拥有Set-----Began-----------
function RedPointManage:setRecruitedHeroRedPoint()
	self.recruitedRedPoint.redpointState = false
	self:setHeroOperatePermission()
	for k,v in pairs(self.recruitedRedPoint.herolistRedpoint) do
		local _heroid = tonumber(k)
		-- self:setTheHeroRedPointState(_heroid)
		self.recruitedRedPoint.redpointState = self:getTheHeroRedPointState(_heroid)
		if self.recruitedRedPoint.redpointState~=nil and self.recruitedRedPoint.redpointState==true then
			break
		end
	end
end
function RedPointManage:resetRecruitHeroPoint()
	self.heroOperatePermission = {}
	self.recruitedRedPoint = {}
	self.recruitedRedPoint.redpointState = nil
	self.recruitedRedPoint.herolistRedpoint = {}
	for k,v in pairs(self.heroData) do
		self.recruitedRedPoint.herolistRedpoint[tostring(k)] = {}
		self.recruitedRedPoint.herolistRedpoint[tostring(k)].redpointState = nil
		for key,value in pairs(self._heroOperateKey) do
			self.recruitedRedPoint.herolistRedpoint[tostring(k)][tostring(key)] = nil
		end
	end
end
--[[
英雄进阶等的初步限制，比如没有道具，那就肯定无法穿装备，无法进阶，无法升星
这个函数在获取英雄最外面的红点时，运行一次。每次走setTheHeroAllOperateRedPointState函数的时候都要走一次
]]
function RedPointManage:setHeroOperatePermission()
	self.heroOperatePermission = {}
	local _instancId = gameUser.getInstancingId()
	local _compareFunc = function(_lockNum,_hasNum)
		if tonumber(_lockNum) > tonumber(_hasNum) then
			return false
		else
			return true
		end
	end
	--升级技能
	-- local _table1 = self.staticFunctionInfoData[tostring(53)] or {}
	-- local _skillUpLimitId = _table1 and _table1.unlockparam or 0
	self.heroOperatePermission.isCanSkillUp = XTHD.getUnlockStatus(53)
	-- _compareFunc(_skillUpLimitId,_instancId)
	local _skillPoint = gameUser.getSkillPointNow()
	if tonumber(_skillPoint)<1 then
		self.heroOperatePermission.isCanSkillUp = false
	end
	--进阶
	-- local _table2 = self.staticFunctionInfoData[tostring(49)] or {}
	-- local _advanceLimitId = _table2 and _table2.unlockparam or 0
	self.heroOperatePermission.isCanAdvance = XTHD.getUnlockStatus(49)
	-- _compareFunc(_advanceLimitId,_instancId)
	--升星
	-- local _table3 = self.staticFunctionInfoData[tostring(52)] or {}
	-- local _starupLimitId = _table3 and _table3.unlockparam or 0
	self.heroOperatePermission.isCanStarUp = XTHD.getUnlockStatus(52)
	-- _compareFunc(_starupLimitId,_instancId)
	--强化
	local _equipmentData = self.EquipmentData or {}
	if next(_equipmentData)~=nil then
		self.heroOperatePermission.isCanStreng = true
	else
		self.heroOperatePermission.isCanStreng = false
	end
	
	--装备
	local _itemData = self.items_data or {}
	if next(_itemData)~=nil then
		self.heroOperatePermission.isCanEquip = true
		self.heroOperatePermission.isCanLevelUp = true
	else
		self.heroOperatePermission.isCanEquip = false
		self.heroOperatePermission.isCanLevelUp = false
		self.heroOperatePermission.isCanAdvance = false
		self.heroOperatePermission.isCanStarUp = false
	end
end
--判断某一英雄是否有红点
function RedPointManage:setTheHeroRedPointState(_heroid)
	if self.heroOperatePermission == nil or next(self.heroOperatePermission)==nil then
		self:setHeroOperatePermission()
	end
	self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].redpointState = false
	for i=1,#self._heroOperateKey do
		local _type = self._heroOperateKey[i]
		if (self.heroOperatePermission[_type]~=nil and self.heroOperatePermission[_type]==true) or self.heroOperatePermission[_type] then
			-- self:setTheHeroOperateStateByType(_heroid,_type)
			local heroBool = nil
			--在判断外面（英雄列表和主城）的红点的时候，英雄等级40级以上升级没红点。在英雄信息才有
			if _type == "isCanLevelUp" and tonumber(gameUser.getLevel())>40 then
				heroBool = false
			else
				heroBool = self:getTheHeroOperateStateByType(_heroid,_type)
			end
			self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].redpointState = heroBool
			if self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].redpointState~=nil and self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].redpointState==true  then
				return
			end
		else
			self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)][_type] = false
		end
	end
end
--设置某一英雄的全部操作，进阶升星等。
function RedPointManage:setTheHeroAllOperateRedPointState(_heroid)
	if self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)]==nil then
		return
	end
	self:setHeroOperatePermission()
	for i=1,#self._heroOperateKey do
		local _type = self._heroOperateKey[i]
		if self.heroOperatePermission[_type]~=nil and self.heroOperatePermission[_type]==true then
			self:setTheHeroOperateStateByType(_heroid,_type)
		else
			self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)][_type] = false
		end
	end
end

function RedPointManage:setTheHeroOperateStateByType(_heroid,_type)
	if _type=="isCanEquip" then
		self:setTheHeroEquipItemsState(_heroid)
	elseif _type=="isCanStreng" then
		self:setTheHeroStrengItemsState(_heroid)
	elseif _type=="isCanLevelUp" then
		self:setTheHeroLevelUpState(_heroid)
	elseif _type=="isCanSkillUp" then
		self:setTheHeroSkillUpState(_heroid)
	elseif _type=="isCanAdvance" then
		self:setTheHeroAdvanceState(_heroid)
	elseif _type=="isCanStarUp" then
		self:setTheHeroStarUpState(_heroid)
	end
end
--是否有装备可装
function RedPointManage:setTheHeroEquipItemsState(_heroid)
	local _equipBool = false
	_equipBool = self:getItemState({_type = self.heroData[tostring(_heroid)].type or 0,heroid =_heroid,_level = self.heroData[tostring(_heroid)].level or 0})
	self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanEquip = _equipBool
end
--判断某英雄是否能装备
function RedPointManage:getItemState(hero_data)
	if not self.item_State then
		return false
	end
	local _heroEquipmentData = self.EquipmentData[tostring(hero_data.heroid)] or {}
	for k,v in pairs(self.item_State) do
		--当前这个位置是否有可穿戴装备
		if v and next(v)~=nil then
			--当前英雄的类型是否有可穿戴装备
			if v[tostring(hero_data._type)] and next(v[tostring(hero_data._type)])~=nil then
				for _key,_var in pairs(v[tostring(hero_data._type)]) do
					if _var.level and hero_data._level and tonumber(_var.level)<=tonumber(hero_data._level) then
						if not _heroEquipmentData or next(_heroEquipmentData)==nil or _heroEquipmentData[tostring(k)]==nil or next(_heroEquipmentData[tostring(k)])==nil then
							return true
						end
						local _equipQuality = tonumber(_heroEquipmentData[tostring(k)].quality or 1)
						local _itemQuality = tonumber(_var.quality or 1)
						if _itemQuality>_equipQuality then
							return true
						elseif _itemQuality==_equipQuality then
							local _equipPower = tonumber(_heroEquipmentData[tostring(k)].power or 1)
							local _itemPower = tonumber(_var.power or 0)
							if _itemPower>_equipPower then
								return true
							end
						end
					end
				end
			end
		end
	end
	return false
end
--是否可一键强化
function RedPointManage:setTheHeroStrengItemsState(_heroid)
	local _strengBool = false
	local _eqiupsData = self.EquipmentData[tostring(_heroid)] or {}
	for k,v in pairs(_eqiupsData) do
		local _curStrengLevel = tonumber(v and v.strengLevel or 0)
		local _strengLevel = tonumber(_curStrengLevel) + 1
		local _quality = v.quality or 1
		if tonumber(_curStrengLevel)<tonumber(gameUser.getLevel()) then
			local _equipupData = self.staticItemEquipUpData[tostring(_strengLevel)] or {}
			local _coin =  tonumber(_equipupData and _equipupData["consume" .. _quality] or 0)
			if _coin <= tonumber(gameUser.getGold()) and _coin>0 then
				local _needItem = _equipupData["need"]
				local _needNum = tonumber(_equipupData["num".._quality])
				if _needItem ==nil or _needNum == nil or tonumber(_needItem)<1 or tonumber(_needNum)<1 then
					_strengBool = true
					break
				else
					local _hasNum = self.dynamicCostItemData[tostring(_needItem)] or {}
					_hasNum = _hasNum.count or 0
					if _needNum<=_hasNum then
						_strengBool = true
						break
					end
				end
			end
		end
	end
	self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanStreng = _strengBool
end
--是否可升级
function RedPointManage:setTheHeroLevelUpState(_heroid)
	-- if tonumber(gameUser.getLevel())>40 then
	-- 	self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanLevelUp = false
	-- 	return
	-- end
	local _levelupBool = false
	local _heroData = self.heroData[tostring(_heroid)] or {}
	local _heroLevel = tonumber(_heroData and _heroData.level or 0)
	local _playerData = self.staticPlayerInfoListData[tostring(gameUser.getLevel())] or {}
	local _topLevel = tonumber(_playerData and _playerData.maxlevel or 0)
	if _heroLevel<_topLevel then
		for i=1,#self.staticLevelUpData do
			local _itemid = self.staticLevelUpData[i].itemid or 0
			local _costData = self.dynamicCostItemData[tostring(_itemid)] or {}
			local _count = tonumber(_costData and _costData.count or 0)
			if _count > 0 then
				_levelupBool = true
				break
			end
		end
	end
	self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanLevelUp = _levelupBool
end
--是否可升级技能
function RedPointManage:setTheHeroSkillUpState(_heroid)
	local _skillupBool = false
	_skillupBool = self:getIsCanSkillUp(_heroid)
	self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanSkillUp = _skillupBool
end
function RedPointManage:getIsCanSkillUp(_heroid)
	if tonumber(gameUser.getSkillPointNow())<5 then
		return false
	end
	local _dynamicHeroSkillData = self.dynamicHeroSkillData[tonumber(_heroid)]
	local _dynamicHeroData = self.heroData[tostring(_heroid)]
	local _heroLevel = _dynamicHeroData.level or 0
	for i=0,3 do
		local _skillKey = "skillid" .. i
		local _skillLevel = _dynamicHeroSkillData[_skillKey .."lv"] or 0
		if tonumber(_skillLevel)>0 then
			_skillLevel = _skillLevel
			local _table = self.staticHeroSkillListData[tostring(_heroid)]
			local _skillId = _table and _table[_skillKey] or 0
			local _staticSkillUpData = self.staticSkillUpListData[tostring(_skillLevel)]
			if _staticSkillUpData~=nil and next(_staticSkillUpData)~=nil then
				--等级够不？
				local _needlevel = _staticSkillUpData["needlevel"] or nil
				if _needlevel~=nil and tonumber(_heroLevel) >=tonumber(_needlevel) then
					--翡翠够不？
					local _needFeicui = _staticSkillUpData["skill" .. i .. "price"] or nil
					if _needFeicui~=nil and tonumber(gameUser.getFeicui())>=tonumber(_needFeicui) then
						return true
					end
				end
				
			end
		end
	end
	return false
end
--是否可进阶
function RedPointManage:setTheHeroAdvanceState(_heroid)
	local _advanceBool = false
	_advanceBool = self:getIsCanAdvance(_heroid)
	self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanAdvance = _advanceBool
end
function RedPointManage:getIsCanAdvance(_heroid)
	local _dynamicHeroData = self.heroData[tostring(_heroid)]
	local _advanceNum = tonumber(_dynamicHeroData["advance"])
	local _heroLevel = _dynamicHeroData.level or 0
	local _table = self.staticHeroAdvancedListData[tostring(_heroid)]
	local _staticAdvanceData = _table and _table[tostring(_advanceNum)] or nil
	if _table[tostring(_advanceNum+1)]==nil or next(_table[tostring(_advanceNum+1)])==nil then
		return false
	end
	if _staticAdvanceData == nil or next(_staticAdvanceData)==nil then
		return false
	end
	--等级够不？
	if _staticAdvanceData["needlevel"]==nil or tonumber(_staticAdvanceData["needlevel"])>tonumber(_heroLevel) then
		return false
	end
	--翡翠够不？
	if _staticAdvanceData["feicuicost"]==nil or tonumber(_staticAdvanceData["feicuicost"])>tonumber(gameUser.getFeicui()) then
		return false
	end
	--道具够不？
	local _costItemTable = self.dynamicCostItemData[tostring(_staticAdvanceData["itemid1"])]
	local _hasCostItemCount = _costItemTable and _costItemTable["count"] or 0
	if _staticAdvanceData["itemid1count"]==nil or tonumber(_staticAdvanceData["itemid1count"]) > tonumber(_hasCostItemCount) then
		return false
	end
	return true
end
--是否可升星
function RedPointManage:setTheHeroStarUpState(_heroid)
	local _starupBool = true
	_starupBool = self:getIsCanStarup(_heroid)
	self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanStarUp = _starupBool
end
function RedPointManage:getIsCanStarup(_heroid)
	local _dynamicHeroData = self.heroData[tostring(_heroid)]
	local _starNum = tonumber(_dynamicHeroData["star"]) + 1
	local _staticStarupData = self.staticHeroStarupListData[tostring(_heroid)]
	if _staticStarupData == nil or next(_staticStarupData)==nil then
		return false
	end
	--翡翠够不？
	local _coiniStr = "goldcost" .. _starNum .. "star"
	if _staticStarupData[_coiniStr]==nil or tonumber(_staticStarupData[_coiniStr])>tonumber(gameUser.getFeicui()) then
		return false
	end
	--魂石够不？
	local _itemStr = "starcount" .. _starNum
	local _costItemTable = self.dynamicCostItemData[tostring(_staticStarupData["propsneed"])]
	local _hasCostItemCount = _costItemTable and _costItemTable["count"] or 0
	if _staticStarupData[_itemStr]==nil or tonumber(_staticStarupData[_itemStr]) > tonumber(_hasCostItemCount) then
		return false
	end
	--是否已到最大星级
	local maxStar = XTHD.getHeroMaxStar(_heroid)
    if tonumber(_dynamicHeroData["star"]) >= maxStar then
		return false
	end
	return true
end
--------------已拥有Set-----Ended-----------


--------------已拥有Get-----Began-----------
--获取已招募英雄的红点
function RedPointManage:getRecruitedHeroRedPoint()
	self:setRecruitedHeroRedPoint()
	return self.recruitedRedPoint.redpointState
end
--获取某拥有英雄的红点情况
function RedPointManage:getTheHeroRedPointState(_heroid)
	if self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)]==nil then
		return false
	end
	self:setTheHeroRedPointState(_heroid)
	return self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].redpointState
end
--获取英雄的全部状态
function RedPointManage:getTheHeroAllOperateRedPointState(_heroid)
	if self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)]== nil then
		return {}
	end
	self:setTheHeroAllOperateRedPointState(_heroid)
	local _stateData = self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)] or {}
	return _stateData
end

function RedPointManage:getTheHeroOperateStateByType(_heroid,_type)
	if self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)]==nil then
		return false
	end
	local _operateBool = false
	if _type=="isCanEquip" then
		_operateBool = self:getTheHeroEquipItemsState(_heroid)
	elseif _type=="isCanStreng" then
		_operateBool = self:getTheHeroStrengItemsState(_heroid)
	elseif _type=="isCanLevelUp" then
		_operateBool = self:getTheHeroLevelUpState(_heroid)
	elseif _type=="isCanSkillUp" then
		_operateBool = self:getTheHeroSkillUpState(_heroid)
	elseif _type=="isCanAdvance" then
		_operateBool = self:getTheHeroAdvanceState(_heroid)
	elseif _type=="isCanStarUp" then
		_operateBool = self:getTheHeroStarUpState(_heroid)
	else
		_operateBool = false
	end
	return _operateBool
end
--是否有装备可装
function RedPointManage:getTheHeroEquipItemsState(_heroid)
	self:setTheHeroEquipItemsState(_heroid)
	return self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanEquip
end
--是否可一键强化
function RedPointManage:getTheHeroStrengItemsState(_heroid)
	self:setTheHeroStrengItemsState(_heroid)
	return self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanStreng
end
--是否可升级
function RedPointManage:getTheHeroLevelUpState(_heroid)
	self:setTheHeroLevelUpState(_heroid)
	return self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanLevelUp
end
--是否可升级技能
function RedPointManage:getTheHeroSkillUpState(_heroid)
	self:setTheHeroSkillUpState(_heroid)
	return self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanSkillUp
end
--是否可进阶
function RedPointManage:getTheHeroAdvanceState(_heroid)
	self:setTheHeroAdvanceState(_heroid)

	return self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanAdvance
end
--是否可升星
function RedPointManage:getTheHeroStarUpState(_heroid)
	self:setTheHeroStarUpState(_heroid)
	
	return self.recruitedRedPoint.herolistRedpoint[tostring(_heroid)].isCanStarUp
end

--宠物是否可以进行操作
function RedPointManage:getTheHeroPetState( _heroid )
	-- body
end
--------------已拥有Get-----Ended-----------


--------------未招募Set-----Began-----------
--设置未招募英雄的情况
function RedPointManage:setNoRecruitHeroRedPoint()
	--判断每个未招募英雄的情况
	self.norecruitRedPoint.redpointState = false
	for k,v in pairs(self.norecruitRedPoint.herolistRedpoint) do
		local _heroid = tonumber(k)
		-- self:setTheHeroRecruitState(_heroid)
		self.norecruitRedPoint.redpointState = self:getTheHeroRecruitState(_heroid)
		if self.norecruitRedPoint.redpointState~=nil and self.norecruitRedPoint.redpointState==true then
			break
		end
	end
end
function RedPointManage:resetNoRecruitHeroRedPoint()
	self.norecruitRedPoint = {}
	self.norecruitRedPoint.redpointState = nil
	self.norecruitRedPoint.herolistRedpoint = {}
	for k,v in pairs(self.staticOtherHeroData) do
		self.norecruitRedPoint.herolistRedpoint[tostring(k)] = {}
		self.norecruitRedPoint.herolistRedpoint[tostring(k)].redpointState = nil
		for key,value in pairs(self._heroOperateKey) do
			self.norecruitRedPoint.herolistRedpoint[tostring(k)][tostring(key)] = nil
		end
	end
end
--设置某一个英雄是否可以招募
function RedPointManage:setTheHeroRecruitState(_heroid)
	self.norecruitRedPoint.herolistRedpoint[tostring(_heroid)].redpointSate = false
	--判断能否招募，碎片是否充足
	local _herodata = self.staticOtherHeroData[tostring(_heroid)] or {}
	local _starNum = _herodata and _herodata.star or 1
	local _allChipNum = tonumber(self.starupchipData[tonumber(_heroid)]["allstarcount" .. _starNum] or 0)
	local _costCoin = tonumber(self.starupchipData[tonumber(_heroid)]["allgoldcost" .. _starNum .. "star"] or 0)
	local _itemid = tonumber(_heroid) + 1000
	local _table = self.dynamicCostItemData[tostring(_itemid)] or {}
	local _m_chipNum = tonumber(_table and _table.count or 0)

	if _allChipNum>0 and _allChipNum<=_m_chipNum and _costCoin>0 and _costCoin<=tonumber(gameUser.getFeicui()) then
		self.norecruitRedPoint.herolistRedpoint[tostring(_heroid)].redpointSate = true
	end
end
--------------未招募Set-----Ended-----------


--------------未招募Get-----Began-----------
--获取未招募英雄的情况
function RedPointManage:getNoRecruitHeroRedPoint()
	--如果redpointState是nil，表示没有对为招募英雄是否有红点的情况进行判断，重新进行判断，如果不是nil，表示已经判断过了，直接返回。
	self:setNoRecruitHeroRedPoint()
	return self.norecruitRedPoint.redpointState
end
--获取指定未招募英雄的情况
function RedPointManage:getTheHeroRecruitState(_heroid)
	if self.norecruitRedPoint.herolistRedpoint[tostring(_heroid)]~=nil then
		self:setTheHeroRecruitState(_heroid)
	end
	return self.norecruitRedPoint.herolistRedpoint[tostring(_heroid)] and self.norecruitRedPoint.herolistRedpoint[tostring(_heroid)].redpointSate or false
end
--------------未招募Get-----Ended-----------

---------------------------英雄Ended---------------------------------


---------------------------装备Began---------------------------------
function RedPointManage:getEquipRedPointState()
	-- 获取所有已穿戴的装备
	local equipData = DBTableEquipment.getData( gameUser.getUserId() )
	if table.nums( equipData ) > 0 and not equipData[1] then
		equipData = { equipData }
	end
	-- 判断红点条件
	local redDotFlag = false
	local myMoney = gameUser.getGold()
	local unlockStarup = XTHD.getUnlockStatus( 50, false )
	for i, v in ipairs( equipData ) do
		local rankData = gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = v.itemid} ).rank
		-- 强化
		if not redDotFlag then
			if v.strengLevel < gameUser.getLevel() then
				local strengthData = gameData.getDataFromCSV( "EquipUpList", {itemlevel = v.strengLevel + 1} )
				-- 钱
				if myMoney >= strengthData["consume"..rankData] then
					-- 材料
					if strengthData.need then
						if strengthData.num and XTHD.resource.getItemNum( strengthData.need ) >= strengthData.num then
							redDotFlag = true
							break
							-- print("strength  ",v.itemid)
						end
					else
						redDotFlag = true
						break
					end
				end
			end
		end
		-- 升星
		if unlockStarup and not redDotFlag and v.quality > 2 then
			local maxStars = gameData.getDataFromCSV( "EquipInfoList", {itemid = v.itemid}).advancetopvalue
			if maxStars > v.phaseLevel then
				-- 没进阶到满星
				local starupData = gameData.getDataFromCSV( "EquipAscendingStar", {stage = v.phaseLevel + 1} )
				-- 钱
				if myMoney >= starupData.goldprice*XTHD.resource.advanceGoldCoefficient[rankData] then
					-- 材料
					if starupData["num"..rankData] then
						local numTable = string.split( starupData["num"..rankData], "#" )
						local csmTable = string.split( starupData["consumables"..rankData], "#" )
						local i = 1
						local itemFlag = true
						while numTable[i] do
							if XTHD.resource.getItemNum( csmTable[i] ) < tonumber( numTable[i] ) then
								itemFlag = false
								break
							end
							i = i + 1
						end
						if itemFlag then
							redDotFlag = true
							break
						end
					end
				end
			end
		end
	end

	return redDotFlag
end
-- 判断装备合成红点
function RedPointManage:getEquipComposeRedPointState()
	local composeData = gameData.getDataFromCSV("SmithyMakingList",{itemtype = 0})
	local myLevel = gameUser.getLevel()
	local myGold = gameUser.getGold()
	local myFeicui = gameUser.getFeicui()
	for i, v in ipairs( composeData ) do
		if tonumber( v.needlv or 0 ) <= myLevel then
			-- 等级满足
			if tonumber( v.needgold or 0 ) <= myGold and tonumber( v.needfc or 0 ) <= myFeicui then
				-- 银两翡翠满足
				local i = 1
				local itemFlag = true
				while v["num"..i] do
					if XTHD.resource.getItemNum( v["need"..i] ) < tonumber( v["num"..i] ) then
						itemFlag = false
						break
					end
					i = i + 1
				end
				if itemFlag then
					return true
				end
			end
		end
	end
	return false
end
---------------------------装备Ended---------------------------------


-------------------动态数据Began--------------------
function RedPointManage:setDynamicData()
	self:getDynamicHeroData()
	self:getDynamicItemData()
	self:getDynamicEquipmentData()
	self:getDynamicDBHeroSkillData()
end
function RedPointManage:getDynamicHeroData()
	-- DBTableHero.getData(gameUser.getUserId());
	local DBUserHeroInfo = {}
	DBUserHeroInfo = DBTableHero.getDataByID() or {}
	if DBUserHeroInfo == nil or next(DBUserHeroInfo) == nil then
		self.heroData = {}
		self:getStaticOtherHeroData()
		return
	end

	-- 获取静态数据库
	local _staticHeroTable = self.staticHeroListData or {}
	if _staticHeroTable == nil or next(_staticHeroTable) == nil then
		self.heroData = {}
		self:getStaticOtherHeroData()
		return
	end
	self.heroData = {}
	for k,v in pairs(DBUserHeroInfo) do
		v.type = _staticHeroTable[tostring(v.heroid)]["type"]
		self.heroData[tostring(v.heroid)] = v
		-- clone(v)
	end
	self:getStaticOtherHeroData()
end
--获取未招募英雄
function RedPointManage:getStaticOtherHeroData()
	self.staticOtherHeroData = {}
	for k,v in pairs(self.staticHeroListData) do
		if (self.heroData[tostring(k)]==nil or next(self.heroData[tostring(k)])==nil) and tonumber(v["unlock"])~=0 then
			self.staticOtherHeroData[tostring(k)] = v
			-- clone(v)
		end
	end
end
--获取动态Item数据
function RedPointManage:getDynamicItemData()
	local items_pairs = {}
	--这里浅拷贝，可能篡改数据
	items_pairs = DBTableItem.getDataByID()
	local _EquipmentTable = gameData.getDataFromCSVWithPrimaryKey("EquipInfoList")
	self.items_data = {}
	self.dynamicCostItemData = {}
	for i,var in pairs(items_pairs) do
		self.items_data[tostring(var["dbid"])] = {}
		self.items_data[tostring(var["dbid"])] = var
		local _data_ = _EquipmentTable[tostring(var["itemid"])] or {}
		local _equipmentData = {
								herotype = _data_.herotype or 1
								,equippos = _data_.equippos or 0
							}
		self.items_data[tostring(var["dbid"])].equipment = _equipmentData
		self.dynamicCostItemData[tostring(var.itemid)] = {}
		self.dynamicCostItemData[tostring(var.itemid)] = var
	end
	self:setItemState()
end
--获取动态Equip数据
function RedPointManage:getDynamicEquipmentData()
	self.EquipmentData = {}
	local _table = DBTableEquipment.getDataByID()
	for k,v in pairs(_table) do
		if not self.EquipmentData[tostring(v.heroid)] or next(self.EquipmentData[tostring(v.heroid)])==nil then
			self.EquipmentData[tostring(v.heroid)] = {}
		end
		self.EquipmentData[tostring(v.heroid)][tostring(v.bagindex)] = v
	end
end
--获取动态heroSkillUp
function RedPointManage:getDynamicDBHeroSkillData()
	self.dynamicHeroSkillData = {}
	self.dynamicHeroSkillData = DBTableHeroSkill.getDataByID()
end

function RedPointManage:setItemState()
	--[[
	self.items_State = {
			--位置
			["1"] = {
					--英雄类型
					["1"] = 符合条件的装备的信息,
					["2"] = ,
					["3"] = 
				}
			["2"] = {
					["1"] = ,
					["2"] = ,
					["3"] = 
				}
		}
	]]
	--设置6个位置上，每个位置上三种类型，每一种类型所代表的道具中的最强品质和此品质中的最强战力
	self.item_State = {}
	if self.items_data~=nil and next(self.items_data)~=nil then
		--遍历item表中数据
		for k,var in pairs(self.items_data) do
			--分成6个位置，判断这个装备的位置
			for i=1,6 do
				if not self.item_State[tostring(i)] then
					self.item_State[tostring(i)] = {}
				end
				--判断这条数据的位置
				if var.equipment and  tonumber(var.equipment.equippos)==tonumber(i) then
					local _heroType = string.split(var.equipment.herotype,'#')
					--这个装备的穿戴英雄类型
					for _k,v in pairs(_heroType) do
						if self.item_State[tostring(i)][tostring(v)]==nil or next(self.item_State[tostring(i)][tostring(v)])==nil then
							self.item_State[tostring(i)][tostring(v)] = {}
						end
						self.item_State[tostring(i)][tostring(v)][#self.item_State[tostring(i)][tostring(v)] + 1] = var
					end
				end
			end
		end
	end
end

function RedPointManage:reFreshDynamicHeroData()
	self:getDynamicHeroData()
	self:getDynamicDBHeroSkillData()
	XTHD.dispatchEvent({["name"] =CUSTOM_EVENT.REFRESH_FUNCTION_REDPOINT})
end
function RedPointManage:reFreshDynamicHeroSkillData()
	self:getDynamicDBHeroSkillData()
	XTHD.dispatchEvent({["name"] =CUSTOM_EVENT.REFRESH_FUNCTION_REDPOINT})
end
function RedPointManage:reFreshDynamicItemData()
	self:getDynamicItemData()
	XTHD.dispatchEvent({["name"] =CUSTOM_EVENT.REFRESH_FUNCTION_REDPOINT})
end
function RedPointManage:reFreshDynamicEquipmentData()
	self:getDynamicEquipmentData()
	XTHD.dispatchEvent({["name"] =CUSTOM_EVENT.REFRESH_FUNCTION_REDPOINT})
end
function RedPointManage:reFreshDynamicItemAndEquipmentData()
	self:getDynamicItemData()
	self:getDynamicEquipmentData()
	XTHD.dispatchEvent({["name"] =CUSTOM_EVENT.REFRESH_FUNCTION_REDPOINT})
end


-------------------动态数据Ended--------------------


-------------------静态数据Began--------------------
function RedPointManage:setStaticData()
	self.staticFunctionInfoData = gameData.getDataFromCSVWithPrimaryKey("FunctionInfoList")
	self.staticHeroListData = gameData.getDataFromCSVWithPrimaryKey("GeneralInfoList")
	self.staticItemEquipUpData = gameData.getDataFromCSVWithPrimaryKey("EquipUpList")
	self.staticPlayerInfoListData = gameData.getDataFromCSVWithPrimaryKey("PlayerUpperLimit")
	self.staticHeroStarupListData = gameData.getDataFromCSVWithPrimaryKey("GeneralGrowthNeeds")
	self.staticHeroSkillListData = gameData.getDataFromCSVWithPrimaryKey("GeneralSkillList")
	self.staticSkillUpListData = gameData.getDataFromCSVWithPrimaryKey("JinengUpNeed")
	self:setStaticDBHeroStarUpListData()
	self:setStaticDBLevelUpData()
	self:setStaticDBHeroAdvancedListData()
	self:setStaticDBItemComposeData()
end

function RedPointManage:setStaticDBLevelUpData()
	local _itemTable = gameData.getDataFromCSV("ArticleInfoSheet",{effecttype = 5})
	self.staticLevelUpData = {}
	for k,v in pairs(_itemTable) do
		if v.effecttype == 5 then
			self.staticLevelUpData[#self.staticLevelUpData + 1] = v
		end
	end
	table.sort(self.staticLevelUpData,function(data1,data2)
			return tonumber(data1.itemid)<tonumber(data2.itemid)
		end)
end
--英雄进阶静态
function RedPointManage:setStaticDBHeroAdvancedListData()
	self.staticHeroAdvancedListData = {}
	local _table = gameData.getDataFromCSV("GeneralAdvanceInfo")
	for k,v in pairs(_table) do
		if self.staticHeroAdvancedListData[tostring(v.heroid)]==nil then
			self.staticHeroAdvancedListData[tostring(v.heroid)] = {}
		end
		self.staticHeroAdvancedListData[tostring(v.heroid)][tostring(v.rank)] = v
	end
end
function RedPointManage:setStaticDBHeroStarUpListData()
	--都一样的
	self.starupchipData = gameData.getDataFromCSV("GeneralGrowthNeeds") or {}
	for i=1,#self.starupchipData do
		for j=1,5 do
			self.starupchipData[i]["allstarcount" .. j] = self.starupchipData[i]["allstarcount" .. (j-1)] or 0
			local _chipNumber = self.starupchipData[i]["starcount" .. j] or 0
			_chipNumber = _chipNumber + self.starupchipData[i]["allstarcount" .. j]
			self.starupchipData[i]["allstarcount" .. j] = _chipNumber

			self.starupchipData[i]["allgoldcost" .. j .. "star"] = self.starupchipData[i]["allgoldcost" .. (j-1) .. "star"] or 0
			local _costCoin = self.starupchipData[i]["goldcost" .. j .. "star"] or 0
			_costCoin = _costCoin + self.starupchipData[i]["allgoldcost" .. j .. "star"]
			self.starupchipData[i]["allgoldcost" .. j .. "star"] = _costCoin
		end
	end
end
-------合成静态
function RedPointManage:setStaticDBItemComposeData()
	self.itemComposeData = {}
	local _table = gameData.getDataFromCSV("SmithyMakingList")
	for i=1,#_table do
		if tonumber(_table[i].itemtype) ~= 0 then
			if self.itemComposeData[tonumber(_table[i].itemtype)]==nil then
				self.itemComposeData[tonumber(_table[i].itemtype)] = {}
			end
			self.itemComposeData[tonumber(_table[i].itemtype)][#self.itemComposeData[tonumber(_table[i].itemtype)] + 1] = _table[i]
			-- self.itemComposeData[tonumber(_table[i].itemtype)-1][#self.itemComposeData[tonumber(_table[i].itemtype)] + 1] = _table[i]
		end
		
	end
	for i=1,#self.itemComposeData do
		table.sort(self.itemComposeData[tonumber(i)],function(data1,data2)
				local _data1Num = tonumber(data1.needfc) + tonumber(data1.needgold)
				local _data2Num = tonumber(data2.needfc) + tonumber(data2.needgold)
				return _data1Num<_data2Num
			end)
	end
end


-------------------静态数据Ended--------------------

-- ]==]

function RedPointManage:addListener()
	XTHD.addEventListener({name = CUSTOM_EVENT.HERO_REDPOINTMGR,callback = function()
		self:startSetRedpoint()
	end})
end

function RedPointManage:create()
	RedPointManage:addListener()
	RedPointManage:startSetRedpoint()
end

--------
function RedPointManage:setHeroNumber(_num)
	self._heroNum = _num
	-- self._heroNum = 1
end
function RedPointManage:getHeroNumber()
	return self._heroNum or 0
end
--------