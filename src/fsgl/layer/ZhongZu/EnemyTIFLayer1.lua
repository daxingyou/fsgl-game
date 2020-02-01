--[[
敌方单个队伍信息
]]
local EnemyTIFLayer1 = class("EnemyTIFLayer1",function( )
	return XTHDPopLayer:create()
end)

function EnemyTIFLayer1:ctor(parent,data)
	self._parent = parent
	self._teamData = data
end

function EnemyTIFLayer1:create(brother,data)
	local team = EnemyTIFLayer1.new(brother,data)
	if team then 
		team:init()
	end 
	return team 	
end

function EnemyTIFLayer1:init( )
	local height = 140
	----背景
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_16.png")
	bg:setContentSize(cc.size(475,height))
	local bg2 = ccui.Scale9Sprite:create("res/image/common/scale9_bg_16.png")
	bg2:setContentSize(cc.size(475,height))
	local _mode = XTHDPushButton:createWithParams({
		normalNode = bg,				
		selectedNode = bg2,
		needSwallow = true,
	})
	self:addContent(_mode)
	_mode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	-----提示
	local _lable = cc.Sprite:create("res/image/camp/map/camp_label11.png")
	_mode:addChild(_lable)
	_lable:setPosition(_mode:getBoundingBox().width / 2,_mode:getBoundingBox().height - _lable:getBoundingBox().height)
	------第二层背景
	_bg2 = ccui.Scale9Sprite:create("res/image/common/scale9_bg_17.png")
	_bg2:setContentSize(cc.size(_mode:getContentSize().width - 10,_lable:getPositionY() - _lable:getBoundingBox().height))
	_bg2:setAnchorPoint(0.5,1)
	_mode:addChild(_bg2)
	_bg2:setPosition(_mode:getBoundingBox().width / 2,_lable:getPositionY() - _lable:getBoundingBox().height + 5)
	----背景下面的字
	local _lable = cc.Sprite:create("res/image/plugin/duanadvance/space_sp.png")
	self:addContent(_lable)
	_lable:setAnchorPoint(0.5,1)
	_lable:setPosition(_mode:getPositionX(),_mode:getPositionY() - _mode:getContentSize().height / 2 - 5)

	self:initTeams(_bg2)
end

function EnemyTIFLayer1:initTeams(targ)
	local data = self._teamData.team
	if not data then 
		return 
	end 
	---头像们
	local x = 8
	for k,v in pairs(data[1].heros) do 
		local node = HeroNode:createWithParams({
			heroid = v.petId,
			star = v.star,
			level = v.level,
			needHp = true,
			curNum = v.curHp,
			maxNum = v.property['200'],
			advance = v.phase,
		})
		local _factor = (targ:getBoundingBox().height - 10) / node:getBoundingBox().height
		targ:addChild(node)
		node:setScale(_factor)
		node:setAnchorPoint(0,0.5)
		node:setPosition(x,targ:getBoundingBox().height / 2)
		x = x + node:getBoundingBox().width + 5
	end 
end

return EnemyTIFLayer1