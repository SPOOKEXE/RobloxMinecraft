
local HttpService = game:GetService('HttpService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local SystemsContainer = {}

local BlockIDConfig = ReplicatedModules.Defined.BlockID

local GenerationConfig = ReplicatedModules.Defined.Generation
local ChunkSizeSquare = GenerationConfig.ChunkSizeSquare
local BlockScale = GenerationConfig.BlockScale

local Terrain = workspace.Terrain

-- // Module // --
local Module = {}

local function SetBlock( x, y, z, blockID )
	local Block = false
	if BlockIDConfig[blockID] then
		Block = ReplicatedStorage.Assets.Blocks:FindFirstChild( BlockIDConfig[blockID] )
	end
	if not Block then
		Block = ReplicatedStorage.Assets.Blocks.Unknown
	end
	Block = Block:Clone()
	Block.Name = table.concat({x, y, z, blockID}, " - ")
	local PositionCFrame = CFrame.new( x, y, z )
	if Block:IsA("Model") then
		Block:SetPrimaryPartCFrame(PositionCFrame)
	elseif Block:IsA("BasePart") then
		Block.CFrame = PositionCFrame
	else
		warn("Unknown Block ClassName Type.")
	end
	return Block
end

function Module:Visual( chunkX, chunkZ, chunkData )
	local chunkXStart = chunkX * ChunkSizeSquare * BlockScale
	local chunkZStart = chunkZ * ChunkSizeSquare * BlockScale

	local uncompressedBulk = ReplicatedModules.Utility.String.lualzw.decompress(chunkData.Data)
	local bulkDataTable = HttpService:JSONDecode(uncompressedBulk)
	--print(bulkDataTable)
	for x, t in pairs( bulkDataTable ) do
		for z, t2 in pairs( t ) do
			local yPosition, blockID = table.unpack(t2)

			local Block = SetBlock( x, yPosition, z, blockID )
			Block.Parent = Terrain[table.concat({chunkX, chunkZ}, "-")]

			local Adjacents = {}
			if bulkDataTable[tostring(x-BlockScale)] then
				table.insert( Adjacents, bulkDataTable[tostring(x-BlockScale)][tostring(z)] )
			end
			if bulkDataTable[tostring(x+BlockScale)] then
				table.insert( Adjacents, bulkDataTable[tostring(x+BlockScale)][tostring(z)] )
			end
			if bulkDataTable[tostring(x)][z-BlockScale] then
				table.insert( Adjacents, bulkDataTable[tostring(x)][tostring(z-BlockScale)] )
			end
			if bulkDataTable[tostring(x)][tostring(z+BlockScale)] then
				table.insert( Adjacents, bulkDataTable[tostring(x)][tostring(z+BlockScale)] )
			end

			local minHeight = yPosition
			for _, adjacentData in ipairs( Adjacents ) do
				if (not adjacentData.Checked) or (adjacentData.Checked <= yPosition) then
					minHeight = math.min(yPosition, adjacentData[1])
				end
			end

			for _, adjacentData in ipairs( Adjacents ) do
				if (not adjacentData.Checked) or adjacentData.Checked > minHeight then
					adjacentData.Checked = minHeight
				end
			end

			local counter = 0
			for currentHeight = yPosition, minHeight, -BlockScale do
				counter += 1
				local BlockBeneath = SetBlock( x, currentHeight-BlockScale, z, if counter < 3 then 3 else 5 )
				BlockBeneath.Name = table.concat({chunkX, chunkZ, currentHeight-BlockScale}, "-")
				BlockBeneath.Parent = Terrain[table.concat({chunkX, chunkZ}, "-")]
			end

		end
		task.wait()
	end
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems
end

return Module
