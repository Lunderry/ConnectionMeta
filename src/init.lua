---@diagnostic disable: undefined-doc-name
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ManagerMeta = require(script.ManagerMeta)
local MetaData = require(script.MetaData)
local Types = require(script.Types)
--
export type MetaConnection<T> = Types.MetaConnection<T>
--
local module = {}

local function selection<T>(specificType: string): Types.ContentDisconnect
	return ManagerMeta.Wait(MetaData.Disconnect, specificType) :: Types.ContentDisconnect
end

local function disconnect<T>(specificType: string, value: T): ()
	selection(specificType).funct(value)
end

---create MetaConnection, specificType is for select type save
---@param specificType string?
---@return any
function module.new<T>(specificType: string | "RBXScriptConnection" | "thread"): Types.MetaConnection<T>
	local tb = { pack = {} } :: Types.MetaConnection<T>
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
end

---Create a new type for Disconnect
---@param nameType string
---@param funct any
function module.AddDisconnect(nameType: string, metatable: {} | nil, funct: any): ()
	if MetaData.Disconnect[nameType] then
		return
	end
	metatable = if metatable then metatable else MetaData.DEFAULTMETA

	MetaData.Disconnect[nameType] = { meta = metatable, funct = funct } :: Types.ContentDisconnect
	bindable:Fire(nameType, metatable, funct)
end

bindable.Event:Connect(function(n, m, f)
	module.AddDisconnect(n, m, f)
end)

return module
