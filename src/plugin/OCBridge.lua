-- ******** Lua与OC的交互类 ***********

--lua 调用OC
function zctech.ZCCallOC( className, methodName, args )
    print("enter zctech.ZCCallOC")
    local luaoc = require("src/cocos/cocos2d/luaoc.lua")
    local ok,ret  = luaoc.callStaticMethod(className, methodName, args)
    if not ok then
        print("luaoc error:"..tostring(ret)..",className="..tostring(className)..",methodName="..tostring(methodName))
    else
        print("The oc ret is:"..tostring(ret)..",className="..tostring(className)..",methodName="..tostring(methodName))
    end
    --如果调AppStore ，则使用zctech.ZCCallOC("ShowAppStore","callAppStore")
end


--退出SDK登录
function zctech.ocLogoutSDK(  )
    function zctech_logout(  )
        MsgCenter:reset()    ------断开Socket
        XTHD.replaceToLoginScene()
    end

    local arg = {callback = zctech_logout}
    zctech.ZCCallOC(OC_ZCJNIHELPER,"gameSDKLogout",arg)
end
