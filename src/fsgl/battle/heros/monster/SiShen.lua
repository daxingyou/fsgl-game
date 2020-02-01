--[[
死神-301
对应的monsterid:1301~1400
]]
local SiShen = class("SiShen", function(params)
    local animal = Character:_create(params)
    return animal
end )

function SiShen:create(params)
    return SiShen.new(params)
end

return SiShen