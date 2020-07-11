local UnityEngine = script.Parent
local Math = require(UnityEngine.Math)

local _Vector2 = {}

_Vector2.__type     = 'Vector2'
_Vector2._Getters = {}
_Vector2._ShortRefs = {}
_Vector2._FieldRefs = {}

_Vector2.x = nil
_Vector2.y = nil

function _Vector2:AddGetter(name, func)
	self._Getters[name] = func
end

function _Vector2:AddShortRef(shortName, longName)
	self._ShortRefs[shortName] = longName
end

function _Vector2:AddFieldRef(refName, fieldName)
	self._FieldRefs[refName] = fieldName
end

function _Vector2.MoveTowards(current, target, maxDistanceDelta)
	local a = target - current
	local magnitude = a.magnitude
	local result
	if magnitude <= maxDistanceDelta or magnitude == 0 then
		result = target
	else
		result = current + a / magnitude * maxDistanceDelta
	end
	return result
end

function _Vector2.Lerp(a, b, t)
	t = Math.Clamp01(t)
	return _Vector2.new(
		a.x + (b.x - a.x) * t,
		a.y + (b.y - a.y) * t
	)
end

function _Vector2.LerpUnclamped(a, b, t)
	return _Vector2.new(
		a.x + (b.x - a.x) * t,
		a.y + (b.y - a.y) * t
	)
end

function _Vector2:Scale(b)
	self.x *= b.x
	self.y *= b.y
	return self
end

function _Vector2.Reflect(inDirection, inNormal)
	return -2 * _Vector2.Dot(inNormal, inDirection) * inNormal + inDirection
end

function _Vector2.Perpendicular(inDirection)
	return _Vector2.new(-inDirection.y, inDirection.x)	
end

function _Vector2.Dot(lhs, rhs)
	return lhs.x * rhs.x + lhs.y * rhs.y
end

function _Vector2.Angle(from, to)
	local num = Math.Sqrt(from.sqrMagnitude * to.sqrMagnitude)
	if num < 1E-15 then
		return 0
	else
		return Math.Acos(Math.Clamp(_Vector2.Dot(from, to) / num, -1, 1)) * 57.29578
	end
end

function _Vector2.SignedAngle(from, to)
	local num = _Vector2.Angle(from, to)
	local num2 = Math.Sign(from.x * to.y - from.y * to.x)
	return num * num2
end

function _Vector2.Distance(a, b)
	return (a - b).magnitude
end

function _Vector2.ClampMagnitude(vector, maxLength)
	if vector.sqrMagnitude > maxLength * maxLength then
		return vector.normalized * maxLength
	else
		return vector
	end
end

function _Vector2.SqrMagnitude(a)
	return a.x * a.x + a.y * a.y
end

function _Vector2.Min(lhs, rhs)
	return _Vector2.new(
		Math.Min(lhs.x, rhs.x), 
		Math.Min(lhs.y, rhs.y)
	)
end

function _Vector2.Max(lhs, rhs)
	return _Vector2.new(
		Math.Max(lhs.x, rhs.x),
		Math.Max(lhs.y, rhs.y)
	)
end

function _Vector2.SmoothDamp(current, target, smoothTime, maxSpeed, currentVelocity)
	local deltaTime = game:GetService("RunService").Heartbeat:Wait()
	smoothTime = Math.Max(0.0001, smoothTime)
	local num = 2 / smoothTime
	local num2 = num * deltaTime
	local d = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
	local vector = current - target
	local vector2 = target
	local maxLength = maxSpeed * smoothTime
	vector = _Vector2.ClampMagnitude(vector, maxLength)
	target = current - vector
	local vector3 = (currentVelocity + num * vector) * deltaTime
	currentVelocity = (currentVelocity - num * vector3) * d
	local vector4 = target + (vector + vector3) * d
	if _Vector2.Dot(vector2 - current, vector4 - vector2) > 0 then
		vector4 = vector2
		currentVelocity = (vector4 - vector2) / deltaTime
	end
	return vector4, currentVelocity
end

function _Vector2.new(x, y)
	local self = setmetatable({}, {
		__index = function(t, index)
			local getter = _Vector2._Getters[index]
			local shortRef = _Vector2._Getters[_Vector2._ShortRefs[index]]
			local fieldRef = _Vector2._FieldRefs[index]
			
			if getter then
				return getter(t)
			elseif shortRef then
				return shortRef(t)
			elseif fieldRef then
				return t[fieldRef]
			end
			return _Vector2[index]
		end,
		__add = function(t, v)
			if not v.x or not v.y then
				error("argument 2 missing field x, or y.")
			end
			return _Vector2.new(
				t.x + v.x,
				t.y + v.y
			)
		end,
		__sub = function(t, v)
			if not v.x or not v.y then
				error("argument 2 missing field x, or y.")
			end
			return _Vector2.new(
				t.x - v.x,
				t.y - v.y
			)
		end,
		__mul = function(t, v)
			local mulX, mulY
			if type(v) == 'number' then
				mulX, mulY = v, v
			elseif v.x and v.y then
				mulX, mulY = v.x, v.y
			else
				error("not a valid type to multiply by.")
			end
			
			return _Vector2.new(
				t.x * mulX,
				t.y * mulY
			)
		end,
		__div = function(t, v)
			local mulX, mulY
			if type(v) == 'number' then
				mulX, mulY = v, v
			elseif v.x and v.y then
				mulX, mulY = v.x, v.y
			else
				error("not a valid type to divide by.")
			end
			
			return _Vector2.new(
				t.x / mulX,
				t.y / mulY
			)
		end,
		__eq = function(lhs, rhs)
			return (lhs - rhs).sqrMagnitude < 9.99999944E-11
		end,
		__tostring = function(t)
			return t.__type .. ": " .. t.x .. ", " .. t.y
		end
	})
	
	self.x = x or 0
	self.y = y or 0
	
	self:AddGetter("SqrMagnitude", function(t)
		return t.x * t.x + t.y * t.y
	end)
	self:AddShortRef("sqrMagnitude", "SqrMagnitude")
	
	self:AddGetter("Magnitude", function(t)
		return math.sqrt(t.SqrMagnitude)
	end)
	self:AddShortRef("magnitude", "Magnitude")
	
	self:AddGetter("Normalized", function(t)
		return _Vector2.new(t.x, t.y):Normalize()
	end)
	
	self:AddShortRef("normalized", "Normalized")
	self:AddShortRef("unit", "Normalized")
	self:AddShortRef("Unit", "Normalized")
	
	self:AddFieldRef(1, "x")
	self:AddFieldRef("X", "x")
	
	self:AddFieldRef(2, "y")
	self:AddFieldRef("Y", "y")
	
	return self
end

local zeroVector = _Vector2.new(0,  0)
_Vector2.zero = zeroVector

local oneVector = _Vector2.new(1,  1)
_Vector2.one = oneVector

local upVector    = _Vector2.new(0,  1)
_Vector2.up = upVector

local downVector  = _Vector2.new(0, -1)
_Vector2.down = downVector

local leftVector  = _Vector2.new(-1, 0)
_Vector2.left = leftVector

local rightVector = _Vector2.new(1,  0)
_Vector2.right = rightVector

local positiveInfinityVector = _Vector2.new(1/0,  1/0)
_Vector2.positiveInfinity = positiveInfinityVector

local negativeInfinityVector = _Vector2.new(0/0,  0/0)
_Vector2.negativeInfinity = negativeInfinityVector

function _Vector2:Normalize()
	local magnitude = self.magnitude
	if magnitude > 1E-05 then
		self /= magnitude
	else
		self = _Vector2.zero
	end
	return self
end

return _Vector2
