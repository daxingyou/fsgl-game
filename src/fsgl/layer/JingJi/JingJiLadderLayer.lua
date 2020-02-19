--排位
local JingJiLadderLayer = class("JingJiLadderLayer",function ()
    return XTHD.createBasePageLayer({ZOrder = 0})
end)

function JingJiLadderLayer:ctor(data,list,parent)
	self._parent = parent
    self._data = {}
	self._petList = list
    self._data.rivals = {}
	self._heroNode = {}
    local _data = gameData.getDataFromCSV("GeneralInfoList")
    self:initUI(data)
    -- ZCLOG(data)
    self:refreshList(data)
    XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_PVP_LADDER_LAYER,
        callback = function (event)
            XTHDHttp:requestAsyncInGameWithParams({
                modules="orderListRequest?",
                -- params = {method="strongRequest?"},
                successCallback = function(data)
                    if tonumber(data.result) == 0 then
                        -- ZCLOG(data)
                        self:refreshList(data)
                    elseif tonumber(data.result) == 2000 then
                        XTHD.createExchangePop(3)
                    elseif tonumber(data.result) == 2007 then
                        XTHDTOAST(LANGUAGE_TIPS_WORDS20)-----"精力不足！")
                    else
                        XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
                    end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败!")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingParent = self,
                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
        end
    })
end

function JingJiLadderLayer:onCleanup()
    XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_PVP_LADDER_LAYER)
end

function JingJiLadderLayer:onEnter( )
    YinDaoMarg:getInstance():addGuide({index = 9,parent = self},2)
    YinDaoMarg:getInstance():doNextGuide()    
end

function JingJiLadderLayer:refreshList(data)
	local list ={}
	for k,v in pairs(data.rivals) do
		if v.charId ~= gameUser.getUserId() then
			list[#list + 1] = v
		end
	end

	data.rivals = list

    table.sort(data.rivals,function(a,b)
        return tonumber(a.rank) < tonumber(b.rank)
    end)
    self._data = data
    self._ladderTable:reloadDataAndScrollToCurrentCell()
    for i=1,#data.rivals do
        if data.rivals[i].charId == gameUser.getUserId() then
            self.scrollIdx = i-3
            if self.scrollIdx < 0 then
                self.scrollIdx = 0
            end
            break
        end
    end
    if self.scrollIdx then
        self._ladderTable:scrollToCell(self.scrollIdx)
    end

    if self.topSwallowBtn then
        self.topSwallowBtn:removeFromParent()
    end
    self.topSwallowBtn = XTHDPushButton:createWithParams({
        touchSize = self._ceilbg:getContentSize()
    })
    self.topSwallowBtn:setContentSize(self._ceilbg:getContentSize())
    self.topSwallowBtn:setPosition(self._ceilbg:getContentSize().width/2,self._ceilbg:getContentSize().height/2)
    self._ceilbg:addChild(self.topSwallowBtn)
    local rankLight = cc.Sprite:create("res/image/plugin/competitive_layer/light_bg.png")
    rankLight:setPosition(50,self.topSwallowBtn:getContentSize().height/2)
    self.topSwallowBtn:addChild(rankLight)
    rankLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(3,360)))

    local rankIcon = XTHDPushButton:createWithParams({
                musicFile = XTHD.resource.music.effect_btn_common,
                normalFile = "res/image/common/rank_icon/rankIcon_"..gameUser.getDuanId()..".png",
                selectedFile ="res/image/common/rank_icon/rankIcon_"..gameUser.getDuanId()..".png",
            })
    rankIcon:setPosition(50,self.topSwallowBtn:getContentSize().height/2)
    rankIcon:setScale( 50/rankIcon:getContentSize().width )
    rankIcon:setTouchEndedCallback(function (  )
        local layer = require( "src/fsgl/layer/ZhuCheng/DuanWeiInfoLayer.lua" ):create()
        LayerManager.addLayout( layer )
    end)
    self.topSwallowBtn:addChild(rankIcon)

    self.rankData = gameData.getDataFromCSV("CompetitiveDaily")

    if gameUser.getDuanId() < 7 then
        if data.rank > self.rankData[gameUser.getDuanId()].up then
            local rankBefore = XTHDLabel:createWithParams({  --前xx名可获得晋级资格 ,英文版需要修改 by andong
                text = LANGUAGE_UNKNOWN.front,------"前",
                fontSize = 20,
                color = XTHD.resource.color.brown_desc
            })
            rankBefore:setPosition(rankIcon:getPositionX()+rankIcon:getBoundingBox().width/2+20,rankIcon:getPositionY())
            self.topSwallowBtn:addChild(rankBefore)

            local rankNeed = XTHDLabel:createWithParams({
                text = self.rankData[gameUser.getDuanId()].up,
                fontSize = 22,
                color = cc.c3b(104,157,0),
            })
            rankNeed:setAnchorPoint(0,0.5)
            rankNeed:setPosition(rankBefore:getPositionX()+rankBefore:getBoundingBox().width/2,rankBefore:getPositionY())
            self.topSwallowBtn:addChild(rankNeed)

            local rankAfter = XTHDLabel:createWithParams({
                text = LANGUAGE_TIPS_WORDS30,----- "名可获得晋级资格",
                fontSize = 20,
                color = cc.c3b(117,76,30)
            })
            rankAfter:setAnchorPoint(0,0.5)
            rankAfter:setPosition(rankNeed:getPositionX()+rankNeed:getBoundingBox().width,rankNeed:getPositionY())
            self.topSwallowBtn:addChild(rankAfter)
            rankLight:setOpacity(0)
        else
			local rankForward = XTHDLabel:createWithParams({
                text = LANGUAGE_TIPS_WORDS31,-------- "你已获得晋级资格",
                fontSize = 20,
                color = XTHD.resource.color.brown_desc
            })
            rankForward:setAnchorPoint(0,0.5)
            rankForward:setPosition(rankIcon:getPositionX()+rankIcon:getBoundingBox().width,rankIcon:getPositionY())
            self.topSwallowBtn:addChild(rankForward)

            local rankForwardBtn = XTHD.createButton({
				normalFile = "res/image/rankGame/jinji_up.png",
				selectedFile = "res/image/rankGame/jinji_down.png",
                musicFile = XTHD.resource.music.effect_btn_common,
                isScrollView = false,
            })
            rankForwardBtn:setAnchorPoint(0.5,0.5)
            rankForwardBtn:setPosition(self.topSwallowBtn:getContentSize().width - rankForwardBtn:getContentSize().width*2 - 10,self.topSwallowBtn:getContentSize().height *0.5)
            self.topSwallowBtn:addChild(rankForwardBtn)
            rankLight:setOpacity(255)
            rankForwardBtn:setTouchEndedCallback(function ()
				self:JinjiCallFunc()
            end)
        end
    end
	self.rankNum:setString(tostring(data.rank))
    self.ladderCountNum:setString(data.orderLeftCount)
    self.ladderCountNum.num = data.orderLeftCount
   -- self.awardNum:setString(gameUser.getAward())
    self.cdNum:setString(getCdStringWithNumber(data.coolTime))
    self.cdNum.cd = data.coolTime
    self:doCountDown(self.cdNum)

end

function JingJiLadderLayer:doCountDown(node)
    node:stopAllActions()
    node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function ()
        if node.cd <= 0 then
            node:stopAllActions()
            node:setString("")
            self.noTime:setVisible(true)
        else
            self.noTime:setVisible(false)
            node:setString(getCdStringWithNumber(node.cd,{h = ":"}))
            node.cd = node.cd - 1
        end
    end),cc.DelayTime:create(1))))
end

function JingJiLadderLayer:initUI(data)    
    -- local noticBg = self:getChildByName("_notic_bg")
    -- 背景
    local bottomBg = XTHD.createSprite( "res/image/rankGame/bg.png" )
    bottomBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    bottomBg:setPosition( self:getBoundingBox().width * 0.5, ( self:getBoundingBox().height - self.topBarHeight ) * 0.5-5 )
	self._bg = bottomBg
    self:addChild( bottomBg )

	--self._petList
	local heroList = {}
	for k, v in pairs(DBTableHero.DBData) do
		for i = 1,#self._petList do
			if self._petList[i] == v.heroid then
				heroList[#heroList +1] = v
			end
		end
	end

	table.sort(heroList,function(a,b)
		return a.power > b.power
	end)

	local _strid = string.format("%03d", heroList[1].heroid)
	local hero = XTHDTouchSpine:create(heroList[1].petId, "res/spine/" .. _strid .. ".skel", "res/spine/" .. _strid .. ".atlas", 1)
    hero:setAnimation(0, "idle", true)
	self._bg:addChild(hero)
	hero:setPosition(170,self._bg:getContentSize().height*0.5 - 80)

	local nameLable = XTHDLabel:create(gameUser.getNickname(),20,"res/fonts/def.ttf")
	nameLable:setColor(cc.c3b(0,0,0))
	self._bg:addChild(nameLable)
	nameLable:setPosition(hero:getPositionX() - 10,self._bg:getContentSize().height - nameLable:getContentSize().height *0.5 - 50)

	local m_infobg = cc.Sprite:create("res/image/rankGame/bg_2.png")
	bottomBg:addChild(m_infobg)
	m_infobg:setPosition(m_infobg:getContentSize().width *0.5 + 26,m_infobg:getContentSize().height *0.5 + 25)
	self._m_infobg = m_infobg

	local m_rank = XTHDLabel:create("我的排名：",20,"res/fonts/def.ttf")
	m_infobg:addChild(m_rank)
	m_rank:setAnchorPoint(0,0.5)
	m_rank:setPosition(35,m_infobg:getContentSize().height - m_rank:getContentSize().height - 10)

	local battleCdBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png" )
    battleCdBg:setContentSize( 85, 25 )
    battleCdBg:setAnchorPoint(0,0.5)
	m_infobg:addChild(battleCdBg)
	battleCdBg:setPosition(m_rank:getPositionX() + m_rank:getContentSize().width - 10,m_rank:getPositionY())

	local rank = XTHDLabel:create(tostring(data.rank),18,"res/fonts/def.ttf")
	battleCdBg:addChild(rank)
	rank:setAnchorPoint(0.5,0.5)
	rank:setPosition(battleCdBg:getContentSize().width*0.5,battleCdBg:getContentSize().height*0.5)
	self.rankNum = rank

	local ruanwiList = {"青铜组","白银组","黄金组","白金组","钻石组","至尊组","王者组"}
	local duanweiLable = XTHDLabel:create(ruanwiList[data.duan],18,"res/fonts/def.ttf")
	duanweiLable:setColor(cc.c3b(246,214,1))
	duanweiLable:setAnchorPoint(0,0.5)
	m_infobg:addChild(duanweiLable)
	duanweiLable:setPosition(battleCdBg:getContentSize().width + battleCdBg:getPositionX() + 10,battleCdBg:getPositionY())
	
	--挑战次数
	local m_time = XTHDLabel:create("挑战次数：",20,"res/fonts/def.ttf")
	m_infobg:addChild(m_time)
	m_time:setAnchorPoint(0,0.5)
	m_time:setPosition(35,m_rank:getPositionY() - m_rank:getContentSize().height - 5)

	local battleCdBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png" )
    battleCdBg:setContentSize( 85, 25 )
    battleCdBg:setAnchorPoint(0,0.5)
	m_infobg:addChild(battleCdBg)
	battleCdBg:setPosition(m_time:getPositionX() + m_time:getContentSize().width - 10,m_time:getPositionY())	

	local ladderCountNum = XTHD.createLabel({
        fontSize = 18,
        color = cc.c3b(255,255,255),
    })
	ladderCountNum:setAnchorPoint(0.5,0.5)
    ladderCountNum:setPosition(battleCdBg:getContentSize().width*0.5,battleCdBg:getContentSize().height*0.5)
    battleCdBg:addChild(ladderCountNum)
    self.ladderCountNum = ladderCountNum
	
	local m_cdTime = XTHDLabel:create("冷却时间：",20,"res/fonts/def.ttf")
	m_infobg:addChild(m_cdTime)
	m_cdTime:setAnchorPoint(0,0.5)
	m_cdTime:setPosition(35,m_time:getPositionY() - m_time:getContentSize().height - 5)

	local battleCdBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png" )
    battleCdBg:setContentSize( 85, 25 )
    battleCdBg:setAnchorPoint(0,0.5)
	m_infobg:addChild(battleCdBg)
	battleCdBg:setPosition(m_cdTime:getPositionX() + m_cdTime:getContentSize().width - 10,m_cdTime:getPositionY())

	local cdNum = XTHD.createLabel({
        fontSize = 18,
        color = cc.c3b(255,255,255),
    })
	cdNum:setAnchorPoint(0.5,0.5)
    cdNum:setPosition(battleCdBg:getContentSize().width *0.5,battleCdBg:getContentSize().height*0.5)
    battleCdBg:addChild(cdNum)
    self.cdNum = cdNum

	local battleCdBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png" )
  battleCdBg:setContentSize( 85, 25 )
  battleCdBg:setAnchorPoint(0,0.5)
	m_infobg:addChild(battleCdBg)
	battleCdBg:setPosition(m_cdTime:getPositionX() + m_cdTime:getContentSize().width - 10,m_cdTime:getPositionY())

  local robberyTimePlus = XTHDPushButton:createWithParams({
       musicFile = XTHD.resource.music.effect_btn_common,
       normalFile = "res/image/common/btn/btn_addDot_normal.png",
       selectedFile = "res/image/common/btn/btn_addDot_selected.png",
   })
   robberyTimePlus:setPosition(m_time:getPositionX()+m_time:getBoundingBox().width + 90,m_time:getPositionY())
   m_infobg:addChild(robberyTimePlus)
   robberyTimePlus:setScale(0.6)
   self.robberyTimePlus = robberyTimePlus
   self.ladderInfo = gameData.getDataFromCSV("VipInfo",{id = 21})["vip"..gameUser.getVip()] or 0

   local cleanCDBtn = XTHDPushButton:createWithParams({
       musicFile = XTHD.resource.music.effect_btn_common,
       normalFile = "res/image/common/btn/btn_cleanDot_normal.png",
       selectedFile = "res/image/common/btn/btn_cleanDot_selected.png"
   })
   cleanCDBtn:setPosition(battleCdBg:getBoundingBox().width + 15,battleCdBg:getBoundingBox().height/2)
   battleCdBg:addChild(cleanCDBtn)
   self.cleanCDBtn = cleanCDBtn
   cleanCDBtn:setScale(0.6)

     --购买挑战次数按钮回调
   self.robberyTimePlus:setTouchEndedCallback(function ()
       local byConfirmLayer = XTHDConfirmDialog:createWithParams( {
           rightText = LANGUAGE_BTN_KEY.goumai,
           isHide = false,
       })

       local contain = byConfirmLayer:getContainer()

       local title_txt  = XTHDLabel:create("购买次数",26,"res/fonts/def.ttf")
       title_txt:setPosition(contain:getBoundingBox().width/2,250)
       title_txt:setColor(cc.c3b(55,54,112))
       contain:addChild(title_txt)

       local str1 = XTHDLabel:createWithParams({
           text = LANGUAGE_TIPS_WORDS242,
           fontSize = 18,
           color = XTHD.resource.color.gray_desc
       })
       str1:setAnchorPoint(0,0.5)

       local ingotIcon = XTHD.createHeaderIcon(XTHD.resource.type.ingot)
       ingotIcon:setAnchorPoint(0,0.5)

       local str2 = XTHDLabel:createWithParams({
           text = LANGUAGE_TIPS_BUYCHALLENGETIMES(50*(data.orderBuyCount+1)),
           fontSize = 18,
           color = XTHD.resource.color.gray_desc
       })
       str2:setAnchorPoint(0,0.5)

       str1:setPosition((contain:getBoundingBox().width-(str1:getBoundingBox().width+ingotIcon:getBoundingBox().width+str2:getBoundingBox().width))/2,180)
       contain:addChild(str1)

       ingotIcon:setPosition(str1:getPositionX()+str1:getBoundingBox().width,str1:getPositionY())
       contain:addChild(ingotIcon)

       str2:setPosition(ingotIcon:getPositionX()+ingotIcon:getBoundingBox().width,ingotIcon:getPositionY())
       contain:addChild(str2)

       local leftTime = XTHDLabel:createWithParams({
           text = LANGUAGE_TIPS_LASTBUYTIMES(self.ladderInfo-data.orderBuyCount),
           fontSize = 18,
           color = XTHD.resource.color.gray_desc
       })
       leftTime:setPosition(contain:getBoundingBox().width/2,130)
       contain:addChild(leftTime)

       byConfirmLayer:setCallbackRight(function ()
           XTHDHttp:requestAsyncInGameWithParams({
               modules="buyOrderCount?",
               -- params = {method="strongRequest?"},
               successCallback = function(net)
                   if tonumber(net.result) == 0 then
                       XTHDTOAST(LANGUAGE_TIP_SUCCESS_TO_BUY)-----"购买成功")
                       gameUser.setIngot(net.ingot)
                       XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                       self.ladderCountNum:setString(net.orderLeftCount)
                       self.ladderCountNum.num = net.orderLeftCount
                       data.orderBuyCount = data.orderBuyCount + 1
                       leftTime:setString(LANGUAGE_TIPS_LASTBUYTIMES(self.ladderInfo-data.orderBuyCount))
                       str2:setString( LANGUAGE_TIPS_BUYCHALLENGETIMES(50*(data.orderBuyCount+1)) )
                     XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RECHARGE_HUOYUEJIANGLI})
                   elseif tonumber(net.result) == 2000 then
                       XTHD.createExchangePop(3)
                   else
                       XTHDTOAST(net.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
                   end
               end,--成功回调
               failedCallback = function()
                   XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
               end,--失败回调
               targetNeedsToRetain = self,--需要保存引用的目标
               loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
           })
       end)
       byConfirmLayer:setCallbackLeft(function ()
           byConfirmLayer:hide()
       end)

       self:addChild(byConfirmLayer)
   end)

   --购买冷却时间按钮回调
   self.cleanCDBtn:setTouchEndedCallback(function ()
       if self.cdNum.cd == 0 then
           XTHDTOAST(LANGUAGE_TIPS_WORDS33)-----"当前无冷却时间！")
           return
       end
       local byConfirmLayer = XTHDConfirmDialog:createWithParams( {
           rightText = LANGUAGE_BTN_KEY.goumai,
           rightCallback = function ()
               XTHDHttp:requestAsyncInGameWithParams({
                   modules="clearCoolTime?",
                   successCallback = function(data)
                       if tonumber(data.result) == 0 then
                           XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PVP_LADDER_LAYER})
                           gameUser.setIngot(data.ingot)
                           XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                           -- self.ladderCountNum:setString(data.orderLeftCount)
                       elseif tonumber(data.result) == 2000 then
                           XTHD.createExchangePop(3)
                       else
                           XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)------"网络请求失败!")
                       end
                   end,--成功回调
                   failedCallback = function()
                       XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
                   end,--失败回调
                   targetNeedsToRetain = self,--需要保存引用的目标
                   loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
               })
           end,
       })
       local contain = byConfirmLayer:getContainer()
       local msgStr = "<color=#462222 fontSize=18 >"..LANGUAGE_KEY_HERO_TEXT.buySkillpointOneTextXc.."<img="..IMAGE_KEY_HEADER_INGOT.." /></color><color=#462222 fontSize=18>"..(15*math.ceil(self.cdNum.cd/60))..LANGUAGE_FORMAT_TIPS8.."</color>"
       local labelContent = RichLabel:createARichText(msgStr,false)
       labelContent:setAnchorPoint(0.5,0.5)
       labelContent:setPosition(contain:getBoundingBox().width/2,contain:getBoundingBox().height/2+40)
       contain:addChild(labelContent)

       self:addChild(byConfirmLayer)
   end)

	self.noTime = XTHD.createLabel({
        text = LANGUAGE_UNKNOWN.none,
        fontSize = 18,
        color = cc.c3b(255,255,255),
    })
	self.noTime:setAnchorPoint(0.5,0.5)
    self.noTime:setPosition(cdNum:getPosition())
    battleCdBg:addChild(self.noTime)
    self.noTime:setVisible(false)

	local settingduiwu = XTHDPushButton:createWithParams({
		normalFile = "res/image/rankGame/fangshou_up.png",
		selectedFile = "res/image/rankGame/fangshou_down.png",
	})
	m_infobg:addChild(settingduiwu)
	settingduiwu:setPosition(m_infobg:getContentSize().width * 0.5 - settingduiwu:getContentSize().width - 25,m_infobg:getContentSize().height *0.5)
	settingduiwu:setTouchEndedCallback(function()
		if not XTHD.getUnlockStatus( 17, true ) then
			return
		end
		local PVPTeamPop = requires("src/fsgl/layer/JingJi/JingJiTeamPop.lua"):create(self._petList,3,self)
		self:addChild(PVPTeamPop)
		PVPTeamPop:show()
	end)

	self:createMyOrderTeams()

    local bg = XTHD.createSprite()
    bg:setContentSize(cc.size(self._bg:getContentSize().width,450))
    bg:setPosition(self._bg:getContentSize().width/2,(self._bg:getContentSize().height - self.topBarHeight)*0.5 )--noticBg:getPositionY()/2
    self._bg:addChild(bg)

    local topSp = cc.Sprite:create()
    topSp:setContentSize( self._bg:getBoundingBox().width - 40, 45 )
    topSp:setAnchorPoint(0.5,1)
    topSp:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height + 10)
    bg:addChild(topSp,1)
    self.topSp = topSp

	local ceilbg = cc.Sprite:create("res/image/rankGame/bg_3.png")
	self._bg:addChild(ceilbg)
	ceilbg:setAnchorPoint(1,0.5)
	ceilbg:setPosition(self._bg:getContentSize().width - 35,self._bg:getContentSize().height - ceilbg:getContentSize().height *0.5 - 25)
	self._ceilbg = ceilbg

    --按钮查看记录
    local checkBtn =  XTHD.createButton({
		normalFile = "res/image/rankGame/report_up.png",
		selectedFile = "res/image/rankGame/report_down.png",
        isScrollView = false,
        musicFile = XTHD.resource.music.effect_btn_common,
    })
    checkBtn:setPosition(ceilbg:getContentSize().width - checkBtn:getContentSize().width *0.5 - 30,ceilbg:getContentSize().height *0.5)
    ceilbg:addChild(checkBtn,1)

    checkBtn:setTouchEndedCallback(function ()
		self:BattleReport()
    end)

	-- 排行榜奖励
    local rankListRewardBtn = XTHD.createButton({
		normalFile = "res/image/rankGame/btn_paihang_up.png",
        selectedFile = "res/image/rankGame/btn_paihang_down.png",
        anchor = cc.p( 0.5, 0.5 ),
        endCallback = function()
            ClientHttp:requestAsyncInGameWithParams({
                modules = "topRewardData?",
                params  = {rewardType = 2},
                successCallback = function( backData )
                    if tonumber( backData.result ) == 0 then
                        local pop = requires( "src/fsgl/layer/ZhuCheng/RankListRewardPop1.lua"):create(2, backData.rank, backData.time )
                        self:addChild( pop, 3 )
                        pop:show()
                    else
                          XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败"..backData.result)
                    end 
                end,
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                loadingParent = self,
            })
        end
    })
	rankListRewardBtn:setPosition(rankListRewardBtn:getContentSize().width, bottomBg:getContentSize().height / 2 - rankListRewardBtn:getContentSize().height *0.8)
    bottomBg:addChild(rankListRewardBtn, 1)
    self.rankListRewardBtn = rankListRewardBtn

    --按钮连胜奖励
    local rewardBtn =  XTHD.createButton({
        normalFile = "res/image/rankGame/btn_liansheng_up.png",
        selectedFile = "res/image/rankGame/btn_liansheng_down.png",
        anchor = cc.p( 0.5, 0.5 ),
        isScrollView = false,
    })
    rewardBtn:setPosition(rankListRewardBtn:getPositionX() + rankListRewardBtn:getContentSize().width + 53,rankListRewardBtn:getPositionY())
    bottomBg:addChild(rewardBtn,1)

    rewardBtn:setTouchEndedCallback(function ()
        -- XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_PVP_LADDER_LAYER})
        XTHDHttp:requestAsyncInGameWithParams({
            modules="rewardList?",
            -- params = {method="rewardList?"},
            successCallback = function(data)
                if tonumber(data.result) == 0 then
                    local JingJiCompetitiveRewardPop = requires("src/fsgl/layer/JingJi/JingJiCompetitiveRewardPop.lua"):create(data)
                    self:addChild(JingJiCompetitiveRewardPop)
                    JingJiCompetitiveRewardPop:show()
                end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                -- self:removeFromParent()
                LayerManager.removeLayout(self)
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end)

    --底框
    -- local bottomSp = ccui.Scale9Sprite:create(cc.rect(20,20,1,1),"res/image/common/shadow_bg.png")
    local bottomSp = ccui.Scale9Sprite:create()
    bottomSp:setAnchorPoint(0.5,0)
    bottomSp:setContentSize(cc.size(bg:getBoundingBox().width - 64,43))
    bottomSp:setPosition(bg:getBoundingBox().width/2,0)
    bg:addChild(bottomSp,1)

    self._ladderTable =CCTableView:create(cc.size(670,270))--761
    TableViewPlug.init(self._ladderTable)
    self._ladderTable:setPosition((self._bg:getContentSize().width - self._ladderTable:getContentSize().width)/3 - 10,self._bg:getContentSize().height*0.3)--20
    self._ladderTable:setBounceable(true)
    self._ladderTable:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL) --设置横向纵向
    self._ladderTable:setDelegate()
    self._ladderTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._bg:addChild(self._ladderTable)

    local cellWidth = 190
    local function cellSizeForTable(table,idx)
        return cellWidth,290
    end

    local function numberOfCellsInTableView(table)
        return #self._data.rivals
    end

    local function tableCellTouched(table,cell)
    end

    local function tableCellAtIndex(table1,idx)
        local cell = table1:dequeueCell()
        if cell then
            cell:removeAllChildren()
			cell:setContentSize(cc.size(cellWidth,290))
		else
			cell = cc.TableViewCell:new() 
			cell:setContentSize(cc.size(cellWidth,290))
        end
			self:buildCell( cell, idx + 1, cellWidth, 290 )
--        self:updateCell( cell, idx + 1, cellWidth )
        return cell
    end

    self._ladderTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._ladderTable.getCellNumbers=numberOfCellsInTableView
    self._ladderTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._ladderTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._ladderTable.getCellSize=cellSizeForTable
    self._ladderTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._ladderTable:reloadData()
end

function JingJiLadderLayer:buildCell( cell, index, cellWidth, cellHeight )
	local nowPlayer = self._data.rivals[index]
	local cell_bg = cc.Sprite:create("res/image/rankGame/taizi.png")
	cell:addChild(cell_bg)
	cell_bg:setPosition(cell:getContentSize().width * 0.5,cell_bg:getContentSize().height + 50)

	local hero_teams = nowPlayer.teams[1].heros
	table.sort(hero_teams,function(a,b)
		return a.curPowar > b.curPowar
	end)
	local _strid = string.format("%03d", hero_teams[1].petId)
	local hero = XTHDTouchSpine:create(hero_teams[1].petId, "res/spine/" .. _strid .. ".skel", "res/spine/" .. _strid .. ".atlas", 1)
    hero:setPosition(cell_bg:getContentSize().width / 2, 25)
    hero:setAnimation(0, "idle", true)
	hero:setScale(0.7)	
	cell_bg:addChild(hero)
	hero:setTouchEndedCallback(function()
		local layer = requires("src/fsgl/layer/JingJi/JingJiRankGamePop.lua"):create(hero_teams,index,self)
		self:addChild(layer)
		layer:show()
	end)

	local nameLable = XTHDLabel:create(tostring(nowPlayer.name),16,"res/fonts/def.ttf")
	nameLable:setColor(cc.c3b(75,39,13))
	cell_bg:addChild(nameLable)
	nameLable:setPosition(cell_bg:getContentSize().width *0.5,hero:getPositionY() + hero:getContentSize().height + 180)

	--等级背景
	local levelbg = cc.Sprite:create("res/image/rankGame/shengchangbg.png")
	cell:addChild(levelbg)
	levelbg:setAnchorPoint(0.5,1)
	levelbg:setPosition(cell:getContentSize().width *0.5,cell_bg:getPositionY() - cell_bg:getContentSize().height *0.5)
	
	local levleLable = XTHDLabel:create(tostring(nowPlayer.rank),16,"res/fonts/def.ttf")
	levleLable:setColor(cc.c3b(75,39,13))
	levelbg:addChild(levleLable)
	levleLable:setPosition(levelbg:getContentSize().width *0.5,levelbg:getContentSize().height *0.5 - 1)

	--挑战按钮
	local btn_tiaozhan = XTHDPushButton:createWithParams({
		normalFile = "res/image/rankGame/tiaozhan_up.png",
		selectedFile = "res/image/rankGame/tiaozhan_down.png"
	})
	cell:addChild(btn_tiaozhan)
	btn_tiaozhan:setPosition(cell:getContentSize().width *0.5,btn_tiaozhan:getContentSize().height + 5)
	btn_tiaozhan:setTouchEndedCallback(function()
		self:clickChallenge(index)
	end)
end

function JingJiLadderLayer:updateCell( cell, index, cellWidth )
    local nowPlayer = self._data.rivals[index]
    -- 排行
    cell._rankNum:setString( nowPlayer.rank )
    if nowPlayer.rank <= 10 then
        local rankIconPath = ""
        rankIconPath = "res/image/ranklist/rank_4.png"
        cell._rankIcon:setTexture( rankIconPath )
        cell._rankIcon:setVisible( true )
    else
        cell._rankIcon:setVisible( false )
    end
    -- 中间
    cell._playerName:setString( nowPlayer.name.." 等级:"..nowPlayer.level )
    cell._powerNum:setString( nowPlayer.teams[1].power )
    -- 头像
    
end

function JingJiLadderLayer:refreshHeroDate(data)
	self._petList = data
	self._parent._data.orderTeams = data
	self:createMyOrderTeams()
	self._parent:refreshPower()
end

function JingJiLadderLayer:createMyOrderTeams()
	for i = 1,#self._heroNode do
		self._heroNode[i]:removeFromParent()
	end

	self._heroNode = {}

	for i = 1,#self._petList do
		local node = HeroNode:createWithParams({
			heroid = self._petList[i]
		})
		local x = self._m_infobg:getContentSize().width*0.75 - 28 + (#self._petList-1) *node:getContentSize().width *0.5 - (i-1)*node:getContentSize().width
		local y = self._m_infobg:getContentSize().height*0.5
		node:setTag(i *100 + i)
		node:setScale(0.8)
		self._m_infobg:addChild(node)
		node:setPosition(x,y)
		self._heroNode[#self._heroNode + 1] = node 
	end
end

--挑战按钮回调
function JingJiLadderLayer:clickChallenge(index)
    local function doChallenge()
        XTHDHttp:requestAsyncInGameWithParams({
            modules="orderChallengeRival?",
            params = {rank = self._data.rivals[index].rank},
            successCallback = function(data)
                if tonumber(data.result) == 0 then
                    local challageData = data.rivals
                    LayerManager.addShieldLayout()
                    local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")
                    local _layerHandler = SelHeroLayer:create(BattleType.PVP_LADDER, nil, challageData);
                    fnMyPushScene(_layerHandler)
                else
                    XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)------"网络请求失败!")
                end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败!")
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingParent = self,
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end

    if self.cdNum.cd > 0 then
        if self.ladderCountNum.num <= 0 then
            XTHDTOAST(LANGUAGE_TIPS_WORDS32)-----"当前没有挑战次数！")
            return
        end
        local byConfirmLayer = XTHDConfirmDialog:createWithParams( {
            rightText = LANGUAGE_BTN_KEY.goumai,
            rightCallback = function ()
                XTHDHttp:requestAsyncInGameWithParams({
                    modules="clearCoolTime?",
                    successCallback = function(data)
                        if tonumber(data.result) == 0 then
                            gameUser.setIngot(data.ingot)
                            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                            doChallenge()
                            -- self.ladderCountNum:setString(data.orderLeftCount)
                        elseif tonumber(data.result) == 2000 then
                            XTHD.createExchangePop(3)
                        else
                            XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
                        end
                    end,--成功回调
                    failedCallback = function()
                        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
                    end,--失败回调
                    targetNeedsToRetain = self,--需要保存引用的目标
                    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                })
            end,
        })
        local contain = byConfirmLayer:getContainer()
        local msgStr = "<color=#462222 fontSize=18 >"..LANGUAGE_KEY_HERO_TEXT.buySkillpointOneTextXc.."<img="..IMAGE_KEY_HEADER_INGOT.." /></color><color=#462222 fontSize=18>"..(15*math.ceil(self.cdNum.cd/60))..LANGUAGE_FORMAT_TIPS8.."</color>"
        local labelContent = RichLabel:createARichText(msgStr,false)
        labelContent:setAnchorPoint(0.5,0.5)
        labelContent:setPosition(contain:getBoundingBox().width/2,contain:getBoundingBox().height/2+40)
        contain:addChild(labelContent)
        
        self:addChild(byConfirmLayer)
    else
        doChallenge()
    end
end

function JingJiLadderLayer:BattleReport()
	XTHDHttp:requestAsyncInGameWithParams({
		modules="orderFightRecord?",
        successCallback = function(data)
			if tonumber(data.result) == 0 then
				local PVPRepLayer = requires("src/fsgl/layer/JingJi/JingJiRepLayer.lua"):create(data)
                self:addChild(PVPRepLayer)
                PVPRepLayer:show()
            end
       end,--成功回调
       failedCallback = function()
			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            -- self:removeFromParent()
            LayerManager.removeLayout(self)
       end,--失败回调
       targetNeedsToRetain = self,--需要保存引用的目标
       loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end

function JingJiLadderLayer:JinjiCallFunc()
	local function doPromotion()
		XTHDHttp:requestAsyncInGameWithParams( {
			modules = "promotionRival?",
			successCallback = function(data)
				if tonumber(data.result) == 0 then
					-- 对手信息：data.rivals
					local challageData = data.rivals
					LayerManager.addShieldLayout()
					local SelHeroLayer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua")
					local _layerHandler = SelHeroLayer:create(BattleType.PVP_LADDER, nil, challageData);
					fnMyPushScene(_layerHandler)
				else
					XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
				end
			end,
			-- 成功回调
			failedCallback = function()
				XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
			end,
			-- 失败回调
			targetNeedsToRetain = self,
			-- 需要保存引用的目标
			loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
		} )
	end
	if self.cdNum.cd > 0 then
		if self.ladderCountNum.num <= 0 then
			XTHDTOAST(LANGUAGE_TIPS_WORDS32)
			return
		end
		local byConfirmLayer = XTHDConfirmDialog:createWithParams( {
			rightText = LANGUAGE_BTN_KEY.goumai,
			rightCallback = function()
				XTHDHttp:requestAsyncInGameWithParams( {
					modules = "clearCoolTime?",
					successCallback = function(data)
						if tonumber(data.result) == 0 then
							gameUser.setIngot(data.ingot)
							XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
							doPromotion()
							-- self.ladderCountNum:setString(data.orderLeftCount)
						elseif tonumber(data.result) == 2000 then
							XTHD.createExchangePop(3)
						else
							XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
						end
					end,
					-- 成功回调
					failedCallback = function()
						XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
					end,
					-- 失败回调
					targetNeedsToRetain = self,
					-- 需要保存引用的目标
					loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
				} )
			end,
		} )
		self:addChild(byConfirmLayer)

		local contain = byConfirmLayer:getContainer()
		local msgStr = "<color=#462222 fontSize=18 >" .. LANGUAGE_KEY_HERO_TEXT.buySkillpointOneTextXc .. "<img=" .. IMAGE_KEY_HEADER_INGOT .. " /></color><color=#462222 fontSize=18>" ..(15 * math.ceil(self.cdNum.cd / 60)) .. LANGUAGE_FORMAT_TIPS8 .. "</color>"
		local labelContent = RichLabel:createARichText(msgStr, false)
		labelContent:setAnchorPoint(0.5, 0.5)
		labelContent:setPosition(contain:getBoundingBox().width / 2, contain:getBoundingBox().height / 2 + 40)
		contain:addChild(labelContent)
	else
		doPromotion()
	end
end

function JingJiLadderLayer:create(data,list,parent)
    return JingJiLadderLayer.new(data,list,parent)
end

return JingJiLadderLayer