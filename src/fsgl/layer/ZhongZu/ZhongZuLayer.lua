--[[
Authored by LITAO
种族
]]
local ZhongZuLayer = class("ZhongZuLayer",function( )
	return XTHDDialog:create()
end)

function ZhongZuLayer:ctor(funcID,parent)
    self._parent = parent
    self.__gotoBattleCounter = 0
    self.__funcID = funcID
	self.__TDGlobalPowerBar = nil --天道盟总的势力点条
	self.__TDGlobalPowerBarPercent = nil
	self.__WJGlobalPowerBar = nil --无极营总的势力点条	
	self.__WJGlobalPowerBarPercent = nil
	self.__rewardList = nil ---底部的凭势力点可获得的奖励
    self.__campMainPanle = nil -- 种族的基础面板 
    self.__campFunctions = {} --种族里的功能面板，1 种族任务，2 种族奖励，3 种族商店，4 种族祭拜
    self.__campFunctionBtn = {} --种族里的功能按键 
    self._funcLayers = {}
    self.__campBattleTime = nil --种族战场面板上的种族开战时间 
    self.__currentFunctionIndex = 1 --当前所在功能的索引
    self.__isNeedRefresh = false
    self.__worshipTimesLabel = nil ---神兽膜拜次数    
    self._extraBg = nil ------种族在开战前、开战时、开战后的提示背景
    self._beginTimeBg = nil -----种族战开启时间的背景
    self._pushSceneCount = 0
    self._isBuyItem = false

    self.Tag = {
        ktag_campBeginTip = 100, 
    }

    self.__campTask = {---种族任务
        shiliPointLabel = nil, ---玩家为种族获得的势力点数的label
        shiliLabel = nil,--势力值后面的“势力值”label
        shiliPointBar = nil, ---势力点的进度条（带箱子的）    
        taskList = nil, --种族任务的列表    
        boxes = {},----箱子们
    }

    self.__campStore = {
        shiliPointLabel = nil ,
        shiliLabel = nil,
        honorLabel = nil,
        storeList = nil, -- 种族商店的列表
    }

    self.color = {
        tuHuang = cc.c3b(234,221,103),
        green = cc.c3b(52,255,106),
        darkBrown = cc.c3b(66,28,7),
        purple = cc.c3b(222,15,217),
        lightYellow = cc.c3b(207,100,17),
    }   
    XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_CAMPBASE,callback = function( )
        ZhongZuDatas.requestServerData({
            target = self,
            method = "campBase?",
            success = function( )
                self:showExtraTips()
                self:updateInforPowerBar()
                if self._parent then 
                    self._parent:updateInforPowerBar()
                end 
            end,
        })    
    end})
end

function ZhongZuLayer:create(funcID,parent)
    local camp = ZhongZuLayer.new(funcID,parent)
    if camp then 
        camp:init()
    end 
    return camp
end

function ZhongZuLayer:onEnter( )  
end

function ZhongZuLayer:onExit( )
end

function ZhongZuLayer:onCleanup( )
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_CAMPBASE)
end

function ZhongZuLayer:init()
    ZhongZuDatas.getLocalCampDatas()
    local selfSize = self:getContentSize()
    ---背景
    local bg = cc.Sprite:create("res/image/camp/camp_main_bg.png")
    self:addChild(bg)
	local size = cc.Director:getInstance():getWinSize()
	bg:setContentSize(size.width,size.height)
    bg:setPosition(selfSize.width / 2,selfSize.height / 2)
    -----动画 
    -- local _bgA = sp.SkeletonAnimation:create("res/image/camp/frames/zyz.json","res/image/camp/frames/zyz.atlas",1.0)
    -- bg:addChild(_bgA)
    -- _bgA:setTimeScale(0.2)
    -- _bgA:setPosition(bg:getContentSize().width / 2,bg:getContentSize().height / 2)
    -- _bgA:setAnimation(0,"animation",true)
    --看效果换成图片，两边的人物
    local leftHero = cc.Sprite:create("res/image/camp/lefthero.png")
    leftHero:setPosition(bg:getContentSize().width/5,bg:getContentSize().height / 2)
    leftHero:setScale(0.8)
    bg:addChild(leftHero)

    local rightHero = cc.Sprite:create("res/image/camp/righthero.png")
    rightHero:setPosition(bg:getContentSize().width*4/5-10,bg:getContentSize().height / 2)
    rightHero:setScale(0.7)
    bg:addChild(rightHero)
    ---返回按钮
    local close = XTHD.createNewBackBtn(function ()
        LayerManager.removeLayout()
    end)
    self:addChild(close)
    close:setPosition(selfSize.width, selfSize.height)
    --进度条
    local barBack = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading_bg_new2.png")
    self:addChild(barBack)
    barBack:setPosition(self:getContentSize().width / 2,self:getContentSize().height - 50)
    self.__progressBarbg = barBack
    ----左边种族图标    
    local _icon = cc.Sprite:create("res/image/camp/camp_circle_icon1.png")
    self:addChild(_icon)
    _icon:setAnchorPoint(1,0.5)
    _icon:setPosition(barBack:getPositionX() - barBack:getContentSize().width / 2 + 7,barBack:getPositionY() - 10)
    ----势力点文字
    local label = XTHDLabel:createWithParams({
        text = LANGUAGE_CAMP_SELF_POINT_PERCENT(0),
        fontSize = 16, 
        ttf = "res/fonts/def.ttf",               
    })
    self:addChild(label)
    label:enableOutline(cc.c4b(0,0,0,255),1)
    label:setAnchorPoint(0,0.5)
    label:setPosition(_icon:getPositionX() + 10,barBack:getPositionY() + barBack:getContentSize().height / 2 + label:getContentSize().height / 2)
    self.__TDGlobalPowerBarPercent = label
    ----右边种族图标
    _icon = cc.Sprite:create("res/image/camp/camp_circle_icon2.png")
    self:addChild(_icon)
    _icon:setAnchorPoint(0,0.5)
    _icon:setPosition(barBack:getPositionX() + barBack:getContentSize().width / 2 - 7,barBack:getPositionY() - 10)
    ----势力点文字     
    local label = XTHDLabel:createWithParams({
        text = LANGUAGE_CAMP_ENEMY_POINT_PERCENT(0),
        fontSize = 16, 
        color = cc.c3b(255,255,255), 
        ttf = "res/fonts/def.ttf",              
    })
    self:addChild(label)
    label:setAnchorPoint(1,0.5)
    label:enableOutline(cc.c4b(0,0,0,255),1)
    label:setPosition(_icon:getPositionX() - 10,barBack:getPositionY() + barBack:getContentSize().height / 2 + label:getContentSize().height / 2)
    self.__WJGlobalPowerBarPercent = label
    ----蓝进度条
    local blueBar = ccui.LoadingBar:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading_new2.png",50)
    barBack:addChild(blueBar)
    blueBar:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
    self.__TDGlobalPowerBar = blueBar
    ----红进度条
    local redBar = ccui.LoadingBar:create(IMAGE_KEY_CAMP_RES_PATH.."camp_loading_new1.png",50)
    barBack:addChild(redBar)
    redBar:setDirection(1) --设置从右到左
    redBar:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
    self.__WJGlobalPowerBar = redBar
    -----条上的动画
    local _barFlash = sp.SkeletonAnimation:create("res/image/camp/frames/dzt.json","res/image/camp/frames/dzt.atlas",1.0)
    if _barFlash then 
        barBack:addChild(_barFlash)
        _barFlash:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
        _barFlash:setAnimation(0,"animation",true)
    end 
    ----中间的VS
    _icon = cc.Sprite:create("res/image/camp/camp_VS.png")
    barBack:addChild(_icon)
    _icon:setScale(0.8)
    _icon:setPosition(barBack:getContentSize().width / 2,barBack:getContentSize().height / 2)
    self.__campVSIcon = _icon
    -- self.__campVSIcon:setAnchorPoint(0.5,0.5)
    ----开战时间背景 这里没改
    local _beganBg = ccui.Scale9Sprite:create("res/image/camp/camp_unknown_bg1.png")
    _beganBg:setContentSize(cc.size(631,40))
    self:addChild(_beganBg)
    _beganBg:setPosition(selfSize.width / 2,barBack:getPositionY() - barBack:getContentSize().height - 40)
    self._beginTimeBg = _beganBg
    -----中间的种族数据消息条
    self._extraBg = cc.Node:create()
    self:addChild(self._extraBg)
    self._extraBg:setAnchorPoint(0.5,0.5)
    local _bar = cc.Sprite:create("res/image/camp/camp_bg4.png")
    self._extraBg:addChild(_bar)
    self._extraBg:setContentSize(_bar:getContentSize())
    _bar:setPosition(self._extraBg:getContentSize().width / 2,self._extraBg:getContentSize().height / 2)
    self._extraBg:setPosition(self:getContentSize().width / 2 + 20,self:getContentSize().height / 2 + 15)
    self._extraBg.bg = _bar
   

    ----进种族战按钮
    local taiji = sp.SkeletonAnimation:create( "res/image/camp/frames/duijue_up.json", "res/image/camp/frames/duijue_up.atlas", 1.0)
     --看效果换成图片
    --  local taiji = ccui.Scale9Sprite:create("res/image/camp/taiji.png")
    self:addChild(taiji)  
    taiji:setScale(0.8) 
    taiji:setPosition(selfSize.width / 2,selfSize.height / 2)
    taiji:setAnimation(0,"duijue_up",true)

     --种族对决文字
     local zydj = cc.Sprite:create("res/image/camp/zudj.png")
     zydj:setPosition(taiji:getPositionX(),taiji:getPositionY()+zydj:getContentSize().height+50)
     zydj:setAnchorPoint(0.5,0)
     zydj:setScale(0.8)
     self:addChild(zydj)
   
    
    local goBattle = XTHDPushButton:createWithParams({
        musicFile = XTHD.resource.music.effect_btn_common,
    })
    self:addChild(goBattle)
    goBattle:setContentSize(cc.size(250,250))
    goBattle:setPosition(selfSize.width / 2,selfSize.height / 2)   
	goBattle:setTouchBeganCallback(function()
		taiji:setScale(0.78)
	end)

	goBattle:setTouchMovedCallback(function()
		taiji:setScale(0.8)
	end)
 
    goBattle:setTouchEndedCallback(function( )   
		taiji:setScale(0.8)  
        if self.__gotoBattleCounter == 0 then 
            self.__gotoBattleCounter = self.__gotoBattleCounter + 1
            -- taiji:setAnimation(0,"atk",true)
            performWithDelay(self,function( )
                YinDaoMarg:getInstance():guideTouchEnd()
                requires("src/fsgl/layer/ZhongZu/ZhongZuMap.lua"):create(self)
                -- taiji:setAnimation(0,"idle",true)
            end,0.5)
        end 
    end)
    self.goBattleBtn = goBattle
    self:addGuide()
    -----参与奖励
    local _joinTips = cc.Sprite:create("res/image/camp/camp_join_tips.png")
    self:addChild(_joinTips)
    _joinTips:setAnchorPoint(0,0.5)
    ---元宝
    local gold = XTHD.createHeaderIcon(ZhongZuDatas._localReward[1].rewardItemType)
    self:addChild(gold)
    gold:setAnchorPoint(0,0.5)
    --数量
    local amount = cc.Label:createWithBMFont("res/image/common/common_num/1.fnt",ZhongZuDatas._localReward[1].rewardAmoun)
    self:addChild(amount)
    amount:setAnchorPoint(0,0.5)

    local x = (self:getContentSize().width - _joinTips:getBoundingBox().width - gold:getBoundingBox().width - amount:getBoundingBox().width) / 2
    _joinTips:setPosition(x,selfSize.height * 1/3 - 50)
    gold:setPosition(_joinTips:getPositionX() + _joinTips:getBoundingBox().width,_joinTips:getPositionY())
    amount:setPosition(gold:getBoundingBox().width + gold:getPositionX(),gold:getPositionY() - 5)

    --特效
    local texiao = sp.SkeletonAnimation:create("res/image/camp/frames/duijue_down.json","res/image/camp/frames/duijue_down.atlas",1.0)
    texiao:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
    texiao:setAnimation(0,"duijue_down",true)
	texiao:setContentSize(size)
--    texiao:setScale(0.8)
    self:addChild(texiao)


    self:updateInforPowerBar()
    self:showExtraTips()
end 
---更新种族信息面板的进度条
function ZhongZuLayer:updateInforPowerBar( )
    if self.__TDGlobalPowerBar and self.__WJGlobalPowerBar and ZhongZuDatas._serverBasic and self.__TDGlobalPowerBarPercent and self.__WJGlobalPowerBarPercent then 
        local all = tonumber(ZhongZuDatas._serverBasic.aForce) + tonumber(ZhongZuDatas._serverBasic.bForce)
        local percent = tonumber(ZhongZuDatas._serverBasic.aForce) / all * 100
        percent = percent > 0 and percent or 0
        self.__TDGlobalPowerBar:setPercent(percent)
        if self.__progressBarbg and self.__campVSIcon then 
            local x,y = self.__campVSIcon:getPosition()
            local vs_x = self.__progressBarbg:getBoundingBox().width * percent / 100
            self.__campVSIcon:setPosition(vs_x-15,y) 
        end 
        percent = math.ceil(percent)
        self.__TDGlobalPowerBarPercent:setString(LANGUAGE_CAMP_SELF_POINT_PERCENT(percent))

        percent = tonumber(ZhongZuDatas._serverBasic.bForce) / all * 100
        percent = percent > 0 and percent or 0
        self.__WJGlobalPowerBar:setPercent(percent)
        percent = math.floor(percent)
        self.__WJGlobalPowerBarPercent:setString(LANGUAGE_CAMP_ENEMY_POINT_PERCENT(percent))
    end 
end


-----显示种族在开战前、开战时、开战后的提示
function ZhongZuLayer:showExtraTips( )
    if self._extraBg and ZhongZuDatas._serverBasic and self._beginTimeBg then 
        self._beginTimeBg:removeAllChildren()
        local content = cc.Node:create()
        if self._extraBg.bg and content then 
            self._extraBg:removeChildByTag(self.Tag.ktag_campBeginTip)
            content:setAnchorPoint(0.5,0.5)
            content:setPosition(self._extraBg:getContentSize().width / 2,self._extraBg:getContentSize().height / 2)
            self._extraBg:addChild(content,1,self.Tag.ktag_campBeginTip)
        end 
        if ZhongZuDatas._serverBasic.openState == 0 then -----种族战未开启
            if ZhongZuDatas._serverBasic.dayBetween == 0 then -----今天才结束的种族战
                -----文字提示
                if ZhongZuDatas._serverBasic.successCampId == 0 then 
                    local _word = cc.Sprite:create("res/image/camp/camp_label9.png") -----种族战已开启提示字
                    self._beginTimeBg:addChild(_word)
                    _word:setPosition(self._beginTimeBg:getContentSize().width / 2,self._beginTimeBg:getContentSize().height / 2)
                else 
                    -----文字提示
                    local _word = cc.Sprite:create("res/image/camp/camp_label8.png") -----本次种族战已结束，恭喜。。。。
                    _word:setAnchorPoint(0,0.5)
                    self._beginTimeBg:addChild(_word)
                    local _name = cc.Sprite:create("res/image/camp/camp_name"..ZhongZuDatas._serverBasic.successCampId..".png")
                    _name:setAnchorPoint(0,0.5)
                    self._beginTimeBg:addChild(_name)
                    local _last = cc.Sprite:create("res/image/camp/camp_victory_word.png")
                    _last:setAnchorPoint(0,0.5)
                    self._beginTimeBg:addChild(_last)
                    local x = _word:getContentSize().width + _name:getContentSize().width + _last:getContentSize().width
                    x = (self._beginTimeBg:getContentSize().width - x) / 2
                    _word:setPosition(x,self._beginTimeBg:getContentSize().height / 2)
                    _name:setPosition(_word:getPositionX() + _word:getContentSize().width,_word:getPositionY())
                    _last:setPosition(_name:getPositionX() + _name:getContentSize().width,_name:getPositionY())
                end 
                if #ZhongZuDatas._serverBasic.aTop3 > 0 or #ZhongZuDatas._serverBasic.bTop3 > 0 then 
                    self._extraBg.bg:setVisible(true)
                    ---------
                    content:setContentSize(cc.size(self._extraBg.bg:getBoundingBox().width,self._extraBg.bg:getBoundingBox().height))
                    ------左种族
                    local campName = cc.Sprite:create("res/image/camp/camp_label3.png")
                    campName:setAnchorPoint(0.5,1)
                    content:addChild(campName)
                    campName:setPosition(content:getContentSize().width * 1/4 + 50,content:getContentSize().height - 30)
                    local y = campName:getPositionY() - campName:getContentSize().height - 10
                    for i = 1,#ZhongZuDatas._serverBasic.aTop3 do 
                        local _name = XTHDLabel:createWithSystemFont(string.format("%d.%s",i,ZhongZuDatas._serverBasic.aTop3[i]),XTHD.SystemFont,20)
                        _name:setAnchorPoint(0.5,1)
                        content:addChild(_name)
                        _name:setPosition(campName:getPositionX() ,y)
                        y = y - _name:getContentSize().height - 10
                    end 
                    ------右种族
                    campName = cc.Sprite:create("res/image/camp/camp_label4.png")
                    campName:setAnchorPoint(0.5,1)
                    content:addChild(campName)
                    campName:setPosition(content:getContentSize().width * 3/4 - 35,content:getContentSize().height - 30)
                    y = campName:getPositionY() - campName:getContentSize().height - 10
                    for i = 1,#ZhongZuDatas._serverBasic.bTop3 do
                        local _name = XTHDLabel:createWithSystemFont(string.format("%d.%s",i,ZhongZuDatas._serverBasic.bTop3[i]),XTHD.SystemFont,20)
                        _name:setAnchorPoint(0.5,1)
                        content:addChild(_name)
                        _name:setPosition(campName:getPositionX() ,y)
                        y = y - _name:getContentSize().height - 10
                    end 
                else 
                    self._extraBg.bg:setVisible(false)                    
                end 
            else 
                ----时间
                local beginTime = tostring(ZhongZuDatas._serverBasic.beginTime)
                beginTime = string.sub(beginTime,1,#beginTime - 3)
                local endTime = tostring(ZhongZuDatas._serverBasic.endTime)
                endTime = string.sub(endTime,1,#endTime - 3)
                local _time1 = os.date("%m.%d",beginTime)
                local _time2 = os.date("%H:%M",beginTime)
                endTime = os.date("%H:%M",endTime)
                local _timeFont = cc.Label:createWithBMFont("res/image/common/common_num/yellowwordforcamp.fnt",LANGUAGE_TIME_FORMAT5(_time1,_time2,endTime))
                ----开战时间字
                local _beganTips = cc.Sprite:create("res/image/camp/camp_begin_tips.png")
                self._beginTimeBg:addChild(_beganTips)
                _beganTips:setAnchorPoint(0,0.5)
                _beganTips:setPosition((self._beginTimeBg:getBoundingBox().width - _timeFont:getBoundingBox().width - _beganTips:getContentSize().width) / 2,self._beginTimeBg:getBoundingBox().height / 2)

                _timeFont:setAnchorPoint(0,0.5)
                self._beginTimeBg:addChild(_timeFont)
                _timeFont:setPosition(_beganTips:getPositionX() + _beganTips:getContentSize().width,self._beginTimeBg:getBoundingBox().height / 2 - 4)
                _timeFont:setAdditionalKerning(-2)                
                ---------
                if ZhongZuDatas._serverBasic.bTop3[1] and ZhongZuDatas._serverBasic.aTop3[1] then 
                    self._extraBg.bg:setVisible(true)
                    self._extraBg.bg:setScaleY(132 / self._extraBg.bg:getContentSize().height)
                    content:setContentSize(cc.size(self._extraBg.bg:getBoundingBox().width,self._extraBg.bg:getBoundingBox().height))
                    ------左种族
                    local campName = cc.Sprite:create("res/image/camp/camp_label5.png")
                    campName:setAnchorPoint(0.5,0)
                    content:addChild(campName)
                    local _name = XTHDLabel:createWithSystemFont(ZhongZuDatas._serverBasic.aTop3[1] or "",XTHD.SystemFont,26)
                    _name:setAnchorPoint(0.5,0)
                    content:addChild(_name)
                    local y = campName:getContentSize().height + _name:getContentSize().height + 15
                    y = (content:getContentSize().height - y) / 2
                    _name:setPosition(content:getContentSize().width * 1/4 + 50 ,y)
                    campName:setPosition(_name:getPositionX(),y + 15 + _name:getContentSize().height)
                    ------右种族
                    campName = cc.Sprite:create("res/image/camp/camp_label6.png")
                    campName:setAnchorPoint(0.5,0)
                    content:addChild(campName)
                    _name = XTHDLabel:createWithSystemFont(ZhongZuDatas._serverBasic.bTop3[1] or "",XTHD.SystemFont,26)
                    _name:setAnchorPoint(0.5,0)
                    content:addChild(_name)
                    y = campName:getContentSize().height + _name:getContentSize().height + 15
                    y = (content:getContentSize().height - y) / 2
                    _name:setPosition(content:getContentSize().width * 3/4 - 35,y)
                    campName:setPosition(_name:getPositionX(),y + _name:getContentSize().height + 15)
                else 
                    self._extraBg.bg:setVisible(false)
                end 
            end 
        else ----开战
            -----文字提示
            local _word = cc.Sprite:create("res/image/camp/camp_label7.png") -----种族战已开启提示字
            self._beginTimeBg:addChild(_word)
            _word:setPosition(self._beginTimeBg:getContentSize().width / 2,self._beginTimeBg:getContentSize().height / 2)
            --------两种族参战人数
            self._extraBg.bg:setScaleY(132 / self._extraBg.bg:getContentSize().height)
            content:setContentSize(cc.size(self._extraBg.bg:getBoundingBox().width,self._extraBg.bg:getBoundingBox().height))
            -------左种族
            --光明谷参战人数
            local campName = cc.Sprite:create("res/image/camp/camp_label1.png")
            campName:setAnchorPoint(0.5,0)
            local number = cc.Label:createWithBMFont("res/fonts/blueword.fnt",(ZhongZuDatas._serverBasic.aPlayerCount or 0))
            number:setAdditionalKerning(-2)
            number:setAnchorPoint(0.5,0)

            content:addChild(campName)
            content:addChild(number)
            local y = campName:getContentSize().height + number:getContentSize().height + 10
            y = (content:getContentSize().height - y) / 2
            number:setPosition(content:getContentSize().width * 1/4 + 50,y)
            campName:setPosition(number:getPositionX(),y + number:getContentSize().height + 10)
            ------右种族
            campName = cc.Sprite:create("res/image/camp/camp_label2.png")
            campName:setAnchorPoint(0.5,0)
            number = cc.Label:createWithBMFont("res/fonts/campbegin.fnt",(ZhongZuDatas._serverBasic.bPlayerCount or 0))
            number:setAdditionalKerning(-2)
            number:setAnchorPoint(0.5,0)

            content:addChild(campName)
            content:addChild(number)
            y = campName:getContentSize().height + number:getContentSize().height + 10
            y = (content:getContentSize().height - y) / 2
            number:setPosition(content:getContentSize().width * 3/4 - 35,y)
            campName:setPosition(number:getPositionX(),y + number:getContentSize().height + 10)
        end 
    end     
end

function ZhongZuLayer:addGuide( )
    YinDaoMarg:getInstance():addGuide({
        parent = self,
        target = self.goBattleBtn, -----点击开战按钮
        index = 4,
    },25)
    YinDaoMarg:getInstance():doNextGuide()    
end

return ZhongZuLayer