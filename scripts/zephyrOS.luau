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

local zephyrOS = {}

local Screen = GetPart("ARController") or GetPart("TouchScreen") or GetPart("Screen")
local Instrument = GetPart("Instrument")

zephyrOS.Library = {
	Screen = Screen,
}

zephyrOS.Settings = {
	AccentColor = Color3.fromRGB(51, 88, 130),
}

zephyrOS.States = {
	StartMenuOpened = false,
}

zephyrOS.Threads = {
	StartMenu = nil,
	RenderRegionTime = nil,
	RenderScreenCursors = nil,
}

function zephyrOS:Shutdown()
	Screen:ClearElements()
	Screen:CreateElement("TextLabel", {
		Size=UDim2.fromScale(1, 1),
		Position=UDim2.fromScale(0, 0),
		BackgroundColor3=Color3.fromRGB(0, 0, 0),
		TextColor3=Color3.fromRGB(60, 60, 60),
		Text="Goodbye",
		Font=Enum.Font.Gotham,
		TextScaled=true,
	})
	Beep(1)
	task.wait(0.15)
	Beep(0.75)
	task.wait(0.2)
	Beep(0.5)
	task.wait(0.2)
	Beep(0.35)
	task.wait(0.45)
	Microcontroller:Shutdown()
end

function Init() 
	local Desktop = Screen:CreateElement("TextLabel", {
		Size=UDim2.fromScale(1, 0.9),
		Position=UDim2.fromScale(0, 0),
		BackgroundColor3=Color3.fromRGB(0, 0, 0),
		TextColor3=zephyrOS.Settings.AccentColor,
		Text="zephyr",
		Font=Enum.Font.FredokaOne,
		TextStrokeTransparency=0,
		TextScaled=true,
		TextStrokeColor3=Color3.fromRGB(255, 255, 255),
	})

	local Taskbar = Screen:CreateElement("Frame", {
		Size=UDim2.fromScale(1, 0.1),
		Position=UDim2.fromScale(0, 0.9),
		BackgroundColor3=Color3.fromRGB(30, 30, 30),
		BorderColor3=Color3.fromRGB(255, 255, 255),
	})

	local RegionTime = Screen:CreateElement("TextLabel", {
		Parent=Taskbar,
		Size=UDim2.fromScale(0.12, 1),
		Position=UDim2.fromScale(0.88, 0),
		BackgroundColor3=Color3.fromRGB(30, 30, 30),
		BorderColor3=Color3.fromRGB(255, 255, 255),
		TextColor3=Color3.fromRGB(255, 255, 255),
		TextScaled=true,
		Text="--:--:--",
		Font=Enum.Font.Gotham,
	})
	
	local StartButton = Screen:CreateElement("TextButton", {
		Parent=Taskbar,
		Size=UDim2.fromScale(0.07, 1),
		Position=UDim2.fromScale(0, 0),
		BackgroundColor3=Color3.fromRGB(30, 30, 30),
		BorderColor3=Color3.fromRGB(255, 255, 255),
		TextColor3=zephyrOS.Settings.AccentColor,
		TextStrokeTransparency=0,
		TextStrokeColor3=Color3.fromRGB(255, 255, 255),
		TextScaled=true,
		Text="z",
		Font=Enum.Font.FredokaOne,
	})

	StartButton.MouseButton1Click:Connect(function()
		if zephyrOS.States.StartMenuOpened == false then
			if zephyrOS.Threads.StartMenu == nil then
				zephyrOS.Threads.StartMenu = Screen:CreateElement("Frame", {
					Parent=Desktop,
					Size=UDim2.fromScale(0.4, 0.8),
					Position=UDim2.fromScale(0, 0.2),
					BackgroundColor3=Color3.fromRGB(30, 30, 30),
					BorderColor3=Color3.fromRGB(255, 255, 255),
					Visible = true
				})

				local _Title = Screen:CreateElement("TextLabel", {
					Parent=zephyrOS.Threads.StartMenu,
					Size=UDim2.fromScale(1, 0.12),
					Position=UDim2.fromScale(0, 0),
					BackgroundTransparency=1,
					TextColor3=zephyrOS.Settings.AccentColor,
					TextStrokeTransparency=0,
					TextStrokeColor3=Color3.fromRGB(255, 255, 255),
					TextScaled=true,
					Text="zephyrOS",
					Font=Enum.Font.FredokaOne
				})

				local ShutdownButton = Screen:CreateElement("TextButton", {
					Parent=zephyrOS.Threads.StartMenu,
                    Size=UDim2.fromScale(1, 0.1),
                    Position=UDim2.fromScale(0, 0.9),
                    BackgroundColor3=Color3.fromRGB(30, 30, 30),
                    BorderColor3=Color3.fromRGB(255, 255, 255),
                    TextColor3=Color3.fromRGB(255, 255, 255),
                    TextScaled=true,
                    Text="Shutdown",
                    Font=Enum.Font.Gotham
                })

				ShutdownButton.MouseButton1Click:Connect(function()
					zephyrOS:Shutdown()
				end)
			end

			StartButton.TextStrokeColor3 = zephyrOS.Settings.AccentColor
			StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			zephyrOS.Threads.StartMenu.Visible = true
			zephyrOS.States.StartMenuOpened = true
		else
			StartButton.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
			StartButton.TextColor3 = zephyrOS.Settings.AccentColor
			zephyrOS.Threads.StartMenu.Visible = false
			zephyrOS.States.StartMenuOpened = false
		end
	end)

	zephyrOS.Threads.RenderRegionTime = task.spawn(function()
		if not Instrument then
			RegionTime:Destroy()
			return
		end

		local T
		Microcontroller.Loop:Connect(function()
			if T == Instrument:GetReading("Time") then return end
			RegionTime.Text = Instrument:GetReading("Time")
			T = Instrument:GetReading("Time")
		end)
	end)

	zephyrOS.Threads.RenderScreenCursors = task.spawn(function()
		local SavedCursors = {}
	
		local CanMoveCursors = true
		Screen.CursorPressed:Connect(function()
			if not CanMoveCursors then return end
			for _, v in Screen:GetCursors() do
				if SavedCursors[v.Player] == nil then
					SavedCursors[v.Player] = Screen:CreateElement("Frame", {
						Size=UDim2.fromOffset(10, 10),
						BackgroundColor3=Color3.fromRGB(220, 220, 220),
					})
	
					local _Username = Screen:CreateElement("TextLabel", {
						Parent=SavedCursors[v.Player],
						Size=UDim2.fromOffset(0, 0),
						Position=UDim2.fromScale(0.5, 2.5),
						TextColor3=Color3.fromRGB(220, 220, 220),
						Text=v.Player,
						TextScaled=false,
						TextWrapped=false,
						TextSize=24,
						BackgroundTransparency=1,
						TextXAlignment=Enum.TextXAlignment.Center,
						Font=Enum.Font.Gotham
					})
				end
	
				if not SavedCursors[v.Player].Visible then
					SavedCursors[v.Player].Visible = true
				end
	
				SavedCursors[v.Player].Position = UDim2.fromOffset(v.X - 5, v.Y - 5)
			end
			CanMoveCursors = false
			task.wait(0.025)
			CanMoveCursors = true
		end)

		Microcontroller.Loop:Connect(function()
			for i, v in SavedCursors do
				if not Screen:GetCursors()[i] then
					SavedCursors[i].Visible = false
				end
			end
		end)
	end)
end

local s, r = pcall(function()
	task.spawn(function()
		task.wait(0.2)
		Beep(0.35)
		task.wait(0.2)
		Beep(0.5)
		task.wait(0.2)
		Beep(0.75)
		task.wait(0.2)
		Beep(1)
	end)
	Init()
end)

if not s then
	error(r)
end
