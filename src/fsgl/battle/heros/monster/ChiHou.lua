--[[
	斥候-315
	对应monsterid:901~1000
]]
local ChiHou = class("ChiHou", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function ChiHou:create(params)
	return ChiHou.new(params)
end

return ChiHou