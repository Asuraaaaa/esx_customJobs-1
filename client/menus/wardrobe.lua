Jobs.RegisterMenu('wardrobe', function(isPrimaryJob)
    if (not Jobs.HasPermission('wardrobe.use', isPrimaryJob)) then
        return
    end

    Jobs.TriggerServerCallback('esx_jobs:getPlayerGender', isPrimaryJob, function(gender)
        local elements = {}
        local clothes = Jobs.GetCurrentJobValue(isPrimaryJob).clothes or {}
        local genederSkins = clothes[gender] or {}

        if (#genederSkins > 0) then
            table.insert(elements, { label = _U('skins'), value = '', disabled = true })
        end

        for _, clothe in pairs(genederSkins) do
            table.insert(elements, { label = clothe.name, value = _ })
        end

        table.insert(elements, { label = _U('own_skin'), value = 0 })

        table.insert(elements, { label = _U('back'), value = '', disabled = true })
        table.insert(elements, { label = _U('back'), value = 'back' })

        Jobs.ESX.UI.Menu.Open(
            'job_default',
            GetCurrentResourceName(),
            'wardrobe',
            {
                title = _U('wardrobe'),
                align = 'top-left',
                elements = elements,
                primaryColor = Jobs.GetPrimaryColor(isPrimaryJob),
                secondaryColor = Jobs.GetSecondaryColor(isPrimaryJob),
                image = Jobs.GetCurrentHeaderImage(isPrimaryJob)
            },
            function(data, menu)
                local index = data.current.value
                local playerPed = GetPlayerPed(-1)

                SetPedArmour(playerPed, 0)
                ClearPedBloodDamage(playerPed)
                ResetPedVisibleDamage(playerPed)
                ClearPedLastWeaponDamage(playerPed)
                ResetPedMovementClipset(playerPed, 0)

                if (index ~= nil and tonumber(index) > 0 and clothes ~= nil and clothes[gender] ~= nil and clothes[gender][index] ~= nil) then
                    local outfit = clothes[gender][index] or {}

                    TriggerEvent('skinchanger:loadDefaultModel', gender == 'male', function()
                        Jobs.ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                            TriggerEvent('skinchanger:loadClothes', skin, outfit.skin)
                            TriggerEvent('esx:restoreLoadout')
                        end)
                    end)

                    TriggerEvent('esx:restoreLoadout')
                else
                    TriggerEvent('skinchanger:loadDefaultModel', gender == 'male', function()
                        Jobs.ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                            TriggerEvent('skinchanger:loadSkin', skin)
                            TriggerEvent('esx:restoreLoadout')
                        end)
                    end)

                    TriggerEvent('esx:restoreLoadout')
                end

                menu.close()
            end,
            function(data, menu)
                menu.close()
            end)
    end)
end)