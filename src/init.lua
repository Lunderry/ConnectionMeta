---@diagnostic disable: undefined-doc-name
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
export type MetaConnection<T> = {
	pack: any,
	Add: (self: MetaConnection<T>, ...T) -> ...T | T,
	Disconnect: (self: MetaConnection<T>, q: number | T?) -> (),
	Destroy: (self: MetaConnection<T>) -> (),
	Unpack: (self: MetaConnection<T>) -> ...T,
}

local MetaData = require(script.MetaData)

local module = {}

local function selection<T>(specificType: string): { meta: {}, funct: any }
	return MetaData.Disconnect[specificType]
end

local function disconnect<T>(specificType: string, value: T): ()
	selection(specificType).funct(value)
end

---create MetaConnection, specificType is for select type save
---@param specificType string?
---@return any
function module.new<T>(specificType: string | "RBXScriptConnection" | "thread"): MetaConnection<T>
	local tb = { pack = {} } :: MetaConnection<T>
	tb.pack = setmetatable({}, selection(specificType).meta)

	---@return any
	function tb:Add(...: T): ...T | T
		local t = { ... }
		for _, v in t do
			self.pack[#self.pack + 1] = v
		end
		return table.unpack(t)
	end

	---@param q number | T?
	function tb:Disconnect(q: number | T?): ()
		if q ~= nil then
			if type(q) == "number" then
				disconnect(specificType, self.pack[q])
				table.remove(self.pack, q)
			else
				disconnect(specificType, self.pack[table.find(self.pack, q) :: number])
				table.remove(self.pack, table.find(self.pack, q))
			end
			return
		end
		for _, v in self.pack do
			disconnect(specificType, v)
		end
		table.clear(tb.pack)
	end

	function tb:Destroy(): ()
		if #tb.pack > 0 then
			self:Disconnect()
		end
		table.clear(tb.pack)
		table.clear(tb)
	end

	---@return any
	function tb:Unpack(): ...T
		return table.unpack(tb.pack)
	end

	return tb
end

local bindable: BindableEvent
do
	if ReplicatedStorage:FindFirstChild("_AddDisconnect") then
		bindable = ReplicatedStorage["_AddDisconnect"]
	else
		bindable = Instance.new("BindableEvent", ReplicatedStorage)
		bindable.Name = "_AddDisconnect"
	end

	bindable.Event:Connect(module.AddDisconnect)
end

---Create a new type for Disconnect
---@param nameType string
---@param funct any
function module.AddDisconnect(nameType: string, metatable: {} | nil, funct: any): ()
	if MetaData.Disconnect[nameType] then
		return
	end
	metatable = if metatable then metatable else MetaData.DEFAULTMETA

	MetaData.Disconnect[nameType] = { meta = metatable, funct = funct }
	bindable:Fire(nameType, metatable, funct)
end

return module
