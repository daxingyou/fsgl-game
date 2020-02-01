local ZhuangBeiLacePop=class("ZhuangBeiLacePop",function ()
	return XTHDConfirmDialog:createWithParams()
end)
function ZhuangBeiLacePop:ctor( params )
    self._type = 4
	self._itemId = 0
    self._leftCallback = nil
    self._rightCallback = nil
    if params then
    	if params.rightCallback then
    		self._rightCallback = params.rightCallback
    	end
    	if params.leftCallback then
    		self._leftCallback = params.leftCallback
    	end
	    if params.itemId then
	        self._itemId = params.itemId
	    end
        if params._type_ then
            self._type = params._type_
        end
	end
	self:initUI()
end

function ZhuangBeiLacePop:initUI()
    local _name = ""
    if self._type == XTHD.resource.type.smeltPoint then
        _name = LANGUAGE_NAMES.smeltDot
    elseif self._type == XTHD.resource.type.item then
        _name = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = self._itemId}).name
    end
	
	txt_content = XTHDLabel:create(LANGUAGE_EQUIP_LACK(_name),18)
	txt_content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
    txt_content:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    txt_content:setColor(XTHD.resource.color.gray_desc)
    -- if tonumber(txt_content:getContentSize().width)<306 then
    --     txt_content:setDimensions(tonumber(txt_content:getContentSize().width), 120)
    -- else
    --     txt_content:setDimensions(306, 120)
    -- end
    txt_content:setPosition(self.containerBg:getContentSize().width/2,self.containerBg:getContentSize().height/2 + 30)
    self.containerBg:addChild(txt_content)

    self:setCallbackRight(function ()
     	if self._rightCallback then
        	self._rightCallback()
        end
        self:removeFromParent()
	end)

	self:setCallbackLeft(function()
		if self._leftCallback then
        	self._leftCallback()
        end
        self:removeFromParent()
    end)

	self:show()
end

function ZhuangBeiLacePop:create( params )
	return ZhuangBeiLacePop.new( params )
end
return ZhuangBeiLacePop