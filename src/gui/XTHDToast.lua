XTHDToast = XTHDToast or {}

TOAST_DEFAULT_FADEOUT_DURATION = 0.264

local function getSequenceAction(...)
    local action = {}
    for i=1, select("#", ...) do
        local  arg = select(i, ...)
        if arg then
            -- action:addObject(arg)
            action[#action+1] = arg
        end
    end
    return cc.Sequence:create(action)
end

function XTHDToast:new()
	local store = nil
	local fontName = ""
	local fontSize = 20.0


	function init(self)
	
		if store then return store end
	
		local o = {}
		setmetatable(o,  self)

		store  = o
		store.text = ""

		local function createLayout()
			local textField = XTHDLabel:create(store.text, fontSize)
			textField:setFontSize(30)
			textField:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1),1)
			return textField
		end

		local function createAction(target)
			if not TOASTLIST then
				TOASTLIST = {}
			else
				print(#TOASTLIST)
			end

			local scene = cc.Director:getInstance():getRunningScene()
			target:setPosition(scene:getBoundingBox().width/2,scene:getBoundingBox().height/2+150)
			scene:addChild(target, 100)

			local handler = function(event)
				if event == "exit" then
					TOASTLIST = {}
				end
            end

            scene:registerScriptHandler(handler)

			target:setScale(0)
			TOASTLIST[#TOASTLIST+1] = target
			if #TOASTLIST == 1 then
				self:runToast()
			end
		end

		function store:flashShow(string)
			local string = string or ""
			local textField = createLayout()
			textField:setString(string)
			createAction(textField)
		end

		function store:flashShowWithColor(string,quality)
			local tempContent , textField = createLayout()
			textField:setString(string)
			createAction(tempContent, 0.7, 0)
		end
	
		return o

	end

	return init(self)


end

function XTHDToast:runToast()
	TOASTLIST[1]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.7),cc.ScaleTo:create(0.2,1),cc.Spawn:create(cc.MoveBy:create(2.5,cc.p(0,200)),cc.FadeOut:create(2.5)),cc.RemoveSelf:create()))
	TOASTLIST[1]:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function ()
		table.remove(TOASTLIST,1)
		if #TOASTLIST ~= 0 then
			self:runToast()
		end
	end)))
end