-- usage:
-- local cdata_table = require 'cdata_table'
-- local tbl = cdata_table()
-- local index = ffi.new('int64_t', 10086)
-- tbl[index] = 1
-- print(tbl[index]) -- result = 1
--
-- note that tbl[ffi.new('int64_t', 10086)] has difference with tbl[10086] cause they have different type
-- type matters in cdata_table


local cdata_table = {}

local table_meta = {}

local cdata_table_util = require 'cdata_table.util'
local shallow_copy = cdata_table_util.shallowcopy
local c_to_lua = cdata_table_util.c_to_lua
local lua_to_c = cdata_table_util.lua_to_c
local get_type_str = cdata_table_util.get_type_str

local function to_key(x)
    if type(x) == "string" then
        return 's'..x
    elseif type(x) == 'cdata' then
        return 'c' .. get_type_str(x) .. '@' .. c_to_lua(x)
    else
        return x
    end
end

local function from_key(key)
    if type(key) ~= "string" then
        return key
    end

    local t = key:sub(1,1)
    if t == 's' then
        return t:sub(2)
    elseif t == 'c' then
        local ep = string.find(key, '@', 2, true)
        local t_str = key:sub(2,ep - 1)
        local data = key:sub(ep + 1)
        return lua_to_c(data, t_str)
    else
        error('unknonwn key type')
    end
end

function table_meta.__index(self, ind)
    return rawget(self, to_key(ind))
end

function table_meta.__newindex(self, ind, val)
    return rawset(self, to_key(ind), val)
end

-- ipairs simply works without specification
-- pairs needs to be treat specially
function table_meta.__pairs(self)
    local tbl, key = self, nil
    return function()
        local v
        key, v = next(tbl, key)
        if nil~=v then return from_key(key),v end
    end
end


function cdata_table.new(tbl)
    local ret = setmetatable({}, table_meta)
    if type(tbl) == 'table' then
        if getmetatable(tbl) == table_meta then
            return shallow_copy(tbl)
        end
    elseif tbl == nil then
        return ret
    else
        error('cdata_table must be created from table!')
    end

    for k, v in pairs(tbl) do
        ret[k] = v
    end
    return ret
end

local cdata_dict_meta = {__call= function (_, ...) return cdata_table.new(...) end}

return setmetatable(cdata_table, cdata_dict_meta)