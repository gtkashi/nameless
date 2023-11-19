_addon.name = 'nameless'
_addon.version = '0.1.4'
_addon.author = 'GTKashi, distilled from revisible 0.9.2 by Darkdoom;Rubenator;Akaden'

local packets = require('packets')
 
debugsetting=false
checkactive = 1

local path = windower.addon_path:gsub('\\', '/') .. 'EntityFlagChanger.dll'
local _FlagChanger = assert(package.loadlib(path, 'luaopen_EntityFlagChanger'))()

local debug = function(message, ...)
	if debugsetting == true then
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
end

-- Adds a small delay to reset character/nameplate visibility and hide the nameplate again
local rehideplayername = function()
	_FlagChanger.ShowEntityName(windower.ffxi.get_player().index)
	coroutine.sleep(0.1)
	hideplayername()
end

-- Checks for invisible buff if found, makes the character transparent. If not found, resets character visibility only if character still transparent.
local checkinvisstatus = function()
	if T(windower.ffxi.get_player().buffs):contains(69) then
		hideplayer()
		--debug("player invisible apparently")
	else
		--debug("player not invisible apparently")
		if _FlagChanger.IsEntityInvisible(windower.ffxi.get_player().index) then
			rehideplayername()
		end
	end
end

-- Make the nameplate/character visible again right before unloading the addon, else you'd need to talk to an NPC or zone to reset yourself
windower.register_event('unload', function()
	_FlagChanger.ShowEntityName(windower.ffxi.get_player().index)
end)

local checkinvisstatusonload = function()
	if T(windower.ffxi.get_player().buffs):contains(69) then
		debug("player invisible on load")
	else
		rehideplayername()
		debug("player visible on load")
	end
end

-- Checks for invisible status on load/reload
windower.register_event('load', function()
	if not pcall(checkinvisstatusonload) then
		debug("calling invisibility status failed: probably while starting or stopping the game")
	end
end)

-- Runs invisible check before every tick
windower.register_event('prerender', function()
	if checkactive == 1 then
		if not pcall(checkinvisstatus) then
			debug("calling invisibility status failed: probably while starting or stopping the game")
		end
	end
end)

-- Hides nameplate after main inventory load complete, also reenables the prerender check
windower.register_event('incoming chunk',function(id, data)
	if id == 0x001D then
		checkactive = 1
		hideplayername()
	end
end)

-- Toggles a flag to stop the prerender check when changing zones
windower.register_event('zone change',function()
	checkactive = 0
end)

