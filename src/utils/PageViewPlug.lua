-- 将PageView放入该插件即可实现循环滚动效果

PageViewPlug = PageViewPlug or { }

function PageViewPlug.init(pageView)
    pageView.setSaveCache = PageViewPlug.setSaveCache
    pageView.onLoadListener = PageViewPlug.onLoadListener
    pageView.onSelectedListener = PageViewPlug.onSelectedListener
    pageView.jumpToPage = PageViewPlug.jumpToPage
    pageView.loadPage = PageViewPlug.loadPage
    pageView.reloadData = PageViewPlug.reloadData
    pageView.updatePageAtIndex = PageViewPlug.updatePageAtIndex

    pageView.getCurrentPage = PageViewPlug.getCurrentPage
    pageView.getCurrentIndex = PageViewPlug.getCurrentIndex

    pageView.scrollToLast = PageViewPlug.scrollToLast
    pageView.scrollToNext = PageViewPlug.scrollToNext
	pageView._isScroll = true

    -- 监听滑动事件
    pageView:addEventListener( function(sender, eventType)
        local index = sender:getCurrentPageIndex()
        if index ~= sender.index then
            sender:jumpToPage(index)
        end
    end )
end

-- 设置是否保留缓存
function PageViewPlug:setSaveCache(save)
    self.isCache = save or false
end

function PageViewPlug:onLoadListener(callback)
    if callback ~= nil and "function" == type(callback) then
        self.loader = callback
    end
end

function PageViewPlug:onSelectedListener(callback)
    if callback ~= nil and "function" == type(callback) then
        self.selecter = callback
    end
end

function PageViewPlug:jumpToPage(index)
    if self.length<2 then
        return
    end
    if index < 1 then
        index = self.length
    elseif index > self.length then
        index = 1
    end
    self.index = index
    self:loadPage(index)
    self:scrollToPage(index, 0)

    if self.isCache ~= true and self.length > 5 then
        local length = self.length + 1

        local lastIndex1 = self.index - 1
        if lastIndex1 < 0 then
            lastIndex1 = length
        end
        local lastIndex2 = lastIndex1 - 1
        if lastIndex2 < 0 then
            lastIndex2 = length
        end
        local lastIndex3 = lastIndex2 - 1
        if lastIndex3 < 0 then
            lastIndex3 = length
        end

        local nextIndex1 = self.index + 1
        if nextIndex1 > length then
            nextIndex1 = 0
        end
        local nextIndex2 = nextIndex1 + 1
        if nextIndex2 > length then
            nextIndex2 = 0
        end
        local nextIndex3 = nextIndex2 + 1
        if nextIndex3 > length then
            nextIndex3 = 0
        end

        for i = 0, length do
            if i ~= self.index and i ~= lastIndex1 and i ~= lastIndex2 and i ~= lastIndex3 and i ~= nextIndex1 and i ~= nextIndex2 and i ~= nextIndex3 then
                local page = self:getItem(i)
                page:removeAllChildren()
            end
        end
    end
end

function PageViewPlug:loadPage(index)
    self:updatePageAtIndex(index, false)

    local lastIndex = index - 1
    local nextIndex = index + 1
    local lastPage = self:getItem(lastIndex)
    local children = lastPage:getChildren()
    if children == nil or #children == 0 then
        if lastIndex < 1 then
            lastIndex = self.length
        end
        self.loader(lastPage, lastIndex)
    end
    local nextPage = self:getItem(nextIndex)
    local children = nextPage:getChildren()
    if children == nil or #children == 0 then
        if nextIndex > self.length then
            nextIndex = 1
        end
        self.loader(nextPage, nextIndex)
    end
    if self.isCache then
        local delay = cc.DelayTime:create(0.1)
        local sequence = cc.Sequence:create(delay, cc.CallFunc:create( function()
            local _length = self.length + 1
            for i = 0, _length do
                local _page = self:getItem(i)
                local _index = i
                if _index < 1 then
                    _index = self.length
                elseif _index > self.length then
                    _index = 1
                end
                local children = _page:getChildren()
                if children == nil or #children == 0 then
                    self.loader(_page, _index)
                end
            end
        end ))
        self:runAction(sequence)
    end
end

function PageViewPlug:reloadData(index, length)
    if index == nil or index < 1 then
        index = 1
    end
    if length == nil or length < 1 then
        length = 1
    end
    self.index = 0
    self.length = length

    self:removeAllChildren()

    if length > 1 then
        length = length + 2
    end
    local size = self:getContentSize()
    for i = 1, length do
        page = ccui.Layout:create()
        page:setContentSize(size)
        -- 开启超屏截图
        page:setClippingEnabled(true)
        self:addPage(page)
    end

    if self.length == 1 then
        index = 1
        local page = self:getItem(0)
        self.loader(page, index)
        if self.selecter then
            self.selecter(page, index)
        end
        self.index = index
    else
        self:jumpToPage(index)
    end
end

function PageViewPlug:updatePageAtIndex(index, isForce)
    index = index or 1
    isForce = isForce ~= false or false
    if self.length == 1 then
        index = 1
        local page = self:getItem(0)
        local children = page:getChildren()
        if isForce then
            self.loader(page, index)
        elseif children == nil or #children <= 0 then
            self.loader(page, index)
        end
        if index == self.index and self.selecter then
            self.selecter(page, index)
        end
    else
        local page = self:getItem(index)
        local children = page:getChildren()
        if isForce then
            self.loader(page, index)
            if self.isCache then
                if index == 1 then
                    local _page = self:getItem(self.length + 1)
                    self.loader(_page, index)
                elseif index == self.length then
                    local _page = self:getItem(0)
                    self.loader(_page, index)
                end
            end
        elseif children == nil or #children <= 0 then
            self.loader(page, index)
        end
        if index == self.index and self.selecter then
            self.selecter(page, index)
        end
    end
end

function PageViewPlug:getCurrentPage()
    local index = self:getCurrentPageIndex()
    local page = self:getItem(index)
    return page
end

function PageViewPlug:getCurrentIndex()
    return self.index
end

-- 向前翻页
function PageViewPlug:scrollToLast(time,callback)
    if self.length <= 1 or self.isLoading == true then
        return
    end
    self.isLoading = true
    local index = self.index - 1
    time = time or 1
	local isTouchable = self:isTouchEnabled()
	self:setTouchEnabled(false)
    self:scrollToPage(index, time)
    local delay = cc.DelayTime:create(time)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create( function()
        self.isLoading = false
		self:setTouchEnabled(isTouchable)	
		if callback then
			callback()
		end
    end ))
    self:runAction(sequence)
end

-- 向后翻页
function PageViewPlug:scrollToNext(time,callback)
    if self.length <= 1 or self.isLoading == true then
        return
    end
    self.isLoading = true
    local index = self.index + 1
    time = time or 1
	local isTouchable = self:isTouchEnabled()
    self:scrollToPage(index, time)
    local delay = cc.DelayTime:create(time)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create( function()
        self.isLoading = false
		self:setTouchEnabled(isTouchable)
		if callback then
			callback()
		end
    end ))
    self:runAction(sequence)
end