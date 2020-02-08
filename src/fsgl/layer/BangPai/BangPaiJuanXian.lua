--createdBy xingchen 
--2015/12/8
--帮派战初始界面
local BangPaiJuanXian = class("BangPaiJuanXian",function()
		return XTHD.createBasePageLayer({bg="res/image/guild/worship/worship_bg.png"})
	end)

function BangPaiJuanXian:ctor(_data)
	self._data = _data or {}
    self._btn_effect = {}
    self.worshipItems = {}
	self._JiBaibtn = {}
	self.staticData = {}
	-- self:setGuildWarData(_data)
	self:setStaticData()
	self:initLayer()
end

function BangPaiJuanXian:onEnter( ... )
     --祭拜奖励列表请求
     self:refushRedPoint()
end

function BangPaiJuanXian:onCleanup( )
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("res/spine/effect/guild_effect/xuanzhuan.plist")
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/guild/worship/worship_bg.jpg")
    textureCache:removeTextureForKey("res/image/guild/worship/xiang.png")
    for i=1,3 do
        -- textureCache:removeTextureForKey("res/image/guild/worship/worship_image" .. i .. ".png")
        textureCache:removeTextureForKey("res/image/guild/worship/worship_textBg" .. i .. ".png")
    end
end

function BangPaiJuanXian:initLayer()
    local _upPosY = self:getContentSize().height - self.topBarHeight - 40
    --剩余祭拜次数
	local _lastWorshipTitle = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT_3 .. "：",18)
	_lastWorshipTitle:setAnchorPoint(cc.p(0,0.5))
    _lastWorshipTitle:setPosition(cc.p(15,_upPosY))
    _lastWorshipTitle:setColor(XTHD.resource.textColor.huihuang_text)
	self:addChild(_lastWorshipTitle)
	local _lastWorshipCount = XTHDLabel:create(self._data["surplusCount"] or 0,20)
	self._worship_times = _lastWorshipCount
	_lastWorshipCount:setColor(XTHD.resource.textColor.huihuang_text)
	_lastWorshipCount:setAnchorPoint(cc.p(0,0.5))
	_lastWorshipCount:setPosition(cc.p(_lastWorshipTitle:getBoundingBox().x+_lastWorshipTitle:getBoundingBox().width,_upPosY))
	self:addChild(_lastWorshipCount)

    self._worship_times_nums = tonumber(self._data["surplusCount"] or 0)

	--祭拜点
	--奖励盒子
    local reward_box = XTHD.createButton({
            normalFile = "res/image/guild/worship/worship_box_normal.png",
            selectedFile = "res/image/guild/worship/worship_box_selected.png"
        })
    reward_box:setPosition(self:getContentSize().width - 35,_upPosY-30)
    self:addChild(reward_box)
	self._reward_box = reward_box
    reward_box:setTouchEndedCallback(function (  )
        requires("src/fsgl/layer/BangPai/BangPaiJuanXianJiangLi.lua"):createOne(self)
    end)
    --文字捐献宝箱：
    local jxLabel = XTHDLabel:create("捐献宝箱:",18)
    jxLabel:setAnchorPoint(1,0.5)
    jxLabel:setColor(XTHD.resource.textColor.huihuang_text)
    jxLabel:setPosition(reward_box:getBoundingBox().x-20,reward_box:getPositionY())
    self:addChild(jxLabel)
    --改的，可领取奖励红点
	--self.red_point = nil
    self.red_point = XTHD.createSprite("res/image/common/heroList_redPoint.png")
    self.red_point:setPosition(reward_box:getContentSize().width-15,reward_box:getContentSize().height-15)
    reward_box:addChild(self.red_point)
    self.red_point:setVisible(false)
    self.red_point:setTag(2)
	self.red_point:setName("red_point")
    XTHD.addEventListener({name = "GuildWorshipreward",callback = function( event )
        if event.data.name == "reward" then
            if tonumber(event.data.visible) == 1 and self.red_point ~=nil then
                self.red_point:setVisible(true)
            end
            
        end
    end})
    XTHD.addEventListener({name = "GuildWorshipreward2",callback = function( event )
        if event.data.name == "reward" then
            if event.data.visible and self.red_point ~= nil then
                self.red_point:setVisible(false)
            end
            
        end
    end})

   
    --帮派总祭拜点
    local worship_points_iamge = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT_4 .. "：",18)
    worship_points_iamge:setAnchorPoint(1,0.5);
    worship_points_iamge:setColor(XTHD.resource.textColor.huihuang_text)
    worship_points_iamge:setPosition(reward_box:getBoundingBox().x,reward_box:getPositionY()+50)
    self:addChild(worship_points_iamge)

    local worship_points_label = XTHDLabel:create(self._data["guildWorship"] or 0,20)
    worship_points_label:setAnchorPoint(0,0.5)
    worship_points_label:setColor(XTHD.resource.textColor.huihuang_text)
    worship_points_label:setPosition(worship_points_iamge:getBoundingBox().x +worship_points_iamge:getBoundingBox().width,worship_points_iamge:getPositionY())
    self:addChild(worship_points_label)
    self._worship_points = worship_points_label;

    local _worshipBg = cc.Sprite:createWithTexture(nil, cc.rect(0,0,self:getContentSize().width,455))
    _worshipBg:setOpacity(0)
    _worshipBg:setPosition(cc.p(self:getContentSize().width/2, _lastWorshipTitle:getBoundingBox().y/2))
    self:addChild(_worshipBg)
    local _worshipPos = {
	    cc.p(_worshipBg:getContentSize().width/2-290,150),
	    cc.p(_worshipBg:getContentSize().width/2,150),
	    cc.p(_worshipBg:getContentSize().width/2+290,140),
	}
    self.worshipItems = {}
    for i=1,3 do
    	local _worshipSp = self:initWorshipItem(i)
        self.worshipItems[i] = _worshipSp
        _worshipSp:setAnchorPoint(cc.p(0.5,0))
    	_worshipSp:setPosition(cc.p(_worshipPos[i].x ,_worshipPos[i].y+135))
    	_worshipBg:addChild(_worshipSp)
    end


end



function BangPaiJuanXian:initWorshipItem(_idx)
	local _staticData = self.staticData[_idx] or {}
	-- local _worshipSp = sp.SkeletonAnimation:create("res/image/guild/worship/xiang.json", "res/image/guild/worship/xiang.atlas", 1.0)
    -- _worshipSp:setAnimation(0,"xiang" .. _idx,true)

    local _worshipSp = sp.SkeletonAnimation:create("res/image/guild/worship/huolu.json", "res/image/guild/worship/huolu.atlas", 1.0)
    _worshipSp:setAnimation(0,"0" .. _idx,true)

    -- cc.Sprite:create("res/image/guild/worship/worship_image" .. _idx .. ".png")
	local _btnBg = cc.Sprite:create("res/image/guild/worship/worship_btnBg.png")
	_btnBg:setAnchorPoint(cc.p(0.5,1))
	_btnBg:setPosition(cc.p(_worshipSp:getContentSize().width/2,65-150+5*_idx))
	_worshipSp:addChild(_btnBg)
	local btnImg = {"green","blue","orange"}
    -- local btnText = {"免费祭拜","高级祭拜","至尊祭拜"}
    --三个祭拜的按钮
    local _btn = XTHD.createCommonButton()
    if _idx == 1 then
       _btn = XTHD.createCommonButton({
            btnColor = "write_1",
            isScrollView = false,
            text = LANGUAGE_KEY_GUILDWORSHIP_TEXT[_idx],
            btnSize = cc.size(143,46),
        })
    else
        _btn = BangPaiFengZhuangShuJu.createGuildBtnNode({
            btnSize = cc.size(135,46)
            ,text = LANGUAGE_KEY_GUILDWORSHIP_TEXT[_idx]
            ,imgStr = "header_ingot",
            btnColor = "write_1",
            fontColor = XTHD.resource.btntextcolor.write
        })
    end
	self._JiBaibtn[#self._JiBaibtn + 1] = _btn
    
	_btn:setAnchorPoint(cc.p(0.5,1))
	_btn:setPosition(cc.p(_btnBg:getContentSize().width/2,_btnBg:getContentSize().height+20))
	_btnBg:addChild(_btn)
	_btn:setTouchEndedCallback(function()
            self:worship_do_http(_idx)
            self:refushRedPoint()

		end)
	--背景
	local _textBg = cc.Sprite:create("res/image/guild/worship/worship_textBg" .. _idx .. ".png")
	_textBg:setAnchorPoint(cc.p(0.5,1))
	_textBg:setPosition(cc.p(_worshipSp:getContentSize().width/2,_btnBg:getBoundingBox().y-5))
    _worshipSp:addChild(_textBg)
    _textBg:setScale(0.8)

    --普通捐献，中级捐献，高级捐献
    local _textlabel = cc.Sprite:create("res/image/guild/worship/worship_text" .. _idx .. ".png")
    _textlabel:setPosition(_textBg:getContentSize().width/2,_textBg:getContentSize().height-_textlabel:getContentSize().height/2)
    _textlabel:setAnchorPoint(cc.p(0.5,0))
    _textBg:addChild(_textlabel)

	local array_label = {}
	for j=1,3 do
        local label = XTHDLabel:create("0",22)
        label:setColor(XTHD.resource.color.gray_desc)
        label:setPosition(_textBg:getContentSize().width/2,_textBg:getContentSize().height - 52-(j-1)*25)
        _textBg:addChild(label)
        array_label[#array_label+1] = label
    end
    if _staticData then
        array_label[1]:setString(LANGUAGE_KEY_GUILD_TEXT.guildWorshipDotTextXc .. "+".._staticData["jibaidian"])
        array_label[2]:setString(LANGUAGE_KEY_GUILD_TEXT.guildContributionTextXc .. "+".._staticData["gongxian"])
        array_label[3]:setString(LANGUAGE_KEY_GUILD_TEXT.guildExpTitleTextXc .. "+".._staticData["exp"])
    end

    --祭拜花费
    local _costPosY = _textBg:getContentSize().height - 25
    -- if tonumber(_staticData["cost"]) > 0 then

    --     local gold_icon = cc.Sprite:create("res/image/common/header_ingot.png");

    --     local cost_num = getCommonWhiteBMFontLabel(_staticData["cost"]) 
    --     cost_num:setAnchorPoint(0,0.5)
    --     gold_icon:setPosition(cc.p(_textBg:getContentSize().width/2 - cost_num:getContentSize().width/2,_costPosY))
    --     cost_num:setPosition(gold_icon:getBoundingBox().x+gold_icon:getBoundingBox().width,_costPosY-7)
    --     _textBg:addChild(gold_icon)
    --     _textBg:addChild(cost_num)
    -- else
    --     local null_image = cc.Sprite:create("res/image/guild/worship/worship_null.png");
    --     null_image:setPosition(_textBg:getContentSize().width/2,_costPosY)
    --     _textBg:addChild(null_image)
    -- end

    --能够祭拜时的特效
    local effect = self:playAnimate()
    -- effect:setScaleX(_btn:getContentSize().width/102)
    effect:setPosition(_btn:getContentSize().width/2,_btn:getContentSize().height/2+5)
    -- effect:setVisible(false)
	effect:setName("effect")
    _btn:addChild(effect,100)
    if self._btn_effect[_idx]~=nil then
    	self._btn_effect[_idx]:removeFromParent()
    	self._btn_effect[_idx] = nil
    end
    self._btn_effect[_idx] = effect
    self:checkEffect()

	return _worshipSp
end


--检测是否播放特效
function BangPaiJuanXian:checkEffect(  )
    --如果没有祭拜次数，则不显示特效
    -- print("self._data",self._worship_times_nums,#self._btn_effect)
    if tonumber(self._worship_times_nums) <= 0 then
        for i=1,#self._btn_effect do
            if self._btn_effect[i] ~= nil then
                -- print("self._dataasdfasdfasdfsdfd")
                self._btn_effect[i]:setVisible(false)
            end
        end
        return
    end

    if tonumber(gameUser.getIngot()) < 500 and tonumber(gameUser.getIngot()) >= 100 and tonumber(self._worship_times_nums) >= 0 then
        -- print("self._dataasdfasdfasdfsdfd 1 1")
        if self._btn_effect[3] ~= nil then
            -- print("self._dataasdfasdfasdfsdfd 1 2")
            self._btn_effect[3]:setVisible(false)
        end
    elseif tonumber(gameUser.getIngot()) < 100 and tonumber(self._worship_times_nums) >= 0 then
        -- print("self._dataasdfasdfasdfsdfd 2 1")
        if self._btn_effect[2] ~= nil then
            -- print("self._dataasdfasdfasdfsdfd 2 2")
            self._btn_effect[2]:setVisible(false)
        end
    else
        -- print("put out else")
    end


end

--能够祭拜的特效
function BangPaiJuanXian:playAnimate(  )
    local _btnEffect = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)
    _btnEffect:setAnimation( 0, "querenjinjie", true)

    -- cc.SpriteFrameCache:getInstance():addSpriteFrames("res/spine/effect/guild_effect/xuanzhuan.plist", "res/spine/effect/guild_effect/xuanzhuan.png")
    -- local frames_array = {}
    -- for i=1,8 do
    --     local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("ui_0"..i..".png")
    --     frames_array[#frames_array+1] = frame
    -- end

    -- local first_frame = cc.Sprite:createWithSpriteFrame( frames_array[1] )
    -- first_frame:setScale(1.1)
    -- local animation = cc.Animation:createWithSpriteFrames(frames_array, 0.1)
    -- local animate = cc.Animate:create(animation)
    -- first_frame:runAction(cc.RepeatForever:create(cc.Sequence:create(animate,
    --         cc.DelayTime:create(0.01)
    --     )))

    return _btnEffect
end

function BangPaiJuanXian:worship_do_http( _type )
	
    ClientHttp.httpGuildWorship(self,function ( data )
        XTHDTOAST(LANGUAGE_WORSHIP_SUCCESS)
        self._data = data
        --刷新祭拜剩余次数
        self._worship_times:setString(self._data["surplusCount"] or 0)
        self._worship_times_nums = tonumber(self._data["surplusCount"])
		self:checkEffect()

        --刷新祭拜点
        self._worship_points:setString(self._data["guildWorship"] or 0)
        -- self._worship_points_iamge:setPosition(self._worship_points:getPositionX()-self._worship_points:getContentSize().width-10,self._worship_points:getPositionY())
        --刷新元宝
        if data["ingot"] then
            gameUser.setIngot(data["ingot"])
        end
        local mDatas = BangPaiFengZhuangShuJu.getGuildData()
        mDatas.level = tonumber(data.level) or 1
        mDatas.curExp = tonumber(data.curExp) or 0
        mDatas.maxExp = tonumber(data.maxExp) or 0
        if mDatas.list and #mDatas.list > 0 then
            for k,v in pairs(mDatas.list) do
                if v.charId == gameUser.getUserId() then
                    v.dayContribution = tonumber(data.dayContribution) or 0
                    v.totalContribution = tonumber(data.totalContribution) or 0
                    break
                end
            end
        end
        BangPaiFengZhuangShuJu.setGuildData(mDatas)
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_INFO})
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
		XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_TASKLIST})
		--XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDRANKLIST})

        if self.worshipItems[tonumber(_type)]~=nil then
            -- self.worshipItems[tonumber(_type)]:setAnimation(0,"xiang" .. _type .. "_" .. _type,false)
            self.worshipItems[tonumber(_type)]:addAnimation(0,"0" .. _type,true)
        end

        local _staticData = self.staticData[tonumber(_type)]
		local _colorType = "RED"
        XTHD.createAttrToastByTable({
                [1] = {num = _staticData["jibaidian"],attr = LANGUAGE_KEY_GUILD_TEXT.guildWorshipDotTextXc,},
                [2] = {num = _staticData["gongxian"],attr = LANGUAGE_KEY_GUILD_TEXT.guildContributionTextXc},
                [3] = {num = _staticData["exp"],attr = LANGUAGE_KEY_GUILD_TEXT.guildExpTitleTextXc},
            },nil,self._JiBaibtn[_type],_colorType)
        
         --红点
            -- if self._data["redPoint"] == 0 then
            --     self.red_point:setVisible(false)
            -- else
            --     self.red_point:setVisible(true)
            -- end
    end,{worshipType = _type})

    


    
end

--刷新小红点
function BangPaiJuanXian:refushRedPoint()
    -- 祭拜奖励列表请求
     ClientHttp.httpGuildWorshipListReward(self, function ( data )
        local dataList = data["list"]
        for i=1,#dataList do
             --传消息
            XTHD.dispatchEvent({name = "GuildWorshipreward",data = {["name"] = "reward",["visible"] = dataList[i]["state"]}})    
        end
        
    end)
end

-- function BangPaiJuanXian:setRedPoint( is_visable )
--     self.red_point:setVisible(is_visable)
-- end

function BangPaiJuanXian:setStaticData()
	self.staticData = {}
	self.staticData = gameData.getDataFromCSV("SectDonate")
end

function BangPaiJuanXian:create(data)
	local _layer = self.new(data)
	return _layer
end

return BangPaiJuanXian