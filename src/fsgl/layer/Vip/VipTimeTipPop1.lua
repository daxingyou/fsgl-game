--[[
    FileName: VipTimeTipPop1.lua
    Author: andong
    Date: 2015-12-19
    Purpose: xx界面
]]
local VipTimeTipPop1 = class( "VipTimeTipPop1", function ()
    return XTHDPopLayer:create({isRemoveLayout = true})
end)
function VipTimeTipPop1:ctor(params)
    self:initData(params)
    self:initUI()
    self:show()
end
function VipTimeTipPop1:initData(params)
    self._restTime = params.time
    self._type = params.type
end
function VipTimeTipPop1:initUI()
    local popSize = cc.size(375,228)
    local popNode = ccui.Scale9Sprite:create(cc.rect(45,45,1,1), "res/image/common/scale9_bg_34.png")
    popNode:setContentSize(popSize)
    popNode:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
    self:addContent(popNode)
    local close = XTHD.createBtnClose(function()
        self:hide()
    end)
    close:setPosition(popSize.width-5, popSize.height-5)
    popNode:addChild(close)

    local myLab1 = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_RECHARGEING.."  ",
        fontSize = 20,
        color = XTHD.resource.color.brown_desc,
        anchor = cc.p(0.5, 0.5),
        pos = cc.p(popSize.width/2-10, popSize.height/2 + 20),
    })
    popNode:addChild(myLab1)
    local myLab2 = XTHDLabel:createWithParams({
        text = self._restTime,
        fontSize = 22,
        color = XTHD.resource.color.brown_desc,
        anchor = cc.p(0, 0.5),
        pos = cc.p(myLab1:getPositionX()+myLab1:getContentSize().width/2, myLab1:getPositionY()+1),
    })
    popNode:addChild(myLab2)
    
    local restTime = self._restTime
    schedule(self, function()
        restTime = restTime - 1
        print("restTime == ", restTime)

        myLab2:setString(tostring(restTime))

        if restTime <= 0 then
            if self._type == 1 then
                gameUser._vipRechargeTime.monthCard = 0
            elseif self._type == 2 then
                gameUser._vipRechargeTime.zhizhunCard = 0
            end
            self:hide()
        end
    end,1.0, nil)
    

    local confirm = XTHD.createCommonButton({
        endCallback = function()
            self:hide()
        end,
        text = LANGUAGE_BTN_KEY.sure,
        isScrollView = false,
        anchor = cc.p(0.5, 0),
        pos = cc.p(popSize.width/2, 12)
    })
    popNode:addChild(confirm)

end
function VipTimeTipPop1:create(params)
    return self.new(params)
end

function VipTimeTipPop1:onEnter()
    print("onEnter ====")
end
function VipTimeTipPop1:onCleanup()
    print("onCleanup ====")
end
function VipTimeTipPop1:onExit()
    print("onExit ====")
end

return VipTimeTipPop1