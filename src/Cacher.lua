
warn([[𝓢𝓟𝓞𝓞𝓚_𝓔𝓧𝓔 𝓕𝓡𝓐𝓜𝓔𝓦𝓞𝓡𝓚]])

local Promise = require( game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild('Promise') )

local function promiseErrorHandler(...)
	task.defer(warn, ...)
end

local function hasInit( tbl )
	return tbl.Init or (getmetatable(tbl) and getmetatable(tbl).Init)
end

local Class = {}
Class.__index = Class
Class.__newindex = function( _, _ )
	error(script:GetFullName()..' is locked.')
end

local Cache = {}

local function Preload(Parent)
	if not Cache[Parent] then

		Cache[Parent] = { }
		for _, ModuleScript in ipairs(Parent:GetChildren()) do
			Promise.new(function()
				Cache[Parent][ModuleScript.Name] = require(ModuleScript)
			end):catch(promiseErrorHandler)
		end

		setmetatable(Cache[Parent], Class)

		for preLoadedName, preLoaded in pairs(Cache[Parent]) do
			if preLoaded.Initialised or (not hasInit(preLoaded)) then
				continue
			end
			local accessibles = { ParentSystems = Cache[Parent.Parent] }
			for otherLoadedName, differentLoaded in pairs(Cache[Parent]) do
				if preLoadedName ~= otherLoadedName then
					accessibles[otherLoadedName] = differentLoaded
				end
			end
			preLoaded.Initialised = true
			Promise.new(function()
				preLoaded:Init(accessibles)
			end):catch(promiseErrorHandler)
		end

		Parent.ChildAdded:Connect(function(ModuleScript)
			if ModuleScript:IsA("ModuleScript") then
				Promise.new(function()
					return require(ModuleScript)
				end):andThen(function(activeModule)
					Cache[Parent][ModuleScript.Name] = activeModule
					if hasInit( activeModule ) then
						local accessibles = { ParentSystems = Cache[Parent.Parent] }
						for otherLoadedName, differentLoaded in pairs(Cache[Parent]) do
							if ModuleScript.Name ~= otherLoadedName then
								accessibles[otherLoadedName] = differentLoaded
							end
						end
						activeModule:Init(accessibles)
					end
				end):catch(promiseErrorHandler)
			end
		end)

	end
	return Cache[Parent]
end

function Class.New( Parent )
	return Cache[Parent] or Preload(Parent)
end

return Class