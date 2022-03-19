--!strict

--[[
	This example is aimed specifically towards a roblox luau audience.
]]--

--Require fundamental dependencies
local RunService = game:GetService("RunService")
local Soup = require(path.to.Soup)

--Construct a component with key "Position"
Soup.ConstructComponent("Position", {
	Constructor = function(Entity : Soup.Entity_t, Position : Vector3?)
		return {
			Position = Position or Vector3.new();
		}
	end;

	Destructor = function(Entity : Soup.Entity_t, Message : string)
		print(Entity.Position, "Is being destroyed! A sponsor from our hosts: "..Message)
	end;
})

--Construct a component with key "Physics"
Soup.ConstructComponent("Physics", {
	Constructor = function(Entity : Soup.Entity_t, Velocity : Vector3?) --Define a constructor that takes in a velocity and returns a table storing that velocity and a default acceleration
		return {
			Velocity = Velocity or Vector3.new();
			Acceleration = Vector3.new();
		}
	end;
})

--Construct a component with key "Health"
Soup.ConstructComponent("Health", {
	Constructor = function(Entity : Soup.Entity_t, MaxHealth : number, RegenerationRate : number) --Define a constructor that takes in a max health and regeneration rate and returns a table storing them and a default health
		return {
			MaxHealth = MaxHealth or 100;
			RegenerationRate = RegenerationRate or 1;
			Health = MaxHealth;
		}
	end;
})

--Create a System that iterates over all Position components that have an associated Physics component and update their properties
local PositionCollection = Soup.GetCollection("Position") :: Soup.Collection_t
RunService.Heartbeat:Connect(function(dt : number)
	for _, Position in ipairs(PositionCollection) do
		local Physics = Position.Entity.Physics
		if not Physics then continue end

		Position.Position += 0.5 * Physics.Acceleration * dt^2 + Physics.Velocity * dt
		Physics.Velocity += Physics.Acceleration * dt
	end
end)

--Create a System that iterates over all Health components and update their health
local HealthCollection = Soup.GetCollection("Health") :: Soup.Collection_t
RunService.Heartbeat:Connect(function(dt : number)
	for _, Health in ipairs(HealthCollection) do
		Health.Health = math.min(Health.MaxHealth, Health.Health + Health.RegenerationRate * dt)
	end
end)

--Create 1000 entities with Position, Physics, and Health components and store them in Entities
local Entities : {[number] : Soup.Entity_t} = table.create(1e3)
for i = 1, #Entities do
	local Entity = Soup.CreateEntity()
	Soup.CreateComponent(Entity, "Position", Vector3.new(i, i, i))
	Soup.CreateComponent(Entity, "Physics", Vector3.new(-i, i, -i))
	Soup.CreateComponent(Entity, "Health", 100, 5)

	Entities[i] = Entity
end

task.wait(10)

--Delete all entities in Entities and clear the table to prevent memory leak
for _, Entity in ipairs(Entities) do
	Soup.DeleteEntity(Entity)
end
table.clear(Entities)