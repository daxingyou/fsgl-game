
--@author by hezhitao
--本文件用于控制是否进行异步更新

IS_CHECK_UPDATE = false

function getFlagUpdate( ... )
	if IS_CHECK_UPDATE then
		return IS_CHECK_UPDATE
	end
	return false
end