-- 该文件的主要作用是挂代理，但是类似于普通的extern，life都可以，但是像touch/schedule这种的就不需要了，因为不知道具体在什么地方unregister
Handler = {};

function Handler:extern( table, target )
	local t = tolua.getpeer(target);
	if not t then
		t = {};
		tolua.setpeer(t, target);
	end
	setmetatable(t, table);
	return target;
end

function Handler:externlife( this, target )
	local t = tolua.getpeer(target);
	if not t then
		t = {};
		tolua.setpeer(t, target);
	end
	setmetatable(t, this);

	local function handlerEvent( event )
		if event == "enter" then
			target:onEnter();
		elseif event == "exit" then
			target:onExit();
		elseif event == "cleanup" then
			target:onCleanup();
		end
	end
	target:registerScriptHandler(handlerEvent);
	return target;
end