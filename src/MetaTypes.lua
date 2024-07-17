--!strict
export type MetaConnection<T> = {
	pack: any,
	Add: (self: MetaConnection<T>, connection: { T } | T) -> ...T | T,
	Disconnect: (self: MetaConnection<T>) -> (),
	Destroy: (self: MetaConnection<T>) -> (),
	Unpack: (self: MetaConnection<T>) -> ...T,
}
--[[Create new types
examples:
export type NumberStack = MetaConnection<number>
export type letter = MetaConnection<string>
]]

return nil
