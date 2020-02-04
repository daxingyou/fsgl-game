--  Created by zhangchao on 15-04-22.
--[[ 创建精灵 ]]
XTHD = XTHD or { }

function XTHD.createSprite(file)
    local _s
    if file then
        _s = cc.Sprite:create(file)
    end
    if not _s then
        if file then
            print("wm-----errTip : " .. tostring(file) .. " notExit")
        end
        _s = cc.Sprite:create()
    end
    return _s
end

-- 创建一个循环序列帧动画对象
--[[
    local _data = {
        file = "",
        name = "",
        startIndex = 1,
        endIndex = 10,
        perUnit = 0.1,
        isCircle = false
    }
]]
function XTHD.createSpriteFrameSp(params)
    local _file = params.file
    local _name = params.name
    local _start = params.startIndex
    local _endIndex = params.endIndex
    local _perUnit = params.perUnit or 2.8 / 14.0
    local _isCircle = params.isCircle == nil and true or params.isCircle

    cc.SpriteFrameCache:getInstance():addSpriteFrames(_file .. ".plist", _file .. ".png")
    local _sp = XTHD.createSprite()
    local animation = getAnimationBySpriteFrame(_name, _start, _endIndex, _perUnit)
    if _isCircle then
        _sp:runAction(cc.RepeatForever:create(animation))
    else
        _sp:runAction(cc.Sequence:create(animation, cc.RemoveSelf:create(true)))
    end
    return _sp
end

function XTHD.createLabel(params)
    return XTHDLabel:createWithParams(params)
end
--[[
--创建默认参数
local defaultParams = {
text = "",
fontSize = nil,--字体大小
size = nil,--字体大小，同上
ttf = nil,--自定义字体，默认字体使用:Helvetica
pos = cc.p(0,0),
color = cc.c3b(255, 255, 255),
anchor = cc.p(0.5,0.5),--锚点
needSwallow = false,--是否需要吞噬事件，默认不吞噬
clickable = true,--是否可以点击
beganCallback = nil,--点击事件的按下回调
endCallback = nil,--点击事件的抬起回调
touchSize = cc.size(0,0)--点击区域，如果没有传值，则默认点击区域为getBoundingBox()
}

[color=ffffffff]test[/color] 控制字体颜色，颜色值按aa rr gg bb排列
[b][/b] 字体加粗
[image=path offsety=-10 w=20 h= 20][/image] 图标 ,其中offsety如果为负数，则代表图标向下偏移10像素，w代表图标宽度(图标将强制变成此宽度)
[u][/u]下划线
[i][/i] 文字倾斜 汉字可能没有效果
]]
function XTHD.createRichLabel(params)
    return XTHDRichLabelTTF:createWithParams(params)
end
--[[--
{
    fnt = red|white|yellow|green
    text = "111"--
    kerning = -2 --间隔默认值
}
]]
function XTHD.createBMFontLabel(params)
    local fnt = params.fnt
    local text = params.text
    local kerning = params.kerning
    if fnt == nil then
        fnt = "res/fonts/baisezi.fnt"
    end
    if kerning == nil then
        kerning = -2
    end
    return XTHDLabel:createWithParams( { fnt = fnt, text = text, kerning = kerning })
end

function XTHD.createLayer()
    return cc.Layer:create()
end
function XTHD.createDialog()
    return XTHDDialog:create()
end

-- 创建开始战斗的按钮
--[[params = {
        par  = nil,--父类
        pos  = nil,--位置
        zorder1 = nil, --按钮层级
        zorder2 = nil, --动画层级
    ｝
]]
function XTHD.createFightBtn(params)
    local _params = {
        -- normalFile = "res/image/tmpbattle/star_chall.png",
        touchSize = cc.size(100,100),
        musicFile = "res/sound/battleStart.mp3",
    }
    local _zorder = params.zorder1 or 0
    local _btn = XTHDPushButton:createWithParams(_params)


    _btn:setPosition(params.pos)
    _btn:setContentSize(_params.touchSize)
    params.par:addChild(_btn, _zorder)

    local _effect = sp.SkeletonAnimation:create("res/spine/effect/select_hero/tiaozhan.json", "res/spine/effect/select_hero/tiaozhan.atlas", 1.0);
    _effect:runAction(cc.Sequence:create(cc.CallFunc:create( function()
        _effect:setAnimation(0, "tiaozhan", false)
    end ), cc.DelayTime:create(0.67), cc.CallFunc:create( function()
        _effect:setAnimation(0, "tiaozhan", true)
    end )))
    -- _effect:setOpacity(0)
    _effect:setPosition(params.pos)
    _zorder = params.zorder2 or 1
    params.par:addChild(_effect, _zorder)

    return _btn, _effect
end
--[[--
    local defaultParams = {
        normalNode        = nil,--默认状态下显示的node,通常为精灵
        selectedNode      = nil,--选中状态下显示的node,通常为精灵
        disableNode       = nil,--不可点击时显示的node,通常为精灵
        label             = nil,--按钮的文字node，通常为label控件,例如cc.Label
        normalFile        = nil,--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = nil,--选中状态下显示的精灵的文件名(如果同时传入selectedNode,则优先使用selectedNode)
        disableFile       = nil,--不可点击状态下显示的精灵文件名
        musicFile         = "res/sound/sound_clickBtn_effect.mp3",--点击的音效文件路径
        needSwallow       = true,--是否吞噬事件
        clickable         = true,--是否可以点击
        enable            = true,--true代表可点击，false代表不可点击，且按钮变灰，默认为true
        beganCallback     = nil,
        endCallback       = nil,--
        moveCallback      = nil,----
        ttf               = nil,--
        fnt               = nil,--
        text              = nil,--文字，字符串类型，如果传入了该字段，则优先使用该字段
        fontSize          = 18,--字体大小`
        fontColor         = cc.c3b(255, 255, 255),
        touchSize         = cc.size(0,0),--点击区域，如果没有传值，则默认点击区域为getBoundingBox()
        touchScale        = 1,--点击按钮时的缩放比例
        anchor            = cc.p(0.5,0.5),--锚点
        pos               = cc.p(0,0),--坐标
        x                 = 0,--x
        y                 = 0,--y
        needEnableWhenMoving = false,   --当滑动的时候，时候响应点击事件,默认滑动的时候响应点击事件  yanyuling true的话滑动不响应 false滑动响应
        needEnableWhenOut = false,      --是否在移出点击范围内抬起还相应end事件 liuluyang
    }
]]
function XTHD.createButton(params)
    params = params or { }
    if params.musicFile == nil then
        params.musicFile = XTHD.resource.music.effect_btn_common
    end
    return XTHDPushButton:createWithParams(params)
end

--[[
    local default = {
        btnColor = "green",        --默认是绿色按钮
        btnSize = cc.size(102,48), --默认为按钮本身大小
        isEnableShadow = true,     --默认给传入的text加粗，label不加粗
    }
]]
-- 新UI的button(只需要传入button的颜色、大小)，其它参数和XTHDPushButton的一样
function XTHD.createCommonButton(params)
    local params = params or { }
    local btnColor = params.btnColor or "write_1"
    local btnSize = params.btnSize or cc.size(102, 46)
    local btnparams = { }
    if btnColor == "write" or btnColor == "write_1" or btnColor == "blue" or btnColor == "gray" then
        btnSize = cc.size(163, 75)
        btnparams = {
            normalNode = XTHD.getScaleNode1("res/image/common/btn/btn_" .. btnColor .. "_up.png",btnSize),
            selectedNode = XTHD.getScaleNode1("res/image/common/btn/btn_" .. btnColor .. "_down.png",btnSize),
            fontColor = params.fontColor or XTHD.resource.btntextcolor["write"],
            fontSize = 24,
            isEnableShadow = true,
        }
    else
        btnparams = {
            normalNode = XTHD.getScaleNode("res/image/common/btn/btn_" .. btnColor .. "_up.png",btnSize),
            selectedNode = XTHD.getScaleNode("res/image/common/btn/btn_" .. btnColor .. "_down.png",btnSize),
            fontColor = params.fontColor or XTHD.resource.btntextcolor[btnColor],
            fontSize = 22,
            isEnableShadow = true,
        }
    end
    params.btnColor = nil
    -- params.btnSize = nil
    for k, v in pairs(params) do
        if params[k] then
            btnparams[k] = params[k]
        end
    end
    if btnparams.isEnableShadow == true and btnparams.text ~= nil and btnparams.label == nil then
        if btnparams.fontColor.a == nil then
            btnparams.fontColor.a = 255
        end
        btnparams.label = XTHDLabel:create(btnparams.text, btnparams.fontSize, "res/fonts/def.ttf")
        btnparams.label:setAnchorPoint(cc.p(0.5, 0.45))
        -- btnparams.label:setPosition(btnSize.width/2, btnSize.height/2)

        -- btnparams.label:enableShadow(btnparams.fontColor,cc.size(0.4,-0.4),0.4)
        -- btnparams.label:enableOutline(cc.c4b(150,79,39,255),2)

    end
    if btnparams.label then
        if btnColor == "write_1" then
            btnparams.label:enableOutline(cc.c4b(150, 79, 39, 255), 2)
        elseif btnColor == "write" then
            btnparams.label:enableOutline(cc.c4b(103, 34, 13, 255), 2)
        elseif btnColor == "blue" then
            btnparams.label:enableOutline(cc.c4b(45, 13, 103, 255), 2)
        end

    end


    return XTHD.createButton(btnparams)
end

-- 获取指定大小的按钮
function XTHD.getBtnFrame(imgpath1, imgpath2, size, movetouch)
    local btn_normal = ccui.Scale9Sprite:create(imgpath1)
    btn_normal:setContentSize(size)

    local btn_selected = ccui.Scale9Sprite:create(imgpath2)
    btn_selected:setContentSize(size)

    local moveing_touch = movetouch or false

    local btn = XTHDPushButton:createWithParams( {
        normalNode = btn_normal,
        selectedNode = btn_selected,
        needSwallow = false,
        needEnableWhenMoving = moveing_touch,
        musicFile = XTHD.resource.music.effect_btn_common,
    } )
    return btn
end

------创建带音效的按钮
XTHD.SoundEnum = {
    kSound_closeCommon = 1,
    kSound_closePop = 2,
    kSound_common = 3,
}
function XTHD.createPushButtonWithSound(params, _type)
    local str = XTHD.resource.music.effect_btn_common
    if _type == XTHD.SoundEnum.kSound_closePop then
        str = XTHD.resource.music.effect_close_pop
    elseif _type == XTHD.SoundEnum.kSound_closeCommon then
        str = XTHD.resource.music.effect_btn_commonclose
    end

    if params and type(params) == "table" then
        params.musicFile = str
    else
        params = { musicFile = str }
    end
    return XTHDPushButton:createWithParams(params)
end
--[[
@gray  true:node会变灰，否则恢复原样
(注:暂时没有递归处理子节点)
]]
function XTHD.setGray(node, gray)
    if gray ~= nil and gray == false then
        node:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(cc.SHADER_POSITION_TEXTURE_COLOR_NO_MVP))
    else
        XTHD.setShader(node, "res/shader/gray.vsh", "res/shader/gray.fsh")
    end
end

function XTHD.setShader(node, vsh, fsh)
    local glProgram = cc.GLProgramCache:getInstance():getGLProgram(vsh)
    if glProgram == nil then
        local pProgram = cc.GLProgram:create(vsh, fsh)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
        pProgram:link()
        pProgram:updateUniforms()
        cc.GLProgramCache:getInstance():addGLProgram(pProgram, vsh)
        glProgram = cc.GLProgramCache:getInstance():getGLProgram(vsh)
        -- print("添加shader:["..vsh.."]")
    else
        -- print("找到shader:["..vsh.."]")
    end
    node:setGLProgram(glProgram)
end

function XTHD.getHeaderIconPath(_type)
    local fileImage = nil
    if _type == XTHD.resource.type.exp then
        fileImage = IMAGE_KEY_COMMON_ITEM_EXP
    elseif _type == XTHD.resource.type.gold then
        fileImage = IMAGE_KEY_HEADER_GOLD
    elseif _type == XTHD.resource.type.ingot then
        fileImage = IMAGE_KEY_HEADER_INGOT
    elseif _type == XTHD.resource.type.item then
        -- 不可能是装备
    elseif _type == XTHD.resource.type.tili then
        fileImage = IMAGE_KEY_HEADER_TILI
    elseif _type == XTHD.resource.type.feicui then
        fileImage = IMAGE_KEY_HEADER_FEICUI
    elseif _type == XTHD.resource.type.prestige then
        fileImage = IMAGE_KEY_HEADER_PRESTIGE
    elseif _type == XTHD.resource.type.xueyu then

    elseif _type == XTHD.resource.type.honor then
        fileImage = IMAGE_KEY_HEADER_HONOR
    elseif _type == XTHD.resource.type.stone then
        fileImage = IMAGE_KEY_HEADER_SAINTSTONE
    elseif _type == XTHD.resource.type.contribution then

    elseif _type == XTHD.resource.type.reward then
        fileImage = IMAGE_KEY_HEADER_AWARD
    elseif _type == XTHD.resource.type.energy then
        fileImage = IMAGE_KEY_HEADER_ENERGY
    elseif _type == XTHD.resource.type.soul_green then

    elseif _type == XTHD.resource.type.soul_blue then

    elseif _type == XTHD.resource.type.soul_purple then

    elseif _type == XTHD.resource.type.soul_red then

    elseif _type == XTHD.resource.type.azure then

    elseif _type == XTHD.resource.type.white then

    elseif _type == XTHD.resource.type.vermilion then

    elseif _type == XTHD.resource.type.black then

    end
    return fileImage
end


function XTHD.createHeaderIcon(_type)
    -- 用来根据type创建小图标
    local fileImage = nil
    if _type == XTHD.resource.type.exp then
        fileImage = IMAGE_KEY_COMMON_ITEM_EXP
    elseif _type == XTHD.resource.type.gold then
        fileImage = IMAGE_KEY_HEADER_GOLD
    elseif _type == XTHD.resource.type.ingot then
        fileImage = IMAGE_KEY_HEADER_INGOT
    elseif _type == XTHD.resource.type.item then
        -- 不可能是装备
    elseif _type == XTHD.resource.type.tili then
        fileImage = IMAGE_KEY_HEADER_TILI
    elseif _type == XTHD.resource.type.feicui then
        fileImage = IMAGE_KEY_HEADER_FEICUI
    elseif _type == XTHD.resource.type.prestige then
        fileImage = IMAGE_KEY_HEADER_PRESTIGE
    elseif _type == XTHD.resource.type.xueyu then

    elseif _type == XTHD.resource.type.honor then
        fileImage = IMAGE_KEY_HEADER_HONOR
    elseif _type == XTHD.resource.type.stone then
        fileImage = IMAGE_KEY_HEADER_SAINTSTONE
	elseif _type == XTHD.resource.type.servant then
        fileImage = IMAGE_KEY_HEADER_SERVANTSTONE
    elseif _type == XTHD.resource.type.contribution then

    elseif _type == XTHD.resource.type.reward then
        fileImage = IMAGE_KEY_HEADER_AWARD
    elseif _type == XTHD.resource.type.energy then
        fileImage = IMAGE_KEY_HEADER_ENERGY
    elseif _type == XTHD.resource.type.soul_green then

    elseif _type == XTHD.resource.type.soul_blue then

    elseif _type == XTHD.resource.type.soul_purple then

    elseif _type == XTHD.resource.type.soul_red then

    elseif _type == XTHD.resource.type.azure then

    elseif _type == XTHD.resource.type.white then

    elseif _type == XTHD.resource.type.vermilion then

    elseif _type == XTHD.resource.type.black then

    end

    local tmpSprite = cc.Sprite:create()

    if tmpSprite then
        print(fileImage)
        tmpSprite = cc.Sprite:create(fileImage)
    end

    return tmpSprite
end

function XTHD.createSaintBeastChange(fNode, callback, zorder)
    local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("Artifact")
	cc.Director:getInstance():getRunningScene():addChild(layer)
	layer:show()
end

function XTHD.createServantChange(fNode,callback,zorder)
    local ServantChangeLayer = requires("src/fsgl/layer/ShangCheng.lua"):create({which = 'servant',callback = callback}) -----神器商店
    LayerManager.addLayout(ServantChangeLayer, {par = fNode, zz = zorder})
end

function XTHD.createEquipLayer(heroid, dbid, _type, CallFunc)
    -- ZOrder = ZOrder or 0
    -- if _type == 4 then
    --     equipLayer = requires("src/fsgl/layer/ZhuangBei/EquipNewLayer.lua"):create(dbid,1,CallFunc)
    --     if equipLayer:getChildByName("tab4"):getTouchEndedCallback() then
    --         equipLayer:getChildByName("tab4"):getTouchEndedCallback()()
    --     end
    -- else
    --     equipLayer = requires("src/fsgl/layer/ZhuangBei/EquipNewLayer.lua"):create(dbid,_type,CallFunc)
    -- end
    -- LayerManager.pushModule(equipLayer)
	if _type == 2 then
		local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("camp")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
	elseif _type == 1 then
		local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("arena")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
	elseif _type == 3 then
		local equipLayer = requires("src/fsgl/layer/ZhuangBei/ZhuangBeiLayer.lua"):create(heroid, dbid, _type, CallFunc)
		LayerManager.addLayout(equipLayer)
	end
end

function XTHD.createEquipSmeltLayer(dbid, callback)
    if not XTHD.getUnlockStatus(29, true) then
        return
    end
    local equipSmeltLayer = requires("src/fsgl/layer/ZhuangBei/ZhuangBeiSmeltLayer.lua"):create(dbid, callback)
    LayerManager.addLayout(equipSmeltLayer)
end

function XTHD.createIllustrationLayer()
    local illustrationlayer = requires("src/fsgl/layer/TuJian/TuJianLayer.lua"):create()
    LayerManager.addLayout(illustrationlayer)
end

function XTHD.createTask(fNode, CallFunc, ZOrder, index)
    ZOrder = ZOrder or 0
    XTHDHttp:requestAsyncInGameWithParams( {
        modules = "taskList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                HttpRequestWithOutParams("gragraduationRewardList",function (sdata)
--                    print("毕业典礼的数据为")
--                    print_r(sdata)
                    local tasklayer = requires("src/fsgl/layer/RenWu/RenWuLayer.lua"):create(data, CallFunc, index,sdata)
                    LayerManager.addLayout(tasklayer)
                end) 
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,
        -- 失败回调
        targetNeedsToRetain = fNode,
        -- 需要保存引用的目标
        loadingParent = fNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function XTHD.createBibleLayer(fNode)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "baodianWindow?",
        successCallback = function(backData)
            if tonumber(backData.result) == 0 then
				gameUser.setGuildPoint(backData.totalContribution)
                local bibleLayer = requires("src/fsgl/layer/XiuLian/XiuLianListLayer.lua"):create( { backData = backData })
                LayerManager.addLayout(bibleLayer)
            else
                XTHDTOAST(backData.msg)
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        targetNeedsToRetain = fNode,
        -- 需要保存引用的目标
        loadingParent = fNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function XTHD.createCompetitiveChange(fNode, zorder, _type, callback)
    local CompetitiveChangeLayer = requires("src/fsgl/layer/ShangCheng.lua"):create( { which = 'arena', callback = callback })
    ----竞技场
    LayerManager.addLayout(CompetitiveChangeLayer, { par = fNode, zz = zorder })
end

function XTHD.createEquipCopies(fNode, zorder)
    requires("src/fsgl/layer/ShenBingGe/ShenBingGeLayer.lua"):create(fNode)
end

function XTHD.createXiuLuo(fNode)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "openAsura?",
        params = { },
        successCallback = function(data)
            if data.result == 0 then
                LayerManager.addShieldLayout()
                local XiuLuoLianYuLayer = requires("src/fsgl/layer/XiuLuoLianYu/XiuLuoLianYuLayer.lua"):create(data)
                LayerManager.addLayout(XiuLuoLianYuLayer)
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        loadingParent = fNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function XTHD.createArtifact(heroId, fNode, godid, callback)
    -- 先从数据库中取出现有神器
    local ownArtifact = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ARTIFACT)
    if ownArtifact.godid then
        ownArtifact = { ownArtifact }
    end
    -- 循环判断那个神器是装备在这个英雄身上的
    if not godid then
        for i = 1, #ownArtifact do
            if ownArtifact[i].petId == heroId then
                -- 找到神器，进入神器页面
                local ShenQiLayer = requires("src/fsgl/layer/ShenQi/ShenQiLayer.lua"):create(ownArtifact[i].godid, ownArtifact, callback)
                -- LayerManager.pushModule(ShenQiLayer)
                LayerManager.addLayout(ShenQiLayer)
                return
            end
        end
    else
        local ShenQiLayer = requires("src/fsgl/layer/ShenQi/ShenQiLayer.lua"):create(godid, ownArtifact, callback)
        LayerManager.addLayout(ShenQiLayer)
        -- LayerManager.pushModule(ShenQiLayer)
        return
    end
    -- 如果这个英雄身上没有神器，弹出这个框
    if fNode then
        local ShenQiConfirmPop = requires("src/fsgl/layer/ShenQi/ShenQiConfirmPop.lua"):create(#ownArtifact, heroId, fNode, callback)
        fNode:addChild(ShenQiConfirmPop)
        ShenQiConfirmPop:show()
    end
end

function XTHD.createSeekTreasureLayer(node)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "liemingBase?",
        params = { },
        successCallback = function(data)
            if data.result == 0 then
                LayerManager.addShieldLayout()
                local seekTreasure = requires("src/fsgl/layer/QuXiongBiJi/QuXiongBiJiLayer.lua"):create(data, node)
                LayerManager.addLayout(seekTreasure)
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,
        -- 失败回调
        targetNeedsToRetain = node,
        -- 需要保存引用的目标
        loadingParent = node,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function XTHD.createStoneGambling(_callback)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "openCutJade?",
        params = { },
        successCallback = function(data)
            if data.result == 0 then
                LayerManager.addShieldLayout()
                local KaiShanCaiKuang = requires("src/fsgl/layer/KaiShanCaiKuang/KaiShanCaiKuang.lua"):create(data, _callback)
                LayerManager.addLayout(KaiShanCaiKuang)
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,
        -- 失败回调
        targetNeedsToRetain = fNode,
        -- 需要保存引用的目标
        loadingParent = fNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function XTHD.createSaintBeastChapter()
    -- XTHDTOAST("此功能暂未开启！")
    -- do return end
    XTHDHttp:requestAsyncInGameWithParams( {
        modules = "godBeastEctype?",
        successCallback = function(godBeastEctype)
            if tonumber(godBeastEctype.result) == 0 then
                local SaintBeast = requires("src/fsgl/layer/LiLian/LiLianSaintBeastSelectLayer.lua"):create(godBeastEctype)
                LayerManager.addLayout(SaintBeast, { par = self })
            else
                XTHDTOAST(godBeastEctype.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,
        -- 失败回调
        targetNeedsToRetain = fNode,
        -- 需要保存引用的目标
        loadingParent = fNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function XTHD.createServantsChapter()
    -- XTHDTOAST("此功能暂未开启！")
    -- do return end
    XTHDHttp:requestAsyncInGameWithParams({
        modules="servantEctype?",
        successCallback = function(godBeastEctype)
            if tonumber(godBeastEctype.result) == 0 then
                local SaintBeast = requires("src/fsgl/layer/ShenQiYiZhi/ShenQiYiZhiSelectLayer.lua"):create(godBeastEctype)
                LayerManager.addLayout(SaintBeast,{par = self})
            else
                XTHDTOAST(godBeastEctype.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        targetNeedsToRetain = fNode,--需要保存引用的目标
        loadingParent = fNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function XTHD.createHangUpLayer()
    ClientHttp:requestAsyncInGameWithParams({
        modules="hangUpList?",
        successCallback = function( data )
            -- print("修仙圣境服务器返回的数据为：")
            -- print_r(data)
            if tonumber( data.result ) == 0 then
                --刷新挂机信息
                local hangup = requires("src/fsgl/layer/BiGuan/BiGuanLayer.lua"):create({which = 'yingliang',data = data})
                LayerManager.addLayout(hangup)
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = fNode,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = fNode,
    })  
end

function XTHD.createChallengeChapter()
    ClientHttp:requestAsyncInGameWithParams({
        modules="ectypeSingleRecord?",
        successCallback = function( data )
--             print("单挑之王服务器返回的数据为：")
--             print_r(data)
            if tonumber( data.result ) == 0 then
				gameUser.settaoFaLingSum(data.taoFaLingSum)
                local challenge = requires("src/fsgl/layer/JingXiangZhiLu/JingXiangZhiLuSingleChallengeLayer.lua"):create(data.ectypeRecord)
                LayerManager.addLayout(challenge)
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = fNode,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = fNode,
    })  
end

function XTHD.createCompetitiveLayer(callback, needPoint)
    if XTHD.getUnlockStatus(63, true) == false then
        return
    end
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "arenaTeams?",
        params = { },
        successCallback = function(net_data)
            if tonumber(net_data.result) == 0 then
                local CompetitiveLayer = requires("src/fsgl/layer/JingJi/JingJiMainLayer.lua")
                local layer = CompetitiveLayer:create(net_data, needPoint, callback)
                LayerManager.addLayout(layer)
            else
                XTHDTOAST(net_data.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,
        -- 失败回调
        targetNeedsToRetain = fNode,
        -- 需要保存引用的目标
        loadingParent = fNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )

end

-- 创建兑换英雄界面
function XTHD.createExchangeHero(node1, node2, callback, zorder, failedCall)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "openRecruit?",
        successCallback = function(data)
            if data.result == 0 then
                if node2 then
                    LayerManager.removeLayout(node2)
                end
                local exchange_hero = requires("src/fsgl/layer/QiXingTan/QiXingTanchangeHeroLayer.lua"):create(data, callback)
                LayerManager.addLayout(exchange_hero, { par = node1, zz = zorder })
            else
                XTHDTOAST(data.msg)
                if failedCall and type(failedCall) == "function" then
                    failedCall()
                end
            end
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            if failedCall and type(failedCall) == "function" then
                failedCall()
            end
        end,
        -- 失败回调
        targetNeedsToRetain = node,
        -- 需要保存引用的目标
        loadingParent = node,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end
-- 创建兑换装备界面
function XTHD.createExchangeEquip(node1, node2, callback, zorder)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "openRecruit?",
        successCallback = function(data)
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            end
            if node2 then
                LayerManager.removeLayout(node2)
            end
            local exchangeEquip = requires("src/fsgl/layer/QiXingTan/QiXingTanchangeEquipLayer.lua"):create(data, callback)
            LayerManager.addLayout(exchangeEquip, { par = node1, zz = zorder })
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,
        -- 失败回调
        targetNeedsToRetain = node,
        -- 需要保存引用的目标
        loadingParent = node,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

-- 创建兑换界面
function XTHD.createExchangeLayer(node,index,callback)
	ClientHttp:requestAsyncInGameWithParams( {
        modules = "openRecruit?",
        successCallback = function(data)
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
            end
            local exchangeLayer = requires("src/fsgl/layer/QiXingTan/QiXingTanchangeLayer.lua"):create(data,callback)
			LayerManager.addLayout(exchangeLayer)
        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,
        -- 失败回调
        targetNeedsToRetain = node,
        -- 需要保存引用的目标
        loadingParent = node,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

-- 银两副本
function XTHD.createGoldCopy(node, zorder)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "goldEctypeBase?",
        successCallback = function(data)
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                return
            end
            if data["result"] == 0 then
                local gold_copy = requires("src/fsgl/layer/ShangJinLieRen/ShangJinLieRenLayer.lua"):create(data)
                LayerManager.addLayout(gold_copy, { par = node, zz = zorder })
                -- if not zorder then
                --     node:addChild(gold_copy)
                -- else
                --     node:addChild(gold_copy,zorder)
                -- end
            else
                XTHDTOAST(data["msg"])
            end

        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,
        -- 失败回调
        targetNeedsToRetain = node,
        -- 需要保存引用的目标
        loadingParent = node,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

-- 翡翠副本
function XTHD.createJaditeCopy(node, zorder, callFunc)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "feicuiEctypeBase?",
        successCallback = function(data)
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                return
            end
            if data["result"] == 0 then
                local jadite_copy = requires("src/fsgl/layer/ShiLianZhiTa/ShiLianZhiTaLayer.lua"):create(data, callFunc)
                LayerManager.addLayout(jadite_copy, { par = node, zz = zorder })
            else
                XTHDTOAST(data["msg"])
            end

        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,
        -- 失败回调
        targetNeedsToRetain = node,
        -- 需要保存引用的目标
        loadingParent = node,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

-- vip特权界面
function XTHD.createVipLayer(node, node1, zorder)

    print(XTHD.getVIPRewardExist(), "getVIPExistgetVIPExist")
    print(XTHD.getVIPExist(), "getVIPExistgetVIPExist")
    if XTHD.getVIPRewardExist() == true then
        if XTHD.getVIPExist() == true then
            LayerManager.removeLayout()
        end
        return
    end
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "vipRewardRecord?",
        successCallback = function(data)
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                return
            end
            if data["result"] == 0 then

                -- 先移除后添加，否则会销毁吊topbar中刷新数据的通知
                if node1 ~= nil then
                    LayerManager.removeLayout(node1)
                    -- node1:removeFromParent()
                end

                local vip = requires("src/fsgl/layer/Vip/VipRewardLayer1.lua"):create(data)
                LayerManager.addLayout(vip, { par = node, zz = zorder })
                -- if zorder then
                --     node:addChild(vip,zorder)
                -- else
                --     node:addChild(vip)
                -- end
            else
                XTHDTOAST(data["msg"])
            end

        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,
        -- 失败回调
        targetNeedsToRetain = node,
        -- 需要保存引用的目标
        loadingParent = node,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

-- 邮件界面
function XTHD.createMail(node)
    local function _createCall(sData)
        local _mail = requires("src/fsgl/layer/YouJian/YouJiangLayer.lua"):create(sData)
        LayerManager.addLayout(_mail)
    end
    YouJiangData.httpGetMailList(node, _createCall)
end

-- 战报
function XTHD.createBattleReport(node)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "arenaLog?",
        params = { },
        successCallback = function(net_data)
            if tonumber(net_data.result) == 0 then
                local _mail = requires("src/fsgl/layer/JingJi/JingJiBattleReport.lua"):create(net_data)
                LayerManager.addLayout(_mail)
            else
                XTHDTOAST(net_data["msg"])
            end

        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,
        -- 失败回调
        targetNeedsToRetain = node,
        -- 需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

-- by hezhitao began

-- 判断VIP充值界面是否存在，如果VIP充值界面已经存在，则不再addchild  VIP充值界面，防止在VIP充值界面出现银两不足，出现循环添加的情况
vip_exist_flag = false
function XTHD.setVIPExist(flag)
    vip_exist_flag = flag
end
function XTHD.getVIPExist()
    return vip_exist_flag
end
vipReward_exist_flag = false
function XTHD.setVIPRewardExist(flag)
    vipReward_exist_flag = flag
end
function XTHD.getVIPRewardExist()
    return vipReward_exist_flag
end

-- end

-- vip充值界面
function XTHD.createRechargeVipLayer(node, node1, zorder)

    print(XTHD.getVIPExist(), "getVIPExistgetVIPExist")
    if XTHD.getVIPExist() == true then
        -- if XTHD.getVIPRewardExist() == true then
        --     LayerManager.removeLayout()
        -- end
        return
    end

    ClientHttp:requestAsyncInGameWithParams( {
        modules = "payWindows?",
        successCallback = function(data)
            if not data or next(data) == nil then
                XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
                return
            end
            if data["result"] == 0 then
                -- 先移除后添加，否则会销毁吊topbar中刷新数据的通知
                if node1 ~= nil then
                    LayerManager.removeLayout(node1)
                end

                local recharge_vip = requires("src/fsgl/layer/Vip/VipRechargeLayer1.lua"):create(data)
                LayerManager.addLayout(recharge_vip, { par = node, zz = zorder })
                --  if zorder then
                --     node:addChild(recharge_vip,zorder)
                -- else
                --     node:addChild(recharge_vip)
                -- end
            else
                XTHDTOAST(data["msg"])
            end

        end,
        -- 成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_KEY_ERROR_NETWORK)
        end,
        -- 失败回调
        targetNeedsToRetain = node,
        -- 需要保存引用的目标
        loadingParent = node,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function XTHD.getUnlockStatus(id, isToast)
    -- 配置id isToast如果没开是否弹出解锁条件
    isToast = isToast or false
    if not FUNCTION_INFO_DATA then
        FUNCTION_INFO_DATA = gameData.getDataFromCSV("FunctionInfoList")
    end
    local isOpen = false
    if FUNCTION_INFO_DATA[id].unlocktype == 1 then
        isOpen = gameUser.getLevel() >= FUNCTION_INFO_DATA[id].unlockparam
    elseif FUNCTION_INFO_DATA[id].unlocktype == 2 then
        isOpen = gameUser.getInstancingId() >= FUNCTION_INFO_DATA[id].unlockparam
    end
    if isToast == true and isOpen == false then
        XTHDTOAST(FUNCTION_INFO_DATA[id].tip)
    end
    return isOpen
end

-- 创建排行榜奖励界面
function XTHD.createRankListRewardLayer(node)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "topRewardData?",
        params = { rewardType = 1 },
        successCallback = function(data)
            -- dump( data, "topRewardData" )
            if tonumber(data.result) == 0 then
                data._index = 1
                local YingXiongBangLayer = requires("src/fsgl/layer/YingXiongBang/YingXiongBangLayer.lua"):create(data)
                LayerManager.addLayout(YingXiongBangLayer)
            else
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
                ------"网络请求失败"..data.result)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,
        -- 加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    } )
end
-- 创建选阵营界面
function XTHD.createCampRegisterLayer(par, callback)
    HttpRequestWithOutParams("campFewerPeople",function (data)
        -- print("请求较少人数阵营服务器返回的数据为：")
        -- print_r(data)
        local layer = requires("src/fsgl/layer/ZhongZu/ZhongZuRegisterLayer.lua"):createWithParams( {
            campID = data.campId,
            callback = callback
        })
        par:addChild(layer)
    end,
	function()
		cc.Director:getInstance():popToRootScene()
		XTHD.replaceToLoginScene()
	end)
end

-- 创建选英雄界面
function XTHD.createSelectHeroLayer(scene, callback)
    local _lay = requires("src/fsgl/layer/YinDaoJieMian/YinDaoSelectHeroLayer.lua"):create( function()
        LayerManager.pushModule(nil, true, { guide = true })
        replaceLayer( { id = 1, parent = LayerManager.getBaseLayer() })
    end )
    -- scene:addChild(_lay)
    return _lay
    -- local pLay = XTHDDialog:create(255)
    -- local labTxt = XTHD.createLabel( { color = cc.c3b(255, 255, 255), fontSize = 30 })
    -- labTxt:setDimensions(800, 150)
    -- labTxt:setAnchorPoint(cc.p(0.5, 0.5))
    -- labTxt:setPosition(winWidth / 2, winHeight / 2)
    -- labTxt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- labTxt:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    -- labTxt:setOpacity(0)
    -- labTxt:setString("请选择一位英雄")
    -- pLay:addChild(labTxt)
    -- labTxt:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.FadeIn:create(3.0), cc.FadeOut:create(2.0), cc.CallFunc:create( function(...)
    --     pLay:removeFromParent()
    --     local _lay = requires("src/fsgl/layer/YinDaoJieMian/YinDaoSelectHeroLayer.lua"):create( function()
    --         LayerManager.pushModule(nil, true, { guide = true })
    --         replaceLayer( { id = 1, parent = LayerManager.getBaseLayer() })
    --     end )
    --     scene:addChild(_lay)
    -- end )))
    -- return pLay
end

function XTHD.createExchangePop(_type)
    local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create( { id = _type })
    -- byhuangjunjian 获得资源共用方法（1.元宝2.体力3.银两4.翡翠）
    cc.Director:getInstance():getRunningScene():addChild(StoredValue)
end

function XTHD.createSemltChange(fNode, callback)
    local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("recycle")
	cc.Director:getInstance():getRunningScene():addChild(layer)
	layer:show()
end

function XTHD.createDialog()
    return XTHDDialog:create()
end

function XTHD.createArenaRank(num)
    return cc.Sprite:create("res/image/common/rank_icon/rankIcon_" ..(num - 1) .. ".png")
end

function XTHD.createNewBackBtn(_endCall)
    local _size = cc.Director:getInstance():getWinSize()
    local back_btn = XTHD.createButton( {
        normalNode = cc.Sprite:create("res/image/common/btn/btn_back_normal.png"),
        selectedNode = cc.Sprite:create("res/image/common/btn/btn_back_selected.png"),
        musicFile = XTHD.resource.music.effect_btn_commonclose,
        touchSize = cc.size(150,60),
        anchor = cc.p(1,1),
        pos = cc.p(_size.width,_size.height),
        endCallback = _endCall
    } )
    return back_btn
end

function XTHD.createBasePageLayer(params)
    -- dump(params, "wm----createBasePageLayer")
    local defaultParams = {
        bg = "res/image/plugin/weaponshop/bg.png",
        -- 背景
        isScale = true,
        isCreateBg = true,
        isOnlyBack = false,
        difPos = cc.p(0,0),
        callback = nil,
        -- 关闭回调 注意 如果传入回调需要自己在回调内部添加removeFronParent()
        isShadow = false,
        -- 是否在顶部条后面加阴影
        isNewBackBtn = true,
        ZOrder = 1,
        showPlus = true,
        showGF = true,
    }

    if params == nil then params = { } end
    for k, v in pairs(defaultParams) do
        if params[k] == nil then
            params[k] = v
        end
    end
    local dialog = XTHDDialog:create()
    if params.isCreateBg then
        local bgSprite = XTHD.createSprite(params.bg)
        bgSprite:setPosition(dialog:getBoundingBox().width / 2 + params.difPos.x, dialog:getBoundingBox().height / 2 + params.difPos.y)
        bgSprite:setName("BgSprite")
        dialog:addChild(bgSprite)
        if params.isScale == true then
            bgSprite:setScale(dialog:getBoundingBox().width / bgSprite:getBoundingBox().width, dialog:getBoundingBox().height / bgSprite:getBoundingBox().height)
        end
    end

    if params.isShadow == true then
        local chapter_top_bg = ccui.Scale9Sprite:create("res/image/plugin/stageChapter/chapter_top_bg.png")
        chapter_top_bg:setContentSize(cc.size(dialog:getContentSize().width, 43))
        chapter_top_bg:setAnchorPoint(0.5, 1)
        chapter_top_bg:setPosition(dialog:getContentSize().width / 2, dialog:getContentSize().height)
        dialog:addChild(chapter_top_bg, params.ZOrder)
    end

    local function _endCall()
        if params.callback then
            params.callback()
        else
            LayerManager.removeLayout(dialog)
        end
    end
    if params.isOnlyBack then
        local back_btn = XTHD.createNewBackBtn(_endCall)
        back_btn:setName("back_btn")
        dialog:addChild(back_btn, params.ZOrder)
    else
        local _topBarLayer = requires("src/fsgl/layer/common/TopBarLayer1.lua"):create(params.isNewBackBtn, params.showPlus, params.showGF)
        _topBarLayer:setName("TopBarLayer1")
        _topBarLayer:setBackCallFunc(_endCall)
        dialog.topBarHeight = _topBarLayer:getTopBarHeight()
        dialog:addChild(_topBarLayer, params.ZOrder)
    end
    dialog.topBarHeight = dialog.topBarHeight or 40

    return dialog
end

function XTHD.createPopLayer(params)
    return XTHDPopLayer:create(params)
end
function XTHD.createItemNode(params)
    return ItemNode:createWithParams(params)
end

function XTHD.createBtnClose(callBack)
    local close_btn = XTHDPushButton:createWithParams( {
        normalNode = cc.Sprite:create("res/image/common/btn/btn_red_close_normal.png"),
        selectedNode = cc.Sprite:create("res/image/common/btn/btn_red_close_selected.png"),
        needSwallow = true,
        enable = true,
        endCallback = function()
            if callBack then
                callBack()
            end
        end
    } )
    return close_btn
end
--[[
@_type  1代表正方形，2代表圆形...
@id     图片id
]]
function XTHD.createHeroAvatar(param)
    return XTHD.createSprite(XTHD.resource.getHeroAvatarImgPath(param))
end

-- 显示资源找回面板
function XTHD.showRecoveryLayer()
    cc.Director:getInstance():getRunningScene():addChild(ZiYuanZhaoHuiLayer:create())
end

-- 显示羁绊界面
function XTHD.showJiBanLayer()
    cc.Director:getInstance():getRunningScene():addChild(JiBanLayer:create())
end


--[[ action ]]
--[[ 创建窗口弹出的动画 ]]
function XTHD.runActionPop(targetNode)
    targetNode:setScale(0)
    targetNode:runAction(cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.15, 1.1), 3),cc.EaseIn:create(cc.ScaleTo:create(0.1, 1), 3)))
end

function XTHD.runHidePop(targetNode)
    targetNode:runAction(cc.EaseIn:create(cc.ScaleTo:create(0.15, 0), 3))
end

function XTHD.updateProperty(data)

    for i = 1, #data do
        local property = string.split(data[i], ",")
        gameUser.updateDataById(property[1], property[2])
    end
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
end
----显示聊天面板
function XTHD.showChatroom(parent, chatBtn, where)
    if not parent then
        return
    end
	local scene = cc.Director:getInstance():getRunningScene()
	if scene:getChildByName("chat_room") then
		scene:getChildByName("chat_room"):removeFromParent()
	end
    -----聊天面板后的淡黑色背影
    if not scene:getChildByName("chat_room") then
        local zorder = chatBtn:getLocalZOrder() or 0
        local _layer = XTHDDialog:create()
        scene:addChild(_layer, 1)
        _layer:setTouchEndedCallback( function()
            -- local target = scene:getChildByName("chat_room")
            -- if target and target.__actionComplete then
            --     target:showPanel("exit")
            -- end
        end )
        local _color = cc.LayerColor:create(cc.c4b(0, 0, 0, 100), scene:getContentSize().width, scene:getContentSize().height)
        local room = LiaoTianRoomLayer:create(chatBtn, _color, _layer)
        if room then
            scene:addChild(_color)
            scene:addChild(room, zorder + 2)
            room:setName("chat_room")
            room:setTheFrom(where)

            XTHD.dispatchEvent( { name = EVENT_NAME_CHANGE_CHAT_REDDOT, data = { visible = false } })
            chatBtn:setLocalZOrder(zorder + 1)
        end
    else
        local target = scene:getChildByName("chat_room")
        if target then
            target:showPanel("exit")
        end
    end
end

--[[
所有涉及到添加道具或者获得道具的地方都应该统一使用该方法，方便以后修改
{
    callback = function() end,
    items     = {},
}
]]
function XTHD.saveItem(params)
    local callback = params.callback
    local items = params.items
    for i = 1, #items do
        local _temp_data = items[i]
        local itemData = gameData.getDataFromDynamicDB(gameUser.getUserId(), "item", { dbid = _temp_data.dbId })
        if itemData.dbid then
            DBTableItem.deleteData(gameUser.getUserId(), _temp_data.dbId)
            if tonumber(_temp_data.count) ~= 0 then
                _temp_data["baseProperty"] = _temp_data["property"]["baseProperty"] or ""
                _temp_data["strengLevel"] = _temp_data["property"]["strengLevel"] or 0
                _temp_data["phaseProperty"] = _temp_data["property"]["phaseProperty"] or ""
                _temp_data["phaseLevel"] = _temp_data["property"]["phaseLevel"] or 0
                DBTableItem.insertData(gameUser.getUserId(), _temp_data)
            end
        else
            if tonumber(_temp_data.count) ~= 0 then
                _temp_data["baseProperty"] = _temp_data["property"]["baseProperty"] or ""
                _temp_data["strengLevel"] = _temp_data["property"]["strengLevel"] or 0
                _temp_data["phaseProperty"] = _temp_data["property"]["phaseProperty"] or ""
                _temp_data["phaseLevel"] = _temp_data["property"]["phaseLevel"] or 0
                DBTableItem.insertData(gameUser.getUserId(), _temp_data)
            end
        end
    end
    if callback then
        callback()
    end
end
--[[ 同上 ]]
function XTHD.saveHero(params)
    local callback = params.callback
    local hero = params.hero
    -- TODO  存入数据库
    local save = true
    if save and callback then
        callback()
    end
end

--[[ 刷新用户数据的ui显示，包括主城和顶部信息 ]]
function XTHD.refreshUserInfoUI(params)
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TOP_INFO })
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO })
end
--[[
{
name = "xxx",
callback = function(event)
end
}
name:字符串，事件名称
callback:
    function (event)
    end)
]]
function XTHD.addEventListener(params)
    local eventName = params.name
    local callback = params.callback

    local custom_listener = cc.EventListenerCustom:create(eventName, callback)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(custom_listener, 1)
end

function XTHD.removeEventListener(eventName)
    cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(eventName)
end

--[[
添加在节点上的监听，如果传入node为nil，走XTHD.addEventListener
节点上的监听在节点被移掉的时候会自动移掉。
]]
function XTHD.addEventListenerWithNode(params)
    local eventName = params.name
    local callback = params.callback
    local node = params.node

    local custom_listener = cc.EventListenerCustom:create(eventName, callback)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    if node then
        eventDispatcher:addEventListenerWithSceneGraphPriority(custom_listener, node)
    else
        eventDispatcher:addEventListenerWithFixedPriority(custom_listener, 1)
    end
    -- if node == nil then
    --     XTHD.addEventListener(params)
    -- else
    --     local custom_listener = cc.EventListenerCustom:create(eventName,callback)
    --     local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    --     eventDispatcher:addEventListenerWithSceneGraphPriority(custom_listener, node)
    -- end
end

--[[
发送自定义的引擎消息
一般用于刷新数据
name: 事件名称
data:携带的数据(在接收时可以使用)

{
name = "xxx",
data = "xxx"
}
]]
function XTHD.dispatchEvent(params)
    local eventName = params.name
    local data = params.data

    local event = cc.EventCustom:new(eventName)
    event.data = data
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:dispatchEvent(event)
end

--[[
    XTHDTOAST那个方法改成走这里。
    之前的XTHDToast.lua写的太乱就拿出来了，效果一样。
]]
function XTHD._createToast(str)
    local function _ToastRecursion()
        _TOASTLIST[1]:runAction(cc.Spawn:create(cc.Sequence:create(cc.ScaleTo:create(0.15, 1.7), cc.ScaleTo:create(0.2, 1), cc.Spawn:create(cc.MoveBy:create(2.5, cc.p(0, 200)), cc.FadeOut:create(2.5)), cc.RemoveSelf:create()),
        cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create( function()
            table.remove(_TOASTLIST, 1)
            if #_TOASTLIST ~= 0 then
                _ToastRecursion()
            end
        end ))))
    end
    _TOASTLIST = _TOASTLIST or { }
	local node = cc.Director:getInstance():getNotificationNode()
    local target = cc.Sprite:create("res/image/common/toast_bg.png")

    local targetLabel = XTHDLabel:createWithParams( {
        text = str,
        fontSize = 22
    } )
    if targetLabel:getBoundingBox().width > 360 then
        target:initWithFile("res/image/common/toast_bg_long.png")
    end
    setAllChildrenCascadeOpacityEnabled(target)
    targetLabel:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(1, -1), 1)
    targetLabel:setPosition(target:getBoundingBox().width / 2, target:getBoundingBox().height / 2)
    target:addChild(targetLabel)
    local scene = cc.Director:getInstance():getRunningScene()
    target:setPosition(scene:getBoundingBox().width / 2, scene:getBoundingBox().height / 2 + 150)
    node:addChild(target, 100000)

    -- local handler = function(event)
    --     print("fklsdjflksjl"..event)
    --     if event == "cleanup" then
    --         print("Scene Exit")
    --         target:removeFromParent()
    --     end
    -- end
    -- --防止Scene变化时动画停止导致列表阻塞
    -- scene:registerScriptHandler(handler)

    -- target:setScale(0.5)
    -- _TOASTLIST[#_TOASTLIST+1] = target
    -- if #_TOASTLIST == 1 then
    --     _ToastRecursion()
    -- end

    target:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveBy:create(0.264, cc.p(0, 45)), 0.264), cc.DelayTime:create(1.760), cc.Spawn:create(cc.FadeOut:create(0.176), cc.MoveBy:create(0.176, cc.p(0, 35))), cc.RemoveSelf:create(true)))
end

-- 用来显示属性变化 类似于Toast
function XTHD.createAttrToast(num, attr, pos, propertyKey,parent,_colorType)
    local function _ToastRecursion()
        _ATTRTOASTLIST[1]:runAction(cc.Spawn:create(cc.Sequence:create(cc.ScaleTo:create(0.15, 1.7), cc.ScaleTo:create(0.2, 1), cc.Spawn:create(cc.MoveBy:create(2.5, cc.p(0, 200)), cc.FadeOut:create(2.5)), cc.RemoveSelf:create(), cc.CallFunc:create( function()
            table.remove(_ATTR_SP_LIST, 1)
        end )),
        cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
            table.remove(_ATTRTOASTLIST, 1)

            if #_ATTRTOASTLIST ~= 0 then
                _ToastRecursion()
            end
        end ))))
    end
    if num == 0 then
        return
    end
    _ATTRTOASTLIST = _ATTRTOASTLIST or { }
    _ATTR_SP_LIST = _ATTR_SP_LIST or { }
    -- local fntPath = "res/fonts/hongsezi.fnt"
    local fntColor = "GREEN"
    local _absNum = math.abs(num)
    if propertyKey ~= nil then
        _absNum = XTHD.resource.addPercent(tonumber(propertyKey), _absNum)
    end
    if num > 0 then
        num = "+" .. _absNum
        -- fntPath = "res/fonts/lvsezi.fnt"
        fntColor = "GREEN"
    else
        num = "-" .. _absNum
        -- fntPath = "res/fonts/hongsezi.fnt"
        fntColor = "RED"
    end

    local scene = cc.Director:getInstance():getRunningScene()
	local target = cc.Sprite:create()
	target:setContentSize(cc.size(scene:getBoundingBox().width, 0))
	pos = pos or cc.p(scene:getBoundingBox().width / 2, scene:getBoundingBox().height / 2 - 50)
	if not parent then
		pos = pos or cc.p(scene:getBoundingBox().width / 2, scene:getBoundingBox().height / 2 - 50)
		scene:addChild(target,10)
	else
		pos = cc.p(parent:getContentSize().width / 2, parent:getContentSize().height / 2)
		parent:addChild(target,10)
	end
	target:setPosition(pos)
	--scene:addChild(target)
    -- local target2 = cc.Label:createWithBMFont(fntPath,num)
	
    local target2 = XTHD.createLabel( {
        text = attr .. num,
        color = XTHD.resource.getColor(fntColor),
        fontSize = 22,
    } )
    target2:enableShadow(cc.c4b(0, 0, 0, 0), cc.size(1, -1))
	
	if _colorType then
		fntColor = "RED"
	else
		fntColor = "GREEN"
	end
    target2:enableOutline(XTHD.resource.getColor(fntColor), 0.5)
    -- label:setAnchorPoint(0,0.5)
    -- label:setPosition((target:getBoundingBox().width-(label:getBoundingBox().width+target2:getBoundingBox().width))/2,0)
    -- target:addChild(label)
    target2:setAnchorPoint(0.5, 0.5)
    target2:setPosition(target:getBoundingBox().width * 0.5, -7)
    -- target2:setPosition(label:getPositionX()+label:getBoundingBox().width,-7)
    target:addChild(target2,10)
    target:setName("AttrToast")
    _ATTR_SP_LIST[#_ATTR_SP_LIST + 1] = target

    setAllChildrenCascadeOpacityEnabled(target)
    target:setScale(0)
    _ATTRTOASTLIST[#_ATTRTOASTLIST + 1] = target
    if #_ATTRTOASTLIST == 1 then
        _ToastRecursion()
    end
end

function XTHD.createAttrToastByTable(params, pos,target,_colorType)
    -- num 数值 label前缀 pos位置(cc.p())
    _ATTRTOASTLIST = { }
    if _ATTR_SP_LIST and #_ATTR_SP_LIST > 0 then
        for i = 1, #_ATTR_SP_LIST do
            if _ATTR_SP_LIST[i] and _ATTR_SP_LIST[i].removeFromParent then
				_ATTR_SP_LIST[i] = nil
				--_ATTR_SP_LIST[i]:removeFromParent()
            end
        end
    end
    _ATTR_SP_LIST = { }
    for i = 1, #params do
        XTHD.createAttrToast(params[i].num, params[i].attr, pos, params[i].propertyKey,target,_colorType)
    end
end

--[[ 显示属性变化 ]]
function XTHD.createHeroBasePropertyToast(_oldHeroData, _newHeroData, _pos)
    local _propertyTable = XTHD.resource.getBasePropertyToastTable(_oldHeroData, _newHeroData)
    local tmpList = { }
    for i = 1, #_propertyTable do
        tmpList[#tmpList + 1] = {
            num = _propertyTable[i].num,
            attr = _propertyTable[i].label,
            propertyKey = _propertyTable[i].propertyKey,
        }
    end
    XTHD.createAttrToastByTable(tmpList, _pos)
    -- XTHD.createAttrToast(_propertyTable[i].num,XTHD.resource.getAttrLabel(_propertyTable[i].label),_pos)
    -- XTHD.createAttrToastByTable(_propertyTable,_pos)
end
--[[ 战斗力的改变动画 ]]
function XTHD._createFightLabelToast(params)
--	print("改变神器后服务器返回的数据为：")
--	print_r(params)
    local _defaultparams = {
        oldFightValue = 0,
        newFightValue = 0
    }
    for k, v in pairs(_defaultparams) do
        if not params[k] or params[k] == nil then
            params[k] = v
        end
    end

    local _fightUpValue = tonumber(params.newFightValue) - tonumber(params.oldFightValue)

    -- 数字变化多少次停止，45/60s
    local _sencondNum = 45

    -- local _changeValue = math.abs(_fightUpValue)>_sencondNum and math.abs(_fightUpValue) or _sencondNum
    local _changeValue = math.abs(_fightUpValue)
    local _changPath = "res/image/plugin/hero/hero_propertyadd.png"
    local _moveDistance = 20
    local _fightUpDownLabel = nil
    local _dowmDis = -3
    if tonumber(_fightUpValue) > 0 then
        _changeValue = math.ceil(_changeValue / _sencondNum)
        _changPath = "res/image/plugin/hero/hero_propertyadd.png"
        _moveDistance = -20
        _fightUpDownLabel = getCommonGreenBMFontLabel(math.abs(_fightUpValue))
        _fightUpDownLabel:setScale(0.7)
        _dowmDis = -3
    elseif tonumber(_fightUpValue) < 0 then
        _changeValue = - math.ceil(_changeValue / _sencondNum)
        _changPath = "res/image/plugin/hero/hero_propertysub.png"
        _moveDistance = 20
        _fightUpDownLabel = getCommonRedBMFontLabel(math.abs(_fightUpValue))
        _dowmDis = -7
    else
        return
    end

    local scene = cc.Director:getInstance():getRunningScene()
    local _fightBgSprite = nil
    if scene:getChildByName("fightBgSprite") then
        _fightBgSprite = scene:getChildByName("fightBgSprite")
        if _fightBgSprite:getChildByName("fightLabel") then
            local _fightLabel_pre = _fightBgSprite:getChildByName("fightLabel")
            if _fightLabel_pre:getScheduler() then
                _fightLabel_pre:unscheduleUpdate()
            end
            _fightLabel_pre:removeFromParent()
        end
        _fightBgSprite:stopAllActions()
        _fightBgSprite:removeAllChildren()
        _fightBgSprite:removeFromParent()
    end
    _fightBgSprite = XTHD.createSprite("res/image/common/toast_bg.png")
    _fightBgSprite:setCascadeOpacityEnabled(true)
    _fightBgSprite:setName("fightBgSprite")
    _fightBgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    _fightBgSprite:setPosition(scene:getBoundingBox().width / 2, scene:getBoundingBox().height / 2 + 230)
    scene:addChild(_fightBgSprite)

    -- 战力值变化
    local _fightLabel = getCommonYellowBMFontLabel(params.oldFightValue)
    -- XTHDLabel:create(params.oldFightValue,20)
    _fightLabel:setName("fightLabel")
    _fightLabel:setAnchorPoint(cc.p(0.5, 0.5))
    _fightLabel:setPosition(cc.p(_fightBgSprite:getBoundingBox().width / 2, _fightBgSprite:getBoundingBox().height / 2 - 7))
    _fightBgSprite:addChild(_fightLabel)

    -- 战力两个字
    local _fightTitle = XTHD.createSprite("res/image/common/fightToastTitle.png")
    -- _fightTitle:setScale(0.7)
    _fightTitle:setAnchorPoint(cc.p(1, 0.5))
    _fightTitle:setPosition(cc.p(_fightLabel:getPositionX() - _fightLabel:getBoundingBox().width / 2 - 5, _fightBgSprite:getBoundingBox().height / 2))
    _fightBgSprite:addChild(_fightTitle)

    -- 上升箭头
    local _fightUpDownSpr = XTHD.createSprite(_changPath)
    _fightUpDownSpr:setAnchorPoint(cc.p(0, 0.5))
    _fightUpDownSpr:setPosition(cc.p(_fightLabel:getPositionX() + _fightLabel:getBoundingBox().width / 2 + 10, _fightTitle:getPositionY() + _moveDistance))
    _fightBgSprite:addChild(_fightUpDownSpr)
    _fightUpDownSpr:setOpacity(0)
    -- 上升值
    _fightUpDownLabel:setAnchorPoint(cc.p(0, 0.5))

    _fightUpDownLabel:setPosition(cc.p(_fightUpDownSpr:getPositionX() + _fightUpDownSpr:getBoundingBox().width + 5, _fightTitle:getPositionY() + _moveDistance + _dowmDis))
    _fightBgSprite:addChild(_fightUpDownLabel)

    _fightUpDownLabel:setOpacity(0)
    local _anitime = 0.3
    local _upAnimation = cc.Sequence:create(cc.DelayTime:create(0.3)
    , cc.Spawn:create(cc.MoveBy:create(_anitime, cc.p(0, - tonumber(_moveDistance)))
    , cc.FadeIn:create(_anitime)))
    local _sprAnimation = cc.Sequence:create(cc.DelayTime:create(0.3)
    , cc.Spawn:create(cc.MoveBy:create(_anitime, cc.p(0, - tonumber(_moveDistance)))
    , cc.FadeIn:create(_anitime)))

    _fightUpDownSpr:runAction(_sprAnimation)
    _fightUpDownLabel:runAction(_upAnimation)

    _fightBgSprite:setScale(2.5)
    _fightBgSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.8), cc.ScaleTo:create(0.1, 1.0)
    , cc.DelayTime:create(1.5), cc.FadeOut:create(0.5)
    , cc.CallFunc:create( function()
        _fightBgSprite:removeAllChildren()
        _fightBgSprite:removeFromParent()
    end )))

    local _cd = 0.7
    local _dtTime = 0
    _fightLabel:scheduleUpdateWithPriorityLua( function(dt)
        _dtTime = _dtTime + dt
        if _dtTime < _cd then
            return
        end
        local _num = tonumber(_fightLabel:getString()) + tonumber(_changeValue)
        _fightLabel:setString(tostring(_num))
        if math.abs(tonumber(params.oldFightValue) - tonumber(_fightLabel:getString())) >= math.abs(_fightUpValue) or tonumber(_fightLabel:getString()) <= 0 then
            _fightLabel:setString(tostring(params.newFightValue))
            _fightLabel:unscheduleUpdate()
            return
        end
    end , 0)

    local handler = function(event)
        if event == "exit" then
            if scene:getChildByName("fightBgSprite") and scene:getChildByName("fightBgSprite"):getChildByName("fightLabel") then
                local _label = scene:getChildByName("fightBgSprite"):getChildByName("fightLabel")
                if _label:getScheduler() then
                    _label:unscheduleUpdate()
                end
            end
        end
    end
    -- 防止Scene变化时动画停止导致列表阻塞
    scene:registerScriptHandler(handler)
end

--[[
    顺序创建N个Toast 相互不重叠
]]
function XTHD.createToastList(toastList, duration)
    duration = duration or 0.4
    if #toastList ~= 0 then
        XTHDTOAST(toastList[1])
        table.remove(toastList, 1)
    end
    local scene = cc.Director:getInstance():getRunningScene()
    scene:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create( function()
        XTHD.createToastList(toastList, duration)
    end )))
end


-- 解析装备属性
function XTHD.getEquipPropertyData(_data)
    local _propertyData = { }
    if _data == nil or next(_data) == nil then
        return _propertyData
    end
    for i = 1, 22 do
        local _propertyNum = XTHD.resource.AttributesNum[i]
        local _propertyKey = XTHD.resource.AttributesName[tonumber(_propertyNum)]
        local _propertyName = LANGUAGE_KEY_ATTRIBUTESNAME(tostring(_propertyNum))
        local _propertyStr = _data[tostring(_propertyKey)]
        if _propertyStr and tostring(_propertyStr) ~= "0" then
            local _propertyTable = string.split(_propertyStr, '#') or { }
            local _table = { }
            _table.name = _propertyName
            _table.propertyValue = _propertyTable
            _table.propertyNum = _propertyNum
            _propertyData[#_propertyData + 1] = _table
        end

    end
    return _propertyData
end
-- 解析英雄属性
function XTHD.getHeroPropertyData(_data)
    local _propertyData = { }
    if _data == nil or next(_data) == nil then
        return _propertyData
    end
    for i = 1, 22 do
        local _color = "shenhese"
        -- "lvse"
        if i < 6 then
            _color = "shenhese"
        end
        local _propertyNum = XTHD.resource.AttributesNum[i]
        local _propertyKey = XTHD.resource.AttributesName[tonumber(_propertyNum)]
        local _propertyName = LANGUAGE_KEY_DETAILINFONAME(tostring(_propertyNum))
        local _propertyValue = _data[tostring(_propertyKey)]
        if _propertyValue and tonumber(_propertyValue) > 0 then
            local _table = { }
            _table.name = _propertyName
            _table.propertyValue = _propertyValue
            _table.propertyNum = _propertyNum
            _table._color = _color
            _propertyData[#_propertyData + 1] = _table
        end

    end
    return _propertyData
end

-- 关卡图标
function XTHD.createChapterIcon(params)
    local _defaultParams = {
        _bossHeroid = 1,
        _star = 0,
    }
    for k, v in pairs(_defaultParams) do
        if not params[k] then
            params[k] = v
        end
    end
    local _icon_bg = cc.Sprite:create("res/image/plugin/stageChapter/boss_avator_bg.png")
    _icon_bg:setOpacity(0)
    if tonumber(params._bossHeroid) < 1 then
        return _icon_bg
    end

    local avator_sp = cc.Sprite:create(XTHD.resource.getHeroAvatarImgPath( { _type = 2, heroid = params._bossHeroid }))
    avator_sp:setPosition(avator_sp:getContentSize().width / 2, avator_sp:getContentSize().height / 2)
    _icon_bg:addChild(avator_sp)

    local sword_sp = cc.Sprite:create("res/image/plugin/stageChapter/boss_avator_sword.png")
    sword_sp:setPosition(avator_sp:getContentSize().width / 2, sword_sp:getContentSize().height / 2 - 10)
    sword_sp:setOpacity(0)
    _icon_bg:addChild(sword_sp)

    if params._star then
        for i = 1, tonumber(params._star) do
            local _star_sp = cc.Sprite:create("res/image/common/item_star.png")
            _star_sp:setPosition(sword_sp:getContentSize().width / 2 +(i - 2) * 28.5, 16)
            _star_sp:setScale(1.5)
            sword_sp:addChild(_star_sp)
        end
    end
    return _icon_bg
end
function XTHD.getTimeHMS(time, needHour)
    local H = math.floor(time / 3600)
    local M = math.floor(time / 60 - H * 60)
    local S = math.floor(time % 60)
    local showH = 0
    local showM = 0
    local showS = 0
    if H <= 9 then
        showH = "0" .. H
    else
        showH = H
    end
    if M <= 9 then
        showM = "0" .. M
    else
        showM = M
    end
    if S <= 9 then
        showS = "0" .. S
    else
        showS = S
    end
    local timeStr = "00:00"
    if M == 0 then
        timeStr = "00:" .. showS
    else
        timeStr = showM .. ":" .. showS
    end

    if H > 0 and needHour ~= nil and needHour == true then
        timeStr = showH .. ":" .. timeStr
    end
    return timeStr
end


function XTHD.requirePayID(payInfo,_parent)
     ClientHttp:requestAsyncInGameWithParams({
            modules = "payFinish?",
            params = payInfo, -- 参数
            successCallback = function(data)
            --获取奖励成功
            if data and tonumber(data.result) == 0 then
                local needShowVip = false
                local show = {} --奖励展示
                if type(data) == "table" and data["property"] then
                    for i=1,#data["property"] do
                        local pro_data = string.split( data["property"][i],',')
                        --如果奖励类型存在，而且不是vip升级(406)则加入奖励
                        if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
                            local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
                            if getNum > 0 then
                                local idx = #show + 1
                                show[idx] = {}
                                show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
                                show[idx].num = getNum
                            end
                        end
                        DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2])
                        if tonumber(pro_data[1]) == 406 then --vip升级
                            needShowVip = true
                        end
                        if tonumber(pro_data[1]) == 403 then --元宝
                            gameUser.setIngot(tonumber(pro_data[2]))
                        end
                    end
                end
                if type(data) == "table" and data["itemList"] then
                    for i=1,#data["itemList"] do
                        local item = data["itemList"][i]
--                        dump(item)
                        local showCount = 0
                        if item.count and tonumber(item.count) ~= 0 then
                            showCount = item.count - tonumber(DBTableItem.getCountByID(item.dbId));
                            DBTableItem.updateCount(gameUser.getUserId(),item,item.dbId)
                        else
                            DBTableItem.deleteData(gameUser.getUserId(),item.dbId)
                        end
                        if showCount > 0 then
                            --如果奖励类型
                            local idx = #show + 1
                            show[idx] = {}
                            show[idx].rewardtype = 4 -- 4
                            show[idx].id = item.itemId
                            show[idx].num = showCount
                        end
                    end
                end
                ShowRewardNode:create(show)
                --设置银两、翡翠兑换次数
                if data["silverSurplusSum"] and data["feicuiSurplusSum"] then
                    gameUser.setGoldSurplusExchangeCount(data["silverSurplusSum"])
                    gameUser.setFeicuiSurplusExchangeCount(data["feicuiSurplusSum"])
                    gameUser.setIngotTotal(data["totalIngot"])
                end
                XTHDTOAST(LANGUAGE_KEY_RECHARGE_CONGRATULATIONS)
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_VIP_MSG})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG})
                if needShowVip then
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_VIP_SHOW})
                end
				_parent:updateCell()
            else
            end
            end,--成功回调
            failedCallback = function()
            end,--失败回调
            timeoutForConnect = 15,
            timeoutForRead = 20,
            reconnectTimes = 5,
        })
end

--支付
function XTHD.pay(item_data,isLimitGift,_parent)
    --IsLimit: 1.充值界面  2.限时礼包  3.成长基金 4.月卡至尊卡
    local IsLimit = isLimitGift or 1

    item_data.needGold = item_data.needGold == nil and item_data.yuanbao1 or item_data.needGold
    item_data.needRMB = item_data.needRMB == nil and item_data.rmb or item_data.needRMB
    item_data.configId = item_data.configId == nil and item_data.id or item_data.configId
    item_data.configType = item_data.configType == nil and item_data.typeA or item_data.configType

    local payInfo = {
        localTest     = tostring("false"),
        orderId       = tostring("1"),
        cpOrderId     = tostring("1"),
        addGold       = tostring(item_data.needGold),
        charId        = tostring(gameUser.getUserId()),
        platfromId    = tostring("1"),
        payConfigId   = tostring(item_data.configId),
        type          = tostring(item_data.configType),
    } 

    local CallbackSuccLua = function()
        print("------------支付成功回调-----------------")
        local node = cc.Director:getInstance():getNotificationNode()
        performWithDelay(node,function()
             -- XTHD.requirePayID(payInfo,_parent)
            local PayCall = XTHD.doPayFinish(payInfo,_parent,IsLimit)
            PayCall()
        end,1)
    end
    
    local CallbackFailedLua = function()
        print("------------支付失败回调-----------------")
        local node = cc.Director:getInstance():getNotificationNode()
        performWithDelay(node,function()
             XTHDTOAST(LANGUAGE_KEY_PAY_FAILED)
        end,1)
    end

    local payString = ""
    local buyNum = 0
    if item_data.configType == 1 then
        payString = "购买月卡"
        buyNum = 1
    elseif item_data.configType == 2 then
        payString = "购买至尊卡"
        buyNum = 1
    elseif item_data.configType == 3 then
        payString = "购买"..tostring(item_data.needGold).."元宝"
        buyNum = item_data.needGold
    elseif item_data.configType == 4 then
        payString = "购买限时礼包"
        buyNum = 1
    elseif item_data.configType == 5 then
        payString = "购买成长基金"
        buyNum = 1
    end

    local data = nil

    local serverPayData = {
        needGold      = tostring(item_data.needGold),
        payConfigId   = tostring(item_data.configId),
        roleid        = tostring(gameUser.getUserId()),
        serverid      = tostring(gameUser.getServerId()),
        passportId    = tostring(gameUser._passportID)
    } 

    print("CHANNEL_CODE_DEFINE: "..tostring(GAME_CHANNEL))

    if GAME_CHANNEL == CHANNEL_CODE_Define then -- 本地测试支付接口
        payInfo.localTest = tostring("true"),
        print("本地测试计费: ----------"..payString)
        print_r(payInfo)
        local testPayCall = XTHD.doPayFinish(payInfo,_parent,IsLimit)
        testPayCall()
        return
    end

    if GAME_CHANNEL == CHANNEL_CODE_XT or GAME_CHANNEL == CHANNEL_CODE_XG or GAME_CHANNEL == CHANNEL_CODE_Define then
        data = {
            roleId        = tostring(gameUser.getUserId()),
            money         = tostring(item_data.needRMB),
            serverId      = tostring(gameUser.getServerId()),
            productname   = payString,
            productdesc   = tostring(""),
            attach        = json.encode(serverPayData)
        }
    elseif GAME_CHANNEL == CHANNEL_CODE_JW then
        data = {
            money         = tostring(item_data.needRMB),
            roleId        = tostring(gameUser.getUserId()),
            roleName      = tostring(gameUser.getNickname()),
            roleLevel     = gameUser.getLevel(),
            serverId      = tostring(gameUser.getServerId()),
            serverName    = tostring(gameUser.getServerName()),
            level = tostring(gameUser.getLevel()),
            guildName = tostring(gameUser.getGuildName()),

            productname   = payString,
            cpOrderID     = tostring("201805280101002568"),
            count         = tostring("1"),
            extend        = json.encode(serverPayData),
            goodsID       = tostring("1"),
            vip           = tostring(gameUser.getVip()),
            ingot         = tostring(gameUser.getIngot()),
            partyName     = tostring("gaibang"),
            roleCreateTime= tostring("0"),
        }
    elseif GAME_CHANNEL == CHANNEL_CODE_SY then
        data = {
            roleId        = tostring(gameUser.getUserId()),
            roleName      = tostring(gameUser.getNickname()),
            money         = tostring(item_data.needRMB),
            serverId      = tostring(gameUser.getServerId()),
            serverName    = tostring(gameUser.getServerName()),
            productname   = payString,
            productdesc   = "价格实惠，赶紧买起",
            productid     = item_data.configId,
            buyNum        = buyNum,
            uid           = gameUser.getSYUserID(),
            level         = gameUser.getLevel(),
        }
    end

    local arg = data
    local sig = nil
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        local tmp = json.encode(data)
        arg = { tmp , CallbackSuccLua, CallbackFailedLua }  --[[--此处需要json.encode转换成字符串，否则java端获取到的是null]]
        sig = "(Ljava/lang/String;II)V"
    else
        arg = {roleId=tostring(gameUser.getUserId()),roleName=tostring(gameUser.getNickname()),money=tostring(item_data.needRMB),serverId=tostring(gameUser.getServerId()),serverName=tostring(gameUser.getServerName()),productname=payString,productdesc="价格实惠，赶紧买起",productid=AppStoreGoods[tonumber(item_data.configId)],itemid=item_data.configId,buyNum=buyNum,uid=gameUser.getSYUserID(),level=gameUser.getLevel(),successCallback = CallbackSuccLua,errorCallback = CallbackFailedLua}
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS,"pay",arg,sig)
    print("----------------支付回调函数----------------")
end

-- 一般登录逻辑
function XTHD.login(param)

    local logoffCallback = function(param)
        print("----------------logoffCallback 登出回调函数----------------")
        MsgCenter:reset()
        ------断开Socket
        print("----------------logoffCallback 0----------------")
        isLoginFlag = false
        print("----------------logoffCallback 1----------------")
        XTHD.replaceToLoginScene()
        print("----------------logoffCallback 2----------------")
    end
    local data = { logoutcallback = logoffCallback }

    local arg = param
    local sig = nil
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        arg = { param.callback }
        sig = "(I)V"
    elseif platform == cc.PLATFORM_OS_IPHONE or cc.PLATFORM_OS_IPAD or cc.PLATFORM_OS_MAC then
        arg = { Callback = param.callback, logoutCB = data.logoutcallback }
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS, "login", arg, sig)
    print("----------------注册登录回调函数----------------")
end

function XTHD.switchAccount()
    local arg = { }
    local sig = nil
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        sig = "()V"
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS, "switchAccount", arg, sig)
    print("---------------切换账号----------------")
end

-- 在切换用户时 有的平台会自动弹出登录界面 所在只需传递登录回调函数 不要再调用登录界面
function XTHD.switchUserNotShowLoginUI(param)
    local arg = param
    local sig = nil
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        arg = { param.callback }
        sig = "(I)V"
    elseif platform == cc.PLATFORM_OS_IPHONE or cc.PLATFORM_OS_IPAD or cc.PLATFORM_OS_MAC then
        arg = { Callback = param.callback }
        return
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS, "switchUserNotShowLoginUI", arg, sig)
    print("----------------切换用户登录回调函数----------------")
end

function XTHD.uploadPlayerInfo(_type)
    local data = {
        dataType = _type,   --数据类型：1：进入游戏；2：创建角色；3：角色升级；4：游戏退出
        uid = gameUser.getSYUserID(),
        roleId = tostring(gameUser.getUserId()),
        guildName = tostring(gameUser.getGuildName()),
        level = tostring(gameUser.getLevel()),
        serverId = tostring(gameUser.getServerId()),
        serverName = tostring(gameUser.getServerName()),
        vip = tostring(gameUser.getVip()),
        roleName = tostring(gameUser.getNickname()),
        roleLevel = tostring(gameUser.getLevel()),
        roleParty = tostring(gameUser._guildName) ~= "" and tostring(gameUser._guildName) or tostring(LANGUAGE_KEY_CHAT_NONEBP),
        roleCreateTime = gameUser.getRoleCreateTime(),
        ingot = tostring(gameUser.getIngot()),
    }
    local platform = cc.Application:getInstance():getTargetPlatform()
    local args = { }
    local sigs = nil
    if platform == cc.PLATFORM_OS_ANDROID then
        -- 玩家角色ID，玩家角色名，玩家角色等级，游戏区服ID,游戏服务器名字,vip
        local _param = json.encode(data)
        args = { _param }
        sigs = "(Ljava/lang/String;)V"
    elseif platform == cc.PLATFORM_OS_IPHONE or cc.PLATFORM_OS_IPAD or cc.PLATFORM_OS_MAC then
        args = { ingot = data.ingot, guildName = data.guildName, serverId = data.serverId, serverName = data.serverName, roleName = data.roleName, uid = data.uid, level = data.level, vip = data.vip }
        return
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS, "uploadPlayerInfo", args, sigs)
end

-- 一般登出逻辑
function XTHD.logout()
    local node = cc.Director:getInstance():getNotificationNode()
    node:stopActionByTag(9999)
    isLoginUC = false
    local logoutCallback = function(param)
        -- print("----------------logoutCallback 登出回调函数----------------")
        -- MsgCenter:reset()
        -- ------断开Socket
        -- print("----------------logoutCallback 0----------------")
        -- isLoginFlag = false
        -- print("----------------logoutCallback 1----------------")
        -- XTHD.replaceToLoginScene()
        -- print("----------------logoutCallback 2----------------")
        print("----------------switchCallback 切换账号回调函数----------------")
        print("CTX_log渠道登录返回的参数为：")
        print_r(param)
        isNotShowLoginUI = true --切换账号有的平台自己会调用登录界面  所以在初始化登录界面时不需要调用
        if param ~= nil and param ~= "" then
            isLoginFlag = false
            isNotShowLoginUI = false
            if LayerManager.isLayerOpen(2) ~= nil then
                local node = LayerManager.isLayerOpen(2)
                node:loginUserCenter({data = param})
            end
        end
    --     if isLoginFlag then
    --         if param ~= nil and param ~= "" then
    --             isLoginFlag = true
    --             isNotShowLoginUI = true
    --             if LayerManager.isLayerOpen(2) ~= nil then
    --                 local node = LayerManager.isLayerOpen(2)
    --                 node:loginUserCenter({data = param})
    --             end
    --         end
    --     else
    --         ClientHttp:requestAsyncInGameWithParams({
    --             modules = "exit?",
    --             successCallback = function() 
    --                 print("向服务器请求退出成功--------------------------------------------------")  
    --                 MsgCenter:reset() 
    --                 -- XTHD.logout()
    --                 cc.Director:getInstance():popToRootScene()
    --                 XTHD.replaceToLoginScene()
    --                 gameUser.setToken(nil)
    --                 gameUser.setNewLoginToken(nil)
    --             end,
    --             failedCallback = function() 
    --                 print("向服务器请求退出失败--------------------------------------------------")
    --                 MsgCenter:reset() 
    --                 -- XTHD.logout()
    --                 cc.Director:getInstance():popToRootScene()
    --                 XTHD.replaceToLoginScene()
    --                 gameUser.setToken(nil)
    --                 gameUser.setNewLoginToken(nil)
    --             end,--失败回调
    --             loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
    --         })
    --     end
    end

    local data = { callback = logoutCallback }
    local arg = { }
    local sig = nil
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        arg = { data.callback }
        sig = "(I)V"
    elseif platform == cc.PLATFORM_OS_IPHONE or cc.PLATFORM_OS_IPAD or cc.PLATFORM_OS_MAC then
        arg = { Callback = data.callback }
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS, "logOut", arg, sig)
    print("----------------注册登出回调函数----------------")
end

-- 一般游戏返回键 暂时不用
function XTHD.gameBack()
    local arg = { }
    local sig = nil
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        sig = "()V"
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS, "gameBackKey", arg, sig)
    print("----------------游戏返回键----------------")
end


-- 一般玩家退出游戏
function XTHD.gameExit()
    local arg = { }
    local sig = nil
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        sig = "()V"
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS, "exitGame", arg, sig)
    print("----------------退出游戏---------------")
end


function XTHD.createPowerShowSprite(_powerValue)
    -- 战斗力
    local fight_bg = cc.Sprite:create("res/image/common/zl_bg.png")

    local fight_label = XTHDLabel:createWithParams( { fnt = "res/image/common/common_num/yellowwordforcamp.fnt", text = _powerValue or 0, kerning = - 2 })
    fight_label:setScale(0.7)
    fight_label:setName("fight_label")
    fight_label:setAnchorPoint(0, 0.5)
    fight_label:setPosition(cc.p(fight_bg:getContentSize().width *0.5 - 25, fight_bg:getContentSize().height / 2 - 5))
    fight_bg:addChild(fight_label)

    return fight_bg
end

function XTHD.refreshPowerShowSprite(_powerTarget, _powerValue)
    if _powerTarget == nil then
        return
    end
    local _value = _powerValue or 0
    local _fightBg = _powerTarget
    local _fightLabel = _fightBg:getChildByName("fight_label")
    if _fightLabel == nil then
        return
    end
    _fightLabel:setString(_value)
    _fightLabel:setPosition(cc.p(_fightBg:getContentSize().width *0.5 - 25, _fightBg:getContentSize().height / 2 - 5))
end

function XTHD.createHeroNameShowSprite(_nameStr, _advanceValue, _heroid)
    local heroRankTab = XTHD.resource.getRankColor_number(_advanceValue or 0, _heroid)
    local _imgPath = "res/image/plugin/hero/heroName_" ..(heroRankTab.colorStr or "white") .. ".png"
    local heroname_bg = cc.Sprite:create(_imgPath)

    local heroname_label = XTHDLabel:create(_nameStr or "", 18, "res/fonts/def.ttf")
    heroname_label:setName("heroname_label")

    -- heroname_label:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
    heroname_label:setAnchorPoint(0.5, 0.7)
    heroname_bg:addChild(heroname_label)
    local nameAdvance_label = XTHDLabel:create(heroRankTab["addNumberStr"] or "", 22)
    nameAdvance_label:setName("nameAdvance_label")
    -- nameAdvance_label:enableShadow(heroRankTab["color"],cc.size(0.4,-0.4),0.4)
    nameAdvance_label:setAnchorPoint(cc.p(0, 0.5))
    -- nameAdvance_label:setColor(heroRankTab["color"])
    heroname_bg:addChild(nameAdvance_label)

    if heroRankTab.colorStr == "green" then
        heroname_label:enableOutline(cc.c4b(21, 102, 82, 255), 2)
        nameAdvance_label:setColor(cc.c4b(21, 102, 82, 255))
    elseif heroRankTab.colorStr == "blue" then
        heroname_label:enableOutline(cc.c4b(21, 33, 105, 255), 2)
        nameAdvance_label:setColor(cc.c4b(21, 33, 105, 255))
    elseif heroRankTab.colorStr == "purple" then
        heroname_label:enableOutline(cc.c4b(80, 21, 105, 255), 2)
        nameAdvance_label:setColor(cc.c4b(80, 21, 105, 255))
    elseif heroRankTab.colorStr == "orange" then
        heroname_label:enableOutline(cc.c4b(166, 80, 29, 255), 2)
        nameAdvance_label:setColor(cc.c4b(166, 80, 29, 255))
    else
        heroname_label:enableOutline(cc.c4b(200,0,4,255), 2)
        nameAdvance_label:setColor(cc.c4b(255, 255, 255, 255))
    end

    local _namePosX = heroname_bg:getContentSize().width / 2
    if string.len(heroRankTab["addNumberStr"]) < 1 then
        _namePosX = heroname_bg:getContentSize().width / 2
    else
        _namePosX = heroname_bg:getContentSize().width / 2 - 3 / 2 - nameAdvance_label:getContentSize().width / 2
    end
    heroname_label:setPosition(cc.p(_namePosX, heroname_bg:getContentSize().height / 2 + 5))
    nameAdvance_label:setPosition(cc.p(heroname_label:getBoundingBox().x + heroname_label:getBoundingBox().width + 3, heroname_label:getPositionY() - 4))
    return heroname_bg
end

function XTHD.refreshHeroNameShowSprite(_heronameTarget, _nameStr, _advanceValue, _heroid)
    if _heronameTarget == nil then
        return
    end
    local heroRankTab = XTHD.resource.getRankColor_number(_advanceValue or 0, _heroid)
    local _imgPath = "res/image/plugin/hero/heroName_" ..(heroRankTab.colorStr or "white") .. ".png"
    local _heroNameBg = _heronameTarget
    local _heroname_label = _heroNameBg:getChildByName("heroname_label")
    local _nameadvance_label = _heroNameBg:getChildByName("nameAdvance_label")

    _heroNameBg:initWithFile(_imgPath)
    _heroNameBg:setAnchorPoint(cc.p(0.5, 0))
    _heroname_label:setString(_nameStr)



    _nameadvance_label:setString(heroRankTab["addNumberStr"] or "")
    -- _nameadvance_label:setColor(heroRankTab["color"])
    -- _nameadvance_label:enableShadow(heroRankTab["color"],cc.size(0.4,-0.4),0.4)
    local _namePosX = _heroNameBg:getContentSize().width / 2
    if string.len(heroRankTab["addNumberStr"]) < 1 then
        _namePosX = _heroNameBg:getContentSize().width / 2
    else
        _namePosX = _heroNameBg:getContentSize().width / 2 - 3 / 2 - _nameadvance_label:getContentSize().width / 2
    end
    _heroname_label:setPosition(cc.p(_namePosX, _heroNameBg:getContentSize().height / 2 + 5))
    _nameadvance_label:setPosition(cc.p(_heroname_label:getBoundingBox().x + _heroname_label:getBoundingBox().width + 3, _heroname_label:getPositionY() - 4))

    if heroRankTab.colorStr == "green" then
        _heroname_label:enableOutline(cc.c4b(21, 102, 82, 255), 2)
        _nameadvance_label:setColor(cc.c4b(21, 102, 82, 255))
    elseif heroRankTab.colorStr == "blue" then
        _heroname_label:enableOutline(cc.c4b(21, 33, 105, 255), 2)
        _nameadvance_label:setColor(cc.c4b(21, 33, 105, 255))
    elseif heroRankTab.colorStr == "purple" then
        _heroname_label:enableOutline(cc.c4b(80, 21, 105, 255), 2)
        _nameadvance_label:setColor(cc.c4b(80, 21, 105, 255))
    elseif heroRankTab.colorStr == "orange" then
        _heroname_label:enableOutline(cc.c4b(166, 80, 29, 255), 2)
        _nameadvance_label:setColor(cc.c4b(166, 80, 29, 255))
    else
        _heroname_label:enableOutline(cc.c4b(200,0,4,255), 2)
        _nameadvance_label:setColor(cc.c4b(255, 255, 255, 255))
    end
end

function XTHD.getPropertyValueByTurn(_data)
    if _data == nil then
        return { }
    end
    local _propertyData = _data
    _propertyData["hp"] = tonumber(_propertyData.property["200"]) or 0;
    -- hp
    _propertyData["physicalattack"] = tonumber(_propertyData.property["201"]) or 0;
    -- physicalattack
    _propertyData["physicaldefence"] = tonumber(_propertyData.property["202"]) or 0;
    -- physicaldefence
    _propertyData["manaattack"] = tonumber(_propertyData.property["203"]) or 0;
    -- manaattack
    _propertyData["manadefence"] = tonumber(_propertyData.property["204"]) or 0;
    -- manadefence
    _propertyData["hit"] = tonumber(_propertyData.property["300"]) or 0;
    -- hit
    _propertyData["dodge"] = tonumber(_propertyData.property["301"]) or 0;
    -- dodge
    _propertyData["crit"] = tonumber(_propertyData.property["302"]) or 0;
    -- crit
    _propertyData["crittimes"] = tonumber(_propertyData.property["303"]) or 0;
    -- crittimes
    _propertyData["anticrit"] = tonumber(_propertyData.property["304"]) or 0;
    -- anticrit
    _propertyData["antiattack"] = tonumber(_propertyData.property["305"]) or 0;
    -- antiattack
    _propertyData["attackbreak"] = tonumber(_propertyData.property["306"]) or 0;
    -- attackbreak
    _propertyData["antiphysicalattack"] = tonumber(_propertyData.property["307"]) or 0;
    -- antiphysicalattack
    _propertyData["physicalattackbreak"] = tonumber(_propertyData.property["308"]) or 0;
    -- physicalattackbreak
    _propertyData["antimanaattack"] = tonumber(_propertyData.property["309"]) or 0;
    -- antimanaattack
    _propertyData["manaattackbreak"] = tonumber(_propertyData.property["310"]) or 0;
    -- manaattackbreak
    _propertyData["suckblood"] = tonumber(_propertyData.property["311"]) or 0;
    -- suckblood
    _propertyData["heal"] = tonumber(_propertyData.property["312"]) or 0;
    -- heal
    _propertyData["behealed"] = tonumber(_propertyData.property["313"]) or 0;
    -- behealed
    _propertyData["antiangercost"] = tonumber(_propertyData.property["314"]) or 0;
    -- antiangercost
    _propertyData["hprecover"] = tonumber(_propertyData.property["315"]) or 0;
    -- hprecover
    _propertyData["angerrecover"] = tonumber(_propertyData.property["316"]) or 0;
    -- angerrecover
    return _propertyData
end

function XTHD.displayCampWarTips(what)
    -----显示阵营战提示
    local _layer = requires("src/fsgl/layer/ZhongZu/WarTipsLayer1.lua"):create(false, what)
    local _parent = cc.Director:getInstance():getNotificationNode()
    if _parent then
        _parent:addChild(_layer)
        return what
    end
    return 0
end

function XTHD.getTimeStrBySecond(_second)
    if _second == nil then
        return
    end
    local _timeStr = ""
    local _second_ = tonumber(_second)
    if _second < 60 then
        _timeStr = LANGUAGE_CHAT_TIME8(1)
    elseif _second < 3600 then
        _timeStr = LANGUAGE_CHAT_TIME8(math.floor(_second_ / 60))
        -- 1分钟前
    elseif _second < 3600 * 24 then
        _timeStr = LANGUAGE_CHAT_TIME9(math.floor(_second_ / 3600))
        -- 1小时前
    elseif _second < 3600 * 24 * 7 then
        _timeStr = LANGUAGE_CHAT_TIME10(math.floor(_second_ / 86400))
        -- 天前
    else
        _timeStr = LANGUAGE_CHAT_TIME13(7)
        -- 超过7天
    end
    return _timeStr
end

-----创建运镖界面
function XTHD.YaYunLiangCaoLayer(sNode, callBack)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "getDartList?",
        params = { },
        successCallback = function(data)
            if data.result == 0 then
                if callBack then
                    callBack()
                end
                LayerManager.addShieldLayout()
                local YaYunLiangCaoLayer = requires("src/fsgl/layer/YaYunLiangCao/YaYunLiangCaoLayer.lua"):create(data)
                LayerManager.addLayout(YaYunLiangCaoLayer)
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            ------"网络请求失败")
        end,
        -- 失败回调
        loadingParent = sNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function XTHD.GodDiceLayer(sNode)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "openDestiny?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                local _destinyDicelayer = requires("src/fsgl/layer/RiChangRenWu/RiChangRenWuDestinyDiceLayer.lua"):create(data, sNode)
                LayerManager.addLayout(_destinyDicelayer)
            else
                XTHDTOAST(data.msg)
            end
        end,
        -- 成功回调
        loadingParent = sNode,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            -----"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function XTHD.createFunctionLayer(_size)
    local _rectSize = _size
    if _rectSize == nil then
        _rectSize = cc.size(420, 264)
    end
    local layer_sp = XTHDSprite:createWithTexture(nil, cc.rect(0, 0, _rectSize.width, _rectSize.height))
    layer_sp:setOpacity(0)
    return layer_sp
end

-- 返回消耗材料table，装备强化过后的数据。
function XTHD.getEquipStrengthCostItems(params)
    --[=[
    local _default = {
        backStrengthLevel = true,       --是否返回强化后的等级
        equipmentsTable = {             --需要强化的装备列表
            quality = 1,
            strengLevel = 1,
        },
        itemsData = {}                  --DBTableItem动态数据

    }
    ]=]
    local _equipmentsTable = { }
    if params == nil or params.equipmentsTable == nil or #params.equipmentsTable < 1 then
        return { }, nil
    end
    _equipmentsTable = params.equipmentsTable
    local staticEquipUpData = gameData.getDataFromCSV("EquipUpList")
    local dynamicItemData = params.itemsData
    -- 动态背包数据是否传入
    if dynamicItemData == nil or next(dynamicItemData) == nil then
        local _table = DBTableItem:getDataByID()
        dynamicItemData = { }
        for k, v in pairs(_table) do
            dynamicItemData[tostring(v.itemid)] = v
        end
    end
    local _playerLevel = tonumber(gameUser.getLevel())
    local _AllCoin = 0
    local _hasCoin = tonumber(gameUser.getGold())
    local _costItemTable = { }

    local function getEquipmentCoin(_equipmentsTable)
        local _addCoin = 0
        local _isOver = false
        for i = 1, #_equipmentsTable do
            if _hasCoin == 0 then
                break
            end
            local _quality = _equipmentsTable[i].quality or 0
            local _strengLevel = tonumber(_equipmentsTable[i].strengLevel or 0)
            local _itemLevel = _strengLevel + 1
            if _itemLevel <= _playerLevel then
                local _coinData = staticEquipUpData[tonumber(_itemLevel)]
                if _coinData == nil or next(_coinData) == nil then
                    break
                end
                local _coin = _coinData["consume" .. _quality]
                if _coin <= _hasCoin then
                    local _needItem = _coinData["need"]
                    local _needNum = tonumber(_coinData["num".._quality])
                    if _needItem == nil or _needNum == nil or tonumber(_needItem) < 1 or tonumber(_needNum) < 1 then
                        _isOver = true
                        _hasCoin = _hasCoin - _coin
                        _addCoin = _coin + _addCoin
                        _equipmentsTable[i].strengLevel = _itemLevel
                    else
                        local _allNeedNum = 0
                        local _lastNum = 0
                        if _costItemTable[tostring(_needItem)] ~= nil then
                            _lastNum = tonumber(_costItemTable[tostring(_needItem)].lastNum or 0)
                            _allNeedNum = tonumber(_costItemTable[tostring(_needItem)].allNeedNum or 0) + _needNum
                        else
                            _lastNum = tonumber(dynamicItemData[tostring(_needItem)] and dynamicItemData[tostring(_needItem)].count or 0)
                            _allNeedNum = _needNum
                        end
                        if _lastNum >= _needNum then
                            _isOver = true
                            _lastNum = _lastNum - _needNum
                            _hasCoin = _hasCoin - _coin
                            _addCoin = _coin + _addCoin
                            _equipmentsTable[i].strengLevel = _itemLevel
                            _costItemTable[tostring(_needItem)] = {
                                itemType = 4,
                                itemId = _needItem,
                                allNeedNum = _allNeedNum,
                                lastNum = _lastNum
                            }
                        end
                    end

                end
            end
        end
        if _isOver == false then
            return _addCoin
        else
            return _addCoin + getEquipmentCoin(_equipmentsTable)
        end
    end
    _AllCoin = getEquipmentCoin(_equipmentsTable)
    _costItemTable["gold"] = {
        itemType = 2,
        itemId = 0,
        allNeedNum = _AllCoin,
        lastNum = 0
    }
    if params.backStrengthLevel ~= nil and params.backStrengthLevel == false then
        return _costItemTable
    else
        return _costItemTable, _equipmentsTable
    end
end

function XTHD.createDialogPop(str)
    local dialog = cc.Sprite:create("res/image/daily_task/escort_task/dialog_bg.png")
    local dialogLabel = XTHDLabel:createWithParams( {
        text = str,
        fontSize = 18,
        color = XTHD.resource.color.gray_desc
    } )
    dialogLabel:setAnchorPoint(0, 1)
    dialogLabel:setPosition(10, dialog:getBoundingBox().height - 7)
    dialogLabel:setWidth(dialog:getBoundingBox().width - 20)
    dialog:addChild(dialogLabel)
    XTHD.runActionPop(dialog)
    return dialog
end

function XTHD.createDialogPopGuide(str, fontSize)
    local _fontSize = tonumber(fontSize) or 18
    local _size = cc.size(145, 70)
    local dialog = ccui.Scale9Sprite:create("res/image/daily_task/escort_task/dialog_bg.png")
    dialog:setContentSize(_size)
    local dialogLabel = XTHDLabel:createWithParams( {
        text = str,
        fontSize = _fontSize,
        color = XTHD.resource.color.gray_desc
    } )
    dialogLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    dialogLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    dialog:addChild(dialogLabel)
    dialog:setScale(1.4)

    local _partSize = cc.size(10, 4)
    local _width = dialogLabel:getContentSize().width
    local _dimensionsX = _size.width - _partSize.width
    -- dialogLabel:setDimensions(_dimensionsX, _size.height - _partSize.height - 10)
    dialogLabel:setWidth(_dimensionsX)

    local _px = _size.width * 0.5
    if _width < _dimensionsX then
        _px =(_size.width + _dimensionsX - _width) * 0.5
    end
    local _height = dialogLabel:getContentSize().height
    if _height > _size.height - _partSize.height - 10 then
        _size = cc.size(_size.width, _height + _partSize.height + 10)
        dialog:setContentSize(_size)
    end

    dialogLabel:setPosition(_px,(_size.height - _partSize.height) * 0.5 + 10)
    return dialog, dialogLabel
end

function XTHD.getScaleNode(_path, _nodeSize)
    local _node = ccui.Scale9Sprite:create(_path)
    _node:setContentSize(_nodeSize)
    return _node
end
-- 新换的按钮
function XTHD.getScaleNode1(_path, _nodeSize)
    -- local _node = ccui.Scale9Sprite:create(_path)
    local _node = cc.Sprite:create(_path)
    _node:setContentSize(_nodeSize)
    return _node
end

--------接受多人副本的邀请 data = {parent,configID,teamID}
function XTHD.acceptMultiCopyInvite(data)
    DuoRenFuBenDatas:joinATeam(data, function(serverData)
        local _layer = requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenPrepareLayer.lua"):create( {
            id = - 1,
            fristID = serverData.configID,
            previouseTeam = serverData.teams,
        } )
        musicManager.setBackMusic(XTHD.resource.music.music_bgm_main)
        musicManager.switchBackMusic()
        LayerManager.addLayout(_layer)
    end )
end

function XTHD.getTextSplitList(str)
    local list = { }
    local len = string.len(str)
    local i = 1
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, 0, i + shift - 1)
        i = i + shift
        table.insert(list, char)
    end
    return list
end

function XTHD.playLabelAction(_strLabel, _perTime)
    if _strLabel == nil or _perTime == nil or tonumber(_perTime) <= 0 then
        return
    end
    local _label = _strLabel
    local _labelText = _label:getString()
    _label:setVisible(false)
    local _textList = XTHD.getTextSplitList(_labelText)
    _label:setVisible(true)
    if #_textList <= 1 then
        return
    end
    local _textOrder = 1
    local _labelFunc = function()
        _label:setString(_textList[_textOrder])
        if _textOrder >= #_textList then
            _label:stopActionByTag(2104)
        end
        _textOrder = _textOrder + 1
    end
    _labelFunc()
    schedule(_label, _labelFunc, _perTime, 2104)
end

function XTHD.playLabelActionByRich(_strLabel, _text, _perTime)
    if _strLabel == nil or type(_text) ~= "string" then
        return
    end
    local _data = _strLabel:parse(_text)
    if not _data or #_data < 1 then
        return
    end
    _perTime = tonumber(_perTime) or 0.1

    local _label = _strLabel
    _label._showInfo = _text
    local _dataTb = { }
    local _count = 1
    local _worldTb, _countS, _countM, textArr
    local function _labelFunc()
        _label._isPlaying = true
        performWithDelay(_strLabel, function()
            local dic = _data[_count]
            if not dic.img then
                if not textArr then
                    textArr = XTHD.getTextSplitList(dic.word)
                    _countM = #textArr
                    _worldTb = clone(dic)
                    _dataTb[_count] = _worldTb
                    _countS = 1
                end
                if _countM > 0 then
                    _worldTb.word = textArr[_countS]
                    if _countS == _countM then
                        textArr = nil
                        _count = _count + 1
                    end
                    _countS = _countS + 1
                else
                    textArr = nil
                    _count = _count + 1
                end
            else
                _dataTb[_count] = dic
                _count = _count + 1
            end
            _strLabel:setStringByDatas(_dataTb)
            if _count > #_data then
                _label._isPlaying = false
                return
            end
            _labelFunc()
        end , _perTime)
    end

    _labelFunc()
end

function XTHD.luaBridgeCall(className, functionName, args, sigs)
    local platform = cc.Application:getInstance():getTargetPlatform()
    local ok, ret
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = requires("src/cocos/cocos2d/luaj.lua")
        ok, ret = luaj.callStaticMethod(className, functionName, args, sigs)
    elseif (platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_MAC) then
        local luaoc = requires("src/cocos/cocos2d/luaoc.lua")
        ok, ret = luaoc.callStaticMethod(className, functionName, args)
    end
    if not ok then
        print("luaoc error:" .. tostring(ret) .. ",className=" .. tostring(className) .. ",methodName=" .. tostring(functionName))
    else
        print("The oc ret is:" .. tostring(ret) .. ",className=" .. tostring(className) .. ",methodName=" .. tostring(functionName))
    end
end


function XTHD.getGameInfoFromSdk()
    local platform = cc.Application:getInstance():getTargetPlatform()
    local callbackLua = function()
    end
    local args = { }
    local sigs = nil
    -- 初始化SDK平台
    if (cc.PLATFORM_OS_ANDROID == platform) then
        -- 渠道号默认为官网渠道
        GAME_CHANNEL = CHANNEL.Android.CHANNEL_CODE_Define
        callbackLua = function(param)
            local _param_ = json.decode(param)
            GAME_CHANNEL = tostring(_param_["channel"])
            GAME_MAC = tostring(_param_["macAddr"])
            GAME_OS_VERSION = tostring(_param_["versionCode"])
            GAME_ANDROIDID = tostring(_param_["androidId"])
            GAME_APPKEY = tostring(_param_["appKey"])
            print("ysm  GAME_CHANNEL=" .. tostring(GAME_CHANNEL) .. ",GAME_MAC=" .. tostring(GAME_MAC) .. ",GAME_OS_VERSION=" .. GAME_OS_VERSION)
        end
        args = { callbackLua }
        sigs = "(I)V"
    elseif (cc.PLATFORM_OS_IPHONE == platform) or(cc.PLATFORM_OS_IPAD == platform) then
        callbackLua = function(param)
            if param["channel"] ~= nil then
                GAME_CHANNEL = tostring(param["channel"])
                GAME_IDFA = tostring(param["idfa"])
                GAME_OS_VERSION = tostring(param["os_version"])
                GAME_APPKEY = tostring(param["game_appkey"])
                print("GAME_CHANNEL=" .. tostring(GAME_CHANNEL) .. ",GAME_OS_VERSION=" .. GAME_OS_VERSION .. ",GAME_IDFA=" .. GAME_IDFA)
            end
        end
        args = { callback = callbackLua }
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS, "getGameInfo", args, sigs)
end

function XTHD.replaceToLoginScene(relogin)
    LayerManager.reset()
    MsgCenter:reset()
    local _layer = requires("src/fsgl/layer/DengLu/DengLuLayer.lua")
    local _scene = cc.Scene:create()
    local bgNode = cc.NodeGrid:create()
    bgNode:addChild(_layer:create(relogin))
    _scene:addChild(bgNode)
    cc.Director:getInstance():replaceScene(_scene)
    return _scene
end

--[[ --登录成功的sdk回调，有些sdk是需要游戏中的角色信息，所以在获取游戏数据后需要回调给sdk端 ]]
function XTHD.loginSuccessCallback()
    
end   

-- 登录成功上传lua回调 函数
function XTHD.loginUpdataluaCall()

    -- local logoutCallback = function(param)
    --     print("----------------logoutCallback 登出回调函数----------------")
    --     isLoginFlag = false
    --     print("----------------logoutCallback 0----------------")
    --     MsgCenter:reset()
    --     ------断开Socket
    --     print("----------------logoutCallback 1----------------")
    --     XTHD.replaceToLoginScene()
    --     print("----------------logoutCallback 2----------------")
    -- end

    -- local switchCallback = function(param)
    --     print("----------------switchCallback 切换回调函数----------------")
    --     isLoginFlag = false
    --     isNotShowLoginUI = true
    --     -- 切换账号有的平台自己会调用登录界面  所以在初始化登录界面时不需要调用
    --     print("----------------switchCallback 0----------------")
    --     MsgCenter:reset()
    --     ------断开Socket
    --     print("----------------switchCallback 1----------------")
    --     XTHD.replaceToLoginScene()
    --     print("----------------switchCallback 2----------------")
    -- end

    local logoutCallback = function()
        print("----------------logoutCallback 注销回调函数----------------")
        if isLoginFlag then
            gameUser.setToken(nil)
            gameUser.setNewLoginToken(nil)
        else
           ClientHttp:requestAsyncInGameWithParams({
                modules = "exit?",
                successCallback = function() 
                    print("向服务器请求退出成功--------------------------------------------------")  
                    MsgCenter:reset() 
                    -- XTHD.logout()
                    cc.Director:getInstance():popToRootScene()
                    XTHD.replaceToLoginScene(nil)
                    gameUser.setToken(nil)
                    gameUser.setNewLoginToken(nil)
                end,
                failedCallback = function() 
                    print("向服务器请求退出失败--------------------------------------------------")
                    MsgCenter:reset() 
                    -- XTHD.logout()
                    cc.Director:getInstance():popToRootScene()
                    XTHD.replaceToLoginScene(nil)
                    gameUser.setToken(nil)
                    gameUser.setNewLoginToken(nil)
                end,--失败回调
                loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
            })
        end
    end

    local switchCallback = function(param)
        print("----------------switchCallback 切换账号回调函数----------------")
        isNotShowLoginUI = true --切换账号有的平台自己会调用登录界面  所以在初始化登录界面时不需要调用
        if isLoginFlag then
            if param ~= nil and param ~= "" then
                print("CTX_log渠道登录返回的参数为：")
                print_r(param)
                if LayerManager.isLayerOpen(2) ~= nil then
                    local node = LayerManager.isLayerOpen(2)
                    node:loginUserCenter({data = param})
                else
                    XTHDTOAST(LANGUAGE_TIPS_WORDS286)
                end
            end
        else
            ClientHttp:requestAsyncInGameWithParams({
                modules = "exit?",
                successCallback = function() 
                    print("向服务器请求退出成功--------------------------------------------------")  
                    MsgCenter:reset() 
                    -- XTHD.logout()
                    cc.Director:getInstance():popToRootScene()
                    XTHD.replaceToLoginScene(nil)
                    gameUser.setToken(nil)
                    gameUser.setNewLoginToken(nil)
                end,
                failedCallback = function() 
                    print("向服务器请求退出失败--------------------------------------------------")
                    MsgCenter:reset() 
                    -- XTHD.logout()
                    cc.Director:getInstance():popToRootScene()
                    XTHD.replaceToLoginScene(nil)
                    gameUser.setToken(nil)
                    gameUser.setNewLoginToken(nil)
                end,--失败回调
                loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
            })
        end
    end

    local arg = { }
    local sig = nil
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        arg = { logoutCallback, switchCallback }
        sig = "(II)V"
    elseif (platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD) then
        return
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS, "loginUpdataluaCall", arg, sig)
    print("----------------loginUpdataluaCall----------------")
end

function XTHD.enterCustomerServiceCenter()
    local _param_ = {
        uid = tostring(gameUser.getUserId()),
        nickName = tostring(gameUser.getNickname()),
        level = tostring(gameUser.getLevel()),
        serverId = tostring(gameUser.getServerId()),
        serverName = tostring(gameUser.getServerName()),
        vip = tostring(gameUser.getVip()),
        appUId = tostring(gameUser.getPassportID()),
    }
    local platform = cc.Application:getInstance():getTargetPlatform()
    local args = { }
    local sigs = nil
    if platform == cc.PLATFORM_OS_ANDROID then
        -- 玩家角色ID，玩家角色名，玩家角色等级，游戏区服ID,游戏服务器名字,vip
        local param = json.encode(_param_)
        args = { param }
        sigs = "(Ljava/lang/String;)V"
    elseif (platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD) then
        args = _param_
    end
    XTHD.luaBridgeCall(LUA_BRIDGE_CLASS, "enterCustomerServiceCenter", args, sigs)
end

function XTHD.isEmbeddedSdk(_param_)

    if GAME_CHANNEL == CHANNEL_CODE_Define then
        return false
    end

    local platform = cc.Application:getInstance():getTargetPlatform()
    if IS_NEI_TEST or platform == cc.PLATFORM_OS_MAC then
        return false
    end


    for k, _platform in pairs(CHANNEL) do
        for k, channel in pairs(_platform) do
            if GAME_CHANNEL == tostring(channel) then
                return true
            end
        end
    end
    return false
end


function XTHD.doPayFinish(_param_,_parent,isLimit)

    --对月卡和至尊卡计时30秒
    if tonumber(_param_.type) == 1 then
        gameUser._vipRechargeTime.monthCard = os.time()
    elseif tonumber(_param_.type) == 2 then
        gameUser._vipRechargeTime.zhizunCard = os.time()
    end

    local node = cc.Director:getInstance():getNotificationNode()
    local callbackLua = nil
    local callTimes = 0
    local delay = 1.0
    local function performRequest()
        if node then
            callTimes = callTimes+1
            performWithDelay(node, function()
                print("重新请求订单确认")
                callbackLua(param)
                if callTimes > 2 then
                    delay = 5.0
                end
            end,delay)
        end
    end
    callbackLua = function(param)
        ClientHttp:requestAsyncInGameWithParams({
            modules = "payFinish?",
            params = _param_, -- 参数
            successCallback = function(data)
--            dump(data)
            --获取奖励成功
            if data and tonumber(data.result) == 0 then
                local needShowVip = false
                local show = {} --奖励展示
                if type(data) == "table" and data["property"] then
                    for i=1,#data["property"] do
                        local pro_data = string.split( data["property"][i],',')
                        --如果奖励类型存在，而且不是vip升级(406)则加入奖励
                        if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
                            local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
                            if getNum > 0 then
                                local idx = #show + 1
                                show[idx] = {}
                                show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
                                show[idx].num = getNum
                            end
                        end
                        DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2])
                        if tonumber(pro_data[1]) == 406 then --vip升级
                            needShowVip = true
                        end
                        if tonumber(pro_data[1]) == 403 then --元宝
                            gameUser.setIngot(tonumber(pro_data[2]))
                        end
                    end
                end
                if type(data) == "table" and data["itemList"] then
                    for i=1,#data["itemList"] do
                        local item = data["itemList"][i]
--                        dump(item)
                        local showCount = 0
                        if item.count and tonumber(item.count) ~= 0 then
                            showCount = item.count - tonumber(DBTableItem.getCountByID(item.dbId));
                            DBTableItem.updateCount(gameUser.getUserId(),item,item.dbId)
                        else
                            DBTableItem.deleteData(gameUser.getUserId(),item.dbId)
                        end

                        if showCount > 0 then
                            --如果奖励类型
                            local idx = #show + 1
                            show[idx] = {}
                            show[idx].rewardtype = 4 -- 4
                            show[idx].id = item.itemId
                            show[idx].num = showCount
                        end
                    end
                end
				gameUser.setThreeTimePayId(data.threeTimePayId)
				gameUser.setThreeTimePayList(data.threeTimePayList)
                ShowRewardNode:create(show)
                --设置银两、翡翠兑换次数
                if data["silverSurplusSum"] and data["feicuiSurplusSum"] then
                    gameUser.setGoldSurplusExchangeCount(data["silverSurplusSum"])
                    gameUser.setFeicuiSurplusExchangeCount(data["feicuiSurplusSum"])
                    gameUser.setIngotTotal(data["totalIngot"])
                end
                XTHDTOAST(LANGUAGE_KEY_RECHARGE_CONGRATULATIONS)
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_VIP_MSG})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG})
                if needShowVip then
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_VIP_SHOW})
                end
				if isLimit == 1 then
					_parent:updateCell()
                elseif isLimit == 2 then
                    _parent:freshLayer()
                    gameUser.setActivityOpenStatusById(19, 0)
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
                elseif isLimit == 3 or isLimit == 4 then
                    _parent:freshData()
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
				end
            else
                performRequest()
            end
              
            end,--成功回调
            failedCallback = function()
                performRequest()
            end,--失败回调
            timeoutForConnect = 15,
            timeoutForRead = 20,
            reconnectTimes = 5,
        })
    end
    return callbackLua
end

function XTHD.createMaxBtn(btnsize)
    -- local _maxBtn = XTHD.createCommonButton({
    --         btnColor = "gray",
    --         btnSize = btnsize or cc.size(80,38),
    --         text = "MAX",
    --         fontSize = 20,
    --     })
    local _maxBtn = XTHDPushButton:createWithParams( {
        normalFile = "res/image/common/btn/btn_max_normal.png",
        selectedFile = "res/image/common/btn/btn_max_selected.png"
        ,
        musicFile = XTHD.resource.music.effect_btn_common
    } )
    return _maxBtn
end

-- 播放英雄配音
function XTHD.playHeroDubEffect(_heroid, _action)
    if _heroid == nil or _action == nil then
        return 0
    end
	musicManager.stopAllEffects()
    local _soundId = 0
    local _soundStr = getHeroDubEffectNamePath(_heroid, _action)
    print("heroDubPath>>" .. _soundStr)
    _soundId = musicManager.playEffect(_soundStr);
    _soundId = _soundId or 0
    return _soundId
end

function XTHD.createTiaoguoButton(par)
    local btn_battle
    btn_battle = XTHD.createCommonButton( {
        text = LANGUAGE_KEY_GUIDE_SCENE_TEXT_28,
        isScrollView = false,
        endCallback = function()
            btn_battle:setClickable(false)
            musicManager.stopAllEffects()
            musicManager.stopMusic()
            musicManager.playBackgroundMusic(XTHD.resource.music.music_bgm_login, true)

            local layer = XTHD.createCampRegisterLayer(gameUser.getCampID(), function(data)
                BATTLE_TIME_SCALE = BATTLE_SPEED.X2
                LayerManager.pushModule(nil, true, { guide = true })
            end )
            local _scene = cc.Scene:create()
            _scene:addChild(layer)
            cc.Director:getInstance():replaceScene(_scene)
        end
    } )
    btn_battle:setPosition(cc.p(winWidth - 60, winHeight - 30))
    btn_battle:setScale(0.7)
    par:addChild(btn_battle)
end

function XTHD.addEffectToEquipment(_target, _rankValue)
    if _target == nil or _rankValue == nil then
        return
    end
    -- local _qualitySpine = sp.SkeletonAnimation:create("res/image/plugin/hero/equipSpine/zbg.json", "res/image/plugin/hero/equipSpine/zbg.atlas", 1)
    local _qualitySpine = sp.SkeletonAnimation:create("res/image/plugin/hero/equipSpine/wupinkuang.json", "res/image/plugin/hero/equipSpine/wupinkuang.atlas", 1)
    -- _qualitySpine:setScale(1.3)
    local _rank = tonumber(_rankValue)
    if _rank == 4 then
        -- _qualitySpine:setAnimation(0,"zz",true)
        _qualitySpine = sp.SkeletonAnimation:create("res/image/plugin/hero/equipSpine/lanse.json", "res/image/plugin/hero/equipSpine/lanse.atlas", 1)
        _qualitySpine:setAnimation(0, "lanse", true)
        _qualitySpine:setPosition(cc.p(_target:getContentSize().width / 2 - 6, _target:getContentSize().height / 2 + 11))
    elseif _rank == 5 then
        -- _qualitySpine:setAnimation(0,"cz",true)
        _qualitySpine = sp.SkeletonAnimation:create("res/image/plugin/hero/equipSpine/chengse.json", "res/image/plugin/hero/equipSpine/chengse.atlas", 1)
        _qualitySpine:setAnimation(0, "chengse", true)
        _qualitySpine:setPosition(cc.p(_target:getContentSize().width / 2, _target:getContentSize().height / 2 + 5))
    elseif _rank == 6 then
        -- _qualitySpine:setAnimation(0,"hz",true)
        _qualitySpine = sp.SkeletonAnimation:create("res/image/plugin/hero/equipSpine/hongse.json", "res/image/plugin/hero/equipSpine/hongse.atlas", 1)
        _qualitySpine:setAnimation(0, "hongse", true)
        _qualitySpine:setPosition(cc.p(_target:getContentSize().width / 2, _target:getContentSize().height / 2 + 5))
    else
        _qualitySpine:setAnimation(0, "wupinkuang", true)
        _qualitySpine:setPosition(cc.p(_target:getContentSize().width / 2, _target:getContentSize().height / 2 - 10))
    end
    _target:addChild(_qualitySpine)
    _qualitySpine:setName("qualitySpine")
end

function XTHD.getHeroSpineById(_heroid)
    if _heroid == nil then
        _heroid = 0
    end
	local _spine = nil
    local _strid = string.format("%03d", _heroid)
	if _strid ~= 322 and _strid ~= 026 and _strid ~= 042 then
		_spine = sp.SkeletonAnimation:createWithBinaryFile("res/spine/" .. _strid .. ".skel", "res/spine/" .. _strid .. ".atlas", 1)
	else
		_spine = sp.SkeletonAnimation:create("res/spine/" .. _strid .. ".json", "res/spine/" .. _strid .. ".atlas", 1)
	end
   
    return _spine
end

function XTHD.timeHeroListCallback(_target, _zorder, _noFailTip)
    if _target == nil then
        _target = cc.Director:getInstance():getRunningScene()
    end
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "limitPetList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                local _popLayer = requires("src/fsgl/layer/HuoDong/XianShiYingXiongLayer.lua"):create(data)
                if _popLayer ~= nil then
					_target:removeAllChildren()
					_popLayer:setName("XianShiYingXiongLayer")
                    _target:addChild(_popLayer, _zorder or 0)
					_popLayer:setPosition(_target:getContentSize().width/2 + 79,_target:getContentSize().height/2 - 20)
                end
            else
                if _noFailTip == nil or _noFailTip == false then
                    XTHDTOAST(data.msg)
                end
            end
        end,
        -- 成功回调
        failedCallback = function()
            if _noFailTip == nil or _noFailTip == false then
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            end
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function XTHD.limitTimeBuyCallback(_target,_zorder,_noFailTip)
    if _target == nil then
        _target = cc.Director:getInstance():getRunningScene()
    end
    ClientHttp:requestAsyncInGameWithParams({
        modules = "getLimitGift?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                local _popLayer = requires("src/fsgl/layer/HuoDong/XianShiLiBaoLayer.lua"):create(data)
                if _popLayer ~=nil then
                    _target:addChild(_popLayer,_zorder or 0)
                end
            else
                if _noFailTip == nil or _noFailTip == false then
                    XTHDTOAST(data.msg)
                end
            end
        end,--成功回调
        failedCallback = function()
            if _noFailTip ==nil or _noFailTip == false then
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            end
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function XTHD.createStoneItemChip(params)
    local _defaultparams = {
        itemtype = 1,
        rank = 1,
        level = 1,
        target = nil,
        isGrey = false
    }
    if params.target == nil or params.itemtype == nil or params.itemtype ~= 5 then
        return
    end
    for k, v in pairs(_defaultparams) do
        if params[k] == nil then
            params[k] = v
        end
    end

    local _path = "res/image/quality/rank_" ..(params.rank or 1) .. ".png"
    local _sp = XTHD.createSprite(_path)
    if params.isGrey == true then
        XTHD.setGray(_sp, true)
    end
    _sp:setAnchorPoint(1, 1)
    _sp:setPosition(params.target:getContentSize().width + 2, params.target:getContentSize().height + 2)
    params.target:addChild(_sp)

    local _lb = XTHDLabel:createWithParams( {
        text = params.level,
        fontSize = 20,
        color = cc.c3b(255,255,255)
    } )
    _lb:setPosition(_sp:getContentSize().width * 0.5, _sp:getContentSize().height * 0.5 + 2)
    _sp:addChild(_lb)
end

function XTHD.getMeridianCurPhase(_level)
    if _level == nil or tonumber(_level) == nil then
        return 0
    end
    return math.floor(tonumber(_level) / 5) + 1
end
-- 创建等级升级转盘
function XTHD.createLevelUpTurn(sNode, _callback)
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "levelZhuanPanList?",
        -- 接口
        params = { },
        -- 参数
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                -- 请求成功
                -- ... --相应处理
                if _callback then
                    _callback(data)
                end
            else
                XTHDTOAST(data.msg)
                -- 出错信息(后端返回)
            end
        end,
        -- 成功回调
        loadingParent = sNode,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            -----"网络请求失败")
        end,
        -- 失败回调
        targetNeedsToRetain = sNode,
        -- 需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

-- 直接进入噩梦副本
function XTHD.gotoDiffcultyCopy(node, _callback, target)
    local _open_data = gameData.getDataFromCSV("FunctionInfoList", { ["id"] = 82 })
    if tonumber(_open_data["unlocktype"]) == 2 then
        if gameUser.getInstancingId() < tonumber(_open_data["unlockparam"]) then
            XTHDTOAST(LANGUAGE_KEY_NOTOPEN)
            ------"副本暂未开启!")
            return
        end
    end
    if tonumber(_open_data["unlocktype"]) == 1 then
        if gameUser.getLevel() < tonumber(_open_data["unlockparam"]) then
            XTHDTOAST(LANGUAGE_TIPS_OPEN_DIFFCULTY(_open_data["unlockparam"]))
            ------"噩梦副本xx级开启!")
            return
        end
    end
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "diffcultyEctypeRecord?",
        -- 接口
        params = { },
        -- 参数
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                -- 请求成功
                -- 保存后端数据
                CopiesData.UpdateInstancingData(data)
                -- 进入恶魔副本
                local layer = requires("src/fsgl/layer/LiLian/LiLianStageChapterView.lua"):create( { targetId = target and target or nil, callback = _callback })
                LayerManager.addLayout(layer)
            else
                XTHDTOAST(data.msg)
                -- 出错信息(后端返回)
            end
        end,
        -- 成功回调
        loadingParent = sNode,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            -----"网络请求失败")
        end,
        -- 失败回调
        targetNeedsToRetain = sNode,
        -- 需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end
-- 噩梦副本和普通精英副本之间的跳转使用
function XTHD.createDiffcultyCopy(sNode, _callback, target)
    -- 创建恶魔副本，请求后端数据
    local _open_data = gameData.getDataFromCSV("FunctionInfoList", { ["id"] = 82 })
    if tonumber(_open_data["unlocktype"]) == 2 then
        if gameUser.getInstancingId() < tonumber(_open_data["unlockparam"]) then
            XTHDTOAST(LANGUAGE_KEY_NOTOPEN)
            ------"副本暂未开启!")
            return
        end
    end
    if tonumber(_open_data["unlocktype"]) == 1 then
        if gameUser.getLevel() < tonumber(_open_data["unlockparam"]) then
            XTHDTOAST(LANGUAGE_TIPS_OPEN_DIFFCULTY(_open_data["unlockparam"]))
            ------"噩梦副本xx级开启!")
            return
        end
    end
    XTHD.playYunActionIn(sNode, function()
        ClientHttp:requestAsyncInGameWithParams( {
            modules = "diffcultyEctypeRecord?",
            -- 接口
            params = { },
            -- 参数
            successCallback = function(data)
                if tonumber(data.result) == 0 then
                    -- 请求成功
                    -- 清理当前界面
                    XTHD.playYunActionOut(cc.Director:getInstance():getRunningScene())
                    LayerManager.removeLayout(sNode)
                    -- 保存后端数据
                    CopiesData.UpdateInstancingData(data)
                    -- 进入恶魔副本
                    local layer = requires("src/fsgl/layer/LiLian/LiLianStageChapterView.lua"):create( { targetId = target and target or nil, callback = _callback })
                    LayerManager.addLayout(layer)
                else
                    if sNode:getChildByName("inAction_leftYun") then
                        sNode:getChildByName("inAction_leftYun"):removeFromParent()
                    end
                    if sNode:getChildByName("inAction_rightYun") then
                        sNode:getChildByName("inAction_rightYun"):removeFromParent()
                    end
                    if sNode:getChildByName("inAction_tipLab") then
                        sNode:getChildByName("inAction_tipLab"):removeFromParent()
                    end
                    XTHDTOAST(data.msg)
                    -- 出错信息(后端返回)
                end
            end,
            -- 成功回调
            loadingParent = sNode,
            failedCallback = function()
                if sNode:getChildByName("inAction_leftYun") then
                    sNode:getChildByName("inAction_leftYun"):removeFromParent()
                end
                if sNode:getChildByName("inAction_rightYun") then
                    sNode:getChildByName("inAction_rightYun"):removeFromParent()
                end
                if sNode:getChildByName("inAction_tipLab") then
                    sNode:getChildByName("inAction_tipLab"):removeFromParent()
                end
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
                -----"网络请求失败")
            end,
            -- 失败回调
            targetNeedsToRetain = sNode,
            -- 需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
        } )
    end , true)
end
-- 云进入
function XTHD.playYunActionIn(_parent, _callback, _needShowTip)
    local leftYun = XTHDImage:create("res/image/plugin/stageChapter/yun_left.png")
    leftYun:setContentSize(cc.Director:getInstance():getWinSize().width/3*2,cc.Director:getInstance():getWinSize().height)
    leftYun:setName("inAction_leftYun")
    leftYun:setAnchorPoint(1, 0.5)
    leftYun:setPosition(0, _parent:getContentSize().height / 2)
    local rightYun = XTHDImage:create("res/image/plugin/stageChapter/yun_right.png")
    rightYun:setContentSize(cc.Director:getInstance():getWinSize().width/3*2,cc.Director:getInstance():getWinSize().height)
    rightYun:setName("inAction_rightYun")
    rightYun:setAnchorPoint(0, 0.5)
    rightYun:setPosition(_parent:getContentSize().width, _parent:getContentSize().height / 2)
    _parent:addChild(leftYun, 3)
    _parent:addChild(rightYun, 3)
    leftYun:stopAllActions()
    rightYun:stopAllActions()
    leftYun:runAction(cc.Sequence:create(
    cc.MoveTo:create(0.3, cc.p(rightYun:getBoundingBox().width, leftYun:getPositionY())),
    cc.CallFunc:create( function()
        if _needShowTip then
            local tipLab = XTHDLabel:createWithParams( {
                text = LANGUAGE_TIPS_DIFFCULTY_IS_ING,
                fontSize = 20,
                color = XTHD.resource.color.brown_desc,
                anchor = cc.p(0.5,0.5),
                pos = cc.p(_parent:getContentSize().width / 2,_parent:getContentSize().height / 2 - 150),
            } )
            tipLab:setName("inAction_tipLab")
            _parent:addChild(tipLab, 4)
        end
        _callback()
    end )
    ))
    rightYun:runAction(cc.Sequence:create(
    cc.MoveTo:create(0.3, cc.p(_parent:getContentSize().width - rightYun:getBoundingBox().width, rightYun:getPositionY()))
    ))
end
-- 云退出
function XTHD.playYunActionOut(_parent)
    local leftYun = XTHDImage:create("res/image/plugin/stageChapter/yun_left.png")
    leftYun:setContentSize(cc.Director:getInstance():getWinSize().width/3*2,cc.Director:getInstance():getWinSize().height)
    leftYun:setAnchorPoint(0, 0.5)
    leftYun:setPosition((357 - 393) * 2, _parent:getContentSize().height / 2)
    local rightYun = XTHDImage:create("res/image/plugin/stageChapter/yun_right.png")
    leftYun:setContentSize(cc.Director:getInstance():getWinSize().width/3*2,cc.Director:getInstance():getWinSize().height)
    rightYun:setAnchorPoint(1, 0.5)
    rightYun:setPosition(_parent:getContentSize().width, _parent:getContentSize().height / 2)
    _parent:addChild(leftYun, 3)
    _parent:addChild(rightYun, 3)
    leftYun:stopAllActions()
    rightYun:stopAllActions()
    leftYun:runAction(cc.Sequence:create(
    cc.MoveTo:create(0.3, cc.p(leftYun:getPositionX() - rightYun:getBoundingBox().width, leftYun:getPositionY())),
    cc.RemoveSelf:create(true)
    ))
    rightYun:runAction(cc.Sequence:create(
    cc.MoveTo:create(0.3, cc.p(rightYun:getPositionX() + rightYun:getBoundingBox().width, leftYun:getPositionY())),
    cc.RemoveSelf:create(true)
    ))
end

function XTHD.createMeridianSpine()
    local _spine = sp.SkeletonAnimation:create("res/spine/effect/meridian_wakeupEffect/jm.json", "res/spine/effect/meridian_wakeupEffect/jm.atlas", 1.0);
    return _spine
end

function XTHD.playSkillEffectAndPlaySound(picName, soundName, isPlayer)
    local scene = cc.Director:getInstance():getRunningScene()

    local x = -400
    local targetX = 0
    local anchorX = 0
    local height = 450

    if isPlayer == BATTLE_SIDE.LEFT then
        x = -400
        targetX = 30
        anchorX = 0
    else
        x = 1400
        targetX = 1024
        anchorX = 1
    end

    if picName ~= nil then
        local skillPic = XTHD.createSprite("res/image/skillPic/"..picName..".png")
        skillPic:setAnchorPoint(cc.p(anchorX, 0.5))
        skillPic:setPosition(cc.p(x, height))
        scene:addChild(skillPic)

        skillPic:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.5, cc.p(targetX, height)),
            cc.DelayTime:create(0.3),
            cc.MoveTo:create(0.3, cc.p(targetX - 30, height)),
            cc.FadeOut:create(1),
            cc.CallFunc:create(function(node)
                if node ~= nil then
                    node:removeFromParent()
                end
            end)
        ))
    end
    if soundName ~= nil then
        --播放音效
		cc.SimpleAudioEngine:getInstance():playEffect("res/sound/hero/"..soundName..".mp3", false)
    end
end


function XTHD.setReplaceZhenqiDialog(subZhenqiCost, parentT, rightFunc)
    if parentT == nil then
        return
    end
    local _subCost = subZhenqiCost or 0
    local _needIngot = XTHD.resource.getIngotNumToReplaceZhenqi(_subCost)

    local _dialog = XTHDConfirmDialog:createWithParams( {
        rightCallback = rightFunc
    } )
    _dialog:setName("dialog")
    local _confirmDialogBg = nil
    parentT:addChild(_dialog)
    if _dialog:getContainer() then
        _confirmDialogBg = _dialog:getContainer()
    else
        _dialog:removeFromParent()
        return
    end
    local _descLabel = XTHDLabel:create(string.format("缺少%s韬略，是否使用元宝代替？", _subCost), 18)
    _descLabel:setPosition(cc.p(_confirmDialogBg:getContentSize().width / 2, _confirmDialogBg:getContentSize().height / 2 + 40))
    _descLabel:setColor(XTHD.resource.color.gray_desc)
    _confirmDialogBg:addChild(_descLabel)
    local _downPosY = _confirmDialogBg:getContentSize().height / 5 * 3 - 20
    local _ingotSp = cc.Sprite:create(IMAGE_KEY_HEADER_INGOT)
    local _ingotLabel = XTHDLabel:create(_needIngot, 18)
    _ingotLabel:setAnchorPoint(cc.p(0, 0.5))
    _ingotSp:setPosition(cc.p(_confirmDialogBg:getContentSize().width / 2 - _ingotLabel:getBoundingBox().width / 2, _downPosY))
    _ingotLabel:setPosition(cc.p(_ingotSp:getBoundingBox().x + _ingotSp:getBoundingBox().width, _downPosY))
    _ingotLabel:setColor(XTHD.resource.color.gray_desc)
    _confirmDialogBg:addChild(_ingotSp)
    _confirmDialogBg:addChild(_ingotLabel)

    if tonumber(gameUser.getIngot()) < _needIngot then
        _dialog:setCallbackRight( function()
            local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create( { id = 1 })
            parentT:addChild(StoredValue)
            _dialog:removeFromParent()
        end )
    end
end

--获取英雄最高星数
function XTHD.getHeroMaxStar(hero_id)
	local maxStar = 0
	local starData = gameData.getDataFromCSV("GeneralGrowthNeeds",{id = hero_id})
	for i = 1,11 do
	   if starData["starcount"..i] == 0 then
			maxStar = i - 1
			break
	   end
	end
	return maxStar
end

--界面装饰
function XTHD.createNodeDecoration( _parent,title )
    local hengliang = cc.Sprite:create("res/image/public/hengliang.png")
    _parent:addChild(hengliang)
    hengliang:setPosition(_parent:getContentSize().width * 0.5,_parent:getContentSize().height - 10)
	hengliang:setName("hengliang")

    local title = cc.Sprite:create(title)
    _parent:addChild(title)
    title:setPosition(_parent:getContentSize().width * 0.5,_parent:getContentSize().height)
    title:setScale(0.8)
    _parent._title = title
	title:setName("title")

    local piaodiai_left = cc.Sprite:create("res/image/public/piaodai.png")
    piaodiai_left:setScale(0.8)
    _parent:addChild(piaodiai_left)
    piaodiai_left:setPosition( -8,_parent:getContentSize().height - piaodiai_left:getContentSize().height*0.5 + 40)
	piaodiai_left:setName("piaodiai_left")

    local piaodiai_right = cc.Sprite:create("res/image/public/piaodai_2.png")
    _parent:addChild(piaodiai_right)
    piaodiai_right:setScale(0.8)
    piaodiai_right:setPosition(_parent:getContentSize().width + 12,_parent:getContentSize().height - piaodiai_right:getContentSize().height*0.5 + 40)
	piaodiai_right:setName("piaodiai_right")

    local dibian = cc.Sprite:create("res/image/public/dibian.png")
    _parent:addChild(dibian)
    dibian:setPosition(_parent:getContentSize().width *0.5,6)
	dibian:setName("dibian")
    
end

--首冲打脸页弹窗
function XTHD.FristChongZhiPopLayer(parent)
	if gameUser.getLevel() >= 7 and gameUser.getFirstLayerState() == 0 then
		local layer = requires("src/fsgl/layer/HuoDong/ShouCiChongZhiNewLayer.lua"):create()
		parent:addChild(layer,11)
		layer:show()
	end
end

--修改名字界面
function XTHD.changPlayerNameLayer(callback)
    local popLayer = XTHDDialog:create()--XTHDPopLayer:create()
    local setnameBg=ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")--cc.Sprite:create("res/image/setting/setname_bg.png")
    setnameBg:setContentSize(cc.size(420,370))
    setnameBg:setPosition(popLayer:getContentSize().width/2, popLayer:getContentSize().height/2)
    popLayer:addChild(setnameBg)
    -- kuang2
    local kuang2 = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    kuang2:setContentSize(cc.size(380,180))
    kuang2:setPosition(setnameBg:getContentSize().width/2,setnameBg:getContentSize().height/2)
    kuang2:setAnchorPoint(0.5,0.5)
    setnameBg:addChild(kuang2)
    
    local titleLabel=XTHDLabel:createWithParams({text=LANGUAGE_TIPS_WORDS148,ttf="",size=22}) ------"为你的队伍取个名字"
    titleLabel:setColor(cc.c3b(53,30,26))
    setnameBg:addChild(titleLabel)
    titleLabel:setPosition(setnameBg:getContentSize().width/2,setnameBg:getContentSize().height-30)
    local namerandom_bg=ccui.Scale9Sprite:create("res/image/login/login_input_bg.png")
    namerandom_bg:setContentSize(cc.size(158,39))                                               
    namerandom_bg:setAnchorPoint(0,0)
    setnameBg:addChild(namerandom_bg)
    namerandom_bg:setPosition(75,setnameBg:getContentSize().height/2-10)
    local editbox_account = ccui.EditBox:create(cc.size(218,39), ccui.Scale9Sprite:create(),nil,nil)
    editbox_account:setFontColor(cc.c3b(255,255,255))
    editbox_account:setPlaceHolder(LANGUAGE_TIPS_WORDS149)-------"1~6位英文、汉字")
    editbox_account:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE ) 
    editbox_account:setAnchorPoint(0,0.5)
    editbox_account:setMaxLength(30)
    editbox_account:setPosition(0,17)
    editbox_account:setPlaceholderFontColor(cc.c3b(181,181,181))
    editbox_account:setFontName("Helvetica")
    editbox_account:setPlaceholderFontName("Helvetica")
    editbox_account:setFontSize(20)
    editbox_account:setPlaceholderFontSize(24)
    editbox_account:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editbox_account:setText(tostring(gameUser.getNickname()));
    namerandom_bg:addChild(editbox_account)
    --按钮随机
    local btn_random=XTHDPushButton:createWithParams({
        normalNode="res/image/setting/setname_random.png",
        selectedNode="res/image/setting/setname_random.png",
        musicFile = XTHD.resource.music.effect_btn_common,
        needSwallow=true,
        endCallback = function ()
            local prefixLen = #PrefixName
            local midLen = #MidName
            local suffixLen = #SuffixName
            local hasMid = math.random(100) % 2
            local index = math.random(prefixLen)
            local name = PrefixName[index]
            if hasMid == 1 then 
                index = math.random(midLen)
                name = name..MidName[index]
            end 
            index = math.random(suffixLen)
            name = name..SuffixName[index]         
            editbox_account:setText(name)                
        end
    })
    btn_random:setScale(0.8)
    btn_random:setAnchorPoint(1,0)
    btn_random:setPosition(350,namerandom_bg:getPositionY())
    setnameBg:addChild(btn_random)
    --按钮取消
    local btn_cancle = XTHD.createCommonButton({
        btnColor = "write",
        isScrollView = false,
        text = LANGUAGE_KEY_CANCEL,
        fontSize = 26,
        endCallback = function ()
            popLayer:removeFromParent() 
        end
    })
    btn_cancle:setAnchorPoint(1,0)
    btn_cancle:setScale(0.7)
    btn_cancle:setPosition(195,20)
    setnameBg:addChild(btn_cancle)
    --按钮确定
    local btn_ok=XTHD.createCommonButton({
        btnColor = "write_1",
        isScrollView = false,
        text = LANGUAGE_KEY_SURE,
        fontSize = 26,
        needSwallow=true,
        endCallback = function ()
            local notice=editbox_account:getText()
            local bg_sp = ccui.Scale9Sprite:create( cc.rect(40,40,1,2), "res/image/common/scale9_bg_34.png" )
            bg_sp:setContentSize(375,228)
            bg_sp:setCascadeOpacityEnabled(true)
            bg_sp:setPosition(popLayer:getContentSize().width / 2, popLayer:getContentSize().height / 2)
            popLayer:addChild(bg_sp, 2)
            local txt_content  = nil
            -- if  gameUser.getNameCount()>0 then
            --     txt_content = XTHDLabel:create(LANGUAGE_TIPS_WORDS150,18)-------"修改昵称花费100元宝,是否继续？",18)
            -- else
            --     txt_content = XTHDLabel:create(LANGUAGE_TIPS_WORDS151,18)--------"首次修改昵称免费,是否继续？",18)
            -- end
            txt_content = XTHDLabel:create("确定修改为"..notice.."嘛？",18)
            txt_content:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
            txt_content:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
            txt_content:setColor(XTHD.resource.color.gray_desc)
            --解决文字过短居中的问题
            if tonumber(txt_content:getContentSize().width)<306 then
                txt_content:setDimensions(tonumber(txt_content:getContentSize().width), 120)
            else
                txt_content:setDimensions(306, 120)
            end

            txt_content:setPosition(bg_sp:getContentSize().width/2,bg_sp:getContentSize().height/2 + 30)
            bg_sp:addChild(txt_content)
            local btn_left = XTHD.createCommonButton({ 
                btnColor = "write_1",
                isScrollView = false,
                text = LANGUAGE_KEY_CANCEL,
                fontSize = 22,
                musicFile = XTHD.resource.music.effect_btn_common,
                pos = cc.p(100 + 5,50),
                endCallback = function()
                    bg_sp:removeFromParent()
                end
            })
            btn_left:setScale(0.7)
            btn_left:setCascadeOpacityEnabled(true)
            btn_left:setOpacity(255)
            bg_sp:addChild(btn_left)
            local btn_right = XTHD.createCommonButton({
                btnColor = "write_1",
                isScrollView = false,
                text = LANGUAGE_KEY_SURE,
                fontSize = 22,
                musicFile = XTHD.resource.music.effect_btn_common,
                pos = cc.p(bg_sp:getContentSize().width-100-5,btn_left:getPositionY()),
                endCallback = function()
                    if tonumber(string.utf8len(notice)) <= 6 and tostring(notice) ~= tostring(gameUser.getNickname()) then
                        ClientHttp:requestAsyncInGameWithParams({
                            modules = "changeName?",
                            params = {name=tostring(string.gsub(notice," ",""))},
                            successCallback = function(my_data)
--                                dump(my_data)
                                if tonumber(my_data.result)==0 then  
                                    gameUser.setNameCount(my_data.changeNameCount)
                                    gameUser.setNickname(my_data.name)
                                    gameUser.setIngot(my_data.ingot)
                                    if callback then
                                        callback(my_data)
                                    end
                                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 
                                    popLayer:removeFromParent()
                                else
                                    XTHDTOAST(my_data.msg)
                                end 
                            end,
                            failedCallback = function()
                                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
                            end,--失败回调
                            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                        })      
                    else
                        if tonumber(string.utf8len(notice))>6 then
                            XTHDTOAST(LANGUAGE_INPUTTIPS6)-------"请输入6个字符以内")
                        elseif tostring(notice)==tostring(gameUser.getNickname()) then
                            XTHDTOAST(LANGUAGE_INPUTTIPS7)-------"相同昵称不需要更改！")
                        end        
                    end  
                end
            })
            btn_right:setScale(0.7)
            btn_right:setCascadeOpacityEnabled(true)
            btn_right:setOpacity(255)
            bg_sp:addChild(btn_right)
    end})  
    btn_ok:setScale(0.7)
    btn_ok:setAnchorPoint(0,0)
    btn_ok:setPosition(225,20)
    setnameBg:addChild(btn_ok)
    return popLayer
end

--判断背包中是否有箱子可开启
function XTHD.checkBagOpenTip()
    local flag = 0 
    local count = 0
    local ItemTotalData =  DBTableItem.getData(gameUser.getUserId(),nil,nil)
    -- print("装备数据为：")
    -- print_r(ItemTotalData)
    for i = 1,#ItemTotalData do
        local itemData = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = ItemTotalData[i].itemid})
        if itemData.display == 2 then
            if ItemTotalData[i].itemid == 2615 then  --橙色英雄箱特殊处理，需要时空钥匙开启
                if XTHD.resource.getItemNum(2617) > 0 then
                    count = count + 1
                end
            else
                count = count + 1
            end
            if count > 0 then
                return 1
            end
        end
    end
    return flag
end