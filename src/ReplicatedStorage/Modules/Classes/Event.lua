-- SPOOK_EXE

export type EventClass = {
	B : BindableEvent,
	E : RBXScriptSignal,
	Fire : (any?),
	Wait : (any?),
	Connect : (any) -> RBXScriptConnection,
	DisconnectAll : (any?)
}

local container = Instance.new('Folder')
container.Name = '_bindabless'
container.Parent = game:GetService(game:GetService('RunService'):IsServer() and 'ServerStorage' or 'ReplicatedStorage')

-- // Class // --
local Event = {}
Event.__index = Event

function Event.New(customName)
	local connectionBindable = Instance.new('BindableEvent')
	connectionBindable.Name = customName or 'EVENT_'..debug.traceback()
	connectionBindable.Parent = container
	local self = {B = connectionBindable, E = connectionBindable.Event}
	setmetatable(self, Event)
	return self
end

function Event:Fire(...)
	self.B:Fire(...)
end

function Event:Wait(...)
	self.E:Wait(...)
end

function Event:Connect(...)
	self.E:Connect(...)
end

function Event:DisconnectAll()
	self.E:Disconnect()
	self.B:Destroy()
	setmetatable(self, nil)
end

return Event

-- SPOOK_EXE