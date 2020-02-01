-- ******** Lua与java的交互类 ***********

--lua调用java
function zctech.ZCCallJava(className,functionName,args,sigs)
    local luaj = requires("src/cocos/cocos2d/luaj.lua")
    local ok,ret  = luaj.callStaticMethod(className,functionName,args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("The java ret is:", ret)
    end
end


--游戏退出SDK登录
function zctech.ZCLogout()
    local args = {}
    local sigs = "()V"
    zctech.ZCCallJava(JAVA_PLATFORMSDK,"ZCLogout",args,sigs)
end

--游戏返回键
function zctech.ZCGameBack(  )
    local args = {}
    local sigs = "()V"
    zctech.ZCCallJava(JAVA_PLATFORMSDK,"gameBackKey",args,sigs)
end

--获取百度推送的appid userid channelid
--获取友盟推送的device token 
function zctech.ZCGetBPushData()
    --如果是andro平台的话，则需要从java端获取百度channelid，然后保存的到userdefault中
    if ZC_targetPlatform == cc.PLATFORM_OS_ANDROID then
        function callbackBP( param )
            if param ~= nil and param ~= "" and string.len(param) ~= 0 then
                cc.UserDefault:getInstance():setStringForKey(BPUSH_USER_ID,param)
                print(" zctech.ZCGetBPushData 123-------------->"..tostring(param))
            end
        end
        local args = {callbackBP}
        local sigs = "(I)V"
        zctech.ZCCallJava(JAVA_PLATFORMSDK,"getPushData",args,sigs)
        print(" zctech.ZCGetBPushData 123")
    end
end


--玩家退出游戏
function zctech.javaZctechExit(  )
    local arg = {}
    local sig = "()V"
    zctech.ZCCallJava(JAVA_PLATFORMSDK,"exitGame",arg,sig)
end

