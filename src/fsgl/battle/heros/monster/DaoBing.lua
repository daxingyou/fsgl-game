--[[
	刀兵-318
	只有动作atk
]]
local DaoBing = class("DaoBing", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function DaoBing:create(params)
	return DaoBing.new(params)
end

return DaoBing