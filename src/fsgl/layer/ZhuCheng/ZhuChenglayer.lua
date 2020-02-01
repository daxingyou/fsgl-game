--yanyuling 20150120
------added by LITAO 2015.5.8------
requires("src/fsgl/layer/LiaoTian/LiaoTianRoomLayer.lua")
requires("src/fsgl/layer/ZhuCheng/ZiYuanZhaoHuiLayer.lua")
requires("src/fsgl/layer/JiBan/JiBanLayer.lua")
------added by LITAO ended------
requires("src/fsgl/manager/RedPointManage.lua") -- xingchen20150625
------
local  ZhuChenglayer  = class( "ZhuChenglayer", function ( ... )
    return XTHDDialog:create();
end)

local operatorBtns = nil   --底部buton对象
local mGameData = gameData
local mGameUser = gameUser

function ZhuChenglayer:create(mark) 
    local layer = self.new(mark)
    if layer then 
        layer:setSwallowTouches(false)
    end 
    return layer
end

function ZhuChenglayer:ctor(mark)
    -- self._externalMark = mark ------开篇进来的标识 
    self._currentBattle = 0

    XTHD.setVIPExist(false)
    XTHD.setVIPRewardExist(false)
    mGameData = gameData
    mGameUser = gameUser
    self._extraFuncID = 0 ------在新功能开启的时候，如进竞技场之后还需要指到的功能ID
    self.__addGold = 0
    self.__addJade = 0
    self._clickedBuilding = true
    self._buildingsTable = {} --主城建筑表
    self._propertyLable = {} ---顶上的，玩家的财产（体力、银两、翡翠、元宝）
    self._animateFrames = {fire = {},newGold = {},fightBtnA = {},fightBtnB = {},bird = {}} ---动画效果
    self._buildingAmountOfVIP = gameData.getDataFromCSV("VipInfo",{id = 23}) ----建筑升级数量与VIp的关系表
    self._curBuildingId = nil   
    self._clound = {}

    self._targetCityData = nil
    self._targetCity = nil
    self._speedCost = 0
    self._allSpeedCost = 0

    self._isNewFunctionGuide = false -----是否是新功能开启

    self._buildLevelUpVIP = 0 ----建筑升级立刻完成需要的VIP等级
    self._buildSpeedUpVIP = 0 -----建筑加速需要的VIP等级    
    self._buildSpeedUpVIP,self._buildLevelUpVIP = self:getBuildAboutVIP() -----获取建筑加速、升级的VIP等级

    self.Tag = {
        ktag_actionFightA = 512,
        ktag_actionFightB = 513,
        ktag_nodeOfLeftFire = 514,
        ktag_nodeOfRightFire = 515,
        ktag_nodeOfChatroom = 516,
        ktag_particleGold = 517,
        ktag_particleFeicui = 518,
        ktag_nodeOfBird = 519,
        ktag_actionFightB = 520,
        ktag_actionCircle = 521,
        ktag_firstColorLayer = 522,
    }    
    --for xuefu 我把主城的数据请求请求放在了Login里面，然后存到了UserDataMgr 中，如果你有什么需求没能满足且不确定怎么改，再联系我吧，yanyuling
    self._builds = UserDataMgr:getMainCityData().builds

    XTHD.addEventListenerWithNode({name = CUSTOM_EVENT.REFRESH_FUNCTION_REDPOINT,node = self,callback = function()
        self:reFreshFunctionRedPoint()
    end})
    self:registerNotifications()  ----注册小红点显示消息  
    self:initUI()
    RedPointManage:create() ----英雄小红点 

    local node = cc.Director:getInstance():getNotificationNode() 
    local announce = node:getChildByName("announcement")         
    if announce then 
        announce:run()
    end
    gameUser._isInGame = true ----表示玩家进入游戏

    musicManager.setBackMusic(XTHD.resource.music.music_bgm_main)
    musicManager.switchBackMusic()


    -- YinDaoMarg:getInstance():updateServer({group = 10,index = 1,isGuideOver = false})
end

function ZhuChenglayer:onEnter()  
    -------是否有限时战开启
    local _battleID = gameUser.getLimitBattle()
    for k,v in pairs(_battleID) do 
        if v > 0 then 
            if k == 1 and not self._haveInitSelf then----世界Boss
                XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_BATTLE_TIPSLAYER,data = "boss"})
            elseif k == 4 and not self._haveInitSelf then ----种族战
                XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_BATTLE_TIPSLAYER,data = "campstart"})
            else 
                self._menuLayer:switchFromNewGoalAndBattle(true,k)        
            end  
        end    
    end  
   
    ---------------------------------------------------------------------
    
    -----建筑加速、升级倒计时调整
    if self._buildingsTable and next(self._buildingsTable) ~= nil then 
        for k,v in pairs(self._buildingsTable) do             
            local data = UserDataMgr._buildData[v:getId()]
            if data then 
                v:setProperties(data)
                UserDataMgr:popBuildingData(v:getId())
            end 
            v:refreshSpeedAndLevelState()            
        end 
    end 
    self._menuLayer:createNewTargetTip()----
    ---------------
    self:refreshBaseInfo()    
    --英雄红点
    RedPointManage:startSetRedpoint()
    self:reFreshFunctionRedPoint() 
    if HaoYouPublic.haveNews() then
        self:freshNewsBtn({data = {name = "newsMsg", visible = true}})
    end
    --世界boss弹窗
    if gameUser._worldBossOver==1 then
        local reward_pop=requires("src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiHatredPop.lua"):create()
        reward_pop:show()
        self:addChild(reward_pop)
        reward_pop:setName("_worldBossLayer")
        gameUser._worldBossOver=0
    end
    -- local _isFirstEnter = false
    -- if self._externalMark and self._externalMark.guide == true then ----第一次进来游戏 
    --     self:first2MainCity()
    --     self._externalMark.guide = false
    --     _isFirstEnter = true
    -- end 
    -----引导
    self:addGuide()
    ------------------------------------------
    if not self._haveInitSelf then
        self._haveInitSelf = true
        local textureCache = cc.Director:getInstance():getTextureCache()
        textureCache:removeTextureForKey("res/image/login/login_bg.png")
        textureCache:removeTextureForKey("res/image/login/yun.png")
        textureCache:removeTextureForKey("res/image/login/selectServer_bg.png")
        textureCache:removeTextureForKey("res/image/login/login_tip_bg.png")
        textureCache:removeTextureForKey("res/image/login/game_name.png")
        -- textureCache:removeTextureForKey("res/image/login/yinno.plist")

        local _layer1,_layer2 = YinDaoMarg:getInstance():getCurrentGuideLayer()
        if not _layer1 and not _layer2 and _isFirstEnter == false then
            local activityOpenStatus = gameUser.getActivityOpenStatus() or {}
            if activityOpenStatus["11"] and tonumber(activityOpenStatus["11"])==1 then
                XTHD.timeHeroListCallback(self,1,true)    
            end
            
        end
    end
    -- self:first2MainCity()
    -- self:test()
end

function ZhuChenglayer:onExit()
    ------当建筑上有粒子效果时，移掉
    if self._buildingsTable and next(self._buildingsTable) ~= nil then 
        for k,v in pairs(self._buildingsTable) do  
            v:removeParticles()
        end 
    end 
    
    self._menuLayer._pushSceneCount = 0
    self:cleanOperatorBtns()
    self:stopAction(self._tipsAction)

    if self._buildPointer then 
        self._buildPointer:removeFromParent()
        self._buildPointer = nil
        self._extraFuncID = 0
    end 
    self._menuLayer:removePointer()
end

function ZhuChenglayer:onCleanup()
    self._menuLayer:removeSchedulerAddRes()
    self:removeDispatchEvent()
end

--初始化主城背景及建筑界面
function ZhuChenglayer:initUI()    
    musicManager.setEffectVolume(0.5)--控制音效大小by.huangjunjian
    UserDataMgr:getBuildingsStaticData()

    self:initNewBg() -- 初始化新背景层
    --self:initBg() --初始化背景层
    self:initMenuLayer() --初始化按钮层
    ------显示地图上的动画效果
    -- self:displayMapEffect()------加载特效
    self:showAttackPop()
    self:refreshData()
    ----让第一个建筑居中
    -- if self._externalMark and self._externalMark.guide == true then ----第一次进来游戏 
    --     self:gotoSpecifiedBuild(3,nil,true) -----第一个建筑 
    -- else 
    self:gotoSpecifiedBuild(2,nil,true) ----第一次进来到七星坛
    -- end 
   
end

-- 初始化新背景层
function ZhuChenglayer:initNewBg( ... )

    local g_winSize = self:getContentSize()

    local view = requires("src/fsgl/layer/common/DuoCengScrollLayer.lua"):createOne()
    view:setBounce(50)
    self._backView = view
    self:addChild(view,-1)

    local pLay = cc.Node:create()
    pLay:setContentSize(2400, 720)
    view:addNewBackLay(pLay, 1, 1)

    local sky = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/sky.json", "res/image/homecity/frames/mySpine/sky.atlas", 1.0)
    sky:setAnimation(0,"animation",true)
    sky:setPosition(1200, 0)
    pLay:addChild(sky, 1)

    local yuanjingshan_b = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/yuanjingshan_b.json", "res/image/homecity/frames/mySpine/yuanjingshan_b.atlas", 1.0)
    yuanjingshan_b:setAnimation(0,"animation",true)
    yuanjingshan_b:setPosition(1200, 0)
    pLay:addChild(yuanjingshan_b, 5)

    local yuanjingshan = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/yuanjingshan.json", "res/image/homecity/frames/mySpine/yuanjingshan.atlas", 1.0)
    yuanjingshan:setAnimation(0,"animation",true)
    yuanjingshan:setPosition(1200, 0)
    pLay:addChild(yuanjingshan, 10)

    local yuanjingshan_c = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/yuanjingshan_c.json", "res/image/homecity/frames/mySpine/yuanjingshan_c.atlas", 1.0)
    yuanjingshan_c:setAnimation(0,"animation",true)
    yuanjingshan_c:setPosition(1200, 0)
    pLay:addChild(yuanjingshan_c, 15)

    local yuanjingwuqi = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/yuanjingwuqi.json", "res/image/homecity/frames/mySpine/yuanjingwuqi.atlas", 1.0)
    yuanjingwuqi:setAnimation(0,"animation",true)
    yuanjingwuqi:setPosition(1200, 0)
    pLay:addChild(yuanjingwuqi, 20)

    local yuanjingshan_d = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/yuanjingshan_d.json", "res/image/homecity/frames/mySpine/yuanjingshan_d.atlas", 1.0)
    yuanjingshan_d:setAnimation(0,"animation",true)
    yuanjingshan_d:setPosition(1200, 0)
    pLay:addChild(yuanjingshan_d, 25)

    local zhongjingshan = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/zhongjingshan.json", "res/image/homecity/frames/mySpine/zhongjingshan.atlas", 1.0)
    zhongjingshan:setAnimation(0,"animation",true)
    zhongjingshan:setPosition(1200, 0)
    pLay:addChild(zhongjingshan, 30)

    local zhongjingwuqi = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/zhongjingwuqi.json", "res/image/homecity/frames/mySpine/zhongjingwuqi.atlas", 1.0)
    zhongjingwuqi:setAnimation(0,"animation",true)
    zhongjingwuqi:setPosition(1200, 0)
    pLay:addChild(zhongjingwuqi, 35)

    local wuqi = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/wuqi.json", "res/image/homecity/frames/mySpine/wuqi.atlas", 1.0)
    wuqi:setAnimation(0,"animation",true)
    wuqi:setPosition(1200, 0)
    pLay:addChild(wuqi, 40)

    local qizi_donghua = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/qizi_donghua.json", "res/image/homecity/frames/mySpine/qizi_donghua.atlas", 1.0)
    qizi_donghua:setAnimation(0,"animation",true)
    qizi_donghua:setPosition(966, 139)
    pLay:addChild(qizi_donghua, 45)

    local qianjingjianzhu = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/qianjingjianzhu.json", "res/image/homecity/frames/mySpine/qianjingjianzhu.atlas", 1.0)
    qianjingjianzhu:setAnimation(0,"animation",true)
    qianjingjianzhu:setPosition(1200, 0)
    pLay:addChild(qianjingjianzhu, 50)

    local dibubianan = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/dibubianan.json", "res/image/homecity/frames/mySpine/dibubianan.atlas", 1.0)
    dibubianan:setAnimation(0,"animation",true)
    dibubianan:setPosition(1200, 0)
    pLay:addChild(dibubianan, 55)

    local tree = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/tree.json", "res/image/homecity/frames/mySpine/tree.atlas", 1.0)
    tree:setAnimation(0,"animation",true)
    tree:setPosition(1200, 0)
    pLay:addChild(tree, 60)

    local kongmingdeng = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/kongmingdeng.json", "res/image/homecity/frames/mySpine/kongmingdeng.atlas", 1.0)
    kongmingdeng:setAnimation(0,"animation",true)
    kongmingdeng:setPosition(1200, 0)
    pLay:addChild(kongmingdeng, 65)

    local qianjingwuqi = sp.SkeletonAnimation:create( "res/image/homecity/frames/mySpine/qianjingwuqi.json", "res/image/homecity/frames/mySpine/qianjingwuqi.atlas", 1.0)
    qianjingwuqi:setAnimation(0,"animation",true)
    qianjingwuqi:setPosition(1200, 0)
    pLay:addChild(qianjingwuqi, 70)

    view:setBackLayData(nil)
    view:resetBackLay()
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ---创建建筑
    for i = 1, 10 do 
        if i ~= 7 then 
            local _build = BuildingItem1:create({
                buildingId = i,
                endCallback = function( )
                    if i == 3 then ----钱庄
                        self:clickBuilding(i)
                    else 
                        ----------引导
                        YinDaoMarg:getInstance():guideTouchEnd() 
                        ------------------------
                        self:openFunctionsByID(i)
                    end 
                end,
                beganCallback = function( )
                    self._targetCity = self._buildingsTable[i]
                end,
                collectCallback = function(id)
                    self:collectAniAndRefreshRes(id)                 
                end,
            })
            if _build then
                if _build:getId() == 1 then
                    pLay:addChild(_build, 18)
                elseif _build:getId() == 3 then
                    pLay:addChild(_build, 44)
                elseif _build:getId() == 4 then
                    pLay:addChild(_build, 19)
                elseif _build:getId() == 5 then
                    pLay:addChild(_build, 28)
                elseif _build:getId() == 6 then
                    pLay:addChild(_build, 89)
                elseif _build:getId() == 9 then
                    pLay:addChild(_build, 18)
                else
					if _build:getId() == 2 then
						local canZhaomu = cc.Sprite:create("res/image/homecity/canten.png")
						_build:addChild(canZhaomu)
						canZhaomu:setName("canZhaomu")
						canZhaomu:setPosition(_build:getContentSize().width *0.5,_build:getContentSize().height *0.5 + canZhaomu:getContentSize().height)
						canZhaomu:runAction(
							cc.RepeatForever:create(
								cc.Sequence:create(
									cc.MoveBy:create(
										0.6, cc.p( 0, 3 )
									),
									cc.MoveBy:create(
										0.6, cc.p( 0, -3 )
									)
								)
							)
						)
					end
                    pLay:addChild(_build, 100)
                end
                
                self._buildingsTable[i] = _build
            end 
        end 
    end
    
    local function onClick( sPos, sIsClick )
        if not self._clickedBuilding then ----没有被选中的建筑 
            self:cleanOperatorBtns()
        end
        self._clickedBuilding = false 
        if self._targetCity then
            self._targetCity:setSelectedState(false)
            self._targetCity = nil
        end 
    end
    view:setClickCallFunc(onClick) 


    local _pos = cc.p(45, 215)
    local _file = "res/image/friends/zuixinxiaoxi_17.png"
    local _file2 = "res/image/friends/zuixinxiaoxi_18.png"
    --创建新消息提示按钮
    local _sp = XTHD.createButton({
        normalFile = _file,
        selectedFile = _file2,
        needSwallow = true,
        endCallback = function ()
            requires("src/fsgl/layer/HaoYou/IntracationInfoPop1.lua"):create(self)
        end,
        pos = _pos,
    })
    _sp:setEnable(false)
    self:addChild(_sp)
    _sp:setVisible(false)
    self._newsBtn = _sp

    self._newsSp = cc.Sprite:create(_file)
    self._newsSp:setPosition(_pos)
    self._newsSp:setVisible(false)
    self:addChild(self._newsSp)
end


-- 初始化背景层
function ZhuChenglayer:initBg( ... )
    local view = requires("src/fsgl/layer/common/DuoCengScrollLayer.lua"):createOne()
    view:setBounce(50)
    self._backView = view
    self:addChild(view,-1)

    local pLay, pFileName, pSprite
    local pWidth = 0
    local pFileTb = {"res/image/homecity/cityworld_bg",1,"_",1,".png"}
    local g_winSize = self:getContentSize()
    local topWidt = 0
    local _backLayData = {}
    for i = 1, 3 do
        local pLay = cc.Node:create()
        pWidth = 0
        local pDatas = {id = i+1}
        pDatas.data = {}
        for j = 1, 4 do
            pFileTb[2] = i
            pFileTb[4] = j
            pFileName = table.concat(pFileTb)
            pSprite = cc.Sprite:create(pFileName)
            --换主城背景
            pSprite:setScaleY(0.85)
            -- if i ==1 and j == 1 then
            --     local yezi = cc.ParticleSystemQuad:create("res/image/homecity/zhi1.plist")
            --     yezi:setScale(2.5)
            --     yezi:setPosition(pSprite:getContentSize().width/2,pSprite:getContentSize().height/1.5)
            --     yezi:setAutoRemoveOnFinish(false)
            --     self:addChild(yezi) 
            -- end
            if (pSprite) then
                pSprite:setAnchorPoint(0, 0)
                pSprite:setPosition(pWidth, 0)
                pLay:addChild(pSprite)
                pWidth = pWidth + pSprite:getContentSize().width
                pDatas.data[#pDatas.data + 1] = pFileName
                pSprite:setName("back_" .. j)
            end
        end
        if i == 2 then-------中间的云
            local x = 0
            local pLenth = #pDatas.data
            for j = 1,4 do 
                pFileName = "res/image/homecity/cityworld_bg4_" .. j ..".png"
                local _temp = cc.Sprite:create(pFileName)
                -- 缩放
                _temp:setScaleY(0.85)
                pLay:addChild(_temp)
                _temp:setAnchorPoint(0, 0)
                _temp:setPosition(x, 10)
                x = x + _temp:getContentSize().width
                self._clound[j] = _temp
                _temp:setName("back_" .. (pLenth + j))
                pDatas.data[#pDatas.data + 1] = pFileName
            end 
        end
        _backLayData[#_backLayData + 1] = pDatas
        local pSize = cc.size(pWidth, g_winSize.height)
        pLay:setContentSize(pSize)
        view:addBackLay(pLay,i+1)
        if(i == 1) then
            local pLay2 = cc.Node:create()
            pLay2:setContentSize(pSize)
            view:addBackLay(pLay2,i)
            self._front_bg = pLay2
            topWidt = pWidth
        elseif(i == 2) then
            self._middle_bg = pLay
        elseif(i == 3) then
            self._after_bg = pLay
        end
    end
    view:setBackLayData(_backLayData)
    view:resetBackLay()
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ---创建建筑
    for i = 1, 10 do 
        if i ~= 7 then 
            local _build = BuildingItem1:create({
                buildingId = i,
                endCallback = function( )
                    if i == 3 then ----钱庄
                        self:clickBuilding(i)
                    else 
                        ----------引导
                        YinDaoMarg:getInstance():guideTouchEnd() 
                        ------------------------
                        self:openFunctionsByID(i)
                    end 
                end,
                beganCallback = function( )
                    self._targetCity = self._buildingsTable[i]
                end,
                collectCallback = function(id)
                    self:collectAniAndRefreshRes(id)                 
                end,
            })
            if _build then 
                self._front_bg:addChild(_build, 1)
                self._buildingsTable[i] = _build
            end 
        end 
    end
    
    local function onClick( sPos, sIsClick )
        if not self._clickedBuilding then ----没有被选中的建筑 
            self:cleanOperatorBtns()
        end
        self._clickedBuilding = false 
        if self._targetCity then
            self._targetCity:setSelectedState(false)
            self._targetCity = nil
        end 
    end
    view:setClickCallFunc(onClick) 


    local _pos = cc.p(50, 165)
    local _file = "res/image/friends/zuixinxiaoxi_17.png"
    local _file2 = "res/image/friends/zuixinxiaoxi_18.png"
    --创建新消息提示按钮
    local _sp = XTHD.createButton({
        normalFile = _file,
        selectedFile = _file2,
        needSwallow = true,
        endCallback = function ()
            requires("src/fsgl/layer/HaoYou/IntracationInfoPop1.lua"):create(self)
        end,
        pos = _pos,
    })
    _sp:setEnable(false)
    self:addChild(_sp)
    _sp:setVisible(false)
    self._newsBtn = _sp

    self._newsSp = cc.Sprite:create(_file)
    self._newsSp:setPosition(_pos)
    self._newsSp:setVisible(false)
    self:addChild(self._newsSp)
end

function ZhuChenglayer:freshNewsBtn( event )
    if not self._newsBtn or event.data.name ~= "newsMsg" then
        return false
    end
    if not event.data.visible then
        self._newsSp:stopAllActions()
        self._newsBtn:stopAllActions()
        self._newsSp:setVisible(false)
        self._newsBtn:setEnable(false)
        self._newsBtn:setVisible(false)
        return true
    end
    self._newsSp:setVisible(true)
    self._newsSp:setOpacity(0)
    local action = cc.Sequence:create(
        cc.FadeIn:create(1),
        cc.CallFunc:create(function ( ... )
            self._newsSp:setVisible(false)
            self._newsBtn:setVisible(true)
            self._newsBtn:setEnable(true)
            self._newsBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(1, 1.1),
                cc.ScaleTo:create(1, 1.0)
            )))
        end)
        )
    self._newsSp:runAction(action)
    return true
end

--初始化菜单层
function ZhuChenglayer:initMenuLayer()  
    print("********CTX_log:初始化主城界面*********")
    local menuLayer = requires("src/fsgl/layer/ZhuCheng/ZhuChengMenuLayer.lua"):create(self)
    self._menuLayer = menuLayer
    self:addChild(menuLayer)

    self:refreshBaseInfo()
end

--点击建筑
function ZhuChenglayer:clickBuilding(n)        
    ----------引导
    YinDaoMarg:getInstance():guideTouchEnd()
    ------------------------------------------------------------------------------------------------------------------------------
    if self._buildPointer then ----移除在建筑上的手，非新手引导
        self._buildPointer:removeFromParent()
        self._buildPointer = nil
    end 
    ------------------------------------------------------------------------------------------------------------------------
    self._targetCity = self._buildingsTable[n]
    if not self._targetCity then 
        return nil
    end 
    ------------------------------------------------------------------------------------------------------------------------
    local hasResource = false
    if self._targetCity:isCanCollect() then -----有资源可收集
        self._targetCity:removeCollectMark()
        hasResource = true
    else 
        local layer = requires("src/fsgl/layer/ZhuCheng/BuildUpgradeLayer1.lua"):create({
            id = n,
            build = self._buildingsTable[n],
            needVip = self._buildLevelUpVIP,
            levelupCallback = function(id,time) ------点击升级之后的
                if self._buildingsTable[id] and not self._buildingsTable[id]:isLevelUp() then
                    if self._buildingsTable[id]:isSpeedUp() then
                        self._buildingsTable[id]:setSpeedUpState(0)
                        self._buildingsTable[id]:removeSpeedUpEffect()
                    end
                    --升级特效
                    self._buildingsTable[id]:setLevelUpState(time)
                    self._buildingsTable[id]:getProgressBar()
                    self._buildingsTable[id]:startCount()
                    --取消选中
                    self._buildingsTable[id]:setSelectedState(false)
                    self._curBuildingId = nil
                    self:refreshBaseInfo()                    
                end
            end,
            immidCallback = function(data) ----点击立刻完成之后 的
                self._buildingsTable[data.buildId]:setCurLevel(data.level)
                self._buildingsTable[data.buildId]:setLevelUpState(0)
                self._buildingsTable[data.buildId]:removeProgressBar()
                --取消选中
                self._buildingsTable[data.buildId]:setSelectedState(false)
                self._curBuildingId = nil
                self:refreshBaseInfo()
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {name = "build"}})
            end
        })
        LayerManager.addLayout(layer,{par = self})
    end 
    return hasResource
end

function ZhuChenglayer:cleanOperator( )
    if operatorBtns then
        operatorBtns:setClosedBtns()
        operatorBtns = nil         
    end
end

function ZhuChenglayer:cleanOperatorBtns( ... )
    self._clickedBuilding = false
    if self._curBuildingId and self._buildingsTable[self._curBuildingId] then                                                           
        self._buildingsTable[self._curBuildingId]:setSelectedState(false)
        self._curBuildingId = nil   
        self:cleanOperator()
    end
end

function ZhuChenglayer:openFunctionsByID(id)
    local _secondID = 0
    if self._buildPointer then ----移除在建筑上的手，
        self._menuLayer:setVisible(true)
        self._buildPointer:removeFromParent()
        self._buildPointer = nil
        _secondID = self._extraFuncID 
    end 
    if not self._buildingsTable[id]:getUnlock() then 
        local _data = mGameData.getDataFromCSV("FunctionInfoList",{ buildingid = id })
        if not _data.tip or _data.tip == "" then
            XTHDTOAST(LANGUAGE_KEY_UNLOCK)------"未解锁")
        else
            XTHDTOAST(_data.tip)
        end                
        return 
    end 
    if id then
        if id == 1 then ---演武场
            local ChapterSelect = requires("src/fsgl/layer/RiChangRenWu/RiChangRenWuLayer.lua"):create(_secondID,self)
            LayerManager.addLayout(ChapterSelect)
        elseif id == 2 then ---抽卡
            -------引导--------
            local _group,_index = YinDaoMarg:getInstance():getGuideSteps()
            if _group == 1 and _index == 3 then 
                XTHD.createExchangeLayer(self,nil,function( ) ------成功回调
                    YinDaoMarg:getInstance():releaseGuideLayer()
                    performWithDelay(self,function( )      
                        YinDaoMarg:getInstance():doNextGuide()
                        local _group,_index = YinDaoMarg:getInstance():getGuideSteps()
                        if _group == 6 and _index == 11 then ------先弹点剧情 
                            YinDaoMarg:getInstance():setCurrentGuideVisibleStatu(false)
                            requires("src/fsgl/layer/YinDaoJieMian/GuideHealFoxLayer.lua"):create(function( )
                                YinDaoMarg:getInstance():setCurrentGuideVisibleStatu(true)
                            end)
                        end  
                    end,0.01)
                end,1,function( ) -----失败回调
                    YinDaoMarg:getInstance():tryReguide()
                end) ---直接进抽将
            else 
                XTHD.createExchangeLayer(self)
            end 
            -------引导--------
        elseif id == 3 then -----钱庄

        elseif id == 4 then ---万宝阁
            requires("src/fsgl/layer/WanBaoGe/WanBaoGe.lua"):createWithType(1, {par = self})     
        elseif id == 5 then --铁匠铺
            local StoredValue = requires("src/fsgl/layer/TieJiangPu/TieJiangPuLayer.lua"):create()
            LayerManager.addLayout(StoredValue, {par = self})
        elseif id == 6 then ----排行     
            XTHDHttp:requestAsyncInGameWithParams({
                modules = "allDuanRank?",
                successCallback = function(data)
					-- dump(data,"英雄榜")
                    if tonumber(data.result)==0 then
                        local paihangbang_layer=requires("src/fsgl/layer/ZhuCheng/RankListLayer1.lua"):create(data) 
						self:addChild(paihangbang_layer)
                        --LayerManager.addLayout(paihangbang_layer, {par = self})
                    else
                          XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败"..data.result)
                    end 
                end,
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })             
        elseif id == 8 then ----图鉴
            local illustrationlayer = requires("src/fsgl/layer/TuJian/TuJianLayer.lua"):create()
            LayerManager.addLayout( illustrationlayer )
        elseif id == 9 then -----领地战
            requires("src/fsgl/layer/ZhongZu/ZhongZuMainLayer.lua"):create(nil,self)    
        elseif id == 10 then ----邮件
            XTHD.createMail(self)            
        end 
    end 
end

--用来刷新等级、经验，银两，银币信息
function ZhuChenglayer:refreshBaseInfo() 
    -- 刷新按钮层的信息
    self._menuLayer:refreshBaseInfo()
    ------建筑 显示小红点 
    if self._buildingsTable and next(self._buildingsTable) ~= nil then  
        for k,v in pairs(self._buildingsTable) do 
            local index = v:getId()
            local pstate = tonumber(mGameUser.getRecruiteState()) or 0
            local pk = tonumber(k) or 0
            if v:canLevelUp() and v:getLevelUpState() <= 0 and self:canBuildingLevelUp() then -----当前建筑能升级
                v._redDot:setVisible(true)
            elseif pk == 2 and pstate > 0 then ----如果是七星坛有免费的抽卡机会
                v._redDot:setVisible(true)
            elseif pk == 10 and mGameUser.getEmailAmount() > 0 then -----邮件还有
                v._redDot:setVisible(true)
                v:playSpines(false)
            elseif pk == 1 then
                v._redDot:setVisible(RedPointState[16].state == 1)
            else  
                v._redDot:setVisible(false)
                v:playSpines(true)
            end 
        end
    end 
	
end
-- 刷新建筑相关信息
function ZhuChenglayer:refreshData()
    if self._builds and next(self._builds) ~= nil then
        for i = 1, #self._builds do --这些都是解锁的 
            local index = self._builds[i].buildId
            if self._buildingsTable and self._buildingsTable[index] then 
                self._buildingsTable[index]:setUnlock(true)
                self._buildingsTable[index]:setCurLevel(self._builds[i].level)
                self._buildingsTable[index]:setCurGold(self._builds[i].gold)
                self._buildingsTable[index]:setCurFeicui(self._builds[i].feicui)
                self._buildingsTable[index]:setLevelUpState(self._builds[i].upEndTime)
                self._buildingsTable[index]:setSpeedUpState(self._builds[i].addSpeedEndTime)
                self._buildingsTable[index]:startCount()

                if self._buildingsTable[index] and self._buildingsTable[index]:getLevelUpState() > 0 then --升级中
                    self._buildingsTable[index]:getProgressBar() ---显示升级特效
                end
                if self._buildingsTable[index] and self._buildingsTable[index]:getSpeedUpState() > 0 then --加速中
                    self._buildingsTable[index]:getSpeedUpEffect()--显示加速特效
                elseif self._buildingsTable[index] and self._buildingsTable[index]:isSpeedUp() then
                    self._buildingsTable[index]:removeSpeedUpEffect()
                end
                --被选中的建筑不提示领取资源
                if not self._curBuildingId or self._curBuildingId ~= index then --没有被选中的建筑 或 除去被选中的建筑
                    self._buildingsTable[index]:getCollectMark()--建筑是否可以领资源
                end          
            end
        end
    end
end
--[[@buildingCollectNum table{id,addG：增加的银两,addJ:增加的翡翠}]]
function ZhuChenglayer:collectAniAndRefreshRes(buildingCollectNum)
    if buildingCollectNum and type(buildingCollectNum) == "table" then 
        local id = buildingCollectNum.id       
        self.__addGold = self.__addGold + buildingCollectNum.addG 
        self.__addJade = self.__addJade + buildingCollectNum.addJ
        local target = self._buildingsTable[id]
        if target then 
            local collectResDone = true
            
            local function runAni2( )
                local function callBack( sID )
                    self.__addJade = 0  
                    self.__addGold = 0
                    self._menuLayer:removeSchedulerAddRes()
                    self._menuLayer:setGJHugeNum()
                end
                self._menuLayer:playGJAddAction(buildingCollectNum, self.__addGold, self.__addJade, collectResDone, callBack)
            end
            performWithDelay(target, runAni2, 0.01)
            
        end 
    end
end
----------authored by LITAO---
-- 刷新红点相关提示信息
function ZhuChenglayer:freshRedNotifications( event )
   
    if (not event) then
        return
    end
    print("--------------------建筑小红点------------------"..event.data.name)
    if self:freshNewsBtn(event) then    --如果是聊天新消息提示
        return
    end
    if self._menuLayer then
        if (self._menuLayer:freshRedPoints(event)) then  --如果是maincitymenulayer中的按钮中的小红点
            return
        end
    end
    if event.data.name == "build" then -----建筑可升级
        if not self._buildingsTable then 
            return 
        end 
        for k,v in pairs(self._buildingsTable) do 
            if v:canOpen() then 
                v:setUnlock(true)
            end 
            if v:getUnlock() == true and v:getLevelUpState() <= 0 and v:canLevelUp() and self:canBuildingLevelUp() then   
                v._redDot:setVisible(true)
            else            
                if (mGameUser.getRecruiteState() > 0 and k == 2) or (mGameUser.getEmailAmount() > 0 and k == 10) then ----是七星坛(可免费抽卡)/ 邮件
                    v._redDot:setVisible(true)
                else 
                    v._redDot:setVisible(false)                        
                end 
            end 
        end         
    elseif event.data.name == "mail" then       --邮件
        if self._buildingsTable and self._buildingsTable[10] then 
            self._buildingsTable[10]._redDot:setVisible(RedPointState[15].state == 1)
            self._buildingsTable[10]:playSpines(RedPointState[15].state == 0)
			if self._menuLayer.__functionButtons[67] then
				self._menuLayer.__functionButtons[67]:setVisible(ISUNREADMAIL)
			end
            if RedPointState[15].state == 0 then 
                mGameUser.setEmailAmount( 0 )
            end 
        end 
    elseif event.data.name == "chouka" then -----抽卡(七星坛)
        if self._buildingsTable and self._buildingsTable[2] then 
            local target = self._buildingsTable[2]                    
            if event.data.visible == true then 
                target._redDot:setVisible(true)
            elseif event.data.visible == false then 
                if not (target:canLevelUp() and target:getUnlock() == true and target:getLevelUpState() <= 0) or mGameUser.getRecruiteState() < 1 then 
                    target._redDot:setVisible(false)
                end 
            end 
        end 
    elseif event.data.name == "tiejiangpu" then ----合成（铁匠铺）
        if self._buildingsTable and self._buildingsTable[5] then 
            local target = self._buildingsTable[5]
            if event.data.visible == true then    
                if target and target:getUnlock() == true then 
                    target._redDot:setVisible(false)
                end 
            elseif event.data.visible == false then 
                if not (target:canLevelUp() and target:getUnlock() == true and target:getLevelUpState() <= 0) then 
                    target._redDot:setVisible(false)
                end 
            end
        end
    elseif event.data.name == "ywc" then  --演武场
        if self._buildingsTable and self._buildingsTable[1] then 
            local target = self._buildingsTable[1]
            if target and target:getUnlock() == true then 
                target._redDot:setVisible(RedPointState[16].state == 1)
            end 
        end
    -- elseif event.data.name == "liucunPackage" then -------留存奖励
    --     if self._menuLayer then 
    --         self._menuLayer:runLiuCunAction(event.data.visible)
    --     end 
    end         
end

----[目标有：邮件-mail 英雄-hero 任务-task 活动-activity] 建筑 build 建筑解锁 build_open 七星坛可免费 chouka 铁匠铺有东西可合成 tiejiangpu
function ZhuChenglayer:registerNotifications( )
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,callback = function( event )  --刷新主城小红点
        self:freshRedNotifications(event)----小红点
		if self._buildingsTable[2]:getChildByName("canZhaomu") then
			self._buildingsTable[2]:getChildByName("canZhaomu"):setVisible(self._menuLayer:refreshZhaoMuTishi())
		end
    end})
    
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO, callback = function (event)--用来刷新等级、经验，银两，银币信息，按钮的显示与隐藏
        self:refreshBaseInfo()
		if self._buildingsTable[2]:getChildByName("canZhaomu") then
			self._buildingsTable[2]:getChildByName("canZhaomu"):setVisible(self._menuLayer:refreshZhaoMuTishi())
		end
    end})
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_CITY_BUILDINGS, callback = function( event)---刷新主城建筑产出
        local data = event.data
        if data and data.buildId then  
            if self._buildingsTable and self._buildingsTable[tonumber(data.buildId)] then 
                self._buildingsTable[tonumber(data.buildId)]:setProperties(data)
                UserDataMgr:popBuildingData(data.buildId)
            end 
        end 
    end})
    XTHD.addEventListener({name = CUSTOM_EVENT.GOTO_SPECIFIEDBUILDING, callback = function( event)---特殊指引到某个指定建筑
        print("--------------------引导的参数为---------------------")
        print_r(event)
        if event.data.funcID then 
            self:gotoNewFunction(event.data)
        elseif event.data.isOpen then 
            self:setTheSpecifiedBuildClicked(event.data.id)
        else 
            self:pointToSpecifiedBuid(event.data.id)
        end 
    end})    
    XTHD.addEventListener({name = CUSTOM_EVENT.UPDATE_ACTIVITYMENUS,callback = function(event) -------更新活动按钮们的显示及位置 
        local data = event.data
        if self._menuLayer then 
            self._menuLayer:updateActivityButtonPos(data.index,data.visible)
        end 
    end})
    XTHD.addEventListener({name = CUSTOM_EVENT.SHOW_BATTLE_TIPSLAYER,callback = function(event) ----当战斗快要开始的时候，显示提示页
        local what = event.data
        if gameUser.getLevel() > 15 and self._currentBattle == 0 then 
            self._currentBattle = XTHD.displayCampWarTips(what)
            performWithDelay(self,function ( )
                self._currentBattle = 0
            end,10.0)
        end 
    end})
end
-- 移动到指定的建筑显示
function ZhuChenglayer:gotoSpecifiedBuild( id,callback,noAnimation,isEase)
    if(not self._buildingsTable[id]) then
        return
    end
    local topLay = self._backView:getTopLay()
    if(not topLay) then        
        return
    end
    local pos1 = cc.p(self._buildingsTable[id]:getPosition())
    local pos2 = cc.p(topLay:getPosition())

    -- print("gotoSpecifiedBuild: "..id)
    -- dump(pos1, pos2)
        
    local winSize = self:getContentSize()
    local dis = winSize.width / 2 - (pos1.x + pos2.x) 
    local pTIme = (noAnimation == true) and 0 or noAnimation
    self._backView:setAutoMove(pTIme, dis, callback, isEase)
end
----用图标指到指定的建筑上
function ZhuChenglayer:pointToSpecifiedBuid( id )
    local function callback( )
        local target = self._buildingsTable[id]
        if target then
            if self._buildPointer then 
                self._buildPointer:removeFromParent()
                self._buildPointer = nil
            end 
            self._menuLayer:removePointer()
            self._buildPointer = YinDao:addAHandToTarget( target )
            self._buildPointer:setRotation(180)
        end 
        self._isNewFunctionGuide = false
    end
    self:gotoSpecifiedBuild(id,callback,0.5)
end
-----移到指定的建筑，并设置为被点击状态 
function ZhuChenglayer:setTheSpecifiedBuildClicked( id )
    local function callback( )
        local target = self._buildingsTable[id]
        if target then 
            if target:isSelectedState() then ---如果在选中状态 
                return 
            end 
            local result = self:clickBuilding(id)
            if result == true then ---已收集资源
                self:clickBuilding(id)
                self._clickedBuilding = false
            end 
        end 
    end
    self:gotoSpecifiedBuild(id,callback,true)
end
----显示地图上的特效
function ZhuChenglayer:displayMapEffect( )
    ---帧特效
    -- for i = 1,16 do     
    --     ----战斗按钮上的A特效
    --     local texture = nil
    --     if i < 9 then 
    --         -- texture = cc.Director:getInstance():getTextureCache():addImage("res/image/homecity/frames/fightBtnA/llg"..i..".png")
    --         -- self._animateFrames.fightBtnA[i] = cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,texture:getPixelsWide(),texture:getPixelsHigh()))
            

    --         -- texture = cc.Director:getInstance():getTextureCache():addImage("res/image/homecity/frames/fightBtnB/jjg"..i..".png")
    --         -- self._animateFrames.fightBtnB[i] = cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,texture:getPixelsWide(),texture:getPixelsHigh()))
    --     end 
    --     if i < 8 then 
    --         ----主城场景上两个火焰
    --         texture = cc.Director:getInstance():getTextureCache():addImage("res/image/homecity/frames/fire/"..i..".png")
    --         self._animateFrames.fire[i] = cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,texture:getPixelsWide(),texture:getPixelsHigh()))
    --     end 
    --     --没做好之前的
    --     -- texture = cc.Director:getInstance():getTextureCache():addImage("res/image/homecity/frames/newgoal/xmb"..i..".png") ----新目标上的特效
    --     texture = cc.Director:getInstance():getTextureCache():addImage("res/image/homecity/frames/newgoal/maincity_newTarget_bg.png") ----新目标上的特效
    --     self._animateFrames.newGold[i] = cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,texture:getPixelsWide(),texture:getPixelsHigh()))        
    -- end     
    -- for i = 1,20 do ----天上的鸟
    --     local texture = cc.Director:getInstance():getTextureCache():addImage("res/image/homecity/frames/bird/feiniaoa_0"..i..".png")
    --     self._animateFrames.bird[i] = cc.SpriteFrame:createWithTexture(texture,cc.rect(0,0,texture:getPixelsWide(),texture:getPixelsHigh()))
    -- end 

    -- self._menuLayer:displayMenuEffect(self._animateFrames, self.Tag)

    ----左边的火焰（不知道是哪的）
    -- local fire = cc.Animation:createWithSpriteFrames(self._animateFrames.fire,0.1)
    -- fire = cc.Animate:create(fire)
    -- local target = cc.Sprite:create()
    -- if self._front_bg and not self._front_bg:getChildByTag(self.Tag.ktag_nodeOfLeftFire) then 
    --     self._front_bg:addChild(target,1,self.Tag.ktag_nodeOfLeftFire)
    --     target:setPosition(1643,166)
    --     target:runAction(cc.RepeatForever:create(fire:clone()))
    -- end 
     
    ---天上的鸟
    -- local _bird = cc.Animation:createWithSpriteFrames(self._animateFrames.bird,1/20)
    -- _bird = cc.Animate:create(_bird)
    -- _bird = cc.RepeatForever:create(_bird)
    -- if self._after_bg and not self._after_bg:getChildByTag(self.Tag.ktag_nodeOfBird) then 
    --     target = cc.Sprite:create() 
    --     target:setScale(2.0)         
    --     local move1 = cc.MoveTo:create(20.0,cc.p(450,self:getContentSize().height - 120))
    --     local move2 = cc.MoveTo:create(20.0,cc.p(800,self:getContentSize().height + 20))
    --     local move = cc.Sequence:create(move1,move2,cc.CallFunc:create(function( )
    --         target:setPosition(-50,self:getContentSize().height - 110)
    --         target:setScale(2.0)
    --     end))        
    --     target:runAction(_bird)
    --     target:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(move,cc.ScaleTo:create(20,1.0)),cc.DelayTime:create(10.0))))
    --     self._after_bg:addChild(target,1)
    --     target:setTag(self.Tag.ktag_nodeOfBird)
    --     target:setPosition(-50,self:getContentSize().height - 110)
    -- end 
    ----左边的水(图鉴上边的水)
    -- local _targSpine = sp.SkeletonAnimation:create( "res/image/homecity/frames/spine/scwq.json", "res/image/homecity/frames/spine/scwq.atlas", 1.0)   
    -- _targSpine:setAnimation(0,"animation",true)
    -- self._front_bg:addChild(_targSpine,1)
    -- _targSpine:setPosition(173,230)    
    -------粒子落叶
    -- local emitter1 = cc.ParticleSystemQuad:create("res/image/homecity/frames/zhi1.plist") 
    -- local emitter2 = cc.ParticleSystemQuad:create("res/image/homecity/frames/zhi2.plist") 
    -- self._front_bg:addChild(emitter1,1)
    -- emitter1:setPositionType(cc.POSITION_TYPE_RELATIVE)
    -- emitter1:setPosition(self._front_bg:getContentSize().width - 200,self._front_bg:getContentSize().height - 20)
    -- self._front_bg:addChild(emitter2,1)
    -- emitter2:setPositionType(cc.POSITION_TYPE_RELATIVE)
    -- emitter2:setPosition(self._front_bg:getContentSize().width - 250,self._front_bg:getContentSize().height - 20)
    -- -------粒子樱花
    -- emitter1 = cc.ParticleSystemQuad:create("res/image/homecity/frames/yinno.plist") 
    -- emitter1:setPositionType(cc.POSITION_TYPE_RELATIVE)
    -- local _parent = self._buildingsTable[3]:getSpineNodeByName("lizi")
    -- if _parent then 
    --     local pos = _parent:convertToWorldSpace(cc.p(0,0))
    --     pos = self._buildingsTable[3]:convertToNodeSpace(pos)
    --     _parent:addChild(emitter1)
    --     emitter1:setPosition(pos)
    -- else 
    --     -- self._buildingsTable[3]:addChild(emitter1)
    --     emitter1:setPosition(self._buildingsTable[3]:getContentSize().width / 2 - 22,self._buildingsTable[3]:getContentSize().height)
    -- end 
    -- -----云在跑
    -- local _totleWidth = 0
    -- for k,v in pairs(self._clound) do 
    --     _totleWidth = _totleWidth + v:getContentSize().width
    -- end
    for k,v in pairs(self._clound) do 
        local action = cc.MoveBy:create(0.02,cc.p(-1,0))
        action = cc.RepeatForever:create(cc.Sequence:create(action,cc.CallFunc:create(function( )
            local x,y = v:getPosition()
            if x <= -v:getContentSize().width then 
                v:setPosition(_totleWidth - v:getContentSize().width, y)
            end 
        end)))
        v:runAction(action)
    end 
end

--[[by,huangjunjian 防守信息提示 就是在下线的时候被别人打了的日志]]
function ZhuChenglayer:showAttackPop(  )
    local function createAttackPopUI(data)
        local poplayer= XTHDDialog:create()--XTHDPopLayer:create()
        self:addChild(poplayer)
        local _popBgSprite=cc.Sprite:create("res/image/common/scale9_bg3_34.png")
        _popBgSprite:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
        poplayer:addChild(_popBgSprite)
        --主人，你不在的时候我们收到了攻击
        local label = XTHDLabel:create("主人，你不在的时候我们受到了攻击",20,"res/fonts/def.ttf")
        label:setPosition(_popBgSprite:getContentSize().width/2,_popBgSprite:getContentSize().height-70)
        _popBgSprite:addChild(label)
        label:setColor(cc.c3b(108,88,81))
        -- label:enableOutline(cc.c4b(255,255,255,255),1)
         --关闭按钮
        local close_btn = XTHD.createBtnClose(function()
            poplayer:removeFromParent()
        end)
        close_btn:setPosition(_popBgSprite:getContentSize().width - 15, _popBgSprite:getContentSize().height - 15)
        _popBgSprite:addChild(close_btn)
        
        local scrollViewBg=ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png")
        scrollViewBg:setContentSize(cc.size(_popBgSprite:getContentSize().width -120,230))
        scrollViewBg:setPosition(cc.p(60,100))
        scrollViewBg:setAnchorPoint(0, 0)
        _popBgSprite:addChild(scrollViewBg)

        local scrollView = ccui.ScrollView:create()
		scrollView:setScrollBarEnabled(false)
        scrollView:setAnchorPoint(0, 0)
        scrollView:setTouchEnabled(true)
        scrollView:setBounceEnabled(true)
        scrollView:setContentSize(cc.size(_popBgSprite:getContentSize().width,230))
        scrollView:setPosition(cc.p(0,0))
        scrollView:setName("scrollView")
        scrollViewBg:addChild(scrollView, 2)
        --蓝色31  210 255
        --     --提示文字
        local function setTime(_time)
            local turnTime = tonumber(_time)
            local timeStr = nil
            if turnTime < 60 then
                timeStr = LANGUAGE_CHAT_TIME8(turnTime) -----"分钟前"
            elseif turnTime < 1440 then
                timeStr = LANGUAGE_CHAT_TIME9(math.floor(turnTime/60)) -------"小时前"
            elseif turnTime < 10080 then
                timeStr = LANGUAGE_CHAT_TIME10(math.floor(turnTime/1440)) -------"天前"
            elseif turnTime < 43200 then
                timeStr = LANGUAGE_CHAT_TIME11(math.floor(turnTime/10080)) -------"周前"
            else
                timeStr = LANGUAGE_CHAT_TIME12(math.floor(turnTime/43200)) ------"个月前"
            end
            return timeStr
        end
        
        local num=#data.list or 0
        local Position_last=220
        if num>1 then
            Position_last=(Position_last)*(tonumber(num)+1)
            scrollView:setInnerContainerSize(cc.size(_popBgSprite:getContentSize().width,Position_last+20))
        end
        
        for i=1,num do --tonumber(#data.list) do
            local time = XTHDLabel:createWithParams({
                text =setTime(tonumber(data.list[i]["diffTime"])),
                fontSize = 20,
                color = cc.c3b(71, 37, 30),
            })
            time:setAnchorPoint(0.5,0.5)
            time:setPosition(scrollViewBg:getContentSize().width/2,Position_last-25)
            scrollView:addChild(time)
            local announcement = XTHDLabel:createWithParams({
                text =LANGUAGE_KEY_OTHER_ATTACK_YOU(tostring(data.list[i]["attackName"])),------"攻击了你",
                fontSize = 20,
                color = cc.c3b(71, 37, 30),
            })
            announcement:setAnchorPoint(0.5,0.5)
            announcement:setPosition(scrollViewBg:getContentSize().width/2,Position_last-90)
            scrollView:addChild(announcement)
            
            local result1 = XTHDLabel:createWithParams({
                text = LANGUAGE_TIP_YOU_WIN,----- "你赢了",
                fontSize = 22,
                color = cc.c3b(104,157,0),
            })
            result1:setAnchorPoint(0.5,0.5)
            result1:setPosition(scrollViewBg:getContentSize().width/2,Position_last-150)
            scrollView:addChild(result1)
            if data.list[i]["result"] and data.list[i]["result"]==0 then
                result1:setString(LANGUAGE_TIP_YOU_LOSE)------"你输了")
                result1:setColor(cc.c3b(255,48,48))
            end
            -- local line=cc.Sprite:create("res/image/setting/line.png")
            -- scrollView:addChild(line)
            -- line:setAnchorPoint(0,0.5)
            -- line:setScaleX(390/271)
            -- line:setPosition(20+10,Position_last-15)
            Position_last=Position_last -220     
        end
        --资源变化
        local sourcechange=XTHDLabel:createWithParams({text= LANGUAGE_KEY_RESOURCECHANGE,ttf="",size=18})-------"资源变化:"
        sourcechange:setColor(cc.c3b(71, 37, 30))
        sourcechange:setAnchorPoint(0,0)
        sourcechange:setPosition(25+20,35-2+15)
        _popBgSprite:addChild(sourcechange)
        
        local sp_tab={"res/image/common/header_feicui.png","res/image/common/header_gold.png","res/image/plugin/competitive_layer/competitiveDefense_Prestige.png"}
        for i=1,2 do
             local weiwangsp=cc.Sprite:create(sp_tab[i])
             weiwangsp:setAnchorPoint(0.5,0.5)
             if i== 3 then
                weiwangsp:setScale(0.65)
             elseif i== 1 then
                weiwangsp:setScale(0.9)
             end
             weiwangsp:setPosition(125+(i-1)*150+20,40+4+15)
             _popBgSprite:addChild(weiwangsp)
             local num=0
             if i==1 and data.lostfeicui then
                num= tonumber(data.lostfeicui)
             elseif i==2 and data.lostSilver then
                num= tonumber(data.lostSilver)
             end
             local weiwangnum=getCommonWhiteBMFontLabel(num)
             weiwangnum:setAnchorPoint(0,0.5)
             _popBgSprite:addChild(weiwangnum)
             weiwangnum:setPosition(weiwangsp:getPositionX()+20+20,40-2+15) 
        end
    end
    XTHDHttp:requestAsyncInGameWithParams({
        modules = "defendList?",
        successCallback = function(data)
            if data and data.list and #data.list > 0 then
                createAttackPopUI(data)
            end
        end,
        failedCallback = function()
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
    })     
end
-----返回跟建筑功能开启有关的VIP等级,返回加速和升级立刻完成需要的VIP等级，
function ZhuChenglayer:getBuildAboutVIP( )
    local vipData = mGameData.getDataFromCSV("VipInfo")
    local _speed = 3
    local _upOver = 3
    if not vipData then 
        return _speed,_upOver
    end 
    local _data = vipData[19] ----建筑升级需要的VIP
    local key = nil
    local i = 0
    for i = 1,17 do 
        key = "vip"..(i - 1)
        if _data and _data[key] and _data[key] > 0 then 
            _upOver = (i - 1)
            break   
        end         
    end 
    _data = vipData[20]---建筑加速需要的VIP
    for i = 1,17 do 
        key = "vip"..(i - 1)
        if _data and _data[key] and _data[key] > 0 then 
            _speed = (i - 1)
            break
        end         
    end 
    return _speed,_upOver
end
--
function ZhuChenglayer:reFreshFunctionRedPoint()
    --英雄红点
    local _herostate = RedPointManage:getHeroRedPointState()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "hero",["visible"] = _herostate}})
    --铁匠铺合成红点
    local _composeState = RedPointManage:getComposeRedPointState()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "tiejiangpu",["visible"] = _composeState}})

    -- 装备红点
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "equip"}})
    --修炼红点
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "baodian",["visible"] = gameUser.getbaodianGettingState()}})
end
----根据vip的可升级建筑数据来判断是否这还可以升级建筑
function ZhuChenglayer:canBuildingLevelUp( )
    if self._buildingsTable then 
        local amount = 0
        for k,v in pairs(self._buildingsTable) do 
            if v:getLevelUpState() > 0 then 
                amount = amount + 1
            end 
        end 
        if self._buildingAmountOfVIP then 
            local vip = gameUser.getVip()
            local limit = self._buildingAmountOfVIP["vip"..vip]
            if amount >= limit then 
                return false
            else 
                return true
            end 
        end 
    end 
    return false
end
------有新功能开启的时候箭头去新功能
function ZhuChenglayer:gotoNewFunction(data)
    self._isNewFunctionGuide = true
    if data.isBuild then 
        self._extraFuncID = data.funcData.cid
        self:pointToSpecifiedBuid(data.funcID)
    else 
        self._menuLayer:pointToSpecityMenu(data.funcID)
    end 
end

function ZhuChenglayer:removeDispatchEvent( )
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT)    
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_MAINCITY_INFO)
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_CITY_BUILDINGS)
    XTHD.removeEventListener(CUSTOM_EVENT.GOTO_SPECIFIEDBUILDING)    
    XTHD.removeEventListener(CUSTOM_EVENT.UPDATE_ACTIVITYMENUS)    
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_FUNCTION_REDPOINT)
    XTHD.removeEventListener(CUSTOM_EVENT.DISPLAY_BATTLEBEGINS_TIP)
    XTHD.removeEventListener(CUSTOM_EVENT.SHOW_BATTLE_TIPSLAYER)  
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_FUNCTION_BTNSHOW)  
end
-------第一次进来，缓慢前往种族
function ZhuChenglayer:first2MainCity()
    self._menuLayer:setVisible(false)
    YinDaoMarg:getInstance():getACover(self)

    local _color = cc.LayerColor:create(cc.c4b(0,0,0,255),self:getContentSize().width,self:getContentSize().height)
    self:addChild(_color,10,self.Tag.ktag_firstColorLayer)
    local time = 4.0
    local _in = cc.FadeOut:create(time)
    _color:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),_in,cc.CallFunc:create(function( )
        self:removeChildByTag(self.Tag.ktag_firstColorLayer)
        self:gotoSpecifiedBuild(5,nil,9.0) ----移到最右边
        performWithDelay(self,function( ) -----再移到中间
            self:gotoSpecifiedBuild(1,function( )
                YinDaoMarg:getInstance():removeCover(self)
                self._menuLayer:setVisible(true)
                YinDaoMarg:getInstance():doNextGuide()
            end,5.0)
        end,7)
    end)))
end

function ZhuChenglayer:addGuide( )
    local function removeCover( )
        YinDaoMarg:getInstance():removeCover(self)
    end
    local _group,index = YinDaoMarg:getInstance():getGuideSteps()
    print("'''''''''''''''''''''''''''''''''''the current group is ,step is",_group,index)
    if ((_group == 7 and index == 2) or (_group == 11 and index == 2) or (_group == 12 and index == 2) or (_group == 13 and index == 2) or (_group == 14 and index == 2)
         or (_group == 15 and index == 2) or (_group == 16 and index == 2) or (_group == 17 and index == 2) or (_group == 18 and index == 2)
         or (_group == 19 and index == 2) or (_group == 20 and index == 2)) then
        YinDaoMarg:getInstance():getACover(self)
        self:gotoSpecifiedBuild(1,removeCover,true)----演武场
        self:removeChildByName("_worldBossLayer") ----去掉世界boss的结算面板
    elseif (_group == 1 and index == 2) then     
        YinDaoMarg:getInstance():getACover(self)
        self:gotoSpecifiedBuild(2,removeCover,true)----七星坛
    elseif _group == 6 and index == 2 then 
        YinDaoMarg:getInstance():getACover(self)
        self:gotoSpecifiedBuild(5,removeCover,true)----铁匠铺
    elseif _group == 10 and index == 2 then 
        YinDaoMarg:getInstance():getACover(self)
        self:gotoSpecifiedBuild(9,removeCover,true)----领地战
    elseif _group == 14 and index == 2 then 
        YinDaoMarg:getInstance():getACover(self)
        self:gotoSpecifiedBuild(6,removeCover,true)----英雄榜
    end 

    self._menuLayer:addGuide()
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._buildingsTable[2], ----七星坛,
        index = 2,
        needNext = false,
        offset = cc.p(0,-50)
    },1)
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._buildingsTable[1], ----演武场,
        needNext = false,
    },{
        {12,2}, ---多人副本
        {13,2},----悬赏任务
        {14,2},----赏金猎人
        {15,2},----求签试练之塔
        {16,2},----天命骰子
        {18,2},----神器
        {19,2},----天兵阁
        {22,2},----押运粮草
    })
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self._buildingsTable[9], ----种族旗
        index = 2,
        needNext = false,
    },10)
    ---
    -- if not self._externalMark or self._externalMark.guide ~= true then
    YinDaoMarg:getInstance():doNextGuide()
    -- end
    self._menuLayer:guide2Fight()
end

function ZhuChenglayer:test( ) -----测试种族
    local time = 0
    if not globalID then 
        globalID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function( )
            time = time + 1
            if time % 10 == 0 then ----还有十分钟开启种族战        
                -- gameUser.setLimitBattle(1)
                -- XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_BATTLE_TIPSLAYER,data = "boss"})

                local _tem = {result = 1,strong = {{"中吕中中",10},{"中吕中中",20}},selfRank = 1,selfnum = 100}
                XTHD.dispatchEvent({name = CUSTOM_EVENT.SHOW_CAMPWARRESULT_DIALOG,data = _tem})
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(globalID)
                globalID = nil
            end 
            if time % 5 == 0 then 
                gameUser.setLimitBattle(0)
                -- cc.Director:getInstance():getScheduler():unscheduleScriptEntry(globalID)
                -- globalID = nil
                XTHD.dispatchEvent({name = CUSTOM_EVENT.DISPLAY_BATTLEBEGINS_TIP,data = {war = false}})
            end 
            print("the time is",time)
        end,1.0,false)
    end 
end
----------authored by LITAO---end---------------

return ZhuChenglayer