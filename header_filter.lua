local function gen_csrf_token(key, expires)
  if key == nil then
    return
  end

  if expires == nil then
    -- 默认token超时为3600秒
    expires = os.time() + 3600
  end
  
  -- 还未完成
end

-- cookie中有csrf token直接返回
local cookie_csrf_token = ngx.var["cookie_csrf_token"]
if cookie_csrf_token ~= nil then
  return
end

-- 此处设置csrf_token的超时时间
local csrf_token_timeout = 7200
local expires = os.time() + csrf_token_timeout
-- 此处的testkey由用户自己设置
local csrf_token = gen_csrf_token("testkey", expires)
if csrf_token ~= nil then
  ngx.header["Set-Cookie"] = {"csrf_token="..csrf_token..";path=/;expires="..ngx.cookie_time(expires)}
end
