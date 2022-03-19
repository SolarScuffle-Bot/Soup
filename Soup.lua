--!strict

local Module = {}

--Public Types
export type Name_t = any
export type Entity_t = {[Name_t] : Component_t}
export type Component_t = {Entity : Entity_t; [any] : any}
export type Collection_t = {[number] : Component_t}
export type Destructor_t = (Entity_t, ...any) -> nil
export type Constructor_t = (Entity_t, ...any) -> {}
export type Template_t = {
	Constructor: Constructor_t?;
	constructor: Constructor_t?;
	Destructor: Destructor_t?;
	destructor: Destructor_t?;
}

--Private Types
type DataInternal_t = {
	Constructor: Constructor_t;
	Destructor: Destructor_t;
	Collection: Collection_t;
}

--Private Properties
local _CollectionIndex : any = newproxy()
local DataInternal : {[Name_t] : DataInternal_t} = {}

--Helper Functions
local function SwapPop(Array : {[number] : any}, i : number)
	local j = #Array
	Array[j][_CollectionIndex] = i
	Array[i], Array[j] = Array[j], nil
end

--Returns the collection at Name, nil if not present
Module.GetCollection = function(Name : Name_t) : Collection_t?
	local Data = DataInternal[Name]
	if not Data then return end

	return Data.Collection
end

--Creates a unique instance of Name component in Entity. Passes Entity as the first argument to the constructor. _CollectionIndex property automatically added to access the collection index for O(1) removal time.
Module.CreateComponent = function(Entity : Entity_t, Name : Name_t, ... : any)
	local Data : DataInternal_t = DataInternal[Name]
	if not Data then error("Attempting to create instance of non-existant "..Name.." component") return end
	if Entity[Name] then return end

	local Component = Data.Constructor(Entity, ...) :: Component_t
	Component.Entity = Entity
	Entity[Name] = Component

	local Index = #Data.Collection + 1
	Component[_CollectionIndex] = Index
	Data.Collection[Index] = Component
end

--Deletes the unique instance of Name component in Entity. Calls the Name destructor with variable arguments.
Module.DeleteComponent = function(Entity : Entity_t, Name : Name_t, ... : any)
	local Data : DataInternal_t = DataInternal[Name]
	if not Data then error("Attempting to delete instance of non-existant "..Name.." component") return end

	local Component : Component_t = Entity[Name]
	if not Component then return end
	Data.Destructor(Entity, ...)
	Entity[Name] = nil

	SwapPop(Data.Collection, Component[_CollectionIndex])
end

--Sets the Name component's constructor function to ConstructorFunc, destructor function to _DestructFunc, and component collection to {}.
Module.ConstructComponent = function(Name : Name_t, Template : Template_t)
	DataInternal[Name] = {
		--Collections are contiguous arrays of same-type components. Designed to allow for fast ipairs iteration.
		Collection = {};

		--Constructors return a new instance of their component and run during creation. These are manually defined.
		Constructor = Template.Constructor or Template.constructor or function() return {} end;

		--Destructors run during the component's deletion. These are manually defined.
		Destructor = Template.Destructor or Template.destructor or function() end;
	}
end

--Deletes all components with key Name and nils everything ConstructComponent set.
Module.DestructComponent = function(Name : Name_t)
	local Data : DataInternal_t = DataInternal[Name]
	if not Data then return end

	for _, Component in ipairs(Data.Collection) do
		Module.DeleteComponent(Component.Entity, Name)
	end

	DataInternal[Name] = nil
end

--Returns a new entity instance. Entities are tables of references to their components, useful for storing in external data structures like a quadtree.
Module.CreateEntity = function() : Entity_t
	return {} :: Entity_t
end

--Deletes all components in an entity using DeleteComponent. If no references are left to it the garbage colllection will clean it up.
Module.DeleteEntity = function(Entity : Entity_t, ... : any)
	for Name, _ in pairs(Entity) do
		Module.DeleteComponent(Entity, Name, ...)
	end
end

return Module
