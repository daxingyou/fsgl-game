function battle_test()
    local scene = cc.Scene:create()
    local clazz = requires("src/battle/TestBattleLayer.lua")
    scene:addChild(clazz:create())
    cc.Director:getInstance():pushScene(scene)
    do return end
    local battleLayer = requires("src/battle/BattleLayer.lua"):createWithParams( {
        bgList =
        {
            "res/image/background/bg_10.jpg",
            "res/image/background/bg_11.jpg",
            "res/image/background/bg_12.jpg",
            "res/image/background/bg_13.jpg",
            "res/image/background/bg_14.jpg"
        },
        teamListLeft =
        {
            {
                Character:createWithParams( {
                    id = 1,
                    _type = ANIMAL_TYPE.PLAYER
                } )
            }
        },
        teamListRight =
        {
            {
                story = "我是剧情我是剧情我是剧情我是剧情我是剧情我是剧情我是剧情我是剧情",
                team =
                {
                    Character:createWithParams( {
                        id = 1,
                        _type = ANIMAL_TYPE.PLAYER
                    } )
                }
            },
            {
                team = { }
            },
            {
                story = "还有剧情"
            },
            {
                story = "还有剧情"
            },
            {
                story = "还有剧情"
            },
            {
                team = { }
            }
        }
    } )
    scene:addChild(battleLayer)
    battleLayer:start()
    cc.Director:getInstance():pushScene(scene)
end
