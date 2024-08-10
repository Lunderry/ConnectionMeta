--!strict
local RunService = game:GetService("RunService")
--
local module = {}

local WAITING = 1

---It's used to wait for something from a table
---@param data table
---@param index string
---@return any
function module.Wait(data: { [string]: any }, index: string): ()
	local count = 0

	while true do
		if data[index] then
			break
		end

		count += RunService.Heartbeat:Wait()

		if count > WAITING then
			error("No exist " .. index)
		end
	end

	return data[index]
end

return module
