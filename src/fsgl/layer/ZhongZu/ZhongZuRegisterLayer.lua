--[[
authored by LITAO
玩家注册种族
]]
local ZhongZuRegisterLayer = class("ZhongZuRegisterLayer",function( )
    return XTHDDialog:create()    
end)

function ZhongZuRegisterLayer:ctor(params)
    math.randomseed(os.clock())
    self._callback = params.callback
    self._campID = params.campID--1 为仙族，2 为魔族
    self._campID = self._campID == 0 and 1 or self._campID
    self._campBtn = {}
    self._triangle = nil
    self._selectedCircle = nil
    self._campTips = nil ----右边不同种族的说明文字
    self._campIcon = nil ---右边不同种族的图标
    self._selectedCampID = 0

    ---预加载出主城部分资源
    local textureCache = cc.Director:getInstance():getTextureCache()
    local pFileTb = {"res/image/homecity/cityworld_bg",1,"_",1,".png"}
    local pFileName = ""
    for j = 1, 5 do
        if j ~= 5 then
            for i = 1, 3 do
                pFileTb[2] = i
                pFileTb[4] = j
                pFileName = table.concat(pFileTb)
                textureCache:addImage(pFileName)
            end
        end
        pFileName = "res/image/homecity/cityworld_bg4_" .. j ..".png"
        textureCache:addImage(pFileName)
    end
    for i = 1, 9 do 
        if i ~= 7 and i ~= 8 then 
            BuildingItem1:create({buildingId = i})
        end
    end
end

function ZhongZuRegisterLayer:createWithParams(params)
    local camp = ZhongZuRegisterLayer.new(params)
    if camp then 
        camp:init()
    end 
    return camp
end

function ZhongZuRegisterLayer:init( )
    --背景
    local winSize = cc.Director:getInstance():getWinSize()
    local bg = cc.Sprite:create("res/image/camp/regist/bg.png")
    self:addChild(bg)
    bg:setContentSize(winSize)
    bg:setPosition(winSize.width / 2,winSize.height / 2)
    self.bg = bg
--    local content = cc.Sprite:create("res/image/camp/regist/content.png")
--    self.bg:addChild(content)
--    content:setPosition(self.bg:getContentSize().width/2,self.bg:getContentSize().height/2)
--    local battle = cc.Sprite:create("res/image/camp/regist/battle.png")
--    content:addChild(battle)
--    battle:setPosition(content:getContentSize().width/2,content:getContentSize().height/2)
    ----右边板
    -- local _border = ccui.Scale9Sprite:create("res/image/camp/regist/camp_right_b.png")
    -- -- _border:setContentSize(212,611)
    -- self:addChild(_border)
    -- _border:setAnchorPoint(1,0.5)
    -- _border:setScaleY(0.8)
    -- _border:setPosition(self:getContentSize().width+60,self:getContentSize().height / 2)
    ------------动画 (人物)
    -- local _spine = sp.SkeletonAnimation:create( "res/image/camp/xzy.json", "res/image/camp/xzy.atlas", 1.0)
    -- self:addChild(_spine)
    -- _spine:setPosition(self:getContentSize().width / 2 - 95,self:getContentSize().height / 2 + 15)        
    -- _spine:setAnimation(0,"ay",true)
    -- self._spine = _spine
    --看效果的在spine上放上图片试一下
    -- self.campSprite = {}
    -- local campSprite1 = XTHD.createSprite("res/image/camp/selecamp1.png")
    -- campSprite1:setPosition(_spine:getPositionX(),_spine:getPositionY())
    -- campSprite1:setScale(0.8)
    -- self:addChild(campSprite1)
    -- self.campSprite[1] = campSprite1
    -- local campSprite2 = XTHD.createSprite("res/image/camp/selecamp2.png")
    -- campSprite2:setPosition(_spine:getPositionX(),_spine:getPositionY())
    -- campSprite2:setScale(0.8)
    -- self:addChild(campSprite2)
    -- self.campSprite[2] = campSprite2
    -- self.campSprite[2]:setVisible(false)
    

    --开始游戏特效
    -- local star_btn_eff = cc.Sprite:create("res/image/camp/star_btn_eff.png")
    -- star_btn_eff:setPosition(self:getContentSize().width/2 - 40,145)
    -- content:addChild(star_btn_eff)
    -- star_btn_eff:setScale(0.7)
    -- --进入游戏按钮
    -- local button = XTHDPushButton:createWithParams({
    --     musicFile = XTHD.resource.music.effect_btn_common,
    -- })
    -- button:setTouchSize(cc.size(165,162))
    -- button:setContentSize(cc.size(165,162))
    -- button:setTouchEndedCallback(function( )
    --     -- if button.spine then 
    --     --     button.spine:setAnimation(0,"jryx2",false)
    --     -- end 
    --     self:removeFromParent()
    --     -- self:doEnterGame()
    -- end)
    -- content:addChild(button)
    -- button:setPosition(content:getContentSize().width/2,145)   
    -- --进入游戏按钮 
    -- local start_btn = cc.Sprite:create("res/image/camp/star_btn.png")
    -- start_btn:setPosition(button:getContentSize().width / 2,button:getContentSize().height / 2)
    -- button:addChild(start_btn)
    -- button:setScale(0.7)
    -- _spine = sp.SkeletonAnimation:create( "res/image/camp/anniu.json", "res/image/camp/anniu.atlas", 1.0)
    -- button:addChild(_spine)
    -- _spine:setPosition(button:getContentSize().width / 2,button:getContentSize().height / 2)        
    -- _spine:setAnimation(0,"jryx",true)
    -- button.spine = _spine
    ----种族图标
    -- local _icon = cc.Sprite:create("res/image/camp/camp_circle_icon"..self._campID..".png")
    -- self:addChild(_icon)
    -- _icon:setPosition(button:getPositionX()-20,self:getContentSize().height * 3/4)
    -- self._campIcon = _icon
    --标题板
    -- local titleBoard = cc.Sprite:create(IMAGE_KEY_CAMP_RES_PATH.."camp_choise_title.png")
    -- self:addChild(titleBoard)
    -- titleBoard:setScale(0.8)
    -- titleBoard:setPosition(_icon:getPositionX(),_icon:getPositionY() + _icon:getBoundingBox().height + 10)
    -- ---说明
    -- local _tips = XTHDLabel:createWithSystemFont(LANGUAGE_CAMPCHOOSETIP[self._campID],XTHD.SystemFont,22)
    -- _tips:setWidth(150)
    -- _tips:enableShadow(cc.c4b(0,0,0,200),cc.size(1,-1))
    -- self:addChild(_tips)
    -- _tips:setAnchorPoint(0.5,1)
    -- _tips:setPosition(_icon:getPositionX()+10,_icon:getPositionY() - _icon:getContentSize().height / 2 - 15)
    -- self._campTips = _tips

	local campbg1 = cc.Sprite:create("res/image/camp/regist/camp1.png")
	self.bg:addChild(campbg1)
	campbg1:setPosition(self:getContentSize().width * 0.25,self.bg:getContentSize().height*0.5)
	campbg1:setName("campbg1")

	local campbg2 = cc.Sprite:create("res/image/camp/regist/camp2.png")
	self.bg:addChild(campbg2)
	campbg2:setPosition(self:getContentSize().width * 0.75,self.bg:getContentSize().height*0.5)
	campbg2:setName("campbg2")

	local shunyingtianming = XTHDPushButton:createWithParams({
		normalNode = "res/image/camp/regist/shunyingtianming_1.png",
        selectedNode = "res/image/camp/regist/shunyingtianming_2.png",
	})
	self.bg:addChild(shunyingtianming)
	shunyingtianming:setPosition(self.bg:getContentSize().width *0.5 + 10,self.bg:getContentSize().height *0.5)
	shunyingtianming:setTouchEndedCallback(function()
		local layer = XTHDConfirmDialog:createWithParams({
			msg = "是否随机选择种族加入？",
            rightCallback = function( )
				self._selectedCampID = self._campID      
                self:doEnterGame()
			end
        })
        self:addChild(layer)
	end)

	local xiaohao = cc.Sprite:create("res/image/camp/regist/xiaohao.png")
	self.bg:addChild(xiaohao)
	xiaohao:setPosition(self.bg:getContentSize().width *0.5 + 10,shunyingtianming:getPositionY() - 100)
    -----选种族
    -- local actName = {"gm","ay"}
    for i = 1,2 do       
        local _campBtn = XTHD.createPushButtonWithSound({
            --后加的，看效果(以前什么也没有)
            normalNode = "res/image/camp/regist/camp" .. i .. "_normal.png",
            selectedNode = "res/image/camp/regist/camp" .. i .. "_selected.png",
        },3)
		local campNode = self.bg:getChildByName("campbg"..i)
        campNode:addChild(_campBtn)
        _campBtn:setTouchSize(cc.size(105,108))
        _campBtn:setContentSize(cc.size(105,108))
        _campBtn:setTouchEndedCallback(function( )
            local name = i == 1 and "仙族" or "魔族"
            local layer = XTHDConfirmDialog:createWithParams({
                msg = "确定选择"..name.."嘛？",
                rightCallback = function( )      
                    self:doSelect(i)
                    self:doEnterGame()
                end
            })
            self:addChild(layer)
        end)
		local x = campNode:getContentSize().width*0.5 + 3
        _campBtn:setPosition(x,_campBtn:getContentSize().height*0.5 + 20)
        self._campBtn[i] = _campBtn  
        --特效+箭头
        -- local texiao = cc.Sprite:create("res/image/camp/texiao.png") 
        -- texiao:setPosition(_campBtn:getContentSize().width/2+10,_campBtn:getContentSize().height/2+10)
        -- _campBtn:addChild(texiao) 
        -- texiao:setScale(0.8)
        -- _campBtn.texiao = texiao
        -- _campBtn.texiao:setVisible(false)
        -- local jiantou = cc.Sprite:create("res/image/camp/jt.png") 
        -- jiantou:setPosition(_campBtn:getContentSize().width/2,_campBtn:getContentSize().height+40) 
        -- _campBtn:addChild(jiantou)
        -- _campBtn.jiantou = jiantou 
        -- _campBtn.jiantou:setVisible(false)


        ----动画 
        -- _spine = sp.SkeletonAnimation:create( "res/image/camp/anniu.json", "res/image/camp/anniu.atlas", 1.0)
        -- _campBtn:addChild(_spine)
        -- _spine:setPosition(_campBtn:getContentSize().width / 2,_campBtn:getContentSize().height / 2)        
        -- _spine:setAnimation(0,actName[i],true)
        -- _campBtn.spine = _spine
        -- --先透明，等给了资源在放开
        -- _campBtn.spine:setOpacity(0)
    end 
    if self._campID == 1 then
		local tuijian = cc.Sprite:create("res/image/camp/regist/tuijian.png")
		campbg1:addChild(tuijian)
        tuijian:setPosition(campbg1:getContentSize().width *0.5,campbg1:getContentSize().height *0.5 + 10)
    elseif self._campID == 2 then
		local tuijian = cc.Sprite:create("res/image/camp/regist/tuijian.png")
		campbg2:addChild(tuijian)
        tuijian:setPosition(campbg2:getContentSize().width *0.5,campbg2:getContentSize().height *0.5 + 10)
    end
    -- self:doSelect(self._campID,true)
end

function ZhongZuRegisterLayer:getARandomName( )
    local prefixLen = #PrefixName
    local midLen = #MidName
    local suffixLen = #SuffixName
    local hasMid = math.random(100) % 2
    local index = math.random(prefixLen)
    local name = PrefixName[index]
    if hasMid == 1 then 
        index = math.random(midLen)
        name = name..MidName[index]
    end 
    index = math.random(suffixLen)
    name = name..SuffixName[index]
    return name
end

function ZhongZuRegisterLayer:doEnterGame()
    local username = self:getARandomName()
    local camp = self._selectedCampID
    -- local time = os.clock()

    XTHDHttp:requestAsyncInGameWithParams({        
        modules = "changeCamp?",
        params = {campId = camp},
        successCallback = function(data)
            if data.result == 0 then
                gameUser.setCampID(camp)
                if self._callback then
                    gameUser.setGuideID({group = 1,index = 1})
                    -- YinDaoMarg:getInstance():updateServer({group = 1,index = 1})
                    -------更新玩家数据----------
                    if data and data.bagItems then ------更新背包数据 
                        DBTableItem.insertMultiData(gameUser.getUserId(),data.bagItems)
                    end
                    if data and data.addPet then ------更新英雄数据 
                        DengLuUtils.UpdateHerosAndEquipmentsData({data.addPet})
                    end 
                    if data.property then -----更新玩家属性值 
                        for k,v in pairs(data.property) do 
                            local values = string.split(v,',')
                            DBUpdateFunc:UpdateProperty("userdata",values[1],values[2],nil,true)
                        end 
                    end 
                    ----------------------------
                    self._callback(data)
                    self:removeFromParent()
                end
            else
                XTHDTOAST(data.msg)
            end 
        end,--成功回调 
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZhongZuRegisterLayer:onEnter( )
    UserDataMgr:preLoadSpine()----
end

function ZhongZuRegisterLayer:onExit( )
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/camp/camp_regi_bg.jpg")
    textureCache:removeTextureForKey("res/image/camp/xzy.png")
    textureCache:removeTextureForKey("res/image/camp/anniu.png")
end

function ZhongZuRegisterLayer:doSelect(which,isFirst)
    if which == self._selectedCampID then 
        return 
    end 
    -- local actName = {"gm","ay"}
    local target = self._campBtn[which]
    if target then 
        if which == 1 then
            self._campBtn[which]:setSelected(true)
            self._campBtn[2]:setSelected(false)
        elseif which == 2 then
            self._campBtn[which]:setSelected(true)
            self._campBtn[1]:setSelected(false)
        end
    --     target:stopAllActions()
    --     target:setScale(1.0)
    --     if isFirst then   ------是否是刚进来
    --         if target.spine then  
    --             target.spine:setAnimation(0,actName[which].."1",true)
    --                 target.texiao:setVisible(true)
    --                 target.jiantou:setVisible(true)
                    
    --         end 
    --     else 
    --         local time = 0.02
    --         local action = cc.ScaleTo:create(time,0.8)
    --         local action2 = cc.ScaleTo:create(time,1.5)
    --         local action3 = cc.ScaleTo:create(time,1.15)   
    --         target:runAction(cc.Sequence:create(action,action2,action3,cc.CallFunc:create(function( )
    --             if target.spine then 
    --                 target.spine:setAnimation(0,actName[which].."1",true)
    --                 --ly
    --                 if which == 1 then
    --                 self._campBtn[which].texiao:setVisible(true)
    --                 self._campBtn[which].jiantou:setVisible(true)
    --                 self._campBtn[2].texiao:setVisible(false)
    --                 self._campBtn[2].jiantou:setVisible(false)
                    
    --                 elseif which == 2 then
    --                 self._campBtn[which].texiao:setVisible(true)
    --                 self._campBtn[which].jiantou:setVisible(true)
    --                 self._campBtn[1].texiao:setVisible(false)
    --                 self._campBtn[1].jiantou:setVisible(false)
    --                 end
                    
    --             end 
    --         end)))
    --     end 
        if self._selectedBtn then 
            self._selectedBtn:setScale(1.0)
            -- self._selectedBtn.spine:setAnimation(0,actName[3 - which],true)
            -- self._selectedBtn.texiao:setVisible(true)
            -- self._selectedBtn.jiantou:setVisible(true)
        end     
        self._selectedBtn = target
    end 
    ---------刷新数据     
    if self._selectedCampID ~= which then 
        -- if self._campTips then 
        --     self._campTips:setString(LANGUAGE_CAMPCHOOSETIP[which])
        -- end 
        -- if self._campIcon then 
        --     self._campIcon:setTexture("res/image/camp/camp_circle_icon"..which..".png")
        -- end 
        self._selectedCampID = which
    end 
end

return ZhongZuRegisterLayer