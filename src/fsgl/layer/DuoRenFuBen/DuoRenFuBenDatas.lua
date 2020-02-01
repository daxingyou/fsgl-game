--[[
------多人副本数据
]]
DuoRenFuBenDatas = class("DuoRenFuBenDatas")

DuoRenFuBenDatas.copyListData = nil ------副本列表数据 
DuoRenFuBenDatas.serverDay = 0 -----当前服务器是星期几
DuoRenFuBenDatas.teamListData = nil ------某个开启的副本里的队伍数据 
DuoRenFuBenDatas.tili = 0 ----当前的鲜花数
DuoRenFuBenDatas.afterInvitedCall = nil -----玩家在接受邀请之后的回调

function DuoRenFuBenDatas:reset()
	DuoRenFuBenDatas.copyListData = nil 
	DuoRenFuBenDatas.serverDay = 0 
	DuoRenFuBenDatas.teamListData = nil
	DuoRenFuBenDatas.tili = 0
	DuoRenFuBenDatas.afterInvitedCall = nil -----玩家在接受邀请之后的回调
end 

function DuoRenFuBenDatas:getServerDay( )
	if self.serverDay ~= 0 then 
		return self.serverDay
	else 
		if self.copyListData then 
			local time = tostring(self.copyListData.time)
			self.serverDay = os.date("%w",string.sub(time,1,#time - 3))
		end 
		return self.serverDay	
	end 		
end
--------加入某个队伍 
function DuoRenFuBenDatas:joinATeam(data,invitedCall)
	local isOpen,_data = isTheFunctionAvailable(80) -------多人副本
    if not isOpen then ------没开启
        XTHDTOAST(_data.tip)
        return 
    end 

	local localData = gameData.getDataFromCSV("TeamCopyList",{id = data.configID})
	local curLevel = gameUser.getLevel()
	local playerMaxAdvance = DBTableHero.maxAdvance

	if curLevel >= localData.needlv and playerMaxAdvance >= localData.limitRank then -----
		local object = SocketSend:getInstance()
		if object then 
			object:writeInt(data.teamID)
			object:send(MsgCenter.MsgType.CLIENT_REQUEST_JOINMULTITEAM)
		end 
		DuoRenFuBenDatas.afterInvitedCall = invitedCall
	elseif curLevel < localData.needlv then ------等级不足
		XTHDTOAST(LANGUAGE_BTN_KEY.noEnoughLevel..localData.needlv)
	elseif playerMaxAdvance < localData.limitRank then -----没有合适的英雄 
		XTHDTOAST(LANGUAGE_MULTICOPY_TIPS8..localData.limitRank)
	end 
end