--[[
读取CSV文件成table
]]
FileReader = {}

local key = {}

function FileReader:removeStringSpace(target )
    if target and target ~= "" then
        target = string.gsub(target,"%s","")
        return target
    end
    return nil
end

function FileReader:installCsvData(line)  
    local i = 1
    local data = {}
    local begin = 1
    while true do        
        local index = string.find(line,",",begin)
        if not index or (index == begin and #line <= index + 1) then 
            break
        else 
            ----处理字符串本身就有逗号的
            local x,y = string.find(line,"\"",begin)           
            if x and index > x then 
                y = string.find(line,"\"",x + 1)
                local value = string.sub(line,x + 1,y - 1)
                value = self:removeStringSpace(value)
                if value and #value > 0 then 
                    if tonumber(value) then 
                        data[key[i]] = tonumber(value)
                    else 
                        local a,b = string.find(value,'#')
                        if not a or a ~= 1 then 
                            data[key[i]] = value
                        else 
                            data[key[i]] = string.sub(value,2)
                        end 
                    end 
                end 
                i = i + 1
                begin = y + 2
            else                 
                local value = string.sub(line,begin,index - 1)
                value = self:removeStringSpace(value)
                if value and #value > 0 then 
                    if tonumber(value) then 
                        data[key[i]] = tonumber(value)
                    else 
                        local a,b = string.find(value,'#')
                        if not a or a ~= 1 then 
                            data[key[i]] = value
                        else 
                            data[key[i]] = string.sub(value,2)
                        end 
                    end 
                end 
                i = i + 1
                begin = index + 1
            end 
        end 
    end
    return data
end

function FileReader:installCsvKey( line )
    local i = 1
    local begin = 1
    while true do
        local index = string.find(line,";",begin)
        index = index == nil and string.find(line,",",begin) or index
        if not index or begin >= #line then
            break
        else 
            key[i] = string.sub(line,begin,index - 1)
            key[i] = self:removeStringSpace(key[i])
            begin = index + 1
            i = i + 1
        end
    end
end

function FileReader:loadCSVData(path)        
    local packageData = {}
    local packageDataByKey = {}
    if string.find(path,".csv") == nil then
        return nil
    end    
    local data = cc.FileUtils:getInstance():getStringFromFile(path)        
    if data == nil or #data <= 1 then 
        return nil
    end
    local j = 1
    local i = 1
    local begin = 1
    while true do
        local newData = nil
        local isover = false
        local index = string.find(data,"\r",begin)
        if not index then 
            index = string.find(data,"\n",begin)
        end 
        if not index or begin >= #data then
           return packageData,packageDataByKey
        else
            if j == 2 then 
                newData = string.sub(data,begin,index)
                self:installCsvKey(newData)
            elseif j > 2 then
                newData = string.sub(data,begin,index)
                local value = self:installCsvData(newData)
                if value and next(value) ~= nil then 
                    packageData[i] = value
                    local _primaryKey = value[tostring(key[1])]
                    packageDataByKey[tostring(_primaryKey)] = value
                    i = i + 1
                end 
            end 
            begin = index + 1
            j = j + 1
        end 
    end 
    return packageData,packageDataByKey
end