_addon.name = 'nameless'
_addon.version = '0.1.1'
_addon.author = 'GTKashi, distilled from revisible 0.9.2 by Darkdoom;Rubenator;Akaden'

local self_invisible_flag = 0x8
local packets = require('packets')
local bit = require('bit')
require('sets')
local config = require('config')
 
local defaults = {
	debug=true,
}

local path = windower.addon_path:gsub('\\', '/') .. 'EntityFlagChanger.dll'
local _FlagChanger = assert(package.loadlib(path, 'luaopen_EntityFlagChanger'))()
local settings = config.load(defaults)

local hideplayername = function()
	playerindex = windower.ffxi.get_player().index
	_FlagChanger.HideEntityName(playerindex)
end

local debug = function(message, ...)
	if settings.debug then
		print('Nameless >> '..string.format(message, ...))
	end
end

windower.register_event('load', function()
	playerindex = windower.ffxi.get_player().index
	_FlagChanger.ShowEntityName(playerindex)
	coroutine.sleep(0.1)
	hideplayername()
end)

windower.register_event('incoming chunk',function(id, original, modified, injected, blocked)
	if id == 0x001D then
		hideplayername()
	end
end)

windower.register_event('lose buff', function(buff_id)
	playerindex = windower.ffxi.get_player().index
	--debug(tostring(buff_id))
	if buff_id == 69 then
		_FlagChanger.ShowEntityName(playerindex)
		coroutine.sleep(0.1)
		_FlagChanger.HideEntityName(playerindex)
	end
end)

windower.register_event('unload', function()
	playerindex = windower.ffxi.get_player().index
	_FlagChanger.ShowEntityName(playerindex)
end)