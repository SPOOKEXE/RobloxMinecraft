
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local SimpleNoiseModule = ReplicatedModules.Classes.SimpleNoise
local GenerationData = ReplicatedModules.Defined.GenerationData
local NoiseFunctions = ReplicatedModules.Utility.NoiseFuncs

local SystemsContainer = {}

local Terrain = workspace.Terrain

-- // Module //. --
local Module = {}

Module.GeneratedChunks = {}
Module.NoiseMap = SimpleNoiseModule.Simple2D.New(false, 25, 100)

-- Calculate the noise value given the x, z
-- TODO: Add support for multi-threading techniques
function Module:CalculateAt(x, z)
	print("Calculate Noise At ; ", x, z)
	return Module.NoiseMap:Get(x, z)
end

-- Calculate the values for a section of land
-- TODO: Add support for multi-threading techniques
function Module:CalculateSection(x, z, width, depth)
	for x_cord = x, x + width do
		for z_cord = z, z + depth do
			task.defer(function()
				Module:Generate(x_cord, z_cord)
			end)
		end

		if x_cord % 50 == 0 then
			task.wait()
		end
	end
end

-- Generate one section of land at the given x,z
-- TODO: Add support for multi-threading techniques
function Module:Generate(x, z)
	if Module.GeneratedChunks[x] and Module.GeneratedChunks[x][z] then
		return
	end
	print("Generate Terrain At ; ", x, z)
	local noiseHeightValue = Module.NoiseMap:Get(x, z)

	local CF = CFrame.new(x * GenerationData.BlockScale, noiseHeightValue, z * GenerationData.BlockScale)
	local Size = Vector3.new(GenerationData.BlockScale, 8, GenerationData.BlockScale)
	Terrain:FillBlock(CF, Size, Enum.Material.Grass)
end

-- Generate sections of land at once given the starting x, z, and the section lengths
-- TODO: Add support for multi-threading techniques
function Module:GenerateSection(x, z, width, depth)
	for x_cord = x, x + width do
		for z_cord = z, z + depth do
			task.defer(function()
				Module:Generate(x_cord, z_cord)
			end)
		end
	end
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	Module:GenerateSection(-25, -25, 50, 50)
end

return Module


