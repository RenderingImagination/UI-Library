local List = Tool:WaitForChild("List")
local Control = Tool:WaitForChild("Control")
local ExamplePlayer = Tool:WaitForChild("Example")
print'1'

local Active = false
local ControlOpen = false
local ActiveChanged = Instance.new("BindableEvent", Tool)
local TargetPlayer
local LocalPlayer = game:GetService("Players").LocalPlayer
local Camera = game.Workspace.CurrentCamera
local CheckList
print'2'

local function DefineCheckList()
	CheckList = game:GetService("Players"):GetPlayers()
	table.sort(CheckList, function(A, B)
		return A.Name < B.Name
	end)
end

local function MakeButton(player)
	local Button = ExamplePlayer:Clone()
	Button.Name = player.Name
	Button.TextLabel.Text = player.Name
	Button.ImageButton.Image = "http://www.roblox.com/Thumbs/Avatar.ashx?x=200&y=200&Format=Png&username=".. player.Name
	Button.BackgroundColor3 = player.Team and player.Team.TeamColor.Color or Button.BackgroundColor3
	Button.ImageButton.MouseButton1Down:Connect(function()
		if player.Character ~= nil then
			Camera.CameraSubject = player.Character.Humanoid
			TargetPlayer = player
			Control.Enabled = true
			List.Enabled = false
			coroutine.wrap(function()
				local Disabled,PlayerCharacterChanged
				PlayerCharacterChanged = player.CharacterAdded:Connect(function(NewChar)
					local Humanoid = NewChar:FindFirstChildOfClass("Humanoid")
					if not Humanoid then repeat Humanoid = NewChar:FindFirstChildOfClass("Humanoid") task.wait() until Humanoid or not NewChar.Parent end
					if Humanoid then
						Camera.CameraSubject = Humanoid
					end
				end)
				Disabled = ActiveChanged.Event:Connect(function()
					Disabled:Disconnect()
					PlayerCharacterChanged:Disconnect()
				end)
			end)()
		end
	end)
	return Button
end

local function UpdateCTools()
	Control.Options.Frame.ToolStore:ClearAllChildren()
	Control.Options.Frame.ToolStore.CanvasSize = UDim2.new(0,0,0,0)
	if not TargetPlayer then return end
	local T = 0
	local P = 0
	for i,v in pairs(TargetPlayer.Backpack:GetChildren()) do
		if v.ClassName == "Tool" or v.ClassName == "HopperBin" then
			local button = Control.Options.Frame.Example:Clone()
			button.Name = "Tool"
			button.Visible = true
			button.Parent = Control.Options.Frame.ToolStore
			button.Text = v.Name
			button.Position = UDim2.new(0,0,0,P)
			P += 55
			T += 1
			Control.Options.Frame.ToolStore.CanvasSize = UDim2.new(0,0,0,(T*55))			
		end
	end
end

local function ToggleC()
	UpdateCTools()
	if ControlOpen then
		Control.Options.Frame.PlayerInfo.Visible = false
		Control.Options.Frame.ToolStore.Visible = false
		Control.Options.Frame:TweenSize(UDim2.new(0.5,0,0,0),"Out","Sine",1,false)
		task.wait(.5)
		Control.Options.Frame.OpenC.Image = "http://www.roblox.com/asset/?id=108326682"
		ControlOpen = false
	elseif not ControlOpen then
		Control.Options.Frame:TweenSize(UDim2.new(0.5,0,-0.5,0),"Out","Sine",1,false)
		task.wait(.5)
		Control.Options.Frame.PlayerInfo.Visible = true
		Control.Options.Frame.ToolStore.Visible = true
		Control.Options.Frame.OpenC.Image = "http://www.roblox.com/asset/?id=108326725"
		ControlOpen = true
	end
end
print'3'
Control.Options.Frame.OpenC.MouseButton1Down:connect(ToggleC)

Tool.Equipped:Connect(function()
	Active = true
	ActiveChanged:Fire()
	List.Enabled = true
	Control.Enabled = true
	for _, player in pairs(CheckList) do
		local PreviousPosition = UDim2.new(-0.1, 0, 0, 0)
		local Button = MakeButton(player)
		if PreviousPosition.X.Scale >= .9 then
			Button.Position = UDim2.new(0, 0, PreviousPosition.Y.Scale+.3, 0)
		else
			Button.Position = PreviousPosition + UDim2.new(0.1, 0, 0, 0)
		end
		Button.Parent = List.Options
		PreviousPosition = Button.Position
	end
end)

Tool.Unequipped:Connect(function()
	Active = false
	ActiveChanged:Fire()
	Camera.CameraSubject = LocalPlayer.Character.Humanoid
	List.Enabled = false
	Control.Enabled = false
	for _, child in pairs(List.Options:GetChildren()) do
		if child:IsA("UIGridLayout") then continue end
		task.spawn(child.Destroy, child)
	end
	ControlOpen = false
	Control.Options.Frame.PlayerInfo.Visible = false
	Control.Options.Frame.ToolStore.Visible = false
	Control.Options.Frame.Size = UDim2.new(0.5,0,0,0)
	Control.Options.Frame.OpenC.Image = "http://www.roblox.com/asset/?id=108326682"
end)
print'4'
DefineCheckList()
game:GetService("Players").PlayerAdded:Connect(DefineCheckList)
game:GetService("Players").PlayerRemoving:Connect(DefineCheckList)
print'7'
List.Parent = LocalPlayer:WaitForChild("PlayerGui")
Control.Parent = LocalPlayer.PlayerGui
print'6'
game:GetService("RunService").RenderStepped:Connect(function()
	if not TargetPlayer then return end
	Control.Options.Frame.PlayerInfo.PlrName.Text = "Name: "..tostring(TargetPlayer)
	Control.Options.Frame.PlayerInfo.Walkspeed.Text = "Walkspeed: "..tostring(TargetPlayer.Character.Humanoid.WalkSpeed)
	Control.Options.Frame.PlayerInfo.Health.Text = "Health: "..tostring(TargetPlayer.Character.Humanoid.Health)
	Control.Options.Frame.PlayerInfo.MHealth.Text = "Max Health: "..tostring(TargetPlayer.Character.Humanoid.MaxHealth)
	Control.Options.Frame.PlayerInfo.ImageLabel.Image = "http://www.roblox.com/thumbs/avatar.ashx?x=200&y=200&format=png&username="..tostring(TargetPlayer)
end)
print'5'
