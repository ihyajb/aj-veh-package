lib.versionCheck('ihyajb/aj-veh-package')
local Config = require'shared.config'
local QBCore = exports['qb-core']:GetCoreObject()

local DoesEntityExist = DoesEntityExist
local GetEntityPopulationType = GetEntityPopulationType
local GetEntityType = GetEntityType
local GetVehicleType = GetVehicleType
local GetEntityModel = GetEntityModel
local GetPedInVehicleSeat = GetPedInVehicleSeat
local ox_inventory = exports.ox_inventory
AddEventHandler('entityCreated', function(handle)
    if not DoesEntityExist(handle) then return end
    if GetEntityPopulationType(handle) ~= 2 then return end
    if GetEntityType(handle) ~= 2 then return end
    if GetVehicleType(handle) ~= 'automobile' then return end
    if GetPedInVehicleSeat(handle, -1) > 0 then return end
    if Entity(handle).state.hasPackage then return end
    if Config.blacklistedModels[GetEntityModel(handle)] then return end
    if math.random(1, Config.percent) ~= 1 then return end

    local success, boneID = lib.callback.await('aj-veh-package:client:ValidateVehicle', NetworkGetEntityOwner(handle), NetworkGetNetworkIdFromEntity(handle))
    if not success then return end
    local data = {
        model = Config.packageProps[math.random(#Config.packageProps)],
        boneID = boneID,
        rotation = math.random(0, 360) + 0.0
    }
    Entity(handle).state:set('loadPackage', data, true)
    Entity(handle).state:set('hasPackage', true, true)
    lib.print.debug('Adding Package to vehicle!')
end)

RegisterNetEvent('aj-veh-package:server:SearchedPackage', function()
    local src = source
    local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)
    if veh == 0 or not DoesEntityExist(veh) then return end
    if not Entity(veh).state.hasPackage then return end
    Entity(veh).state:set('loadPackage', nil, true)
    Entity(veh).state:set('hasPackage', nil, true)
    if Config.inventory == "ox" then
        local rewardItem = Config.rewardItems[math.random(#Config.rewardItems)]
        ox_inventory:AddItem(src, rewardItem.item, math.random(rewardItem.minAmount, rewardItem.maxAmount))
    elseif Config.inventory == "qb" then
        local rewardItem = Config.rewardItems[math.random(#Config.rewardItems)]
        local rewardChance = math.random(rewardItem.minAmount, rewardItem.maxAmount)
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddItem(rewardItem.item, rewardChance, false)
        TriggerClientEvent("inventory:client:ItemBox", Player.PlayerData.source, QBCore.Shared.Items[rewardItem.item], "add", rewardChance)
    else
        lib.print.error('"Config.inventory" is not setup correctly!')
    end
end)

AddEventHandler('onResourceStop', function(r)
    if cache.resource ~= r then return end
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        if DoesEntityExist(vehicles[i]) then
            Entity(vehicles[i]).state:set('loadPackage', nil, true)
            Entity(vehicles[i]).state:set('hasPackage', nil, true)
            -- DeleteEntity(vehicles[i]) --! Use for debug to refresh parked vehicle pool
        end
    end
end)
