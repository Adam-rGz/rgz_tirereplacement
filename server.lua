------------------------------------------
--	rGz Tire replacement  --
------------------------------------------
ESX                = nil

local tirescfg = {
	["wheel_lf"] = 0,
	["wheel_rf"] = 1,
	["wheel_lm1"] = 2,
	["wheel_rm1"] = 3,
	["wheel_lm2"] = 45,
	["wheel_rm2"] = 47,
	["wheel_lm3"] = 46,
	["wheel_rm3"] = 48,
	["wheel_lr"] = 4,
	["wheel_rr"] = 5,
}
local tireBones = {"wheel_lf", "wheel_rf", "wheel_lm1", "wheel_rm1", "wheel_lm2", "wheel_rm2", "wheel_lm3", "wheel_rm3", "wheel_lr", "wheel_rr"}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('rgz_opony:getCfg', function (source, cb)
	cb(tirescfg, tireBones)
end)

ESX.RegisterUsableItem('klucz1', function(source)
	local _source = source
	math.randomseed(os.time())
	math.random(); math.random(); math.random()
	zbita = math.random(0,9)
	szyba = math.random(0,5)
	TriggerClientEvent('rgz_opony:fix', _source, 1, zbita, szyba)
end)

ESX.RegisterUsableItem('klucz2', function(source)
	local _source = source
	math.randomseed(os.time())
	math.random(); math.random(); math.random()
	zbita = math.random(0,13)
	szyba = math.random(0,5)
	TriggerClientEvent('rgz_opony:fix', _source, 2, zbita, szyba)
end)

--[[RegisterCommand("opona", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if(xPlayer.getInventoryItem('klucz1').count > 0) or  then
		TriggerClientEvent('rgz_opony:fix', _source, 1)
    elseif(xPlayer.getInventoryItem('klucz2').count > 0) or  then
		TriggerClientEvent('rgz_opony:fix', _source, 2)
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Nie posiadasz~s~ przy sobie ~g~Klucza~s~!')
    end
end, true)
]]--
RegisterServerEvent("rgz_opony:napraw")
AddEventHandler("rgz_opony:napraw", function(client, tireIndex)
	TriggerClientEvent("rgz_opony:naprawiono", client, tireIndex)
	
end)


