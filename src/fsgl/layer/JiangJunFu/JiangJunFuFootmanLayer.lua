--Created By Liuluyang 2015年08月07日
local JiangJunFuFootmanLayer = class("JiangJunFuFootmanLayer",function (sParams)
	return XTHD.createPopLayer(sParams)
end)

local RESOURCE_ICON = {
	"res/image/common/Servant_msy.png",
	"res/image/common/Servant_qcj.png",
	"res/image/common/Servant_qly.png",
	"res/image/common/Servant_qzl.png",
	"res/image/common/Servant_yly.png"
}

function JiangJunFuFootmanLayer:ctor( )
    self._extraCall = nil -----需要在礼品装备里执行的
    self._selectedData = nil -----被选中的数据
    self._SelecteIndex = 1
end

function JiangJunFuFootmanLayer:initUI()
    -- local bg = ccui.Scale9Sprite:create(cc.rect(50,50,1,1),"res/image/common/scale9_bg_2.png")
    local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	bg:setContentSize(cc.size(802,470))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)

    local titleSp = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,34))
	titleSp:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-30)
	bg:addChild(titleSp)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_HERO_TEXT.ownedPet,
		fontSize = 26,
        color = cc.c3b(106,36,13),
        ttf = "res/fonts/def.ttf"
	})
	titleLabel:setPosition(titleSp:getBoundingBox().width/2,titleSp:getBoundingBox().height/2+20)
	titleSp:addChild(titleLabel)

	self.petData = gameData.getDataFromCSV("ServantUp")

	
    self._PrtTable = cc.TableView:create(cc.size(780,340))
	TableViewPlug.init(self._PrtTable)
	self._PrtTable:setPosition((bg:getBoundingBox().width-self._PrtTable:getBoundingBox().width)/2 +1, 80)
    self._PrtTable:setBounceable(true)
    self._PrtTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._PrtTable:setDelegate()
    self._PrtTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    bg:addChild(self._PrtTable)

    local exchangeBtn = XTHD.createCommonButton({
        btnColor = "write_1",
        btnSize = cc.size(130,49),
        isScrollView = true,
        needSwallow = false,
        text = "前往获取",
        fontSize = 22,
        needEnableWhenMoving = true,
        endCallback = function ()
         	XTHD.createSaintBeastChange(cc.Director:getInstance():getRunningScene(),function ()
                self:refreshData()
            end)
        end
    })
    exchangeBtn:setScale(0.8)
    exchangeBtn:setPosition(250,45)
    bg:addChild(exchangeBtn)
    local wearBtn = nil
    --if heroId then 
        wearBtn = XTHD.createCommonButton({
            btnColor = "write",
            btnSize = cc.size(130,49),
            isScrollView = true,
            text = "赏  赐",
            fontSize = 22,
            needSwallow = false,
            needEnableWhenMoving = true,
            musicFile="res/sound/EquipOn.mp3",
            endCallback = function ()
                self:EquipmentPet()
                self:hide()
            end
        })
    wearBtn:setScale(0.8)
    wearBtn:setPosition(bg:getBoundingBox().width-250,45)
    bg:addChild(wearBtn)
    self._wearBtn = wearBtn

    self.cellList = {}
    self.DBpetData = self:analysData()
    self._PrtTable.selectId = self.DBpetData[1].godid
	self._selectedData = self.DBpetData[1]    

	self._PrtTable.getCellSize = function(table,idx)
        return 387,136
    end
	
	self._PrtTable.getCellNumbers = function(table)
        return math.ceil(#self.DBpetData/2)
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
        	if idx*2+i <= #self.DBpetData then
        		local nowData = self.DBpetData[idx*2+i]
				local petListData = gameData.getDataFromCSV("ServantUp",{id = nowData.templateId })
                self._SelecteIndex = idx*2+i
                --self._selectedData = self.DBpetData[idx*2+i]
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
	
				
				local name = nil
				if 	petListData._type == 501 then
					name = RESOURCE_ICON[1]
				elseif 	petListData._type == 502 then
					name = RESOURCE_ICON[2]
				elseif 	petListData._type == 503 then
					name = RESOURCE_ICON[3]
				elseif 	petListData._type == 504 then
					name = RESOURCE_ICON[4]
				elseif 	petListData._type == 505 then
					name = RESOURCE_ICON[5]
				end		

                local atfIcon = cc.Sprite:create(name)
                atfIcon:setScale(0.9)
				atfIcon:setAnchorPoint(0,0.5)
				atfIcon:setPosition(10,cell_bg:getBoundingBox().height/2)
				cell_bg:addChild(atfIcon)
                --名字
				local atfName = XTHDLabel:createWithParams({
			        text = XTHD.resource.name[self.petData[nowData.templateId]._type] or "喜羊羊",
			        fontSize = 20,
                    color = cc.c3b(55,54,112),
                    ttf = "res/fonts/def.ttf"
			    })
			    atfName:setAnchorPoint(0,1)
			    atfName:setPosition(atfIcon:getPositionX()+atfIcon:getBoundingBox().width+15,atfIcon:getPositionY()+atfIcon:getBoundingBox().height/2-3)
			    cell_bg:addChild(atfName)
                --等级
			    local levelLabel = XTHDLabel:createWithParams({
			        text = "+"..self.petData[nowData.templateId].rank,
			        fontSize = 20,
                    color = cc.c3b(55,54,112),
                    ttf = "res/fonts/def.ttf"
			    })
			    levelLabel:setAnchorPoint(0,0)
			    levelLabel:setPosition(atfName:getPositionX()+atfName:getBoundingBox().width+5,atfName:getPositionY()-atfName:getBoundingBox().height)
			    cell_bg:addChild(levelLabel)
                --英雄头
                local heroIcon = nil
			    if nowData.petId ~= 0 then
			        heroIcon = HeroNode:createWithParams({
			    	    heroid = nowData.petId
		    	    })
                else
                    heroIcon = cc.Sprite:create()
                end
		    	heroIcon:setAnchorPoint(1,1)
		    	heroIcon:setPosition(cell_bg:getBoundingBox().width-15,cell_bg:getBoundingBox().height-5)
		    	heroIcon:setScale(0.5)
		    	cell_bg:addChild(heroIcon)
			   --nd
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

                if self._PrtTable.selectId == nowData.godid then
                    cell_bg:getChildByName("imgClick"):setVisible(true)
                    cell_bg:setSelected(true)
                end
                self.cellList[nowData.godid] = cell_bg
                cell_bg:setTouchEndedCallback(function ()
                    cell_bg:setSelected(true)
                    cell_bg:getChildByName("imgClick"):setVisible(true)
                    if self.cellList[self._PrtTable.selectId].setSelected ~= nil then
                        self.cellList[self._PrtTable.selectId]:setSelected(false)
                        self.cellList[self._PrtTable.selectId]:getChildByName("imgClick"):setVisible(false)
                    end
                    self._PrtTable.selectId = nowData.godid
                    -- print("**********:" .. nowData.petId)
                    -- print("@@@@@@@" .. self._PrtTable.selectId)
                    self._selectedData = self.DBpetData[idx*2+i]
					
                    self._SelecteIndex = idx*2+i
                    print("当前选中的仆从ID",self._SelecteIndex)
                end)
            end
        end
        return cell
    end
    self._PrtTable:registerScriptHandler(self._PrtTable.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._PrtTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._PrtTable:registerScriptHandler(self._PrtTable.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
    self._PrtTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._PrtTable:reloadData()
end

function JiangJunFuFootmanLayer:EquipmentPet(  )
    if self._selectedData.petId ~= 0 then
        XTHDTOAST("该侍仆已有主人，请将其辞退后方可赏赐他人！")
        return
    end
    ClientHttp:requestAsyncInGameWithParams({
        modules = "petDeployServant?",
        params  = {petId = self._heroid,servantId = self._selectedData.servantId},
        successCallback = function( data )
           self._selectedData.petId = data.petId
           DBPetData.UpdateAtfData(nil,data.servantId,"petId",data.petId)
           local petDatastr = {"hp", "physicalattack", "physicaldefence", "manaattack", "manadefence"}
           if data.petProperty[1] and data.petProperty[1].property then
                local  property = data.petProperty[1].property
                for i=1,#property do
                    local _tab = string.split(property[i], ",")
                    DBPetData.UpdateAtfData(nil, data.servantId, petDatastr[i],data.servantProperty[1].property[20 .. (i-1)])     
                end
            end
			if data["petProperty"] then
				for i = 1,#data["petProperty"] do
					local _data = data["petProperty"][i]
					for j = 1,#_data["property"] do
						local _petItemData = string.split( _data["property"][j],',')
						DBTableHero.updateDataByPropId(gameUser.getUserId(),_petItemData[j],_petItemData[2],_data["petId"])	
						if tonumber(_petItemData[1]) == 407 then
								--self._newFightValue = tonumber(_petItemData[2])
						end
					end
				end
			end
			

            local tab = DBTableHero.getHeroData(data.petId)
            self._parent:reFreshLeftLayer2(tab)
            self._parent:UpdataShangCi(DBPetData.DBData[data.servantId])
			if self._parent._ItemNode then
				self._parent._ItemNode:removeFromParent()
				self._parent._ItemNode = nil
			end
			self._parent:createItemNode()
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    })
end

function JiangJunFuFootmanLayer:refreshData()
    self.DBpetData = self:analysData()
    self._PrtTable:reloadDataAndScrollToCurrentCell()
end

function JiangJunFuFootmanLayer:analysData()
    local petData = self:getData()
    if petData.petId then
        petData = {petData}
    end
    return petData
end

function JiangJunFuFootmanLayer:getBtnNode()
    local _btnNodeTable = {}
    local _normalSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    _normalSprite:setContentSize(cc.size(387,131))
    local _selectedSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    _selectedSprite:setContentSize(cc.size(387,131))
    _btnNodeTable[1] = _normalSprite
    _btnNodeTable[2] = _selectedSprite
    return _btnNodeTable
end

function JiangJunFuFootmanLayer:getData()
	local DBData = gameData.getDataFromDynamicDB(gameUser.getUserId(), DB_TABLE_NAME_PET)
	local sortFunc = function(a1, a2)
        return self.petData[a1.templateId].rank > self.petData[a2.templateId].rank
    end
    table.sort(DBData,sortFunc)
    return DBData
end

function JiangJunFuFootmanLayer:setExtraCall(call)
    self._extraCall = call
end

function JiangJunFuFootmanLayer:create(heroid,parent)
    self._parent = parent
    self._heroid = heroid
    local pop = JiangJunFuFootmanLayer.new({isRemoveLayout = isLayout})
	pop:initUI()
    return pop 
end

return JiangJunFuFootmanLayer