local Config = require'shared.config'

local Seats = {
    'seat_pside_f',
    'seat_dside_r',
    'seat_pside_r'
}

local function GetVehicleDoorCount(entity)
    local doorCount = 0
	if GetEntityBoneIndexByName(entity, 'door_pside_f') ~= -1 then doorCount += 1 end
	if GetEntityBoneIndexByName(entity, 'door_pside_r') ~= -1 then doorCount += 1 end
	if GetEntityBoneIndexByName(entity, 'door_dside_f') ~= -1 then doorCount += 1 end
	if GetEntityBoneIndexByName(entity, 'door_dside_r') ~= -1 then doorCount += 1 end
    return doorCount
end

RegisterNetEvent('aj-veh-package:client:StartRandomPackage', function(vNetID)
    local entity = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(vNetID) then return NetworkGetEntityFromNetworkId(vNetID) end
    end, 'Failed to get vehicle', 10000)
    local totalSeats = GetVehicleDoorCount(entity) - 1
    local selectedSeat = Seats[math.random(1, totalSeats)]
    local boneID = GetEntityBoneIndexByName(entity, selectedSeat)
    local oNetID = lib.callback.await('aj-veh-package:server:CreatePackage', false, vNetID)
    local package = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(oNetID) then return NetworkGetEntityFromNetworkId(oNetID) end
    end, 'Failed to get package', 10000)

    --! This is prob bad code but ¯\_(ツ)_/¯
    while DoesEntityExist(entity) and not NetworkHasControlOfEntity(entity) do
        NetworkRequestControlOfEntity(entity)
        Wait(0)
    end
    while DoesEntityExist(package) and not NetworkHasControlOfEntity(package) do
        NetworkRequestControlOfEntity(package)
        Wait(0)
    end

    if Config.debug then
        -- SetEntityDrawOutline(entity, true)
        SetEntityDrawOutline(package, true)
        SetEntityDrawOutlineShader(1)
    end
    SetDisableFragDamage(package, true)
    SetEntityCollision(package, false, false)
    AttachEntityToEntity(package, entity, boneID, 0.0, 0.0, 0.0, 0.0, 0.0, math.random(0, 359) + 0.0, 0.0, false, false, false, false, 2, true, false)
end)

lib.onCache('vehicle', function(veh)
    if not veh then return end
    if Entity(veh).state.hasPackage then
        lib.print.debug('This vehicle has a package!')
        Wait(0)
        while cache.vehicle do
            Wait(0)
            if IsControlJustPressed(0, 38) then --E
                if lib.progressCircle({
                    duration = Config.SearchTime,
                    canCancel = true,
                    position = 'bottom',
                    disable = {
                        car = true,
                        move = true
                    },
                    label = 'Searching'
                }) then
                    TriggerServerEvent('aj-veh-package:server:SearchedPackage', Entity(cache.vehicle).state.hasPackage, NetworkGetNetworkIdFromEntity(cache.vehicle))
                    break
                end
            end
        end
    end
end)