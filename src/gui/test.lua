--  Created by zhangchao on 14-11-01.

function test_gui()
    local gameScene = cc.Scene:create()
    
--[[创建一个按钮]]
    local btn = XTHDPushButton:createWithParams({
        normalFile = "btn_7_normal.png"
        ,selectedFile = "btn_7_selected.png"
        ,disableFile = "btn_7_disabled.png"   
        ,needSwallow = true--是否需要吞噬事件
--        ,text="button上的文字"
        ,label = XTHDLabel:createWithParams({text="按钮文字",ttf="res/fonts/def.ttf",size=18})
        ,touchSize = cc.size(300,200)--触摸事件的点击范围大小
        ,endCallback = function()--触摸事件的回调函数
            print("你点击了我")
        end
    })
    btn:setAnchorPoint(cc.p(0,1.0))
    btn:setPosition(cc.p(100 ,310))
    gameScene:addChild(btn)


--[[创建一个文本，使用系统默认字体]]
    local label = XTHDLabel:create("我是文字",40) --只需要传入显示的文字和大小即可，字体默认使用系统的

    label:setAnchorPoint(cc.p(0,1.0))
    label:setPosition(cc.p(100 ,510))
    gameScene:addChild(label)
    label:setTouchEndedCallback(function() 
        btn:setLabelSize(40)
        btn:setSelected(true)
    end)


--[[创建一个文本，根据参数创建]]
    local label2 = XTHDLabel:createWithParams({
    text="返回"--现实内容
    ,ttf="res/fonts/def.ttf"--字体
    ,size=40--文字大小
    ,endCallback = function()
--        cc.Director:getInstance():popScene()
        print("点击了返回按钮")
        local texture = cc.TextureCache:getInstance():addImage("land.png")
            local obj = XTHDPushButton:createWithTexture(texture,cc.rect(0,0,texture:getContentSize().width,texture:getContentSize().height/2))
        obj:setPosition(300,300)
        gameScene:addChild(obj)
    end
    })
    label2:setAnchorPoint(cc.p(0,1.0))
    label2:setPosition(cc.p(300 ,410))
    gameScene:addChild(label2)


    cc.Director:getInstance():pushScene(gameScene)


--[[
dialog的使用
    local dialog = XTHDDialog:create()
    self:addChild(dialog)
    dialog:setColor(cc.c3b(255, 0, 0))
    dialog:setTouchEndedCallback(function()
        print("点击")
    end)
]]

end