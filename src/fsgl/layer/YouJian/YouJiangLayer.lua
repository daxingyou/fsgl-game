-- FileName: YouJiangLayer.lua
-- Author: wangming
-- Date: 2015-10-24
-- Purpose: 邮件UI封装
--[[TODO List]]

local YouJiangLayer = class( "YouJiangLayer", function ()
    return XTHD.createBasePageLayer()
end)

function YouJiangLayer:ctor()
    self._fontColor = cc.c3b(70, 34, 34)
    local _bg = cc.Sprite:create("res/image/plugin/equip_smelt/equipsmelt.png")
    _bg:setPosition(self:getContentSize().width*0.5, (self:getContentSize().height - 55)*0.5)
    self:addChild(_bg)
    self._bg = _bg
    self._bgSize = _bg:getContentSize()
	self._countIndex = 1
	
	local title = "res/image/public/youjian_title.png"
	XTHD.createNodeDecoration(self._bg,title)

    -- local bamboomImg = cc.Sprite:create("res/image/common/bamboom.png")
    -- bamboomImg:setAnchorPoint(cc.p(1,0))
    -- bamboomImg:setPosition( _bg:getContentSize().width/2+self:getContentSize().width/2,18 )
    -- _bg:addChild(bamboomImg)

    self._mailData = YouJiangData.getMailData() or {}
--    print("邮件内容的数据为：")
--    print_r(self._mailData)
    self._mailData.list = self._mailData.list or {}
    local newViewSize = cc.size(self._bgSize.width/2 - 40, self._bgSize.height - 60)
    self._newViewSize = newViewSize

    self._isShowOneKey = false
    for i = 1,#self._mailData.list do
        local listItem = self._mailData.list[i]
        if listItem.extractionState == 1 and listItem.accessState == 1 then  -- 1没有抽取 2已经抽取
            self._isShowOneKey = true
        end
    end

    if not self._mailData.list or #self._mailData.list <= 0 then
        local _noBg = cc.Sprite:create("res/image/plugin/mail_layer/mail_no_back.png")
        _noBg:setPosition(self._bgSize.width*0.5, self._bgSize.height*0.5 + 10)
        self._bg:addChild(_noBg)
        
        local no_mail = XTHDLabel:createWithParams({
            text = LANGUAGE_TIPS_WORDS128,-----"暂时还没有邮件！",
            fontSize = 22,
            color = cc.c3b(174, 159, 136),
            anchor = cc.p(0.5, 1)
        })
        no_mail:setPosition(self._bgSize.width*0.5, _noBg:getPositionY() - _noBg:getContentSize().height*0.5 + 10)
        _bg:addChild(no_mail)
    else
        self:initRightUI()
        self:initLeftUI()
    end
    --dump(self._mailData.list)
    -- XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RED_POINT,callback = function (  )
    --     if tonumber(gameUser.getEmailAmount()) <= 0 and self._red_point ~= nil then
    --         self._red_point:setVisible(false)
    --     end
    -- end})
end

function YouJiangLayer:initRightUI()
    local right_bg = cc.Sprite:create()
    right_bg:setContentSize(self._newViewSize.width - 15, self._newViewSize.height + 4)
    right_bg:setAnchorPoint(0, 1)
    right_bg:setPosition(self._bgSize.width*0.5 + 20, self._bgSize.height - 27)
    self._bg:addChild(right_bg)
    self.m_MailRightBg = right_bg

    local line = ccui.Scale9Sprite:create("res/image/plugin/mail_layer/splitZY.png")
    line:setContentSize(470,2)
    line:setRotation(90)
    line:setPosition(self._bg:getContentSize().width/2 +5, self._bg:getContentSize().height/2)
    self._bg:addChild(line,10)
end

function YouJiangLayer:initLeftUI()
    local left_bg = ccui.Scale9Sprite:create()
    left_bg:setContentSize(self._newViewSize.width, self._newViewSize.height + 4)
    left_bg:setAnchorPoint(0, 1)
    left_bg:setPosition(32, self._bgSize.height - 27)
    self._bg:addChild(left_bg)
    self.m_MailLeftBg = left_bg

     local _mailTableView = cc.TableView:create(self._newViewSize)
    _mailTableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _mailTableView:setPosition(cc.p(5, 2))
    _mailTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
--    _mailTableView:setBounceable(true)
    _mailTableView:setDelegate()
    left_bg:addChild(_mailTableView)
	TableViewPlug.init(_mailTableView)

    local _cellSize = cc.size(self._newViewSize.width - 14, 100)
    
	_mailTableView.getCellNumbers = function( table )
        return  #self._mailData.list
    end
    
	_mailTableView.getCellSize = function( table, idx )
        return _cellSize.width ,  _cellSize.height + 15
    end
    
    local function tableCellTouched(table, cell)
        local idx = cell:getIdx()
        if self._nowSelect and self._nowSelect:getIdx() == idx then
            return
        end
        self:setSelectItemStatus(cell)
        self:readMail(cell.emailId, idx, cell)
    end
    local function tableCellAtIndex( table, idx )
        local _cell = table:dequeueCell()
        if _cell == nil then
            _cell = cc.TableViewCell:new()
            _cell:setContentSize(_cellSize)
        else
            _cell:removeAllChildren()
        end
        self:getMailItem(_cell, idx)
        return _cell
    end

    _mailTableView:registerScriptHandler(_mailTableView.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    _mailTableView:registerScriptHandler(_mailTableView.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    _mailTableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _mailTableView:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    _mailTableView:reloadData()
    self._mailTableView = _mailTableView
end

--更新邮件列表中得选中状态
function YouJiangLayer:setSelectItemStatus( cell )
    if self._nowSelect then
        self._nowSelect._selected_icon:setVisible(false)
    end
    self._nowSelect = cell
    if self._nowSelect then
        self._nowSelect._selected_icon:setVisible(true)
    end
end

--创建邮件列表元素
function YouJiangLayer:getMailItem( cell, idx )

    local _cellSize = cell:getContentSize()
    local _cellData = self._mailData.list[idx + 1]
    cell.emailId = _cellData.emailId


    --back
    -- local _background_item = ccui.Scale9Sprite:create(cc.rect(15,15,1,1),"res/image/common/scale9_bg_26.png")
    local _background_item = ccui.Scale9Sprite:create("res/image/plugin/mail_layer/mailCellbg.png")
    _background_item:setContentSize(_cellSize.width,_cellSize.height + 10)
    _background_item:setName("_background_item")
    _background_item:setPosition(_cellSize.width*0.5 + 2, _cellSize.height*0.5 + 10)
    cell:addChild(_background_item)
    cell._background_item = _background_item

    -- 分隔线
    local splitCellLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitX.png" )
    splitCellLine:setContentSize( self._newViewSize.width + 8, 2 )
    splitCellLine:setAnchorPoint( cc.p( 0, 0 ) )
    splitCellLine:setPosition( -13, 1 )
    cell:addChild( splitCellLine )

    --设置选中状态(windows调一下)
    -- local _selected_icon = cc.LayerColor:create(cc.c4b(234,208,139,150))
    local _selected_icon = ccui.Scale9Sprite:create("res/image/common/scale9_bg_13.png")
    _selected_icon:setContentSize(cc.size(_cellSize.width + 2, _cellSize.height + 10))
    _selected_icon:setAnchorPoint(0,0)
    _selected_icon:setPosition(0, 0)
    _background_item:addChild(_selected_icon)
    cell._selected_icon = _selected_icon

    if self._nowSelect and self._nowSelect:getIdx() == idx then
        _selected_icon:setVisible(true)
    else
        _selected_icon:setVisible(false)
    end

    -- icon
    local icon_path = "" 
    if _cellData.lookState == 0 then  --0表示未读取,1表示看过
        icon_path = "res/image/plugin/mail_layer/btn_mail_closed.png" 
    else
        icon_path = "res/image/plugin/mail_layer/btn_mail_open.png" 
    end
    
    local open_icon = XTHD.createSprite(icon_path)
    open_icon:setPosition(50, _cellSize.height*0.5 + 5)
    _background_item:addChild(open_icon)
    open_icon:setScale(0.8)
    cell._icon = open_icon

    --邮件标题
    local mail_title = XTHDLabel:createWithSystemFont(_cellData.title, "Helvetica", 18)
    mail_title:setColor(self._fontColor)
    mail_title:setAnchorPoint(0, 0.5)
    mail_title:setPosition(95, _cellSize.height*0.75)
    _background_item:addChild(mail_title)

    --发件人title
    local from_title = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_SENDER..": " .. LANGUAGE_KEY_HOST, "Helvetica", 18)
    from_title:setColor(self._fontColor)
    from_title:setAnchorPoint(0,0.5)
    from_title:setPosition(mail_title:getPositionX(),_cellSize.height*0.5)
    _background_item:addChild(from_title)

     --日期
    local date_txt = XTHDLabel:createWithSystemFont(_cellData.reviceTime, "Helvetica", 18)
    date_txt:setColor(self._fontColor)
    date_txt:setAnchorPoint(0,0.5)
    date_txt:setPosition(mail_title:getPositionX(),_cellSize.height*0.25)
    _background_item:addChild(date_txt)

    --如果有附件可以领取，则显示红点
    local red_point = XTHD.createSprite("res/image/common/heroList_redPoint.png")
    red_point:setPosition(_cellSize.width - 20, _cellSize.height - 20)
    _background_item:addChild(red_point)
    cell._red_point = red_point

    --lookState : 0:没有查看;1:查看过
    --accessState 0:没有附件1:有附件
    if tonumber(_cellData["lookState"]) == 1 and tonumber(_cellData["accessState"]) == 0  then
        red_point:setVisible(false)
    end

    --默认选中第一个cell
    if not self._isFisrt then
        self:setSelectItemStatus(cell)
        performWithDelay(self, function ( ... )
            self:readMail(_cellData.emailId, idx, cell)
        end, 0.01)
        self._isFisrt = true
    end
end


function YouJiangLayer:readMail( mailId, idx, node )
    local function _readCallBack( sData )
        self:showMailMsgDetail(sData, idx, node)

        local openStats = node._icon
        if openStats ~= nil then
            openStats:initWithFile("res/image/plugin/mail_layer/btn_mail_open.png")
        end

        --处理红点
        local tmp_point = node._red_point
        if tmp_point ~= nil then
            if tonumber(#sData["monetys"]) == 0 and tonumber(#sData["items"]) == 0  then
                tmp_point:setVisible(false)
            end
        end
        --重置邮件读取状态
        local lookState = self._mailData.list[idx + 1].lookState
        if lookState then
            self._mailData.list[idx + 1].lookState = 1
        end
		self:updateMainCityRedPoint()
    end
    YouJiangData.httpReadMailList(self, _readCallBack, {emailId = mailId})
end

--邮件详细内容
function YouJiangLayer:showMailMsgDetail( data, idx, _node )
    self.m_MailRightBg:removeAllChildren()
    if not data or next(data) == nil then
        return
    end

    local _size = self.m_MailRightBg:getContentSize()
    local _bgSize = cc.size(_size.width - 10, _size.height*0.7 - 10)

   --邮件内容显示背景
    local show_mail_bg = cc.Sprite:create()
    show_mail_bg:setContentSize(_bgSize)
    show_mail_bg:setAnchorPoint(0.5, 1)
    show_mail_bg:setPosition(_size.width*0.5, _size.height - 5)
    self.m_MailRightBg:addChild(show_mail_bg)
    --邮件标题
    local title_txt = XTHDLabel:createWithSystemFont(data.title, "Helvetica", 22)
    title_txt:setAnchorPoint(cc.p(0.5, 1))
    title_txt:setColor(cc.c3b(53,25,26))
    title_txt:setPosition(_bgSize.width*0.5, _bgSize.height - 5)
    show_mail_bg:addChild(title_txt)
     --邮件内容显示标题
    local title_line = ccui.Scale9Sprite:create(cc.rect(0,0,20,2),"res/image/ranklistreward/splitX.png")
    title_line:setContentSize(cc.size(_bgSize.width+20, 2))
    title_line:setPosition(_bgSize.width*0.5, _bgSize.height - 35)
    show_mail_bg:addChild(title_line)

    -- 附件背景
    local _bgSize2 = cc.size(_bgSize.width, _size.height*0.3 - 10)
    local attachment_bg = cc.Sprite:create()
    attachment_bg:setContentSize(_bgSize2)
    attachment_bg:setAnchorPoint(0.5, 0)
    attachment_bg:setPosition(show_mail_bg:getPositionX(), 5 + 30)
    self.m_MailRightBg:addChild(attachment_bg)
    -- 附件标题
    local attachment_img = ccui.Scale9Sprite:create("res/image/plugin/mail_layer/fj_bg.png")
    attachment_img:setContentSize(cc.size(310,34))
    attachment_img:setAnchorPoint(cc.p(0.5,1))
    attachment_img:setPosition(_bgSize2.width*0.5, _bgSize2.height + 30)
    attachment_bg:addChild(attachment_img)
    local attachment_txt = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_ATTACH, "Helvetica", 22)
    attachment_txt:setAnchorPoint(cc.p(0.5, 1))
    attachment_txt:setColor(cc.c3b(53,25,26))
    attachment_txt:setPosition(_bgSize2.width*0.5, _bgSize2.height + 25)
    attachment_bg:addChild(attachment_txt)
     --附件线
    local attachment_line = ccui.Scale9Sprite:create(cc.rect(0,0,20,2),"res/image/ranklistreward/splitX.png")
    attachment_line:setContentSize(cc.size(_bgSize.width+20, 2))
    attachment_line:setPosition(_bgSize.width*0.5, _bgSize2.height +35)
    attachment_bg:addChild(attachment_line)

    -- 邮件内容
    local scrollview_size = cc.size(_bgSize.width, _bgSize.height - 75)
    local scrollview = ccui.ScrollView:create()
	scrollview:setScrollBarEnabled(false)
    scrollview:setTouchEnabled(true)
    scrollview:setDirection(ccui.ScrollViewDir.vertical)
    scrollview:setContentSize(scrollview_size)
    scrollview:setPosition(0,38)
    show_mail_bg:addChild(scrollview)
    local pHeight = 0
    local dear_player = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_MAILSTART, "Helvetica", 22)
    dear_player:setColor(self._fontColor)
    dear_player:setAnchorPoint(0, 1)
    scrollview:addChild(dear_player)
    pHeight = pHeight + dear_player:getContentSize().height

    local content_txt = XTHDLabel:createWithSystemFont(data.textContent, "Helvetica", 18)
    content_txt:setColor(self._fontColor)
    content_txt:setAnchorPoint(0, 1)
    content_txt:setWidth(scrollview_size.width - 20)
    scrollview:addChild(content_txt)
    pHeight = pHeight + content_txt:getContentSize().height + 10
    local scrollview_inner_size = scrollview:getInnerContainerSize()
    if pHeight > scrollview_inner_size.height then
        scrollview_inner_size.height = pHeight
        scrollview:setInnerContainerSize(scrollview_inner_size)
    end
    local _pos = cc.p(10, scrollview_inner_size.height - 5)
    dear_player:setPosition(_pos)
    content_txt:setPosition(_pos.x, _pos.y - dear_player:getContentSize().height - 5)


    --是否有附件奖励信息
    local is_attachment_flag = true 
    if data.items and data.monetys and #data.items == 0 and #data.monetys == 0 and data.gods and #data.gods == 0 and data.servants and #data.servants == 0 then
        is_attachment_flag = false
    end
    if not is_attachment_flag then
        local unHaveTTF = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_MAILWUEXTR, "Helvetica", 22)
        unHaveTTF:setColor(self._fontColor)
        unHaveTTF:setAnchorPoint(0.5, 0.5)
        unHaveTTF:setPosition(cc.p(_bgSize2.width*0.5, (_bgSize2.height - 40)*0.5))
        attachment_bg:addChild(unHaveTTF)
    else
        local cell_arr = {}
        for i=1,#data.monetys do
            local tmp_tab = {}
            tmp_tab.value = data.monetys[i]
            tmp_tab._type = 1   --表示货币
            cell_arr[#cell_arr+1] = tmp_tab
        end

        for i=1,#data.items do
            local tmp_tab = {}
            tmp_tab.value = data.items[i]
            tmp_tab._type = 4  --表示装备
            cell_arr[#cell_arr+1] = tmp_tab
        end
        
        if data.gods then
            for i = 1,#data.gods do  --神器
                local tmp_tab = {}
                tmp_tab.value = data.gods[i]
                tmp_tab._type = tonumber(string.split(data.gods[i],',')[1])
                print("111邮件中显示神器:"..tmp_tab._type)
                cell_arr[#cell_arr+1] = tmp_tab
            end
        end
       
        if data.servants then
            for i = 1,#data.servants do  --侍仆
                local tmp_tab = {}
                tmp_tab.value = data.servants[i]
                tmp_tab._type = tonumber(string.split(data.servants[i],',')[1])
                cell_arr[#cell_arr+1] = tmp_tab
            end
        end

        --存放点击领取时，显示领取成功的界面的数据
        local claim_success_data = {}
        for i = 1, #cell_arr do
            local item_id = 1
            local item_type = 4
            local item_data = string.split(cell_arr[i].value,",")

            if cell_arr[i]._type == 1 then
                item_type = item_data[1]
            else
                item_id = item_data[1]
                item_type = cell_arr[i]._type
            end
            --添加领取成功的数据到claim_success_data中
            local temp_table = {}
            temp_table.rewardtype = tonumber(item_type)
            temp_table.num = tonumber(item_data[2])
            if item_type == 4 then
                temp_table.id = item_id
            end
            claim_success_data[#claim_success_data+1] = temp_table
        end
        --创建item
        local function createItem( _data )
            local item_id = 1
            local item_type = 4
            local item_data = string.split(_data.value,",")

            if _data._type == 1 then
                item_type = item_data[1]
            else
                item_id = item_data[1]
                item_type = _data._type
            end

            local item = ItemNode:createWithParams({
                itemId = tonumber(item_id),
                -- quality = data.rank,
                _type_ = tonumber(item_type),
                count = item_data[2],
                -- touchShowTip = false,
            })
            item:setScale(0.85)
            return item
        end

        local _extrHight = _bgSize2.height
        local _extrWidth = #cell_arr * 80 < (_bgSize2.width -10) and #cell_arr * 80 or (_bgSize2.width -10)

        --创建tableview
        local function create_tableview( ... )
            --附件的tableview
            local tableview = cc.TableView:create(cc.size(_extrWidth, _extrHight))
            tableview:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
            tableview:setPosition(cc.p(attachment_bg:getContentSize().width/2-_extrWidth/2, 30))
--            tableview:setBounceable(true)
            tableview:setDelegate()
            attachment_bg:addChild(tableview)

            -- tableView注册事件
            local function numberOfCellsInTableView( table )
                return #cell_arr  
            end
            local function cellSizeForTable( table, idx )
                return 90, 90  
            end
            local function tableCellAtIndex( table, idx )
                local cell = table:dequeueCell()
                if cell == nil then
                    cell = cc.TableViewCell:new()
                    cell:setContentSize(90,90)
                else
                    cell:removeAllChildren()
                end

                local item = createItem(cell_arr[idx+1])
                item:setPosition(cell:getContentSize().width*0.5,cell:getContentSize().height*0.5)
                cell:addChild(item)

                return cell
            end

            tableview:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
            tableview:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
            tableview:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
            tableview:reloadData()
        end

        --当附件数量小于4个的时候，不创建tableview
        local function createMoreItem(  )
            for i=1,#cell_arr do
                local x = attachment_bg:getContentSize().width*0.5 - (#cell_arr - 1) * 40 + (i-1)*90
                local y = attachment_bg:getContentSize().height*0.5
                local item = createItem(cell_arr[i])
                item:setPosition(x,y)
                attachment_bg:addChild(item)
            end
            
        end

        if #cell_arr > 4 then
            create_tableview()
        else
            createMoreItem()
        end
        -- 领取奖励
        local claim = XTHD.createCommonButton({
            btnColor = "write",
            btnSize = cc.size(130,46),
            isScrollView = false,
            text = LANGUAGE_BTN_KEY.getReward,
            fontColor = cc.c3b(255,255,255),
            fontSize = 26,
        })
        claim:setScale(0.6)
        claim:setPosition(_size.width*0.5+100, claim:getContentSize().height/2 - 10)
        self.m_MailRightBg:addChild(claim)

        --领取奖励后，数据处理
        local function dealData( data )
--			print("单独领取奖励的数据为：")
--			print_r(data)
            if not data then
                return
            end

            if data.property and #data.property > 0 then
                for i=1,#data.property do
                    local pro_data = string.split( data.property[i],',')
                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
                end
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
            end

            if data.items and #data.items ~= 0 then
                for i=1,#data.items do
                    local item_data = data.items[i]
                    if item_data.count and tonumber(item_data.count) ~= 0 then
                        DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
                    else
                        DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
                    end
                end
            end

            local gods = data.gods
            if gods then
                for i=1,#gods do
                    DBTableArtifact.analysDataAndUpdate(gods[i])
                end
            end

            local servants = data.servants
            if servants then
                -- dump(servants,"仆从")
                for i = 1,#servants do
                    DBPetData.analysDataAndUpdate(servants[i])
                end
            end
            RedPointManage:reFreshDynamicItemData()
        end


        --已领取
        local already_cliam_font = cc.Sprite:create("res/image/vip/yilingqu.png")
        already_cliam_font:setPosition(claim:getPosition())
        already_cliam_font:setScale(0.8)
        already_cliam_font:setName("already_cliam_font")
        self.m_MailRightBg:addChild(already_cliam_font)
        already_cliam_font:setVisible(false)

        --领取奖励
        local function claimReward( data )
            if claim then
                claim:setVisible(false)
            end
            if already_cliam_font then
                already_cliam_font:setVisible(true)
            end

            --领取奖励成功后，处理红点数据，都置为附件已经领取的数据
            self._mailData.list[idx + 1].monetyType = 0
            self._mailData.list[idx + 1].itemId = 0
            self._mailData.list[idx + 1].accessState = 0

            local red_point = _node._red_point
            if red_point ~= nil then
                red_point:setVisible(false)
            end

            --显示领取奖励成功界面
            ShowRewardNode:create(claim_success_data)
			self:updateMainCityRedPoint()
            dealData(data) 
        end


        claim:setTouchEndedCallback(function (  )
            YouJiangData.httpGetMailExtra(self, claimReward, {emailId = data.emailId})
        end)

        --已经领取奖励
        if data.accessState == 0 and tonumber(data["extractionState"]) == 2 then   --extractionState = 1 没有领取，=2 已领取
            claim:setVisible(false)
            already_cliam_font:setVisible(true)
        end

		if data.accessState == 0 and tonumber(data["extractionState"]) == 1 then 
			claim:setVisible(false)
            already_cliam_font:setVisible(false)
		end


        -- 一键领取奖励
        local oneKeyClaim = XTHD.createCommonButton({
            btnColor = "write",
            btnSize = cc.size(130,46),
            isScrollView = false,
            text = "一键领取",
            fontColor = cc.c3b(255,255,255),
            fontSize = 26,
        })
        oneKeyClaim:setScale(0.6)
        oneKeyClaim:setPosition(_size.width*0.5 - 50, oneKeyClaim:getContentSize().height/2 - 10)
        self.m_MailRightBg:addChild(oneKeyClaim)

        if self._isShowOneKey == false then
            oneKeyClaim:setVisible(false)
        end

        -- 一键领取奖励后，数据处理
        local function dealOneKeyData( data )
--            print("一键领取邮件奖励的数据为：")
--            print_r(data)
            if not data then
                return
            end
            local show = {} --奖励展示

            print(#data.property)
            --货币类型
            if data.property and #data.property > 0 then
                
                for i=1,#data.property do
                    
                    local pro_data = string.split( data.property[i],',')
                    --如果奖励类型存在，而且不是vip升级(406)则加入奖励
                    if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
                        print("proData:"..tonumber(pro_data[1]))
                        local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
                        if getNum > 0 then
                            local idx = #show + 1
                            show[idx] = {}
                            show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
                            show[idx].num = getNum
                        end
                    end
                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
                end
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
            end

            --神器
			local gods = data.gods
            if gods then
                for i=1,#gods do
                    DBTableArtifact.analysDataAndUpdate(gods[i])
					local t = gameData.getDataFromCSV("SuperWeaponUpInfo",{id = gods[i].templateId})._type
					local idx = #show + 1
					show[idx] = {}
					show[idx].rewardtype = t -- item_data.item_type
					show[idx].id = gods[i].templateId
					show[idx].num = 1
                end
            end

            --侍仆
            local servants = data.servants
            if servants then
                -- dump(servants,"仆从")
                for i = 1,#servants do
                    DBPetData.analysDataAndUpdate(servants[i])
					local t = gameData.getDataFromCSV("ServantUp",{id = servants[i].templateId})._type
					local idx = #show + 1
					show[idx] = {}
					show[idx].rewardtype = t -- item_data.item_type
					show[idx].id = servants[i].templateId
					show[idx].num = 1
                end
            end
            RedPointManage:reFreshDynamicItemData()

            --物品类型
            print(#data.items)
            if data.items and #data.items ~= 0 then
                for i=1,#data.items do
                    local item_data = data.items[i]
                    local showCount = item_data.count
                    if item_data.count and tonumber(item_data.count) ~= 0 then
                        --print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
                        showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId));
                        DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
                    else
                        DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
                    end
                    --如果奖励类型
                    local idx = #show + 1
                    show[idx] = {}
                    show[idx].rewardtype = 4 -- item_data.item_type
                    show[idx].id = item_data.itemId
                    show[idx].num = showCount
                end
            end


            --显示领取奖励成功界面
            ShowRewardNode:create(show)
            gameUser.setEmailAmount(0)
            RedPointManage:reFreshDynamicItemData()
        end

        --领取奖励
        local function oneKeyClaimReward( data )
            if claim then
                claim:setVisible(false)
            end
            if oneKeyClaim then
                oneKeyClaim:setVisible(false)
            end
            if already_cliam_font then
                already_cliam_font:setVisible(true)
            end
            self._isShowOneKey = false

            --领取奖励成功后，处理红点数据，都置为附件已经领取的数据
            for i = 1, #self._mailData.list do
                local listItem = self._mailData.list[i]
                listItem.monetyType = 0
                listItem.itemId = 0
                listItem.accessState = 0
                listItem.lookState = 1
            end

            -- 遍历所以cell 取消红点显示
            for i = 1, #self._mailData.list do
                local tableCell = self._mailTableView:cellAtIndex(i - 1)
                if tableCell and tableCell._red_point then
                    tableCell._red_point:setVisible(false)
                end
            end
			 self:updateMainCityRedPoint()
            dealOneKeyData(data) 
        end

        oneKeyClaim:setTouchEndedCallback(function (  )
            YouJiangData.httpGetMailExtraOneKey(self, oneKeyClaimReward)
        end)

    end

    -- 删除按钮
    local delBtn = XTHD.createButton({
        normalFile   = "res/image/plugin/mail_layer/del_up.png",
        selectedFile = "res/image/plugin/mail_layer/del_down.png",
        anchor       = cc.p(1,0)
    })
    delBtn:setPosition(_size.width*0.5 + 220, delBtn:getContentSize().height/2 - 10)

    delBtn:setTouchEndedCallback(function()
        local function delMailReward(data)
            XTHDTOAST("邮件删除成功！")
            delBtn:setVisible(false)
            --dump(self._mailData.list)
            table.remove(self._mailData.list, idx + 1)
            --print("delMailReward --- "..tostring(idx))
            --dump(self._mailData.list)
            --self._mailTableView:removeCellAtIndex(idx)

            self._mailTableView:reloadDataAndScrollToCurrentCell()

            if idx >= #self._mailData.list then
                idx = #self._mailData.list - 1
            end

            local cell = self._mailTableView:cellAtIndex(idx)
            if cell then
                self:setSelectItemStatus(cell)
                performWithDelay(self, function ( ... )
                    self:readMail(cell.emailId, idx, cell)
                end, 0.01)
            end

            if idx < 0 then
                self.m_MailRightBg:removeAllChildren()
            end
        end

        YouJiangData.httpGetMailDel(self, delMailReward, {emailId = data.emailId})
    end)
    self.m_MailRightBg:addChild(delBtn)
    
end

function YouJiangLayer:updateMainCityRedPoint()
	RedPointState[15].state = 0
	for i = 1, #self._mailData.list do
        local tableCell = self._mailTableView:cellAtIndex(i - 1)
        if tableCell and tableCell._red_point then
           if tableCell._red_point:isVisible() then
				RedPointState[15].state = 1
				XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "mail"}})
				return
			end
		end
	end
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "mail"}})
end

--************************************************GM信箱  部分  end ******************************************
function YouJiangLayer:create()
	return self.new()
end

return YouJiangLayer;
