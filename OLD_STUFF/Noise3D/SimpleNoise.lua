
local Noise2D = require(script.Parent.Parent.Noise2D)

local function checkN0(n)
	if n == 0 then
		return 1
	end
	return n
end

-- // Class // --
local Noise3D = setmetatable({}, Noise2D.SimpleNoise)
Noise3D.__index = Noise3D

function Noise3D.New(...)
	local self = setmetatable(Noise2D.New(...), Noise3D)
	self.rX = Random.new():NextNumber()
	self.rY = Random.new():NextNumber()
	return self
end

function Noise3D:Get(x, y, z)
	local baseNoiseValue = math.noise(self.seed, self.rX, self.rY) * math.noise( x / self.map_scale, y / self.map_scale, z / self.map_scale )
	for _, method in ipairs( self.pre_final_methods ) do
		method(baseNoiseValue)
	end
	baseNoiseValue *= self.amplitude
	for _, method in ipairs( self.post_final_methods ) do
		method(baseNoiseValue)
	end
	return baseNoiseValue
end

return Noise3D

