
--[[设置文字]]
function XTHDPushButton:setLabel(label)
	
end

function XTHDPushButton:getLabel()
   
end

--[[设置文字]]
function XTHDPushButton:setText(text)
   
end

--设置Label大小
function XTHDPushButton:setLabelSize(fontSize)
    
end

--设置Label颜色
function XTHDPushButton:setLabelColor(c3b)
   
end

function XTHDPushButton:getLabelColor()
   
end

function XTHDPushButton:setString(text)
   
end

--[[设置成选中状态 true | false]]
function XTHDPushButton:setSelected(flag)
    
end

--设置按钮是否可用
function XTHDPushButton:setEnable(flag)
    
end


function XTHDPushButton:isEnable()
    
end

--设置正常时的图片精灵
function XTHDPushButton:setStateNormal(label)
    
end

function XTHDPushButton:getStateNormal()
    
end

--设置选中时的图片精灵
function XTHDPushButton:setStateSelected(label)
   
end

function XTHDPushButton:getStateSelected()
    
end

--设置不可用时的图片精灵
function XTHDPushButton:setStateDisable(label)
    
end

function XTHDPushButton:getStateDisable()
    
end

function XTHDPushButton:setMusicFile(musicFile)
    
end

function XTHDPushButton:getMusicFile()
    
end


function XTHDPushButton:setTouchMovedCallback( callback )
end

function XTHDPushButton:getTouchMovedCallback( )
end


function XTHDPushButton:ctor(params)
	
end
--设置滑动的时候是否响应点击
function XTHDPushButton:setEnableWhenMoving(flag)
end

function  XTHDPushButton:getEnableWhenMoving()
end
--设置是否需要移出区域还相应事件
function XTHDPushButton:setEnableWhenOut(flag)
end

function XTHDPushButton:getEnableWhenOut()
end

function XTHDPushButton:playMusic()
end

--[[
local defaultParams = {
        normalNode        = nil,--默认状态下显示的node，通常为精灵
        selectedNode      = nil,--选中状态下显示的node,通常为精灵
        disableNode       = nil,--不可点击时显示的node,通常为精灵
        label             = nil,--按钮的文字node，通常为label控件,例如cc.Label
        normalFile        = nil,--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = nil,--选中状态下显示的精灵的文件名(如果同时传入selectedNode,则优先使用selectedNode)
        disableFile       = nil,--不可点击状态下显示的精灵文件名
        musicFile         = XTHD.resource.music.effect_btn_common,--点击的音效文件路径
        needSwallow       = true,--是否吞噬事件
        clickable         = true,--是否可以点击
        enable            = true,--true代表可点击，false代表不可点击，且按钮变灰，默认为true
        beganCallback     = nil,
        endCallback       = nil,--
        moveCallback      = nil,----
        ttf               = nil,--
        fnt               = nil,--
        text              = nil,--文字，字符串类型，如果传入了该字段，则优先使用该字段
        fontSize          = 18,--字体大小
        fontColor         = cc.c3b(255, 255, 255),
        touchSize         = cc.size(0,0),--点击区域，如果没有传值，则默认点击区域为getBoundingBox()
        touchScale        = 1,--点击按钮时的缩放比例
        anchor            = cc.p(0.5,0.5),--锚点
        pos               = cc.p(0,0),--坐标
        x                 = 0,--x
        y                 = 0,--y
        needEnableWhenMoving = false,   --当滑动的时候，时候响应点击事件,默认滑动的时候响应点击事件  yanyuling true的话滑动不响应 false滑动响应
        needEnableWhenOut = false,      --是否在移出点击范围内抬起还相应end事件 liuluyang
    }
]]
function XTHDPushButton:createWithParams(params)
end
--[[创建一个button，该button实质就是一个精灵]]
function XTHDPushButton:create(filePath)
end
--通过文件名创建一个button，注意：其实质就是个精灵，所以完全可当作精灵来使用，主要区别就是加上了点击相关的判断而已
function XTHDPushButton:createWithFile(filePath,params)
end

function XTHDPushButton:createWithTexture(texture,rect)
    
end
