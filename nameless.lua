_addon.name = 'nameless'
_addon.version = '0.1.3'
_addon.author = 'GTKashi, distilled from revisible 0.9.2 by Darkdoom;Rubenator;Akaden'

local self_invisible_flag = 0x8
local packets = require('packets')
local bit = require('bit')
require('sets')
local config = require('config')
 
local defaults = {
	debug=false,
}

playerisinvisible = 0

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
	_FlagChanger.HideEntityName(windower.ffxi.get_player().index)
end

-- Hides player
local hideplayer = function()
	_FlagChanger.SetEntityInvisible(windower.ffxi.get_player().index)
	playerisinvisible = 1
end

-- Adds a small delay to reset character/nameplate visibility and hide the nameplate again
local rehideplayername = function()
	_FlagChanger.ShowEntityName(windower.ffxi.get_player().index)
	coroutine.sleep(0.1)
	hideplayername()
end

-- Hides nameplate on addon load
windower.register_event('load', function()
	rehideplayername(windower.ffxi.get_player().index)
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
			playerisinvisible = 0
		end
	end
end)

-- Backup attempt to reset character visibility after losing Invisible
windower.register_event('lose buff', function(buff_id)
	--debug(tostring(buff_id))
	if buff_id == 69 then
		rehideplayername()
	end
	if playerisinvisible == 1 and not T(windower.ffxi.get_player().buffs):contains(69) then
		playerisinvisible = 0
		rehideplayername()
	end
end)

-- Attempting to solve for an odd case where Sneak cast afterwards seemed to cause the player to be invisible
windower.register_event('gain buff', function(buff_id)
	--debug(tostring(buff_id))
	if buff_id == 69 then
		hideplayer()
		coroutine.sleep(1.5)
		hideplayer()
	end
end)

-- Make the nameplate/character visible again right before unloading, else you'd need to talk to an NPC or zone to reset yourself
windower.register_event('unload', function()
	_FlagChanger.ShowEntityName(windower.ffxi.get_player().index)
end)

-- Checks for invisible status on reload
windower.register_event('load', function()
	if T(windower.ffxi.get_player().buffs):contains(69) then
		playerisinvisible = 1
	else
		playerisinvisible = 0
	end
end)