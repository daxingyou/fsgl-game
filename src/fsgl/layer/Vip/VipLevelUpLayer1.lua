VipLevelUpLayer1 = class("VipLevelUpLayer1",function( )
	return cc.Layer:create()
end)


function VipLevelUpLayer1:ctor(data)
	self._canClick = false
end

function VipLevelUpLayer1:create(data)
	local instance = VipLevelUpLayer1.new(data)
	if instance then 
		instance:init(data)
		instance:registerScriptHandler(function(event )
			if event == "enter" then 
				instance:onEnter()
			elseif event == "exit" then 
				instance:onExit()
			end 
		end)
	end 
	return instance
end


function VipLevelUpLayer1:init( data )
	local _color = cc.LayerColor:create(cc.c4b(0,0,0,100),self:getContentSize().width,self:getContentSize().height)
	self:addChild(_color)

	local board = cc.Node:create()	
	self:addChild(board)
	board:setContentSize(cc.size(539,341))
	board:setAnchorPoint(0.5,0.5)
	board:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self.__functionBoard = board
	----特效
	local _spine = sp.SkeletonAnimation:create("res/spine/effect/level_up/xgn.json", "res/spine/effect/level_up/xgn.atlas", 1.0)
	board:addChild(_spine)
	_spine:setPosition(board:getContentSize().width / 2,board:getContentSize().height / 2)
	_spine:setAnimation(0,"3",false)
	performWithDelay(self,function( )
		----关闭按钮
		local _closeBtn = XTHD.createBtnClose(function()
	        self:removeFromParent()
	    end)
		board:addChild(_closeBtn)
		_closeBtn:setPosition(board:getContentSize().width - _closeBtn:getContentSize().width / 2,board:getContentSize().height - _closeBtn:getContentSize().height - 10)
		---前往按钮
		local _gotoBtn = XTHD.createCommonButton({
			text = LANGUAGE_BTN_KEY.chakanjiangli,
			isScrollView = false,
			fontSize = 22,
			btnSize = cc.size(130, 49),
		})
		board:addChild(_gotoBtn)
		_gotoBtn:setTouchEndedCallback(function( )
			if data ~= nil then
				XTHD.createVipLayer(cc.Director:getInstance():getRunningScene(),self._parent)
			else
				XTHD.createVipLayer(cc.Director:getInstance():getRunningScene(),self._parent)
			end
			self:removeFromParent()
		end)
		_gotoBtn:setPosition(board:getContentSize().width / 2 + 10,50)

		---vip信息
		local vip_font = cc.Sprite:create("res/image/vip/huode.png")
		vip_font:setPosition(120,board:getContentSize().height/2)
		board:addChild(vip_font)

		local light_icon = cc.Sprite:create("res/image/vip/bg_light.png")
		 light_icon:setPosition(250+30+10,vip_font:getPositionY())
		board:addChild(light_icon)

		local vip_num = self:createVipFont(true,gameUser.getVip())
		vip_num:setPosition(230+10,vip_font:getPositionY()+15)
		board:addChild(vip_num)

		local vip_font1 = cc.Sprite:create("res/image/vip/suoyouquan.png")
		vip_font1:setPosition(150+240,board:getContentSize().height/2)
		board:addChild(vip_font1)

		local tip_label = XTHDLabel:createWithParams({
			text = LANGUAGE_TIPS_WORDS193,-------"解锁更多权限,享受更多爽快",
			fontSize = 16,
			color = cc.c3b(53,25,26)
			})
		tip_label:setPosition(board:getContentSize().width/2,100)
		board:addChild(tip_label)

		self._canClick = true		
	end,1.0)
	performWithDelay(self,function ( )
		if _spine then 
			_spine:setAnimation(0,"4",true)
		end 
	end,1.0)
end


--vip字体和VIP数字  is_big控制是否为大的VIP字体，vip_num是VIP的级别
function VipLevelUpLayer1:createVipFont( is_big,vip_num )
    local vip_file = ""
    local vip_num_file = ""
    local offset_x = 0   --x轴上的偏移量
    local offset_y = 0
    if is_big == true then
        vip_file = "res/image/vip/vip_big.png"
        vip_num_file = ""
        offset_x = 20
        offset_y = 16
    else
        vip_file = "res/image/vip/vip_small.png"
        vip_num_file = "s_"
        offset_y = -3
    end
    local vip_icon = cc.Sprite:create(vip_file)

    if vip_num<0 then
        vip_num = 0
    end

    --vip 数字
    local vip_num_sp = XTHD.createSprite()  --一个透明的精灵，用于存放VIP数字，并且通过vip_num的大小确定，vip_num_sp的大小
    if tonumber(vip_num) < 10 then
        local tmp_vip_num = cc.Sprite:create("res/image/vip/vip_"..vip_num_file..vip_num..".png")
        vip_num_sp:setContentSize(tmp_vip_num:getContentSize().width,tmp_vip_num:getContentSize().height)
        tmp_vip_num:setPosition(vip_num_sp:getContentSize().width/2,vip_num_sp:getContentSize().height/2)
        vip_num_sp:addChild(tmp_vip_num)
    else
        local gewei = vip_num%10
        local shiwei = (vip_num - gewei)/10
        local gewei_vip_num = cc.Sprite:create("res/image/vip/vip_"..vip_num_file..gewei..".png")
        local shiwei_vip_num = cc.Sprite:create("res/image/vip/vip_"..vip_num_file..shiwei..".png")
        vip_num_sp:setContentSize(gewei_vip_num:getContentSize().width+shiwei_vip_num:getContentSize().width,gewei_vip_num:getContentSize().height)

        --十位上的数字在前面
        shiwei_vip_num:setPosition(shiwei_vip_num:getContentSize().width/2,shiwei_vip_num:getContentSize().height/2)
        vip_num_sp:addChild(shiwei_vip_num)

        gewei_vip_num:setPosition(gewei_vip_num:getContentSize().width+shiwei_vip_num:getContentSize().width/2-5,gewei_vip_num:getContentSize().height/2)
        vip_num_sp:addChild(gewei_vip_num)
    end

    local sp_bg = XTHD.createSprite()
    sp_bg:setContentSize(vip_icon:getContentSize().width+vip_num_sp:getContentSize().width,vip_icon:getContentSize().height)
    vip_icon:setPosition(vip_icon:getContentSize().width/2,vip_icon:getContentSize().height/2)
    sp_bg:addChild(vip_icon)

    vip_num_sp:setPosition(vip_icon:getContentSize().width+vip_num_sp:getContentSize().width/2-offset_x+20,vip_icon:getContentSize().height/2-offset_y)
    sp_bg:addChild(vip_num_sp)

    return sp_bg
end

function VipLevelUpLayer1:onEnter( )

    local function TOUCH_EVENT_BEGAN( touch,event )
    	return true
    end

    local function TOUCH_EVENT_MOVED( touch,event )
    	-- body
    end

    local function TOUCH_EVENT_ENDED( touch,event )
    	if self._canClick == false then
    		return
    	end
    	local pos = touch:getLocation()
    	local rect = self.__functionBoard:getBoundingBox()
    	if cc.rectContainsPoint(rect,pos) == false then
    		self._canClick = false
    		self:removeFromParent()
    	end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(TOUCH_EVENT_BEGAN,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(TOUCH_EVENT_MOVED,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(TOUCH_EVENT_ENDED,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
end

function VipLevelUpLayer1:onExit( )
	
end

return VipLevelUpLayer1