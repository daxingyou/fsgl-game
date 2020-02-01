local currentLanguageCode =  cc.Application:getInstance():getCurrentLanguageCode()

-- currentLanguageCode = "en"
print("currentLanguageCode="..tostring(currentLanguageCode))
--判断语言简称
currentLanguageCode = "zh"
if currentLanguageCode == "zh" then
	requires("src/fsgl/language/language_zh.lua")
end

requires("src/fsgl/language/language_"..currentLanguageCode..".lua")
