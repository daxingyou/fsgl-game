--[[
点击我方种族城市的时候显示按钮
]]
local ZhongZuBuildDialog = class("ZhongZuBuildDialog",function( )
	return ccui.Scale9Sprite:create("res/image/camp/map/build_di.png")
end)

function ZhongZuBuildDialog:ctor(cityID,parent,defendSum)
	self.__cityID = cityID
	self.__parent = parent
	self._defendSum = defendSum or 0
end

function ZhongZuBuildDialog:create(cityID,parent,defendSum)
	local dialog = self.new(cityID,parent,defendSum)
	if dialog then 
		dialog:init()
		dialog:registerScriptHandler(function(_event)
			if _event == "enter" then 
				dialog:onEnter()
			elseif _event == "exit" then
				dialog:onExit()
			end 
		end)
	end 
	return dialog
end

function ZhongZuBuildDialog:init( )	
	-- self:setContentSize(cc.size(110,100))
	self:setContentSize(cc.size(140,220))
	----按钮
	local y = self:getBoundingBox().height - 15
	for i = 1,4 do 
	-- for i = 1,2 do 
		local button = XTHD.createPushButtonWithSound({
			normalFile = "res/image/camp/map/btn_gray_up.png",
			selectedFile = "res/image/camp/map/btn_gray_down.png",
		},3)
		self:addChild(button)
		button:setTag(i)
		button:setTouchEndedCallback(function( )
			self:doButtonClicked(button:getTag())
		end)
		----字
		local word = XTHDLabel:createWithSystemFont(LANGUAGE_CAMP_BUILDBTNWORDS[i],XTHD.SystemFont,22)
		word:setColor(cc.c3b(255,255,255))
		word:enableShadow(cc.c4b(160,76,43,0xff),cc.size(1,0))
		button:addChild(word)
		word:setPosition(button:getContentSize().width / 2,button:getContentSize().height / 2)

		button:setPosition(self:getBoundingBox().width / 2,y - button:getContentSize().height / 2)
		y = button:getPositionY() - button:getContentSize().height / 2
	end 
end

function ZhongZuBuildDialog:onEnter( )
end

function ZhongZuBuildDialog:onExit(  )	
end

function ZhongZuBuildDialog:doButtonClicked( _tag )
	local layer = nil
	if _tag == 1 then ----信息
		requires("src/fsgl/layer/ZhongZu/ZhongZuCityInfoLayer.lua"):create(self.__cityID,self.__parent,self._defendSum)
	elseif _tag == 2 then ----编队
		if ZhongZuDatas:isCampWarStart() == true then ----种族战已开启
			XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS35)
			return 
		end 
		if #ZhongZuDatas._serverSelfDefendTeam.teams < 1 then ----未设置防守队伍            
			XTHDTOAST(LANGUAGE_CAMP_TIPSWORDS28)-----("你还没有设置防守队伍，请点击右下角的”队伍调整“")
			return 
		end 
		layer = requires("src/fsgl/layer/ZhongZu/ReassignTeamLayer1.lua"):create(self.__cityID,self.__parent)
		if layer and self.__parent then
			self.__parent:addChild(layer,3)
		end 
	elseif _tag == 3 then  ----城主
		requires("src/fsgl/layer/ZhongZu/forTheHost/ZhongZuCastellenInfo.lua"):create(self.__cityID,self.__parent)
	elseif _tag == 4 then  ----捐献
		requires("src/fsgl/layer/ZhongZu/forTheHost/ZhongZuCityDonate.lua"):create(self.__cityID,self.__parent)
	end 
	self:removeFromParent()
end

function ZhongZuBuildDialog:setCityID( id )
	self.__cityID = id
end

return ZhongZuBuildDialog