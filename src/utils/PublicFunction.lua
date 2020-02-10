function bIsDebug()
	return true;
end


-- ć šćŽĺź§ĺşŚćąč§ĺşŚ
function CC_RADIANS_TO_DEGREES( angel )
	return angel * 57.29577951;
end

-- ć šćŽč§ĺşŚćąĺź§ĺşŚ
function CC_DEGREES_TO_RADIANS( angel )
	return angel * 0.01745329252;
end

function getVersionCode()
	local versionCode = CCUserDefault:sharedUserDefault():getStringForKey("version");
	versionCode = versionCode == "" and "1.0" or versionCode;
	return versionCode;
end

function setNowVersion( versionCode )
	CCUserDefault:sharedUserDefault():setStringForKey("version", versionCode);
	CCUserDefault:sharedUserDefault():flush();
end

function getArrAction( ... )
    local tabParam = { ... };
    local arr = CCArray:create();
    for i = 1, #tabParam do
        arr:addObject( tabParam[i] );
    end
    return arr;
end

function getSequencesAction( ... )
    return cc.Sequence:create( { ... } );
end

function getAnimation( filepathPrefix, startIndex, endIndex, perUnit, bRestore )
    perUnit = perUnit or 2.8 / 14.0;
    bRestore = bRestore == nil and true or false;
    local animation = cc.Animation:create();
    for i = startIndex , endIndex do
        local filepath = filepathPrefix .. i .. ".png";
        animation:addSpriteFrameWithFile( filepath );
    end
    animation:setDelayPerUnit( perUnit );
    animation:setRestoreOriginalFrame(bRestore);
    local action = cc.Animate:create( animation );
    return action;
end

function getAnimationBySpriteFrame( filepathPrefix, startIndex, endIndex, perUnit )
    perUnit = perUnit or 2.8 / 14.0;
    local animation = cc.Animation:create();
    for i = startIndex , endIndex do
        local filepath = filepathPrefix .. i .. ".png";
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(filepath));
    end
    animation:setDelayPerUnit( perUnit );
    animation:setRestoreOriginalFrame(true);
    local action = cc.Animate:create( animation );
    return action;
end

function getDistanceX( node1, node2 )
    local node1x, node1y = node1:getPosition();
    local node2x, node2y = node2:getPosition();
    return math.abs( node1x - node2x );
end

function getDistance( pos1, pos2 )
    return cc.pGetDistance( pos1, pos2 );
end

function getNodesDistance( node1, node2 )
    local node1X , node1Y = node1:getPosition();
    local node2X, node2Y = node2:getPosition();
    return cc.pGetDistance(cc.p(node1X, node1Y), cc.p(node2X, node2Y));
end

function getDynamicTime( distance, perPx )
    distance = math.abs(distance)
    return distance / perPx;
end

function setAllChildrenCascadeOpacityEnabled(node)
    node:setCascadeOpacityEnabled(true) --čŽžç˝Ž
    local pArray   = node:getChildren()
    if pArray ~= nil and type(pArray) == "table" and table.getn(pArray) > 0  then
        for i,var in ipairs(pArray) do
            if var ~= nil then
                setAllChildrenCascadeOpacityEnabled(var)
            end
        end
    end
end

--ĺşĺź ä¸ç¨éĺĺ­čçš ç´ćĽçťçśčçšä˝żç¨setCascadeOpacityEnabled(true)ĺ°ąĺŻäťĽäş čżć ˇäźĺŻźč´ĺ­čçšLabelçé´ĺ˝ąéćĺşŚä¸äźéççśčçšçéćĺşŚĺĺčĺĺ liuluyang
function ZCFadeOut(node,Totaltime,endOpacity)
   -- node.oldOpacity = node:getOpacity() --äżĺ­äťĽĺçéćĺşŚ

    if Totaltime == nil or type(Totaltime) ~= "number" then
        Totaltime = 0.18
    end

    if endOpacity == nil or type(endOpacity) ~= "number" then
        endOpacity = 0
    end
    
    -- node:setOpacity(startOpacity)
    node:runAction(cc.FadeTo:create(Totaltime,endOpacity))
    local pArray   = node:getChildren()
    if pArray ~= nil and type(pArray) == "table" and table.getn(pArray) > 0  then
        for i,var in ipairs(pArray) do
             if var ~= nil then
                ZCFadeOut(var,Totaltime,endOpacity)
            end
        end
    end
end

--ĺşĺź ä¸ç¨éĺĺ­čçšFadeIn ç´ćĽçťçśčçšä˝żç¨setCascadeOpacityEnabled(true)ĺ°ąĺŻäťĽäş čżć ˇäźĺŻźč´ĺ­čçšLabelçé´ĺ˝ąéćĺşŚä¸äźéççśčçšçéćĺşŚĺĺčĺĺ liuluyang
function ZCFadeIn(node,Totaltime,startOpacity)
    node.oldOpacity = node:getOpacity() ---äżĺ­äťĽĺçéćĺşŚ

    if Totaltime == nil or type(Totaltime) ~= "number" then
        Totaltime = 0.18
    end

    if startOpacity == nil or type(startOpacity) ~= "number" then
        startOpacity = 0
    end
    
    node:setOpacity(startOpacity)
    node:runAction(cc.FadeTo:create(Totaltime,node.oldOpacity))
    local pArray   = node:getChildren()
    if pArray ~= nil and type(pArray) == "table" and table.getn(pArray) > 0  then
        for i,var in ipairs(pArray) do
            if var ~= nil then
                ZCFadeIn(var,Totaltime,startOpacity)
            end
        end
    end
end

function XTHDTOAST( str )
    if str == nil or str == "" then return end
    XTHD._createToast(str)
end

function ShowNetTipWithResultValue(_resultId)
    local error_str = ErrorCode[tostring(_resultId)] or "UNKNOWN ERROR"    
end
--20150306 ç¨ćĽćĺ°luačĄ¨
function ZCLOG(Lua_table)
    do
        return;
    end
        local function define_print(_tab,str)
            str = str .. "  "
            for k,v in pairs(_tab) do
                if type(v) == "table" then
                    if not tonumber(k) then
                        print(str.. k .."{")
                    else
                        print(str .."{")
                    end
                    define_print(v,str)
                    
                    print( str.."}")
                   
                else
                    --print(k,v)
                    print(str .. tostring(k) .. " " .. tostring(v))
                end
            end
        end
    if type(Lua_table) == "table" then
        define_print(Lua_table," ")
    else
        print(tostring(Lua_table))
    end
end

--[[Composite --- translation ---  ĺ¤ĺç
        1.čżĺä¸ä¸Şĺ¤ĺçčçšďźćŻĺŚĺĺťşä¸ä¸ŞćéŽçćśĺďźéčŚçťćéŽäź éçžćŻĺ­ďź
            ĺ­ä˝éčŚćžç¤şĺćéŽä¸é˘ďźć­¤ć
ćŻéç¨äşZCPushButtonçć
ĺľćŻčžĺ¤ďźćéŽéčŚäź éä¸¤ä¸Şčçšçĺĺťşćšĺź
        2.éç¨äşçŽĺçčçšćźćĽďźćŻĺŚä¸ä¸Şčçšä¸é˘éčŚćˇťĺ ä¸ä¸Şĺ­čçšďź
        3.ä¸é˘çčçšéťčŽ¤ćˇťĺ ĺä¸é˘čçšçä¸­é´ďźĺ¤§ĺ¤ć°ĺşčŻĽćŻčżç§éćąĺ§ĺĺ~

    ćł¨ďź1.ĺ­čçšéťčŽ¤ćˇťĺ ĺ¨çśčçšçä¸­ĺżçšä¸
        2.ćŹćšćłä¸č´č´ŁéŞčŻčľćşçććć§ďźĺłä¸č´č´ŁéŞčŻčçšćŻĺŚĺĺťşćĺ
]]
function getCompositeNodeWithImg(lowerImgPath,higherImgPath,higher_node_pos)
    local lowerNode  = cc.Sprite:create(lowerImgPath)
    local higherNode = cc.Sprite:create(higherImgPath)
    if higher_node_pos and higher_node_pos.x and higher_node_pos.y then
        higherNode:setPosition(higher_node_pos.x, higher_node_pos.y)
    else
        higherNode:setPosition(lowerNode:getContentSize().width/2, lowerNode:getContentSize().height/2)
    end
    lowerNode:setCascadeOpacityEnabled(true)
    lowerNode:setCascadeColorEnabled(true)
    lowerNode:addChild(higherNode)
    return lowerNode
end

function getCompositeNodeWithNode(lowerNode,higherNode,higher_node_pos)
    if  higher_node_pos and higher_node_pos.x and higher_node_pos.y then
        higherNode:setPosition(higher_node_pos.x, higher_node_pos.y)
    else
        higherNode:setPosition(lowerNode:getContentSize().width/2, lowerNode:getContentSize().height/2)
    end
    lowerNode:setCascadeOpacityEnabled(true)
    lowerNode:setCascadeColorEnabled(true)
    lowerNode:addChild(higherNode)
    return lowerNode
end

--[[ćä¸ä¸Şéĺ¸¸ĺˇ¨ĺ¤§çć°ĺ­č˝Źĺć ĺä¸ ďźä¸ďźĺçąťĺćžç¤şçĺ­çŹŚä¸˛
    big_num éčŚčżčĄč˝Źĺçć°ĺ­
    base_num čżčĄč˝Źĺçĺşć°ďźćŻĺŚ â10000â ďź100000 äźč˝Źĺä¸ş 10ä¸
]]
function getHugeNumberWithLongNumber(big_num,base_num)
    if not base_num then
        base_num = 10000
    else
        base_num = tonumber(base_num)
    end
    -- base_num = 1000000
    -- print("base_num >>>>>> ")
    if big_num then
        big_num = tonumber(big_num)
    else
        return "0" 
    end
    local _result_str = ""

    local function getShowNumber(_number,_limit)
        local _showNum = _number or 0
        local _model = 10
        if tonumber(_limit)>1000000 then
            _model = 100
        end
        return math.floor(_showNum/_limit*_model)/_model
    end
    local function make_Str(big_num)
        local _unit = ""
        local _showNumber = 0
        if big_num >= 100000000 then
            _unit = LANGUAGE_DATA[6]
            _showNumber = getShowNumber(big_num,100000000)
        elseif big_num>=base_num and big_num<10000 then
            _unit = LANGUAGE_DATA[4]
            _showNumber = getShowNumber(big_num,1000)
        elseif  big_num >= base_num then
            _unit = LANGUAGE_DATA[5]
            _showNumber = getShowNumber(big_num,10000)
        else
            _unit = ""
            _showNumber = big_num
        end
        _result_str = _result_str .. _showNumber .. _unit
    end
    make_Str(big_num)
    return _result_str
end

function getCdStringWithNumber(timeSpt,typeParams,noZero,notNormal)
    --[[
        typeParamsäťŁčĄ¨ĺĺ˛çŹŚ dayĺ¤Š hourĺ°ćś minĺé secç§ éťčŽ¤ćŻ  "ĺ¤Š" ,"ĺ°ćś" ,":" ,""
    ]]
    if notNormal then
        noZero = 1
    end
    local dayStr = LANGUAGE_UNKNOWN.day -----"ĺ¤Š"
    local hourStr = LANGUAGE_UNKNOWN.hour -----"ĺ°ćś"
    local minStr = ":"
    local secStr = ""

    if typeParams then
        if typeParams.d then
            dayStr = typeParams.d
        end
        if typeParams.h then
            hourStr = typeParams.h
        end
        if typeParams.m then
            minStr = typeParams.m
        end
        if typeParams.s then
            secStr = typeParams.s
        end
    end

    if not timeSpt or tonumber(timeSpt) <1 then
        return 0
    else
        timeSpt = tonumber(timeSpt)
    end

    local nowTime = ""
    local count = 0
    local day = math.floor(timeSpt/86400)
    if day > 0 then
        count = count + 1
        nowTime = nowTime .. day .. dayStr
        timeSpt = timeSpt % 86400
    end
    local hour = math.floor(timeSpt/3600)
    if hour > 0 then
        count = count + 1
        if hour < 10 and day > 0 then
            hour = "0"..hour
        end
        nowTime = nowTime .. hour .. hourStr
        timeSpt = timeSpt % 3600
    else
        if day > 0 and not noZero then
            nowTime = nowTime .. "00" .. hourStr
        end
    end

    if count >= 2 and notNormal then
        return nowTime
    end
    local min = math.floor(timeSpt/60)
    if min > 0 then
        count = count + 1
        if min < 10 and (day > 0 or tonumber(hour) > 0) then
            min = "0"..min
        end
        nowTime = nowTime .. min .. minStr
        timeSpt = timeSpt % 60
    else
        if (tonumber(hour) > 0 or day > 0) and not noZero then
            nowTime = nowTime .. "00" .. minStr
        end
    end
    
    if count >= 2 and notNormal then
        return nowTime
    end
    local sec = timeSpt
    if sec < 10 and (tonumber(day) > 0 or tonumber(hour) > 0 or tonumber(min) > 0) then
        sec = "0"..sec
    end
    nowTime = nowTime .. sec .. secStr

    return nowTime
end

--[[
    čˇĺçłťçťćśé´ćł
]]
function setTimeSpan( dt )
    if __nTimerSpan == nil then
        local socket = require("socket");
        __nTimerSpan = tonumber(math.ceil(socket:gettime()*1000));
    end
    __nTimerSpan = __nTimerSpan + dt * 1000;
    __nTimerSpan = math.ceil(__nTimerSpan);
end

function getTimeSpan( ... )
    if __nTimerSpan == nil then
        local socket = require("socket");
        __nTimerSpan = tonumber(math.ceil(socket:gettime()*1000));
    end
    return __nTimerSpan
end

--[[
    @return čˇĺäťmĺ°nçéćşć°
]]
function GET_RANDOM_DATA( m, n )
    local socket = require("socket");
    local __nTimerSpan = socket:gettime();
    math.randomseed( __nTimerSpan )
    return math.random(m, n);
end


--20150616
function getCommonWhiteBMFontLabel(_str)
    -- return XTHDLabel:createWithParams({fnt = "res/image/common/common_num/1.fnt" , text = _str , kerning = -2})
    return XTHDLabel:createWithParams({fnt = "res/fonts/baisezi_0.fnt" , text = _str , kerning = -3})
end                                                  
function getCommonYellowBMFontLabel(_str)
    return XTHDLabel:createWithParams({fnt = "res/image/common/common_num/2_0.fnt" , text = _str , kerning = -2})
end
function getCommonRedBMFontLabel(_str)
    return XTHDLabel:createWithParams({fnt = "res/image/common/common_num/1-red.fnt" , text = _str , kerning = -2})
end
function getCommonGreenBMFontLabel(_str)
    return XTHDLabel:createWithParams({fnt = "res/image/common/common_num/greenword.fnt" , text = _str , kerning = -2})
end
function getCommonLabel(_str)
    return XTHDLabel:createWithParams({
        text = _str,
        fontSize = 16,
    })
end

--[[
    targetSize:ĺśĺŽčŚćäź¸ĺ°çĺ°şĺŻ¸
    rect:ä¸şĺśĺŽçćäź¸ĺşĺďźéťčŽ¤ä¸éčŚäź é
]]
function getScale9SpriteWithImg(imgpath,targetSize,rect)
   local scale9_sp = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),imgpath)
    scale9_sp:setContentSize(targetSize)
    scale9_sp:setCascadeOpacityEnabled(true)
    scale9_sp:setCascadeColorEnabled(true)
    return scale9_sp
end

--[[
    ĺĺ°ć°çšĺĺ ä˝ĺ°ć°ďźéťčŽ¤ä¸şĺ°ć°çšĺ2ä˝
    @param1: data: éčŚäżŽć­Łçć°ĺ­
    @param2: length: ĺ°ć°çšĺĺ ä˝
]]
function getDecimalData( data, length )
    length = lengt or 2;
    -- lengthĺŞč˝ä¸ş>0çć°ďźĺŞč˝ĺĺ°ć°çšĺć­Łć°ä˝
    if length < 0 then
        length = 0;
    end
    if data == nil then
        return 0;
    end
    local _tmpData = math.pow(10, length);
    data = data * _tmpData;
    data = math.floor(data);
    return data / _tmpData;
end

-- 进入神器
function enterArtifact(callback)
    local isOpen,data = isTheFunctionAvailable(35)    
    if not isOpen then 
        XTHDTOAST(data.tip)
        return 
    end 
    local ownArtifact = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ARTIFACT)
    if ownArtifact and ownArtifact.godid then
        ownArtifact = {ownArtifact}
    end
    if #ownArtifact > 0 then 
        --主城界面选择神器
        local function getArtifact()
            local artifactData = gameData.getDataFromCSV("SuperWeaponUpInfo")
            table.sort(ownArtifact, function(a,b)
                if tonumber(artifactData[a.templateId].rank) == tonumber(artifactData[b.templateId].rank) then
                    return tonumber(artifactData[a.templateId]._type) < tonumber(artifactData[b.templateId]._type)
                else
                    return tonumber(artifactData[a.templateId].rank) > tonumber(artifactData[b.templateId].rank)
                end
            end)
            return ownArtifact[1].godid
        end
        local gid = getArtifact()
        XTHD.createArtifact(nil,nil, gid , callback)
    else 
        XTHDTOAST(LANGUAGE_TIPS_WORDS4)        
    end
end  

-- 更换界面
function replaceLayer(params)
	-- print("跳转界面的数据为：")
	-- print_r(params)

    params = params or {}
    local node = params.fNode or nil
    local id = tonumber(params.id or 0)
    local chapterId = params.chapterId or 0
    local callback = params.callback or nil
    local heroid = params.heroid or 1
    local zorder = params.zorder or 0
    local parent = params.parent or nil

    local functionId = params.functionId or 0

    local layerArr = {
        -- [1] = "src/fsgl/layer/LiLian/LiLianStageChapterView.lua",                      --ä¸ťçşżĺŻćŹ
        -- [2] = "src/fsgl/layer/LiLian/LiLianStageChapterView.lua",                      --ç˛žčąĺŻćŹ
        [1] = "src/fsgl/layer/LiLian/LiLianStageChapterLayer.lua",                      --ä¸ťçşżĺŻćŹ
        [2] = "src/fsgl/layer/LiLian/LiLianStageChapterLayer.lua",                      --ç˛žčąĺŻćŹ
        
        -- [1] = "src/fsgl/layer/LiLian/LiLianStageChapterView.lua",                      --ä¸ťçşżĺŻćŹ
        -- [2] = "src/fsgl/layer/LiLian/LiLianStageChapterView.lua",                      --ç˛žčąĺŻćŹ

        [3] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",                 --éĺ¸ĺŻćŹ  ććść˛Ąć
        [4] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",                 --çżĄçż ĺŻćŹ  ććść˛Ąć
        [5] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",                 --čŁ
        [6] = "",                         --çŤćĺşĺ
        [7] = "src/fsgl/layer/WanBaoGe/WanBaoGe.lua",                 
        [8] = "src/fsgl/layer/QiXingTan/QiXingTanchangeLayer.lua",                --ĺĽçč˝Ščąé
        [9] = "src/fsgl/layer/ZhongZu/ZhongZuMainLayer.lua",                                       --éľčĽĺĺş
        [10] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",                                                               --çŤćĺşĺ
        [11] = "",                 
        [12] = "src/fsgl/layer/LiLian/SaintBeastChangeLayer.lua",                 
        [13] = "src/fsgl/layer/common/SourceLackPop1.lua",
        [14] = "src/fsgl/layer/KaiShanCaiKuang/KaiShanCaiKuang.lua",             
        [15] = "src/fsgl/layer/ZhuCheng/ExchangeByIngotPopLayer1.lua",                 
        [16] = "src/fsgl/layer/QiXingTan/QiXingTanchangeLayer.lua",                 
        [17] = "src/fsgl/layer/ZhuangBei/ZhuangBeiSmeltLayer.lua",                 
        [18] = "src/fsgl/layer/QiXingTan/QiXingTanchangeLayer.lua",                 
        [19] = "src/fsgl/layer/QiXingTan/QiXingTanchangeEquipLayer.lua",                
        [20] = "src/fsgl/layer/HuoDong/HuoDongLayer.lua",                            --ç­žĺ°
        [21] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",                 
        [22] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",                 
        [23] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",                 
        [24] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",                 
        [25] = "src/fsgl/layer/JingJi/JingJiMainLayer.lua",    --çŤćĺş
        [26] = "src/fsgl/layer/ZhongZu/ZhongZuMainLayer.lua",                 
        [27] = "src/fsgl/layer/ZhongZu/ZhongZuMainLayer.lua",                 
        [28] = "src/fsgl/layer/ZhongZu/ZhongZuMainLayer.lua",                 
        [29] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",
        [30] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",
        [31] = "src/fsgl/layer/YingXiong/YingXiongInfoLayer.lua",
        [32] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",
        [33] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",
        [34] = "src/fsgl/layer/YingXiong/YingXiongInfoLayer.lua",                                 --34ăčąéçłťçť-ĺć
        [35] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",
        [36] = "src/fsgl/layer/YingXiong/YingXiongInfoLayer.lua",
        [37] = LANGUAGE_KEY_NOTOPEN,------"ććŞĺźĺŻ",
        [38] = "src/fsgl/layer/YingXiong/YingXiongInfoLayer.lua",
        [39] = "src/fsgl/layer/QiXingTan/QiXingTanchangeHeroSubLayer.lua",
        [40] = "src/fsgl/layer/QiXingTan/QiXingTanchangeEquipSubLayer.lua",    
        [41] = "src/fsgl/layer/TieJiangPu/TieJiangPuLayer.lua",
        [44] = "src/fsgl/layer/YingXiong/YingXiongInfoLayer.lua",    
		[66] = "src/fsgl/layer/KaiShanCaiKuang/KaiShanCaiKuang.lua",
		[78] = "src/fsgl/layer/RiChangRenWu/RiChangRenWuDestinyDiceLayer.lua",
		[58] = "src/fsgl/layer/QuXiongBiJi/QuXiongBiJiLayer.lua",
		[79] = "src/fsgl/layer/BangPai/BangPaiMain.lua",
		[80] = "src/fsgl/layer/ZhongZu/ZhongZuMainLayer.lua",
		[71] = "src/fsgl/layer/ShenBingGe/ShenBingGeLayer.lua",    
    }

    local function turnLayer(id)
        LayerManager.addLayout(requires(layerArr[id]):create(), {par = node, zz = zorder})
    end

    local function turnHeroScene(_type)
        local _data = {
                        _type = _type
                        ,_closeCallback = callback
                        ,heroId = heroid
                    }
        if SCENEEXIST.HEROINFOLAYER == true then
            LayerManager.pushModule(requires(layerArr[id]):create(_data))
        else
            LayerManager.pushModule(requires(layerArr[id]):create(_data))
        end
    end

    local function turnStageChapterScene(_chapterId,_ChapterType,node)
        LayerManager.addShieldLayout()
        local _data = {callBack = callback, target_instancingid = _chapterId, chapter_type = _ChapterType,parent = node}
        local layer = requires(layerArr[id]):create(_data)
        LayerManager.addLayout(layer)
    end
    if tonumber(functionId) > 0 then
        local _promptData = {}
        local _isAvailable = false
        _isAvailable,_promptData = isTheFunctionAvailable(functionId)
        if _isAvailable == nil or _isAvailable == false then
            XTHDTOAST(_promptData.tip or LANGUAGE_KEY_NOTOPEN)-----"ććść ćłĺźĺŻ")
            return
        end
    end
    if id == 1 then--1ăä¸ťçşżĺŻćŹ
        turnStageChapterScene(chapterId,ChapterType.Normal,node)
    elseif id == 2 then    --2ăç˛žčąĺŻćŹ
        local _elite_open_data = gameData.getDataFromCSV("FunctionInfoList", {["id"] = 19} )
            if tonumber(_elite_open_data["unlocktype"]) == 2 then
                if gameUser.getInstancingId() < tonumber(_elite_open_data["unlockparam"]) then
                XTHDTOAST(LANGUAGE_KEY_NOTOPEN)------"ç˛žčąĺŻćŹććŞĺźĺŻ!")
                return
            end
            if tonumber(_elite_open_data["unlocktype"]) == 1 then
                if gameUser.getLevel() < tonumber(_elite_open_data["unlockparam"]) then
                    XTHDTOAST(LANGUAGE_TIPS_OPEN_ELITE(_elite_open_data["unlockparam"]))------"ç˛žčąĺŻćŹććŞĺźĺŻ!")
                    return
                end
            end
        end
        turnStageChapterScene(chapterId,ChapterType.ELite,node)
    elseif id == 3 then    --3ăéĺ¸ĺŻćŹ
        XTHD.createGoldCopy(node,zorder)
    elseif id == 4 then
        XTHD.createJaditeCopy( node,zorder )
    elseif id == 5 then    --6ăčŁ
        XTHD.createEquipCopies(node,zorder)
    elseif id == 6 then    --6ăçĽĺ
        XTHD.createSaintBeastChapter(node,zorder)
    elseif id == 7 then    --7ăĺĺş
        gotoMaincity()
        XTHD.dispatchEvent({name = CUSTOM_EVENT.GOTO_SPECIFIEDBUILDING,data = {id = 4,isOpen = false} })
    elseif id == 8 then    --8ăĺĺ čĺŽéĺťşç­ 
        local _store = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create({which = 'yuanbao'})
        LayerManager.addLayout(_store)
    elseif id == 9 then    --9ăéľčĽĺĺşĺ
        local _store = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create({which = 'camp'})
        LayerManager.addLayout(_store)
    elseif id == 10 then    --10ăçŤćĺşĺ
        XTHD.createCompetitiveChange(node,zorder,chapterId)
    elseif id == 11 then    --11ăççźĺ
        XTHD.createSemltChange(node,chapterId)
    elseif id == 12 then    --12ăçĽĺ
        XTHD.createSaintBeastChange(node,callback,zorder)
    elseif id == 13 then    --13ăä˝ĺč´­äš°
        local StoredValue = requires(layerArr[id]):create({id=2,Callback=callback})--byhuangjunjian čˇĺžčľćşĺ
        cc.Director:getInstance():getRunningScene():addChild(StoredValue)
    elseif id == 14 then    --14ăĺ
      XTHD.createStoneGambling()
    elseif id == 15 then    --15ăĺ
        local _exchangeLayer = requires(layerArr[id]):create("feicui")
        if _exchangeLayer == nil then
            return
        end
        if zorder then 
            node:addChild(_exchangeLayer,zorder)
        else 
            node:addChild(_exchangeLayer)
        end 
    elseif id == 16 then    --16ăčŁ
		requires("src/fsgl/layer/WanBaoGe/WanBaoGe.lua"):createWithType(1, {par = node}) 
    elseif id == 17 then    --17ăççźçłťçť
        XTHD.createEquipSmeltLayer(callback)
    elseif id == 18 then   --18ăĺĽçč˝Ščąé
        XTHD.createExchangeLayer(node,nil,callback)
    elseif id == 19 then   --19ăĺĽçč˝ŠčŁ
        XTHD.createExchangeLayer(node,nil,callback,zorder)
    elseif id == 20 then    --20ăć´ťĺ¨çé˘
        requires(layerArr[id]):createWithTab(1)
    elseif id == 21 then    --21ăčłĺ°äťťĺĄ
        XTHD.createTask(node,callback,zorder,1)
    elseif id == 22 then    --22ăä¸ťçşżäťťĺĄ
        XTHD.createTask(node,callback,zorder,2)
    elseif id == 23 then    --23ăćĽĺ¸¸äťťĺĄ
        XTHD.createTask(node,callback,zorder,3)
    elseif id == 24 then    --24ăćŻçşżäťťĺĄ
        XTHD.createTask(node,callback,zorder,4)
    elseif id == 25 then    --25ăçŤćĺş
        XTHD.createCompetitiveLayer(node,callback,zorder)
    elseif id == 26 then    --26ăéľčĽçĽ­ć
        XTHDTOAST(LANGUAGE_KEY_NOTOPEN)------"ććŞĺźĺŻ")
    elseif id == 27 then    --27ăéľčĽćĺş        
        requires(layerArr[id]):create(nil,node)
    elseif id == 28 then    --28ăéľčĽäťťĺĄ
        requires(layerArr[id]):create(1,node,zorder)
    elseif id == 29 then    --29ăä¸ťĺĺťşç­-čłĺ°ĺŁćŽż
        gotoMaincity()
        XTHD.dispatchEvent({name = CUSTOM_EVENT.GOTO_SPECIFIEDBUILDING,data = {id = 3,isOpen = false} })
    elseif id == 30 then    --30ăä¸ťĺĺťşç­-
        gotoMaincity()
        XTHD.dispatchEvent({name = CUSTOM_EVENT.GOTO_SPECIFIEDBUILDING,data = {id = 4,isOpen = false} })
    elseif id == 31 then    --31ăčąéčżéś
        turnHeroScene("advance")
    elseif id == 32 then    --čżéś
         XTHD.createEquipLayer(nil,nil,2,callback)
    elseif id == 33 then    --ĺźşĺ
         XTHD.createEquipLayer(nil,nil,1,callback)
    elseif id == 34 then    --1ăčąéĺć
        local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("recycle")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
    elseif id == 35 then    --神器商店
        local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("Artifact")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
    elseif id == 36 then    --čąéĺçş§ćč˝
        turnHeroScene("skill")
    elseif id == 37 then    --ć´çť
        XTHD.createEquipLayer(nil,nil,3,callback)
    elseif id == 38 then    --čąéĺçş§
        turnHeroScene("levelup")
	elseif id == 39 or id == 40 or id == 41 then    
        LayerManager.addLayout(requires(layerArr[id]):create(node), {par = node, zz = zorder})
    elseif id == 42 then    --vipĺ
        XTHD.createRechargeVipLayer(node,nil,zorder)
    elseif id == 43 then    --vipĺĽĺą        
        XTHD.createVipLayer(node)
    elseif id == 44 then    --čąéĺçş§ćč˝
        turnHeroScene("property")
    elseif id == 45 then  ------çĽĺ¨éĺą
         XTHD.YaYunLiangCaoLayer(node)
    elseif id == 46 then  ------ä¸çBOSS
        LayerManager.createModule( "src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiLayer.lua", {par = node})
    elseif id == 47 then  ------ćŹčľäťťĺĄ
        requires("src/fsgl/layer/XuanShangRenWu/XuanShangRenWuLayer.lua"):createForLayerManager({node = node})
    elseif id == 48 or id == 49 then  ------ĺéçż ĺçżĄçż 
        XTHD.createStoneGambling()
    elseif id == 50 then  ------ĺ¤Šĺ˝éŞ°ĺ­
        print("jump to dice is okay ,the id is 50")
        XTHD.GodDiceLayer(node)
    elseif id == 51 then  ------äżŽç˝ćĺş
        XTHD.createXiuLuo(node)
    elseif id == 52 then -----ĺ¸Žć´žć
        BangPaiFengZhuangShuJu.createGuildLayer({parNode = node})
    elseif id == 53 or id == 54 or id == 55 then -----ĺ˘č´­ăćŹčľ
        local _tb = {"groupBuy","offer","XiuLuo","yuanbao"}
        local SaintBeastChangeLayer = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create({which = _tb[id-52],callback = callback}) -----Ă§Ä˝ÂÄşÂÂ¨ÄşÂÂÄşĹÂ
        LayerManager.addLayout(SaintBeastChangeLayer, {par = fNode, zz = zorder})
    elseif id == 56 then -----é˛čąĺĺş
        local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("flower")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
    elseif id == 57 then -----ĺĽ˝ĺ
        requires("src/fsgl/layer/HaoYou/HaoYouLayer.lua"):create(node)
    elseif id == 58 then -----ćąç­ž
        XTHD.createSeekTreasureLayer(node)
    elseif id == 59 then -----ćąç­ž
        XTHD.gotoDiffcultyCopy(node,nil, chapterId)
	elseif id == 60 then -----ćąç­ž
        requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenLayer.lua"):create()
	elseif id == 62 then
		XTHD.createChallengeChapter(node)	
	elseif id == 63 then
		XTHD.createHangUpLayer(node)
	elseif id == 64 then
		local storelayer = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create({which = 'yuanbao'}) 
		LayerManager.addLayout(storelayer)
	elseif id == 65 then
		local storelayer = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create({which = 'groupBuy'})
		LayerManager.addLayout(storelayer)
	elseif id == 66 then
		requires("src/fsgl/layer/DuoRenFuBen/DuoRenFuBenLayer.lua"):create()
	elseif id == 67 then
		local layer = requires("src/fsgl/layer/PopShop/PopShopLayer"):create("guild")
		cc.Director:getInstance():getRunningScene():addChild(layer)
		layer:show()
		layer:setName("Poplayer")
	elseif id == 68 then
		local storelayer = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create({which = 'camp'})
		LayerManager.addLayout(storelayer)
	elseif id == 69 then
		local storelayer = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create({which = 'strength'})
		LayerManager.addLayout(storelayer)
	elseif id == 70 then
		ClientHttp:requestAsyncInGameWithParams({
        modules = "openTree?",
        successCallback = function( data )
            local dataList = {}
            dataList._curExp = data.curExp
            dataList._maxExp = data.maxExp
            dataList._treeLevel = data.level 
            dataList._state = data.state
            dataList._List = data.list
            --self._addExperience = 0
            dataList._nextTime = data.nextTime/1000 - os.time()
            if dataList._nextTime <= 0 then
                dataList._nextTime = 0
            end
            dataList._freeCount = data.freeCount
            if data.result == 0 then
                -- dump(dataList,"获取服务器参数")
                local lifeTree = requires("src/fsgl/layer/ZhongZu/ShengMingZhiShu.lua"):create(dataList,node)
                LayerManager.addLayout(lifeTree)
            end
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    })
	elseif id == 71 then
		LayerManager.createModule( "src/fsgl/layer/XiongShouLaiXi/XiongShouLaiXiLayer.lua", {par = node} )
	elseif id == 72 then
		XTHD.createServantsChapter(node)
	elseif id == 73 then
		requires("src/fsgl/layer/WanBaoGe/WanBaoGe.lua"):createWithType(3, {par = node})   
	elseif id == 74 then
		local storelayer = requires("src/fsgl/layer/ShangCheng/ShangCheng.lua"):create({which = 'XiuLuo'})
		LayerManager.addLayout(storelayer)
	elseif id == 75 then
		XTHD.gotoDiffcultyCopy(node,nil, chapterId)
	elseif id == 76 then
		LayerManager.addShieldLayout()
		XTHD.YaYunLiangCaoLayer(node)
	elseif id == 77 then
		local layer = requires("src/fsgl/layer/YingXiong/YingXiongXianJi.lua"):create(node)
       -- LayerManager.addLayout(layer)
		cc.Director:getInstance():getRunningScene():addChild(layer)
	elseif id == 78 then
		XTHD.GodDiceLayer(cc.Director:getInstance():getRunningScene())
	elseif id == 79 then
		BangPaiFengZhuangShuJu.createGuildLayer( { parNode = cc.Director:getInstance():getRunningScene() })
	elseif id == 80 then
		requires("src/fsgl/layer/ZhongZu/ZhongZuMainLayer.lua"):create(nil,cc.Director:getInstance():getRunningScene())    
    end 
end

-----ĺ¤ć­ĺ˝ĺćĺŽçĺč˝IDçĺč˝ćŻĺŚĺźĺŻďźďźĺŚććŻĺťşç­ďźĺŻäťĽĺŞäź ĺťşç­IDďź
function isTheFunctionAvailable(funcID,buildID)   
    local function functionsAtType( _type,limit )
        local result = false
        if _type and limit then 
            if _type == 1 then ----ç­çş§
                local curLevel = gameUser.getLevel()
                if curLevel >= limit then 
                    result = true
                end 
            elseif _type == 2 then
                local block = gameUser.getInstancingId() 
                if block >= limit then 
                    result = true
                end 
            elseif _type == 3 then ---ĺŞĺ¤Š

            elseif _type == 4 then ----ćśé´ćŽľ

            end 
        end 
        return result
    end
    local funcData = gameData.getDataFromCSV("FunctionInfoList",{buildingid = buildID})
    local result
    if(funcData and funcData.buildingid) then
        result = functionsAtType(funcData.unlocktype,funcData.unlockparam)
        return result, funcData 
    end
    funcData = gameData.getDataFromCSV("FunctionInfoList",{id = funcID})
    if(funcData and funcData.id) then
        result = functionsAtType(funcData.unlocktype,funcData.unlockparam)
        return result, funcData 
    end
    return false,nil
end
--
function ChangeAttributeAnim(bnode,data)--[[ĺąć§ĺĺçšć-byhuangjunjian data={k,v},bnodeçšćçśčçš,dataćŻäťäšć ˇçş¸ĺ°ąčĄ¨ç°äťäšć ˇçş¸ä¸čŚäšąäź đˇ ]]
    local data = data or {w_attack=100, w_defense=200, hp=300, n_attack=-100, n_defense=200,power=-1000}
    local label_font_size = 30
    local label_sub = 40
    local animLabels = {}
    local  function createAttributeAnim(bnode)

        if bnode:getChildByName("_Panel_equip_anim") then
            bnode:getChildByName("_Panel_equip_anim"):removeFromParent()
        end

        _Panel_equip_anim = ccui.Layout:create()
        _Panel_equip_anim:setContentSize(bnode:getContentSize().width,bnode:getContentSize().height)
        _Panel_equip_anim:setAnchorPoint(0.5,0.5)
        _Panel_equip_anim:setPosition(bnode:getContentSize().width/2, bnode:getContentSize().height/2 - 50)
        _Panel_equip_anim:setName("_Panel_equip_anim")
        bnode:addChild(_Panel_equip_anim)
        
        for k,v in pairs(data) do
            local Label_wugong = XTHDLabel:create("外功+10",label_font_size)
            Label_wugong:setPosition(cc.p(_Panel_equip_anim:getContentSize().width/2, _Panel_equip_anim:getContentSize().height/2 - label_sub))
            _Panel_equip_anim:addChild(Label_wugong)
            Label_wugong:setVisible(false)
            if v > 0 then
                symbol = "+"
            else
                symbol = "-"
            end
            if symbol == "-" then
                Label_wugong:setString(tostring(k) .. tostring(v))--property[propertyStr[i]])
                Label_wugong:setColor(cc.c3b(255,0,0))
            else
                Label_wugong:setString(tostring(k)  ..symbol.. tostring(v)) --.. property[propertyStr[i]])
                Label_wugong:setColor(cc.c3b(0,255,0))
            end
            animLabels[#animLabels+1] = Label_wugong
        end
    end

    createAttributeAnim(bnode)
    _Panel_equip_anim:setVisible(true)


    if table.nums(animLabels) == 0 then
        return
    end

    for i=1,table.nums(animLabels) do
         local animLabel = animLabels[i]
        animLabel:enableShadow(cc.c4b(0, 0, 0, 255))
        animLabel:setOpacity(255)
        animLabel:setPosition(cc.p(_Panel_equip_anim:getContentSize().width/2, _Panel_equip_anim:getContentSize().height/2  + (i-1)*10))
        local pScaleTo = cc.ScaleTo:create(0.1,2.0)
        local pScaleTo1 = cc.ScaleTo:create(0.1,1.0)

        local pDelay = cc.DelayTime:create(1)

        local LabelAction = {}

        table.insert(LabelAction, pScaleTo)
        table.insert(LabelAction, pScaleTo1)
        table.insert(LabelAction, pDelay)
        table.insert(LabelAction, cc.CallFunc:create(function ()
            local fadeOut = cc.FadeOut:create(0.5)
            animLabel:runAction(fadeOut)

            local actionArray1 = {}
            table.insert(actionArray1, cc.FadeOut:create(0.5))
            table.insert(actionArray1, cc.DelayTime:create(0.5))
            animLabel:runAction(cc.Sequence:create(actionArray1))
        end))

        local pScaleToseq  = cc.Sequence:create(LabelAction)
        local pMoveTo = cc.MoveBy:create(0.3, cc.p(0,60))
        local pMoveBy = cc.MoveBy:create(1.5, cc.p(0,110))
        local actionArray2 = {}
        table.insert(actionArray2, pMoveTo)
        table.insert(actionArray2, pMoveBy)
        table.insert(actionArray2, pScaleToseq)

        local pspawn = cc.Spawn:create(actionArray2)

        animLabel:runAction(cc.Sequence:create(cc.DelayTime:create(0.5*(i-1)),cc.Show:create(), pspawn))

    end
end
-----ćžç¤şvipç­çş§ä¸čśłçĺŻščŻćĄ
function showVIPNotEnoughDialog( parent,vipleve )
    local confirmLayer = XTHDConfirmDialog:createWithParams({
        msg = LANGUAGE_FORMAT_VIPNOTENOUGH(vipleve)
    })
    confirmLayer:setCallbackRight(function( )
        confirmLayer:removeFromParent()
        XTHD.createRechargeVipLayer(parent)
    end)
    if parent then 
        parent:addChild(confirmLayer)
    end 
end

function showIngotNotEnoughDialog( parent,ingot )
    local confirmLayer = XTHDConfirmDialog:createWithParams({
        msg = LANGUAGE_FORMAT_TIPS44(ingot)
    })
    confirmLayer:setCallbackRight(function( )
        confirmLayer:removeFromParent()
        XTHD.createRechargeVipLayer(parent)
    end)
    if parent then 
        parent:addChild(confirmLayer)
    end 
end
----ĺĺťşĺ éćéŽ
function createSpeedButton( battleType, sCall)
    local _maxSpeedScale = BATTLE_SPEED.X1
    if gameUser.getLevel() < BATTLE_SPPEDX2_LIMIT then
        _maxSpeedScale = BATTLE_SPEED.X1
    -- else
    elseif gameUser.getVip() < gameUser.getVipBattleSpeedLimit() and gameUser.getLevel() < BATTLE_SPPEDX3_LIMIT then
        _maxSpeedScale = BATTLE_SPEED.X2
    else
        _maxSpeedScale = BATTLE_SPEED.X3
    end
    
    if BATTLE_TIME_SCALE > _maxSpeedScale then
        BATTLE_TIME_SCALE = _maxSpeedScale
    end
    local file_x1 = "res/image/tmpbattle/speed_x1.png"
    local file_x2 = "res/image/tmpbattle/speed_x2.png"
    local file_x3 = "res/image/tmpbattle/speed_x3.png"

    local speed_x_file = file_x1
    if BATTLE_TIME_SCALE == BATTLE_SPEED.X3 then
        speed_x_file = file_x3
    elseif BATTLE_TIME_SCALE == BATTLE_SPEED.X2 then
        speed_x_file = file_x2
    else
        BATTLE_TIME_SCALE = BATTLE_SPEED.X1
    end
    
    local btn_speed = XTHDPushButton:create(speed_x_file)
    --[[--čŽ°ĺ˝ä¸ä¸ćŹĄçĺ éĺç]]
    cc.Director:getInstance():getScheduler():setTimeScale(BATTLE_TIME_SCALE)
    btn_speed:setTouchEndedCallback(function() 
        if sCall then
            sCall()
        end
        local nowTimeScale = cc.Director:getInstance():getScheduler():getTimeScale()
        if nowTimeScale < BATTLE_SPEED.X2 then
            if BATTLE_SPEED.X2 > _maxSpeedScale then
                HttpRequestWithParams("speed",{speed = 1},function (data)
                    gameUser.setBattleSpeed(1)
                end)   
                nowTimeScale = BATTLE_SPEED.X1
                speed_x_file = file_x1
                XTHDTOAST(LANGUAGE_KEY_BATTLE_SPEEDX2TIP())
            else
                HttpRequestWithParams("speed",{speed = 2},function (data)
                    gameUser.setBattleSpeed(2)
                end)  
                nowTimeScale = BATTLE_SPEED.X2
                speed_x_file = file_x2  
            end
            btn_speed:initWithFile(speed_x_file)
        elseif nowTimeScale < BATTLE_SPEED.X3 then
            if BATTLE_SPEED.X3 > _maxSpeedScale then
                HttpRequestWithParams("speed",{speed = 1},function (data)
                    gameUser.setBattleSpeed(1)
                end)
                nowTimeScale = BATTLE_SPEED.X1
                speed_x_file = file_x1
                XTHDTOAST(BATTLE_SPPEDX3_LIMIT .. "级或Vip" .. gameUser.getVipBattleSpeedLimit() .. "即可享受3倍速战斗")
            else
                HttpRequestWithParams("speed",{speed = 3},function (data)
                    gameUser.setBattleSpeed(3)
                end)
                nowTimeScale = BATTLE_SPEED.X3
                speed_x_file = file_x3
            end
            btn_speed:initWithFile(speed_x_file)
        else
            if nowTimeScale ~= BATTLE_SPEED.X1 then
                btn_speed:initWithFile(file_x1)
            end
            HttpRequestWithParams("speed",{speed = 1},function (data)
                gameUser.setBattleSpeed(1)
            end)
            nowTimeScale = BATTLE_SPEED.X1
            speed_x_file = file_x1
        end
        BATTLE_TIME_SCALE = nowTimeScale
        cc.Director:getInstance():getScheduler():setTimeScale(BATTLE_TIME_SCALE)
    end)
    return btn_speed
end

function getAutoState( battleType )
    if battleType == BattleType.PVP_SHURA or 
      battleType == BattleType.PVP_GUILDFIGHT or 
      battleType == BattleType.MULTICOPY_FIGHT or battleType == BattleType.PVP_LADDER then
        return true, true
    end
    if gameUser.getLevel() < BATTLE_AUTO_LIMIT then 
        return false, true
    end
    local isAuto = cc.UserDefault:getInstance():getBoolForKey(gameUser.getUserId().."isNormalAuto")
    return isAuto, false
end
----ĺĺťşčŞĺ¨ćććéŽ
function createAutoButton(battleType, sCall)
    local isAuto, isLock = getAutoState(battleType)
    local btnAuto
    if isAuto then
        btnAuto = XTHDSprite:create("res/image/tmpbattle/autocombat_on.png")
    else
        btnAuto = XTHDSprite:create("res/image/tmpbattle/autocombat_off.png")
        -- if isLock then
        --     local _locker = cc.Sprite:create("res/image/common/lock_sp.png")
        --     btnAuto:addChild(_locker)
        --     _locker:setAnchorPoint(1,0.5)
        --     _locker:setPosition(btnAuto:getContentSize().width - 37,btnAuto:getContentSize().height*0.5)
        -- end
    end 
    -- btnAuto:setScale(0.7)
    btnAuto:setTouchEndedCallback(function() 
        if sCall then
            sCall()
        end
        if isLock then
            if gameUser.getLevel() < BATTLE_AUTO_LIMIT then 
                XTHDTOAST(LANGUAGE_AUTOBATTLETIP_LIMIT())-------"20çş§ĺźĺŻčŞĺ¨ćć")
            else
                XTHDTOAST(LANGUAGE_TIPS_WORDS230)
            end
            return 
        end
        local data = {}
        XTHD.dispatchEvent({
            name = EVENT_NAME_BATTLE_ISREPLAY,
            data = data,
        })
        if data.isReplay then
            XTHDTOAST("回放中不可修改")
            return
        end
        XTHD.dispatchEvent({
            name = EVENT_NAME_BATTLE_ISAUTO,
            data = data,
        })
        local isAuto = data.auto
        if isAuto == true then
            btnAuto:initWithFile("res/image/tmpbattle/autocombat_off.png")
            isAuto = false
        else
            btnAuto:initWithFile("res/image/tmpbattle/autocombat_on.png")
            isAuto = true
        end
        XTHD.dispatchEvent({
            name = EVENT_NAME_BATTLE_AUTO,
            data = {auto = isAuto}
        })
        -- if battleType == BattleType.PVE then         
            cc.UserDefault:getInstance():setBoolForKey(gameUser.getUserId().."isNormalAuto",isAuto)
        -- end 
    end)
    return btnAuto
end

function getStringLengthByCharactor(str)
    local list = {}
    local len = string.len(str)
    local i = 1 
    local j = 0
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
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        j = j + 1        
        table.insert(list, char)
    end
    return list, j
end
----ĺ°ć¸¸ćçć°ćŽĺşäťŹé˝ĺ¤ä˝
function resetDBDatas( )
    DBTableArtifact.DBData = {} ---
    DBTableEquipment.DBData = {}
    DBTableHero.resetData()
    DBTableHeroSkill.resetData()
    DBTableInstance.InstancingDBData = {}
    DBTableInstance.EliteInstancingDBData = {}
    DBTableInstance.InstancingRewardDBData = {}
    DBTableItem.DBData = {}
    DBUserTeamData.DBData = {}
    DBPetData.DBData = {}
end
----ĺťé¤ĺ­çŹŚä¸˛ä¸¤çŤŻçé´ĺźĺˇ
function getRideOfSingleQuote( str )
    if str and type(str) == "string" and #str > 2 then 
        local beginX = string.find(str,"'")
        local endX = string.find(str,"'",#str - 1)
        if beginX and endX then 
            return string.sub(str,beginX + 1,endX - 1)
        end 
    end 
    return str
end
-------čŽžç˝ŽćĺŽçlabelĺŻščąĄtintďźisup true äťćŹč˛ĺ°çťżč˛ tintďźisup false äťćŹč˛ĺ°çş˘č˛tint
function letTheLableTint(targ,isup)
    if targ and not targ._isRunning then
        targ._isRunning = true
        local time = 0.1
        local tint1 = nil 
        local tint2 = cc.TintTo:create(time,255,255,255) 
        if isup then ----äťćŹč˛ĺ°çťżč˛
            tint1 = cc.TintTo:create(time,0,255,0)
        else ----äťćŹč˛ĺ°çş˘č˛ 
            tint1 = cc.TintTo:create(time,255,0,0)
        end 
        local action = cc.Sequence:create(tint1,tint2)
        -- local action = cc.Sequence:create(cc.FadeOut:create(time),cc.FadeIn:create(time))
        targ:runAction(cc.Sequence:create(action,action:clone(),cc.CallFunc:create(function( )
            targ._isRunning = nil
        end)))  
    end 
end
-------ćˇťĺ pushscene------------
function fnMyPushScene( node )
    if not node then
        return
    end
    -- LayerManager.pushModule(node)
    local _scene = cc.Scene:create()
    _scene:addChild(node)
    cc.Director:getInstance():pushScene(_scene)
	local chartbtn = LayerManager.addChatRoom({sType = LiaoTianRoomLayer.Functions.Camp})
	chartbtn:retain()
	chartbtn:removeFromParent()
	_scene:addChild(chartbtn)
end

function createFailHttpTipToPop( ... )
    local show_msg = LANGUAGE_TIPS_WORDS210------"ĺ°äž ďźä˝ çç˝çťäźźäšĺşäşçšéŽé˘ďźčŻˇéčŻďź"
    local confirmDialog = XTHDConfirmDialog:createWithParams({msg = show_msg,leftVisible = false,isHide = false})
    local scene = cc.Director:getInstance():getRunningScene()
    scene:addChild(confirmDialog,100)
    XTHD.dispatchEvent({
        name = EVENT_NAME_BATTLE_RESUME,
    })

    local callbalc = confirmDialog:getContainerLayer()
    if callbalc ~= nil then
        callbalc:setTouchEndedCallback(function (  )

        end)
    end

    confirmDialog:setCallbackRight(function (  )
        confirmDialog:removeFromParent()
        cc.Director:getInstance():popScene() 
    end)
end

-- ĺĺťşĺĽ˝ĺĺ¤´ĺ
--[[
    params :
    iconID ĺ¤´ĺID
    campID éľčĽID
    level ç­çş§
]]--
function createFriendIcon( sParams )
    local params = sParams or {}
    local iconID = params.iconID
    local campID = params.campID
    local level = params.level
    local callFn = params.callFn
    if not iconID or iconID == 0 then 
        iconID = 1
    end 
    local _canTouch = callFn and true or false
    -- local icon = cc.Sprite:create("res/image/avatar/avatar_"..iconID..".jpg")
    local _normalNode = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById(iconID))
    local _selectedNode = XTHD.createSprite(XTHD.resource.getHeroAvatorImgById(iconID))
    local icon = XTHDPushButton:createWithParams({
        normalNode = _normalNode,
        selectedNode = selectedNode,
        musicFile = XTHD.resource.music.effect_btn_common,
        needSwallow = _canTouch,
        enable = _canTouch,
        endCallback = function ()
            if callFn then
                callFn()
            end
        end,
    })
    local iconBox = cc.Sprite:create("res/image/plugin/competitive_layer/hero_board.png")
    if iconBox and icon then 
        icon:addChild(iconBox)
        iconBox:setPosition(icon:getBoundingBox().width*0.5,icon:getBoundingBox().height*0.5)
        icon:setScale(0.75)
        -----level 
        if level then
            local _level = getCommonWhiteBMFontLabel(level)
            if _level then 
                iconBox:addChild(_level)
                _level:setAnchorPoint(0,0.5)
                _level:setPosition(5, _level:getBoundingBox().height*0.5 - 10)
            end 
        end
        ------camp
        if campID then
            local _campBox = cc.Sprite:create("res/image/homecity/city_player_levelBox.png")
            if _campBox then 
                iconBox:addChild(_campBox)
                _campBox:setPosition(iconBox:getBoundingBox().width - _campBox:getContentSize().width*0.5 + 5,_campBox:getContentSize().height / 2 - 3)
                ----camp icon 
                local campIcon = cc.Sprite:create("res/image/homecity/camp_icon"..campID..".png")
                if campIcon then 
                    _campBox:addChild(campIcon)
                    campIcon:setPosition(_campBox:getContentSize().width*0.5,_campBox:getContentSize().height*0.5)              
                end 
            end 
        end
    end
    local select_box = cc.Sprite:create("res/image/common/item_select_box.png")
    select_box:setPosition(icon:getBoundingBox().width*0.5, icon:getBoundingBox().height*0.5)
    select_box:setName("select_box")
    icon:addChild(select_box,3) 
    select_box:setVisible(false)
    icon.select_box = select_box
    return icon
end

-------ćĺ°čćś------------
local mTime = 0
local tagTable = {"wm____time ","",":",0}
function printTime( index, tag )
    if(not index) then
        mTime = os.clock()
        return
    end
    local pTime = os.clock()
    tagTable[2] = tostring(tag)
    tagTable[4] = pTime - mTime
    print(table.concat(tagTable))
    mTime = pTime
end

function getAnEsoterica( )
    local _logintips = gameData.getDataFromCSV("GuidanceNotes")
    local str = LANGUAGE_KEY_HERO_TEXT.smallSecret.._logintips[EsotericaIndex].tips ----------"ĺ°ç§çąďź" .. _logintips[EsotericaIndex].tips
    EsotericaIndex = EsotericaIndex + 1
    EsotericaIndex = EsotericaIndex % #_logintips + 1
    return str
end

local function _createOneWinInfo( _result )
    local _resultIcon
    if _result == 0 then
        _resultIcon = cc.Sprite:create("res/image/guild/guildWar/guildWar_resultFailureSp.png")
    elseif _result == 1 then
        _resultIcon = cc.Sprite:create("res/image/guild/guildWar/guildWar_resultWinSp.png")
    elseif _result == 2 then
        _resultIcon = cc.Sprite:create("res/image/guild/guildWar/guildWar_resultEvenSp.png")
    end
    return _resultIcon
end

--ĺĺťşä¸ćĄĺŻšćäżĄćŻUI
function createOneFightInfo(_info)
    local pNode = cc.Node:create()
    local _result = tonumber(_info.result)
    ---left
    local _leftDi = cc.Sprite:create("res/image/guild/guildWar/guildWar_attackBg.png")
    _leftDi:setAnchorPoint(1, 0.5)
    pNode:addChild(_leftDi)

    local pId = _info.leftId
    local sData = {templateId = pId, level = _info.leftLevel}
    local icon = HaoYouPublic.getFriendIcon(sData, {notShowCamp = true})
    if icon then
        icon:setScale(0.8)
        icon:setAnchorPoint(0, 0.5)
        icon:setPosition(100, _leftDi:getContentSize().height*0.5)
        _leftDi:addChild(icon)

        if _info.attackLore and _info.attackLore == 1 then
            local _sp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_beOver.png")
            icon:addChild(_sp)
            _sp:setPosition(icon:getContentSize().width*0.5, icon:getContentSize().height*0.5)
        elseif _result == 0 then
            local _sp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_failure.png")
            icon:addChild(_sp)
            _sp:setPosition(icon:getContentSize().width*0.5, icon:getContentSize().height*0.5)
        end
		if _info.teamId  then
			local _leftName = XTHDLabel:createWithSystemFont("第" .. _info.teamId .."场", "Helvetica", 20)
        _leftName:setColor(XTHD.resource.color.white_desc)
        _leftName:setAnchorPoint(cc.p(0, 0.5))
        _leftName:setPosition(cc.p(250 , _leftDi:getContentSize().height*0.5))
        _leftDi:addChild(_leftName)
    end
    end

    ----right
    local _rightDi = cc.Sprite:create("res/image/guild/guildWar/guildWar_defenceBg.png")
    _rightDi:setAnchorPoint(0, 0.5)
    pNode:addChild(_rightDi)
    pId = _info.rightId
    sData = {templateId = pId, level = _info.rightLevel}
    local icon = HaoYouPublic.getFriendIcon(sData, {notShowCamp = true})
    if icon then
        icon:setScale(0.8)
        icon:setAnchorPoint(1, 0.5)
        icon:setPosition(_rightDi:getContentSize().width - 100, _leftDi:getContentSize().height*0.5)
        _rightDi:addChild(icon)

        if _info.defendLore and _info.defendLore == 1 then
            local _sp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_beOver.png")
            icon:addChild(_sp)
            _sp:setPosition(icon:getContentSize().width*0.5, icon:getContentSize().height*0.5)
        elseif _result == 1 then
            local _sp = cc.Sprite:create("res/image/guild/guildWar/guildWarText_failure.png")
            icon:addChild(_sp)
            _sp:setPosition(icon:getContentSize().width*0.5, icon:getContentSize().height*0.5)
        end
		if _info.teamId  then
		 local _rightName = XTHDLabel:createWithSystemFont("第" .. _info.teamId .."场", "Helvetica", 20)
        _rightName:setColor(XTHD.resource.color.white_desc)
        _rightName:setAnchorPoint(cc.p(1, 0.5))
        _rightName:setPosition(cc.p(_rightDi:getContentSize().width - 250 , _leftDi:getContentSize().height*0.5))
        _rightDi:addChild(_rightName)
		end

--         local _rightName = XTHDLabel:createWithSystemFont(_info.rightName, "Helvetica", 20)
--        _rightName:setColor(XTHD.resource.color.white_desc)
--        _rightName:setAnchorPoint(cc.p(1, 0.5))
--        _rightName:setPosition(cc.p(_rightDi:getContentSize().width - 250 , _leftDi:getContentSize().height*0.5))
--        _rightDi:addChild(_rightName)
    end

   
    ----result
    local _showResult = _info.showResult == nil and true or _info.showResult
    if _showResult then
        local _resultIcon = _createOneWinInfo(_result)
        if _resultIcon then
            pNode:addChild(_resultIcon)
        end
    end
    return pNode
end

function createOneFightInfoForLRInfos( _info )
    if _info.leftInfos and _info.rightInfos then
        local _nodes = {}
        for i=1,#_info.leftInfos do
            local _lData = _info.leftInfos[i]
            local _rData = _info.rightInfos[i]
            local _pInfo = {
                result = _info.result,
                leftId = _lData.petId,
                rightId = _rData.petId,
                leftLevel = _lData.level,
                rightLevel = _rData.level, 
                leftName = gameData.getDataFromCSV("GeneralInfoList",{heroid = _lData.petId}).name,
                rightName = gameData.getDataFromCSV("GeneralInfoList",{heroid = _rData.petId}).name,
                showResult = false,
            }
            local pNode = createOneFightInfo(_pInfo)
            _nodes[#_nodes + 1] = pNode
        end
        local _node = cc.Node:create()
        if #_nodes == 1 then
            _node:addChild(_nodes[1])
        elseif #_nodes == 2 then
            _node:addChild(_nodes[1])
            _node:addChild(_nodes[2])
            _nodes[1]:setPositionY(47)
            _nodes[2]:setPositionY(-47)
        end
        local _resultIcon = _createOneWinInfo(tonumber(_info.result))
        if _resultIcon then
            _node:addChild(_resultIcon)
        end
        return _node
    else
        return createOneFightInfo(_info)
    end
end

--ĺĺťşä¸ä¸ŞĺŻšćçťćĺźšçŞ
function createOneFightTips( par, _info, callBack )
    local _lay = cc.LayerColor:create(cc.c4b(0,0,0,120))
    _lay:setTouchEnabled(true)
    local function touchCall( eventType, x, y )
        if (eventType == "began") then
            return true
        end
    end
    _lay:registerScriptTouchHandler(touchCall)
    par:addChild(_lay)
    --čćŻ
    local _popBgSprite = cc.Sprite:create("res/image/tmpbattle/robbery_bg.png")
    _popBgSprite:setPosition(_lay:getContentSize().width*0.5, _lay:getContentSize().height*0.5)
    _lay:addChild(_popBgSprite)
    local _size = _popBgSprite:getContentSize()
    --çťć
    local effTitle
    local _result = tonumber(_info.result)
    if _result == BATTLE_RESULT.WIN  then--ćĺ
        effTitle = sp.SkeletonAnimation:create( "res/spine/effect/battle_win/shengli_01.json", "res/spine/effect/battle_win/shengli_01.atlas",1.0)
        effTitle:setAnimation(0,"shengli_01",false)
	effTitle:setScale(0.6)
    elseif _result == BATTLE_RESULT.FAIL  then--ĺ¤ąč´Ľ
        effTitle = cc.Sprite:create("res/image/tmpbattle/result_faild.png")
    elseif _result == BATTLE_RESULT.TIMEOUT  then--čś
        effTitle = cc.Sprite:create("res/image/guild/guildWar/guildWar_evenSp.png")
    end
    if effTitle  then
        if _result == BATTLE_RESULT.WIN  then
            effTitle:setPosition(_size.width*0.5, _size.height-140)
            _popBgSprite:addChild(effTitle)
        else
		    effTitle:setPosition(_size.width*0.5, _size.height)
            _popBgSprite:addChild(effTitle)
        end
    end

    local pNode = createOneFightInfoForLRInfos(_info)
    pNode:setPosition(cc.p(_size.width*0.5, _size.height*0.5))
    _popBgSprite:addChild(pNode)

    local function getBtnNode(imgpath,_size,_rect)
        local btn_node = ccui.Scale9Sprite:create(_rect,imgpath)
        btn_node:setContentSize(_size)
        btn_node:setCascadeOpacityEnabled(true)
        btn_node:setCascadeColorEnabled(true)
        return btn_node
    end

    local _isTouched = false
    local function _endCall( ... )
        if _isTouched then
            return
        end
        _isTouched = true
        _lay:removeFromParent()
        _lay = nil
        if callBack then
            callBack()
        end
    end
    local backbtn = XTHD.createCommonButton({
            btnSize = cc.size(142,49),
            isScrollView = false,
            text = LANGUAGE_BTN_KEY.continue,
            anchor = cc.p(0.5, 0),
            pos = cc.p(_size.width*0.5, 20),
            endCallback = function ( ... )
               _endCall()
            end
        })
    _popBgSprite:addChild(backbtn)
    performWithDelay(_lay, _endCall, 10)
end

function gotoMaincity( ) ----ç´ćĽĺťä¸ťĺ
    LayerManager.popModuleToDefult()
    LayerManager.removeLayoutToDefult()
end


-- {par = ćżč˝˝çśçąťďź failCall = ĺ¤ąč´Ľ/ć ć´ć°-ĺč°ďź succCall = éčŚć´ć°-ĺč°, loadingType = ćžç¤şloading
function checkUpdate( sParams )
    local params = sParams or {}
    if not sParams.par then
        if params.failCall then
            params.failCall()
        end
        return
    end
    if not getFlagUpdate() then
        if params.failCall then
            params.failCall()
        end
        return
    end
      --č§ŁććŹĺ°Manifestćäťś
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
    local manifest = table


    if manifest == nil then
        if params.failCall then
            params.failCall()
        end
        return
    end

    local version_str = manifest["version"] .. "." .. manifest["svn"]
    if manifest.version == "5.0.0" then
        ISFIRSTUPDATE = true
    else
        ISFIRSTUPDATE = false
    end

    local testing = ""
    if manifest["testing"] ~= nil then
        testing = "&testing=" .. manifest["testing"]
    end

    -- local GAME_UPDATE_CHANNEL = "appstore"
    -- čŻˇćąćć°ççćŹäżĄćŻ
    local lastVersionParams = {
        url = manifest["lastVersionUrl"] .. "&bundle=" .. manifest["bundle"] .. "&version=" .. manifest["version"] .. "&update_channel=" .. manifest["update_channel"] .. testing,
        successCallback = function(data)
            if data ~= nil then
                if tonumber(data.status) == 1 or tonumber(data.status) == 5 then --
                    if params.succCall then
                        params.succCall(data)
                    end
                    return
                end
            end 
            if params.failCall then
                params.failCall()
            end
        end,
        failedCallback = function()
            if params.failCall then
                params.failCall()
            end
        end,
        targetNeedsToRetain = params.par,
        loadingParent = params.par,
        loadingType = params.loadingType,
        encrypt = HTTP_ENCRYPT_TYPE.NONE,
    }

    XTHDHttp:requestAsyncWithParams(lastVersionParams)
    return manifest
end

function createAnimal( params )
    local id = params.id
    local _type = params._type
    if _type == ANIMAL_TYPE.PLAYER and not params.helps and not params.data then
        local pData = DBTableHeroSkill.getHeroSkillDatasForFight(id)
        local pData2 = DBTableHero.getHeroDatasForFight(id)
        if pData == nil or pData2 == nil then
            return nil
        end
    end
    return Character:createWithParams(params)
end

function animalClickedAnimation(params)
    --rotation,randValue,path,attacker,beAttacker
    local _clickedSp = XTHD.createSprite(params.path)
    _clickedSp:setAnchorPoint(cc.p(1,0.5))
    _clickedSp:setRotation(params.rotation)
    _clickedSp:setScale(params.attacker:getScaleY())
    params.beAttacker:addNodeForSlot({node = _clickedSp , slotName = "midPoint" , zorder = 10})
    if params.beAttacker:getScaleX()<0 then
        _clickedSp:setScaleX(-1*_clickedSp:getScaleX())
    end
    _clickedSp:setPosition(cc.p(params.randValue,params.randValue))
    _clickedSp:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.FadeOut:create(0.1),cc.CallFunc:create(function()
            _clickedSp:removeFromParent()
        end)))
end

function doFuncForAllChild( sNode, sFunc )
    local function _func_( _node ) 
        sFunc(_node)
        local _children = _node:getChildren()
        for k,node in pairs(_children) do
            _func_(node)
        end
    end
    _func_(sNode)
end

--ćˇťĺ appstoreççćŹĺ¤ĺŽćšćłďźćšäžżć§ĺśĺŽĄć ¸éśćŽľççšćŽĺ¤ç
function IS_APP_STORE_CHANNAL()
    return false
end

function getHeroDubEffectNamePath(_heroid,_action)
    local _nameTable  = {
        idle = "idle",
        run = "run",
        atk0 = "atk0",
        atk1 = "atk1",
        atk2 = "atk2",
        atk3 = "atk3",
        atk = "atk",
        atkd = "atkd",
        death = "death",
        win = "joke",
    }
    local _actionName = _nameTable[tostring(_action)] or ""
--    if _heroid == 1 then
--        _actionName = ""
--    end
    local _path = "res/sound/hero/voice_hero_" .. _heroid .. "_" .. _actionName .. ".mp3"
    -- if not cc.FileUtils:getInstance():isFileExist(_path) then
    --     local _newAction = math.random(1,2) == 1 and "idle" or "joke"
    --     if _heroid == 3 then
    --         _newAction = "joke"
    --     elseif _heroid == 13 or _heroid == 15 or _heroid == 25 or _heroid == 37 then
    --         _newAction = "idle"
    --     end
    --     _path = "res/sound/hero/voice_hero_" .. _heroid .. "_" .. _newAction .. ".mp3"
    -- end
    return _path
end


function getServerName( serverId, serverName )
    if not serverName then
        return ""
    end
    local _num = tonumber(serverId) or 0
    _num = _num%1000
    -- return "援军" .. _num .. " " .. tostring(serverName)
    return tostring(serverName)
end

function getShareImg()
    return "res/image/shareImg.png"
end

--获取分享图片链接地址
function getShareImgFilePath()
    -- 获取一张分享的图片
    local shareImg = getShareImg()

    if cc.FileUtils:getInstance():isFileExist(shareImg) then 
        local sprite = cc.Sprite:create(shareImg)
        sprite:setAnchorPoint(0, 0)
        sprite:setPosition(0, 0)

        local spriteS = sprite:getContentSize()

        --邀请码
        local uiIdLabel = XTHD.createLabel({
            text      = 12345678,
			fontSize  = 16,
			anchor    = cc.p(0, 0.5 ),
			pos       = cc.p(spriteS.width * 0.1, spriteS.height * 0.1),
			color     = cc.c3b(255, 112, 62),
        })

        sprite:addChild(uiIdLabel);

        local contentSize = spriteS
        local view = cc.Director:getInstance():getOpenGLView()
        local plicy = view:getResolutionPolicy()
        local viewSize = view:getDesignResolutionSize()
        view:setDesignResolutionSize(contentSize.width, contentSize.height, plicy)

        local gl_depth24_stencil8 = 0x88F0
        local eFormat = 2
        local screenshot = cc.RenderTexture:create(contentSize.width, contentSize.height, eFormat, gl_depth24_stencil8)
        screenshot:begin()
        sprite:visit()
        screenshot:endToLua()
        local screenshotFileName = string.format("fb-%s.jpg", os.date("%Y-%m-%d_%H:%M:%S", os.time()))
        local shareImgFilePath = cc.FileUtils:getInstance():getWritablePath() .. screenshotFileName

        print("shareImgFilePath： "..shareImgFilePath)
        screenshot:saveToFile(screenshotFileName, cc.IMAGE_FORMAT_JPEG, false)
            --reset 恢复上面设置的大小
        view:setDesignResolutionSize(viewSize.width, viewSize.height, plicy)

        return shareImgFilePath
    end
end

function print_r(t)  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] : "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] : "'..val..'"')
                    else
                        print(indent.."["..pos.."] : "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

--刷新属性，背包和神器
function RefreshAllData(data)
    --保存背包信息
    for i=1,#data["items"] do
        local item_data = data["items"][i]
        if item_data.count and tonumber(item_data.count) ~= 0 then
            DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
        else
            DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
        end
    end

    --保存用户属性
    local property = data["property"]
    if property then
        for i=1,#property do
            local pro_data = string.split( property[i],',')
              DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
        end
    end
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息

    --保存神器信息
    local gods = data["gods"]
    if gods then
        for i=1,#gods do
            DBTableArtifact.analysDataAndUpdate(gods[i])
        end
    end

    local servants = data["servants"]

    if servants then
        for i=1,#servants do
            DBPetData.analysDataAndUpdate(servants[i])
        end
    end

    -- dump(DBPetData)
    
    RedPointManage:reFreshDynamicItemData()

    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})      --刷新topbar数据
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的，
end

function HttpRequestWithOutParams(modules,callback,callback_2)
    ClientHttp:requestAsyncInGameWithParams({
        modules = modules.."?",
        successCallback = function( data )
            if tonumber( data.result ) == 0 then
                callback(data)
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST("您的网络已断开，请重新登录")------"网络请求失败")
			if callback_2 then
				callback_2()
			end
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    })  
end

function HttpRequestWithParams(modules,params,callback)
    ClientHttp:requestAsyncInGameWithParams({
        modules = modules.."?",
        params = params,
        successCallback = function( data )
            if tonumber( data.result ) == 0 then
                callback(data)
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    })  
end

function NumToCharArray(num)
    local list = {}
    for i = 1,string.len(num) do
        list[i] = string.sub(tostring(num),i,i)
    end
    return list
end

function showBadWebDialog( )
    local function back2LoginLayer(relogin)
        cc.Director:getInstance():popToRootScene()
        XTHD.replaceToLoginScene(relogin)
        -- XTHD.logout()
    end

    local layer = XTHDConfirmDialog:createWithParams({
        msg = "长时间未操作，请重新登录！",--LANGUAGE_KEY_NETWORKERROR,--------"网络连接异常，请重新登录",
        leftVisible = false,
        rightCallback = function( )      
            MsgCenter:reset()     
            back2LoginLayer()
            -- XTHDHttp:requestAsyncInGameWithParams({
            --     modules = "newToken?",
            --     params = {passportId = gameUser.getPassportID()},
            --     successCallback = function(data)
            --         if tonumber(data.result) == 0 then
            --             gameUser.setToken(data.token)
            --             gameUser.setNewLoginToken(data.token) 
            --             -- back2LoginLayer(true)
            --             back2LoginLayer()
            --         else 
            --             back2LoginLayer()
            --         end
            --     end,
            --     failedCallback = function()
            --         back2LoginLayer()
            --     end,--失败回调
            --     loadingType = HTTP_LOADING_TYPE.NONE,
            -- })
        end
    })
    layer:setName("webReconnectDialog")
    layer:getContainerLayer():setClickable(false)
    local scene = cc.Director:getInstance():getRunningScene()
    if scene and not scene:getChildByName("webReconnectDialog") then 
        scene:addChild(layer,1024)
    end 
end

function showDingHaoDialog( )
    local function back2LoginLayer(relogin)
        cc.Director:getInstance():popToRootScene()
        XTHD.replaceToLoginScene(relogin)
        XTHD.logout()
    end

    local layer = XTHDConfirmDialog:createWithParams({
        msg = "您的账号在其他地方被登录，如不是本人操作，请及时修改密码!",
        leftVisible = false,
        rightCallback = function( )      
            MsgCenter:reset()     
            back2LoginLayer()
        end
    })
    layer:setName("webReconnect1Dialog")
    layer:getContainerLayer():setClickable(false)
    local scene = cc.Director:getInstance():getRunningScene()
    if scene and not scene:getChildByName("webReconnect1Dialog") then 
        scene:addChild(layer,1025)
    end 
end

function showDisconnectTip( )
    local function back2LoginLayer(relogin)
        cc.Director:getInstance():popToRootScene()
        XTHD.replaceToLoginScene(relogin)
        -- XTHD.logout()
    end

    local layer = XTHDConfirmDialog:createWithParams({
        msg = "网络已断开，正在重连中...\n".."           "..CONNECTTIME,
        leftVisible = false,
        rightVisible = false,
        -- rightCallback = function( )      
        --     MsgCenter:reset()     
        --     back2LoginLayer()
        -- end
    })
    layer:setName("webReconnect2Dialog")
    layer:getContainerLayer():setClickable(false)
    local scene = cc.Director:getInstance():getRunningScene()
    if scene and not scene:getChildByName("webReconnect2Dialog") then 
        scene:addChild(layer,1023)
    end 

    local node = cc.Director:getInstance():getNotificationNode()
    node:stopActionByTag(10000)
    schedule(node, function(dt)
        CONNECTTIME = CONNECTTIME - 1
        if CONNECTTIME < 0 then
            node:stopActionByTag(10000)
            MsgCenter:reset()     
            back2LoginLayer()
            return
        end
        MsgCenter:doReconnect()
        scene:getChildByName("webReconnect2Dialog"):setMsg("网络已断开，正在重连中...\n".."           "..CONNECTTIME)
    end,1,10000)
end

--计算刘海屏x轴偏移像素点
function GetScreenOffsetX()
    local offsetX = math.max((screenRadio - 1024/615)*ScreenOffsetX,0)
    return offsetX
end
