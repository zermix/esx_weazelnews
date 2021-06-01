ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_society:registerSociety', 'weazelnews', 'Journaliste', 'society_weazelnews', 'society_weazelnews', 'society_weazelnews', {type = 'private'})

RegisterServerEvent('AnnonceDispoW')
AddEventHandler('AnnonceDispoW', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "~b~Journaliste", '~g~Annonce', 'Le Journaliste est désormais ~g~Disponible!', 'CHAR_LIFEINVADER', 8)
	end
end)

RegisterServerEvent('AnnonceIndispoW')
AddEventHandler('AnnonceIndispoW', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "~b~Journaliste", '~r~Annonce', 'Le Journaliste est désormais ~r~Indisponible!', 'CHAR_LIFEINVADER', 8)
	end
end)

RegisterCommand("cam", function(source, args, raw)
    local src = source
    TriggerClientEvent("Cam:ToggleCam", src)
end)

RegisterCommand("bmic", function(source, args, raw)
    local src = source
    TriggerClientEvent("Mic:ToggleBMic", src)
end)

RegisterCommand("mic", function(source, args, raw)
    local src = source
    TriggerClientEvent("Mic:ToggleMic", src)
end)


RegisterServerEvent('Annonce')
AddEventHandler('Annonce', function(msgCustom)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], "~b~Annonce", '~g~Journaliste', '~b~Annonce : ~n~~s~'..msgCustom, 'CHAR_LIFEINVADER', 20)
	end
end)

RegisterServerEvent('weazelnews:prendreitem')
AddEventHandler('weazelnews:prendreitem', function(itemName, count)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local sourceItem = xPlayer.getInventoryItem(itemName)

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_weazelnews', function(inventory)
        local inventoryItem = inventory.getItem(itemName)

        -- is there enough in the society?
        if count > 0 and inventoryItem.count >= count then

            -- can the player carry the said amount of x item?
            if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
                TriggerClientEvent('esx:showNotification', _source, "~r~Quantité Invalide")
            else
                inventory.removeItem(itemName, count)
                xPlayer.addInventoryItem(itemName, count)
                TriggerClientEvent('esx:showNotification', _source, 'Objet retiré ~g~x'..count..' '..inventoryItem.label)
            end
        else
            TriggerClientEvent('esx:showNotification', _source, "~r~Quantité Invalide")
        end
    end)
end)


RegisterNetEvent('weazelnews:stockitem')
AddEventHandler('weazelnews:stockitem', function(itemName, count)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local sourceItem = xPlayer.getInventoryItem(itemName)

    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_weazelnews', function(inventory)
        local inventoryItem = inventory.getItem(itemName)

        -- does the player have enough of the item?
        if sourceItem.count >= count and count > 0 then
            xPlayer.removeInventoryItem(itemName, count)
            inventory.addItem(itemName, count)
            TriggerClientEvent('esx:showNotification', _source, "Objet déposé ~g~x"..count.." "..inventoryItem.label.."")
        else
            TriggerClientEvent('esx:showNotification', _source, "~r~Quantité Invalide")
        end
    end)
end)


ESX.RegisterServerCallback('weazelnews:inventairejoueur', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items   = xPlayer.inventory

    cb({items = items})
end)

ESX.RegisterServerCallback('weazelnews:prendreitem', function(source, cb)
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_weazelnews', function(inventory)
        cb(inventory.items)
    end)
end)