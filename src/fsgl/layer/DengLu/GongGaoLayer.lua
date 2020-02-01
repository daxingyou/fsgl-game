
NOTICE_EXIST = false
local GongGaoLayer = class("GongGaoLayer", function()
   return  XTHD.createPopLayer()
end )

function GongGaoLayer:create(_callBack,data)
    local obj = GongGaoLayer.new()
    obj:init(_callBack,data)
    return obj
end

function GongGaoLayer:init(_callBack,data)
    self._callBack = _callBack
    self:setTouchEnabled(true)
	self:initData(data)
    self:registerScriptTouchHandler( function(eventType, x, y)
        if (eventType == "began") then
            return true
        elseif (eventType == "ended") then
            -- if self._notice_bg then
            --     local pPos = cc.p(x,y)
            --     local rect = self._notice_bg:getBoundingBox()
            --     if cc.rectContainsPoint(rect, pPos) == false then   --注意参数顺序cc.rectContainsPoint( rect, point )
            --         self:removeFromParent()
            --     end
            -- end
        end
    end )
end

function GongGaoLayer:onExit()
    NOTICE_EXIST = false
    if self._scrollView then
        self._scrollView:removeFromParent()
        self._scrollView = nil
    end
    if self._callBack then
        self._callBack()
    end
end

function GongGaoLayer:onEnter()
    NOTICE_EXIST = true
--    local str_url = XTHD.config.server.url_uc .. "versionNotice"
--    XTHDHttp:requestAsyncWithParams( {
--        url = str_url,
--        isNotice = true,
--        encrypt = HTTP_ENCRYPT_TYPE.NONE,
--        method = HTTP_REQUEST_TYPE.GET,
--        successCallback = function(data)
--            if type(data) == "table" and data["result"] == 0 then
--                -- print("服务器返回的公告数据为：")
--                -- print_r(data)
--                -- local state = tonumber(data.state) or 1
--                -- if state == 0 then
--                self:initData(data)
--                -- else
--                -- self:removeFromParent()
--                -- end
--            else
--                XTHDTOAST(data["msg"])
--                self:removeFromParent()
--            end
--        end,
--        -- 成功回调
--        failedCallback = function()
--            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
--            self:removeFromParent()
--        end-- 失败回调
--    } )
end

function GongGaoLayer:initData(data)
    -- print("公告内容为：")
    -- print_r(data)
    local _string = data["notice"] or ""
    if _string == "" or #data["notice"] == 0 then
        self:removeFromParent()
        return
    end

    self.selectedIndex = 0
    self.selectTab = nil
    self.noticeData = data["notice"]

    local notice_bg = cc.Sprite:create("res/image/common/publicNoticeBack.png")
    notice_bg:setPosition(self:getContentSize().width * 0.5, self:getContentSize().height * 0.5)
    self:addContent(notice_bg)

	local btn_close = XTHDPushButton:createWithFile({
		normalFile = "res/image/login/ggbtn/btn_close_up.png",
		selectedFile = "res/image/login/ggbtn/btn_close_down.png",
		endCallback  = function()
           self:hide()
		end,
	})
	notice_bg:addChild(btn_close)
	btn_close:setPosition(notice_bg:getContentSize().width - btn_close:getContentSize().width *0.5 - 5,notice_bg:getContentSize().height - btn_close:getContentSize().height *0.5-15)

	local haibao = cc.Sprite:create("res/image/common/haibao_06.png")
	notice_bg:addChild(haibao)
	haibao:setPosition(notice_bg:getContentSize().width *0.5 + 4,notice_bg:getContentSize().height - haibao:getContentSize().height *0.5 - 60)

    -- local notic_title = cc.Sprite:create("res/image/common/noticeTitle2.png")
    -- notic_title:setAnchorPoint(cc.p(0.5, 0))
    -- notic_title:setPosition(notice_bg:getContentSize().width*0.5,notice_bg:getContentSize().height - 45)
    -- notice_bg:addChild(notic_title)

    self._notice_bg = notice_bg

    -- 公告tableview
    local tableView = cc.TableView:create(cc.size(175, 303))
    tableView:setPosition(37, 52)
    -- tableView:setInertia( true )
    -- tableView:setBounceable( true )
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._notice_bg:addChild(tableView)
    self._tableView = tableView

    local cellWidth = 175
    local cellHeight = 79

    local function numberOfCellsInTableView(table)
        return #self.noticeData
    end
    local function cellSizeForTable(table, index)
        return cellWidth, cellHeight
    end
    local function tableCellAtIndex(table, index)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
            self:buildCell(cell, index, cellWidth, cellHeight)
        else
            if cell:getChildByName("cellBtn") then
                local _cellBtn = cell:getChildByName("cellBtn")
                if _cellBtn.selected and _cellBtn.selected == true then
                    _cellBtn.selected = false
                end
            end
            -- cell:removeAllChildren()
        end
        self:updateCell(cell, index)
        return cell
    end
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()


    -- 测试样式有需要可以打开看看

    -- 标题图片
    local title = cc.Sprite:create("res/image/common/title01.png")
    --title:setContentSize(744, 118)
    title:setPosition(cc.p(529, notice_bg:getContentSize().height - 230))
    notice_bg:addChild(title)

    local tsize = cc.size(560, 250)
    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(tsize)
    scrollView:setBounceEnabled(true)
    scrollView:setPosition(256, 52)
    scrollView:setInnerContainerSize(tsize)
    notice_bg:addChild(scrollView)
    self._scrollView = scrollView
	scrollView:setScrollBarEnabled(false)

    -- 内容信息
    local _richText = ccui.RichText:create();
    RichTextPlug.init(_richText)
    _richText:setAnchorPoint(0, 0)
    _richText:setPosition(0, tsize.height)
    _richText:setContentSize(tsize)
    _richText:setMultiLineMode(true)
    _richText:setText(self.noticeData[1].content)
    scrollView:addChild(_richText)
    self._richText = _richText

    -- 延迟调整公告文本位置
    local delay = cc.DelayTime:create(0.01)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create( function()
        local svSize = self._scrollView:getContentSize()
        local vrSize = self._richText:getVirtualRendererSize()
        if vrSize.height < svSize.height then
            self._richText:setPosition(0, svSize.height - vrSize.height)
            self._scrollView:setInnerContainerSize(svSize)
        else
            self._richText:setPosition(0, 0)
            self._scrollView:setInnerContainerSize(vrSize)
        end
    end ))
    self._scrollView:runAction(sequence)

--    local _btnAction = XTHDPushButton:createWithParams( {
--        normalFile = "res/image/common/btn/wzdl_up.png",
--        selectedFile = "res/image/common/btn/wzdl_down.png",
--        btnSize = cc.size(130,48),
--        endCallback = function()
--            self:removeFromParent()
--        end
--    } )

--    _btnAction:setPosition(cc.p(notice_bg:getContentSize().width * 0.5, 55))
--    notice_bg:addChild(_btnAction)

end

function GongGaoLayer:buildCell(cell, index, cellWidth, cellHeight)
    local noticeData = self.noticeData[index + 1]
    -- cell背景
    local _cellBtn = ccui.Button:create("res/image/login/ggbtn/" .. noticeData.path .. "_down.png", "res/image/login/ggbtn/" .. noticeData.path .. "_up.png", "res/image/login/ggbtn/" .. noticeData.path .. "_up.png")
    _cellBtn:setAnchorPoint(cc.p(0.5, 0.5))
    _cellBtn:setPosition(cc.p(cellWidth / 2, cellHeight / 2))
    _cellBtn:setSwallowTouches(false)
    _cellBtn:setTag(index + 1)
    cell:addChild(_cellBtn)

    _cellBtn:setName("cellBtn")
    cell._cellBtn = _cellBtn

    if index == 0 then
        self.selectTab = _cellBtn
        self.selectedIndex = 0
        --        self.selectTab:setEnabled(false)
        _cellBtn:loadTextureNormal("res/image/login/ggbtn/" .. noticeData.path .. "_up.png")
    end

    _cellBtn:addTouchEventListener( function(sender)
        local noticeData = self.noticeData[self.selectTab:getTag()]
        print(self.selectTab:getTag())
        self.selectTab:setEnabled(true)
        self.selectTab:loadTextureNormal("res/image/login/ggbtn/" .. noticeData.path .. "_down.png")
        self.selectTab = _cellBtn
        noticeData = self.noticeData[sender:getTag()]
        print(sender:getTag())
        --        sender:setEnabled(false)
        sender:loadTextureNormal("res/image/login/ggbtn/" .. noticeData.path .. "_up.png")
        self:refreshNoticeUIData(noticeData.content, index)
        self.selectedIndex = index
    end )

    -- -- 标题
    -- local title = XTHD.createLabel({
    --     anchor = cc.p( 0.5, 0.5 ),
    --     pos = cc.p( _cellBtn:getContentSize().width / 2, _cellBtn:getContentSize().height / 2),
    --     color = cc.c3b( 168, 23, 43 ),
    --     fontSize = 20,
    -- })

    -- _cellBtn:addChild( title )
    -- cell._title = title
end

function GongGaoLayer:updateCell(cell, index)
    -- 标题
    local noticeData = self.noticeData[index + 1]

    -- cell._title:setString(noticeData.title)

    _cellBtn = cell._cellBtn

    _cellBtn:setTag(index + 1)
    if index == self.selectedIndex then
        --        _cellBtn:setEnabled(false)
        _cellBtn:loadTextureNormal("res/image/login/ggbtn/" .. noticeData.path .. "_up.png")
    else
        _cellBtn:setEnabled(true)
        _cellBtn:loadTextures("res/image/login/ggbtn/" .. noticeData.path .. "_down.png", "res/image/login/ggbtn/" .. noticeData.path .. "_up.png")
    end
end

function GongGaoLayer:refreshNoticeUIData(noticeContent, index)
    if not noticeContent or self.selectedIndex == index then
        return
    end
    self._richText:setText(noticeContent)
    -- 延迟调整公告文本位置
    local delay = cc.DelayTime:create(0.01)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create( function()
        local svSize = self._scrollView:getContentSize()
        local vrSize = self._richText:getVirtualRendererSize()
        if vrSize.height < svSize.height then
            self._richText:setPosition(0, svSize.height - vrSize.height)
            self._scrollView:setInnerContainerSize(svSize)
        else
            self._richText:setPosition(0, 0)
            self._scrollView:setInnerContainerSize(vrSize)
        end
    end ))
    self._scrollView:runAction(sequence)
end

return GongGaoLayer