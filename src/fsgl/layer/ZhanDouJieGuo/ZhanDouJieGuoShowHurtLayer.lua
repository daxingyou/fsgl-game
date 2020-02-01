--多人副本数据

local ZhanDouJieGuoShowHurtLayer=class("ZhanDouJieGuoShowHurtLayer",function (  )
    return XTHDPopLayer:create()
end)
function ZhanDouJieGuoShowHurtLayer:ctor (data,type)
    self:initUI(data,type)
    self:show()
    musicManager.stopBackgroundMusic()
end
function ZhanDouJieGuoShowHurtLayer:initUI(data,type)
    local _hurt_data = data 
    
    local Pop_bg = XTHDImage:create("res/image/tmpbattle/battle_data_bg.png")
    Pop_bg:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
    self:getContainerLayer():addChild(Pop_bg)
    -- data_bg.popNode = Pop_bg   
       
    local function setTxt(label_node,add_value, max_value,delay_time)
        if label_node then
            label_node:runAction(cc.Sequence:create(cc.DelayTime:create(1/60),cc.CallFunc:create(function()
                local _target_value = tonumber(label_node:getString()) + tonumber(add_value)
                if _target_value >= tonumber(label_node:getTag()) then
                    _target_value = tonumber(label_node:getTag())
                end
                label_node:setString(_target_value)
                if tonumber(label_node:getString()) < tonumber(max_value) then
                    setTxt(label_node,add_value,max_value)
                end
            end)))
        end
    end

    function showAnimationWhenCellScro(_timer_list,label_list,_max_value_left,_max_value_right)
        for i=1,#_timer_list do
            local _cur_list = _timer_list[i]
            local _cur_label_list = label_list[i]
            if _cur_list then
                for j=1,#_cur_list do
                    local _max_value= 1
                    if i == 1 then
                        _max_value = _max_value_left
                    elseif i == 2 then
                        _max_value = _max_value_right
                    end
                   
                    if _max_value==0 then
                       _target_per=0
                    else
                       _target_per = tonumber(_cur_list[j]:getTag())/_max_value*100
                    end
                    -- local _target_per = tonumber(_cur_list[j]:getTag())/_max_value*100
                    _cur_list[j]:runAction(cc.ProgressFromTo:create(_target_per/60,0,_target_per))
                    local hurt_label = _cur_label_list[j]
                    if hurt_label  and _target_per > 0 then
                        local addvalue=math.floor(tonumber(_cur_list[j]:getTag())/60)
                        if addvalue<1 then
                            addvalue=1
                        end
                        setTxt(hurt_label,addvalue,tonumber(_cur_list[j]:getTag()))
                    end
                end
            end
        end
    end

    local hurt_datatView  = CCTableView:create(cc.size(Pop_bg:getContentSize().width, Pop_bg:getContentSize().height));
    hurt_datatView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);
    hurt_datatView:setPosition(0,0)
    hurt_datatView:setVerticalFillOrder(cc.TABLEVIEW_FILL_BOTTOMUP);
    hurt_datatView:setBounceable(false);
    hurt_datatView:setDelegate()
    Pop_bg:addChild(hurt_datatView)

        -- -- 注册事件
    local function numberOfCellsInTableView( table )
        if tonumber(type) == BattleType.PVP_CHALLENGE or tonumber(type) == BattleType.PVP_LADDER then
            return #data["bfurts"]
        else
            return 1
        end
    end
    local function cellSizeForTable( table, idx )
        return hurt_datatView:getViewSize().width,hurt_datatView:getViewSize().height
    end
    local function tableCellAtIndex( table, idx )
        local cell = table:dequeueCell();
        if cell then
            cell:removeAllChildren()
        else
            cell =  cc.TableViewCell:new();
        end
        local _timer_list = {
            [1]={},
            [2]={}
        }
        local label_list = {
            [1]={},
            [2]={}
        }
        local _total_hurt_left = 0
        local _total_hurt_right = 0
        local _max_value_left = 0
        local _max_value_right = 0
        if tonumber(type) == BattleType.PVP_CHALLENGE or tonumber(type) == BattleType.PVP_LADDER then
            -- _hurt_data = {
            --     ["afurts"] = data["afurts"][idx+1]["hurts"],
            --     ["bfurts"] = data["bfurts"][idx+1]["hurts"]
            -- }
            _hurt_data = data 
        else
            _hurt_data = data 
        end 
         local left_total_hurt = XTHDLabel:createWithParams({
                text="",
                size = 18,
                color=cc.c3b(0,0,0),
                anchor = cc.p(0.5,1)
            })
         cell:addChild(left_total_hurt)

        local right_total_hurt = XTHDLabel:createWithParams({
                text="",
                size = 18,
                color=left_total_hurt:getColor(),
                anchor = cc.p(0.5,1)
            })
            cell:addChild(right_total_hurt)

        for i=1,2 do 
            local _team_txt = LANGUAGE_TIPS_WORDS92-------"我方总伤害"
            local _team_data = _hurt_data["afurts"]
            local pos  = cc.p(140,Pop_bg:getContentSize().height-20)
            local _blood_exp_bar = "res/image/tmpbattle/battle_data_pro_green.png"
            if i ==2 then
                _team_txt = LANGUAGE_TIPS_WORDS93-------"敌方总伤害"
                pos = cc.p(280,Pop_bg:getContentSize().height-20)
                _team_data = _hurt_data["bfurts"]
                 _blood_exp_bar = "res/image/tmpbattle/battle_data_pro_red.png"

            end
            local team_txt = XTHDLabel:createWithParams({
                text=_team_txt,
                size = 18,
                color=cc.c3b(0,0,255),
                pos = pos
            })
            team_txt:setDimensions(200, 60)
            team_txt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER )
            team_txt:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
            cell:addChild(team_txt)

            for j=1,#_team_data do
                local _tab = string.split(_team_data[j],',')
                if i == 1 then
                    left_total_hurt:setPosition(team_txt:getPositionX(),Pop_bg:getContentSize().height-35)
                    _total_hurt_left = _total_hurt_left + tonumber(_tab[2])
                    if tonumber(_tab[2]) > _max_value_left then
                        _max_value_left = tonumber(_tab[2])
                    end
                elseif i == 2 then
                    right_total_hurt:setPosition(team_txt:getPositionX(),left_total_hurt:getPositionY())
                    _total_hurt_right = _total_hurt_right + tonumber(_tab[2])
                    if tonumber(_tab[2]) > _max_value_right then
                        _max_value_right = tonumber(_tab[2])
                    end
                end
               
                local db_data = nil --英雄或者怪物的数据
                if i==1 then
                    local _tmpData = DBTableHero.getData(gameUser.getUserId(), {heroid =tonumber(_tab[1])}) or {}
                    db_data = clone(_tmpData)
                    db_data["heroid"] = _tab[1]
                    db_data["advance"] = _tmpData["advance"]
                    if _tab[4] ~= nil then
                        db_data["level"] = tonumber(_tab[4]) or 0
                    end
                    if _tab[3] ~= nil then
                        db_data["star"] = tonumber(_tab[3]) or 0
                    end
                elseif i == 2 then
                    local _tmpData = {}
                    if  tonumber(type) == BattleType.CAMP_PVP or   tonumber(type) == BattleType.PVP_CHALLENGE or tonumber(type) == BattleType.PVP_LADDER then
                        -- local _key = tostring(_tab[1])
                        -- _tmpData = self._enemy_team_data[_key]
                        -- db_data = clone(_tmpData);
                        -- db_data["heroid"] = _tab[1]
                        db_data = clone(_tmpData);
                        local advance=0
                        if tonumber(_tab[3])>= 16 then
                            advance=16
                        else
                            advance=tonumber(_tab[3])
                        end
                        db_data["advance"] = advance--_tmpData["rank"]
                        db_data["heroid"] = tonumber(_tab[1])--_tmpData["heroid"]
                        db_data["level"]=tonumber(_tab[4]) or 0
                        db_data["star"]=0
                    else
                        db_data = clone(_tmpData)
                        local advance=0
                        if tonumber(_tab[3])>= 16 then
                            advance=16
                        else
                            advance=tonumber(_tab[3])
                        end
                        db_data["advance"] =advance--_tmpData["rank"]
                        db_data["heroid"] = tonumber(_tab[1])--_tmpData["heroid"]
                        db_data["level"]=tonumber(_tab[4]) or 0
                        db_data["star"]=0
                    end
                    
                    
                end
                local hero_item = YingXiongItem:createWithParams(db_data)
                hero_item:setScale(60/hero_item:getContentSize().width)
                cell:addChild(hero_item)

                --输入数据条
                local exp_progress_bg = cc.Sprite:create("res/image/tmpbattle/battle_data_pro_bg.png")
                exp_progress_bg:setScaleY(0.6)
                exp_progress_bg:setScaleX(0.6)
                cell:addChild(exp_progress_bg)

                local exp_progress_timer = cc.ProgressTimer:create(cc.Sprite:create(_blood_exp_bar)) 
                exp_progress_timer:setName("exp_progress_timer")
                exp_progress_timer:setType(cc.PROGRESS_TIMER_TYPE_BAR);
                exp_progress_timer:setMidpoint(cc.p(0,0.5));
                exp_progress_timer:setBarChangeRate(cc.p(1, 0))
                exp_progress_timer:setPosition(exp_progress_bg:getContentSize().width/2,exp_progress_bg:getContentSize().height/2)
                exp_progress_timer:setPercentage(80)
                exp_progress_bg:addChild(exp_progress_timer)
                exp_progress_timer:setTag(tostring(_tab[2]))
                _timer_list[i][#_timer_list[i] +1] = exp_progress_timer

                --_tab[2])
                local hurt_label = XTHDLabel:createWithParams({
                    text=0,
                    size = 24,
                    color=cc.c3b(0,0,0),
                    anchor = cc.p(0.5,0),
                    pos = cc.p(exp_progress_bg:getContentSize().width/2,30)
                })
                hurt_label:setTag(tostring(_tab[2]))
                exp_progress_bg:addChild(hurt_label)
                label_list[i][#label_list[i] + 1] =hurt_label
                 if i == 1 then
                    hero_item:setPosition(hero_item:getContentSize().width/2*hero_item:getScale()+20,Pop_bg:getContentSize().height-100 - (j-1)*(hero_item:getContentSize().height*hero_item:getScale()+7))
                    
                    exp_progress_bg:setPosition(hero_item:getPositionX()+10+ hero_item:getContentSize().width/2*hero_item:getScale() + exp_progress_bg:getContentSize().width/2-40, hero_item:getPositionY() -10)
                elseif i == 2 then
                    hero_item:setPosition(Pop_bg:getContentSize().width- hero_item:getContentSize().width/2*hero_item:getScale()-20,Pop_bg:getContentSize().height-100 - (j-1)*(hero_item:getContentSize().height*hero_item:getScale()+7))
                   
                    exp_progress_bg:setPosition(hero_item:getPositionX()-10- hero_item:getContentSize().width/2*hero_item:getScale() - exp_progress_bg:getContentSize().width/2+30,  hero_item:getPositionY() -10)
                    
                    -- exp_progress_bg:setScaleX(-1)
                    -- hurt_label:setScaleX(-1)
                end
            end
        end

        left_total_hurt:setString(_total_hurt_left)
        right_total_hurt:setString(_total_hurt_right)
        showAnimationWhenCellScro(_timer_list,label_list,_max_value_left,_max_value_right)

        return cell
    end
    hurt_datatView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    hurt_datatView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    hurt_datatView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    hurt_datatView:reloadData()
    hurt_datatView:updateCellAtIndex(0)
end
function ZhanDouJieGuoShowHurtLayer:create(data,type)
    return ZhanDouJieGuoShowHurtLayer.new(data,type)
end
return ZhanDouJieGuoShowHurtLayer
