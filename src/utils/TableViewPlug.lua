-- 在所有单元格大小一致的TableView上添加getCellSize和getCellNumbers方法即可实现手动滚动

-- getCellSize获取TableView每个单元格的大小
-- getCellNumbers获取TableView的单元格数量

TableViewPlug = TableViewPlug or { }

function TableViewPlug.init(tableView)
    tableView.scrollToCell = TableViewPlug.scrollToCell
    tableView.scrollToLast = TableViewPlug.scrollToLast
    tableView.scrollToNext = TableViewPlug.scrollToNext
    tableView.getCurrentPage = TableViewPlug.getCurrentPage
    tableView.reloadDataAndScrollToCurrentCell = TableViewPlug.reloadDataAndScrollToCurrentCell
end

-- 滚动到指定下标的单元格 [animated = true 时会有动画效果， animated = false 直接跳到指定页数]
function TableViewPlug:scrollToCell(index, animated)
    animated = animated or false
    local point = self:getContentOffset()
    local direction = self:getDirection()
    local verticalFillOrder = self:getVerticalFillOrder()
    local count = self:getCellNumbers()
    local width = 0
    local height = 0
    if self.getCellSize then
        width, height = self:getCellSize(index)
    end
    local maxInset = self:maxContainerOffset()
    local minInset = self:minContainerOffset()
    if direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL then
        if minInset.x > maxInset.x then
            return
        end
        point.x = - index * width
        point.x = math.min(point.x, maxInset.x)
        point.x = math.max(point.x, minInset.x)
    else
        if minInset.y > maxInset.y then
            return
        end
        if verticalFillOrder == cc.TABLEVIEW_FILL_TOPDOWN then
            point.y = -((count - index) * height)
        else
            point.y = - index * height
        end
        point.y = math.min(point.y, maxInset.y)
        point.y = math.max(point.y, minInset.y)
    end
    self:setContentOffset(point, animated)
end

-- 获取当前展示单元格下标
function TableViewPlug:getCurrentPage()
    local point = self:getContentOffset()
    local direction = self:getDirection()
    local vertical = self:getVerticalFillOrder()
    local count = self:getCellNumbers()
    local cwidth, cheight = self:getCellSize()
    if direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL then
        -- 水平滚动
        return - point.x / cwidth
    else
        -- 垂直滚动
        if vertical == cc.TABLEVIEW_FILL_TOPDOWN then
            -- 从底部算
            return point.y / cheight + count
        else
            -- 从顶部算
            return - point.y / cheight
        end
    end
end

-- 滚动到上一个单元格
function TableViewPlug:scrollToLast(animated)
    local page = self:getCurrentPage()
    local verticalFillOrder = self:getVerticalFillOrder()
    local dir = 1
    if verticalFillOrder == cc.TABLEVIEW_FILL_TOPDOWN then
        dir = -1
    end
    self:scrollToCell(page + dir, animated)
end

-- 滚动到下一个单元格
function TableViewPlug:scrollToNext(animated)
    local page = self:getCurrentPage()
    local verticalFillOrder = self:getVerticalFillOrder()
    local dir = 1
    if verticalFillOrder == cc.TABLEVIEW_FILL_TOPDOWN then
        dir = -1
    end
    self:scrollToCell(page - dir, animated)
end

-- 重新加载单元格数据并滚到当前下标单元格
function TableViewPlug:reloadDataAndScrollToCurrentCell(animated)
    local direction = self:getDirection()
    local point = self:getContentOffset()
    animated = animated or false
    self:reloadData()
    local maxInset = self:maxContainerOffset()
    local minInset = self:minContainerOffset()
    if direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL then
        if minInset.x > maxInset.x then
            return
        end
        point.x = math.min(point.x, maxInset.x)
        point.x = math.max(point.x, minInset.x)
    else
        if minInset.y > maxInset.y then
            return
        end
        point.y = math.min(point.y, maxInset.y)
        point.y = math.max(point.y, minInset.y)
    end
    self:setContentOffset(point, animated)
end