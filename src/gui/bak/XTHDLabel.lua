--  Created by zhangchao on 14-11-01.
--[[
--创建默认参数
local defaultParams = {
text = "",
fontSize = nil,--字体大小
size = nil,--字体大小，同上
ttf = nil,--自定义字体，默认字体使用:Helvetica
fnt             = nil,
kerning         = 0,----左右字距
pos = cc.p(0,0),
color = cc.c3b(255, 255, 255),
anchor = cc.p(0.5,0.5),--锚点
needSwallow = false,--是否需要吞噬事件，默认不吞噬
clickable = true,--是否可以点击
beganCallback = nil,--点击事件的按下回调
endCallback = nil,--点击事件的抬起回调
touchSize = cc.size(0,0)--点击区域，如果没有传值，则默认点击区域为getBoundingBox()
}
]]
XTHDLabel = class("XTHDLabel", function(params)
   
end)

--[[设置字体大小，可以保证不改变字体样式]]
function XTHDLabel:setFontSize(fontSize)
    
end

--[[
--创建默认参数
local defaultParams = {
text = "",
fontSize = nil,--字体大小
size = nil,--字体大小，同上
ttf = nil,--自定义字体，默认字体使用:Helvetica
fnt             = nil,
kerning         = 0,----左右字距
pos = cc.p(0,0),
color = cc.c3b(255, 255, 255),
anchor = cc.p(0.5,0.5),--锚点
needSwallow = false,--是否需要吞噬事件，默认不吞噬
clickable = true,--是否可以点击
beganCallback = nil,--点击事件的按下回调
endCallback = nil,--点击事件的抬起回调
touchSize = cc.size(0,0)--点击区域，如果没有传值，则默认点击区域为getBoundingBox()
}
]]
function XTHDLabel:createWithParams(params)
end

function XTHDLabel:create(text,fontSize,ttf)
end
