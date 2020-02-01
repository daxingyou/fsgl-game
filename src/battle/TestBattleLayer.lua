xpcall( function()
    requires("EnemyList.lua")
    gameData.EnemyList = _G.EnemyList
    gameData.analyseDataByPrimaryKey()
end , function()
    print("没有找到EnemyList.lua，请手动将他复制到与src的同级目录中")
end )

local TestBattleLayer = class("TestBattleLayer", function(tab)
    return XTHDDialog:create()
end )

function TestBattleLayer:ctor(tab)
    local bg = ccui.Scale9Sprite:create(cc.rect(40, 40, 1, 2), "res/image/common/scale9_bg_34.png")
    bg:setContentSize(819, 515)
    bg:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    self:addChild(bg)
    local title = XTHD.createLabel( {
        text = "第一波对战怪物"
    } )
    title:setPosition(cc.p(bg:getContentSize().width / 2, bg:getContentSize().height))
    bg:addChild(title)
    local close_btn = XTHD.createBtnClose( function()
        cc.Director:getInstance():popScene()
    end )
    close_btn:setPosition(bg:getContentSize().width - 10, bg:getContentSize().height - 10)
    bg:addChild(close_btn)
    title = XTHD.createLabel( {
        text = "左边人物"
    } )
    title:setPosition(cc.p(250, 440))
    bg:addChild(title)
    title = XTHD.createLabel( {
        text = "右边怪物"
    } )
    title:setPosition(cc.p(600, 440))
    bg:addChild(title)
    local left = { }
    local right = { }
    for i = 1, 5 do
        local input_bg_account = ccui.Scale9Sprite:create("res/image/common/op_white.png")
        input_bg_account:setContentSize(340, 40)
        input_bg_account:setPosition(cc.p(250, 420 - i * 40))
        bg:addChild(input_bg_account)
        local editbox_account = ccui.EditBox:create(cc.size(300, input_bg_account:getContentSize().height), ccui.Scale9Sprite:create(), nil, nil)
        editbox_account:setFontColor(cc.c3b(92, 91, 91))
        editbox_account:setPlaceHolder("输入heroId")
        editbox_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        editbox_account:setMaxLength(30)
        editbox_account:setPosition(input_bg_account:getPosition())
        editbox_account:setPlaceholderFontColor(cc.c3b(181, 181, 181))
        editbox_account:setFontName("Helvetica")
        editbox_account:setPlaceholderFontName("Helvetica")
        editbox_account:setFontSize(24)
        editbox_account:setPlaceholderFontSize(24)
        editbox_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        bg:addChild(editbox_account)
        if i == 1 then
            editbox_account:setText("1")
        elseif i == 2 then
        elseif i == 3 then
        elseif i == 4 then
        elseif i == 5 then
        end
        left[#left + 1] = editbox_account
        input_bg_account = ccui.Scale9Sprite:create("res/image/common/op_white.png")
        input_bg_account:setContentSize(340, 40)
        input_bg_account:setPosition(cc.p(600, 420 - i * 40))
        bg:addChild(input_bg_account)
        editbox_account = ccui.EditBox:create(cc.size(300, input_bg_account:getContentSize().height), ccui.Scale9Sprite:create(), nil, nil)
        editbox_account:setFontColor(cc.c3b(92, 91, 91))
        editbox_account:setPlaceHolder("输入monsterId")
        editbox_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
        editbox_account:setMaxLength(30)
        editbox_account:setPosition(input_bg_account:getPosition())
        editbox_account:setPlaceholderFontColor(cc.c3b(181, 181, 181))
        editbox_account:setFontName("Helvetica")
        editbox_account:setPlaceholderFontName("Helvetica")
        editbox_account:setFontSize(24)
        editbox_account:setPlaceholderFontSize(24)
        editbox_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        bg:addChild(editbox_account)
        if i == 1 then
        elseif i == 2 then
        elseif i == 3 then
        elseif i == 4 then
        elseif i == 5 then
        end
        right[#right + 1] = editbox_account
    end
    local btn_fight,battle_effect = XTHD.createFightBtn( {
        par = bg,
        pos = cc.p(bg:getContentSize().width / 2,100)
    } )
	
	btn_fight:setTouchBeganCallback(function()
		if battle_effect then
			battle_effect:setScale(0.98)
		end
	end)

	btn_fight:setTouchMovedCallback(function()
		if battle_effect then
			battle_effect:setScale(1)
		end
	end)
	
    btn_fight:setTouchEndedCallback( function()
		if battle_effect then
			battle_effect:setScale(1)
		end
        local teamListLeft = { }
        local teamListRight = { }
        local bgList = { }
        for k, target in pairs(left) do
            local text = target:getText()
            if text == nil or string.len(text) < 1 then
            else
                local id = tonumber(text)
                local animal = {
                    id = id,
                    _type = ANIMAL_TYPE.PLAYER
                }
                teamListLeft[#teamListLeft + 1] = animal
            end
        end
        bgList = {
            "res/image/background/bg_10.jpg",
            "res/image/background/bg_11.jpg",
            "res/image/background/bg_12.jpg",
            "res/image/background/bg_13.jpg",
            "res/image/background/bg_14.jpg"
        }
        local rightData = { }
        local team = { }
        for k, target in pairs(right) do
            local text = target:getText()
            if text == nil or string.len(text) < 1 then
            else
                local id = tonumber(text)
                local animal = {
                    id = id,
                    _type = ANIMAL_TYPE.PLAYER
                }
                team[#team + 1] = animal
            end
        end
        rightData.team = team
        teamListRight[#teamListRight + 1] = rightData
        if #teamListLeft < 1 and #teamListRight < 1 then
            XTHDTOAST("请添加人物")
            return
        end
        local battleLayer = requires("src/battle/BattleLayer.lua"):create()
        battleLayer:initWithParams( {
            bgList = bgList,
            battleType = BattleType.PVE,
            battleTime = 180,
            teamListLeft = { teamListLeft },
            teamListRight = teamListRight,
            battleEndCallback = function(params)
                performWithDelay(battleLayer, function()
                    -- dump(params, "wm----battleEndCallback : ")
                    cc.Director:getInstance():popScene()
                end , 1.5)
            end
        } )
        local scene = cc.Scene:create()
        scene:addChild(battleLayer)
        scene:addChild(BattleUIExploreLayer:create())
        battleLayer:start()
        cc.Director:getInstance():pushScene(scene)
    end )
end
function TestBattleLayer:create()
    return TestBattleLayer.new()
end

return TestBattleLayer