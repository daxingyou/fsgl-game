--[[
	开始挑战界面新UI
	by andong
	11-19
]]--
local LiLianStageLayer = class("LiLianStageLayer", function()
	return XTHD.createBasePageLayer()
end)


function LiLianStageLayer:ctor( params )
     -- print("--------------精英和普通副本章节的数据为--------------")
     -- print_r(params)

	if params.bgFile then
		self:getChildByName("BgSprite"):setTexture(params.bgFile)
	end
	local mask = cc.LayerColor:create()
    mask:setContentSize(self:getContentSize())
    mask:setColor(cc.c3b(0,0,0))
    mask:setOpacity(100)
    self:addChild(mask)
	self.stage_data = params.data
	self._stageType = params.stageType
	self._guideGroup = 1
	self:init()
	self:requestFirstOne(params.stageType,params.data.instancingid,params.data.chapterid)
end

--向服务器请求第一个通过此章节的人
function LiLianStageLayer:requestFirstOne(chaptertype,levelid,chapterid)
	-- print("当前的副本类型是："..chaptertype.."       章节id："..chapterid.."      关卡id："..levelid)
	local cType
	if chaptertype == ChapterType.ELite then
        cType = "elite"
    elseif chaptertype == ChapterType.Normal then
        cType = "ectype"
    else
        cType = "diffculty"
	end
	ClientHttp:requestAsyncInGameWithParams({
        modules = "ectypeRecordFristName?",
        params  = {ectypeType = cType,ectypeId = levelid},
        successCallback = function( data )
            -- print("请求普通精英副本千古留名服务器返回参数为：")
            -- print_r(data)
            if tonumber(data.result) == 0 then
                if data.name ~= "" then
	            	local str = "全服首位通关者："..data.name
	                self.first_name:setString(str)
                end
            else
                XTHDTOAST(data.msg)
            end 
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    })
end

function LiLianStageLayer:init( )--在副本里添加了宝箱这个东西 所以弹出界面增加一个类型
	self._topBar = self:getChildByName("TopBarLayer1") --userinfo
	self._topBar:setNeedReleaseGuide(false)
	local stage_data = self.stage_data
	
    --backGround
    self._bg_sp = cc.Sprite:create("res/image/common/stagelayer.png")
    self._bg_sp:setName("self._bg_sp")
    self._bg_sp:setPosition(self:getContentSize().width/2, self:getContentSize().height/2 - self.topBarHeight/2)
    -- self._bg_sp:setPosition(self:getContentSize().width/2, self:getContentSize().height/2 - 40)
    self:addChild(self._bg_sp)

	local title = "res/image/public/normal.png"
	if self._stageType == ChapterType.ELite then
		title = "res/image/public/jingying.png"
	end
	XTHD.createNodeDecoration(self._bg_sp,title)

    local bg2 = cc.Sprite:create("res/image/plugin/stagepop/bg2.png")
    local lessH = self._bg_sp:getContentSize().height/2 - bg2:getContentSize().height/2
	bg2:setPosition(self._bg_sp:getContentSize().width/2, self._bg_sp:getContentSize().height/2 - self.topBarHeight/2 + lessH)
	bg2:setOpacity(0)
    self._bg_sp:addChild(bg2)

	-- local popNode = XTHDImage:create("res/image/plugin/stagepop/pop_bg.png")
	local popNode = cc.Sprite:create()
	popNode:setContentSize(cc.size(613,374))
	self.popNode = popNode
	popNode:setPosition(self._bg_sp:getContentSize().width / 2,self._bg_sp:getContentSize().height / 2)
	self._bg_sp:addChild(popNode)
	

	local stage_name = XTHDLabel:create(stage_data.name,28)
	local _name_color = cc.c3b(192,45,0)
	local _first_color = cc.c3b(38,106,175)
	if self._stageType == ChapterType.ELite then
		_name_color = cc.c3b(38,106,175)
		_first_color = cc.c3b(192,45,0)
	end
	stage_name:setColor(_name_color)
	stage_name:setAnchorPoint(cc.p(0,0.5))
	stage_name:setPosition(40,self._bg_sp:getContentSize().height - 50 )
	self._bg_sp:addChild(stage_name)

    --千古留名
    local first_name = XTHDLabel:create("",20)
    first_name:setColor(_first_color)
    first_name:setAnchorPoint(cc.p(0,0.5))
    first_name:setPosition(40,self._bg_sp:getContentSize().height - 90 )
    self._bg_sp:addChild(first_name)
    self.first_name = first_name

	local stage_desc = XTHDLabel:create(stage_data.description,18)
	stage_desc:setColor(cc.c3b(128,112,91))
	stage_desc:setAnchorPoint(0,1)

	if stage_desc:getContentSize().width > 355 then
	    stage_desc:setDimensions(400,50)
	else
		stage_desc:setDimensions(400,34)
	end

	stage_desc:setPosition(45,self._bg_sp:getContentSize().height/2+130)
	self._bg_sp:addChild(stage_desc)


	--通关记录
	local recordLab = XTHDLabel:create(LANGUAGE_KEY_FINISHRECORD .. ":",18)
	recordLab:setPosition(self._bg_sp:getContentSize().width/2 + 130,self._bg_sp:getContentSize().height - 60)
	recordLab:setAnchorPoint(cc.p(0,0.5))
	recordLab:setColor(cc.c3b(69,32,120))
	self._bg_sp:addChild(recordLab)

	local recordBg = cc.Sprite:create("res/image/plugin/stagepop/recordBg.png")
	recordBg:setPosition(self._bg_sp:getContentSize().width - recordBg:getContentSize().width/2 - 10+50, self._bg_sp:getContentSize().height - 115)
	self._bg_sp:addChild(recordBg)
	recordBg:setScale(0.8)
	local _star =  nil
	if self._stageType == ChapterType.Normal then
		_star =CopiesData.GetNormalStar(stage_data.instancingid)
	elseif self._stageType == ChapterType.ELite then
		_star =CopiesData.GetEliteStar(stage_data.instancingid)
	end
	for i=1,3 do

		local _star_sp
		if _star and tonumber(_star) >= i then
			_star_sp = cc.Sprite:create("res/image/plugin/stagepop/star_l.png")
			_star_sp:setPosition(recordBg:getContentSize().width/2+(i-2)*75, recordBg:getContentSize().height/2)
			_star_sp:setScale(1.5)
			recordBg:addChild(_star_sp)
		else
			_star_sp = cc.Sprite:create("res/image/plugin/stagepop/star_g.png")
			_star_sp:setPosition(recordBg:getContentSize().width/2+(i-2)*75, recordBg:getContentSize().height/2)
			_star_sp:setScale(1.5)
			recordBg:addChild(_star_sp)
		end
		_star_sp:setScale(0.9)
	end
	if _star == nil or tonumber(_star) < 3 then
		local tipLab = XTHDLabel:create(LANGUAGE_KEY_OPENSWEEP,18)
		tipLab:setAnchorPoint(cc.p(0,0.5))
		tipLab:setPosition(self._bg_sp:getContentSize().width/2 + 130,recordBg:getPositionY() - 70)
		tipLab:setColor(cc.c3b(69,32,17))
		self._bg_sp:addChild(tipLab)

	end


	-- local consumption_bg = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/scale9_bg_18.png")
	local consumption_bg = ccui.Scale9Sprite:create("res/image/plugin/stagepop/xh_bg.png")
	consumption_bg:setContentSize(cc.size(430, 52))
	consumption_bg:setAnchorPoint(0,0.5)
	consumption_bg:setPosition(50,self._bg_sp:getContentSize().height / 2 + 30)
	self._bg_sp:addChild(consumption_bg)

	local consumption = XTHDLabel:create(LANGUAGE_VERBS.cost1..":",18)-------消		耗: ",18)
	consumption:setColor(cc.c3b(69,32,17))
	consumption:setAnchorPoint(0,0.5)
	consumption:setPosition(20,consumption_bg:getContentSize().height / 2 )
	consumption_bg:addChild(consumption)

	local _spPhysical = cc.Sprite:create("res/image/common/header_tili.png");
	_spPhysical:setAnchorPoint(cc.p(0.5, 0.5));
	_spPhysical:setPosition(cc.p(consumption:getPositionX() + 40 + _spPhysical:getContentSize().width,consumption_bg:getContentSize().height/2));
	consumption_bg:addChild(_spPhysical);

	local label_consumption = XTHDLabel:create(stage_data.hpcost,24)
	label_consumption:setColor(cc.c3b(167,0,0))
	label_consumption:setPosition(_spPhysical:getPositionX() + _spPhysical:getContentSize().width,consumption_bg:getContentSize().height / 2)
	consumption_bg:addChild(label_consumption)

	--经营副本有个购买次数的小东西
	if self._stageType == ChapterType.ELite then

		-- print("挑战次数 ===== ")
		local challage_label = XTHDLabel:create(LANGUAGE_TIPS_WORDS189,18)---------"挑战次数: ",18)
		challage_label:setColor(cc.c3b(69,32,17))
		challage_label:setAnchorPoint(cc.p(0,0.5))
		challage_label:setPosition(35 + label_consumption:getPositionX() + label_consumption:getContentSize().width,consumption_bg:getContentSize().height/2 )
		consumption_bg:addChild(challage_label)

		local dao = cc.Sprite:create("res/image/plugin/stagepop/knife.png")
		dao:setAnchorPoint(cc.p(0,0.5))
		dao:setPosition(10 + challage_label:getPositionX() + challage_label:getContentSize().width,consumption_bg:getContentSize().height/2 )
		consumption_bg:addChild(dao)

		-- self._last_fight_times = DBTableInstance.getEliteFightTimes(gameUser.getUserId(),stage_data.instancingid) or 3
		self._last_fight_times =CopiesData.GetEliteTimes(stage_data.instancingid) or 3
		-- self._reset_times = DBTableInstance.getEliteResetTimes(gameUser.getUserId(),stage_data.instancingid) or 0
		self._reset_times = CopiesData.GetEliteRefreshTimes(stage_data.instancingid ) or 0
		local challage_time_txt = XTHDLabel:create(self._last_fight_times.."/3",18) 
		challage_time_txt:setColor(cc.c3b(167,0,0))
		challage_time_txt:setAnchorPoint(cc.p(0,0.5))
		challage_time_txt:setPosition(10 + dao:getPositionX() + dao:getContentSize().width,consumption_bg:getContentSize().height/2 )
		consumption_bg:addChild(challage_time_txt)
		self._challage_time_txt = challage_time_txt
		local add_time_btn = XTHDPushButton:createWithParams({
			selectedFile = "res/image/common/btn/btn_add_selected.png",
			normalFile = "res/image/common/btn/btn_add_normal.png",
			musicFile = XTHD.resource.music.effect_btn_common,
			pos = cc.p(30 + challage_time_txt:getPositionX() + challage_time_txt:getContentSize().width,consumption_bg:getContentSize().height/2 )		
		})
		add_time_btn:setScale(0.8)
		
		add_time_btn:setTouchEndedCallback(function()
				if tonumber(self._last_fight_times) > 0  then
					XTHDTOAST(LANGUAGE_FORMAT_TIPS39(self._last_fight_times))-----"当前剩余挑战次数为".. tostring(self._last_fight_times) .."次,无法购买!")
					return
				end

			 local _confirmLayer = XTHDConfirmDialog:createWithParams( {
	            rightCallback  = function ()
	            	ClientHttp:requestAsyncInGameWithParams({
						modules = "resetEctype?",
			            params = {ectypeId=stage_data.instancingid},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
			            successCallback = function(net_data)
				            if tonumber(net_data.result) == 0 then
				            	self._last_fight_times = tonumber(net_data["surplusCount"])
				            	self._reset_times = tonumber(net_data["resetCount"])
				            	challage_time_txt:setString(net_data["surplusCount"].."/3")
				            	self:setSweepBtnStatus()
				            	 -- DBTableInstance.updateEliteFightTimes(gameUser.getUserId(),stage_data.instancingid,net_data["surplusCount"])
								CopiesData.ChangeEliteTimes(stage_data.instancingid,net_data["surplusCount"])
								 -- DBTableInstance.updateEliteResetTimes(gameUser.getUserId(),stage_data.instancingid,net_data["resetCount"])
				            	CopiesData.ChangeEliteRefreshTimes(stage_data.instancingid,net_data["resetCount"])
				            	if net_data["ingot"] then
					            	gameUser.setIngot(net_data["ingot"])
					            end
				            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
				            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
				            	

				            else
				            	XTHDTOAST(net_data.msg)
				            end
			            end,--成功回调
			            failedCallback = function()
			                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
			            end,--失败回调
			            targetNeedsToRetain = self,--需要保存引用的目标
			            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
			        })
	            end,
	            msg = LANGUAGE_FORMAT_TIPS40((self._reset_times+1)*30)------"您确定要花费".. tostring((self._reset_times+1)*30).."元宝购买挑战次数吗？"
	        } );
	        self:addChild(_confirmLayer)
		end)
		consumption_bg:addChild(add_time_btn);
	
	else
		-- print("挑战次数 ===== ")
		local challage_label = XTHDLabel:create(LANGUAGE_TIPS_WORDS189,18)---------"挑战次数: ",18)
		challage_label:setColor(cc.c3b(69,32,17))
		challage_label:setAnchorPoint(cc.p(0,0.5))
		challage_label:setPosition(35 + label_consumption:getPositionX() + label_consumption:getContentSize().width,consumption_bg:getContentSize().height/2 )
		consumption_bg:addChild(challage_label)

		local dao = cc.Sprite:create("res/image/plugin/stagepop/knife.png")
		dao:setAnchorPoint(cc.p(0,0.5))
		dao:setPosition(10 + challage_label:getPositionX() + challage_label:getContentSize().width,consumption_bg:getContentSize().height/2 )
		consumption_bg:addChild(dao)

		local infinite = XTHDLabel:create(LANGUAGE_ADJ.nolimit,18)---------"挑战次数: ",18)
		infinite:setColor(cc.c3b(167,0,0))
		infinite:setAnchorPoint(cc.p(0,0.5))
		infinite:setPosition(10 + dao:getPositionX() + dao:getContentSize().width,consumption_bg:getContentSize().height/2 )
		consumption_bg:addChild(infinite)

	end
	local line_sp = ccui.Scale9Sprite:create(cc.rect(0,0,20,2),"res/image/ranklistreward/splitX.png")
	line_sp:setContentSize(cc.size(450,2))
	line_sp:setAnchorPoint(0.5,0.5)
	line_sp:setPosition(40 + consumption_bg:getContentSize().width / 2,self._bg_sp:getContentSize().height/2-50)
	self._bg_sp:addChild(line_sp)

	
	--587*119
	--local fall_bg = ccui.Scale9Sprite:create(cc.rect(14,15,1,1),"res/image/common/scale9_bg_5.png")
	local fall_bg = cc.Sprite:create()
	fall_bg:setContentSize(cc.size(500,150))
	fall_bg:setAnchorPoint(0.5,1)
	fall_bg:setPosition(fall_bg:getContentSize().width / 2 + 40,fall_bg:getContentSize().height +80)
	self._bg_sp:addChild(fall_bg)

	local label_probability_fall = XTHDLabel:create(LANGUAGE_TIPS_WORDS190,18)------"可能获得:",18)
	label_probability_fall:setColor(consumption:getColor())
	label_probability_fall:setAnchorPoint(0,1)
	label_probability_fall:setPosition(5,fall_bg:getContentSize().height-8)
	fall_bg:addChild(label_probability_fall)

	local fall_items = string.split(stage_data.items,"#")
	if tonumber(stage_data["bossid"]) == -1 then
		local table  = string.split(stage_data.firstiawardid,",")
	    fall_items={}
		for k,v in ipairs(table) do
			v=string.split(v,"#")
			fall_items[#fall_items+1]=v
		end
	end
	-- fall_items[#fall_items+1] = fall_items[2] --test

	--征战10次
	local sweep_times = 1
	--按钮bg
	-- local btn_bg=cc.Sprite:create("res/image/plugin/stagepop/btn_bg.png")
	-- btn_bg:setAnchorPoint(1,0.5)
	-- btn_bg:setPosition(fall_bg:getContentSize().width-5,fall_bg:getContentSize().height/2)
	-- fall_bg:addChild(btn_bg)
	local label_sp = nil
	if self._stageType == ChapterType.Normal then
		label_sp = XTHD.resource.getButtonImgTxt("saodangshici_lan")
		sweep_times = 10
	elseif self._stageType == ChapterType.ELite then
		label_sp =  XTHD.resource.getButtonImgTxt("saodangsanci_lan")
		sweep_times = 3
	end
	-- local sweepTen_disableNode = cc.Sprite:create("res/image/common/btn/btn_gary.png")
	local sweepTen_disableNode = ccui.Scale9Sprite:create("res/image/common/btn/btn_write_1_disable.png")
	sweepTen_disableNode:setContentSize(cc.size(163,75))
	-- XTHD.setGray(sweepTen_disableNode,true)

	-- local tabBtn = {}
	-- local normalBtn = ccui.Scale9Sprite:create(cc.rect(50,25,1,1),"res/image/common/btn/btn_blue_up.png")
	-- normalBtn:setContentSize(cc.size(150,46))
	-- local selectedBtn = ccui.Scale9Sprite:create(cc.rect(50,25,1,1),"res/image/common/btn/btn_blue_down.png")
	-- selectedBtn:setContentSize(cc.size(150,46))


	local sweep_10_btn = XTHD.createCommonButton({
		text = LANGUAGE_KEY_GETSWEEP(sweep_times),
		isScrollView = false,
		btnColor = "write",
		btnSize = cc.size(150,46),
		disableNode = sweepTen_disableNode,
		-- musicFile = XTHD.resource.music.effect_btn_common,
		fontColor = cc.c3b(255,255,255),
		fontSize = 24,
		endCallback = function()
			local tili_num = 50
			if self._stageType == ChapterType.Normal then
				tili_num = 50
			elseif self._stageType == ChapterType.ELite then
				tili_num = 30
			end
			if gameUser.getTiliNow() < tonumber(tili_num) then
				self:showPayDialog()
				return
			end
			self:SweepRequest(sweep_times,stage_data.instancingid )
		end
	})
	sweep_10_btn:setAnchorPoint(0,0.5)
	sweep_10_btn:setPosition(self._bg_sp:getContentSize().width/2 + 300,recordBg:getPositionY() - 120)

	--征战一次
	-- local sweepOne_disableNode = cc.Sprite:create("res/image/common/btn/btn_gary.png")
	local sweepOne_disableNode = ccui.Scale9Sprite:create("res/image/common/btn/btn_write_1_disable.png")
	sweepOne_disableNode:setContentSize(cc.size(163,75))
	XTHD.setGray(sweepOne_disableNode,true)
	local sweep_btn = XTHD.createCommonButton({
			btnColor = "write_1",
			isScrollView = false,
			disableNode = sweepOne_disableNode,
			text = LANGUAGE_KEY_GETSWEEP("1"),
			btnSize = cc.size(150,46),
			fontColor = cc.c3b(255,255,255),
			fontSize = 26,
			endCallback = function()
				if gameUser.getTiliNow() < 5 then
					self:showPayDialog()
					YinDaoMarg:getInstance():overCurrentGuide(true,11)
					return
				end
				self:SweepRequest(1,stage_data.instancingid )
			end
		})
	sweep_btn:setAnchorPoint(0,0.5)
	sweep_btn:setPosition(self._bg_sp:getContentSize().width/2 + 120,sweep_10_btn:getPositionY())
	local _my_instancing = 1
	if self._stageType == ChapterType.Normal then
		_my_instancing = gameUser.getInstancingId()-- tonumber(userData_table.instancingid)
	elseif self._stageType == ChapterType.ELite then
		_my_instancing = gameUser.getEliteInstancingId()--tonumber(userData_table.eliteinstancingid)
	end
	
	self._sweep_10_btn = sweep_10_btn
	self._sweep_10_btn:setScale(0.8)
	self._sweep_btn = sweep_btn
	self._sweep_btn:setScale(0.8)
	--先判断次数时候允许开区
	self:setSweepBtnStatus()
	
	--在判断关卡书否允许开启
	if tonumber(stage_data["bossid"]) == 0 or (tonumber(stage_data["bossid"]) > 0 and tonumber( stage_data["instancingid"]) > _my_instancing  ) then
		sweep_10_btn:setEnable(false)
		sweep_btn:setEnable(false)
		sweep_10_btn:setVisible(false)
		sweep_btn:setVisible(false)
	end
	self._bg_sp:addChild(sweep_10_btn)
	self._bg_sp:addChild(sweep_btn)
	-- 可能掉落
	self.drop_data=fall_items
	local width=fall_bg:getContentSize().width /2 
	-- if btn_bg:isVisible() then
	-- 	width=(fall_bg:getContentSize().width-btn_bg:getContentSize().width)/2 
	-- end
	local space = 110
	if #fall_items > 4 then
		space = 100
	end
	local tabPos = SortPos:sortFromMiddle(cc.p(width ,fall_bg:getContentSize().height/2) , tonumber(#fall_items) , space)

	for i,var in ipairs(fall_items) do
		print(i)
		local item_bg=nil
		local items_info=nil 		
		items_info = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = var} )
	    item_bg = ItemNode:createWithParams({
			itemId = items_info["itemid"],
			needSwallow = true,
			_type_ = 4
			})
	    print("item size ... ", item_bg:getContentSize().width, item_bg:getContentSize().height)
		-- item_bg:setScale(60/item_bg:getContentSize().width)
		local _my_instancing = 1
		if self._stageType == ChapterType.Normal then
			_my_instancing = gameUser.getInstancingId()-- tonumber(userData_table.instancingid)
		elseif self._stageType == ChapterType.ELite then
			_my_instancing = gameUser.getEliteInstancingId()--tonumber(userData_table.eliteinstancingid)
		end
		item_bg:setPosition(tabPos[i].x,tabPos[i].y - 10)
		fall_bg:addChild(item_bg)

		local item_name_label = XTHDLabel:createWithParams({
            text = items_info["name"],
            anchor=cc.p(0.5,1),
            fontSize = 18,--字体大小
            color = consumption:getColor(),
            pos = cc.p(item_bg:getContentSize().width/2,-2),
        })
        item_bg:addChild(item_name_label)

	end

	-- self:show()
	--挑战按钮，先注释掉，等给了资源之后在放开
	local challenge_btn, battle_effect = XTHD.createFightBtn({
        par = self._bg_sp,
		pos = cc.p( self._bg_sp:getContentSize().width - 230, self._sweep_10_btn:getPositionY() - 150),
	})
	-- local challenge_btn = XTHDPushButton:createWithParams({
	-- 	selectedFile = "res/image/tmpbattle/star_chall.png",
	-- 	normalFile = "res/image/tmpbattle/star_chall.png",
	-- 	musicFile = "res/sound/battleStart.mp3",
	-- 	pos = cc.p(self:getContentSize().width-100*0.5-175, 100+40)		
	-- })
	challenge_btn:setTouchBeganCallback(function()
		if battle_effect then
			battle_effect:setScale(0.98)
		end
	end)	
	
	challenge_btn:setTouchMovedCallback(function()
		if battle_effect then
			battle_effect:setScale(1)
		end
	end)

	challenge_btn:setTouchEndedCallback(function ()
		if battle_effect then
			battle_effect:setScale(1)
		end
		musicManager.playEffect(XTHD.resource.music.effect_btn_common)
		self:challageEvent(stage_data)
	end)
	-- self:addChild(challenge_btn)
	self._challeng_btn = challenge_btn

	--img
	-- local leftImg = cc.Sprite:create("res/image/common/titlepattern_left.png")
	-- local rightImg = cc.Sprite:create("res/image/common/titlepattern_right.png")
	-- self:addChild(leftImg)
	-- self:addChild(rightImg)
	-- leftImg:setPosition(challenge_btn:getPositionX()- 100, challenge_btn:getPositionY())
	-- rightImg:setPosition(challenge_btn:getPositionX()+ 100, challenge_btn:getPositionY())



	local function preloadAni( id )
		local nId = id
		id = tostring(id)
		if string.len(id) == 1 then
			id = "00" .. id
		elseif string.len(id) == 2 then
			id = "0" .. id
		end
			sp.SkeletonAnimation:create("res/spine/" .. id .. ".json", "res/spine/" .. id .. ".atlas", 1)
		end

	local function preSpine( ... )
		local _pve_heros = DBUserTeamData:getPVETeamData()
		local pCount = 0
		if _pve_heros and #_pve_heros > 0 then
			for i = 1, 5 do
				local pNum = tonumber(_pve_heros["heroid"..i]) or 0
				if pNum > 0 then
					local _heroId = pNum
					preloadAni(_heroId)
					pCount = pCount + 1
					if pCount >= 2 then
						break
					end
				end
			end
		end
	end
	performWithDelay(self, preSpine, 0.01)
end

function LiLianStageLayer:onEnter()
	--------引导
	YinDaoMarg:getInstance():getACover(self)
	self:addGuide()
	--------
end
--体力不足的时候显示的提示框
function LiLianStageLayer:showPayDialog(_tili_cost)
 	local confirm = XTHDConfirmDialog:createWithParams({
		msg = LANGUAGE_TIPS_IF_BUY_TILI,
		rightCallback = function()
			local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=2})--byhuangjunjian 获得资源共用方法（1.元宝2.体力3.银两4.翡翠）
		     cc.Director:getInstance():getRunningScene():addChild(StoredValue)	
		end,
	})
	self:addChild(confirm,10)
end

function LiLianStageLayer:setSweepBtnStatus()
	--只有精英副本才有征战次数限制
	if self._stageType == ChapterType.ELite  then
		self._last_fight_times =  self._last_fight_times or 0
		if self._last_fight_times > 0 and self._last_fight_times < 3 then
			self._sweep_10_btn:setEnable(false)
			self._sweep_10_btn:setLabelColor(cc.c3b(220,220,220))
			self._sweep_btn:setEnable(true)
			self._sweep_btn:setLabelColor(cc.c3b(255,255,255))
		elseif self._last_fight_times <= 0  then
			self._sweep_10_btn:setEnable(false)
			self._sweep_10_btn:setLabelColor(cc.c3b(255,255,255))
			self._sweep_btn:setEnable(false)
			self._sweep_btn:setLabelColor(cc.c3b(255,255,255))

		elseif self._last_fight_times >= 3  then
			self._sweep_10_btn:setEnable(true)
			self._sweep_10_btn:setLabelColor(cc.c3b(255,255,255))
			self._sweep_btn:setEnable(true)
			self._sweep_btn:setLabelColor(cc.c3b(255,255,255))

		end
	end
	
end
function LiLianStageLayer:getAvatorAsIWant(heroid)
	local imgPath =	"res/image/avatar/avatar_circle_"..heroid..".png"
	if not cc.Director:getInstance():getTextureCache():addImage(imgPath) then
		imgPath = 	"res/image/avatar/avatar_circle_1.png"
	end
	return imgPath
end 

function LiLianStageLayer:onExit( )
	if self ~= nil then
	YinDaoMarg:getInstance():removeCover(self)
    end
end

function LiLianStageLayer:SweepRequest(times,instancingid)
	--征战限制 by hezhitao  began
	local tmp_data = gameData.getDataFromCSV("FunctionInfoList", {id = 30})
	local unlocktype = tmp_data["unlocktype"] or 2
	local unlockparam = tmp_data["unlockparam"] or 0
	if tonumber(unlocktype) == 2 then   --根据关卡开启
		if gameUser.getInstancingId() < tonumber(unlockparam) then
			XTHDTOAST(tmp_data["tip"])
			return
		end
	elseif tonumber(unlocktype) == 1 then   --根据玩家等级开启
		if gameUser.getLevel() < tonumber(unlockparam) then
			XTHDTOAST(tmp_data["tip"])
			return
		end
	end

	--end

	local _modules = "sweepEctype?"
	if self._stageType == ChapterType.Normal then
		_modules = "sweepEctype?"
	elseif self._stageType == ChapterType.ELite then
		_modules = "sweepEliteEctype?"
	end
	ClientHttp:requestAsyncInGameWithParams({
			modules = _modules,
            params = {ectypeId=instancingid,times=times},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
            successCallback = function(net_data)
	            if tonumber(net_data.result) == 0 then
	            	local playerProperty = net_data["property"]
	            	if playerProperty then
				        for i=1,#playerProperty do
				            local pro_data = string.split( playerProperty[i],',')
				              DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
				        end
				    end
	            	 --更新数据库稍微延时了，刷新数据的时候，没有及时更新到数据 yanyuling
	            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
	            	local LiLianSweepPopLayer = requires("src/fsgl/layer/LiLian/LiLianSweepPopLayer.lua"):create(net_data)
	            	self:addChild(LiLianSweepPopLayer,2)
	            	if self._stageType == ChapterType.ELite then
	            		self._last_fight_times = tonumber(net_data["surplusCount"])
		            	self._challage_time_txt:setString(net_data["surplusCount"].."/3")
		            	self:setSweepBtnStatus()
		            	CopiesData.ChangeEliteTimes(instancingid,net_data["surplusCount"])
	            	end
	            	LiLianSweepPopLayer:setHideCallback()
					XTHD.dispatchEvent({name = "EVENT_LEVEUP"}) 
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RECHARGE_HUOYUEJIANGLI})
	            else
	            	XTHDTOAST(net_data.msg)
	            end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
end

function LiLianStageLayer:challageEvent (stage_data)
    YinDaoMarg:getInstance():guideTouchEnd() 
	local _battleType, min_level, tiliCost
	if self._stageType == ChapterType.Normal then
		_battleType = BattleType.PVE
		local _chapterInfo = gameData.getDataFromCSV("CommonStarRewards", {chapterid = stage_data.chapterid})
		min_level = _chapterInfo.levelfloor or 1
		tiliCost = stage_data.hpcost or 5
	else
		_battleType = BattleType.ELITE_PVE
		local _chapterInfo = gameData.getDataFromCSV("EliteStarAward", {chapterid = stage_data.chapterid})
		min_level = _chapterInfo.levelfloor or 1
		tiliCost = stage_data.hpcost or 10
	end
	if gameUser.getLevel() < tonumber(min_level) then
		XTHDTOAST(LANGUAGE_FORMAT_TIPS41(min_level))-------"等级达到"..min_level.."级才能挑战")
		return
	end
	if gameUser.getTiliNow() < tiliCost then
		self:showPayDialog()
		return
	end
	self._challeng_btn:setEnable(false)
	ClientHttp.http_StartChallenge(self, _battleType, {ectypeId = stage_data.instancingid}, function(data)
		----引导 
	    -- local blockID = YinDaoMarg:getInstance():getCurrentStepBlockID()
    	YinDaoMarg:getInstance():releaseGuideLayer()
	    ------------------------------------
	    local function _normalGo()
	    	LayerManager.removeLayout(self)
			LayerManager.addShieldLayout()
			local _layer = requires("src/fsgl/layer/ChuZhan/XuanZeYingXiongNewLayer.lua"):createForPve(_battleType, stage_data.instancingid, data)
			fnMyPushScene(_layer)
			if self._challeng_btn then
				self._challeng_btn:setEnable(true)
			end
	    end

	 --    do 
		--     data.instancingid = stage_data.instancingid
		-- 	self:_goBattleNew(data)
		-- 	return
		-- end
		-- local _instancingId = LiLianStageChapterData.getInstancingId(self._stageType)
		-- print("新手引导章节部分数据为：".._instancingId.."类型："..self._stageType)
--		print_r(data)
	    if self._stageType == ChapterType.Normal then
			if stage_data.instancingid <= 5 then
				if data.isPassFrist == true then
					_normalGo()
				else
					data.instancingid = stage_data.instancingid
					self:_goBattleNew(data)
				end
			else
				_normalGo()
			end
			
--			if _instancingId == stage_data.instancingid - 1 then
--				if _instancingId == 0
--				or _instancingId == 1
--				or _instancingId == 2
--				or _instancingId == 3
--				or _instancingId == 4 then
--			    	data.instancingid = stage_data.instancingid
--					self:_goBattleNew(data)
--				else
--					_normalGo()
--				end
--			else
--				_normalGo()
--			end
		else
			_normalGo()
	    end
	  --   if blockID == -1 then
			-- self:_goBattleNew()
	  --   else
	  --   	data.battleType = _battleType
			-- data.instancingid = stage_data.instancingid
			-- data.guideIndex = blockID
			-- self:_goToBattle(data)
	  --   end
		
	end, function()-----如果失败了再来
		YinDaoMarg:getInstance():tryReguide()
		YinDaoMarg:getInstance():onlyCapter1Guide({ -----执行第一章的特殊引导 
	    	parent = self,
	    	target = self._challeng_btn
	    })
	end)
end

function LiLianStageLayer:_goBattleNew( data )

	ClientHttp.http_EctypeBattleBegin(self, function()
		LayerManager.removeLayout(self)
		LayerManager.addShieldLayout()

        --更新动态数据库中的体力data
       	gameUser.setTiliNow(tonumber(data.tili))

       	local teamListRight = data.monsters
		local _heroData = {}
		local _table = DBTableHero.getData(gameUser.getUserId())
		if _table then 
			if #_table > 1 then 
				_heroData = _table
			else
				_heroData[1] = _table
			end 
		end
		if _heroData[1] and next(_heroData[1])then
			local _team_data = {}
		  	_team_data["heroid"..1] = _heroData[1].heroid
		  	_team_data.teamid = 1
			DBUserTeamData:UpdatePVETeamData(_team_data)
		end
		local _id = tonumber(_heroData[1].heroid) or 8
		if _id ~= 8 and _id ~= 37 and _id ~= 17 then
			_id = 8
		end
		local _instancingid = data.instancingid
		if _instancingid == 5 then
			requires("src/fsgl/layer/YinDaoJieMian/YinDaoFight2.lua"):create({id = _id, rightData = teamListRight})
		else
			local _ectypeId = 1000 + _instancingid
			requires("src/fsgl/layer/YinDaoJieMian/YinDaoFight1.lua"):create({id = _id, ectypeId = _ectypeId, rightData = teamListRight})
		end
		if self._challeng_btn then
			self._challeng_btn:setEnable(true)
		end
	end)
end

-- function LiLianStageLayer:_goToBattle( sData )
-- 	ClientHttp.http_EctypeBattleBegin(self, function()
-- 		LayerManager.removeLayout(self)
-- 		LayerManager.addShieldLayout()
-- 		local _heroData = {}
-- 		local _table = DBTableHero.getData(gameUser.getUserId())
-- 		if _table then 
-- 			if #_table > 1 then 
-- 				_heroData = _table
-- 			else
-- 				_heroData[1] = _table
-- 			end 
-- 		end
-- 		local _reward_item = sData or {}
-- 		local _helps = {}
-- 		if _reward_item.helps and _reward_item.helps[1] then --为了不影响正常使用临时屏蔽
-- 			_helps = _reward_item.helps[1]
-- 		end
		
--      	local _arrDropList = _reward_item["itemReward"]
--      	local _dropList = {}
--      	for i = 1, #_arrDropList do
--      		local _szData = _arrDropList[i];
--      		local _tabData = string.split( _szData, ',' )
--      		_dropList[tostring(_tabData[1])] = _tabData[2]
--      	end
--         --更新动态数据库中的体力data
--        	gameUser.setTiliNow(tonumber(_reward_item.tili))

--     	local teamListLeft = {}
--     	local teamListRight = {}
--     	local bgList = {}

--     	for k,v in pairs(_helps) do
--     		local animal = {id = v.heroid, _type = ANIMAL_TYPE.PLAYER, helps = v}
--     		teamListLeft[#teamListLeft + 1] = animal
--     	end
--     	local _isGuidingHero = #_helps > 0 and true or false
--     	for i=1, #_heroData do
--     		local _heroId = _heroData[i].heroid
--     		local _data = HeroDataInit:InitHeroDataSelectHero( _heroId )
--     		local animal = {id = _heroId, _type = ANIMAL_TYPE.PLAYER, data = _data, isGuidingHero = _isGuidingHero}
--     		teamListLeft[#teamListLeft + 1] = animal
-- 			if #teamListLeft == 5 then
-- 				break
-- 			end
--     	end
--   --  		local _heroId = 1
-- 		-- local _data = HeroDataInit:InitHeroDataSelectHero( _heroId )
-- 		-- local animal = {id = _heroId, _type = ANIMAL_TYPE.PLAYER, data = _data, isGuidingHero = true}
-- 		-- teamListLeft[#teamListLeft + 1] = animal
-- 		-- local _heroId = 12
-- 		-- local _data = HeroDataInit:InitHeroDataSelectHero( _heroId )
-- 		-- local animal = {id = _heroId, _type = ANIMAL_TYPE.PLAYER, data = _data, isGuidingHero = true}
-- 		-- teamListLeft[#teamListLeft + 1] = animal

--     	table.sort(teamListLeft, function(a,b) 
--     		local _range1 = a.helps and a.helps.attackrange or a.data.attackrange
--     		_range1 = tonumber(_range1) or 0
--     		local _range2 = b.helps and b.helps.attackrange or b.data.attackrange
--     		_range2 = tonumber(_range2) or 0
--     		return _range1 < _range2
--     	end)

--     	for k,v in pairs(teamListLeft) do
--     		v.data = nil
--     	end
		
--         local instanceData
--         local _battleType = _reward_item.battleType
--         local sInstancingid = _reward_item.instancingid
-- 		if _battleType == BattleType.PVE then
-- 			instanceData = gameData.getDataFromCSV("ExploreInfoList", {["instancingid"]=sInstancingid})
-- 		else
-- 			instanceData = gameData.getDataFromCSV("EliteCopyList", {["instancingid"]=sInstancingid})
-- 		end
-- 		local bossid 	   = instanceData.bossid
-- 		local sound 	   = "res/sound/"..tostring(instanceData.sound)..".mp3"
-- 		local _time = instanceData.maxtime 

-- 		local storyIds = string.split(instanceData.storyID,"#")
-- 		local worldEffects = _reward_item.effects
-- 		local background   = instanceData.background
-- 		local bgs = string.split(background,"#")

-- 		for k,bgId in pairs(bgs) do
-- 			bgList[#bgList + 1] = "res/image/background/bg_"..bgId..".jpg"
-- 		end
-- 		local _bgType = instanceData.fubentype or -1
		
--         local monsters = _reward_item.monsters
--         for index=1,#monsters do
-- 			local rightData 		= {}
-- 			local storyId 			= storyIds[index]
-- 			--[[--剧情id]]
--         	if storyId and tonumber(storyId) and tonumber(storyId) > 0 and sInstancingid > gameUser.getInstancingId() then
-- 				rightData.storyId 	= storyId
-- 			end
-- 			--[[--该波的怪物]]
--         	local waveMonsters 		= monsters[index]
--         	local team 				= {}
--         	for k,monster in pairs(waveMonsters) do
--         		local monsterid = monster.monsterid
--         		local isBoss = false
--         		if monster.heroid == 801 then
--         			isBoss = true
--         		end
--         		local animal = {id = monsterid , _type = ANIMAL_TYPE.MONSTER,monster = monster, isWorldBoss = isBoss}
-- 			    team[#team + 1]=animal
--         	end
-- 			if team ~= nil and #team > 0 then
-- 		    	--[[--排队]]
-- 		    	table.sort( team, function(a,b) 
-- 		    		local n1 = tonumber(a.monster.attackrange) or 0
-- 		    		local n2 = tonumber(b.monster.attackrange) or 0
-- 		    		return n1 < n2
-- 		    	end )
-- 				rightData.team = team
-- 				teamListRight[#teamListRight + 1] = rightData
-- 			end
--         end
       
-- 		local _helpsData = _helps
-- 		local scene = cc.Scene:create()
-- 		local battleLayer = requires("src/battle/BattleLayer.lua"):create()
-- 		local uiExploreLayer = BattleUIExploreLayer:create(_battleType, false)            
-- 		battleLayer:initWithParams({
-- 			bgList 			= bgList,
-- 			bgm    			= sound,
-- 			battleTime      = _time,
-- 			instancingid    = sInstancingid,
-- 			teamListLeft	= {teamListLeft},
-- 			teamListRight	= teamListRight,
-- 			battleType 		= _battleType,
-- 			bgType			= _bgType,
-- 			isGuide			= _reward_item.guideIndex,
-- 			helps 			= _helpsData,
-- 			worldBuff       = worldEffects,
-- 			battleEndCallback = function(params)
-- 				if _helpsData and #_helpsData > 0 and params.left and params.left[1] and #params.left[1] > 0 then
-- 					for k,v in pairs(params.left[1]) do
-- 						for key,value in pairs(_helpsData) do
-- 							if value.heroid == v.id then
-- 								v.type = ANIMAL_TYPE.MONSTER
-- 								v.id = value.monsterid
-- 							end
-- 						end
-- 					end
-- 				end
-- 				ClientHttp.http_SendFightValidation(battleLayer, function(data)
-- 		            local _instancingid = params.instancingid
-- 					local _star = data.star
-- 					if tonumber(data["fightResult"]) == 1 then
-- 						local refresh_data = {}
-- 						refresh_data["type"] = _battleType == BattleType.PVE and ChapterType.Normal or ChapterType.ELite
-- 			            refresh_data["instancingid"] = _instancingid
-- 			            refresh_data["star"] = _star
-- 			            refresh_data["surplusCount"] = data["surplusCount"] or 0
-- 						CopiesData.refreshDataBase(refresh_data)
-- 					end
-- 					performWithDelay(battleLayer, function()
-- 						battleLayer:hideWithoutBg()
-- 						data.backCallback = function() 
-- 							cc.Director:getInstance():popScene()
-- 						end
-- 						scene:addChild(requires( "src/fsgl/layer/ZhanDouJieGuo/ZhanDouJieGuoPVELayer.lua"):create(data))
-- 					end, 2)
--                 end, function()
-- 	             	createFailHttpTipToPop()
-- 				end, params)
-- 			end,
-- 		})
		
-- 		scene:addChild(battleLayer)
-- 		battleLayer:setUILay(uiExploreLayer)
-- 		scene:addChild(uiExploreLayer)
		
-- 		cc.Director:getInstance():pushScene(scene)
-- 		battleLayer:start()

-- 		local _team_data = {}
-- 	  	for i = 1, #teamListLeft do
-- 	  		local _data = teamListLeft[i]
-- 	  		if _data.id ~= 12 then
-- 			  	_team_data["heroid"..i] = _data.id
-- 		  	end
-- 	  	end
-- 	  	_team_data.teamid = 1
-- 		DBUserTeamData:UpdatePVETeamData(_team_data)
-- 	end)
-- end

function LiLianStageLayer:create( params )
	local layer = LiLianStageLayer.new(params)
	return layer
end

function LiLianStageLayer:addGuide( )
    performWithDelay(self,function( )    	
		    YinDaoMarg:getInstance():addGuide({
		        parent = self,
		        target = self._challeng_btn,
		        index = 5,
				needNext = false,
				isButton = false,
		    },8)
	    YinDaoMarg:getInstance():removeCover(self)	    
	    YinDaoMarg:getInstance():doNextGuide()
	    YinDaoMarg:getInstance():onlyCapter1Guide({
	    	parent = self,
	    	target = self._challeng_btn
	    }) -----执行第一章的特殊引导 
    end,0.3)
end

return LiLianStageLayer;