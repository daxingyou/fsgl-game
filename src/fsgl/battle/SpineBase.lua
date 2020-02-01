SpineBase = class( "SpineBase", function ( params )
	local jsonFile 			= params.jsonFile
	local atlasFile 		= params.atlasFile
	local res = string.find(jsonFile,".skel")
	local skeletonNode = nil
	if res and res > 0 then
		skeletonNode =  sp.SkeletonAnimation:createWithBinaryFile(jsonFile, atlasFile, 1.0)
	else
		skeletonNode =  sp.SkeletonAnimation:create(jsonFile,atlasFile,1.0)
	end
	--local skeletonNode 		= sp.SkeletonAnimation:create(jsonFile, atlasFile, 1.0);
	--初始化，c++端实现，原理是调用一次update
	-- skeletonNode:setDebugBonesEnabled(true)
	-- skeletonNode:setDebugSlotsEnabled(true)
	return XTHDTouchExtend.extend(skeletonNode)
end)

function SpineBase:ctor(params)

end

function SpineBase:playAnimation(aniName,loop)
	self:setAnimation( 0, aniName, loop )
end

function SpineBase:createWithParams(params)
	return SpineBase.new(params)
end