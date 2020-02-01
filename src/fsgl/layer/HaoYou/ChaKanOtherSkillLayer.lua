local ChaKanOtherSkillLayer = class("ChaKanOtherSkillLayer",function()
		local select_sp = XTHD.createFunctionLayer()
	    return select_sp
	end)

function ChaKanOtherSkillLayer:ctor(params)
	if params._contentSize ~=nil then
        self:setTextureRect(cc.rect(0,0,params._contentSize.width,params._contentSize.height))
    end
    self:setOpacity(0)
    self._fontSize = 18

    self.skillInfoData ={}
	self:setSkillData(params._data)

    self:init()
end

function ChaKanOtherSkillLayer:init()
	local _bgWidth = self:getContentSize().width-8*2
	if self:getContentSize().width > 405 then
		_bgWidth = 405 - 8*2 + (self:getContentSize().width - 405)/2
	end
	local _bgSize = cc.size(_bgWidth ,self:getContentSize().height - 8-2)

	local _itemListBg = ccui.Scale9Sprite:create()
	_itemListBg:setContentSize(_bgSize)
	_itemListBg:setAnchorPoint(cc.p(0.5,0))
	_itemListBg:setPosition(cc.p(self:getContentSize().width/2,20))
	self:addChild(_itemListBg)

    local tableViewSize = cc.size(_bgSize.width-2 ,_bgSize.height - 2-4)
    local tableViewCellSize = cc.size(tableViewSize.width,97)
    self.tableViewCellSize = tableViewCellSize
	local skill_tableView = cc.TableView:create(tableViewSize)
	-- skill_tableView:setBounceable(true)
	skill_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	skill_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	skill_tableView:setDelegate()
	skill_tableView:setPosition(2,4)
	_itemListBg:addChild(skill_tableView)

	local _cellNumber = 5

	skill_tableView:registerScriptHandler(
        function (table_view)
            return _cellNumber
        end
    ,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	skill_tableView:registerScriptHandler(
        function (table_view,idx)
            return tableViewCellSize.width,tableViewCellSize.height
        end
    ,cc.TABLECELL_SIZE_FOR_INDEX)
    

    skill_tableView:registerScriptHandler(
    	function(table_view,cell)

    	end,cc.TABLECELL_TOUCHED)

    skill_tableView:registerScriptHandler(
    	function (table_view,idx)
    		local cell = table_view:dequeueCell()
    		if cell then
    			cell:removeAllChildren()
    		else
    			cell = cc.TableViewCell:create()
			end
			local cell_bg = self:createSkillCellInfo(idx+1)
			cell_bg:setPosition(tableViewSize.width/2,tableViewCellSize.height/2)
			cell:addChild(cell_bg)
			if _idx ~=4 then
		    	local _lineSp = ccui.Scale9Sprite:create( cc.rect( 0, 0, 3, 2 ), "res/image/ranklistreward/splitcell.png" )
				_lineSp:setContentSize(cc.size(self.tableViewCellSize.width - 2,2))
				_lineSp:setPosition(cc.p(self.tableViewCellSize.width/2,0))	
				-- cell:addChild(_lineSp)
		    end
    		return cell
	    end
    ,cc.TABLECELL_SIZE_AT_INDEX)
    -- print("onEnteronEnteronEnteronEnter")
    skill_tableView:reloadData()
end
function ChaKanOtherSkillLayer:createSkillCellInfo(_idx)
	local _idxNum = _idx

	--  ccui.Scale9Sprite:create("res/image/common/scale9_bg_12.png")
	-- cell_bg:setContentSize(cc.size(327,99))
	local cell_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
	cell_bg:setContentSize(cc.size(self.tableViewCellSize.width - 5*2,self.tableViewCellSize.height - 5 -2))

	local skill_info_data = self.skillInfoData[tonumber(_idx)] or {}

	--技能头像方框
	local skill_bg = JiNengItem:createWithParams(skill_info_data)
	skill_bg:setSwallowTouches(false)
	skill_bg:setTouchSize(cc.size(100,100))
	skill_bg:setAnchorPoint(0,0.5)
	skill_bg:setScale(60/skill_bg:getContentSize().width)
	skill_bg:setPosition(10,cell_bg:getContentSize().height / 2)
	cell_bg:addChild(skill_bg)
	
	--技能名称
	local skill_name = XTHDLabel:create(skill_info_data["name"],self._fontSize)
	skill_name:setColor(self:getTextColor("shenhese"))
	skill_name:setAnchorPoint(0,0.5)
	skill_name:enableShadow(cc.c4b(70,34,34,255),cc.size(0.3,-0.3),0.5)
	skill_name:setPosition(skill_bg:getBoundingBox().x + skill_bg:getBoundingBox().width + 10,cell_bg:getContentSize().height/3*2)
	cell_bg:addChild(skill_name)

	--是否已经解锁
	local lock_color=self:getTextColor("shenhese")
	if not skill_info_data.isUnLock or skill_info_data.isUnLock == false then
		skill_bg:setTextureGray(skill_info_data)
		lock_color = self:getTextColor("hongse")
		skill_name:setColor(self:getTextColor("huise"))
	end
	local _unlockDescLabel = XTHDLabel:create(skill_info_data.unLockDesc,self._fontSize)
	_unlockDescLabel:setAnchorPoint(cc.p(0,0.5))
	_unlockDescLabel:setPosition(cc.p(skill_name:getBoundingBox().x,cell_bg:getContentSize().height/3*1))
	_unlockDescLabel:setColor(lock_color)
	cell_bg:addChild(_unlockDescLabel)

	return cell_bg
end

function ChaKanOtherSkillLayer:setSkillData(data)
	self.skillInfoData ={}
	if data == nil then
		return
	end
	local _skillKey = {"talent","skillid","skillid0","skillid1","skillid2","skillid3"}
	local _heroid = data.id
	local _data = gameData.getDataFromCSV("GeneralSkillList") or {}
	local _table = {}

	for k, v in pairs(_data) do
		_table[v.heroid] = v
	end

	local _skillInfoTable = gameData.getDataFromCSV("JinengInfo") or {}
	local _heroskillData = _table[tonumber(_heroid)] or {}
	for i=1,#(data.skills or {}) do
		if i~=2 then
			local _skillId = _heroskillData[tostring(_skillKey[i])] or 0
			local _skillLevel = data.skills[i] or 0
			local _dataIndex = #self.skillInfoData + 1
			self.skillInfoData[tonumber(_dataIndex)] = _skillInfoTable[tonumber(_skillId)]
			self.skillInfoData[tonumber(_dataIndex)].level = _skillLevel
			local _isUnlock = true
			local _unLockDesc = LANGUAGE_KEY_HERO_TEXT.LevelTitleTextXc .. ": " .. _skillLevel
			if tonumber(_skillLevel)<1 and i>3 then
				_isUnlock = false
				_unLockDesc = LANGUAGE_TIPS_skillUnlockDescTextXc(tonumber(i-3))
			end
			if i==1 then
				_unLockDesc = LANGUAGE_KEY_HERO_TEXT.skillTalentDescTextXc
			end
			self.skillInfoData[tonumber(_dataIndex)].isUnLock = _isUnlock
			self.skillInfoData[tonumber(_dataIndex)].unLockDesc = _unLockDesc
		end
	end
end

--获取英雄升级界面的文字颜色
function ChaKanOtherSkillLayer:getTextColor(_str)
    -- local _nameColor = XTHD.resource.getQualityItemColor(self.itemInfoData["rank"])
    local _textColor = {
        hongse = cc.c4b(204,2,2,255),                           --红色
        shenhese = cc.c4b(70,34,34,255),                        --深褐色，用的比较多
        lanse = cc.c4b(3,102,204,255),                        --蓝色
        chenghongse = cc.c4b(255,79,2,255), 
        zongse = cc.c4b(70,34,34,255),
        baise = cc.c4b(255,255,255,255),                        --白色
        lvse = cc.c4b(104,157,0,255),                           --绿色
        huise = cc.c4b(41,41,41,255),                           --灰色
    }
    return _textColor[_str]
end

function ChaKanOtherSkillLayer:create(params)
	local _node = self.new(params);
	return _node;
end

return ChaKanOtherSkillLayer