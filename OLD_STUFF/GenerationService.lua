-- https://www.redblobgames.com/maps/terrain-from-noise/

local HttpService = game:GetService('HttpService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local SystemsContainer = {}

local ChunkData = {}

local GenerationConfig = ReplicatedModules.Defined.Generation
local ChunkSizeSquare = GenerationConfig.ChunkSizeSquare
local RenderDistance = GenerationConfig.RenderDistance
local BlockScale = GenerationConfig.BlockScale

local Terrain = workspace.Terrain
local Materials = Enum.Material:GetEnumItems()

-- // Module // --
local Module = { ChunkData = ChunkData, NoiseMap = false }

function Module:Generate( chunkX, chunkZ )
	local xStart = (chunkX * ChunkSizeSquare * BlockScale)
	local zStart = (chunkZ * ChunkSizeSquare * BlockScale)

	local xEnd = xStart + (ChunkSizeSquare * BlockScale)
	local zEnd = zStart + (ChunkSizeSquare * BlockScale)

	print( "X: ", Vector2.new(xStart, xEnd), "Z: ", Vector2.new(zStart, zEnd) )

	local DataTable = {}

	Instance.new('Folder', Terrain).Name = table.concat({chunkX, chunkZ}, "-")

	for x = xStart, xEnd, BlockScale do
		if not DataTable[x] then
			DataTable[x] = {}
		end
		for z = zStart, zEnd, BlockScale do
			if not DataTable[x][z] then
				local y = Module.NoiseMap:Get(x, z)
				y = 40 + (math.round(y / BlockScale) * BlockScale)
				local blockID = 2
				DataTable[x][z] = {y, blockID}
			end
		end
	end

	local bulkDataString = HttpService:JSONEncode(DataTable)
	local bulkDataCompressed = ReplicatedModules.Utility.String.lualzw.compress(bulkDataString)
	ChunkData[chunkX][chunkZ].Data = bulkDataCompressed
end

function Module:Load( chunkX, chunkZ )
	local DoGenerate = false
	if not ChunkData[chunkX] then
		ChunkData[chunkX] = { }
	end
	if not ChunkData[chunkX][chunkZ] then
		ChunkData[chunkX][chunkZ] = { Loaded = false, Data = false }
		DoGenerate = true
	end
	if DoGenerate then
		Module:Generate( chunkX, chunkZ )
	end
	ChunkData[chunkX][chunkZ].Loaded = true
	return ChunkData[chunkX][chunkZ]
end

function Module:Unload( chunkX, chunkZ )
	if ChunkData[chunkX] and ChunkData[chunkX][chunkZ] then
		ChunkData[chunkX][chunkZ].Loaded = false
	end
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	local SeedNumber = Random.new():NextNumber()
	print("Seed; ", SeedNumber)
	Module.NoiseMap = ReplicatedModules.Classes.Noise2D.SimpleNoise.New( SeedNumber, 80, 64 )
	--Module.NoiseMap:AppendPostMethod( ReplicatedModules.Classes.NoiseFuncs.RigidNoise )
	--Module.NoiseMap:AppendPostMethod( ReplicatedModules.Classes.NoiseFuncs.Terraces )

	for x = -RenderDistance / 2, RenderDistance / 2, 1 do
		for z = -RenderDistance / 2, RenderDistance / 2, 1 do
			local Data = Module:Load(x, z)
			task.delay(0.5, function()
				SystemsContainer.DebugVisualService:Visual( x, z, Data )
			end)
		end
	end

end

return Module
