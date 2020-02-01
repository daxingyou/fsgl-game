--[[
种族战结束之后弹出的提示
]]
local ZhongZuWarOverLayer = class("ZhongZuWarOverLayer",function( )
	return XTHDPopLayer:create()
end)

function ZhongZuWarOverLayer:ctor(data)
	self._data = data or {}
end

function ZhongZuWarOverLayer:create(data)
	local _layer = ZhongZuWarOverLayer.new(data)
	if _layer then 
		_layer:init()
	end 
	return _layer
end

function ZhongZuWarOverLayer:init( )
	------背景
	local _bg = cc.Sprite:create("res/image/worldboss/result_bg.png")
	_bg:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self:addContent(_bg)
	----种族战结束 
	local _word = cc.Sprite:create("res/image/camp/camp_war_overword.png")
	_bg:addChild(_word)
	_word:setPosition(_bg:getContentSize().width / 2,_bg:getContentSize().height)
	---点击空白区域继续
	local _tips = cc.Sprite:create("res/image/plugin/duanadvance/space_sp.png")
	_bg:addChild(_tips)
	_tips:setPosition(_bg:getContentSize().width / 2,0 - _tips:getContentSize().height / 2)
	-----谁取得胜利
	local _name = nil
	if self._data.result > 0 then 
		_name = cc.Sprite:create("res/image/camp/camp_name"..(self._data.result)..".png")
		_bg:addChild(_name)
		_name:setAnchorPoint(cc.p(0,0.5))
		-----获得胜利字
		local _vict = cc.Sprite:create("res/image/camp/camp_victory_word.png")
		_bg:addChild(_vict)
		_vict:setAnchorPoint(cc.p(0,0.5))
		local x = _name:getContentSize().width + _vict:getContentSize().width
		x = (_bg:getContentSize().width - x) / 2	
		_name:setPosition(x,_word:getPositionY() - _word:getContentSize().height)
		_vict:setPosition(_name:getPositionX() + _name:getContentSize().width,_name:getPositionY())
	else 
		_name = cc.Sprite:create("res/image/camp/camp_label9.png")
		_bg:addChild(_name)
		_name:setPosition(_bg:getContentSize().width / 2,_word:getPositionY() - _word:getContentSize().height)
	end 	
	if #self._data.strong[1][1] > 0 or #self._data.strong[2][1] > 0 then ------种族双方都有最强
		-------最强大侠
		_word = cc.Sprite:create("res/image/camp/camp_zqdx_word.png")
		_bg:addChild(_word)
		_word:setPosition(_bg:getContentSize().width / 2,_name:getPositionY() - _name:getContentSize().height - 20)
		local _line = cc.Sprite:create("res/image/plugin/compose/compose_titleSp.png")
		_bg:addChild(_line)
		_line:setPosition(_word:getPosition())	
		------最强
		self:initCampStrongest(_bg)
	else
		_word = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS39,XTHD.SystemFont,20)
		_word:enableShadow(cc.c4b(0xff,0xff,0xff,0xff),cc.size(1,0))
		_bg:addChild(_word)
		_word:setPosition(_bg:getContentSize().width / 2,_bg:getContentSize().height / 2)
	end 
	-----玩家自己的排行等
	_word = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS37,XTHD.SystemFont,20)
	_word:setColor(cc.c3b(255,126,0))	
	_bg:addChild(_word)
	_word:setAnchorPoint(0,0.5)
	------
	local _amount = XTHDLabel:createWithSystemFont(self._data.selfnum or 0,XTHD.SystemFont,24)
	_amount:setColor(cc.c3b(255,126,0))	
	_bg:addChild(_amount)
	_amount:setAnchorPoint(0,0.5)
	-----
	local _rank = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS38,XTHD.SystemFont,20)
	_rank:setColor(cc.c3b(255,126,0))	
	_bg:addChild(_rank)
	_rank:setAnchorPoint(0,0.5)
	-----
	local _rankNum = XTHDLabel:createWithSystemFont(self._data.selfRank or 0,XTHD.SystemFont,24)
	_rankNum:setColor(cc.c3b(255,126,0))	
	_bg:addChild(_rankNum)
	_rankNum:setAnchorPoint(0,0.5)
	
	x = _word:getContentSize().width + _amount:getContentSize().width + _rank:getContentSize().width + _rankNum:getContentSize().width + 30
	x = (_bg:getContentSize().width - x) / 2
	_word:setPosition(x,50)
	_amount:setPosition(_word:getPositionX() + _word:getContentSize().width,_word:getPositionY())
	_rank:setPosition(_amount:getPositionX() + _amount:getContentSize().width + 30,_amount:getPositionY())
	_rankNum:setPosition(_rank:getPositionX() + _rank:getContentSize().width,_rank:getPositionY())
end

function ZhongZuWarOverLayer:initCampStrongest(target)
	-------光明谷最强	
	if not self._data.strong then 
		return 
	end 
	local camp = {}	
	local i = 1
	for k,v in pairs(self._data.strong) do 
		local node = cc.Node:create()
		node:setAnchorPoint(0,0.5)
		if #v[1] > 0 then -----有人
			local h = 0
			local w = 0
			local _icon = cc.Sprite:create("res/image/camp/camp_icon_small"..k..".png")
			_icon:setScale(0.8)
			node:addChild(_icon)
			_icon:setAnchorPoint(0,0.5)
			h = _icon:getContentSize().height
			w = w + _icon:getContentSize().width + 5
			---名字
			local _name = XTHDLabel:createWithSystemFont(v[1],XTHD.SystemFont,24)
			node:addChild(_name)
			_name:setAnchorPoint(0,0.5)
			_name:setColor(cc.c3b(254,227,0))
			w = w + _name:getContentSize().width + 5
			---杀敌
			local _kill = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_TIPSWORDS36,XTHD.SystemFont,22)
			node:addChild(_kill)
			_kill:setAnchorPoint(0,0.5)
			_kill:setColor(cc.c3b(255,168,0))
			w = w + _kill:getContentSize().width
			----数量
			local _amount =  XTHDLabel:createWithSystemFont(v[2],XTHD.SystemFont,24)
			node:addChild(_amount)
			_amount:setAnchorPoint(0,0.5)
			_amount:setColor(cc.c3b(255,168,0))
			w = w + _amount:getContentSize().width
			node:setContentSize(cc.size(w,h))

			_icon:setPosition(0,node:getContentSize().height / 2)
			_name:setPosition(_icon:getPositionX() + _icon:getContentSize().width,_icon:getPositionY())
			_kill:setPosition(_name:getPositionX() + _name:getContentSize().width + 10,_name:getPositionY())
			_amount:setPosition(_kill:getPositionX() + _kill:getContentSize().width,_kill:getPositionY())
			camp[i] = node
			i = i + 1
		end 
	end 
	if #camp > 1 then 
		target:addChild(camp[1])
		target:addChild(camp[2])
		local x = camp[1]:getContentSize().width + camp[2]:getContentSize().width
		x = (target:getContentSize().width - x) / 2
		camp[1]:setPosition(x,target:getContentSize().height / 2)
		camp[2]:setPosition(camp[1]:getContentSize().width + camp[1]:getPositionX() + 25,camp[1]:getPositionY())
	elseif camp[1] then  
		target:addChild(camp[1])
		local x = camp[1]:getContentSize().width
		x = (target:getContentSize().width - x) / 2
		camp[1]:setPosition(x,target:getContentSize().height / 2)
	end 
end

return ZhongZuWarOverLayer