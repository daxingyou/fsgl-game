requires("src/fsgl/db/DBTableHero.lua")
requires("src/fsgl/db/DBTableHeroSkill.lua")
requires("src/fsgl/db/DBTableItem.lua")
requires("src/fsgl/db/DBTableEquipment.lua")
requires("src/fsgl/db/DBTableInstance.lua")
requires("src/fsgl/db/DBTableArtifact.lua")
requires("src/fsgl/db/CopiesData.lua")
requires("src/fsgl/db/DBUserTeamData.lua")
requires("src/fsgl/db/DBPetData.lua")

DBUpdateFunc = {}

function DBUpdateFunc:UpdateProperty( tableName,prop_id, data, heroid,noLevelup )

	local hasLevelUp = false
	if tableName == "userdata" then
		if tonumber(prop_id) == 400 and not noLevelup then
			if tonumber(data) > gameUser.getLevel() then
				local LevelUp = requires("src/fsgl/layer/common/ShengJiLayer.lua").new(tonumber(data), gameUser.getLevel(), function( )
					----新版本（1）引导 
					YinDaoMarg:getInstance():triggerGuide(1,tonumber(data))
					-- YinDaoMarg:getInstance():triggerGuide(1,data)
				end)
	            cc.Director:getInstance():getRunningScene():addChild(LevelUp,100)   			
	            LevelUp:setName("playerLevelUp")
	            hasLevelUp = true
	        end
		end
		gameUser.updateDataById(prop_id,data)
	elseif tableName == "userheros" then
		DBTableHero.updateDataByPropId(gameUser.getUserId(),prop_id, data, heroid )
	end
	return hasLevelUp
end
