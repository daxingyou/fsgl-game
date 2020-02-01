local mUserDataMgr = UserDataMgr
BuildingItem1 = class("BuildingItem1", function(params)
    params.buildingId = params.buildingId == nil and 1 or params.buildingId

    local _isSpine = true
    local _targSpine = nil
    local jianzhu = nil
    local button = XTHDPushButton:createWithParams( {
        anchor = cc.p(0.5,0),
        -- 已经商定好   用(0.5, 0)作为锚点，建筑成形后记得修改
        needSwallow = false,
        needEnableWhenMoving = true,
        musicFile = XTHD.resource.music.effect_btn_common,
    } )
    local extralY = 0
    if params.buildingId == 1 then
        ---- 演武场
        -- _targSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/yanwuchang.json", "res/image/homecity/frames/spine/yanwuchang.atlas", 1.0)
        -- _targSpine:setAnimation(0,"idle",true)

        _targSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/mySpine/yanwuchang_donghua.json", "res/image/homecity/frames/mySpine/yanwuchang_donghua.atlas", 1.0)
        _targSpine:setAnimation(0, "animation", true)
        _targSpine:setScale(0.82)
        extralY=90
    elseif params.buildingId == 2 then
        ----七星坛
        -- _targSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/qixingtan.json", "res/image/homecity/frames/spine/qixingtan.atlas", 1.0)
        -- _targSpine:setAnimation(0,"idle",true)

        _targSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/mySpine/qixingtan_donghua.json", "res/image/homecity/frames/mySpine/qixingtan_donghua.atlas", 1.0)
        _targSpine:setAnimation(0, "animation", true)
        _targSpine:setScale(0.82)
        extralY=20
    elseif params.buildingId == 3 then
        ----钱庄
        -- _targSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/ck.json", "res/image/homecity/frames/spine/ck.atlas", 1.0)
        -- _targSpine:setAnimation(0,"idle",true)

        _targSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/mySpine/shangcheng_donghua.json", "res/image/homecity/frames/mySpine/shangcheng_donghua.atlas", 1.0)
        _targSpine:setAnimation(0, "animation", true)
        _targSpine:setScale(0.9)
    elseif params.buildingId == 4 then
        ----万宝阁
        -- _targSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/wanbaoge.json", "res/image/homecity/frames/spine/wanbaoge.atlas", 1.0)
        -- _targSpine:setAnimation(0,"idle",true)

        _targSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/mySpine/wanbaoge_donghua.json", "res/image/homecity/frames/mySpine/wanbaoge_donghua.atlas", 1.0)
        _targSpine:setAnimation(0, "animation", true)
        extralY=30
    elseif params.buildingId == 5 then
        ----铁匠铺
        -- _targSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/tjp.json", "res/image/homecity/frames/spine/tjp.atlas", 1.0)
        -- _targSpine:setAnimation(0,"idle",true)

        _targSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/mySpine/tiejiangpu_donghua.json", "res/image/homecity/frames/mySpine/tiejiangpu_donghua.atlas", 1.0)
        _targSpine:setAnimation(0, "animation", true)
        -- _targSpine:setScale(0.9)
        extralY=20
    elseif params.buildingId == 6 then
        ----英雄榜
        -- _targSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/phb.json", "res/image/homecity/frames/spine/phb.atlas", 1.0)
        -- _targSpine:setAnimation(0,"idle",true)

        _targSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/mySpine/yingxiongbang_donghua.json", "res/image/homecity/frames/mySpine/yingxiongbang_donghua.atlas", 1.0)
        _targSpine:setAnimation(0, "animation", true)
    elseif params.buildingId == 8 then
        ----图鉴
        -- _targSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/tujian.json", "res/image/homecity/frames/spine/tujian.atlas", 1.0)
        -- _targSpine:setAnimation(0,"idle",true)

        _targSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/mySpine/tujian_donghua.json", "res/image/homecity/frames/mySpine/tujian_donghua.atlas", 1.0)
        _targSpine:setAnimation(0, "animation", true)
        _targSpine:setScale(0.82)
    elseif params.buildingId == 9 then
        ----种族战
        -- _targSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/zhenyingzhan.json", "res/image/homecity/frames/spine/zhenyingzhan.atlas", 1.0)
        -- _targSpine:setAnimation(0,"idle",true)

        _targSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/mySpine/zhenyingzhan_donghua.json", "res/image/homecity/frames/mySpine/zhenyingzhan_donghua.atlas", 1.0)
        _targSpine:setAnimation(0, "animation", true)
        _targSpine:setScale(0.92)
        extralY=20
    elseif params.buildingId == 10 then
        ----邮件
        -- _targSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/youxiang.json", "res/image/homecity/frames/spine/youxiang.atlas", 1.0)
        -- _targSpine:setAnimation(0,"idle",true)

        _targSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/mySpine/xinxiang_donghua.json", "res/image/homecity/frames/mySpine/xinxiang_donghua.atlas", 1.0)
        _targSpine:setAnimation(0, "animation", true)
        _targSpine:setScale(0.75)
    else
        local defaultParams = {
            normalFile = "res/image/homecity/building" .. params.buildingId .. ".png",
            selectedFile = "res/image/homecity/building" .. params.buildingId .. ".png",
            anchor = cc.p(0.5,0.5),
            -- 已经商定好   用(0.5, 0)作为锚点，建筑成形后记得修改
            needSwallow = false,
            needEnableWhenMoving = true
        }
        for k, v in pairs(defaultParams) do
            if params[k] == nil then
                params[k] = v
            end
        end
        button = XTHDPushButton:createWithParams(params)
        local size = button:getBoundingBox()
        button:setTouchSize(cc.size(size.width - 50, size.height - 50))
        _isSpine = false
    end

    if _isSpine and _targSpine then
        local _box = _targSpine:getBox()
        button:setContentSize(_box.width, _box.height)
        button:setTouchSize(cc.size(_box.width, _box.height - extralY))
        button:addChild(_targSpine)
        _targSpine:setTag(1024)
        _targSpine:setAnchorPoint(0.5, 0)
        _targSpine:setPosition(button:getContentSize().width / 2, 25)--添加25个像素向上位移
    end

    -- button:setContentSize(spineTargSize)
    -- if jianzhu then
    --     jianzhu:setScale(0.8)
    --     button:addChild(jianzhu)
    --     _targSpine:setTag(1024)
    --     if params.buildingId == 8 or params.buildingId == 10 then
    --         jianzhu:setPosition(button:getContentSize().width / 2,button:getContentSize().height / 2)

    --     else
    --         jianzhu:setPosition(button:getContentSize().width / 2,0)
    --     end
    -- end
    return button
end )

function BuildingItem1:ctor(params)
    self.Tag = {
        ktag_actionBuildClick = 511,
        ktag_actionTag = 512,
        ktag_particles1 = 513,
        ktag_particles2 = 514,
        ktag_resourceGold = 515,
        ktag_resourceJade = 516,
        ktag_nodeTag_levelUpStr = 2048,
        ktag_levelup_progressbar = 2049,
    }
    self._osTime = os.time()
    self._isSpine = true
    self._nameOffset = cc.p(0, 0)
    --- 建筑名字的偏移量
    self._speedOffset = cc.p(0, 0)
    ----建筑加速时的加速特效的偏移量
    self._speedUpEffect = nil

    self._buildLocalAllData = gameData.getDataFromCSV("LayoutOfBuilding", { buildingid = params.buildingId })
    ----当前建筑的所有等级的静态数据
    table.sort(self._buildLocalAllData, function(a, b)
        return tonumber(a.level) <(b.level)
    end )
    print("=================", params.buildingId)
    self._buildFunctionData = gameData.getDataFromCSV("FunctionInfoList", { buildingid = params.buildingId })
    -----当前建筑的功能数据
    local posTable = string.split(self._buildFunctionData.pos, '#')
    self:setPosition(tonumber(posTable[1]), tonumber(posTable[2]))

    self._buildLocalData = nil

    local defaultParams = {
        unlock = false,
        -- false 没解锁  true  解锁
        curLevel = 0,
        -- 当前等级
        levelUpState = 0,
        -- 0 没在升级中   非0  升级剩余时间
        speedUpState = 0,
        -- 0 没在加速中   非0  加速剩余时间
        curGold = 0,
        -- 当前产出的银两数
        curFeicui = 0,
        -- 当前产出的翡翠数
        collectCallback = nil,-- 收集资源的特效时使用
    }

    for k, v in pairs(defaultParams) do
        if params[k] == nil then
            params[k] = v
        end
    end
    if params.buildingId == 1 then
        -- 演武场
        self._nameOffset = cc.p( - 215, -70)
    elseif params.buildingId == 2 then
        ----七星坛
        self._nameOffset = cc.p(10, -100)
    elseif params.buildingId == 3 then
        -- 钱庄
        self._nameOffset = cc.p(-15, 15)
    elseif params.buildingId == 4 then
        ----万宝阁
        self._nameOffset = cc.p(5, -30)
    elseif params.buildingId == 5 then
        ----铁匠铺
        self._nameOffset = cc.p(- 210, 40)
    elseif params.buildingId == 6 then
        ----英雄榜
        self._nameOffset = cc.p(30 - 214, 25)
    elseif params.buildingId == 8 then
        ----图鉴
        self._nameOffset = cc.p(-210, -35)
    elseif params.buildingId == 9 then
        ----种族战
        self._nameOffset = cc.p(-10, -30)
    elseif params.buildingId == 10 then
        --- 邮件
        self._nameOffset = cc.p(-50, -135)
    end

    self:setCascadeOpacityEnabled(true)
    self:setCascadeColorEnabled(true)

    self:setId(params.buildingId)
    if params.noName == nil then
        self:addBuidName()
    end
    self:setUnlock(params.unlock)
    self:setCurLevel(params.curLevel)
    self:setCurGold(params.curGold)
    self:setCurFeicui(params.curFeicui)
    self:setLevelUpState(params.levelUpState)
    self:setSpeedUpState(params.speedUpState)
    self:setCanCollect(false)

    self:setIsSpeedUp(false)
    self:setIsLevelUp(false)
    self:setIsSelectedState(false)

    self:setCollectCallback(params.collectCallback)
    self:setOldPos()

    self:setTouchBeganCallback( function()
        self:setSelectedState(true)
        if params.beganCallback then
            params.beganCallback()
        end
    end )
    self:setTouchEndedCallback( function()
        self:setSelectedState(false)
        if params.endCallback then
            params.endCallback()
        end
    end )
end

function BuildingItem1:startCount()
    if self:getUnlock() == true and not self:getActionByTag(self.Tag.ktag_actionTag) then
        schedule(self, function()
            self:updateStates()
        end , 1.0, self.Tag.ktag_actionTag)
    end
end

function BuildingItem1:updateStates()
    -- 每1秒执行一次
    local canStop = false
    -- if self._speedUpState > 0 then ----在加速中
    --     self._speedUpState = self._speedUpState - 1
    --     if self._speedUpState <= 0 then
    --         self:removeSpeedUpEffect()
    --         canStop = true
    --     end
    -- end
    if self._levelUpState > 0 then
        -- 在升级中
        self._levelUpState = self._levelUpState - 1
        self:updateLevelupProgress()
        if self._levelUpState <= 0 and self._isLevelUp then
            self:setCurLevel(self._level + 1)
            self._isLevelUp = false
            self:removeProgressBar()
            local param = mUserDataMgr:getTheSpecifiedBuildingsData(self:getId(), self:getCurLevel())
            if param and next(param) ~= nil then
                local str = LANGUAGE_MAINCITY_CITYUPTIPS1(param.localData.buildingname, self:getCurLevel())
                XTHDTOAST(str)
            end
            canStop = true
        end
    else
        canStop = true
    end
    self._osTime = os.time()
    if canStop then
        self:stopActionByTag(self.Tag.ktag_actionTag)
    end
end

function BuildingItem1:setOldScale()
    if self:getId() == 3 then
        self._oldScale = 0.8
    else
        self._oldScale = self:getScale()
    end
end

function BuildingItem1:getOldScale()
    return self._oldScale or 1
end

function BuildingItem1:setOldPos()
    self._oldPos = cc.p(self:getPositionX(), self:getPositionY())
end

function BuildingItem1:getOldPos()
    return self._oldPos or cc.p(0, 0)
end

-- 设置是否在选中状态
function BuildingItem1:setSelectedState(selectedState)
    if selectedState == true then
        if self._isSpine then
            if self:getChildByTag(1024) and self._buildingId ~= 10 then
                ----除去邮箱
                self:getChildByTag(1024):setAnimation(0, "atk", true)
            end
            local action = cc.Spawn:create(cc.MoveTo:create(0.08, cc.pAdd(self:getOldPos(), cc.p(0, 15))), cc.ScaleTo:create(0.08, self:getOldScale() * 1.1))
            local actionReverse = cc.Spawn:create(cc.MoveTo:create(0.08, self:getOldPos()), cc.ScaleTo:create(0.08, self:getOldScale()))
            action = cc.Sequence:create(action, actionReverse)
            action:setTag(self.Tag.ktag_actionBuildClick)
            self:runAction(action)
        end
    else
        if self._isSpine then
            -- -
            if self:getChildByTag(1024) then
                self:getChildByTag(1024):setAnimation(0, "idle", true)
            end
            self:stopActionByTag(self.Tag.ktag_actionBuildClick)
            self:setPosition(self:getOldPos())
            self:setScale(1.0)
        end
    end
    self:setIsSelectedState(selectedState)
end

-- 设置是否可以收集资源
function BuildingItem1:setCanCollect(canCollect)
    self._canCollect = canCollect
end

function BuildingItem1:isCanCollect()
    return self._canCollect == nil and false or self._canCollect
end

-- 取得升级进度条
function BuildingItem1:getProgressBar()
    -- 钱庄取消升级动画
    if (self:getId() == 3) then
        return
    end
    if self:getLevelUpState() > 0 then
        -- 创建进度条
        self._gray_bg = cc.Sprite:create("res/image/homecity/building_progess_bg.png")
        -- res/image/building/progress_bg.png
        local _parent = self:getSpineNodeByName("hpBarPoint")
        if _parent then
            _parent:addChild(self._gray_bg)
        else
            self:addChild(self._gray_bg)
            self._gray_bg:setAnchorPoint(cc.p(0.5, 0))
            self._gray_bg:setPosition(self:getBoundingBox().width / 2, self:getBoundingBox().height - 50)
        end
        -- ly3.15
        self._gray_bg:setScale(0.8)

        local exp_progress_timer = cc.ProgressTimer:create(cc.Sprite:create("res/image/homecity/building_progress.png"))
        --  res/image/building/progress_bar.png
        exp_progress_timer:setName("progress_timer")
        exp_progress_timer:setPosition(self._gray_bg:getContentSize().width / 2, self._gray_bg:getContentSize().height / 2 + 1)
        exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR);
        exp_progress_timer:setMidpoint(cc.p(0, 0.5));
        local percentage = 10 / 6 * tonumber(self:getLevelUpState()) / self:getUpgradeNeedTime()
        exp_progress_timer:setPercentage(100 - percentage)
        exp_progress_timer:setBarChangeRate(cc.p(1, 0))
        self._gray_bg:addChild(exp_progress_timer, 1, self.Tag.ktag_levelup_progressbar)

        local ratio = cc.Label:createWithBMFont("res/fonts/baisezi.fnt", 1)
        ratio:setScale(0.8)
        ratio:setPosition(self._gray_bg:getContentSize().width / 2, 0)
        ratio:setString(getCdStringWithNumber(self:getLevelUpState(), { m = LANGUAGE_UNKNOWN.minute, s = LANGUAGE_UNKNOWN.second }, false, true))
        self._gray_bg:addChild(ratio, 1, self.Tag.ktag_nodeTag_levelUpStr)
        -- 升级的特效
        -- local _upSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/spine/sjjd.json", "res/image/homecity/frames/spine/sjjd.atlas", 1.0)
        local _upSpine = sp.SkeletonAnimation:create("res/image/homecity/frames/spine/shengjizhong.json", "res/image/homecity/frames/spine/shengjizhong.atlas", 1.0)
        if _upSpine then
            self._gray_bg:addChild(_upSpine, 2)
            -- ly3.15
            _upSpine:setPosition(self._gray_bg:getContentSize().width / 2 - 50, self._gray_bg:getContentSize().height + 10)
            -- _upSpine:setAnimation(0,"sj",true)
            _upSpine:setAnimation(0, "shengjizhong", true)
        end
        self:setIsLevelUp(true)
    end
end
--------更新建筑升级上的进度条与倒计时
function BuildingItem1:updateLevelupProgress()
    if self._gray_bg then
        local target = self._gray_bg:getChildByTag(self.Tag.ktag_levelup_progressbar)
        if target then
            local percentage = 10 / 6 * tonumber(self._levelUpState) / self:getUpgradeNeedTime()
            target:setPercentage(100 - percentage)
        end
        target = self._gray_bg:getChildByTag(self.Tag.ktag_nodeTag_levelUpStr)
        if target then
            target:setString(getCdStringWithNumber(self._levelUpState, { m = LANGUAGE_UNKNOWN.minute, s = LANGUAGE_UNKNOWN.second }, false, true))
        end
    end
end
--- 移掉升级进度条 noEffect 没有升级特效
function BuildingItem1:removeProgressBar(noEffect)
    if self._gray_bg then
        self._gray_bg:removeFromParent()
        self._gray_bg = nil
        if self._time then
            self._time = 0
        end
    end
    if self:isLevelUp() then
        self:setIsLevelUp(false)
    end
    ----升级完之后播放特效
    if not noEffect then
        local _effect = sp.SkeletonAnimation:create("res/image/homecity/frames/spine/jzjs.json", "res/image/homecity/frames/spine/jzjs.atlas", 1.0)
        if _effect then
            self:addChild(_effect)
            _effect:setPosition(self:getBoundingBox().width / 2, self:getBoundingBox().height / 2)
            _effect:setAnimation(0, "sj", false)
            performWithDelay(self, function()
                if _effect then
                    _effect:removeFromParent()
                end
            end , 2.0)
        end
    end
end

-- 取得银两或者翡翠可领取标志()
function BuildingItem1:getCollectMark()
    local limit = math.pow(self:getCurLevel(), 2) * 10
    if self:getLevelUpState() <= 0 and self:isCanCollect() == false and self:isSelectedState() == false and(self:getCurGold() >= limit or self:getCurFeicui() >= limit) then
        -- if self:getLevelUpState() <= 0 and self:isCanCollect() == false and self:isSelectedState() == false then
        if not self._collectMark then
            self._collectMark = XTHDImage:create()
            self._collectMark:setContentSize(cc.size(80, 80))
            self._collectMark:setTouchSize(cc.size(80, 80))
			self._collectMark:setAnchorPoint(0.5,0)
            self._collectMark:setTouchEndedCallback( function()
                self:removeCollectMark()
            end )
            local _targNode = self:getSpineNodeByName("hpBarPoint")
            if _targNode then
                _targNode:addChild(self._collectMark)
            else
                self:addChild(self._collectMark)
            end

            -- local goldMark = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/jinfeicui.json", "res/image/homecity/frames/spine/jinfeicui.atlas", 1.0);
            -- 翡翠
            local goldMark = sp.SkeletonAnimation:create("res/image/homecity/frames/spine/baoshi.json", "res/image/homecity/frames/spine/baoshi.atlas", 1.0);
            -- 银两
            local yinlinag = sp.SkeletonAnimation:create("res/image/homecity/frames/spine/qianbi.json", "res/image/homecity/frames/spine/qianbi.atlas", 1.0);

            local goldRate = self:getGoldProduceRate()
            local jadeRate = self:getEmeraldProduceRate()
            if goldRate > 0 and jadeRate <= 0 then
                --- 掉银两
                yinlinag:setAnimation(0, "qianbi", true)
            elseif jadeRate > 0 and goldRate <= 0 then
                --- 掉翡翠
                goldMark:setAnimation(0, "baoshi", true)
            elseif jadeRate > 0 and goldRate > 0 then
                --- 两个都掉
                goldMark:setAnimation(0, "baoshi", true)
                yinlinag:setAnimation(0, "qianbi", true)
            end

            if goldMark then
                -- 钱庄上面的掉翡翠掉银两
                self._collectMark:addChild(goldMark)
                goldMark:setPosition(self._collectMark:getContentSize().width / 2 - 5 + 72, self._collectMark:getContentSize().height / 2 - 40 + 82 - 99)
                goldMark:setOpacity(0)
                goldMark:runAction(cc.FadeIn:create(0.5))
            end
            if yinlinag then
                -- 钱庄上面的掉翡翠掉银两
                self._collectMark:addChild(yinlinag)
                yinlinag:setPosition(self._collectMark:getContentSize().width / 2 + 35 + 72, self._collectMark:getContentSize().height / 2 - 40 + 82 - 99)
                yinlinag:setOpacity(0)
                yinlinag:runAction(cc.FadeIn:create(0.5))
            end


            self:setCanCollect(true)
        end
        return self._collectMark
    end
end

-- 领取银两或者翡翠
function BuildingItem1:removeCollectMark()
    if self._collectMark then
        -- 飞银两系列效果
        local gold = 0
        local feicui = 0
        local data = self._buildLocalData
        if data and data.producegold10s and data.produceemerald10s then
            data = mUserDataMgr:getCityDataByID(self:getId())
            if data and data.gold and data.feicui then
                gold = data.gold
                feicui = data.feicui
                self:getCollectCallback()( {
                    id = self:getId(),
                    addG = gold,
                    addJ = feicui
                } )
            end
        end
        local function moveActions(targ)
            if targ then
                targ:runAction(cc.Sequence:create(
                cc.Spawn:create(cc.ScaleTo:create(0.2, 0.8), cc.FadeIn:create(0.5)),
                cc.MoveBy:create(0.8, cc.p(0, 50)),
                cc.FadeOut:create(0.5),
                cc.CallFunc:create( function()
                    targ:removeFromParent()
                end )
                ))
            end
        end

        local labels = { }
        for i = 1, 2 do
            local rewardLabel = nil
            local icon = nil
            if i == 1 and tonumber(gold) > 0 then
                icon = cc.Sprite:create("res/image/common/header_gold.png")
                icon:setScale(0.5)
                self:addChild(icon, 2, self.Tag.ktag_resourceGold)
                rewardLabel = cc.Label:createWithBMFont("res/fonts/jinbizengjia.fnt", "+" .. gold)
                rewardLabel:setAnchorPoint(0, 0.5)
                rewardLabel:setScale(0.625)
                local x =(self:getBoundingBox().width -(icon:getBoundingBox().width + rewardLabel:getBoundingBox().width)) / 2
                icon:setPosition(x, self:getBoundingBox().height - 100)
                -----------------银两数量
                rewardLabel:setPosition(icon:getBoundingBox().width + 15, icon:getBoundingBox().height / 2 + 12)
            elseif i == 2 and tonumber(feicui) > 0 then
                icon = cc.Sprite:create("res/image/common/header_feicui.png")
                icon:setScale(0.8)
                self:addChild(icon, 2, self.Tag.ktag_resourceJade)
                rewardLabel = cc.Label:createWithBMFont("res/fonts/jiaxue.fnt", "+" .. feicui)
                rewardLabel:setAnchorPoint(0, 0.5)
                rewardLabel:setScale(0.625)
                local x =(self:getBoundingBox().width -(icon:getBoundingBox().width + rewardLabel:getBoundingBox().width)) / 2
                icon:setPosition(x, self:getBoundingBox().height - 100)
                -----------------翡翠数量
                rewardLabel:setPosition(icon:getBoundingBox().width + 8, icon:getBoundingBox().height / 2 + 5)
            end
            if icon then
                icon:setCascadeOpacityEnabled(true)
                icon:addChild(rewardLabel, 2)

                labels[i] = icon
                icon:setOpacity(0)
            end
        end
        self._collectMark:runAction(cc.Sequence:create(cc.FadeOut:create(0.05), cc.CallFunc:create( function()
            self._collectMark:removeFromParent()
            self._collectMark = nil
            local i = 1
            for k, v in pairs(labels) do
                if i == 1 then
                    moveActions(v)
                else
                    performWithDelay(v, function()
                        moveActions(v)
                    end , 0.1)
                end
                i = i + 1
            end
        end )))

        local pos = cc.p(self:getCollectMarkPos())
        local addG = tonumber(gold)
        local addJ = tonumber(feicui)

        local function runAni()
            local emitter1 = sp.SkeletonAnimation:create("res/image/homecity/frames/luobaoshi.json", "res/image/homecity/frames/luobaoshi.atlas", 1.0)
            local emitter2 = sp.SkeletonAnimation:create("res/image/homecity/frames/luojinbi.json", "res/image/homecity/frames/luojinbi.atlas", 1.0)
            if addG > 0 and addJ > 0 then
                musicManager.playEffect("res/sound/collect_both.mp3")
                -- emitter1 = cc.ParticleSystemQuad:create("res/image/homecity/frames/diaofeicui.plist")
                -- emitter2 = cc.ParticleSystemQuad:create("res/image/homecity/frames/diaojinbi.plist")
                emitter1:setAnimation(0, "luobaoshi", false)
                emitter2:setAnimation(0, "luojinbi", false)
            elseif addG > 0 then
                musicManager.playEffect("res/sound/collect_gold.mp3")
                -- emitter2 = cc.ParticleSystemQuad:create("res/image/homecity/frames/diaojinbi.plist")
                emitter2:setAnimation(0, "luojinbi", false)
            elseif addJ > 0 then
                musicManager.playEffect("res/sound/collect_jedct.mp3")
                -- emitter1 = cc.ParticleSystemQuad:create("res/image/homecity/frames/diaofeicui.plist")
                emitter1:setAnimation(0, "luobaoshi", false)
            end

            local target = self:getSpineNodeByName("hpBarPoint")
            target = target or self
            if emitter1 then
                -- emitter1:setPositionType(cc.POSITION_TYPE_RELATIVE)
                -- emitter1:setAutoRemoveOnFinish(true)
                target:addChild(emitter1)
                emitter1:setTag(self.Tag.ktag_particles1)
                -- emitter1:setPosition(pos)
                -- 修改位置之后的掉翡翠掉银两
                emitter1:setPosition(self._collectMark:getContentSize().width / 2, self._collectMark:getContentSize().height / 2 - 20)
            end
            if emitter2 then
                -- emitter2:setPositionType(cc.POSITION_TYPE_RELATIVE)
                -- emitter2:setAutoRemoveOnFinish(true)
                target:addChild(emitter2)
                -- emitter2:setPosition(pos)
                -- 修改位置之后的掉翡翠掉银两
                emitter2:setPosition(self._collectMark:getContentSize().width / 2, self._collectMark:getContentSize().height / 2 - 20)
                emitter2:setTag(self.Tag.ktag_particles2)
            end
        end
        runAni()

        self:setCanCollect(false)
        self:setCurGold(0)
        self:setCurFeicui(0)
        -- 领取资源
        XTHDHttp:requestAsyncInGameWithParams( {
            modules = "getResouce?",
            params = { buildId = self:getId() },
            successCallback = function(data)
                if tonumber(data.result) == 0 then
                    gameUser.setGold(data.curGold)
                    gameUser.setFeicui(data.curFeicui)
                    gameUser.setPreGold(data.curGold)
                    gameUser.setPreFeicui(data.curFeicui)
                    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
                else
                    XTHDTOAST(data.msg)
                end
            end,
            -- 成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
                -------"网络请求失败")
            end,
            -- 失败回调
            targetNeedsToRetain = self,
            -- 需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.NONE,-- 加载图显示 circle 光圈加载 head 头像加载
        } )
    end
end

function BuildingItem1:getCollectMarkPos()
    if self._collectMark then
        return self._collectMark:getPosition()
    else
        return cc.p(0, 0)
    end
end
-- 收集资源的响应函数
function BuildingItem1:setCollectCallback(collectCallFunc)
    self._collectCallback = collectCallFunc
end

function BuildingItem1:getCollectCallback()
    return self._collectCallback or nil
end

-- 判定是否在升级
function BuildingItem1:setIsLevelUp(isLevelUp)
    self._isLevelUp = isLevelUp
end

function BuildingItem1:isLevelUp()
    return self._isLevelUp == nil and false or self._isLevelUp
end
-- 判定是否在加速
function BuildingItem1:setIsSpeedUp(isSpeedUp)
    self._isSpeedUp = isSpeedUp
end

function BuildingItem1:isSpeedUp()
    return self._isSpeedUp == nil and false or self._isSpeedUp
end
-- 判定是否在选中状态
function BuildingItem1:setIsSelectedState(isSelectedState)
    self._isSelectedState = isSelectedState
end

function BuildingItem1:isSelectedState()
    return self._isSelectedState == nil and false or self._isSelectedState
end

-- 加速特效
function BuildingItem1:getSpeedUpEffect()
    if self:getSpeedUpState() > 0 then
        ----加速特效
        local _speedUpEffect = sp.SkeletonAnimation:create("res/image/homecity/frames/spine/sjjd.json", "res/image/homecity/frames/spine/sjjd.atlas", 1.0)
        if _speedUpEffect then
            local _parent = self:getSpineNodeByName("js")
            if _parent then
                _parent:addChild(_speedUpEffect)
            else
                self:addChild(_speedUpEffect)
                local x = self:getBoundingBox().width * 2 / 3
                local y = 0
                if self._speedOffset then
                    x = x + self._speedOffset.x
                    y = y + self._speedOffset.y
                end
                _speedUpEffect:setPosition(x, y)
            end
            _speedUpEffect:setAnimation(0, "js", true)
        end
        ------光效
        local _lightEffect = sp.SkeletonAnimation:create("res/image/homecity/frames/spine/jzjs.json", "res/image/homecity/frames/spine/jzjs.atlas", 1.0)
        if _lightEffect then
            self:addChild(_lightEffect)
            _lightEffect:setPosition(self:getBoundingBox().width / 2, self:getBoundingBox().height / 2)
            _lightEffect:setAnimation(0, "js", false)
        end
        performWithDelay(self, function()
            _lightEffect:removeFromParent()
            _lightEffect = nil
        end , 2.0)

        self._speedUpEffect = _speedUpEffect

        self:setIsSpeedUp(true)
    end
end

function BuildingItem1:removeSpeedUpEffect()
    if self._speedUpEffect then
        self._speedUpEffect:removeFromParent()
        self._speedUpEffect = nil
        self:setIsSpeedUp(false)
    end
end 

-- set get 银两的产出速率
function BuildingItem1:getGoldProduceRate()
    return self._buildLocalData.producegold10s or 0
end

-- set get 银两的最大存储量
function BuildingItem1:getGoldMaxStore()
    return self._buildLocalData.goldstoremax or 0
end

-- set get 翡翠的产出速率
function BuildingItem1:getEmeraldProduceRate()
    return self._buildLocalData.produceemerald10s or 0
end

-- set get 翡翠的最大存储量
function BuildingItem1:getEmeraldMaxStore()
    return self._buildLocalData.emeraldstoremax or 0
end

-- set get 银两和翡翠加速产出时的加速倍数
function BuildingItem1:getSpeedRatio()
    return self._buildLocalData.basicratio or 0
end

-- set get 升级需要消耗的时间(表里的时间单位为分钟)
function BuildingItem1:getUpgradeNeedTime()
    return self._buildLocalData.upgradelimittime or 10000
    -- 容错：别返回0去作为除数 返回稍大一点的数吧
end

-- set get 建筑ID
function BuildingItem1:setId(id)
    self._buildingId = id
end

function BuildingItem1:getId()
    return self._buildingId or 0
end
-- set get 建筑是否为解锁状态
function BuildingItem1:setUnlock(unlockState)
    self._unlock = unlockState
    if unlockState and unlockState == true then
        --- 如果当前建筑是刚刚被开启
        if self:getCurLevel() < 1 then
            self:setCurLevel(1)
        end
    end
end

function BuildingItem1:getUnlock()
    return self._unlock == nil and false or self._unlock
end
-- set get 建筑当前等级
function BuildingItem1:setCurLevel(curLevel)
    self._level = curLevel
    -- 每次等级变化后 建筑的一些数据属性要发生变化
    self:refreshLocalData()
    if self._levelLabel then
        self._levelLabel:setString(curLevel)
    end
    if self._buildNameBox and curLevel > 0 then
        XTHD.setGray(self._buildNameBox, false)
    end
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_BUILDINFO_AFTERLEVELUP })
end

function BuildingItem1:getCurLevel()
    return self._level or 0
end
-- set get 建筑当前产出的银两数
function BuildingItem1:setCurGold(curGold)
    self._gold = curGold
end

function BuildingItem1:getCurGold()
    return self._gold or 0
end
-- set get 建筑当前产出的翡翠数
function BuildingItem1:setCurFeicui(curFeicui)
    self._feicui = curFeicui
end

function BuildingItem1:getCurFeicui()
    return self._feicui or 0
end
-- set get 建筑完成升级的剩余时间
function BuildingItem1:setLevelUpState(levelUpState)
    self._levelUpState = levelUpState
end

function BuildingItem1:getLevelUpState()
    return self._levelUpState or 0
end
-- set get 建筑完成加速的剩余时间
function BuildingItem1:setSpeedUpState(speedUpState)
    self._speedUpState = speedUpState
end

function BuildingItem1:getSpeedUpState()
    return self._speedUpState or 0
end

function BuildingItem1:setProperties(data)
    if self._level ~= data.level and data.upEndTime <= 0 then
        -----已升级完成
        self:stopActionByTag(self.Tag.ktag_actionTag)
        self._isLevelUp = false
        self:removeProgressBar()
        local param = mUserDataMgr:getTheSpecifiedBuildingsData(self:getId(), self:getCurLevel() + 1)
        if param and next(param) ~= nil then
            local str = LANGUAGE_MAINCITY_CITYUPTIPS1(param.localData.buildingname, self:getCurLevel() + 1)
            XTHDTOAST(str)
        end
    end
    self:setSpeedUpState(data.addSpeedEndTime)
    self:setCurLevel(data.level)
    self:setLevelUpState(data.upEndTime)
    self:setCurGold(data.gold)
    self:setCurFeicui(data.feicui)

    self:startCount()
    self:getCollectMark()
end

function BuildingItem1:refreshLocalData()
    self._buildLocalData = self._buildLocalAllData[self._level]
end

function BuildingItem1:getLocalData()
    return self._buildLocalData
end

function BuildingItem1:addBuidName()
    -- 名字
    local _name = cc.Sprite:create("res/image/building/build_name" .. self:getId() .. ".png")
    _name:setScale(0.8)
    XTHD.setGray(_name, true)
    _name:setAnchorPoint(0.5, 1)
    local size=self:getContentSize()
    local x = size.width + _name:getBoundingBox().width / 2
    local y = size.height
    if self._nameOffset then
        x = x + self._nameOffset.x
        y = y + self._nameOffset.y
    end
    _name:setPosition(x, y)
    self._buildNameBox = _name
    self:addChild(_name)

    --- 小红点
    local _redDot = cc.Sprite:create("res/image/common/heroList_redPoint.png")
    self:addChild(_redDot)
    _redDot:setPosition(_name:getPositionX() + _name:getBoundingBox().width / 2 + 2, _name:getPositionY() - _redDot:getContentSize().height / 2 + 5)
    _redDot:setVisible(false)
    self._redDot = _redDot

    -- local _nameBox = cc.Sprite:create("res/image/building/building_name_bg.png")
    -- if self._buildingId ~= 3 then -----钱庄
    --     _nameBox = cc.Sprite:create("res/image/building/building_name_bg2.png")
    -- end
    -- XTHD.setGray(_nameBox,true)
    -- self:addChild(_nameBox)
    -- _nameBox:setAnchorPoint(0.5,1)
    -- local x = self:getBoundingBox().width + _nameBox:getBoundingBox().width / 2
    -- local y = self:getBoundingBox().height
    -- if self._nameOffset then
    --     x = x + self._nameOffset.x
    --     y = y + self._nameOffset.y
    -- end
    -- _nameBox:setPosition(x,y)
    -- self._buildNameBox = _nameBox
    -- --名字
    -- local _name = cc.Sprite:create("res/image/building/build_name"..self:getId()..".png")
    -- _nameBox:addChild(_name)


    -- _name:setPosition(_nameBox:getBoundingBox().width / 2,_nameBox:getBoundingBox().height / 2 - 5)


    -- ---等级
    -- if self._buildingId == 3 then ---钱庄
    --     local _level = cc.Label:createWithBMFont("res/fonts/item_num.fnt",0)
    --     _nameBox:addChild(_level)
    --     _level:setScale(0.7)
    --     _level:setPosition(_nameBox:getContentSize().width / 2,_nameBox:getContentSize().height - _level:getContentSize().height / 2)
    --     self._levelLabel = _level
    -- end
    -- ---小红点
    -- local _redDot = cc.Sprite:create("res/image/common/heroList_redPoint.png")
    -- self:addChild(_redDot)
    -- _redDot:setPosition(_nameBox:getPositionX() + _nameBox:getBoundingBox().width / 2 + 2,_nameBox:getPositionY() - _redDot:getContentSize().height / 2 + 5)
    -- _redDot:setVisible(false)
    -- self._redDot = _redDot
end

function BuildingItem1:create(params)
    local pBuilding = self.new(params)
    return pBuilding
end

function BuildingItem1:getSpineNodeByName(slotName)
    if self._isSpine and slotName then
        local targSpine = self:getChildByTag(1024)
        if targSpine then
            return targSpine:getNodeForSlot(slotName)
        else
            return nil
        end
    else
        return nil
    end
end
-----更新建筑的加速和升级的倒计时
function BuildingItem1:refreshSpeedAndLevelState()
    self._levelUpState = self:getLevelUpState() -(os.time() - self._osTime)
    self._speedUpState = self:getSpeedUpState() -(os.time() - self._osTime)
    self._osTime = os.time()
    ----升级
    if self._levelUpState <= 0 then
        ----升级已经时间已经完了
        if self._isLevelUp then
            self:setCurLevel(self:getCurLevel() + 1)
        end
        self:removeProgressBar(true)
    else
        ----升级的时间还没有完
        if self._gray_bg and self._gray_bg:getChildByTag(self.Tag.ktag_nodeTag_levelUpStr) then
            -----更新建筑升级时上面进度条上的计时
            local target = self._gray_bg:getChildByTag(self.Tag.ktag_nodeTag_levelUpStr)
            target:setString(getCdStringWithNumber(self._levelUpState, { m = LANGUAGE_UNKNOWN.minute, s = LANGUAGE_UNKNOWN.second }, false, true))
        end
        if not self:getActionByTag(self.Tag.ktag_actionTag) then
            self:startCount()
        end
    end
    ----加速
    if self._speedUpState <= 0 then
        self:removeSpeedUpEffect()
    end
end
----当前建筑是否可以开启
function BuildingItem1:canOpen()
    local result = false
    local funcData = self._buildFunctionData
    if funcData then
        if funcData.unlocktype == 1 then
            --- 按等级开启
            if gameUser.getLevel() >= funcData.unlockparam then
                result = true
            end
        elseif funcData.unlocktype == 2 then
            ----按关卡开启
            if gameUser.getInstancingId() >= funcData.unlockparam then
                result = true
            end
        end
    end
    return result
end
----当前建筑是否可升级
function BuildingItem1:canLevelUp()
    local _data = self._buildLocalData
    if not _data or not _data.upgradelimitlevel then
        return false
    end
    local curLevel = gameUser.getLevel()
    local gold = gameUser.getGold()
    local jade = gameUser.getFeicui()
    if _data.upgradelimitlevel == 0 then
        return false
    elseif curLevel >= _data.upgradelimitlevel and gold >= _data.upgradegoldcost and jade >= _data.upgradeemeraldcost then
        return true
    end
end

function BuildingItem1:removeParticles()
    local target = self:getSpineNodeByName("hpBarPoint")
    target = target or self
    if target then
        if target:getChildByTag(self.Tag.ktag_particles1) then
            target:removeChildByTag(self.Tag.ktag_particles1)
        end
        if target:getChildByTag(self.Tag.ktag_particles2) then
            target:removeChildByTag(self.Tag.ktag_particles2)
        end
    end
    if self:getChildByTag(self.Tag.ktag_resourceGold) then
        self:removeChildByTag(self.Tag.ktag_resourceGold)
    end
    if self:getChildByTag(self.Tag.ktag_resourceJade) then
        self:removeChildByTag(self.Tag.ktag_resourceJade)
    end
end

function BuildingItem1:playSpines(isIdle)
    if self:getChildByTag(1024) then
        if isIdle then
            self:getChildByTag(1024):setAnimation(0, "idle", true)
        else
            self:getChildByTag(1024):setAnimation(0, "atk", true)
        end
    end
end