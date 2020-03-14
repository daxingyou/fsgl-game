--[[
    Author by xingchen
    2015.12.02
    帮派活动界面
]]
local BangPaiHuoDong = class("BangPaiHuoDong", function (...) 
	local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(cc.size(420,220))
	return node
end)

function BangPaiHuoDong:init( parent ,pos)
	self._pos = pos
	self._parent = parent
    self._cell_arr = {}  --存放cell
    self._worship = nil   --帮派祭拜
    self._worship_times = nil --祭拜次数label
    self._worship_times_nums = 0
    self._worship_points = nil  --祭拜点
    self._worship_points_iamge = nil --祭拜点图片，为了更新祭拜点时调整它的位置guildBaodian
    self._cell_idx = 1     --标记当前被选中的cell的idx
    self._btn_effect = {}
    self.activityTabKey = {"guildJuanXian","guildBoss","guildbattle","guildBaodian"}

    local _topBarHeight = self.topBarHeight or 40
    --屏幕大小的sprite,用于存放管理各个活动界面的sprite和tableview
    local _bgSprite = cc.Sprite:createWithTexture(nil, cc.rect(0,0,self:getContentSize().width,self:getContentSize().height))
    _bgSprite:setOpacity(0)
    _bgSprite:setAnchorPoint(cc.p(0.5,0))
    _bgSprite:setPosition(cc.p(self:getContentSize().width/2,0))
    self:addChild(_bgSprite)
    self._bg = _bgSprite
    local _innerSize = cc.size(_bgSprite:getContentSize().width + _bgSprite:getContentSize().width / 6 * 2,_bgSprite:getContentSize().height)
    
    local activity_list = ccui.ScrollView:create()
    activity_list:setBounceEnabled(true)
    activity_list:setTouchEnabled(false)
    activity_list:setDirection(ccui.ScrollViewDir.horizontal)
    activity_list:setContentSize(cc.size(_bgSprite:getContentSize().width,_innerSize.height))
    activity_list:setInnerContainerSize(_innerSize)
    activity_list:setPosition(0,0)
	activity_list:setScrollBarEnabled(false)
    _bgSprite:addChild(activity_list)


    for i=1,#self.activityTabKey do
        local _itemBtn = XTHD.createButton({
            normalFile = "res/image/guild/guildActivities/" .. self.activityTabKey[i] .. ".png",
            selectedFile = "res/image/guild/guildActivities/" .. self.activityTabKey[i] .. ".png",
			needEnableWhenMoving = true,
        })
        local _itemPosX = (_itemBtn:getContentSize().width + 20) * (i -1) + _itemBtn:getContentSize().width *0.5 + 18
        local _itemPosY = _innerSize.height/2
		_itemBtn:setSwallowTouches(false)
        _itemBtn:setPosition(cc.p(_itemPosX,_itemPosY))
        activity_list:addChild(_itemBtn)

		_itemBtn:setTouchBeganCallback(function()
			_itemBtn:setScale(0.98)
		end)
		_itemBtn:setTouchMovedCallback(function()
			_itemBtn:setScale(1)
		end)
        _itemBtn:setTouchEndedCallback(function()
			_itemBtn:setScale(1)
            self:switchActivity(i)        
        end)
        if i == 4 then
            self.xiulianBtn = _itemBtn
        end
    end
	local x,y = self.xiulianBtn:getPosition()
	local pos = self.xiulianBtn:convertToWorldSpace(cc.p(x,y))
    YinDaoMarg:getInstance():addGuide({ ----点击帮派修炼
        parent = self._parent,
        target = self.xiulianBtn,
        index = 3,
        needNext = false,
        offset = cc.p(pos.x + self._pos.x - self.xiulianBtn:getContentSize().width *0.5,pos.y + self._pos.y + self.xiulianBtn:getContentSize().height *0.25),
    },17)
    YinDaoMarg:getInstance():doNextGuide() 
end

function BangPaiHuoDong:switchActivity( idx )
    if idx == nil then
        return
    end
    idx = tonumber(idx) or 0
    local _guildActivitiesTable = {
        "BangPaiJuanXian.lua",
		"BangPaiBoos.lua",           --帮派Boss
        "BangPaiZhanMain.lua",            --帮派战   
    }
    local _guildHttpKey = {
        "guildWorshipList?",
		"guildBossList?",
        "guildBattleBase?",
    }
    local _actLayer = nil
    if idx >= 1 and idx<=3 then   --帮派祭拜
        ClientHttp:httpGuild(_guildHttpKey[idx],self,function(data)
                local _newLayer = requires("src/fsgl/layer/BangPai/" .. _guildActivitiesTable[idx]):create(data)
                LayerManager.addLayout(_newLayer,{noHide = true})
            end,{})
    else
        YinDaoMarg:getInstance():guideTouchEnd()
        XTHD.createBibleLayer(cc.Director:getInstance():getRunningScene())
    end
end

function BangPaiHuoDong:getFileNameByIdx( idx )
    local file_path = {
        "guildActText_worship",
        "guildActText_war",
        "guildActText_manor",
        "guildActText_banquet",
        "guildActText_stagechapter"
    }
    if tonumber(idx) > #file_path or tonumber(idx) <= 0 then
        return nil,#file_path
    end
    local path = "res/image/guild/"..file_path[idx]..".png"
    return path,#file_path
end

function BangPaiHuoDong:create( parent,pos )
	local pLay = self.new()
	pLay:init(parent,pos)
	return pLay
end

return BangPaiHuoDong
