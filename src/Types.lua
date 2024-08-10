export type MetaConnection<T> = {
	pack: any,
	Add: (self: MetaConnection<T>, ...T) -> ...T | T,
	Disconnect: (self: MetaConnection<T>, q: number | T?) -> (),
	Destroy: (self: MetaConnection<T>) -> (),
	Unpack: (self: MetaConnection<T>) -> ...T,
}

export type ContentDisconnect = {
	meta: {},
	funct: (value: any) -> (),
}

export type Disconnect = {
	[string]: ContentDisconnect,
}
return nil
