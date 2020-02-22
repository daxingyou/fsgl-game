--Created By Liuluyang 2015年06月13日
local ShowPopJiBanInfo = class("ShowPopJiBanInfo",function ()
	return XTHD.createPopLayer()
end)

function ShowPopJiBanInfo:ctor(index)
	self._JiBanData = gameData.getDataFromCSV("Fetters",{ id = index })
	self:initUI(index)
end

function ShowPopJiBanInfo:initUI(index)
	local layer = cc.LayerColor:create(cc.c4b(0,0,0, 0))
	layer:setContentSize(self:getContentSize())
	self:addChild(layer,-1)
	layer:setOpacity(100)
	-- local bg = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_2.png")
	local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg3_34.png")
	bg:setName("bg")
	bg:setContentSize(cc.size(357,510))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2 - 10)
	self:addContent(bg)
	--框
	local kuang = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
	kuang:setContentSize(cc.size(342,490))
	kuang:setPosition(bg:getContentSize().width/2 - 2,13)
	kuang:setAnchorPoint(0.5,0)
	bg:addChild(kuang)
	
	--标题
	local BiaoTi = cc.Sprite:create("res/image/jiban/jbname"..index..".png")
	bg:addChild(BiaoTi)
	BiaoTi:setPosition(bg:getContentSize().width / 2,bg:getContentSize().height - 5)

	local lable = XTHDLabel:createWithParams({
				text = self._JiBanData.describe ,
				fontSize = 15,
				color = cc.c3b(50,50,50),
	})
	lable:setAnchorPoint(cc.p(0,1))
	lable:setDimensions(bg:getContentSize().width - 30,0)
	bg:addChild(lable)
	lable:setPosition(20,BiaoTi:getPositionY() - 20)

	local heroList = string.split(self._JiBanData.needID,"#")
	for i = 1, #heroList do
		local heroNode = HeroNode:createWithParams({
							heroid = heroList[i],
							level = -1,
							star = -1,
						})
		bg:addChild(heroNode)
		
		local y = 0
		
		if #heroList < 5 then
			y = bg:getContentSize().height -lable:getContentSize().height - 80 - (i-1)*heroNode:getContentSize().height*0.7 
		else
			y = bg:getContentSize().height -lable:getContentSize().height - 120 - (i-2)*heroNode:getContentSize().height*0.6 - 10
		end	

		heroNode:setPosition(heroNode:getContentSize().width /2,y)
		heroNode:setScale(0.55)
		
		local heroData = gameData.getDataFromCSV("GeneralShow",{ heroid = heroList[i] })
		local herolabel = XTHDLabel:createWithParams({
				text = heroData.herodescription ,
				fontSize = 22,
				color = cc.c3b(50,50,50),
		})
		herolabel:setDimensions(bg:getContentSize().width + 60,0)
		heroNode:addChild(herolabel)
		herolabel:setAnchorPoint(cc.p(0,0.5))		
		herolabel:setPosition(heroNode:getContentSize().width / 2 + 60 ,heroNode:getContentSize().height / 2)
	
	end

end

function ShowPopJiBanInfo:create(index)
	return ShowPopJiBanInfo.new(index)
end

return ShowPopJiBanInfo