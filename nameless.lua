_addon.name = 'nameless'
_addon.version = '0.1.0'
_addon.author = 'GTKashi, distilled from revisible 0.9.2 by Darkdoom;Rubenator;Akaden'

namehidden = 0

local packets = require('packets')
local bit = require('bit')
require('sets')
local config = require('config')

local path = windower.addon_path:gsub('\\', '/') .. 'EntityFlagChanger.dll'
local _FlagChanger = assert(package.loadlib(path, 'luaopen_EntityFlagChanger'))()

local settings = config.load(defaults)

local defaults = {
  debug=false,
}

local debug = function(message, ...)
  if settings.debug then
    print('Nameless >> '..string.format(message, ...))
  end
end

local hideplayername = function()
  if namehidden == 0 then 
	_FlagChanger.HideEntityName(windower.ffxi.get_player().index)
	--debug('Logout/in/load/unload/zonechange Set %d name to invisible', windower.ffxi.get_player().index)
	namehidden = 1
  end
end

windower.register_event('incoming chunk',function(id, data, modified, injected, blocked)
  if injected then return end

  if namehidden == 0 then
	  if id == 0xD or id == 0x037 then 
		_FlagChanger.HideEntityName(windower.ffxi.get_player().index)
		--debug('IncomingChunk Set %d name to invisible', windower.ffxi.get_player().index)
		namehidden = 1
	  end
  end
end)

windower.register_event('zone change', 'load', function()
  local n = 0
  while n<7 do
	  namehidden = 0
	  coroutine.sleep(2)
	  hideplayername()
	  n = n + 1
  end
end)
windower.register_event('logout', 'login', 'load', 'unload', hideplayername)
