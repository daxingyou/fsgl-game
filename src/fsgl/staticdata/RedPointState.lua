RedPointState = 
{
	--state:0不显示红点，1显示红点
	{id = 1,state = 0,des = "节日狂欢"},
	{id = 2,state = 0,des = "精彩活动"},
	{id = 3,state = 0,des = "开服狂欢"},
	{id = 4,state = 0,des = "每日福利"},
	{id = 5,state = 0,des = "活跃有礼"},
	{id = 6,state = 0,des = "投资计划"},
	{id = 7,state = 0,des = "超值兑换"},
	{id = 8,state = 0,des = "日常活动"},
	{id = 9,state = 0,des = "毕业典礼"},
	{id = 10,state = 0,des = "任务"},
	{id = 11,state = 0,des = "闭关"},
	{id = 12,state = 0,des = "英雄"},
	{id = 13,state = 0,des = "装备"},
	{id = 14,state = 0,des = "回收"},
	{id = 15,state = 0,des = "邮件"},
	{id = 16,state = 0,des = "演武场"},
	{id = 17,state = 0,des = "新累计登录"},
	{id = 18,state = 0,des = "月卡至尊卡"},
	{id = 19,state = 0,des = "成长基金"},
	{id = 20,state = 0,des = "首冲团购"},
	{id = 21,state = 0,des = "限时抢购"},
	{id = 22,state = 0,des = "三次首冲"},
	{id = 23,state = 0,des = "充值有礼"},--节日狂欢（充值有礼）
	{id = 24,state = 0,des = "消费好礼"},--节日狂欢（消费好礼）
	{id = 25,state = 0,des = "材料兑换"},--节日狂欢（材料兑换）
	{id = 26,state = 0,des = "神装兑换"},--节日狂欢（神装兑换）
	{id = 27,state = 0,des = "英雄兑换"},--节日狂欢（英雄兑换）
	{id = 28,state = 0,des = "稀有兑换"},--节日狂欢（稀有兑换）
    {id = 29,state = 0,des = "行囊可开启提醒"},
}

function RedPointState.SetStateByID(data)
	if data then
		if RedPointState[data.id] then
			RedPointState[data.id].state = data.state
		end
	end
end

function RedPointState.GetStateByID(id)
	if RedPointState[id] then
		return RedPointState[id].state
	end
end