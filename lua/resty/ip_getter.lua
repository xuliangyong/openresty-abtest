
local _M = {}

local mt = { __index = _M }

function _M.getip(self)
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

function _M.new(self) 
	return setmetatable({}, mt)
end


return _M