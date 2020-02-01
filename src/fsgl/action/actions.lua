--[[ 游戏中常见的动画都在这里获取，如果需要修改，也都是在此处修改，所以最好加上注释 ]]
XTHD = XTHD or { }
XTHD.action = XTHD.action or { }

XTHD.action.type = {
    wuligongji = "wuligongji",
    wulibaoji = "wulibaoji",
    fashugongji = "fashugongji",
    fashubaoji = "fashubaoji",
    jiaxue = "jiaxue",
    jinbizengjia = "jinbizengjia",
    nuqizengjia = "nuqizengjia",
    buff = "buff",--[[ 各种buff字体使用 ]]
}
--[[ 战斗中的各种文字提示 ]]
XTHD.action.runActionTipCharacter = function(params)
    local parent = params.parent
    local position = params.position
    local crit = params.crit
    local text = params.text
    local _type = params._type
    local zOrder = params.zOrder

    local targetNode = XTHD.createSprite()

    local action = cc.Show:create()

    if _type == XTHD.action.type.buff then
        --[[ 只有特定buff才需要显示 ]]
        if (tonumber(text) and tonumber(text) > 25)
            or text == "clear"
            or text == "discrupt"
            or text == "dodge"
            or text == "immunity"
            or text == "shield"
            or text == "23_1"
            or text == "23_2"
            or text == "24_1"
            or text == "24_2"
            or text == "25_1"
            or text == "25_2"
            or text == "39_1"
            or text == "39_2" then
            -- if gameUser.getLevel() > 2 then
            targetNode = XTHD.createSprite("res/fonts/buffWord/" .. text .. ".png")
            -- end
        end
        position.y = position.y + 40
    else
        local font = "res/fonts/" .. _type .. ".fnt"
        if crit == true then
            if _type == XTHD.action.type.wulibaoji then
                text = "BJ" .. text
                font = "res/fonts/wulibaoji.fnt"
            elseif _type == XTHD.action.type.fashubaoji then
                text = "BJ" .. text
                font = "res/fonts/fashubaoji.fnt"
            end
        end
        targetNode = cc.Label:createWithBMFont(font, text)
        targetNode:setCascadeOpacityEnabled(true)
        targetNode:setAdditionalKerning(-1)
        targetNode:setAnchorPoint(cc.p(0.5, 0.5));

    end
    if targetNode then
        targetNode:setPosition(position);
        if zOrder then
            parent:addChild(targetNode, zOrder)
        else
            parent:addChild(targetNode)
        end
    else
        return targetNode
    end

    if _type == XTHD.action.type.wuligongji
        or _type == XTHD.action.type.fashugongji
        or _type == XTHD.action.type.fashubaoji
        or _type == XTHD.action.type.wulibaoji
        or _type == XTHD.action.type.buff then
        targetNode:setScale(0.2)

        local t = 0.1
        local fadeTime = 0.3

        math.newrandomseed()
        local arr = { }
        arr[#arr + 1] = -5
        arr[#arr + 1] = 0
        arr[#arr + 1] = 10
        arr[#arr + 1] = 15
        arr[#arr + 1] = 20
        arr[#arr + 1] = 25
        arr[#arr + 1] = 30
        local random = math.random(#arr)
        local scale = 0.75
        local height = 70
        if crit == true then
            scale = 1
            height = 100
        end
        action = cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(t, cc.p(0, arr[random] + height)), cc.FadeIn:create(t), cc.ScaleTo:create(t, 0.4)),
        cc.ScaleTo:create(t, scale),
        cc.FadeTo:create(0.4, 180),
        cc.Spawn:create(cc.FadeOut:create(fadeTime), cc.MoveBy:create(fadeTime, cc.p(0, 20 + 40))),
        cc.RemoveSelf:create(true))
        if _type == XTHD.action.type.buff then
            action = cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(t, cc.p(0, arr[random] + height)), cc.FadeIn:create(t), cc.ScaleTo:create(t, 0.4)),
            cc.ScaleTo:create(t, scale),
            cc.FadeOut:create(0.4 * 2 + fadeTime),
            cc.RemoveSelf:create(true))
        end
    elseif _type == XTHD.action.type.jiaxue or _type == XTHD.action.type.nuqizengjia then
        targetNode:setAdditionalKerning(-2)
        targetNode:setScale(0.75)
        local fadeTime = 0.6
        action = cc.Sequence:create(cc.Spawn:create(cc.FadeTo:create(fadeTime, 50), cc.MoveBy:create(fadeTime, cc.p(0, 3 * 40))),
        cc.RemoveSelf:create(true))
    elseif _type == XTHD.action.type.jinbizengjia then
        targetNode:setScale(0.5)
        local fadeTime = 0.5
        action = cc.Sequence:create(cc.EaseIn:create(cc.MoveBy:create(fadeTime, cc.p(0, 40)), fadeTime),
        cc.FadeOut:create(0.1),
        cc.RemoveSelf:create(true))
    end


    targetNode:runAction(action)
    return targetNode
end
--[[ 弹窗动画 ]]
XTHD.action.runActionPop = function(targetNode)
    targetNode:setScale(0.3)
    targetNode:runAction(cc.Sequence:create(cc.ScaleTo:create(0, 0.3), cc.ScaleTo:create(0.15, 1.08), cc.ScaleTo:create(0.03, 1), cc.FadeIn:create(0.15 + 0.03)))
end
--[[ --toast ]]
XTHD.action.runActionToast = function(targetNode)
    targetNode:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveBy:create(0.264, cc.p(0, 45)), 0.264), cc.DelayTime:create(1.760), cc.Spawn:create(cc.FadeOut:create(0.176), cc.MoveBy:create(0.176, cc.p(0, 35))), cc.RemoveSelf:create(true)))
end


XTHD.action.runActionShake = function(params)
    local delta = 3
    local time = 0.1
    local speed = 0.05
    local shakeNode = cc.Director:getInstance():getRunningScene()
    if params then
        if params.delta then
            delta = params.delta
        end
        if params.time then
            time = params.time
        end
        if params.speed then
            speed = params.speed
        end
        if params.shakeNode then
            shakeNode = params.shakeNode
        end
    end
    time = math.modf(time * 10)
    if time < 1 then
        time = 1
    end

    local _shakePos1 = cc.p(delta * 0.5, delta * 0.5)
    local _shakePos2 = cc.p(- delta, - delta)
    --[[ --防止多个震屏互相叠加 ]]
    -- self:setPosition(cc.p(0,0))
    shakeNode:runAction(cc.Repeat:create(cc.Sequence:create(
    cc.MoveBy:create(speed * 0.5, _shakePos1),
    cc.MoveBy:create(speed, _shakePos2),
    cc.MoveBy:create(speed * 0.5, _shakePos1)
    ), time))
end