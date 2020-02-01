requires("src/fsgl/layer/DengLu/DengLuUtils.lua")
requires("src/fsgl/layer/ZhuCheng/BuildingItem1.lua")

local TAG = "DengLuLayer"
local MAX_ACCOUNT_COUNT = 3
local  DengLuLayer  = class( "DengLuLayer", function ( ... )
    return XTHDDialog:create()
end)

function DengLuLayer:onEnter( ... )
    local _saveKey = "active"
    local _key = cc.UserDefault:getInstance():getBoolForKey(_saveKey)
    if _key ~= true then
        cc.UserDefault:getInstance():setBoolForKey(_saveKey, true)
        XTHDADHttp.SendActive()
        -- print("wm---do active")
    else
        -- print("wm---have active")
    end
    local node = cc.Director:getInstance():getNotificationNode()
    if node then
        node:stopAllActions()
    end
    if not self._haveCleanedPast then
        self._haveCleanedPast = true
        helper.collectMemory(true)


        ---预加载出主城部分资源
        local textureCache = cc.Director:getInstance():getTextureCache()
        local pFileTb = {"res/image/homecity/cityworld_bg",1,"_",1,".png"}
        local pFileName = ""
        for j = 1, 5 do
            if j ~= 5 then
                for i = 1, 3 do
                    pFileTb[2] = i
                    pFileTb[4] = j
                    pFileName = table.concat(pFileTb)
                    textureCache:addImage(pFileName)
                end
            end
            pFileName = "res/image/homecity/cityworld_bg4_" .. j ..".png"
            textureCache:addImage(pFileName)
        end
        for i = 1, 9 do 
            if i ~= 7 and i ~= 8 then 
                BuildingItem1:create({buildingId = i})
            end
        end
    end
        --音乐和音效停止
    musicManager.stopMusic()
    musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_login,true)

    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        self:setKeypadEnabled(true)
        self:registerScriptKeypadHandler(function(callback)
            if callback == "backClicked" then
                print("返回按钮监听")
                if XTHD.isEmbeddedSdk() == true then
                    XTHD.gameBack()
                end
            elseif callback == "menuClicked" then
    --            print("菜单监听")
            end
        end)
    end
end

function DengLuLayer:InitUI()

--    local csbNode = cc.CSLoader:createNode("res/MainScene/MainScene.csb")
--    self:addChild(csbNode,30)
--    csbNode:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)

    self._isLoginUC = false
    print("_isLoginUC   false")

    local width = self:getContentSize().width
    local height = self:getContentSize().height
    
    local login_bg = requires("src/fsgl/layer/DengLuBeiJing/SwitchSceneBgLayer1.lua"):create()
    self:addChild(login_bg)

    local bg = XTHD.createSprite()
    bg:setContentSize(XTHD.resource.visibleSize)
    bg:setPosition(width/2, height/2)
    self:addChild(bg)

    width = bg:getContentSize().width
    height = bg:getContentSize().height
    
    local game_name = XTHD.createSprite("res/image/login/game_name.png")
    game_name:setPosition(width/2 , 400)
    bg:addChild(game_name)
    game_name:setVisible(false)

    local _btnSize = cc.size(200, 80)
    local btn_account = XTHDPushButton:createWithParams ({
        normalNode = cc.Sprite:create("res/image/login/id01_up.png"),
        selectedNode = cc.Sprite:create("res/image/login/id01_down.png"),
        needSwallow = true,
        enable = true,
        pos = cc.p((self:getContentSize().width - bg:getContentSize().width) / 2 + bg:getContentSize().width - _btnSize.width / 2 + 40,bg:getContentSize().height + (self:getContentSize().height - bg:getContentSize().height) / 2 - _btnSize.height / 2 - 15),
        endCallback = function()
            self:showLoginRect()
            print("zhanghaoguanli -------- showLoginRect()")
        end
    })
    btn_account:setScale(0.8)
    bg:addChild(btn_account)
    if self:getSDKFlag() then
        btn_account:setVisible(false)
    else
        btn_account:setVisible(true)
    end    
    
    local btn_gongao = XTHDPushButton:createWithParams ({
        normalNode = cc.Sprite:create("res/image/login/gonggao01_up.png"),
        selectedNode = cc.Sprite:create("res/image/login/gonggao01_down.png"),
        needSwallow = true,
        enable = true,
        endCallback = function()
			local str_url = XTHD.config.server.url_uc .. "versionNotice"
			XTHDHttp:requestAsyncWithParams( {
				url = str_url,
				isNotice = true,
				encrypt = HTTP_ENCRYPT_TYPE.NONE,
				method = HTTP_REQUEST_TYPE.GET,
				successCallback = function(data)
					if type(data) == "table" and data["result"] == 0 then
						local notice = requires("src/fsgl/layer/DengLu/GongGaoLayer.lua"):create(nil,data)
						self:addChild(notice)
						notice:show()
					else
						XTHDTOAST(data["msg"])
						--self:removeFromParent()
					end
				end,
				-- 成功回调
				failedCallback = function()
					XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
					--self:removeFromParent()
				end-- 失败回调
			} )

        end
    })
    btn_gongao:setPosition(btn_account:getPositionX(),btn_account:getPositionY() - btn_gongao:getContentSize().height)
    btn_gongao:setScale(0.8)
    bg:addChild(btn_gongao)

     --[[清除缓存  hezhitao began ]]
    local clear_btn = XTHD.createButton{
    normalFile = "res/image/login/huancun01_up.png",
    selectedFile = "res/image/login/huancun01_down.png",
    endCallback = function (  )
        self:tipsDialog()
    end}
    clear_btn:setAnchorPoint(0.5,0.5)
    clear_btn:setPosition(btn_account:getPositionX(),btn_account:getPositionY() - btn_gongao:getContentSize().height * 2)
    bg:addChild(clear_btn)
    clear_btn:setScale(0.8)

    -- local btn_account = XTHD.createCommonButton({
    --     btnColor = "blue",
    --     btnSize = _btnSize,
    --     fontSize = 22,
    --     text = "机械猪",
    --     pos = cc.p((self:getContentSize().width - bg:getContentSize().width) / 2 + bg:getContentSize().width - _btnSize.width / 2 - 10 - _btnSize.width - 10,bg:getContentSize().height + (self:getContentSize().height - bg:getContentSize().height) / 2 - _btnSize.height / 2 - 5),
    --     endCallback = function()
    --         requires("src/fsgl/layer/YinDaoJieMian/YinDaoFight1.lua"):create({id = 17, ectypeId = 1002})
    --     end
    -- })
    -- bg:addChild(btn_account)

    -- local btn_account = XTHD.createCommonButton({
    --     btnColor = "blue",
    --     btnSize = _btnSize,
    --     fontSize = 22,
    --     text = "变色龙",
    --     pos = cc.p((self:getContentSize().width - bg:getContentSize().width) / 2 + bg:getContentSize().width - _btnSize.width / 2 - 10 - _btnSize.width - 10 - _btnSize.width - 10,bg:getContentSize().height + (self:getContentSize().height - bg:getContentSize().height) / 2 - _btnSize.height / 2 - 5),
    --     endCallback = function()
    --         requires("src/fsgl/layer/YinDaoJieMian/YinDaoFight1.lua"):create({id = 37, ectypeId = 1001})
    --     end
    -- })
    -- bg:addChild(btn_account)

    -- local btn_account = XTHD.createCommonButton({
    --     btnColor = "blue",
    --     btnSize = _btnSize,
    --     fontSize = 22,
    --     text = "手动设置",
    --     pos = cc.p((self:getContentSize().width - bg:getContentSize().width) / 2 + bg:getContentSize().width - _btnSize.width / 2 - 10 - _btnSize.width - 10,bg:getContentSize().height + (self:getContentSize().height - bg:getContentSize().height) / 2 - _btnSize.height / 2 - 5),
    --     endCallback = function()
    --         local _node = XTHDDialog:create()
    --         self:addChild(_node, 100)
    --         _node:setTouchEndedCallback(function()
    --             _node:removeFromParent()
    --         end)
    --         local _size = _node:getContentSize()
    --         local _inputDi1 = XTHD.createSprite("res/image/login/login_input_bg.png")
    --         _inputDi1:setPosition(cc.p(_size.width/2 , _size.height/2 + 100))
    --         _node:addChild(_inputDi1)
            
    --         local editbox_ip = ccui.EditBox:create(cc.size(400,_inputDi1:getContentSize().height), ccui.Scale9Sprite:create(),nil,nil)
    --         editbox_ip:setFontColor(cc.c3b(255,255,255))
    --         editbox_ip:setPlaceHolder("输入ip")
    --         editbox_ip:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    --         editbox_ip:setAnchorPoint(0,0.5)
    --         editbox_ip:setMaxLength(30)
    --         editbox_ip:setPosition(10 , _inputDi1:getContentSize().height/2)
    --         editbox_ip:setPlaceholderFontColor(cc.c3b(200,187,165))
    --         editbox_ip:setFontName("Helvetica")
    --         editbox_ip:setPlaceholderFontName("Helvetica")
    --         editbox_ip:setFontSize(24)
    --         editbox_ip:setPlaceholderFontSize(24)
    --         editbox_ip:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    --         editbox_ip:setText(_name);
    --         _inputDi1:addChild(editbox_ip)

    --         local _inputDi2 = XTHD.createSprite("res/image/login/login_input_bg.png")
    --         _inputDi2:setPosition(cc.p(_inputDi1:getPositionX() , _inputDi1:getPositionY() - _inputDi1:getContentSize().height - 20))
    --         _node:addChild(_inputDi2)
            
    --         local editbox_port = ccui.EditBox:create(cc.size(400,_inputDi2:getContentSize().height), ccui.Scale9Sprite:create(),nil,nil)
    --         editbox_port:setFontColor(cc.c3b(255,255,255))
    --         editbox_port:setPlaceHolder("输入端口号")
    --         editbox_port:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    --         editbox_port:setAnchorPoint(0,0.5)
    --         editbox_port:setMaxLength(30)
    --         editbox_port:setPosition(10 , _inputDi2:getContentSize().height/2)
    --         editbox_port:setPlaceholderFontColor(cc.c3b(200,187,165))
    --         editbox_port:setFontName("Helvetica")
    --         editbox_port:setPlaceholderFontName("Helvetica")
    --         editbox_port:setFontSize(24)
    --         editbox_port:setPlaceholderFontSize(24)
    --         editbox_port:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    --         editbox_port:setText(_name);
    --         _inputDi2:addChild(editbox_port)

    --         local btn_go = XTHD.createCommonButton({
    --             btnColor = "blue",
    --             btnSize = _btnSize,
    --             fontSize = 22,
    --             text = "确定",
    --             pos = cc.p(_size.width/2 , _size.height/2 + 200),
    --             endCallback = function()
    --                 local _ip = editbox_ip:getText()
    --                 local _port = editbox_port:getText()
    --                 XTHD.config.server.url_uc = "http://" .. _ip .. ":" .. _port .. "/login/"
    --                 _node:removeFromParent()
    --                 XTHDTOAST("设置成功，请重新登录帐号！")
    --             end
    --         })
    --         _node:addChild(btn_go)
    --     end
    -- })
    -- bg:addChild(btn_account)

    local server_name_bg = XTHD.createSprite("res/image/login/login_server_name_bg.png")
    server_name_bg:setPosition(width/2 , 170)
    bg:addChild(server_name_bg)
	

    local icon_server_status = XTHD.createSprite("res/image/login/icon_server_status_ok.png")
    icon_server_status:setPosition(35, server_name_bg:getContentSize().height / 2 )
    server_name_bg:addChild(icon_server_status)
	icon_server_status:setScale(0.8)


    local txt_server_name = XTHDLabel:createWithParams({
        text = isLoginUC == false and LANGUAGE_TIPS_WORDS118 or gameUser.getServerName(),-------"上次选择的服务器",
        fontSize = 18,
        anchor = cc.p(0,0.5),
        color = XTHD.resource.color.orange_desc,
    })
    txt_server_name:setPosition(cc.p(icon_server_status:getBoundingBox().x + icon_server_status:getBoundingBox().width + 15 , icon_server_status:getPositionY()))
    txt_server_name:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1,-1))
    server_name_bg:addChild(txt_server_name)

    self._txt_server_name    = txt_server_name
    self._icon_server_status = icon_server_status
    --[[点击选服]]
    local btn_switch_server = XTHD.createButton({
        normalFile        = "res/image/login/btn_switch_server_normal.png", 
        selectedFile      = "res/image/login/btn_switch_server_selected.png",
        touchSize         = cc.size(145,50),
        pos = cc.p(370,txt_server_name:getPositionY()),
        endCallback = function()
            if gameUser.getToken() == nil  or gameUser.getToken() == "" or isLoginUC == false then
                self:showLoginRect()
                print("switch_server-------- showLoginRect()")
            end
            
            btn_account:setVisible(false)

            self:addChild(requires("src/fsgl/layer/FuWuQi/ServerLayer1.lua"):createWithParams({
                serverId = self._serverId,
                tab = 1,
                selectCallback = function(data_item)
                    self:saveSelectedServer(data_item)
                end,
                closeCallback = function()
                    if self:getSDKFlag() == true then
                        btn_account:setVisible(false)
                    else
                        btn_account:setVisible(true)
                    end
                    
                end
            }))
        end
    })
	btn_switch_server:setScale(0.8)
    server_name_bg:addChild(btn_switch_server)
    --[[进入游戏]]
    local btn_enter_game = XTHD.createButton({
        normalFile        = "res/image/login/startGame_up.png",
        selectedFile      = "res/image/login/startGame_down.png",
       -- text              = "开始游戏",
--        ttf               = "res/fonts/def.ttf",
--        fontSize          = 28,
        pos = cc.p(bg:getContentSize().width / 2,80),
        endCallback = function()
            -- if 1 then
            --     local imagePath = getShareImgFilePath()
            --     local args = {imagePath}
            --     local sigs = "(Ljava/lang/String;)V"
            --     performWithDelay(self, function ()
            --         XTHD.luaBridgeCall(LUA_BRIDGE_CLASS,"share",args,sigs)
            --     end, 0.3)
                
            --     return
            -- end

            if gameUser.getToken() == nil  or gameUser.getToken() == "" or isLoginUC == false then
                self:showLoginRect()
                print("gameUser.getToken()"..gameUser.getToken())

                if self._isLoginUC == false then
                    print("self._isLoginUC  false")
                else
                    print("self._isLoginUC  true")
                end
                
                print("enter_game-------- showLoginRect()")
                do return end
            end

            local flag = true

            xpcall(function() 
                local userDefault = cc.UserDefault:getInstance()
                local lastServer = userDefault:getStringForKey(KEY_NAME_LAST_SERVER)
                lastServer = loadstring(lastServer)
                if type(lastServer) == "function" then
                    lastServer = lastServer()
                else
                    lastServer = checktable(lastServer)
                end
                local openState     = lastServer.openState
                local openTime      = lastServer.openTime
                if openState == 2 then
                   XTHDTOAST(LANGUAGE_TIPS_WORDS119.."...")------服务器正在维护中...")
                   flag = false
                elseif openState == 0 then
                    self:addChild(XTHDConfirmDialog:createWithParams({msg = LANGUAGE_TIPS_WORDS120.."\n"..openTime,----------服务器即将开放，具体开放时间：\n"..openTime,
                        leftVisible = false
                        }))
                   flag = false
                end
            end,function() end)
            
            if flag == false then
                if not self:getSDKFlag() then
                    local _name , _password = ""
                    local accounts = self:getLastAccounts()
                    if accounts and #accounts > 0 then
                        _name = accounts[#accounts].username
                        _password = accounts[#accounts].password
                        self:loginUserCenter({},_name,_password)
                    end
                else
                    self:initSDKLoginUI()
                end
            else
                self._bg:setVisible(false)
                DengLuUtils.doNewLogin(self) 
            end
        end
    })
    -- btn_enter_game:getLabel():enableShadow(cc.c4b(45,13,103,255),cc.size(1,-1),500)
    --btn_enter_game:getLabel():enableOutline(cc.c4b(45,13,103,255),2)
    btn_enter_game:setScale(0.9)
    bg:addChild(btn_enter_game)
	
	local kaishiyouxi = cc.Sprite:create("res/image/login/kaishiyouxi.png")
	btn_enter_game:addChild(kaishiyouxi)
	kaishiyouxi:setScale(0.8)
	kaishiyouxi:setPosition(btn_enter_game:getContentSize().width *0.5,btn_enter_game:getContentSize().height *0.5 - 5)

    self._bg = bg

	local text = ""

    --[[清除缓存  hezhitao began ]]
    -- local clear_btn = XTHD.createButton{
    -- normalFile = "res/image/update/game_remove_cache.png",
    -- selectedFile = "res/image/update/game_remove_cache.png",
    -- endCallback = function (  )
    --     self:tipsDialog()
    -- end}
    -- clear_btn:setPosition(self:getContentSize().width - 50,100)
    -- self:addChild(clear_btn)
    -- clear_btn:setScale(0.6)
    --当前版本号
    local function parseManifest()
        local file = nil
        local table = nil

        if cc.FileUtils:getInstance():isFileExist(XTHD.resource.getWritablePath() .. "project.manifest") then
            file = cc.FileUtils:getInstance():getStringFromFile(XTHD.resource.getWritablePath() .. "project.manifest")
        else
            file = cc.FileUtils:getInstance():getStringFromFile("src/project.manifest")
        end

        if file ~= nil then
            table = json.decode(file)
        end
        return table
    end

    local manifest_tab = parseManifest()
    local version = manifest_tab["version"].."."..manifest_tab["svn"] or ""
    self._debug_ = 0
    local versionId = XTHDLabel:createWithParams({
        text = "版本号" .. version,
        fontSize = 24,
        color = cc.c3b(255, 255, 255),
        endCallback = function()
            self._debug_ = self._debug_ + 1
            if self._debug_ >= 5 and cc.Director:getInstance():isDisplayStats() == false then
                cc.Director:getInstance():setDisplayStats(true)
            elseif cc.Director:getInstance():isDisplayStats() == true then
                cc.Director:getInstance():setDisplayStats(false)
                self._debug_ = 0
            end
        end
    })
    versionId:setAnchorPoint(cc.p(0, 0))
    versionId:setPosition(cc.p(45, self:getContentSize().height-versionId:getContentSize().height - 10))
    self:addChild(versionId)
    -- 背景框
    local rect = XTHD.createSprite("res/image/login/login_rect_bg.png")
    rect:setPosition(cc.p(cc.Director:getInstance():getWinSize().width / 2 , cc.Director:getInstance():getWinSize().height / 2))
    self:addChild(rect)
    rect:setScale(0.8)
    --  --另外一个
    --  local rect_bg = cc.Sprite:create("res/image/login/rect_bg.png")
    --  rect_bg:setPosition(rect:getContentSize().width/2,rect:getContentSize().height/2+40)
    --  rect:addChild(rect_bg)
    --  -- rect_bg:setScale(0.8)
    --  --账号登陆板子
    --  local zhanghaodenglu = cc.Sprite:create("res/image/login/zhanghaodenglu.png")
    --  zhanghaodenglu:setPosition(rect:getContentSize().width/2,rect:getContentSize().height+zhanghaodenglu:getContentSize().height/2-40)
    --  rect:addChild(zhanghaodenglu)
    --  --账号登陆文字
    --  local zhanghao = XTHDLabel:create("账号登陆",28)
    --  zhanghao:setPosition(zhanghaodenglu:getContentSize().width/2,zhanghaodenglu:getContentSize().height/2)
    --  zhanghaodenglu:addChild(zhanghao)
    rect:setVisible(false)
    self._rect = rect
    

    if string.isEmpty(gameUser.getToken()) == true and not self:getSDKFlag() then
        local _name , _password = ""
        local accounts = self:getLastAccounts()
        if accounts and #accounts > 0 then
            print("自动登录")
            _name = accounts[#accounts].username
            _password = accounts[#accounts].password
            self:loginUserCenter({}, _name, _password)
        end
    elseif isLoginFlag == false and self:getSDKFlag()  then
        self:showLoginRect()
        print("InitUI zidong denglu-------- showLoginRect()")
    end

    --如果退出游戏框已经存在，则不在添加退出游戏框，
    self._exit_flag = false

    --响应android 返回事件
    --[[ 
    local function onrelease(code, event)
        if code == cc.KeyCode.KEY_BACK then
            if self._exit_flag == false then
                --self:showLogoutDialog()            
            end
        elseif code == cc.KeyCode.KEY_HOME then
            
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onrelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    ]]--
    --self:runAction(cc.Sequence:create( cc.DelayTime:create(0.2),cc.CallFunc:create(function (  )
    --    self:initSDKLoginUI()
    --end) ))
end

function DengLuLayer:showLogoutDialog( )
    self._exit_flag = true
    local show_msg = LANGUAGE_TIPS_WORDS121-------"你确定要退出游戏么？"
    local confirmDialog = XTHDConfirmDialog:createWithParams({msg = show_msg})
    self:addChild(confirmDialog)

    confirmDialog:setCallbackRight(function (  )
        XTHD.gameExit()
    end)

    confirmDialog:setCallbackLeft(function (  )
        confirmDialog:removeFromParent()
        self._exit_flag = false
    end)
end

function DengLuLayer:showLoading( )
    self._bg:setVisible(false)
end
--[[显示登录框]]
function DengLuLayer:showLoginRect()

    if self:getSDKFlag() == true and isLoginFlag == true then
        self._bg:setVisible(true)
        return
    elseif self:getSDKFlag() == true and isLoginFlag == false then
        self._bg:setVisible(true)
        self:initSDKLoginUI()
        return
    end

    local bg = self._bg
    bg:setVisible(false)
    local rect = self._rect
    rect:removeAllChildren()
    rect:initWithFile("res/image/login/login_rect_bg.png")
    --另外一个
    local rect_bg = cc.Sprite:create("res/image/login/rect_bg.png")
    rect_bg:setPosition(rect:getContentSize().width/2,rect:getContentSize().height/2+40)
    rect:addChild(rect_bg)
    self.rect_bg = rect_bg
    rect_bg:setScaleY(1.2)
    --账号登陆板子
    local zhanghaodenglu = cc.Sprite:create("res/image/login/zhanghaodenglu.png")
    zhanghaodenglu:setPosition(rect:getContentSize().width/2,rect:getContentSize().height+zhanghaodenglu:getContentSize().height/2-40)
    rect:addChild(zhanghaodenglu)
    self.zhanghaodenglu_bg = zhanghaodenglu
    --账号登陆文字
    local zhanghao = XTHDLabel:create("账号登陆",32,"res/fonts/def.ttf")
    zhanghao:setPosition(zhanghaodenglu:getContentSize().width/2,zhanghaodenglu:getContentSize().height/2)
    zhanghao:enableOutline(cc.c4b(120,50,9,255),1)
    zhanghao:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1),10)
    zhanghaodenglu:addChild(zhanghao)

    rect:setVisible(true)


    local input_bg_account_sp = cc.Sprite:create("res/image/login/login_input_02.png")
    input_bg_account_sp:setPosition(cc.p(100 , rect:getContentSize().height-120-20))
    rect:addChild(input_bg_account_sp)

    local input_bg_account = XTHD.createSprite("res/image/login/login_input_bg.png")
    input_bg_account:setPosition(cc.p(rect:getContentSize().width / 2 +15, input_bg_account_sp:getPositionY()))
    -- input_bg_account:setScaleX(0.9)
    rect:addChild(input_bg_account)

    local input_bg_pwd_sp = cc.Sprite:create("res/image/login/login_input_03.png")
    input_bg_pwd_sp:setPosition(cc.p(100 , input_bg_account:getPositionY()-90-20))
    rect:addChild(input_bg_pwd_sp)

    local input_bg_pwd = XTHD.createSprite("res/image/login/login_input_bg.png")
    input_bg_pwd:setPosition(cc.p(rect:getContentSize().width / 2+15 , input_bg_pwd_sp:getPositionY()))
    -- input_bg_pwd:setScaleX(0.9)
    rect:addChild(input_bg_pwd)

    local input_bg_phone_sp = cc.Sprite:create("res/image/login/login_input_04.png")
    input_bg_phone_sp:setPosition(cc.p(100 , input_bg_account:getPositionY()-90-20))
    rect:addChild(input_bg_phone_sp)

    local input_bg_phone = XTHD.createSprite("res/image/login/login_input_bg.png")
    input_bg_phone:setPosition(cc.p(rect:getContentSize().width / 2 +15, input_bg_phone_sp:getPositionY()))
    -- input_bg_phone:setScaleX(0.9)
    rect:addChild(input_bg_phone)

     
    local _name , _password = ""
    local accounts = self:getLastAccounts()
    -- dump(accounts, "最新帐号")
    if accounts and #accounts > 0 then
        _name = accounts[#accounts].username
        _password = accounts[#accounts].password
    end

    local editbox_account = ccui.EditBox:create(cc.size(250,input_bg_account:getContentSize().height), ccui.Scale9Sprite:create(),nil,nil)
    editbox_account:setFontColor(cc.c3b(255,255,255))
    editbox_account:setPlaceHolder(LANGUAGE_KEY_ENTER_ACCOUNT)
    editbox_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    editbox_account:setAnchorPoint(0,0.5)
    editbox_account:setMaxLength(30)
    editbox_account:setPosition(10 , input_bg_account:getContentSize().height/2)
    editbox_account:setPlaceholderFontColor(cc.c3b(255,255,255))
    editbox_account:setFontName("Helvetica")
    editbox_account:setPlaceholderFontName("Helvetica")
    editbox_account:setFontSize(20)
    editbox_account:setPlaceholderFontSize(20)
    editbox_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editbox_account:setText(_name);
    input_bg_account:addChild(editbox_account)

    local editbox_pwd = ccui.EditBox:create(cc.size(280,input_bg_account:getContentSize().height), ccui.Scale9Sprite:create(),nil,nil)
    editbox_pwd:setFontColor(cc.c3b(255,255,255))
    editbox_pwd:setPlaceHolder(LANGUAGE_KEY_ENTER_PWD)
    editbox_pwd:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    editbox_pwd:setAnchorPoint(0,0.5)
    editbox_pwd:setMaxLength(30)
    editbox_pwd:setPosition(10 , input_bg_pwd:getContentSize().height/2)
    editbox_pwd:setPlaceholderFontColor(cc.c3b(255,255,255))
    editbox_pwd:setFontName("Helvetica")
    editbox_pwd:setPlaceholderFontName("Helvetica")
    editbox_pwd:setFontSize(20)
    editbox_pwd:setPlaceholderFontSize(16)
    editbox_pwd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editbox_pwd:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editbox_pwd:setText(_password);
    input_bg_pwd:addChild(editbox_pwd)



    local editbox_phone = ccui.EditBox:create(cc.size(280,input_bg_account:getContentSize().height), ccui.Scale9Sprite:create(),nil,nil)
    editbox_phone:setFontColor(cc.c3b(255,255,255))
    editbox_phone:setPlaceHolder(LANGUAGE_INPUTTIPS2)------"请再次输入密码")
    editbox_phone:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    editbox_phone:setAnchorPoint(0,0.5)
    editbox_phone:setMaxLength(30)
    editbox_phone:setPosition(10, input_bg_phone:getContentSize().height/2)
    editbox_phone:setPlaceholderFontColor(cc.c3b(255,255,255))
    editbox_phone:setFontName("Helvetica")
    editbox_phone:setPlaceholderFontName("Helvetica")
    editbox_phone:setFontSize(20)
    editbox_phone:setPlaceholderFontSize(20)
    editbox_phone:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editbox_phone:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editbox_phone:setText(_password);
    input_bg_phone:addChild(editbox_phone)

    local btn_fast_register = XTHD.createCommonButton({
        btnColor = "write_1",
        isScrollView = false,
        fontSize = 24,
        text = LANGUAGE_BTN_KEY.kuaisuzhuce,
        btnSize = cc.size(200, 80),
        pos = cc.p(rect:getContentSize().width / 2-110, 80)
    })
    btn_fast_register:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
    btn_fast_register:setScale(0.8)
    rect:addChild(btn_fast_register)
    
    local function _getNameAndPassWord()
        local username = editbox_account:getText()
        local password = editbox_pwd:getText()
        local mobile = editbox_phone:getText()
        if string.len(username) ==0 or username == "" then
            username= ""
        end
        if string.len(password) ==0 or password == "" then
            password= ""
        end
        string.gsub(username, " ", "")
        string.gsub(password, " ", "")
        string.gsub(mobile, " ", "")
        return username, password,mobile;
    end

    --设置获取道具
    local _ItemData_ = {}
    _ItemData_.count = 20
    _ItemData_.minIdx = 110011
    _ItemData_.maxIdx = 110011
    --放开注释可以获取道具
    -- _ItemData_.isGetItem = true

    --self:changeUrl("http://192.168.11.210:8080/game/petAction.do?method=allPet"),
    local function getItemData(idx)
        ClientHttp:requestAsyncInGameWithParams({
            modules = "giveItem?",
            params = {count=_ItemData_.count,itemId=idx},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
            successCallback = function(data)
            if tonumber(data.result) == 0 then
                if idx <= tonumber(_ItemData_.maxIdx) then
                    getItemData(idx+1)
                end
            else
                XTHDTOAST(data.msg)
            end
            end,--成功回调
            failedCallback = function()
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end
    
     --[[登录游戏]]
    local btn_login_game = XTHD.createCommonButton({
        text = LANGUAGE_BTN_KEY.querendenglu,
        isScrollView = false,
        btnColor = "write",
        fontSize = 24,
        btnSize = cc.size(200, 80),
        pos = cc.p(rect:getContentSize().width / 2+110,80),
        endCallback = function()
            local username, password = _getNameAndPassWord();
            -- 对帐号名密码进行删除空格处理
            username = string.gsub( username, " ", "")
            password = string.gsub( password, " ", "")
            self:loginUserCenter({},username,password)
        end
    })
    btn_login_game:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
    
    btn_login_game:setScale(0.8)
    rect:addChild(btn_login_game)
    
    btn_login_game:setVisible(false)
    btn_fast_register:setVisible(false)
    local btn_back =  XTHD.createCommonButton({
        btnColor = "write_1",
        isScrollView = false,
        fontSize = 22,
        text = LANGUAGE_BTN_KEY.fanhuishangyibu,
        btnSize = cc.size(200, 80),
        pos = cc.p(rect:getContentSize().width / 2-110,85),
    })
    btn_back:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
    -- btn_back:setScale(0.7)
    rect:addChild(btn_back)

    --qq登陆按钮
    local qq_btn =  XTHD.createButton({
        normalFile        = "res/image/login/qqdl.png", 
        selectedFile      = "res/image/login/qqdl.png",
        --fontSize = 26,
        --text = "QQ登陆",
        --ttf = "res/fonts/def.ttf",
        pos = cc.p(rect:getContentSize().width / 2+110,-30),
        endCallback = function()
            print("qq登陆")
            local sigs = "(I)V"
            XTHD.luaBridgeCall(LUA_BRIDGE_CLASS,"login",args,sigs)
        end
    })
    --qq_btn:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
    ---local qq_logo = cc.Sprite:create("res/image/login/qqbtn.png")
    --qq_logo:setPosition(45,qq_btn:getContentSize().height/2+5)
    --qq_btn:getLabel():setPositionX(qq_btn:getLabel():getPositionX()+35)
    --qq_btn:addChild(qq_logo)
    qq_btn:setScale(0.7)
    rect:addChild(qq_btn)

    --微信登陆按钮
    local wx_btn =  XTHD.createButton({
        normalFile        = "res/image/login/wxdl.png", 
        selectedFile      = "res/image/login/wxdl.png",
        --text = "微信登陆",
        --fontSize = 26,
        --ttf = "res/fonts/def.ttf",
        pos = cc.p(rect:getContentSize().width / 2-110,-30),
        endCallback = function()
           print("微信登录")
        end
    })
    --wx_btn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
    --local wx_logo = cc.Sprite:create("res/image/login/wxbtn.png")
    --wx_logo:setPosition(40,wx_btn:getContentSize().height/2+5)
    --wx_btn:addChild(wx_logo)
    --wx_btn:getLabel():setPositionX(wx_btn:getLabel():getPositionX()+35)
    wx_btn:setScale(0.7)
    rect:addChild(wx_btn)


    local btn_register =  XTHD.createCommonButton({
        btnColor = "write",
        isScrollView = false,
        text = LANGUAGE_BTN_KEY.wanchengzhuce,
        fontSize = 22,
        btnSize = cc.size(200, 80),
        pos = cc.p(rect:getContentSize().width / 2+110,85),
        endCallback = function()
            local username, password, mobile = _getNameAndPassWord();
            if username~="" and password~="" and mobile~="" and  password== mobile then
                XTHDHttp:requestAsyncWithParams({
                    url = XTHD.config.server.url_uc.."register?userName="..string.urlencode(username).."&password="..string.urlencode(password).."&mobile="..string.urlencode(mobile),
                    encrypt = HTTP_ENCRYPT_TYPE.NONE,
                    successCallback = function(data)
                        if tonumber(data.result) == 0 then
                            local serverSum         = data.serverSum
                            local lastServerId      = data.lastServerId
                            local token             = data.token
                            local serverId          = data.serverId
                            local serverName        = getServerName(serverId, data.serverName)
                            local openState         = data.openState--[[1开启,0即将开启,2维护中]]
                            local openTime          = data.openTime
                            local crowdState        = data.crowdState--[[4爆满,3拥挤,2顺畅]]
                            local newState          = data.newState--[[是否新服,1新服]]
                            local recommend         = data.recommend--[[是否推荐,1推荐]]

                            editbox_account:setText(username)
                            editbox_pwd:setText(password)

                            self:saveAccount(username,password)
                            self:saveSelectedServer(data)
                           
                            gameUser.setToken(token)
                            gameUser.setNewLoginToken(token)
                            gameUser.setLastaServerId(lastServerId)
                            self._txt_server_name:setString(serverName)
                            self._icon_server_status:initWithFile(XTHD.resource.getServerStatusImgPath(crowdState))
                            self._icon_server_status:setAnchorPoint(cc.p(0,0.5))
                            self._rect:setVisible(false)
                            bg:setVisible(true)
                            self._isLoginUC = true
                            isLoginUC = true
							--self:showPlayerNamePopLayer()
							self:showNoticeDialog()
                        else
                            XTHDTOAST(data.msg)
                        end
                    end,--成功回调
                    failedCallback = function()
                        XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                    end,--失败回调
                    targetNeedsToRetain = self,--需要保存引用的目标
                    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                })
            else
                if username=="" then
                    XTHDTOAST(LANGUAGE_INPUTTIPS3)-----"请输入帐号！")
                -- end
                elseif password=="" then
                    XTHDTOAST(LANGUAGE_INPUTTIPS4)------"请输入密码！")
                -- end
                elseif mobile==""then
                    XTHDTOAST(LANGUAGE_INPUTTIPS2)--------"请再次输入密码！")
                elseif password ~= mobile then
                    XTHDTOAST(LANGUAGE_INPUTTIPS5)-----"两次密码输入不一致！")
                end
               
            end
        end
    })
    --描边
    btn_register:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
    -- btn_register:setScale(0.7)
    rect:addChild(btn_register)
    local more_bg =ccui.Scale9Sprite:create("res/image/login/btn_more_bg.png")
    more_bg:setContentSize(cc.size(380,155+15+5))
    more_bg:setPosition(cc.p(rect:getBoundingBox().width / 2+80 , rect:getBoundingBox().height / 2+50-20))
    rect:addChild(more_bg)
    local node =ccui.Scale9Sprite:create(cc.rect(10,10,1,1),"res/image/login/btn_more_bg.png")
    node:setContentSize(cc.size(452+15,155+15+5))
    local more_account_bg=XTHDPushButton:createWithParams({
        -- normalNode=node,
        -- selectedNode=node,
        touchSize         = cc.size(452+15,155+15+5),
        })
    more_account_bg:setTouchEndedCallback(function() 
        more_account_bg:removeAllChildren()
        -- more_account_bg:getStateNormal():removeAllChildren()
        more_account_bg:setVisible(false)
        more_bg:setVisible(false)
        btn_fast_register:setVisible(true)
        btn_login_game:setVisible(true)
    end)
   
    more_account_bg:setPosition(more_bg:getContentSize().width/2,more_bg:getContentSize().height/2)
    more_bg:addChild(more_account_bg)
    more_bg:setVisible(false)
    more_account_bg:setVisible(false)
    -- local node=cc.Sprite:create("res/image/login/btn_more_selected.png")
    -- node:setFlipY(true)
    local btn_more = XTHD.createButton({
        normalFile        = "res/image/login/btn_more_selected.png", 
        selectedFile      = "res/image/login/btn_more_normal.png",
        pos = cc.p(487-120+90+50, input_bg_account:getPositionY()),
        touchSize         = cc.size(80,80),
        endCallback = function()
            if more_account_bg:isVisible() == true then
                -- XTHDPushButton:getStateNormal()
                 more_account_bg:removeAllChildren()
                 more_account_bg:setVisible(false)
                 more_bg:setVisible(false)
                btn_fast_register:setVisible(true)
                btn_login_game:setVisible(true)
            else    
                local accounts = self:getLastAccounts()
                if accounts ~= nil and #accounts > 0 then
                    if #accounts > 3 then
                        btn_fast_register:setVisible(false)
                        btn_login_game:setVisible(false)
                    end
                    more_account_bg:setVisible(true)
                    more_bg:setVisible(true)

                    for i = 1 , #accounts do
                        local username = accounts[#accounts - (i - 1)].username
                        local password = accounts[#accounts - (i - 1)].password
               
                         bg_account = XTHDPushButton:createWithFile()--456,45
                         bg_account:setContentSize(456,45)
                        --  bg_account:setScaleX(0.8)
                        --  bg_account:setScaleY(0.4)
                        local diff = input_bg_account:getBoundingBox().height + 4
                        bg_account:setAnchorPoint(cc.p(0.5,1.0))
                        -- bg_account:setPosition(cc.p(more_account_bg:getContentSize().width / 2 , input_bg_account:getBoundingBox().y - (i - 1) * input_bg_account:getBoundingBox().height - 4 * i))
                        bg_account:setPosition(cc.p(more_account_bg:getContentSize().width / 2 , more_account_bg:getContentSize().height+90 - (i - 1) * input_bg_account:getBoundingBox().height - 4 * i-5))
                        if i == 2 or i == 3 then
                        --line
                            local line = ccui.Scale9Sprite:create("res/image/ranklistreward/splitX.png")
                            line:setContentSize(360,2)
                            line:setPosition(cc.p(more_account_bg:getContentSize().width / 2 , bg_account:getPositionY()-5))
                            line:setAnchorPoint(0.5,0.5)
                            more_account_bg:addChild(line)
                        end

                        more_account_bg:addChild(bg_account)
                        local txt = XTHD.createLabel({text = username,
                            color = cc.c3b(70,34,34),
                            anchor = cc.p(0,0.5),
                            fontSize = 32,
                            pos = cc.p(88 , bg_account:getBoundingBox().height / 2-10)})
                        bg_account:addChild(txt)

                        bg_account:setTouchEndedCallback(function()
                            editbox_account:setText(username)
                            editbox_pwd:setText(password)
                            
                            more_account_bg:removeAllChildren()
                            more_account_bg:setVisible(false)
                            more_bg:setVisible(false)
                            btn_fast_register:setVisible(true)
                            btn_login_game:setVisible(true)
                        end)
                    end

                end

            end
        end
    })
    rect:addChild(btn_more)

--注册板子
    local function showReg()
        btn_register:setVisible(true)
        -- txt_phone:setVisible(true)
        input_bg_phone:setVisible(true)
        input_bg_phone_sp:setVisible(true)
        btn_back:setVisible(true)
        editbox_phone:setVisible(true)
        
        btn_login_game:setVisible(false)
        btn_fast_register:setVisible(false)
        btn_more:setVisible(false)
        -- txt_title:setString("帐号注册")
        rect:initWithFile("res/image/login/login_rect_bg.png")
        --ly
        self.zhanghaodenglu_bg:setVisible(false)
        self.rect_bg:setPosition(rect:getContentSize().width/2,rect:getContentSize().height/2+50)
        
        --用户名注册
        local yh_zhuce = XTHD.createButton({
        normalFile        = "res/image/login/zhuce_sele.png", 
        selectedFile      = "res/image/login/zhuce_normal.png",
        -- touchSize         = cc.size(145,50),
        text              = "用户名注册",
        fontSize          = 24,
        anchor            = cc.p(0,0),
        pos               = cc.p(20,self.rect_bg:getContentSize().height),
        ttf               = "res/fonts/def.ttf"
        })
        yh_zhuce:getLabel():enableOutline(cc.c4b(120,50,9,255),2)
        yh_zhuce:getLabel():setPosition(yh_zhuce:getContentSize().width/2,yh_zhuce:getContentSize().height/2-5)
        self.rect_bg:addChild(yh_zhuce)
        yh_zhuce:setSelected(true)
        --手机号注册
        local sjh_zhuce = XTHD.createButton({
            normalFile        = "res/image/login/zhuce_sele.png", 
        selectedFile      = "res/image/login/zhuce_normal.png",
        -- touchSize         = cc.size(145,50),
        text              = "手机号注册",
        fontSize          = 24,
        anchor            = cc.p(0,0),
        pos               = cc.p(yh_zhuce:getPositionX()+yh_zhuce:getContentSize().width+10,self.rect_bg:getContentSize().height),
        ttf               = "res/fonts/def.ttf"
        })
        sjh_zhuce:getLabel():enableOutline(cc.c4b(120,50,9,255),2)
        sjh_zhuce:getLabel():setPosition(sjh_zhuce:getContentSize().width/2,sjh_zhuce:getContentSize().height/2-5)
        self.rect_bg:addChild(sjh_zhuce)
        yh_zhuce:setTouchEndedCallback(function()
            editbox_account:setPlaceHolder("账号（6-20位英文，数字）")
            yh_zhuce:setSelected(true)
            sjh_zhuce:setSelected(false)
        end)
        sjh_zhuce:setTouchEndedCallback(function()
            editbox_account:setPlaceHolder("请输入手机号")
            sjh_zhuce:setSelected(true)
            yh_zhuce:setSelected(false)
        end)

        

        editbox_account:setPlaceHolder("账号（6-20位英文，数字）")
         input_bg_account_sp:setPosition(cc.p(100 , rect:getContentSize().height-120+10))
         input_bg_account:setPosition(cc.p(rect:getContentSize().width / 2 , input_bg_account_sp:getPositionY()))

         input_bg_pwd_sp:setPosition(cc.p(100 , input_bg_account:getPositionY()-90+10))
         input_bg_pwd:setPosition(cc.p(rect:getContentSize().width / 2 , input_bg_pwd_sp:getPositionY()))
         input_bg_phone_sp:setPosition(cc.p(100 , input_bg_pwd:getPositionY()-90+10))
         input_bg_phone:setPosition(cc.p(rect:getContentSize().width / 2 , input_bg_phone_sp:getPositionY()))
        editbox_account:setText(nil)
        editbox_pwd:setText(nil)
        editbox_phone:setText(nil)
    end
  
    local function showLogin()
        self.zhanghaodenglu_bg:setVisible(true)
        self.rect_bg:setPosition(rect:getContentSize().width/2,rect:getContentSize().height/2+40)
        self.rect_bg:removeAllChildren()
        btn_register:setVisible(false)
        -- txt_phone:setVisible(false)
        input_bg_phone:setVisible(false)
        input_bg_phone_sp:setVisible(false)
        btn_back:setVisible(false)
        editbox_phone:setVisible(false)
        btn_login_game:setVisible(true)
        btn_fast_register:setVisible(true)
        btn_more:setVisible(true)
        -- txt_title:setString("帐号登录")
         rect:initWithFile("res/image/login/login_rect_bg.png")
         input_bg_account_sp:setPosition(cc.p(100 , rect:getContentSize().height-120-20))
         input_bg_account:setPosition(cc.p(rect:getContentSize().width / 2+15 , input_bg_account_sp:getPositionY()))
         input_bg_pwd_sp:setPosition(cc.p(100 , input_bg_account:getPositionY()-90-20))
         input_bg_pwd:setPosition(cc.p(rect:getContentSize().width / 2+15 , input_bg_pwd_sp:getPositionY()))
         input_bg_phone_sp:setPosition(cc.p(100 , input_bg_pwd:getPositionY()-90))
         input_bg_phone:setPosition(cc.p(rect:getContentSize().width / 2+15 , input_bg_phone_sp:getPositionY()))
        
        
        editbox_account:setText(_name)
        editbox_pwd:setText(_password)
    end

    btn_back:setTouchEndedCallback(function()
        showLogin()
    end)
    
    btn_fast_register:setTouchEndedCallback(function() 
        showReg()
        -- for i=1,2 do
        --     announce:setString("")
        -- end
        more_bg:setVisible(false)
    end)    
    showLogin()
    --[[如果输入帐号的时候，不需要显示下方的内容]]
    bg:setVisible(false)

end

function DengLuLayer:loginUserCenter(params, username, password)
    if(GAME_CHANNEL == CHANNEL.Android.CHANNEL_CODE_Define and (username == "" or password == "")) then
        XTHDTOAST(LANGUAGE_TIPS_WORDS284)
        return
    end
    local user_data = params.data
    local server_url = XTHD.config.server.url_uc
    local url = ""

    print("DengLuLayer:loginUserCenter():    server_url:"..server_url.."   game_channel:"..GAME_CHANNEL)

    if (cc.PLATFORM_OS_ANDROID == ZC_targetPlatform) then
        if GAME_CHANNEL == CHANNEL.Android.CHANNEL_CODE_Define then
            url = server_url.."login?userName="..tostring(username).."&password="..tostring(password)
        elseif GAME_CHANNEL == CHANNEL.Android.CHANNEL_CODE_XT then
            --[[--android传过来的是字符串，所以需要转换一下]]
            user_data =  json.decode(user_data)
            local tmp_sign = user_data["sign"]
            local tmp_time = user_data["logintime"]
            local tmp_name = user_data["username"]
            -- url = server_url.."login?userName="..tmp_name.."&password="..tostring("").."&logintime="..tmp_time.."&sign="..tmp_sign.."&appkey="..GAME_APPKEY
            url = server_url.."login?userName="..tmp_name.."&password="..tostring("").."&logintime="..tmp_time.."&sign="..tmp_sign
        elseif GAME_CHANNEL == CHANNEL.Android.CHANNEL_CODE_XM then
            --[[--android传过来的是字符串，所以需要转换一下]]
            user_data =  json.decode(user_data)
            local tmp_uid = user_data["uid"]
            local tmp_session = user_data["session"]
            url = server_url.."login?userName="..tmp_uid.."&password="..tmp_session
        elseif GAME_CHANNEL == CHANNEL.Android.CHANNEL_CODE_360 then
            --[[--android传过来的是字符串，所以需要转换一下]]
            user_data =  json.decode(user_data)
            local tmp_token = user_data["token"]
            local tmp_scope = user_data["scope"]
            url = server_url.."login?userName="..tmp_token.."&password="..tmp_scope
        elseif GAME_CHANNEL == CHANNEL.Android.CHANNEL_CODE_BD then
            user_data = json.decode(user_data)
            url = server_url.."login?userName="..tostring(user_data.token).."&password="
        elseif GAME_CHANNEL == CHANNEL.Android.CHANNEL_CODE_HW then
            --[[--android传过来的是字符串，所以需要转换一下]]
            user_data =  json.decode(user_data)
            local token = user_data["token"]
            url = server_url.."login?userName="..token.."&password="..tostring("")
        elseif GAME_CHANNEL == CHANNEL.Android.CHANNEL_CODE_JW then
            user_data =  json.decode(user_data)
            local userid = user_data["userId"]
            local userName = user_data["username"]
            local tmptoken = user_data["token"]
            local channelcode = user_data["channelcode"]
            url = server_url.."login?userName="..username.."&password="..tostring("").."&uid="..userid.."&token="..tmptoken.."&channel_code="..channelcode
        elseif GAME_CHANNEL == CHANNEL.Android.CHANNEL_CODE_FB then
            user_data =  json.decode(user_data)
            local userid = user_data["id"]
            local userName = user_data["name"]
            local tmptoken = user_data["token"]
            local channelcode = user_data["channelcode"]
            url = server_url.."login?userName="..username.."&password="..tostring("").."&uid="..userid.."&token="..tmptoken
        elseif GAME_CHANNEL == CHANNEL.Android.CHANNEL_CODE_SY then
            user_data =  json.decode(user_data)
            gameUser.setSYLoginData(user_data)
            print("---------SDK返回的登录数据为：----------")
            print_r(user_data)
            local sid = user_data["sid"]
            local uid = user_data["uid"]
            local channenid = user_data["channelid"]
            local version = user_data["version"]
            local ext = user_data["ext"]
            url = server_url.."login?userName="..tostring("cc").."&password="..tostring("").."&channelId="..string.urlencode(channenid).."&userId="..uid.."&sid="..string.urlencode(sid).."&ext="..string.urlencode(ext).."&version="..string.urlencode(version)
        end
    elseif (cc.PLATFORM_OS_IPHONE == ZC_targetPlatform) or (cc.PLATFORM_OS_IPAD == ZC_targetPlatform) or (cc.PLATFORM_OS_MAC == ZC_targetPlatform) then
         if GAME_CHANNEL == CHANNEL.IOS.CHANNEL_CODE_Define then
                url = server_url.."login?userName="..tostring(username).."&password="..tostring(password)
            end
        if user_data ~= nil then
            if GAME_CHANNEL == CHANNEL.IOS.CHANNEL_CODE_XT then
                local tmp_sign = user_data["sign"]
                local tmp_time = user_data["logintime"]
                local tmp_name = user_data["username"]
                url = server_url.."login?userName="..tmp_name.."&password="..tostring("").."&logintime="..tmp_time.."&sign="..tmp_sign.."&appkey="..GAME_APPKEY
            elseif GAME_CHANNEL == CHANNEL.IOS.CHANNEL_CODE_XM then
                local tmp_uid = user_data["uid"]
                local tmp_session = user_data["session"]
                url = server_url.."login?userName="..tmp_uid.."&password="..tmp_session
            elseif GAME_CHANNEL == CHANNEL.IOS.CHANNEL_CODE_360 then
                local tmp_token = user_data["token"]
                local tmp_scope = user_data["scope"]
                url = server_url.."login?userName="..tmp_token.."&password="..tmp_scope
            elseif GAME_CHANNEL == CHANNEL.IOS.CHANNEL_CODE_BD then
                url = server_url.."login?userName="..tostring(user_data.token).."&password="
            elseif GAME_CHANNEL == CHANNEL.IOS.CHANNEL_CODE_HW then
                local token = user_data["token"]
                url = server_url.."login?userName="..token.."&password="..tostring("")
            elseif GAME_CHANNEL == CHANNEL.IOS.CHANNEL_CODE_XG then
                local tmp_token = user_data["token"]
                local userid = user_data["userId"]
                url = server_url.."login?userName="..tostring("1").."&password="..tostring("").."&user_id="..userid.."&token="..tmp_token
            elseif GAME_CHANNEL == CHANNEL.IOS.CHANNEL_CODE_JW then
                local tmptoken = user_data["token"]
                local channelcode = user_data["channelcode"]
                local userid = user_data["userId"]
                url = server_url.."login?userName="..tostring("1").."&password="..tostring("").."&uid="..userid.."&token="..tmptoken.."&channel_code="..channelcode
            elseif GAME_CHANNEL == CHANNEL.IOS.CHANNEL_CODE_SY then
                local sid = user_data["sid"]
                local uid = user_data["uid"]
                local channenid = user_data["channelid"]
                local version = user_data["version"]
                local ext = user_data["ext"]
                url = server_url.."login?userName="..tostring("cc").."&password="..tostring("").."&channelId="..channenid.."&userId="..tostring("").."&sid="..string.urlencode(sid).."&ext="..string.urlencode(ext).."&version="..string.urlencode(version).."&platform=ios"
            end
        end
	else
		--cocos模拟器
		url = server_url.."login?userName="..tostring(username).."&password="..tostring(password)
    end
    url = url.."&channel="..GAME_CHANNEL
    print("--------------登录请求链接为："..url)

    self:__doLoginUserCenter(url, username, password)
end

function DengLuLayer:__doLoginUserCenter(_url, username, password)
    if string.isEmpty(_url) == true then
        XTHDTOAST(LANGUAGE_TIPS_WORDS122)
        return 
    end
    --[[登录user center 中心]]
    XTHDHttp:requestAsyncWithParams({
        url = _url,
        encrypt = HTTP_ENCRYPT_TYPE.NONE,
        successCallback = function(data)
            print("请求登录服务器返回的参数为：")
            print_r(data)
            if tonumber(data.result) == 0 then
                isLoginFlag = true
                local serverSum = data.serverSum
                local lastServerId = data.lastServerId--[[最后登陆的服务器id,如果==0,说明没有登陆过游戏服务器]]
                local token = data.token
                local serverId = data.serverId
                local serverName = getServerName(serverId, data.serverName)
                local serverIp = data.serverIp
                local serverPort = data.serverPort
                local openState = data.openState
                local crowdState = data.crowdState
                local newState = data.newState
                local _wealState = tonumber(data.wealState) or 0
                local syUserID = data.name
                gameUser.setSYUserID(syUserID)

                self:saveAccount(username,password)
                print("saveSelectedServer ---- _txt_server_name ----- ")
                self:saveSelectedServer(data)

                gameUser.setToken(token)
                gameUser.setNewLoginToken(token)
                gameUser.setServerName(serverName)
                gameUser._passportID = data.passportId
                gameUser.setLastaServerId(lastServerId)
                self._bg:setVisible(true)
                self._rect:setVisible(false)

                self._isLoginUC = true
                isLoginUC = true
                print("_isLoginUC   true")

                --显示游戏公告
                print("********CTX_log:第一次登录显示游戏公告*********")
                self:showNoticeDialog(function()
                    if _wealState == 1 then
                       self:showOldPlayerGuide()
                    end
                end)
            else
                --1017 账号被封
                XTHDTOAST(data.msg)
                -- self:showLoginRect()
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            -- self:showLoginRect()
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingParent = self,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

--[[
@return username password
]]
function DengLuLayer:getLastAccounts()
    local accounts = cc.UserDefault:getInstance():getStringForKey(KEY_NAME_ACCOUNT_INFO)
    accounts = loadstring(accounts)
    if type(accounts) == "function" then
        accounts = accounts()
    end
    accounts = checktable(accounts)
    if #accounts > 0 then
        return accounts
    else
        return nil
    end
end

function DengLuLayer:saveAccount(username,password)
    if not username or not password then
        return
    end
    local accounts = cc.UserDefault:getInstance():getStringForKey(KEY_NAME_ACCOUNT_INFO)
    accounts = loadstring(accounts)
    
    if type(accounts) == "function" then
       accounts = accounts()
    end
    if accounts == nil or accounts == "" then
       accounts = {}
    end
    for k,v in pairs(accounts) do
        if v.username == username then
            table.remove(accounts , k)
        end
    end
    table.insert(accounts , {username=username , password=password})
    if #accounts > MAX_ACCOUNT_COUNT then
        table.remove(accounts , 1)
    end
    cc.UserDefault:getInstance():setStringForKey(KEY_NAME_ACCOUNT_INFO,table.ser(accounts))
    cc.UserDefault:getInstance():flush()
end



function DengLuLayer:saveSelectedServer(serverData)
    print("DengLuLayer:saveSelectedServer()")
    local data_item = serverData
    local serverId = data_item.serverId
    local serverName = getServerName(serverId, data_item.serverName)
    local serverIp = data_item.serverIp
    local serverPort = data_item.serverPort
    local openState = data_item.openState
    local crowdState = data_item.crowdState
    local newState = data_item.newState
    self._serverId = serverId
    self._txt_server_name:setString(serverName)
    print("data_item.serverName  "..data_item.serverName)
    print("serverName  "..serverName)
    gameUser.setServerName(serverName)
    self._icon_server_status:initWithFile(XTHD.resource.getServerStatusImgPath(crowdState))
    self._icon_server_status:setAnchorPoint(cc.p(0,0.5))
    
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setStringForKey(KEY_NAME_LAST_SERVER,table.ser(serverData))
    userDefault:flush()

end

function DengLuLayer:ctor(isRelogin)
    print("********CTX_log:登录界面构造函数*********")
    self._relogin = isRelogin 
    self:InitUI()
    if isRelogin then 
        self._bg:setVisible(false)
        self._rect:setVisible(false)
        DengLuUtils.doNewLogin(self,isRelogin)
    end 
    LayerManager.layerOpen(2, self)
end


function DengLuLayer:tipsDialog()

    local show_msg = LANGUAGE_TIPS_WORDS123------"注意：清除数据后可能需要重新下载补丁包，但不会影响游戏数据、账号等相关信息，建议该功能只在游戏出现异常状况时使用，您确定清除缓存吗？"
    local confirmDialog = XTHDConfirmDialog:createWithParams({msg = show_msg})
    self:addChild(confirmDialog)

    confirmDialog:setCallbackRight(function ()
        XTHD.logout()
        cc.FileUtils:getInstance():removeDirectory(XTHD.resource.getWritablePath())
        helper.reloadAllFile()
        requires("src/main.lua")
    end)

    confirmDialog:setCallbackLeft(function (  )
        confirmDialog:removeFromParent()
    end)

end

--******************************************  SDK  相关  内容 BEGAN   --******************************************--
--获取平台
function DengLuLayer:getSDKFlag(  )
    local issdk = XTHD.isEmbeddedSdk()
    print("getSDKFlag ------ "..tostring(issdk))
    return issdk
end

--初始化SDK的登录相关数据
function DengLuLayer:initSDKLoginUI( ... )
    if not self:getSDKFlag() then
        return
    end

    --登录成功后的回调
    local loginCallBack = function (param)
        print("---------SDK登录成功回调----------")
        print_r(param)
        if param ~= nil and param ~= "" then
            isNotShowLoginUI = false
            if LayerManager.isLayerOpen(2) ~= nil then
                local node = LayerManager.isLayerOpen(2)
                node:loginUserCenter({data = param})
            end
            -- self:loginUserCenter({data = param})
        end
    end

    print("initSDKLoginUI ------ ")
    if isNotShowLoginUI then
        print("切换账号入口")
        XTHD.switchUserNotShowLoginUI({callback = loginCallBack})
    else
        print("登录入口")
        XTHD.login({callback = loginCallBack})
    end 

    XTHD.loginUpdataluaCall()
end 

--显示公告
function DengLuLayer:showNoticeDialog( _callBack )
    local notice = nil
	local str_url = XTHD.config.server.url_uc .. "versionNotice"
	XTHDHttp:requestAsyncWithParams( {
		url = str_url,
		isNotice = true,
		encrypt = HTTP_ENCRYPT_TYPE.NONE,
		method = HTTP_REQUEST_TYPE.GET,
		successCallback = function(data)
			if type(data) == "table" and data["result"] == 0 then
				if NOTICE_EXIST == true then
					return
				end
				local nowScene = self:getScene()
				if nowScene then
					notice = requires("src/fsgl/layer/DengLu/GongGaoLayer.lua"):create(_callBack,data)
					nowScene:addChild(notice,1025)
					notice:show()
				else
					notice = requires("src/fsgl/layer/DengLu/GongGaoLayer.lua"):create(_callBack,data)
					self:addChild(notice,1025)
					notice:show()
				end
			else
				XTHDTOAST(data["msg"])
				--self:removeFromParent()
			end
		end,
		-- 成功回调
		failedCallback = function()
		XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
		--self:removeFromParent()
		end-- 失败回调
	} )
end

--显示老玩家指引公告
function DengLuLayer:showOldPlayerGuide()
    -- 5,4,3,2,1
    local show_msg = LANGUAGE_TIPS_WORDS123------"注意：清除数据后可能需要重新下载补丁包，但不会影响游戏数据、账号等相关信息，建议该功能只在游戏出现异常状况时使用，您确定清除缓存吗？"
    local confirmDialog = XTHDConfirmDialog:createWithParams({
        msg = "亲爱的三测玩家你好，感谢你参加公开测试！现在登录1服盖世传奇即可领取奖励（VIP玩家登录后可获得充值返利和VIP等级）。请注意，该奖励只能在1服盖世传奇中领取。",
        leftVisible = false
    })
    self:addChild(confirmDialog, 1024)
    confirmDialog:getContainerLayer():setTouchEndedCallback(function()end)
    confirmDialog:setCallbackRight(function()end)

    local _count = 3
    local _state = "gray"
    local _button = confirmDialog:getRightButton()
    _button:setText(LANGUAGE_BTN_KEY.sure .. "(" .. _count .. ")")
    _button:setLabelColor(XTHD.resource.btntextcolor[_state])
    _button:setStateNormal(XTHD.getScaleNode("res/image/common/btn/btn_".._state.."_up.png",cc.size(130,51)))
    _button:setStateSelected(XTHD.getScaleNode("res/image/common/btn/btn_".._state.."_down.png",cc.size(130,51)))
    local function _doCount()
        performWithDelay(_button, function()
            _count = _count - 1
            if _count > 0 then
                _button:setText(LANGUAGE_BTN_KEY.sure .. "(" .. _count .. ")")
                _button:setLabelColor(XTHD.resource.btntextcolor[_state])
                _doCount()
            else
                _state = "green"
                _button:setText(LANGUAGE_BTN_KEY.sure)
                _button:setLabelColor(XTHD.resource.btntextcolor[_state])
                _button:setStateNormal(XTHD.getScaleNode("res/image/common/btn/btn_".._state.."_up.png",cc.size(130,51)))
                _button:setStateSelected(XTHD.getScaleNode("res/image/common/btn/btn_".._state.."_down.png",cc.size(130,51)))
                confirmDialog:setCallbackRight(function ()
                    confirmDialog:removeFromParent()
                end)
            end
        end, 1)
    end
    _doCount()
end

function DengLuLayer:showPlayerNamePopLayer()
	local layer = requires("src/fsgl/layer/DengLu/PlayerNamePoplayer.lua"):create()
	self:addChild(layer)
	layer:show()
end

--******************************************  SDK  相关  内容 END     --******************************************--

 function DengLuLayer:socketTestClint()
    local socket = require("socket")
     
    local host = "http://123.59.58.109/game/"
    local port = 1
    local sock = assert(socket.connect(host, port))
    
    sock:settimeout(0) --不设置阻塞
      
 
    local input, recvt, sendt, status
    local __x = 1
    while true do
        __x = __x +1
        input = __x
        if input > 0 then
            assert(sock:send(input .. "\n"))
        end
         
        recvt, sendt, status = socket.select({sock}, nil, 1)
        while #recvt > 0 do
            local response, receive_status = sock:receive()  --接收到的数据，接收状态
            if receive_status ~= "closed" then
                if response then
                    print(response)
                    recvt, sendt, status = socket.select({sock}, nil, 1)
                end
            else
                break
            end
        end
    end
  
end


-- end
function DengLuLayer:create(isRelogin)
    local layer = self.new(isRelogin)   
    return layer
end

return DengLuLayer
