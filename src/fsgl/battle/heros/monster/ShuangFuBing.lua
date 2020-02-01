--[[
    双斧兵-307
	对应monsterid:501~600
]]
local ShuangFuBing = class("ShuangFuBing", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function ShuangFuBing:create(params)
	return ShuangFuBing.new(params)
end

return ShuangFuBing