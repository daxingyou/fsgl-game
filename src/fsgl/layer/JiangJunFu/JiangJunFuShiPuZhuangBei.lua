--Created By Liuluyang 2015年08月07日
local JiangJunFuShiPuZhuangBei = class("JiangJunFuShiPuZhuangBei",function (sParams)
	return XTHD.createPopLayer(sParams)
end)

function JiangJunFuShiPuZhuangBei:ctor( )
    self._extraCall = nil -----需要在礼品装备里执行的
    self._selectedData = nil -----被选中的数据
    self._SelecteIndex = 1
    self._ZhuangBei = {}
end

function JiangJunFuShiPuZhuangBei:initUI()
    local item_data =  DBTableItem.getData(gameUser.getUserId(),nil,nil)
    
    for i = 1,#item_data do
        if item_data[i].item_type == 7 then
            self._ZhuangBei[#self._ZhuangBei + 1] = item_data[i]
        end
    end
    -- dump(self._ZhuangBei)
    local bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	bg:setContentSize(cc.size(802,470))
	bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(bg)

    local titleSp = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,34))
	titleSp:setPosition(bg:getBoundingBox().width/2,bg:getBoundingBox().height-30)
	bg:addChild(titleSp)

	local titleLabel = XTHDLabel:createWithParams({
		text = "侍仆装备",
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
            text = "装　备",
            fontSize = 22,
            needSwallow = false,
            needEnableWhenMoving = true,
            musicFile="res/sound/EquipOn.mp3",
            endCallback = function ()
                self:EquipmentPet()
            end
        })
  
    wearBtn:setScale(0.8)
    wearBtn:setPosition(bg:getBoundingBox().width-250,45)
    bg:addChild(wearBtn)
    self._wearBtn = wearBtn

    self.cellList = {}
    
    self._PrtTable.selectId = self._ZhuangBei[1].dbid

	self._PrtTable.getCellSize = function(table,idx)
        return 387,136
    end
	
	self._PrtTable.getCellNumbers = function(table)
        return math.ceil(#self._ZhuangBei/2)
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
        	if idx*2+i <= #self._ZhuangBei then
        		local nowData = self._ZhuangBei[idx*2+i]
                self._SelecteIndex = idx*2+i
                self._selectedData = self._ZhuangBei[1]
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
                local atfIcon = EquipItem:createSimpleItem(nowData)
                atfIcon:setScale(0.9)
				atfIcon:setAnchorPoint(0,0.5)
				atfIcon:setPosition(10,cell_bg:getBoundingBox().height/2)
				cell_bg:addChild(atfIcon)
                --名字
				local atfName = XTHDLabel:createWithParams({
			        text = self._selectedData.name or "喜羊羊",
			        fontSize = 26,
                    color = cc.c3b(55,54,112),
                    ttf = "res/fonts/def.ttf"
			    })
			    atfName:setAnchorPoint(0,1)
			    atfName:setPosition(atfIcon:getPositionX()+atfIcon:getBoundingBox().width+15,atfIcon:getPositionY()+atfIcon:getBoundingBox().height/2 - 30)
			    cell_bg:addChild(atfName)

                self.cellList[nowData.dbid] = cell_bg
                if self._PrtTable.selectId == nowData.dbid then
                    cell_bg:getChildByName("imgClick"):setVisible(true)
                    cell_bg:setSelected(true)
                end
                cell_bg:setTouchEndedCallback(function ()
                    cell_bg:setSelected(true)
                    cell_bg:getChildByName("imgClick"):setVisible(true)
                    if self.cellList[self._PrtTable.selectId].setSelected ~= nil then
                        self.cellList[self._PrtTable.selectId]:setSelected(false)
                        self.cellList[self._PrtTable.selectId]:getChildByName("imgClick"):setVisible(false)
                    end
                    self._PrtTable.selectId = nowData.dbid
                    self._selectedData = self._ZhuangBei[idx*2+i]
                    self._SelecteIndex = idx*2+i
                    -- dump(nowData,"选中的装备")
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

function JiangJunFuShiPuZhuangBei:refreshData()
    self._PrtTable:reloadDataAndScrollToCurrentCell()
end


function JiangJunFuShiPuZhuangBei:getBtnNode()
    local _btnNodeTable = {}
    local _normalSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    _normalSprite:setContentSize(cc.size(387,131))
    local _selectedSprite = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
    _selectedSprite:setContentSize(cc.size(387,131))
    _btnNodeTable[1] = _normalSprite
    _btnNodeTable[2] = _selectedSprite
    return _btnNodeTable
end

function JiangJunFuShiPuZhuangBei:EquipmentPet( )
    local item_data = gameData.getDataFromCSV("ServanEquip",{id = self._selectedData.itemid})
    if self._parent._curRank < item_data.needrank then
        XTHDTOAST("侍仆等级不足，佩戴当前装备等级最低为"..item_data.needrank.."级")
        return
    end
    self._parent:EquipmentPet(self._selectedData.dbid,self._indexPos)
    self:hide()
end

function JiangJunFuShiPuZhuangBei:setExtraCall(call)
    self._extraCall = call
end

function JiangJunFuShiPuZhuangBei:create(index,parent)
    self._servantId = servantId
    self._indexPos = index
    self._parent = parent
    self._heroid = heroid
    local pop = JiangJunFuShiPuZhuangBei.new({isRemoveLayout = isLayout})
	pop:initUI()
    return pop 
end

return JiangJunFuShiPuZhuangBei