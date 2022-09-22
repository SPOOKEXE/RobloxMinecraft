local ITERATIONS = 8

-- // Class // --
local Class = {}
Class.__index = Class

function Class.New(mass, force, damping, speed)
	local self = {
		Target = Vector3.new(),
		Position = Vector3.new(),
		Velocity = Vector3.new(),

		Mass = mass or 5,
		Force = force or 50,
		Damping    = damping or 4,
		Speed = speed  or 4,
	}

	return self
end

function Class:Shove(_force)
	self.Velocity += _force
end

function Class:Update(dt)
	local scaledDeltaTime = math.min(dt, 1) * self.Speed / ITERATIONS

	for _ = 1, ITERATIONS do
		local iterationForce = self.Target - self.Position
		local acceleration = (iterationForce * self.Force) / self.Mass

		acceleration = acceleration - self.Velocity * self.Damping

		self.Velocity += acceleration * scaledDeltaTime
		self.Position += self.Velocity * scaledDeltaTime
	end

	return self.Position
end

return Class