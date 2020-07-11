local Math = {}

Math.PI                   = math.pi
Math.Infinity             = 1/0
Math.NegativeInfinity     = 0/0
Math.Deg2Rad              = 0.0174532924
Math.Rad2Deg              = 57.29578
Math.localMinNormal       = 1.17549435E-38
Math.localMinDenormal     = 1.401298E-45
Math.IsFlushToZeroEnabled = Math.localMinDenormal == 0
Math.Epsilon              = not Math.IsFlushToZeroEnabled and Math.localMinDenormal or Math.localMinNormal

function Math.Sin(f)
	return math.sin(f)
end

function Math.Cos(f)
	return math.cos(f)
end

function Math.Tan(f)
	return math.tan(f)
end

function Math.Asin(f)
	return math.asin(f)
end

function Math.Acos(f)
	return math.acos(f)
end

function Math.Atan(f)
	return math.atan(f)
end

function Math.Atan2(y, x)
	return math.atan2(y, x)
end

function Math.Sqrt(f)
	return math.sqrt(f)
end

function Math.Abs(f)
	return math.abs(f)
end

function Math.Min(...)
	local values = {...}
	local num = #values
	local result
	if num == 0 then
		return 0
	else
		local num2 = values[1]
		for i = 2, num do
			if values[i] < num2 then
				num2 = values[i]
			end
		end
		return num2
	end
end

function Math.Max(...)
	local values = {...}
	local num = #values
	if num == 0 then
		return 0
	else
		local num2 = values[1]
		for i = 2, num do
			if values[i] > num2 then
				num2 = values[i]
			end
		end
		return num2
	end
end

function Math.Pow(f, p)
	return math.pow(f, p)
end

function Math.Exp(power)
	return math.exp(power)
end

function Math.Log(f)
	return math.log(f)
end

function Math.Log10(f)
	return math.log10(f)
end

function Math.Ceil(f)
	return math.ceil(f)
end

function Math.Floor(f)
	return math.floor(f)
end

function Math.Sign(f)
	if f < 0 then return -1 else return 1 end
end

function Math.Clamp(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	end
	return value
end

function Math.Clamp01(value)
	if value < 0 then
		return 0
	elseif value > 1 then
		return 1
	end
	return value
end

function Math.Lerp(a, b, t)
	return a + (b - a) * Math.Clamp01(t)
end

function Math.LerpUnclamped(a, b, t)
	return a + (b - a) * t
end

function Math.Repeat(t, length)
	return Math.Clamp(t - Math.Floor(t / length) * length, 0, length)
end

function Math.PingPong(t, length)
	t = Math.Repeat(t, length * 2)
	return length - Math.Abs(t - length)
end

function Math.LerpAngle(a, b, t)
	local num = Math.Repeat(b - a, 360)
	if num > 180 then
		num -= 360
	end
	return a + num * Math.Clamp01(t)
end

function Math.MoveTowards(current, target, maxDelta)
	if Math.Abs(target - current) <= maxDelta then
		return target
	else
		return current + Math.Sign(target - current) * maxDelta
	end
end

function Math.MoveTowardsAngle(current, target, maxDelta)
	local num = Math.DeltaAngle(current, target)
	if -maxDelta < num and num < maxDelta then
		return target
	else
		target = current + num
		return Math.MoveTowards(current, target, maxDelta)
	end
end

function Math.SmoothStep(from, to, t)
	t = Math.Clamp01(t)
	t = -2 * t * t * t + 3 * t * t
	return to * t + from * (1 - t)
end

function Math.Gamma(value, absmax, gamma)
	local flag = false
	if value < 0 then
		flag = true
	end
	
	local num = Math.Abs(value)
	if num > absmax then
		if not flag then
			return num
		else
			return -num
		end
	else
		local num2 = Math.Pow(num / absmax, gamma) * absmax
		if not flag then
			return num2
		else
			return -num2
		end
	end
end

function Math.Approximately(a, b)
	return Math.Abs(b - a) < Math.Max(1E-06 * Math.Max(Math.Abs(a), Math.Abs(b)), Math.Epsilon * 8)
end

-- returns num8, and currentVelocity
function Math.SmoothDamp(current, target, smoothTime, maxSpeed, currentVelocity)
	local deltaTime = game:GetService("RunService").Heartbeat:Wait()
	smoothTime = Math.Max(0.0001, smoothTime)
	local num = 2 / smoothTime
	local num2 = num * deltaTime
	local num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
	local num4 = current - target
	local num5 = target
	local num6 = maxSpeed * smoothTime
	num4 = Math.Clamp(num4, -num6, num6)
	target = current - num4
	
	local num7 = (currentVelocity + num * num4) * deltaTime
	currentVelocity = (currentVelocity - num * num7) * num3
	local num8 = target + (num4 + num7) * num3
	if num5 - current > 0 == num8 > num5 then
		num8 = num5
		currentVelocity = (num8 - num5) / deltaTime
	end
	return num8, currentVelocity
end

function Math.SmoothDampAngle(current, target, smoothTime, maxSpeed, currentVelocity)
	target = current + Math.DeltaAngle(current, target)
	return Math.SmoothDamp(current, target, smoothTime, maxSpeed, currentVelocity)
end

function Math.InverseLerp(a, b, value)
	if a ~= b then
		return Math.Clamp01((value - a) / (b - a))
	else
		return 0
	end
end

function Math.DeltaAngle(current, target)
	local num = Math.Repeat(target - current, 360)
	if num > 180 then
		num -= 360
	end
	return num
end

function Math.LineIntersection(p1, p2, p3, p4)
	local num = p2.x - p1.x
	local num2 = p2.y - p1.y
	local num3 = p4.x - p3.x
	local num4 = p4.y - p3.y
	local num5 = num * num4 - num2 * num3
	local result2
	local result
	
	if num5 == 0 then
		result2 = false
	else
		local num6 = p3.x - p1.x
		local num7 = p3.y - p1.y
		local num8 = (num6 * num4 - num7 * num3) / num5
		result = Vector2.new(p1.x + num8 * num, p1.y + num8 * num2) -- TODO: UnityClassConverter
		result2 = true
	end
	return result2, result
end

function Math.LineSegmentIntersection(p1, p2, p3, p4)
	local num = p2.x - p1.x
	local num2 = p2.y - p1.y
	local num3 = p4.x - p3.x
	local num4 = p4.y - p3.y
	local num5 = num * num4 - num2 * num3
	local result2, result
	if num5 == 0 then
		result2 = false
	else
		local num6 = p3.x - p1.x
		local num7 = p3.y - p1.y
		local num8 = (num6 * num4 - num7 * num3) / num5
		if num8 < 0 or num8 > 1 then
			result2 = false
		else
			local num9 = (num6 * num2 - num7 * num) / num5
			if num9 < 0 or num9 > 1 then
				result2 = false
			else
				result = Vector2.new(p1.x + num8 * num, p1.y + num8 * num2) -- TODO: UnityClassConverter
				result2 = true
			end
		end
	end
	return result2;
end

return Math
