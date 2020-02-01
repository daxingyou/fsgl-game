--[[
 	对英雄做统一管理
]]


HeroMgr = {};

--[[
整个数据结构为
player = {
	[1] = {["node"] = xx, ["ready"] = xx},
	[2] = {["node"] = xx, ["ready"] = xx},
	[3] = {["node"] = xx, ["ready"] = xx}
};
]]

-- 将所有敌人清空
function HeroMgr:removeEnemyAndCleanup()
	if self.m_mapEnemyList == nil then
		return;
	end
	for index = 1, #self.m_mapEnemyList do
		self.m_mapEnemyList[index]["node"]:removeAllBuff(true) --清除所有的buff，有些buff表现并不是挂在人物上面的，所以不会一并移除
		self.m_mapEnemyList[index]["node"]:removeFromParent(true)
	end
	self.m_mapEnemyList = nil;
end

-- 删除所有玩家英雄
function HeroMgr:removePlayerAndCleanup()
	if self.m_mapPlayerList == nil then
		return;
	end
	for i = 1, #self.m_mapPlayerList do
		self.m_mapPlayerList[i]["node"]:removeAllBuff(true)
		self.m_mapPlayerList[i]["node"]:removeFromParent(true);
	end
	self.m_mapPlayerList = nil;
end

-- 删除指定的node
function HeroMgr:removeTheEnemy( seatId )
	local _enemyNodeList = self:getEnemyNodeList();
	if _enemyNodeList == nil or next(_enemyNodeList) == nil then
		return;
	end
	for i = 1, #_enemyNodeList do
	end
end

function HeroMgr:getPlayers()
	return self.m_mapPlayerList or {};
end

function HeroMgr:getEnemys()
	return self.m_mapEnemyList or {};
end

function HeroMgr:getPlayerNodeList()
	local _list = {};
	if self.m_mapPlayerList == nil then
		self.m_mapPlayerList = {};
	end
	for i = 1, #self.m_mapPlayerList do
		_list[#_list+1] = self.m_mapPlayerList[i]["node"];
	end
	return _list;
end

-- 获取敌人的列表
function HeroMgr:getEnemyNodeList()
	local _list = {};
	if self.m_mapEnemyList == nil then
		self.m_mapEnemyList = {};
	end
	for i = 1, #self.m_mapEnemyList do
		_list[#_list+1] = self.m_mapEnemyList[i]["node"];
	end
	return _list;
end

-- -- 将玩家信息添加到列表
function HeroMgr:onAddPlayerToVec( data )
	if self.m_mapPlayerList == nil then
		self.m_mapPlayerList = {};
	end
	self.m_mapPlayerList[#self.m_mapPlayerList+1] = {["node"] = data, ["ready"] = false};
end

function HeroMgr:onAddEnemyToVec( data )
	if self.m_mapEnemyList == nil then
		self.m_mapEnemyList = {};
	end
	self.m_mapEnemyList[#self.m_mapEnemyList+1] = {["node"] = data, ["ready"] = false};
end

function HeroMgr:setPlayerbReady( heroid, _bready )
	for i = 1, #self.m_mapPlayerList do
		if self.m_mapPlayerList[i]["node"]:getHeroData():getID() == heroid then
			self.m_mapPlayerList[i]["ready"] = _bready;
			break;
		end
	end
end

-- -- 根据英雄的类型获取位置
-- function HeroMgr:getHeroLocation( herotype )
-- 	local x = 0.0;
-- 	local y = 0.0;
-- 	if herotype == HeroType.kHeroType_Player then
-- 		if self.m_mapPlayerPos == nil then
-- 			self.m_mapPlayerPos = {};
-- 			-- 玩家站位配置
-- 			for index = 1, 5 do
-- 				x = winWidth*0.05-(winWidth*0.07*index);
-- 				y = index%2 ~= 0 and winHeight*0.52 or winHeight*0.42;
-- 				self.m_mapPlayerPos[#self.m_mapPlayerPos+1] = cc.p(x, y);
-- 			end
-- 		end
-- 		return self.m_mapPlayerPos;
-- 	else
-- 		if self.m_mapEnemyPos == nil then
-- 			self.m_mapEnemyPos = {};
-- 			for index = 1, 5 do
-- 				x = winWidth*0.85+(winWidth*0.15*index);
-- 				y = index%2 ~= 0 and winHeight*0.52 or winHeight*0.42;
-- 				self.m_mapEnemyPos[#self.m_mapEnemyPos+1] = cc.p(x, y);
-- 			end
-- 		end
-- 		return self.m_mapEnemyPos;
-- 	end
-- end

-- 整体思路如下
--[[
	让英雄在行走的过程中检测，
]]
function HeroMgr:setPlayerSortPosY( sortList, detector )
	-- 获取队友列表
	local _teamList = detector:getPlayerNodeList();
	-- 小于等于两个人的时候不排序，可以展开
	if sortList == nil or #sortList <= 2  then
		return;
	end
	-- 遍历需要排序的单元列表，让分别让他们保存目前的sortList以用来检测是否需要调动Update去排序，定义算出来的YIndex
	for sortListIndex = 1, #sortList do
		local _hero = nil;
		for teamListIndex = 1, #_teamList do
			if _teamList[teamListIndex]:getSeatID() == sortList[sortListIndex] then
				-- 保存sortList用来做检测
				_teamList[teamListIndex]:setSortList(sortList);
				_hero = _teamList[teamListIndex];
				break;
			end
		end
		if _hero then
			local _newYIndex = 4;
			 if _hero:getSeatID() == detector:getSeatID() then
				_newYIndex = self:_getNewYIndex( _hero:getYIndex(), #sortList, true );
				-- print(">>>true 排列之前的YIndex: " .. tostring(_hero:getYIndex()) .. " 计算好的YIndex为: " .. tostring(_newYIndex) );
			else
				_newYIndex = self:_getNewYIndex( _hero:getYIndex(), #sortList, false );
				-- print(">>>false 排列之前的YIndex: " .. tostring(_hero:getYIndex()) .. " 计算好的YIndex为: " .. tostring(_newYIndex) );
			end
			_hero:setYIndex( _newYIndex );
		end
	end
end

function HeroMgr:getSpineResNo( id )
	local resNo = "";
	if string.len(id) == 1 then
		resNo = "00" .. id;
	elseif string.len(id) == 2 then
		resNo = "0" .. id;
	elseif string.len(id) == 3 then
		resNo = id;
	end
	return resNo;
end

--[[
站位图
------------------------------------	
							5					9
------------------------------------	
					4							8
------------------------------------	
			3				5					7
------------------------------------	
	2				4							6
------------------------------------	
			3				5					5
------------------------------------	
	2				4							4
------------------------------------	
			3				5					3
------------------------------------	
					4							2
------------------------------------	
							5					1
------------------------------------
]]	
--[[
	@oldIndex 原始的Yindex
	@count 当前共有多少个人需要排列
	@bNewPlayer 是否为最新的人物加入需要重新给出一个指定的YIndex
]]
function HeroMgr:_getNewYIndex( oldIndex, count, bNewPlayer )
	print(">>>> oldIndex: " .. oldIndex .. "   count: " .. count);
	if not bNewPlayer then
		if oldIndex <= 4 then
			return oldIndex - 1;
		else
			return oldIndex + 1;
		end
	else
		if count == 3 then
			return 5;
		elseif count == 4 then
			return 4;
		elseif count == 5 then
			return 5;
		end
	end
end


--[[
	关于不同层级的站位
]]
function HeroMgr:getPosY( idx )
	-- return 155+25*idx;  --原始高度
	return 130+25*idx;
end
--[[
	关于spine站位  1:玩家  2:敌人
]]
function HeroMgr:getLocation( herotype )
	local x = 0.0;
	local y = 0.0;
	if herotype == HeroType.kHeroType_Player then
		if self.m_mapPlayerPos == nil then
			self.m_mapPlayerPos = {};
			-- 玩家站位配置
			for index = 1, 5 do
				local _waveIndex = GameControl:getWaveIndex() or 1;
				-- x = winWidth*(-0.15)-(winWidth*0.07*index) + winWidth*(_waveIndex-1);
				x = winWidth*(-0.15)-(winWidth*0.07*index);
				y = index%2 ~= 0 and self:getPosY(6) or self:getPosY(4);
				self.m_mapPlayerPos[#self.m_mapPlayerPos+1] = cc.p(x, y);
			end
		end
		return self.m_mapPlayerPos;
	else
		if self.m_mapEnemyPos == nil or tostring(self.m_nBattleType) ~= tostring(self.m_lastBattleType) then
			self.m_lastBattleType = self.m_nBattleType;
			self.m_mapEnemyPos = {};
			for index = 1, 5 do
				local _waveIndex = GameControl:getWaveIndex() or 1;
				if self.m_nBattleType == BattleType.PVP_CHALLENGE then
					_waveIndex = 1;
				end
				x = winWidth*1.15+(winWidth*0.07*index)+winWidth*(_waveIndex-1);
				-- x = winWidth*0.5+(winWidth*0.07*index)+winWidth*(_waveIndex-1);
				y = index%2 ~= 0 and self:getPosY(6) or self:getPosY(4);
				self.m_mapEnemyPos[#self.m_mapEnemyPos+1] = cc.p(x, y);
			end
		end
		return self.m_mapEnemyPos;
	end
end


function HeroMgr:createPlayer( heroData, callback_hp, callback_mp, parent )


	-- local heroInfo = UserHeroInfoMgr:getTheDataFromDataBase(heroID)
	local theHeroConfig = heroData;

	-- 创建英雄，此时我们需要让英雄保存自己的属性
	local pHeroBaseTab = requires("src/ai/Player" .. self:getSpineResNo(theHeroConfig["heroid"]) .. ".lua");

	local pHero = pHeroBaseTab:create( HeroType.kHeroType_Player, theHeroConfig, callback_hp, callback_mp, parent );
	
	if pHero then
		
		local seatIndex = #HeroMgr:getPlayerNodeList()+1;
		
		-- 首先让所有的英雄都处于暂停状态
		-- pHero:setPause( true );
		pHero:pauseAnimation()
		local tabPos = self:getLocation(HeroType.kHeroType_Player);
		if tabPos[seatIndex] then
			-- 用来设置几号位使用的
			pHero:setSeatID( seatIndex );
			pHero:setPosition(tabPos[seatIndex]);
			-- 用来设置排列Y轴高度使用的
			if seatIndex % 2 ~= 0 then  -- 从1开始
				-- pHero:setPositionY( GameControl:getPosY(6) );
				pHero:setYIndex( 6 );
				pHero:setYOldIndex( 6 );
			else
				-- pHero:setPositionY( GameControl:getPosY(4) );
				pHero:setYIndex( 4 );
				pHero:setYOldIndex( 4 );
			end
		end
	end
	return pHero;
end

function HeroMgr:createEnemy( data, parent, callfunc_hp, nBattleType )

	self.m_nBattleType = nBattleType;
	
	local pHeroBaseTab = requires("src/ai/Player" ..self:getSpineResNo(data["heroid"]) .. ".lua");
	local pHero = pHeroBaseTab:create( HeroType.kHeroType_Enemy, data, callfunc_hp, callback_mp, parent );
	
	if pHero then
		local fScaleX, fScaleY = data["scale"], data["scale"];
		-- 敌人从5-10 11-15 16-xx等这种情况去记
		local _waveIndex = 0;--GameControl:getWaveIndex()
		if nBattleType == BattleType.PVE then
			_waveIndex = GameControl:getWaveIndex();
			-- if GameControl:checkExistPlot() then
			-- 	_waveIndex = _waveIndex -1
			-- end
		else
			_waveIndex = PVPGameControl:getWaveIndex();
		end

		local heroIndex = #HeroMgr:getEnemyNodeList()+1 + _waveIndex*5;
		fScaleX = fScaleX*(-1.0);
		pHero:setScaleX(fScaleX);
		pHero:setScaleY(fScaleY);
		-- 首先让所有的英雄都处于暂停状态
		-- pHero:setPause( true );

		local tabPos = self:getLocation(HeroType.kHeroType_Enemy);
		local nTmpHeroIndex = heroIndex%5;
		if heroIndex%5 == 0 then
			nTmpHeroIndex = 5;
		end

		if tabPos[nTmpHeroIndex] then
			pHero:setSeatID( heroIndex );
			pHero:setPosition(tabPos[nTmpHeroIndex]);
		end
		-- 用来设置排列Y轴高度使用的
		if nTmpHeroIndex % 2 ~= 0 then  -- 从1开始
			-- pHero:setPositionY( GameControl:getPosY(6) );
			pHero:setYIndex( 6 );
			pHero:setYOldIndex( 6 );
		else
			-- pHero:setPositionY( GameControl:getPosY(4) );
			pHero:setYIndex( 4 );
			pHero:setYOldIndex( 4 );
		end
	end

	return pHero;
end
