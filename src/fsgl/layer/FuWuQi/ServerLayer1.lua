--[[选服务器]]
local ServerLayer1 = class("ServerLayer1", function(params)
    return XTHDPopLayer:create()
end)

local PER_COUNT = 2
function ServerLayer1:onCleanup()
    print("ServerLayer1:onCleanup"..tostring(self._closeCallback))
    if self._closeCallback then
        self._closeCallback()
    end
end

function ServerLayer1:initWithData(params)
    
    local serverId          = params.serverId
    local tab               = params.tab
    local closeCallback     = params.closeCallback
    local selectCallback    = params.selectCallback
    if not tab then
        tab = 1
    end
    self._serverId = serverId
    self._closeCallback = closeCallback
    self._selectCallback = selectCallback

    local bg = XTHD.createSprite("res/image/login/selectServer_bg.png")
    bg:setPosition(cc.p(self:getContentSize().width / 2 , self:getContentSize().height / 2))
    bg:setScale(0.8)
    self:addContent(bg)
    local title_bg = cc.Sprite:create("res/image/login/zhanghaodenglu.png")
    title_bg:setPosition(bg:getContentSize().width/2,bg:getContentSize().height-5)
    bg:addChild(title_bg)

    local title=XTHDLabel:createWithParams({text=LANGUAGE_KEY_CHOOSESERVER,ttf="res/fonts/def.ttf",size=26}) ------"选择服务器"
    title:setColor(cc.c3b(104, 33, 11))
    title:setAnchorPoint(0.5,0.5)
    title:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2)
    title_bg:addChild(title)
    local row_width = 592+14+ 12
    local row_height = 85

    local tablePoint = cc.p(15 , 40)
    local tableWidth = row_width+105
    local tableHeight = row_height * 6 - 20
    self._taskTable = cc.TableView:create(cc.size(tableWidth , tableHeight-20))
	TableViewPlug.init(self._taskTable)
    self._taskTable:setPosition(tablePoint)
    self._taskTable:setBounceable(true)
    self._taskTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._taskTable:setDelegate()
    self._taskTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    bg:addChild(self._taskTable)
     --关闭按钮
    -- local close_btn = XTHD.createBtnClose(function() 
    --     self:removeFromParent()
    -- end)
    -- close_btn:setPosition(bg:getContentSize().width - 10, bg:getContentSize().height - 10)
    -- bg:addChild(close_btn)
    
    local btn_ok = XTHD.createCommonButton({
        btnSize = cc.size(200, 80),
        isScrollView = false,
        text = LANGUAGE_BTN_KEY.sure,
        pos = cc.p(704+150 , 50),
        fontSize = 24,
        btnColor = "write_1",
        endCallback = function() 
            if self._server then
                local openState = self._server.openState
                local openTime = self._server.openTime
                if openState == 2 then
                   XTHDTOAST(LANGUAGE_TIPS_WORDS119.."...")------服务器正在维护中...")
                elseif openState == 0 then
                    self:addChild(XTHDConfirmDialog:createWithParams({msg = LANGUAGE_TIPS_WORDS120.."\n"..openTime,---------- 服务器即将开放，具体开放时间：\n"..openTime,
                        leftVisible = false
                        }))
                else
                    if self._selectCallback then
                        self._selectCallback(self._server)
                    end

                    self:hide()
                end
            end
        end
    })
    -- btn_ok:getLabel():enableOutline(cc.c4b(150,79,39,255),1)
    btn_ok:setScale(0.9)
    bg:addChild(btn_ok)

    local label_tabs = {
    --  "res/image/login/server_recommend.png",
    --  "res/image/login/server_list.png",
    --  "res/image/login/server_last.png"
    "推荐服务器","服务器列表","上次服务器"
 }
     local color_label = cc.c3b(255, 255, 255)

    --[[右边的tab]]
    for i=1,3 do
        local btn_tab = XTHD.createButton({
            normalFile = "res/image/ranklist/btn_normal.png",
            selectedFile = "res/image/ranklist/btn_selected.png",
            text = label_tabs[i],
            ttf = "res/fonts/def.ttf"
            })
        btn_tab:getLabel():enableOutline(cc.c4b(45,13,103,255),2)
        btn_tab:setPosition(cc.p(704+150,433-35+100 - 84 * (i - 1)))
        btn_tab:setLabelSize(24)
        btn_tab:setLabelColor(color_label)
        bg:addChild(btn_tab)
        -- local btn_sp=cc.Sprite:create(label_tabs[i])
        -- btn_sp:setPosition(btn_tab:getContentSize().width/2,btn_tab:getContentSize().height/2)
        -- btn_tab:addChild(btn_sp)
        btn_tab:setTouchEndedCallback(function() 
            btn_tab:setSelected(true)
            if self._last_tab then
                self._last_tab:setSelected(false)
            end
            self._last_tab = btn_tab


            self:switchTab({tab = i})

            if i == 2 then
            end

        end)
        if i == 1 then
            btn_tab:setSelected(true)
            self._last_tab = btn_tab
        end
    end


    local per       = PER_COUNT--[[每行显示的个数]]
    self.total_row  = 0
    
    self.data_list = nil
	
	self._taskTable.getCellSize = function(table,idx)
        return row_width,row_height
    end
   
	
	self._taskTable.getCellNumbers = function(table)
        return self.total_row
    end
   

    local function tableCellTouched(table,cell)
    end
    
    local function tableCellAtIndex(table1,idx)
        local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        end
        cell:removeAllChildren()
        cell:setContentSize(cc.size(row_width,row_height))

        for i=1,2 do

            if self.data_list and self.data_list[i + idx * per] ~= nil then
                local index = i + idx * per
                local data_item = self.data_list[index]
                local serverId = data_item.serverId
                local serverName = getServerName(serverId, data_item.serverName)
                local serverIp = data_item.serverIp
                local serverPort = data_item.serverPort
                local openState = data_item.openState
                local crowdState = data_item.crowdState
                local newState = data_item.newState
                local openTime = data_item.openTime
                local avatorid=1 
                local herolevel=0 
                local roleName = data_item.charName

                -- local node_normal=ccui.Scale9Sprite:create(cc.rect(20,20,1,1),"res/image/common/scale9_bg_10.png")
                -- node_normal:setContentSize(279,66)
                -- local node_select=ccui.Scale9Sprite:create(cc.rect(20,20,1,1),"res/image/common/scale9_bg_13.png")
                -- node_select:setContentSize(279,66)
                local node_normal=cc.Sprite:create("res/image/common/select_bg_10.png")
                local node_select=cc.Sprite:create("res/image/common/select_bg_11.png")
                local btn_left = XTHD.createButton{
                    normalNode = node_normal,
                    selectedNode = node_select,
                    needSwallow = false
                }
                print("IDDDD:" .. serverId .. "NAme:" .. serverName)
                btn_left:setTouchEndedCallback(function() 
                    if openState == 2 then
                        XTHDTOAST(LANGUAGE_TIPS_WORDS119..'...')-------"服务器正在维护中...")
                    elseif openState == 0 then
                        self:addChild(XTHDConfirmDialog:createWithParams({msg = LANGUAGE_TIPS_WORDS120..'\n'..openTime,--------"服务器即将开放，具体开放时间：\n"..openTime,
                            leftVisible = false
                            }))
                    end
                    -- if crowdState == 4 and (roleName == "" or roleName == nil) then
                    --    XTHDTOAST("服务器爆满")
                    --    return
                    -- end
                    xpcall(function() 
                        if self._lastSelectedServerButton ~= nil then
                            self._lastSelectedServerButton:setSelected(false)
                        end
                    end, function() end)
                    self._lastSelectedServerButton = btn_left
                    btn_left:setSelected(true)
                    self._server = data_item
                end)
                
                if self._serverId == serverId and self._lastSelectedServerButton == nil then
                   btn_left:setSelected(true)
                   self._server = data_item
                   self._lastSelectedServerButton = btn_left
                end
                local x = (i * 2 - 1) * (btn_left:getContentSize().width / 2) + 10
                local y = row_height / 2 - 5 
                if i % 2 == 0 then
                   x = x + 5
                end
                btn_left:setPosition(cc.p(x , y))
                cell:addChild(btn_left)


                local icon_server_status = XTHD.createSprite(XTHD.resource.getServerStatusImgPath(crowdState))
                icon_server_status:setPosition(x - (btn_left:getContentSize().width / 2) + 34 , y)
                cell:addChild(icon_server_status)

                local txt_server_name = XTHDLabel:createWithParams({
                    text = serverName,
                    fontSize = 22,
                    anchor = cc.p(0,0.5),
                    color = color_label,
                    ttf = "res/fonts/def.ttf"
                })
                txt_server_name:enableOutline(cc.c4b(45,13,103,255),2)
                txt_server_name:setPosition(cc.p(icon_server_status:getBoundingBox().x + icon_server_status:getBoundingBox().width + 5 , icon_server_status:getPositionY()))
                -- txt_server_name:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1,-1))
                cell:addChild(txt_server_name)
                if  data_item.level and tonumber(data_item.level)>0 then
                    herolevel= data_item.level
                    if data_item.templateId then
                        avatorid= data_item.templateId
                    end
                   
                    --头像框
                    local avatar_bg = cc.Sprite:create("res/image/homecity/city_player_iconBox.png")
                    avatar_bg:setAnchorPoint(1,0.5)
                    avatar_bg:setPosition(btn_left:getContentSize().width-45,btn_left:getContentSize().height/2 )
                    avatar_bg:setScale(0.4)
                    btn_left:addChild(avatar_bg)

                     --头像 herolevel    
                     local avator = cc.Sprite:create(zctech.getHeroAvatorImgById(avatorid))
                     avator:setPosition(avatar_bg:getContentSize().width/2,avatar_bg:getContentSize().height/2)
                      avator:setAnchorPoint(0.5,0.5)
                    --   avator:setScale(0.5)
                      avatar_bg:addChild(avator)
                    --
                    local level=getCommonWhiteBMFontLabel(herolevel)
                    level:setAnchorPoint(1,0)
                    level:setPosition(avator:getContentSize().width-5,-2)
                    avator:addChild(level)
                end
                
                local icon_new = XTHD.createSprite("res/image/login/server_new.png")
                icon_new:setAnchorPoint(cc.p(0,1.0))
                icon_new:setPosition(cc.p(x - (btn_left:getContentSize().width / 2) , y + (btn_left:getContentSize().height / 2)))
                cell:addChild(icon_new)
                icon_new:setVisible(false)

                if newState == 1 then
                    icon_new:setVisible(true)
                end

            end
        end

        return cell
    end

    self._taskTable:registerScriptHandler(self._taskTable.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._taskTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._taskTable:registerScriptHandler(self._taskTable.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    self._taskTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)

    self._initted = true
end
function ServerLayer1:ctor(params)

    self._initted = false
    -- reloadData(data)
	self:switchTab(params)
end

function ServerLayer1:switchTab(params)

    -- 首先检查玩家是否登录
    if gameUser.getToken() == "" then 
        XTHDTOAST("请登录，否则无法选择服务器")
        return
    end

    local tab               = params.tab
    local pageId            = params.pageId
    if pageId == nil or pageId < 1 then
        pageId = 1
    end
    local method = "recommendServer?token="
    if tab == 2 then
        method = "serverList?pageId="..pageId .. "&token="
    elseif tab == 3 then  --上次服务器
        XTHDHttp:requestAsyncWithParams({
        url = XTHD.config.server.url_uc.."serverList?pageId=1&token=" .. gameUser.getToken(),
        targetNeedsToRetain = self,--需要保存引用的目标
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                self.data_list  = data.list
                if gameUser.getLastServerId() == 0 then
                    self.data_list = nil
                else
                    self.data_list_temp = {}
                    for i = 1,#self.data_list do
                        if self.data_list[i].serverId == gameUser.getLastServerId() then
                            self.data_list_temp[1] = self.data_list[i]
                        end 
                    end 
                    self.data_list = self.data_list_temp
                end
                self.total_row = 1
                self._taskTable:reloadDataAndScrollToCurrentCell()
                return
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            return
        end,--失败回调
    }) 
    end
    XTHDHttp:requestAsyncWithParams({
        url = XTHD.config.server.url_uc..method .. gameUser.getToken(),
        targetNeedsToRetain = self,--需要保存引用的目标
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                --[[第一次初始化]]
                -- print("服务器返回的服务器列表数据为：")
                -- print_r(data)
                if self._initted == false then
                    self:initWithData(params)
                    self:show(true)
                end
                local list         = data.list
                table.sort(list, function( d1, d2 )
                    local _num1 = tonumber(d1.serverId) or 0
                    local _num2 = tonumber(d2.serverId) or 0
                    return _num1 > _num2
                end)
                self.data_list 	   = list
                local total_num    = #list

                self.total_row = total_num / PER_COUNT
                local tmp       = total_num % PER_COUNT
                if tmp > 0 then
                    self.total_row   = self.total_row + 1
                end
		        if self._taskTable then
                    self._lastSelectedServerButton = nil
		            self._taskTable:reloadDataAndScrollToCurrentCell()
		        end
            else
                XTHDTOAST(data.msg)
                if self._initted == false then
                    self:removeFromParent()
                end
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            if self._initted == false then
                self:removeFromParent()
            end
        end,--失败回调
    })
end

function ServerLayer1:createWithParams(params)
	return ServerLayer1.new(params)
end

return ServerLayer1