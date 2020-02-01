--Created By Liuluyang 2015年08月07日
local ShenQiSelectPop = class("ShenQiSelectPop",function (sParams)
	return XTHD.createPopLayer(sParams)
end)

function ShenQiSelectPop:ctor( )
    self._extraCall = nil -----需要在礼品装备里执行的
    self._selectedData = nil -----被选中的数据
end

function ShenQiSelectPop:initUI(heroId,refreshNode,callback)
    self._parent = refreshNode
     self._heroID = heroId
    -- local bg = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_2.png")
    local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	bg:setContentSize(cc.size(802,470))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)

    local titleSp = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,50))
	titleSp:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-20)
	bg:addChild(titleSp)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_HERO_TEXT.ownedArtifact,--- "拥有神器",
		fontSize = 26,
        color = cc.c3b(106,36,13),
        ttf = "res/fonts/def.ttf"
	})
	titleLabel:setPosition(titleSp:getBoundingBox().width/2,titleSp:getBoundingBox().height/2+5)
	titleSp:addChild(titleLabel)

	self.artifactData = gameData.getDataFromCSV("SuperWeaponUpInfo")

	-- local exchangeBtn = XTHD.createCommonButton({
    --     btnColor = "write_1",
    --     btnSize = cc.size(130,49),
    --     needSwallow = false,
    --     text = LANGUAGE_BTN_KEY.qianwangduihuan,
    --     fontSize = 22,
    --     needEnableWhenMoving = true,
    --     endCallback = function ()
    --      	XTHD.createSaintBeastChange(cc.Director:getInstance():getRunningScene(),function ()
    --             self:refreshData()
    --         end)
    --     end
    -- })
    -- exchangeBtn:setScale(0.8)
    -- exchangeBtn:setPosition(250,45)
    -- bg:addChild(exchangeBtn)

    -- local wearBtn = nil
    -- if heroId then 
    --     wearBtn = XTHD.createCommonButton({
    --         btnColor = "write",
    --         btnSize = cc.size(130,49),
    --         text = LANGUAGE_BTN_KEY.equipNow,
    --         fontSize = 22,
    --         needSwallow = false,
    --         needEnableWhenMoving = true,
    --         musicFile="res/sound/EquipOn.mp3",
    --         endCallback = function ()
    --             -- print("%%%%%%:" .. self._ArtifactTable.selectId )
    --             -----引导
    --             YinDaoMarg:getInstance():guideTouchEnd() 
    --             --------------------------------------------------
    --          	XTHDHttp:requestAsyncInGameWithParams({
    --                 modules="petDeployGod?",
    --                 params = {petId=heroId,godId=self._ArtifactTable.selectId},
    --                 successCallback = function(Deploy)
    --                 if tonumber(Deploy.result) == 0 then
    --                     YinDaoMarg:getInstance():doNextGuide()
    --                 	for i=1,#Deploy.petProperty do
    --                         DBTableHero.multiUpdate(gameUser.getUserId(),Deploy.petProperty[i].petId,Deploy.petProperty[i].property)
    --                 	end
    --                 	for i=1,#Deploy.godProperty do
    --                         local nowGod = Deploy.godProperty[i]
    --                         local tmpList = {}
    --                         for k,v in pairs(nowGod.property) do
    --                             tmpList[XTHD.resource.AttributesName[tonumber(k)]] = v
    --                         end
    --                         DBTableArtifact.multiUpdate(nowGod.godId,tmpList)
    --                 	end
    --                 	DBTableArtifact.DeleteOldArtifact(gameUser.getUserId(),heroId)
    --                 	DBTableArtifact.UpdateAtfData(gameUser.getUserId(),self._ArtifactTable.selectId, "petId", heroId)
    --                     if self._callback then
    --                         self._callback(self._ArtifactTable.selectId)
    --                     end
    --                     if refreshNode and refreshNode.reFreshLeftLayer then
    --                         refreshNode:reFreshLeftLayer()
    --                     end
    --                     if callback then
    --                         callback(self._ArtifactTable.selectId)
    --                     else
    --                         XTHD.createArtifact(heroId,nil,nil,self._extraCall)
    --                     end
    --                     self:hide()
    --                 else
    --                     YinDaoMarg:getInstance():tryReguide()
    --                     XTHDTOAST(Deploy.msg)
    --                 end
    --                 end,--成功回调
    --                 failedCallback = function()
    --                     YinDaoMarg:getInstance():tryReguide()
    --                     XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
    --                 end,--失败回调
    --                 targetNeedsToRetain = self,--需要保存引用的目标
    --                 loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    --             })
    --          end
    --     })
    -- else
    --     wearBtn = XTHD.createCommonButton({
    --         text = LANGUAGE_KEY_SURE,
    --         btnSize = cc.size(130, 51),
    --         fontSize = 22,
    --         needSwallow = false,
    --         needEnableWhenMoving = true,
    --         musicFile="res/sound/EquipOn.mp3",
    --         endCallback = function( )
    --             XTHD.createArtifact(nil,nil,self._ArtifactTable.selectId,function( )
    --                 self:refreshData()
    --             end)
    --         end
    --     })
    -- end 
    -- wearBtn:setScale(0.8)
    -- wearBtn:setPosition(bg:getBoundingBox().width-250,45)
    -- bg:addChild(wearBtn)
    -- self._wearBtn = wearBtn
    -- 802
    -- 470
    self._ArtifactTable = cc.TableView:create(cc.size(780,340))
	TableViewPlug.init(self._ArtifactTable)
	self._ArtifactTable:setPosition((bg:getBoundingBox().width-self._ArtifactTable:getBoundingBox().width)/2 +1, 80)
    self._ArtifactTable:setBounceable(true)
    self._ArtifactTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._ArtifactTable:setDelegate()
    self._ArtifactTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    bg:addChild(self._ArtifactTable)

    local exchangeBtn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(130,49),
        isScrollView = false,
        needSwallow = false,
        text = LANGUAGE_BTN_KEY.qianwangduihuan,
        fontSize = 22,
        needEnableWhenMoving = true,
        endCallback = function ()
         	XTHD.createSaintBeastChange(cc.Director:getInstance():getRunningScene(),function ()
                self:refreshData()
            end)
        end
    })
    exchangeBtn:setScale(0.8)
    exchangeBtn:setPosition(250,50)
    bg:addChild(exchangeBtn)

    local wearBtn = nil
    if heroId then 
		local heroData = DBTableHero.getDataByID( heroId )
		self._oldFightValue = heroData.power
        wearBtn = XTHD.createCommonButton({
            btnColor = "write",
            btnSize = cc.size(130,49),
            isScrollView = false,
            text = LANGUAGE_BTN_KEY.equipNow,
            fontSize = 22,
            needSwallow = false,
            needEnableWhenMoving = true,
            musicFile="res/sound/EquipOn.mp3",
            endCallback = function ()
                -- print("%%%%%%:" .. self._ArtifactTable.selectId )
                -----引导
                YinDaoMarg:getInstance():guideTouchEnd() 
                --------------------------------------------------
             	XTHDHttp:requestAsyncInGameWithParams({
                    modules="petDeployGod?",
                    params = {petId=heroId,godId=self._ArtifactTable.selectId},
                    successCallback = function(Deploy)
                    if tonumber(Deploy.result) == 0 then
                        YinDaoMarg:getInstance():doNextGuide()
                    	for i=1,#Deploy.petProperty do
                            DBTableHero.multiUpdate(gameUser.getUserId(),Deploy.petProperty[i].petId,Deploy.petProperty[i].property)
                    	end
                    	for i=1,#Deploy.godProperty do
                            local nowGod = Deploy.godProperty[i]
                            local tmpList = {}
                            for k,v in pairs(nowGod.property) do
                                tmpList[XTHD.resource.AttributesName[tonumber(k)]] = v
                            end
                            DBTableArtifact.multiUpdate(nowGod.godId,tmpList)
                    	end
                    	DBTableArtifact.DeleteOldArtifact(gameUser.getUserId(),heroId)
                    	DBTableArtifact.UpdateAtfData(gameUser.getUserId(),self._ArtifactTable.selectId, "petId", heroId)
                        if self._callback then
                            self._callback(self._ArtifactTable.selectId)
                        end
                        if refreshNode and refreshNode.reFreshLeftLayer then
                            refreshNode:reFreshLeftLayer()
                        end
                        if callback then
                            callback(self._ArtifactTable.selectId)
                        else
                            XTHD.createArtifact(heroId,nil,nil,self._extraCall)
                        end
                        self:hide()
						local heroData = DBTableHero.getDataByID( heroId )
						self._newFightValue = heroData.power
						XTHD._createFightLabelToast({
							oldFightValue = self._oldFightValue,
							newFightValue = self._newFightValue
						})
                    else
                        YinDaoMarg:getInstance():tryReguide()
                        XTHDTOAST(Deploy.msg)
                    end
                    end,--成功回调
                    failedCallback = function()
                        YinDaoMarg:getInstance():tryReguide()
                        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
                    end,--失败回调
                    targetNeedsToRetain = self,--需要保存引用的目标
                    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                })
             end
        })
    else
        wearBtn = XTHD.createCommonButton({
            text = LANGUAGE_KEY_SURE,
            btnSize = cc.size(130, 51),
            fontSize = 22,
            isScrollView = false,
            needSwallow = false,
            needEnableWhenMoving = true,
            musicFile="res/sound/EquipOn.mp3",
            endCallback = function( )
                XTHD.createArtifact(nil,nil,self._ArtifactTable.selectId,function( )
                    self:refreshData()
                end)
            end
        })
    end 
    wearBtn:setScale(0.8)
    wearBtn:setPosition(bg:getBoundingBox().width-250,50)
    bg:addChild(wearBtn)
    self._wearBtn = wearBtn

    self.cellList = {}
    self.DBartifactData = self:analysData()

    self._ArtifactTable.selectId = self.DBartifactData[1].godid
    
	self._ArtifactTable.getCellSize = function(table,idx)
        return 387,136
    end
		
	self._ArtifactTable.getCellNumbers = function(table)
        return math.ceil(#self.DBartifactData/2)
    end
    local function tableCellTouched(table,cell)
    end

    local function tableCellAtIndex(table1,idx)
    	local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else
            cell:removeAllChildren()
        end

        for i=1,2 do
        	if idx*2+i <= #self.DBartifactData then
                
        		local nowData = self.DBartifactData[idx*2+i]
        		local cellNode = self:getBtnNode()
        		local cell_bg = XTHDPushButton:createWithParams({
			         normalNode = cellNode[1],
			         selectedNode = cellNode[2],
			         needSwallow = false,
			         needEnableWhenMoving = true,
			         endCallback = function ()
                        
			         end
			    })
			    cell_bg:setAnchorPoint(i==1 and 0 or 1 ,0)
        		cell_bg:setPosition(i==1 and 0 or 780,3)
                cell:addChild(cell_bg)
                
                --点击后背景
                local imgClick = cc.Sprite:create("res/image/common/scale9_bg_13.png")
                imgClick:setName("imgClick")
                cell_bg:addChild(imgClick)
                imgClick:setScaleX(0.65)
                imgClick:setScaleY(0.83)
                imgClick:setPosition(cell_bg:getContentSize().width / 2, cell_bg:getContentSize().height / 2 + 2)

                imgClick:setVisible(false)

                --神器头像
        		local atfIcon = ItemNode:createWithParams({
        			_type_ = self.artifactData[nowData.templateId]._type,
        			clickable = false
                })
                atfIcon:setScale(0.9)
				atfIcon:setAnchorPoint(0,0.5)
				atfIcon:setPosition(10,cell_bg:getBoundingBox().height/2)
				cell_bg:addChild(atfIcon)
                --名字
				local atfName = XTHDLabel:createWithParams({
			        text = XTHD.resource.name[self.artifactData[nowData.templateId]._type] or "",
			        fontSize = 20,
                    color = cc.c3b(55,54,112),
                    ttf = "res/fonts/def.ttf"
			    })
			    atfName:setAnchorPoint(0,1)
			    atfName:setPosition(atfIcon:getPositionX()+atfIcon:getBoundingBox().width+15,atfIcon:getPositionY()+atfIcon:getBoundingBox().height/2-3)
			    cell_bg:addChild(atfName)
                --等级
			    local levelLabel = XTHDLabel:createWithParams({
			        text = "+"..self.artifactData[nowData.templateId].rank,
			        fontSize = 20,
                    color = cc.c3b(55,54,112),
                    ttf = "res/fonts/def.ttf"
			    })
			    levelLabel:setAnchorPoint(0,0)
			    levelLabel:setPosition(atfName:getPositionX()+atfName:getBoundingBox().width+5,atfName:getPositionY()-atfName:getBoundingBox().height)
			    cell_bg:addChild(levelLabel)
                --英雄头像
			    if nowData.petId ~= 0 then
			    	local heroIcon = HeroNode:createWithParams({
			    		heroid = nowData.petId
		    		})
		    		heroIcon:setAnchorPoint(1,1)
		    		heroIcon:setPosition(cell_bg:getBoundingBox().width-15,cell_bg:getBoundingBox().height-15)
		    		heroIcon:setScale(0.5)
		    		cell_bg:addChild(heroIcon)
			    end

			    for i=1,6 do
			    	if nowData["items"..i] ~= -1 then
			    		local stoneIcon = ItemNode:createWithParams({
			    			_type_ = 4,
			    			itemId = nowData["items"..i],
			    			clickable = false
                        })
                        -- stoneIcon.item_img:setScale(0.95)
                        stoneIcon:setScale(45/stoneIcon:getBoundingBox().width)
                        -- stoneIcon:setScale(0.5)
		    			stoneIcon:setAnchorPoint(0.5,0)
		    			stoneIcon:setPosition(XTHD.resource.getPosInArr({
		    				lenth = 2,
		    				bgWidth = cell_bg:getBoundingBox().width,
		    				num = 6,
		    				nodeWidth = stoneIcon:getBoundingBox().width,
		    				now = i
	    				})+45,10)
		    			cell_bg:addChild(stoneIcon)
		    		else
		    			local noGemIcon = cc.Sprite:create("res/image/plugin/hero/item_bg.png")
                        noGemIcon:setAnchorPoint(0.5,0)
		    			noGemIcon:setPosition(XTHD.resource.getPosInArr({
		    				lenth = 2,
		    				bgWidth = cell_bg:getBoundingBox().width,
		    				num = 6,
		    				nodeWidth = noGemIcon:getBoundingBox().width,
		    				now = i
	    				})+45,10)
	    				cell_bg:addChild(noGemIcon)
			    	end
			    end

                if self._ArtifactTable.selectId == nowData.godid then
                    cell_bg:getChildByName("imgClick"):setVisible(true)
			    	cell_bg:setSelected(true)
			    end
			    self.cellList[nowData.godid] = cell_bg
			    cell_bg:setTouchEndedCallback(function ()
                    cell_bg:setSelected(true)
                    cell_bg:getChildByName("imgClick"):setVisible(true)
			    	if self.cellList[self._ArtifactTable.selectId].setSelected ~= nil then
                        self.cellList[self._ArtifactTable.selectId]:setSelected(false)
                        self.cellList[self._ArtifactTable.selectId]:getChildByName("imgClick"):setVisible(false)
			    	end
                    self._ArtifactTable.selectId = nowData.godid
                    -- print("**********:" .. nowData.godid)
                    -- print("@@@@@@@" .. self._ArtifactTable.selectId)
                    self._selectedData = self.DBartifactData[idx*2+i]
			    end)
        	end
        end
        return cell
    end

    self._ArtifactTable:registerScriptHandler(self._ArtifactTable.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._ArtifactTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._ArtifactTable:registerScriptHandler(self._ArtifactTable.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    self._ArtifactTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._ArtifactTable:reloadData()
end

function ShenQiSelectPop:refreshData()
    self.DBartifactData = self:analysData()
    self._ArtifactTable:reloadDataAndScrollToCurrentCell()
end

function ShenQiSelectPop:analysData()
    local artifactData = self:getData()
    if artifactData.godid then
        artifactData = {artifactData}
    end
    return artifactData
end

function ShenQiSelectPop:getBtnNode()
    local _btnNodeTable = {}
    local _normalSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    _normalSprite:setContentSize(cc.size(387,131))
    local _selectedSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    _selectedSprite:setContentSize(cc.size(387,131))
    _btnNodeTable[1] = _normalSprite
    _btnNodeTable[2] = _selectedSprite
    return _btnNodeTable
end

function ShenQiSelectPop:getData()
	local DBData = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_ARTIFACT)
	local sortFunc = function(a1, a2)
        return self.artifactData[a1.templateId].rank > self.artifactData[a2.templateId].rank
    end
    table.sort(DBData,sortFunc)
    return DBData
end

function ShenQiSelectPop:setExtraCall(call)
    self._extraCall = call
end

function ShenQiSelectPop:create(heroId,refreshNode,callback, isLayout)
    local pop = ShenQiSelectPop.new({isRemoveLayout = isLayout})
	pop:initUI(heroId,refreshNode,callback)
    return pop 
end

function ShenQiSelectPop:onEnter( )
    -- if self._parent then 
    --     YinDaoMarg:getInstance():getACover(self._parent)
    --     if gameUser.getInstancingId() == 48 then ----第21组引导 
    --         YinDaoMarg:getInstance():addGuide({ ----经验丹引导
    --             parent = self._parent,        
    --             target = self._wearBtn,
    --             index = 7,
    --             needNext = false,
    --         },21)
    --     end 
    --     performWithDelay(self._wearBtn,function( )
    --         YinDaoMarg:getInstance():doNextGuide()   
    --         YinDaoMarg:getInstance():removeCover(self._parent)
    --     end,0.2)
    -- end 
end

return ShenQiSelectPop