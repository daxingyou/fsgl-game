SortPos = {};

--[[
	@tip  该方法的作用是用来排列顺序使用的，
	@param1: 中心点坐标
	@param2: 需要排列的元素的个数
	@param3: 每个之间需要按照distance的距离排列
]]

function SortPos:sortFromMiddle( midPos, count, distance )
	local posX = midPos.x;
	local posY = midPos.y;
	local bEven = count % 2;
	local tabPos = {};
	local tmpPos = cc.p(0, 0);
	-- 对avator btn进行排序
	if bEven == 0 then
		-- odd 从中间的x-1, x 分别想两边排列
		-- 向左排
		for i = count/2,  1, -1 do
			if i == count/2 then
				tmpPos = cc.p(posX-distance/2, posY);
			else
                tmpPos = cc.p(tabPos[i+1].x-distance, posY);
			end
			tabPos[i] = tmpPos;
		end
		-- 向右排
		for i = count/2+1,  count do
			if i == count/2+1 then
				tmpPos = cc.p(posX+distance/2, posY);
			else
				tmpPos = cc.p(tabPos[i-1].x+distance, posY);
			end
			tabPos[i] = tmpPos;
		end
	else
		-- odd
		local midIndex = math.ceil(count/2);  -- 向上取整
		-- 向左排
		for i = midIndex,  1, -1 do
			if i == midIndex then
                tmpPos = cc.p(posX, posY);
			else
				tmpPos = cc.p(tabPos[i+1].x-distance, posY);
			end
			tabPos[i] = tmpPos;
		end
		-- 向右排
		for i = midIndex+1,  count do
			tmpPos = cc.p(tabPos[i-1].x+distance, posY);
			tabPos[i] = tmpPos;
		end
	end
	return tabPos;
end