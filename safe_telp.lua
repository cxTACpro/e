local Player = game.Players.LocalPlayer    
local Http = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local Api = "https://games.roblox.com/v1/games/"

local _place,_id = game.PlaceId, game.JobId
-- Asc for lowest player count, Desc for highest player count
local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
function ListServers(cursor)
   local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
   return Http:JSONDecode(Raw)
end

time_to_wait = 2 --seconds

while wait(time_to_wait) do
   --freeze player before teleporting to prevent executor crash?
   local char=workspace:FindFirstChild(Player.Name,true)
    char.HumanoidRootPart.Anchored = true --bruh
   Player.Character.HumanoidRootPart.Anchored = true --bruh
   local Servers = ListServers()
   local Server = Servers.data[math.random(1,#Servers.data)]
   
    if Server.playing < Server.maxPlayers and  Server.id ~= _id then
        TPS:TeleportToPlaceInstance(_place, Server.id, Player)
    end
end
