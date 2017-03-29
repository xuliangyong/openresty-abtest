local conf = require "config"
--取真实ip
function get_real_ip()
	ngx.log(ngx.INFO, "======================================x-forwarded-for:", ngx.req.get_headers()["x-forwarded-for"])
	ngx.log(ngx.INFO, "======================================Proxy-Client-IP:", ngx.req.get_headers()["Proxy-Client-IP"])
	ngx.log(ngx.INFO, "======================================WL-Proxy-Client-IP:", ngx.req.get_headers()["WL-Proxy-Client-IP"])
	ngx.log(ngx.INFO, "======================================remote_addr:", ngx.var.remote_addr)
	
	local real_ip = ngx.req.get_headers()["x-forwarded-for"]
	if real_ip == nil then
		real_ip = ngx.req.get_headers()["Proxy-Client-IP"]
	end
	
	if real_ip == nil then
		real_ip = ngx.req.get_headers()["WL-Proxy-Client-IP"]
	end	
	
	if real_ip == nil then
		real_ip = ngx.var.remote_addr
	end	
	
	if real_ip ~= nil and #real_ip > 15 then 
		local s = string.find(real_ip,",")
		if s ~= nil then
			real_ip = string.sub(real_ip, 1, s-1)
		end
	end
	
	return real_ip
end

--查询ip是否在redis
function get_ip_from_redis(clientip)
	local redis = require "resty.redis_iresty"
	local cfg = {timeout = 1000, host = conf.redis.host, port = conf.redis.port, password = conf.redis.password}
	local red = redis:new(cfg)
	
	local resp, err = red:get(clientip)  
	if not resp then  
		ngx.log(ngx.INFO, err)
	end 
	
	return resp
	
end

---------  start  --------
local ip_getter = require "resty.ip_getter"
local ipget = ip_getter:new()
local clientip = ipget:getip()
local value = get_ip_from_redis(clientip)

if value ~= nil then 
	ngx.exec("@proxy_new")
else
	ngx.exec("@proxy_old")
end	




	
	