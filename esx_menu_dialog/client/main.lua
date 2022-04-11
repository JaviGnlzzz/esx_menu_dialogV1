Citizen.CreateThread(function()
	ESX               = nil
	local Timeouts    = {}
	local GUI         = {}
	GUI.Time          = 0
	local MenuType    = 'dialog'
	local OpenedMenus = {}

	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	local openMenu = function(namespace, name, data)
		for i=1, #Timeouts, 1 do
			ESX.ClearTimeout(Timeouts[i])
		end

		OpenedMenus[namespace .. '_' .. name] = true

		SendNUIMessage({
			action    = 'openMenu',
			namespace = namespace,
			name      = name,
			data      = data
		})

		local timeoutId = ESX.SetTimeout(200, function()
			SetNuiFocus(true, true)
		end)

		table.insert(Timeouts, timeoutId)
	end

	local closeMenu = function(namespace, name)
		OpenedMenus[namespace .. '_' .. name] = nil
		local OpenedMenuCount                 = 0

		SendNUIMessage({
			action    = 'closeMenu',
			namespace = namespace,
			name      = name,
			data      = data
		})

		for k,v in pairs(OpenedMenus) do
			if v == true then
				OpenedMenuCount = OpenedMenuCount + 1
			end
		end

		if OpenedMenuCount == 0 then
			SetNuiFocus(false)
		end

	end

	ESX.UI.Menu.RegisterType(MenuType, openMenu, closeMenu)

	RegisterNUICallback('menu_submit', function(data, cb)
		local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)
		local post = true

		if menu.submit ~= nil then

			if tonumber(data.value) ~= nil then

				data.value = ESX.Math.Round(tonumber(data.value))

				if tonumber(data.value) <= 0 then
					post = false
				end
			end

			data.value = ESX.Math.Trim(data.value)
			
			if post then
				menu.submit(data, menu)
			else
				ESX.ShowNotification('Numero invalido')
			end
		end

		cb('OK')
	end)

	RegisterNUICallback('menu_cancel', function(data, cb)
		local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.cancel ~= nil then
			menu.cancel(data, menu)
		end

		cb('OK')
	end)

	RegisterNUICallback('menu_change', function(data, cb)
		local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

		if menu.change ~= nil then
			menu.change(data, menu)
		end

		cb('OK')
	end)

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(10)
			local OpenedMenuCount = 0

			for k,v in pairs(OpenedMenus) do
				if v == true then
					OpenedMenuCount = OpenedMenuCount + 1
				end
			end

			if OpenedMenuCount > 0 then
				DisableControlAction(0, 1,   true)
				DisableControlAction(0, 2,   true)
				DisableControlAction(0, 142, true)
				DisableControlAction(0, 106, true)
				DisableControlAction(0, 12, true)
				DisableControlAction(0, 14, true)
				DisableControlAction(0, 15, true)
				DisableControlAction(0, 16, true)
				DisableControlAction(0, 17, true)
			else
				Citizen.Wait(500)
			end
		end
	end)
end)