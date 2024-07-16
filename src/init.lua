---@diagnostic disable: undefined-doc-name
--!strict
export type MetaConnection<T> = {
	pack: any,
	Add: (self: MetaConnection<T>, connection: { T } | T) -> ...T | T,
	Disconnect: (self: MetaConnection<T>) -> (),
	Destroy: (self: MetaConnection<T>) -> (),
	Unpack: (self: MetaConnection<T>) -> ...T,
}

local MetaData = require(script.MetaData)

local module = {}

local function dslection<T>(specificType: string): { meta: {}, funct: any }
	return MetaData.Disconnect[specificType]
end

local function disconnect<T>(specificType: string, value: T): ()
	dslection(specificType).funct(value)
end

---create MetaConnection, specificType is for select type save
---@param specificType string?
---@return any
function module.new<T>(specificType: string | "RBXScriptConnection" | "thread"): MetaConnection<T>
	local tb = { pack = {} } :: MetaConnection<T>
	tb.pack = setmetatable({}, dslection(specificType).meta)

	---@param connection n {T | T}
	---@return any
	function tb:Add(connection: { T } | T): ...T | T
		if specificType ~= nil and type(connection) == "table" then
			for _, v in connection do
				self.pack[#self.pack + 1] = v
			end
			return table.unpack(connection)
		else
			self.pack[#self.pack + 1] = connection
			return connection
		end
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

---Create a new type for Disconnect
---@param nameType string
---@param funct any
function module.AddDisconnect(nameType: string, metatable: {} | nil, funct: any): ()
	metatable = if metatable then metatable else MetaData.DEFAULTMETA

	MetaData.Disconnect[nameType] = { meta = metatable, funct = funct }
end

return module
