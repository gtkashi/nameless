_addon.name = 'nameless'
_addon.version = '0.1.0'
_addon.author = 'GTKashi, distilled from revisible 0.9.2 by Darkdoom;Rubenator;Akaden'

local packets = require('packets')
local bit = require('bit')
require('sets')

local path = windower.addon_path:gsub('\\', '/') .. 'EntityFlagChanger.dll'
local _FlagChanger = assert(package.loadlib(path, 'luaopen_EntityFlagChanger'))()

local hideplayername = function()
	_FlagChanger.HideEntityName(windower.ffxi.get_player().index)
end

windower.register_event('incoming chunk',function(id, original, modified, injected, blocked)
  if id == 0x001D then
	_FlagChanger.HideEntityName(windower.ffxi.get_player().index)
  end
end)

windower.register_event('load', hideplayername)