type comm('in_, 'ret, 'yield, 'yieldback, 'ctx) =
	| Comm__set(int, 'yieldback): comm('in_, 'ret, 'yield, 'yieldback, [`set])
	| Comm__request(int, 'in_): comm('in_, 'ret, 'yield, 'yieldback, [`requested])
	| Comm__reply(comm('in_, 'ret, 'yield, 'yieldback, [`requested]), int, result(reply('ret, 'yield), exn)): comm('in_, 'ret, 'yield, 'yieldback, [`replied])

and reply('ret, 'yield) =
	| Rep_(int, 'yield)
	| Rep_ly('ret)

and lambda('a, 'b) = Lambda({ await_id: int })
