SpineAnimal = class( "SpineAnimal", function ( params )
	local resourceId = params.resourceId
	local spineID =  string.format("%03d",resourceId)
	print("spineID="..spineID)
	local jsonFile = nil		
	
	if spineID ~= 322 and spineID ~= 026 and spineID ~= 042 then
		jsonFile = "res/spine/" .. spineID .. ".skel"
	else
		jsonFile = "res/spine/" .. spineID .. ".json"
	end
	local atlasFile 		= "res/spine/" .. spineID .. ".atlas"
	return SpineBase:createWithParams({jsonFile = jsonFile , atlasFile = atlasFile })
end)

function SpineAnimal:ctor(params)
	--[[务必先获取节点的位置，否则在第一次使用的时候位置是错误的]]
	self:getSlotPositionInWorld("firePoint")
	self:getSlotPositionInWorld("root")
	self:getSlotPositionInWorld("midPoint")
	self:getSlotPositionInWorld( "hpBarPoint" )
	self._resourceId = params.resourceId
end

function SpineAnimal:getResourceId()
	return self._resourceId
end

function SpineAnimal:getSlotPositionInWorld(slotName,parent)
	local pointNode = self:getNodeForSlot( slotName )
	local _parent = parent
	if _parent == nil then
		_parent = cc.Director:getInstance():getRunningScene()
	end
	if pointNode and _parent then
		local pointWorldPos = pointNode:convertToWorldSpace(cc.p(0.5, 0.5));
		local pointNodePos = _parent:convertToNodeSpace( pointWorldPos );
		return pointNodePos
	end
	return cc.p(0,0)
end

--[[清除动画监听事件]]
function SpineAnimal:onCleanup()
	print("SpineAnimal:onCleanup")
	--[[--记得打开下面的注释]]
	self:_unregisterSpineEventHandler()
end

function SpineAnimal:_unregisterSpineEventHandler()
	self:unregisterSpineEventHandler(sp.EventType.ANIMATION_START)
	self:unregisterSpineEventHandler(sp.EventType.ANIMATION_END)
	self:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
	self:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
end

function SpineAnimal:createWithParams(params)
	return SpineAnimal.new(params)
end