type comm('in_, 'ret, 'ctx) =
	| Comm__request(int, 'in_): comm('in_, 'ret, [`requested])
	| Comm__reply(comm('in_, 'ret, [`requested]), int, result('ret, exn)): comm('in_, 'ret, [`replied])
