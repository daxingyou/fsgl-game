--Created By Liuluyang 2015年07月29日
--留言
local JingJiCompetitiveMsgPop = class("JingJiCompetitiveMsgPop",function ()
	return XTHD.createPopLayer()
end)


function JingJiCompetitiveMsgPop:ctor(reportId,callfunc)
	self:initUI(reportId,callfunc)
end

function JingJiCompetitiveMsgPop:onCleanup()
end

function JingJiCompetitiveMsgPop:initUI(reportId,callfunc)
	local bg =  ccui.Scale9Sprite:create(cc.rect(0,0,0,0), "res/image/tmpbattle/battle_data_bg.png" )
    bg:setContentSize(505,366)
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)

	local bgTitle = cc.Sprite:create("res/image/plugin/saint_beast/pop_title.png")
	bgTitle:setAnchorPoint(0.5,0)
	bgTitle:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-35)
	bg:addChild(bgTitle)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_TIPS_WORDS26,-------"选择留言",
		fontSize = 32,
		color = cc.c3b(106,36,13)
	})
	titleLabel:setPosition(bgTitle:getBoundingBox().width/2,bgTitle:getBoundingBox().height/2)
	bgTitle:addChild(titleLabel)

	local MsgData = gameData.getDataFromCSV("PlunderMessage",{challengeStatus = 1})

	for i=1,5 do
		local bgNormal = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
		bgNormal:setContentSize(cc.size(468,62))
		local bgSelected = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
		bgSelected:setContentSize(cc.size(468,62))
		local cell_bg = XTHDPushButton:createWithParams({
			normalNode = bgNormal,
			selectedNode = bgSelected,
		})
		cell_bg:setPosition(bg:getBoundingBox().width/2,XTHD.resource.getPosInArr({
			lenth = 5,
			bgWidth = bg:getBoundingBox().height,
			num = 5,
			nodeWidth = cell_bg:getBoundingBox().height,
			now = i,
		}))
		bg:addChild(cell_bg)
		cell_bg:setTouchEndedCallback(function()
			XTHDHttp:requestAsyncInGameWithParams({
				modules="leaveMessage?",
		        params = {reportId=reportId,messageId=MsgData[i].id},
		        successCallback = function(data)
			        if tonumber(data.result) == 0 then
			        	XTHDTOAST(LANGUAGE_TIPS_WORDS27)------"留言成功")
			        	if callfunc then
			        		callfunc()
			        	end
			        	self:hide()
			        else
			        	XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)------"网络请求失败!")
			        end
		        end,--成功回调
		        failedCallback = function()
		            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
		        end,--失败回调
		        targetNeedsToRetain = self,--需要保存引用的目标
		        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		    })
		end)

		local msg = XTHDLabel:createWithParams({
			text = MsgData[i].msg,
			fontSize = 18,
			color = XTHD.resource.color.brown_desc
		})
		msg:setPosition(cell_bg:getBoundingBox().width/2,cell_bg:getBoundingBox().height/2)
		cell_bg:addChild(msg)
	end
end

function JingJiCompetitiveMsgPop:create(reportId,callfunc)
	return JingJiCompetitiveMsgPop.new(reportId,callfunc)
end

return JingJiCompetitiveMsgPop