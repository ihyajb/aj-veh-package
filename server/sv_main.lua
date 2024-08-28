lib.versionCheck('ihyajb/aj-veh-package')
local Packages = {}
local Config = require'shared.config'

local DoesEntityExist = DoesEntityExist
local GetEntityPopulationType = GetEntityPopulationType
local GetEntityType = GetEntityType
local GetVehicleType = GetVehicleType
local GetEntityModel = GetEntityModel
local GetPedInVehicleSeat = GetPedInVehicleSeat
local ox_inventory = exports.ox_inventory
AddEventHandler('entityCreated', function(handle)
    if #Packages == Config.maxPackages then return end
    if not DoesEntityExist(handle) then return end
    if GetEntityPopulationType(handle) ~= 2 then return end
    if GetEntityType(handle) ~= 2 then return end
    if GetVehicleType(handle) ~= 'automobile' then return end
    if GetPedInVehicleSeat(handle, -1) > 0 then return end
    if Entity(handle).state.hasPackage then return end
    if Config.blacklistedModels[GetEntityModel(handle)] then return end
    if math.random(1, Config.percent) ~= 1 then return end

    TriggerClientEvent('aj-veh-package:client:StartRandomPackage', NetworkGetEntityOwner(handle), NetworkGetNetworkIdFromEntity(handle))
end)

local function FindAndDelete(object)
    if not DoesEntityExist(object) then return end
    DeleteEntity(object)
    for i = 1, #Packages do
        if Packages[i] == object then
            table.remove(Packages, i)
            break
        end
    end
end

lib.callback.register('aj-veh-package:server:CreatePackage', function(source, vNetID)
    local vehicle = NetworkGetEntityFromNetworkId(vNetID)
    local coords = GetEntityCoords(vehicle)
    local object = CreateObjectNoOffset(Config.packageProps[math.random(#Config.packageProps)], coords.x, coords.y, coords.z - 5, true, true, false)
    Packages[#Packages+1] = object
    while not DoesEntityExist(object) do Wait(0) end
    Entity(vehicle).state:set('hasPackage', object, true)
    CreateThread(function()
        while DoesEntityExist(object) do
            Wait(1000)
            if not DoesEntityExist(vehicle) then
                lib.print.debug('Vehicle poofed, Deleting Object!')
                FindAndDelete(object)
                break
            end
        end
    end)
    return NetworkGetNetworkIdFromEntity(object)
end)

RegisterNetEvent('aj-veh-package:server:SearchedPackage', function(object, vNetID)
    local src = source
    local veh = NetworkGetEntityFromNetworkId(vNetID)
    if not Entity(veh).state.hasPackage then return end
    if not DoesEntityExist(object) then return end
    FindAndDelete(object)
    Entity(veh).state:set('hasPackage', nil, true)
    local rewardItem = Config.rewardItems[math.random(#Config.rewardItems)]
    ox_inventory:AddItem(src, Config.rewardItems[rewardItem].item, math.random(Config.rewardItems[rewardItem].minAmount, Config.rewardItems[rewardItem].maxAmount))
end)

AddEventHandler('onResourceStop', function(r)
    if cache.resource ~= r then return end
    for i = 1, #Packages do
        if DoesEntityExist(Packages[i]) then
            DeleteEntity(Packages[i])
        end
    end
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        if DoesEntityExist(vehicles[i]) then
            DeleteEntity(vehicles[i])
        end
    end
end)