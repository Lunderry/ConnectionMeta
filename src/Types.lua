export type MetaConnection<T> = {
	pack: any,
	Add: (self: MetaConnection<T>, ...T) -> ...T | T,
	Disconnect: (self: MetaConnection<T>, q: number | T?) -> (),
	Destroy: (self: MetaConnection<T>) -> (),
	Unpack: (self: MetaConnection<T>) -> ...T,
}
return nil
