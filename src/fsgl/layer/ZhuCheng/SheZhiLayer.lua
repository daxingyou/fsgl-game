local SheZhiLayer = class("SheZhiLayer", function (...) 
    return XTHDPopLayer:create({isRemoveLayout = true})
end)
--SheZhiLayer.__index = SheZhiLayer

function SheZhiLayer:ctor(callback)
    self.artifact = gameData.getDataFromDynamicDB(gameUser.getUserId(),DB_TABLE_NAME_ARTIFACT)
    self._heroData = DBTableHero.getData(gameUser.getUserId())
    self.heroinfo = gameData.getDataFromCSV("GeneralInfoList", {["unlock"] = 1})--开启英雄
    
    if callback then
        self.callback = callback
    end     
    self:setColor(cc.c3b(0,0,0))
    self:setOpacity(80)
    self.avatornum = gameUser.getTemplateId()
    self:initUI(gameUser.getBaseContent())
    self:show()
end

function SheZhiLayer:initUI(data)
    self._lastSelectedBtn = nil
    --三个button的响应函数
    local tabs={}
    local bgtap={"settingBg", "playerBg"}
    local function selectBtnCallback(btn)
        for k,v in pairs(tabs) do
            if btn == v then 
                self._lastSelectedBtn:setSelected(false)
                self._lastSelectedBtn:setLocalZOrder(0)
                self._lastSelectedBtn = btn
                self._lastSelectedBtn:setSelected(true)
                self._lastSelectedBtn:setLocalZOrder(1) 
                if v:getTag() == 1 then
                    if self._info_bg:getChildByName("settingBg") then
                        self._info_bg:getChildByName("settingBg"):setVisible(true)
                    else 
                        self:initSetting()
                    end
                elseif v:getTag() == 2 then
                    if self._info_bg:getChildByName("playerBg") then
                        self._info_bg:getChildByName("playerBg"):setVisible(true)
                    end
                end
            else                
                if self._info_bg:getChildByName(bgtap[v:getTag()])  then
                   self._info_bg:getChildByName(bgtap[v:getTag()]):setVisible(false) 
                end
            end
        end
    end 

    local btn_normalpath = "res/image/common/btn/btn_tabClassify_normal.png"
    local btn_selectpath = "res/image/common/btn/btn_tabClassify_selected.png"


    --backGround
    local backGround = cc.Sprite:create()
    backGround:setContentSize(cc.size(700, 420))
    backGround:setPosition(self:getContentSize().width/2 - 35, self:getContentSize().height/2)
    self:addContent(backGround)
    self._backGround = backGround

    --close
    local close = XTHD.createBtnClose(function()
        self:hide()
        LayerManager.removeLayout(self)    
    end)
    close:setPosition(backGround:getContentSize().width-5,backGround:getContentSize().height-5)
    backGround:addChild(close,5)

    local info_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    info_bg:setAnchorPoint(cc.p(0,0.5))
    info_bg:setContentSize(cc.size(700,450))
    info_bg:setPosition(0, backGround:getContentSize().height/2 )
    backGround:addChild(info_bg,1)
    self._info_bg = info_bg

    -- local init_posY = backGround:getContentSize().height - 60
    -- for i = 1, 2 do 
    --     local btnNormal = getCompositeNodeWithImg(btn_normalpath,"res/image/setting/setting"..i.."_2.png")
    --     local btnSelected = getCompositeNodeWithImg(btn_selectpath,"res/image/setting/setting"..i.."_1.png")
    --     local btn  = XTHDPushButton:createWithParams({
    --         normalNode        = btnNormal,
    --         selectedNode      = btnSelected,
    --         needSwallow       = true,--是否吞噬事件
    --         musicFile = XTHD.resource.music.effect_btn_common,
    --     })
    --     btn:setScale(0.7)
    --     btn:setTag(i)
    --     btn:setAnchorPoint(cc.p(0, 1))
    --     btn:setPosition(cc.p(backGround:getContentSize().width, init_posY-(i-1)*86))
    --     backGround:addChild(btn,0)
    --     tabs[#tabs+1]=btn 
    --     btn:setTouchEndedCallback(function() selectBtnCallback(btn) end)
    --     if i == 2 then
    --         self._lastSelectedBtn = btn
    --         btn:setSelected(true)
    --         btn:setLocalZOrder(1) 
    --     end
    -- end 
    
    --默认显示玩家信息界面
    self:initPlayerLeft()
end


function SheZhiLayer:initPlayerLeft()

    local popSize = cc.size(self._info_bg:getContentSize().width-2,self._info_bg:getContentSize().height)
    local popPos = cc.p(self._info_bg:getContentSize().width/2,self._info_bg:getContentSize().height/2)

    local playerBg = cc.Sprite:create()
    playerBg:setContentSize(popSize)
    playerBg:setPosition(popPos)
    self._info_bg:addChild(playerBg,1)
    playerBg:setName("playerBg")

    local left_bg = playerBg
    --头像
    self.avator = HeroNode:createWithParams({
        heroid = self.avatornum,
        star  = 0,
        level = 0,
        advance = 0,
    })
    self.avator:setAnchorPoint(0, 1) 
    self.avator:setPosition(60, left_bg:getContentSize().height -22)
    left_bg:addChild(self.avator)
    --更换头像Btn
    local changeAvatorBtn  = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(105,46),
        isScrollView = false,
        needSwallow = true,
        enable = true,
        musicFile = XTHD.resource.music.effect_btn_common,
        text = LANGUAGE_TIPS_SETTING_TIP7,
        fontSize = 26,
        fontColor = cc.c3b(255,255,255),
        endCallback = function ()
            local _layer = requires("src/fsgl/layer/ZhuCheng/HeroPortraitLayer1.lua"):create(self)
            self:addChild(_layer,1)
            _layer:show()
        end
    })
    changeAvatorBtn:setScale(0.6)
    changeAvatorBtn:setTouchSize(cc.size(100,50))
    changeAvatorBtn:setAnchorPoint(0.5, 1)
    changeAvatorBtn:setPosition(self.avator:getContentSize().width/2+2, -3)
    self.avator:addChild(changeAvatorBtn)

    --XTHD.createRichLabel现在不适合android(暂时不用)
    -- local id = XTHD.createRichLabel({
    --     -- text = "[color=6437211b][size=50][u]ID:[/color][/size][/u][color=ff88242d][b][i][size=30]"..gameUser.getUserId().."[/color][/b][/i][/size]",
    --     text = "[color=ff37211b][size=20]ID:[/color][/size][color=ff88242d][size=20]"..gameUser.getUserId().."[/color][/size]",
    -- })
    -- id:setAnchorPoint(0.5, 1)
    -- self.avator:addChild(id)
    -- id:setPosition(self.avator:getContentSize().width/2, changeAvatorBtn:getPositionY()-32)
    local id = XTHDLabel:createWithParams({
        text = "编号:",
        fontSize = 20,
        color = cc.c3b(55,33,27),
        anchor = cc.p(0.5,1),
    })
    local idNumber = XTHDLabel:createWithParams({
        text = gameUser.getUserId(),
        fontSize = 20,
        color = cc.c3b(136,36,45),
        anchor = cc.p(0,1),
    })
    id:setPosition(self.avator:getContentSize().width/2-idNumber:getContentSize().width/2,changeAvatorBtn:getPositionY()-47)
    idNumber:setPosition(id:getPositionX()+id:getContentSize().width/2,id:getPositionY())
    self.avator:addChild(id)
    self.avator:addChild(idNumber)

	local btn_chenghao = XTHD.createCommonButton({
		btnColor = "write_1",
        btnSize = cc.size(105,46),
        isScrollView = false,
        needSwallow = true,
        enable = true,
        musicFile = XTHD.resource.music.effect_btn_common,
        text = "称号",
        fontSize = 26,
        fontColor = cc.c3b(255,255,255),
        endCallback = function ()
           self:Chenghao()
        end
	})
	self.avator:addChild(btn_chenghao)
	btn_chenghao:setScale(0.6)
    btn_chenghao:setTouchSize(cc.size(100,50))
    btn_chenghao:setAnchorPoint(0.5, 1)
    btn_chenghao:setPosition(changeAvatorBtn:getPositionX(), idNumber:getPositionY() - idNumber:getContentSize().height *0.5  -10)
	

    local serverTitle = XTHDLabel:createWithParams({
        text = LANGUAGE_KEY_NOWSERVER .. ":",
        size = 19,
        color = cc.c3b(40,18,10),
        anchor = cc.p(0,0.5),
    })
    left_bg:addChild(serverTitle)
    serverTitle:setPosition(changeAvatorBtn:getPositionX(),100)

    local serverName = XTHDLabel:createWithParams({
       text = gameUser.getServerName(),
       size = 19,
       color = cc.c3b(132,8,8),
       anchor = cc.p(0,0.5),
    })
    left_bg:addChild(serverName)
    serverName:setPosition(serverTitle:getPositionX(),serverTitle:getPositionY() - 30)

    -- local splity = cc.Sprite:create("res/image/setting/splitY.png")
    -- splity:setAnchorPoint(0,0.5)
    -- splity:setPosition(158,left_bg:getContentSize().height/2)
    -- left_bg:addChild(splity)

    local heroInfoBg = ccui.Scale9Sprite:create("res/image/setting/heroinfo_bg.png")
    -- local heroInfoBg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1),"res/image/common/scale9_bg_14.png")
    heroInfoBg:setContentSize(cc.size(485, left_bg:getContentSize().height-50))
    heroInfoBg:setAnchorPoint(1,0.5)
    heroInfoBg:setPosition(left_bg:getContentSize().width-13,left_bg:getContentSize().height/2+5)
    left_bg:addChild(heroInfoBg)

    local supportlabel=cc.Sprite:create("res/image/setting/duanwei_rank.png")
    supportlabel:setAnchorPoint(0,1)
    supportlabel:setPosition(15,heroInfoBg:getContentSize().height - 20)
    heroInfoBg:addChild(supportlabel)

    local ttftest6=cc.Label:createWithBMFont("res/fonts/yellowwordforcamp.fnt",tostring(gameUser.getDuanRank()))
    ttftest6:setAnchorPoint(0,1)
    heroInfoBg:addChild(ttftest6)
    ttftest6:setScale(0.8)
    ttftest6:setPosition(supportlabel:getPositionX()+supportlabel:getContentSize().width+5,supportlabel:getPositionY() - 4)

    local duanwei = cc.Sprite:create("res/image/setting/duanwei.png")
    duanwei:setAnchorPoint(0,1)
    duanwei:setPosition(supportlabel:getPositionX() + 190, supportlabel:getPositionY())
    heroInfoBg:addChild(duanwei)

    local zu = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_GET_DUANWEI(gameUser.getDuanId()), "Helvetica", 20)
    zu:setColor(cc.c3b(127,0,9))
    zu:setAnchorPoint(0,1)
    zu:setPosition(duanwei:getPositionX()+duanwei:getContentSize().width+5, duanwei:getPositionY() - 4)
    heroInfoBg:addChild(zu)

    --徽章
    local teamBadge = cc.Sprite:create("res/image/common/rank_icon/rankIcon_"..gameUser.getDuanId()..".png")
    teamBadge:setAnchorPoint(cc.p(0, 0.5))
    teamBadge:setPosition(zu:getPositionX()+zu:getContentSize().width+5, zu:getPositionY()-10)
    teamBadge:setScale(1)
    heroInfoBg:addChild(teamBadge)

    --小助手
    local friendBtn  = XTHDPushButton:createWithParams({
        normalNode = "res/image/setting/menu_help1.png",
        selectedNode = "res/image/setting/menu_help2.png",
        needSwallow = true,
        enable = true,
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback = function ()
            local help = requires("src/fsgl/layer/ZhuShou/BangZhuLayer.lua"):create();
            LayerManager.addLayout(help, {par = self, zz = 1})
        end
    })
    friendBtn:setScale(0.7)
    friendBtn:setAnchorPoint(1, 1)
    friendBtn:setPosition(heroInfoBg:getContentSize().width-20, heroInfoBg:getContentSize().height-10)
    heroInfoBg:addChild(friendBtn)


    local initPosY = left_bg:getContentSize().height - 170
    --line1
    -- local line1 = ccui.Scale9Sprite:create("res/image/setting/setint_line.png")
    -- -- line1:setContetnSize(476,2)
    -- line1:setPosition(heroInfoBg:getContentSize().width/2, initPosY +31)
    -- heroInfoBg:addChild(line1)
    --info
    local function getArtifactNum() --神器
        local ownedArtifactNum=0
        if self.artifact.templateId and self.artifact.templateId ~=0 then
            ownedArtifactNum=1
        end
        if #self.artifact>0 then
            ownedArtifactNum=#self.artifact
        end
        return ownedArtifactNum
    end
    local function getMaxPower() --最高英雄战力
        local power=0
           if #self._heroData==0 then
            power=self._heroData["power"]
           end
        for k=1,#self._heroData do
            b=self._heroData[k]["power"]
            if power>b then
                power=power 
            elseif power<b then
                power=b
            end 
        end
        return power
    end   

    local infoTable = {
        [1] = {
            key = LANGUAGE_KEY_NAME,--名字
            value = (gameUser.getNickname()),      
        },
        [3] = {
            key = LANGUAGE_KEY_CAMP,--种族
            value = gameUser.getCampID()==1 and LANGUAGE_CAMP_NAME1 or LANGUAGE_CAMP_NAME2, 
        },
        [7] = {
            key = LANGUAGE_KEY_LEVEL,--等级
            value = (gameUser.getLevel()),         
        },
        [5] = {
            key = LANGUAGE_KEY_HERO_TEXT.expTextXc,--exp
            value = (tonumber(gameUser.getExpNow()).."/"..tonumber(gameUser.getExpMax())),     
        },
        [2] = {
            key = LANGUAGE_KEY_CHAT_BANGPAI,--帮派            
            value = tostring(gameUser._guildName)~=""and tostring(gameUser._guildName) or LANGUAGE_KEY_CHAT_NONEBP,
        },
        [4] = {
            key = LANGUAGE_KEY_HERO_TEXT.ownedHeros, --拥有英雄
            value = LANGUAGE_KEY_OWNED_HEROS(#self._heroData),
                    
        },
        [8] = {
            key = LANGUAGE_KEY_HERO_TEXT.highestHeroFVIM, --"最高英雄战力"
            value = getMaxPower(),
        },
        [6] = {
            key = LANGUAGE_KEY_HERO_TEXT.ownedArtifact, --拥有神器
            value = LANGUAGE_KEY_OWNED_ARTIFACT(getArtifactNum()),
        },
        -- [9] = {
        --     key = LANGUAGE_KEY_NOWSERVER,--当前服务器
        --     value = gameUser.getServerName(),
        -- },
    }

    for i = 1, #infoTable do
        local infoTip1 = XTHDLabel:createWithParams({
            text = infoTable[i].key .. ":",
            size = 19,
            color = cc.c3b(40,18,10),
            anchor = cc.p(0,0.5),
            pos = cc.p(i%2 == 0 and 250 or 15, initPosY - (math.floor((i - 1)/2))*35),
        })
        local infoTip2 = XTHDLabel:createWithParams({
           text = infoTable[i].value,
           size = 19,
           color = cc.c3b(132,8,8),
           anchor = cc.p(0,0.5),
         --  pos = cc.p(i%2 == 0 and infoTip1:getPositionX()+130 or infoTip1:getPositionX()+50, infoTip1:getPositionY()),
        })
		infoTip2:setPosition(infoTip1:getPositionX() + infoTip1:getContentSize().width + 10, infoTip1:getPositionY())
        heroInfoBg:addChild(infoTip1)
        heroInfoBg:addChild(infoTip2)
		
		if i == 1 then
			local mySex = cc.Sprite:create("res/image/PlayerName/sex_"..gameUser.getSex()..".png")
			heroInfoBg:addChild(mySex)
			mySex:setScale(0.8)
			mySex:setAnchorPoint(0,0.5)
			mySex:setPosition(infoTip2:getPositionX() + infoTip2:getContentSize().width + 5,infoTip2:getPositionY())
		end

        if i == 1 then
            self._name = infoTip2
        end
    end

    --改名按钮
    local changName  = XTHDPushButton:createWithParams({
        normalNode = cc.Sprite:create("res/image/setting/changeName_up.png"),
        selectedNode = cc.Sprite:create("res/image/setting/changeName_down.png"),
        needSwallow = true,
        enable = true,
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback = function ()
            if gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2304}) then
                current_num = gameData.getDataFromDynamicDB(gameUser.getUserId(),"item",{itemid = 2304}).count or 0
                if current_num > 0 then
                    local pop = XTHD.changPlayerNameLayer(function (data) 
                        self._name:setString(tostring(data.name))
                        gameUser.setNickname(data.name)
                        for i=1,#data["costItems"]  do
                            local _data = data["costItems"][i] 
                            if _data then
                                DBTableItem.updateCount(gameUser.getUserId(),_data,_data["dbId"])
                                XTHDTOAST("改名成功!")
                                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
                                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})        --刷新数据信息
                            end
                        end
                    end)
                    self:addChild(pop,1)
                else
                    local bg_sp = ccui.Scale9Sprite:create("res/image/common/scale9_bg_34.png" )
                    bg_sp:setContentSize(375,228)
                    bg_sp:setCascadeOpacityEnabled(true)
                    bg_sp:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
                    self:addChild(bg_sp, 2)
                    local txt_content = XTHDLabel:create("是否前往商店购买改名卡？",18)
                    txt_content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
                    txt_content:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
                    txt_content:setColor(XTHD.resource.color.gray_desc)
                    --解决文字过短居中的问题
                    if tonumber(txt_content:getContentSize().width)<306 then
                        txt_content:setDimensions(tonumber(txt_content:getContentSize().width), 120)
                    else
                        txt_content:setDimensions(306, 120)
                    end

                    txt_content:setPosition(bg_sp:getContentSize().width/2,bg_sp:getContentSize().height/2 + 30)
                    bg_sp:addChild(txt_content)
                    -- 不前往
                    local btn_left = XTHD.createCommonButton({ 
                        btnColor = "write_1",
                        isScrollView = false,
                        text = LANGUAGE_KEY_CANCEL,
                        fontSize = 22,
                        musicFile = XTHD.resource.music.effect_btn_common,
                        pos = cc.p(100 + 5,50),
                        endCallback = function()
                            bg_sp:removeFromParent()
                        end
                    })
					btn_left:setScale(0.8)
					btn_left:setScaleY(0.7)
                    btn_left:setCascadeOpacityEnabled(true)
                    btn_left:setOpacity(255)
                    bg_sp:addChild(btn_left)
                    --前往
                    local btn_right = XTHD.createCommonButton({
                        btnColor = "write_1",
                        isScrollView = false,
                        text = "前往",
                        fontSize = 22,
                        musicFile = XTHD.resource.music.effect_btn_common,
                        pos = cc.p(bg_sp:getContentSize().width-100-5,btn_left:getPositionY()),
                        endCallback = function()
							bg_sp:removeFromParent()
                            replaceLayer({
                                fNode = self,
                                id = 64,
                                chapterId = nil,
                                callback = function ()
                                   self:refreshList(true)
                                end,
                            })
                        end
                    })
					btn_right:setScaleX(0.8)
					btn_right:setScaleY(0.7)
                    btn_right:setCascadeOpacityEnabled(true)
                    btn_right:setOpacity(255)
                    bg_sp:addChild(btn_right)
                end
            end
        end,
    })
    changName:setAnchorPoint(1,0.5)
    changName:setTouchSize(cc.size(50,50))
    changName:setPosition(heroInfoBg:getContentSize().width -250, initPosY)
    heroInfoBg:addChild(changName)

   self:initSetting()

end

function SheZhiLayer:initSetting()
    --背景
    local settingBg = cc.Sprite:create()
    -- local settingBg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1), "res/image/common/scale9_bg_14.png")
    settingBg:setAnchorPoint(0.5,0.5)
    settingBg:setContentSize(cc.size(self._info_bg:getContentSize().width-2,self._info_bg:getContentSize().height))
    settingBg:setPosition(cc.p(self._info_bg:getContentSize().width/2,self._info_bg:getContentSize().height/2))
    settingBg:setName("settingBg")
    self._info_bg:addChild(settingBg,1)
    
    -- local leftbg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1), "res/image/common/scale9_bg_14.png")
    local leftbg = cc.Sprite:create()
    leftbg:setContentSize(320,settingBg:getContentSize().height)
    leftbg:setAnchorPoint(1,0.5)
    settingBg:addChild(leftbg,1)
    leftbg:setPosition(settingBg:getContentSize().width/2 -20, settingBg:getContentSize().height/2)
    -- local rightbg = ccui.Scale9Sprite:create(cc.rect(5,5,1,1), "res/image/common/scale9_bg_14.png")
    local rightbg = cc.Sprite:create()
    rightbg:setContentSize(320,settingBg:getContentSize().height)
    rightbg:setAnchorPoint(0,0.5)
    settingBg:addChild(rightbg,1)
    rightbg:setPosition(settingBg:getContentSize().width/2 +20, settingBg:getContentSize().height/2)

    local function createTitleBar(text, pos)
        local _titleBarpath = "res/image/setting/jcsz.png"
        if tostring(text) == tostring(LANGUAGE_TIPS_SETTING_TIP3) then
            _titleBarpath = "res/image/setting/jcsz.png"
        else 
            _titleBarpath = "res/image/setting/tssz.png"
        end
        local _titleBar = cc.Sprite:create(_titleBarpath)
        _titleBar:setPosition(pos)
        settingBg:addChild(_titleBar, 2)
        local _title = XTHDLabel:createWithParams({
            text = text,
            fontSize = 18,
            color = cc.c3b(70, 34, 34)
        })
        _title:setPosition(cc.p(_titleBar:getContentSize().width*0.5, _titleBar:getContentSize().height*0.5))
        -- _titleBar:addChild(_title)
    end
    -- kuang1 
    -- local kuang1 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
    -- kuang1:setContentSize(settingBg:getContentSize().width-40,91)
    -- kuang1:setPosition(cc.p(settingBg:getContentSize().width/2, settingBg:getContentSize().height - 30))
    -- kuang1:setAnchorPoint(0.5,1)
    -- settingBg:addChild(kuang1)

    -- createTitleBar(LANGUAGE_TIPS_SETTING_TIP3, cc.p(settingBg:getContentSize().width/2, settingBg:getContentSize().height - 30))


    local clickControlBtnCallback = function(controlBtn)
        if controlBtn:getTag() == 1 then
            if musicManager.isMusicEnable() == true then
                musicManager.setMusicEnable(false)
            elseif musicManager.isMusicEnable() == false then
                musicManager.setMusicEnable(true)
            end
        elseif controlBtn:getTag() == 2 then
            if musicManager.isEffectEnable() == true then
                musicManager.setEffectEnable(false)
            elseif musicManager.isEffectEnable() == false then
                musicManager.setEffectEnable(true)
            end
        elseif controlBtn:getTag() == 3 then -- 兑换邀请码

        else-- 返回登录   
        end
    end

    local btn_arr = {}
    local nameTable = {LANGUAGE_TIPS_SETTING_TIP4,LANGUAGE_TIPS_SETTING_TIP8,LANGUAGE_TIPS_SETTING_TIP5}
    local colorTable = {"write","write","write_1"}
    local pos = SortPos:sortFromMiddle(cc.p(settingBg:getContentSize().width/2,25) ,#nameTable,settingBg:getContentSize().width/5)
    for i = 1, 3 do
        local btn = XTHD.createCommonButton({
            btnColor = colorTable[i],
            btnSize = cc.size(150,48),
            isScrollView = false,
            needSwallow = false,
            musicFile = XTHD.resource.music.effect_btn_common,
            needEnableWhenMoving = true,
            text = nameTable[i],
            fontSize =  24,
            fontColor = cc.c3b(255,255,255)
        })
        -- btn:getLabel():setPositionY(btn:getLabel():getPositionY()+3)
        btn:setAnchorPoint(0.5, 0)
        btn:setScale(0.8)
        btn:setPosition(cc.p(pos[i].x + 90 , pos[i].y + 10))
        settingBg:addChild(btn) 
        btn:setSwallowTouches(false)
        btn_arr[#btn_arr+1] = btn
    end

    --兑换激活码
    btn_arr[1]:getLabel():setFontSize(20)
    btn_arr[1]:setTouchEndedCallback(function (  )

        local exchange_code = requires("src/fsgl/layer/ZhuCheng/ExchangeCodePop1.lua")
        self:addChild(exchange_code:create(), 1)
    end)
    
     
     --返回登录
    btn_arr[3]:setTouchEndedCallback(function() 
        MsgCenter:reset()    ------断开Socket
        ClientHttp:requestAsyncInGameWithParams({
            modules = "exit?",
            successCallback = function()        
            end,
            failedCallback = function()
            end,--失败回调
            loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
        })
        XTHD.replaceToLoginScene()
        XTHD.logout()
    end)

    --联系客服
    btn_arr[2]:setTouchEndedCallback(function()
        print("--联系客服--")
        XTHD.enterCustomerServiceCenter()
    end)
	btn_arr[2]:setVisible(false)

    --用于审核
    if IS_APP_STORE_CHANNAL() then
        btn_arr[1]:setVisible(false)
        --重新摆位置
        local pos = SortPos:sortFromMiddle(cc.p(settingBg:getContentSize().width/2,25) ,2,settingBg:getContentSize().width/3)
        btn_arr[2]:setPosition(cc.p(pos[1].x, pos[1].y))
        btn_arr[3]:setPosition(cc.p(pos[2].x, pos[2].y))

    end

     -- kuang2
     -- local kuang2 = ccui.Scale9Sprite:create("res/image/plugin/hero/yxk.png")
     -- kuang2:setContentSize(settingBg:getContentSize().width-40,190)
     -- kuang2:setPosition(cc.p(settingBg:getContentSize().width/2, settingBg:getContentSize().height - 145))
     -- kuang2:setAnchorPoint(0.5,1)
     -- settingBg:addChild(kuang2)
    --推送设置
--    createTitleBar(LANGUAGE_TIPS_SETTING_TIP6, cc.p(settingBg:getContentSize().width/2, settingBg:getContentSize().height - 145))
   local switchPathOpen = "res/image/setting/check_btn_normal.png"
    for i = 1, 2 do
        local col = tonumber(((i-1)%2))
        local row = math.floor((i-1)/2)        
        local recommendTip = cc.Label:create()
        recommendTip:setSystemFontSize(20)
        recommendTip:setTextColor(cc.c4b(54, 55, 112, 255) )
        recommendTip:setAnchorPoint(1, 0.5)
        local recomPosx
        if col == 0 then
            leftbg:addChild(recommendTip)
            recomPosx = leftbg:getContentSize().width - 150
        else
            rightbg:addChild(recommendTip)
            recomPosx = leftbg:getContentSize().width - 200
        end
        if i==1 then
            recommendTip:setPosition(recomPosx + 115 , settingBg:getContentSize().height - 330)
        elseif i == 2 then
            recommendTip:setPosition(recomPosx + 80 , settingBg:getContentSize().height - 330)
        else
            recommendTip:setPosition(recomPosx, settingBg:getContentSize().height - 130 - row*58)
        end

        if col == 0 and row == 0 then  -- i == 1
            recommendTip:setString(LANGUAGE_KEY_MUSIC)-----"音乐")
        elseif col == 1 and row == 0 then -- -- i == 2
            recommendTip:setString(LANGUAGE_KEY_SOUND)------"音效")
--        elseif col == 0 and row == 1 then -- i == 3
--            recommendTip:setString(LANGUAGE_KEY_TITLENAME.vimRecoverFullNotify)-----"体力回满通知")
--        elseif col == 1 and row == 1 then -- -- i == 4
--            recommendTip:setString(LANGUAGE_KEY_TITLENAME.skillDotRecoverFullNotify)------"技能点回满通知")
--        elseif col == 0 and row == 2 then -- i == 5
--            recommendTip:setString(LANGUAGE_KEY_TITLENAME.rangeMatchChallengedNotify)------"排位赛被挑战通知")
--        elseif col == 1 and row == 2 then 
--            recommendTip:setString(LANGUAGE_KEY_TITLENAME.beRobberedNotify)-----"被玩家抢夺时通知")
--        -- elseif col == 0 and row == 3 then -- i == 5
--            -- recommendTip:setString(LANGUAGE_KEY_TITLENAME.getEquipFreeNotify)-------"天降异宝免费通知")
--        -- elseif col == 1 and row == 3 then 
--            -- recommendTip:setString(LANGUAGE_KEY_TITLENAME.recruitFreeNotify)-------"群英降临免费通知")
--        elseif col == 0 and row == 3 then -- i == 5
--            recommendTip:setString(LANGUAGE_KEY_TITLENAME.fullResourceNotify)-----"建筑满资源通知")
--        elseif col == 1 and row == 3 then 
--            recommendTip:setString(LANGUAGE_KEY_TITLENAME.buildingLevelupNotify)-----"建筑升级完成通知")
        end

        local switchBtn = XTHDPushButton:createWithFile(switchPathOpen)
        switchBtn:setEnableWhenMoving(true)
        switchBtn:setSwallowTouches(false)
        switchBtn:setTouchSize(cc.size(50,50))
        switchBtn:setTag(i)
        local tab=true
        local switchBtnUp=cc.Sprite:create("res/image/setting/check_btn_selected.png")
        switchBtnUp:setPosition(switchBtn:getContentSize().width/2, switchBtn:getContentSize().height/2)
        switchBtnUp:setVisible(false)
        if i ==2 then
            if musicManager.isEffectEnable() == true then
                switchBtnUp:setVisible(true)
            elseif musicManager.isEffectEnable() == false then
                switchBtnUp:setVisible(false)
                
            end
        elseif i==1 then
            if musicManager.isMusicEnable() == true then
                switchBtnUp:setVisible(true)

            elseif musicManager.isMusicEnable() == false then
                switchBtnUp:setVisible(false)

            end
        end
        switchBtn:addChild(switchBtnUp)
        switchBtn:setAnchorPoint(cc.p(0, 0.5))
        switchBtn:setPosition(cc.p(recommendTip:getPositionX() + 5, recommendTip:getPositionY()))
        if col == 0 then
            leftbg:addChild(switchBtn)
        else
            rightbg:addChild(switchBtn)
        end 
        switchBtn:setTouchEndedCallback(function() 
            musicManager.playEffect(XTHD.resource.music.effect_btn_common)
            if  i==1 then
                 if musicManager.isMusicEnable() == true then
                    switchBtnUp:setVisible(false)
                 elseif musicManager.isMusicEnable() == false then
                    switchBtnUp:setVisible(true)
                end
                clickControlBtnCallback(switchBtn)
            elseif i==2 then
                if musicManager.isEffectEnable() == true then
                    switchBtnUp:setVisible(false)
                elseif musicManager.isEffectEnable() == false then
                    switchBtnUp:setVisible(true)
                end
                clickControlBtnCallback(switchBtn)
--            else  
--                if tab == true then
--                    tab=false
--                    switchBtnUp:setVisible(true)
--                else
--                    tab=true
--                    switchBtnUp:setVisible(false)  
--                end
            end
        end)

    end
end

function SheZhiLayer:Chenghao()
	local layer =  requires("src/fsgl/layer/ZhuCheng/ChenghaoLayer.lua"):create()
	cc.Director:getInstance():getRunningScene():addChild(layer)
	layer:setName("Poplayer")
	layer:show()
end

function SheZhiLayer:changAcator(id)--回调函数改变主城头像by.hungjunjian
    ClientHttp:requestAsyncInGameWithParams({
        modules = "changeTemplate?",
        params = {templateId=tostring(id)},
        successCallback = function(data)
        if tonumber(data.result)==0 then
            local  avator_id=1
            if data.templateId then
                 avator_id=data.templateId
            end   
            gameUser.setTemplateId(avator_id)
            --修改缓存
            self.avator:getChildByName("item_border"):getChildByName("hero_img"):initWithFile(zctech.getHeroAvatorImgById(avator_id))
            --修改本页面
            self.callback(1,avator_id)
            --修改主城
        else
            msg= LANGUAGE_TIPS_WORDS147------"没有返回数据"
            if data.msg then
                msg=data.msg
            end
            XTHDTOAST(msg)
        end 
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        }) 
end

function SheZhiLayer:create(callback)--什么鬼！！
    local pLayer = self.new(callback)
    return pLayer
end

return SheZhiLayer