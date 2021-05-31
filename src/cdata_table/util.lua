local _M = {}

local ffi = require 'ffi'
local ffi_sizeof = ffi.sizeof
local ffi_string = ffi.string
local ffi_new = ffi.new
local ffi_cast = ffi.cast

-- we lack the ability to manipulate types directly. so below is the workaround.
local function get_type_str(t)
    return tostring(ffi.typeof(t)):sub(7, -2) -- ctype<...>
end

local function add_type_fix(t_str, fix)
    local p = string.find(t_str, '[', 1, true)
    if p == nil then
        p = string.find(t_str, '*', 1, true)
    end
    if p==nil then
        t_str = t_str..fix
    else
        t_str = t_str:sub(1, p-1) .. fix..t_str:sub(p)
    end

    return t_str
end

local function get_cloned_pointer(x)
    local t_str = get_type_str(x)
    return ffi_new(add_type_fix(t_str, '[1]'), {x})
end

_M.get_type_str = get_type_str

function _M.c_to_lua(x) -- so the cdata can be used as dict index
    return ffi_string(get_cloned_pointer(x), ffi_sizeof(x))
end

function _M.lua_to_c(x, type) -- convert back
    return ffi_cast(add_type_fix(get_type_str(type),"(*)"), x)[0]
end

function _M.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
        setmetatable(copy, getmetatable(orig))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return _M