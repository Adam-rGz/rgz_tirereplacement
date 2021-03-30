------------------------------------------
--	rGz Tire replacement  --
------------------------------------------
local rgzBusy = false
ESX = nil
local tiresCfg = {}
local tiresCfg2 = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
	
	ESX.TriggerServerCallback('rgz_opony:getCfg', function(cfg, cfg2)
		tiresCfg = cfg
		tiresCfg2 = cfg2
	end)
end)



RegisterNetEvent('rgz_opony:fix')
AddEventHandler('rgz_opony:fix', function(option,zbita,szyba)
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local vehicle = GetClosestVehicleToPlayer()
	local animDict = "melee@knife@streamed_core_fps"

	if rgzBusy == false then
		if vehicle ~= 0 then
			local closestTire = GetClosestVehicleTire(vehicle)
			if closestTire ~= nil then
				if IsVehicleTyreBurst(vehicle, closestTire.tireIndex)  then
										
						rgzBusy = true
						TaskStartScenarioInPlace(plyPed, 'PROP_HUMAN_BUM_BIN', 0, true)
						Citizen.CreateThread(function()
							local needed_time = 1700
							if option == 2 then 
								needed_time = 1000
							end
							local timer = needed_time
							while timer > 0 do
								timer = timer -1	
								local del = 100 - (100 * (timer / needed_time))
								local procent = ESX.Math.Round(del, 2)							
								Draw3DText(closestTire.bonePos.x, closestTire.bonePos.y, closestTire.bonePos.z, tostring("~r~Repairing "..procent.."%"))
								Citizen.Wait(10)
							end
							
							if option == 1 and zbita < 3 then
								SmashVehicleWindow(vehicle, closestTire.tireIndex)
								TriggerEvent("pNotify:SendNotification", {text = "oops, you accidentally broke the glass", type = "error", queue = "global", timeout = 3000, layout = "bottomRight"})	
							end
								
							if option == 2 and zbita < 2 then
								SmashVehicleWindow(vehicle, closestTire.tireIndex)
								TriggerEvent("pNotify:SendNotification", {text = "oops, you accidentally broke the glass", type = "error", queue = "global", timeout = 3000, layout = "bottomRight"})	
							end

							local driverOfVehicle = GetDriverOfVehicle(vehicle)
							local driverServer = GetPlayerServerId(driverOfVehicle)
						
							if driverServer == 0 then
								TriggerEvent("pNotify:SendNotification", {
									text = "Tire repaired, remember that others may still have holes!",
									type = "success",
									queue = "global",
									timeout = 3000,
									layout = "bottomRight"
								})
								SetVehicleTyreFixed(vehicle, closestTire.tireIndex)	
											
								rgzBusy = false
							else
								TriggerServerEvent("rgz_opony:napraw", driverServer, closestTire.tireIndex)			
								rgzBusy = false
							end
							ClearPedTasksImmediately(plyPed)
						end)
						
				else
					TriggerEvent("pNotify:SendNotification", {
						text = "Tire is fine",
						type = "error",
						queue = "global",
						timeout = 3000,
						layout = "bottomRight"
					})
				end
			end
		else
			TriggerEvent("pNotify:SendNotification", {
				text = "Theres no nearby car",
				type = "error",
				queue = "global",
				timeout = 3000,
				layout = "bottomRight"
			})
		end
	end
	
end)


RegisterNetEvent("rgz_opony:naprawiono")
	AddEventHandler("rgz_opony:naprawiono", function(tireIndex)
		TriggerEvent("pNotify:SendNotification", {
            text = "Somebody replaced your tire",
            type = "success",
            queue = "global",
            timeout = 3000,
            layout = "bottomRight"
          })
		local player = PlayerId()
		local plyPed = GetPlayerPed(player)
		local vehicle = GetVehiclePedIsIn(plyPed, false)
		SetVehicleTyreFixed(vehicle, tireIndex)
end)

function GetClosestVehicleToPlayer()
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.0, 0.0)
	local radius = 3.0
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, radius, 10, plyPed, 7)
	local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
	return vehicle
end

function GetClosestVehicleTire(vehicle)
	local tireBones = tiresCfg2
	local tireIndex = tiresCfg
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local minDistance = 1.0
	local closestTire = nil
	
	for a = 1, #tireBones do
		local bonePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tireBones[a]))
		local distance = Vdist(plyPos.x, plyPos.y, plyPos.z, bonePos.x, bonePos.y, bonePos.z)

		if closestTire == nil then
			if distance <= minDistance then
				closestTire = {bone = tireBones[a], boneDist = distance, bonePos = bonePos, tireIndex = tireIndex[tireBones[a]]}
			end
		else
			if distance < closestTire.boneDist then
				closestTire = {bone = tireBones[a], boneDist = distance, bonePos = bonePos, tireIndex = tireIndex[tireBones[a]]}
			end
		end
	end

	return closestTire
end
function Draw3DText(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
	local scale = (1/dist)*2
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov
   
	if onScreen then
		SetTextScale(0.0*scale, 0.55*scale)
		SetTextFont(0)
		SetTextProportional(1)
		-- SetTextScale(0.0, 0.55)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end

function GetDriverOfVehicle(vehicle)
	local dPed = GetPedInVehicleSeat(vehicle, -1)
	for a = 0, 32 do
		if dPed == GetPlayerPed(a) then
			return a
		end
	end
	return -1
end