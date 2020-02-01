ClipNode = class( "ClipNode", function ( param )
	if param["drawnode"] ~= nil then
		return cc.ClippingNode:create( param["drawnode"] );
	else
		return cc.ClippingNode:create();
	end
end)

function ClipNode:ctor( param )
	local defaultParams = {
		rect 			= cc.rect(0, 0, 50, 50),
		drawnode 		= nil,
	};

	-- 重新赋值
	defaultParams["rect"] = cc.rectEqualToRect( param["rect"], defaultParams["rect"] ) and defaultParams["rect"] or param["rect"];
	
	if param["drawnode"] == nil then
		self:setContentSize(defaultParams["rect"]);

		local stencil = cc.DrawNode:create();
		local rectArr = {};
		rectArr[1] = cc.p(0, 0);
		rectArr[2] = cc.p(self:getContentSize().width, 0);
		rectArr[3] = cc.p(self:getContentSize().width, self:getContentSize().height);
		rectArr[4] = cc.p(0, self:getContentSize().height);
		stencil:drawPolygon(rectArr, 4, cc.c4b(1, 1, 1, 1), 1, cc.c4b(1, 1, 1, 1));
		self:setStencil(stencil);
	end
	self:setInverted( false );
    self:setAlphaThreshold(0);
end

function ClipNode:create( param )
	local node = self.new( param );
	return node;
end