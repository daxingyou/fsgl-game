local JiangJuFuGeneralRoom = class("JiangJuFuGeneralRoom", function()
	return cc.Layer:create()
end)

function JiangJuFuGeneralRoom:ctor()
	
end

-- self.CloseBtn = XTHDPushButton:createWithParams({
-- 		touchSize = cc.size(10000,10000),
--         endCallback = function ()
--             self:removeFromParent()
--         end
--     })

function JiangJuFuGeneralRoom:create(heroID,parent)
	self._parent = parent
    self._heroID = heroID
	local JiangJuFuGeneralRoom = JiangJuFuGeneralRoom:new()
	if JiangJuFuGeneralRoom then
		JiangJuFuGeneralRoom:init()
	end
	return JiangJuFuGeneralRoom
end

function JiangJuFuGeneralRoom:init()
	local view = requires("src/fsgl/layer/common/DuoCengScrollLayer.lua"):createOne()
    view:setBounce(10)
    self._backView = view
    self:addChild(view,-1)

    local pLay = cc.Node:create()
    pLay:setContentSize(1530, self:getContentSize().height)
    view:addNewBackLay(pLay, 1, 1)

	local bg = ccui.Scale9Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/dbj_01.png")
    pLay:addChild(bg)
	bg:setContentSize(1530, self:getContentSize().height)
    bg:setAnchorPoint(cc.p(0.5,0.5))
    bg:setPosition(cc.p(self:getContentSize().width - 330,self:getContentSize().height/2))
    self._bg = bg

     local btn_Inerior = XTHDPushButton:createWithParams({
        normalFile        = "res/image/plugin/JiangJuFuGeneralRoom/jjf_10.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = "res/image/plugin/JiangJuFuGeneralRoom/jjf_10.png",
        touchScale = 0.9,
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
          
        end,
    })
    btn_Inerior:setOpacity(0)
    btn_Inerior:getStateNormal():setOpacity(0)
    btn_Inerior:getStateSelected():setOpacity(0)
    self._bg:addChild(btn_Inerior)
    btn_Inerior:setScale(1.2)
    btn_Inerior:setPosition(cc.p(self._bg:getContentSize().width - btn_Inerior:getContentSize().width - 15,self._bg:getContentSize().height - 165))

    local close_btn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/plugin/JiangJuFuGeneralRoom/backbtn.png",--默认状态下显示的精灵的文件名(如果同时传入normalNode,则优先使用normalNode)
        selectedFile      = "res/image/plugin/JiangJuFuGeneralRoom/backbtn.png",
        touchScale = 0.9,
        musicFile = XTHD.resource.music.effect_btn_common,
        endCallback       = function()
            LayerManager.setChatRoomVisable(true)
       		 LayerManager.removeLayout()
        end,
    })
    self:addChild(close_btn)
    close_btn:setPosition(cc.p(close_btn:getContentSize().width / 2,self:getContentSize().height - close_btn:getContentSize().height / 2))

	local btnName = {"shipu_","baowu_","zhuangyuan_","majiu_"}
	for i = 1,4 do
		local btn = XTHDPushButton:createWithFile({
			normalNode = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/"..btnName[i].."1.png"),
			selectedNode = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/"..btnName[i].."2.png"),
		})
		self:addChild(btn)
		btn:setPosition(370 + ((i-1) * (btn:getContentSize().width+20)),btn:getContentSize().height / 2)
		btn:setTag(i)
		btn:setTouchEndedCallback(function()
			self:CallBtnBack(btn:getTag())
		end)
	end
	
	btnName = {"neifu_","zhenfu_","zhuangyuan_","majiu_"}
	local pos = {cc.p(390,370),cc.p(710,470),cc.p(1127,440),cc.p(1510,390)}
	for i = 1, 4 do
		local btn = XTHDPushButton:createWithFile({
			normalNode = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/btn/"..btnName[i].."1.png"),
			selectedNode = cc.Sprite:create("res/image/plugin/JiangJuFuGeneralRoom/btn/"..btnName[i].."2.png"),
		})
		self._bg:addChild(btn)
		btn:setPosition(pos[i])
		btn:setScale(0.8)
		btn:setTag(i+4)
		btn:setTouchEndedCallback(function()
			self:CallBtnBack(btn:getTag())
		end)
	end
end

function JiangJuFuGeneralRoom:CallBtnBack(index)
	if index == 5 then
		self:onGeneralRoomInterior()
	else
		XTHDTOAST("该功能暂未开放，敬请期待！")
	end
end

--赏赐
function JiangJuFuGeneralRoom:onGeneralRoomInterior(  )
	local JiangJunFuLayer = requires("src/fsgl/layer/JiangJunFu/JiangJunFuLayer.lua"):create(self._heroID,self)
	LayerManager.addLayout(JiangJunFuLayer)
end

function JiangJuFuGeneralRoom:reFreshLeftLayer(data)
    self._parent:reFreshLeftLayer2(data)
end

return JiangJuFuGeneralRoom