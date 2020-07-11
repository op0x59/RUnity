local UnityEngine = script.Parent
local Vector3 = require(UnityEngine.Vector3)
local Math = require(UnityEngine.Math)

local Plane = {}

Plane.__type     = 'Plane'
Plane._Getters = {}
Plane._ShortRefs = {}
Plane._FieldRefs = {}

Plane.m_Normal   = nil
Plane.m_Distance = nil

function Plane:AddGetter(name, func)
	self._Getters[name] = func
end

function Plane:AddShortRef(shortName, longName)
	self._ShortRefs[shortName] = longName
end

function Plane:AddFieldRef(refName, fieldName)
	self._FieldRefs[refName] = fieldName
end

function Plane:SetNormalAndPosition(inNormal, inPoint)
	self.m_Normal = Vector3.Normalize(inNormal)
	self.m_Distance = -Vector3.Dot(inNormal, inPoint)
end

function Plane:Set3Points(a, b, c)
	self.m_Normal = Vector3.Normalize(
		Vector3.Cross(b - a, c - a)
	)
	self.m_Distance = -Vector3.Dot(self.m_Normal, a)
end

function Plane:Flip()
	self.m_Normal = -self.m_Normal
	self.m_Distance = -self.m_Distance
end

function Plane.Translate(plane, translation)
	local distance = plane.m_Distance
	distance += Vector3.Dot(plane.m_Normal, translation)
	return Plane.new(
		plane.m_Normal,
		distance
	)
end

function Plane:ClosestPointOnPlane(point)
	local d = Vector3.Dot(self.m_Normal, point) + self.m_Distance
	return point - self.m_Normal * d
end

function Plane:GetDistanceToPoint(point)
	return Vector3.Dot(self.m_Normal, point) + self.m_Distance
end

function Plane:GetSide(point)
	return Vector3.Dot(self.m_Normal, point) + self.m_Distance > 0
end

function Plane:SameSide(inPt0, inPt1)
	local distance1 = self:GetDistanceToPoint(inPt0)
	local distance2 = self:GetDistanceToPoint(inPt1)
	return (distance1 > 0 and distance2 > 0) or (distance1 <= 0 and distance2 <= 0)
end

--public bool Raycast(Ray ray, out float enter)
--Line: 212
--Plane Struct

function Plane.new(...)
	local self = setmetatable({}, {
		__index = function(t, index)
			local getter = Plane._Getters[index]
			local shortRef = Plane._Getters[Plane._ShortRefs[index]]
			local fieldRef = Plane._FieldRefs[index]
			
			if getter then
				return getter(t)
			elseif shortRef then
				return shortRef(t)
			elseif fieldRef then
				return t[fieldRef]
			end
			return Plane[index]
		end,
		__tostring = function(t)
			return t.__type ..
			"(normal:({" 
				.. t.m_Normal.x .. "}, {"
				.. t.m_Normal.y .. "}, {" 
				.. t.m_Normal.z .. "}), distance:{"
				.. t.m_Distance .. "})"
		end
	})
	
	local args = {...}
	if args[3] then
		self.m_Normal = Vector3.Normalize(
			Vector3.Cross(
				args[2] - args[1], args[3] - args[1]
			)
		)
		self.m_Distance = -Vector3.Dot(self.m_Normal, args[1])
	else
		self.m_Normal = Vector3.Normalize(args[1])
		if type(args[2]) == 'number' then
			self.m_Distance = args[2]
		else
			self.m_Distance = -Vector3.Dot(self.m_Normal, args[2])
		end
	end
	
	self:AddGetter("flipped", function(t)
		return Plane.new(-t.m_Normal, -t.m_Distance)
	end)
	
	self:AddFieldRef("normal", "m_Normal")
	self:AddFieldRef("distance", "m_Distance")
	
	return self
end
return Plane
