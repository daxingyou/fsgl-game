--[[
    机关傀儡-316
	对应monsterid:1401~1500
]]
local JiGuanKuiLei = class("JiGuanKuiLei", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function JiGuanKuiLei:create(params)
	return JiGuanKuiLei.new(params)
end

return JiGuanKuiLei