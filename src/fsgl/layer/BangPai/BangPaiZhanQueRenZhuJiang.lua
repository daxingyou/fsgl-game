--createdBy xingchen 
--2015/10/27
--帮派战确认主将界面
local BangPaiZhanQueRenZhuJiang = class("BangPaiZhanQueRenZhuJiang",function()
    return XTHD.createBasePageLayer()
end)

function BangPaiZhanQueRenZhuJiang:ctor(data)
	self.lordBgTable = {}
	self.lordListData = {}
	self:setLordListData(data)
	self:initLayer()
end

function BangPaiZhanQueRenZhuJiang:initLayer()
	local winSize = cc.Director:getInstance():getWinSize()
	local _topBarHeight = self.topBarHeight or 40
    local _bg = cc.Sprite:create("res/image/common/zhujiang.png")
	_bg:setContentSize(winSize)
    _bg:setPosition(cc.p(self:getContentSize().width/2,(self:getContentSize().height - _topBarHeight)/2 ))
    self:addChild(_bg)
	-- local _bg = cc.Sprite:create("res/image/guild/guildContent_bg.png")
 --    _bg:setPosition(cc.p(self:getContentSize().width/2,(self:getContentSize().height - 55)/2 ))
 --    self:addChild(_bg)

    table.sort(self.lordListData,function(data1,data2)
    		return tonumber(data1.charId) < tonumber(data2.charId)
    	end)

    -- local _bghero = cc.Sprite:create("res/image/guild/guildWar/guildWar_lordBg.png")
    -- _bghero:setAnchorPoint(cc.p(0.5,0))
    -- _bghero:setPosition(cc.p(_bg:getContentSize().width/2,20-10))
	-- _bg:addChild(_bghero)
	--主将logo
    local _bglord = cc.Sprite:create("res/image/guild/guildWar/guildWar_lordTitleBg.png")
    _bglord:setAnchorPoint(cc.p(0,0.5))
    _bglord:setPosition(cc.p(_bg:getContentSize().width/2 - _bglord:getContentSize().width -50 ,_bg:getContentSize().height/2+30))
	_bg:addChild(_bglord)
	
	-- local _lordBgMidUpPos = cc.p(_bglord:getBoundingBox().x+_bglord:getBoundingBox().width/2,_bglord:getBoundingBox().y+_bglord:getBoundingBox().height)
	local _lordBgMidUpPos = cc.p(_bg:getContentSize().width/2,_bg:getContentSize().height)
    local _btnPos = {
	--     cc.p(_lordBgMidUpPos.x-50,_lordBgMidUpPos.y - 195),
	--     cc.p(_lordBgMidUpPos.x-50,_lordBgMidUpPos.y - 375),
	--     cc.p(_lordBgMidUpPos.x+425,_lordBgMidUpPos.y - 150),
	--     cc.p(_lordBgMidUpPos.x+425,_lordBgMidUpPos.y - 250),
	--     cc.p(_lordBgMidUpPos.x+425,_lordBgMidUpPos.y - 405),
		cc.p(_bg:getContentSize().width *0.5 + 70,_bg:getContentSize().height *0.5 + 90),
		cc.p(_bg:getContentSize().width *0.5 +70,_bg:getContentSize().height *0.5 - 80),
		cc.p(_bg:getContentSize().width *0.5 + 270,_bg:getContentSize().height *0.5 + 125),
		cc.p(_bg:getContentSize().width *0.5 +270,_bg:getContentSize().height *0.5 - 15 ),
		cc.p(_bg:getContentSize().width *0.5 +270,_bg:getContentSize().height *0.5 - 152),
		}

	for i=1,5 do
		local _lordBg = XTHD.createButton({
				normalFile = "res/image/guild/guildWar/guildWar_lordSpBg.png",
				selectedFile = "res/image/guild/guildWar/guildWar_lordSpBg.png",
				touchSize = cc.size(160,166),
				endCallback = function()
					self:selectedCallback(i)
				end
			})
			_lordBg:setScale(0.7)
		self.lordBgTable[i] = _lordBg
		local _heroBg = ccui.Scale9Sprite:create("res/image/plugin/hero/item_bg.png")
		_heroBg:setContentSize(90,90)
		_heroBg:setName("_heroBg")
		_heroBg:setPosition(cc.p(_lordBg:getContentSize().width/2,_lordBg:getContentSize().height/2+_heroBg:getContentSize().height/2+30))
		_lordBg:addChild(_heroBg)
		local _addBtn = cc.Sprite:create("res/image/guild/guildWar/guildWar_lordClickSp.png")
		_addBtn:setPosition(cc.p(_heroBg:getContentSize().width/2,_heroBg:getContentSize().height/2))
		_heroBg:addChild(_addBtn)
		local _nameBg = cc.Sprite:create("res/image/guild/guildWar/guildWar_lordNameBg.png")
		_nameBg:setName("nameBg")
		_nameBg:setAnchorPoint(cc.p(0.5,1))
		_nameBg:setPosition(cc.p(_lordBg:getContentSize().width/2,_lordBg:getContentSize().height/2+20))
		_lordBg:addChild(_nameBg)
		-- local _nameLabel = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.clickChooseLordTextXc,24,"res/fonts/round_body.ttf")
		local _nameLabel = XTHDLabel:createWithSystemFont(LANGUAGE_KEY_GUILDWAR_TEXT.clickChooseLordTextXc,XTHD.SystemFont,24)
		_nameLabel:setName("nameLabel")
		--_nameLabel:enableOutline(cc.c4b(0,0,0,255),1)
		_nameLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("zongse"))
		_nameLabel:setPosition(cc.p(_nameBg:getContentSize().width/2,_nameBg:getContentSize().height/2))
		_nameBg:addChild(_nameLabel)

		local _lordSp = cc.Sprite:create("res/image/guild/guildWar/guildWar_lordSign.png")
		_lordSp:setAnchorPoint(cc.p(0,0))
		_lordSp:setPosition(cc.p(-_lordSp:getContentSize().width/2,_heroBg:getContentSize().height-_lordSp:getContentSize().height/2))
		_heroBg:addChild(_lordSp,10)
		_lordBg:setPosition(_btnPos[i])
		_bg:addChild(_lordBg)
		-- HaoYouPublic.getFriendIcon({templateId == gameUser.getCampID(),level = gameUser.getLevel()}, {notShowCamp = true})
	end

	self:refreshLordHero()

	local _lordDesc = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.chooseLordDescTextXc,18)
	_lordDesc:setColor(BangPaiFengZhuangShuJu.getTextColor("hongse"))
	_lordDesc:setAnchorPoint(cc.p(0.5,0.5))
	_lordDesc:setPosition(cc.p(_bg:getContentSize().width/2,55))
	_bg:addChild(_lordDesc)

	XTHD.addEventListenerWithNode({name = "refreshGuildLordSp",node = self,callback = function(event)
        	self:notificateToRefresh(event.data)
        end})

end

function BangPaiZhanQueRenZhuJiang:selectedCallback(_idx)
	requires("src/fsgl/layer/BangPai/BangPaiZhanZhuJiang.lua"):create(self.lordListData,_idx)
end
function BangPaiZhanQueRenZhuJiang:notificateToRefresh(_data)
	self:setLordListData(_data)
	self:refreshLordHero()
end

function BangPaiZhanQueRenZhuJiang:refreshLordHero()
	for i=1,5 do
		if self.lordBgTable[i]~=nil then
			if self.lordBgTable[i]:getChildByName("_heroBg") then
				local _nameLabel = nil
				local _nameBg = self.lordBgTable[i]:getChildByName("nameBg")
				if _nameBg:getChildByName("nameLabel") then
					_nameLabel = _nameBg:getChildByName("nameLabel")
				else
					_nameLabel = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.clickChooseLordTextXc,20)
					_nameLabel:setName("nameLabel")
					_nameLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("zongse"))
					_nameLabel:setPosition(cc.p(_nameBg:getContentSize().width/2,_nameBg:getContentSize().height/2))
					_nameBg:addChild(_nameLabel)
				end
				local _heroBg = self.lordBgTable[i]:getChildByName("_heroBg")
				if self.lordListData[i]==nil or next(self.lordListData[i])==nil then
					if _heroBg:getChildByName("heroSp") then
						_heroBg:removeChildByName("heroSp")
					end
					_heroBg.charId = nil
					_nameLabel:setString(LANGUAGE_KEY_GUILDWAR_TEXT.clickChooseLordTextXc)
				else
					if _heroBg:getChildByName("heroSp") then
						local _oldCharId = tonumber(_heroBg.charId or 0)
						local _newCharId = tonumber(self.lordListData[i].charId or 0)
						if _oldCharId~=_newCharId then
							_heroBg:removeChildByName("heroSp")
							local _heroSp = HaoYouPublic.getFriendIcon({templateId = self.lordListData[i].template,level = self.lordListData[i].level}, {notShowCamp = true})
							_heroSp:setName("heroSp")
							_heroSp:setScale(1)
							_heroSp:setPosition(cc.p(_heroBg:getContentSize().width/2,_heroBg:getContentSize().height/2))
							_heroBg:addChild(_heroSp,5)
							_heroBg.charId = self.lordListData[i].charId
							_nameLabel:setString(self.lordListData[i].name or "")
						end
					else
						local _heroSp = HaoYouPublic.getFriendIcon({templateId = self.lordListData[i].template,level = self.lordListData[i].level}, {notShowCamp = true})
						_heroSp:setName("heroSp")
						_heroSp:setScale(1)
						_heroSp:setPosition(cc.p(_heroBg:getContentSize().width/2,_heroBg:getContentSize().height/2))
						_heroBg:addChild(_heroSp,5)
						_nameLabel:setString(self.lordListData[i].name or "")
						_heroBg.charId = self.lordListData[i].charId
					end
				end
				
			end
		end
	end
end

function BangPaiZhanQueRenZhuJiang:setLordListData(data)
	self.lordListData = {}
	self.lordListData = data and data.list or {}
end

function BangPaiZhanQueRenZhuJiang:create(data)
	local _layer = self.new(data)
	return _layer
end

return BangPaiZhanQueRenZhuJiang