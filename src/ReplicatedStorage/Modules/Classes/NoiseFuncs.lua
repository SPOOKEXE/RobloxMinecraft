
local Module = {}

function Module.RigidNoise( noiseValue )
	return 2 * (0.5 - math.abs(0.5 - noiseValue));
end

function Module.Terraces( noiseValue, steps )
	steps = steps or 4
	return math.round( noiseValue * steps ) / steps
end

function Module.Redistribution( noiseValue, exp )
	return math.pow( noiseValue, exp )
end

return Module
