-- zctech = {}
if not zctech then
    zctech = {}
end

-----------------string_began-----------------------------

--写在这是为了增加容错性，如果没有需要的图片，则返回默认图片，而不至于程序报错，也能避免程序中使用图片的时候每次都判断是否存在

--用来获取英雄的头像图片
function zctech.getHeroAvatorImgById(hero_id)
    local imgpath = "res/image/avatar/avatar_"..hero_id..".png" 
    if not cc.Director:getInstance():getTextureCache():addImage(imgpath) then
        imgpath = "res/image/avatar/avatar_1.png"
    end
    return imgpath
end

