--Created By Liuluyang 2015年07月10日
local JingJiCompetitiveRewardPop = class("JingJiCompetitiveRewardPop",function ()
	return XTHD.createPopLayer()
end)

function JingJiCompetitiveRewardPop:ctor(data)
	self:initUI(data)
end

function JingJiCompetitiveRewardPop:initUI(data)
	self.data = data
	local Bg = ccui.Scale9Sprite:create(cc.rect(0,0,0,0),"res/image/common/scale9_bg1_34.png")
	Bg:setContentSize(cc.size(650,453))
	Bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(Bg)

    -- local titleBg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 34))
    local titleBg = cc.Sprite:create("res/image/login/zhanghaodenglu.png")
	titleBg:setAnchorPoint(0.5,1)
	titleBg:setPosition(Bg:getBoundingBox().width/2,Bg:getBoundingBox().height+30)
	Bg:addChild(titleBg)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_TIP_CONTINUE_WIN_REWARD,------- LANGUAGE_KEY_CONTINUEREWARD,--------"连胜奖励",
        fontSize = 32 ,
        color = cc.c3b(106,36,13)
	})
	titleLabel:setPosition(titleBg:getBoundingBox().width/2,titleBg:getBoundingBox().height/2)
	titleBg:addChild(titleLabel)

	self.arenaData = gameData.getDataFromCSV("WinningStreak")

	self._rewardTable = CCTableView:create(cc.size(620,370))
    TableViewPlug.init(self._rewardTable)
    self._rewardTable:setPosition((Bg:getBoundingBox().width-620)/2, 40)
    self._rewardTable:setBounceable(true)
    self._rewardTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._rewardTable:setDelegate()
    self._rewardTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    Bg:addChild(self._rewardTable)

    local function cellSizeForTable(table,idx)
        return 620,112
    end

    local function numberOfCellsInTableView(table)
        return #self.data.list
    end

    local function tableCellTouched(table,cell)
    end

    local function tableCellAtIndex(table1,idx)
        local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(cc.size(620,112))
        else
            cell:removeAllChildren()
        end

        local cell_bg = ccui.Scale9Sprite:create(cc.rect(0,0,0,0),"res/image/common/scale9_bg1_26.png")
        cell_bg:setContentSize(619,111)
        cell_bg:setAnchorPoint(0,0)
        cell:addChild(cell_bg)

        local nowData = self.arenaData[idx+1]
        local httpData = self.data.list[idx+1]

        local descLabel1 = XTHDLabel:createWithParams({           --连胜xx次可获得:  英文版语序不一样需要修改
        	text = LANGUAGE_NAMES.continueWin,------"连胜",
	        fontSize = 16,
	        color = XTHD.resource.color.gray_desc
        })
        descLabel1:setAnchorPoint(0,0.5)
        descLabel1:setPosition(15,cell_bg:getBoundingBox().height/2)
        cell_bg:addChild(descLabel1)

        local descLabelNum = XTHDLabel:createWithParams({
        	text = nowData.needwin,
	        fontSize = 16,
	        color = XTHD.resource.color.red_desc
        })
        descLabelNum:setAnchorPoint(0,0.5)
        descLabelNum:setPosition(descLabel1:getPositionX()+descLabel1:getBoundingBox().width,descLabel1:getPositionY())
        cell_bg:addChild(descLabelNum)

        local descLabel2 = XTHDLabel:createWithParams({
        	text = LANGUAGE_KEY_TIMES..LANGUAGE_VERBS.canGet,------"次可获得:",
	        fontSize = 16,
	        color = XTHD.resource.color.gray_desc
        })
        descLabel2:setAnchorPoint(0,0.5)
        descLabel2:setPosition(descLabelNum:getPositionX()+descLabelNum:getBoundingBox().width,descLabelNum:getPositionY())
        cell_bg:addChild(descLabel2)

        local rewardParams = string.split(nowData.reward,"#")

        local showRewardList = {}

        for i=1,#rewardParams do
            local _tb = string.split(rewardParams[i],",")
        	local itemIcon = ItemNode:createWithParams({
        		_type_ = 4,
        		itemId = _tb[1],
        		count = _tb[2],
        	})
        	itemIcon:setScale(0.75)
        	itemIcon:setAnchorPoint(0,0.5)
        	itemIcon:setPosition(150+(i-1)*(itemIcon:getBoundingBox().width+10),cell_bg:getBoundingBox().height/2)
        	cell_bg:addChild(itemIcon)

        	local tmpList = {
        		rewardtype = 4,
        		id = _tb[1],
        		num = _tb[2]
	        }
	        showRewardList[#showRewardList+1] = tmpList
        end

		local _isvisible = false
        local btnText = LANGUAGE_BTN_KEY.getReward
        local btnColor = "write_1"
        if httpData.state == 0 then
            btnColor = "write_1"
            btnText = LANGUAGE_BTN_KEY.getReward
			_isvisible = true
		elseif httpData.state == 1 then
            btnColor = "write_1"
            btnText = LANGUAGE_BTN_KEY.getReward
			_isvisible = true
		elseif httpData.state == -1 then
            btnColor = "write"
            btnText = LANGUAGE_BTN_KEY.noAchieve
			_isvisible = false
		end
        local get_sp=cc.Sprite:create("res/image/camp/camp_reward_getted.png")
        get_sp:setAnchorPoint(0.5,0.5)  
        get_sp:setPosition(cell_bg:getBoundingBox().width-70,cell_bg:getBoundingBox().height/2)
        cell_bg:addChild(get_sp)
        get_sp:setScale(0.6)
        get_sp:setVisible(false)
        local getBtn = XTHD.createCommonButton({
                btnColor = btnColor,
                text = btnText,
                isScrollView = true,
                btnSize = cc.size(102,46),
                fontSize = 22,
            })
        getBtn:setScale(0.6)
        getBtn:setAnchorPoint(0.5,0.5)
        getBtn:setPosition(cell_bg:getBoundingBox().width-70,cell_bg:getBoundingBox().height/2)
        cell_bg:addChild(getBtn)

		local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		getBtn:addChild(fetchSpine)
		fetchSpine:setPosition(getBtn:getBoundingBox().width - 14, getBtn:getContentSize().height*0.5+2)
		fetchSpine:setAnimation(0, "querenjinjie", true )	
		fetchSpine:setVisible(_isvisible)

        if self.data.list[idx+1].state == 1 then
            getBtn:setVisible(false)
            get_sp:setVisible(true)
        end
        getBtn:setTouchEndedCallback(function ()
            if self.data.list[idx+1].state == 1 then
                XTHDTOAST(LANGUAGE_KEY_GETTED)-------"你已经领取了这个奖励")
                getBtn:setVisible(false)
                return
            end
        	if self.data.maxVictory < nowData.needwin then
                XTHDTOAST(LANGUAGE_FORMAT_TIPS5(nowData.needwin-self.data.maxVictory))-------"还需连胜"..nowData.needwin-self.data.maxVictory.."次才可领奖")
                return
            end
            XTHDHttp:requestAsyncInGameWithParams({
                modules = "getReward?",
                params = {rewardId=nowData.id},
                successCallback = function(finishTask)
                    if tonumber(finishTask.result) == 0 then
                        -- XTHDTOAST("11111")
                        self.data.list[idx+1].state = 1
                        XTHD.saveItem({items = finishTask.items})
                        ShowRewardNode:create(showRewardList)
                        self._rewardTable:reloadDataAndScrollToCurrentCell()
                        -- self:getParent().rewardRedDot:setVisible(false)
                        -- for i=1,#self.data.list do
                        --     if self.data.list[i].state == 0 then
                        --         self:getParent().rewardRedDot:setVisible(true)
                        --     end
                        -- end
                    else
                        XTHDTOAST(finishTask.msg or LANGUAGE_TIPS_WEBERROR)--------"网络请求失败!")
                    end
                end,--成功回调
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
                targetNeedsToRetain = self,--需要保存引用的目标
                loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
            })
        end)

        local statusNum = XTHDLabel:createWithParams({
        	text = self.data.maxVictory.."/"..nowData.needwin,
	        fontSize = 16,
	        color = tonumber(self.data.maxVictory) >= tonumber(nowData.needwin) and XTHD.resource.color.gray_desc or XTHD.resource.color.red_desc
        })
        statusNum:setAnchorPoint(1,0.5)
        statusNum:setPosition(getBtn:getPositionX()-70,cell_bg:getBoundingBox().height/2)
        cell_bg:addChild(statusNum)

        return cell
    end

    self._rewardTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._rewardTable.getCellNumbers=numberOfCellsInTableView
    self._rewardTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._rewardTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._rewardTable.getCellSize=cellSizeForTable
    self._rewardTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._rewardTable:reloadData()
end

function JingJiCompetitiveRewardPop:create(data)
	return JingJiCompetitiveRewardPop.new(data)
end

return JingJiCompetitiveRewardPop