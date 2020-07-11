local UnityEngine = script.Parent
local Math = require(UnityEngine.Math)

local _Vector3 = {}

_Vector3.__type     = 'Vector3'
_Vector3._Getters = {}
_Vector3._ShortRefs = {}
_Vector3._FieldRefs = {}

_Vector3.x = nil
_Vector3.y = nil
_Vector3.z = nil

function _Vector3:AddGetter(name, func)
	self._Getters[name] = func
end

function _Vector3:AddShortRef(shortName, longName)
	self._ShortRefs[shortName] = longName
end

function _Vector3:AddFieldRef(refName, fieldName)
	self._FieldRefs[refName] = fieldName
end

function _Vector3.Lerp(a, b, t)
	t = Math.Clamp01(t)
	return _Vector3.new(
		a.x + (b.x - a.x) * t,
		a.y + (b.y - a.y) * t,
		a.z + (b.z - a.z) * t
	)
end

function _Vector3.LerpUnclamped(a, b, t)
	return _Vector3.new(
		a.x + (b.x - a.x) * t,
		a.y + (b.y - a.y) * t,
		a.z + (b.z - a.z) * t
	)
end

function _Vector3.MoveTowards(current, target, maxDistanceDelta)
	local a = target - current
	local magnitude = a.magnitude
	if magnitude <= maxDistanceDelta or magnitude < 1.401298E-45 then
		return target
	else
		return current + a / magnitude * maxDistanceDelta
	end
end

function _Vector3.SmoothDamp(current, target, smoothTime, maxSpeed, currentVelocity)
	local deltaTime = game:GetService("RunService").Heartbeat:Wait()
	smoothTime = Math.Max(0.0001, smoothTime)
	local num = 2 / smoothTime
	local num2 = num * deltaTime
	local d = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
	local vector = current - target
	local vector2 = target
	local maxLength = maxSpeed * smoothTime
	vector = _Vector3.ClampMagnitude(vector, maxLength)
	target = current - vector
	local vector3 = (currentVelocity + num * vector) * deltaTime
	currentVelocity = (currentVelocity - num * vector3) * d
	local vector4 = target + (vector + vector3) * d
	if _Vector3.Dot(vector2 - current, vector4 - vector2) > 0 then
		vector4 = vector2
		currentVelocity = (vector4 - vector2) / deltaTime
	end
	return vector4, currentVelocity
end

function _Vector3.Reflect(inDirection, inNormal)
	return -2 * _Vector3.Dot(inNormal, inDirection) * inNormal + inDirection
end

function _Vector3.Normalize(value)
	local num = value.magnitude
	if num > 1E-05 then
		return value / num
	else
		return _Vector3.zero
	end
end

function _Vector3.Dot(lhs, rhs)
	return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
end

function _Vector3.Project(vector, onNormal)
	local num = _Vector3.Dot(onNormal, onNormal)
	if num < Math.Epsilon then
		return _Vector3.zero
	else
		return onNormal * _Vector3.Dot(vector, onNormal) / num
	end
end

function _Vector3.ProjectOnPlane(vector, planeNormal)
	return vector - _Vector3.Project(vector, planeNormal)
end

function _Vector3.Angle(from, to)
	local num = Math.Sqrt(from.sqrMagnitude * to.sqrMagnitude)
	if num < 1E-15 then
		return 0
	else
		local f = Math.Clamp(_Vector3.Dot(from, to) / num, -1, 1)
		return Math.Acos(f) * 57.29578
	end
end

function _Vector3.SignedAngle(from, to, axis)
	local num = _Vector3.Angle(from, to)
	local num2 = Math.Sign(_Vector3.Dot(axis, _Vector3.Cross(from, to)))
	return num * num2
end

function _Vector3.Distance(a, b)
	local vector = _Vector3.new(a.x - b.x, a.y - b.y, a.z - b.z)
	return Math.Sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
end

function _Vector3.ClampMagnitude(vector, maxLength)
	if vector.sqrMagnitude > maxLength * maxLength then
		return vector.normalized * maxLength
	else
		return vector
	end
end

function _Vector3.Min(lhs, rhs)
	return _Vector3.new(
		Math.Min(lhs.x, rhs.x),
		Math.Min(lhs.y, rhs.y),
		Math.Min(lhs.z, rhs.z)
	)
end

function _Vector3.Max(lhs, rhs)
	return _Vector3.new(
		Math.Max(lhs.x, rhs.x),
		Math.Max(lhs.y, rhs.y),
		Math.Max(lhs.z, rhs.z)
	)
end

function _Vector3.AngleBetween(from, to)
	return Math.Acos(Math.Clamp(_Vector3.Dot(from.normalized, to.normalized), -1, 1))
end

function _Vector3:Set(newX, newY, newZ)
	self.x = newX
	self.y = newY
	self.z = newZ
	return self
end

function _Vector3:Scale(scale)
	self.x *= scale.x
	self.y *= scale.y
	self.z *= scale.z
	return self
end

function _Vector3:Cross(lhs, rhs)
	return _Vector3.new(
		lhs.y * rhs.z - lhs.z * rhs.y,
		lhs.z * rhs.x - lhs.x * rhs.z,
		lhs.x * rhs.y - lhs.y * rhs.x
	)
end

function _Vector3.new(x, y, z)
	local self = setmetatable({}, {
		__index = function(t, index)
			local getter = _Vector3._Getters[index]
			local shortRef = _Vector3._Getters[_Vector3._ShortRefs[index]]
			local fieldRef = _Vector3._FieldRefs[index]
			
			if getter then
				return getter(t)
			elseif shortRef then
				return shortRef(t)
			elseif fieldRef then
				return t[fieldRef]
			end
			return _Vector3[index]
		end,
		__add = function(t, v)
			if not v.x or not v.y or not v.z then
				error("argument 2 missing field x, y, or z.")
			end
			return _Vector3.new(
				t.x + v.x,
				t.y + v.y,
				t.z + v.z
			)
		end,
		__sub = function(t, v)
			if not v.x or not v.y or not v.z then
				error("argument 2 missing field x, y, or z.")
			end
			return _Vector3.new(
				t.x - v.x,
				t.y - v.y,
				t.z - v.z
			)
		end,
		__mul = function(t, v)
			local mulX, mulY, mulZ
			if type(v) == 'number' then
				mulX, mulY, mulZ = v, v, v
			elseif v.x and v.y and v.z then
				mulX, mulY, mulZ = v.x, v.y, v.z
			else
				error("not a valid type to multiply by.")
			end
			
			return _Vector3.new(
				t.x * mulX,
				t.y * mulY,
				t.z * mulZ
			)
		end,
		__div = function(t, v)
			local divX, divY, divZ
			if type(v) == 'number' then
				divX, divY, divZ = v, v, v
			elseif v.x and v.y then
				divX, divY, divZ = v.x, v.y, v.z
			else
				error("not a valid type to divide by.")
			end
			
			return _Vector3.new(
				t.x / divX,
				t.y / divY,
				t.z / divZ
			)
		end,
		__eq = function(lhs, rhs)
			return (lhs - rhs).magnitude < 9.99999944E-11
		end,
		__tostring = function(t)
			return t.__type .. ": " .. t.x .. ", " .. t.y .. ", " .. t.z
		end
	})
	
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	
	self:AddGetter("SqrMagnitude", function(t)
		return t.x * t.x + t.y * t.y + t.z * t.z
	end)
	self:AddShortRef("sqrMagnitude", "SqrMagnitude")
	
	self:AddGetter("Magnitude", function(t)
		return math.sqrt(t.SqrMagnitude)
	end)
	self:AddShortRef("magnitude", "Magnitude")
	
	self:AddFieldRef(1, "x")
	self:AddFieldRef("X", "x")
	
	self:AddFieldRef(2, "y")
	self:AddFieldRef("Y", "y")
	
	self:AddFieldRef(3, "z")
	self:AddFieldRef("Z", "z")
	
	return self
end

local zeroVector = _Vector3.new(0, 0, 0)
_Vector3.zero = zeroVector

local oneVector = _Vector3.new(1, 1, 1)
_Vector3.one = oneVector

local forwardVector = _Vector3.new(0, 0, 1)
_Vector3.forward = forwardVector

local backVector = _Vector3.new(0, 0, -1)
_Vector3.back = backVector

local upVector = _Vector3.new(0, 1, 0)
_Vector3.up = upVector

local downVector = _Vector3.new(0, -1, 0)
_Vector3.down = downVector

local leftVector = _Vector3.new(-1, 0, 0)
_Vector3.left = leftVector

local rightVector = _Vector3.new(1, 0, 0)
_Vector3.right = rightVector

local positiveInfinityVector = _Vector3.new(1/0, 1/0, 1/0)
_Vector3.positiveInfinity = positiveInfinityVector

local negativeInfinityVector = _Vector3.new(0/0, 0/0, 0/0)
_Vector3.negativeInfinity = negativeInfinityVector

return _Vector3
