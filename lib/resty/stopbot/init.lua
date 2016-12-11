local M = {
   storage = {},
   zones = {},
}

local zone_option_validators = {
   access = function (value)
      return value == "log" or value == "count"
   end,
   access_expires = function (value)
      return tonumber(value) ~= nil
   end,
   access_limit = function (value)
      return tonumber(value) ~= nil
   end,
   only_after = function (value)
      return type(value) == "table" and #value > 0
   end,
}

function M.init_storage(storage_name, module_name, storage_options)
   M.storage[storage_name] = function ()
      local storage_module = require(module_name)
      return storage_module.new(storage_options)
   end
end

function M.init_zone(zone_name, options)
   if zone_name == nil then
      error("zone_name should not be nil")
   end
   if M.zones[zone_name] then
      error("duplicate zone declaration: " .. tostring(zone_name))
   end
   local options = options or {}
   local validator
   for name, value in pairs(options) do
      validator = zone_option_validators[name]
      if validator == nil then
         error('unknown zone option ' .. tostring(name))
      end
      if not validator(value) then
         error('invalid value ' .. tostring(value) .. ' for option ' .. tostring(name))
      end
   end
   M.zones[zone_name] = options
end

function M.access_zone(zone_name)
   -- TODO don't really need to raise errors here
   local zone = M.zones[zone_name]
   local remote_addr = ngx.var.remote_addr
   if zone == nil then
      error("unknown zone " .. tostring(zone_name))
   end
   local storage = M.storage.default()
   storage:zone_increment(zone_name, remote_addr)
   if zone.access_expires then
      storage:set_ttl(zone.access_expires)
   end
   local i, name
   if zone.only_after then
      for i, name in ipairs(zone.only_after) do
         storage:zone_get_count(name, remote_addr)
      end
   end
   local result = storage:execute()
   if zone.access_limit and zone.access_limit < result[1] then
      print('too many requests')
      ngx.exit(ngx.HTTP_TOO_MANY_REQUESTS)
   end
   if zone.only_after then
      for i, name in ipairs(zone.only_after) do
         if result[i+1] < 1 then
            print('forbidden')
            ngx.exit(ngx.HTTP_FORBIDDEN)
         end
      end
   end
end

return M
