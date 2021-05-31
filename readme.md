# cdata table

This library provides for LuaJIT a table type that allows using cdata as its index.

## Installation

```bash
luarocks install https://raw.githubusercontent.com/suikabreaker/cdata-table/master/cdata_table-1.rockspec
```

## Usage

Example:

```lua
local ffi = require 'ffi'
local cdata_table = require 'cdata_table'
local tbl = cdata_table() -- it's the same like to use cdata_table.new()


local i64_ind = ffi.new('int64_t', 1)
tbl[i64_ind] = 'test'
print(tbl[i64_ind]) -- output: test

for k, v in pairs(tbl) do
    print(k) -- output: 1LL
end
```

Keys are identified by their values, or to be precise, by their bytes representation and types.

Note that type matters. And even being integer type, cdata is not treated as number:

```lua
tbl[1] = 'test2'
print(tbl[1]) -- output: test2
local i32_ind = ffi.new('int32_t', 1)
tbl[i32_ind] = 'test3'
print(tbl[i32_ind]) -- output: test3

for k, v in pairs(tbl) do
    print(k)
end
-- output(order may vary, output format for i32 depends on environment):
-- 1LL
-- 1
-- 1
for k, v in ipairs(tbl) do
    print(k)
end
-- output:
-- 1
```

Of cause every type that can be used as index for normal table also works:

```lua
tbl.test = 'test4'
print(tbl['test']) -- output: test4
```

and other cdata type:

```lua
local cstr_ind = ffi.new('char[6]', 'good!')
tbl[cstr_ind] = 'test4'
print(tbl[cstr_ind]) -- output: test5
```