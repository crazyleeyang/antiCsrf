local function gen_csrf_token(key, expires)
    if key == nil then
        return
    end

    if expires == nil then
        -- 默认token超时为3600秒
        expires = os.time() + 3600
    end

    math.randomseed(tostring(os.time()):reverse():sub(1,6))
    local token = math.random(os.time())
    local resty_sha256 = require "resty.sha256"
    local str = require "resty.string"
    local sha256 = resty_sha256:new()
    sha256:update(token.."|"..expires.."|"..key)
    local digest = sha256:final()
    local sign = str.to_hex(digest)
    local msg = token.."|"..expires.."|"..sign
    local csrf_token = ngx.encode_base64(msg)
    return csrf_token
end

local function split(str, split_char)
    if str == "" then
        return {}
    end
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char, 1, true);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + string.len(split_char), #str);
    end

    return sub_str_tab;
end

local function check_csrf_token(key, csrf_token)
    local decode_str = ngx.decode_base64(csrf_token)
    if decode_str == nil then
        return false
    end

    local str_tab = split(decode_str, "|")
    local len = table.getn(str_tab)
    if len ~= 3 then
        return false
    end

    local req_token     = str_tab[1]
    local req_expires   = str_tab[2]
    local req_sign      = str_tab[3]
    local str = require "resty.string"
    local resty_sha256 = require "resty.sha256"
    local sha256 = resty_sha256:new()
    sha256:update(req_token.."|"..req_expires.."|"..key)
    local digest = sha256:final()
    local sign = str.to_hex(digest)
    if sign ~= req_sign then
        return false
    end

    if tonumber(req_expires) <= os.time() then
        return false
    end

    return true
end

-- 此处设置csrf_token的超时时间
local csrf_token_timeout = 7200
local key = "testkey"
local expires = os.time() + csrf_token_timeout

-- cookie中有csrf token，如果不合法，重新生成
local cookie_csrf_token = ngx.var["cookie_csrf_token"]
if cookie_csrf_token ~= nil then
    if check_csrf_token(key, cookie_csrf_token) then
        return
    else
        -- 如果超时或者token非法，重新生成
        local csrf_token = gen_csrf_token(key, expires)
        if csrf_token ~= nil then
          ngx.header["Set-Cookie"] = {"csrf_token="..csrf_token..";path=/;expires="..ngx.cookie_time(expires)}
        end
        return
    end
end

-- 此处的testkey由用户自己设置
local csrf_token = gen_csrf_token(key, expires)
if csrf_token ~= nil then
    ngx.header["Set-Cookie"] = {"csrf_token="..csrf_token..";path=/;expires="..ngx.cookie_time(expires)}
end
