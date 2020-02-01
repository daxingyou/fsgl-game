
function test_http()
    local gameScene = cc.Scene:create()

    --[[创建一个按钮]]
    local btn = XTHDPushButton:createWithParams({
        normalFile = "btn_7_normal.png"
        ,selectedFile = "btn_7_selected.png"
        ,disableFile = "btn_7_disabled.png"   
        ,needSwallow = true--是否需要吞噬事件
        --        ,text="button上的文字"
        ,label = XTHDLabel:createWithParams({text="请求网络",ttf="res/fonts/def.ttf",size=18})
        ,touchSize = cc.size(300,200)--触摸事件的点击范围大小
        ,endCallback = function()--触摸事件的回调函数
            XTHDHttp:startWithAsync("www.facebook.com",function(response,obj)
                print("网络返回成功")
            end,nil)
        end
    })
    btn:setAnchorPoint(cc.p(0,1.0))
    btn:setPosition(cc.p(100 ,310))
    gameScene:addChild(btn)


    --[[创建一个文本，根据参数创建]]
    local label2 = XTHDLabel:createWithParams({
        text=LANGUAGE_KEY_BACK-------"返回"--现实内容
        ,ttf="res/fonts/def.ttf"--字体
        ,size=40--文字大小
        ,endCallback = function()
            --        cc.Director:getInstance():popScene()
            print("点击了返回按钮")
            local texture = cc.TextureCache:getInstance():addImage("land.png")
            local obj = XTHDImage:createWithFileOrUrlDirectory("map/9_1.jpg","http://img2.hanjiangsanguo.com/hjimg/")
            obj:setPosition(300,300)
            gameScene:addChild(obj)
        end
    })
    label2:setAnchorPoint(cc.p(0,1.0))
    label2:setPosition(cc.p(300 ,410))
    gameScene:addChild(label2)
    
    XTHDPushButton:createWithFile("map/9_1.jpg")

    cc.Director:getInstance():pushScene(gameScene)

end