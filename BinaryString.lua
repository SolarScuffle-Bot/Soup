local Module = {}

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