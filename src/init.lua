--!strict
export type MetaConnection<T> = {
	pack: { T },
	Add: (self: MetaConnection<T>, connection: { T } | T) -> ...T | T,
	Disconnect: (self: MetaConnection<T>) -> (),
	Destroy: (self: MetaConnection<T>) -> (),
	Unpack: (self: MetaConnection<T>) -> ...T,
}

local DataDisconnect = require(script.DataDisconnect)

local module = {}

local function disconnect<T>(specificType: string, value: T): ()
	if specificType then
		DataDisconnect[specificType](value)
	else
		DataDisconnect[typeof(value)](value)
	end
end

---create MetaConnection, If you want to use a custom type, use specificType.
---@param specificType string?
---@return any
function module.new<T>(specificType: string?): MetaConnection<T>
	local tb = { pack = {} } :: MetaConnection<T>

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

	function tb:Disconnect(q: number | T?): ()
		if q ~= nil then
			local remove = 0
			if type(q) == "number" then
				disconnect(specificType, self.pack[q])
				remove = q
			else
				disconnect(specificType, table.find(self.pack, q))
				remove = table.find(self.pack, q)
			end
			table.remove(self.pack, remove)
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

	function tb:Unpack(): ...T
		return table.unpack(tb.pack)
	end

	return tb
end

---Create a new type for Disconnect
---@param nameType string
---@param funct any
function module.AddDisconnect(nameType: string, funct: any): ()
	DataDisconnect[nameType] = funct
end

return module