type comm('in_, 'ret, 'yield, 'yieldback, 'ctx) =
	| Comm__set(int, 'yieldback): comm('in_, 'ret, 'yield, 'yieldback, [`set])
	| Comm__request(int, 'in_): comm('in_, 'ret, 'yield, 'yieldback, [`requested])
	| Comm__reply(comm('in_, 'ret, 'yield, 'yieldback, [`requested]), int, result(reply('ret, 'yield), exn)): comm('in_, 'ret, 'yield, 'yieldback, [`replied])

and reply('ret, 'yield) =
	| Rep_({ async_id: int, await_id: int, app: 'yield })
	| Rep_ly('ret)

and lambda('a, 'b) = Lambda({ async_id: int });
