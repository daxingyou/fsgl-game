--[[
该文件为 设置 灰色遮挡层
点击事件初始化设置为-9999， 使用引用计数的方式去做，这样就可以不用过多考虑到底是哪个最后remove

使用说明，将parent传进来，直接嗲用:newLoadingLayer进行添加
]]
local LoadingLayer = class( "LoadingLayer", function ()
	return XTHDDialog:create();
end);


function LoadingLayer:create()
	if self.m_retainCount == nil or self.m_retainCount == 0 then
		self.m_retainCount = 1;
		self.mask = self.new();
		self.mask:setColor( cc.c3b(0,0,0) );
        self.mask:setOpacity( 200.0 );
		pDirector:getRunningScene():addChild( self.mask, 9999 );
	end
	self.m_retainCount = self.m_retainCount + 1;

	local function handlerEvent( event )
		if event == "enter" then

		elseif event == "exit" then

		elseif event == "cleanup" then
			LoadingLayer.m_retainCount = 0;
			self.mask = nil;
		end
	end
	self.mask:registerScriptHandler(handlerEvent);

	return self.mask;
end

function LoadingLayer:removeLoadingLayer()

	self.m_retainCount = self.m_retainCount - 1;
	if self.m_retainCount == 0 and self.mask then
		self.mask:removeFromParent(true);
		self.mask = nil;
	end
	
end

return LoadingLayer;