--[[
字体颜色大小设置：
	<#F00> = <#FF0000> 	= 文字颜色
	<32>				= 字体大小
	<font Arial>		= 文字字体(支持TTF)
	<img filename>		= 图片
	<img_32*32 fname> 	= 指定显示大小的图片
    <>                  = 还原字体大小颜色为默认值
	\n \t 				= 换行 和 tab，可能暂时实现得不是很好

动画设置：
	<blink 文字>		= （动画）闪烁那些文字
	<rotate 文字>		= （动画）旋转那些文字
	<scale 文字>		= （动画）缩放那些文字
]]--

RichTextPlug = RichTextPlug or { }

function RichTextPlug.init(richTextNode, fontSize, textColor, textFont)

    richTextNode._text = "<#FF0>请在<36>这里<font res/fonts/hwzs.ttf>设置<>\n\t<rotate 文字哦>"

    richTextNode._fontSizeDef = fontSize or 26
    richTextNode._textColorDef = textColor or cc.c3b(255, 255, 255)
    richTextNode._textFontDef = textFont or "res/fonts/def.ttf"
    richTextNode._fontSize = richTextNode._fontSizeDef
    richTextNode._textColor = richTextNode._textColorDef
    richTextNode._textFont = richTextNode._textFontDef
    richTextNode._elements = { }
    richTextNode._outLine = 0
    richTextNode._underLine = false

    richTextNode.setMultiLineMode = RichTextPlug.setMultiLineMode
    richTextNode.textAnimation = RichTextPlug.textAnimation
    richTextNode.defaultImgCb = RichTextPlug.defaultImgCb
    richTextNode.addCustomNode = RichTextPlug.addCustomNode
    richTextNode.setText = RichTextPlug.setText
    richTextNode.setDefaultFont = RichTextPlug.setDefaultFont

    richTextNode:setContentSize(200,100)
    richTextNode:setText(richTextNode._text)
end

-- 多行模式-即设置ignoreContentAdaptWithSize(false)和设置setContentSize()开启自动换行
function RichTextPlug:setMultiLineMode(b)
    self:ignoreContentAdaptWithSize(not b)
    return self
end

function RichTextPlug:setDefaultFont(font)
    self._textFont = font
end

function RichTextPlug:setDefaultFontSize(size)
    self._fontSizeDef = size
end

function RichTextPlug:setDefaultTextColor(color)
    self._textColorDef = color
end

local C_AND = string.byte("&")
local P_BEG = string.byte("<")
local P_END = string.byte(">")
local SHARP = string.byte("#")
local ULINE = string.byte("_")
local C_LN = string.byte("\n")
local C_TAB = string.byte("\t")

local str_trim = function(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

local function c3b_to_c4b(c3b)
    return { r = c3b.r, g = c3b.g, b = c3b.b, a = 255 }
end

-- #RRGGBB/#RGB to c3b
local function c3b_parse(s)
    local r, g, b = 0, 0, 0
    if #s == 4 then
        r, g, b = tonumber(string.rep(string.sub(s, 2, 2), 2), 16),
        tonumber(string.rep(string.sub(s, 3, 3), 2), 16),
        tonumber(string.rep(string.sub(s, 4, 4), 2), 16)
    elseif #s == 7 then
        r, g, b = tonumber(string.sub(s, 2, 3), 16),
        tonumber(string.sub(s, 4, 5), 16),
        tonumber(string.sub(s, 6, 7), 16)
    end
    return cc.c3b(r, g, b)
end

function RichTextPlug:setText(text)
    assert(text)

    self._text = text
    self._callback = self.textAnimation

    for _, lbl in pairs(self._elements) do
        self:removeElement(lbl)
    end
    self._elements = { }

    local p, i, b, c = 1, 1, false
    local str, len, chr, obj = "", #text

    while i <= len do
        c = string.byte(text, i)
        if c == P_BEG then
            -- <
            if (not b) and(i > p) then
                str = string.sub(text, p, i - 1)
                obj = ccui.RichElementText:create(0, self._textColor, 255, str, self._textFont, self._fontSize)
                self:pushBackElement(obj)
                self._elements[#self._elements + 1] = obj

                self._textColor = self._textColorDef
                self._fontSize = self._fontSizeDef
                self._textFont = self._textFontDef
            end

            b = true; p = i + 1; i = p

            while i <= len do
                if string.byte(text, i) == P_END then
                    -- >
                    b = false
                    if i > p then
                        str = str_trim(string.sub(text, p, i - 1))
                        chr = string.byte(str, 1)

                        if chr == SHARP and(#str == 4 or #str == 7) and tonumber(string.sub(str, 2), 16) then
                            self._textColor = c3b_parse(str)
                        elseif tonumber(str) then
                            self._fontSize = tonumber(str)
                        elseif string.sub(str, 1, 5) == "font " or string.sub(str, 1, 5) == "font_" then
                            self._textFont = str_trim(string.sub(str, 5, i - 1))
                        elseif string.sub(str, 1, 8) == "outLine " or string.sub(str, 1, 8) == "outLine_" then
                            local strTemp = str_trim(string.sub(str, 8, i - 1))
                            self._outLine = tonumber(strTemp)
                        elseif string.sub(str, 1, 10) == "underLine " or string.sub(str, 1, 10) == "underLine_" then
                            local strTemp = str_trim(string.sub(str, 10, i - 1))
                            if strTemp == "true" then
                                self._underLine = true
                            else
                                self._underLine = false
                            end

                        elseif string.sub(str, 1, 4) == "img " or string.sub(str, 1, 4) == "img_" then
                            self:addCustomNode(self.defaultImgCb(str_trim(string.sub(str, 4, i - 1))))
                        elseif self._callback then
                            self:addCustomNode(self._callback(str, self))
                        end
                    end

                    break
                end
                i = i + 1
            end

            p = i + 1
        elseif c == C_LN or c == C_TAB then
            if (not b) and(i > p) then
                str = string.sub(text, p, i - 1)
                obj = ccui.RichElementText:create(0, self._textColor, 255, str, self._textFont, self._fontSize)
                self:pushBackElement(obj)
                self._elements[#self._elements + 1] = obj
            end

            obj = cc.Node:create()
            if c == C_LN then
                obj:setContentSize(cc.size(self:getContentSize().width, 1))
            else
                obj:setContentSize(cc.size(self._fontSize, 1))
            end
            self:addCustomNode(obj)

            p = i + 1
        end
        i = i + 1
    end

    if (not b) and(p <= len) then
        str = string.sub(text, p)
        obj = ccui.RichElementText:create(0, self._textColor, 255, str, self._textFont, self._fontSize)
        self:pushBackElement(obj)
        self._elements[#self._elements + 1] = obj
    end

    return self
end

function RichTextPlug.textAnimation(text, sender)
    local BLINK = "blink "
    local ROTATE = "rotate "
    local SCALE = "scale "

    if string.sub(text, 1, #BLINK) == BLINK then
        local lbl = ccui.Text:create(string.sub(text, #BLINK + 1), sender._textFont, sender._fontSize)
        lbl:setTextColor(c3b_to_c4b(sender._textColor))
        lbl:runAction(cc.RepeatForever:create(cc.Blink:create(10, 10)))
        return lbl
    elseif string.sub(text, 1, #ROTATE) == ROTATE then
        local lbl = ccui.Text:create(string.sub(text, #ROTATE + 1), sender._textFont, sender._fontSize)
        lbl:setTextColor(c3b_to_c4b(sender._textColor))
        lbl:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.1, 5)))
        return lbl
    elseif string.sub(text, 1, #SCALE) == SCALE then
        local lbl = ccui.Text:create(string.sub(text, #SCALE + 1), sender._textFont, sender._fontSize)
        lbl:setTextColor(c3b_to_c4b(sender._textColor))
        lbl:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(1.0, 0.1), cc.ScaleTo:create(1.0, 1.0))))
        return lbl
    end

    return nil
end

function RichTextPlug.defaultImgCb(text)
    local w, h = 0, 0
    if string.byte(text, 1) == ULINE then
        local p1 = string.find(text, "*")
        local p2 = string.find(text, " ")

        if p1 and p2 and p2 > p1 then
            w = tonumber(string.sub(text, 2, p1 - 1))
            h = tonumber(string.sub(text, p1 + 1, p2))
        end

        if p2 then
            text = str_trim(string.sub(text, p2 + 1))
        end
    end

    local spf, img = cc.SpriteFrameCache:getInstance():getSpriteFrame(text), nil
    if spf then
        -- 	img = cc.Sprite:createWithSpriteFrame(spf)
        img = ccui.ImageView:create(text, ccui.TextureResType.plistType)
    elseif cc.FileUtils:getInstance():isFileExist(text) then
        --   	img = cc.Sprite:create(text)
        img = ccui.ImageView:create(text, ccui.TextureResType.localType)
    end

    if img and w and h and w > 0 and h > 0 then
        img:ignoreContentAdaptWithSize(false)
        -- cc.Sprite can't do this, so we use ccui.ImageView
        img:setContentSize(cc.size(w, h))
    end

    return img
end

function RichTextPlug:addCustomNode(node)
    if node then
        local anc = node:getAnchorPoint()
        if anc.x ~= 0.0 or anc.y ~= 0.0 then
            local tmp = node
            local siz = node:getContentSize()
            node = cc.Node:create()
            node:setContentSize(siz)
            node:addChild(tmp)
            tmp:setPosition(cc.p(siz.width * anc.x, siz.height * anc.y))
        end
        local obj = ccui.RichElementCustomNode:create(0, cc.c3b(255, 255, 255), 255, node)
        self:pushBackElement(obj)
        self._elements[#self._elements + 1] = obj
    end
end

return RichTextPlug