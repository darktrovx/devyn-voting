local QBCore = exports['qb-core']:GetCoreObject()

local Elections = {}
local VoteLocation = vector4(440.99, -980.35, 30.93, 264.12) -- CHANGE ME


RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Elections = getElections()
    exports['qb-target']:AddCircleZone("vote-target", vector3(VoteLocation.x, VoteLocation.y, VoteLocation.z), 0.3, {
        name="vote-target",
        debugPoly=true,
        useZ = true,
    }, {
        options = {
            {
                type = "client",
                event = "vote:openMenu",
                icon = "fas fa-circle",
                label = "Vote",
            },
        },
        distance = 2.5
    })
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    Elections = {}
    exports['qb-target']:RemoveZone("vote-target")
end)

RegisterNetEvent("vote:updateElections", function(update)
    print("[Elections]: Updated Elections")
    Elections = update
end)

RegisterNetEvent("vote:openMenu", function(data)
    if data["admin"] == nil then data["admin"] = false end
    if Elections then
        SendNUIMessage({
            action = "open",
            admin = data["admin"],
            elections = Elections,
        })
        SetNuiFocus(true, true)
    else 
        QBCore.Functions.Notify("There are no elections currently running!", "error")
    end
end)

function getElections()
    local elections = promise.new()
    QBCore.Functions.TriggerCallback("elections:getElections", function(result)
        elections:resolve(result)
    end)
    return Citizen.Await(elections)
end


RegisterNUICallback('vote', function(votes)
    TriggerServerEvent("vote:submit", votes["votes"])
    SetNuiFocus(false, false)
end)


RegisterNUICallback('admin', function()
    local votes = promise.new()
    QBCore.Functions.TriggerCallback("elections:admin", function(result)
        votes:resolve(result)
    end)
    local data = Citizen.Await(votes)
    for k,v in pairs(data) do
        print("POSITION: "..k)
        for k2,v2 in pairs(v) do 
            print("Name: "..k2, "Votes: "..v2)
        end
    end
end)

RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
end)