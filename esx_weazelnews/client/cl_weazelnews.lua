ESX                           = nil
local PlayerData              = {}


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()

    AddTextComponentString(text)
    DrawText(_x, _y)
end

Citizen.CreateThread(function()
    local weazelmap = AddBlipForCoord(-591.6608, -929.8761, 23.8696)

    SetBlipSprite(weazelmap, 135)
    SetBlipColour(weazelmap, 17)
    SetBlipScale(weazelmap, 0.9)
    SetBlipAsShortRange(weazelmap, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Journaliste")
    EndTextCommandSetBlipName(weazelmap)
end)

function RangerVehW(veh)
    local playerPed = GetPlayerPed(-1)
    local veh = GetVehiclePedIsIn(playerPed, false)
    
	if IsPedInAnyVehicle(GetPlayerPed(-1), true) then 

        ESX.Game.DeleteVehicle(veh)
        ESX.ShowNotification("~g~Vous avez bien rangé votre véhicule.")
    end
end

--GARAGE--

openedGarageMenuW = false
RMenu.Add("weazelnews", "garagew_main", RageUI.CreateMenu("Garage Journaliste", "Garage Journaliste"))
RMenu:Get("weazelnews", "garagew_main"):SetRectangleBanner(0, 128, 237)
RMenu:Get("weazelnews", "garagew_main").Closed = function()

	openedGarageMenuW = false

end

--ACTION--

openedActionMenuW = false
RMenu.Add("weazelnews", "actionw_main", RageUI.CreateMenu("Actions Journaliste", "Actions Journaliste"))
RMenu:Get("weazelnews", "actionw_main"):SetRectangleBanner(0, 128, 237)
RMenu:Get("weazelnews", "actionw_main").Closed = function()

	openedActionMenuW = false

end

--COFFRE--

openedCoffreMenuW = false
RMenu.Add("weazelnews", "coffrew_main", RageUI.CreateMenu("Coffre Journaliste", "Coffre Journaliste"))
RMenu:Get("weazelnews", "coffrew_main"):SetRectangleBanner(0, 128, 237)
RMenu:Get("weazelnews", "coffrew_main").Closed = function()

	openedCoffreMenuW = false

end

--MENU F6--

openedF6MenuW = false
RMenu.Add("weazelnews", "menuf6_mainw", RageUI.CreateMenu("Menu Journaliste", "Menu Journaliste"))
RMenu:Get("weazelnews", "menuf6_mainw"):SetRectangleBanner(0, 128, 237)
RMenu:Get("weazelnews", "menuf6_mainw").Closed = function()

    openedF6MenuW = false

end

RMenu.Add("weazelnews", "interaction_mainw", RageUI.CreateSubMenu(RMenu:Get("weazelnews", "menuf6_mainw"), "Matériel", nil))
RMenu:Get("weazelnews", "interaction_mainw").Closed = function()end

RMenu.Add("weazelnews", "annonce_mainw", RageUI.CreateSubMenu(RMenu:Get("weazelnews", "menuf6_mainw"), "Annonces", nil))
RMenu:Get("weazelnews", "annonce_mainw").Closed = function()end

openedRangerMenuW = false

RegisterKeyMapping("openJournalisteMenu", "TOUCHE MENU JOURNALISTE", 'keyboard', 'F6')

RegisterCommand("openJournalisteMenu", function(source)
    if ESX.PlayerData.job.name == "weazelnews" then
        openF6MenuW()
    end
end)

function OpenBillingMenuW()

	ESX.UI.Menu.Open(
	  'dialog', GetCurrentResourceName(), 'billing',
	  {
		title = "Facture"
	  },
	  function(data, menu)
	  
		local amount = tonumber(data.value)
		local player, distance = ESX.Game.GetClosestPlayer()
  
		if player ~= -1 and distance <= 3.0 then
  
		  menu.close()
		  if amount == nil then
			  ESX.ShowNotification("~r~Problèmes~s~: Montant invalide")
		  else
			local playerPed        = GetPlayerPed(-1)
			TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
			Citizen.Wait(4000)
			  TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_weazelnews', ('weazelnews'), amount)
			  Citizen.Wait(100)
			  ESX.ShowNotification("~r~Vous avez bien envoyer la facture")
		  end
  
		else
		  ESX.ShowNotification("~r~Problèmes~s~: Aucun joueur à proximitée")
		end
  
	  end,
	  function(data, menu)
		  menu.close()
	  end
    )
end

function OpenGetStocksweazelnewsMenu()
    ESX.TriggerServerCallback('weazelnews:prendreitem', function(items)
        local elements = {}

        for i=1, #items, 1 do
            table.insert(elements, {
                label = 'x' .. items[i].count .. ' ' .. items[i].label,
                value = items[i].name
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            css      = 'Journaliste',
            title    = 'Journaliste Stockage',
            align    = 'top-left',
            elements = elements
        }, function(data, menu)
            local itemName = data.current.value

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
                css      = 'Journaliste',
                title = 'quantité'
            }, function(data2, menu2)
                local count = tonumber(data2.value)

                if not count then
                    ESX.ShowNotification('Quantité Invalide')
                else
                    menu2.close()
                    menu.close()
                    TriggerServerEvent('weazelnews:prendreitem', itemName, count)

                    Citizen.Wait(300)
                    OpenGetStocksweazelnewsMenu()
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end, function(data, menu)
            menu.close()
        end)
    end)
end

function OpenPutStocksweazelnewsMenu()
    ESX.TriggerServerCallback('weazelnews:inventairejoueur', function(inventory)
        local elements = {}

        for i=1, #inventory.items, 1 do
            local item = inventory.items[i]

            if item.count > 0 then
                table.insert(elements, {
                    label = item.label .. ' x' .. item.count,
                    type = 'item_standard',
                    value = item.name
                })
            end
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            css      = 'Journaliste',
            title    = 'inventaire',
            align    = 'top-left',
            elements = elements
        }, function(data, menu)
            local itemName = data.current.value

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
                css      = 'Journaliste',
                title = 'quantité'
            }, function(data2, menu2)
                local count = tonumber(data2.value)

                if not count then
                    ESX.ShowNotification('Quantité Invalide')
                else
                    menu2.close()
                    menu.close()
                    TriggerServerEvent('weazelnews:stockitem', itemName, count)

                    Citizen.Wait(300)
                    OpenPutStocksweazelnewsMenu()
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end, function(data, menu)
            menu.close()
        end)
    end)
end

function input(TextEntry, ExampleText, MaxStringLenght, isValueInt)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        if isValueInt then
            local isNumber = tonumber(result)
            if isNumber then
                return result
            else
                return nil
            end
        end

        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

function openF6MenuW()
    if openedF6MenuW then
        RageUI.Visible(RMenu:Get("weazelnews", "menuf6_mainw"), false)
        openedF6MenuW = false
        return
    else
        openedF6MenuW = true
        RageUI.Visible(RMenu:Get("weazelnews", "menuf6_mainw"), true)
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
        
            while ESX.GetPlayerData().job == nil do
                Citizen.Wait(10)
            end
        
            ESX.PlayerData = ESX.GetPlayerData()
            while openedF6MenuW do
                Wait(1.0)

                local annonceBuilder = {}

                RageUI.IsVisible(RMenu:Get("weazelnews", "menuf6_mainw"), true, false, false, function()
                    
                    RageUI.Separator("↓ ~b~Actions~s~ ↓")

                    RageUI.ButtonWithStyle("~b~→ 📄 Facture", "~b~Description :~s~ Mettre une ~b~Facture", {RightLabel = "~b~"}, true, function(h,a,s)
                        if s then
                            OpenBillingMenuW()
                        end
                    end, RMenu:Get("weazelnews", "menuf6_mainw"))

                    RageUI.ButtonWithStyle("~b~→ 🎥 Matériel Journaliste", "~b~Description :~s~ ~b~Matériel Journaliste", {RightLabel = "~b~"}, true, function(h,a,s)
                    end, RMenu:Get("weazelnews", "interaction_mainw"))

                    RageUI.ButtonWithStyle("~b~→ 🚨 Annonces", "~b~Description :~s~ Annonces ~b~Journaliste", {RightLabel = "~b~"}, true, function(h,a,s)
                    end, RMenu:Get("weazelnews", "annonce_mainw"))

                end)

                RageUI.IsVisible(RMenu:Get("weazelnews", "interaction_mainw"), true, false, false, function()

                    RageUI.Separator("↓ ~b~Matériel Journaliste~s~ ↓")

                    RageUI.ButtonWithStyle("~b~→ 🎥 Caméra", "~b~Description :~s~ Prendre la ~b~Caméra", {RightLabel = "~b~"}, true, function(h,a,s)
                        if s then
                            ExecuteCommand('cam')
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("~b~→ 🎙️ Micro", "~b~Description :~s~ Prendre le ~b~Micro", {RightLabel = "~b~"}, true, function(h,a,s)
                        if s then
                            TriggerEvent('Mic:ToggleBMic')
                        end
                    end)
                    DeleteEntity(cam1)
                    RageUI.Separator("↓ ~r~Retour~s~ ↓")

                    RageUI.ButtonWithStyle("~r~→ Retour", "~r~Description :~s~ ~r~Retour", {RightLabel = "~b~"}, true, function(h,a,s)
                    end, RMenu:Get("weazelnews", "menuf6_mainw"))

                end)

                RageUI.IsVisible(RMenu:Get("weazelnews", "annonce_mainw"), true, false, false, function()

                    RageUI.Separator("↓ ~b~Intéractions Véhicules~s~ ↓")

                    RageUI.ButtonWithStyle("~g~→ ✅ Disponible", "~g~Description :~s~ Journaliste ~g~Disponible", {RightLabel = "~b~"}, true, function(h,a,s)
                        if s then
                            TriggerServerEvent('AnnonceDispoW')
                        end
                    end)

                    RageUI.ButtonWithStyle("~r~→ ❌ Indisponible", "~r~Description :~s~ Journaliste ~r~Indisponible", {RightLabel = "~b~"}, true, function(h,a,s)
                        if s then
                            TriggerServerEvent('AnnonceIndispoW')
                        end
                    end)

                    RageUI.ButtonWithStyle("~b~→📢 Faire une Annonce", "~b~Description :~s~ Faire une ~B~Annonce Personnalisée", {RightLabel = "~b~"}, true, function(h,a,s)
                        if s then
                            msgCustom = input("Annonce", "", 77, false)
                            if msgCustom then
                                annonceBuilder.description = result
                                ESX.ShowNotification("~g~Annonce correctement définie !")
                            end
                            TriggerServerEvent('Annonce', msgCustom)
                        end
                    end)

                    RageUI.Separator("↓ ~r~Retour~s~ ↓")

                    RageUI.ButtonWithStyle("~r~→ Retour", "~r~Description :~s~ ~r~Retour", {RightLabel = "~b~"}, true, function(h,a,s)
                    end, RMenu:Get("weazelnews", "menuf6_mainw"))

                end)
            end
        end)
    end
end

function openActionMenuW()
    if openedActionMenuW then
        RageUI.Visible(RMenu:Get("weazelnews", "actionw_main"), false)
        openedActionMenuW = false
        return
    else
        openedActionMenuW = true
        RageUI.Visible(RMenu:Get("weazelnews", "actionw_main"), true)
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
        
            while ESX.GetPlayerData().job == nil do
                Citizen.Wait(10)
            end
        
            ESX.PlayerData = ESX.GetPlayerData()
            while openedActionMenuW do
                Wait(1.0)

                local myCoords = GetEntityCoords(PlayerPedId())
                local dist = GetDistanceBetweenCoords(myCoords, ConfigWeazelNews.Pos.Action, true)

                if dist > 2.5 then
                    RageUI.CloseAll()
                    openedActionMenuW = false
                else
                    RageUI.IsVisible(RMenu:Get("weazelnews", "actionw_main"), true, false, false, function()
                        
                        RageUI.Separator("↓ ~b~Actions~s~ ↓")

                        RageUI.ButtonWithStyle("📥 Dépot", "~b~Description :~s~ Déposer de l'argent dans l'entreprise'", {RightLabel = "~b~→→"}, true, function(Hovered, Active, Selected)
                            if (Selected) then
                                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'deposit_money_amount_' .. 'weazelnews',
                                {
                                    title = ('Montant')
                                }, function(data, menu)
                    
                                    local amount = tonumber(data.value)
                    
                                    if amount == nil then
                                        ESX.ShowNotification('Montant invalide')
                                    else
                                        menu.close()
                                        TriggerServerEvent('esx_society:depositMoney', 'weazelnews', amount)
                                        RefreshweazelnewsMoney()
                                    end
                                end)
                            end
                        end)

                        RageUI.ButtonWithStyle("📤 Retrait", "~b~Description :~s~ Retirer de l'argent de l'entreprise", {RightLabel = "~b~→→"}, true, function(Hovered, Active, Selected)
                            if (Selected) then
                                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_society_money_amount_' .. 'weazelnews',
                                {
                                    title = ('Montant')
                                }, function(data, menu)
                                local amount = tonumber(data.value)
            
                                    if amount == nil then
                                        ESX.ShowNotification('Montant invalide')
                                    else
                                        menu.close()
                                        TriggerServerEvent('esx_society:withdrawMoney', 'weazelnews', amount)
                                        RefreshweazelnewsMoney()
                                    end
                                end)
                            end
                        end)

                    end)
                end
            end
        end)
    end
end

function openCoffreMenuW()
    if openedCoffreMenuW then
        RageUI.Visible(RMenu:Get("weazelnews", "coffrew_main"), false)
        openedCoffreMenuW = false
        return
        Wait(0)
    else
        openedCoffreMenuW = true
        RageUI.Visible(RMenu:Get("weazelnews", "coffrew_main"), true)
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
        
            while ESX.GetPlayerData().job == nil do
                Citizen.Wait(10)
            end
        
            ESX.PlayerData = ESX.GetPlayerData()
            while openedCoffreMenuW do
                Wait(1.0)

                local myCoords = GetEntityCoords(PlayerPedId())
                local dist = GetDistanceBetweenCoords(myCoords, ConfigWeazelNews.Pos.Coffre, true)
                
                if dist > 2.5 then
                    RageUI.CloseAll()
                    openedCoffreMenuW = false
                else
                    RageUI.IsVisible(RMenu:Get("weazelnews", "coffrew_main"), true, false, false, function()

                        RageUI.ButtonWithStyle("📥 Déposer objet", "~b~Description : ~s~Pour déposer un ~b~Objet.", {RightLabel = "→"},true, function(Hovered, Active, Selected)
                            if (Selected) then   
                                OpenPutStocksweazelnewsMenu()
                                RageUI.CloseAll()
                                openedCoffreMenuW = false
                            end
                        end)

                        RageUI.ButtonWithStyle("📤Prendre objet", "~b~Description : ~s~Pour prendre un ~b~Objet.", {RightLabel = "→"},true, function(Hovered, Active, Selected)
                            if (Selected) then   
                                OpenGetStocksweazelnewsMenu()
                                RageUI.CloseAll()
                                openedCoffreMenuW = false
                            end
                        end)

                    end)
                    
                end
            end
        end)
        Wait(1200)
    end
end

function openGarageMenuW()
    local pos = GetEntityCoords(PlayerPedId())

    if openedGarageMenuW then
        RageUI.Visible(RMenu:Get("weazelnews", "garagew_main"), false)
        openedGarageMenuW = false
        return
    else
        openedGarageMenuW = true
        RageUI.Visible(RMenu:Get("weazelnews", "garagew_main"), true)
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
        
            while ESX.GetPlayerData().job == nil do
                Citizen.Wait(10)
            end
        
            ESX.PlayerData = ESX.GetPlayerData()
            while openedGarageMenuW do
                Wait(1.0)

                local myCoords = GetEntityCoords(PlayerPedId())
                local dist = GetDistanceBetweenCoords(myCoords, ConfigWeazelNews.Pos.Garage, true)

                if dist > 2.5 then
                    RageUI.CloseAll()
                    openedGarageMenuW = false
                else
                    RageUI.IsVisible(RMenu:Get("weazelnews", "garagew_main"), true, false, false, function()
                        RageUI.Separator("↓ ~b~Véhicules~s~ ↓")

                        RageUI.ButtonWithStyle("Camionette Journaliste", "~b~Description :~s~ Sortir une ~b~Camionette", {RightLabel = "~b~→→"}, true, function(h,a,s)
                            if s then
                                local model = GetHashKey("Burrito3")
                                    RequestModel(model)
                                    while not HasModelLoaded(model) do Citizen.Wait(10) end
                                    local pos = GetEntityCoords(PlayerPedId())
                                    local spawnPos = vector3(ConfigWeazelNews.Pos.Spawn)
                                    local vehicle = CreateVehicle(model, spawnPos.x, spawnPos.y, spawnPos.z, 175.0, true, false)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                    RageUI.CloseAll()
                                    openedGarageMenuW = false
                            end
                        end, RMenu:Get("weazelnews", "garagew_main"))
                        
                    end)
                end
            end
        end)
    end
end

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()

    while true do
        local myCoords = GetEntityCoords(PlayerPedId(), true)
        local noFps = false

        if ESX.PlayerData.job and ESX.PlayerData.job.name == "weazelnews" then

            if not openedGarageMenuW then
                if #(myCoords-ConfigWeazelNews.Pos.Garage) < 1.5 then
                    noFps = true
                    AddTextEntry("GARAGE", "Appuyez sur [~b~E~s~] pour accéder au ~b~Garage")
                    DisplayHelpTextThisFrame("GARAGE", false)
                    if IsControlJustReleased(0,38) then
                        openGarageMenuW()
                    end
                    DrawMarker(22, ConfigWeazelNews.Pos.Garage, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 128, 237, 155, 55555, false, true, 2, false, false, false, false)
                elseif #(myCoords-ConfigWeazelNews.Pos.Garage) < 5.5 then
                    noFps = true
                    DrawMarker(22, ConfigWeazelNews.Pos.Garage, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 128, 237, 155, 55555, false, true, 2, false, false, false, false)
                end
            end

            if not openedRangerMenuW then
                if #(myCoords-ConfigWeazelNews.Pos.Ranger) < 1.5 then
                    noFps = true
                    AddTextEntry("RANGER", "Appuyez sur [~b~E~s~] pour ranger votre ~b~Véhicule")
                    DisplayHelpTextThisFrame("RANGER", false)
                    if IsControlJustReleased(0,38) then
                        RangerVehW()
                    end
                    DrawMarker(22, ConfigWeazelNews.Pos.Ranger, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 128, 237, 155, 55555, false, true, 2, false, false, false, false)
                elseif #(myCoords-ConfigWeazelNews.Pos.Ranger) < 5.5 then
                    noFps = true
                    DrawMarker(22, ConfigWeazelNews.Pos.Ranger, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 128, 237, 155, 55555, false, true, 2, false, false, false, false)
                end
            end

            if not openedActionMenuW then
                if #(myCoords-ConfigWeazelNews.Pos.Action) < 1.5 and ESX.PlayerData.job.grade_name == 'boss' then
                    noFps = true
                    AddTextEntry("ACTIONS", "Appuyez sur [~b~E~s~] pour accéder aux ~b~Actions Patrons")
                    DisplayHelpTextThisFrame("ACTIONS", false)
                    if IsControlJustReleased(0,38) then
                        openActionMenuW()
                    end
                    DrawMarker(22, ConfigWeazelNews.Pos.Action, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 128, 237, 155, 55555, false, true, 2, false, false, false, false)
                elseif #(myCoords-ConfigWeazelNews.Pos.Action) < 5.5 then
                    noFps = true
                    DrawMarker(22, ConfigWeazelNews.Pos.Action, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 128, 237, 155, 55555, false, true, 2, false, false, false, false)
                end
            end

            if not openedCoffreMenuW then
                if #(myCoords-ConfigWeazelNews.Pos.Coffre) < 1.5 then
                    noFps = true
                    AddTextEntry("COFFRE", "Appuyez sur [~b~E~s~] pour accéder au ~b~Coffre")
                    DisplayHelpTextThisFrame("COFFRE", false)
                    if IsControlJustReleased(0,38) then
                        openCoffreMenuW()
                    end
                    DrawMarker(22, ConfigWeazelNews.Pos.Coffre, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 128, 237, 155, 55555, false, true, 2, false, false, false, false)
                elseif #(myCoords-ConfigWeazelNews.Pos.Coffre) < 5.5 then
                    noFps = true
                    DrawMarker(22, ConfigWeazelNews.Pos.Coffre, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 128, 237, 155, 55555, false, true, 2, false, false, false, false)
                end
            end

        end

        if noFps then
            Wait(1)
        else
            Wait(1200)
        end
    end
end)


local holdingCam = false
local usingCam = false
local holdingMic = false
local usingMic = false
local holdingBmic = false
local usingBmic = false
local camModel = "prop_v_cam_01"
local camanimDict = "missfinale_c2mcs_1"
local camanimName = "fin_c2_mcs_1_camman"
local micModel = "p_ing_microphonel_01"
local micanimDict = "missheistdocksprep1hold_cellphone"
local micanimName = "hold_cellphone"
local bmicModel = "prop_v_bmike_01"
local bmicanimDict = "missfra1"
local bmicanimName = "mcs2_crew_idle_m_boom"
local bmic_net = nil
local mic_net = nil
local cam_net = nil
local UI = { 
	x =  0.000 ,
	y = -0.001 ,
},

---------------------------------------------------------------------------
-- Toggling Cam --
---------------------------------------------------------------------------
RegisterNetEvent("Cam:ToggleCam")
AddEventHandler("Cam:ToggleCam", function()
    if not holdingCam then
        RequestModel(GetHashKey(camModel))
        while not HasModelLoaded(GetHashKey(camModel)) do
            Citizen.Wait(100)
        end
		
        local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
        local camspawned = CreateObject(GetHashKey(camModel), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
        Citizen.Wait(1000)
        local netid = ObjToNet(camspawned)
        SetNetworkIdExistsOnAllMachines(netid, true)
        NetworkSetNetworkIdDynamic(netid, true)
        SetNetworkIdCanMigrate(netid, false)
        AttachEntityToEntity(camspawned, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(GetPlayerPed(PlayerId()), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
        TaskPlayAnim(GetPlayerPed(PlayerId()), camanimDict, camanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
        cam_net = netid
        holdingCam = true
		DisplayNotification(--[["To enter News cam press ~INPUT_PICKUP~ \n]]"Pour entrer dans le mode Cinématique, appuyez sur ~INPUT_INTERACTION_MENU~")
    else
        ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
        DetachEntity(NetToObj(cam_net), 1, 1)
        DeleteEntity(NetToObj(cam_net))
        cam_net = nil
        holdingCam = false
        usingCam = false
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if holdingCam then
			while not HasAnimDictLoaded(camanimDict) do
				RequestAnimDict(camanimDict)
				Citizen.Wait(100)
			end

			if not IsEntityPlayingAnim(PlayerPedId(), camanimDict, camanimName, 3) then
				TaskPlayAnim(GetPlayerPed(PlayerId()), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
				TaskPlayAnim(GetPlayerPed(PlayerId()), camanimDict, camanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
			end
				
			DisablePlayerFiring(PlayerId(), true)
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0, 44,  true) -- INPUT_COVER
			DisableControlAction(0,37,true) -- INPUT_SELECT_WEAPON
			SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey("WEAPON_UNARMED"), true)
		end
	end
end)

---------------------------------------------------------------------------
-- Cam Functions --
---------------------------------------------------------------------------

local fov_max = 70.0
local fov_min = 5.0
local zoomspeed = 10.0
local speed_lr = 8.0
local speed_ud = 8.0

local camera = false
local fov = (fov_max+fov_min)*0.5

---------------------------------------------------------------------------
-- Movie Cam --
---------------------------------------------------------------------------

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(10)

		local lPed = GetPlayerPed(-1)
		local vehicle = GetVehiclePedIsIn(lPed)

		if holdingCam and IsControlJustReleased(1, 244) then
			movcamera = true

			SetTimecycleModifier("default")

			SetTimecycleModifierStrength(0.3)
			
			local scaleform = RequestScaleformMovie("security_camera")

			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(10)
			end


			local lPed = GetPlayerPed(-1)
			local vehicle = GetVehiclePedIsIn(lPed)
			local cam1 = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

			AttachCamToEntity(cam1, lPed, 0.0,0.0,1.0, true)
			SetCamRot(cam1, 2.0,1.0,GetEntityHeading(lPed))
			SetCamFov(cam1, fov)
			RenderScriptCams(true, false, 0, 1, 0)
			PushScaleformMovieFunction(scaleform, "security_camera")
			PopScaleformMovieFunctionVoid()

			while movcamera and not IsEntityDead(lPed) and (GetVehiclePedIsIn(lPed) == vehicle) and true do
				if IsControlJustPressed(0, 177) then
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					movcamera = false
				end
				
				SetEntityRotation(lPed, 0, 0, new_z,2, true)

				local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
				CheckInputRotation(cam1, zoomvalue)

				HandleZoom(cam1)
				HideHUDThisFrame()

				drawRct(UI.x + 0.0, 	UI.y + 0.0, 1.0,0.15,0,0,0,255) -- Top Bar
				DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
				drawRct(UI.x + 0.0, 	UI.y + 0.85, 1.0,0.16,0,0,0,255) -- Bottom Bar
				
				local camHeading = GetGameplayCamRelativeHeading()
				local camPitch = GetGameplayCamRelativePitch()
				if camPitch < -70.0 then
					camPitch = -70.0
				elseif camPitch > 42.0 then
					camPitch = 42.0
				end
				camPitch = (camPitch + 70.0) / 112.0
				
				if camHeading < -180.0 then
					camHeading = -180.0
				elseif camHeading > 180.0 then
					camHeading = 180.0
				end
				camHeading = (camHeading + 180.0) / 360.0
				
				Citizen.InvokeNative(0xD5BB4025AE449A4E, GetPlayerPed(-1), "Pitch", camPitch)
				Citizen.InvokeNative(0xD5BB4025AE449A4E, GetPlayerPed(-1), "Heading", camHeading * -1.0 + 1.0)
				
				Citizen.Wait(10)
			end

			movcamera = false
			ClearTimecycleModifier()
			fov = (fov_max+fov_min)*0.5
			RenderScriptCams(false, false, 0, 1, 0)
			SetScaleformMovieAsNoLongerNeeded(scaleform)
			DestroyCam(cam1, false)
			SetNightvision(false)
			SetSeethrough(false)
		end
	end
end)

---------------------------------------------------------------------------
-- News Cam --
---------------------------------------------------------------------------

-- Citizen.CreateThread(function()
-- 	while true do

-- 		Citizen.Wait(10)

-- 		local lPed = GetPlayerPed(-1)
-- 		local vehicle = GetVehiclePedIsIn(lPed)

-- 		if holdingCam and IsControlJustReleased(1, 38) then
-- 			newscamera = true

-- 			SetTimecycleModifier("default")

-- 			SetTimecycleModifierStrength(0.3)
			
-- 			local scaleform = RequestScaleformMovie("security_camera")
-- 			local scaleform2 = RequestScaleformMovie("breaking_news")


-- 			while not HasScaleformMovieLoaded(scaleform) do
-- 				Citizen.Wait(10)
-- 			end
-- 			while not HasScaleformMovieLoaded(scaleform2) do
-- 				Citizen.Wait(10)
-- 			end


-- 			local lPed = GetPlayerPed(-1)
-- 			local vehicle = GetVehiclePedIsIn(lPed)
-- 			local cam2 = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

-- 			AttachCamToEntity(cam2, lPed, 0.0,0.0,1.0, true)
-- 			SetCamRot(cam2, 2.0,1.0,GetEntityHeading(lPed))
-- 			SetCamFov(cam2, fov)
-- 			RenderScriptCams(true, false, 0, 1, 0)
-- 			PushScaleformMovieFunction(scaleform, "SET_CAM_LOGO")
-- 			PushScaleformMovieFunction(scaleform2, "breaking_news")
-- 			PopScaleformMovieFunctionVoid()

-- 			while newscamera and not IsEntityDead(lPed) and (GetVehiclePedIsIn(lPed) == vehicle) and true do
-- 				if IsControlJustPressed(1, 177) then
-- 					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
-- 					newscamera = false
-- 				end

-- 				SetEntityRotation(lPed, 0, 0, new_z,2, true)
					
-- 				local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
-- 				CheckInputRotation(cam2, zoomvalue)

-- 				HandleZoom(cam2)
-- 				HideHUDThisFrame()

-- 				DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
-- 				DrawScaleformMovie(scaleform2, 0.5, 0.63, 1.0, 1.0, 255, 255, 255, 255)
-- 				Breaking("BREAKING NEWS")
				
-- 				local camHeading = GetGameplayCamRelativeHeading()
-- 				local camPitch = GetGameplayCamRelativePitch()
-- 				if camPitch < -70.0 then
-- 					camPitch = -70.0
-- 				elseif camPitch > 42.0 then
-- 					camPitch = 42.0
-- 				end
-- 				camPitch = (camPitch + 70.0) / 112.0
				
-- 				if camHeading < -180.0 then
-- 					camHeading = -180.0
-- 				elseif camHeading > 180.0 then
-- 					camHeading = 180.0
-- 				end
-- 				camHeading = (camHeading + 180.0) / 360.0
				
-- 				Citizen.InvokeNative(0xD5BB4025AE449A4E, GetPlayerPed(-1), "Pitch", camPitch)
-- 				Citizen.InvokeNative(0xD5BB4025AE449A4E, GetPlayerPed(-1), "Heading", camHeading * -1.0 + 1.0)
				
-- 				Citizen.Wait(10)
-- 			end

-- 			newscamera = false
-- 			ClearTimecycleModifier()
-- 			fov = (fov_max+fov_min)*0.5
-- 			RenderScriptCams(false, false, 0, 1, 0)
-- 			SetScaleformMovieAsNoLongerNeeded(scaleform)
-- 			DestroyCam(cam2, false)
-- 			SetNightvision(false)
-- 			SetSeethrough(false)
-- 		end
-- 	end
-- end)

---------------------------------------------------------------------------
-- Events --
---------------------------------------------------------------------------

-- Activate camera
RegisterNetEvent('camera:Activate')
AddEventHandler('camera:Activate', function()
	camera = not camera
end)

--FUNCTIONS--
function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(1)
	HideHudComponentThisFrame(2)
	HideHudComponentThisFrame(3)
	HideHudComponentThisFrame(4)
	HideHudComponentThisFrame(6)
	HideHudComponentThisFrame(7)
	HideHudComponentThisFrame(8)
	HideHudComponentThisFrame(9)
	HideHudComponentThisFrame(13)
	HideHudComponentThisFrame(11)
	HideHudComponentThisFrame(12)
	HideHudComponentThisFrame(15)
	HideHudComponentThisFrame(18)
	HideHudComponentThisFrame(19)
end

function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		new_z = rotation.z + rightAxisX*-1.0*(speed_ud)*(zoomvalue+0.1)
		new_x = math.max(math.min(20.0, rotation.x + rightAxisY*-1.0*(speed_lr)*(zoomvalue+0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

function HandleZoom(cam)
	local lPed = GetPlayerPed(-1)
	if not ( IsPedSittingInAnyVehicle( lPed ) ) then

		if IsControlJustPressed(0,241) then
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,242) then
			fov = math.min(fov + zoomspeed, fov_max)
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	else
		if IsControlJustPressed(0,17) then
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,16) then
			fov = math.min(fov + zoomspeed, fov_max)
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	end
end


---------------------------------------------------------------------------
-- Toggling Mic --
---------------------------------------------------------------------------
RegisterNetEvent("Mic:ToggleMic")
AddEventHandler("Mic:ToggleMic", function()
    if not holdingMic then
        RequestModel(GetHashKey(micModel))
        while not HasModelLoaded(GetHashKey(micModel)) do
            Citizen.Wait(100)
        end
		
		while not HasAnimDictLoaded(micanimDict) do
			RequestAnimDict(micanimDict)
			Citizen.Wait(100)
		end

        local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
        local micspawned = CreateObject(GetHashKey(micModel), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
        Citizen.Wait(1000)
        local netid = ObjToNet(micspawned)
        SetNetworkIdExistsOnAllMachines(netid, true)
        NetworkSetNetworkIdDynamic(netid, true)
        SetNetworkIdCanMigrate(netid, false)
        AttachEntityToEntity(micspawned, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 60309), 0.055, 0.05, 0.0, 240.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(GetPlayerPed(PlayerId()), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
        TaskPlayAnim(GetPlayerPed(PlayerId()), micanimDict, micanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
        mic_net = netid
        holdingMic = true
    else
        ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
        DetachEntity(NetToObj(mic_net), 1, 1)
        DeleteEntity(NetToObj(mic_net))
        mic_net = nil
        holdingMic = false
        usingMic = false
    end
end)

---------------------------------------------------------------------------
-- Toggling Boom Mic --
---------------------------------------------------------------------------
RegisterNetEvent("Mic:ToggleBMic")
AddEventHandler("Mic:ToggleBMic", function()
    if not holdingBmic then
        RequestModel(GetHashKey(bmicModel))
        while not HasModelLoaded(GetHashKey(bmicModel)) do
            Citizen.Wait(100)
        end
		
        local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
        local bmicspawned = CreateObject(GetHashKey(bmicModel), plyCoords.x, plyCoords.y, plyCoords.z, true, true, false)
        Citizen.Wait(1000)
        local netid = ObjToNet(bmicspawned)
        SetNetworkIdExistsOnAllMachines(netid, true)
        NetworkSetNetworkIdDynamic(netid, true)
        SetNetworkIdCanMigrate(netid, false)
        AttachEntityToEntity(bmicspawned, GetPlayerPed(PlayerId()), GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422), -0.08, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(GetPlayerPed(PlayerId()), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
        TaskPlayAnim(GetPlayerPed(PlayerId()), bmicanimDict, bmicanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
        bmic_net = netid
        holdingBmic = true
    else
        ClearPedSecondaryTask(GetPlayerPed(PlayerId()))
        DetachEntity(NetToObj(bmic_net), 1, 1)
        DeleteEntity(NetToObj(bmic_net))
        bmic_net = nil
        holdingBmic = false
        usingBmic = false
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if holdingBmic then
			while not HasAnimDictLoaded(bmicanimDict) do
				RequestAnimDict(bmicanimDict)
				Citizen.Wait(100)
			end

			if not IsEntityPlayingAnim(PlayerPedId(), bmicanimDict, bmicanimName, 3) then
				TaskPlayAnim(GetPlayerPed(PlayerId()), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
				TaskPlayAnim(GetPlayerPed(PlayerId()), bmicanimDict, bmicanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
			end
			
			DisablePlayerFiring(PlayerId(), true)
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0, 44,  true) -- INPUT_COVER
			DisableControlAction(0,37,true) -- INPUT_SELECT_WEAPON
			SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey("WEAPON_UNARMED"), true)
			
			if (IsPedInAnyVehicle(GetPlayerPed(-1), -1) and GetPedVehicleSeat(GetPlayerPed(-1)) == -1) or IsPedCuffed(GetPlayerPed(-1)) or holdingMic then
				ClearPedSecondaryTask(GetPlayerPed(-1))
				DetachEntity(NetToObj(bmic_net), 1, 1)
				DeleteEntity(NetToObj(bmic_net))
				bmic_net = nil
				holdingBmic = false
				usingBmic = false
			end
		end
	end
end)

---------------------------------------------------------------------------------------
-- misc functions --
---------------------------------------------------------------------------------------

function drawRct(x,y,width,height,r,g,b,a)
	DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end

function Breaking(text)
		SetTextColour(255, 255, 255, 255)
		SetTextFont(8)
		SetTextScale(1.2, 1.2)
		SetTextWrap(0.0, 1.0)
		SetTextCentre(false)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(1, 0, 0, 0, 205)
		SetTextEntry("STRING")
		AddTextComponentString(text)
		DrawText(0.2, 0.85)
end

function Notification(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0, 1)
end

function DisplayNotification(string)
	SetTextComponentFormat("STRING")
	AddTextComponentString(string)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end