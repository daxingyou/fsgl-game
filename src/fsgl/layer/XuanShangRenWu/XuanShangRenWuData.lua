-- FileName: XuanShangRenWuData.lua
-- Author: wangming
-- Date: 2015-10-12
-- Purpose: 悬赏任务封装数据
--[[TODO List]]

XuanShangRenWuData = {}

function XuanShangRenWuData.httpGetOfferRewardData( sParams )
	local parNode = sParams.parNode
    if not parNode then
        return
    end
    local callBack = sParams.callBack
    XTHDHttp:requestAsyncInGameWithParams({
        modules="wantedList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                -- XuanShangRenWuData.setOfferRewardList(data.list)
                -- XuanShangRenWuData.setSurplusCount(data.surplusCount)
                if callBack then
                    callBack(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
        end,--失败回调
        targetNeedsToRetain = parNode,--需要保存引用的目标
        loadingParent = parNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function XuanShangRenWuData.httpRefreshOfferRewardList( sParams )
    local parNode = sParams.parNode
    if not parNode then
        return
    end
    local callBack = sParams.callBack
    XTHDHttp:requestAsyncInGameWithParams({
        modules="refreshWantedList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                -- XuanShangRenWuData.setOfferRewardList(data.list)
                -- XuanShangRenWuData.setSurplusCount(data.surplusCount)
                if data.ingot then
                	gameUser.setIngot(data.ingot)
                	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO}) ---刷新主城市的
                	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                end
                if callBack then
                    callBack(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
        end,--失败回调
        targetNeedsToRetain = parNode,--需要保存引用的目标
        loadingParent = parNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function XuanShangRenWuData.httpChallengeOfferReward( sParams )
    local parNode = sParams.parNode
    if not parNode then
        return
    end
    local callBack = sParams.callBack
    XTHDHttp:requestAsyncInGameWithParams({
        modules="challengeWanted?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                if callBack then
                    callBack(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
        end,--失败回调
        targetNeedsToRetain = parNode,--需要保存引用的目标
        loadingParent = parNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function XuanShangRenWuData.httpChallengeOfferRewardOkey( sParams )
    local parNode = sParams.parNode
    if not parNode then
        return
    end
    local callBack = sParams.callBack
    XTHDHttp:requestAsyncInGameWithParams({
        modules="onkyChallengeWanted?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                if callBack then
                    callBack(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
        end,--失败回调
        targetNeedsToRetain = parNode,--需要保存引用的目标
        loadingParent = parNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function XuanShangRenWuData.httpGetOfferRewardShop( sParams )
    local parNode = sParams.parNode
    if not parNode then
        return
    end
    local callBack = sParams.callBack
    XTHDHttp:requestAsyncInGameWithParams({
        modules="wantedShopList?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                if callBack then
                    callBack(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
        end,--失败回调
        targetNeedsToRetain = parNode,--需要保存引用的目标
        loadingParent = parNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function XuanShangRenWuData.httpBuyOfferRewardShop( sParams )
    local parNode = sParams.parNode
    local _configId = tonumber(sParams.configId) or 0
    if not parNode or _configId == 0 then
        return
    end
    local callBack = sParams.callBack
    XTHDHttp:requestAsyncInGameWithParams({
        modules="wantedShopBuy?",
        params = {configId = _configId},
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                if callBack then
                    callBack(data)
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-------"网络请求失败!")
        end,--失败回调
        targetNeedsToRetain = parNode,--需要保存引用的目标
        loadingParent = parNode,
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end
