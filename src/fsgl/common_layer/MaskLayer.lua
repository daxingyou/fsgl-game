--[[
该文件为 设置 灰色遮挡层
点击事件初始化设置为-9999， 使用引用计数的方式去做，这样就可以不用过多考虑到底是哪个最后remove

使用说明，将parent传进来，直接嗲用:newMaskLayer进行添加
]]
local MaskLayer = {};

MaskLayer.m_retainCount = 0;

function MaskLayer:create( node, pos, zOrder, color, opacity )
	zOrder = zOrder or 0;
	node = node or pDirector:getRunningScene();
	color = color or cc.c3b(0,0,0);
	opacity = opacity or 200.0;
	pos = pos or cc.p(0, 0);
	if self.m_retainCount == 0 then
		self.mask = cc.LayerColor:create();
		self.mask:setContentSize( cc.size( winWidth*2, winHeight ) );
		self.mask:setPosition( pos );
		self.mask:setColor( color );
        self.mask:setOpacity( opacity );
		node:addChild( self.mask, zOrder );
	end
	self.m_retainCount = self.m_retainCount + 1;

	local function handlerEvent( event )
		if event == "enter" then

		elseif event == "exit" then

		elseif event == "cleanup" then
			print(">>>> clean up");
			MaskLayer.m_retainCount = 0;
			self.mask = nil;
		end
	end
	if self.mask then
		self.mask:registerScriptHandler(handlerEvent);
	end
	return self.mask;
end

function MaskLayer:removeMaskLayer()

	self.m_retainCount = self.m_retainCount - 1;
	if self.m_retainCount < 0 then
		self.m_retainCount = 0;
	end
	print(">>>> removeMaskLayer: " .. tostring(self.m_retainCount));
	if self.m_retainCount == 0 and self.mask then
		self.mask:removeFromParent(true);
		self.mask = nil;
	end
	
end

return MaskLayer;