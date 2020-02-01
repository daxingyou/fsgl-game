requires("src/fsgl/layer/YinDaoJieMian/YinDaoScript.lua")

YinDaoScriptLayer = class( "YinDaoScriptLayer", function ( params )
	return XTHDDialog:create()
end)

function YinDaoScriptLayer:ctor(params)
	local _opacity = 70
	if params.opacity then 
		_opacity = params.opacity
	end 
	local _playerId = params.playerId or 1
	local _playerInfo = gameData.getDataFromCSV("GeneralInfoList", {heroid = _playerId})
	local storyId 	= params.storyId
	local callback 	= params.callback
	local auto 		= params.auto
	local storyData = YinDaoScript[tostring(storyId)]--gameData.getDataFromCSV("YinDaoScript", {["iplotid"]=storyId})
	-- dump(storyData)
	self:setOpacity(_opacity)
	--[[--默认开启自动]]
	if auto == nil then
		auto = true
	end

	self.lastSpineId = "001"
	local skeletonNode = SpineAnimal:createWithParams({resourceId = 1}) --sp.SkeletonAnimation:create("res/spine/" .. self.lastSpineId .. ".json", "res/spine/" .. self.lastSpineId .. ".atlas", 1.0)
	skeletonNode:setScale(0.8)
	-- skeletonNode:setAnimation(0,"idle",true)
	
	local _tmp = XTHD.createSprite("res/image/story/story_txt_bg.png")
	local txtBG = ccui.Scale9Sprite:create("res/image/story/story_txt_bg.png")
	txtBG:setContentSize(cc.size(self:getContentSize().width,_tmp:getBoundingBox().height))
	txtBG:setPosition( cc.p(winWidth*0.5,txtBG:getContentSize().height / 2) )
	self:addChild(txtBG)
	txtBG:setCascadeOpacityEnabled(true)
	self:addChild(skeletonNode)
	self.skeletonNode = skeletonNode

	-- 对话背景框的size
	local txtBGSize = txtBG:getBoundingBox()

	local namebg = XTHDPushButton:createWithParams({
		normalNode = cc.Sprite:create("res/image/story/storyboard_namebg.png"),
		label = XTHD.createLabel({fontSize = 22,text = "",color=cc.c3b(98,0,0)}),
		})
	namebg:setClickable(false)
	namebg:setPosition(cc.p(namebg:getBoundingBox().width/2 + 50, 142))
	txtBG:addChild(namebg)
	namebg:setVisible(false)
	-- 向下的箭头
	local arrow = cc.Sprite:create("res/image/story/guide_down_arrow.png")
	arrow:setPosition( cc.p(txtBGSize.width*0.92,txtBGSize.height*0.4) )
	local moveBy = cc.MoveBy:create(1.0, cc.p(0, 10))
	local seqAction = cc.Sequence:create(moveBy, moveBy:reverse())
	local repeatAction = cc.RepeatForever:create(seqAction)
	arrow:runAction( repeatAction )
	txtBG:addChild(arrow);
	--箭头取消了 先设为不可见
	arrow:setVisible(false)


	local labTxt =  XTHD.createRichLabel({}) 
	labTxt:setDimensions(cc.size(600,90))
	labTxt:setAnchorPoint(0,0)
	labTxt:setPosition(38,10)
	labTxt:setFontSize(22)
	labTxt:setFontFillColor(cc.c3b(70, 34, 34))
	labTxt:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	labTxt:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
	-- local labTxt =  RichLabel:createARichText("",false,600,nil,{fontSize = 22,color = XTHD.resource.color.gray_desc})
	-- labTxt:setAnchorPoint(0,0)
	-- labTxt:setPosition(38,_tmp:getBoundingBox().height - 25)

	txtBG:addChild( labTxt )

	local timeTxt = XTHD.createLabel({fontSize = 22,text = "",color=cc.c3b(0,0,0)})
	timeTxt:setPosition(txtBG:getContentSize().width - 50,30)
	timeTxt:setOpacity(0)
	txtBG:addChild( timeTxt )
	timeTxt:setVisible(false)

	local stories = {}
	if storyData then
		for i=1,10 do
			if storyData["words"..i] ~= nil then
				local word = storyData["words"..i]
				local words = string.split(word,"|")
				stories[#stories + 1] = words
			end
		end--for end
	end
	
	local function showTxt()
		--[[每次取第一条]]
		if self._soundEffId then
			musicManager.stopEffect(self._soundEffId)
			self._soundEffId = nil
		end 
		for i=1,#stories do
			local story 		= stories[i]
			local text 			= story[#story]
			local name 			= story[1]
			local resourceid 	= story[2]
			local side 			= story[3]
			local y 			= story[4]
			local scale 		= story[5]
			local spineAct 		= story[6]
			local isActRepeat	= story[7] --1循环 其他为不循环
			local talkId		= story[8] --1循环 其他为不循环
			-- local isActStay		= story[8] --播完动画后是否停在当前动画最后一帧
			if tonumber(name) == -1 then
				name = _playerInfo.name
			end
			namebg:setText(name)
			namebg:setLabelColor(cc.c3b(98,0,0))
			if tonumber(resourceid) == -1 then
				resourceid = _playerInfo.heroid
			end
			local spineID =  string.format("%03d",resourceid)
			--[[如果人物没变，就不需要重新创建]]
			if spineID ~= self.lastSpineId then
				self.lastSpineId = spineID
				skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
				skeletonNode:removeFromParent()
				skeletonNode = SpineAnimal:createWithParams({resourceId = self.lastSpineId})
				self:addChild(skeletonNode)
			end
			if skeletonNode:isExistAnimation(spineAct) == true then
				--如果该英雄有此动作，则播放此动作。如果没有则播放待机
				-- skeletonNode:playAnimation(spineAct,tonumber(isActRepeat) == 1 and true or false)
				-- if tonumber(isActRepeat) ~= 1 then
				-- 	skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
				-- 	skeletonNode:registerSpineEventHandler(function (event)
				-- 		--如果不需要重复播放，则在播放一次之后播放待机
				-- 		if event.animation == spineAct then
				--         end
				-- 	end, sp.EventType.ANIMATION_COMPLETE)
				-- end
			else
				-- skeletonNode:playAnimation("idle",true)
			end
			self.skeletonNode = skeletonNode
			skeletonNode:setScale(scale)
			namebg:setPosition(cc.p(namebg:getBoundingBox().width/2 + 20, txtBG:getBoundingBox().height))
			skeletonNode:setPosition(cc.p(namebg:getPositionX(),y  ))
			--[[如果是右边]]
			if tonumber(side) == 2 then
				labTxt:setDimensions(cc.size(700,90))
				labTxt:setPosition(38,10)
				-- labTxt:setPositionX(38)
				--翻转，注意用法，x轴变成负数
				skeletonNode:setScaleX(-1.0 * math.abs(skeletonNode:getScaleX()))
				namebg:setPosition(cc.p(txtBGSize.width - namebg:getBoundingBox().width/2 - 20, txtBG:getBoundingBox().height))
				skeletonNode:setPosition(cc.p(namebg:getPositionX(),y ))
			else
				labTxt:setDimensions(cc.size(600,90))
				labTxt:setPosition(250,10)
				-- labTxt:setPositionX(250)
			end
			table.remove(stories,i)
			labTxt:setString("")
			labTxt:runAction(cc.Sequence:create(
				cc.FadeOut:create(0.2), 
				cc.CallFunc:create(function() 
					labTxt:setString(text)
--					labTxt:startLoopDisplay(0.05, 0, 0, cc.CallFunc:create(function() 
--						labTxt._isPlaying = false
--					end))
--					labTxt._isPlaying = true
					-- XTHD.playLabelActionByRich(labTxt, text, 0.05)
				end),
				cc.FadeIn:create(0.5)))

			if talkId ~= "0" then
				local _name = "res/sound/guide/guide_talk_" .. talkId .. ".mp3"
				-- self._soundEffId = musicManager.playEffect(_name)
			end
			break
		end
	end
	local strs = {}
	strs[#strs + 1] = "①"
	strs[#strs + 1] = "②"
	strs[#strs + 1] = "③"
	strs[#strs + 1] = "④"
	strs[#strs + 1] = "⑤"
	
	local TIME = 10
	local _time_ = TIME
	local touchCallback = nil
	touchCallback = function( ... )
		_time_ = TIME
		if #stories > 0 then
			showTxt()
			if auto == true then
				timeTxt:setVisible(false)
				timeTxt:stopAllActions()
				schedule(timeTxt, function() 
					_time_ = _time_ - 1
			        if _time_ < 1 then
			        	touchCallback()
			        end
			        if strs[_time_] then
			       		timeTxt:setString(tostring(strs[_time_]))
			        end
			        if _time_ < 6 then
			        	timeTxt:setVisible(true)
			        else
			        	timeTxt:setVisible(false)
			        end
			    end, 2.0,1)
			    
			    timeTxt:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(0))))
			end
		else
			self.skeletonNode:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
			if callback then
				callback()
			end
			self:removeFromParent()
		end
	end
	touchCallback()
	self:setTouchEndedCallback(function() 
		musicManager.playEffect(XTHD.resource.music.effect_btn_common,false)
		if labTxt._isPlaying == true then
			-- labTxt:stopAllActions()
			-- labTxt:setOpacity(255)
			--labTxt:stopLoopDisplay()
			-- labTxt:setString(labTxt._showInfo)
			--labTxt._isPlaying = false
			return
		end
		touchCallback()
	end)
	txtBG:setPosition(cc.p(winWidth*0.5,-txtBG:getContentSize().height / 2 - 50))
	local scaleX = txtBG:getScaleX()
	txtBG:runAction(cc.Sequence:create( cc.MoveTo:create(0.1,cc.p(winWidth*0.5,txtBG:getContentSize().height / 2)) , cc.ScaleTo:create(0.1,scaleX,1.1), cc.ScaleTo:create(0.1,scaleX,1.0)  ))
end

function YinDaoScriptLayer:createWithParams(params)
	return YinDaoScriptLayer.new(params)
end
