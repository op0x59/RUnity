local UnityEngine = script.Parent
local Vector3 = require(UnityEngine.Vector3)
local Math = require(UnityEngine.Math)

local Ray2D = {}

Ray2D.__type     = 'Ray2D'
Ray2D._Getters   = {}
Ray2D._ShortRefs = {}
Ray2D._FieldRefs = {}

Ray2D.m_Origin    = nil
Ray2D.m_Direction = nil

function Ray2D:AddGetter(name, func)
	self._Getters[name] = func
end

function Ray2D:AddShortRef(shortName, longName)
	self._ShortRefs[shortName] = longName
end

function Ray2D:AddFieldRef(refName, fieldName)
	self._FieldRefs[refName] = fieldName
end

function Ray2D:GetPoint(distance)
	return self.m_Origin + self.m_Direction * distance
end

function Ray2D.new(origin, direction)
	local self = setmetatable({}, {
		__index = function(t, index)
			local getter = Ray2D._Getters[index]
			local shortRef = Ray2D._Getters[Ray2D._ShortRefs[index]]
			local fieldRef = Ray2D._FieldRefs[index]
			
			if getter then
				return getter(t)
			elseif shortRef then
				return shortRef(t)
			elseif fieldRef then
				return t[fieldRef]
			end
			return Ray2D[index]
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
return Ray2D
