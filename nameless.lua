_addon.name = 'nameless'
_addon.version = '0.1.2'
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

local debug = function(message, ...)
	if settings.debug then
		print('Nameless >> '..string.format(message, ...))
	end
end

-- Hides nameplate
local hideplayername = function()
	playerindex = windower.ffxi.get_player().index
	_FlagChanger.HideEntityName(playerindex)
end

-- Adds a small delay to reset character/nameplate visibility and hide the nameplate again
local rehideplayername = function()
	playerindex = windower.ffxi.get_player().index
	_FlagChanger.ShowEntityName(playerindex)
	coroutine.sleep(0.1)
	hideplayername()
end

-- Hides nameplate on addon load
windower.register_event('load', function()
	playerindex = windower.ffxi.get_player().index
	rehideplayername(playerindex)
end)

-- Hides nameplate after main inventory load complete
windower.register_event('incoming chunk',function(id, original, modified, injected, blocked)
	if id == 0x001D then
		hideplayername()
	end
end)

-- Reset player visibility when Invisible buff is lost
windower.register_event('outgoing chunk',function(id, buff_id)
	if id == 0x0F1 then
		if buff_id == 69 then
			rehideplayername()
		end
	end
end)

-- Backup attempt to reset character visibility after losing Invisible
windower.register_event('lose buff', function(buff_id)
	--debug(tostring(buff_id))
	if buff_id == 69 then
		rehideplayername()
	end
end)

-- Attempting to solve for an odd case where Sneak cast afterwards seemed to cause the player to be invisible
windower.register_event('gain buff', function(buff_id)
	--debug(tostring(buff_id))
	if buff_id == 71 then
		if not T(windower.ffxi.get_player().buffs):contains(69) then
			rehideplayername()
		end
	end
end)

-- Make the nameplate/character visible again right before unloading, else you'd need to talk to an NPC or zone to reset yourself
windower.register_event('unload', function()
	playerindex = windower.ffxi.get_player().index
	_FlagChanger.ShowEntityName(playerindex)
end)