--以下英雄未拥有 255,210,80
local YingXiongDetailPropertyLayer = class("YingXiongDetailPropertyLayer", function()
    local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(420,264)
	return node
end)

function YingXiongDetailPropertyLayer:ctor(heroData,target_layer,isOther)
    self.isOther = isOther
    self.otherDistance = 0
    if self.isOther~=nil and self.isOther == true then
        self:setTextureRect(cc.rect(0,0,357,446))
        self.otherDistance = 5
    end
    
    self.infoLayer = target_layer

    self.detail_fontSize = target_layer and self.infoLayer._commonTextFontSize or 18

    self.data = heroData

    self:init()
end

function YingXiongDetailPropertyLayer:init()
    -- local _herotitleBg_path = "res/image/plugin/hero/heroTitle_bg.png"
    --英雄介绍框
    local kuang1 = ccui.Scale9Sprite:create("res/image/newHeroinfo/hero_descriptionbg.png")
	kuang1:setAnchorPoint(0,0.5)
    kuang1:setPosition(cc.p(12.5,self:getContentSize().height *0.5 - 5))
    self:addChild(kuang1)

	local heroname = cc.Sprite:create("res/image/newHeroinfo/heroname/heroname_"..self.data.heroid..".png")
	heroname:setAnchorPoint(0.5,0.5)
	kuang1:addChild(heroname)
	heroname:setPosition(heroname:getContentSize().width *0.5 + 6,kuang1:getContentSize().height *0.5)

	--getStringLengthByCharactor
	--确定每一个lable要放入多少字符
	local count = 12
	local _description = ""
	for i = 1,string.len(self.data["description"])/3 do
		_description = _description.."\n"..string.sub(self.data["description"],(i-1)*3 + 1,i*3)
	end
	--dump(_description)

	local texts = {}
	for i = 1,string.len(self.data["description"])/3 do
		texts[#texts + 1] = string.sub(self.data["description"],(i-1)*3 + 1,i*3)
	end
	

	for i = 1,#texts do
		texts[i] = texts[i].."\n"
	end
	
	local lables = {}
	for i = 1, math.ceil(#texts / count) do
		local chars = ""
		local _index = 0
		for j = 1,count do
			_index = (i - 1)*count + j
			if texts[_index] then
				chars = chars .. texts[_index]
			end
		end
		lables[#lables + 1] = chars
	end
	
	local lable = XTHDLabel:create("唐",self.detail_fontSize)
	local _width = lable:getContentSize().width
	local height = lable:getContentSize().height

	for i = 1,#lables do
		local _heroDescript_label = XTHDLabel:create(lables[i],self.detail_fontSize-2,"res/fonts/hwzs.ttf")
		_heroDescript_label:setColor(cc.c3b(60,0,0))
		_heroDescript_label:setAnchorPoint(cc.p(1,1))
		_heroDescript_label:setDimensions(_width, height * count)    
		kuang1:addChild(_heroDescript_label)
	
		local x,y
		x = kuang1:getContentSize().width - (i-1)*_heroDescript_label:getContentSize().width - 40
		y = kuang1:getContentSize().height - 20
		_heroDescript_label:setPosition(x,y)
	end

     --英雄属性框
     local kuang2 = ccui.Scale9Sprite:create("res/image/newHeroinfo/shuxingbg.png")
     kuang2:setPosition(cc.p(kuang1:getContentSize().width + kuang1:getPositionX(),self:getContentSize().height*0.5 - 5))
     kuang2:setAnchorPoint(0,0.5)
     self:addChild(kuang2)
	
	 local _contentWidth = kuang2:getContentSize().width

    --属性介绍
--    local help_btn = XTHDPushButton:createWithParams({
--		normalFile        = "res/image/camp/lifetree/wanfa_up.png",
--        selectedFile      = "res/image/camp/lifetree/wanfa_down.png",
--        musicFile = XTHD.resource.music.effect_btn_common,
--        endCallback       = function()
--            local StoredValue = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type=14});
--			local scene = cc.Director:getInstance():getRunningScene()
--			StoredValue:setAnchorPoint(0.5,0.5)
--			StoredValue:setPosition(0,0)
--            scene:addChild(StoredValue)
--        end,
--	})
--    help_btn:setScale(0.9)
--    help_btn:setAnchorPoint(cc.p(0.5,0.5))
--    help_btn:setPosition(cc.p(self:getContentSize().width/2+_contentWidth/2 - 15,_heroDetailTitle_bg:getBoundingBox().y-20))
--    self:addChild(help_btn,3)
   local _downPosY = 15
--    if self.isOther ~=nil and self.isOther == true then
--        help_btn:setVisible(false)
--        _downPosY = self.otherDistance
--    end
    --属性值
    
    local _propertyHeight = kuang2:getContentSize().height - 45

    local _downShade = ccui.Scale9Sprite:create(cc.rect(28,0,2,15),"res/image/common/common_scale_shade.png")
    _downShade:setContentSize(cc.size(_contentWidth-10,15))
    _downShade:setAnchorPoint(cc.p(0.5,0))
    _downShade:setPosition(cc.p(self:getContentSize().width/2,_downPosY-2))
    self:addChild(_downShade)
    _downShade:setVisible(false)

    local _tableViewCellSize = cc.size(_contentWidth,28)
    self._tableView = CCTableView:create(cc.size(kuang2:getContentSize().width,_propertyHeight))
    self._tableView:setPosition(cc.p(0,10))
    self._tableView:setBounceable(true)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._tableView:setDelegate()
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    kuang2:addChild(self._tableView)

    self.propertyData = XTHD.getHeroPropertyData(self.data)

    local function cellSizeForTable(table,idx)
        return _tableViewCellSize.width,_tableViewCellSize.height
    end

    local function numberOfCellsInTableView(table)
        return #self.propertyData
    end

    local function scrollViewDidScroll(view)
        local offset = self._tableView:getContentOffset().y
        if offset < 0 then
            _downShade:setVisible(false)
        else
            _downShade:setVisible(false)
        end
    end

    local function tableCellAtIndex(table,idx)
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
        end
        local _propertyPosX = 20
        local _detailData = self.propertyData[idx+1]
        local info_label_name = XTHDLabel:create(_detailData.name .. ":",self.detail_fontSize)
        info_label_name:setColor(cc.c3b(60,0,0))
        info_label_name:setAnchorPoint(0,0.5)
        info_label_name:setPosition(cc.p(_propertyPosX,_tableViewCellSize.height/2))
        cell:addChild(info_label_name)
        local current_info_number = XTHDLabel:create(XTHD.resource.addPercent(_detailData.propertyNum,_detailData.propertyValue), self.detail_fontSize)
        current_info_number:setColor(cc.c3b(60,0,0))
        current_info_number:setAnchorPoint(0,0.5)
        current_info_number:setPosition(cc.p(_propertyPosX + 90,info_label_name:getPositionY()))
        cell:addChild(current_info_number)

        return cell
    end

    self._tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:reloadData()

    if tonumber(self._tableView:getContentOffset().y)<0 then
        _downShade:setVisible(false)
    end

end

function YingXiongDetailPropertyLayer:reFreshHeroFunctionInfo()
    self.data = nil
    self.data = clone(self.infoLayer and self.infoLayer.data)
    -- self:setPropertyPart(self.data)
    self.propertyData = XTHD.getHeroPropertyData(self.data)
    self._tableView:reloadData()
end

function YingXiongDetailPropertyLayer:reFreshHeroFunctionInfo2(data)
    self.data = data
    -- self:setPropertyPart(self.data)
    self.propertyData = XTHD.getHeroPropertyData(self.data)
    self._tableView:reloadData()
end

--获取英雄升级界面的文字颜色
function YingXiongDetailPropertyLayer:getDetailTextColor(_str)
    -- local _nameColor = XTHD.resource.getQualityItemColor(self.itemInfoData["rank"])
    local _textColor = {
        hongse = cc.c4b(204,2,2,255),                           --红色
        shenhese = cc.c4b(70,34,34,255),                        --深褐色，用的比较多
        -- lanse = cc.c4b(26,158,207,255), 
        lanse = cc.c4b(3,102,204,255),                        --蓝色
        -- chenghongse = cc.c4b(205,101,8,255),                    --橙红色
       chenghongse = cc.c4b(255,79,2,255), 
        -- zongse = cc.c4b(128,112,91,255),                        --棕色，有点深灰色的感觉
        zongse = cc.c4b(70,34,34,255),
        baise = cc.c4b(255,255,255,255),                        --白色
        lvse = cc.c4b(104,157,0,255),                           --绿色
    }
    return _textColor[_str]
end

function YingXiongDetailPropertyLayer:create(heroData,target_layer,isOther)
	local _node = self.new(heroData,target_layer,isOther);
	return _node;
end

return YingXiongDetailPropertyLayer