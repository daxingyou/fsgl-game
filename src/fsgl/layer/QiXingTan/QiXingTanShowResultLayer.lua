

local QiXingTanShowResultLayer = class("QiXingTanShowResultLayer",function ()
    return XTHDDialog:create()
end)

function QiXingTanShowResultLayer:ctor(param,_type)
    self:init(param,_type)
end

function QiXingTanShowResultLayer:init( param,_type )
    self._param = {} 
    self._effect_tab = {}  --存放特效，为了提高播放动画的效率，提前加载动画
    self._item_name = {}   --通过查表获取装备名字

    self._juan_zhou_bg = nil
    self._img_bg = nil
    self._gold_num = nil

   
    local size = cc.Director:getInstance():getWinSize()
    local bg = XTHD.createSprite()
    bg:setContentSize(XTHD.resource.visibleSize)
    bg:setPosition(size.width/2, size.height/2)
    self:addChild(bg)

    local img_bg = cc.Sprite:create("res/image/exchange/reward/reward_background.jpg") 
    img_bg:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2)
	img_bg:setContentSize(self:getContentSize())
    bg:addChild(img_bg)
    self._img_bg = img_bg


    self:dealWithData_equip_one(param)
    self:initOne()

    --刷新英雄兑换数据
    XTHD.dispatchEvent({name = "UPDATE_PIECE_NUM",data = param })

    --刷新英雄兑换子界面数据
    XTHD.dispatchEvent({name = "REFRESH_HERO_SUB_DATA",data = param })

    --刷新装备兑换子界面数据
    XTHD.dispatchEvent({name = "UPDATE_EQUIP_PIECE_NUM" })

    --刷新装备兑换界面数据
    XTHD.dispatchEvent({name = "UPDATE_PIECE_DATA" })

end


function QiXingTanShowResultLayer:doActionForOne(  )
    local item = ItemNode:createWithParams({
        _type_ = 4,
        itemId = self._param[1]["itemId"],
        count = self._param[1]["count"] ,
        needSwallow = true
        })
    item:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2+12)
    self._img_bg:addChild(item)
    -- item:setClickable(false)

     --闪烁动画
    local flash_effect =  sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/tubiao.json", "res/spine/effect/exchange_effect/tubiao.atlas",1 )
    flash_effect:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2+12)
    self._img_bg:addChild(flash_effect)
    flash_effect:setAnimation(0,"animation",false)

    local tmp_tab = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = self._param[1]["itemId"]}) or nil
    local tmp_name = ""
    local tmp_quality = 1
    if tmp_tab ~= nil then
        tmp_name = tmp_tab["name"] or ""
        tmp_quality = tmp_tab["rank"] or 1
    end

    local item_name = XTHDLabel:createWithParams({
                text = tmp_name,
                fontSize = 18,
                -- color = XTHD.resource.getQualityItemColor( tmp_quality )
                color = cc.c3b(0,0,0)
                })
    item_name:setPosition(self._img_bg:getContentSize().width/2,self._img_bg:getContentSize().height/2-48)
    self._img_bg:addChild(item_name)

    --拼接显示内容
    local ret_txt1 = LANGUAGE_VERBS.get---------"获得 "       --获得物品名xx个 英文版需要修改
    local ret_txt2 = tmp_name
    local ret_txt3 = " "..self._param[1].count..LANGUAGE_UNKNOWN.a.."!"--------个!"


    local reward_txt = ccui.RichText:create()
    reward_txt:setPosition(item:getPositionX(),item:getPositionY()-120)
    self._img_bg:addChild(reward_txt)

    local ret1 = ccui.RichElementText:create(1,cc.c3b(255,255,255), 255,ret_txt1,"Helvetica",18)
    local ret2 = ccui.RichElementText:create(1,cc.c3b(0,255,0), 255,ret_txt2,"Helvetica",22)
    local ret3 = ccui.RichElementText:create(1,cc.c3b(255,255,255), 255,ret_txt3,"Helvetica",18)

    reward_txt:pushBackElement(ret1)
    reward_txt:pushBackElement(ret2)
    reward_txt:pushBackElement(ret3)

    item:setScale(0.1)

    item:runAction(cc.Sequence:create( cc.ScaleTo:create(0.1,1),cc.CallFunc:create(function (  )
        
        end) ))

end

--初始化一个奖励装备界面
function QiXingTanShowResultLayer:initOne( param )

    self._img_bg:removeAllChildren()
    local img_bg = self._img_bg
    self:addMengBan(img_bg)

    local light_circle = cc.Sprite:create("res/image/exchange/reward/reward_light_circle.png")
    light_circle:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2)
    img_bg:addChild(light_circle)
    light_circle:setScale(0.8)
    --光圈动画
    light_circle:runAction(cc.Sequence:create( cc.DelayTime:create(0.1333),cc.CallFunc:create(function (  )
        musicManager.playEffect("res/sound/sound_effect_drawcard.mp3")
        self:doActionForOne()
    end),cc.CallFunc:create(function (  )
        -- light_circle:setScale(1)
        light_circle:setVisible(false)
    end),cc.DelayTime:create(0.067), cc.CallFunc:create(function (  )
        light_circle:setVisible(true)
    end),cc.CallFunc:create(function (  )
        --调用特效
        -- self:doActionForOne()
    end),cc.CallFunc:create(function (  )
        
    end)))
    -- light_circle:runAction( cc.Sequence:create( cc.DelayTime:create(0.23),cc.RepeatForever:create( cc.RotateBy:create(1,15) ) ) )
    light_circle:runAction(cc.RepeatForever:create( cc.RotateBy:create(1,15) ))

     --台子
     local taizi = cc.Sprite:create("res/image/exchange/taizi.png")
     taizi:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2-20)
     img_bg:addChild(taizi)

     -- 框的动画
    local frame_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/kuang.json", "res/spine/effect/exchange_effect/kuang.atlas",1 );
    frame_effect:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2)
    img_bg:addChild(frame_effect)
    frame_effect:setOpacity(0)
    frame_effect:setAnimation(0,"animation3",false)

    --恭喜获得静图
    local gxhd = cc.Sprite:create("res/image/exchange/gxhd.png")
    gxhd:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2+178)
    img_bg:addChild(gxhd)

     --标题动画
    local title_effect = sp.SkeletonAnimation:create("res/spine/effect/exchange_effect/gxhd.json", "res/spine/effect/exchange_effect/gxhd.atlas",1 );
    title_effect:setPosition(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2-145)
    img_bg:addChild(title_effect)
    title_effect:setOpacity(0)
    title_effect:setAnimation(0,"animation",false)

    --确定按钮
    local be_ok = XTHD.createCommonButton({
        text = LANGUAGE_BTN_KEY.sure,
        isScrollView = false,
        fontSize = 22,
        btnSize = cc.size(130,51),
        pos = cc.p(img_bg:getContentSize().width/2,130),
        endCallback = function()    
            self:removeFromParent()
        end
    })
    img_bg:addChild(be_ok)
   
end


--根据self._show_type获取item的名字
function QiXingTanShowResultLayer:getTempName( sub_data,_type )
    --_type = 1  首先要显示英雄的名字
    local tmp_txt = ""
    if _type == 1 then
        tmp_txt = gameData.getDataFromCSV("GeneralInfoList",{heroid = sub_data.id}).name
    elseif _type == 2 then
        tmp_txt = gameData.getDataFromCSV("GeneralInfoList",{heroid = sub_data.petId}).name
    elseif _type == 3 then
        tmp_txt = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = sub_data.itemId}).name
    end
    return tmp_txt
end


function QiXingTanShowResultLayer:dealWithData_equip_one( param )

    if param["items"] and #param["items"] ~= 0  then

        self._param[#self._param+1] = param["items"][#param["items"]]
        self._show_type = 3
    end

    self:saveDataToDB(param)
end

--把数据写入到数据库中
function QiXingTanShowResultLayer:saveDataToDB( param )
    if param["items"] and #param["items"] ~= 0  then
        --最后一条数据是拼接上去的，所以保存到数据库的时候，不需要保存拼接的数据
        for i=1,#param["items"]-1 do
            if param["items"][i].count and tonumber(param["items"][i].count) ~= 0 then
                DBTableItem.updateCount(gameUser.getUserId(),param["items"][i],param["items"][i].dbId)
            else
                DBTableItem.deleteData(gameUser.getUserId(),param["items"][i].dbId)
            end
        end
    end

end


--添加蒙版效果
function QiXingTanShowResultLayer:addMengBan( img_bg )
    local mengban_bg = cc.LayerColor:create()
    mengban_bg:setColor(cc.c3b(0,0,0))
    mengban_bg:setOpacity(127.5)
    mengban_bg:setContentSize(img_bg:getContentSize())
    mengban_bg:setPosition(0,0)
    img_bg:addChild(mengban_bg)
end

function QiXingTanShowResultLayer:create(param,_type)
    local layer = self.new(param,_type)
    return layer
end

function QiXingTanShowResultLayer:onCleanup( ... )

     --清理比较大的纹理
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/exchange/reward/reward_background.jpg") 

end

return QiXingTanShowResultLayer