-- Copyright (C) 2013 Yichun Zhang (agentzh)


local ffi = require 'ffi'
local ffi_string = ffi.string
local ffi_new = ffi.new
local C = ffi.C
local strlen = string.len
local setmetatable = setmetatable
local ngx = ngx
local type = type
local tostring = tostring
local error = error


module(...)


_VERSION = '0.0.1'


ffi.cdef[[
    void ngx_http_lua_ffi_md5_bin(const unsigned char *src, size_t len,
                                  unsigned char *dst);

    void ngx_http_lua_ffi_md5(const unsigned char *src, size_t len,
                              unsigned char *dst);

    int ngx_http_lua_ffi_sha1_bin(const unsigned char *src, size_t len,
                                  unsigned char *dst);
]]


if not ngx then
    return error("no existing ngx. table found")
end


local MD5_DIGEST_LEN = 16
local md5_buf = ffi_new("unsigned char[?]", MD5_DIGEST_LEN)

ngx.md5_bin = function (s)
    if type(s) ~= 'string' then
        if not s then
            s = ''
        else
            s = tostring(s)
        end
    end
    C.ngx_http_lua_ffi_md5_bin(s, strlen(s), md5_buf)
    return ffi_string(md5_buf, MD5_DIGEST_LEN)
end


local MD5_HEX_DIGEST_LEN = MD5_DIGEST_LEN * 2
local md5_hex_buf = ffi_new("unsigned char[?]", MD5_HEX_DIGEST_LEN)

ngx.md5 = function (s)
    if type(s) ~= 'string' then
        if not s then
            s = ''
        else
            s = tostring(s)
        end
    end
    C.ngx_http_lua_ffi_md5(s, strlen(s), md5_hex_buf)
    return ffi_string(md5_hex_buf, MD5_HEX_DIGEST_LEN)
end


local SHA_DIGEST_LEN = 20
local sha_buf = ffi_new("unsigned char[?]", SHA_DIGEST_LEN)

ngx.sha1_bin = function (s)
    if type(s) ~= 'string' then
        if not s then
            s = ''
        else
            s = tostring(s)
        end
    end
    local ok = C.ngx_http_lua_ffi_sha1_bin(s, strlen(s), sha_buf)
    if ok == 0 then
        return error("SHA-1 support missing in Nginx")
    end
    return ffi_string(sha_buf, SHA_DIGEST_LEN)
end


local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
