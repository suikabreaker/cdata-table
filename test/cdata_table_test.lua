local ctbl = require "cdata_table"
local ffi = require "ffi"


local t_v = {
    ffi.new('int32_t', 1),
    ffi.new('int64_t', 1),
    ffi.new('int32_t', 2),
    ffi.new('int64_t', 2),
    ffi.new('char[10]', 'good!'),
    ffi.new('char[10]', 'bad!'),
    "good!", "bad!",
    1,2,3
}

local t = ctbl()
for _, v in ipairs(t_v) do
    t[v] = v
end

for _, v in ipairs(t_v) do
    assert(t[v]==v)
end

for k, v in pairs(t) do
    if type(k) == 'cdata' and tostring(ffi.typeof(k)):find('&') then
        k,v=ffi.string(k),ffi.string(v)
    end

    print(k, '=', v)
    assert(k==v)
end