local UnityEngine = script.Parent
local Vector3 = require(UnityEngine.Vector3)
local Math = require(UnityEngine.Math)

local Ray = {}

Ray.__type     = 'Ray'
Ray._Getters = {}
Ray._ShortRefs = {}
Ray._FieldRefs = {}

Ray.m_Origin    = nil
Ray.m_Direction = nil

function Ray:AddGetter(name, func)
	self._Getters[name] = func
end

function Ray:AddShortRef(shortName, longName)
	self._ShortRefs[shortName] = longName
end

function Ray:AddFieldRef(refName, fieldName)
	self._FieldRefs[refName] = fieldName
end

function Ray:GetPoint(distance)
	return self.m_Origin + self.m_Direction * distance
end

function Ray.new(origin, direction)
	local self = setmetatable({}, {
		__index = function(t, index)
			local getter = Ray._Getters[index]
			local shortRef = Ray._Getters[Ray._ShortRefs[index]]
			local fieldRef = Ray._FieldRefs[index]
			
			if getter then
				return getter(t)
			elseif shortRef then
				return shortRef(t)
			elseif fieldRef then
				return t[fieldRef]
			end
			return Ray[index]
		end,
		__tostring = function(t) 
			return t.__type .. "(Origin: {" .. tostring(t.m_Origin) .. "}, Dir: {"
			.. tostring(t.m_Direction) .. "})"
		end
	})
	
	self.m_Origin    = origin
	self.m_Direction = direction.Unit -- epic cross compatibility with roblox
	
	self:AddFieldRef("origin", "m_Origin")
	-- TODO: direction setter
	
	return self
end
return Ray
