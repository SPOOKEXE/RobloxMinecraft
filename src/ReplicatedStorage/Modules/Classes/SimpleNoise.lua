
local function checkN0(n)
	return (n == 0) and 1 or n
end

-- // Noise 2D // --
local Simple2D = {}
Simple2D.__index = Simple2D

function Simple2D.New(seed, amplitude, mapScale)
	return setmetatable({
		seed = seed or Random.new():NextNumber(),
		amplitude = checkN0(amplitude or 1),
		map_scale = checkN0(mapScale or 128),
		pre_final_methods = { },
		post_final_methods = { },
		_cache = { },
	}, Simple2D)
end

function Simple2D:Get(x, y)
	local index = x.."-"..y
	local noiseValue = self._cache[index]
	if noiseValue then
		return noiseValue
	end
	noiseValue = math.noise( self.seed, x / self.map_scale, y / self.map_scale )
	for _, method in ipairs( self.pre_final_methods ) do
		method(noiseValue)
	end
	noiseValue *= self.amplitude
	for _, method in ipairs( self.post_final_methods ) do
		method(noiseValue)
	end
	self._cache[index] = noiseValue
	return noiseValue
end

function Simple2D:AppendPreMethod( noiseMethod, index )
	if index then
		index = math.clamp(index, 1, #self.pre_final_methods)
		table.insert(self.pre_final_methods, index, noiseMethod)
	else
		table.insert(self.pre_final_methods, noiseMethod)
	end
end

function Simple2D:AppendPostMethod( noiseMethod, index )
	if index then
		index = math.clamp(index, 1, #self.post_final_methods)
		table.insert(self.post_final_methods, index,  noiseMethod)
	else
		table.insert(self.post_final_methods, noiseMethod)
	end
end

function Simple2D:PopPreMethod()
	local index = #self.pre_final_methods
	if index > 0 then
		table.remove(self.pre_final_methods, index)
	end
end

function Simple2D:PopPostMethod()
	local index = #self.post_final_methods
	if index > 0 then
		table.remove(self.post_final_methods, index)
	end
end

function Simple2D:ClearPreMethods()
	self.pre_final_methods = {}
end

function Simple2D:ClearPostMethods()
	self.post_final_methods = {}
end

-- // Noise 3D // --
local Simple3D = setmetatable({}, Simple2D)
Simple3D.__index = Simple3D

function Simple3D.New(...)
	local self = setmetatable(Simple2D.New(...), Simple3D)
	self.rX = Random.new():NextNumber()
	self.rY = Random.new():NextNumber()
	return self
end

function Simple3D:Get(x, y, z)
	local index = x.."-"..y.."-"..z
	local baseNoiseValue = self._cache[index]
	if baseNoiseValue then
		return baseNoiseValue
	end
	baseNoiseValue = math.noise(self.seed, self.rX, self.rY) * math.noise( x / self.map_scale, y / self.map_scale, z / self.map_scale )
	for _, method in ipairs( self.pre_final_methods ) do
		method(baseNoiseValue)
	end
	baseNoiseValue *= self.amplitude
	for _, method in ipairs( self.post_final_methods ) do
		method(baseNoiseValue)
	end
	self._cache[index] = baseNoiseValue
	return baseNoiseValue
end

return {Simple2D = Simple2D, Simple3D = Simple3D}

