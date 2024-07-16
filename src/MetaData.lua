--!strict
local module = {}

module.DEFAULTMETA = {
	__newindex = function(self, i, v)
		rawset(self, i, v)
	end,
}

module.Disconnect = {
	RBXScriptConnection = {
		meta = module.DEFAULTMETA,
		funct = function(v)
			v:Disconnect()
		end,
	},

	thread = {
		meta = module.DEFAULTMETA,
		funct = function(v)
			task.cancel(v)
		end,
	},
}

return module
