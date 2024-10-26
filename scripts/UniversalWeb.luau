--[[
    MIT License

    Copyright (c) 2024 indeedVC

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]

local UniversalWeb = {}

UniversalWeb.Library = {
	Display = GetPart("Screen") or GetPart("TouchScreen"),
	Modem = GetPart("Modem"),
	Disk = GetPart("Disk"),
	Keyboard = GetPart("Keyboard"),
	
	AddressBar = nil,
	SecurityEmoji = nil,
	SiteFrame = nil,

	CurrentPage = nil,
}

UniversalWeb.Settings = {
	AccentColor = Color3.fromRGB(88, 101, 242)
}

function UniversalWeb:GoToURL(address: string)
	local addr = address:gsub('\n', ''):lower()

	if UniversalWeb.Library.CurrentPage ~= nil then UniversalWeb.Library.CurrentPage:Destroy() end
	UniversalWeb.Library.CurrentPage = UniversalWeb.Library.Display:CreateElement("Frame", {
		Parent=UniversalWeb.Library.SiteFrame,
		Size=UDim2.fromScale(1, 1),
		Position=UDim2.fromScale(0, 0),
		BackgroundColor3=Color3.fromRGB(255, 255, 255),
	})

	if addr:find("^about:") then
		addr = addr:gsub("about:", '')

		if addr == "create" then
			if not UniversalWeb.Library.Disk then
				UniversalWeb.Library.Display:CreateElement("TextLabel", {
					Parent=UniversalWeb.Library.SiteFrame,
					Size=UDim2.fromScale(1, 1),
					Position=UDim2.fromScale(0, 0),
					BackgroundColor3=Color3.fromRGB(255, 64, 64),
					TextColor3=Color3.fromRGB(255, 255, 255),
					Font=Enum.Font.Gotham,
					FontSize=Enum.FontSize.Size42,
					RichText=true,
					TextWrapped=true,
					Text="<b>ERROR</b>\nA Disk is required"
				})
				Microcontroller.Loop:Connect(function() end)
				return
			end
		elseif addr == "welcome" then
			UniversalWeb.Library.Display:CreateElement("TextLabel", {
				Parent=UniversalWeb.Library.CurrentPage,
				Size=UDim2.fromScale(1, 1),
				Position=UDim2.fromScale(0, 0),
				BackgroundColor3=Color3.fromRGB(255, 255, 255),
				TextColor3=Color3.fromRGB(0, 0, 0),
				Font=Enum.Font.Gotham,
				FontSize=Enum.FontSize.Size42,
				TextWrapped=true,
				Text="Welcome to Universal Web! Click on the URL bar to get started."
			})
		else
			UniversalWeb.Library.Display:CreateElement("TextLabel", {
				Parent=UniversalWeb.Library.CurrentPage,
				Size=UDim2.fromScale(1, 1),
				Position=UDim2.fromScale(0, 0),
				BackgroundColor3=Color3.fromRGB(35, 39, 42),
				TextColor3=Color3.fromRGB(255, 255, 255),
				Font=Enum.Font.Gotham,
				FontSize=Enum.FontSize.Size42,
				RichText=true,
				TextWrapped=true,
				Text="<font size=\"60\"><b>That doesn't look right.</b></font>\nCheck the URL and try again."
			})
		end

		UniversalWeb.Library.SecurityEmoji.Text = "🛡️"
		addr = "about:" .. addr
	else
		addr = addr:gsub('%p+', '')
		
		UniversalWeb.Library.Modem:Configure({NetworkID = "UniversalWeb:" .. addr})
		UniversalWeb.Library.Modem:SendMessage(JSONEncode({
			microcontroller = SandboxID,
			web = addr,
		}))

		UniversalWeb.Library.Display:CreateElement("TextLabel", {
			Parent=UniversalWeb.Library.CurrentPage,
			Size=UDim2.fromScale(1, 1),
			Position=UDim2.fromScale(0, 0),
			BackgroundColor3=Color3.fromRGB(35, 39, 42),
			TextColor3=Color3.fromRGB(255, 255, 255),
			Font=Enum.Font.Gotham,
			FontSize=Enum.FontSize.Size42,
			RichText=true,
			TextWrapped=true,
			Text="<font size=\"60\"><b>That doesn't look right.</b></font>\nThis page doesn't exist or the web's modem didn't respond. Check the URL and try again."
		})

		UniversalWeb.Library.SecurityEmoji.Text = "⚠️"
	end

	UniversalWeb.Library.AddressBar.Text = addr
end

function Init()
	local Topbar = UniversalWeb.Library.Display:CreateElement("Frame", {
		Size=UDim2.fromScale(1, 0.15),
		Position=UDim2.fromScale(0, 0),
		BackgroundColor3=Color3.fromRGB(18, 20, 21),
		BorderColor3=UniversalWeb.Settings.AccentColor,
		BorderSizePixel=4,
	})

	UniversalWeb.Library.SiteFrame = UniversalWeb.Library.Display:CreateElement("Frame", {
		Size=UDim2.fromScale(1, 0.85),
		Position=UDim2.fromScale(0, 0.15),
		BackgroundColor3=Color3.fromRGB(255, 255, 255),
		BorderColor3=UniversalWeb.Settings.AccentColor,
		BorderSizePixel=4,
	})

	UniversalWeb.Library.AddressBar = UniversalWeb.Library.Display:CreateElement("TextButton", {
		Parent=Topbar,
		Size=UDim2.fromScale(0.89, 0.7),
		Position=UDim2.fromScale(0.095, 0.15),
		BackgroundColor3=Color3.fromRGB(35, 39, 42),
		BorderColor3=UniversalWeb.Settings.AccentColor,
		TextColor3=Color3.fromRGB(255, 255, 255),
		Text='',
		RichText=true,
		TextScaled=true,
		Font=Enum.Font.Gotham,
	})

	UniversalWeb.Library.SecurityEmoji = UniversalWeb.Library.Display:CreateElement("TextLabel", {
		Parent=Topbar,
		Size=UDim2.fromScale(0.07, 0.7),
		Position=UDim2.fromScale(0.015, 0.15),
		BackgroundColor3=Color3.fromRGB(35, 39, 42),
		BorderColor3=UniversalWeb.Settings.AccentColor,
		TextColor3=Color3.fromRGB(255, 255, 255),
		Text='',
		RichText=true,
		TextScaled=true,
		Font=Enum.Font.Gotham,
	})

	if not UniversalWeb.Library.Modem then
		UniversalWeb.Library.AddressBar.Text = "about:nomodem"
		UniversalWeb.Library.AddressBar.TextColor3 = Color3.fromRGB(255, 64, 64)
		UniversalWeb.Library.Display:CreateElement("TextLabel", {
			Parent=UniversalWeb.Library.SiteFrame,
			Size=UDim2.fromScale(1, 1),
			Position=UDim2.fromScale(0, 0),
			BackgroundColor3=Color3.fromRGB(255, 64, 64),
			TextColor3=Color3.fromRGB(255, 255, 255),
			Font=Enum.Font.Gotham,
			FontSize=Enum.FontSize.Size42,
			RichText=true,
			TextWrapped=true,
			Text="<b>ERROR</b>\nA Modem is required"
		})
		Microcontroller.Loop:Connect(function() end)
		return
	end

	local _ADDRESSBARCLICKED = false
	UniversalWeb.Library.AddressBar.MouseButton1Click:Connect(function()
		if _ADDRESSBARCLICKED then return end
		if not _ADDRESSBARCLICKED then _ADDRESSBARCLICKED = true end

		UniversalWeb.Library.Display:CreateElement("Frame", {
			Parent=UniversalWeb.Library.CurrentPage,
			Size=UDim2.fromScale(1, 1),
			Position=UDim2.fromScale(0, 0),
			BackgroundColor3=Color3.fromRGB(0, 0, 0),
			BackgroundTransparency=0.35,
			ZIndex=10000,
		})

		UniversalWeb.Library.AddressBar.Text = "Type in Keyboard to enter URL"
	end)

	UniversalWeb.Library.Keyboard.TextInputted:Connect(function(text, player)
		if _ADDRESSBARCLICKED then
			UniversalWeb:GoToURL(text)
			_ADDRESSBARCLICKED = false
			Beep()
		end
	end)

	UniversalWeb:GoToURL("about:welcome")
end

Init()
