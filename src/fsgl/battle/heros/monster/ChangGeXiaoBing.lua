--[[
	长戈小兵-305
	对应monsterid:401~500
]]
local ChangGeXiaoBing = class("ChangGeXiaoBing", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function ChangGeXiaoBing:create(params)
	return ChangGeXiaoBing.new(params)
end

return ChangGeXiaoBing