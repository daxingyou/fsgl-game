--赏金猎人boss升级界面
--@author hezhitao 2015.07.07
local ShangJinLieRenLevelUpPop = class("ShangJinLieRenLevelUpPop",function()
        return XTHDPopLayer:create()
    end)
local fontColor = cc.c3b(53,25,26)  --通用字体颜色
function ShangJinLieRenLevelUpPop:ctor(level_id,callback)
    self:init(level_id,callback)
end

function ShangJinLieRenLevelUpPop:init( ... )
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/goldcopy/levelup_frame.png") 
end

function ShangJinLieRenLevelUpPop:init(level_id,callback)

    self._before_arr = {}  --存放升级前的数据
    self._after_arr = {}   --存放升级后的数据
    self._jadite_num = nil --显示需要翡翠的数量
    self._callback = callback

    self._level = level_id or 1

    local _popBgSprite = cc.Sprite:create("res/image/common/scale9_bg1_34.png")
    local popNode = XTHDPushButton:createWithParams({
                        normalNode = _popBgSprite
                    })
    popNode:setTouchEndedCallback(function ()
        
    end)
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    -- self:addChild(popNode)
    self:addContent(popNode)
    self.popNode = popNode
    self:show()

    local title_txt = XTHDLabel:createWithParams({
        text = LANGUAGE_TIPS_WORDS94,-------"为张飞升级,获得更多奖励!",
        fontSize = 21,
        color = cc.c3b(106,36,13)
        })
    title_txt:setPosition(_popBgSprite:getContentSize().width/2,_popBgSprite:getContentSize().height-38)
    _popBgSprite:addChild(title_txt)

    --背景框2 
    local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    kuang:setContentSize(_popBgSprite:getContentSize().width-40,245)
    kuang:setAnchorPoint(0.5,0)
    kuang:setPosition(_popBgSprite:getContentSize().width/2,_popBgSprite:getContentSize().height/2-80)
    _popBgSprite:addChild(kuang)

    -- local levelup_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_5.png")
    local levelup_bg = ccui.Scale9Sprite:create()
    levelup_bg:setContentSize(_popBgSprite:getContentSize().width-40,165)
    levelup_bg:setPosition(_popBgSprite:getContentSize().width/2,_popBgSprite:getContentSize().height/2+60)
    _popBgSprite:addChild(levelup_bg)

    local desc_label = LANGUAGE_TIPS_WORDS95 ----------{"每100点伤害奖励:","可获得银两上限:","击杀的额外奖励:"}
    local tmp_data = gameData.getDataFromCSV("SilverGame")  --为了获取总共有多少等级，防止下标越界
    local current_data = gameData.getDataFromCSV("SilverGame", {["level"]=self._level})
    local next_data = {}
    local before_data = {tonumber(current_data["gold"])*100,current_data["limit"],current_data["killaward"]}
    local after_data = {}

    
    if self._level < #tmp_data then
        next_data = gameData.getDataFromCSV("SilverGame", {["level"]=tonumber(self._level)+1})
        after_data = {tonumber(next_data["gold"])*100,next_data["limit"],next_data["killaward"]}
    else
        after_data = LANGUAGE_TIPS_WORDS96-------{"最高层","最高层","最高层"}
    end

    for i=1,3 do
        --线
        if i < 3 then
            local line = cc.Sprite:create("res/image/common/line_1.png")
            line:setPosition(levelup_bg:getContentSize().width/2,levelup_bg:getContentSize().height/3*(3-i))
            line:setScaleX(1.3)
            levelup_bg:addChild(line)
        end

        --描述
        local desc = XTHDLabel:createWithParams({
            text = desc_label[i],
            fontSize = 18,
            color = fontColor
            })
        desc:setAnchorPoint(0,0.5)
        desc:setPosition(105,levelup_bg:getContentSize().height-25-(i-1)*levelup_bg:getContentSize().height/3)
        levelup_bg:addChild(desc)

        local gold_icon = cc.Sprite:create("res/image/common/header_gold.png")
        -- gold_icon:setPosition(desc:getPositionX()+desc:getContentSize().width+10,desc:getPositionY())
        gold_icon:setPosition(desc:getPositionX() + desc:getContentSize().width + 10,desc:getPositionY())
        gold_icon:setAnchorPoint(0,0.5)
        levelup_bg:addChild(gold_icon)

        --升级前数据
        local before_num = XTHDLabel:createWithParams({
            text = before_data[i],
            fontSize = 18,
            color = fontColor
            })
        before_num:setAnchorPoint(0,0.5)
        before_num:setPosition(gold_icon:getPositionX()+gold_icon:getContentSize().width+10,desc:getPositionY())
        levelup_bg:addChild(before_num)
        self._before_arr[#self._before_arr+1] = before_num

        --箭头
        local arrow_icon = cc.Sprite:create("res/image/goldcopy/arrow.png")
        arrow_icon:setAnchorPoint(0,0.5)
        arrow_icon:setPosition(390,desc:getPositionY()) 
        levelup_bg:addChild(arrow_icon)

        --升级后的数据
        local after_num = XTHDLabel:createWithParams({
            text = after_data[i],
            fontSize = 18,
            color = cc.c3b(88,143,4)
            })
        after_num:setAnchorPoint(0,0.5)
        after_num:setPosition(arrow_icon:getPositionX()+arrow_icon:getContentSize().width+10,desc:getPositionY())
        levelup_bg:addChild(after_num)
        self._after_arr[#self._after_arr+1] = after_num

    end

    -- local spend_bg = ccui.Scale9Sprite:create("res/image/common/op_white.png")
    local spend_bg = ccui.Scale9Sprite:create()
    spend_bg:setContentSize(_popBgSprite:getContentSize().width-40,40)
    spend_bg:setPosition(levelup_bg:getPositionX() + 75,levelup_bg:getPositionY()-levelup_bg:getContentSize().height/2-30)
    _popBgSprite:addChild(spend_bg)

     --升级消耗
    local levelup_spend_label = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_LEVEL_LIMIT..":",-------需求玩家等级:",
        fontSize = 18,
        color = fontColor
        })
    levelup_spend_label:setAnchorPoint(0,0.5)
    levelup_spend_label:setPosition(20+10,spend_bg:getContentSize().height/2)
    spend_bg:addChild(levelup_spend_label)

    local level_num = XTHDLabel:createWithParams({
        text = (current_data["needlv"] or 1),
        fontSize = 18,
        color = fontColor
        })
    level_num:setAnchorPoint(0,0.5)
    level_num:setPosition(levelup_spend_label:getPositionX()+levelup_spend_label:getContentSize().width,levelup_spend_label:getPositionY())
    spend_bg:addChild(level_num)

    --如果等级不够，就用红色显示
    if gameUser.getLevel() < tonumber(current_data["needlv"]) then
        level_num:setColor(cc.c3b(255,0,0))
    end

    self._level_num = level_num

    local levelup_spend = XTHDLabel:createWithParams({
        text = LANGUAGE_TIP_LEVELUP_COST..":",------升级消耗:",
        fontSize = 18,
        color = fontColor
        })
    levelup_spend:setAnchorPoint(0,0.5)
    levelup_spend:setPosition(level_num:getPositionX()+level_num:getContentSize().width+30,level_num:getPositionY())
    spend_bg:addChild(levelup_spend)

    --翡翠
    local jadite_icon = cc.Sprite:create("res/image/common/header_feicui.png")
    jadite_icon:setPosition(levelup_spend:getPositionX()+levelup_spend:getContentSize().width+20,levelup_spend:getPositionY()) 
    spend_bg:addChild(jadite_icon)

    --升级后的数据
    self._jadite_num = getCommonWhiteBMFontLabel(current_data["needfeicui"])
    self._jadite_num:setAnchorPoint(0,0.5)
    self._jadite_num:setPosition(jadite_icon:getPositionX()+jadite_icon:getContentSize().width-10,levelup_spend_label:getPositionY()-6)
    spend_bg:addChild(self._jadite_num)

    --取消按钮
    local cancel_btn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(130, 51),
        isScrollView = false,
        fontSize = 26,
        pos = cc.p(_popBgSprite:getContentSize().width/3-30, 75),
        text = LANGUAGE_KEY_CANCEL,
        endCallback = function()
            self:hide()
        end
    })
    cancel_btn:setScale(0.8)
    _popBgSprite:addChild(cancel_btn)

    --升级按钮
    
    local levelup_btn = XTHD.createCommonButton({
        btnColor = "write",
        btnSize = cc.size(130, 51),
        isScrollView = false,
        fontSize = 26,
        pos = cc.p(_popBgSprite:getContentSize().width/3*2+30, cancel_btn:getPositionY()),
        text = LANGUAGE_MAINCITY_FUNCNAME4,
        endCallback = function (  )
            self:doHttpLevelUp()
        end
    })
    levelup_btn:setScale(0.8)
    _popBgSprite:addChild(levelup_btn)

end

function ShangJinLieRenLevelUpPop:doHttpLevelUp(  )
    ClientHttp:requestAsyncInGameWithParams({
        modules = "upGoldEctypeLevel?",
        successCallback = function(data)
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                return
            end
            if tonumber(data["result"]) == 0 then
                self:updataData(data)
                XTHD.dispatchEvent({name = "PLAY_EFFECT"})
            elseif tonumber(data["result"]) == 3711 then   --等级不足
                local _confirmLayer = XTHDConfirmDialog:createWithParams( {
                        rightCallback  = function ()
                            replaceLayer({
                                fNode = self:getParent(),
                                id = 22
                            })
                            self:hide()
                            
                        end,
                        msg = LANGUAGE_TIPS_WORDS97--------"等级不足,是否去完成主线任务获取经验?"
                    } );
                self:addChild(_confirmLayer)
            elseif tonumber(data["result"]) == 2005 then   --翡翠不足
                local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=4})
                -- local _confirmLayer = XTHDConfirmDialog:createWithParams( {
                --         rightCallback  = function ()
                --             replaceLayer({
                --                 fNode = self:getParent(),
                --                 id = 15
                --             })
                --             self:hide()
                --         end,
                --         msg = LANGUAGE_TIPS_WORDS98,--------"翡翠不足,是否使用元宝兑换翡翠?"
                --     } );
                self:addChild(StoredValue)
            else
                XTHDTOAST(data["msg"])
            end
            
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ShangJinLieRenLevelUpPop:updataData( data)
    -- self._before_arr = {}  --存放升级前的数据
    -- self._after_arr = {}   --存放升级后的数据
    -- self._jadite_num = 0 --显示需要翡翠的数量


    self._level = data["ectypeLevel"]
    local tmp_data = gameData.getDataFromCSV("SilverGame")  --为了获取总共有多少等级，防止下标越界
    local current_data = gameData.getDataFromCSV("SilverGame", {["level"]=self._level})
    local next_data = {}
    local before_data = {tonumber(current_data["gold"])*100,current_data["limit"],current_data["killaward"]}
    local after_data = {}


    if self._level < #tmp_data then
        next_data = gameData.getDataFromCSV("SilverGame", {["level"]=tonumber(self._level)+1})
        after_data = {tonumber(next_data["gold"])*100,next_data["limit"],next_data["killaward"]}
    else
        after_data = LANGUAGE_TIPS_WORDS96-------{"最高层","最高层","最高层"}
    end

    for i=1,#self._before_arr do
        self._before_arr[i]:setString(before_data[i])
    end

    for i=1,#self._after_arr do
        self._after_arr[i]:setString(after_data[i])
    end

    self._jadite_num:setString(current_data["needfeicui"])

    --刷新下一等级
    local needlv = current_data["needlv"] or 1
    self._level_num:setString(needlv)
    if gameUser.getLevel() < tonumber(needlv) then
        self._level_num:setColor(cc.c3b(255,0,0))
    end

    --执行回调，刷新银两副本中的等级
    if self._callback ~= nil and type(self._callback) == "function" then
       self._callback(self._level)
    end

    --刷新TopBar翡翠数据
    gameUser.setFeicui(data.feicui)
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})      --刷新topbar数据
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO}) ---刷新主城市的，

    self:removeFromParent()

    --更新银两副本中ectypeLevel数据
end



function ShangJinLieRenLevelUpPop:create(level_id,callback)
    local _layer = self.new(level_id,callback)
    return _layer
end
return ShangJinLieRenLevelUpPop