-- FileName: YouJiangData.lua
-- Author: wangming
-- Date: 2015-10-24
-- Purpose: 邮件数据封装
--[[TODO List]]

YouJiangData = {}

function YouJiangData.getMailData( sData )
	return YouJiangData.data
end

function YouJiangData.setMailData( sData )
	YouJiangData.data = sData
end

local function httpDo( sParams )
	local parNode = sParams.parNode
    local callBack = sParams.callBack
    local _params = sParams.params
    local _modules = sParams.modules
    XTHDHttp:requestAsyncInGameWithParams({
        modules = _modules,
        params = _params,
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

--邮件列表请求
function YouJiangData.httpGetMailList( sParNode, sCallBack )
	if not sParNode then
        return
    end
    local function endCall( sData )
		YouJiangData.setMailData(sData)
		if sCallBack then
			sCallBack(sData)
		end
    end
	local _params = {
		parNode = sParNode,
		callBack = endCall,
		modules = "emailList?",
	}
	httpDo(_params)
end

--读取邮件
function YouJiangData.httpReadMailList( sParNode, sCallBack, sParams)
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "readEmail?",
        params = sParams,
    }
    httpDo(_params)
end

--领取邮件附件
function YouJiangData.httpGetMailExtra( sParNode, sCallBack, sParams)
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "extractionEmail?",
        params = sParams,
    }
    httpDo(_params)
end

--一键领取邮件附件
function YouJiangData.httpGetMailExtraOneKey( sParNode, sCallBack)
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "aKeyGet?",
    }
    httpDo(_params)
end


--一键领取邮件附件
function YouJiangData.httpGetMailDel( sParNode, sCallBack, sParams)
    if not sParNode then
        return
    end
    local _params = {
        parNode = sParNode,
        callBack = sCallBack,
        modules = "deleteEmail?",
        params = sParams,
    }
    httpDo(_params)
end