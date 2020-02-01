-- FileName: BangZhuTuiWei.lua
-- Author: wangming
-- Date: 2015-10-21
-- Purpose: 帮会退位
--[[TODO List]]

local BangZhuTuiWei = class("BangZhuTuiWei", function ( sParams ) 
	return requires("src/fsgl/layer/BangPai/BangPaiXinXi.lua"):create(sParams)
end)

function BangZhuTuiWei:init( sParams )
	local mParams = sParams or {}
	local popNode = self._popNode
	local _worldSize = popNode:getContentSize()
	local _nowSelectId = 0

	local _titleBack = self._titleBack
	_titleBack:setVisible(false)
	--文字
	local wenzi = cc.Sprite:create("res/image/guild/guildTitleText_chooseHeir.png")
	wenzi:setPosition(popNode:getContentSize().width/2,popNode:getContentSize().height-7-15)
	popNode:addChild(wenzi)

	local _tableSize = cc.size(_worldSize.width*0.95, 240)

	local _cellSize = cc.size(_tableSize.width*0.95, 115)
	local function cellSizeForTable(table, idx)
		return _cellSize.width,_cellSize.height
    end
    local function numberOfCellsInTableView(table)
        return #mParams
    end
    local function tableCellTouched(table, cell)
    	local pIndex = _nowSelectId
    	_nowSelectId = cell._idx or 0
    	if pIndex ~= _nowSelectId then
	    	table:updateCellAtIndex(pIndex)
	    	table:updateCellAtIndex(_nowSelectId)
	    end
    end
	local function tableCellAtIndex(table, idx)
		local _cell = table:dequeueCell()
	    if _cell then
	        _cell:removeAllChildren()
	    else
	        _cell = cc.TableViewCell:new()
	    end
	    _cell._idx = idx
		local data = mParams[idx+1] or {}

		local _pic = "res/image/common/scale9_bg1_26.png"
		if idx == _nowSelectId then
			_pic = "res/image/common/scale9_bg1_26.png"
		end

	    local pCellSize = cc.size(_cellSize.width, _cellSize.height - 5)
	    local _di = ccui.Scale9Sprite:create(_pic)
	    _di:setContentSize(pCellSize)
	    _di:setAnchorPoint(0.5, 0)
	    _di:setPosition(_tableSize.width*0.5, 0)
	    _di:setName("cellDi")
	    _cell:addChild(_di)

	     local _ttfX = 130
	    local _ttfX2 = 290
	    local pY = 30
	    local pY2 = 25
	    local _ttfColor = cc.c3b(54,55,112)

	    local line = cc.Sprite:create("res/image/guild/guild_verticalLine.png")
	    line:setAnchorPoint(0.5, 1)
	    line:setRotation(-90)
	    line:setScaleY(7)
	    line:setPosition(40, _cellSize.height*0.5 + 10)
	    _di:addChild(line)

		local pNum = tonumber(data.template) or 1
	    local icon = HaoYouPublic.getFriendIcon({templateId = pNum}, {notShowLv = true, notShowCamp = true})
	    if icon then
	    	icon:setScale(0.8)
	    	icon:setAnchorPoint(0, 0.5)
	    	icon:setPosition(20, pCellSize.height*0.5 + 3)
	    	_di:addChild(icon)
	    end

	    local _nameTTF = XTHDLabel:createWithSystemFont(data.name, "Helvetica", 22)
	    _nameTTF:setColor(_ttfColor)
	    _nameTTF:setAnchorPoint(0, 0.5)
	    _nameTTF:setPosition(_ttfX , _cellSize.height - pY)
		_di:addChild(_nameTTF)

		---line 2
		pNum = tonumber(data.level) or 1
		local _lvTTF = XTHDLabel:createWithSystemFont("Lv:" .. pNum, "Helvetica", 18)
	    _lvTTF:setColor(_ttfColor)
	    _lvTTF:setAnchorPoint(0, 0.5)
	    _lvTTF:setPosition(_ttfX + _nameTTF:getContentSize().width + 2, _cellSize.height - pY)
		_di:addChild(_lvTTF)

		local ttf1 = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_GUILD_TEXT.guildTodayContributionTextXc .. "：", "Helvetica", 18)
	    ttf1:setColor(_ttfColor)
	    ttf1:setAnchorPoint(0, 0.5)
	    ttf1:setPosition(_ttfX , _cellSize.height*0.5 - 5)
		_di:addChild(ttf1)
		pNum = tonumber(data.dayContribution) or 0
		local ttfNum1 = XTHDLabel:createWithSystemFont(pNum, "Helvetica", 20)
	    ttfNum1:setColor(_ttfColor)
	    ttfNum1:setAnchorPoint(0, 0.5)
	    ttfNum1:setPosition(ttf1:getPositionX() + ttf1:getContentSize().width - 10, ttf1:getPositionY())
		_di:addChild(ttfNum1)

		local ttf2 = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_GUILD_TEXT.guildAllPowerTextXc .. "：", "Helvetica", 18)
	    ttf2:setColor(_ttfColor)
	    ttf2:setAnchorPoint(0, 0.5)
	    ttf2:setPosition(_ttfX2 , ttf1:getPositionY())
		_di:addChild(ttf2)
		pNum = tonumber(data.power) or 0
		local ttfNum2 = XTHDLabel:createWithSystemFont(pNum, "Helvetica", 20)
	    ttfNum2:setColor(_ttfColor)
	    ttfNum2:setAnchorPoint(0, 0.5)
	    ttfNum2:setPosition(ttf2:getPositionX() + ttf2:getContentSize().width - 10, ttf1:getPositionY())
		_di:addChild(ttfNum2)

		----line 3
		ttf1 = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_GUILD_TEXT.guildAllContributionTextXc .. "：", "Helvetica", 18)
	    ttf1:setColor(_ttfColor)
	    ttf1:setAnchorPoint(0, 0.5)
	    ttf1:setPosition(_ttfX , pY2)
		_di:addChild(ttf1)

		pNum = tonumber(data.totalContribution) or 0
		ttfNum1 = XTHDLabel:createWithSystemFont(pNum, "Helvetica", 18)
	    ttfNum1:setColor(_ttfColor)
	    ttfNum1:setAnchorPoint(0, 0.5)
	    ttfNum1:setPosition(ttf1:getPositionX() + ttf1:getContentSize().width - 10, ttf1:getPositionY())
		_di:addChild(ttfNum1)

		ttf2 = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_GUILD_TEXT.guildRankTextXc .. "：", "Helvetica", 18)
	    ttf2:setColor(_ttfColor)
	    ttf2:setAnchorPoint(0, 0.5)
	    ttf2:setPosition(_ttfX2 , ttf1:getPositionY())
		_di:addChild(ttf2)

		local pScale = 0.4
		pNum = tonumber(data.duanId) or 0
	    local teamBadge = cc.Sprite:create("res/image/common/rank_icon/rankIcon_"..pNum..".png")
	    teamBadge:setAnchorPoint(cc.p(0,0.5))
	    teamBadge:setScale(pScale)
	    teamBadge:setPosition(ttf2:getPositionX() + ttf2:getContentSize().width, ttf1:getPositionY())
	    _di:addChild(teamBadge)

		pNum = tonumber(data.rank) or 0
		ttfNum1 = XTHDLabel:createWithSystemFont(pNum, "Helvetica", 18)
	    ttfNum1:setColor(_ttfColor)
	    ttfNum1:setAnchorPoint(0, 0.5)
	    ttfNum1:setPosition(teamBadge:getPositionX() + teamBadge:getContentSize().width*pScale , ttf1:getPositionY())
		_di:addChild(ttfNum1)

		return _cell
    end

    local pos = cc.p((_worldSize.width - _tableSize.width)*0.5, 65)
	local spBack = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	spBack:setAnchorPoint(0, 0)
	spBack:setContentSize(_tableSize)
	spBack:setPosition(pos)
	popNode:addChild(spBack)

 	local _tableView = CCTableView:create(_tableSize)
    _tableView:setPosition(pos)
    _tableView:setBounceable(true)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    _tableView:setDelegate()
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
 
	_tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData()  

    popNode:addChild(_tableView)
	
    local _btn1 = XTHD.createCommonButton({
	    	btnColor = "write_1",
			btnSize = cc.size(130,46),
			isScrollView = false,
            text = LANGUAGE_BTN_KEY.cancel,
			anchor = cc.p(0.5, 0),
			pos = cc.p(_worldSize.width*0.25, 20),
			endCallback = function ( ... )
				self:hide()
			end
		})
		_btn1:setScale(0.6)
	popNode:addChild(_btn1)
	
	local _btn2 = XTHD.createCommonButton({
			btnColor = "write",
			btnSize = cc.size(130,46),
			isScrollView = false,
            text = LANGUAGE_BTN_KEY.sure,
			anchor = cc.p(0.5, 0),
			pos = cc.p(_worldSize.width*0.75, 20),
			endCallback = function ( ... )
				local data = mParams[_nowSelectId+1]
				ClientHttp.httpConcessionGuild( self, function ( sData )
					gameUser.setGuildRole(sData.guildRole)
					self._params = BangPaiFengZhuangShuJu.getGuildData()
					for k,v in pairs(self._params.list) do
						if v.charId == gameUser.getUserId() then
							v.roleId = sData.guildRole
						elseif v.charId == data.charId then
							v.roleId = 1
						end
					end
					BangPaiFengZhuangShuJu.setGuildData(self._params)
					self:hide()
		            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_INFO})
		            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
					--退位成功，去处理数据、刷新列表什么的吧
				end, {otherId = data.charId} )
			end
		})
		_btn2:setScale(0.6)
	popNode:addChild(_btn2)
end


function BangZhuTuiWei:createOne( sParams ) -- {BangPaiFengZhuangShuJu}
	local params = {
		size = cc.size(521, 360),
		titleNode = cc.Sprite:create("res/image/guild/guildTitleText_chooseHeir.png"),
	}
	local pLay = BangZhuTuiWei.new( params )
	pLay:init(sParams)
	LayerManager.addLayout(pLay,{noHide = true})
	return pLay
end

return BangZhuTuiWei