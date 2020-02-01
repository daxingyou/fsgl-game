--[[
----authored by LITAO
原文本格式为：
<img=res/image/common/a.png />我是你大人森罗万象<img=res/image/common/b.png /><color click >哈哈</color><color=#0f90ff click fontSize=20 font=Helvetica >第一段文字<img=res/image/common/a.png height=20 width=20 />第二段文字</color>

该函数用于解析公告和聊天传输的富文本格式
解析后的格式为：
 table
 {
    1 =  table
     {
        img =  res/image/common/a.png
     }
    2 =  table
     {
        color =  table
         {
            r =  255
            b =  255
            g =  255
         }
        word =  我是你大人森罗万象
     }
    3 =  table
     {
        img =  res/image/common/b.png
     }
    4 =  table
     {
        word =  哈哈
        click =  true
        color =  table
         {
            r =  255
            b =  255
            g =  255
         }
     }
    5 =  table
     {
        color =  table
         {
            r =  15
            b =  255
            g =  144
         }
        click =  true
        word =  第一段文字
        font =  Helvetica
        fontSize =  20
     }
    6 =  table
     {
        width =  20
        height =  20
        img =  res/image/common/a.png
     }
    7 =  table
     {
        color =  table
         {
            r =  15
            b =  255
            g =  144
         }
        click =  true
        word =  第二段文字
        font =  Helvetica
        fontSize =  20
     }
 }
]]
RichLabel = class("RichLabel",function( )
	return cc.Node:create()
end)

function RichLabel:ctor(isShadow,maxWidth,clickFuncs,defaultParams)
	self._isShadow = (isShadow == nil) and true or isShadow
	self._width = maxWidth
	self._clickFuncs = clickFuncs
	if defaultParams then 
		self._defaultFontSize = defaultParams.fontSize
		self._defaultColor = defaultParams.color 
	end 
	self:setCascadeOpacityEnabled(true)
end
--分割标签
function RichLabel:parse( str )
    if not str or str == "" then 
        return {}
    end 
    local words = {}
    local i = 1
    while(true) do 
    	local x,y = string.find(str,"<color")
    	if x and x == 1 then 
    		local a,b = string.find(str,"</color>")
	    	words[i] = string.sub(str,y + 1,a - 1)
	    	str = string.sub(str,b + 1)
	    elseif x and x > 1 then 
	    	words[i] = string.sub(str,1,x - 1)
	    	str = string.sub(str,x)
	    else
	    	if str and #str > 0 then 
	    		words[i] = str
	    	end 
	    	break
    	end 
    	i = i + 1
    end 
    words = self:parseLabels(words)
    return words
end
--[[
分割image标签	
]]
function RichLabel:parseLabels(source)
	if #source < 1 then 
		return {}
	end 
	local message = {}
	local j = 1	
	for i = 1,#source do 
		local str = source[i]
		local _color = ""
		while true do 
			if not str or #str < 1 then 
				break
			end 
			---是否有顏色标签
			local endPos = 0
			local x,y = string.find(str,"=#")
			if x then 
				endPos = string.find(str,">")
				_color = string.sub(str,1,endPos)
				str = string.sub(str,endPos + 1)
			end
			x,y = string.find(str,"<img=")	
			if not x then ---无图片
				message[j] = self:getLabelProperty(_color..str)
				j = j + 1
				break
			else 
				if x == 1 then 
					endPos = string.find(str,"/>")
					local img = string.sub(str,x,endPos + 1)
					message[j] = self:getImageProperty(img)
					j = j + 1
					str = string.sub(str,endPos + 2)
				elseif x > 1 then 					
					message[j] = self:getLabelProperty(_color..string.sub(str,1,x - 1))
					j = j + 1
					str = string.sub(str,x)
				end 
			end	
		end 
	end 
	return message
end

function RichLabel:getImageProperty(source)
	local img = {}
	if source and #source > 0 then 
		local x = string.find(source,"=")
		local y = string.find(source," ")
		local path = string.sub(source,x + 1,y - 1)
		img.img = path
		x,y = string.find(source,"width=")
		if x then 			
			x = string.find(source," ",y)
			local _x = string.find(source,"/>",y)
			x = ( _x and (not x or x > _x)) and _x or x
			local width = string.sub(source,y + 1,x - 1)
			img.width = tonumber(width)
		end 
		x,y = string.find(source,"height=")
		if x then 			
			x = string.find(source," ",y)
			local _x = string.find(source,"/>",y)
			x = ( _x and (not x or x > _x)) and _x or x			
			local height = string.sub(source,y + 1,x - 1)
			img.height = tonumber(height)
		end 
	end 
	return img
end
----解析颜色标签
function RichLabel:getLabelProperty(str)
	local message = {}
	if not str or str == "" then 
		return {}
	end 	
	local endPos = string.find(str,">")
	local params = ""
	if endPos then 
		params = string.sub(str,1,endPos)
		str = string.sub(str,endPos + 1)
	end 

	local x,y = string.find(params,"=#")
	local color = ""
	if x then ----有特殊的颜色
		x = string.find(params," ",y)
		local _x = string.find(params,">",y)
		x = ( _x and (not x or x > _x)) and _x or x		
		color = string.sub(params,y + 1,x - 1)
		if string.find(params,"click") then 
			message = {
				click = true,
				color = self:consistColor(color),
				word = str
			}
		else 
			message = {
				color = self:consistColor(color),
				word = str
			}
		end 
	else -----无特殊的颜色
		if not string.find(params,"click") then 
			message = {
				word = str,
				color = self._defaultColor or cc.c3b(255,255,255),
			}
		else 
			message = {
				word = str,
				color = self._defaultColor or cc.c3b(255,255,255),
				click = true
			}
		end 
	end 
	x,y = string.find(params,"font=")
	if x then 
		x = string.find(params," ",y)
		local _x = string.find(params,">",y)
		x = ( _x and (not x or x > _x)) and _x or x		
		message.font = string.sub(params,y + 1,x - 1)
	else 
		message.font = "Helvetica"
	end 
	x,y = string.find(params,"fontSize=")
	if x then 
		x = string.find(params," ",y)
		local _x = string.find(params,">",y)
		x = ( _x and (not x or x > _x)) and _x or x		
		message.fontSize = tonumber(string.sub(params,y + 1,x - 1))
	else 
		message.fontSize = self._defaultFontSize or 18
	end 
	return message
end

function RichLabel:consistColor(colorStr,c4b)	
	if not colorStr or colorStr == "" then
		if c4b then  
			return cc.c4b(255,255,255,255)
		else
			return cc.c3b(255,255,255)
		end 
	end 
	local r,g,b 
	r = tonumber("0x"..string.sub(colorStr,1,2))
	g = tonumber("0x"..string.sub(colorStr,3,4))
	b = tonumber("0x"..string.sub(colorStr,5,6))
	if not c4b then 
		return cc.c3b(r,g,b)
	else 
		return cc.c4b(r,g,b,255)
	end 
end
------转换公告文字
function RichLabel:parseAnnouncementMsg( msg )
	local _words2 = {}
	if msg then 
		if string.find(msg,"</color>") then 
			local _words = {}
			local _color = {}
			local i = 1
			local beginPos,endPos
			beginPos = 1
			--------------------------------------------------------------先分段
			while true do
				local x,y = string.find(msg,"</color>",beginPos)
				if not x then
					if beginPos < #msg then 
						_words[i] = string.sub(msg,beginPos,#msg)
					end  
					break
				end 
				_words[i] = string.sub(msg,beginPos,x - 1)	
				beginPos = y + 1
				i = i + 1		
			end 
			--------------------------------------------------------------再截颜色、分文字
			local j = 1
			for i = 1,#_words do 
				local x,y = string.find(_words[i],"<color=#")
				if not x then 
					_words2[j] = {txt = _words[i],color = cc.c4b(255,255,255,255)}
					j = j + 1
				else 
					if x > 1 then 
						_words2[j] = {txt = string.sub(_words[i],1,x - 1),color = cc.c4b(255,255,255,255)}
						local color = self:consistColor(string.sub(_words[i],y + 1,y + 6),true)
						x,y = string.find(_words[i],">")
						if x then 
							_words2[j + 1] = {txt = string.sub(_words[i],x + 1),color = color}
							j = j + 2
						end
					elseif x == 1 then 
						local color = self:consistColor(string.sub(_words[i],y + 1,y + 6),true)
						x,y = string.find(_words[i],">")
						if x then 
							_words2[j] = {txt = string.sub(_words[i],x + 1),color = color}
							j = j + 1
						end 
					end 
				end
			end
		else 
			_words2[1] = {txt = msg,color = cc.c3b(255,255,255,255)} 
		end 
	end 
	return _words2
end

function RichLabel:createAnAnnouncement( msg )
	local node = cc.Node:create()
	local _words = self:parseAnnouncementMsg(msg)
	local x = 0 
	local y = 0
	local width = 0 
	local height = 0
	for i = 1,#_words do 
		local _label = XTHDLabel:createWithSystemFont(_words[i].txt,XTHD.SystemFont,18)
		_label:setTextColor(_words[i].color)
		_label:enableShadow(cc.c4b(0,0,0,150),cc.size(1,-1))
		node:addChild(_label)
		_label:setAnchorPoint(0,0.5)
		_label:setPosition(x,y)
		x = x + _label:getBoundingBox().width
		width = _label:getBoundingBox().width + width
		height = _label:getBoundingBox().height
	end 
	node:setContentSize(cc.size(width,height))
	node:setAnchorPoint(0,1.0)
	return node
end
--[[
params{
	contentWidth = width,---该富文本可显示的区域宽度，会根据宽度自动折行 
	content = "" --用于显示的文本内容
	clickFuncs = {} ----如果文本内嵌有可点击的对象，按顺序加入点击响应的回调函数
}
]]
function RichLabel:createARichText(source,isShadow,maxWidth,clickFuncs,defaultParams)
	local node = RichLabel.new(isShadow,maxWidth,clickFuncs,defaultParams)
	if not source or #source < 1 then 
		return node
	end 
	local data = nil
	if type(source) == "string" then 
		data = node:parse(source)
	elseif type(source) == "table" then 
		data = source
	end 
	if not data or #data < 1 then 
		return node
	end 
	if not node._width or node._width == 0 then ----一行显示 
		node:fillByOneLine(node,data,node._clickFuncs)
	else ---多行显示 
		node:fillByMultiLines(node,data,node._width,node._clickFuncs)
	end 
	return node	
end

function RichLabel:fillByOneLine(targ,data,clickFuncs)
	if targ and data then 
		local x = 0
		local y = 0
		local width = 0
		local height = 0
		local j = 1
		for i = 1,#data do 
			local node = nil
			if data[i].img then 
				node = cc.Sprite:create(data[i].img)
				if node then 
					local size = node:getContentSize()
					if data[i].width then 
						node:setScaleX(data[i].width / size.width)
					end 
					if data[i].height then 
						node:setScaleY(data[i].height / size.height)
					end 
				end 
			elseif data[i].word then 
				node = XTHDLabel:createWithParams({
			        text = data[i].word,
			        fontSize = data[i].fontSize,
			        color = data[i].color
		        })
				if self._isShadow then 
		        	node:enableShadow(cc.c4b(0,0,0,150),cc.size(1,-1))
		        end 
		        if data[i].click then 
		        	node:setTouchEndedCallback(function( )
		        		if clickFuncs and clickFuncs[j] then 
		        			clickFuncs[j]()
		        			j = j + 1
		        		end 
		        	end)
		        end 
			end 
			if node then 
				targ:addChild(node)
				node:setAnchorPoint(0,0.5)
				node:setPosition(x,y)
				width = width + node:getBoundingBox().width
				height = height > node:getBoundingBox().height and height or node:getBoundingBox().height
				x = x + node:getBoundingBox().width
			end 
		end 
		targ:setContentSize(cc.size(width,height))
		targ:setAnchorPoint(0,1.0)
	end 
end
--创建精灵
function RichLabel:fillByMultiLines(targ,data,maxWidth,clickFuncs)
	local spriteArray = {}
	local j = 1
	for i, dic in ipairs(data) do
		if not dic.img then 
			local textArr = self:stringToChar(dic.word)
			if #textArr > 0 then --创建文字
				local fontName = dic.font
				local fontSize = dic.fontSize
				local fontColor = dic.color
			    local isClicking = false
				for j, word in ipairs(textArr) do
					local label = XTHDLabel:createWithParams({
				        text = word,
				        fontSize = fontSize,
				        color = fontColor
			        })
			        if self._isShadow then 
		        		label:enableShadow(cc.c4b(0,0,0,150),cc.size(1,-1))
		        	end 
			        if dic.click then 
			        	label:setTouchBeganCallback(function( )
			        		if isClicking then 
			        			return false
			        		else 
			        			isClicking = true
			        			return true 
			        		end 
			        	end)
			        	label:setTouchEndedCallback(function( )			        		
			        		if clickFuncs and clickFuncs[j] then 
			        			clickFuncs[j]()
			        			j = j + 1
			        		end 
			        		isClicking = false
			        	end)
			        end 
					spriteArray[#spriteArray + 1] = label
					targ:addChild(label)
				end
			end 
		else
			local sprite = cc.Sprite:create(dic.img)
			if dic.width then 
				sprite:setScaleX(dic.width / sprite:getBoundingBox().width)
			end 
			if dic.height then 
				sprite:setScaleY(dic.height / sprite:getBoundingBox().height)
			end 
			spriteArray[#spriteArray + 1] = sprite
			targ:addChild(sprite)		
		end
	end
	self:adjustPosition(spriteArray,maxWidth)
	targ:setContentSize(cc.size(self._maxWidth,self._maxHeight))
	targ:setAnchorPoint(0.5,0.5)
end
-- 拆分出单个字符
function RichLabel:stringToChar(str)
    local list = {}
    local len = string.len(str)
    local i = 1 
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        table.insert(list, char)
    end
	return list, len
end
--调整位置（设置文字和尺寸都会触发此方法）
function RichLabel:adjustPosition(source,maxWidth)

	local spriteArray = source
	if not spriteArray then --还没创建
		return
	end
	--获得每个精灵的宽度和高度
	local widthArr, heightArr = self:getSizeOfSprites(spriteArray)

	--获得每个精灵的坐标
	local pointArrX, pointArrY = self:getPointOfSprite(widthArr, heightArr,maxWidth)

	for i, sprite in ipairs(spriteArray) do
		sprite:setPosition(pointArrX[i], pointArrY[i])
	end
end

--获得每个精灵的尺寸
function RichLabel:getSizeOfSprites(spriteArray)
	local widthArr = {} --宽度数组
	local heightArr = {} --高度数组
	--精灵的尺寸
	for i, sprite in ipairs(spriteArray) do
		local rect = sprite:getBoundingBox()
		widthArr[i] = rect.width
		heightArr[i] = rect.height
	end
	return widthArr, heightArr
end

--获得每个精灵的位置
function RichLabel:getPointOfSprite(widthArr, heightArr, width)
	local totalWidth = width

	local maxWidth = 0
	local maxHeight = 0

	local spriteNum = #widthArr

	--从左往右，从上往下拓展
	local curX = 0 --当前x坐标偏移
	
	local curIndexX = 1 --当前横轴index
	local curIndexY = 1 --当前纵轴index
	
	local pointArrX = {} --每个精灵的x坐标

	local rowIndexArr = {} --行数组，以行为index储存精灵组
	local indexArrY = {} --每个精灵的行index

	--计算宽度，并自动换行
	for i, spriteWidth in ipairs(widthArr) do
		local nexX = curX + spriteWidth
		local pointX
		local rowIndex = curIndexY

		local halfWidth = spriteWidth * 0.5
		if nexX > totalWidth and totalWidth ~= 0 then --超出界限了
			pointX = halfWidth
			if curIndexX == 1 then --当前是第一个，
				curX = 0-- 重置x
			else --不是第一个，当前行已经不足容纳
				rowIndex = curIndexY + 1 --换行
				curX = spriteWidth
			end
			curIndexX = 1 --x坐标重置
			curIndexY = curIndexY + 1 --y坐标自增
		else
			pointX = curX + halfWidth --精灵坐标x
			curX = pointX + halfWidth --精灵最右侧坐标
			curIndexX = curIndexX + 1
		end
		pointArrX[i] = pointX --保存每个精灵的x坐标

		indexArrY[i] = rowIndex --保存每个精灵的行

		local tmpIndexArr = rowIndexArr[rowIndex]

		if not tmpIndexArr then --没有就创建
			tmpIndexArr = {}
			rowIndexArr[rowIndex] = tmpIndexArr
		end
		tmpIndexArr[#tmpIndexArr + 1] = i --保存相同行对应的精灵

		if curX > maxWidth then
			maxWidth = curX
		end
	end

	local curY = 0
	local rowHeightArr = {} --每一行的y坐标

	--计算每一行的高度
	for i, rowInfo in ipairs(rowIndexArr) do
		local rowHeight = 0
		for j, index in ipairs(rowInfo) do --计算最高的精灵
			local height = heightArr[index]
			if height > rowHeight then
				rowHeight = height
			end
		end
		local pointY = curY + rowHeight * 0.5 --当前行所有精灵的y坐标（正数，未取反）
		rowHeightArr[#rowHeightArr + 1] = - pointY --从左往右，从上到下扩展，所以是负数
		curY = curY + rowHeight --当前行的边缘坐标（正数）

		if curY > maxHeight then
			maxHeight = curY
		end
	end

	self._maxWidth = maxWidth
	self._maxHeight = maxHeight

	local pointArrY = {}

	for i = 1, spriteNum do
		local indexY = indexArrY[i] --y坐标是先读取精灵的行，然后再找出该行对应的坐标
		local pointY = rowHeightArr[indexY]
		pointArrY[i] = pointY
	end

	return pointArrX, pointArrY
end

----获取文字，不要标签
function RichLabel:getStringOnly(str)
	local data = self:parseAnnouncementMsg(str)
	local _word = ""
	for i = 1,#data do 
		if data[i].txt then 
			_word = _word..data[i].txt
		end 
	end 	
	return _word,data
end

function RichLabel:setString( source )
	-- dump(source,"_words2")
	local anchor = self:getAnchorPoint()
	local x,y = self:getPosition()
	self:removeAllChildren()
	if not source or #source < 1 then 
		return
	end 
	local data = nil
	if type(source) == "string" then 
		data = self:parse(source)
	elseif type(source) == "table" then 
		data = source
	end 
	if not data or #data < 1 then 
		return 
	end 
	if not self._width or self._width == 0 then ----一行显示 
		self:fillByOneLine(self,data,clickFuncs)
	else ---多行显示 
		self:fillByMultiLines(self,data,self._width,clickFuncs)
	end 
	self:setAnchorPoint(anchor)
	self:setPosition(x,y)
end

function RichLabel:setStringByDatas( data )
	local anchor = self:getAnchorPoint()
	local x,y = self:getPosition()
	self:removeAllChildren()
	if not data or type(data) ~= "table" or #data < 1 then 
		return
	end 
	if not self._width or self._width == 0 then ----一行显示 
		self:fillByOneLine(self,data,clickFuncs)
	else ---多行显示 
		self:fillByMultiLines(self,data,self._width,clickFuncs)
	end 
	self:setAnchorPoint(anchor)
	self:setPosition(x,y)
end