
local function checkN0(n)
	if n == 0 then
		return 1
	end
	return n
end

-- // Class // --
local Noise2D = {}
Noise2D.__index = Noise2D

function Noise2D.New(seed, amplitude, mapScale)
	return setmetatable({
		seed = seed or Random.new():NextNumber(),
		amplitude = checkN0(amplitude or 1),
		map_scale = checkN0(mapScale or 128),
		pre_final_methods = { },
		post_final_methods = { },
	}, Noise2D)
end

function Noise2D:Get(x, y)
	local noiseValue = math.noise( self.seed, x / self.map_scale, y / self.map_scale )
	for _, method in ipairs( self.pre_final_methods ) do
		method(noiseValue)
	end
	noiseValue *= self.amplitude
	for _, method in ipairs( self.post_final_methods ) do
		method(noiseValue)
	end
	return noiseValue
end

function Noise2D:AppendPreMethod( noiseMethod, index )
	if index then
		table.insert(self.pre_final_methods, index, noiseMethod)
	else
		table.insert(self.pre_final_methods, noiseMethod)
	end
end

function Noise2D:AppendPostMethod( noiseMethod, index )
	if index then
		table.insert(self.post_final_methods, index,  noiseMethod)
	else
		table.insert(self.post_final_methods, noiseMethod)
	end
end

function Noise2D:PopPreMethod()
	local index = #self.pre_final_methods
	if index > 0 then
		table.remove(self.pre_final_methods, index)
	end
end

function Noise2D:PopPostMethod()
	local index = #self.post_final_methods
	if index > 0 then
		table.remove(self.post_final_methods, index)
	end
end

function Noise2D:ClearPreMethods()
	self.pre_final_methods = {}
end

function Noise2D:ClearPostMethods()
	self.post_final_methods = {}
end

return Noise2D

