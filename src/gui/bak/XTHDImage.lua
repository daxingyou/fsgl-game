--  Created by zhangchao on 14-11-23.
--[[
    XTHDImage的本质就是一个Sprite,但XTHDImage可以在加载本地数据失败的情况下，
    自动从网络下载指定图片并保存在缓存目录中，下一次即可从本地加载。
  ]]
XTHDImage = class("XTHDImage", function(params)
end)


function XTHDImage:create(fileName)
    return XTHDImage.new(fileName)
end
--[[
    fileName 文件名，例如：item/i.png
    imageUrlDirectory 网络资源的地址目录，例如：http://img2.hanjiangsanguo.com/hjimg/
    注意：imageUrlDirectory 应该是目录，XTHDImage内部会拼接imageUrlDirectory和fileName
  ]]
function XTHDImage:createWithFileOrUrlDirectory(fileName,imageUrlDirectory)
    
end

--此方法是为了在每次加载图片的时候，避免手动输入url，重新定义方法是为了避免破坏之前的程序的实现
function XTHDImage:createWithFileInGame(fileName,imageUrlDirectory)
   
end


