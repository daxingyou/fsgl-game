--副本信息处理 createBy.huangjunjian  2015.08.11
CopiesData={}
function CopiesData.UpdateInstancingData(jsonData)
    local userId = gameUser.getUserId()
    local _target_instancing= {}
    local _target_elite_instancing = {}
    local rewardData={}
    local elite_rewardData={}
    local _target_diffculty_instancing ={} --恶魔副本关卡信息
    local diffculty_rewardData = {} --恶魔副本星级奖励
      --插入普通副本的星级信息
    local function _updateData(json)
        if json then
            for k,v in pairs(json) do
                local _instancing = {};
                _instancing["star"] = v;
                _instancing["id"] = tonumber(k);
                _target_instancing[tonumber(k)]=_instancing--#_target_instancing+1
            end
        end
    end

    --插入精英副本的数据
    local  function _upEliteData(json_data)
         if json_data then
             table.sort( json_data, function (a,b)
                return a.ectypeId < b.ectypeId
            end )
             for k,v in pairs(json_data) do
                local _tmp = {}
                _tmp["id"] =json_data[k]["ectypeId"]
                _tmp["star"] =json_data[k]["star"]
                _tmp["surplusCount"] =json_data[k]["surplusCount"]
                _tmp["resetCount"] =json_data[k]["resetCount"]
                _target_elite_instancing[k]=_tmp
            end
        end
    end
    --插入恶魔副本的数据
    local  function _upDiffcultyData(json_data)
         if json_data and next(json_data) then
            table.sort( json_data, function (a,b)
                return a.ectypeId < b.ectypeId
            end )
            for k,v in pairs(json_data) do
                local _tmp = {}
                _tmp["id"] =json_data[k]["ectypeId"]
                _tmp["star"] =json_data[k]["star"]
                _tmp["surplusCount"] =json_data[k]["surplusCount"]
                _tmp["resetCount"] =json_data[k]["resetCount"]
                _target_diffculty_instancing[k]=_tmp
            end
        end
    end
    local function _upRewardData(rewardCount)
        if rewardCount then
            for k,v in pairs(rewardCount) do
                local tab={}
                tab["chapterid"]=k
                tab["normal_times"]= v
                rewardData[tonumber(k)]=tab
            end
        end
    end
    local function _upEliteRewardData(eliteRewardCount)
        if eliteRewardCount then
            for k,v in pairs(eliteRewardCount) do
                local tab={}
                tab["chapterid"]=k
                tab["elite_times"]= v
                elite_rewardData[tonumber(k)]=tab
            end
        end
    end
    local function _upDiffcultyRewardData(diffRewardCount)
        if diffRewardCount then
            for k,v in pairs(diffRewardCount) do
                local tab={}
                tab["chapterid"]=k
                tab["elite_times"]= v
                diffculty_rewardData[tonumber(k)]=tab
            end
        end
    end
    
    if jsonData["ectypeRecord"] then
        _updateData(jsonData["ectypeRecord"])  --插入普通副本的星级信息
        _upRewardData(jsonData["rewardCount"])
        gameUser.setNormalCopiesData(_target_instancing)
        gameUser.setCopiesReward(rewardData)
    end
    if jsonData["eliteEctypeRecord"] then
        _upEliteData(jsonData["eliteEctypeRecord"]) --插入精英副本的数据
        _upEliteRewardData(jsonData["eliteRewardCount"])
        gameUser.setEliteCopiesData(_target_elite_instancing)
        gameUser.setEliteCopiesReward(elite_rewardData)
    end
    if jsonData["diffcultyEctypeRecord"] then
        _upDiffcultyData(jsonData["diffcultyEctypeRecord"]) --插入噩梦副本的数据
        _upDiffcultyRewardData(jsonData["ectypeRewardCount"])
        gameUser.setDiffcultyCopiesData(_target_diffculty_instancing)
        gameUser.setDiffcultyCopiesReward(diffculty_rewardData)
    end
end
--[[
普通副本
]]
--修改宝箱状态
function CopiesData.changeCopiesReward(id,star,_type)
    local _star_data={}
    local tab={}
    if _type and _type==ChapterType.Normal then
        _star_data=gameUser.getCopiesReward()
        _star_data[tonumber(id)]["normal_times"]=star--table.concat(tab, "#")
    elseif  _type and _type==ChapterType.ELite  then
         _star_data=gameUser.getEliteCopiesReward()
         _star_data[tonumber(id)]["elite_times"]=star --table.concat(tab, "#")
    elseif _type == ChapterType.Diffculty then
        _star_data=gameUser.getDiffcultyCopiesReward()
        _star_data[tonumber(id)]["elite_times"]=star --table.concat(tab, "#")
    end  
end
    

--获取星级
function CopiesData.GetNormalStar(id)
    local _star_data=gameUser.GetNormalCopiesData ()
    local _star_=nil  
    if _star_data[tonumber(id)] and _star_data[tonumber(id)]["star"]  then
        _star_=_star_data[tonumber(id)]["star"]
    end
    return _star_
end
--更改星级 
function CopiesData.ChangeNormalData(id,star )
    local normal_data=gameUser.GetNormalCopiesData()
    if normal_data[tonumber(id)] then
        normal_data[tonumber(id)]["star"]=star
    else
        local  data={}
            data["star"] = star
            data["id"] = id
        table.insert(normal_data,tonumber(id),data)
    end
    gameUser.setNormalCopiesData ( normal_data )
end
--增加数据
function CopiesData.insertData(id,data)
    local normal_data=gameUser.GetNormalCopiesData()
    table.insert(normal_data,tonumber(id),data)
    gameUser.setNormalCopiesData ( normal_data )
end
--获取宝箱数据
--更改宝箱数据

--[[
精英副本
]]

--获取星级
function CopiesData.GetEliteStar(id)
    local _star_data=gameUser.GetEliteCopiesData (  ) 
    local _star_=nil 
    if _star_data[tonumber(id)] and _star_data[tonumber(id)]["star"]  then
       _star_=_star_data[tonumber(id)]["star"]
    end
    return _star_
end
--改变星级
function CopiesData.ChangeEliteData(id,star )
    local elite_data=gameUser.GetEliteCopiesData()
    
    if elite_data[tonumber(id)] and elite_data[tonumber(id)]["star"]  then
       elite_data[tonumber(id)]["star"]=star
    end
    gameUser.setEliteCopiesData ( elite_data )
end
--得到进攻次数
function CopiesData.GetEliteTimes(id )
    local num=3
    local elite_data=gameUser.GetEliteCopiesData()
    if elite_data[tonumber(id)] and elite_data[tonumber(id)]["surplusCount"] then
       num=elite_data[tonumber(id)]["surplusCount"]
    end
    return num 
end
--改变进攻次数
function CopiesData.ChangeEliteTimes(id,surplusCount)
    local elite_data=gameUser.GetEliteCopiesData()
    if elite_data[tonumber(id)] and elite_data[tonumber(id)]["surplusCount"]  then
       elite_data[tonumber(id)]["surplusCount"]=surplusCount
    end   
    gameUser.setEliteCopiesData ( elite_data )
end
--得到刷新次数
function CopiesData.GetEliteRefreshTimes(id )
    local num=0
    local elite_data=gameUser.GetEliteCopiesData()
    if elite_data[tonumber(id)] and elite_data[tonumber(id)]["resetCount"] then
        num=elite_data[tonumber(id)]["resetCount"]
    end
    return num 
end

--更改刷新次数
function CopiesData.ChangeEliteRefreshTimes(id,resetCount)
    local elite_data=gameUser.GetEliteCopiesData()
    if elite_data[tonumber(id)] and elite_data[tonumber(id)]["resetCount"]  then
        elite_data[tonumber(id)]["resetCount"]=resetCount
    end   
    gameUser.setEliteCopiesData ( elite_data )
end
--增加数据
function CopiesData.insertEliteData(id,data)
    local elite_data=gameUser.GetEliteCopiesData()
    table.insert(elite_data,tonumber(id),data)
    gameUser.setEliteCopiesData ( elite_data )
end

--[[
    恶魔副本相关
]] 
--获取星级
function CopiesData.GetDiffcultyStar(id)
    local _star_data=gameUser.getDiffcultyCopiesData (  ) 
    local _star_=nil 
    if _star_data[tonumber(id)] and _star_data[tonumber(id)]["star"]  then
       _star_=_star_data[tonumber(id)]["star"]
    end
    return _star_
end
--改变星级
function CopiesData.ChangeDiffcultyData(id,star )
    local diffculty_data=gameUser.getDiffcultyCopiesData()
    
    if diffculty_data[tonumber(id)] and diffculty_data[tonumber(id)]["star"]  then
       diffculty_data[tonumber(id)]["star"]=star
    end
    gameUser.setDiffcultyCopiesData ( diffculty_data )
end
--得到进攻次数
function CopiesData.GetDiffcultyTimes(id )
    local num=3
    local diffculty_data=gameUser.getDiffcultyCopiesData()
    if diffculty_data[tonumber(id)] and diffculty_data[tonumber(id)]["surplusCount"] then
       num=diffculty_data[tonumber(id)]["surplusCount"]
    end
    return num 
end
--改变进攻次数
function CopiesData.ChangeDiffcultyTimes(id,surplusCount)
    local diffculty_data=gameUser.getDiffcultyCopiesData()
    if diffculty_data[tonumber(id)] and diffculty_data[tonumber(id)]["surplusCount"]  then
       diffculty_data[tonumber(id)]["surplusCount"]=surplusCount
    end   
    gameUser.setDiffcultyCopiesData ( diffculty_data )
end
--得到刷新次数
function CopiesData.GetDiffcultyRefreshTimes(id )
    local num=0
    local diffculty_data=gameUser.getDiffcultyCopiesData()
    if diffculty_data[tonumber(id)] and diffculty_data[tonumber(id)]["resetCount"] then
        num=diffculty_data[tonumber(id)]["resetCount"]
    end
    return num 
end

--更改刷新次数
function CopiesData.ChangeDiffcultyRefreshTimes(id,resetCount)
    local diffculty_data=gameUser.getDiffcultyCopiesData()
    if diffculty_data[tonumber(id)] and diffculty_data[tonumber(id)]["resetCount"]  then
        diffculty_data[tonumber(id)]["resetCount"]=resetCount
    end   
    gameUser.setDiffcultyCopiesData ( diffculty_data )
end
--增加数据
function CopiesData.insertDiffcultyData(id,data)
    local diffculty_data=gameUser.getDiffcultyCopiesData()
    table.insert(diffculty_data,tonumber(id),data)
    gameUser.setDiffcultyCopiesData ( diffculty_data )
end

-------------------------------------------------副本胜利页面处理------------------------
function CopiesData.refreshDataBase( data )  ----只有胜利才能进来 
    local _instancingid = data["instancingid"]
    local _star = data["star"];
    gameUser.setNowinstancingid(_instancingid)
    --根据副本是精英副本还是普通副本，来判断需要更新的是哪个数据表
    if data.type == ChapterType.Normal then
        -- gameUser.setPassNormalChapterStatus(false)
        local _bOldStar = CopiesData.GetNormalStar(_instancingid) or nil 
        if _bOldStar then ----旧关卡
            local pStar = tonumber(_star) or 0
            local pbOldStar = tonumber(_bOldStar) or 0
            if pStar > pbOldStar then --只有本次星级大于之前获得星级时，才会更新数据
                CopiesData.ChangeNormalData(_instancingid,_star )
                -- cc.UserDefault:getInstance():setBoolForKey(KEY_NAME_STAR_EFFECT,true)
            end
        else -----新关卡
            local _tmpData = {};
            _tmpData["id"] = tonumber(_instancingid)
            _tmpData["star"] = _star
            CopiesData.insertData(_instancingid,_tmpData)
            gameUser.setInstancingId(tonumber(_instancingid))
            FunctionYinDao.warIsWin = true
            cc.UserDefault:getInstance():setBoolForKey(KEY_NAME_STAR_EFFECT,true)
            -- if tonumber(_instancingid) >= gameUser.getInstancingId() and tonumber(gameUser.getInstancingId()) > 1 then
            --     local now_chapter = gameData.getDataFromCSV("ExploreInfoList", {["instancingid"] = tonumber(_instancingid)+1} )["chapterid"] or 0
            --     local last_instanc_chapterid = gameData.getDataFromCSV("ExploreInfoList", {["instancingid"] = gameUser.getInstancingId()} )["chapterid"] or 0
            --     if tonumber(now_chapter) > tonumber(last_instanc_chapterid) then
            --         -- gameUser.setPassNormalChapterStatus(now_chapter)
            --     end
            -- end
        end
    elseif data.type == ChapterType.ELite then
        -- gameUser.setPassEliteChapterStatus(false)     
        local _bOldStar=CopiesData.GetEliteStar(_instancingid) or nil
        if _bOldStar  then
            local pStar = tonumber(_star) or 0
            local pbOldStar = tonumber(_bOldStar) or 0
            if pStar > pbOldStar then
                CopiesData.ChangeEliteData(_instancingid,_star )
                -- cc.UserDefault:getInstance():setBoolForKey(KEY_NAME_STAR_EFFECT,true)
            end
            CopiesData.ChangeEliteTimes(_instancingid,data["surplusCount"])
        elseif _bOldStar==nil then
            local _tmpData = {};
            _tmpData["id"] = tonumber(_instancingid);
            _tmpData["star"] = _star;
            _tmpData["surplusCount"] =data["surplusCount"]
            _tmpData["resetCount"] =0
            CopiesData.insertEliteData(_instancingid,_tmpData)
            gameUser.setEliteInstancingId(_instancingid)
            CopiesData.ChangeEliteTimes(_instancingid,data["surplusCount"])  
            cc.UserDefault:getInstance():setBoolForKey(KEY_NAME_STAR_EFFECT,true)      
            -- if tonumber(_instancingid) >= gameUser.getEliteInstancingId() and tonumber(gameUser.getEliteInstancingId()) > 1 then
            --     local now_chapter = gameData.getDataFromCSV("EliteCopyList", {["instancingid"] = tonumber(_instancingid)+1} )["chapterid"] or 0
            --     local last_instanc_chapterid = gameData.getDataFromCSV("EliteCopyList", {["instancingid"] = gameUser.getEliteInstancingId()} )["chapterid"] or 0
            --     if tonumber(now_chapter) > tonumber(last_instanc_chapterid) then
            --         -- gameUser.setPassEliteChapterStatus(now_chapter)
            --     end
            -- end
        end
    elseif data.type == ChapterType.Diffculty then
        local _bOldStar=CopiesData.GetDiffcultyStar(_instancingid) or nil
        if _bOldStar  then
            local pStar = tonumber(_star) or 0
            local pbOldStar = tonumber(_bOldStar) or 0
            if pStar > pbOldStar then
                CopiesData.ChangeDiffcultyData(_instancingid,_star )
            end
            CopiesData.ChangeDiffcultyTimes(_instancingid,data["surplusCount"])
        elseif _bOldStar==nil then
            local _tmpData = {};
            _tmpData["id"] = tonumber(_instancingid);
            _tmpData["star"] = _star;
            _tmpData["surplusCount"] =data["surplusCount"]
            _tmpData["resetCount"] =0
            CopiesData.insertDiffcultyData(_instancingid,_tmpData)
            gameUser.setDiffcultyInstancingId(_instancingid)
            CopiesData.ChangeDiffcultyTimes(_instancingid,data["surplusCount"])  
            cc.UserDefault:getInstance():setBoolForKey(KEY_NAME_STAR_EFFECT,true)      
        end
    end
    
end