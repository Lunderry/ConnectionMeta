return {
	RBXScriptConnection = function(v)
		v:Disconnect()
	end,

	thread = function(v)
		task.cancel(v)
	end,
}
