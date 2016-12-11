local M = {}
M.__index = M

function M.new(options)
   local instance = {}
   setmetatable(instance, M)

   instance.name = options.name
   instance.result = {}
   return instance
end

function M:zone_increment(zone_name, remote_addr)
   local key = zone_name .. '_' .. remote_addr
   local value = ngx.shared[self.name]:incr(key, 1, 0)
   print (key, ' => ', value)
   table.insert(self.result, value)
end

function M:zone_get_count(zone_name, remote_addr)
   local key = zone_name .. '_' .. remote_addr
   local value = ngx.shared[self.name]:get(key) or 0
   print (key, ' => ', value)
   table.insert(self.result, value)
end

function M:set_ttl(ttl)
end

function M:execute()
   print('execute')
   local res = self.result
   self.result = {}
   return res
end

return M
