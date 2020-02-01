

local BattleUIEquipLayer = class("BattleUIEquipLayer", function()

    return XTHD.createLayer()
end)

function BattleUIEquipLayer:ctor(data,battle_type)
    local width = self:getContentSize().width;
    local height = self:getContentSize().height;
	--自动战斗按钮
	-- local btnAuto = createAutoButton(BattleType.EQUIP_PVE)--XTHDSprite:create("res/image/tmpbattle/autocombat_off.png")
	-- btnAuto:setPosition(cc.p(btnAuto:getContentSize().width / 2 + 17, self:getContentSize().height - btnAuto:getContentSize().height / 2 - 10))
	-- self:addChild(btnAuto)	

    local handle = function ( event )
        if event == "cleanup" then
            self:onCleanup()
        end
    end
    self:registerScriptHandler(handle)
end

function BattleUIEquipLayer:onCleanup()
    if not self._notPlay then
        musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_main,true)
    end
end
function BattleUIEquipLayer:create(data,battle_type)
    return BattleUIEquipLayer.new(data,battle_type) 
end
return BattleUIEquipLayer