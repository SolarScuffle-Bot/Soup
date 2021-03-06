local function StringBAnd(String1, String2)
	local Length = math.max(#String1, #String2)
	local String3 = table.create(Length, 0)
	for i = 1, Length do
		String3[i] = (string.byte(String1, i) == 49 and string.byte(String2, i) == 49) and 1 or 0
	end
	for i = Length, 1, -1 do
		if String3[i] ~= 0 then break end
		String3[i] = nil
	end
	return #String3 == 0 and "0" or table.concat(String3, '')
end

local function StringBOr(String1, String2)
	local Length = math.max(#String1, #String2)
	local String3 = table.create(Length, 0)
	for i in ipairs(String3) do
		String3[i] = (string.byte(String1, i) == 49 or string.byte(String2, i) == 49) and 1 or 0
	end
	for i = Length, 1, -1 do
		if String3[i] ~= 0 then break end
		String3[i] = nil
	end
	return #String3 == 0 and "0" or table.concat(String3, '')
end

local function StringBNot(String1)
	local String2 = table.create(#String1, 1)
	for i in ipairs(String2) do
		String2[i] = string.byte(String1, i) == 48 and 1 or 0
	end
	for i = #String2, 1, -1 do
		if String2[i] ~= 0 then break end
		String2[i] = nil
	end
	return #String2 == 0 and "0" or table.concat(String2, '')
end

local function StringPlace(Place)
	local String = table.create(Place, 0)
	String[Place] = 1
	return #String == 0 and "0" or table.concat(String, '')
end

local NextPlace = 1
local NameToData = {}
local SignatureToCollection = {}
local UniversalSignature = "0"

local function InsertEntity(Entity, Collection)
	local Index = #Collection.Entities + 1
	Collection.Entities[Index] = Entity
	Collection.EntityToIndex[Entity] = Index
end

local function RemoveEntity(Entity, Collection)
	local Index = Collection.EntityToIndex[Entity]
	local LastIndex = #Collection.Entities
	local LastEntity = Collection.Entities[LastIndex]
	Collection.Entities[Index], Collection.Entities[LastIndex] = LastEntity, nil
	Collection.EntityToIndex[LastEntity], Collection.EntityToIndex[Entity] = Index, nil
end

local function GetCollection(Signature)
	local Collection = SignatureToCollection[Signature]
	if Collection then return Collection end
	
	Collection = {
		Signature = Signature;
		Entities = {};
		EntityToIndex = {};
	}

	SignatureToCollection[Signature] = Collection

	for _, Entity in ipairs(SignatureToCollection[UniversalSignature].Entities) do
		if StringBAnd(Collection.Signature, Entity._Signature) == Collection.Signature then
			InsertEntity(Entity, Collection)
		end
	end
	
	return Collection
end

local Module = {}

Module.GetCollection = function(Names)
	local Signature = "0"
	for _, Name in ipairs(Names) do
		local Data = NameToData[Name]
		if not Data then
			error("Attempting to get collection of non-existant "..Name.." component")
			return
		end

		Signature = StringBOr(Signature, Data.Signature)
	end

	return GetCollection(Signature).Entities
end

Module.ConstructComponent = function(Name, Template)
	if NameToData[Name] then
		error("Attempting to construct component "..Name.." twice")
		return
	end

	NameToData[Name] = {
		Signature = StringPlace(NextPlace);

		Constructor = Template.Constructor or Template.constructor or function() return true end;
		Destructor = Template.Destructor or Template.destructor or function() end;
	}

	NextPlace = NextPlace + 1
end

Module.CreateComponent = function(Entity, Name, ...)
	local Data = NameToData[Name]
	if not Data then
		error("Attempting to create instance of non-existant "..Name.." component")
		return
	end

	if Entity[Name] then
		warn("Attempting to create instance of "..Name.." component on entity "..Entity.." when it already exists")
		return
	end

	Entity[Name] = Data.Constructor(Entity, ...)
	Entity._Signature = StringBOr(Entity._Signature, Data.Signature)

	for CollectionSignature, Collection in pairs(SignatureToCollection) do
		if 
			StringBAnd(CollectionSignature, Entity._Signature) == Entity._Signature and
			not Collection.EntityToIndex[Entity]
		then
			InsertEntity(Entity, Collection)
		end
	end
	
	warn(SignatureToCollection)
end

Module.DeleteComponent = function(Entity, Name, ...)
	local Data = NameToData[Name]
	if not Data then
		error("Attempting to delete instance of non-existant "..Name.." component")
		return
	end

	local Component = Entity[Name]
	if not Component then
		warn("Attempting to delete instance of "..Name.." component on entity "..Entity.." when it doesn't exist")
		return
	end

	for CollectionSignature, Collection in pairs(SignatureToCollection) do
		if 
			StringBAnd(CollectionSignature, Entity._Signature) == CollectionSignature and
			Collection.EntityToIndex[Entity]
		then
			RemoveEntity(Entity, Collection)
		end
	end

	Data.Destructor(Entity, ...)
	Entity[Name] = nil
	Entity._Signature = StringBAnd(Entity._Signature, StringBNot(Data.Signature))
end

Module.CreateEntity = function()
	local Entity = {}
	Entity._Signature = UniversalSignature

	local Collection = GetCollection(Entity._Signature)
	InsertEntity(Entity, Collection)

	return Entity
end

Module.DeleteEntity = function(Entity)
	for Name in pairs(Entity) do
		if Name ~= "_Signature" then
			Module.DeleteComponent(Entity, Name)
		end
	end
end

Module.GetDebugText = function()
	local Text = "DEBUG TEXT:\n\n"
	
	for Signature, Collection in pairs(SignatureToCollection) do
		Text ..= "("..tonumber(string.reverse(Signature), 2)..") => [\n\t"
		
		for i, Entity in ipairs(Collection.Entities) do
			Text ..= "("
			
			local Names = {}
			table.insert(Names, tonumber(string.reverse(Entity._Signature), 2))
			
			for Name in pairs(Entity) do
				if Name ~= "_Signature" then
					table.insert(Names, Name)
				end	
			end
			
			Text ..= table.concat(Names, ", ") .. ")\t"
		end
		
		Text ..= "\n],\n\n"
	end
	
	return Text
end

return Module