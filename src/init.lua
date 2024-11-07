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

local folder: Folder & { ObjectValue }
local bindableFolder: { [string]: BindableFunction }
do
	local function find(instanceName: string, name: string): any
		local findDisconnect = ReplicatedStorage:FindFirstChild(name)
		local r
		if findDisconnect then
			r = findDisconnect
		else
			r = Instance.new(instanceName, ReplicatedStorage)
			r.Name = name
		end
		return r
	end

	folder = find("Folder", "_Connections")
	bindableFolder = find("Folder", "_GetDisconnect")
end

local bindableLocal = Instance.new("BindableFunction", bindableFolder)
bindableLocal.Name = script:GetFullName()

---Create a new type for Disconnect
---@param nameType string
---@param funct any () -> ()
function module.AddDisconnect(nameType: string, metatable: {} | nil, funct: () -> ()): ()
	if MetaData.Disconnect[nameType] then
		return
	end
	metatable = if metatable then metatable else MetaData.DEFAULTMETA

	MetaData.Disconnect[nameType] = { meta = metatable, funct = funct } :: Types.ContentDisconnect

	--save connection
	local objectValue = Instance.new("ObjectValue", folder)
	objectValue.Name = nameType
	objectValue.Value = script
end

---@param nameType string
---@return any
bindableLocal.OnInvoke = function(nameType: string): Types.ContentDisconnect
	return MetaData.Disconnect[nameType]
end

---@param child Instance
local function scanFolder(child: Instance): ()
	if MetaData.Disconnect[child.Name] then
		return
	end

	if not child:IsA("ObjectValue") then
		return
	end

	local v = child.Value

	if v == nil or not v:IsA("Instance") then
		return
	end

	local getBindable = bindableFolder[v:GetFullName()]

	local g: Types.ContentDisconnect = getBindable:Invoke(v.Name)

	module.AddDisconnect(child.Name, g.meta, g.funct)
end

folder.ChildAdded:Connect(scanFolder)

--scan folder more
for _, v in pairs(folder:GetChildren()) do
	scanFolder(v)
end

return module
