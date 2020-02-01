--[[游戏中常见的资源都在这里获取]]
XTHD = XTHD or {}
XTHD.resource = XTHD.resource or {}
textureCache = cc.Director:getInstance():getTextureCache()

XTHD.resource.visibleSize = cc.size(922,576)
--[[
常用资源类型，和数据表对应
例如，服务器返回1，就代表是经验
]]
XTHD.resource.type = {
    exp = 1,            --[[经验]]
    gold = 2,           --[[银两]]
    ingot = 3,          --[[元宝]]
    item = 4,           --[[道具]]
    tili = 5,           --[[体力]]
    feicui = 6,         --[[翡翠]]
    prestige = 7,       --[[威望]]
    xueyu = 8,          --[[血玉]]
    honor = 9,          --[[荣誉]]
    stone = 10,         --[[神石]]
    servant = 15,       --[[万灵魂]]
    contribution = 11,  --[[帮派贡献]]
    reward = 12,        --[[奖牌]]
    energy = 13,        --[[精力]]
    soul_green = 21,    --[[绿魂石]]
    soul_blue = 22,     --[[蓝魂石]]
    soul_purple = 23,   --[[紫魂石]]
    soul_red = 24,      --[[赤魂石]]
    azure = 30,         --[[轩辕]]
    white = 31,         --[[盘古]]
    vermilion = 32,     --[[伏羲]]
    black = 33,         --[[昆仑]]
    heroexp = 40,       --[[英雄经验]]
    hero =50,           --[[英雄]]
    cityExp = 51,       ------[种族城市经验]
    smeltPoint = 100,   --[[回收点数]]
    jade_1 = 101,       --[[1级翡翠石]]
    jade_2 = 102,       --[[2级翡翠石]]
    jade_3 = 103,       --[[3级翡翠石]]
    gold_1 = 104,       --[[1级金银矿石]]
    gold_2 = 105,       --[[2级金银矿石]]
    gold_3 = 106,       --[[3级金银矿石]]
    bounty = 200,       --[[赏金]]
    reputation = 201,   --[[声望]]
    asura_blood = 202,  --[[修罗血]]
    guild_contri = 203, --[[帮派贡献]]
    flower = 204,       --[[鲜花]]
    soul   = 205,       --[[魂玉]]
    luckyCoin = 206,    --[[幸运币]]
    zhenQi    = 207,    --[[韬略]]
    servant_qly = 501,  --[[侍仆·千鸟樱]]
    servant_qcj = 502,   --[[侍仆·浅仓镜]]
    servant_yly = 503,   --[[侍仆·亚里亚]]
    servant_msy = 504,   --[[侍仆·麻神一]]
    servant_qzl = 505,   --[[侍仆·青佐木]]
}

XTHD.resource.propertyToType = {
    [400] = nil,--级别
    [401] = nil,--当前hp
    [402] = XTHD.resource.type.gold,--银币
    [403] = XTHD.resource.type.ingot,--元宝
    [404] = nil,--当前状态
    [405] = nil,--绑定状态
    [406] = nil,--VIP等级
    [407] = nil,--战力
    [408] = nil,--称号idr
    [409] = nil,--活跃度
    [410] = nil,--当前体力
    [411] = nil,--最大体力
    [412] = nil,--购买体力次数
    [413] = XTHD.resource.type.exp,--当前经验值
    [414] = nil,--最大经验值
    [415] = nil,--升星等级 
    [416] = nil,--品阶等级
    [417] = nil,--剩余技能点
    [418] = XTHD.resource.type.feicui,--翡翠
    [419] = nil,--精力
    [420] = nil,--竞技场掠夺的总翡翠
    [421] = nil,--竞技场掠夺的总银币
    [422] = nil,--竞技场掠夺的总次数
    [423] = nil,--种族id
    [424] = nil,--远征次数
    [425] = nil,--货币兑换次数 
    [426] = XTHD.resource.type.honor,--荣誉值
    [427] = nil,--绿魂石
    [428] = nil,--蓝魂石
    [429] = nil,--紫魂石
    [430] = nil,--赤魂石
    [431] = XTHD.resource.type.stone,       --神石
    [432] = XTHD.resource.type.guild_contri,--帮派贡献
    [433] = nil,--每天增加的势力点数
    [434] = nil,--累计增加的势力点数
    [435] = nil,--膜拜次数
    [438] = XTHD.resource.type.reward,   --[奖牌]
    [446] = XTHD.resource.type.bounty,   --[赏金令牌] 
    [456] = XTHD.resource.type.soul,     --[魂玉] 
    [457] = XTHD.resource.type.luckyCoin,--[[幸运币]]
    [459] = XTHD.resource.type.zhenQi,   --[[韬略]]
    [460] = XTHD.resource.type.servant,  --[[万灵魂]]
}

--装备进阶消耗银两系数
XTHD.resource.advanceGoldCoefficient = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 5,
    [5] = 7,
    [6] = 10,
}

XTHD.resource.quality = {
    white = 1,
    green = 2,
    blue = 3,
    purple = 4,
    orange = 5,
    red = 6
}

XTHD.resource.name = LANGUAGE_TABLE_RESOURCENAME

XTHD.resource.description = LANGUAGE_RESOURCEDESCRIBETIONS

XTHD.resource.PVE11GiveIngot = 0

function XTHD.resource.getButtonImgTxt(_imgName)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/fonts/common_btnText.plist", "res/fonts/common_btnText.png")
    local _btnImgSF = cc.SpriteFrameCache:getInstance():getSpriteFrame(_imgName..".png")
    local _btnImgTxt = cc.Sprite:createWithSpriteFrame(_btnImgSF)
   
    --最好加一个错误判断，
    if not _btnImgTxt then
        _btnImgTxt = cc.Sprite:create()
    end
    return _btnImgTxt
end

function XTHD.resource.getAttrLabel(attrName)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/fonts/attr_name.plist", "res/fonts/attr_name.png")
    local _btnImgSF = cc.SpriteFrameCache:getInstance():getSpriteFrame(attrName..".png")
    local _btnImgTxt = cc.Sprite:createWithSpriteFrame(_btnImgSF)
   
    --最好加一个错误判断，
    if not _btnImgTxt then
        _btnImgTxt = cc.Sprite:create()
    end
    return _btnImgTxt
end

XTHD.resource.getAttrStrByProperty = {
    [200] = "shengmingshangxian",
    [201] = "waigongshanghai",
    [202] = "waigongfangyu",
    [203] = "neigongshanghai",
    [204] = "neigongfangyu",
    [300] = "mingzhonglv",
    [301] = "shanbilv",
    [302] = "baojilv",
    [303] = "baojishanghai",
    [304] = "baoshangjianmian",
    [305] = "shanghaijianmian",
    [306] = "shanghaichuantou",
    [307] = "waishangjianmian",
    [308] = "waishangchuantou",
    [309] = "neishangjianmian",
    [310] = "neishangchuantou",
    [311] = "xixue",
    [312] = "zhiliaojiacheng",
    [313] = "shoudaozhiliao",
    [314] = "xiaohaojianmian",
    [315] = "shengminghuifu",
    [316] = "nuqihuifu",
}
    
XTHD.SystemFont = "Helvetica"


function XTHD.resource.getNormalChapterNameSpFrame(chapter_id)
      local _btnImgSF = cc.SpriteFrameCache:getInstance():getSpriteFrame("normal_"..chapter_id..".png")
    if _btnImgSF == nil then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("res/image/plugin/stageChapter/chapter_name.plist", "res/image/plugin/stageChapter/chapter_name.png")
        _btnImgSF = cc.SpriteFrameCache:getInstance():getSpriteFrame("normal_"..chapter_id..".png")
    end
    return _btnImgSF
end

function XTHD.resource.getEliteChapterNameSpFrame(chapter_id)
     local _btnImgSF = cc.SpriteFrameCache:getInstance():getSpriteFrame("elite_"..chapter_id..".png")
    if _btnImgSF == nil then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("res/image/plugin/stageChapter/chapter_name.plist", "res/image/plugin/stageChapter/chapter_name.png")
        _btnImgSF = cc.SpriteFrameCache:getInstance():getSpriteFrame("elite_"..chapter_id..".png")
    end
    return _btnImgSF
end

--[[
    如果在按钮上面文本以节点的形式存在的时候，字需要改变纹理的情况下，使用该函数更为合适，只需要setTexture()即可，而该函数则返回对应的纹理
]]
function XTHD.resource.getButtonImgFrame(_imgName)
    local _btnImgSF = cc.SpriteFrameCache:getInstance():getSpriteFrame(_imgName..".png")
    if _btnImgSF == nil then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("res/fonts/common_btnText.plist", "res/fonts/common_btnText.png")
        _btnImgSF = cc.SpriteFrameCache:getInstance():getSpriteFrame(_imgName..".png")
    end
    if not _btnImgSF then
        _btnImgSF = cc.SpriteFrameCache:getInstance():getSpriteFrame("tiaozheng_lan.png")
    end
    return _btnImgSF
end

XTHD.resource.titleColor = cc.c4b(137,77,0,255)

XTHD.resource.color = {
--[[灰色，一般用于描述性文字]]
    -- gray_desc = cc.c3b(105, 77, 56),
    gray_desc = cc.c3b(54, 55, 112),
    white_desc = cc.c3b(255,255,255),
    green_desc = cc.c3b(54,255,48),
    blue_desc = cc.c3b(31,210,255),
    purple_desc = cc.c3b(243,53,255),
    orange_desc = cc.c3b(255,186,0),
    red_desc = cc.c3b(255,48,48),
    -- brown_desc = cc.c3b(70,34,34),
    brown_desc = cc.c3b(54,55,112),
}

XTHD.resource.textColor = {
    gray_text = cc.c3b(70, 34, 34),
    white_text = cc.c3b(255,255,255),
    green_text = cc.c3b(104,157,0), 
    blue_text = cc.c3b(26,158,207),
    purple_text = cc.c3b(243,53,255),
    orange_text = cc.c3b(255,186,0),
    red_text = cc.c3b(100,100,100),
    juhuang_text = cc.c3b(205,101,8),
    yellow_text = cc.c3b(255,240,0),
    huihuang_text = cc.c3b(194,126,8),
    anhong_text = cc.c3b(189,50,50),
    hongse_text = cc.c3b(204,64,2),
    blue_text_1 = cc.c4b(42,202,255,255),
    yellow_text = cc.c4b(255,232,104,255),
    green_text_1 = cc.c4b(40,206,47,255),
}

XTHD.resource.btntextcolor = {
    green = cc.c4b(59,115,0,255),
    red = cc.c4b(136,53,8,255),
    blue = cc.c4b(0,79,153,255),
    blue_1 = cc.c4b(0,79,115,255),
    gray = cc.c4b(160,76,43,255),
    black = cc.c4b(105,105,105,255),
    orange = cc.c4b(194,81,6,255),
    write = cc.c4b(255,255,255,255),
    write_1 = cc.c4b(255,255,255,255)
}

--[[游戏中常用的音乐文件]]
XTHD.resource.music = {
    music_bgm_main = "res/sound/sound_maincity_bg.mp3",--[[主城的背景音乐]]
    music_bgm_selectchapter="res/sound/sound_chapter_selected_bg.mp3",--[[关卡选择]]
    music_bgm_login="res/sound/sound_login.mp3",--[[登陆音乐]]
    music_bgm_camp = "res/sound/bgm_camp.mp3", ----[种族音乐]
    music_bgm_battle_pvp = "",--[[pvp的战斗音乐]]
	music_bgm_battle = "res/sound/bgm_02_battle_03.mp3",--普通副本战斗音乐
    effect_close_pop = "res/sound/sound_closePanel_effect.mp3",--[[窗口关闭的音效]]
    effect_open_pop="res/sound/sound_openPanel_effect.mp3",--[[窗口打开]]
    effect_btn_common = "res/sound/sound_clickBtn_effect.mp3",--[[按钮的默认点击音效]]
    effect_btn_commonclose="res/sound/sound_clickCloseBtn_effect.mp3",--[[默认按钮关闭]]
    effect_battle_victory="res/sound/sound_battle_victory.mp3",--[[胜利音效]]
    effect_battle_lost="res/sound/sound_battle_fail.mp3",--[[失败音效]]
    effect_reward_get="res/sound/sound_getReward_effect.mp3"--[[获得奖励]],
	effect_bangpai_bgm = "res/sound/bgm_bangpai.mp3",--帮派背景音乐
	effect_pvpMain_bg = "res/sound/bgm_battle_pvp.mp3",--竞技场背景音乐
	effect_seleceteHero_bgm = "res/sound/bgm_camp_02.mp3",--选中英雄背景音乐
	effect_jierikuanghuan_bgm = "res/sound/bgm_jieri_kuanghuan.mp3",--节日狂欢背景音乐
	effect_jingxiangzhilu_bgm = "res/sound/bgm_jingxiang.mp3",--镜像之路背景音乐
	effect_yanwuchang_bgm = "res/sound/bgm_yanwuchang.mp3",--演武场背景音乐
	effect_lilian_bgm = "res/sound/sound_chapter_selected_bg.mp3",--历练背景音乐
	effect_qixingtan_bgm = "res/sound/bgm_putong_fuben.mp3",--七星坛背景音乐
	effect_tujian_bgm = "res/sound/bgm_tujian.mp3"--图鉴背景音乐
}

XTHD.resource.bmfont = {
    white       = "res/fonts/baisezi.fnt",
    yellow      = "res/image/common/common_num/2.fnt",
    red         = "res/image/common/common_num/1-red.fnt",
    green       = "res/image/common/common_num/greenword.fnt",
}

function XTHD.resource.getEquipName(num)
    local EquipName = {}
    for i = 1,6 do 
        EquipName[i] = LANGUAGE_KEY_EQUIPGRIDNAME[i]
    end 
    return EquipName[tonumber(num)]
end

XTHD.resource.artifactSp = {
    [30] = "res/image/plugin/saint_beast/artifact_cerulean_gragon.png",
    [31] = "res/image/plugin/saint_beast/artifact_white_tiger.png",
    [32] = "res/image/plugin/saint_beast/artifact_vinaceous_rosefinch.png",
    [33] = "res/image/plugin/saint_beast/artifact_dragon_tortoise.png",
}

function XTHD.resource.getAttributes(num)
    return LANGUAGE_KEY_ATTRIBUTESNAME(tostring(num))
end

function XTHD.resource.addPercent(property,str)
    property = tonumber(property)
    if not property then
        return str
    end

    if property >= 300 and property < 315 then
        if XTHD.resource.getModfSecNum(str) == 0 then
            return str.."%"
        else
            str = string.format("%.1f",str)
            return str.."%"
        end
    else
        str = math.ceil(tonumber(str))
        return str
    end
end

function XTHD.resource.isPercent(property)
    property = tonumber(property)
    if not property then
        return false
    end

    if property >= 300 and property < 315 then
        return true
    else
        return false
    end
end

function XTHD.resource.getColor(color)
    local COLOR3B = {}
    COLOR3B["WHITE"] = cc.c3b(255,255,255)
    COLOR3B["GREEN"] = cc.c3b(251,5,28)
    COLOR3B["BLUE"] = cc.c3b(31,210,255)
    COLOR3B["PURPLE"] = cc.c3b(243,53,255)
    COLOR3B["ORANGE"] = cc.c3b(255,186,0)
    COLOR3B["RED"] = cc.c3b(255,48,48)
    return COLOR3B[color]
end

XTHD.resource.AttributesNum = {
    [1] = "200",
    [2] = "201",
    [3] = "202",
    [4] = "203",
    [5] = "204",
    [6] = "300",
    [7] = "301",
    [8] = "302",
    [9] = "303",
    [10] = "304",
    [11] = "305",
    [12] = "306",
    [13] = "307",
    [14] = "308",
    [15] = "309",
    [16] = "310",
    [17] = "311",
    [18] = "312",
    [19] = "313",
    [20] = "314",
    [21] = "315",
    [22] = "316"
}

XTHD.resource.AttributesName = {
    [200] = "hp",
    [201] = "physicalattack",
    [202] = "physicaldefence",
    [203] = "manaattack",
    [204] = "manadefence",
    [300] = "hit",
    [301] = "dodge",
    [302] = "crit",
    [303] = "crittimes",
    [304] = "anticrit",
    [305] = "antiattack",
    [306] = "attackbreak",
    [307] = "antiphysicalattack",
    [308] = "physicalattackbreak",
    [309] = "antimanaattack",
    [310] = "manaattackbreak",
    [311] = "suckblood",
    [312] = "heal",
    [313] = "behealed",
    [314] = "antiangercost",
    [315] = "hprecover",
    [316] = "angerrecover"
}

XTHD.resource.PetbutesName = {
    [200] = "hp",
    [201] = "physicalattack",
    [202] = "physicaldefence",
    [203] = "manaattack",
    [204] = "manadefence",
    [300] = "hit",
    [301] = "dodge",
    [302] = "crit",
    [303] = "crittimes",
    [304] = "anticrit",
    [305] = "antiattack",
    [306] = "attackbreak",
    [307] = "antiphysicalattack",
    [308] = "physicalattackbreak",
    [309] = "antimanaattack",
    [310] = "manaattackbreak",
    [311] = "suckblood",
    [312] = "heal",
    [313] = "behealed",
    [314] = "antiangercost",
    [315] = "hprecover",
    [316] = "angerrecover"
}


function XTHD.resource.getAttributesMax(itemid,num,strengLevel,isMax)--获取装备属性最大值 strengLevel强化等级
    local selectType = 2
    if isMax then
        selectType = isMax
    end
    local MaxNum = {}
    MaxNum["200"] = "hp"
    MaxNum["201"] = "physicalattack"
    MaxNum["202"] = "physicaldefence"
    MaxNum["203"] = "manaattack"
    MaxNum["204"] = "manadefence"
    MaxNum["300"] = "hit"
    MaxNum["301"] = "dodge"
    MaxNum["302"] = "crit"
    MaxNum["303"] = "crittimes"
    MaxNum["304"] = "anticrit"
    MaxNum["305"] = "antiattack"
    MaxNum["306"] = "attackbreak"
    MaxNum["307"] = "antiphysicalattack"
    MaxNum["308"] = "physicalattackbreak"
    MaxNum["309"] = "antimanaattack"
    MaxNum["310"] = "manaattackbreak"
    MaxNum["311"] = "suckblood"
    MaxNum["312"] = "heal"
    MaxNum["313"] = "behealed"
    MaxNum["314"] = "antiangercost"
    MaxNum["315"] = "hprecover"
    MaxNum["316"] = "angerrecover"

    local finalNum = tonumber(string.split(gameData.getDataFromCSV("EquipInfoList",{itemid = itemid})[MaxNum[num]],"#")[selectType]) or ""
    if finalNum ~= "" and tonumber(num) < 300 then
        finalNum = finalNum + finalNum*(strengLevel*0.06)--math.floor(finalNum*(strengLevel*0.06))
    end
    return finalNum
end

function XTHD.resource.getEquipment(userid,EquipType,orderby) --EquipType 1 返回所有装备 2 返回没穿上的装备 3 返回穿上的装备 默认为1
    local orderby = orderby or 1
    if not EquipType then
        EquipType = 1
    end
    local itemdata = DBTableItem.getDatasByPosition()
    if itemdata.dbid then
        itemdata = {itemdata}
    end
    
    for i=1,#itemdata do
        itemdata[i].weight = itemdata[i].quality*100000+itemdata[i].power
    end
    itemdata.itemNum = #itemdata

    local equipdata = gameData.getDataFromDynamicDB(nil,DB_TABLE_NAME_EQUIPMENT)
    if equipdata.dbid then
        equipdata = {equipdata}
    end
    table.sort(equipdata,function(a,b)
        return tonumber(a.power) < tonumber(b.power)
    end)

    for i=1,#equipdata do
        equipdata[i].rank = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = equipdata[i].itemid}).rank
        equipdata[i].name = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = equipdata[i].itemid}).name
        equipdata[i].weight = equipdata[i].rank*100000+equipdata[i].power
    end
    equipdata.equipNum = #equipdata


    sortFunc = function(t1, t2)
        if orderby == 1 then
            return t1.weight > t2.weight
        else
            return t1.weight < t2.weight
        end        
    end

    table.sort(itemdata, sortFunc)
    table.sort(equipdata, sortFunc)

    if EquipType == 2 then
        return itemdata
    elseif EquipType == 3 then
        return equipdata
    elseif EquipType == 1 then

        local tmpList = {}
        for i=1,#equipdata do
            tmpList[#tmpList+1] = equipdata[i]
        end
        for i=1,#itemdata do
            tmpList[#tmpList+1] = itemdata[i]
        end
        tmpList.itemNum = #itemdata
        tmpList.equipNum = #equipdata
        return tmpList
    end

end
--传入原来的属性值，改变后的属性值
function XTHD.resource.getBasePropertyToastTable(_oldtable,_changetable)
    local _toastBaseTable = {}
    if _changetable == nil or next(_changetable) ==nil then
        return _toastBaseTable
    end
    local _propertySubTable = {}
    for i=1,#XTHD.resource.AttributesNum do
        local _propertyOld = 0
        local _key = XTHD.resource.AttributesName[tonumber(XTHD.resource.AttributesNum[i])]
        if _oldtable[tostring(_key)]~=nil then
            _propertyOld = tonumber(_oldtable[tostring(_key)])
        end
        local _propertyChange = 0
        if _changetable[tostring(_key)]~=nil then
            _propertyChange = tonumber(_changetable[tostring(_key)])
        end
        local _subValue = _propertyChange - _propertyOld
        if tonumber(_subValue)~=0 then
            _propertySubTable[tostring(XTHD.resource.AttributesNum[i])] = _subValue
        end
    end
    for i=200,316 do
        if _propertySubTable[tostring(i)]~=nil then
            local _labelName = XTHD.resource.getAttributes(tonumber(i))
            -- if tonumber(_propertySubTable[tostring(i)])>0 then
            --     _labelName = _labelName .. "_lv"
            -- else
            --     _labelName = _labelName .. "_hong"
            -- end
            _toastBaseTable[#_toastBaseTable + 1] = {num = tonumber(_propertySubTable[tostring(i)]),label = _labelName,propertyKey = i}
        end
    end
    return _toastBaseTable
end

function XTHD.resource.getRankColor_number(rankId,heroid)
    local rankColor = cc.c3b(240,240,240)
    local addNumber = 0
    local colorStr = "white"
    if not rankId then rankId = 0 end
    rankId  = tonumber(rankId) > 0 and tonumber(rankId) or 0
    -- local _levelTable = {"16","11","7","4","2","1"}
    -- local _colorTable = {
    --     ["16"] = cc.c3b(235,0,0)
    --     ,["11"] = cc.c3b(255,180,0)
    --     ,["7"] = cc.c3b(210,0,255)
    --     ,["4"] = cc.c3b(0,186,255)
    --     ,["2"] = cc.c3b(0,240,56)
    --     ,["1"] = cc.c3b(240,240,240)
    -- }
    -- local _colorStrTable = {"red","orange","purple","blue","green","white"}
    -- for i=1,#_levelTable do
    --     local _limit = tonumber(_levelTable[i])
    --     if tonumber(rankId)>=_limit then
    --         addNumber = tonumber(rankId) - _limit 
    --         rankColor = _colorTable[tostring(_limit)]
    --         colorStr = _colorStrTable[tonumber(i)]
    --         break
    --     end
    -- end
    if heroid ==nil then
        heroid = 1
    end
    local _data = gameData.getDataFromCSV("GeneralInfoList")
	local _staticData = {}
	for k,v in pairs(_data) do
		_staticData[v.heroid] = v
	end
    _staticData = _staticData[tonumber(heroid)] or {}
    local _heroQuality = tonumber(_staticData.rank or 1)
    local _colorTable = {
        [1] = cc.c3b(240,240,240)
        ,[2] = cc.c3b(0,240,56)
        ,[3] = cc.c3b(0,186,255)
        ,[4] = cc.c3b(210,0,255)
        ,[5] = cc.c3b(255,180,0)
        ,[6] = cc.c3b(235,0,0)
    }
    rankColor = _colorTable[_heroQuality]
    local _colorStrTable = {"white","green","blue","purple","orange","red"}
    colorStr = _colorStrTable[_heroQuality]

    addNumber = rankId - 1

    local rankTab = {}
    rankTab["color"] = rankColor
    rankTab["colorStr"] = colorStr
    rankTab["addNumber"] = addNumber
    if addNumber > 0 then
        -- if colorStr ~= "red" then
        --     rankTab["colorStr"] = colorStr .. addNumber
        -- end
        rankTab["addNumberStr"] = " +" .. addNumber
    else
        rankTab["addNumberStr"] = ""
    end

    
    return rankTab
end

-- function XTHD.resource.getQualityHeroBgPath(quality)
--     quality = tonumber(quality)
--     if not quality or quality <= 0 or quality > 16 then
--         return "res/image/common/hero_bg1.png"
--     end
--     return "res/image/common/hero_bg"..quality..".png"
-- end

function XTHD.resource.getPosInArr(params)
    --[[
        lenth 每个之间的间距
        bgWidth 父节点宽度 决定中点在哪里
        num 总共有多少个
        nodeWidth 一个有多宽
        now 当前是第几个
    ]]--
    local lenth = params.lenth or 0
    local bgWidth = params.bgWidth or 0
    local num = params.num or 0
    local nodeWidth = params.nodeWidth or 0
    local now = params.now or 1
    return ((bgWidth-(num*nodeWidth)-(num*lenth))/2)+((now-1)*(lenth+nodeWidth))+nodeWidth/2+lenth/2
end

function XTHD.resource.getModfSecNum(num)
    local _,tmp = math.modf(num)
    return tmp
end
--获取装备进阶上限
function XTHD.resource.getItemAdvanceUpLimit(quality)
    local _quality = tonumber(quality) or 0
    local _upLimit = 0
    if _quality<3 then
        _upLimit = 0
    elseif _quality<5 then --5
        _upLimit = 5
    elseif _quality==5 then -- 10
        _upLimit = 10
    elseif _quality ==6 then
        _upLimit = 15
    end
    return _upLimit
end
function XTHD.resource.getPlusNumWithAdvance(_advance)
    if not _advance or tonumber(_advance) <= 0 then
        return nil
    end
    _advance = tonumber(_advance)
    if _advance > 2 and _advance <= 3 then
        return _advance-2
    elseif _advance > 4 and _advance <= 6 then
        return _advance-4
    elseif _advance > 7 and _advance <= 10 then
        return _advance-7
    elseif _advance > 11 and _advance <= 15 then
        return _advance-11
    elseif _advance > 16 and _advance <= 20 then
        return _advance-16
    end
    return nil
end
function XTHD.resource.getGameUIAvatorBgPath(quality)
    if not quality then quality = 1 end
    quality = tonumber(quality)

    local imgPath = "res/image/tmpbattle/avator_bg_1.png"
    if quality > 1 and quality < 4 then
        imgPath = "res/image/tmpbattle/avator_bg_2.png"
    elseif quality >= 4 and quality < 7 then
         imgPath = "res/image/tmpbattle/avator_bg_3.png"
    elseif quality >= 7 and quality < 11 then
         imgPath = "res/image/tmpbattle/avator_bg_4.png"
    elseif quality >= 11 and quality < 16 then
        imgPath = "res/image/tmpbattle/avator_bg_5.png"
    elseif quality >= 16 and quality < 20 then
        imgPath = "res/image/tmpbattle/avator_bg_6.png"
    end
    return imgPath
end

--框
function XTHD.resource.getQualityItemBgPath(quality, isHero)
    if quality == nil or type(quality) ~= "number"  or tonumber(quality) < 1  then
      quality = 1
    end
    
    if quality >= 6 then
        quality = 6
    end

    local _imagePath = "res/image/quality/item_"..tostring(quality)..".png"
    if isHero then
        _imagePath = "res/image/quality/heroBox_"..tostring(quality)..".png"
    end
    if not cc.Director:getInstance():getTextureCache():addImage(_imagePath) then
        _imagePath = "res/image/quality/item_1.png"
    end
    return _imagePath
end

function XTHD.resource.getItemImgById(resourceId,guildIcon)    
    if resourceId and tonumber(resourceId)>0 and tonumber(resourceId)<300 then
        return XTHD.resource.getHeroAvatorImgById(resourceId)
    end
    local _imagePath = "res/image/item/props"..tostring(resourceId)..".png"
    if guildIcon and guildIcon == 1 then
        _imagePath = "res/image/item/logo/props"..tostring(resourceId)..".png"
    end
    if not cc.Director:getInstance():getTextureCache():addImage(_imagePath) then
        _imagePath = "res/image/item/props10000.png"
    end
    return _imagePath
end

--英雄框
function XTHD.resource.getQualityHeroBgPath(quality)
    if not quality or  tonumber(quality) <1 then
        quality = 1
    end
    return "res/image/quality/heroBox_"..quality..".png"
    
end
--[[获取道具颜色]]
function XTHD.resource.getQualityItemColor(quality)
    local rankColor = cc.c3b(240,240,240)
    if quality == 2 then
        rankColor = cc.c3b(0,240,56)
    elseif quality == 3 then
        rankColor = cc.c3b(0,186,255)
    elseif quality == 4 then
        rankColor = cc.c3b(210,0,255)
    elseif quality == 5 then
        rankColor = cc.c3b(255,180,0)
    elseif quality == 6 then
        rankColor = cc.c3b(255,48,48)
    end
    return rankColor
end

function XTHD.resource.getIconImgById(_iconid)
    local _imagePath = "res/image/plugin/stageChapter/point_big_" .. _iconid .. ".png"
    if not cc.Director:getInstance():getTextureCache():addImage(_imagePath) then
        _imagePath = "res/image/plugin/stageChapter/point_big_1.png"
    end
    return _imagePath
end

function XTHD.resource.getHeroProNameById(pro_id)
    return LANGUAGE_KEY_ATTRIBUTESNAME(tostring(pro_id))
end

function XTHD.resource.getRankStr(rank)
    local RankStr = {
        LANGUAGE_KEY_LEVELS1,
        LANGUAGE_KEY_LEVELS2,
        LANGUAGE_KEY_LEVELS3,
        LANGUAGE_KEY_LEVELS4,
        LANGUAGE_KEY_LEVELS5,
        LANGUAGE_KEY_LEVELS6,
    }
    return RankStr[tonumber(rank)]
end
function XTHD.resource.getChineseWordWithSignalNum(_num)
    _num = tonumber(_num)
    return LANGUAGE_TABLE_WORDDATA[_num] or  ""
end

-- 获取资源图标   --如果传递type = 4 就需要传递itemData
function XTHD.resource.getResourcePath(resource_type, itemData)
    --[[
        1 经验
        2 银两
        3 元宝
        4 道具
        5 体力
        6 翡翠
        7 威望
        8 血玉
        9 荣誉
        10 神石
        11 帮派贡献
        12 奖牌

        21 绿魂石
        22 蓝魂石
        23 紫魂石
        24 赤魂石
    ]]--

    if resource_type == 4 then
        -- if itemData.dbId  then
             local itemId = itemData.itemId
        --     if itemId < 2 or tonumber(params.phaseLevel)<1 then
        --         local UserData = DBTableItem.getData(gameUser.getUserId(),{dbid = self.dbId})      
        --         self._params.itemId = UserData.itemid
        --         itemId = UserData.itemid
        --         if not UserData.itemid then
        --             UserData =  DBTableEquipment.getData(gameUser.getUserId(), {dbid = self.dbId})
        --             self._params.itemId = UserData.itemid
        --             itemId = UserData.itemid
        --         end
        --         stardata = tonumber(UserData.phaseLevel or 0)
        --     else
        --         stardata = tonumber(params.phaseLevel or 0)
        --     end
        -- elseif self.dbId and itemId < 2 then
        --     local UserData = DBTableItem.getData(gameUser.getUserId(),{dbid = self.dbId})      
        --     self._params.itemId = UserData.itemid
        --     itemId = UserData.itemid
        --     if not UserData.itemid then
        --         UserData =  DBTableEquipment.getData(gameUser.getUserId(), {dbid = self.dbId})
        --         self._params.itemId = UserData.itemid
        --         itemId = UserData.itemid
        --     end
        -- end
        local _static_data = gameData.getDataFromCSV("ArticleInfoSheet", {itemid = itemId})
        if _static_data.type ~= 2 then
            item_img = XTHD.resource.getItemImgById(_static_data.resourceid)
        else
            --该道具是英雄魂石
            item_img = XTHD.resource.getItemImgById(_static_data.resourceid)
            -- item_img:setScale(70/item_img:getBoundingBox().width,70/item_img:getBoundingBox().height)
        end

        return item_img
    end

    local Path = {
        [1] = "res/image/common/task_gold_icon_2.png",
        [2] = IMAGE_KEY_HEADER_GOLD,
        [3] = IMAGE_KEY_HEADER_INGOT,
        [5] = "res/image/common/task_gold_icon_2.png",
        [6] = IMAGE_KEY_HEADER_FEICUI,
        [7] = "res/image/common/task_gold_icon_2.png",
        [8] = IMAGE_KEY_HEADER_REDJADE,
        [9] = IMAGE_KEY_HEADER_HONOR,
        [10] = IMAGE_KEY_HEADER_SAINTSTONE,
        [11] = IMAGE_KEY_HEADER_CONTRIBUTION,
        [12] = IMAGE_KEY_HEADER_AWARD,
        [13] = IMAGE_KEY_HEADER_ENERGY,

        [21] = "res/image/common/task_gold_icon_2.png",
        [22] = "res/image/common/task_gold_icon_2.png",
        [23] = "res/image/common/task_gold_icon_2.png",
        [24] = "res/image/common/task_gold_icon_2.png",
        [200] = IMAGE_KEY_HEADER_OFFERREWARD,
    }
    return Path[tonumber(resource_type)]
end
--获取英雄类型图标
function XTHD.resource.getHeroTypeImgPath(_id)
    local _path = "res/image/plugin/hero/hero_type_1.png"
    if tonumber(_id) > 0 and tonumber(_id)<4 then
        _path = "res/image/plugin/hero/hero_type_".. _id ..".png"
    end
    return _path
end

function XTHD.resource.getItemNum(id) -- 获取有多少个道具
    local ownNum = 0
    local ownData = DBTableItem.getData( gameUser.getUserId(), {itemid = id} )
    if #ownData ~= 0 and type(ownData[1]) == "table" then
        for i=1,#ownData do
            ownNum = ownNum + ownData[i].count
        end
    else
        ownNum = ownData.count or 0
    end

    local ownData = DBTableEquipment.getData(gameUser.getUserId(), {itemid = id} )
    if #ownData ~= 0 and type(ownData[1]) == "table" then
        for i=1,#ownData do
            ownNum = ownNum + 1
        end
    end
    return ownNum
end

function XTHD.resource.getServerStatusImgPath(status)
    local path = "res/image/login/icon_server_status_ok.png"
    if status == 3 then
        path = "res/image/login/icon_server_status_normal.png"
    elseif status == 4 then
        path = "res/image/login/icon_server_status_hot.png"
    end
    return path
end
--[[
    --头像
建议使用XTHD.resource.getHeroAvatarImgPath( param )
]]
function XTHD.resource.getHeroAvatorImgById(hero_id)
    local imgpath = "res/image/avatar/avatar_"..hero_id..".png" 
    if not cc.Director:getInstance():getTextureCache():addImage(imgpath) then
        imgpath = "res/image/avatar/avatar" .. hero_id .. ".png"
        if not cc.Director:getInstance():getTextureCache():addImage(imgpath) then
            imgpath = "res/image/avatar/avatar_1.png"
        end
    end

    return imgpath
end
--[[
  头像
   城主头像专用
]]
function XTHD.resource.getHeroAvatorImgById1(hero_id)
    local imgpath = "res/image/avatar/castellan/chengzhu_"..hero_id..".png" 
    if not cc.Director:getInstance():getTextureCache():addImage(imgpath) then
        imgpath = "res/image/avatar/avatar" .. hero_id .. ".png"
        if not cc.Director:getInstance():getTextureCache():addImage(imgpath) then
            imgpath = "res/image/avatar/castellan/chengzhu_1.png"
        end
    end

    return imgpath
end

--[[
@_type  1代表正方形，2代表圆形...
@id     图片id
]]
function XTHD.resource.getHeroAvatarImgPath( param )
    local _type = param._type
    local id = param.heroid
    local file = "res/image/avatar/avatar_"..id..".png"
    if _type == 2 then
        file = "res/image/avatar/avatar_circle_"..id..".png"
    end
    if not cc.Director:getInstance():getTextureCache():addImage(file) then
        file = XTHD.resource.getHeroAvatarImgPath({_type = _type, heroid = 1})
    end
    return file
end

function XTHD.resource.getBossNameImg( param )
    local _type = param._type
    local id = param.heroid
    local file = "res/fonts/bossName/boss_name_"..id..".png"
    if not cc.Director:getInstance():getTextureCache():addImage(file) then
        file = XTHD.resource.getBossNameImg({_type = _type, heroid = 801})
    end
    return file
end

--[[
    获取段位图片
]]
function XTHD.resource.getRankIcon( rankIndex )
    if rankIndex == nil or rankIndex > 7 or rankIndex < 0 then
        rankIndex = 0;
    end
    return "res/image/common/rank_icon/rankIcon_" .. rankIndex .. ".png";
end

zctech = zctech or {}

function zctech.print_table(t, name, indent)
    -- do
    --     return "";
    -- end
    local tableList = {}
    function table_r (t, name, indent, full)
        local id = not full and name or type(name)~="number" and tostring(name) or '['..name..']'
        local tag = indent .. id .. ' = '
        local out = {}  -- result
        if type(t) == "table" then
            if tableList[t] ~= nil then
                table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
            else
                tableList[t]= full and (full .. '.' .. id) or id
                if next(t) then -- Table not empty
                    table.insert(out, tag .. '{')
                    for key,value in pairs(t) do
                        table.insert(out,table_r(value,key,indent .. '   ', tableList[t]))
                    end
                    table.insert(out,indent .. '}')
                else
                    table.insert(out,tag .. '{}')
                end
            end
        else
            local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
            table.insert(out, tag .. val)
        end
        return table.concat(out, '\n')
    end
    return table_r(t,name or 'Value',indent or '')
end

function XTHD.resource.isHaveEquipmentInFirstPos()
    local _euqipmentTable = {}
    local _table = DBTableEquipment.getData(gameUser.getUserId())
    
    if _table and next(_table)~=nil then
        if #_table<1 then
            _euqipmentTable[1] = _table
            if tonumber(_euqipmentTable[1].bagindex)==1 and tonumber(_euqipmentTable[1].heroid)==1 then
                return true
            end
        else
            _euqipmentTable = _table
            for i=1,#_euqipmentTable do
                if tonumber(_euqipmentTable[i].heroid)==1 and tonumber(_euqipmentTable[i].bagindex)==1 then
                    return true
                end
            end
        end
        
    end
    return false
end

--激活经脉时，韬略不足，使用元宝代替
--传入缺少的韬略数量，返回需要的元宝数量
function XTHD.resource.getIngotNumToReplaceZhenqi(_lostZhenqi)
    local _needIngot = 0
    local _zhengqi = tonumber(_lostZhenqi or 0)
    _needIngot = math.ceil(_zhengqi/500)
    return _needIngot
end