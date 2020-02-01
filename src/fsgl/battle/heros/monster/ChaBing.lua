--[[
	叉兵-312
	只有动作atk
	对应monsterid:801~900
]]
local ChaBing = class("ChaBing", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function ChaBing:create(params)
	return ChaBing.new(params)
end

return ChaBing