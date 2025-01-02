type ContentDisconnect = {
	meta: [];
	funct: (value: unknown) => void;
};

export type Disconnect = {
	[key: string]: ContentDisconnect;
};

type meta = {
	__newindex: (this: meta, key: unknown, v: unknown) => void;
};
declare namespace ConnectionMeta {
	export class MetaConnection<T> {
		pack: unknown;

		constructor(specificType: string | "RBXScriptConnection" | "thread");

		Add(this: MetaConnection<T>, ...args: T[]): T | T[];
		Disconnect(this: MetaConnection<T>, q: number | T): void;
		Destroy(this: MetaConnection<T>): void;
		Unpack(this: MetaConnection<T>): T[];
	}
	export const AddDisconnect: (nameType: string, metatable: meta | undefined, funct: () => void) => void;
}
