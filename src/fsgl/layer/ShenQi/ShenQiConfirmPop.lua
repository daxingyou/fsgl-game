--Created By Liuluyang 2015年08月07日
local ShenQiConfirmPop = class("ShenQiConfirmPop",function ()
	return XTHDPopLayer:create()
end)

function ShenQiConfirmPop:ctor(artifactCount,heroId,refreshNode,extraCall)
    self._parent = refreshNode

    self._extraCall = extraCall
	self:initUI(artifactCount,heroId,refreshNode)
end

function ShenQiConfirmPop:initUI(artifactCount,heroId,refreshNode)
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
	bg:setContentSize(cc.size(355,320))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_TIP_NONEEQUIP_ARTIFACT,
		fontSize = 18,
		color = XTHD.resource.color.brown_desc
	})
	titleLabel:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-50)
	bg:addChild(titleLabel)

	local shadow = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	shadow:setContentSize(cc.size(325,210))
	shadow:setAnchorPoint(0.5,0)
	shadow:setPosition(bg:getBoundingBox().width/2,25)
	bg:addChild(shadow)

	local changeNode = self:getBtnNode()
	local changeBtn = XTHDPushButton:createWithParams({
        musicFile = XTHD.resource.music.effect_btn_common,
        normalNode      = changeNode[1],
        selectedNode    = changeNode[2],
        text = LANGUAGE_TIP_GOTO_ARTIFACTSHOP, ----前往神器商店购买
    })
    changeBtn:getLabel():setColor(XTHD.resource.color.brown_desc)
    changeBtn:setAnchorPoint(0.5,1)
    changeBtn:setPosition(shadow:getBoundingBox().width/2,shadow:getBoundingBox().height-10)
    shadow:addChild(changeBtn)

    changeBtn:setTouchEndedCallback(function ()
        XTHD.createSaintBeastChange(self:getParent())
    	self:hide()
    end)

    local listNode = self:getBtnNode()
    local listBtn = XTHDPushButton:createWithParams({
        musicFile = XTHD.resource.music.effect_btn_common,
        normalNode      = listNode[1],
        selectedNode    = listNode[2],
        text = LANGUAGE_TIP_LOOKUP_OWN_ARTIFACT,-----查看已有神器
    })
    listBtn:getLabel():setColor(XTHD.resource.color.brown_desc)
    listBtn:setAnchorPoint(0.5,0)
    listBtn:setPosition(shadow:getBoundingBox().width/2,10)
    shadow:addChild(listBtn)

    listBtn:setTouchEndedCallback(function ()
        YinDaoMarg:getInstance():guideTouchEnd() 
        YinDaoMarg:getInstance():releaseGuideLayer()
        --------引导 
    	if artifactCount <= 0 then
    		XTHDTOAST(LANGUAGE_TIPS_WORDS4) ---你当前还没有神器
            YinDaoMarg:getInstance():overCurrentGuide(true)
    		return
    	end
    	local ShenQiSelectPop = requires("src/fsgl/layer/ShenQi/ShenQiSelectPop.lua"):create(heroId,refreshNode,self._extraCall)
		self:getParent():addChild(ShenQiSelectPop)
		ShenQiSelectPop:show()
		self:hide()
    end)
    self._artifactListBtn = listBtn    
end

function ShenQiConfirmPop:getBtnNode()
    local _btnNodeTable = {}
    local _normalSprite = ccui.Scale9Sprite:create("res/image/common/select_bg_11.png")
    _normalSprite:setContentSize(cc.size(313,92))
    local _selectedSprite = ccui.Scale9Sprite:create("res/image/common/select_bg_10.png")
    _selectedSprite:setContentSize(cc.size(313,92))
    _btnNodeTable[1] = _normalSprite
    _btnNodeTable[2] = _selectedSprite
    return _btnNodeTable
end

function ShenQiConfirmPop:create(artifactCount,heroId,refreshNode,extraCall)
	return ShenQiConfirmPop.new(artifactCount,heroId,refreshNode,extraCall)
end

function ShenQiConfirmPop:onEnter( )
    -- YinDaoMarg:getInstance():getACover(self._parent)
    -- if gameUser.getInstancingId() == 48 then ----第21组引导 
    --     YinDaoMarg:getInstance():addGuide({ ----经验丹引导
    --         parent = self._parent,        
    --         target = self._artifactListBtn,
    --         index = 6,
    --     },21)
    -- end 
    -- performWithDelay(self._artifactListBtn,function( )
    --     YinDaoMarg:getInstance():doNextGuide()   
    --     YinDaoMarg:getInstance():removeCover(self._parent)
    -- end,0.2)
end

return ShenQiConfirmPop