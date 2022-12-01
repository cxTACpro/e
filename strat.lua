repeat task.wait() until game:IsLoaded()
local repstorage = game:GetService("ReplicatedStorage")
local leave = repstorage:FindFirstChild("LeaveGuiEvent")
local player = game:GetService("Players").LocalPlayer
local lobby = workspace:FindFirstChild("CDS Summer Lobby")
local place = repstorage.Events:FindFirstChild("Place")
local a = {}
task.wait()
function a:Map(mapname)
	task.wait()
    if lobby then
		local elevators=lobby["Elevators"]:GetChildren()
		local gotin = false
		for i,lift in pairs(elevators) do
			if lift:IsA("Model") then
				local mapinfo = lift:FindFirstChild("Gate")
				if mapinfo then
					local mapnim = mapinfo.Map.Value
					if string.lower(mapname)==string.lower(mapnim) then
						local char = player.Character
						game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = mapinfo.Gate.CFrame
						gotin = true
						break
					end
				end
			end
		end
		if not gotin then
			return a:Map(mapname)
		end
	end

end
function a:Mode(mode)
if not lobby then
	game:GetService("ReplicatedStorage").Events.Vote:InvokeServer(mode) end
end
function a:Place(X,Y,Z,towername)
	place:InvokeServer(nil,towername,Ray.new(Vector3.new(X,Y,Z), Vector3.new(0, 0, 0)))
end
function a:Upgrade(instance)
	if not lobby then
		local sell=repstorage.Events.Upgrade
		sell:InvokeServer(instance)
    end
end
function a:Sell(instance)
    if not lobby then
		local sell=repstorage.Events.Sell
		sell:InvokeServer(instance)
    end
end
function a:Loadout(t1,t2,t3,t4,t5)
	slots = {"One","Two","Three","Four","Five"}
	for  i=1,5  do
		local une=repstorage.Events.Unequip
		une:FireServer(slots[i])
	end
    local e=repstorage.Events.Equip
    local ts = {t1,t2,t3,t4,t5}
    for i=1,5 do
		if ts[i] then
        	local towertoequip = ts[i]
			local inventory = player.Data.Inventory
			local tower = inventory[towertoequip]
			if tower and tower.Value==true then
				e:FireServer(towertoequip)
			else
				player:Kick("requested tower not owned or found")
				break
			end
		end
    end
end
function a:SellAllFarms()
	if not lobby then
		for i,tower in pairs(workspace.Game.Towers:GetChildren()) do
			if tower.Name=="Farm" and tower.Owner.Value==player.Name then
				a:Sell(tower)
			end
		end
	end
end
return a
